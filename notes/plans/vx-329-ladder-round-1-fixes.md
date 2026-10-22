# VX-329 — ladder round 1, the FIX LEG (Opus implementer, 2026-10-22)

**Not done in this leg, first:** nothing under `Sources/VariorumCore/Sync/` (the fence — `StaticSyncKeyProvider`, orphaned
by finding 3's deletion, is the orchestrator's own carve right after this leg lands); no refusal for a stranger's
`-wal`/`-journal` beside a fresh pick (the reviewer's final call: a Low ticket at closeout, never built here); no Mac or
phone `xcodebuild test` run (the brief's limit — the re-run list is under EVIDENCE). **The rulings (resumed leg):** the
dispositions landed at `d438050f9` and the leg stopped; the reviewer's final calls (`notes/plans/vx-329-ladder-round-1.md`
§"THE REVIEWER'S FINAL CALLS", `72e2f7c73`) UPHELD finding 1's dispute (the `-shm` counter-pin is the pin of record, the
`-wal` pin withdrawn as hollow), confirmed findings 2 and 4 as planned, and recorded the orchestrator's option (a) for
finding 3 (delete the runner and its suite; `VaultEnrollment` KEPT). This leg then applied all four, in the order below.

**Scope:** the CODE findings of `notes/plans/vx-329-ladder-round-1.md` only (verbatim there — the spec). The record/doc
findings (the MAJOR, the deploy-checklist MINOR, the L1 canon-note MINOR, the runbook MINOR, the zsh NIT) are the
orchestrator's, fixed at `2240a7f19` — not dispositioned here.

**Preflight (read in full, not delegated):** CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md`
whole; the plan `notes/plans/vx-329-release-switch.md` §5 (the U1, U3, R1, Mac fix-leg and phone fix-leg records) and
§6 whole (the kickoff record, the cut, the environment traps, §6a–§6c, the L0/VX-465/pg_temp/L1/R1-sizing records,
the stage batch record); the findings file `notes/plans/vx-329-ladder-round-1.md` IN FULL. Code read per finding below.

## LIVE STATUS (PENDING = unverified)

- Piece D — this file, the four dispositions: DONE (`d438050f9`).
- Finding 1 (MINOR, the export's sidecar sweep): **DONE** — pin `53635410d`, fix `da778d459`. The pin of record
  `StorePlaintextExportTests.aStrangersShmBesideThePickSurvivesTheExport` (stranger bytes at `<picked>-shm` in a plain
  writable temp folder; `export`; the copy lands, the stranger's file survives byte-identical — the comment says why only
  `-shm` discriminates). **RED on the old code** (`swift test --filter StorePlaintextExportTests`: `✘ … 4 tests in 1 suite
  failed … with 2 issues` — `fileExists(atPath: stranger.path)` and the byte-identity, the sweep removed it). THE FIX:
  the four sweep lines deleted, one comment saying why none follows the copy. **GREEN after:** the export suites
  (`StorePlaintextExportTests|PlaintextExportImportTests|MCPGrantSchemaTests|LibraryClassifierTests
  |LocalMachineryRecreationTests|ProtectionRecordSchemaTests`) `✔ Test run with 50 tests in 6 suites passed` (R1's 49/6 +
  this pin). **REVERT CHECK (on `da778d459`, the tree clean first):** the sweep's three lines restored alone → the pin RED
  for its stated reason (the same 2 issues); restored by `git checkout --`, `git diff --exit-code` clean.
- Finding 2 (MINOR, the pg_temp belt's drift pin): NOT-STARTED — the plan below.
- Finding 3 (MINOR, `Crypto/VaultBootstrap.swift`): NOT-STARTED — option (a): delete the runner + its suite, the
  comments outside Sync/ made true, `VaultEnrollment` KEPT.
- Finding 4 (NIT, the stale collision-sweep comment): **DONE** (this commit) — `EditorCommands.swift:562–564` now says
  the other `l` chords are ⌘L (Switch Wing) and ⌘⇧L (Save Choices as Lens), ⌃⌘Q untouched; re-swept true (the key table's
  `l` rows are exactly `.switchWing` ⌘L, `.saveChoicesAsLens` ⌘⇧L, `.lockLibraryNow` ⌃⌘L, and the three
  `.keyboardShortcut("l", …)` call sites match them). Comment-only; its compile is the closing `build-for-testing`.
- Evidence (suites, build-for-testing, the Mac re-run list): NOT-STARTED.

## THE DISPOSITIONS (one row per code finding)

### Finding 1 — [MINOR] `StorePlaintextExport.swift:90–92`, the post-export sidecar sweep — AGREE (fix) · DISPUTE (pin shape)

**Agree:** the sweep removes none of the export's own litter (with `PRAGMA plain.journal_mode = MEMORY` the copy makes
no sidecar; the sweep runs only after a whole copy — a throw skips it), so its only effect is on pre-existing files of
those names beside the pick. Delete it (lines 89–92), as the finding says.

**Dispute — the pin as specified (plant `<picked>-wal`, export, assert it survives) is red on BOTH sides, so it cannot
be the red-on-old pin; and the finding's own example input is not the sweep's deletion.** The counter-mechanism: SQLite
itself removes a `-wal` and a `-journal` beside a ZERO-PAGE database at the first shared lock on it — the pager's
open-WAL-if-present step deletes the WAL file when the database has no pages, and its hot-journal check deletes a
journal beside a zero-page database (a journal of an empty database is never hot). The ATTACH creates the picked file at
0 bytes, so the very first statement that reads `plain` (the journal-mode pragma, before `sqlcipher_export`) deletes a
planted `<picked>-wal` / `<picked>-journal` — sweep or no sweep. Only `-shm` is outside that road (SQLite opens and
removes `-shm` only in WAL mode, which the copy never enters).

**The evidence (transient probes — never committed; restored and removed before this commit):**
- P1 — the REAL export (`StorePlaintextExport.export`, the app's SQLCipher through the core), a probe suite planting
  stranger bytes at each sidecar name beside a fresh pick in a plain writable temp folder, one case per name. On the
  current code: all three GONE (`survived=false` × 3). With the sweep's four lines transiently removed (then restored
  by `git checkout --`, `git diff --exit-code Sources/` clean): **`-wal` GONE, `-journal` GONE, `-shm` SURVIVED
  byte-identical.**
- P2 — the system `/usr/bin/sqlite3` (3.54.0), the same three planted beside a not-yet-existing `p.sqlite`: `ATTACH
  'p.sqlite' AS plain; PRAGMA plain.journal_mode=MEMORY;` alone → `p.sqlite-wal` and `p.sqlite-journal` deleted,
  `p.sqlite-shm` kept; a first write after it (`CREATE TABLE plain.t(x)`) → `-shm` still kept. The deletion is SQLite's
  own convention (a sidecar of those names IS that database's), not SQLCipher's and not the sweep's.

**Counter-proposal for the pin (for the reviewer's call):** plant `<picked>-shm` (stranger bytes) in a plain writable
temp folder, run `export`, assert it survives byte-identical — RED on the current code (the sweep removes it — P1),
GREEN with the sweep deleted (P1). The pin's comment would say why only `-shm` discriminates.

**What deleting the sweep does NOT change (stated, not built):** a stranger's `<picked>-wal` / `<picked>-journal` beside
a FRESH pick is still removed — by SQLite at the ATTACH. Avoiding that would need a new refusal (e.g. the export's
never-overwrite guard extended to those two names, with words) — a behavior decision, not this finding's fix; offered as
an option only. The finding's severity reads the same or lower: the sweep's one unique deletion is `-shm`.

### Finding 2 — [MINOR] `Server/supabase/maintenance/vx213-pg-temp-search-path.sql`, no drift pin — AGREE

The mechanism is real as stated: nothing in `Tests/` or `Sources/` reads the artifact (re-grepped), and a later
`create or replace` with a bare `set search_path = public` resets the function's SET clause (a replace resets
`proconfig` — exactly why the artifact must ride after 17, which re-creates `key_vault_update` bare).

**Planned fix (the AuthRLSDDL idiom — the `deployShapeProblems` / `truncateProblems` shape: a pure check + the real arm +
a doctored-fixture bite proof):**
- A pure resolver over the deploy ORDER: `01`–`04`, the lockstep chain (`lockstepFiles`) with the three
  function-creating maintenance artifacts at their deploy positions (`13j-window-pull-rename` after 10, the pre-13x
  ladder overlay after 11, `beta-signup-auto-entitle` after 12), then `vx213-pg-temp-search-path.sql` right after
  `17_phase_vx307_vault.sql`, then every LATER lockstep file after it (so a future marker-15 file deploys after the belt
  — the finding's drift case). Per exact signature (name + normalized argument types — the chain drops old overloads by
  signature): `create or replace function` sets the definer flag and the SET search_path (nil when absent — the reset);
  `drop function if exists` removes it; `alter function … set search_path = …` overrides it.
- Problems it names: a live SECURITY DEFINER function, or any live function carrying a search_path (the artifact's four
  invoker helpers), whose FINAL list does not end in `pg_temp`; an artifact alter that names a signature not live at its
  position (`rls_auto_enable()` exempted with its reason as data — project furniture the chain never creates, the grant
  sweep's own row); an alter whose list minus the trailing `pg_temp` differs from the list in force there (the
  artifact's "each list preserved" claim — `sync_challenge`/`sync_key_proof_check` keep `extensions`).
- Tests: the real arm (no problems — every one of the 18 chain functions the artifact lists resolves to a trailing
  `pg_temp`); the bite proof (the artifact left out → `key_vault_update` and every other flagged; a doctored later
  lockstep file re-creating `key_vault_update` with bare `public` → flagged; an alter dropping `extensions` from
  `sync_challenge` → flagged).
- Red-on-old: the real arm RED with the artifact removed from the order (behavioral revert, restored, recorded here).

### Finding 3 — [MINOR] `Sources/VariorumCore/Crypto/VaultBootstrap.swift`, the dangling disposition — AGREE (the orchestrator's ruling: delete) · STOP-AND-FLAG (a Sync/ ripple)

**Agree** with the ruling: zero product callers (re-grepped: `VaultBootstrap` appears only in its file, its suite and a
`Package.swift` comment); `SyncEngine.resyncReinitialize` stays live (its one other call, `Sync/PurgeJanitor.swift:809` — re-grepped).
Planned: delete `Sources/VariorumCore/Crypto/VaultBootstrap.swift` + `Tests/VariorumCoreTests/VaultBootstrapTests.swift`;
make the comments outside Sync/ that name the runner true (`Package.swift:73–77`, `Crypto/VaultEnrollment.swift:7` and
`:102`, `Tests/VariorumCoreTests/Support/ScriptedVaultServer.swift:6`); evidence the build + a residue grep.

**STOP-AND-FLAG — the deletion ripples into `Sources/VariorumCore/Sync/` (the brief's stop condition):**
`StaticSyncKeyProvider` (`Sync/SyncEncryption.swift:114–128`) has exactly ONE caller anywhere — `VaultBootstrap.swift:136`
(`rg --word-regexp` over `Sources/`, `App/`, `Tools/`, `Tests/`: no other, product or test). Deleting the runner leaves
it a caller-less public type in Sync/, and its doc comment names two deleted consumers ("the `vault-bootstrap` runner,
the re-key brain's `resyncReinitialize`-only engine" — `CorpusRotation`, gone at L1). The build needs no Sync/ line
(the type is public, so no unused-symbol warning); finishing the "nothing kept dead" disposition does.

**A second cascade, outside Sync/ (flagged, not mine to widen):** `Crypto/VaultEnrollment.swift` (`VaultEnrollment`,
`VaultEnrollmentError`, `DeviceKeyMaterial`) has `VaultBootstrap` as its ONLY product consumer on this tree — the U1
record's "`Auth/AccountLifecycle`" consumer reads `KeyVaultClient`, not `VaultEnrollment` (re-grepped). After the
deletion it is product-dead, reached only by tests (`VaultEnrollmentTests`, `AccountLifecycleTests`' world,
`ScriptedVaultServer`). Deleting it too would rewire `AccountLifecycleTests`' world — beyond the ruling's "delete it with
its suite".

**Options for the orchestrator:** (a) I delete `VaultBootstrap` + its suite now (no Sync/ line); the orchestrator carves
`StaticSyncKeyProvider` + its comment in its own Fable-hands Sync/ commit (the L1 precedent), and rules `VaultEnrollment`
separately (same pass or a ticket); (b) as (a), but `StaticSyncKeyProvider` is KEPT as generic fixed-key furniture with
only its comment made true (still a Sync/ line — the orchestrator's); (c) hold the deletion until both cascades are
ruled together. NOT applied pending the word.

### Finding 4 — [NIT] `App/Variorum/Variorum/EditorCommands.swift:563`, the stale collision-sweep comment — AGREE

Verified: ⌘L is Switch Wing (`CapabilityRegistry.swift:2519`, `shortcutLabel: "\u{2318}L"`), so "the only `l` chord
anywhere in the app is ⌘⇧L" is false; the key table's comment at `:355–358` already lists both. **Planned fix:** the
File menu's comment (`:562–564`) says the `l` chords are ⌘L (Switch Wing) and ⌘⇧L (Save Choices as Lens), ⌃⌘L free,
⌃⌘Q (the system's Lock Screen) untouched — comment-only; no pin (the NIT names none); evidence the Mac
`build-for-testing`.

## EVIDENCE

NOT-STARTED — after the rulings. The planned closing set: `swift build`; `swift test --filter
'StorePlaintextExportTests|PlaintextExportImportTests|AuthRLSDDLTests|AccountLifecycleTests|VaultEnrollmentTests|KeyVaultClientTests'`
both configurations (+ the full core suite debug and release if finding 3 deletes); `xcodebuild build-for-testing`
Mac + iOS. The Mac suites for the orchestrator's re-run (finding 1 — every app suite that names `StorePlaintextExport`):
`PlaintextExportDoorTests`, `PlaintextExportBringInRoadTests`, `PickedCopyRoadTests` (the export's app callers are
`PlaintextExportModel`, `DataSafetyPane`, `SQLCipherLibraryLeaf`) — PENDING the applied fix.
