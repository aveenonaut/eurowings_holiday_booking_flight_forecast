# Case-study source data

The company supplied three dummy CSV datasets and a two-page assignment brief.
Original files are preserved locally in `data/raw/`, which is excluded from Git.
The CSVs are also stored in a Databricks Unity Catalog managed volume. This
repository records their metadata without distributing the original files.

## File inventory

| File | Purpose | Data rows |
| --- | --- | ---: |
| `EWH_DummyActuals.csv` | Historical booking-to-flight observations | 20,142 |
| `EWH_DummyBookingPeriodFc.csv` | Forecast by booking date and market | 2,452 |
| `EWH_DummyFlightPeriodFc.csv` | Forecast by flight date and market | 2,083 |
| `Case Study Data Science.pdf` | Assignment, expected output and evaluation questions | Not applicable |

[sources.csv](sources.csv) records each file's role, relative local path,
Databricks path where applicable, data-row count, byte size and SHA-256 checksum.
CSV row counts exclude the header. The PDF has no row count and has not been
uploaded to the volume. Checksums describe the local originals; this inventory
does not itself verify the content of remote copies.

## CSV format and fields

All three CSVs use a header row, semicolon (`;`) separators and ISO date strings
(`YYYY-MM-DD`). They can be decoded as UTF-8. Preserve the original bytes and
filenames; any cleaning belongs in derived tables.

| File | Columns, in source order |
| --- | --- |
| Actuals | `BookingDate`, `FlightDate`, `FlightMarketCluster`, `Tix`, `Revenue` |
| Booking forecast | `Date`, `FlightMarketCluster`, `Tix`, `Revenue` |
| Flight forecast | `Date`, `FlightMarketCluster`, `Tix`, `Revenue` |

`Tix` counts travellers, each including flight and accommodation. `Revenue` is
in euros. Average order value (AOV) is `Revenue / Tix`. In the booking forecast,
`Date` is the booking date; in the flight forecast, it is the flight date.

The observed keys are `(BookingDate, FlightDate, FlightMarketCluster)` for
actuals and `(Date, FlightMarketCluster)` for each forecast. These combinations
are unique in the supplied files. The actuals contain no transaction identifier;
do not assume each row represents one ticket or one uniquely identifiable order.

Actual booking dates cover 2024-01-01 through 2025-12-31; actual flight dates
cover 2024-01-04 through 2026-11-19. Booking forecast dates cover 2026-01-01
through 2026-12-30; flight forecast dates cover 2026-01-01 through 2026-12-31.

Initial inspection found fractional forecast ticket counts, zero-revenue rows,
one actual flight preceding its booking date, and different market and calendar
coverage. The two forecasts also have different annual totals. These findings
need analysis alongside the assignment's cross-year requirement. No records
have been corrected, dropped or otherwise transformed.

## Databricks source storage

- Catalog: `workspace`
- Schema: `default`
- Managed volume: `ewh_source_data`
- Volume path: `/Volumes/workspace/default/ewh_source_data/`

The volume contains all three original CSVs. Their remote byte sizes and
SHA-256 checksums were verified against [sources.csv](sources.csv) before the
initial load on 6 November 2026.

The corresponding raw Delta tables are `workspace.ewh_dev.raw_actuals`,
`workspace.ewh_dev.raw_booking_forecast` and
`workspace.ewh_dev.raw_flight_forecast`. See the [SQL guide](../sql/README.md)
for repeatable loading and validation. Source storage is shared; this step
creates only DEV tables and does not create PROD outputs.

For the Databricks CLI, use the `dbfs:` prefix when listing a volume:

```bash
databricks fs ls dbfs:/Volumes/workspace/default/ewh_source_data/ \
  --profile EWH_CASE_STUDY
```

`EWH_CASE_STUDY` is a local authenticated profile name, not a credential.
Authenticate separately and keep authentication files outside the repository.

## Verify local source files

From the repository root, run this standard-library-only check. It verifies
file sizes, SHA-256 checksums and CSV data-row counts without changing files:

```bash
python - <<'PY'
import csv
import hashlib
from pathlib import Path

with Path("data/sources.csv").open(encoding="utf-8", newline="") as inventory:
    for source in csv.DictReader(inventory):
        path = Path(source["local_path"])
        content = path.read_bytes()
        if len(content) != int(source["size_bytes"]):
            raise SystemExit(f"Size mismatch: {path}")
        if hashlib.sha256(content).hexdigest() != source["sha256"]:
            raise SystemExit(f"Checksum mismatch: {path}")
        if source["row_count"]:
            with path.open(encoding="utf-8-sig", newline="") as handle:
                reader = csv.reader(handle, delimiter=";")
                next(reader)
                rows = sum(1 for _ in reader)
            if rows != int(source["row_count"]):
                raise SystemExit(f"Row-count mismatch: {path}")
        print(f"Verified: {path}")
PY
```

A missing source file causes the check to fail. A replacement source requires
reviewing the file and intentionally updating its inventory entry. A successful
checksum check proves file identity, not business validity or forecast quality.
