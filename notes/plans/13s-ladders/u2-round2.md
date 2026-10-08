# U2 ladder — ROUND 2 (cold review of the round-1 fixes, Fable, 2026-10-08)

**Scope:** the round-1 fixes only — do they close the findings, are the pins honest, do they
introduce anything new. Fixes under review: `33fd6b89` (MINOR-1 + MINOR-2, pins first) and
`2b71ce6b` (NIT-2); NIT-1 dispositioned record-as-accepted (the disposition's reasoning judged, not
the absence of a fix). **Anchor:** `13s-ladders/u2-round1.md` whole; the U2 RECORD sections of the
phase plan; the fix diffs read hunk by hunk; `Tour.swift`/`TourWalkTests.swift`/`TourOverlay.swift`
confirmed byte-identical between the fix commits and HEAD (e4f52b40).
**My evidence seat:** headless. I re-ran the tour suites (35/3 GREEN), re-verified BOTH pins
red-on-old myself by behavioural revert (`git checkout 33fd6b89^ -- Tour.swift`, pins kept):
`anAreaWanderDuringTheMiddleStepsRingsTheRoadBackToTheNote` **RED, 18 issues** and
`leavingSnippetsIntoTheFieldGuideFinishesWithoutYankingHerHome` **RED, 1 issue** — exactly the
record's counts — with the own-mode refinement arm and the non-guide yank arm green on old exactly
as the record says (they pin the refinement and the kept behavior, not the fix); restored, tree
clean. Full core suite at the end of the session: **2420 tests in 280 suites + 40 in 6 GREEN** —
the record's exact claim, reproduced. Mac side: no app suite pins the changed rule branches
(`TourTests.swift` pins copy strings only — grepped), so the fixes owe the next stage window no
new suite names, as the round-1 record claims.

## Findings

- **[MINOR] · `Sources/VariorumCore/Domain/Tour.swift:313–326` (`reduce(.next)`) with `:518–525`
  (`enter(.legEnd)`) and `:346` (`reduce(.facts)`'s finish check) · MINOR-2's fix closes the facts
  road but leaves the `.next` road into `.legEnd` at the guide silent — the guarded navigate is
  skipped and NO finish is emitted, because `finishAtGuide` is consulted only under `.facts`** ·
  Evidence (traced, then probed empirically with a scratch walk — deterministic in the pure rule):
  reach `.legSnippets` and let her report from the field guide arrive with
  `previousPlace != .area(.snippets)` — concretely, `enter(.legSnippets)`'s navigate has not yet
  produced its settled report when she ⌘K's to the guide (one observation cycle's race, or a
  coalesced report), so `advance(.legSnippets)` (line 467: the previousPlace gate) keeps her at
  leg 4 with `facts.place == .book(guide)`. The leg-4 card carries "next" (`hasNext`, line 86–90).
  Pressing it: `reduce(.next)` → `enter(.legEnd)` → `finishAtGuide(state)` is NON-nil → the
  navigate is skipped (the fix's new guard); `settle` advances nowhere; and line 346's
  `finishAtGuide` finish check runs only under `case .facts` — so the outcome is
  `state.step == .legEnd`, `effects == []`. Probe output on HEAD: `step=legEnd, state non-nil,
  effects=[]`, `rings=[[.sidebarArea(.bookcase)]]`, `isRoadBack=true` — the card describes the
  guide and says the road-back sentence over a Bookcase ring while she is SITTING at the guide,
  and the tour finishes only when some later facts change arrives (place is already the finish
  place, so nothing need change). Pre-fix the same press emitted `navigate(.area(.bookcase))` —
  the yank MINOR-2 complained of, but progress; the fix converts that corner's yank into a stall.
  Not stranded (End tour present; any facts report at the guide finishes via line 346; leaving and
  returning finishes), and the corner needs the race PLUS the next-press — a corner of a corner,
  said honestly. **Red-on-current pin:** walk to `.legSnippets`, report
  `.init(place: .book(guide))` (previousPlace the Pool), `send(.next)` — expect
  `state == nil` and `effects == [.finish(completed: true)]`; today it yields `.legEnd` and `[]`
  (probe above; the old rule yields the navigate — red there too, differently) · Fix: mirror
  line 346's two-line check after `settle` in `reduce(.next)` (or hoist the
  step==.legEnd/finishAtGuide epilogue to cover both events), plus the pin.

No other finding. MINOR-1's fix is complete against its widened scope: every branch of
`ringGroups`' new fallbacks and `isRoadBack`'s mirrors was traced pairwise
(write/makeTake/takeIcon/takesMode/deeperModes/placeFollows/downAndUp — off-note, in-note
wrong-mode, in-note own-mode, panel-open) and they agree in every reachable state; the only
constructible mismatch (`.takeIcon` with `panelOpen` true in a non-Write mode: panel ring with
`isRoadBack` true) is unreachable from the real window — `TourEngine.facts` (TourEngine.swift:239)
assembles a caret ONLY when `noteMode == .write` — so no pin could go red through the app's facts
road; hollow by the guard, recorded here rather than raised.

## The round-1 dispositions, judged

- **MINOR-1 — truly closed.** The fix implements exactly the adopted widened scope (the
  implementer's `.deeperModes`/`.placeFollows` additions, plus `.downAndUp` and the in-note rail
  fallbacks for `.takeIcon`/`.takesMode`); `roadBackRow` is the legs' own shape;
  `tourNoteID` is provably non-nil at every road-back step (set in `remember` at `.insideBook`,
  the only entry into `.write`, before any fallback can ask). The refinement (fires ONLY off the
  note) is honored and pinned by the own-mode arm. The overlay's sentence is additionally gated on
  a LIT ring (`TourOverlay.swift:170` — `isRoadBack && !spotlight.lit.isEmpty`), so even an absent
  Open-strip row degrades to silence, never to a contradicting sentence.
- **MINOR-2 — closed on its reported road; the residual above is the adjacent `.next` arm.** The
  pin's first arm proves the straight Snippets→guide exit now finishes with
  `[.finish(completed: true)]` alone; the second arm pins the kept P-U2-7 yank. The fix also makes
  the degraded `fieldGuideID == nil` landing consistent (any-book finish without the yank) — a
  strict improvement, noted.
- **NIT-1's record-as-accepted — the reasoning HOLDS.** A3's one-anchor reading legitimately
  covers both on-screen copies; a first-reporter-wins rule would trade two honest rings for a
  scroll-order-dependent single one (statefulness in the spotlight for an edge the walk never
  reached), and which copy should carry the ring is a by-eye product call — correctly routed to
  the merge's QUESTIONS beside P-U2-9 rather than ruled here. Accepted as dispositioned.
- **NIT-2 — closed.** The clear sits inside the existing `TourOracle.overlay === engine` guard
  (TourOverlay.swift:94–100), so a new mount's frames survive an old overlay's late disappear and
  a dead overlay's frames never leak into the next pin. DEBUG-only, no product path; no pin owed —
  the honesty rule honored.

## Clean bill (checked this round, found solid)

1. Both pins verified red-on-old by my OWN behavioural revert — issue counts (18 + 1) and the
   green-on-old arms exactly as the record claims; the pins assert the fixes' mechanisms, not
   incidentals.
2. The suite claim reproduced exactly: full core `swift test` 2420/280 + 40/6 GREEN on HEAD.
3. Tree discipline: the fix commits touch only `Tour.swift`, `TourWalkTests.swift`,
   `TourOverlay.swift` + the ladder file; U1b's unstaged seeder/Sync-adjacent work untouched by
   them; all three files byte-identical at HEAD.
4. No Mac suite pins the changed branches (copy-string pins only), so nothing app-side goes red at
   the next stage window from these fixes; the one open residual (the end card's live re-walk on
   the fresh binary) remains correctly tracked in the U2 RECORD, owed to the next window.
5. Nothing under `Sources/VariorumCore/Sync/`, no store write, no editor-seam file in either fix;
   no literal colour; no new door, no copy change (the card table untouched by the fixes).

**Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 0 NIT.** No round 3 is earned. The round-1 fixes are
honest and well-pinned; the one finding is the unclosed `.next` arm of MINOR-2's own corner —
small, deterministic to pin, one mirrored check to fix — left to the orchestrator's disposition
(this seat was not authorized to fix in round 2).

## THE IN-ROUND CLOSURE (the cross-model exchange and the fix, same session — 2026-10-08)

**The implementer's response: AGREE, zero dispute, fix-now.** Its independent trace confirmed the
mechanism exactly (the pre-settle report keeps her at `legSnippets` at the guide; `reduce(.next)`
never consults `finishAtGuide`; `ringGroups` then points her AWAY from the finish place — "a
stalled tour at the finish line, the exact contradiction A7 exists to prevent"), confirmed the
proposed fix as right and minimal, and verified the only other road into `.legEnd`
(`.choose(.keepGoing)` → `.legStar`) cannot reach it in one press — which matches my own trace
(`advance(.legSnippets)` requires a fresh report, so `settle` can never cascade through leg 4
under `.next` or `.choose`).

**Final call (the reviewer's): CONFIRMED — FIXED (5a119f3a).** `reduce(.next)` mirrors the
`.facts` arm's two-line `finishAtGuide` check after `settle`: a "next" pressed at leg 4 while she
already sits at the field guide finishes with `[.finish(completed: true)]` alone; the at-Snippets
press keeps P-U2-7's designed yank home, pinned in the same test's second arm.
**Pin red-on-old, watched:**
`TourWalkTests.nextAtLegFourWhileAlreadyAtTheGuideFinishesThereInsteadOfStalling` written FIRST
and run against the unfixed rule — **RED, 2 issues** (the state survived, no finish; exactly the
probe's stall), the kept-yank arm green on both sides (it pins the designed behavior, not the
fix); **GREEN after**. Tour suites 36/3 GREEN; full core suite at the close
**2423 tests in 280 suites + 40 in 6 GREEN** (the +3 over this round's opening run = this pin +
U1b's in-worktree core pins, which build beside this ladder; nothing red anywhere). Tree
discipline: only `Tour.swift` (one hunk) and `TourWalkTests.swift` (one hunk) staged — each file's
diff checked hunk-by-hunk against U1b's concurrent edits before the add; U1b's unstaged work
untouched.

**THE U2 LADDER CLOSES: two rounds + this in-round closure, no round 3.** Every finding across
both rounds carries a written disposition: round 1's two MINORs fixed (33fd6b89), NIT-2 fixed
(2b71ce6b), NIT-1 record-as-accepted (to the merge's QUESTIONS beside P-U2-9), round 2's one
MINOR fixed (5a119f3a). The one open residual remains the end card's live re-walk on the fresh
binary — the next stage window's, tracked in the U2 RECORD.

## F-U2-W-3 (the fresh-store walk's finding, routed to this seat — 2026-10-08)

**The trace, whole.** The coordinator's popover-vs-direct hypothesis is FALSIFIED: both roads run
the identical door (`ContextBar.bookDoor` → `onOpenBook(first.id)` / the list row → the same
closure → `RootView.openBook` → `bookAscent` + `adopt(.reading)`). And option (a)'s mechanism —
the direct-road entry selecting the toured note — ALREADY EXISTS in the model, link by link:
`BookView.takeAscentRequest` → `BookViewModel.requestReveal` (BookViewModel.swift:1175 — it seats
`standingAnchorPostID` beside the reveal), `carryPlace(from: .outline)` →
`BookAnchor.currentPost(.outline)` = `focusedPostID ?? standingPostID` (BookAnchor.swift), and the
Index's `landOrSeed` (BookIndexView.swift:712) lands the reveal OR seeds from
`focused ?? standing ?? entries[0]`, with `select` ALWAYS reporting `noteIndexSelection` (the
box's "is a note selected", by its own doc). Every static interleaving I could construct —
Outline-first, Index-first, entries-late, the departing Outline's reveal-watcher
(BookView.swift:1714) eating the carry — still ends SELECTED through the standing fallback. The
walked empty box is therefore a VIEW-LIFECYCLE race (the one nil-writer is
`BookIndexView.onDisappear`'s `noteIndexSelection(nil)`; a new-appears-before-old-disappears
remount ordering is the plausible culprit) that this headless seat cannot reproduce or pin.

**The choice, stated (the coordinator asked): (b), the rule-side fallback — because (a) is
unpinnable honestly.** A model-level pin for (a) ("ascent → carry → Index selected") is GREEN on
the old tree — the model already does it — so it would be hollow under the guard, and the actual
racing link cannot be named without the stage. (b) is deterministic, headlessly red-on-old, and
robust to WHICHEVER link raced: whenever the box holds no note — for any reason — the beat keeps
a ring and earns its line. The race itself stays recorded here for the stage window's eyes, not
guessed at.

**The fix (eea127a7).** `Tour.Facts` gains `bookNoteSelected` (the box holds a note, selected or
live — a window fact of exactly `bookNoteLive`'s class, produced beside it in `TourPlaces.facts`
from the same published box report, book places only; `RootView.tourBookNoteSelected` is the
`tourBookNoteLive` twin reading `report.state.postID != nil`). `ringGroups(.downAndUp)` at a book
rings the step's own `.noteBoxEditHere` ONLY while the box holds a note; an empty box rings the
toured note's own Index row with the Index tab behind it — step 9's exact group shape, and the
row is the walk's VERIFIED recovery (clicking it selects, drops into index-edit AND advances —
the reducer's facts already handle the act, as the walk confirmed). `isRoadBack(.downAndUp)`
mirrors (`!bookNoteSelected` at a book), so the road-back line shows exactly when the fallback
rings. Step 9's own ring already fell to the row+tab group (present behavior, unchanged); its
sentence's truth in the raced state returns with the race's own fix, owed to the stage window.
**Pin red-on-old, watched:**
`TourWalkTests.stepTenInABookWithAnEmptyNoteBoxRingsTheNotesIndexRow` written FIRST — **RED, 2
issues** on the old rule (no ring group, no line), the holding-box arm green on both sides (it
pins the kept edit-here ring); **GREEN after**, with ONE justified fixture edit (the main-leg
walk now SAYS `bookNoteSelected: true` where it always implicitly stood). Tour suites **37/3
GREEN**. The full core run's only reds are U4's uncommitted mid-sweep savepoint-wording pair
(`SavepointRuns.swift` + `SavepointCadenceTests.swift`, both dirty in this shared tree —
attributed, untouched). The app half (four small edits, every Mac callsite kept compiling by
defaults) is parse-checked at this seat; the Mac compile runs at the implementer's sanity pass
and the stage window, and the fix's live re-walk rides the final stage window as routed.
