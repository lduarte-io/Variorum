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
