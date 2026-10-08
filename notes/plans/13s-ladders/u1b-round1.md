# 13s U1b — ladder round 1 (cold review, FABLE reviewer, 2026-10-08)

**Target:** UNIT U1b (the seed reshape), branch `vx-7-13s-voice-onboarding`, diff
`46343a43..eeba3cb0 -- App/ Sources/ Tests/` EXCLUDING the U2 ladder's tour files
(`Domain/Tour.swift`, `TourWalkTests.swift`, `Features/Onboarding/` tour files,
`TourSpotlight.swift`, `TourTests.swift`). Scope verified against the eight U1b commits
(bb3c4f0b, 6075e15c, 1409b339, 8b41ea74, b4979816, 2ce6cb52, abc8f0a6, eeba3cb0): the
U1b commits never touch the excluded files, and the interleaved U2-ladder commits never
touch U1b's files — with one deliberate scope call: **`Features/Onboarding/
BirthFurnitureSeeders.swift` is U1b's own new file** (created 6075e15c, never seen by
the U2 ladder) and was reviewed in full here despite living in the excluded directory.

**Flow note:** the record names a FABLE implementer (R-13s-33's Sync-rule cast), so this
is the SAME-MODEL ladder shape — the orchestrator arbitrates disputes against the spec
(CLAUDE.md's review flow), not the cross-model exchange.

**Spec anchors read whole in this session:** the phase plan (R-13s-1…42, the U1b brief,
the U3 RECORD's disposition 1, the U1b RECORD), `notes/REVIEW_PROMPT.md`, SyncSpec's §7
fold rules + the seeded-furniture-fold paragraph, the 17y B-DEDUPE RECORD + B-SEED
context in `notes/plans/phase-17-standing-fixes.md`, QUESTIONS #186 (a)–(h),
`notes/plans/13s-start-here-reference.md`, and the code: `SeededFurnitureDedupe.swift`
(whole), `SampleLibrarySeeder`/`SampleLibraryWelcome`/`SampleLibraryJekyllBook`/
`SeededBookRestore`, `BirthFurnitureSeeders.swift` (whole), `LaunchFurniture`,
`VariorumApp`, `ShellActions`/`EditorCommands`/`Capability`/`CapabilityRegistry`,
`PostureCopy`/`DataSafetyCopy` + the runbook twin, `Operations+Container`/`+Quicknote`/
`+Import`/`+Tag`/`+Appearance` (the star write), `SegmentationRules`, `BookNaming`,
`PoolAndTray`/`ReadingAssembly`/`AppearanceQueries`, the mobile furniture/settings
files, and every changed test file.

---

## FINDINGS

### MAJOR-1 · Sources/VariorumCore/Sync/SeededFurnitureDedupe.swift:676–797 (`noteVerdict`) and :497–580 (`guideVerdict`) · a STARRED seeded copy reads unengaged and can fold away, silently losing her star — the readme fact U1b adds widens a standing hole in the fold's ruled engagement axes

- **What's wrong.** QUESTIONS #186(a) records the fold's contract in her approved
  words: *"A copy you've edited, renamed, re-ruled, **starred/un-starred**, shelved, or
  tagged is never merged — both stay, visibly."* The R-17y-5 letter quoted in
  `SeededFurnitureDedupe.swift`'s own header names "a star change" in the engagement
  list. The mechanism honors the star axis ONLY at the gathering grain
  (`gatheringIsSeedsOwn`, :358 — `starred` vs `bornStarred`). A NOTE's star lives in
  the synced `setting` star list (`Operations+Appearance.swift:288 setStarred` — "a
  synced `setting` list … ZERO schema"), nowhere on the note's row family, and
  `noteVerdict` has no leg that reads it; `guideVerdict`'s SELECT (:501–509) never
  fetches `reading.starred` either, though a book's star IS that column (the union
  star). So a starred readme / seeded-quicknote / bookless-twin / field-guide copy
  classifies `.foldable` exactly like a pristine one. (The scraps POOL is out of
  this class — `StarTarget.Kind` is post|reading only; a pool cannot be starred.)
- **Evidence (the concrete mechanism, inputs → wrong outcome).** Two fresh Macs each
  seed the readme before sign-in (the B-DEDUPE pair-forming road; her own Pro+Air
  setup). Say Mac 1's copy R1 has the LARGER id. She stars the readme on Mac 1 — a
  `setting`-list write naming R1; zero rows change on R1's family (starring a note
  fires intake only on living BOOKS with star rules — a fresh store has none; the
  starred-notes GATHERING assembles at read and writes no membership). Both Macs sign
  in; a pull lands the twin; `furnitureDedupeOccasion` fires ("readme" is in
  `facts.containers` after piece 5); after the F2 deferral settles, both copies
  classify `.foldable` with EQUAL signatures (U1b's own drift-guard pin proves the
  equality), the smaller id R2 keeps, **R1 — the starred copy — tombstones.** Her
  Starred section then renders nothing for it (`Queries.starredListItems`,
  `AppearanceQueries.swift:276` — dead targets filtered), and the next star write
  self-heals the dead entry out of the stored list. The star is gone without a word —
  against #186(a)'s "both stay, visibly".
- **Pin (red-on-old).** A `SeededFurnitureDedupeTests` two-client arm: both devices
  seed a reserved container (the readme fact, or the quicknote for the pre-existing
  class), ONE device stars its copy (`setStarred(.post(id), true)`), sync both ways,
  run the fold occasion — expect BOTH copies to survive. RED on the current tree (the
  fold folds; the starred copy can be the loser).
- **Scope, stated honestly.** The mechanism predates U1b — the quicknote, scraps pool
  and guide have been exposed since B-DEDUPE shipped in 0.9.2; U1b changes ZERO
  `Sync/` lines. What U1b ADDS is the exposure's widest surface: the readme is the
  newest thing a fresh Library leads with (R-13s-29) and the likeliest first star
  target among seeded objects. The unit's acceptance claim ("every seeded object of
  the final set folds … the 17y B-DEDUPE rules") is satisfied mechanically, but the
  B-DEDUPE rules AS RECORDED include the star axis, and the container/book grains
  don't carry it.
- **Proposed fix.** One engagement leg per container/book verdict: the target id's
  presence in the LOCAL starred list ⇒ `.engaged` (the gathering grain's own axis,
  extended; deterministic per device from synced state; subject to #186(g)'s recorded
  crossing race exactly like every existing axis — no new class). A `Sync/` change —
  the Fable seam; the custody-slot grant this unit held covers it, or it routes to a
  VX ticket as a standing-mechanism fix. The orchestrator's arbitration decides the
  routing; my recommendation is fix-in-ladder while the slot is in hand.

### MINOR-1 · App/Variorum/Variorum/Registry/ShellActions.swift:417–441 (`restoreClassicsGathering`, the adopted arm) · the door refuses "did nothing" even when the arrangement it composed just WROTE — the voice rule its own sibling implements

- **What's wrong.** The door runs `Self.arrangeWelcome(session:)` first, then
  adopts-or-mints. On the ADOPTED arm it always speaks the refusal ("A “classics”
  gathering is already on your Bookcase.", :433–434) and ignores
  `arranged.didAnything`. `restoreSeededBook`'s `alreadyWhole` arm (same file,
  ~:520–535) implements the ruled voice exactly: *"…unless the arrangement WROTE
  something — then the door acted, and a receipt says what"* (18i J33 + 13i-d U7 —
  `WelcomeDoorCopy.alreadyWholeArranged`).
- **Evidence.** An installed-base store on which the arrangement has never run (the
  classics gathering exists from the old seed; Sherlock sits unshelved, un-owned):
  the first press of the new door mints/adopts Welcome, shelves Sherlock onto it and
  owns it (`arrangeWelcome` → `didAnything == true`), adopts the gathering — and then
  claims it did nothing. The sibling door on the same store would have spoken the
  arranged receipt.
- **Pin (red-on-old).** The classics-door suite's shape (`SampleLibraryWelcomeTests.
  theClassicsDoorMints…`) staged on an EXISTING store: pre-create the gathering, leave
  Sherlock unshelved, press the door once — expect a receipt (the arranged voice);
  current code speaks `.refusal`.
- **Proposed fix.** Mirror the sibling: `if let arranged, arranged.didAnything` →
  receipt (an `alreadyWholeArranged`-shaped line for a gathering), else the refusal.

### NIT-1 · App/Variorum/Variorum/Registry/ShellActions.swift:433–434 · the adopted-arm refusal is false for an ARCHIVED adoptee (a pre-existing wording class, new instance)

- `SampleLibraryWelcome.homeReadings` reads `Queries.readings`, which INCLUDES
  archived rows by documented design (`ReadingAssembly.swift:147–151` — "a seeded book
  she archived must never be re-minted"; the right behavior, kept). But an archived
  classics gathering then adopts and the door says "already on your Bookcase" while
  the row sits under ARCHIVED and assembles EMPTY (13i-e). Same class as the book
  doors' standing `alreadyWhole` wording beside an archived copy — recorded for the
  wording's next touch (e.g. an `archived_at`-aware variant: "…already exists — it's
  under Archived"), never a behavior change. No pin owed (wording, not mechanism).

---

## CLEAN BILL (checked specifically, found solid)

1. **ZERO `Sync/` lines** — `git diff 46343a43..eeba3cb0 -- Sources/VariorumCore/Sync/`
   is EMPTY (verified, 0 bytes). The custody-slot grant held for a mechanism change
   that proved unnecessary; the record says so honestly and the mechanism read bears
   it out: the container grain is generic over `facts.containers`, the occasion check
   reads the same list, and the readme's fan rides the signature skeleton whose
   edited-unchosen-take arm the core convergence suite already pins.
2. **The never-soften floors are BYTE-IDENTICAL** — verified old-tree vs new-tree
   extraction of `privacyStandardFloorSentence` and `privacyCastleFloorSentence`
   (`PostureCopy.swift:816–820` new; only line numbers shifted, the sole neighbor
   change the retired `privacyBookDoorSentence`), AND a grep of the ENTIRE range diff
   for floor-sentence text: zero added/removed lines. The runbook twins' floors
   (DataSafetyCopy §8 + `notes/DataSafetyRunbook.md`) interpolate the posture cards and
   are untouched; only the pointer clause left both. The piece-6 trace is correct: the
   pointer was the lesson's own fourth-paragraph constant, OUTSIDE the two fenced
   sentences, so the U3-disposition-1 minimal fix applies. The fenced "SET" caps /
   em-dashes stay HELD for her, as the disposition ordered.
3. **The readme placeholder is byte-exact** — independently re-proven at this seat: a
   compiled-Swift comparison of `ReadmeSeeder.paragraphs` + `takes` against the
   reference's lines 5/7/21/22/60 and 13/17/28/32 (end-trim only; curly quotes, the
   em dash, the curly apostrophe in "I'm", ":D", straight quotes in ¶4 all
   byte-identical). Her dictated closer verbatim; nothing after it; no letter.
   `bulkSegments` splits on `"\n"` with k−1 trailing-newline storage, so the
   `"\n"`-joined import mints exactly five blocks whose rendered page reproduces the
   paragraphs — the pin's `rendered ==` arm is sound. The P-U1b-2 block-boundary
   reading (lines 21/22 as separate blocks) is defensible and recorded with its
   alternative; R-13s-39's naming of "the 'This is the point…' block" supports it.
4. **The casing defaults are fresh-mint-only by construction** — every non-test usage
   of both constants traced: the two mints (`Operations+Container.swift:309`,
   `Operations+Quicknote.swift:161`), display/copy interpolations, the phone's
   starter-journal constant, and the seeder's quicknotes FACT name. No writer renames;
   the daily designation derives from the `'daily'` marker; quicknotes discovery is
   the designation setting; `BookNaming.sameName` is ends-trimmed + case-folded, so an
   installed base's "Quicknotes" still matches the fact's "quicknotes" signature at
   the gathering grain. Both new core pins RUN GREEN at this seat; the red-on-old of
   the ruled-value arm is a literal comparison (red by inspection — re-running the
   behavioural revert adds nothing; not re-run).
5. **The dedupe-facts judgment (the brief's question): the app-side injection honestly
   satisfies the obligations** — with MAJOR-1's star-axis caveat, which is the
   MECHANISM's standing gap, not the injection's. The facts land at the SyncSpec-§7
   seam exactly as B-DEDUPE's acceptance precedent demands (the shipped-shape pins +
   the Mac REAL-SEED drift guard are SyncSpec's own named acceptance idiom): the
   drift guard mints TWICE through the REAL seeders under different UUID seeds and
   classifies through the REAL `SeededFurnitureClassifier` with `BridgeHash.body` —
   the production recipe — proving foldable + equal; the wiring pin covers the one
   named composition (`MacFurnitureFacts.compose`), guide half + both new facts +
   every retained fact. P-U1b-4 (keep the retired objects' facts) is the correct
   direction: classics (door-mintable on N devices), quicknotes (first-capture on N
   devices) and starred notes (still seeded) all still form real pairs; dropping the
   facts would strand them. The Mac-only injection matches the guide's standing
   precedent (the phone is nil-inert on these titles and converges by outcome rows;
   the phone seeds neither object, so no phone-side pair ever forms).
6. **The final seed set matches her launch list verbatim** (R-13s-5/37): launchSet =
   Sherlock alone; arrangement keeps tagging + owning + shelving, drops the gathering
   and quicknote mints; starred-notes gathering still seeds; EE leaves BOTH platforms
   (the phone's first-write leg + marks removed symmetrically); the example scrap
   seeds first (oldest — `Queries.pools` orders `created_at, id`, so the rail's first
   card claim holds); the readme seeds last (newest). The launch pin asserts presence,
   absence AND never-minted (no tombstones), plus `Book.all`/`launchSet` membership.
7. **EE's retirement is COMPLETE on every door surface** — ShellActions func + palette
   row + dispatch case + the tutorial door's silent ensure, the Help menu button, the
   `CapabilityID` case + registry entry, the phone's Settings row + its state + its
   road; `SeededBookRestore.ensure`/`Declined`/`EnsureOutcome` removed as dead code
   with their one caller. No rendered copy names "Encryption Explained" anywhere
   outside the Book definition itself (swept); `Book.all` keeps EE solely as the
   pristine-dedupe vocabulary for the installed base (`dedupeCovered` unchanged), and
   the drill suite's direct seeding stays legal (watch-out 2's honest note).
8. **The Jekyll lowercase rename is safe by construction** — Jekyll opts OUT of the
   pristine dedupe (`joinsPristineDedupe: false`), so no fold signature moves; the
   explicit door ignores tombstones by design (her press is consent); the
   title-case-twin consequence is recorded (P-U1b-5) with the honest alternative; the
   attribution keeps the published title's case on Sherlock's precedent; the registry
   verb follows the one constant.
9. **The classics restore door's brain** is the retired arrangement step's shape,
   driven by ONE body from the door, the chapter fixture and the test (the fixture
   consolidation in piece 3 is real); mint values (collection/createdAt/asc/Welcome)
   match the old arrangement's, so door-minted pairs keep folding under the retained
   gathering fact; adopt-by-rule-or-name prevents twins; the second-press pin covers
   it. `restoreSeededBook`'s alreadyWhole precedent confirms navigate+refuse is the
   established adopted-arm shape (MINOR-1 is only the arranged-receipt half).
10. **The quicknote-lesson staleness is DELIBERATE and owned** — the shipped Books
    chapter still teaches the seeded quicknote and the gathering; piece 1 flags the
    staged chapter world as the tell, and I verified the triage landing's draft
    (`13s-guide-triage/chapter-10…`, the "RESTAGED to the R-13s-37 launch seed" change
    log) rewrites the lesson to the make-your-own road; the landing is sequenced
    before the merge. Not a finding; named here so the dependency stays visible.
11. **Suites** — the whole core suite re-run at this seat at the review's end:
    **2423 tests in 280 suites + 40 in 6 GREEN** (the record's exact finals
    reproduced); `SeededFurnitureDedupeTests` 17/17 green (untouched, as claimed);
    the two new core casing pins green. The Mac/simulator pins are WRITTEN and wait
    for the stage window as the record states; the eight per-fact revert recipes are
    behaviorally correct inverses of the committed lines (each checked against the
    code it names), and recipe 7's already-run claim is consistent with the pins'
    shape.
12. **Discipline** — commits per piece with LIVE STATUS flips in the same commit;
    no attribution trailers on any U1b commit; pathspec-limited stages; the record's
    "what this unit does NOT do" fence matches the diff (no walk, no xcodebuild test
    at the seat, no guide-prose rework beyond the ruled rides, no readme/letter
    finished text — VX-105 stands); existing stores never retrofitted anywhere in the
    diff.

**Verdict: 0 BLOCKER · 1 MAJOR · 1 MINOR · 1 NIT.** The MAJOR is a standing `Sync/`
mechanism gap against a recorded contract that U1b's new fact widens — the
orchestrator's arbitration routes it (fix-in-ladder under the held slot is my
recommendation); the MINOR and NIT are the new door's voice.

## ARBITRATION (orchestrator, same-model ladder — CLAUDE.md's rule; 2026-10-08 ~11:25)

- **MAJOR-1 — FIX IN-LADDER, accepted whole.** The mechanism is concrete, the pin is named, and the scope honesty cuts the right way: the gap is pre-existing (0.9.2's B-DEDUPE) but U1b's readme puts the fresh store's most prominent note on the losing side of it, and 13s holds the custody slot NOW — a later fix would have to re-take it. The fix is the reviewer's named shape: one engagement leg per container/book verdict reading the local starred list, with the two-client red-on-old pin (star one copy, fold, both survive). Sync/ change ⇒ FABLE implements: the U1b implementer is resumed for the fix pass AFTER its stage window completes (its suite results stay valid — the fix is core-side; the dedupe suite reruns headless with the pin). #186(a)'s recorded rule and R-17y-5 are the spec it builds to.
- **MINOR-1 — FIX IN-LADDER:** mirror the sibling's `didAnything` receipt in the classics door's adopted arm (the ruled voice, 18i J33 + 13i-d U7). Same fix pass.
- **NIT-1 — RECORD-ONLY, accepted:** the standing wording class rides the book doors' family; nothing tonight.
- **Sequencing:** stage window (running) → my fresh-store walk → release → the fix pass (headless) → round 2 re-reviews the fixes (fresh reviewer). The walk's validity is unaffected by MAJOR-1 (a two-client fold edge, invisible to a single store).

**In-window fix RATIFIED (orchestrator, ~11:40):** the fan-order defect fix (92d4da7f — the seeder mints same-parent alternates reversed so the stored fan reads [original, take 1, take 2] per R-13s-39's faithful order) is ACCEPTED as within the U1a/U2 precedent: the pin's first red IS the red-on-old capture, the trace is mechanism-level (branchVariant seats after its parent), and the flag was honest. Round 2's scope includes 92d4da7f (the fix + the two corrected pin oracles).

**WALK-BLOCKING FINDING (orchestrator's fresh-store walk, ~12:00): THE TRUE FRESH-INSTALL LAUNCH NEVER SEEDS.** A properly reset dev store (files + ALL device latches cleared) births a fresh store whose UI is right (Study ✓, the offer line ✓) but stays EMPTY: zero `io.lduarte.Variorum` subsystem log lines at any level (the furniture road's unconditional notices absent), no new per-store defaults artifacts — the post-open chain (`fresh.start()` → housekeeping → `LaunchFurniture.seed`) never ran on the fresh-birth path. First TWO reset attempts were MY machinery gaps (the store-file-only reset left the seed latches; recorded for WalkKit lore: a true fresh-install reset clears `SampleLibrarySeeded.Variorum-dev*` + `SampleLibraryWelcome.Variorum-dev` too). The third, correct reset exposed the real defect. The U1b implementer traces and fixes with a red-on-old pin; routing (U1b's refactor vs pre-existing since 17y) follows the trace. The walk resumes on the fix.
