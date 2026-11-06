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
| 3 | Kickoff sitting: cast · riders · VX-734 resolution · VX-820 vocabulary · VX-822 placement/handoff | PENDING — her answers land in the SITTING RECORD below |
| 4 | Batch 1 (VX-734) | NOT-STARTED |
| 5 | Batch 2 (VX-820) | NOT-STARTED |
| 6 | Batch 3 (VX-822) | NOT-STARTED |
| 7 | The ladder over the whole diff | NOT-STARTED |
| 8 | Closeout (canon deltas two-file shape · tickets · handoff · tickets-filed list last) | NOT-STARTED |

## SITTING RECORD — kickoff, 2026-11-05

*(Her rulings land here verbatim-faithful, same turn.)*
