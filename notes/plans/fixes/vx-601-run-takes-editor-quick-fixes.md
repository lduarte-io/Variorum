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

**NOT DONE (first line, kept current):** the suite window (the orchestrator's: this session never
runs `xcodebuild test`) — **every red and green claim below is a PREDICTION, PENDING that window**;
the USE walk (an Opus walker under the orchestrator's claim — rows W1–W4 below); the cold ladder.
No behavioural revert is in flight — all three revert builds are DONE and the source is HEAD
(`git diff` empty; no `VX601A-REVERT` marker in `PaneSurface.swift`).

**LIVE STATUS**
- Reading — DONE: this file in full (members, batches, ENVIRONMENT TRAPS, the sitting record
  R-601-1/R-601-6), `notes/TEXTKIT2_NOTES.md` in full, `notes/SurfaceContracts.md` "The note",
  `notes/SessionResiliencyProtocol.md`, the VX-214 record's VX-222/VX-227 trace + the F2 ruling
  (`notes/plans/fixes/vx-214-settings-launch-polish.md` §BATCH 4 + ARCHITECT RULING), and the code:
  `Surface/PaneSurface.swift` (whole), `Surface/PaneTextAuthority.swift`,
  `Core/Views/CommentTextArea.swift` (the U3-g road), `Core/Views/CaptureTextView.swift` (VX-193),
  every `PaneSurfaceView(` host, `TakesViewModel`'s focus/park/end-rule section,
  `CanvasViewModel`'s switcher, the pins `PaneSurfaceTests`, `PaneFindFaceTests`,
  `CommentTextAreaTests`' undo pin.
- Trace — DONE (below); both members' mechanisms CONFIRMED by my own read; no divergence from the
  briefed mechanisms — two WIDENINGS, stated (VX-421's reach; VX-248's live road on Canvas).
- Pins — DONE: `VariorumTests/PaneLifecycleTests.swift`, 12 tests in 3 suites —
  `PaneUndoLifecycleTests` (VX-421: 5 red-on-old + 1 guard; 73a7a2ca, + the read-pane pin
  b1a82dc3), `PaneRebindTests` (VX-248: 3 red-on-old + 2 guards; 73a7a2ca),
  `CanvasSwitcherRebindTests` (VX-248 on a real road: 1 red-on-old; 24b835b5); the rig's edit mirror
  e0021460 (a self-review find — without it three pins would have read false-red on the fixed tree).
- Fix VX-421 — DONE (436bf331 + b1a82dc3): the coordinator's own `undoHistory` answered through
  `undoManager(for:)`; the read adoption and `uninstall` end it; a READ pane answers an always-empty
  `readHistory` (the probe below).
- Fix VX-248 — DONE (b1a82dc3): the coordinator binds the host's `variantID` (`boundVariantID`); a
  change is a RE-BIND (`rebindIfTakeChanged`) run BEFORE the liveness note — the new take's text
  written where it differs, the old history ended, the find/room token baselines adopted as at a
  mount — and `noteLiveness(_:rebound:)` lands a live re-bind's caret in the new text and claims the
  keyboard as any programmatic going-live.
- Builds — DONE, all four carrying the FINAL tests (24b835b5), each build-for-testing GREEN
  (logs `App/Variorum/DerivedData/logs/`):
  `DerivedData/vx601a-post` = HEAD (the fix) · `DerivedData/vx601a-pre` = HEAD's tests over the
  PRE-FIX `PaneSurface.swift` (c2a0b833's — both members reverted) · `DerivedData/vx601a-rev421` =
  HEAD with ONLY VX-421 reverted (`undoManager(for:)` answers nil → the window's manager, as before)
  · `DerivedData/vx601a-rev248` = HEAD with ONLY VX-248 reverted (`rebindIfTakeChanged` returns
  false first — never a re-bind, as before). Each revert: committed-first, built, restored by
  `git checkout -- …/PaneSurface.swift`.
- Red/green runs — PENDING (the orchestrator's window; the prediction table below).
- USE walk — PENDING (the orchestrator's claim, an Opus walker; rows W1–W4 below).
- Self-assessment + READY-FOR-SUITES — DONE (below, this commit).

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
5. **The widening — a live road reaches the leaf TODAY, on Canvas** (found by my own read at the
   self-review; the VX-214 sweep's table covered the Takes and Lenses boards and named Compare as
   unexamined — Canvas was not on it). `CanvasViewModel.switchTake` (`:605-623`) writes the view
   pick AND re-focuses the ring onto the newly shown take in the SAME turn ("4E: the ring follows the
   card"), while the card keeps ONE pane per placement (`CanvasView.swift:639`, the card `ForEach`
   keyed by `placementID`; the pane carries no per-take identity) — a live→live re-key, the naive
   follow VX-227's park exists to avoid. So on the old tree ‹ › (or ⌃⌘←/→ with the switcher open)
   under a live card hands the next keystroke up as the NEW take with the OLD take's words. Canvas is
   a Debug-build mode (Release has six), so the road is real wherever the mode is. Pinned
   (`CanvasSwitcherRebindTests`, red on old by mechanism — its non-vacuity asserts the card keeps the
   SAME pane across the switch; a remount would make the road hollow and the pin would say so).

**THE PROBE (offscreen AppKit, a standalone `swiftc` binary in the session scratchpad — never the
app, no store, no screen; the VX-179 U3-g method).** A TK2 `NSTextView` with `allowsUndo`, a
delegate answering `undoManager(for:)`, in a borderless window never ordered in; macOS 27.0.1:
1. `string =` posts NO `textDidChange` and registers NO undo (so a re-bind/adoption hands nothing
   up — the `aRebindHandsNothingUp` guard rests on it).
2. Typing registers on the DELEGATE's manager (the window's `canUndo` stays false).
3. **An undo APPLIES to a NON-editable text view** — `isEditable = false`, then `undo:` through the
   window: the characters reverted (and no `textDidChange` posted offscreen). → the read-pane gate.
4. A delegate answering nil falls back to the WINDOW's manager (`view.undoManager ===
   window.undoManager`). → `readHistory` is never nil.
5. `undo:` with the WINDOW as first responder undoes through the window's own manager.

**AS BUILT (`Surface/PaneSurface.swift`; `Surface/PaneTextAuthority.swift` gains one doc sentence;
no other production file).**
- *VX-421 — the pane's own history (`PaneSurfaceRepresentable.Coordinator`):* `let undoHistory`,
  answered by `undoManager(for:)` for the coordinator's own view while it is EDITABLE (live); a READ
  pane answers `readHistory`, a manager nothing is ever registered on (never nil — nil is the
  window's). `endUndoHistory(in:)` (`breakUndoCoalescing()` + `removeAllActions()`) runs at every
  PROGRAMMATIC write of the pane's characters — the read adoption in `updateNSView` and the re-bind —
  and `uninstall()` empties the history at teardown (by construction it dies with the coordinator
  anyway). ⌘Z keeps AppKit's road (`undo:` → the window → the first responder's manager).
- *The lifecycle edges, said which (the brief's ask):* **teardown** — the history goes with the pane
  (emptied in `uninstall`; the coordinator's life is the representable's); **detach/re-attach**
  (TEXTKIT2 §3's re-parent) — the history **SURVIVES**, untouched: nothing in it is window-bound
  any more (the guard `aPaneKeepsItsHistoryAcrossADetachAndReattach`); **first-responder edges** — ⌘Z
  reaches the history only while the pane is live; a read pane holding the keyboard reaches nothing,
  and its history waits for its next going-live over the same characters; **a re-bind** — the old
  take's history ends.
- *VX-248 — the bound take:* `boundVariantID` is written at the mount (from the host's
  `variantID`) and by `rebindIfTakeChanged` only. In `updateNSView` the re-bind runs right after the
  callbacks refresh and BEFORE `paintFind`/`isEditable`/`noteLiveness`: when the bound take changed,
  the new take's text is written where it differs (TRACE 1a's record answers for a read pane, the
  view for a live one — once per re-bind, never per pass; an identical branch writes nothing — the
  A47c class), the face re-derived caret-blind, the caret ledger and the find paint reset, a
  remeasure, the history ended, the record set (`nil` live, the text read); then the find and room
  token baselines are adopted as at a mount (a re-bind is not a step); then
  `noteLiveness(_:rebound:)` treats a LIVE re-bind exactly as a programmatic going-live — the
  landing (`caretOnGoingLive`) placed in the NEW text, then the keyboard claim (the find field's
  keyboard rule kept); a click flag never overrides a re-bind's landing (the click was made in the
  replaced text); a live re-bind is also a convergence occasion (the render restore is the A47c
  belt); a READ re-bind keeps the read adoption's road. `PaneSurfaceView.variantID`'s doc now says it
  is the bound take; every one of the ten production hosts passes the take whose `onEdit` it hands
  down beside it (each read: TakesCellView, the mini/stack cards, Compare ×2, the Write panel,
  Canvas, the workbench, Read ▸ edit, the book Index).
- *What did NOT change:* the read tier proper (`ReadPostView`, its own coordinator), the full-document
  editor (`EditorTextView`), `BlockRangeIndex`, `TakesViewModel` (VX-222's end-rule and VX-227's
  parked follow stay, untouched — redundant by construction now, never removed), no `Sync/`, no
  schema, no Shared/ file (**MOBILE PARITY: nothing mobile-visible** — `PaneSurface.swift` is Mac-only).

**PROVISIONAL (for the orchestrator's #245 bundle — I do not touch QUESTIONS.md):**
- **P-A1 — ⌘Z in a READ pane that holds the keyboard does nothing.** The rulings say "⌘Z undoes only
  the pane the cursor is in" (R-601-1) and do not name a read pane holding the keyboard (a
  drag-selection; the gap a parked follow's blur leaves). Options: (a) nothing — BUILT, the most
  spec-defensible: a read pane holds no caret of hers (VX-296's line) and is projection-authoritative
  (`PaneTextAuthority`'s contract), and the probe shows AppKit WOULD move its characters; (b) undo that
  pane's own typing (the precedents' shape without the gate) — moves a read pane off its take's text
  (and in the live app hands it up from a read pane); (c) fall back to the window's manager — the
  cross-pane history R-601-1 ends. Red-on-old pinned (`aReadPaneHoldingTheKeyboardUndoesNothing`).
- *Carried, not new:* "a programmatic write of the characters ends the history" is the precedents'
  rule (P-VX179-U3-4, carried at VX-193 as P-U4-1) applied to panes.

**CONSEQUENCES FOR HER TO KNOW (not decisions — what the ruled arm means in use):**
- A pane's history is the REALIZED pane's: a take scrolled far enough that its lazy row
  de-realizes (the Takes article and boards are lazy) comes back with no ⌘Z history — on the old
  tree that same scroll-away-and-⌘Z replayed into the de-realized pane (this ticket's crash road by
  scrolling). Likewise every going-read of Read ▸ edit's and the book Index's pane (those hosts
  render the pane only while live).
- ⌘Z after a take's words changed elsewhere while she was away (another pane of the same take, sync,
  an agent) has nothing to undo in that pane — the history named words that left it.

**THE PREDICTION TABLE (the red/green runs — PENDING the orchestrator's window).** 12 tests in 3
suites; R = red, G = green; "guard" = green on both sides by design.

| # | Test | pre (both reverted) | rev421 | rev248 | post |
|---|---|---|---|---|---|
| 1 | `PaneUndoLifecycleTests/aTornDownPanesTypingNeverReachesTheWindowsUndo` | R | R | G | G |
| 2 | `…/undoAfterATornDownPaneIsReleasedIsACleanNoOp` (stops at its `#require` when red — never runs the crash line) | R | R | G | G |
| 3 | `…/undoInAPaneUndoesOnlyThatPanesTyping` | R | R | G | G |
| 4 | `…/aReadPaneHoldingTheKeyboardUndoesNothing` | R | R | G | G |
| 5 | `…/aPaneKeepsItsHistoryAcrossADetachAndReattach` (guard) | G | G | G | G |
| 6 | `…/aProgrammaticWriteEndsThePanesHistory` (stops at its `#require` when red) | R | R | G | G |
| 7 | `PaneRebindTests/aLivePaneReboundToAnotherTakeShowsThatTakesWords` | R | R (the history line only — the re-bind's history half rides VX-421's manager) | R | G |
| 8 | `…/aReadPaneReboundAsItGoesLiveShowsTheNewTake` | R | G | R | G |
| 9 | `…/aReboundLivePaneLandsItsCaretInTheNewText` | R | G | R | G |
| 10 | `…/aRebindHandsNothingUp` (guard) | G | G | G | G |
| 11 | `…/aReadPaneReboundShowsTheNewTakeAndStaysRead` (guard) | G | G | G | G |
| 12 | `CanvasSwitcherRebindTests/switchingTheLiveCardsTakeNeverWritesTheOldWordsIntoTheNewTake` | R | G | R | G |

A pin green on its own member's revert = HOLLOW (record it, never fix it). #12's non-vacuity line
("the card kept ONE pane across the switch") red on BOTH sides would mean SwiftUI remounts the card's
pane and the Canvas road is hollow — then #12 is dispositioned hollow and the Canvas widening
withdrawn.

## READY-FOR-SUITES — batch A (the orchestrator's window; from `App/Variorum/`)

All four builds are done; run `test-without-building` on each (no rebuild):
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<build> test-without-building -only-testing:… `.
Confirm each run's "Test run with N tests in M suites" line and read the `skipped:` lines (VX-604:
0 ran = no verdict).

1. **THE RED RUNS** — the three pin suites on each revert build (`vx601a-pre`, `vx601a-rev421`,
   `vx601a-rev248`), seconds each:
   `-only-testing:VariorumTests/PaneUndoLifecycleTests -only-testing:VariorumTests/PaneRebindTests -only-testing:VariorumTests/CanvasSwitcherRebindTests`
   — expect **12 tests in 3 suites** on each, the reds exactly as the table: pre — #1–#4, #6–#9, #12
   red (9 red, 3 green); rev421 — #1–#4, #6, #7 red (6 red, 6 green); rev248 — #7–#9, #12 red (4
   red, 8 green). Both `#require`-guarded pins STOP before their replay line when red, so no red run
   can take the test host down.
2. **THE GREEN RUN, tier 1** (on `vx601a-post`) — the pins, VX-222's and VX-227's contamination pins
   (now redundant by construction — their executed counts go in the record), and the pane component's
   own suites:
   `-only-testing:VariorumTests/PaneUndoLifecycleTests -only-testing:VariorumTests/PaneRebindTests -only-testing:VariorumTests/CanvasSwitcherRebindTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/PaneSurfaceTests -only-testing:VariorumTests/PanePublishDoorTests -only-testing:VariorumTests/PaneFindFaceTests -only-testing:VariorumTests/PaneTextAuthorityTests -only-testing:VariorumTests/PaneTextCompareTests -only-testing:VariorumTests/PaneMarkdownCaretFaceTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/PaneRenderRestoreClipTests -only-testing:VariorumTests/CanvasTakesSwitcherTests -only-testing:VariorumTests/MarkdownActsTests`
   — 17 suites, all green expected (the counts per suite are the run's; VX-222's
   `TakesChooseRingTests` is 5 tests).
3. **THE GREEN RUN, tier 2 — the pane-family battery** (on `vx601a-post`): every suite type in the
   91 test files that name the pane component or any of its ten hosts (`PaneTextView`,
   `PaneSurfaceView`, `PaneTextAuthority`, `PaneCaretLanding`, `PaneFindFace`, `PaneMeasurement`,
   `PanePublisher`, `PaneDecoration`, `TakesBoardView`, `LensesBoardView`, `CompareBoardView`,
   `WriteTakesPanel`, `CanvasView`, `BlocksWorkbenchView`, `ReadEditPane`, `BookIndexView`,
   `TakesCellView`) + `TakesParkedFollowTests` — **196 suite types** (extracted as types containing
   `@Test`, never file names — the VX-184 lesson). One `-only-testing:VariorumTests/<name>` per name:
   ArrivalsDoorPlacementTests AutosaveRegistryLifecycleTests AutosaveRegistryReleaseGuardTests
   BlockHighlightTests BlockHistoryPaletteDoorTests BlockHistoryPaneTests BlocksArrivalMeasureTests
   BlockSelectionRegistryTests BlockSelectionRuleTests BlocksWorkbenchFaceTests
   BlockTagSheetVoiceTests BlockTOCStatusTests BoardBlockSelectionTests BoardDeliveryPolicyTests
   BookAscentDeclarationTests BookCarryLiveBlockTests BookCollectingDoorsTests
   BookEditHereRiderTests BookIndexEditingTests BookIndexGroupingTests BookIndexTakesTests
   BookIndexToOutlineCarryTests BookLeavingRegistryTests BookLeavingSavepointTests
   BookNoteBoxOpenDoorTests BookOpenDoorMountTests BookOpenDoorRuleTests BookOpenDoorShellTests
   BookPlaceMemoryTests BookRedesignMountTests CalloutContextMenuTests CalloutEmojiPickerTests
   CalloutSwatchTests CanvasAndPoolTests CanvasArrivalTests CanvasBankDropTests
   CanvasBankHostedTests CanvasBankMembershipTests CanvasBoardGeometryTests CanvasDragTrackingTests
   CanvasFocusedBlockFactTests CanvasHostedRealizationTests CanvasOrderAndOverviewTests
   CanvasRealizationTests CanvasSwitcherRebindTests CanvasTakesSwitcherTests CapabilityRegistryTests
   CaptureFocusReattachTests CaptureHandOffTests CaptureHostsUndoFilingTests CaptureKeysTests
   CaptureOpeningFocusBoxTests CaptureOpeningFocusRuleTests CaptureTextViewKeyTests
   CaptureTourFocusTests CaptureUndoHistoryTests CaptureUndoSyncTests CommandRouterTests
   CommentPanelHostLeavingTests CommentPanelHostSuites CommentPanelReleaseTests
   CompareAnchorWholeTests CompareCompositionTests CompareLeavingSavepointTests
   CompareLensesAlignmentTests CompareOnePlacementTests CompareViewModelTests CopyAllTakesDoorTests
   CurrentBlockContinuityTests DebugOracleSingletonWindowTests DuplicateBookNameDoorTests
   DuplicateDoorsTests FanReorderDoorTests FormattingSurfacesTests GlobalSegmentationFaceTests
   IndexClickCaretTests IndexLandingCaretTests IndexProseColumnTests IndexTierMetricsTests
   InlineEditorWidthReflowTests InlineHeightReportTests LensesReorderTests ListContinuationTests
   MarkdownActsTests MarkdownCaretFaceTests MCPCompareLandingTests MergeSelectionTests
   ModeSwitchCarryTests ModeSwitchFeelTests MoveAndExecuteTests NavigationDoorsTests
   NavigationHistoryTests NestedListDoorTests NewBlockShortcutTests NoteCardSmartBooksTests
   NoteOpenLandingTests OpenNotesTests PaneBookBlurTests PaneFindFaceTests PaneFocusCatcherTests
   PaneHeldModeTests PaneLayoutTests PaneLineMetricsScopeTests PaneMarkdownCaretFaceTests
   PaneMountTests PanePublishDoorTests PaneRebindTests PaneRenderRestoreClipTests PaneSplitDoorTests
   PaneSplitModelTests PaneSurfaceTests PaneTextAuthorityTests PaneTextCompareTests
   PaneUndoLifecycleTests PaneUnmountTests ParagraphGapTests PlainPasteDoorTests PlainPasteRuleTests
   PostDetailModeMemoryTests PostDetailRoutingTests ProseGutterTests QuickEntryOpeningScopeTests
   QuitFinalizeSurfacesTests ReadModeTests ReadNoteLandingTests ReturnKeyTraceTests
   SavepointCommitDoorTests SavepointNameAskTests SavepointNameCopyTests SavepointNameFaceTests
   SavepointRenameDoorTests SavepointSealedDoorTests SavepointTakesDoorTests SealDoorTests
   SettleRewrapOverlayTests SidebarNoteBoxDoorFacesTests SidebarNoteBoxTakesCellClickTests
   SidebarSmokeTests SoftNewlineTests SpellcheckLevelTests SplitAtNewlinesDoorTests
   StaleWriteIntentTests StatusCenterTests TagChipLeafTests TakeCardDoorTests
   TakePaneDurabilityTests TakePaneMeasureTests TakesArticleRenderTests TakesArticleScrollTests
   TakesArticleWatchTests TakesBoardSoakTests TakesBoardTests TakesBufferConvergenceTests
   TakesCardHeightTests TakesChooseRingTests TakesEmptyBlockFaceTests TakesEmptyStateTests
   TakesEntryBandTests TakesFindBoardTests TakesLandingTests TakesLensFilterTests
   TakesMarginGridAlignmentTests TakesMarginGridCaptureTests TakesParkedFollowTests
   TakesPresentationTests TakesRailPagingTests TakesRoomTests TakesSlotDragTests
   TakesStepFollowModelTests TakesStepFollowTests TakesWordCountTests TakeToBlockDoorTests
   TrayPanelMoveTests TutorialBookShapeTests TutorialDeletionActsTests TutorialDoorTests
   TutorialFannedMatrixTests TutorialLibraryActsTests TutorialLookingActsTests
   TutorialPrivacyChapterTests TutorialStructureActsTests TutorialTakesActsTests
   TutorialWherePlacesActsTests TutorialWritingActsTests TypedReturnKeyTests
   VX347AskedTakeFilingTests VX347LeaveRuleTests VX347LeavingBoxTests VX347OneCommitPerFieldTests
   WorkspaceModelTests WorkspaceNamingTests WriteBlockSelectionTests WriteTakesPanelChooseTests
   WriteTakesPanelKeysTests WriteTakesPanelRoutedCommandTests WriteTakesPanelTests
   Standing reds that are NOT this batch's, if met: VX-337's two load-dependent flakes
   (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt`,
   `TakesBoardSoakTests.randomizedBoardSoakHoldsEveryInvariant(seed: 21)` — whole-target load only;
   batch C's bounded trace) and the trait-skipped singleton-window oracle suite.

## THE USE WALK — batch A rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug build
from `DerivedData/vx601a-post`; never press Resume Sync; restore exactly as found)

The walk REQUEST names: one fresh walk note with one fanned block (two takes) and a second plain
block, minted by quick entry and ⌘T; it leaves to the Trash at the end. The fixed build is not
expected to crash; if it does, the walker stops, records, and the orchestrator confirms the store
reopens clean and still held before anything else. Captures one per row per voice, both voices
(Study first — the store's voice — then Terminal, restored to Study):
- **W1 — VX-421, her exact gesture:** Takes; ⌘T mints a take; paste a long paragraph into it; delete
  that take (the card's Delete Take); **⌘Z — the app lives** (nothing undoes; no crash); **⌥⌘Z
  restores the take**. (Old build: the crash — not walked.)
- **W2 — R-601-1's meaning:** type in take 1, click take 2 and type there; ⌘Z, ⌘Z — only take 2's
  typing goes; take 1 is untouched. Then switch to Write and back to Takes: take 2 still reads
  undone (the store heard the undo — the live road's `textDidChange`, which this fix does not move;
  if it reads re-done, that is a pre-existing finding to record, not this batch's regression).
- **W3 — VX-248 on its live road (Canvas, ⌘7 — Debug only):** the fanned block's card: click in,
  type "x"; open its ‹ › switcher and press › — **the card shows take 2's own words, the caret in
  it**; type "!" — it lands in take 2's words; ‹ back — take 1's words, with the "x". (Old build: take
  1's words shown under take 2 — the contamination.)
- **W4 — no regression of VX-227's follow:** Lenses, a scratch column: click its pane, ⌃⌘→ — take 2's
  own words, caret in it; ⌃⌘← — take 1's own words; a keystroke lands in each.

## SELF-ASSESSMENT (the first of the two reviews — the implementer's)

- **Scope and seams.** Two production files: `Surface/PaneSurface.swift` (the coordinator's undo
  history, the bound take, the re-bind, `noteLiveness(_:rebound:)`, two doc paragraphs) and
  `Surface/PaneTextAuthority.swift` (one doc sentence naming the re-bind exception). Zero
  `Sync/`, schema, Shared/, `EditorTextView`, `BlockRangeIndex` (regions untouched), read tier,
  `TakesViewModel`. No TK1 API (`.layoutManager` appears nowhere new); no attribute stamp added (the
  re-bind writes a whole string and re-derives the face exactly as the read adoption does). P-3: no
  second liveness mechanism — the history reads `isEditable`, which the authority's answer sets; the
  re-bind extends the one component's lifecycle, as the brief asked.
- **The trace held.** Both briefed mechanisms confirmed by my own read; two widenings, stated: VX-421
  reaches every pane host (and the read adoption is a second replay road), VX-248 has a live road
  today on Canvas. The probe added one fact the brief did not have (undo applies to a non-editable
  text view) and the read-pane gate answers it (P-A1, PROVISIONAL).
- **What could regress, and why I think it doesn't.** (1) *Existing re-key roads now re-bind:* the
  Takes article on a choose and the Lenses park both re-key a READ cell — the re-bind writes exactly
  what the read adoption wrote, and the read adoption then finds its record current (one write, as
  before). (2) *Order inside `updateNSView`:* the re-bind writes before `applyFace`/`applyStyle`/the
  font branch; each of those re-derives over whatever text is there, so a voice/palette change in
  the same pass converges as it did. (3) *Ten hosts' `variantID`:* each read; each passes the take
  whose `onEdit` it binds. (4) *Write's take panel:* its panes no longer share the Write editor's
  history (the editor's structural `removeAllActions` no longer reaches them) — each pane's history
  ends on its own programmatic writes instead. (5) *Cost:* two `UndoManager`s per mounted pane (one
  never used); the re-bind's view comparison runs once per re-bind, never per pass. (6) *The F1
  source walk* (`PaneSurfaceTests`): no binding written, no SwiftUI wrapper word in the coordinator.
- **Risks I see.** (a) Pins written without a run: the rig, the window shapes and the undo road
  follow measured precedents (`CommentTextAreaTests`' undo pin, `PaneFindFaceTests`' re-parent,
  `CanvasAndPoolTests`' mounted board), and one false-red was caught in self-review (e0021460) — but a
  harness surprise is possible; a red on `post` is a pin to fix, never a reason to touch the
  production change without a trace. (b) #12's premise (the card keeps one pane across the switch) is
  read from the code, not measured — its non-vacuity line decides. (c) An IME composition in progress
  at a re-bind is replaced with the old take's text (a programmatic write ends a composition — the same
  as any adoption; no road re-binds a live pane mid-composition today). (d) `textDidChange` on ⌘Z in
  the live app is AppKit's and unchanged by which manager holds the actions — W2 confirms it.
- **Residue / not mine (for the orchestrator to ticket or drop):** (R-1) **the full-document editor's
  sibling** — `EditorViewModel.teardown` leaves the Write editor's typing history on the WINDOW's
  manager and its `textView` is weak, so a torn-down Write editor's actions may name a freed view the
  same way (e.g. type in Write, switch to a mode that unmounts the editor, ⌘Z with nothing holding the
  keyboard). Suspected, NOT traced to a crash, the editor seam's other surface kind — out of this
  batch. (R-2) the optional naive-follow demonstration (VX-227's batch4revert over this fix: its
  scratch pins green, proving the park redundant for contamination) was NOT built — the Canvas pin
  is the same demonstration on a real road.
