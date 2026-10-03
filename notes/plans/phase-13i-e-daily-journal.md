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
| 0 | U0 — the schema event (architect; schema-first commits) | **DONE** (b2e8b1c2 — v1_21 + model + registry/marker 12 + DDL-pin list + the mirror artifact + the deploy checklist; full core suite green 2127/234, the 13i-d baseline exactly) |
| 1 | U1 — the op family + the daily rulings (headless) | **DONE** (`d12eecc6` piece 1 · `b6e4f52e` piece 2 · `a8199c9b` the confirm-N fragment; R1–R4 red by revert, restored clean; core FULL 2168/242 green, Mac 384/50 + 97/13, phone 69/15 — the U1 RECORD below) |
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

## U1 RECORD — THE OP FAMILY + THE DAILY RULINGS (`opus-implementer`, 2026-10-03)

**NOT DONE BY THIS UNIT (first line, per the contract):** no FACES (Mac or phone — U2's: the
Archived surface's books group, the archive doors, the daily Journal's Delete→Archive swap, the
`OpsRefusalTable` words, the "(archived)" marks, the Collecting pane's pause sentence, lesson 9);
no walk (a headless unit — the evidence is state-transition pins, red-on-old reverts and the
fake-server convergence pin; the USE gate for this unit's semantics is U2's walk + U3's
orchestrator walk); zero `Sync/`, `Server/`, migrations, editor seam. QUESTIONS is NOT written
here — this phase routes its PROVISIONALs to #179 at the closeout (ledger row 7; the 13i-*
precedent); each P-13ie-U1-n below is written QUESTIONS-ready.

### LIVE STATUS (per commit; every unverified claim PENDING)

- 2026-10-03 · **START** — preflight read in this session, not delegated: this file WHOLE; CLAUDE.md
  + its auto-loaded canon; the sitting record §10, §20, §25 (lesson 9); the daily-Journal identity
  memo WHOLE; the resiliency protocol WHOLE; the 13i-c plan's §3 (+ §5/§6, the seal/delete/restore
  patterns mirrored); KnownIssues row 32. Code read by hand: `Operations+Reading.swift` whole,
  `Operations+Seal.swift`, `Operations+Intake.swift`, `Domain/IntakeDecision.swift`,
  `Operations+Container.swift` (the shelving door + `insertDailyJournalBook`),
  `Operations+Appearance.swift` (`setDailyJournalBook`), `Queries/AppearanceQueries.swift` (the
  designation, the marker, the candidates, the star union), `Queries/ReadingAssembly.swift` whole,
  `Queries/ShelfQueries.swift` whole, `Operations+BlockArchive.swift` (the archive precedent), the
  v1_18 marker migration step, the app/mobile consumers of every query touched. THE DESIGN below
  settled before the first line of code. **No revert in flight.**
- 2026-10-03 · **PIECE 1 DONE (`d12eecc6`):** the archive op
  family (`Operations+ReadingArchive.swift`), the three `OperationError` cases, the pause in the
  one table (`IntakeDecision.BookFacts.archived` + `intakeRuns`; `livingBooks`' SQL), the
  gathering's empty assembly + the four outside-the-assembly readers, the Bookcase choke point,
  `archivedReadings`, the catalog's book arm, the E13 name guard. Pins: `BookArchiveTests.swift`
  (4 suites / 23 tests) GREEN in a filtered run. `DailyJournalRulingsTests.swift` committed AHEAD of
  its production change and RUN ON THE PRE-FIX TREE (the natural red — EVIDENCE below). NEXT: piece
  2 (the derivation, the guard, the comes-back), then the existing pins whose premise the guard
  retires, then the revert cycle, then the full suite. No revert in flight.
- 2026-10-03 · **PIECE 2 DONE (`b6e4f52e`):** THE DERIVATION
  (`Queries.dailyJournalBookID` → `dailyJournalBookCandidates(db).first`), THE GUARD (both delete
  ops read the row inside their write and refuse `dailyJournalCannotBeDeleted` on the marker —
  `deleteReading` rewritten from the `updateLiveReading` closure to an explicit write),
  `addPostToReading`'s body extracted to a db-level twin (the public door unchanged in behaviour),
  THE COMES-BACK (`shelveInDailyJournalBook`'s one write: the `unarchiveReading` body, then the
  filing under `db.inSavepoint`). Three EXISTING pins whose premise the guard retires were
  re-premised — never weakened (each still asserts its own clause; each now reaches a dead daily
  Journal by the row write an older build's delete / another device's tombstone is):
  `ThemeAndShelfQueryTests.dailyJournalBookDanglesToNil` (also now asserts the door refuses),
  `JournalKeeperRepairTests.aDanglingDesignationAdoptsTheArrivingJournal`, and the PHONE's
  `MobileStarterJournalTests.aDeletedStarterJournalNeverComesBack` (the starter IS the daily
  Journal). Filtered run: the four daily suites + the keeper suite + the touched suites 66/15
  GREEN. NEXT: the red-on-old REVERT cycle (R1–R3), then the full core suite, the Mac/mobile
  compile + the affected batches. No revert in flight.
- 2026-10-03 · **REVERTS STARTING (announced before the first edit; the tree is committed at piece
  2, so `git checkout -- <file>` is the SAFE restore and `git diff` shows exactly what is reverted
  at any moment):** R1 — the two `refuseDeletingTheDailyJournal` calls removed in
  `Operations+Reading.swift`; R2 — `Queries.dailyJournalBookID` back to the setting read in
  `AppearanceQueries.swift`; R3 — the `unarchiveReading` call removed from
  `shelveInDailyJournalBook` in `Operations+Container.swift`. ONE at a time; each restored by
  checkout and verified clean (`git diff --quiet`) before the next. A successor finding a dirty
  diff in any of those three files is mid-revert: `git checkout -- <file>` restores it.
- 2026-10-03 · **R1–R3 DONE, each RED at its named mechanism and RESTORED CLEAN** (`git diff
  --quiet` after each checkout; the tree equals the piece-2 commit) — the evidence lines are in
  EVIDENCE below. **R4 ANNOUNCED (an extra, beyond the brief's three — proving the PAUSE pins are
  not hollow):** `IntakeDecision.intakeRuns`' `&& !book.archived` AND `livingBooks`'
  `archived_at IS NULL` both removed (`Domain/IntakeDecision.swift`,
  `Operations/Operations+Intake.swift`); restored by checkout, verified clean.
- 2026-10-03 · **R4 DONE (red, restored clean). END RUNS DONE:** core FULL 2167/242 GREEN; Mac
  `build-for-testing` TEST BUILD SUCCEEDED + two named batches GREEN (384/50, 97/13); the phone's
  affected suites GREEN (69/15, 2 pre-existing known issues) after TWO phone-test fixes the core
  change forced (the starter-journal pin's `import GRDB`; `MobileBooksTests.designateDailyIsTheRoad
  OutOfTheTodayRefusals` re-premised from a gathering-as-daily — no longer a designation under the
  book-only derivation — to a FINISHED daily book; F-U1-3). The ops-seam `dailyJournalBookID()`
  doc corrected. NEXT: the record's finals (WHAT WAS BUILT · EVIDENCE · FINDINGS · PROVISIONALS),
  the ledger row, the hand-off. No revert in flight.
- 2026-10-03 · **UNIT CLOSED.** `a8199c9b` added the archive-with-notes set's ONE fragment +
  `Queries.archiveWithNotesCount` (U2's confirm N; pinned); the record's finals written
  (`9324dfb3`); the FINAL core FULL run on that committed tree: **2168 tests / 242 suites GREEN**
  (1 standing skip) = the baseline + exactly this unit's 41/8. Ledger row 1 → DONE. Every claim
  above is verified; nothing PENDING; no revert in flight; nothing uncommitted. NEXT (the
  orchestrator's): U2's spawn (the faces + lesson 9) — the U1 calls it makes are listed under WHAT
  WAS BUILT; the ladder reads FINDINGS F-U1-1…10.

### THE DESIGN (settled before building; PROVISIONAL where marked — QUESTIONS-ready for #179)

**The op family (`Operations+ReadingArchive.swift`, new — scope item 2):**
- **`archiveReading(id)`** — a book OR a gathering (R-13ie-3), the daily Journal included (archive
  is its road): `archived_at = updated_at = now`, ONE row write, nothing else moves (a plain book
  archives ALONE — R-13ie-2; pending arrivals KEEP WAITING — the edge; no note touched).
- **`archiveReadingWithNotes(id) -> [String]`** — ONE clock read: every live MEMBER note of the
  book (live member row, live post) that is NOT already archived gets `container.archived_at =
  updated_at = now`, then the book's `archived_at = now`. Returns the archived notes in book order.
  Never a tombstone; never a saved VERSION (born archived by the classifier — re-stamping one would
  break `archived_at == created_at`; the "not already archived" fence leaves them untouched by
  construction); arrivals' notes never (an arrival is not membership); sealed members DO archive
  (AppSpec §9's seal letter: "the post itself may still be archived").
- **`unarchiveReading(id) -> [String]`** — the book's live MEMBER notes whose `archived_at` EQUALS
  the book's stamp come back (archived_at cleared) FIRST, then the book's flag clears, then the
  RESUME CATCH-UP (`intakeSweep(.catchUp)` — bells, never quiet seats; runs only when the book's
  intake runs: a live BOOK, readable rule, not finished; a gathering simply assembles again at
  read). Returns the notes it brought back, in book order.
- **P-13ie-U1-1 — double archive / unarchive REFUSE:** `readingAlreadyArchived(id:)` /
  `readingNotArchived(id:)` (two new `OperationError` cases) — the 13j block-archive precedent
  (`blockAlreadyArchived` / `blockNotArchived`) and the `readingNotDeleted`/`readingNotSealed`
  class ("a recovery door that silently succeeded would teach that Put back did something"); a
  re-stamp would also orphan the exact-stamp key of an earlier archive-with-notes. *Alternative:
  the identity-setter no-op guard.*
- **P-13ie-U1-2 — `archiveReadingWithNotes` mirrors `deleteReadingWithNotes` AT THE OP:** refuses
  a gathering (`wrongReadingKind`) and nothing else; the DOOR offers it only on an OWNED book (U2) —
  R-13ie-2's "Lesson 8's ruled delete shape, mirrored", read to the letter of the 13i-c plan §6
  ("the op itself refuses a gathering and nothing else"). *Alternative: the op also refuses a plain
  book (a belt against hiding notes that live in other books).*
- **P-13ie-U1-3 — the exact-stamp corners:** a note archived individually BEFORE the book carries
  its own stamp and stays archived after the unarchive (the edge, `restoreContainer`'s letter); a
  note that LEFT the book while it was archived (removed, moved in elsewhere, a wing move's
  severance) is no longer a member and stays archived ("rows whose story diverged stay as they
  are"); a note unarchived by hand meanwhile is simply live already.
- **P-13ie-U1-4 — no undo, and the redo future untouched:** the family registers nothing (the door
  is the recovery — the Trash-class rule the brief names) and, unlike `deleteReadingWithNotes`,
  does not clear the redo future (`archiveContainer`'s class: archive removes no content, so no
  stack entry is stranded).
- **Orthogonality (no code — pinned):** Finish/Seal/lock/own on an archived book are legal (no
  unarchive-first gate — the edge); `restoreReading` of a book deleted while archived returns
  ARCHIVED (row state; the flip never touches `archived_at`) with its catch-up paused;
  `duplicateReading` of an archived book is born UNARCHIVED (the `Reading` init's nil — P-13ic-7's
  configuration-never-state letter); a wing move rides archived (an in-place row update).

**The archived semantics (scope item 2, R-13ie-4 with her amendment):**
- **P-13ie-U1-5 — THE PAUSE lives in the ONE table:** `IntakeDecision.BookFacts.archived` and
  `intakeRuns` gains `!archived` — so EVERY auto-ingestion road pauses by construction: the tagging
  and starring EVENTS, creation BACKFILL, every CATCH-UP (restore, un-finish, unseal, a rule edit);
  `livingBooks`' SQL gains `archived_at IS NULL` (the cheap pre-filter, the same truth). A rule set
  or edited on an archived book fires nothing; the unarchive's catch-up covers the gap (bells — the
  finished-book precedent). The bind of an ARCHIVED gathering binds its assembly, which is empty
  while archived — no new refusal; the unarchive's catch-up bells its matches.
- **P-13ie-U1-6 — EXPLICIT adds untouched** (her amendment — NO `readingArchived` refusal anywhere):
  `addPostToReading`, `seatArrival`, `copyPostIntoReading`, `movePostIntoReading`,
  `newPostInReading`, `assertReadingAcceptsPosts`, `divergePostForReading`, the gathering's collect
  door — zero lines changed. The book's OUTFLOW (auto-tag) still rides an explicit add on an
  archived book: it is the explicit act's own tagging (P-13ib-1), not ingestion INTO the book.
  *Alternative: an archived book's outflow pauses too.*
- **The gathering answers EMPTY everywhere its rule is consulted:** `assembleReading`'s gathering
  arm returns `[]` while archived (every reader THROUGH the assembly follows by construction — the
  book surfaces, export, `bindOwnedNotesPreview`, the Bookcase aggregates' gathering counts); the
  four readers that run a gathering's rule OUTSIDE the assembly skip an archived gathering: the
  Pool's tuck (`notePoolListingSQL` — its notes re-class loose), the chip's gathering leg
  (`readingsContaining`), the Library card's feed (`smartBookMembership`), `bookWordCounts`.
- **P-13ie-U1-7 — the Bookcase listing excludes archived** at the ONE choke point
  `bookcaseReadings` (both arms — the Mac's wing-scoped read AND the phone's all-wings read), so
  `bookshelf`, `bookcase` (the snapshot the № census, strip counts and solos derive from in
  `BookcaseBoard`) and `bookcaseAggregates` follow; `bookWordCounts` drops archived readings in all
  three arms. `Queries.readings` (the choosers/pickers, the seeders' existence reads) KEEPS
  archived — her second rider marks them "(archived)" in the pickers (U2), and a seeder must never
  re-mint a seeded book she archived. NEW `Queries.archivedReadings(wingID:limit:)` — the Archived
  surface's BOOKS feed for U2 (`archived_at DESC, id DESC`, the `archivedPosts` order).
- **P-13ie-U1-8 — membership is a FACT:** an archived book's member rows still count as membership
  wherever membership is read — the Pool's home test (a note whose only book is archived is NOT
  bookless), `membershipElsewhere` (an archived OWNED book still owns), `readingsContaining`'s book
  leg (U2 mutes it "(archived)"), `ownershipFacts`, `isBookless`, the sealed-book unlock guard (the
  edge's "the honest read: membership is a fact; visibility is the book's own state"). *Alternative:
  an archived book's notes count as bookless and return to the Pool.*
- **P-13ie-U1-9 — the ⌘K/search catalog's book arm excludes archived books** (the edge — "match the
  shipped archived-note treatment": the note arm has always excluded archived notes).
- **P-13ie-U1-10 — Starred:** an archived starred book STAYS in the sidebar's Starred section
  (`Queries.starred` unchanged) — the shipped archived-note treatment (an archived starred note
  stays starred and listed: `starredListItems` filters `deleted_at` only); the star is her
  deliberate quick-access, archive is the library's visibility. *Alternative: Starred hides it.*
- **P-13ie-U1-11 — the E13 name guard skips archived books:** `assertBookNameIsFree` reads
  `archived_at IS NULL` too — her ruling's own words, *"archived/deleted books don't count"*
  (13e E13; QUESTIONS' 13e batch 1 entry (a) noted "books have no archive" — now they do). The wing
  moves' name-collision PREVIEWS are deliberately unchanged (a stricter warning is the safe side).

**The daily rulings (scope item 3, the sitting record §10):**
- **THE DERIVATION:** `Queries.dailyJournalBookID` = `dailyJournalBookCandidates(db).first` (the
  keeper's own smallest-id pick over LIVE marker-bearers — an ARCHIVED Journal is live, so it is
  found). The `daily_journal_book` setting stays WRITTEN as a cache (`setDailyJournalBook`,
  `insertDailyJournalBook` byte-unchanged); `designatedBookID` keeps its quicknotes consumer; the
  §7 keeper (`Sync/Repairs.swift`) untouched.
- **THE GUARD:** `deleteReading` and `deleteReadingWithNotes` read the row INSIDE their write
  transaction and refuse `dailyJournalCannotBeDeleted(id:)` (new) when
  `Queries.isDailyJournalMintShape(row)` — ANY marker-bearer (two mid-convergence both refuse; the
  keeper's apply-mode tombstone is not an op and is unaffected). Checked FIRST after liveness.
- **P-13ie-U1-12 — THE COMES-BACK:** `shelveInDailyJournalBook`'s filing runs in ONE write: when the
  derived book is archived, the `unarchiveReading` body runs first (its exact-stamp members
  return, its catch-up runs), then the FILING runs inside a SAVEPOINT (`addPostToReading`'s body,
  extracted to a db-level twin — the public door byte-identical). A refused filing (finished, full,
  owned-elsewhere → the bell, another wing) rolls back the filing ONLY: the Journal still comes back
  — "it returns when a day arrives" (the day arrived), and a bell must ring at a door she can see. A
  DECIDED pair (already filed, or removed by hand) brings nothing back — no day arrived, an old
  entry was re-reached. A DEAD daily book still mints fresh (today's behaviour). *Alternative: the
  Journal returns only when the filing lands (all-or-nothing).*

**The pins (scope item 4 — named before building):** a new suite file
`Tests/VariorumCoreTests/BookArchiveTests.swift` (the op family's exact transitions + the archived
semantics per consumer) and `Tests/VariorumCoreTests/DailyJournalRulingsTests.swift` (the guard,
the derivation, the comes-back), plus the keeper-meets-archived convergence pins headless against
the fake server (test-side only; zero `Sync/` source). RED-ON-OLD by behavioural revert at three
mechanisms: (R1) the guard — revert the two guard lines, the old tree tombstones the daily book;
(R2) the derivation — revert `dailyJournalBookID` to the setting read: a marker/setting
disagreement answers the setting, and a dangling setting beside a live marker-bearer double-mints
on ⌘J; (R3) the comes-back — revert the shelving's unarchive: the book stays archived after the
filing.

### WHAT WAS BUILT (a fresh session's map)

**Production (core only — zero `Sync/`, `Server/`, migrations, editor seam):**
- `Operations/Operations+ReadingArchive.swift` (NEW) — `archiveReading(id)`,
  `archiveReadingWithNotes(id) -> [String]`, `unarchiveReading(id) -> [String]` and its db-level
  body `unarchiveReading(_ db:id:now:)` (shared with the shelving door's comes-back);
  `Queries.archiveWithNotesSource` (the ONE set) + `Queries.archiveWithNotesCount(readingID:)`
  (the owned two-choice confirm's N — U2's).
- `Operations/OperationError.swift` — `readingAlreadyArchived(id:)`, `readingNotArchived(id:)`,
  `dailyJournalCannotBeDeleted(id:)` (the app's `OpsRefusalTable` has a `default:` — no app
  compile change; the WORDS are U2's).
- `Domain/IntakeDecision.swift` — `BookFacts.archived` (defaulted `false`) and `intakeRuns`'
  `&& !book.archived`. `Operations/Operations+Intake.swift` — `livingBooks` filters
  `archived_at IS NULL`; `intakeBookFacts` passes the flag.
- `Queries/ReadingAssembly.swift` — the GATHERING arm of `assembleReading` returns `[]` while
  archived (books keep assembling); `Queries.archivedReadings(wingID:limit:)` (NEW — the
  Archived surface's books feed, `archived_at DESC, id DESC`); `Queries.readings` documented as
  INCLUDING archived (pickers, seeders).
- `Queries/ShelfQueries.swift` — `bookcaseReadings` (BOTH arms) excludes archived → `bookshelf`,
  `bookcase`, `bookcaseAggregates` (and the app's `BookcaseBoard` census/solos/strip counts, which
  read only the snapshot's books); `bookWordCounts` drops archived readings (all three arms);
  `notePoolListingSQL`, `readingsContaining`'s gathering leg and `smartBookMembership` skip an
  archived gathering; `searchCatalog`'s book arm excludes archived books.
- `Operations/Operations+Reading.swift` — `deleteReading` rewritten from the `updateLiveReading`
  closure to an explicit write carrying THE GUARD; `deleteReadingWithNotes` carries it after the
  kind check; `refuseDeletingTheDailyJournal` (private, keyed on `isDailyJournalMintShape`);
  `addPostToReading`'s body extracted to `addPostToReading(_ db:_:to:at:)` (internal — the public
  door calls it in its own write; behaviour identical, the full suite is the proof);
  `assertBookNameIsFree` skips archived books.
- `Queries/AppearanceQueries.swift` — `dailyJournalBookID` = `dailyJournalBookCandidates(db).first`
  (THE DERIVATION); `designatedBookID` now serves Quicknotes alone.
- `Operations/Operations+Container.swift` — `shelveInDailyJournalBook`: after the (unchanged)
  plan/decided read, ONE write — the `unarchiveReading` body when the derived book is archived,
  then `addPostToReading(db…)` under `db.inSavepoint`; an `OperationError` from the savepoint is
  returned out of the write (so the un-archive commits) and rethrown into the SHIPPED outcome
  mapping (`.bookFinished` / `.bookAtCapacity` / `.wrongKind` / the bell / `.refused`).
- `Operations/Operations+Appearance.swift` — doc only (the ops-seam `dailyJournalBookID()`).

**Tests:** NEW `Tests/VariorumCoreTests/BookArchiveTests.swift` — `BookArchiveOperationTests`
(8), `ArchivedIntakeTests` (7), `ArchivedGatheringReadersTests` (2), `ArchivedListingTests` (7);
NEW `Tests/VariorumCoreTests/DailyJournalRulingsTests.swift` — `DailyJournalDeleteGuardTests`
(4), `DailyJournalDerivationTests` (5), `DailyJournalComesBackTests` (6),
`ArchivedJournalKeeperTests` (2, the fake server). RE-PREMISED (the guard/derivation retired their
premise; each keeps its own clause): `ThemeAndShelfQueryTests.dailyJournalBookDanglesToNil`,
`JournalKeeperRepairTests.aDanglingDesignationAdoptsTheArrivingJournal` (file
`FurnitureConvergenceRepairTests.swift`), the phone's
`MobileStarterJournalTests.aDeletedStarterJournalNeverComesBack` (+ `import GRDB`) and
`MobileBooksTests.designateDailyIsTheRoadOutOfTheTodayRefusals` (F-U1-3).

**For U2 — the calls the faces make:** Archive = `archiveReading`; the OWNED book's second choice
= `archiveReadingWithNotes` (its confirm's N = `Queries.archiveWithNotesCount`); Unarchive =
`unarchiveReading` (returns the notes that came back — the "came back whole" receipt's count); the
Archived surface's books group = `Queries.archivedReadings(wingID:)`; the daily Journal's Delete →
Archive (the op refuses `dailyJournalCannotBeDeleted` — the words are U2's); "(archived)" marks
read `reading.archivedAt` (the pickers' `Queries.readings` keeps archived books; the chip's book
leg names them); the Collecting pane's pause sentence reads `reading.archivedAt` on a living book.

### EVIDENCE (counts exact, run at the END)

- **Core FULL `swift test` (the FINAL run, after the last production change `a8199c9b`, on the
  committed tree `9324dfb3`): "✔ Test run with 2168 tests in 242 suites passed after 101.873
  seconds"** — 1 skipped (the standing env-gated real-server integration pass,
  `basicOfflineEditsConvergeOverTheRealServer`). Baseline 2127/234 → **+41 / +8, exactly this
  unit's** (`BookArchiveTests` 24 in 4 suites, `DailyJournalRulingsTests` 17 in 4 suites). *(The first END run, on the
  piece-2 production code before `archiveWithNotesCount` existed: "✔ Test run with 2167 tests in
  242 suites passed after 101.711 seconds", 1 skipped — the standing env-gated real-server
  integration pass; +40 / +8 = exactly this unit's suites at that point.)*
- **Mac** (zero app instances — `pgrep` empty; build `App/Variorum/DerivedData/13ie-u1`):
  `build-for-testing` **TEST BUILD SUCCEEDED**; named suites via `test-without-building`, 0
  skipped: **batch B "✔ Test run with 384 tests in 50 suites passed"** (every suite in a test file
  that reads a changed query or door — `BookcaseBoardBrainTests`, `BookcaseViewModelTests`,
  `JournalBooksTests`, `BookStructureModelTests`, `BookDropTests`, `MembershipChoiceTests`,
  `BookCollectingDoorsTests`, `ShelfModelTests`, `PromoteAndPaletteTests`, `PoolTuckFaceTests`,
  `NoteCardSmartBooksTests`, `LibrarySortMenuTests`, `LibraryDayFilterTests`,
  `DuplicateBookNameDoorTests`, `BookDeleteAndDuplicateTests`, `TrashBookNotesTests`,
  `TrashSurfaceTests`, `WingSwitcherTests`, `WingBookMoveDoorTests`, `SampleLibraryWelcomeTests`,
  `QuickNote*`, …) + **batch A "✔ Test run with 97 tests in 13 suites passed"** (every
  `Tutorial*` suite — the spine, `TutorialBooksLessonTests`' withholding lesson-9 pin still green:
  U1 adds no sentence). These ran on the piece-2 production code; the one later production change
  (`archiveWithNotesCount` + the act reading the shared fragment) is core-internal and no app code
  calls it yet.
- **Phone** (iPhone 17 Pro simulator, build `DerivedData/13ie-u1-ios`): **"Test run with 69 tests
  in 15 suites passed … with 2 known issues"** — the known issues are the pre-existing
  `withKnownIssue` in `MobileTutorialWalkTests.theFannedDivideLessonLandsTheDuplicateShape`
  (eeba2e7c, untouched). Suites: `MobileStarterJournalTests`, `MobileShelfTodayDoorTests`, the
  `MobileBooksTests` file's five, `MobileShellTests`, the tutorial-walk file's seven.

- **PRE-FIX RUN (piece 1's tree — the archive family present, the daily rulings NOT yet built;
  `swift test --filter` over the four daily suites, 17 tests / 4 suites):** RED at every named
  mechanism — (R1) `deleteReadingRefusesTheDailyJournal` ("an error was expected but none was
  thrown"; the Journal's `deleted_at` set; its membership dead) and
  `deleteReadingWithNotesRefusesTheDailyJournalAndTouchesNoEntry` (none thrown, `["…0000"]`
  returned — the entry sent to the Trash with it), `theGuardKeysOnTheMarker`; (R2)
  `theMarkerAnswersWhenTheCachedSettingDisagrees` (the read answered the trait notebook; ⌘J filed
  into it), `aDanglingSettingBesideALiveMarkerBearerNoLongerDoubleMints` (**the double-mint:
  `next.bookID` = …0004 beside the live marker-bearer …0001**; two live daily-shaped books),
  `aMissingSettingBesideALiveMarkerBearerFilesThere`, `theCachedSettingAloneNoLongerDesignates`,
  `theCacheIsStillWrittenAndTheReadIsTheKeepersPick`; (R3)
  `aDayArrivingBringsAnArchivedJournalBackAndFilesIntoIt` (`archived_at` still set after the
  filing; not on the Bookcase), `theComesBackReturnsTheEntriesArchivedWithTheJournal`,
  `aRefusedFilingStillBringsTheJournalBack`, `anOwnershipBellRingsAtAJournalThatCameBack`. GREEN on
  both sides by design (behaviour-preservation and edge pins, never red-on-old claims):
  `archiveIsTheDailyJournalsRoad`, `aDecidedPairBringsNothingBack`,
  `aDeadDailyJournalStillMintsFresh`, and the two keeper-meets-archived convergence pins (the
  edge's own claim is that NO `Sync/` change is needed — green on both sides is its evidence).
  One fixture defect found and fixed on the way (the raw setting write used `ON CONFLICT`, which
  fires the outbox trigger twice — now the repo's UPDATE-then-INSERT shape).
- **THE BEHAVIOURAL REVERTS (on the committed piece-2 tree; the brief's R1–R3 — each run is the
  named suite filtered; each restored by `git checkout --` and verified `git diff --quiet`):**
  - **R1 — the GUARD** (both `refuseDeletingTheDailyJournal` calls commented out): RED —
    `deleteReadingRefusesTheDailyJournal` ("an error was expected but none was thrown"; the
    Journal's `deleted_at` set; the membership dead; outbox written),
    `deleteReadingWithNotesRefusesTheDailyJournalAndTouchesNoEntry` (none thrown, the entry's
    `deleted_at` set — the Journal and its entry in the Trash), `theGuardKeysOnTheMarker`, and the
    re-premised `ThemeAndShelfQueryTests.dailyJournalBookDanglesToNil` ("an error was expected").
    31 tests / 5 suites, 11 issues. Restored clean.
  - **R2 — the DERIVATION** (`dailyJournalBookID` back to `designatedBookID(db, key:
    "daily_journal_book")`): RED — all five derivation pins; the decisive line,
    `aDanglingSettingBesideALiveMarkerBearerNoLongerDoubleMints`: **`next.bookID` …0004 ≠ the live
    marker-bearer …0001, two live books** (⌘J double-minted); `theMarkerAnswersWhenTheCachedSetting
    Disagrees`: the read answered the trait notebook and ⌘J filed into it (…0003). 5 tests / 1
    suite, 13 issues. Restored clean.
  - **R3 — the COMES-BACK** (the `unarchiveReading` call in the shelving's write removed): RED —
    `aDayArrivingBringsAnArchivedJournalBackAndFilesIntoIt` (`archived_at` still set after the
    filing; off the Bookcase; no outbox row for the reading — **the old tree's letter: the column
    exists, nothing clears it**), `theComesBackReturnsTheEntriesArchivedWithTheJournal`,
    `aRefusedFilingStillBringsTheJournalBack`, `anOwnershipBellRingsAtAJournalThatCameBack`;
    `aDecidedPairBringsNothingBack` and `aDeadDailyJournalStillMintsFresh` green (controls). 6 tests
    / 1 suite, 7 issues. Restored clean.
  - **R4 — the PAUSE** (an extra beyond the brief: `intakeRuns`' `&& !book.archived` and
    `livingBooks`' `archived_at IS NULL` both removed): RED — `theOneTablePausesAnArchivedBook`
    (`intakeRuns(archived)` true; the verdicts `.arrival`/`.seat` where `.nothing` was asserted),
    `aLivingArchivedBookNeitherSeatsNorBellsOnTaggingOrStarring` (both archived books took rows),
    `unarchivingALivingBookCatchesUpThroughArrivalsNeverQuietSeats` (the gap SEATED as a member
    while archived — `[.member]` where `[.arrival]`), `aRuleSetOnAnArchivedBookFiresNothingUntilThe
    Unarchive`, `reopeningOrRestoringAnArchivedBookStaysPaused`; the two explicit-add/outflow pins
    green (controls — not pause claims). 7 tests / 1 suite, 11 issues. Restored clean.
  - **No revert in flight** — every reverted file restored by checkout and verified `git diff
    --quiet`; the tree equals the piece-2 commit's production code.

### FINDINGS (for the orchestrator; none is a STOP — no fence was needed)

- **F-U1-1 — the derivation's one exposure (a store-shape question for HER window):** a store whose
  cached `daily_journal_book` names a LIVE book wearing NO marker now reads "no daily Journal",
  and the next ⌘J mints a fresh one (the old book keeps its entries as an ordinary book). Reachable
  only where v1_18's step 8 skipped the stamp — it marked the designee only when its profile was
  `'journal'`, so a pre-13i-a "Use as Daily Journal" on a non-journal book is the one road. Pinned
  as documented behaviour (`theCachedSettingAloneNoLongerDesignates`). **Exposure check, read-only,
  at her window (never a session's act on her store):** `SELECT r.profile FROM setting s JOIN
  reading r ON r.id = s.value WHERE s.key = 'daily_journal_book' AND r.deleted_at IS NULL` — `daily`
  ⇒ not exposed. Remedies if exposed: (a) she re-designates by hand ("Use as Daily Journal" moves
  the marker); (b) a one-time ensure (the memo §5 edge 1's "the ensure's own write": no live
  marker-bearer + a live designee ⇒ stamp it) — NOT built, the brief keeps the setting
  retired-as-read; (c) accept.
- **F-U1-2 — `setDailyJournalBook` still accepts a GATHERING** and stamps `'daily'` on it — a
  marker the identity (`kind = 'book'`) ignores, so the designation silently does nothing and ⌘J
  mints the real Journal. No face offers it (the Mac's "Use as Daily Journal" and the phone's
  details door render on books only); the op's letter permits it, and a PRE-RECAST store whose
  designated SMART book wore profile `'journal'` got the stamp from v1_18. Proposal: the op refuses
  `wrongReadingKind` (one line — not done: the brief keeps `setDailyJournalBook` byte-unchanged).
  The phone's `.wrongKind` Today wording is now unreachable (harmless dead copy).
- **F-U1-3 — two PHONE pins re-premised (the ladder should confirm each keeps its intent):**
  `MobileStarterJournalTests.aDeletedStarterJournalNeverComesBack` reaches the deleted starter by
  the row write an older build's delete is (the starter IS the daily Journal — the door refuses
  now); `MobileBooksTests.designateDailyIsTheRoadOutOfTheTodayRefusals` used a GATHERING as the
  refusing daily book — under the derivation that is no designation at all (F-U1-2), so the
  refusal half now uses a FINISHED daily book (`.bookFinished`, "finished", still never "Mac"); the
  designate-heals half is untouched. Two core pins re-premised the same way (listed in WHAT WAS
  BUILT).
- **F-U1-4 — the PHONE's shelf drops archived books too** (`bookshelf(nil)` is the Bookcase's
  all-wings arm, so the ruling binds it), but the phone has NO Archived surface and no unarchive
  door: an archived book is out of view on the phone until unarchived on the Mac (the catalog
  excludes it as well; its notes stay in the phone's Library). The closeout's MobileSoul line
  should carry it for the mobile catch-up.
- **F-U1-5 — the starter Journal and the comes-back:** her Mobile Round 2 starter ruling ("if they
  delete that journal book or archive it, it just doesn't appear at all") is about the SEEDER and
  still holds (an archived starter is a live reading, so the store is never "new" again). The
  starter IS the daily Journal, so §10's comes-back returns an archived one on the next Today's
  Entry — the later ruling governing exactly the daily Journal; lesson 9's sentence says so.
  Surfaced so nobody reads it as a seeder regression.
- **F-U1-6 — the comes-back is silent:** `DailyBookShelving` is unchanged (a new case would break
  the phone's exhaustive `shelvingNote` switch and every pin comparing outcomes). A face wanting a
  receipt ("Your Journal is back on the Bookcase") reads archived-before/after itself — U2's call
  (PROVISIONAL P-13ie-U1-13).
- **F-U1-7 — interim, same phase:** until U2 lands its words and the Delete→Archive swap (P-2),
  the Mac's and the phone's Delete doors on the daily Journal speak their tables' DEFAULT refusal
  words for `dailyJournalCannotBeDeleted`. Nothing is lost — the act refuses.
- **F-U1-8 — `wingContents` deliberately COUNTS archived books** (a wing holding only archived
  books is not empty; Delete Wing refuses and names them — kept-forever framing). U2's copy may
  want "(N archived)" there.
- **F-U1-9 — proposed canon deltas for the closeout (contract lines only; not written here):**
  AppSpec §9 — the archive family (archive / archive-with-notes / unarchive with the exact-stamp
  return and the resume catch-up; the pause in `intakeRuns`; explicit adds open), the daily
  Journal's derivation, delete guard and comes-back; §12 — the Archived surface's books (U2's).
- **F-U1-10 — machinery:** zsh does not word-split an unquoted `$ARGS`, so a first Mac batch ran
  0 tests ("Executed 0 tests", 14 s) — caught by its missing "Test run with" line; the batches ran
  from bash scripts with absolute paths (`App/Variorum/DerivedData/13ie-u1-batch{A,B}.sh`,
  `13ie-u1-ios.sh`; build folders `DerivedData/13ie-u1`, `13ie-u1-ios` for the closeout's tidy).
  No session death; no revert left in flight.

### PROVISIONALS (QUESTIONS-ready for #179; each one line to overturn)

P-13ie-U1-1 double archive/unarchive refuse (the block-archive precedent) · U1-2 archive-with-notes
refuses a gathering only at the op; the door offers it on owned books · U1-3 the exact-stamp
corners (individually archived stays; a note that left the book stays) · U1-4 no undo, the redo
future untouched · U1-5 the pause lives in the one table (every intake road; a rule edit while
archived fires nothing; the bind of an archived gathering binds its empty assembly) · U1-6
explicit adds untouched, the OUTFLOW still rides an explicit add · U1-7 the Bookcase excludes
archived on both arms; the pickers keep them; `archivedReadings` newest-first · U1-8 membership is
a fact (an archived book still homes its notes — not in the Pool; an archived owned book still
owns) · U1-9 the catalog drops archived books · U1-10 an archived starred book stays in Starred ·
U1-11 the E13 guard skips archived names (her own words) · U1-12 the comes-back: un-archive first,
the filing savepointed — a refused filing still brings the Journal back; a decided pair brings
nothing back · **U1-13 (new at the end)** the comes-back speaks no receipt of its own (F-U1-6). The
plan's EDGES (arrivals keep waiting; archive without a confirm line for waiters; duplicate born
unarchived; Finish/Seal/lock orthogonal; restore returns archived; wing moves ride archived) are
BUILT as written and pinned.

## THE ARCHITECT'S ADJUDICATION AFTER U1 (2026-10-03 — verified by spot-check per the recovery protocol: ten commits present and pushed through `430b6dcb`, the `Sync/`/`Server/`/migrations diff EMPTY, the tree clean, the record and ledger in place, and the unit's 41/8 re-run GREEN on the tip by the orchestrator's own hand)

- **F-U1-1 (the marker-less designee exposure) — ADOPTED into the deploy checklist:** the
  read-only exposure check runs at HER window AGAINST THE MIRROR via the `!` road
  (`reading.profile` is PLAIN there; a session never queries her real store) — `daily` ⇒ not
  exposed; exposed ⇒ she re-designates by hand ("Use as Daily Journal" moves the marker; one
  press). The one-time-ensure remedy stays NOT built (the brief's letter). Her store's shape
  makes exposure near-nil (her Journal was the ⌘J-minted `'journal'`-profile book v1_18's step
  stamped; her 13i-a round was clean) — the check is the belt.
- **F-U1-2 (`setDailyJournalBook` accepts a gathering) — RULED, BUILD IT at U2 as ACT 0:** the
  op refuses `wrongReadingKind` on a non-book. The trace is worse than silent-nothing: the
  marker-move would demote every live `'daily'` book to the trait and stamp a GATHERING the
  candidates (kind='book') ignore — the next ⌘J then mints a fresh Journal while the gathering
  wears a marker `setJournalTrait` refuses to clear. One line + a red-on-old pin at that
  mechanism (the brief's "keep the op unchanged" letter is the architect's to amend, and is
  amended here).
- **F-U1-3 (the four re-premised pins) — to the LADDER's eye** (the record flags each; the
  reviewer confirms intent survived; zero framing beyond the repo).
- **F-U1-4 (the phone's shelf drops archived; no phone Archived surface/unarchive door) —
  ADOPTED for the closeout's MobileSoul line** (the mobile catch-up's face set gains it).
- **F-U1-5 (the starter interplay) / F-U1-7 (the interim default refusal words) / F-U1-10
  (machinery) — record-only, no action owed.**
- **F-U1-6 (the silent comes-back) — RULED for U2:** the ⌘J road SPEAKS a quiet RECEIPT when it
  brought the Journal back ("The Journal is back on the Bookcase." — receipt-kind on the message
  seam, so `receipt_style` governs; 13s re-voices). Read archived-before/after at the door
  (P-13ie-U1-13's shape) — `DailyBookShelving` stays unchanged, exactly as the record proposes.
- **F-U1-8 (`wingContents` counts archived) — SUSTAINED as built;** U2 MAY add "(N archived)"
  to the Delete Wing refusal's naming where it already lists contents (copy-only, implementer's
  judgment; 13s re-voices either way).
- **F-U1-9 (canon deltas) — adopted for the closeout's list.**
- **The PROVISIONALs P-13ie-U1-1…13 — ALL SUSTAINED as built** (each lands in QUESTIONS #179 at
  the closeout). P-13ie-U1-12's refused-filing-still-returns reading is upheld as R-13ie-4's own
  letter ("a day arrived"); P-13ie-U1-13 is superseded by the F-U1-6 ruling above (the receipt
  is now ruled, not open).
- **U2 RIDERS (beyond its standing brief):** ACT 0 — F-U1-2's refusal + pin; the comes-back
  receipt (F-U1-6's ruling); the optional wing-contents copy (F-U1-8).

## U2 BRIEF — THE FACES + LESSON 9 (`opus-implementer`; read this WHOLE file first)

Preflight (yours): this file WHOLE (the U1 RECORD + THE ARCHITECT'S ADJUDICATION AFTER U1
closely — its U2 RIDERS bind); CLAUDE.md + canon; the sitting
record §7 (the Bookcase contract) + §25 lesson 9; the resiliency protocol; the 13i-d plan's U3
RECORD (the Book Settings state-doors shape you extend) and U7 RECORD (the books chapter + the
F-U7-2 pin you flip). Fences as U1's: no `Sync/`, no `Server/`, no migrations, no editor seam.

Build:
0. **ACT 0 (the adjudication's F-U1-2 ruling):** `setDailyJournalBook` refuses a non-book
   (`wrongReadingKind`) — one line in `Operations+Appearance.swift`'s db-level writer, with a
   red-on-old pin at the traced mechanism (on the old tree the designation demotes every live
   `'daily'` book to the trait and stamps the gathering; ⌘J then mints a fresh Journal beside
   it). This is the ONE core-op line in your unit; everything else is faces/queries-reads.
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
5. **The comes-back RECEIPT (the adjudication's F-U1-6 ruling):** the ⌘J/Today's Entry road
   speaks a quiet receipt-kind line when the filing brought an archived Journal back ("The
   Journal is back on the Bookcase." — `receipt_style` governs; 13s re-voices). Read
   archived-before/after at the door; `DailyBookShelving` unchanged. Optional (F-U1-8, your
   judgment): "(N archived)" in the Delete Wing refusal's contents naming.
6. A scripted walk (dev store, Debug, captures gitignored under `notes/plans/13ie-screens/`).

Same checkpoint protocol, record shape, fences and traps as U1.

## U2 RECORD — THE FACES + LESSON 9 (`opus-implementer`, 2026-10-03)

**NOT DONE BY THIS UNIT (first line, per the contract):** PENDING — written at the close.

### LIVE STATUS (per commit; every unverified claim PENDING)

- 2026-10-03 · **START** — preflight read in this session, not delegated: this file WHOLE (the
  kickoff rulings R-13ie-1…4 with both riders, the EDGES, the U1 RECORD, the adjudication after U1
  and its U2 RIDERS, the U2 brief, the ENVIRONMENT TRAPS); CLAUDE.md + its auto-loaded canon; the
  sitting record §7, §10 and §25 (lesson 9); `notes/SessionResiliencyProtocol.md` whole; the 13i-d
  plan's U3 RECORD (the Book Settings state doors) and U7 RECORD (the books chapter, F-U7-2's pin).
  Code read by hand: `setDailyJournalBook` (both levels), `BookStateDoors.swift` whole,
  `BookSettingsSheet.swift` whole, `ShelfView`'s book menu + `BookcaseRowMeta`, `ArchivedView`
  whole + `RecoveryViewModel.startArchived`, the registry's book-scope declarations and
  `CapabilityID`'s book acts, `MembershipChip`, `BookPanelView`'s header/gatherings line,
  `NotePicker.curatedBooks`, `JournalBooks.openToday` + its three callers, `OpsRefusalTable`,
  `DeletionRefusal`, `WingWords`/`wingContents`, the phone's two delete doors, lesson 9's prose and
  `lessonNineTheDailyJournal`. THE DESIGN below settled before the first line of code. **No revert in
  flight.** NEXT: ACT 0 (pin first, red on the old tree, then the line).
- 2026-10-03 · **ACT 0 DONE** — the pin committed AHEAD of its fix (`DailyJournalDesignationKindTests`,
  2 tests) and RUN ON THE PRE-FIX TREE: **RED, 7 issues** at the traced mechanism (no throw; the
  Journal demoted; the gathering wearing `'daily'`; the derived read nil; outbox written; **⌘J filed
  into a freshly minted …0006 beside the original …0001 — two books**); the control green
  (`scratchpad/13ie-u2/act0-red.log`). The guard line landed in `setDailyJournalBook(_ db:)`; GREEN
  with every daily/archive/keeper/wing neighbour: **105 tests / 22 suites**
  (`act0-green.log`). **REVERT ANNOUNCED (starts after this commit; the tree is committed, so
  `git checkout -- Sources/VariorumCore/Operations/Operations+Appearance.swift` is the SAFE
  restore):** RV0 — the one guard line removed; the pin re-run; restored and verified `git diff
  --quiet`.

### THE DESIGN (settled before building; PROVISIONAL where marked — QUESTIONS-ready for #179)

- **ACT 0 (the adjudication's F-U1-2 ruling):** `setDailyJournalBook`'s db-level writer gains ONE
  guard ahead of the marker move — the row's `kind` read and a non-book refused
  `wrongReadingKind(expected: .book)` — so neither the public door nor any future db-level caller
  can demote the live daily book and stamp a gathering. Pin first: on the old tree the designation
  of a gathering lands (the live daily Journal demoted to the trait, the gathering wearing
  `'daily'`, the setting naming it) and the next ⌘J (`shelveInDailyJournalBook`) MINTS a fresh
  Journal beside it — two books where one stood.
- **The registry (P-1):** two new acts — `.archiveBook` (verb "Archive", doors `.contextMenu` the
  Bookcase row + `.surface` the Book Settings sheet's State section) and `.unarchiveBook` (verb
  "Unarchive", `.surface` — the Archived surface's book rows + the sheet). Both `always` for
  `.editRule`'s reason (each renderer carries its book). **WHICH of Archive · Unarchive · Delete a
  book renders is DATA** — a new pure table `BookArchiveDoorSet.rendered(for:)` over
  `BookArchiveFacts` (archived · the daily marker): archived ⇒ Unarchive, else Archive; **Delete
  never on a marker-bearer** (`Queries.isDailyJournalMintShape` — the SAME predicate the op's guard
  keys on, so a face can never offer a delete the op refuses: P-2). Every renderer reads the table.
- **The archive door's behaviour (the delete door's twin, lighter — her "not too onerous"):** a
  PLAIN book, a GATHERING and the daily Journal archive AT ONCE with a receipt naming the road back
  (no confirm — archive is reversible and kept-forever; P-13ie-U2-1); an OWNED book ASKS — two
  choices when it holds notes ("Archive Book Only" / "Archive Book and Its N Notes", N =
  `Queries.archiveWithNotesCount`, the copy saying the book-only notes STAY in the Library, still
  its own — membership is a fact, P-13ie-U1-8), one button when it holds none (the delete
  confirm's own N = 0 shape). The owned door reads "Archive…" (it asks); the others "Archive".
  Unarchive acts at once; its receipt says what came back (the op's returned notes) and, on a
  living book, how many now wait at Arrivals (the pending count read before/after — the catch-up
  bells, never seats). Receipts on the status seam's RECEIPT kind (quiet by default); refusals
  REFUSE. The acts live in `BookStateDoors` (the state doors' one brain — open/confirm/perform),
  the words in `BookStateCopy`.
- **The ARCHIVED surface's BOOKS group (R-13ie-1):** `ArchivedView` gains a BOOKS section ABOVE the
  notes (section labels drawn only when an archived book exists — an archive with no books reads
  exactly as before), fed by a held observation of `Queries.archivedReadings(wingID:)` (the
  current wing; a NEW core observation wrapper `observeArchivedReadings` — `reading` only, so
  autosave never wakes it) and a one-shot per-list member count (`liveMemberNoteCount`, the
  13i-d archived-counts precedent: reading `container` stays out of the held region). Each row: the
  name, the honest facts ("book · N notes · owned/finished/sealed · daily Journal", or "gathering
  · shows nothing while archived"), the archived stamp; doors **Open** (navigation, the book view)
  · **Unarchive** · **Delete Book…** (the shared delete road with its three confirms; NOT drawn on
  the daily Journal — the table). The name filter narrows books too. Subtitle: "notes and books you
  set aside — kept, with no countdown" (keep-forever framing — PROVISIONAL P-13ie-U2-2).
- **The Book Settings sheet:** the STATE section gains an **Archived** row (caption + Archive /
  Unarchive from the table); a gathering's sheet now draws the State section for it (archive is a
  gathering's state too — R-13ie-3). The daily Journal's caption is §10's sentence verbatim ("The
  daily Journal can be archived, never deleted; it returns when a day arrives."). **THE VISIBLE
  PAUSE (R-13ie-4):** while archived, the Collecting section leads with "Collecting is paused while
  this book is archived." on a book whose rule reads (a living rule — a rule-less book has no
  auto-ingestion to pause, so the sentence would be noise) and "Collecting is paused while this
  gathering is archived — it shows nothing until you unarchive it." on a gathering (P-13ie-U2-3);
  the explicit add doors are untouched. The probe records both (pins).
- **"(archived)" — her second rider's lighter road, and the muted membership faces:** ONE shared
  word in a hoisted copy enum (`Shared/BookArchiveCopy.swift`, so the phone's catch-up speaks the
  same mark) — `name(_:)` → "Name (archived)". Selectors: the membership chip's "Add to Book" menu
  (books and gatherings), the Pool's Add-to-Book picker (its annotation slot: "archived", beside
  "finished"). Membership faces: the chip's book rows, the Book Panel's switcher rows and its state
  line ("archived"), the context bar's ascent menu. "Appears in N gatherings" needs no mark by
  construction — U1's `readingsContaining` drops an archived gathering (it shows nothing). Manage
  Notes… is reachable only from a Bookcase row, which never shows an archived book (P-2 by
  construction — recorded, nothing drawn). The book view's navigator chip says "archived" too
  (orientation for a book opened from Archived — P-13ie-U2-4).
- **The daily Journal's doors (P-2):** Delete is REPLACED by Archive on every surface — the Mac's
  Bookcase row (the table) and the Archived row (the table); **the phone's two doors** (the shelf
  row's long-press and Book Details' delete row) show Archive on the daily Journal instead of
  Delete (scope item 3's letter — "every door that offers Delete on a book offers ARCHIVE on the
  daily Journal instead"; its road back on the phone is Today's Entry itself). The phone's archive
  face for ORDINARY books stays the mobile catch-up's (F-U1-4's MobileSoul line; P-13ie-U2-5).
- **The words:** `OpsRefusalTable` (shared) gains `dailyJournalCannotBeDeleted` ("The daily Journal
  can't be deleted — archive it instead; it comes back when a day arrives."),
  `readingAlreadyArchived` ("That book is already archived — nothing changed."),
  `readingNotArchived` ("That book isn't archived any more — nothing changed."); the shared
  `DeletionRefusal` (the phone's delete road) gains the first. All 13s-revoicable.
- **The comes-back RECEIPT (F-U1-6's ruling):** `JournalBooks.openToday` reads the derived daily
  book's archived state BEFORE and AFTER the shelving inside its runner turn and, when the filing
  brought it back, `Outcome.receipt` = "The Journal is back on the Bookcase." (the ruling's words);
  both Mac roads (⌘J / the palette's `ShellActions.todaysEntry`, and the Bookcase's Today's Entry
  through `LibraryViewModel.openJournalEntry`) speak it as a RECEIPT. `DailyBookShelving`
  unchanged. The phone's Today door is the mobile catch-up's (recorded).
- **F-U1-8's optional copy (taken):** `Queries.WingContents` gains `archivedBooks` /
  `archivedGatherings` (defaulted 0 — a small core QUERY addition, recorded) and
  `WingWords.contents` says "2 books (1 archived)" so a wing that refuses deletion for books she
  cannot see on the Bookcase says where they are.
- **Lesson 9 (P-6):** the second sentence lands in "the journal & the pool" verbatim — "You can
  archive it; you can't delete it; it comes back when a day arrives." — and
  `lessonNineTheDailyJournal` FLIPS: presence asserted, and the behaviour executed headless (archive
  the Journal → it leaves the Bookcase → `shelveInDailyJournalBook` → the SAME book back, live,
  unarchived, entry filed; the delete door refuses it with the table's words; the Bookcase row's
  table offers no Delete). Red-on-old is the natural red of the pre-sentence tree.

## LIVE STATUS (the resiliency protocol's record — updated per commit; unverified claims PENDING)

- 2026-10-03 · kickoff: preflight complete (the KICKOFF RECORD above); her four rulings
  R-13ie-1…4 recorded verbatim-faithful the same sitting; the re-size said and accepted; this
  plan rewritten as the first act. Her LIVE AMENDMENT to R-13ie-4 (explicit adds stay open;
  auto-ingestion alone pauses, visibly; the gathering pause confirmed) recorded the same turn,
  the scope/briefs/evidence reworked to it. Her SECOND rider (the add-door face: selectors mark
  "(archived)", no confirm — the lighter road; keep-forever framing) recorded the same turn
  (d523d6d8). No revert in flight.
- 2026-10-03 · **U0 DONE (b2e8b1c2):** the schema event whole — `v1_21_reading_archive`
  (`reading.archived_at TEXT`, additive), `Reading.archivedAt`, the registry's reading column
  (PLAIN) + `lockstepVersion = 12` + its version doc line (the `Sync/` half by the architect
  under the rider), `AuthRLSDDLTests.lockstepFiles` + `15_phase13ie_archive.sql` (the 14
  template) + `notes/plans/13i-e-deploy-checklist.md`. Full core suite GREEN: **2127 tests /
  234 suites** — the 13i-d baseline exactly (the marker pin and the serializer completeness
  walk rode the change). The mirror is NOT deployed — her window; the dev store never syncs so
  the phase builds safely at marker 12. U1 spawns next.
