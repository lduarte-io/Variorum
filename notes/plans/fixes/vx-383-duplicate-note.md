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
- The phone: no duplicate door — but **Promote IS on the phone** (Note ⋯ ▸ Versions…, the shared `VersionActs.promote`; U1's implementer corrected the kickoff's grep), so D-C-3 is MOBILE-VISIBLE through the shared op with zero phone code changed. **MOBILE PARITY: a `notes/MobileSoul.md` ledger row at the closeout** (a promoted version now wears the original's tags and is heard by living books, on both platforms).

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
| U1 | VX-372 | BUILT — headless green, the Mac compiled (the U1 UNIT RECORD); the Mac batch (Tier A + B), `MobileVersionsTests` and the walk W0–W10 are OWED in a stage window (the orchestrator's) |
| U2 | VX-371 | BUILT — headless green, the Mac compiled (green `vx383-u2` + red `vx383-u2-red`; the U2 UNIT RECORD); the Mac batch (61 suites + the faces pin's red run) and the REAL-CLIENT LIVE ROUND are OWED in a stage window (the orchestrator's), beside U1's batch + walk (`vx383-u2` holds U1 + U2 — the tip) |
| Ladder | — | NOT-STARTED |
| Closeout | — | NOT-STARTED |

## THE ORCHESTRATOR'S RULINGS AND DISPOSITIONS (2026-10-17, the stage window)

- **R-C-1 — the field guide's recipe 6 (U2's OWED):** adopted, in one sentence without a parenthesis: *"The copy lands in that wing's Pool unless you name a book for it or a book collects its tags, and your original never changes."* Written by the orchestrator (the architect's small-code latitude) in `TutorialSeeder.swift` and its exact-text pin `TutorialMCPChapterTests.revisionRecipe`; the real store's field guide is re-seeded at the closeout behind A1 (P-C-1 already owed it).
- **P-U2-3 — an ARCHIVED destination takes the copy: (a) stands.** The U2 brief's "archived" in the refusal list was the orchestrator's slip; AppSpec §9's 13i-e family ("EXPLICIT adds land — no `readingArchived` refusal exists") and `create_note`'s road are the law, and the implementer built to them correctly.
- **P-U1-1…6, P-U2-1/2/4/5:** accepted as built for the ladder; bundled for her at the merge.
- **U1's MOBILE PARITY correction** accepted (D-C-3 is mobile-visible through the shared `VersionActs.promote`): a `notes/MobileSoul.md` row at the closeout.

## PROVISIONALS (to the QUESTIONS bundle at the merge)

- **P-C-1** the verbs "Duplicate with Tags" / "Duplicate without Tags"; "Duplicate as Version" retires as a label.
- **P-C-2** promote applies the original's current tags through the application road.
- **P-C-3** the wire's `with_tags` defaults to true.

## Stage traffic log

- 2026-10-17 19:02 CLAIMED `vx383` (240 min; her word at the sitting: "Now, I'm off the Pro"; no coordinator session live, the stage read FREE; her app absent, HID idle hours). **The Mac batch on the tip product `vx383-u2`** (382 suites = U1's Tier A + U2's 61 + U1's 367, deduped; the product built at `3c8e84b85`, no source line changed since — `batch-all.txt`/`batch-all.log` in `notes/plans/vx383-screens/`): **"Test run with 2402 tests in 379 suites failed after 950.745 seconds with 5 issues (including 1 known issue)"** — the 5 issues are VX-115's standing pin (`BookCollectingDoorsTests` — VX-382's member, by design not this run's) and VX-167's standing parallel-run red (`DestructiveUndoWarningTests.redoNeverAsks`, 3 issues — Parked, "goes red only in wide parallel runs"); 36 env-gated capture harnesses skipped by design; **VX-372's `DuplicateDoorsTests` and VX-371's `MCPDuplicateFilingFacesTests` PASSED**. The faces pin's red run on `vx383-u2-red`, the guide pins after the recipe edit, `MobileVersionsTests`, the walk and the live round follow in the same window.
- The faces pin's RED run, redone by the orchestrator (the first attempt used `test`, which REBUILT the red product from the fixed tree and read green — a slip, recorded): `MCPPaneCopy.swift` put at `80e97a6fa` (pre-revert copy kept, restored by sha256 `6ea650e3…`, tree clean, NO REVERT IN FLIGHT), `build-for-testing` into `vx383-u2-red` (its dylib carries "duplicated a note into" ×0), then `test-without-building` → **"2 tests in 1 suite failed … with 6 issues" on exactly `:39 :40 :42 :44 :56 :62`** — U2's R5 claim VERIFIED (`u2/faces-red.log`, `u2/faces-red-build.log`). The tip product `vx383-u2` rebuilt after R-C-1's edit; the guide + door pins on it (`TutorialMCPChapterTests` · `TutorialCurrencyTests` · `DuplicateDoorsTests` · `HelperCurrencyTests`): **"37 tests in 4 suites passed"** (`u1/guide-pins.log`).
- Dev-store safety copy taken at the zero-instance moment 19:20 (`<scratchpad>/prestage/`: sqlite c17923414b2e668e · wal 7f2fcf1ec90d4cc8 · shm e4e2b900d45c90ca; Debug prefs exported, 211 KB); her user-scope MCP servers fingerprint `['linear-server', 'variorum'] bc64543e2f4e8e58` (= VX-246/VX-336's). Consent probe on this host: AX 1 SCREEN 1.

## THE LIVE ROUND — RUN BY THE ORCHESTRATOR (2026-10-17, the `vx383` window; captures in `notes/plans/vx383-screens/u2/live/` + the scratchpad's `u2-live/`)

Claude Code 2.1.302 as the real client, a fresh tab key from the Connect tab bound with zero clicks on the first turn (`claude -p --strict-mcp-config` with a scratch config; her user-scope servers' fingerprint `bc64543e2f4e8e58` before and after). The fixtures were MINTED BY THE CLIENT (the u2 set per L0; the walk's u1 set too), the open book OFF (verified on the pane), the grants by the sheet.
- **L1 PASS** — `landed` = `“u2 living”, which collects one of its tags`, `tags` `["u2dup"]`, no `book_id`; Activity "claude-code duplicated “u2 source”"; Edit menu "Undo claude-code's duplicate" → the copy left u2 living (2 → 1 notes) → "Redo claude-code's duplicate" → back (2), the quiet receipt "Redid: claude-code's duplicate".
- **L2 PASS** — the answer byte-exact (`landed` = `the end of “u2 drafts”, in its chapter “second drafts”, and “u2 living”, which collects one of its tags`; `book_id` B · `section_id` C · `tags` `["u2dup"]`); the receipt **"claude-code duplicated “u2 source” into “u2 drafts” · ⌥⌘Z undoes  Open ›"** caught on the bar (t7.png); Activity **"claude-code duplicated a note into “u2 drafts”"**; undo → u2 drafts 0 · u2 living 2; redo → 1 · 1 ch · 3 — and L7's read-back shows the redone copy under "second drafts".
- **L3 PASS** — `with_tags: false` → `landed` `the Pool of Home`, `tags` `[]`, no book took it. **`with_tags: "no"` never reaches the wire from Claude Code**: the client's own schema validation refuses a non-boolean before the call (the pin covers the server's sentence; recorded, not a defect).
- **L4 PASS** — Home edit revoked; read on "u2 source" + write new on "u2 drafts" granted (the note picker needed the three copies renamed first — four rows read "u2 source"; a walk ergonomics note, not a defect); `duplicate_note` listed; the book road landed with `landed` = `the end of “u2 drafts”, and a book not shared with you, which collects one of its tags`; the wing road refused with the exact sentence and raised **"claude-code asks to write new in the Home wing"** in Waiting → Don't allow; Activity **"claude-code was refused duplicating a note in “Home”"**.
- **L5 HALF-LIVE** — `book_id: "no-such-book"` → the exact not-shared sentence and NO ask (Waiting empty after). The OTHER-WING half was not reached live: the walk could not mint a second wing (the Bookcase masthead's SwiftUI `Menu` did not open under synthetic clicks or a held press — a WalkKit limit, logged below); it stands on `MCPDuplicateNoteFilingServerTests.aBookOfAnotherWingAnswersTheOneNotSharedShapeAndRaisesNoAsk` (red under R2). A candidate for her own hand check.
- **L6 PASS** — write new on "u2 finished" granted; the call answered **"This book is finished — reopen it first; if it’s sealed, unseal it."**; nothing minted, the undo stack unchanged.
- **L7 PASS** — `read_note(with_ids)` of the L2 copy equals L2's answer record for record (take ids, labels, the text's sha256), the shown takes equal; the copy's membership reads u2 drafts / "second drafts".
- Both voices: the Terminal pass for L2's receipt and Activity row is folded into the walk's voice flip (below).

## Unit records

*(Each unit's implementer writes its section here.)*

## U1 UNIT RECORD — VX-372: the op's tag choice, the two doors, promote, the seeder (opus-implementer, from 2026-10-17)

**NOT DONE BY THIS SESSION (the record's first line, per the contract): the Mac test batch, the phone suite and the dev-store walk — none run (they need a stage window, the orchestrator's; listed below, exact). Every Mac pin is therefore PENDING its first run. D-C-4 (the wire) not touched — U2's.** Everything else is DONE: D-C-1, D-C-3, D-C-5 and D-C-2 built; the core pins red-on-old (committed ahead) and green; two behavioural revert checks red then restored; the whole core package green but VX-353's standing flake (green alone); the Mac app and its tests compiled. No stage
claimed, no app launched, no `xcodebuild test`, no store touched by this session (the Mac batch and the walk are the
orchestrator's, in a stage window).

**Read in (in full, this session's own context):** CLAUDE.md + its canon; this file whole; `notes/MCPSpec.md` whole;
`notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` §U6a (D-311-1…8, THE ORCHESTRATOR'S RULINGS ON U6a's FORKS);
`notes/QUESTIONS.md` #227 (with her answers — P-VX311-1…3, P-VX361-1, VX-371's shape); `notes/plans/phase-17-standing-fixes.md`
B3 row 3 + P-17y-B3-c1; `notes/SessionResiliencyProtocol.md`. Code (every pointer re-verified at `438846fb1`):
`Operations+Versions.swift` (`duplicateAsVersion`/`duplicateAsVersionBody`/`copyPost`/`revertMintedContainer`),
`Operations+Ownership.swift` (`copyLiveTags`), `Operations+Intake.swift` (`insertPostTag`, the event, `applyAutoTag`),
`Operations+UndoInverses.swift` (`registerMintedContainerEntry`), `Operations+Container.swift` (`restoreContainer`'s exact-stamp
revival), the container tombstone trigger, `Operations+NoteVersions.swift` (save/promote), `Operations+MCPDuplicate.swift`,
the registry (`Capability.swift`, `CapabilityRegistry.swift`, `ShellActions.swift`, `EditorCommands.swift`), the doors
(`LibraryCatalogView`, `PoolPostsView`, `TakesBoardView`, `LensesBoardView`, `MembershipChip`, `CommitBar`,
`TakesBottomBar`), `TutorialSeeder.swift`, `CapabilityRegistryTests.swift`, `DuplicateCarriesTagsTests.swift`,
`MCPDuplicateNoteActsTests.swift`.

**Housekeeping:** `.gitignore` gains `notes/plans/vx383-screens/` (this run's logs and captures; the vx-336 precedent).
Headless logs: `notes/plans/vx383-screens/u1/logs/`.

### LIVE STATUS — U1's pieces (flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | read-in, this record, the gitignore line | DONE (this commit) |
| 1 | D-C-1 pins (core) — committed AHEAD of the fix, run RED on the pre-fix tree | DONE (this commit) — NEW `Tests/VariorumCoreTests/DuplicateAppliesTagsTests.swift` (9 tests; every one calls the door's PRE-EXISTING spelling — `duplicateAsVersion(_:)`, whose default becomes with-tags, and `duplicateNoteForClient` — so it compiles on the pre-fix tree): a quiet book SEATS the copy (end, unsectioned, the seat stamped by the application's own act) · the Arrivals dial BELLS it · a full book bells it · the application ORDER is kept and the ownership table holds (an owned book claims the free copy, a plain book then bells it) · the wire's duplicate is heard the same way (one body) · ONE entry: undo leaves the book without the copy (the seat tombstoned on the copy's stamp), redo brings the SAME row back · a dismissal she made between stays decided (her stamp) · a bell she seated between comes back seated · CONTROL: finished and archived books stay paused. **JUSTIFIED EDITS:** `DuplicateCarriesTagsTests` — P-17y-B3-c1's control flips to `theRidingTagsAreAppliedSoALivingBookHearsThem` (superseded by D-C-1), the undo label reads "Duplicate with Tags" (P-C-1), the suite's doc says so; `RedoStackTests.redoingAPostMintBringsTheWholeCopyBack` — the label. **RED on the pre-fix tree (`2b3b3cd3a` + these files): "Test run with 40 tests in 4 suites failed … with 12 issues"** — 11 tests failed, each on its designed line (`p1-pins-red.log`, `p1-pins-red.pairs`): `DuplicateAppliesTagsTests` `:93` `:118` `:135` `:157` `:176` `:196` `:227` `:253` (the pair row never exists — the copy was never heard), `DuplicateCarriesTagsTests` `:104` `:109` (the label) and `:134` (the flipped control), `RedoStackTests` `:234` (the label); the control `finishedAndArchivedBooksStayPaused` and the four other `DuplicateCarriesTagsTests` GREEN |
| 2 | D-C-1 fix — `Operations.DuplicateTags`, `duplicateAsVersion(_:tags:)`, the body's parameter, the undo label | DONE (this commit) — `Operations+Versions.swift`: NEW `Operations.DuplicateTags` (`.applied` · `.none`, `CaseIterable`; `verb` = "Duplicate with Tags" / "Duplicate without Tags" — the door's word AND the undo label, one source; P-C-1); `duplicateAsVersion(_:tags: = .applied)` registers ONE `registerMintedContainerEntry` under `tags.verb` (the default keeps every existing caller compiling and is her door's default); `duplicateAsVersionBody(_:_:tags:)` — `copyPost`, then with `.applied` NEW `applyLiveTags(db, from:to:now:)`: the source's live applications of live tags IN THE TARGET'S WING (the duplicate's wing is the source's; the wing belt `applyAutoTag` keeps), source application order (`created_at, id`), each through `insertPostTag` (the one road — intake hears it), a tag already worn skipped; `.none` applies nothing. The row copy (`copyLiveTags`) is retired from the duplicate and keeps its one other caller, the ceremony copy (its doc says so). `Operations+MCPDuplicate.swift`: `duplicateNoteForClient(_:tags: = .applied, undoLabel:guardedBy:)` passes the choice to the same body — **the wire file is untouched; the wire's copy is now heard by intake at the default `.applied`** (P-C-3's ruled default; U2 wires `with_tags`). NEW-API pins `Tests/VariorumCoreTests/DuplicateWithoutTagsTests.swift` (4 tests — the verbs; without tags the copy wears none and no book hears it, the rest her door's copy; each choice undoes/redoes under its own verb; the wire's body takes the same choice, its default with tags) — green by construction, red-on-old by compilation (piece 6 runs its behavioural revert). **GREEN:** the D-C-1 pins + every duplicate/version/intake-touching core suite — **"Test run with 227 tests in 21 suites passed", EXIT 0** (`p2-pins-green.log`: `DuplicateAppliesTagsTests`, `DuplicateWithoutTagsTests`, `DuplicateCarriesTagsTests`, `RedoStackTests`, `MCPDuplicateNoteActsTests`, `VersionOperationsTests`, `NoteVersionsTests`, `IntakeOperationsTests`, `IntakeSoakTests`, `DivergeAndExtractSeamTests`, `CommentTravelTests`, `FanOrderTests`, `PoolDragCopyTests`, `TrashAndArchiveTests`, `UndoQuietPressTests`, `LibrarySameMacRestoreDrillTests`); every MCP suite naming `duplicate_note` — **"84 tests in 8 suites passed … with 1 known issue"**, EXIT 0 (`p2-mcp-green.log`; the known issue is VX-357's standing `withKnownIssue` in `MCPWriteDigestServerTests`, not this change's) |
| 3 | D-C-3 — promote applies the original's tags (pins ahead, then the fix) | DONE (`c7795fee9` pins · this commit the fix) — **pins** NEW `Tests/VariorumCoreTests/PromoteAppliesTagsTests.swift` (4 tests, all on the pre-existing `saveNoteVersion`/`promoteNoteVersion`/`duplicateAsVersion` spellings): the promoted note wears the ORIGINAL's live tags NOW in its order (a tag removed since the save stays off, one added since rides, a deleted tag never) · a living book hears it and seats it · Save → Promote ends where Duplicate with Tags ends (same tags, same book) · CONTROL: promote still registers no undo entry. **RED on the pre-fix tree (`d04089428` + the file): "4 tests in 1 suite failed … with 4 issues"** — `:54`, `:77`, `:102`, `:105` (`p3-pins-red.log`, `.pairs`); the control GREEN. **fix** `Operations+NoteVersions.swift` `promoteNoteVersion`: after the two flips (so the note is live and unarchived when intake hears it), `applyLiveTags(db, from: postID, to: versionID, now:)` — the original's live tags in the version's wing (= the note's: versions ride wing moves), application order kept, each through `insertPostTag`; one clock read for the flips and the applications; still no undo entry. **GREEN: "133 tests in 10 suites passed", EXIT 0** (`p3-pins-green.log`: the promote pins + `NoteVersionsTests`, `VersionOperationsTests`, the D-C-1 suites, `IntakeOperationsTests`, `MCPDuplicateNoteActsTests`, the carriage suites). **⚠ MOBILE-VISIBLE (corrects the plan's "MOBILE PARITY: nothing mobile-visible"):** the phone HAS a Promote — Note ⋯ ▸ Versions… (`VariorumMobile/Features/Write/MobileVersions.swift`, round 2 batch 6c) through the SHARED `VersionActs.promote` (`App/Variorum/Shared/VersionActs.swift:79`) → the same op, so a version promoted on the phone now wears the original's tags too (no phone code changed; its receipt "…a note of its own now, in the Library" stays true). The closeout's MOBILE PARITY line owes this; `MobileVersionsTests` joins the batch (simulator) |
| 4 | D-C-5 — the seeder's twin (+ P-C-1's three guide sentences) | DONE (this commit; compiled at piece 7, pinned in piece 5's Mac file) — **THE CHECK D-C-5 ASKS:** does any seeded LIVING book's rule hear the guide tag? **No.** The field guide is a plain book with NO rule (`TutorialSeeder.seed` → `createReading(name:kind: .book, profile: "collection", wordTarget:)`); every seeded rule belongs to a GATHERING (`SampleLibraryWelcome.restoreClassicsGathering` — #classics; `Operations+StarredGathering` — ★; the quicknotes gathering), and a gathering never materializes. So the twin is minted `.applied`, said explicitly (`duplicateAsVersion(versions.post.id, tags: .applied)`), and **on every fresh store, and on any store where she has not built a living book collecting the guide's tag, the seed's rows are identical to today's** (the twin bookless, wearing the guide's tag, no row at any book). The one store-shape that differs: if SHE built a living book collecting #tutorial, the twin is now heard like each of its sibling lessons (whose `lesson()` apply has always been an applying act) — the row-copied twin was the one lesson note no book could hear. `.none` + the existing hand apply would land the very same rows (that apply is an applying act too), so the fallback buys nothing; the hand apply stays as the belt, its `alreadyTagged` tolerance and comment updated. **P-C-1's three guide sentences** (`TutorialSeeder.swift`): "three ways" lesson — "duplicate the note (Duplicate with Tags) and let the two grow apart as versions, linked and comparable"; "compare & versions" ¶1 — "Two gestures make one: Mark as Versions just draws a link between two existing notes; Duplicate with Tags mints a whole copy (takes and all, and its tags) and draws the link in one gesture, and Duplicate without Tags leaves the tags behind. Mark = connect, duplicate = copy + connect."; ¶6 — "The library's right-click menu has Duplicate with Tags and Duplicate without Tags for any note, any time." (Words functional — VX-234's pass may re-voice; the real store's guide is re-seeded at the closeout behind A1, the orchestrator's.) |
| 5 | D-C-2 — the two capabilities, every door, the inline doors routed, P-C-1's faces | DONE (`ab303505e`; compiled by piece 7's Mac `build-for-testing`: **TEST BUILD SUCCEEDED, XCB-EXIT 0**, no warning in a touched line) — `Capability.swift` (`.duplicateNoteWithTags`, `.duplicateNoteWithoutTags`); `CapabilityRegistry.swift` (both `.post`, `noteScoped` — the neighbours' rule, `.deleteNote`'s stated split for the row doors — `takesAccess: .native`, no chord; doors `[.menuBar, .contextMenu, .palette, .bottomBar]`, WITH tags `+ .surface`; verbs and the unavailable note from `DuplicateCopy`); NEW `Core/Views/NoteDuplicate.swift` (`CopyForAI`'s shape and home: `NoteDuplicate.run` — `session.runCopying` (flush first) → `duplicateAsVersion(_:tags:)` → where the copy landed, read from `Queries.readingsContaining` books; `perform` speaks it as a RECEIPT carrying "Open ›" (→ `.variorumOpenPost`, the chip's and Arrivals' road) or the refusal via `OpsRefusalCopy`; `DuplicateCopy` — the verbs from core's one source, the unavailable note, the inline doors' help, the landed words); `ShellActions.duplicateNote(tags:)` (the mounted detail's note, else the note she is WRITING in when it is a note — a book's inline editor, which `noteScoped` already counts; else the honest note) + both palette rows; `EditorCommands` File-menu rows beside Save a Version (menuRendered); both bars' `note ▾` rows under Versions… (`CommitBar` gated on the note kind — the scraps editor composes that bar with a pool's id; `TakesBottomBar` through the board's own door, which lifts her hand off the article landing first); the note-row grammar (`SidebarView.contextMenuCapabilities`, the Open strip deliberately not rendering them — `.deleteNote`'s reason) rendered by the Library's `postRowMenu` and the Pool's row menu (through the parent's act, P39a — `onDuplicateAsVersion` now carries the tag choice); the shipped inline doors — the Takes board's `note actions` row, the Lenses Chosen column's `⧉` pull-down, the book chip's row — declared `.surface` in their surfaces' tables (the Lenses board gains `surfaceCapabilities`, the walk's union a line) and running WITH tags under its verb; `LibraryViewModel.duplicateAsVersion(postID:tags:)` and `TakesViewModel.duplicateAsVersion(tags:)` forward to the one act (the Library's raw `String(describing:)` refusal is gone — the status centre speaks the app's words). **P-C-1's faces:** every "Duplicate as Version" label (the Library row, the Pool row, the Takes board, the Lenses column, the chip), the helper's "version" entry (⌘/), `MultiBookEditNote.sentence`, `DivergeCopy`'s smart-book refusal ("…a copy appears there only if it carries the same tags. Duplicate with Tags makes one that does."), the chip's status line (now `DuplicateCopy.landed` — "in the Pool until you shelve it" was no longer always true), the undo label (piece 2), the guide (piece 4). NEW Mac pins `VariorumTests/DuplicateDoorsTests.swift` (12 tests: the declarations in her words from the one source; availability; every door table; the row menus' bodies (source scan); **the retired label on NO Mac/Shared face** (a scan of every non-comment Swift line); the sentences that name the door; the one act WITH tags — the book took the copy in, the receipt names it, carries Open ›; WITHOUT tags — no tag, no book, "in the Pool"; a blockless note refuses in the app's words; the shell door with nothing open speaks the note, with a detail mounted duplicates that note; the landed words; the guide names both verbs from the registry) — NEW API, red-on-old BY COMPILATION (stated; the batch runs them green). JUSTIFIED EDITS: `BookAscentTests` ×3 (the door by its declared verb), the Pool view's init in `MCPSharedIconClickTests`, `MembershipChoiceTests`, `PoolTuckFaceTests` ×2 (`{ _, _ in }`), `CapabilityRegistryTests`' surface union (+ `LensesBoardView.surfaceCapabilities`) |
| 6 | revert checks (announced here before any revert starts) | DONE (this commit; **NO REVERT IN FLIGHT** — both restored, `sha256` `0258d46a…62202` equal to the pre-revert copy, `git status` clean) — announced at `ccdb04fb5` before the first edit; pre-revert copy `<scratchpad>/u1-prerevert/Operations+Versions.swift`. **R1** (`.none`'s arm applying tags) → **"4 tests in 1 suite failed … with 4 issues"**: `DuplicateWithoutTagsTests` `:53` `:54` (the copy wore the tag, the book heard it) and `:100` `:101` (the wire's bare copy the same) — `p6-R1-red.log`, `.pairs`. **R2** (`applyLiveTags`' ORDER BY reversed) → **"13 tests in 2 suites failed … with 4 issues"**: `DuplicateAppliesTagsTests.theApplicationOrderIsKeptAndTheOwnershipTableHolds` `:154` (the paths' order), `:158` (the owned book BELLED — the plain book had claimed the copy first), `:161` (the plain book SEATED it) and `PromoteAppliesTagsTests.aPromotedVersionWearsTheOriginalsCurrentTags` `:54` (the order) — `p6-R2-red.log`, `.pairs`; every other pin of both suites green under the revert. **Restored:** the three suites **"17 tests in 3 suites passed"**, EXIT 0 (`p6-restored-green.log`) |
| 7 | headless finals + the Mac `build-for-testing` (no runner) | DONE — **the Mac `build-for-testing`** at `ab303505e` (`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx383-u1 build-for-testing`, from `App/Variorum/`): **TEST BUILD SUCCEEDED, XCB-EXIT 0** (`p7-mac-build.log`); the warnings in touched files are pre-existing lines (`LibraryCatalogView:1620`, `LensesBoardView:935`, `TakesBoardView:2058`, `BookAscentTests:556`), none in a new or edited line; no source changed after it (pieces 6–8 are records and reverted-then-restored lines). **The whole core package once** at `c30eaaca2` (`swift test`, `p7-core-final.log`): **VariorumCoreTests "2889 tests in 336 suites passed"** · **workbook "40 tests in 6 suites passed"** · **VariorumMCPTests "349 tests in 67 suites failed … with 2 issues (including 1 known issue)"** — the ONE failure is VX-353's standing flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.7 s past its 15 s bound at load average 9–12 — the run beside another worktree's build; untouched by this unit) and the known issue is VX-357's `withKnownIssue`; **the suite re-run alone: "3 tests in 1 suite passed", EXIT 0** (`p7-timelimit-rerun.log`). The derived product `App/Variorum/DerivedData/vx383-u1` is KEPT (the batch may run it — see piece 8). No runner, no app launched, no stage, no store |
| 8 | the Mac batch's suite list + the walk steps + the self-assessment | DONE (this commit) — below: THE MAC BATCH FOR U1, THE WALK FOR U1, PROVISIONALS, NOTES FOR U2, SELF-ASSESSMENT |

### THE MAC BATCH FOR U1 (for the orchestrator's stage window — every suite that exercises a changed SOURCE file)

**Product:** `App/Variorum/DerivedData/vx383-u1` (built at `ab303505e`; `git diff --stat ab303505e..HEAD -- App Sources Tests` is EMPTY — pieces 6–8 changed records only), xctestrun `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun` (present) — or rebuild from the tip. **Run** from `App/Variorum/`: `xcodebuild test-without-building -xctestrun <that file> -only-testing:VariorumTests/<Suite> …` and confirm the "Test run with N tests" line.

**Tier A — this unit's own pins and every justified edit (read first; every one PENDING):** `DuplicateDoorsTests` (12, NEW — expect all green) · `CapabilityRegistryTests` (the walk: declared ⇔ rendered with the two acts, the Lenses board's new surface line) · `MultiBookEditNoteRuleTests` · `MultiBookEditNoteTriggerTests` · `DivergeDoorTests` (the three `BookAscentTests` justified edits) · `CopyDoorFlushTests` (the library/board doors now run `NoteDuplicate` — still flush first, `lastError`/`statusMessage` still nil) · `MCPSharedIconClickTests` · `MembershipChoiceTests` · `PoolTuckFaceTests` (the Pool view's init) · `NoteVersionsPaneTests` (promote now applies tags) · `TutorialCurrencyTests` · `TutorialLookingActsTests` · `TutorialFurnitureFoldTests` (the twin, minted with tags) · `HelperCurrencyTests` (the helper's version entry) · `CompareViewModelTests` · `CompareLensesAlignmentTests` (the Lenses Chosen door) · `MCPCompareLandingTests` · `TakesBoardTests` · `ScrubAndOutlineTests` · `SavepointCommitDoorTests` · `PaletteReachTests` · `SampleLibraryWelcomeTests`.

**Tier B — the whole grep (367 suites, every name verified a real type in the built test bundle: `nm -j` + `swift-demangle --simplified`, ≥ 20 symbols each — a name matching nothing runs 0 tests silently).** Generated by grepping `App/Variorum/VariorumTests/*.swift` for every changed type and the changed core acts (`NoteDuplicate|DuplicateCopy|EditorCommands|MembershipChip|DivergeCopy|ChipRefusals|CommitBar|HelperView|LibraryCatalogView|LibraryViewModel|SidebarView|PoolPostsView|LensesBoardView|TakesBoardView|TakesBottomBar|TakesViewModel|TutorialSeeder|CapabilityRegistry|CapabilityID|ShellActions|RootView|MultiBookEditNote|duplicateAsVersion|promoteNoteVersion|VersionActs|promoteColumn|Duplicate as Version|Duplicate with Tags` → 194 files), then every type with a `@Test` in them. The list (also `notes/plans/vx383-screens/u1/batch-suites.txt`, gitignored, on the Pro):

`AddToBookMintTests` · `AppMenuServicesTests` · `ArchivedBooksGroupTests` · `ArchivedListingTests` · `ArchivedMarkTests` · `ArticleLandingProjectionArmTests` · `AscentDoorTests` · `AscentRoutingTests` · `AutosaveConsolidationTests` · `AutosaveRegistryLifecycleTests` · `AutosaveRegistryReleaseGuardTests` · `AutosaveRegistryReleaseTests` · `BlockDeletionAndRedoTests` · `BlockHighlightTests` · `BlockHistoryPaletteDoorTests` · `BlockHistoryPaneTests` · `BlockSelectionRegistryTests` · `BlockSelectionRuleTests` · `BlockTOCStatusTests` · `BoardBlockSelectionTests` · `BoardDeleteRedoSurvivalTests` · `BoardDeleteRollbackTests` · `BoardDeliveryPolicyTests` · `BoardMergeDiagnosisTests` · `BookAnchorTests` · `BookArchiveDeclarationTests` · `BookArchiveDoorActTests` · `BookArchivedLineTests` · `BookArrivalsTests` · `BookAscentDeclarationTests` · `BookCarryTests` · `BookChooserOrderTests` · `BookCollectingDoorsTests` · `BookDeleteAndDuplicateTests` · `BookFilterBarTests` · `BookFocusFoldTests` · `BookPanelActingTests` · `BookPanelBrainTests` · `BookPanelDeclarationTests` · `BookRedesignMountTests` · `BookRowMenuTests` · `BookSearchTests` · `BookSettingsArchiveRowTests` · `BookSettingsSheetTests` · `BookStateDoorsTests` · `BookViewTests` · `BranchDoorFlushTests` · `CalloutContextMenuTests` · `CalloutEmojiPickerTests` · `CalloutSwatchTests` · `CalmAsksTests` · `CalmPageHoverTests` · `CanvasAndPoolTests` · `CanvasBoardGeometryTests` · `CanvasDebugOnlyTests` · `CanvasFocusedBlockFactTests` · `CanvasHostedRealizationTests` · `CanvasOrderAndOverviewTests` · `CanvasRealizationTests` · `CanvasTakesSwitcherTests` · `CapabilityRegistryTests` · `CaptureFocusReattachTests` · `CaptureHostsUndoFilingTests` · `CaptureTourFocusTests` · `CaptureUndoHistoryTests` · `CaptureUndoSyncTests` · `CarveCaretLandingTests` · `ChordLegibilityTests` · `ComesBackReceiptTests` · `CommandRouterTests` · `CommentPanelDoorsTests` · `CommentPanelHostLeavingTests` · `CommentPanelReleaseTests` · `CommitBarLayoutTests` · `CommitVocabularyTests` · `CompareAnchorWholeTests` · `CompareCompositionTests` · `CompareLensesAlignmentTests` · `CompareOnePlacementTests` · `CompareViewModelTests` · `ConfirmationsSettingTests` · `ContextBarDoorsTests` · `ContextBarTests` · `CopyAllTakesDoorTests` · `CopyDoorFlushTests` · `CreationTargetTests` · `DebugOracleOwnershipTests` · `DebugOracleSingletonWindowTests` · `DebugOracleTwoWindowTests` · `DestructiveUndoWarningTests` · `DiagnosticsPaneTests` · `DifferentialApplyTests` · `DivergeDoorTests` · `DivideExtractGestureTests` · `DivideWCeremonyTests` · `DocumentImportDoorTests` · `DragTypeDeclarationTests` · `DropAndRefusalCopyTests` · `DuplicateBookNameDoorTests` · `DuplicateDoorsTests` · `EncryptionBookDoorTests` · `EncryptionExplainedDrillTests` · `EncryptionExplainedSeedTests` · `FanReorderDoorTests` · `FannedDefaultsBoardTests` · `FannedDefaultsTests` · `FindAndReplaceTests` · `FormattingSurfacesTests` · `ForwardDestinationTests` · `FreeTypedTagTests` · `GlobalSegmentationFaceTests` · `HelperCurrencyTests` · `IAAndTrashShapeTests` · `ICloudDriveOfferTests` · `IndependentWorkspaceTests` · `JekyllTakemaniaSeedTests` · `LaunchFurnitureTests` · `LensesReorderTests` · `LibraryCardsWordTests` · `LibraryControlsFlowRuleTests` · `LibraryControlsGeometryTests` · `LibraryControlsStableWidthsTests` · `LibraryControlsU3cProbe` · `LibraryInfiniteScrollTests` · `LibraryListFaceRigTests` · `LibraryListFaceTests` · `LibraryPanelHostTests` · `LibraryPreviewBrainTests` · `LibrarySortMenuTests` · `LibraryTagFaceTests` · `LibraryViewScopeSwitchTests` · `LibraryWhenDoorTests` · `LifecycleFacesTests` · `ListContinuationTests` · `MCPAskAndReceiptTests` · `MCPAsksWaitCaptureTests` · `MCPAsksWaitTests` · `MCPCompareLandingTests` · `MCPEditFacesTests` · `MCPGrantSheetTests` · `MCPHerEditorDoorTests` · `MCPNavigationTests` · `MCPPaneTabsTests` · `MCPPaneTests` · `MCPRebindFaceTests` · `MCPShareFacesTests` · `MCPSharedIconClickTests` · `MCPSharedRowsRulesTests` · `MCPSharedRowsTests` · `MakeBlockGestureTests` · `MarginHoverCommentTests` · `MarkdownActsTests` · `MarkdownPaletteWritersTests` · `MastheadTagDoorTests` · `MembershipChoiceTests` · `MergeGestureTests` · `MergeSelectionTests` · `MorningListTests` · `MoveAndExecuteTests` · `MultiBookEditNoteRuleTests` · `MultiBookEditNoteTriggerTests` · `NavigationDoorsTests` · `NavigationHistoryTests` · `NestedListDoorTests` · `NewBlockShortcutTests` · `NewModesTests` · `NodSetTests` · `NoteBoxCompositionTests` · `NoteBoxGeometryTests` · `NoteBoxSlotTests` · `NoteCardSmartBooksTests` · `NoteDeleteConfirmEdgeTests` · `NoteDeletionActTests` · `NoteDeletionDeclarationTests` · `NoteDeletionNavigateAwayTests` · `NoteOnlyWindowTests` · `NoteTagDeclarationTests` · `NoteTrayTests` · `NoteVersionsPaneTests` · `OneTimeCodeAutoFillTests` · `OpenListCloseDoorTests` · `OpenListCloseShellTests` · `OpenListDragFaceTests` · `OpenListDragMountTests` · `OpenListDropDoorTests` · `OpenListDropRuleTests` · `OpenListHeightTests` · `OpenListLandingTests` · `OpenListLayoutMountTests` · `OpenListRowCloseDoorTests` · `OpenNotesMemoryShimTests` · `OpenNotesModelRestoreTests` · `OpenNotesRestoreTests` · `OpenNotesTests` · `OpenStripMenuTests` · `OriginBlockDoorTests` · `OutlineWritingSurfaceTests` · `PagedAnchorReportTests` · `PaletteReachTests` · `PaneBookBlurTests` · `PaneFindFaceTests` · `PaneFocusCatcherTests` · `PaneHeldModeTests` · `PaneLayoutTests` · `PaneMountTests` · `PaneMountWindowTests` · `PaneRenderRestoreClipTests` · `PaneSplitDoorTests` · `PaneSplitModelTests` · `PaneUnmountTests` · `ParagraphGapTests` · `PoolTuckFaceTests` · `PostDetailModeMemoryTests` · `PostDetailRoutingTests` · `QuickEntryLaunchFocusTests` · `QuickNoteDoorTests` · `QuickNoteMintTests` · `QuickNoteWindowTests` · `QuickNoteWordTests` · `QuietRunRowCaptureTests` · `QuitDoorTests` · `QuitFinalizeSurfacesTests` · `ReadModeTests` · `RecoveryDoorsTests` · `RemoveReleaseDoorTests` · `ReviewRound1FixTests` · `ReviewRound2FixTests` · `ReviewRound3FixTests` · `SampleLibraryTests` · `SampleLibraryWelcomeTests` · `SavepointCommitDoorTests` · `SavepointHistoryFaceTests` · `SavepointNameAskTests` · `SavepointNameCopyTests` · `SavepointNameFaceTests` · `SavepointOnLeaveTests` · `SavepointRenameDoorTests` · `SavepointSealedDoorTests` · `SavepointTakesDoorTests` · `ScrubAndOutlineTests` · `SealDoorTests` · `SealedBookMemberDoorTests` · `SettingsShapeTests` · `ShellChromeTests` · `ShellConfirmTests` · `ShellDoorOwnershipTests` · `ShellLandingDoorTests` · `ShellLandingMountTests` · `ShellLandingRuleTests` · `SidebarLayoutTests` · `SidebarSectionFollowTests` · `SidebarSectionWindowMountTests` · `SidebarSectionWindowRuleTests` · `SidebarSmokeTests` · `SidebarTransitionBeatTests` · `SnippetOpenTargetTests` · `SnippetTagDoorTests` · `SnippetsLandingTests` · `SpanToTakeDoorTests` · `SpanToTakeGesturePlanTests` · `SpellcheckLevelTests` · `SplitAtNewlinesDoorTests` · `SpreadBookViewTests` · `StaleWriteIntentTests` · `StarActingTests` · `StarDeclarationTests` · `StarTargetingTests` · `StarredScrollLayoutTests` · `StarredScrollMountTests` · `StatusCenterTests` · `StatusSeamVocabularyTests` · `StatusToastPlacementRuleTests` · `StatusToastPlacementShellTests` · `StructuralRewriteDoorTests` · `SupportChoiceTests` · `SupportDraftTests` · `SurfaceSizeMemoryTests` · `SystemHotKeyChordTests` · `SystemHotKeyDeclarationTests` · `SystemHotKeyRoadTests` · `TagAndFolderTests` · `TagChipFitTests` · `TagChipLeafTests` · `TakeCardDoorTests` · `TakeCardMenuTitleTests` · `TakeLabelFaceTests` · `TakePaneDurabilityTests` · `TakePaneMeasureTests` · `TakeToBlockDoorTests` · `TakesArticleRenderTests` · `TakesArticleScrollTests` · `TakesArticleWatchTests` · `TakesBoardSoakTests` · `TakesBoardTests` · `TakesBufferConvergenceTests` · `TakesCardHeightTests` · `TakesChooseRingTests` · `TakesDivideTests` · `TakesEmptyBlockFaceTests` · `TakesEmptyStateTests` · `TakesEntryBandTests` · `TakesFindBoardTests` · `TakesFindReplaceTests` · `TakesLandingTests` · `TakesLensFilterTests` · `TakesMarginGridAlignmentTests` · `TakesMarginGridCaptureTests` · `TakesParkedFollowTests` · `TakesPresentationTests` · `TakesRailPagingTests` · `TakesReplaceRuleTests` · `TakesRoomTests` · `TakesSlotDragTests` · `TakesStepFollowModelTests` · `TakesStepFollowTests` · `TakesWordCountTests` · `TourEndCardAsideGateTests` · `TourEndCardTests` · `TourEngineTests` · `TourEntryTests` · `TourOfferLineTests` · `TourPoolTuckTests` · `TourScriptTests` · `TourSpotlightTests` · `TrashPoolHonestyTests` · `TrashSurfaceTests` · `TrayPanelMoveTests` · `TutorialBookShapeTests` · `TutorialBooksLessonTests` · `TutorialBooksRitualTests` · `TutorialBuildFlavorTests` · `TutorialCurrencyTests` · `TutorialDeletionActsTests` · `TutorialDoorTests` · `TutorialFannedMatrixTests` · `TutorialFurnitureFoldTests` · `TutorialLibraryActsTests` · `TutorialLookingActsTests` · `TutorialMCPChapterCaptureTests` · `TutorialMCPChapterTests` · `TutorialPrivacyChapterTests` · `TutorialStructureActsTests` · `TutorialTakesActsTests` · `TutorialWherePlacesActsTests` · `TutorialWritingActsTests` · `TwoWindowMountTests` · `UndoHintAndRefusalTests` · `UndoWarningWordsTests` · `VX209GuideWarningTests` · `VX209LeavesCastleConfirmTests` · `ViewMenuSeparatorTests` · `VocabularySweepTests` · `WhatsNewTests` · `WindowRegistryTests` · `WindowUnmountTests` · `WingBookMoveDoorTests` · `WingContentsArchivedWordsTests` · `WingSwitcherChordTests` · `WingSwitcherTests` · `WorkspaceCloseActTests` · `WorkspaceModelTests` · `WorkspaceNamingTests` · `WriteBlockSelectionTests` · `WriteTakesPanelChooseTests` · `WriteTakesPanelKeysTests` · `WriteTakesPanelRoutedCommandTests` · `WriteTakesPanelTests`

**Expected standing reds this set meets (not U1's):** VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (Todo); VX-167's order-dependent `DestructiveUndoWarningTests.redoNeverAsks` (Parked — red only in wide parallel runs). The pointer-injection suites in the set demand an idle machine (the frozen archive's row 85).

**Phone (simulator — `MOBILE-VISIBLE`, see piece 3):** `VariorumMobileTests/MobileVersionsTests` (its Promote drives the shared `VersionActs.promote` → the changed op; the receipt words are unchanged, so it should stay green — it is the evidence that the phone's Promote still lands). No phone source changed.

**Red-on-old for the Mac pins:** BY COMPILATION (every Mac pin names the new capability ids, `NoteDuplicate`, `DuplicateCopy` or `Operations.DuplicateTags`) — stated, not measured; the behavioural reds are the headless pieces 1, 3 and 6.

### THE WALK FOR U1 (dev-store Debug build `io.lduarte.Variorum.debug`, both voices — Study, then Terminal for W1 · W5 · W6 · W8; captures into `notes/plans/vx383-screens/u1/walk/`)

- **W0 — set-up (dev store):** a tag `#u1dup` on a note "u1 source" with two blocks (one fanned); a book "u1 living" whose rule gathers `#u1dup`, New matches: join quietly; a second book "u1 bell" on the same tag with "wait at Arrivals".
- **W1 — the Library row:** right-click "u1 source" → the menu shows **Duplicate with Tags** and **Duplicate without Tags** where "Duplicate as Version" stood (no "Duplicate as Version" anywhere) → **Duplicate with Tags** → the receipt (quiet line at the bar's end by default): **"Duplicated with tags — the copy is in “u1 living”."** with **Open ›** → press it → the copy opens, wearing `#u1dup`. "u1 living"'s Index lists the copy at its end; "u1 bell"'s Arrivals icon shows presence with the copy waiting (an arrival is not counted). Capture each.
- **W2 — her undo over the seat:** the Edit menu reads **"Undo Duplicate with Tags"** → ⌥⌘Z → the copy leaves "u1 living" (and "u1 bell"'s Arrivals) and sits in the Trash → ⇧⌥⌘Z → back in "u1 living" at the same place, the bell back.
- **W3 — a dismissal between:** duplicate with tags again → at "u1 bell" Arrivals **Dismiss** the copy → ⌥⌘Z → ⇧⌥⌘Z → the copy back in "u1 living" and NOT waiting at "u1 bell" (her dismissal stands).
- **W4 — the Pool row, without tags:** in the Pool, right-click a tagged note → **Duplicate without Tags** → the receipt **"Duplicated without tags — the copy is in the Pool."** → the copy wears no tag; neither book took it.
- **W5 — `note ▾` in Write:** open "u1 source" (⌘1) → the bar's `note ▾` → **Duplicate with Tags** and **Duplicate without Tags** right under Versions… → press without → its receipt; then in Takes (⌘2) the board's bar `note ▾` shows the same two rows.
- **W6 — ⌘K:** with "u1 source" shown, ⌘K → type "duplicate" → both rows → **Duplicate with Tags** → its receipt; on the Bookcase (no note open) the File menu's two rows are GREY.
- **W7 — the File menu:** with a note open, File → **Duplicate with Tags** / **Duplicate without Tags** under Save a Version, enabled; press one.
- **W8 — the shipped inline doors, renamed:** Takes board header `note actions ▾` → **Duplicate with Tags**; Lenses (⌘4) Chosen column → **⧉ Duplicate with Tags** pull-down → its row; the book chip under the title (a note in a book) → popover → **Duplicate with Tags** → the popover's status line says where the copy landed, **Open the Copy** opens it.
- **W9 — Save Version → Promote:** on "u1 source": Save a Version (⌘⇧S), then add `#u1dup2` to the note and remove nothing → Note ▸ Versions… → the moment → **Promote** → the promoted note (Library) wears `#u1dup` and `#u1dup2`, and "u1 living" took it in.
- **W10 — the words:** ⌘/ → the dictionary's **version** entry names DUPLICATE WITH TAGS / DUPLICATE WITHOUT TAGS; (dev store only) Help ▸ Restore Tutorial… → the field guide's "compare & versions" lesson reads the new sentences.
- **Posture after:** delete the walk's notes/books/tags (Trash), restore the voice, leave the dev store as found (memory: walks restore dev-store posture).

### PROVISIONALS (U1's — to the QUESTIONS bundle at the merge, beside P-C-1…3)

- **P-U1-1 — every duplicate door speaks ONE receipt with "Open ›"**, the shipped Library/Pool/Takes-board rows included (they acted in silence before; with tags the copy can now land in a book, so silence hides where it went). Options: (a) BUILT; (b) only the new doors (File, ⌘K, `note ▾`) speak, the shipped rows stay silent; (c) a receipt with no door.
- **P-U1-2 — the receipt's words say WHERE:** "Duplicated with tags — the copy is in the Pool." · "…in “Book”." (one book) · "…in N books."; "Duplicated without tags — the copy is in the Pool."; an ARRIVAL is not mentioned (the copy is still in the Pool, and the book's Arrivals icon shows it). Options: (a) BUILT; (b) also name a bell ("…waiting at “Book”'s Arrivals"); (c) no location ("Duplicated with tags.").
- **P-U1-3 — ⌘K and the File menu act on the note she is WRITING in when no note detail is mounted** (a book's inline note — `noteScoped` already counts that editor, so the door was enabled there). Options: (a) BUILT; (b) the mounted detail only — Copy full text's shipped posture (the book's inline note hears "open one first").
- **P-U1-4 — the three shipped inline doors** (the Takes board's `note actions`, the Lenses Chosen column, the book chip) **carry WITH tags only**, under its verb (the plan's "route to the with-tags act"); without tags lives on the File menu, ⌘K, both `note ▾` menus and the note rows. Option: (b) both verbs on each inline door.
- **P-U1-5 — placement:** File menu right under Save a Version; both `note ▾` menus right under Versions…; the note rows where "Duplicate as Version" stood. Option: (b) a "Duplicate ▸" submenu holding both.
- **P-U1-6 — the re-worded sentences, for her VX-234 pass:** the helper's "version" entry, `DivergeCopy`'s smart-book refusal ("…a copy appears there only if it carries the same tags. Duplicate with Tags makes one that does."), the first-edit note ("To make a copy that can diverge, use Duplicate with Tags (the book chip under the title)."), the inline doors' help, the guide's three sentences (piece 4).

### NOTES FOR U2 (D-C-4 — things U1 changed under the wire, which U2 must finish)

- **The wire's behaviour moved in U1:** `duplicateNoteForClient(_:tags: = .applied, …)` runs the shared body with tags APPLIED, so a `duplicate_note` copy is now heard by intake (P-C-3's ruled default) — with no wire file touched. U2 wires `with_tags` to this parameter (`with_tags ? .applied : .none`).
- **Stale until U2 rewrites them:** `MCPToolCatalog.duplicateNote`'s description ("the author's own Duplicate as Version" — a retired label; "The copy lands in no book" — no longer always true: a book collecting one of its tags may take it in) and the answer's `landed` ("the Pool of Home" even when intake seated the copy) — D-C-4's answer and docs. `MCPSession.instructions` line 147 names no label (fine).
- **Pins that will need the same thought:** `MCPDuplicateNoteServerTests.theCopyLandsBooklessInTheSourcesWingAndAnswersWhatItMinted` passes today only because its book is plain (no rule).

### SELF-ASSESSMENT

- **Sound:** D-C-1 takes the ONE application road (`insertPostTag`) in the act's own transaction, so intake's whole table (seat, bell, capacity, ownership, finished/archived pauses) is inherited rather than re-stated — and its undo story needed no new machinery: the container trigger and the exact-stamp revival already carry seats and bells, as the four undo/redo pins measure (a dismissal and a seat she judged between both stand). D-C-3 reuses the same helper after the flips. D-C-5's question has a clean answer (no seeded living book exists). D-C-2 follows the `CopyForAI` precedent exactly (one act in `Core/Views`, the bars call it directly, ⌘K through `ShellActions`), so no `RoutedCommand` case and no surface handler were needed — the act needs a note, not an editor.
- **Weakest points, for the reviewer's eye:** (1) every Mac line is compiled but UNRUN (Tier A first); (2) P-U1-1 changes three shipped faces from silent to a receipt; (3) the receipt's book lookup reuses `Queries.readingsContaining`, which also assembles each living gathering's rule for the ONE copy — author-scale, but it is a read after the act on every press; (4) the `.variorumOpenPost` broadcast for Open › is the chip's and Arrivals' existing road (P-4: a signal, the opening decides nothing) — not the composition road `ShellRouter.pendingSelection`, which `NoteDuplicate` cannot reach from the bars; (5) the plan's MOBILE PARITY line was wrong (the phone's Promote now applies tags) — corrected in piece 3 for the closeout; (6) between U1 and U2 the wire's description overclaims "lands in no book" (same PR; U2 owes it).
- **Not touched:** `Sources/VariorumCore/Sync/`, custody, the Keychain, any migration or schema, the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface` — `EditorView`/`EditorViewModel` untouched too), the wire (`Sources/VariorumMCP/`). No trace led to any of them.

## U2 UNIT RECORD — VX-371: `duplicate_note` files into a book; `with_tags`; the answer; the docs (opus-implementer, from 2026-10-17)

**NOT DONE BY THIS SESSION (the record's first line, per the contract): the Mac test batch (61 suites + the faces pin's red run), the REAL-CLIENT LIVE ROUND and its captures in both voices — none run (they need a stage window, the orchestrator's; listed below, exact). Every Mac pin is therefore PENDING its first run. The field guide's recipe 6 and the public guide page are NOT touched (outside the brief — OWED below).** Everything else is DONE: D-C-4 built (the parse, the book road, the guard, the core's filing through the one body, the answer, the receipt, Activity, the scopes, the description); 13 wire pins committed ahead and RED on the pre-fix tree, then green; 6 core pins; four behavioural reverts red then restored by checksum; a red Mac product for the faces pin; the whole package green but VX-353's standing flake (green alone); the Mac app and its tests compiled twice (green and red products). No stage claimed, no app launched, no `xcodebuild test`, no store touched by this session.

**Read in (in full, this session's own context):** CLAUDE.md + its canon; this file whole (the design D-C-1…5, the U2
brief, the environment traps, U1's UNIT RECORD and its NOTES FOR U2); `notes/MCPSpec.md` whole;
`notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` §U6a (the traces, D-311-1…8, PROVISIONALs, FOR VX-234, THE
ORCHESTRATOR'S RULINGS ON U6a's FORKS and its ONE OPEN DECISION); `notes/QUESTIONS.md` #227 with her answers
(P-VX311-1…3, P-VX361-1, VX-371's shape); `notes/SessionResiliencyProtocol.md`. Code (every pointer at `5857f3a71`):
`MCPWriteTools+DuplicateNote.swift` (`performDuplicateNote`, `guardDuplicate`), `MCPWriteTools.swift` (the Job, the
parse, `create_note`'s `into(.book)`, `noteIntoBook`, `inWing`, `land`, `noteAnswer`, `sectionWithoutBookWords`),
`MCPWriteTools+WingMove.swift` (`guardWingMove`, `landedWords`, `left_books`' naming rule), `MCPGrantAuthority.swift`,
`Domain/MCPGrantRule.swift`, `Queries/MCPGrantQueries.swift` (`mcpNoteFacts`, `mcpBookFacts`, the resolved wing),
`MCPWriteSupport.swift` (`MCPWriteReceipt`, `MCPWireRefusalCopy`), `MCPOwnActivity.swift` (`hidesTarget`),
`MCPToolCatalog.swift` (`createNote`, `addNoteToBook`, `duplicateNote`), `MCPSession.swift` (the instructions),
`Operations+MCPDuplicate.swift`, `Operations+Versions.swift` (`duplicateAsVersion(Body)`, `applyLiveTags`, `copyPost`),
`Operations+MCPWrites.swift` (`mintNoteEntry`'s book road, `mintedNoteTags`), `Operations+Reading.swift`
(`addPostToReading`, `requireSameWing`), `Operations+Intake.swift` (`insertPostTag`, `applyAutoTag`), the app's
`MCPPaneCopy.swift` (Activity's phrases, `MCPReceiptCopy`, `MCPActivityFace`), `NoteDuplicate.swift` (U1's landed
words), the pins `MCPDuplicateNoteServerTests`, `MCPDuplicateNoteActsTests`, `MCPMintedAnswerServerTests`,
`MCPOwnActivityServerTests`, `MCPAdviceServerTests`, `TutorialMCPChapterTests` (:1048 pins a substring of the
description), `MCPTakeLabelFormServerTests`.

**Housekeeping:** headless logs in `notes/plans/vx383-screens/u2/logs/` (gitignored — the run's folder).

### The traces (written before code)

- **Why a book-level client can't duplicate today** (the ticket's mechanism): `performDuplicateNote` decides the
  landing ONLY by `decideWing(standing, wingID: facts.wingID, rung: .writeNew)` (`MCPWriteTools+DuplicateNote.swift`
  :78–85) — a book grant never reaches `decideWing` (`MCPGrantRule.decideWing` filters `scopeKind == .wing`), so a
  client whose write new is a BOOK hears the wing's refusal; and the catalog lists the tool only under `scopes: [.wing]`
  (`MCPToolCatalog.swift:1027`), so such a client never even sees it. `create_note` files into a book through
  `into(.book)` → `MCPGrantAuthority.decide(standing, book: mcpBookFacts, rung: .writeNew)` (`MCPWriteTools.swift`
  :680–699) and the core's `mintNoteEntry` (`Operations+MCPWrites.swift` :538–600: the book's gates and the chapter
  BEFORE the mint, then `addPostToReading(db, …, at: .end)` — the hand-add's one choke point, its capacity and ownership
  gates and its outflow — then the section stamp, then the header's tags).
- **Why `with_tags` is owed:** since U1 the wire's body runs `duplicateAsVersionBody(…, tags: .applied)` by default
  (`Operations+MCPDuplicate.swift` :54–64) with no wire argument to choose `.none`.
- **Why the answer and the docs overclaim since U1** (U1's NOTES FOR U2): `landed` is always
  `landedWords(wingTitle:isHome:)` — "the Pool of Home" even when a living book collecting one of the copy's applied
  tags SEATED it in the same act; the description still says "the author's own Duplicate as Version" (a retired label,
  P-C-1) and "The copy lands in no book".
- **The order the plan rules, and why it matters (red-on-old by revert, piece 5):** with the destination a QUIET living
  book whose rule collects one of the source's tags, applying the tags BEFORE the filing would let intake SEAT the copy
  first, and the filing's `addPostToReading` would then refuse `alreadyInReading` — so the membership must come first
  (then this book's own pair is decided and the applications are heard by the OTHER books, `mintNoteEntry`'s order).
- **A book of another wing:** `addPostToReading`'s `requireSameWing` would refuse `crossWingMembership` — a sentence the
  wire must never speak for a book it then refuses to name (no oracle); the wire answers such a book exactly as a
  missing one (the facts read as nil — `MCPGrantAuthority.decide(book: nil)` → the ONE not-shared shape, no ask).

### The design as built (D-C-4 applied; the plan's words where it has them)

- **The parse:** `with_tags` (boolean, default true; anything else "with_tags must be true or false." — the read
  tools' sentence), `book_id` (optional), `section_id` (optional, with `book_id` only — `create_note`'s parse rule and
  its sentence, `sectionWithoutBookWords`).
- **The reach — the snapshot:** the NOTE at READ (+ the fence, byte-for-byte as today: P-VX311-1's sentence, checked
  before the landing so no landing ask is raised for an act that can never land); then the LANDING: no `book_id` → the
  WING road exactly as today (`decideWing` at WRITE NEW, its refusal and its ask); with `book_id` → `create_note`'s book
  decision (`decide(book:)` at WRITE NEW, consuming, its refusal and its ask on the book), the book's facts read as nil
  when its resolved wing is not the note's (another wing's book = the ONE not-shared shape, byte-identical to an id
  naming nothing, no ask). ONE ask, the source's first.
- **The guard** (`guardDuplicate`, inside the act's transaction, FIRST): the note at READ, the fence, then the landing
  side as the snapshot decides it (the book with the same wing filter, or the wing), on ONE standing read; the once
  grants of both sides stamped there as ONE union (`guardWingMove`'s shape).
- **The core:** `Operations.DuplicateFiling` (book, optional chapter) threads through THE ONE BODY
  (`duplicateAsVersionBody(_:_:tags:filing:)` — her doors pass none, so their rows are byte-unchanged): the book's gates
  and the chapter BEFORE the copy (`mintNoteEntry`'s order), the family copy, then the membership through
  `addPostToReading` (capacity, ownership, wing, the outflow), the chapter stamped on that row, THEN the `with_tags`
  applications. `duplicateNoteForClient(_:tags:filing:undoLabel:guardedBy:) -> MCPDuplicate` adds, inside the same
  transaction, the tag listing (P-VX361-1's shape: the source's applied tags in application order, then the book's
  outflow, each listed once — `mintedNoteTags`, now shared) and every live BOOK the copy is a member of (the filing
  first). ONE entry (`registerMintedContainerEntry`): the container tombstone takes the membership, its applications
  and any seats on one stamp; the redo revives them on it. The old spelling (`duplicateNoteForClient(_:tags:undoLabel:
  guardedBy:) -> PostCopyResult`) stays as its one caller-facing wrapper (U1's pins call it).
- **Refusals** through the ONE chain (`land` → `MCPWireRefusalCopy.spoken`): a finished book `lockedReading` and a full
  one `readingAtCapacity` in her doors' words (the app's table); a chapter that isn't the book's →
  `add_note_to_book`'s one chapter sentence; a gathering's id reads as no book's (not-shared, as `create_note`). **An
  ARCHIVED book is NOT a refusal** — AppSpec §9's 13i-e family: "EXPLICIT adds land (her amendment — no
  `readingArchived` refusal exists)", and `create_note`'s road lands there too; the brief's list names "archived"
  among the refusals, the plan's D-C-4 does not — built to the plan + AppSpec, pinned as a landing control.
- **The answer:** VX-252's records (+ `source_block_id`), `source_note_id`, `block_ids`, **`tag_ids` + `tags`** (both
  roads), `book_id` and `section_id` echoed when given, **`landed`** in words (PROVISIONAL P-U2-1 below).
- **The receipt:** act `.duplicate`, target the COPY, `detail` = the book's name when filed; Open › opens the copy
  (P-VX311-3). **Activity:** the book road's rows are logged on the BOOK (PROVISIONAL P-U2-2 below).
- **Scopes:** `[.book, .wing]`.
- **The docs:** the description rewritten (both roads, the default, `with_tags: false`, "books that collect by its
  tags hear the copy, as when the author tags"; "Duplicate as Version" retired; the substrings two pins read kept).
  `MCPSession.instructions`' revision sentence names no reach — unchanged. The guide's MCP lesson 3 names no reach —
  unchanged (recipe 6's "in no book" is recorded under OWED, outside this brief).

### LIVE STATUS — U2's pieces (flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | read-in, the traces, the design, this record | DONE (this commit) |
| 1 | the wire pins, committed AHEAD of the fix, run RED on the pre-fix tree | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPDuplicateNoteFilingServerTests.swift` (13 tests, the SDK's client over a real socket, every call on the tool's pre-existing name so the file compiles on the pre-fix tree): a book-level write new files the copy at the book's END in one act and one undo (the answer's `book_id`/`landed`/`tag_ids`, the receipt's `detail`, the Activity row on the book, ⌥⌘Z leaving the book without it and ⇧⌥⌘Z the SAME row back) · a chapter files it and `landed` names it · every `section_id` that isn't the book's chapter answers the ONE sentence, and `section_id` without `book_id` the parse's · a book of another wing (writable), an unreached one and an id naming nothing answer byte-identically, no ask · the book's side of a refusal speaks, asks for the BOOK and is logged on it (`list_my_activity` keeps the sent id) · `with_tags: false` copies no tag and no book hears it (a non-boolean refused) · by default a collecting book takes the copy in and `landed` says so (an Arrivals book rings, unnamed) · THE ORDER: a destination that collects the copy's tag takes it ONCE, filed in its chapter, never an arrival, and an unreadable collecting book is said without its name · an owned destination takes it and a plain collecting book BELLS it · finished and full refuse in her words (the chain), a gathering is no book's, an archived book takes the add · once grants of both sides spend as one, a refused act spends nothing · listed to a book-level write new, never a note-level one · `tag_ids`/`tags` = applied then outflow, each once (without tags, the outflow alone). **RED on the pre-fix tree (`36589add6` + the file): "Test run with 13 tests in 1 suite failed … with 42 issues"** — all 13 red, each on its designed line (`notes/plans/vx383-screens/u2/logs/p1-pins-red.log`, `.pairs` — 35 distinct pairs): the book road's six by the wing's refusal (`:144`, `:200`, `:416`, `:450`, `:597`, `:532/:540/:543`), the ignored arguments by landing (`:233`×3, `:238`, `:239`, `:241`; `:272`, `:283`×4, `:287`; `:344`, `:345`, `:353`–`:355`; `:497`×3, `:500`, `:507`), the wing's ask and log (`:309`, `:311`, `:315`, `:318`), the stale `landed`/no `tag_ids` (`:381`, `:384`), the listing (`:566`) |
| 2 | the core: `DuplicateFiling` through the one body, the client op's result, the tag listing; core pins | DONE (this commit) — `Operations+Versions.swift`: NEW `Operations.DuplicateFiling` (book, optional chapter); `duplicateAsVersionBody(_:_:tags:filing: = nil)` — with a filing, the book's gates (live, a book — `wrongReadingKind`, unfinished — `lockedReading`) and the chapter (`sectionNotFound`/`sectionNotInReading`) BEFORE the copy (`mintNoteEntry`'s order), the family copy, the membership through `addPostToReading` (capacity, `requireSameWing`, ownership, the outflow), the chapter on that row, THEN the `with_tags` applications; her doors pass none (rows byte-unchanged); `liveTagIDs(_:of:inWing:)` factored out of `applyLiveTags` (one statement for what is applied and what is listed). `Operations+MCPWrites.swift`: `mintedNoteTags` internal, its header by ids (create_note's call maps `header.map(\.id)` — same list). `Operations+MCPDuplicate.swift`: NEW `MCPDuplicate` (the copy, `tagIDs`/`tagPaths` — applied then outflow, each once — and `memberBookIDs`, the filing first then intake's seats, all read INSIDE the act's transaction) and `duplicateNoteForClient(_:tags:filing:undoLabel:guardedBy:) -> MCPDuplicate` (guard first, the one body, ONE `registerMintedContainerEntry`); the old spelling is now its filing-less wrapper (`.copy`). NEW core pins `Tests/VariorumCoreTests/MCPDuplicateFilingActsTests.swift` (6 tests — filed at the end in its chapter under ONE entry, the undo tombstoning the filing AND a tag seat on the copy's one stamp, the redo returning the same rows · THE ORDER: a collecting destination takes the copy once, filed, the other book's bell · an owned destination is a plain add, a plain collecting book bells · the answered tags (applied then outflow, once; without tags the outflow alone; the list is the store) · the destination's refusals (finished, gathering, full, another wing, another book's chapter, a deleted chapter) mint nothing and register nothing; an archived book takes the add · her doors file nothing) — NEW API, red-on-old BY COMPILATION (the house's rule for a pure addition; the ORDER's behavioural red is piece 5's revert). **GREEN: the 6 + every core suite touching a changed function — "Test run with 269 tests in 28 suites passed", EXIT 0** (`u2/logs/p2-core-wide.log`: CommentTravel, DuplicateAppliesTags, DivergeAndExtractSeam, DuplicateCarriesTags, DuplicateWithoutTags, FanOrder, LibrarySameMacRestoreDrill, MCPDuplicateFilingActs, MCPDuplicateNoteActs, MCPLensDoorsActs, MCPEditActs, MCPMintedBlocksActs, MCPWriteActs, NoteVersions, PoolDragCopy, PromoteAppliesTags, RedoStack, TrashAndArchive, UndoQuietPress, VersionOperations, IntakeOperations, IntakeSoak) |
| 3 | the wire: parse, the book road, the guard, the answer, the receipt, the catalog; justified edits | DONE (this commit) — `MCPWriteTools.swift`: `Job.duplicateNote(noteID:withTags:bookID:sectionID:)`, the parse and the dispatch. `MCPWriteTools+DuplicateNote.swift`: `parseDuplicateNote` (`with_tags` a boolean, default true, else "with_tags must be true or false."; `section_id` without `book_id` → `sectionWithoutBookWords`); `performDuplicateNote` — the note at READ and the fence UNCHANGED, then THE BOOK ROAD with `book_id` (`mcpBookFacts` read through `inWing` — another wing's book is nil, so `decide(book:)` answers the ONE not-shared shape with no ask; `decide(book:, .writeNew, consumes)` with `create_note`'s refusal + ask on the book; landed rows logged on the BOOK with its name, `logsReceiptTitle: false`) or else THE WING ROAD byte-for-byte (the same decision, refusal, ask and log line as VX-311); both call `duplicateNoteForClient(_:tags:filing:…)`; `guardDuplicate(_:noteID:bookID:)` re-decides the note, the fence and the landing side (the book through the same `inWing`, or the wing) on ONE standing read inside the act and spends the union; `duplicateAnswer` — VX-252's records, `source_note_id`, `block_ids`, `tag_ids` + `tags` (from the act), `book_id`/`section_id` echoed, `landed` (`duplicateLandedWords`, P-U2-1: "the end of “B”" [+ ", in its chapter “C”"], else the Pool words; then every book intake SEATED it in — named where the client reads it, else "a book not shared with you" — "…, which collects one of its tags"); the receipt `detail` = the book's name when filed, Open › the copy. `MCPToolCatalog.duplicateNote`: `scopes: [.book, .wing]`; the schema gains `with_tags`, `book_id`, `section_id`; the description rewritten (both roads, the default, `with_tags: false`, the books that collect by its tags hearing the copy, the outflow on a filed copy, the answer's new fields; "Duplicate as Version" retired; the substrings `TutorialMCPChapterTests:1048` and `MCPTakeLabelFormServerTests:128` read are kept). No justified edit was needed: no existing pin asserted the old answer's key set or the old scopes. **GREEN: the 13 VX-371 pins + VX-311's 7 — "Test run with 20 tests in 2 suites passed", EXIT 0** (`u2/logs/p3-pins-green.log`); **every MCP suite naming `duplicate_note`, the grant authority, the catalog/instructions pins, the refusal chain, create_note's minted answer + the core grant-rule suites — MCP "169 tests in 21 suites passed … with 1 known issue" (VX-357's `withKnownIssue`) and core "97 tests in 12 suites passed", EXIT 0** (`u2/logs/p3-mcp-wide.log`) |
| 4 | the app's words (Activity, the receipt) + their pins; the Mac `build-for-testing` (no runner) | DONE (this commit; the pins' red and green PENDING the batch) — `MCPPaneCopy.swift`: Activity — a `duplicate_note` row of kind `book` says "duplicated a note into “B”" (×N: "duplicated N notes into “B”"), its refused book side "duplicating a note into “B”" (the note and wing sides unchanged); the receipt — "duplicated “X” into “B”" when `detail` names the book (unchanged without), and ONE filed duplicate too long for the bar keeps the BOOK, dropping the note's title ("duplicated a note into “B”" — the wing move's precedent) before the "made a change" fallback. NEW Mac pin `VariorumTests/MCPDuplicateFilingFacesTests.swift` (2 tests — Activity's book lines + the unchanged note/wing lines; the receipt with and without the book, the long line keeping the book within `budget`) — pure faces, red on the pre-fix tree BY ASSERTION (the book kind fell to the note's phrase; the receipt ignored `detail`): PENDING its red run on the red product piece 5 builds and its green run on `vx383-u2`. **The Mac `build-for-testing`** from `App/Variorum/` at this commit's tree (`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx383-u2 build-for-testing`): **TEST BUILD SUCCEEDED, XCB-EXIT 0** in 3:04 (`u2/logs/p4-mac-build.log`), no warning in a touched file. The product `App/Variorum/DerivedData/vx383-u2` holds U1 + U2 (the tip) — the batch runs both units' Mac pins from it |
| 5 | revert checks (announced in this record BEFORE any revert starts) | DONE (this commit; **NO REVERT IN FLIGHT** — every file restored from `<scratchpad>/u2-prerevert/`, each `sha256` equal to `git show HEAD:<file>`, `git status` clean) — announced at `3c8e84b85` before the first edit. **R1 the ORDER** (`duplicateAsVersionBody`'s applications moved before the filing) → wire **"13 tests … failed … with 4 issues"** + core **"6 tests … failed … with 2 issues"**: `MCPDuplicateNoteFilingServerTests.aDestinationThatCollectsItsTagTakesTheCopyOnceFiledInItsChapter` `:416`/`:397` and `anOwnedDestinationTakesTheCopyAndAnotherCollectingBookBellsIt` `:450`/`:434` (both refused); `MCPDuplicateFilingActsTests.theMembershipComesFirst…` `:120` (`alreadyInReading` — the quiet destination seated the copy first) and `anOwnedDestinationIsAPlainAdd…` `:144` (`noteMemberedElsewhere` — the plain book seated it first, so the owned book's add met a note membered elsewhere) — the order is load-bearing on BOTH its named consequences (`p5-R1-red.log`, `.pairs`). **R2 the wing filter** (`inWing` passing every book) → **"13 tests … failed … with 3 issues"**: `aBookOfAnotherWingAnswersTheOneNotSharedShapeAndRaisesNoAsk` `:283` ×2 (the writable other wing's book answered "Refused: crossWingMembership(…)" — the oracle) and `:288` (the third wing's book raised an ask). **R3 `with_tags` ignored** → **"13 tests … failed … with 6 issues"**: `withTagsFalseCopiesNoTagsSoNoBookHearsTheCopy` `:353`–`:356` and `theAnswerListsEveryTag…` `:609`/`:610` (the bare copy wore the applied tags). **R4 `scopes: [.wing]`** → **"13 tests … failed … with 1 issue"**: `itIsListedToABookLevelWriteNewAndNeverToANoteLevelOne` `:566`. **Restored:** "20 tests in 2 suites passed" + "6 tests in 1 suite passed", EXIT 0 (`p5-restored-green.log`). **R5 the app's words** (`MCPPaneCopy.swift` as at `80e97a6fa`) → the RED Mac product `App/Variorum/DerivedData/vx383-u2-red` (**TEST BUILD SUCCEEDED, XCB-EXIT 0**, `p5-R5-mac-red-build.log`; its `Variorum.debug.dylib` carries "duplicated a note into" ×0, `vx383-u2`'s ×2) — its run is the batch's: `MCPDuplicateFilingFacesTests` expected RED there on exactly `:39` `:40` `:42` `:44` (the book lines fall to the note's phrase / the fallback noun) and `:56` `:62` (the receipt ignores the book; the long line falls to "made a change"), with `:46` `:47` `:49` `:58` `:64` GREEN (the unchanged lines) — PENDING |
| 6 | headless finals (the named suites, then the whole core + MCP packages once) | DONE — the named suites: pieces 2, 3 and 5 (core 269/28 · the duplicate wire 20/2 · MCP wide 169/21 + core grant-rule 97/12 · restored 20/2 + 6/1, all EXIT 0). **The whole package once** at `6271cc463` (`swift test`, `u2/logs/p6-whole-package.log`, load average 18–23 from another worktree's build): **VariorumCoreTests "2895 tests in 337 suites passed"** · **workbook "40 tests in 6 suites passed"** · **VariorumMCPTests "362 tests in 68 suites failed … with 2 issues (including 1 known issue)"** — the ONE failure is VX-353's standing flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (19.7 s past its 15 s bound under the load; untouched by this unit — U1 met it too) and the known issue VX-357's `withKnownIssue`; **re-run alone: "3 tests in 1 suite passed", EXIT 0** (`p6-timelimit-rerun.log`). `git diff --stat 3c8e84b85 -- App Sources Tests` is EMPTY, so both Mac products are the tip's sources |
| 7 | the Mac batch list, the LIVE ROUND SCRIPT, PROVISIONALs, the self-assessment | DONE (this commit) — below |

### THE MAC BATCH FOR U2 (for the orchestrator's stage window — every suite that exercises a changed SOURCE file)

**Products** (both from `App/Variorum/`, `xcodebuild … build-for-testing`, no runner; each `Build/Products/
Variorum_Variorum_macosx27.0-arm64.xctestrun`): **`App/Variorum/DerivedData/vx383-u2`** — THE TIP's sources (U1 + U2;
`git diff --stat 3c8e84b85 -- App Sources Tests` empty) — and **`App/Variorum/DerivedData/vx383-u2-red`** — the same with
`MCPPaneCopy.swift` as at `80e97a6fa` (piece 5's R5). Run: `xcodebuild test-without-building -xctestrun <file>
-only-testing:VariorumTests/<Suite> …`, and confirm the "Test run with N tests" line.

**The red run (first):** `vx383-u2-red` · `-only-testing:VariorumTests/MCPDuplicateFilingFacesTests` → expected **2 tests
failed**, issues at exactly `:39` `:40` `:42` `:44` `:56` `:62` (record each pair); then the same suite on `vx383-u2` →
green.

**The green batch on `vx383-u2` — 61 suites** (the files under `App/Variorum/VariorumTests` naming a changed type or act —
`MCPPaneCopy|MCPReceiptCopy|MCPActivityFace|MCPToolFacts|MCPToolCatalog|duplicateAsVersion|duplicateNoteForClient|
createStructuredNote|importNote(|createNote(|MCPServerHost|MCPDoor|MCPWriteReceipt|mintedNoteTags|applyLiveTags|
NoteDuplicate|DuplicateCopy|promoteNoteVersion` → 38 files — then every type with a `@Test` in them; each verified a real
type in `vx383-u2`'s test bundle, `nm -j` + `swift-demangle --simplified`, ≥ 57 symbols each; the list is also
`notes/plans/vx383-screens/u2/batch-suites.txt`, gitignored, on the Pro):

`BranchDoorFlushTests` · `CompareAnchorWholeTests` · `CompareCompositionTests` · `CompareLensesAlignmentTests` ·
`CompareOnePlacementTests` · `CompareViewModelTests` · `CopyDoorFlushTests` · `DuplicateDoorsTests` · `LensesReorderTests` ·
`MCPAskAndReceiptTests` · `MCPAsksWaitCaptureTests` · `MCPAsksWaitTests` · `MCPCompareLandingTests` ·
`MCPDeliberateFacesTests` · `MCPDoorErgonomicsFacesTests` · **`MCPDuplicateFilingFacesTests`** (NEW, 2) ·
`MCPEditFacesTests` · `MCPEditParityFacesTests` · `MCPGrantSheetCaptureTests` · `MCPGrantSheetTests` ·
`MCPGrantSheetU2CaptureTests` · `MCPHerEditorDoorTests` · `MCPLibraryParityFacesTests` · `MCPNavigationTests` ·
`MCPPaneTabsCaptureTests` · `MCPPaneTabsTests` · `MCPPaneTests` · `MCPRebindFaceTests` · `MCPSetupKeyFacesTests` ·
`MCPSetupMenuTests` · `MCPSetupTabKeyTests` · `MCPShareFacesCaptureTests` · `MCPShareFacesTests` · `MCPWingFacesTests` ·
`MCPWireRefusalSweepTests` · `QuitFinalizeSurfacesTests` · `SavepointCommitDoorTests` · `SavepointNameAskTests` ·
`SavepointNameCopyTests` · `SavepointNameFaceTests` · `SavepointRenameDoorTests` · `SavepointSealedDoorTests` ·
`SavepointTakesDoorTests` · `ScrubAndOutlineTests` · `TakesBoardSoakTests` · `TakesBoardTests` ·
`TakesBufferConvergenceTests` · `TakesPresentationTests` · `TutorialBookShapeTests` · `TutorialDeletionActsTests` ·
`TutorialDoorTests` · `TutorialFannedMatrixTests` · `TutorialLibraryActsTests` · `TutorialLookingActsTests` ·
`TutorialMCPChapterCaptureTests` · `TutorialMCPChapterTests` · `TutorialPrivacyChapterTests` ·
`TutorialStructureActsTests` · `TutorialTakesActsTests` · `TutorialWherePlacesActsTests` · `TutorialWritingActsTests`

Most of these are U1's Tier A/B already (one run of U1's list ∪ these on `vx383-u2` covers both units). The pins that read
U2's words: `TutorialMCPChapterTests:1048` (the description keeps "Needs read on the note and write new on its wing"),
`MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` (every kind × allowed × count for `duplicate_note` — the
book kind's new arm), `MCPAskAndReceiptTests` (the receipt line's budget fallback, now with the duplicate's book arm).
**Expected standing reds this set may meet (not U2's):** VX-167's order-dependent `DestructiveUndoWarningTests.
redoNeverAsks` is NOT in this set; U1's list carries VX-115's `BookCollectingDoorsTests` and VX-167. The pointer-injection
suites demand an idle machine (the frozen archive's row 85). **No phone suite:** no phone source and no shared source U2
changed (`MCPPaneCopy` is Mac-only; the core change reaches the phone's build but no phone door calls `filing:`).

### THE LIVE ROUND SCRIPT FOR U2 (the orchestrator's stage window — the dev-store Debug build `io.lduarte.Variorum.debug`; Claude Code connected through its own setup tab; captures into `notes/plans/vx383-screens/u2/live/`; Study first, then Terminal for L2 and L5's faces)

Names in « » are the ids the setup answers. Every expected answer below is the JSON field as built (the answer is
sorted-keys JSON); words in quotes are byte-exact.

- **L0 — set-up (Settings ▸ MCP's open book OFF — else every unfenced book reads and L4's unnamed book would be named; an
  EDIT grant on Home, "until it disconnects", via the grant sheet; then through the client):**
  `create_book {"name": "u2 drafts", "wing_id": ""}` → «B»; `create_section {"book_id": «B», "name": "second drafts"}`
  → «C»; `create_book {"name": "u2 living", "wing_id": ""}` → «L»; `set_book_rule {"book_id": «L», "rule": {"tag":
  "u2dup"}}` (no backfill seats — P-13nb-U4-16; new matches join quietly); `create_book {"name": "u2 finished",
  "wing_id": ""}` → «F»; `finish_book {"book_id": «F»}`; `create_note {"wing_id": "", "title": "u2 source", "blocks":
  [{"text": "The first paragraph."}, {"text": "The second paragraph.", "takes": [{"text": "The second, again.",
  "label": "again"}]}]}` → «S»; `apply_tag {"note_id": «S», "tag": "u2dup"}` → `changed: true`, and «L» takes «S» in
  (the applying act is heard). By her hand (⌘L ▸ new wing): a wing **"u2 elsewhere"** and in it a book **"u2 theirs"** →
  «E» (read its id with `list_books` under a write-new grant on that wing, granted in L5).
- **L1 — WITH TAGS, the wing road, a collecting book takes the copy in:** `duplicate_note {"note_id": «S»}` → no error;
  `landed` = `“u2 living”, which collects one of its tags`; `tag_ids` = [the u2dup id], `tags` = `["u2dup"]`; no
  `book_id`. App: the quiet receipt **"claude-code duplicated “u2 source” · ⌥⌘Z undoes"** with **Open ›** (opens the
  copy); Activity **"claude-code duplicated “u2 source”"**; «L»'s Index lists the copy at its end. Edit menu **"Undo
  claude-code's duplicate"** → ⌥⌘Z → the copy leaves «L» (in the Trash) → ⇧⌥⌘Z → back in «L» at the same place. Capture
  each.
- **L2 — INTO A CHAPTER (the book road):** `duplicate_note {"note_id": «S», "book_id": «B», "section_id": «C»}` →
  `book_id` «B», `section_id` «C», `landed` = `the end of “u2 drafts”, in its chapter “second drafts”, and “u2 living”,
  which collects one of its tags`, `tags` = `["u2dup"]`. App: receipt **"claude-code duplicated “u2 source” into “u2
  drafts” · ⌥⌘Z undoes"**, Open › opens the copy; Activity **"claude-code duplicated a note into “u2 drafts”"**; «B»'s
  Index shows the copy under "second drafts", and «L» took it too. ⌥⌘Z → both books without it; ⇧⌥⌘Z → filed again under
  "second drafts". **Both voices** (Study, then Terminal): the receipt line and the Activity row.
- **L3 — WITHOUT TAGS:** `duplicate_note {"note_id": «S», "with_tags": false}` → `tag_ids` `[]`, `tags` `[]`, `landed`
  `the Pool of Home`; the copy is in the Pool, wears no tag, «L» did not take it. `duplicate_note {"note_id": «S»,
  "with_tags": "no"}` → error **"with_tags must be true or false."**
- **L4 — A BOOK-ONLY SHARE (VX-371's point):** revoke the Home edit grant (the pane's Revoke); grant claude-code **read on
  the note "u2 source"** and **write new on the book "u2 drafts"** (the grant sheet, until it disconnects). `tools/list`
  (re-announced) **lists `duplicate_note`**. `duplicate_note {"note_id": «S», "book_id": «B»}` → lands: `landed` = `the
  end of “u2 drafts”, and a book not shared with you, which collects one of its tags` («L» is not this client's now),
  `book_id` «B». Then `duplicate_note {"note_id": «S»}` (no book) → error **"That wing isn't shared with this client, or
  doesn't exist. The author can share it from Variorum ▸ Settings ▸ MCP."** and her ASK for the wing **Home at write
  new** waits (the pending mark / the pane's Waiting) → answer **Don't allow**. Activity: **"claude-code was refused
  duplicating a note in “Home”"** (the wing side, as VX-311 logs it — Home's logged title is "Home", quoted by the line).
- **L5 — A BOOK OF ANOTHER WING:** grant write new on the wing "u2 elsewhere" (`list_books` there gives «E»).
  `duplicate_note {"note_id": «S», "book_id": «E»}` → error **"That book isn't shared with this client, or doesn't
  exist. The author can share it from Variorum ▸ Settings ▸ MCP."** — byte-identical to `duplicate_note {"note_id":
  «S», "book_id": "no-such-book"}`; **no ask appears**; nothing minted. Activity **"claude-code was refused duplicating a
  note into “u2 theirs”"** (both voices).
- **L6 — A FINISHED BOOK:** grant write new on "u2 finished" (or Home again). `duplicate_note {"note_id": «S», "book_id":
  «F»}` → error **"This book is finished — reopen it first; if it’s sealed, unseal it."** (her door's words through the
  chain); nothing minted, no undo entry.
- **L7 — the answer is the store:** for the L2 copy, `read_note {"note_id": «copy», "with_ids": true}` → its `blocks`
  equal L2's answer record for record; each `sha256` equals the source take's.
- **Posture after:** delete the round's notes and books (Trash), the "u2 elsewhere" wing (empty it first), the u2dup tag;
  revoke every grant the round made; restore the voice; leave the dev store as found (memory: walks restore dev-store
  posture). **Pass:** every expected line above, byte-exact where quoted; any deviation is a finding for the record.

### PROVISIONALS (U2's — to the QUESTIONS bundle at the merge, beside P-C-1…3 and U1's)

- **P-U2-1 — `landed`'s words:** (a) BUILT — filed: "the end of “B”" (+ ", in its chapter “C”") — `create_note`'s "it
  joins the book at its end"; not filed: the Pool words as before, UNLESS a book collecting one of the applied tags took
  the copy in; then every such book follows, NAMED where the client can read it and counted where it can't ("a book not
  shared with you" — `move_note_to_wing`'s `left_books` precedent: ids/counts yes, names only with a grant), ", which
  collects one of its tags"; an arrival is never said (no membership). (b) a structured `book_ids` beside a shorter
  `landed` (list_notes' shape); (c) never mention a book the client can't read (then `landed` would claim "the Pool" for
  a copy a hidden book holds — false, so not built).
- **P-U2-2 — Activity on the book road logs the row on the BOOK:** (a) BUILT — "claude-code duplicated a note into “B”"
  (×N "duplicated N notes into “B”"; refused "duplicating a note into “B”") — the row has ONE target, so the line names
  the book (the plan's "in words naming the book"), and `list_my_activity` shows `target_kind: book` + the `book_id` the
  client sent (P-VX261-4's "a creating act names where it was made"); the receipt says both ("duplicated “X” into
  “B”"). (b) log on the source note as the wing road does ("duplicated “X”" — the book unnamed); (c) a line naming both
  needs a second title on the local-only `mcp_activity` (a migration — not this unit's).
- **P-U2-3 — an ARCHIVED destination takes the copy:** (a) BUILT — AppSpec §9's 13i-e family ("EXPLICIT adds land — no
  `readingArchived` refusal exists") and `create_note`'s road agree; the brief's list named "archived" among the
  refusals, the plan's D-C-4 does not. (b) refuse an archived destination on the wire (a refusal no door of hers has).
- **P-U2-4 — a book of another wing is decided BEFORE the book's own decision, as no book:** (a) BUILT — the one
  not-shared shape, NO ask (no grant could make it the landing; an ask would pester her for nothing), byte-identical to an
  id naming nothing. (b) decide the book first and answer not-shared only after (a writable other-wing book would then
  raise an ask she could never usefully grant).
- **P-U2-5 — the receipt's long-line fallback keeps the book:** (a) BUILT — "claude-code duplicated a note into “B” ·
  ⌥⌘Z undoes" (the wing move's precedent) before "made a change"; (b) the generic fallback.

### FOR VX-234 (user-facing words, as built)

- The wire (the MCP room's register): `duplicate_note`'s description (quoted whole in `MCPToolCatalog.duplicateNote`);
  the `with_tags`/`book_id`/`section_id` schema lines; "with_tags must be true or false." (the read tools' sentence,
  reused); `section_id`'s parse sentence (`create_note`'s, reused: "…the book the note joins."); the `landed` words
  (P-U2-1).
- Her surfaces: Activity "duplicated a note into “B”" · "duplicated N notes into “B”" · "duplicating a note into “B”";
  the receipt "duplicated “X” into “B”" and its long form "duplicated a note into “B”".

### OWED (for the orchestrator)

- **The Mac batch** (above) and **the live round** (above), in a stage window.
- **The field guide's recipe 6** (the MCP chapter's "how to use it", `TutorialSeeder`) still says "The copy lands in that
  wing's Pool, in no book" — since U1 (D-C-1) a book collecting one of the note's tags may take the copy in, and since U2 a
  client can file the copy into a book it names. Outside this brief (lesson 3 names no reach, so the brief's condition
  for the guide was not met). Candidate words: "…The copy lands in that wing's Pool (or in a book you name), and your
  original never changes." — its pin `TutorialMCPChapterTests` (`revisionRecipe`, exact text) and the closeout's
  real-store re-seed would carry it. The orchestrator's ruling.
- **The public guide page** (https://stargazing.tech/variorum/mcp): a line for her site agent in the handoff —
  `duplicate_note` can now file its copy into a book (`book_id`, `section_id`) and choose its tags (`with_tags`).
- **MCPSpec's contract line** at the closeout: the `duplicate_note` clause (P-VX311-2's wing-only rung) grows the book
  road, `with_tags`, the new answer fields and the Activity/receipt words.
- `MCPSession.instructions` is UNCHANGED (its revision sentence names no reach) — stated, not owed.

### SELF-ASSESSMENT

- **Sound:** the book road reuses every existing seam rather than restating one — `create_note`'s book decision
  (`decide(book:)` at write new, its refusal and its ask), the hand-add's choke point (`addPostToReading`: capacity,
  wing, ownership, the outflow), `add_note_to_book`'s chapter sentence (`MCPWireRefusalCopy`), the one refusal chain
  for her doors' words, `mintedNoteTags` for P-VX361-1's listing, `registerMintedContainerEntry` for the one undo, and
  `guardWingMove`'s union spend. The filing threads through THE ONE BODY her doors share (D-311-1), so the wire can't
  drift from her Duplicate; her doors pass no filing and their rows are byte-unchanged (pinned). The ORDER is measured on
  both of its consequences (R1: `alreadyInReading` at a collecting destination; `noteMemberedElsewhere` at an owned
  one). The wing road is byte-for-byte (the same decision, words, ask and log line; VX-311's seven pins unchanged and
  green). No oracle: another wing's book reads as no book before any decision (R2 measured the leak it closes: the raw
  `crossWingMembership` and a pointless ask).
- **Weakest points, for the reviewer's eye:** (1) every Mac line is compiled but UNRUN (the faces pin's red and green
  are the batch's); (2) `landed`'s count of unreadable books ("a book not shared with you") tells a book-level client
  that SOME book it can't read collects one of the note's tags — the `left_books` precedent gives ids of unreadable
  books already, but the reviewer should weigh it against "anything you can't reach answers as if it did not exist"
  (P-U2-1 (c) is the alternative); (3) the book road's Activity row names the book, not the note (P-U2-2); (4) a
  race-time refusal inside the act (the guard's note side, after the snapshot allowed it) is logged on the book side —
  harmless for the client (its answer is the guard's refusal), a slightly mislabelled row in her pane; (5) the names in
  `landed` are decided on the SNAPSHOT standing (the one that authorized the act — `move_note_to_wing`'s rule), so a
  once grant spent by this very act still names its book; (6) the field guide's recipe 6 overclaims since U1 — flagged,
  not fixed (outside the brief).
- **Not touched:** `Sources/VariorumCore/Sync/`, custody, the Keychain, any migration or schema (`mcp_activity` unchanged
  — hence P-U2-2), the editor seam, U1's Mac doors (`NoteDuplicate`, the registry, the boards), `MCPSession.instructions`,
  the field guide. No trace led to any of them.
