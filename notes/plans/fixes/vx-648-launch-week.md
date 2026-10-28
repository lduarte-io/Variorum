# VX-648 — Run: launch-week umbrella (MCP follow-ups, book navigation, wing doors, stars & the deleted-blocks trace)

**STATUS: OPEN — kicked off 2026-10-28 (overnight, /architect-phase).**
Ticket: VX-648 · Project: v1 release readiness · Branch: `vx-648-launch-week` · Worktree: `~/dev/variorum-vx-648` · Machine: the Pro.
Orchestrator: Fable (architect shape). Implementers: fresh Opus per batch (xhigh). Cold review: **Fable** (`fable-reviewer`) — VX-647/649/563 touch the editor seam. Stage: via **oct27coordinator** (REQUEST → READY → GO protocol; never self-claim). No release without her word.

**Her kickoff (2026-10-28, verbatim):** "/architect-phase vx-648 — Run: launch-week umbrella. Resolve the members by LISTING VX-648's sub-issues (16 at minting; the listing governs — re-list before the ladder). My rulings are on each ticket and in QUESTIONS #245 / AppSpecRecord's 2026-10-27/28 entries. Suggested batches: (1) the editor lag pair — VX-647 (Pre-launch) + VX-649: at the very least a detailed trace; if the fix seems feasible do it then and there, if it needs a lot of surgery it waits — included either way (editor seam: Fable review, TEXTKIT2_NOTES first); (2) the MCP door — VX-639 (an edit grant reaching a gathering gets a book's acts: star, rename, archive, delete; its rule stays mine), VX-640 (/mcp in the instructions, provider-neutral; the cap rises to 3,100), VX-641 (Pre-launch: the Private row hides until the library has ever had a client; an already-marked note or book always shows it; the guide says when it appears), VX-606 (refuse undeclared arguments on every tool), VX-626 ("last seen" stamps the disconnect), VX-367 (guide lesson 3 names the eight edit acts); (3) wings, stars & keys — VX-644 (the "in ‹wing›" label opens the wing switcher), VX-632 (⌥⌘L Move to Wing… / ⇧⌥⌘L Copy to Wing…), VX-643 (remove the 15-star cap — mobile-visible), VX-563 (⌘↑/⌘↓ step between notes while reading, document start/end while editing); (4) the book navigator & small fixes — VX-645, VX-646, VX-630, VX-631. VX-440 runs in parallel and also touches the book navigator and Book Settings — closeouts serialize, the second merger merges main in and re-runs the overlap. Stage, merges and any walk per the standing rules and whichever coordinator is live; no release without my word." — plus, in the same message: "VX-612 was also added after this kickoff message was first drafted. contact oct27coordinator for your walk / testing needs. Rule provisionally overnight on what you are able to."

## The roster — the SUB-ISSUE LISTING at kickoff (2026-10-28, 17 members; re-list before the ladder)

| # | Member | Batch | Priority | Labels | One line |
|---|---|---|---|---|---|
| 1 | VX-647 | 1 | High | Performance · Bug · Pre-launch | Many deleted blocks ⇒ 3–5 s lag on Return/new blocks and deletes. TRACE FIRST; fix if feasible. |
| 2 | VX-649 | 1 | High | Editor · Bug | Leaving a checklist with Return: the new line vanishes ~1 s. Investigated WITH VX-647, same rule. |
| 3 | VX-639 | 2 | Medium | MCP · Improvement | Edit grant reaching a gathering gets a book's acts (star, rename, archive, delete); `set_book_rule` keeps refusing. |
| 4 | VX-640 | 2 | Medium | MCP · Wording | /mcp reconnect road into `MCPSession.instructions`, provider-neutral; `instructionsBound` 3,000 → 3,100. |
| 5 | VX-641 | 2 | Medium | MCP · Improvement · Pre-launch | Private row hidden until the library has EVER had a client (VX-590's fact); already-marked always shows; guide says when it appears. |
| 6 | VX-606 | 2 | Low | MCP · Bug (Suspected) | Wire served `read_note` with an undeclared argument despite `additionalProperties: false` — validate the published schema, every tool. |
| 7 | VX-626 | 2 | Medium | MCP · Bug | Clients row "last seen" shows a closed session's START; stamp the close (the end-line road runs at every ending). |
| 8 | VX-612 | 2 | Low | MCP · Bug (Suspected) | Accept loop can die while the pane says "running": retry the transient class (EMFILE/ENFILE/ENOMEM/ENOBUFS/EAGAIN), fail loudly otherwise. |
| 9 | VX-367 | 2 | Low | MCP · Wording | Field guide lesson 3's Edit card names the eight remaining edit acts one by one. |
| 10 | VX-644 | 3 | High | App shell · Improvement | The "in ‹wing›" label beside New Note IS the wing switcher (⌘L's sheet, same act; P-1 declared door, P-2 one-wing ruled note). |
| 11 | VX-632 | 3 | Medium | App shell · Improvement | ⌥⌘L Move to Wing… / ⇧⌥⌘L Copy to Wing… chords over VX-377's selector; same registry capabilities and gates. |
| 12 | VX-643 | 3 | Medium | Library & sidebar · Improvement | Remove the 15-star cap everywhere (her doors, ⌘K, drop-to-star, the wire, the PHONE — MOBILE-VISIBLE); words mentioning fifteen go. |
| 13 | VX-563 | 3 | Medium | Books · Improvement | ⌘↑/⌘↓ step previous/next note in the in-book view while reading; document start/end while editing (VX-560's rule). HER kickoff ruling. |
| 14 | VX-645 | 4 | Medium | Books · Improvement | Navigator follow-highlight extends to Book and Read modes (the same brain, not a second one). |
| 15 | VX-646 | 4 | Medium | Books · Improvement | Navigator scrolls itself to keep the highlighted row in view (the Open list's follow idiom). |
| 16 | VX-630 | 4 | Low | Books · Bug | Index → Outline carry loses the caret's block (`BookAnchor.landing`'s `.index` arm carries only the note). |
| 17 | VX-631 | 4 | Low | Books · Wording · Bug | "12 storys" — the sample-library receipt's plural. |

NOT members (explicit, from the run ticket + #245): VX-633 (unseated — does NOT gate the launch build, runs later), VX-642 (Needs Lillian, NOT to be built), VX-611/VX-616/VX-189 (→ VX-440), VX-613/VX-628/VX-625/VX-368/VX-369 (riders not taken).

## Where her rulings live (preflight read, 2026-10-28)

- Each member's ticket body (fetched at kickoff; quoted in the batch briefs below).
- QUESTIONS **#245** (the VX-620 bundle — RB-7 → VX-639, RB-13+cap → VX-640, RB-3/RB-10 fact → VX-641, star cap → VX-643, VX-367/606 "should be done") and **#246** (the VX-562 bundle — P-562-1 → VX-646, P-562-2 → VX-645). #245 is HANDLED end-to-end; #246's P-562-8 (the bottom-twitch taste call) waits on her live look — NOT this run's to change.
- `notes/AppSpecRecord.md`, the 2026-10-27/28 entries (her three passes on the VX-620 thread; VX-562's entry).
- VX-563's gesture is SETTLED BY HER KICKOFF: ⌘↑/⌘↓ step between notes while reading, document start/end while editing — VX-560's reading-vs-editing rule (the proposal is also on the ticket as a comment).

## Binding principles — the 13b constitution (copied per the architect-phase skill; BINDING in this run)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

Application notes (the skill's precisions) bind too: P-1's scope is the ROUTED vocabulary grown incrementally (`.surface` door case for inline-only doors); P-3 keeps TWO deliberate surface kinds (the full-document editor is never absorbed into `PaneSurface`; both consult `PaneTextAuthority`); storage-coupled code stays feature-side; equality-gated sinks deliver at wire time and overlay geometry refreshes trigger on every input axis; a fixed class recurring adjacent closes with a sweep table (instance × host, FIXED-with-named-pin or provably SAFE).

## Overlap & serialization

- **VX-440** (live, parallel): the book navigator + Book Settings (batch 4's surface, and VX-639's Book Settings adjacency). Closeouts SERIALIZE — first-ready merges first; the second merges main in and re-runs the overlap suites before its merge ask. The coordinator intersects merged files at every merge.
- **VX-601** (live, in its batch-C windows → Fable ladder → merge → a RELEASE at her word): the editor seam (`PaneTextView`, `EditorTextView`, `PaneSurface`, the Takes board). Batch 1 (VX-647/649) is the likely collision; the coordinator asked to be told EARLY which editor files batch 1 touches — the batch-1 implementer reports its touched-file list as soon as the trace names them, and the orchestrator forwards it.
- Shared ledgers (master plan, TICKETS.md, QUESTIONS.md, AppSpecRecord) are touched only at merge moments, on latest main, by the merging session. The in-flight row landed at kickoff (commit on main).

## Stage protocol (oct27coordinator, 2026-10-28)

REQUEST (what/minutes/claim name, early, marked "EARLY, not READY" if so) → READY (a separate ping when startable NOW) → GO (only from the coordinator, with the exact claim line) → RELEASE (`Tools/stage release --who <claim>` + one result line: EXECUTED tests/suites per run — 0 ran = no verdict, compare "Executed N tests" with expected counts — dev-store posture, instance/sim state, stage.log times). Every `xcodebuild test` needs the stage; headless `swift build`/`swift test`/`build-for-testing` never do. `Tools/stage renew` RESETS to now+N — ask before renewing. Instance guards: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`, `xcrun simctl list devices booted`. Traps learned 2026-10-27: `-only-testing` SILENTLY DROPS non-suite-TYPE names (verify names); build the `-only-testing` list as a zsh ARRAY (`args=(-only-testing:VariorumTests/A …); xcodebuild … "${args[@]}"`); the dev slot is `…/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/` (the sibling `Variorum/` folder is a relic, NOT the dev store); commit ledger/record files pathspec-limited from a worktree with in-flight edits. Dev store: library e11e5233, HELD since 10-20, signed out, Study with app Appearance = Dark (macOS itself LIGHT — never change the system appearance), no books, one note (Oct-19), Walk Wing empty, MCP server OFF, claude-code approved with 0 grants, NEVER press Resume; record the as-found at leg 0 and restore exactly; export Debug prefs before launch, re-export + diff + delete walk-added keys after. Simulated-input walk steps go to an OPUS walker under the run's claim (her standing fable-safeguards rule routes live walks to Opus anyway). Settings with sync semantics: record and restore exactly.

## Environment traps (every batch brief carries this section by reference — read it in the record)

Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications refreshes while one lives. `xcodebuild build-for-testing` compiles without the runner. Mac tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" / "Executed N tests" line (Swift Testing's count INCLUDES skipped tests — read the `skipped:` lines). zsh `pipestatus`. NEVER add a custom build configuration (anything not named exactly "Debug" builds the SPM packages Release and strips VariorumCore's DEBUG oracles). Suites beside a live session flash the test host's windows — prefer zero-instance windows for timing-sensitive measurements (batch 1's timings are timing-sensitive: ask for an idle window). Backups WAL-safe with UTC names before touching the real store (the A1 rail), into `Backups/safety-copies/`. Screenshots in gitignored dirs. Never `git checkout` over uncommitted work. Push after every commit; never force-push or rewrite history. Commits carry NO attribution trailer (her rule). Commit messages say `Part of VX-NNN` for the member they serve.

`notes/SessionResiliencyProtocol.md` binds every session: commit per coherent piece + push; LIVE STATUS in this file from the first commit; PENDING markers for unverified claims; synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`); implementers never spawn subagents (one read-only Sonnet for EXTERNAL facts only is the one exception, per CLAUDE.md); announce reverts in the record before starting them; commit before you revert.

---

## BATCH 1 — the editor lag pair: VX-647 + VX-649 (trace-then-fix-if-feasible)

**The implementer's brief is this section + the sections above** (roster rows 1–2, the constitution, overlap — note the VX-601 editor-seam overlap and the touched-files report duty — stage protocol, environment traps). Required reading before any code: `notes/TEXTKIT2_NOTES.md` IN FULL (her kickoff: "TEXTKIT2_NOTES first"); `notes/SurfaceContracts.md` §The note; AppSpec §7's Return-key paragraph and §9 (newBlock, deleteBlock, autosave, structural undo/redo, insureTakes); AppSpec §4/§5 and OverallModel §5 (P1–P3). Work in `~/dev/variorum-vx-648` on `vx-648-launch-week`.

**VX-647 (High, Pre-launch, Confirmed).** Her report 2026-10-28, verbatim: "when a note has a lot of deleted blocks, making new blocks with newlines and deleting blocks starts to have a several second (like 3-5 seconds at least) delay. it's really annoying and bothersome." HER RULE FOR THE RUN, verbatim: "at the very least a detailed trace on VX-647, and if the fix seems complicated and like it involves a lot of surgery, it should wait, if it seems feasible, it should do the fix then and there. included either way."
- Suspects from the ticket (unproven — trace, don't assume): something on the new-block and delete roads reads the note's DELETED blocks — the per-post tray ("deleted blocks", `block.last_container_id`), the tray's observation re-running on every structural act, a delete's cascade or restore-cost read, or the structural undo stack's pre-images — so cost grows with the note's history rather than the edit. If so it breaks P1.
- Evidence of its kind (the ticket's own words): a measured repro on a note seeded with many deleted blocks; a P1 pin (statement capture or a timing bound) RED on the pre-fix tree, revert-verified; the fix — OR, if the fix needs surgery, the detailed trace as the deliverable: the named mechanism, the measured numbers, the call path, the fix shape and why it waits. Either way the trace lands in this file under BATCH 1 RECORD.
- The trace can and should start HEADLESS: seed a core-package fixture (a post with N live blocks and M ≫ N tombstoned blocks via the operations API), measure `newBlock`/`deleteBlock`/the queries the editor's structural roads run, as a function of M. If the cost is view-side (an observation re-running, a tray query on every act), instrument the view-model road next — app-target tests need a stage claim (REQUEST early through the orchestrator), so exhaust the headless road first.
**VX-649 (High, Confirmed).** Her report 2026-10-28, verbatim: "when i have a list going like - [ ] and I make a new line after it and hit enter again to get rid of the list, the new line briefly disappears for about a second before coming back - very noticable lag and delay."
- The road (traced only to its door): Return on an empty list item is the editor's list door — `EditorTextView.insertNewline(_:)` handles the list before the segmentation chip's structural Return. A line that disappears and then returns suggests the edit is applied, the display is rebuilt from a stale projection, and the true state arrives a beat later. FIRST QUESTION: does it share VX-647's mechanism (a note's deleted history making structural acts slow)? Her word: investigated along with VX-647, same trace-then-fix-if-feasible rule.
- Evidence of its kind: a repro note, a pin on the visible state through the act (red on the pre-fix tree), the fix — or the trace + deferral case.
**Batch duties:** report the TOUCHED EDITOR FILES to the orchestrator as soon as the trace names them (the VX-601 overlap). Fixes land with red-on-old pins verified by behavioral revert, per member. If the trace proves the finding hollow (no deleted-blocks dependence reproducible), record it — don't fix it. If a fix would change product behavior anywhere ruled (the Return door's semantics, caret landings, receipts), STOP and return the proposal to the orchestrator before building that half (the in-batch design fork rule). Suite scope at close: the suites exercising every changed SOURCE file.

## BATCH 2 — the MCP door: VX-639 · VX-640 · VX-641 · VX-606 · VX-626 · VX-612 · VX-367 (brief to be finalized at spawn; the ticket rulings are in the roster + the tickets, the records in `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md` and `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`; `notes/MCPSpec.md` read IN FULL by the implementer)

## BATCH 3 — wings, stars & keys: VX-644 · VX-632 · VX-643 · VX-563 (brief at spawn; VX-643 is MOBILE-VISIBLE — the phone's star doors, `MobileStars`, `MobileStarredView`, the mobile tutorial's cap line; a MobileSoul ledger row is owed at closeout)

## BATCH 4 — the book navigator & small fixes: VX-645 · VX-646 · VX-630 · VX-631 (brief at spawn; the VX-562 record `notes/plans/fixes/vx-562-outline-follow.md` is required reading; VX-440 overlap — serialize)

---

## LEDGER (every row owned; updated per batch)

| Row | Item | Status |
|---|---|---|
| L-1 | Workspace seated, branch pushed, in-flight row landed on main | DONE (f7331583b + the in-flight commit) |
| L-2 | VX-648 In Progress; roster listed (17) | DONE 2026-10-28 |
| L-3 | Batch 1 (VX-647 + VX-649) | NOT-STARTED — brief above |
| L-4 | Batch 2 (MCP door, 7 members) | NOT-STARTED |
| L-5 | Batch 3 (wings/stars/keys, 4 members) | NOT-STARTED |
| L-6 | Batch 4 (book navigator & small fixes, 4 members) | NOT-STARTED |
| L-7 | Re-list the roster before the ladder | NOT-STARTED |
| L-8 | The ladder (Fable cold review, whole run diff, REVIEW_PROMPT verbatim) | NOT-STARTED |
| L-9 | Closeout (canon deltas in the two-file shape; MCPSpec's 3,000→3,100 line + set_starred cap clause + RB-7 paragraph; SurfaceContracts' keyboard-family line (⌥⌘L/⇧⌥⌘L, ⌘↑/⌘↓) + star-cap words + navigator lines; AppSpecRecord dated entry; tickets; MOBILE PARITY row for VX-643; handoff) | NOT-STARTED |

## RULINGS LOG (provisional rulings land here the turn they're made)

- (none yet)

## LIVE STATUS

2026-10-28 (kickoff): preflight complete (MCPSpec + SurfaceContracts + TEXTKIT2_NOTES + resiliency + workflow-transition + QUESTIONS #245/#246 + AppSpecRecord 10-27/28 entries read in full; 17 ticket bodies fetched). Coordinator announced and protocol received. Batch 1 spawning next.
