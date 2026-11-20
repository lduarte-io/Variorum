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
| R3-m1 | MINOR — the walk's questions for her have not landed in the record's §5, the only road the closeout carries to her | PENDING | PENDING | PENDING |
| R3-n1 | NIT — the door rule's placeholder exemption (`contains("prompt")`) is broader than the class it states | PENDING | PENDING | PENDING |
| R3-n2 | NIT — process: the walk driver's untracked copy sat in the tree at the round's start (the walk's own build) | PENDING | PENDING | PENDING |

### 2a. The implementer's answers

PENDING.

### 2b. The reviewer's final calls

PENDING.

## 3. What this round did not read

The last mobile run's merge had not landed when this round read the tree. Its join into this branch (three
files: `.gitignore`, `MobileSettingsView.swift`, `VariorumMobileApp.swift`, by that run's own map) enters after
this round and is read on its own — a narrow cold pass, or the orchestrator's line-by-line check against the
map if the join is a handful of lines; the record says which. The targeted suites, the re-capture and the merge
gate's whole targets run on the tree that holds it.
