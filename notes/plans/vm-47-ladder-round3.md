# VM-47 — the ladder, round 3 (the whole run's diff, after the walk's fixes and the re-land of main)

**Run record: `notes/plans/vm-47-sizes-and-look.md`.** Reviewer: a fresh `fable-reviewer`,
`notes/REVIEW_PROMPT.md` verbatim with zero framing, 2026-11-19, started 20:21 on the tree at `ce9a1e099`.
Why a round 3: round 2 found no MAJOR, so her rule ("up to 5 rounds as long as a major is found") earned none;
this round was taken because code entered after round 2 read the tree — the walk's fixes (part A's four and
batch 2's ten pieces, about a thousand lines with their pins) and batch 7, the re-land of main (the Mac run's
and the first mobile run's merges; four conflict files resolved by the other run's written map). It was taken
before the last mobile run's merge so that a MAJOR would be known ahead of the stage windows; that last join
(three files) is read on its own afterwards (§3). Read-only; nothing was built or run by the reviewer.
Tally: **0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.** No MAJOR, so no further round is earned by her rule.

## 1. The reviewer's report (verbatim; one absolute path is written `~/dev/…`, as the repo's push guard requires)

VM-47 cold review — ladder ROUND 3 (the whole run's diff vs main `a09d6a025`; HEAD `ce9a1e099`). New ground since round 2 read the tree: the walk's fixes part A (W-A1/A3/A9/A10) and batch 2 (ten pieces + the door rule's placeholder exemption `94f4e752d`), and batch 7 — the re-land of main (merge `4866c7fb8`, the new join pin `9147929f7`). The midway and rounds 1–2's findings and dispositions were re-checked, not re-litigated. Read-only throughout; no build or test ran (the stage is the orchestrator's), so run-claims were verified by disposition-tracing, diffs vs main, and my own greps, never by re-execution. This message should land repo-first as `notes/plans/vm-47-ladder-round3.md` (the round-1/2 convention — the orchestrator lands it; I write no report files). Tally: **0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.**

### Prior rounds' fixes, re-checked (the standing duty)
- R1's three confirmed comment sentences are all landed and worded as ruled: `MobileShellRouter.bindTheme` (…/MobileShellRouter.swift:124 cites R1-m1), `MobileRootMenu.items(settings:)` (:71, the word-is-identity sentence), and R2-n2's never-loosen sentence on `theLinesActAnswersAcrossFortyFourOnAFortyFourLine` (~/dev/variorum-vm-47/App/Variorum/VariorumMobileTests/MobileMessageLineFaceTests.swift:75). R1-n4 stayed dismissed — `MobileReadView`'s comment unedited.
- Round 1's owed item "VM-27's red-on-old by trace only" is now PROVEN (LIVE STATUS row R1.5: green on `vm47-b5`, red on the re-made `rol5` snapshot in both cases at `MobileSettingsProtectionDoorTests.swift:139`, no host stop).
- R1-n2's "no action, owner VM-61/VM-148" was legitimately superseded by the walk's own W-B4 finding (its own trace, fixed with a pin) — not a disposition breach.

### Findings

**[MINOR] · `notes/plans/vm-47-sizes-and-look.md` §5 + `notes/plans/vm-47-walk.md` · The walk's QUESTION-FOR-HER findings have not landed in §5, and §5 is the only road the closeout carries to her.** Evidence (traced): the walk file's own reading protocol (vm-47-walk.md:97) says a question goes "into the record's §5, with the capture file names"; the orchestrator handoff's step 5 repeats "questions for her into §5" and its closeout step says "§5 carried into `notes/QUESTIONS.md` at the merge moment". §5's table holds only P-47-29 and P-47-30 of the walk's output. Living only in the walk file: **W-A5** (the colour-emoji 🗑), **W-A6** (box focused at AX5 hides every book), **W-A7** (the fields' system-blue caret), **W-B2** (the callout wash 1.05:1 on teal & rust's dark paper), **W-C1** (the message line wraps to 63 pt against §E's one 44 pt line), **W-C5** (the disabled calm button 1.65:1), **W-C8** (Terminal lowercases her Versions excerpt); **W-A8/W-C6/W-D3** cite §5 rows (P-47-13/-6/-8) whose text does not carry the new question; and batch 2 piece 3's `pageWarning` orange (≈2.2:1, "a question for her, not a plain token") sits only in §6. (W-A2 alone is genuinely covered, by P-47-27/R-47-3.) Degradation: a closeout executed exactly as written bundles §5 into QUESTIONS and these ten-plus questions never reach her sitting. Fix: before closeout, land each as a §5 row (or one §5 row enumerating the walk's questions by id with capture names, plus a row for the warning-token question). Record work — no pin possible; the written justification above is the evidence.

**[NIT] · `App/Variorum/VariorumMobileTests/MobileFaintOnDoorsTests.swift` (the exemption landed by `94f4e752d`) · The door rule's placeholder exemption is `line.lowercased().contains("prompt")` — any line merely mentioning "prompt" (an identifier, a trailing comment) exempts a faint read, broader than the stated class (`prompt:`, `phoneFieldPrompt`).** Test-only guard breadth: a future door's word in the faint on such a line would silently pass. No production effect, no pin by definition (it guards future code). Fix, if taken: match `prompt:`/`phoneFieldPrompt` as the commit message itself words the class; or nothing.

**[NIT] · process, the worktree during review · An untracked `App/Variorum/VariorumMobileUITests/VM47FinalWalkDriver.swift` sat in the tree at this round's start and was removed mid-review (HEAD unmoved at `ce9a1e099`; tree clean at the end).** Consistent with row 1.6e's stated convention (the driver copy "exists only for that build; never committed") and W.8's pending re-capture — expected walk machinery, listed only so the record shows the tree moved under the review and nothing of it entered the diff. No action.

### The new ground, verified in depth (all solid)
- **Batch 7's merge join:** the four conflict files diffed whole vs main — drawing-layer changes only; VM-78's reads and words intact (`dateChipDay` observed date used, no `.header?.entryDate` in MobileWriteView; `kindLabel` "Gathering" spoken by `PhoneSegmentedChoice` and this run's `kindWord` "Smart Book" gone; `memberRowName`/`kindMark`/`rowCarriesDiverge` whole; `deleteDoorTitle(for:)` and `finishRowAct(for:)` whole). The three no-hunk restyles are exactly as recorded (Unarchive verb → `control`, pause → `meta` + corrected muted inside its three-line cap, `.plain` → `PhoneMenuRowStyle`; Diverge → `PhoneInlineActStyle(tone: .muted)` inside VM-81's `if`). VM-78's phone models and VM-55's `Shared/` brains: zero-line diffs vs main (checked `MobileShelfFaces`, `BookStateCopy`, `ArrivalsCopy`, `StatusCenter`, `WingState`). The both-touched auto-merged files sampled (`MobileShelfView`, `MobileTrashView`, `MobileMembership`): styling-only vs main, main's behaviour (VM-33's empty line, the kind-aware delete, the long-press act table) untouched. The merge commit's per-file log matches the tree. The "map's quoted pre-walk inks vs this run's latest" call is correctly decided by the map's own governing sentence, and the four lines wear the walk's inks the run's own rules hold.
- **The new join pin** (`MobileBookDetailsJoinRowsTests`): its premise holds by reading — `finishRowAct` returns `.finish` for an unlocked archived book, so Finish, Unarchive and Delete Book… all mount; `menuRowPlain` = 44; red-on-raw-merge by construction is plausible (a `.plain` button answers at its word's line). Its first run and the snapshot red-on-old are honestly PENDING.
- **The editor seam, post-merge (my Fable duty):** `MobileEditorTextView.swift` diff vs main is EXACTLY the one authorized line (`backgroundColor = face.room` → `face.paper` in `applyVoiceChrome`); `MobileEditorViewModel.swift`, `Shared/EditorBrain/`, `VoiceTokens.swift`, `Sources/` and `Server/` all zero-diff vs main over the whole run.
- **W-A1:** the mechanism is real (`.clipped()` at the safe-area-sized band cut every page's `ignoresSafeArea()` ground); `MobileBandClip` keeps the sideways fence (neighbours one width away still never show) and frees 2× band height vertically — more than any strip takes in the shipped portrait orientation; scrolling surfaces clip their own content, so nothing new leaks. Pins ran red-on-old and the sideways guard held (row W.7g).
- **W-A3 + the pin's move:** the side-bearing trace is sound (origin = first ink − CTFont glyph-bounds minX at the row's resolved size); moved, not loosened; executed red on old (80.6 vs 52.2) and level on new (49.55/49.58).
- **The faint sweeps (W-A9, W-B1/W-C3):** ink-only; my own greps confirm zero Mac type-slot reads and zero Mac `tokens.faint`/`muted` reads anywhere in the phone tree or Shared's styled arms, and the surviving `tokens.phone.faint` sites are exactly the stated class (the block list's glyph, the box's hint + dashed edge, the disabled daily-journal door, the two prompt inks).
- **W-A10/piece 6:** the prompt road is the only public one; `PeekableSecretField`'s and `AuthViews`' Mac arms are the former constructions byte-for-byte in the diff (`SecureField(titleKey, text:)` / `TextField(label, text:)`, no `prompt:` ever passed off-phone).
- **W-C2:** traced — the env (`mobilePageShowing`, default true outside a shell) is set per band page; the search releases on both the hidden-restore and the page-leave roads; the pin was proven non-hollow (the harness reproduced the restoration; red on old in W.7q). The quick-entry box is covered by its own let-go machinery (`fileOnLeaving` on every `selectPage`, `model.isFocused → focused = false` on every road out), so the fix's narrowness is right.
- **W-B3:** `tint: tokens.alarm` with `.destructive` kept, and the disabled read survives the `.opacity` removal in `SyncStatusViews` because `PhoneControlFeedback` reads `\.isEnabled` itself. **W-B4:** the hairline condition exactly mirrors `undoRow`/`redoRow`'s render conditions (`door.undoLabel`/`redoLabel`). **W-C7:** the divider wears `tokens.line`. **Piece 9 (P-47-30):** honestly no-code, the track facts recorded, held for her.
- **Spec and rules:** appearance stays this phone's own `UserDefaults` preference, never the `setting` table, inert under a test host (`MobileAppearance.swift` — AppSpec §12 honoured); the voice writes through `Operations.setThemeVoice` (S1-shaped); shared ledgers and canon zero-diff on the branch; no commit trailers over the whole range; branch pushed, tip = origin; `.gitignore` gained only the vm-47-screens line; nothing corpus-proportional, nothing word-level, no text copied across entities in the new ground.
- **Review foci:** no plan-time section exists (re-checked); batch 7's five ranked risks each addressed — risk 1 verified above; risks 2, 3 and 5 are run-pending by design (owed below); risk 4 (the Unarchive row's new height) is the new pin's subject and W.8's re-capture's.

### Owed evidence the record already owns (gates the closeout; none claimed done)
(1) Batch 7's stage windows — the 64-type phone array, the 25-type Mac leg, then the whole phone and Mac targets: NOTHING has run on the merged tree; main's guards (G1/G2), the R-47-3 pin set and VM-78's hosted Book Details/membership suites meet this styling at that window. (2) The join pin's first run + its snapshot red-on-old. (3) The `MobileFaintOnDoorsSourceTests` re-run after `94f4e752d`. (4) W.8's re-capture — the only eyes that will see the taller Unarchive row and the restyled Diverge. (5) The closeout duties: FOR A LATER READER (still PENDING), the canon two-file deltas, PL-77, the §5→QUESTIONS carry — which the MINOR above must precede.

**Recommended disposition:** the MINOR is record work for the orchestrator/implementer at or before closeout (no pin — the mechanism is the closeout's own bundling rule); NIT 1 is a one-line test tightening or nothing; NIT 2 needs nothing. Nothing is FINDER-FIXES; nothing new goes to `notes/QUESTIONS.md` from this round (the MINOR routes the walk's existing questions INTO that road rather than minting one). **No MAJOR found — under her five-round rule no further round is earned**, subject to the owed evidence coming back as the record expects; a red in batch 7's windows or W.8's re-capture re-opens as its own trace, not as this round's.

## 2. Dispositions

| Id | Finding | The implementer (§2a) | The reviewer's final call (§2b) | What changed |
|---|---|---|---|---|
| R3-m1 | MINOR — the walk's questions for her have not landed in the record's §5, the only road the closeout carries to her | **AGREE** — checked id by id: seven of the walk's questions were nowhere in §5 (W-A5, W-A6, W-A7, W-B2, W-C1, W-C5, W-C8); three sat beside rows that ask a different question (W-A8 / P-47-13, W-C6 / P-47-6, W-D3 / P-47-8); W-A2 is P-47-27's own question, but the row lacked the walk's measurements; the warning orange was in §6 only. The record work is owed whatever the call, so it landed: one row per question, P-47-27 extended (§2a) | PENDING | `16f9664b0` (the run record's §5, record only): P-47-27 EXTENDED with W-A2's measurements; NEW P-47-31 (W-A5), P-47-32 (W-A6), P-47-33 (W-A7), P-47-34 (W-A8, beside P-47-13), P-47-35 (W-B2), P-47-36 (W-C1), P-47-37 (W-C5), P-47-38 (W-C6, beside P-47-6), P-47-39 (W-C8), P-47-40 (W-D3, beside P-47-8), P-47-41 (batch 2 piece 3's warning orange); one sentence under "Held for her hands" (the Account sheet's first sight is hers). No code, no test |
| R3-n1 | NIT — the door rule's placeholder exemption (`contains("prompt")`) is broader than the class it states | **AGREE** on the breadth, with one correction — `code(_:)` blanks comments before the match, so a comment never exempts; identifiers and string literals do (case-folded). Today's four matching lines are all the real class. The sibling rule (:226) has the same breadth. Narrowest: `prompt:` or `\.phoneFieldPrompt`, case-sensitive, at both rules — or nothing; I lean to taking it. The test is NOT changed pending the call (§2a) | PENDING | PENDING |
| R3-n2 | NIT — process: the walk driver's untracked copy sat in the tree at the round's start (the walk's own build) | **AGREE**, no action — the copy is in no commit on any ref and the tree is clean; its path is not gitignored, and no ignore line should be added (it would hide a stray copy from `git status`) (§2a) | PENDING | PENDING |

### 2a. The implementer's answers

The findings reached the implementer (Opus, 2026-11-19) verbatim. Its agree/dispute is below, for this reviewer's
final call. Nothing was built or run for this step, and no code or test changed. R3-m1's record work, which is owed
whatever the call, landed after these answers in the run record's §5 (the commit is in §2's table).

**R3-m1 (MINOR) — AGREE. The record work is done (the run record's §5).**
- *The facts, checked one by one.* The walk file classes eleven findings as A QUESTION FOR HER: W-A2, W-A5, W-A6, W-A7,
  W-A8, W-B2, W-C1, W-C5, W-C6, W-C8 and W-D3. Its protocol sends each one "into the record's §5, with the capture file
  names" (`vm-47-walk.md` §2). Before this answer, §5 carried two of the walk's ids, both born of its fixes: W-A9
  (P-47-29, the chips' inks after the fix) and W-C4 (P-47-30, the segmented track). Of the eleven:
  - Seven were not in §5 at all: W-A5, W-A6, W-A7, W-B2, W-C1, W-C5 and W-C8, as the finding says.
  - Three were named beside a §5 row whose question is a different one. W-A8: P-47-13 decides the sheet header's INK
    and Cancel's weight, while W-A8 asks how a path title breaks at AX5. W-C6: P-47-6 is the quick-entry box's hint,
    while W-C6 is the tag field's. W-D3: P-47-8 picks "the smaller of the two candidates" by size, while W-D3 asks
    which scaling CLASS the app's own state lines take. None of the three rows carries the walk's question, so each
    gets a new row that points at the old one.
  - W-A2 is covered in substance: its question is P-47-27's own ("which part of the line gives way (the walk
    captures it)"). R-47-3 ruled the word, not the truncation. The row did not hold what the walk measured, so it is
    extended, not duplicated.
  - A twelfth question sat in §6 and row W.7j only: batch 2 piece 3's warning orange on the shared pages ("a question
    for her, not a plain token").
- *The mechanism holds.* Row W.8 ("§5 for any new question") is the record's own step for this. It was NOT-STARTED
  when the round read the tree. A closeout that bundled §5 into QUESTIONS before W.8 ran would have carried none of
  these.
- *The shape: one row per question, not one row listing them.* Each question has its own options, capture names and
  as-built line, and QUESTIONS takes them as separate items for her sitting.
- *What changed:* in §5, P-47-27 extended with W-A2's measurements; P-47-31 … P-47-41 added (W-A5, W-A6, W-A7, W-A8,
  W-B2, W-C1, W-C5, W-C6, W-C8, W-D3, the warning orange); one sentence under "Held for her hands" (the Account sheet's
  first sight is hers).
- *Not a question on screen:* piece 4's leftover, two hairlines when the note's ⋯ sheet has no settings door. In the
  app that state cannot occur: the shell sets `mobileSettingsDoor` over everything it presents
  (`MobileShellView.swift:323`), so every ⋯ sheet draws its Settings row. Only a harness or a preview lacks the door.
- *Left where they are, for the reviewer's call:* the walk's "Noted, not filed" lines hold three items marked "her
  look" that no reader classed as a question. Set 1: the note's ⋯ sheet keeps its rows on the room while Settings' rows
  sit on the paper. Set 2: Book Details' detail lines sit beside their labels, not under them; and the system
  toolbar's "Details · Read" wear the system's label colour (the reader's two stacked back doors are already P-47-20).
  I added no rows for them, because their readers did not class them as questions.

**R3-n1 (NIT) — AGREE on the breadth, with one correction. I would narrow both rules together. Nothing changed now.**
- *The exemption as written.* The door rule (`MobileFaintOnDoorsTests.swift:156`, from `94f4e752d`) is
  `if line.lowercased().contains("prompt") { continue }`. It reads the line as `code(_:)` returns it (:73–82).
- *What it really exempts.*
  - Comments: `code(_:)` blanks every whole-line comment and strips a trailing one (`(^|\s)//.*$`) before any rule
    reads the line. A trailing COMMENT that mentions "prompt" therefore does NOT exempt a faint read. That half of the
    finding's example is hollow.
  - Identifiers and words: string literals are kept and the match is case-folded. So any identifier holding the
    letters in any case exempts its line (`promptCount`, `showsPrompt`, `PromptBadge`, `isPrompting`). So does any
    literal holding them: a door whose own word read "Prompt…" in the faint would pass. Here the finding's breadth is
    real.
- *Today's tree.* Exactly four faint reads in the scanned files share a line with "prompt", and all four are the real
  class:
  - `Shared/AuthViews.swift:469` and `:486`, the Account helpers' `prompt: Text(…).foregroundStyle(style.tokens.phone.faint)`;
  - `Shared/Theme/PhoneControls.swift:337`, `TextField(phonePlaceholder:)`'s `prompt:`;
  - `Shared/Theme/PhoneControls.swift:310`, `.environment(\.phoneFieldPrompt, tokens.phone.faint)`. That line is the
    modifier handing the ink DOWN. The read is `PeekableSecretField.swift:32`
    (`@Environment(\.phoneFieldPrompt) private var promptInk`), a line that no faint pattern matches.

  No line today is exempted that should not be.
- *The narrowest match that still exempts both forms:* `line.contains("prompt:") || line.contains("\\.phoneFieldPrompt")`,
  case-sensitive and not lowercased. These are the argument label and the environment key path, which is how the
  commit message and both rules' comments word the class. Each of the four lines holds one or the other (checked by
  grep; nothing was run). An identifier or a word that merely contains "prompt" would no longer pass.

  Narrower still would tie the faint read to the prompt's own `Text`, by a regex on
  `prompt: Text(…).foregroundStyle(…faint)`. That would also refuse a line holding a prompt beside a separate faint
  word. No view in this tree is written that way, so I would not take the regex.
- *The sibling rule has exactly the same breadth.* `wordOffenders()` (:226, from `a21110f9d`) uses the same
  `line.lowercased().contains("prompt")`, and the door rule copied it (its comment calls it "the sibling rule's
  exemption"). The sibling is the broader rule: it reads every faint read, not only those inside a door, so a hole
  there admits any faint word under 17 pt. Narrowing the door rule alone would leave that hole open.
- *What I would change, if taken:*
  - the two lines (:156, :226) to the two-substring match;
  - the door rule's comment (:152–155) and the sibling's doc comment (:200–201), to name the two forms exactly.

  This is test-only, in one commit. No red-on-old exists, because the rule guards future code. The evidence would be
  that neither rule's count moves (by the grep, all four of today's lines keep their exemption under the narrower
  match), plus the compile on the next build. The other choice is nothing, since no line today is mis-exempted. I lean
  to taking it: the rule's job is to catch a future word, and "prompt" is a plausible word in a future door. The
  reviewer decides.

**R3-n2 (NIT, process) — AGREE: no action.**
- The path `App/Variorum/VariorumMobileUITests/VM47FinalWalkDriver.swift` is in no commit on any ref: `git log --all`
  over it is empty. The tree was clean when this answer started (HEAD `be385dbae`, nothing untracked).
- The convention is the record's. The driver lives gitignored in `vm-47-screens/instruments/`, and its copy in
  `VariorumMobileUITests/` exists only for a walk build and is removed straight after (rows 1.6e and W.2; R-47-3
  piece 3).
- One fact the finding does not name: that path is NOT ignored. `git check-ignore` finds no rule, and the branch's
  `.gitignore` gains only `notes/plans/vm-47-screens/`. What keeps a stray copy out of a commit is the run's
  add-by-path rule and the walk's own removal step. I would add no ignore line, because it would hide a left-behind
  copy from `git status`, the signal that let this round see the tree move.

### 2b. The reviewer's final calls

The implementer's answers (§2a) went back to the round's reviewer, which re-read what they turn on and made the
final call on each. Its reply, verbatim (its closing list of the three files' absolute paths is left out — the
files are this one, the run record's §5, and `App/Variorum/VariorumMobileTests/MobileFaintOnDoorsTests.swift`):

VM-47 ladder round 3 — the reviewer's final calls (§2b). Read-only held; nothing edited, built, or run (the QUIET window stands). I read §2a in full and re-checked each answer against the tree at `e40901ba9`: the new §5 rows at `16f9664b0` read whole (with their Options/Built/State cells), the "Held for her hands" sentence, `code(_:)` at `MobileFaintOnDoorsTests.swift:73–82` (comments blanked, trailing comments stripped), both exemption lines (:156, :226), my own grep of every faint read sharing a line with "prompt" (exactly the four lines §2a names), and the walk file's "Noted, not filed" items.

**R3-m1 (MINOR — the walk's questions for her not in §5) — CONFIRMED, and the landed record work DISCHARGES it. Nothing further to change.**
- I read all twelve rows at `16f9664b0` whole. Every item my finding named is landed, in the right shape: P-47-27 extended with W-A2's measurements (what gives way per voice and size, the two-digit-count caveat, the capture names) rather than duplicated — right, since R-47-3 ruled the word and P-47-27 already owned the truncation question; new rows P-47-31…P-47-40 for W-A5, W-A6, W-A7, W-A8, W-B2, W-C1, W-C5, W-C6, W-C8 and W-D3, each with its own Options · Built · State cells and capture file names, exactly the walk protocol's shape; P-47-41 for batch 2 piece 3's warning orange, with its reachable sites listed and the honest "no capture shows it"; the three beside-pointers (P-47-34 → P-47-13, P-47-38 → P-47-6, P-47-40 → P-47-8) correctly say the old row asks a different question. The Account sheet's never-seen state landed under "Held for her hands" with the road to its first sight named. One-row-per-question over my one-row-enumerating alternative is the better shape, for the reason §2a gives (QUESTIONS takes them as separate items). Nothing is missing against my finding's list and nothing is misplaced; the degradation path (closeout bundles §5 → QUESTIONS) is closed.
- The implementer's "not a question on screen" call on piece 4's leftover (the doubled hairline with no settings door) is right — I verified the shell hands the door over everything it presents, so the state is harness/preview-only.
- **The question left to me — the three "Noted, not filed / her look" items: NO, none belongs in §5, with one condition.** (1) The note's ⋯ sheet's rows on the room while Settings' rows sit on the paper: each surface follows its own ruled grammar (R-47-1 puts sheets on the room; Settings' rows-on-paper is P-47-26's built shape, already held for her look), so a §5 row would hand her a call that is already ruled plus one already held; the sheet itself is VM-61/VM-148's next touch (round 1's R1-n2 owner). (2) Book Details' detail lines beside their labels: VM-78's layout on a screen whose look items the walk already routes to VM-218 (W-D1) — this run deliberately restyled type and ink only, never another run's layout. (3) The system toolbar's "Details · Read" in the system label colour: the pushed screens' top edge is P-47-20's deferred W-009 class with per-screen owners. **The condition:** items (2) and (3) are one line each on their owning tickets at the closeout's ticket pass (VM-218 for the Book Details line; the P-47-20 owner of the book's contents/Read top edge for the toolbar colour), so they leave the walk file with an owner rather than evaporating. Item (1) needs nothing beyond its existing owners.

**R3-n1 (NIT — the prompt exemption's breadth) — AMENDED on the mechanism, CONFIRMED on the breadth, and the narrowing IS TAKEN at both rules.**
- The implementer's correction is right and is adopted as the record's: `code(_:)` (`MobileFaintOnDoorsTests.swift:73–82`) blanks whole-line comments and strips trailing ones before any rule reads a line, so my "a trailing comment mentioning prompt" example was hollow — only identifiers and string literals can exempt, case-folded. The breadth itself is real (a `promptCount` identifier, a door whose own word is "Prompt…"), and its correction cuts both rules, since the sibling (:226) is the broader one (every faint read, not only doors') and the door rule copied its exemption.
- I verified today's tree myself: exactly four faint reads share a line with "prompt" (`AuthViews.swift:469`, `:486`; `PhoneControls.swift:337` — all `prompt:` — and `PhoneControls.swift:310` — `\.phoneFieldPrompt`), all four the real placeholder class; the narrower match keeps all four exempt, and `PeekableSecretField.swift:32` never reaches the exemption (no faint pattern on its line).
- **The exact change, test-only, one commit:** at BOTH :156 and :226, `if line.contains("prompt:") || line.contains("\\.phoneFieldPrompt") { continue }` — case-sensitive, no `lowercased()` (an argument label and a key path have one spelling); the door rule's comment (:152–155) and the sibling's doc comment (:200–201) updated to name the two forms exactly. The regex-on-`prompt: Text(…)` alternative is correctly declined (no view is written that way; it would refuse a legal line shape). Evidence owed: both rules' ported counts unmoved (the four lines keep their exemption; 0 offenders on this tree), the compile riding the next build — no pin, correctly, since the rule guards future code and no red-on-old can exist.

**R3-n2 (NIT, process — the transient untracked driver copy) — CONFIRMED as the implementer answers: no action, and NO ignore line.**
- Its added fact is the stronger argument and is adopted: the path is deliberately not ignored (`git check-ignore` finds no rule — my own round-3 check agrees), so `git status` is the signal that shows a left-behind copy; an ignore line would hide exactly the state this round noticed. The path is in no commit on any ref, the convention (rows 1.6e, W.2) already owns the copy's lifecycle, and the tree is clean. Nothing changes.

**The confirmed fix pass, in full** (the implementer applies; nothing is FINDER-FIXES; nothing new goes to `notes/QUESTIONS.md` from this round — R3-m1's rows reach it through the closeout's §5 carry as designed): (1) R3-m1 — nothing further; the §5 rows at `16f9664b0` stand as landed; the closeout's ticket pass carries the two Noted-not-filed lines to VM-218 and the P-47-20 owner as conditioned above. (2) R3-n1 — the two-substring, case-sensitive match at :156 and :226 with the two comments updated, test-only, one commit; evidence = counts unmoved + the next build's compile. (3) R3-n2 — nothing. Round-3 tally after dispositions: 0 BLOCKER · 0 MAJOR · 1 MINOR (confirmed, discharged by record work) · 2 NIT (one amended-and-taken as a test tightening, one confirmed no-action). **No MAJOR — under her five-round rule no further round is earned**, subject to the owed evidence standing from my §1: batch 7's stage windows and whole-target gates, the join pin's first run and snapshot red-on-old, the `MobileFaintOnDoorsSourceTests` re-run (which now also carries R3-n1's narrowed rule), W.8's re-capture, and the closeout duties. The last mobile run's merge-in (round-3 file §3) is read on its own when it lands, as the record says.

## 3. What this round did not read

The last mobile run's merge had not landed when this round read the tree. Its join into this branch (three
files: `.gitignore`, `MobileSettingsView.swift`, `VariorumMobileApp.swift`, by that run's own map) enters after
this round and is read on its own — a narrow cold pass, or the orchestrator's line-by-line check against the
map if the join is a handful of lines; the record says which. The targeted suites, the re-capture and the merge
gate's whole targets run on the tree that holds it.
