# TOOLS (Human-readable Index)

Authoritative registry lives at `01-system/configs/tools/registry.yaml`.

This file mirrors the registry for readers. Keep entries aligned.

- remittance-runner (ops)
  - Runs `run_remittance_today.ps1` with provided flags; writes logs/manifests to `03-outputs/remittance-runner/<date>/`.
- invoices-runner (ops)
  - Runs `run_invoices_today.ps1`; writes logs/manifests to `03-outputs/invoices-runner/<date>/`.
- remit-rename-amount (ops)
  - Batch rename PDFs to append detected amounts; logs under `03-outputs/remit-rename-amount/`.
- migrate-store-date (ops)
  - Converts `Inv&Remit_Today/YYYY-MM-DD/<Store>/...` → `Inv&Remit_Today/<Store>/YYYY-MM-DD/...`; logs under `03-outputs/migrate-store-date/`.
