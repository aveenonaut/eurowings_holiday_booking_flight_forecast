# Running the data analysis

Open [01_data_analysis.ipynb](01_data_analysis.ipynb) for the executed analysis.
It queries raw Delta tables through [03_analysis_extract.sql](../sql/03_analysis_extract.sql)
and explains each step in plain language. No model is trained and no Databricks
table is written by the notebook.

## Local Jupyter

1. Install the project with `poetry install --with dev` and select the
   **Python (Eurowings Holiday Forecast)** kernel.
2. Install the standalone Databricks CLI and authenticate an OAuth profile as
   described in the [official CLI tutorial](https://docs.databricks.com/aws/en/dev-tools/cli/tutorial).
   The profile used here is `EWH_CASE_STUDY`.
3. Ensure the CLI is on PATH or set `DATABRICKS_CLI` to its executable path.
   The setup cell also recognises this server's existing executable at
   `/tmp/ewh-databricks-cli/databricks`. This temporary installation can disappear;
   other machines need their own CLI installation. Keep credentials outside this
   repository.
4. Set `DATABRICKS_CONFIG_PROFILE` and `DATABRICKS_WAREHOUSE_ID` if your profile
   or SQL warehouse differs from the defaults in the parameter cell.
5. Open Jupyter at the repository root or in `notebooks/`, then run all cells.

If a running notebook cannot find the CLI, set its location **inside the kernel**
before running the setup cell. For this server:

```python
import os

os.environ["DATABRICKS_CLI"] = "/tmp/ewh-databricks-cli/databricks"
```

Exporting this variable in a separate terminal does not update an already
running kernel. The notebook prints the resolved executable path; authentication
continues to use the selected CLI profile.

The CLI connection uses the [Statement Execution API](https://docs.databricks.com/api/statement-execution/v1/execute-statement).
The helper in `src/ewh_forecast/data_access.py` fetches all result chunks, rejects
truncated/incomplete results and preserves SQL decimal values. No raw CSV
fallback is used. Tests mock the API; they do not need credentials or cloud access.

Python 3.10.18 analysis dependencies are locked to pandas 2.2.3, NumPy 1.26.4
and Matplotlib 3.9.4. Notebook execution/validation tools are development
dependencies. No unrelated Python environment has been modified.

## Databricks notebook option

With this repository present in a Databricks Git folder, open/import the notebook
and run it with `spark` available. The extraction SELECTs then use `spark.sql`.
Use a serverless environment with compatible analysis dependencies and access
to the three DEV raw tables. The cloud Python environment is independent of
the local Poetry environment. This execution path is provided but has not been
live-tested as a Databricks notebook; the recorded execution used local Jupyter
with real Databricks SQL results.

## Outputs and limits

- Notebook outputs contain selected descriptive tables and links to the charts
  in `reports/figures/`. Images are stored as separate PNGs rather than large
  embedded base64 strings, keeping notebook source and text outputs fully
  covered by the existing secret checks. Keep the notebook inside this
  repository so its relative image links resolve.
- `reports/figures/` contains nine exported PNG charts.
- `outputs/analysis/` contains generated summary tables, metrics and SQL
  statement IDs; this directory is excluded from Git.
- The anomaly-review tables use explicit exploratory thresholds and report
  distinct flagged rows, affected ticket/revenue shares and sensitivity to
  hypothetical omissions. These omissions do not change the main populations.
- Follow-up sections compare flagged prices with leave-one-out market/quarter
  peers, inspect zero revenues and year-end coverage, check illustrative AOV
  bounds against forecast targets, and compare lead-group AOV under common
  market/month weights. The annual boundary illustration uses shared markets.
- Monthly Decimal rounding-interval checks test the suspected August–December
  Tix scaling pattern without replacing targets. Cross-file zero-revenue tables
  and explicit calendar-year/52-week checks report the limits of possible links.
- The closing section summarises EDA treatments, unresolved assumptions and the
  hand-off to a modelling specification and baseline.
- Raw rows are not exported as a separate dataset by the notebook. The findings
  include two diagnostic date/market records to explain observed conflicts;
  notebook outputs also show selected extreme-AOV examples for review.

All raw tables and source files remain unchanged. The timing charts exclude
one negative-lead observation while raw-total checks retain it. Read the
[decisions](../docs/decisions.md) and [findings](../reports/findings.md) before
interpreting the figures. In particular, partial flight cohorts must not be
mistaken for complete final demand.

The brief describes dummy data. The [interpretation note](../docs/anomaly_interpretation.md)
separates verified patterns from possible causes and links external evidence.

Selected literature and analysis are descriptive. There is no fitted model,
backtest score, production deployment or claim of causal effects in this notebook.
