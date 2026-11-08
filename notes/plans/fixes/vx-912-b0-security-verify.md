# VX-912 · B0 — the trimmed VX-751 security re-verify (the verdict tables)

**Run 2026-11-08 by the orchestrator (reading + prod-read probes only; no code). Scope per R-912-6 — two halves: (a) the abuse-guard re-verify + the RPC-door inventory since 13y; (b) the exploit-shaped-text flag pass over the open Castle & sync / MCP ticket lines + the fix records' open-items sections. The deep per-paragraph read of record BODIES is VX-754's fan-out job, deliberately not here.**

## (a) The abuse-guard re-verify — HOLDS

Probed live (production, read-only, 2026-11-08):

- **`sync_push` carries the 13y ruled numbers EXACTLY** in its deployed body: `batch_rows > 2000` per-call cap · `budget_lifetime >= 500000` threshold · `budget_window_rows + batch_rows > 50000` per `interval '24 hours'` tumbling window · both refusals typed `VARIORUM_WRITE_QUOTA` carrying `retry_after_seconds` (0 for the cap; the window's remainder computed). Unchanged by every artifact since 12.
- **`AuthRateLimit.swift` stands honest:** the token endpoint's 150 req/5 min/IP stated as a fact with its caveats written (IP-scoped, under-enforcement reports, "a speed bump, never the wall — the walls are the password itself, the per-request key proof, and the E2EE design"). No change needed; the platform-side setting is Supabase's default (a dashboard glance re-confirms it any time, hers, optional).
- **`sync_reencrypt` is GONE from production** (rotation retired whole at artifact 17/VX-329) — one fewer door than the 13y world. The census confirms no function of that name exists.

## (a) The RPC-door inventory (production census, 2026-11-08 — 23 public functions)

**Not callable / not authenticated-reachable (no door):** `key_vault_require_proof_hash`, `rls_auto_enable`, `stamp_server_seq`, `signup_auto_entitle` (trigger functions — Postgres refuses direct invocation of `returns trigger` functions, so their broad ACLs are inert); `entitlement_set` (service_role only); `next_tenant_seq`, `sync_table_pk`, `sync_constant_time_equal`, `sync_key_gate`, `sync_key_proof_check` (definer-internal, no authenticated grant).

**The authenticated doors — each quota'd or exempt with the reason:**

| Door | Verdict | Reason |
|---|---|---|
| `sync_push` | **QUOTA'D** | the one write-volume door; the three ruled numbers verified above |
| `sync_pull` / `sync_pull_remaining` | exempt | reads, own partition, window-bounded (max_rows; vx495's shape B); the one write is the device-cursor upsert — see the recorded corner below |
| `sync_challenge` | exempt — **belted** | max 32 nonces/call, a 5-minute TTL sweep on every call, a hard cap of 64 live nonces per account (oldest evicted) — verified in the deployed body; no growth vector |
| `key_proof_enroll` | exempt | one-time; ALREADY_ENROLLED afterwards; writes one vault secret |
| `key_vault_update` | exempt | single-row CAS (revision-gated), challenge-proofed, own row only; rotation-era multi-step machinery retired at 17 |
| `sync_purge_execute` | exempt (by design, 13j) | destructive-to-self only, own partition, challenge-proofed; purge deliberately un-quota'd |
| `account_data_truncate` | exempt | destructive-to-self, challenge-proofed + the 13y re-auth window |
| `account_purge` | exempt | account suicide; self-scoped |
| `sync_horizon` · `sync_purge_ledger` · `sync_schema_version` · `sync_visibility_horizon_ms` | exempt | reads |

**The one recorded corner (exempt-with-reason, belt offered):** `sync_pull`'s device-cursor upsert mints one `device_cursor` row per distinct `for_device` value with **no per-account cap** — an authenticated caller can grow rows in its own partition without touching the write quota. Why it is acceptable as stands: entirely self-scoped (no cross-tenant reach); the purge horizon is protected by the 13j design regardless (the 60-day drop-out ages stale cursors out, and the content-free purged-ids ledger fences returners, so even an evicted-or-stale real device cannot resurrect purged rows); rows are four small columns; `account_data_truncate`/`account_purge` clear them. **The optional belt (her call, a maintenance script, not a lockstep):** cap live device rows per account on the `sync_challenge` pattern (N = 64, oldest `seen_at` evicted) — offered as a mintable Low ticket, not built here.

## (b) The exploit-shaped-text flag pass (ticket lines + record open-items sections)

Criterion (R-912-6): flag ONLY wording that states a live road to keys/plaintext/bypass plainly enough to follow — never the existence of bugs. All 117 open Castle & sync and MCP area lines read; all 17 fix-record "Open items" sections read (every one is ticket pointers and bundle references — nothing exploit-shaped there).

**Flags (her keep/redact/fix call):**
1. **VX-443** — "Today's store-id envelope beside the slot keeps the pre-crossing key after a new-road crossing." The one genuinely road-shaped line: it names where a STALE KEY persists. Candidates: fix cheap next wave (the VX-508 shape — clear the stale envelope), or reword the public line. Advice: fix — it's the same class she just closed on the server side.
2. **VX-891** — the gathering-cursor hidden-vs-missing asymmetry: the line states a fence ORACLE (hidden distinguishable from missing via cursor resume), the exact promise the fence makes. Advice: fix pre-OSS (the fence's byte-identical promise is a headline property; a published asymmetry invites probing). Candidate rider/next-wave.
3. **VX-396** — a clientInfo.name holding U+0000 binds as its prefix: identity-collision-shaped (a local client could collide with an approved name). K2's recorded non-defeat (same-user malware) already brackets it, and the setup-key binding is the real fence — but the guard is cheap (refuse/strip NUL at the door, the VX-357 family). Advice: fix cheap.
4. **VM-15** — borderline, advice KEEP: "a sibling phone that hasn't followed into Castle stays Apple-openable" is a product truth the protection pages already frame (every device must follow), not a secret road.

**Stale-close candidates found by the pass (the rotation era ended at artifact 17):** VX-212 (rotation poison-row case — the machinery it names no longer exists on the server; close or re-point) · VX-475 (the attacker-suite pin reads file 12's `sync_reencrypt` body — the function is dropped from production; the pin needs re-pointing or the ticket closing).

**Everything else read and KEPT without a flag** — honest bug/debt/UX lines whose visibility is her ruled posture ("I have open issues, that's just life").
