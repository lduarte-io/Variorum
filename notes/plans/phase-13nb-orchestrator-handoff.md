# 13n-b — orchestrator handoff (pre-compaction, 2026-10-10)

**Written at her instruction at the format-schema sitting's close** — the
successor is THIS orchestrator post-compaction (her word, R-13nb-24: the
context is kept; this document is the belt under the compaction summary).
The kickoff prompt is the last section. Verify, never trust: every claim
below is checkable in git and the plan file.

## 1. Who you are and where you stand

You are the Fable architect-orchestrator for phase **13n-b — the MCP
door** (ticket **VX-124**, child of VX-25; branch `vx-124-13n-b`;
worktree `~/dev/variorum-vx-124` on the Pro; the main checkout
`~/dev/variorum` stays on `main`, untouched). The plan file and ONE
running record is `notes/plans/phase-13n-b-mcp-door.md` — its SITTING
RECORD (R-13nb-1…26) and fork rulings (AF-1…AF-9) are the phase's whole
ruled design; read them before anything else. Companion records: the
wire-document memo (`phase-13nb-memo-wire-document.md`), the sitting
prep (`phase-13nb-format-schema-sitting-prep.md`), four ladder records
(`13nb-u{1,2}-ladder-round{1,2}.md`), and this file.

## 2. State at cutover (all pushed; HEAD ≈ ea732abc)

- **U1 CLOSED WHOLE:** spine built (SDK 0.12.1 exact · socket server ·
  shim · grants store v1_24 · pure rule · read rung · pane); live round
  MET with a real Claude Code client; ladder clean at round 2.
- **U2 CLOSED WHOLE:** suggest + write-new rungs, Private ops/faces +
  fence third leg, just-in-time ask, per-act client-named undo,
  adoption-lands-OFF; her fact-check shape MET live incl. the ⌥⌘Z leg
  ("Undo claude-code's lens" — her favorite moment of the phase);
  ladder closed clean at round 2 (the MAJOR — Private marks invisible
  to the §7 fold classifiers — fixed by the reviewer in Sync/, four
  revert-verified pins; AF-7 amended "one write means one write";
  AF-9 least-capability spend, my own fix).
- **v1_25 PRIVATE MARK landed (my hands, 304b41d1):** both
  `ai_private_at` columns, SyncSchema PLAIN classifications,
  **lockstepVersion 12→13 client-side**, mirror artifact
  `Server/supabase/16_phase13nb_private.sql`. **THE DEPLOY IS HELD FOR
  HER CLOSEOUT WINDOW** — mirror first, then BOTH installs in the same
  window; the /Applications refresh is held behind it (never strand
  her build ahead of the mirror).
- **THE SITTING RAN WHOLE** (R-13nb-20…26): no open design questions
  remain in the phase. None.
- **U3 IN FLIGHT, no fork pending:** a fresh opus-implementer builds
  the edit-rung spine (its brief = the plan's U3 section). Its ONE fork
  (the boundary-marker glyph + token + grammar) is RULED — **AF-10**
  (`1d3f4913`): marker `--- next block ---`, `{v:2}` header token
  (parser-only, capture untouched), the grammar as proposed, and its
  SEVEN build calls all concurred (the rung-wide in-transaction guard —
  its move_block-out-of-a-fenced-note disclosure trace; CarryAllMerge
  moved to core under the 3C PARITY PATTERN — app name kept compiling,
  zero test edits; text-addressed cuts `second_half_starts_with`;
  bounded with_commits with the commit_ids fetch; the approved-clients
  Allow-AI-here submenu, read·once, fenced legal; readable-books-only
  book facts; the named brackets with the standing dedupe). Progress at
  this writing (through `902f0d30`): R5/R6 done (either-payload
  create_note + entry_date validated as a real day) and **R7 done —
  FORMAT v2 whole** (marker mode iff needed; all 13n-a byte pins green
  untouched 77/6; BoundaryMarkerTests 9/9 incl. a >1000-note
  exact-inverse sweep; the plain export pinned clean; the wire leg —
  read_note/import_document speaking v2 end to end). Earlier pieces
  (edit_take + brackets + guard, structural tools, commits params,
  sections) check its UNIT RECORD — do not assume order. It runs as
  this session's background task; its hand-back arrives as an agent
  message; if the session loses track, the U3 UNIT RECORD + `git log`
  are truth, and ListAgents finds it.
- **Counts at cutover:** core 2,541/292 · VariorumMCPTests 33/4 ·
  workbook 40/6, headless, gated skips only. The one known red on the
  Mac side is **VX-115** (BookCollectingDoorsTests — stale on main
  since 13o, NOT ours).
- **Tickets born this phase:** VX-127 (floating_notes face-or-retire) ·
  VX-128 (block tags underbaked, Needs Lillian) · VX-129 (undo-stack
  face) · VX-130 (Compare + version preload) · VX-131 (once-grant
  timeout). In-flight row on main updated through `3b619e20`.

## 3. What remains (in order)

1. **U3 closes** → verify its claims (commits, counts, pins, zero
   Sync/) → **its live round, MINE** (stage claim; the recipe in §4's
   machinery notes) → **U3 ladder** (fresh
   fable-reviewer; the cross-model flow VERBATIM: findings → implementer
   agree/dispute → reviewer final-calls + implements its fixes →
   sanity pass → round 2 fresh reviewer).
2. **U4 brief + fresh implementer** — contents RULED (R-13nb-26 e/f/g):
   the carriage (tray read + Put back, versions list/read +
   save_version, lineage + ancestry fields, archived-reach params,
   **lenses list/read** — her pull-in, `set_entry_date` on edit rung);
   **book rules READ AND WRITE** (set-rule/set-outflow on write-new —
   her "Write too, in U4"; the ladder watches this power); **NAVIGATION**
   (receipt offer door WITH a keyboard road; `show_in_app` with her
   etiquette VERBATIM — only while she's at the app, never automatic,
   "open where your agent wants you to see deliberately"; targets:
   note-at-block via the 13o landing machinery · lens · takes-board ·
   book/chapter; Compare targets wait for VX-130). U4 ladder watch
   items: the journal-fence-on-add note (R-13nb-26 b — a note added to
   a journal book becomes fenced from that moment), book-rule-write
   power, navigation etiquette gates are RULINGS not suggestions.
3. **U4 live round** (the whole W-series equivalent + her Percy-grade
   round over the connection — the plan's U3-acceptance line migrated
   here with the carriage) → **U4 ladder** → done building.
4. **CLOSEOUT** (the standing ritual, plus this phase's own):
   - The QUESTIONS merge bundles: P-13nb-U1-1…13 (U1-2 TWICE-amended —
     "one write means one write"; U1-13 extended to books),
     P-13nb-U2-1…13 (+ the F2 sync twin), the AF-6 ask-queue and AF-9
     spend-choice provisionals, R-13nb-26's PROVISIONAL-class edges.
   - **HER DEPLOY WINDOW:** artifact 16 on the mirror (her go, never
     pre-authorized), then BOTH installs (Mac Release to /Applications
     behind A1 + the phone via devicectl — the 13i-e shape), the §12
     running record updated in SyncSpec, marker verified 13.
   - The author checklist carries: A-4's self-declared-identity
     boundary line + grants-ride-library-copies note (R-13nb-6 covers
     the toggle; the rows ride deliberately), the re-verify-probe-(a)
     per-macOS-point-release ritual line, VX-115's red (not ours).
   - Follow-on tickets to mint: references read · callout carry ·
     restore-version · deleted-comments read (R-13nb-26 e's list).
   - Canon deltas AS RULED ONLY (contract lines + pointers): AppSpec §7
     (ai_private_at + the local-only grants family), §9 (the mark ops;
     the MCP ops line), §12 (the MCP door + Private contract lines),
     §14's entry; the 13s-a note (the MCP pane copy + a field-guide
     MCP chapter are in 13s-a's re-voicing path, R-13n-9).
   - MOBILE PARITY: the Private mark's synced columns reach the phone
     as rows with NO faces — likely a `notes/MobileSoul.md` ledger row
     (the phone's Private faces + the fence have no meaning without a
     phone server; the MARK's visibility on the phone is the real
     question). Not "nothing mobile-visible" this time — judge at
     closeout.
   - Master plan + in-flight retire + closeout paragraph + archives
     roll + plan banner CLOSED + worktree removed + branch deleted +
     run/walk evidence deleted + her handoff + PR (merge commit) +
     hard stop.

## 4. The taste I built up (what she asked me to pass down)

- **Maximal capability, minimal configuration.** Every correction she
  made pushed the same direction: the wire carries the FULL model (the
  keyboard bar — exclusions need affirmative justification), while the
  control surface stays tiny and coarse (four grant dials, no write
  counters, no per-client carriage knobs — "narrow where it counts").
  When you face a new carriage question, the answer is almost always:
  CARRY the capability, NEVER add a knob. She said the nightmare out
  loud: "let some ai read deleted takes and other ai's not to." Dials
  belong on FILES (audiences vary); the wire's only dials are grant,
  scope, rung, Private.
- **Reversibility is her trust engine, not refusal.** The moment she
  loved was "Undo claude-code's lens" in the Edit menu. Receipts,
  visible grants, per-act undo, the durable note-mark — these buy more
  safety-feeling than any gate. When weighing a protection, prefer the
  one that makes an act VISIBLE AND REVERSIBLE over one that blocks.
- **She corrects frames by asking questions.** "What exactly is the
  inventory?" / "what does one write mean?" are not stalling — they're
  the signal that my abstraction leaked. Answer the actual question
  with a CONCRETE STORY first (the Tuesday/Wednesday two-grants story
  worked; the abstract version didn't), then re-ask. Never ship a
  ruling she assented to through a frame she didn't fully hold.
- **Her instincts are usually the right default and she knows the
  model deeply** — she caught the search-commits inconsistency, the
  once-staleness surprise, and the ids-go-stale-on-merge fact ahead of
  me. When her lean contradicts my restraint-lean, hers has been right
  every time this phase. But she WANTS the honest counter-case stated
  (the sizing flags, the register boundary) — state it plainly once,
  then build her way.
- **Verbatim-faithful recording is load-bearing.** Twice a ruling
  turned on the exact words ("it's only for technical people anyway";
  "better live"). Record her words the same turn, quote them in
  follow-ups; she notices and trusts the record.
- **The format doctrine in one line:** the data model is never
  contorted to fit a serialization; serializations are views with
  DECLARED fidelity (manifest lines, version tokens); ids live only
  live. 13m inherits this whole.
- **Machinery lessons, hard-won:** shared-worktree discipline —
  pathspec-limited `git add` ONLY, a pull refused by an implementer's
  dirty files is benign (check `git log` origin vs local before
  worrying); do NOT batch-sed comment rewrites (my N1 garble — R2
  caught it; edit comments by hand, reread after); the cross-model
  flow runs exactly as written and both implementers took AGREE-heavy
  postures — the ladder's value came from the REVIEWERS' own traces
  (revert-runs, grep-completeness), so insist on those; agent messages
  arrive twice (direct + formal hand-back) — act once; the two Fable
  reviewer sessions each hit a mid-review safety-classifier cutoff
  while quoting repo source — harmless, they recovered, don't be
  alarmed by the note.
- **The live-round recipe worked twice; keep it:** stage claim → fresh
  branch Debug build (own DerivedData tag) → `open` the app →
  throwaway `claude mcp add -s local variorum-dev -- <built shim
  path>` in a scratchpad dir → `claude -p --model haiku --allowedTools
  "mcp__variorum-dev__*" < script.txt` → pane driving via
  cliclick/osascript (WalkKit's README has the coordinate math; this
  host holds AX + Screen Recording) → quit YOUR instance → `claude mcp
  remove` → stage release. Never her real store, never /Applications.
- **Her working rhythm:** she answers batches fast and completely,
  often with a rider that's a new ruling — mine the riders. Multi-item
  messages get point-by-point replies, every item, her words (the
  standing memory rule — it held value all phase).

## 5. The kickoff prompt (paste-ready — she sends this after compaction)

> You are the 13n-b orchestrator, post-compaction, context continuing.
> Re-seat: `cd ~/dev/variorum-vx-124 && git pull --ff-only` (plus the
> memory repo and `~/dev/variorum` per the bout-start rule if a new
> day). Read IN FULL: `notes/plans/phase-13nb-orchestrator-handoff.md`
> (your own handoff — state, remaining work, the taste section), then
> the plan file's SITTING RECORD + LEDGER + AF-10
> (`notes/plans/phase-13n-b-mcp-door.md`). The U3 implementer was
> mid-build at the handoff's last update (format v2 done through
> `902f0d30`; no fork pending — AF-10 ruled everything) and may have
> reported or still be running — check the U3 UNIT RECORD and
> `git log --oneline -15` FIRST; never assume its state. Then continue
> per the handoff §3: U3 close → verify → its live round (yours, under
> a stage claim) → U3 ladder (fresh fable-reviewer, the cross-model
> flow verbatim) → U4 brief per R-13nb-26 e/f/g → U4's round + ladder
> → closeout with HER deploy window. The author's standing words that
> bind you: fable-reviewer on every ladder; her etiquette and
> keyboard-bar rulings are law; point-by-point replies;
> verbatim-faithful records; the deploy window is HERS.
