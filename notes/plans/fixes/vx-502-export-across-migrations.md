# VX-502 — export across migrations + the Castle-restore walk

**STATUS: OPEN — kicked off 2026-10-27 ~02:00 MDT (overnight, /architect-phase, her kickoff brief below). Nothing
below the LIVE STATUS table is built yet; every claim of work is PENDING until its row says otherwise.** Branch
`vx-502-export-across-migrations`, worktree `~/dev/variorum-vx-502`, the Pro. Fable orchestrates (session vx-502);
Opus implements (a fresh `opus-implementer` per unit); the cold reviewer per the diff at ladder time (the diff
touches `App/Variorum/Shared/Protection/` faces, so the standing default is `fable-reviewer`). Commits say
`Part of VX-502`; NO trailers. Stage claims route through tonight's coordinator (session `oct26coordinator`).
The 13b constitution (P-1…P-9, `.claude/skills/architect-phase/SKILL.md`) binds BY REFERENCE — this is a
ticket-shaped effort on the VX fix-record shape (the vx-494/vx-510/vx-529 precedent), not a phase plan.

## The charter

**Her kickoff (2026-10-27, verbatim-faithful):** overnight protocol — run autonomously, provisional-and-continue,
bundle every question for her morning. This effort holds the CUSTODY-ADJACENT slot and the Castle-restore walk:
stage claims through tonight's coordinator session (`oct26coordinator`), the walk uses `~/.variorum/dev-castle.env`
exactly and restores the dev store's posture after, and the live Castle walk itself is handed to an OPUS session
(the orchestrator is Fable — the standing safeguard). The acceptance rule is ratified on the ticket. **No release,
no /Applications refresh without her word.**

**The ratified acceptance rule (her word, 2026-10-27, on VX-502):** *accept any export whose applied set is a
subset of the importing build's known set; newer-than-me still refuses.* P-VX309-U1b-7's exact-match PROVISIONAL
is SUPERSEDED by this ruling at the build (the vx-309 plan's row stays as history, unedited).

**Her rider (2026-10-26, the VX-502 comment, verbatim):** "we should make sure the actual restore castle from
backup is walked appropriately (maybe with a passphrase change since the backup was made, just for extra
reassurance)" — closing the recorded VX-510 gap (R-510-2's closeout: restore walked in Standard only; Castle
backups opened by Look inside but never restored). **The walk arm: restore a Castle backup made under an OLD pair
after the pair has changed, end to end through unlock and sync.** This walk + the code fix together are a release
gate (her 2026-10-26 rulings).

**Concurrency (the ticket's note):** VX-439 carries the export doors and both efforts touch the import/export
seam — whichever merges SECOND rebases and re-runs the export/import pins before its PR. Closeouts serialize
through the coordinator.

**The mechanism (VX-494's F6, confirmed):** `Operations+PlaintextExportImport.swift` —
`PlaintextExportReading.plan(_:)` guards `applied == known` over `grdb_migrations` identifiers vs
`AppDatabase.migrator.migrations`. Any migration landed after an export was written — LOCAL-ONLY ones included
(v1_32, whose table the export even DROPS) — makes the export refuse as `schemaNotCurrent(newer: false)`.
Reach today: every export written by 0.10 (9093) refuses on 9162+.

## The coordinator's protocol (oct26coordinator's grant, 02:05 MDT — binding on this run's stage traffic)

The custody-adjacent slot is GRANTED and held by this effort until the hard stop answers "nothing further owed".
If the diff grows into `Sync/` or keychain lines beyond this plan, the coordinator is told BEFORE the commit.
Stage traffic: REQUEST (what, minutes, claim name) sent early → a separate READY ping when able to start NOW →
GO only from the coordinator with the exact claim line (a free stage is never an invitation) → RELEASE plus one
result line. Headless `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` never need the stage;
EVERY `xcodebuild test` does. The Air runs nothing tonight. Instance checks use the STRICT forms `pgrep -lx
Variorum` and `pgrep -lf "MacOS/Variorum$"`. After every Debug launch, dismiss a What's New sheet if one shows.
The walk's REQUEST must state: (1) it uses exactly `~/.variorum/dev-castle.env`, never new values; (2) the dev
store's posture before and the restore it will run at the end — the posture left is reported at RELEASE; (3) if
it touches Debug prefs: `defaults export` before, re-export and DIFF at restore (`defaults import` merges —
walk-added keys get left behind); (4) if it runs an hour or more: tests first, then ping "SEAM" before the
dev-store copy so a merge-gating run can slot in.

## LIVE STATUS (flip per piece, same commit; unverified claims marked PENDING)

| # | Piece | Status |
|---|---|---|
| 0 | Kickoff: preflight whole; worktree + branch; in-flight row on main; VX-502 In Progress; coordinator announced, slot granted | DONE (this commit) |
| 1 | Unit A: the subset rule + pins (a fresh opus-implementer, headless) | BUILT AND CLOSED by the implementer (`74cfc1733`…`272fdda65`), orchestrator-verified (commits, gate diff, faces diff, tree clean) — "UNIT A — LIVE STATUS" at this record's end; PENDING: the two Mac suites under a stage claim (`PlaintextExportBringInRoadTests` — the flipped app pin has NEVER EXECUTED, compiled only — and `U2WordsTests`; the walk window's test batch). Implementer findings adopted: F-A1 (D-A2's premise corrected — VX-461, not vx-309's merge, is why no content-bearing export predates v1_31; the canon delta cites VX-461), F-A2 (a stable newer export refuses at the PICK via `PickedCopy.classify`; the gate's catch covers only the between-reads race), F-A3 (MCP load-flakes only) |
| 2 | The ladder on unit A's diff | ROUND 1 LANDED (`notes/plans/fixes/vx-502-ladder-round-1.md`, a fresh fable-reviewer: 0 BLOCKER · 1 MAJOR · 1 MINOR · 1 NIT + the already-scheduled gating condition; the architect's positions in the round file). The implementer's agree/dispute PENDING (the cross-model flow); fixes then a fresh round-2 reviewer |
| 3 | Unit B: the Castle-restore walk (an Opus session; stage via the coordinator; dev-castle.env; posture restored after) | SHAPE SETTLED with the coordinator (THE NEGOTIATED WALK below supersedes the kickoff legs); the walk session NOT YET SPAWNED — it builds the helper, runs --check, proposes the concrete plan back, then READY |
| 4 | Closeout: canon deltas (SurfaceContracts Doors line citing VX-461; AppSpecRecord entry; QUESTIONS #239(a) note), canon-size, tickets triaged, handoff, PR, merge serialized with VX-439 | NOT STARTED |

## UNIT A — the subset rule (the architect's design, ruled at kickoff)

**The one change (the gate):** `plan(_:)`'s guard becomes `applied.isSubset(of: known)`; the refusal becomes the
honest shape — under the ratified rule the ONLY refusal is "carries migration identifiers this build doesn't
know", i.e. a newer Variorum wrote it. **D-A1:** `Failure.schemaNotCurrent(newer: Bool)` is renamed to
`Failure.schemaNewer` (the `newer: false` arm is unreachable under the rule; a dead arm would mislead).
`ProtectionCopyDoors.readPlaintextExport` catches it with the EXISTING `LibraryOpenCopy.newerSchemaRefusal`
wording (unchanged — no new user-facing sentence, nothing for her wording pass);
`ProtectionWords.exportFromAnEarlierBuild` is deleted with its doc (a now-unreachable face). Check
`PlaintextExportDoorTests` / `CopyActTests` for pins on the deleted string before deleting.

**D-A2 — why subset is safe for the READ (verify, don't trust):** the reader's SQL (wing, container.wing_id,
reading kinds, reading_section, reading_post.status — already feature-detected at `hasStatus` — plus
`Queries.variorumDocumentText`'s tables) assumes the physical schema of the WRITER's build, and no export can be
older than the build that shipped `StorePlaintextExport` (vx-309, merged 2026-10-20). The implementer VERIFIES,
column by column, in source: every table/column the reader touches was in the migration set at vx-309's merge;
v1_31 (`protection_record`) and v1_32 (`sync_pull_stage`) are local-only and DROPPED by the export, never read.
**The standing duty, recorded at the gate as a comment:** any future migration that changes a table the export
reader touches must add a feature-detect (the `hasStatus` precedent) — an older export must keep reading. A
hand-made file whose physical schema predates the reader's needs throws a database error → the generic catch →
`.unreadableCopy` (an honest refusal; such a file was never a real export). If the verification FINDS a read
column newer than the export road's birth set, that is a design fork — STOP and bring it to the orchestrator.

**D-A3 — pins:**
1. **(red-on-old, the F6 scene)** an export whose `grdb_migrations` lacks the LAST migration identifier (today
   v1_32 — exactly the 9093 export's shape) READS WHOLE and imports; on the pre-fix code this throws
   `schemaNotCurrent(newer: false)` — RED. This FLIPS the first half of the existing
   `anExportOfAnotherBuildsSchemaRefuses`.
2. **(deeper subset)** several identifiers deleted → still reads whole (the rule is subset, not last-only).
3. **(the newer guard, kept)** `v9_99_from_the_future` inserted → refuses; teeth by behavioral revert (the gate
   deleted whole → this pin red — the future export would read).
Behavioral reverts, named in the unit's LIVE STATUS before any run: (RV-A1) the rule restored to exact-match →
pins 1 and 2 red; (RV-A2) the gate deleted whole → pin 3 red.

**D-A4 — docs:** the file-head comment, `ProtectionCopyDoors`'s and `ProtectionWords`'s doc pointers updated to
the ratified rule, cited as "VX-502 (her ratified rule, 2026-10-27; supersedes P-VX309-U1b-7)".

**Evidence at unit close (in the unit's LIVE STATUS):** the pins' red-on-old lines quoted; each revert's run
line; then on the final tree `swift test --filter PlaintextExportImportTests`, an adjacent filter
(`PlaintextExport|LibraryClassifier|VariorumDocument|CopyAct`), the whole core suite debug AND release (the known
MCP load-flake named if it appears, never fixed), and ONE `xcodebuild … build-for-testing` if any `App/` file
changes (the faces do). Headless only — no stage, no app launch, no store, no server.

## UNIT B — the Castle-restore walk (goal-stated; the walk session proposes the concrete plan BACK before acting)

**The goal (her words above):** a Castle backup made under an OLD pair, restored AFTER a passphrase change,
end to end through unlock and sync. On the DEV STORE (`io.lduarte.Variorum.debug`), the branch's Debug build,
under a HELD stage claim granted by `oct26coordinator` (the REQUEST/READY/GO protocol above), driven by an OPUS
session (never Fable). Secrets: source `~/.variorum/dev-castle.env` and type only through the `~/.variorum/bin`
helpers (R-510-1/-6); sync on the PROD TEST ROAD (`VARIORUM_PROD_TEST_ROAD=1`, the vxtest allowlist from
`~/.variorum/prod-test-accounts.env`, the `Tools/WalkKit/first-run-walk.sh` machinery,
`Tools/prod-confirm-test-user.sh`) — her real account can never pass; never invent secrets; if the passphrase
changes mid-walk, update dev-castle.env IN THE SAME WINDOW (keep the prior value as a comment until the restore)
and restore it with the posture at the end. Read before planning: `notes/CastleRules.md` whole,
`notes/plans/fixes/vx-510-first-run-sync.md`'s walk machinery sections, `notes/plans/vm-8-castle-catchup.md`'s
walk legs, the walk-driving-lessons and debug-app-account-fence memory notes, `Tools/WalkKit/`.

**The legs (acceptance evidence, each with a screenshot or log line):**
1. Arrange: dev store in Castle, synced with a vxtest account, pair = dev-castle.env's. (The pre-walk posture is
   RECORDED first — whatever it is — and is what leg 8 restores.)
2. A backup made through the app's own road (rule 5's pair lands beside the library); the pair noted.
3. The passphrase CHANGED (Settings ▸ Protection ▸ Change passphrase — both secrets typed; the account's lock
   re-wraps in the same act, rule 7). dev-castle.env updated in the same window.
4. The reassurance probes on the OLD backup (Look inside, nothing written): it opens with the OLD pair (rule 5's
   floor) AND with the NEW passphrase (rule 6 — same key, re-locked only). A failure of either is a FINDING
   against the Castle rules, not something to work around — stop and record.
5. The RESTORE through the app's own door (Restore from Backup / Make this my library), opened by the OLD pair:
   per rule 17 a new library, fresh identity and key, in the posture of now under the current pair, landing HELD.
6. Unlock end to end: lock, meet the Castle lobby, open with the current secrets.
7. Resume Sync pressed; the round runs to "Synced" against the vxtest account under its CURRENT (changed) pair;
   content verified both ways (the pre-walk note present; a new note pushed and confirmed server-side through the
   test-road tooling).
8. POSTURE RESTORED: the dev store ends as leg 1 recorded it — Castle under dev-castle.env's ORIGINAL pair (the
   passphrase changed back; env restored byte-identical), signed out / sync state as found, the vxtest account's
   pair left consistent with `~/.variorum/prod-test-accounts.env` (changed back in the same window as env edits),
   Previous Libraries asides noted here for the closeout tidy, Debug prefs diffed against the pre-window export
   (the coordinator's item 3), the stage claim RELEASED with the posture reported.

**The coordinator's addendum (02:12 MDT, carrying her word: "ensuring that no one gets locked out of the dev
store due to castle testing"):** (1) VERIFY, don't trust — the env file's last posture note is VX-306 U3
(2026-10-18): dev library `86a82b4f`, STANDARD (no Castle), under NEWROAD_WORDS + CASTLE_PASSPHRASE; later
efforts may have moved it without a note. The walk's FIRST leg confirms the actual posture opens with those
values before changing anything; if they don't open it, STOP and tell the coordinator — never mint new values.
So leg 1's "arrange" likely includes ENTERING Castle from Standard (Use Castle…, both secrets typed — more door
coverage, recorded as its own evidence line). (2) Any posture left different from found — even deliberately — is
noted in the env file's notes in the same window (values only in the file, never in a commit or record), and
RELEASE reports the posture left and that it opens. (3) The walk script of record is COMMITTED FIRST and the
machine state recorded per leg, so a stop mid-leg is followed by a verify-not-trust check.

**Constraints:** zero-instance discipline per the stage (the strict pgrep forms); never touch the real store or
her account; the walk's evidence folder is gitignored and DELETED at the effort's close (this record is the
evidence of record); `caffeinate` per the resiliency protocol; a leg that cannot complete after 2–3 attempts
STOPS and reports — no improvisation around a Castle door. Walk findings against CastleRules go to the morning
bundle, never to autonomous fixes (the Castle design is frozen — her word 2026-10-24).

## THE NEGOTIATED WALK (settled with oct26coordinator, 2026-10-27 ~02:20–03:25 MDT — SUPERSEDES the kickoff
legs above; the kickoff section stays as history. The walk session builds to THIS.)

**The as-found library is preserved untouched.** The coordinator's correction: the active dev library is NOT
`86a82b4f` — the records say VX-309's walk (2026-10-20) left **`e11e5233`** (key 77f4a14d) active: Standard,
opening quietly, HELD (the Oct-20 restore banner standing, Resume never pressed), signed out; the dev pair
unchanged since. Efforts since may have moved it again; treat every id as UNVERIFIED until leg 1 reads it. A hold
is one Resume press from gone, so NO test leg (Castle, sync, key door, backup-under-test) ever runs on the
as-found library — its hold must survive byte-for-byte.

**The two credential sets never cross (the coordinator's lanes):** the DEV pair (dev-castle.env) touches ONLY the
as-found library — one live use, leg 1's non-mutating check door; the vxtest ACCOUNT's pair (prod-test files, the
R-510-8 helper) touches ONLY walk-owned libraries. The join is what makes this work: rule 7 — a join ADOPTS the
account's pair, so after it every typed secret on the walk library is the account's. dev-castle.env takes NO value
changes (no PASSPHRASE2 there); the account's passphrase change uses the prod-test env's EXISTING passphrase2
field. The interpretive note on her kickoff sentence is in the morning bundle.

**The helper (a provisional act, her bundle; the coordinator's conditions):** `~/.variorum/bin/type-dev-castle-secret`,
byte-patterned on type-prod-test-secret (R-510-8): fields `passphrase | words`; reads ONLY dev-castle.env at mode
600; itself mode 700; refuses unless the frontmost process is the Debug build BY EXACT PATH (can never type into
the real app); never a value in argv, stdout, a log, a capture or a transcript; a `--check` mode verifying every
guard and typing NOTHING (type-sim-secret's shape), run headless BEFORE READY. dev-castle.env gains a comment
line (no values) naming the helper and its fields, plus a no-values posture note: the library id leg 1 found and
the id the walk leaves.

**The legs:**
1. AS-FOUND RECORD: strict-pgrep instance check; launch the branch's Debug build; record the active library id,
   posture, hold state, sign-in state; verify the env pair opens it via "Check my passphrase or twelve words…"
   (writes nothing; the helper types). STOP to the coordinator if the pair doesn't open it or it isn't Standard.
   `defaults export` of the Debug domain BEFORE anything (the prefs baseline).
2. THE WALK LIBRARY: a copy source made or picked (the walk session proposes — a Back Up Now pair beside the
   as-found is acceptable, reported; an existing fresh backup preferred), then Make this my library → a NEW
   library (rule 17: fresh identity, posture of now, CURRENT pair — rule 7 means no fresh words are ever minted);
   the as-found steps aside WHOLE into the walk's own dated Previous Libraries entry (reported). Resume the walk
   library's hold (account-less — no round).
3. THE JOIN: sign into the NAMED vxtest account (in the READY ping) and join by the ACCOUNT's secret
   (type-prod-test-secret); the walk library adopts the account's pair. If the account is not in Castle, ENTER
   Castle (both account secrets; the VX-469 line screenshotted).
4. THE CASTLE BACKUP under pair P1 (the account's current pair); the pair noted by place, never value.
5. THE PAIR CHANGE: Change passphrase → the prod-test env's passphrase2 (P2); the account's lock re-wraps in the
   same act (rule 7); prod-test files stay TRUE throughout (passphrase2 is a recorded field).
6. THE PROBES on the old backup (Look inside, nothing written): opens with P1 (rule 5's floor) AND with P2
   (rule 6 — same key, re-locked only). Either failing is a FINDING against CastleRules — STOP and record; the
   Castle design is frozen (her word 2026-10-24), so findings go to the bundle, never to autonomous fixes.
7. THE RESTORE: Make this my library on the P1-era Castle backup, opened by the OLD pair; fresh identity, posture
   of now, current pair, lands HELD; the walk library steps aside (walk-owned, cleaned at the end).
8. UNLOCK END TO END: lock (⌃⌘L), meet the Castle lobby, open with the current secrets.
9. SYNC END TO END: Resume Sync; the round runs to "Synced" against the account under its CURRENT (P2) pair;
   content verified both directions (the pre-change note present; a new note pushed and confirmed through the
   test-road tooling).
10. THE PAIR RESTORED: Change passphrase BACK (P2 → the env's passphrase) on the restored library, so
    `~/.variorum/prod-test-accounts.env` and `prod-test-words-<account>` are TRUE at release with ZERO edits (the
    coordinator checks this at RELEASE). If a failed leg strands P2, the files are updated to truth in the same
    window (values never printed) and RELEASE says so. Then sign OUT (the resting posture; rule 16 — no key
    change).
11. THE HAND-RETURN (the coordinator's conditions, verbatim): the app quit and ZERO instances proven with the
    strict pgrep forms before any move; whatever occupies the live slot set aside WHOLE and reported, never
    overwritten or merged into; the stepped-aside as-found set returned whole by a SAME-VOLUME move, no partial
    copies; then ONE relaunch proves the as-found id active, Standard, unlocked (the quiet road), signed out,
    the hold banner standing. If it isn't: STOP, KEEP THE CLAIM, tell the coordinator, NO repairs.
12. CLEANUP, each target READ before removal: the walk-owned libraries' sets, their Previous Libraries entries,
    their `Backups/<id>` folders and key droppings — keeping only what this record needs as evidence, reported.
    `86a82b4f`, the 10-08 and 10-18 Previous Libraries entries and the as-found set stay UNTOUCHED. Debug prefs
    re-exported and DIFFED against leg 1's baseline (`defaults import` merges — walk-added keys get left behind).
13. RELEASE to the coordinator, one line: the active library id, its posture, opens unlocked, signed out
    confirmed, the prefs diff clean, no instances, and the prod-test-account state left (files true, or updated
    and said).

**Stage traffic:** the claim is `vx-502-walk`, already REQUESTED; the window's order is (a) the Mac test batch —
`-only-testing:VariorumTests/PlaintextExportBringInRoadTests` + `U2WordsTests` + the closeout's changed-source
suites — (b) the SEAM ping, (c) the legs. READY goes to the coordinator only after the walk session's concrete
plan is approved by the orchestrator AND the helper's --check has run headless. GO comes only from the
coordinator with the exact claim line.

## Environment traps (carried into every brief, verbatim)

Instance checks use the coordinator's strict forms `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`;
real-store instances are treated by STORE, never quit/killed; NO Release builds or /Applications refreshes (her
word tonight: none without her say). `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/` with suite-level `-only-testing`; confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration (non-"Debug" names strip the DEBUG oracles). Headless `swift
build`/`swift test` never needs the stage. Backups WAL-safe, UTC names, into `Backups/safety-copies/`. Never
`git checkout` over uncommitted work; push after every commit; foreground waits only (poll a log past the Bash
timeout, never end a turn waiting); no subagents inside implementer or reviewer sessions beyond the one read-only
Sonnet for external facts.

## THE MORNING BUNDLE (questions held for her; grows as the run finds them)

1. **The walk's credential lanes — an interpretive note, not a blocker (the walk is PLANNED this way; say if you
   want it otherwise):** your kickoff said "the walk uses ~/.variorum/dev-castle.env exactly". The planned
   reading: the dev library's own secrets come from that file exactly (and only its check-door leg needs them);
   the CASTLE TEST LEGS run on walk-owned libraries under a vxtest ACCOUNT's pair through your R-510 helper
   machinery (the join adopts the account's pair — rule 7), because the active dev library is HELD (VX-309's
   banner, Resume never pressed) and any Castle/sync act on it would destroy that hold. The dev store's own pair
   is never changed and nothing new is invented. Flagged because your sentence could be read as "the Castle legs
   themselves type dev-castle values". *(Flip this line to as-run at the walk's close.)*
2. **A provisional act, PENDING the walk session: `~/.variorum/bin/type-dev-castle-secret` is to be minted** (the
   walk needs a typing road for the dev library's secrets and none exists — your R-510-8 helper covers only
   prod-test accounts; the coordinator confirmed the gap and ruled the conditions). Byte-patterned on
   type-prod-test-secret: mode 700, reads only dev-castle.env at 600,
   frontmost-must-be-the-Debug-build-by-exact-path, never prints a value, a --check mode that types nothing; a
   no-values comment line added to dev-castle.env naming it. Yours to keep or delete (the walk-machinery-kept
   precedent suggests keep). *(Flip this line when the helper exists and --check has run.)*

## THE LEDGER (numbered rows; every row owned)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | The gate flipped to the ratified subset rule (D-A1) | unit A | OPEN |
| 2 | The read-tolerance verification + the standing feature-detect duty recorded (D-A2) | unit A | OPEN |
| 3 | Pins 1–3 + the behavioral reverts (D-A3) | unit A | OPEN |
| 4 | The faces: dead string deleted, docs updated (D-A1/D-A4) | unit A | OPEN |
| 5 | The ladder round(s) + dispositions | orchestrator | OPEN |
| 6 | The walk, legs 1–8 | unit B | OPEN |
| 7 | Canon deltas + QUESTIONS #239(a) note + AppSpecRecord entry | closeout | OPEN |
| 8 | Tickets triaged; handoff; PR; merge serialized vs VX-439 | closeout | OPEN |

## UNIT A — LIVE STATUS (the implementer owns this section)

**NOT DONE HERE (by the brief — headless):** the two Mac suites this unit touches — `PlaintextExportBringInRoadTests` (the flipped preflight pin) and `U2WordsTests` (the deleted line's two mentions) — are COMPILED (A4's build-for-testing, final tree) but NOT RUN: stage-gated, PENDING the orchestrator (`xcodebuild test -scheme Variorum -destination 'platform=macOS' -only-testing:VariorumTests/PlaintextExportBringInRoadTests -only-testing:VariorumTests/U2WordsTests`). No walk or use capture (headless unit; the use evidence is unit B's and the orchestrator's); no canon delta (the closeout's); no ticket filed.

**UNIT A — CLOSED by the implementer, 2026-10-27** (every row below DONE with its evidence; the Mac run above and the ladder are the orchestrator's).

*opus-implementer, 2026-10-27, HEADLESS (no stage, no app launch, no `xcodebuild test`, no store, no server). Every
claim not marked DONE with its evidence is PENDING. A fresh session with only the repo finishes the unit from this
table.*

**REVERT STATE: no revert in flight.** RV-A1 and RV-A2 ran and were each restored from `e56920846` (`git checkout --` the gate file; `git diff --exit-code` clean after each).

| # | Piece | Status |
|---|---|---|
| A0 | Preflight (canon, this record whole, SurfaceContracts' Doors, the resiliency protocol, the code) + the D-A2 verification below + this section | DONE (`74cfc1733`) |
| A1 | The pins, committed RED-on-old before the fix: core pins 1–3 in `PlaintextExportImportTests` (the old two-arm `anExportOfAnotherBuildsSchemaRefuses` split — its earlier-build arm FLIPPED into pin 1, its newer arm kept as pin 3, plus a lag-beside-the-future arm); the app-side pin on the dead face FLIPPED the same way (`PlaintextExportBringInRoadTests.thePreflightReadsAnEarlierBuildsExportRefusesANewerOneAndWritesNothing`: the earlier build's export now PLANS whole; a newer build's is refused AT THE DOOR — `PickedCopy.classify` → `.refused(LibraryOpenCopy.newerSchemaRefusal, detail: "v9_99_from_the_future")`; nothing written) | DONE (`996478bd8`; the app pin's newer arm CORRECTED in the close commit — see finding F-A2: as first committed it asked `readPlaintextExport` for the newer refusal, which that function never gives; caught by tracing at self-review, never run). **RED ON THE PRE-FIX TREE** (`swift test --skip-build --filter PlaintextExportImportTests`, the tree `74cfc1733` + these pins): `✘ Test anExportMissingThisBuildsLastMigrationReadsWholeAndImports() recorded an issue at PlaintextExportImportTests.swift:225:6: Caught error: .schemaNotCurrent(newer: false)` · `✘ Test anExportMissingSeveralMigrationsStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:241:6: Caught error: .schemaNotCurrent(newer: false)` · `✔ Test anExportOfANewerBuildsSchemaRefuses() passed` (green-on-old by design — its teeth are RV-A2) · `✘ Test run with 5 tests in 1 suite failed … with 2 issues`. The app pin is red-on-old BY CONSTRUCTION (the pre-fix gate refuses the earlier export) — NOT RUN (stage-gated; PENDING the orchestrator's Mac run) |
| A2 | The fix: the gate → `applied.isSubset(of: known)`; `Failure.schemaNotCurrent(newer:)` → `Failure.schemaNewer` (D-A1); `readPlaintextExport` catches it with the existing `LibraryOpenCopy.newerSchemaRefusal`; `ProtectionWords.exportFromAnEarlierBuild` deleted with its doc and its two `U2WordsTests` mentions (pins found by grep: `U2WordsTests` ×2, `PlaintextExportBringInRoadTests` ×1 — none in `PlaintextExportDoorTests` or `CopyActTests`); D-A4's doc pointers; the standing feature-detect duty as a comment above the gate | DONE (`e56920846`). After the fix, `swift test --skip-build --filter PlaintextExportImportTests`: `✔ Test run with 5 tests in 1 suite passed` (pins 1–3 and the two standing tests). The Mac files (`ProtectionCopyDoors`, `ProtectionWords`, `U2WordsTests`, the flipped app pin) are COMPILED at A4 only — PENDING there |
| A3 | The behavioral reverts, named here before any run: **RV-A1** — the gate restored to exact-match (`applied == known`) → pins 1 and 2 RED; **RV-A2** — the gate deleted whole → pin 3 RED. Each from the committed fix, restored by `git checkout --`, `git diff --exit-code` clean | DONE (`a7434545a`), on `e56920846`, the gate file only, `swift build --build-tests` then `swift test --skip-build --filter PlaintextExportImportTests`. **RV-A1** (`guard applied == known else { throw Failure.schemaNewer }`): `✘ Test anExportMissingSeveralMigrationsStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:241:6: Caught error: .schemaNewer` · `✘ Test anExportMissingThisBuildsLastMigrationReadsWholeAndImports() recorded an issue at PlaintextExportImportTests.swift:225:6: Caught error: .schemaNewer` · pin 3 ✔ · `✘ Test run with 5 tests in 1 suite failed … with 2 issues` — RESTORED, diff clean. **RV-A2** (the `guard applied.isSubset(of: known)` line deleted whole): `✘ Test anExportOfANewerBuildsSchemaRefuses() recorded an issue at PlaintextExportImportTests.swift:262:9: Expectation failed: an error was expected but none was thrown` · the same at `:274:9` (the lag-beside-the-future arm) · pins 1–2 ✔ · `✘ Test run with 5 tests in 1 suite failed … with 2 issues` — RESTORED, diff clean |
| A4 | Evidence on the final tree: `swift test --filter PlaintextExportImportTests`; the adjacent filter `PlaintextExport\|LibraryClassifier\|VariorumDocument\|CopyAct`; the whole core suite debug AND release; ONE `xcodebuild … build-for-testing` (`-derivedDataPath App/Variorum/DerivedData/vx502-unitA`) | DONE. The core evidence on the code of `e56920846` (the close commit changes only a test doc comment in core and the app pin, re-run below): `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 5 tests in 1 suite passed` · the adjacent filter `PlaintextExport|LibraryClassifier|VariorumDocument|CopyAct` → `✔ Test run with 60 tests in 7 suites passed` (Variorum document format · VX-305 U3 Send Library/the plaintext export · pre-13x 3b the export strips the local tables · 13n-b U1 grants schema · VX-306 U1a the protection record's table · VX-309 U1b T-8 · 13x U1 the classifier) · **whole core suite DEBUG** (`swift test`): VariorumCoreTests `━ Test run with 3437 tests in 457 suites passed after 292.522 seconds with 5 known issues`; VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — `aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (MCPHarnessTimeLimitTests.swift:90, 19.2 s vs its 15 s bound) = the RECORDED VX-353 wall-clock load-flake, green ALONE (`✔ Test run with 3 tests in 1 suite passed`), not touched; the third target `✔ 32 tests in 4 suites passed` · **whole core suite RELEASE** (`swift test -c release`): VariorumCoreTests `━ Test run with 3408 tests in 452 suites passed after 221.054 seconds with 5 known issues`; VariorumMCPTests `✘ 383 tests … with 2 issues` — the same VX-353 flake (17.9 s) and `MCPSetupKeyServerTests.twoToolsUnderOneNameAreToldApart` (:108), the load-flake sighting already recorded red under full `-c release` load and green alone (vx-329 ladder round-1 fixes; vx-184; vx-246) — both GREEN ALONE in release (`✔ Test run with 13 tests in 2 suites passed`), not touched; the third target `✔ 32 tests in 4 suites passed`. ON THE FINAL TREE (the close commit): `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 5 tests in 1 suite passed`; the adjacent filter → `✔ Test run with 60 tests in 7 suites passed`; `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx502-unitA build-for-testing` (from `App/Variorum/`) → `** TEST BUILD SUCCEEDED **`, zero errors, no warning in a touched file (a first build-for-testing on `6ca575b88` also succeeded; the app pin's correction re-ran it on the final tree). The whole-suite runs were not repeated for the close commit's doc-comment-only core change |

### D-A2 — the read-tolerance verification (in source, column by column)

**The record's premise, checked — and corrected.** D-A2 says no export can be older than "the build that shipped
`StorePlaintextExport` (vx-309, merged 2026-10-20)". **That attribution is wrong:** the WRITER (`StorePlaintextExport`
+ Data Safety's door, not Debug-gated) was born at pre-13x 3b, `1fce30cb8` (2026-09-06, migrations `v1_core`…`v1_16`);
vx-309 (`1e9f4abb2`) shipped the READER (T-8's bring-in). **The conclusion holds anyway, for a different reason —
VX-461** (`3470c6905`; its commit traces it: a sandboxed save panel grants the picked path alone, the export's first
write opened `<picked>-journal` beside it outside the grant, so the copy failed "unable to open database file" and left
the picked file at 0 BYTES — proven under `sandbox-exec`, the vx-309 walk's W-VX309-4 line byte for byte). The Mac
target is sandboxed in BOTH configurations since Phase 7 (`5d9c2ccf8`: `ENABLE_APP_SANDBOX = YES`, user-selected
read-write only — no Downloads/Desktop entitlement); both writers (`DataSafetyPane`, the new road's
`SQLCipherLibraryLeaf`) go through `StorePlaintextExport.export` → `write`. So **the first build that could write a
content-bearing export is the VX-329 merge `0aab72c39` (2026-10-22, carrying VX-461; migrations `v1_core`…`v1_31`)** —
release 0.10 (9093), exactly F6's scene. A pre-fix door's 0-byte file classifies `.notAVariorumStore` (the
classifier's empty-file arm) and never reaches the reader. (Theoretical residue, never a real export: a file written
where the sandbox already held a folder grant — the chosen backups folder, which the door itself refuses — or by an
unsandboxed headless tool. Such a file older than `v1_21` throws a SQL error — "no such table: wing" below `v1_18`,
"no such column: archived_at" below `v1_21`, both before any record decode of a missing column — into the generic
catch → `.unreadableCopy`.)

**Every table and column the reader touches, with the migration that made it** — `PlaintextExportReading.plan` and
everything it calls: `Queries.variorumDocumentText` → `variorumDocument` → `Container.fetchOne` (Codable — every
`Container` property), `blockPresentations`, `postTags` (`Tag` Codable), `exportBlocks` → `renderPost` (+ `blockFan`,
`Variant` Codable); `DisplayTitle` is pure:

| Table · columns read | Born |
|---|---|
| `grdb_migrations.identifier` | GRDB's own |
| `container`: id, owner_id, kind, title, profile, entry_date, locked, locked_at, floating_notes, segmentation_default, last_touched_at, last_major_revision_at, churn_accumulator, baseline_length, created_at, updated_at, archived_at, deleted_at, sync_version | `v1_core` |
| `container.word_target` (Container decode; optional) | `v1_12` |
| `container.wing_id` (the notes query + Container decode, non-optional) | `v1_18` |
| `block`: id, default_variant_id, deleted_at · `variant`: every `Variant` property (id, block_id, parent_variant_id, working_text, status, locked, label, fan_position, created/updated/deleted_at, sync_version) · `container_block`: id, block_id, container_id, position, chosen_variant_id, deleted_at | `v1_core` |
| `block_comment`: block_id, deleted_at (renderPost's comment count) | `v1_8` |
| `block.presentation` | `v1_9` |
| `tag`: id, owner_id, parent_id, name, path, created/updated/deleted_at, sync_version · `post_tag`: tag_id, post_id, deleted_at | `v1_core` |
| `tag.wing_id` (Tag decode, non-optional) | `v1_18` |
| `reading`: id, name, kind, deleted_at (kind `'book'`, or the pre-`v1_18` spelling `'curated'` — both read) | `v1_core` (the table rebuilt at `v1_18`) |
| `reading.wing_id` | `v1_18` |
| `reading.archived_at` | `v1_21` — **the newest column the reader touches** |
| `reading_section`: id, reading_id, name, position, deleted_at · `reading_post.section_id` | `v1_10` |
| `reading_post`: id, reading_id, post_id, position, deleted_at | `v1_core` |
| `reading_post.status` | `v1_18` — feature-detected (`hasStatus`) |
| `wing`: id, name, position, deleted_at | `v1_18` |

Never read: `v1_31`'s `protection_record` and `v1_32`'s `sync_pull_stage` (each migration is ONE `CREATE TABLE` of a
local-only table — `ProtectionRecordSchema.ddl`, `SyncPullStageSchema.ddl` — both in `SyncSchema.localOnlyTables`,
both DROPPED by the export); `v1_25`'s `ai_private_at` (no `Container` property; the reading query names its
columns); the MCP family (`v1_24`–`v1_30`; travels empty). **Verdict: every read column was in the migration set at
vx-309's merge (`007a9f2b1`, through `v1_31`) AND at the first content-bearing export's build (`0aab72c39`, through
`v1_31`). `v1_31` and `v1_32` change no table the reader touches, so every real export's physical schema is today's
minus the local-only tables, and the reader reads them all. NO FORK.** The standing duty (any future migration that
alters a table this list names adds a feature-detect, the `hasStatus` precedent) lands at the gate as a comment (A2).

### Findings for the orchestrator (none is a fork; none built past the brief)

- **F-A1 — D-A2's stated premise was wrong; its conclusion stands** (recorded in the verification above): the export
  WRITER shipped at pre-13x 3b (2026-09-06), not vx-309; VX-461's sandbox-journal bug (fixed `3470c6905`, in the VX-329
  merge `0aab72c39` → 0.10) is what makes 0.10 the first build that could write a content-bearing export. If the
  closeout's canon line or the AppSpecRecord entry restates the record's reason, it should cite VX-461, not vx-309.
- **F-A2 — the newer-export refusal is the pick's, not the preflight's (unchanged by this unit):**
  `LibraryClassifier.classify` answers `.newerSchema` for a plaintext store carrying an unknown identifier BEFORE it
  tells export from library, so `PickedCopy.classify` refuses a newer export with `LibraryOpenCopy.newerSchemaRefusal`
  (the unknown ids as its detail) and the bring-in's preflight is never reached; called directly,
  `readPlaintextExport` answers `.unreadableCopy` for such a file. Its `schemaNewer` → `newerSchemaRefusal` catch (D-A1)
  is therefore reachable only when the file changes between the classifier's staged read and the plan's — kept as ruled
  (defensive, the honest words). The same was true of the pre-fix `newer: true` arm. The core gate's newer refusal is
  pinned directly (`PlaintextExportReading.read`, pin 3).
- **F-A3 — the MCP target's reds in both whole-suite runs are the recorded load-flake class only** (VX-353's
  `aPeerThatNeverAnswersInitialize…` wall-clock bound; the `twoToolsUnderOneNameAreToldApart` sighting under full
  `-c release` load), each green alone; not touched.
