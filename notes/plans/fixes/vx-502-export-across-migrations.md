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

**Her overnight word (2026-10-27, ~03:35 MDT, in-session, verbatim): "make sure that the castle backup restore is
solid & if it needs to be tested with a passphrase change in between to verify that the old one still works AND
the new one works, that's authorized. I want it fully tested"** — the pair-change arm is explicitly AUTHORIZED
and REQUIRED: the walk proves BOTH roads on the old Castle backup — the old passphrase still opens it (rule 5's
floor) AND the new one opens it (rule 6) — plus the restore end to end. The negotiated legs 6–9 carry exactly
this; a failure of either road is a stop-and-record finding, never worked around. (She also confirmed the export
refusal bug is one she has met herself, several times.)

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
| 2 | The ladder on unit A's diff | ROUND 1 CLOSED (`vx-502-ladder-round-1.md`: 0·1·1·1; all three agreed and fixed `0e14d7bf8`…`a094d8e0a`, the era pin frozen at v1_31). ROUND 2 LANDED (`vx-502-ladder-round-2.md`, a fresh opus-reviewer: 0 BLOCKER · 0 MAJOR · 2 MINOR · 4 NIT; all r1 fixes SOUND) — THE FINAL ROUND (no new MAJOR). **CLOSED**: R2-M2/N3/N4 the orchestrator (`c6a45250d`), R2-M1/N1/N2 the implementer (`f7335503a`, `45b43fddf`, probe `cb179b627`→`cb64aa9c7`), the orchestrator's line-by-line check in the round-2 file (`844fc4a91`). The one standing gate: the stage batch (the walk window's step 0) |
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
3. THE JOIN: RECORD the account's as-found posture first — Standard or Castle — by place, never value (R2-N4:
   it is restored or reported at the end). Sign into the NAMED vxtest account (in the READY ping) and join by the
   ACCOUNT's secret (type-prod-test-secret); the walk library adopts the account's pair. If the account is not in
   Castle, ENTER Castle (both account secrets; the VX-469 line screenshotted).
4. THE CASTLE BACKUP under pair P1 (the account's current pair); the pair noted by place, never value.
5. THE PAIR CHANGE: Change passphrase → the prod-test env's passphrase2 (P2); the account's lock re-wraps in the
   same act (rule 7); prod-test files stay TRUE throughout (passphrase2 is a recorded field).
6. THE PROBES on the old backup (Look inside, nothing written): opens with P1 (rule 5's floor) AND with P2
   (rule 6 — same key, re-locked only). Either failing is a FINDING against CastleRules — STOP and record; the
   Castle design is frozen (her word 2026-10-24), so findings go to the bundle, never to autonomous fixes.
7. THE RESTORE: Make this my library on the P1-era Castle backup, opened by the OLD pair; fresh identity, posture
   of now, current pair, lands HELD; the walk library steps aside (walk-owned, cleaned at the end).
8. UNLOCK END TO END: lock (⌃⌘L), meet the Castle lobby, open with the current secrets.
9. SYNC END TO END (rewritten per R2-M2 — the restored library BINDS NO ACCOUNT, P-VX378-U2-4): Resume Sync lifts
   the hold with NO round (screenshot VX-522's account-less banner — its own evidence line); then "Sync this
   library…" — the JOIN — by P2 through type-prod-test-secret (recording whether R-529-7's proof fields keep the
   words moment quiet); then the first round runs to "Synced" against the account under its CURRENT (P2) pair;
   content verified both directions (the pre-change note present; a new note pushed and confirmed through the
   test-road tooling).
10. THE PAIR RESTORED, on the now-JOINED library (R2-M2): Change passphrase BACK (P2 → the env's passphrase), so
    `~/.variorum/prod-test-accounts.env` and `prod-test-words-<account>` are TRUE at release with ZERO edits (the
    coordinator checks this at RELEASE). If a failed leg strands P2, the files are updated to truth in the same
    window (values never printed) and RELEASE says so. Then the ACCOUNT's posture restored (R2-N4): if leg 3
    found it STANDARD, follow the restored library back out (Use Standard — both secrets; rule 12's leave walked
    as its own evidence line); if found CASTLE, leave it in Castle. Then sign OUT (the resting posture; rule 16 —
    no key change).
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

**THE WALK RULINGS (phase 1 → 2, the orchestrator, 2026-10-27 ~04:45 MDT; the walk session's phase-1 proposal is
the input — its drafts sit gitignored under `App/Variorum/DerivedData/vx502-walk-drafts/` until 2a commits them):**
1. **Leg 2 = variant B′** (the proposal's finding is CONFIRMED: `ProtectionCopyDoors.makeMine` overwrites the
   slot's hold marker before anything moves, so the negotiated make-mine leg could never return the hold; B′ also
   avoids a second, WRITING use of the dev pair and never pushes the as-found library's content into the
   account). At zero instances the NINE top-level slot files move whole, inode-proven, into a same-volume aside;
   the empty no-lived-here slot assesses as start-fresh; the walk library is a FRESH library (its minted words
   never looked at — it joins the account at leg 3 and adopts the account's pair, rule 7). Rule 17's make-mine
   coverage is NOT lost: leg 7 (the restore under test) exercises it fully. Leg 11 moves the nine back; the
   INODE check binds the SEVEN persistent files (WAL/SHM move with the set but rebuild at relaunch — presence
   and store consistency are their check, not inode identity).
2. **The W0 safe copy: YES** — the nine as-found files copied into the dev container's `Backups/safety-copies/`
   (UTC name) before anything, her lockout concern made mechanical.
3. **The prefs baseline is E0, before step 0** (the test host IS the dev-store app).
4. **type-prod-test-secret is NOT patched tonight** (her R-510-8 tool; an untested change to credential tooling
   right before its live use is worse than the brief same-user ps exposure it has always had). The observation
   goes to the morning bundle (item 3) with the stdin-form offer — hers.
5. **Observation 8a: INCLUDED** (P1 refused at the restored library's lobby — rule 17's "carries no keys" made
   visible; if P1 OPENS it, that is a finding).
6. **Voice captures: SKIPPED** (no changed face on the walk's path; a flip writes synced setting rows).
7. **Step 0's suite set is DERIVED, not guessed:** grep `App/Variorum/VariorumTests` for the changed types
   (`ProtectionCopyDoors`, `ProtectionWords`, `PlaintextExportReading`) and run every matching suite as its own
   `-only-testing`; name the set in the READY. Build-for-testing at 2a (no stage), `test-without-building` inside
   the window, ABSOLUTE derived-data path. **VX-604 (the coordinator's heads-up): a lone-suite run can
   false-green as "0 tests in 1 suite passed" through a test-host launch crash — every RESULT line states the
   EXECUTED test count per run; 0 executed = NO VERDICT, rerun or stop.**
8. **The helper's lane guard STAYS** (a prod-test-road launch refuses dev-pair typing — the coordinator's lanes
   enforced mechanically). The words-field mapping is CONFIRMED (`VARIORUM_DEV_NEWROAD_WORDS` is the dev
   library's words — the env's own VX-306 U3 note; `VARIORUM_DEV_CASTLE_WORDS` is the pre-design store's and is
   never typed).
9. **No permission config changes for the window** (author-only; a type-mode call that prompts or stalls is a
   STOP-and-report, the window yielded, bundled for morning — never worked around).
10. **Serialization:** 2a's COMMIT (the walk script + lib moving to their real paths) waits for the ladder's
   close (the r2 fixes + the orchestrator's line-by-line check) — one writer on the branch at a time; pull first.
   The account branches (castle found in Castle / at passphrase2 / Standard / unopenable / stale words stash) run
   as scripted, the last two as STOPs. The WalkKit `wl2` helper and the wl2-gated guard stay as built.
11. **For the coordinator at READY:** the as-found set returns byte-whole INCLUDING VX-548's client row and
   VX-439's "Walk Book" residue — VX-439's part 2 is unaffected but must not run inside this window.

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
   precedent suggests keep). *(FLIPPED: the helper EXISTS — built in phase 1, --check green twice on the real
   file, headless, nothing typed; its guards include the lane check (a prod-test-road launch refuses dev-pair
   typing), the frontmost-Debug-by-exact-path check re-verified at type time, and stdin delivery so the value
   never enters argv or any environment.)*
3. **A security observation on your existing helper, no action taken (walk ruling 4):**
   `type-prod-test-secret` (R-510-8) passes the secret in osascript's ARGV — briefly visible to same-user `ps`.
   The new dev helper uses the stdin form instead. Patching yours to match is ~6 lines, same checks — but it is
   your ratified tool and the walk depended on it tonight, so nothing was changed. Want it patched?

## THE LEDGER (numbered rows; every row owned)

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | The gate flipped to the ratified subset rule (D-A1) | unit A | DONE (`e56920846`; unit A's table) |
| 2 | The read-tolerance verification + the standing feature-detect duty recorded (D-A2) | unit A | DONE (`74cfc1733` + the gate comment; premise corrected per F-A1 — VX-461) |
| 3 | Pins 1–3 + the behavioral reverts (D-A3) | unit A | DONE (`996478bd8`, reverts `a7434545a`; + the era pin `074c73023`) |
| 4 | The faces: dead string deleted, docs updated (D-A1/D-A4) | unit A | DONE (`e56920846`, F-2's doc `0e14d7bf8`) |
| 5 | The ladder round(s) + dispositions | orchestrator | DONE — r1 + r2 both CLOSED, every finding dispositioned; the stage batch rides unit B's window |
| 6 | The walk, legs 1–8 | unit B | OPEN |
| 7 | Canon deltas + QUESTIONS #239(a) note + AppSpecRecord entry | closeout | OPEN |
| 8 | Tickets triaged; handoff; PR; merge serialized vs VX-439 | closeout | OPEN |

## UNIT A — LIVE STATUS (the implementer owns this section)

**NOT DONE HERE (by the brief — headless):** the two Mac suites this unit touches — `PlaintextExportBringInRoadTests` (the flipped preflight pin) and `U2WordsTests` (the deleted line's two mentions) — are COMPILED (A4's build-for-testing, final tree) but NOT RUN: stage-gated, PENDING the orchestrator (`xcodebuild test -scheme Variorum -destination 'platform=macOS' -only-testing:VariorumTests/PlaintextExportBringInRoadTests -only-testing:VariorumTests/U2WordsTests`). No walk or use capture (headless unit; the use evidence is unit B's and the orchestrator's); no canon delta (the closeout's); no ticket filed.

**UNIT A — CLOSED by the implementer, 2026-10-27** (every row below DONE with its evidence; the Mac run above and the ladder are the orchestrator's).

*opus-implementer, 2026-10-27, HEADLESS (no stage, no app launch, no `xcodebuild test`, no store, no server). Every
claim not marked DONE with its evidence is PENDING. A fresh session with only the repo finishes the unit from this
table.*

**REVERT STATE: no revert in flight.** RV-A1 and RV-A2 ran and were each restored from `e56920846`; the R1-c probe ran and was restored from `074c73023` (its window, 03:21:59–03:23:17 MDT, predates unit B's walk session's first file in this worktree, and no build of this worktree exists outside `DerivedData/vx502-unitA`); the R2-c probe ran ONLY in an isolated scratch copy of `45b43fddf` (deleted after) — this worktree was never modified by it.

| # | Piece | Status |
|---|---|---|
| A0 | Preflight (canon, this record whole, SurfaceContracts' Doors, the resiliency protocol, the code) + the D-A2 verification below + this section | DONE (`74cfc1733`) |
| A1 | The pins, committed RED-on-old before the fix: core pins 1–3 in `PlaintextExportImportTests` (the old two-arm `anExportOfAnotherBuildsSchemaRefuses` split — its earlier-build arm FLIPPED into pin 1, its newer arm kept as pin 3, plus a lag-beside-the-future arm); the app-side pin on the dead face FLIPPED the same way (`PlaintextExportBringInRoadTests.thePreflightReadsAnEarlierBuildsExportRefusesANewerOneAndWritesNothing` — RENAMED at round 2 (R2-N2) `thePreflightReadsAnEarlierBuildsExportThePickRefusesANewerOneNothingWritten`: the earlier build's export now PLANS whole; a newer build's is refused AT THE DOOR — `PickedCopy.classify` → `.refused(LibraryOpenCopy.newerSchemaRefusal, detail: "v9_99_from_the_future")`; nothing written) | DONE (`996478bd8`; the app pin's newer arm CORRECTED in the close commit — see finding F-A2: as first committed it asked `readPlaintextExport` for the newer refusal, which that function never gives; caught by tracing at self-review, never run). **RED ON THE PRE-FIX TREE** (`swift test --skip-build --filter PlaintextExportImportTests`, the tree `74cfc1733` + these pins): `✘ Test anExportMissingThisBuildsLastMigrationReadsWholeAndImports() recorded an issue at PlaintextExportImportTests.swift:225:6: Caught error: .schemaNotCurrent(newer: false)` · `✘ Test anExportMissingSeveralMigrationsStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:241:6: Caught error: .schemaNotCurrent(newer: false)` · `✔ Test anExportOfANewerBuildsSchemaRefuses() passed` (green-on-old by design — its teeth are RV-A2) · `✘ Test run with 5 tests in 1 suite failed … with 2 issues`. The app pin is red-on-old BY CONSTRUCTION (the pre-fix gate refuses the earlier export) — NOT RUN (stage-gated; PENDING the orchestrator's Mac run) |
| A2 | The fix: the gate → `applied.isSubset(of: known)`; `Failure.schemaNotCurrent(newer:)` → `Failure.schemaNewer` (D-A1); `readPlaintextExport` catches it with the existing `LibraryOpenCopy.newerSchemaRefusal`; `ProtectionWords.exportFromAnEarlierBuild` deleted with its doc and its two `U2WordsTests` mentions (pins found by grep: `U2WordsTests` ×2, `PlaintextExportBringInRoadTests` ×1 — none in `PlaintextExportDoorTests` or `CopyActTests`); D-A4's doc pointers; the standing feature-detect duty as a comment above the gate | DONE (`e56920846`). After the fix, `swift test --skip-build --filter PlaintextExportImportTests`: `✔ Test run with 5 tests in 1 suite passed` (pins 1–3 and the two standing tests). The Mac files (`ProtectionCopyDoors`, `ProtectionWords`, `U2WordsTests`, the flipped app pin) are COMPILED at A4 only — PENDING there |
| A3 | The behavioral reverts, named here before any run: **RV-A1** — the gate restored to exact-match (`applied == known`) → pins 1 and 2 RED; **RV-A2** — the gate deleted whole → pin 3 RED. Each from the committed fix, restored by `git checkout --`, `git diff --exit-code` clean | DONE (`a7434545a`), on `e56920846`, the gate file only, `swift build --build-tests` then `swift test --skip-build --filter PlaintextExportImportTests`. **RV-A1** (`guard applied == known else { throw Failure.schemaNewer }`): `✘ Test anExportMissingSeveralMigrationsStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:241:6: Caught error: .schemaNewer` · `✘ Test anExportMissingThisBuildsLastMigrationReadsWholeAndImports() recorded an issue at PlaintextExportImportTests.swift:225:6: Caught error: .schemaNewer` · pin 3 ✔ · `✘ Test run with 5 tests in 1 suite failed … with 2 issues` — RESTORED, diff clean. **RV-A2** (the `guard applied.isSubset(of: known)` line deleted whole): `✘ Test anExportOfANewerBuildsSchemaRefuses() recorded an issue at PlaintextExportImportTests.swift:262:9: Expectation failed: an error was expected but none was thrown` · the same at `:274:9` (the lag-beside-the-future arm) · pins 1–2 ✔ · `✘ Test run with 5 tests in 1 suite failed … with 2 issues` — RESTORED, diff clean |
| A4 | Evidence on the final tree: `swift test --filter PlaintextExportImportTests`; the adjacent filter `PlaintextExport\|LibraryClassifier\|VariorumDocument\|CopyAct`; the whole core suite debug AND release; ONE `xcodebuild … build-for-testing` (`-derivedDataPath App/Variorum/DerivedData/vx502-unitA`) | DONE. The core evidence on the code of `e56920846` (the close commit changes only a test doc comment in core and the app pin, re-run below): `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 5 tests in 1 suite passed` · the adjacent filter `PlaintextExport|LibraryClassifier|VariorumDocument|CopyAct` → `✔ Test run with 60 tests in 7 suites passed` (Variorum document format · VX-305 U3 Send Library/the plaintext export · pre-13x 3b the export strips the local tables · 13n-b U1 grants schema · VX-306 U1a the protection record's table · VX-309 U1b T-8 · 13x U1 the classifier) · **whole core suite DEBUG** (`swift test`): VariorumCoreTests `━ Test run with 3437 tests in 457 suites passed after 292.522 seconds with 5 known issues`; VariorumMCPTests `✘ 383 tests in 71 suites … with 1 issue` — `aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (MCPHarnessTimeLimitTests.swift:90, 19.2 s vs its 15 s bound) = the RECORDED VX-353 wall-clock load-flake, green ALONE (`✔ Test run with 3 tests in 1 suite passed`), not touched; the third target `✔ 32 tests in 4 suites passed` · **whole core suite RELEASE** (`swift test -c release`): VariorumCoreTests `━ Test run with 3408 tests in 452 suites passed after 221.054 seconds with 5 known issues`; VariorumMCPTests `✘ 383 tests … with 2 issues` — the same VX-353 flake (17.9 s) and `MCPSetupKeyServerTests.twoToolsUnderOneNameAreToldApart` (:108), the load-flake sighting already recorded red under full `-c release` load and green alone (vx-329 ladder round-1 fixes; vx-184; vx-246) — both GREEN ALONE in release (`✔ Test run with 13 tests in 2 suites passed`), not touched; the third target `✔ 32 tests in 4 suites passed`. ON THE FINAL TREE (the close commit): `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 5 tests in 1 suite passed`; the adjacent filter → `✔ Test run with 60 tests in 7 suites passed`; `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx502-unitA build-for-testing` (from `App/Variorum/`) → `** TEST BUILD SUCCEEDED **`, zero errors, no warning in a touched file (a first build-for-testing on `6ca575b88` also succeeded; the app pin's correction re-ran it on the final tree). The whole-suite runs were not repeated for the close commit's doc-comment-only core change |

### ROUND 1 FIXES (the ladder's round 1 — `notes/plans/fixes/vx-502-ladder-round-1.md`; F-1 MAJOR, F-2 MINOR, F-3 NIT, all AGREED)

| # | Piece | Status |
|---|---|---|
| R1-0 | Positions recorded (all three agreed, reasons in the round file) | DONE (`91429974f`) |
| R1-a | F-2 — `readPlaintextExport`'s doc says the newer arm truthfully; F-3 — the redundant count `#expect` deleted | DONE (`0e14d7bf8`; doc-only + one deleted line; `swift build --build-tests` green; the suite runs at R1-d) |
| R1-b | F-1 — the ERA-FROZEN PIN (`anExportOfTheOldestExportEraStillReadsWhole`: a file migrated `upTo: "v1_31_protection_record"`, seeded by raw SQL in that era's columns, the writer's local-only drop applied, must plan whole and import) + the pointer comment at the head of `Migrations.swift` and at the gate | DONE (`074c73023`): `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test anExportOfTheOldestExportEraStillReadsWhole() passed` · `✔ Test run with 6 tests in 1 suite passed`. The `Migrations.swift` pointer is COMMENT-ONLY (three lines above `v1_1`) |
| R1-c | F-1's teeth — a SCRATCH PROBE, never committed: a temporary `v1_33_probe` migration (`ALTER TABLE container ADD COLUMN probe …`) + the reader's notes query naming `probe`; expected: pins 1–2 GREEN (blind, the reviewer's point), the era pin RED. Announced in the REVERT STATE line before it runs; restored by `git checkout --` | DONE (announced `4f4a98cce`, run, restored — NEVER committed): the probe (`v1_33_probe`: `ALTER TABLE container ADD COLUMN probe TEXT NOT NULL DEFAULT ''`; the notes query `… archived_at, probe FROM container`) → `✘ Test anExportOfTheOldestExportEraStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:294:6: Caught error: SQLite error 1: no such column: probe` while `✔ anExportMissingThisBuildsLastMigrationReadsWholeAndImports()` · `✔ anExportMissingSeveralMigrationsStillReadsWhole()` · `✔ anExportOfANewerBuildsSchemaRefuses()` · both standing tests ✔ — `✘ Test run with 6 tests in 1 suite failed … with 1 issue`: exactly the reviewer's traced degradation, which pins 1–2 miss and the era pin catches. Restored by `git checkout --` both files, `git diff --exit-code` clean |
| R1-d | Evidence on the final tree: `swift build`; `swift test --filter PlaintextExportImportTests`; the adjacent filter | DONE on `4f4a98cce` (code = `074c73023`; the close commit adds only records): `swift build` → `Build complete!` · `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 6 tests in 1 suite passed` (the era pin green ⇒ the probe is out of the built tree) · the adjacent filter → `✔ Test run with 61 tests in 7 suites passed`. The round's diff beyond the pin, the doc clause and the deleted expect is COMMENT-ONLY (the `Migrations.swift` pointer, the gate comment's pointer), so the unit close's whole-suite runs stand; `ProtectionCopyDoors`' change is a doc comment, so no build-for-testing was re-run. PENDING (unchanged, the orchestrator's): the two Mac suites under a stage claim |

### ROUND 2 FIXES (the FINAL round — `notes/plans/fixes/vx-502-ladder-round-2.md`; the orchestrator's final calls: R2-M1, R2-N1, R2-N2 the implementer's)

| # | Piece | Status |
|---|---|---|
| R2-a | R2-N1 — `forgetMigrations` expects its `identifiers` KNOWN and DISTINCT (subset + distinctness); R2-N2 — `PlaintextExportBringInRoadTests`' header line and the test's NAME say the PICK refuses a newer export (name/doc only) | DONE (`f7335503a`; `swift build --build-tests` green — the suites run at R2-d). The stage batch's quoted line names the SUITE (`-only-testing:VariorumTests/PlaintextExportBringInRoadTests`), verified by grep — it needs no change |
| R2-b | R2-M1 — the era pin's drop list FROZEN as the literal of 0.10's five local-only names (`0aab72c39`'s `SyncSchema.localOnlyTables`: sync_outbox, sync_state, sync_row_seq, _sync_applying, protection_record — the 0.10 writer modeled; its MCP tables exist empty by migration, no strip needed) + `#expect(LibraryClassifier.classify(at:) == .plaintextExport(store:))` before the read | DONE (`45b43fddf`): `oldestExportEraDroppedTables` (the five names, `DROP TABLE` strict — each exists at v1_31) replaces the loop over today's set; the classify `#expect` sits before the read; the pin's doc names both gates. `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test anExportOfTheOldestExportEraStillReadsWhole() passed` · `✔ Test run with 6 tests in 1 suite passed` |
| R2-c | R2-M1's teeth — a FILTERED SCRATCH PROBE, never committed, announced in the REVERT STATE line first: one MCP table name joins the local-only set AS THE CLASSIFIER SEES IT (`LibraryClassifier.readPlaintext`'s loop over `SyncSchema.localOnlyTables` → `.union(["mcp_client"])` — the use site in `Persistence/`, so the probe never edits a `Sync/` file); expected: the era pin's classify expect RED, pins 1–3 GREEN; the run filtered to `PlaintextExportImportTests` | DONE (announced `cb179b627`; run in an ISOLATED scratch copy — `git archive 45b43fddf …`, its own `.build` — because unit B's walk session is live in this worktree; never committed, the copy deleted): `LibraryClassifier.readPlaintext`'s `for table in SyncSchema.localOnlyTables {` → `.union(["mcp_client"]) {`, then `swift test --skip-build --filter PlaintextExportImportTests` → `✘ Test anExportOfTheOldestExportEraStillReadsWhole() recorded an issue at PlaintextExportImportTests.swift:378:9: Expectation failed: LibraryClassifier.classify(at: url) == .plaintextExport(store: url)` (`→ .plaintextLibrary(store: …/export.sqlite)`) while pins 1–3 and both standing tests ✔ — `✘ Test run with 6 tests in 1 suite failed … with 1 issue`: the reclassification R2-M1 traced, invisible to every other pin, caught by the era pin. The probe edited the classifier's USE SITE (`Persistence/`), never `Sync/SyncSchema.swift` |
| R2-d | Evidence on the final tree: `swift build`; the pin suite; the adjacent filter; ONE `build-for-testing` re-run (an `App/` test file renamed) | DONE on `cb179b627` (code = `45b43fddf`): `swift build` → `Build complete!` · `swift test --skip-build --filter PlaintextExportImportTests` → `✔ Test run with 6 tests in 1 suite passed` · the adjacent filter → `✔ Test run with 61 tests in 7 suites passed` · `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx502-unitA build-for-testing` (from `App/Variorum/`) → `** TEST BUILD SUCCEEDED **`, zero errors, no warning in the renamed file. App/ changes this round: the one test file, NAME and DOC only. The round's diff is test code + records only (no production line), so the unit close's whole-suite runs stand. PENDING (the orchestrator's, unchanged): the two Mac suites under a stage claim — the quoted `-only-testing` names the SUITE, so the rename needs no change there |

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

## UNIT B — LIVE STATUS (the walk session owns this section; the script of record is `notes/plans/fixes/vx-502-walk-script.md`)

**NOT DONE YET (first, as the contract asks):** no stage act, no Debug launch, no `xcodebuild test`, no dev-store or
real-store touch, no account act. The ONE server read allowed before the window (W0's precheck) is PENDING in 2a's
hand-back. Every leg below is PENDING until its row carries its machine-state line (`wk_state`, committed per leg).

*Walk session — Opus subagent of the vx-502 orchestrator. Worktree `~/dev/variorum-vx-502`. Claim `vx-502-walk` (GO only
from the coordinator, relayed). Secrets by field name only.*

| # | Piece | Status |
|---|---|---|
| B0 | Phase 1: preflight read whole; `~/.variorum/bin/type-dev-castle-secret` minted (mode 700; fields `passphrase` → `VARIORUM_DEV_CASTLE_PASSPHRASE`, `words` → `VARIORUM_DEV_NEWROAD_WORDS`; lane guard; stdin road); 12 fixture guard cases + escaping round-trip; `--check` on the real file exit 0 for both fields (frontmost guard deferred to type time); `dev-castle.env` +6 comment lines, value-lines fingerprint unchanged | DONE (outside the repo; the proposal's hand-back) |
| B1 | THE WALK RULINGS 1–11 (`88fb5ec1b`) applied: B′ leg 2; the seven-persistent-file inode rule at leg 11; the W0 safe copy; E0 before step 0; 8a in; the derived step-0 suite set; VX-604's executed-count rule; the script + the lib (`Tools/WalkKit/castle-walk-lib.zsh`) COMMITTED FIRST | DONE (this commit) |
*[removed for publication]*
| B3 | READY (relayed by the orchestrator) → GO → W0 (E0, account line) → step 0 (the derived 109-suite set, executed count stated) → SEAM. The coordinator's added condition (her no-lockouts word, superseding ruling 2's timing): the SAFETY COPY moves to AFTER the SEAM and BEFORE leg 1's first dev-store act — the as-found slot's own files into `…/Variorum-dev/Backups/safety-copies/variorum-vx502-walk-<UTC stamp>`, cmp-verified file by file; the net under the hand-return, used only if it fails and only after the coordinator is told | IN-PROGRESS — GO 04:05 MDT; claimed `vx-502-walk` 04:06:14 (150 min, the coordinator's exact line); W0 DONE; **STEP 0 GREEN** (below); SEAM handed back 04:2x; the safety copy + leg 1 next on the resume |

**THE WINDOW'S STATE LINES (committed per leg; verify-not-trust after any stop):**
- `STATE W0 2026-10-27T10:06:32Z` | instances 0 | slot (name@inode): `variorum-keys-1787a29ea0d545b9.json@191598614` `variorum-keys-3f3a561c436e6d3a.stale-1792486410.json@191598615` `variorum-keys-881730135471ec9f.stale-1792344917.json@191598616` `variorum-library-keys.json@191598617` `variorum-library-lived-here@191598618` `variorum-restore-hold.json@191598619` `variorum.sqlite-shm@197685944` `variorum.sqlite-wal@197685943` `variorum.sqlite@191598620` | slot library `e11e5233` key `77f4a14d` | HELD (marker inode 191598619, digest `9e26054518c7`) | Previous Libraries `2026-10-08-035453` `2026-10-18-173517` `2026-10-20-085330` | file fingerprints: dev-castle.env `9136808d9bffba71` · prod-test-accounts.env `0806985523f5a8b8` · prod-test-words-castle `ae9701dc2ac1ff53` | castle: mode **castle**, revision **23** (updated 2026-10-25 05:00:00Z), cursors 17, live containers 5 (newest 2026-10-24T12:12:48Z) | E0 taken (prefs-E0.plist, slot-E0.txt, places-E0.txt in the gitignored evidence folder) | caffeinate pid 86391 | grants AX/SCREEN/System Events held; author check idle 1003 s.
- **STEP 0 (04:07:13–04:18 MDT):** `xcodebuild test-without-building -scheme Variorum -destination platform=macOS -derivedDataPath …/DerivedData/vx502-close` + the 109 derived `-only-testing:VariorumTests/<Type>` flags (one each, read by `xargs` from `step0-flags.txt`) → **`✔ Test run with 594 tests in 109 suites passed after 175.942 seconds.`** · `** TEST EXECUTE SUCCEEDED **` · **EXECUTED 594** (594 `✔ Test` lines, 109 `✔ Suite` lines; 0 `skipped`, 0 `✘`, 0 known issues — VX-604's rule met: a real verdict) · the two named suites passed: "VX-309 U1b — T-8: a plaintext export brought in…" (`PlaintextExportBringInRoadTests`; its flipped pin `thePreflightReadsAnEarlierBuildsExportThePickRefusesANewerOneNothingWritten()` ✔ — **its first execution**) and "VX-309 U2 — the words unit's lines, as drafted" (`U2WordsTests`) · zero instances after.
- `STATE S0 2026-10-27T10:19:06Z` | instances 0 | the slot after the batch (the test host opened the store): `variorum.sqlite@191598620` (content changed), `-wal@197858323`, `-shm@197858324` rebuilt; **the six non-store files BYTE-IDENTICAL to E0** (the hold marker inode 191598619 digest `9e26054518c7`, the key file, lived-here, the three older-named key files) | `e11e5233` key `77f4a14d`, HELD | no backup file written since E0 (container `Backups/` and the picked folder) | prefs E0→E1: 2248 keys, 0 added, 0 removed, 3 changed (`IdleCommitSweepMark.Variorum`, `IdleCommitSweepMark.Variorum-dev`, `variorum.backup.log` — the batch's own bookkeeping; E0 stays THE baseline) | file fingerprints unchanged | stage ~138 min left.
- **THE SAFETY COPY (the coordinator's added condition; 04:20:19 MDT, zero instances proven first):** the as-found slot's own nine files — `variorum.sqlite` + `-wal` + `-shm`, `variorum-keys-1787a29ea0d545b9.json`, the two `variorum-keys-*.stale-*.json`, `variorum-library-keys.json`, `variorum-restore-hold.json`, `variorum-library-lived-here` — `cp -p` into **`…/Variorum-dev/Backups/safety-copies/variorum-vx502-walk-2026-10-27T102019Z`**, **`cmp` OK on all nine, file by file** (9 copied, 9 in the folder). The net under the hand-return — used only if it fails, and only after the coordinator is told.
- **LEG 1 — AS-FOUND RECORD (04:20:25–04:22:52 MDT; the DEV lane) — DONE.** Plain launch pid 91521 (zero `VARIORUM_*` keys); no What's New sheet; no rule-21 notice. Log: `road: opened — library e11e5233 key 77f4a14d device e5276ad5; custody silent 24 touchid 0; … live key file roads [apple,passphrase,words]; notice false; … acts 0`. The main window: the Bookcase (VX-439's "Walk Book", 1 note, unshelved; the Open list's "2026-10-27"), the words card (never pressed), "Sync off (dev store)", **the hold banner "This is your library as of October 20, 2026. This library doesn't sync, so Resume changes nothing in it."** (Resume never pressed). Settings ▸ Protection: **"You're in Standard."** · Sync: **"This library doesn't sync." · "Sign in to turn on sync." · Sign in…** (signed out). **The check door (read-only):** the dev passphrase (`type-dev-castle-secret passphrase`) → **"That passphrase opens this library."** (log `road: a secret check (read-only, nothing written) — the library: opens; the account: none (the library doesn't sync)`); the dev words (`… words`) → **"Those twelve words open this library."** (the same log line). The key file before/after: mtime 1792486744, 1076 bytes, digest `595b4cc06577` — IDENTICAL. Closed; quit accepted; zero instances (its own step). `dev-castle.env`'s FOUND note filled (comment only; value-lines fingerprint `95af56b5e7ee7a2c` unchanged, mode 600).
- `STATE L1 2026-10-27T10:23:02Z` | instances 0 | the seven persistent files on their W0 inodes; WAL/SHM rebuilt by the open (`-wal@197884700`, `-shm@197884701`) | `e11e5233` key `77f4a14d` HELD (marker 191598619 `9e26054518c7`) | Previous Libraries unchanged | prod-test-accounts.env `0806985523f5a8b8` · words-castle `ae9701dc2ac1ff53` unchanged; dev-castle.env's whole-file digest moves only with its comment lines | stage ~134 min left.
- **LEG 2 — B′ (04:23:34–04:23:58 MDT) — DONE.** Zero instances proven (its own step) → **the as-found set aside WHOLE** into `…/Application Support/Variorum-dev-aside-vx502-asfound/` (same volume): 9 files, inodes identical, **the seven persistent files on their W0 inodes** (191598614–191598620), WAL/SHM as of leg 1 (`-wal@197884700`, `-shm@197884701`); the slot left holding only `Backups/` and `Previous Libraries/`. Road launch pid 93840: `VARIORUM_PROD_TEST_ROAD=1` + the handed allowlist, no walk project (`ps eww`), **"PROD TEST ROAD (VX-510): ARMED"**. The empty slot assessed START-FRESH: `road: created — library deaea068 key e404dedb device 38b46920` · `the first open goes straight on (the words wait for her look)` · its creation backup `Backups/deaea068/38b46920/…-102343-e404dedb` + the picked-folder twin (walk-owned — leg 12). **L1 = `deaea068`**, empty, "Signed out", the words card + the passphrase card (never pressed).
*[removed for publication]*
- `STATE L3 2026-10-27T10:28:39Z` | 1 instance (pid 93840, the walk build, road-armed) | slot: L1 `deaea068` key `e568e108` (Castle) | castle: mode **castle**, revision **23** (unmoved — a join writes no vault row), cursors **18** (+1, L1), live containers **6** (+1, note A; newest 2026-10-27T10:28:10Z) | prod-test-accounts.env `0806985523f5a8b8` · words-castle `ae9701dc2ac1ff53` unchanged; dev-castle.env `b5a18156e91c4954` (its FOUND comment only). (The lib's state line now counts unique pids — one process matched by both strict forms read "2" at L2.)
- **LEG 4 — THE CASTLE BACKUP under P1 (04:29:21–04:29:51 MDT) — DONE.** Settings ▸ Data Safety (before: "Newest: Oct 27, 2026 at 4:25 AM · 2 copies" — L1's creation pair under `e404dedb` and the join-time pair `…-102556-e568e108`) ▸ Back Up Now… → `backup pair: written under e568e108 in Backups/deaea068/38b46920` (04:29:46) · `the picked folder holds this Mac's fresh pair of this library — none copied there`. **THE P1-ERA BACKUP:** `…/Variorum-dev/Backups/deaea068/38b46920/variorum-backup-2026-10-27-102946-e568e108.sqlite` (inode 197898065, 581632 bytes, digest `d1268c6509d1` — it holds note A) + `….keys.json` (inode 197898071, 822 bytes, digest `25833f274ac4`). **The pair by place:** P1 = `prod-test-accounts.env`'s `VARIORUM_PRODTEST_CASTLE_PASSPHRASE` (helper field `passphrase`) + `prod-test-words-castle` (field `words`).
- **LEG 5 — THE PAIR CHANGE P1 → P2 (04:30:18–04:32:07 MDT) — DONE.** Protection ▸ Change passphrase… (its synced line: "This library syncs with your account, so your account's passphrase changes with it, on every device.") → Current ← `passphrase` (P1), New + Again ← `passphrase2` (P2) → Change passphrase → `change_passphrase: begun #2 e568e108 → none · done #2 under e568e108` · **`road: changePassphrase — the current key re-locked (e568e108), the account's lock with it`**. **Rule 6 seen:** the key fingerprint UNCHANGED (`e568e108` before and after; the key file's mtime moved — re-locked only). **Rule 7 seen:** the vault revision **23 → 24** (updated 2026-10-27 10:31:12Z), mode castle — the account's lock re-wrapped in the same act. The prod-test files unchanged (`passphrase2` is a recorded field). **Note B** ("VX-502 walk note B - written after the backup and the pair change, under P2") → pushed.
- `STATE L5 2026-10-27T10:32:07Z` | 1 instance (93840) | L1 `deaea068` key `e568e108` | castle: mode castle, revision **24**, cursors 18, live containers **7** (newest 10:31:49Z — note B) | prod-test-accounts.env `0806985523f5a8b8` · words-castle `ae9701dc2ac1ff53` unchanged.
- **LEG 6 — THE PROBES on the P1-era backup (04:32:43–04:36:34 MDT) — DONE, every road as CastleRules says.** Data Safety ▸ Restore from Backup: this library's rows first — **"Oct 27, 2026 at 4:29 AM"** (the P1-era pair) leading, then 4:25, 4:23 — with Look inside… + Make this my library… and NO Delete (rule 19); "Other libraries on this Mac" below (Delete… there, never pressed). Look inside… on the 4:29 row → **"This copy doesn't open by itself on this Mac. Enter its passphrase or twelve words."** (Castle + Always ask: no quiet road — rule 5's quiet clause honestly absent).
  - **Negative control** (a junk literal, nobody's secret) → **"That doesn't open this copy. Enter the copy's own passphrase or twelve words."**
  - **P1 (`passphrase`) — rule 5's FLOOR → OPENS:** `road: a look inside a copy (backup, road itsOwnSecrets) — read-only, nothing written`. The facts sheet: "This is a copy from October 27. Nothing you do here changes it or your library." · No books · **6 notes — one dated 2026-10-27 + the account's five of 2026-10-24**; the 2026-10-27 row's page reads **"VX-502 walk note A…"**; **note B ABSENT** (the backup predates it). (Titles read "Untitled" — the known VX-520/W-9 class.)
  - **P2 (`passphrase2`) — rule 6 (same key, re-locked only) → OPENS:** `road: a look inside a copy (backup, road currentSecretsThroughTheHistory) — read-only, nothing written`; the facts sheet open.
  - **The words (unchanged — old and current alike) → OPEN:** `road itsOwnSecrets — read-only, nothing written`.
  - **NOTHING WRITTEN:** L1's key file (mtime 1793097072, digest `51cd6d94ff1b`), the six backup files in `Backups/deaea068/38b46920`, the P1-era pair's inodes/sizes/digests, and the vault (revision 24) — all identical before and after.
- `STATE L6 2026-10-27T10:36:34Z` | 1 instance | L1 `deaea068` key `e568e108` | castle: castle, revision 24, cursors 18, containers 7 | files unchanged.
- **LEG 7 — THE RESTORE (04:37:07–04:38:27 MDT) — DONE.** Data Safety ▸ the 4:29 row ▸ Make this my library… (the first such button verified ON that row by its AX frame) → the confirm: **"This copy becomes a new library — in Castle, under your current twelve words and passphrase — with a fresh key of its own. Your current library steps aside whole into Previous Libraries… The copy itself is not changed. You never leave Castle by opening something. The new library doesn't sync with your account until you turn on sync for it in Settings ▸ Protection."** → "The copy's passphrase or twelve words" ← **`passphrase` (P1 — the OLD pair opens the copy)**; "Your twelve words" ← `words`; "Your passphrase" ← **`passphrase2` (P2 — the current pair)** → Make this my library → `make_mine: begun #3 e568e108 → 7e8d8a27` · **`make_mine: the new library's key file written (7e8d8a27) — with the join's two proof fields (VX-523: the pair proven the account's)`** · `swapped — this Mac's library is the copy, a new library under 7e8d8a27` · `done #3` · **`road: made a copy this Mac's library — library 598d1a34 key 7e8d8a27; the previous one in Previous Libraries; held`** · `road: opened — library 598d1a34 key 7e8d8a27 device 7dc6684a`. **Rule 17 seen:** L2 = **`598d1a34`** (≠ L1 `deaea068` — a fresh identity), key **`7e8d8a27`** (≠ `e568e108` — a fresh key), **"You're in Castle."** (the posture of now), **HELD** (a new marker, inode 197902388), the banner **"This is your library as of October 27, 2026. This library doesn't sync, so Resume changes nothing in it."** (VX-522 — the restored library binds no account; the row "Not synced yet"; Protection's Sync: "This library doesn't sync." + "Sync this library…"); L1 stepped aside into **`Previous Libraries/2026-10-27-103750/`** (`variorum-library-keys.json` + `variorum.sqlite`, its key file naming `deaea068` key `e568e108`) — walk-owned, leg 12's. The vault unmoved (revision 24 — a restore writes no vault row).
- `STATE L7 2026-10-27T10:38:27Z` | 1 instance | slot: L2 `598d1a34` key `7e8d8a27`, HELD | Previous Libraries + `2026-10-27-103750` | castle: castle, revision 24, cursors 18, containers 7 | files unchanged.
- **LEG 8 — UNLOCK END TO END (04:38:50–04:41:05 MDT) — DONE.** ⌃⌘L → `road: locked — the library closed behind the lobby (VX-445)` → the Castle lobby: **"Open your library — Enter your passphrase or your twelve words to open your library." · "Touch ID isn't set up for this library."** (Always ask) · Passphrase · Open · "Use your twelve words instead".
  - **8a (ruling 5 — rule 17's "carries no keys" made visible): P1 (`passphrase`) → REFUSED, as the rules say:** **"That passphrase doesn't open this library."**; log `road: the vault road proves nothing for this passphrase — today's refusal` (P1 is no longer the account's current passphrase, so R-529-1's vault road does not apply; the restored library is locked under the current pair only).
  - **P2 (`passphrase2`, the current passphrase) → OPENS:** `road: opened — library 598d1a34 key 7e8d8a27 device 7dc6684a`.
  - **8b — ⌃⌘L again → "Use your twelve words instead" (opened from its label — VX-527) → `words` → "Open with the words" → OPENS** (the third `road: opened — library 598d1a34` line). (A walk-tool slip on the way, recorded: the first press hit the passphrase row's own "Open" — the words row's button is "Open with the words"; nothing was refused, nothing typed twice.)
  - The hold marker unchanged across both locks (inode 197902388).
- `STATE L8 2026-10-27T10:41:05Z` | 1 instance | L2 `598d1a34` key `7e8d8a27`, HELD | castle unchanged (revision 24).
- **LEG 9 — SYNC END TO END (R2-M2's order; 04:41:31–04:43:45 MDT) — DONE.**
  - **Resume first, NO round:** the banner **"This is your library as of October 27, 2026. This library doesn't sync, so Resume changes nothing in it."** (VX-522, account-less — captured as its own evidence line) → Resume Sync → the banner gone, the hold marker removed, NO round line in the log, the row **"Sync isn't on for this library yet · Protection…"**; the cards band empty (the words ledger carried — VX-444).
  *[removed for publication]*
  - **Content BOTH directions:** the Library lists **note B** ("VX-502 walk note B…", edited today 4:31 AM — written after the backup, so it came DOWN from the server) and **note A** ("…note A…", 4:28 — carried in the backup), beside the account's five VX-510 notes: **7 notes = the server's 7 — no duplicate**. **Note C** ("VX-502 walk note C - written on the restored library, under P2") through the quick entry → pushed UP: live containers **7 → 8** (newest 2026-10-27T10:43:28Z), cursors **18 → 19** (L2's device), the vault unmoved (revision 24 — joins write no vault row).
- `STATE L9 2026-10-27T10:43:45Z` | 1 instance | L2 `598d1a34` key `7e8d8a27`, not held, synced to castle | castle: castle, revision 24, cursors 19, containers 8.
- **LEG 10 — THE PAIR RESTORED, then signed out (04:44:19–04:46:27 MDT) — DONE.** On the now-JOINED restored library: Protection ▸ Change passphrase… (the synced line on screen) → Current ← `passphrase2` (P2), New + Again ← `passphrase` (P1) → `change_passphrase: begun #5 7e8d8a27 → none · done #5` · `road: changePassphrase — the current key re-locked (7e8d8a27), the account's lock with it` → the vault **24 → 25** (updated 2026-10-27 10:45:06Z), mode castle; the key unchanged. **The files TRUE with ZERO edits, proven by the check door:** `passphrase` → **"That passphrase opens this library and your account."** · `words` → **"Those twelve words open this library and your account."** (log `the library: opens; the account: opens` ×2); `prod-test-accounts.env` and `prod-test-words-castle` fingerprints identical to W0's. **The account's posture (R2-N4):** found CASTLE → LEFT in Castle. **Signed out (rule 16 — no key change):** Protection ▸ Sign out… → the alert **"Sign out of this Mac?"** → Sign Out (AX press) → the row **"Signed out · Sign in…"**.
| B4 | Legs 1–13 per the script of record | NOT STARTED |
