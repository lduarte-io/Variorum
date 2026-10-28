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
| 1 | VX-421 crash fix (per-pane undo) + pins | **ACCEPTED 2026-10-27** — red-on-old by revert (rev421: exactly its 6 pins), tier 1 + battery green, walk W1/W2 PASS both voices |
| 2 | VX-248 bound-take adoption + VX-222/227 pins green | **ACCEPTED 2026-10-27** — red-on-old by revert (rev248: exactly its 4 pins), VX-222/227 green in tier 1, walk W3/W4 PASS both voices |
| 3 | VX-429 instrumented probe → fix or record | **ACCEPTED 2026-10-27** — red-on-old by revert, suites green, walk A1/A2/A4 PASS (Study + partial Terminal) |
| 4 | VX-592 drag probe → fix or record | **ACCEPTED 2026-10-27** — red-on-old by revert ("Write is fine" falsified), suites green, walk A3/A4 PASS; A5 recorded; Q-A2-1 → #245 |
| 5 | VX-428 session memory + measurements + landing proof | **ACCEPTED 2026-10-28** — red-on-old by revert (incl. the rebuilt trees), her measurement P3-clean, walk B1/B2/B4 PASS |
| 6 | VX-577 expand-all in slot split | **ACCEPTED 2026-10-28** — red-on-old by revert (#12 + #10), walk B3 PASS (P-B-1 blur seen live); the ⎋ clause → VX-637 (pre-existing/harness, her 5-s check) |
| 7 | VX-594 the […] door + caret-following ⌘T | **ACCEPTED 2026-10-28** — the door red-on-old by revert, walk B5/B6 PASS; the ⌘T half HOLLOW-GOOD (already worked, guards green); the no-current-take edge → #245 |
| 8 | VX-427 focused-take count | NOT-STARTED (batch C) |
| 9 | VX-574 font weight | NOT-STARTED (batch C) |
| 10 | VX-586 "block i/N" via BlockLineLabel | NOT-STARTED (batch C) |
| 11 | VX-321 receipt wording | NOT-STARTED (batch C) |
| 12 | VX-337 bounded flake trace | NOT-STARTED (batch C; bounded, her word) |
| 13 | The kickoff sitting record | DONE 2026-10-27 (R-601-1…6) |
| 14 | The ladder (whole-diff, fable-reviewer) | NOT-STARTED |
| 15 | Closeout (canon deltas · the #245 bundle · tickets · handoff) | NOT-STARTED |

## WINDOW a2 — the owed runs (the orchestrator, 2026-10-27, claim vx-601-tests-a2 from 20:26)

**Red runs on the REBUILT trees (gated rig; array args; zero host restarts in all three):** every
run executed **12 tests in 3 suites**. `vx601a-pre` — 9 red; `vx601a-rev421` — 6 red;
`vx601a-rev248` — 4 red. Counts match the prediction table EXACTLY, and the names partition
cleanly: rev421's reds are precisely the undo/history pins, rev248's precisely the
rebind-adoption pins, and their union is exactly pre's nine. **No pin is hollow** (none is green
on its own member's revert while red on pre), so red-on-old is verified by revert PER MEMBER.
Logs: `DerivedData/logs/red2-*.log`.

**Tier 1 on `vx601a-post`: 132 tests in 17 suites, ALL PASSED, 0 skipped** (VX-222's and VX-227's
contamination pins among them — green and now redundant by construction). Log:
`DerivedData/logs/tier1-post.log`.

**The 196-suite battery on post: 1143 tests in 196 suites PASSED** (655 s; 4 warnings; 14 known
issues — the deliberately-loud pinned cases, e.g. `IndexTierMetricsTests`' TK2 short-blank-line
set; the only skips the trait-disabled singleton-window oracle suite, by design; zero host
restarts). Log: `DerivedData/logs/battery-post.log`. **An observation for VX-337's bounded trace:**
both its named tests (`TakesArticleScrollTests` fold settle, `TakesBoardSoakTests` seed 21) PASSED
inside this 196-suite run — consistent with the flake being whole-TARGET-load-dependent, not
196-suite-load-dependent; batch C's trace should use the whole target.

**Window a2 verdict: batch A's suite evidence is COMPLETE** — red-on-old by revert per member,
tier 1 green, the battery green. The USE walk (W1–W4) is the remaining acceptance evidence.

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

## INCIDENT — the vx-601-tests-a window, 2026-10-27 evening (window STOPPED early; the orchestrator)

**What ran.** Under the coordinator's GO (claim 19:50–, 45 min): first attempt 19:50–19:51 executed
0 tests on all three revert trees (the zsh word-split slip — the whole `-only-testing` list passed
as one argument; the VX-604 no-verdict shape; caught by the coordinator). Re-run with array args:
`vx601a-pre` 20:03 — **12 tests in 3 suites, failed with 19 issues** (the red run; failing names
match the expected red families by name; per-pin verification below still owed); `vx601a-rev421`
20:04 and `vx601a-rev248` 20:05 — **NO VERDICT: the test host died AT LAUNCH on every attempt**
("Restarting after unexpected exit…" ×3 each), the app's store open failing at startup
(`AppDatabase+Dependency.swift:19`, the dev-store path in `io.lduarte.Variorum.debug`). Logs:
`App/Variorum/DerivedData/logs/red-*.log`.

**The slot's file facts at 20:06** (no store opened, file listing only): the dev slot holds ONE
`variorum.sqlite` (397,312 bytes, mtime Sep 25 08:07), NO -wal/-shm, NO key file beside it, and
the slot folder's own mtime is Sep 25 — while its parent (`…/Application Support`) changed TODAY
at 19:02, before this window's claim (19:50). That contents does not look like the wave's
held-since-10-20 library. Two readings fit: (a) the slot was replaced with a preserved-mtime copy
before this window (19:02), with the pre run's host at 20:03 having opened something that later
launches could not; or (b) the breakage happened during/after the pre run (20:03–20:04). File
facts alone cannot distinguish; handed to the coordinator to correlate with the other sessions'
19:02 acts. **Her real store is a different container and was never touched.**

**Status consequences.** Tier 1 and the battery DID NOT RUN. rev421/rev248 red-on-old verification
is OWED (the per-member hollow-pin discrimination was exactly their job). The pre red run stands
PROVISIONALLY. No process of this window survived it (pgrep strict forms clean, no booted sims);
the claim was released with the incident reported. NOTHING in this window pressed Resume Sync or
opened the store by hand.

**CORRECTION (the coordinator's own check, ~20:20 — the orchestrator's slot reading was WRONG).**
(1) The dev slot is `…/Application Support/Variorum-dev/` and is INTACT — store 27,856,896 bytes,
-wal/-shm present, `variorum-restore-hold.json` (Oct 20) and key files in place; last write 20:05
by this window's own test hosts. The Sep-25 397KB file this record's file-facts paragraph describes
is `Application Support/Variorum/` — a RELIC folder, untouched (nothing wrote it); the parent's
19:02 mtime was vx-623's walk restoring itself (18:53–19:07, 197/197 cmp-verified). NOT a
dev-store incident; nothing for her to rule. (2) The rev421/rev248 launch deaths are a RIG/TREE
fact: their logs show 22× "@Dependency(\.date) has no test implementation… accessed from a test
context" before each fatal — in the REVERTED trees the pins reach the LIVE `database`/`date`
dependencies, whose live road opens the relic path and fatals. The pre tree did not show this, so
the question is why the partially-reverted trees differ (a dependency access outside the test's
scope on the old code paths — e.g. a torn-down pane's escaped callback — or the trees built
differently). Handed to the batch A implementer as a narrow rig diagnosis: fix the RIG or the
tree-build road, never production code without a trace; rebuild the revert trees; the red runs
then re-run in a fresh window.

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

## THE REV-TREE LAUNCH DEATHS — the rig diagnosis (batch A implementer, resumed 2026-10-27 ~20:30)

**Read first:** the INCIDENT section and its CORRECTION (above, the orchestrator's and the
coordinator's). Bounded brief: why the rev421/rev248 test hosts died where the pre tree's did not;
fix the RIG or the tree-build road only; rebuild; no `xcodebuild test` (not ours).

**THE TRACE (from the three logs, `App/Variorum/DerivedData/logs/red-vx601a-{pre,rev421,rev248}.log`):**
1. *Not the old code paths.* The fatal fires in EVERY test of both rev runs — the guards included
   (`aPaneKeepsItsHistoryAcrossADetachAndReattach`, `aRebindHandsNothingUp`), whose code is identical
   in all three trees and never touches a torn-down pane or a re-bind — each time preceded by the same
   failing issue, attributed to the RUNNING test: `@Dependency(\.database) has no test implementation
   … Location: VariorumCore/Operations.swift:16`, then `AppDatabase+Dependency.swift:19` (the live
   guard, `AppDatabase.liveValue`, opening the DEFAULT path — the relic `Application Support/Variorum/`)
   → fatal → "Restarting after unexpected exit" → the next test, the same death.
2. *Not a different build.* All three were made by the one command (`xcodebuild -scheme Variorum
   -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> build-for-testing`), from the same
   tests, differing only in `PaneSurface.swift` (pre = c2a0b833's file; rev421/rev248 = one-line
   behavioural reverts — the batch A record's builds line).
3. *A LAUNCH RACE in the test host.* The test host IS the Debug app; it opens its store on the
   protection road asynchronously after launch and only then builds its shell. **Pre:** process start
   20:03:30.76 → `[protection] road: opened` 20:03:31.49 → "Test run started" ~20:03:31.91 (the shell
   was built before any test ran — zero dependency issues in the whole run). **rev421 (and rev248, every
   relaunch):** process start 20:04:04.81 → "Test run started" 20:04:05.25 → road opened 20:04:05.62
   (MID-TEST) → the shell's hot-key registration (RootView `onAppear`) at 05.785 → the `\.database`
   issue → fatal 05.90. The tests began ~0.44 s after launch, before the store opened.
4. *Why inside the test.* The pins' `settle` pumps `RunLoop.main` from within the test's task; the host's
   shell, built when the open completes, was therefore constructed SYNCHRONOUSLY inside that task —
   where swift-dependencies resolves `@Dependency` in the TEST's scope, not the app's
   `prepareDependencies` ambient — so the shell's first `\.database` read found nothing and fell to the
   live guard. (The launch-time `\.date` reports at `AppSession.swift:762`, "Test «unknown» recorded a
   warning", are VX-439's documented harmless noise, outside any test.)

**VERDICT: a RIG fact (the VX-604 class — the test host's own launch), NOT a production bug.** Outside a
test there is no test scope: the shell's reads see the ambient the bootstrap prepared before any view
exists. Nothing in batch A's production change is on the path (the fatal fires in tests that exercise
none of it). The pre run's clean pass was the same race, won by timing.

**THE RIG FIX (this commit — `VariorumTests/PaneLifecycleTests.swift` only):** `HostLaunchSettle.wait()`
— called at the top of BOTH settle helpers, so no rig ever pumps the run loop before the host's launch
has settled. It SLEEPS (never pumps) until the host shell's first landed settings value
(`EditorTypography.isAdopted`, whose one production setter is `ThemeStore.start` inside the ready
shell), then a 0.5 s tail (the pre run's observed gap was 0.42 s); bounded at 20 s (a host that cannot
open builds no shell); once per process (a latch — later calls are free). While the test sleeps, the
host's launch runs on the main run loop outside any test's task — the pre run's condition, made
deterministic. Not done, deliberately: wrapping the rig suites in `withDependencies` (it would let the
host's shell build against the test's in-memory store and still surface the shell's OTHER unscoped
dependencies as failures attributed to the pin).

**Exposure beyond this batch (for the orchestrator / VX-604):** any suite that pumps `RunLoop.main`
before the host's launch settles is exposed when it runs FIRST in a process — the existing
no-dependency rigs (`PaneFindFaceTests`, `PaneSurfaceTests`) fatally, the `withDependencies` suites by
building the host's shell inside their scope. A suite-wide host gate is VX-604's to design; this batch's
three suites carry their own.

**LIVE STATUS (this follow-up):**
- Trace + verdict — DONE (above).
- Rig fix — DONE (this commit); `DerivedData/vx601a-post` rebuilt, build-for-testing GREEN.
- Rebuild of `vx601a-pre`, `vx601a-rev421`, `vx601a-rev248` with the fixed rig — DONE: each revert
  committed-first (from e007ac1a), built, restored by `git checkout -- …/PaneSurface.swift`; all three
  build-for-testing GREEN (logs `rebuild-{pre,rev421,rev248}-gate.log`); every test bundle postdates the
  rig source (pre 20:20:59 · post 20:18:49 · rev421 20:22:12 · rev248 20:23:24; the source 20:17:44).
  No revert in flight; the source is HEAD.
- The red runs on all three + the green tiers — PENDING the coordinator's next window (the
  READY-FOR-SUITES commands and the prediction table stand unchanged; the pre run's 20:03 result —
  12 tests, 9 red exactly as predicted, the 3 guards green — matched the table and is re-run on the
  rebuilt tree with the rest).
- Expected cost of the gate in a window: one wait per test process, ≤ ~1–2 s when the host opens
  normally (the half-second tail included); 20 s at most if the host cannot open.

## THE WALK RECORD — batch A (W1–W4) (Opus walker, claim `vx-601-walk`, 2026-10-27 20:43–21:00 MDT)

Build: `App/Variorum/DerivedData/vx601a-post/Build/Products/Debug/Variorum.app` (dev store, pid 47334
for the whole walk — ONE launch, no crash, no relaunch). Captures (gitignored):
`App/Variorum/DerivedData/walkshots-vx601a/` — `leg0-*` as-found, `w1*`–`w4*` Study, `t1*`–`t4*`
Terminal, `r*` leave-taking. No What's New sheet showed at launch.

**As-found (leg 0, captured before any act):** Bookcase, no books; the held banner "This is your
library as of October 20, 2026…" with Resume Sync (NEVER pressed); "Sync off (dev store)"; Study voice,
app Dark while macOS stayed Light (system appearance never touched); Library = ONE note ("The walk
leaves a stone here…", edited Oct 19); Trash = the Sherlock seed set (notes + "the adventures of
sherlock holmes" book, deleted Oct 27 5:46 PM — the ≈65 the brief names; NOT counted exactly — the
Trash list loads lazily and reads "The Trash is empty." for its first ~1–3 s, which a walker must not
mistake for the as-found). The encrypted-library ask card ("record the twelve words") showed on the
Bookcase and was never touched.

**The walk note:** minted by quick entry ("vx601 walk note, the fanned block one." ⇧⏎ "The second
plain block two." ⏎ — titled "2026-10-27", two blocks), then ⌘T in Write → block 1 fanned (⑂2).
W1 added a third take (restored by ⌥⌘Z); the Terminal pass a fourth. Takes below: take 1 = the
chosen, take 2 = the take ⌘T mints in Takes (it lands SECOND, right after the chosen — the caret
lands in it), take 3 = the Write-minted take.

| Row | Study | Terminal | What was seen |
|---|---|---|---|
| **W1** (VX-421, her gesture) | **PASS** | **PASS** | Takes, fan expanded; ⌘T → ⑂3, caret in the fresh take; ⌘V pasted the long paragraph whole into it; card ⌄ ▸ "Delete this take" → ⑂2; **⌘Z → the app LIVED** (same pid, nothing undid, fan still ⑂2); **⌥⌘Z → the take came back whole** with the paragraph (⑂3), receipt "Undid: Delete Variant". Terminal: same sequence, same result (⑂4 → ⑂3 → ⌘Z alive, nothing → ⌥⌘Z ⑂4) — but see finding F-1 (the pasted text). |
| **W2** (R-601-1) | **PASS** | **PASS** | Typed " oneTYPED" at take 1's end, clicked take 2's end, typed " twoTYPED"; ⌘Z → only " twoTYPED" left take 2; second ⌘Z → nothing further visible; take 1 kept " oneTYPED". ⌘1 → ⌘2 (re-expanded): take 2 still reads UNDONE (no re-do — no pre-existing finding to record). Terminal: " tA" / " tB", identical outcome. |
| **W3** (VX-248, Canvas ⌘7) | **PASS** | **PASS** | Card 1 ("see takes (3)"): clicked its end, typed "x" → "…oneTYPEDx"; "see takes" opened "‹ take 1 of 3 ›"; › → "take 2 of 3 · viewing — not what the note shows", the card showing **take 2's OWN words** ("…W1 long paragraph: the morning…"); typed "!" — the clipped card can't show its end, so verified in Takes after: take 2 ends "…strangely glad.!" (the caret sat at take 2's end), take 1 has no "!"; ‹ → take 1's words with the "x". Terminal: "tAx", › → take 2's own words, "!" → confirmed in Lenses (take 2 ends ".../!"), ‹ → take 1 with "x". |
| **W4** (VX-227 follow, Lenses) | **PASS** | **PASS** | "+ column ▾ ▸ New lens — arrange existing takes" (= `addScratchColumn`, session-only, no store write) → "Lens 1 · unnamed lens"; clicked its pane at take 1's end; ⌃⌘→ → "take 2 of 3", the live pane showing **take 2's own words**; "Q" landed IN take 2; ⌃⌘← → "take 1 of 3", take 1's own words; "W" landed at take 1's end ("…oneTYPEDxW", the Chosen column agreeing). Terminal identical ("take 2 of 4" → Q in take 2; ← → "tAxW"). Observation O-2. |

**Findings and observations (none blocks a row):**
- **F-1 (walk-environment, not the app): the clipboard changed under the walk.** The walker set the
  pasteboard once (`pbcopy`, ~20:45, the long paragraph) for W1-Study; by the Terminal pass (~20:52)
  the pasteboard held a Reddit URL someone else copied (Universal Clipboard — this Mac's HID stayed
  idle throughout, the guard passing every step). So Terminal W1 pasted that 3-line URL, not the
  paragraph — still a paste on the fresh take's undo stack, which is the mechanism the row exercises,
  and the URL now sits in that take of the TRASHED walk note. The walker did not touch the clipboard
  again. **The author's clipboard was overwritten once by the walk (~20:45) — tell her.**
- **O-1 (wording, pre-existing, not this batch):** the structural-undo receipt reads "Undid: Delete
  Variant" — the model word on a face that otherwise says "take". Candidate Wording ticket.
- **O-2 (behaviour as built, not a failure):** after a step, the caret keeps its character OFFSET in
  the new take, so W4's "Q" landed mid-word ("paQragraph" / "httpQs" — offset 48, take 1's end). The
  row's contract (own words, caret in it, a keystroke lands in it) holds; whether a step should park
  the caret at the end is an unruled edge for her, not a regression.
- **O-3 (later batches' members, recorded only):** Takes came back COLLAPSED after the ⌘1→⌘2
  round-trip (VX-428's territory); the bottom bar read "7w take" while typing in the long take
  (VX-427's); after Canvas the Takes head pane's caret sat before the "x" rather than after it.

**Leave-taking / returned:** palette "Use Study Voice" (the Terminal switch was the palette's "Use
Terminal Voice" — the setting is synced document semantics, now back to Study); Appearance never
touched (app Dark throughout, both voices); the walk note deleted by note ▾ ▸ "Delete Note…" ▸
Delete ("goes to the Trash for 30 days"; receipt "Note moved to the Trash — 30 days to put it back.");
NOT emptied, NOT deleted forever. Verified after: Library = the one Oct-19 note; Trash top row
"2026-10-27 · note · deleted Oct 27, 2026 at 8:57 PM", the as-found list unchanged beneath it in the
same order (Trash = as-found + 1); held banner present (Resume Sync never pressed); "Sync off (dev
store)"; Study + app Dark. Not re-opened (untouched by any walk act): sign-in, the MCP pane, Walk Wing.
Quit by bundle id `io.lduarte.Variorum.debug`; guards `pgrep -lx Variorum` / `pgrep -lf
"MacOS/Variorum$"` empty before launch and after quit.

**Prefs (`io.lduarte.Variorum.debug`, before/after export diff):** ADDED four per-note keys for the
walk note (`canvasViewMemory.` / `currentBlock.` / `postMode.` / `takesViewMemory.`
`398495C7-ADA3-415B-A971-8CA8953D5DCA`) — all four DELETED; CHANGED bookkeeping left as is:
`IdleCommitSweepMark.Variorum-dev` (stamp), `variorum.backup.log` (the per-launch dev-store backup
*[removed for publication]*
before: nothing added, nothing removed.

## ORCHESTRATOR ADDENDUM — batch A acceptance + the walk's tails (2026-10-27 ~21:05)

**Batch A is ACCEPTED** (suites: red-on-old by revert per member, tier 1 132/17, battery 1143/196;
the walk: W1–W4 pass, both voices, no crash). The coordinator verified both releases
(tests-a2 20:25:47–20:41:46; walk 20:42:52–21:00:49).

**The launch counter, and an orchestrator slip said plainly:** restoring
`calmAsks.passphrase.<library-uuid>.launches` to its as-found 29, the first write keyed on a first-match
grep and hit a DIFFERENT library's counter (`…159caa3f….launches`, 3 → 29) before being caught
against the walker's before-export. Both keys were then restored to their exact before-export
values (159caa3f = 3, e11e5233 = 29) and verified against `/tmp/vx601-prefs-before.plist`. The
lesson, adopted: restore from the export's ground truth, never a pattern match.

**F-1, her clipboard (for her):** the walk's one `pbcopy` (~20:45) overwrote the pasteboard; by the
Terminal pass it held a Reddit URL of hers (Universal Clipboard pulls her devices' clipboard onto
the Pro), which then rode W1's paste. **Where the URL sits now: the DEV store's Trash, top row —
the walk note "vx601 walk note" (deleted 8:57 PM), in one of its takes.** Nothing purged; deleting
it forever is hers to say. **The standing rule from the coordinator, adopted for every future walk
brief in this run: NO pasteboard writes — type the text, or save-and-restore the pasteboard,
declared in the REQUEST.**

**Walk findings routed:** O-1 (the receipt "Undid: Delete Variant" speaks the model word) → a
Wording ticket to mint (OWED — see Linear writes below). O-2 (a ⌃⌘ take-step keeps the caret's
character offset, landing mid-word) → the #245 bundle as an unruled edge, options at closeout.
O-3's three observations stay recorded for their owning batches (VX-428, VX-427, batch A2's
caret territory).

**OWED LINEAR WRITES — SETTLED 2026-10-27 (she re-authed /mcp):** O-1 minted as **VX-634**
(Improvement · Wording · Confirmed · Takes & Lenses · Low; standalone — a candidate rider, not
seated); VX-429/VX-592 moved In Progress with batch A2. VX-421/VX-248 → In Review at the ladder,
Done at the merge, as usual.

**HER WORD (2026-10-27, relayed by the coordinator, verbatim-faithful):** (1) walks MAY use the
clipboard — *"it's really very rarely an actual issue"*; her Mac↔Air clipboard sharing is on and
that is fine; the addendum's no-pasteboard rule is WITHDRAWN (a walker should still expect her
content can be on the pasteboard via Universal Clipboard — that is a fact to know, not a rule to
enforce). (2) The trashed walk note ("vx601 walk note", holding her URL) *"can be deleted
forever"* — **a standing duty for this run's NEXT window that launches the Debug app**: Trash ▸
that one note ▸ Delete forever, NOTHING ELSE, named in that window's RELEASE line. If no later
window launches the app, the coordinator folds it into a short window of its own.

## BATCH A2 RECORD — pane INPUT probes: VX-429 + VX-592 (implementer: opus-implementer, 2026-10-27)

**NOT DONE (first line, kept current):** the suite window (the orchestrator's: this session never
runs `xcodebuild test`, never launches the app, never claims the stage) — **every red and green
claim below is a PREDICTION, PENDING that window**; the USE walk (rows A1–A6 below, an Opus walker
under the orchestrator's claim — the A2 gate is use, not the pins); the cold ladder. VX-592 rides
*[removed for publication]*
four builds are done and the source is HEAD (`git diff` empty; no `VX601A2-REVERT` marker).

**LIVE STATUS**
- Reading — DONE: this file (members VX-429/VX-592, batches, ENVIRONMENT TRAPS, BATCH A RECORD +
  its rig diagnosis, the ORCHESTRATOR ADDENDUM incl. O-3 and her clipboard word),
  `notes/TEXTKIT2_NOTES.md` in full, `notes/SurfaceContracts.md` "The note",
  `notes/SessionResiliencyProtocol.md`; code: `Surface/PaneSurface.swift` (whole), the Takes hosts
  (`TakesShared.swift` cell, `TakesBoardView.swift` article/mini/card panes + gestures),
  `TakesViewModel.notePaneSelection`, `EditorTextView.mouseDown`, `PaneFocusCatcher`,
  `PressReporter`, the shared caret settle (`MarkdownCaretRescue`, `MarkdownFace.settleCaret`),
  the rigs (`PaneLifecycleTests`, `EditorTestSupport`, `TakePaneMeasureTests`' click). Linear was
  unreachable from this session (re-auth) — the ticket bodies were read from this file only.
- Trace — DONE (below): the PROBE (15 standalone offscreen binaries) found ONE AppKit mechanism
  that is BOTH members' symptom; the scout's hypothesis is FALSIFIED by measurement.
- Pins — DONE: `VariorumTests/CaretPressTests.swift`, 21 tests in 3 suites —
  `PaneCaretPressTests` (VX-429: 3 red-on-old + 4 guards), `EditorCaretPressTests` (VX-592 in
  Write: 2 red-on-old + 2 guards), `CaretPressRuleTests` (the pure rule: 10) (b62478c3; hardened
  37521ea6 — each pin asserts its own preconditions).
- Fix — DONE: `Surface/CaretPress.swift` (the rule, b62478c3; the wire's lone-caret gate,
  37521ea6) + one call line each in `PaneTextView.mouseDown` (VX-429) and `EditorTextView.mouseDown`
  (VX-592) (ca626390).
- Builds — DONE, all four carrying the FINAL tests (37521ea6), each build-for-testing GREEN, every
  binary newer than the final sources (logs `App/Variorum/DerivedData/logs/a2-*-build2.log`):
  post · pre · rev429 · rev592 (the BUILDS paragraph below).
- Red/green runs — PENDING (the orchestrator's window; the prediction table below).
- USE walk — PENDING (the orchestrator's claim, an Opus walker; rows A1–A6 below).
- Self-assessment + READY-FOR-SUITES — DONE (below, this commit).

**THE PROBE (standalone `swiftc` binaries in the session scratchpad, copies kept in the gitignored
`App/Variorum/DerivedData/a2probe/` — never the app, no store, no screen: windows at −20 000 never
ordered in; mouse events built with `NSEvent.mouseEvent` and QUEUED with `NSApp.postEvent` — never
a CGEvent, never the real pointer; every drag door intercepted, no pasteboard written). macOS
27.0.1, Swift 6.4, TK2 `NSTextView` unless said:**
1. *During a drag NO selection notification is posted* — one `textViewDidChangeSelection`, at the
   mouse-up (AppKit's `stillSelecting: YES` contract), for a press at the caret AND elsewhere. The
   scout's mechanism ("the first notification lands MID-DRAG… the VX-296 settle → `remeasure()`
   inside the tracking loop") cannot occur: there is no mid-drag notification for the settle to
   ride. **FALSIFIED.** (Suspect 2, the same-value `isEditable`/`noteLiveness` writes, needs an
   update pass mid-drag; nothing posts one — not pursued.)
2. *A text view that OVERRIDES `mouseDown` is on AppKit's CLASSIC mouse road*: a bare TK2
   `NSTextView` carries 9 gesture recognizers (click/press recognizers, `_NSTextSelectionTouchTracker`
   — the gesture-driven selection road), a `mouseDown`-overriding subclass carries NONE. Both
   Variorum surfaces that this batch touches override `mouseDown` — `PaneTextView` (every pane: the
   Takes cards and article, Lenses, Compare, the Write take panel, Canvas, the workbench, Read ▸ edit,
   the book Index, the read tier) and `EditorTextView` (Write) — so BOTH are on the classic road.
   (`CaptureNSTextView`/`CommentNSTextView` do not override it — the gesture road, unmeasured.)
3. **THE MECHANISM.** On the classic road, an EMPTY selection (a caret at `c`) whose caret has
   SETTLED (one run-loop turn after it was placed — the `NSTextInsertionIndicator` arrives then;
   "set + display" alone does not do it) counts as COVERING THE CHARACTER AFTER IT: a press anywhere
   on character `c`'s glyph box (measured: x from char 12's leading edge to char 13's, 83.8…91.5 pt,
   both affinities) is a press INSIDE THE SELECTION — and a press inside the selection that is HELD
   before moving (≥ ~0.15–0.2 s; 0.03–0.1 s still selects) begins a TEXT DRAG of the selection
   (`dragSelection(with:offset:slideBack:)` is asked, with `{c, 0}`). AppKit's own `dragSelection`
   answers `false` for the empty selection at once (no drag image, no pasteboard, no session —
   every door intercepted, none reached), AppKit consumes the rest of the gesture, and NOTHING
   HAPPENS: no selection, the caret stays, no notification. A press on the character BEFORE the
   caret, past the line's end (a caret before `\n`), at the text's end, or on a non-empty
   selection's neighbours selects normally; double/triple clicks select normally; a quick
   press-and-move (< ~0.1 s hold) selects normally — which is why it reads as "sometimes".
   **TK1 never does it** (same probe, `usingTextLayoutManager: false`: every case selects). Editable
   or not, key window or not, as a scroll view's document or not: the same.
4. So **VX-429's symptom exactly**: a drag starting at the caret's own position (on its right side,
   *[removed for publication]*
   *"when I try to drag a highlight from where my cursor is currently typing, it doesn't work"*: a
   drag-to-highlight STARTING AT THE CURSOR, in the live editor; the read panes "work" because they
   show no caret, so nobody presses on one (a read pane keeps a settled invisible selection —
   VX-296 — and the same press on it fails the same way, unseen). **"Write is fine" is predicted
   FALSE**: `EditorTextView` is on the same road; the Write pin decides (if it is green on old,
   VX-592's Write half is hollow and its fix is withdrawn).
5. *The other reading of VX-592* (drag-AND-DROP of an already-selected span out of the live pane):
   the source road is IDENTICAL live and read — a press inside a non-empty selection held past the
   delay asks `dragSelection` on both, and AppKit's own `dragSelection` reaches the session door
   (the deprecated `dragImage:at:offset:event:pasteboard:source:slideBack:`, refused in the probe)
   for an editable and a non-editable view alike. No source-side asymmetry exists to fix. The one
   live/read asymmetry left is the DESTINATION — only the live pane is editable (P-3), so a drop onto
   any read pane is refused by construction; a real drag session is needed to see it (a staged
   window) and whether read panes should accept drops is a product call (below, for #245).
6. *Levers measured* (a fresh settled caret per case): re-setting the SAME selection (silently or
   not), re-assigning `textSelections`, `updateInsertionPointStateAndRestartTimer` — all still drag
   nothing; declining `dragSelection` (returning false) — AppKit does NOT fall back to selecting.
   **Only moving the empty selection off the pressed character, silently (`stillSelecting: true`),
   in the same turn as `super.mouseDown`, works**: the press selects, a plain click on the caret
   still ends at `{c, 0}` with exactly ONE notification (identical to before), no extra notification.
7. *The pins' footing:* the whole mechanism reproduces INSIDE A MAIN-QUEUE CALLBACK (the test
   host's own shape — Swift Testing's main-actor job, where a nested run loop runs no main-queue
   hop) in a NON-key window never ordered in, with plain run-loop pumps as the settle (probe 14;
   the `NSTextInsertionIndicator` is not even present there, so the settle is a run-loop turn, not
   the indicator); and the wire's AppKit calls never drop a TK2 view to TK1 (probe 15).

**THE SETTLED DESIGN (the fix — one rule, two surfaces):** a pure rule (`Surface/CaretPress.swift`)
and one wire each surface calls immediately before `super.mouseDown`: on a PLAIN single click (no
modifiers, `clickCount == 1`, no marked text) while the selection is ONE empty range at `c < length`
and the press lands on either character beside the caret (`characterIndex(for:)` ∈ {c−1, c} — the
measured zone plus the boundary pixel; firing on `c−1` is harmless, measured), the caret is moved
silently to the far edge of the composed character at `c` (`stillSelecting: true` — no
notification), and AppKit's own tracking then does exactly what it does anywhere else. Nothing else
moves: a non-empty selection, a ⇧/⌘/⌥/⌃ click, a double click, a press elsewhere never reach the
lever; no storage or attribute write; no new liveness or selection authority (P-3); cost one
`characterIndex(for:)` per qualifying click (P1).

**AS BUILT (`Surface/CaretPress.swift` new; one call line each in `Surface/PaneSurface.swift`
and `Features/Editor/EditorTextView.swift`; no other production file).**
- *The rule (pure, `nonisolated enum CaretPress`):* `caretBeforePress(selection:pressedCharacter:text:)`
  — one empty range at `c < length`, the press on `c` or `c − 1` → the far edge of the composed
  character at `c`; anything else → nil. `isPlainSingleClick(type:clickCount:modifiers:)` — a left
  mouse-down, `clickCount == 1`, no ⇧/⌘/⌥/⌃ (caps lock is not a modifier of the gesture).
- *The wire (`CaretPress.clearPressedCharacter(in:for:)`):* the plain-single-click and
  no-marked-text gates, a lone-caret gate BEFORE any hit-test, one `characterIndex(for:)` at the
  press, the rule, then `setSelectedRange(_:affinity:stillSelecting: true)` — the caret's own
  affinity kept, no notification. Probe 15: 240 hit-tests and the selection writes leave a TK2
  view on TK2 (no `willSwitchToNSLayoutManager`, `textLayoutManager` still set).
- *Where it is called:* `PaneTextView.mouseDown` after the checkbox, link and ⌘-claim doors and
  immediately before `super` (VX-429); `EditorTextView.mouseDown` after the checkbox, link and
  block-pick doors and immediately before `super` (VX-592). The doors before it are unchanged and
  still win (a checkbox click, a ⌘-click never reach it).
- *What did NOT change:* no storage or attribute write (no stamp — TEXTKIT2 §3), no `runStructural`,
  `BlockRangeIndex` untouched, no liveness or selection authority added (P-3), no `Sync/`, no
  schema, no Shared/ file (**MOBILE PARITY: nothing mobile-visible** — both surfaces are Mac-only;
  the phone's text views are UIKit's own road). `CaptureNSTextView` and `CommentNSTextView` do not
  override `mouseDown` (AppKit's gesture road) and are not touched (residue R-A2-2).

**BUILDS (all four carrying the FINAL tests, 37521ea6; each build-for-testing GREEN; logs
`App/Variorum/DerivedData/logs/a2-*-build2.log`):** `DerivedData/vx601a2-post` = HEAD (the fix) ·
`DerivedData/vx601a2-pre` = both wires reverted (the rule type unwired) · `DerivedData/vx601a2-rev429`
= ONLY the pane wire reverted · `DerivedData/vx601a2-rev592` = ONLY the editor wire reverted. Each
revert committed-first, built, restored by `git checkout -- <file>`; no `VX601A2-REVERT` marker
remains; `git diff` empty. **No revert is in flight.**

**THE PREDICTION TABLE (the red/green runs — PENDING the orchestrator's window).** 21 tests in 3
suites; R = red, G = green; "guard" = green on both sides by design.

| # | Test | pre | rev429 | rev592 | post |
|---|---|---|---|---|---|
| 1 | `PaneCaretPressTests/aHeldDragFromTheCaretsOwnPlaceSelects` | R | R | G | G |
| 2 | `…/aHeldDragFromALandedCaretAtTheStartSelects` | R | R | G | G |
| 3 | `…/aReadPanesKeptCaretNeverEatsADrag` (two lines red: no selection, and a focus request) | R | R | G | G |
| 4 | `…/aHeldDragFromElsewhereSelects` (guard) | G | G | G | G |
| 5 | `…/aQuickDragFromTheCaretSelects` (guard — why it read "sometimes") | G | G | G | G |
| 6 | `…/aHeldClickOnTheCaretIsStillAPlainClick` (guard — one report, the place handed up) | G | G | G | G |
| 7 | `…/aShiftClickStillExtendsFromTheCaret` (guard) | G | G | G | G |
| 8 | `EditorCaretPressTests/aHeldDragFromTheCaretSelectsInWrite` | R | G | R | G |
| 9 | `…/aHeldDragFromWhereSheJustTypedSelectsInWrite` | R | G | R | G |
| 10 | `…/aHeldDragFromElsewhereSelectsInWrite` (guard) | G | G | G | G |
| 11 | `…/aHeldClickOnTheCaretStaysAClickInWrite` (guard) | G | G | G | G |
| 12–21 | `CaretPressRuleTests/*` (the pure rule — 10 tests) | G | G | G | G |

pre: 5 red · rev429: 3 red (#1–#3) · rev592: 2 red (#8–#9) · post: 0 red. **A pin green on its own
member's revert is HOLLOW — record it, never fix it:** #8/#9 green on pre/rev592 would mean Write
does NOT carry the mechanism in the host ("Write is fine" true) — then VX-592's Write half is
withdrawn (the editor wire reverted, the record says so); #1–#3 green on pre/rev429 would mean the
offscreen gesture cannot reach the mechanism — then VX-429 needs the staged real-pointer window
(below) before any fix stands. Every pin's preconditions are asserted in the pin (the click put the
caret where it says; the press is on the caret's own character and anchors at it — `anchors`), so
a red names its line.

## READY-FOR-SUITES — batch A2 (the orchestrator's window; from `App/Variorum/`)

All four builds are done; run `test-without-building` on each (no rebuild):
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<build> test-without-building -only-testing:…`
(array args — the window-a lesson). Confirm each "Test run with N tests in M suites" line and read
the `skipped:` lines (VX-604: 0 ran = no verdict). **No pin here can start a real drag session or
write a pasteboard on either tree** (a held press on an empty selection reaches AppKit's own
`dragSelection`, which answers false before any image, pasteboard or session — measured, probe 11);
no drag-out of a non-empty selection is ever pressed (that would start a real one). Each held
gesture costs ~0.5 s; the three suites run in well under a minute.

1. **THE RED RUNS** — on `vx601a2-pre`, `vx601a2-rev429`, `vx601a2-rev592`:
   `-only-testing:VariorumTests/PaneCaretPressTests -only-testing:VariorumTests/EditorCaretPressTests -only-testing:VariorumTests/CaretPressRuleTests`
   — expect **21 tests in 3 suites** each, the reds exactly as the table (pre 5 · rev429 3 · rev592 2).
2. **THE GREEN RUN, tier 1** (on `vx601a2-post`) — the pins plus EVERY suite that delivers a
   `mouseDown` to `PaneTextView` or `EditorTextView` (the touched road; grep `\.mouseDown(with:` in
   `VariorumTests/`) and the pane component's own suites:
   `-only-testing:VariorumTests/PaneCaretPressTests -only-testing:VariorumTests/EditorCaretPressTests -only-testing:VariorumTests/CaretPressRuleTests -only-testing:VariorumTests/TakePaneMeasureTests -only-testing:VariorumTests/BlockHighlightTests -only-testing:VariorumTests/WriteBlockSelectionTests -only-testing:VariorumTests/BlockSelectionRuleTests -only-testing:VariorumTests/TypewriterRoomTests -only-testing:VariorumTests/PhantomSpaceTests -only-testing:VariorumTests/PaneSurfaceTests -only-testing:VariorumTests/PaneFindFaceTests -only-testing:VariorumTests/PaneUndoLifecycleTests -only-testing:VariorumTests/PaneRebindTests -only-testing:VariorumTests/CanvasSwitcherRebindTests -only-testing:VariorumTests/PaneTextAuthorityTests -only-testing:VariorumTests/PaneMarkdownCaretFaceTests -only-testing:VariorumTests/MarkdownCaretFaceTests -only-testing:VariorumTests/MarkdownActsTests -only-testing:VariorumTests/IndexClickCaretTests`
   — 19 suites, all green expected.
3. **THE GREEN RUN, tier 2 — the battery** (on `vx601a2-post`): batch A's 196 suite types (the
   READY-FOR-SUITES — batch A list above, verbatim) PLUS `CaretPressRuleTests PaneCaretPressTests
   EditorCaretPressTests PhantomSpaceTests TypewriterRoomTests` — **201 suite types**. Standing reds
   that are NOT this batch's, if met: VX-337's two load-dependent flakes and the trait-skipped
   singleton-window oracle suite (as batch A's list says).

## THE USE WALK — batch A2 rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug
build from `DerivedData/vx601a2-post`; never press Resume Sync; restore exactly as found)

The walk REQUEST names: one fresh walk note minted by quick entry with ONE ordinary paragraph
(e.g. "alpha bravo charlie delta echo foxtrot golf hotel india juliet") plus ⌘T for a second take;
it leaves to the Trash at the end. The press is `cliclick` `dd:` at the caret's own spot (1–2 px
right of the drawn caret), `w:500`, then `dm:` steps and `du:` — the HOLD is the point (a quick
`dd`→`dm` selects on the old build too). Her clipboard word (2026-10-27) stands: the walk may use
the pasteboard; it should not need to. Captures one per row per voice, both voices (Study first —
the store's voice — then Terminal, restored to Study). The standing duty of this run's NEXT Debug
window (the earlier walk note's Delete forever, nothing else) is the orchestrator's to carry in
the same REQUEST.
- **A1 — VX-429, her gesture (Takes ⌘2):** click between two words to put the caret; wait ~1 s;
  press ON the caret, hold ½ s, drag right ~3 words, release → **those words are selected** (from
  the caret). Then the same from the caret leftwards. (Old build, for contrast if the window
  allows: nothing selects, the caret stays.)
- **A2 — VX-429, the landed caret:** ⌘1 then ⌘2 (or re-open the note in Takes) so the pane lands
  its caret by itself; press on that caret, hold, drag → selects.
*[removed for publication]*
  press on the caret, hold, drag → selects. Then in a Takes take card (a bloomed fan): type a word,
  the same → selects.
- **A4 — no regression:** (a) a held CLICK on the caret, no move → the caret stays, nothing else
  happens; (b) ⇧-click extends from the caret; (c) double-click selects a word, triple a line;
  (d) **drag-and-drop still works**: select a word in the live pane, press INSIDE the selection,
  hold, drag it two words along, drop → the word MOVES (then ⌘Z undoes it); the same in Write.
- **A5 — RECORD ONLY (VX-592's other reading, for her):** in Takes with the fan open: select a
  word in the LIVE pane and drag it onto ANOTHER take's card (a read pane) → record what happens
  (expected: the drop is refused — a read pane accepts no drop, P-3 by construction); then select a
  word in a READ card and drag it into the live pane → record. No verdict; it rides #245.
- **A6 — RECORD ONLY (residue R-A2-2):** the quick-entry box and a comment field run AppKit's other
  (gesture) road and were not changed: type a word in quick entry, press on the caret, hold, drag →
  record whether it selects.

## SELF-ASSESSMENT (the first of the two reviews — the implementer's)

- **Scope and seams.** One new file (`Surface/CaretPress.swift`: a pure rule + one wire), one call
  line in each of `PaneTextView.mouseDown` and `EditorTextView.mouseDown`, one new test file. Zero
  `Sync/`, schema, Shared/, `BlockRangeIndex`, structural door, storage or attribute write. No TK1
  API (the wire's calls are `NSTextView`/`NSTextInputClient` API; probe 15 shows no fallback). P-3:
  no second liveness or selection authority — the move happens inside one gesture of the view that
  already owns the selection and is never reported. P1: one hit-test where she pressed, only for a
  plain single click on a lone caret.
- **The trace held, and replaced the brief's.** The scout's mechanism was falsified by measurement
  (no mid-drag notification exists); the measured one explains every word of both reports and the
  "sometimes" (the hold), and predicts the brief's "Write is fine" WRONG — the Write pins decide.
- **What could regress, and why I think it doesn't.** (1) *A click at the caret:* the caret now
  makes one silent trip and AppKit puts it where the click always put it, with the one notification
  it always posted (pinned both surfaces; probe 9). (2) *Typing attributes after such a click* are
  re-derived from the text at the caret, exactly as for any click elsewhere — the surfaces are
  plain text whose face is re-derived per edit, so nothing she types changes. (3) *Drag-and-drop of
  a real selection* never reaches the rule (a non-empty selection is gated before the hit-test,
  pinned in the rule suite); the walk's A4d checks it live. (4) *⇧/⌘/⌥/⌃ clicks, double/triple
  clicks, marked text* are gated out (pinned / by construction). (5) *The doors before it*
  (checkbox, link, ⌘-claim, block pick) still run first and still consume their clicks.
- **Risks I see.** (a) Pins written without a run, on a synthesized gesture: the shapes are the
  probes' own (14 standalone binaries, including the test host's main-queue-callback shape, probe
  14), but a harness surprise is possible — a red on `post` is a pin to fix, never a reason to touch
  the production change without a trace; a green on `pre` is a hollow pin and says so above.
  (b) *A point-release dependency:* the rule leans on a 27.0.1 TK2 behaviour; if a later macOS
  drops it the rule is a harmless no-op, and if it moves the zone, the ±1 window covers the
  boundary pixel — TEXTKIT2_NOTES §5's re-verify should name `CaretPressTests` (a canon line for
  the closeout, the orchestrator's). (c) The gesture-road text views (capture, comments) are
  unmeasured (R-A2-2).

**PROVISIONAL / FOR #245 (the orchestrator's bundle — I do not touch QUESTIONS.md):**
*[removed for publication]*
  at the cursor (FIXED here, both surfaces). If she meant drag-AND-DROP of an already-selected span
  out of the live pane: no source-side mechanism exists (the AppKit source road is identical live
  and read — probe 12), and the one live/read asymmetry is the destination — a READ pane accepts no
  drop, by construction (P-3). Options if that is what she meant: (a) keep it — a read pane is
  projection-authoritative, so dropping text there means nothing until it is live (BUILT: unchanged);
  (b) a drop on a read pane makes it live and lands the text there (focus + edit in one gesture);
  (c) a drop on a read take card offers a door (insert into this take · new take from the dropped
  text). Most spec-defensible: (a). Walk row A5 records the facts for her.
- *Carried, not new:* none.

**RESIDUE / NOT MINE (for the orchestrator to ticket or drop):**
- **R-A2-1 (O-3's caret, traced — not this mechanism):** after Canvas, Takes' head pane landed
  before the "x" typed on the Canvas card because Canvas reports the focused block with NO caret
  offset (`CanvasViewModel.focus`, 18k C5 — "a canvas caret reporter would be a design act"), so
  the note's memory kept the offset from before the "x" and Takes' `.offset` landing used it. A
  recorded design limit, Canvas-only (Debug); a Canvas caret reporter is her call.
- **R-A2-2 (the gesture road, unmeasured):** `CaptureNSTextView` (quick entry, the capture box) and
  `CommentNSTextView` do not override `mouseDown`, so they run AppKit's gesture-recognizer road,
  which an offscreen probe cannot drive (the window road delivers nothing to an unordered window,
  probe 3). Walk row A6 records whether the same press fails there; a fix would be its own ticket.
- **R-A2-3 (a TEXTKIT2_NOTES §3 entry is owed at closeout):** the measured 27.0.1 fact — on the
  classic (`mouseDown`-override) road a settled empty selection covers its next character for the
  drag-or-select decision; held presses there drag nothing; TK1 never does — belongs in the
  build companion beside the other measured findings, pinned in `CaretPressTests`. Canon is the
  orchestrator's at closeout; the text is ready here.

## WINDOW a2b — batch A2's runs (the orchestrator, 2026-10-27, claim vx-601-tests-a2b from ~21:59)

**Red runs on the three trees: 21 tests in 3 suites EXECUTED on each, zero host restarts, zero
crash dialogs.** `vx601a2-pre` — 5 red; `vx601a2-rev429` — 3 red (exactly the pane pins:
caret's-own-place, landed-at-start, read-pane's-kept-caret); `vx601a2-rev592` — 2 red (exactly the
Write pins: from-the-caret, from-where-she-just-typed). The union is pre's five; the partition is
clean; **no pin is hollow — both wires STAND.** The Write-side pins red on pre settle the
discrimination the implementer designed: **the ticket's "Write is fine" was FALSE** — Write had
the same held-press-at-the-caret dead drag, and VX-592's EditorTextView wire is real, not
withdrawn. Red-on-old is verified by revert PER MEMBER. Logs: `DerivedData/logs/red-vx601a2-*.log`.

**Tier 1 on `vx601a2-post`: 149 tests in 19 suites PASSED, 0 skipped** (every suite delivering a
mouseDown to either view, plus the pane family — batch A's suites among them, still green over the
new wires). Log: `DerivedData/logs/tier1-a2-post.log`.

**The 201-suite battery on post: 1178 tests in 201 suites PASSED** (670 s; 14 known issues — the
deliberately-loud pinned set, unchanged; zero host restarts). Log:
`DerivedData/logs/battery-a2-post.log`.

**Window a2b verdict: batch A2's suite evidence is COMPLETE** — red-on-old by revert per member
(both wires standing; "Write is fine" falsified), tier 1 green, the battery green. The USE walk
(A1–A6) is the remaining acceptance evidence; the old walk note's delete-forever rides that
window.

## THE WALK RECORD — batch A2 (A1–A6) (Opus walker, claim `vx-601-walk-a2`, 2026-10-27 22:17–22:33 MDT)

Build: `App/Variorum/DerivedData/vx601a2-post/Build/Products/Debug/Variorum.app` (dev store, pid 64032
for the whole walk — ONE launch, no crash, no relaunch; no What's New sheet). Captures (gitignored):
`App/Variorum/DerivedData/walkshots-vx601a2/` — `leg0-*` as-found, `del-before*` the Trash before
the duty, `a1*`/`a2*`/`a3*`/`a4*`/`a5*`/`a6*` Study, `t-*` Terminal, `r-*` leave-taking. The press
is exactly the row's: `cliclick m: w:300 dd:<caret+1–2 pt> w:500 dm:… du:` under
`Tools/WalkKit/guard.sh` every step (HID idle rests ≥ 2 s between synthetic steps — the guard
cannot tell the walker's own last click from a person; one step was refused for that and re-run).
Window 1240×840 at (244,155).

**As-found (leg 0, before any act):** Bookcase, no books; the held banner "This is your library as of
October 20, 2026…" with Resume Sync (NEVER pressed); "Sync off (dev store)"; Study voice, app Dark,
macOS Light (system appearance never touched); Library = ONE note ("The walk leaves a stone here…",
edited Oct 19); the twelve-words card on the Bookcase (never touched). Trash (read after its
"The Trash is empty." loading face cleared, ~10 s): top row "2026-10-27 · note · deleted Oct 27, 2026
at 8:57 PM", then the Sherlock seed set (notes + "the adventures of sherlock holmes" book and 13
notes, all 5:46 PM). Not opened (untouched by any act): sign-in, MCP, Walk Wing.

**THE DELETION DUTY — NOT DONE, held by its own guard (F-A2W-1).** The brief named the note
"vx601 walk note" with an 8:57 PM stamp and said: title or stamp not matching exactly ⇒ do not
delete, record, report. The Trash row's STAMP matches (8:57 PM, the only 8:57 row) but its TITLE
reads **"2026-10-27"** — quick entry titled the batch A walk note by its date (this record's batch A
walk section says so: "titled '2026-10-27'"; "vx601 walk note…" is its first block's TEXT). The row's
destructive button also reads **"Delete Now"**, not "Delete forever". Nothing was pressed; the row is
still in the Trash (`del-before2-w0.png`, `r-trash-w0.png`). It is almost certainly the right note —
the orchestrator's next REQUEST can name it as it shows: **"2026-10-27 · deleted 8:57 PM ▸ Delete
Now"**.

**The walk note:** quick entry ("alpha bravo charlie delta echo foxtrot golf hotel india juliet.
kilo lima mike november oscar papa quebec.") ⏎ → a one-block note shown as "2026-10-27"; retitled in
Write's title field to **"vx601 a2 walk note"** (so the Trash never holds two same-named walk
notes); Write typing added " romeo"; ⌘T → ⑂2. Takes below: take 1 = chosen, take 2 = ⌘T's take
(edited: " sierra", later " yankee"; Terminal Write added " xray" to the chosen).

| Row | Study | Terminal | What was seen |
|---|---|---|---|
| **A1** (VX-429, Takes, her gesture) | **PASS** | **PASS** | Collapsed fan's pane: click placed the caret in "delt\|a"; ~1.5 s; held press ON the caret, drag right → **"a echo foxtrot golf" selected FROM the caret** (`a1-right`). Leftwards: caret before "india", held press, drag left → **"foxtrot golf hotel " selected, ending AT the caret** (`a1-left`). Terminal: caret before "golf" → "golf hotel india" (`t-a1`). |
| **A2** (VX-429, the landed caret) | **PASS** | **PASS** | ⌘1→⌘2: the pane landed its own caret (before "foxtrot" — the previous selection's start; in Terminal, before "kilo"); held press on it, drag → **"foxtrot golf hotel" selected** (`a2`); Terminal → "india juliet. " (`t-a2`). |
| **A3** (VX-592, Write + a take card) | **PASS** | **PASS** | Write: typed " romeo" at the block's end, no move, held press at the caret, drag left → **"pa quebec. romeo" selected** (`a3w`); Terminal " xray" → "quebec. romeo xray" (`t-a3w`). Takes, bloomed fan (expand all), take 2's card: typed " sierra", held press at the caret, drag left → **"papa quebec. romeo sierra" selected** (`a3t`); Terminal " yankee" → "romeo sierra yankee" (`t-a3t`). |
| **A4** (no regression) | **PASS** | (d)-Write only: **PASS** | Take 2's card: (a) held CLICK on the caret (before "kilo"), no move → no selection, text unchanged; the caret blinked out of two captures, so ⇧→ probed it: it selected exactly "k" — **the caret stayed where it was** (`a4a*`). (b) ⇧-click → **extended from the caret: "kilo lima mike"** (`a4b`). (c) double-click → **"hotel"** (`a4c-dbl2`; the first double-click hit the space between two words and selected the space — ordinary AppKit); triple → **the whole take's paragraph** (`a4c-tri`; macOS's Writing Tools badge appeared beside it — the system's). (d) Takes: "hotel" selected, pressed INSIDE, held, dragged two words along, dropped → **MOVED** ("…golf india juliet. hotel kilo…"), **⌘Z restored it** (`a4d-t*`); Write: same → moved, ⌘Z restored (`a4d-w*`). Terminal: (d) in Write the same (`t-a4d-w*`); (a)–(c) and (d)-Takes not repeated in Terminal (window). |
| **A5** (RECORD ONLY, Q-A2-1 → #245) | recorded | not repeated | Fan open. LIVE take-2 card: "lima" selected, held, dragged onto the chosen (read) card over "delta", released → **nothing: no drop, no text moved, both cards unchanged** ("lima" still selected in take 2) (`a5-l2r`). READ → live: a double-click on the chosen card made THAT card the live one ("mike" selected, active colour; take 2's "lima" went inactive grey) — so a read card cannot be the drag's source as such; dragging "mike" into take 2's card → **nothing: no drop, both unchanged** (`a5-r-sel`, `a5-r2l`). No verdict. |
| **A6** (RECORD ONLY, R-A2-2) | recorded | not repeated | **Quick entry: SELECTS** — typed text, caret at its end, held press at the caret, drag left → "golf hotel india juliet" selected (`a6-qe-crop`). **Comment field (Comments sheet): SELECTS** — typed "tango uniform victor whiskey", held press at the caret, drag left → "uniform victor whiskey" selected (`a6c`). The draft was then cleared (⌘A ⌫) and the sheet closed — no comment added. Both on AppKit's other road, unchanged by the batch, already select. |

**Findings and observations (none blocks a row):**
- **F-A2W-1 — the deletion duty's naming** (above): the 8:57 PM note's Trash title is "2026-10-27",
  and the Trash button is "Delete Now". Left in place by the guard; the orchestrator's to re-name.
- **O-A2W-1 (unverified, for whoever touches capture):** typed into quick entry via System Events,
  `{t:"vx601 a2 walk note"}` rendered with CURLY quotes (smart quotes on in the box), and the
  "name it '…'?" offer kept proposing the first-words title — the token looked unrecognized. It was
  deleted before submitting, so whether curly quotes break the capture microsyntax is NOT tested.
- **O-A2W-2 (prefs shape):** batch A's walk wrote four per-note keys (canvas/currentBlock/postMode/
  takesViewMemory); this walk wrote only `currentBlock.` and `postMode.` — recorded, not judged.

**Leave-taking / returned:** palette "Use Study Voice" (the Terminal switch was the palette's "Use
Terminal Voice"); Appearance never touched (app Dark throughout). The walk note ▸ note ▾ ▸ "Delete
Note…" ▸ Delete ("The note goes to the Trash for 30 days…"; receipt "Note moved to the Trash — 30
days to put it back."); NOT deleted forever. Verified after: Library = the one Oct-19 note; Trash
top row **"vx601 a2 walk note · note · deleted Oct 27, 2026 at 10:31 PM"**, then "2026-10-27 · 8:57
PM" (STILL PRESENT — F-A2W-1), then the Sherlock set in the same order (Trash = as-found + 1); held
banner present (Resume Sync never pressed); "Sync off (dev store)"; Study + app Dark; ended on the
Bookcase with the twelve-words card as found (`r-bookcase-w0.png`). Quit by bundle id
`io.lduarte.Variorum.debug` 22:32:36; guards `pgrep -lx Variorum` / `pgrep -lf "MacOS/Variorum$"`
empty before launch and after quit.

**Prefs (`io.lduarte.Variorum.debug`, `/tmp/vx601a2-prefs-before.plist` → after):** ADDED two
per-note keys for the walk note — `currentBlock.` / `postMode.` `C2C2D07F-F967-45AB-AA1D-B1A8D278F734`
— both DELETED. CHANGED bookkeeping left as is for the orchestrator: `IdleCommitSweepMark.Variorum-dev`
(02:04:19Z → 02:17:33Z), `variorum.backup.log` (the per-launch dev-store backup entry),
*[removed for publication]*
Final export (`/tmp/vx601a2-prefs-final.plist`) vs before: nothing added, nothing removed.

**Deletion duty, second leg (same claim, 22:34–22:37 MDT; the coordinator's corrected naming: batch
A's walk note was auto-titled by its date).** Guards empty; relaunched the same `vx601a2-post` build
(pid 67144; no What's New sheet). Trash read after its loading face (~9 s): row 1 "vx601 a2 walk
note · 10:31 PM", row 2 **"2026-10-27 · note · deleted Oct 27, 2026 at 8:57 PM" — the only row at
that stamp**, then the Sherlock set (5:46 PM) — `leg2-trash-before-w0.png`. Pressed that row's
**"Delete Now"** once → the confirm "Delete this note for good? It skips the rest of its 30 days —
there's no putting it back." (Delete for Good / Cancel). **The walker's turn ended here, mid-leg**
(the app left running, the confirm open, nothing in it pressed); on resume, the state was read
FIRST before any press: the confirm still open over the Trash, the 8:57 PM row still standing,
row 1 and the Sherlock set unchanged (`leg2-now-w0.png`). Then pressed **"Delete for Good"** — that
one row, nothing else; the Trash never emptied. Receipt: "The note is gone from the app now — the
app's own cleanup removes the bytes." The list refreshed ~5 s later. **After:** the 8:57 PM
"2026-10-27" row GONE; "vx601 a2 walk note · 10:31 PM" still on top (it STAYS in the Trash); the
Sherlock set directly beneath, unchanged and in order through "A Scandal in Bohemia"; held banner
present, Resume Sync never pressed; "Sync off (dev store)"; Study + app Dark
(`leg2-trash-after2-w0.png`). Observation O-A2W-3 (pre-existing, not this batch): that receipt line
draws over the bottom-most visible Trash row's text. Quit by bundle id (22:36); both strict guards
empty. **Prefs after the leg:** nothing added or removed vs `/tmp/vx601a2-prefs-before.plist`; the
*[removed for publication]*
and was restored by its exact key to **29** (`defaults write -int 29`, read back 29, an int as
before; every other library's counter unchanged against the before-export); remaining CHANGED =
bookkeeping only (`IdleCommitSweepMark.Variorum-dev`, `variorum.backup.log`). Final export
`/tmp/vx601a2-prefs-final2.plist`. F-A2W-1 is CLOSED by this leg.

## BATCH B RECORD — the board and its doors: VX-428 + VX-577 + VX-594 (implementer: opus-implementer, 2026-10-27)

**NOT DONE (first line, kept current):** the suite window (the orchestrator's: this session never
runs `xcodebuild test`, never launches the app, never claims the stage) — **every red/green claim
and every VX-428 measurement below is a PREDICTION or a PENDING number until that window**; the
USE walk (rows B1–B6 below, an Opus walker under the orchestrator's claim); the cold ladder. The
⌘T caret-following half of VX-594 is HOLLOW (nothing built — the guards pin it). No revert is in flight — all six trees are built and the source is HEAD.

**LIVE STATUS**
- Reading — DONE: this file (the sitting record R-601-2/R-601-4, members VX-428/VX-577/VX-594,
  batches, ENVIRONMENT TRAPS, BATCH A + A2 records incl. the rig diagnosis and the launch gate
  `HostLaunchSettle`), `notes/SurfaceContracts.md` "The note", `notes/TEXTKIT2_NOTES.md` in full,
  `notes/SessionResiliencyProtocol.md`, the live tickets VX-428/VX-594 (body + her triage comment +
  the pricing scout) read through Linear (read-only); code: `EditorRouter`, `TakesBoardLayout`,
  `TakesViewModel` (lifecycle, adopt, focus/blur/park, expansion forwards, reveals, the R73 key
  family), `TakesChoreographer` (landings), `TakesBoardView` (init, header, articleRow, the slot-split
  bloom, cards, the routed handler), `TakesLensFilterController`, `TakesFindController.land`,
  `TakesShared` (cell menu, `TakeCardActs`/`TakeCardMenu`), `WriteTakesPanel`, `LensesBoardView`'s
  ⌘T arm, `TakesBottomBar`'s take doors, `EditorView`'s ⌘T arm, `CapabilityRegistry`'s take family
  + `Capability`, `PostDetailView`'s mode switch; the pins `TakeCardDoorTests`, `TakesBoardTests`,
  `TakesArticleScrollTests`, `TakesBoardSoakTests`, `TutorialWalkTests.branchOnAClosedFanRevealsTheNewTake`.
- Trace — DONE (below). VX-428's and VX-577's briefed mechanisms CONFIRMED; VX-594's ⌘T half
  FALSIFIED (it already follows the caret — HOLLOW); one widening each for VX-428 (slot split's entry
  ring) and VX-577 (the ring under expand-all in slot split).
- Fixes + pins — DONE (110e038c3), all three members; `DerivedData/vx601b-post` build-for-testing
  GREEN (log `App/Variorum/DerivedData/logs/b-post-build.log`; the one warning in a touched file,
  `TakesBoardView.swift` `TakeCardProbeSlot.space` from a Sendable closure, is pre-existing).
- Revert trees — DONE: all six trees build-for-testing GREEN, every one carrying the FINAL tests
  (the BUILDS paragraph below). **No revert is in flight; the source is HEAD** (`git diff` empty, no
  `VX601B-REVERT` marker anywhere).
- Red/green runs + the VX-428 measurement — PENDING (the orchestrator's window; READY-FOR-SUITES below).
- USE walk — PENDING (rows B1–B6 below).
- Prediction table, READY-FOR-SUITES, walk rows, self-assessment — DONE (below).

**THE TRACE.**

*VX-428 — CONFIRMED.* (1) `PostDetailView` (`:446-448`) mounts `TakesBoardView` only while the mode
is Takes, keyed `.id("takes-<post>")`, so every mode switch destroys the board and its per-mount
`@State` `TakesViewModel`. (2) The open-fan set is `TakesBoardLayout.expandedBlocks` inside that model
(its doc said "session-only … nothing persists", i.e. mount-only in practice), so it dies with the
board: a fresh board opens every fan closed (walk observation O-3 of batch A saw exactly this). (3)
The session's `EditorRouter` survives remounts and already holds the article's per-note memories
(`takesArticlePlaces`, `takesArticleCurrentRows`, `takesShowFilters`). (4) `TakesBoardView.init`
(`:175-189`) sets `landingEnabled = true` on the model BEFORE `State(initialValue:)` — the
construction-time fact (17q R1-1) — so a seed placed when that flag goes true is in the layout
before the view's first body, hence before the first article geometry report. (5) **The widening
(found by my own read): in SLOT SPLIT a bloomed fanned block has no article cell** (`articleRow`
replaces it with the fan's cards, `TakesBoardView.swift` `splitBloomed`), and the N9 entry arm
(`TakesChoreographer.consumeLandings`) rings `takes-main|<block>|<chosen>` — so a board BORN with its
entry block's fan open (possible only once fans survive the switch) would ring a pane no surface
renders (the R112 class). Before VX-428 a remount never had an open fan (follow-the-scroll's
visibility blooms arrive after the first adoption), so the road is new with this member.

*VX-577 — CONFIRMED.* `TakesViewModel.offersExpandAll` (`:295-297`) returned
`projection.fanStyle != .slotSplit` citing R25's "slot split IS a whole-post fan presentation"; the
header (`TakesBoardView.swift` `headerControls`) renders "expand all"/"close all" only under that
gate; ⎋ (`onExitCommand` → `closeAllFans`) and the menu's Close All Takes always reached slot split.
`expandAllFans()`/`closeAllFans()` themselves never read the style. Under slot split a bloom draws
the fan as cards in the article cell's place, each split paging under its own key (the block id),
follow-the-scroll blooming visible fanned rows, the lens filter's `paneIsShown` (`:192`) already
knowing the article cell is gone under a split. **The widening:** expand all in slot split REPLACES
the article cell the ring may be in — the ring would be left keyed to `takes-main|…`, a pane no
surface renders (the same R112 class; the per-block ⑂ badge and ⌘⇧T on the live block reach it too
today — residue R-B-1).

*VX-594 — the door CONFIRMED missing; the ⌘T half FALSIFIED (HOLLOW).* (a) The take card's ⌄ menu
(`TakeCardMenu.rows`, `TakesShared.swift`) carried Archive · Label · Lock · Delete; a fan card's pane
(`takeMiniPane`, `CollapsibleTakeCard`, Write's panel cards) has NO Variorum context menu; only the
ARTICLE cell's right-click offers "＋ New take — branch of this one", and the article shows the
CHOSEN take. So a not-chosen take had no door that branches from IT without first clicking into it.
(b) **Every ⌘T host already resolves the source to the take the caret is in**: the Takes board's
`.branch` arm branches `model.focusedPane`'s take and refuses with no ring
(`TakesBoardView.handleTakesCommand`); the Lenses board's diverges from the focused pane's take;
Write's take panel's branches the ring's take, else the shown one (P-VX150-1); the Takes bar's "+
take" and block ▾ row use `focusedPane?.variantID ?? slot.variantID`; Write's editor's caret is
always in the take Write shows (`mintCaretTake`). `branchVariant` takes any parent. So her
confirmed semantics ("if your caret is in a particular take the keyboard shortcuts will work for
that too") ALREADY HOLD — the guards below pin them and are predicted GREEN on the pre-fix tree:
**DISMISSED AS HOLLOW** (recorded, nothing built). The blank doors (⌥⌘T, ⇧⌥⌘T) already target the
caret's block; a blank take has no parent (`newBlankVariant` writes `parent_variant_id = NULL` —
"a blank/new take is a different gesture", OverallModel §3), so R-601-4's words do not reach them
and there is no edge to rule.

**AS BUILT.**
- *VX-428:* `EditorRouter.takesExpandedBlocks: [String: Set<String>]` (`@ObservationIgnored`,
  session-only, never persisted/synced; no empty set stored). `TakesBoardLayout` gains
  `expansionSink` (called after every CHANGE — `bloom` only when it inserted, `toggleExpanded`,
  `expandAll`/`closeAllFans` only when the set changed; the assignments themselves are unchanged, so
  observation is byte-identical), `seedExpansion` (no report) and `pruneExpansion(to:)`.
  `TakesViewModel.landingEnabled`'s false→true edge runs `openExpansionMemory()` (installs the sink,
  seeds from the session; prunes at once if a projection is already in hand); `rememberExpansion`
  writes (guarded by `landingEnabled`, equality-gated); `adopt` prunes the seed against the FIRST
  projection only (inside a showing nothing is pruned — a ⌥⌘Z that puts a block back brings it back
  open). Write's panel and the Lenses board never set `landingEnabled`: never seeded, never write.
  The widening's fix: `landAuthorityFocus` (the N9 entry door, the choreographer's only call) maps an
  article key to the card that renders the same take when a slot-split bloom replaced its cell
  (`paneRenderingArticleTake`, read AFTER the filter's reveal, which can itself bloom), paging it
  into view — the find's and the room's own mapping. The shared predicate is
  `TakesViewModel.slotSplitReplacesArticleCell(_:)` (`articleRow`'s branch, asked of the model).
  Doc lines superseded in place, citing R-601-2/R-VX170-5: `TakesBoardLayout`'s header and its
  "Expansion" MARK (the mount-only letter), `TakesBoardView.init`'s construction-time comment.
- *VX-577:* `offersExpandAll` is an exhaustive switch answering true for all four styles (a future
  style decides for itself), its doc citing VX-577 and her words. `expandAllFans()` ends the ring
  by the flushed `blur()` when, after the expansion, the ring's article cell is replaced by a
  slot-split bloom (P-B-1, PROVISIONAL). Nothing else in the style's rendering needed a change:
  page offsets are per block; follow-the-scroll composes (`isBloomed`'s OR); the filter's `.ordinary`
  rows for expanded blocks follow the board's rule.
- *VX-594:* `.newTake` declares the `.surface` door (the `.archiveTake` shape — the card's row names
  its target; the chord acts on the caret's take). `TakeCardActs` gains `branch`; `TakeCardMenu.rows`
  leads with `.newTake` titled `TakeCardMenuCopy.newBranchedTake` = "New branched take (⌘T)" (her
  ruled words + the declared chord; the `chorded` drift guard walks it); `TakeCardMenu.capabilities`,
  `TakesBoardView.surfaceCapabilities` and `WriteTakesPanel.surfaceCapabilities` list it. The card
  acts are wired ONCE on the model — `TakesViewModel.cardActs(for:columnID:)` (in `TakesShared.swift`)
  — for both hosts, the four old closures byte-identical in behavior; the branch is
  `branchTakeRevealed(blockID:, from: <the card's take>, preferredColumnID: <the host's card
  namespace>)`, so the ring lands on the new card where the host renders it (the board's fan cards,
  Write's panel's own column — the panel's ⌘T road exactly).
- *What did NOT change:* no operation, no schema, no `Sync/`, no `PaneSurface`/`EditorTextView`/
  `BlockRangeIndex`, no structural door, no Shared/ file (`AppSession` untouched — the router is
  Mac-only): **MOBILE PARITY: nothing mobile-visible.** No TK1 API, no attribute stamp.

**PROVISIONAL (for the orchestrator's #245 bundle — I do not touch QUESTIONS.md):**
- **P-B-1 — the ring when expand all hides its cell in slot split.** Options: (a) end the ring by
  the flushed blur — BUILT, the most spec-defensible: it is the `show ▾` filter's ratified rule for
  exactly this shape (R-VX170: her own view change that hides the live pane blurs it, because the
  view she asked for is exactly what shows), and it satisfies R112; (b) follow onto the card that
  renders the same take (the find/room/step mapping — those are TARGETED landings, not page-wide
  reshapes; the caret would land at the card's END, `fanCaretLanding`'s `.leave`); (c) leave the ring
  keyed to the vanished cell (the pre-fix shape: stranded, keyboard acts reach an invisible take,
  close-all revives it) — refused by R112.
- *Carried, not new:* the entry ring's slot-split mapping is the find's/room's existing mapping
  applied to the N9 door; a card going live by a landing takes `fanCaretLanding`'s `.leave` (the
  shipped END) rather than the remembered caret place the article cell would honour — a fan card has
  never honoured it (residue R-B-3).

**RESIDUE / NOT MINE (for the orchestrator to ticket or drop):**
- **R-B-1 (pre-existing, same class as P-B-1):** in slot split the per-block bloom doors — the ⑂
  badge on the live article cell, ⌘⇧T (`toggleFocusedFan`) — replace the cell the ring is in and
  strand it; and in EVERY style close all / ⎋ with the ring in a fan card strands it (the card
  vanishes). P-B-1's blur (or its ruled successor) would extend to them in one helper.
- **R-B-2 (pre-existing, traced):** the choreographer's `.bloom` landing (Write panel's "Open Takes
  mode", Lenses' ⌘⇧T) blooms the block and then rings `takes-main|…` — in slot split a pane no
  surface renders. `paneRenderingArticleTake` is the one-line fix; not built (its own pin owed).
- **R-B-3 (observation):** a fan card that takes the ring by a landing puts the caret at its END
  (`TakesFindController.fanCaretLanding` honours only `.select`), where the article cell lands at
  the remembered place — so in slot split, an entry onto a remembered-open block lands at the end of
  the take rather than where she was. Her call if it matters.

**BUILDS (all six carrying the FINAL tests of 110e038c3; each build-for-testing GREEN; logs
`App/Variorum/DerivedData/logs/b-<tree>-build.log`; each revert tree built incrementally from an APFS
clone of the post tree's DerivedData, its app, debug dylib and test bundle all rebuilt — mtimes
checked):** `DerivedData/vx601b-post` = HEAD · `vx601b-pre` = all three members reverted ·
`vx601b-rev428` = VX-428 reverted (`openExpansionMemory` returns at once — no seed, no write-back —
and the entry ring's slot-split mapping off) · `vx601b-rev428map` = ONLY the mapping off (the memory
on — proves the slot-split ring pin is not riding the memory alone) · `vx601b-rev577` = VX-577
reverted (the old `!= .slotSplit` gate, no blur) · `vx601b-rev594` = VX-594 reverted (the
`.newTake` row removed from `TakeCardMenu.rows`; the declaration and the lists kept, so the tree
compiles — a behavioural revert). Each revert: edited on the committed tree (the record named it
first), built, restored by `git checkout -- <file>`; restore verified by an empty `git diff`.

**THE PREDICTION TABLE (the red/green runs — PENDING the orchestrator's window).** R = red, G =
green; ×n = a parameterized test's cases. "guard" = green on every tree by design; HOLLOW = the ⌘T
half of VX-594, green everywhere.

| # | Test | pre | rev428 | rev428map | rev577 | rev594 | post |
|---|---|---|---|---|---|---|---|
| 1 | `TakesExpansionMemoryTests/theBoardsOpenFansAreWrittenToTheSessionAsTheyChange` | R | R | G | G | G | G |
| 2 | `…/aFreshBoardIsSeededBeforeItsFirstProjection` | R | R | G | G | G | G |
| 3 | `…/theFirstProjectionPrunesBlocksTheNoteNoLongerHolds` | R | R | G | G | G | G |
| 4 | `…/onlyTheTakesBoardReadsOrWritesTheMemory` (guard — the fence) | G | G | G | G | G | G |
| 5 | `…/applyingAShowFilterForgetsTheFansItCloses` (its non-vacuity line reds without the memory) | R | R | G | G | G | G |
| 6 | `TakesExpansionRemountTests/aModeRoundTripComesBackWithItsFansOpenAndOnTheSameBlock` (the "open" half; the place half green everywhere) | R | R | G | G | G | G |
| 7 | `…/anEntryLandingStillReachesAFarBlockWithFansOpenAboveIt` ×4 (proof; only its "seeded" non-vacuity line reds without the memory) | R×4 | R×4 | G | G | G | G |
| 8 | `…/slotSplitsEntryRingLandsOnTheCardThatRendersItsTake` | R | R | **R** | G | G | G |
| 9 | `TakesSlotSplitExpandAllTests/expandAllOpensEverySplitAndCloseAllBringsThePlainPageBack` (rendering guard; its memory line reds without VX-428) | R | R | G | G | G | G |
| 10 | `…/expandAllNeverLeavesTheRingOnAPaneNoSurfaceRenders` ×2 (slotSplit · stack) | R·G | G·G | G·G | R·G | G·G | G·G |
| 11 | `TakesExpansionCostTests/aSeededRemountCostsOnlyWhatIsOnScreen` ×3 (measurement; its "seeded" non-vacuity reds without VX-428 — run it on rev428 and post only) | R×3 | R×3 | — | — | — | G×3 |
| 12 | `TakesBoardTests/expandAllIsOfferedOnlyWhereMeaningful` (JUSTIFIED EDIT: the slot-split line flipped) | R | G | G | R | G | G |
| 13 | `TakeCardDoorTests/theBoardsLiveTakeCardCarriesTheFourActs` (its grammar now includes `.newTake`) | R | G | G | G | R | G |
| 14 | `…/theOtherLiveCardShapeCarriesThemToo` (same) | R | G | G | G | R | G |
| 15 | `…/theCardMenuIsOneListWithTheRegistrysOwnWords` (JUSTIFIED EDIT: the branch row at the head) | R | G | G | G | R | G |
| 16 | `…/aLiveCardsMenuOffersNewBranchedTake` ×2 (stack · carousel) | R×2 | G | G | G | R×2 | G×2 |
| 17 | `…/theBranchRowBranchesFromTheCardsOwnNotChosenTake` ×2 (board · Write panel) | R×2 | G | G | G | R×2 | G×2 |
| 18 | `…/commandTBranchesTheTakeTheCaretIsInElseRefuses` (HOLLOW guard) | G | G | G | G | G | G |
| 19 | `…/theWritePanelsCommandTBranchesTheTakeTheRingIsIn` (HOLLOW guard) | G | G | G | G | G | G |
| 20 | `…/bothTakesSurfacesDeclareTheOneCardGrammar` + the suite's other 9 (guards) | G | G | G | G | G | G |
| 21 | `TakeCardMenuTitleTests/*` (2 — the chord drift guard now walks the new row) | G | G | G | G | G | G |

**Reading the runs:** rev428 reds exactly #1–#3, #5–#9, #11 (the memory); rev428map reds exactly
#8 (the slot-split entry mapping — green there would make #8's mapping half HOLLOW: then the mapping
is dispositioned hollow and withdrawn); rev577 reds exactly #10(slotSplit) and #12; rev594 reds
exactly #13–#17; their union is pre's. A pin green on its own member's revert is HOLLOW — record it,
never fix it. #18/#19 are predicted green on every tree: **that is the evidence that R-601-4's ⌘T
half is hollow** — if either is RED on pre, the trace above is wrong and the ⌘T half is real (stop,
report; do not build on a guess).

**THE VX-428 MEASUREMENT — PENDING the window (#11's `VX428-MEASURE` lines, from the post run's
log; the numbers land here).** The fixture: 60 blocks, every block fanned (two takes), a 1100×700
window; per style (stack · margin grid · slot split) four remounts — 0 fans open, 5 open at the top,
25 open at the top (all on the first screen: the worst case), 25 open BELOW the fold. Each line
gives the seed (µs — `landingEnabled`'s seed + sink install), the first realized pane (ms from the
hosting view's mount), the settle (ms until the realized pane set holds still for three turns — the
first paint and the restore's re-renders done) and the realized panes (article · cards). **What the
code predicts, for checking the numbers against:** the seed is O(open fans) — one dictionary read,
one set copy (single-digit µs); the remount's cost is the lazy column's: only REALIZED rows build
their cards (P3), so 25 fans below the fold realize exactly what 0 do (asserted), and 25 at the top
realize at most a viewport's worth (asserted: ≤ 3 panes per at-rest row, two cards per open fanned
row, the rows fewer because taller); nothing scales with the 60 blocks except the existing O(slots)
reads every render already makes (`marginRailWidth`'s candidate filter, `railEngaged`'s scan) —
unchanged by this member. The margin rail is engaged from the FIRST frame on a seeded board (the
prose column's measure is the engaged one at first paint — no widening after it).

## READY-FOR-SUITES — batch B (the orchestrator's window; from `App/Variorum/`)

All six builds are done; run `test-without-building` on each (no rebuild), array args:
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building -only-testing:…`.
Confirm each "Test run with N tests in M suites" line and read the `skipped:` lines (VX-604: 0 ran =
no verdict). Every new mounted pin waits on `HostLaunchSettle` before it pumps (the launch gate),
and `TakeCardDoorTests`' bloomed-board harness now does too.

1. **THE RED RUNS** — on `vx601b-pre`, `vx601b-rev428`, `vx601b-rev428map`, `vx601b-rev577`,
   `vx601b-rev594` (seconds to ~2 minutes each):
   `-only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/TakesBoardTests`
   **plus on `vx601b-rev428` only** `-only-testing:VariorumTests/TakesExpansionCostTests` — expect the
   table's reds exactly (TakesBoardTests runs whole: its other 22 tests green everywhere).
2. **THE GREEN RUN, tier 1** (on `vx601b-post`) — the pins, the measurement (its `VX428-MEASURE`
   lines are the numbers this record is owed), and the Takes-board family the change reaches (the
   expansion memory, the entry ring, the card menu, the routed ⌘T):
   `-only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakesExpansionCostTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/ArticleLandingProjectionArmTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesLandingTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/TakesFindBoardTests -only-testing:VariorumTests/TakesStepFollowTests -only-testing:VariorumTests/TakesStepFollowModelTests -only-testing:VariorumTests/TakesParkedFollowTests -only-testing:VariorumTests/TakesChooseRingTests -only-testing:VariorumTests/TakesRailPagingTests -only-testing:VariorumTests/TakesCardHeightTests -only-testing:VariorumTests/TakesRoomTests -only-testing:VariorumTests/TakesEntryBandTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/WriteTakesPanelTests -only-testing:VariorumTests/WriteTakesPanelChooseTests -only-testing:VariorumTests/WriteTakesPanelKeysTests -only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/ModeSwitchCarryTests -only-testing:VariorumTests/ModeSwitchFeelTests`
   — 30 suites, all green expected (VX-337's two load-dependent flakes are whole-TARGET-load only;
   met here, they are not this batch's — note them for batch C).
3. **THE GREEN RUN, tier 2 — the battery** (on `vx601b-post`): batch A2's 201 suite types (the
   READY-FOR-SUITES — batch A2 list, verbatim) PLUS `TakesExpansionMemoryTests
   TakesExpansionRemountTests TakesSlotSplitExpandAllTests TakesExpansionCostTests
   TakeCardMenuTitleTests TakesBoardTests TakesArticleWatchTests ArticleLandingProjectionArmTests
   TakesEntryBandTests TakesRoomTests TakesCardHeightTests TakesLandingTests CommandRouterTests
   BranchDoorFlushTests SpreadBookViewTests TutorialTakesActsTests` (any already in the 201 counts
   once) — ~215 suite types. Standing reds that are NOT this batch's, if met: VX-337's
   two flakes and the trait-skipped singleton-window oracle suite.

## THE USE WALK — batch B rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug
build from `DerivedData/vx601b-post`; never press Resume Sync; restore exactly as found)

The walk REQUEST names: one fresh walk note minted by quick entry with FOUR plain paragraphs
(blocks), each given a second take with ⌘T in Takes (each take edited so the two differ — e.g. "…
second take"), retitled "vx601 b walk note"; it leaves to the Trash at the end. **The fan style is a
SYNCED store setting** (`fan_style`): the walker reads the as-found style first (the header's
"style: …") and restores it exactly at leave-taking. Captures one per row per voice, both voices
(Study first — the store's voice — then Terminal, restored to Study).
- **B1 — VX-428, her tester's words:** Takes (⌘2), stack style; open two fans with their ⑂ badges;
  ⌘1 (Write), look, ⌘2 → **both fans are still open**, the page where she left it. Then ⎋ (close
  all), ⌘1, ⌘2 → all closed (close-all is remembered too).
- **B2 — VX-428, "getting to the right location":** open the first block's fan; scroll so the third
  block is at the top; ⌘1, ⌘2 → **the same block at the top, the fan above still open.** Then in
  Write put the caret in the LAST block, ⌘2 → **the board lands on the last block** (on screen, the
  ring in it) with the first block's fan still open above.
- **B3 — VX-577, the door (style: Slot split):** the header shows **"expand all"** and **"close
  all"**; expand all → every fanned block opens into its split (cards side by side); ◀ ▶ on one split
  pages it alone; close all → the plain page; expand all again, then ⎋ → plain. Then click into a
  block's text, type a word, press expand all → **the word is kept** (⌘1 shows it), no ring is left
  floating, a click in a card takes the caret again.
- **B4 — VX-428 × slot split:** (still slot split) open one block's split, click into its chosen
  card, ⌘1, ⌘2 → the split is still open and **the ring lands in that block's card** (typing lands
  there). Restore the as-found style afterwards.
- **B5 — VX-594, the door:** stack style, a block's fan open; on the NOT-chosen take's card, ⌄ →
  **"New branched take (⌘T)"** → a new card appears with the not-chosen take's words, the caret in
  it; the ✓ chosen card unchanged. Then Write (⌘1) → the block's ⑂ badge (Write's take panel) → a
  not-chosen card's ⌄ → New branched take → the same, in the panel.
- **B6 — VX-594's ⌘T (the hollow half, confirmed live):** click into the not-chosen take's card in
  Takes, ⌘T → the new take carries THAT take's words (not the chosen's). Click somewhere neutral so
  no take holds the caret, ⌘T → the board's "Click into a take first" refusal.

## SELF-ASSESSMENT (the first of the two reviews — the implementer's)

- **Scope and seams.** Production: `EditorRouter.swift` (one session slot), `TakesBoardLayout.swift`
  (the sink, seed, prune; reports only on a change — the assignments, hence observation, unchanged),
  `TakesViewModel.swift` (the landingEnabled edge, the memory, the first-projection prune, the gate,
  the expand-all blur, the slot-split predicate and the entry mapping), `TakesBoardView.swift`
  (`cardActs` forwards to the model, `.newTake` in `surfaceCapabilities`, two doc comments),
  `TakesShared.swift` (`TakeCardActs.branch`, the row, the copy, the one wiring),
  `WriteTakesPanel.swift` (the wiring, `.newTake` declared), `CapabilityRegistry.swift` (`.surface` on
  `.newTake`). Zero `Sync/`, schema, operations, Shared/, `PaneSurface`, `EditorTextView`,
  `BlockRangeIndex`, structural door, storage write. No TK1 API, no attribute stamp. P-1: the door
  is declared, rendered from the one list, walked per surface. P-3: no second liveness — the entry
  mapping and the blur go through the authority's own doors (`authority.focus`, `blur`). P1/P3: the
  memory is O(open fans) per change; drawing seeded fans is the lazy column's (measured).
- **The trace held, with one member half falsified.** VX-428/VX-577 as briefed plus one widening
  each (both the same R112 class, both slot split's article-cell replacement); VX-594's door missing
  as suspected, and its ⌘T half already true on every host — the sitting's premise for that half was
  wrong, so nothing was built for it and the guards pin her semantics.
- **What could regress, and why I think it doesn't.** (1) *Existing two-mount pins on one session*
  now see the second board seeded — every such suite I found expands nothing before its remount
  (`TakesArticleScrollTests`'s remounts; the soak expands, then remounts — its invariants are about
  rings, mirrors and heights, all honest under open fans); the battery decides. (2) *The Write panel
  and Lenses* never set `landingEnabled` — fenced (pin #4). (3) *Twin models* (SwiftUI builds a
  discarded `TakesViewModel` on every `TakesBoardView` re-init) get seeded too — a read and a copy;
  they never mutate, so they never write. (4) *The card wiring's move* — the four old closures are
  byte-identical in behavior (the delete pin presses the real wiring now). (5) *The blur* fires only
  on the one shape (slot split, ring in an article cell expand-all replaced); every other style keeps
  the ring (pin #10's stack case). (6) *The entry mapping* applies only when the article cell is
  really gone (`slotSplitReplacesArticleCell` reads the board's own bloom rule).
- **Risks I see.** (a) Pins written without a run: the harnesses are the measured suites' own
  (`TakesArticleScrollTests`' mount/settle/topOfPage, `TakeCardDoorTests`' oracle,
  `TutorialWalkTests`' routed ⌘T); a red on post is a pin to fix, never a production edit without a
  trace. (b) #6's ±1-block restore tolerance under two taller-than-estimated rows above the place is
  the existing pin's tolerance, not a new promise; if the window shows it outside, that is her
  "getting to the right location" failing and the record must say so plainly. (c) The measurement's
  bound (#11, ≤ 3 panes per at-rest row) assumes LazyVStack prefetch stays within ~2 rows; a red there
  is a measured fact to report, not a reason to loosen the bound silently. (d) The fan card's END
  landing (R-B-3) is visible in B4.

## WINDOW b — batch B's runs (the orchestrator, 2026-10-27/28, claim vx-601-tests-b from 23:34; renewed to ~00:25 at the coordinator's approval)

**Red runs on the five trees (array args; 42 tests / 6 suites each, 43 / 7 on rev428 with the cost
suite; zero restarts):** the partition by member is CLEAN — rev428's reds are exactly the memory
pins (#2 #3 #6 #7×4 #8 #11×3), rev428map's exactly the mapping pin (#8 — REAL, not hollow),
rev577's exactly the ring pin's slotSplit case (#10), rev594's exactly the five door pins
(#13–#17), pre the union; the two ⌘T HOLLOW guards (#18 #19) are green everywhere, as predicted —
the caret-following half of VX-594 already worked, confirmed. **BUT FOUR PINS ARE GREEN WHERE THE
TABLE PREDICTS RED:** #1 and #5 (green on pre AND rev428), #9 (green on pre and rev428), #12 (green
on pre AND rev577 — the loudest: the flipped-gate test must red on a tree whose gate still excludes
slot split). The green-on-both-sides rule applies: batch B does NOT accept until each of the four
is traced — pin-indirection, a revert that missed a file, or a genuinely hollow row — and the
implementer is resumed on exactly that forensics (pins and trees only). Logs:
`DerivedData/logs/red-vx601b-*.log`.

**Tier 1 on `vx601b-post`: 279 tests in 30 suites, ONE failure** —
`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt`, which is one of VX-337's two
known load-dependent flakes; it is GREEN alone on the same tree, twice (40/1 each). Disposition:
not a determinate batch B regression; the NEW FACT — it now reproduces at 30-suite load on this
branch where it previously needed the whole target — is routed to VX-337's bounded trace (batch C)
as a cheaper repro. Watch it in the ladder: if it recurs at low load, re-examine against batch B's
restore-seam changes first.

**HER VX-428 MEASUREMENT (the `VX428-MEASURE` lines, tier 1's run on post — an UNSHARED machine,
nothing else queued, per the coordinator):** the seed is 1.2–4.0 µs across all twelve shapes. P3
holds exactly: 25 fans open BELOW the fold realize precisely what 0 open do (19 article panes, 0
cards, in every style), and 25 at the top realize one viewport's worth (stack 4+8, marginGrid 3+6,
slotSplit 0+10). Settled time: stack 154→168 ms (0 → 25-top), marginGrid 152→166 ms, slotSplit
155→203 ms (the card realization's price, still viewport-bounded). First pane: 108→122 ms stack,
113→159 ms slotSplit. Her requirement's other half — landings with a seeded set — is pin #7
(red-on-old verified on rev428, ×4 styles) plus walk rows B2/B4.

## BATCH B FORENSICS — the four "green where predicted red" rows (implementer, 2026-10-28, from the window's `DerivedData/logs/red-vx601b-*.log`)

**NOT DONE (first line):** the re-runs (the orchestrator's window — the plan at the end of this
section). **No revert is in flight; the production source is the fix again** (7dc216f23 — App/ is
byte-identical to 110e038c3; no `VX601B-REVERT` marker anywhere). Both affected trees are rebuilt,
build-for-testing GREEN.

**THE TRACE (read off the logs and the build logs; no test run by this session).**
- **#1, #5, #9 — a TREE defect, mine: the rev428 revert never turned the write-back off.** The
  revert inserted a bare `return` as the first line of `openExpansionMemory()`, with the sink's
  installation (`board.expansionSink = { … }`) on the NEXT line. Swift parses a Void `return`
  followed by an expression on the next line as `return <expression>` — the assignment ran, THEN the
  function returned. Both revert builds say so: `b-rev428-build.log:5631` and `b-pre-build.log:5629`,
  *"Expression following 'return' is treated as an argument of the 'return'"* (TakesViewModel.swift
  :2671 / :2665), then *"code after 'return' will never be executed"* for the SEED lines only. So on
  pre and rev428 the memory's WRITE-BACK was live and only the SEED was off — exactly the observed
  partition: the seed pins (#2, #3, #6, #7, #8, #11) red, the write-back pins (#1, #5, and #9's memory
  line) green. The pins are sound; the trees were not the trees the table named. **Fix: rebuild pre
  and rev428 with a revert that cannot swallow the next line** (`if true { return }` — the sink and
  the seed both unreachable).
- **#12 — NO VERDICT, not green: it never ran.** `expandAllIsOfferedOnlyWhereMeaningful` lives in
  the suite type `TakesPresentationTests` (`TakesBoardTests.swift:817-951` — the file holds five suite
  types), and my READY-FOR-SUITES named only `TakesBoardTests`. Every red log shows the "Takes board
  (Phase 11, A3)" suite running its 13 tests and no line for #12 anywhere (`grep -c` = 0 in all five
  red logs and in `tier1-b-post.log`). So the gate edit is NOT dead code — nothing else offers expand
  all (the header renders the two buttons only under `model.offersExpandAll`); the pin simply was not
  run. The battery on post lists `TakesPresentationTests` and will give post's verdict; pre and rev577
  need a run with the right suite name. No tree change.

**THE CORRECTED TABLE (only the rows this section changes; every other row stands as the window
measured it, which matched the original table):**

| # | Test | pre | rev428 | rev428map | rev577 | rev594 | post |
|---|---|---|---|---|---|---|---|
| 1 | `TakesExpansionMemoryTests/theBoardsOpenFansAreWrittenToTheSessionAsTheyChange` | R (rebuilt tree) | R (rebuilt tree) | G | G | G | G |
| 5 | `…/applyingAShowFilterForgetsTheFansItCloses` | R (rebuilt) | R (rebuilt) | G | G | G | G |
| 9 | `TakesSlotSplitExpandAllTests/expandAllOpensEverySplitAndCloseAllBringsThePlainPageBack` (its memory line) | R (rebuilt) | R (rebuilt) | G | G | G | G |
| 12 | `TakesPresentationTests/expandAllIsOfferedOnlyWhereMeaningful` (the suite NAME corrected) | R | G | G | R | G | G |

**Measured in the window and standing (the orchestrator's relay):** rev428map reds #8 alone — the
slot-split entry mapping is REAL; rev577 reds #10 (slot split) — the blur is real; rev594 reds
#13–#17 exactly; both ⌘T guards green on every tree — R-601-4's ⌘T half confirmed HOLLOW. Tier 1 on
post: 279 tests in 30 suites, one failure — `TakesArticleScrollTests` (the straddling-fold pin),
green alone twice, dispositioned to VX-337's load-dependent class by the orchestrator, not this
batch's. The `VX428-MEASURE` numbers landed (P3-clean, per the orchestrator) — their copy into this
record is owed from `tier1-b-post.log`.

**The 209-suite battery on post: 1216 tests in 209 suites PASSED** (713 s; 14 known issues — the
loud pinned set, unchanged; zero restarts; the straddling-fold flake did NOT recur at this load —
one more datum for VX-337's nondeterminism). Log: `DerivedData/logs/battery-b-post.log`.

**Window b verdict:** post is GREEN across tier 1 (one dispositioned flake) and the battery; the
red discrimination stands for everything EXCEPT the four re-opened pins (#1 #5 #9 #12), whose
forensics gate batch B's acceptance. The walk (B1–B6) waits on that forensics too.

**THE REBUILDS — DONE.** `vx601b-rev428` rebuilt with `if true { return }` as the revert's first
line (log `b-rev428-build2.log`: no "treated as an argument of the 'return'" warning; dylib 23:56) —
both the seed and the sink are now unreachable. `vx601b-pre` rebuilt with the same corrected rev428
revert plus the rev577 and rev594 reverts unchanged (log `b-pre-build2.log`, GREEN, dylib 00:05).
The other three trees (`rev428map`, `rev577`, `rev594`) never contained the slip and stand as
measured. The rev428 rebuild overlapped the tail of the window's battery (≈23:53–23:56, CPU load
only — no pointer events); the battery passed regardless (1216/209), so nothing there needs a re-read.

**A WORKTREE COLLISION, said plainly (and repaired).** The window's ledger commit bd6a17ef7
(00:02:32) was made from this same worktree while the pre-tree revert was in flight (applied
≈00:02:20, restored after the build at 00:05) — it captured `TakesViewModel.swift` and
`TakesShared.swift` WITH the `VX601B-REVERT` edits and pushed them as HEAD (the old slot-split gate,
no blur, no expansion memory, no entry mapping, no branch row). My `git checkout --` afterwards then
restored to that HEAD, i.e. to the reverted bytes. **Repaired by a forward commit, 7dc216f23**, which
restores both files from 767fb4206 — App/ is now byte-identical to the fix (110e038c3), verified by
`git diff 110e038c3 HEAD -- App/` being empty. No history rewritten. No test result is affected:
every run used the DerivedData trees, all built before bd6a17ef7. **Lesson for the record:** a
revert-in-flight window and a ledger commit must not share a worktree moment — the orchestrator's
ledger commits should be pathspec-limited (`git commit -- notes/…`), and a revert's restore should
be from the fix commit by id (`git checkout <fix-sha> -- <file>`), never from HEAD.

**#12 on post:** it RAN in the window's battery (which lists `TakesPresentationTests`) and PASSED
(`battery-b-post.log`) — post's verdict is green; pre/rev577 still owe theirs.

**THE RE-RUN PLAN (the orchestrator's window; from `App/Variorum/`, `test-without-building`, array
args; ~2 minutes in all):**
1. `vx601b-pre` — `-only-testing:VariorumTests/TakesExpansionMemoryTests -only-testing:VariorumTests/TakesExpansionRemountTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/TakesPresentationTests`
   — expect the union: #1 #2 #3 #5 #6 #7×4 #8 #9 #10(slotSplit) #12 #13 #14 #15 #16×2 #17×2 red;
   #4 #10(stack) #18 #19 and the card suite's other 9, the chord guard's 2 and the presentation
   suite's other 3 green. (TakesBoardTests dropped from this list: none of its 13 tests is a pin.)
2. `vx601b-rev428` — the same six suites plus `-only-testing:VariorumTests/TakesExpansionCostTests`
   — expect exactly #1 #2 #3 #5 #6 #7×4 #8 #9 #11×3 red; everything else green.
3. `vx601b-rev577` — `-only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakesSlotSplitExpandAllTests`
   — expect exactly #12 and #10(slotSplit) red. (rev577's other suites ran clean last window and
   the tree is unchanged.)
`rev428map` and `rev594` need nothing more. If #1/#5/#9 are STILL green on the rebuilt rev428, the
write-back is reached by a road my trace missed — stop and report, never adjust the pin.

## WINDOW b-final, phase 1 — the red re-runs on the REBUILT trees (the orchestrator, 2026-10-28, claim vx-601-b-final from ~00:08)

All four re-opened rows now prove RED-ON-OLD on their member's tree, and every other row holds:
`vx601b-pre` (33 tests / 6 suites, the corrected suite set): red = #1 #2 #3 #5 #6 #7×4 #8 #9
#10(slotSplit) #12 #13 #14 #15 #16×2 #17×2 — the full union, #12 red now that
`TakesPresentationTests` is named; guards #18–#20 green. `vx601b-rev428` (34 / 7 with the cost
suite): red = exactly #1 #2 #3 #5 #6 #7×4 #8 #9 #11×3 — the rebuilt revert (the bare-return slip
gone) turns the write-back off and #1/#5/#9 red as they must. `vx601b-rev577` (6 / 2): red =
exactly #12 + #10(slotSplit). Zero restarts everywhere. **Batch B's red-on-old verification is
COMPLETE per member; nothing hollow but the two deliberately-hollow ⌘T guards.** Logs:
`DerivedData/logs/red2-vx601b-*.log`. Phase 2 (the B walk) proceeds under the same claim.

## THE WALK RECORD — batch B (B1–B6) (Opus walker, claim `vx-601-b-final`, 2026-10-28 00:12–00:24 MDT)

Build: `App/Variorum/DerivedData/vx601b-post/Build/Products/Debug/Variorum.app` (dev store, pid 83475
for the whole walk — ONE launch, no crash, no What's New sheet). Captures (gitignored):
`App/Variorum/DerivedData/walkshots-vx601b/` — `leg0-*` as-found, `mint*` the note, `b1*`…`b6*` the
rows, `r-*` leave-taking (each with a `-s` 1240-wide copy). Every step through `Tools/WalkKit/click.sh`
/ `keys.sh` (the full guard each time; ≥ 2.2 s between synthetic steps — no refusal this walk). Window
1240×840 at (244,155). **Study voice only** — the record's row text asks both voices; Terminal was NOT
walked (a Terminal pass needed a second walk note, against the request's ONE note, inside a brisk
claim). Recorded, not judged.

**As-found (leg 0, before any act):** Bookcase, no books; held banner "This is your library as of
October 20, 2026…" + Resume Sync (NEVER pressed); "Sync off (dev store)"; Study voice, app Dark
(macOS Light, never touched); the twelve-words card (never touched). Library/Trash read at
leave-taking (below). **As-found fan style: "style: stack", "wash: on"** (Takes header, read before any
style act); under slot split the dial read **"× 2 beside"** — never touched.

**The walk note:** quick entry ⌘V of four paragraphs ("alpha … golf." / "hotel … november." /
"oscar … uniform." / "victor … three.") ⏎ → a four-block note shown as "2026-10-28", retitled
**"vx601 b walk note"**. Takes: block 1 ⌘T → ⑂2 (take 2 edited "… golf. second take"); block 2 ⌘T →
⑂2 (take 2 "… november. second take"). Block 1 later grew to ⑂8 through B3/B5/B6's mints.

| Row | Study | What was seen |
|---|---|---|
| **B1** (VX-428) | **PASS** (open half) · **PASS via the header door** (close half; ⎋ = F-BW-1) | Both fans open, caret in block 2's article; ⌘1 (Write: ⑂2 on both blocks) → ⌘2 → **both fans still open**, block 2 in view with block 1's cards above (`b1-after`). Then ⎋ → **nothing closed** (`b1-esc`), ⌘1/⌘2 → still both open (nothing had closed). The header's **"close all"** → plain page, ⌘1/⌘2 → **all closed, "close all" dimmed** — the memory heard the close (`b1-closeall-after`). |
| **B2** (VX-428) | **PASS** | Block 1's fan opened by its ⑂2 badge; the note is too short to scroll block 3 to the top — the reference top was block 1's ✓ chosen card with block 2's article at y≈428. ⌘1/⌘2 → **pixel-identical page: same top, the fan open, the caret in block 2** (`b2-rt`). Write: caret at the end of the LAST block ("three.|") → ⌘2 → **"block 4/4", the caret after "three." on screen, block 1's fan still open above** (`b2-last-land`). |
| **B3** (VX-577) | **PASS** (⎋ = F-BW-1) | Style → Slot split: header **"style: slot split ▾ · × 2 beside ▾ · expand all · close all"** (`b3-slot`). **expand all** → both fanned blocks in side-by-side splits (`b3-expand`). Block 1 given a 3rd take ("+ new take (branch)" — it branched the chosen and seated the new card 2nd) → its split showed **"◀ 1–2 of 3 ▶"**, block 2's (2 takes) none; **▶ → block 1 alone to "2–3 of 3"**, block 2's split unchanged (`b3-page`). **close all** → the plain page (`b3-closeall`). expand all again → splits back; **⎋ → nothing** (caret in a card, `b3-esc`); a click in the empty right margin greyed the caret, **⎋ → still nothing** (`b3-esc2`). Typed word, unfanned block 3: " kept" → expand all → kept, caret stays in its (unreplaced) cell (`b3-typed-expand`, first try). **The P-B-1 case, fanned block 2:** close all, caret at the article's end, typed " held" → **expand all → " held" is in block 2's ✓ chosen card, NO caret drawn anywhere, the status reads "click into a take"** (`b3-typed2-expand`) — the blur; a click in the card took the caret again (`b4-clickcard`); ⌘1 showed " held" and " kept" in Write (`b4-write`). |
| **B4** (VX-428 × VX-577) | **PASS** | Still slot split, both splits open; click into block 2's ✓ chosen card (caret in "h\|eld") → ⌘1 → ⌘2 → **both splits still open, the caret landed in block 2's chosen card** (at its END — R-B-3) (`b4-back`); typed " ring" → **landed in that card** (`b4-typed`; see O-BW-1). Block 1's pager read "1–2 of 3" after the remount. Style restored to **Stack** (wash: on unchanged) before B5 (`b5-stack`). |
| **B5** (VX-594) | **PASS** (board) · **PASS** (Write panel) | Stack, block 1 ⑂3 open; the NOT-chosen card "… golf. second take" ⌄ → the menu **leads with "New branched take (⌘T)"**, then "Archive this take (⌘⇧A)", "Label take…", "Lock this take", "Delete this take" (`b5-chev`) → pressed → **⑂4, a new card "… golf. second take" (that take's words) right after its source, the caret in it; the ✓ chosen card unchanged ("… golf.")** (`b5-branched`). Write (⌘1) → block 1's ⑂ badge → panel **"Takes — block D9B30289"** (VX-586's id, live) → 3rd card ("… second take", not chosen) ⌄ → the same menu, led by "New branched take (⌘T)" (`b5-panel-chev`) → **⑂5, a new card "… second take" after its source with the caret; chosen unchanged** (`b5-panel-branched`). |
| **B6** (VX-594 guard) | **PASS** (caret in the take) · **RECORDED** (the neutral half — no refusal seen) | Takes, block 1's 3rd card (not chosen): typed " six" → ⌘T → **⑂6, a new card "… golf. second take six" right after it with the caret; ✓ chosen still "… golf."** (`b6-cmdT`). **The neutral half, exactly:** (a) a click in the EMPTY RIGHT MARGIN beside the cards left the caret live (white) in the card ⌘T had just made, status "block 1/4" (`b6-neutral`) → ⌘T → **⑂7, another "… second take six" branched from that not-chosen card, the caret into it; NO toast, NO words** (`b6-neutral-cmdT`). (b) a click in the LEFT board margin (left of the cards) **greyed the caret** (the text view resigned) but the status stayed "block 1/4" (`b6-left`) → ⌘T → **⑂8, again a "… second take six" branch of the card holding the greyed caret, the greyed caret moving into it; NO toast, NO words, NOT a chosen-take branch** (`b6-left-cmdT`, `b6-left-scrolled`). The board's "Click into a take first" refusal was **never reached** — a margin click does not clear the board's current take (#245's edge). |

**Findings and observations (none blocks a row's fix):**
- **F-BW-1 — ⎋ closed nothing, three tries:** stack, caret in block 2's article (`b1-esc`); slot
  split, caret in a card (`b3-esc`); slot split after a margin click greyed the caret (`b3-esc2`).
  The record traces ⎋ as `onExitCommand` → `closeAllFans` — in this build, by synthetic `key code 53`,
  that road never fired (the header's close all works every time). Whether a live text view swallows
  ⎋ (`cancelOperation:`) and the margin click leaves no SwiftUI focus for `onExitCommand`, or this is
  pre-existing, is NOT traced here — for the orchestrator (B1's and B3's ⎋ clauses stand unproven).
- **O-BW-1 — the landed END sits on a fresh line:** every ⌘T-minted card and the B4 landing drew
  the caret on a line BELOW the text, and " ring" typed there landed on its own line ("… held⏎ ring",
  also in the article). Clicked carets were inline. Looks like quick entry's paste left a trailing
  newline in each block's text (blocks also render a blank line tall); not traced.
- **O-BW-2 — a stale pager label:** after close all → expand all, block 1's split read "2–3 of 3"
  while showing the ✓ chosen card + card 2 (= 1–2) (`b3-expand2`); after the ⌘1/⌘2 remount it read
  "1–2 of 3" over the same two cards (`b4-back`).
- **O-BW-3 — new takes seat right after their source:** "+ new take (branch)" seated its branch of
  the chosen 2nd; ⌄ ▸ New branched take and ⌘T seated each new card directly after the card it came
  from. Recorded, not judged.

**Leave-taking / returned:** fan style back to **"style: stack", "wash: on"** (as found; set in B4,
read again before leaving Takes, `b6-*`); "× 2 beside" never touched. The walk note ▸ note ▾ ▸
"Delete Note…" ▸ **Delete** ("The note goes to the Trash for 30 days. You can put it back from there
until then."; receipt "Note moved to the Trash — 30 days to put it back."); NOT deleted forever.
Verified after: Library = the one Oct-19 note ("The walk leaves a stone here…"); Trash (read ~8 s
after opening) top row **"vx601 b walk note · note · deleted Oct 28, 2026 at 12:23 AM"**, then "vx601
a2 walk note · 10:31 PM", then the Sherlock set (5:46 PM) in order — as-found + 1, no 8:57 PM row
(`r-trash`); held banner present, Resume Sync never pressed; "Sync off (dev store)"; Study + app Dark;
ended on the Bookcase with the twelve-words card as found (`r-bookcase`). Quit by bundle id
`io.lduarte.Variorum.debug` 00:23:50; guards `pgrep -lx Variorum` / `pgrep -lf "MacOS/Variorum$"`
empty before launch and after quit.

**Prefs (`io.lduarte.Variorum.debug`, `/tmp/vx601b-prefs-before.plist` → after):** ADDED two per-note
keys for the walk note — `currentBlock.` / `postMode.` `F8F0338C-070B-4013-A101-034E471EA7B2` — both
*[removed for publication]*
read 30 and was restored to **29** (`defaults write -int 29`, read back 29, "Type is integer"); every
other counter unchanged. Remaining CHANGED = bookkeeping only (`IdleCommitSweepMark.Variorum-dev`,
`variorum.backup.log`). Final export `/tmp/vx601b-prefs-final.plist` vs before: nothing added, nothing
removed.


## ORCHESTRATOR DISPOSITIONS — the B walk's findings and batch B acceptance (2026-10-28 ~00:30)

**Batch B is ACCEPTED** (red-on-old by revert per member on the rebuilt trees; tier 1 + the
209-battery green; walk B1–B5 PASS with B6's caret half). The open items, each dispositioned:
- **Finding 1 (⎋ closed nothing):** the wiring (`TakesBoardView.swift:318` `.onExitCommand`)
  PREDATES this run and the batch's diff never touched it; `closeAllFans` is pin-green
  programmatically and the header door works live. So not this run's regression — minted
  **VX-637** (Suspected: the synthetic key-53 road may simply not reach SwiftUI's onExitCommand
  when an AppKit pane holds focus, the known blind-spot class). HER 5-SECOND CHECK is in the
  ticket and the morning bundle; the walk's ⎋ clauses stand UNPROVEN, not failed.
- **Finding 3 (stale slot-split pager label):** minted **VX-638** (Confirmed, Low) — within one
  mount, so likely pre-existing; not a batch gate.
- **Finding 2 (landed caret on a fresh line):** record-only — the walk note's pasted blocks likely
  carry a trailing newline; untraced; re-examine only if seen on real content.
- **Finding 4 (new takes seat right after their source):** behavior as built, record-only.
- **B6's neutral half:** the "Click into a take first" refusal is UNREACHABLE on the board — a
  margin click greys the caret but never clears the board's current take, so ⌘T always branches
  the current take once one existed. Goes to **#245** as the ruled-edge question (options: (a) as
  built — the current take persists and ⌘T always has a target; (b) a margin click clears the
  current take and ⌘T then refuses; (c) keep the caret-grey state but make ⌘T refuse from it).
- **The Terminal pass (not walked):** dispositioned COVERED-FORWARD — batch B's members are
  voice-independent behavior, and batch C's walk (VX-574's font work) must run BOTH voices through
  Takes anyway; its rows will re-touch the B surfaces in Terminal. The gap is named here, not hidden.

## BATCH C RECORD — bars, chrome, wording, the bounded flake: VX-427 + VX-574 + VX-586 + VX-321 + VX-337 (implementer: opus-implementer, 2026-10-28)

**NOT DONE (first line, kept current):** the suite window and the USE walk (rows C1–C6) — both the
orchestrator's (this session never runs `xcodebuild test`, never launches the app, never claims the
stage), so **every red/green claim below is a PREDICTION, PENDING that window**; VX-337's SOAK flake
(`TakesBoardSoakTests` seed 21) — not traced, the bound spent on the fold flake (hypotheses below);
the cold ladder. **No revert is in flight** — all seven trees are built and the source is HEAD
(`git diff` empty; no `VX601C-REVERT` marker anywhere).

**LIVE STATUS**
- Reading — DONE: this file (the sitting record R-601-3, members VX-427/VX-574/VX-586/VX-321/VX-337,
  the batches, ENVIRONMENT TRAPS, the batch A/A2/B records incl. `HostLaunchSettle`, the
  ORCHESTRATOR DISPOSITIONS — VX-637/VX-638 not re-fixed), `notes/SurfaceContracts.md` "The app" and
  "The note", `notes/SessionResiliencyProtocol.md`; the tickets VX-321/VX-337/VX-574/VX-586 read
  through Linear (read-only); the VX-282 record's O-3 (VX-321's origin).
- Trace — DONE, all five (below; VX-574's main hypothesis FALSIFIED by measurement, VX-337's fold
  flake traced to a test over-assertion of a pinned design state).
- Fixes + pins — DONE: VX-427 · VX-586 · VX-321 · VX-574 (44519c5dc, the Lenses pin hardened
  fa7ea5567) — `VariorumTests/TakesBarAndFacesTests.swift`, 11 tests in 4 suites; VX-337
  (e5731ecc4) — `TakesArticleScrollTests.swift`: the fold pin's state assertion corrected + one pure
  pin. `DerivedData/vx601c-post` build-for-testing GREEN (`logs/c-post-build3.log`; no warning in a
  touched file).
- Revert trees — DONE from fa7ea5567: `vx601c-pre` (all five reverted) · `vx601c-rev427` ·
  `-rev586` · `-rev321` · `-rev574` · `-rev337`, each an APFS clone of `vx601c-post` built
  incrementally, every one build-for-testing GREEN (`logs/c-<tree>-build.log`; zero "will never be
  executed"/"treated as an argument" warnings — the batch B slip class cannot be here); each revert IN
  PLACE on the member's face/door function (marker `VX601C-REVERT`; the script beside the trees,
  `App/Variorum/DerivedData/c-revert.py`), restored by `git checkout fa7ea5567 -- App/Variorum`
  (by id, never HEAD). Partition spot-check on the binaries: the old panel-title literal
  "Takes — block " is in exactly `pre` and `rev586`'s dylibs, in none of the other five.
- Prediction table, READY-FOR-SUITES, walk rows C1–C6, self-assessment — DONE (below).
- Red/green runs, walk — PENDING (the orchestrator's window).

**THE TRACES (pre-fix line numbers).**

*VX-427 — CONFIRMED (the scout's trace, read myself).* `TakesBottomBar.wordCounts` (`:618-626`)
built the "Nw take" unit from `model.resolvedTake(column: model.columns.first, slot:)` for the
FOCUSED BLOCK's slot — the first column's pick (`TakesViewModel.resolvedTake` →
`PaneTextAuthority.resolvedText(pick:…)`). On the Takes board `columns.first` is the main column,
whose pick is nil, so it resolved the CHOSEN take: with the ring in any other card of a bloomed fan
the bar counted the chosen take's words, and kept them while she typed (the buffer she was filling
was another take's). The batch A walk saw it live (O-3: "7w take" while typing in the long take);
batch A's Terminal capture `t2a-w0.png` shows "9w take" with the caret in the 3-line take. A WIDENING
(same line): the Lenses board hosts the same bar, and there `columns.first` is the Chosen column —
typing in a lens column counted the chosen take too. Write needs nothing (the scout's finding 2).

*VX-586 — the sweep.* Every face in the Takes family that could speak a block's id, grepped
(`prefix(`, `\(…blockID`/`…ID` interpolations in `Text`/`help`/`accessibilityLabel`/receipt/refusal
calls, `Text(id)`, "blk") over `Features/Takes`, `Surface`, `Features/Editor`, `Features/TOC`,
`Features/ReadTier`, `Core`:
| Site | Face | Disposition |
|---|---|---|
| `WriteTakesPanel.swift:119` "Takes — block \(blockID.prefix(8))" | Write's take panel title (also the book Index's in-place Takes sheet — the same view) — the live one the B walk saw ("Takes — block D9B30289") | **FIXED** — `WriteTakesPanel.title(blockID:slots:)` → "Takes — " + `BlockLineLabel.caret` ("Takes — block 2/10"; "block —" when the projection does not hold the block) |
| `TakesBottomBar.swift:605-612` | the Takes bar's context label | already `BlockLineLabel` (13g R5-4) — untouched |
| `PaneSurface.swift:1620` `view.identifier` | the pane NSView's identifier — never drawn, never spoken (test/probe identity) | KEPT, deliberately (not a face) |
| `VisualWalkProbe.swift` (`post`, `rlSel`, …`prefix(8)`) | DEBUG walk-probe log lines | KEPT (DEBUG diagnostics, never rendered) |
| `BookIndexView.swift:829` `BookIndexGeometry.trace` | DEBUG geometry trace | KEPT (not a face) |
| `RefusalCopy.swift:29` "see blk n/n below" | Write's Make Block refusal — not an id, but the retired word "blk" R5-4 replaced with "block n/n" | NOT MINE (Write's refusal, not a Takes face) — residue R-C-1 |
No other Takes face interpolates an id (the take cards, the bars, the receipts, the rail, the filter
rows, the article, the empty state all read ordinals, labels or text).

*VX-321 — CONFIRMED, and wider.* `TakeStructureCopy.movedNote` (`OpsRefusalCopy.swift:181-184`) is
ONE constant spoken by FOUR hosts: the Takes board (`TakesStructureController.swift:706`, whose
disclosure IS "archived · n" — correct there), Write's take panel (the same controller through the
panel's `TakesViewModel` — its list is headed "archived takes", VX-154's rider), the Lenses board
(the same controller — it renders NO archived list; its archive receipt already points at the Takes
board), and Write itself (`EditorSurfaceController.swift:1072` — the road back is the block's takes
panel, "archived takes"). Three of four named a list that host does not show.

*VX-574 — the trace, and what it FALSIFIED.* (1) *The focused board's prose is NOT lighter.* Every
take pane draws `EditorDocument.baseFont` (the voice's one font — `EditorTypography.current`) in
`EditorTypography.ink(for: voice)`, the same font object and the same dynamic ink as Write's editor
(`applyVoiceChrome`) and the read tier; no weight, no alpha, no opacity, no draw override anywhere on
`PaneTextView`. The one code difference is the BACKGROUND (`applyStyle`: `drawsBackground = false`
on a pane; Write and `ReadPostView` draw opaque paper), and font smoothing is the lever that could
turn a transparent background into thinner stems — so I measured it: an offscreen probe (scratchpad
`c574probe/probe2`) shows CoreText smoothing DOES add 15–19% glyph ink on macOS 27.0.1, but the
in-app captures show the panes rendered exactly as Write: glyph pixels over the same words, Write vs
the board — dark Study (`walkshots-vx601b/b1-write` vs `b1-after`): 5392 vs 5372 and 5583 vs 5537;
light Terminal (13u3 `F01` Write vs `uh-05` Takes): 1933 vs 1944; light Study (13u3 `d-13` vs
`ug-14`): the same weight by eye at 3×. So the board's prose is byte-for-byte Write's face, in both
voices and both rooms — **the "transparent pane loses smoothing" hypothesis is FALSIFIED by
measurement.** (2) *Two Takes faces DO draw her words lighter than anything else, in code:*
(a) **`ReadTakesView`** — the Takes board's read-only twin, shown by EVERY unfocused pane (Open
Beside) and every non-key window holding a note left in Takes (`RootView.readCheapNote`) — drew all
prose in `tokens.muted`, the ONLY reader of her prose not in the voice's ink (its precedent
`ReadPostView`, the same note left in Write, draws ink). Its "dimmed/read styling" was the 13g batch
6 BRIEF's line (`phase-13g-formatting-lists-checkboxes.md:2373`), not a ruling of hers — R5-1 ruled
only takes-first — so her VX-574 word governs it. (b) **the stack card's collapsed line**
(`CollapsibleTakeCard`, the ▾ fold) set the take's first line in `.callout`, a LITERAL system font
outside the token layer (SF Pro 12 in both voices). Not deliberate-and-ruled anywhere (the record
pointers read: 13g R5-1, 13b 3F, VX-170's collapsed row — which is ruled "muted" at `tokens.small`).

**AS BUILT.**
- *VX-427* — `TakesBottomBar.takeUnit(for:)`: the focused pane's own take, found in
  `projection.fans[pane.blockID]` (the projection carries every placed block's ACTIVE fan, and a
  live pane is always an active take) and counted through the authority's overlay
  (`model.liveText`) — per keystroke; nil with no ring, and nil for a take the projection does not
  hold yet (says no unit rather than a wrong one). `wordCounts` → `static wordCounts(for:)` so the
  pin reads what the bar draws. P1: one dictionary read + one fan scan + one take's word count.
  Her ruling R-601-3's limits kept: no click-cycle face, no per-card count, words byte-unchanged.
- *VX-586* — `WriteTakesPanel.title(blockID:slots:)` (above). The panel's model projects the whole
  note, so the ordinal and count are the note's; O(blocks) per render, the bar's own cost.
- *VX-321* — `TakeStructureCopy.ArchivedRoad` (takesBoard · lensesBoard · writePanel · write) and
  `movedNote(_:)`; `TakesViewModel.archivedRoad` reads the two facts the archive receipt already
  reads (`writePanelBlockID`, `host`); `EditorSurfaceController` passes `.write`. The board's
  sentence is byte-unchanged; the panel's reuses VX-154's rider's "“archived takes” below brings it
  back"; Lenses reuses its archive receipt's road ("the archived list under its takes on the Takes
  board (⌘2) brings it back"); Write says "its takes panel keeps it under “archived takes”" (no ⌘⇧T
  in it: after the move Write's caret is in the NEW block, whose panel ⌘⇧T would open). The panel's
  header literal is ONE constant now, `TakeStructureCopy.archivedTakesHeader`, read by the header
  and by every receipt naming that list (the panel's archive receipt and Write's ⌘⇧A receipt
  interpolate it — byte-identical). **PROVISIONAL copy** (her copy pass, as VX-154's rider's was —
  P-U3-6); for the orchestrator's #245 bundle: P-C-1 below.
- *VX-574* — `ReadTakesView.proseInk(_:)` = `tokens.ink` for both prose sites (the take's words and
  an unfanned block's prose); the chrome around them (✓ chosen, labels) keeps its quiet colours.
  `TakesBoardView.collapsedTakeLineFont(_:)` = `tokens.small` (VX-170's ruled one-line face; the
  line stays muted, as that ruled sibling is). Nothing changed on the focused board's panes — the
  measurement says there is nothing there to change; the walk's side-by-side captures (rows C4/C5)
  are the acceptance evidence, BOTH voices.
- *What did NOT change:* no operation, no schema, no `Sync/`, no `PaneSurface`/`EditorTextView`/
  `BlockRangeIndex`, no structural door, no Shared/ file — **MOBILE PARITY: nothing
  mobile-visible** (every touched file is Mac-only: `Features/`, `Registry/`).

**PROVISIONAL (for the orchestrator's #245 bundle — I do not touch QUESTIONS.md):**
- **P-C-1 — the receipt's words on the three non-board hosts (VX-321).** Built: each host names its
  own road (above). Options: (a) as built — each host's own list; (b) one host-neutral sentence for
  every host ("…the original is archived on its block — its takes keep it; ⌥⌘Z undoes it."), naming
  no list; (c) Write's names the chord ("its takes panel (⌘⇧T on that block)…"). Most
  spec-defensible: (a) — VX-154's rider's rule, her-copy-pass words. A copy-pass nit to carry: the
  Lenses sentence nests its archive receipt's "(⌘2)" inside the receipt's own parenthesis.
- **P-C-2 — the read twin's ink (VX-574).** Built: ink (her VX-574 word over the 13g brief's
  "dimmed/read styling"). Option (b): keep a lighter twin but in the prose's ink at reduced opacity —
  not built; her words ask for "not a weird light font compared to anything else".

**VX-337 — THE BOUNDED TRACE (ticket-shaped; the orchestrator relays it to VX-337).**
*The fold-settle flake (`TakesArticleScrollTests.aShortRowStraddlingTheFoldComesBackAboveIt`) —
TRACED, a deterministic TEST fix built.*
1. *The failure's own shape* (`DerivedData/logs/tier1-b-post.log:1563-1567`): ONE issue —
   `restIsReached(second.board.articleRestore) → false` after 9 aims — while the SAME test's page
   assertion beside it (her row's top back at −30 ± 2) PASSED. So the page was right and only the
   restore's STATE was not "reached". 9 aims < the 24-aim budget, so not an exhausted restore (an
   exhausted one goes `.settled`, which reads as reached).
2. *The mechanism (code, read):* a `.wanted` restore advances ONLY on a scroll-GEOMETRY report
   (`TakesArticleScroll.consumeArticleGeometry` → `restoreStep`, which settles into `.holding` when
   the row's frame sits at `into ± 2`); a row-FRAME report never advances it
   (`articleRowFramesMoved` returns `.wait` unless `.settled`). Every geometry report carries the
   rows' PREVIOUS frames (the 17q ladder's W-2, measured, documented at
   `TakesViewModel.noteArticleRowFrame`), and the restore's re-aim is absolute — so when SwiftUI's
   re-resolution of the last aim puts the row exactly where it sat, the geometry report of that
   move reads the row off its place, re-aims to the same offset (no geometry change follows), and
   the row then reports its arrival with no geometry report after it: `.wanted` with the page right.
3. *This is the DESIGN, pinned — not a code bug to fix:* 18l-b U2 met exactly this stall (the
   bloom's landing stranded behind it) and fixed it only for a restore a LANDING waits on
   (`restoreLooksAgainForAWaitingLanding`); with no landing waiting the restore keeps its own
   geometry cadence ON PURPOSE — "the guard for her R-Q21: a plain round trip's restore cadence is
   the byte-preserved restore's own" — pinned by
   `TakesArticleWatchTests.aRestoreWithNoLandingWaitingIsLeftToItsOwnCadence` (expects `.wanted`).
   So the code change I first drafted (settle a pending restore on the row's own report) would have
   reversed a pinned decision tied to her ruling — NOT built.
4. *So the TEST over-asserts:* the fold pin is a plain round trip (`forgetCurrentBlock`, no
   landing), and `restIsReached` demands `.settled`/`.holding`, which the design reaches only if a
   geometry report happens to FOLLOW the row's arrival inside the 20-turn window — SwiftUI's pass
   ordering and coalescing, which load moves (alone and in the 196/209-suite batteries a later
   report arrived; in the whole-target run and once in batch B's 30-suite tier 1 it did not).
   *The fix (test-only, `TakesArticleScrollTests.swift`):* the state assertion becomes
   `restArrived(_:on: hersRow)` — `.settled`/`.holding`, OR `.wanted` on HER row (any other shape
   still fails) — beside the UNCHANGED page assertion (her row's top at −30 ± 2), which is the
   contract and carries the pin's red on the round-1 tree (the row came back AT the fold there).
   Deterministic in the variable the trace found; NOT a widened timeout (the window is untouched).
5. *The pin (pure board, deterministic):* `aPlainRoundTripsRestoreArrivingBetweenReportsIsArrivedNotLost`
   drives the exact shape (aim → the aim's report reads the previous frame and re-aims → the row
   reports itself at −30, no report after) and asserts the design's state (`.wanted(place)`), that
   the OLD assertion rejects it (the run's red) and the corrected one accepts it, and that the
   corrected one still rejects `.undecided` and a restore wanting another row. Red-on-old by revert:
   `restArrived`'s body reverted to `restIsReached`'s → this pin's acceptance line reds.
*The soak flake (`TakesBoardSoakTests.randomizedBoardSoakHoldsEveryInvariant(seed: 21)`, "block
0001 strips 4 cards for a fan of 5") — NOT traced (the bound was spent on the first; read only).*
Two hypotheses from a read of the test, for VX-337's next session: (i) **process-global state**
(the VX-167 class) — the soak WRITES `UserDefaults.standard`'s `takesGridRows`/`takesGridCols`/
`takesBeneathCount` for its run and restores them after, while Swift Testing runs other suites
concurrently in the whole-target process (all `@MainActor`, interleaving at every `await`); any
suite touching those keys (or the strip's other `.standard` settings) mid-soak changes what the
strip renders; (ii) **an invariant read before the strip's last card realized** after a mint under
load (invariant 5 counts realized "mini" panes against the fan). The next step is to log, at the
failure, the three `.standard` keys and the strip's realized ids; no fix is proposed.

**RESIDUE / NOT MINE (for the orchestrator to ticket or drop):**
- **R-C-1:** `RefusalCopy.swift:29` (Write's Make Block refusal) says "see blk n/n below" — the word
  "blk" R5-4 retired; the bar now reads "block n/n". A Wording one-liner in Write, not a Takes face.
- **R-C-2:** literal system fonts on Takes-family CHROME (not take words): `WriteTakesPanel` title
  `.headline` + status `.caption` ×2, `LensesBoardView` `.caption`/`.callout.weight(.bold)`/
  `.caption2`, `TakesShared` `.headline`/`.caption`, `DiffView`. The token-layer sweep of chrome
  fonts is wider than VX-574's take-words scope.
- **R-C-3:** `notes/copy-pass/all-user-facing-strings.md:614` still lists the old panel title (a
  copy-pass inventory, not canon) — the copy pass's to refresh.

**THE PREDICTION TABLE (the red/green runs — PENDING the orchestrator's window).** R = red, G =
green; "guard" = green on every tree by design.

| # | Test | pre | rev427 | rev586 | rev321 | rev574 | rev337 | post |
|---|---|---|---|---|---|---|---|---|
| 1 | `TakesBarTakeCountTests/theBarCountsTheFocusedCardsOwnTakeNotTheChosenOne` | R | R | G | G | G | G | G |
| 2 | `…/onTheLensesBoardTheBarCountsTheLensColumnsTake` | R | R | G | G | G | G | G |
| 3 | `TakesPanelBlockLabelTests/thePanelTitleSaysWhereTheBlockSitsNeverItsID` | R | G | R | G | G | G | G |
| 4 | `…/aBlockTheNoteDoesNotHoldReadsTheHonestBlank` | R | G | R | G | G | G | G |
| 5 | `TakeMovedReceiptWordingTests/eachHostsReceiptNamesItsOwnList` (its header + board lines are guards) | R | G | G | R | G | G | G |
| 6 | `…/thePanelsDoorSpeaksThePanelsList` | R | G | G | R | G | G | G |
| 7 | `…/theLensesBoardsDoorPointsAtTheTakesBoard` | R | G | G | R | G | G | G |
| 8 | `…/theTakesBoardsDoorKeepsItsDisclosuresWords` (guard) | G | G | G | G | G | G | G |
| 9 | `…/writesDoorNamesTheTakesPanelsList` | R | G | G | R | G | G | G |
| 10 | `TakesProseFaceTests/theReadTwinDrawsHerWordsInTheVoicesInk` | R | G | G | G | R | G | G |
| 11 | `…/theCollapsedCardLineWearsTheVoicesFont` | R | G | G | G | R | G | G |
| 12 | `TakesArticleScrollTests/aPlainRoundTripsRestoreArrivingBetweenReportsIsArrivedNotLost` | R | G | G | G | G | R | G |
| 13 | `TakesArticleScrollTests/aShortRowStraddlingTheFoldComesBackAboveIt` (VX-337's flake) | load-dependent (the old assertion) | ← | ← | ← | ← | load-dependent | G (deterministic in the traced variable) |
| — | `TakesArticleScrollTests`' other 39 | G | G | G | G | G | G | G |

pre: #1–#7 #9–#12 red (11 red); rev427 #1–#2; rev586 #3–#4; rev321 #5–#7 #9; rev574 #10–#11; rev337
#12; their union is pre's. A pin green on its own member's revert is HOLLOW — record it, never fix it.
#6/#7/#9 compare the door's receipt with BOTH the copy function and a literal, so a revert of the
copy function cannot agree with itself (the literal line reds).

## READY-FOR-SUITES — batch C (the orchestrator's window; from `App/Variorum/`)

All seven builds are done; `test-without-building` on each, array args:
`xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<tree> test-without-building -only-testing:…`.
Confirm each "Test run with N tests in M suites" line and read the `skipped:` lines (VX-604: 0 ran =
no verdict). The new pins are headless model/copy pins and pure-board pins (no window, nothing that
pumps the run loop before a test body except `withEditor`'s own harness and `TakesArticleScrollTests`'
existing mounts — the suite's established rig).
1. **THE RED RUNS** — on `vx601c-pre`, `-rev427`, `-rev586`, `-rev321`, `-rev574`, `-rev337`:
   `-only-testing:VariorumTests/TakesBarTakeCountTests -only-testing:VariorumTests/TakesPanelBlockLabelTests -only-testing:VariorumTests/TakeMovedReceiptWordingTests -only-testing:VariorumTests/TakesProseFaceTests -only-testing:VariorumTests/TakesArticleScrollTests`
   — expect **52 tests in 5 suites** on each (11 + 41), the reds exactly as the table. (Only `pre` and
   `rev337` carry the old fold assertion; met red there, #13 is VX-337's own flake, not a verdict.)
2. **THE GREEN RUN, tier 1** (on `vx601c-post`) — the pins, VX-337's suite and its sibling (the
   restore-cadence guard), the soak (the other flake; the stack card), and every suite touching a
   changed face or door (the bar, the panel, the take↔block receipt on all four hosts, the archive
   receipts, the read twin's holdsTakes, the card menus):
   `-only-testing:VariorumTests/TakesBarTakeCountTests -only-testing:VariorumTests/TakesPanelBlockLabelTests -only-testing:VariorumTests/TakeMovedReceiptWordingTests -only-testing:VariorumTests/TakesProseFaceTests -only-testing:VariorumTests/TakesArticleScrollTests -only-testing:VariorumTests/TakesArticleWatchTests -only-testing:VariorumTests/TakesBoardSoakTests -only-testing:VariorumTests/TakesWordCountTests -only-testing:VariorumTests/TakeToBlockDoorTests -only-testing:VariorumTests/CopyAllTakesDoorTests -only-testing:VariorumTests/WriteTakesPanelRoutedCommandTests -only-testing:VariorumTests/WriteTakesPanelTests -only-testing:VariorumTests/WriteTakesPanelChooseTests -only-testing:VariorumTests/WriteTakesPanelKeysTests -only-testing:VariorumTests/ConfirmationsSettingTests -only-testing:VariorumTests/RefusalTableConvergenceTests -only-testing:VariorumTests/MorningListTests -only-testing:VariorumTests/ArchivedListingTests -only-testing:VariorumTests/TakesBoardTests -only-testing:VariorumTests/TakesPresentationTests -only-testing:VariorumTests/TakeCardDoorTests -only-testing:VariorumTests/TakeCardMenuTitleTests -only-testing:VariorumTests/CapabilityRegistryTests -only-testing:VariorumTests/TutorialTakesActsTests -only-testing:VariorumTests/BookIndexTakesTests -only-testing:VariorumTests/TakesLensFilterTests -only-testing:VariorumTests/LensesReorderTests`
   — 27 suites, all green expected. If `TakesBoardSoakTests(seed: 21)` reds, it is VX-337's
   untraced half (note it; not this batch's).
3. **THE GREEN RUN, tier 2 — the battery** (on `vx601c-post`): batch B's 209-suite battery list (its
   READY-FOR-SUITES tier 2, verbatim) PLUS `TakesBarTakeCountTests TakesPanelBlockLabelTests
   TakeMovedReceiptWordingTests TakesProseFaceTests ConfirmationsSettingTests
   RefusalTableConvergenceTests ArchivedListingTests` (any already present counts once). VX-337's
   fold pin should now be green whatever the load (the point of the fix — watch it).

## THE USE WALK — batch C rows (an Opus walker under the orchestrator's claim; DEV-STORE Debug
build from `DerivedData/vx601c-post`; never press Resume Sync; restore exactly as found)

The walk REQUEST names: one fresh walk note minted by quick entry with THREE plain paragraphs
(blocks) of unequal length (e.g. "alpha bravo charlie." / "delta echo foxtrot golf hotel india
juliet." / "kilo lima mike."), retitled "vx601 c walk note"; ⌘T in Takes on block 1 and block 2 so
each has a second take, each second take edited to a DIFFERENT word count than its chosen (e.g. add
three words); it leaves to the Trash at the end. Rows C5 needs a SECOND note open beside it (the
store's one Oct-19 note, opened beside and closed again — view-only, nothing written). **BOTH
VOICES** for every row (Study first — the store's voice — then Terminal, restored to Study); the fan
style is a synced setting — read as found, restore exactly.
- **C1 — VX-427 (R-601-3), the bar counts the take being typed in:** Takes (⌘2), block 1's fan open
  (its ⑂ badge or expand all). Click into the NOT-chosen card → the bar's trailing "Nw take" reads
  THAT card's words (count them); type two words → it reads two more; click the ✓ chosen card → its
  own count. Then Lenses (⌘4): "+ column ▾ ▸ New lens — arrange existing takes", flip block 1 to the
  second take (‹ ›), click into that lens cell → the bar counts the lens cell's take, not the Chosen
  column's. (Old build: the chosen take's count throughout — batch A's capture `t2a-w0` shows it.)
- **C2 — VX-586, block i/N:** Write (⌘1), block 2's ⑂ badge → the take panel's title reads
  **"Takes — block 2/3"** (no hex id anywhere). Close it; block 1's badge → "Takes — block 1/3".
- **C3 — VX-321, the receipt names the list:** (a) in that panel (block 1), click into the
  NOT-chosen card, ⌥⌘⏎ (Move Take into a Block Below) → the panel's line reads "…archived on its
  block (“archived takes” below brings it back); ⌥⌘Z undoes it." and "archived takes" lists the
  original below the cards; ⌥⌘Z. (b) Write itself: caret in block 1, ⌥⌘⏎ → the bar's quiet line
  reads "…(its takes panel keeps it under “archived takes”)…"; ⌥⌘Z. (c) Takes board: ring in a card,
  ⌥⌘⏎ → "…(“archived · n” under its takes brings it back)…" — unchanged; ⌥⌘Z. (Receipts are the
  quiet line at the bar's trailing end under `receipt_style` quiet — capture the bar.)
- **C4 — VX-574, side by side (the acceptance evidence):** the same note, Write (⌘1) then Takes (⌘2,
  stack, fans closed so the article shows prose), captured at the SAME window size and the same
  scroll so the same paragraph sits in both; both voices. The prose must read the same weight and
  ink in both modes (the orchestrator may measure glyph coverage per word as this record did —
  crop the same words from both captures). Note in the row if Takes reads lighter anywhere — that
  would be a finding against the trace (it measured identical).
- **C5 — VX-574, the faces that were lighter:** (a) the READ TWIN: with the walk note left in Takes,
  open the Oct-19 note beside it (its row's Open Beside) and click into THAT pane, so the walk note's
  pane goes unfocused → it shows the read-only takes cards; its words are in the prose ink (as dark
  as the focused pane's), not grey. Capture both panes; close the beside pane after. (b) the STACK
  CARD FOLD: Takes, block 1's fan open, the ▾ at a card's top-left → the card folds to one line in the
  voice's small face (Study: the sans small; Terminal: the mono small — no longer a system sans in
  Terminal); ▸ unfolds it.
- **C6 — batch B's Terminal residue (one row, Terminal only):** style → slot split: the header shows
  **expand all · close all**, expand all opens every split, close all brings the plain page back;
  then stack style, a NOT-chosen card's ⌄ → **"New branched take (⌘T)"** → a new card with that
  take's words, the caret in it. Restore the as-found style.

## SELF-ASSESSMENT (the first of the two reviews — the implementer's)

- **Scope and seams.** Production: `TakesBottomBar.swift` (the take unit), `WriteTakesPanel.swift`
  (the title; the archived header through the one literal), `OpsRefusalCopy.swift`
  (`TakeStructureCopy.ArchivedRoad`/`movedNote(_:)`/`archivedTakesHeader`),
  `TakesStructureController.swift` + `EditorSurfaceController.swift` (one call each),
  `TakesViewModel.swift` (`archivedRoad`; the panel's archive receipt through the literal),
  `EditorViewModel.swift` (⌘⇧A's receipt through the literal — byte-identical), `ReadTakesView.swift`
  (the prose ink), `TakesBoardView.swift` (the collapsed line's font). Tests: one new file, and
  `TakesArticleScrollTests.swift` (VX-337). Zero `Sync/`, schema, operations, Shared/, `PaneSurface`,
  `EditorTextView`, `BlockRangeIndex`, structural door, storage write; no TK1 API, no attribute
  stamp. P-1: no new door. P-3: no liveness change (the bar READS `focusedPane`). P1: the bar's unit
  is one fan + one take per render; the title O(blocks) like the bar's own label.
- **The traces held — and two were corrected by evidence.** VX-427/VX-586/VX-321 as briefed (VX-427
  and VX-321 each one widening: the Lenses board). VX-574: the brief's "where do the panes get a
  lighter face" — they don't (measured, four capture pairs, both voices and rooms; the smoothing
  hypothesis falsified); the two faces that DO draw take words lighter were found and fixed at their
  token consumers. VX-337: my first drafted fix (settle a pending restore on the row's own report)
  would have reversed a pinned, ruling-tied design (`aRestoreWithNoLandingWaitingIsLeftToItsOwnCadence`)
  — found before building, so the fix is to the over-asserting TEST, not the code.
- **What could regress, and why I think it doesn't.** (1) *The bar on a projection lag* (a take the
  projection does not hold yet): no unit for a moment rather than the wrong one — a live pane's take
  is always in `fans` once the mint lands (the ring parks until the slot arrives). (2) *The receipts*:
  the board's sentence is pinned byte-identical; the two archive receipts that now interpolate the
  header literal are byte-identical (the existing `theArchiveReceiptNamesThePanelsOwnList` and
  `ConfirmationsSettingTests` read them). (3) *The read twin's ink*: chrome around the words untouched;
  `tokens.ink` is palette-free like the panes' `EditorTypography.ink`. (4) *The fold pin* is not
  weakened against its original target: the page assertion (−30 ± 2) still reds the round-1 tree;
  only the state assertion admits the design's legal `.wanted`-on-her-row.
- **Risks I see.** (a) Pins written without a run: the shapes follow measured suites
  (`TakeStructureDoorTests`' world, `TakesBoardTests`' focus/edit, `RefusalTableConvergenceTests`'
  Write door, the pure-board restore pins); a red on post is a pin to fix, never a production edit
  without a trace. (b) `writesDoorNamesTheTakesPanelsList` is the first harness pin of a SUCCESSFUL
  ⌥⌘⏎ in Write (only its refusal was pinned before) — if `runStructural` needs more than the harness
  gives, it reds on post for a rig reason; say so rather than adjust the production line. (c) VX-574
  is accepted on the WALK's side-by-side (C4) — if her "weird light font" is something the trace did
  not find (her own store's settings, a palette), C4/C5 are where it shows; the record says so.

## WINDOW c — batch C's runs (the orchestrator, 2026-10-28, claim vx-601-tests-c from ~01:26)

**Red runs on the six trees: 52 tests in 5 suites EXECUTED on each, zero restarts — the partition
matches the prediction table EXACTLY, nothing hollow:** pre reds the full union (#1–#7, #9–#12);
rev427 exactly the two count pins (the Lenses widening's pin included); rev586 exactly the
panel-title pair; rev321 exactly the four receipt/door pins; rev574 exactly the two face pins;
rev337 exactly the new restore pin. The fold flake (#13) did NOT red anywhere in these runs.
**Batch C's red-on-old is verified by revert per member.** Logs: `DerivedData/logs/red-vx601c-*.log`.

**Tier 1 on `vx601c-post`: 236 tests in 27 suites, ALL PASSED** (one honest slip first: the
orchestrator's list extraction initially re-ran batch A's 17-suite tier 1 — also green — before
the correct 27 ran; both logs kept, `tier1-c-post.log` is the 27). **The WHOLE Mac target on post
is running** (the battery + VX-337's soak-load observation + the pre-ladder baseline; VX-627's
VisualWalk pin is red on main and PRE-EXISTING per the coordinator — separated from this batch's
verdict). PENDING.
