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
call; **since her process change of 2026-10-13 (CLAUDE.md "Two reviews" — Fable's budget goes to finding and judging, not typing) the OPUS IMPLEMENTER applies the confirmed fixes, red-on-old each with the suite green, and the reviewer writes a fix itself only for `Sync/` lines (none in this run) or a finding it marks FINDER-FIXES, followed by one implementer sanity pass; a final round's fixes get the orchestrator's line-by-line check**). No agent runs concurrently with another.

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

## Her overnight mandate (2026-10-14, ~00:50, verbatim)

*"I want you to continue on through the night ending in a merge to main - the final merge in of the night can be the
only one to do an applications refresh. Rule provisionally in my absence and leave me a handoff with any needed
information to note down."* So: the run closes and merges tonight; every open product call is built PROVISIONAL and
logged to `notes/QUESTIONS.md` under the VX-282 heading; the `/Applications` refresh runs ONLY if this run is the
night's final merge (the stage coordinator calls the order — passed to vx-281 and vx-246 too); the handoff is
`notes/handoffs/vx-282-handoff.md`, her checklist at the top.

## Tickets born during the run

VX-319 (Write's word count one short after a carve — U1 walk, untraced) · VX-320 (File ▸ Export Block… hits the caret
block under the take panel — U3 O-1) · VX-321 (Move Take into a Block Below's receipt "archived · n" — U3 O-3) ·
VX-322 (the capture box's `entryFocused` may stay true across a re-attach to another responder — U4 O-U4-1, untraced) ·
VX-325 (⌘K queues behind the take panel — U3 O-6). All in *12 — Hardening & perf validation*, Todo; pre-launch is hers.
U4's O-U4-2 (the box's history left the window's shared undo stack under P-U4-1) — no symptom traced, no work: recorded.

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
| U2 | VX-296 — the italics flicker, caret-aware live restyle (Mac + phone) | **DONE** — fix `962a7305` (core) · `75b45ca9` (face + Mac) · `657bb57c` (phone) · `cb2251c4` (the pending-edit guard); pins `44ad276b`. Verified: core 2,799/320 headless; W1 red on old as designed; Mac W2 190/26 + u2b g1 106/13 green; phone u2b 59/10 green in one launch (the red pin `leavingATrailingSpace…` now green); W3 walk holds (Study only — the second voice not walked). PROVISIONALs P-U2-1/2/3 → QUESTIONS #219. Claim `vx282-u2b` HELD for U3's handover. |
| U3 | VX-154 — the take panel's remaining routed commands (+ the archive-receipt rider nit) | **DONE** — record `4e5d3464`; seams `04e0369f`; pins `fa90e851`; the fix `ae2277b7` (the registry fact) + `26ecec8c` (the panel). Stage window 01:18:43–01:35:12 (claim `vx282-u3`, RELEASED): W1 red on old as designed (23/2, 46 issues) · W1b revert B as designed (only the two ring checks red) · W2 the fixed batch 248 tests / 24 suites green · W3 every row held, both voices (logs `4c9ced16`/`38af3061`; the walk record below). P-U3-1…8 (QUESTIONS #220). No claim held; no revert in flight. |
| U4 | VX-193 + VX-112 — the capture box's undo desync and focus re-grab | **READY FOR STAGE — W1 red on old (old products) + W2 the Mac batch g1/g2 (fixed) + W3 a walk on the dev store (the bar, the pad, the tour in Terminal and Study, the away start), ≈42 min.** Traces `324bfda8`; pins ahead of the fix `c4f2a893` (+ the tour pin's isolation `bfd3ca38`); fix VX-193 `0c31fcc5`, VX-112 `6bb9c7c9`. Products built headless, TEST BUILD SUCCEEDED ×2: `DerivedData/vx282-u4-old-products` (pins over the pre-fix box, by the named revert `cdc842f0` — DONE and RESTORED, `git diff` empty) and `DerivedData/vx282-u4` (fixed). PROVISIONALs P-U4-1/2 (QUESTIONS #221). No claim held; no revert in flight. Every count PENDING. |
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

**NOT DONE in this unit (stated first):** the walk ran in ONE voice (Study, the dev store's own) — the second voice
was not walked (the Settings voice switch was not cheap in the window); the phone has no walk (its pins drive the
real `MobileEditorTextView` in a key window); the opener side and ⌘I/⌘B stay caret-blind by PROVISIONAL choice
(P-U2-1/P-U2-3, QUESTIONS #219).

**State: DONE** (2026-10-14 01:17 — every row verified: headless core, W1 red on old, W2 + u2b green, W3 walk).
Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-13/14. Fix commits: `962a7305` (core parser +
gate + ledger) · `75b45ca9` (face + the Mac's two live roads) · `657bb57c` (the phone) · `cb2251c4` (the
pending-edit guard, the W2b finding's fix). Pins ahead of the fix: `44ad276b`.

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

**THE u2b WINDOW — RUN 2026-10-14, 01:14:41 → 01:17:22 (the coordinator's GO, part 1 of a chained window; claim
`vx282-u2b`, HELD at the end for U3's chained handover; `guard.sh --author` OK before each leg; at the start no
Variorum instance, no booted simulator, the simulators freshly erased — iPhone 17 Pro iOS 26.2 present; nothing
rebuilt — the products built at `cb2251c4`).**
- **The phone, W2b re-run — GREEN** (`u2b-w2b-phone.log`, `-collect-test-diagnostics never`, a first boot and fresh
  install, ≈ 70 s in all): "**Test run with 59 tests in 10 suites passed**", ONE launch (0 "Restarting after
  unexpected exit"), `** TEST EXECUTE SUCCEEDED **`. **THE RED PIN IS GREEN:**
  `MobileMarkdownCaretTests.leavingATrailingSpaceBehindUnstylesTheSpanHonestly` ✔ (it crashed on the pre-guard
  product) — and it asserts the italic on the line right after `insertText("hello ")`, so the skipped mid-transaction
  settle WAS re-run after UIKit's transaction closed (the trace's inference, now observed). `herFlow…` ✔. All ten
  suites ✔: the four `MobileMarkdown*` suites, `MobileMarkdownCaretTests`, materialization & identity, routing &
  autosave, the verdict binding, the identity separator check, the crash reproductions.
- **The Mac g1 re-run (the shared settle changed) — GREEN** (`u2b-w2-g1.log`): "**Test run with 106 tests in 13 suites
  passed**", 0 skipped, `** TEST EXECUTE SUCCEEDED **` — identical to W2's g1. W2's g2 (84/13) ran before the guard
  and was not re-run, per the u2b plan: its panes settle through the same shared face, but on the Mac the guard never
  trips (the selection change and `textDidChange` both arrive after `processEditing`, measured), and the pane suites in
  g1 (`PaneMarkdownCaretFaceTests`) re-ran green through it.
- `xcrun simctl shutdown all` → **0 booted**; 0 Variorum instances; **the claim `vx282-u2b` still HELD** (~23 min left
  at 01:17) for U3's chained handover.

### U3 — VX-154 (the take panel's remaining routed commands)

**State: IN-PROGRESS.** Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-13/14. Every count and
every "green"/"red" below is **PENDING** until it runs (headless) or the stage window runs it.

**The ticket (verbatim):** *"every OTHER routed command still falls through to Write caret handlers under the sheet —
⌘S commit, comments, callout, take↔block commands, block delete/archive/insert, the structural verbs, history and
origin; ⌘⇧T swaps the sheet to the caret block panel. Same mechanism class; the panel registration is the worked fix
(0deda5b4, 2e5784ca). Rider nit: the panel archive receipt says archived · n while its own list header reads archived
takes."*

**The mechanism, re-traced in this session against `67344257` (VX-143's pointers verified; the code agrees):**
1. Every menu-bar door (`EditorCommands.swift:519/526/635-660/671-794/825/846`), and every ⌘K act row
   (`ShellActions.paletteAction`, `ShellActions.swift:797-840`), ends in `CommandRouter.dispatch`, which walks the
   handler stack LIFO — `handlers.reversed()`, the first handler that returns true consumes (`CommandRouter.swift:694-702`).
2. Write's take panel registers on appear and unregisters on disappear (`WriteTakesPanel.swift:193-195`, `:204-209`) —
   the LIFO top while it is up. Its handler claims ONLY `.takes(…)` (`guard case .takes` at `:226`) and of those hands
   `.toggleFan/.closeAll/.saveLens` back (`:273-274`). Every other `RoutedCommand` returns false.
3. The next handler down is Write's own (`EditorView.handleRouted`, `EditorView.swift:309`), registered by the
   `EditorView` the sheet hangs from (`:200`). Its arms address Write's CARET — `caretBlockID` / `caretVariantID`
   (the take Write SHOWS at the caret). So with the panel up, each falls through to the caret block beneath the sheet:
   a different block whenever the panel came from another block's ⑂ badge (`EditorView.swift:947`), and even on the
   caret's own block it acts at Write's caret, not on the take whose pane is live in the panel.
4. Where Write's arm PRESENTS something it is a second sheet on the same window (comments `EditorView.swift:222`, the
   lens name `:192`, the two ceremonies `:227/:232`, the tray/history/versions fallbacks) — AppKit queues a second
   `beginSheet` behind the one up, so it appears only after the panel closes (on the caret block). The savepoint
   name field is a popover on Write's bar beneath the sheet.
5. The panel's `TakesViewModel` is its OWN instance (`WriteTakesPanel.swift:85`; `authority` is per-instance,
   `TakesViewModel.swift:321`), so its ring can only stand in the panel's block — every card keys the panel's
   `blockID` (`:290`). That invariant holds today only because nothing in the panel ever focuses another block; the
   board's structural arms DO (`choreography.parkFocus` → `consumeLandings` → `focus(…takes-main…)`,
   `TakesChoreographer.swift:139`, `:151-159`), which matters to the rule below.

**Why ⌘⇧T, ⎋ and ⌘⇧L reached Write deliberately at VX-150** (`vx-143-write-chrome-feedback.md:124/:132/:136`,
ladder r1 item 4): VX-150's member was the TAKE keys — acts on a take of a block. These three were judged "not take
acts on a block": ⌘⇧T is a surface toggle ("takes at the block you're in"), ⎋ (`.closeAll`) closes the board's blooms
(grey in Write, a no-op arm there), ⌘⇧L saves the NOTE's choices (post scope). The same record's observation (2) left
⌘⇧T's swap as "arguably right ('takes at the block you're in'), arguably a jump; a taste call, untouched" — so it was
left, not ruled; VX-154's own body lists the swap among the symptoms. ⎋ and ⌘⇧L keep their reasons (unchanged here);
⌘⇧T changes (P-U3-4).

**Every routed command that can fire while the panel is up** (the panel's panes carry only the stock text menu and
Format — no `variorumMenu` is wired at `WriteTakesPanel.swift:331` — and Write's context menus and bars are beneath a
window-modal sheet, so the live doors are the MENU BAR and its keys; ⌘K's palette is a `.sheet` on `RootView`
(`RootView.swift:313`), expected to queue behind the panel like Write's own sheets — walk-verified at W3):

| # | Command · door/key | Today with the panel up (Write's arm) — which block | Built (U3) |
|---|---|---|---|
| 1 | `.commit` · File ▸ Commit Take ⌘S, ⌘K | `commitCaretVariant` → `askSavepointName` (`EditorViewModel.swift:3259/3268`): the field for Write's CARET take, a popover on Write's bar beneath the sheet | the take the panel's ring is in, else the take the block shows (the ring moves onto it, then the ask) — the board's `askSavepointName`; the field in the panel (P-U3-1) |
| 2 | `.comments` · Block ▸ Comments… ⌘⇧' | `openCaretComments` (`:3947`) → a queued comments sheet on the CARET block | the panel's block — the board's request, named; the panel presents the comments sheet (the Takes bar's twin, `TakesBottomBar.swift:309`) |
| 3 | `.callout(…)` · Block ▸ Callout, ⌥⌘C | `applyCallout` (`:3960`) frames the CARET block | frames the panel's block (`applyCallout(_:blockID:)`, 13k K6's named target) — silent, as on every surface (the panel draws no frame: P-U3-5) |
| 4 | `.copyAllTakes` · ⌘⇧C | `copyCaretBlockTakes` (`:3981`) — the CARET block's fan | the panel's block's fan (`copyAllTakes(blockID:)`), the receipt in the panel |
| 5 | `.takeToBlockBelow` · ⌥⌘⏎ | `moveCaretTakeIntoBlockBelow` — Write's shown take at the caret | the take the ring is in, named; no ring ⇒ the board's own refusal (strict — ⌘⇧A's precedent, P-U3-3) |
| 6 | `.takesToBlocks` · ⌥⇧⌘⏎ | `turnCaretBlockTakesIntoBlocks` — the CARET block | the panel's block (`turnTakesIntoBlocks(blockID:)`) |
| 7 | `.showBlockHistory` · ⌘K, the bars | `requestBlockHistory` (`:3335`) — the CARET block | the panel's block — the router first (the inspector), else the board's fallback sheet, presented by the panel |
| 8 | `.showOriginBlock` · ⌘K | `revealCaretBlockOrigin` (`:2936`) — the CARET block | the panel's block's originals (into History, as everywhere), or the honest `OriginPeekCopy.noOriginHere` |
| 9 | `.deleteBlock` · Block ▸ Delete Block, ⌘K | `deleteCaretBlock` — the CARET block | the panel's block (the board's arm, named); the panel's own gone face + the receipt; ⌥⌘Z (P-U3-2) |
| 10 | `.archiveBlock` · Block ▸ Archive Block | `archiveCaretBlock` — the CARET block | the panel's block (likewise) |
| 11 | `.insertBlockBelow` · ⌘⇧⏎, ⌘K | `insertBlockBelowCaret` — a block below the CARET, Write's caret into it | GREY while the panel is up (registry data); consumed with the panel's line if dispatched (P-U3-2) |
| 12 | `.addBlockAtEnd` · Block menu, ⌘K | `jumpToDocumentEnd` — Write's caret moves beneath the sheet | GREY (same) |
| 13 | `.structural(…)` · ⌘⇧D ⌥⌘⇧D ⌘⇧E ⌘⇧K ⌘⇧M ⌥⌘⇧M | `invokeGesture` at Write's caret/selection; the ceremony sheets queue | GREY (same) |
| 14 | `.deleteInEveryTake` · Block menu | over Write's selection beneath the sheet | GREY (same) |
| 15 | `.takes(.toggleFan)` · ⌘⇧T | `openCaretFan` (`:3377`): the caret's block ⇒ no-op; another block ⇒ the sheet SWAPS to the caret block's panel | CLOSES the panel — the toggle's close half (P-U3-4) |
| 16 | `.takes(.saveLens)` · ⌘⇧L | the NOTE's lens-name sheet (queued) | unchanged — note scope (VX-150's ruling) |
| 17 | `.takes(.closeAll)` · Block menu | grey in Write (registry: the Takes board only) | unchanged |
| 18 | `.pageFan(±1)` · ⌥⌘←/→ | grey in Write; Write declines | unchanged |
| 19–22 | `.toggleSeal` · `.saveNoteVersion` ⌘⇧S · `.showNoteVersions` · `.showNoteTray` | Write's — the NOTE (the same note the panel shows) | unchanged — note scope |
| 23 | `.find(…)` · ⌘F ⌥⌘F ⌘G ⇧⌘G ⌘E, Replace in Every Take | Write's find bar in its own scroll view beneath the sheet — the NOTE's text | unchanged — note scope |
| — | `.takes(.choose/.stepPrev/.stepNext/.archive/.branch/.blank/.blankChoose)` | already the panel's (VX-135/VX-150) | unchanged, + the archive receipt's words (the rider) |

**The rule built.** While Write's take panel is up, a routed command about a block or a take acts on the PANEL's
block — the take its ring is in where the act needs a take — through the Takes board's own arm with the panel's block
NAMED (13k K6's named-target convention: a named target never falls back to the routed one). Where the act needs a
take and the ring is in none: an ADDITIVE act (⌘S) takes what the block shows, P-VX150-1's ratified rule for ⌘T; an act
that takes a take OUT of the fan (⌥⌘⏎) refuses as the board does, ⌘⇧A's precedent (VX-150). The acts that cut, join or
add blocks where she writes (rows 11–14) cannot act honestly from a one-block sheet — their results land on blocks the
panel never shows, the board carries most of them to Write by a mode switch that a sheet over Write cannot make, and
the board's insert/divide arms park the ring on a block the panel does not render — so by P-2's last sentence ("a door
that can never act in its context isn't rendered") they are GREY while the panel is up, by registry data (the panel
reports itself to the router, the takes-board attachment's shape — P-1), and a dispatch that reaches the panel anyway
is consumed with one line, never handed to Write's caret. ⌘⇧T closes the panel. Commands about the NOTE keep reaching
Write — the note is the same note either way. One more invariant, made structural rather than coincidental: **the
panel's ring never stands outside its block** — the board's delete/archive and take-to-block arms park the ring on a
survivor or a minted block (`parkFocus`), a pane the panel never renders, after which ⌘⏎ / ⌘⇧A / ⌃⌘→ would act on a
block the panel does not show (this ticket's class, one step later). `TakesViewModel.writePanelBlockID` (set only by
the panel) makes `focus(_:)` blur instead of landing on another block.

**Where canon decides, and where it does not.** AppSpec §9's ops are untouched (every act is an existing operation
through the board's existing body). P-1/P-2 decide the grey (gating is data; a door that can never act in its context
is not rendered). 13k K6 decides the named target (a scoped surface names its block; a named target never falls back).
P-VX150-1 (ratified, QUESTIONS #210) decides ⌘S's no-ring fallback by extension, and VX-150's own ⌘⇧A arm decides
⌥⌘⏎'s strictness by the same reading. VX-150's "fall through by design" for ⌘⇧L decides the note family. Nothing rules
⌘⇧T's meaning over an open panel, the act/grey split, or the copy — PROVISIONAL below.

**The diff (seven app files, one new test file, one test edited; zero `Sources/`, `Sync/`, custody, Keychain, schema,
`Shared/`; nothing in `EditorSurfaceController`, `BlockRangeIndex`, `EditorEditRoute`/`SeamCarvePlan`,
`EditorViewModel`, `runStructural` or the markdown face):**
- `Registry/Capability.swift` — `CapabilityContext.writeTakesPanelAttached` (default false). `Registry/CommandRouter.swift`
  — `attachWriteTakesPanel()` / `detachWriteTakesPanel(_:)`, a token set + an observable flag (the takes board's
  attachment shape), carried into `currentContext()`. `Registry/CapabilityRegistry.swift` — `outsideWritesTakesPanel(_:)`
  wraps the nine verbs' OWN rules (`divideAvailability` ×2, `structural` ×5, `takeFamily` ×2); with the panel down every
  answer is byte-unchanged (`ae2277b7`).
- `Features/Takes/WriteTakesPanel.swift` — the init gains `onClose:` (the host's close road; nil = `dismiss`) and a pin's
  road in for its model (`model:`; nil = it builds its own, as before) (`04e0369f`); it scopes its model to its block
  (`writePanelBlockID`), attaches to the registry on appear and detaches on disappear, claims the commands per the table
  (`handleRouted` → the new arms + `handleTakesKey`, VX-150's arms moved verbatim), and presents what its arms raise —
  the savepoint name ask (on its header, arrow below), comments, Block History's fallback and its tray (the Takes bar's
  presentations, same model requests, `TakesBottomBar.swift:292-351`'s twins; a shared modifier for both hosts is a
  possible follow-up, not built — it would move the bar's code, outside this unit) (`26ecec8c`).
- `Features/Takes/TakesViewModel.swift` — `writePanelBlockID` + `ringMayStand(on:)` guarding `focus(_:)` and
  `landAuthorityFocus(_:)` (nil ⇒ always true: the boards unchanged); `archiveTake`'s panel receipt
  (`writePanelArchiveReceipt`); the named-target form for `requestComments`, `revealFocusedBlockOrigin`,
  `deleteFocusedBlock`, `archiveFocusedBlock` (`applyCallout`/`copyAllTakes`'s shape; nil ⇒ byte-for-byte the routed
  target). `Features/Takes/TakesStructureController.swift` — `deleteFocusedBlock(blockID:)`/`archiveFocusedBlock(blockID:)`
  through `targetSlot(named:)` (a named block is looked up, never replaced by the routed target), and
  `clickIntoATakeToMoveIt` hoisted to ONE literal for the board and the panel.
- `Features/Editor/EditorView.swift` — the sheet passes `onClose: { model.fanPanel = nil }` (its own binding). Not on
  VX-246's courtesy list (`EditorView` ≠ `EditorSurfaceController`/`EditorViewModel.storageDidEdit`).
- **Outside the run's declared surfaces** ("the Write take panel's routed-command registration"): the three Registry
  files, `TakesViewModel`/`TakesStructureController` (additive named-target parameters and the scope fact), and
  `EditorView`'s one-line sheet wiring — each is the panel's routing's own consequence; said here and in the report.

**The pins — `WriteTakesPanelRoutedCommandTests` (new, `.serialized`; `WriteTakesPanelRoutedTests.swift`).** The real
panel mounted over a fanned block that is NOT Write's caret block, a stand-in for Write's handler beneath it consuming
EVERY routed command (as the real one does), the router's `writeEditorAttached` wired true (Write is mounted beneath in
the app), the panel's own model passed in. Store-asserted wherever the act writes. RED ON OLD = against the pins-first
product (`fa90e851`'s, whose app code is pre-fix; the seams it carries are behaviour-neutral):

| Test | Asserts | Old |
|---|---|---|
| `commitAsksForTheTakeTheRingIsInAndFilesIt` | ring in take 2 → ⌘S: stand-in never saw it; the ask names take 2; filing writes ONE commit on take 2, named; none on the caret take | RED |
| `commitWithNoRingAsksForWhatTheBlockShows` | no ring → ⌘S: the ask names the shown take; the ring moved onto it | RED |
| `commentsOpenOnThePanelsBlockInThePanel` | ⌘⇧': the request is the panel's block; a sheet is attached (the panel presented it) | RED |
| `theCalloutFramesThePanelsBlock` | ⌥⌘C: the panel block's `presentation` is a callout; the caret block's stays nil | RED |
| `copyAllTakesCopiesThePanelsFan` | ⌘⇧C: the general pasteboard holds the panel's fan, not the caret block's (saved + restored around the test — `PlainPasteDoorTests`' precedent) | RED |
| `aTakeIntoABlockBelowMovesTheRingsTakeAndTheRingStaysHome` | ring in take 2 → ⌥⌘⏎: the page reads caret · shown · "the second take"; take 2 archived on the panel's block; caret block untouched; **`focusedPane == nil` after** (the scope guard) | RED |
| `aTakeIntoABlockBelowWithNoRingRefusesAndMovesNothing` | no ring → ⌥⌘⏎: a refusal in the panel; nothing minted; no take left the fan; stand-in never saw it | RED |
| `allTakesIntoBlocksActsOnThePanelsBlock` | ⌥⇧⌘⏎: the page reads caret · shown · second · third; caret block untouched | RED |
| `blockHistoryOpensForThePanelsBlock` | History: the request is the panel's block, presented by the panel (no detail in the harness ⇒ the fallback) | RED |
| `originOpensThePanelsBlocksOriginals` | the panel's block is a MERGE: the origin door opens ITS History | RED |
| `deleteBlockDeletesThePanelsBlockAndTheRingNeverLeavesIt` | ring in take 2 → Delete Block: the panel block tombstoned, caret block live, the gone face, **`focusedPane == nil` after** (not the survivor) | RED |
| `archiveBlockArchivesThePanelsBlock` | Archive Block: the panel block's `archived_at` set; the caret block's not | RED |
| `theWriteVerbsAreGreyWhileThePanelIsUpAndNeverReachTheCaret` | the nine are `isEnabled == false`; dispatched anyway: none reaches the stand-in, the panel refuses, the page still has 2 blocks | RED |
| `showTakesClosesThePanel` | ⌘⇧T: the host's close road called once; the stand-in never saw it | RED |
| `theArchiveReceiptNamesThePanelsOwnList` | ⌘⇧A (ring in take 2): a receipt containing "archived takes", not "archived · n" | RED |
| `theNoteCommandsStillReachWrite` | seal, ⌘⇧S, Versions, tray, ⌘⇧L, close-all, ⌘F all reach the stand-in | GUARD |
| `whenThePanelClosesEveryCommandIsWritesAgain` | after unmount: Divide / New Block Below enabled again; every claimed command reaches the stand-in (the lifecycle pin) | GUARD |

- **Edited:** `WriteTakesPanelKeysTests.theBloomAndLensKeysStillReachWriteAndEverythingReturnsWhenThePanelCloses` — ⌘⇧T
  left its "still reaches Write" list (now `[.closeAll, .saveLens]`), pointing at `showTakesClosesThePanel` (P-U3-4).
  Green on both sides as edited.
- **Not red-on-old by construction, so proven by a discriminating revert — REVERT B (the ring-scope guard alone):** on the
  old product the acts that park the ring never reach the panel, so the guard's two `focusedPane == nil` expectations
  cannot be red there. Revert B (`ringMayStand` returns true; applied to the working tree only, built, restored by
  `git checkout --` from `26ecec8c`, `git diff` empty, the fixed product rebuilt) — EXPECTED: ONLY those two expectations
  red, everything else in the suite green.

**The products (one new tree, two products set aside — 455 MB each, `Build/Products` only; the `.xctestrun` is
relocatable via `__TESTROOT__`):** `DerivedData/vx282-u3-old-products` (the build of `fa90e851`: pins + seams + the
pre-fix app) · `DerivedData/vx282-u3-revB-products` (the fix minus the guard) · `DerivedData/vx282-u3` (the build of
`26ecec8c`, the fixed product). All three **TEST BUILD SUCCEEDED**; zero warnings in the touched files. No core or
`Shared/` file touched — no `swift test` and no phone build owed.

**PROVISIONALs (QUESTIONS #220):**
- **P-U3-1 — ⌘S with no take clicked into commits what the block shows**, the ring moved onto it first. Built (a): P-VX150-1's
  ratified rule, and what Write's caret arm committed when the panel was the caret block's (no regression there).
  Options: (b) refuse as the Takes board does ("Click into a take first — ⌘S commits the take you're in."); (c) ask for the
  shown take without moving the ring.
- **P-U3-2 — the act/grey split.** Built (a): the panel ACTS on its own block for delete block, archive block and the
  take↔block pair (results the panel can show: its gone face, takes leaving its fan); the nine verbs that cut, join or add
  blocks where she writes are GREY while the panel is up. Options: (b) those nine close the panel and run in Write AT THE
  PANEL'S BLOCK (fire-and-DO — needs a new road for an already-mounted Write editor to take a carried landing: editor-seam
  machinery, not built); (c) grey delete/archive and the take↔block pair too (the panel never changes the note's blocks);
  (d) act on all of them as the Takes board does (divide/insert would land on blocks the panel never shows, and
  extract/merge have no native board road — they carry to Write).
- **P-U3-3 — ⌥⌘⏎ needs the ring.** Built (a): no ring ⇒ the board's own refusal (an act that takes a take OUT of the fan,
  ⌘⇧A's precedent). Option: (b) the shown take, P-VX150-1's rule (what Write's caret arm moved in the caret-block case) —
  moving the CHOSEN take out is the riskier default.
- **P-U3-4 — ⌘⇧T over the panel CLOSES it** (the toggle's close half; the board's ⌘⇧T closes a bloom). Options: (b) the
  swap to the caret block's panel (VX-150's untouched "arguably right" — the ticket lists it as a symptom); (c) nothing.
- **P-U3-5 — a callout set from the panel is silent** (as on every surface — the frame is the feedback) and the panel draws
  no frame; it shows on Write's page the moment the panel closes. Options: (b) a receipt in the panel; (c) the panel wears
  the frame (the board's `TakesCalloutFrame`) — a new face, not built.
- **P-U3-6 — copy (her copy pass):** the archive receipt "Take archived — never gone: “archived takes” below brings it
  back." (the rider) and the grey verbs' line "That works in the note itself — close the takes panel first." (heard only
  by a dispatch that bypasses the greyed menu).
- **P-U3-7 — the note's own commands keep reaching Write while the panel is up** (seal, ⌘⇧S, Versions, the tray, find,
  ⌘⇧L — VX-150's ⌘⇧L ruling widened to the note family). Those that PRESENT something do so beneath or after the panel
  (Write's find bar, ⌘⇧L's name sheet, the no-inspector hosts' fallback sheets queue behind it). Options: (b) grey them
  while the panel is up; (c) the panel presents them.

**Observations (not fixed — for the orchestrator to ticket or dispose):**
- **O-1 (same class, not routed):** File ▸ Export Block… (`ShellActions.exportCaretBlock`, `ShellActions.swift:350`) exports
  Write's CARET block while the panel is up — a direct call, outside the routed vocabulary this ticket covers.
- **O-2:** ⌃⌘↑/⌃⌘↓ (previous/next block, a direct editor call) move Write's caret beneath the sheet — invisible, writes nothing.
- **O-3 (the rider's twin):** `TakeStructureCopy.movedNote` (⌥⌘⏎'s receipt, shared by Write and the boards) names
  "“archived · n” under its takes" — read in the panel now, and in Write, whose road back is this panel's "archived
  takes". Shared copy on Write's road — not changed here.
- **O-4 (the recorded two-windows keying family):** the handler stack and the grey fact are app-wide; with the panel up in
  one window it answers commands meant for another window's surface. Pre-existing (VX-135's registration); U3 widens what
  the panel answers.
- **O-5 (U5 overlap):** the panel is now a FOURTH host of `CommentsPanel` (a nested sheet — Write's sheet, the Takes bar's
  sheet and `TakesShared`'s popover are the others). VX-257's park-on-host-closing must cover a sheet host the way it
  covers the bar's. No overlap with VX-183's registry declarations (U3 declares no comment door).
- **O-6:** ⌘K's palette is a `.sheet` on `RootView`; expected NOT to open while the panel is up (AppKit queues a second
  sheet) — W3 probes it. If so, History, origin, seal, Versions and the tray have no live door while the panel is up; their
  arms are still the panel's for any road that reaches.

**THE WINDOW PLAN (≈42 min; runs only on the orchestrator's claim line; `guard.sh --author` before every leg; `pgrep`
first — no `/Applications/Variorum.app` instance, none of ours).** From `App/Variorum/`; logs to
`notes/plans/vx282-screens/u3/logs/`, captures to `notes/plans/vx282-screens/u3/`.
- **W1 — red on old (≈5 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u3-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
  -only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests -only-testing:VariorumTests/WriteTakesPanelKeysTests`
  → `w1-red-on-old.log`. EXPECTED: the fifteen RED rows above red; the two GUARDS green; `WriteTakesPanelKeysTests`
  wholly green.
- **W1b — revert B (≈3 min):** the same with `-xctestrun DerivedData/vx282-u3-revB-products/Variorum_Variorum_macosx27.0-arm64.xctestrun`,
  `-only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests` → `w1b-revB.log`. EXPECTED: ONLY
  `aTakeIntoABlockBelow…StaysHome` and `deleteBlock…NeverLeavesIt` red, each on its `focusedPane == nil` alone.
- **W2 — the fixed Mac batch (≈12 min), `-derivedDataPath DerivedData/vx282-u3`, two groups (suite TYPE names, grepped):**
  (g1) `WriteTakesPanelRoutedCommandTests` `WriteTakesPanelKeysTests` `WriteTakesPanelChooseTests` `WriteTakesPanelTests`
  `PostDetailRoutingTests` `CommandRouterTests` `MoveAndExecuteTests` `TakesLandingTests` `CapabilityRegistryTests`
  `TakeCardDoorTests` → `w2-g1.log`; (g2) `TakeToBlockDoorTests` `CopyAllTakesDoorTests` `OriginBlockDoorTests`
  `ArchivedListingTests` `TakesChooseRingTests` `TakesArticleScrollTests` `SavepointTakesDoorTests`
  `SavepointCommitDoorTests` `RecoveryDoorsTests` `BlockHistoryPaneTests` `NewModesTests` `NoteTrayTests`
  `TutorialTakesActsTests` `TutorialDeletionActsTests` → `w2-g2.log`. Read every suite's ✔/✘ line and the skips (a wrong
  name runs 0 tests and still "succeeds").
- **W3 — the walk (≈22 min), `DerivedData/vx282-u3/Build/Products/Debug/Variorum.app` on the DEV store only** (dismiss a
  What's New sheet if shown; the voice as found, recorded). Stage the note through the shelf's quick-entry bar:
  `{t:"VX-154 walk"}alpha` ⇧⏎ `beta` ⏎ → it opens in Write. Caret into `beta` (⌘↓), ⌘T twice (a fan of three), then
  ⌘↑ (the caret back in `alpha` — the caret block is NOT the panel's). Open `beta`'s panel from its ⑂ badge (located by a
  region capture, clicked by `cliclick`); click into its second take. Region captures before/after each row:
  1. **⌘S** → the name field in the panel (capture) → type `walk` ⏎ → the receipt (capture); `alpha`'s take untouched.
  2. **⌘⇧'** → the comments sheet for `beta`'s block over the panel (capture) → close it by its own Close.
  3. **The Block menu opened** (`cliclick` on the menu bar) — Divide, Extract, Make Block, Merge, the two "choosing
     takes", Delete in Every Take, New Block Below, New Block at End GREY; Delete/Archive Block live (capture) → ⎋;
     then **⌘⇧D** → nothing happens (capture).
  4. **⌘K** → does the palette open over the panel? (capture — O-6); if it does, "Block History" ⏎ → `beta`'s history
     (capture).
  5. **Block ▸ Archive Block** → the panel's gone face + the receipt; Write beneath keeps `alpha` (capture) → **⌥⌘Z** →
     `beta` returns (capture).
  6. **⌘⇧T** → the panel CLOSES; Write, caret still in `alpha`, no swapped sheet (capture).
  7. **Lifecycle:** ⌘S now → Write's own name field for `alpha`'s take (capture) → ⎋.
  8. **The second voice** (⌘K "Use Terminal Voice" / "Use Study Voice", whichever is not current): reopen `beta`'s panel
     from its badge, click into a take, ⌘S (capture the field in the panel) → ⎋ → ⌘⇧T → restore the voice found.
  Then the walk note to the Trash (residue recorded), quit OUR instance by identity, `pgrep` again, the dev store left
  Standard and unlocked with its voice as found, release the claim.

**THE STAGE WINDOW — RUN 2026-10-14 (the coordinator's GO, part 2 of its chained window: `Tools/stage release --who
vx282-u2b && Tools/stage claim --who vx282-u3 …`, claimed 01:18:43; `git pull --ff-only` first — U2's and U4's commits on
the branch, NOT in these products, by the no-rebuild rule; `guard.sh --author` OK before every leg; 0 Variorum instances
and 0 booted simulators at the start). Logs: `notes/plans/vx282-screens/u3/logs/`.**
- **W1 — RED ON OLD, AS DESIGNED** (`w1-red-on-old.log`, the old products, 01:18:55–01:19:51): "Test run with **23 tests
  in 2 suites failed** … **46 issues**". All fifteen RED rows red, every issue on a designed expectation (the stand-in saw
  the command; the ask/request/store/clipboard never moved; the nine `isEnabled` live; `closes == 0`; the receipt named
  "archived · n"). GREEN on old: the two GUARDS (`theNoteCommandsStillReachWrite`, `whenThePanelClosesEveryCommandIsWritesAgain`)
  and `WriteTakesPanelKeysTests` 6/6 (incl. the narrowed characterization). *(On old the two ring checks are red too —
  the ring simply stays in take 2 when nothing acts; W1b is what isolates the guard.)*
- **W1b — REVERT B, AS DESIGNED** (`w1b-revB.log`, the fix minus the ring guard, 01:20:02–01:20:37): "**17 tests in 1 suite
  failed** … **2 issues**" — exactly `aTakeIntoABlockBelowMovesTheRingsTakeAndTheRingStaysHome` (`:409`, `focusedPane == nil`)
  and `deleteBlockDeletesThePanelsBlockAndTheRingNeverLeavesIt` (`:500`, `focusedPane == nil`), one issue each; the other
  fifteen green. The guard is load-bearing: without it the ring lands on the minted block / the survivor.
- **W2 — THE FIXED MAC BATCH, GREEN** (`DerivedData/vx282-u3`, the build of `26ecec8c`): g1 (`w2-g1.log`, 01:20:42–01:22:13)
  "**87 tests in 10 suites passed**"; g2 (`w2-g2.log`, 01:22:18–01:24:34) "**161 tests in 14 suites passed**" — **248 tests /
  24 suites, 0 skipped** (every suite's ✔ line read; the two "skipped" grep hits are a test's NAME), `** TEST EXECUTE
  SUCCEEDED **` ×2.
- **W3 — THE WALK, EVERY ROW HELD** (01:25–01:34; the `vx282-u3` Debug app — the build of `26ecec8c`, pid 81959 — on the
  DEV store: "Sync off (dev store)", unlocked, no lock screen met, no What's New sheet, voice **Study** as found; every key
  through `keys.sh`, every click through `click.sh`, ≥ 3 s apart — a 1 s gap tripped the guard on my OWN click's HID event
  once, before any keystroke was sent; idle had been 2,914 s). Staged through the shelf's quick-entry bar:
  `{t:"VX-154 walk"}alpha` ⇧⏎ `beta` ⏎ → opened in Write; ⌘↓ ⌘T ⌘T (beta ⑂3), ⌘↑ (the caret back in `alpha`, block 1/2);
  `beta`'s panel opened from its ⑂ badge — **the panel's block is NOT the caret block** (`w3-00`, `w3-01`). Captures:
  `notes/plans/vx282-screens/u3/` (window captures, downsized; the one full-screen menu capture cropped to the app's
  region and the full frame deleted — it held the desktop).
  1. **⌘S — HOLDS.** Ring in take 2 → ⌘S: the name field opened **in the panel** under its header (`w3-02`), not on Write's
     bar beneath → `walk` ⏎ → "Committed “walk” — an immutable saved moment of this take." in the panel and the bar
     (`w3-03`). **Where it landed** (checked after the panel closed, the caret put in `beta`, Block History from the bar):
     take 1 of 3 — 0 · **take 2 of 3 — 1** · take 3 — 0 (`w3-13`): the ring's take of the PANEL's block; `alpha` committed nothing.
  2. **⌘⇧' — HOLDS.** The comments sheet came up **over the panel at once** (`w3-04` — before the fix Write's comments sheet
     would queue behind the panel, on the caret block); a comment filed with ⌘⏎ shows in the page's gutter **beside
     `beta`** (`w3-05`). Closed by its own Close.
  3. **The Block menu — HOLDS.** Enabled states read through System Events (`logs/w3-block-menu-panel-up.txt`): GREY —
     Divide Block at Cursor, Divide choosing takes…, Extract Selection, Make Block from Selection, Merge Blocks, Merge
     choosing takes…, Delete in Every Take, New Block at End of Note, New Block Below (the nine), plus Close All Takes and
     the two page items (Write's standing grey); LIVE — Delete Block, Archive Block, the take family, Save Choices as Lens…,
     Copy All Takes, Move Take into a Block Below, Turn All Takes into Blocks, Previous/Next Block, Comments…, Callout, Toggle
     Block Seams. The menu opened and captured (`w3-06`). **⌘⇧D → nothing** (`w3-07`: `alpha`/`beta`, block 1/2, the fan
     and the line unchanged).
  4. **⌘K — O-6 CONFIRMED.** The palette did **not** open over the panel (`w3-08`); it was QUEUED and came up the moment the
     panel closed at row 6 (`w3-11`). So History/origin/seal/Versions/tray have no live door while the panel is up (their
     arms stay the panel's, pinned); the queued-palette-appears-later behaviour is pre-existing (the palette is `RootView`'s
     sheet) — for the orchestrator to ticket.
  5. **Block ▸ Archive Block — HOLDS.** The PANEL's block went: the panel's own face "This block is no longer in the note."
     with "Block archived — it's kept, with no countdown, in This Note's Tray … ⌥⌘Z undoes this."; Write beneath kept
     `alpha` (block 1/1) (`w3-09`). **⌥⌘Z** → `beta` back with its fan and comment, "Undid: Archive Block", and **no card holds
     the ring** — the guard blurred it instead of landing it on `alpha` (`w3-10`).
  6. **⌘⇧T — HOLDS.** The panel **closed**; Write with the caret still in `alpha`, no sheet swapped in for `alpha` (`w3-11`,
     where the queued palette then appeared — dismissed with ⎋).
  7. **Lifecycle — HOLDS.** With the panel closed, ⌘S opened **Write's own** field at the bar's commit door for `alpha`'s
     take (`w3-12`) → ⎋.
  8. **The second voice (Terminal, via ⌘K "Use Terminal Voice") — HOLDS.** Caret back in `alpha`, `beta`'s panel reopened
     from its badge (`w3-14`); **⌘S with NO take clicked into** (P-U3-1's road): the field opened in the panel (`w3-15`) and,
     after ⎋, the ring stood in the **chosen** take (`w3-16`); ⌘⇧T closed the panel (`w3-17`). Voice restored to **Study** via
     ⌘K "Use Study Voice" (`w3-18`).
  - **Walk finding W-1 (taste, recorded as P-U3-8):** the ⌘S field hangs below the panel's HEADER, so it covers the FIRST
    card — in the no-ring case exactly the take being committed (the ring on it is hidden until the field closes)
    (`w3-15`). Option: anchor the ask on the take's own card (the in-sidebar-box placement's "nearer where she typed").
  - **Residue:** the note "VX-154 walk" moved to the Trash by its own note ▾ › Delete Note… › Delete ("Note moved to the
    Trash — 30 days to put it back.", `w3-19`) — with it beta's commit "walk" and the comment "walk comment on beta".
  - **Posture as left:** our instance quit by identity (`tell application id "io.lduarte.Variorum.debug" to quit`;
    `pgrep -x Variorum` → none — two loose `pgrep -f` hits were the VX-246 session's `nm` command lines, not apps); 0
    booted simulators; the dev store Standard (custody never touched), unlocked, voice **Study** (as found), appearance
    `system` (unchanged). **Claim RELEASED 01:35:12** (`Tools/stage release --who vx282-u3`; status FREE).

### U4 — VX-193 + VX-112 (the capture box: the undo desync and the focus re-grab)

**State: READY FOR STAGE** (the window plan at the end of this section). Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-14. Every count and every
"green"/"red" below is **PENDING** until it runs (headless) or the stage window runs it.

**The surface:** `Core/Views/CaptureTextView.swift` (the ONE capture box, 13u3 UNIT C) and its two hosts —
`Features/Shelf/QuickEntryBar.swift` (the Bookcase's and the Library's bar) and `Features/QuickNote/QuickNoteView.swift`
(the quick-note pad). Both members live in the box's coordinator and its `NSTextView` subclass; neither host needs a line
(traced below).

#### VX-193 — the trace (re-done in this session against `8ba431b2`)

1. Typing reaches the binding by ONE road: `CaptureTextView.Coordinator.textDidChange` → `parent.text = view.string`
   (`CaptureTextView.swift:334-337`). Both hosts file the BINDING, never the view: the bar's ⏎ → `QuickEntryBar.submit()`
   → `QuickEntryModel.submit()` reads `text` (`QuickEntryBar.swift:79-80`, `:317-321`); the pad's ⏎ / ⌘⏎ / close / quit →
   `QuickNotePad.take()` reads `text` (`QuickNoteView.swift:158-159`, `:414-428`, `:391-411`). The placeholders and the
   title chip read the binding too (`QuickEntryBar.swift:229`, `:280`; `QuickNoteView.swift:295`, `:310`).
2. **⌘Z / ⇧⌘Z change the box's text with NO `textDidChange`.** MEASURED again here (a windowless TK2 `NSTextView` probe,
   no window, nothing on screen; the scratch program is not committed): type `first thought`, break coalescing, type
   ` and more` → two `textDidChange`; `undo()` → the view reads `first thought` with ZERO `textDidChange`; `redo()` →
   `first thought and more`, again zero. VX-179's U3-g measured the same on the real box (O-U3-3).
3. So after ⌘Z the box shows one text and the binding holds the pre-undo text, and ⏎ files the words she undid — in
   both hosts (the pad's ⌘⏎ button and its close/quit filing read the same stale binding). After ⌘Z → ⌘Z → ⇧⌘Z the
   binding is still the last TYPED state, so redo desyncs as well.
4. **The sibling defect, same mechanism class (VX-179 U3-g's FIRST half — not named on the ticket, found by carrying
   the precedent):** the box's typing history lives in the WINDOW's undo manager (the coordinator implements no
   `undoManager(for:)`; `allowsUndo = true`, `CaptureTextView.swift:193`), and a programmatic adopt
   (`updateNSView`'s `view.string = text`, `:254-262`) leaves that history standing — MEASURED here (windowless probe:
   `canUndo` stays true after `string = ""`) — and ⌘Z then replays typing ranges of the OLD text against the new one:
   MEASURED, `NSRangeException … Range {0, 3} out of bounds; string length 0`. The box is cleared programmatically on
   every completed hand-off (`QuickEntryModel.submit` `:118-121`, `QuickNotePad.take` `:199-202`), and — the road where
   the box STAYS on screen with the caret in it — on an EMPTY filing: a whitespace-only or tokens-only capture
   (`QuickEntryModel.submit` `:82-91`; `QuickNotePad.take` `:166-175`, the pad stays open on `.nothingToFile`,
   `:426`). Type three spaces, ⏎, ⌘Z: the exception.

**The fix — VX-179 U3-g's mechanism, carried unchanged** (`CommentTextArea.swift:215-298`; the trace shows the capture
box needs nothing different): the coordinator owns the box's `UndoManager` and answers `undoManager(for:)` with it (⌘Z's
road: `undo:` travels to the window, which undoes through the first responder's manager — VX-179's measurement); it
hears its OWN manager's `NSUndoManagerDidUndoChange` / `DidRedoChange` and re-syncs the binding; a programmatic adopt
ENDS the history (`removeAllActions()`). Measured here before relying on it: the observer (queue `.main`) runs
SYNCHRONOUSLY inside `undo()`, top level and inside a main-queue job alike — so no SwiftUI update can run between the
undo and the binding's sync with the stale text (which would re-adopt it and erase the undo).

**P-VX179-U3-4 carried:** "undo is PER AREA and a programmatic replacement ends it" (#215 — still open there, her eye in
daily use). For the capture box it reads: ⌘Z in the box undoes the box's own typing and nothing else (on the old tree it
could reach whatever else sat on the window's stack), and after a hand-off or an empty filing there is nothing to undo
into. Carried as PROVISIONAL here with the same options (P-U4-1).

#### VX-112 — the trace (re-done in this session against `8ba431b2`)

What can put the caret in the box (every `makeFirstResponder(box)` road in the code): (i) `CaptureNSTextView
.viewDidMoveToWindow` while `wantsInitialFocus` (`CaptureTextView.swift:386-394`); (ii) `Coordinator.takeFocus()` from
`updateNSView` when the counted `focusRequest` changed (`:264-267`, `:323-332`); (iii) her click. Nothing else in the app's
code names the box (AppKit's own key-view loop on Tab aside).

- **Candidate 1 — the "asked ONCE" flag is never cleared: a REAL defect of the shared box.** `wantsInitialFocus` is set
  once in `makeNSView` from `focusRequest > 0` (`:229`) and read on EVERY arrival in a window (`:386-394`); the doc says
  "Asked ONCE, on arrival" (`:359-363`). So a box MADE with a raised request re-claims the keyboard on every
  re-attach — after any release, and over any other responder (the deferred block checks only `firstResponder !==
  self`). **Which boxes carry the flag:** the pad's, always (`QuickNoteView.focusRequest` starts at 1, `:244`). The
  bar's, on NO traced road: its request is raised by `QuickEntryBar`'s `.task` (`:312-314`), which runs at least one
  main-queue turn after `makeNSView` built the box with the request still 0 — so the bar's flag is false and candidate
  1 cannot re-grab the bar. **The held-focus half is broken the other way on the bar:** a re-attach while the bar HOLDS
  the caret drops it to the window (TEXTKIT2 §3, 18l-c U7) and nothing re-takes it (its flag is false) — the keyboard
  lost silently, `PaneTextView`'s pre-U7 class.
- **Candidate 2 — the Bookcase's own mount autofocus (R102, `QuickEntryBar.swift:312-314`): live when the Bookcase
  MOUNTS after the tour's release.** `startTour()` (`RootView.swift:990-1002`) sets the engine; the engine's `init`
  performs `navigate(.bookcase)` in that same turn (`TourEngine.swift:57-69`) when she is elsewhere; the overlay and the
  Bookcase mount in the following update, the probe's arrival releases the window's first responder synchronously
  (`TourOverlay.swift:76-80`, `:523-528`), and the bar's `.task` raise lands at least one turn later → `takeFocus` → the
  caret in the bar during step 1. So a tour started AWAY from the Bookcase (Help ▸ Take the Tour from a note) ends step
  1's first turn with the caret in the bar. **Not her walk's road:** that tour started from the offer line, which lives
  only on the Bookcase (`ShelfView.swift:240`; `RootView.swift:975-978`, `:1161`), and `navigate` returns early when
  she is already there (`RootView.swift:1015-1018`) — no mount, no raise.
- **A third reading of her walk's evidence (the 13s U2 WALK RECORD, `phase-13s-voice-onboarding.md:567`):** the walk ran
  in DARK TERMINAL and the evidence it quotes is "the caret block visible mid-tour". The Terminal voice draws a blinking
  accent BLOCK cursor in the empty bar exactly while the box does NOT hold the caret (`QuickEntryBar.swift:235-246`,
  17y B2 (m)) — so the tour's release itself turns that block ON. Nothing in that record says a key was typed into the
  box. On my static trace neither candidate fires on her road, and the block cursor explains the sighting completely.
  **W3 decides it** (both voices — Study draws no block cursor — with the focused element read by AX and one keystroke).

**The rule built (her ruling as recorded in this run: "the shared capture box re-takes only focus it HELD, never
steals"):** `PaneTextView`'s rule (`PaneSurface.swift:583-620`), in the shared box. The initial request is served ONCE,
on the first arrival, and cleared (the doc's own "asked ONCE"); a box that held the keyboard when it was detached
re-takes it on re-attach, and only when the window itself holds the keyboard (nil or the window) — so it never steals
from a field, a sheet or anything else that took it meanwhile, and a box that did NOT hold it (released by the tour or
anyone) stays away. The EXPLICIT requests keep today's behaviour exactly — the counted request (`takeFocus` — her padding
click, the title chip, the Bookcase's mount raise) and the initial request's own deferred serve (its guard is still
"not already mine", so the pad opens with the caret wherever it does today, whatever SwiftUI's hosting view holds at
that moment); an explicit request is not a re-take. One robustness line: an initial request whose deferred serve finds
the box out of its window is re-armed for the next arrival rather than lost (the old never-cleared flag served it there
by accident). **Candidate 2 is NOT changed** (the brief: the first-mount autofocus
works where it does today): whether the Bookcase's mount autofocus should stand down while a tour runs is a product call
the rulings do not make — P-U4-2. **The residual race, recorded as the 13s record did:** a release that lands WHILE the
box is detached (the window already holds the keyboard, so the release changes nothing observable) cannot be told from
the detach's own drop; the box re-takes. `PaneTextView` carries the same residual.

#### The pins — `VariorumTests/CaptureUndoAndFocusTests.swift` (new; committed AHEAD of the fix, `c4f2a893`)

Five suites (suite TYPE names). The box is the production `CaptureTextView` in a real titled window beside an
`NSTextField` (another responder); the hosts are the production `QuickEntryBar` and `QuickNoteView` over an in-memory
store (`AppDatabase.inMemory()`, injected — never the default path). ⌘Z/⇧⌘Z go by their own road (`undo:`/`redo:` up the
responder chain from the box); ⏎ is the real `keyDown` with a Return event. Settles suspend (yield + 10 ms per turn) so
the box's deferred focus serve and the hosts' filing `Task`s run (VX-179 U3's FIX LEG lesson). RED ON OLD = against the
build of `c4f2a893` (the pins over the pre-fix app).

| Suite · test | Asserts | Old |
|---|---|---|
| `CaptureUndoSyncTests` · `anUndoAndARedoReachTheBinding` | type `first thought` + ` and more`; ⌘Z, ⌘Z, ⇧⌘Z: after each, the binding == the box (non-vacuity: the box really moved) | RED (3 — each binding cell) |
| `CaptureUndoSyncTests` · `aProgrammaticClearEndsTheBoxsOwnHistory` | the box's undo manager is NOT the window's; the host clears the binding → `canUndo == false` (a `#require`, so the old tree stops BEFORE the ⌘Z that raised there); ⌘Z changes nothing; new words undo alone, binding and all | RED (2 — the identity cell and the `#require`) |
| `CaptureHostsUndoFilingTests` · `theBarFilesWhatTheBoxShows(.undo / .undoTwiceThenRedo)` | the real bar: `alpha` + ` beta`, the gesture, the box shows `alpha`; ⏎ → the opened note's blocks == `["alpha"]` | RED ×2 (old files `alpha beta`) |
| `CaptureHostsUndoFilingTests` · `thePadFilesWhatTheBoxShows(.undo / .undoTwiceThenRedo)` | the real pad: the same; ⏎ → ONE note, blocks == `["alpha"]` | RED ×2 |
| `CaptureHostsUndoFilingTests` · `anEmptyFilingLeavesNothingToUndoIntoInEitherHost` | bar then pad: three spaces, ⏎ → the box cleared and still on screen; `#require(canUndo == false)`; ⌘Z brings nothing back; nothing filed | RED (1 — the bar's `#require`; the pad's half never runs on old) |
| `CaptureFocusReattachTests` · `theFirstMountAutofocusStillLands(bornAsking: true/false)` | the pad's birth (request 1 at make) and the bar's (0, raised once up) both open with the caret; a later counted request still takes it from a field | GUARD ×2 |
| `CaptureFocusReattachTests` · `aReleasedBoxStaysAwayAcrossAReattach(true/false)` | holds → `makeFirstResponder(nil)` (the tour's act) → detach + re-attach → the box does NOT hold the keyboard | RED for `true` (candidate 1); GUARD for `false` |
| `CaptureFocusReattachTests` · `aBoxThatHeldTheKeyboardKeepsItAcrossAReattach(true/false)` | holds → detach (AppKit drops it to the window — asserted) → re-attach → the box holds it again | RED for `false` (the bar's silent loss); GUARD for `true` |
| `CaptureFocusReattachTests` · `aReattachNeverStealsFromAnotherResponder(true/false)` | holds → detach → the field takes the keyboard → re-attach → the box leaves it there | RED for `true` (the old arrival claim stole); GUARD for `false` |
| `CaptureTourFocusTests` · `stepsOneAndTwoNeverPutTheCaretBackInTheQuickEntry` | the REAL shell (`TourEntryTests`' world): the caret in the Bookcase's quick entry, the tour requested on the Bookcase (her road), released at arrival, then step 1 and step 2 settle — the box never holds the caret | **EXPECTED GREEN on both sides** (the static trace finds no re-grab on this road) — a red on old would mean the harness reproduces a re-grab the trace missed; the result is a finding either way |

Expected on old: **13 issues** (3 + 2 + 2 + 2 + 1 + 1 + 1 + 1) across 10 failing cases, every other case green; expected
on the fixed product: all green. *(The tour pin was edited at `bfd3ca38` — it no longer writes the dev app's real
defaults and reads `TourOracle` only when the slot reports THIS store's seeded book, so it cannot collide with
`TourEntryTests` inside one test process; the old products were rebuilt with that edit, below.)*

#### The diff (ONE production file; zero hosts, zero `Sources/`, `Sync/`, custody, Keychain, schema, `Shared/`)

`App/Variorum/Variorum/Core/Views/CaptureTextView.swift` (+58/−10):
- **VX-193 (`0c31fcc5`):** `Coordinator` gains `undoHistory` (its own `UndoManager`), `undoManager(for:)` (answers for
  its own view only), the did-undo/did-redo observers (`queue: .main`, `MainActor.assumeIsolated` — `CommentTextArea`'s
  exact form) → `textChangedOutsideTyping()` (binding ← view, only when they differ), `stopObservingUndo()` (called from
  `dismantleNSView`), and `adopt(_:into:)` — `updateNSView`'s programmatic adopt moved verbatim, plus
  `undoHistory.removeAllActions()`. `makeNSView` names `coordinator.view` before the delegate is wired (it was the last
  line), so `undoManager(for:)` can never answer nil for the box's own view.
- **VX-112 (`6bb9c7c9`):** `CaptureNSTextView` gains `heldKeyboardWhenDetached` and `viewWillMove(toWindow:)` (notes a
  held keyboard on detach); `viewDidMoveToWindow` serves `wantsInitialFocus` ONCE (cleared; its deferred serve keeps
  today's guard; re-armed if the serve finds the box out of its window), else re-takes a held keyboard only when the
  window holds it (nil or the window itself). Docs corrected ("the shelf's autofocus" → the pad's; the trace's reason
  the bar's flag is false is written at `makeNSView`).
- Not touched: `QuickEntryBar.swift`, `QuickNoteView.swift` (neither needs a line — both file the binding, which now
  follows), `takeFocus()`, the keys, the geometry statics, the canary. Nothing on VX-246's courtesy list; nothing outside
  the run's declared surfaces (the new test file aside).

#### The products (one new tree, as briefed; `Build/Products` set aside once, 456 MB)

- **Old:** `App/Variorum/DerivedData/vx282-u4-old-products` — the pins as at `bfd3ca38` over the PRE-FIX box. Built by a
  NAMED revert (`cdc842f0` named it first): `CaptureTextView.swift` checked out from `c4f2a893`, `build-for-testing`
  into `vx282-u4` → TEST BUILD SUCCEEDED → products copied → restored by `git checkout HEAD --`, `git diff` empty,
  verified. Its dylib's `CaptureNSTextView` carries no `viewWillMove` and its `Coordinator` no `undoHistory` (`nm`).
- **Fixed:** `App/Variorum/DerivedData/vx282-u4` — the build of `bfd3ca38` (= the fix at `6bb9c7c9` + the edited pins)
  → TEST BUILD SUCCEEDED; zero warnings in `CaptureTextView.swift` and the new test file. Its dylib carries both members'
  symbols (`nm`).
- No core file touched → no `swift test` owed. No phone file touched → no phone build owed (`Core/Views/` is Mac-only;
  the phone's capture is a SwiftUI `TextField`, its own road — `MobileQuickNote.swift:1229`).

#### PROVISIONALs (QUESTIONS #221)

- **P-U4-1 — undo is the box's own, and a programmatic replacement ends it** (P-VX179-U3-4 carried, #215 still open
  there). Built (a). Options: (b) the window's shared history (⌘Z in an empty box reaches other text's stack); (c) the
  clear itself undoable (a duplicate-filing hazard).
- **P-U4-2 — candidate 2, a tour started AWAY from the Bookcase lands with the caret in the bar** (traced by code
  order; W3 checks it live). Built (a): unchanged — R102 stands, the tour releases once at its arrival. Options: (b) the
  tour releases again when its own navigation lands; (c) the bar's mount autofocus stands down while a tour runs.

#### Observations (not fixed — for the orchestrator)

- **O-U4-1 (untraced):** the box reports its caret's departure only through `resignFirstResponder`; `CommentNSTextView`
  also reports it at `viewWillMove(toWindow: nil)` because a detached first responder "does not always hear" resign. If
  that holds for the box, a re-attach that finds ANOTHER responder holding the keyboard leaves the bar's `entryFocused`
  true (the Terminal block cursor stays hidden). Pre-existing; the rule built here is unaffected.
- **O-U4-2:** on the old tree the box's typing history sat on the window's undo manager — the one Write's editor and the
  panes use (no other app text view supplies its own; `grep undoManager(for:`). P-U4-1 takes the box off that stack; no
  cross-surface symptom was traced.

#### THE WINDOW PLAN (≈42 min; runs only on the orchestrator's claim line; `guard.sh --author` before every leg)

From `App/Variorum/`; logs to `notes/plans/vx282-screens/u4/logs/`, captures to `notes/plans/vx282-screens/u4/`.
`pgrep -fl 'Variorum.app/Contents/MacOS'` first — no `/Applications/Variorum.app` instance, none of ours.

- **W1 — red on old (≈5 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u4-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
  -only-testing:VariorumTests/CaptureUndoSyncTests -only-testing:VariorumTests/CaptureHostsUndoFilingTests
  -only-testing:VariorumTests/CaptureFocusReattachTests -only-testing:VariorumTests/CaptureTourFocusTests` →
  `w1-red-on-old.log`. EXPECTED: 13 issues in the 10 cases the pin table marks RED, every GUARD green, NO crash (the two
  `#require` cells stop the old tree before its ⌘Z). The tour pin's result on old is a FINDING either way (expected
  green).
- **W2 — the fixed Mac batch (≈12 min), `-derivedDataPath DerivedData/vx282-u4`, two groups (suite TYPE names,
  grepped):**
  (g1) `CaptureUndoSyncTests` `CaptureHostsUndoFilingTests` `CaptureFocusReattachTests` `CaptureTourFocusTests`
  `CaptureFocusReportTests` `CaptureKeysTests` `CaptureTextViewKeyTests` `CaptureHandOffTests` `QuickEntryBarTests`
  `QuickNoteMintTests` `QuickNoteDoorTests` `QuickNoteWindowTests` `QuickNoteWordTests` `QuickNoteParkTests` →
  `w2-g1.log`;
  (g2) `CaptureMicrosyntaxDoorTests` `CaptureMicrosyntaxLineEndingTests` `CaptureLineEndingDoorTests`
  `CRLFImportDoorTests` `TitleSuggestionChipTests` `CommentTextAreaMountedTests` `CommentPanelGeometryRuleTests`
  `SystemHotKeyChordTests` `SystemHotKeyDeclarationTests` `SystemHotKeyRoadTests` `TourEntryTests` `TourSpotlightTests`
  `TourEngineTests` `TourOfferLineTests` `BookcaseQuickEntryPlacementTests` `ShelfModelTests` `PromoteAndPaletteTests`
  → `w2-g2.log`. Read every suite's ✔/✘ line and the skips (a wrong name runs 0 tests and still "succeeds").
- **W3 — the walk (≈25 min), `DerivedData/vx282-u4/Build/Products/Debug/Variorum.app` on the DEV store only**
  (`open -n`; dismiss a What's New sheet with its own button if one shows; the voice and appearance as found, recorded).
  Keys through `keys.sh` only, ≥ 2 s apart; captures by REGION (`screencapture -x -R`), the pad by window id (it floats,
  layer 19). The caret's truth is read by AX, never from a screenshot alone: `tell (first application process whose unix
  id is <pid>) to get role of (value of attribute "AXFocusedUIElement")` (the box is an `AXTextArea`).
  - **A — the quick-entry bar (VX-193):** on the Bookcase, the caret in the bar (AX). Type `VX-193 bar one`, ← then →
    (a caret move ends the typing undo group), type ` two` (capture) → ⌘Z: the box reads `VX-193 bar one` (capture) →
    ⌘Z: empty, the placeholder back (capture) → ⇧⌘Z: `VX-193 bar one` (capture) → ⏎: the note opens reading `VX-193 bar
    one` — never `two` (capture). Back to the Bookcase (⌘K). **A2 (the sibling):** three spaces, ⏎ → the box clears and
    stays → ⌘Z → nothing comes back, no alert (capture).
  - **B — the quick-note pad (VX-193):** File ▸ Quick Note (menu, by AX name) → the pad (capture by id). The same:
    `VX-193 pad one`, ←→, ` two`, ⌘Z, ⌘Z, ⇧⌘Z (capture each) → ⏎ → the pad files and closes (the receipt). Proof of what
    filed: ⌘K, type `VX-193 pad` → the passage reads `VX-193 pad one` (capture); `pad two` finds nothing (capture).
  - **C — VX-112, her road, in TERMINAL** (her walk's voice; switched by ⌘K "Use Terminal Voice" if the store is in
    Study): on the Bookcase with the caret in the bar (AX: `AXTextArea`) → Help ▸ Take the Tour → step 1: capture the bar
    (the Terminal block cursor — expected VISIBLE, the release's own sign) + AX focus (expected NOT the box) → one
    keystroke `x` → the bar stays empty (capture) → the card's "next ⟶" (by AX name) → step 2: capture + AX + `x` again.
  - **D — the same in STUDY** (⌘K "Use Study Voice"; Help ▸ Take the Tour starts over at step 1): no block cursor; AX +
    `x` at steps 1 and 2.
  - **E — P-U4-2 live (the away start):** open the VX-193 bar note (⌘K) → Help ▸ Take the Tour → the tour lands on the
    Bookcase → AX focus + capture (EXPECTED by the trace: the caret IS in the bar — the R102 raise after the release); no
    keystroke here (it would start a note). Then "End tour" by its AX name.
  - **Cleanup:** the two walk notes to the Trash (note ▾ ▸ Delete Note… ▸ Delete; residue recorded); any `x` that landed
    deleted by ⌫; the voice restored as found; the tour record left as found (`variorum.tour.offer` read `completed`
    before the window — a later tour never downgrades it, re-read after); quit OUR instance by identity (`tell
    application id "io.lduarte.Variorum.debug" to quit`), `pgrep` again; the dev store Standard and unlocked; release
    the claim.

## Ladder

*(Round findings verbatim, dispositions, fixes — repo-first before each next round.)*

## Closeout

*(Pending.)*
