# Eurowings Holidays: booking-to-flight forecast reconciliation

Data science case study connecting booking-date and flight-date forecasts for
ticket volume (`Tix`) and revenue in euros, separately for each destination
market (`FlightMarketCluster`).

## Objective

Produce a table with `BookingDate`, `FlightDate`, `FlightMarketCluster`, `Tix`
and `Revenue`. Aggregating the result by either booking date or flight date,
within each market, must reproduce the corresponding supplied forecast for
both measures. The solution must preserve plausible booking lead times,
account for bookings and flights in different years, and retain the original
forecast average order values (`Revenue / Tix`).

The submission will explain the method, validation, error metrics and
limitations, and demonstrate repeatable execution and access for BI users.

## Current status

- Poetry, the Jupyter kernel, Ruff, pre-commit and GitHub Actions are configured.
- The supplied brief and three CSVs have been inspected. Their inventory is in
  [data/sources.csv](data/sources.csv).
- The original CSVs are stored in the Databricks managed volume
  `/Volumes/workspace/default/ewh_source_data/`.
- The three raw Delta tables are loaded in `workspace.ewh_dev`. The
  [SQL guide](sql/README.md) explains loading and validation.
- The [research review](docs/literature_review.md) covers 16 relevant papers,
  with reading depth and limitations recorded for each.
- The [executed analysis notebook](notebooks/01_data_analysis.ipynb) reads the raw
  SQL tables. Start with [the findings](reports/findings.md) for its results and
  [analysis decisions](docs/decisions.md) for assumptions and open questions.
  The [anomaly interpretation](docs/anomaly_interpretation.md) separates observed
  patterns from possible causes and records the limits of external evidence.
- No forecasting model or deployment job is implemented. The on-books/forecast
  conflicts and missing-key interpretation need resolution before modelling.
  There are no forecast accuracy claims yet.

## Repository layout

```text
.
├── README.md
├── pyproject.toml
├── poetry.lock
├── .gitignore
├── .pre-commit-config.yaml
├── .github/workflows/ci.yml
├── data/
│   ├── README.md          # Source descriptions, storage and verification
│   ├── sources.csv        # File inventory and SHA-256 checksums
│   └── raw/               # Original CSVs and brief; excluded from Git
├── sql/
│   ├── README.md          # Execution instructions and validation expectations
│   ├── 01_ingest_raw.sql  # Repeatable DEV raw-table loading
│   ├── 02_validate_raw.sql
│   └── 03_analysis_extract.sql
├── notebooks/
│   ├── README.md          # Connection and execution instructions
│   └── 01_data_analysis.ipynb
├── src/ewh_forecast/
│   └── data_access.py     # Complete SQL result fetching via authenticated CLI
├── tests/
│   └── test_data_access.py
├── docs/
│   ├── literature_review.md
│   ├── anomaly_interpretation.md
│   └── decisions.md
├── reports/
│   ├── findings.md
│   └── figures/           # Selected exported charts
└── outputs/               # Generated local summaries; excluded from Git
```

Start with the [data guide](data/README.md) for file schemas, date coverage and
source verification. Further folders will be added alongside their working
implementations.

## Reproduce the current setup

1. Obtain the supplied case-study files through an authorised channel and place
   them in `data/raw/`, preserving the filenames in `data/sources.csv`.
   Original files are not distributed with this repository.
2. Verify their checksums using the instructions in [data/README.md](data/README.md).
3. Install the locked environment and register the kernel as described below.
4. Run the local project checks.
5. In Databricks, run the loading and validation scripts following the
   [SQL guide](sql/README.md). This requires authorised access to the source
   volume and a SQL warehouse. Local CI does not execute these cloud statements.
6. Run [the analysis notebook](notebooks/README.md). It makes read-only SQL
   queries and writes local figures and summary outputs. Review the findings
   before interpreting partial flight cohorts or choosing modelling assumptions.
   A modelling workflow will be documented when implemented and validated.

## Environment

Use Python **3.10.18** and Poetry **2.1.4**. The locked pre-commit version
also supports the server's Git 2.30.

```bash
poetry env use python3.10
poetry install --with dev
poetry run pre-commit install
```

To register the notebook kernel:

```bash
poetry run python -m ipykernel install --user \
  --name eurowings-holiday-forecast \
  --display-name "Python (Eurowings Holiday Forecast)"
```

## Run checks locally

```bash
poetry run pre-commit run --all-files
poetry run python -m pip check
PYTHONPATH=src poetry run python -m unittest discover -s tests -v
```

Pre-commit checks Git-tracked files; newly created code is included after it is
staged with Git. The Poetry configuration and lock-file check always runs.
To check Python and notebooks before staging them, use:

```bash
poetry run ruff check .
poetry run ruff format --check .
```

To apply formatting fixes:

```bash
poetry run ruff format .
```

## Continuous integration

GitHub Actions runs **CI / Environment and code checks** on pull requests targeting
`main`, pushes to `main`, and manual runs. Feature-branch pushes are checked through
their open pull request, avoiding duplicate push/PR runs. It:

1. Sets up Python 3.10.18 and Poetry 2.1.4.
2. Installs dependencies from the committed `poetry.lock`, including development tools.
3. Checks installed dependency compatibility and imports the notebook runtime.
4. Runs the same pre-commit checks used locally: Poetry/lock-file validation;
   YAML, TOML and JSON validation; whitespace and merge-conflict checks; secret
   detection; and Ruff linting and formatting for Python files and notebooks.
5. Tests SQL result handling with mocked responses, without connecting to Databricks.

### What checks each requirement

| Requirement | Tool used here |
| --- | --- |
| YAML, TOML and JSON syntax | `pre-commit-hooks` validators; notebook JSON is included |
| JSON formatting | `pretty-format-json`, preserving key order and excluding notebooks |
| Trailing whitespace and final newlines | `pre-commit-hooks` fixers |
| Unresolved merge-conflict markers | `check-merge-conflict`, including outside an active merge |
| Secrets, tokens and private-key markers | `detect-secrets`, with external credential verification disabled |
| Black-style formatting | `ruff format --check` |
| Core Flake8 checks | Ruff `E`, `F` and `W` rules |
| isort-style import sorting | Ruff `I` rules |
| pyupgrade-style modernization | Ruff `UP` rules targeting Python 3.10 |
| nbQA-style notebook code checks | Ruff's native `.ipynb` support |

Ruff covers these requested functions; it is not a byte-for-byte replacement for
all Black output or every third-party Flake8/nbQA plugin. The configured checks
run on both Python files and notebooks. Notebook imports may appear later in a
cell. Long-line errors are ignored, matching the ancillary repo's lint policy;
formatting still wraps code where possible. Indentation rules that conflict with
the formatter are disabled.

Whitespace hooks can fix files locally; review and stage their changes before
committing again. Ruff formatting is check-only. In CI, a fixer change fails the
check and is not committed or pushed. Notebook outputs are preserved, and
notebooks are not executed in CI.

Secret detection scans text files, including notebook source and outputs. Only
`poetry.lock` is excluded from that hook because it contains generated package
hashes. There is no baseline silently accepting existing findings. Review false
positives before adding a narrow `pragma: allowlist secret` annotation. Detection
is heuristic and cannot guarantee that every secret will be found.

Tests cover full result pagination, exact decimal amounts, truncated/missing
results and SQL failures. Forecasting tests and time-based split checks should
be added alongside modelling code. A green CI result validates project checks
and tested utilities, not forecast accuracy. SQL source validation and the
analysis notebook require authenticated Databricks access and are run separately.

`poetry.toml` remains machine-local. Original source files, generated data and
Databricks authentication files are excluded from Git. Keep credentials outside
the repository; the data guide documents storage paths without credentials.
