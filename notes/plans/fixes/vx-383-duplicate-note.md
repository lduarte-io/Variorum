# VX-383 — Run: Duplicate a note — the Mac door and the wire (VX-284 part C)

**STATUS: OPEN — kicked off 2026-10-17 at her sitting.** Run ticket **VX-383** (project *v1 release readiness*; a
child of the umbrella **VX-284**) · branch `vx-383-duplicate-note` · worktree `~/dev/variorum-vx-383` on the Pro ·
PR `VX-383: …` (merge commit only). Shape: `/architect-phase vx-284`, split at her word into three runs (below).
Orchestrator: the sitting's session (Fable 5.1), which holds the architect mandate for this run.

**Members (sub-issues of VX-383):** **VX-372** (a direct duplicate door, with tags / without tags; a duplicate with
tags counts as tagging; Save Version → Promote ends the same way) + **VX-371** (the AI's `duplicate_note` files its
copy into a book, as `create_note` can). Her 2026-10-15 word on both tickets: designed together, proven by ONE
real-client live round, never split apart.

## The split (her rulings at the 2026-10-17 kickoff sitting — the question tool, recommended options first)

Her opening words: *"I'd like to /architect-phase vx-284 but I think it has to start with a separation of concerns
because the phase has grown too large. what can we work on in parallel? You can certainly split out VX-216 and I
don't know what VX-250 is exactly, but if it's my copy calls it can probably wait for a separate session with me. I'd
like to run what can be run without my involvement and appropriately split up - if that means gatherings & tags
separately, that's fine. I also know an MCP item has been added to this"* — and, mid-turn: *"we also can't do
anything with sync / custody."*

- **Split:** "Three runs + VX-216 alone (Recommended)" — **VX-381** Run: Gatherings & tags (part A: VX-250 · VX-240 ·
  VX-241 · VX-249 · VX-247 · VX-111 · VX-194); **VX-382** Run: Book view doors & reds (part B: VX-303 · VX-304 ·
  VX-291 · VX-21 · VX-69 · VX-77 · VX-115); **VX-383** this run (part C: VX-372 + VX-371). **VX-216** stays a direct
  child of VX-284, author-attended, after VX-381 merges (the same menus and sheets). VX-284 is the UMBRELLA and closes
  when the three runs and VX-216 are Done. The A and B kickoff files: `notes/plans/fixes/vx-381-gatherings-tags.md`
  and `notes/plans/fixes/vx-382-book-view-doors.md` (each with a paste-ready kickoff prompt at its top).
- **VX-250 is not a pending copy call** (said to her at the sitting): its four items are her QUESTIONS #217 answers,
  exact words given; its one open decision (whether the shared collect receipt shortens with the mint receipt) is a
  PROVISIONAL for VX-381's orchestrator. So part A runs without her.
- **This session orchestrates:** "Run C, Duplicate (Recommended)".
- **Run C's cold reviewer:** "Fable (Recommended)" — `fable-reviewer` at xhigh, fresh per round, cross-model.
- **Effort:** "xhigh (Recommended)" for every implementer and reviewer across the three runs.
- **Sync / custody:** none of the seventeen members touches `Sources/VariorumCore/Sync/`, custody or the Keychain
  (checked file by file at the sitting); VX-378 keeps the one Sync/-or-custody slot. VX-240's "Opening your library…"
  face is a chrome arm in the Settings scene, not custody code.

## Binding principles — the 13b constitution, copied verbatim as the skill requires

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.


*(The skill's application notes bind too — P-1's scope is the ROUTED vocabulary grown incrementally; P-3 keeps two
surface kinds; layer placement; the overlay/sink delivery law. This run touches no surface or overlay; P-1 and P-4
are the ones it meets.)*

## Required reading for every session of this run

CLAUDE.md and its auto-loaded canon · **`notes/MCPSpec.md` IN FULL** (this run changes a wire tool, its answer and
the AI's docs) · `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` §U6a (D-311-1…8 and THE ORCHESTRATOR'S RULINGS
ON U6a's FORKS — the as-built `duplicate_note`) · `notes/QUESTIONS.md` #227 (P-VX311-1…3, P-VX361-1) ·
`notes/plans/phase-17-standing-fixes.md` B3 row 3 and P-17y-B3-c1 (the tag ride as a ROW copy — superseded for this
door by VX-372) · `notes/SessionResiliencyProtocol.md` · this file in full. No `Sync/`, custody, Keychain or
editor-seam file is touched; the implementer says so in its record if a trace leads there, and stops.

## The design (the architect's, 2026-10-17 — built to her two tickets; every fork recorded with its options)

**Where the code is (traced read-only at the kickoff):**
- Her door's body: `Operations.duplicateAsVersion` → `duplicateAsVersionBody` (`Sources/VariorumCore/Operations/
  Operations+Versions.swift` ~:217–240): `copyPost` (whole fans, comments, names, per-block `derived_from`, one
  `version_of`) then `copyLiveTags` (`Operations+Ownership.swift:120` — a ROW copy of the source's live
  applications in its wing; no intake). ONE undo entry, `registerMintedContainerEntry` (`Operations+UndoInverses
  .swift:546`): the inverse tombstones the copy through the container-delete road, which tombstones memberships and
  tag applications on the same stamp; the redo revives on that stamp.
- The wire's body: `Operations.duplicateNoteForClient` (`Operations+MCPDuplicate.swift`) — the same body behind a
  `WriteGuard`, the client's undo label. The tool: `Sources/VariorumMCP/MCPWriteTools+DuplicateNote.swift`
  (`performDuplicateNote` + `guardDuplicate`: READ on the source, the fence, WRITE NEW on the source's wing via
  `decideWing`; both once grants spent as one union); the catalog entry `MCPToolCatalog.duplicateNote` (~:1002,
  `scopes: [.wing]`); the answer = VX-252's records + `source_note_id` + `landed`; `MCPSession.swift:147` names it
  in the instructions ("For a revision, copy the note with duplicate_note…").
- The one tag-application road: `Operations.insertPostTag` (`Operations+Intake.swift:39`) — every living book whose
  rule hears the tag decides by `IntakeDecision` (seat or bell, capacity, ownership). `apply_tag` on the wire is
  WRITE NEW and "books that collect by that tag hear it, as when the author tags"; `create_note`'s `tags` header
  applies through the same road at WRITE NEW (VX-361). So an AI copy whose tags are APPLIED is the wire's existing
  posture, not a new reach.
- `create_note`'s book filing: `book_id` at WRITE NEW on that book, optional `section_id` (a chapter of that book;
  any other id answers `add_note_to_book`'s ONE chapter sentence), `MCPWriteTools.swift` ~:80, :240–260, :524.
- Her existing Duplicate as Version doors (NOT in the registry): the Library's right-click
  (`LibraryCatalogView.swift:1318`), the Pool's (same view), the Takes board's ▾ (`TakesBoardView.swift:619`), the
  Lenses board's, the Book Panel's membership chip (`MembershipChip.swift:524`); `LibraryViewModel.duplicateAsVersion`
  and `TakesViewModel.duplicateAsVersion` call the op. The tutorial seeder mints the versions lesson's twin through the
  same op on a QUIET facade (`TutorialSeeder.swift:1886–1898`, tolerating `alreadyTagged`).
- Promote: `promoteNoteVersion` (`Operations+NoteVersions.swift:315`) flips `archived_at`/`locked` and nothing else
  — the promoted copy wears NO tags (`mintNoteVersion` copies none; VX-336's D-311-1 measured it). Not undoable by
  her ruling.
- The phone: no duplicate door, no Versions door (grepped) — **MOBILE PARITY: nothing mobile-visible.**

**D-C-1 — the op grows a TAG CHOICE; "with tags" APPLIES.** `duplicateAsVersion(_:tags:)` with
`DuplicateTags = .applied | .none` (names the implementer's): `.applied` copies the family, then applies each live
tag the source wears in its wing THROUGH `insertPostTag` (application order kept; a tag the copy already wears —
impossible on a fresh copy, but the guard stays — skips), so intake decides exactly as when she tags: a book that
joins quietly SEATS the copy, one with Arrivals on BELLS it, capacity waits at the door, an owned-elsewhere note
bells. `.none` applies nothing. This SUPERSEDES P-17y-B3-c1 for this door (the row copy is retired from the duplicate
body; `copyLiveTags` keeps its other callers). ONE transaction; ONE undo entry — `registerMintedContainerEntry`
already covers the seats (the container tombstone takes memberships and applications on one stamp; the redo revives
them on it) — the implementer PINS it: an undo after a seat leaves the book without the copy, a redo brings the seat
back, and a seat she judged between (a dismissal) stays decided. Finished, sealed and archived books stay paused as
today (the intake table). `duplicateAsVersionBody` grows the same parameter so the wire can never drift (D-311-1).

**D-C-2 — the Mac doors: TWO capabilities, declared once (P-1).** `.duplicateNoteWithTags` and
`.duplicateNoteWithoutTags` (ids the implementer's), scope the NOTE, doors `[.menuBar, .contextMenu, .palette]` (and
whatever door enum the note ▾ menu uses — the implementer reads `CapabilityRegistry.swift`'s note-scoped neighbours
and follows them), no shortcut (none asked), availability wherever a note is the target (the Library/Pool rows, the
note ▾ menu, ⌘K with a note shown, the Takes/Lenses boards, the Book Panel chip), `.unavailable` with an honest note
otherwise; a version-history note and a scraps group are never targets (her door's own refusals stand). The existing
inline doors keep working and now ROUTE to the with-tags act (their labels follow P-C-1). The registry walk gains the
two acts; `OpsRefusalCopy` carries any new refusal. **P-C-1 (PROVISIONAL, for her VX-234 wording pass):** the verbs
are her words — **"Duplicate with Tags"** and **"Duplicate without Tags"**; the label "Duplicate as Version" RETIRES
from every face (the versions machinery and the `version_of` edge are unchanged), so the guide's three mentions
(`TutorialSeeder.swift` ~:787, :1849–1851, :1883) read the new verb and the real store's field guide is re-seeded at
the closeout behind the A1 rail (the skill's rule). Options recorded: (a) BUILT — her words; (b) keep "Duplicate as
Version" as the with-tags verb and add only "Duplicate without Tags" (no lesson churn, but not her words).

**D-C-3 — Save Version → Promote ends like Duplicate with Tags (her "I suppose").** `promoteNoteVersion` applies the
ORIGINAL note's live tags (its tags NOW, in its wing) to the promoted note through `insertPostTag` in its own
transaction — so a promoted version wears what a duplicate with tags would and the books hear it. Still no undo entry
(her one-way ruling stands; the seats ride the act). **P-C-2 (PROVISIONAL):** (a) BUILT — the original's current tags
applied; (b) leave promote tag-less and say so (her lean that a diverged copy is meant to differ — but that lean was
Diverge's, and her words here ask for alignment); (c) the version's tags at SAVE time (not stored today — would need a
schema change; rejected, marker 13 untouched).

**D-C-4 — the wire: `with_tags` + `book_id`/`section_id` on `duplicate_note` (VX-371 + VX-372's wire edge).**
- `with_tags` (boolean, **default true** — her door's default and the as-built carriage; the copy's applied tags are
  the wire's existing WRITE NEW posture, `apply_tag` + `create_note`'s header — P-13nb-U4-16 is not met: the books'
  rules are hers and the client already reaches the source). **P-C-3 (PROVISIONAL):** (a) BUILT — default true;
  (b) default false (a bookless, tagless copy — safer-looking but not her door).
- `book_id` (optional; with it, optional `section_id`): the copy is FILED into that book in the same act and the same
  undo, as `create_note` files. Reach, her ticket's shape: READ on the source (+ the fence as today) and WRITE NEW on
  the destination BOOK (`decide` on the book, the `create_note` precedent) — a book in the source's own wing (books
  never span wings: a book of another wing answers the ONE not-shared shape, no oracle) — **or**, with no `book_id`,
  WRITE NEW on the wing as today. The filing is `addPostToReading`'s plain add on a fresh bookless copy; an OWNED
  destination is a plain add too (the copy is membered nowhere yet); a finished book, a gathering, a full book refuse
  in her doors' words through the ONE refusal chain (VX-362). ORDER inside the transaction: the family copy, then the
  membership (so the outflow's `applyAutoTag` fires as on a hand-add), then the `with_tags` applications — so a copy
  filed into an owned book bells elsewhere rather than seating twice (the ownership table). The once grants of both
  sides spend as one union (the `guardWingMove` shape, as today). The snapshot decides both and raises ONE ask.
- `scopes` grows to `[.book, .wing]` so a book-level client sees the tool (the W-UX-14 truth pin's sense: it CAN
  land a copy now). The description says both roads and the default.
- The answer: VX-252's records (+ `source_block_id`), `source_note_id`, `landed` (the book's words when filed —
  `create_note`'s), `book_id`/`section_id` echoed, and **`tag_ids` + `tags`** listing EVERY tag the copy wears when
  the act lands (P-VX361-1's shape: the applied tags, then the book's outflow, listed once). The receipt's Open ›
  opens the copy (P-VX311-3). Activity speaks it in words ("‹client› duplicated “X” into “Book”").
- **The AI's docs:** the tool description (the two roads, the default, `with_tags: false`), `MCPSession.instructions`
  line 147's sentence if it needs the book road (stay ≤3,000 — the pin), the guide's MCP lesson 3 if it names
  duplicate's reach. The public guide page's delta is a line for her site agent in the handoff.
- The fence (P-VX311-1) stands byte-for-byte; the pre-act flush list already names `duplicate_note`.

**D-C-5 — the seeder.** The versions lesson's twin is minted with `.applied`: the implementer checks whether any
seeded living book's rule hears the guide tag (the field guide is a seeded book; if its rule names #tutorial the
twin would now SEAT, which may be exactly right or may duplicate a membership the seed makes by hand) and makes the
seed's result identical to today's — `.none` + the existing hand apply is the fallback. Said in the record either way.

## Units (two acceptance units — within the sizing guidance; one fresh `opus-implementer` session each)

| Unit | Members | What | Evidence |
|---|---|---|---|
| **U1** | VX-372 (+ D-C-1/2/3/5) | The op's tag choice with intake; the two registry capabilities + every door; promote aligned; the seeder | Red-on-old pins (core: a with-tags duplicate seats/bells per the table, undo/redo over seats, without-tags wears none, promote applies; Mac: the registry walk, the doors declared and rendered, the refusal copy) · the headless core + MCP suites green · a Mac batch under a stage claim · a dev-store walk in both voices (the Library row menu, note ▾, ⌘K, the chip) |
| **U2** | VX-371 (+ D-C-4) | `duplicate_note`'s `with_tags`, `book_id`, `section_id`; scopes; the answer; the docs | Red-on-old pins (VariorumMCPTests: book road at write new on the book, the wing road unchanged, the wrong-wing/not-shared shape, chapter sentence, `with_tags: false`, answer fields, the instructions bound) · headless green · a Mac batch · **ONE real-client live round on the dev store** proving both tickets (Claude Code against the Debug app: duplicate with tags into a collecting book, into a chapter, without tags, under a book-only share) |
| Ladder | both | `fable-reviewer` at xhigh, fresh per round, `notes/REVIEW_PROMPT.md` verbatim, cross-model (CLAUDE.md "Two reviews") | findings repo-first; hard cap three rounds |
| Closeout | — | MCPSpec contract line, AppSpec §14 entry, QUESTIONS bundle (P-C-1…3), tickets, MOBILE PARITY, handoff, PR merge, the field-guide re-seed (if P-C-1 (a) stands), the /Applications refresh at a zero-instance window | the merged-tip runs |

**Order:** U1 then U2 (U2 reads U1's op signature). VX-371 and VX-372 close one by one as their units land.

## Briefs

### U1 brief — VX-372 (an `opus-implementer` at xhigh; a fresh session)

Work ONLY in `~/dev/variorum-vx-383` on branch `vx-383-duplicate-note`. Read the "Required reading" set above and
this file in full first; reading is never delegated. Build D-C-1, D-C-2, D-C-3 and D-C-5 exactly as written; where
this file leaves a name or a door enum to you, pick the one the neighbouring declarations use and say so in your
record. Every bug-class change lands with a red-on-old pin verified by revert (name each revert, keep pre-revert
copies in your own `u1-prerevert/` under the scratchpad, never `git checkout` a file you also edit). A design fork
this file does not settle — stop, write the fork with 2–3 options and your recommendation into your record, commit,
and return; the architect rules before you build that half. Commits: one per coherent piece, message naming the
member and `Part of VX-383`, NO attribution trailer of any kind, pushed after each. Write your UNIT RECORD under
"Unit records" below from your first commit (LIVE STATUS per piece; PENDING for anything unverified). Headless:
`swift build` + `swift test --filter` over every duplicate-, intake-, registry- and version-touching suite (then the
whole core package once). The Mac batch and the walk need a stage claim: ask the orchestrator for the window; never
launch the Debug app, run `xcodebuild test` or touch any store without it. Do not touch `Sync/`, custody, the
Keychain, the editor seam or any schema; do not change the wire (U2's). End with your self-assessment in the record.

### U2 brief — VX-371 (an `opus-implementer` at xhigh; a fresh session, after U1's record closes)

As U1's brief, for D-C-4: the wire's `with_tags`, `book_id`, `section_id`, the scopes, the answer, the Activity
words, the docs (the description, the instructions within 3,000 characters, the guide lesson if it names the reach).
Mirror `create_note`'s book road and `add_note_to_book`'s chapter sentence; keep the fence and the wing road
byte-for-byte; the guard re-decides every side inside the transaction and spends the once grants as one union. Pins
in `VariorumMCPTests` red-on-old. The real-client live round is run by the orchestrator in a stage window; prepare
its script (the exact tool calls and expected answers) in your record.

## Environment traps (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration (Xcode builds SPM package dependencies RELEASE under any configuration not
named exactly "Debug" — silently stripping VariorumCore's DEBUG-gated oracles); suites running beside a live
session flash the test host's windows on screen; backups WAL-safe with UTC names, ALWAYS before touching the real
store (this run touches it only at the closeout's re-seed, behind A1); screenshots in gitignored dirs only; never
`git checkout` over uncommitted work; commit per piece and push after every commit
(`notes/SessionResiliencyProtocol.md`); synchronous foreground waits only — poll a log with
`grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop, never `tail -f | grep -m1`; never force-push, never
rewrite history; commits name their member and `Part of VX-383`, with NO attribution trailer of any kind. The stage
(`Tools/stage`) is claimed by the ORCHESTRATOR for every Mac batch, walk and live round; no coordinator session is
live at this kickoff (the stage read FREE), so claims go straight through the tool and are logged below. The dev
store's Castle credentials, if a lock screen appears, are `~/.variorum/dev-castle.env` (never invent, never commit).

## LIVE STATUS

| Unit | Members | State |
|---|---|---|
| U1 | VX-372 | NOT-STARTED — brief above; implementer to spawn |
| U2 | VX-371 | NOT-STARTED — after U1 |
| Ladder | — | NOT-STARTED |
| Closeout | — | NOT-STARTED |

## PROVISIONALS (to the QUESTIONS bundle at the merge)

- **P-C-1** the verbs "Duplicate with Tags" / "Duplicate without Tags"; "Duplicate as Version" retires as a label.
- **P-C-2** promote applies the original's current tags through the application road.
- **P-C-3** the wire's `with_tags` defaults to true.

## Stage traffic log

*(REQUEST / claim / release lines, appended by the orchestrator.)*

## Unit records

*(Each unit's implementer writes its section here.)*
