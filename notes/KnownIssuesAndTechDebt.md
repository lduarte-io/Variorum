# Variorum — Known Issues & Tech Debt

Deliberately-deferred work only. **Rule: no entry without naming the phase that resolves it** — if nothing owns it, fix it now instead of parking it. Remove entries when resolved (the closing phase's closeout notes the resolution).

| Item | What & why deferred | Owning phase |
|------|--------------------|--------------|
| TK2 viewport viability decision | Whether book-scrub/infinite-scroll can trust live TK2 geometry on Tahoe, or must use stored per-block length estimates, or STTextView. Facts unknowable until tried on the M3. | 6 (TK2 spike) |
| Xcode 26 install (both Macs) | Chosen: install on the Intel Air + M3; required before any 26-SDK editor work. Author action (Apple ID / download). | 6 (TK2 spike) — hard prerequisite |
| Supabase project setup | Server project, mirrored schema, seq/CAS functions, auth token. Author assists (account, dashboard). | 5 (Sync core) |
| Sync auth hardening | Phase 5 ships a single-user token; real auth/key rotation arrives with accounts. | 14 (Accounts) |
| Cross-block re-bracketing | Selecting a span across existing block boundaries → "make this a block" requires splitting touched blocks (each possibly fanned) and reconciling. v1 ships clean-inside-one-block / whole-block cases; messy cross-fan re-bracketing deferred. | 9 (Structural ops in editor) — partial; re-own at 9's closeout if still deferred |
| Markdown export | Planned so the store is never a black box; needs the read layer to exist first. | 11 (Remaining views) — or re-own at 11's closeout |
| Within-post virtualization escape hatch | Only if a real 100k+-word single post appears; block decomposition keeps the door open (AppSpec §4). | 12 (Hardening) — assess, likely re-defer with evidence |
| `AppDatabase.liveValue` failure UX | The dependency's live value `fatalError`s if the on-disk store can't open — fine while the package is headless; the app shell needs real failure handling (alert, recovery/backup path) when root composition wires `@Dependency(\.database)`. | 7 (Editor v1 / app shell) |
| Structural-undo UI wiring | The undo core (per-op inverses, session stack) lands with Phases 2–3 per AppSpec §9; menu/shortcut wiring and "Undo Divide"-style labeling need the editor. (Supersedes the old "audit/operation log" item — author decided 2026-07-04.) | 7 (Editor v1) — extend at 9 |
| Reference panel UI | The `reference` table ships in schema v1; the panel (Quick Look, PDFKit with drag-selection-into-draft, read-only WKWebView) is a view. EPUB permanently out of scope, not parked. | 11 (Remaining views) |
| restoreCommit pre-split warning | Restoring a commit that predates a divide/extract resurrects pre-split text (documented behavior, AppSpec §9); the editor should warn. Test lands Phase 3; the warning needs UI. | 7 (Editor v1) |
| Tombstone GC | Soft-delete is the only delete; purge needs a sync-aware horizon (all devices past the seq). | 12 (Hardening) |
