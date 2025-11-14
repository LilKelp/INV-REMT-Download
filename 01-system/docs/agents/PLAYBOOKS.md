# PLAYBOOKS

Document phrases → intents → steps → outputs under `03-outputs/<tool>/...`.

Examples:
- 「跑 AU 匯款 YYYY-MM-DD」→ remittance-runner with `-Stores 'Australia AR' -Date 'YYYY-MM-DD' -FastScan -MaxItems 400 -PruneOriginals` → `03-outputs/remittance-runner/YYYY-MM-DD/`
- 「掃描匯款（廣泛） AU+NZ YYYY-MM-DD」→ remittance-runner with `-Stores 'Australia AR','New Zealand AR' -Date 'YYYY-MM-DD' -Recurse -Broad -FastScan -MaxItems 800 -PruneOriginals` → `03-outputs/remittance-runner/YYYY-MM-DD/`
- 「下載發票 YYYY-MM-DD」→ invoices-runner with `-Date 'YYYY-MM-DD' -Recurse` → `03-outputs/invoices-runner/YYYY-MM-DD/`
