## Sandbox Snapshots

- `02-inputs/snapshots/<date>/<Store>/<date>/…` holds `.msg` fixtures copied from production runs so we can test pipelines without touching Outlook.
- Run `python download_yourremittance.py --date YYYY-MM-DD --base-dir 02-inputs/snapshots/<date> --stores "<Store>"` to exercise the OTP downloader in “dry-run” mode.
- Add new fixtures by copying the desired `.msg` files into the matching store/date folder under `02-inputs/snapshots/`.
- Even when using snapshots, downloaded PDFs/logs are emitted to `03-outputs/remittance-runner/<date>/...`, so remove them afterwards if you don’t want to keep the artifacts.
