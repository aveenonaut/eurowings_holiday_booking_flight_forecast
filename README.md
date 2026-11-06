# eurowings_holiday_booking_flight_forecast

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

GitHub Actions runs **CI / Environment and code checks** on pushes, pull requests
and manual runs. It:

1. Sets up Python 3.10.18 and Poetry 2.1.4.
2. Installs dependencies from the committed `poetry.lock`, including development tools.
3. Checks installed dependency compatibility and imports the notebook runtime.
4. Runs the same pre-commit checks used locally: Poetry/lock-file validation;
   YAML, TOML and JSON validation; whitespace and merge-conflict checks; secret
   detection; and Ruff linting and formatting for Python files and notebooks.

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

The repository does not yet contain forecasting code or application tests.
Forecasting tests, time-based split checks and data validation should be added
alongside the corresponding code. A green CI result currently validates the
project setup and code checks, not forecast accuracy.

Commit `pyproject.toml`, `poetry.lock`, `.pre-commit-config.yaml`, `.gitignore`,
this README and `.github/workflows/ci.yml`. `poetry.toml` remains local.
The workflow starts running after these changes are committed and pushed.
