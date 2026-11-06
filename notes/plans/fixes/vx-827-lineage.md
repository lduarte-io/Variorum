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
before asking for the merge GO. **Declared with vx-878 (2026-11-05):** its batch 3 (VX-874, the
trail's three-state dial) and our VX-778 both touch the Settings ▸ MCP pane files (the Features/
Settings MCP pane + MCPPaneCopy), on top of the registry/MCPToolCatalog/two-store-arms overlap.
Agreement: VX-778 stays NARROW — the count's predicate (count places that still stand, or say
"N grants"), no Clients-tab row-rendering restructure; if the U2 implementer finds the fix must
restructure row rendering, the orchestrator messages vx-878 BEFORE that half builds. The second
merger re-runs the pane suites + CapabilityRegistryTests + ShellChromeTests on its merged tree.

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

## U1 RECORD — the shared lineage queries (leg 1: deliverables 1–2 + the reconciliation + the deliverable-3 proposal)

*Implementer: opus-implementer, fresh session, 2026-11-05. Headless only (`swift build` / `swift test`
on the package; no stage, no xcodebuild test, no GUI, no store touches). This leg builds deliverables
1 and 2 and PROPOSES deliverable 3; the wire tool is NOT built until the orchestrator rules.*

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| U1-0 | Preflight read (CLAUDE.md canon · this file's The run / Fence law / Environment traps / U1 BRIEF · MCPSpec IN FULL · vx-809 FOR A LATER READER · mcp-invisibility-residuals · Trash.swift `originalsStrandedBy`/`strandedOriginals` + `LineageReadP1Tests` · `MCPNoteStructure` lineage/parents/farSides · the two-store catalog + arms · `MCPCarriageServerTests`' stub pin · P-13nb-U4-7's ruling text in the 13n-b record · `Queries/Lineage.swift` · `versionHistoryPredicate`) | DONE |
| U1-1 | The note-level lineage-peers query + its pins (`6046e48a7`) | DONE — 11/11 green; P1 pins red-on-naive verified |
| U1-2 | The block-level lineage-tree query + its pins (`f5b33af76`) | DONE — 10/10 green; P1 pins red-on-naive verified |
| U1-3 | The P1 pins (library growth, own-lineage linearity, plan) for both | DONE (inside U1-1/U1-2) |
| U1-4 | The reconciliation read of `MCPNoteStructure.lineage`'s stub (below) | DONE — **FLAG F-U1-1: the stub and R-825 genuinely collide** (probe-proven); nothing built on that edge |
| U1-5 | The deliverable-3 proposal (below) | DONE — **HELD for the orchestrator's ruling**; the wire tool is NOT built |

**Next (on the orchestrator's word):** rule on the PROPOSAL (P-U1-a…g below) and carry F-U1-1 to her; then build
`list_note_lineage` to the ruling + its catalog/list-form/VX-606 arms + the DRAFT CANON DELTAS; then the unit's END
suites (core lineage family + the MCP overlap suites + the two-store catalog).

### What landed (deliverables 1 and 2)

**`Queries.lineagePeers(db, noteID:) -> [LineagePeer]`** — `Sources/VariorumCore/Queries/LineagePeers.swift`.
Per peer note: `noteID`, `wingID`, `archivedAt`, `links: [LineageLink]` (`blockID` · `peerBlockID` · `relation`
`derived_from` (the peer holds an ORIGINAL) | `derived_into` (the peer holds a COPY) | `version_of` · `originOp` ·
`edgeID` · `at`); convenience `holdsAnOriginal` / `holdsACopy` / `isAVersion`. The rule as built: ONE HOP at the
block level; both ends LIVE and PLACED; the peer a live POST other than the subject; a pool is never a peer; a saved
version (born archived — AppSpec §9's letter "`archived_at == created_at` is the version classifier") is never a peer;
a domain-archived note IS a peer and carries its stamp; a tombstoned edge is absent whatever killed it. Reach-blind
(the wire's fence goes on top). Order: peers by note id; links in the subject's placement order, then peer block id,
then relation. Cost: `mine` (the note's placements, `idx_cblock_order`) MATERIALIZED, every join CROSS JOIN-driven —
`idx_edge_source`/`idx_edge_target`, `uq_cblock_ownership`, PKs.

**`Queries.lineageTree(db, blockID:, calendar:) -> LineageTree?`** — `Sources/VariorumCore/Queries/LineageTree.swift`
(U3's read). `origin` + `nodes` (ancestors by (depth, id), then descendants by (depth, id), then `version_of`
siblings by id) + every admitted `edges`. Per node: `blockID`, `direction` (origin · ancestor · descendant ·
version), shortest `depth`, `via` (the edge from the smallest-id neighbour one level nearer, then the smallest edge
id; `originOp` reads it), `state` (`placed(containerID)` · `preserved(lastContainerID)` · `archived(lastContainerID)`
· `deleted(deletedAt, lastContainerID)` · `missing`), `home` (container id, kind, DisplayTitle name, wing, deleted?,
saved version?), `shownTakeID` + `text` (placed: chosen if live/active/on the block, else default; unplaced: default;
deleted: the default as it died with it — the Trash's rule). nil when no block row has the id; a DELETED origin
answers. Walks: one-column `UNION` sets (each node once — terminates on any cycle; never the depth-carrying square),
MATERIALIZED + CROSS JOIN; depths/`via` by a breadth-first pass in Swift over the fetched edges.

**My readings, recorded (none invents product behavior; each is the orchestrator's to overturn):**
- **R-U1-1 — the tree's edge admission:** an edge is lineage when LIVE or tombstoned on the EXACT stamp of one of its
  endpoint blocks (the delete cascade) — `versionHistoryPredicate`'s edge fence verbatim in meaning. The brief asks
  for both "in the Trash" nodes AND "a tombstoned edge (excluded)"; the cascade tombstones EVERY edge of a deleted
  block, so without this rule no node could ever be "in the Trash". An edge taken apart on its own
  (`unmarkPostsAsVersions`, `removeVersionOf`, sync debris) is excluded. Note the deliberate difference from the
  Trash's own walk (`strandedFamilyWalk` reads past ALL tombstones — a family clock needs history; a navigable
  surface with acts needs restore-coherent edges). Put back revives the edges and the tree reads them live (pinned).
- **R-U1-2 — an ARCHIVED block is its own state** (`archived`), never "preserved as lineage": 13j batch 6's ruling
  (a set-aside she chose; its road is the tray's Put back, not `placeBlock`). U3's Put back must branch on it.
- **R-U1-3 — `version_of` siblings are the ORIGIN's only** (the brief's "plus version_of siblings for ONE block"),
  depth 1. Extending to every tree node stays neighbourhood-bounded if U3's design wants it.
- **R-U1-4 — the note-level family excludes released originals on BOTH sides** (one hop between PLACED blocks): a
  divide-W's or merge's released original joins neither note (pinned). The note's own released originals stay
  `read_note` `with_lineage`'s.
- **R-U1-5 — no depth cap on the tree:** cost ∝ the block's own lineage component, `originalsStrandedBy`'s posture;
  U3's glance popover (immediate parents/children) can filter depth 1 from the same read. If U3 needs a bounded read
  for an ambient surface, that's a U3 question (the popover is summoned, not held).

### Evidence (headless, this leg)

- `LineagePeersTests` — "✔ Test run with 11 tests in 1 suite passed": a divide chain across three notes (N↔P↔Q, N and
  Q never meet), released originals join neither note, an extract moved across wings (the wing named), a pool copy
  is no peer, a duplicate (every block `derived_into` 'manual' + the ONE `version_of` anchor) and Copy to Wing (the
  other wing) with a saved version excluded, a tombstoned edge / dead block / dead note absent, an archived take's
  block present, an archived note present with its stamp, an archived (set-aside) block absent, a hand-built cycle
  (one link each way), nothing for no lineage / an empty note / a missing id. P1: library ×15 **661 → 661** VM
  instructions; 20 → 60 links 1935 → 5575 (×2.9, linear); no store-table SCAN in the plan.
- `LineageTreeTests` — "✔ Test run with 10 tests in 1 suite passed": a divide chain up and down (depths, `via`,
  homes, texts, edges exact), a merge's sources and a divide-W's original preserved with their texts, an extract
  across wings + a pool copy (pool home), a duplicate's block as descendant AND version sibling + a saved version's
  block (`isSavedVersion`), the Trash in the tree (cascade-stamped edges, walked through, a deleted origin answers,
  Put back revives the edges) vs an edge taken apart (debris stamp; unmarked versions), an archived chosen take's
  fallback to the default + an archived block's `archived` state, a hand-built cycle through the origin (ancestor
  AND descendant) + a dangling id (`missing`, walked through) + an id with no row → nil. P1: seam history 20 → 60
  rounds **6436 → 18676** (×2.9); library ×15 **3376 → 3376**; no store-table SCAN from either end with a deleted
  block in the history.
- **Red-on-naive, each verified by a named mutation and restored by `git checkout --` (`git status` clean):**
  (1) peers rewritten edge-driven (`versionPeerPosts`' shape, `edge e JOIN container_block mine ON mine.block_id IN
  (…)`) → `theReadNeverScansAStoreTable` RED (`SCAN e USING INDEX uq_edge_live`) and `theReadDoesNotGrowWithTheLibrary`
  RED (library ×15: **3060 → 35540**); every exact-rows pin green on both (answers unchanged). (2) the tree's ancestor
  walk carrying DEPTH in the recursion (`anc(id, depth)` — the VX-654 square) → `theTreeGrowsWithTheSeamHistory…` RED
  (**26295 → 198255**, ×7.5) and the hand-built cycle never TERMINATED (the run was killed after ~5 min at 99% CPU —
  the cycle guard is load-bearing, not defensive decoration). (3) the tree un-MATERIALIZED with plain JOINs →
  `theTreeNeverScansAStoreTable` RED (`SCAN e` ×2) and `theTreeDoesNotGrowWithTheLibrary` RED (library ×15: **4308 →
  9908**).
- Lineage family on the committed tree (`--filter 'Lineage|TrashLineage|VX653|VX670'`): core "✔ Test run with 63
  tests in 11 suites passed"; MCP target "✔ Test run with 2 tests in 2 suites passed".

### U1-4 — the reconciliation read: `MCPNoteStructure.lineage`'s beyond-grant stub (P-13nb-U4-7)

**The discipline as built** (`Sources/VariorumMCP/MCPNoteStructure.swift` `lineage` / `farSides` / `parents`; the
ruling text `notes/plans/phase-13n-b-mcp-door.md` P-13nb-U4-7 + AF-11 F-4's RIDER): `read_note` `with_lineage` reads
each page block's DIRECT LIVE edges (`derived_from` both ways, `version_of`) and classifies the far block for this
client: placed in THIS note → `{relation, block_id, origin_op, at}`; a released original of this note (unplaced,
`last_container_id` = this note) → `+ released: true, text`; placed in one of the family's saved versions →
`+ version_id`; placed in another note the client can READ (`MCPGrantAuthority.decide(…, rung: .read, consumes:
false)`) → `+ note_id`; **anything else live — an unreadable note (ungranted, Private, the daily Journal's, another
wing's), ANY pool, a released original of another note — → the ONE stub `{"beyond_grant": true, "relation": r}`**
(no id, title, kind, origin_op or stamp). A DEAD or missing far block is OMITTED ("the lineage walks' live-endpoint
rule"; in practice the delete cascade has already killed the edge). Take ancestry mirrors it, except that a dead or
missing parent block collapses INTO the stub (`parent_beyond_grant: true` — the F-6 amendment: omission there would
mint a liveness oracle). The RIDER's stated reason for a stub over omission: *"omission would lie about the tree's
completeness, a distinguishable stub would open an oracle."*

**How the catalog holds it to R-825: it does not reach it.** The catalog's one lineage arm (`read_note · card,
everything`) reads `card`, which has no edge to any hidden block in store A (the hidden half mints with
`createPost`/`newBlock` only), so its `lineage` is `[]` in A, B and C alike. The stub's only pin is
`MCPCarriageServerTests.lineageAndAncestryAreExactAndBeyondTheGrantIsOneUniformStub` — fenced = unshared = scrap,
byte-identical, **"none omitted"** asserted.

**FLAG F-U1-1 — the stub and R-825 GENUINELY COLLIDE (for edges; the parent stub does not).** Probe (throwaway, never
committed — `Tests/VariorumMCPTests/U1StubProbeServerTests.swift`, deleted after the run): two stores built the same
way, store A alone holding her Duplicate of a shared note (the copy lands ungranted in the Pool); the same client
with a READ grant on the shared note calls `read_note` `with_lineage`. Store A's block answers
`"lineage":[{"beyond_grant":true,"relation":"derived_into"},{"beyond_grant":true,"relation":"version_of"}]`; store
B's answers `"lineage":[]` — **"U1-PROBE identical: false"**. Mechanism: the edge is a row of its own whose far end is
hidden; the stub speaks it (one per edge — so it COUNTS hidden copies, and it vanishes when the hidden copy is deleted,
since the cascade kills the edge: a liveness signal on a hidden block), while a store without the hidden copy has no
row to speak. That is exactly what R-825 forbids ("nothing on the wire may vary with what the client cannot reach")
and what VX-817's audit line names for edges ("a hidden copy is simply absent, never counted, never hinted"); the
P-13nb-U4-7 RIDER rules the opposite ("omission would lie about the tree's completeness"). Both are ruled canon —
MCPSpec's law paragraph names R-825 and, in the same sentence family, "down to the byte-identical beyond-grant
lineage stub (P-13nb-U4-7)" — and `notes/mcp-invisibility-residuals.md`, her one-place ledger "of those
impossibilities", does NOT list it (so either the ledger is incomplete or the stub is an unrecorded leak). The parent
stub (`parent_beyond_grant`) is NOT a collision: it answers a reachable take's own non-null parent pointer that does
not resolve within reach, identically for hidden, dead and missing parents (F-6 made it so). **Per the brief and the
VX-825 precedent: nothing built on that edge; ruled canon not changed; this goes to her.** Options for her (my
recommendation first, the spec-defensible one under her later, general law):
  (a) RETIRE the edge stub: `with_lineage` omits an edge whose far side is unreadable, exactly VX-817's line, and the
      RIDER's completeness worry is answered by the fixed-scope-words idiom — an always-present `beyond_reach` on a
      `with_lineage` answer ("Lineage beyond your reach, if any, is not listed." — wording hers); re-pin
      `lineageAndAncestry…` (stubs → absent) and add the A/B arm to the two-store catalog (a hidden copy of a
      reachable note in store A). The parent stub stays.
  (b) KEEP the stub as a recorded residual: add it to `notes/mcp-invisibility-residuals.md` as the seventh entry
      (it leaks a count and a liveness bit per edge — harder to square with "never counted" than residuals 1–6, which
      leak one bit each) and add the catalog arm as an enumerated exception.
  (c) COLLAPSE it: one fixed per-block marker ("some lineage is beyond your reach") — still one bit per block, never
      a count; a residual entry either way.
Until she rules, the NEW tool follows the ticket's line (absent, never a stub) and its own catalog arms prove it pure;
the two tools then disagree in shape on purpose, and the proposal below does not route through `farSides`.

### U1-5 — THE DELIVERABLE-3 PROPOSAL (held for the orchestrator's ruling; nothing built)

- **P-U1-a — name:** `list_note_lineage` (READ rung; `scopes` as `read_note`'s).
- **P-U1-b — scope: ONE HOP at the block level, between PLACED blocks** (`Queries.lineagePeers` as built). Why not
  transitive: a note-to-note chain N → H → Q passes through an intermediate note, and Q's presence would then depend on
  whether H exists — with H hidden that is a path through unreachable state, R-825's exact failure; one hop with BOTH
  ends readable is the only shape that is a pure function of reachable state without a per-path reach walk. Released
  originals stay out (R-U1-4); a client wanting the whole family of one block reads `read_note` `with_lineage` and
  follows readable `note_id`s.
- **P-U1-c — `note_ids` RIDES** (1–200, no repeats, exclusive with `note_id` — VX-812's list-form idiom; "which notes
  have copies elsewhere?" in one call is the ticket's ask): each item its own read decision and once-grant spend
  (P-809-12), its own Activity line; `results` answers each id in order — the single call's answer, or `{note_id,
  refused}` with the one not-shared sentence; a call where every item refused is an error answer (VX-812's rule).
- **P-U1-d — the fence:** the subject decided at READ through `MCPGrantAuthority.decide` (the fence keys win: the daily
  Journal's and ⌘J entries and the Private mark answer only a per-ask note grant); each PEER kept only when the same
  rule reads it (`rung: .read, consumes: false` — `farSides`' precedent, so a peer never spends a once grant); a peer
  the client cannot read is simply absent — never counted, never stubbed; `beyond_reach` ALWAYS present with the notes
  form, my draft "Notes beyond your reach, if any, are not listed." (P-809-1's family; wording hers).
- **P-U1-e — the answer (single form):**
  ```json
  {"note_id": "N", "title": "Drafts",
   "copies":    [{"note_id": "P", "title": "Draft, again", "wing_id": "",
                  "links": [{"block_id": "n1", "peer_block_id": "p1", "origin_op": "divide", "at": "2026-11-05T…"}]}],
   "originals": [],
   "versions":  [{"note_id": "P", "title": "Draft, again", "wing_id": "",
                  "links": [{"block_id": "n1", "peer_block_id": "p1", "origin_op": "manual", "at": "…"}]}],
   "beyond_reach": "Notes beyond your reach, if any, are not listed."}
  ```
  `copies` = peers holding `derived_into` links, `originals` = `derived_from`, `versions` = `version_of`; a peer sits
  in every bucket it has links for, each entry carrying only that bucket's links (a duplicate is in `copies` by every
  block and in `versions` by its one anchor). Peers in note-id order, links in the subject's block order (the Core
  read's — no position key on the wire, A-809-13). The edge id is NOT sent (the door names no edge ids today). An
  archived peer is LISTED and marked `"archived": true` (lineage is a fact about a reachable note, not a facet
  listing — omitting a reachable archived copy would make "which notes have copies elsewhere?" lie); the
  alternative, `include_archived` defaulting out like the listings, is the orchestrator's if preferred.
- **P-U1-f — cost:** per item ∝ the note's placed blocks + their direct edges + one batched facts read for its peers
  (`Queries.mcpNoteFacts`) — never the corpus; ≤ 200 items.
- **P-U1-g — the rest as the brief:** VX-606 schema enforcement at the call door; Activity in words ("‹client› read
  the lineage of “N”" / "…of 3 notes"); the description per VX-197 (says one hop, both ends readable, what each bucket
  means, that a once grant covers one item, that `read_note` `with_lineage` reads one block's direct edges);
  `MCPSession.instructions` NOT edited; catalog arms: a reachable note with a hidden copy in store A (Pool, Private
  note, another wing, the daily Journal entry), a hidden subject, a list mixing readable and hidden ids, a readable
  cross-wing peer; the coverage test forces the tool in.

**Open, gating nothing in this leg:** F-U1-1 (hers); P-U1-a…g (the orchestrator's); R-U1-1…5 (recorded readings,
the orchestrator's to overturn).

## U1 ADJUDICATION (the orchestrator, 2026-11-05 — repo-first, before the continuation)

**Verified:** commits c0cad8fd3 · 6046e48a7 · f5b33af76 · f9f53d92b on origin; tree clean;
the two pin suites re-run independently — 21/21 green, the library pin printing ×1 661 / ×15 661.

**R-U1-1…5 — ALL SUSTAINED.** (1) the exact-stamp cascade fence is `restoreBlock`'s own
philosophy — without it no Trash node could exist, and an independently-dead edge staying out
honors tombstone-means-decided; (2) archived ≠ preserved per 13j — U3's Put back branches on it;
(3) version siblings for the origin only keeps the tree one block's family; (4) the wire's peers
are placed notes — a released original is no "elsewhere"; (5) no depth cap — the walk is bounded
by the family and the cycle guard is pinned load-bearing.

**P-U1-a…g — SUSTAINED, with one call made here:** archived peers are ALWAYS listed, marked
`"archived": true`, no `include_archived` argument — lineage answers a family fact and an omitted
archived original would un-answer the agent's question; the app's archived-behind-facets listing
convention argues the other way, so this is **PROVISIONAL (joins bundle #264)**. No edge ids and
no position keys on the wire (VX-859's lesson) — confirmed. All-items-refused answers as an error
(VX-812's landed-nothing rule) — confirmed.

**F-U1-1 — TO HER (two ruled lines collide: P-13nb-U4-7's stub vs R-825).** Ruling recorded
below when it lands.
