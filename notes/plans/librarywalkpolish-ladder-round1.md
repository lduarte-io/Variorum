# librarywalkpolish batch 1 — cold-review ladder ROUND 1 (fresh `opus-reviewer`, 2026-10-05; diff `128c4af1..923be8c6`, the thirteen record-only commits named at spawn excluded)

**Verdict: 1 MAJOR · 5 MINOR · 5 NIT.** The reviewer executed REVIEW_PROMPT.md verbatim in its
own scratch DerivedData (`17y-review7`); re-ran the batch's suites (49/14 — 47 green + the
labeled known issue + the pre-existing F-BW-2 red) and the existing Library suites on the new
engine (71/10 green, the appearance-flip pin among them); compared the face captures
first-hand (visually identical); VERIFIED rather than trusted the two inherited claims (the
F-BW-2 "pre-existing" claim CONFIRMED by replaying the scan across six commits — with one
name corrected: the offender landed at 15b081d2, f8977039 only moved it; the compose rider
CONFIRMED genuinely shipped). Seam check: fences empty; the one borderline (VR-118's
effectiveOrder reading a stored LOCAL preference) judged outside "a default's meaning" — the
opus cast stands, the reasoning recorded. SAME-MODEL round: the dispositions below are the
orchestrator's, adjudicated against the spec.

## Findings and dispositions

- **[MAJOR-1] VR-116's drag chip is CUT OFF on most grabs** (`ShelfView.swift:1185–1199`): the
  preview canvas is exactly the row's size while the chip centre is clamped only to the
  canvas, so any grab ≳3 pt off the row's vertical centre, or within half a chip of either
  end, clips the chip (empirically probed standalone: grabs at y 4/32 cut 11 pt, a
  trailing-end grab lost 82 of 186 pt — the end of the book's name); the batch's own pin even
  locks a centre at y 0. **DISPOSITION: CONFIRMED — FIX, the reviewer's PRIMARY shape** (grow
  the canvas symmetrically by a chip-sized margin per axis, chip at grab + margin — the
  canvas stays centred over the source so the chip stays exactly under the cursor; the clamp
  alternative is REJECTED, it re-introduces the offset R-LWP-3 forbids). The reviewer's
  red-on-old pin as specified.
- **[MINOR-1] The order popover OUTLIVES NAVIGATION** (a menu never does): `orderOpen` lives
  on the RootView-owned model; only a board-local catcher closes it; ⌘K/⌘N/⌘J or a sidebar
  click tears the board down with the popover "open", and it greets her return. #188(d)
  overclaimed. **DISPOSITION: CONFIRMED — FIX** (close on the board's `.onDisappear`, window
  resign-key, app deactivation; the reviewer's pin; #188(d) corrected at this seam).
- **[MINOR-2] Three B-WALK record sections were filed INSIDE the B3 RECORD** (between B3's
  REVERT STATE and its red-on-old paragraph) — the late-session degradation class the spawn
  flagged, caught working. **DISPOSITION: CONFIRMED — FIXED AT THIS SEAM by the orchestrator**
  (the four blocks moved whole under the B-WALK RECORD's REVERT STATE line; LIVE STATUS's
  "below" pointers true again).
- **[MINOR-3] HALF of the F-BW-1 tripwire claim is HOLLOW:** the `withKnownIssue` arm reads
  only the model (it trips when hand placing returns) and NEVER the seed text — so the
  claimed "turns red when the lesson is re-worded" is false, and the arm also burns a full
  3-second wait every run. **DISPOSITION: CONFIRMED — FIX in the fix round**, folded into
  F-BW-1's own reword (below): the lesson re-words, a SEED-TEXT pin replaces the hollow half,
  the wait short-circuits when hand placing is off, and the three claim sentences are
  corrected to what is true.
- **[MINOR-4] Nothing GATED 0.9.2 on the lesson-7 reword** (the owner cell's "or VR-120,
  whichever comes first" would have let the release ship a lesson teaching hidden doors).
  **DISPOSITION: CONFIRMED — FIXED AT THIS SEAM:** F-BW-1 is now A PRE-0.9.2 GATE (the
  KnownIssues owner cell + the pass's close line both say so); the reword itself is
  AUTHORIZED seed-content work in the fix round (the B-SEED/B-DEDUPE precedent; the standing
  re-seed consequence already scheduled at the arc's close).
- **[MINOR-5, product] The scope-honesty rule was built on the WEAKER side:** Cards over the
  Books/Blocks scopes shows "No notes match" over a full library — the same dishonest state
  both of her rulings removed, reachable two ways. **DISPOSITION: CONFIRMED — BUILD THE
  GENERALIZED RULE as PROVISIONAL** (Cards ⇒ Notes from ANY scope; a non-Notes scope picked
  inside Cards ⇒ List), hers to overturn; #188(a) carries the note; no pin owed beyond the
  rule table's.
- **[NIT-1] `PressReporter` ignores clipping** (`bounds.contains`): a shelf name scrolled out
  of the strip keeps a ghost hit zone that closes the № float from unrelated right-clicks.
  **DISPOSITION: CONFIRMED — FIX** (`visibleRect.contains`; the reviewer's pin, red today).
- **[NIT-2] A cross-WINDOW Bookcase drag meets a per-window drag record** (no hairline, or a
  stale one, on a header drop that acts — W-5's reverse; needs two Bookcase windows).
  **DISPOSITION: RECORDED as an accepted corner** — #188(l); the app-wide drag record is hers
  to order.
- **[NIT-3] #188(k) named only part of its class:** the strip's "starred" word outlines for
  an already-starred book, then releases into `starBook`'s silent guard — the same false
  offer W-5 removed from the headers. **DISPOSITION: CONFIRMED — the class COMPLETES in the
  fix round** (the outline gates on the drop acting; the sweep-table discipline), and (k)
  carries the fold.
- **[NIT-4] F-BW-2 named the wrong commit** (the offender landed at 15b081d2; f8977039 moved
  it to :393) — the "pre-existing" substance VERIFIED true. **DISPOSITION: CONFIRMED — the
  name corrected at this seam in all four places; the one-line `.lineLimit` FIX itself is
  AUTHORIZED in the fix round** (the 19g class; `ChromeLineLimitTests`' standing red is the
  red-on-old, flipping green is the proof; round 2's eye covers the read-tier touch).
- **[NIT-5] Dark mode was never captured** (every capture and parity pin ran `.aqua`; R51's
  black room leaves the new face's header material, the popovers and the chips unmeasured
  there). **DISPOSITION: CONFIRMED — the fix round runs ONE `.darkAqua` pass of the rig +
  Bookcase mounts** and reports; the NOT-DONE line and HER RE-WALK list gain it.

## The clean bill (held)

The engine parity (pins + first-hand capture comparison + 244-unedited-tests), the switch
rule's purity, the dismissal mechanism's pass-through, the compose rider's shipped proof, the
reorder hiding through one value with the preference never rewritten, the W-5 trace against
the code, token-only fills, every red-on-old committed ahead, and the mobile-parity line —
all verified solid by the reviewer first-hand.

## HER RE-WALK list (the reviewer's three live-only items + one):

1. Does the № float leave the screen while the wing switcher's native menu is tracking?
2. Does the drag chip land under the cursor on a REAL drag (the fix round's margin fix
   included)?
3. Does a header's hairline light when a book from ANOTHER shelf hovers it in All?
4. Dark mode, one pass of the Library face + Bookcase (NIT-5).

## THE FIX ROUND (a FRESH session — the batch implementer ended past the ~500k cliff; spawned at this commit)

Scope: MAJOR-1 (the canvas margin + pin) · MINOR-1 (popover lifecycle + pin) · MINOR-3+F-BW-1
(the lesson-7 reword, seed-content AUTHORIZED, + the seed-text pin + the wait short-circuit +
the claim corrections) · MINOR-5 (the generalized switches, PROVISIONAL) · NIT-1
(`visibleRect` + pin) · NIT-3 (the starred-word false offer, the class sweep) · NIT-4's fix
half (the `.lineLimit` one-liner, `ChromeLineLimitTests` green) · NIT-5 (the `.darkAqua`
pass). Round 2 (fresh reviewer) re-reviews the fix diff.

### THE FIX ROUND (fresh session) — `opus-implementer`, 2026-10-05 ~22:20; LIVE STATUS from the first commit

**NOT DONE (first line, per the contract): PENDING — the round is running; this line is rewritten at the close.**

Preflight read in this session's own context (never delegated): CLAUDE.md + its auto-loaded canon;
this file whole; `notes/plans/librarywalkpolish.md` (the governing frame, R-LWP-1…6); the 17 file's
"17y B-WALK BRIEF" + "17y B-WALK RECORD" whole; QUESTIONS #188; KnownIssues' F-BW-1/F-BW-2 rows;
`notes/SessionResiliencyProtocol.md`; `notes/TEXTKIT2_NOTES.md` (NIT-4 touches a read-tier file —
one `.lineLimit`, nothing else). Worktree `~/dev/variorum-17y` ONLY; DerivedData
`App/Variorum/DerivedData/17y-wfix2`; no subagents; the author may be at the machine — headless
builds/tests only, no GUI driving, no store staged or restored, the running Debug instance (pid
from the 17y DerivedData) untouched. Captures: `notes/plans/17y-screens/bwalk/` (gitignored).
SEED CONTENT AUTHORIZED for this session for lesson 7 ONLY (the B-SEED/B-DEDUPE precedent).

| # | item | status |
|---|---|---|
| 0 | This LIVE STATUS | DONE (this commit) |
| 1 | MAJOR-1 — the drag canvas grows by a chip-sized margin per axis, chip at grab + margin (the reviewer's red pin first) | NOT-STARTED |
| 2 | MINOR-1 — the order popover closes on the board's disappearance, window resign-key, app deactivation (the reviewer's pin first) | NOT-STARTED |
| 3 | MINOR-3 + F-BW-1 — lesson 7 reworded to what 0.9.2 ships; the seed-text pin replaces the hollow half; the wait short-circuits; the three claim sentences corrected — A PRE-0.9.2 GATE | NOT-STARTED |
| 4 | MINOR-5 — the generalized scope-honesty rule (PROVISIONAL): Cards ⇒ Notes from any scope; a non-Notes scope inside Cards ⇒ List | NOT-STARTED |
| 5 | NIT-1 — `PressReporter` tests `visibleRect` (the reviewer's pin first) | NOT-STARTED |
| 6 | NIT-3 — the strip's "starred" word outlines only when the drop acts; the class sweep table | NOT-STARTED |
| 7 | NIT-4's fix half — `.lineLimit(1)` beside `.fixedSize()` at `NoteIndexColumn.swift:393`; `ChromeLineLimitTests` red → green | NOT-STARTED |
| 8 | NIT-5 — ONE `.darkAqua` pass of the List-face rig + Bookcase mounts; captures + report | NOT-STARTED |
| 9 | END suites (the batch's + Bookcase/Library families + tutorial books + ChromeLineLimitTests) + record close | NOT-STARTED |

**REVERT STATE: NO REVERT IN FLIGHT.**
