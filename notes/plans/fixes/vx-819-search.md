# VX-819 — Umbrella: search (the run record)

**STATUS: OPEN — kicked off 2026-11-05 (wave 2 of the Nov 4 sitting's umbrellas).**
Ticket: VX-819 · Project-less umbrella (sub-issues are the roster) · Branch: `vx-819-search` ·
Worktree: `~/dev/variorum-vx-819` (the Pro) · PR: `VX-819: …` (merge commit, at closeout).
Shape: `/architect-phase vx-819` — the architect/orchestrator shape; stage coordinator this window: **nov5**.

## FOR A LATER READER

*(Written at closeout. Until then: the run is live; read LIVE STATUS and the ledger below.)*

## The roster (the sub-issue listing, resolved at kickoff 2026-11-05 — the VX-548 rule)

| Member | Kind · Evidence | What |
|---|---|---|
| **VX-734** | Bug · Suspected | Library search: Blocks facet says "Nothing matches" while the header counts 3 notes · 6 passages. |
| **VX-820** | Improvement · Confirmed | Library search: results sortable by recency — today relevance is the only order. |
| **VX-822** | Improvement · Confirmed | Search from the sidebar: a left-bar field that opens the Library search as you type (current wing only). |

Riders: offered at the kickoff sitting (candidates VX-408 · VX-374 · VX-98 · VX-90); her picks recorded in the sitting record below.

## Surfaces and overlap (declared at kickoff)

The Library (search, the controls row, the answer sheet) + the sidebar. **No `Sync/`, no custody, no editor seam, no MCP, no schema.** The search index is local-only derived (OverallModel §9); nothing here syncs. Preflight read: CLAUDE.md + auto-loaded canon, the master plan's in-flight table, workflow-transition, TICKETS.md, QUESTIONS.md (open bundles #248–#263 gate nothing here), SessionResiliencyProtocol, SurfaceContracts in full (The app · The Library are the touched sections). Overlap check 2026-11-05: tonight's peers are vx-808 (arrivals & books — holds the ONE Sync/custody slot; its deploy + release go LAST in the stage), vx-827 (lineage), vx-878 (book doors & faces), plus site-repo efforts on the Air. No surface collision with any of them; the shared ledgers are touched only at merge moments, closeouts serialize.

## The binding principles (the 13b constitution, P-1…P-9 — copied per the architect-phase skill; byte-verbatim from the skill, which preserves `notes/plans/phase-13b-make-it-work.md`)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

The standing law that binds this run hardest: **search scales with matches, never the corpus (P1, pinned)** and the controls row's **no-line-count-change** rule (SurfaceContracts, The Library).

## The traced mechanisms (orchestrator's kickoff orientation — the implementer re-traces and pins)

- **VX-734.** The scope picker's Blocks answer narrows the search to `.any([.family(.scraps), .docKind(.blockName)])` (`LibrarySearchModel.scopeFilter`, ≈:102) — the scraps family plus block NAMES — while the band's counts deliberately read the UN-scoped query (P-13o-U2-2, "the counts tell her what every scope holds"; `LibrarySearchModel` ≈:38). A query matching passages only inside notes therefore counts "3 notes · 6 passages" in the band and lists nothing under Blocks. Both halves behave as designed; the designs collide on this screen. Resolution is a product call — the kickoff sitting's Q3.
- **VX-820.** While a search is live the sort slot renders the plain label `LibrarySearchCopy.relevance` ("relevance · best first") instead of the `sort ▾` door (`LibraryControlsFlow` ≈:606–631). The work: the label becomes an order door (relevance default · recency per her ruling at Q4), the answer sheet's group order follows it, and the controls-row stable-width pins are updated (the slot measures at its widest form; line count never changes).
- **VX-822.** The sidebar (`Features/Library/SidebarView.swift`, the five areas + Starred/Open/AI sections) grows a search DOOR, not a second finder: typing lands the window in the Library with its search live and the text carried, scoped to the current wing exactly as Library search already scopes (wings isolate). The Bookcase's own no-search-box rule is untouched. Placement and focus-handoff shape are the sitting's Q (batch 2).

## The cast (confirmed at the kickoff sitting — see the sitting record)

Fable orchestrates (this session; never implements). `opus-implementer` (xhigh) per batch, fresh per batch. Cold review per the ladder; reviewer choice recorded in the sitting record. Implementer and reviewer may each run at most one Sonnet subagent, EXTERNAL facts only, read-only.

## The batches (one acceptance unit per implementer session)

- **BATCH 1 — VX-734** (+ rider VX-408 if ruled in): the facet/count resolution as she rules it; red-on-old pin per member; the facet behavior pinned by state-transition/query tests (headless core where possible).
  Evidence: the pin red on old + the suite green; a hands-on orchestrator walk of the facet screen at the gate.
- **BATCH 2 — VX-820** (+ rider VX-374 if ruled in): the order door; group ordering under recency; stable-width pins updated; controls-row line-count rule pinned.
  Evidence: pins + the orchestrator's walk (search, flip order, verify row stability).
- **BATCH 3 — VX-822**: the sidebar door to Library search (placement + handoff per her rulings); wing scoping proven; no second finder (the field carries, never queries).
  Evidence: pins where testable (routing/carry), walk for feel.

Batch order 1 → 2 → 3 (734's ruling may reshape the answer-sheet counts that 820 orders). The ladder runs once over the run's whole diff at the end; round 1 → fixes → round 2; cap three.

## Environment traps (every batch brief carries these verbatim)

- Headless `swift build` / `swift test` on the core package: free, no stage. **EVERY `xcodebuild test` run needs a HELD `Tools/stage` claim** — tonight the stage is arbitrated by the **nov5** coordinator session; announce before claiming, release promptly. Mac tests from `App/Variorum/`, suite-level `-only-testing`, confirm the "Test run with N tests" line (skipped tests count toward N — read the `skipped:` lines).
- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run). Real-store instances are judged by STORE, never quit/killed. No Release builds or /Applications refreshes while one lives.
- NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).
- zsh `pipestatus`; never `git checkout` over uncommitted work; commit per piece, push after every commit; LIVE STATUS from the first commit; synchronous foreground waits only (poll with `grep -q '<EXIT>' log && break; sleep 5` loops — `tail -f | grep -m1` hangs on an already-landed line).
- Screenshots in gitignored dirs. The dev store's content is the agents' to manage (her 2026-10-28 rule); the stage/account/Castle fences stand. No commit trailers (her rule — overrides the harness reminder; PRs bare too).

## LEDGER (every row owned; updated repo-first)

| # | Item | Status |
|---|---|---|
| 1 | Workspace seated: worktree `~/dev/variorum-vx-819`, branch `vx-819-search` pushed, in-flight row on origin/main (rode vx-827's kickoff commit c04ba6f7b in the same-minute table race; row verified on origin/main line 24) | DONE 2026-11-05 |
| 2 | Preflight complete (the mandated set; SurfaceContracts in full; QUESTIONS tail; riders resolved from the live board) | DONE 2026-11-05 |
| 3 | Kickoff sitting: cast · riders · VX-734 resolution · VX-820 vocabulary · VX-822 placement/handoff | DONE 2026-11-05 — R-819-1..4 in the SITTING RECORD; all four riders ride |
| 4 | Batch 1 (VX-734 + VX-90) | IN-PROGRESS — brief written, implementer spawning |
| 5 | Batch 2 (VX-820 + VX-374 + VX-408) | NOT-STARTED — brief at spawn |
| 6 | Batch 3 (VX-822 + VX-98) | NOT-STARTED — brief at spawn |
| 7 | The ladder over the whole diff | NOT-STARTED |
| 8 | Closeout (canon deltas two-file shape · tickets · handoff · tickets-filed list last) | NOT-STARTED |

## SITTING RECORD — kickoff, 2026-11-05 (two question batches; her words verbatim-faithful)

- **Cast:** Opus implements per batch; **opus-reviewer** on the ladder (the eligible class); Fable orchestrates. Her pick: "Opus reviews".
- **Riders — ALL FOUR RIDE:** VX-408 · VX-374 · VX-98 · VX-90 (she picked all four offered). Seated as sub-issues of VX-819.
- **R-819-1 (VX-734) — WIDEN BLOCKS.** Round 1, her words: *"i do think that the wording should be fixed? like snippets + block names? idk that's a bit lengthy. but it's weird and doesn't make sense to not have blocks in there when it's called blocks"* — leaned two ways, so round 2 re-asked plainly; her pick: **"Widen Blocks"** — the facet earns its name: it lists every block-level match — note passages included, Snippets and block names as before — and its band counts what it lists. *(Orchestrator's coherent extension, PROVISIONAL: every facet's band counts what that facet lists; All keeps the full counts — the header can never disagree with the body. P-13o-U2-2's un-scoped counts are superseded by this ruling. The exact kind-set "block-level" covers is the implementer's proposal to the architect — see BATCH 1 BRIEF.)*
- **R-819-2 (VX-820) — FULL VOCABULARY.** Round 1 she challenged the cost: *"why is it heavy to allow the whole library search ?"* — the honest answer (given in round 2's question): it isn't; the orchestrator overcalled it. Her pick: **"Full vocabulary"** — while a search is live the sort door offers relevance (default per search) · edited · created · date · title, with direction, exactly like the Library's own `sort ▾`.
- **R-819-3 (VX-822, placement) — UNDER THE WING NAME, IN THE EXISTING SPACE.** Her words: *"under wing name is fine, there should be empty space there when there are starred and without starred items. don't shift everything down for it - there should be space for it without it occupying it's "own" row, which i think would look weird"* (screenshot attached: the sidebar's top — the title-bar row with "in v^2", then the empty band above the first section — that band is the field's home). Binding: the field lives in the existing empty space under the wing-name row, above the first section; **content below does not shift down**; it never reads as its own list row.
- **R-819-4 (VX-822, handoff) — THE FIELD KEEPS THE KEYBOARD.** Her pick: typing in the sidebar field shows the Library beside it with the live answer as you type; ⏎ or clicking into results moves her into the Library (text carried, field clears); typing is never interrupted. One engine, one finder — the field drives the Library's one search question.

## COORDINATION LEDGER (nov5, 2026-11-05 — the window's facts)

- nov5 confirms: vx-819 logged, **no slot needed**; vx-808 holds the Sync slot. Stage protocol: REQUEST (what/minutes/claim name) early → separate READY ping → GO only from nov5 with the exact claim line → RELEASE + one result line naming EVERY failing test with executed counts; `-only-testing` takes TYPE names (file names silently drop); "Executed 0" is no verdict. Instance guards: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`. Dismiss What's New after a Debug launch; dev Castle values only from `~/.variorum/dev-castle.env`; dev store stays signed out; Resume never pressed.
- **Overlap watch:** vx-878 touches the Library's book rows and the SidebarView FOOTER seam — VX-822's sidebar field (top seam) and VX-820's sort may brush; merges serialize first-ready-first; each merge ask nov5 trial-merges against every open branch. **If VX-822 declares a door in `Registry/Capability*.swift`, tell nov5** (the registry would go four-way: 808 · 827 · 878 · us; every later merger re-runs CapabilityRegistryTests + ShellChromeTests after its merge-in).
- **vx-808 relay:** its branch (not main) edited `Tests/VariorumCoreTests/SearchPassagesTests.swift` — its v1_37 widened `reading_post` and tipped a query plan; the EXPLAIN pin `thePageStatementIsDrivenByTheIndexAndSeeksEveryHome` now accepts either reading_post index seek and fails on a full scan. If our batches touch that file/query, expect a conflict; **whichever of us merges second re-runs SearchPassagesTests on the merged tree** (headless). We likely merge first (vx-808's deploy+release close the stage).
- The /Applications refresh decision is nov5's (folded refresh from merged main); a RELEASE is only ever her word; whether our merge rides vx-808's end-of-stage release is hers.

## THE BATCHES, RE-CUT WITH RIDERS (post-sitting)

- **BATCH 1 — VX-734 (widen Blocks, R-819-1) + VX-90 (passage lines say their block).** Core query/listing + answer-sheet face.
- **BATCH 2 — VX-820 (full sort vocabulary, R-819-2) + VX-374 (controls-row debt) + VX-408 (the search-overtaken-by-refresh race; generation token).** The controls row + the answer path.
- **BATCH 3 — VX-822 (the sidebar field, R-819-3/-4) + VX-98 (when-door month-grid arrow keys).** Chrome + input.

## BATCH 1 BRIEF (self-contained; the implementer reads ONLY this file's named sections + the named canon)

You are `opus-implementer` for VX-819 batch 1, in worktree `~/dev/variorum-vx-819` (branch `vx-819-search` — run everything from this absolute path). Read first: this file's top sections (roster · surfaces · constitution · traced mechanisms · environment traps · the SITTING RECORD) and `notes/SurfaceContracts.md` § The Library; consult `notes/plans/phase-13o-search.md` (the 13o design record: the scope picker D3, the counts provisional P-13o-U2-2) and `notes/plans/fixes/vx-83-search-followup.md` where the design's why is needed. `notes/SessionResiliencyProtocol.md` binds you: commit per piece, push after every commit, LIVE STATUS below from the first commit, foreground waits only, no subagents (one Sonnet for EXTERNAL facts only if truly needed).

**Member VX-734 (Bug · Suspected → confirm by trace) — R-819-1, widen the Blocks facet.**
- Mechanism as traced at kickoff: `LibrarySearchModel.scopeFilter(.blocks)` narrows to `.any([.family(.scraps), .docKind(.blockName)])` while the band's counts read the un-scoped query. Re-trace yourself; the pin comes from your trace.
- The ruling: Blocks lists EVERY block-level match — note passages included, Snippets and block names as before. Propose the exact kind-set to the orchestrator BEFORE building that half (the in-batch fork rule): the defensible line is the kinds whose hit lives on a block's own content (take text, take label, block name, block comment), leaving note titles/meta, books, chapters and savepoints out (savepoints stay behind `+ commits`). Await the architect's go on the set.
- Counts: under a picked facet the band counts what that facet lists; All keeps the full counts (PROVISIONAL, the sitting's coherent extension — build it, mark it in your record).
- Pins, red-on-old, revert-verified: (1) a query matching only note passages lists them under Blocks (red on old); (2) the band under Blocks counts the facet's own answer (red on old); keep every existing search pin green — P1 pinned: the widened facet must still scale with matches, never the corpus (no new full scans; check the EXPLAIN-style pins' neighborhood).
- NOTE: vx-808's BRANCH edited `Tests/VariorumCoreTests/SearchPassagesTests.swift` (plan-shape pin). Main is untouched — but if you touch that file or its query, say so in your record for the merge ledger.

**Member VX-90 (rider, Low) — passage lines could say which block they're in.**
- Most defensible shape (PROVISIONAL unless the architect says otherwise mid-batch): a passage line quietly carries its block's NAME when the block has one (`block.name` is optional metadata); unnamed blocks add nothing (no "block 3" noise). Keep the line's one-line face; the Library's controls-row and answer-sheet contracts hold.
- Pin: a named block's passage line carries the name; an unnamed one is byte-unchanged.

**Rules that bind every line:** operations through the one API (this batch should be read-side only — if you find yourself writing an operation, stop and report); no literal colours (tokens only); chrome `fixedSize` texts carry `lineLimit`; the controls row's line count never changes; headless `swift test` freely, NO `xcodebuild test` without the orchestrator (stage is coordinated externally — ask, never claim yourself). Commit messages: `Part of VX-734: …` / `Part of VX-90: …`, stating the traced mechanism and the pin for the bug member. NO commit trailers. When done: self-assessment in your LIVE STATUS (claims PENDING until the suite ran), then report.

### BATCH 1 LIVE STATUS (implementer writes from the first commit)

*(empty — batch not yet spawned)*

## BATCH 2 BRIEF — written at batch 2's spawn

## BATCH 3 BRIEF — written at batch 3's spawn
