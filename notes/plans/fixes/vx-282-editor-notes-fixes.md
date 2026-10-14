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
| U1 | VX-290 — the empty-block backspace's caret landing | IN-PROGRESS — **W1 RED ON OLD DONE, W2 MAC BATCH GREEN** (stage `vx282-u1` 21:58:14–22:01:26, released; record below). **W3, the walk, is HELD** on the coordinator's word (she may be on the Pro) — next: on the orchestrator's "W3 GO" + claim line, walk rows A–D, record, flip to DONE. Fix `385aa1fc`. No revert in flight. |
| U2 | VX-296 — the italics flicker, caret-aware live restyle (Mac + phone) | **READY FOR STAGE — W1 red-on-old (Mac + phone), W2 the Mac batch (2 groups, 26 suite types), W2b the phone batch (10 suite types), W3 the walk rows A–C (+ the second voice), ≈45 min without U1's walk.** Fix `75b45ca9` (face + Mac) + `657bb57c` (phone); core `962a7305`; pins `44ad276b` (ahead of the fix). Headless: core 2,799/320 · MCP 212/41 · workbook 40/6 green; the four products built (old/fixed × Mac/phone). No revert in flight (none needed). PROVISIONALs P-U2-1/2/3 → QUESTIONS #219. |
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
- **W3 — HELD** by the coordinator until she confirms she is off the Pro; no "W3 GO" had reached this session when
  W2 ended, so the claim was released, per the GO's instruction. PENDING.

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
view's caret and post the selection change — the pins' caret-move road.)

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

## Ladder

*(Round findings verbatim, dispositions, fixes — repo-first before each next round.)*

## Closeout

*(Pending.)*
