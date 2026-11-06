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
| 1 | U1 — lineage queries + VX-817 wire + the F-U1-1 stub retirement | DONE (c0cad8fd3…40b8f417a; adjudications below) |
| 2 | U2 — VX-810 + VX-815 + VX-778 (rider, her kickoff pick) | DONE (22c3a5a89…06113a96c; adjudication below) |
| 3 | VX-801 design pass (5 mockup rounds + 2 explorations) | DONE — THE DESIGN MEMO settled at the exploration sitting |
| 4 | U3a — the Commits face | DONE (fc8880a53…dc7fde0e5; adjudication below) |
| 4b | U3b — the Lineage face + origin re-aim + panel retirement | DONE (654cf3469…; U3b RECORD below) |
| 5 | Ladder (whole diff) | ROUND 1 DONE (0 BLOCKER/MAJOR, 2 MINOR, 3 NIT — dispositions below); fix leg + round 2 pending |
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
| U1-6 | LEG 2: the stub retirement in `read_note` `with_lineage` — absent + the fixed sentence — + the A/B catalog arm + the re-pin (`08c12ede2`; revert announced `3c2f7a416`) | DONE — red on the reverted stub (catalog arm + carriage pin), green on the fix; restored, tree clean |
| U1-7 | LEG 2: `list_note_lineage` + its server suite + six catalog arms + the coverage justified edits + the Activity words (`bf6eadad8`) | DONE — 3/3 + catalog green; the both-ends fence red when the peer filter is removed |
| U1-8 | LEG 2: DRAFT CANON DELTAS (D-U1-1…4, at the end of this file) | DONE |
| U1-9 | LEG 2: the END suites + self-assessment (below, "LEG 2 — END") | DONE — green but for the standing socket-timing trio, green alone |

**Leg 1 and leg 2 CLOSED (2026-11-05).** U1 is built and pinned; what remains of the unit is the run's (the one ladder over the whole diff after U3; the canon landing at closeout; the App-target suites and the public guide page — below).

**ANNOUNCED BEHAVIORAL REVERT (U1-6's red-on-old, before it runs):** on the committed `08c12ede2`, the
working tree's `MCPNoteStructure.swift` will be put back to the OLD lineage behavior ONLY — the
`.beyondGrant` arm appending `{"relation": r, "beyond_grant": true}` again, and no `beyond_reach` key —
with every new pin kept; the two-store catalog and the carriage suite run; then `git checkout --
Sources/VariorumMCP/MCPNoteStructure.swift` restores the fix and `git status` must read clean. Expected:
the catalog's `read_note · kin with lineage …` arm RED (A ≠ B) and the re-pinned carriage test RED.

### LEG 2 — what landed (the continuation: her F-U1-1 ruling + the sustained proposal)

**The stub retirement (`08c12ede2`).** `MCPNoteStructure.lineage`'s `.beyondGrant` arm now `continue`s — an edge
whose far side the client cannot read is ABSENT, exactly as a dead far side always was; the per-edge
`beyondGrant(_:)` helper is gone. `MCPNoteStructure.read` sets `beyond_reach` =
`MCPWriteTools.beyondReachLineageWords` ("Lineage beyond your reach, if any, is not listed." — her ruling's exact
words, HELD FOR HER #264) whenever `with_lineage` is asked, before the page is fitted (the budget weighs it; a
version read gets it too); never on any other form. `parent_beyond_grant` untouched. `read_note`'s description: "a
relative outside what you can read is left out, and beyond_reach says so — a take's parent you can't read shows only
parent_beyond_grant". Pins: the two-store catalog's NEW arm `read_note · kin with lineage (hidden relatives in the
Pool, a Private note, a hidden wing, the Journal)` — `kin` is a new reachable note in the shared book with a READABLE
Copy to Wing copy in Studio (all three stores); store A's hidden half gives kin her Duplicate (`tags: .none`, Home's
Pool, ungranted) and version links to the Private member, the hidden wing's note and the Journal entry (edges and a
copy only — no reachable row changes); and `MCPCarriageServerTests.lineageAndAncestryAreExactAndBeyondTheGrantIsAbsent`
(renamed; justified edit — the three unreadable far sides absent, no `"beyond_grant"` anywhere, the sentence present
only when lineage is asked, `parent_beyond_grant` kept). **Red-on-old by the announced behavioral revert** (the stub
append restored and the `beyond_reach` line removed, every new pin kept, on the committed `08c12ede2`): the catalog
arm RED — "varies with what the client cannot reach", A's first block answering five `{"beyond_grant":true,…}`
(the Pool copy's `derived_into` + four `version_of`) beside the readable Studio copy's two entries, B the readable two
alone — and the carriage pin RED (4 issues); "✘ Test run with 17 tests in 2 suites failed … with 5 issues";
restored by `git checkout --`, `git status` clean; on the fix "✔ Test run with 17 tests in 2 suites passed".

**`list_note_lineage` (`bf6eadad8`).** `MCPToolCatalog.listNoteLineage` (READ, `everyScope`, in `read`),
`MCPReadTools.listNoteLineage` / `noteLineage` (in `MCPReadTools.swift`, beside `read_note` — its private helpers),
exactly P-U1-a…g + the archived call. Readings recorded (the orchestrator's to overturn): (i) the list form keeps
VX-812's keys verbatim — `results`, `landed_count`, `refused_count` — "landed" reading as "answered" for a read; (ii)
`archived` is an ALWAYS-PRESENT boolean on every peer entry (`list_books`' shape; true when archived); (iii) a peer's
`wing_id` is the rule's resolved wing (`NoteFacts.wingID` — a dangling wing reads Home, the listings' rule); (iv) a
peer's `title` is `mcpScopeTitle`'s (`read_note`'s title rule); (v) Activity words in `MCPPaneCopy` (Mac target):
"reading the lineage of ‹note›" (refused) / "read the lineage of ‹note›" (landed) — PROVISIONAL, #264. Pins:
`MCPListNoteLineageServerTests` (3) and six catalog arms (kin beside its hidden relatives, kin's Studio copy and its
original, a hidden subject, the Journal entry, a mixed list, an all-hidden list → error). Justified edits (the
ritual — the catalog grows): `MCPServerTests` (the read-rung set; a book grant's listed tools),
`MCPWriteServerTests` (a suggest grant's listed tools; the every-door-that-names-a-note call list). **The fence's
red-on-mutation** (on the committed `bf6eadad8`: the peer reach filter replaced by "every peer"): the server suite
RED (5 issues — hidden peers listed, their ids in the text) and the catalog RED (`list_note_lineage · kin …`: "a
hidden id crossed" + "varies with what the client cannot reach"); restored, tree clean.

### LEG 2 — END (the suites, on the committed `d766d9363`; headless)

**Not done in this leg, said first:** no App-target TEST run (no stage — the MCP pane's every-tool Activity-words pin,
W-UX-13, and the rest of `VariorumTests` are owed to the run's closing window); no whole core-package run (this unit's
core changes are two ADDITIVE files); no edit to MCPSpec, SurfaceContracts or AppSpecRecord (D-U1-1…4 are drafts);
the public guide page (stargazing.tech/variorum/mcp) is outside the repo — if it describes `with_lineage`'s
`beyond_grant`, it needs her word at closeout.

- Core lineage family (`--filter 'Lineage|TrashLineage|VX653|VX670'`): "✔ Test run with 63 tests in 11 suites
  passed"; the MCP target's matches "✔ Test run with 5 tests in 3 suites passed".
- **The whole MCP test target** (`--filter VariorumMCPTests`): "✘ Test run with 617 tests in 115 suites failed after
  53.626 seconds with 4 issues" — ALL FOUR the standing socket-timing trio, named: `MCPStopRoadsServerTests
  .aQuitSaysNothingForAConnectionItEnds` and `.aClientThatLeftBeforeTheQuitKeepsItsOwnLine` ("got no answer to its
  initialize"), `MCPDiscoverProbeServerTests.claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes`
  (`socket.nextResponse()`), `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`
  (past 15 s) — the vx-809 record's NO-VERDICT family under a loaded run; the three suites re-run ALONE: "✔ Test run
  with 14 tests in 3 suites passed". Every other suite green, including the two-store catalog (now with seven U1
  arms), `MCPUndeclaredArgumentsServerTests` (VX-606 walks the new tool), `MCPWireNeutralityTests`,
  `MCPAdviceServerTests` (the instructions untouched), `MCPListWingsServerTests`, the carriage and the new suite.
- App target COMPILE only (allowed without the stage): `xcodebuild -scheme Variorum -destination 'platform=macOS'
  -configuration Debug build-for-testing` → "** TEST BUILD SUCCEEDED **" (the `MCPPaneCopy` words compile); then
  `Tools/verify-pins` → OK both graphs (16 + 15 pins); `git status` clean.

**Self-assessment (the implementer's, before the ladder):**
- *Confident:* both queries' rules and costs (exact rows over every named shape; each P1 claim red on a named naive
  form); the stub retirement's mechanism and its pin (red on the announced revert, byte-identical across stores on the
  fix); the new tool's fence (red when the peer filter is removed; the Private and Journal keys beat a Home WING
  grant in the server suite; hidden = missing per list item).
- *Watch in review:* (1) the catalog's new reachable note `kin` joins the shared book and its Copy to Wing copy lands
  in Studio, so several existing arms' answers changed in ALL stores alike (the B == C control and A == B held on
  every arm; nothing was re-baselined by hand); (2) the list form reuses VX-812's `landed_count` for a READ (a
  naming reading, recorded); (3) `archived` is an always-present boolean, not a key present only when true;
  (4) `noteLineage` holds the writer for its item (`read_note`'s once-stamp posture) — ∝ the note's blocks and edges
  plus one title read per readable peer; (5) the tree's admission rule (R-U1-1) is the one place the new reads
  deliberately differ from the Trash's walk.
- *Owed by others:* the App-target suites in the closing window; her wordings (#264: the two scope sentences, the
  Activity words, the archived-peers call); the closeout's canon landing (D-U1-1…4); U3 consumes `lineageTree`.

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

**F-U1-1 — HER RULING (2026-11-05, in session, the question-tool batch): "Retire the stub".**
The per-edge `beyond_grant` stub retires: a lineage far side the client can't read is simply
ABSENT from `read_note`'s `with_lineage` answer; a fixed, always-present scope sentence rides the
lineage answer instead (the P-809-1 family — "Lineage beyond your reach, if any, is not listed.",
exact wording HELD FOR HER in bundle #264); re-pinned, plus the A/B two-store catalog arm that was
missing (the arm that caught this stays as the pin). The parent stub is untouched (no collision).
P-13nb-U4-7's contract line gets its supersession delta in MCPSpec at closeout; the residuals
ledger gains NO row (that is the point).

## DRAFT CANON DELTAS (U1 — drafted by the implementer; the orchestrator lands them at closeout, two-file rule; MCPSpec is not edited here)

**D-U1-1 — `notes/MCPSpec.md`, the fence sentence (P-13nb-U4-7's supersession).** In "**The fence (VX-163's keys, 13n-c
U1 …):** … everything unreachable answers ONE uniform not-shared shape — no fenced-vs-unshared oracle anywhere, for
BOOKS too (F-7), down to the byte-identical beyond-grant lineage stub (P-13nb-U4-7); …", replace the clause from "down
to" through "(P-13nb-U4-7)" with:

> … for BOOKS too (F-7); **a lineage far side beyond reach is ABSENT from `read_note`'s `with_lineage` (VX-827 — her
> F-U1-1 ruling, "Retire the stub", superseding P-13nb-U4-7's per-edge `beyond_grant` stub; the record
> `notes/plans/fixes/vx-827-lineage.md`): an edge is spoken only when both its ends are readable, and a `with_lineage`
> answer always carries `beyond_reach` — "Lineage beyond your reach, if any, is not listed." (PROVISIONAL wording,
> #264); a take's parent beyond reach still answers the one `parent_beyond_grant` stub, the same for a hidden, a dead
> and a missing parent**; …

**D-U1-2 — `notes/MCPSpec.md`, the new tool (a contract line; suggested home: after the `list_wings` sentence in "THE
PRE-LAUNCH SWEEP'S MCP TRIO", or as its own bolded sentence beside the VX-336 wire tools):**

> **`list_note_lineage` (VX-817 — the VX-827 run; the record `notes/plans/fixes/vx-827-lineage.md` U1, P-U1-a…g):** a
> READ-rung tool answering the other notes a note is joined to by ONE live edge between their live, placed blocks
> (`Queries.lineagePeers` — `derived_from` either way, `version_of`; a released original, a pool and a saved version
> are never a peer): `copies` (a peer's block derived from the note's), `originals` (the note's derived from a
> peer's) and `versions` (a `version_of` link), each peer with `note_id`, `title`, `wing_id`, `archived` (an archived
> peer always listed, marked — PROVISIONAL, #264) and its `links` (`block_id`, `peer_block_id`, `origin_op`, `at`); no
> edge id and no position key crosses. The subject is decided at READ by the one rule (`read_note`'s decision, ask
> and once spend); a PEER is kept only where the same rule reads it, never spending a grant — **an edge appears only
> when BOTH its ends are within reach** (her VX-817 line): a peer beyond reach is absent, never counted or hinted,
> and `beyond_reach` always says "Notes beyond your reach, if any, are not listed." (PROVISIONAL wording, #264). One
> hop only: a chain through another note is never followed. `note_ids` (1–200, no repeats, exclusive with `note_id`)
> reads each note as the single call — VX-812's list form (`results`, `landed_count`, `refused_count`; a once grant
> covers one item; an all-refused list an error answer). ∝ each note's placed blocks and their direct edges, never
> the corpus. Activity speaks it in words.

**D-U1-3 — `notes/SurfaceContracts.md`, Doors (optional, the orchestrator's call):** after "`list_wings` lists the
wings the client holds a standing wing grant on, a granted empty wing included.", add: "`list_note_lineage` lists the
notes one edge away from a note — copies, originals, versions — only where both ends are readable (VX-817)."

**D-U1-4 — `notes/AppSpecRecord.md` (the dated entry's narrative, closeout):** her F-U1-1 ruling verbatim ("Retire the
stub"), the probe's two answers (leg 1, U1-4), the A/B arm as the pin that was missing, and the supersession of
P-13nb-U4-7's RIDER reasoning ("omission would lie about the tree's completeness") by R-825's fixed-scope-words idiom.

**`notes/mcp-invisibility-residuals.md`: NO ROW** (her ruling: "that is the point").

**D-U2-1 — `notes/MCPSpec.md`, `list_notes` by tag + the richer rows (VX-810; suggested home: right after
"`list_notes(book_id)` carries the book's chapters."):**

> **`list_notes` takes `tag` (VX-810 — the VX-827 run; the record `notes/plans/fixes/vx-827-lineage.md` U2):** a
> tag's PATH in every tag tool's form (a leading `#` tolerated; one that names no path refuses at the call door in
> `remove_tag`'s sentence), read in the listing's own wing — a book's or a gathering's, `wing_id`'s; the bare form in
> every wing — and matched as the rule grammar matches a tag term (the tag and its subtree), worn on the note itself
> or on a live block it places (`Queries.notesWearingTag` — THE ONE wearer rule `tag_unused_in_reach` reads; a snippet
> never); it filters the listing's own source, every row still through the one rule, paged by that listing's own
> cursor; a path no readable note wears — naming nothing, worn only beyond reach, an unreachable wing's — lists
> NOTHING (the empty listing, byte-identical; never a refusal). ∝ the tag's wearers (a book's: its members), never
> the corpus. **Every row carries `entry_date` (`null` when undated — VX-758's rider) and `tag_ids` + `tags`** (the
> tags the note itself wears, by path — the Level 0 header's; a block's tags are the block's); **`read_note`'s JSON
> forms carry `tag_ids` + `tags`** on every page, on the live read only (a saved version's read carries neither, as
> it carries no `books`).

**D-U2-2 — `notes/MCPSpec.md`, the empty note (VX-815; suggested home: after the "Paged `read_note` (VX-256)"
sentence):**

> **An empty note says it is empty (VX-815 — the VX-827 run U2):** a TEXT form of a note INSIDE reach — `read_note`'s
> Level 0 (a lens's too), a saved version's text, `export_note` — whose answer would hold nothing (empty, or only the
> format's block breaks) answers ONE sentence naming it ("“‹title›” is an empty note — nothing is written in it
> yet."; a saved version's "This saved version of “‹title›” is empty — nothing was written in it." — PROVISIONAL,
> #264) in place of the empty string, which is the core's own read of a note that does not exist; a titled or tagged
> empty note keeps its header (an empty body); the JSON forms already said it (`blocks: []` beside the title); the
> fence's one byte-identical not-shared shape is untouched (hidden = missing).

**D-U2-3 — `notes/MCPSpec.md`, the pane's count (VX-778):** in "The pane: per-client grant rows (counts say
"grants")", replace the parenthesis with: "(counts say "grants" and count only grants whose place still stands — a
gone one, Revoke-only in Shared with AI, counts nowhere: VX-778)".

**D-U2-4 — `notes/SurfaceContracts.md`, Doors (optional, the orchestrator's call):** beside D-U1-3's line, add:
"`list_notes` takes a tag path and lists the readable notes wearing it or a tag under it, on the note or a block;
its rows carry each note's own tags and entry date (VX-810)."

**D-U2-5 — `notes/AppSpecRecord.md` (the dated entry's narrative, closeout):** VX-815's trace as recorded (U2-2 —
the nothing-shape is the core's tolerant read; the wire's fence was never byte-identical with it, so that half is
stated as a control, not a red-on-old); the P1 lesson (U2-3 — a plain JOIN let SQLite walk every post through
`idx_container_kind`, a SEARCH that is a corpus scan; the plan pin counts it as one); VX-778's Deny consequence and
its options (U2-6).

**FOR #264 (the U2 items — the orchestrator lands them at the merge; each built as its (a)):**
- **P-U2-1 — the empty-note sentences** (U2-5): (a) [built] "“‹title›” is an empty note — nothing is written in it
  yet." / "This saved version of “‹title›” is empty — nothing was written in it."; (b) one title-less fixed sentence
  for every empty text read; (c) the Level 0 form keeps an empty answer and only `export_note` speaks.
- **P-U2-2 — what counts as "holds nothing"** (U2-5): (a) [built] empty or only line breaks (blank blocks are no
  words; a header or a space is something); (b) only the exactly empty answer; (c) any whitespace-only answer.
- **P-U2-3 — Deny's confirm after VX-778** (U2-6): (a) [built] it names what the row names (standing places only);
  (b) a third `gone` count so it names every row the press revokes (an `MCPDoor`/`MCPPane` edit — vx-878's files);
  (c) the row also says "· K gone".
- **P-U2-4 — a saved version's JSON read carries no tags** (U2-4): (a) [built] neither key, as `books`; (b) the
  version container's own tags (`[]` in practice); (c) the live note's tags.
- **P-U2-5 — rows show the note's OWN tags while the filter also matches a block's** (U2-4): (a) [built] as said in
  the description; (b) rows also list the tags the note's blocks wear (a separate key); (c) the filter matches note
  tags only.

## U1 LEG-2 ADJUDICATION (the orchestrator, 2026-11-05)

**Verified:** commits 08c12ede2 · bf6eadad8 · d766d9363 · 40b8f417a on origin, tree clean;
`MCPListNoteLineageServerTests` re-run independently, 3/3 green. The four red MCP-target tests are
the standing socket-timing trio + one (the VX-722/VX-532/VX-850 class, green alone, named in the
vx-809 record) — accepted as the known flake class, NOT this unit's.

**Leg-2 readings 1–5 ALL SUSTAINED:** (1) VX-812's list-form keys verbatim, `landed_count`
meaning "answered" on a read — idiom consistency wins; the word flagged to #264; (2) `archived`
boolean on every peer entry (rides the existing #264 PROVISIONAL); (3) a dangling wing reads Home
(R-13ia-2); (4) titles through `mcpScopeTitle`, the one road; (5) the Activity wordings
PROVISIONAL #264, hers to re-cut.

**Carried to the ladder's attention (the implementer's own watch list, kept verbatim in its
record):** the `kin` fixture's effect on existing catalog arms (controls held, nothing hand
re-baselined); the R-U1-1 edge-admission difference from the Trash walk; `noteLineage` holding
the writer per item. **Owed to the closing window:** the App-target suites (W-UX-13 included);
her #264 wordings; the canon landing (D-U1-1…4); whether the public MCP guide page describes
`beyond_grant` on `with_lineage` (checked at closeout; her word if it does).

## U2 BRIEF — VX-810 + VX-815 + VX-778 (the read-ergonomics batch)

**Read first (in full):** CLAUDE.md's auto-loaded canon · `notes/MCPSpec.md` WHOLE · this file's
sections "The run", "Fence law carried into every MCP brief", "Environment traps", the U1 RECORD's
DRAFT CANON DELTAS (your answers build beside U1's shapes), and this brief · the FOR A LATER
READER of `notes/plans/fixes/vx-809-mcp-door-ergonomics.md` · `notes/mcp-invisibility-residuals.md`
· the three member tickets' descriptions (quoted in "The run") · `Sources/VariorumMCP/
MCPReadTools.swift` + `MCPToolCatalog.swift` + the two-store catalog test before touching answers.

**Deliverable A — VX-810, ALL THREE FACETS (ruled by the orchestrator under the ticket's
"the run picks"):**
1. `list_notes` takes an optional tag filter — match the EXISTING tag tools' argument convention
   (read `apply_tag`/`remove_tag`/`replace_tag` first; if the convention is genuinely ambiguous,
   PROPOSE before building this facet). Subtree matching exactly as the rule grammar does; the
   wearers are the post-level and block-level UNION (a block tag counts through its block's
   placement); wing-scoped as `list_notes` already is; reach-scoped through the one rule; paged
   as `list_notes` pages; cost ∝ the rows listed, never the corpus. A tag id/path naming nothing
   the client can know follows the fence (hidden = missing — one worded refusal or empty listing,
   whichever the existing listing idiom speaks; state your pick in the record).
2. `list_notes` rows gain `tag_ids` + `tags` (paths, the mint answers' pairing) and `entry_date`
   (null when undated — the VX-758 rider, the ticket's 2026-11-05 amendment).
3. `read_note`'s JSON forms gain the note's `tag_ids` + `tags`.
   Existing pins change bytes — justified re-pins only, named one by one in your record; the
   two-store catalog's A/B and B==C controls must hold untouched (nothing hand re-baselined).
**Deliverable B — VX-815.** TRACE FIRST: why does an empty granted note read as the nothing-shape
today (which form, which code path)? Then the fix: a note INSIDE reach that is empty answers
HONESTLY (title, metadata, empty body — the normal read's shape with empty content, or the
minimal honest sentence if the Level 0 text form needs one; any minted sentence is HELD FOR HER
in #264). The fence's byte-identical hidden-and-missing shape is UNTOUCHABLE — the pin: the
granted-empty answer and the fence answer stop being byte-identical, while hidden vs missing
stays byte-identical (red on old by behavioral revert, announced before it runs).
**Deliverable C — VX-778, PREDICATE-NARROW (the vx-878 agreement, binding):** the Clients tab's
"N shared places" count overstates reach (gone places count). MCPSpec already says counts say
"grants" — verify that line against the pane; align the count to what the listing shows or to
"N grants", whichever the trace supports; NO Clients-tab or Shared-with-AI row-rendering
restructure. If the fix cannot stay predicate-narrow, STOP that half and report — the
orchestrator messages vx-878 before anything wider builds. Pin the count's source headlessly
where it lives; if only a Mac-target test can pin it, WRITE the pin and leave its run to the
closing stage window (compile-only verify now: `xcodebuild build-for-testing`).

**Evidence (the unit's acceptance):** headless core + MCP suites at the unit's end (name every
failing test; the socket-timing trio is the known class); the catalog arms for every changed
answer; VX-815's two byte-pins red-on-old; VX-778's pin red-on-old; `Tools/verify-pins` OK;
App target compile-only green. NO xcodebuild test, no stage, no GUI, no store.

**Constraints:** no schema change, no `Sync/`, no custody, no cursor changes (`list_notes`' book
cursor is VX-808's — VX-859); `MCPSession.instructions` untouched; draft canon delta lines
appended to DRAFT CANON DELTAS (you never edit MCPSpec). One agent; at most ONE Sonnet subagent
for EXTERNAL facts, read-only. Pull the branch first — U1's work is on origin. U2 RECORD section
with LIVE STATUS from the first commit; commit per piece ending "Part of VX-<member>"; no
trailers; push every commit; foreground waits only.

## U2 RECORD — VX-810 + VX-815 + VX-778 (the read-ergonomics batch)

**NOT DONE in U2, said first:** no App-target TEST run (no stage — U2 touched no App file; U1's owed Mac pins stand for
the closing window, and no new Mac pin was needed: VX-778's count lives in core and is pinned there); no edit to
MCPSpec, SurfaceContracts, AppSpecRecord or QUESTIONS (D-U2-1…5 and P-U2-1…5 are drafts for the orchestrator); the
public MCP guide page (stargazing.tech/variorum/mcp, outside the repo) may want `list_notes`' `tag`, the richer rows
and the empty-note sentence — her word at closeout; the stale "N shared places" wording in `MCPDoor`/`MCPPaneCopy`
COMMENTS (vx-878's files) left as is.

*Implementer: opus-implementer, fresh session, 2026-11-05. Headless only (`swift build` / `swift test` on the
package, `xcodebuild build-for-testing` for the App target's compile); no stage, no xcodebuild test, no GUI, no
store touches.*

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| U2-0 | Preflight read (CLAUDE.md canon · this file's The run / Fence law / Environment traps / U1 RECORD + DRAFT CANON DELTAS / U2 BRIEF · MCPSpec WHOLE · vx-809 FOR A LATER READER · mcp-invisibility-residuals · the three tickets' full descriptions · `MCPReadTools.swift` whole · `MCPToolCatalog.swift`'s read rung + `apply_tag` / `remove_tag` / `replace_tag` / `create_note` · `MCPWriteTools+RemoveTag` / `+TagReplace` · `MCPNoteStructure.read` · the two-store catalog + its arms · `TagQueries` / `TagUsageQueries` · `mcpGrantReachCounts` / `mcpGrantInertFence` / `mcpGrantPlaceTitle` + the pane's client row) | DONE |
| U2-1 | A — the tag filter's argument convention (the proposal gate) | DONE — NOT ambiguous (below); no proposal sent |
| U2-2 | B — VX-815's TRACE (a throwaway probe, never committed) | DONE — below |
| U2-3 | A — core: the tag-wearer listing + batched note tags, with exact-rows and P1 pins | DONE — 7/7 + the shared brain's suites green; both P1 pins red on the naive join (below) |
| U2-4 | A — `list_notes` `tag` + rows' `tag_ids`/`tags`/`entry_date` + `read_note` JSON's `tag_ids`/`tags`; server suite; catalog arms; justified re-pins | DONE — 6/6 server + the catalog (10 new arms) green; the arms red on the fence mutation (below); ONE justified re-pin |
| U2-5 | B — VX-815's fix + its byte-pins (red by announced behavioral revert) + catalog arms | DONE — red exactly as announced on the revert, green on the fix (below) |
| U2-6 | C — VX-778's predicate + its pin (red-on-old) | DONE — red on the pre-fix tree, green on the fix; predicate-narrow, no App file touched |
| U2-7 | Draft canon delta lines (appended to DRAFT CANON DELTAS) + the #264 items | DONE — D-U2-1…5, P-U2-1…5 |
| U2-8 | END: headless core + MCP suites, `Tools/verify-pins`, App compile-only; self-assessment | DONE — below |

### U2-1 — the tag filter's argument (the proposal gate: NOT ambiguous)

Every tag tool on the wire takes ONE argument `tag`, a PATH string (`apply_tag`, `remove_tag`, `replace_tag`'s
`tag`/`with`; `create_note`'s `tags` is its array form): `TagPath.segments` normalization, a leading `#` tolerated,
an empty result refused at the call door in the one sentence ("tag must be a tag path — names joined by /, e.g.
"percy/pt-en"."), the path resolved in a WING (`remove_tag`: the note's live wing, else Home). No tool takes a tag
id as an argument. So `list_notes` takes `tag` (a path) in exactly that form — built without a proposal. How the
path resolves for a LISTING (the one place the convention needs a reading): in the listing's own wing — `wing_id`'s
wing, a book's or gathering's wing (`Queries.wingScope`, so Home also holds a dangling wing's, as `list_notes`
lists notes there) — and, for the bare form (every note shared, across wings), in every wing; the subtree exactly
as the rule grammar's (`Queries.tagSubtree`: the root by id, its wing's tags under its path).

### U2-2 — VX-815's TRACE (why an empty granted note reads as "nothing")

Probe (throwaway `Tests/VariorumMCPTests/U2EmptyProbeServerTests.swift`, deleted, never committed): a READ book
grant; an untitled empty note, a titled empty note and an untitled note with one blank block in the book; a hidden
note and an id naming nothing outside it. Answers on the pre-fix tree:

| call | untitled empty | titled empty | one blank block | hidden | missing |
|---|---|---|---|---|---|
| `read_note` (Level 0 text) | `""` | `{t:"An empty one"}` | `""` | refusal¹ | refusal¹ |
| `read_note` `with_ids` | `{"blocks":[],"books":[…],"note_id":…,"title":"2026-06-30"}` | the same shape, titled | one block, its take `"text":""` | refusal¹ | refusal¹ |
| `export_note` | `""` | `""` | `""` | refusal¹ | refusal¹ |

¹ `isError: true`, "That note isn't shared with this client, or doesn't exist. The author can share it from
Variorum ▸ Settings ▸ MCP." — byte-identical for hidden and missing (the fence holds).

**The mechanism.** The TEXT forms answer the core's document read verbatim: `read_note`'s Level 0 is
`Queries.variorumDocumentText` (`MCPReadTools.readNote`, the `else` arm), `export_note` is `Queries.renderedText`.
For a note with no title, no tags and no words, the document is the EMPTY STRING — and the empty string is exactly
the core's TOLERANT READ of a note that does not exist ("A missing or tombstoned note reads as an empty document",
`Queries.variorumDocument`): the nothing-shape. So a granted empty note answers byte-for-byte what the store would
answer for nothing at all; the agent's "looks exactly like a note I can't reach" is that nothing. **What the trace
does NOT support:** the WIRE's fence answer was never byte-identical with it — the fence speaks its refusal sentence
flagged `isError` — so a pin "granted-empty ≠ the fence answer" is GREEN ON BOTH SIDES (recorded as a control, not
as the fix's red-on-old). The with_ids form is already honest (title, books, `blocks: []`). The red-on-old pin is
therefore stated against the nothing-shape the trace found: the granted empty note's text answers stop being
byte-identical with `Queries.variorumDocumentText` of an id naming nothing (`""`), while the fence's hidden-vs-
missing answers stay byte-identical (the untouchable control — green on both sides by design).

### U2-3 — the core reads (VX-810's source)

- **`Queries.notesWearingTag(db, path:, wingID:)`** (`Queries/TagUsageQueries.swift`, beside the ONE brain): the live
  tags at exactly `path` (`Queries.liveTagIDs` — one wing as surfaces read it, Home also holding a dead wing's; nil =
  every wing; one `uq_tag_path_live` probe per wing), each one's subtree by `Queries.tagSubtree` (the rule grammar's
  — the root and its own wing's tags under its path), and every live POST wearing a subtree tag by THE ONE wearer rule
  — `tagWearersSQL`, HOISTED byte-for-byte out of `tagSubtreeIsWorn`'s `.reach` walk so the listing and
  `remove_tag`'s `tag_unused_in_reach` read one text (on the note itself, or a live block it places; a snippet never).
  Reach-blind, distinct, by note id.
- **`Queries.wornTags(db, noteIDs:)`** (`Queries/TagQueries.swift`): many notes' OWN live tags at once (`postTags`
  batched — the header's tags, never a block's), each note's by path then id; `WornTag(id, path)`.
- Pins (`Tests/VariorumCoreTests/TagWearersListingTests.swift`, "✔ Test run with 7 tests"; with the shared brain's
  `TagUsageQueriesTests` + `UnusedTagsTests` "✔ Test run with 22 tests in 3 suites passed"): itself vs a placed
  block, a snippet / deleted block / dead note / removed application out; the subtree (parent lists child wearers,
  never the reverse; a segment prefix and a bare child name are no path; a dead tag's path holds nothing); the path in
  one wing, in every wing, a dead wing's tags as Home's; `wornTags`' order, block tags out, agreeing with `postTags`.
- **P1, red on the naive form, verified by mutation and restored:** the first build joined `container` with a plain
  `JOIN` — SQLite then walked EVERY post through `idx_container_kind` (a SEARCH that is a corpus scan) probing an
  automatic index on the wearers: `theListingDoesNotGrowWithTheLibrary` RED (library ×15: **760 → 3560** VM
  instructions) and `theWearerReadNeverScansAStoreTable` RED (the plan pin counts a SEARCH by the post kind's index as
  a scan). With `CROSS JOIN` (the wearers drive; each probed by primary key — the VX-654 lesson): library ×15 **484 →
  484**; wearers 20 → 60: 1086 → 2806 (×2.6, linear); no corpus-table scan. (The SAME plain-JOIN outer shape in
  `tagSubtreeIsWorn`'s `.reach` walk was measured too, by a throwaway probe: flat, 526 → 526 at library 20 → 300 —
  its `WHERE wearers.id > :after … LIMIT` drives from the wearers — so it is NOT a finding and stays byte-unchanged.)

### U2-4 — VX-810 on the wire (what landed)

- **`list_notes` takes `tag`** (`MCPReadTools.listNotes` + `optionalTagPath`): `remove_tag`'s parse — a path, a
  leading `#` tolerated, `TagPath.segments` — and its one sentence, now a shared constant
  (`MCPWriteTools.tagPathWords`, byte-identical), refused at the call door BEFORE any read (nothing logged). Read
  only once the place is allowed: a BOOK's and a GATHERING's in the place's wing (`facts.wingID`), `wing_id`'s in that
  wing, the BARE form in every wing (`Queries.notesWearingTag`). The wearers then filter the listing's OWN source —
  `bookPage`'s members (`c.id IN json_each(:tagged)`; book order and cursor untouched, ∝ the book's members), the
  gathering's assembly (filtered before the slice, its id-resuming cursor untouched), `recencyPage`'s candidates
  (wing: `wingID` + candidates; bare: the wearers ARE the candidates — every note the rule reads is in the shared
  listing's sources, so the readable wearers are exactly its notes wearing the tag; pinned against the unfiltered
  listing) — and every kept row still passes the per-note rule, so a hidden wearer is absent exactly as unfiltered.
  **The fence pick (the brief asked me to state it):** a path naming nothing, a tag worn only beyond reach and a tag
  of an unreachable wing all answer the EMPTY LISTING — the listing idiom (a filter that matches nothing lists
  nothing); never a refusal, so nothing distinguishes a tag that exists from one that doesn't (pinned byte-identical
  in all three listing forms). No cursor shape changed (VX-859 stays VX-808's).
- **Rows** gain `entry_date` (the stored day; `null` — always present — when undated or blank) and `tag_ids` +
  `tags` (the note's OWN tags, `Queries.wornTags` batched per page; by path, the header's order — a block's tags are
  the block's, so a note listed through a BLOCK tag shows it in neither key; the description says both).
- **`read_note`'s JSON forms** (`MCPNoteStructure.read`) gain `tag_ids` + `tags` beside `books` — every page, as
  `entry_date` rides — on the LIVE read only: a saved version's read carries neither, exactly as it carries no
  `books` (my reading of "the note's tags": a version is a moment of the note and wears none of its own; the key is
  the live read's). The Level 0 text is unchanged (its header already says the tags).
- **Descriptions** (`MCPToolCatalog`): `list_notes` says `tag` (the path, the subtree, a note or one of its blocks,
  the wing it is read in, a path no readable note wears lists none) and every row key; `read_note` names `tag_ids`
  and `tags`; the schema declares `tag` (VX-606 serves it, refuses the plural `tags` — pinned).
  `MCPSession.instructions` untouched.

**Pins.** `MCPListNotesByTagServerTests` (6 — "✔ Test run with 7 tests in 2 suites passed" with the re-pinned guard):
the listing's own wing / the subtree / the post+block union / the fence in a book, a wing, a gathering and the bare
form; the bare tagged listing == the unfiltered listing's wearers, same order; worn-only-beyond-reach == naming
nothing, byte for byte, in all three forms; `///` refused in the one sentence, unlogged; paging by each cursor ==
the unpaged answer; every row's `tag_ids`/`tags`/`entry_date` (null present); `read_note`'s with_ids, both pages,
the version read without the keys; VX-606's `tag` served and `tags` refused. **The two-store catalog** — 10 new
`list_notes · … tag …` arms in the read block (the shared book and its page, the bare form and its page, Studio
#idea, the gathering's #idea, #secret-topic, a hidden wing's path, a path naming nothing, a hidden wing's listing),
store A's hidden half gaining hidden WEARERS only (the shared book's Private member wears #board, the secret note's
BLOCK wears #board, the attic note its own #attic-topic — applications on hidden notes, no reachable row changes):
A == B and B == C on every arm, nothing hand re-baselined; every existing arm's answer grew the new keys in all
three stores alike. **Red on the fence mutation** (the walk's rule skipped for tagged listings — `decision.isAllowed
|| tagPath != nil`, restored by copy, `grep` clean): the catalog RED on 7 of the new arms, each naming the hidden
wearer's id that crossed ("✘ Test run with 8 tests in 2 suites failed … with 17 issues").

**Justified re-pins (one by one):**
1. `MCPReadFormsUnchangedServerTests.everyFormWithoutTheNewAsksIsByteUnchanged` (`MCPPagedReadServerTests.swift`,
   G-256-1's golden guard — 4 expectations: with_ids, with_commits, with_lenses+with_tray, through a lens): VX-810
   DELIBERATELY grows every JSON form with `tag_ids` + `tags`; the golden note now wears `#draft` so the bytes pin
   both keys' place (sorted between `note_id` and `title`) and form. The Level 0 and export arms unchanged.
2. The catalog's hidden half (A only) gains the three applications above — fixture growth for the new arms, not a
   re-baseline (the catalog compares stores live; B == C held).

### U2-5 — VX-815: the fix, and THE ANNOUNCED BEHAVIORAL REVERT (written before it runs)

**The fix (committed with this paragraph).** `MCPReadTools.readNote`: after the allowed read's log line, a TEXT form
(`export_note`; `read_note` without `with_ids` and its implications — the Level 0 document, through a lens, a saved
version's text) whose answer `holdsNothing` (empty, or only the line breaks the format puts between blank blocks —
any header `{t:…}` / `{#…}` or other character is something) answers ONE sentence instead: `emptyNoteWords(title:)`
— "“‹title›” is an empty note — nothing is written in it yet." — or, for a saved version's text,
`emptyVersionWords(title:)` — "This saved version of “‹title›” is empty — nothing was written in it." (the read's own
title, `mcpScopeTitle`; BOTH PROVISIONAL, HELD FOR HER in #264). A titled or tagged empty note keeps its Level 0
header (the normal read's shape with an empty body); the JSON forms are untouched (already honest). The fence's
refusal roads all return BEFORE this line, so hidden = missing is untouched by construction. Descriptions:
`read_note` and `export_note` each say an empty note answers the sentence in place of empty text.
`MCPSession.instructions` untouched.

**ANNOUNCED BEHAVIORAL REVERT (before it runs).** On the committed fix, the working tree's `MCPReadTools.swift` will
be put back to the OLD behavior ONLY — the `if plain || !withIDs, Self.holdsNothing(text) { … }` substitution removed
(the helpers and sentences kept, so every pin compiles) — and `MCPEmptyNoteServerTests` + the two-store catalog run;
then `git checkout -- Sources/VariorumMCP/MCPReadTools.swift` restores the fix and `git status` must read clean.
Expected: `readNoteSaysAGrantedEmptyNoteIsEmpty` and `exportNoteSaysAGrantedEmptyNoteIsEmpty` RED (the granted empty
note's answers byte-identical with the nothing-shape `""`); the control `theFenceStaysOneShapeAndTheEmptyNoteIsNotIt`
GREEN (hidden = missing on both sides; the empty note never equalled the refusal — the trace); the catalog GREEN on
both sides (its three new empty-note arms answer the same in every store either way — they are R-825 arms, not the
fix's pin).

**The revert's result (ran on the committed `e672c14f5`, the substitution removed, every pin kept):** exactly as
announced — `readNoteSaysAGrantedEmptyNoteIsEmpty` RED (3 issues: the untitled empty note's Level 0 `==` the
nothing-shape `""`; the sentence absent; the blank-block note the same) and `exportNoteSaysAGrantedEmptyNoteIsEmpty`
RED (6 issues: all three empty notes exported `""`); the control `theFenceStaysOneShapeAndTheEmptyNoteIsNotIt` GREEN;
the two-store catalog GREEN ("✘ Test run with 6 tests in 2 suites failed … with 9 issues"); restored by `git checkout
--`, `git status` clean; on the fix "✔ Test run with 6 tests in 2 suites passed". **The two byte-pins, as the trace
allows them:** (1) granted-empty vs the NOTHING-SHAPE — red on old, green on the fix; (2) hidden vs missing — byte-
identical in the Level 0, with_ids and export forms, green on BOTH sides (the untouchable control; a pin that the
fix cannot move by construction). The brief's literal "granted-empty vs the fence answer" is green on both sides
(the fence always spoke its refusal) — recorded in U2-2, asserted in the control, not claimed as red-on-old.
**Catalog:** three new arms on a reachable EMPTY note (untitled, no blocks, under a READ note grant added to the
catalog's client — fixture growth, every store alike): `read_note · an empty note (text)` → "“2026-06-30” is an empty
note — nothing is written in it yet." · `… , with ids` → `{"blocks":[],"books":[],…,"tag_ids":[],"tags":[],"title":
"2026-06-30"}` · `export_note · an empty note` → the sentence; A == B, B == C.

### U2-6 — VX-778: the client row's count (trace, fix, pin)

**The trace.** MCPSpec's line — "per-client grant rows (counts say "grants")" — checked against the pane: the
Clients row's detail is `MCPPaneCopy.reads(liveGrantCount, inert: inertGrantCount)` → "1 grant" / "N grants", plus
"· M inert" (W-UX-10 already moved the noun off "shared places"; the ticket quotes the old words). So "say N
grants" is already the noun. The COUNT is the defect: `MCPDoor`'s client row reads `Queries.mcpGrantReachCounts`,
which classified each live grant by `mcpGrantInertFence` alone — and that answers nil for a GONE target (no note
facts, no book facts, a wing always nil, no gathering facts), so a grant on a deleted note, book, wing or gathering,
or a book grant on a reading that is a gathering again (VX-763's road), counted as REACHING — while Shared with AI
lists each as "(gone)", Revoke only (`mcpGrantPlaceTitle` nil, the predicate `MCPChangeOffer` reads). VX-771's O-6
named exactly this.
**The fix (predicate-narrow, core only — the vx-878 agreement held: no App file, no row rendering touched).**
`mcpGrantReachCounts` skips a grant whose place is gone by the listing's OWN gone predicate (`mcpGrantPlaceTitle ==
nil`) — counted as neither reaching nor inert. **The pin** (`MCPGrantPlacesTests.aGrantWhosePlaceIsGoneIsCountedNeither
ReachingNorInert`, headless core): three standing places + one inert, then five grants whose places go (deleted note,
book, wing, gathering; a book grant whose reading is a gathering again); Shared with AI lists all five gone; the
counts read (3, 1). **RED on the pre-fix tree** (the pin written first): "the client row counts only the places that
still stand — not (reaching: 8, inert: 1)" ("✘ Test run with 9 tests in 1 suite failed … with 1 issue"); on the fix
"✔ Test run with 65 tests in 7 suites passed" (`MCPGrantPlacesTests|MCPGrant`). No Mac-target pin was needed (the
count's source is core); the pane's existing pins (`MCPPaneTests`' `liveGrantCount == 8` over eight standing books;
`MCPGrantSheetTests`' Deny words) read standing places only and are untouched.
**One consequence, said plainly (PROVISIONAL, for #264):** Deny's confirm sums the same two counts
(`MCPPaneCopy.denyClientDetail(grants: live + inert)`), so it too stops naming a gone place's grant — it now names
what the row she just read names; Deny still revokes the gone rows (they leave Shared with AI). Options: **(a)
[built]** as is — the confirm agrees with the row; **(b)** a third count (`gone`) carried on `MCPDoor.ClientRow` so
the confirm names every row the press revokes — an `MCPDoor` + `MCPPane` edit (vx-878's batch-3 files; NOT built,
outside the narrow agreement); **(c)** the row also says "· K gone" — a rendering change, out of scope.

### U2 — END (the suites, on the committed `50f6953e7`; headless)

- **The whole package, headless** (`swift test`, every target): core "✔ Test run with 3817 tests in 518 suites passed
  after 262.268 seconds with 5 known issues" (the standing known-issue set); a further target "✔ Test run with 32 tests
  in 4 suites passed"; **the MCP target** "✘ Test run with 627 tests in 117 suites failed after 56.990 seconds with 4
  issues" — ALL FOUR the socket-timing NO-VERDICT class under a loaded run, named:
  `MCPStopRoadsServerTests.aClientThatLeftBeforeTheQuitKeepsItsOwnLine`,
  `MCPDiscoverProbeServerTests.claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes`,
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (past 15 s) and
  `MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds(_:)` (`.clientHangsUp` — its PREMISE failed:
  "every session's initialize was answered (1 not)"). The five socket suites re-run ALONE (with
  `MCPPreInitializeWindowTests`, red once in a mid-unit run): "✔ Test run with 24 tests in 5 suites passed". Every
  other suite green — the two-store catalog (now with U2's 13 arms), `MCPUndeclaredArgumentsServerTests`,
  `MCPListNotesByTagServerTests`, `MCPEmptyNoteServerTests`, the re-pinned golden guard, `MCPAdviceServerTests` (the
  instructions untouched), the shared brain's `TagUsageQueriesTests`/`UnusedTagsTests`, `MCPGrantPlacesTests`.
- **App target COMPILE only** (no stage needed): `xcodebuild -scheme Variorum -destination 'platform=macOS'
  -configuration Debug build-for-testing` → "** TEST BUILD SUCCEEDED **".
- `Tools/verify-pins` → OK both graphs (16 + 15 pins); `git status` clean.

**Row dispositions.** VX-810 — BUILT (all three facets; feature pins + 10 catalog arms red on the fence mutation; one
justified re-pin). VX-815 — FIXED (the trace's nothing-shape pinned red by the announced revert; the literal "≠ the
fence answer" half green on both sides — recorded, asserted as a control, never claimed). VX-778 — FIXED (red on the
pre-fix tree; predicate-narrow, core only; its Deny consequence to #264 as P-U2-3).

**Self-assessment (the implementer's, before the ladder):**
- *Confident:* the wearer read's rule (one text with the shared brain) and its cost (the library pin flat, red on the
  naive join by measurement and by plan); the tagged listings' fence (every catalog arm pure, red when the walk's rule
  is skipped); VX-815's mechanism and that the fence is untouched by construction (every refusal returns before the
  substitution; hidden = missing pinned in three forms); VX-778's predicate is the listing's own.
- *Watch in review:* (1) the BARE tagged listing reads the wearers as its candidates instead of `sharedPage`'s
  sources — sound only while every grant kind's reach is in the sources (pinned: the tagged listing == the
  unfiltered listing's wearers, same order; a future grant kind must keep both); (2) a tagged BOOK listing walks the
  book's members filtering by `IN json_each` — ∝ the book, not the page; (3) `liveTagIDs` probes Home + the `wing`
  rows, so a tag naming a wing id with no row at all is missed (no op mints one; said in its doc); (4) the rows' `tags`
  are the note's own while the filter also matches a block's (the description says both; P-U2-5); (5) the catalog's
  new reachable `empty` note (a READ note grant) and the hidden half's three applications changed several existing
  arms' answers in all stores alike — A == B and B == C held, nothing re-baselined; (6) VX-778's Deny-confirm
  consequence (P-U2-3).
- *Owed by others:* the closing window's App-target suites; her #264 words and calls (P-U2-1…5); the canon landing
  (D-U2-1…5); the public guide page.

## U2 ADJUDICATION (the orchestrator, 2026-11-06 — after independent verification)

**Verified:** commits 22c3a5a89…06113a96c on origin, tree clean; the new suites re-run
independently (TagWearersListingTests 16/16 incl. the flat library pin; the filtered MCP/core
set 19/19 green). The core's "5 known issues" are Swift Testing's expected-failure standing set
on a PASSED run; the MCP target's four reds are the standing socket-timing class, named in the
record, green alone — accepted, not this unit's.

**Sustained:** the no-proposal call (every tag tool takes `tag` as a path — the convention was
not ambiguous); VX-810's fence pick (a path naming nothing, a tag worn only beyond reach and a
hidden wing's tag all answer the SAME empty listing, never a refusal — the listing idiom, hidden
= missing); VX-815's pin honesty — the briefed "granted-empty ≠ fence" red-on-old was IMPOSSIBLE
(the fence was always a worded refusal; the empty read was `""`), so it stands as a green control
while the CHANGE (the says-it's-empty sentence) is pinned red-on-old by announced revert — the
ticket's substance is delivered; VX-778 as built with the P-U2-3 Deny-confirm consequence
(option (a); (b) touches vx-878's files and was rightly not built) — PROVISIONAL #264.

**Carried to the ladder's attention:** the tagged BOOK listing costs ∝ the book's members (bounded
by membership, never the corpus — a deliberate flag, not a verdict); the wearers-equality premise
pin; the `kin`/`empty` fixtures' effect on existing catalog arms (controls held, nothing hand
re-baselined). **BORN-TICKET CANDIDATE (filed at closeout):** `Queries.liveTagIDs` misses a tag
whose wing id names no wing row at all — no operation creates one today (Low, Suspected, Debt).
**P-U2-1…5 join bundle #264.**

## THE CLOSING WINDOW'S TERMS (nov5, 2026-11-06 — binding on whoever runs it)

Queued with nov5: app-target batch (~45 min) FIRST, then ping nov5 "SEAM" before the walk's Debug
launch (a merge-gating run may slot in; otherwise carry on under the same claim), then the
lineage-door walk (~20 min). Walk etiquette: dismiss What's New after the Debug launch; the dev
store stays signed out; Resume never pressed; Castle values only from `~/.variorum/dev-castle.env`
if the lock screen is met; at RELEASE say the dev-store posture left. RELEASE line: executed
counts per suite and EVERY failing test by name (or "0 failures"), plus both strict instance
guards (`pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`) empty. READY goes to nov5 with a
claim name once the ladder closes. Merge planning: vx-808 carries the v1_37 schema event and its
deploy/release CLOSES the stage; it edited SearchPassagesTests (no known overlap with us); merges
serialize through nov5 — the second merger merges the first and re-runs the MCP overlap suites
(+ the pane suites + CapabilityRegistryTests + ShellChromeTests per the vx-878 agreement).

**Mockup v1 sitting (2026-11-05 evening, on the Air — her feedback verbatim-faithful, supersedes
v1's drawn shapes):** the glance is NOT a literal popup — *"when I said popup, I was kind of
imagining more that when you go into the block menu that already existed, that it would be
there… i do not think a literal popup is needed. at most it would be like the way takes looks."*
She asked whether the popup was already built — it is NOT (nothing of VX-801 is built; U1's
queries only). The redesign's center of gravity moves: *"i almost feel like the more relevant
issue for redesign is being able to easily see your commits, compare the commit to the current
take you're looking at, etc. it just looks crowded and hard to see"* (two Block History panel
screenshots attached in session). Layout: *"i also do not like the left to right scroll in the
whole area - that gets confusing. maybe we do a verticle scroll where older is above"*; *"think
about git - i know that shows with branches, but like I really do feel like we have to focus on
making the information easily accessible. showing compare, letting people look for commits on
previous takes of ancestor blocks easily is the goal - what would get us to that point?"*
Progressive disclosure ruled: *"i agree things can expand piece by piece - nothing at first,
then takes, then commits of those takes if you really want."* → v1's Q2 is ANSWERED (vertical,
older above, no horizontal scroll); Q3 ANSWERED (collapsed → takes → commits); Q1's popup arm is
DEAD (the door lives in the existing block menu / history door). Mockup v2 owed: ONE vertical
story surface whose rest state IS the glance, absorbing the Block History redesign question and
the commit-vs-now compare.

**Mockup v2 sitting (2026-11-05, on the Air):** RULED — *"yes - there should be one door for
block history. that makes a lot of sense."* (v2's question 1: this surface SUCCEEDS Block
History, one door). RULED — *"the immediate thing you see should be this particular block's
history - and it should be easy to see commits BY TAKE, archived takes, etc., and then you
should be able to also see lineage."* (the surface OPENS on this block — takes with their
commits, archived takes visible — lineage reachable second; v2's lineage-first vertical order is
dead). v2's face REJECTED: *"i still don't like this new mockup. i feel like it's a lot of words
and not very clear still."* Layout reopened: *"maybe the horziontal scroll was actually better,
it was actually a lot clearer at least."* Her process ask: *"start by clearly listing all the
info that needs to be shown and then let's think about for a complicated block what it would
look like."* → v3 direction: this-block-first; information inventory first; the horizontal
element may return as a bounded MAP (never whole-area scroll); takes as cards, not text rows.

**Mockup v3 sitting (2026-11-05):** direction accepted with corrections — *"ok i think that looks
better, but lineage should be something you have to expand / go into. the default should be just
seeing the commits."* The map band is NOT the default face; commits are. *"i know they're named -
you should also be able to scroll through the full text of any commit."* (full text readable in
place, scrollable — names alone insufficient). *"i think the fundamental issue is that you are
still not representing commits *per take* very clearly. maybe look at how the takes popup on
write looks for inspiration - each one should be able to go into the lineage."* *"maybe lineage
does need to be a separate door than "commits" still - that might be better if we can't figure
out something clear."* → v4 direction: the default view is COMMITS, one generous Takes-popup-
family card per take with its commits inside and full text expanding in place; lineage behind
its own step/door (the v3 map+log survives as that second view — "looks better" stands for it);
the one-door ruling softens to one surface family with a Commits face and a Lineage face, both
reachable from the block menu.

**Trial-merge heads-up (nov5, 2026-11-06):** origin/vx-827-lineage (1a66adce2) vs
origin/vx-808-arrivals-books (cc5e4fad0) CONFLICT textually in three files —
`Sources/VariorumMCP/MCPToolCatalog.swift`, `Tests/VariorumMCPTests/MCPServerTests.swift`,
`Tests/VariorumMCPTests/MCPWriteServerTests.swift` (both runs add wire tools: the tool list and
tool-count pins). Against vx-878 and vx-819 we merge clean today. Whichever run merges SECOND
resolves these three and re-runs the MCP server + catalog suites headless on the merged tree
(on top of the standing second-merger duties recorded above).

**Mockup v4 sitting (2026-11-05, ~21:05):** v4 REJECTED on visual clarity and density. Her words,
verbatim: *"ok like look at this mockup. think about what people are using this for - claude just
changed something. does it feel easy to look at commits? does it feel good?"* (said over two
REFERENCE mockups she attached — `<home>/shots/shot-20261105-210521.png`: a compact
"readme (draft) › takes" panel, the chosen take's text with red strikethrough washes and
"claude-code is editing…", beside a "history · this take" DOT TIMELINE — one line per commit,
name + relative date: "before claude-code's edit · now", "tightened · Oct 31", "first draft ·
Oct 30"; and `<home>/shots/shot-20261105-210542.png`: a "readme (draft) › compare"
two-pane before/after of claude-code's edit, removed words struck red on the left, added words
washed green on the right). Of v4 (`<home>/shots/shot-20261105-210749.png`): *"this
is not very clear visually at all."* Her instruction: *"have 2 opus subagents, make them each
make a mockup, with what neesd to be there and every round of my feedback verbatim, with new
directions. we need to explore other things like this does not look good still and it is not
dealing with density well."* → TWO Opus design agents spawned in parallel (her explicit word —
the one-at-a-time default is hers to lift), each with the information inventory, the full
verbatim feedback trail (this file's sitting entries), the three shots, and a DISTINCT direction
seed: A = the timeline spine (commits as the primary object, one dot line, takes as facets);
B = the reference's own panel shape (one text pane + one history rail, diff washes, compact).
The AI-edit use case leads both briefs: "claude just changed something" — note the door's
edit_take bracket already mints the "before/after ‹client›'s edit" commits the reference names.

**The two explorations landed (2026-11-05 ~21:2x, both on the Air):** A = the timeline spine
(`explore-A-timeline.html` — one dot line, newest top, take chips filter; the heavy fixture is
12 lines at rest; Today/This week grouping; the AI pair one line with inline changed words;
lineage behind the one door reusing v3's map). B = the panel grown (`explore-B-panel.html` — one
text pane + one rail, ever; the switcher swaps the rail; opens pre-marked against "before
claude-code's edit"; drawn at panel and full-column widths). Each page carries the inventory and
her verbatim feedback trail collapsed up top. BOTH agents' reports converge on ONE decisive
question for her: does history open on ALL takes in one line (A's rest state) or on THE take
you're in with the rest a press away (B's shape, her reference's "history · this take")?
Flagged provisional calls riding the pages: A — the inline change preview, Restore on an
archived take's commit only after Unarchive, the "branched from" footer; B — opening pre-marked
against the AI's before-commit, rail newest-top vs family older-above.

**Window term added (nov5, 2026-11-06 — after vx-808 launched a sibling worktree's stale build):**
the walk's Debug launch comes from THIS worktree's OWN DerivedData, never the newest-modified
one — pick the `~/Library/Developer/Xcode/DerivedData/Variorum-*` dir whose `info.plist`
`WorkspacePath` sits inside `~/dev/variorum-vx-827/` (PlistBuddy prints it), or better the
explicit `-derivedDataPath` the build used; launch `Build/Products/Debug/Variorum.app` from that
dir and NAME the launched product path in the RELEASE line.

**The exploration sitting (2026-11-05 ~22:03 — DIRECTION ACCEPTED; her words verbatim):** *"ok i
like these mockups a lot."* · *"these mockups are much better on the whole, it's a direction
that I like."* The composite she ruled: *"in the editing view, i'd want to see mockup A's B. The
edit, opened in place view of the edit, but with the small graph of commits with the take
dropdown that mockup B has next to it still"* (her screenshot = B's pane+rail with "plain ✓
chosen · 5 takes ▾"); *"(there should be room in the whole pane)"*. Compare: *"i think that the
side by side is nice, and i think that being able to switch what commits you are comparing is
also really nice."* Lineage: *"i like in mockup A how you can see the takes of the lineage block
easily, but i also like mockup B's verticle view of the history. let's make it so that when you
select an ancestor block, you can still click on its various takes & commits easily, as in A,
but with the verticle view instead of the horizontal scroll, as in B."* Three-box compare:
*"i think being able to open 3 commits would be helpful (before claude, after claude, now), is
just one example. or maybe instead of a third commit, always being able to show "now" as the
third compare box option."* Browsing: *"i also feel like you should be able to preview or scroll
through the commit text without opening a named commit, or it could get tedious. maybe a fast
swapper would be enough of an answer there."* THE DECISIVE QUESTION: *"i think that showing all
takes on one line is better - sometimes multiple takes will have changed in a single pass
round."*

## THE DESIGN MEMO — the block's History & Lineage surface (settled at the exploration sitting; U3 builds to THIS)

**The doors (P-1, registry-declared).** The block menu carries History and Lineage rows; the
bottom bar's history word opens the Commits face. The surface takes the FULL pane; ‹ back
returns exactly where she was. The old Block History panel RETIRES — every door that opened it
opens the Commits face; all its jobs live here.

**The Commits face (the default).** Two regions in the whole pane:
- THE READING PANE (left, generous): the selected moment's full text, scrollable; header: the
  commit's name (or first words), when, its take + chip, quiet mark, "N changes since"; a
  plain · against-now wash toggle (word-level, view-time — OverallModel §8's legal diff; a pure
  Domain text-compare function with tests); acts at the foot: Restore · Bring back as take ·
  Compare · Rename.
- THE RAIL (right, narrow): B's vertical dot timeline, newest at top — defaulting to ALL TAKES
  INTERLEAVED (her ruling), each line dot · name/first words · its take's small chip · relative
  date; the take dropdown ("5 takes ▾", the Write takes-popup family, archived takes grouped)
  FILTERS to one take, whose rail then leads with the hollow "the take now" dot; quiet runs
  fold to one line; an AI bracket pair (before/after ‹client›'s edit) rides a quiet wash and
  never folds; the deleted takes line at the rail's foot (count · days left · Put back).
- THE FAST SWAPPER (her ruling): the pane FOLLOWS the rail — a click or ↑/↓ step swaps the
  pane's text instantly; reading never requires opening or naming anything.

**Compare.** Side by side, from any commit's Compare act: two boxes (the picked moment · now),
EACH box's header a swapper that can be re-aimed at any take's moment; "now" is ALWAYS offerable
as a standing third box (her before · after · now example). Word washes in the reference's
language (removed struck on the left family, added washed on the right).

**The Lineage face (behind its one door).** VERTICAL, older above, NO horizontal scroll
anywhere: the family as a list (origin verb · first words · where it lives · counts), this
block marked; selecting an ancestor swaps the SAME pane+rail composition to that block — its
take dropdown, its rail, its commits, A's two-click reach with B's geometry; Put back ·
Bring back as take · Compare with now on the selected node's header; a Trash node muted, no
acts; a cross-wing node named with its wing, go-to only.

**Edges already ruled elsewhere, binding here:** archived takes visible (dropdown group +
hollow dots); restore-from-Trash stays on its own surface; sentence case; the commit
vocabulary; P3 — the reading pane is a READ surface (no live editor on this face); the
registry-walk covers every door; seals refuse the writing acts through the existing operations.

**PROVISIONAL at build (joins #264):** the all-takes rail's handling of per-take "now" rows;
the exact keys of the fast swapper; the third-box door's wording; the AI-pair wash's exact
face; whether the pane opens pre-selected on the newest moment or on "before ‹client›'s edit"
after an AI edit (B's flagged call — lean: newest, which IS the after-bracket, with the before
one step down).

**U3 SPLITS IN TWO LEGS (sizing honesty, one unit per session):** U3a = the Commits face whole
(pane + rail + dropdown + fast swap + compare + the Domain diff function + registry + the
panel's retirement); U3b = the Lineage face (the vertical family, the ancestor swap, the acts
in the tree) + the mobile-parity note. The ladder still runs ONCE over the run's whole diff.

## U3a BRIEF — the Commits face (builds THE DESIGN MEMO's first half)

**Read first (in full):** CLAUDE.md's auto-loaded canon · this file: "The run", THE DESIGN MEMO,
every "Mockup/exploration sitting" entry (her words are the spec), "Environment traps" ·
`notes/SurfaceContracts.md` — The note and The app sections · `notes/TEXTKIT2_NOTES.md` (the
reading pane is read-tier work; if you touch `PaneSurface`, `EditorTextView`, `BlockRangeIndex`
or the read tier's seams, its rules bind) · the existing Block History implementation WHOLE
(find the panel, its every door — bottom bar word, block ▾, the inspector road VX-668 named, the
read-in-full sheet, VX-440's R-440-3 behaviors) · the exploration mockups `explore-A-timeline.html`
+ `explore-B-panel.html` + her composite screenshot `<home>/shots/shot-20261105-220337.png`
(the drawn target) · U1's `Queries/LineageTree.swift` (U3b consumes it; know its shape) · the
capability registry (P-1's home) before declaring doors.

**Deliverables:**
1. The Commits face exactly as THE DESIGN MEMO states it: reading pane + all-takes rail + take
   dropdown + the fast swapper + the rail foot's deleted takes. Full pane; ‹ back returns.
2. The pure Domain text-compare function (word-level spans between two given texts, view-time
   only, nothing stored — OverallModel §8's legal diff), its own test suite; the pane's
   against-now washes and Compare's washes both read it.
3. Compare: two boxes + the standing "now" third, each box's header a swapper; from any
   commit's Compare act.
4. The Block History panel's RETIREMENT: every door that opened it opens this face; its jobs
   (per-take commits, read in full, Restore, Bring back as take, Name/Rename, deleted takes +
   Put back) all live here; remove what nothing composes anymore. The commit vocabulary and
   every refusal stay the existing operations' — no new ops, no op changes.
5. Registry: the new/moved doors declared once; the registry-walk test extended and green.
PROVISIONAL leans (build these, log #264): open on the newest moment (after an AI edit that IS
the after-bracket, the before one step down); ↑/↓ as the swapper's keys; the memo's other
flagged items.

**Evidence:** the Domain diff suite; the registry walk; focused view-model coverage for the
face's projections (rail rows, folds, dropdown, swapper selection); every existing
Block-History-class pin re-pointed as a JUSTIFIED edit named one by one (nothing silently
deleted); headless core suites green at the unit's end; `xcodebuild build-for-testing` green.
Mac-target TEST RUNS are owed to the closing stage window, not this session — write the pins,
compile them, name them for the window. TutorialWalkTests must COMPILE; if any tutorial step
touches Block History, FLAG it before changing anything the tutorial walks.

**Constraints:** P3 — the reading pane is a READ surface, no second live editor, no new
liveness mechanism beside `PaneTextAuthority`; no `Sync/`, no custody, no schema, no MCP-door
changes; sentence case, the commit vocabulary; one agent, at most ONE Sonnet for EXTERNAL
facts; LIVE STATUS (U3a RECORD) from the first commit, commit per piece ending "Part of
VX-801", no trailers, push every commit, foreground waits only; work only in
`~/dev/variorum-vx-827` (pull first — U1/U2 and the memo are on origin).

## U3a RECORD — the Commits face (VX-801's first half)

**NOT DONE in U3a, said first:** no Mac-target TEST run and no walk (both owed to the run's closing stage window —
the suites and the twelve walk rows are named under "what is OWED"); the old Block History PANEL is NOT deleted —
the origin door still opens it (gate G2, left as it was for U3b); the tutorial's Came-from sentences are NOT
reworded (gate G1, flagged — owed when the Lineage face lands); no "lineage ›" door on the face (U3b's); no
canon delta (SurfaceContracts' Block History bullet, the AppSpecRecord entry) and no QUESTIONS edit — the #264
items are P-U3a-1…11 below, for the orchestrator at the merge; no mobile change (the phone's Block History is
untouched — the MOBILE PARITY line is U3b's per the memo).

*Implementer: opus-implementer, fresh session, 2026-11-05. Headless only (`swift build` / `swift test` on the
package, `xcodebuild build-for-testing` for the App target's compile); no stage, no xcodebuild test, no GUI, no
store touches. Mac-target pins are written and compiled here and NAMED for the run's closing stage window.*

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| U3a-0 | Preflight read (CLAUDE.md canon · this file's The run / every sitting entry / THE DESIGN MEMO / Environment traps / the U3a BRIEF · SurfaceContracts The app + The note · TEXTKIT2_NOTES whole · both exploration mockups + her composite shot (read as an image) · the whole Block History implementation: `BlockHistoryPane.swift`, `Shared/BlockHistoryFace.swift`, `SavepointHistory.swift`, the inspector host in `PostDetailView`, the router seam, both bars' doors + sheet fallbacks, the Write take panel's arms, the Blocks workbench's two doors, `ShellActions.showBlockHistory`, the registry rows · `Queries.blockHistory` · U1's `LineageTree` · the walk test · the tutorial's Block History lessons + walk) | DONE |
| U3a-G1 | GATE — the tutorial walks Block History (FLAGGED below, before anything it walks changes) | FLAGGED |
| U3a-G2 | GATE — the panel's retirement meets doors/jobs the memo does not cover for U3a (FLAGGED below; left as they were) | FLAGGED |
| U3a-1 | The pure Domain text-compare (`Domain/TextCompare.swift`) + its own suite | DONE — `TextCompareTests` 16/16 headless (a product row: the suite does not compile on the pre-change tree); her reference edit reads as FOUR changes |
| U3a-2 | The pure rail projection (`Domain/CommitRail.swift` — interleave, folds, AI pair, filter, now row, swapper order, opening selection) + its suite | DONE — `CommitRailTests` 14/14 headless (product row; the bracket names pinned equal to the door's `Operations.mcpEditCommitNames`) |
| U3a-3 | The Commits face: model + view (reading pane, rail, take dropdown, fast swapper, deleted-takes foot) | DONE (compiled) — `Features/History/CommitsFaceModel.swift` + `CommitsFaceView.swift`; `CommitsFaceModelTests` 11 pins written + compiled, RUN owed to the closing window |
| U3a-4 | Compare: two boxes + the standing "now" third, each header a swapper, the washes | DONE (compiled) — `Features/History/CommitsCompareView.swift` + the model's compare state; two Compare pins in `CommitsFaceModelTests` |
| U3a-5 | The re-aim: every history door opens the face (full pane in the detail, ‹ back; the sheet where no detail is); the block ▾ History row on both bars; the origin door keeps its old panel (G2) | DONE (compiled) — router seam `requestOriginHistory`; `PostDetailView.historyFace`; the three sheet hosts; both block ▾ menus; three host pins in `BlockHistoryHostTests` |
| U3a-6 | Registry: the face's acts declared once; the walk extended; every Block-History-class pin re-pointed as a named justified edit; new Mac pins (compiled, named for the window) | DONE (compiled) — four `.surface` acts; the walk's line; `CommitsFaceDoorsTests`; the re-points listed under U3a-6 below |
| U3a-7 | END: headless core suites, `xcodebuild build-for-testing`, the PROVISIONAL list for #264, self-assessment | DONE — below |

### U3a-G1 — GATE: the tutorial walks Block History (FLAGGED before anything changes)

The brief's gate fires. Two tutorial facts touch the panel being retired:

1. **The walk drives the panel's model.** `TutorialWalkTests.theDeletedSpareTakeWaitsInTheBlocksPastAndComesBack`
   (lesson "what a block leaves behind") builds `BlockHistoryModel` and presses its `putBackTake` — the deleted
   take's Put back in "the same History face". The new face carries the same act at its rail's foot (the memo:
   "the deleted takes line at the rail's foot (count · days left · Put back)"), through the same op and the same
   receipt (`BlockPastCopy.restored`).
2. **The lessons' WORDS describe the panel.** `TutorialSeeder` lesson "Five: this block's History" says the
   history door "opens the Block History panel: each live take's saved moments, the takes this block archived, the
   takes it deleted (with their clocks), and Came from, the blocks it came out of". After U3a's re-aim the history
   door opens the Commits face: saved moments by take (the rail), archived takes (the dropdown's group, hollow dots),
   deleted takes (the rail's foot) — but **Came from is not on the Commits face**: the memo puts lineage behind its
   own door (the Lineage face, U3b). The other Came-from sentences (lessons at `TutorialSeeder` ≈1505, 1569, 1584,
   1772–1782, 1848–1850, 1876, 1900; `RecoveryCopy` ≈351/369; `OpsRefusalCopy` ≈668; `TrayPath.originalsPath`) all
   name "Came from in Block History" as where an original waits.

**What U3a does about it:** nothing it walks is changed. The tutorial's TEXT is not edited (product copy about
lineage is U3b's — the Came-from region's new home is the Lineage face, and its words are owed then, at her
wording pass); the walk's model stays compiled and green because the old panel survives for the origin door (G2).
**Owed (U3b + the orchestrator):** lesson five's clause "and Came from, the blocks it came out of" and every
"Came from in Block History" sentence above re-pointed at the Lineage face when it lands — P-6 says a tutorial
step that stops being true is a regression, and between U3a and U3b this one is (nothing ships between them; the
ladder runs once after U3b).

### U3a-G2 — GATE: doors and jobs the memo does not cover for U3a (left as they were)

1. **The origin door — "See original from divide…/merge…" (the block's right-click, ⌘K's "See the Original This
   Came From").** Today it opens the Block History panel, whose Came-from region shows the originals with Bring back
   and Open this note's tray. The memo's Commits face shows no originals; their home is the Lineage face (U3b).
   Re-aiming this door at the Commits face would be a door promising an original and showing commits (P-2's lie),
   and re-aiming it anywhere else is a design the memo does not make for U3a. **Left as it was:** the origin door
   keeps opening the old panel (inspector where a detail is mounted, the bars' sheet where none is) through its
   own road; the old panel's code stays exactly as shipped. **Question for U3b / the orchestrator:** the origin door
   lands on the Lineage face with the original selected — confirm, and the old panel (`BlockHistoryPane`,
   `BlockHistoryModel`, `CommitReadingSheet`, `HistoryRegionHeader`, `CommitRowView`, the VX-668 oracle) then retires
   whole with its pins re-pointed.
2. **Unarchive (the panel's archived-takes region).** The brief's job list omits it; the memo says "all its jobs
   live here" and draws archived takes in the dropdown's group with hollow dots, without placing Unarchive.
   Exploration A (which she said she liked) drew it on an archived take's "now" head. **Built as PROVISIONAL**
   (P-U3a-6 below): when the selected moment is an ARCHIVED take's "now", the pane's foot offers Unarchive (the
   existing op, the existing receipt); every other moment's foot is the memo's four acts.
3. **The panel's "Show the block you're in" jump** (ledger row 33) — the face takes the full pane, so no caret
   moves while it stands; the jump has nothing to do on the face and is not carried (it stays on the old panel).

**Walk lesson adopted (nov5, from vx-808's walk):** the note header's TAG FIELD does not receive
synthetic typing while a live editor holds first responder — cliclick keys fall through into the
BODY, and a stray Return fires the structural typed-Return door and divides blocks (repair:
⌥⌘Z). Seed tags via quick-entry microsyntax (`{#tag/path}`), never by typing into the tag field.
The dev store now carries replaceable walk fixtures from tonight (harbour review + pins, "Night
ferry" notes, a #harbour tag, a bookless "driftglass" note) — fine to reuse or ignore (dev-store
content is agents' to manage). Merge note: vx-808's B5 touches `MCPToolCatalog.swift` additively
— still the second merger's resolution.

### U3a-1/2 — the two pure rules (headless, red by not compiling on the pre-change tree)

- **`Sources/VariorumCore/Domain/TextCompare.swift`** — the view-time word compare (OverallModel §8's legal diff:
  between two already-identified texts, stored nowhere). Tokens = word runs (an apostrophe inside a word belongs
  to it) · whitespace runs · single other characters; Myers over interned tokens after a common prefix/suffix
  trim; ONE cleanup — a plain space (never a line break) between two changes joins them when the joined change
  still replaces words on both sides, so "slowly becomes" → "starts to become" is one struck phrase beside one
  washed phrase and counts as ONE change. Three run families (`old` struck side, `new` washed side, `unified` for
  the single pane) each give their text back byte for byte. **P1:** the edit search is bounded by `editBudget`
  (1,000 token edits); past it the differing middle is ONE coarse change, never a hang (pinned with a 4,000-word
  wholesale rewrite: 49 ms). `Tests/VariorumCoreTests/TextCompareTests.swift` 16/16 — her reference edit reads
  as FOUR changes (removed "slowly becomes" · "whole" · "notice" · "really"; added "starts to become" · "see").
- **`Sources/VariorumCore/Domain/CommitRail.swift`** — the rail as a value: all takes interleaved newest-first by
  `(created_at, id)` with ONE "now" line (the lead take); `.take(id)` filters and leads with that take's now; the
  fold is `SavepointRuns` unchanged with ONE amendment (an AI bracket is never quiet for folding); an "after"
  directly above its own "before" (same take, same client) shares one `pairID` (the wash), a lone bracket its
  own; archived takes' moments flagged hollow; `selectable` / `step` (the swapper, stops at the ends, skips a
  run's own line) / `opening` (the newest moment, even inside a fold) / `runHiding` (the run to open so it
  shows). The bracket names are parsed locally (a Domain rule does not reach up into Operations) and PINNED
  EQUAL to `Operations.mcpEditCommitNames`. `Tests/VariorumCoreTests/CommitRailTests.swift` 14/14.

### U3a-3/4/5 — the face, Compare, the re-aim (what landed, one pointer per piece)

- **The model** `App/Variorum/Variorum/Features/History/CommitsFaceModel.swift` — the observed read
  (`Queries.blockHistory` + the shown take via `Queries.mcpShownTake`, flushed first so "now" is now), the filter
  (all by default), the selection seated by `CommitRail.opening` and kept across snapshots unless its moment is
  gone, the open runs, the wash (default against now), the pre-split confirm, the rename ask, Compare's boxes,
  and the acts — `restoreCommit` (flush first, pre-split ask, the VX-431 landing parcel posted as the panel
  posts it — inert while the face covers the surface), `bringBackCommitAsTake`, `renameCommitPoint` (the seal's
  standing refusal, the field never opened under one), `restoreVariant` (Put back), `unarchiveVariant`; every
  receipt and refusal the panel's own constant (`BlockHistoryCopy`, `BlockPastCopy`, `TrayRefusalCopy`). The
  washes are cached per pair of texts. The face's own words live in ONE home, `CommitsFaceCopy` (PROVISIONAL).
- **The view** `App/Variorum/Variorum/Features/History/CommitsFaceView.swift` — the crumb (‹ back · the note ·
  "block N/M" via `BlockLineLabel` · history), the status line, the reading pane (headline = the name else the
  first words; meta = when · take ✓ · quiet · predates a split; "N changes since" + plain · against now chips;
  the whole text as ONE selectable `Text` in a scroll — read tier, no editor, P3; the chosen bar on the leading
  edge when the moment's take is the one the note shows; the foot acts), the rail (the take dropdown — a popover
  of tinted rows, "all takes" first, archived grouped; "history · all takes / this take"; the dot timeline with a
  continuous spine, take chips in the all-takes rail, run lines that open in place, the AI pair on a quiet accent
  wash; the deleted takes at the foot, one line each with Put back), ↑/↓ on the face (`onKeyPress`, the face
  holding the keyboard), the VX-668-shape DEBUG pin door `CommitsFaceOracle`.
- **Compare** `App/Variorum/Variorum/Features/History/CommitsCompareView.swift` — ‹ history, two boxes (a moment
  beside its take now; an AI half sets before · after), each header a `VoicedMenu` swapper over every moment of
  every take (now + commits, grouped by take), "＋ now" while fewer than three boxes stand and none is a now, ✕ on
  a third box only; the first box struck against the second, every later box washed against the one before.
- **The re-aim.** `PostDetailView.historyFace` — the face REPLACES the mode's surface under the masthead (never
  beside or over a mounted editor: no hidden editor can take a keystroke or a routed act); the open captures the
  place exactly as a mode switch does (`carryPlaceAcrossModeSwitch`) and drops the one-shot caret/find seeds
  (17o's R1-1 class); ‹ back clears it and the mode's surface arrives by the mode round trip's own road; any mode
  request (the current mode included) closes it keeping the open's carry; a direct mode change closes it too.
  The router's `showBlockHistory` seam now opens the face; NEW `requestOriginHistory` seam (+ `showOriginHistory`
  registration) keeps the ORIGIN door on the old inspector panel (G2). The three sheet hosts (`CommitBar`,
  `TakesBottomBar`, `WriteTakesPanel`) present the face on `blockHistoryRequest` (‹ back dismisses) and the old
  panel on the new `originHistoryRequest` slot (`EditorViewModel`, `TakesViewModel` — the origin door's
  requests built byte for byte as before). **block ▾ History** on both bars (`CommitBar.historyRowTitle`, the
  registry verb's short form "History"), the same act as the history word.
- **The registry.** Four `.surface` acts declared once (`.restoreCommit`, `.bringBackCommitAsTake`,
  `.compareCommits`, `.renameCommit`) — the panel rendered the three writers undeclared; `CommitsFaceView.
  surfaceCapabilities` = those four + `.restoreTake` + `.unarchiveTake`; the surface walk carries the face's line
  (a named JUSTIFIED EDIT in `CapabilityRegistryTests`). `.showBlockHistory`'s declaration is unchanged
  (`[.bottomBar, .palette]` — block ▾'s row is a second `.bottomBar` render).

### U3a — PROVISIONAL, for #264 (the orchestrator lands QUESTIONS at the merge)

- **P-U3a-1** — the all-takes rail's per-take "now" rows: ONE "now" line, the lead take's (the take the door was
  pressed in, else the first live take) — exploration A's drawing; every other take's now is one dropdown pick
  away. Alternatives: a "now" per live take at the top; none in the all-takes rail.
- **P-U3a-2** — where the face opens: the newest moment among the shown takes (after an AI edit that IS the
  after-bracket, the before one ↓ down); a fold holding it opens to show it; a block with no moments opens on its
  now. (The memo's lean, built.)
- **P-U3a-3** — the wash's default: against now (her composite draws it; "claude just changed something" is the
  case). Alternative: plain by default.
- **P-U3a-4** — the fast swapper's keys: ↑ newer · ↓ older, stopping at the ends, stepping over a run's own line;
  the face holds the keyboard while it stands. (The memo's lean.)
- **P-U3a-5** — Compare's third box: the door reads "＋ now" and is offered while fewer than three boxes stand
  and none of them is a now (the take of the last box); only a third box can be put away (✕); with three boxes
  the middle one washes what arrived against the first (each later box against the one before). Compare carries
  no acts of its own (the acts live on the face's pane; B drew Restore · Bring back under its before box).
- **P-U3a-6** — Unarchive's place (the panel's archived-region job, which the memo does not place): the pane's
  foot offers Unarchive when the shown moment is an ARCHIVED take's "now" (exploration A's head); Restore on an
  archived take's commit stays rendered and the op answers (the panel's posture).
- **P-U3a-7** — the AI pair's wash: the voice's accent at 8 % behind both lines, the dots in the accent.
- **P-U3a-8** — the deleted takes at the rail's foot: one line per deleted take — "deleted take · ‹its words› ·
  N days left · Put back" (the memo's "count · days left · Put back", per take so each Put back names its take).
- **P-U3a-9** — the face's own words (`CommitsFaceCopy`): "‹ back", "history", "the take now", "all takes",
  "history · all takes / this take", "✓ chosen", "locked", "archived", "archived takes", "plain", "against now",
  "N changes since" / "1 change since" / "no changes since", "Compare", "＋ now", "deleted take", "N takes ▾",
  "N commits". The acts keep the panel's shipped verbs — "Bring back as a take" (her composite reads "Bring back
  as take"; the shipped, pinned constant was kept rather than minting a second spelling — her wording pass).
- **P-U3a-10** — hosts: the full pane in a note's detail; where no detail is (the book's inline editors, the
  scraps hosts, Write's take panel) the same face rides a sheet (the panel's own two-host rule), ‹ back closing
  it. In the full pane a Restore lands no wash on a page (no page stands beside the face — the "elsewhere a
  receipt" arm of VX-431/VX-668's contract); ‹ back returns to the place the open carried.
- **P-U3a-11** — the crumb's block place reads `BlockLineLabel`'s "block N/M" (the bars' own words; her
  composite drew "block 2").

### U3a — what is OWED, and to whom

- **U3b / the orchestrator — G1, the tutorial.** Lesson five's "and Came from, the blocks it came out of" and every
  "Came from in Block History" sentence (listed in G1) re-pointed at the Lineage face when it lands. The
  history door's help ("…and the block it came out of") and `.showBlockHistory`'s unavailable note ("…and where
  it came from") become true again the moment the face carries "lineage ›" — left untouched for that reason.
- **U3b — G2, the origin door + the old panel.** The origin door lands on the Lineage face; then the panel retires
  whole: `BlockHistoryPane.swift` (`BlockHistoryModel`, `CommitRowView`, `CommitReadingSheet`,
  `HistoryRegionHeader`, `BlockHistoryPaneOracle`, `CommitRowFace`'s Mac-local half), the inspector's
  `.blockHistory` case, the router's `requestOriginHistory` seam and both models' `originHistoryRequest` slots
  (or they re-aim at the Lineage face), and these pins re-pointed again: `BlockHistoryPaneTests`,
  `BlockHistoryClarityTests`, `BlockHistorySealTests`, `BlockHistoryHostTests` (its first two), `RestoreLanding*Tests`,
  `CommitsPageLedgerTests`, `BlockHistoryCommitsCaptureTests`, `RecoveryDoorsTests`' came-from arms,
  `OriginBlockDoorTests`, `WriteTakesPanelRoutedTests`' origin row, and the tutorial walk's
  `theDeletedSpareTakeWaitsInTheBlocksPastAndComesBack` (drive `CommitsFaceModel.putBackTake` instead).
  The header's "lineage ›" door (her composite) is U3b's — not drawn here (P-2: no Lineage face to open yet).
- **The closing stage window — the Mac runs** (suite-level `-only-testing`): `VariorumTests/CommitsFaceModelTests`,
  `VariorumTests/CommitsFaceDoorsTests`, `VariorumTests/BlockHistoryHostTests`, `VariorumTests/CapabilityRegistryTests`,
  and the re-pointed `BlockHistoryPaneTests`, `RecoveryDoorsTests`, `OriginBlockDoorTests`,
  `RestoreLandingInspectorTests`, `WriteTakesPanelRoutedTests`, plus the neighbours the re-aim touches:
  `RestoreLandingTests`, `RestoreLandingRewriteHopTests`, `BlockHistoryClarityTests`, `BlockHistorySealTests`,
  `CommitsPageLedgerTests`, `CommandRoutingTests`, `CanvasAndPoolTests`, `ModeSwitchCarryTests`,
  `TutorialWalkTests`, `ShellChromeTests`, `DeadVocabularyTests`, `CommitVocabularyTests`,
  `HelperCurrencyTests`.
- **The walk (the orchestrator's, the closing window — the acceptance gate is USE).** One capture per row, both
  voices: (1) Write → bar "history" → the face in the full pane on the newest moment; (2) ↑/↓ swaps the pane;
  (3) plain · against now; (4) the take dropdown → one take → its now leads; archived take → Unarchive; (5) a
  quiet run opens in place; (6) an AI edit (the door's `edit_take` on a dev-store note) → the face opens on the
  after, ↓ the before, washed; (7) Compare from the before → before · after → "＋ now" → three boxes, a header
  re-aimed; (8) Restore / Bring back as a take / Rename / a deleted take's Put back, each receipt; (9) ‹ back →
  Write exactly where it was; (10) block ▾ ▸ History from Takes; (11) the book's inline editor → the face in a
  sheet; (12) "See original from…" still opens the old panel (G2, unchanged).

### U3a-6 — the Block-History-class pins, re-pointed one by one (each a named JUSTIFIED EDIT in its file)

Nothing was deleted. The rule applied: a pin about WHERE A HISTORY DOOR LANDS moves to the face; a pin about the
PANEL keeps every claim and is driven through the road that still opens the panel (the origin door's, gate G2).

| Pin | Edit |
|---|---|
| `BlockHistoryHostTests.aModeSwitchClosesThePaneTheModeOpened` | driven by `requestOriginHistory` (the panel's surviving road); claims unchanged |
| `BlockHistoryHostTests.fromBlocksThePaneIsTheOneRightRegion…` | the same |
| `BlockHistoryHostTests` — NEW `theHistoryDoorOpensTheCommitsFaceInTheFullPane`, `aModeSwitchFromTheFaceShowsTheMode`, `fromBlocksTheFaceReplacesTheWorkbenchAndGivesItBack` | the face's host (red on the pre-U3a tree: the door opened the inspector beside a mounted editor; `historyFace` did not exist) |
| `BlockHistoryPaneTests.theMountedDetailOpensTheHistoryPaneInItsRealSidePanel` | driven by `requestOriginHistory`; claims unchanged |
| `BlockHistoryPaneTests.aHistoryRequestForAnUnmountedPostIsRefused…` | unchanged arms + two for the origin seam (refused off-note, never parked) |
| `RestoreLandingInspectorTests` (VX-668's three) | the inspector road opened through `requestOriginHistory` (the history door now REPLACES Write, so there is no page beside the face to land on — the "elsewhere a receipt" arm); every landing claim unchanged |
| `RecoveryDoorsTests.theContextRowOpensThePeekAtTheOriginAndItShowsItsTakes` | reads `originHistoryRequest` (+ `blockHistoryRequest == nil`) |
| `RecoveryDoorsTests.theRoutedActSpeaksWhereTheBlockHasNoOriginal` | + `originHistoryRequest == nil` |
| `OriginBlockDoorTests.theBoardsProjectionCarriesTheOriginsAndItsDoorActs` | reads `originHistoryRequest` (+ `blockHistoryRequest == nil`) |
| `WriteTakesPanelRoutedTests.originOpensThePanelsBlocksOriginals` | reads `originHistoryRequest` (+ not the face) |
| `BlockHistoryCommitsCaptureTests.captureTheCommitsPaneInContextBesideTheNote` (disabled harness) | shoots the panel through `requestOriginHistory` |
| `CapabilityRegistryTests.theSurfacesRenderExactlyTheDeclaredSurfaceActs` | + the face's line |

Left as they were, still true: `OriginBlockDoorTests.theDoorOpensTheBlocksHistoryAtItsCameFrom` (it drives the
HISTORY door's request — whose fallback slot is still `blockHistoryRequest`; its doc names the origin door, a
wording U3b's retirement re-reads), `RecoveryDoorsTests.theHistoryRequestCarriesTheCaretsBlockAndItsTake`,
`WriteTakesPanelRoutedTests.blockHistoryOpensForThePanelsBlock` (the fallback sheet now presents the face),
`CommandRoutingTests`/`CanvasAndPoolTests`' `registerDetail(showBlockHistory:)` arms, the panel's model suites
(`BlockHistoryClarityTests`, `BlockHistorySealTests`, `CommitsPageLedgerTests`), the tutorial walk (G1).

### U3a — END (the suites, on the committed tree; headless)

- `swift build` — Build complete. `TextCompareTests` 16/16 · `CommitRailTests` 14/14.
- **`swift test --filter VariorumCoreTests` → "Test run with 3847 tests in 520 suites passed after 270.536 seconds
  with 5 known issues"** (the known issues are standing `withKnownIssue` arms, none of this unit's).
- The whole package's `swift test` (all targets): every target green but `VariorumMCPTests`, which reported THREE
  failures — `MCPDiscoverProbeServerTests.claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes`
  (`socket.nextResponse()` nil), `MCPStopRoadsServerTests.aClientThatLeftBeforeTheQuitKeepsItsOwnLine` ("claude-code
  got no answer to its initialize"), `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`
  (41.9 s against a 15 s bound) — socket-timing suites over code this unit never touched (no `Sources/VariorumMCP`
  line in the diff), run under a load average of 13–16 (other sessions on the Pro). **Re-run alone:
  `swift test --filter 'MCPDiscoverProbeServerTests|MCPStopRoadsServerTests|MCPHarnessTimeLimitTests'` → "Test run
  with 14 tests in 3 suites passed after 2.300 seconds".** Recorded as load flakes, not dismissed silently: the
  closing window's MCP re-run (the second-merger duty) is where they are read again.
- **App target COMPILE only** (no stage): `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration
  Debug build-for-testing` → "** TEST BUILD SUCCEEDED **" (default DerivedData — this worktree's own
  `Variorum-*` dir; TutorialWalkTests compiles).
- `Tools/verify-pins` → OK both graphs (16 + 15 pins).

### U3a — self-assessment (for the cold reviewer's read, not instead of it)

- **The hosting call is the one to read hardest.** The memo says "full pane; ‹ back returns exactly where she
  was". Built: the face REPLACES the mode's surface (never covers a mounted one — a hidden editor would keep the
  keyboard's routed acts and could take keystrokes), and ‹ back re-arrives through the mode round trip (the carry
  captured at the open, the caret/find seeds dropped as leaving Write drops them). So "exactly" is the mode round
  trip's exactness — the carried block at its viewport fraction, the caret at her remembered offset — not a
  frozen view. The alternative (keep the surface mounted under an opaque face, hand the first responder back) is
  exact by construction but leaves Write's handlers live under a face she cannot see. Named for the walk (row 9).
- **The model is long (≈690 lines, much of it doc).** One surface's brain — projections, selection, the acts, and
  Compare's boxes; the decisions themselves are the two pure Domain rules. If P-9 bites, Compare's state is the
  clean seam to split out.
- **`Queries.mcpShownTake`** is read for the ✓ chosen mark — a core query named for the MCP door but generic
  (the structural ops' rendered-take rule); no MCP file touched.
- **The old panel lives on** (G2) — two models with the same acts for one run's interval; U3b deletes the old.
- **Not walked, not run.** Every Mac claim above is compiled, not yet observed. The face's geometry (the rail's
  330 pt, the chips, the dropdown popover) has had no eyes on it.

## U3a ADJUDICATION (the orchestrator, 2026-11-06)

**Verified:** commits fc8880a53…dc7fde0e5 on origin, tree clean; `TextCompareTests` +
`CommitRailTests` re-run independently, 30/30 green. The three MCP reds are the standing
socket-timing class (no MCP code in this diff; green alone) — accepted.

**G1 SUSTAINED:** the lesson sentences stay untouched until U3b's Lineage face makes the new
truth; U3b sweeps them (drafts, wordings to #264). The real store's seeded guide will be STALE
at merge — the closeout re-seeds via Help ▸ Restore Field Guide… behind the A1 rail (owed list).

**G2 RULED (the architect, within the memo's retirement ruling):** the origin door ("See
original from…", ⌘K's twin) lands on the LINEAGE face with the ORIGIN NODE SELECTED — the
panel then retires WHOLE (U3a's listed files and pins), and the tutorial's `putBackTake` drive
re-points to the face's road. Flagged to #264 for her eye (she sees it at the walkthrough; the
walk shows it live).

**Sustained besides:** the ‹-back-as-mode-round-trip decision (a hidden mounted editor would
still take routed acts and keystrokes — the hazard is real; walk row 9 checks); P-U3a-6
(Unarchive in the pane's foot, exploration A's drawing); the registry catch (three writing acts
the panel rendered undeclared, now declared — P-1 doing its job). **P-U3a-1…11 join #264.**
**Carried to the ladder and the window:** every Mac-face claim is compiled, not yet observed —
the window's runs and the twelve-row walk are the observation.

## U3b BRIEF — the Lineage face, the origin re-aim, the panel's retirement

**Read first (in full):** this file: THE DESIGN MEMO, every sitting entry, the U3a RECORD WHOLE
(its owed lists, retire lists, walk rows, P-U3a items), "Environment traps", this brief ·
`notes/SurfaceContracts.md` The note + The app · `notes/TEXTKIT2_NOTES.md` (binding if you touch
the read tier's seams) · `Sources/VariorumCore/Queries/LineageTree.swift` + its tests (U1 built
your read; its states are placed · preserved · archived · deleted · missing) · the guide's
lesson five content (G1's ~10 sentences, listed in the U3a RECORD) · the capability registry.

**Deliverables:**
1. **The Lineage face** per THE DESIGN MEMO: vertical family, older above, no horizontal
   scroll; one line per node (origin verb · first words · where it lives · counts), this block
   marked; selecting a node swaps the SAME pane+rail composition to that block — REUSE the
   CommitsFace machinery parameterized by block, never a second implementation; node-header
   acts Put back (placeable states only, the existing op and landing, the receipt names where
   it landed) · Bring back as take · Compare with now (the same compare); a Trash node muted
   with no acts; a cross-wing node named with its wing, go-to only. Doors: "lineage ›" on the
   Commits face's bar, a "Lineage" row in both block ▾ menus, registry-declared.
2. **The cross-block Bring back as take** — her sitting ruling verbatim: "mints the node's
   active text as a new take on the block you came from — the bringBackCommitAsTake shape,
   cross-block; parent lineage via the existing edge." This grows §9 by one operation.
   **PROPOSE-THEN-BUILD (hard gate):** send the orchestrator the op's exact row semantics
   BEFORE writing it — name, inputs, the minted take's fields (fan position end, never chosen,
   never born locked, label?), `parent_variant_id` stance (her "via the existing edge" reads as
   NO cross-block parent pointer — the derived_from edge already carries the lineage; say if
   the code argues otherwise), refusals (seal, dead block, I10 irrelevance), touch/churn
   posture, undo entry. Exact state-transition tests on the ruling.
3. **The origin door re-aim (G2's ruling above):** "See original from…" and ⌘K's twin land on
   the Lineage face with the origin node selected; then the OLD PANEL RETIRES WHOLE — the U3a
   record's file and pin lists executed, every pin re-pointed or retired as a named justified
   edit, the tutorial's `putBackTake` drive re-pointed to the face's road and GREEN-equivalent
   (compiled; the window runs it).
4. **The guide sweep:** G1's sentences reworded to the new truth — drafts faithful to the
   guide's voice, every changed sentence listed in your record for #264 (her wordings to
   re-cut); the tutorial walk test's steps kept true.
5. **Walk rows** for the Lineage face appended to the U3a record's walk list (the origin-door
   landing, the ancestor swap, Put back's receipt, the cross-wing go-to, the Trash node).

**Evidence:** the new op's exact state-transition suite; face/VM focused coverage (the family
rows, node selection swap, act availability by state); headless core suites green at the end
(every failing test named; the socket trio is the known class); `xcodebuild build-for-testing`
green; `Tools/verify-pins` OK. Mac-target RUNS stay owed to the closing window.

**Constraints:** U3a's constraints verbatim (P3, no `Sync/`, no custody, no schema, no MCP
changes, sentence case, the commit vocabulary, one agent + max one Sonnet external, LIVE STATUS
U3b RECORD from the first commit, "Part of VX-801" commits, no trailers, push each, foreground
waits, pull first).

## U3b RECORD — the Lineage face, the origin re-aim, the panel's retirement (VX-801's second half)

**NOT DONE in U3b, said first:** no Mac-target TEST run and no walk (both owed to the run's closing stage window — the
suites and the walk rows 13–23 are named under "what is OWED"); no canon delta (SurfaceContracts' Block History bullet
and the Lineage face's line, AppSpec §9's new operation `bringBackFromLineage`, the AppSpecRecord entry) and no
QUESTIONS edit — the #264 items are P-U3b-1…13 and the sweep's W1–W16 below, for the orchestrator at the merge; no
`notes/MobileSoul.md` row (the MOBILE PARITY line is drafted below for the closeout); the real store's seeded guide is
not re-seeded (owed, behind the A1 rail); the ⌘/ helper's block ▾ row is not taught History or Lineage (P-U3b-10).

*Implementer: opus-implementer, fresh session, 2026-11-06. Headless only (`swift build` / `swift test` on the
package, `xcodebuild build-for-testing` for the App target's compile); no stage, no xcodebuild test, no GUI, no
store touches. Mac-target pins are written and compiled here and NAMED for the run's closing stage window.*

### LIVE STATUS

| # | Piece | Status |
|---|---|---|
| U3b-0 | Preflight read (CLAUDE.md canon · this file: The run, every sitting entry, THE DESIGN MEMO, the U3a RECORD whole, the U3a ADJUDICATION, the U3b BRIEF, Environment traps · SurfaceContracts The app + The note · TEXTKIT2_NOTES whole · both exploration mockups' lineage sections + her composite shot · `Queries/LineageTree.swift` + `LineageTreeTests` · U3a's face (`CommitsFaceModel`, `CommitsFaceView`, `CommitsCompareView`) · the old panel whole (`BlockHistoryPane.swift`) and its every door/host · `Operations.bringBackCommitAsTake` + `insertFanVariant` · `PreservedOriginPutBack` / the tray's put-back roads · the tutorial's lineage lessons · the capability registry + the surface walk) | DONE |
| U3b-P | PROPOSAL — the cross-block Bring back as take (the brief's hard gate; row semantics sent to the orchestrator before any op code) | RULED (all four leans sustained — U3b-P RULED) |
| U3b-1 | The family projection (pure, core) + the node counts read + headless suites | DONE — `Domain/LineageFamily.swift` (members older above in generation bands, place + header acts by state, the op's own wing rule, a block met twice drawn once, `opening`), `Queries/LineageFamilyCounts.swift`; `LineageFamilyTests` 7/7 headless (product row) |
| U3b-2 | The op, built to the ruling + its exact state-transition suite | DONE — `Operations+LineageBringBack.swift` (`bringBackFromLineage`, `LineageTakeSource`, `lineageCrossesWing`), `OperationError.notInLineage`, its words in `OpsRefusalTable`; `LineageBringBackTests` 12/12 headless (a product row: does not compile on the pre-U3b tree) |
| U3b-3 | The Commits face machinery parameterized by block (a relative of the block you came from) — reuse, not a second composition | DONE (compiled) — `CommitsFaceModel.Role` (`.home` / `.relative`), the shared `LineageBringBack` road; `CommitsFaceBody` = THE one pane+rail composition both faces draw |
| U3b-4 | The Lineage face (model + view), its doors (lineage › on the face, Lineage in both block ▾ menus), the registry | DONE (compiled) — `LineageFaceModel` + `LineageFaceView` + `BlockHistorySurface`; `LineageFaceModelTests` (10 pins) + `LineageFaceDoorsTests` (4) written and compiled, RUN owed to the closing window |
| U3b-5 | The origin door re-aim (G2's ruling) + the old panel's WHOLE retirement + every pin re-pointed or retired by name + the tutorial walk's drive | DONE (compiled — `build-for-testing` green) — the table under U3b-5 below |
| U3b-6 | The guide sweep (G1's sentences, each listed for #264) | DONE (compiled; phone target compiled too — `RecoveryCopy` is shared) — the list under U3b-6 below |
| U3b-7 | Walk rows for the Lineage face, appended to the window's walk | DONE — rows 13–23 under "what is OWED" below |
| U3b-8 | END: headless suites, `build-for-testing`, `Tools/verify-pins`, the PROVISIONAL list, self-assessment | DONE — below |
| U3b-FIX-1 | Ladder R1-F1 (the flush gap): AGREED; fix + pin, the behavioral revert announced below BEFORE it runs | BUILT + COMPILED (429218982) — **NOT LANDED until the closing window runs the recipe below: red on old, then green** |
| U3b-FIX-5 | Ladder R1-F5 (`mcpShownTake`'s name): AGREED; a pure rename + its call sites | NOT-STARTED |


### U3b-P — THE PROPOSAL: the cross-block Bring back as take (sent before any op code; build waits on the ruling)

Her ruling (verbatim, the VX-801 sitting): *"mints the node's active text as a new take on the block you came from —
the bringBackCommitAsTake shape, cross-block; parent lineage via the existing edge."*

- **Name / inputs.** `Operations.bringBackFromLineage(_ source: LineageTakeSource, onto blockID: String) -> Variant`,
  `enum LineageTakeSource { case take(variantID), commit(commitID) }`. The node header's act passes the node's
  shown take (`LineageTree`'s read rule: placed → chosen, else default — "the node's active text"); the op copies
  that take's text AS IT STANDS at act time. The `.commit` form serves the pane's foot when the face shows a
  RELATIVE's moment (her v1 goal: *"letting people look for commits on previous takes of ancestor blocks easily"*
  — recovery is the point of finding one). Narrow alternative: `.take` only (a relative's commit is read and
  compared, never brought back).
- **The row.** ONE `variant` INSERT: `block_id` = the target · `working_text` = the source's text · 
  `parent_variant_id` = **NULL** (the code agrees with the brief's reading: every parent pointer in the codebase is
  same-block — branch, `bringBackCommitAsTake`, `moveSpanToNewTake`, the ceremonies'/duplicates' remapped trees;
  the MCP door's `create_take` mints NULL; the existing `derived_from`/`version_of` edge carries the lineage; NO new
  edge) · `status` active · `locked` 0 · `label` = the source's name when it has one (a commit's message / a take's
  label, through the take label's normalisation), else NULL (alternative: always NULL) · `fan_position` = the
  fan's END · fresh id, `created_at` = `updated_at` = now. Never chosen (no `container_block` write), never the
  default (`block.default_variant_id` untouched), never born locked; no edge, commit, comment or presentation
  written.
- **Touch / churn / undo.** None — `bringBackCommitAsTake`'s (= `branchVariant`'s) posture: no `last_touched_at`,
  no churn, NO structural-undo entry; the road back is deleting the take. (Alternative: one undo entry, inverse =
  tombstone the minted take, exact-row redo.)
- **Refusals, in order, one transaction:** target missing/dead → `blockNotFound(target)`; target under a sealed
  post → `lockedPost`; `.commit` unknown → `commitNotFound`; the source take missing/dead → `variantNotFound`
  (archived or locked source ALLOWED — only read); the source's block dead → `blockNotFound(source)` (a Trash node;
  the face draws no act there); **the lineage fence (lean A):** the source block must be a node of the target's
  `Queries.lineageTree` (admitted edges, read in the transaction — cost ∝ that block's lineage, P1), never the
  target itself, and never across wings (both homes notes in different wings; the scraps are the one shared room)
  → ONE new `OperationError.notInLineage(sourceBlockID:targetBlockID:)`, worded in the shared refusal table.
  Alternative B: no fence in the op (the face offers only same-wing live nodes), no new error case. I10
  irrelevant (adds a take). Sync: a plain insert, the outbox trigger captures it. Not wire-called; no MCP change.
- **Pins (exact state transitions, headless):** take source and commit source, every field above and every other
  table unchanged (placements, default, edges, commits, the note's touch/churn stamps); label rules; the fan's end
  past an archived take; archived/locked source allowed; each refusal writes nothing; the fence's arms (unrelated,
  same block, cross-wing, a pool home crosses nothing); a placed descendant in another note and a version sibling
  as sources.
- **Asked:** (a) both source forms or take-only · (b) the source's name as label or none · (c) fence A (new
  error) or B (none) · (d) no undo entry or one. **Leans: both · the source's name · A · none.**

**U3b-P RULED (the orchestrator, 2026-11-06 — the cross-block Bring back as take):** all four
leans SUSTAINED. (a) BOTH source forms — her sitting ruling names the node's active text (.take)
and her recorded goal ("letting people look for commits on previous takes of ancestor blocks…
recovery is the point") needs .commit; the existing bringBackCommitAsTake is the same-block
precedent the .commit form extends. (b) the source's name as the label — bringBackCommitAsTake's
own rule (§9: "label = the commit's message when it has one"), applied to both forms. (c) FENCE
A — the lineage fence lives IN the operation (`notInLineage`, worded in the shared refusal
table): domain rules are enforced in Operations, never by views, and wing isolation ("the only
crossings are the explicit move/copy doors") would otherwise be one careless caller away; the
in-transaction lineageTree read is ∝ the lineage (P1 fine); scraps stays the shared room.
(d) NO undo entry — branchVariant's posture exactly as the precedent; the road back is deleting
the take, which is itself undoable. Row semantics, NULL parent (the same-block parent
convention + the edge already carrying lineage), refusal order and the pin list all sustained
as proposed. The new refusal's sentence joins the #264 wording list.

### U3b-5 — the origin re-aim and the panel's WHOLE retirement (G2's ruling, executed)

**Production.** Both origin doors (`EditorViewModel.revealCaretBlockOrigin`, `TakesViewModel.revealOriginBlock(ofBlock:)`)
build the history doors' request with `opening: .lineage(select: <the original>)` and ride the history doors' ONE road
(`CommandRouter.requestBlockHistory` → the detail's full pane; the model's `blockHistoryRequest` sheet where no detail
is). Gone: `CommandRouter.requestOriginHistory`/`showOriginHistory`, both models' `originHistoryRequest`, the three
origin sheets (`CommitBar`, `TakesBottomBar`, `WriteTakesPanel`), the inspector's `.blockHistory` case (+
`isBlockHistory`) and its mode-switch close, `Features/Tray/BlockHistoryPane.swift` WHOLE (`BlockHistoryModel`,
`BlockHistoryPane`, `CommitRowView`, `CommitReadingSheet`, `CommitRunEntry`, `CommitRowRule`, `HistoryRegionHeader`,
`BlockHistoryPaneOracle`, the jump door's rule and words, the region lines, the read-in-full words, the Mac
`deletedExplainer`, `noSavepoints`, `cameFromPathWithDoor`, the open-row anatomy of `CommitRowFace` and its ◦ glyph) and
`Features/Editor/SavepointHistory.swift` (`QuietRunRow` — the panel's only). Moved, byte-identical
(`Features/History/HistoryRequests.swift`: `RestoreLanding`, `BlockHistoryRequest` + its new `opening`,
`FocusedBlock`; `Features/History/HistoryWords.swift`: the Mac door words, the Bring back as a take words,
`restoreHelp`, `CommitRowFace`'s resting-words half). `TrayPath.originalsPath`/`originalsPathWithDoor` now name
`BlockLineagePath` (the guide sweep, U3b-6, lists the sentences that follow). The panel's "Open this note's tray" door
and the row-33 jump are NOT carried (P-U3b-6; the U3a record's G2.3).

**Every pin, by name** (each a JUSTIFIED EDIT in its file, the claim kept where the surface still carries it):

| Pin | Disposition |
|---|---|
| `BlockHistoryPaneTests.everyRegionReadsAsASectionAndTheListIsGone` | RETIRED (the panel's regions) |
| `BlockHistoryPaneTests.theHistoryPaneOffersPutBackAndUnarchiveAndNoPurgeDoor` | RE-POINTED — both faces' declared acts: Put back + Unarchive, no purge door |
| `BlockHistoryPaneTests.theMountedDetailOpensTheHistoryPaneInItsRealSidePanel` | RETIRED (panel in the side column; the full-pane hosts are `BlockHistoryHostTests`') |
| `BlockHistoryPaneTests.aHistoryRequestForAnUnmountedPostIsRefused…` | RE-POINTED — the origin seam's arms become Lineage-opening requests on the one seam |
| `BlockHistoryPaneTests.everyLiveTakesSavepointRunIsInThePane` | RE-POINTED — the shared `BlockHistoryExpansion` the Mac forwarder called |
| `BlockHistoryPaneTests.aRestoreFlushesThePendingBufferBeforeItLands` | RE-POINTED — `CommitsFaceModel.restore` (the same flush first) |
| `BlockHistoryPaneTests.theJumpOffersItselfOnly…` · `.theMountedPaneDrawsItsJumpDoorOnly…` (+ its mount helper) | RETIRED (the row-33 jump retired with the panel) |
| `BlockHistoryClarityTests.theRegionHeadersCarryCounts…` · `.anUnnamedMomentIsTitledByWhen` · `.anEmptyRegionDrawsNoHeader` | RETIRED (region headers; the read-in-full sheet's title) |
| `BlockHistoryClarityTests.readInFullShowsTheWholeMomentWithItsTwoFootDoors` | RE-POINTED — the face's pane is the whole moment, Restore + Bring back at its foot |
| `BlockHistoryClarityTests.bringBackAsATakeLandsTheTakeAndSaysSo` · `.bringBackUnderASealRefuses…` | RE-POINTED — `CommitsFaceModel.bringBackSelected` |
| `BlockHistorySealTests` (all four) | RE-POINTED — the face's `askRenameSelected` (field shut under a seal, the standing sentence) and `rename(commitID:to:)` |
| `BlockHistoryHostTests.aModeSwitchClosesThePaneTheModeOpened` · `.fromBlocksThePaneIsTheOneRightRegion…` (+ `historyOpen`, `inspectorColumnMounted`) | RETIRED (the panel's host; both rulings stand on the face's pins) |
| `BlockHistoryHostTests.theOriginDoorOpensTheLineageFaceOnTheOriginal` | NEW (red on the pre-U3b tree: no Lineage face) |
| `BlockHistoryCommitsCaptureTests` (disabled harness) | RE-POINTED — shoots `BlockHistorySurface` at the face's sheet width; in context through `requestBlockHistory` |
| `EditorSessionTests.restoreTargetsTheTakeTheRowBelongsToNotTheCaret` · `CommitFlowTests.restoreOfAPreSplitCommitAsksFirst` | RE-POINTED — `CommitsFaceModel` |
| `OutsideWriteRingEndTests.writePanelRingEnds…` · `.compareRingEnds…` | RE-POINTED — `CommitsFaceModel.restore` as the outside write |
| `SavepointRenameDoorTests` (all six) | RE-POINTED — `CommitsFaceModel.rename(commitID:to:)` |
| `ChromeMinHeightTests.sheetHostedRecoveryPanesNearZeroWidthProbeStayBounded` | RE-POINTED — the sheet-hosted surface, framed as its hosts frame it; bound = the sheet's ideal height |
| `CommitRestingPreviewTests` (two drawing pins) | RE-POINTED — `CommitsRailWords` (the rail's moment words, extracted so the pins read what the rail draws); the ◦ glyph line RETIRED |
| `RestoreLandingTests.aSheetRestoreLandsWhereTheRowRestoreDoes…` | RETIRED (the read-in-full sheet); the suite's restore driver RE-POINTED to `CommitsFaceModel` |
| `RestoreLandingInspectorTests` (the file, three pins) | RETIRED (the inspector host + the sheet; VX-668's fix pin `RestoreLandingRewriteHopTests` stays) |
| `RecoveryDoorsTests` — the declarations' two arms | RE-POINTED — both faces' declared acts |
| `RecoveryDoorsTests.theContextRowOpensThePeekAtTheOrigin…` | RE-POINTED — the door's request opens the Lineage face on the original; `LineageFaceModel` selects it, its node is the original's |
| `RecoveryDoorsTests.theCameFromRegionsTwoDoors…` · `.theCameFromsBringBackDiagnosesASealedNote` | RE-POINTED — `LineageFaceModel.putBack` (the same `PreservedOriginPutBack`); the tray-door half RETIRED (P-U3b-6) |
| `RecoveryDoorsTests.theRoutedActSpeaksWhereTheBlockHasNoOriginal` | the origin-slot arm RETIRED with the slot |
| `RecoveryDoorsTests` — the regions pin, the two Put back pins, the A1 mount pin, the A3 pin | RE-POINTED — `CommitsFaceModel` / a mounted `CommitsFaceView` |
| `OriginBlockDoorTests.theBoardsProjectionCarriesTheOriginsAndItsDoorActs` | RE-POINTED — the board's request opens the Lineage face on the original |
| `WriteTakesPanelRoutedTests.originOpensThePanelsBlocksOriginals` | RE-POINTED — the panel's request, `.lineage(select: original)` |
| `CommitsPageLedgerTests` — `theCommitsPageDrawsNoBezels` + `theQuietRunLineSpeaksInTheVoice` | RE-POINTED as ONE source pin over `Features/History/` (no bezels, no system caption/secondary) |
| `CommitsPageLedgerTests.theDetailsLineSaysOnlyWhatTellsCommitsApart` | RE-POINTED — the face's `meta` line |
| `CommitsPageLedgerTests` — the defining-sentence, open-preview, compact-row and resting-line pins | RETIRED (region line, open row, row anatomy); the defining line flagged P-U3b-9 |
| `SavepointOnLeaveTests` — `QuietRunRowCaptureTests` | RETIRED (`QuietRunRow` composes nowhere) |
| `TutorialWalkTests` — the no-purge arm, `theDeletedSpareTakeWaitsInTheBlocksPastAndComesBack`, the exits lesson's Bring back | RE-POINTED — both faces; `CommitsFaceModel.putBackTake` (U3a's owed drive); `LineageFaceModel.putBack` |
| `CapabilityRegistryTests.theSurfacesRenderExactlyTheDeclaredSurfaceActs` | the pane's line RETIRED; the Lineage face's line ADDED |

### U3b-6 — the guide sweep (G1, executed): every changed sentence, for #264 (her wordings to re-cut)

Mac only — the phone's Block History keeps its Came from region and every shared sentence's default. Drafted in the
guide's voice; the tutorial walk's finders still hold (the deleted-takes paragraph still opens "Deleted takes wait…",
the divide paragraph still names "See original from divide…"). **The real store's seeded guide is stale until Help ▸
Restore Field Guide… re-seeds it** (the U3a adjudication's owed item, behind the A1 rail).

| # | Where | Was | Now |
|---|---|---|---|
| W1 | `TutorialSeeder` — the tray lesson's last parenthesis | "It waits in the block it became, under Came from." | "It waits in the lineage of the block it became." |
| W2 | lesson "what a block leaves behind", ¶1 | "Everything this block has been opens in the panel on the right: every take's saved moments, the takes it archived, the takes it deleted, and where it came from." | "Everything this block has been opens in place of the page: every take's saved moments on one line, newest at the top, the takes it archived, the takes it deleted, and, one press away under lineage, where it came from. ‹ back returns you to the page." |
| W3 | same lesson, ¶3 | "Open history on either new block and its Came from region shows the original itself ("From a divide on ‹date› — the original is preserved") with Bring back beside it. Right-clicking the block ▸ See original from divide… and ⌘K land in the same place." | "Open the lineage of either new block (block ▾ ▸ Lineage, or lineage in its history) and the original is there itself, kept as lineage, with Put back beside it and its own takes and commits underneath. Right-clicking the block ▸ See original from divide… and ⌘K land in the same place, the original already picked." |
| W4 | same lesson, ¶4 (merges) | "…lists both of the blocks it joined in Came from, each with its own Bring back, three of them…" | "…lists both of the blocks it joined in its lineage, each with its own Put back, three of them…" |
| W5 | same lesson, ¶5 | "Deleted takes wait in the same panel, under Deleted takes, each with the days it has left." | "Deleted takes wait in the same history, at the foot of its line of moments, each with the days it has left." |
| W6 | the spare take's own text | "…then put me back from the block's history panel." | "…then put me back from the block's history." |
| W7 | lesson "the five places", Five | "…it opens the Block History panel: each live take's saved moments, the takes this block archived, the takes it deleted (with their clocks), and Came from, the blocks it came out of." | "…it opens the block's history in place of the page: every take's saved moments on one line, the takes this block archived, the takes it deleted (with their clocks), and, behind lineage, the blocks it came out of." |
| W8 | lesson "what a copy carries", ¶3 | "(Came from)" | "(in the block's Lineage)" |
| W9 | lesson "the two exits", "Now look." | "…press history: its Came from region lists both originals, … and a Bring back button that puts it into the note again … and this panel is where that line points." | "…open its lineage (block ▾ ▸ Lineage): both originals are there, … and a Put back that puts it into the note again … and this lineage is where that line points." |
| W10 | same lesson, the join paragraph | "…both originals kept whole under Came from." | "…both originals kept whole in the joined block's lineage." |
| W11 | same lesson, the closing paragraph | "…look inside what it became, under Came from." | "…look in the lineage of what it became." |
| W12 | `OpsRefusalCopy.receipt` (the cross-block join's quiet line) | "the ends joined — originals under Came from" | "the ends joined — originals in the block's Lineage" (≤ 100 chars kept: 95 in the pinned case) |
| W13 | `RecoveryCopy.trayRevealKeptInLineage` (the Mac passes its place; the phone keeps the default) | "…it lives under Came from in Block History, not in the tray." | "…it lives under the block's Lineage, not in the tray." |
| W14 | `TrayPath.originalsPath` (one constant — the divide ceremony's checklist + released-original note, the take cards' three lines, the merge arrangement's status, the merge ceremony's stay-behind line, the four merge receipts, the helper's merge entry follow it) | "Block History → Came from" | "the block's Lineage" |
| W15 | `TrayPath.originalsPathWithDoor` | "Block History → Came from (the history door in the note's bottom bar)" | "the block's Lineage (block ▾ ▸ Lineage in the bottom bar)" |
| W16 | `OperationError.notInLineage`'s words (`OpsRefusalTable`, the ruled fence) | — | "That block isn't part of this block's lineage in this wing — nothing was brought back." |

Left as they were, true again now that the Commits face carries "lineage ›" (U3a's note): the history door's help,
`.showBlockHistory`'s unavailable note, the ⌘/ helper's Block History row ("…and the block it came out of"). Not swept
(not G1's, still true on the Mac): `RecoveryCopy.trayNoTakesArchived` ("under Archived takes in Block History" — the take
dropdown's archived group). **Owed to her eye, not changed:** the ⌘/ helper's `block ▾` row lists neither History
(U3a) nor Lineage — a door with no helper line (P-U3b-10).

### U3b — what landed, one pointer per piece

- **The op** (U3b-P RULED): `Sources/VariorumCore/Operations/Operations+LineageBringBack.swift` —
  `bringBackFromLineage(_:onto:)`, `LineageTakeSource`, `lineageCrossesWing` (the ONE wing rule the face reads too);
  `OperationError.notInLineage`; its words in `App/Variorum/Shared/OpsRefusalTable.swift`.
- **The family as a value**: `Sources/VariorumCore/Domain/LineageFamily.swift` (order, places, acts, `opening`);
  `Sources/VariorumCore/Queries/LineageFamilyCounts.swift`.
- **The reused composition**: `App/Variorum/Variorum/Features/History/CommitsFaceView.swift` — `CommitsFaceBody` (the
  ONE pane+rail, extracted from the Commits face; both faces compose it), `CommitsRailWords`, `CommitsFaceStatusLine`,
  "lineage ›" on the crumb; `CommitsFaceModel.Role` (`.home` / `.relative`) + `LineageBringBack` (the one road both
  bring-back doors run) in `CommitsFaceModel.swift`.
- **The Lineage face**: `Features/History/LineageFaceModel.swift` (+ `LineageFaceCopy`, `WingCopy.lineageElsewhere`),
  `Features/History/LineageFaceView.swift` (+ `BlockHistorySurface` — the ONE host every surface/sheet composes, the
  request's `opening` choosing the face — and `LineageFaceOracle`).
- **Doors**: `.showBlockLineage` + the header's four `.surface` acts in `Registry/Capability.swift` /
  `CapabilityRegistry.swift`; block ▾ Lineage on both bars (`CommitBar.lineageRowTitle`); `requestBlockLineage()` on
  `EditorViewModel` and `TakesViewModel`.
- **The re-aim + retirement**: U3b-5 above. **The sweep**: U3b-6 above.

### U3b — PROVISIONAL, for #264 (the orchestrator lands QUESTIONS at the merge)

- **P-U3b-1** — where the Lineage face opens: the origin door's original; else (lineage ›, block ▾ Lineage) the block
  it came out of — the nearest ancestor, first drawn (A's reach: lineage › then its commits, one press); else this
  block. Alternative: always on this block.
- **P-U3b-2** — the geometry: ONE vertical family list ABOVE the pane+rail (A's map turned vertical, her "as in A, but
  with the verticle view … as in B"), about seven rows before it scrolls on its own; generations as bands (B's gaps),
  older above; within a generation by the connecting edge's stamp, then id; a block met twice (a duplicate's copy is
  a descendant AND a version) drawn once, at its first place. Alternative: the family as a third column, or in the
  rail's place (B's drawing, which loses the selected block's rail).
- **P-U3b-3** — the row's words: verbs "divided · merged · extracted · copied (Snippets copies and duplicates alike) ·
  a version · related (an edge with no act)"; places "here · this note · in “‹title›” ( · a saved version) · in
  Snippets · kept as lineage · set aside · in the Trash · in another library — the wing “‹name›”"; counts "N takes ·
  M commits" (active takes; the commits of live takes).
- **P-U3b-4** — a RELATIVE's moments are read, compared (against the block you came from's now) and brought back onto
  the block you came from — never restored, renamed, unarchived or put back in place from here, and its deleted takes
  are not listed (a lineage block is not edited from this face).
- **P-U3b-5** — a Trash member and another wing's member are NOT selectable (no pane+rail); the Trash row keeps its
  first words, muted; the other-wing row shows no words (#166(e)) and "go to ‹wing› ›" switches the wing (the Compare
  board's road).
- **P-U3b-6** — not carried from the panel: "Open this note's tray" (the tray keeps its masthead door) and the row-33
  jump (U3a's G2.3).
- **P-U3b-7** — Put back on a SET-ASIDE (archived) member runs the tray's `unarchiveBlock` road; a receipt for a
  landing in ANOTHER note names it ("In “‹title›”: Put back where it came from.").
- **P-U3b-8** — the Lineage door always opens (block ▾ and lineage › are always drawn); a block with no lineage shows
  "Nothing came before or after this block — it was never divided, merged, extracted or copied."
- **P-U3b-9** — the panel's commit-defining meaning line ("Each take's saved moments — Restore loads one back into its
  buffer.") has no place on the face; "saved moment" defines commit in Restore's and Bring back's hover words. Should
  the face carry a defining line?
- **P-U3b-10** — the ⌘/ helper's block ▾ row lists neither History (U3a) nor Lineage.
- **P-U3b-11** — "‹ history" returns to the Commits face re-seated on its opening (not the moment last read there);
  the crumb reads "‹note› › block N/M › lineage" with "‹ history" at the right; ↑/↓ step the selected block's moments.
- **P-U3b-12** — the cross-block receipt: "Brought back as a take on this block — it's the last take in its fan." /
  "Brought back as the take “‹label›” on this block — …"; the header verb "Compare with now"; the header and pane
  help sentences (`LineageFaceCopy`); the door's verb "Block Lineage", its row "Lineage".
- **P-U3b-13** — the fence's refusal (W16) and the sweep's wordings W1–W15 (U3b-6).

### U3b — what is OWED, and to whom

- **The closing stage window — the Mac runs** (suite-level `-only-testing`), on top of U3a's list:
  `VariorumTests/LineageFaceModelTests`, `VariorumTests/LineageFaceDoorsTests`, and every suite U3b-5/-6 touched —
  `BlockHistoryPaneTests`, `BlockHistoryClarityTests`, `BlockHistorySealTests`, `BlockHistoryHostTests`,
  `EditorSessionTests` (incl. `CommitFlowTests`), `OutsideWriteRingEndTests`, `SavepointNamingTests`
  (`SavepointRenameDoorTests`), `ChromeMinHeightTests`, `CommitRestingPreviewTests`, `RestoreLandingTests`,
  `RestoreLandingRewriteHopTests`, `RecoveryDoorsTests`, `OriginBlockDoorTests`, `WriteTakesPanelRoutedTests`,
  `CommitsPageLedgerTests`, `SavepointOnLeaveTests`, `TutorialWalkTests`, `CapabilityRegistryTests`,
  `CrossBlockCompoundTests`, `NoteTrayTests`, plus the neighbours the phrase moved under: `MergeArrangementTests`,
  `ProseCutGeometryTests`, `MergeCeremonySheetTests`, `IAAndTrashShapeTests`, `RecoveryExplainerTests`,
  `HelperCurrencyTests`, `ShortcutCatalogTests`, `OpsRefusalTableIntegrityTests`, `DeadVocabularyTests`,
  `CommitVocabularyTests`, `CommandRoutingTests`, `CanvasAndPoolTests`, `ModeSwitchCarryTests`, `ShellChromeTests`;
  and the phone's `VariorumMobileTests/MobileBlockHistoryTests` + `MobileNoteTrayTests` (the shared
  `RecoveryCopy` default — compiled here, unchanged in behaviour).
- **The walk (appended to U3a's twelve; row 12 is SUPERSEDED — "See original from…" opens the Lineage face now, not
  the old panel).** One capture per row, both voices: (13) block ▾ ▸ Lineage on a merged block → the family older
  above, both sources kept as lineage, this block marked, the face open on the first source's pane+rail; ↑/↓ swap its
  moments; (14) "lineage ›" on the Commits face → the same; "‹ history" back; (15) THE ORIGIN DOOR: a divided block's
  right-click ▸ See original from divide… (and ⌘K's twin) → the Lineage face with the original selected; (16) THE
  ANCESTOR SWAP: click the other source → its take dropdown, its rail, its commits; a commit's Bring back as a take
  from the pane's foot → the receipt, the take at the merged block's fan end (Takes); (17) the header's Bring back as
  take → receipt; Compare with now → two boxes (the source now · this block now); (18) PUT BACK on a kept original →
  "Put back where it came from.", the row then "this note"; (19) THE TRASH NODE: delete a source (or a descendant) →
  its row muted, no acts, not selectable; (20) THE CROSS-WING GO-TO: extract and move a block to another wing → its row
  names the wing, no words, "go to ‹wing› ›" switches the wing; (21) a plain block's Lineage → the empty line; (22) a
  sheet host (the book's inline editor, Write's take panel) → block ▾ ▸ Lineage in the sheet, ‹ back closes it; (23)
  the guide, re-seeded on the DEV store: lessons "what a block leaves behind", "the five places", "the two exits" read
  true against the surface.
- **The closeout** — the real store's guide re-seeded (Help ▸ Restore Field Guide…, A1 first); canon: SurfaceContracts'
  Block History bullet rewritten for the History & Lineage surface + the Lineage face, AppSpec §9's
  `bringBackFromLineage` line (the ruled semantics, U3b-P RULED), AppSpecRecord's entry; QUESTIONS #264 gathers
  P-U3a-1…11, P-U3b-1…13, W1–W16.
- **MOBILE PARITY (drafted for the closeout):** the phone's Block History is untouched (its sheet, its Came from region
  and its Bring back); the Mac's History & Lineage surface — the Commits face, the Lineage face, the cross-block Bring
  back as take — has no phone face yet: a `notes/MobileSoul.md` ledger row (a VM ticket for the board).

### U3b — END (the suites, on the committed tree; headless)

- `swift build` — Build complete. `LineageBringBackTests` 12/12 · `LineageFamilyTests` 7/7.
- **`swift test --filter VariorumCoreTests` → "Test run with 3866 tests in 522 suites passed after 272.989 seconds with
  5 known issues"** (U3a's 3847 + this unit's 19; the five known issues are the standing `withKnownIssue` arms).
- `swift test --filter 'VariorumMCPTests|StringsWorkbookTests'` — `StringsWorkbookTests` 32/32 green; `VariorumMCPTests`
  627 tests, FOUR failures, all socket-timing under a load average of 6–11 (other sessions on the Pro):
  `MCPDiscoverProbeServerTests.claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes` (`socket.nextResponse()`
  nil), `MCPStopRoadsServerTests.aClientThatLeftBeforeTheQuitKeepsItsOwnLine`,
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (44 s against a 15 s bound)
  — U3a's named trio — and `MCPPreInitializeWindowTests.aBareOpeningIsAnsweredBeforeTheReadBlocks` (the window's answer
  late). **Re-run alone: `swift test --filter 'MCPDiscoverProbeServerTests|MCPStopRoadsServerTests|
  MCPHarnessTimeLimitTests|MCPPreInitializeWindowTests'` → "Test run with 22 tests in 4 suites passed after 2.309
  seconds".** This unit's diff carries no `Sources/VariorumMCP`, `Sync/` or `Server/` line (the MCP target compiles
  against the one new `OperationError` case and nothing else). Recorded as load flakes; the closing window's MCP re-run
  reads them again.
- **App targets COMPILE only** (no stage): `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration
  Debug build-for-testing` → "** TEST BUILD SUCCEEDED **"; `xcodebuild -scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' build-for-testing` → "** TEST BUILD SUCCEEDED **" (the shared `RecoveryCopy` and
  `OpsRefusalTable` edits).
- `Tools/verify-pins` → OK both graphs (16 + 15 pins).

### U3b — self-assessment (for the cold reviewer's read, not instead of it)

- **The reuse is real, and it bent the Commits face's model.** `CommitsFaceBody` is the one pane+rail; the Lineage
  face composes it over a member through `CommitsFaceModel`'s new `Role`. The relative role branches the acts in four
  places (`paneActs`, `openCompare`, `bringBackSelected`, the swapper's groups) and reads the home block's takes for
  Compare's "now". Read those branches hardest — a relative must never reach Restore/Rename/Put back/Unarchive (pinned:
  `selectingAMemberSwapsThePaneAndRailToIt`), and the foot's Bring back must go through the fenced op, never
  `bringBackCommitAsTake` (it does: `LineageBringBack.run`).
- **The model grew past U3a's ≈690 lines** (now 821). U3a named Compare's state as the split seam; U3b did not split
  it (one unit, one surface). P-9 is the reviewer's call.
- **The fence is in the op, and the face reads the op's own wing rule** (`Operations.lineageCrossesWing`), so a member
  the face offers is a member the op accepts. The op reads `Queries.lineageTree` inside its transaction (∝ the target's
  lineage — U1's P1 pins bound it).
- **The retirement deleted three test-host pins and one whole suite** (`RestoreLandingInspectorTests`) whose STRUCTURE
  (the inspector panel, the read-in-full sheet) no longer exists; each is named in its file and in U3b-5's table. The
  VX-668 fix pin (`RestoreLandingRewriteHopTests`) stays. The judgment to read: whether the inspector suite's guard has
  a full-pane analogue worth a new pin (the face in the full pane lands no page — U3a's P-U3a-10 "elsewhere a receipt").
- **`TrayPath.originalsPath` moved for EVERY Mac sentence at once** (W14/W15) — the constant's purpose, but it means
  eight receipts and explainers changed words in one line; all listed for her.
- **Not walked, not run.** Every Mac claim above is compiled, not observed — the Lineage face's geometry (the family
  band's height, the header line under it, the composition below at the detail's width) has had no eyes on it.


## U3b ADJUDICATION (the orchestrator, 2026-11-06)

**Verified:** pushed to ec90f46fa, tree clean; `LineageBringBackTests` + `LineageFamilyTests`
re-run independently, 19/19 green. Core 3866 passed (the 5 known issues are the standing
`withKnownIssue` set); the four MCP reds are the socket-timing class (the fourth,
`MCPPreInitializeWindowTests.aBareOpeningIsAnsweredBeforeTheReadBlocks`, is NEW to the list —
same class, green alone, no MCP line in this diff; the window's MCP re-run reads it again and
it joins the flake ledger if it recurs).

**Accepted with named justification:** `RestoreLandingInspectorTests` deleted whole (its
subject — the inspector panel and read-in-full sheet — no longer exists; the bug's own fix pin
`RestoreLandingRewriteHopTests` survives); the `TrayPath.originalsPath` wording moving its
eight sites through the one constant (the W-list carries it for her pass); `CommitsRailWords`
as a testability seam. **Standing concern for the ladder, named in the implementer's own
self-assessment:** `CommitsFaceModel` at 821 lines (P-9's class — the TakesViewModel
counterexample was 890). **P-U3b-1…13 + W1–W16 join #264.** The mobile-parity draft (no phone
face; a VM ticket at closeout) stands.

**THE BUILD IS COMPLETE.** The ladder opens: one ladder over the run's whole diff
(origin/main…vx-827-lineage), fresh `fable-reviewer`, REVIEW_PROMPT verbatim; findings land
repo-first in `notes/plans/fixes/vx-827-ladder-round1.md` before any fix session sees them.

**Window terms, two riders (nov5, 2026-11-06):** the MCPPreInitializeWindowTests load red is
VX-850's — our data point COMMENTED there (no new ticket; the U3b adjudication's flake-ledger
line is satisfied by that comment). The READY message to nov5 must carry the WHOLE
`-only-testing` type list for the Mac batch; nov5 checks every name against the worktree
before the GO.

**Walk trap (nov5, 2026-11-06):** vx-819 quit the dev-store Debug app FULL-SCREEN tonight, so
our walk's launch will likely restore full-screen — where cliclick's typing (t:/kp:) stops
landing while clicks still work (System Events keystrokes do work). The walk's FIRST step is
⌃⌘F to a normal window; the window is left WINDOWED at quit.

## LADDER ROUND 1 — DISPOSITIONS (the orchestrator, 2026-11-06; the findings file is
`notes/plans/fixes/vx-827-ladder-round1.md`, committed by the reviewer at 840f91f92)

**R1-F1 [MINOR, the flush gap] — FIX THIS RUN.** The mechanism is traced and real (a relative
placed in another note, live in a second window with pending typing → a stale pane "now" and a
stale minted take), flush-first is the standing precedent, and the reviewer names a workable
red-on-old pin. Goes to the U3b implementer verbatim for agree/dispute; on agreement it applies
the fix (flush the source block's placed note inside `LineageBringBack.run`; relative-role
`start()` flushes the relative's placed note) with the pin red on old, revert-verified.
**R1-F2 [MINOR, the raw-wing fence] — RECORD, NOT A LADDER FIX** (the reviewer's own proposed
disposition): the fence errs CLOSED (nothing unsafe; a dangling wing is a sync-only state no
local op mints), and a pin would be hollow without hand-built rows. JOINS the liveTagIDs
born-ticket as one dangling-wing facet pair (Low · Suspected · Debt, filed at closeout).
**R1-F3 [NIT, canon drafts] — DONE BELOW** (D-U3-1/-2 drafted; the closeout's landing is now
mechanical).
**R1-F4 [NIT, ✕ semantics + the two nows] — #264** as their own P-lines: **P-U3a-5b** — ✕
renders on every box while three stand and removes any down to two (the defensible reading,
as built); **P-U3b-14** — on the Lineage face "now" is two things: the pane's against-now wash
compares against the RELATIVE's own take-now, the header's Compare with now against the HOME
block's now (both leans kept; hers to re-cut).
**R1-F5 [NIT, the `mcpShownTake` name] — FIX THIS RUN as a mechanical rider** on R1-F1's core
touch (the reviewer's "rename at next core touch" — this IS the next core touch): a faithful
generic name (the implementer picks; the rule is a rendered-take read, not an MCP fact), call
sites swept, no behavior, pins compile unchanged.

## DRAFT CANON DELTAS — D-U3 (land at closeout, two-file rule)

**D-U3-1 (SurfaceContracts, The note — REPLACES the "Block History (vx-440, R-440-3)" bullet;
VX-674's unnamed-commit-rests-on-first-words and VX-668's restore-landing rules survive inside
it):** *History & lineage (VX-801): one surface, two faces; every history door opens it and the
Block History panel is retired. Commits is the default face: the selected moment's full text as
a reading pane (plain · against-now washes — a view-time word compare, stored nowhere) beside
the all-takes rail (newest first, each line its take's chip, the take dropdown filtering to one
take led by its "take now", quiet runs folded, an AI edit's before/after pair never folding,
deleted takes at the foot with Put back); ↑/↓ steps the pane; a moment's acts are Restore ·
Bring back as take · Compare · Name, an unnamed moment resting on its first words; Compare is
two swappable boxes with "now" always offerable as a standing third. The Lineage face is behind
its own door: the family vertical, older above; selecting a member swaps the same pane and rail
to that block; member acts Put back · Bring back as take · Compare with now; a Trash member
muted with no acts; another wing's member named with go-to only; the origin doors land here
with the original selected. (notes/plans/fixes/vx-827-lineage.md, THE DESIGN MEMO)*
**D-U3-2 (AppSpec §9, beside bringBackCommitAsTake):** *bringBackFromLineage(source, onto) —
mints a take on the target block from a lineage relative's take or commit: text as stored,
label = the source's name when it has one, fan's end, never chosen, never born locked, NULL
parent (the existing edge carries the lineage); no touch, no churn, no undo entry (delete the
take is the road back); refuses a dead or sealed target, a dead source, and a source outside
the target's lineage neighbourhood (`notInLineage` — the fence lives in the operation; scraps
stays the shared room). (vx-827-lineage.md, U3b-P RULED)*

### U3b — FIX LEG (ladder round 1, the two items the orchestrator sent; dispositions in "LADDER ROUND 1 — DISPOSITIONS")

**R1-F1 — AGREE** (traced again here, not taken on the reviewer's word): `CommitsFaceModel.start()` flushes only its own
`postID` — the HOME note; `LineageBringBack.run` flushes nothing; `bringBackFromLineage(.take)` copies `working_text`
as STORED. A relative placed in ANOTHER note, live in a second window with typing the debounce has not written, is
read stale on the pane ("the take now") and brought back stale (the minted take misses her last words). The `.commit`
form copies an immutable snapshot (I5) and needs nothing. **The fix:** `LineageBringBack.run` resolves a `.take`
source's live placement and flushes that note FIRST — and, the flush road's own contract ("a caller whose act COPIES
the store must consult it" — `AppSession.flushExistingAutosave`, the `VersionActs` precedent), a flush that leaves
bytes pending refuses with the standing `OpsRefusalCopy.unsavedChanges` rather than copying stale words; the
relative role's `start()` flushes the relative's placed note too (`flushBeforeReading`).

**The behavioral revert, ANNOUNCED BEFORE IT RUNS** (the pins are Mac-target — the autosave coordinator is
`AppSession`'s — so headless they are written and compiled here; the RUNS are the closing window's, in this order:
fixed tree green → revert → red → restore):
- **Revert A** (the bring-back half): in `LineageBringBack.run`, delete the `.take` flush guard (the `if case .take …
  throw Refusal.unsavedChanges }` statement). Pin `LineageFaceModelTests.aRelativeInAnotherNoteIsFlushedBeforeItsWordsComeBack`
  must go RED (the minted take holds the stored "Extracted part." instead of the typed "Extracted part, retyped.").
- **Revert B** (the read half): in `CommitsFaceModel.flushBeforeReading`, delete the relative branch (keep the
  `postID` flush). Pin `LineageFaceModelTests.aRelativesPaneReadsItsNoteAfterItsPendingTypingLands` must go RED (the
  stored take still reads the old words after the face's read flush).

**R1-F5 — AGREE**: `Queries.mcpShownTake` → `Queries.shownTake` (the structural ops' rendered-take rule, not an MCP
fact); a pure rename, its two call sites swept (the Commits face model; ONE line in
`Sources/VariorumMCP/MCPWriteTools+Edit.swift`, under the orchestrator's sweep authorization — the run's only
VariorumMCP touch from U3b).


**R1-F1 fix shape, two rulings (the orchestrator, 2026-11-06):** (1) the CONSULT-AND-REFUSE line
STAYS — `flushExistingAutosave`'s own contract says a caller whose act copies the store must
consult it (the VersionActs precedent), and the refusal reuses the existing `unsavedChanges`
sentence: an existing contract honored, not new behavior; the record notes the sentence reuse.
(2) the Mac-target pin's red-on-old RUN is ACCEPTED as deferred to the closing window — the
coordinator lives in AppSession, so headless can only write and compile it; CONDITIONS: the
behavioral-revert recipe lands in the record now (mechanical enough for the window session to
run it cold), and the window's Mac batch runs that pin RED ON OLD by the recipe, then green on
the fix, BEFORE the walk — the fix is not "landed" until that run. R1-F5's one-line VariorumMCP
call-site sweep is within the rename authorization.

#### R1-F1 — what was built, and THE RECIPE the closing window runs cold

**Built (429218982):** `LineageBringBack.run` (in `App/Variorum/Variorum/Features/History/CommitsFaceModel.swift`)
resolves a `.take` source's live placement (`LineageBringBack.placedNote(session:takeID:)`) and flushes that note
first; when the flush answers NOT clean it throws `LineageBringBack.Refusal.unsavedChanges`, whose sentence REUSES the
standing `OpsRefusalCopy.unsavedChanges` ("Unsaved changes couldn't be written — resolve that first, then retry." —
the `VersionActs` precedent, the orchestrator's ruling (1): no new sentence); both callers (`CommitsFaceModel.
bringBackFromLineage`, `LineageFaceModel.bringBack`) speak it as a refusal. `CommitsFaceModel.flushBeforeReading()`
(what `start()` now calls) flushes the face's own note and, for a RELATIVE, the note it is placed in
(`LineageBringBack.placedNote(session:blockID:)`). Pins: `LineageFaceModelTests.aRelativeInAnotherNoteIsFlushedBeforeItsWordsComeBack`
and `.aRelativesPaneReadsItsNoteAfterItsPendingTypingLands` (fixture `pendingRelative`: an extracted block moved to a
second note "Elsewhere", its take's typing recorded on Elsewhere's autosave coordinator with a 30 s debounce — written
by nothing but a flush).

**THE FIX IS NOT LANDED until the closing window's Mac batch runs this, BEFORE the walk** (the orchestrator's ruling
(2)). From `~/dev/variorum-vx-827/App/Variorum`, under the held stage claim, the tree clean:

1. **Green on the fix:** `xcodebuild -scheme Variorum -destination 'platform=macOS' test
   -only-testing:VariorumTests/LineageFaceModelTests` → every test passes (12, the two F1 pins among them).
2. **Revert A** (the bring-back half): `git apply ../../notes/plans/fixes/vx-827-reverts/r1-f1-revert-A-bringback.patch`
   (deletes the five-line `.take` flush guard in `LineageBringBack.run`). Run step 1's command. **Expected RED:**
   `aRelativeInAnotherNoteIsFlushedBeforeItsWordsComeBack` fails at `minted?.workingText == "Extracted part, retyped."`
   — the minted take holds the stored `"Extracted part."`. (`aRelativesPaneReads…` stays green under A.) Restore:
   `git apply -R ../../notes/plans/fixes/vx-827-reverts/r1-f1-revert-A-bringback.patch`.
3. **Revert B** (the read half): `git apply ../../notes/plans/fixes/vx-827-reverts/r1-f1-revert-B-read.patch` (deletes
   the relative branch of `flushBeforeReading`, keeping the own-note flush). Run step 1's command. **Expected RED:**
   `aRelativesPaneReadsItsNoteAfterItsPendingTypingLands` fails at `stored == "Extracted part, retyped."` — the stored
   take still reads `"Extracted part."`. (`aRelativeInAnotherNote…` stays green under B — the bring-back road flushes
   on its own.) Restore: `git apply -R ../../notes/plans/fixes/vx-827-reverts/r1-f1-revert-B-read.patch`.
4. `git status` clean; record the three runs' "Test run with N tests" lines and the two red failure lines here.

Both patches were generated from the committed fix by deleting exactly those lines and `git diff`, and both
`git apply --check` clean against 429218982; each compiles on its own (an unused helper/case is all either leaves).

