# VX-282 — Run: Editor & notes fixes

**STATUS: OPEN — kickoff 2026-10-13 (evening).** Run ticket **VX-282** (project *v1 release readiness*) ·
branch `vx-282-editor-notes-fixes` · worktree `~/dev/variorum-vx-282` on the Pro · PR `VX-282: …` (merge commit
only). Shape: `/run-phase` on the run ticket, at her word. Orchestrator: session **vx-282** (named variorum-da at kickoff; Opus 5.5 at max).
Cast — **her word at kickoff (2026-10-13, verbatim):** *"you're running as the orchestrator Opus at Max thinking -
run implementers on xhigh and Opus cold review on Max. Run a fable cold review when you need to if you do & at the
end of the phase if you didn't need that."* So: `opus-implementer` at **xhigh**, ONE fresh session per unit,
strictly sequential; the ladder's cold reviews are **`opus-reviewer` at max** (same-model: the orchestrator
arbitrates against the spec); **one `fable-reviewer` cold review over the whole run's diff** — the editor seam
(VX-290 `EditorTextView` + `BlockRangeIndex`; VX-296's live-storage restyle) is the need CLAUDE.md names, and it
lands at the run's end, where it covers the whole diff (cross-model flow for its findings: Fable makes the final
call and implements its confirmed fixes). No agent runs concurrently with another.

**The kickoff is the runway's section** — `notes/plans/vx-33-release-runway.md` § "VX-282 — Run: Editor & notes
fixes" (quoted whole below), plus §2's conflict map and §3's rules for every run. Each member's ticket body
carries its own trace and pins (read them in Linear, or ask the orchestrator to paste one).

## The kickoff (the runway's §3 section, verbatim)

> ### VX-282 — Run: Editor & notes fixes
> **Members:** VX-290 (backspace) · VX-296 (the italics flicker) · VX-154 · VX-193 · VX-112 · VX-257 · VX-229 ·
> VX-183 · VX-182.
>
> **Units:**
> 1. **VX-290, the empty-block backspace.** Editor seam; its trace, ruling and pins are on the ticket. One
>    ReturnKeyTrace pin flips by her report's ruling.
> 2. **VX-296, the italics flicker** (pre-launch at her word: *"it's a bit too buggy and annoying to
>    remain"*). The closer half of the flanking rule refuses a closing `*` with a space before it. Fix (a), the
>    recommendation: caret-aware in the live editor only; the grammar and the read pages are untouched.
>    Shared markdown face, so both platforms' live editors.
> 3. **VX-154, the take panel's remaining routed commands.** The panel registration is the worked fix
>    (`0deda5b4`, `2e5784ca`).
> 4. **VX-193 + VX-112, the capture box pair.** VX-193: undo desync, so ⏎ files undone words — the comments
>    panel's per-area UndoManager is the precedent. VX-112: the focus re-grab, her "not urgent", judged on her walk.
> 5. **The comments family left by VX-179:**
>    - VX-229 first (the popover leak).
>    - VX-257 rides the same release hook.
>    - VX-183 (the registry).
>    - VX-182 (the purge fence, a query).
>
> **Cast:** Opus / **Fable** (VX-290 is `EditorTextView` + `BlockRangeIndex`; VX-296 restyles the live storage).
> Read `notes/TEXTKIT2_NOTES.md`. **Mobile-visible:** VX-296's shared face reaches the phone's live editor too
> (say so in the MOBILE PARITY line); VX-290 is Mac-only (the phone has no carve).

## Her rulings that bind this run (from the tickets, verbatim where she wrote them)

- **VX-290** — her report IS the caret-landing ruling (QUESTIONS #33(d) already decides WHICH block goes):
  *"when you're on an empty block in the write editor and there's a bunch of empty takes below it, clicking
  delete repeatedly eats the takes from underneath you, rather than moving you up into the previous line like
  writing editors typically do."* → **the caret lands where the deleted line break was**: after carving the
  block AFTER the separator, at the end of the block before it; after carving the block BEFORE the separator,
  at the start of the block after it (unchanged). Delete Block and archive keep their own helper.
- **VX-296** — fix **(a)**, her word on the ticket: *"296: your fix is good"* — caret-aware, live editor only;
  the grammar (`MarkdownSyntax`), the read pages, export and the phone's read page are untouched. Option (b)
  (dropping the closer half app-wide) is NOT authorized. Pins: `*hello |*` with the caret at `|` styled italic
  (red on old) and `2 * 3 * 4` still plain.
- **VX-257** — *"yes, clicking away should save your half typed comment on a draft."* → QUESTIONS #215
  option (a): PARK on the host's closing in the existing `CommentDraftPark`, restore on reopen at that block;
  parking never files (#118(a) stands); ⎋ still clears deliberately.
- **VX-112** — *"sounds like VX-112 is a tour only issue so I'll see if it bothers me on my walk but doesn't
  sound urgent."* The rule to build: the shared capture box re-takes only focus it HELD, never steals; red-on-old
  Mac pin first.

## The run's surfaces and overlaps (declared at kickoff)

- **Owned:** the Write editor's seam carve landing (`EditorSurfaceController`, `BlockRangeIndex`,
  `EditorEditRoute`/`SeamCarvePlan` as the trace needs); the shared markdown face's live restyle
  (`Shared/MarkdownFace/MarkdownFaceCore.swift`, `Theme/MarkdownStyling.swift`, the live editors' restyle call
  sites on both platforms); the Write take panel's routed-command registration; `Core/Views/CaptureTextView.swift`
  and its hosts (`QuickEntryBar`, `QuickNoteView`); the comments panel host/popover (`CommentsPanel`,
  `CommentPanelHostWatcher`, `Shared/CommentDraftPark.swift`), the capability registry's comment doors;
  `Queries/RestoreCost.swift`.
- **Zero `Sync/`, custody or Keychain lines** (VX-182 is a read-side query in `Queries/RestoreCost.swift`;
  `Sync/PurgeJanitor.swift` is NOT touched). Zero schema. Castle (VX-266) holds the one Sync/-custody slot.
- **Overlap — VX-246** (session variorum-84): VX-275 (the flush before a wire delete) and VX-230 (a badge) may
  reach the editor seam. Neither run changes the other's landing or styling rules without saying so; the
  orchestrator tells variorum-84 before this run edits anything in its lane, and whichever merges second merges
  main in first. **Its reply (2026-10-13):** VX-246's editor-seam units come later in its run (its U3 VX-275 may reach the
  block-range map, `EditorViewModel`'s projection deferral and a block tombstoned under a pending buffer —
  near `BlockRangeIndex`/`EditorSurfaceController`; its U4 VX-230 is the fan-badge decoration layer, not the
  markdown face); it messages this run's orchestrator (session **vx-282**) before editing
  `EditorSurfaceController`, `BlockRangeIndex`, `EditorEditRoute`/`SeamCarvePlan` or the markdown face. Its
  orchestrator session is now named **vx-246**.
- **Overlap — VX-283/VX-284:** the navigate-away road and `ShellRouter.adopt(landing:)` are theirs; this run uses
  neither.

## Stage protocol for implementers (binding)

The Pro's stage is coordinated tonight by the session **oct13coordinator**. **Only the orchestrator talks to it.**
- Headless `swift build` / `swift test` and `xcodebuild build` / `build-for-testing` never need the stage — run
  them freely in this worktree, with `-derivedDataPath App/Variorum/DerivedData/vx282-uN`.
- **EVERY `xcodebuild test` (Mac or simulator), every Debug-app launch and every walk needs a HELD claim.** When a
  unit reaches that point: commit, push, write `READY FOR STAGE — <what>, ≈<minutes>` on the unit's LIVE STATUS
  row, and report back to the orchestrator with exactly what the window will run. Then END YOUR TURN. The
  orchestrator requests the window and, on the coordinator's GO, sends you the exact claim line
  (`Tools/stage claim vx282-uN …`) — never claim without it. Release the claim yourself the moment the window's
  work is done (`Tools/stage release`), and report the release.
- Walks drive the DEV-store Debug build only (`io.lduarte.Variorum.debug`), `cliclick` + `Tools/WalkKit/`
  (`guard.sh` before every step; read `Tools/WalkKit/README.md`). After every Debug launch, dismiss a What's New
  sheet with its own button if one shows (until VX-237 lands — expected, never a finding). Leave the dev store
  as found: Standard, unlocked. If it greets you with a lock screen, the dev credentials live at
  `~/.variorum/dev-castle.env` (source it; never echo, log, capture or commit the values) — and if anything about
  posture is unexpected, stop the leg, release cleanly, report.
- **Never** touch her real store or `/Applications/Variorum.app`; never quit or kill a running instance you did
  not launch (if one is running, STOP and report).
- Before a behavioural revert (red-on-old proof): commit first, name the revert in the LIVE STATUS, restore by
  `git checkout -- <file>` from the commit, verify by `git diff`.

## LIVE STATUS

| Unit | Members | State |
|---|---|---|
| U1 | VX-290 — the empty-block backspace's caret landing | **DONE** — fix `385aa1fc`; W1 red on old + W2 the Mac batch green `be826a5d`; W3 the walk, every row held `a7a63949`. Stage released 22:01:26 and 23:47:00. One observation for the orchestrator to ticket (the bar's word counter, not this unit's road). No revert in flight. |
| U2 | VX-296 — the italics flicker, caret-aware live restyle (Mac + phone) | **READY FOR STAGE — u2b: phone W2b suites (-collect-test-diagnostics never) + Mac g1, ≈12 min.** The W2b fix built: `MarkdownFace.settleCaret` never writes while `storage.editedMask` is non-empty (before the ledger, so a skip consumes nothing); the trace of why a skipped settle is never lost is recorded; the red pin is `MobileMarkdownCaretTests.leavingATrailingSpaceBehindUnstylesTheSpanHonestly` (red on the pre-guard product by its crash). Rebuilt headless into the EXISTING `vx282-u2` + `vx282-u2-ios` only. Earlier: W1 red on old as designed, W2 Mac 190/26 green, W3 walk holds (Study). No claim held; no revert in flight. |
| U3 | VX-154 — the take panel's remaining routed commands (+ the archive-receipt rider nit) | NOT-STARTED |
| U4 | VX-193 + VX-112 — the capture box's undo desync and focus re-grab | NOT-STARTED |
| U5 | VX-229 → VX-257 → VX-183 → VX-182 — the comments family | NOT-STARTED |
| Ladder | `fable-reviewer`, REVIEW_PROMPT verbatim, PHASE=VX-282 | NOT-STARTED |
| Closeout | canon deltas, tickets, MOBILE PARITY, handoff, merge, refresh per the coordinator | NOT-STARTED |

## Stage traffic log (oct13coordinator protocol)

- 2026-10-13 ~17:40 — announced to oct13coordinator; its reply: VX-281 goes first when READY alongside others
  (VX-246's last unit waits on it); otherwise READY order, short-before-long; simulator suites need the stage too;
  dev store last left Standard + unlocked (vx-184, 15:35) — leave it so; walks need "walk" plainly in the
  REQUEST (it checks she isn't using the Pro); /Applications stays 7045 until the next release; no real-store
  MCP calls or real-app launches without her recorded word.
- 2026-10-13 — REQUEST sent early for `vx282-u1` (≈40 min: the Mac batch + the red-on-old revert run + a short walk); coordinator: queued FIRST, nobody ahead; zero-slot recorded for VX-282; at READY it checks she isn't using the Pro before the walk part (if she is, the GO covers batch + revert, the walk gets its own short GO).

## Unit records

*(Each unit's implementer writes its section here: the traced mechanism with file:line, the pins (red-on-old,
how verified), the diff summary, headless counts, the stage window's Mac counts and walk, PROVISIONAL calls,
anything for the author. PENDING until verified.)*

### U1 — VX-290 (the empty-block backspace's caret landing)

**State: IN-PROGRESS.** Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-13. Every count and
every "green"/"red" below is **PENDING** until the stage window runs it.

**The trace, re-done in this session against `5e2e22a7` (every file:line the ticket names verified; the code
agrees with the ticket's mechanism):**
1. ⌫ with the caret at an EMPTY block's start proposes deleting the one separator before it. A separator is owned
   by no entry, so `BlockRangeIndex.verdict` answers `.refuse(.crossesBlockBoundary)` and the gate
   (`EditorViewModel.shouldChangeText`, `EditorViewModel.swift:1097-1124`) refuses the keystroke and asks the one
   route (`EditorEditRoute.route`, `EditorEditRoute.swift:294-344`). The Mac's `.emptyBlockCarve` arm (`:307-311`)
   → `SeamCarvePlan.emptyBlockDeletion` (`:430-450`) → `BlockRangeIndex.emptyBlockDeletion`
   (`BlockRangeIndex.swift:246-252`) names the EMPTY neighbour of the separator — the one BEFORE it when both are
   empty (QUESTIONS #33(d)). **Which block goes is right**: with text above, it is the caret's own empty block.
2. `performCrossBlockRoute` schedules `runEmptyBlockDeletion` for the next main-actor turn
   (`EditorViewModel.swift:1162-1165` → `EditorSurfaceController.scheduleCrossBlockCompound`, `:2038-2060`).
3. **The caret is what goes wrong.** `runEmptyBlockDeletion` (`EditorSurfaceController.swift:2319-2331`) lands the
   caret by `caretLandingAfterRemoving(_ i:)` (`:1282-1287`) — "the START of the block below, else the END of the
   block above" — the Delete Block and archive doors' helper (`:1116`, `:1131`). It is told only WHICH entry
   left, never which SIDE of the deleted separator it sat on. With any block below, the caret lands at that
   block's start — which, the carved line gone, sits on the very visual line the caret was on.
   `applyStructuralResult` places it by identity (`:3016-3022`).
4. So the next ⌫ deletes the separator between the block above and the block now under the caret: another empty
   block carves (her report — *"eats the takes from underneath you"*), and a texted one is #34's seam merge
   ("Blocks joined"). Only the LAST empty block lands correctly (no block below → the end of the block above).
   **Fast presses take the same road:** a key typed while the carve's flight is up is stashed
   (`EditorTextView.keyDown`, `:85-98`; armed at `runStructural`, `EditorSurfaceController.swift:2932`) and replayed
   at the LANDED caret once the chain is idle (`replayDeferredKeystrokesIfIdle`, `:2071-2074`, from the chain's
   tail, `:2049-2058`) — the same wrong landing.
5. **The ⏎⌫ "oops":** ⏎ at the end of `alpha` (above `beta`) makes an empty block below (R-13u4-2); ⌫ carves it
   and lands at `beta`'s start; a second ⌫ is then #34's seam merge — the two paragraphs JOIN.
6. **Forward-delete:** ⌦ at a paragraph's end deletes the separator AFTER it; an empty block below is that
   separator's `after` neighbour → the same helper → the caret moves DOWN to the next block's start.
7. A fanned empty block never carves (`SeamCarvePlan.emptyBlockDeletion`'s fan guard, `EditorEditRoute.swift:443`;
   the diagnosis speaks `.seamBesideFan`) — so the eating stops at a block with takes. Verified.

**Where the code and the ticket differ (the code wins; recorded):**
- The flipping pin the ticket names `ReturnKeyTraceTests.aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow`
  lives in the suite TYPE `TypedReturnKeyTests` (file `ReturnKeyTraceTests.swift:857`).
- The 18l note (`phase-18l-navigation-feel.md:1056`) calls the old landing "the carve's ruled landing (13c 1B)".
  Traced: it was the 13c 1B helper's own doc ("what the eye expects when the seam above the caret closes"), not
  one of QUESTIONS #33's five ratified calls — nothing ruled the landing before her VX-290 report, as the ticket
  says.
- `runDeleteBlock`'s doc (`EditorSurfaceController.swift:1128-1129`) says the carve shares its body; it has not
  since 13c R3-1 gave the carve its own one-transaction body. Corrected in passing (a doc line only).
- **Recorded, not fixed (pre-existing, independent of the landing):** two ⌫ key events delivered in ONE main-actor
  turn (before the first's scheduled turn runs — a test can do this; not seen on hardware, where the scheduled
  turn runs between key events and the flight then stashes the second key) plan the SAME carve against the
  unchanged index; the second is refused inside `deleteBlock`'s transaction (`blockNotFound` — the block is already
  gone) and a refusal toast shows. No data is touched.

**The ruling being built:** her report (QUESTIONS #33(d) already decides WHICH block goes): *the caret lands where
the deleted line break was* — after carving the block AFTER the separator, at the END of the block before it;
after carving the block BEFORE the separator, at the START of the block after it (unchanged). Delete Block and
archive keep `caretLandingAfterRemoving`. Mac-only (the phone has no carve).

**The fix (three production files, no new authority, zero schema/`Sync/`/custody):**
- `BlockRangeIndex.emptyBlockCarve(replacing:isDeletion:)` — the carve's ONE walk now returns
  `(carved, survivor)`: the empty entry that goes AND the entry across the deleted separator.
  `emptyBlockDeletion` forwards to it (`?.carved`), so #33(d)'s both-empty rule stays in one place and every
  existing answer is unchanged (pinned at every one-character range of an irregular tiling). The regions, the
  verdict and the tiling are untouched.
- `SeamCarvePlan.EmptyBlockDeletion` gains `landing: Landing` — `.endOf(blockID:)` when the carved block sat
  AFTER the separator (⌫ from inside it, ⌦ at the end of the block before), `.startOf(blockID:)` when it sat
  BEFORE it (⌫ at the start of the block after, ⌦ from inside it). Named by the SURVIVING block's id, never an
  offset (the surface re-renders between the plan and the landing). Pure: the table suite pins it.
- `EditorSurfaceController.runEmptyBlockDeletion` lands by `caretLanding(afterCarving:)` instead of
  `caretLandingAfterRemoving(plan.entryIndex)`: `.startOf` → `(id, 0)`; `.endOf` → `(id, the survivor's length as
  the index holds it at the call)` — the doors' posture (read at the call, just before `runStructural` arms the
  stash), so a key that reached the survivor before this turn stays behind the caret. The deferred-key road needs
  nothing of its own: the stash replays at whatever this lands. Delete Block / archive still call
  `caretLandingAfterRemoving` (doc updated: theirs alone now); `runDeleteBlock`'s stale "both doors" doc corrected.
- **Cost (P1):** `.endOf` resolves the survivor by one identity scan of the entries, at act time only (never per
  typed character in a block). The same act already re-renders the whole surface (`seam: nil` → `renderFull`) and
  `applyStructuralResult` already scans for the caret block by identity, so the order of the act is unchanged.
- **The phone:** `MobileEditorViewModel` matches `.carveEmptyBlock` without binding (`:1694`), so the added field
  changes nothing there; the `VariorumMobile` scheme builds (generic iOS Simulator, headless).

**The pins (RED ON OLD = run against the one-line behavioural revert below; PENDING until the stage window):**
- `CarveCaretLandingTests` (a new `.serialized` suite in `BlockDeletionAndRedoTests.swift` — it hosts a real key
  window and drives `keyDown`, as every real-key suite does):
  - `herReportBackspaceInAnEmptyBlockMovesUpIntoTheLineAbove` — her pin: `["alpha","","",""]`, caret in the first
    empty block, ⌫ ⌫ → `["alph","",""]`; after the first ⌫ the caret is at alpha's end (5). **RED ON OLD.**
  - `aBackspaceTypedDuringTheCarvesFlightLandsAboveToo` — the deferred fast press (writer held, the second ⌫
    stashed during the flight) → `["alph","",""]`. **RED ON OLD.**
  - `returnThenBackspacePutsTheCaretBackWhereItWas` — the ⏎⌫ "oops" on `["alpha","beta"]`: the caret back at
    alpha's end, a second ⌫ → `["alph","beta"]` (old: the paragraphs joined). **RED ON OLD.**
  - `forwardDeleteAtAParagraphsEndKeepsTheCaretThere` — ⌦ at alpha's end over an empty block, then `x` →
    `["alphax","beta"]` (old: `["alpha","xbeta"]`). **RED ON OLD.**
  - Guards (green both sides): `backspaceAtAParagraphsStartUnderAnEmptyBlockKeepsItsStart`,
    `forwardDeleteInsideAnEmptyBlockKeepsTheCaretOnItsLine` (the BEFORE-side landing, unchanged), and
    `theDeleteAndArchiveDoorsKeepTheirOwnLanding(false/true)` (the doors still land at the block below's start).
- `TypedReturnKeyTests` (`ReturnKeyTraceTests.swift`):
  - **FLIPPED BY RULING:** the old `aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow` shape (`["alpha","beta"]`,
    ⏎ ⌫ ⏎ x in one turn) now lives as `aBurstWithASeamBackspaceAboveABlockLandsWhereTheBreakWas`, expecting
    `["alpha","x","beta"]` (was `["alpha","","xbeta"]`). **RED ON OLD.**
  - **RE-POINTED, purpose kept:** `aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow` keeps its name and its R2-1
    job (one burst pin per landing arm) on a shape that still lands BELOW: `["","beta"]`, ⏎ ⌫ ⏎ x at beta's start →
    `["","","xbeta"]`. Green both sides by design (not re-run against R2-1's own revert — the re-point keeps the
    arm, it does not re-prove R2-1).
- New-API pins (cannot be red-on-old — the API is new; they pin the pure decision): `EditorEditRouteTableTests
  .theCarvesLandingIsWhereTheDeletedBreakWas` (six shapes, both sides, #33(d)'s both-empty case) and
  `BlockDeletionAndRedoTests.theCarveNamesTheSurvivorAcrossTheSeparatorAndTheAnswerIsUnchanged`. The table
  suite's `aLoneEmptySeparatorIsTheMacsCarveAndThePhonesRefusal` gained the field (mechanical).

**The revert planned for red-on-old (one line):** `EditorSurfaceController.runEmptyBlockDeletion`'s
`let landing = caretLanding(afterCarving: plan)` → `let landing = caretLandingAfterRemoving(plan.entryIndex)` —
built into its OWN DerivedData (`App/Variorum/DerivedData/vx282-u1-revert`) BEFORE the window and restored at once
(`git checkout --` from the commit, verified by `git diff`), so the tree is never reverted while the turn is
handed off; the window runs `test-without-building` against both product sets.

**Headless:** `xcodebuild build-for-testing -scheme Variorum` (DerivedData `vx282-u1`) — TEST BUILD SUCCEEDED;
`xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'` — BUILD SUCCEEDED. No core
package file touched, so no `swift test` owed.

**The revert build — DONE, RESTORED.** The one line applied to the working tree only (named in LIVE STATUS first,
`13555701`), `build-for-testing` into `App/Variorum/DerivedData/vx282-u1-revert` — TEST BUILD SUCCEEDED; restored by
`git checkout -- App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift` from `385aa1fc`; `git diff`
empty, the landing line verified present. The fixed products were rebuilt after the restore
(`DerivedData/vx282-u1`, TEST BUILD SUCCEEDED). Both `.xctestrun` files exist.

**THE WINDOW PLAN (≈40 min; runs only on the orchestrator's claim line; `guard.sh --author` before every step).**
Logs and captures go to `notes/plans/vx282-screens/u1/` (`logs/` for the runs). From `App/Variorum/`:
- **W1 — red-on-old (≈3 min):** `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS'
  -derivedDataPath DerivedData/vx282-u1-revert -only-testing:VariorumTests/CarveCaretLandingTests
  -only-testing:VariorumTests/TypedReturnKeyTests -only-testing:VariorumTests/EditorEditRouteTableTests`.
  EXPECTED: in `CarveCaretLandingTests` the four RED-ON-OLD pins red and the three guards (five cases) green; in
  `TypedReturnKeyTests` ONLY `aBurstWithASeamBackspaceAboveABlockLandsWhereTheBreakWas` red; the table suite green
  (its pins pin the plan, which the revert leaves in place).
- **W2 — the fixed Mac batch (≈8 min), two groups on `DerivedData/vx282-u1`:** (g1) `CarveCaretLandingTests`
  `BlockDeletionAndRedoTests` `TypedReturnKeyTests` `ReturnKeyTraceTests` `SoftNewlineTests`
  `EditorEditRouteTableTests` `SeamMergeTests`; (g2) `WriteTopAirTests` `WriteFloatingViewportTests`
  `UntouchedLineKeeperTests` `WholeBlockDeleteTests` `BoundaryClampTests` `CrossBlockCompoundTests`. (Suite TYPE names,
  grepped: `ReturnKeyTraceTests.swift` holds three suites; `WriteFloatingViewportTests.swift` two — both carve users;
  `CrossBlockCompoundTests.swift`'s two other suites never reach the carve and are not named.) Read the counts
  and the skips in the logs (a wrong name runs 0 tests and still "succeeds").
- **W3 — the walk (≈20 min), the `vx282-u1` Debug app on the DEV store only** (`pgrep` first: no
  `/Applications/Variorum.app` instance, none of ours; dismiss a What's New sheet if shown). Stage the note through
  the shelf's quick-entry bar (`keys.sh` — full strings land there; the TK2 editor drops synthetic prose):
  `{t:"VX-290 walk"}alpha` ⇧⏎ ⇧⏎ `beta` ⏎; open it by ⌘K. In Write, keys only (`keys.sh`, ≥ 2 s apart; captures
  by region, before and after each row):
  - **A (her report):** caret to alpha's end (⌘↑ then ⌘→), ⏎ ⏎ ⏎ (three empty blocks, the caret in the last),
    ↑ ↑ (the caret in the FIRST empty block, empties below) → ⌫: the caret goes UP to alpha's end (the editing
    indicator on alpha, the receipt "Empty block deleted"), two empties stay below → ⌫: `alph`.
  - **B (the climb):** ↓ ↓ (the caret in the last empty block) → ⌫: the empty ABOVE goes and the caret's line
    moves up → ⌫: the caret's own block goes into the line above, the caret at `alph`'s end.
  - **C (the ⏎⌫ oops):** ⏎ at `alph`'s end → ⌫: back at `alph`'s end → ⌫: `alp` (never "Blocks joined").
  - **D (forward-delete):** ⏎ (an empty block below `alp`), ↑ then ⌘→ (back at `alp`'s end) → fn-⌦ (key code 117):
    the empty block goes and the caret STAYS at `alp`'s end, `beta` right below.
  Then move the walk note to the Trash (residue recorded), quit OUR instance by identity, re-check `pgrep`, leave
  the dev store as found (Standard, unlocked), release the claim. Voice: the dev store's current one, recorded — the
  landing is a caret position with no face of its own (no chrome, no voice-dependent code on the road); the
  mounted pins run under the harness's Terminal metrics.

**THE STAGE WINDOW, W1 + W2 — DONE** (the coordinator's GO; `Tools/stage` handed `coord-for-vx282` → **`vx282-u1`**,
claimed 21:58:14, RELEASED 22:01:26 — 4 of the 20 minutes; `guard.sh --author` OK before each leg; no Variorum
instance before or after, no simulator). Logs: `notes/plans/vx282-screens/u1/logs/`.
- **W1 — RED ON OLD, as designed** (`test-without-building` on `DerivedData/vx282-u1-revert`, the one-line revert;
  `w1-red-on-old.log`): "Test run with **55 tests in 3 suites failed** … **12 issues**", 0 skipped. Every issue sits
  in the five designed pins and nowhere else:
  - `herReportBackspaceInAnEmptyBlockMovesUpIntoTheLineAbove` — 3 (the caret NOT in alpha, NOT at 5, the second ⌫
    did not read `["alph","",""]`);
  - `aBackspaceTypedDuringTheCarvesFlightLandsAboveToo` — 1 (the store after the replayed press);
  - `returnThenBackspacePutsTheCaretBackWhereItWas` — 3 (the caret, the offset, `["alph","beta"]`);
  - `forwardDeleteAtAParagraphsEndKeepsTheCaretThere` — 3 (the caret, the offset, `["alphax","beta"]`);
  - `TypedReturnKeyTests.aBurstWithASeamBackspaceAboveABlockLandsWhereTheBreakWas` — 2 (the store, the caret's
    block).
  GREEN on old: the three guards (`backspaceAtAParagraphsStartUnderAnEmptyBlockKeepsItsStart`,
  `forwardDeleteInsideAnEmptyBlockKeepsTheCaretOnItsLine`, `theDeleteAndArchiveDoorsKeepTheirOwnLanding` ×2), the
  re-pointed `aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow`, its sibling
  `aBurstWithASeamBackspaceKeepsTheTextBehindTheReturnItFollowed`, the rest of `TypedReturnKeyTests`, and the whole
  table suite (its pins pin the plan, which the revert leaves in place). *(The store expectations print
  `<not evaluated>` for the actual value — `#expect` does not decompose a `try` call — so the old stores are the
  trace's, not the log's.)*
- **W2 — THE FIXED MAC BATCH, GREEN** (`test-without-building` on `DerivedData/vx282-u1`, the build of `385aa1fc`):
  (g1, `w2-g1.log`) "**120 tests in 7 suites passed**" — `CarveCaretLandingTests` `BlockDeletionAndRedoTests`
  `TypedReturnKeyTests` `ReturnKeyTraceTests` `SoftNewlineTests` `EditorEditRouteTableTests` `SeamMergeTests`;
  (g2, `w2-g2.log`) "**60 tests in 6 suites passed**" — `WriteTopAirTests` `WriteFloatingViewportTests`
  `UntouchedLineKeeperTests` `WholeBlockDeleteTests` `BoundaryClampTests` `CrossBlockCompoundTests`.
  **180 tests / 13 suites, all passed, 0 skipped** (every suite's ✔ line read in the logs; `** TEST EXECUTE
  SUCCEEDED **` ×2).
- **W3 — HELD** at W2's end (no "W3 GO" had reached this session), so the claim was released per the GO; the walk
  ran in its own window below.

**THE WALK, W3 — DONE, EVERY ROW HELD** (the coordinator's "W3 GO"; `Tools/stage` handed `vx282-u2` → **`vx282-u1`**
in one chained call, claimed 23:41:01, RELEASED 23:47:00; `git pull --ff-only` first — U2's commits on the branch,
NOT in the walked product, by the window's no-rebuild rule; `guard.sh --author` OK before every act; AX and screen
capture probed first). The product: the EXISTING `DerivedData/vx282-u1` Debug app (the build of `385aa1fc`), pid
16425, the DEV store (`io.lduarte.Variorum.debug`) — Standard, unlocked (no lock screen met), voice **Study**,
appearance system (light), both as found and as left. No What's New sheet showed (`whatsNew.lastVersion` 0.9.5 =
the product's). Staged through the shelf's quick-entry bar (`{t:"VX-290 walk"}alpha` ⇧⏎ `beta` ⏎ — opened in Write,
`["alpha","beta"]`). Every key through `keys.sh` (System Events), ≥ 2 s apart except row E. **The evidence in each
capture is the bottom bar's `block i/n`** (the caret's block and the count), the text, the masthead's tray count
(⌫N) and the quiet receipt "Empty block deleted — ⌥⌘Z undoes it." Captures (the content column, downsized):
`notes/plans/vx282-screens/u1/walk/`.
- **A — her report: HELD.** ⌘→ to alpha's end (`A0`), ⏎⏎⏎ (`A1`: five blocks, block 4/5), ↑↑ into the FIRST empty
  block with two empties below (`A2`: block 2/5) → **⌫: the caret moved UP to alpha's end** (`A3`: block 1/4, the
  two empties still below, ⌫1, the receipt) → **⌫: `alph`** (`A4`: block 1/4, both empties untouched — nothing
  eaten from underneath).
- **B — the climb from the last empty block: HELD.** ↓↓ into the last empty (`B0`: block 3/4) → ⌫: the empty ABOVE
  went and the caret's line moved up (`B1`: block 2/3, ⌫2 — #33(d)'s both-empty case, the shipped landing) → ⌫: the
  caret's own block went into the line above, **the caret at `alph`'s end** (`B2`: block 1/2, ⌫3).
- **C — the ⏎⌫ "oops": HELD.** ⏎ at `alph`'s end (`C0`: an empty block between, block 2/3) → ⌫: **back at `alph`'s
  end** (`C1`: block 1/2, ⌫4) → ⌫: **`alp`** (`C2`: still two blocks — never "Blocks joined").
- **D — forward-delete at a paragraph's end: HELD.** ⏎ then ↑ ⌘→ (`D0`: the caret at `alp`'s end, an empty block
  below, block 1/3) → fn-⌦ (key code 117): the empty block went and **the caret STAYED at `alp`'s end** (`D1`: block
  1/2, `beta` right below, ⌫5, the receipt).
- **E — an extra row, the real fast double press: HELD.** ⏎⏎⏎ ↑↑ (`E0`: block 2/5) → two ⌫ 30 ms apart in ONE
  System Events call (the README's model of a fast human double press): one empty carved, the second press deleted
  a letter — **`al`**, block 1/4, two empties still below, ⌫6 (`E1`). The deferred road on real events.
- **The two-⌫-in-one-turn refusal toast NEVER showed** — not in A–D (presses ≥ 2 s apart) and not in E (30 ms
  apart: the second press took the deferred road, the flight's stash). The recorded same-turn shape stays a
  test-only reach.
- **Cleanup:** the walk note moved to the Trash by note ▾ ▸ Delete Note… ▸ Delete (the app's own SwiftUI confirm;
  receipt "Note moved to the Trash — 30 days to put it back.") — **residue: the note "VX-290 walk" in the dev store's
  Trash, with the six carved empty blocks in its tray**; our instance quit by identity
  (`tell application id "io.lduarte.Variorum.debug" to quit`), `pgrep` empty after; no system popup or dialog met.
- **SURPRISE, recorded for the orchestrator to ticket — NOT this unit's road:** the bottom bar's note word count
  read **"1w in note"** while `alph`/`alp` and `beta` both stood on the page, after `B1` and after `D1` (each stayed
  wrong across a 3–4 s recapture, and corrected at the next structural act); after `A3`, `B2`, `C1`, `E1` it read
  the true 2w. `B1` is a carve whose landing is BYTE-IDENTICAL to the pre-VX-290 code (the block before the break,
  `.startOf`), so the drop does not track this unit's change. The count is `EditorViewModel.publishPostWordCount` →
  `ledger.totalWords(over: slots)` (the per-variant cached counts) — a different surface; observed, not traced.

### U2 — VX-296 (the italics flicker: a caret-aware live restyle)

**State: IN-PROGRESS.** Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-13. Every count and
every "green"/"red" below is **PENDING** until it is run (headless) or until the stage window runs it.

**The ruling being built:** fix **(a)**, her word on the ticket — *"296: your fix is good"*: caret-aware, LIVE
EDITOR ONLY. While her caret sits right after the whitespace that disqualifies a closer, the closer still counts;
when she leaves a trailing space behind, the span honestly un-styles. The grammar's meaning for every non-live
reader (read pages, export, the phone's read page, search, ⌘B/⌘I's toggle, anything else that parses) is unchanged.
Option (b) (dropping the closer half app-wide) is NOT authorized and is not built.

**The trace, re-done in this session against `a8c4756c` (the ticket's pointers verified; the code agrees):**
1. The minimal flanking rule — `Sources/VariorumCore/Domain/MarkdownSyntax.swift:549-555` (the doc: no whitespace
   after an opener, none before a closer; the reason, `2 * 3 * 4`). Its three closers each refuse a candidate whose
   previous character is whitespace: `closingPair` (`**`, `~~`, `:556-568`, the test at `:562`), `closingSingle`
   (`*`, `:570-580`, the test at `:576`), and `closingUnderscore` (`_`, `:477-490`, the test at `:483`).
2. Her flow: ⌘I with no selection writes `**` with the caret between (`MarkdownEditing.wrapPlan`'s caret gesture,
   `MarkdownEditing.swift:436-441`, `:463-468`). Typing `hello` reads `*hello*` — italic. Typing a SPACE reads
   `*hello *`: the closer is refused (`:576`), there is no other closer, and the span is gone. Typing `w` reads
   `*hello w*` — italic again. Every word boundary flips it.
3. She SEES each flip because every live editor re-parses the edited LINES on every keystroke, caret-blind:
   - **the Write editor and the book's inline editor** (one road — `InlineEditorSurface` wires the same
     `EditorSurfaceDelegate`, `EditorView.swift:559-581`): `EditorViewModel.storageDidEdit` →
     `MarkdownStyling.restyle(storage, range: editedRange)` (`EditorViewModel.swift:1312-1320`);
   - **every live pane** (Takes cards, Lenses columns, Index rows, Read's edit face, Write's take panel, Blocks,
     Canvas — all `PaneSurface`): `Coordinator.textDidChange` → `MarkdownStyling.restyle(storage, range:
     pendingEditRange ?? view.selectedRange())` (`PaneSurface.swift:1955-1967`);
   - **the phone's Write editor**: `MobileEditorViewModel.storageDidEdit` → `MarkdownFace.restyle(storage, range:
     editedRange, …)` (`MobileEditorViewModel.swift:1906-1915`). The phone's takes card editor wears no face
     (no `MarkdownFace` call under `VariorumMobile/Features/Takes/`).
   All three call the ONE shared face (`Shared/MarkdownFace/MarkdownFaceCore.swift`, `restyle` `:139-198`), which
   tokenizes with `MarkdownSyntax.spans(in:)` (`:153-155`) and so inherits the closer rule.
4. **The opener side** flips the same way only when whitespace follows the opening star: `*| world*` after she
   backspaces the first word away, or a space typed right after the opener. Typing words forward inside the pair
   never produces it (traced: the caret is always right of the last typed character, and the opener is followed
   by the first one). See PROVISIONAL P-U2-1.
5. Every other face road is caret-less by nature and untouched: the full-render doors (`EditorDocument.materialize`
   → `MarkdownStyling.style`, `EditorDocument.swift:88`; the phone's `:765`, `:837`), the structural rewrites
   (`applySeamEdit` `EditorViewModel.swift:938`, `programmaticReplace` `:4066`, the phone's `:2073`), the
   voice/palette roads (`EditorTypography.swift:475`, `:489`; the pane's `style`/`restyleFacedLines` at
   `PaneSurface.swift:1395`, `:1468`, `:1520`, `:1553`, `:1579`), the read tier (`ReadPostViewModel.swift:265` —
   non-editable), and every non-face parser reader (`MarkdownRendering.swift:246`, `TypedArrows.swift:83`,
   `MarkdownEditing.swift:186/214/289/336`, `MobileMarkdownActs.swift:116`).

**A measured fact the design rests on (a headless AppKit probe, an offscreen TK2 `NSTextView`, no window — the
scratch program is not committed):** during `insertText`, the storage delegate's `didProcessEditing` sees the
PRE-edit selection (a space typed at 6 reports `edited={6, 2}` with `sel={6, 0}`), then `didChangeSelection` fires
with the landed caret (`{7, 0}`), then `textDidChange`. `didChangeSelection` also fires for an edit that leaves the
caret still (forward-delete) and for a same-range `setSelectedRange`; a raw storage edit AFTER the caret fires none.
So the Write editor's keystroke restyle cannot know the landed caret, and the selection change is the reliable
"the caret has settled" moment on the Mac. (The same probe: `moveRight(nil)`/`moveLeft(nil)` move a windowless TK2
view's caret and post the selection change — the pins' caret-move road. And — the fact the settle leans on — the
selection change is posted only AFTER the storage's `processEditing` has completed, for a raw insert before the
caret, a full `setAttributedString` and typing alike: `editedMask == 0` and no `processEditing` frame on the stack
inside the handler, and an attribute write made there is its own clean edit (`mask=1`). So the settle never writes
inside a storage edit transaction — unlike the keystroke restyle, which by design writes inside `didProcessEditing`.)

**The road chosen, and why.**
- **The rule lives in the parser, behind an optional caret that defaults to today's reading.**
  `MarkdownSyntax.spans(in:caret:)` (`caret: Int? = nil`): the three closers consult one predicate,
  `closerFlanks` — "not preceded by whitespace, OR the caret sits exactly here". The opener half is untouched. Every
  existing caller passes no caret and reads byte-for-byte as before (the core markdown suites unchanged and green;
  the exhaustive gate-soundness pin below). The alternative — a second matcher in the face — is the two-brains class
  the one-tokenizer rule exists to kill; substituting a placeholder for the space before the caret would also flip
  `_`'s word-start rule. So: one grammar, one extra input, nil = untouched for every non-live reader.
- **The live surfaces keep their keystroke restyle caret-blind and byte-unchanged, and gain ONE settle step.** The
  keystroke road cannot know the landed caret (measured above), so rather than guess it, every live surface runs
  `MarkdownFace.settleCaret` when its caret has settled: an O(1) gate (`MarkdownCaretRescue.point` — the grapheme at
  the caret is `*`/`~`/`_` and the one before it is same-line whitespace; the exact necessary condition of the
  parser's rescue, pinned exhaustively) decides whether the caret could change the reading at all, and a tiny ledger
  (`MarkdownCaretRescue.Ledger` — which line was last styled honouring a caret, shifted at every character edit,
  OVER-claiming rather than ever under-claiming) decides which lines to restyle: the line a caret left (caret-blind)
  and the line it arrived at (honouring it). Almost every caret move restyles nothing; the worst case is two LINES
  (P1, pinned by scan count). Both platforms run the one brain.
- **The caret parameter is the SELECTION RANGE at the face** (`restyle(…, caret: NSRange?)`), so the held 18e brief
  (VX-293 — the faded marks' reveal rule wants the whole selection and a caret-move restyle occasion) can take this
  door and this settle occasion as they are. None of 18e's feature is built.

**Every live restyle occasion, and what each now does (Mac):**
- **The Write editor + the book's inline editor** (`EditorViewModel`; the inline editor wires the same
  `EditorSurfaceDelegate`): `storageDidEdit`'s top notes EVERY character edit in the ledger (suppressed programmatic
  writes too — full renders, seam edits, `programmaticReplace`), before the suppress guard; the keystroke restyle at
  `:1312-1320` is unchanged; `EditorSurfaceDelegate.textViewDidChangeSelection` now calls `settleMarkdownCaret()`
  before `updateCaretContext()`. Paste, undo, ⌘I/⌘B, find-replace and the structural rewrites all end in a selection
  change on this view, so each settles there.
- **Every live pane** (`PaneSurfaceView.Coordinator` — Takes, Lenses, Index, Read's edit face, Write's take panel,
  Blocks, Canvas): `shouldChangeTextIn` records the pre-edit range beside the existing `pendingEditRange`;
  `textDidChange` notes it, keeps its caret-blind restyle, then settles (the selection has landed by then, measured)
  before its remeasure (italics can rewrap); `textViewDidChangeSelection` settles on a pure caret move (skipped while
  an edit is in flight — `textDidChange` follows and settles) and remeasures when a line was restyled; `noteLiveness`
  clears the honour when a pane goes READ (a read pane honours no caret: the settle reads no selection while
  `isEditable` is false).
- **Unchanged, by nature caret-blind:** the full-render/materialize doors, the seam/programmatic rewrites' own
  restyles, the voice/palette/appearance re-faces, the pane's refont/ink/face/read-adopt roads, the read tier, and
  every non-face reader of the grammar (rendering, export, search, `TypedArrows`, `MarkdownEditing`'s acts).

**The phone** (`MobileEditorViewModel` — its Write editor is the phone's only face wearer; the takes card editor
wears none): `storageDidEdit`'s top notes every character edit (the Mac's line, before the suppress guard); the
keystroke restyle at `:1906-1915` is unchanged; `settleMarkdownCaret()` runs the shared settle; and the ONE gate
delegate (`MobileEditorGateDelegate`) gains `textViewDidChangeSelection` and `textViewDidChange`, each calling it — both,
so the honour never depends on UIKit's ordering of the two reports against the storage edit's own restyle (a second
settle with nothing changed writes nothing). **Mobile branch facts (for the catch-up's merge):** the long-lived
`mobile` branch exists only locally (`~/dev/variorum-mobile`; no `origin/mobile` ref), and `git log main..mobile`
lists ZERO commits — its tip `28ee417a` is the merge-base — so no file this unit touches has diverged there.

**The diff (seven source files changed, one new core file, three new test files):**
- `Sources/VariorumCore/Domain/MarkdownSyntax.swift` — `spans(in:caret:)`, `closerFlanks`, the caret threaded to the
  three closers. `Sources/VariorumCore/Domain/MarkdownCaretRescue.swift` (new) — `point(in:selection:)`, `Restyle`,
  `Ledger` (`noteEdit`, `settle`). *(Both outside the run's declared surfaces list, which names the face and the live
  call sites; the brief allowed the parser's optional caret.)*
- `App/Variorum/Shared/MarkdownFace/MarkdownFaceCore.swift` — `restyle(…, caret:)` (nil = byte-unchanged) and
  `settleCaret` (one editing session for its ≤ 2 lines). `Theme/MarkdownStyling.swift` — the Mac forwards.
- `Features/Editor/EditorViewModel.swift` (the ledger, the edit note, `settleMarkdownCaret`) ·
  `Features/Editor/EditorView.swift` (the delegate's one call) · `Surface/PaneSurface.swift` (the coordinator) ·
  `VariorumMobile/Features/Write/MobileEditorViewModel.swift` (the ledger, the note, the settle, the delegate's two
  callbacks).
- Zero `Sync/`, custody, Keychain, schema; nothing in `BlockRangeIndex`, `EditorTextView`, `EditorSurfaceController`,
  `EditorEditRoute`/`SeamCarvePlan`, or `runStructural`. The settle writes ATTRIBUTES ONLY on ranges the tokenizer
  computes inside one line (no identity attribute, no character, nothing registered with text undo).

**The pins.**
- **Core, headless — `MarkdownCaretRescueTests` (17 tests; NEW API, so not red-on-old by construction; GREEN):**
  her `*hello |*` italic with the caret at `|` and plain everywhere else and caret-blind; `*hello w*` italic at every
  caret; the family (`**hello **` caret-blind reads ITALIC over `hello *` today — bold with the caret; `~~gone ~~`;
  `_so _`, `_so _x` still refused); the opener never rescued (`* hello*` at every caret); no opener, no rescue;
  **arithmetic plain at EVERY caret position** (`2 * 3 * 4`, `2 ** 3 ** 4`, `a ~~ b ~~ c`, `2 _ 3 _ 4`, `x * y`, `* *`,
  `**bold** and 2 * 3 * 4`); `*foo *bar*` byte-identical with no caret; **the gate's soundness** (19 texts × every
  caret: wherever the gate says nil, the caret-aware reading IS the caret-blind one); graphemes (a combining space; a
  caret inside a surrogate pair); the gate answers only an insertion point; the scan cost; the ledger (her typing
  flow, leaving, going read, one line restyled once, the same-offset re-honour after an edit, edits elsewhere and the
  widened report).
- **Mac — `MarkdownCaretFaceTests` (the Write editor, `withEditor`, real `insertText` + arrow actions):**
  `herFlowTypingInsideAnItalicPairNeverDropsTheItalicAtASpace` (⌘I's `**` + "hello world again" one keystroke at a
  time; display == stored; every character of the block keeps its ID, the separator none; the audit never fires) —
  **RED ON OLD**; `aBoldPairStaysBoldAtASpaceToo` — **RED ON OLD**; `leavingATrailingSpaceBehindUnstylesTheSpanHonestly`
  (→ plain, ← italic, a selection plain, a click into the next block plain) — **RED ON OLD** (its italic expectations);
  `arithmeticStaysPlainAtEveryCaretPositionAndAsItIsTyped` — GUARD, green both sides;
  `aCaretMoveCostsAtMostTwoLinesAndNothingWhereItCannotMatter` (400 lines in one block: zero scans for moves that
  cannot matter, ≤ 2 lines onto a rescue point, ≤ 4 lines between two) — its non-vacuity expectation **RED ON OLD**,
  the rest green both sides.
- **Mac — `PaneMarkdownCaretFaceTests` (a live pane in a borderless window, `.serialized`):**
  `aLivePaneKeepsTheItalicWhileHerCaretSitsAfterTheSpace` — **RED ON OLD**;
  `aPaneThatLosesTheCaretOrGoesReadUnstylesTheSpan` (→ plain, ← italic, the pane going read with its caret still parked
  at the rescue point → plain, a caret placed in a read pane → plain) — **RED ON OLD** (its italic expectations).
- **Phone — `MobileMarkdownCaretTests` (the real `MobileEditorTextView` in a key window, first responder,
  `insertText`; Study, whose face has a real italic — a non-vacuity `#require`):** her flow — **RED ON OLD**;
  leaving a trailing space — **RED ON OLD** (its italic expectations).
- **Unchanged and expected green:** `MarkdownFaceTests`, `ProgrammaticReplaceFaceTests`, the identity audit suites
  (`IdentityProjectionAuditWalkTests`, `MacIdentityAuditWiringTests`), the phone's `MobileMarkdown*Tests` and its
  identity suite — the brief's "the existing face and parser suites green and UNCHANGED".

**The red-on-old products — NO REVERT.** The pins were committed AHEAD of the fix (`44ad276b`), and that commit's
app code is the pre-fix app over a core whose nil-caret reading is byte-identical (proven headless), so its products
ARE the old tree: `xcodebuild build-for-testing` → `App/Variorum/DerivedData/vx282-u2-old` (Mac) and
`vx282-u2-old-ios` (phone, `generic/platform=iOS Simulator`) — both **TEST BUILD SUCCEEDED**. The fixed products
(the tree at `657bb57c`): `DerivedData/vx282-u2` and `vx282-u2-ios` — both **TEST BUILD SUCCEEDED**. No revert was
ever applied; `git status` clean.

**Headless counts:** `swift test` (whole core package, at the fix's tree): **VariorumCoreTests 2,799 tests / 320
suites passed** (VX-184's closeout baseline 2,782/319 + this unit's 17/1), VariorumMCPTests 212/41, workbook 40/6 —
all green. The markdown suites alone at `962a7305`: 106/7.

**PROVISIONALs (QUESTIONS #219 — the number is main's next free one; renumbered at the merge if taken):**
- **P-U2-1 — the opener side is not caret-aware.** Built (a) closer only — the ruling's letter and her typing flow
  (forward typing inside a pair only ever puts the space before the closer; traced). The opener flips only when the
  FIRST word is backspaced away (`*| world*`) or a space is typed right after the opening star. Option (b) the mirror:
  arithmetic stays plain at every caret either way (one caret can never rescue both halves — an opener needs a
  non-space right of it, a rescued closer a space left of it), but a star typed mid-line before a later closer
  (`5 *| 3 and *wow*`) would show a long wrong italic while the caret sits there.
- **P-U2-2 — every closer of the flanking family, not only `*`.** Built (a) `*`, `**`, `~~` and `_`; ⌘B's pair
  flickered worse than ⌘I's (bold → an italic over `two *` with a stray star → bold). Option (b) the italic star only.
- **P-U2-3 — ⌘I/⌘B keep reading the caret-blind grammar.** At `*hello |*` the face shows italics, but ⌘I does what it
  always did at that one spot (inserts a new pair; one letter later it unwraps). Built (a) unchanged — the acts are
  among the "every other reader" the ruling left untouched. Option (b) the acts read the caret-aware reading when
  nothing is selected.

**Edges recorded, not built (the accepted posture):**
- A whole-surface re-face (a voice, palette or appearance switch; a pane's refont/ink/face road) is caret-blind: a
  rescue in force at that instant returns at her next keystroke or caret move.
- A raw programmatic storage write AFTER the caret on its own line, with no selection change, re-reads that line
  caret-blind until the next keystroke or caret move (no such road is known on the caret's own block mid-typing).
- The emphasis-nesting sibling the ticket names (`*a **b** c*`) is untouched — "ticket it if she ever hits it".

**THE WINDOW PLAN (runs only on the orchestrator's claim line; `guard.sh --author` before every leg; no
`/Applications/Variorum.app` instance before or after, no simulator booted by anyone else).** Logs and captures go to
`notes/plans/vx282-screens/u2/` (`logs/` for the runs). From `App/Variorum/`:
- **W1 — red on old (≈8 min):**
  (Mac) `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  DerivedData/vx282-u2-old -only-testing:VariorumTests/MarkdownCaretFaceTests
  -only-testing:VariorumTests/PaneMarkdownCaretFaceTests -only-testing:VariorumTests/MarkdownFaceTests`.
  EXPECTED: red in `herFlow…`, `aBoldPair…`, `leaving…` (italic expectations), `aCaretMoveCosts…` (its `arriving > 0`
  only), `aLivePaneKeeps…`, `aPaneThatLoses…` (italic expectations); GREEN `arithmeticStays…` and the whole of
  `MarkdownFaceTests`.
  (Phone) `xcodebuild test-without-building -scheme VariorumMobile -destination 'platform=iOS Simulator,name=iPhone
  17 Pro,OS=26.2' -derivedDataPath DerivedData/vx282-u2-old-ios -only-testing:VariorumMobileTests/MobileMarkdownCaretTests`.
  EXPECTED: both tests red on their italic expectations, the identity expectations green.
- **W2 — the Mac batch, fixed product `DerivedData/vx282-u2` (≈10 min), two groups (suite TYPE names, grepped):**
  (g1) `MarkdownCaretFaceTests` `PaneMarkdownCaretFaceTests` `MarkdownFaceTests` `ProgrammaticReplaceFaceTests`
  `MarkdownActsTests` `FormattingSurfacesTests` `MarkdownPaletteWritersTests` `IdentityProjectionAuditWalkTests`
  `MacIdentityAuditWiringTests` `EditorSessionTests` `ReviewRoundFixTests` `CommitFlowTests` `FanFlowTests`;
  (g2) `PaneSurfaceTests` `PanePublishDoorTests` `PaneFindFaceTests` `TakePaneMeasureTests` `TakePaneDurabilityTests`
  `TakesCardHeightTests` `PaneRenderRestoreClipTests` `PlainPasteRuleTests` `PlainPasteDoorTests`
  `IndexClickCaretTests` `InlineHeightReportTests` `WriteFloatingViewportTests` `UntouchedLineKeeperTests`.
  Read the counts and the skips in the logs (a wrong name runs 0 tests and still "succeeds").
- **W2b — the phone, fixed product `DerivedData/vx282-u2-ios` (≈6 min, the same simulator):**
  `MobileMarkdownCaretTests` `MobileMarkdownRenderTests` `MobileMarkdownReturnTests` `MobileMarkdownActsTests`
  `MobileCheckboxTapTests` `MobileEditorMaterializationTests` `MobileEditorRoutingTests` `MobileEditRoutingBindingTests`
  `MobileIdentityAuditSeparatorTests` `MobileEditRoutingCrashTests`. Shut the simulator down after (`xcrun simctl
  shutdown`), by the device id the run booted.
- **W3 — the walk (≈20 min), the Debug app `DerivedData/vx282-u2/Build/Products/Debug/Variorum.app` on the DEV store
  only** (`pgrep` first; dismiss a What's New sheet if shown). Stage the note through the shelf's quick-entry bar
  (full strings land there): `{t:"VX-296 walk"}*hello*`; open it by ⌘K. In Write, keys only (`keys.sh`, one key per
  call, ≥ 2 s apart; region captures before and after each row):
  - **A (her flow):** the caret between `hello` and the closing star (⌘↑ then → ×6) → SPACE: capture — `hello ` stays
    italic (right after the space) → `w`: capture (mid-word, italic) → `o` → SPACE: capture (italic again).
  - **B (leaving):** → past the star: capture — the span is plain, the trailing space left behind → ←: capture —
    italic again → a click on the note's title or another line: capture — plain.
  - **C (arithmetic):** ⌘→, ⏎ (a new block), type `2 * 3 * 4` key by key: capture — no italics, no dimmed stars.
  If synthetic keys drop characters in the TK2 editor (the walk kit's 13u3 note), stage A's states through the quick
  entry instead (`*hello *`) and walk the caret half (B) only — the typing half is the pins'. Voice: the dev store's
  current voice (recorded); then Study↔Terminal via Settings ▸ Appearance's AX road and repeat A's space capture and
  B's leave capture; restore the voice found. Then the walk note to the Trash (residue recorded), quit OUR instance by
  identity, re-check `pgrep`, leave the dev store Standard and unlocked, release the claim.

**THE STAGE WINDOW — RUN 2026-10-13, 22:59:49 → 23:39 (the coordinator's GO; claim `vx282-u2`, HELD at the end —
NOT released, U1's walk follows by a chained handover; `guard.sh --author` OK before every leg; no Variorum instance
and no booted simulator at the start). Logs: `notes/plans/vx282-screens/u2/logs/`; captures beside them.**
- **W1 — RED ON OLD, AS DESIGNED.**
  - Mac (`w1-mac-red-on-old.log`, the `44ad276b` product): "Test run with **23 tests in 3 suites failed** … **9
    issues**", every one on a designed expectation — `herFlow…` 1 (the italic dropped after typing `"hello "` and
    `"hello world "`), `aBoldPair…` 1 (flickered at `"two "`), `leaving…` 3 (the three italic expectations),
    `aCaretMoveCosts…` 1 (`arriving > 0` — nothing honoured the caret), `aLivePaneKeeps…` 1 (dropped at `"hello "`),
    `aPaneThatLoses…` 2 (its two italic expectations). GREEN on old: `arithmeticStays…`, the rest of `aCaretMoveCosts…`,
    and the whole of `MarkdownFaceTests` (16).
  - Phone (`w1-phone-red-on-old.log`, the old iOS product, iPhone 17 Pro iOS 26.2): "**2 tests in 1 suite failed** …
    **3 issues**" — `herFlow…` 1, `leaving…` 2 (its italic expectations); NO crash on the old product.
- **W2 — THE MAC BATCH, GREEN** (the `657bb57c` product): g1 (`w2-g1.log`) "**106 tests in 13 suites passed**"; g2
  (`w2-g2.log`) "**84 tests in 13 suites passed**" — **190 tests / 26 suites, 0 skipped**, `** TEST EXECUTE SUCCEEDED
  **` ×2. The two new Mac suites green there (her flow, the bold pair, leaving, arithmetic, the P1 cost; the live pane
  and the pane going read).
- **W2b — THE PHONE: A FINDING** (`w2b-phone.log`, the fixed iOS product): 33 tests in 5 suites passed (the four
  `MobileMarkdown*` suites incl. her-flow pin `herFlowTypingInsideAnItalicPairNeverDropsTheItalicAtASpace` ✔, plus the
  edit-routing, identity-separator, materialization and routing suites ✔), BUT
  **`MobileMarkdownCaretTests.leavingATrailingSpaceBehindUnstylesTheSpanHonestly` hit the DEBUG fatal "mobile editor
  surface desynced from the block index"** (`MobileEditorViewModel.swift:2001`) → the runner restarted → `** TEST
  EXECUTE FAILED **`, the one failing test that one. **Caused by the phone settle** — the same test on the OLD product
  recorded only its italic issues and did not crash. **The backtrace** (`~/Library/Logs/DiagnosticReports/
  VariorumMobile-2026-10-13-232041.ips`, its Problem Reporter window captured as
  `w2b-problem-report-VariorumMobile.png`): the test's `view.insertText("hello ")` (ONE multi-character insert) →
  `MobileEditorTextView.insertText` → `UITextInputController _insertText:fromKeyboard:` → **`NSTextStorage
  coordinateEditing:`** → `endEditing` → `processEditing` → `MobileStorageObserver` → `storageDidEdit`'s `.refuse` arm
  (`:1917`) → `recoverFromUnroutableEdit` → `desyncRecovery`'s `EditorAssertionSeam.fire`. **The mechanism (traced
  from the stack; the iOS ordering itself is inferred, not yet measured):** UIKit wraps that insert in ONE
  `coordinateEditing` transaction and reports the selection to the delegate INSIDE it, before `endEditing`; the
  settle's attribute write then joins the character edit in the one `processEditing` report, whose range now starts
  at the line's first marker — so the gate's armed edit no longer binds, `fallbackVerdict` recomputes over a range
  that crosses the separator, and the route refuses. (On the Mac the selection change is posted only after
  `processEditing` — measured — and the Mac batch, which inserts the same `"hello "` in one call, is green.)
  **The fix, designed, NOT BUILT (no rebuilds this window, the coordinator's word):** `MarkdownFace.settleCaret` never
  writes while its storage has an edit pending — `guard storage.editedMask.isEmpty` (the edit's own `processEditing`
  then notes it, and `textViewDidChange` — already wired, after the edit closes — settles with the ledger's edit mark
  forcing the re-honour). One line in the shared face, so the Mac's two roads carry the same belt (behaviour there
  unchanged: the Mac never settles mid-edit). The red pin for it already exists (this crash). **Next:** build it
  headless, then a phone window (W2b re-run) and the Mac g1 re-run (the shared settle changed).
  **Harness fact:** both phone runs lost 600 s to xcodebuild's "Failure collecting diagnostics from simulator: Timed
  out after 600.0 seconds" (W1's elapsed 1008 s) — a phone leg costs ≈ 18 min as run; the next one should pass
  `-collect-test-diagnostics never`. The simulator was shut down by the run (re-checked: 0 booted).
- **W3 — THE WALK, Study (the dev store's voice, recorded; never switched), the `vx282-u2` Debug app on the dev store**
  (opened unlocked, "Sync off (dev store)", no What's New sheet). Staged through the quick-entry bar
  (`{t:"VX-296 walk"}*hello*` — the box curled the quotes, the microsyntax took them; `w3-00-quickentry.png`) → ⏎ opened
  it in Write (`w3-01-opened.png`, `*hello*` italic, stars dimmed). Keys one per `keys.sh` call, ≥ 2 s apart — **no
  character dropped**:
  - **A (her flow) — HOLDS:** caret before the closing star (`w3-A0-caret-before-star.png`) → SPACE: `*hello |*` stays
    ITALIC, both stars dimmed (`w3-A1-after-space.png` — the state that read plain before the fix) → `w`
    (`w3-A2-midword-w.png`) → `o` (`w3-A3-midword-wo.png`) → SPACE again (`w3-A4-after-second-space.png`): italic at
    every step.
  - **B (leaving) — HOLDS:** → past the star: the whole line reads PLAIN, stars undimmed — the trailing space left
    behind (`w3-B1-right-past-star.png`); ← back between the space and the star: italic again (`w3-B2-left-back.png`).
  - **C (arithmetic) — HOLDS:** ⌘→, ⏎ (a new block — which also moved the caret to another line), `2 * 3 * 4` typed
    key by key: plain, no dimmed stars; and the first line, its caret gone, reads plain (`w3-C1-arithmetic-typed.png`).
  - **The second voice — NOT WALKED** (the voice switch is the Settings AX road, not cheap in the window's remaining
    time; the brief's "otherwise do Study"). Recorded as such; the pins run under the harness's Terminal metrics.
  - **Residue:** the walk note moved to the Trash by its own `note ▾ › Delete Note…` and the app's confirm
    (`w3-D0-note-menu.png`; the receipt "Note moved to the Trash — 30 days to put it back."). The W2b crash's Problem
    Reporter window ("Problem Report for VariorumMobile", buttons Hide Details/OK — my run's artifact, its report kept)
    was dismissed by its named OK button.
- **Posture left:** our instance quit by identity (`pgrep` → 0 instances); the dev store as found — Standard (custody
  never touched), unlocked, voice Study (unchanged), appearance "system" (unchanged); 0 simulators booted; **the claim
  `vx282-u2` still HELD** (~20 min left at 23:39) for U1's chained handover.

**THE W2b FIX — the settle never writes while an edit is pending (built after the window, at the coordinator's
word; no stage needed).**
- **The guard:** `MarkdownFace.settleCaret` (`Shared/MarkdownFace/MarkdownFaceCore.swift`) opens with
  `guard storage.editedMask.isEmpty else { return false }`, BEFORE the ledger is consulted — so a skipped settle
  consumes nothing (the ledger's claim and its edit mark are untouched). The parameter narrows from
  `NSMutableAttributedString` to `NSTextStorage` (`editedMask` is a text-storage property; every live caller already
  passes one; the Mac forward in `Theme/MarkdownStyling.swift` follows). One line of behaviour, in the shared face, so
  all three live surfaces carry it.
- **THE RED PIN:** `MobileMarkdownCaretTests.leavingATrailingSpaceBehindUnstylesTheSpanHonestly` — **RED on the
  pre-guard product** (`657bb57c`'s, the W2b crash: the DEBUG desync fatal through `coordinateEditing:` →
  `storageDidEdit`'s `.refuse` arm), expected GREEN on the guarded product (PENDING the u2b window). Its sibling
  `herFlow…` (single-character inserts) was already green and must stay so.
- **Why a skipped settle is never lost — traced road by road:**
  - **The phone's keyboard insert (the crash road):** the mid-transaction selection report is skipped →
    `endEditing` → `processEditing` → `storageDidEdit` notes the edit (`noteEdit`: claim shifted, edit mark set) and
    runs its caret-blind restyle → UIKit then reports `textViewDidChange` — its contract is "called in response to
    user-initiated changes", which the keyboard's `insertText` is — and that report, wired to the settle since
    `657bb57c`, runs after the transaction has closed: `editedMask` is empty, the edit mark forces the settle, and the
    landed caret is honoured. **Evidence from W2b:** `herFlow…`'s space keystroke was honoured before `insertText`
    returned (the pin read italic on the very next line), so a report AFTER UIKit's transaction exists on this road;
    the multi-character insert runs through the same `_insertText:fromKeyboard:`. That it is `textViewDidChange` (and
    not a second selection report) is inferred, not measured, and it does not matter: the u2b re-run's `leaving…` pin
    asserts the italic on the line right after `insertText("hello ")`, so a lost settle would read red there.
  - **The phone's programmatic roads:** the bar's formatting acts apply each edit through UIKit's input replace and
    THEN set `textView.selectedRange` (`MobileMarkdownActs.apply`, `:85-106`); the structural roads place the caret
    after their writes; the model's own writes (`EditorSurfaceStorage.replace`, the voice re-face session) never set
    the selection inside their `beginEditing` sessions. Every final placement is a report after the edit closed.
  - **The Mac Write editor and the inline editor:** the settle runs only from `textViewDidChangeSelection`, which
    AppKit posts after `processEditing` completes (measured: `editedMask == 0`, for typing, raw inserts and full
    replacements), so the guard never trips there; ⌘B/⌘I (`MarkdownActs.apply`, `:182-201`) place the selection only
    after every edit. Behaviour on the Mac is unchanged (the W2 batch's 190 stand on that).
  - **A Mac live pane:** the settle runs at `textDidChange` (posted after `processEditing` and after the selection
    change, measured) and on pure caret moves (no edit in flight) — the guard never trips.
  - **A road where it IS lost:** none found for an input-road edit. The recorded edge stands unchanged and does not
    grow: a programmatic write followed by NO caret report (a voice/palette re-face; a raw write on the caret's line)
    re-reads caret-blind until her next keystroke or caret move — and a skip needs a pending edit, whose end the input
    roads always follow with a report.
- **Headless:** `build-for-testing` into the EXISTING trees only — `DerivedData/vx282-u2` (Mac) and
  `DerivedData/vx282-u2-ios` (phone): **TEST BUILD SUCCEEDED** ×2; no new tree, the `-old` trees untouched. No core
  file changed (no `swift test` owed).

**THE u2b WINDOW PLAN (≈12 min; on the orchestrator's claim line; `guard.sh --author` before each leg). From
`App/Variorum/`; logs to `notes/plans/vx282-screens/u2/logs/`. The coordinator erases the iOS simulators before it —
the run is a first boot and a fresh install (budgeted).**
1. `xcrun simctl list devices available | grep "iPhone 17 Pro"` — confirm the device still exists after the erase
   (if the erase deleted devices rather than wiping them, take any iPhone on iOS 26.2 or 27.0 from that list; the
   product is a generic-simulator build, deployment target iOS 26).
2. **The phone (W2b re-run):** `xcodebuild test-without-building -scheme VariorumMobile -destination
   'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' -derivedDataPath DerivedData/vx282-u2-ios
   -collect-test-diagnostics never` with `-only-testing:VariorumMobileTests/` ×10 — `MobileMarkdownCaretTests`
   `MobileMarkdownRenderTests` `MobileMarkdownReturnTests` `MobileMarkdownActsTests` `MobileCheckboxTapTests`
   `MobileEditorMaterializationTests` `MobileEditorRoutingTests` `MobileEditRoutingBindingTests`
   `MobileIdentityAuditSeparatorTests` `MobileEditRoutingCrashTests` → `u2b-w2b-phone.log`. EXPECTED: all ten suites
   green in ONE launch (no "Restarting after unexpected exit"; W2b's "33 tests" line counted only the launch after
   its crash, so read the ✔/✘ lines per suite rather than compare totals).
3. **The Mac g1 re-run (the shared settle changed):** `xcodebuild test-without-building -scheme Variorum -destination
   'platform=macOS' -derivedDataPath DerivedData/vx282-u2` with `-only-testing:VariorumTests/` ×13 —
   `MarkdownCaretFaceTests` `PaneMarkdownCaretFaceTests` `MarkdownFaceTests` `ProgrammaticReplaceFaceTests`
   `MarkdownActsTests` `FormattingSurfacesTests` `MarkdownPaletteWritersTests` `IdentityProjectionAuditWalkTests`
   `MacIdentityAuditWiringTests` `EditorSessionTests` `ReviewRoundFixTests` `CommitFlowTests` `FanFlowTests` →
   `u2b-w2-g1.log`. EXPECTED: 106 tests / 13 suites green, as at W2.
4. `xcrun simctl shutdown all`; confirm 0 booted; release the claim (unless told to hold it).

## Ladder

*(Round findings verbatim, dispositions, fixes — repo-first before each next round.)*

## Closeout

*(Pending.)*
