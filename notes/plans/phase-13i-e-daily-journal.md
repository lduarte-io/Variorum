# Phase 13i-e — THE DAILY JOURNAL AS RULED · BOOK ARCHIVE · THE 13i FAMILY CLOSE

## KICKOFF MESSAGE (as she invoked it, 2026-10-03)

> /architect-phase 13i-e — the daily Journal per the sitting record §10 (the designation
> DERIVED from the `'daily'` marker; never-hard-delete with archive legal — "it returns when a
> day arrives"; lesson 9's withheld second sentence lands WITH the guard) + the 13i FAMILY
> CLOSE (the cohesive combined-walk list her posture owes; the family's loose ends swept).
> The binding design: the sitting record §10 + `notes/plans/pre-13u-memo-daily-journal-identity.md`
> §3 (the built marker's remaining letters), read through the a–d execution records. Standing
> cast; preflight per CLAUDE.md. SMALL by her own §15 sizing ("small now") — one to two units.

**STATUS: OPENED 2026-10-03 under `/architect-phase`; RE-SIZED at the kickoff sitting (below)
— her authorized §12 lockstep event (marker 11→12) joins the phase.**

## KICKOFF RECORD (2026-10-03)

Preflight read in this session, not delegated: CLAUDE.md + its auto-loaded canon, the master
plan (pointer + the 13i row + the active order), KnownIssues (row 32 closely + the 13i-owned
sweep), QUESTIONS (#89 whole, #170–#178), this plan as authored at the 13i-d closeout, the
resiliency protocol whole, the sitting record (§10 whole; §20, §25 closely), the daily-Journal
identity memo whole (§0 rulings + §§1–7 edges), the a–d execution records read through (13i-a's
§2/§3/§9/§10 + postscript; 13i-b's U4 record — the Quicknotes comes-back withholding; 13i-c's
daily touches P-13ic-U2-5/P-13ic-U4-1; 13i-d's walk-posture/closeout/U7 record/environment
traps + all four handoffs' combined-walk lists), SyncSpec §7's keeper + dedupe paragraphs and
the §12 running record (the 13i-a/13i-c window shapes this phase's window follows). TEXTKIT2
not required — no editor seam. Code facts verified by hand: `Queries.dailyJournalBookID` (the
setting road), `dailyJournalBookCandidates` (the marker road, smallest-id-first — the keeper's
own pick), `setDailyJournalBook` (moves the marker + writes the setting, 13i-a M-3),
`insertDailyJournalBook` (stamps `'daily'`, Home-only), `deleteReading`/`deleteReadingWithNotes`
(no daily guard — F-U7-2's letter), `reading` has NO archive column anywhere (model, migrations
v1_core…v1_20), the delete doors enumerated (Mac `BookStateDoors.swift:586`; phone
`MobileShelfViewModel.swift:191`, `MobileBookDetails.swift:153`; the two tutorial seeders),
`TutorialBooksChapterTests.lessonNineTheDailyJournal` (the F-U7-2 withholding pin),
`SyncSchema.lockstepVersion = 11` (the registry lives in `Sync/` — the rider routes that half
to the architect). No revert in flight.

### HER KICKOFF RULINGS (the question tool, this sitting — verbatim-faithful)

- **R-13ie-1 — the archived daily Journal lives UNDER ARCHIVED, and the machinery is GENERAL
  (a schema event authorized).** Asked where an archived daily Journal should live (the
  architect's zero-schema setting-flag build recommended), she OVERRULED the zero-schema shape,
  her words: *"it should be under archived - but we should probably make archive machinery for
  books and think through this a bit more. a book is a set of rules + ordering now so it makes
  sense to archive it - the only question is what happens to the notes within. I'm fine with
  another sync schema event to do this right."* So: `reading.archived_at` ON THE ROW (the
  container-archive class — kept-but-out-of-view); archived books list under the sidebar's
  Archived surface; ONE §12 lockstep event, marker 11→12, mirror deploy at HER window. The
  honest re-size was said to her in the same sitting (two implementer units + the event + the
  family close) and she proceeded.
- **R-13ie-2 — the notes within MIRROR DELETE (recommended option taken).** A PLAIN book
  archives alone — its notes stay live everywhere they already are. An OWNED book's door asks:
  archive the book only, or the book and its N notes together (ONE stamp; unarchive returns it
  whole — the restore-whole pattern). Lesson 8's ruled delete shape, mirrored.
- **R-13ie-3 — GATHERINGS ARCHIVE TOO, same door (recommended option taken).** A saved rule
  put away: an archived gathering leaves the Bookcase and STOPS ASSEMBLING (everywhere its
  assembly is consulted — the Pool tuck's "shown by some live gathering" excludes it) until
  unarchived. No notes question by construction.
- **R-13ie-4 — archived pauses AUTO-INGESTION ONLY; explicit adds stay OPEN (her amendment,
  same sitting, superseding the question's "pauses intake + adds" option she first took).** Her
  words, verbatim: *"I actually think that explicitly adding something to an archived book
  should still be allowed - every method of auto ingestion should pause, which should be clear
  to users (though what will happen to a gathering collecting tags? I think that's fine to
  pause too), but if you want to add something to an archived book I think that's fine."* So:
  INTAKE pauses (a living archived book never seats or bells quietly) and the pause is CLEAR
  TO USERS (a face obligation — the Collecting pane says so); an archived GATHERING's
  tag-collection pauses too (R-13ie-3's stops-assembling, hers confirmed); EXPLICIT adds (the
  hand doors — drags, the chip, Manage Notes, copy-in/move-in, judging a waiting arrival) land
  normally on an archived book, NO `readingArchived` refusal on the add doors. The EDIT LAW
  stands: text inside stays editable; the book stays openable from Archived. Unarchive RESUMES
  auto-ingestion with the catch-up (the unseal precedent — resume catch-up bells, never quiet
  seats). **Her second rider, same sitting, verbatim:** *"I do think making a note that the
  book is archived though would be fine - either in the selector it being clear that it is
  archived or a 'confirm add to archived book?' but archived isn't supposed to be too onerous -
  it's just supposed to not be in the library, but you do want to keep it forever."* So the
  add-door FACE says the state: the book selectors/pickers mark archived books "(archived)" —
  the lighter of her two roads, chosen for "not too onerous" (the confirm is the recorded
  alternative — PROVISIONAL, QUESTIONS #179) — and the FRAMING is keep-forever: archived means
  out of the library, never a step toward deletion.

**Standing §10 rulings this phase builds (the sitting record, 2026-09-30 — settled, not
re-litigated):** the designation DERIVED from the `'daily'` marker (the `daily_journal_book`
setting retires-as-read; `setDailyJournalBook` keeps moving the marker; the §7 keeper already
keys on it — zero `Sync/` repair change); never-hard-delete on the ⌘J ground, wording *"the
daily Journal can be archived, never deleted; it returns when a day arrives"*; lesson 9's
second sentence lands WITH the guard (F-U7-2's pin flips); memo letters (c) ratified as her
leans (⌘J stays; Today's Entry the mobile button), (f) faces follow.

## THE BINDING PRINCIPLES (the 13b constitution, copied per the architect-phase skill; its application notes bind alongside, by reference to the skill)

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

## SCOPE (re-sized at the kickoff; everything below is ruled)

1. **THE SCHEMA EVENT (R-13ie-1):** `reading.archived_at TEXT` (additive, nullable) — client
   migration `v1_21_reading_archive`, `SyncSchema.lockstepVersion` 11→12, the registry's
   reading-columns line, the serializer classification (PLAIN — a timestamp, the
   `container.archived_at` class), the mirror DDL artifact
   `Server/supabase/15_phase13ie_archive.sql` + the deploy checklist
   `notes/plans/13i-e-deploy-checklist.md`. NO new §7 repair: plain CAS metadata (two devices
   racing archive/unarchive converge by server-wins — the standing class). The `Sync/` half is
   THE ARCHITECT'S (the standing rider); the schema lands in its own commits BEFORE any code
   that uses it. The mirror deploy runs ONLY at her window, on her explicit go; her real-store
   install refresh is HELD until the mirror deploys (never strand her daily drive).
2. **BOOK ARCHIVE, the op family (R-13ie-2/3/4):** `archiveReading` (book or gathering; plain
   archives alone) · `archiveReadingWithNotes` (the OWNED door's second choice — member notes'
   `container.archived_at` on ONE stamp, versions untouched — archive is visibility, never
   lifecycle) · `unarchiveReading` (exact-stamp members return whole; resume CATCH-UP bells on
   a living book — the unseal precedent). Archived semantics: out of the Bookcase (shelves,
   All, №census, counts, palette's default listing), listed under ARCHIVED; AUTO-INGESTION
   PAUSED, visibly (the living predicate gains "not archived"; the Collecting pane says the
   pause out loud — R-13ie-4); EXPLICIT adds stay OPEN (the hand doors land normally, judging
   a waiting arrival included — her amendment; NO `readingArchived` refusal on any add door);
   a gathering's assembly answers EMPTY everywhere while archived (the Pool
   tuck re-classes its notes); pending arrivals KEEP WAITING (archive is reversible — the
   finish precedent's dismissal deliberately NOT mirrored; PROVISIONAL); text inside stays
   editable (the edit law); the book opens from Archived; delete stays open on archived
   non-daily books; Finished/Sealed/locked are orthogonal states.
3. **THE DAILY JOURNAL AS RULED (§10):** the DERIVATION — `Queries.dailyJournalBookID` flips
   from the setting read to `dailyJournalBookCandidates(db).first` (the keeper's own
   smallest-id pick; every reader follows through the one query); the `daily_journal_book`
   setting RETIRES-AS-READ (writers keep it fresh as a cache — the memo §3's blessed letter;
   `setDailyJournalBook` and the mint byte-unchanged; the §7 keeper untouched). The GUARD —
   `deleteReading` + `deleteReadingWithNotes` refuse the daily Journal
   (`dailyJournalCannotBeDeleted`, checked on the marker INSIDE the transaction); every door
   that offers Delete on a book offers ARCHIVE on the daily Journal instead (P-2); the refusal
   names the road ("archive it instead — it returns when a day arrives"). THE COMES-BACK —
   `shelveInDailyJournalBook`'s ensure UN-ARCHIVES an archived daily Journal before filing
   (same transaction; the derived read finds it archived-but-live); a dead daily book (an old
   build's delete) still mints fresh, today's behavior.
4. **LESSON 9's SECOND SENTENCE (F-U7-2 flips):** "You can archive it; you can't delete it;
   it comes back when a day arrives." lands in "the journal & the pool";
   `lessonNineTheDailyJournal` flips from withholding to asserting — presence AND behavior
   (archive → ⌘J → the SAME book back, live, with today's entry). The re-seed consequence
   rides her next Help ▸ Restore Tutorial press (the handoff carries it; never a session's act).
5. **THE 13i FAMILY CLOSE:** the COHESIVE COMBINED-WALK LIST (one self-contained document
   assembling a–e's lists — `notes/handoffs/13i-family-combined-walk.md`; the deliverable her
   posture owes); the loose ends swept (#170–#178 state restated in her bundle; #89(b)
   resolved to the ruling; KnownIssues row 32 resolved; the memo's letter (f) faces verified;
   the F-U6-2 flag restated); the standing closeout ritual whole.

## EDGES DECIDED ON PAPER (the P-5 enumeration; PROVISIONAL where marked — QUESTIONS #179 carries them)

- **Arrivals while archived:** kept waiting, dismissed by nothing (archive is reversible;
  finishing's sweep deliberately not mirrored) — PROVISIONAL.
- **Archive with arrivals pending:** the door archives without a confirm line (the waiters
  keep; unarchive's catch-up may add more) — PROVISIONAL.
- **A note archived INDIVIDUALLY before its owned book's archive-with-notes:** stamp differs,
  so the book's unarchive leaves it archived (the exact-stamp letter, `restoreContainer`'s).
- **`duplicateReading` of an archived book:** legal; the duplicate born UNARCHIVED
  (configuration, never state — P-13ic-7's letter) — PROVISIONAL.
- **Finish/Seal/lock on an archived book:** orthogonal, all legal from the open book
  (no unarchive-first gate) — PROVISIONAL.
- **Delete of an archived NON-daily book:** open as today (archive is not protection).
- **`restoreReading` of a book deleted WHILE archived:** returns archived
  (kept-but-out-of-view is row state; the Trash road never launders it).
- **The keeper repair meets an archived daily book:** candidates filter is live-rows-only
  (`deleted_at IS NULL`) — an archived daily Journal keeps its identity and converges exactly
  as a visible one (zero `Sync/` change; pinned headless).
- **The Book Panel / membership chips / "appears in" lines naming an archived book:** named,
  muted "(archived)" — PROVISIONAL (the honest read: membership is a fact; visibility is the
  book's own state).
- **The ⌘K palette / search catalog:** archived books leave the default book listings exactly
  as archived notes leave the Library's (match the shipped archived-note treatment) —
  PROVISIONAL.
- **The add selectors mark, never interrupt:** archived books appear in the add
  pickers marked "(archived)" and the add lands on a plain click — her second rider's lighter
  road ("not too onerous"); the "confirm add to archived book?" shape is the recorded
  alternative — PROVISIONAL.
- **Keep-forever framing:** archive is never a step toward deletion — no expiry, no Trash
  interplay, the Archived surface's copy says "kept" never "pending" (her words: "you do want
  to keep it forever").
- **Wing moves:** an archived book rides `moveWingContents` ARCHIVED (13i-d R-13id-6's
  "archived ride archived" said of notes extends to the book's own flag); the daily Journal
  still refuses both doors (13i-d, #169(b)).
- **Old-client clobber risk is the marker's job:** a marker-11 client would push reading rows
  without `archived_at` (CAS whole-row) — exactly why `lockstepVersion` moves to 12 and both
  her installs refresh at the window (the §12 grammar; her phone at her convenience, visibly
  refusing until then).

## ACCEPTANCE UNITS (evidence named before the first spawn; ONE unit per implementer session)

- **U0 (the architect, under the rider) — THE SCHEMA EVENT:** v1_21 + the registry/marker/
  classification (`Sync/`) + the mirror artifact + the deploy checklist, in schema-first
  commits. Evidence: `MigrationTests` schema pins (fresh ≡ migrated), the serializer
  completeness walk green, core suite green at the baseline, the fake server (registry-derived)
  at marker 12. Cold-reviewed by the ladder like all architect code.
- **U1 (`opus-implementer`) — THE OP FAMILY + THE DAILY RULINGS, headless:** scope items 2+3.
  Evidence: exact state-transition pins per op; RED-ON-OLD pins at the traced mechanisms (the
  delete guard — old tree tombstones; the derivation — marker/setting disagreement answers the
  marker, dangling-setting-plus-live-marker no longer double-mints; the ensure's un-archive —
  old tree leaves it archived); the intake/assembly pause pins (a living archived book neither
  seats nor bells; an archived gathering assembles empty; the Pool tuck re-classes; an EXPLICIT
  add LANDS on an archived book — R-13ie-4's amendment pinned); the
  keeper-meets-archived pin; counts exact at the unit's end.
- **U2 (`opus-implementer`) — THE FACES + LESSON 9:** the Archived surface gains its BOOKS
  group (open + Unarchive + the owned two-choice archive confirm's twin receipt), the Bookcase/
  Book Settings/context doors (Archive beside Delete; the daily Journal's Delete REPLACED by
  Archive, P-2), the capability-registry declarations + refusal copy (`OpsRefusalTable` words;
  the Mac's roads), the VISIBLE auto-ingestion pause (R-13ie-4: the Collecting pane's sentence
  while archived — "Collecting is paused while this book is archived", 13s-revoicable), the
  muted membership faces, lesson 9's sentence + the flipped pin.
  Evidence: the registry walk green; the eleven-suite tutorial spine green INCLUDING the
  flipped `lessonNineTheDailyJournal`; Mac suite batches exact; a scripted walk's captures.
- **U3 (the orchestrator) — LADDER · WALK · THE FAMILY CLOSE:** ONE `fable-reviewer` ladder
  over the combined diff (schema + identity semantics ⇒ Fable, the standing rule); the
  orchestrator's hands-on walk (dev store: archive a plain book → Archived shows it → open it
  → unarchive; the owned two-choice; the gathering's empty assembly; archive the Journal →
  Bookcase hides it → ⌘J → it returns filed); the combined-walk document; the closeout ritual;
  HER WINDOW (mirror deploy on her go → the Mac install refresh → her phone at her
  convenience).

## ENVIRONMENT TRAPS (binding; carried from 13i-d per the skill — every brief carries this section verbatim)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH; real-store
instances are treated by STORE, never quit/killed; no Release builds or `/Applications` refreshes
while one lives (THIS phase HAS a deploy — marker 11→12: the mirror deploys at HER window first,
and the real-store install refresh is HELD until it lands, never stranding her daily drive; the
dev store never syncs, so building/testing at marker 12 is safe throughout). `xcodebuild
build-for-testing` compiles without the runner; Mac tests from `App/Variorum/` with suite-level
`-only-testing` only, confirming the "Test run with N tests" line (skips counted — read the
`skipped:` lines); zsh `pipestatus`; NEVER a custom build configuration (non-"Debug" names strip
the DEBUG oracles); suites beside a live session flash test windows — prefer zero-instance
windows; backups WAL-safe, UTC names, into `Backups/safety-copies/` (the A1 rail) before ANY
real-store touch; never `git checkout` over uncommitted work; push after every commit; never
force-push. The dev store (`io.lduarte.Variorum.debug`) NEVER syncs (fenced) — sync evidence is
the fake-server suites, never the production mirror. Foreground waits only; poll logs with
`grep -q … && break` loops (the `tail -f` trap). Background-wait = death for subagents. Known
full-run flake rows (KnownIssues: the latency pin, `CanvasDragTrackingTests`, the
pointer-injection class, the per-note-defaults family): adjudicate by isolation + attribution
before treating any red as this phase's. Walk drives (cliclick/WalkKit) are DEV-STORE Debug
only, author-free, own `caffeinate -d`. Build folders under `App/Variorum/DerivedData/13ie-*`;
the closeout tidies them.

## LEDGER (every row owned; statuses flip in the same commit as the work)

| # | item | status |
|---|---|---|
| 0 | U0 — the schema event (architect; schema-first commits) | NOT-STARTED |
| 1 | U1 — the op family + the daily rulings (headless) | NOT-STARTED |
| 2 | U2 — the faces + lesson 9 | NOT-STARTED |
| 3 | The ladder (ONE, `fable-reviewer`, combined diff) | NOT-STARTED |
| 4 | The orchestrator's walk | NOT-STARTED |
| 5 | HER WINDOW: mirror deploy (her go) → Mac install refresh → the phone at her convenience | HELD FOR HER |
| 6 | The family close: the combined-walk document + the loose-end sweep | NOT-STARTED |
| 7 | Closeout: the standing ritual + canon deltas + KnownIssues row 32 + #89(b) + QUESTIONS #179 + MobileSoul + the handoff + the DerivedData tidy | NOT-STARTED |

## U1 BRIEF — THE OP FAMILY + THE DAILY RULINGS (`opus-implementer`; read this WHOLE file first)

Preflight (yours, never delegated): this file WHOLE; CLAUDE.md + its auto-loaded canon; the
sitting record §10 + §20 + §25 lesson 9; `notes/plans/pre-13u-memo-daily-journal-identity.md`
WHOLE (§0's rulings; §§3–5's edges); `notes/SessionResiliencyProtocol.md`; the 13i-c plan's §3
op-family record (the door-consult and restore-whole patterns you mirror); KnownIssues row 32.
You do NOT touch `Sources/VariorumCore/Sync/` (the registry/marker/classification landed at U0
— any further `Sync/` need is a STOP: report, don't improvise), `Server/`, `Persistence/`
migrations (U0's), or the editor seam. SyncSpec/TEXTKIT2 reads not required at this fence.

Build (scope items 2+3, the EDGES section binding):
1. `archiveReading(id)` / `unarchiveReading(id)` / `archiveReadingWithNotes(id)` on the
   `deleteReading`/`deleteReadingWithNotes`/`restoreReading` patterns (ONE stamp; exact-stamp
   return; member notes' `container.archived_at` only — never tombstones, never versions).
   Typed refusals; no structural-undo entries (the Trash-class recovery rule: the door is the
   recovery). Unarchive on a LIVING book runs the resume catch-up (the un-finish/unseal road —
   bells, never quiet seats).
2. The archived semantics: the living-book intake predicate gains NOT-archived (AUTO-ingestion
   alone pauses — R-13ie-4's amendment: the EXPLICIT add doors land normally on an archived
   book, `addPostToReading`/`seatArrival`/copy-in/move-in untouched, NO `readingArchived`
   refusal anywhere); a gathering's assembly answers empty while
   archived (every consumer — `assembleReading`'s gathering arm, the Pool tuck's
   shown-by-some-live-gathering, `readingsContaining`, the membership chip's gathering list);
   the Bookcase/shelf/census/count queries exclude archived readings.
3. The daily rulings: the derivation (`Queries.dailyJournalBookID` → `dailyJournalBookCandidates
   .first`; the setting untouched as a written cache; `designatedBookID` keeps its quicknotes
   consumer); the guard (`dailyJournalCannotBeDeleted` inside BOTH delete ops' transactions,
   keyed on `Queries.isDailyJournalMintShape`); the ensure's un-archive-before-filing
   (`shelveInDailyJournalBook` — same transaction, routed through `unarchiveReading`'s body).
4. Pins per the U1 evidence list above — red-on-old VERIFIED BY REVERT at each named mechanism;
   state-transition exactness the 13i-c suites' way; the keeper-meets-archived pin headless
   against the fake server.

Checkpoint protocol binds from the first commit (commit per piece, push every commit, LIVE
STATUS in this file flipped per commit, PENDING until verified, foreground waits only, no
subagents). Tests at the END of the unit; counts exact. Record your UNIT RECORD in this file
(the 13i-d records' shape: LIVE STATUS · WHAT WAS BUILT · EVIDENCE · FINDINGS · PROVISIONALS).
Carry the ENVIRONMENT TRAPS section above verbatim as binding.

## U2 BRIEF — THE FACES + LESSON 9 (`opus-implementer`; read this WHOLE file first)

Preflight (yours): this file WHOLE (the U1 RECORD closely); CLAUDE.md + canon; the sitting
record §7 (the Bookcase contract) + §25 lesson 9; the resiliency protocol; the 13i-d plan's U3
RECORD (the Book Settings state-doors shape you extend) and U7 RECORD (the books chapter + the
F-U7-2 pin you flip). Fences as U1's: no `Sync/`, no `Server/`, no migrations, no editor seam.

Build:
1. The ARCHIVED surface's BOOKS group (books above notes; open · Unarchive; honest counts);
   the archive doors everywhere Delete lives on a book/gathering (row context menu, Book
   Settings' state doors), the OWNED book's two-choice archive confirm (the delete confirm's
   twin — "archive the book only / the book and its N notes", the copies listed), receipts on
   the message seam's kinds.
2. The daily Journal's doors: Delete REPLACED by Archive on every surface (P-2 — the registry
   declares the capability unavailable; no door renders a delete that only refuses); the
   op-level refusal's words in `OpsRefusalTable` + the Mac's roads ("The daily Journal can't
   be deleted — archive it instead; it comes back when a day arrives." — 13s re-voices).
3. The capability-registry declarations + the registry walk green; the muted "(archived)"
   membership faces (the Book Panel, chips, "appears in N gatherings"); the VISIBLE
   auto-ingestion pause (R-13ie-4's amendment: the Collecting pane carries a sentence while the
   book is archived — "Collecting is paused while this book is archived." — the explicit add
   doors stay rendered and working; 13s re-voices); the add-door face per her second rider —
   every book SELECTOR/PICKER an add road offers (the membership chip's list, Manage Notes,
   the drop/move/copy targets) marks archived books "(archived)", no confirm interruption
   (the lighter road; the confirm is the recorded alternative, PROVISIONAL #179).
4. Lesson 9's second sentence into "the journal & the pool" + flip
   `lessonNineTheDailyJournal` (presence AND the archive→⌘J→same-book-back behavior); the
   eleven-suite tutorial spine green.
5. A scripted walk (dev store, Debug, captures gitignored under `notes/plans/13ie-screens/`).

Same checkpoint protocol, record shape, fences and traps as U1.

## LIVE STATUS (the resiliency protocol's record — updated per commit; unverified claims PENDING)

- 2026-10-03 · kickoff: preflight complete (the KICKOFF RECORD above); her four rulings
  R-13ie-1…4 recorded verbatim-faithful the same sitting; the re-size said and accepted; this
  plan rewritten as the first act. Her LIVE AMENDMENT to R-13ie-4 (explicit adds stay open;
  auto-ingestion alone pauses, visibly; the gathering pause confirmed) recorded the same turn,
  the scope/briefs/evidence reworked to it. No revert in flight. U0 opens next (the
  architect's schema-first commits).
