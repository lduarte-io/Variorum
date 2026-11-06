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
| 2 | U2 — VX-810 + VX-815 | NOT-STARTED |
| 3 | VX-801 design mockup + sitting | NOT-STARTED |
| 4 | U3 — VX-801 build | NOT-STARTED |
| 5 | Ladder (whole diff) | NOT-STARTED |
| 6 | MCPSpec/SurfaceContracts deltas + AppSpecRecord entry (closeout, two-file rule) | NOT-STARTED |
| 7 | Closeout ritual (tickets, handoff, canon-size, worktree removal) | NOT-STARTED |

## SITTING RECORD

*(Her rulings land here verbatim-faithful, same turn.)*
