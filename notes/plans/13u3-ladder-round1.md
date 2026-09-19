# 13u3 LADDER — ROUND 1 (fable-reviewer, cold, 2026-09-19)

**Diff under review:** `98696c81..HEAD` (93 commits — units A1 · A2 · B · C · D · E · F · G · H plus
orchestrator adjudications; 99 files, ~10.2k production+test insertions outside `notes/`).
**Anchor:** `notes/plans/phase-13u3-faces.md` (GOVERNANCE, R-13u3-1…6, the nine unit records, the
ledger — row 9's named foci: UNIT B's one-time editor SPIN on deleteBackward; A1's geometry across
the five host cells). Prompt: `notes/REVIEW_PROMPT.md` verbatim. Read cold: the plan file whole,
every production file the diff touches (the editor seam files line by line), the new core files
whole (`ProseGutter`, `NoteCardFace`, `SavepointName`, `PostRender`'s additions, `RestoreCost`,
`CaptureTextView`, `SavepointNameField`, `MarkdownReadingFace`, `TakeCardMenu`,
`CommentComposition`), the pins named by the records where a claim rode on them, and QUESTIONS /
KnownIssues deltas. Targeted verification run: the phase's five new/extended core suites
(`SavepointNameTests` · `PostRenderQueryTests` · `RestoreCostTests` · `NoteCardFaceTests` ·
`SnippetsAndPickerQueryTests`) — **71 tests in 5 suites, all green** (no full suite run at review
start, per the standing rule).

**STATUS: COMPLETE.**

---

## FINDINGS (severity-ranked)

### R1-1 · [MAJOR] · `EditorViewModel.swift:1279 → :3336–3337 → :3553–3556` (entry at `EditorView.swift:665–676`) · the decoration refresh can force TK2 layout estimation SYNCHRONOUSLY inside `NSTextStorage.processEditing` — the row-9 focus, ruled REAL

**This is the named focus (UNIT B's one-time editor spin), and the mechanism is real, pre-existing,
and worth closing in this ladder.** The chain, traced in the current code: `deleteBackward:` →
`processEditing` → the storage delegate's `didProcessEditing` (`EditorSurfaceDelegate`,
`EditorView.swift:665–676`, `MainActor.assumeIsolated`) → `storageDidEdit`
(`EditorViewModel.swift:1170`) → `updateCaretContext()` (`:1279`) → **when
`appearance.indicator != .off` and the caret changed blocks** (`:3336`) → `refreshDecorations()`
(`:3337`) → `offsetAt(y:)` (`:3553`) → `NSTextLayoutManager.textLayoutFragment(for:)` — a
layout-FORCING geometry query against storage whose edit has not been laid out yet. That is
TEXTKIT2_NOTES §2's own class (estimation from inside the edit transaction), and UNIT B's `sample`
caught it for real: **1,839 of 1,839 samples in
`ensureLayoutForBounds:` → `_estimatedTextLocationForVerticalOffset:` at 99 % CPU** — a permanent
whole-app spin from an ordinary keystroke. A `deleteBackward` that removes a block's first
character (or crosses a seam) moves `caretBlockID`, so the arm is reachable from plain typing
whenever the editing indicator is on.

**The synchronous call is REDUNDANT on exactly the dangerous path.** For every storage edit the
model already schedules a post-layout decoration refresh: `storageDidEdit` bumps
`overlayGeometryGeneration` (`:1176`), and `overlayLayoutDidSettle` (armed from `viewWillDraw`)
delivers `refreshBadges()` → `defer { refreshDecorations() }` on the next runloop turn, against
honest frames — N14's whole design. So the in-transaction `refreshDecorations()` buys one turn of
indicator latency (a latency every other edit-driven decoration already has) at the price of a
documented TK2 estimation hazard.

**Fix shape:** in `updateCaretContext`, do not run `refreshDecorations()` synchronously when the
call is reached from `storageDidEdit` (the caret-block-changed indicator refresh rides the settle
hop that the same edit has already armed; the selection-change path with no edit — arrow keys —
may keep the synchronous call or take the same hop). One flag or parameter; no geometry changes.

**Hallucination-guard status:** no red-on-old pin can honestly reproduce a once-seen OS-internal
estimation loop — this is an ARCHITECTURAL finding under the guard's second clause: mechanism
traced above (the sample's frames + the live code path), the degradation is a real whole-app hang
met in a real walk, and the justification is TEXTKIT2 §2 plus the fact that the model's own settle
machinery exists precisely to keep geometry reads out of the edit transaction. What CAN be pinned,
if the fix wants a pin: a DEBUG cell asserting no layout-forcing fragment query runs while
`storageDidEdit` is on the stack (a scoped counter — fails on the current code by construction,
green after). Pre-existing mechanism (13 C1/R14-era — NOT this phase's regression; A1's rework did
not widen it: `needsFrames`' arms and the call sites are unchanged), so MAJOR, not BLOCKER.

### R1-2 · [MINOR] · `Sources/VariorumCore/Operations/Operations+Variant.swift:100–110 (`renameCommitPoint`)` · the no-op guard runs BEFORE the seal/liveness guards — drifting from the `setTakeLabel` convention the op's own doc claims to follow "to the letter"

**Mechanism:** `guard commitPoint.message != normalized else { return }` sits above
`liveVariant(db,…)` and `ensurePlacementUnlocked(db,…)`. `setTakeLabel` (`:418–427`, the named
precedent) does the opposite: live-variant + seal first, no-op second. Consequences, both
reachable from the shipped face:

- `renameCommitPoint(sameName)` under a **SEALED post returns silent success** where
  `setTakeLabel(sameLabel)` under the same seal throws `lockedPost`. In Block History on a sealed
  note, opening the rename door (it is offered — the pane does not gate it on the seal) and
  pressing ⏎ with the seed UNEDITED makes `BlockHistoryModel.rename` speak the RECEIPT *"Saved
  moment named "…"."* — a receipt under a seal — while the same door with one character changed
  refuses with the seal sentence. One door, two answers under one seal, decided by whether she
  touched the text (18i's grammar strains: the unchanged-⏎ act wrote nothing).
- Same-name rename of a savepoint on a TOMBSTONED take silently succeeds where the op's documented
  contract ("a savepoint whose take is tombstoned refuses, `variantNotFound`") throws.

**Fix:** move the no-op guard below the two fetch/guard lines (three lines, matching the
convention). **Red-on-old pin:** sealed post + unchanged-name rename `#expect(throws:
.lockedPost)` — fails on the pre-fix code (returns), passes after. The core suite's existing
`aSealedPostRefusesRenaming` cell only covers a CHANGED name, which is why this passed.

### R1-3 · [MINOR] · `EditorViewModel.swift:3066–3072 (`askSavepointName`)` · ⌘S on a SEALED note now opens a name field over a gesture that cannot file — a P-2 regression this phase introduced at exactly one of its five doors

**Mechanism:** the door's only guard is `caretVariantID != nil`. On a sealed note the projection
still carries entries, so the chord/menu road (`commitCaretVariant` → `askSavepointName`; the
bar's button is separately disabled via `header?.locked`) opens the popover, she can type a name,
and the refusal (`lockedPost`, worded) arrives only after ⏎ — where the SHIPPED road refused
instantly at the keypress (`commitCaret` → op throws → spoken). UNIT D's own pin
(`theDoorRefusesBeforeItOpensAFieldItCannotFile`) states the principle but covers only the
open-tail/no-caret state; the unit's other ask-doors (Takes `askSavepointName` guards
`focusedPane`; Canvas/Compare guard `authority.livePane`) each refuse before opening the field in
their unfileable state — the Write editor's seal state is the one missed cell.

**Fix:** one guard in `askSavepointName` — refuse with the seal's sentence when
`header?.locked == true` (the same fact the bar's disable reads), before setting `savepointAsk`.
**Red-on-old pin:** sealed note → `askSavepointName()` → `#expect(savepointAsk == nil)` + a
refusal spoken — fails on the current code (the field opens), passes after.

### R1-4 · [NIT] · `App/Variorum/Variorum/Registry/OpsRefusalCopy.swift` · `commitNotFound` and `variantNotFound` still fall to the `default:` enum dump — and UNIT D's rename door is the first face that can (rarely) surface them

**Mechanism:** `renameCommitPoint`'s two documented "honest throws" (`commitNotFound` when the
savepoint vanished under the open ask; `variantNotFound` when its take was tombstoned mid-ask —
e.g. a sync apply landing between opening Block History and pressing ⏎) route through
`BlockHistoryModel.rename` → `TrayRefusalCopy.message(for:)` → `OpsRefusalCopy.message(for:)`,
where neither has a case — so the pane would print `Refused: commitNotFound(id: "…")`, the exact
class UNIT H just closed for `variantIsChosen`. Race-only reachability (the pane lists live takes'
savepoints and refreshes on observation), hence NIT rather than H's shape. **Fix:** two worded
cases. Red-on-old: a copy-table cell on each — fails on old (dump), passes after.

### R1-5 · [NIT] · `EditorSurfaceController.swift:743–747 (doc) + `MergeArrangement.swift:196–204`` · the `displayed:` parameter's comment overstates what it binds on the run sheet's "Only the shown ones" road

**Mechanism (doc-truth, not behavior):** `runMergeChain(displayed:)`'s comment says *"the SHEET
passes the ids its list marks … so what she was shown is what joins"* — true of the CARRY-ALL road
(`CarryAllMerge.compose` consumes `displayed`), but the PLAIN road (`bringEveryTake: false`) calls
`ops.merge(mergedID, next)`, which resolves each side from the store's chosen at op time and never
reads `displayed`. The promise is in fact made true for the plain road by the NEW drift check
(`refreshMergeRunIfDrifted` compares the list's whole rows against a fresh store read on every
confirm, and `renderedVariantID`'s equivalence with `Operations.renderedVariant` is pinned) —
modulo the recorded sub-ms confirm-to-transaction window, which is the standing
honestly-unpinnable class. Nothing wrong lands; but a future reader could move or weaken the drift
check believing `displayed` still fences the plain road. **Fix:** one sentence at the parameter
(and/or the record's "The list's ids are the merge's `displayed`" line) naming the plain road's
actual protection. Clarity class — no pin owed.

### R1-6 · [NIT · SPECULATIVE] · `Core/Views/TitleSuggestionChip.swift` + `CaptureTextView.focusRequest` · the acceptance walk's "first ⏎ after adopting the chip did not file" has one cheap structural hardening even though the mechanism is unconfirmed

The orchestrator's walk note (a) asked the ladder for a mechanism. What the code shows: adopting
the chip (`onToggle` → `titleFromFirstWords.toggle()`) does nothing about key focus — if the
button click (or anything else in that moment) moves first responder off the `CaptureNSTextView`,
⏎ dispatches to whatever holds keys and `CaptureKeys` never sees it; nothing bumps `focusRequest`,
so the box does not re-take the caret until she clicks it. I could NOT confirm that a SwiftUI
Button click steals first responder on this window (macOS buttons ordinarily refuse it, and the
walk could not reproduce the miss), so per the prompt this is **SPECULATIVE** — but the hardening
is one line that is also the right UX: adopting the chip bumps `focusRequest` (the caret returns
to the words she is naming), which closes the candidate mechanism whether or not it was the
walk's. If built, it is not bug-class (no honest red) — a decision cell, not a pin.

---

## THE NAMED FOCI (ledger row 9) — dispositions

1. **UNIT B's one-time editor SPIN on deleteBackward → REAL, mechanism confirmed, finding R1-1
   (MAJOR).** The frames in the UNIT B RECORD line up exactly with the live code path; the
   trigger arm is the indicator-follows-caret refresh run synchronously inside the storage-edit
   transaction; the fix is to route it through the settle hop the same edit already armed.
   Pre-existing (13-era), not widened by this phase's diff.
2. **A1's geometry across the five host cells → CLEAN, verified by derivation against the code.**
   I re-derived every cell of the host table from `ProseGutter.insets` + each host's bleed:
   - cells 1/2 (Outline, `bleed = max(20,(W−696)/2)`, slot `C = min(W−40, 696)`): frame `= W` at
     every pane width; for `W ≥ 736` left `= (W−680)/2` (the new `.rounded(.down)` differs from
     the old exact value by < 1 pt at odd widths — Write's own recorded odd-width note, and the
     MEASURE is exactly 680 in both, so `BookHeightManifest` learns nothing); for `W < 736` both
     read `28 · W−56` exactly.
   - cell 3 (spread page, `.page`, bleed 20): leading anchored at 28, measure `min(W−56, 680)` —
     byte-identical.
   - cells 4/5 (workspace pane / note window, `.pane`, bleed 20): centring a no-cap column
     degenerates to leading = trailing = 28, measure `W−56` — byte-identical, and the un-capped
     measure is correctly left as QUESTIONS #117 rather than silently narrowed.
   - Write (`.write`, bleed 0): `gutterInset` forwards to the same rule; the odd-point goes to the
     trailing gutter (container exactly 680 where it was 681 — recorded).
   The mean-inset + `textContainerOrigin` override arithmetic is exact (`container width =
   bounds − 2·mean = column`); the placement is change-gated; the zero-width mount keeps the
   factory inset (no flash); `PaneTextView.layout()` correctly dispatches measure-change
   (`onWidthChange` → remeasure) vs gutter-move (`onGutterChange` → badges+decor, no layout); the
   inline editor's equivalent road is `onWidthReflow` → generation bump → settle hop, and any
   gutter change there necessarily moves the frame, so no uncovered case exists. The decoration
   side honors the one law structurally (no write door left; every face yields via `gutterRoom`;
   the no-gutter-no-face consequence is recorded with its surviving doors). The
   `theProseColumnIsAPureFunctionOfTheSurfacesWidth` / production-loop pins hold the cells.

---

## CLEAN BILL (load-bearing things checked and found solid)

1. **The fences held**: zero `Sources/VariorumCore/Sync/`, zero `Persistence/`, zero schema, zero
   migrations, zero `Server/` in the whole `98696c81..HEAD` diff (verified from the diff's file
   list, not the records); the marker stays 8. `RestoreCost`'s mirrored purge predicate is the one
   deliberate near-Sync copy, and it is honestly recorded and held by the
   `theSetAsideReadAgreesWithThePurgeFamilyItMirrors` equality pin — the right call for a faces
   batch under the Fable rider.
2. **UNIT G's drift family** (`MergeRunBlock.shownVariantID` in the same store read as the fans;
   the `if !state.isRun` fence retired; `prePairing` one function at open AND refresh with hers
   kept under `.pairByHand`; `liveActiveFansAndRendered` at open) — each matches the 18f round-3
   fix shapes verbatim; `runFansAndRendered` is genuinely ONE snapshot for open and check.
3. **`Queries.renderedVariantIDs` / `renderedTakeJoinSQL`** — the resolution is `renderPost`'s
   verbatim (chosen-if-live-active-and-same-block, else default-if-live); the turned-around
   traversal rides `uq_cblock_ownership` so nothing multiplies; unplaced-live-block answers by
   default; gaps are absence; the three-resolver equivalence + EXPLAIN-seek pins exist and the
   five core suites ran green here. `NoteCards.load` and both `notePickerNotes` overloads consume
   it; the kept-own-copy verdicts (renderPost · leadingBlockTexts · blockTakes · PageExtents ·
   word counts · tray/trash default-only reads) are each correct as verdicted.
4. **`renameCommitPoint` / I5** — `commit_point.text` is unreachable from the whole name family;
   no touch/churn/undo; outbox UPDATE capture verified by pin rather than assumed;
   `SavepointName.normalized` is consulted at BOTH write doors (`insertCommit` too) so the two
   roads cannot store differently. (The one guard-order drift is R1-2.)
5. **UNIT D's door plumbing** — one `SavepointNameAsk` value + one field + one popover modifier;
   one binding per host (CommitBar; the sidebar-box placement presents on the prose exactly when
   no bar is mounted — the two-presentations-never-up-at-once switch is real); Canvas/Compare
   anchors are overlays (the 8 pt HStack-spacing regression was caught by the shipped alignment
   pin and the fix is correct); Takes/Lenses share one bar and one model slot; the BlockHistory
   per-row binding cannot raise N popovers.
6. **UNIT C's capture seam** — `CaptureKeys.act` is caret-independent by construction (event in,
   act out; `.paragraph` deliberately not consumed so the newline is AppKit's own at the caret);
   the modifier mask carries the 13d F-2 caps-lock/keypad lesson and is pinned to agree with the
   editor's soft-newline mask rather than reaching into it; TK2 opt-in explicit + canary armed +
   `lineFragmentPadding` zeroed (the walk's pixel-column fix); the pad's clear-only-on-success
   `take()` composes the three triggers without double-minting, keeps mid-flight keystrokes, and
   the refusal now lives ON the pad; the close/quit residue is honestly a KnownIssues row
   (owner 17b) + #120(e), not papered over.
7. **UNIT A2's panel** — the ONE trim rule on both roads (the traced two-rule drift, measured
   red-on-old); drafts on the MODEL with the surviving-drafts rule dropping exactly the echo shape
   and dead comments; `justSaved` bridging the landed-but-not-echoed window; the seal refusal
   keeping the draft; receipts/refusals classed at the door (`RecoveryStatus`); the key monitor
   claims only ⌘⏎ and bare ⎋ and passes everything else through.
8. **UNIT B's brain and consumers** — `NoteCardFace` is pure, grapheme-safe (`cut` walks
   `Character`s; the family-emoji pin exists), bounded at 400 whatever it is handed; the
   precedence (title · journal-day · words · day · Untitled) matches the ruling; journal-ness rides
   `container.profile` (the mint's marker), never "has a date"; `LibraryCardRead.plan` makes the
   List mode's zero-cost-for-named-libraries claim a value a pin holds; drawing a card writes
   nothing (pinned); the `VoicedChip.lines` opt-in correctly scopes the clamp after the landing
   suite caught the shared-chip geometry change; the chip's segments split keeps her prose out of
   `chromeLabel`'s case-folding.
9. **UNIT E** — the probe's mechanism (step 1's copy is every outgoing block's surviving
   descendant via `copyPlacements`' lineage edge, so `joinStrandedOriginals` cannot fire) is
   consistent with the code and pinned at both ends; the confirm counts at ASK time
   (`PendingRestore` carries the cost as a value); the narrowed promise is exactly true; the cost
   read is note-scoped with the corpus-independence pin; the zero-cost confirm is byte-identical.
10. **UNIT F** — the hoist is line-for-line the old `PageComposer` appliers with the two duplicate
    rules collapsed onto `MarkdownFace.headingFont`/`adding` (anti-drift pinned); the page's values
    are unchanged at its call site; the PDF's no-colour posture is genuinely stronger than a
    literal and the absence-walk pins it; the `.md` byte-fence was proved by two real builds'
    SHA-256 match, not only by goldens.
11. **UNIT H** — `TakeCardMenu` is ONE rows list rendered by both surfaces and reported by a
    scoped DEBUG oracle; the per-surface declared⇔rendered pin closes the union-walk blindness the
    record correctly diagnoses; `variantIsChosen` now speaks (guard order in
    `performDeleteVariant` confirmed: chosen before last-active, so the new words meet the
    commonest press); the `SnippetsCopy.moveOutRow` constant is consumed by both renderers and
    quoted by the lesson; the amended "verbatim" pin now reads the constant, which is what
    verbatim should have meant.
12. **Docs discipline** — QUESTIONS #117–#125 all present, lettered, PROVISIONAL, with the live
    marker at #126; KnownIssues rows 42 and 50 RESOLVED in place with the work that resolved them;
    every new row carries an owner (12 · 17b · 17e · 13u4); the UNIT H green-per-commit breach is
    self-recorded with its exact window (`17257f35`…`c86e7f40`), which is the remedy the protocol
    asks for — no history rewritten, nothing re-raised here.
13. **Suite arithmetic** — each unit's finals add up against its predecessor's (2794 → 2810 → 2823
    → 2841 → 2859 → 2864 → 2874 → 2880 → 2889, with D's one-cell hand-count discrepancy
    adjudicated by the zero-removed-`@Test` diff); the two standing reds (row 58's environment
    red; the row-49 load-flake family, joined by `ModeSwitchCarryTests`' top-of-Write arm) were
    adjudicated by the paired protocol with the measurements recorded, including G's six-run
    control on the pre-unit tree.

**Open closeout obligations (row 10's, not findings — listed so they are not lost after the
ladder):** the MOBILE PARITY rows the units hand to the orchestrator (A2's `MobileComments` face ·
C's capture face · D's phone doors beside the free name display · E's shared confirm halves; F/G/H
owe nothing); the re-seed list (E's lesson + H's three lesson texts — one re-seed covers both);
the SyncSpec §6 one-line annotation under R-13u3-1 the D brief assigns to the closeout.

## VERDICT

**Counts: 0 BLOCKER · 1 MAJOR · 2 MINOR · 3 NIT (one SPECULATIVE).** Under the standing ladder
rules a fix pass is owed: the findings go to the implementer verbatim (cross-model flow — its
agree/dispute returns to this reviewer, who makes the final call and implements confirmed fixes
with their pins), and round 2 re-reviews the fixes. R1-1's fix wants care at the editor seam (the
settle-hop routing must not starve the arrow-key indicator path); R1-2 and R1-3 are three-line
fixes with clean red-on-old pins as specified; R1-4 is two worded cases; R1-5 is one sentence;
R1-6 is optional hardening, honestly labelled speculative.

---

## FIX PASS (this reviewer, 2026-09-19 — dispositions + evidence appended per piece)

**ANNOUNCED BEHAVIOURAL REVERT (the checkpoint protocol):** to measure
`aRenameThatWritesNothingSpeaksNoReceipt` red-on-old, the pane half of the R1-2 fix is reverted
in place on the committed tree (BlockHistoryPane.rename's receipt made unconditional again — the
shipped shape) with the OP fix left standing, the suite run, and the file restored by
`git checkout` against the R1-2 fix commit. Pre-revert state committed (the R1-2 commit).

**ANNOUNCED BEHAVIOURAL REVERT #2:** to measure the four `SavepointSealedDoorTests` cells
red-on-old, the four production files carrying the R1-3 guards (`EditorViewModel.swift` ·
`TakesViewModel.swift` · `CanvasViewModel.swift` · `CompareBoardView.swift`) are checked out to
the PRE-GUARD commit (the R1-2 findings-note commit), the suite run, and the four files restored
by `git checkout` against the R1-3 fix commit. Pre-revert state committed (the R1-3 commit).

### DISPOSITIONS (the reviewer's final call per finding, under the cross-model flow)

**R1-1 — CONFIRMED (implementer AGREE + three strengthening facts adopted into the record: the
:3337 arm is the ONLY storage-edit-reachable `refreshDecorations` call site of the ten; the
sample's frames prove the indicator arm specifically fired; `EditorView.swift`'s re-measure
observer states the broken rule in the project's own words). Severity stays MAJOR with the
implementer's calibration RECORDED: the arm is gated on the editing indicator, whose default is
`off` — she has it on, and the mechanism was met in a real walk, so MAJOR-not-BLOCKER is exactly
right.** FIXED (commit `13u3 ladder R1-1…`): `storageDidEdit` marks its whole body as the storage-
edit transaction (`inStorageEditTransaction`); `updateCaretContext`'s indicator arm defers its
decoration refresh while the flag is up (the settle hop the same edit armed delivers post-layout —
N14's stated design); the selection-change road keeps its synchronous refresh (caution 1 honored:
only the `:1279` reach is gated, the settle hop untouched; caution 2 honored: the caret-staleness
read is left exactly as it was). DEBUG oracle `decorLayoutQueriesInEditTransaction` + 2 pins in
`EditorDecorTransactionTests`. **Red-on-old, measured through the real delegate pipeline:** with
the shipped synchronous arm restored in place, the oracle counted **1** (both assertions red —
the stale-selection caret hop to block 2 fires the arm inside `processEditing`, and its
in-transaction refresh delivered, confirming the whole mechanism); 2/2 green with the fix;
ProseGutterTests 15/15 green beside it. *(A measurement note, honestly: the temp restore for this
red ran between the fix's edit and its commit — pin-first order, same as R1-2's core pin — so no
committed-state revert was needed; the log lines are in the session record.)*

**R1-2 — CONFIRMED (implementer AGREE; the existing seal pin proven blind to the order by its own
fixture). FIXED in two halves (commit `13u3 ladder R1-2…`):** the op's guards now outrank the
no-op short-circuit (`liveVariant` + `ensurePlacementUnlocked` first — `setTakeLabel`'s letter,
restored), and the ADJACENT OBSERVATION the implementer offered is ADOPTED as the face half: the
op returns whether it WROTE (`@discardableResult -> Bool`) and `BlockHistoryModel.rename` speaks
its receipt from that answer — chosen over comparing the pane's row value, which a stale row
would get wrong (the first draft did exactly that and the shipped
`renamingASavepointSetsAndClearsItsNameAndSaysSo` cell caught it before it ever ran: its second
rename compares against a deliberately stale `CommitPoint` value). **Red-on-old:** core
`theGuardsOutrankTheNoOpShortCircuit` — 2 issues on the pre-fix tree ("an error was expected but
none was thrown", both arms); Mac `aRenameThatWritesNothingSpeaksNoReceipt` — 2 issues under the
announced behavioural revert (`.receipt("Name cleared — the saved moment itself is untouched.")`
about a name that never existed; `.receipt("Saved moment named “kept”.")` re-spoken for a no-op),
restored and re-verified 5/5. Core `SavepointNameTests` 12/12. **Recorded residual, not fixed
(scope):** the PANE's rename door still OPENS its field under a sealed note and refuses at ⏎ —
the same P-2 grain R1-3 closes at the ⌘S doors; with the op fix the refusal is now correct and
consistent on both the changed and unchanged roads, and gating the pane door's OFFER under seal
is a face call left for the round-2 reviewer or a row.

**R1-3 — CONFIRMED; THE SCOPING DISPUTE RULED A WIDEN (the implementer is right, and my
"the siblings are clean" sentence was wrong — verified in code myself before ruling:
`TakesViewModel.focusedPane` IS the raw `authority.livePane` (`:101`), `focus` carries no seal
test, nothing blurs on seal (`toggleSeal` at `:1650` doesn't), and Canvas (`focus` at `:670`) and
Compare (`focus` at `:372`) read the same raw member with their seal facts at hand.** FIXED AT
ALL FOUR DOORS (commit `13u3 ladder R1-3…`): Write guards `header?.locked` · Takes/Lenses guard
`projection.sealed` · Canvas guards `sealed` · Compare guards the PANE'S OWN post's face
(`face(for: pane.context)?.sealed` — Compare crosses posts, so the board-level fact would be the
wrong one), each speaking the exact `lockedPost` sentence the post-⏎ road speaks. **Red-on-old,
measured under the announced behavioural revert #2 (the four files checked out to the pre-guard
commit):** all four `SavepointSealedDoorTests` cells RED — **9 issues, each showing
`savepointAsk → SavepointNameAsk(…)` opening under a seal on every door** — so the widen is not
merely traced but measured on all four; restored and re-verified 10/10 across the three door
suites.

**R1-4 — CONFIRMED (implementer AGREE). FIXED (commit `13u3 ladder R1-4…`):** `variantNotFound`
("That take isn't there any more — … The block's History lists deleted takes, with Put back.")
and `commitNotFound` ("That saved moment isn't there any more.") worded in `OpsRefusalCopy`.
**Red-on-old, pin-first:** `theRenameDoorsRaceRefusalsSpeakInsteadOfDumpingTheEnum` — 6 issues on
the pre-fix copy, both raw dumps verbatim. No shipped pin asserted the old dumps (grepped).
TakeCardDoorTests 10/10 green.

**R1-5 — CONFIRMED (implementer AGREE; its trace adds the `ops.merge` store-read line numbers).
FIXED, doc-only (commit `13u3 ladder R1-5 + R1-6…`):** the `displayed:` parameter now states
exactly what it binds (the carry-all road), what protects the plain road (the drift check + the
pinned resolver equivalence, modulo the recorded sub-ms window), and warns the future reader off
weakening the check. The closed UNIT G record is left as history; this comment is the living
truth at the code.

**R1-6 — CONFIRMED AS SPECULATIVE (both sides agree the cause is unproven); the hardening BUILT
as a decision, no red claimed (the finding's own framing):** adopting or un-adopting the chip
bumps the capture box's counted `focusRequest` on both hosts (the pad grew the `@State` its
literal `1` was hiding), and `takeFocus()` gains the already-first-responder guard the
implementer's caution asked for (no resign/become cycle when the box never lost keys). Toggling
OFF also returns the caret — the behaviour choice the caution named, taken deliberately: she is
returning to the words either way. Chip/capture suites green.

**Also adopted from the responses:** R1-1's three strengthening facts and severity calibration
(above); R1-2's adjacent observation (above). Nothing in the responses was dismissed.
