# VX-601 — Run: takes & editor quick fixes

**STATUS: OPEN — kicked off 2026-10-27 (architect-phase).**
Ticket: VX-601 · Project: v1 release readiness · Branch: `vx-601-run-takes-editor-quick-fixes` ·
Worktree: `~/dev/variorum-vx-601` · Machine: the Pro · Stage/walks via **oct27coordinator**.
Split out of VX-439 at her word (2026-10-27): the Takes/editor cluster isolated under the Fable
reviewer the editor seam requires. **VX-421 is a LAUNCH GATE** (her release-gates ruling 2026-10-26).

**Her kickoff words (2026-10-27, verbatim):** *"VX-601. carry along this rider: VX-577 expand-all
takes in slot split. Contact oct27coordinator for your stage / walk needs."*

**Cast:** Fable orchestrates (this session) and cold-reviews (`fable-reviewer` — the editor seam);
`opus-implementer` per batch, fresh session each, xhigh. Cross-model ladder rules apply (the
reviewer makes the final call; the implementer applies confirmed fixes; FINDER-FIXES per her
2026-10-13 ruling). Confirmed at the kickoff sitting unless redirected there.

**The members (the SUB-ISSUE LISTING, read live at kickoff 2026-10-27 — the VX-548 lesson; TWELVE
after the sitting):** VX-421 · VX-427 · VX-428 · VX-429 · VX-574 · VX-586 · VX-594 + rider
**VX-577** (her kickoff word) + the sitting's seated riders **VX-592 · VX-248 · VX-321 · VX-337**
(R-601-6; VX-337 bounded). Pin-before-fix binds PER MEMBER; the cold review covers the whole diff.

**Concurrency (the in-flight table, 2026-10-27):** VX-620 (MCP door — no overlap), VX-562 (book
Outline + a read-only viewport→block geometry read — its row flags shared read-tier files with
this run: coordinate at merge; closeouts serialize), VX-623 (WalkKit only — no overlap). No
`Sync/`, no custody, no schema anywhere in this run.

---

## Binding principles — the 13b constitution (P-1…P-9, carried per the architect-phase skill)

The skill's P-1…P-9 block and its application notes bind this run verbatim (the skill file is
`.claude/skills/architect-phase/SKILL.md`; the provenance `notes/plans/phase-13b-make-it-work.md`).
The ones this run leans on hardest:

- **P-1 (one capability registry):** VX-594's new door is DECLARED (a take-card door is the
  `.surface` case, the 3D precedent), never an inline if.
- **P-2 (fire-and-DO):** every door this run adds or re-gates performs or delivers the real refusal.
- **P-3 (one text surface, one liveness authority):** `PaneSurface` is the one pane component;
  `PaneTextAuthority` the one liveness brain; VX-421's fix must not grow a second liveness or undo
  mechanism beside it — it extends the pane component's own lifecycle.
- **P-7 (find bugs before she does):** red-on-old pins verified by revert, per member.
- **P-8:** P1–P3 perf invariants bind (VX-428's seeded expansion must stay viewport-proportional).

## Preflight (done 2026-10-27, this session — reading never delegated)

CLAUDE.md + auto-loaded canon · the master plan incl. in-flight · the workflow-transition record ·
`notes/TICKETS.md` (main's copy) · `notes/QUESTIONS.md` open items (latest #244; this run's bundle
will be **#245**) · `notes/SessionResiliencyProtocol.md` · **`notes/SurfaceContracts.md` in full**
(The note / Takes is the touched surface) · **`notes/TEXTKIT2_NOTES.md` in full** (the editor seam;
batch briefs name it required reading) · the live Linear tickets with their scout/pricing comments.
SyncSpec / MCPSpec / CastleRules: not touched by this run.

---

## The members — mechanism, plan, acceptance evidence

### VX-421 — ⌘Z after deleting a take in Takes crashes the app (BUG · Pre-launch · LAUNCH GATE)
**The ticket's traced mechanism (not yet reproduced — the pin confirms):** take panes from
`PaneTextView.makeTakeSurface()` (`PaneSurface.swift:874`, used `:1342`) have `allowsUndo: true`
and no `undoManager(for:)`, so TK2 typing/paste undo lands on the WINDOW's shared `UndoManager`.
Deleting the take tears the pane down (`dismantleNSView` → `coordinator.uninstall()`, `:1587`)
without clearing those actions; `NSUndoManager` does not retain targets; the next ⌘Z messages the
freed object (`EXC_BAD_ACCESS` in `popAndInvoke`). VX-179 U3-g measured the class on the comment
field: `removeAllActions(withTarget:)` does NOT reach TK2's registrations — which is why
`CommentTextArea` and `CaptureTextView` own their undo managers. The take panes never got the
treatment.
**Fix shape (architect's recommendation, her call at the sitting):** each take pane owns its
`UndoManager` (the proven `CommentTextArea`/`CaptureTextView` road) — ⌘Z in a take pane undoes that
pane's own typing only; teardown takes the history with the manager by construction. The
alternative (end the window-manager history at teardown / bound-take change) is recorded, not
preferred: it keeps cross-pane history mixing and must chase every teardown road.
**Related:** VX-248 (the live pane's bound-take class) — SEATED at the sitting and batched beside
this fix; the bound-take-change occasion (a re-bound pane must not keep the old take's undo
history) is the shared seam the two fixes meet on.
**Pin (red-on-old, revert-verified):** offscreen — a take surface in a window, register typing
undo on it, release the view, run undo (zombie/crash on old; clean no-op or pane-scoped undo on
new). Plus the in-app shape if stageable: type/paste in a take pane, delete the take, ⌘Z.
**Acceptance:** the pin pair + the walk repro of her exact gesture (paste long text, delete take,
⌘Z — app lives; ⌥⌘Z still restores the take).

### VX-427 — bottom-bar word count: count the take being typed in (BUG · the tester's ask)
**The scout's finding (ticket comment, 2026-10-18):** the Takes bar already shows "Nw take"
(`TakesBottomBar.swift:586-629`) but `:612-618` counts the COLUMN'S PICK
(`model.resolvedTake(column:slot:)`), not the focused pane's `variantID` — wrong in a bloomed fan,
exactly the complaint. Fix: count the focused pane's take via
`authority.text(variantID:…)` (`PaneTextAuthority.swift:146`); `model.focusedPane` already carries
`variantID`. Write needs nothing (its count is already the shown take's live text).
**The optional second step** (a `take` field in `WordCounts` + a `CountsFace` case in the shared
click cycle) is HER CALL at the sitting — it changes the cycle she's used to and the face is shared
by both bars (never drawable in Write, falls through).
**Pin:** red-on-old — a bloomed fan, focus in a non-picked take, the bar's take count reads the
focused take's words (old: the picked take's).

### VX-428 — takes stay open across a brief mode switch (IMPROVEMENT · her seating = the call; state was Needs Lillian)
**Mechanism (the pricing scout):** the board remounts per mode switch (`PostDetailView.swift:430-479`);
`TakesBoardLayout.expandedBlocks` is per-mount, so the open-fan set dies with the mount.
**The road (the VX-170 precedent, `takesShowFilters`):** the session's `EditorRouter` survives
remounts and already holds per-note session memories. Add `takesExpandedBlocks: [String: Set<String>]`,
seed `board.expandedBlocks` at `TakesViewModel` construction when `landingEnabled` (Write's embedded
panel stays out), write back from the mutators or `teardown()`, prune ids missing from the first
projection.
**This is a RULING** — the layout doc's "session-only, mount-only" line (`TakesBoardLayout.swift:347`)
is the Takes plan's letter; moving expansion to the per-note session home is an update in the spirit
of the per-note session memories that grew up after it (her own triage note on the ticket) — **cite
R-VX170-5**; her ratification at the sitting makes it so.
**Her requirement (verbatim, from the ticket):** *"any relevant performance or rendering
calculations need to be made and we need to make sure this doesn't degrade the app in other ways
(like getting to the right location)"* — so: MEASURE the remount cost of seeding N expanded fans
before first paint (expanded rows change heights and the margin rail), and PROVE scroll restore /
entry landings still hit the right block with the seeded set (the construction-time-fact lesson,
`TakesBoardView.swift:178-187` — the seeded set must be in place before the first article geometry
report).
**Pins:** state-transition pins on the memory (seed, write-back, prune); the landing pin with a
seeded set; the measured numbers in the batch record.

### VX-429 — a selection can't start at the caret's own position in Takes (BUG · PROBE-FIRST)
**The scout: mechanism NOT yet pinned.** The asymmetry: a press at the caret fires no
selection-change at mouseDown, so the first notification lands MID-DRAG with a non-empty range —
the VX-296 caret-settle restyle → `remeasure()`/`publishHeight` path (`PaneSurface.swift:1994-2025,
:1355-1365`) runs inside AppKit's tracking loop. Suspect 2: the same-value `isEditable`/
`noteLiveness` writes on every `updateNSView` pass (`:1428-1429`).
**The binding order:** one instrumented run FIRST (log `selectedRange` before/after
`super.mouseDown`, count settles during one drag in `PaneTextView.mouseDown`, `:763-799`) — the pin
is built as the confirm; red confirms and the fix proceeds, green/other means record-only and the
ticket re-states the truth. No fix without the trace.

### VX-574 — Takes renders in a lighter font than the rest of the app (IMPROVEMENT · Pre-launch)
Her words: *"I need Takes to not be a weird light font compared to anything else."* Probe where the
take panes' font/weight diverges from Write's (the voice tokens are the one vocabulary — P-8; no
literal fonts outside the token layer). Fix at the token consumer, not per-view. Evidence: a
side-by-side walk shot Write vs Takes, same note, both voices; a token-level pin if the divergence
is in code rather than taste.
(Her same sentence's other half — the quick-menu dropdown — is VX-433's question, NOT this run's.)

### VX-586 — Takes says "block 1/10" instead of the block ID (IMPROVEMENT)
Her words: *"change it from the block ID showing in takes mode to block 1/10."* The face that today
shows the raw block id shows "block i/N" (position among the note's blocks). Find every Takes face
that speaks the raw id; one wording brain, not scattered strings. Pin on the label; walk shot.

### VX-594 — branch directly from a not-chosen take (IMPROVEMENT · PROBE-FIRST)
*[removed for publication]*
a 'create branched take' option, or so long as your cursor is in the take, it would automatically
duplicate that one)."* `branchVariant` already takes ANY take as parent — so this is likely a
missing DOOR, not a missing operation. Probe what the […] (take-card) menu offers today and what
the existing branch door binds to. The DOOR SHAPE is her sitting call (options in the sitting
record). P-1: the chosen door is registry-declared (`.surface` case for a card-inline door).
**Pin:** the door exists and branches from the named (not-chosen) take — parent = that take.

### VX-577 — expand all takes is missing in slot split (RIDER, seated at kickoff · IMPROVEMENT)
Her words: *"where is expand all takes when you're in slot split?? you still need it lowkey."*
The gate is deliberate: `TakesViewModel.offersExpandAll` (`TakesViewModel.swift:295-297`) excludes
`.slotSplit` citing **R25's agreed half** ("slot split IS a whole-post fan presentation already") —
but blocks still bloom individually in slot split (`TakesLensFilterController.swift:192`), so the
door has meaning there and her note SUPERSEDES that half of R25 (recorded at the sitting; the canon
delta lands at closeout if any contract line names it — the Takes contract line in SurfaceContracts
does not enumerate the gate, so likely record-only).
**Build:** `offersExpandAll` includes slot split; verify `expandAll(fannedBlockIDs:)` and ⎋/close-all
behave in slot split (follow-the-scroll, page offsets). **Pin:** the door offered and acting in slot
split; red-on-old on the gate.

### VX-248 — live pane adopts the new take's text when its bound take changes (DEBT · seated R-601-6)
**Her ruled root fix (QUESTIONS #217, 2026-10-13: "I think that we should probably fix it — ticket
it").** The class: Takes/Lenses board cells keep a stable on-screen identity while the take they
show can change (choose, step, mint). A LIVE pane is buffer-authoritative and never adopts
projection text (`PaneSurface.swift:1514-1524`) — so a cell re-keyed while live keeps the OLD
take's words wired to the NEW take, and the next keystroke saves them over it (silent; one writer,
never a sync conflict). VX-222 (the adopt end-rule) and VX-227 (the parked follow + transit rule)
close every reachable case today by never letting a cell be live across a re-key. **The fix:** when
a live pane's bound take CHANGES (a re-key is a RE-BIND, not an edit), it adopts the new take's
text — the ratified bend of P-3's "a live pane never adopts projection text" (her ratification IS
this ticket); the caret landing moves in `noteLiveness` after the text write. **Pins:** VX-222's
and VX-227's contamination pins stay green and become redundant-by-construction; a new pin on the
re-bind adoption itself (red-on-old: the stale words survive a forced re-key on old code). The
record of the F2(b) ruling: `notes/plans/fixes/vx-214-settings-launch-polish.md`.

### VX-592 — dragging a selection out of the live editor doesn't work (BUG · Suspected · PROBE-FIRST · seated R-601-6)
*[removed for publication]*
work."* Probe: dragging a selection from the FOCUSED LIVE pane vs the read-tier panes (where it
works). Same binding order as VX-429: instrumented trace first, pin as the confirm, fix only on
red, record-only on green/other.

### VX-321 — "archived · n" where the list header reads "archived takes" (WORDING · seated R-601-6)
VX-154's rider fixed the take panel's archive receipt to match its own list header; the Move Take
into a Block Below receipt (`TakeStructureCopy.movedNote`, shared with Write) still says
"archived · n". Make it speak the header's words. Pin on the receipt string.

### VX-337 — two load-dependent Takes flakes (TEST-ONLY · seated R-601-6 · BOUNDED, her word)
`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt` (`:1803`) and
`TakesBoardSoakTests.randomizedBoardSoakHoldsEveryInvariant(seed: 21)` (`:168`) fail only in the
whole-Mac-target run; both pass alone twice. The VX-167 load-dependence class. **Bounded:** one
timeboxed trace under whole-target load (the run's own full-suite window is the natural occasion);
a fix to test or code if the trace yields; otherwise the findings land on the ticket and it stays
open — her words: *"id try on 337 but bound your efforts on that one."*

---

## The batches (one acceptance unit per implementer session; strictly sequential; set at the sitting)

- **BATCH A — pane LIFECYCLE (the editor seam):** VX-421 (per-pane undo managers, R-601-1) +
  VX-248 (the bound-take adoption root fix — her ruled P-3 bend; VX-222/VX-227's contamination
  pins stay green and become redundant-by-construction). One coherent unit: what happens to a live
  pane when its take is deleted or re-bound. Required reading: this file's sections,
  `notes/TEXTKIT2_NOTES.md`, SurfaceContracts "The note", the environment traps.
- **BATCH A2 — pane INPUT probes (the editor seam):** VX-429 (selection at the caret —
  instrumented trace first) + VX-592 (drag a selection out of the live editor — probe: focused
  live editor vs read-tier panes). Both probe-first: the pin is the confirm; green means
  record-only.
- **BATCH B — the board and its doors:** VX-428 (the session memory, R-601-2, her measurements +
  landing proof) + VX-577 (the expand-all gate in slot split) + VX-594 (both doors, R-601-4).
- **BATCH C — bars, chrome, wording, the bounded flake:** VX-427 (the focused-take count,
  R-601-3) + VX-574 (the font) + VX-586 (block i/N — route through `BlockLineLabel`, the one
  wording brain; the bar's context label already uses it, 13g R5-4) + VX-321 (the receipt word) +
  VX-337 (BOUNDED: one timeboxed trace under whole-target load; findings to the ticket either way).

Order: A (the launch gate) → A2 → B → C. Fresh implementer per batch. The ladder runs ONCE over
the run's whole diff (fable-reviewer, `notes/REVIEW_PROMPT.md` verbatim, zero framing), rounds per
the skill.

## The ledger (every row owned; statuses live here)

| # | Item | Status |
|---|---|---|
| 1 | VX-421 crash fix (per-pane undo) + pins | NOT-STARTED (batch A) |
| 2 | VX-248 bound-take adoption + VX-222/227 pins green | NOT-STARTED (batch A) |
| 3 | VX-429 instrumented probe → fix or record | NOT-STARTED (batch A2) |
| 4 | VX-592 drag probe → fix or record | NOT-STARTED (batch A2) |
| 5 | VX-428 session memory + measurements + landing proof | NOT-STARTED (batch B) |
| 6 | VX-577 expand-all in slot split | NOT-STARTED (batch B) |
| 7 | VX-594 the […] door + caret-following ⌘T | NOT-STARTED (batch B) |
| 8 | VX-427 focused-take count | NOT-STARTED (batch C) |
| 9 | VX-574 font weight | NOT-STARTED (batch C) |
| 10 | VX-586 "block i/N" via BlockLineLabel | NOT-STARTED (batch C) |
| 11 | VX-321 receipt wording | NOT-STARTED (batch C) |
| 12 | VX-337 bounded flake trace | NOT-STARTED (batch C; bounded, her word) |
| 13 | The kickoff sitting record | DONE 2026-10-27 (R-601-1…6) |
| 14 | The ladder (whole-diff, fable-reviewer) | NOT-STARTED |
| 15 | Closeout (canon deltas · the #245 bundle · tickets · handoff) | NOT-STARTED |

## Environment traps (every batch brief carries this section verbatim)

- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test
  host matches mid-run). Real-store instances by STORE, never quit/kill one; no Release builds or
  `/Applications` refreshes while one lives (and none at all this run without her word, via
  oct27coordinator).
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test`
  with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's count
  INCLUDES skipped tests — read the `skipped:` lines. `build-for-testing` compiles without running.
  NEVER add a custom build configuration (non-"Debug" names build the packages Release and strip
  the DEBUG oracles). zsh `pipestatus`.
- **THE STAGE (oct27coordinator's protocol, 2026-10-27 — binding; only the ORCHESTRATOR talks to
  the coordinator, subagents relay through it):** every `xcodebuild test` run, walk, Debug launch
  and dev-store act runs REQUEST → READY → GO — the orchestrator never claims the stage itself,
  and a FREE stage is never an invitation. A REQUEST names the kind (test batch / walk / Debug
  launch), minutes, and the claim name, sent early; READY is a separate ping when it can start NOW
  (keep building headless while waiting); GO arrives by message with the exact claim line; RELEASE
  is `Tools/stage release --who <claim>` plus one result line to the coordinator giving EXECUTED
  test counts (VX-604: a lone-suite run can falsely pass; 0 ran = no verdict), the dev-store
  posture at release, and instance + sim state. `Tools/stage renew` RESETS expiry to now+N — tell
  the coordinator BEFORE renewing. Headless `swift build`/`swift test` and `xcodebuild
  build`/`build-for-testing` never need the stage. Instance guards: the strict forms
  `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`, plus `xcrun simctl list devices booted`.
  After every Debug launch, dismiss a What's New sheet if one shows.
- **The dev store this wave (her standing rules via the coordinator):** library e11e5233, HELD
  since 10-20 (the "as of October 20, 2026" banner), signed out, Study voice. **NEVER press Resume
  Sync** (one press consumes the hold). Restore exactly as found. This run's walk REQUEST names
  what it adds (the notes/takes for the ⌘Z-after-delete-take repro) and how it leaves (Trash vs
  removed); the crash repro kills the Debug app mid-act, so the REQUEST also says how we confirm
  the store reopens clean and still held afterwards.
- Walks: `cliclick` + `Tools/WalkKit/` on the DEV-STORE Debug build only
  (`io.lduarte.Variorum.debug`), under this run's held claim — **simulated-input walk steps are
  driven by an OPUS walker under the claim** (Fable trips the classifier there; her standing
  safeguard). This run plans no credential/posture window (no Castle, no keys, no reset).
- Three sibling efforts are in flight (VX-620, VX-562, VX-623) — all work from THIS worktree only;
  `~/dev/variorum` stays main; the shared ledgers are touched only at merge moments by the merging
  session. Backups: A1 into `Backups/safety-copies/` before ANY real-store touch (none planned).
- Commit per piece, push after every commit, NO attribution trailers (her rule). Foreground waits
  only for subagents (poll with `grep -q … && break; sleep 5`, never `tail -f | grep -m1`).
  Screenshots in gitignored dirs; never `git checkout` over uncommitted work.
- TextKit 2: never touch TK1 APIs; attribute stamps clamp to the VERDICT's range; a frame read
  with `options: []` is a position only in `.layoutAvailable`; `usageBoundsForTextContainer` is a
  high-water mark — `PaneMeasurement` is the one measurement brain. `notes/TEXTKIT2_NOTES.md` is
  required reading for batch A (and any batch that touches pane geometry).

## THE SITTING RECORD (kickoff, 2026-10-27)

**R-601-1 (VX-421, the ⌘Z meaning):** per-pane undo managers — her pick of the recommended arm.
Each take pane owns its `UndoManager`; ⌘Z undoes only the pane the cursor is in; a deleted take's
history goes with its pane by construction. The shared-history-cleared-at-teardown arm is the
recorded alternative, not built. The bound-take-change occasion (a pane re-bound to a new take must
not keep the old take's history) rides the fix either way.

**R-601-2 (VX-428):** build it in this run — her pick of the recommended arm, confirming her
seating. The VX-170 road (per-note session memory on `EditorRouter`), citing R-VX170-5; her
verbatim perf requirement rides batch B (the seeded-remount measurement + the landing/scroll
proof). The ticket leaves Needs Lillian at the batch's start.

**R-601-3 (VX-427, settled across three asks):** the bar follows the caret — the existing "Nw take"
unit counts the take being typed in (the focused pane's own take, never the column's pick), per
keystroke. The click-cycle take face is DROPPED; the per-card always-visible count was offered and
DECLINED (her pick of "Bar follows caret"). Her clarifying words, verbatim: *"I think the whoel
idea was to beable to count the take that you're typing in - is that not what is being done? why is
the take face in the bar's shared click cycle an option ?"* and *"what if the count fix exactly ?
where do you see the take unit? this is so you can easily see how many words each take is at"* —
both answered in the sitting (the unit lives in the Takes bar's trailing counts cluster,
`TakesBottomBar.swift` `wordCounts`; the bug is `resolvedTake(column:slot:)` at `:612-618`).

**R-601-4 (VX-594):** BOTH doors — the take card's […] menu gains "New branched take"
(registry-declared, the `.surface` case, acts on the named take), AND ⌘T / the take-scoped branch
doors follow the caret: the focused pane's take is the branch parent when the caret sits in one;
no focus falls back to today's chosen-take behavior. Her words: *"I think the menu door + caret
following makes the most sense - by that, do you mean if your caret is in a particular take the
keyboard shortcuts will work for that too?"* — confirmed as exactly that semantics, her pick
"Yes, both as described".

**R-601-5 (cast):** standing default confirmed — Fable orchestrates + `fable-reviewer` on the whole
run diff; fresh `opus-implementer` per batch at xhigh; cross-model ladder rules.

**R-601-6 (riders):** ALL FOUR seated as sub-issues — VX-592 (drag from the live editor,
probe-first), VX-248 (the stale-live-pane root fix — HER RULED bend of P-3's never-adopt rule,
QUESTIONS #217's "I think that we should probably fix it"; pins VX-222/VX-227 stay green and become
redundant-by-construction), VX-321 (the receipt wording one-liner), VX-337 (the two load-dependent
Takes flakes) — VX-337 with BOUNDED effort, her words: *"id try on 337 but bound your efforts on
that one"* — one timeboxed trace under whole-target load; if it doesn't yield, the findings land on
the ticket and it stays open, no heroics.

**The run after the sitting: twelve members.** VX-421 · VX-427 · VX-428 · VX-429 · VX-574 ·
VX-586 · VX-594 · VX-577 · VX-592 · VX-248 · VX-321 · VX-337.

---

## BATCH A RECORD — pane LIFECYCLE: VX-421 + VX-248 (implementer: opus-implementer, 2026-10-27)

**NOT DONE (first line, kept current):** everything below the trace — pins, fixes, builds, the
suite window (the orchestrator's: this session never runs `xcodebuild test`), the walk (Opus walker
under the orchestrator's claim). No behavioural revert is in flight.

**LIVE STATUS**
- Reading — DONE: this file in full (members, batches, ENVIRONMENT TRAPS, the sitting record
  R-601-1/R-601-6), `notes/TEXTKIT2_NOTES.md` in full, `notes/SurfaceContracts.md` "The note",
  `notes/SessionResiliencyProtocol.md`, the VX-214 record's VX-222/VX-227 trace + the F2 ruling
  (`notes/plans/fixes/vx-214-settings-launch-polish.md` §BATCH 4 + ARCHITECT RULING), and the code:
  `Surface/PaneSurface.swift` (whole), `Surface/PaneTextAuthority.swift`,
  `Core/Views/CommentTextArea.swift` (the U3-g road), `Core/Views/CaptureTextView.swift` (VX-193),
  every `PaneSurfaceView(` host, `TakesViewModel`'s focus/park/end-rule section, the pins
  `PaneSurfaceTests`, `PaneFindFaceTests`, `CommentTextAreaTests`' undo pin.
- Trace — DONE (below); both members' mechanisms CONFIRMED by my own read; no divergence from the
  briefed mechanisms (one widening for VX-421, stated).
- Pins — NOT-STARTED.
- Fix VX-421 — NOT-STARTED.
- Fix VX-248 — NOT-STARTED.
- Builds (pre / post / per-member reverts) — IN-PROGRESS: the pre-fix baseline build-for-testing
  into `App/Variorum/DerivedData/vx601a-pre` started (the pins join it incrementally).
- Self-assessment + READY-FOR-SUITES — NOT-STARTED.

**THE TRACE (pre-fix line numbers, `PaneSurface.swift` at c2a0b833).**

*VX-421 — CONFIRMED, and WIDER than the ticket's Takes cards.*
1. Every `PaneSurfaceView` mounts through ONE representable whose `makeNSView` builds the view with
   `PaneTextView.makeTakeSurface()` (`:1342` → `:874` → `makeSurface(inset:allowsUndo: true)`,
   `:822` `view.allowsUndo = allowsUndo`). The read tier proper (`ReadPostView`) is the only pane-kind
   surface that does not (`makeReadSurface`, `allowsUndo: false`, its own coordinator).
2. The view's delegate is the representable's `Coordinator` (`:1351`), which implements no
   `undoManager(for:)` — so NSTextView registers every typing/paste undo on its WINDOW's manager.
3. Teardown is `dismantleNSView` → `coordinator.uninstall()` (`:1587`, `:1893-1900`): the canary
   disarms, the publisher invalidates, the view reference drops — nothing touches undo.
4. So the window's manager keeps actions aimed at the torn-down pane. `NSUndoManager` does not retain
   targets; ⌘Z travels `undo:` → `NSWindow` → the first responder's manager (measured at VX-179 U3-g),
   pops the dead pane's action and invokes it: `EXC_BAD_ACCESS` in `popAndInvoke` once the view is
   freed (the ticket), or a silent edit into a detached pane while something still holds it.
5. **The widening (same class, same component):** the reach is every host of the one representable,
   not only the Takes cards — the Takes article and fan/mini/stack cards, Lenses cells, Compare,
   Write's take panel (⌘⇧T closes it: its panes dismantle while Write's editor shares the window's
   manager), Canvas, the Blocks workbench, Read ▸ edit and the book Index (the last two render the
   pane ONLY while live — `ReadEditPane.swift:348`, `BookIndexView.swift:1789` — so every going-read
   dismantles it). And a second road to a corrupt replay: a READ pane's projection adoption
   (`:1514-1524`, `view.string = text`) rewrites the characters while that pane's typing history
   still names ranges of the OLD text — VX-179 U3-g's `NSRangeException` class, which is why both
   precedents (`CommentTextArea`, `CaptureTextView`) END their history on a programmatic write.
6. Why the per-view manager is the road (R-601-1): `removeAllActions(withTarget:)` on the view or the
   storage does NOT reach TK2's registrations (measured at U3-g), so no teardown-time clearing of the
   window's manager can be made exact; and clearing the window's whole manager would reach other
   text's history.

*VX-248 — CONFIRMED (the VX-214 record's mechanism step 3 — "the leaf").*
1. `updateNSView` refreshes the callbacks first — `onEdit` at `:1415` — so the coordinator's edit
   closure is ALWAYS the take the cell resolves NOW (`TakesShared.swift:217`:
   `model.paneEdited(variantID: resolved.variantID, …)`).
2. The characters are written only into a READ pane (`:1514-1524`: `if isLive { adoptedText = nil }
   else if readPaneNeedsText … { view.string = text }`); `noteLiveness` (`:1644-1720`, called at
   `:1429`, BEFORE that block) lands the caret and claims the keyboard but writes no text.
3. The pane's `variantID` (`:1134`, `:1302`) is identity-only today — it reaches nothing but the
   NSView identifier (`applyIdentity`, `:1582-1585`).
4. So a stable-identity cell whose bound take changes while it is LIVE (live→live), or in the same
   render that makes it live (read→live — VX-222's revival), keeps the OLD take's characters under the
   NEW take's edit closure: the next keystroke hands `old words + keystroke` up as the NEW take's
   text and autosave writes it over that take (one writer, never a sync conflict — silent).
   VX-222's end-rule and VX-227's parked follow close every road the board knows of today by never
   letting a cell be live across a re-key; the leaf itself still allows it.
