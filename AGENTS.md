# AGENTS.md — Invoices/Remittance Automation (Outlook)

Last updated: 2025-11-12

## Purpose

This repository contains PowerShell automations that fetch, organize, and normalize “Invoices” and “Remittance Advice” from Outlook. It is designed for high signal, low overhead operation on a Windows workstation with classic Outlook.

Key outcomes
- Pulls invoice and remittance content per-account, per-day, using Sydney time windows.
- Saves PDFs (and, for selected senders, the original email as .msg) with deterministic, deduplicated names.
- Renames remittance PDFs to include the total amount when extractable; invoices keep the original attachment filename.
- Maintains a clean, minimal folder structure for easy handoff and downstream processing.

## Folder Structure

Root: `Inv&Remit_Today`
- First layer: Outlook store/mailbox display name (e.g., `AZhao@novabio.com`, `Australia AR`, `New Zealand AR`)
- Second layer: date in `YYYY-MM-DD`

Examples
- `Inv&Remit_Today/AZhao@novabio.com/2025-11-12/...`
- `Inv&Remit_Today/Australia AR/2025-11-12/...`

The migration script `migrate_to_store_date.ps1` converts older `Date/Store` layouts to `Store/Date`.

## Best Practices

- Confirm date in Sydney time before running.
- Run one store and one date per invocation for reliability and clear logs.
- Prefer Inbox-only with fast scan; add `-Recurse` only when sweeping subfolders is necessary.
- Keep artifacts out of version control: `Inv&Remit_Today/` is .gitignored.
- Use Poppler (pdftotext) under `tools/poppler` for fast, accurate text extraction; scripts auto-detect it.
- Invoices keep original filenames; only remittance PDFs are renamed to append the detected total.
- Use the allowlist for partners that send non-PDF remittances; those are saved as `.msg` with amounts when found in the email text.

## Timezone & Date Windows

- Default timezone: `AUS Eastern Standard Time` (Sydney). Each run targets an exact calendar day in Sydney time, converted for Outlook MAPI filters.
- Runners operate on a single date per invocation for clarity and reliability. To cover ranges, loop dates at the caller or add range flags if needed.

## Mailboxes, Profiles, and Routing Rules

Invoices
- Target store: `AZhao@novabio.com`
- Scope: Inbox (optionally with `-Recurse` for subfolders)
- Attachments: PDFs only
- Foldering: `Inv&Remit_Today/AZhao@novabio.com/YYYY-MM-DD`

Remittance Advice
- Target stores: `Australia AR`, `New Zealand AR`
- Blocked senders: entire `@novabio.com` domain and specific `AU-AR@novabio.com`, `NZ-AR@novabio.com`
- Allowlist senders (always save):
  - `SharedServicesAccountsPayable@act.gov.au`
  - `finance@yourremittance.com.au`
  - `noreply_remittances@mater.org.au`
- Behavior for allowlist senders:
  - If message has PDFs → save PDFs.
  - If message has no PDFs → save the email as `.msg` (file name includes extracted amount when found).
- General matching (non-allowlisted):
  - Subject contains “remittance” OR at least one attachment filename contains “remit”.
  - PDFs only; inline images skipped.
- Dedupe: per message EntryID + attachment index + name + size.
- Renaming: PDFs are renamed to append the extracted total amount when possible; originals are pruned so only one copy remains.

## Amount Extraction

Preferred: `pdftotext` (Poppler). The scripts auto-detect it on PATH, Program Files, and recursively under `tools/poppler`.

Fallbacks:
- Adobe Acrobat Pro COM/JS export (if installed); optionally attempts `js.ocr()`.
- Microsoft Word COM automation. If the PDF is image-only without OCR, extraction may be empty; then derive amount from email subject/body (allowlisted senders only).

Optional: External OCR (e.g., OCRmyPDF/Tesseract) can add a text layer before extraction.

## Tools (Scripts)

Primary runners
- `run_invoices_today.ps1`
  - Purpose: Fetch invoice PDFs from `AZhao@novabio.com` for a given date window.
  - Key params: `-Date`, `-TimeZoneId`, `-Recurse`
  - Output: `Inv&Remit_Today/AZhao@novabio.com/YYYY-MM-DD`

- `run_remittance_today.ps1`
  - Purpose: Fetch remittance PDFs (and allowlisted `.msg` emails) from AR mailboxes for a given date.
  - Key params: `-Stores`, `-Date`, `-TimeZoneId`, `-FastScan`, `-MaxItems`, `-Recurse`, `-PruneOriginals`, `-Broad`, `-AllowSenders`
  - Output: `Inv&Remit_Today/<Store>/YYYY-MM-DD`
  - Notes: Dedupe, blocklist/allowlist, amount-in-filename for PDFs; `.msg` for allowlisted senders with non-PDF payloads.

Supporting
- `download_invoices_today.ps1`
  - Larger, profile-based script (Invoices/Remittance) with index CSV and optional domain grouping. Kept for advanced scenarios; not required for normal day-to-day runs.

- `cleanup_invoices_today.ps1`
  - Flattens allowed stores and removes non-allowed folders or loose files under a date. Supports `-DryRun`.

- `migrate_to_store_date.ps1`
  - Moves old layout (`Inv&Remit_Today/YYYY-MM-DD/<Store>/...`) to new layout (`Inv&Remit_Today/<Store>/YYYY-MM-DD/...`). Supports `-DryRun`.

- `rename_amount_in_folder.ps1`
  - Batch rename PDFs in a folder to include detected amounts; prunes originals when duplicates exist.

- `install_poppler.ps1`
  - Downloads and extracts the latest Poppler portable zip to `tools/poppler`; all scripts auto-detect `pdftotext.exe` there.

- `publish_to_github.ps1`
  - Initializes/commits/pushes the repository (skipping the download root via `.gitignore`).

## Runbook (Handbook)

Always confirm the date (Sydney) with the user before running.

Invoices (today, Inbox + subfolders)
```
powershell -NoProfile -ExecutionPolicy Bypass -File .\run_invoices_today.ps1 -Recurse -Date 'YYYY-MM-DD' -TimeZoneId 'AUS Eastern Standard Time'
```

Remittance (single day, Inbox only, fast & robust)
```
powershell -NoProfile -ExecutionPolicy Bypass -File .\run_remittance_today.ps1 \
  -Stores 'Australia AR' \
  -Date 'YYYY-MM-DD' -TimeZoneId 'AUS Eastern Standard Time' \
  -FastScan -MaxItems 200 -PruneOriginals
```

Remittance (subfolders included, broader sweep)
```
powershell -NoProfile -ExecutionPolicy Bypass -File .\run_remittance_today.ps1 \
  -Stores 'Australia AR','New Zealand AR' \
  -Date 'YYYY-MM-DD' -TimeZoneId 'AUS Eastern Standard Time' \
  -Recurse -FastScan -MaxItems 400 -PruneOriginals
```

Retro-rename totals in an existing folder
```
powershell -NoProfile -ExecutionPolicy Bypass -File .\rename_amount_in_folder.ps1 -Folder "Inv&Remit_Today\<Store>\<YYYY-MM-DD>"
```

Allowlist-only days (emails saved as .msg when no PDFs)
- The allowlist is active by default. If messages from `act.gov.au`, `yourremittance.com.au`, or `mater.org.au` contain only non-PDFs, `.msg` is saved with the amount when extractable from subject/body.

Migrate old folders to Store/Date
```
powershell -NoProfile -ExecutionPolicy Bypass -File .\migrate_to_store_date.ps1 -DryRun
powershell -NoProfile -ExecutionPolicy Bypass -File .\migrate_to_store_date.ps1
```

## Operational Policies

- Idempotency: Dedupe avoids double-saves; originals are pruned after renaming to keep one copy.
- Safety: Domain block for `@novabio.com` on remittance unless sender is explicitly allowlisted.
- Scope control: Prefer Inbox-only + FastScan for speed; add `-Recurse` for thorough sweeps when needed.
- Logging: Console emits “Saved:” paths and the final “Save folder:” summary. The legacy downloader can emit `_index.csv` if needed.

## Dependencies

- Windows + PowerShell 5.1+
- Classic Outlook for Windows (COM/MAPI). The new “Outlook (new)” app does not support COM.
- Microsoft Word (optional fallback for text extraction).
- Poppler `pdftotext` (optional, recommended). If available, rename-with-amount becomes faster and more reliable.

## Version Control

- `.gitignore` excludes `Inv&Remit_Today/` (and legacy `Invoices_Today/`) to keep downloaded artifacts out of the repo.
- Use `publish_to_github.ps1` to initialize/commit/push when `git` is available, or use GitHub Desktop.
- Commit messages: concise and present tense (e.g., “feat: …”, “fix: …”, “chore: …”).

## Troubleshooting

Timeouts or hangs
- Reduce scope: Inbox-only; lower `-MaxItems`.
- Run per-store, per-day; avoid multi-day bulk in one pass.
- Ensure classic Outlook is open and responsive.

Missing renames (no amount)
- PDF may be image-only without OCR. Provide `pdftotext.exe` or use Acrobat/OCR; otherwise amount may be derived from email subject/body for allowlisted senders only.

Nothing saved today
- Confirm correct store, and that the item arrived in the Inbox (or add `-Recurse`).
- Validate subject/filename patterns; add `-Broad` for sweep days.

Blocked senders
- Remittance blocks `@novabio.com`. Add explicit addresses to `-AllowSenders` to override block for trusted partners only.

## Extensibility

- Add stores: supply `-Stores` to remittance runner.
- Expand allowlist: pass additional addresses in `-AllowSenders`.
- Adjust patterns: update subject/filename regexes if needed.
- Change timezone: set `-TimeZoneId` per run or persist a new default.

## Design Principles

- Clarity over cleverness: predictable foldering, single-date runs, explicit stores.
- Low waste: dedupe early, prune originals, minimize scans.
- Safety-first: strict domain blocks with explicit allowlist.
- Composable: small runner scripts for day-to-day, larger script for advanced scenarios.
