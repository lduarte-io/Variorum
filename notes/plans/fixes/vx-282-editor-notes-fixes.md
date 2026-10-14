# VX-282 — Run: Editor & notes fixes

**STATUS: OPEN — kickoff 2026-10-13 (evening).** Run ticket **VX-282** (project *v1 release readiness*) ·
branch `vx-282-editor-notes-fixes` · worktree `~/dev/variorum-vx-282` on the Pro · PR `VX-282: …` (merge commit
only). Shape: `/run-phase` on the run ticket, at her word. Orchestrator: session **variorum-da** (Opus 5.5).
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
  main in first.
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
| U1 | VX-290 — the empty-block backspace's caret landing | NOT-STARTED |
| U2 | VX-296 — the italics flicker, caret-aware live restyle (Mac + phone) | NOT-STARTED |
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

## Ladder

*(Round findings verbatim, dispositions, fixes — repo-first before each next round.)*

## Closeout

*(Pending.)*
