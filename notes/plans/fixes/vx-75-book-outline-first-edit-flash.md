# VX-75 — Book Outline mode: first click-to-edit flashes the whole screen

**Ticket:** VX-75 (In Progress) · **branch** `vx-75-book-outline-first-edit-flash` · **worktree** `~/dev/variorum-vx-75` (the Pro) · **record started** 2026-10-06.
**Shape:** single-ticket fix under the architect skill's process rules — Fable investigates and implements at her word ("you might be able to just investigate and fix it yourself then run a cold review on it and adjudicate"); cold review by `fable-reviewer` (editor-seam suspect ⇒ the Fable rider), pin-before-fix with a behavioral-revert check, this record because the diff is expected to touch the editor seam.

## Her report (2026-10-06, verbatim-faithful)

> "when I'm in a book and I'm on outline mode, I can scroll through everything fine, but when I click in to edit there's a dreadful flash of the whole screen and slight shake almost before it returns to normal. every time i click into editing it for the first time. after that, even navigations to other chapters don't cause issues. but it's driving me crazy - a jarring whole screen text disappears for a split second flash is NOT polished and the rest of the app is gorgeous."

Reading of the words (to verify at reproduction, not to build on): the flash is **once per book-session** (the FIRST click-to-edit; later edits and chapter navigations are clean), **whole-screen** (text everywhere disappears a beat), with a **slight shake** (small geometry shift and return).

## LIVE STATUS

- **DONE** — kickoff: ticket minted (VX-75), worktree seated, in-flight row landed on main (rode the 13s kickoff commit `fe48c535` — a concurrent session's `git add`/commit swept this effort's two ledger edits in; content verified correct, message names only 13s).
- **DONE** — preflight: CLAUDE.md canon (auto), TEXTKIT2_NOTES.md (full), SessionResiliencyProtocol.md (full), master plan in-flight table (no surface overlap: 13o search / 13x portability / 13s voice-onboarding / VM-5 mobile; none claims the book Outline or the editor seam), QUESTIONS.md targeted pass (#43, #97, #99, #103 — the Outline/note-box/landing entries).
- **DONE** — static trace of the suspect seam (findings below).
- **DONE** — walk preparation: Debug build GREEN (`App/Variorum/DerivedData/vx75/Build/Products/Debug/Variorum.app` in the worktree; log `DerivedData/vx75-build.log`); WalkKit helpers compiled (`/tmp/walk-cap`, `/tmp/walk-scroll`, `Tools/WalkKit/wl2`); terminal host holds BOTH grants (AX true · SCREEN true, probed); zero Variorum instances running; ffmpeg + cliclick present. Capture plan: `screencapture -v -V 6` around the first prose click, frames out via ffmpeg, artifacts under the gitignored `DerivedData/vx75-walk/`.
- **IN-PROGRESS** — reproduction: WAITING on the stage (HELD by the VM-5 merge orchestrator, claimed 20:34; a watcher polls each minute) — the walk never steals a live claim.
- **NOT-STARTED** — mechanism trace · pin (red-on-old, revert-verified) · fix · ladder (fable-reviewer) · PR.

## The surface, as read (static trace, pre-reproduction)

The click-to-edit path in the book's Outline (`App/Variorum/Variorum/Features/BookView/`):

1. `BookView.outlineBody` — a plain `VStack` of `outlineSegments` inside one `ScrollView` (`BookView.swift:1410`); each expanded note is its own segment, collapsed runs are `LazyVStack`-free `OutlineRunRow`s that self-virtualize at manifest heights.
2. `OutlinePostRow` (`BookView.swift:2256`): expanded + unfocused ⇒ `ReadPostView` (an `NSViewRepresentable` read tier, `ReadPostSurface`) inside `StableSurface`, identity `"read-<postID>"`; expanded + `liveFocusedPostID == postID` ⇒ `EditorView(inline: true, barPlacement: .inSidebarBox)` inside `StableSurface`, identity `<postID>`.
3. A prose click in the read tier calls `onFocusRequest(offset)` → `BookViewModel.focus(postID, caret: offset)` (`BookViewModel.swift:963`) — pure state (caret seed + focus + expand), no scroll request on this road.
4. The focus flip swaps the row's branch: read surface unmounts, `InlineEditorSurface` (a bare TK2 `EditorTextView`, `makeInlineEditor`) mounts at `@State inlineHeight = 24`, inside `StableSurface(known: rememberedSurfaceSize, followsShrinks: true)` which reserves the remembered height (minHeight) until the editor's first real report.

Theories considered and their status:

- **"First AppKit view flips the SwiftUI ScrollView compositing"** — DEAD: the read tier is already an `NSViewRepresentable` (`ReadPostView.swift:112`), so AppKit views live in that scroll from first render.
- **Row-local collapse to 24 pt during the swap** — guarded by design: `StableSurface` reserves the remembered size across the swap (`StableSurface.swift:246`), and both branches share one memory (`model.rememberedSurfaceSize`). Reservation refusals exist (width mismatch > 1 pt; voice mismatch) — a refused reservation WOULD collapse the row to ~24 pt and shake the column. Whether a refusal fires on her road is an empirical question.
- **Outline width report dropping all learned heights** — `reportOutlineContentWidth` fires on a >1 pt content-column width change and `BookOutlineHeights.stand` drops everything learned (the flash-shaped consequence). What would move the width on a first edit only is not yet traced.
- **Known adjacent quirk, recorded in `EditorViewModel.attach` (`EditorViewModel.swift:485`):** SwiftUI realizes the focused note's `InlineEditorSurface` TWICE (~40 ms apart, two models, no `dismantleNSView`) in the book's Outline — the 13u2 UNIT B finding. In the flash's neighborhood; relevance unproven.
- **Window-global one-time cost on first editable-text focus** (text input context / Writing Tools / glass re-evaluation on macOS 27) — would explain once-per-session + whole-window scope; not traceable statically. Reproduction decides.

None of these is "the mechanism" yet. **No fix lands without a self-traced concrete mechanism and a red-on-old pin** (CLAUDE.md's hallucination guard) — the reproduction exists to pick one.

## Reproduction plan

Dev store, Debug build (`io.lduarte.Variorum.debug`), under a held `Tools/stage` claim (NEVER while VM-5's claim lives; the real-store app untouched):

1. Launch the Debug app fresh; open a chaptered book (the seeded Sherlock book) in Outline.
2. Scroll through; expand a note; screen-record (`screencapture -v` or window capture at interval) around the FIRST prose click into edit.
3. Inspect frames: whole-window vs. scroll-content scope; does text blank everywhere or shift; measure the shake (px) and duration (frames).
4. Repeat the click on a second note — confirm the no-flash steady state; relaunch to confirm once-per-what (session? book open? mode entry?).
5. Instrument per the frames' verdict (targeted logging in the suspect path; the DEBUG oracles are available).

## Findings

*(pending reproduction)*

## The mechanism

*(pending)*

## The pin and the fix

*(pending — pin red-on-old, verified by behavioral revert, before any fix claim)*

## Ladder

*(pending — round 1: fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, zero framing)*
