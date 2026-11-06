"""Read SQL results through an existing Databricks CLI OAuth profile.

Credentials stay in the CLI's authentication storage. This module neither reads
source CSVs nor manages tables. The caller supplies the SQL to execute.
"""

import json
import os
import shutil
import subprocess
import tempfile
import time
from decimal import Decimal
from pathlib import Path

import pandas as pd


def _api(method, endpoint, *, profile, cli_path, payload=None):
    command = [cli_path, "api", method, endpoint, "--profile", profile, "-o", "json"]
    with tempfile.TemporaryDirectory(prefix="ewh-sql-") as directory:
        if payload is not None:
            request = Path(directory) / "request.json"
            request.write_text(json.dumps(payload), encoding="utf-8")
            command.extend(["--json", f"@{request}"])
        result = subprocess.run(
            command, capture_output=True, text=True, timeout=90, check=False
        )
    if result.returncode:
        raise RuntimeError(f"Databricks CLI request failed: {result.stderr.strip()}")
    return json.loads(result.stdout)


def query_dataframe(statement, *, warehouse_id, profile="EWH_CASE_STUDY", timeout=600):
    """Execute SQL and fetch every inline result chunk, preserving decimals.

    Set DATABRICKS_CLI if the CLI is not on PATH. The SQL in this analysis is
    read-only; this function is not an SQL permission or security boundary.
    """
    cli_path = os.environ.get("DATABRICKS_CLI") or shutil.which("databricks")
    if not cli_path:
        raise RuntimeError(
            "Install the Databricks CLI or set DATABRICKS_CLI to its path."
        )

    def request(method, endpoint, payload=None):
        return _api(
            method, endpoint, profile=profile, cli_path=cli_path, payload=payload
        )

    response = request(
        "post",
        "/api/2.0/sql/statements",
        {
            "warehouse_id": warehouse_id,
            "statement": statement,
            "wait_timeout": "10s",
            "on_wait_timeout": "CONTINUE",
            "disposition": "INLINE",
            "format": "JSON_ARRAY",
        },
    )
    statement_id = response["statement_id"]
    deadline = time.monotonic() + timeout
    while response["status"]["state"] in {"PENDING", "RUNNING"}:
        if time.monotonic() >= deadline:
            raise TimeoutError(
                f"SQL still running: {statement_id}; inspect query history."
            )
        time.sleep(2)
        response = request("get", f"/api/2.0/sql/statements/{statement_id}")
    if response["status"]["state"] != "SUCCEEDED":
        raise RuntimeError(f"SQL failed: {response['status']}")

    manifest = response["manifest"]
    if manifest.get("truncated"):
        raise RuntimeError("SQL result was truncated; refusing an incomplete analysis.")
    result = response.get("result", {})
    rows = list(result.get("data_array", []))
    next_link = result.get("next_chunk_internal_link")
    expected_prefix = f"/api/2.0/sql/statements/{statement_id}/result/chunks/"
    seen_links = set()
    while next_link:
        if not next_link.startswith(expected_prefix) or next_link in seen_links:
            raise RuntimeError("Unexpected or repeated SQL result chunk link.")
        seen_links.add(next_link)
        result = request("get", next_link)
        rows.extend(result.get("data_array", []))
        next_link = result.get("next_chunk_internal_link")
    if len(rows) != manifest["total_row_count"]:
        raise RuntimeError("Fetched row count differs from the SQL result manifest.")

    columns = manifest["schema"]["columns"]
    frame = pd.DataFrame(rows, columns=[column["name"] for column in columns])
    for column in columns:
        name, kind = column["name"], column["type_name"]
        if kind == "DATE":
            frame[name] = pd.to_datetime(frame[name], format="%Y-%m-%d", errors="raise")
        elif kind == "DECIMAL":
            frame[name] = frame[name].map(
                lambda value: Decimal(value) if value is not None else None
            )
        elif kind in {"BYTE", "SHORT", "INT", "LONG"}:
            frame[name] = pd.to_numeric(frame[name], errors="raise").astype("Int64")
    frame.attrs["statement_id"] = statement_id
    return frame
