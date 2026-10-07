# VM-10 — The Write page's SCROLL AUTHORITY (her one pull-forward)

**Ticket: VM-10 · Project: Mobile — editor & capture faces · Branch: `vm-10-the-write-scroll-authority` · Worktree: `~/dev/variorum-vm-10` (cut from main @ `0f0624e7`, post-VM-5)**

## Her words (the binding product rule)

- 2026-09-12 (PL-22, the arrival): *"the mobile app also has this issue to an even worse degree
  where it defaults to showing NONE of the written text lines, which also drives me insane."*
- 2026-10-06 (the widening — "the bug that most drives me insane … a constant issue"): *"when i
  make a new line, it scrolls so i only see empty page and it fights me when I try to scroll back
  up. showing empty space should be allowed if you scroll there but it shouldn't be forced."*

**THE RULE: empty space may be SHOWN if you scroll there; it is NEVER FORCED.**

## The three arms (pin-before-fix EACH; the trace RUN, not read)

1. **THE ARRIVAL** — opening a note shows none of the text. RULED SHAPE (the Mac's 2026-09-12
   sitting, the phone builds its OWN version): (a) opening a note REVEALS the caret's line
   minimally — never lands it at the top — unless nothing is remembered for the note, in which
   case the page opens at the TOP; (b) the offset is remembered per note for the SESSION and
   restored on re-entry; (c) the typewriter room stays. The phone's traced candidate (unproven —
   the pin decides): the arrival lands the caret at the note's END over the bottom-inset room
   (`MobileWriteView`'s arrival ~`:40`/`:162`; `MobileEditorViewModel.jumpToBlock` ~`:838–860`
   states the room's contract; `MobileEditorTextView` holds the inset). Keyboard-raise compounding
   is the first thing to MEASURE.
2. **THE NEW-LINE FORCED SCROLL** — typing ⏎ scrolls so she sees only empty page. Trace by
   RUNNING: a multi-block note, caret mid-document and at the end, type ⏎, capture
   `contentOffset`/`contentSize` before/after with and without the keyboard. Find the scroller
   (an explicit reveal call on the typed edit? `scrollRangeToVisible`? the inset math?). The fix
   honors the rule: after ⏎ the caret's LINE stays visible (reveal minimally if it left the
   screen); the page never scrolls beyond what visibility requires; the room is reachable by HER
   scroll only.
3. **THE SCROLL-BACK FIGHT** — something re-scrolls against her gesture after the forced scroll.
   Trace by running: after arm 2's repro, drag upward and observe whether/what re-scrolls
   (a settle/reveal firing per keystroke? a caret-visibility enforcement on a timer/layout pass?).
   The fix: no programmatic scroll while a user pan is live or shortly after it; her gesture wins.

## Evidence of the kind (the acceptance gate is USE)

Pins: (1) the arrival pin — a three-block note, caret in block 3, nothing remembered → block 1
visible (RED on old, record the number); (2) the memory pin — leave at block 2's offset →
re-enter → restored; (3) the ⏎ pin — typed newline with the caret's line on screen → offset moves
at most minimally (RED on old with the forced-jump number); (4) the fight pin if the mechanism is
pinnable honestly — else the traced mechanism + a simulator capture. PLUS a simulator walk with
captures under a gitignored `notes/plans/vm-10-screens/`: a long note opened cold shows its first
lines; a note left mid-way re-opens there; typing ⏎ mid-note does not jump to empty page;
scroll-up after ⏎ sticks; the Today door's straight-into-typing arrival still lands ready to type;
with the keyboard up the caret's line is visible.

## Fences & rules

Phone-local ONLY: `MobileWriteView` / `MobileEditorViewModel` (the arrival + scroll roads) /
`MobileEditorTextView` (the inset). NOTHING in `App/Variorum/Shared/` (the brain's routing is not
the scroll), nothing in `Sources/`, no schema, zero `Sync/`. The typewriter room's EXISTENCE
stays (her ruled shape (c)) — only its FORCING goes. One simulator by UDID
*[removed for publication]*
suites by struct NAME; pathspec-limited commits; push after each; no trailers; the stage is
claimed by the effort at 13o's slot — never claim/release inside the implementer session.
PROVISIONAL rule binds: a decision the ruled shape doesn't make → `notes/QUESTIONS.md` at the
next free number (**#200**) with options, built most-spec-defensible.

## Cast (her 2026-10-06 ruling)

Fable orchestrates (this session) · **Opus 5.5 implements** · **Fable cold review** (the scroll
authority is editor-adjacent and the class burned her twice — the review is wanted, not optional).
Ladder per the standing shape: 0B/0M at round 1 ⇒ one fix wave + orchestrator verification closes.
The close: touched suites + the full mobile suite green, the record's dispositions, MobileSoul
PL-22's arrival half flipped, VM-10 → Done, a second phone install OFFERED on her checklist.

## LIVE STATUS

- 2026-10-07 early: brief staged pre-go; worktree ready at `0f0624e7`; awaiting 13o's stage slot.
- 2026-10-07 (implementer, Opus 5.5): reading done (this brief · CLAUDE.md · handoff §12.2/§12.2a/§10.4–§11.4 ·
  mobile-round-2 §17–§20 · SessionResiliencyProtocol implementer half · TEXTKIT2 §3 iOS findings · the three
  *[removed for publication]*
  `notes/plans/vm-10-screens/` gitignored.
  - TRACE HARNESS (temporary probe `VariorumMobileTests/MobileWriteScrollTraceProbe.swift`, deleted at close):
    the REAL `MobileWriteScreen` (and, for the shell road, the real `MobileShellView` → Library → row push) in
    a scene-attached key window 402×874; KVO on `contentOffset` recording the call stack of every change;
    swizzled `setContentOffset(_:animated:)` / `scrollRectToVisible(_:animated:)` / `scrollRangeToVisible`
    recording each INITIATOR. **Machinery fact:** Simulator.app is NOT installed on this machine (Xcode 27's
    `Developer/Applications` is empty), so the headless device stays in hardware-keyboard mode — the software
    keyboard was forced IN-PROCESS for the keyboard-up runs (WebKitTestRunner's route:
    `GSEventSetHardwareKeyboardAttached(false, 0)` + `+[UIKeyboard isInHardwareKeyboardMode]` → NO; measured
    effect: keyboard guide 387 pt, text view 340 pt, room 323 pt).
  - **Arm 2 (⏎ forced scroll) — TRACED (pre-fix tree, `0f0624e7`+probe).** ⏎ typed at the document END through
    the real door (`MobileEditorTextView.insertText`): offsetY **1776.7 → 2471.3**, first-visible char = last-
    visible char = **2691** (the new empty line, nothing else) — no keyboard, 30-paragraph note. With the keyboard
    up: 30 paragraphs **2343.3**, first = last visible = 2691; a **3-paragraph** note: offsetY **0 → 254.0**,
    first = last visible = **267** — the whole note scrolls away. Mid-document ⏎ at the viewport's last line:
    offsetY 303.3 → **336.0** (a 32.7-pt minimal reveal — correct). THE MECHANISM (initiators, in order): UIKit's
    `-[UITextView _scrollToCaretIfNeeded]` (the caret rect, minimal), then `-[UITextView _scrollToSelectionIfNeeded]`
    (from `textInputDidChange:`) calling `scrollRectToVisible(_:animated:)` with the selection's LINE rect — which
    for the document's LAST line is padded by the bottom `textContainerInset` (the typewriter room): **(15, 2242.9,
    372, 711.4)** vs a mid-document line's (20, 987.5, 362, 22.7). Taller than the 675-pt viewport, it is
    bottom-aligned, so the caret's line lands at the TOP over a page of room. Our code issues no scroll here.
  - **Arm 3 (fight) — TRACING.** A programmatic scroll-up after ⏎ + typing STAYS for 5 s (the only offset moves
    are UIKit's own TK2 content-size anchoring, `_setContentOffsetWithoutRecordingScrollPosition`, ±32/96 pt that
    keep the visible text in place); no timer/mint/delivery re-scroll found. Typing after scrolling the caret off
    screen re-runs `_scrollToSelectionIfNeeded` (the arm-2 rect) — the repeat of the forced scroll.
  - **Arm 1 (arrival) — TRACING.** Every arrival measured lands at offset 0, caret {0,0}, first visible char 1:
    bare screen (focus off/on), the real shell road (Library → row push), and keyboard-up (30- and 3-paragraph
    notes). So "nothing remembered → top" is ALREADY true on the pre-fix tree (its pin will be green-on-old).
  - **More arm-3 tracing.** (i) A geometry change alone (the surface ±120 pt) re-reveals nothing (0 initiators).
    (ii) **The fight, found:** with the keyboard up, the caret on the empty line after ⏎ and the page scrolled
    back up 500 pt, a keyboard DOWN/UP round trip (what `.interactive` dismissal does when her drag engages the
    keyboard and it springs back) re-runs `-[UITextView _scrollToSelectionIfNeeded]` from `-[UITextView
    _layoutText]` ← `layoutSubviews` ← `-[UIWindow layoutViewsForTrackedGuides]` inside `-[UIInputWindowController
    moveFromPlacement:toPlacement:…]`, with the room-padded rect **(15, 2434.9, 372, 711.4)**: offsetY **1643.3 →
    2435.0**, first/last visible **2680/2691** — thrown back onto the room. (iii) Tap-to-continue (open without
    focus, caret to the end, keyboard rises) reveals MINIMALLY (8 paragraphs: 0 → 305.0, caret at the viewport's
    foot) — correct; and typing a character after scrolling the caret away also reveals minimally (the room
    padding attaches ONLY to the empty extra line fragment after a trailing newline — exactly the ⏎ state).
  - **PINS — `VariorumMobileTests/MobileWriteScrollAuthorityTests` (7 tests), RED-ON-OLD RUN on the pre-fix tree**
    (production code untouched; `-collect-test-diagnostics never` — a failing run otherwise hangs xcodebuild 600 s
    collecting simulator diagnostics, a machinery fact):
    - `aReturnAtTheEndRevealsTheNewLineMinimallyAndKeepsTheText` — **RED**: offsetY 1689.7 → **2439.3**, first
      visible char **2691** = the new empty line (2 issues).
    - `aReturnAtTheEndOfAShortNoteKeepsTheWholeNoteOnScreen` — **RED**: offsetY 0 → **254.0**, first visible **267**
      — the whole 3-paragraph note gone (2 issues).
    - `aNoteLeftMidwayReopensWhereSheLeftIt` — **RED**: left at first visible char 970, re-entry at offsetY **0**
      / char 1 (1 issue).
    - GREEN ON OLD (guards, not pins — recorded so nobody counts them as red-on-old):
      `aReturnMidDocumentStillRevealsTheCaretMinimally`, `aNoteNeverVisitedOpensAtTheTop` (arm 1's "nothing
      remembered → top" — already true), `aRelayoutAfterHerScrollUpNeverForcesTheRoom` (the focus round trip in
      HARDWARE-keyboard mode does not reach the placement animation — the fight's real trigger needs the software
      keyboard, which the committed pins deliberately never force process-wide), and
      `typingAfterScrollingTheCaretAwayRevealsItMinimally` (old: 587.3 → 1717.7, caret at the foot — minimal).
  - Walk captures — NOT-STARTED. Final suites — PENDING.
