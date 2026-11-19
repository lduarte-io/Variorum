# VM-47 — the ladder, round 2 (the whole run's diff, after the VM-55 re-land and R-47-3)

**Run record: `notes/plans/vm-47-sizes-and-look.md`.** Reviewer: a fresh `fable-reviewer`,
`notes/REVIEW_PROMPT.md` verbatim with zero framing, 2026-11-19, started 15:10 on the tree at `138b72658`
(code tip `864ef813b`). Why a round 2: round 1 found no MAJOR, so her rule ("up to 5 rounds as long as a major
is found") earned none; this round was taken because the re-land of VM-55 (batch 6), the round-1 fix pass and
R-47-3's word entered after round 1 read the tree. One machine note reached the reviewer mid-read, from the
stage coordinator's QUIET window (another run's merge gate): no build or test run until the window ends — so
nothing was run, and the runs it would have used are listed in its report as owed evidence. The run's one walk
had not run when this round read the tree: whatever the walk fixes enters after it and is read separately (§3).
Tally: **0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT.** No MAJOR, so no further round is earned by her rule.

## 1. The reviewer's report (verbatim)

VM-47 cold review — ladder ROUND 2 (the whole run's diff vs origin/main at eb18888db; HEAD 138b72658 — the VM-55 re-land, the R1 fix pass and R-47-3 are this round's new ground; the midway and round-1 findings re-checked, not re-litigated). Read-only throughout; the coordinator's QUIET window was in force, so no build or test ran — run-verification owed is listed under "owed evidence". Tally: **0 BLOCKER · 0 MAJOR · 0 MINOR · 2 NIT.** This message should land repo-first as `notes/plans/vm-47-ladder-round2.md` (the round-1 convention).

### Prior rounds' fixes, re-checked (round 2's standing duty)

- **Midway M-1 (the 13 pt floor in `PhoneType.uiFont`)** — still applied as confirmed: the floor sits after `scaledUIFont` so it covers BOTH scaling branches (`App/Variorum/Shared/Theme/PhoneType.swift:347–355`), returning `baseUIFont(spec, voice:, pointSize: floorSize)`; the pin `theUIKitFormIsNeverBelowThirteenPointsEither` exists (`MobilePhoneLayerTests.swift:108`) beside `nothingIsEverBelowThirteenPoints` (:88); red-on-old was proven in the snapshot (20 issues, ladder-midway §3). m-1/m-2 comment edits present (`MobileEditorStyle.swift:316–320` launch-time wording naming VM-137; `PhoneSegmentedChoice`'s refusing-site sentence, `PhoneControls.swift:555–558`).
- **R1-m1 / R1-n1 (the two confirmed doc sentences, `dc55d1a3b`)** — landed word-for-word as §2a gave them: `MobileShellRouter.bindTheme`'s doc comment carries the per-session-bind / per-shell-start coupling and the key-the-shell remedy; `MobileRootMenu.items(settings:)` carries "An item's word is its identity… must be distinct". Comments only, no code — as confirmed.
- **R1.3 (the VM-27 pin's harness, test-only)** — verified in `MobileSettingsProtectionDoorTests.swift`: the outer scope binds an in-memory FENCE (`$0.database = fence`, :74–77), the chain runs inside `$0.database = session.database` (:98–99), and the outbox-count guard proves the round read THIS library (a planted note; `pendingPushCount == counted`, :123–126). No production line.
- **R1.5 (VM-27 red-on-old)** — PROVEN per the record (green on `vm47-b5` at `0f167176f`; red on the re-made snapshot with ONLY `MobileSettingsView.swift:251` reverted — both cases at `MobileSettingsProtectionDoorTests.swift:139` `doors.count == 1`, no host crash). The fix line `.environment(\.protectionPaneDoor, nil)` is in place at `MobileSettingsView.swift:251` with the standing row on the same `protectionDoor` gate, so no state loses its one door.

### Findings

**[NIT] · `App/Variorum/VariorumMobile/Features/Shell/MobileShellView.swift` (`listBar(owner)`: `onAppear`/`onDisappear` increments) · The per-stack bar count is unclamped — an unbalanced `onDisappear` would drive `listBarsShowing[owner]` negative and a later appear would read 0 while a bar IS on screen, leaving the one message line under the bar's doors on a pushed list.** SPECULATIVE: I could not construct a reachable sequence (SwiftUI's known imbalance quirks duplicate appears rather than drop them; the push-over/pop/Versions-reader roads are all pinned green by `theMessageLineClearsTheBarWhereverABarIsOnScreen`), so no red-on-old pin exists and a fix would be hollow by the protocol. Disposition wanted: nothing, or a one-character hardening (`max(0, …)` on the decrement) folded into that file's next touch, with batch 6's self-assessment risk 1 as the pointer.

**[NIT] · `App/Variorum/VariorumMobileTests/MobileMessageLineFaceTests.swift:78–83` · The face pin's bounds are tight against font metrics** — `door.height <= 44.5` and foot-within-0.5 depend on SF's 15 pt ascent landing the `firstTextBaseline` alignment of a centered-in-44 act within half a point of the words' padded baseline. True today (the pin ran green in the whole-phone window, row 6.9) and the traced arithmetic works out (≈1 pt baseline offset absorbed by the stack's 44 pt floor), but an iOS point release that moves SF's metrics could flake it the way the batch-1 1/3-pt hold did. No action owed now — listed so the per-release re-verify habit (TEXTKIT2_NOTES §5's class) knows this pin is metrics-coupled.

### The re-land and R-47-3, verified in depth (this round's new ground — all solid)

- **VM-55 preserved**: zero-line diffs vs main on VM-55's `Shared/` brains (`StatusCenter`, `WingState`, `WingsModel`, `WingSwitcherBrain`, `WingWords`, `MobileLine`, `MobileWing`); the 23 conflict files' net diffs carry drawing-layer changes only (roles, phone inks, controls, grounds, hit areas) — no behavior, word, class or timing of VM-55's changed except R-47-3's ruled word. `MobileMessageLine`: `footOffset`/`takesTouch`/scene-edge machinery byte-level untouched; the act's `doorFrame` still covers the whole target because `phoneHitArea` GROWS the layout frame to ≥44×44 (`PhoneMetrics.swift:107–113`) and `onGeometryChange` measures the styled button — so the 44 pt hit-area claim holds inside the passthrough window, not just in accessibility.
- **Meeting 1 (path lines)**: the negative-padding hand-back and `MobileWingDoorMetrics`' 14/6 paddings removed with the layout they named; the door is the line's own 44 (`MobileWingPath` → `.phoneHitArea(alignment: .leading)`, `lineLimit(1)`); VM-55's geometry pins hold the rule, unmoved; the new `theBookcaseLineWithItsWingDoorHoldsOneLineAndEveryTarget` ran green (row 6.9).
- **Meeting 2 (bar + line)**: the measurement re-attached to `MobileTabBar`; the lift keyed to `barOnScreen` (`pagingAllowed || listBarsShowing[tab] > 0`) — reads only the VISIBLE tab's count, so the opacity-hidden stacks and the P-55-14 Protection edge cannot mislead it (traced). Pinned end-to-end through the shell's host probe, red on the old roots-only rule by construction.
- **Meeting 3 + R-47-3**: the one word at the one call site (`MobileShelfView.swift` `page: "Bookcase"`); the five pin moves each state the ruling as the reason; the new literal pin (`MobilePathLineGeometryTests:70` + the R-47-3 prefix assertion) is red on the old word by construction; the "every other shelf the phone draws or speaks" sweep in §6 is thorough and honest (I re-checked `MobileTabBar.word`, `MobileEmptyStoreCopy`, the pin-door words, the refusal sentences' shelf-row sense). The accessibility value reads "Bookcase  ·  N books" as recorded.
- **Meeting 4 (wing landing)**: `selectPage(.shelf)` touches no stack; P-47-19's pop-the-leaving-stack keeps every hidden stack at its root; the joint invariant pinned by `aWingLandingAfterAListWasLeftShowsTheBookcaseItself` (mounted, Trash-left-behind case). The recorded exception (a standing shell's Protection adoption) is owned (VM-110/VM-80).
- **Faces on the layer**: the three source scans' before/after table matches my own greps — zero `tokens.small/body/title/heading/mono`, zero direct `tokens.muted/faint`, zero sub-13 literals in the phone tree outside the named exceptions. `PhoneInlineActStyle`'s `weight:` is additive (nil keeps the role's); `tabSelected`'s pop-then-select and `popToRoot`'s transaction discipline are sound.

### Clean bill (checked myself this round)

- **The Mac cannot have changed**: `VoiceTokens.swift` zero-line diff over the whole run; `Sources/` and `Server/` zero-line diffs; the only Mac-target source change is `Theme/AppearanceChoice.swift` losing exactly the declarations that moved byte-for-byte to `Shared/Theme/AppearanceChoiceRule.swift` (the AppKit half kept as an extension); the `ThemeStore` hoist's only deltas are the two additive members (`onLanded`, `placeholder:` defaulting to the Mac's) and the `#if os(macOS)` fence around the two Mac-only adoptions; `SyncStatusViews`/`SharedPageStyle` changes sit entirely in the styled (phone) arms with the nil arms untouched; the targeted 114-type Mac leg ran green on the re-landed tree (row 6.10).
- **The editor seam held**: `MobileEditorTextView.swift` diff vs main is EXACTLY the one authorized line (`backgroundColor = face.room` → `face.paper`, :989); `MobileEditorViewModel.swift` and `Shared/EditorBrain/` have zero-line diffs vs main; `Face.paper` is a name for the existing `surface` slot — no second truth; `MobileEditorStyle` has ONE app writer (`adopt`), main-actor state, the palette face built once per landing.
- **Her rulings as worded**: R-47-1 (grounds — I verified the `tokens.surface` background lines on the Shelf/Library/Starred list regions, Write's screen+masthead+editor, Book contents, Trash, Archive, Versions; Read's voice-own room per R-13u-10; bars/sheets on the room); R-47-2 (the voice choice writes the LIBRARY's voice through `ThemeStore.setVoice` → `Operations.setThemeVoice`, the runner road — S1-shaped); R-47-3 (built exactly as ruled, nothing renamed); LK-1/LK-2 (voice+palette synced via the hoisted store; light/dark a local `UserDefaults` preference that never touches the `setting` table, inert under a test host via `Launch.thisProcess` — traced to `AppBootstrap.swift:114–117`); LK-5/SW-1/LK-6 (the bar's words, chip, 56 pt targets, Bookcase, voice-cased chrome with plain spoken labels).
- **VM-27, VM-54, VM-51 mechanisms**: all re-verified against the code as the prior rounds recorded them (the one Protection door; `MobileTraitBorder`'s weak-view/lazy-owner trait re-resolution at all four sites; the ONE settings→tokens road with the placeholder equal to an empty library's read).
- **P1/cost**: the type cache is bounded per role·voice·category; theme observation is the tiny setting table; the bar measures three words per layout; the ink rule's palette iteration is the test oracle only (shipped values are constants). Nothing corpus-proportional, nothing word-level, no text copied across entities.
- **Process**: no commit trailers over the run's 130 commits; worktree clean; `notes/plans/vm-47-screens/` gitignored; no history rewrites; shared ledgers untouched on the branch; no `Sync/`, custody or schema lines anywhere. No plan-time "Review foci" section exists (re-checked); the batch self-assessments' risk lists stand addressed (batch 6's four risks each traced above).
- **Copy**: the net string-literal diff vs main matches batch 5's declared list (Appearance words, group names, "More") plus R-47-3's ruled word; retired strings ("Sync" group, the trace button's words, "Manage Tags" label superseded by the row's door title) are batch 5's declared retirements.

### Owed evidence the record already owns (not findings — the closeout gates on these; "to verify by run" under the QUIET window)

1. **The R-47-3 pin set has NEVER EXECUTED** (built only): the moved `MobilePathLineGeometryTests`, `MobileRootMenuTests`, `MobileWingDoorTests`/`MobileWingDoorGeometryTests`/`MobileWingDoorShellTests`, `MobileWingsTests` and the new literal pin post-date row 6.9's whole-phone run (which ran at `b20b04fad`, before `50635a674`). The record says PENDING honestly; a short stage window owes their green before closeout. By construction they should pass (the path text is the HStack's most flexible member, so the deficit truncates it, not the doors' words — the same mechanism row 6.9 already proved at Terminal 402), but construction is not a run.
2. The run's ONE walk (parts A and B, the fresh reader, W.7's narrow fixes) — the first eyes on the two runs together and on P-47-27's truncation (now also at Study's 402 edge per R-47-3 — correctly folded into §5 for her).
3. The whole Mac target on the re-landed tree (the merge gate's leg).
4. Closeout duties: FOR A LATER READER, canon deltas, tickets, the §5 PROVISIONAL bundle for her sitting (P-47-1, -27 and the rest), the rulings-reconciled pass.

**Recommended disposition**: both NITs need at most a line at the named owners; nothing goes to `notes/QUESTIONS.md` (no finding turns on undefined product behavior); nothing is FINDER-FIXES. **No MAJOR found — under her five-round rule no further round is earned**, subject to the owed evidence above coming back as the record expects; a red in the unrun R-47-3 pin window or the walk re-opens as its own trace, not as this round's.

## 2. Dispositions

| Id | Finding | The implementer (§2a) | The reviewer's final call (§2b) | What changed |
|---|---|---|---|---|
| R2-n1 | NIT, SPECULATIVE — `MobileShellView.listBar(owner)`: the per-stack bar count is unclamped | **AGREE** — hollow. No reachable sequence gives a list's bar a disappear without its appear: every road traced pairs them, and the known SwiftUI imbalances push the count UP. The cited pin is narrower than the finding says — it reads a root, the pushed Trash and a note opened from the root; it never pushes a note over a list and never opens the Versions reader — and it could not see a negative count. A clamp does nothing on every balanced sequence, and no pin can be red on today's code. ⇒ change nothing, now or at a next touch; pointer: batch 6's self-assessment risk 1 (§2a) | PENDING | PENDING |
| R2-n2 | NIT — `MobileMessageLineFaceTests.swift:78–83`: the face pin's bounds are tight against font metrics | **AGREE**, no action — with the mechanism corrected (§2a). `door.height <= 44.5` is tied to the hit-area helper's 44, not to fonts. The foot check is tied to one line's HEIGHT (the ascent cancels) and reds past ≈ 21 pt. It has a second coupling: the standing device's text size (chrome scales up to xxxLarge). A red would mean the line really outgrew its 44, so the bound is never loosened. If a note goes anywhere, it is one sentence on the pin's doc comment (§2a gives it), not TEXTKIT2_NOTES or MobileSoul | PENDING | PENDING |

### 2a. The implementer's answers

The findings reached the implementer (Opus, 2026-11-19) verbatim. Its agree/dispute is below, for this reviewer's
final call. Nothing changed for this step: no code, no test, no build, no test run (the QUIET window).

**R2-n1 (NIT, SPECULATIVE) — AGREE: hollow, and nothing to change.**
- *How the count is built.* It has one reader and two writers. The reader is `barOnScreen` (`MobileShellView.swift:427–429`,
  `pagingAllowed || (listBarsShowing[tab] ?? 0) > 0`), which hands the line its lift (:313–314). The writers are the
  two closures of `listBar(owner)` (:686–690): +1 in the bar's `onAppear`, −1 in its `onDisappear`. Four places draw a
  counted bar: the book's contents (:539), the Trash (:560), the Archive (:565) and the Versions listing (:574, drawn
  under `if model.reading == nil` at `MobileVersions.swift:349–351`). A root draws the uncounted `tabBar`, and
  `pagingAllowed` covers it. The count is kept per owning stack and read only for the visible one, so a hidden
  stack's count cannot mislead it.
- *Every road I could trace pairs each −1 with an earlier +1 of the same bar:*
  - a list pushed (+1);
  - a note pushed over it (−1), then popped back (+1);
  - the list popped (−1), by Back, the swipe, `pop(in:)` (:655–661) or `popToRoot` (:719–729). This holds animated
    or not: a pop straight to the root removes the lists it covered without appearing them, and each had already
    paid its −1 when it was covered;
  - the Versions listing becoming the reader and back (−1 / +1, the `if`);
  - Protection replacing the shelf's path wholesale (:609), which pays −1 for a list on top;
  - the shell leaving the tree (a lock, a reopen), which takes its `@State` with it, so no count carries across.

  To go negative, a bar must receive an `onDisappear` with no `onAppear` before it. I cannot construct that sequence,
  and I know of no SwiftUI behaviour that produces it. The known imbalances run the other way: a doubled `onAppear`,
  or an appear when an interactive back-swipe starts that a cancel does not undo. Both push the count UP.
- *A correction to the coverage the finding cites.* `theMessageLineClearsTheBarWhereverABarIsOnScreen`
  (`MobileTabBarTests.swift:349–380`) reads the lift in three states: a root, the pushed Trash, and a note opened from
  the root after the tab popped the Trash. It never pushes a note OVER a list, and it never opens the Versions reader.
  No other pin reads `chromeInset` on those two roads: `insideANoteTheBarIsGoneAndTheVersionsListingWearsIt` (:302)
  checks that the listing draws the bar, not where the line sits. On the road the pin does drive, it could not see a
  negative count. An extra −1 on the Trash would leave −1, and the next state it reads is a note, where −1 and 0 both
  read "no bar". The pin can only go red in the UP direction, at :377 (a note left lifted). That is batch 6's risk 1,
  which names the missed disappear as the failure (run record §6, "Batch 6 — results", the self-assessment).
- *What a clamp would buy* (`max(0, …)` on the decrement). On every balanced sequence, nothing: the decrement meets
  zero only when disappears outnumber appears. On an unbalanced one, it limits the damage to the moment of the
  unmatched −1. If the stray disappear came while a bar was still showing, the line would still sit over that bar
  until the bar's real disappear. After that, the clamp keeps the count from staying one short, so later pairs read
  true again. Against the UP direction it buys nothing.
- *The guard.* Nothing reachable produces the state, so no pin through the shell can be red on today's code. A test
  that called the closures with an extra disappear would pin the arithmetic against an input the app does not
  produce. It would be green on both sides of every real road. By the hallucination guard the finding is hollow:
  record it, don't fix it. I would change nothing, now or as a fold-in at that file's next touch, which would be the
  same unlicensed change made later. The pointer stays batch 6's risk 1. If a run or a walk ever shows the line over a
  list's bar, or lifted inside a note, it opens as its own trace, and the pin then follows the sequence that was found.

**R2-n2 (NIT) — AGREE: no action. The coupling is real, but not quite as the finding words it, and one more sits
beside it.**
- *The bounds, as cited.* `:78` `door.width >= 43.5 && door.height >= 43.5`, `:80` `door.height <= 44.5`, `:81–83`
  `abs(door.maxY - foot) <= 0.5` with `foot = window.bounds.maxY - 34 - 56`. The lines are as the finding gives them.
- *The geometry, traced* (`MobileMessageLine.swift:153–192`).
  - The parts:
    - The line is an `HStack(alignment: .firstTextBaseline, spacing: 12)` (:154).
    - The words are `controlInline`, padded 12 above and below (:157, :163).
    - The act is `PhoneInlineActStyle(weight: .semibold)` (:174). Its label wears `phoneHitArea`
      (`PhoneControls.swift:183–189`): a frame at least 44 × 44, the word centred in it (`PhoneMetrics.swift:107–113`).
    - The stack sits in a frame at least 44 tall (:185), and its foot is placed by `footOffset`, here 34 + 56 above
      the window's foot (:93–95, :132–135).
  - Both texts are the same chrome face at the same size: SF in Study, SF Mono in Terminal
    (`PhoneType.swift:177–179, 311–314`). With their baselines aligned, the ascent cancels, to the extent the two
    weights share vertical metrics.
  - Call h the drawn height of one line of words. The words' column then sits (20 − h)/2 below the act's top, where
    20 is the act's 44 less the words' 12 + 12.
  - SwiftUI's `lineSpacing` goes between lines, so one line draws at the font's own height: h ≈ 18 for SF 15. (If a
    single line drew the role's spacing too, h would be ≈ 20 and the slack ≈ 1 pt — still green in row 6.9.) The
    column then runs from about 1 pt to about 43 pt inside the act's 0–44. The stack is the act's 44, and the door's
    foot IS the line's foot — exactly, not within half a point. The half point only absorbs pixel rounding.
- *What each bound depends on.*
  - `door.height <= 44.5` is tied to the hit-area helper's 44, not to font metrics: the door is `max(44, h)`, and h
    is nowhere near 44.
  - The foot check is the font-coupled one, but through the line's HEIGHT, not its ascent. Once h passes 20, the
    column outgrows the act by (h − 20)/2 at each end and the act's foot rises off the line's, so the check reds past
    h ≈ 21. At the default text size that is about 3 pt of slack in the line height, more than "within half a
    point", and an iOS point release is an unlikely way to cross it.
- *A coupling the finding does not name: the device's text size.* The chrome roles follow the text size up to
  xxxLarge (`PhoneType.swift:72–79`; `PhoneTypeModifier` reads `\.dynamicTypeSize`, :463, :479). The pin sets no text
  size, so it reads the standing device's setting. At the larger sizes, one line of 15 pt chrome scaled up passes
  ≈ 21 pt and the foot check reds. That needs no OS change, and the red would be correct, because the line really is
  taller than 44 then. What keeps the standing device at the default today is this run's own rule (§2, "Evidence a
  batch closes on": walks run on a dedicated device created and deleted inside the walk's claim, "so the shared
  suite device keeps its settings").
- *A red here would be information, not a flake.* The bound states the sizing sheet's own claim, "one line 44 tall".
  If the faces' metrics or the text size make one line of words taller than that, the claim is false and the pin
  should say so. The batch-1 precedent the finding cites agrees: the 1/3 pt hold (run record §6, Batch 1, item 2)
  was a real defect a tight bound caught (`4ec664f2b`), not a flake. So the bound is never loosened.
- *Whether a note belongs in the repo, and where.* Not in `notes/TEXTKIT2_NOTES.md` §5: that matrix is the Mac
  editor core's TextKit 2 checks, and this pin is neither. Not in `notes/MobileSoul.md`: it is canon, and its
  per-release line names the TK2 spike. If a note goes anywhere, it belongs on the pin itself, where a red is met:
  one sentence, comment only, in `theLinesActAnswersAcrossFortyFourOnAFortyFourLine`'s doc comment — *"The foot
  check is metrics-coupled: it holds while one line of the 15 pt chrome face is at most about 21 pt tall (the act's
  44 less the words' 12 above and below, plus the tolerance) — so a red after an iOS update, or on a device left at a
  larger text size, means one line of words outgrew the 44 pt line: look at the line, never loosen the bound (VM-47
  ladder round 2, R2-n2)."* The alternative is nothing, since this file already carries the trace. Either is
  defensible. I lean to the sentence, because a later reader meets the red at the test, not here. The reviewer
  decides.

### 2b. The reviewer's final calls

PENDING.

## 3. What this round did not read

The run's one walk had not run when this round read the tree. Any fix the walk leads to enters after this round;
each is read on its own — a narrow cold pass where a fix carries logic, the orchestrator's line-by-line check
against the walk's finding where it is a value or a ground — and the record says which, fix by fix.
