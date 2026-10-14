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
VX-325 (⌘K queues behind the take panel — U3 O-6) · VX-331 (the restore confirm's deleted-takes count has no 30-day
window — U5 O-U5-2) · VX-332 (navigating back to the Bookcase never focuses quick entry — U6 O-U6-1) · VX-334 (⌃⌘↑/↓ act on
Write's caret under the take panel — U3 O-2) · VX-335 (two ⌫ in one main-actor turn — U1). All in *12 — Hardening & perf
validation*, Todo; pre-launch is hers. **VM-18** (the phone's comments sheet drops a half-typed comment — U5's MOBILE
PARITY) in *Mobile — editor & capture faces*. **VX-326** joined the run as U6 at her word (her ticket from U4's O-U4-3).
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
| U2 | VX-296 — the italics flicker, caret-aware live restyle (Mac + phone) | **DONE** — fix `962a7305` (core) · `75b45ca9` (face + Mac) · `657bb57c` (phone) · `cb2251c4` (the pending-edit guard); pins `44ad276b`. Verified: core 2,799/320 headless; W1 red on old as designed; Mac W2 190/26 + u2b g1 106/13 green; phone u2b 59/10 green in one launch (the red pin `leavingATrailingSpace…` now green); W3 walk holds (Study only — the second voice not walked). PROVISIONALs P-U2-1/2/3 → QUESTIONS #220. Claim `vx282-u2b` HELD for U3's handover. |
| U3 | VX-154 — the take panel's remaining routed commands (+ the archive-receipt rider nit) | **DONE** — record `4e5d3464`; seams `04e0369f`; pins `fa90e851`; the fix `ae2277b7` (the registry fact) + `26ecec8c` (the panel). Stage window 01:18:43–01:35:12 (claim `vx282-u3`, RELEASED): W1 red on old as designed (23/2, 46 issues) · W1b revert B as designed (only the two ring checks red) · W2 the fixed batch 248 tests / 24 suites green · W3 every row held, both voices (logs `4c9ced16`/`38af3061`; the walk record below). P-U3-1…8 (QUESTIONS #221). No claim held; no revert in flight. |
| U4 | VX-193 + VX-112 — the capture box's undo desync and focus re-grab | **DONE** — traces `324bfda8`; pins `c4f2a893` → `079b0a15`; fix VX-193 `0c31fcc5` (the box's own undo history; the re-sync kept as a belt, outcome (a) at `079b0a15`), VX-112 `6bb9c7c9`. u4 window (01:54–02:12): W2 g2 92/17 green; the walk — the sibling reproduced in use on old (`NSRangeException`) and fixed in use, the headline not reproduced in use, her VX-112 sighting = the Terminal block cursor, P-U4-2 withdrawn. u4b window (05:20–05:22): W1b red on old 13 issues / 10 cases exactly as predicted, W2b 10 tests / 5 suites green. PROVISIONAL P-U4-1 (#222). Claim `vx282-u4b` HELD for U5's chained handover. No revert in flight. |
| U5 | VX-229 → VX-257 → VX-183 → VX-182 — the comments family | **DONE** — VX-229 DISMISSED AS HOLLOW in use (the u5b heap decider; the fix `ee86dd8c` reverted `7d798f82`; the runner's retention a known issue `c46f999d`, cause untraced) · VX-257 FIXED `1ca8fe72` (pins `7650b6ce`/`075473c2`, reshaped `dab712d8`/`eaf42b27`; QUESTIONS #223) · VX-183 FIXED `a765683c` · VX-182 FIXED `fd4c260c` (pins `f38fb93c`). Verified: core 2,801/320 + MCP 212/41 + workbook 40/6 headless; W1 / u5c red on old as designed; u5b g2 76/11, g3 23/2; **u5d g1 113 tests / 13 suites passed (9 known issues — the VX-229 runner fact)**; the u5b walk, every row held, both voices. Windows released 05:25:17, 05:57:46, 06:13:57, 06:19:43. Posture as found (Standard, unlocked, Study); no instance; no revert in flight. |
| U6 | VX-326 — the Bookcase's quick entry isn't focused at launch (joined overnight at her word) | **DONE** — pins `d35191b6` + correction `ee1facc9` · fix `3cf0079b` · window `a1967ac0` (logs) + the walk record. Stage window 05:27:17–05:38:17 (claim `vx282-u6`, RELEASED): W1 red on old exactly as predicted (3 tests, 1 issue — the launch pin's last cell) · W2 the fixed batch 148 tests / 43 suites green · W3 every row held (A0 old: the window; A/A' fixed: the caret in the bar at launch in Study and Terminal, a typed letter lands; C the tour never stolen from; D the navigation back as today — O-U6-1 seen live); row B's restored note window not reachable on this Mac (not restored), a new window walked in its place. P-U6-1/2 → QUESTIONS #224. Posture: Study, unlocked Standard, tour `completed`, the Bookcase, nothing filed. No claim held; no revert in flight. |
| Ladder | round 1 `opus-reviewer` (0B/0M/6m/4n, dispositioned) → its FIX LEG; round 2 = the run's one `fable-reviewer` | round 1's FIX LEG **DONE** (the r1fix window 07:53–08:00, released): R1-1/R1-2/R1-7 FIXED red-on-old → green · R1-3 DISMISSED AS HOLLOW · R1-4/5/6/9/10 done · R1-8 the closeout's watch. **NEXT: round 2 = the run's one `fable-reviewer`** |
| Closeout | canon deltas, tickets, MOBILE PARITY, handoff, merge, refresh per the coordinator | NOT-STARTED |

## Stage traffic log (oct13coordinator protocol)

- 2026-10-13 ~17:40 — announced to oct13coordinator; its reply: VX-281 goes first when READY alongside others
  (VX-246's last unit waits on it); otherwise READY order, short-before-long; simulator suites need the stage too;
  dev store last left Standard + unlocked (vx-184, 15:35) — leave it so; walks need "walk" plainly in the
  REQUEST (it checks she isn't using the Pro); /Applications stays 7045 until the next release; no real-store
  MCP calls or real-app launches without her recorded word.
- 2026-10-13 — REQUEST sent early for `vx282-u1` (≈40 min: the Mac batch + the red-on-old revert run + a short walk); coordinator: queued FIRST, nobody ahead; zero-slot recorded for VX-282; at READY it checks she isn't using the Pro before the walk part (if she is, the GO covers batch + revert, the walk gets its own short GO).

## The merge of main (orchestrator, 2026-10-14 ~05:00)

`ece30a41` merged `origin/main` at `fa3bc6e1` (VX-281's merge `0f5efe1c` + its ledgers + handoff) into the branch. One
conflict, `notes/QUESTIONS.md`: VX-281's #219 stands first; this run's entries renumbered **#219–#223 → #220–#224**
(this record follows). On the merged tip, headless: `build-for-testing` **TEST BUILD SUCCEEDED** (into
`DerivedData/vx282-u1`, U1's tree reused; `vx282-screens/merge/merged-build.log`) · `swift test` **VariorumCoreTests
2,809 / 322 · VariorumMCPTests 212 / 41 · workbook 40 / 6, all green** (`merged-swift-test.log`). The unit windows ran on
their pre-merge products (unit evidence); the closeout's Mac run covers the merged tip.

**Machinery honesty (orchestrator):** at ~05:26 U5's implementer was still writing its u5b plan (a record-only commit,
`c5d9e1aa`, no stage use) when U6 received its GO — two agents briefly ran at once, against the strictly-sequential
rule. Nothing collided (U5 touched only the record; U6 pulled and pushed cleanly). Cause: the orchestrator misread a
completion notice for U5's previous turn as the end of the resumed one.

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
    `["","","xbeta"]`. Green both sides by design (not re-run against R2-1's own revert here — the re-point keeps the
    arm). **Re-proven at the round-1 fix leg (R1-9, the r1fix window): RED under R2-1's named revert, as are both its
    siblings — each burst pin carries R2-1 on its own landing.**
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
(P-U2-1/P-U2-3, QUESTIONS #220).

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

**PROVISIONALs (QUESTIONS #220 — the number is main's next free one; renumbered at the merge if taken):**
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

**PROVISIONALs (QUESTIONS #221):**
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
- ~~**O-4 (the recorded two-windows keying family):** the handler stack and the grey fact are app-wide; with the panel up in
  one window it answers commands meant for another window's surface. Pre-existing (VX-135's registration); U3 widens what
  the panel answers.~~ **WITHDRAWN at the round-1 fix leg (R1-6) — its premise is false.** `PaneMount.kind(of:focused:windowIsKey:)`
  (`Workspace/WorkspaceNavigation.swift:85-87`, consulted at `RootView.swift:1124` and `Workspace/NoteWindowView.swift:92`)
  mounts a live surface — Write, the sheet it hosts and every routed-command handler — in exactly ONE window, the
  `WindowRegistry`'s sticky last-known-key (`activeWindowID`, `Workspace/WindowRegistry.swift:116-120`; only REGISTERED
  windows move it — a full window, a note-only window, the quick-note pad). A window that stops being that one re-renders
  its pane read-cheap (`ReadPostView`): its `EditorView` leaves, the take panel's sheet (`EditorView.swift:186`) leaves with
  its host, and the panel's `.onDisappear` (`WriteTakesPanel.swift:267-272`) unregisters its handler and detaches its grey
  fact. So the panel is never up in a window other than the one whose surface owns the handler stack — there is no other
  window's surface for it to answer for. (The app-wide keying that the 13u2b ladder's NIT 1 and the 18l record name is a
  different thing — session-scoped probe registries and `activePostID` — and the panel touches neither.) Traced by
  reading, not walked; no ticket.
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

**NOT DONE BY THIS UNIT (first line):** no live-road pin for ⌘Z — the test host has no key window (`WindowsTests`'
header) and the headless trace of the live road did not converge, so the binding's live sync rests on the u4 walk
alone; and no walk on the u4b pins (none owed — the app code changed by doc comments only after the u4 walk).

**State: DONE** (the u4b window, 2026-10-14 05:20–05:22: W1b red on old exactly as predicted, W2b green — THE u4b
WINDOW at the end of this section). Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-14.

**THE LEAD — the defect that is real in use (VX-193's sibling).** While the box's typing history was the WINDOW's undo
manager, a programmatic clear left it standing; an EMPTY filing (three spaces and ⏎ — the box clears and keeps the caret)
followed by a real ⌘Z raised **`NSRangeException` from `NSUndoTyping undoRedo:`** on the pre-fix build at the u4 walk
(AppKit caught it; that box's ⌘Z was dead afterwards). **FIXED** (`0c31fcc5`): the box owns its `UndoManager` and every
programmatic adopt ends it — red on old (W1, harness) and reproduced in use on old (the walk), green fixed (W2) and
verified in use fixed (no exception, Edit ▸ Undo disabled, both hosts). Pins: `CaptureUndoHistoryTests`.

**VX-193's headline (⌘Z leaves the binding stale) — NOT REPRODUCED IN USE; the re-sync kept as a BELT (outcome (a)).**
On the pre-fix build a real ⌘Z/⇧⌘Z kept the binding in step (the walk). The desync exists only where undo is driven
outside the live event road. The coordinator's ruling asked for the live road to be settled by a pin and a headless
trace first; neither converges here (the FIX LEG section below has the evidence), so the did-undo/redo observers stay
as a belt (VX-179's comments panel carries the same pair on the same probe-only basis) and their cells are reframed as
guards of the programmatic-undo road.

**VX-112 — CLOSED AS FIXED, with the note:** her sighting was the Terminal voice's decorative block cursor, which draws
while the box does NOT hold the caret (the walk, both voices, AX-proven); the box's own defects — the never-cleared
"asked once" flag (the pad's re-grab after a release, stealing from another responder) and the bar's silent loss of a
held keyboard on a re-attach — are fixed (`6bb9c7c9`) and red on old by the direct release-and-reattach pins (W1), green
fixed (W2). P-U4-2 withdrawn (QUESTIONS #222 updated).

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

#### PROVISIONALs (QUESTIONS #222)

- **P-U4-1 — undo is the box's own, and a programmatic replacement ends it** (P-VX179-U3-4 carried, #215 still open
  there). Built (a). Options: (b) the window's shared history (⌘Z in an empty box reaches other text's stack); (c) the
  clear itself undoable (a duplicate-filing hazard).
- **P-U4-2 — WITHDRAWN at the walk (not reproduced live, `E1`).** Was: candidate 2, a tour started AWAY from the Bookcase lands with the caret in the bar (traced by code
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

#### THE STAGE WINDOW — RUN 2026-10-14 01:54:02 → 02:12:15 (claim `vx282-u4`, handed from `coord-for-vx282`; RELEASED)

`git pull --ff-only` first (already up to date; HEAD `e0bb014a`, U4's products unchanged — nothing rebuilt in the window,
the coordinator's word). `guard.sh --author` OK before every leg; no Variorum instance and no booted simulator at the
start or at the end. AX and screen-capture grants probed first (both true). Logs: `notes/plans/vx282-screens/u4/logs/`;
captures: `notes/plans/vx282-screens/u4/walk/`.

- **W1 — red on old** (`w1-red-on-old.log`, the old products): "Test run with **10 tests in 4 suites failed** … **18
  issues**", no crash. **Every cell the pin table marks RED was red**: the binding cells (the box: after ⌘Z the box read
  "" while the binding kept "first thought and more"; the bar and the pad filed the undone words while the box was
  EMPTY), the history cells (the box's manager IS the window's; `canUndo` true after the clear — the `#require`s stopped
  the old tree before its ⌘Z, as designed), and the three VX-112 cells (the pad's birth re-grabbed after a release and
  stole from the field; the bar's birth lost the keyboard on a re-attach). **The tour pin was GREEN on old** — the
  harness does not reproduce a re-grab on her road (the trace's prediction). **Five issues beyond the 13 predicted, all
  non-vacuity cells:** in the test host the two typed chunks formed ONE undo group, so ⌘Z emptied the box instead of
  leaving "first thought" — the pins' two-step assumption, not the defect. Consequence, stated: the `.undoTwiceThenRedo`
  cases were red on old only through that granularity (the box and the binding AGREED there), so the redo half's
  red-on-old is NOT discriminated by these pins.
- **W2 — the fixed Mac batch:** g1 (`w2-g1.log`) "**54 tests in 14 suites**" — **10 issues, all in the two VX-193
  suites and all the same granularity assumption**: `anUndoAndARedoReachTheBinding`'s two non-vacuity cells (its three
  binding cells GREEN), and the hosts' four cases (`.undo`: the box emptied, the binding followed, ⏎ filed NOTHING — so
  the `#require` on a filed note failed; `.undoTwiceThenRedo`: the box showed "alpha beta", the binding agreed, ⏎ filed
  "alpha beta" ≠ the pin's "alpha"). GREEN on the fixed product: `aProgrammaticClearEndsTheBoxsOwnHistory`,
  `anEmptyFilingLeavesNothingToUndoIntoInEitherHost`, the whole VX-112 suite (all eight cases), the tour pin, and the
  other ten suites (12 of 14 suites ✔). g2 (`w2-g2.log`) "**92 tests in 17 suites passed**" — every suite's ✔ line read,
  0 skipped. **So the fixed product never let the box and the binding disagree; the red is the PINS' (they must not
  assume two undo groups in the test host).**
- **W3 — the walk, the fixed Debug app (pids 92274, 92584, 95706 across relaunches) on the DEV store**, opened unlocked
  ("Sync off (dev store)"), voice **Study**, appearance **system**, no What's New sheet; **plus the OLD Debug app
  (`vx282-u4-old-products`, pids 92474, 94191, 95261 — one instance at a time, same dev store) — not in the plan,
  launched because the first rows raised the question the walk exists to answer: does the old build show the symptom
  in USE?** Captures by region / window id; the caret's truth read by AX (`AXFocusedUIElement`); keys through `keys.sh`.
  - **App launch (both builds):** the Bookcase's quick entry is NOT autofocused at launch — AX reads the WINDOW focused
    on the old build and the new alike (`00-launch.png`). Pre-existing, identical on both (O-U4-3 below).
  - **VX-193's headline — NOT REPRODUCED IN USE ON THE OLD BUILD.** Old build, the bar: `old one` ← → ` two`, a real ⌘Z:
    the box empties AND the placeholder comes back (`X0`) — the placeholder draws only when the BINDING is empty
    (`QuickEntryBar.swift:229`) — and ⏎ files nothing (`X1`). Fresh old instance: `redo check`, ⌘Z (`X3`: placeholder
    back), ⇧⌘Z (`X4`: the text back AND the title chip "name it “redo check”?", which reads the binding). **In the
    running app the binding follows ⌘Z and ⇧⌘Z even before the fix**: the desync appears only where undo is driven
    outside the live event road — VX-179's offscreen probe (O-U3-3), my windowless probe, and the test host's
    `tryToPerform(undo:)`. Why the live road posts the change and those roads do not: NOT traced.
  - **The sibling — REPRODUCED IN USE ON THE OLD BUILD.** Old build, the bar: three spaces, ⏎ (the box clears and keeps
    the caret), a real ⌘Z → the old instance logged **`NSRangeException`** at 02:03:58 from `-[NSUndoTyping undoRedo:]` ←
    `-[NSTextStorage(NSUndo) _undoRedoAttributedSubstringFromRange:]` ← `-[NSUndoManager undoNestedGroup]` ← the Edit
    menu's key equivalent (AppKit caught it and the app continued — `X2`); afterwards ⌘Z in that box did NOTHING (typed
    `redo check`, ⌘Z: the text stayed) — the undo stack left broken. **Fixed build, the same sequence: no exception
    (zero `NSRangeException` lines for any fixed-build pid), and Edit ▸ Undo DISABLED — nothing to undo into** — in the bar
    (`A8`) and in the pad (`B0`).
  - **The fixed build in use (consistency, both hosts):** the bar — typed, ⌘Z (box and placeholder back), ⌘Z, ⇧⌘Z (text
    back), ⌘Z, ⏎ → nothing filed, still on the Bookcase (`A0`–`A5`); the pad — `VX-193 pad`, ⌘Z (`B2`: placeholder back,
    File It grey), ⇧⌘Z (`B3`: text, the chip, File It live), ⏎ → filed and closed; ⌘K finds the passage "VX-193 pad"
    (`B5`) and the note reads exactly `VX-193 pad` (`B6`). Undo granularity is UNCHANGED from the old build: on both,
    typing ← → typing coalesces into one ⌘Z step (NSTextView's own contiguous-typing coalescing; `A1`, `X0`).
  - **VX-112, her road — the sighting is the Terminal block cursor (the third reading, CONFIRMED).** Terminal (switched by
    ⌘K "Use Terminal Voice"): the caret in the bar (AX `AXTextArea`, `C1`) → Help ▸ Take the Tour → step 1: AX reads the
    WINDOW focused, and **the accent block cursor blinks at the end of the bar's placeholder** (`C2`, `C2b`) — "the caret
    block visible mid-tour", drawn exactly because the tour released the box; `x` typed → lands nowhere, the bar stays
    empty (`C3`); next ⟶ → step 2: AX the window, `x` lands nowhere (`C4`). Study (no block cursor): the same at steps 1
    and 2 — AX the window, both `x`s land nowhere (`D0`–`D3`). On the fixed build; the old build's harness run (W1's tour
    pin, green on old) and the trace say the same of her road.
  - **The away start (P-U4-2's premise) — NOT REPRODUCED:** a tour started from a note (`o museu`, Read ▸ edit) landed on
    the Bookcase at step 1 with AX reading the WINDOW focused at 3 s and at 6 s (`E1`) — candidate 2's raise did not take
    the caret on this road. P-U4-2 is WITHDRAWN (QUESTIONS #222 updated).
  - **Cleanup / posture:** the ONE walk note (`2026-10-14`, body `VX-193 pad`, #quicknote) moved to the Trash by note ▾ ▸
    Delete Note… ▸ Delete (receipt "Note moved to the Trash — 30 days to put it back.", `Z2`) — the dev store's residue;
    no other note was filed by either build (every bar ⏎ in the walk filed nothing); every `x` landed nowhere; the voice
    restored to **Study** by ⌘K "Use Study Voice" (`Z4`); appearance `system` (never touched); `variorum.tour.offer` read
    `completed` before and after (each tour ended by its own "End tour"); no lock screen met (Standard, unlocked); no
    system dialog; every instance quit by identity, `pgrep` empty after; 0 booted simulators; **the claim RELEASED at
    02:12:15** (18 of 60 minutes).

#### The dispositions, as the window leaves them (the orchestrator rules the open ones)

| Row | Disposition |
|---|---|
| VX-193 — ⌘Z desyncs the binding, ⏎ files undone words | **HOLLOW IN USE** — not reproduced on the old build in the running app (`X0`/`X1`/`X3`/`X4`); real only on roads that drive undo outside the event loop (probes, the test host). The did-undo/redo observers added at `0c31fcc5` fix a road she cannot reach. **RULED (the coordinator): decide by the live road; the fix leg could not establish it headlessly → OUTCOME (a): the observers stay as a belt, their cells reframed as programmatic-road guards** (THE FIX LEG below). |
| VX-193's sibling — ⌘Z after an empty filing replays the old ranges | **FIXED** (`0c31fcc5`: the box's own `UndoManager`, ended at every programmatic adopt) — red on old in the harness (W1) AND reproduced in use on the old build (the logged `NSRangeException`, the broken undo after), green fixed (W2) and verified in use fixed (no exception; Undo disabled) in both hosts. |
| VX-112 — the quick-entry caret returns mid-tour | **Her sighting: HOLLOW** — the Terminal block cursor (drawn while the box does NOT hold the caret), proven live with AX and keystrokes in both voices. **The box's own defects behind the ruled rule: FIXED** (`6bb9c7c9`) — red on old by the direct release-and-reattach pins (the brief's accepted shape), green fixed, the first-mount autofocus unchanged. No live road for them was shown in the walk (none was sought beyond her road). |
| P-U4-2 (candidate 2, the away start) | **WITHDRAWN** — not reproduced live (`E1`). |
| The VX-193 pins | **FIXED at `079b0a15`** — explicit undo grouping per chunk (THE FIX LEG); the u4b window re-proves them on old and new (PENDING). |

**Observation O-U4-3 (pre-existing, both builds — not this unit's road):** the Bookcase's quick entry is not autofocused
at app LAUNCH (AX reads the window focused; old and new alike) — the F-FR-1 shape the `CaptureFocusReportTests` header
recorded as untraced (the `.task` raise landing while the box is windowless), now seen live at launch. Whether the
mount raise lands on an ordinary (tour-less) navigation to the Bookcase was not checked. *(The coordinator tickets it as
a her-call observation.)*

#### THE FIX LEG (headless, 2026-10-14, the coordinator's ruling on the table above)

**The ruling, in short:** decide the observers by the LIVE road — a pin driving the real ⌘Z road in a mounted, key,
first-responder box plus a bounded headless trace; (b) if the live action keeps the binding in sync without the
observers → remove them as hollow; (a) if (b) cannot be established in this leg → keep them as a belt and reframe their
pins honestly. Fix the pins' two-undo-group assumption. Keep the sibling and lead with it. Close VX-112 as fixed with the
note.

**1. The live road — the trace did NOT converge; a live-road pin is NOT buildable in the test host → OUTCOME (a).**
Windowless and offscreen probes (scratch programs, never committed; `.prohibited` app, every window never ordered in),
counting `textDidChange` during the undo:

| road | `textDidChange` during the undo |
|---|---|
| windowless text view, the box's own manager, `manager.undo()` | 0 |
| offscreen window, first responder, own manager / the window's manager, `manager.undo()` | 0 / 0 |
| the same, `undo:` up the responder chain (`tryToPerform`) | 0 / 0 |
| text typed by real `keyDown` events, then `undo:` / `redo:` | 0 / 0 |
| `isKeyWindow`, `isMainWindow`, `NSApp.isActive` FORCED true by override, then `undo:` / `manager.undo()` | 0 / 0 |
| a main menu with Edit ▸ Undo (target nil), the item performed | the undo never reached the text view (no key window) |

Yet on the pre-fix build in the running app a real ⌘Z/⇧⌘Z kept the binding in step (the walk's `X0`/`X1`/`X3`/`X4` —
the only writer of that binding is `textDidChange`). So the live road posts the change through a state these probes
cannot build — a window truly key in an active app, the event dispatched by `NSApplication` — and the XCTest host cannot
build it either: `WindowsTests`' header measured that there `NSApp.isActive` is false and no window ever becomes key,
so `NSApp.sendAction(undo:, to: nil, …)` / the menu path would not reach the box at all (or would reach the host app's
own window). A pin claiming the live road would be vacuous. **Outcome (a):** the did-undo/redo observers STAY as a belt
(no behaviour change; `CaptureTextView`'s docs now say what they are and are not), and their cells are reframed as guards
of the programmatic-undo road. What would settle (b) if ever wanted: a short live check on a build without the
observers (⌘Z/⇧⌘Z in the bar and the pad, the placeholder and the title chip as the binding's tells, as the walk did).

**2. The pins' two-undo-group assumption — fixed.** `CaptureRig.type` now makes each typed chunk ONE explicit undo group
(by-event grouping off, `beginUndoGrouping`, the real `insertText`, `endUndoGrouping`, by-event grouping restored, typing
coalescing broken) — probed headlessly on the box's own manager and on a window's: `first thought and more` → ⌘Z
`first thought` → ⌘Z `""` → ⇧⌘Z `first thought`, on both. So the redo half is now discriminated on old too.

**3. The suites, reorganized to lead with the sibling** (`VariorumTests/CaptureUndoAndFocusTests.swift`, `079b0a15`):
- `CaptureUndoHistoryTests` (THE LEAD — the defect real in use): `aProgrammaticClearEndsTheBoxsOwnHistory` (RED on old: the
  box's manager is the window's; `canUndo` survives the clear — the `#require` stops the old tree before its ⌘Z),
  `anEmptyFilingLeavesNothingToUndoIntoInEitherHost` (RED on old: the bar's `#require`).
- `CaptureUndoSyncTests` (the BELT's guard, programmatic road): `aProgrammaticUndoAndRedoReachTheBinding` — RED on old on
  its three binding cells (now including the redo), its non-vacuity cells green on both.
- `CaptureHostsUndoFilingTests` (the BELT's guard in both hosts): the bar and the pad × (⌘Z · ⌘Z ⌘Z ⇧⌘Z) — RED on old (the
  binding files "alpha beta" while the box shows "alpha"), green fixed.
- `CaptureFocusReattachTests`, `CaptureTourFocusTests` — unchanged.

Expected on old (u4b W1b): **13 issues in 10 failing cases** (2 + 1 + 3 + 4 + 3), the tour pin green, no crash;
expected fixed (W2b): all green. PENDING.

**4. The products:** the fixed product `DerivedData/vx282-u4` rebuilt at `079b0a15` (TEST BUILD SUCCEEDED; its dylib
carries both members' symbols); the old products `DerivedData/vx282-u4-old-products` rebuilt with these pins over the
pre-fix box by the NAMED revert (`git checkout c4f2a893 -- CaptureTextView.swift`, named first in LIVE STATUS at `a5a0adac`, built,
`Build/Products` replaced, restored by `git checkout HEAD --`, `git diff` empty; its dylib carries neither member's
symbols — `nm`). Nothing else rebuilt; no core or phone file touched.

**5. P-U4-1 stays open in #222** (the per-box history — the sibling's fix); P-U4-2 withdrawn there.

**THE u4b WINDOW PLAN (≈8 min; on the orchestrator's claim line; `guard.sh --author` first).** From `App/Variorum/`, logs
to `notes/plans/vx282-screens/u4/logs/`:
- **W1b (≈4 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u4-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'` with
  `-only-testing:VariorumTests/` × `CaptureUndoHistoryTests` `CaptureUndoSyncTests` `CaptureHostsUndoFilingTests`
  `CaptureFocusReattachTests` `CaptureTourFocusTests` → `u4b-w1b-red-on-old.log`. EXPECTED: 13 issues in 10 cases.
- **W2b (≈4 min):** the same five suites on `-derivedDataPath DerivedData/vx282-u4` → `u4b-w2b.log`. EXPECTED: all green.
  (The rest of the u4 batch needs no re-run: the app code changed by doc comments only.)

#### THE u4b WINDOW — RUN 2026-10-14 05:20:17 → 05:21:55 (claim `vx282-u4b`, handed from `coord-for-vx282`; HELD for U5's chained handover)

`git pull --ff-only` first (up to date at `ece30a41` — U5, U6 and the merge of main on the branch; QUESTIONS renumbered,
U4's entry is now #222). Nothing rebuilt (the coordinator's word): `DerivedData/vx282-u4` was last rebuilt by U6 with
U4 + U5 + U6 code — U6 only adds a focus request these suites never touch — and `vx282-u4-old-products` is untouched since
`a5a0adac`. `guard.sh --author` OK before each leg; no Variorum instance before or after (`pgrep -lx Variorum`).
- **W1b — red on old** (`u4b-w1b-red-on-old.log`): "**10 tests in 5 suites failed … 13 issues**", no crash, no restart —
  EXACTLY the prediction, cell for cell: `aProgrammaticClearEndsTheBoxsOwnHistory` 2 (the manager is the window's;
  `canUndo` survives the clear — the `#require` stopped the old tree before its ⌘Z); `anEmptyFilingLeaves…` 1 (the bar's
  `#require`); `aProgrammaticUndoAndRedoReachTheBinding` 3 (the binding after ⌘Z, after ⌘Z, after ⇧⌘Z — its non-vacuity
  cells GREEN on old now: the explicit grouping gives two steps, so the redo half IS discriminated); `theBarFilesWhatTheBoxShows`
  ×2 and `thePadFilesWhatTheBoxShows` ×2, 1 each (the store held "alpha beta" while the box showed "alpha"); the VX-112
  cells 1 each (`aReleasedBox…(true)`, `aBoxThatHeld…(false)`, `aReattachNeverSteals…(true)`). GREEN on old:
  `theFirstMountAutofocusStillLands` (both births) and the tour pin.
- **W2b — the fixed product** (`u4b-w2b.log`): "**10 tests in 5 suites passed**" — every suite's ✔ line read, 0
  skipped.
- **Posture:** no app launched in this window; the dev store untouched (Standard, unlocked, Study, as the coordinator's
  pre-check found it); **the claim `vx282-u4b` HELD** for U5's implementer.

**U4 — DISPOSITIONS, FINAL.** VX-193's sibling (⌘Z after an empty filing replays the old ranges — `NSRangeException`
in use on old): **FIXED** (`0c31fcc5`), pins `CaptureUndoHistoryTests` red on old / green fixed, verified in use. VX-193's
headline (⌘Z leaves the binding stale): **NOT REPRODUCED IN USE** — the re-sync kept as a belt by the coordinator's
ruling, outcome (a) (`079b0a15`), its guards `CaptureUndoSyncTests` + `CaptureHostsUndoFilingTests` red on old / green
fixed on the programmatic-undo road. VX-112: **FIXED with the note** (`6bb9c7c9`) — her sighting was the Terminal block
cursor; the box's own defects red on old / green fixed; the tour pin green both sides. P-U4-1 open (#222); P-U4-2
withdrawn. Born for the orchestrator: O-U4-1 (untraced), O-U4-2, O-U4-3 (now this run's U6, VX-326).

### U5 — VX-229 · VX-257 · VX-183 · VX-182 (the comments family VX-179 left)

**NOT DONE BY THIS UNIT (first line):** the phone has no VX-257 change (its sheet still drops an unsubmitted draft —
MOBILE PARITY below); in the RUNNER the VX-229 cells are KNOWN ISSUES (the runner keeps dismissed panels alive, cause
untraced) and VX-257's two sheet cells reach the leaving body by their fallback road (the binding dismissal's own
`.onDisappear` is not reachable there — in the app the sheet roads were walked through Close and ⎋⎋, not the binding
road); O-U5-2 (the confirm's 30-day window) is untraced, a ticket candidate.

**State: DONE (2026-10-14 06:20).** Implementer: an `opus-implementer` session (Opus 5.5, xhigh), 2026-10-14. Counts marked
PENDING wait for the window. **Revert state: no behavioural revert in flight** (R-182 ran and was restored; `git diff`
empty).

#### VX-229 — the trace (re-done in this session against `d9e1eaf2`)

1. The Takes margin note presents the panel as SwiftUI popover content: `CommentMarginNote`'s
   `.popover(isPresented: $panelShown) { CommentsPanel(session:blockID:) }` (`TakesShared.swift:782-784`). The panel
   mints its model in `State(initialValue:)` (`CommentsPanel.swift:765-770`) and runs the store observation from its
   `.task` — `model.restoreParkedDraft(); addFocusRequest += 1; await model.start()` (`:813-825`), where `start()` is a
   `for try await` over `session.database.observe` that re-reads both comment lists on every relevant write
   (`:154-167`). The loop ends only when its task is cancelled — i.e. when SwiftUI removes the view.
2. A dismissed popover's content is never removed. MEASURED AGAIN in this session by a standalone probe (pure SwiftUI
   + AppKit, no app module, no store; `.prohibited` activation; the anchor window placed off-display before it is
   ordered in, alpha 0; every popover window alpha 0 the turn it appears and checked against every `NSScreen` —
   never touched one): three open/dismiss cycles of a `.popover` whose content holds a `@State` object and a `.task`
   → **each opening is a NEW window; after the third dismissal 3 tasks still run and the objects are all alive;
   `.onDisappear` fired 0 times** (the record of VX-179's `stale.swift`, reproduced).
3. So every opening of the Takes margin note's comments leaves the previous panel whole in its ordered-out window: the
   model, its observation loop (one more re-read per comment write, per stale panel, for the app's life), its views.
   VX-179 FIX LEG 3 released only the stale panels' KEY MONITORS (`CommentPanelKeyMonitor.MonitorView.release()` on
   the host's `willClose`, `:654-672`).
4. **The fix's premise, measured by the same probe:** a STATE FLIP inside the dismissed content, made at the popover's
   `didClose` (an observer scoped by content-window identity, `CommentPanelHostWatcher.isHost`'s rule) **IS
   processed** — the inner view is removed, its `.task` cancelled (tasks 0), its `@State` object released (0 alive),
   `.onDisappear` fires once per dismissal — and the next opening is again a new window with fresh content. (The probe
   source stays in the session scratchpad; it is not committed.)
5. **The sheet hosts** (`EditorView.swift:225-229`, `TakesBottomBar.swift:309-314`, the take panel's nested sheet
   `WriteTakesPanel.swift:241-246`) are expected to tear their content down on dismissal (the panel's `.onDisappear`
   leaving body has relied on it since 13u3 A2) — NOT assumed: guard pins measure it per host shape (three openings
   each), in the stage window (sheet presentations are out of bounds for offscreen probes — VX-179's tightened line).

#### VX-229 — the fix (`CommentsPanel.swift`; zero `Sources/`, `Sync/`, schema)

- **`CommentsPanel` becomes the host-lifecycle wrapper** (its API unchanged: `init(session:blockID:model:)`, every host
  byte-unchanged). It holds only `@State hostClosed` and renders `CommentsPanelSurface` (the panel as it was —
  private, owning the model in its own `@State`) while `!hostClosed`.
- **The surface's watcher hears the popover's `didClose` too** (`CommentPanelHostWatcher` grows `onHostClosed`, one
  observer per moment, both scoped by content-window identity as before): `willClose` runs the leaving body (VX-179
  FIX LEG 2's save, unchanged); `didClose` sets `hostClosed` → the surface is removed → its `.task` (the observation)
  is cancelled, its views leave the window (key monitor, watcher, areas), and nothing holds the model.
- **Why the model is NOT owned by the wrapper (measured, not reasoned):** the first build of this fix put the model in
  the wrapper's `@State` and nil'd it at `didClose`. Replayed offscreen against the real module, the observation
  stopped but the model stayed alive (1, 2, 3). Traced: the wrapper STAYS in the dismissed popover's graph, SwiftUI keeps
  its latest view VALUE, and a `State(initialValue:)` struct carries the object it was built with — so a nil written to
  the state never drops it. The pure-SwiftUI probe had released its model because the model lived in the CHILD that was
  removed. So the model lives in the removed child — the surface — exactly where it always lived.
- The leaving body (`leave()`, moved onto the model at VX-257's pins commit) runs from Close, `.onDisappear` and the
  popover's `willClose`; at the teardown `.onDisappear` runs it once more — idempotent (a commit that would write
  nothing writes nothing; VX-179's accepted double-commit, unchanged).
- **The premise the teardown rests on:** a dismissed popover's content is never shown again — each opening is a NEW
  window with new content (measured by both probes; VX-179 FL3's monitor release already rests on it). The popover pin
  asserts it per opening, so a SwiftUI that reused a popover would fail that premise by name, not blank a panel silently.

**Offscreen replay of the pin's sequence against the REAL module** (VX-179's accepted probe road: a scratch executable
linked dynamically against the tree's `Variorum.debug.dylib` with `@testable import Variorum`; an in-memory store
injected by `prepareDependencies` before anything runs; the unsandboxed default store folder checked absent at start and
exit — never created; `.prohibited`; the anchor off-display before ordering in, alpha 0; each popover window alpha 0 the
turn it appears and checked against every `NSScreen` — never touched one). Three open/dismiss cycles, the product's
`CommentsPanel(session:blockID:)` in a SwiftUI `.popover`:

| product | after dismissal 1 / 2 / 3: models alive · observing | a later write re-read by |
|---|---|---|
| OLD (`vx282-u5-old-products` — the pins commit `7650b6ce`) | 1·1 / 2·2 / 3·3 | **3** stale panels |
| FIXED (this commit) | 0·0 / 0·0 / 0·0 | **0** |

(The replay is evidence beside the pins, not in place of them — the pins RUN in the stage window.)

**The pins — `CommentPanelReleaseTests` (`CommentPanelHostLifecycleTests.swift`, `.serialized`; product construction in
every host, the models read through the DEBUG weak record filtered by the test's session):**

| Test | Asserts | Old |
|---|---|---|
| `aDismissedPopoverLetsGoOfItsPanelsModelAndItsObservation` | the margin note's `.popover` presenter ×3: each opening a NEW window with a mounted, observing panel; after the third dismissal no model alive, none observing, a later write re-read by none | RED (3 · 3 · 3) — PENDING |
| `aDismissedSheetLetsGoOfItsPanel` | the `.sheet(item:)` host ×3: after each dismissal no model alive | GUARD — PENDING (measures the sheet-teardown premise) |
| `theTakePanelsNestedCommentsSheetLetsGoOfItsPanel` | the real `WriteTakesPanel` as a sheet, the comments as its sheet ×3: after each dismissal no model alive | GUARD — PENDING |

Standing pins this touches (expected green, PENDING): `CommentPanelFixLeg2Tests` (the monitor release counts one per
dismissal; the R1-2 save at `willClose`; the close rung) and the rest of the comment set.

#### VX-229 — CORRECTION (same session, before any stage run): the offscreen leak was the probes' own artefact

> **SUPERSEDED BY W1 (2026-10-14 05:24):** in the RUNNER the old product leaks exactly as the ticket says — three
> models alive and observing after three dismissals, a later write re-read by all three — with every premise held. The
> drained offscreen probe (`.prohibited`, never active) does NOT model the runner; its "released" result is recorded
> below as what it measured, not as the product's behaviour. The fix is owed again (the orchestrator re-plans).

**The fix `ee86dd8c` is being REVERTED (its code; the record stays as history).** Measured after it landed, by the same
real-module replay made faithful to a run loop:
- **Undrained autorelease pools.** Both probes above ran every cycle inside one `MainActor.assumeIsolated` block and
  never drained a pool; typing and AppKit's delegate traffic autorelease the popover's window/content chain, which then
  lives until the (never-reached) drain. With every turn and every cycle in its own `autoreleasepool` — what the app's
  run loop does each iteration — the **OLD product releases each dismissed panel**: its model gone and its observation
  ended within the dismissal's turns, three cycles running, typed or not, with the app's long-lived `ThemeStore` in the
  environment or not (`idpanel.swift`, by model identity: `[] [] []`).
- **A held window.** The OLD product keeps a dismissed panel alive AND observing for exactly as long as something holds
  its popover WINDOW strongly — my first pins did (`let window = …` across `rig.dismiss(window)`), and my first replay did
  (`w`). Nothing in the app holds a dismissed popover's window.
- The pure-SwiftUI probe's leak (`popteardown.swift`) survives pool drains for a third reason of its own: its popover
  CONTENT closure read the long-lived driver's observable `counter`, so the stale content stayed subscribed. The
  product's content closure (`CommentsPanel(session:blockID:)`) reads no observable.

So VX-179 FIX LEG 3's measurement (`stale.swift`, offscreen, `.prohibited`, the same probe shape) is, on this evidence, the
same artefact — and VX-229 is **expected HOLLOW**. That cannot be settled offscreen (the probe app is never active; the
runner and the live app are), so: the fix comes out (never ship a fix a red-on-old run has not justified — contract
rule 3), the pins are RESHAPED so no window is ever held across a dismissal (the rigs keep window NUMBERS only), the old
products are rebuilt with them, and **W1 decides**: red on old ⇒ the leak is real in the runner and the fix is re-applied
(`git revert` of this revert) with one more window; green on old ⇒ VX-229 DISMISSED AS HOLLOW, the pins kept as guards.
The live arbiter rides W3: `heap` on the running OLD Debug app after three open/dismiss cycles of the margin note's
popover — the live count of `CommentsPanelModel` instances.

**State of the tree for this step (named before it starts):** the app code goes back to `7650b6ce`'s (the pins commit:
seams only) for `CommentsPanel.swift` and `CommentTextArea.swift`; VX-257's fix, built but UNCOMMITTED, is kept at
`scratchpad/vx282-u5/vx257-fix-uncommitted.patch` (gitignored, in the worktree) with whole-file copies beside it, and
is re-applied after the old products are rebuilt. The probes are kept in the same folder.

**The correction, executed:** `7d798f82` — the code back to `7650b6ce`'s (`CommentsPanel.swift`; `CommentTextArea.swift`
unchanged by VX-229), the pins reshaped (window NUMBERS only), the OLD products rebuilt from that commit
(`DerivedData/vx282-u5-old-products`, replaced — `nm`: neither VX-229's surface nor VX-257's keeping in its dylib).
**The re-measurement, offscreen, pools drained, the theme in the environment, typed** (`idpanel.swift theme type`): after
each of three dismissals no model of the session alive — OLD `[] [] []`, the tree with VX-257's fix `[] [] []`.
**VX-229 disposition: PENDING W1 — expected DISMISSED AS HOLLOW.** If W1's popover cell is red on old, the fix comes
back by `git revert 7d798f82`'s code half (the surface split at `ee86dd8c`) and W2 re-runs on a rebuilt product.

#### VX-257 — the trace (against `d9e1eaf2`)

1. The panel's add draft lives on its per-presentation model (`CommentsPanelModel.addDraft`, bound to the composer —
   `CommentsPanel.swift`, the composer's `CommentTextArea(text: $model.addDraft …)`).
2. The park (`Shared/CommentDraftPark.swift`) held REFUSED drafts only: `fileAddDraft` / `commitEdit` park the SUBMITTED
   text at refusal time; the open's `.task` reads it back (`restoreParkedDraft`, a peek).
3. Every closing road runs ONE leaving body — Close (`close()`), the sheet's `.onDisappear`, the popover's `willClose`
   (`CommentPanelHostWatcher`, VX-179 FIX LEG 2) — and that body committed dirty in-place EDITS only. The add draft was
   deliberately left alone (#118(a): leaving never FILES it), so it went wherever the model went: gone with a sheet's
   torn-down content, gone with a released popover's (and — on VX-179's offscreen picture — "alive in a stale panel",
   which the CORRECTION above shows was the probe's artefact; the reopen is a new model either way). The reopen's box is
   empty: her half-typed comment is lost on a click away (W4-OBS-1, walked live at VX-179's stage window 4).
4. No host parks differently today: there is ONE parking road (refusal time, in the model) and ONE leaving road (the
   model's body, since `7650b6ce`'s seam) — so the fix is one road, not two.

#### VX-257 — the fix (`CommentsPanel.swift`'s model, `Shared/CommentDraftPark.swift`, `CommentTextArea.swift`)

- **The leaving body keeps the composer** (`CommentsPanelModel.leave()` → `keepAddDraftOnLeaving()`): words in the box
  → parked for the block, verbatim, as a draft she LEFT (`Held.refused == false`) — unless they are the very words the
  park holds as this block's REFUSED add draft (that stays the refusal, with its line); an EMPTY box (⎋'s clear rung —
  the ladder's close rung comes after it — or emptied by hand) → a held ADD draft for the block is let go (`clearIfHeld`
  — a held EDIT draft is another draft and stays). Whitespace alone is nothing (`CommentComposition.filing`, the Add
  door's own test). Never files: no operation runs (#118(a) stands).
- **A panel that never opened touches nothing** (`opened`, set by `restoreParkedDraft()` — the open's first act): a
  phantom construction or a close before the first turn has shown nothing of the park.
- **The restore speaks the refusal's line only for a refusal** (`Held.refused`): her own words back in the box need no
  explaining, and "couldn't be saved" would be false.
- **The caret after a restored draft** (`CommentTextAreaView.adoptText`): text arriving into an EMPTY area leaves the
  caret after it — what typing it would have done — so a restored draft is picked up where she stopped. ~~Every other
  programmatic adopt (a clear, a revert, a store arrival) keeps the caret where it can be, as before.~~ **CORRECTED at
  the round-1 fix leg (R1-10):** the rule is keyed on the area being EMPTY, not on the adopt being a restore — so ANY
  adopt into an empty area lands the caret at the end, the MOUNT FILL included (every area is born empty and its first
  `adopt` from `makeNSView` fills it: a live comment row's edit area now opens with its caret at the end of the comment,
  where it opened at the start before VX-257), and a store arrival into an area she had emptied likewise. An adopt into
  a NON-empty area (a clear, a revert, a store arrival over text) keeps the caret where it can be, as before. The record
  line was wrong; the code is unchanged (a click into a row places the caret where she clicks either way).
- **The shared park type** gains `Held.refused` (default `true`) and `park(…refused:)` (default `true`): every existing
  park — the phone's included — is unchanged in behaviour and in source.
- Every host is covered by construction: the popover (its `willClose` → the leaving body), the `.sheet(item:)` hosts —
  Write's and the Takes bar's — and the take panel's NESTED sheet (U3's O-5) (their teardown's `.onDisappear` → the same
  body), and Close in any of them (`close()` → the same body).

**Offscreen replay against the real module** (`realpanel.swift leave` — type `half a thought ` into the popover's composer,
dismiss, reopen ×2): FIXED — parked `refused: false`, both reopenings show `half a thought ` with the caret at 15 (its
end); OLD — park `nil`, both reopenings empty.

**The pins.**

| Test | Asserts | Old |
|---|---|---|
| `CommentPanelLeaveTests.leavingWithAHalfTypedCommentKeepsItForTheSameBlock` | leave with a half draft → held verbatim for the block, `refused == false`; the reopen restores it with NO line; nothing filed | RED |
| `…escapeClearsAndTheReopenIsEmpty` | ⎋'s clear then the leaving → nothing held, the reopen empty; a whitespace-only box keeps nothing | GUARD |
| `…escapeAfterARestoreAbandonsTheDraftForGood` | left → restored → ⎋-cleared → left → nothing held, the reopen empty | RED (at its restore premise) |
| `…anotherBlocksPanelGetsNoForeignDraft` | A left → B's open is empty, no line; B left empty → A still held; A's reopen restores | RED (the held half) |
| `…aRefusedDraftLeftAsItWasKeepsItsLine` | a sealed note's refusal, then the leaving with the same words → still held as the refusal; the reopen speaks the line | GUARD |
| `…aPanelThatNeverOpenedLeavesTheParkAlone` | a refused draft held; a never-opened model's leaving → still held | GUARD (the `opened` rule's own line keeps it — removing it would clear the park here) |
| `CommentPanelHostLeavingTests.aClickAwayFromThePopoverKeepsTheDraftForTheReopen` | the margin note's popover: type, close by the binding (a click away's road), reopen → the words back, the caret after them, nothing filed | RED |
| `…aSheetsClosingKeepsTheDraftForTheReopen` | the `.sheet(item:)` host, the same | RED |
| `…theTakePanelsNestedSheetKeepsTheDraftForTheReopen` | the real `WriteTakesPanel` as a sheet, its comments sheet, the same | RED |
| `CommentPanelParkTests.anUnsubmittedDraftStaysHerOrdinaryAbandon` | DOC ONLY edited (RULED-CHANGE — "the panel's close keeps nothing" is no longer true); its body (typing alone parks nothing) unchanged | GUARD |

All PENDING the stage window (W1 on the old products, W2 on the fixed). The standing park pins (`CommentPanelParkTests`,
RUN A's) are expected green and unmodified in body: refusals still park at refusal time, peek, and clear on the same
draft's landing.

**PROVISIONALs (QUESTIONS #223 — under the VX-282 heading; renumbered at the merge if a sibling took it):**
- **P-U5-1 — ONE held draft, newest wins** (the park's #140(a) trade, now reached by a click away as well as by a
  refusal): leaving block B's panel with words in it replaces a draft held for block A — refused or left. Built (a) the
  park as it is. Options: (b) one held draft PER BLOCK (the park grows to a small per-block table, both platforms' type —
  a change to the phone's park semantics too); (c) a REFUSED draft outranks a left one (a click away elsewhere never
  displaces refusal insurance).
- **P-U5-2 — Close keeps the draft too** (every closing except ⎋⎋, whose first rung empties the box): her ruling names a
  click away; the brief's reading is "any dismissal other than ⎋", and one leaving body serves every road. Option: (b)
  Close abandons the draft as ⎋⎋ does.
- **P-U5-3 — a restored LEFT draft speaks no line**, and comes back with the caret after it. Options: (b) a line of its own
  ("your unfinished comment — still here"); (c) the caret at the start, as a refused draft's restore had it.
- **P-U5-4 — an emptied box at leaving lets a held ADD draft go, a REFUSED one included** (⎋⎋ after a refusal's restore
  abandons it). This supersedes #140(b)'s Mac arm ("⎋-clear and close: the next open brings back the SUBMITTED text the
  store refused") — under VX-257 the box's state at leaving is the draft. Option: (b) an emptied box leaves a REFUSED
  draft held (#140(b) as it was), only a LEFT draft goes.
- **Recorded, not a PROVISIONAL (her ruling):** #140(c) ("a draft typed and never submitted still dies with the close")
  is superseded on the Mac by VX-257.

**MOBILE PARITY (VX-257):** the phone is UNCHANGED — `VariorumMobile/Features/Write/MobileComments.swift` byte-unchanged;
its sheet has its own park instance (refusal-only), and its close roads (the dim-tap, Done, the projection's auto-close)
still drop an unsubmitted draft. Her ruling named the Mac popover. The shared type's two additions default to the phone's
behaviour. A VM ticket candidate for the phone's own click-away (for the orchestrator).

#### VX-183 — the panel's doors, declared (debt, not a bug — no red-on-old pin owed)

**What was true (against `d9e1eaf2`):** the panel rendered six doors inline — the composer's Add
(`CommentsPanel.swift`, the composer's foot), a live row's Save and Revert inside `if dirty { … }` then Delete
(`stampLine`), a deleted row's Restore and Delete forever… (`deletedRow`) — each a hand-built `Button` with a
`CommentsPanelCopy` word, and NONE declared in the capability registry (`CommentsPanel` had no `surfaceCapabilities`;
VX-179 U1's O-2). P-1: every act declared once, surfaces render FROM the registry, gating is data; the grow-as-touched
precision brings them in as panel work touches them (VX-257 did). Nothing behaved wrongly — so, per the brief, no
red-on-old pin: the pins below hold the declaration whole and prove nothing moved.

**Built (`Registry/Capability.swift`, `Registry/CapabilityRegistry.swift`, `CommentsPanel.swift`; one walk line in
`CapabilityRegistryTests`):**
- Six ids — `addComment`, `saveComment`, `revertComment`, `deleteComment`, `restoreComment`, `deleteCommentForever` — each
  a `.surface` act, `.block` scope, `takesAccess: .native` (R118 — the Takes board hosts the panel natively), keyless
  (⌘⏎ and ⎋ are the panel's local monitor's, said by the composer's hint line — not menu keys), `availability: always`
  (the panel IS the context — the `.deleteNow` posture), an `unavailableNote` naming the road. **The verbs are the
  panel's words** ("Add", "Save", "Revert", "Delete", "Restore", "Delete forever…") and `CommentsPanelCopy`'s six door
  words now READ them from the registry — one source.
- **Gating as data:** `CommentsPanelDoors` — `composer` `[add]`; `liveRow(dirty:)` `[save, revert, delete]` /
  `[delete]`; `deletedRow` `[restore, deleteForever]`; `emphasis(_:)` (primary: add, save, restore; quiet: the rest).
  The view renders each row by iterating the rule through ONE builder (`doorButton(_:on:)` — the registry's verb, the
  rule's emphasis, Delete forever's tooltip) — the same doors, order, words and emphasis as before. The Add door's
  enablement stays `CommentComposition.filing`'s pure answer (`isAddDraftFilable`).
- **One dispatch:** `CommentsPanelModel.act(_:on:)` — every rendered door acts through it by its declared id (Delete
  forever only ASKS there; the confirm is the act, unchanged). A non-panel id is a DEBUG assertion.
- `CommentsPanel.surfaceCapabilities = CommentsPanelDoors.all`; the registry walk unions it (a JUSTIFIED EDIT — a new
  renderer is a new line), so declared ⇔ rendered holds by construction — and the fold's purge door is walked as living
  in a trash surface only.

**Pins — `CommentPanelDoorsTests` (new) + the walk line (all PENDING the stage; none red-on-old by design):**
`eachDoorIsDeclaredOnceAsASurfaceActInThePanelsOwnWords` (each declaration's door set, scope, Takes access, no chord, the
shipped word — and the copy reading it) · `theRowsRenderTheSameDoorsInTheSameOrder` (the rule's table = the old
if-statements, emphasis included; the panel declares exactly the six) · `deleteForeverIsATrashSurfaceDoorOnly` ·
`everyDoorActsThroughTheOneDispatch` (Add files, Revert puts back, Save writes, Delete folds, Restore returns, Delete
forever asks and the confirm takes it — against the store) · `CapabilityRegistryTests
.theSurfacesRenderExactlyTheDeclaredSurfaceActs` (its new line). The walk (W3) presses each door live.

#### VX-182 — `restoreCost.deleted_takes` gains the purge fence (core, headless)

**The trace (against `d9e1eaf2`):** `Queries.restoreCost` — the version-restore confirm's only source of facts — counts
population 2 as `variant … deleted_at IS NOT NULL` with no fence (`Queries/RestoreCost.swift:140-142`). Every READER of
deleted takes fences purge intents stamp-aware — Block History's `Queries.deletedTakes` (`Queries/EditorSupport.swift:146-153`)
and the tray's take rows — so a take Delete-Now'd from the tray (its intent standing until the janitor's horizon under a
sync chain; on a never-signed-in install the local sweep removes the row at once, so only synced stores show it) was
listed nowhere yet still counted as "waiting in Block History" in the confirm (`VersionsCopy` renders the count). VX-179
U1 item 3 fenced the comments' twin (population 3, `:146-152`) and left this one (its O-1).

**The fix:** the comments' STAMP-AWARE arm, copied onto the takes' count — `NOT EXISTS (purge_intent pi WHERE
pi.table_name = 'variant' AND pi.row_id = v.id AND (pi.deleted_at IS NULL OR pi.deleted_at >= v.deleted_at))`: a live
intent fences; a completed one fences only the tombstone it covered; a VOIDED one (`restoreVariant` voids — 13j ladder B,
B1) never hides a fresh re-delete. Read-side only: zero `Sync/`, zero `PurgeJanitor`, zero schema.

**Pins (`Tests/VariorumCoreTests/RestoreCostTests.swift`, headless):**
- `aTakeDeletedForeverIsNotCountedAsStillRestorable` — **RED ON OLD, run:** at `f38fb93c` (pins, query unfixed)
  `swift test --filter RestoreCostTests` → 8 tests, **1 issue** (`cost.deletedTakes == 1` read 2); fixed (this commit) →
  **8 tests / 1 suite passed**.
- `aTakePutBackAndDeletedAgainCountsAgain` — GUARD (green both sides): the stamp clause's own pin — an any-state fence
  would hide the re-deleted take Block History lists. **Discriminating revert R-182 (named here, runs next):** the stamp
  clause `AND (pi.deleted_at IS NULL OR pi.deleted_at >= v.deleted_at)` removed from the new arm → expect exactly this
  guard red; restore by `git checkout -- Sources/VariorumCore/Queries/RestoreCost.swift` from this commit, `git diff`
  empty.

**Revert R-182 — RAN, as designed:** the stamp clause off → `swift test --filter RestoreCostTests` 8 tests, **1 issue,
exactly the guard** (`aTakePutBackAndDeletedAgainCountsAgain`: 0 for 1 — the any-state fence hid the re-deleted take);
restored by `git checkout -- Sources/VariorumCore/Queries/RestoreCost.swift`, `git diff` empty, 8/1 green again.

#### U5 — headless counts, products, observations

- **Core, whole package at the unit's tip (`fd4c260c` + the record):** `swift test` → **VariorumCoreTests 2,801 tests /
  320 suites passed** (U2's 2,799 + VX-182's two), VariorumMCPTests 212/41, workbook 40/6 — EXIT 0.
- **Mac:** `build-for-testing` at the tip → TEST BUILD SUCCEEDED (`DerivedData/vx282-u5` — the FIXED products: VX-257,
  VX-183, VX-182; VX-229 reverted). **OLD products:** `DerivedData/vx282-u5-old-products` = the build of `7d798f82` (the
  VX-229/VX-257 pins over the pre-fix app; VX-183's pins post-date it by design — not red-on-old; VX-182's red-on-old ran
  headless). One new tree, as briefed (the old products an APFS clone of its `Build/Products`).
- **Phone:** `xcodebuild build -scheme VariorumMobile -destination 'generic/platform=iOS Simulator'` (same tree) → BUILD
  SUCCEEDED with the shared park's two defaulted additions; `MobileComments.swift` byte-unchanged.
- **The diff (U5 whole):** `Features/Editor/CommentsPanel.swift` (the model's `leave()`/`keepAddDraftOnLeaving()`/`opened`/
  the restore's line rule/`act(_:on:)`/`isObserving`/the DEBUG weak record; `CommentsPanelDoors`; the rows rendering from
  it; `surfaceCapabilities`), `Features/Editor/CommentTextArea.swift` (the caret after text arriving into an empty area),
  `Shared/CommentDraftPark.swift` (`Held.refused`, `park(…refused:)`), `Registry/Capability.swift` +
  `Registry/CapabilityRegistry.swift` (six declarations), `Sources/VariorumCore/Queries/RestoreCost.swift` (the fence);
  tests `CommentPanelHostLifecycleTests.swift` (new), `CommentPanelLeaveTests.swift` (new), `CommentPanelDoorsTests.swift`
  (new), `CommentPanelParkTests.swift` (one doc), `CapabilityRegistryTests.swift` (one walk line),
  `Tests/VariorumCoreTests/RestoreCostTests.swift` (two pins). Zero `Sync/`, custody, Keychain, schema; nothing in
  `BlockDecor`, the gutter cards, `ProseGutter`, `EditorSurfaceController`, `BlockRangeIndex`, `EditorEditRoute`/
  `SeamCarvePlan`, `EditorViewModel.storageDidEdit` or the markdown face. **Outside the run's declared surfaces:**
  `CommentTextArea.swift` (one adopt rule, VX-257's restore caret) — said here and in the report.
- **O-U5-1 (for the orchestrator — VX-179's record):** VX-179 FIX LEG 3's stale-panel finding (`stale.swift`) and the
  monitor release it motivated rest on the same undrained-pool offscreen shape this unit's CORRECTION exposed; on this
  evidence a dismissed popover's panel is released by SwiftUI once nothing holds its window. The release code is harmless
  and stays; its pin (`aDismissedPopoversPanelStopsListening`) may be pinning a road the runner never takes. W3's live
  `heap` count speaks to both.
- **O-U5-2 (untraced past this):** `restoreCost.deletedTakes` has no 30-day window, while Block History's
  `deletedTakes` lists only the last 30 days — so past the window the confirm may count a take Block History no longer
  offers (if expired tombstones are not otherwise removed — not checked). Comments agree on both sides (neither is
  windowed). Pre-existing; not VX-182's fence; a ticket candidate.

#### THE WINDOW PLAN (≈42 min; runs only on the orchestrator's claim line; `guard.sh --author` before every leg)

From `App/Variorum/`; logs to `notes/plans/vx282-screens/u5/logs/`, captures to `notes/plans/vx282-screens/u5/`. `pgrep`
first — no `/Applications/Variorum.app` instance, none of ours.
- **W1 — red on old (≈4 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u5-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'`
  with `-only-testing:VariorumTests/` × `CommentPanelHostSuites` (the serialized parent of `CommentPanelReleaseTests` and
  `CommentPanelHostLeavingTests` — `dab712d8`) `CommentPanelLeaveTests` `CommentPanelParkTests` → `w1-red-on-old.log`. EXPECTED: VX-257 RED — `CommentPanelLeaveTests`
  `leavingWithAHalfTyped…` (1), `escapeAfterARestore…` (1, its premise), `anotherBlocks…` (2); `CommentPanelHostLeavingTests`
  all three (2 each: the text, the caret) — **10 issues in 6 cases**; GREEN — the three model guards and
  `CommentPanelParkTests` (8). **VX-229 — THE DECIDING CELL:** `CommentPanelReleaseTests` EXPECTED GREEN on old (hollow) —
  if `aDismissedPopoverLetsGoOfItsPanelsModelAndItsObservation` is RED on old, the leak is real in the runner: report it,
  and the fix comes back (`ee86dd8c`'s surface split) with a rebuild and a W2 re-run. Its two sheet guards: green.
- **W2 — the fixed batch, `-derivedDataPath DerivedData/vx282-u5` (≈12 min), THREE groups (suite TYPE names, grepped;
  the mounted popover/sheet suites kept in separate invocations — Swift Testing runs suites in parallel in one process):**
  (g1) `CommentPanelHostSuites` `CommentPanelLeaveTests` `CommentPanelDoorsTests` `CommentPanelParkTests`
  `CommentsPanelModelEditorTests` `CommentCompositionTests` `CommentPanelKeysTests` `CommentsAndReorderTests`
  `CapabilityRegistryTests` `TrashSurfaceTests` `NoteVersionsPaneTests` → `w2-g1.log`; (g2) `CommentPanelFixLeg2Tests`
  `CommentTextAreaMountedTests` `CommentPanelGeometryRuleTests` `CommentPanelWordsTests` `CommentCardLayoutTests`
  `CommentCardViewTests` `CommentCardControllerTests` `MarginHoverCommentTests` `IndicatorGutterTests` `ProseGutterTests`
  `BlockDecorGeometryTests` → `w2-g2.log`; (g3) `WriteTakesPanelRoutedCommandTests` `WriteTakesPanelKeysTests` →
  `w2-g3.log`. EXPECTED: all green. Read every suite's ✔/✘ line and the skips (a wrong name runs 0 tests and still
  "succeeds"; the nested `CommentPanelHostSuites` must show BOTH child suites' ✔ lines).
- **W3 — the walk (≈25 min), `DerivedData/vx282-u5/Build/Products/Debug/Variorum.app` on the DEV store only** (dismiss a
  What's New sheet with its own button if shown; the voice as found, recorded; Study if it is the dev store's). Stage a
  note through the shelf's quick-entry bar: `{t:"VX-257 walk"}alpha` ⇧⏎ `beta` ⏎ → it opens in Write; give `alpha` one
  comment through ⌘⇧' (type `first`, ⌘⏎, Close) so its Takes margin note exists. Region captures before/after each row:
  1. **The popover (her ruling's road):** ⌘2 (Takes) → click `alpha`'s margin note → type `half a thou` → click away (on
     the page, outside the popover) → click the margin note again: **`half a thou` is back, the caret after it**, no
     refusal line (capture).
  2. **⎋ clears:** in that reopened popover ⎋ (the box empties, the popover stays) → ⎋ (it closes) → reopen: **empty**.
  3. **Write's sheet:** ⌘1 → caret in `alpha` → ⌘⇧' → type `sheet draft` → Close → ⌘⇧' again: **back** (capture) → ⎋ ⎋
     → ⌘⇧': empty.
  4. **The take panel's nested sheet:** caret in `beta`, ⌘T (a fan) → ⌘↑ (caret back in `alpha`) → open `beta`'s panel from
     its ⑂ badge → ⌘⇧' (the comments over the panel) → type `nested draft` → Close → ⌘⇧' again: **back** (capture) → Close
     → ⌘⇧T closes the panel.
  5. **The doors still work (VX-183):** in `alpha`'s comments (⌘⇧'): **Add** (type `second`, the Add button) → the row;
     a row's **Delete** → the fold shows it ("Comment deleted — it's under Deleted below, restorable."); open the fold →
     **Restore** → back; Delete it again → **Delete forever…** → the confirm appears ("Delete this comment forever?") →
     **Cancel** → still in the fold (captures). Close.
  6. **VX-229, live (the arbiter):** in Takes, open and click-away-dismiss `alpha`'s margin popover three times, then
     `heap <our pid> | grep -E "CommentsPanelModel"` → record the instance count (0 = released: VX-229 hollow live; 3 =
     the leak is real). If `heap` cannot attach without a prompt, skip it and say so — never answer a system dialog.
  7. **The second voice** (⌘K "Use Terminal Voice" / "Use Study Voice", whichever is not current): repeat row 1's
     click-away and reopen (capture) → restore the voice found.
  Then the walk note to the Trash (residue recorded), quit OUR instance by identity, `pgrep` again, the dev store left
  Standard and unlocked with its voice as found, release the claim.

### U6 — VX-326 (the Bookcase's quick entry isn't focused at launch)

**NOT DONE BY THIS UNIT (first line):** **navigating back to the Bookcase is NOT fixed** — it drops the ask exactly as
it does today (O-U6-1, the brief's scope line; seen live at W3 row D). The brief's "relaunch with a note open" row could
not be staged as written: the main window never launches onto a note (premise correction 3), and on this Mac a note
WINDOW open and key at quit was NOT restored at relaunch (W3 row B) — so P-U6-1's "another window is key" case has no
live evidence; a new window (File ▸ New Window) was walked in its place. The unit's evidence comes from products built
at `ee1facc9`, before the branch merged main at `ece30a41` (the coordinator's word: fine for unit evidence; the
closeout runs the merged tip).

**State: DONE — every leg held** (the stage window 05:27:17–05:38:17, below). Implementer: an `opus-implementer` session
(Opus 5.5, xhigh), 2026-10-14. **Revert state: no behavioural revert in flight** (the old-products revert named at
`07f03fa5` ran and was restored before the window).

**Her word (2026-10-14, overnight):** *"yeah you can fix this ticket if you think it's an annoying issue: New ticket
VX-326"* — the orchestrator ruled: fix it (the Bookcase already ASKS for focus on mount; a launch without the caret
falls short of the existing intent — R102, `phase-13-ui-design.md:1659`: *"The shelf also opens with the cursor already
IN the bar ('start typing' is literal now)"*). No canon line or ruling says the Bookcase should NOT take the caret at
launch (the STOP condition was checked: R-13s-3 places the box at the foot and says nothing on focus; "no popup greets
a first open" is about popups; W-U1a-1 is about the TOUR's start).

#### The trace (headless, against `c2b3ba72`) — candidate 2 of the brief: the ask fires before the box is in a window

1. **The ask.** The Bookcase builds its bar with `autofocus: true` (`ShelfView.swift:984` at `c2b3ba72`), and the bar
   asks once from its `.task`: `if autofocus { focusRequest += 1 }` (`QuickEntryBar.swift:312-314`).
2. **The serve.** `CaptureTextView.updateNSView` sees the counted request change, bumps `lastFocusRequest` and calls
   `takeFocus()` (`CaptureTextView.swift:266-269`), whose first line is `guard let view, let window = view.window
   else { return }` (`:398`). A windowless box returns there with the ask already SPENT. Nothing retries it:
   `viewDidMoveToWindow` (`:486-511`) serves only `wantsInitialFocus` (set at make from a request already > 0, `:238`
   — the pad's road; the bar's is raised a turn later, so false) and U4's held-keyboard re-take (the box held nothing).
3. **The launch's order.** The main window is not born showing the shell: `beginOpening` sets `.opening`
   (`AppBootstrap.swift:243`) and the store opens off the main actor; the window shows `StoreOpeningView`
   (`VariorumApp.swift:426-430`) until `finish` writes `.ready` (`AppBootstrap.swift:514`), and `mainWindowContent`
   SWAPS `RootView` in. The shell's first focused selection is always the Bookcase (`WorkspaceModel.swift:45`,
   `[.primary: .shelf]`; `RootView.paneDetail` `.shelf, nil` → `ShelfView`). In a swap, SwiftUI runs the new bar's
   `.task` — and the update its raise causes — a pass BEFORE it puts the box in the window.
4. **MEASURED, not reasoned (two scratch probes, never committed, `.prohibited`, every window off every display and
   alpha 0, checked against every `NSScreen` before and after ordering in; the unsandboxed store folders checked
   absent before and after; no defaults domain left behind):**
   - *Pure SwiftUI + AppKit* (a representable logging its serve and its arrival, a `.task { request += 1 }` like the
     bar's): in every shape — the hosting view's first content, a launch swap, a deeper swap, a navigation back — the
     serve ran with **`window = nil`, ~5 ms before `viewDidMoveToWindow`**.
   - *The REAL module* (linked against `Variorum.debug.dylib` of `DerivedData/vx282-u4` with `@testable import
     Variorum`, an in-memory store by `prepareDependencies`; the production `RootView` behind an opening face, flipped
     ready from a main-actor task as `finish` does; every `makeFirstResponder` call logged by the window, every arrival
     of a `CaptureNSTextView` logged; the box's coordinator read at the end):

     | shape | pre-fix (`c2b3ba72`) | fixed (`3cf0079b`) |
     |---|---|---|
     | `RootView` as the window's FIRST content (the test suites' mount) | box arrives, then `makeFirstResponder(box)`: **the caret lands** | the caret lands (the opening road) |
     | **the LAUNCH swap** (opening face → `RootView`) | box arrives 0.453 s, **no `makeFirstResponder` call ever**; `lastFocusRequest = 1` — the ask was SPENT; the window keeps the keyboard | `makeFirstResponder(box)` at arrival + one turn: **the caret lands** |
     | a navigation Library → Bookcase | the new box arrives, no call, `lastFocusRequest = 1`; **the window keeps the keyboard** | the same — **the window keeps the keyboard** (the brief's scope; O-U6-1) |

   So the brief's other two candidates are excluded on this evidence: the launch road DOES run the mount ask (step 1,
   spent), and key-ness is not the gate — `makeFirstResponder` seats a first responder in a window that is not key
   (the "first content" row above, in a never-key `.prohibited` window), so a request served windowed lands whatever
   the key state. This is F-FR-1 (17y B2, `phase-17-standing-fixes.md:2630` — "a focus request raised before the
   capture box is in a window is DROPPED … untraced in the real app"), now traced in the real composition, and
   O-U4-3's live sighting is its launch face.
5. **Why the suites never saw it:** `TourEntryTests` and `CaptureTourFocusTests` mount `RootView` as the window's
   FIRST content and settle with a forced layout before each run-loop slice — the order in which the box is in its
   window before the ask is served (their precondition "the Bookcase put the caret in its quick entry" holds on the
   old tree too). The launch's own order needs the swap and a settle that only suspends.

**Three premise corrections for the orchestrator (the brief's rule list, read against the trace):**
1. **The gate is the WINDOW, not the key.** The brief's rule reads "as soon as its window is key". The ask is lost
   because the box has no window yet; a box in a window that is not yet key can hold the first responder, and the
   caret is live the moment the window becomes key. Built on that reading — PROVISIONAL **P-U6-1** below.
2. **A navigation back to the Bookcase drops the ask TODAY** (measured, the table's third row; consistent with U4's
   walk row E1, where a tour started from a note landed on the Bookcase with the WINDOW holding the keyboard — U4's
   static trace had predicted the caret in the bar there, which is how P-U4-2 came to be raised and withdrawn). So R102
   holds at no in-place mount in the running app. "Navigating to the Bookcase later behaves exactly as today" is
   honoured — it still drops — and the gap is **O-U6-1** for the orchestrator to ticket (one unit = one surface; the
   tour interplay is why it is not a one-liner: see O-U6-1).
3. **The main window never launches onto a note.** Its workspace always opens on the Bookcase (`WorkspaceModel.swift:45`);
   VX-139 restores the Open STRIP at launch (`restoreRememberedOpenNotes`), never the selection. "Launching onto a
   restored note" exists only as a restored NOTE WINDOW (`noteWindows`, `VariorumApp.swift:461-492`), which the box
   never touches: the rule decides on the facts of the box's OWN window, and `makeFirstResponder` on the main window
   moves neither the key window nor the note window's editor. W3 row B checks it live.

#### The fix (`3cf0079b`; pins ahead at `d35191b6`) — four files, zero `Sources/`, `Sync/`, custody, Keychain, schema, `Shared/`

- **`Core/Views/CaptureTextView.swift` — the shared box gains a second counted ask, the OPENING ask.**
  - `CaptureOpeningFocus` (`:123`, a pure `nonisolated enum` beside `CaptureKeys`): facts `inWindow` · `keyboard`
    (`.nobody` = the window itself or nothing is first responder · `.theBox` · `.someoneElse`) · `sheetOnWindow` →
    verdict `.wait` (not in a window) · `.take` (free keyboard, no sheet) · `.drop` (anything else holds this
    window's keyboard, or a sheet is on it) · `.alreadyHeld`.
  - `CaptureTextView.openingFocusRequest` (`:211`, default 0 — the pad and the Library's bar never raise it); the
    coordinator's `lastOpeningFocusRequest` (made boxes do not inherit an earlier ask, `:306`); `updateNSView` arms
    the box when it changes (`:338-339`).
  - `CaptureNSTextView.armOpeningFocus()` (`:541`) raises `openingFocusPending` and decides on the NEXT main-queue
    turn — never inside the SwiftUI update or layout pass that delivered it, so the window's keyboard is read after
    that pass settles; `decideOpeningFocus()` (`:552`) applies the rule ONCE and lowers the flag on `take`, `drop` or
    `alreadyHeld`; `viewDidMoveToWindow` re-schedules the decision while the flag is up (`:627`). Never steals, never
    served late, served once; other windows are never consulted.
  - Unchanged: `takeFocus()` and its guard (`:469-470` — the explicit asks: her click on the padding, the title chip,
    and every later Bookcase mount's raise), the pad's `wantsInitialFocus`, U4's held-keyboard re-take, the undo
    history, the keys, the geometry. Two comments corrected (F-FR-1 is no longer "UNTRACED").
- **`Features/Shelf/QuickEntryBar.swift`** — `QuickEntryOpeningFocus` (`:181`, a one-bit `@MainActor` claim: `claim()`
  is true exactly once); the bar takes it as an optional `openingFocus` (defaulted nil — the Library's bar and every
  harness mount unchanged) and its `.task` claims it: the claim won → `openingFocusRequest += 1` (`:343`); otherwise
  `focusRequest += 1` exactly as before (`:351`).
- **`Features/Shelf/ShelfView.swift`** (`:96`, `:988`) and **`RootView.swift`** (`:98`, `:1168`) — the shell owns ONE
  claim per `RootView` (`@State` — one per window, a fresh one after every unlock, as VX-139's per-shell claim) and
  hands it to the Bookcase. **Both files are outside the run's declared surfaces** (two pass-through lines each,
  plus a doc comment) — said here and in the report. Nothing in `BlockDecor`, the gutter, `EditorSurfaceController`,
  `BlockRangeIndex`, `EditorEditRoute`/`SeamCarvePlan`, `EditorViewModel.storageDidEdit` or the markdown face.
- **The scope, as built:** a shell OPENING on the Bookcase — a launch, an unlock (the lock screen swaps in the same
  way), a new window — asks through the opening road; every later Bookcase mount in that shell (a navigation back, a
  wing switch's remount) finds the claim spent and keeps today's raise. PROVISIONAL **P-U6-2**.

#### The pins — `VariorumTests/QuickEntryLaunchFocusTests.swift` (red-on-old) + `QuickEntryOpeningFocusTests.swift` (the fix's guards), both new

**Committed AHEAD of the fix (`d35191b6`), CORRECTED before any run (`ee1facc9`) — the OLD products are those pins over
the pre-fix app.** The correction, a harness fact measured offscreen: **AppKit makes a window's first text field its
first responder the moment the window is first ordered in** (key or not — a `.prohibited` probe's non-key window; the
log shows `makeFirstResponder(NSTextView)` during the order-in). The first rig kept a stand-in field in the launch
window, so the field held the keyboard from the start and the launch pin would have failed on BOTH sides. The rig now
frees the keyboard right after ordering in (the launch's own state — the opening face holds nothing) and the launch pin
asserts that premise; the field pin puts the field there itself. The fix's guard suites moved to their own file at the
same commit so the old products build from the pins file alone. The production shell in the launch's own shape: `LaunchShell` is `mainWindowContent`'s switch in miniature (an opening face, then `RootView` when
"ready"); the window (`LaunchWindow`) reports key when the pin says so and posts AppKit's own `didBecomeKey`
(`WindowsTests`' road — this host never makes a window key); every settle only SUSPENDS (no forced layout, no nested
run loop), so SwiftUI's own pass decides when the box reaches its window — the forced layout of the other suites'
settles inserts the box before the ask and would make the pin vacuous.

| Suite · test | Asserts | Old | Fixed |
|---|---|---|---|
| `QuickEntryLaunchFocusTests` · `theShellOpeningOnTheBookcasePutsTheCaretInItsQuickEntry` | the opening face holds no keyboard (premise); → ready; the Bookcase's box arrives in the window; the window turns key → the box is the first responder | **RED (1 issue — the last cell)** | green |
| `QuickEntryLaunchFocusTests` · `aFieldHoldingTheKeyboardKeepsItAcrossTheOpening` | a field holds the keyboard before the shell opens → it keeps it through the opening, the key moment and a re-attach of the box | GUARD (green — the ask is dropped windowless) | green (dropped: `.someoneElse`) |
| `QuickEntryLaunchFocusTests` · `aSheetOnTheWindowAtTheOpeningKeepsTheKeyboardFromTheQuickEntry` | a sheet on the window when the shell opens → the box never takes the keyboard, during it or after it closes | GUARD (green) | green (dropped: the sheet) |

**Added WITH the fix (`3cf0079b`; in `QuickEntryOpeningFocusTests.swift` since `ee1facc9`) — they name what the old tree
lacks, so they are GUARDS of the fixed product (the box rig frees its keyboard after ordering in, the same harness fact,
and its two "free keyboard" cases assert it):**

| Suite · test | Asserts |
|---|---|
| `CaptureOpeningFocusRuleTests` · `outOfItsWindowTheAskWaits`, `inItsWindowTheAskTakesOnlyAFreeKeyboard` | the rule as a table (every cell) |
| `CaptureOpeningFocusBoxTests` · `anAskArmedOutOfTheWindowIsDecidedOnArrival` | the launch's order at the box (the host detached, the ask armed, `openingFocusPending` up while out of the window; re-attached → the caret, the flag down) |
| `CaptureOpeningFocusBoxTests` · `anAskNeverStealsAndIsNeverServedLate` | a field takes the keyboard while the ask waits → kept; the flag down (dropped); a later release + re-attach serves nothing |
| `CaptureOpeningFocusBoxTests` · `anAskOnAFreeWindowTakesTheCaretAndIsServedOnce` | through the representable: raised on a free window → the caret; after a release + re-attach the box stays away (VX-112's contract unchanged) |
| `CaptureOpeningFocusBoxTests` · `anAskWithASheetOnTheWindowIsDropped` | through the representable: a sheet on the window → dropped; the sheet's close serves nothing |
| `QuickEntryOpeningScopeTests` · `theClaimIsTrueExactlyOnce` | the claim object |
| `QuickEntryOpeningScopeTests` · `aNavigationBackToTheBookcaseKeepsTheBarsRaiseAsItWas` | the shell opens (the opening road: `lastOpeningFocusRequest == 1`, `lastFocusRequest == 0`, the caret in the box); Library and back → the NEW Bookcase box raised `focusRequest` (1) and no opening ask (0) — the scope line, asserted on the asks rather than on the outcome (the outcome is today's drop, O-U6-1) |

**The harness facts the pins live with:** this host has no key window (`WindowsTests`' header), so the launch pin's
key moment is the posted notification and `isKeyWindow` — AppKit's own posting under a real hand is the walk's (W3).
The "another window is key" case (a restored note window) is not buildable here (`NSApp.keyWindow` stays nil) and the
rule never consults other windows anyway; W3 row B is its evidence. U4's `CaptureFocusReattachTests` and
`CaptureTourFocusTests` are untouched and expected green (they use the counted ask, and the RootView mount's opening
ask lands in the first-content order exactly as the counted one did).

#### The products (no new full tree, as briefed)

- **Old:** `App/Variorum/DerivedData/vx282-u6-old-products` — the corrected pins (`ee1facc9`) over the PRE-FIX app, by the
  revert NAMED first at `07f03fa5`: `CaptureTextView.swift`, `QuickEntryBar.swift`, `ShelfView.swift`, `RootView.swift`
  checked out from `d35191b6` and `QuickEntryOpeningFocusTests.swift` set aside, `build-for-testing` into `vx282-u4`
  (TEST BUILD SUCCEEDED), `Build/Products` APFS-cloned out (`cp -c`, ≈456 MB logical) replacing the first old products,
  then RESTORED by `git checkout HEAD --` (`git status` clean). `nm`: the app dylib carries 0 `openingFocus` symbols; the
  test bundle carries the pins (42 `QuickEntryLaunchFocusTests` symbols, the rig's `keyboardIsFree`) and no guard suite.
- **Fixed:** `App/Variorum/DerivedData/vx282-u4` — rebuilt LAST, after the restore (the code of `ee1facc9`), TEST BUILD
  SUCCEEDED; `nm`: 232 `openingFocus` symbols in the app dylib, the three guard suites in the test bundle. No new warning
  in a touched file (the five `ShelfView.swift` warnings in the log are pre-existing lines — `+` on `Text`, `placement`).
- **Offscreen replay of the pins' two rig shapes on the real module** (the probe road above, the window holding a field
  that is freed after ordering in, then the launch swap): old products — the launch shape ends on the WINDOW
  (`lastFocusRequest = 1`, no `makeFirstResponder(box)`), the field shape on the field; fixed — the launch shape ends on
  the CAPTURE BOX (`makeFirstResponder(box)` one turn after its arrival), the field shape on the field. What the pins
  will assert, seen once before the stage.
  **For U4's u4b:** this tree now holds U4's final code + U5's committed code + U6 (additive); U4's five suites test
  what they tested (the undo suites and the reattach suite never touch the opening ask; `CaptureTourFocusTests`' shell
  mount takes the caret by the opening road where it took it by the counted one — the offscreen replay's "first
  content" row shows the caret landing on both). `vx282-u4-old-products` is untouched.
- No core file touched → no `swift test` owed. No phone file touched → no phone build owed (`Core/Views/` and the
  Bookcase are Mac-only; the phone's capture is its own road). MOBILE PARITY: nothing mobile-visible.

#### PROVISIONALs (QUESTIONS #224)

- **P-U6-1 — the opening ask is decided when the box reaches its window, on that window's facts alone.** Built (a):
  take the caret when this window's keyboard is free and no sheet is on it, else drop; other windows never consulted
  — so with a restored note window key at launch, the note keeps its editor and the main window's bar holds the caret
  for when she clicks back there (AppKit's per-window first responder). Options: (b) the brief's literal — wait until
  THIS window becomes key and decide then, dropping the ask if a different window becomes key first (a key-change
  watch; a brand-new window, which AppKit keys just after its content arrives, then needs its own allowance); (c) as
  (a), but also drop when another window of the app is key at the decision.
- **P-U6-2 — the opening ask is the shell's, once.** Built (a): the first Bookcase bar of each shell — a launch, every
  unlock, a new window — asks through the opening road; every later Bookcase mount (a navigation back, a wing
  switch's remount) keeps today's raise (which still drops — O-U6-1). Options: (b) every Bookcase mount through the
  opening road (R102's letter, "the shelf opens with the cursor already in the bar"), with the bar standing down while
  a tour runs (W-U1a-1 — a tour started away from the Bookcase lands there after its release); (c) the process's
  first shell only (not after an unlock, not in a new window).

#### Observations (not fixed — for the orchestrator)

- **O-U6-1 — a navigation back to the Bookcase never puts the caret in the bar** (R102's in-place half; measured above).
  Pre-existing since 13u3 UNIT C made the box an AppKit representable (the SwiftUI field's `@FocusState` had waited for
  its window by itself). Fixing it is the same rule pointed at every mount (P-U6-2 (b)), BUT a tour started away from
  the Bookcase navigates there after its release (W-U1a-1), so the bar must stand down while a tour runs, or the tour
  must release again when its navigation lands (P-U4-2's withdrawn options). A ticket, pre-launch at her call.
- **O-U6-2 — the run record's first ten lines** (above its title) are a stray copy of U5's W2 plan; left untouched
  (U5's text).
- **O-U6-3 — U4's candidate 2 trace** ("the bar's `.task` raise lands at least one turn later → `takeFocus` → the
  caret in the bar") assumed the box was windowed at the raise; the real composition drops it windowless. E1's live
  result already agreed; nothing to change in U4's code.

#### THE WINDOW PLAN (≈38 min; runs only on the orchestrator's claim line; `guard.sh --author` before every leg)

From `App/Variorum/`; logs to `notes/plans/vx282-screens/u6/logs/`, captures to `notes/plans/vx282-screens/u6/`.
`pgrep -fl 'Variorum.app/Contents/MacOS'` first — no `/Applications/Variorum.app` instance, none of ours.

- **W1 — red on old (≈3 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u6-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
  -only-testing:VariorumTests/QuickEntryLaunchFocusTests` → `w1-red-on-old.log`. EXPECTED: **1 test failed with 1
  issue** (`theShellOpeningOnTheBookcasePutsTheCaretInItsQuickEntry`, its last cell — the keyboard on the window), the
  two guards green. A GREEN on old means this host's run loop did not reproduce the launch's order — recorded as
  such (the walk then carries the red-on-old evidence; U4's `00-launch.png` and W3 row A0 are its live form).
- **W2 — the fixed Mac batch, `-derivedDataPath DerivedData/vx282-u4` (≈12 min), three groups (suite TYPE names,
  grepped; every suite's ✔/✘ line and the skips read):**
  (g1) `QuickEntryLaunchFocusTests` `CaptureOpeningFocusRuleTests` `CaptureOpeningFocusBoxTests`
  `QuickEntryOpeningScopeTests` `CaptureUndoHistoryTests` `CaptureUndoSyncTests` `CaptureHostsUndoFilingTests`
  `CaptureFocusReattachTests` `CaptureTourFocusTests` `CaptureFocusReportTests` `CaptureKeysTests`
  `CaptureTextViewKeyTests` `CaptureHandOffTests` `QuickEntryBarTests` `BookcaseQuickEntryPlacementTests`
  `QuickNoteMintTests` `QuickNoteDoorTests` `QuickNoteWindowTests` `QuickNoteWordTests` `QuickNoteParkTests` →
  `w2-g1.log`;
  (g2) the tour: `TourScriptTests` `TourSpotlightTests` `TourEngineTests` `TourPoolTuckTests` `TourEntryTests`
  `TourEndCardTests` `TourEndCardAsideGateTests` `TourOfferLineTests` → `w2-g2.log`;
  (g3) every suite that mounts the real shell, and the launch/restore suites: `ShellChromeTests`
  `ShellLandingMountTests` `ShellLandingDoorTests` `NavigationDoorsTests` `PaneSplitDoorTests` `NoteBoxSlotTests`
  `NoteBoxCompositionTests` `AscentRoutingTests` `BookPanelActingTests` `DebugOracleTwoWindowTests`
  `TwoWindowMountTests` `CreationTargetTests` `WindowRegistryTests` `OpenNotesRestoreTests`
  `OpenNotesModelRestoreTests` → `w2-g3.log`. EXPECTED: all green (none of the standing reds VX-115/VX-245/VX-167 is
  in these groups).
- **W3 — the walk (≈23 min), `DerivedData/vx282-u4/Build/Products/Debug/Variorum.app` on the DEV store only.** Launch by
  `open -n <that path>`; the dev store opens unlocked (Standard). **If a What's New sheet greets a launch:** dismiss it
  with its own button, quit OUR instance by identity, relaunch (it greets once per version), and only then take the
  launch row's readings — a sheet on the window at the opening drops the ask by the rule. Keys through `keys.sh` only,
  ≥ 2 s apart; captures by REGION (`screencapture -x -R`); the caret's truth read by AX (`tell (first application
  process whose unix id is <pid>) to get {role of (value of attribute "AXFocusedUIElement"), name of (value of
  attribute "AXFocusedWindow")}` — the box is an `AXTextArea`). Record the voice and appearance found, and
  `defaults read io.lduarte.Variorum.debug variorum.tour.offer` (expect `completed`).
  - **A0 — the OLD build at launch, for the record (≈2 min):** `open -n
    DerivedData/vx282-u6-old-products/Debug/Variorum.app` → AX reads the WINDOW (capture `A0-old-launch.png`) → quit
    it by identity.
  - **A — launch onto the Bookcase (the fixed build):** AX reads `AXTextArea` in the main window, the caret blinking in
    the quick entry (capture `A1-launch.png`); `keys.sh` types `z` → the box shows `z` and the title chip may offer
    a name (capture `A2-typed.png`); ⌫ → empty again, nothing filed.
  - **A' — the second voice:** ⌘K "Use Terminal Voice" (or Study, whichever is not current) → quit by identity →
    relaunch → AX `AXTextArea`; the Terminal block cursor is NOT drawn beside the caret (one cursor — 17y (m)) (capture
    `A3-launch-other-voice.png`) → switch the voice back (⌘K) at the end of the walk.
  - **B — a restored note window:** ⌘K → open any note → its note ▾ ▸ Open in New Window (by AX name) → the note
    window key (AX: its editor, or its window) → quit by identity → relaunch. If macOS restores the note window and it
    comes up key: AX reads the NOTE window's element (its editor keeps the keyboard; capture `B1-note-window.png`) and
    the main window shows no caret in front of her; then click the main window's TITLE BAR only (no content) → AX: the
    main window's `AXTextArea` (P-U6-1 (a): the bar held the caret for when she came back — capture `B2-main.png`).
    Close the note window by its close button. If the note window is NOT restored on this Mac, record that (the
    row then has nothing to check) and close nothing.
  - **C — the tour, no steal:** on the Bookcase with the caret in the bar (AX) → Help ▸ Take the Tour (menu, by AX
    name) → step 1: AX reads the WINDOW (the tour's release, W-U1a-1) (capture `C1-step1.png`) → the card's "next"
    by AX name → step 2: AX the window (capture `C2-step2.png`) → "End tour" by AX name. No keystroke during the tour.
  - **D — the scope line, as today (≈2 min):** ⌘K → `Library` ⏎ → ⌘K → `Bookcase` ⏎ → AX: NOT the box (O-U6-1 —
    expected the window or the palette's leftover; capture `D1-navigate-back.png`).
  - **Cleanup:** nothing filed (every `z` deleted); the note window closed; the voice restored as found;
    `variorum.tour.offer` re-read (expected `completed` — U4's walk ended its tours the same way and the record stayed
    `completed`; record what it reads); the main window left on the Bookcase; quit OUR instance by identity
    (`tell application id "io.lduarte.Variorum.debug" to quit`), `pgrep` empty after; the dev store Standard and
    unlocked; release the claim.

#### THE STAGE WINDOW — RUN 2026-10-14 05:23:19 → 05:25:17 (claim `vx282-u5`, chained from `vx282-u4b`; RELEASED) — STOPPED AFTER W1

The coordinator's GO, part 2 of its chained window: `Tools/stage release --who vx282-u4b && Tools/stage claim --who
vx282-u5 …` (claimed 05:23:19). `git pull --ff-only` first (already at the tip, `03b24597`; nothing rebuilt — the products
are the ones built at `c2b3ba72`). `guard.sh --author` OK (idle 455 s); `pgrep -lx Variorum` and the `MacOS/Variorum$`
anchor: no instance; no booted simulator. Log: `notes/plans/vx282-screens/u5/logs/w1-red-on-old.log`.

- **W1 — red on old** (`vx282-u5-old-products`, the build of `7d798f82` + the hardened pins via the named revert at
  `3a6bad6d`; `CommentPanelHostSuites` `CommentPanelLeaveTests` `CommentPanelParkTests`, 05:23:29–05:24:45): "**20 tests
  in 5 suites failed … 19 issues**", EXIT 65.
  - **VX-257 — RED ON OLD EXACTLY AS PREDICTED: 10 issues in 6 cases** — the three mounted cells 2 each (the text, the
    caret), `leavingWithAHalfTyped…` 1, `escapeAfterARestore…` 1 (its premise), `anotherBlocks…` 2. GREEN on old: the
    three model guards (`escapeClears…`, `aRefusedDraftLeftAsItWas…`, `aPanelThatNeverOpened…`) and
    `CommentPanelParkTests` 8/8.
  - **VX-229 — THE DECIDING CELL IS RED ON OLD:** `aDismissedPopoverLetsGoOfItsPanelsModelAndItsObservation` — "no
    dismissed panel still observes the store (**3 do**)", "no dismissed panel's model is still alive (**3 are**)", "a
    later write is re-read by no dismissed panel (**3 did**)"; every premise held (three openings, three NEW windows, each
    a mounted, observing panel; each closed). **The leak is REAL in the runner** — the ticket's own numbers.
  - **NEW — the sheet guards are RED on old too:** `aDismissedSheetLetsGoOfItsPanel` (the `.sheet(item:)` host — Write's
    and the Takes bar's shape) and `theTakePanelsNestedCommentsSheetLetsGoOfItsPanel` (the real `WriteTakesPanel`'s
    nested sheet) — after EACH of the three dismissals a model of the session was still alive within the 150-turn wait
    (3 issues each; every premise held). So in the runner the sheet hosts do not let go of the panel either. These cells
    assert ALIVE only — whether those sheet models were still OBSERVING is not known from this run. The reverted fix
    (`ee86dd8c`: the popover's `didClose` removes the surface) would not reach a sheet (a sheet posts no `NSPopover`
    notification) — the re-plan needs a road for the sheet hosts as well, and a measurement of their observation.
- **STOPPED** at the coordinator's rule (red on old ⇒ stop; no rebuild mid-window): **W2 and W3 NOT run.** No app was
  launched and the dev store was untouched (as found: Standard, unlocked, Study — U4's report at the handover); no walk
  note; no simulator. **Claim `vx282-u5` RELEASED 05:25:17** (`Tools/stage release --who vx282-u5`; status FREE).
- **Why the offscreen probe disagreed (recorded, not resolved):** the probe app is `.prohibited` (never active, no key
  window) and pumps its own event loop; the runner is the active dev-store app inside `NSApplication.run`. Something in
  the second — not traced — keeps a dismissed host's panel alive. The undrained-pool and held-window effects measured
  offscreen are real effects of those probes, but they are not why the runner leaks.

#### THE u5b WINDOW PLAN (≈40 min; the coordinator's re-plan, 2026-10-14 ~05:30 — no rebuild, the current products; the VX-229 fix stays out)

**The coordinator's ruling on W1's red (recorded):** the runner's red is NOT yet proof of a leak in the APP —
TEXTKIT2_NOTES §3 records that under async test bodies the runner's long-lived main-thread autorelease pool can keep a
dropped mounted view alive past its test; the drained-pool offscreen probe saw every panel released; the app's run loop
drains a pool per event; the sheet guards' reds fit the same hypothesis; and a HELD window does keep content alive and
observing, so if SwiftUI's popover machinery holds the window the app leaks too. **The running app decides (W3 row 6).**

From `App/Variorum/`; logs to `notes/plans/vx282-screens/u5/logs/`, captures to `notes/plans/vx282-screens/u5/`.
`guard.sh --author` before every leg; `pgrep -lx Variorum` / the `MacOS/Variorum$` anchor (never a loose `pgrep -f`).
- **W2 — the fixed batch, `-derivedDataPath DerivedData/vx282-u5`, three groups, `CommentPanelReleaseTests` EXCLUDED (it is
  the question, not a guard):**
  (g1) `CommentPanelHostSuites/CommentPanelHostLeavingTests` (the nested path; if it runs 0 tests, the fallback is
  `-only-testing:VariorumTests/CommentPanelHostSuites -skip-testing:VariorumTests/CommentPanelHostSuites/CommentPanelReleaseTests`
  — the log must show the VX-257 suite's ✔ lines and NO Release-suite line) `CommentPanelLeaveTests`
  `CommentPanelDoorsTests` `CommentPanelParkTests` `CommentsPanelModelEditorTests` `CommentCompositionTests`
  `CommentPanelKeysTests` `CommentsAndReorderTests` `CapabilityRegistryTests` `TrashSurfaceTests` `NoteVersionsPaneTests`
  → `u5b-w2-g1.log`; (g2) as the § U5 plan (`CommentPanelFixLeg2Tests` … `BlockDecorGeometryTests`) → `u5b-w2-g2.log`;
  (g3) `WriteTakesPanelRoutedCommandTests` `WriteTakesPanelKeysTests` → `u5b-w2-g3.log`. EXPECTED all green.
- **W3 — the walk, the FIXED Debug app on the DEV store, with the VX-229 decider first** (so no panel has opened before
  the baseline). `heap` only ever against OUR pid; if it needs a prompt, skip it, say so — VX-229 stays undecided.
  - **Step 0:** launch, dismiss a What's New sheet by its own button, record the voice; stage `{t:"VX-229 walk"}alpha`
    ⇧⏎ `beta` ⏎ through the shelf's quick entry (it opens in Write). **heap (a0):** `heap <pid> 2>&1 | grep -E
    "CommentsPanelModel|ValueConcurrentObserver|ValueWriteOnlyObserver"` → `u5b-heap-a0.txt` (the panel model's count; the
    GRDB observers as a whole — the panel's observation is a `ValueObservation` on the pool, no class of its own, so its
    count is read as the observer total's DELTA).
  - **Row 6a:** give `alpha` its first comment (caret in `alpha`, ⌘⇧', type `first`, ⌘⏎, Close) → wait 2 s → **heap
    (a1)** — one sheet cycle.
  - **Row 6b — the popover:** ⌘2 (Takes) → `alpha`'s margin note → click away, ×3 → wait 2 s → **heap (b)**.
  - **Row 6c — Write's sheet:** ⌘1, caret in `alpha` → ⌘⇧' → Close, ×3 → wait 2 s → **heap (c)**.
  - **Row 6d — the take panel's nested sheet:** caret in `beta`, ⌘T (a fan), ⌘↑; `beta`'s ⑂ badge → the panel; ⌘⇧' →
    Close, ×3 → wait 2 s → **heap (d)**; ⌘⇧T closes the panel → wait 2 s → **heap (d2)**.
  - **The functional symptom:** a comment added after the cycles, and whether anything shows N re-reads — the panel's
    re-read leaves no visible or logged trace, so there is no honest signal for it in the app; recorded as such, not
    invented.
  - **The reading (the coordinator's rule):** counts that grow by ≈ one per cycle ⇒ the leak is REAL in the app (a fix leg
    for the popover AND sheet roads follows, with a rebuild and a short re-run); counts that stay at the live panel's one
    or zero ⇒ VX-229 is HOLLOW in use and the runner's red is a harness artefact ⇒ `CommentPanelReleaseTests` is reshaped
    to the drained-pool shape the probe used (honest, green on the shipped code — never a red pin left in the suite).
  - **Then rows 1–5 and 7 of the § U5 plan** (VX-257: the popover click-away keeps the draft and the reopen shows it; ⎋⎋
    leaves nothing; Write's sheet; the nested sheet. VX-183: Add, Delete, Restore, Delete forever's confirm, Cancel. Row 1
    in the second voice), on the same note.
  - Then the walk note to the Trash, quit OUR instance by identity, `pgrep` again; the dev store Standard, unlocked, the
    voice as found (Study); release the claim.

#### THE STAGE WINDOW — RUN 2026-10-14 05:27:17 → 05:38:17 (claim `vx282-u6`, handed from `coord-for-vx282`; RELEASED)

`git pull --ff-only` first (the branch already carried main's merge `ece30a41` and the QUESTIONS renumber — this unit's
entry is **#224**); nothing rebuilt (the coordinator's word). `guard.sh --author` OK before every leg; no Variorum
instance (`pgrep -lx Variorum`) and no booted simulator at the start or at the end. Logs:
`notes/plans/vx282-screens/u6/logs/`; captures: `notes/plans/vx282-screens/u6/walk/`.

- **W1 — red on old** (`w1-red-on-old.log`, `vx282-u6-old-products`): "Test run with **3 tests in 1 suite failed** …
  with **1 issue**" — **exactly as predicted**: `theShellOpeningOnTheBookcasePutsTheCaretInItsQuickEntry` at
  `QuickEntryLaunchFocusTests.swift:198`, *"the keyboard is on `LaunchFocusWindow`"* (its premise cells — the keyboard
  free before the opening, the box in its window — green); both guards green. So THIS HOST reproduces the launch's
  order with the suspend-only settle; the pin is not vacuous.
- **W2 — the fixed batch, `-derivedDataPath DerivedData/vx282-u4`:** g1 (`w2-g1.log`) "**67 tests in 20 suites
  passed**"; g2 (`w2-g2.log`) "**29 tests in 8 suites passed**"; g3 (`w2-g3.log`) "**52 tests in 15 suites passed**" —
  **148 tests / 43 suites, green**; every suite's ✔ line read (all four VX-326 suites, U4's five capture suites, the
  tour suites, every shell-mounting and launch/restore suite named in the plan), 0 skipped.
- **W3 — the walk, the DEV store (Standard, unlocked; found in STUDY, appearance `system`, `variorum.tour.offer` =
  `completed`; no What's New sheet — both builds 0.9.5 as the dev defaults' last version).** One instance at a time,
  each launched by `open -n` and quit by identity (`tell application id "io.lduarte.Variorum.debug" to quit`, `pgrep`
  empty after each). The caret's truth read by AX (`AXFocusedUIElement` + the focused window's size); keys by `keys.sh`,
  clicks by `click.sh`, ≥ 2 s apart; captures by region.
  - **A0 — the OLD build at launch** (pid 6398): AX `AXWindow` — **the keyboard on the window**, the bar unfocused
    (`A0-old-launch.png`) — O-U4-3 again, the defect.
  - **A — the fixed build at launch, Study** (pid 6505): AX **`AXTextArea` "text entry area", value empty, in the main
    window** — the caret blinks at the start of the quick entry (`A1-launch.png`, `A1b-launch-bar-zoom.png`); `z` typed
    → the box reads `z`, the title chip offers *name it "z"?* (`A2-typed.png`); ⌫ → empty again (`A3-deleted.png`),
    nothing filed. **HOLDS.**
  - **A' — the second voice, Terminal** (⌘K "Use Terminal Voice", quit, relaunch — pid 6800): AX `AXTextArea` at launch;
    the caret in the bar and **no block cursor beside it** in two captures 0.6 s apart — one cursor (17y (m))
    (`A4-launch-terminal.png`, `A4b`/`A4c-terminal-bar-zoom*.png`). **HOLDS.** (Seen on the way: after the palette
    sheet closed, AX read the bar again — AppKit restores a window's first responder after a sheet.)
  - **B — a restored note window: NOT REACHABLE on this Mac.** `o museu` opened by the Open strip's "Open in New Window"
    (800×720), the caret put in its editor by a click (AX `AXTextArea` in the 800×720 window, `B0-note-window-before-quit.png`),
    the app quit with that window key, relaunched (pid 7202): **macOS did not restore the note window** (one window,
    1380×900); the main window opened on the Bookcase with the caret in the bar (AX `AXTextArea` in the 1380×900
    window, `B1-relaunch-no-note-window.png`). **In its place — a NEW window (File ▸ New Window), the other "opening"
    P-U6-2 names:** a second 1240×840 window came up key with **its own quick entry holding the caret** (AX `AXTextArea`
    in the 1240×840 window, `B2-new-window.png`); closed by its own close button, the main window's bar holding the
    caret again after. **HOLDS** for what could be staged; P-U6-1's other-window case stays unwalked (record-only).
  - **C — the tour, no steal:** caret in the bar (AX) → Help ▸ Take the Tour (menu, by AX name) → step 1: AX
    **`AXWindow`** — the tour's release (W-U1a-1), the Terminal block cursor drawn as its sign (`C1-tour-step1.png`) →
    the card's "next" → step 2: AX `AXWindow` (`C2-tour-step2.png`) → "end tour": AX `AXWindow`, the bar never took the
    caret back (`C3-tour-ended.png`); `variorum.tour.offer` still `completed`. **HOLDS.**
  - **D — the scope line, as today:** ⌘K "Go to Library" ⏎ → AX `AXWindow` (`D0-library.png`) → ⌘K "Go to Bookcase" ⏎ →
    AX **`AXWindow`**, the Terminal block cursor drawn — **the bar NOT focused on a navigation back**
    (`D1-navigate-back.png`). Exactly today's behaviour (the brief's line) and **O-U6-1 seen live.**
  - **Cleanup / posture as left:** the voice restored to **Study** by ⌘K "Use Study Voice" (`Z1-study-restored.png`);
    appearance `system` (never touched); `variorum.tour.offer` = **`completed`**; the main window on the **Bookcase**;
    **nothing filed** (the one `z` deleted, no ⏎ in any box; the Bookcase's counts as found); the note window and the
    new window closed by their own buttons; no lock screen met (Standard, unlocked); no system dialog; our instance
    quit by identity, `pgrep -lx Variorum` empty, 0 booted simulators; **the claim RELEASED at 05:38:17** (11 of 55
    minutes).

#### Dispositions

| Row | Disposition |
|---|---|
| VX-326 — the Bookcase's quick entry isn't focused at launch | **FIXED** (`3cf0079b`) — red on old in the harness (W1, the launch pin's last cell) and live on the old build (A0); green fixed (W2, 148/43) and in use fixed in both voices (A, A'), a typed letter landing in the bar. |
| Never steals — a field, a sheet | **HOLDS** — the guards green on both sides (W1/W2); live, the tour's release is never undone (C). |
| The scope — later Bookcase mounts as today | **HOLDS as briefed** — W2's scope pin; live (D). The gap itself is **O-U6-1** (a ticket, the orchestrator's). |
| A restored note window keeps its keyboard | **NOT WALKABLE on this Mac** (the window is not restored); the rule never consults other windows (P-U6-1, QUESTIONS #224). |
| U4's contract (served once, re-take only what it held) | **HOLDS** — U4's five suites green in g1. |

#### THE u5b WINDOW — RUN 2026-10-14 05:40:11 → 05:57:46 (claim `vx282-u5b`, chained from `coord-for-vx282`; RELEASED)

`git pull --ff-only` (at `0fdc2077`; nothing rebuilt — the products built at `c2b3ba72`); `guard.sh --author` OK; no
Variorum instance (`pgrep -lx Variorum`, the `MacOS/Variorum$` anchor); no booted simulator; the dev store as the
coordinator found it at 05:39 (Standard, unlocked, Study). Logs: `notes/plans/vx282-screens/u5/logs/`; captures
`notes/plans/vx282-screens/u5/w3-*.jpg` (downsized).

**W2 — the fixed batch (`DerivedData/vx282-u5`), `CommentPanelReleaseTests` excluded:**
- **g1** (`u5b-w2-g1.log`, 05:40:17–05:41:28): "**110 tests in 12 suites failed … 4 issues**" — the nested path
  `CommentPanelHostSuites/CommentPanelHostLeavingTests` selected exactly the VX-257 suite (no release-suite line).
  GREEN: `CommentPanelDoorsTests` (VX-183, every cell), the registry walk (its new line), `CommentPanelLeaveTests` (VX-257,
  all six — the three that were red on old now green), `CommentPanelParkTests`, the panel's model/composition/keys suites,
  `CommentsAndReorderTests`, `TrashSurfaceTests`, `NoteVersionsPaneTests`; and VX-257's POPOVER cell
  `aClickAwayFromThePopoverKeepsTheDraftForTheReopen` (red on old at W1 → **green**). **RED (4 issues): VX-257's two SHEET
  cells** — `aSheetsClosingKeepsTheDraftForTheReopen` and `theTakePanelsNestedSheetKeepsTheDraftForTheReopen`, the reopened
  composer `""` with the caret `{0, 0}` (2 each). Their dismissal is the BINDING road, whose leaving body runs only from
  the surface's `.onDisappear`; W1 measured that in the runner a dismissed sheet's panel is never let go (the sheet
  guards' reds), so `.onDisappear` never fires there and nothing parks. In the app the same sheets ARE torn down (the heap
  below) and the sheet roads hold in use (rows 3–4) — the runner-artefact class, not a product defect (the binding road
  itself was not walked in the app; Close and ⎋⎋ were).
- **g2** (`u5b-w2-g2.log`, 05:41:55–05:42:44): "**76 tests in 11 suites passed**" — VX-179's panel, card, gutter and decor
  suites incl. `CommentPanelFixLeg2Tests` and `CommentTextAreaMountedTests`. EXIT 0.
- **g3** (`u5b-w2-g3.log`, 05:42:49–05:43:34): "**23 tests in 2 suites passed**" — the two take-panel suites. EXIT 0.

**W3 — the walk, the fixed Debug app (pid 10736) on the dev store, Study as found.** Host grants AX ✓ / screen ✓; no
What's New sheet; "Sync off (dev store)". Staged `{t:"VX-229 walk"}alpha` ⇧⏎ `beta` through the shelf's quick entry →
opened in Write (`w3-00`).

**Row 6 — THE VX-229 DECIDER, `heap 10736` (our pid; no prompt).** Read by class: `CommentsPanelModel`,
`CommentTextAreaView`, and the panel's own GRDB observer `ValueConcurrentObserver<…Fetch<Variorum.CommentsPanelModel.
Snapshot>>` (heap prints app classes UNQUALIFIED — the first helper matched the qualified name and read 0 for the model
and the areas; corrected from the saved heaps, both readings kept in `u5b-heap-summary.txt`):

| step | what had happened | model · observer · areas |
|---|---|---|
| a0 | the note staged, no comments panel ever opened | **0 · 0 · 0** |
| a1 | one Write sheet (`first` filed, Close) | **0 · 0 · 0** |
| b | + three margin-note POPOVER open → click-away cycles (Takes) | **0 · 0 · 0** |
| control | a popover OPEN | 1 · 1 · 2 |
| control | …after its click-away | **0 · 0 · 0** |
| c-open | the third Write ⌘⇧' SHEET open | 1 · 1 · 2 |
| c | + three Write sheet open → Close cycles | **0 · 0 · 0** |
| d-open | the third NESTED sheet open (over `beta`'s take panel) | 1 · 1 · 1 |
| d | + three nested-sheet open → Close cycles | **0 · 0 · 0** |
| d2 | + the take panel closed (⌘⇧T) | **0 · 0 · 0** |
| end | after every row of the walk (13 more openings, both voices) | **0 · 0 · 0** |

**VERDICT: VX-229 is HOLLOW IN USE — runner-only.** In the running app a dismissed host's panel is released every time,
popover, sheet and nested sheet alike: its model, its store observation and its views, within ~2 s of the close; the open
controls prove the count is not trivially zero. W1's red (3 · 3 · 3) and the sheet guards' reds are the runner's own
retention (the long-lived main-thread autorelease pool under async test bodies — TEXTKIT2_NOTES §3), which also explains
why the two VX-257 sheet cells cannot see a `.onDisappear` there. **The functional symptom** (a write re-read by stale
panels) has no honest in-app signal — the panel's re-read leaves no visible or logged trace — and with zero panel
observers alive after every close there is nothing that could re-read. **VX-229: DISMISSED AS HOLLOW** (the fix stays out,
`7d798f82`), pending the coordinator's ruling. **Owed (not started — the coordinator's word: no fix leg before its
ruling):** reshape `CommentPanelReleaseTests` to the drained-pool shape, and VX-257's two sheet cells to a road the runner
delivers, so no red pin stays in the suite.

**The VX-257 / VX-183 rows — every row HOLDS:**
1. **The popover (her ruling's road):** Takes, `alpha`'s margin note, `half a thou` typed → click away → reopen:
   **`half a thou` back, the caret after it, no refusal line**, Add live (`w3-r1`). Terminal voice (row 7): `terminal half` →
   click away → reopen: back, caret after it (`w3-r7`).
2. **⎋ clears:** ⎋ → the box empties, the popover stays (Add faded) → ⎋ → it closes → reopen: **empty** (`w3-r2`).
3. **Write's sheet:** `sheet draft` → Close → ⌘⇧': **back, caret after it** (`w3-r3-sheet-draft-back`); ⎋ ⎋ → ⌘⇧': **empty**.
4. **The take panel's nested sheet:** `beta`'s panel (⑂2) → ⌘⇧' → `nested draft` → Close → ⌘⇧': **back** (`w3-r3-esc…_r4…`).
5. **The doors (VX-183), rendered from the rule:** **Add** filed `second` (the row, the gutter card); `first`'s **Delete** →
   "Comment deleted — it's under Deleted below, restorable." and "▸ Deleted (1)"; the fold open → struck `first`, "Deleted
   <date>", **Restore** (primary) and **Delete forever…** (quiet); Restore → "Comment restored.", both rows live; Delete
   again → **Delete forever…** → the confirm "Delete this comment forever? / It leaves every device, and there's no
   putting it back. / Delete forever · Cancel" → **Cancel** → still in the fold. Extra: `second` edited → "Unsaved · ⌘⏎ ·
   **Save** · Revert · Delete" in the shipped order → **Revert** → back, Delete alone (`w3-r5-*`).
7. **The second voice:** ⌘K "Use Terminal Voice" → row 1 held (above) → ⎋⎋ (cleared, nothing kept) → ⌘K "Use Study
   Voice" — **Study restored** (`w3-r8`).
- **Residue:** the note "VX-229 walk" moved to the Trash by note ▾ › Delete Note… › Delete ("Note moved to the Trash — 30
  days to put it back.", `w3-r9`) — with it the comments `first` (deleted, in its fold) and `second`, and `beta`'s second
  take. Every kept draft was ⎋-cleared before its panel closed, so the park holds nothing.
- **Posture as left:** our instance quit by identity (`tell application id "io.lduarte.Variorum.debug" to quit`;
  `pgrep -lx Variorum` and the anchor → none); no simulator; the dev store Standard (custody untouched), unlocked (no lock
  screen met), **voice Study** (as found), appearance untouched. **Claim `vx282-u5b` RELEASED 05:57:46** (status FREE).

#### VX-229 — FINAL DISPOSITION (the coordinator's ruling, 2026-10-14 ~06:00)

**DISMISSED AS HOLLOW IN USE.** The u5b heap table is decisive: zero models and zero observers alive after each close on
all three roads (popover, Write's sheet, the take panel's nested sheet), with open controls of 1 · 1 · 1–2. W1's red was
the runner's own retention (the long-lived main-thread autorelease pool under async test bodies — TEXTKIT2_NOTES §3's
class). The fix (`ee86dd8c`) stays OUT (`7d798f82`). **O-U5-1 is an FYI for the handoff, no ticket:** VX-179's
stale-monitor pin (`aDismissedPopoversPanelStopsListening`) and its `willClose` release rest on the same offscreen shape.

#### u5c — the three reshaped cells (headless; the coordinator's narrow leg) — `eaf42b27`

- **`CommentPanelReleaseTests` — now a GUARD of the app's real behaviour, not a red-on-old pin** (its header and the
  suite title say so). The rig's turns are DRAINED (`drainedSlice()`: the queued events and a 10 ms run-loop slice inside
  one `autoreleasepool`; no `Task.sleep`; a `Task.yield` between turns), every window lookup pooled, no window ever held;
  each step's census printed (`VX-229 guard — …: models alive N, observing M`). Expected GREEN on both products (the
  lifecycle code is the same on both — VX-229's fix is out).
- **VX-257's two SHEET cells — still REAL pins of the sheet road, red on old.** After the binding dismissal,
  `leaveTheDismissedSheet` waits (drained) for the panel to be let go — the sheet's own `.onDisappear` ran — and, where
  the runner still keeps the dismissed panel alive after the wait, runs that panel's leaving body EXACTLY as the sheet's
  `.onDisappear` calls it (`commitDirtyEdits()` → `leave()`), printing which road ran (`VX-257 the sheet: …`). Old
  `leave()` drops the draft on either road ⇒ red on old; the fixed `leave()` parks it ⇒ green.
- **What could not be settled headlessly (said plainly):** an ASYNC offscreen probe (the cycle as a `@MainActor` task under
  `NSApp.run()`, the runner's shape) does NOT reproduce the runner's retention — both the old and the drained turns let the
  panel go there (`asyncpanel.swift`) — so whether the drained turns make the RUNNER release is u5c's to show. The guard's
  printed census will say it either way; the VX-257 sheet cells are robust to it by construction.

**Named revert for the OLD products (before it starts):** the files that post-date `7d798f82` in the app and its test
bundle go back to it for ONE build — `CommentsPanel.swift`, `CommentTextArea.swift`, `Registry/Capability.swift`,
`Registry/CapabilityRegistry.swift`, `VariorumTests/CapabilityRegistryTests.swift`, `Sources/VariorumCore/Queries/
RestoreCost.swift` (`git checkout 7d798f82 --`), and `VariorumTests/CommentPanelDoorsTests.swift` set aside to
`scratchpad/vx282-u5/`; the reshaped `CommentPanelHostLifecycleTests.swift` stays (the pins as now). Restore by
`git checkout HEAD -- <each>` (the Doors file included); `git status` clean.

**The products (rebuilt into the existing trees; no new tree):** OLD — the named revert above DONE and RESTORED (`git
checkout HEAD --` of all seven, `git status` clean, `git diff` empty); built → `DerivedData/vx282-u5-old-products` replaced
(its dylib carries neither VX-257's keeping nor VX-183's rule — `nm` 0; the reshaped pins in its test bundle). FIXED —
rebuilt at the tip into `DerivedData/vx282-u5` (TEST BUILD SUCCEEDED; `nm` 63). Disk 29 GiB free.

#### THE u5c WINDOW PLAN (≈8 min; on the orchestrator's claim line; `guard.sh --author` first; no app launch, no walk)

From `App/Variorum/`, logs to `notes/plans/vx282-screens/u5/logs/`:
- **W1c — the reshaped cells on OLD (≈2 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-u5-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
  -only-testing:VariorumTests/CommentPanelHostSuites` → `u5c-w1-old.log`. EXPECTED: `CommentPanelReleaseTests` (the GUARD)
  **green** — its printed census `models alive 0, observing 0` after each dismissal; `CommentPanelHostLeavingTests` **red
  in all three cells** (the popover, the sheet, the nested sheet — the text and the caret each: 6 issues in 3 cases), the
  sheet cells printing which leaving road ran.
- **W2c — the fixed products, g1 re-run with the whole host parent (≈4 min):** `-derivedDataPath DerivedData/vx282-u5`
  with `-only-testing:VariorumTests/` × `CommentPanelHostSuites` `CommentPanelLeaveTests` `CommentPanelDoorsTests`
  `CommentPanelParkTests` `CommentsPanelModelEditorTests` `CommentCompositionTests` `CommentPanelKeysTests`
  `CommentsAndReorderTests` `CapabilityRegistryTests` `TrashSurfaceTests` `NoteVersionsPaneTests` → `u5c-w2-g1.log`.
  EXPECTED: all green (u5b's 110 + `CommentPanelReleaseTests`' 3 = 113 tests / 13 suites).
- Read the census lines (`grep "VX-229 guard\|VX-257 the"`) — they are the evidence of which road the runner took. If the
  guard is red on either side, its census says whether the runner still retains dismissed panels under the drained
  shape; report it rather than re-run.

#### THE u5c WINDOW — RUN 2026-10-14 06:12:37 → 06:13:57 (claim `vx282-u5c`, chained from `coord-for-vx282`; RELEASED) — STOPPED AFTER W1c

`git pull --ff-only` first (nothing rebuilt); `guard.sh --author` OK; `pgrep -lx Variorum` — none; no app launched.

- **W1c — the reshaped cells on the OLD products** (`u5c-w1-old.log`, 06:12:42–06:13:49): "**6 tests in 3 suites failed …
  15 issues**", EXIT 65.
  - **VX-257 — RED ON OLD AS DESIGNED, all three host cells** (6 issues in 3 cases: the reopened composer's text and caret,
    `:538`/`:539`). The two SHEET cells took the fallback road: *"VX-257 the sheet: the runner kept 1 dismissed panel(s)
    alive — the cell ran the leaving body as the sheet's .onDisappear calls it"* and the same for *the nested sheet* — the
    old `leave()` dropped the draft, as designed.
  - **THE VX-229 GUARD IS RED ON OLD under the drained shape (9 issues)** — the runner still keeps EVERY dismissed panel
    alive AND observing, accumulating one per opening. The census, verbatim:
    ```
    VX-229 guard — popover, after dismissal 1: models alive 1, observing 1
    VX-229 guard — popover, after dismissal 2: models alive 2, observing 2
    VX-229 guard — popover, after dismissal 3: models alive 3, observing 3
    VX-229 guard — popover, after the wait: models alive 3, observing 3
    VX-229 guard — sheet, after dismissal 1: models alive 1, observing 1
    VX-229 guard — sheet, after dismissal 2: models alive 2, observing 2
    VX-229 guard — sheet, after dismissal 3: models alive 3, observing 3
    VX-229 guard — nested sheet, after dismissal 1: models alive 1, observing 1
    VX-229 guard — nested sheet, after dismissal 2: models alive 2, observing 2
    VX-229 guard — nested sheet, after dismissal 3: models alive 3, observing 3
    ```
    (popover `:439` observing, `:441` alive, `:449` re-reads; the sheet `:472` ×3; the nested sheet `:496` ×3.) The same
    lifecycle code is on the fixed products (VX-229's fix is out), so the guard would read the same there.
  - **What it means:** explicit per-turn `autoreleasepool`s do NOT make the runner let go — so the runner's retention is
    not (only) the autorelease pool this reshape drains; something in the test host keeps a dismissed host's content alive
    and its `.task` running for the whole test, where the app (the u5b heap) releases within ~2 s. The VX-229 cells cannot
    be an honest green guard in this runner as built; VX-257's sheet cells are robust to it (they ran the fallback road).
- **STOPPED** at the coordinator's rule (a red guard ⇒ record, release, report; no fix in the window): **W2c NOT run.**
  **Claim `vx282-u5c` RELEASED 06:13:57** (status FREE). No app launched; the dev store untouched.

#### u5d — the VX-229 cells as KNOWN ISSUES (the coordinator's ruling after u5c) — headless

**The ruling:** wrap the VX-229 cells as Swift Testing known issues — the repo's precedent for a measured harness/platform
fact (`IndexTierMetricsTests`' and `TakesFindBoardTests`' non-intermittent `withKnownIssue` cases). Built: in
`CommentPanelReleaseTests` every alive/observing expectation — the popover cell's alive and observing checks and its
re-read check, and each sheet's and nested sheet's per-opening alive check — sits inside `withKnownIssue("the test runner
keeps a dismissed popover's/sheet's panel alive for the test's lifetime; the running app releases it within ~2 s (VX-282
u5b heap: 0·0·0 after every close)", isIntermittent: false)`. The cells keep running and printing their census; the
premises (a new window, a mounted observing panel, each close) stay plain. **The suite stays green while the runner
retains, and each cell FAILS LOUDLY the day the runner starts releasing — the signal to turn it back into a plain guard.**
The file's header says VX-229 was dismissed as hollow in use (the heap table above is the evidence) and that **the runner's
retention cause is UNTRACED** (not the autorelease pool the drained rig drains — u5c). **No ticket for the runner fact; it is
recorded here.** VX-257's two sheet cells unchanged (their fallback road held at u5c). Rebuilt ONLY the fixed tree
(`DerivedData/vx282-u5` — TEST BUILD SUCCEEDED; the old products not needed).

#### THE u5d WINDOW PLAN (≈5 min; on the orchestrator's claim line; `guard.sh --author` first; no app launch)

**W2c — g1 on the fixed products** (`-derivedDataPath DerivedData/vx282-u5`), `-only-testing:VariorumTests/` ×
`CommentPanelHostSuites` `CommentPanelLeaveTests` `CommentPanelDoorsTests` `CommentPanelParkTests`
`CommentsPanelModelEditorTests` `CommentCompositionTests` `CommentPanelKeysTests` `CommentsAndReorderTests`
`CapabilityRegistryTests` `TrashSurfaceTests` `NoteVersionsPaneTests` → `u5d-w2-g1.log`. EXPECTED: all green, 113 tests /
13 suites — the VX-229 cells passing WITH their known issues recorded (the log's known-issue lines; the census still
printed), VX-257's three host cells green (the sheet cells printing their road). A VX-229 cell failing with "known issue was
not recorded" means the runner RELEASED — record it (good news: un-wrap at the next touch).

#### THE u5d WINDOW — RUN 2026-10-14 06:17:54 → 06:19:43 (claim `vx282-u5d`, chained from `coord-for-vx282`; RELEASED) — U5's last leg

`git pull --ff-only` (nothing rebuilt — the fixed products built at `c46f999d`); `guard.sh --author` OK; `pgrep -lx
Variorum` none; no app launched.
- **W2c — g1 on the FIXED products** (`u5d-w2-g1.log`, 06:17:59–06:19:37): "**113 tests in 13 suites passed … with 9 known
  issues**", `** TEST EXECUTE SUCCEEDED **`, zero ✘. Every suite ✔ (VX-183's doors, the registry walk, VX-257's mounted and
  model suites, the park, the panel model/composition/keys, reorder, Trash, Versions); the VX-229 suite and its parent
  "passed with 9 known issues" — exactly the wrapped expectations: the popover cell `:445` (observing) `:447` (alive) `:457`
  (re-reads), the sheet cell `:483` ×3, the nested sheet `:509` ×3. The census (the runner's fact, unchanged): *popover after
  dismissal 1/2/3: models alive 1/2/3, observing 1/2/3; after the wait: 3, 3; sheet 1/2/3: 1/2/3 alive and observing;
  nested sheet 1/2/3: the same.* VX-257's sheet cells: *"the runner kept 1 dismissed panel(s) alive — the cell ran the
  leaving body as the sheet's .onDisappear calls it"* (both) — and passed.
- **Claim `vx282-u5d` RELEASED 06:19:43** (status FREE). No instance; the dev store untouched.

#### U5 — DISPOSITIONS (final)

| member | disposition | evidence |
|---|---|---|
| VX-229 | **DISMISSED AS HOLLOW IN USE** (the coordinator's ruling) — the fix `ee86dd8c` reverted `7d798f82` | the u5b heap decider (0 · 0 · 0 after every close, all three roads; open controls 1 · 1 · 1–2); the runner's retention a recorded known issue (`c46f999d`), cause untraced; O-U5-1 an FYI |
| VX-257 | **FIXED** `1ca8fe72` (pins `7650b6ce` + `075473c2`, reshaped `dab712d8`/`eaf42b27`) | red on old: W1 10 issues / 6 cases, u5c W1c 6 / 3; green fixed: u5d 113/13; the walk (u5b rows 1–4 + 7, both voices); PROVISIONALs P-U5-1…4 → QUESTIONS **#223** |
| VX-183 | **FIXED** (declared) `a765683c` — debt, no red-on-old owed | `CommentPanelDoorsTests` + the walk line green (u5b g1, u5d); the walk's row 5 (Add, Delete, Restore, Delete forever's confirm + Cancel, Save/Revert) |
| VX-182 | **FIXED** `fd4c260c` (pins `f38fb93c`) | headless: red on old 1 issue, green 8/1; R-182 discriminating revert ran and restored; whole core 2,801/320 |

## Ladder

### ROUND 1 — `opus-reviewer` at max (her cast word), REVIEW_PROMPT verbatim, PHASE=VX-282 (plus one location/stage line), reviewed tip `3bfa9b2a`; read-only

**Tally: 0 BLOCKER · 0 MAJOR · 6 MINOR (one SPECULATIVE) · 4 NIT.** The reviewer's own scope note, verbatim in substance:
the diff is inside Fable's mandatory scope (`BlockRangeIndex`, `PaneSurface`'s coordinator, `SeamCarvePlan`,
`runEmptyBlockDeletion`, `storageDidEdit`, the selection delegate; VX-296 writes attributes on live storage on both
platforms) — this Opus round does not discharge it. **Agreed: round 2 is the run's one Fable cold review.**

**The findings (condensed from the reviewer's text; mechanisms as it traced them):**
- **R1-1 [MINOR]** `PaneSurface.swift:1427-1429/:1652/:1527/:1756`, `MarkdownFaceCore.swift:194` — a pane going READ
  while its caret sits at a rescue point: `paintFind(live:false)` paints the match, then `noteLiveness(false)`'s VX-296
  settle restyles the honoured line caret-blind and the face's clear loop removes `.backgroundColor` from every
  face-styled run (the find paint included); nothing calls `findPaintWasReset()`, so the change-gated repaint writes
  nothing — the match stays unpainted. A regression. Pin: `PaneFindFaceTests`' rig, `*Hyde *`, match {1,4}, caret 6,
  flip read → `.backgroundColor` at 1 == `matchTint`. Fix: when the settle restyled, `findPaintWasReset()`.
- **R1-2 [MINOR]** `EditorViewModel.swift:3511-3515` (vs `:1222`, `:2321`, `:3688-3692`) — a settle in Write can
  re-wrap a line (Study's proportional italics) with no character edit, but `overlayGeometryGeneration` is not bumped,
  so `overlayLayoutDidSettle` returns at its guard: badges, callout frames, seams, the editing indicator and gutter
  cards keep stale positions until the next scroll/pointer/edit. Fix: bump the generation + `overlayLayoutDidSettle()`
  when the settle restyled (the refont road's shape). Pin: Study metrics, a paragraph whose italic toggle changes its
  line count, a fanned block below; after an arrow move off the rescue point + a display pass the badge frame matches.
- **R1-3 [MINOR, SPECULATIVE]** `MobileEditorViewModel.swift:2074-2078`, `MarkdownFaceCore.swift:255` — the phone's
  W2b guard reads `editedMask`, empty between `beginEditing` and the first change inside a transaction; if UIKit
  reports the selection inside `coordinateEditing` BEFORE the character change (autocorrect, predictive/spelling
  Replace, dictation — the iOS ordering is inferred, only `insertText` observed) at a rescue point, the settle writes
  inside the transaction → the W2b class. Fix: also skip while `pendingEdit != nil`. Pin: caret at `*hello |*` (7),
  `textView.replace(<"hello">, withText: "Hello")` — red ⇒ real; green ⇒ hollow.
- **R1-4 [MINOR]** `Features/Editor/CommentsPanel.swift` — consumed by Editor AND Takes (now four hosts incl. U3's),
  edited heavily at this touch, still in `Features/Editor/`: CLAUDE.md's shared-home rule says move it at the next
  touch (with `CommentTextArea.swift`, its only consumer) to `Core/Views/`.
- **R1-5 [MINOR]** `MarkdownSyntax.swift:204/:648`, QUESTIONS #220 — her approved fix (a)'s ticket wording said "the
  grammar … untouched"; the build put the caret rule inside the grammar module (`spans(in:caret:)` + `closerFlanks`),
  behaviour-faithful (nil caret byte-identical, exhaustively pinned) but undisclosed in her bundle. Fix: one line in
  #220 / the handoff.
- **R1-6 [MINOR]** the record's observations — deferred work owed tickets: O-U6-1, O-U5-2, the VM ticket for VX-257's
  phone face, O-2 (⌃⌘↑/↓ move Write's caret beneath the take panel; the menu items stay live), U1's same-turn
  double-⌫ refusal toast; and O-4's premise looks contradicted by `PaneMount.kind(…windowIsKey:)` (the live surface
  mounts only in the key window) — verify before ticketing or correct the record.
- **R1-7 [NIT]** `EditorViewModel.swift:3511-3515`, `MobileEditorViewModel.swift:2074-2078` (vs `PaneSurface.swift:2009-2015`)
  — Write and the phone honour a caret in a NON-editable editor (a sealed note's Write is selectable): a click at a
  rescue point turns the italic on with no drawn caret. Fix: gate on `isEditable` as the pane does. Pin: sealed post,
  `setSelectedRange` at the rescue point → no face styling.
- **R1-8 [NIT]** `CommentPanelHostLifecycleTests.swift` — the VX-229 non-intermittent known issues were measured only
  in 13-suite batches; the closeout's whole-target run may release and fail them. Watch there.
- **R1-9 [NIT]** `ReturnKeyTraceTests.swift:847-918` — R2-1's two burst pins are no longer proven against R2-1's
  (the drain rule's) revert. Fix: one test-only run of both against that revert, or record which pin carries R2-1.
- **R1-10 [NIT]** `CommentTextArea.swift:447-457` + the U5 record — the record's `adoptText` caret rule is inaccurate
  (any adopt into an EMPTY area now lands the caret at the end, mount fills included). Correct the record line.

**Clean bill (the reviewer's, condensed):** VX-290's landing for all six shapes, #33(d) tie-break in one place, the
tail never the survivor, Delete Block/archive untouched, the stashed fast press, P1 · VX-296's nil-caret readers
unchanged, the gate exhaustively sound, attributes-only settles never re-entering `storageDidEdit`, P1 · VX-154's
exhaustive `handleRouted`, named targets never falling back, `ringMayStand` on both ring roads · VX-193/112's own
UndoManager, observers removed at dismantle, re-take only when the window holds the keyboard · VX-326 decided once on
the box's own window · VX-257/183/182's idempotent `leave()`, refused drafts stay refused, the doors byte-identical, the
purge fence stamp-aware and index-backed · zero `Sync/`/custody/keychain/schema · no trailers · its own headless core
run 2,809/322 · MCP 212/41 · workbook 40/6 green · 21 stage logs spot-checked against the record.

**DISPOSITIONS (the orchestrator — same-model round: arbitrated against the spec; her overnight mandate stands):**
- R1-1 **AGREED** — fix + the proposed pin, red-on-old.
- R1-2 **AGREED** — fix (the refont road's shape) + a pin if one can be built honestly (Study metrics); if the test
  host cannot reproduce the re-wrap, say so and keep the fix with its mechanism recorded.
- R1-3 **AGREED, PIN FIRST** — the proposed simulator pin; red ⇒ the `pendingEdit` guard; green ⇒ recorded hollow,
  no fix.
- R1-4 **AGREED** — move `CommentsPanel.swift` + `CommentTextArea.swift` to `Core/Views/` (CLAUDE.md's rule binds at
  this touch); no behaviour change.
- R1-5 **AGREED** — the disclosure line in #220 and the handoff.
- R1-6 **AGREED** — O-U6-1 = **VX-332**, O-U5-2 = **VX-331**, the phone face = **VM-18** (minted before this round);
  O-2 = **VX-334**, the double-⌫ toast = **VX-335** (minted at this round); O-4 re-verified by the fixer — corrected in the record
  if its premise is false, ticketed if it stands.
- R1-7 **AGREED** — gate both settles on `isEditable` + the sealed-post pin.
- R1-8 **AGREED (watch)** — the closeout's whole-target run reads those cells; if they fail, mark intermittent.
- R1-9 **AGREED** — one test-only run of both burst pins against the drain-rule revert in the fix window.
- R1-10 **AGREED** — the record line corrected.

### ROUND 1 — FIX LEG (an `opus-implementer` session, Opus 5.5 xhigh, 2026-10-14)

**NOT DONE BY THIS LEG (first line):** R1-8 (the closeout's whole-target run watches it) and the handoff are not this
leg's. No walk (no fix changes anything she sees except through the pins' roads). Every row below is VERIFIED in the
r1fix window (its record at the end of this subsection).

**LIVE STATUS (this leg): DONE (2026-10-14 08:00).** The window ran 07:53:31–08:00:50 (claim `vx282-r1fix`, RELEASED);
no claim held, no revert in flight (`git diff` empty after every named revert, each verified), the simulators shut down
(0 booted), no Variorum instance. The side branch `vx-282-r1-3-guard` is DELETED (GitHub and local) — R1-3 is hollow.

| Finding | Disposition |
|---|---|
| R1-1 find paint × the read-going settle | **FIXED** `833b1ba7` — pin `49ebe4c4`: W1 red on old (2 issues: the colour, the runs), W2 g1 green |
| R1-2 Write's overlays after a settle re-wrap | **FIXED** `9f9980cb` (a deliberate refinement of the agreed shape — below, for the Fable round) — pin `174b64f3`/`9f9980cb`: W1 red on old (1 issue: badge 318 vs block 340 — the block moved 22 pt, one line), W2 g1 green |
| R1-3 the phone's guard window (PIN FIRST) | **DISMISSED AS HOLLOW** — the pin `706008eb` green on the current product (W2b) and on old (W1c), all three replacements; no fix; the guard branch deleted; the pin stays as a guard |
| R1-4 the comments panel to `Core/Views/` | **DONE** `b7fece88` — W2 g3a + g3b green (73/10 with the 9 VX-229 known issues; 67/10) |
| R1-5 #220's disclosure line | **DONE** `f411c213` |
| R1-6 O-4 re-verified | **DONE** `f411c213` — premise FALSE, U3's O-4 WITHDRAWN in the U3 record; no ticket |
| R1-7 a caret in a non-editable editor | **FIXED** `26c2e448` — pins `ebd327d0`: W1 red on old (Mac, 2 issues: the seal arrival AND the click), W1c red on old (phone, 1), W2 g1 + W2b green |
| R1-9 the burst pins against R2-1's revert | **DONE** — W1b: all THREE burst pins red under R2-1's named revert, nothing else; each carries R2-1 (the test's doc and the U1 record say so) |
| R1-10 the U5 record's adopt line | **DONE** `f411c213` |

#### R1-1 — the find paint the read-going settle erased (FIXED; red on old and green — the window below)

- **Mechanism, confirmed by re-reading the road:** `PaneSurfaceView.updateNSView` paints FIRST
  (`paintFind(live: false)`, `PaneSurface.swift:1427` — it writes `.backgroundColor` over the matches and sets
  `paintedFind = wanted`), then sets `isEditable = false`, then `noteLiveness(false)` → VX-296's settle
  (`:1652`) re-reads the honoured line caret-blind through `MarkdownFaceCore.restyle`, whose clear loop removes
  `.backgroundColor` over every face run it re-derives (`MarkdownFaceCore.swift:188-203` — the code chip's ownership rule,
  13k K10), the match's paint inside the italic span included. The record still read "painted", so the update's closing
  `paintFind(live: false)` (`:1527`) found `wanted == paintedFind` and wrote nothing. A regression of U2's (pre-VX-296 the
  liveness note never restyled).
- **The diff (`833b1ba7`, one file):** the coordinator's private `settleMarkdownCaret(in:)` calls `findPaintWasReset()`
  when the settle restyled — the rule every other attribute-rewriting road in the coordinator already keeps (the face
  change, the base-attribute refresh, a fresh string). Placed in the one settle helper, so the selection-change and
  `textDidChange` settles carry it too (on a live pane `paintedFind` is already nil — a no-op there).
- **The pin:** `PaneFindFaceTests.aPaneGoingReadAtACaretRescuePointKeepsItsMatchPainted` — the suite's rig, `*Hyde *`, one
  match `{1,4}`, born live; the caret at 6 (non-vacuity: italic at 1); `isLive = false` → `.backgroundColor` at 1 ==
  `matchTint` and the painted runs == `[{1,4}]`. **RED ON OLD expected** (2 issues: the colour, the runs) — W1.

#### R1-2 — Write's overlays after a settle re-wrap (FIXED, a refinement of the agreed shape; red on old and green)

- **Mechanism, confirmed:** `EditorViewModel.settleMarkdownCaret` writes attributes only; `overlayGeometryGeneration`'s
  inputs were the storage's character edits (`storageDidEdit`, `:1222`), the attach (`:427`), a width reflow (`:439`)
  and the refont keeper (`:2321`). A settle that toggles an italic in Study re-wraps its paragraph — MEASURED headless
  (a scratch AppKit program, not committed): Iowan Old Style 16 pt at the 680-pt measure, 200 words read 12 lines
  italic and 14 roman (60 words: 4 vs 5; 300: 18 vs 21) — so every block below moves while the generation stands;
  the display pass's `overlayLayoutDidSettle` returns at `overlayGenerationDelivered == overlayGeometryGeneration`
  and the ⑂ badges, callout frames, seams, the indicator and the gutter cards keep the old layout's places until a
  scroll, pointer or edit. (`ScrollAnchorController` refreshes only on a clip-bounds change or a live resize —
  `EditorView.swift:978-1023` — so a re-wrap inside a page that does not scroll heals nothing.)
- **The diff (`9f9980cb`, `EditorViewModel.swift` only):** when the settle restyled, the generation is bumped AND the
  text view is asked to draw (`needsDisplay = true`); the restyle's own display pass then reports through
  `viewWillDraw` → `overlayLayoutDidSettle`, whose hop lands after the pass that laid the restyled line out.
  **Deliberately NOT the agreed "refont road's shape" (a direct `overlayLayoutDidSettle()` call)** — for the
  orchestrator and the Fable round to judge: a direct hop is a `DispatchQueue.main.async` scheduled at once, and it can
  run BEFORE the layout pass that consumes the restyle (traced case: a note opening with its remembered caret at a rescue
  point — the settle runs at the open's caret placement, before the first viewport layout); it then reads pre-layout
  fragment frames, sets `overlayGenerationDelivered` to the new generation, and the first real pass's report returns at
  the guard — N14's own cold-mount class (badges on collapsed frames until a scroll). The width road calls directly
  because a bare frame change guarantees no display pass; a restyle of visible text always draws, and the
  `needsDisplay` belt makes the pass certain even when the line the caret LEFT is off screen above the viewport (moving
  visible text with no glyph of its own to redraw). Cost: one viewport redraw per settle that restyled — only a caret's
  arrival at or departure from a rescue point. Zero lines in `EditorSurfaceController` or `BlockDecor.swift` (VX-246's
  lane — no stop owed).
- **The pin:** `SettleRewrapOverlayTests.aSettleThatRewrapsAParagraphMovesTheBadgeBelowIt` (new suite in
  `MarkdownCaretFaceTests.swift`, `.serialized`) — Write in a 900×700 window under Study chrome (the
  `WriteFloatingViewportTests` rig: `EditorTypography.adopt` + `EditorSurface.Coordinator.applyChrome/install`, the
  globals restored), `*<200 words> *` honoured at its rescue point (non-vacuity: Study's real italic at 1), a fanned block
  below; the steady state by an explicit `refreshBadges()` (so the before is identical on both products); THE ACT: an
  arrow past the closing star (no character changes — asserted), then display passes that FORCE NOTHING
  (`displayIfNeeded` — so the pin proves the fix's own display request); `#require` the block moved > 10 pt (the
  re-wrap); the badge's y within 1 pt of the block's laid-out fragment. **RED ON OLD expected** (1 issue: the badge) — W1.
  An honest pin: the re-wrap is real in the host (Study's font ships), the act is the app's own key road.

#### R1-3 — the phone's guard window (PIN FIRST — DISMISSED AS HOLLOW at W2b)

- **The question (the review's, SPECULATIVE):** the shared settle's guard is `storage.editedMask.isEmpty`, which reads
  empty between `beginEditing` and the transaction's first change; if UIKit reports the selection inside
  `coordinateEditing` before the character change on the `UITextInput.replace(_:withText:)` road (autocorrect, the
  spelling Replace, dictation — only `insertText` was observed at U2), a settle at a rescue point writes inside the
  transaction — W2b's desync class.
- **The pin (`706008eb`, ALONE on the branch):** `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
  × `["Hello", "hi", "hello there"]` — the real `MobileEditorTextView` first responder in a key window, Study, the caret
  at `*hello |*` (7, honoured — non-vacuity), `replace(<"hello">, withText:)`; under `withEditorAssertionsMuted` so a
  desync reads as `desyncRecoveryCount`, never a crash. Asserts: no desync; the text; the identity audit; the face reads
  as the landed caret says (honoured iff the caret still sits between the space and the star). The shorter and longer
  replacements are mine, beside the review's same-length shape: they MOVE the caret, so a selection report is certain.
- **Prepared, NOT applied:** the guard — `guard pendingEdit == nil else { return }` at the top of
  `MobileEditorViewModel.settleMarkdownCaret` — is `47606e46` on the pushed side branch `vx-282-r1-3-guard` (the run tip
  `e243a87d` + that one commit), its phone products built (`DerivedData/vx282-r1fix-guard-ios-products`). RED in W2b ⇒
  the second window runs those products, then the commit is cherry-picked onto the run branch (byte-identical code);
  GREEN ⇒ R1-3 DISMISSED AS HOLLOW, the side branch deleted, no fix.
- **THE VERDICT — GREEN ⇒ DISMISSED AS HOLLOW.** W2b (the run tip's phone product, no guard): all three replacements
  passed — no desync, the text right, the identity audit clean, the face reading as the landed caret says; W1c (the
  pre-fix phone) the same. On iOS 26.2's simulator UIKit's `replace(_:withText:)` does not report the selection inside
  its transaction before the character change, so the `editedMask` guard has no window on this road. No fix landed;
  `47606e46` is gone with its branch (`git push origin --delete vx-282-r1-3-guard`; `git branch -D`), its products
  deleted. The pin stays on the branch as a guard: the day a UIKit point release reorders the reports, it goes red
  (the record of the fix then is this section). Autocorrect's and dictation's own drivers may differ from the public
  `replace(_:withText:)` they call — not reachable in a test host; recorded, not owed.

#### R1-4 — the comments panel moves to the shared home (DONE)

`git mv` of `Features/Editor/CommentsPanel.swift` and `Features/Editor/CommentTextArea.swift` to `Core/Views/`
(`b7fece88`; `git log --follow` carries the history). No code line changed; one header comment in `CommentTextArea.swift`
says why it moved (VX-179's F-U3-1 Q-3 "panel-private home" kept — it stays beside its one consumer). The Xcode project
uses synchronized folders (`PBXFileSystemSynchronizedRootGroup`, no `pbxproj` edit; no membership exception names
either path); the Mac-only target (`MobileComments.swift` names `CommentsPanelModel` in a comment only). Path references
elsewhere are history (records) or the strings workbook's frozen 2026-10-05 inventory keys, which the workbook reads from
its doc, never from source. Headless `build-for-testing` green (the fixed tree).

#### R1-5 — the #220 disclosure (DONE `f411c213`)

QUESTIONS #220 gains a plain paragraph in her register: the approved wording said the grammar untouched; the caret rule
lives in the grammar's module (`spans(in:caret:)` + `closerFlanks`), byte-identical with no caret (its own suites
unchanged, the gate-soundness pin over every caret of nineteen texts), and why one grammar beats a second matcher, with
the road back if she wants the file itself untouched. The handoff line is the closeout's (not this leg's).

#### R1-6 — O-4 re-verified (DONE `f411c213`) — premise FALSE, withdrawn, no ticket

Traced: `PaneMount.kind(of:focused:windowIsKey:)` (`WorkspaceNavigation.swift:85-87`) is consulted at `RootView.swift:1124`
and `NoteWindowView.swift:92` with `WindowRegistry.isKey` — the sticky last-known-key among REGISTERED windows
(`WindowRegistry.swift:108-120`). Exactly one window mounts Write (and so the take panel's sheet, `EditorView.swift:186`,
and every routed handler); a window that stops being it re-renders read-cheap, and the panel's `.onDisappear`
(`WriteTakesPanel.swift:267-272`) unregisters and detaches. The U3 record's O-4 line is struck through with the trace
beside it. The orchestrator owes no ticket for it.

#### R1-7 — a caret in a non-editable editor (FIXED; red on old and green, both platforms)

- **Mechanism, confirmed:** both platforms' settles handed the face the selection whatever the editability, while the pane
  hands none when not editable (`PaneSurface.swift:2009-2015`). The Mac's Write on a SEALED note is selectable and not
  editable (`adoptHeader`, `EditorViewModel.swift:806-816` — no caret drawn): a click at a rescue point turned the italic on,
  and a seal arriving while the caret sat there left the italic standing (nothing re-settled on the flip). The phone's
  non-editable states are the stand-downs (`standDown`, the gone note, the page under the takes browser or the comments
  sheet); a SEALED phone note stays editable (its gate refuses, its caret is drawn).
- **The diff (`26c2e448`):** Mac — `holdsCaret = isEditable || structuralInFlight` gates the selection (the flight's
  few-ms fence is the ONE non-editable state that still holds her caret: `runStructural` drops `isEditable`, the act
  lands the caret INSIDE the flight — `applyStructuralResult`, `EditorSurfaceController.swift:3042-3049` — and the
  defer lifts the fence with no selection change, so a plain `isEditable` gate would read a landing at a rescue point
  caret-blind until her next move; read from the model's own forward, zero lines in `EditorSurfaceController`); and
  `adoptHeader` re-settles when the editability FLIPS (sealing re-reads the honoured line; unsealing honours the caret
  where it stands; a header delivery that does not flip — every autosave's touch stamp — settles nothing). Phone —
  `isEditable` gates the selection; no flip-settle there (a stood-down surface is a hidden or covered page; its caret
  comes back with the pen).
- **The pins (`ebd327d0`):** Mac `MarkdownCaretFaceTests.aSealedNoteHonoursNoCaret` (`["*hello *", "next block"]`: honoured
  while editable — non-vacuity; sealed → not editable, the span plain; a click at the rescue point → plain; unsealed →
  honoured where the caret stands). Phone `MobileMarkdownCaretTests.aStoodDownEditorHonoursNoCaret` (honoured live; after
  `standDown()` a selection at the rescue point, settled as the delegate settles, → plain). **RED ON OLD expected:** Mac 1–2
  issues (the click certainly; the seal arrival unless the harness's reload re-renders the storage) — W1; phone 1 — W1c.

#### R1-9 — the burst pins against R2-1's revert (DONE — all three red under the revert)

R2-1 = the 18c ladder's round-2 MAJOR (`use-report-round-2026-09-06.md:2019-2025`): the stash drained at the end of the
NEWEST arming, not when the surface is IDLE; fixed at `0ce1040f` by `replayDeferredKeystrokesIfIdle`'s one drain rule
(`guard !structuralInFlight, pendingCrossBlockTask == nil`). Its revert, as that ladder named it (`:2159`): the
`pendingCrossBlockTask == nil` half removed. Built test-only (`DerivedData/vx282-r1fix-r21revert-products`, the fixed tip
otherwise), restored, `git diff` empty. **Predicted by trace** (the window decides which pin carries R2-1): RED —
`aBurstWithASeamBackspaceKeepsTheTextBehindTheReturnItFollowed` (the original R2-1 pin, `["alpha"]` → `["alphax", ""]`),
`aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow` (`["", "beta"]`: the carve's flight drains `x` at beta's start
before the queued ⏎ acts → `["", "x", "beta"]`), and `aBurstWithASeamBackspaceAboveABlockLandsWhereTheBreakWas`
(`["alpha", "beta"]`: the carve lands at alpha's end, its flight drains `x` there → `["alphax", "", "beta"]`).

#### R1-10 — the U5 record's adopt line (DONE `f411c213`)

The U5 line is struck through and corrected in place: the caret-at-end rule keys on an EMPTY area, so ANY adopt into
one lands the caret at the end — the mount fill included (every area is born empty and its first `adopt` from
`makeNSView` fills it, so a live comment row's edit area now opens with its caret at the comment's end), and a store
arrival into an area she emptied likewise; an adopt into a non-empty area keeps the caret where it can be. Code
unchanged.

#### The products (no new full tree — three Products-only clones beside the two existing trees)

| Products | Built from | For |
|---|---|---|
| `DerivedData/vx282-r1fix-old-products` (Mac, clone) | the tip with `EditorViewModel.swift` + `PaneSurface.swift` at `706008eb` (named; restored, diff empty) — FINAL pins over the pre-fix app; `nm`: no `holdsCaret` | W1 |
| `DerivedData/vx282-r1fix-r21revert-products` (Mac, clone) | the fixed tip with R2-1's named revert (restored, diff empty) | W1b |
| `DerivedData/vx282-r1fix-old-ios-products` (phone, clone) | `706008eb` itself (all phone pins final; the pre-fix phone) | W1c |
| `DerivedData/vx282-r1fix-guard-ios-products` (phone, clone) | the side branch `47606e46` (tip + the R1-3 guard) | the second window, only on a red W2b |
| `DerivedData/vx282-u1` (Mac, the existing tree) | the run tip (fixes + move) — `nm`: `holdsCaret` present | W2 |
| `DerivedData/vx282-u2-ios` (phone, the existing tree) | the run tip (no guard) — three distinct phone dylibs by md5 | W2b |

All six `TEST BUILD SUCCEEDED`; build logs `DerivedData/vx282-r1fix-*.log`. No `Sources/` file touched — no `swift test`
owed. Zero `Sync/`, custody, Keychain, schema; the editor seam's `EditorSurfaceController`/`BlockRangeIndex`/
`BlockDecor` untouched by the fixes (the R2-1 revert touched `EditorSurfaceController` in the working tree only, for one
build, restored).

#### THE r1fix WINDOW PLAN (≈35 min; runs only on the orchestrator's claim line; `guard.sh --author` before every leg)

From `App/Variorum/`; logs to `notes/plans/vx282-screens/r1fix/logs/` (create it). `pgrep` first — no `/Applications`
Variorum instance, none of ours; no booted simulator. No app launch and no walk: no fix changes anything she sees except
by the pins' roads (an italic's honour in two non-editable states; a badge's place; a match's paint).
- **W1 — red on old, Mac (≈4 min):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-r1fix-old-products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'`
  `-only-testing:VariorumTests/` × `PaneFindFaceTests` `SettleRewrapOverlayTests` `MarkdownCaretFaceTests`
  `PaneMarkdownCaretFaceTests` → `w1-red-on-old.log`. EXPECTED RED: `aPaneGoingReadAtACaretRescuePointKeepsItsMatchPainted`
  (2), `aSettleThatRewrapsAParagraphMovesTheBadgeBelowIt` (1), `aSealedNoteHonoursNoCaret` (1–2); everything else green.
- **W1b — R1-9, the R2-1 revert (≈2 min):** the same with `-xctestrun
  DerivedData/vx282-r1fix-r21revert-products/Variorum_Variorum_macosx27.0-arm64.xctestrun`
  `-only-testing:VariorumTests/TypedReturnKeyTests` → `w1b-r21-revert.log`. Record EVERY red; predicted the three burst
  pins above.
- **W1c — red on old, phone (≈3 min incl. the boot):** `xcodebuild test-without-building -xctestrun
  DerivedData/vx282-r1fix-old-ios-products/VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2' -collect-test-diagnostics never`
  `-only-testing:VariorumMobileTests/MobileMarkdownCaretTests` → `w1c-phone-red-on-old.log`. EXPECTED RED:
  `aStoodDownEditorHonoursNoCaret` (1). R1-3's three cases also run here — informative only (W2b decides).
- **W2 — the fixed Mac batch, `-derivedDataPath DerivedData/vx282-u1` (≈18 min), five invocations (suite TYPE names,
  grepped; the mounted popover/sheet suites kept apart, as at U5):**
  (g1, `w2-g1.log` — the face, find, the panes) `PaneFindFaceTests` `MarkdownCaretFaceTests` `PaneMarkdownCaretFaceTests`
  `SettleRewrapOverlayTests` `MarkdownFaceTests` `ProgrammaticReplaceFaceTests` `PaneSurfaceTests` `PanePublishDoorTests`
  `TakePaneMeasureTests` `PaneRenderRestoreClipTests` `IdentityProjectionAuditWalkTests` `MacIdentityAuditWiringTests`
  `EditorSessionTests` `ReviewRoundFixTests` `CommitFlowTests` `FanFlowTests`;
  (g2, `w2-g2.log` — Write's overlays and geometry) `InlineEditorWindowTests` `ReadTierTests` `EditorWindowSmokeTests`
  `IndicatorGutterTests` `BlockDecorGeometryTests` `ProseGutterTests` `EditorDecorTransactionTests` `RefontViewportTests`
  `RefontGapTopTests` `WriteFloatingViewportTests` `UntouchedLineKeeperTests` `InlineHeightReportTests`;
  (g3a, `w2-g3a.log` — the comments after the move) `CommentPanelHostSuites` `CommentPanelLeaveTests`
  `CommentPanelDoorsTests` `CommentPanelParkTests` `CommentsPanelModelEditorTests` `CommentCompositionTests`
  `CommentPanelKeysTests` `CapabilityRegistryTests`;
  (g3b, `w2-g3b.log`) `CommentPanelFixLeg2Tests` `CommentTextAreaMountedTests` `CommentPanelGeometryRuleTests`
  `CommentPanelWordsTests` `CommentCardLayoutTests` `CommentCardViewTests` `CommentCardControllerTests`
  `MarginHoverCommentTests` `WriteTakesPanelRoutedCommandTests` `WriteTakesPanelKeysTests`;
  (g4, `w2-g4.log` — Return and the carve: the flight fence in `holdsCaret`) `CarveCaretLandingTests`
  `BlockDeletionAndRedoTests` `TypedReturnKeyTests` `ReturnKeyTraceTests` `SoftNewlineTests` `EditorEditRouteTableTests`
  `SeamMergeTests` `CrossBlockCompoundTests`.
  EXPECTED: all green; `CommentPanelHostSuites` "passed with N known issues" (the VX-229 runner fact, U5 — R1-8's watch is
  the closeout's whole-target run, not this). Read every suite's ✔/✘ line and the skips (a wrong name runs 0 tests and
  still "succeeds"; the nested `CommentPanelHostSuites` must show both child suites).
- **W2b — the fixed phone + R1-3's VERDICT, `-derivedDataPath DerivedData/vx282-u2-ios` (≈4 min):** the W1c destination
  and flags, `-only-testing:VariorumMobileTests/` × `MobileMarkdownCaretTests` `MobileMarkdownRenderTests`
  `MobileMarkdownReturnTests` `MobileMarkdownActsTests` `MobileCheckboxTapTests` `MobileEditorMaterializationTests`
  `MobileEditorRoutingTests` `MobileEditRoutingBindingTests` `MobileIdentityAuditSeparatorTests`
  `MobileEditRoutingCrashTests` `MobileLivenessTests` → `w2b-phone.log`. **R1-3 DECIDES HERE:** the three
  `aReplaceThroughTheInputRoad…` cases green ⇒ HOLLOW (no fix; the side branch goes); any red (`desyncRecoveryCount`)
  ⇒ the window can continue at once into **W2c** (≈3 min): the same phone list on `-xctestrun
  DerivedData/vx282-r1fix-guard-ios-products/VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun`
  → `w2c-phone-guard.log`, all green expected; the cherry-pick of `47606e46` follows the window. Then `xcrun simctl
  shutdown all`; 0 booted; release the claim.

**READY FOR STAGE — r1fix: W1 (Mac red-on-old: R1-1, R1-2, R1-7) · W1b (R1-9, the R2-1 revert) · W1c (phone red-on-old,
R1-7) · W2 (the fixed Mac batch, five groups) · W2b (the fixed phone batch + R1-3's verdict) · W2c only if W2b's R1-3 is
red, ≈35 min (≈38 with W2c).**

#### THE r1fix WINDOW — RUN 2026-10-14 07:53:31 → 08:00:50 (claim `vx282-r1fix`, handed from `coord-for-vx282`; RELEASED)

The coordinator's GO (pre-checks at 07:53: no instance, no booted simulator, disk 65 GiB, the dev store Standard and
unlocked). `git pull --ff-only` first (the tip `7444caf8`, the products' code); `guard.sh --author` OK before every leg;
`pgrep -lx Variorum` empty throughout; nothing rebuilt; no app launch, no walk, no system popup. Logs:
`notes/plans/vx282-screens/r1fix/logs/`.
- **W1 — red on old, Mac — AS DESIGNED** (`w1-red-on-old.log`, 07:53:38–07:54:09): "Test run with **18 tests in 4 suites
  failed** … **5 issues**", every one on a designed expectation — `aPaneGoingReadAtACaretRescuePointKeepsItsMatchPainted` 2
  (`PaneFindFaceTests.swift:308` the colour at 1, `:310` the painted runs); `aSettleThatRewrapsAParagraphMovesTheBadgeBelowIt`
  1 (`MarkdownCaretFaceTests.swift:488`: badge y 318.0, the block's fragment 340.0 — the roman re-wrap moved it 22 pt, one
  line, past the `#require`'s 10); `aSealedNoteHonoursNoCaret` 2 (`:172` the seal's arrival — the harness's reload did NOT
  re-render, so the flip half is red on old too — and `:178` the click). GREEN on old: the other 15 (the U2 pins, the find
  suite's eight standing tests, the pane suite).
- **W1b — R1-9, R2-1's revert** (`w1b-r21-revert.log`, 07:54:22–07:54:45): "**27 tests in 1 suite failed** … **4
  issues**" — EXACTLY the three burst pins: `aBurstWithASeamBackspaceKeepsTheTextBehindTheReturnItFollowed` 1 (the
  store), `aBurstWithASeamBackspaceHoldsWhenTheCarveLandsBelow` 2 (the store; 2 entries where 3 belong),
  `aBurstWithASeamBackspaceAboveABlockLandsWhereTheBreakWas` 1 (the store); the other 24 green. **So each of the three
  carries R2-1 on its own landing** — the re-pointed pin included (the review's question); the flipped pin is a second
  R2-1 pin besides VX-290's. (The stores print `<not evaluated>` — `#expect` does not decompose a `try` call — so the old
  stores are the trace's, not the log's.)
- **W1c — red on old, phone** (`w1c-phone-red-on-old.log`, iPhone 17 Pro iOS 26.2, `-collect-test-diagnostics never`,
  07:54:56–07:55:23): "**4 tests in 1 suite failed** … **1 issue**" — `aStoodDownEditorHonoursNoCaret`
  (`MobileMarkdownCaretTests.swift:149`); green: the two U2 pins and R1-3's three cases (informative). One launch, no
  restart.
- **W2 — THE FIXED MAC BATCH, GREEN** (`DerivedData/vx282-u1`, the tip's build): g1 (`w2-g1.log`, 07:55:41–07:56:40)
  "**125 tests in 16 suites passed**" — R1-1's, R1-2's and R1-7's pins ✔ (R1-2's on the UNFORCED display road: the
  fix's own display request delivered the overlays); g2 (`w2-g2.log`) "**68 tests in 12 suites passed**"; g3a
  (`w2-g3a.log`) "**73 tests in 10 suites passed** … with **9 known issues**" (exactly U5's VX-229 runner fact — the
  `━` lines on `CommentPanelReleaseTests` and its parent; both host child suites listed); g3b (`w2-g3b.log`) "**67
  tests in 10 suites passed**"; g4 (`w2-g4.log`) "**137 tests in 8 suites passed**". **470 tests / 56 suites, 0
  skipped** (every log's suite count matched the names given; `** TEST EXECUTE SUCCEEDED **` ×5). *(Machinery honesty:
  the first g1 call passed the `-only-testing` list as ONE argument — zsh does not word-split a string — and xcodebuild
  refused it as an unknown build action before running anything; re-run at once with an array.)*
- **W2b — THE FIXED PHONE BATCH + R1-3's VERDICT, GREEN** (`w2b-phone.log`, `DerivedData/vx282-u2-ios`,
  08:00:08–08:00:40): "**79 tests in 11 suites passed**", one launch, no restart — `aStoodDownEditorHonoursNoCaret` ✔ and
  `aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep` "with 3 test cases passed". **R1-3: HOLLOW** (above).
- **W2c — NOT RUN** (R1-3 green). The side branch deleted on GitHub and locally; `DerivedData/vx282-r1fix-guard-ios-products`
  deleted.
- **Close:** `xcrun simctl shutdown all` → **0 booted**; no Variorum instance; `Tools/stage release --who vx282-r1fix` at
  08:00:50 → STAGE FREE. The dev store untouched (no launch). Products kept for the Fable round: the two trees +
  `vx282-r1fix-old-products`, `vx282-r1fix-r21revert-products`, `vx282-r1fix-old-ios-products`.
- **After the window (doc only, no rebuild owed):** `ReturnKeyTraceTests`' re-pointed pin's doc and the U1 record's line
  now say it was re-proven against R2-1's revert.


### ROUND 2 — the run's ONE `fable-reviewer` cold review (REVIEW_PROMPT verbatim, PHASE=VX-282 + the location/stage line), reviewed tip `88353e0d`; read-only

**Tally: 0 BLOCKER · 0 MAJOR · 2 MINOR · 3 NIT (one SPECULATIVE).** It discharges the editor-seam mandate round 1
deferred and re-checked every round-1 fix (R1-2's display-pass refinement JUDGED SOUND — "strictly better than the
agreed direct hop"). No new BLOCKER/MAJOR ⇒ **no round 3** (the ladder rule). The findings, as the reviewer wrote them
(condensed only where marked):
- **F-1 [MINOR]** `notes/QUESTIONS.md` #220 (+ `MarkdownSyntax.swift:629-651`) — the caret rescue can RE-SHAPE an
  existing, stable span: `closingSingle`/`closingPair` return the EARLIEST closer `closerFlanks` accepts, so a rescued
  interior marker beats the later real closer. `*foo *bar*` reads caret-blind as one italic over `foo *bar`; with the
  caret at offset 5 it reads italic `*foo *` + plain `bar*`, flickering back whole on leaving (same class:
  `*2 * 3 = 6*`). A NEW visible flicker class on spans that never flickered — the ruled rule's letter, recorded only
  in a test comment (`MarkdownCaretRescueTests.swift:119-131`); #220's "a caret only ever changes the reading at the
  one spot" reads as rescue-only. Fix: doc-only — two sentences in #220 + the U2 record's edges, plus the optional
  narrowing she could rule ((b): rescue only when no caret-blind span already covers that marker). No pin owed.
- **F-2 [MINOR]** `EditorSurfaceController.swift:2963` vs `EditorViewModel.swift:804-815, 3557-3558` — R1-7's
  residual: a seal arriving DURING a structural flight (`adoptHeader` skips the editable write and the flip-settle
  under `!structuralInFlight`); the landing's settle honours the caret (the flight fence); the flight's defer
  re-derives `isEditable = false` directly with no selection change — the sealed, caret-less page keeps the italic
  until her next click. Fix: one line in `runStructural`'s defer after the editable re-derive —
  `model.settleMarkdownCaret()`. Pin: hold a flight open, adopt a locked header during it, land a selection at the
  rescue point, end the flight, assert plain — red on current code. Narrow reach (a remote seal racing a few-ms
  flight), self-healing.
- **F-3 [NIT]** `MarkdownFaceCore.swift:237-271` (consumers `EditorViewModel.swift:3541-3548`,
  `PaneSurface.swift:2000, 2017-2024`) — `settleCaret` answers "restyled" whenever the LEDGER planned, not whether
  either inner `restyle` wrote: a caret at a gate-positive point no opener pairs with (`hello *|`) makes Write bump the
  overlay generation + redraw and a pane run `findPaintWasReset()` + `remeasure()` per such move. Cost-only. Fix:
  return `clearWrote || honourWrote`. Take or record.
- **F-4 [NIT, SPECULATIVE]** `PaneSurface.swift:1965-1967, 2000` — a `shouldChangeTextIn` never followed by
  `textDidChange` would leave `pendingEditReplaced` set and skip pure-caret settles until the next keystroke; no
  concrete road named (marked text/IME post `textDidChange`). Belt optional. Take or record.
- **F-5 [NIT]** `EditorViewModel.swift:3519-3548` — the settle's CLEAR of a line far above the viewport (caret parked
  at a rescue point, she scrolls away, then clicks) re-wraps it in Study and nudges the page under the pointer — the
  same physics as any attribute re-wrap, a new occasion VX-296 adds, recorded nowhere. Fix: a line in the U2 record's
  edges (doc-only).

**Clean bill (condensed):** the seam fence (zero `Sync/`/custody/keychain/schema/`Server/`; `EditorTextView`
untouched; `BlockRangeIndex` a pure widening) · no trailers across all 100 run commits · U1's survivor-identity landing
on all six shapes, P1, the walk incl. the real double press · U2's fix (a) as ruled, the byte-identical nil caret
(re-run green), the exact gate, the over-claiming ledger, attributes-only ≤2-line settles never re-entering
`storageDidEdit`, the W2b guard on every input road · every R1 fix re-checked (R1-1/R1-2/R1-7/R1-3/R1-4/R1-9/R1-5/6/10)
· U3's exhaustive `handleRouted`, the one grey wrapper, `ringMayStand` at both doors · U4's own UndoManager, observers
dismantled, re-take-only-what-it-held · U5's heap decider, the tightly-scoped known issues, `leave()` idempotent, the
doors as data, VX-182's fence textually the standing family's · U6's pure once-decided opening rule · every PROVISIONAL
with a reversal line (#220–#224), every deferred observation ticketed.

**THE CROSS-MODEL FLOW (her rule of 2026-10-13):** findings → the implementer verbatim (agree/dispute) → the reviewer's
final call → the IMPLEMENTER applies the confirmed fixes (red-on-old per bug-class fix, the suite green); the reviewer
writes no fix (no `Sync/` lines exist; it marked nothing FINDER-FIXES); this being the final round, its fixes get the
orchestrator's line-by-line check against each finding. Responses and the final call: PENDING below.

## Closeout

*(Pending.)*
