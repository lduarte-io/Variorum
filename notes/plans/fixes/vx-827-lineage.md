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
| U2-8 | END: headless core + MCP suites, `Tools/verify-pins`, App compile-only; self-assessment | NEXT |

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
