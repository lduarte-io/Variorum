# VX-805 — Run: the journal cluster (umbrella)

**STATUS: OPEN — kicked off 2026-11-05 (/architect-phase, the Pro). Branch `vx-805-journal-cluster`, worktree `~/dev/variorum-vx-805`. This run HOLDS the Sync/custody slot (granted by nov4coordinator 2026-11-05 00:41); VX-808 serializes behind it; the 805+808 mirror window is HELD until both merge and runs only at her explicit go. Expected mirror DDL of this run's own: NONE.**

## FOR A LATER READER

*(Written at closeout. Until then, the sections below are the run's working record.)*

---

## 1. Roster (the sub-issue listing, per her 2026-10-27 rule)

Seated members: **VX-435** (Journal movable to any wing) · **VX-436** (Journal deletable, ⌘J re-mints) · **VX-797** (New Entry/⌥⌘N mint fresh entries) · **VX-799** (journal posts stop seeding one_block) · **VX-587** (shift a dated entry one day earlier) · **VX-832** (date picker defaults to creation day).

Riders, taken at the kickoff sitting (2026-11-05): **VX-845** (keep-the-day extends to promote, diverge-for-reading and the ownership forks — already ruled, QUESTIONS #258 F-1(c)) · **VX-615** (gathering context menu says "Delete Book…" while the confirm says Delete Gathering — wording) · **VX-561** (book creation dialog: Esc reportedly doesn't close it — SUSPECTED; repro first, dropped with a record line if it won't reproduce).

Pin-before-fix binds PER MEMBER. Commit messages say `Part of VX-<member>`. Members close individually as their fixes land.

## 2. Cast (her kickoff picks, 2026-11-05)

- Orchestrator: Fable (this session, `vx-805`).
- Implementer: **Opus (`opus-implementer`, xhigh) on every batch, the Sync/ batch included** — her kickoff pick (R-805-1).
- Cold review: **Fable (`fable-reviewer`, xhigh) over the run's whole diff** — mandatory (the run touches `Sources/VariorumCore/Sync/`). Fresh reviewer per ladder round; `notes/REVIEW_PROMPT.md` verbatim, zero framing. Cross-model flow per CLAUDE.md (findings verbatim to the implementer; the reviewer makes the final call; the implementer applies confirmed fixes red-on-old; FINDER-FIXES / Sync/ lines are the reviewer's own hands, then one implementer sanity pass).

## 3. Her rulings

### From the 2026-11-04 design sitting (written on the tickets — the run's contract)

- **VX-435:** One Journal per store, movable to any wing; the move doors stop refusing it. ⌘J follows the Journal to its wing (a wing switch, like opening any note). **The cross-wing mend:** a synced-in entry whose Journal moved wings repairs by MOVING the note into the Journal's wing, tags adopting by path — the same members-move-with-the-book semantics as moveReadingToWing. Her rationale: books can be Private, and a note meant for a private book must not strand in an open wing. This is a SyncSpec §7 repair class; the daily-Journal keeper becomes wing-aware. A membership arriving for a TOMBSTONED book stays inert exactly as today — the repair never moves a note for a dead book. A fresh ⌘J mint when no Journal lives: the wing you're standing in.
- **VX-436:** deletable — Delete appears beside Archive on the daily Journal; the `dailyJournalCannotBeDeleted` refusal retires; the next ⌘J re-mints a fresh Journal in the wing you're standing in. **No backfill:** old entries never re-file themselves — a pair decided with the old book stays decided, and the new book only ever receives each day's own filing.
- **VX-797:** ⌘J keeps open-today and opens the day's FIRST entry; the deliberate new-note doors in the Journal (New Entry, ⌥⌘N in the focused book) mint a fresh entry dated today; backdating a catch-up entry is the masthead's date chip (no date-picker ceremony on the mint); several entries per day are legal. VX-587 rides this run.
- **VX-799:** new journal entries stop seeding `one_block` (the mint change) AND the stored `one_block` override on EXISTING journal entries is cleared ("i don't think it matters that much"). No retroactive re-segmentation — existing blocks untouched; only future typing at an entry's end crystallizes paragraphs normally. Canon (AppSpec §7's "profile='journal' seeds one_block" line; OverallModel §7's journal default) updates at the merge.
- **VX-832:** the date picker defaults to the note's **creation day** (the gesture is backdating; matches VX-758's Library date rule). A note that already HAS an entry date opens on that date, unchanged.

### From the kickoff sitting (2026-11-05, question-dialog picks — recorded same turn)

- **R-805-1 (cast):** Opus implements the Sync/ batch; Fable cold-reviews. (Her pick: "Opus implements".)
- **R-805-2 (restore beside a standing Journal):** **the restoree demotes to the trait** — the restored book returns whole but as an ordinary `'journal'`-trait book; the standing Journal keeps ⌘J and the `'daily'` marker. A restore with NO standing daily book is untouched: the old book simply returns as THE Journal (the marker rides the row). Matches no-backfill; a restore never steals the live Journal; nothing migrates.
- **R-805-3 (VX-587 shape):** **chord + menu act** — one registry capability ("Shift date a day earlier") on any note with an entry date: a keyboard chord (the implementer sweeps the registry for a free chord and PROPOSES it to the orchestrator before wiring — an in-batch design fork), plus the note ▾ menu and ⌘K; the receipt names the new date.
- **R-805-4 (riders):** VX-845, VX-615 and VX-561 all join the run.
- **R-805-5 (the wire and the movable Journal):** **the wire keeps a Journal refusal** — moving the daily Journal across wings stays hers alone on the MCP side even after VX-435 lifts the operation's refusal for her own doors. Context: VX-809 (parallel run) wraps `moveReadingToWing` as `move_book_to_wing`; today it inherits the op's refusal; once this run lifts the op refusal, THIS run's diff carries the wire-side Journal fence + its worded refusal line + test, so the tool never gains the capability in any merge order. Relayed to nov4coordinator → vx-809.
  - **Sibling consequence, status quo (no new ruling):** MCPSpec's standing line "the daily Journal never deletes" on the wire is KEPT — when VX-436 retires the op-level delete guard, the wire's `delete_book` refusal moves to the MCP door (worded via the one refusal chain), exactly as the move fence does. Her doors open; the wire's posture is unchanged.

## 4. The binding principles (the 13b constitution, P-1…P-9 — copied per the architect-phase skill; byte-verbatim)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

*(The application notes in `.claude/skills/architect-phase/SKILL.md` bind the same way.)*

## 5. The batch plan (acceptance units, order, evidence)

**Unit A — the small app-side members (one implementer session; no `Sync/`, no custody).**
Members: VX-799 · VX-832 · VX-587 · VX-845 · VX-615 · VX-561.
- VX-799: `insertPost` stops seeding `one_block` for journal-profile posts; plus a one-time pass clearing the stored `'one_block'` `segmentation_default` on existing journal entries (an ops-road write — synced rows change through the operations layer, CAS metadata; NOT a schema migration of meaning, no §12 event). Red-on-old pin on the mint; exact state-transition test on the clearing pass (only journal-profile posts with `'one_block'` touched; others byte-unchanged).
- VX-832: the masthead date picker opens defaulted to the note's creation DAY when the note has no `entry_date`; a dated note opens on its date, unchanged. Focused VM/unit tests. (Check where the picker lives — if in `App/Variorum/Shared/`, say so in the batch record: the merge gate adds the phone suites.)
- VX-587: per R-805-3 — registry capability, chord PROPOSED before wiring (in-batch design fork: the implementer returns with its chord-collision sweep and proposal; the orchestrator rules; repo-first, then build). Enabled on any note with a non-nil `entry_date`; shifts `entry_date` one day earlier through an ops-road write (touch, no churn — identity-level date metadata; follow `entry_date`'s existing write road); receipt names the new date. Registry-walk test covers the new act.
- VX-845: extend `Domain/DuplicateDay`'s keep-the-day rule to `promoteNoteVersion`, `divergePostForReading` and the ownership forks (ruled F-1(c), QUESTIONS #258). Red-on-old per operation; exact state-transition tests.
- VX-615: the gathering row's context-menu delete verb reads by kind (the VX-611 capability's verb) — a wording fix; pin that the menu's verb matches the confirm's.
- VX-561: repro FIRST (Esc on the book creation dialog). Red pin confirms → fix; green on old → record-only, close the ticket with the finding (the hollow-pin rule).
Evidence of the unit's kind: the suite green + the pins; an orchestrator hands-on walk of the date picker/shift-a-day once a stage window runs (folded into the run's walk).

**Unit B — the Journal's identity: movable + deletable (THE Sync/ batch; phase-sized).**
Members: VX-435 · VX-436. Opus implements (R-805-1); Fable cold-reviews; the implementer READS IN FULL before building: `notes/SyncSpec.md`, `notes/sync-postmortem-fragments.md`, `notes/MCPSpec.md` (the wire fence pieces), SurfaceContracts' Bookcase/app sections, and §6 (design constraints) below.
- Ops half: the daily mint lands in the STANDING wing (`Operations+Container` mint sites; ⌘J's ensure); `setDailyJournalBook` drops `dailyJournalIsHomeOnly`; `moveReadingToWing`/`moveWingContents` stop refusing the Journal (members move with the book, tags adopt by path — the existing road); `refuseDeletingTheDailyJournal` retires from `deleteReadingRow`/`deleteReadingWithNotes`/`revertImportedBook`; Delete appears beside Archive on every Journal face (the one `BookStateDoors` table; phone faces follow the same table where they read it — name any `Shared/` file touched); ⌘J follows the Journal's wing on open (WingFollow — opening it is a wing switch); the re-mint lands in the standing wing.
- Restore half: R-805-2 — `restoreReading` of a `'daily'`-marked book beside a standing live `'daily'` book demotes THE RESTOREE to `'journal'` trait in the restore's own transaction; no standing book → the marker rides the row (unchanged). State-transition tests both ways.
- Sync half (the §7 work): per §6 below. The keeper goes wing-aware; the cross-wing mend lands as a new repair; the user-delete vs keeper-retirement distinction is designed and pinned; repair writes enqueue explicit outbox rows; EVERY repair change lands with two-client fake-server convergence tests (a sync change without a convergence test is unreviewed).
- Wire half: R-805-5 — the MCP door keeps a worded Journal refusal on the book-move road once the op's refusal lifts, and gains the worded Journal refusal on the delete road once the op's guard retires (both through the one refusal chain `MCPWireRefusalCopy.spoken`; no raw case; pinned). **The move fence ships as a SHARED wire-side check a later tool can call — never inlined into one tool** (coordinator's note 2026-11-05: if this run merges first, `move_book_to_wing` doesn't exist yet; vx-809's merge-in routes its tool through this fence, and vx-809 pins "move_book_to_wing refuses the daily Journal" at the TOOL level so a missed wiring goes red in either order). The merge ask NAMES the shared check. Whichever run merges second re-runs that tool's tests (the coordinator trial-merges at every merge).
- **The implementer PROPOSES the sync-half mechanism (a short design section in this file) BEFORE building that half** — the 4E pattern. The orchestrator rules against §6 and SyncSpec; the ruling lands here; then the build proceeds.
Evidence of the unit's kind: convergence suites green with the new scenarios red-on-old; ops state-transition tests; the registry walk; an orchestrator hands-on walk (move the dev store's Journal across wings; delete it; ⌘J; restore it beside the new one) at a stage window.

**Unit C — VX-797: New Entry / ⌥⌘N mint; ⌘J opens the day's first (after B settles).**
- The Journal's New Entry door and ⌥⌘N (the focused book's own foot act, VX-570's road) MINT a fresh entry dated today instead of delegating to open-today; several entries per day are legal; ⌘J keeps open-today and opens the day's FIRST entry (PROVISIONAL default: first = the earliest-created of the day's live Journal-membered entries; logged to QUESTIONS if the implementer finds a conflicting precedent); the masthead date chip backdates as it already does.
- `shelveInDailyJournalBook`'s pair-decided law is UNCHANGED (a tombstoned pair row stays decided); the new-mint road files the fresh entry as ordinary membership through the same gate.
- Evidence: ops/VM tests; the walk covers mint-twice-in-one-day + ⌘J landing on the first.

**Order: A → B (design proposal, then build) → C → the ladder over the whole run diff → closeout.** A fresh implementer per unit (~500k guideline). Sizing: Unit B is the run's one phase-sized unit; A and C are small — within the two-phase-sized-units bound.

## 6. Unit B design constraints (the sync half — binding on the proposal)

What the proposal must settle, inside these rails:

1. **The keeper goes wing-aware.** Today's keeper (SyncSpec §7): candidates = live `kind='book' AND profile='daily'` (`Queries.isDailyJournalMintShape`); smallest id keeps; the loser's memberships/chapters re-point BEFORE any tombstone applies; the designation converges. The wing question: two offline mints can now live in DIFFERENT wings (each device minted in its standing wing). One Journal per store is the law, so the keeper still converges them to ONE — the proposal states what wing the keeper's members land in (the keeper's own wing, by the cross-wing mend's logic) and proves the re-point + the mend compose deterministically on every device.
2. **The cross-wing mend (the new §7 repair class).** A synced-in entry membered in the Journal while sitting in another wing MOVES into the Journal's wing, tags adopting by path (R-13ia-1's adoption; the moveReadingToWing semantics) — a repair write with explicit outbox rows, deterministic, idempotent. Fires at apply time on the occasions the proposal names (a membership landing, a reading's wing changing). A membership for a TOMBSTONED book stays inert — the repair never moves a note for a dead book. What-moves-with-the-mend is spelled: the note's placement row (`container.wing_id`), its tags' adoption, nothing else.
3. **A user delete is NEVER a keeper retirement (the no-backfill law).** The scout's risk 2: today's keeper arm "a loser landing DEAD beside a live keeper hands its live memberships over first" would migrate a deliberately deleted Journal's entries into the ⌘J re-mint, violating no-backfill — and a delete-then-remint seen out of order can present as two live 'daily' books to a third device, which today's keeper would MERGE (backfill by another door). The proposal must give a deterministic, arrival-order-independent way to tell the duplicate-mint race from delete-then-remint, state it in SyncSpec §7's terms, and pin BOTH orders on the two-client harness (tombstone-before-mint and mint-before-tombstone across devices). It must not trust wall clocks (§9: `server_seq` is the only ordering authority) and must keep the true duplicate-mint race converging exactly as today.
4. **R-805-2 rides the repairs too:** wherever the engine meets two live 'daily' rows that are NOT the duplicate-mint race (e.g. a restore replayed by sync beside a standing Journal), the converged outcome matches the local rule — the later/restored row demotes to the trait, deterministic on every device. The proposal names the predicate.
5. **Discipline (the postmortem's standing rule):** every repair change ships with its deterministic rule, an explicit "what moves with the loser" spec, explicit outbox rows asserted by test, and per-class convergence tests on the production path (real triggers, the fake server). The mirror will never catch a miss.
6. **No DDL expected.** If the proposal finds it needs a column, STOP — that is a §12 lockstep event and the author's call; flag the orchestrator and nov4coordinator at once.

## 7. Environment traps (carried VERBATIM into every batch brief)

- Run everything from `~/dev/variorum-vx-805`; never commit from the main checkout. Commit per piece, push after every commit; LIVE STATUS in this file from the first commit (`notes/SessionResiliencyProtocol.md` binds; synchronous foreground waits only — poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`).
- Headless `swift build` / `swift test` on the core package needs NO stage and runs freely. **EVERY `xcodebuild test` run needs a HELD stage claim** — the orchestrator obtains it from nov4coordinator (REQUEST = what/minutes/claim name; GO only from the coordinator; a FREE stage is never an invitation). Mac tests from `App/Variorum/`, suite-level `-only-testing` (a zsh array of TYPE names); confirm the "Test run with N tests" line; "Executed 0" is no verdict; Swift Testing's N counts skipped tests — read the `skipped:` lines.
- Instance checks: `pgrep -lx Variorum` AND `pgrep -lf "MacOS/Variorum$"`. Real-store instances are NEVER quit or killed. No Release builds or /Applications refreshes while one lives. After a Debug launch, dismiss What's New if it shows.
- NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles). zsh `pipestatus`.
- Main carries the PIN BELT (VX-781): core `swift build` prints 7 EXPECTED "dependency not used by any target" warnings — not a regression. A build that tries to float a pin fails closed — moving a pinned dependency version is HERS ALONE (CLAUDE.md author-only list); never "fix" a pin refusal by re-pinning.
- The dev store's Castle credentials are `~/.variorum/dev-castle.env` (never invent, never commit values); dev-store CONTENT is agents' to manage freely; the Debug app never signs into her real account; any prod-test-road act follows the fences (vxtest allowlist only, signed out at rest, never press Resume). Live Castle walk legs go to Opus.
- Never `git checkout` over uncommitted work; commit before any behavioral revert; pre-revert copies in a gitignored uniquely-named dir INSIDE the worktree, never the scratchpad.
- Screenshots in gitignored dirs. No `Co-Authored-By`/`Claude-Session` trailers on commits.

## 8. The ledger

| # | Item | Status |
|---|---|---|
| 1 | VX-799 — one_block seed retires + existing overrides cleared | NOT-STARTED (Unit A) |
| 2 | VX-832 — date picker defaults to creation day | NOT-STARTED (Unit A) |
| 3 | VX-587 — shift-a-day act (chord PROPOSED first) | NOT-STARTED (Unit A) |
| 4 | VX-845 — keep-the-day extends (promote · diverge · ownership forks) | NOT-STARTED (Unit A) |
| 5 | VX-615 — gathering delete verb wording | NOT-STARTED (Unit A) |
| 6 | VX-561 — Esc on book creation dialog (repro first) | NOT-STARTED (Unit A) |
| 7 | VX-435 — movable Journal (ops + faces + keeper wing-awareness + the mend) | NOT-STARTED (Unit B; design proposal first) |
| 8 | VX-436 — deletable Journal (guard retires + delete-vs-retirement + R-805-2 restore rule + wire refusals) | NOT-STARTED (Unit B) |
| 9 | VX-797 — New Entry/⌥⌘N mint; ⌘J opens the day's first | NOT-STARTED (Unit C) |
| 10 | The ladder (Fable, whole run diff) | NOT-STARTED |
| 11 | Closeout (canon deltas: AppSpec §7/§9/§12 lines, OverallModel §7, SurfaceContracts Bookcase/app lines, MCPSpec wire lines; AppSpecRecord entry; tickets; handoff) | NOT-STARTED |

## 9. Coordinator protocol (nov4coordinator, 2026-11-05)

Slot: Sync/custody GRANTED 00:41, held until this run answers "nothing further owed". Stage: REQUEST early (what/minutes/claim name) → READY ping → GO with the exact claim line → RELEASE + one result line with EXECUTED counts per suite. Merge ask names the tree the last WHOLE-TARGET run tested. Known overlaps: (1) the capability registry (VX-828's ⌘digit/spellcheck + VX-809 + this run's VX-587) — the SECOND merger re-runs CapabilityRegistryTests + ShellChromeTests; (2) `App/Variorum/Shared/` — if any Shared/ file enters this diff, the merge-gate window adds the phone suites on the simulator (VX-828 owes them too; the coordinator intersects); (3) `move_book_to_wing` (VX-809) — whichever merges second re-runs its tests against R-805-5's fence. A window of an hour+ runs its tests first and pings "SEAM" before any dev-store copy.
