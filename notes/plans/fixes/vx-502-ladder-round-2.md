# VX-502 — ladder round 2 (a fresh `opus-reviewer`, REVIEW_PROMPT verbatim; 2026-10-27 ~04:15 MDT)

Diff reviewed: the whole branch `origin/main...a094d8e0a`, focus on the round-1 fixes `becfa87cb..a094d8e0a`.
Verdict: **0 BLOCKER · 0 MAJOR · 2 MINOR · 4 NIT — all three round-1 fixes SOUND against their findings** (F-1
traced through GRDB's throwing decode paths and the seed's reach into every decode; F-2 sentence by sentence;
F-3 for every current caller). No new MAJOR ⇒ **this is the FINAL ROUND**: its fixes get the orchestrator's
line-by-line check (no later round reads them). The reviewer's own runs: the pin suite 6/6 debug AND release,
the adjacent filter 61/7, on `a094d8e0a`.

## Findings (condensed faithfully; the full text is the round's hand-back in the orchestrator's session)

- **R2-M1 [MINOR] — F-1's guard covers only the READER gate; the CLASSIFIER gate is unguarded, and the era pin's
  drop list follows today's code though its doc says FROZEN.** Every export passes `LibraryClassifier.classify`
  twice before the reader; it calls a file an export only when none of TODAY's `SyncSchema.localOnlyTables` is
  present. A future change moving a table that 0.10 exports carry (the MCP grants family, the search-index
  family) into `localOnlyTables` reclassifies every 0.10 export as a plaintext LIBRARY → refused — F6's class
  again, and every pin stays green (the era pin never calls `classify` and drops today's set, so its file follows
  the new writer instead of 0.10's). Fidelity today verified against `0aab72c39` (0.10's set = today's five minus
  `sync_pull_stage`, which no v1_31 file has) — future-facing only. FIX: (1) freeze the era pin's drop as a
  literal of 0.10's five names; (2) `#expect(LibraryClassifier.classify(at:) == .plaintextExport(store:))` before
  the read (green today, reviewer-traced). A guard (the pin-3/F-1 class); teeth by an uncommitted filtered probe
  (one MCP table name added to `localOnlyTables` → the classify expect red) — the disjointness pins would go red
  under the same probe, which is why it filters. MINOR not MAJOR: the trigger is a deliberate reclassification
  that must already edit the disjointness pins.
- **R2-M2 [MINOR] — THE NEGOTIATED WALK's leg 9 omits the JOIN, so "Resume Sync → Synced" cannot happen as
  written, and leg 10's "files true with zero edits" depends on that join.** Leg 7's Make this my library "binds
  no account" (P-VX378-U2-4, `Copies.swift`; VX-522's account-less banner; the plan's own leg 2 says an
  account-less Resume runs no round). As written the walk STOPS at leg 9 inside a stage window; and changing
  P2→P1 on an UNJOINED library would not re-wrap the account (rule 7) — the files would be false at release.
  FIX (plan text): leg 9 = Resume (hold lifts, NO round; screenshot VX-522's banner) → "Sync this library…" JOIN
  by P2 via type-prod-test-secret (recording whether R-529-7's proof fields keep the words moment quiet) → the
  first round to "Synced", content both directions; leg 10 then runs on a JOINED library.
- **R2-N1 [NIT] — `forgetMigrations`' doc now claims more than the remaining expect checks** (an unknown
  identifier's DELETE takes nothing and set-equality still passes; no hollowness today — pins pass known,
  distinct identifiers). FIX: the subset+distinctness `#expect` on `identifiers`.
- **R2-N2 [NIT] — `PlaintextExportBringInRoadTests`' file header and test NAME still say the preflight refuses a
  newer export** (F-2 corrected the function doc; the test's own doc and assertion are right). FIX: amend the
  header line and rename the test (name/doc only).
- **R2-N3 [NIT] — record staleness** (LIVE STATUS row 2 "agree/dispute PENDING"; THE LEDGER rows 1–5 OPEN though
  unit A records them DONE; the round-1 file's "nothing below this line exists yet" sentence above the
  now-filled fixes section). FIX: flip at this round's record commit (the orchestrator's).
- **R2-N4 [NIT, SPECULATIVE impact] — walk leg 3 records nothing about the vxtest ACCOUNT's as-found posture and
  returns nothing** (if found Standard, leg 3 enters Castle account-wide and no leg leaves; later R-510 walks may
  assume the posture they last found). FIX (plan text): record the account's posture at leg 3; restore it at the
  end (if found Standard, follow the restored library back out via Use Standard before signing out) or note it
  (no values) in the prod-test env and on the RELEASE line.

## Clean bill (the reviewer's, headings)

The gate is her ratified rule exactly, and the classifier's newer predicate is the SAME rule (the two stages
agree). The rename/deletion clean across every target, VariorumMobile included; no stale canon line exists.
Pins 1–3 sound (pin 2 distinct and non-prefix; both pin-3 arms). The walk's Castle expectations match CastleRules
(rules 5, 6, 17 traced). The round's diff otherwise comment-only; no trailers; writes untouched; nothing scales
with corpus size. The flipped app pin hand-traced and expected green — STILL UNEXECUTED (the stage batch carries
it, the standing gating condition).

## THE FINAL CALLS (the orchestrator — same-model round, arbitrated against the spec; this is the final round,
so the orchestrator checks each landed fix line by line)

- **R2-M1 — CONFIRMED; FIX = the reviewer's (1)+(2), the implementer.** The frozen five-name literal models the
  0.10 writer (the era file's MCP tables exist empty by migration — no row strip needed); the classify expect
  rides the era pin. Teeth: the reviewer's filtered probe IF cheap (uncommitted, announced in the record first,
  restored clean), else the trace stands recorded.
- **R2-M2 — CONFIRMED; FIX = the reviewer's leg rewrite, the orchestrator** (plan text; lands with this round's
  record commit). The walk session's phase-1 proposal predates this — the approval message carries the amended
  legs.
- **R2-N1 — ACCEPTED; the subset+distinctness expect, the implementer.**
- **R2-N2 — ACCEPTED; header + rename, the implementer.**
- **R2-N3 — ACCEPTED; the orchestrator, this round's record commit.**
- **R2-N4 — ACCEPTED as plan text; the orchestrator** — leg 3 records the account's as-found posture; the end
  restores it (a found-Standard account is followed back out before sign-out) or notes it, and the RELEASE line
  carries it either way.

## ROUND 2 FIXES (open — filled as they land; the orchestrator's line-by-line check closes the ladder)

**The implementer's three (opus-implementer, unit A's session; headless; each call built as ruled — none stopped on):**

- `66c4e41eb` — the round-2 fixes table opened in unit A's LIVE STATUS.
- `f7335503a` — **R2-N1**: `forgetMigrations` opens with `#expect(Set(identifiers).isSubset(of:
  Set(AppDatabase.migrator.migrations)) && Set(identifiers).count == identifiers.count, "known, distinct identifiers")`;
  its doc says why (an unknown identifier's DELETE takes nothing yet leaves the set-equality true). **R2-N2**:
  `PlaintextExportBringInRoadTests`' header line now says a newer build's export is refused at the PICK
  (`PickedCopy.classify`, before any preflight); the test is renamed
  `thePreflightReadsAnEarlierBuildsExportThePickRefusesANewerOneNothingWritten` (name/doc only — the body untouched).
  The stage batch's quoted line names the SUITE (`-only-testing:VariorumTests/PlaintextExportBringInRoadTests`) —
  verified by grep, no change needed; unit A's A1 row now notes the rename beside the old name.
- `45b43fddf` — **R2-M1**: (1) `static let oldestExportEraDroppedTables = ["sync_outbox", "sync_state",
  "sync_row_seq", "_sync_applying", "protection_record"]` — 0.10's writer's set (`SyncSchema.localOnlyTables` at
  `0aab72c39`, read there) as a FROZEN literal, replacing the loop over today's `StorePlaintextExport.localOnlyTables`;
  strict `DROP TABLE` (each exists at v1_31); the MCP family's rows not stripped (empty by migration). (2)
  `#expect(LibraryClassifier.classify(at: url) == .plaintextExport(store: url), …)` before the read. The pin's doc
  names both gates and the FROZEN rule for the drop.
- `cb179b627` — the probe announced; **R2-M1's teeth, the reviewer's FILTERED probe, run in an ISOLATED scratch copy**
  (`git archive 45b43fddf` + its own `.build`, deleted after — unit B's walk session is live in this worktree, so no
  production file here was touched): `LibraryClassifier.readPlaintext`'s loop → `SyncSchema.localOnlyTables.union(
  ["mcp_client"])` (the classifier's use site, so no `Sync/` file was edited even uncommitted) → `✘ Test
  anExportOfTheOldestExportEraStillReadsWhole() … :378:9: Expectation failed: LibraryClassifier.classify(at: url) ==
  .plaintextExport(store: url)` (`→ .plaintextLibrary(store: …/export.sqlite)`), pins 1–3 and both standing tests ✔ —
  `✘ Test run with 6 tests in 1 suite failed … with 1 issue`.
- **Evidence on the final tree** (`cb179b627`; code = `45b43fddf`): `swift build` → `Build complete!` · the pin suite
  → `✔ Test run with 6 tests in 1 suite passed` · the adjacent filter → `✔ Test run with 61 tests in 7 suites passed` ·
  ONE `build-for-testing` re-run (`-derivedDataPath DerivedData/vx502-unitA`, the renamed App test) → `** TEST BUILD
  SUCCEEDED **`. The round's diff is test code + records only (App/: the one file, name/doc), so the unit close's
  whole-suite runs stand.
- **Observed, for the orchestrator:** unit B's walk session works in THIS worktree (untracked
  `Tools/WalkKit/castle-walk-lib.zsh` 03:45, then `notes/plans/fixes/vx-502-walk-script.md`). My commits are
  path-limited and touched neither. The R1-c probe's window (03:21:59–03:23:17 MDT) predates that session's first file,
  and no build of this worktree exists outside `DerivedData/vx502-unitA` (none in the default DerivedData), so no Debug
  build could have carried a probe.
- **PENDING (the orchestrator's, unchanged):** `PlaintextExportBringInRoadTests` + `U2WordsTests` under a stage claim.

## THE ORCHESTRATOR'S CHECK — the final round's fixes, line by line (2026-10-27 ~05:05 MDT; no round 3 reads them)

Read against each final call on the diff `c6a45250d..cb64aa9c7` (product/test files):
- **R2-M1 ✔** `oldestExportEraDroppedTables` is the FROZEN five-name literal, byte-matching 0.10's
  `SyncSchema.localOnlyTables` as the round-2 reviewer read it at `0aab72c39`; the loop over today's set is gone;
  the drop is strict `DROP TABLE` (fails loud if the era ever lacks one); the classify `#expect` runs BEFORE the
  read with an honest message; the pin's doc now covers BOTH gates and keeps the FROZEN discipline ("the READER
  or the CLASSIFIER owes the era a tolerance, not this pin an edit"). The teeth: the filtered probe announced
  first (`cb179b627`), run in an ISOLATED scratch copy (right call — the walk session is live in this worktree),
  red at the classify expect alone (`.plaintextLibrary`), every other pin green, the copy deleted.
- **R2-N1 ✔** the subset+distinctness `#expect` with the doc stating why (an unknown identifier's DELETE takes
  nothing yet leaves set-equality true).
- **R2-N2 ✔** the header clause and the rename say the PICK refuses a newer export; the test's body unchanged;
  the record's stage line names the SUITE, so nothing else moves.
- **The commit collision (the implementer's flag): CHECKED, intact** — the walk-rulings block rode `cb64aa9c7`
  (it was on disk uncommitted when the implementer's close staged the record file); it appears ONCE, text as the
  orchestrator wrote it, nothing lost; `88fb5ec1b` carried the rest. History not rewritten; attribution noise
  accepted and recorded here.

**THE LADDER IS CLOSED: round 2 was the final round (0 BLOCKER · 0 MAJOR); its fixes landed and are checked
above. The one standing gate is the stage batch (the two Mac suites — the flipped pin's FIRST execution — plus
the derived Protection-door suite set), which runs as the walk window's step 0 under VX-604's executed-count
rule.**
