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

**The members (the SUB-ISSUE LISTING, read live at kickoff 2026-10-27 — the VX-548 lesson):**
VX-421 · VX-427 · VX-428 · VX-429 · VX-574 · VX-586 · VX-594, plus rider **VX-577** seated at her
kickoff word. (VX-592 remains an offered rider, not seated — re-offered at the sitting.)
Pin-before-fix binds PER MEMBER; the cold review covers the run's whole diff.

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
**Related:** VX-248 (the live pane's bound-take class) — offered as a rider; if declined, this fix
still must handle the BOUND-TAKE CHANGE occasion (a pane re-bound to a new take must not keep the
old take's undo history), since that is the same freed/stale-target class one step milder.
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

---

## The batches (one acceptance unit per implementer session; strictly sequential)

- **BATCH A — the editor seam (`PaneSurface`):** VX-421 + VX-429 (+ VX-592/VX-248 if she seats
  them). The crash fix with its pins; the selection probe with its instrumented trace. Required
  reading for the implementer: this file's VX-421/VX-429 sections, `notes/TEXTKIT2_NOTES.md`,
  SurfaceContracts "The note", the environment traps below.
- **BATCH B — the board and its doors:** VX-428 (session memory + her measurements) + VX-577
  (the gate) + VX-594 (the ruled door).
- **BATCH C — bars and chrome:** VX-427 (the count) + VX-574 (the font) + VX-586 (the label).

Order: A first (the launch gate), then B, then C — C is light enough to fold into B's session only
if B lands small; default is three fresh sessions. The ladder runs ONCE over the run's whole diff
(fable-reviewer, `notes/REVIEW_PROMPT.md` verbatim, zero framing), rounds per the skill.

## The ledger (every row owned; statuses live here)

| # | Item | Status |
|---|---|---|
| 1 | VX-421 crash fix + pins | NOT-STARTED (batch A) |
| 2 | VX-429 instrumented probe → fix or record | NOT-STARTED (batch A) |
| 3 | VX-428 session memory + measurements + landing proof | NOT-STARTED (batch B) |
| 4 | VX-577 expand-all in slot split | NOT-STARTED (batch B) |
| 5 | VX-594 probe → her door ruling → build | NOT-STARTED (batch B; ruling at the sitting) |
| 6 | VX-427 focused-take count (+ her call on the cycle face) | NOT-STARTED (batch C) |
| 7 | VX-574 font weight | NOT-STARTED (batch C) |
| 8 | VX-586 "block i/N" | NOT-STARTED (batch C) |
| 9 | The kickoff sitting record | PENDING — asked 2026-10-27 |
| 10 | The ladder (whole-diff, fable-reviewer) | NOT-STARTED |
| 11 | Closeout (canon deltas · #245 bundle · tickets · handoff) | NOT-STARTED |

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

**VX-427 — her clarification (verbatim):** *"I think the whoel idea was to beable to count the
take that you're typing in - is that not what is being done? why is the take face in the bar's
shared click cycle an option ?"* — Answered: the fix IS exactly that (the bar's existing "Nw take"
unit counts the focused pane's take); the cycle face was the scout's optional extra, recommended
dropped. Her confirm is batch 2 of the sitting.

**VX-594 — her lean + question (verbatim):** *"I think the menu door + caret following makes the
most sense - by that, do you mean if your caret is in a particular take the keyboard shortcuts
will work for that too?"* — Answered yes (⌘T / New Take (Branch) and the take-scoped doors resolve
to the focused pane's take when the caret sits in one, chosen take otherwise); her confirm of that
exact semantics is batch 2 of the sitting.
