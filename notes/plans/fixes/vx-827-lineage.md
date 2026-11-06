# VX-827 — Umbrella: lineage, both faces

**STATUS: OPEN (kicked off 2026-11-05, the wave-2 window; nov5 coordinates the stage).**
Ticket: VX-827 · Project: the Nov-4 sitting umbrellas · Branch: `vx-827-lineage` · Worktree: `~/dev/variorum-vx-827` (the Pro).
Shape: `/architect-phase` (feature/design-heavy — VX-801 carries a design pass). Record: this file.

## FOR A LATER READER

*(Written at closeout. Until then the sections below are the night's working record.)*

---

## The run

Her 2026-11-04 restructure: the lineage redesign and the MCP read family run together — they share
the queries and the fence discipline. The lineage CTE work lands ONCE and feeds both faces. Members
(the sub-issue listing, re-checked at kickoff 2026-11-05):

- **VX-801** — a door to a block's full lineage (app side; design pass). **Sitting rulings
  (2026-11-04, on the ticket, binding):** TWO TIERS — a SIMPLE popover from any block (the glance:
  immediate parents and children, a line each, "Open in Blocks ›"); the FULL surface lives in
  Blocks mode and MAY TAKE THE FULL EDITOR SPACE (the whole tree with text previews; commits +
  takes visible on previous blocks). **Her UX bar, explicit and binding: spacious, easy to read —
  "i'm again concerned and want this ticket to explicitly note a spacious, easy to read UI. i feel
  like lineage could be a significant sized area."** Acts live IN the tree: **Put back** (the
  existing operation with its existing landing; the receipt names where it landed) and **Bring
  back as take** (mints the node's active text as a new take on the block you came from — the
  `bringBackCommitAsTake` shape, cross-block; parent lineage via the existing edge).
  Restore-from-Trash stays on its own surface.
- **VX-817** — MCP reverse lineage ("which notes have copies elsewhere?" in one call). **Fence
  line (the 2026-11-04 disclosure audit, on the ticket, binding):** an edge appears ONLY when BOTH
  its ends are within the client's read reach — a hidden copy is simply absent, never counted,
  never hinted; absence stays indistinguishable from nonexistence (the hidden-and-missing
  discipline applied to edges). R-825 (every answer a pure function of reachable state) binds every
  answer shape this run mints.
- **VX-810** — MCP list notes by tag + tags in the JSON reads + the VX-758 rider: `entry_date`
  (null when undated) rides `list_notes` rows. Post- and block-level union, subtree matching as the
  rule grammar does, within grant reach and the fence, scoped to one wing like every listing.
- **VX-815** — an empty granted note says it's empty. The fence's byte-identical hidden-and-missing
  shape is UNTOUCHABLE; only a note INSIDE the client's reach gains the honest "an empty note"
  answer (title, metadata, empty body). The pin: granted-empty stops being byte-identical with the
  fence answer while hidden vs missing stays indistinguishable.

**No `Sync/`, no custody, no DDL, no lockstep.** The sync slot is vx-808's this window. Overlap:
vx-808's MCP riders (VX-775/776/777/859) touch `Sources/VariorumMCP` too — merges serialize through
nov5; whoever merges second merges the first into its branch and re-runs the MCP overlap suites
before asking for the merge GO.

## Preflight (ran 2026-11-05, this session; reading never delegated)

CLAUDE.md + auto-loaded canon · the master plan (in-flight table; row added c04ba6f7b) ·
`notes/TICKETS.md` (17:15 snapshot) · `notes/QUESTIONS.md` (tail; latest bundle #263 — this run's
is **#264**) · `notes/SessionResiliencyProtocol.md` · `notes/plans/workflow-transition-2026-10-06.md` ·
**`notes/MCPSpec.md` IN FULL** (three members are door work) · `notes/SurfaceContracts.md` (The app,
The Library, The note, Doors) · `notes/TEXTKIT2_NOTES.md` (the glance popover anchors on editor
surfaces; the full surface composes read-tier previews) · the four member tickets in full ·
VX-654's record trail (Done 2026-10-29 inside VX-678: `originalsStrandedBy` rewritten O(L) —
ancestors once, candidate descendant neighbourhood once, MATERIALIZED + CROSS JOIN so SQLite never
flattens to corpus scans; exact-rows pins + library-growth/no-store-table-scan P1 pins; **that
lesson binds every lineage CTE this run writes**).

## The cast

Standing default, confirmed at kickoff: **Fable orchestrates (this session) and cold-reviews
(`fable-reviewer` — the diff carries MCP fence/default's-meaning content, so Opus review is out);
`opus-implementer` builds every batch, xhigh; one agent at a time, fresh per batch; a fresh
reviewer per ladder round.** The orchestrator never implements; its hands stay off
`Sources/VariorumMCP` tool bodies and all app code — briefs, records, mockups (throwaway
instruments / design records), adjudications only.

## The binding principles (the 13b constitution, copied per the architect shape)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut /
  palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data,
  never per-view if-statements. A registry-walk test asserts every declared door exists and every
  rendered door is declared.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any
  mode-switch choreography, done visibly for the user — or delivers the operations layer's real
  refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component that every pane
  composes; "what text does this pane show, and is it live" is answered by ONE pure, unit-tested
  authority (`PaneTextAuthority`); views never re-derive it. Exactly one live pane; the live pane
  is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** No listener derives business state or
  availability from a broadcast; no flow's correctness depends on broadcast ordering. Cross-feature
  flows route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature: write the DESIGN MEMO, get her rulings on the product edges, build to
  the memo.
- **P-6 — The tutorial is the executable spec (R113).** Any change that breaks a tutorial step is
  a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness. Red-on-old stays
  absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer
  exactly as the substrate. Overlays, never rendering attributes. Chrome `fixedSize` texts always
  carry a `lineLimit`. `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in
  the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text
  authority, and gesture routing splits by concern.

Application notes (13b's build record): P-1's scope is the ROUTED vocabulary, grown incrementally;
acts whose only doors are inline on cards/rows declare the `.surface` door case. P-3 keeps TWO
deliberate surface kinds (the full-document editor is never absorbed into the pane surface); any
liveness extension extends `PaneTextAuthority`'s one-live-ring contract ON the authority.
Storage-coupled code lives feature-side. Equality-gated sinks deliver stored state AT WIRE TIME;
overlay geometry refreshes trigger on EVERY input axis.

## The batch plan (acceptance units; one unit per implementer session)

**U1 — the shared lineage queries + VX-817's wire face.** Evidence: exact-rows pins + a
P1/VM-step bound pin red-on-naive (VX-654's precedent); the two-store catalog arm for R-825
(the answer byte-identical between a store where hidden copies exist and one where none do);
both-ends-readable edge pins across wings, Private books, the daily Journal, tombstoned edges,
archived/dead blocks. Mints: a `Queries` family for a note's lineage peers (copies/originals over
`derived_from` + `version_of`, note-level) AND a block-level lineage-tree read (ancestors +
descendants + `version_of` siblings, `origin_op` named, texts resolvable) that U3's surface
consumes — bounded to the block's own neighbourhood, never corpus-proportional. The wire tool
reads the note-level family at READ rung. MCPSpec delta drafted in this file, landed at closeout.

**U2 — VX-810 + VX-815 (the read-ergonomics pair).** Evidence: state/shape pins — tags (ids +
paths) in `list_notes` rows and `read_note`'s JSON forms; `entry_date` (null when undated) on
`list_notes` rows; the list-by-tag road (post- and block-level union, subtree matching, reach- and
wing-scoped, paged like every listing, ∝ rows listed never the corpus); the granted-empty answer
(title, metadata, empty body) with the pin that it differs from the fence shape while hidden vs
missing stays byte-identical; R-825 catalog arms for every changed answer; schema-enforcement
(VX-606) arms for any new argument.

**U3 — VX-801, the lineage door (after the design sitting).** Evidence: the registry-walk test
over the new declared acts (P-1); state-transition tests for Bring back as take (cross-block,
parent = the node's take via the existing edge, fan's end, never chosen, never born locked,
refuses under a seal) and Put back's landing + receipt; pane/preview reuse per P-3 (read tier,
no second liveness mechanism); a hands-on orchestrator walk on the dev store (stage via nov5).
The design mockup (orchestrator-authored, local HTML, absolute path given to her — never an
artifact) precedes the build; her rulings land in this file's SITTING RECORD.

The ladder: ONE ladder over the run's whole diff after U3; `fable-reviewer`, fresh per round,
`notes/REVIEW_PROMPT.md` verbatim; cap three rounds; findings repo-first in this file.

## Fence law carried into every MCP brief (U1, U2)

- The one not-shared shape answers everything unreachable, byte-identical (hidden = missing), down
  to the beyond-grant lineage stub (P-13nb-U4-7). VX-815 changes ONLY the granted-empty arm.
- **R-825:** every answer is a pure function of the client's reachable state — nothing on the wire
  varies with what the client cannot reach, refusals included; pinned by two-store catalog arms.
  The counted-not-named class is retired; scope words are fixed sentences ("…beyond your reach, if
  any, are not listed."), `beyond_reach` always present where the family carries it.
- An edge is spoken only when BOTH ends are readable (VX-817's line). No count, no hint, no
  `has_copies` boolean that could ride a hidden end.
- The wire refuses undeclared arguments at the call door (VX-606). No wire answer shows a raw
  Swift case; store failures speak SQLite's code + message, never the SQL (P-771-11).
- Every read decision through the one rule (`MCPGrantRule.decide` / `decideGathering` /
  `decideWing`); the daily Journal's and ⌘J entries and the Private mark answer only a per-ask
  note grant.
- Tool-description and `MCPSession.instructions` budgets: instructions ≤3,100 chars (R-VX184-3);
  any instructions edit re-counts and stays truth-pinned.

## Environment traps (carried verbatim into every brief)

Instance checks: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the coordinator's strict
forms); treat real-store instances by STORE, never quit/kill one; no Release builds or
/Applications refreshes while one lives. Headless `swift build` / `swift test` and `xcodebuild
build`/`build-for-testing` never need the stage; **EVERY `xcodebuild test` does** — REQUEST →
READY → GO through nov5, release + one result line after, gate lines naming EVERY failing test.
Mac tests from `App/Variorum/`, suite-level `-only-testing` only; confirm the "Test run with N
tests" line; Swift Testing's N counts skipped tests. NEVER add a custom build configuration
(anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).
zsh `pipestatus`. Never `git checkout` over uncommitted work; commit per piece, push after every
commit; LIVE STATUS from the first commit; synchronous foreground waits only (poll with
`grep -q … && break; sleep 5` loops, never `tail -f | grep -m1`). After any Debug launch, dismiss
a What's New sheet if one shows; dev-store Castle values only from `~/.variorum/dev-castle.env`;
the dev store stays signed out and Resume is never pressed. Screenshots in gitignored dirs. A1
safety copy before ANY real-store touch (none expected this run).

## LEDGER

| # | Item | Status |
|---|---|---|
| 1 | U1 — lineage queries + VX-817 wire | NOT-STARTED |
| 2 | U2 — VX-810 + VX-815 + VX-778 (rider, her kickoff pick) | NOT-STARTED |
| 3 | VX-801 design mockup + sitting | NOT-STARTED |
| 4 | U3 — VX-801 build | NOT-STARTED |
| 5 | Ladder (whole diff) | NOT-STARTED |
| 6 | MCPSpec/SurfaceContracts deltas + AppSpecRecord entry (closeout, two-file rule) | NOT-STARTED |
| 7 | Closeout ritual (tickets, handoff, canon-size, worktree removal) | NOT-STARTED |

## SITTING RECORD

**Kickoff sitting, 2026-11-05 (question-tool batch, three answers):**
- **Cast:** "Standing default (Recommended)" — Opus implements every unit, `fable-reviewer` runs
  the one ladder over the whole diff. CONFIRMED.
- **VX-801 design:** *"mockup - but don't use the question tool, just have it ready for me. i'll
  rule before U3."* — So: the orchestrator authors the local HTML mockup during U1/U2, hands her
  the absolute file path in plain chat (never the question tool, never an artifact), and HOLDS
  U3 until her rulings land. The design-pass questions ride the mockup page itself, not a dialog.
- **Riders:** VX-778 joins the run (seated as a sub-issue of VX-827 the same turn; it rides U2 —
  the Settings ▸ MCP client-row count counts only grants whose place still stands, or says
  "N grants"). VX-787 declined.

## U1 BRIEF — the shared lineage queries + VX-817's wire face

**Read first (in this order, in full):** CLAUDE.md's auto-loaded canon (arrives free) ·
`notes/MCPSpec.md` IN FULL · this file's sections "The run", "Fence law carried into every MCP
brief", "Environment traps", and this brief · the FOR A LATER READER section of
`notes/plans/fixes/vx-809-mcp-door-ergonomics.md` (R-825, the two-store catalog, the scope-word
idiom) · `notes/mcp-invisibility-residuals.md` (35 lines — the complete leak ledger; your work
must add NOTHING to it) · `Sources/VariorumCore/Queries/Trash.swift`'s `originalsStrandedBy` and
its test suites (the VX-654 rewrite: MATERIALIZED + CROSS JOIN, neighbourhood-confined walks,
library-growth pins — the binding precedent for every CTE you write) ·
`Sources/VariorumMCP/MCPNoteStructure.swift`'s lineage code (the existing one-hop `with_lineage`
on `read_note` and its beyond-grant stub, P-13nb-U4-7) · the two-store catalog test (grep the MCP
test targets for the catalog; it holds ~209 arms and your new tool adds its own).

**Deliverables.**
1. **The note-level lineage-peers query** (new `Queries` home, e.g. `Queries/Lineage.swift`):
   for a note, the notes its blocks connect to over LIVE `derived_from` edges (both directions)
   and `version_of` edges — per peer: the peer note id and the connecting block pairs with
   `origin_op` and direction. DIRECT (one-hop at block level) is the proposed scope — transitive
   note-chains stay out of the wire answer; PROPOSE before building if the evidence argues
   otherwise. Live blocks, live notes; tombstoned edges and dead peers absent.
2. **The block-level lineage TREE query** (U3 consumes it; lands now with pins): transitive
   ancestors + descendants over `derived_from` plus `version_of` siblings for ONE block —
   per node: block id, the connecting edge's `origin_op`, direction, depth, a state
   classification (placed in note X · preserved as lineage (live, unplaced; `last_container_id`)
   · in the Trash), and the display text resolvable (chosen/default take). Cycle-guarded
   (defensive — the vx-654 pins cover dangling + cyclic rows). Bounded to the block's own
   neighbourhood; cost never corpus-proportional (P1).
3. **VX-817's wire tool** at the READ rung — proposed name `list_note_lineage` (final name is the
   orchestrator's at your proposal gate). Takes `note_id` or `note_ids` (1–200, no repeats,
   exclusive — VX-812's list-form idiom; each item its OWN read decision and once-grant spend,
   P-809-12; an unreachable subject answers the one not-shared shape as that item's result).
   Per subject: `copies`, `originals`, `versions` — each entry a readable peer note (id, title,
   wing_id) with its block-pair edges and origins. **The fence, binding (her 2026-11-04 audit
   line, on the ticket):** an edge appears ONLY when BOTH ends are within the client's read
   reach — a hidden peer is simply absent, never counted, never hinted; `beyond_reach` carries
   the fixed notes-form sentence, ALWAYS present. Private/daily-Journal keys win through the one
   grant rule. R-825 catalog arms: the answer byte-identical between a store where hidden peers
   exist and one where none do. Schema enforcement (VX-606) at the call door; Activity in words;
   the tool description per VX-197's conventions; `MCPSession.instructions` is NOT edited (the
   3,100-char budget is full; the description teaches the tool).
4. **MCPSpec draft delta lines** appended to this file under "DRAFT CANON DELTAS" (the
   orchestrator lands them at closeout; you never edit MCPSpec).

**One required reconciliation, before the tool builds:** read `MCPNoteStructure.lineage`'s
beyond-grant stub discipline exactly (when does a stub appear, what does a dead or missing far
side show, how do the catalog's existing arms hold it to R-825) and state it in your record. The
NEW tool follows the ticket's both-ends-readable line (absent, never a stub). If you find the
existing stub and R-825 genuinely collide, FLAG it to the orchestrator and build nothing on that
edge — ruled canon is never silently changed (the VX-825 precedent: colliding ruled lines go to
her).

**Propose-then-build (the architect's gate):** before writing the tool face, send the
orchestrator a SHORT proposal — the tool name, the answer shape (keys, one example), the
one-hop-vs-transitive call, and whether `note_ids` rides — then build to the ruling.

**Evidence (the unit's acceptance):** exact-rows pins for both queries across: a divide chain,
a merge, an extract, a pool copy, a duplicate (`version_of`), cross-note, cross-wing, a
tombstoned edge (excluded), a dead block, an archived take's block, a released original, a cycle;
a library-growth P1 pin (the query's cost flat as unrelated corpus grows — `originalsStrandedBy`'s
pin style); the wire tool's arms in the headless MCP harness including its two-store catalog
arms and the list-form arms. Headless `swift test` only — no stage. Tests run at the unit's END.

**Constraints:** no schema change, no `Sync/`, no custody. One agent; at most one Sonnet
subagent for EXTERNAL facts only, read-only. Commit per piece with LIVE STATUS in this file
(U1 RECORD section you create), push after every commit, foreground waits only
(`grep -q … && break; sleep 5` polls). Work only in `~/dev/variorum-vx-827`.
