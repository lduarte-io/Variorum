# VX-105 — Ladder round 1 (cold review, whole branch diff)

**Reviewer:** fresh Opus cold reviewer (`opus-reviewer`), 2026-10-30 · `notes/REVIEW_PROMPT.md` verbatim, zero framing.
**Diff reviewed:** `git diff origin/main...HEAD` on `vx-105-readme-letter` (18 files, +1,684/−303), every file read in this session; the record `notes/plans/fixes/vx-105-readme-letter.md`, the content package `notes/plans/vx-105-letter-content/`, her draft `notes/plans/13s-start-here-reference.md`, and the touched seams' neighbours (LaunchFurniture, the book view's Outline/Index, the router, the star write, the note-version mint, the fold classifier) read directly.
**Seam check (first):** the diff touches NO editor seam (no `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/read tier), no custody or keychain code (`Shared/Protection/ProtectionWords.swift` changes ONE comment), nothing under `Sources/` (`git diff origin/main...HEAD -- Sources Package.swift Tests Server` is empty), and no default's meaning. The opus-reviewer seat is right for this round.
**Verification run by the reviewer (headless, no stage):** an independent script compiled the seeder's 17 literals AS WRITTEN (`BirthFurnitureSeeders.swift:117–271`) and checked them against `read-me.txt` (header dropped, blank-line split) and the package README's manifest: **all 17 equal the file byte for byte; no CR, no internal newline, no trailing whitespace; interior fidelity holds — bare-matching blocks exactly [2, 12, 16, 17], the other 13 match with the one space her store carried.** The test file's 17 transcribed hashes diff clean against the README table. The four Start Here passages' move into `TutorialStartHerePassages.swift` diffs byte-identical (modulo indentation) against the pre-VX-105 declaration. The old/new "start here" lesson blocks 2, 3, 8 compared by eye against `origin/main`: as the record states. No Mac suite run (the stage is not mine).

**STATUS: ROUND 1 COMPLETE — 1 MAJOR · 4 MINOR · 3 NIT (findings below; dispositions are the orchestrator's, landed in the record's "## The ladder" before any fix session).**

---

## Findings (severity-ranked)

### MAJOR-1 · `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift:666–709` (the woven "start here", blocks 5–7 and their takes) · the lesson's interactive moment fails on the surface where the guide's first lesson is read by default — the book's Outline — and the BUILD-VERIFY resolved its chrome against Write only

**What's wrong.** Her draft's take sequence was written for the 13s placeholder, a STANDALONE note that opens in Write. Woven into the guide it now lives in a book, and the guide opens on the book view, not on the note:
- Every road to the guide lands on the BOOK: `ShellActions.openTutorial` → `shell.pendingSelection = .reading(found.bookID)` (`ShellActions.swift:719`; the tour's last card calls the same door, `RootView.swift:1154`), the Bookcase's book click likewise; a working book opens in OUTLINE (`BookStructureModel.defaultMode` → `reading.locked ? .read : .outline`, `BookStructureModel.swift:140`). The lesson itself says so — block 3, unchanged: *"You are reading a note, inside a chapter, inside a book on your Bookcase"*; the closer: *"The chapters of this book are listed on the left"* (the book navigator).
- In the Outline the ⑂ badge IS shown (`ReadPostView`'s badge, `BookView.swift:3661` `onBadgeTap` → `model.focus(entry.postID, fanBlock:)` → the inline live `EditorView` → `WriteTakesPanel` sheet), so block 5's *"click on it"* works and take 1 *"You found it! :D"* reads true.
- Take 2 then says *"Now click on Open Takes mode in the top bar of this modal."* The panel's button (`WriteTakesPanel.swift:149`) calls `session.commandRouter.requestMode(.takes, postID:)`; `applyMode` is registered ONLY by `PostDetailView.registerDetail` (`CommandRouter.swift:104`, the sole writer; `PostDetailView.swift:584`), and no note detail is mounted inside a book — so `requestMode` takes its `guard let applyMode else { refuse?(…switchMode.unavailableNote) }` arm (`CommandRouter.swift:549–551`) and speaks **"Open a note first — the modes live inside a note."** The code says this outright: *"Its "Open Takes mode" refuses here as it does over the Outline: no note detail is mounted inside a book"* (`BookIndexView.swift:730–732`).
- Block 6 (*"Click on "expand all" at the top of Takes"*) and take 1 of block 7 (*"you can also get to Takes with ⌘2"*) hit the same wall: ⌘2 in a book routes `ShellActions.requestMode` → the same refusal.

**Inputs → outcome.** Fresh store → tour → "Open the field guide" (or the Bookcase → the guide) → Outline, first lesson "start here" → click ⑂3 on block 5 → panel → press "Open Takes mode" → refusal toast *"Open a note first — the modes live inside a note."* The guide's FIRST interactive instruction does not behave as the words promise — the very case its own closer calls *"a bug in the app, not in you."* The record's BUILD-VERIFY (block 5 / take 2: *"REAL, kept. Write's take icon … presents WriteTakesPanel in a SHEET"*) verified Write's surface, not the book's; R-105-5 asked that the chapter "make sense holistically", and the U1 brief's BUILD-VERIFY mandate was "name the REAL road from the take panel to Takes mode in today's chrome".

**Not new in kind, new in prominence:** "getting around" (unchanged) already says *"press ⌘2 for Takes and ⌘1 for Write"*, which refuses the same way from the Outline — the guide-wide assumption that a lesson is read as an opened note. This effort moves the assumption into the first block a reader acts on.

**Proposed fix (the orchestrator arbitrates; the product choice is hers):** (a) within R-105-5's granted freedom and the BUILD-VERIFY mandate, name the real road from the book in the take/block copy (e.g. open the lesson with its "open ↗" door first — the book's note box offers it in every book mode per SurfaceContracts "The Bookcase and books"), keeping her sentences' shape; or (b) a `notes/QUESTIONS.md` entry: should the take panel's "Open Takes mode" (and ⌘1–⌘7) opened over a book open the note in that mode instead of refusing — product behavior, hers; and in either case ticket the guide-wide class ("getting around"'s ⌘2/⌘1). **Pin:** for (b), a book-context test — focus a guide lesson in the Outline, open its fan panel, press Open Takes mode, assert the note lands in Takes (RED on this tree: the refusal); for (a), extend `theStartHereLessonsChromeWordsAreTheBuildsOwn` to read the named door from its home. The closeout walkthrough should exercise the first lesson FROM THE BOOKCASE (Outline), not only from the Library.

### MINOR-1 · `App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift:314–323` (`liveReadmeID`) · a saved VERSION of the readme counts as "a live readme" — the new door refuses and opens the hidden version

**Mechanism.** `saveNoteVersion` → `mintNoteVersion` makes a full family copy that is a live `container` row `kind='post'`, `deleted_at NULL`, born archived + sealed, with **no title mutation** (`Operations+NoteVersions.swift:32–33, 67–94`). `liveReadmeID` selects `kind='post' AND title='readme' AND deleted_at IS NULL ORDER BY id LIMIT 1` — the version matches. (i) She saves a version of her readme (⌘⇧S), then renames the readme → press Help ▸ Restore “readme” → `.alreadyPresent(versionID)` → refusal *"You already have “readme”, so nothing was restored."* and `pendingSelection = .post(versionID)` opens the sealed archived moment, whose one home is Note ▸ Versions (AppSpec §9: `versionHistoryPredicate` excludes versions from the Library, Archived and every search). P-105-7(v) promises the opposite: *"a readme she RENAMED is no longer a post titled readme, so a press mints a fresh one beside it."* (ii) With the readme and a version both live, `ORDER BY id` over random UUIDs opens the version about half the time.

**Fix.** Exclude versions from `liveReadmeID` with the one classifier the Library/Archived/search use (`versionHistoryPredicate(alias:of: .anyLiveNote)` — `Timeline.swift:354`, `WingQueries.swift:155`, `SearchQueries.swift:488` all read it). It is `internal` to VariorumCore, so the app cannot call it today: either a small public core query ("is this container any note's saved version", beside the public `isVersionHistory(_:_:of:)`) or the orchestrator's call on reusing a public read — never a hand-copied classifier in the app. The door and the birth read then agree with every other surface. **Pin (red on this tree, deterministic under `.incrementing` ids):** seed → `saveNoteVersion(readme)` → `renameContainer(readme, "mine")` → press the door → expect `.restored` and a fresh readme (this tree: refusal, `pendingSelection == .post(versionID)`).

### MINOR-2 · `BirthFurnitureSeeders.swift:325–350` (`performBirthSeed`) vs `:402–411` (`restore`) · the birth seed decides outside its mint's runner turn, and the readme now HAS a door — a press in that gap mints two readmes

**Mechanism.** `restore` reads and mints in ONE runner turn (correct — `twoQuickPressesOfTheReadmeDoorMintOne`). `performBirthSeed` reads on `session.database.read` (no runner), then enqueues its mint as a LATER runner turn with no re-check. If the door's turn is queued before the birth's mint turn but after the birth's read — e.g. the runner busy with the guide's seed turns when she presses Help ▸ Restore “readme” on a first launch — the door mints readme #1 and the birth's turn mints readme #2. The header comment this diff left in place now states the opposite: *"No door latch: these objects have no doors to race."* (`:28–29`). The tutorial's precedent guards exactly this (`aTutorialDoorInFlightIsNeverRacedByTheLaunch`). Window narrow (a first-launch press inside a sub-second gap), consequence two live readmes (both deletable) — hence MINOR.

**Fix.** Move the birth seed's two reads inside the same runner turn as `mint` (the door's shape), and correct the header line. **Pin — honest label:** `OperationsRunner` is an actor whose bodies are synchronous (`OperationsRunner.swift:28`), so the interleave cannot be forced from a test without a seam (an injectable hook between the birth seed's read and its `runner.run`, or a way to hold the actor). With such a seam the pin is deterministic (door queued → birth read sees none → birth mint queued behind the door → assert ONE live readme; this tree: two). Without one, the fix is structural and the only pin is a source-shape assertion — the orchestrator decides whether that seam is worth adding; otherwise record the residual with the corrected header line.

### MINOR-3 · `BirthFurnitureSeeders.swift:379` (`mint` → `setStarred(.post(note.id), starred: true)`) on the DOOR road · the born star is an applying act — in an existing store a living Home book whose rule references the star SEATS (or bells) the restored readme, so the door does not land "the exact seed shape … bookless" (R-105-8)

**Mechanism.** `writeStar` → `intakeAfterStarring(db, postID:)` (`Operations+Appearance.swift:353–355`) for every live, unfinished, unarchived book in the note's wing (Home — the mint's `wingId: ""`) whose rule `RuleGrammar.referencesStar` (`Operations+Intake.swift:69–80`); with the `intake_seating` dial NULL ("join quietly") the readme is seated as a member at the book's end; with `arrivals`, it bells. A fresh store has no such book, so the BIRTH road is exactly as pinned; an existing store can — e.g. a bound "starred notes" gathering (binding keeps `query_spec`, so the bound book keeps collecting, AppSpec §9 `convertSmartReadingToCurated`). The mint's own doc considers only the seeded starred-notes GATHERING (*"a gathering holds nothing — the readme stays bookless"*, `:366–368`). Whether a restore door's born star should be HEARD is product-silent: the core already has the quiet form (`writeStar(…, heard: false)`, internal, VX-596 — "a replay's exact revival is no applying act"), and the opposite reading ("starring is starring") is also defensible.

**Fix.** Not mine to rule — a `notes/QUESTIONS.md` entry (options: (a) heard, as built — the readme joins her star books like any star; (b) unheard — the door's star is the seed's identity, like a replay; needs a public quiet form of the star write). Build stays as is until she answers; mark PROVISIONAL with the alternatives. **Pin (if (b) is ruled):** a store with a Home living book on `{"star":true}`, press the door, assert no `reading_post` row for the new readme (this tree: a member row).

### MINOR-4 · stale and over-claiming lines about the readme's fold and Start Here passages (doc drift this diff created or left behind)

**Mechanism / evidence, each line now false:**
- `App/Variorum/Variorum/LaunchFurniture.swift:136–137` — *"The readme carries its Start Here passages on every store (VX-329: every store opens on the new road)."* It carries none since this diff (`ReadmeStartHerePlanTests.theReadmeCarriesNoneOfThePassages…` pins the opposite).
- `BirthFurnitureSeeders.swift:28–29` — *"No door latch: these objects have no doors to race."* (MINOR-2.)
- `BirthFurnitureSeeders.swift:52–55` (`MacFurnitureFacts`) — *"so EVERY seeded object of the final set folds on sign-in (R-13s-5's release constraint …)"*; and `:89–94` (`ReadmeSeeder.furnitureFact`) — *"two fresh devices' seeds fold at the container grain, content-identical and unengaged only"*. Under S-1 option B a fresh readme is never unengaged (born starred → `noteVerdict`'s star axis, `SeededFurnitureDedupe.swift:727`). `VariorumApp.swift:243–245` says the composed facts carry "the birth furniture's folds" in the same sense.
- **The over-claim the other way:** the S-1 record line and the pin's name `TutorialFurnitureFoldTests.theBornStarredReadmeNeverFoldsByDesign` say the readme NEVER folds. The fact stays registered and the note grain has no `bornStarred` (only gatherings do), so once NEITHER copy is starred (after the two devices meet, the server-wins `'starred'` list stars at most one; her one un-star of that copy is enough) both read pristine — `created_at` is excluded from the signature (`:695–697`) — and the pair FOLDS. That is probably the right outcome (identical pristine copies), but "never" is false, and the round dropped the readme's EQUAL-SIGNATURE drift net (`readmeA == readmeB`), which still guards exactly that un-starred fold.

**Fix.** Correct the five comments to the built truth ("folds only while neither copy is starred; born starred, so a fresh pair keeps both — S-1, VX-711"); rename/re-word the pin to "…NeverFoldsWhileStarred"; and restore the content drift net for the readme: after un-starring both mints (`setStarred(…, false)`), assert both classify `.foldable` with EQUAL signatures. That arm is red on this tree only if the seed's content stops being deterministic — a currency net, green both sides today by design (label it so).

### NIT-1 · `BirthFurnitureSeeders.swift:370–381` + the record's stamp-table coda · the mint is 19 transactions and a failure mid-mint truncates HER TEXT; the record calls this "unchanged in kind from the old seeder", which it is not

The old seeder landed every word in ONE `importPost` transaction (only its takes pass was separate), so its worst partial state was "her text, missing takes". The new mint lands the note first (`createPost`) and then 17 `newBlock` transactions; an error or process death between them leaves a live, UNSTARRED "readme" holding a prefix of her letter, which `seedAtBirth` (`.alreadyPresent`) and the door (refusal) both then treat as present. Recovery exists (delete it, press the door), and the window is a sub-second mint, so NIT — but the record's sentence should say what changed (the text is no longer atomic) and why it was accepted (the split stamp under ops-only, P-105-2). No pin (a crash injection would be the only one; hollow as a bug pin).

### NIT-2 · `TutorialSeeder.swift:690–709` · her takes are pinned to the woven blocks by bare array indices (`startHere.blocks[4]`, `startHere.blocks[6]`)

Any later insertion above them (this lesson is the one R-105-5 says may keep being re-edited, and vx-292 shares the seeder) silently moves both takes to the wrong blocks; only the stage-window pin would notice. A named handle (bind the two blocks' results, or locate them by their text) removes the hazard at no cost. No pin needed beyond the existing `theStartHereLessonWeavesHerWelcome…`.

### NIT-3 · record "O-1" · "readme, a short welcome note" (`TourScript.endAside`) beside a ~1,800-word, 17-block letter is a product question parked only as an "observation for the architect"

Correctly not changed here (tour copy is hers / vx-292's), but an observation in a fix record is easily lost at the closeout; it belongs in `notes/QUESTIONS.md` or as a ticket against the tour copy so her answer has a home.

---

## Clean bill

- **Her text, byte for byte (R-13s-28, R-105-6).** Independently verified (see the header): the 17 literals == `read-me.txt`'s paragraphs; no trailing/CR/internal-newline bytes; interior fidelity vs the manifest holds with bare matches exactly [2, 12, 16, 17]; the test's manifest transcription is exact. `aFreshLaunchSeedsHerReadmeByteForByteOneTakePerBlock` reads the FILE as its oracle (P-105-5) and also asserts `paragraphs == file`.
- **One mint body (R-105-8).** `ReadmeSeeder.mint(ops:writtenAt:)` is called by both `performBirthSeed` and `restore`; her text exists once (`paragraphs`); both run on the quiet facade (`Operations(undoStack: nil)`, `registeringUndo: false`); the door's read and mint share one runner turn (`twoQuickPresses…` pins it).
- **The split stamp (R-105-3, P-105-1/2) through operations only.** `insertPost` reads `date.now` once for `created_at`/`updated_at` (`Operations+Container.swift:357–362`) under the scoped `withDependencies` (swift-dependencies resolves the access-time context over the captured one — `Dependency.swift:183/189`, `initialValues.merging(_current)`); `newBlock` reads ONE `now` for its rows and its touch/churn (`Operations+Block.swift:72–76`), so the pin's `touched == blockStamps.last` equality is sound under the test's ticking clock. `writtenAt` is Gregorian at `TimeZone.current`; the fallback epoch `1_793_249_040` is exactly 2026-10-29T04:44:00Z (checked). The three-zone instants in `herMomentIs…` are right (Los Angeles is still on PDT on Oct 29, 2026).
- **Bookless/untagged/Home/undated** on the birth road: `createPost(title:wingId: "")` with `profile` nil — `importPost`'s own `insertPost(…, profile: nil, entryDate: nil)` shape — no tag or membership write; the fold classifier's star axis confirms why S-1 holds (`SeededFurnitureDedupe.swift:727`).
- **The Sherlock door retitle (R-105-4, boundary ruling 3).** Same `CapabilityID.restoreSampleLibrary`, same act (`restoreSeededBook(.sherlock)`), verb interpolating `SampleLibrarySeeder.bookName`; no rendered "Sample Library" left (the only survivors are the quiet-facade `undoLabel`, OSLog lines and code comments — checked); no guide lesson names the door; the phone has no such door.
- **The readme door's homes (R-105-8).** `restoreReadme` appears in exactly the homes `restoreJekyllBook` has — `Capability.swift` (case), `CapabilityRegistry.swift` (declaration, app scope, `.menuBar`+`.palette`, no key, always), `EditorCommands.swift` (`menuRendered` + Help button, `.disabled(!canReachCreationTarget)`), `ShellActions.swift` (`func`, `paletteActs`, `paletteAction(for:)`); no ⌘/ row exists for any restore door. Receipt/refusal kinds follow the status seam (a mint = receipt; a door that did nothing = refusal), sentence case, no dashes.
- **The passages' re-home (boundary ruling 4, R-105-7).** Byte-identical move (checked); the key lesson still LEADS with the four (`keyLesson = startHerePassages + […]`, unchanged order); chapter 1 reads the same constant; the leads are spelled only in `TutorialStartHerePassages.swift` (grep over the seeder and the readme seeder: none).
- **The weave (R-105-5, boundary ruling 1).** Blocks 2, 3, 8 match the old lesson as stated; block 4 reads `CapabilityRegistry.capability(.restoreTutorial).verb` and the stale-label count drops 3 → 2 (checked on both trees); her draft's words match `13s-start-here-reference.md` except the two recorded edits (F-2's period; ⌘2/⌘/ for "Command 2"/"Command /"); the take fan order (original · 1 · 2) follows `branchVariant`'s seat-after-parent rule, minted second-take-first; the chrome NAMES are real ("Open Takes mode", "expand all" in every style via `offersExpandAll`, `style:` with four styles incl. "Margin grid", ⌘2 = Takes, ⌘/ = the helper) — the ROAD to them from the book is MAJOR-1.
- **No invariant reach.** Nothing under `Sources/`, no schema, no trigger, no sync machinery, no word-level tracking, no corpus-scaled cost (the door's read is one indexed-by-kind title query; the mint is 17 small writes). Writes go through operations only.
- **Boundary with vx-292 honoured.** `TutorialSeeder.swift`'s footprint is the "start here" lesson plus the key lesson's one reference line; the two other stale "Restore Tutorial…" lines and the books chapter's Sherlock lesson are untouched and listed.
- **Pins are red-on-old as claimed** for the readme shape, stamps, star, door arms, the registry declaration, the Sherlock verb and the weave (each by construction: the old tree had none of those facts); the byte-pins of the four passages and `TutorialNewRoadChapterTests` are honestly labelled green-both-sides. `CurrencyError`/`withGuide`/`prose` helpers the new test uses exist in the file. RUN status of every Mac suite remains PENDING the stage window — nothing here substitutes for it.

**STATUS: ROUND 1 COMPLETE — 1 MAJOR · 4 MINOR · 3 NIT.**

## Round 1 arbitration (the orchestrator, same-model ladder — dispositions against the spec)

- **MAJOR-1 — CONFIRMED, fix by REWORDING under R-105-5's grant.** No behavior change tonight: whether "Open Takes mode" over a book should open the note is unruled product behavior — it goes to `notes/QUESTIONS.md` at the merge (noted in the record now). The fix session rewrites blocks 5–7's instructions and takes to roads that WORK from the book's default surface, verifying each candidate against the code before locking copy (the BUILD-VERIFY discipline, this time from Outline): the take icon → take panel works as written; the second take's instruction and blocks 6–7's "expand all"/"style" steps must either use the in-place Takes sheet's real chrome (verify what it offers) or walk the reader through "open ↗" into the full editor first. Keep her play (the hidden "You found it! :D" stays the first take). The sibling defect in "getting around" (⌘2/⌘1 claims in the same in-book context) is PRE-EXISTING and ticketed separately (see below), not fixed here. The closeout walkthrough starts from the Bookcase and walks the lesson's steps as a new user would.
- **MINOR-1 — CONFIRMED.** Saved versions are fenced everywhere (`Queries.versionHistoryPredicate`); the door's live-readme read excludes them via a small public core query (Queries, not Sync/). Red-on-old pin exactly as the finding states (save version → rename → press → fresh mint, never the version opened).
- **MINOR-2 — CONFIRMED.** The birth seed's decide-reads move inside the mint's runner turn (the door's shape); the "no door latch" header comment is rewritten to the new truth. The deterministic-pin seam problem is accepted as the finding states — pin what is cheaply pinnable, record the rest honestly.
- **MINOR-3 — CONFIRMED AS RECORDED BEHAVIOR, no code change.** The star rides the one application road and intake is event-driven BY DESIGN — a living book whose rule wants starred notes hearing the door's star is the system working, exactly as a hand-star would. "Bookless" in R-105-8 describes the fresh-store seed (no living books exist at birth). PROVISIONAL in the record; a `notes/QUESTIONS.md` entry at the merge asks whether the door's star should be a non-event.
- **MINOR-4 — CONFIRMED whole.** Fix the three stale comment sites; reword the S-1 pin and its name to "never folds while starred"; restore the equal-signature drift check on unstarred mints.
- **NIT-1 — CONFIRMED, fix preferred.** Evaluate the one-transaction road first: `importPost` under the 4:44 clock reproduces the 17 trimmed blocks in ONE transaction if and only if its `.paragraph` segmentation is byte-neutral on her trimmed text (the pin proves it); the edited-stamps finish is then one follow-up write on the seed clock, and a failure between leaves a WHOLE letter (benign) instead of a truncated one. If byte-exactness breaks under that road, keep today's shape and fix only the record's "unchanged in kind" claim.
- **NIT-2 — CONFIRMED.** Cheap hardening: the take-attachment indices assert their block's expected text prefix (refuse the attach loudly in DEBUG on a mismatch) or resolve by prefix.
- **NIT-3 — CONFIRMED as a ticket.** The end card is tour copy (vx-292's surface): ticketed, not fixed here.

Tickets minted at this arbitration: see the record's closeout section (the getting-around sibling; the end-card wording). Fix round: a FRESH implementer session applies the confirmed fixes with red-on-old pins; round 2 re-reviews the fixes.

## FIX ROUND 1 RECORD (a fresh Opus implementer, 2026-10-30 — the arbitration above is the work order)

**What this round did NOT do (first line, per the contract):** no Mac suite was RUN (stage window only — every Mac pin
below is WRITTEN and compiles; RUN status PENDING); no walk, no app launch, no `/Applications` touch; nothing under
`Sources/VariorumCore/Sync/`. Her readme text (the 17 blocks) is untouched by every commit here (checked at the end:
the `ReadmeSeeder.paragraphs` literal is identical between the round's base `2b83ecf71` and its last commit).

**ROUND STATE: READY-FOR-STAGE** — every finding dispositioned below; every Mac pin WRITTEN and compiling
(`xcodebuild … build-for-testing` EXIT 0, no warning in a touched file); the core's one change (a public query) RUN
GREEN headless; the full core suite's end-of-round run is recorded in "Headless evidence" below.

### LIVE STATUS

- **MINOR-1** (a saved version is never "a live readme") — DONE (`fa4187e79`; this record line followed one commit
  later). The fix: a small public core query `Queries.isVersionOfAnyLiveNote(_:_:)`
  (`Sources/VariorumCore/Queries/NoteVersions.swift`, beside `isVersionHistory`) — the ONE classifier,
  `versionHistoryPredicate(alias: "v", of: .anyLiveNote)`, the Library/Archived/search/wing-move fence, asked of one
  live container; `ReadmeSeeder.liveReadmeID` now reads the posts titled "readme" in id order and returns the first the
  classifier does not name (the birth seed and the door share the read, so both are fixed). Not `Sync/`; no schema.
  Pins: (1) core, HEADLESS, RUN GREEN — `NoteVersionsTests.anyLiveNotesVersionIsNamedAndNothingElseIs` (`swift test
  --filter NoteVersionsTests`: 31 tests passed): the mechanism stated (save a moment of "readme", rename the note → a
  title read finds the moment as a live post), the moment named; the note, a plain "readme" and an archived work never
  named; an unmarked pair not named; a moment that rode its note's deletion not named. Red on old by construction (no
  public form existed; the predicate is internal). (2) app, WRITTEN, compiles (`build-for-testing` EXIT 0), RUN
  PENDING the stage window — `LaunchFurnitureTests.aSavedVersionOfTheReadmeIsNeverALiveReadme`: seed →
  `saveNoteVersion(readme)` → `renameContainer(readme, "mine")` → Help ▸ Restore “readme” → a receipt,
  `pendingSelection == .post(fresh)` with fresh ≠ moment ≠ original, the fresh note her 17 blocks, and a second press
  answering `.alreadyPresent(fresh)`. RED ON OLD by revert recipe: restore `liveReadmeID`'s bare `SELECT … ORDER BY id
  LIMIT 1` → the moment is the only live "readme" → `.alreadyPresent(moment)` → the refusal speaks and
  `pendingSelection == .post(moment)` (the receipt and `fresh != moment` expectations fail).
- **MINOR-2** (the birth seed decides inside its mint's runner turn) — DONE (the commit carrying this line). The fix:
  `ReadmeSeeder.performBirthSeed`'s two decide-reads (the live read, the tombstone read) moved INTO the `runner.run`
  body that mints — `@Dependency(\.database)` read in the turn, exactly `restore`'s shape — so nothing can land between
  the decision and the mint. The header's "No door latch: these objects have no doors to race." is rewritten to the
  truth (the snippet has no door; the readme has one and decides in its mint's turn; why the tutorial needs a latch
  and the readme does not). The example snippet's seeder is unchanged (no door — no race). Pins, both WRITTEN and
  compiling, RUN PENDING the stage window: (1) `LaunchFurnitureTests.aDoorPressInTheBirthSeedsGapNeverMakesTwoReadmes`
  — the interleave forced by HOLDING the runner (a turn waiting on a semaphore, bounded at 10 s so it can never hang
  the suite): the door's turn queues behind the hold, the birth seed runs, the hold lets go → exactly one of the two
  minted, one live readme. RED ON OLD by revert recipe (restore the `session.database.read` before `runner.run`): the
  birth's read runs while the runner is held, sees nothing, and queues its mint behind the door's → two readmes, both
  minted. HONEST LABEL: the red side relies on the runner taking its queued turns in order (the door's queued ~100 ms
  before the birth's mint — FIFO in practice, not promised by the language); the green side is order-independent
  (either order leaves one). (2) `LaunchFurnitureTests.theBirthSeedReadsNothingOutsideItsMintsTurn` — the
  DETERMINISTIC shape pin: `performBirthSeed`'s source holds no `session.database` read, and inside it the
  `session.runner.run` precedes the live read, which precedes the mint. RED ON OLD by construction (the old body read
  on `session.database.read` ahead of `runner.run`). Residual, recorded: none in the readme; the snippet has no door.
- **MINOR-4** (stale comments; the fold pin's "never") — DONE (the commit carrying this line). The stale lines, each
  now the built truth: `LaunchFurniture.swift` (the readme "carries its Start Here passages" → the readme is her letter
  alone; the passages live in the guide's first and protection chapters, R-105-7); `BirthFurnitureSeeders.swift`
  `MacFurnitureFacts` ("EVERY seeded object … folds on sign-in" → every seeded object is KNOWN to the fold, with the
  readme's ruled exception: born starred, a fresh pair keeps both, folds once neither copy is starred — S-1, VX-711)
  and `ReadmeSeeder.furnitureFact` (the same correction at the fact); the header's "No door latch" line (done at
  MINOR-2); `VariorumApp.swift` ("the birth furniture's folds" → facts, with the readme's "only once neither copy is
  starred"); and the wiring pin's message in `TutorialFurnitureFoldTests`. The pin RENAMED and reworded:
  `theBornStarredReadmeNeverFoldsByDesign` → **`theBornStarredReadmeNeverFoldsWhileStarred`** (assertions unchanged:
  both fresh mints `.engaged`). The drift net RESTORED: **`theReadmeFoldsOnceNeitherCopyIsStarredAndTwoMintsAgree`** —
  both mints un-starred through the one star write (`setStarred(.post(id), starred: false)`), both classify
  `.foldable` with EQUAL signatures. Honestly labelled a CURRENCY NET: green on both sides today by design; red only if
  the readme's seed stops being deterministic or an un-starred readme picks up an engagement leg. The U1 record's four
  "never folds" lines (its pin table, P-list, stage expectation, S-1 RULED paragraph) corrected in place, each naming
  the round. WRITTEN, compiling (`build-for-testing` EXIT 0), RUN PENDING the stage window.
- **MAJOR-1** (lesson 1's takes moment from the book's Outline) — DONE, RESHAPED by **R-105-10** (her ruling, relayed
  mid-round; recorded verbatim in the U1 record's rulings). GUIDE CONTENT CHANGED AGAIN (the "start here" lesson) —
  her real store's seeded guide is stale by it, as R-105-9 already leaves to her (she re-seeds on the Air after the
  release). No behavior change anywhere.
  **First form (`3a42c3f5b`) — SUPERSEDED by R-105-10, kept as history:** one conditional sentence inside her
  take-icon block ("If you're reading this in the book's Outline, click open ↗ beside this note's title first, so it
  opens in the full editor."). R-105-10 moved the teaching EARLY and made it the lesson's first ask; her block is
  verbatim again.
  **The reshaped fix (the commit carrying this text) — the lesson is now FOURTEEN blocks:**
  1. **A NEW block 4 (0-based 3), right after "This book is Variorum teaching itself with itself. You are reading a
     note, inside a chapter, inside a book on your Bookcase … right here in its own text." — the lesson's FIRST ask,
     before the safety block's "Cut it up, rewrite it, delete it" and before any take click.** Rendered:
     > The first move to learn is the one from a book into a note. In the book's Outline each note is a card, and
     > clicking it, or open ↗ beside its title, opens the note itself in the full editor. Open this lesson that way
     > now if it isn't open already: the rest of it happens inside the note.

     ("open ↗" interpolated from `NoteBoxCopy.openDoor`, the book's one word for its open door — never retyped. It
     composes with block 3: block 3 says what the reader is looking at, block 4 is the move into it. "if it isn't open
     already" keeps it true for the reader who clicked the card and is already inside — an ask, not a warning.)
  2. **Her take-icon block (now block 6) VERBATIM again:** "I built Variorum with a simple goal: to be able to create
     multiple different versions of a block of text. I call these versions takes, borrowing from the film world. The
     icon to the right of this block is the take icon - click on it." Her takes, her Write/Takes block and her "so
     what?" block with its takes — all as U1 seeded them (F-2's period and the ⌘2/⌘/ idiom stand, ruled).
  3. **F-3 — the closer, adjusted (flagged; a consequence the new happy path required, under R-105-5's grant):** a
     reader on the happy path now reaches the closer INSIDE the note, where "The chapters of this book are listed on
     the left" was false (the left there is the app's sidebar, not the book's navigator — this was O-2 in the first
     form, already true then for a reader who clicked the card). Rendered now:
     > In the book itself, the chapters are listed on the left, each an interactive guide, and from inside a note the
     > book glyph above the page takes you back there, at that very note. Read in order, or jump to what itches. When
     > something in a lesson doesn't behave as the words promise, that is a bug in the app, not in you.

     True from the Outline (the book's navigator) and from the note (a note's context bar wears the book glyph, whose
     click opens its one book at that note — `ContextBarDoors.iconRow(isNote: true)`, `bookClick(bookCount: 1, …) ==
     .open`; "the workspace" lesson teaches the same glyph). It completes her flow both ways (book → note is the first
     ask; note → book is the closer). REVERT RECIPE if the orchestrator rules it out of scope: restore the U1 closer
     text ("The chapters of this book are listed on the left, each an interactive guide. Read in order, …") and its
     pin line — O-2 then returns as an observation.
  **BUILD-VERIFY (each against the code):**
  - What a reader on the guide's first lesson actually sees: every guide road selects the BOOK
    (`ShellActions.openTutorial` → `pendingSelection = .reading(bookID)`), a working book opens on `.outline`
    (`BookStructureModel.defaultMode(for:)`; the guide is not finished), and the Outline shows each note as a
    collapsed CARD by default (`BookViewModel.expandedPosts`, her #43(a) ruling): title, a 40-word excerpt (her welcome
    and the beliefs' opening), "open ↗" on the card's title row, ▸ to unfold. The card's BODY is the open door too
    (`collapsedPostCard`: `Button { onOpenInWrite(entry.postID) }` — the tour's "Click into …" road). A reader who
    unfolds the card in place (▸) reads the lesson in the Outline, where the expanded header carries "open ↗" right
    beside the title (`postHeader`); the sidebar's note box carries the same word (`NoteBoxCopy.openDoor`, VX-304).
  - Where the door lands: `openInWrite` → `onOpenSearchHit` → `RootView.open(.post(id), mode: .write)` → the note's
    own detail in WRITE — at her caret's block when the note was live in the Outline (`BookOpenDoor.place`), else the
    plain open's place (R-18l-1). Its help reads "Open this note in the full editor (Write · Takes · Lenses · …)"; "a
    book from the inside" already says "clicking a card opens the note in the full editor".
  - From the opened note, her take instructions re-verified (U1's BUILD-VERIFY was done in Write, the same surface):
    the ⑂ badge at block 6's right (`BadgeOverlayController`, `x: proseRight + 6`) → `openFan` → `WriteTakesPanel` in
    a sheet ("this modal") → take 1 "You found it! :D" → take 2's "Open Takes mode" in the panel's top bar →
    `requestMode(.takes)` → the mounted `PostDetailView`'s `applyMode` → Takes, bloomed on the block; block 7's
    "expand all" at the top of Takes (`TakesBoardView.headerControls`, every style); block 8's takes — ⌘2 is Takes,
    ⌘/ the helper, the per-block ⑂ and the top button expand/collapse, "style:" with four styles incl. "Margin grid".
    Every word of hers holds as written; none needed changing.
  - The reader who stays in the Outline (graceful, no warning added): the read surface shows the ⑂ badge
    (`ReadPostView.onBadgeTap` → `focus(…, fanBlock:)` → the inline editor's `WriteTakesPanel`), so the play still
    plays — the icon, the panel, "You found it! :D"; only take 2's "Open Takes mode" refuses there, and the refusal
    itself says why ("Open a note first — the modes live inside a note."), pointing back at the first ask; the panel
    offers neither "expand all" nor "style", so blocks 7–8's Takes steps wait for the opened note.
  **Pins** (WRITTEN, compiling — `build-for-testing` EXIT 0 — RUN PENDING the stage window):
  `TutorialCurrencyTests.theStartHereLessonWeavesHerWelcomeHerTakesAndTheFourPassages` — now FOURTEEN blocks: the
  first ask's exact text (with `NoteBoxCopy.openDoor` asserted `== "open ↗"`), her take-icon block verbatim with both
  takes, the closer's new text, the passages at 10–13, single takes elsewhere; RED ON OLD by construction (no block
  named a road into the note; 13 blocks). `TutorialCurrencyTests.theStartHereLessonsRoadOutOfTheOutlineIsTheBuildsOwn`
  (the H pattern — a currency net, green both sides by design): the seeded guide's own row reads `defaultMode ==
  .outline`; BookView's header "open ↗" calling `onOpenInWrite`, the card body's `Button { onOpenInWrite(…) }`, the
  Write landing and the "full editor" help; `CommandRouter`'s no-`applyMode` refusal arm (RED if a mode request ever
  works without a mounted note — then revisit the first ask); the take panel's lack of expand all / the style menu;
  and the closer's way back (`ContextBarDoors`: a note wears the book glyph; one book → `.open`). The unchanged
  `theStartHereLessonsChromeWordsAreTheBuildsOwn` still holds her chrome words. Headless sanity: a script checked
  every source string the road pin reads — all present/absent as asserted.
  **For the orchestrator at the merge (not built):** the QUESTIONS entry (should "Open Takes mode" and ⌘1–⌘7 over a
  book open the note in that mode instead of refusing — R-105-10 rules the lesson, not the button); the "getting
  around" ⌘2/⌘1 sibling stays its ticket (that lesson is another note, read wherever the reader is). The closeout
  walkthrough (the orchestrator's) should start from the Bookcase: the guide → Outline → the "start here" card → the
  first ask (card click AND, separately, ▸ then the header's open ↗) → block 6's ⑂ → take 1 → take 2's Open Takes
  mode → expand all → block 8's takes → the closer's book glyph back to the book at the lesson; and once staying in
  the Outline (▸ → ⑂ → the panel → take 2's refusal reads sensibly).
- **NIT-2** (the take attachments check their blocks) — DONE (the commit carrying this line). The fix: a nested
  `fanned(_:opening:)` in the "start here" lesson resolves each take target by its index AND the opening of its text
  ("I built Variorum with a simple goal" for block 6, "This is the point at which you might be thinking" for block
  8 — blocks 5 and 7 when NIT-2 landed; R-105-10's first ask moved both down one, and the indices moved with them in
  the same commit, which is exactly the edit NIT-2 guards); a mismatch REFUSES the attach — `assertionFailure` in DEBUG (loud: every suite that seeds the guide trips it),
  and in Release no take lands rather than a wrong one. Her four takes' texts and their mint order are unchanged
  (byte-identical literals, moved inside the two `if let`s). Pin: none new, as the finding says — the existing
  `TutorialCurrencyTests.theStartHereLessonWeavesHerWelcomeHerTakesAndTheFourPassages` asserts both fans on their
  blocks in fan order; NIT-2 is hardening against a FUTURE edit (no misattachment exists today), so no red-on-old pin
  can exist for it — recorded, not hollow. Compiles (`build-for-testing` EXIT 0).
- **NIT-1** (the one-transaction road) — DONE as the arbitration's FALLBACK (the commit carrying this line): the road
  was evaluated and NOT TAKEN; today's mint shape is kept; the U1 record's "unchanged in kind" claim is corrected in
  place. The evaluation, each half against the code:
  1. **Byte-exactness — HOLDS (checked).** A throwaway core test (run headless, then deleted — never committed) read
     `read-me.txt` as the U1 pin does and ran the bulk segmenter: `SegmentationRules.bulkSegments(paragraphs.joined(
     separator: "\n"), mode: .paragraph)` == her 17 paragraphs, byte for byte (one line per paragraph; `trimmedPiece`
     trims nothing from her already-trimmed blocks). Joined by "\n\n" instead, 16 of 17 blocks gain a trailing "\n"
     (the blank-run rule keeps k−1 newlines as content) — not exact; and `importPost`'s default reads the READER's
     segmentation (one-block → 1 block, sentence → 81), so the road would have to pass `.paragraph` explicitly.
  2. **The edited-stamps finish — CANNOT BE DONE THROUGH OPERATIONS.** `importPost` under the 4:44 clock lands
     `created_at`, `updated_at`, `last_touched_at` AND `last_major_revision_at` at 4:44 (its `mintSegments` stamp touch
     + churn per block on the same clock). R-105-3 needs `last_touched_at` / `last_major_revision_at` at the seed
     moment (the readme tops the edited sort, R-13s-29). The ONLY writer of `last_major_revision_at` is
     `registerTextChange` (`Operations+Variant.swift:688`), reached by a churn-crossing text change or by
     `forceMajorRevision: true`, which only a MANUAL `commit` passes (`:65`). So the finish would need a raw row write
     (operations-as-API forbids it — P-105-2's own reason), a manual savepoint (a visible commit in her readme's
     history AND fold engagement — `noteVerdict` reads a manual `commit_point` as hers), or `autosave` of unchanged
     text with an invented `charDelta` (a false churn report). None is spec-defensible → per the brief's STOP rule the
     road is abandoned, not re-designed.
  **Not built — an option for the orchestrator only:** a two-phase clock scoped to `importPost` (4:44 for its FIRST
  `date.now` read — `insertPost`'s — and the ambient clock for every later read — `mintSegments`') would land today's
  exact stamp shape in ONE transaction. It is a different design from the arbitrated one and couples the seed to
  `importPost`'s internal read order (a stamp pin would guard it), so it is named here and not built.
  Record corrected: the U1 record's stamp-table coda now states what changed (the text is no longer atomic: the worst
  partial state is a live, unstarred readme holding a PREFIX of her letter, which both roads then treat as present —
  recovery is delete + the door) and why it was accepted (the split stamp under operations-only). No pin (a crash
  injection would be the only one — hollow as a bug pin, as the finding says).
- **MINOR-3** (the door's born star is heard) — DONE as recorded behavior (the commit carrying this line), NO code
  change: **P-105-8** in the U1 record's PROVISIONALs states the built behavior (the star rides the one application
  road; an existing store's living Home book that wants starred notes hears the door's star, as it would hers;
  "bookless" in R-105-8 describes the fresh-store seed), the alternative (b) unheard with what it would need (a public
  quiet star write — `writeStar(…, heard: false)` is internal), and the pin owed only if (b) is ruled. The QUESTIONS
  entry is the orchestrator's at the merge (a worktree implementer never touches the shared ledger).
- **NIT-3** (the end card's "a short welcome note") — DONE as a ticket: VX-713 (the arbitration's), noted on the U1
  record's O-1. No code change (tour copy is vx-292's surface).

### Headless evidence (end of round)

- `swift build` EXIT 0. The full core package `swift test` at the end: **VariorumCoreTests — 3,555 tests in 477 suites
  PASSED (5 known issues, the standing `PairInvariantPinsTests` ones)**; a third target 32/32 passed;
  **VariorumMCPTests — 468 tests, ONE issue: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnect
  NamedAndBounded` (a wall-clock bound, `elapsed < 15 s`, measured 27 s while the whole package ran in parallel)**.
  Re-run alone: PASSED in 1.05 s. A load-bound timing flake in the MCP socket harness, untouched by this round (it
  never reaches `Queries.isVersionOfAnyLiveNote`, the round's only core change). Recorded, not fixed.
- `NoteVersionsTests` (31, incl. the new MINOR-1 pin) PASSED.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing -quiet` (compile-only — app AND test
  target, nothing run, no test host launched) EXIT 0 after every code commit; no warning in a touched file.
- Her text: the `ReadmeSeeder.paragraphs` literal is byte-identical between `2b83ecf71` and the round's last commit
  (scripted comparison).
- NIT-1's byte check: a throwaway core test, run and deleted (never committed) — see NIT-1.

### Stage-window expectation (updated for this round)

The U1 record's stage command list stands — every suite TYPE this round touched is already on it
(`LaunchFurnitureTests`, `TutorialFurnitureFoldTests`, `TutorialCurrencyTests`); no new suite type. **Expected at the
window: everything passes — no expected red.** The round's new/renamed Mac tests, by suite type:
`LaunchFurnitureTests` · `aSavedVersionOfTheReadmeIsNeverALiveReadme` (MINOR-1) ·
`aDoorPressInTheBirthSeedsGapNeverMakesTwoReadmes` (MINOR-2 — it HOLDS the session runner on a bounded semaphore wait
for ~0.4 s, blocking one cooperative-pool thread; it can never hang past 10 s) ·
`theBirthSeedReadsNothingOutsideItsMintsTurn` (MINOR-2); `TutorialFurnitureFoldTests` ·
`theBornStarredReadmeNeverFoldsWhileStarred` (renamed) · `theReadmeFoldsOnceNeitherCopyIsStarredAndTwoMintsAgree`
(restored, MINOR-4); `TutorialCurrencyTests` · `theStartHereLessonWeavesHerWelcomeHerTakesAndTheFourPassages`
(fourteen blocks now) · `theStartHereLessonsRoadOutOfTheOutlineIsTheBuildsOwn` (MAJOR-1/R-105-10). If the MINOR-2
interleave pin reads red, read its message first: "exactly one of the two minted" false with BOTH minted means the fix
regressed; a hang is impossible by construction.

**Commits, in order:** `fb9c2a9ea` the record opens · `fa4187e79` MINOR-1 · `d895f34bb` MINOR-1's record line ·
`a24e9477b` MINOR-2 · `85cfa64eb` MINOR-4 · `3a42c3f5b` MAJOR-1 first form (superseded) · `b04f47bae` NIT-2 ·
`13257d389` NIT-1 + MINOR-3 + NIT-3 records · `198b94562` MAJOR-1 reshaped by R-105-10 · this close.
