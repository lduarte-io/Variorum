# U4 ladder — ROUND 1 (cold review, Opus, 2026-10-08)

**Target:** UNIT U4 (the savepoint→commit app-surface sweep, VX-103), EXACTLY the seven commits
`0f4055fb · b67e59c8 · 4a18ce00 · 96ac35ee · 705e98f2 · 8a2fb53a · 3ee9d349` on
`vx-7-13s-voice-onboarding` (worktree `~/dev/variorum-13s`). The interleaved commits in the range
(`fc9974db`, `eea127a7` — the tour fix; U1b's) were excluded hunk by hunk.
**Prompt:** `notes/REVIEW_PROMPT.md` verbatim. **Anchor:** the plan file's R-13s-31/32/34 (her
verbatim words), the U4 BRIEF, the U4 RECORD (grep table, PROVISIONALs P-U4-1..5, self-assessment,
stage commands, red-on-old recipes), R-VX83-9/10 + P-VX83-C7 in `notes/plans/fixes/vx-83-search-followup.md`,
the triage drafts' vocabulary (`13s-guide-triage/00-overview.md`, `chapter-03-takes.md`). No "Review
foci" section exists; the brief's high-stakes checks were treated as foci and each is answered below.
**Scope check (asked first):** the diff touches no editor seam (`CommitBar.swift` hunks are `.help`
strings only — no `EditorTextView`/`BlockRangeIndex`/`PaneSurface`), no custody/keychain code, nothing
under `Sources/VariorumCore/Sync/` or `Persistence/`, and no default's meaning (the cadence pane's
strings moved; `SavepointCadence`'s values and the `savepoint_cadence` read are untouched). Opus scope
holds — no re-spawn as `fable-reviewer` needed.
**My evidence seat:** headless only, in an ISOLATED copy (`git archive 3ee9d349` of the package into
my scratchpad — the shared tree carries U1b's in-flight `Sync/` edits, so I neither built nor
swapped files there). Everything below marked "traced" or "ran" was done at this seat.

## Findings

**Verdict: 0 BLOCKER · 0 MAJOR · 3 MINOR · 2 NIT.**

- **[MINOR] · U4 RECORD, P-U4-1 (`notes/plans/phase-13s-voice-onboarding.md:915`) with the seven
  definition sites (`Core/Views/SavepointNameField.swift:113,119`, `Features/Editor/CommitBar.swift:607`,
  `Features/Takes/TakesBottomBar.swift:378`, `Features/Help/HelperView.swift:88,368`,
  `VariorumMobile/…/MobileBlockHistory.swift:152`) · P-U4-1 is stated without the fact that decides it:
  "saved moment" is ALSO the app's noun for the WHOLE-NOTE version — so the PROVISIONAL cites her
  R-VX83-10 reason in its favour while the chosen gloss partly reintroduces the very confusion that
  reason names.** Evidence (traced in the repo): `Shared/VersionsCopy.swift:49–51` (`empty`, the
  Versions pane): *"No saved moments yet. ⌘⇧S saves the whole note as it is right now"*;
  `VariorumMobile/…/MobileVersions.swift:251–252` (*"No saved moments yet — Save a Version in ⋯ keeps
  the whole note…"*); `VariorumMobile/…/MobileNoteActions.swift:254` ("promote a saved moment" — a
  version); `Registry/CapabilityRegistry.swift:909` (Versions' unavailable note: *"A note's saved
  moments live with the note"*). Her R-VX83-10, verbatim: *"I like commits because I don't want people
  to think savepoint is for the whole note or something."* After U4, a ⌘S press says *"Committed — an
  immutable saved moment of this take."* and the ⌘/ dictionary defines commit as *"An immutable saved
  moment of one take"* — one menu over, the note's Versions pane says *"No saved moments yet. ⌘⇧S saves
  the whole note"*, and on the phone the Commit Take receipt (*"a saved moment of this take is kept"*)
  sits beside a Versions sheet that reads the same "No saved moments yet". The record omits two more
  facts her adjudication needs: (i) the GLOSS SPLIT — the frozen tour (`TourScript.swift:101`) and the
  triage's first teach (`13s-guide-triage/chapter-03-takes.md:83`, *"⌘S keeps a savepoint of the take
  you're in"*, the guide's one R-13s-32 survival) define commit with "savepoint", while ⌘/, the
  receipts and the two tooltips now define it with "saved moment" — the app will teach one word two
  ways; (ii) option (b) is miscounted as "those six definitions" — the built list is seven sites.
  **My judgment on the reading the brief asked me to weigh:** (a) RESPECTS her rulings rather than
  stretching them — R-13s-32 *permits* "savepoint" where it defines commit (it never requires it), its
  recorded line hands "any further explanatory use" to the landing session's judgment, R-13s-31 wants
  the word changed everywhere, and "saved moment" is not an invention: it is her own Block History
  gloss (`Features/Tray/BlockHistoryPane.swift:98–102`, row 28 of the Act 10 round — her ask nearly
  verbatim, *"Savepoints: this take's saved moments"*, now the meaning line under the "Commits"
  header). The defect is the PROVISIONAL's statement, not the build: it is not yet an honest choice
  for her because it hides the Versions collision and the gloss split. No red-on-old pin applies (a
  wording/record finding, not bug-class). · **Fix:** restate P-U4-1 before it reaches QUESTIONS — name
  the Versions collision (the four sites above), the tour/guide gloss split, the count (seven), and
  note that option (c) (no noun — *"Committed — this take, as it stands, kept for good."*) is the only
  option that avoids both the retired word and the whole-note noun. Whether to rebuild to (b) or (c)
  now is the orchestrator's arbitration; (a) may stand as built pending her word.

- **[MINOR] · `App/Variorum/Variorum/Features/Help/HelperView.swift:248–249` (the ⌘/ helper's
  "The note's bars" group) · The `note ▾ (bottom bar)` row teaches a door that does not exist — and
  U4's rewrite of this exact line now tells her the NOTE menu holds commits.** Evidence (traced): the
  row reads *"history (commits) · seal / unseal · the note's date"*. Both `note ▾` menus carry Save a
  Version, `Versions…` (`VersionsPath.menuLabel`), the split-at-newlines repair, Seal/Unseal, the
  date, the wing doors and Delete (`Features/Editor/CommitBar.swift:786–`, `noteMenuItems`; the Takes
  bar's own help says *"its seal and its date"*, `TakesBottomBar.swift:515`) — NO history item: Block
  History left the note menu for the bar beside commit at the post-13l polish round (`06263d16`,
  2026-08-25), pinned by `BlockHistoryPaneTests.theHistoryActIsDeclaredOnBothBarsBesideCommit`, whose
  doc quotes her F2 report: *"it's unclear that history is under Note, that makes it seem like the
  Note's history."* The row was written at 13g batch 7 (`713df357`, 2026-08-01) and went stale in
  August — pre-existing — but U4 rewrote it (`96ac35ee`, "(savepoints)" → "(commits)") and carried the
  false door forward; the rewrite now pairs commits with the note menu, the per-take-vs-whole-note
  confusion both her F2 report and her R-VX83-10 reason name. **Red-on-old pin:** in
  `CommitVocabularyTests` (or `HelperCurrencyTests`) — find the `HelperView.groups` item whose keys
  start "note \u{25BE}", expect `!does.localizedCaseInsensitiveContains("history")` and that it names
  `VersionsPath.menuLabel` (or "version"); red on the current tree, green after. · **Fix:** the row says
  the real menu — e.g. *"save a version · Versions… · seal / unseal · the note's date"*, composed from
  `VersionsPath.saveVerb`/`menuLabel` so it cannot drift again.

- **[MINOR] · `App/Variorum/VariorumTests/DeadVocabularyTests.swift:292–298` (`isLabelShaped`) · The
  fence lets a QUESTION-SHAPED HEADER through: a trailing "?" counts as a sentence end, so a confirm or
  alert title carrying the retired word passes as "prose".** Evidence (traced through the code):
  `endsASentence` is true for `.`/`?`/`!` after closing quotes are stripped, and `isLabelShaped`
  requires `!endsASentence` — so `"Restore this savepoint?"` (3 words) is not label-shaped and is never
  reported. Confirm titles ARE headers by R-13s-32's own scoping ("surface labels and headers"), and
  short "?" titles are this app's standing idiom — ~30 such constants today, e.g.
  `Shared/VersionsCopy.swift:115` *"Make the note say this again?"*, `MobileTutorialSeeder.replaceQuestion`
  *"Restore the pocket guide?"*, `Core/Views/WingsModel.swift:235` *"Delete the wing “x”?"*,
  `Shared/KeyDoorCopy.swift:114` *"Sign out everywhere?"*. A future *"Restore this savepoint?"* or
  *"Delete this savepoint?"* confirm ships silently, against R-13s-31's "so it cannot creep back".
  No live escape today (my own scan: no post-sweep literal naming the word ends in "?"). **Red-on-old
  pin:** add to `theSavepointFenceFiresOnLabelsAndSparesExplanationsAndKeys`
  `#expect(retired(#"static let restoreTitle = "Restore this savepoint?""#) == ["Restore this savepoint?"])`
  — red on the current matcher. · **Fix:** within the six-word limit, count only "." and "!" as sentence
  ends (a ≤6-word question is a title); the tour sentence, the search chip's help and every other
  survival stay out of reach (all long), so the post-sweep tree stays at zero offenders.

- **[NIT] · U4 RECORD, LIVE STATUS row 1 + P-U4-5 (`phase-13s-voice-onboarding.md:863, :919`) · "11
  offenders on the pre-sweep tree, exactly the labels and headers" overclaims, and P-U4-5 never says the
  reading is PER LITERAL FRAGMENT.** Evidence: one of the eleven, `"restore this savepoint"`
  (`MobileBlockHistory.swift:486` pre-sweep), is the act phrase interpolated into a refusal SENTENCE
  (*"This note is locked — unlock it to restore this savepoint."*, the `MobileBlockHistoryTests` pin's
  own string) — prose, flagged only because the fence judges each literal fragment, not the composed
  string (likewise `"history (savepoints) · seal / unseal · the "` is half of a `+`-joined row). Moving
  it was right under R-13s-31, so nothing is wrong in the product; the record's description of the
  fence is. · **Fix:** one sentence in P-U4-5 — the label shape is read per literal fragment (it can
  over-fire on a short prose fragment, loudly, and a composed label is judged by its pieces).

- **[NIT] · `notes/plans/13s-ladders/closeout-checklist.md` (no line) with
  `Features/Tutorial/TutorialSeeder.swift:913` · Nothing gates the merge on the field guide's now-false
  quote.** Evidence: the guide quotes the fold line literally — *"fold into a single “N quiet
  savepoints · show” line"* — while its own comment (`:905–907`) promises *"The words follow
  `SavepointCadenceCopy` / `SavepointRuns` … so the lesson and the switch cannot drift apart"*; U4
  retired that line (`SavepointRuns.runLabel` now says "N quiet commits"), no pin binds the pair, and
  the port that fixes it (chapter 03's landing flag) waits on her per-chapter approvals. The record
  discloses it (watch-out 1); the closeout checklist does not carry it, so a 13s merge ahead of the
  landing ships a guide quoting a line the app no longer shows. · **Fix:** one checklist line — the
  triage landing (or, failing it, the one-line quote port at `:913`) lands before the 13s PR merges.

## The brief's high-stakes checks (each answered)

- **The frozen tour sentence — UNTOUCHED.** `TourScript.swift` is byte-identical at `1d66dfcc`,
  `3ee9d349` and HEAD (md5 `b26f5089…`), "keeps a savepoint of a moment worth keeping" present once;
  no U4 commit touches `Features/Onboarding/` (the range's two Onboarding hunks are `eea127a7`, the
  tour fix, not U4's). `TourTests.swift:46` still pins it. The fence's control asserts it stays out of
  reach (`DeadVocabularyTests.swift:259`).
- **No key, schema name or identifier renamed — VERIFIED.** Every U4 code hunk is a string literal or
  a comment, plus ONE new constant (`SavepointNameCopy.unnamedReceipt`, a hoist). Zero commits in the
  range under `Sources/VariorumCore/Sync/` or `Persistence/`; `savepoint_cadence` (`IdleCommit.swift:33`,
  `Operations+Appearance.swift:196`), the index kind `'savepoint'`, the two migration ids, the
  `.savepoint` row case, `BlockHistoryPath.savepointsSection`, `SavepointCadenceCopy`, the phone's
  `blockHistory.savepoint.<id>` accessibility identifier — all unchanged.
- **The fence's scope — HONEST, with the one hole above.** I built a headless twin from the test
  file's own functions at `3ee9d349` (extractor, matcher, allow-list copied verbatim, `swiftc`) and ran
  it on both trees: **pre-sweep (`0f4055fb`) 652 files, 11 offenders; post-sweep (`3ee9d349`) 652
  files, 0 offenders, all 3 allow-list entries seen (zero stale).** The legal survivals are spared by
  construction (both long prose); keys spared by word-boundary (`savepoint_cadence`), by exact literal
  (the two Settings keywords, the phone's identifier) or by file (Persistence/, the search SQL composer
  and its count reader — I read both: SQL keys and a ranking table only, nothing rendered). The
  question-shaped-header hole is the MINOR above.
- **The grep table's 46/2/19/13 — REPRODUCED by an independent scanner.** My own Python literal
  extractor (raw strings, nested interpolation and block comments handled — written separately from
  the fence's) over the four shipped roots: **80 hits pre-sweep, 34 post**, and every one of the 80
  maps to exactly one row of the table: 46 MOVED (the 20 sites' counts sum to 46), 2 LEGAL
  (`LibrarySearchCopy.swift:63`, `TourScript.swift:101`), 19 KEYS (SettingsShape ×2, the phone's
  identifier, SearchComposer ×8, Operations+Appearance, Migrations ×2, SearchIndex, IdleCommit,
  SearchQueries ×3), 13 the landing's (TutorialSeeder). The 34 survivors are exactly 2 + 19 + 13. The
  "356 comment-only lines" figure also reproduces (688 lines name the word; 356 are comment-only). No
  non-Swift resource (`.strings`, `.xcstrings`, plist, JSON) names the word; no UI-test target keys on
  it. Take-label/name strings: none carried it — confirmed.
- **PROVISIONALs P-U4-1..5 — four honest, one not yet.** P-U4-2 (the verb "makes" — the "takes"
  ambiguity argument is sound), P-U4-3 (the pocket guide — correctly scoped: the U4 brief names the
  phone's twins, the triage covers only the Mac `TutorialSeeder`, and the pocket guide sits in no
  dedupe fact: `SeededFurnitureDedupe.swift:91–94`, `SampleLibrarySeeder.swift:612–615`), P-U4-4 (the
  never-rendered keywords — `theOldWordStillFindsThePaneItsKeyNamed`'s ranking traced through
  `SettingsSearch.findings`: both rows rank 3 on a keyword, the cadence row first by catalog order —
  it will pass) and P-U4-5 (with the NIT's one sentence) are honestly stated with real alternatives.
  P-U4-1 is the first MINOR.

## Clean bill (load-bearing things checked and found solid)

- **The core pin, red-on-old by my own revert (isolated copy):** `SavepointRunsTests` GREEN at
  `3ee9d349`; with `0f4055fb`'s `SavepointRuns.swift` swapped in, `theWordsCountWhatTheRowStandsFor`
  RED with exactly 4 issues (the record's count); restored, `cmp`-clean.
- **The whole core suite, reproduced:** `swift test` in the isolated `3ee9d349` copy —
  **2424 tests in 280 suites passed** + `StringsWorkbookTests` **40 in 6 passed** (the record's
  numbers; my first two runs' reds were my copy's missing `Server/` and `notes/copy-pass/` fixtures,
  added and re-run, nothing in the product).
- **The Mac/Shared/phone hunks, read whole:** every changed string reads as a correct statement of the
  shipped behaviour (the restore receipt, the never-pruned refusal against
  `deliberateSavepointNeverPruned`, the lock/seal auto-commit sentences in the pocket guide against
  §9's quiet-occasion list, the day-filter caveat's union rule against §10). The receipt hoist is a
  genuine de-duplication (three byte-identical literals → one constant), Write's own "Committed."
  untouched as documented.
- **The seeded-text edits are dedupe-safe:** the Jekyll front matter is judged by no fold
  (`Book.joinsPristineDedupe == false`, `SampleLibrarySeeder.swift:310`; `manifest(for:)` is reached
  only through `dedupeCovered`); the pocket guide has no text-hash restore logic (`MobileTutorialSeeder`
  — discovery by name, no pristine check) and sits in no dedupe fact. No existing store's copy
  changes; only fresh seeds speak the new words.
- **The new/flipped pins bind what they claim and will run:** `CommitVocabularyTests` (6) reads the
  real constants, catalog, helper statics and Settings index; the flipped `LibraryDayFilterTests` ×2,
  `LibraryWhenRangeTests`, `SavepointHistoryFaceTests`, `MobileBlockHistoryTests` ×3 bound the old word
  (justified edits); `aCommitRowSaysCommitOnTheDrawnCell` finds the act button where it lives (a direct
  `contentView` subview, `MobileBlockHistorySheetView.swift:345`); `thePocketGuideSaysCommitNeverSavepoint`
  is red on the pre-sweep seed by construction. No other test binds a moved string (searched the three
  test targets for every retired fragment).
- **The stage-window commands and recipes:** every `-only-testing` suite named exists and holds the
  pins it is there for; the four recipe files have been touched by no other unit since `0f4055fb`, so
  the file-copy reverts revert only U4.
- **Discipline:** every U4 commit is pathspec-limited to its unit's files; the record opened before
  any code (LIVE STATUS from `0f4055fb`), REVERT STATE line honest, PENDING marked where the stage
  window owes the run. No canon edit, no Sync/, no schema.
