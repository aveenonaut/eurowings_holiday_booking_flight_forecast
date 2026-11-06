# Raw data ingestion on Databricks

These scripts load the three supplied CSVs into managed Delta tables in the
development schema, `workspace.ewh_dev`. They do not create or modify PROD tables.

| Script | Purpose |
| --- | --- |
| `01_ingest_raw.sql` | Create the DEV schema and tables, then load each source with `COPY INTO` |
| `02_validate_raw.sql` | Check counts, required fields, key uniqueness, totals and full source equality |

## Run the scripts

1. Authenticate to the Databricks workspace containing the source volume.
2. Open **SQL Editor** and create a query. Select **Serverless Starter Warehouse**.
3. Paste the complete contents of [01_ingest_raw.sql](01_ingest_raw.sql) into the
   editor and run all statements in order. Wait for the last load to complete.
4. In a second query, paste and run [02_validate_raw.sql](02_validate_raw.sql).
5. Rerun both queries to check repeatability. The second ingestion should report
   zero inserted rows for each file; validation should return the same results.

Table and source names are fully qualified, so the editor's selected catalog
and schema do not determine where these scripts write. Access requires a SQL
warehouse, permission to create the DEV schema and tables, and `READ VOLUME`
on `workspace.default.ewh_source_data` with the corresponding catalog/schema
usage permissions.

To inspect the result in the UI, open **Catalog > workspace > ewh_dev**.
For example, run this read-only query to preview a table:

```sql
SELECT *
FROM workspace.ewh_dev.raw_actuals
LIMIT 10;
```

## Source and types

The source volume is `/Volumes/workspace/default/ewh_source_data/`.
Each table reads exactly one named CSV, with UTF-8 encoding, a header and a
semicolon delimiter. Files are read as strings and explicitly cast to the
declared table types. Parsing errors or required-field nulls fail ingestion.

Dates use `DATE`; market names use `STRING`. Actual and flight forecast ticket
counts use `BIGINT`. Booking forecast ticket counts use `DECIMAL(18,2)` to retain
the fractional values in the source. Revenue uses `DECIMAL(18,2)` in euros to
avoid binary floating-point rounding. Inspection confirmed that the supplied
ticket counts need at most two decimal places and revenues are whole euros.
These are raw-table types; the final forecast output schema remains a later step.

## Expected validation results

| Table | Rows | Tix | Revenue (EUR) |
| --- | ---: | ---: | ---: |
| `raw_actuals` | 20,142 | 45,453.00 | 33,314,149.00 |
| `raw_booking_forecast` | 2,452 | 23,012.74 | 18,988,449.00 |
| `raw_flight_forecast` | 2,083 | 22,413.00 | 18,330,715.00 |

For every table, `duplicate_key_rows`, `invalid_required_rows` and
`source_mismatch_rows` must be zero. A successful `ASSERT_TRUE` returns `NULL`
in `validation_assertion`; a failed condition raises an error. The script
compares every typed row in both directions with `EXCEPT ALL`, retaining
duplicate multiplicity. Matching row counts and totals alone is insufficient.

The actuals key is `(BookingDate, FlightDate, FlightMarketCluster)`; the two
forecast keys are `(Date, FlightMarketCluster)`. These uniqueness expectations
describe the supplied files, not a universal transaction identifier.

Known source anomalies, including zero revenue and a flight preceding its booking
date, remain in the raw tables. Validation proves faithful loading; it does not
resolve those anomalies or validate a forecasting method.

## Repeatability and failures

`CREATE ... IF NOT EXISTS` preserves existing objects. `COPY INTO` records
processed files in each table and skips them on subsequent runs. No `force`
reload, overwrite, truncation or automatic schema evolution is enabled.

Each load is atomic for its table, but the three table loads are not one
transaction. If a later statement fails, earlier successful loads remain.
Stop, inspect the error, and rerun after resolving it. Do not automatically
delete or recreate tables to bypass validation failures.

File-level repeatability does not remove duplicate records inside a source.
The separate key and source-equality checks detect these problems. `COPY INTO`
also skips an already loaded source path even if its content changes. Treat
the supplied files as immutable; an intentional source replacement needs a
reviewed inventory update and loading strategy.

The [source inventory](../data/sources.csv) records local-file SHA-256 checksums.
Remote source checksums should match that inventory before the initial load.

## Verified execution: 6 November 2026

Executed both SQL files through the authenticated Databricks Statement Execution
API using **Serverless Starter Warehouse**. The remote source byte sizes and
SHA-256 checksums matched `data/sources.csv` before ingestion.

| Table | Rows inserted on first run | Rows inserted on rerun |
| --- | ---: | ---: |
| `raw_actuals` | 20,142 | 0 |
| `raw_booking_forecast` | 2,452 | 0 |
| `raw_flight_forecast` | 2,083 | 0 |

Validation succeeded after both runs. Counts and exact decimal totals matched
the expectations above; duplicate keys, invalid required rows and differences
from the source rows were all zero. The final validation statement ID is
`01f1d984-30a7-1d44-b8c7-8345f6d889b1`, available in the workspace query history
to users with permission. This records a verified execution, not a guarantee
that the tables will remain unchanged after this date.

## References

- [COPY INTO syntax and repeatability](https://docs.databricks.com/aws/en/sql/language-manual/delta-copy-into)
- [Reading source files with explicit schemas](https://docs.databricks.com/aws/en/sql/language-manual/functions/read_files)
- [ASSERT_TRUE validation](https://docs.databricks.com/aws/en/sql/language-manual/functions/assert_true)
