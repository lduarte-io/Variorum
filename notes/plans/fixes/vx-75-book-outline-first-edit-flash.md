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
- **DONE** — the PROBE PIN written (speculative-finding road: pin FIRST as the confirm): `BookOutlineLandingTests.theFirstClickIntoEditingHoldsTheColumnSteady` — expands a story read-cheap, settles, then `focus(storyID, caret: 120)` (the prose click's exact call) and SAMPLES the `BookOutlineGeometry` oracles every settle turn: max neighbour top-shift (tolerance 150 pt — legit read↔live inset drift is ≤ ~48), the focused row's height floor (> pre − 200), and no witness anchor de-realizing mid-swap. RED ⇒ the column-geometry class is confirmed; GREEN ⇒ the column is acquitted in-harness and the walk's frames adjudicate a window-level class. `build-for-testing` compiling headlessly (`DerivedData/vx75-bft.log`).
- **IN-PROGRESS** — reproduction: WAITING on the stage (HELD by the VM-5 merge orchestrator, claimed 20:34, renewed; a watcher polls each minute) — the walk never steals a live claim.
- **DONE** — reproduction walk (frames), mechanism traced, red-on-old pin, fix, behavioral revert (RED→GREEN), fixed-build walk (no blank frame), regression run (30 suites; the only reds are VX-77's, pre-existing).
- **IN-PROGRESS** — ladder round 1: fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim.
- **NOT-STARTED** — PR `VX-75: …` (merge commit) after the ladder.

## The walk runbook (one stage claim covers both acts)

**Scheduling (her ruling, 2026-10-06 evening): 13o decides the test-run order across the five named sessions — this session claims ONLY on 13o's assignment.** Answered its questionnaire same turn: one ~35–45 min slot (walk ~15–20 + suite run ~5–10), hard-blocked, not the row-85 idle-machine class; a second similar slot after the fix lands, to be requested when ready.

1. On 13o's go: `Tools/stage claim --who "VX-75 orchestrator" --reason "first-edit flash reproduction + pin run" --minutes 45`.
2. `guard.sh --author` → `open -n` the vx75 Debug app → pid by PATH (`pgrep -f 'DerivedData/vx75/.../MacOS'`).
3. Shelf capture (`/tmp/walk-cap`) → click Sherlock (Outline opens by default) → ▸-unfold a story read-cheap → small scroll → capture for prose coordinates.
4. ≥3 s of HID quiet → `screencapture -v -V 6 DerivedData/vx75-walk/flash.mov` (background) → sleep ~1.5 → `click.sh <pid> <x> <y>` into the prose → let the recording finish → `ffmpeg -vsync 0` frames → read the frames around the click (whole-window vs. column scope; translation vs. blanking; the shake's magnitude).
5. Second prose click on another note under the same session — the clean steady state on film too; then quit the dev instance BY IDENTITY, re-check `pgrep`.
6. The pin run under the same claim: `xcodebuild test … -only-testing:VariorumTests/BookOutlineLandingTests` (suite level), read the `VX-75 PIN:` line.
7. Release the stage; findings land here before any fix.

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

**The walk (2026-10-07 ~00:57, dev store, the Sherlock book, Terminal·dark, stage held by 13o's assignment).** A story ▸-unfolded read-cheap, scrolled mid-story, then ONE prose click recorded (`DerivedData/vx75-walk/flash.mov`, 94 frames @ ~15.6 fps, extracted to `frames/`):
- Frames **f0055–f0063 (~9 frames ≈ 0.6 s)**: the ENTIRE text column is blank — the window's background where the story was. The sidebar (the note box already says "editing" + the title, no bar yet) and the navigator stay drawn. PNG size drops 2.95 MB → 1.83 MB and returns at f0064.
- **f0065**: the same text back at the SAME position (the "He chuckled…" line at the identical y before and after), the clicked block ringed live, the note box's bar filled in. **No measurable column displacement** — the probe pin agrees (`maxShift=0`, no witness de-realized, the row's height floor never dipped). The "slight shake" is not a geometry move in the frames; its likeliest reading is the blank→return itself plus the note box growing its bar in the same beat — re-walked after the fix.
- A second recording (a navigator click on a COLLAPSED story, `steady.mov`) shows a different, expected beat: the newly expanded story's body loads below its heading (nothing was on screen there before).

**The pin run (same claim):** the probe `theFirstClickIntoEditingHoldsTheColumnSteady` GREEN (`maxShift=0 heightFloor=16195 of 16195 vanished=[]`) — the column-geometry class is ACQUITTED. The stage claim then lapsed during a session interruption (no harm recorded; 13o's implementer back-filled the idle stage); re-claimed on the author's word.

## The mechanism

**`OutlinePostRow` swaps two VIEWS on focus, and the incoming one is born empty.** Expanded + unfocused renders `ReadPostView` (identity `read-<postID>`); expanded + focused renders `EditorView(inline: true)` (identity `<postID>`) — two separate `if/else` branches. The prose click → `BookViewModel.focus` flips `liveFocusedPostID`, the branch flips, SwiftUI dismantles the read surface IMMEDIATELY, and the inline editor mounts with an EMPTY `EditorTextView` (and a 24-pt frame inside `StableSurface`'s reservation, which is why nothing moves). Its text arrives only when `EditorViewModel.observeSlots`' first `observePost` delivery reaches `applyProjection` → `.initialRender` → `renderFull`. Every displayed frame between those two moments shows a correctly-sized, EMPTY row: the flash. **Once-per-session** because the interval is the editor's COLD first-render cost (first observation, first projection of a ~9.7k-word story, first TK2 layout of that storage — ~0.6 s cold on the walk); warm, the same gap shrinks to a frame or less, below perception — hence "after that… no issues". The class is not cold-only: the gap exists on every read→live swap, it is only invisible when short.

**Red-on-old pin:** `BookOutlineLandingTests.theFirstClickIntoEditingNeverShowsAnEmptyNote` — samples every displayed turn after `focus(_:caret:)` for any in-window `NSTextView` holding the story; RED on the current tree: `emptyTurns=[0] editorFilledAt=1` (in-memory store, warm — one empty turn; the app's cold road is ~9 frames of the same).

## The pin and the fix

**The fix (commit `6ff214c8`, files `Features/BookView/BookView.swift` + `Features/Editor/EditorView.swift`):**
- `OutlinePostRow`'s expanded body is ONE shape for both states: the header, then (near the viewport) a `ZStack` holding the read surface (identity `read-<postID>`, kept while `!(isLive && liveShowing)`) and, when live, the inline editor (identity `<postID>`) at `opacity(liveShowing ? 1 : 0)` + `allowsHitTesting(liveShowing)`. The read surface therefore keeps its identity across the focus flip — it is NOT dismantled by the click — and leaves only when the editor first shows the note. `liveShowing` (row `@State`) resets on the editor's `onDisappear` (unfocus, far-from-viewport release, collapse).
- `EditorView.onLiveShowing` → `InlineEditorSurface.onShowing` → the inline `Coordinator` fires it ONCE, from `remeasure()`, the first time a report is made with `model.loaded` true — i.e. right after the height measured from the initial render is written to the frame binding, in the SAME main-queue turn, so the frame grows, the editor turns opaque and the read surface leaves in one SwiftUI update. The full-document editor and every other inline host (spread, pool) pass nil — byte-unchanged behaviour.
- P-3 holds: the read surface is never live; there is still exactly one live editor (the invisible one is the live editor, already registered and taking the caret seed).

**Pin, red-on-old by behavioral revert:** `theFirstClickIntoEditingNeverShowsAnEmptyNote`, tightened before the fix landed so an editor counts as SHOWING the story only at its real height (a 24-pt birth frame holding the text does not count). Fix tree: `emptyTurns=[]` — suite 10/10 green (`DerivedData/vx75-pinrun3.log`). Pre-fix `BookView.swift` restored over the fix tree (`git show HEAD~1:…`; the fix committed first, restored by `git checkout --`): `emptyTurns=[0, 1]` — RED (`vx75-revert.log`). The geometry probe stays green on both sides (it was the acquittal, not the pin).

**The fixed-build walk (2026-10-07 19:42, fresh launch — the cold first-click conditions):** the same road (Sherlock → ▸ A Scandal in Bohemia → scroll 15 → one prose click), recorded (`fixed.mov`, re-extracted at a fixed 30 fps so no distinct frame can drop): **no frame loses its text** — the smallest frame in the whole recording is the first; the only jumps are UPWARD (`x0106` +275 KB, `x0112` +192 KB — the live ring and the note box's bar arriving). `x0105` (read surface) and `x0112` (live: the clicked block ringed, caret at block 12/262, the box's bar filled) show the identical text at identical positions. The "slight shake" does not appear.

**Regression run (same claim):** the 30 suites that mount `BookView`/the inline editor/`StableSurface` — 173 tests in 29 suites: green except 3 issues in two tests, `OutlineRoomTests.bothColumnsChromeStaysInsideThemAtTheirFloors` and `BookOrderConversionTests.theNavigatorsChromeStaysInsideItsColumn` (chrome clipped at a column floor). **Both fail identically on this branch's PRE-fix tree** (`vx75-prefix-margins.log`) — pre-existing, already ticketed as **VX-77** (red on main, found by VM-5); the navigator sibling was added to VX-77 by comment. Not this fix's.

## Ladder

*(pending — round 1: fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim, zero framing)*
