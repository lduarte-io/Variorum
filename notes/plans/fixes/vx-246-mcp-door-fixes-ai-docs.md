# VX-246 — Run: MCP door fixes & AI docs (the RUN record)

**STATUS: OPEN. Kickoff 2026-10-13, 21:20 MDT, by the orchestrator session vx-246, named variorum-84 at kickoff (Opus 5.5 at max effort, her
launch) on the Pro. This file is the live state; read its LIVE STATUS first on any resume.**

**The binding sources.** Every implementer reads these in full, in its own context, before touching code:
- **The plan:** `notes/plans/mcp-pane-and-docs-kickoff.md`. It holds the kickoff, the rulings carried from VX-184's
  pre-run sitting (R-VX184-2/3/4), U7 (the docs, which is this run's U8) and HER ADDITIONS. Its U6 section and the
  VX-268 bullet belong to VX-281, not this run.
- **The release runway:** `notes/plans/vx-33-release-runway.md`, §2 (order, and the conflict map of files two runs
  share) and §3 (VX-246's section).
- **VX-184's run record:** `notes/plans/fixes/vx-184-mcp-launch-polish.md`. Its U1–U5 UNIT RECORDs say what the door
  does today. THE LADDER is where VX-258/259/260/275/276/279/280 were found, traced and ruled.
- **Each member's Linear ticket:** her rulings, verbatim. Each unit's brief below restates what binds.

**Coordinates.** Ticket VX-246 (project *13n — The MCP door*). Branch `vx-246-mcp-door-fixes-ai-docs`. Worktree
`~/dev/variorum-vx-246` on the Pro. One PR, `VX-246: …`, merged with a merge commit. Members close one by one as their
fixes land; every commit names its member and `Part of VX-246`.

**The cast — HER WORD AT THIS KICKOFF (2026-10-13, 21:30 MDT, verbatim), superseding the plan's "everything at max"
and the runway's "Opus / Fable":** *"you're running as the orchestrator Opus at Max thinking - run implementers on
xhigh and Opus cold review on Max. Run a fable cold review when you need to if you do & at the end of the phase if
you didn't need that."*
- **Orchestrator:** session vx-246 (Opus 5.5, max effort; renamed by her from variorum-84, 2026-10-13 ~22:00 MDT).
- **Implementers:** `opus-implementer` at `effort: xhigh`, one fresh one per unit, strictly sequential.
- **The ladder:** `opus-reviewer` at `effort: max`, cold, over the whole run's diff, capped at three rounds, a fresh
  reviewer each round. Same-model flow (CLAUDE.md): the orchestrator arbitrates disputes against the spec, and the
  implementer applies the agreed fixes.
- **Fable:** a `fable-reviewer` cold review WHEN NEEDED. CLAUDE.md requires one whenever the diff touches `Sync/`,
  custody/keychain or the editor seam: here U3 (VX-275's `delete_block` half) and probably U4 (VX-230's badge). If no
  unit needs one, there is ONE Fable cold review at the end of the run anyway, her rule. A Fable review follows the
  cross-model flow, ~~Fable makes the final call on disputes and implements its confirmed fixes itself~~ *[amended
  2026-10-13 by her ruling, main `75f6f275` — CLAUDE.md "Two reviews", the fable-reviewer agent, both phase skills,
  ProcessHistory, the runway §3]*: Fable makes the final call on every finding; the OPUS IMPLEMENTER applies the
  confirmed fixes (red-on-old per finding, the suite green); the next fresh reviewer re-checks them, and a FINAL
  round's fixes (no later round reads them) get the orchestrator's line-by-line check against each finding. Fable
  writes a fix itself ONLY for `Sync/` lines (this run has none) or a finding it marks **FINDER-FIXES** (one line
  why), and the implementer then gets one sanity pass over its diff. The orchestrator's message handing Fable the
  implementer's answers authorizes exactly that and spells the rule out (a loaded agent definition may predate it).
  Her reason: Fable's weekly budget goes to finding and judging, not typing.
- **Why the review matters here:** VX-258 changes the setup key's accept path and VX-279 is the socket road; the
  runway named Fable for both. Under her redirect, the max-effort Opus ladder carries them, and the Fable review
  (needed for the editor-seam units, or held to the end) reads the whole run.

**Members (21, all Pre-launch):** VX-258 · VX-259 · VX-260 · VX-279 · VX-280 · VX-276 · VX-277 · VX-119 · VX-275 ·
VX-230 · VX-231 · VX-267 · VX-253 · VX-252 · VX-255 · VX-311 · VX-298 · VX-254 · VX-256 · VX-261 · VX-197.

**The gates this run carries.**
- **VX-258:** VX-184's build stays HERS ALONE (no public release) until VX-258 ships.
- **The stargazing page:** a build whose instructions carry the link to `https://stargazing.tech/variorum/mcp` ships
  only after that page is live (R-VX184-4).

## THE UNITS (the kickoff's sizing)

The runway suggested six units. Sized against `notes/PhaseSizingGuidance.md` (one acceptance unit, one surface, per
implementer session), they become eight. This was said to her at kickoff. No unit is phase-sized (none is a new mode,
a token pass, a lockstep event or a posture model), so the run sits inside the two-phase-sized-units guidance.

| unit | members | the surface | acceptance evidence | notes |
|---|---|---|---|---|
| **U1** — the door's security and correctness | VX-258 · VX-259 · VX-260 · VX-279 · VX-280 | the setup-key rule and the admission; the wire's book-name check; comment authorship; the server host; the lens picks read | pins red-first per member, red again by revert; the MCP target green across repeated whole-target runs (VX-279); a Mac batch; a REAL-client live round on the dev store | VX-258's ask FACE is built on VX-281's tabbed pane after VX-281 merges (agreed with variorum-75, now vx-281, 2026-10-13). Its core goes first |
| **U2** — the undo class | VX-276 · VX-277 · VX-119 | the structural undo stack's rule (a redo after a quiet undo stays quiet), for MCP entries and her own doors alike | the round-2 probes plus one pin per family, red-first; the sweep (every registration whose redo reads current state: FIXED or provably SAFE); a Mac batch; her Edit menu walked for one family per direction | core only. No pane; no editor seam expected |
| **U3** — her editor vs the wire | VX-275 | a pre-act seam (the app's flush, then the navigate-away) before a wire write tombstones what her editor holds; `delete_block` under her caret | pins; a Mac live round: her pending keystrokes survive a wire delete, and her pane leaves the dead note | **EDITOR SEAM** (the `delete_block` half): read TEXTKIT2_NOTES first. The navigate-away road is shared with VX-283 (VX-123): one road, never a second |
| **U4** — the faces after big writes | VX-230 · VX-231 | the fan badge's placement and refresh (her evening lead on VX-230: badges of many fanned blocks drawn at the first block before layout reaches them); the Bookcase row's counts | red-first pins; a walk in both voices on the dev store with a large fanned note (U1-of-VX-184's repro and hers) | likely the **EDITOR SEAM** (the decoration layer): TEXTKIT2_NOTES first. Check VX-283's VX-122 revival signal before inventing one |
| **U5** — the write tools' shapes | VX-267 · VX-253 · VX-252 · VX-255 | `aiLabel`'s form; `save_lens` by label; `create_note`'s answer (take ids, `section_id`); `insert_blocks` | pins; a real-client live round | VX-253's matcher needs VX-267's form, so they share a unit |
| **U6** — Compare from the wire | VX-311 · VX-298 | `duplicate_note` (her Duplicate as Version); `show_in_app`'s Compare target; `link_versions`' "Open ›" opening Compare | pins; a real-client live round; the Compare board walked in both voices | — |
| **U7** — the agent's read-backs | VX-254 · VX-256 · VX-261 | write-reply digests (every take-writing tool, U5's and U6's new ones included); compact or paged `read_note`; the client's own recent acts | pins; a real-client live round | after U5 and U6, so the digests cover the new tools |
| **U8** — the AI's docs (LAST) | VX-197 | the field guide's MCP chapter; `MCPSession.instructions` (bound 3,000); the tool descriptions; the stargazing brief's delta | the truth pins (`TutorialMCPChapterTests`, the advice's caps); the chapter walked in both voices; a real client reading the instructions | starts ONLY after VX-281 merges and main is merged in. Never concurrent with VX-292, her tutorial session (`TutorialSeeder`) |
| **LADDER** | the whole run's diff | `opus-reviewer` at max, capped at three rounds (same-model flow) | — | plus a `fable-reviewer` cold review WHEN NEEDED (the editor-seam units), or once at the end if none was needed (her word at kickoff) |
| **CLOSEOUT** | — | the merge (serialized through the coordinator), canon deltas, the QUESTIONS bundle, the handoff | — | ~~the `/Applications` refresh waits for the next release (her word, relayed by the coordinator 2026-10-13)~~ *[superseded 2026-10-14 by her word to this session (her rulings section)]*: only the night's FINAL merge refreshes `/Applications`, and the coordinator decides who is last. VX-246 refreshes at its merge ONLY if the coordinator says it is last |

## Hard rules binding every unit

- **Zero `Sources/VariorumCore/Sync/`, custody or Keychain lines.** The run is zero-slot, as confirmed to the
  coordinator.
- **Schema is ALLOWED if needed** (her word, 2026-10-13: *"the next MCP fix session can have a schema change event if
  it seems like we need one."*).
  - A LOCAL-ONLY change rides the grants family's road: `MCPGrantSchema`, its own commit ahead of the code, no
    `sync_version`, no trigger, stripped by the export, marker 13 untouched.
  - A SYNCED change is a SyncSpec §12 lockstep event: stop and report before writing it.
  - Read `notes/SyncSpec.md` in full BEFORE any schema commit, never after (VX-184 U3's recorded slip).
- **The editor seam** (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, the decoration layer,
  `Shared/EditorBrain`): read `notes/TEXTKIT2_NOTES.md` first. Attribute stamps clamp to the verdict's range;
  `runStructural` is the one structural door.
- **VX-281's lane** belongs to session vx-281, formerly variorum-75 (worktree `~/dev/variorum-vx-281`). It covers:
  - `App/Variorum/Variorum/Features/MCP/MCPPane*.swift`, `MCPPaneCopy.swift` and `MCPGrantSheet.swift`;
  - the shared-with-AI icon on the Library, Pool, Book Panel and wing-switcher rows.

  STOP and tell the orchestrator before editing any of them; the orchestrator sequences with vx-281.
- **The stage.** Every `xcodebuild test`, walk, live round, Debug launch and dev-store reset goes through the
  orchestrator to the stage coordinator (session oct13coordinator):
  1. REQUEST: what, how many minutes, the claim name.
  2. READY: built, and able to start now.
  3. GO: only from the coordinator, carrying the exact claim line.
  4. RELEASE: the claim released, then one result line.

  Implementers never message the coordinator; they write THE STAGE WINDOW plan into their unit record, report READY
  and end their turn, and the orchestrator resumes them with the GO. Headless `swift build`/`swift test` and
  `xcodebuild build`/`build-for-testing` need no stage.
- **The DEV store only**, behind an A1 prestage copy that is restored and verified. Never her real store, never
  `/Applications/Variorum.app`, never her user-scope MCP registrations. The live rounds of VX-184's units are the
  worked form.
  - A What's New sheet on a Debug launch: close it with its own button.
  - A lock screen: unlock from `~/.variorum/dev-castle.env` (source it; never invent values, never write them anywhere)
    and restore the posture before release.
  - Blocked by a state another session made: ask the orchestrator. Never discard or reset a store to get past it.
- **Commits** name the member and `Part of VX-246`, with NO attribution trailers, and push after every commit
  (`git pull --rebase` first). `notes/SessionResiliencyProtocol.md` binds: a LIVE STATUS from the first commit,
  records before final verification, and synchronous foreground waits only (poll the log; never end a turn to wait).
- **Pin before fix, PER MEMBER, red on the old tree.** Verify by revert: announce the revert in the record first, run
  it on a committed tree, then restore and verify the restore. A pin green on both sides exposes the row as hollow;
  record that and don't fix.
- **Every PROVISIONAL** lands in the unit record with its options; the orchestrator files `notes/QUESTIONS.md` at the
  merge (the next free number). Pure pane wording goes to VX-234's list, never to QUESTIONS.
- **Disk.** Build into `App/Variorum/DerivedData/vx246-uN` (gitignored), and check free space before a Mac build.

## LIVE STATUS (orchestrator — flipped as units land)

| unit | status |
|---|---|
| U1 — the door's security and correctness | CORE DONE, headless green at `ab552c5a` (MCP 223/48 · core 2,800/324 · workbook 40/6; the Mac build-for-testing built). The implementer is retired at ~678k context (the cutover rule). The rest is U1b, below. U1's Mac batch rides U2's stage window (orchestrator call, see THE ORCHESTRATOR ON U1's HAND-BACK) |
| U1b — VX-258's face and U1's remainder | **PROVEN 2026-10-14 07:06–07:52** (U1b STAGE RUN).<br>• **Pins:** W1a/W1b red on old as designed, so the merge gate is exactly the mint call site.<br>• **W2:** 1,838 tests / 279 suites green except VX-115's standing red.<br>• **The live round passed every leg in both voices,** with a real Claude Code 2.1.299:<br>&nbsp;&nbsp;– legs 0, 1, 2a–2d, 3 and 4;<br>&nbsp;&nbsp;– U2's W2/W3;<br>&nbsp;&nbsp;– ruling 2 with a real client's delete;<br>&nbsp;&nbsp;– U4c's W3.<br>• Leg 5 (Codex) is N/A. The store was restored cmp-SAME. — Earlier: **BUILT, READY FOR STAGE at `edfc0f12`** (U1b UNIT RECORD).<br>• **Main merged in clean** (`5be99e6d`, no conflicts).<br>• **VX-258's face:** the mint call site (the merge gate closed), the Waiting re-bind row, the words and the truth lines.<br>• **VX-318 is HOLLOW:** traced, and the pin stayed green on the pre-fix tree under load while its positive control went red. No product change.<br>• **P-VX260-1 (b)** is built with **v1_29**, a local-only `mcp_comment_author.text_digest`.<br>• **Headless:** MCP 240/51 · core 2,841/329 · workbook 40/6.<br>• The implementer is retired at ~652k; a FRESH runner takes the window (`vx246-u1b`, claim 120).<br>Its window ALSO carries U4c's W1–W3, U2's W2/W3, and ruling 2's real-client check. **UNBLOCKED 2026-10-14 ~04:15** (VX-281 merged: PR #159, `0f5efe1c`; ledgers `3d42df78`; handoff `fa3bc6e1`). IN-PROGRESS: a FRESH implementer from the U1b BRIEF below (~04:35), piece 0 the merge of main. — Earlier: WAITS for VX-281's merge, then a FRESH implementer: the face incl. the mint call site (**THE MERGE GATE** — U1's core must not merge or reach her build without it), VX-318 (OWED 3), P-VX260-1 rebuilt as option (b), the live round (U1's legs 0–5), and U2's MCP walk legs W2/W3 (no detour needed once the face exists). Note for W2/W3: on an empty redo stack the Redo item is DISABLED (`EditorCommands.swift:576`, unchanged), so "nothing to redo" reads as a disabled item, never a toast (U2 STAGE RUN's finding 1) |
| U2 — the undo class | **PROVEN WHOLE:** W2/W3 (the MCP value, toggle and revive directions) passed in U1b's window, 07:06–07:52. — **WINDOW 1 PROVEN 2026-10-14 00:23–00:38** (U2 STAGE RUN below): the Mac batch 1,084 tests / 148 suites green (1,078 + 6 gated skips, 0 failed — U1's G1–G3 included), W1 proven in both voices, the dev store restored cmp-SAME. Open only for W2/W3 in U1b's window. — Earlier: BUILT, headless green at `10223a2d` (MCP 223/48 · core 2,826/326 · workbook 40/6; the Mac build-for-testing built). The implementer is retired at ~634–690k context (the cutover rule). Its stage window (the Mac batch with U1's groups, plus W1, her own door) goes to a FRESH runner; W2/W3 move to U1b's window. The acceptance closes when W1–W3 have run |
| U3 — her editor vs the wire | **WINDOW PROVEN 2026-10-14 02:18–02:54** (U3 STAGE RUN below): W1 red on old 7/8 (17 issues) as designed; W2 1,470 tests / 215 suites green, the one failure VX-167's standing `redoNeverAsks` (alone: green); W3a (a real Claude Code, both voices) and W3b (53 ms / 51 ms after her last keystroke) proven; the store restored cmp-SAME. Finding A (a wire note delete in the OTHER pane moves her focus) is ruled provisionally (ruling 2) and fixed after U4's plan, its proof riding U4's window. — Earlier: BUILT, headless green at `61ec7723` (MCP 236/49 · core 2,826/326 · workbook 40/6; both Mac products built: `vx246-u3-red` is the red-on-old product, `vx246-u3` the fixed one). The implementer is retired at ~620k context (cutover). Its window (`vx246-u3`: the Mac pins red on old, the 215-suite batch, Claude Code by U1's detour, and the timing driver) goes to a FRESH runner. VX-323 (the wider class) was born and fixed here |
| U4 — the faces after big writes | **WINDOW RUN 2026-10-14 03:05–03:41** (U4 STAGE RUN below). **VX-231 PROVEN** (the Bookcase row follows an outside join live, in both voices). **VX-230 PARTLY:** Write is proven (no disc, block 1 bare, scrolled badges at home, first launch clean), but the book view's INLINE editor still misplaces badges after a width change and drops them right after mount (W2's red reproduces alone; seen live in both voices). Two pins are hollow as written, and one characterization pin is defective. → **U4b** below. — Earlier: READY FOR STAGE at `dcfb6123`: piece 6 written (271-suite batch, THE STAGE WINDOW plan for `vx246-u4`, self-assessment, OWED). Products: `vx246-u4-red` (U4's pins, no fix) and `vx246-u4` (both fixes). The window goes to a FRESH runner; its step 6 (ruling 2's proof) moves to U5's window, where ruling 2 is built (orchestrator call). — Earlier: BUILT, PAUSED at `3d1c5dd6` for U3's window (~499k context). VX-230 traced: TK2 reports unlaid paragraphs as empty frames at the top-left, so badges piled at block 1; fixed in `EditorViewModel.refreshBadges`. VX-231 traced: the Bookcase word count was re-read only on appear and its own buttons; fixed in `ShelfViewModel.start`. Mac pins are written but not run, and both products are built. Next: the same implementer writes piece 6 (the batch list and THE STAGE WINDOW plan), then a FRESH session adds ruling 2's fix and runs U4's window with its proof |
| U4b — the inline editor's badges, and ruling 2 | **WINDOW RUN 2026-10-14 04:42–05:16** (U4b STAGE RUN below). W1a/W1b were red on old exactly as designed, so the re-designed phantom pin is no longer hollow. **The walk passed in both voices:** the Outline right after mount, the width change top and deep, the spread's live page, and Write. **RULING 2 IS PROVEN** on her own Delete door. **W2 found ONE REAL REGRESSION from U4b's `refreshBadges`:** `InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport` (an off-screen fan made with no text change stays unbadged on the inline surface). → **U4c.** — Earlier: READY FOR STAGE at `63410c1a` (U4b UNIT RECORD). The re-trace corrected the runner's: the inline height lands on SwiftUI's NEXT pass, and U4's forced `.ensuresLayout` read poisoned the layout, measured up to 1,662 pt off. Fixed in `refreshBadges` plus the one cleared `remeasure` call (`5aaf01b4`); ruling 2 is `select(_:in:takingFocus:)` (`cd843647`). Pins red-first, three products built, headless unchanged. Its window (`vx246-u4b`, 75 min) is run by the SAME session (~250k), queued after U1b's merge commit |
| U4c — the inline badge regression | **PROVEN in U1b's window:** W1 green, the host printing `block 40 laid out = false` (its trace confirmed); W3 passed in both voices, with the ⌘T take far off-screen wearing its badge at its own line. **VX-230 is CLOSED** at the merge. — **BUILT at `6d5dbd90`, with NO product change** (U4c UNIT RECORD). Measured bare TK2 probes show the regressed pin's HARNESS never ran the queued remeasure: `pump()` runs no main-queue hop, and the pin's own height report widened the frame. The in-use road is covered (probes 12–13, 50 and 400 blocks). The pin is corrected to be stronger (it checks the line, covers two roads, and allows no refresh after adoption), and a new mid-reflow pin is added. The orchestrator ACCEPTS this provisionally, with the live walk as the arbiter. **Its window (W1 the two pins, W2 13 suites, W3 the far-off-screen ⌘T walk in both voices) rides U1b's window, on the MERGED product** |
| U5 — the write tools' shapes | **MOVED to the follow-on run** (ORCHESTRATOR'S PROVISIONAL RULINGS, ruling 3); its brief travels with it. — Earlier: NEXT, after U4b. *(9edd8439's "spawned" was premature: U4's GO came first, so U5 never started.)* VX-267/253/252/255 are already In Progress. Ruling 2 moved from U5's piece 0 to U4b; U5's live round adds the real-client check of it |
| U6 — Compare from the wire | **MOVED to the follow-on run** (ruling 3); its brief is drafted for that run |
| U7 — the agent's read-backs | **MOVED to the follow-on run** (ruling 3); its brief is drafted for that run |
| U8 — the AI's docs (LAST) | **MOVED to the follow-on run** (ruling 3), since the docs must describe U5–U7's tools. VX-281 has merged, so it is unblocked there |
| LADDER | **ROUND 1 SPAWNED 2026-10-14 ~08:00:** the ONE Fable review, `fable-reviewer`, cold, REVIEW_PROMPT verbatim with PHASE=VX-246. — Plan: Round 1 is the ONE Fable review (`fable-reviewer`, cold, REVIEW_PROMPT verbatim) over the whole diff, under the cross-model flow as amended 2026-10-13: Fable makes the final call, the Opus implementer applies the fixes. Rounds 2 and 3 are `opus-reviewer` at max, re-checking the fixes. Capped at three rounds |
| FABLE review (when needed, or once at the end) | Folded into the LADDER as its round 1. The editor-seam units (U3, U4, U4b, U4c) need it, and putting it first lets an Opus round re-check Fable's confirmed fixes |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- *(Newest first from here.)* 2026-10-14 07:52:05: **RELEASE `vx246-u1b`** (45 of 120 min). Every live leg passed;
  posture Standard/unlocked, cmp-SAME vs A1; prefs 1,580 keys, 0 differ; fingerprint SAME; the `-s local` registrations
  gone; the A1 copy `scale-prestage-20261014T131848Z` is the coordinator's to prune. Our next stage use is the closeout's
  merge run, after the ladder.
- ~07:40: **SEAM** (the batch half done: 1,838 / 279, only VX-115's standing red). vx-282 hadn't asked for its merge
  run, so the coordinator answered "continue", on the same claim.
- ~07:06: **GO for `vx246-u1b`** under the coordinator's SEAM PLAN: the batch first with no A1 copy, then "SEAM" before
  the A1 copy, so vx-282's merge-gating run could slot in. The claim line was `Tools/stage release --who
  coord-for-vx246 && Tools/stage claim --who vx246-u1b --reason "VX-246 U1b: red-on-old + U4c W1 + 279-suite batch |
  SEAM | live round both voices (A1, MCP fingerprint)" --minutes 120`.
- 2026-10-14 05:16:26: **RELEASE `vx246-u4b`** (34 of 75 min). The result lines went to
  the coordinator. W2 found ONE REAL REGRESSION, now U4c's. Posture: Standard/unlocked, cmp-SAME vs A1; prefs 1,567
  keys, 0 differ; fingerprint SAME. The A1 copy `scale-prestage-20261014T104214Z` is the coordinator's to prune. A guard
  note: vx-282's headless build command line matches `pgrep -f 'Variorum.app/Contents/MacOS'`, so use
  `pgrep -lx Variorum`.
- ~04:40: **GO for `vx246-u4b`** (nobody ahead; a 20-min hold), carrying `Tools/stage release --who coord-for-vx246 &&
  Tools/stage claim --who vx246-u4b --reason "VX-246 U4b: red-on-old x2 + 304-suite batch + inline-editor walk both
  voices (A1)" --minutes 75`. U1b paused before its merge (`c0e23c47`, no MERGE_HEAD).
- ~04:15: **VX-281 merged**, the coordinator relaying: `0f5efe1c`, then the
  ledgers at `3d42df78` (QUESTIONS #219; AppSpec §12/§14) and the handoff at `fa3bc6e1`. Main is to be merged in
  before our merge, and our merge-moment ledger edits land on top of VX-281's §12/§14 lines.

- 2026-10-13, ~21:00 MDT: the kickoff announcement went to oct13coordinator, and its protocol came back:
  - the stage runs REQUEST → READY → GO → RELEASE, with READY sent only once built;
  - merges serialize through the coordinator, asked with origin/main already merged in;
  - no real-store MCP calls and no real-app launches without her recorded word;
  - the `/Applications` refresh waits for the next release (her word);
  - the dev store is in Standard posture, unlocked and restored (vx-184's closeout).

  Zero-slot was confirmed after preflight. The coordinator's ordering call: VX-281 goes first when both runs are READY,
  unless our request is ≤10 min or gates a merge.
- 2026-10-13, ~23:15 MDT: U1 reported READY for a window (~75 min, or ~25 min batch-only). **No request was sent.**
  Every live leg except leg 0 needs the face (or a Deny → re-run → Approve detour), and U1 can't merge before the face
  anyway, so the live round moves whole to U1b. U1's Mac batch rides U2's window: one claim instead of two on a
  contended night. Nothing was asked of the coordinator, so nothing needs cancelling.
- 2026-10-14, ~00:20 MDT: U2 reported READY (~110 min whole, ~50 batch-only). The orchestrator trimmed it to the Mac
  batch plus W1, her own door (~75 min). The MCP legs W2/W3 and their Deny → re-run → Approve detour (U2's step 4)
  move to U1b's window, where the face connects `claude-code` with no detour. REQUEST sent for claim `vx246-u2`.
  READY follows once the fresh runner has read in.
- 2026-10-14 ~00:21: the coordinator queued `vx246-u2`. The stage was FREE, only vx-282's combined window was
  pending, and the first READY would go first. Walks are cleared all night (she's off the Pro); an undismissable system
  popup is reported to it word for word.
- ~00:22: READY sent (built; the runner expects ~70 min; a 90-min claim asked).
- ~00:23: **GO**, carrying `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u2 --reason
  "VX-246 U2: 148-suite Mac batch + dev-store undo/redo walk (A1 prestage, verified restore)" --minutes 90`. Its
  pre-checks: no Variorum instances, no booted sims, 64 GiB free; the dev store left Standard/unlocked/Study,
  byte-identical after vx-281's walk at 00:14. Relayed to the runner verbatim.
- 00:38:15: **RELEASE** (35 of 90 min). The result line went to the coordinator: 1,084 tests / 148 suites green, W1
  proven in both voices, posture Standard/unlocked, cmp-SAME vs the A1 copy (Study voice), prefs 0 keys differ.
  Two notes went with it: the A1 copy `scale-prestage-20261014T062331Z` is the coordinator's to prune, and
  `defaults import` merges rather than replaces (re-export and diff).
- ~00:58: the coordinator relayed her word (to vx-282, ~00:50): runs continue through the night to a merge, ONLY the
  night's final merge refreshes `/Applications`, and the coordinator decides who is last. It asked whether we expect
  to merge tonight. Answered by scope, with no time estimate (her rule): what is left in order, so VX-246 merges after
  VX-281 and likely after VX-282.
- ~01:40: REQUEST sent for `vx246-u3` (the runner's minutes to follow with READY).
- ~01:50: the coordinator queued `vx246-u3`: vx282-u3 (on stage) → vx281-r1fix (critical path) → vx282-u4 → us, if
  we're READY by then, else whoever is READY first. It accepted the guards and asked for the user-scope fingerprint
  verdict (SAME) in the release's posture line.
- ~02:16: **GO for `vx246-u3`**, carrying `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u3
  --reason "VX-246 U3: pins + 215-suite batch + dev-store live round (A1, MCP fingerprint)" --minutes 90`. The
  coordinator held the stage 15 min while U4's implementer paused at a clean seam (3d1c5dd6). Its pre-checks: no
  instances, no sims, 50 GiB free; the dev store Standard/unlocked/Study, the tour offer completed (vx-282's walk, 02:12).
- ~03:05: **GO for `vx246-u4`** at once (nobody ahead), carrying `Tools/stage release --who coord-for-vx246 && Tools/stage
  claim --who vx246-u4 --reason "VX-246 U4: pins + 271-suite batch + import + dev-store walk both voices (A1)"
  --minutes 90`. U5 hadn't been spawned, so the runner started straight away.
- 03:41:03: **RELEASE** (35 of 90 min). Result lines and posture went to the coordinator: Standard/unlocked, cmp-SAME vs
  A1; prefs 1,549 keys, 0 differ; fingerprint SAME. The A1 copy `scale-prestage-20261014T090551Z` is the coordinator's
  to prune. A tooling note: `Tools/stage status` exits 1 while a claim is held, so it can't sit in an `&&` chain.
- ~03:05: REQUEST, then READY for `vx246-u4` (the runner at 4c874e63: ~60 min of work, a 90-min claim asked; a 35-min
  batch-only split offered if vx-282 is mid-window). The coordinator: vx-281's short fix window on stage, then us and
  vx-282's combined window in READY order.
- 02:54:00: **RELEASE** (36 of 90 min). The result lines went to the coordinator with the posture: Standard/unlocked,
  cmp-SAME vs A1; prefs 0 differ; the MCP fingerprint SAME; the `-s local` server gone. The A1 copy
  `scale-prestage-20261014T081813Z` is the coordinator's to prune.
- ~02:05: the U3 runner is READY (348b1a78: both products match the tree, 215 suites listed, her user-scope servers
  fingerprinted). READY sent with a 90-min claim. U4's implementer starts meanwhile, under a PAUSE protocol: at the
  GO, it stops at a clean seam (committed, pushed, the tree clean) before the runner claims, so only one agent runs
  at a time.

## Cross-run coordination

- **VX-281** (session vx-281, formerly variorum-75; `~/dev/variorum-vx-281`, branch `vx-281-run-mcp-settings-pane-shared-icon`).
  - Its lane is listed under the hard rules above.
  - VX-258's ask face is built on the tabbed pane after VX-281 merges (agreed 2026-10-13). Per R-VX184-6 it is a row
    type in the Waiting section, which sits above the tabs, beside the existing grant asks.
  - vx-281 pings the orchestrator at its merge. U8 waits on that merge, and so does U1b.
  - 2026-10-13 ~23:20 MDT: the orchestrator sent vx-281 the face's file list (U1's OWED 1), so its own work can flag
    a collision. No reply was asked unless one exists.
  - **vx-281's answer (2026-10-13 ~23:25 MDT; its HEAD `3e31f78b`, merging after its ladder): no collision, but four
    facts U1b builds on:**
    1. `clientBoundary` and `keyLine` are unchanged, but each now renders as a one-line SUMMARY on the face (e.g.
       `MCPPaneCopy.clientBoundarySummary`), with the full sentence behind an (i) via the new
       `Core/Views/ExplainerLine.swift`. A change to either full sentence brings its summary along.
    2. The setup menu moved out of `MCPPane.swift` into a new `MCPSetupMenu.swift`: the code block, the client choice
       in its header, and the copy icon upper right, which is the same one copy act.
    3. `MCPDoor` gained the setup choice (VX-232): `setupClient` + `chooseSetupClient(_:)`. A copy makes its client
       the chosen one, and choosing another client clears a stale receipt. The `copySetupCommand` line passing the name
       reads the client from there.
    4. Waiting sits ABOVE the tabs, with connection requests beside it. The re-bind row goes there, next to the grant
       asks. The pane remembers its tab on the door (`paneTab`).
    5. **FYI (2026-10-14 ~00:55):** its ladder's R1-3 fix also edits `MCPDoor.copySetupCommand(for:)`. It closes an
       in-flight-copy receipt race and drops or re-aims that function's default argument. That is the function the face
       passes the client name through, so U1b reads it AFTER their merge.
  - **U3's MCPDoor hook:** vx-281 acknowledged it; no collision expected.
- **VX-283** (VX-123's navigate-away road, VX-122's revival signal): U3 builds on the one navigate-away road
  (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`). U4 checks VX-122's signal before inventing a refresh of
  its own (the runway, §2).
- **VX-282** (session vx-282, formerly variorum-da; `~/dev/variorum-vx-282`; the editor seam: VX-290, VX-296): U3's
  and U4's editor-seam lines say so. Neither changes another run's landing or styling rules without saying so.
  - **Its lane note, 2026-10-13 evening (no reply asked).** Both units are committed on `vx-282-editor-notes-fixes`.
    - **Its U2 (VX-296, caret-aware italics):**
      - `EditorViewModel.swift`: one call at the top of `storageDidEdit`, plus a new `settleMarkdownCaret`;
      - `EditorView.swift`: one call in the selection-change delegate;
      - `Surface/PaneSurface.swift`: the pane coordinator;
      - `Shared/MarkdownFace/MarkdownFaceCore.swift` and `Theme/MarkdownStyling.swift`: `restyle` gains an optional
        `caret:` that defaults to today's output, plus a new `settleCaret`;
      - core: an optional `caret:` on `MarkdownSyntax.spans` and a new `Domain/MarkdownCaretRescue.swift`;
      - the phone: `MobileEditorViewModel.swift`.
    - **Its U1 (VX-290):** `BlockRangeIndex`, `EditorEditRoute`/`SeamCarvePlan` and `EditorSurfaceController` (the
      carve's caret landing only).
    - **What it means here:** VX-275's `delete_block` half reaches EditorViewModel's projection deferral, and VX-230
      may reach `PaneSurface`. So U3 and U4 land on top of these files. The orchestrator messages vx-282 before either
      unit starts, and whoever merges second merges main in first.
- **VX-292** (her tutorial session) and **VX-266** (Castle's words in the guide) also edit `TutorialSeeder`. U8 never
  runs at the same time as VX-292, and rebases onto whichever lands first.
- **VX-266** (Castle) is THE `Sync/`-custody effort. This run never touches `Sync/`, custody or the Keychain.

## Her rulings during the run (verbatim; each also on its ticket)

- **VX-275, 2026-10-13 ~21:45 MDT, asked in chat.** The orchestrator proposed option (a): before a wire delete, flush
  her typing and navigate her pane away from the dead note, exactly as her own Delete door does. Her answer: *"yeah
  that's fine on that call."* U3 builds (a).
- **HER OVERNIGHT WORD, 2026-10-14 ~01:05 MDT, to this session, verbatim:** *"I want you to continue on through the
  night ending in a merge to main - the final merge in of the night can be the only one to do an applications refresh.
  Rule provisionally in my absence and leave me a handoff with any needed information to note down."*
  - The run continues unit by unit through the night, to a merge.
  - The `/Applications` refresh happens only at the night's final merge, and the coordinator says which merge that is.
  - The orchestrator rules provisionally where she would rule, never on the author-only list's irreversible acts (her
    accounts or credentials, deleting or overwriting what she made, history rewrites, a synced schema lockstep deploy).
    Every such ruling is logged in ORCHESTRATOR'S PROVISIONAL RULINGS below, for the handoff.
- **P-VX258-2 (U1's bind arm) RATIFIED, 2026-10-13 ~23:35 MDT, in chat.** The orchestrator told her what was built:
  an approved client name with no key tied to it yet (after opening a library from another Mac, or after a deny and
  a re-approve) accepts a key copied from that client's own setup tab with no clicks; any other new key waits for her
  OK. Her answer: *"i ratify what you built"*. It covers only that call; P-VX260-1's option (b) isn't built yet and
  stays provisional. On VX-258 as a comment.

## ORCHESTRATOR'S PROVISIONAL RULINGS (her delegation, 2026-10-14 ~01:05 — each for her ratification in the handoff)

*(Process calls the orchestrator makes on its own authority are recorded in each unit's ORCHESTRATOR section. This
list holds the calls that would otherwise have waited for her.)*

1. **U3's W3b: a scripted client stands in for "a real client" on the timing leg.** Claude Code answers in seconds,
   so it can't land a call inside her 500 ms autosave debounce. A stdlib Python driver on the real Debug shim proves
   the keystroke-vs-act timing; W3a proves the real-client road with Claude Code. Ruled: both legs run, and the driver
   leg counts as the timing evidence.
3. **Tonight's merge scope (2026-10-14 ~05:25).** Her word: *"continue on through the night ending in a merge to
   main."*
   - **The constraint:** the cast runs one agent at a time. Each unit has needed its own build, pins and stage
     window, and sometimes a follow-up (U4b, U4c). The whole-diff ladder and the closeout come after the last unit.
   - **Ruled:** VX-246 merges the units that FIX the door and her editor: U1 with U1b (the merge gate), U2, U3, and
     U4 with U4b and U4c. They go through the ladder and the closeout.
   - **U5, U6, U7 and U8 move to a follow-on run:** VX-267 · VX-253 · VX-252 · VX-255 · VX-311 · VX-298 · VX-254 ·
     VX-256 · VX-261 · VX-197. At the closeout it is minted as its own run ticket with these members re-parented. It
     carries this record's drafted briefs for U5–U7 and the plan's U7 (the docs), and she kicks it off.
   - **Why this seam:**
     - U1–U4 are pre-launch DEFECTS: security, undo, lost typing, wrong faces.
     - U5–U8 are new wire SHAPES plus the docs that must describe them, so they belong together.
     - The diff stays reviewable, her build gets the fixes at the night's merge, and VX-258's arrival lifts VX-184's
       "hers alone" gate.
   - **Nothing is dropped:** every member keeps its ruling and its ticket.
2. **A navigate-away never takes her focus** (U3 STAGE RUN's finding A, 2026-10-14 ~03:00).
   - **The defect:** `WorkspaceModel.notesDeleted` sends each pane that shows a dead note to the Library through
     `select(.library, in:)`, and `select` also moves the focus there (`focusedPane = pane`). So when a client deletes
     the note in the pane she is NOT typing in, her focus jumps to that pane and her own note drops to the read tier.
     U3's wire road newly reaches this; her own Delete door shares the road.
   - **Ruled:** a pane showing a dead note goes to the Library IN PLACE, and the focus stays where it was. Only a pane
     that is itself focused stays focused, as now.
   - **Why:** her ruling (a) is "navigate away as her own Delete door does". The door's intent is to leave the dead
     note, never to move her typing elsewhere, and a calm surface never steals the caret.
   - **The side effect, said:** her own door deleting from one pane a note open in the OTHER pane no longer moves her
     focus either.
   - ~~**Built:** after U4's plan, red-first, with its proof in U4's window.~~ *[re-placed 2026-10-14 ~03:20 by
     the orchestrator]* **Built as U5's piece 0,** red-first. **Proven in U5's window** with a REAL client: a
     `delete_note` on the note in her other pane while her caret types in the first, and her caret stays. U4's window
     runs on its products as built, so it isn't held for a rebuild.

## Tickets minted from this run

*(any unit's mints join this table, and the closeout handoff lists them all)*

| ticket | born | what | fate |
|---|---|---|---|
| VX-318 | U1's OWED 3 (the implementer, 2026-10-13) | MCP socket: a session's reader thread can read another socket's bytes after the host closes its descriptor. Same fd-reuse class as VX-279; traced by reading | a member (sub-issue of VX-246, Pre-launch); built in U1b with a red-first pin |
| VX-323 | U3's trace of the wider class (the implementer, 2026-10-14) | MCP rewrites, restructures, freezes and copies read the stored row, never her pending typing (`edit_take`, `restore_commit`, `divide_block`, `merge_blocks`, `lock_take`/`archive_take`, `save_commit`/`save_version`) | a member, born and FIXED in U3 by the same pre-act flush as VX-275 (pins red-first) |
| VX-324 | U3's OWED 2 (the implementer, 2026-10-14) | The Takes board's Lock / Archive / Delete-take doors may not flush her typing first. Her own doors; noticed, not reproduced | Todo, v1 release readiness, Bug. Probe red-first before any fix; NOT this run's |
| VX-327 | U4's OWED (the implementer, 2026-10-14) | Callouts, comment cards and seams may read TK2's empty frames for unlaid paragraphs the same way the badges did, and pile at the top in the book view's editor after a width change | Todo, v1 release readiness, Bug. Probe red-first before any fix; NOT this run's |
| VX-328 | U3 STAGE RUN's finding B (the runner, 2026-10-14) | With a split open, the Library catalog in the right pane draws past the divider and clips the left pane's header (both voices) | Todo, v1 release readiness, Bug; possibly VX-283's. NOT this run's |
| (VX-318) | — | Dismissed as HOLLOW in U1b, not fixed: the descriptor closes only after `run()` returns, which waits for the reader's own finish. Pin `MCPReaderAfterCloseTests` is green on both trees; its positive control is red | Closes at the merge as not-a-bug, with the pin kept as a guard |
| VX-333 | U4c's OWED 3 (the implementer, 2026-10-14) | Test harness: `pump()` runs no main-queue hop inside a main-actor test, so pins relying on it read the state before a queued hop. Sweep them | Todo, v1 release readiness, Debt. NOT this run's |
| VM-17 | U4's OWED 3 (the implementer, 2026-10-14) | The phone's fan badges may pile at the first block on long fanned notes, like VX-230 on the Mac (if they read TK2 fragment frames the same way) | the VM board (Mobile — editor & capture faces, Backlog). Probe first |
| VM-16 | U2's OWED 2 (the implementer, 2026-10-14) | The phone's undo door says "Undid: …" on a quiet press: `MobileUndoDoor` still calls `undo(with:)`/`redo(with:)`. The fix is the Mac door's two lines; the rule itself already reaches the phone | the VM board (Mobile — editor & capture faces, Backlog); it needs a simulator stage; related to VX-276 |

## THE RUN AS IT MERGES — the map (orchestrator, before the ladder)

*(A factual map for the ladder and the closeout. Each unit's record above is the evidence; this section adds no claim of
its own.)*

**Scope (ORCHESTRATOR'S PROVISIONAL RULINGS, ruling 3).**
- **Tonight's merge carries the FIX units:** U1 + U1b, U2, U3, U4 + U4b + U4c.
- **U5, U6, U7 and U8 moved to a follow-on run** (VX-267 · VX-253 · VX-252 · VX-255 · VX-311 · VX-298 · VX-254 ·
  VX-256 · VX-261 · VX-197). Their briefs above stay as drafts for that run, and no code of theirs is on this branch.

**Members in this merge, and where each one's record is:**

| member | what | unit record | state at the ladder |
|---|---|---|---|
| VX-258 | setup keys tied to their tab; an Any-client re-bind waits for her OK (the core v1_28, the face) | U1, U1b | PROVEN (U1b STAGE RUN, legs 0–2d) |
| VX-259 | book names checked only against books the client can read | U1 | PROVEN (leg 3) |
| VX-260 | her edit makes an AI's comment hers (option (b), the v1_29 digest) | U1, U1b | PROVEN (leg 4, (a) and (b)) |
| VX-279 | the server host's fd reuse | U1 | built; proven by pin + probe |
| VX-280 | `save_lens`' picks read (P1) | U1 | built; plan pin |
| VX-318 | the reader thread after close | U1b | HOLLOW, not fixed; pin kept as a guard |
| VX-276 · VX-277 · VX-119 | the undo class: a quiet half retires its entry | U2 | PROVEN (W1 in U2's window; W2/W3 in U1b's) |
| VX-275 · VX-323 | the pre-act flush before wire writes; the caret landing; the navigate-away | U3 | proven (U3 STAGE RUN) |
| VX-230 · VX-231 | the badge pile; the Bookcase count | U4, U4b, U4c | PROVEN (U4, U4b; U4c's W3 in U1b's window) |
| ruling 2 | a navigate-away never takes her focus | U4b | PROVEN (her door in U4b's window; a real client in U1b's) |

**Schema:** two LOCAL-ONLY steps on the grants family's road, each its own commit: v1_28 `mcp_rebind_request` (U1)
and v1_29 `mcp_comment_author.text_digest` (U1b). Marker 13 untouched, zero lockstep, no `Sync/` lines.

**The editor seam** (the reason Fable reviews):
- U3's external-removal caret landing in `EditorSurfaceController.renderFull`;
- U4/U4b's `EditorViewModel.refreshBadges`;
- U4b's one call in `InlineEditorSurface.Coordinator.remeasure` (`EditorView.swift`);
- U4c's pins.

**Main merged in:** `5be99e6d` (VX-281's PR #159 plus its ledgers and handoff), clean.

**Known and owed before the merge (the orchestrator's list):**
- the field guide's MCP chapter, lesson 2 (`TutorialSeeder.swift` ~l.2552): its "Running the setup again moves the
  name…" sentence is now true only of a client's own tab. A minimal truth edit plus `TutorialMCPChapterTests`' pin,
  in the first fix pass;
- canon at the closeout: AppSpec §7's grants family gains v1_28 and v1_29; §9's structural undo/redo contract line
  (U2's OWED 3); §12 THE MCP DOOR's A-4 amendment as VX-258 built it, the book-name check, her-edit-makes-it-hers by
  digest, and the pre-act flush and navigate-away (U3's OWED 5); TEXTKIT2_NOTES §3's measured facts (U4b's corrected
  proposal and U4c's harness fact);
- the QUESTIONS bundle (the PROVISIONALs of every unit, and the orchestrator's rulings 1–3), from #220.
- **for VX-234's wording pass, from U1b's live round:** while the ask is fresh, the re-bind row's detail reads
  "…with a setup that wasn't copied for it, now. It reaches…".


## UNIT BRIEFS (the orchestrator's; each unit's implementer is spawned from its brief)

### U1 BRIEF — the door's security and correctness (VX-258 · VX-259 · VX-260 · VX-279 · VX-280)

**What binds, per member** (the ticket text is the full record; her words are verbatim):

1. **VX-258: setup keys tied to their tab; an Any-client re-bind waits for her OK.**
   - **The hole** (VX-184's round-1 MAJOR, confirmed by trace): `mintMCPSetupKey()` mints an untagged key, and
     `MCPSetupKeyRule.decide` returns `.rebind` for any unclaimed key under a bound name. The `.rebind` admission keeps
     the client's approval and grants. So a tool she is trying through "Any MCP client" that calls itself `claude-code`
     inherits Claude Code's grants with no approval step.
   - **HER RULING:** *"tie keys to their tab and for the general "Any MCP client" case, we should probably do the
     re-bind waits for my ok? i don't want everyone who isn't using claude or codex to be vulnerable to this. the best
     protection at each level"*.
     - A key copied from the Claude Code or Codex tab re-binds ONLY that tool's name, with zero clicks (R-VX184-5 as
       she ruled it).
     - An "Any MCP client" key presented under a bound name re-binds only after her OK: a quiet ask, with no reach
       until she allows.
     - The VX-168 impostor pin (a fresh MINT presented under a bound name) returns, red-first. VX-184 rewrote it to a
       never-minted key; restore its original threat.
   - **Argue in the record:**
     - **Where the tab tag lives.** Option one: inside the authenticated key text. The stored hash covers the whole
       key as presented, so a tag in the key can't be altered without the hash missing, and it needs no schema. Option
       two: a local-only column on `mcp_setup_key` (a schema change on the grants family's road: its own commit, zero
       lockstep).
     - **What a Claude Code or Codex tab key does under a DIFFERENT bound name**, and under an unknown name.
     - **What she hears if she answers "Don't allow"**, and what the client hears while it waits. A refusal stays one
       sentence, with no oracle.
     - **Verify each tab's real `clientInfo.name` live.** Claude Code is on the Pro. For Codex: if its CLI isn't
       installed, the name comes from an external lookup (your one Sonnet lookup agent may fetch Codex's source or
       docs), and the record says so.
   - **The ask's FACE waits for VX-281.** Build the core first (the rule, the pending re-bind state, the admission's "no
     reach until she allows", and the model API her answer calls). Then STOP before any edit under
     `App/Variorum/Variorum/Features/MCP/` and report. The orchestrator merges main in once VX-281 lands, then
     green-lights the face. If VX-281 hasn't landed when everything else in U1 is done, the unit closes with the face
     recorded as OWED: a short follow-up, not a silent gap.
   - Activity speaks the new arms in words. Wording ships AS BUILT and goes on the FOR VX-234 list.
2. **VX-259: book names are checked only against books the client can read.**
   - `rename_book` (VX-184) and `create_book` (13n-c) refuse a name any live book uses, Private and other wings'
     included, and echo the stored name: an oracle, against F-7.
   - **HER RULING:** *"it's fine if an accidental book name duplicate is made - there's no schema protection against
     it and we already ruled that it's ok if that happens."*
   - The door's check compares only against books the client can READ. Her own doors keep the full E13 guard.
   - Fix both tools. Pin red-first: a Private book "secret", an edit grant on another book, then
     `rename_book(other, "secret")` lands and names nothing.
3. **VX-260: her edit makes an AI's comment hers.**
   - Once she has edited an AI's comment, deleting it needs EDIT, and a suggest caller hears her ruled R-VX188-2
     sentence.
   - Argue the road: her edit clears the authorship record, or the delete compares the comment's `updated_at` with the
     record's `recorded_at`. Mind the batch undo/redo's revive stamp.
   - Pin red-first.
4. **VX-279: the server host's fd reuse** (pre-existing since 13n-b).
   - `MCPServerHost.serve` closes the fd BEFORE the session leaves `sessions`, so a stale `hangUp()` in `stop()` can
     shut down an unrelated socket that reused the number.
   - Fix: deregister under the host lock before `close`, and make `hangUp()` a no-op once closed (one per-session lock).
   - Pin: the round-2 reviewer's probe `hangUpAfterCloseShutsDownAReusedDescriptor`.
   - Evidence of the load flake's end: the whole MCP target green across repeated whole-target runs under concurrent
     load. The count of runs is yours to justify; VX-184's round 2 saw 4 failures in 14.
5. **VX-280: `save_lens`'s picks check reads the whole note** (a P1 breach).
   - `MCPWriteTools.picks` gets the round-2 fix pass's shape: the given ids drive through a `json_each` `CROSS JOIN`,
     seeking `uq_cblock_ownership`.
   - Pin it with a query-plan test (`MCPPreCheckPlanTests` is the precedent); every refusal stays byte-identical.

**Evidence that closes U1:**
- headless pins for every member, red-first and red again by revert;
- the whole headless package green, with counts;
- a Mac batch covering every changed SOURCE file's suites (grep the tests for the changed types; 13x's lesson);
- a REAL-client live round on the dev store (`claude -p` turns, the VX-184 units' form). Its legs:
  1. a Claude Code tab key re-binds `claude-code` and nothing else;
  2. an Any-client key presented as `claude-code` waits, with no reach;
  3. the rename to a hidden book's name lands without echo;
  4. a suggest client's delete of a comment she edited hears her sentence;
  5. Codex's leg, if Codex is present.

**Out of scope:** the guide and `MCPSession.instructions` (U8); every other member; anything in VX-281's lane before
the orchestrator's word.

### U2 BRIEF — the undo class (VX-276 · VX-277 · VX-119)

**The one rule, for every family, MCP entries and her own doors alike:** an undo writes only over the act's own
result, and a redo after a QUIET undo (an inverse that wrote nothing) stays quiet. One mechanism; one pin per family,
red-first.

**What binds, per member.** Each ticket's text is the record, quoted VERBATIM below; its rulings came through
VX-184's ladder dispositions.

1. **VX-276: a redo after a quiet undo re-applies the client's act over her own reversal (every direction).**
   > **Also in scope (VX-184 round-2 fix pass):** `delete_block` / `delete_take` after she Puts the block back from the
   > tray — her Put back registers no undo entry, so ⌥⌘Z (quiet) then ⇧⌥⌘Z re-deletes what she restored.
   >
   > **WIDENED at VX-184's review round 2 (2026-10-13):** the whole class — **a redo after a QUIET undo re-applies the
   > client's act** in EVERY direction, not just reviving a removed row. `UndoStack.undo` moves any non-throwing
   > inverse onto the redo stack, even one that wrote nothing, so: the client acts → she reverses it with an undo-less
   > door of hers (unlock, reopen, rename back, Put back, restore a chapter or a comment, unarchive) → ⌥⌘Z is quiet →
   > ⇧⌥⌘Z writes the client's act over hers. Covers: lock, finish/reopen, archive_book, delete_book, delete_chapter,
   > delete_note, archive/unarchive_note, delete_comment, the compare-and-set value family when she sets the value
   > back (rename_book, …), the pre-existing set_entry_date, file_note_in_chapter, set_book_rule, set_block_name,
   > choose_take, adopt_lens, and `reapplyMCPWingMove` proceeding with a nil `backwardStamp`. **One fix for all:**
   > each entry's inverse records whether it wrote; the redo returns quietly when the last inverse wrote nothing (the
   > house precedent: `restoreCommentForClient`, `save_lens`, `link_versions`); the compare-and-set stays. Pins: the
   > round-2 reviewer's probes (`lockRedoAfterQuietUndo`, `finishRedoAfterQuietUndo`,
   > `renameBackToOriginalThenQuietUndoThenRedo`, `deleteNoteRedoAfterHerPutBackAndAQuietUndo`,
   > `deleteChapterRedoAfterHerRestoreAndAQuietUndo` — red on VX-184's tip), one per family. Detail: the VX-184 run
   > record `notes/plans/fixes/vx-184-mcp-launch-polish.md` § THE LADDER (round 2).
   >
   > Found by VX-184's round-1 fix-pass sweep (the adjacent class to the compare-and-set fix): when an MCP act's undo
   > goes quiet because she has since changed things, the REDO still revives rows she removed by hand. Affected:
   > `add_comment(s)`, `create_note` / an imported note / `save_version`, `apply_tag`, `create_section`, and
   > `add_note_to_book`'s seat case. House precedent for the fix: a stamp-keyed redo, as `save_lens` and `create_book`
   > already do — revive only rows still carrying the act's own stamp. Red-first pins per family. Detail: the VX-184
   > run record § THE LADDER → ROUND 1 — FIX PASS.
2. **VX-277: her own doors' undo/redo overwrite what she changed since (lens adopt; a block delete after a tray Put
   back).**
   > **Widened (VX-184 round-2 fix pass):** the same shape outside the MCP family also hits her own Delete Block
   > gesture — she deletes a block (an undo entry), Puts it back from the tray (no entry), then ⌥⌘Z / ⇧⌥⌘Z act over
   > her restore. One rule for her doors, the MCP road's (VX-276): a redo after a quiet undo stays quiet; an undo
   > writes only over the act's own result.
   >
   > Found by VX-184's round-1 fix-pass sweep, outside the MCP family: her own "✓ Make this the note" adopt doors
   > restore every chosen pointer on undo unconditionally. Choosing a take registers no undo entry, so adopting a lens,
   > then choosing a different take on some block, then ⌥⌘Z (undoing the adopt) silently overwrites her later choice.
   > The MCP road was fixed in VX-184 with a per-slot compare-and-set (`restoreChosenPointersIfUnchanged`); her doors
   > keep the old helper. Fix: route them through the same rule, red-first.
3. **VX-119: the undo-pair class — `reapplyMintedContainer`'s redo resurrects a hand-deleted note.**
   > Found adjacent to 13n-a's F1 (fixed for `importBook` at `1a3036bf`): the SHARED single-container pair
   > `revertMintedContainer`/`reapplyMintedContainer` (since 13c; the copy ops and now the single-file import door
   > ride it) keys its redo on current state, not the stamp the undo wrote. Traced by READING ONLY (no probe run):
   > import one file → delete the note by hand → ⌥⌘Z (no-op, already dead) → ⇧⌥⌘Z brings back the note she deleted.
   > Pin-before-fix: write the red probe FIRST; then the F1 fix shape (a LockIsolated stamp box). SWEEP instruction
   > (the class-completeness rule): enumerate every structural-undo registration whose redo reads current state
   > instead of the undo's stamp — instance × host table, each FIXED or provably SAFE. Record:
   > `notes/plans/13na-ladder-round1.md` (the fix-round report's first left-undone item).
   >
   > **R2-1's rule rides this sweep (2026-10-09, ladder round 2):** an inverse that tombstones NOTHING must return nil
   > and never overwrite the stamp box — else each fixed pair inherits the retried-undo regression (fixed for
   > `revertImportedBook` at `ead486c4`, pin `aRetriedCompoundUndoStillRedoesEveryBook`).

**Read before code** (in your own context; this list adds to the run's binding sources):
- `Sources/VariorumCore/Operations/UndoStack.swift` whole, and the registration sites the tickets name.
- VX-184's record: THE LADDER's ROUND 1 — FIX PASS, THE SWEEP TABLE and its ROUND 2 READING (from about line 2010),
  and ROUND 2's findings and dispositions (from about line 2195).
- `notes/plans/13na-ladder-round1.md`.

**Argue in the record, before code:**
- **Where the rule lives.**
  - (a) In `UndoStack` itself: `undo` learns from the inverse whether it wrote, and a quiet undo's entry then redoes
    nothing, or never reaches the redo stack.
  - (b) Per entry: each inverse records what it wrote, and its redo keys on that. This is the house precedent:
    `restoreCommentForClient`, `save_lens`'s `undoneOn:`, `link_versions`, and `importBook`'s F1 stamp box.
  - Weigh the redo-future rules: a new structural act clears it, and undoing past a `redo: nil` entry ends it. Weigh
    how many files hold registrations, and whether a future registration could forget the rule.
  - Whichever road you pick, the compare-and-set on the UNDO side stays.
- **What she sees on a quiet press.** What ⌥⌘Z and ⇧⌥⌘Z say when nothing changes, on AppSpec §12's one status seam,
  where a door that did nothing speaks a refusal. Keep the client-named words of MCP entries. Wording ships as built
  and goes on the FOR VX-234 list.
- **The revive direction:** a stamp-keyed redo that revives only rows still carrying the act's own stamp, under
  R2-1's nil rule.

**THE SWEEP (VX-119's class-completeness rule, over BOTH families):** every structural-undo registration whose inverse
or redo reads current state instead of what the act or the inverse wrote. Build it as an instance × host table, each
row FIXED (red-first) or provably SAFE (one line of reason). Start from VX-184's SWEEP TABLE and ROUND 2 READING;
VX-184's dated strike-throughs mark which of its verdicts were false.

**STOP and report before:**
- **any edit on the editor seam:** `EditorViewModel`, `EditorSurfaceController`, `EditorTextView`, `BlockRangeIndex`,
  `PaneSurface`, `PaneTextAuthority`, or the editor half of the structural door. vx-282's lane is live there, and an
  editor-seam diff brings a Fable review.
- any edit in VX-281's lane (the hard rules above);
- an author-only call, or an ambiguity that gates the core.

**Evidence that closes U2:**
- **Pins:** the five round-2 probes red-first, plus one pin per family — the revive families, VX-277's adopt doors,
  Delete Block after Put back, and VX-119's single-file import and copy ops. Each goes red again by revert.
- **The sweep table, complete.**
- **The whole headless package green,** with counts: core, MCP and the workbook.
- **A Mac batch, one claim, `vx246-u2`.** It covers every changed SOURCE file's suites (grep the tests for the changed
  types; 13x's lesson). It also runs U1's planned batch: U1's THE STAGE WINDOW, its three groups. U1's live legs are
  NOT yours (they wait for U1b).
- **Her Edit menu walked on the dev store,** one family per direction (value, toggle, delete, revive), through ⌥⌘Z /
  ⇧⌥⌘Z. At least one MCP family is driven by a real `claude -p` turn, and at least one is her own door. Capture any
  face whose words change.
  - **If `claude-code` needs a fresh setup on the dev store:** U1's core makes an untagged key WAIT under an approved
    name, and nothing on screen can answer it yet. The road around it is U1's: THE STAGE WINDOW's legs 3–4 (Deny →
    re-run the setup → Approve). Its existing bound key keeps working.

**Context:** if your context passes ~500k before the unit is done, stop at the next clean seam: committed, green, the
continuation written in your LIVE STATUS. Then report; the orchestrator continues with a fresh session.

**Out of scope:** every other unit's members; VX-318 and the rest of U1b; the guide (U8).

### U3 BRIEF — her editor vs the wire (VX-275)

**What binds.**
- **The ticket, VERBATIM:**
  > Found by VX-184's review ladder (round-1 finding on `delete_note`, traced read-only in the fix pass): **no MCP write
  > coordinates with her open editor at all.** There is no flush in `Sources/VariorumMCP` and no hook for one. When a
  > wire `delete_note` or `delete_block` tombstones the take she's typing in, her pending keystrokes are refused and live
  > only in memory: ⌥⌘Z / Put back return the take WITHOUT them unless another flush happens that session, and quitting
  > loses them. A wire `delete_note` also never sends the navigate-away her own Delete door sends (`NoteDeletion.swift`
  > flushes first and says why). Fix: a pre-act hook (the app's flush + navigate-away) before a wire write tombstones
  > what her editor shows. **The** `delete_block` **half reaches the editor seam, so the review is Fable's (CLAUDE.md)
  > and the proof is a Mac run.** Trace + ticket-ready summary: the VX-184 run record
  > `notes/plans/fixes/vx-184-mcp-launch-polish.md` § THE LADDER → ROUND 1 — FIX PASS.
- **HER RULING** (this record's "Her rulings during the run"): option (a). Before a wire delete lands, the app saves
  what she has typed and moves her pane off the deleted note, exactly as her own Delete door does. *"yeah that's fine
  on that call."*
- **The trace:** VX-184's record, THE `delete_note` / `delete_block` FLUSH TRACE (about line 2077 onward). It gives the
  mechanism, the three needs, the residual window and the "plausibly wider" class.

**The work.**
1. **A pre-act seam on the wire.** Add a new `MCPHostHooks` hook that the server awaits BEFORE `executor.run`.
   - It runs for every act that tombstones rows her editor may hold. Argue the act list in the record: `delete_note`,
     `delete_block` and `delete_take` at least, and any book or chapter act that takes notes down with it.
   - Wire it in `MCPDoor` to the app's flush, `AppSession.flushExistingAutosave`, the road her own doors use
     (`NoteDeletion.report`).
   - The flush is its own runner turn, so it runs BEFORE the act's turn, never inside it.
2. **The navigate-away after a landed note death.** After a landed `delete_note`, and any wire act that leaves a note
   dead, post on THE ONE ROAD: `.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`. That is exactly what her Delete
   door and her structural-undo door's WA-3 (`leaveNotesTheActLeftDead`) post. Never a second road: VX-283's VX-123
   builds on this one later.
3. **`delete_block` under her caret — THE EDITOR SEAM.** Read `notes/TEXTKIT2_NOTES.md` first.
   - After the flush, the block's text is stored. The editor must then drop the dead block's range the way her own
     Delete Block does: find that road and reuse it.
   - The trace names `EditorViewModel`'s projection deferral (`applyPendingIfClean`'s guard) and the block-range map.
   - Attribute stamps clamp to the verdict's range, and `runStructural` is the one structural door.
4. **The wider class — trace it first.** VX-184's trace called it plausible but untraced. Every wire act that REWRITES
   rows her open editor holds unflushed (`edit_take`, `restore_commit`, `divide_block`, `merge_blocks`, …) checks its
   precondition against the STORED text, never her pending buffer, so her next flush can write her old buffer back over
   the act.
   - **If the trace holds,** the fix is the same seam: flush first, so the act's precondition sees her latest text and
     a mismatch refuses with the existing stale-text refusal. Her own doors already flush before they act, so this
     applies her rule to the wire; it is not new product behavior.
   - Pin it red-first per family, and report it. I mint its ticket from your report.
   - **If the trace fails,** record the pin that stayed green on both sides and leave it unfixed.
5. **The residual window.** A keystroke typed between the flush and the act's turn stays pending. Argue in the record
   what happens to it for a delete and for a rewrite. If it can't be closed cheaply, give options and mark it
   PROVISIONAL.

**Lanes.**
- **vx-282's editor-seam work** is NOT on our branch: it is committed on `vx-282-editor-notes-fixes`, unmerged. Its
  files are listed under Cross-run coordination above. Keep U3's editor edits out of those functions:
  `storageDidEdit`'s top, `settleMarkdownCaret`, the selection delegate, `PaneSurface`'s coordinator, the markdown face,
  `BlockRangeIndex`, `EditorEditRoute`/`SeamCarvePlan`, and `EditorSurfaceController`'s carve landing. If the fix needs
  one of them, STOP and report; I coordinate with vx-282.
- **`MCPDoor.swift`:** vx-281 changed it on its own branch (`setupClient`/`chooseSetupClient`, VX-232). Keep U3's edit
  there to wiring the new hook.
- **VX-281's lane** (`MCPPane*`, `MCPPaneCopy`, `MCPGrantSheet`, the shared icon): out.

**Evidence that closes U3.**
- **Pins**, red-first per family and red again by revert:
  - headless: the seam's order — a fake host hook proving the flush ran before the act's turn, and the delete acts
    calling it;
  - Mac-level: a pending autosave plus a wire delete through the door leaves her bytes in the tombstone and moves her
    pane off the dead note; a `delete_block` under a pending buffer lands her bytes first and the editor drops the
    range;
  - the wider class's pins, if its trace holds.
- **The whole headless package green,** with counts.
- **THE STAGE WINDOW plan** in your record (claim name `vx246-u3`): a Mac batch over every changed source file's
  suites, and a live round on the dev store.
  - The live round shows her pending keystrokes surviving a real client's `delete_note` and `delete_block`, and her
    pane leaving the dead note, captured.
  - The real client needs `claude-code` connected. Use U1's documented detour (Deny → re-run → Approve) or wait for
    U1b's face; say which.
  - From U2's run: on an empty redo stack the ⇧⌥⌘Z item is disabled, so no toast appears.

**Fable.** This diff reaches the editor seam, so the run owes a `fable-reviewer` cold review (CLAUDE.md). It is the
orchestrator's to run after the units; keep the record reviewable.

**Context:** past ~500k, stop at the next clean seam (committed, green, the continuation written) and report.

**Out of scope:** every other unit's members; VX-318 and the rest of U1b; the guide (U8).

### U4 BRIEF — the faces after big writes (VX-230 · VX-231)

**What binds, per member** (each ticket is the record; her words are verbatim).

1. **VX-230: the fan badge after big writes.** Her word: a pre-release fix.
   - **The ticket, VERBATIM:**
     > **In VX-246 at her word** (2026-10-13: *"I want that fix added to the upcoming session."*). Her new observation:
     > *"I found that going into takes mode and expanding and closing it fixed it, which makes it seem even more like a
     > chrome issue."* Lead: a stale badge face after an MCP write, not wrong data. Possibly the same root cause as
     > VX-231 (a face not refreshed after an MCP write).
     >
     > Noticed in VX-184 U1's live round (2026-10-13, dev store): Block 001 of a 300-block MCP-written note wore a darker
     > ⑂2 badge with exactly one take in the store, surviving scroll-away-and-back; the six truly fanned blocks badged
     > correctly. Mechanism unverified, nothing fixed. Record: notes/plans/fixes/vx-184-mcp-launch-polish.md (U1 OWED 3a).
     >
     > **Her real-store sighting (2026-10-13 ~02:23, her report + screenshot shot-20261013-022301.png):** same
     > first-block signature in her own work — an MCP-connected Claude added blocks and takes to a note in "o ladrão de
     > raios"; the FIRST block's take badge (a REAL take — the fan exists) renders as a fully black filled disc, while
     > every other block's ⑂2 badge renders normally. Her caret was in block 1 (the focused/live block); U1's sighting
     > also had the landing focused on block 1 (⌥⌘O). Two readings to keep apart until traced: (a) a RENDERING defect —
     > the badge on the first/focused block draws dark/black; (b) U1's original phantom-badge reading (a badge where the
     > store holds one take). Possibly one bug (U1's "darker ⑂2" may have been the same black rendering, with the take
     > count separately right or wrong), possibly two. **Her word: pre-release fix.**
   - **Her further observation, 2026-10-13 evening, VERBATIM:** *"the black mark on takes is there even when you
     haven't been in the book it's just there on first launch, then resolves a little, then is fixed. and it appears
     even in the book view where it shouldn't, like all the takes are gathered on top of the first one is what it
     looks like."*
   - **Her screenshots** (on the Pro; read them):
     - `~/shots/shot-20261013-174949.png`: the book "o ladrão de raios", Outline mode, chapter 1's first block
       (the chapter's opening Portuguese line) wearing the dark disc at the right edge.
     - `~/shots/shot-20261013-022301.png`: her real-store sighting.
   - **The lead to test FIRST** (the orchestrator's comment on the ticket; a hypothesis, NOT a traced mechanism):
     - The fan badges of MANY fanned blocks are placed at the FIRST block's position before TextKit 2's lazy viewport
       layout reaches their blocks. They move to their real places as layout catches up, and the overlapping
       translucent badges darken into one black disc.
     - If so, the MCP write is incidental: the trigger is a note with many fanned blocks below the fold. U1's "⑂2 on a
       single-take block" would then be a neighbour's badge drawn in the wrong place.
     - It reaches the decoration layer and TK2 geometry, which is THE EDITOR SEAM.
     - The pin to try first: open a note whose fanned blocks start below the viewport, and assert that no badge rect
       sits at another block's position.
     - Her clue stands: a Takes-mode expand/collapse clears it, because that re-runs layout. So does "even in the book
       view where it shouldn't": trace which book surface draws badges at all, and whether it should.
2. **VX-231: the Bookcase row counts read stale right after a large note joins a book.**
   - **The ticket, VERBATIM:**
     > **Possibly the same root cause as VX-230:** a face not refreshed after an MCP write (both seen right after big
     > MCP writes). **Joined VX-246 at her word (2026-10-13: "yes, add VX-231 to VX-246. all MCP fixes together.")** —
     > investigate beside VX-230.
     >
     > Noticed in VX-184 U1's live round (2026-10-13, dev store): immediately after the 32k-word MCP-written note joined
     > the book, its Bookcase row read '7 notes · 3 ch · 120w'. Mechanism unverified, nothing fixed. Record:
     > notes/plans/fixes/vx-184-mcp-launch-polish.md (U1 OWED 3b).
   - **Check VX-122 before inventing a refresh** (the runway's §2). VX-122 is in VX-283, which has not started: "A
     live Library misses revivals — Put back, structural redo, and sync restores all fail to refresh it … Fix wants
     ONE revival signal or an observation that covers restores." Its trace is in `notes/plans/phase-13n-a-document-format.md`
     (WALK-FIX PASS, WA-4).
     - If VX-231's cause is a count or projection that isn't re-read after a write, prefer the existing observation
       roads over a new notification.
     - If the fix would BE VX-122's one revival signal, STOP and report: that's VX-283's ticket, and I coordinate.

**THE EDITOR SEAM.** Read `notes/TEXTKIT2_NOTES.md` in full BEFORE any edit there.
- Decorations stay off the live storage, and you never touch TK1 APIs (`.layoutManager` silently downgrades).
- Attribute stamps clamp to the verdict's range.
- The Fable review is the orchestrator's to run after the units; keep the record reviewable.

**Lanes.**
- **vx-282's editor-seam work** is NOT on our branch. Stay out of its listed functions (Cross-run coordination above).
- **vx-282's answer, 2026-10-14 ~02:00: none of its units touch the badge's road.** It plans no change to
  `BlockDecor.swift`, the gutter cards, `ProseGutter`, any decoration overlay, or the TK2 geometry they read.
  - Its remaining U5: `CommentsPanel.swift`, `CommentPanelHostWatcher`, `Shared/CommentDraftPark.swift`,
    `Registry/Capability.swift`, `CapabilityRegistry.swift` and `Queries/RestoreCost.swift`.
  - Already built there: `Core/Views/CaptureTextView.swift`; `CommandRouter.swift`; `Features/Takes/WriteTakesPanel.swift`,
    `TakesViewModel.swift` and `TakesStructureController.swift`; one line in `EditorView.swift`.
  - Stay out of those files. If the fix needs one of them, STOP and report.
- **VX-281's lane** is out.

**Evidence that closes U4.**
- **Pins**, red-first per member and red again by revert. For VX-230, the badge-geometry pin above. For VX-231, a
  count pin; if its trace finds no defect, record it as hollow.
- **The whole headless package green,** with counts.
- **THE STAGE WINDOW plan** in your record (claim `vx246-u4`; minutes; a batch-only fallback):
  - a Mac batch over every changed source file's suites;
  - a walk in BOTH voices on the dev store with a large note with many fanned blocks below the fold, and a book like
    hers (two takes on most blocks).
  - **What the walk shows:** the badges right at first open and first launch, with no dark disc and no badge on a
    single-take block; the book views as ruled; the Bookcase row's counts right after a big note joins a book.
  - **The fixture** is yours to build on the dev store. The trace decides whether a real MCP write is needed; if one
    is, `claude-code` connects by U1's documented detour (Deny → re-run → Approve).

**Context:** past ~500k, stop at the next clean seam (committed, green, the continuation written) and report.

**Out of scope:** every other unit's members; U1b; the guide (U8).

### U4c BRIEF — the inline editor's badge regression (VX-230)

- **The regression,** from U4b STAGE RUN's W2, reproduced alone: `InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport`
  fails at `:78` (badges `[]` where block 40's badge was expected) and at `:80`.
  - It was green in U3's and U4's W2, and turned red with U4b's `refreshBadges` change: no forced layout, only
    `.layoutAvailable` fragments badge, and the inline region is the whole post.
- **The runner's trace,** by reading and not yet verified:
  - Branching a take leaves the chosen take's text unchanged. So `reload()` takes the `.adoptEcho` arm (`slots = new`,
    then `refreshBadges()`) with no storage edit.
  - No remeasure follows, so U4b's re-run inside `remeasure` never fires on this road.
  - The read then finds block 40 unlaid. The remeasure's earlier whole walk had laid it out, so something in between
    un-laid it, most likely the display pass in `pump()`.
  - The deciding number is block 40's fragment state at `:76`.
- **What it means in use:** in the book view's inline editor, a fan made far off-screen with no text change (an MCP
  `add_take`, a sync arrival, a take branched from a panel) can stay unbadged until her next keystroke or a width
  change.
- **The constraint from U4b's re-trace — never reintroduce it:** a forced `.ensuresLayout` read from mid-document
  POISONS positions, measured up to 1,662 pt off. The settle net and the remeasure's whole walk give exact positions.
- **The work:**
  - Verify the trace with bare TK2 probes; U4b's are in `notes/plans/vx246-screens/u4b/probes/`, and they need no
    stage.
  - Then fix it so every road that changes which blocks are fanned WITHOUT a storage edit gets its badges at settled
    positions on the inline surface. Never use a forced mid-document read.
  - Leave Write unchanged unless the trace shows the same gap there, and say which.
- **Pins:** the regressed test IS the red-first pin; it was red on `vx246-u4b` in W2. If the in-use road isn't
  already covered, add a pin that makes a fan off-screen with no text change through the op the MCP road uses, red on
  `vx246-u4b`.
- **Lanes:** as U4b's. The one cleared `remeasure` call in `EditorView.swift` may be extended; vx-282's two touches
  stay out of bounds. Read `notes/TEXTKIT2_NOTES.md` first.
- **Evidence and THE STAGE WINDOW plan** (claim `vx246-u4c`; a short one):
  - **W1:** the new pin on `vx246-u4b`, red.
  - **W2:** the inline-editor and badge suites, `FanBadgePlacementTests` and the regressed suite on `vx246-u4c`,
    green.
  - **W3,** a short walk in both voices: in the book's Outline, a take branched on a block far off-screen, through
    her own door, wears its badge at its own line when scrolled to.
  - The headless package should be unchanged.
- **Context:** this is a small unit. Past ~500k, stop at a clean seam.

### U1b BRIEF — VX-258's face and U1's remainder (VX-258 · VX-318 · VX-260's option (b)), plus the carried live legs

VX-281 MERGED (PR #159, merge commit `0f5efe1c`; its ledgers on main at `3d42df78`; its handoff at `fa3bc6e1`), so its lane is main's now. Merge `origin/main` at `fa3bc6e1` or later.
- QUESTIONS is now at #219.
- AppSpec §12's MCP DOOR line gained "THE PANE AND THE SHARED ICON".

**THE MERGE GATE:** U1's core must not merge or reach her build without piece 1(a).

**vx-281's merge note (~04:15), what the face builds on:**
- **The pane:** the switch and status on top; Waiting and the connection requests ABOVE the tabs; the tabs are Connect ·
  Clients · Shared with AI · Activity.
- **The setup:** a code block (`MCPSetupMenu.swift`) with the client in its header and the copy ICON upper right. Its
  tooltip and VoiceOver name are "Copy setup command". The chosen client lives on `MCPDoor.setupClient` /
  `chooseSetupClient`.
- **`copySetupCommand(for:)` has NO default argument now,** and its receipt lands only while the menu still shows that
  client.
- **The summaries:** `clientBoundary` and `keyLine` render as one-line summaries (`MCPPaneCopy.clientBoundarySummary` /
  `keySummary`) via `Core/Views/ExplainerLine`.
- **The shared icon** marks the Library, Pool, Book Panel and ⌘L rows; the field guide still says Bookcase only (U8's).
- **New files:** `Domain/MCPGrantRule+Wing.swift` (the wing reach read-off) and `Core/Views/NearWindow.swift`.

**Piece 0: merge main in.**
- `git fetch origin && git merge origin/main` into this branch. It must be a MERGE COMMIT: never rebase, never
  force-push.
- Resolve every conflict keeping BOTH sides' meaning. Expected: `MCPDoor.swift`, where our U3 hook construction lines
  meet VX-281's `setupClient` / `chooseSetupClient(_:)` (VX-232) and its R1-3 change to `copySetupCommand(for:)`.
  Possibly tests that both sides touched.
- After the merge: the whole headless package green, with counts, and a Mac `build-for-testing`.
- Record each conflict and its resolution in your record.

**Piece 1: VX-258's FACE** (U1's OWED 1, read whole, plus vx-281's five facts under Cross-run coordination).
- **(a) The mint call site. NOT optional; it is the merge gate.**
  - `MCPSetupClient`, inside O-4's fence, gains each tab's expected `clientInfo.name`: Claude Code `claude-code`, Codex
    `codex-mcp-client` (an external lookup, said as such), Any MCP client `nil`.
  - `MCPDoor.copySetupCommand(for:)` passes it on: `mintMCPSetupKey(copiedFor: client.expectedName)`. Read the client
    from the door's `setupClient` (fact 3), as R1-3 left the function (fact 5).
  - `MCPSetupMenuTests`' key regex then reads `vmk2_<name>_…` for the two tabs and `vmk1_…` for Any: a justified
    edit.
- **(b) The re-bind row** in the Waiting section. Waiting sits ABOVE the tabs, beside the connection requests (fact 4).
  - It reads `Queries.mcpRebindRequests`, and the door's store observation must include `mcp_rebind_request`.
  - Allow → `allowMCPRebind(id)`; Don't allow → `declineMCPRebind(id)`. Both throw `mcpRebindRequestNotFound` for a
    gone ask, which is said where she pressed.
  - Add the pending marks and counts if the face counts asks.
- **(c) The words:** Activity words for `connect_rebind_waiting` / `_allowed` / `_declined`, and the pane's refusal
  words for `mcpRebindRequestNotFound`.
- **(d) The truth of L1 (`clientBoundary`) and `keyLine`,** each with its one-line SUMMARY (fact 1, `ExplainerLine`):
  a client's own setup re-run moves its name, and an Any-client setup waits for her OK. U8 re-voices the guide.
- Every word ships as built and goes on the FOR VX-234 list. Her ruled rule (P-VX258-2's bind arm, RATIFIED) holds.

**Piece 2: VX-318** (U1's OWED 3).
- `MCPSocketTransport`'s reader thread may outlive `session.run()`. A reader descheduled between two `read`s could
  read another socket's bytes after the host closes the descriptor and its number is reused.
- The fix shape: the session's close waits, bounded, for its transport's reader to exit.
- Pin red-first; a deterministic test seam is fine.

**Piece 3: P-VX260-1, rebuilt as option (b)** (THE ORCHESTRATOR ON U1's HAND-BACK).
- Add a local-only digest of the comment's words to `mcp_comment_author`, compared at delete. Any change to the words,
  from any device or client, makes deleting need EDIT.
- It gets its own schema commit on the grants family's road: no `sync_version`, no trigger, stripped by the export,
  marker 13 untouched. Read `notes/SyncSpec.md` in full first.
- Argue backfill against NULL-means-legacy.
- Pin red-first: a change to the text with no door (a synced edit's shape), then the suggest delete hears her
  R-VX188-2 sentence.

**Piece 4: THE STAGE WINDOW plan** (claim `vx246-u1b`; minutes; a batch-only fallback).
- **The Mac batch:** every changed source file's suites. That includes every MCP pane suite on the merged tree,
  `MCPSetupMenuTests`, and the suites the merge touched. Re-run U1's G1–G3 on the merged tree.
- **The live round on the DEV store.**
  - **U1's legs:**
    - leg 0: Claude Code 2.1.299's real `clientInfo.name`;
    - leg 1: a Claude Code TAB key re-binds `claude-code` with zero clicks;
    - leg 2: an Any-client key under `claude-code` WAITS with no reach; the Waiting row, her Allow (tools arrive
      without a reconnect) and her Don't allow, captured in BOTH voices;
    - leg 3: the rename to a hidden book's name lands without echo;
    - leg 4: a suggest delete of a comment she edited hears her sentence, plus option (b)'s doorless edit;
    - leg 5: Codex, which is not installed, so record it N/A.
  - **U2's W2 and W3:** the MCP value, toggle and revive directions with quiet presses. Redo is a DISABLED item on an
    empty redo stack, so expect no toast.
  - **Ruling 2's real-client check:** while her caret types in pane 1, a client's `delete_note` takes down the note in
    pane 2. Pane 2 goes to the Library and the focus stays in pane 1, captured.
  - **The setup line the pane copies** runs `claude mcp remove -s user …; claude mcp add -s user …`. NEVER run it as
    copied: take only the key, and register it `-s local` in a scratch project (U3 STAGE RUN's handling). Her
    user-scope servers are fingerprinted before and after and must stay SAME. Scratch keys are deleted and the clipboard
    emptied.

**Context:** this unit is big. If you pass ~450k by the time the plan is written, say so: a fresh runner takes the
window. Past ~500k mid-piece, stop at the next clean seam (committed, green, the continuation written) and report.

**Out of scope:** U5–U8's members; the guide (U8).

### U4b BRIEF — the inline editor's badges, and ruling 2 (VX-230's remainder · ruling 2)

1. **VX-230's remainder: the book view's inline editor.** Read U4 STAGE RUN whole.
   - **After a width change,** badges below the first screen stay at the old layout's offsets. W2's
     `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` reproduces alone on the fixed product: 51 of 80 badges
     misplaced, 7 pt growing to 657 pt down the post.
   - **Right after the inline editor mounts,** fanned blocks can be unbadged, with only block 1 wearing one. This was
     seen live in both voices: the Book spread's live left page, and Outline in Terminal.
   - **The runner's trace** (by reading, in the record): on the inline surface the badge pass reads with
     `.ensuresLayout`, but it runs BEFORE the remeasure that grows the text view. Its visible region is
     `textView.bounds`, so fans below the old height get no badge, the frames it reads aren't the settled layout's,
     and nothing re-runs the pass after the remeasure.
   - **The cure U4 set aside:** re-run the badge pass after `InlineEditorSurface.Coordinator.remeasure`
     (`EditorView.swift`). **That ONE call is cleared** (vx-282 notified, 2026-10-14 ~03:50). Stay out of vx-282's
     two `EditorView.swift` touches: the selection-change delegate (VX-296) and VX-154's line.
   - **Trace it yourself first,** confirm or correct the trace, then fix red-first. Read U4's UNIT RECORD for the
     measured TK2 facts.
2. **The pins U4's window exposed.**
   - **Two pins are hollow as written:** `aBadgeNeverSitsAtAnotherBlocksPlace` and `aWidthChangeInWriteKeepsEachBadgeHome`
     were GREEN on the red product, because TK2 estimates their deep fans in the harness and never reports `.zero`.
     Re-design each to be red on old, forcing the unlaid state deterministically, or record it hollow and remove it.
     Say which.
   - **One pin is defective:** the characterization `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects`
     fails on BOTH trees at `:397`, because the test host lays the deep fragment out after `layoutViewport()`. Make it
     state what the host actually does, or remove it, and say so in the record.
3. **Ruling 2** (ORCHESTRATOR'S PROVISIONAL RULINGS): a navigate-away never takes her focus.
   - `WorkspaceModel.notesDeleted`'s `select(.library, in:)` sets `focusedPane = pane`. A pane showing a dead note
     must go to the Library IN PLACE, with the focused pane staying focused.
   - Pin it red-first on the Mac: two panes, focus in pane 1, pane 2's note dies.
   - It moved here from U5's piece 0, so the two small app-side fixes share one window.

**THE EDITOR SEAM.** Read `notes/TEXTKIT2_NOTES.md` first. Decorations stay off the live storage, and no TK1 API.
The Fable review covers this at the run's end.

**Lanes.** Stay out of vx-282's listed files and functions, except the ONE cleared `remeasure` call. VX-281's lane is
out. `WorkspaceModel` is VX-283's road (VX-123 carries a comment about it); no running session lists it.

**Evidence that closes U4b, and with it VX-230.**
- **Pins**, red-first and red again by revert, on a red product.
- **The headless package green,** with counts; these are app-side fixes, so it should be unchanged.
- **THE STAGE WINDOW plan** (claim `vx246-u4b`; minutes; a batch-only fallback):
  - **W1:** the new and re-designed pins on the red product.
  - **W2:** a Mac batch over every changed source file's suites: the inline editor, the book views, and the workspace
    and note-deletion suites.
  - **W3, a short walk in BOTH voices:** the book's Outline and the Book spread, after a width change and right after
    mount, with every fanned block badged at its own line. Plus ruling 2's in-app check: her own Delete door, used
    from pane 1, deletes the note open in pane 2; pane 2 goes to the Library and the focus stays in pane 1.
  - The fixture goes through her File ▸ Import… door, as U4's window did; its fixture generator is in
    `notes/plans/vx246-screens/u4/`.
  - The real-client version of ruling 2's check rides U5's window.

**Context:** past ~500k, stop at the next clean seam and report.

**Out of scope:** every other unit; U5's members.

### U5 BRIEF — the write tools' shapes (VX-267 · VX-253 · VX-252 · VX-255)

**Order:** VX-267 first (VX-253's matcher needs its form), then VX-253, VX-252 and VX-255. Every member is ruled;
its ticket is the record, quoted here.

1. **VX-267: AI take labels drop "suggested".**
   - **HER RULING, verbatim:** *"why do we need claude-code \* suggested \* english. isn't it obvious it's suggested if
     it's claude? seems like an extra word."*
   - Since her label-split ruling (VX-197), the client prefix appears only on takes an AI adds at SUGGEST, inside
     her writing, so the name already says it was proposed.
   - `aiLabel` (13n's P-13n-3 convention, hers to re-voice) becomes `<client>` or `<client> · <label>`.
   - Existing takes keep their labels: labels are text, so no migration. VX-253's matcher accepts both forms.
     `aiLabel`'s tests are re-pinned.
   - **Truth:** any tool description or instructions line that states the OLD form is now false; correct it in this
     unit (doc-truth). U8 re-voices the docs later.
   - Pre-launch: settle the convention before public users create takes in the old form.
2. **VX-253: `save_lens` by take label.** RULED, her word: *"I like your 253 recommendation"*, with her
   clarification built in:
   - **Three explicit fills, never a magic word:** `picks`, `label`, or `pin_chosen: true`. `picks` ride on either
     rule as per-block overrides, applied FIRST, so a block a pick covers is never ambiguous.
   - **A block with no take of that label** shows its chosen take and is listed in `unmatched_blocks`.
   - **An AMBIGUOUS block** (two takes of that label) that no pick covers refuses the whole call, naming those
     blocks. The retry passes the same rule plus `picks` for exactly those blocks, or the first call does when the
     agent already knows.
   - **Labels match exactly as stored,** plus one convenience: a client's OWN suggestions match by their own part.
     Per VX-267 the stored form is `<client> · <label>`, and the legacy `<client> · suggested · <label>` matches too.
     Never another client's. Her "english" plus the AI's suggested "english" on one block counts as two matches, so
     the call refuses.
   - `save_lens` stays at SUGGEST. Its cost is proportional to the note's blocks: the lens names one take per block.
3. **VX-252: `create_note` returns take ids, and accepts `section_id`.**
   - Per block, it answers the shown take's id plus each extra take's id and label, in order. This matches
     `add_take`, which already returns `take_id`.
   - An optional `section_id` files the note in a chapter in the same call. Argue its rung and its refusals: the
     chapter must belong to the book the note joins.
   - Check `import_document`'s answer for the same gap, and close it the same way if it is real.
4. **VX-255: `insert_blocks` into an existing note.**
   - **RULED, her word:** *"VX-255: agreed, write new lets them add blocks at the end, edit lets them write blocks
     anywhere. I think that's a fair line to draw."*
   - The shape is `insert_blocks(note_id, after_block_id?, blocks)`, using `create_note`'s block shape.
   - At WRITE NEW it appends at the note's END only. Inserting after a specific block needs EDIT, the line the
     catalog already draws for every placing act.
   - It runs as ONE transaction with ONE client-named undo, on §9 newBlock's road. The entry follows U2's undo rule:
     each half answers whether it changed anything.
   - It answers `flushesHerEditorFirst` (U3's exhaustive switch), argued in the record.
   - Pre-launch: it closes an R-VX184-1 parity gap ("as capable as her at the keyboard").

**Lanes and words.**
- Tool descriptions live in `Sources/VariorumMCP` (ours). If a new act's Activity words or a pane refusal's words
  live in VX-281's lane (`MCPPaneCopy.swift` and the like), don't edit them: record the words as OWED for U1b, after
  VX-281's merge. A sentence that falls back to a tool id meanwhile goes on that list.
- **Wording ships as built** and goes on the FOR VX-234 list.

**Evidence that closes U5.**
- **Pins**, red-first per member and red again by revert. A pure addition (a new parameter or tool) is red by its
  absence on the old tree.
- **The whole headless package green,** with counts.
- **THE STAGE WINDOW plan** in your record (claim `vx246-u5`; minutes; a batch-only fallback):
  - a Mac batch over every changed source file's suites;
  - a REAL-client live round on the dev store: `claude -p` turns that use each new shape;
  - the round's acts: `create_note` answering ids and filing into a chapter; `save_lens` by label meeting an
    ambiguous block, then its `picks` retry; `insert_blocks` at the end at WRITE NEW, refused mid-note at WRITE NEW,
    then anywhere at EDIT; and the new label form seen in Takes, captured.
  - `claude-code` connects by U1's documented detour (Deny → re-run → Approve), registered `-s local` in a scratch
    project only; her user-scope servers are fingerprinted before and after.

**Context:** past ~500k, stop at the next clean seam (committed, green, the continuation written) and report.

**Out of scope:** every other unit's members; U1b; the guide and `MCPSession.instructions` beyond doc-truth (U8).

**~~PIECE 0, before the members: ruling 2's fix~~** *[moved to U4b, 2026-10-14 ~03:50; what stays for U5 is the
real-client check in its live round, the last bullet below]* (ORCHESTRATOR'S PROVISIONAL RULINGS, ruling 2: a
navigate-away never takes her focus).
- **The defect:** `WorkspaceModel.notesDeleted` sends each pane showing a dead note to the Library through
  `select(.library, in:)`, and `select` sets `focusedPane = pane` (`WorkspaceModel.swift`, about line 186).
- **The fix:** a pane showing a dead note goes to the Library IN PLACE, and the focused pane stays focused.
- **Pin:** red-first, a Mac pin with two panes, focus in pane 1, and pane 2's note dying; its red run is part of your
  window. Search the Mac tests for `WorkspaceModel`, `notesDeleted` and the navigate-away suites, and add every suite
  that reaches it to your batch.
- **Proof:** in your live round, while her caret types in pane 1, a real client's `delete_note` takes down the note
  in pane 2. Pane 2 goes to the Library and her caret stays in pane 1, captured in both voices.
- **Lanes:** this is VX-283's road (VX-123), and VX-123 carries a comment about it. Neither vx-281 nor vx-282 lists
  `WorkspaceModel`.

## UNIT RECORDS

*(each written by its implementer from its first commit, under its own heading below)*

## U1 UNIT RECORD — the door's security and correctness: VX-258 · VX-259 · VX-260 · VX-279 · VX-280 (opus-implementer, from 2026-10-13 ~21:30 MDT)

**What this unit did NOT do (said first — the state at the STOP, 2026-10-13 ~23:10 MDT):** (1) **VX-258's FACE is not built** — the brief's STOP before `App/Variorum/Variorum/Features/MCP/` (VX-281's lane): no Waiting row, no Allow / Don't allow buttons, no Activity words for the three new acts, and — the merge gate — **the app still mints UNTAGGED keys** (the one-line mint call site and the setup menu's names are in that folder), so on this build a re-run Claude Code setup under an approved `claude-code` WAITS for an OK no pane can give (OWED 1); (2) **no stage window has run** — no Mac test batch, no live round, no walk (THE STAGE WINDOW, two windows planned); the Codex name is an external lookup, never seen live (Codex is not installed); (3) the guide and `MCPSession.instructions` untouched (U8), no `notes/QUESTIONS.md` entry or canon edit (the merge's); (4) the VX-279 neighbour found on the way (the transport's reader thread) is traced, not fixed (OWED 3). Everything else in U1 is built, pinned red-first and red again by revert, and green headless (the finals below).
This commit is the record, the LIVE STATUS and the traces, written before any code. Everything below the traces is
the plan, not a claim.

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (AppSpec §12's THE MCP DOOR line);
this run record whole (the U1 BRIEF, the hard rules); the plan `notes/plans/mcp-pane-and-docs-kickoff.md` whole; the
runway `notes/plans/vx-33-release-runway.md` §2 and §3 (VX-246); VX-184's record — its U1 UNIT RECORD whole (VX-198's
re-bind design, the live-round form) and THE LADDER whole (round 1's MAJOR and MINORs, her three rulings, both fix
passes, round 2's host finding and P1 notes); `notes/SessionResiliencyProtocol.md` whole; the five tickets (VX-258,
VX-259, VX-260, VX-279, VX-280 — no comments on any). Code read: `MCPServerHost`, `MCPSession`, `MCPHandshake` (the
refusals), `MCPPreamble`, `Domain/MCPSetupKeyRule`, `Operations+MCPSetupKeys`, `Operations+MCPGrants` (contact,
approve, Deny, the adoption release), `Queries` (the setup-key reads), `MCPGrantSchema` + the v1_24/26/27 migrations,
`MCPGrantAuthority` + `MCPRefusalCopy`, `MCPReadTools.listBooks`, `MCPWriteTools` (`picks`, `perform`'s `saveLens` and
`createBook` arms), `MCPWriteTools+Batches` (`placedBlocksSQL`, the P1 precedent) + `MCPPreCheckPlanTests`,
`MCPWriteTools+LibraryEdits` (`onBook`, `guardBooks`, `rename_book`), `Operations+MCPLibraryEdits.renameBookForClient`,
`Operations+MCPWrites.createBook`, `Operations+Reading.requireBookNameFree`, `Operations+Comments` (her comment doors),
`Operations+MCPCommentAuthors`, `MCPWriteTools+CommentDelete`, `Operations+MCPWrites.addComment` and its undo halves,
`Operations+MCPBatches.addComments`; the app's `MCPDoor.copySetupCommand` and `MCPPaneCopy`'s `MCPSetupClient` and
Activity words (READ ONLY — VX-281's lane and the brief's STOP); the setup-key test suites (core, socket, the Mac's
`MCPSetupKeyFacesTests`, `MCPSetupMenuTests`, `TutorialMCPChapterTests`' rule pin) and `MCPProviderNeutralityTests`
(O-4's sweep of every string literal under `Sources/`).

**Surfaces (planned):** `Sources/VariorumMCP/{MCPServerHost,MCPSession,MCPWriteTools,MCPWriteTools+LibraryEdits}.swift`
· `Sources/VariorumCore/{Domain/MCPSetupKeyRule,Operations/Operations+MCPSetupKeys,Operations/Operations+MCPGrants,
Operations/Operations+MCPLibraryEdits,Operations/Operations+MCPWrites,Operations/Operations+Reading,
Operations/Operations+Comments,Queries/MCPGrantQueries,Persistence/MCPGrantSchema,Persistence/Migrations}.swift` ·
tests. ZERO `Sync/`, custody/Keychain, editor seam, `Server/`. ONE local-only schema change (VX-258's waiting re-binds,
v1_28 on the grants family's road) — its own commit, SyncSpec read in full first. ZERO edits under
`App/Variorum/Variorum/Features/MCP/` (the brief's STOP) — VX-258's face, its Activity words and the one-line mint call
site are OWED below.

### LIVE STATUS — U1's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the traces and the designs (before code); `notes/plans/vx246-screens/` gitignored (`git check-ignore` verified) | DONE (this commit) |
| 1 | VX-279 — the seam (the session closes its own connection; behaviour-identical), the pin `hangUpAfterCloseLeavesAReusedDescriptorAlone` (the round-2 probe `hangUpAfterCloseShutsDownAReusedDescriptor`), RED on the seam tree | DONE (this commit) — `MCPSession.closeConnection()` = the host's bare `close(fd)`, moved (no flag); `MCPServerHost.serve` calls it in the same place. NEW `Tests/VariorumMCPTests/MCPServerHostReuseTests.swift`. **RED on the seam tree: 1 test, 3 issues** — the fresh socket took the peer's 6 bytes (the first expectation held) and then read 0, wrote nothing, and its peer read nothing: the stale `hangUp()` shut the reused number down (round 2's "wrote 6 bytes, read 0", reproduced). Log `notes/plans/vx246-screens/u1/logs/p1-pin-seam-red.log` (gitignored) |
| 2 | VX-279 — the fix (deregister under the host lock before the close; one per-session lock over closed/close/shutdown), GREEN; red again by revert; the whole MCP target repeated under concurrent load, pre-fix and post-fix | DONE (`a7c0b200` the fix; this commit the revert proof and the load runs) — **the fix:** `MCPSession` — `connectionLock` + `connectionClosed`: `closeConnection()` closes once and marks it, `hangUp()` is a no-op once closed; `MCPServerHost` — `ended` deregisters under the host lock, THEN closes (the Task calls `ended`, or closes alone when the host is gone). **The pin GREEN** (1/1, 0.030 s; log `p2-pin-green.log`). **The production road, measured through the REAL host** (a temporary probe, never committed — `Tests/VariorumMCPTests/ZZProbeHostStopReuse.swift`, untracked, deleted at this piece's close): each round a real `MCPServerHost` with 12 keyed sessions, their clients closing, then a sweep of 0–5.85 ms, then `stop()`, while a churner thread opens socketpairs in the same process; after the stop every churned socket must still carry a byte. **Pre-fix (the seam tree): 4 victims in 1,000 rounds** (3/200 · 0/400 · 1/400; ~366k churned sockets) — the stale hang-up caught in the act on the production road; **fixed: 0 victims in 1,200 rounds** (0/400 ×3; ~442k churned). Logs `p2-probe-prefix*.log`, `p2-probe-fixed-*.log`. **The whole MCP target under load, PRE-FIX** (the seam tree, the new pin skipped; `scratchpad/u1/loadruns.sh` — `swift test --skip-build --filter VariorumMCPTests` with N `yes` hogs on 12 cores): 8 hogs **0/14 failed**; 24 hogs **1/21 failed** — `connectionsPastTheCapAreRefusedWithOneHonestErrorAndSlotsFree`, "Unable to parse empty data" (round 2's exact signature; `load-prefix24a/run-2.log`). **RED AGAIN BY REVERT** (announced in `a7c0b200`, run on that committed tree): the two production files back to the seam commit `fdb4dab0` → the pin **RED, 1 test, 3 issues** (identical to piece 1) and the probe **3 victims in 400 rounds**; **RESTORED** (`git checkout HEAD -- <the two>`, `git diff HEAD` empty) → the pin green again (logs `p2-revert-red.log`, `p2-revert-probe.log`, `p2-restored.log`). **The whole MCP target under the same 24-hog load, FIXED: 0 failed in 21 runs, 213 tests / 42 suites each** (the new pin included; the probe skipped; `load-fixed24{a,b,c}/summary.txt`). Said plainly: under my load the pre-fix whole-target rate was low (1 in 21; round 2 saw 4 in 14 under its own load), so 21 clean runs alone are weak evidence (≈ 0.37 chance of 21 clean runs at a 1-in-21 rate); the mechanism's end is proven by the pin (deterministic, red/green/red) and by the real-host probe (4 in 1,000 → 0 in 1,200 → 3 in 400 on the revert). The probe file was DELETED (never committed) |
| 3 | VX-280 — `picks`' statement named (`picksSQL`, behaviour-identical), the plan pin, RED | DONE (this commit) — `MCPWriteTools.picksSQL` = the inline statement, byte-identical, read by `picks`. NEW `Tests/VariorumMCPTests/MCPPicksPlanTests.swift`. **RED: 1 test, 3 issues** — the pre-fix plan, read from the package's own SQLite: `SEARCH cb USING INDEX idx_cblock_order (container_id=?)` → `SEARCH v USING INDEX idx_variant_block (block_id=?)` → `SCAN j VIRTUAL TABLE INDEX 1:` — every placement of the note, then every take of each block, then the given ids scanned for each: worse than the ticket said (∝ the note's blocks × their takes × the ids). Log `p3-pin-red.log` |
| 4 | VX-280 — the fix (`json_each` drives through `CROSS JOIN`s, `uq_cblock_ownership` sought), GREEN, the lens suites unmodified as the parity proof; red again by revert | DONE (`14d7a876` the fix; this commit the revert proof) — **the fix:** `picksSQL`'s two JOINs → `CROSS JOIN` (the doc says why); the plan now reads `SCAN j VIRTUAL TABLE INDEX 1:` → `SEARCH v USING INDEX sqlite_autoindex_variant_1 (id=?)` → `SEARCH cb USING INDEX uq_cblock_ownership (block_id=?)` (printed once by a temporary line, never committed). **The pin GREEN** (1/1). **Parity:** no suite pinned `picks`' refusals, so NEW `MCPPicksParityServerTests.everyPicksRoadAnswersAsBefore` (same file) pins every road on the wire — a take of another note, a deleted take, an id naming nothing (each "take_id … isn't a take of this note."), two takes of one block (its sentence), and a valid pick landing block by block; plus the lens/write/show/catalog suites UNMODIFIED (`MCPLensDoorsServerTests`, `MCPWriteServerTests`, `MCPServerTests`, `MCPShowServerTests`, `MCPPreCheckPlanTests`) — **40 tests / 7 suites green** (`p4-parity.log`); the two VX-280 suites 2/2 (`p4-parity-fixed.log`). **RED AGAIN BY REVERT** (announced in `14d7a876`, run on that committed tree): `MCPWriteTools.swift` back to `4590f02d` → the plan pin **RED, 3 issues** (identical to piece 3) while the parity pin stayed **GREEN** — the two statements answer every road alike, which is the parity claim made executable (`p4-revert.log`); **RESTORED** (`git checkout HEAD --`, `git status` clean) → 2/2 green (`p4-restored.log`) |
| 5 | VX-259 — the server pins (a Private book, another wing's book; `rename_book` and `create_book`), RED | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPBookNameReachServerTests.swift` (two tests: `rename_book` toward a Private book's and another wing's name, with a readable collider as the control; `create_book` beside the same two, the same control). **RED: 2 tests, 8 issues** — the rename refused "duplicateBookName(name: \"secret\")" (the hidden book's exact stored name, echoed — the oracle, in the harness's refusal words; the app's are `BookNameCopy`'s "A book named “secret” already exists…") and the test stopped there (3 issues: the refusal, the echo, the answer not JSON); `create_book` refused both hidden names the same way (5 issues incl. the resulting name list). Log `p5-pins-red.log` |
| 6 | VX-259 — the fix (the wire's name check counts only books the client can read; her doors keep the full guard), GREEN; red again by revert | DONE (`ce4ceb3b` the fix; this commit the revert proof) — **the fix:** core — `Operations.BookNameReach` (a predicate asked, in the act's transaction, of each COLLIDING live reading) and `requireBookNameFree(…, counting:)` (nil = every reading — her doors, `importBook` and `assertBookNameIsFree` untouched); `renameBookForClient` and `createBook(named:inWing:)` gain `namesCountedBy:` (default nil). Wire — `MCPWriteTools.readableBooks(clientName)`: a reading counts only while THIS client can READ it now — `MCPGrantAuthority.decide(standing, reading: readPlace(db, id))`, the one rule `list_books` reads (a fenced book never; a gathering under its wing's reach), non-consuming; `rename_book` and `create_book` pass it. **Pins GREEN:** `MCPBookNameReachServerTests` 2/2; NEW core `MCPBookNameReachTests` (the op's contract: a non-counting collider passed by and asked alone; nil counts every reading; a counting collider refuses, naming it) 1/1. **Two JUSTIFIED EDITS (the ritual, each commented in place):** `MCPBookStateServerTests.renameBookIsHerRename…` and `MCPLibraryOnceServerTests.aRefusedActSpendsNothing` used an UNREACHABLE book ("letters", "taken") as their E13 collider — exactly the oracle VX-259 closes; each now grants the client READ on that book, so E13 still refuses there (the readable-collider road), every other expectation unchanged. **Runs:** the four book/write/once suites 20/4 green (`p6-green.log`); the whole MCP target **217/45 green** (`p6-mcp-target.log`); core `MCPLibraryEditActsTests`/`MCPWriteActsTests`/`MCPUndoDivergenceTests` 44/6 green (unmodified — they pass no predicate). **RED AGAIN BY REVERT** (announced in `ce4ceb3b`, run on that committed tree): the wire's two files back to `ecced999` → the server pins **RED, 2 tests, 8 issues** — identical to piece 5 (the core contract pin green, as it must be: the core is not reverted) (`p6-revert.log`); **RESTORED** (`git checkout HEAD --`, `git status` clean) → green (`p6-restored.log`) |
| 7 | VX-260 — the pins (core: her edit clears the record; socket: a suggest delete after her edit hears her sentence), RED | DONE (this commit) — NEW socket `Tests/VariorumMCPTests/MCPCommentHersServerTests.swift` (`aSuggestClientCannotDeleteACommentSheEdited`: a suggest client's two comments; she rewrites one; its `delete_comment` must answer her R-VX188-2 sentence byte-exact and leave it live; the untouched one still deletes) and NEW core `Tests/VariorumCoreTests/MCPCommentHersTests.swift` (`herEditClearsTheRecordAndANoOpEditDoesNot`; `aClientsEditAndARefusedEditOfHersKeepTheRecord` — a client's `editCommentForClient` and her refused blank edit leave the record, green on both sides BY DESIGN: they pin what the fix must not do). Pre-fix API only. **RED:** socket **1 test, 2 issues** (the delete LANDED on the comment she rewrote — no refusal, the comment gone); core **1 of 2 tests, 1 issue** (her edit left the record naming the client). Log `p7-pins-red.log` |
| 8 | VX-260 — the fix, GREEN; red again by revert | DONE (`8a8a99aa` the fix; this commit the revert proof) — **the fix:** `editBlockComment` (her comment door — the Mac's Comments panel and the phone alike) forgets the comment's authorship record (`Operations.forgetMCPCommentAuthor`, a DELETE on `mcp_comment_author`) in its own transaction, ONLY when `rewriteComment` wrote (a no-op edit returns nil, a refused one throws before); the docs that said the record is never touched again (`Operations+MCPCommentAuthors`' header, `Queries.mcpCommentAuthor`, `MCPWriteTools+CommentDelete`, `MCPGrantSchema`'s family note) now say so. **GREEN:** the two VX-260 suites 3/3; the MCP comment suites (`MCPCommentAuthorshipServerTests`, `MCPCommentEditServerTests`, …) **11/4** and the core comment suites **58/18** green unmodified (`p8-green.log`). **RED AGAIN BY REVERT** (announced in `8a8a99aa`, run on that committed tree): `Operations+Comments.swift` back to `4a736d81` → socket **1 test, 2 issues** and core **1 issue**, identical to piece 7 (the keep-the-record pin green, by design) (`p8-revert.log`); **RESTORED** (`git checkout HEAD --`, `git status` clean) → 3/3 green (`p8-restored.log`) |
| 9 | VX-258 — the red pins on the PRE-FIX API (the VX-168 impostor restored: a fresh MINT under a bound, approved name takes nothing; the same for a known approved UNBOUND name), RED | DONE (this commit) — NEW core `Tests/VariorumCoreTests/MCPSetupKeyTabTests.swift` (suite `MCPSetupKeyImpostorTests`: `aFreshMintUnderABoundApprovedNameTakesNothing` — VX-168's impostor restored to its ORIGINAL threat, a fresh MINT; `aFreshMintUnderAnApprovedUnboundNameTakesNothing` — the bind arm) and NEW socket `Tests/VariorumMCPTests/MCPSetupKeyImpostorServerTests.swift` (`theImpostorConnectsReachingNothingAndTheRealKeyKeepsConnecting`: no tools, `read_note` refused without her words, the answer byte-identical to a first-contact request's, the real session served, the real key still admitted). Pre-fix API only. **RED:** core **2 tests, 5 issues** (the impostor RE-BOUND the name — the bound hash moved, the row's version rewritten to the impostor's "9.9", the real key then refused; the unbound arm BOUND the name to the impostor's key, the version rewritten); socket **1 test, 4 issues** (the impostor listed the read tools, read her note's words, answered unlike a request, and the real key was turned away). Log `p9-pins-red.log` |
| 10 | VX-258 — SyncSpec read in full; the schema commit (v1_28, the waiting re-binds — local-only, the grants family's road) with its schema pins | DONE (this commit — the schema ALONE, ahead of the code that uses it) — **`notes/SyncSpec.md` read in full BEFORE this commit** (125 lines: §3's local-only machinery, §6/§7, §12's lockstep rule and its running record through 13n-b's marker 13 — a local-only family table is none of it: no `sync_version`, no outbox trigger, no mirror, the marker untouched). `v1_28_mcp_rebind_requests` → `mcp_rebind_request (id, client_id → mcp_client(id), key_hash, version, asked_at)` + `uq_mcp_rebind_request_client` (one waiting setup per client) + `uq_mcp_rebind_request_key` (one row per key); `MCPGrantSchema.tables` and `childFirstOrder` (before `mcp_client`) gain it; the family note says what it holds. **Pins:** NEW `MCPGrantSchemaTests.theWaitingRebindIsRegisteredLocalOnlyLikeTheGrantsFamily` (registered, outside the sync registry, no `sync_version`, no trigger, never the outbox, marker 13, the two uniques and the FK held) + `aStoreBeforeTheWaitGainsItEmptyAndKeepsItsRows`; JUSTIFIED EDITS (the ritual, commented): the family seed carries one waiting row (the export pin counts a row per table), the trigger-free list, `MigrationTests`' expected tables and indexes and the v1_16→latest index delta. **Run:** `MCPGrantSchemaTests` + `MigrationTests` + `SyncSchemaTests` + the export suites **56/7 green** (the completeness walk subtracts the family by name; the plaintext export strips it EMPTY) (`p10-schema.log`) |
| 11 | VX-258 — the core: the tab tag in the key, `decide`'s arms, the waiting re-bind (admitted with no reach until she allows), the ops her answer calls (allow / don't allow), Deny and the adoption tidy; the state-transition pins and the justified edits; GREEN | DONE (`c9edeefd`) — **`Domain/MCPSetupKeyRule`:** `copiedForPrefix` `vmk2_`, `canCarry` (1–64 of `A–Z a–z 0–9 . _ -`), `key(fromRandomBytes:copiedFor:)`, `copiedFor(_:)` (read from the right; nil for untagged or malformed); `Client.approved` (default TRUE — the fail-safe reading); `KeyStanding.awaiting(clientID:)`; `Decision.awaitRebind` (admits — to a request's face); `decide(…, copiedFor:, …)` per the design's table; acts `connect_rebind_waiting` / `connect_rebind_allowed` / `connect_rebind_declined`, `replacingActs`. **`Queries`:** the standing reads `awaiting` after a binding and before the unclaimed set; the replaced memory reads her Allow's rows too; NEW `mcpRebindRequests` → `MCPRebindRequest` (id, client, name, declared version, when — never the hash). **`Operations`:** `mintMCPSetupKey(copiedFor:)` (a name it cannot carry refuses, nothing kept); `admitMCPConnection`'s `awaitRebind` arm (claims the key into ONE waiting row per client — a newer wait replaces the older — logged once as refused, the client row untouched; a re-presentation writes nothing); NEW `allowMCPRebind(id)` (binds/replaces, logs the replaced hash as the target, refuses a non-approved client) and `declineMCPRebind(id)` (forgets the key); `denyMCPClient` and `landMCPAfterAdoption` drop the waits; `OperationError.mcpRebindRequestNotFound`. **`MCPSession`:** an `awaitRebind` admission holds the key's hash; `clientName` (the host's) is nil while waiting (no while-connected lifetime, not "connected"); ListTools/CallTool short-circuit BEFORE any tool — no tools, the pending sentence, "Unknown tool" for an unknown name — until the bound key IS this key (checked per call, flips once); `announceToolsChanged` tells it the moment she allows. **`MCPServerHost`:** the grants fingerprint carries each decided client's binding (her Allow re-announces). **NEW PINS (new API — green, state transitions):** core `MCPSetupKeyTabRuleTests` (3 — the key's form, `canCarry`, every arm of the table) + `MCPSetupKeyWaitTests` (8 — the tab mint, the wait, a newer wait, Allow (bound and unbound), Don't allow, Deny/adoption, a tab key under another name); socket `MCPSetupKeyTabServerTests` (4 — a tab copy re-binds zero-click; an Any copy waits, her Allow serves it with NO reconnect (the list-changed notification heard) and the replaced key hears its sentence; Don't allow; a waiting connection never keeps the name's while-connected grant alive). **JUSTIFIED EDITS (the ritual, each commented):** the harness's `setupKey(for:)` mints a key copied FOR the name (a tab copy — every pre-VX-258 pin's own assumption); the pins that modelled her re-run of a client's own setup with an untagged mint now mint it from that client's tab — core `aBoundNameRebindsAFreshCopy` and `aKnownUnboundNameBindsAnUnclaimedKey` (each GAINING the untagged / another-tab / no-approval arms), `anApprovedUnboundNameBinds…`, `aBindIsLogged…`, `denyReleases…`, `anAdoptionReleases…`, `aFreshCopyRebindsABoundName…`; socket `twoToolsUnderOneNameAreToldApart`, `anApprovedUnboundNameBinds…`, `aSecondCopyRebinds…`; the Mac's `TutorialMCPChapterTests` rule pin (its `.rebind` line is the client's own setup; an Any-copy line added — compiled at the stage, U8 re-voices lesson 2). **GREEN:** the whole MCP target **223/48**; core MCP + migration + export **295/42** (`p11-green.log`); the piece-9 red pins all green. |
| 12 | VX-258 — red again by revert | DONE (this commit) — announced in `c9edeefd`, run on that committed tree: the seven production files AND the six test files that read the new API back to the schema commit `0b9f6fe3` (the schema kept), `MCPSetupKeyTabServerTests.swift` moved aside inside the worktree → piece 9's pre-fix-API pins **RED again: socket 1 test, 4 issues; core 2 tests, 5 issues (3 + 2) — identical to piece 9** (`p12-revert-red.log`). (A first attempt's `git checkout` failed on zsh's unsplit variable and reverted NOTHING — the moved test file alone; caught by `git status`, redone with an array — said so the log's earlier stale green is not read as a result.) **RESTORED:** `git checkout HEAD -- <the thirteen>`, the file moved back, `git status` clean, `git diff HEAD` empty → socket MCPSetupKey* **16/4**, core **36/6** green (`p12-restored.log`) |
| 13 | headless finals (the whole package) + the Mac `build-for-testing` | DONE (this commit) — **MCP 223/48 · core 2,800/324 · workbook 40/6**, EXIT 0, zero ✘, the standing skips only (`p13-finals.log`); the Mac `build-for-testing` **TEST BUILD SUCCEEDED** into `DerivedData/vx246-u1`, no warning in a touched file (`mac-build-for-testing.log`) — details under "The pins and the red counts" |
| 14 | STOP — VX-281's lane (VX-258's face, its Activity words, the mint call site); THE STAGE WINDOW plan; the report | **STOPPED + READY FOR STAGE (`acb94ac0`, 2026-10-13 ~23:10 MDT)** — the face OWED (OWED 1, incl. the merge gate); THE STAGE WINDOW written (window 1 now ~75 min, claim `vx246-u1`; window 2 after the face ~45 min); the stage NOT claimed (waits on the orchestrator's GO) |

**No revert is in flight** (the reverts of VX-279, VX-280, VX-259, VX-260 and VX-258 ran and were RESTORED — `git diff HEAD` empty).

### The traces (written before code)

**VX-279 — the host's fd reuse (inputs → wrong state).** `MCPServerHost.serve` (`MCPServerHost.swift:179–183`) runs
each session as `Task { await session.run(); close(fd); self?.ended(session) }`: the descriptor is CLOSED while the
session is still in `sessions` — `ended` removes it only after, under the host lock. `stop()` (`:104–126`) snapshots
`sessions.values` under the lock, wakes and waits (up to 2 s) for the accept thread, closes the listener and the wake
pipe, unlinks the socket, and only then calls `hangUp()` on every session in the snapshot — a bare
`shutdown(fd, SHUT_RDWR)` (`MCPSession.swift:210–212`) on the number the session was born with. A session whose `run()`
ended in that window (its client hung up; the server's stop itself; the over-cap close) has already freed its number;
POSIX hands the lowest free number to the next descriptor the PROCESS opens (any thread — another test's harness
client, the next session's `accept`, a store file), and the stale `hangUp()` then shuts THAT socket down: its reader
sees EOF ("Client disconnected"), its peer's next read is empty ("Unable to parse empty data"). In tests (Swift
Testing runs the MCP suites in parallel in ONE process, each with its own host) that is round 2's 4-in-14 load flake;
in production `MCPDoor.stopServer` (the switch off, a lock, quit) can shut down an unrelated in-process socket. The
mechanism needs no help from the session: `hangUp()` has no way to know its number was closed.
**The fix (the ticket's):** (1) the session owns its descriptor's end — `closeConnection()` and `hangUp()` share ONE
per-session lock and a `closed` flag: a close runs once, and a hang-up after it is a no-op (a hang-up before it shuts
down the session's OWN socket, which is the point of it); (2) the host deregisters the session under the host lock
BEFORE it closes the descriptor, so a stop that snapshots after the session ended never sees it. Either half alone
leaves a window ((1) is the one that closes it by construction; (2) keeps `connectedClientNames` and the
while-connected accounting off a dead session).
**The pin:** the round-2 reviewer's probe, rebuilt (its scratch clone is gone): a session over one end of a
socketpair; the session's connection closed by the host's road; a fresh socketpair opened until one end reuses the
number; then `hangUp()`; the fresh pair must still carry bytes both ways. **It needs a seam to compile on both sides:**
today the host closes with a raw `close(fd)` the session never sees, so a pin that closes "the way the host does" must
call a session method. Piece 1 adds `MCPSession.closeConnection()` with EXACTLY today's behaviour (a bare `close`, no
flag) and routes the host through it — a behaviour-identical refactor — and the pin is run RED on that tree. Piece 2's
fix changes only the method's body and the host's order; reverting piece 2 is the red-by-revert.

**VX-280 — `save_lens`'s picks check reads the whole note (P1).** `MCPWriteTools.picks(noteID:takeIDs:)`
(`MCPWriteTools.swift:638`) resolves the given take ids with `json_each(?) j JOIN variant v ON v.id = j.value …
JOIN container_block cb ON cb.block_id = v.block_id … WHERE cb.container_id = ?` — plain JOINs, so the planner is free
to drive from the note's placements (`idx_cblock_order (container_id=?)`) and probe the ids inside: cost ∝ the note's
blocks, not the ≤N ids given (round 2's fix pass measured exactly this shape on a replica and named it, NOT fixed).
**The fix:** the precedent `placedBlocksSQL` — the ids drive through `CROSS JOIN` (SQLite keeps a `CROSS JOIN`'s left
table outside its right), each id → its take by primary key → its block's ONE live placement through
`uq_cblock_ownership` (`block_id=?`, partial on `deleted_at IS NULL`). Both joins become `CROSS JOIN`, so no order but
`j → v → cb` is legal. Membership per id is unchanged (a live take of a block live-placed in this note), so every
refusal ("take_id … isn't a take of this note.", the two-takes-of-one-block sentence) is byte-identical. **The pin:**
the statement named `picksSQL` (piece 3, behaviour-identical) and pinned ON THE PLAN (`MCPPreCheckPlanTests`' form):
the plan starts `SCAN j`, seeks `uq_cblock_ownership`, never `idx_cblock_order`, never scans a table.

**VX-259 — the book-name oracle.** `rename_book` → `Operations.renameBookForClient` (`Operations+MCPLibraryEdits.swift:78`)
and `create_book` → `Operations.createBook(named:inWing:)` (`Operations+MCPWrites.swift:663`) both call
`requireBookNameFree(db, name)` (`Operations+Reading.swift:934`), which scans EVERY live, unarchived reading in every
wing — Private books, the daily Journal, gatherings, other wings — and throws `duplicateBookName(name: <the stored
name>)`; the wire words it through `hooks.refusalWords` (the app's `BookNameCopy.refusal(existing:)` — "A book named
“<exact stored name>” already exists…"). So a client with edit on ONE book learns that a book it cannot reach exists,
and its exact casing, by renaming toward the name — against F-7 and the advice's "Anything you can't reach answers
exactly as if it did not exist". **Her ruling:** an accidental duplicate is fine (no schema protection, ruled before);
the door's check compares only against books the client can READ; her own doors keep the full guard. **The fix:**
`requireBookNameFree` gains an optional COUNTS predicate (nil = every reading — her doors, unchanged); the two MCP ops
take it from the wire; the wire passes "a reading this client can READ now" — the one rule the listing already reads
(`MCPGrantAuthority.decide(standing, reading: readPlace(db, id))`: a book at read under its grants/the open book, a
gathering under `decideGathering`), asked only of the readings whose name COLLIDES (the scan stays a shelf-sized pass;
the rule runs on the colliders, normally none or one). A readable collider still refuses with its name (the client can
read it — no oracle). **The pins (socket road):** a Private book "secret"; an edit grant on another book;
`rename_book(other, "Secret")` LANDS and its answer names only the client's own "Secret" (never "secret", the hidden
casing); likewise a book of another wing; `create_book("Secret")` in a wing the client writes into lands beside the
hidden one; a READABLE collider still refuses (the control).

**VX-260 — her edit makes an AI's comment hers.** The suggest rung's `delete_comment` (`MCPWriteTools+CommentDelete`)
needs SUGGEST when `Queries.mcpCommentAuthor` names the caller and EDIT otherwise (`deleteRung`). The record
(`mcp_comment_author`, v1_27) is written when a client adds a comment and NEVER touched again: her comment edit
(`editBlockComment` → `rewriteComment`) leaves it, so a suggest client deletes a comment she has rewritten — the
lesson-3 promise "Suggest … can't change a word you wrote" broken (round 1's MINOR; recoverable by her restore).
**Her ruling** (her pick of round 1's option (b), "Your edit makes it yours" — the finding's text: "her edit of the
comment clears the record (a one-line hook in her edit path)"). **The road, argued:**
- **(a) her edit clears the record — CHOSEN** (the ruled option, literally): `editBlockComment` deletes the comment's
  `mcp_comment_author` row in the SAME transaction as the rewrite, and only when the text really changed
  (`rewriteComment` returns nil on a no-op, so a no-op edit writes nothing — the record stays). Exact: nothing else
  moves authorship — the client's own undo/redo of its add (`reapplyAddedComment` bumps `updated_at`), her delete and
  restore (both bump `updated_at`), a client's `edit_comment` (`rewriteComment` through `editCommentForClient`, whose
  header says the record is untouched) — none is her edit, and none changes who wrote it.
- (b) the delete compares the comment's `updated_at` with the record's `recorded_at` — REJECTED: every write bumps
  `updated_at`, so the client's own add-undo-redo (`reapplyAddedComment`, the brief's "revive stamp"), her delete +
  restore, a sync apply, would each make the comment "not its own" though nobody edited a word; making those not count
  needs the revive roads to rewrite the record — the record then becomes a mutable mirror of the comment, which it was
  ruled not to be ("a fact about authorship").
- (c) a text digest on the record (a local-only column) — the comment is the client's while its words are still the
  ones it wrote: catches HER EDIT ON ANOTHER DEVICE too (a)'s gap, below — but it is a schema change beyond the ruled
  option and treats any client's later edit as hers. Logged as the PROVISIONAL's option.
**(a)'s gap, said plainly:** the record is LOCAL to the Mac whose door wrote it; her edit of the same comment on
another Mac (or the phone) arrives by sync, whose apply never runs `editBlockComment` (and `Sync/` is out of bounds),
so on THIS Mac the record still names the client. PROVISIONAL P-VX260-1.
**The pins:** core — a client's comment, her `editBlockComment` → the record is gone; her no-op edit (same text) →
the record stays; a client's `editCommentForClient` → the record stays. Socket — client X (suggest) adds C; she edits
C; X's `delete_comment(C)` answers her R-VX188-2 sentence byte-exact and C stays live; the control (no edit) still
deletes.

**VX-258 — setup keys tied to their tab; an Any-client re-bind waits for her OK.** `MCPDoor.copySetupCommand(for:)`
mints through `Operations.mintMCPSetupKey()` (`Operations+MCPSetupKeys.swift:26`), which takes no client: every copy —
Claude Code's tab, Codex's, "Any MCP client" — pends one UNTAGGED hash in `mcp_setup_key`. `MCPSetupKeyRule.decide`
(`MCPSetupKeyRule.swift:144`) returns `.rebind` for a bound name presenting any `.unclaimed` key, and
`admitMCPConnection`'s `.rebind` arm (`Operations+MCPSetupKeys.swift:91–107`) binds the key and leaves the client's
approval and grants untouched. So an "Any MCP client" copy given to a tool that calls itself `claude-code` (by accident
or design) is ADMITTED AS claude-code, with every grant, no ask. **The same hole stands one arm over (found on this
trace, not named by round 1):** a KNOWN, APPROVED, UNBOUND name — every client after she adopts a library
(`landMCPAfterAdoption` releases every binding, grants kept), any client approved before VX-168 that never reconnected,
a client she Denied and approved again — takes `.bind` for any unclaimed key, with the same effect (approval and grants
inherited, no ask). Her ruling's words — "i don't want everyone who isn't using claude or codex to be vulnerable to
this. the best protection at each level" — cover both arms; the bind arm's half is PROVISIONAL P-VX258-2.
**The design (argued; built in pieces 9–12):**
1. **Where the tab tag lives — INSIDE the key text (option one, chosen).** A key copied for one client's tab is
   `vmk2_<name>_<43 base64url>`; an "Any MCP client" copy keeps today's `vmk1_<43>` (every key minted before VX-258 is
   one too). The stored hash (`MCPSetupKeyRule.hash` — SHA-256 over the whole key as presented) covers the tag, so a
   holder who edits the tag presents a key whose hash no mint ever stored: `.unknown`, refused. No schema for the tag;
   the tag can never drift from its key; the parse is pure. Option two (a local-only `mcp_setup_key.tab` column) costs a
   schema change, loses the tag the moment a key is claimed, and buys nothing the hash does not already guarantee.
   **The tag carries the client NAME, not the tab** — the app's setup menu (`MCPSetupClient`, inside O-4's fence in
   `MCPPaneCopy.swift`) knows each tab's expected `clientInfo.name` and passes it to the mint; `Sources/` stays
   provider-neutral (O-4's sweep forbids a provider's name in any `Sources/` literal outside a fence, and fences live
   only in the app). The name must be 1–64 characters of `[A-Za-z0-9._-]` (shell-, TOML- and JSON-safe as written).
2. **The arms (`decide`, the new inputs: the name the key was copied for, and whether the name is APPROVED).** The
   tag only ever ADDS a privilege — the zero-click right for its own name; it never makes a key weaker than an
   untagged one. "A name that carries reach" = a known client in state approved.

   | name | presented key | decision |
   |---|---|---|
   | bound, approved | its own key | admit (unchanged) |
   | bound, approved | unclaimed, copied for THIS name | **rebind**, zero clicks (R-VX184-5 as she ruled it) |
   | bound, approved | unclaimed, untagged ("Any MCP client", or minted before VX-258) | **await her OK** — admitted with NO reach (below) |
   | bound, approved | unclaimed, copied for ANOTHER name | **await her OK** (PROVISIONAL P-VX258-1: never weaker than an Any key; (b) refuse) |
   | known, approved, UNBOUND | unclaimed, copied for THIS name | bind (R-VX168-1's "just re-run the setup", unchanged) |
   | known, approved, UNBOUND | unclaimed, untagged or another name's | **await her OK** (PROVISIONAL P-VX258-2 — the bind arm's half of the hole) |
   | known, NOT approved (pending, denied) | unclaimed, any tag | bind / rebind as today (no reach to inherit — her approval still decides) |
   | unknown | unclaimed, any tag | request (unchanged — first contact is always her approval) |
   | the name whose wait holds this key | the waiting key | still waiting (no new ask, nothing logged) |
   | any other name | a key waiting under another name | refuse — another name's key (one sentence) |
   | any | replaced / bound elsewhere / unknown / bare / unnamed | unchanged refusals |

   **A tab key under an UNKNOWN name** is a connection request, as any fresh key is: first contact carries no reach and
   always waits for her approval, and refusing it would dead-end a client whose real name differs from the tab's (a
   renamed client, a mistaken mapping) on its FIRST connection. **Under a DIFFERENT bound name** it waits for her OK
   like an Any key (P-VX258-1).
3. **The waiting re-bind — admitted, with no reach until she allows.** A client on first contact today is ADMITTED as
   a pending request: tools/list empty, every call "This client's connection request is waiting in Variorum ▸ Settings
   ▸ MCP. Nothing is readable until the author approves it." The waiting key gets EXACTLY that face — so its holder
   cannot tell "the name I claimed is a known approved client" from "I am new here" (the no-oracle letter), and Claude
   Code-style clients show the server connected with no tools, then gain them when she allows, with no reconnect (the
   advice's own promise: "Tools appear only for what they have shared (re-announced when that changes)"). Mechanics:
   the admission CLAIMS the key (it leaves the unclaimed set — K2's "the first name that presents it binds to it") into
   a local-only `mcp_rebind_request` row (client, key hash, when — one per client; a newer wait for the same name
   replaces the older, whose key is then forgotten); the SESSION remembers it is waiting and short-circuits every
   tools/list (empty) and tools/call (the pending sentence) BEFORE any tool runs — one choke point, so no tool's grant
   read can leak reach — until the client's bound hash IS its key (her Allow); it does not count as a connection of
   the name for the while-connected grants or the pane's "connected" set while it waits (it is not that client yet).
   Her Allow → `allowMCPRebind(id)`: one transaction — the name's bound key replaced by (or bound to) the waiting key,
   the row gone, logged `connect_rebind_allowed` with the REPLACED key's hash as the target (so the replaced key still
   hears its own sentence — VX-198's memory, unchanged), the tool list re-announced to every session (the grants
   fingerprint gains the binding). Her Don't allow → `declineMCPRebind(id)`: the row gone, the key forgotten (it was
   never anyone's), logged `connect_rebind_declined`; the name keeps its own key, so the real client never notices.
   **What the client hears:** while it waits, the pending sentence (above), the same as any connection request; after
   "Don't allow", its next connection hears the ONE refusal sentence (its key reads as never issued — no oracle); a
   still-open waiting session stays connected and reaches nothing. Deny of the client drops its waiting row; an
   adoption drops them all (the release road's companion).
   **Recorded residual (P-VX258-3):** a call with MALFORMED arguments — first contact answers the tool's argument error
   (each tool parses before it decides), the waiting session answers the pending sentence (it short-circuits first) — so
   a holder of an unclaimed key can still tell the two apart by sending a malformed call. Strictly better than every
   shipped posture (VX-168 refused the same probe outright, VX-198 admitted it with full reach), and bounded (each probe
   spends one key she copied; the bit learned is "this name is an approved client here"). Option (b) closes it at the
   cost of routing the waiting session through every tool with a pending standing (22 grant reads).
4. **The VX-168 impostor pin returns (red-first, pre-fix API only):** a fresh MINT (untagged) presented under the
   bound, approved `claude-code` → the name keeps its own key and the presenter reaches nothing (core: the bound hash
   unchanged; socket: `read_note` on her shared note refused, the tool list empty, the real key still served).
5. **Activity in words:** the new acts (`connect_rebind_waiting`, `connect_rebind_allowed`, `connect_rebind_declined`)
   are worded in `MCPPaneCopy.activityLine` — VX-281's lane — so they are OWED with the face; until then her Activity
   falls back to "used connect rebind waiting" (`spokenAct`), never an error.
6. **`clientInfo.name` per tab:** Claude Code — `claude-code` (VX-184 U1's live round: "claude-code connected with a new
   setup, now bound to its name", Claude Code 2.1.296; the Pro now runs **2.1.299** — re-verified live in this unit's
   stage window, leg 0 below). **Codex — `codex-mcp-client`, from an EXTERNAL LOOKUP, not seen live:** Codex is NOT
   installed on the Pro (`which codex` empty, 2026-10-13), so the one Sonnet lookup agent (read-only, web only) read
   Codex's source: `codex-rs/codex-mcp/src/rmcp_client.rs`, `mcp_initialize_request_params` —
   `Implementation::new("codex-mcp-client", env!("CARGO_PKG_VERSION")).with_title("Codex")` — on `main` and the
   release tag `rust-v0.162.1` (09 Oct 2026); the same literal at `rust-v0.150.0`, `rust-v0.100.0`, `rust-v0.46.0` and
   `rust-v0.30.0` (the legacy `mcp-client` road, removed since, sent the identical triple); one construction site for
   stdio and HTTP alike. Its confidence: high, with the caveat that its fetches were summarized pages, not raw bytes
   (the key line confirmed by four separate fetches). **A fact for the face, from the same lookup:** Codex's opt-in
   2026-07-28 protocol mode (`CODEX_MCP_PROTOCOL_VERSION=2026-07-28`) sends `server/discover` FIRST — VX-180's
   pre-initialize window already answers it; whether that mode still carries `clientInfo` in `initialize` is
   unconfirmed. These names are the APP's to carry (`MCPSetupClient`, inside O-4's fence) — OWED with the face.

### The pins and the red counts (each read from its log — `notes/plans/vx246-screens/u1/logs/`, gitignored)

| member | pin(s) | red on the pre-fix tree | green | red again by revert |
|---|---|---|---|---|
| VX-279 | `MCPServerHostReuseTests.hangUpAfterCloseLeavesAReusedDescriptorAlone` (the round-2 probe, rebuilt) + a temporary real-host probe (never committed) + 21 loaded whole-target runs | 1 test, 3 issues (seam tree) · probe 4 stale hang-ups in 1,000 stops · whole target 1/21 failed under 24 hogs (round 2's exact signature) | 1/1 · probe 0 in 1,200 · whole target 0/21 failed (213/42 each) | 1 test, 3 issues · probe 3 in 400 |
| VX-280 | `MCPPicksPlanTests` (the plan) + `MCPPicksParityServerTests` (every answer, on the wire) | plan pin 1 test, 3 issues (parity pin not yet written — see the revert column) | 2/2; the lens/write suites unmodified 40/7 | plan pin 3 issues; the parity pin GREEN on the old statement (parity proven both ways) |
| VX-259 | `MCPBookNameReachServerTests` (2) + core `MCPBookNameReachTests` (the op's contract, new API) | 2 tests, 8 issues | 2/2 + 1/1; the whole MCP target 217/45 | 2 tests, 8 issues (the wire reverted; the core contract pin green, as it must be) |
| VX-260 | socket `MCPCommentHersServerTests` + core `MCPCommentHersTests` (2) | socket 2 issues; core 1 issue (the keep-the-record test green by design) | 3/3; the comment suites unmodified (MCP 11/4, core 58/18) | socket 2, core 1 |
| VX-258 | core `MCPSetupKeyImpostorTests` (2) + socket `MCPSetupKeyImpostorServerTests` — pre-fix API; plus the new-API state-transition pins (core `MCPSetupKeyTabRuleTests` 3, `MCPSetupKeyWaitTests` 8; socket `MCPSetupKeyTabServerTests` 4) and the schema pins (2) | core 2 tests, 5 issues; socket 1 test, 4 issues | all green; socket MCPSetupKey* 16/4, core 36/6 | core 5, socket 4 (the new-API pins set aside for the revert — they cannot compile against it) |

**Headless finals (piece 13 — the whole package, `swift build --build-tests` then `swift test --skip-build` on
`e9f073ed`'s sources, EXIT 0 in 5:23, zero ✘ lines):** **`VariorumMCPTests` 223 / 48 · `VariorumCoreTests` 2,800 / 324 ·
`StringsWorkbookTests` 40 / 6** — VX-184's close was 212/41 · 2,782/319 · 40/6: MCP +11 tests / +7 suites (exactly the
seven new suites), core +18 / +5 (the five new suites, plus two in `MCPGrantSchemaTests`); the skips are the standing
gated set only (the two 13o gated suites, the real-server pass, `bench(notes:)` and the dev-only fixtures — read in the
log, identical to VX-184's). Log `p13-finals.log`. **The Mac `build-for-testing` (no stage — a build):**
`cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx246-u1
build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (2.5 GB; `Debug/Variorum.app` = `io.lduarte.Variorum.debug` with
`Contents/MacOS/variorum-mcp`; 188 warnings, the standing count — NONE in a file this unit touched, grepped). Log
`mac-build-for-testing.log`. **Path check:** zero lines under `Sources/VariorumCore/Sync/`, custody/Keychain/`Crypto/`,
the editor seam, `Server/`, or `App/Variorum/Variorum/Features/MCP/` (the STOP held); the one App file touched is a
test, `App/Variorum/VariorumTests/TutorialMCPChapterTests.swift` (a justified edit).

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u1`)

**Why TWO windows, said first.** The app's mint call site (`MCPDoor.copySetupCommand`) and the setup menu's names
(`MCPSetupClient`, in `MCPPaneCopy.swift`'s O-4 fence) are under `App/Variorum/Variorum/Features/MCP/` — the brief's
STOP — so on THIS build every Copy setup command still mints an UNTAGGED key, which VX-258 treats as an "Any MCP client"
copy: under the dev store's `claude-code` (approved), a re-run setup WAITS for an OK the pane cannot yet give (no
face). Leg 1 (a Claude Code tab key re-binds with zero clicks) and her Allow / Don't allow therefore need the face; they
are window 2's. Window 1 proves everything else now.

**Window 1 — NOW (~75 min; claim `vx246-u1`).** Built: `App/Variorum/DerivedData/vx246-u1` (the Debug app + the test
bundle, from `e9f073ed`'s sources — rebuild first if the branch moved).
0. **Guards, every step:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` ABSENT — if present,
   STOP, never quit or kill it); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; then the claim line the GO relays;
   `guard.sh <devpid> x y` before each click; ≥ 2.6 s between synthetic events (VX-184 U1's HID-idle lesson).
1. **The Mac batch (~20 min)** — `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS'
   -derivedDataPath DerivedData/vx246-u1` with `-only-testing:VariorumTests/<Suite>`, three groups, every suite a
   changed SOURCE file's type reaches (grepped: `MCPSetupKeyRule`, `mcpSetupKeyStanding`, `MCPServerHost`/`MCPDoor`,
   `denyMCPClient`, `OperationError.mcp…`, `editBlockComment` (her Comments panel), the book-name guard
   (`assertBookNameIsFree`/`duplicateBookName`/`BookNameCopy`), the migrator, `StorePlaintextExport`):
   - **G1 — the door's faces (13 + 5 gated):** MCPSetupKeyFacesTests · MCPSetupMenuTests · TutorialMCPChapterTests ·
     MCPPaneTests · MCPShareFacesTests · MCPAskAndReceiptTests · MCPDoorErgonomicsFacesTests · MCPNavigationTests ·
     MCPEditFacesTests · MCPAsksWaitTests · MCPGrantSheetTests · MCPWingFacesTests · VX206ProtectionLandingTests
     (+ the gated capture suites MCPGrantSheetCaptureTests · MCPShareFacesCaptureTests · MCPAsksWaitCaptureTests ·
     MCPGrantSheetU2CaptureTests · TutorialMCPChapterCaptureTests — expected SKIPPED).
   - **G2 — her comment edit + the guide (22):** CommentPanelParkTests · EditorTypographyTests · BlockDecorGeometryTests
     · CommentsAndReorderTests · CommentPanelGeometryRuleTests · CommentTextAreaMountedTests · CommentPanelWordsTests ·
     CommentPanelFixLeg2Tests · CommentCompositionTests · CommentPanelKeysTests · CommentsPanelModelEditorTests ·
     TutorialBookShapeTests · TutorialDoorTests · TutorialWritingActsTests · TutorialTakesActsTests ·
     TutorialStructureActsTests · TutorialLookingActsTests · TutorialLibraryActsTests · TutorialDeletionActsTests ·
     TutorialWherePlacesActsTests · TutorialPrivacyChapterTests · TutorialFannedMatrixTests.
   - **G3 — the book-name guard and the store (11):** AddToBookMintTests · DuplicateBookNameDoorTests ·
     CalloutSwatchTests · CalloutEmojiPickerTests · BookAscentDeclarationTests · EncryptionBookDoorTests ·
     GatheringRuleGateTests · BookOutlineFacesTests · MastheadTagsObservationTests · PlaintextExportDoorTests ·
     VX209WayBackRoundTripTests.
   Standing reds named if met (VX-115's `BookCollectingDoorsTests` is not in the set).
2. **A1 prestage copy** of the dev store (`Tools/ScaleFixture/stage.sh`'s copy loop without its fixture launch; every
   store file + the key files → `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified); the
   Debug app's prefs plist saved beside the scratch; her user-scope servers read BEFORE (names + a fingerprint, never
   values). A What's New sheet: close it with its own button. A lock screen: `source ~/.variorum/dev-castle.env`, unlock
   with exactly those values, never written anywhere; posture restored before release.
3. **Leg 0 — the posture read + Claude Code's name, live:** launch the Debug app (`open -n`), Settings ▸ MCP: the
   server running; the Clients list's `claude-code` row (approved? grants?) captured. In a scratch project, a
   `variorum-tee` `-s local` registration (the REAL Debug shim behind `tee`, VX-184's form) proves the
   `clientInfo.name` Claude Code 2.1.299 sends (expected `claude-code`).
4. **Leg 2 — VX-258, an untagged copy waits with no reach (a REAL Claude Code):** Settings ▸ MCP ▸ Connect a client ▸
   **Any MCP client** ▸ Copy → an untagged key (its first 9 characters recorded); register it `-s local` as
   `variorum-dev` for Claude Code (the JSON stanza's command + env, by hand); `claude mcp list` → ✔ Connected
   (admitted to a request's face); ONE `claude -p --strict-mcp-config` turn asking it to list the books → no Variorum
   tool exists for it (recorded as found); the tee: the `initialize` result, then an EMPTY `tools/list`. Her
   Activity: one "claude-code was refused using connect rebind waiting" line (the FALLBACK words — the face's are owed;
   captured in BOTH voices). If the dev `claude-code` is NOT approved, the leg reads a bind/rebind instead — recorded as
   found, and the leg is re-run under an approved name in window 2.
5. **Legs 3 and 4 need `claude-code` WITH reach, so they take the existing faces' road (no Allow face yet):**
   `claude-code`'s row ▸ Deny… (confirm) → re-run the Any-client setup (an unapproved name binds — the arm without
   approval) → `claude mcp list` ✔ → the row ▸ Approve… → the grant sheet: EDIT on one Home book (always) + SUGGEST on
   one note (always) (cliclick, guarded). Then:
   - **Leg 3 — VX-259:** mark ANOTHER Home book Private through her own door (its settings); note its exact name N.
     ONE `claude -p` turn: rename the edit-granted book to N in a different case → LANDS, the tool's answer names only
     the client's own spelling (tee-captured; a grep of the wire for N's stored casing finds nothing); the Bookcase shows
     the duplicate. Then the control in the same turn or the next: a rename toward a book the client CAN read refuses.
   - **Leg 4 — VX-260:** ONE `claude -p` turn: `add_comment` on a block of the suggest-granted note. Her Comments panel
     (cliclick): edit that comment's words. ONE `claude -p` turn: `delete_comment` → the tool answer is her R-VX188-2
     sentence, byte-equal ("You don't have permission to delete that comment. Suggest raising your permission level to
     edit."), the comment still live in her panel (capture, both voices).
6. **Cleanup:** the `-s local` registrations removed; her user-scope servers read AFTER (byte-identical fingerprint); the
   dev instance quit BY BUNDLE ID; the prefs restored; the dev store `Tools/ScaleFixture/restore.sh <dir>` → "Restored
   (verified)"; scratch keys and setups deleted, the clipboard emptied, a whole-key grep over the evidence = 0; stray
   `default.profraw` removed; `Tools/stage release`; one result line. Evidence → `notes/plans/vx246-screens/u1/`
   (gitignored; keys redacted to 9 characters).

**Window 2 — AFTER VX-281 merges and the face is built (~45 min; claim per the GO):** the face's Mac suites (the pane's
Waiting section, `MCPSetupMenuTests` with the tagged key form) + **leg 1** (Claude Code ▸ Copy → `vmk2_claude-code_…`;
re-run under the bound `claude-code` → ✔ Connected and SERVED with zero clicks; Activity "…connected with a newer
setup…") + **her Allow** (an Any-client copy as `claude-code` waits; the Waiting row shows it with its declared version;
Allow → the SAME Claude Code session gains its tools with no reconnect; the replaced key's next connection hears its own
sentence) + **her Don't allow** (the wait gone, the next connection hears the ONE sentence, the real key still served)
— the Waiting row and the Activity lines captured in BOTH voices. **Codex's leg: N/A** unless Codex is installed by then
(the name stands on the external lookup above).

### SELF-ASSESSMENT (pre-stage — the implementer's)

**Against the U1 brief, per member:**
- **VX-279** — the mechanism traced, the pin red/green/red, AND caught live on the production road (a real host: 4 stale
  hang-ups in 1,000 stops before, 0 in 1,200 after, 3 in 400 on the revert); the fix is the ticket's (one per-session
  lock, deregister-before-close). The whole-target evidence is HONESTLY WEAK alone (my load reproduced round 2's flake
  only 1 in 21; 0 in 21 after) — the pin and the probe carry the proof.
- **VX-280** — the plan pinned red (worse than the ticket said: notes × takes × ids) and green; the refusals' parity is
  now pinned on the wire and proven both ways by the revert (no suite pinned them before).
- **VX-259** — her ruling as built: the wire's check counts only readable readings (the listing's own rule, asked only of
  colliders, never spending a grant); her doors untouched (nil = E13 whole). Two existing pins encoded the oracle and were
  re-pointed at readable books, each commented.
- **VX-260** — the ruled option literally (her edit clears the record, only when the words change); the cross-device gap
  said plainly (P-VX260-1).
- **VX-258** — the core complete: the tag inside the authenticated key text (zero schema for the tag), the rule's arms,
  the waiting state (one local-only table, its own commit after SyncSpec), the session's one choke point (no tool runs for
  a waiting key), her two answers as ops, Deny/adoption tidy, the VX-168 impostor pin restored to its original threat and
  red-first. **The bind arm's half of the same hole (P-VX258-2) is closed the same way** — beyond the round's letter,
  within her ruling's words; said, pinned, provisional.
**Against the spec:** zero `Sync/`, custody, editor seam, `Server/`; ONE local-only schema change (v1_28) on the grants
family's road — SyncSpec read first, marker 13, zero lockstep, the export strips it; I1–I10/P1–P3/S1–S5 untouched (VX-280
restores P1's letter; S-invariants not in play — local-only rows). A-4's boundary stays K2's (names, not processes) —
VX-258 narrows WHICH fresh key may move a name; it does not claim more than K2's recorded non-defeat.
**Risks I see:** (1) **THE MERGE GATE:** until the face's mint call site lands, every Copy mints an untagged key, so her
re-run Claude Code setup WAITS for an OK no pane can give — the run must not merge (or reach her build) with U1's core
alone; (2) P-VX258-3's malformed-arguments residual; (3) a waiting session flips to served lazily (its next call, list
or the announce) — between her Allow and the flip it is not yet counted as the name's connection (a while-connected
grant ending in that instant is the only effect); (4) the Codex name is an external lookup, not seen live; (5) the
noticed-not-fixed VX-279 neighbour (OWED 3).

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX258-1 — a tab key under ANOTHER known approved name:** (a) as built — it waits for her OK, as an untagged key does
  (a tag only ever ADDS the zero-click right for its own name; never weaker than an Any key); (b) refuse it
  (`notThisNamesKey`, the one sentence) — stricter, but a client whose real name differs from its tab's (a rename, a
  mistaken mapping) then has no road but the Any tab. Under an UNKNOWN name any fresh key is a connection request
  (first contact is always her approval; refusing would dead-end a mis-mapped client on its first connection).
- **[RATIFIED by her, 2026-10-13 ~23:35 MDT — *"i ratify what you built"*: option (a) stands.]** **P-VX258-2 — the BIND arm (a known, approved, UNBOUND name — every client after an adoption, a Deny-then-approve, a
  client approved before VX-168):** (a) as built — an untagged (or another name's) key waits for her OK there too, the
  same hole closed the same way; a key copied for the name binds at once (R-VX168-1 unchanged for the tabs); (b) leave
  the bind arm as VX-168 built it — the MAJOR's hole stays open for unbound approved names (after every adoption, all of
  them).
- **P-VX258-3 — what a waiting connection hears:** (a) as built — the session short-circuits before any tool: no tools,
  every KNOWN tool the pending sentence, an unknown name "Unknown tool" (as for anyone); residual: a MALFORMED call to a
  known tool still tells a waiting connection from a first-contact one (each tool parses before it decides); (b) route
  the waiting session through every tool with a pending standing (22 grant reads), closing the residual at the cost of
  touching every tool's standing read; (c) refuse the waiting connection at the handshake with its own sentence —
  simplest, but tells its holder the name is approved (an oracle) and needs a reconnect after her Allow.
- **P-VX258-4 — one wait per name:** (a) as built — a newer waiting key for the same name replaces the older (whose key
  is forgotten: its holder hears the ONE sentence next time) — one ask per name in her Waiting section; (b) one row per
  key — several asks for one name, which she cannot tell apart (A-4: names, not processes).
- **P-VX258-5 — the wait's Activity row and calls:** (a) as built — the FIRST presentation logs `connect_rebind_waiting`
  as REFUSED (it reaches nothing), a re-presentation nothing, and a waiting session's calls log nothing (a first-contact
  request's calls log per tool — her side only, no client sees it); (b) log the waiting connection as allowed
  ("connected"), and/or its calls per tool.
- **P-VX258-6 — the key's tag form:** (a) as built — `vmk2_<name>_<43>`, the client name readable in her client's
  config (1–64 of `A–Z a–z 0–9 . _ -`; a name outside that is refused at the mint); (b) an encoded tag (e.g. base64url of
  any name) — carries any name, readable by nobody.
- **P-VX260-1 — her edit on another device:** (a) as built — only her edit on THIS Mac (the record's own Mac) clears the
  record; (b) a text digest on the record (a local-only column): any change to the words, from any device or client,
  makes deleting need edit; (c) the `updated_at` compare (rejected: the add's undo/redo revive, her delete + restore and
  every sync apply bump it, so "not its own" would follow from acts that change no word).

### FOR VX-234 (user-facing words, as built)

**No rendered app word changed in this unit** (the STOP). On the WIRE (technical register, unchanged sentences, new
uses): a waiting connection answers the existing pending sentence ("This client's connection request is waiting in
Variorum ▸ Settings ▸ MCP. Nothing is readable until the author approves it."); after her Don't allow its next
connection hears the existing ONE sentence. **Words the face will need (owed — listed for her wording pass):** the
Waiting section's re-bind row (who, the declared version, "a setup copied for any MCP client"), its Allow / Don't allow
verbs and receipts; Activity lines for `connect_rebind_waiting` / `connect_rebind_allowed` / `connect_rebind_declined`
(today her Activity falls back to "claude-code was refused using connect rebind waiting"); `MCPPaneCopy.refusal` for
`mcpRebindRequestNotFound` (today "Couldn't do that: …"); and the truth updates of L1 (`clientBoundary`), `keyLine` and
the guide's lesson-2 sentence (U8) — a client's own setup re-run moves its name; an Any-client setup waits for her OK.

### OWED (for the orchestrator)

1. **VX-258's FACE — after VX-281 merges (the brief's STOP; the record of what it must carry):**
   (a) **the mint call site — NOT optional, the merge gate (risk 1):** `MCPSetupClient` (inside O-4's fence in
   `MCPPaneCopy.swift`) gains each tab's expected `clientInfo.name` — Claude Code `claude-code`, Codex `codex-mcp-client`
   (external lookup), Any MCP client `nil` — and `MCPDoor.copySetupCommand` passes it:
   `try $0.mintMCPSetupKey(copiedFor: client.expectedName)` (one line); `MCPSetupMenuTests`' key regex then reads
   `vmk2_<name>_…` for the two tabs and `vmk1_…` for Any (a justified edit);
   (b) the Waiting section's re-bind row — read `Queries.mcpRebindRequests` (the door's store observation must include
   `mcp_rebind_request`), Allow → `allowMCPRebind(id)`, Don't allow → `declineMCPRebind(id)` (both throw
   `mcpRebindRequestNotFound` for a gone ask), the pending marks/counts if the face counts asks;
   (c) the Activity words and the refusal words above; (d) L1 / `keyLine` truth (U8 re-voices the guide).
2. **Window 1 now, window 2 after the face** (THE STAGE WINDOW above).
3. **Noticed on the way, NOT fixed (same class as VX-279, a ticket):** `MCPSocketTransport`'s reader THREAD may outlive
   `session.run()` — after the SDK's `disconnect` shuts the socket down, a reader descheduled between two `read`s could
   issue its next `read` after the host has closed and the process reused the number (reading another socket's bytes).
   Traced by reading, not reproduced; vanishingly narrow (it needs the thread descheduled across several async hops).
   The fix shape: the session's close waits (bounded) for its transport's reader to exit.
4. **The ladder's attention:** P-VX258-2 goes beyond round 1's letter (the bind arm) — within her ruling's words; the
   orchestrator may hold it for her.
5. **Canon at the merge:** AppSpec §12 THE MCP DOOR — A-4's boundary as amended by VX-258 (a client's own setup re-binds
   its name with zero clicks; any other fresh key under an approved name waits for her OK, admitted with no reach; Deny
   and an adoption drop the waits); §7's grants-family bullet gains v1_28 (local-only, marker 13, zero lockstep); the
   door's book-name check (VX-259); her edit makes a comment hers (VX-260). MOBILE PARITY: nothing mobile-visible except
   VX-260 riding her shared comment door (the phone's comment edit clears the record too — on the phone's own store,
   which never holds a record).

### THE ORCHESTRATOR ON U1's HAND-BACK (2026-10-13, ~23:15 MDT)

- **Accepted as reported.** Green suites were not re-run (rule 6). The path check across `3b0d641d..ab552c5a` finds zero
  lines in `Sync/`, custody/Keychain, `Server/`, `Features/MCP/` or the editor seam. The only App file is a test, and
  the one schema step is `Persistence/MCPGrantSchema.swift` + `Migrations.swift` (local-only v1_28).
- **The cutover.** The implementer handed back at ~678k context, past the ~500k quality line. It stops at this clean
  seam (committed, green, the record complete), and U1b gets a fresh implementer.
- **The window.** None was requested; the Stage traffic log says why. U1's planned Mac batch (THE STAGE WINDOW above,
  its three groups) rides U2's window. Its live legs 0–5 move whole to U1b, after the face exists.
- **`MCPDoor`'s one line early (the hand-back's question): declined.** On its own it closes nothing: the names it must
  pass live in `MCPSetupClient`, inside VX-281's `MCPPaneCopy.swift` (O-4's fence). And the gap only bites a build
  carrying U1's core without the face, which the merge gate already forbids.
- **The PROVISIONALs.**
  - **P-VX258-1, -3, -4, -5 and -6 stand as built.** Each is the defensible pick. The ladder reads them, and they go
    into QUESTIONS at the merge.
  - **P-VX258-2, the bind arm, stands as built** — *and she RATIFIED it the same evening (her rulings section)*. It is the safer reading of her ruling's words (*"the best protection
    at each level"*). It goes to her in chat; QUESTIONS takes it at the merge unless she answers first.
  - **P-VX260-1 is rebuilt as option (b), for U1b.** Her rule reads "Once she has edited an AI's comment, deleting it
    needs EDIT". An edit on her phone or the Air is still her edit, and (a) leaves those comments deletable.
    - Option (b) adds a local-only digest of the comment's words to the authorship record and compares it at delete.
      That honors her words wherever she edits, with no `Sync/` line and no trigger. An unchanged digest means
      unchanged words, so her "only when the words change" stays exact.
    - U1b gives it its own schema commit on the grants family's road. It argues in the record between backfill and a
      NULL-means-legacy rule, and pins red-first: a text change with no door (a synced edit's shape), then the suggest
      delete hears her sentence.
    - Accepted residual: an EDIT-rung client's rewrite also makes a comment undeletable at SUGGEST.
    - It is still PROVISIONAL, with options (a)/(b)/(c) kept for her.
- **OWED 3 is now VX-318,** a member of this run, built in U1b.
- **OWED 5, the canon at the merge,** is carried to the closeout as written.

## U2 UNIT RECORD — the undo class: VX-276 · VX-277 · VX-119 (opus-implementer, from 2026-10-13 ~23:40 MDT)

**What this unit has NOT done yet (said first; the state at READY, 2026-10-14 ~01:50 MDT):** (1) **no stage window has
run** — no Mac test batch, no Edit-menu walk, no real `claude -p` turn (THE STAGE WINDOW below, waiting on the GO); so
the quiet-press refusal words have never been seen on screen; (2) **the phone's undo door is untouched** — the rule
reaches the phone (same `UndoStack`), its quiet-press words do not (MOBILE PARITY, OWED 2); (3) no `notes/QUESTIONS.md`
entry or canon edit (the merge's). Everything else is built, pinned red-first, red again by revert, and green headless. Everything below "The design" is the
plan, not a claim.

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (AppSpec §9's structural undo/redo
bullet, §12's one status seam — "a door that did nothing speaks a refusal"); this run record's header, THE UNITS, the
hard rules, LIVE STATUS, Cross-run coordination, the U2 BRIEF (the three tickets quoted verbatim) and U1's UNIT RECORD
(its THE STAGE WINDOW, which this unit's window also runs); the plan `notes/plans/mcp-pane-and-docs-kickoff.md` whole;
the runway §2–§3; VX-184's record — THE LADDER whole from ROUND 1 through ROUND 2's FIX PASS (the SWEEP TABLE, its
ROUND 2 READING, the ADJACENT CLASS, round 2's redo finding and dispositions); `notes/plans/13na-ladder-round1.md`
(F1 and the VX-119 adjunct); `notes/SessionResiliencyProtocol.md` whole; `UndoStack.swift` whole. Code read: the two
doors that press ⌥⌘Z / ⇧⌥⌘Z (`ShellActions.structuralUndo/Redo`, the phone's `MobileUndoDoor`),
`StructuralUndoCopy`, `Operations+UndoInverses` whole, and every `undoStack?.register(` site (85, in 27 files) with
the halves it names — read as the sweep proceeds and listed in THE SWEEP TABLE.

**Surfaces (planned):** `Sources/VariorumCore/Operations/UndoStack.swift` (the rule), the registration sites' halves
under `Sources/VariorumCore/Operations/` (each half says whether it changed anything), the Mac door
`App/Variorum/Variorum/Registry/ShellActions.swift` (what a quiet press says) and `App/Variorum/Shared/StructuralUndoCopy.swift`
(its words), tests. ZERO `Sync/`, custody/Keychain, schema, `Server/`, editor seam, VX-281's lane. The phone's door
(`VariorumMobile/…/MobileUndoDoor.swift`) is NOT touched (see "What she sees" — a MOBILE PARITY owed line).

### LIVE STATUS — U2's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the design argued (before code) | DONE (`748b21d9`) |
| 1 | the pins FIRST, on the pre-fix API: the five round-2 probes + one per family (revive, VX-277's adopt doors, Delete Block after Put back, VX-119's single-file import and copy ops, the partial-entry and mirror orders) → RED on the pre-fix tree, counts recorded | DONE (`dfcb6531`) — NEW `Tests/VariorumCoreTests/UndoQuietPressTests.swift`, 22 tests, pre-fix API only (`undo(with:)`/`redo(with:)`, rows read back), each checking its premise (her door registered nothing / cleared no future). **RED on the pre-fix tree (`748b21d9`'s sources): 22 of 22 failed, 22 issues — one each, every one the "her change stands" line, no premise line** (log `notes/plans/vx246-screens/u2/logs/p1-pins-red.log`, gitignored). By family: VX-276's five round-2 probes (`lockRedoAfterQuietUndo`, `finishRedoAfterQuietUndo`, `renameBackToOriginalThenQuietUndoThenRedo`, `deleteNoteRedoAfterHerPutBackAndAQuietUndo`, `deleteChapterRedoAfterHerRestoreAndAQuietUndo`) 5 · the revive family (add_comment, apply_tag, create_section, create_note, and add_note_to_book's seat in the other order — ⌥⌘Z wrote, her dismissal, ⇧⌥⌘Z) 5 · the mirror order (an undo after a quiet redo) 1 · the client's adopt over two slots (her ✓ back on one) 1 · VX-277: her adopt's undo over her later ✓ 1, her adopt's parts 1, Delete Block after her Put back 1 · VX-119: the single-file import 1, Duplicate as Version 1, the F1 stamp key (a tombstone on another stamp between ⌥⌘Z and ⇧⌥⌘Z) 1 · entries with parts in the mirror order: her merge (the merged block she put back) 1, the client's batch of takes 1, the client's rule over two columns 1, imported paste blocks 1 |
| 2 | the rule in `UndoStack` (halves report whether they changed anything; a quiet half retires its entry; the compound tracks its legs) + every registration site converted (the compiler enumerates them) + the per-part entries' boxes + the Mac door's quiet words → GREEN, every existing undo/redo suite unmodified | DONE (`e63c8dd0`) — **`UndoStack`:** `Entry.inverse`/`redo` return `Bool`; `undoReporting`/`redoReporting` → `Outcome(label, changed)` (`undo`/`redo` keep returning the label — every existing caller and pin unchanged); a quiet half RETIRES its entry and leaves the other stack as it was; `withCompound` keeps each leg's state (applied · reverted · retired), runs only the legs whose partner changed something, and a throwing leg keeps every finished leg counted. **Shared helpers (one shape per family):** `registerStructuralEntry` (the 12 `revertStructural`/`reapplyStructural` sites — `StructuralParts`: texts · minted blocks · placement rows · converted takes, each half `only:` its partner's parts), `registerMintedContainerEntry` (the 10 single-container sites — `revertMintedContainer` returns its stamp, `reapplyMintedContainer` revives only on it: VX-119's F1 shape), `registerPointerEntry` (her three adopt doors — VX-277 — and the client's `choose_take`: per-slot compare-and-set + the slots record). **Per-entry records:** `set_book_rule` (columns), the takes/comments batches (`BatchParts`, per-row stamps), imported paste blocks, move-to-new-take (`SpanParts`), the client's `adopt_lens` (slots + the kept lens's stamp), diverge (`DivergeUndone`), convert-to-book (`SmartConversionUndone`). **Stamp-keyed revives (the F1 shape):** `add_take`, `add_comment`, `apply_tag`/`remove_tag` (both directions), `create_section`, `add_note_to_book` (and its seat: re-seats only while the row still waits at the door as the undo left it). **Quiet now where her Put back owns the row:** `revertDeleteVariant` and `revertArchiveVariant` write nothing (not even the default pointer) when the take is already live / active. Every other half returns the truth it already computed. **Mac door:** `ShellActions.structuralUndo/Redo` read the outcome — a quiet press speaks a REFUSAL (`StructuralUndoCopy.undoFoundNothing/redoFoundNothing`). **GREEN:** the 22 pins 22/22 (`p2-pins-green.log`); the whole core **2,822 / 325** (U1's 2,800/324 + these 22 + 1 suite) and the whole MCP target **223 / 48**, zero failures, every existing pin UNMODIFIED (`p2-core-whole.log`, `p2-mcp-whole.log`); the phone's door untouched (it compiles: `undo(with:)`'s signature stands) |
| 3 | red again BY REVERT (announced first, on a committed tree; restored and verified) | DONE (run on `e63c8dd0`, recorded in `84e1b458`) — announced in its own commit before it ran; on the committed tree `e63c8dd0`: the 27 changed files under `Sources/VariorumCore/Operations/` back to the pins commit `dfcb6531` (`git checkout dfcb6531 -- <the 27>`), the pins kept → **RED again: 22 of 22 failed, 22 issues, the test × line set IDENTICAL to piece 1** (diffed) (`p3-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/VariorumCore/Operations/`, `git status` clean, `git diff HEAD` empty → 22/22 green (`p3-restored.log`). **Two more pins added after the revert (`84e1b458`):** `aDivergedCopySheDeletedStaysDeletedThroughTheRedo` (the diverge entry — its logic changed most; its own red-by-revert is piece 3b) and NEW `UndoStackQuietRuleTests` (3 — the stack's rule on the new API: a quiet undo retires and leaves the redo future; a quiet redo retires; a compound runs only the legs whose partner changed — green by construction, state transitions); **26/26 green** across the two suites |
| 3b | the diverge pin red by revert (announced here; the new-API suite moved aside inside the worktree while it runs) | DONE (announced `84e1b458`, recorded `ef2ef588`) — the same 27 files back to `dfcb6531`, `UndoStackQuietRuleTests.swift` moved aside → `UndoQuietPressTests` **23 of 23 failed, 23 issues** — the 22 as before plus `aDivergedCopySheDeletedStaysDeletedThroughTheRedo` on its "her delete of the copy stands" line (`p3b-revert-red.log`); **RESTORED** (`git checkout HEAD -- Sources/VariorumCore/Operations/`, the file moved back, `git status` clean but this record) → **26/26 green** (`p3b-restored.log`) |
| 4 | THE SWEEP TABLE complete — every one of the 85 registrations FIXED or SAFE with its reason | DONE (`ef2ef588`) — below |
| 5 | headless finals (core · MCP · workbook) + the Mac `build-for-testing` | DONE (`1a891184`) — **the whole package, `swift test --skip-build` on `ef2ef588`'s sources, EXIT 0 in 4:06: `VariorumMCPTests` 223 / 48 · `VariorumCoreTests` 2,826 / 326 · `StringsWorkbookTests` 40 / 6**, zero ✘ (core = U1's 2,800/324 + `UndoQuietPressTests` 23 + `UndoStackQuietRuleTests` 3; MCP and workbook unchanged); the standing gated skips only (`p5-finals.log`). **The Mac `build-for-testing`** into `App/Variorum/DerivedData/vx246-u2` (an APFS clone of U1's folder, then incremental; 65 GiB free first) → **`** TEST BUILD SUCCEEDED **`**, EXIT 0, no warning in a touched file (`mac-build-for-testing.log`). It first failed on ONE Mac test: `JumpAndUndoTests.swift` (`StructuralUndoTests.concurrentUndosExecuteOneAtATime`) registers a toy entry whose inverse returned nothing — a **JUSTIFIED EDIT** (the ritual comment in place): the toy now answers `true` (it stands for an inverse that changed something); the serialization it pins is untouched |
| 6 | THE STAGE WINDOW plan (claim `vx246-u2`; the Mac batch incl. U1's three groups; the Edit-menu walk with a real `claude -p` turn; a batch-only fallback) → READY | DONE (`1a891184`) — THE STAGE WINDOW below; **READY for stage** (the stage NOT claimed — the orchestrator's GO) |

**No revert is in flight** (pieces 3 and 3b ran and were RESTORED — `git diff HEAD` empty under `Sources/`).

### The mechanism, traced (inputs → wrong state)

`UndoStack.undo` (`UndoStack.swift:280–295`) runs the top entry's inverse and, whenever the inverse does not THROW,
moves the entry onto the redo stack. Every inverse in the house is written to be QUIET on divergence — it returns
without writing when the world has moved past its entry (`revertDeleteBlock` at a live block, every compare-and-set
restorer, every stamp-keyed revival) so the stack never wedges. So a quiet inverse is indistinguishable, to the stack,
from one that wrote. The redo half then runs against whatever the rows read NOW, and nearly every redo checks only that
its rows are back in the pre-act state. Her undo-less doors (the recovery and metadata class: Put back from the tray or
the Trash, restore a chapter or comment, unarchive, reopen/finish, rename, her ✓, lock/unlock, the rule editor's Save)
produce exactly that pre-act state. So: act → her reversal by an undo-less door → ⌥⌘Z (quiet, but popped onto the redo
stack) → ⇧⌥⌘Z writes the act over hers. The same holds in the MIRROR order (⌥⌘Z writes → she changes it by an undo-less
door → ⇧⌥⌘Z quiet but moved back onto the undo stack → ⌥⌘Z un-does her change) and for PARTS of a multi-part entry
(an adopt over several slots: her ✓ back on ONE slot makes the undo partial, and the redo re-chooses that slot over
her). VX-119's case is the same shape on the mint family: import a file → she deletes the note (`deleteContainer`
clears the redo future, not the undo stack) → ⌥⌘Z (`revertMintedContainer`: already dead, quiet) → ⇧⌥⌘Z
(`reapplyMintedContainer`: still dead → `restoreContainer`) brings back the note she deleted.

### The design, argued

**1. Where the rule lives — the STACK, with every half saying whether it changed anything (the brief's (a), carrying
(b) where an entry has parts).**
- **(a) In `UndoStack` (CHOSEN, as the rule's home).** Each half returns `Bool` — "this half changed something".
  `undo` moves an entry onto the redo stack only when its inverse changed something; a QUIET inverse RETIRES the entry
  (it leaves the undo stack and never reaches the redo stack — there is nothing for its redo to put back). `redo`
  mirrors it exactly: a re-apply that changed something moves the entry back onto the undo stack; a quiet one retires
  it (there is nothing for its next undo to take back). So the stack itself guarantees the rule's two halves for every
  entry at once: **a half only ever runs after its partner changed something**, so a redo after a quiet undo never
  runs, and an undo after a quiet redo never runs. ONE mechanism, in ONE file; the entry types change from
  `(Operations) throws -> Void` to `(Operations) throws -> Bool`, so EVERY registration site must answer the question —
  the compiler enumerates the sweep, and a future registration cannot forget it (it cannot compile without saying what
  its halves changed).
- **(b) Per entry, for entries with PARTS (CARRIED inside (a)).** A whole-entry Bool is exact for an entry with one
  part (its compare-and-set or stamp key already decides that one part). An entry with several parts (an adopt over N
  slots; a rule over three columns; a merge's minted block and released placements; a batch of N takes or comments;
  N imported blocks) can be PARTIAL: the undo writes some parts and finds others already moved by her. Its redo must
  then put back exactly the parts the undo took back — no more. Those entries keep a per-entry box of WHICH parts the
  last half changed (the house precedent: `importBook`'s F1 stamp box, `save_lens`'s `undoneOn:`, `restoreCommentForClient`)
  and each half acts only on the parts its partner changed; the half's `Bool` is "changed any part". The COMPOUND
  (`withCompound`) does the same for its legs inside the stack: it records which legs' halves changed something and
  runs only those legs' partners next.
- **(c) Rejected: detect writes in the database** (`total_changes()` or a GRDB transaction observer around the half) —
  zero edits per site, but it counts incidental writes (an `updated_at` bump, an insurance commit) as "changed", races
  any other writer on the shared connection, and gives no per-part answer; the rule would be implicit where a reviewer
  cannot read it.
- **Weighed, the redo-future rules:** (1) any new structural act still clears the redo future (unchanged — `register`);
  (2) undoing a `redo: nil` entry that CHANGED something still ends the redo future (unchanged); (3) a QUIET half
  retires only its own entry and leaves the other stack as it was — it adds no history and abandons no future (the
  redo stack's remaining entries were undone by presses that did change something, and each of them re-applies only
  over its own undo's result, so none of them can reach over hers either). Options for (3) — PROVISIONAL P-VX276-1
  below.
- **The compare-and-set on the UNDO side stays** (VX-184 round 1's fix, the brief's word): it is what makes an inverse
  quiet when she changed the value to something NEW; the stack rule covers the order round 2 found (her change BACK to
  the pre-act value). Both are needed: the stack rule alone would let an undo overwrite a third value of hers.
- **How many files:** 27 files, 85 sites — every one converted and dispositioned in THE SWEEP TABLE. A site whose
  halves were already exact (keyed on what the partner wrote) still converts: its halves return the truth.

**2. What she sees on a quiet press (AppSpec §12: a door that did nothing speaks a REFUSAL).**
- Today a quiet ⌥⌘Z says the RECEIPT "Undid: <label>" though nothing changed, and leaves an Edit-menu "Redo <label>"
  that would write the act over her change. After: the stack reports the outcome (`UndoStack.Outcome` — the label and
  whether it changed anything; the old `undo(with:) -> String?` / `redo(with:) -> String?` keep returning the label so
  every existing caller and pin reads unchanged), and the Mac door speaks a REFUSAL on a quiet press —
  "Nothing to undo — <label> was already undone or changed since." / "Nothing to redo — it changed again after <label>
  was undone." (words AS BUILT, the FOR VX-234 list). The entry is retired, so the Edit menu moves on to the next entry
  and never offers a redo that would do nothing.
- MCP entries keep their client-named labels ("claude-code's book rename") in both sentences.
- **The phone's door (`MobileUndoDoor`) is NOT changed here** (out of this unit's surface; no simulator stage): the core
  rule reaches the phone the moment it ships (its stack is the same `UndoStack`), but on a quiet press the phone still
  speaks its receipt "Undid: <label>" and offers Redo, which then finds nothing (or the next entry). A MOBILE PARITY
  owed line (OWED, below).

**3. The revive direction (VX-119, VX-276's adjacent class).** The mint and revive entries' redos already revive by a
stamp where the house keyed them (`importBook`'s F1 box, `save_lens`, `create_book`, `link_versions`,
`restore_comment`); under the stack rule a quiet inverse retires its entry, so the redo of a revival NEVER runs after
an undo that tombstoned nothing (R2-1's nil rule, enforced by the stack instead of by each box). Where a redo revives
by CURRENT state (`reapplyMintedContainer`, `reapplyAddedComment`, `reapplyAppliedTag`, `flipCreatedSection`,
`reapplyAddedMembership`, …) the redo is ALSO keyed on the stamp its own inverse wrote (the F1 shape), so a row that
died since on another stamp — her Trash, a sync tombstone from another device, which clears no redo future — is never
revived by it.

**PROVISIONAL P-VX276-1 — what a QUIET half does to the stacks:** (a) AS BUILT — it retires its own entry and leaves
the other stack as it was; (b) it retires its entry AND ends the redo future, as undoing a `redo: nil` entry does —
stricter, but it throws away redos her earlier presses earned; (c) the entry moves on marked quiet and its partner is a
no-op — the house precedent's letter (`restoreCommentForClient`'s quiet redo), but the Edit menu then offers a
"Redo <label>" that does nothing (a false offer).

**PROVISIONAL P-VX276-2 — a quiet press's words and kind:** (a) AS BUILT — a refusal (it toasts), naming the entry;
(b) a quiet receipt (a muted line). (a) is §12's letter: a door that did nothing speaks a refusal.

### THE SWEEP TABLE — every structural-undo registration, both families (piece 4)

**The class (VX-119's rule, the brief's ONE RULE):** an entry's half that reads CURRENT state instead of what the act or
its partner half wrote, so it writes over a change of hers. Four orders reach it: **O1** act → her undo-less reversal →
⌥⌘Z (quiet) → ⇧⌥⌘Z; **O4** its mirror (⌥⌘Z wrote → her change → ⇧⌥⌘Z quiet → ⌥⌘Z); **O2** ⌥⌘Z wrote → her change →
⇧⌥⌘Z (the redo must act only over the undo's own result); **O3** ⇧⌥⌘Z wrote → her change → ⌥⌘Z (round 1's
compare-and-set). **The stack now closes O1 and O4 for EVERY entry by construction** — a half only ever runs after its
partner changed something — PROVIDED each half answers truthfully; so each row says (i) its answer is the truth (it
returns `true` only on a path that wrote a part of the act's result) and (ii) how O2/O3 and the PARTS stand. Her
undo-less doors (the recovery and metadata class): Put back (tray, Trash), restore (chapter, comment, reading), ✓,
renames, label, commit name, lock/unlock, finish/reopen, archive/unarchive (note, book, take), the rule editor's Save,
filing, reorder in a book/chapter, dismiss/seat, un-tag, her per-note wing move — plus a sync apply from another device.
Every door of hers that REGISTERS an entry (divide, merge, extract, new block, delete block/take, archive take/block,
move, reorder, the conversions, the copies, import) puts hers on top of the stack — LIFO undoes hers first, so it is
not the class. **Pins:** the family pins are `UndoQuietPressTests` (23, red on the pre-fix tree, red again by revert)
and `UndoStackQuietRuleTests` (3, the stack itself).

| # | site (file:line on `dfcb6531`) | entry → halves | verdict |
|---|---|---|---|
| 1 | `UndoStack.swift:222` (the compound) | `withCompound`'s folded legs | **FIXED** — leg states (applied · reverted · retired); a half runs only legs whose partner changed something; a throwing leg keeps finished legs counted (supersedes R2-1's retry concern by construction). Pin `aCompoundRunsOnlyTheLegsWhosePartnerChangedSomething` |
| 2–13 | `Block:80` New Block · `Pool:104` Pool Copy · `TakeEdits:77` (her take edits) · `TakeStructure:249` (take↔block conversions) · `Structural:144` Extract · `:201` Divide · `:366` Divide choosing takes · `:673` Divide (fanned) · `:845` Split at Newlines · `:989` Merge · `:1250` Merge Takes · `MCPEdits:112` `edit_take` · `MCPNoteEdits:416` `restore_commit` | `revertStructural` / `reapplyStructural` → now `registerStructuralEntry` | **FIXED (parts)** — each half returns `StructuralParts` (texts, minted blocks, placement rows, converted takes) and runs `only:` its partner's parts, so a mint she Put back from the tray between ⇧⌥⌘Z and ⌥⌘Z is never tombstoned again (O4-partial) and a released source she re-homed is never re-released (O2-partial). O1: her tray Put back of an untouched mint is impossible (an untouched mint vanishes without `last_container_id`); a diverged mint's Put back makes the redo's block part quiet. Text parts stay CANON-DECIDED (AppSpec §9: a buffer edited since is insured by a quiet commit, then overwritten; A12 warns) — unchanged. Pin `herMergeLeavesTheBlockSheRestoredBetweenRedoAndUndo` |
| 14 | `BlockArchive:51` Archive Block | `revertArchiveBlock` / `performArchiveBlock(quiet)` | **SAFE** (now truthful: `performUnarchiveBlock` returns nil on its quiet road) — her unarchive door (`unarchiveBlock`) REGISTERS its own entry (LIFO); O2/O3 reach only by sync, and both halves check the block's archive state they move from |
| 15 | `BlockArchive:99` Unarchive Block | mirror of 14 | **SAFE** — as 14 |
| 16 | `Deletion:17` Archive Variant | `revertArchiveVariant` / `performArchiveVariant(quiet)` | **FIXED** — her unarchive (`unarchiveVariant`, no entry) makes the take active; the inverse is now QUIET there (it no longer re-asserts the default pointer over what her unarchive left — it used to, which made the undo "write" and the redo re-archive), so O1 retires. O2: ⌥⌘Z wrote → she archives it herself → ⇧⌥⌘Z finds it archived — quiet (retires). Family pin: the toggle probes (`lockRedoAfterQuietUndo`, `finishRedoAfterQuietUndo`) — same stack road; no take-archive pin of its own |
| 17 | `Deletion:143` Delete Variant | `revertDeleteVariant` / `performDeleteVariant(quiet)` | **FIXED** — her tray Put back (`restoreVariant`, no entry): the inverse is now quiet on a live take (no default-pointer write — same reason as 16), so O1 retires. O2: the take re-deleted by her — `deleteVariant` registers (LIFO). Family pin `deleteBlockRedoAfterHerPutBackAndAQuietUndo` (same shape, the block) |
| 18 | `Deletion:244` Delete Block | `revertDeleteBlock` / `performDeleteBlock(quiet)` | **FIXED** — VX-277's case: her tray Put back → ⌥⌘Z quiet (`false`) → retired; ⇧⌥⌘Z never re-deletes. O2: her own re-delete registers (LIFO). Pin `deleteBlockRedoAfterHerPutBackAndAQuietUndo` |
| 19 | `Variant:425` Reorder Take | `restoreFanPosition` ×2 | **SAFE** — truthful (`false` when already there); her other reorders register (LIFO); O2/O3 only by sync, and each half moves to an exact position, never past a value she chose by an undo-less door (none exists for `fan_position`) |
| 20–21 | `Placement:216` Move Block · `:251` Reorder | `restorePlacementLocation` ×2 | **SAFE** — truthful (`false` when already there); every door of hers that moves a placement registers (LIFO); MCP `move_block` registers too |
| 22 | `SpanToTake:145` Move into a New Take | `revertSpanToNewTake` / `reapplySpanToNewTake` | **FIXED (parts)** — `SpanParts` (the source's words · the minted take, with the stamp the undo tombstoned it on): her tray Put back of the minted take between ⌥⌘Z and ⇧⌥⌘Z makes the redo's mint part quiet and the next undo leaves it; the redo revives the take only on the undo's stamp. Text part canon-decided (insured), as 2–13. Covered by the structural/batch family pins (no pin of its own) |
| 23 | `Diverge:114` Diverge for This Book | `revertDiverge` / `reapplyDiverge` | **FIXED** — `DivergeUndone` (the stamp; which of copy row · original row · copy it moved): the redo revives the copy only while it is dead on the undo's stamp, the original's row only if the undo brought it back. O1/O2: her Delete of the copy before ⌥⌘Z (clears no undo history) — the undo still writes (the original comes back), and the redo used to `restoreContainer` her deleted copy. Pin `aDivergedCopySheDeletedStaysDeletedThroughTheRedo` (red by revert, piece 3b) |
| 24 | `ReadingConversion:216` Convert to Book | `revertSmartConversion` / `reapplySmartConversion` | **FIXED** — the revert returns nil when it changed nothing (her Delete of the book since → retires) and its stamp; the redo revives only rows dead on that stamp. No door of hers converts back (the record's own note); O2 only by sync. No pin of its own (the revive-family pins cover the stamp key) |
| 25–34 | `Versions:217` Duplicate as Version · `:285` Make Outline Note · `:308` Promote Lens · `:430` Make Into a Note · `NoteVersions:58` Save a Version · `Import:75` (Import as a note) · `DocumentImport:88` (the single-file import) · `Ownership:328` Copy In · `MCPWrites:519` `create_note` / `create_structured_note` / `import_document` (a note) · `MCPCarriage:90` `save_version` | `revertMintedContainer` / `reapplyMintedContainer` → now `registerMintedContainerEntry` | **FIXED** — VX-119: the inverse returns the stamp it wrote (nil — R2-1 — when the note was already dead: retires), the redo revives only while the note is dead on THAT stamp (the F1 shape). O1 (her Delete, then ⌥⌘Z, ⇧⌥⌘Z) and the other-road O2 (a tombstone on another stamp — another device) both closed. Pins `anImportedNoteSheDeletedStaysDeleted`, `aCopySheDeletedStaysDeleted`, `aClientsNoteSheDeletedStaysDeleted`, `aRedoRevivesOnlyWhatItsOwnUndoTombstoned` |
| 35 | `DocumentImport:175` (a folder import — a book) | `revertImportedBook` / `reapplyImportedBook(undoneOn:)` | **SAFE (already F1)** — stamp-keyed since 13n-a; now truthful (`false` when the inverse tombstoned nothing, so the entry retires rather than carrying R2-1's old box) |
| 36 | `Import:100` Import (paste into a note) | `revertImportedBlocks` / `reapplyImportedBlocks` | **FIXED (parts)** — each half moves only the blocks its partner moved: a block she Put back from the tray between ⇧⌥⌘Z and ⌥⌘Z stays. Pin `importedBlocksLeaveTheBlockSheRestoredBetweenRedoAndUndo` |
| 37–39 | `Versions:332` Adopt Lens (`adoptLens`) · `:356` (`adoptLensPreservingChosen`) · `:407` (`adoptPicksPreservingChosen`) | `revertChosenPointers` (unconditional) → now `registerPointerEntry` | **FIXED** — VX-277: her adopt doors on the client's rule — per-slot compare-and-set (the undo never overwrites her later ✓) plus the slots record (her ✓ BACK on one slot is never re-chosen over by the redo). The old unconditional helpers (`revertChosenPointers`, `restoreChosenPointers`, `adoptUndoHalves`) are gone — no caller remained. Pins `herAdoptsUndoLeavesHerLaterCheckmarkAlone`, `herAdoptsRedoLeavesTheSlotSheSetBackAlone` |
| 40 | `MCPDeliberate:112` `choose_take` | per-slot compare-and-set → `registerPointerEntry` | **FIXED** — one slot: O1 (her ✓ back) closed by the stack; O2/O3 by the compare-and-set (unchanged). Family pin: the value probes |
| 41 | `MCPDeliberate:212` `adopt_lens` | `revertLensAdoption` / `reapplyLensAdoption` (+ the kept lens) | **FIXED (parts)** — the slots record and the kept lens's stamp; the redo re-adopts only the slots its undo walked back. Pin `aClientsAdoptRedoLeavesTheSlotSheSetBackAlone` |
| 42 | `MCPCarriage:41` `put_back` (a block) | `performDeleteBlock(quiet)` / `revertDeleteBlock` | **SAFE** — truthful both ways; her re-delete (`deleteBlock`) registers (LIFO); her Put back of a block the undo re-deleted: ⇧⌥⌘Z finds it live — quiet, retires (O4 by the stack) |
| 43 | `MCPCarriage:61` `put_back` (a take) | `performDeleteVariant(quiet)` / `restoreVariant` (catching `variantNotDeleted`) | **SAFE** — truthful (`false` on the catch); as 42 |
| 44 | `MCPCarriage:122` `set_entry_date` | `restoreEntryDate(from:to:)` ×2 | **FIXED** — round 1's compare-and-set (O2/O3) + the stack (O1/O4: her date set BACK). Family pins: the value probes |
| 45 | `MCPCarriage:176` `file_note_in_chapter` | `refileMembership(from:to:)` ×2 | **FIXED** — as 44 (exact row + compare-and-set, P-VX184-R1-2) |
| 46 | `MCPCarriage:337` `set_book_rule` | `restoreCollectingColumns` ×2 | **FIXED (parts)** — the columns record: a column she set BACK between ⌥⌘Z and ⇧⌥⌘Z is never re-written. Pin `aBookRulesRedoLeavesTheColumnSheSetBackAlone` |
| 47 | `MCPCommentAuthors:56` `delete_comment` | `reviveDeletedComment(deletedOn:)` / `redeleteComment` | **FIXED** — round 2's `redeleteComment` after her restore + a quiet undo: closed by the stack (the inverse's stamp key makes it quiet; it now says so). Family pins: the delete probes |
| 48 | `MCPEdits:166` `set_block_name` | `restoreBlockName(from:to:)` ×2 | **FIXED** — as 44 |
| 49 | `MCPEdits:207` `create_section` | `flipCreatedSection` ×2 → `tombstoneCreatedSection` / `reviveCreatedSection(undoneOn:)` | **FIXED** — O1 by the stack; the redo revives only on its undo's stamp (O2 on another road). Pin `aChapterSheDeletedStaysDeleted` |
| 50 | `MCPLibraryEdits:100` `rename_book` | `restoreBookName(from:to:)` ×2 | **FIXED** — the value family. Pins `renameBackToOriginalThenQuietUndoThenRedo`, `anUndoAfterAQuietRedoLeavesHerValueAlone` (O4) |
| 51 | `:168` `finish_book` | `revertFinishedBook(finishedOn:)` / `refinishBook` | **FIXED** — O1 (her reopen) by the stack. Pin `finishRedoAfterQuietUndo`. Residual unchanged (VX-184's record): her reopen-then-refinish before ⌥⌘Z is indistinguishable from the act's finish (no finish stamp on `reading`) |
| 52 | `:175` `reopen_book` | `refinishBook` / `reopenBookAgain` | **FIXED** — the mirror of 51, by the stack |
| 53 | `:251` `archive_book` | `revertArchivedBook(archivedOn:)` / `rearchiveBook` | **FIXED** — O1 (her unarchive) by the stack; the inverse was already stamp-keyed |
| 54 | `:308` `unarchive_book` | `restoreBookArchive` / `revertArchivedBook(original stamp)` | **SAFE (already keyed)** — the redo runs only on the archive's original stamp; now truthful |
| 55 | `:369` `delete_book` | `revertDeletedBook(deletedOn:)` / `redeleteBook` | **FIXED** — O1 (her Put back from the Trash) by the stack. Family pin `deleteNoteRedoAfterHerPutBackAndAQuietUndo` |
| 56 | `:432` `remove_note_from_book` | `reviveRemovedMembership(removedOn:)` / `reremoveMembership` | **SAFE (already keyed)** — her re-add mints a NEW row (`reremoveMembership` acts on the act's row only); now truthful |
| 57 | `:494` `move_note_in_book` | `restoreMembershipPosition(from:to:)` ×2 | **FIXED** — the value family (round 1 + the stack) |
| 58 | `:546` `rename_chapter` | `restoreChapterName(from:to:)` ×2 | **FIXED** — the value family |
| 59 | `:585` `delete_chapter` | `reviveDeletedChapter(deletedOn:)` / `redeleteChapter` | **FIXED** — O1 (her restore) by the stack. Pin `deleteChapterRedoAfterHerRestoreAndAQuietUndo` |
| 60 | `:631` `move_chapter` | `restoreChapterPosition(from:to:)` ×2 | **FIXED** — the value family |
| 61 | `:678` `delete_note` | `revertDeletedNote(deletedOn:)` / `redeleteNote` | **FIXED** — O1 (her Put back) by the stack. Pin `deleteNoteRedoAfterHerPutBackAndAQuietUndo` |
| 62 | `:743` `archive_note` / `unarchive_note` | `restoreNoteArchived(from:to:)` ×2 | **FIXED** — O1 (her unarchive back) by the stack; the compare-and-set on the stored stamp stays |
| 63 | `MCPNoteEdits:83` `edit_comment` | `rewriteCommentIfUnchanged(from:to:)` ×2 | **FIXED** — the value family (her words set BACK) |
| 64 | `:124` `restore_comment` | `redeleteComment` / `reviveDeletedComment(deletedOn:)` | **SAFE (already keyed)** — the precedent; now truthful |
| 65–66 | `:189` `delete_take` (the last take → the block) · `:195` `delete_take` | as 18 · as 17 | **FIXED** — as 18 / 17 |
| 67 | `:217` `archive_take` | as 16 | **FIXED** — as 16 |
| 68 | `:238` `unarchive_take` | `performArchiveVariant(quiet)` / `unarchiveTakeQuietly` | **FIXED** — the mirror of 16, by the stack |
| 69 | `:281` `set_take_label` | `restoreTakeLabel(from:to:)` ×2 | **FIXED** — the value family |
| 70 | `:335` `lock_take` / `unlock_take` | `setTakeLockQuietly` ×2 | **FIXED** — round 2's toggle: truthful (`setVariantLockRows(...).changed`), O1 closed by the stack. Pin `lockRedoAfterQuietUndo` |
| 71 | `:460` `rename_commit` | `restoreCommitMessage(from:to:)` ×2 | **FIXED** — the value family |
| 72 | `:520` `rename_note` | `restoreNoteTitle(from:to:)` ×2 | **FIXED** — the value family |
| 73 | `:558` `delete_lens` | `reapplySavedLens(undoneOn:)` / `revertSavedLens` | **SAFE (already keyed)** — no lens restore door of hers exists; now truthful |
| 74 | `MCPVersionLinks:84` `link_versions` | `revertVersionLinks` / `reapplyVersionLinks(undoneOn:)` | **SAFE (already keyed)** — now truthful |
| 75 | `MCPWingMove:101` `move_note_to_wing` | `revertMCPWingMove` / `reapplyMCPWingMove` | **FIXED** — round 2's nil `backwardStamp`: the redo no longer runs after a quiet undo (the stack); O2 (her move elsewhere after ⌥⌘Z) was already quiet (the redo requires the note in the source wing) |
| 76 | `MCPWrites:145` `add_take` | `revertAddedTake` / `reapplyAddedTake` | **FIXED** — O1 by the stack (her delete of the take); the redo now revives only on its undo's stamp. Family pin `aCommentSheDeletedStaysDeleted` (same shape) |
| 77 | `:231` `add_comment` | `revertAddedComment` / `reapplyAddedComment` | **FIXED** — as 76. Pin `aCommentSheDeletedStaysDeleted` |
| 78 | `:316` `save_lens` | `revertSavedLens` / `reapplySavedLens(undoneOn:)` | **SAFE (already keyed)** — now truthful |
| 79 | `:569` `apply_tag` | `revertAppliedTag` / `reapplyAppliedTag` | **FIXED** — O1 (her un-tag of the very application) by the stack; the redo revives only on its undo's stamp. Pin `aTagSheTookOffStaysOff` |
| 80 | `:616` `remove_tag` | `reapplyAppliedTag` / `revertAppliedTag` | **FIXED** — the mirror of 79: the undo revives only while the application is dead on the act's (then each redo's) stamp — her own re-tag mints a live twin the revival already deferred to |
| 81 | `:683` `create_book` | `revertImportedBook(posts: [])` / `reapplyImportedBook` | **SAFE (already F1)** — as 35 |
| 82 | `:726` `add_note_to_book` | `revertAddedMembership` / `reapplyAddedMembership` | **FIXED** — O2 for the SEAT: ⌥⌘Z demoted it to the door (wrote), her dismissal, ⇧⌥⌘Z used to re-seat the pair she decided; the redo now re-seats only while the row still waits at the door as the undo left it, and a fresh membership revives only on the undo's stamp. Pin `aSeatSheDismissedAfterTheUndoStaysDismissed`. Residual: the inverse writes `prior.position`/`section` back over a reorder of hers made after the seat (the act's result is the seat; recorded, not changed) |
| 83–84 | `MCPBatches:81` `add_takes` · `:131` `add_comments` | per-row halves | **FIXED (parts)** — `BatchParts` (the rows standing, each undone row's stamp). Pin `aBatchLeavesTheTakeSheRestoredBetweenRedoAndUndo` |
| 85 | `MCPCarriage`/`MCPEdits` acts that call HER ops (`divide_block`, `merge_blocks`, `move_block`, `delete_block`) | her ops' own entries (relabeled) | covered by rows 2–13, 18, 20–21 |

**The four sweep notes the brief asked to carry forward:** (1) VX-184's dated strike-throughs are honoured: every
"HOLLOW FOR THE UNDO HALF ONLY" row (lock, finish/reopen, archive/unarchive take) and every round-2 "FALSE of the redos
that act on ANY live row" (`rearchiveBook`, `redeleteBook`, `redeleteChapter`, `redeleteNote`, `redeleteComment`,
`reapplyMCPWingMove`) is now closed by the stack; (2) the round-1 ADJACENT CLASS (the revive redos) is FIXED twice over
(the stack for O1, the stamp key for the other roads); (3) VX-277's two halves (her adopt doors' value class; Delete
Block after a tray Put back) are FIXED and pinned; (4) VX-119's pair and every copy op riding it are FIXED, and the
F1 box's R2-1 nil rule is now enforced by the stack (a nil inverse retires its entry) as well as by each box.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u2`)

**Built:** `App/Variorum/DerivedData/vx246-u2` (the Debug app `io.lduarte.Variorum.debug` + the test bundle, from
`ef2ef588`'s sources plus the justified Mac test edit — rebuild first if the branch moved). **~110 min whole; batch-only
fallback ~50 min.**
0. **Guards, every step:** `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app` ABSENT — if present,
   STOP; never quit or kill it); `pgrep -fl 'Variorum.app/Contents/MacOS'` empty; then the claim line the GO relays;
   `guard.sh <devpid> x y` before each click; ≥ 2.6 s between synthetic events.
1. **The Mac batch (~50 min)** — `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS'
   -derivedDataPath DerivedData/vx246-u2` with `-only-testing:VariorumTests/<Suite>`, four groups:
   - **U2-A — every Mac suite that reaches the structural undo (113 suites in 43 files; grepped for `undoStack`,
     `UndoStack`, `structuralUndo`/`structuralRedo`, `StructuralUndoCopy`, `undo(with`/`redo(with`, `redoDepth`,
     `topLabel`):** BlockDeletionAndRedoTests · BlockHighlightTests · BlockHistoryPaletteDoorTests ·
     BlockSelectionRegistryTests · BlockSelectionRuleTests · BlocksWorkbenchTests · BlockTOCStatusTests · BlockTOCTests ·
     BoardBlockSelectionTests · BoardDeleteRedoSurvivalTests · BoardDeleteRollbackTests · BoardDeliveryPolicyTests ·
     BoardMergeDiagnosisTests · BookOrderConversionTests · BoundaryClampTests · BoundaryFluidityTests ·
     CanvasAndPoolTests · CanvasBoardGeometryTests · CanvasFocusedBlockFactTests · CanvasHostedRealizationTests ·
     CanvasOrderAndOverviewTests · CanvasRealizationTests · CanvasTakesSwitcherTests · CommandRouterTests ·
     CommitFlowTests · CompareCompositionTests · CompareViewModelTests · CrossBlockCompoundTests ·
     DestructiveUndoWarningTests · DifferentialApplyTests · DivideExtractGestureTests · DivideWCeremonyTests ·
     DocumentImportDoorTests · DropAndRefusalCopyTests · EditorSessionTests · EncryptionExplainedSeedTests · FanFlowTests
     · FannedDefaultsBoardTests · FannedDefaultsTests · FanReorderDoorTests · FragmentLinesTests · GestureSoakTests ·
     ImportFacesTests · JekyllTakemaniaSeedTests · JumpCorrectionLoopTests · LaunchFurnitureTests · LensesReorderTests ·
     MakeBlockGestureTests · MCPWingFacesTests · MenuFlightDoorAwaitTests · MergeArrangementTests ·
     MergeCeremonySheetTests · MergeGestureTests · MergeSelectionTests · MoveAndExecuteTests · NoteDeleteConfirmEdgeTests
     · NoteDeletionActTests · NoteDeletionDeclarationTests · NoteDeletionNavigateAwayTests · QuickNoteDoorTests ·
     QuickNoteMintTests · QuickNoteWindowTests · QuickNoteWordTests · QuitFinalizeSurfacesTests · ReturnKeyTraceTests ·
     ReturnKeyUndoSignTests · ReviewRound1FixTests · ReviewRound2FixTests · ReviewRound3FixTests · ReviewRoundFixTests ·
     SampleLibraryTests · SampleLibraryWelcomeTests · SealDoorTests · SeamMergeTests · ShellConfirmTests ·
     SoftNewlineTests · SpanToTakeDoorTests · SpanToTakeGesturePlanTests · SplitAtNewlinesDoorTests ·
     StaleWriteIntentTests · StatusCenterTests · StructuralRewriteDoorTests · StructuralUndoTests ·
     TakeCardMenuTitleTests · TakesBoardTests · TakesBufferConvergenceTests · TakesDivideTests · TakesFindReplaceTests ·
     TakesLandingTests · TakesPresentationTests · TakesReplaceRuleTests · TakesWordCountTests · the 13 Tutorial*
     suites in that set (TutorialBookShapeTests · TutorialBooksLessonTests · TutorialBooksRitualTests ·
     TutorialDeletionActsTests · TutorialDoorTests · TutorialFannedMatrixTests · TutorialLibraryActsTests ·
     TutorialLookingActsTests · TutorialMCPChapterTests · TutorialPrivacyChapterTests · TutorialStructureActsTests ·
     TutorialTakesActsTests · TutorialWherePlacesActsTests · TutorialWritingActsTests) · TypedReturnKeyTests ·
     UndoHintAndRefusalTests · WholeBlockDeleteTests · WriteBlockSelectionTests.
   - **U1's G1, G2, G3 exactly as U1's THE STAGE WINDOW lists them** (their overlap with U2-A runs once).
   - **Standing reds, named if met:** VX-167's `DestructiveUndoWarningTests.redoNeverAsks` (red only under in-process
     parallelism — re-run alone if met); VX-245's sites; VX-115's `BookCollectingDoorsTests` (not in the set).
   - **Watch for:** any suite whose assertion reads "Undid: …" after an undo that is now QUIET (a door test pressing
     ⌥⌘Z over an entry the world moved past) — that pin met the rule's new face; record it as a justified edit with
     the refusal's words, never a silent change.
2. **A1 prestage copy** of the dev store (U1's step 2, verbatim: every store file + the key files →
   `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified); the Debug app's prefs plist saved;
   her user-scope MCP servers read BEFORE (names + a fingerprint, never values). A What's New sheet: its own button. A
   lock screen: `source ~/.variorum/dev-castle.env`, those values only, posture restored before release.
3. **Leg W1 — her own door, the DELETE direction (VX-277), both voices:** launch (`open -n` the Debug app); a scratch
   note in Home with three short blocks ("One." / "Two." / "Three."). Delete block "Two." (its block ▾ ▸ Delete
   Block) → This Note's Tray ▸ Leaving ▸ Put back → ⌥⌘Z → **capture the refusal toast** ("Nothing to undo — Delete
   Block was already undone or changed since.") and the Edit menu open (its Undo/Redo items no longer name Delete
   Block) → ⇧⌥⌘Z → "No structural change to redo." → "Two." still on the page (capture). Then the NORMAL road on the
   same note: Delete "Three." → ⌥⌘Z (the receipt "Undid: Delete Block", the block back) → ⇧⌥⌘Z ("Redid: Delete
   Block", gone) — the ping-pong unchanged. Flip the voice (Settings ▸ Appearance) and capture the refusal again.
4. **The MCP road (U1's legs 3–4 detour — U1's core makes an untagged copy WAIT under an approved name, and no face
   can answer it yet):** in a scratch project, read the Clients list's `claude-code` row; if a `-s local`
   registration with its bound key no longer exists: the row ▸ Deny… (confirm) → Settings ▸ MCP ▸ Connect a client ▸
   Copy (an untagged key; first 9 characters recorded) → register it `-s local` as `variorum-dev` (`claude mcp
   add`, the JSON stanza's command + env by hand) → `claude mcp list` ✔ → the row ▸ Approve… → the grant sheet: EDIT
   on the scratch note's book… — simplest: EDIT on the scratch NOTE (always), cliclick, guarded.
5. **Leg W2 — the client's VALUE and TOGGLE directions, one real `claude -p --strict-mcp-config` turn:** ask it to
   `rename_note` the scratch note to "renamed by claude" and `lock_take` the take of block "One." (tee-captured
   tool answers). Then her own doors: retitle the note back to its old title (the title field) and unlock the take
   (its card ▾ ▸ Unlock). ⌥⌘Z → refusal "Nothing to undo — claude-code's take lock was already undone or changed
   since." (capture) → ⌥⌘Z → refusal for "claude-code's note title" (capture) → ⇧⌥⌘Z → "No structural change to
   redo." → her title and her unlock stand (capture).
6. **Leg W3 — the client's REVIVE direction, one `claude -p` turn:** `add_comment` on block "One." → her Comments
   panel ▸ delete that comment → ⌥⌘Z → refusal ("Nothing to undo — claude-code's comment was already undone or
   changed since.") → ⇧⌥⌘Z → nothing to redo → the comment stays deleted (the panel's deleted fold shows it once).
7. **Cleanup:** the `-s local` registration removed; her user-scope servers read AFTER (byte-identical fingerprint);
   the dev instance quit BY BUNDLE ID; the prefs restored; the dev store `Tools/ScaleFixture/restore.sh <dir>` →
   "Restored (verified)" (it also returns `claude-code`'s pre-window binding and approval); scratch keys deleted, the
   clipboard emptied, a whole-key grep over the evidence = 0; stray `default.profraw` removed; `Tools/stage release`;
   one result line. Evidence → `notes/plans/vx246-screens/u2/` (gitignored; keys redacted to 9 characters).

**Path check (`748b21d9^..HEAD`, this unit's commits):** `Sources/VariorumCore/Operations/` — `UndoStack.swift` + 27
`Operations+*.swift` files; `App/Variorum/Shared/StructuralUndoCopy.swift` and `App/Variorum/Variorum/Registry/ShellActions.swift`
(the Mac door's quiet words); tests (`UndoQuietPressTests`, `UndoStackQuietRuleTests`, the Mac `JumpAndUndoTests`
justified edit); this record. **ZERO** lines under `Sync/`, `Persistence/` (no schema), custody/Keychain/`Crypto/`,
`Server/`, the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `Shared/EditorBrain`),
or `Features/MCP/` (VX-281's lane) — grepped.

**Batch-only fallback (~50 min):** steps 0–1 alone; the walk legs move to the next window (the record then says the
acceptance unit is NOT closed — the brief's evidence includes the walk).

### SELF-ASSESSMENT (pre-stage — the implementer's)

**Against the brief:** the ONE RULE lives in one place — `UndoStack` — and every half of every entry (85) now answers
whether it changed anything, so a redo after a quiet undo never runs (and its mirror); entries with parts keep a record
of which parts their last half moved; revives are keyed on the stamp their own undo wrote (the F1 shape). The five
round-2 probes and one pin per family are red-first (22 of 22, then 23 of 23 with the diverge pin), red again by revert
with identical test×line sets, green after; the stack's own rule has three new-API pins. THE SWEEP TABLE dispositions
every registration. Headless whole package green (223/48 · 2,826/326 · 40/6) with every pre-existing pin UNMODIFIED;
one Mac test needed a justified edit (a toy inverse now answers `true`).
**Against the spec:** AppSpec §9's structural undo/redo ("each registration carries its inverse AND an exact-row
redo…") holds, sharpened: the redo now re-applies exactly what its undo un-did, never what the rows happen to read;
"undo and redo emit ordinary operations" holds (no new write road); "any new structural act clears the redo future"
and "undoing a `redo: nil` entry ends it" are unchanged; §12's "a door that did nothing speaks a refusal" now holds for
the structural doors. I1–I10, P1 (every half ∝ its own rows), S1–S5 untouched; zero `Sync/`, custody, schema,
`Server/`, editor seam, VX-281's lane (path-diffed below).
**Risks I see:** (1) **the truthfulness of 85 `Bool` answers** is the whole mechanism — a half answering `true` without
writing would quietly re-open the class for its entry; each was read and dispositioned, but a reviewer should
spot-check the per-entry records (structural parts, diverge, conversion, span-to-take, batches); (2) behaviour that
CHANGED on purpose, beyond the class: `revertDeleteVariant` / `revertArchiveVariant` no longer re-assert the default
pointer over a take her Put back or unarchive already brought back (they used to, which made the undo "write");
`restorePlacementLocation` no longer bumps `updated_at` when the placement is already there; the comments, takes,
tags, chapters, memberships and minted notes are revived ONLY on their undo's stamp (a row dead on another stamp — a
sync tombstone — stays dead); (3) the quiet-press refusal words are UNSEEN (no Mac run yet) and the phone still speaks
its receipt on a quiet press (OWED 2); (4) residuals recorded, not changed: `finish_book`'s indistinguishable
reopen-then-refinish (no finish stamp — VX-184's record), and `add_note_to_book`'s undo restoring the seat's
pre-image position over a reorder of hers made after it; (5) this session ran past the ~500k guideline (to ~690k) to
finish at a clean seam — the knowledge-bound pieces (the conversions and the sweep) could not move to a fresh session
cheaply (the resiliency note's 2026-08-31 clarification); every claim above is in a log or a commit.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX276-1 — what a QUIET half does to the stacks:** (a) AS BUILT — it retires its own entry and leaves the other
  stack as it was; (b) it also ends the redo future, as undoing a `redo: nil` entry does — stricter, it throws away
  redos her earlier presses earned; (c) the entry moves on marked quiet and its partner is a no-op (the house
  precedent's letter) — the Edit menu then offers a "Redo …" that does nothing (a false offer).
- **P-VX276-2 — a quiet press's kind:** (a) AS BUILT — a refusal (toasts), naming the entry; (b) a quiet receipt.
- **P-VX276-3 — PARTS:** (a) AS BUILT — an entry with several parts (slots, columns, blocks, rows, a merge's mint and
  released sources) re-applies exactly the parts its partner moved, so the undo/redo can walk PART of an act back and
  forth while her change to another part stands; (b) whole-entry — any divergence makes the whole entry quiet (simpler
  to explain; the parts she never touched become un-undoable).
- **P-VX276-4 — revives keyed on the undo's own stamp (the F1 shape) for every revive redo:** (a) AS BUILT — a row
  dead on any other stamp (her Trash after a Put back; another device's tombstone) is never revived by a redo; (b)
  revive any dead row the entry names (the pre-run behaviour for most entries) — would let a redo undo another
  device's delete.
- **P-VX277-1 — her own adopt doors on the client's per-slot rule:** (a) AS BUILT — the undo restores a slot only while
  it still shows the adopted take; (b) her doors restore every pointer unconditionally (the pre-run behaviour) — her
  later ✓ on an adopted block is overwritten by her own ⌥⌘Z.

### FOR VX-234 (user-facing words, as built)

1. **The structural undo door's quiet press** (Mac, the bottom bar's toast — a refusal): "Nothing to undo — ‹label›
   was already undone or changed since." (`StructuralUndoCopy.undoFoundNothing`; ‹label› is the entry's own name:
   "Delete Block", "Adopt Lens", "claude-code's note title"…).
2. **The structural redo door's quiet press:** "Nothing to redo — it changed again after ‹label› was undone."
   (`StructuralUndoCopy.redoFoundNothing`).
Both shared with the phone's door through `StructuralUndoCopy`, but the phone does not speak them yet (OWED 2).

### OWED (for the orchestrator)

1. **THE STAGE WINDOW** above (claim `vx246-u2`), on the GO; U1's batch rides it.
2. **MOBILE PARITY — the phone's quiet press:** `VariorumMobile/Features/Write/MobileUndoDoor.swift` still calls
   `undo(with:)`/`redo(with:)` and speaks "Undid: ‹label›" (with a Redo offer) on a quiet press; the fix is the Mac
   door's two lines (`undoReporting`/`redoReporting` + the two refusals) — a VM ticket (it needs a simulator stage).
   The rule itself (no redo after a quiet undo) already reaches the phone.
3. **Canon at the merge:** AppSpec §9's structural undo/redo bullet gains the contract line — "a half runs only after
   its partner changed something: an undo that finds its act's result already gone (her undo-less door, a sync apply)
   changes nothing, says so, and retires its entry; a redo re-applies exactly what its undo un-did (parts and stamps
   included), so it never writes over a change of hers" — with a pointer to this record; §12's status-seam line is
   already the letter for the refusal.
4. **The ladder's attention:** the per-entry records (THE SWEEP TABLE's FIXED (parts) rows) and the two default-pointer
   behaviour changes (Risk 2).


### THE ORCHESTRATOR ON U2's HAND-BACK (2026-10-14, ~00:20 MDT)

- **Accepted as reported.** Green suites were not re-run (rule 6).
  - The path check across `736d29e7..10223a2d` finds `UndoStack.swift`, 27 `Operations+*.swift` files, the Mac
    door's two App files (`Shared/StructuralUndoCopy.swift`, `Registry/ShellActions.swift`), one Mac test, and the
    record. There are zero lines in `Sync/`, `Persistence/`, custody/Keychain/`Crypto/`, `Server/`, the editor seam,
    or `Features/MCP/`.
- **The cutover.** The implementer handed back at ~634k context (the harness's count; ~690k by its own). It finished
  past the line, at a clean seam and on purpose: its argument is in its self-assessment, and it is accepted for the
  build. The stage window goes to a FRESH runner. Screenshots and a long window would push that session toward its
  limit while it held a claim and a prestaged store, which is the worst place for a session to fail.
- **The window, trimmed.** Steps 0–3 and 7 run now: the Mac batch (U2-A plus U1's G1–G3) and W1, her own door, in both
  voices, then the cleanup.
  - Steps 4–6 (the detour, W2 and W3) move to U1b's window. There the face connects `claude-code` through U1's leg 1
    with zero clicks, so the Deny → re-run → Approve detour on the old pane is never needed.
  - Nothing on the critical path waits for them: the ladder follows U8, which waits for VX-281's merge exactly as U1b
    does. U2's acceptance closes after U1b's window.
- **The PROVISIONALs.** P-VX276-1, -2, -3 and -4 and P-VX277-1 stand as built. Each is the defensible pick, and -2 is
  §12's own letter ("a door that did nothing speaks a refusal"). They go into QUESTIONS at the merge.
- **The two behaviour changes beyond the class are accepted, with the ladder's attention (OWED 4).** Each makes an
  undo truthfully report that it changed nothing when it changed nothing:
  - `revertDeleteVariant` / `revertArchiveVariant` are quiet when the take is already live or active;
  - `restorePlacementLocation` doesn't write when the block is already there.
- **The residuals go to the ladder, unticketed for now.**
  - `finish_book`'s reopen-then-refinish is the compare-and-set's recorded ABA: books carry no finish stamp, as
    VX-184's record says.
  - `add_note_to_book`'s seat undo restores the arrival's pre-image POSITION over a reorder of hers made after it.
    That reads as a part (P-VX276-3) the undo writes over. A reviewer that confirms it gets it fixed in the ladder's
    pass; otherwise it is dispositioned there.
- **OWED 2 is now VM-16** (the phone's quiet press). **OWED 3** (AppSpec §9's contract line) is carried to the
  closeout.

## U2 STAGE RUN — the trimmed window (a fresh stage runner, from 2026-10-14 ~00:20 MDT)

**What this run does NOT do (said first):** steps 4–6 of U2's THE STAGE WINDOW (the MCP detour, W2, W3) are NOT this
run's. They move to U1b's window (THE ORCHESTRATOR ON U2's HAND-BACK). No MCP client is registered or run here, so step
7's MCP-registration lines (the `-s local` removal, her user-scope servers read before/after, the key grep) don't apply.
No product code is changed under the claim. U2's acceptance stays OPEN until W2/W3 run.

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, the Stage traffic log,
U1's THE STAGE WINDOW (G1–G3 and its step 2's A1 text), U2's UNIT RECORD whole, THE ORCHESTRATOR ON U2's HAND-BACK;
`notes/SessionResiliencyProtocol.md`; `Tools/stage`, `Tools/WalkKit/` (`guard.sh`, `click.sh`, `keys.sh`, the README),
`Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); the memory notes walk-driving-lessons and
walk-restores-dev-store-posture. Code read for W1's words: `StructuralUndoCopy`, `ShellActions.structuralUndo/Redo`, the
quick-entry mint (`QuickEntryModel.submit` → `importPost`, `SegmentationRules.bulkSegments`: one line = one block under
paragraph segmentation), the Delete Block capability (menu bar Block ▸, palette, context menu) and the tray's door
(`TrayPath`, the note's inspector `tray` icon; tabs Leaving · Archived; `RecoveryCopy.putBackVerb` "Put back").

**The build check (before READY):** `git diff --name-only ef2ef588..HEAD -- Sources App` lists ONLY
`App/Variorum/VariorumTests/JumpAndUndoTests.swift` (the justified edit); the tree is clean; the built products in
`App/Variorum/DerivedData/vx246-u2` (the app and `VariorumTests.xctest`, 00:11:21) postdate every source, the test edit
included (00:09:44) → **no rebuild**. Host grants probed (no prompt): `AX: true SCREEN: true`. `Tools/WalkKit/wl2`
compiled (gitignored). Free disk 65 GiB.

**The batch's suite list:** the record's own names, extracted and diffed against the text: U2-A **110** names (the
plan's "113" counts differently; the 110 are exactly its listed names) + G1 18 + G2 22 + G3 11 = **148 unique** after
the overlap (the 14 Tutorial suites, `MCPWingFacesTests`). Every name is a declared type in `VariorumTests` (0 missing).
All Swift Testing. The list and the run script sit beside the evidence (`notes/plans/vx246-screens/u2/stage-suites-148.txt`,
`run-batch.sh`; gitignored).

**Two process choices, said here:**
- **The A1 prestage copy is taken BEFORE the batch** (the plan's step 2, moved up): the test host IS the dev-store app,
  so a copy taken after the batch could hold the batch's side effects. VX-184's close took its fallback copy at the same
  point for the same reason. The prefs export rides with it. After the batch the store is hashed against the copy; if
  it moved, that is recorded and the restore still returns the pre-window state.
- **The batch runs detached to its log and is POLLED IN THE FOREGROUND** (VX-184's close, the phase-19 precedent): one
  `xcodebuild` past the Bash tool's 10-minute limit can't run in a single foreground call. The turn never ends on it.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the suite list, this section → READY | DONE (this commit) — READY reported; the claim is the orchestrator's GO |
| 0 | guards on every step (`guard.sh --author`, `pgrep` empty, the claim line; `guard.sh <pid> x y` per click; ≥ 2.6 s between synthetic events) | DONE — every act went through `click.sh`/`keys.sh` (the author check, activate, the full guard), all OK, ≥ 2.6 s apart; her app never present; no system popup met. The GO from oct13coordinator; its exact line run: `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u2 --reason "VX-246 U2: 148-suite Mac batch + dev-store undo/redo walk (A1 prestage, verified restore)" --minutes 90` → **CLAIMED 00:23:24 MDT, 90 min**. Pre-claim: `guard.sh --author` OK (idle 585 s), no Variorum instance, no xcodebuild. The coordinator's posture to return to: **Standard, unlocked, Study voice** |
| 2 (moved up) | A1 prestage copy (every store file + key files → `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified) + `defaults export io.lduarte.Variorum.debug` | DONE (00:23) — **`…/Backups/safety-copies/scale-prestage-20261014T062331Z`**, five files each `cmp`-verified (sqlite `9bb8eef87116` · wal `c5beb92c1cf8` · shm `7ce060b13cfa` · keys `3af4704371ff` / `7e12a1b85890`, sha256 prefixes); prefs exported (1,548 keys, `appearanceChoice` = system) to `u2/prefs-pre.plist` |
| 1 | the Mac batch, 148 suites, one `test-without-building` (`run-batch.sh`), result bundle `u2/batch.xcresult`; a red re-run ALONE once; standing reds named | DONE (00:23:52 → 00:30:57) — **"✔ Test run with 1084 tests in 148 suites passed after 391.637 seconds"**, `** TEST EXECUTE SUCCEEDED **`, EXIT 0 (`u2/logs/stage-batch.log`). By the result bundle's type names (`u2/logs/stage-batch-by-suite.txt`, 148 rows, none outside the list): **U2-A 110 suites, 846 passed** · **G1 18 suites, 132 passed + 6 skipped** (the five gated capture harnesses, as U1's plan expected) · **G2 22 suites, 148 passed** · **G3 11 suites, 49 passed** → **1,078 passed, 6 skipped, 0 failed, 0 known issues**. No re-run was needed. No standing red met: VX-167's `DestructiveUndoWarningTests` 7/7 (`redoNeverAsks` green at this width); VX-245's and VX-115's suites are not in the set. **No "Undid: …" pin met the new quiet rule** (zero failures, so zero justified edits). The undo-reaching suites green, e.g. `BlockDeletionAndRedoTests` 29, `UndoHintAndRefusalTests` 13, `StructuralUndoTests` 2 (the justified `JumpAndUndoTests` edit among them). **The batch moved the dev store, as expected:** the test host opened it at 00:24, so wal `c5beb92c` → `0226d456` (3,415,512 → 3,448,472 bytes) and shm changed; sqlite and both key files unchanged. Five prefs keys moved (`IdleCommitSweepMark.Variorum-dev`, `currentBlock.0000…`, `variorum.backup.log`, `variorum.calmAsks.daysOfUse`, `…lastUseDay`). The A1 copy predates both, so the restore returns the pre-window state |
| 3 | W1 — her own door, the delete direction (VX-277), both voices | DONE (00:31 → 00:37), BOTH VOICES — **STUDY HALF** (the dev store's voice as found; captures `u2/w1/`). Launched `open -n` the vx246-u2 Debug app 00:31 (pid 51260, window 1380×900 at (60,36); no What's New sheet, no lock screen, Bookcase). The scratch note through the Bookcase quick-entry bar ("One." ⇧⏎ "Two." ⇧⏎ "Three." ⏎ — held-shift returns) → minted "2026-10-14", opened in Write, **block 1/3** (`01`, `02`); the Edit menu then read "Undo Import" (the mint's own entry). Caret into "Two." (block 2/3, `03`) → **menu bar Block ▸ Delete Block** → gone, its receipt "Block deleted — ⌥⌘Z puts it back, then in This Note's Tray…", Edit "Undo Delete Block" (`04`) → the note's tray icon → This Note's Tray ▸ **Leaving 1**: "Two." (`05`) → **Put back** → "Put back where it was.", "Two." on the page, Leaving 0 — and the Edit menu STILL read "Undo Delete Block" (`06`; the class's set-up) → **⌥⌘Z once → the REFUSAL toast "Nothing to undo — Delete Block was already undone or changed since."** (`07`, `07b`), "Two." stays; the Edit menu now "Undo Import" (enabled) · "Redo Structural Change" (DISABLED) — no item names Delete Block and no redo is offered (`08`, the menu open) → **⇧⌥⌘Z → nothing at all; "Two." still on the page** (`09`). **AS FOUND, not the plan's words:** the plan expected the toast "No structural change to redo.", but the menu item is `.disabled(topRedoLabel == nil)` (`App/Variorum/Variorum/EditorCommands.swift:576`, untouched on this branch vs `origin/main`), so on an empty redo stack the chord never reaches `ShellActions.structuralRedo()` and no sentence is spoken. The rule holds: the retired entry offers no redo, and nothing re-deletes "Two.". W2/W3 (U1b's window) will meet the same: "nothing to redo" there is a disabled Redo item, not a toast. **The normal road, unchanged:** caret in "Three." → Block ▸ Delete Block (`10`) → ⌥⌘Z → the quiet receipt **"Undid: Delete Block"**, "Three." back, Edit "Redo Delete Block" enabled (`11`) → ⇧⌥⌘Z → **"Redid: Delete Block"**, "Three." gone, the tray Leaving 1 holds it, Edit "Undo Delete Block" (`12`). **TERMINAL HALF:** Settings from the app menu (⌘, is the editor's), General ▸ Theme ▸ Terminal by AX (`13` Study before, `14` Terminal after), Settings closed by its own close button (`15`, the note in Terminal; the tray holding "Three.") → **Put back** "Three." → "Put back where it was.", Leaving 0, Edit still "Undo Delete Block" (`16`) → **⌥⌘Z once → the same REFUSAL, word for word, in Terminal: "Nothing to undo — Delete Block was already undone or changed since."** (`17`), "Three." stays, Edit "Undo Import" · Redo disabled → ⇧⌥⌘Z → nothing, "Three." stays (`18`). **W1's verdict: VX-277's delete direction PROVEN on her own doors in both voices** — after her Put back, ⌥⌘Z changes nothing, says so as a refusal naming the entry, retires it (the menu moves on to the next entry, Import), and no redo can re-delete her block; the normal Undid/Redid ping-pong is unchanged. The voice was not set back by hand: it lives in the store, and the restore below returns it (Study) |
| 7 | cleanup: the Debug app quit BY BUNDLE ID; prefs imported back (0 keys differ); `restore.sh` → "Restored (verified)"; stray `default.profraw` removed; `Tools/stage release`; one result line | DONE but the release (00:37–00:38) — the Debug app quit by `tell application id "io.lduarte.Variorum.debug" to quit` 00:37:23, `pgrep` empty. **Prefs:** the window had moved 9 keys (the batch's 5 + the Settings window frame, the open-notes memory, two `currentBlock.*`). `defaults import` of `prefs-pre.plist` MERGES, so it left the one key the walk ADDED (`currentBlock.5968B82C…`, the scratch note's caret) → `defaults delete` of that key → re-export: **1,548 keys, 0 differ**. **The dev store:** `Tools/ScaleFixture/restore.sh …/scale-prestage-20261014T062331Z` → **"Restored (verified)"** (`u2/logs/restore.log`); then each file `cmp`'d against the A1 copy → **all five SAME**, and the sha256 set equals the pre-window hashes (`store-hash-restored.txt` = `store-hash-pre.txt`) → the store is byte-identical to the state the coordinator handed over (Standard, unlocked, Study). The launch took no new backup into `Backups/`. No stray `default.profraw`; the tree clean. MCP lines N/A (no client registered). **RELEASED 00:38:15 MDT** (`Tools/stage release --who vx246-u2` → STAGE FREE), 35 of the 90 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx246-u2` 00:23:24–00:38:15 MDT, RELEASED; the Mac batch 1,084 tests in 148 suites passed (1,078 passed + 6 gated skips, 0 failed; U2-A 110/846 · G1 18/132+6 · G2 22/148 · G3 11/49); W1 PROVEN in both voices (her Put back, then ⌥⌘Z speaks "Nothing to undo — Delete Block was already undone or changed since.", the entry retires, no redo re-deletes; the normal Undid/Redid road unchanged); posture as left: **Standard/unlocked, cmp-SAME vs the A1 copy** (Study voice in the restored store), prefs 0 keys differ. **U2's acceptance stays OPEN for W2/W3 (U1b's window).**

## U3 UNIT RECORD — her editor vs the wire: VX-275 (opus-implementer, from 2026-10-14 ~01:00 MDT)

**What this unit has NOT done yet (said first; the state at READY, 2026-10-14 ~02:10 MDT):** (1) **no stage window has
run** — the eight Mac pins have never executed (their red-on-old run is W1, their green W2), no Mac batch, no live round
(THE STAGE WINDOW below, waiting on the GO); so the editor seam's caret fix is proven only by compile and by trace until
W1/W2; (2) the residual window is NOT closed (P-VX275-2 (a), accepted and recorded); (3) a model-driven client (Claude
Code) can never land a call inside her 500 ms debounce, so the live round's "pending keystrokes" half rides a scripted
client on the REAL shim (W3b) — Claude Code's turn (W3a) proves the navigate-away and the editor's half; (4) no
`notes/QUESTIONS.md` entry, no canon edit, no ticket minted (the merge's and the orchestrator's — the wider class's
ticket is the orchestrator's to mint from this report). Everything else is built, pinned red-first, red again by revert
(headless), and green headless.

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (AppSpec §9's standing conventions and
structural undo, §12's THE MCP DOOR line); this record's header, THE UNITS, the hard rules, LIVE STATUS, Cross-run
coordination (vx-282's file list), Her rulings during the run (VX-275's (a)), the U3 BRIEF, and U1's and U2's UNIT
RECORDs (skimmed for the tree: VX-258's keys and the waiting re-bind, VX-260's comment authorship, U2's
`UndoStack.Outcome` rule); the plan `notes/plans/mcp-pane-and-docs-kickoff.md` whole; the runway §2 (the conflict map —
"the navigate-away road", "the markdown face and the editor seam") and §3 (VX-246, VX-282, VX-283); VX-184's record —
THE `delete_note` / `delete_block` FLUSH TRACE whole, U4's and U5's traces and designs (where `delete_take`,
`restore_commit`, `lock_take`, `archive_take`, `delete_note` were built); `notes/TEXTKIT2_NOTES.md` whole (BEFORE any
editor-seam edit); `notes/SessionResiliencyProtocol.md` whole. Code read: `MCPWriteTools.call` and `perform` whole, every
`Job` family (`+Edit`, `+NoteEdits`, `+LibraryEdits`, `+Carriage`, `+Deliberate`, `+Batches`, `+CommentDelete`,
`+RemoveTag`, `+LinkVersions`), `MCPWriteSupport` (`MCPHostHooks`, `MCPWriteReceipt`), `MCPSession`'s call routing,
`MCPServerHost`; the core acts `editTakeUnderInsurance`, `divideBlock`, `mergeBlocks`, `deleteTakeForClient`,
`archiveTakeForClient`, `lockTakeForClient`, `restoreCommitForClient`, `deleteNoteForClient`, `autosave`,
`editableVariant`; the app's `MCPDoor` (attach, `reconcileServer`'s hooks, `landReceipt`), `NoteDeletion` whole,
`AppSession`'s coordinator registry (`autosave(forPost:)`, `flushExistingAutosave`, `flushEveryOpenPost`,
`heldPostIDs`, `releaseAutosave`), `AutosaveCoordinator` whole, `ShellActions.structuralUndo/Redo` and
`leaveNotesTheActLeftDead`, `WorkspaceModel.notesDeleted`, RootView's and NoteWindowView's listeners; the editor:
`EditorViewModel.applyProjection` / `applyPendingIfClean` / `caretIdentity`, `EditorProjectionPolicy.decide`,
`EditorSurfaceController.renderFull` / `applyDifferential` / `runStructural` / `applyStructuralResult` /
`deleteCaretBlock` / `runDeleteBlock` / `caretLandingAfterRemoving`, `BlockRangeIndex.caretLandingAfterRemoving`; her
Takes-board doors (`TakesViewModel.run`, `setTakeLocked`, `archiveTake`); vx-282's branch diff on the editor files
(read-only: `git diff origin/main...origin/vx-282-editor-notes-fixes` — it does NOT touch `renderFull`,
`applyProjection` or `applyPendingIfClean`); vx-281's branch diff on `MCPDoor.swift` (read-only — it does not touch
`reconcileServer`'s hooks).

**Surfaces (planned):** the wire `Sources/VariorumMCP/{MCPWriteSupport,MCPWriteTools,MCPWriteTools+Edit,
MCPWriteTools+NoteEdits,MCPWriteTools+LibraryEdits,MCPWriteTools+Carriage,MCPWriteTools+Deliberate,
MCPWriteTools+Batches}.swift` (the hook, the one await, each job's answer); one core doc line
(`Operations+MCPNoteEdits.restoreCommitForClient`'s "the wire has none to flush", false since this unit); the app
`App/Variorum/Variorum/Features/MCP/MCPDoor.swift` — **the hooks' construction lines only** (the brief's limit) — and a
NEW `App/Variorum/Variorum/Features/MCP/MCPDoor+HerEditor.swift` (outside VX-281's lane: not `MCPPane*`, `MCPPaneCopy`,
`MCPGrantSheet`); **THE EDITOR SEAM:** `App/Variorum/Variorum/Features/Editor/EditorSurfaceController.swift`
`renderFull` only (the caret by identity when the caret's block left — none of vx-282's listed functions); tests
(headless `Tests/VariorumMCPTests/`, Mac `App/Variorum/VariorumTests/`). ZERO `Sync/`, custody/Keychain, schema,
`Server/`, `BlockRangeIndex`, `PaneSurface`, the markdown face, `storageDidEdit`, the selection delegate, the carve.
The navigate-away rides THE ONE ROAD (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`) — no second road.

### LIVE STATUS — U3's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the traces and the design (before code) | DONE (this commit) |
| 1 | THE SEAM (behaviour-identical): `MCPHostHooks.beforeWrite` declared and never awaited; `MCPWriteReceipt.notesLeftDead` declared and never set; the door wired to both (`MCPDoor+HerEditor.swift` + the hooks lines) | DONE (this commit) — `MCPWriteSupport.swift`: `beforeWrite: (@Sendable (_ tool: String) async -> Void)?` (init param defaulted nil) and `notesLeftDead: [String]` (defaulted []); NOTHING calls or sets them yet. `MCPDoor.swift`: the hooks' construction only — `onWrite` → `landWireWrite`, `beforeWrite` → `flushHerEditorBeforeWrite` (3 lines + comments). NEW `MCPDoor+HerEditor.swift`: `flushHerEditorBeforeWrite()` = `session?.flushEveryOpenPost()`; `landWireWrite(_:)` posts `.variorumNotesDeleted` with `notesLeftDead` when non-empty, then `landReceipt` (unchanged). No test-support change needed: the headless pins drive `MCPWriteTools` directly (the `MCPEditServerTests` precedent) with their own turn-recording executor. `swift build` green |
| 2 | the pins FIRST, on the seam tree: headless (`MCPHerEditorServerTests` — the order, the act list, one per family) RED, counts recorded; Mac (`MCPHerEditorDoorTests` through the real door + `ExternalBlockRemovalCaretTests`) written and COMPILED (build-for-testing into `DerivedData/vx246-u3-red` — the red-on-old product, run at W1) | DONE (`b5f46670` the pins; this commit the red product's build and one warning fixed). **Headless RED on the seam tree (`f3093e6d`'s sources): 12 of 13 tests failed, 26 issues** (log `notes/plans/vx246-screens/u3/logs/p2-pins-red.log`, gitignored), every one on its designed line, no premise line: the order (2 — no flush before `delete_block`'s or `delete_note`'s turn), the act list (1 — none of the 11 listed acts asks), TOMBSTONE `delete_note` 3 · `delete_block` 3 · `delete_take` both roads 3 (her words not in the tombstone, her flush refused, the undo returns the take without them), FREEZE `lock_take`+`archive_take` 4 (the stale text, the insurance commit holds it, her bytes refused), REWRITE `edit_take` 3 (the stale edit LANDED, answered success, and registered an entry) · `restore_commit` 2 (the "before" commit insures the stale row; her debounce writes back over the restore), STRUCTURE `divide_block` 1 ("Second half" reads twice) · `merge_blocks` 1 (her words left the note), COPY `save_commit`+`save_version` 2 (both miss her last words), the navigate-away FACT 1 (`delete_note`'s receipt names nothing); **the SAFE characterization `aPointerMoveNeverNeedsHerFlushAndLosesNothing` green, by design** (it pins what the fix must not change). The Mac pins (`MCPHerEditorDoorTests` 4 through the real door and a socket client; `ExternalBlockRemovalCaretTests` 4, one of them a by-design characterization) are written. **DONE — the red-on-old Mac product BUILT** (no claim — a build): `App/Variorum/DerivedData/vx246-u3-red` (an APFS clone of `vx246-u2`, then `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0; logs `u3/logs/mac-red-build.log`, `mac-red-build-2.log`). Its sources are THIS commit's — the seam, the pins, NO fix — so it IS the pre-fix tree with the pins: W1 runs the eight Mac pins against it. The one new warning the first build showed was mine (a `Notification` captured in the observer's `@Sendable` closure, `MCPHerEditorDoorTests`) — fixed in this commit and the product rebuilt; zero warnings in a touched file now. (The clone's ~4,200 "Stale file … outside of the allowed root paths" lines are the cloned build database naming `vx246-u2`'s paths — noise, not warnings of the code; 190 real warnings, the standing set as recompiled whole.) |
| 3 | THE FIX (the wire): `Job.flushesHerEditorFirst` (exhaustive, every job family answers), the one await in `MCPWriteTools.call` before `executor.run`, `delete_note`'s receipt names the dead note; the core doc line → headless GREEN, every existing suite unmodified | DONE (this commit) — `MCPWriteTools.call`: after `parse`, `if job.flushesHerEditorFirst, let beforeWrite = hooks.beforeWrite { await beforeWrite(job.tool) }`, then `executor.run` as before. `Job.flushesHerEditorFirst` and one per family (`EditJob`, `CarriageJob`, `DeliberateJob`, `BatchJob`, `NoteEditJob`, `LibraryEditJob`) — exhaustive switches, no `default`; TRUE exactly for the record's IN rows: `edit_take`, `divide_block`, `merge_blocks`, `delete_block`, `save_version`, `save_commit`, `delete_take`, `archive_take`, `lock_take` (lock only — `.lockTake(_, locked)` answers `locked`), `restore_commit`, `delete_note`. `delete_note`'s receipt: `notesLeftDead: [noteID]`. Core: `restoreCommitForClient`'s doc no longer says "the wire has none to flush". **GREEN:** `MCPHerEditorServerTests` **13/13** (`u3/logs/p3-pins-green.log`); the whole MCP target **236 / 49**, zero failures, every existing pin UNMODIFIED (= U2's 223/48 + these 13/1; `p3-mcp-target.log`) |
| 4 | red again BY REVERT (announced first, on a committed tree; restored and verified) | DONE (announced `0a60d647`, recorded in this commit) — on the committed tree `9a96d46c` the seven wire files of the fix went back to the pins commit `29a53c38` (`git checkout 29a53c38 -- <the seven>`; `git diff HEAD --stat` named exactly those seven, −119/+1), the pins kept → **RED again: 12 of 13 failed, 26 issues, the test × line set IDENTICAL to piece 2's** (diffed: 26 lines, no difference; `u3/logs/p4-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/VariorumMCP/`, `git diff HEAD -- Sources` empty → 13/13 green (`p4-restored.log`). The editor seam's revert is the red product itself (W1 — the Mac pins run against `vx246-u3-red`, whose sources are the pre-fix tree) |
| 5 | THE EDITOR SEAM: `renderFull` lands the caret by her Delete Block's rule when the caret's block left the projection | DONE (this commit) — `EditorSurfaceController.renderFull`: reads `caretLanding(whenBlockLeft:oldEntries:survivors:)` from the OLD tiling before the rewrite (nil while the caret's block survives); after the rewrite, when the caret's block is gone, lands by identity on the answer — the block below's START, else the block above's END. The new `nonisolated static func caretLanding` is pure (one pass over the old tiling; only blocks the new projection holds count). No attribute stamp is added (the rewrite and its attributes are `renderFull`'s, unchanged); `BlockRangeIndex`, `runStructural`, the carve and every vx-282 function untouched (`git diff origin/main -- <vx-282's files>` shows this hunk in `renderFull` and the new helper only). **The Mac product with BOTH fixes BUILT:** `App/Variorum/DerivedData/vx246-u3` (an APFS clone of `vx246-u3-red`, then `build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0; 188 warnings — the standing count — NONE in a touched file; `u3/logs/mac-build-for-testing.log`). **PENDING the stage:** `ExternalBlockRemovalCaretTests` red on `vx246-u3-red` (W1), green on `vx246-u3` (W2) |
| 6 | headless finals (core · MCP · workbook) + the Mac `build-for-testing` into `DerivedData/vx246-u3` | DONE (this commit) — **the whole package, `swift test --skip-build` on `e43024c1`'s sources, EXIT 0: `VariorumMCPTests` 236 / 49 · `VariorumCoreTests` 2,826 / 326 · `StringsWorkbookTests` 40 / 6**, zero ✘ (MCP = U2's 223/48 + `MCPHerEditorServerTests` 13/1; core and workbook unchanged — the core change is one doc line); the skipped set IDENTICAL to U2's finals (9 lines, diffed — the standing gated suites only) (`u3/logs/p6-finals.log`). **The Mac `build-for-testing`** (piece 5): `DerivedData/vx246-u3`, `** TEST BUILD SUCCEEDED **`, 188 warnings, none in a touched file |
| 7 | THE STAGE WINDOW plan (claim `vx246-u3`; W1 red on old, W2 green + the batch, W3 the live round) → READY | DONE (this commit) — THE STAGE WINDOW below (~60 min, claim 80; batch-only fallback ~20 min, claim 30); the scripts and the suite list beside the evidence (`notes/plans/vx246-screens/u3/run-w1-red.sh`, `run-w2-batch.sh`, `stage-suites-215.txt`, `driver.py` — gitignored); **READY for stage** (the stage NOT claimed — the orchestrator's GO) |

**No revert is in flight** (piece 4's ran and was RESTORED — `git diff HEAD -- Sources` empty).

### The traces (written before code)

**1. THE MECHANISM, re-traced on this tree (VX-184's trace holds, line for line).** Inputs → wrong state:
(1) She types in a note's take. Every surface on a post shares ONE `AutosaveCoordinator` (`AppSession.autosave(forPost:)`
— Write `EditorViewModel.swift:49`, Takes, the block TOC, Compare, Canvas, the book's Index edit model); `record`
(`AutosaveCoordinator.swift:106`) holds the WHOLE take text as pending and schedules a 500 ms debounce; the row still
holds the last flush. (2) A client's write is ONE runner turn: `MCPWriteTools.call` parses, then
`executor.run { perform }` (`MCPWriteTools.swift:43–44`) — the app's executor IS `session.runner`
(`MCPDoor.swift:27`). `Sources/VariorumMCP` holds no flush and `MCPHostHooks` (`MCPWriteSupport.swift:107`) has no seam
for one (`refusalWords`, `onAsk`, `onWrite`, `now`, `show`, `wingMoveFrozenWords`). (3) The act reads and writes the
STORED rows. (4) The debounce fires: `flushNow` (`:142`) → `ops.autosave` → `editableVariant`
(`Operations+Variant.swift:479`: live, not archived, not locked, placement unsealed). A refusal puts the entry BACK
(`:160`) — `isDirty` stays true, `showOperationError` speaks it — and while dirty the editor defers every projection
(`EditorViewModel.swift:837`, `EditorProjectionPolicy.decide`'s `busy` arm), so her text stays on screen, IN MEMORY
only. Nothing retries by itself; ⌘Q's `savepointOnLeaving` flushes, is refused again, and the bytes die with the process.
**Her doors are the contrast:** `NoteDeletion.report` flushes the named notes FIRST (`NoteDeletion.swift:173–174`), acts,
then posts `.variorumNotesDeleted` (`:191`); `runStructural` flushes first and fences the keyboard for the flight
(`EditorSurfaceController.swift:2927–2950`); `BlockHistoryPane.restore`, `commitCaret` (⌘S), `VersionActs` and
`runCopying` flush first. The wire does neither half.

**2. THE ACT LIST — every write tool, argued (IN = the pre-act flush runs; the brief's "argue the act list").** The test
of an act: after it lands, does her pending flush (a) get REFUSED (bytes stranded in memory), (b) write her old buffer
OVER the act or into a row the act left behind, or (c) does the act SNAPSHOT the store without her last words?

| family | tools | the wrong state on this tree, traced | IN? |
|---|---|---|---|
| TOMBSTONE | `delete_note` (`tombstoneNoteFamily`), `delete_block` (`deleteBlock`), `delete_take` both roads (`deleteVariantRows`; the LAST take → `deleteBlockRows`) | her take is tombstoned on one stamp; her flush → `liveVariant` throws `variantNotFound` → stranded; ⌥⌘Z / Put back return the take WITHOUT her bytes (the tombstone never carried them) | **IN** (the ticket's three) |
| FREEZE | `lock_take` (`setVariantLockRows`, insuring the STORED text), `archive_take` (`archiveVariantRows`) | her flush → `lockedVariant` / `archivedVariant` → stranded exactly as a tombstone strands them; `lock_take`'s insurance commit captures the stale stored text, not hers | **IN** (the same refused-flush class — VX-275's "her pending keystrokes are refused and live only in memory") |
| REWRITE | `edit_take` (`expected_text` vs STORED, `Operations+MCPEdits.swift:86`), `restore_commit` (no precondition; its "before" commit insures the STORED text) | the act lands over the stale row; her flush then writes her whole buffer OVER it — the client was told it landed, the take silently reads hers again (insured only in the act's "after" commit) | **IN** (the wider class) |
| STRUCTURE | `divide_block` (`divideBlock`'s `expectedText` = the shown take's STORED text, `:299`), `merge_blocks` (`mergeBlocks` reads both STORED chosen takes) | divide (one take): A keeps identity as the first half, so her flush writes the WHOLE old block + her typing into A — the second half reads twice (runStructural's named "text-duplication class"); a fanned divide or a merge RELEASES her block (`last_container_id`, unplaced), her flush lands in that lineage block (unplaced ⇒ `ensurePlacementUnlocked` passes) — her words leave the note | **IN** (the wider class) |
| COPY | `save_commit` (`commitTakeForClient` snapshots `working_text`), `save_version` (a full family copy) | the commit / the version misses her last words while answering success; nothing is lost (her words stay in the live take), but her own ⌘S (`commitCaret`) and her own Save Version (`VersionActs`: "a caller whose act READS or COPIES the store … must consult it") flush first | **IN** (her doors' rule, applied) |
| SAFE — text untouched | `add_take`, `add_takes`, `add_comment(s)`, `delete_comment`, `edit_comment`, `restore_comment`, `save_lens`, `delete_lens`, `set_block_name`, `set_take_label`, `unarchive_take`, `unlock_take`, `rename_commit`, `rename_note`, `create_note`, `import_document`, `create_book`, `create_section`, `apply_tag`, `remove_tag`, `link_versions`, `add_note_to_book`, `file_note_in_chapter`, `set_book_rule`, `set_entry_date`, `put_back`, the twelve book/chapter/membership acts, `archive_note`/`unarchive_note`, `move_note_to_wing` | none of them reads, rewrites, copies, freezes or kills a take's `working_text`; her pending flush lands where she typed it (comments and titles are drafts committed on her own act — `CommentsPanel.commitEdit`, `PostDetailView.rename` — never the coordinator's pending text, so they are outside this class) | OUT |
| SAFE — pointer or place | `move_block` (same variant, another place or note), `choose_take`, `adopt_lens` | her flush still lands in the take she typed in (live, active, unlocked); the editor's deferred projection then shows the new arrangement — nothing of hers is overwritten or lost | OUT |
| BOOKS | `delete_book` (book only — an owned book's notes go to the Pool, alive), `archive_book`, `finish_book`, `remove_note_from_book`, `delete_chapter` (memberships keep their pointer) | **no wire act takes a note down with a book or chapter** — `deleteReadingWithNotes` / `archiveReadingWithNotes` are hers alone (R-VX184-2); her text in a member note lands normally | OUT (the brief's "any book or chapter act that takes notes down" — there is none on the wire) |

**3. THE NAVIGATE-AWAY.** Of the wire's acts, only `delete_note` leaves a note dead (the table above; `save_version`
mints, `move_note_to_wing` keeps it live, the undo/redo of a client's create or import is HER door, which WA-3's
`leaveNotesTheActLeftDead` already covers). `delete_note`'s receipt is delivered through `onWrite` and nothing posts
`.variorumNotesDeleted` (`MCPDoor.swift:372` → `landReceipt` only), so a pane and the Open strip stand on the tombstone
(the code's own record: `NoteDeletion`'s header, WA-3's reason).

**4. `delete_block` UNDER HER CARET — the editor seam.** With the flush FIRST, her bytes are stored and her coordinator
is clean when the act lands, so the delivery that follows takes the projection road every external change takes:
`applyProjection(fromDelivery:)` → `.refetchFresh` → `applyPendingIfClean` → a fresh read → `.fullRender` →
`renderFull(new, preserveTail: true)` — the SAME rewrite her own Delete Block uses (`runDeleteBlock` →
`runStructural` → `applyStructuralResult(seam: nil)` → `renderFull`). The range is dropped by the existing road; no
second structural door is needed (`runStructural` stays the one structural door — the wire's act is not a gesture of
hers). **The one difference is the caret:** her door lands the caret BY IDENTITY on the block below's start, else the
block above's end (`caretLandingAfterRemoving`); `renderFull` restores the caret by identity only when its block
SURVIVES (`EditorSurfaceController.swift:179`), so when the caret's block left, the wholesale storage replacement parks
her insertion point at the DOCUMENT'S END (renderFull's own row-49 record) — her next keystroke lands at the note's end.
**The fix:** in `renderFull`, when the caret's block is not in the new projection, land by her Delete Block's rule —
the first block BELOW the caret's in the old tiling that survives, at its start, else the first surviving block ABOVE,
at its end — read from the old index before the rewrite (the rule `BlockRangeIndex.caretLandingAfterRemoving` states,
asked at the caret's own position; `BlockRangeIndex` itself untouched). It reaches every external removal of the caret's
block (a sync apply, another window), which all share the same parking today. **Attribute stamps:** the edit adds none
(the rewrite and its attributes are `renderFull`'s, unchanged); TEXTKIT2 §3's clamp rule is untouched. **Her own acts are
unchanged:** `applyStructuralResult` re-lands the caret on its outcome after `renderFull`, as before.

**5. THE RESIDUAL WINDOW.** The flush is its own runner turn and the act is the next one; between the flush's capture
(`flushNow`'s `let batch = pending`) and the act's commit the main actor is free, so a keystroke typed in that window is
pending again. Its length: one MainActor hop back to the session's task plus the runner's queue — normally well under a
few milliseconds; longer only while the runner holds other work. **What happens to such a keystroke:**
- after a TOMBSTONE or FREEZE act: exactly today's stranding, narrowed to those few characters — refused, kept pending in
  memory (spoken), landed by a later flush only if ⌥⌘Z (the client's entry) or Put back revives the take in this
  session; lost at ⌘Q otherwise. For `delete_block` the editor also stays dirty, so the dead block stays on screen
  until then (the pre-fix experience, for the window's characters only).
- after a REWRITE or STRUCTURE act: her next flush writes her buffer over the act (or into the released block) — but
  only when the client's precondition still matched her flushed text, i.e. she was NOT typing in that take before the
  flush and began inside the window. The act's own "after" commit (edit/restore) insures the client's words.
- after a COPY act: the commit/version misses those characters; nothing is lost.
**Closing it is not cheap:** the only complete close is a keyboard fence over every open editor for the act's flight
(`runStructural`'s `isEditable = false` + `beginDeferringKeystrokes`, generalized to every surface the coordinator map
names, released after the act's projection lands, her deferred keys replayed at the landed caret) — an editor-seam
change across Write, Takes panes, the book's Index and Compare. A second flush AFTER the act cannot help (a refused
write stays refused; a landed one is the overwrite). **PROVISIONAL P-VX275-2** below; (a) is built.

### The design (argued)

1. **The hook — `MCPHostHooks.beforeWrite: (@Sendable (_ tool: String) async -> Void)?`**, awaited in
   `MCPWriteTools.call` AFTER the arguments parse and BEFORE `executor.run`, only for a job whose
   `flushesHerEditorFirst` is true. Its own turn, never inside the act's (the act's body is synchronous on the runner;
   the app's flush is itself a runner turn). A malformed call never flushes (it never reaches the hook). Nil = no app
   around the host (headless hosts flush nothing).
2. **The list is the `Job`'s, answered by EVERY job family through an exhaustive `switch` with no `default`** — a future
   tool cannot compile without saying whether it meets her text (U2's sweep principle; U5's `insert_blocks` and U6's
   `duplicate_note` will have to answer — the latter is a COPY).
3. **The app's flush — `session.flushEveryOpenPost()`, not the per-note `flushExistingAutosave(forPost:)` the brief
   names** (PROVISIONAL **P-VX275-1**; both are `coordinator.flushNow()`, the house's two entries to one act). Why every
   open post: (i) **no address resolution outside the act's transaction** — a block, take, commit or comment id would be
   resolved to its note BEFORE the act's turn, a second read racing the act's own (the decide/act gap AF-10 (a)'s guard
   closed); (ii) **no oracle** — the resolution would run before the grant decision, so how long a call takes would say
   whether she is typing in a note the client cannot reach (F-7); flushing every open post costs the same whatever id is
   named; (iii) **coverage without a resolver per tool** — `move_block` across notes, `merge_blocks`' two blocks, U6's
   copies; (iv) **the house's precedent for exactly this** — `flushEveryOpenPost`'s own doc (13e E10): a source "named
   by a block, not by a post … Flushing every open coordinator answers it without a lookup, and costs nothing when
   nothing is pending" — ∝ the notes open, never the corpus (P1). Her Delete door's posture rides too: the flush's
   outcome is not consulted (a refused write keeps its bytes pending, exactly as before); the act lands.
4. **The navigate-away — a FACT on the receipt, posted on THE ONE ROAD.** `MCPWriteReceipt.notesLeftDead: [String]`
   (default empty), set by `delete_note` to its note. The door's `onWrite` hop posts `.variorumNotesDeleted` with those
   ids (exactly what `NoteDeletion` posts — the named ids; each window filters to its panes) and then lands the receipt.
   A signal, never a decision (P-4). No second road: VX-283's VX-123 builds on this one.
5. **The editor seam — `renderFull`'s caret** (trace 4). A pure helper over the old tiling and the new projection's
   block ids, so the rule is pinnable; `renderFull` lands by identity on its answer when the caret's block left.
6. **Words:** none new. The wire's answers and refusals are unchanged (a stale `edit_take` hears the op's existing
   `bufferChangedSinceGesture` in her words). **FOR VX-234: nothing** (no pane word changes).

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX275-1 — the flush's reach:** (a) AS BUILT — every open post (`flushEveryOpenPost`), before every listed act;
  (b) the brief's wording — only the act's own note(s) through `flushExistingAutosave(forPost:)`, resolved from the
  act's ids before its turn (a read outside the act's transaction, and a timing oracle on unreachable ids); (c) (b) with
  the resolution moved after the snapshot decision — the act split into two runner turns (decide, then flush, then act),
  re-opening the decide/act gap the guard closes.
- **P-VX275-2 — the residual window:** (a) AS BUILT — accepted and recorded (milliseconds; a keystroke in it meets
  today's behaviour, narrowed to those characters); (b) a keyboard fence over every open editor for the wire act's
  flight (`runStructural`'s fence generalized, keys deferred and replayed at the landed caret) — closes it, at the cost
  of an editor-seam change across every live surface and her typing paused for each wire write; (c) refuse a wire
  TOMBSTONE/FREEZE act while the app holds unflushed text for that take (a "the author is typing there" refusal — the
  product call VX-184's trace offered as option (b), not ruled; she ruled (a)).

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u3`)

**Built (no rebuild unless the branch moved — check `git diff --name-only e43024c1..HEAD -- Sources App`):**
- `App/Variorum/DerivedData/vx246-u3-red` — the RED-ON-OLD product: the seam and the pins, NO fix (sources = `29a53c38`'s
  App/Sources; the record commits after it touch docs only). It runs ONLY W1.
- `App/Variorum/DerivedData/vx246-u3` — the FIXED product (both fixes, `e43024c1`'s sources): W2 and W3.

**Estimate ~60 min of work → claim 80 min** (W1 ~4 · W2 ~15 · W3a ~20 · W3b ~12 · cleanup ~6). **Batch-only fallback (~20
min, claim 30):** steps 0, W1, W2 and the release — the live round then moves to the next window.

0. **Guards, every step:** `Tools/stage status` shows the claim held; `Tools/WalkKit/guard.sh --author` (her
   `/Applications/Variorum.app` ABSENT — if present, STOP and report, never quit or kill it); `pgrep -fl
   'Variorum.app/Contents/MacOS'` empty before any test run; every GUI act through `click.sh` / `keys.sh` (the author check,
   then `guard.sh <devpid> x y`), synthetic events ≥ 2.6 s apart (the self-trip rule). An undismissable system popup →
   reported word for word, the window paused.
1. **W1 — RED ON OLD (~4 min):** `zsh notes/plans/vx246-screens/u3/run-w1-red.sh` (the two Mac suites against
   `vx246-u3-red`; detached to its log if it runs long, POLLED IN THE FOREGROUND — never a turn ended on it). **Expected,
   by design:** `MCPHerEditorDoorTests` **4 of 4 red** — delete_note (her words not in the tombstone; no navigate-away
   signal within the 5 s settle; Put back without them), delete_block (the tombstone without her words; her editor still
   dirty, the dead block's range kept, the caret still in it), edit_take (the stale edit ANSWERED SUCCESS), divide_block
   ("Second half" twice after her debounce); `ExternalBlockRemovalCaretTests` **3 of 4 red** (the caret parked at the
   document's end / in the tail) and the survivor characterization GREEN. Every issue read against its designed line; a
   red on a PREMISE line (a `#require`, the door never serving, the socket client failing) is a harness defect — STOP the
   window after cleanup and report, nothing fixed under the claim.
2. **W2 — GREEN + THE MAC BATCH (~12–15 min):** `zsh notes/plans/vx246-screens/u3/run-w2-batch.sh` — 215 suites on
   `vx246-u3`: the eight new pins, every suite in a test file that mounts the full-document editor (`renderFull` runs at
   every editor's first render and every structural result — 96 files), every Mac `MCP*` suite (the door's hooks), the
   note-deletion, autosave and projection families (`stage-suites-215.txt`; 93 of them ran green in U2's window). Detached,
   polled in the foreground. Read: the summary line, every `✘`, the `skipped:` lines (the gated capture suites expected
   skipped). **A red not designed:** re-run ALONE once (`-only-testing:VariorumTests/<Suite>/<test>()`); green alone + a
   named load-flake class (VX-167, VX-279) ⇒ recorded as that class; reproduces alone ⇒ a REAL regression: the window
   proceeds to cleanup and the release, and the report carries the test, its message and the trace — nothing fixed here.
3. **A1 PRESTAGE + LAUNCH (~3 min):** the dev store's files + key files → `…/Variorum-dev/Backups/safety-copies/
   scale-prestage-<ts>/` (the stage.sh copy loop without its fixture launch; each file `cmp`-verified; sha256 recorded); the
   Debug app's prefs exported (`defaults export io.lduarte.Variorum.debug`); her user-scope Claude servers read (names + a
   fingerprint of `~/.claude.json`'s `mcpServers`, never values). `open -n` the `vx246-u3` Debug app; its pid by PATH. A
   What's New sheet → closed with its own button; a DEV lock screen → `source ~/.variorum/dev-castle.env` and unlock with
   exactly those values (never echoed, logged, captured or written), posture restored before release.
4. **W3a — A REAL CLAUDE CODE TURN (~20 min, Study first):**
   - **Connect `claude-code` — U1's detour, the existing faces' road** (U1b's face is NOT on this branch: the app still
     mints untagged keys, so a re-run setup under a bound, approved `claude-code` WAITS for an OK no pane can give; if U1b
     has merged into this branch by the window, skip the detour and copy from the Claude Code tab instead — say which):
     Settings ▸ MCP — **leg 0, the posture read** (the server running; `claude-code`'s row: approved? bound? its grants),
     captured → `claude-code`'s row ▸ **Deny…** (confirm) → Connect a client ▸ Claude Code ▸ **Copy setup command** (the
     key's first 9 characters recorded) → in a scratchpad project the copied line with `-s user` → `-s local`:
     `variorum-dev` (the REAL Debug shim) → `claude mcp list` ✔ Connected (a denied name binds the fresh key) → the row ▸
     **Approve…** → the grant sheet. **NO standing grant yet** — the grants come from her note doors below.
   - **Two scratch notes** through the Bookcase quick-entry bar (U2's W1 recipe, held-shift returns): **"vx275 a"** —
     "Alpha one." ⇧⏎ "Alpha two." ⏎; **"vx275 b"** — "One." ⇧⏎ "Two." ⇧⏎ "Three." ⏎. Each note ▸ `note ▾` ▸ **Share with
     AI…** → claude-code · Edit · Always (her grant road; the sheet's words captured once).
   - **Her panes:** "vx275 a" open in pane 1, "vx275 b" beside it (Open Beside) in pane 2, both in Write; in "vx275 a"
     type " She was typing here." at the end of "Alpha two." (then ≥ 600 ms pass — her debounce lands it; said plainly:
     a model's call cannot arrive inside 500 ms, so THIS turn proves the navigate-away and the editor's half, and W3b proves
     the pending half); the caret placed in "Two." of "vx275 b" (click), the note bar reading its block "2/3". Capture.
   - **ONE `claude -p --strict-mcp-config` turn** (`--allowedTools` `mcp__variorum-dev__list_notes`,
     `…__read_note`, `…__delete_block`, `…__delete_note`): "In Variorum, in the note 'vx275 b' delete the block 'Two.'; then
     delete the note 'vx275 a'." **Expected:** both served, `isError` false; pane 2's "Two." GONE with the caret at the
     START of "Three." (the note bar "2/2"; capture) — her Delete Block's landing; pane 1 LEFT "vx275 a" (it shows the
     Library; the Open strip has no "vx275 a" row; capture) — THE ONE ROAD; the receipt lines "claude-code deleted a block…"
     and "…deleted a note…" (capture). Then the Trash ▸ "vx275 a" ▸ **Put back** → its text reads "Alpha one." / "Alpha two.
     She was typing here." (capture); This Note's Tray on "vx275 b" ▸ Leaving ▸ "Two." ▸ **Put back** (capture).
   - **Terminal:** Settings ▸ General ▸ voice Terminal; repeat with fresh notes "vx275 c" (as a) and "vx275 d" (as b) —
     grants, panes, ONE turn naming c and d, the same captures. (The voice lives in the store; the restore returns it.)
5. **W3b — HER PENDING KEYSTROKES, the real shim and a scripted client (~12 min, Study):** `notes/plans/vx246-screens/u3/
   driver.py` (stdlib Python, `python3 -I`): it spawns the Debug build's REAL `Contents/MacOS/variorum-mcp` with a copied
   setup key in `VARIORUM_MCP_KEY` (as every setup the pane copies), initializes as **`vx275-driver`**, finds the note by
   title through `list_notes` (and the block through `read_note` with ids), prints READY, then fires its ONE call the
   instant a trigger file appears — milliseconds after her last keystroke.
   - **The driver's door:** Connect a client ▸ **Any MCP client** ▸ Copy (key's first 9 recorded) → `VARIORUM_MCP_KEY=…
     python3 -I driver.py <shim> vx275-driver hello x` (a first contact — her pane shows the request) → its row ▸
     **Approve…** → the grant sheet: the HOME wing · Edit · Always (the dev store; restored after).
   - **delete_block while she types:** a fresh note **"vx275 e"** ("One." ⇧⏎ "Two." ⇧⏎ "Three." ⏎) open in Write; the
     driver armed (`… driver.py <shim> vx275-driver delete_block "vx275 e" "Three." <scratch>/go-e`, background, READY read
     from its stderr); the caret clicked to the end of "Three."; then IN ONE Bash call `Tools/WalkKit/keys.sh <pid>
     'keystroke " pending words"'`, `python3 -I -c 'import time;print(time.time())'` (the moment her typing ended), and
     `touch <scratch>/go-e` → the driver's answer (`isError` false, `fired_at`, `answered_at`). **The timing is the
     evidence:** `answered_at` − the typing's end < 0.5 s ⇒ the act landed INSIDE her debounce, so only the pre-act flush
     can have saved her words (if a leg comes in over 0.5 s it proves nothing about the hook — re-run it once) → capture:
     the block gone, the caret at the END of "Two." (no block below — the block above's end). This Note's Tray ▸ Leaving ▸
     "Three. pending words" ▸ Put back → **"Three. pending words"** on the page (capture) — her keystrokes, typed
     milliseconds before the delete, survived it.
   - **delete_note while she types:** a fresh note **"vx275 f"** ("Fresh line." ⏎) open in Write, the caret at the end of
     its line, the driver armed for `delete_note "vx275 f"`; the same one-call keystroke + time + trigger (the same < 0.5 s
     reading) → the pane leaves the note (capture) →
     the Trash ▸ "vx275 f" ▸ Put back → **"Fresh line. pending words"** (capture).
   - Both voices are covered by W3a's faces; W3b is the pending half's evidence (Study). **Optional, only if minutes
     remain (the red contrast on the real app):** quit, `open -n` the `vx246-u3-red` app, repeat the delete_block leg once →
     the Put-back block WITHOUT " pending words" (capture), quit.
6. **CLEANUP (~6 min):** the `-s local` registrations removed (`claude mcp remove -s local …`), her user-scope servers read
   AFTER (the fingerprint byte-identical to step 3's), the driver's key and setup lines deleted, the clipboard emptied, a
   whole-key grep over `vx246-screens/u3/` and the scratchpad = 0 files; the Debug app quit BY BUNDLE ID (`tell application
   id "io.lduarte.Variorum.debug" to quit`; `pgrep` empty; no socket left); the prefs: `defaults import` of step 3's export
   + `defaults delete` of every key the walk ADDED (`import` merges — U2's finding) → re-export, **0 keys differ**; the dev
   store `Tools/ScaleFixture/restore.sh <the prestage dir>` → "Restored (verified)" and a second `cmp` of every file (the
   posture the coordinator handed over: Standard, unlocked, Study); stray `default.profraw` removed; **`Tools/stage release
   --who vx246-u3`** at once; then ONE result line for the orchestrator (claim times, W1's red counts, W2's totals, W3's
   verdicts, the posture as left). Evidence → `notes/plans/vx246-screens/u3/` (gitignored; keys redacted to 9 characters).

### SELF-ASSESSMENT (pre-stage — the implementer's)

- **Confident:** the mechanism (traced line by line on this tree, and every family's wrong state reproduced headless —
  the red counts are the trace made executable); the seam's ORDER (the flush awaited before `executor.run`, structurally
  outside the act's synchronous body, pinned by the turn log); the act list (each tool argued, the exhaustive switches
  make a future tool answer); THE ONE ROAD (the door posts exactly what `NoteDeletion` posts — the named ids — and the
  listeners are unchanged).
- **Less sure, said plainly:** (1) the Mac pins and the editor-seam fix have only compiled — their first run is W1/W2;
  the socket client in `MCPHerEditorDoorTests` is new test plumbing (a detached task per read so the main actor stays free
  for the hook) and may need a harness adjustment at W1 if a premise line trips; (2) `renderFull`'s landing is the house
  rule asked at the caret's block — a MERGE elsewhere lands on the first surviving block below (her text's new home, the
  merged block, is a NEW id the old tiling cannot name); better than the document's end, not the merged block itself (a
  recorded limit, below); (3) P-VX275-1 departs from the brief's wording (every open post, not `flushExistingAutosave` for
  the act's note) — argued, and the options are listed; (4) the flush runs before the grant decision, so an act that then
  refuses still flushed her text: harmless (her own text into her own store, what her debounce does 500 ms later), and
  the timing it exposes is "something was pending somewhere", never which note; (5) a wire flush IN FLIGHT at the very
  instant she presses a structural gesture makes `runStructural`'s own flush find the coordinator busy, so it refuses
  "Unsaved changes couldn't be written — resolve that first, then retry." — the SAME race her own debounce's flush has
  always had (a debounce flush in flight at her press), one more occasion for it, milliseconds wide; recorded, not
  pinned. **MOBILE PARITY:** nothing mobile-visible — the MCP door is Mac-only and the phone's editor is untouched.
- **Recorded limits (not defects of this unit):** the residual window (P-VX275-2); her own Takes-board Lock / Archive /
  Delete-take doors run without a flush (`TakesViewModel.run` — "flushing before every ops call would make every board
  door pay") — the same refused-flush class may reach HER doors when she clicks within 500 ms of typing into that take
  (NOT traced to a repro here — OWED 2); comments and titles are drafts committed on her own act, outside this class; a
  book deleted under her book surface has no navigate-away road of its own (her own book Delete door neither — not this
  ticket's class, notes stay alive).

### FOR VX-234 (user-facing words, as built)

Nothing. No pane word, receipt, refusal or tool description changed; a stale `edit_take` hears the op's existing
`bufferChangedSinceGesture` words.

### OWED (for the orchestrator)

1. **The wider class's ticket** (the brief: "I mint its ticket from your report"): *"MCP rewrites, restructures, freezes
   and copies read the STORED row, never her pending buffer — `edit_take` landed on a stale row and her next flush wrote
   over it (the client was told it landed); `restore_commit` likewise, its 'before' commit insuring the stale row;
   `divide_block` (one take) left her whole old block in the first half — the second half read twice; `merge_blocks` and a
   fanned divide released her block, so her flush landed outside the note; `lock_take`/`archive_take` refused her flush —
   stranded like a delete; `save_commit`/`save_version` missed her last words. Fixed in VX-246 U3 by the same pre-act
   flush as VX-275 (every listed act; the list argued in the record's U3 trace); pins `MCPHerEditorServerTests` (one per
   family, red 26 issues on the seam tree, red again by revert) and the Mac `MCPHerEditorDoorTests` (edit_take, divide)."*
2. **A possible sibling on HER doors (not traced to a repro — for a ticket or a dismissal):** the Takes board's Lock,
   Archive and Delete-take doors call the op without flushing (`TakesViewModel.run`, by design for cost); if she types into
   a take's pane and clicks its Lock within the 500 ms debounce, the lock's insurance commit holds the stale row and her
   flush is refused (the same class, on her own door). Worth one red-first probe before anyone fixes it.
3. **VX-283 (VX-123) builds on this road:** the wire's navigate-away now rides `.variorumNotesDeleted` from
   `MCPDoor.landWireWrite` (fact: `MCPWriteReceipt.notesLeftDead`). VX-123's sync applies and `deleteReadingWithNotes`
   should post on the same road, never a second.
4. **The Fable cold review** of the editor seam (CLAUDE.md): `EditorSurfaceController.renderFull` + `caretLanding` — the
   orchestrator's to run after the units.
5. **Canon at the merge (proposed, not written):** AppSpec §12's THE MCP DOOR line could gain one clause — "a wire act
   that meets a take she may be typing in (delete, lock/archive, edit/restore, divide/merge, commit/version) lands her
   pending typing first, as her own doors do, and a wire note delete sends every pane off the note".

### THE ORCHESTRATOR ON U3's HAND-BACK (2026-10-14, ~01:40 MDT)

- **Accepted as reported.** Green suites were not re-run (rule 6).
  - The path check across `0e2bd140..61ec7723` finds: `Sources/VariorumMCP` (the hook and the per-job answer); one
    core doc line; the app's `MCPDoor.swift` (9 lines, the hook construction) and the new `MCPDoor+HerEditor.swift`;
    `EditorSurfaceController.swift` (+41: the external-removal caret landing); and the Mac and headless pins.
  - There are zero lines in `Sync/`, `Persistence/`, custody, `Server/`, VX-281's lane, or vx-282's listed functions.
  - The ONE editor-seam file is `EditorSurfaceController.renderFull` plus its pure `caretLanding(whenBlockLeft:…)`.
    The Fable review owes it a look (OWED 4).
- **vx-282 was told** about the new caret-landing occasion, the runway's "saying so". Its answer, ~01:45: no rule
  collision. VX-290 left `caretLandingAfterRemoving`'s rule as it was (start of the block below, else end of the
  block above; pinned by `CarveCaretLandingTests`' guard case); it changed only the seam carve's landing. Expect a
  comment-only conflict near `caretLandingAfterRemoving`'s and `runDeleteBlock`'s doc comments. Keep both: their
  wording plus our function.
- **The cutover.** The implementer handed back at ~620k context, so a FRESH runner takes the window, as with U2.
- **The PROVISIONALs stand as built.**
  - P-VX275-1: `flushEveryOpenPost` rather than a per-note flush, because per-note would resolve ids before the
    grant's decision (a timing oracle).
  - P-VX275-2: the residual window is accepted and recorded.
  - Both go into QUESTIONS at the merge.
- **The OWED items.**
  - OWED 1 is now **VX-323**, a member, born and fixed here.
  - OWED 2 is now **VX-324**, Todo, outside the run: a probe comes first.
  - OWED 3: VX-123 got a comment about the one road.
  - OWED 4, the Fable review, is the orchestrator's, after the units.
  - OWED 5, the §12 clause, goes to the closeout.
- **The window runs whole** (W1 the red-on-old Mac pins, W2 the batch, W3a Claude Code by U1's detour, W3b the
  driver). The editor-seam fix has never run on a Mac, so its evidence shouldn't wait for U1b.

## U3 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14 ~01:35 MDT)

**What this run does NOT do (said first):** no product code is written or changed, under the claim or before it. A red
that needs code is recorded and reported, never fixed here. U1b's face is not on this branch, so W3a takes U1's detour
(Deny → re-run → Approve), never the Claude Code tab's tagged key. No canon, QUESTIONS or ticket edits.

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, the Stage traffic log,
ORCHESTRATOR'S PROVISIONAL RULINGS (ruling 1 — W3b's scripted client); U1's THE STAGE WINDOW (step 2's A1 text, step 5's
Deny → re-run → Approve detour); U2 STAGE RUN whole; U3's UNIT RECORD whole (THE STAGE WINDOW, THE ORCHESTRATOR ON U3's
HAND-BACK); `notes/SessionResiliencyProtocol.md`; `Tools/stage`, `Tools/WalkKit/` (README, `guard.sh`, `click.sh`,
`keys.sh`, `wl2`, the two Swift helpers), `Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); U3's
`run-w1-red.sh`, `run-w2-batch.sh`, `stage-suites-215.txt`, `driver.py`; the memory notes walk-driving-lessons and
walk-restores-dev-store-posture. Code read for the window: the Mac pins' harness (`MCPHerEditorDoorTests` — in-memory
store, its own socket home); the pane's Clients rows, request rows and setup menu (`MCPPane.swift`); the grant sheet
(`MCPGrantSheet.swift` — the approval's "nothing yet" place, the radio groups); the setup command's text
(`MCPPaneCopy.setupCommand`).

**The build check (before READY):**
- **No source moved since either product was built.** `git diff --name-only e43024c1..HEAD -- Sources App` is EMPTY.
  No `.swift`/plist/pbxproj/xcstrings/`Package.swift` under `Sources` or `App/Variorum` is newer than the fixed product's
  `Variorum.debug.dylib` (01:18:46). No test file moved since the red product's commit (`git diff --name-only
  29a53c38..HEAD -- App/Variorum/VariorumTests Tests` empty). The tree is clean.
- **Each product is what its name says, read from its symbols** (`nm` + `swift demangle`):
  - `DerivedData/vx246-u3-red` (dylib 01:11:43, before the fix commit `9a96d46c` at 01:13:45): the seam present
    (`flushHerEditorBeforeWrite` 7), the fix ABSENT (`flushesHerEditorFirst` 0, `caretLanding(whenBlockLeft:…)` 0), both
    pin suites in its test bundle.
  - `DerivedData/vx246-u3` (dylib 01:18:46): the seam 7, the wire fix (`flushesHerEditorFirst` 28), the editor-seam
    fix (`caretLanding(whenBlockLeft:…)` 15), both pin suites.
  - **→ no rebuild.**
- **The W2 list:** `run-w2-batch.sh`'s 215 `-only-testing` names diffed against `stage-suites-215.txt`: IDENTICAL, 215
  unique.
- **Host and tools:** grants probed with no prompt, `AX: true SCREEN: true`; `walk-cap`/`walk-scroll` compiled into the
  scratchpad; `Tools/WalkKit/wl2` present; Claude Code 2.1.299, Python 3.12.13, `cliclick` present. Free disk **47 GiB**.
- **Her user-scope MCP servers, read now (names + a sha256 prefix of the `mcpServers` block, never values):**
  `['linear-server', 'variorum']`, `bc64543e2f4e8e58`. No user-scope `variorum-dev` exists, so a scratch project's
  `-s local variorum-dev` shadows nothing of hers. Re-read at the window's start and after cleanup.
- **Never run the copied setup line as copied:** it begins `claude mcp remove -s user variorum-dev; claude mcp add -s
  user …`. Only its key is taken (from the clipboard, redacted to 9 characters in every record); the registration is
  rebuilt `-s local` in a scratch project.

**Process choices (U2's lessons applied):**
- **The A1 copy, the prefs export and the user-scope fingerprint come FIRST, before W1** (the test host is the dev-store
  app).
- **W1 and W2 run detached to their logs and are POLLED IN THE FOREGROUND.**
- **Every GUI act goes through `click.sh`/`keys.sh`,** at least 2.6 s apart. **The Debug app is quit by bundle id.**
- **The prefs are restored by import, then a re-export and a diff,** deleting every key the window added, until 0 differ.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the GO's exact line) |
| 0 | guards on every step; the claim from the GO's line | DONE — the GO from oct13coordinator; its exact line run: `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u3 --reason "VX-246 U3: pins + 215-suite batch + dev-store live round (A1, MCP fingerprint)" --minutes 90` → **CLAIMED 02:18:04 MDT, 90 min**. Pre-claim: `guard.sh --author` OK (idle 364 s), no Variorum instance, no xcodebuild. **The tree had moved after the build check:** HEAD `3d1c5dd6` (U4's paused commits — `EditorViewModel.refreshBadges`, `ShelfViewModel`, tests). At the coordinator's word, NO rebuild: the window runs on the two products exactly as built (`vx246-u3-red`, `vx246-u3` — U3's tip sources, verified by symbol above). The coordinator's posture to return to: **Standard, unlocked, Study, the tour offer completed** (vx-282's walk, 02:12) |
| 1 | A1 prestage copy (every store file + key files, each `cmp`-verified, sha256 recorded) + `defaults export io.lduarte.Variorum.debug` + her user-scope fingerprint BEFORE | DONE (02:18) — **`…/Backups/safety-copies/scale-prestage-20261014T081813Z`**, five files each `cmp`-verified (sha256 prefixes: sqlite `088275b387ef` · wal `e961fd26b8bb` · shm `257bfc77563f` · keys `3af4704371ff` / `7e12a1b85890`; `u3/store-hash-pre.txt`); prefs exported (**1,549 keys**, `appearanceChoice` = system) to `u3/prefs-pre.plist`; her user-scope servers BEFORE: `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** (`u3/userscope-pre.txt`) |
| W1 | `run-w1-red.sh` — the eight Mac pins against `vx246-u3-red`; expected `MCPHerEditorDoorTests` 4/4 red, `ExternalBlockRemovalCaretTests` 3/4 red + the survivor characterization green; every issue read against its designed line | DONE (02:18:23 → 02:19:19) — **RED ON OLD, exactly as designed: 7 of 8 tests failed, 17 issues** ("✘ Test run with 8 tests in 2 suites failed after 6.999 seconds with 21 issues (including 4 warnings)", `u3/logs/w1-red-on-old.log`, `u3/w1-red.xcresult`). **`MCPHerEditorDoorTests` 4 of 4 red, 14 issues:** delete_note 6 (`:274` her words still pending after the act · `:275` no `.variorumNotesDeleted` within the settle · `:276` · `:278` a pane still on the tombstone · `:280` the Open strip still holds it · `:283` Put back WITHOUT "And the last thought."); delete_block 5 (`:303` the tombstone without " Typed." · `:305` still dirty · `:309` the index keeps the dead block · `:310` the document still reads it · `:312` the caret not on the block below's start); edit_take 2 (`:329` the stale edit ANSWERED SUCCESS · `:332` it registered "claude-code's edit"); divide_block 1 (`:350` "Second half" twice). **`ExternalBlockRemovalCaretTests` 3 of 4 red, 3 issues** (`:47` caret offset not 0 on the block below · `:68` the block above's end not landed · `:92` the landing did not skip the blocks that left with hers); **`aCaretWhoseBlockSurvivesKeepsItsPlace` GREEN** (the by-design characterization). **No premise line tripped:** every `#require`, the door's `settle` on `.running`, the socket client, the "her words are still pending" premise and the served answers (`isError == false`) all held. **The 4 warnings** are not issues of the pins: "@Dependency(\.withRandomNumberGenerator) has no test implementation, but was accessed from a test context" (`WithRandomNumberGenerator.swift:59`, test «unknown»), raised during the divide pin's run — recorded as found; W2 reads whether the fixed product shows them too |
| W2 | `run-w2-batch.sh` — 215 suites on `vx246-u3`; a red re-run alone once; standing reds named (VX-167, VX-245, VX-115) | DONE (02:19:35 → 02:25:41) — "✘ Test run with **1470 tests in 215 suites** failed after 322.350 seconds with 7 issues (including 4 warnings)" (`u3/logs/w2-batch.log`, `u3/w2-batch.xcresult`): **1,457 passed · 12 skipped · 1 failed**. **The eight pins GREEN on the fixed product:** `MCPHerEditorDoorTests` 4/4 (delete_note, delete_block, edit_take, divide_block) and `ExternalBlockRemovalCaretTests` 4/4. **The one red is VX-167's standing one:** `DestructiveUndoWarningTests.redoNeverAsks()` (3 issues, `:141–143`, under the batch's parallelism) → **re-run ALONE once (02:25:53): ✔ passed** (`u3/logs/w2-rerun-redoNeverAsks.log`) — recorded as VX-167's load-flake class, not a regression. The 12 skips are the gated set: the 7 UNKEYED-oracle singleton tests (`VARIORUM_ORACLE_SINGLETON_WINDOWS` off) and the 5 capture harnesses (MCPAsksWait/GrantSheet/GrantSheetU2/ShareFaces captures). VX-245's and VX-115's suites are not in the set. **The 4 warnings recur on the fixed product, the same text as W1's** ("@Dependency(\.withRandomNumberGenerator) has no test implementation, but was accessed from a test context", test «unknown», while `MCPHerEditorDoorTests` ran): a harness noise of the NEW door pins (something on the served socket's side reads the dependency outside the pin's `withDependencies` scope), not an issue of any test — reported for the orchestrator, nothing changed under the claim |
| 3 | launch `vx246-u3` (`open -n`); a What's New sheet closed by its own button; a lock screen per the env file | DONE (02:26:50) — pid 3355, window 1380×900 at (60,36), **Study, light, the Bookcase; no What's New sheet, no lock screen** (`u3/w3a/launch/w0.png`) |
*[removed for publication]*
*[removed for publication]*
*[removed for publication]*
**THE FINDINGS (for the orchestrator — none fixed, none touched under the claim):**
- **FINDING A — a wire note delete in the OTHER pane takes her focus.** `WorkspaceModel.notesDeleted` re-routes each pane on
  the dead note with `select(.library, in: pane)`, and `select` sets `focusedPane = pane` (`WorkspaceModel.swift:186`). So when
  a client deletes the note in the pane she is NOT in, her focus jumps to that pane (now the Library) and her own note falls to
  the read tier. Seen in both voices (`w3a/18`–`20`, `39`). The road is shared with her own Delete door, but there she is
  usually in the pane she deletes from. A product call (keep her focus where it was?), likely VX-283's road or its own ticket.
- **FINDING B — the Library at half width overlaps the other pane.** With a split open, the Library catalog drawn in the right
  pane extends left past the divider and covers the left pane's edge, clipping its header ("clicl"; `w3a/18`–`26`, `30`, `39`).
  Layout, not this unit's. A ticket if it isn't known.
- **FINDING C — the red product did NOT strand her words on the live `delete_block` road.** On `vx246-u3-red` there was no
  refusal toast, the page dropped the block, and both the tray and the store after Put back held "Three. pending words". The
  `delete_note` road DID lose them (above). The headless and Mac pins hold the debounce still, and the live app does not. Where
  the words went between the tombstone and the revive (a flush into the tombstoned take, or an in-memory pending overlay that
  Put back's door then flushed) is unexplained on this evidence. Worth one trace before the record calls `delete_block`'s
  stranding half proven live. The fix's live `delete_block` evidence (W3a's caret, W3b's 53 ms leg) stands either way.
- **The 4 dependency warnings** in W1 and W2 come from the new door pins' harness (`withRandomNumberGenerator` read outside the
  pin's `withDependencies`). Test-only noise.
- **Two plan deviations, said:** (1) claude-code's grant was ONE wing grant (Home · Edit · Always) instead of a per-note Share
  with AI…; (2) the Terminal half's turn was split in two to see the caret live before Finding A's focus move. W3b ran in
  Terminal.

**THE RESULT LINE (for the coordinator):** claim `vx246-u3` 02:18:04–02:54:00 MDT, RELEASED.
- **W1** red on old as designed: 7 of 8 failed, 17 issues (door pins 4/4, caret pins 3/4, the survivor green, no premise line).
- **W2:** 1,470 tests in 215 suites: 1,457 passed, 12 gated skips, 1 failed. The one red is VX-167's standing `redoNeverAsks`
  under parallelism, green when re-run alone. The 8 pins are green.
- **W3a PROVEN, both voices**, with a real Claude Code 2.1.299 turn via U1's detour: the caret lands at the start of the block
  below, the pane leaves the dead note, and Put back returns her words.
- **W3b PROVEN** with the timing driver on the real shim: answered 0.053 s (`delete_block`) and 0.051 s (`delete_note`) after
  her last keystroke, and both Put backs returned " pending words". The red contrast lost them on `delete_note`.
- **Posture as left: Standard/unlocked, cmp-SAME vs the A1 copy** (Study voice in the restored store), prefs 0 keys differ.
- The MCP fingerprint is SAME (`bc64543e2f4e8e58`), the scratch project's `-s local` server is gone, and the key grep finds 0.
- The A1 copy `scale-prestage-20261014T081813Z` is the coordinator's to prune. Findings A–C go to the orchestrator.

## U4 UNIT RECORD — the faces after big writes: VX-230 · VX-231 (opus-implementer, from 2026-10-14 ~02:15 MDT)

**What this unit has NOT done (said first; the state at READY, 2026-10-14 ~03:10 MDT):** no pin has run — every pin is a
Mac pin, so its red-on-old run is W1 and its green W2; both fixes are written and both Mac products are built, but
nothing has run on a Mac; no stage window has run (no batch, no walk); ORCHESTRATOR'S PROVISIONAL RULING 2 (the
navigate-away keeps her focus) is NOT built here — its slot in the window is marked for the fresh session that builds it;
no QUESTIONS entry, canon edit or ticket (the orchestrator's). No `notes/QUESTIONS.md` entry, canon edit or ticket (the merge's and the orchestrator's). Zero
`Sync/`, custody, Keychain, schema or `Server/` lines planned.

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (OverallModel §5 P1–P3, AppSpec §4 and
§12's editor language: "a corner badge only on fanned blocks"); this record's header, THE UNITS, the hard rules, LIVE
STATUS, the stage traffic log, Cross-run coordination (vx-281's and vx-282's lanes), the U4 BRIEF, and U1–U3's UNIT
RECORDs and STAGE RUN sections (skimmed for the tree and the window shape); `notes/plans/mcp-pane-and-docs-kickoff.md`
whole; VX-184's U1 UNIT RECORD (LIVE STATUS, THE STAGE WINDOW, THE LIVE ROUND — leg (d)'s two sightings — and OWED
4a/4b); `notes/plans/phase-13n-a-document-format.md`'s WALK-FIX PASS (WA-3, WA-4 — VX-122's trace); **`notes/TEXTKIT2_NOTES.md`
whole, BEFORE any editor-seam edit**; `notes/SessionResiliencyProtocol.md` whole; her two screenshots
(`~/shots/shot-20261013-022301.png` — Write, block 1 of 160 with its caret, a BLACK filled disc at block 1's badge place
while every other block wears its own muted ⑂2; `~/shots/shot-20261013-174949.png` — the book "o ladrão de raios" in
Outline, the focused note's live inline editor ("this note · editing"), ONE black disc at block 1's badge place and
**no badge on any other visible block**, though most of them are fanned). Code read: `EditorViewModel.refreshBadges` /
`refreshDecorations` / `overlayLayoutDidSettle` / `attach` / `viewportBounds` / `restoreReadingAnchor` / the N14 doc;
`EditorView.swift` — `EditorSurface.Coordinator`, `InlineEditorSurface.Coordinator` (install, the composed
`onWidthReflow` / `onLayoutSettle`, `remeasure`), `BadgeOverlayController`, `ScrollAnchorController`;
`EditorTextView.setFrameSize`/`applyFrameHeight`/`viewWillDraw`/the two factories; `PaneMeasurement.height`/`extent`;
`ReadPostViewModel` (`remeasure`, `refreshBadges`); `LongBlockLayout` (its `.layoutAvailable` predicate);
`JumpPrimitive.jump`'s head; `BookView`'s expanded row (the ZStack of `ReadPostView` and the inline `EditorView`); the
Mac pins `InlineEditorWindowTests` and `TutorialWalkTests`' N14 / starved-host badge pins (their harness shapes); the
Bookcase: `ShelfViewModel` (the held/one-shot split, `start`, `refreshAggregates`), `ShelfView` (every
`refreshAggregates` caller), `BookcaseRowMeta.facts`, `Queries.bookcase` / `ShelfBook` / `bookWordCounts`;
`BookcaseBoardTests`' session harness; vx-282's branch diff on `EditorViewModel.swift` and `EditorView.swift`
(read-only — `storageDidEdit`'s top, `settleMarkdownCaret`, the fan-panel sheet's `onClose`, the selection delegate).

**Surfaces (planned):** THE EDITOR SEAM — `App/Variorum/Variorum/Features/Editor/EditorViewModel.swift`,
`refreshBadges` ONLY (none of vx-282's functions; `EditorView.swift` — on vx-282's file list — is NOT touched); the
Bookcase — `App/Variorum/Variorum/Features/Shelf/ShelfViewModel.swift` (`start`'s loop + one helper; no sibling run
touches the file); Mac pins under `App/Variorum/VariorumTests/`. ZERO `Sync/`, custody/Keychain, schema, `Server/`,
`BlockRangeIndex`, `PaneSurface`, `runStructural`, the decoration overlay, the read tier, VX-281's lane.

### LIVE STATUS — U4's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the traces and the design (before code); the TK2 probes saved beside the evidence | DONE (this commit) — `notes/plans/vx246-screens/u4/probes/` (gitignored): `probe.swift`, `probe2.swift`, `probe3.swift` + `probe-output.txt` (macOS 27.0, 26A428) |
| 1 | the pins FIRST (Mac — `FanBadgePlacementTests` for VX-230, `BookcaseOutsideWriteTests` for VX-231), committed on the pre-fix tree | DONE (`e4a1042e` the seam: `ShelfViewModel.oneShotReads`, DEBUG, behaviour-identical — a counter nothing consults, so the fix's P1 letter is a pin; `511196ad` + `10629374` the pins). **`FanBadgePlacementTests` (5):** `aBadgeNeverSitsAtAnotherBlocksPlace` (U1's phantom: block 1 one take, one fan on screen, four far below — Write at the top), `blockOnesBadgeIsItsOwnAlone` (her `022301`: 96 of 120 fanned, block 1 among them), `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` (her `174949`: the inline editor, 80 of 120 fanned, a width change through the app's own road — no synchronous remeasure, no explicit refresh), `aWidthChangeInWriteKeepsEachBadgeHome` (Write, a window resize), and `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` (a CHARACTERIZATION, green on both trees by design). The first four read the FACE (the ⑂ buttons) and the model: every badge on a laid-out fragment at its own line, no two ⑂ at one place, none at an unfanned block 1's place. **`BookcaseOutsideWriteTests` (2):** `aNoteJoiningFromOutsideTheBoardReReadsItsWords` (U1's shape: the board up, a 12,000-word note joins through the ops alone; the row must read "2 notes · 12,003w") and `typingInAMemberNoteNeverReReadsTheOneShot` (the P1 guard — green on both trees by nature). **Expected on the red product (W1):** the four VX-230 face pins RED on the stack / phantom / position lines (the inline pin also on "every badge at its line"), the characterization GREEN; the VX-231 join pin RED on "the row's word figure follows the join" (3 read, 12,003 stored) and the row line, the P1 guard GREEN. A red on a PREMISE line (`premise:` in the message, a `#require`) is a harness defect, not evidence |
| 2 | the RED-ON-OLD Mac product: `build-for-testing` → `App/Variorum/DerivedData/vx246-u4-red` (the pins, NO fix — W1 runs against it) | DONE — an APFS clone of `vx246-u3`, then `xcodebuild … -derivedDataPath DerivedData/vx246-u4-red build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0 on the second build (the first named one isolation error in the new pin — `10629374` fixed it); its sources = `10629374`'s App/Sources: U3's tree + the seam + the pins, NO fix — so it IS the pre-fix tree with the pins (and, since the fix commits will touch only `EditorViewModel.refreshBadges` and `ShelfViewModel`, byte-identical to a revert of them — the red-by-revert run). No warning in a touched file (logs `u4/logs/mac-red-build{,-2}.log`) |
| 3 | VX-230's fix — `refreshBadges`: a badge only from a laid-out fragment; the inline surface lays out what it badges | DONE (`91a56a7a`) — `EditorViewModel.refreshBadges` ONLY: the fragment read keeps a frame only when `state == .layoutAvailable`; on the surface with no scroll view the read passes `.ensuresLayout` (measured first, `probes/probe4`: a mid-document `.ensuresLayout` read is positionally exact — TK2 lays out up to it); the R1-1 oracle (`decorLayoutQueriesInEditTransaction`) counts that forcing read if it ever ran inside the storage-edit transaction. No other function, no other editor file |
| 4 | VX-231's fix — the Bookcase's one-shot re-read when its own held snapshot moves | DONE (`07f9f28d`) — `ShelfViewModel.start`: a held delivery whose `books` differ from the last held (after the first) calls `followHeldMove()` — a single-flight `Task` re-running `refreshAggregates` (a move during a re-read asks for one more), cancelled at `start`'s exit |
| 5 | headless finals (core · MCP · workbook) + the FIXED Mac product `DerivedData/vx246-u4` | DONE — **headless, `swift test --skip-build` on `07f9f28d`'s sources, EXIT 0: `VariorumMCPTests` 236 / 49 · `VariorumCoreTests` 2,826 / 326 · `StringsWorkbookTests` 40 / 6**, zero ✘, the skip set the standing gated nine (unchanged from U3 — no core line moved; `u4/logs/p5-finals.log`). **The fixed Mac product BUILT:** `App/Variorum/DerivedData/vx246-u4` (an APFS clone of `vx246-u4-red`, then `build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0, no warning in a touched file; `u4/logs/mac-build-for-testing.log`) — its sources are `07f9f28d`'s (both fixes) |
| 6 | THE STAGE WINDOW plan (claim `vx246-u4`: W1 red on old · W2 green + the batch · W3 the walk in both voices) → READY | DONE (this commit) — resumed after U3's window (released 02:54); **the products check: `git diff --name-only 07f9f28d..HEAD -- Sources App` EMPTY → no rebuild** (`vx246-u4-red` = `10629374`'s sources, `vx246-u4` = `07f9f28d`'s). The W2 list `u4/stage-suites.txt` (271 suites = U3's 215 ∪ every suite in a test file that mounts an editor model, the inline surface, a book view or the Bookcase ∪ the two new suites; every name verified to exist as a type) and the scripts `u4/run-w1-red.sh`, `u4/run-w2-batch.sh` (U3's shape; gitignored). THE STAGE WINDOW below, with RULING 2's slot marked. **READY for stage** — the stage NOT claimed; a FRESH session builds ruling 2's fix on this tree first (the orchestrator's word), then runs the window |

**No revert is in flight.**

### The traces (written before code)

**VX-230 — the mechanism, MEASURED (inputs → wrong output).** The badge pass is `EditorViewModel.refreshBadges`
(`EditorViewModel.swift` ~3696). For every FANNED slot it reads the block's first fragment with
`enumerateTextLayoutFragments(from:options: [])` — no layout forced, by design ("unlaid-out blocks simply have no badge
until scrolled to (P1)", its own doc) — offsets `fragment.layoutFragmentFrame` by `textContainerOrigin`, and keeps the
badge when `viewFrame.intersects(visible)`. `BadgeOverlayController.render` then places the button at
`y = badge.frame.minY`. The doc's promise is false on two measured facts (`probes/probe-output.txt`, a bare TK2
`NSTextView` on this Mac, macOS 27.0):
1. **A fragment TK2 has not laid out reports `layoutFragmentFrame == .zero`, `state == .none`** — cold, every fragment;
   after a viewport layout, every fragment outside the viewport that TK2 did not estimate (an estimated one,
   `state == .estimatedUsageBounds`, reports a GUESSED frame); and **after ANY width change, EVERY fragment, until the
   next layout pass** (probe2: a fully laid-out 160-paragraph document, `setFrameSize` 700 → 360, then all seven
   sampled fragments read `s0 y0 h0`).
2. **`CGRect.zero.offsetBy(origin).intersects(visible)` is TRUE** whenever `visible` contains the container origin —
   CGRect's degenerate-rect rule (`(40,20,0,0).intersects((0,0,700,500))` → `true`, measured).

So every fanned block whose fragment is not laid out gets a badge AT THE CONTAINER'S ORIGIN — the top of block 1's first
line — whenever the top of the note is in view. Her badges are `NSButton`s with the translucent `.badge` bezel; N of
them stacked at one point darken into one filled disc (her "fully black filled disc"; U1's "darker ⑂2"). **The MCP
write is incidental:** the trigger is a note with fanned blocks TK2 has not laid out, which any long fanned note is.
- **Write (her `022301` shot, U1's sighting):** the detail editor lays out only its viewport (+ TK2's overdraw), so
  every fanned block below the fold stacks on block 1 while the top of the note is in view. Block 1's own badge (hers)
  sits under the stack; U1's block 1 had ONE take and wore the stack alone — the "phantom ⑂2" is its neighbours'
  badges (the six fanned blocks were 22/72/122/172/222/272; 22 was on screen and badged itself; the five below
  stacked). "Resolves a little, then is fixed": scrolling lays blocks out (`ScrollAnchorController.boundsChanged` →
  `refreshBadges`), and each block, once laid out, moves its badge home.
- **The book Outline (her `174949` shot — the INLINE editor, `InlineEditorSurface`, no scroll view of its own):**
  the inline badge region is the WHOLE post by design (`viewportBounds` returns `textView.bounds` — "Whole-post overlay
  work is the accepted inline cost model (the inline surface is laid out to content already…)"). Its badge pass is
  delivered by (a) `renderFull`'s tail and (b) the N14 settle hop. On a WIDTH change the composed
  `InlineEditorSurface.Coordinator.onWidthReflow` calls the MODEL's handler first — generation bump +
  `overlayLayoutDidSettle()`, which queues the badge hop S — and THEN `scheduleRemeasure()`, which queues the
  remeasure R (whose `PaneMeasurement.height` is the `.ensuresLayout` walk over the whole post). The main queue runs S
  BEFORE R: S reads a document the width change has just returned to `state .none` — every fanned fragment `.zero` —
  so EVERY fanned block's badge lands at the origin, and none at its block; R then lays the whole post out, and nothing
  re-runs the badge pass (no generation bump, no scroll observer on this surface, and the next display pass's settle
  finds the generation delivered). That is her shot exactly: one black disc, no visible block badged. (The attach-time
  doc — "delivery stays on the next runloop turn, after this cycle's remeasure has laid the new width out" — assumed
  the opposite order; the coalescing remeasure can also be superseded by a later `viewUpdated` trigger and land later
  still.) "Taking Takes mode and back fixed it": a remount re-runs the cold order, where the projection arrives after
  the width settled and the post-layout settle hop delivers real frames.
- **Which book surface draws badges, and whether it should:** the focused note's inline editor (the one live editor,
  P3) and every other expanded note's read tier (`ReadPostView`, whose `refreshBadges` always follows its own
  `.ensuresLayout` remeasure — laid out by construction; examined, SAFE). AppSpec §12: "a corner badge only on fanned
  blocks", on every surface that shows the text — so the book view SHOULD badge its fanned blocks, each at its own
  block. Her "where it shouldn't" reads as the stack (no badge belongs at block 1's place for the others), not as
  "the book view should draw none" — the fix keeps the badges and puts each one home.

**VX-230 — the fix (designed, PENDING the pins):**
1. **The geometry rule, both surfaces:** `refreshBadges` places a badge only from a fragment whose
   `state == .layoutAvailable` — the house's own "laid out" predicate (`LongBlockLayout`'s candidates read exactly
   it). A `.zero` frame or a TK2 estimate is never a position. A fanned block TK2 has not laid out gets NO badge until
   it is laid out — the function's own documented contract, made true.
2. **The inline surface lays out what it badges:** on the surface with no scroll view (the book / spread / pool
   editor, whose badge region is the whole post) the fragment read passes `.ensuresLayout`. That makes the doc's own
   premise ("the inline surface is laid out to content already") TRUE at the read instead of assumed, regardless of
   which hop runs first. Cost: ZERO net layout over a mount or a width change — the remeasure lays out the same whole
   post on every storage edit and width change (`PaneMeasurement.extent`'s `.ensuresLayout` walk), so whichever of the
   two runs first pays it and the other finds it done (P1: the inline surface's accepted cost model since Phase 10 —
   no new class). The detail editor keeps `options: []` (P1 — only its viewport is ever laid out).
3. **Not built, argued:** a trigger in `InlineEditorSurface.Coordinator.remeasure` (re-run the badges after the whole-post
   layout) — `EditorView.swift` is on vx-282's file list, and a trigger keeps the ordering dependence that is today's
   defect; a display-pass re-delivery for the DETAIL editor after a width change — its width change is followed by
   `ScrollAnchorController`'s width road (`restoreReadingAnchor` → `JumpPrimitive.jump`, which lays out its target, then
   `refreshBadges`), so no mechanism is traced to a defect there; the pin `aWidthChangeInWriteKeepsEachBadgeHome`
   characterizes it (green on the fixed product is the evidence; red there would be a found residual, reported, never
   patched under the claim).
4. **Recorded residual (pre-existing, unchanged in kind):** after a single large scroll jump in Write (⌘↓, a scroller
   click), the badge pass runs at `boundsChanged`, before TK2 lays out the region the jump exposed; a fanned block whose
   fragment is still unlaid there gets no badge until the next scroll event or keystroke (before this fix: the same —
   its `.zero` frame missed the moved viewport). TK2's overdraw makes it rare under continuous scrolling.

**VX-230 — the decoration sibling (traced by reading; NOT this unit's — OWED):** `refreshDecorations` reads
`fragmentFrame(atOffset:)` with `options: []` and no state check too, so a decorated block (a callout, a comment card,
the seams, the indicator) whose fragments are unlaid gets a zero-height rect at the container's origin, and
`frame.intersects(visible)` keeps it. Write prunes it to the visible character window (its two edge lookups force
layout there), which hides most of it; the INLINE surface's window is the whole post, so after a width change its
decorations would stack at the top until the next keystroke. Same TK2 facts, a different face (the decoration
overlay), not her report — a ticket with a red-first probe, not a rider on this fix.

**VX-231 — the mechanism (inputs → wrong output).** The Bookcase holds two cost tiers by contract
(`ShelfViewModel`'s header): the HELD half (`start()` — `Queries.bookcase`, one wing's shelves and books with
`postCount`, `sectionCount`, arrival counts; its tracked region never includes `container`, pinned
`theHeldSnapshotsRegionIsBlindToAutosave`) and the ONE-SHOT half (`refreshAggregates()` — `bookWordCounts`, the tags
column, rule paths, last-edited, gathering and archived counts) re-read ONLY on appearance (`ShelfView`'s `.task`) and
after the board's OWN acts (fifteen call sites, every one a door on the board). A note joining a book from anywhere
else — an MCP `add_note_to_book` / `create_note` into a book (U1's leg (d)), a sync apply, the Book Panel, another
window, ⌘J — moves the held snapshot (the row's "6 notes" → "7 notes" at once) and leaves the one-shot as it was, so
the row pairs a fresh note count with the stale word figure ("7 notes · 3 ch · 120w" right after a 32,347-word note
joined). The same pairing reaches the archived count, the tags column and a gathering's count.
- **Not VX-122's signal:** VX-122 is the LIBRARY's one-shot listing missing revivals, wanting one cross-surface revival
  signal. This defect needs no signal: the Bookcase already HOLDS an observation that moves exactly when membership does;
  only its one-shot twin does not follow it. The brief's preference ("the existing observation roads over a new
  notification") is the fix.

**VX-231 — the fix (designed, PENDING the pin):** in `start()`'s held loop, a snapshot whose `books` differ from the
last one held (after the first delivery, which `.task`'s own appearance read covers) re-reads the one-shot half —
single-flight (a change landing while a re-read runs asks for exactly one more after it), never inside the observation
loop's own turn. P1: the held region never wakes at autosave rate (pinned), so this re-read runs at membership /
shelf / rule-change rate — the same store-wide one-shot every board act already re-runs; nothing new reads `container`
at keystroke rate. A note's words changing by EDITING (no membership move) stays the one-shot's documented staleness
— not this ticket.

**Shared cause?** No. VX-230 is a geometry read treating TextKit 2's "not laid out" as a position (plus one delivery
order on the inline surface); VX-231 is a refresh trigger the one-shot tier never had. Both were first seen right
after a big MCP write, and in both the write is incidental: any long fanned note shows VX-230; any outside membership
change shows VX-231.

### THE ORCHESTRATOR ON U3's WINDOW (2026-10-14, ~03:00 MDT)

- **Accepted.** U3's acceptance evidence is complete: the red-on-old Mac pins, the batch, the real-client leg in both
  voices, and the timing leg. VX-275 and VX-323 close at the merge.
- **Finding A** (her focus moves when a client deletes the note in the other pane) is ruled provisionally as ruling 2
  in ORCHESTRATOR'S PROVISIONAL RULINGS. Its fix comes after U4's plan, red-first, and its proof rides U4's window.
- **Finding B** (the split view's Library catalog overdraws the divider) is now **VX-328**, outside the run.
- **Finding C** (the live pre-fix app didn't strand `delete_block`'s words) is dispositioned by trace. It fits
  VX-184's FLUSH TRACE, step (5): her bytes stay pending in memory and land if a later flush runs in the same session.
  Put back's door flushes, so the in-session red contrast was rescued. The loss shows at QUIT, which the
  `delete_note` red contrast exercised and the `delete_block` one didn't.
  - The deterministic pins hold the debounce still and prove the mechanism (red on old, by revert).
  - The fixed product's live legs (W3a's caret landing, W3b's 53 ms) stand either way.
  - Not traced further. The Fable review may weigh it.
- **The harness warnings** (`@Dependency(\.withRandomNumberGenerator)` has no test implementation, raised while the new
  door pins run) are noise, not a failure. The ladder may ask for the dependency to be pinned in the suite.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u4`)

**Built (rebuild ONLY if `git diff --name-only 07f9f28d..HEAD -- Sources App` is non-empty — ruling 2's fix WILL make it
non-empty: rebuild BOTH products then, `vx246-u4-red` from the pins commit's tree plus ruling 2's pin only if its pin
must be red on old, else as is):**
- `App/Variorum/DerivedData/vx246-u4-red` — RED-ON-OLD (`10629374`'s sources: the pins, no fix). Runs ONLY W1.
- `App/Variorum/DerivedData/vx246-u4` — FIXED (`07f9f28d`'s sources): W2 and W3.

**Estimate ~55 min of work → claim 75** (W1 ~4 · W2 ~18 · fixture ~8 · W3 ~18 · ruling 2's proof ~5 · cleanup ~5).
**Batch-only fallback (~25 min, claim 35):** steps 0–1, W1, W2, cleanup; the walk moves to the next window.

0. **Guards, every step** (U3's, verbatim): `Tools/stage status` shows the claim held; `Tools/WalkKit/guard.sh --author`
   (her `/Applications/Variorum.app` ABSENT — present ⇒ STOP and report, never quit or kill it); `pgrep -fl
   'Variorum.app/Contents/MacOS'` empty before any test run; every GUI act through `click.sh` / `keys.sh`, synthetic events
   ≥ 2.6 s apart; an undismissable system popup → reported word for word, the window paused.
1. **A1 prestage + prefs, FIRST** (the test host is the dev-store app): every dev-store file + key files →
   `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified, sha256 recorded; `defaults export
   io.lduarte.Variorum.debug`. (No MCP leg in this window — her user-scope servers are not touched; read them only if a
   leg is added.)
2. **W1 — RED ON OLD (~4 min):** `zsh notes/plans/vx246-screens/u4/run-w1-red.sh` (detached to its log, POLLED in the
   foreground). **Expected, by design:** `FanBadgePlacementTests` **4 of 5 red** — `aBadgeNeverSitsAtAnotherBlocksPlace`,
   `blockOnesBadgeIsItsOwnAlone`, `aWidthChangeInWriteKeepsEachBadgeHome` (each on "not laid out — its frame is no
   position" / "stacked on another's place" / "at block 1's place"), `theBookEditorPutsEveryBadgeHomeAfterAWidthChange`
   (on "its block's first line at y=…" and the stack line) — and the characterization
   `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` GREEN; `BookcaseOutsideWriteTests`
   `aNoteJoiningFromOutsideTheBoardReReadsItsWords` RED on "the row's word figure follows the join" (3 read, 12,003 stored)
   and the row line, `typingInAMemberNoteNeverReReadsTheOneShot` GREEN. A red on a `premise:` line or a `#require` is a
   harness defect → STOP after cleanup and report, nothing fixed under the claim. **Said honestly:**
   `aWidthChangeInWriteKeepsEachBadgeHome`'s width road is the one pin whose OLD-tree red rides the stack (the deep fans),
   not the width road itself — record which lines failed.
3. **W2 — GREEN + THE MAC BATCH (~18 min):** `zsh notes/plans/vx246-screens/u4/run-w2-batch.sh` — 271 suites on
   `vx246-u4` (`stage-suites.txt`), detached, polled. Read the summary, every `✘`, the `skipped:` lines (the gated
   capture suites). Expected: the seven pins green. **A red not designed:** re-run ALONE once
   (`-only-testing:VariorumTests/<Suite>/<test>()`); green alone + a named load-flake class (VX-167, VX-279) ⇒ recorded as
   that; reproduces alone ⇒ a REAL regression, reported with the test, its message and a trace (no fix under the claim).
   Standing reds named if met: VX-115 (`BookCollectingDoorsTests`), VX-245's sites, VX-167. **Watch especially:** any
   inline/book suite that counts layout passes or first measures (`InlineHeightReportTests`, `InlineEditorWindowTests`,
   the Book Outline landing suites) — the inline badge read now lays the post out when a fanned block exists.
4. **THE FIXTURE (~8 min, the dev store, her own Import door — no MCP needed: the mechanism is TK2's, the write
   incidental, the trace's finding):** in the scratchpad, generate with stdlib Python in the 13n-a document format
   (`Domain/VariorumDocument.swift` — `alternatesHeader`, `takeMarker(label:ordinal:)`, `alternatesSection`; a malformed
   file is refused BY LINE at import, so the import itself validates it):
   - `vx230-long.md` — 140 blocks of ~60 words, block 1 with ONE take, ONE fanned block on the first screen (block 3),
     then fanned blocks 40, 70, 100, 139 (U1's shape);
   - `vx230-book/` — two chapter folders, each with two notes of ~70 blocks, **block 1 fanned and ~4 in 5 blocks fanned**
     (her book's shape: "two takes on most blocks").
   File ▸ Import… each (the note lands in the Pool, the folder as an unshelved book — its receipt captured once).
5. **W3 — THE WALK, Study then Terminal (~9 min each; one capture per row into `notes/plans/vx246-screens/u4/`;
   region captures, `screencapture -x -R`):**
   - **(a) Write, first open:** the long note from the Pool → Write at its top: block 3's ⑂2 at block 3; NO badge at
     block 1 (one take); no dark disc anywhere. Capture.
   - **(b) Write, first open of a book note:** chapter 1's first note in Write: block 1's ⑂2 is ONE muted badge, like
     every other block's (her `022301` shot, the after). Capture.
   - **(c) Scrolled:** scroll (wheel, in small steps) to block 40 of the long note: its ⑂2 appears at block 40 as it comes
     into view; scroll back to the top: still no badge at block 1. Capture each.
   - **(d) The book view — Outline:** open the book, Outline, expand chapter 1's first note and click into it (the live
     inline editor): every visible fanned block wears its ⑂2 at its own line, block 1 included, no disc (her `174949`
     shot, the after). Capture. Then **a width change**: toggle the sidebar (or resize the window ~200 pt narrower) —
     the badges follow their lines, no disc. Capture.
   - **(e) The book view — Index / Book / Read:** a glance at each with the same note (whatever surface draws badges
     there draws each at its own block). One capture each where badges show.
   - **(f) First LAUNCH:** quit the Debug app by bundle id with the long note open in Write, relaunch (`open -n`): at the
     note's top, no disc, block 3 badged. Capture. (Her "on first launch, then resolves" — the after.)
   - **(g) VX-231 — the Bookcase row after a big join:** the Bookcase on screen with the imported book's row visible
     (its "N notes · …w" read and captured); from a SECOND window (File ▸ New Window, or a note's Book Panel / Add to
     Book… door — any road that is not a Bookcase door) add the long note (`vx230-long`, ~8,400 words) to the book; back at
     the Bookcase, WITHOUT leaving it or re-entering: the row reads one more note AND its word figure grew by the note's
     words. Capture before/after. (If no non-Bookcase add door is reachable with the Bookcase visible, the headless pin
     stands as the evidence and the walk records the attempt.)
6. **RULING 2's PROOF — the marked slot (the FRESH session fills it: its pin's name, its red-on-old line, and a ~5-min
   live check).** ORCHESTRATOR'S PROVISIONAL RULING 2: a navigate-away never takes her focus. The live check's shape:
   two panes, her caret typing in pane 1's note; pane 2's note deleted from outside pane 1 (U3's W3a road, or her own
   Delete on pane 2's note from the Library/Trash with pane 1 focused) → pane 2 lands on the Library IN PLACE and her
   caret STAYS in pane 1 (a keystroke lands there). Capture. *(Not built by U4 — the orchestrator's word: a fresh session
   builds it on this tree, red-first, rebuilds the products, and runs this window with its proof.)*
7. **CLEANUP (~5 min):** the imported note and book moved to the Trash is NOT enough — the dev store is RESTORED:
   the Debug app quit BY BUNDLE ID (`pgrep` empty); prefs `defaults import` + delete every key the window added →
   re-export, 0 keys differ; `Tools/ScaleFixture/restore.sh <the prestage dir>` → "Restored (verified)" + a second `cmp`
   (the posture handed over: Standard, unlocked, Study); the voice back to Study if changed (the restore returns it);
   the scratch fixture files deleted; stray `default.profraw` removed; **`Tools/stage release --who vx246-u4`** at once;
   ONE result line (claim times, W1's red counts, W2's totals, W3's verdicts, ruling 2's verdict, the posture).

### SELF-ASSESSMENT (pre-stage — the implementer's)

- **Confident:** the mechanism — measured, not inferred (`probes/probe-output.txt`: `.zero` / `.none` for unlaid
  fragments, every fragment after a width change, the degenerate-rect `intersects`, and a mid-document `.ensuresLayout`
  read positionally exact); both of her screenshots and U1's sighting follow from it line by line; the fixes are small and
  local (`refreshBadges`'s read, `ShelfViewModel.start`'s loop); headless green and both products build clean.
- **Less sure, said plainly:** (1) nothing has run on a Mac — the pins' harness shapes are copied from the N14 / inline
  width pins, but a premise line may still trip at W1; (2) the inline `.ensuresLayout` read moves the book editor's
  whole-post layout from the remeasure hop to the badge pass when the badge pass runs first (renderFull's tail, a voice
  flip's `applyChrome` inside SwiftUI's update) — the same work one hop earlier, but suites that time or count inline
  layout may notice (W2 watches them); (3) VX-231's follower double-reads the store-wide one-shot after each BOARD act
  (the act's own explicit refresh + the follow) — human-rate, off the main thread, accepted rather than touching fifteen
  call sites; (4) Write's width road is argued (the scroll-anchor controller's width restore lays out and refreshes), not
  traced live — W2's `aWidthChangeInWriteKeepsEachBadgeHome` and W3 (d) are its evidence.
- **Recorded residuals:** after one large scroll jump in Write, a fanned block exposed by the jump may lack its badge
  until the next scroll event or keystroke (unchanged in kind from before); a member note's words changing by EDITING
  still don't reach the Bookcase row until the board re-appears (the one-shot's documented design).
- **Editor-seam letter:** `refreshBadges` adds no attribute stamp, touches no storage, no `runStructural`, no
  `BlockRangeIndex`; the one forcing read is off the storage-edit transaction (the R1-1 oracle counts it if it ever ran
  inside); TK1 untouched (no `.layoutManager`).
- **MOBILE PARITY:** nothing mobile-visible — the phone's badges are `MobileBlockDecor`'s own (not examined; the TK2
  facts are platform-shared, so the phone may hold the same class — OWED 3).

### PROVISIONALs (with their options — the orchestrator files them at the merge)

None. (Both fixes restore documented contracts: "unlaid-out blocks simply have no badge until scrolled to", and the
Bookcase row's counts agreeing with each other.)

### FOR VX-234 (user-facing words, as built)

Nothing — no word changed.

### OWED (for the orchestrator)

1. **VX-327 — the decoration layer's same read** (minted from this trace): `refreshDecorations`' `fragmentFrame(atOffset:)`
   reads unlaid fragments as positions too (no state check), so decorations — callouts, comment cards, seams, the
   indicator — of unlaid blocks get zero-height rects at the container origin; Write's visible-window prune hides most of
   it, the inline surface's whole-post window does not (after a width change, until the next keystroke). A red-first
   probe before any fix.
2. **TEXTKIT2_NOTES §3 — a PROPOSED finding** (canon is the orchestrator's at the closeout): *"macOS 27.0 measured finding
   (VX-246 U4, 2026-10-14 — pinned in `FanBadgePlacementTests.textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects`):
   a layout fragment TK2 has not laid out reports `layoutFragmentFrame == .zero` in the `.none` state (an estimated one
   reports a GUESSED frame), and a WIDTH change returns every fragment to `.none` / `.zero` until the next layout pass; a
   `.zero` rect offset by the container origin `intersects` any rect holding that point (CGRect's degenerate-rect rule).
   **The rule:** a frame read with `options: []` is a position only when `state == .layoutAvailable`. A mid-document
   `.ensuresLayout` read is positionally exact (TK2 lays out up to it)."*
3. **The phone's twin (not examined):** `MobileBlockDecor` / `MobileEditorTextView` may read fragment frames the same way
   — a probe on the VM board if the orchestrator wants it checked.
4. **The Fable cold review** (the editor seam, CLAUDE.md): `EditorViewModel.refreshBadges` — the orchestrator's, after the
   units.
5. **Canon at the merge:** none required (AppSpec §12's "a corner badge only on fanned blocks" now holds on every surface).


## U4 STAGE RUN — the window minus ruling 2 (a fresh stage runner, from 2026-10-14 ~03:00 MDT)

**What this run does NOT do (said first):** step 6 of U4's THE STAGE WINDOW (RULING 2's PROOF) is NOT this run's; it
moved to U5's window, where ruling 2 is built (ORCHESTRATOR'S PROVISIONAL RULINGS, ruling 2). No product code is
written or changed, under the claim or before it; a red that needs code is recorded and reported, never fixed here. No
MCP client is registered or run (the trace's finding: the mechanism is TK2's and the write incidental), so the fixture
lands through her own File ▸ Import… door. No canon, QUESTIONS or ticket edits.

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, the Stage traffic log,
ORCHESTRATOR'S PROVISIONAL RULINGS; U2 STAGE RUN and U3 STAGE RUN whole (the A1 copy BEFORE the batch; `defaults import`
merges, so re-export and diff; the batch detached and polled in the foreground); U4's UNIT RECORD whole (the traces,
THE STAGE WINDOW, the self-assessment, OWED); `notes/SessionResiliencyProtocol.md`; `Tools/stage`, `Tools/WalkKit/`
(README, `guard.sh`, `click.sh`, `keys.sh`), `Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); U4's
`run-w1-red.sh`, `run-w2-batch.sh`, `stage-suites.txt`; the memory notes walk-driving-lessons and
walk-restores-dev-store-posture. Code read for the window: the import door (`DocumentImporter.choose` — files AND
folders, multiple selection, prompt "Import"; `VariorumDocumentFolder` — `.md` accepted, subfolders = chapters, digit-aware
order), the format (`VariorumDocument` — header, the Alternates section, `take: N`), the badge face
(`BadgeOverlayController.render` — an `NSButton` titled `⑂<n>`), the Pool's every-row "Add to Book ▾" (W3 (g)'s
non-Bookcase road).

**The build check (before READY):**
- **No source moved since either product was built.** `git diff --name-only 07f9f28d..HEAD -- Sources App` is EMPTY;
  `git diff --name-only 10629374..HEAD -- App/Variorum/VariorumTests Tests` is EMPTY; the tree is clean at `23e87826`
  (record-only commits since). The newest sources (`EditorViewModel.swift` 02:06:42, `ShelfViewModel.swift` 02:07:24)
  predate the fixed product's dylib and test bundle (02:11:41); the pins (02:00:43, 02:03:40) predate the red product's
  (02:05:29–30), and both fix files' edits postdate it.
- **Each product is what its name says, read from its symbols** (`nm` + `swift demangle`): `vx246-u4` — `followHeldMove`
  15 (VX-231's fix), `EditorViewModel.refreshBadges()` 4,276 bytes (VX-230's fix); `vx246-u4-red` — `followHeldMove` 0,
  `refreshBadges()` 3,336 bytes (the pre-fix body); both carry the seam (`oneShotReads` 7) and both pin suites in their
  test bundles (`FanBadgePlacementTests`, `BookcaseOutsideWriteTests`). **→ no rebuild.**
- **The W2 list:** `run-w2-batch.sh`'s `-only-testing` names = `stage-suites.txt`, 271 unique (U4's piece 6 verified each
  as a declared type).
- **Host and tools:** grants probed with no prompt, `AX: true SCREEN: true`; `walk-cap` / `walk-scroll` compiled into the
  scratchpad, plus a READ-ONLY AX probe `badges <pid>` (every `AXButton` titled `⑂…` with its screen frame, and any
  point holding more than one — the stack, read as numbers beside each capture; it posts no event); `Tools/WalkKit/wl2`
  present; `cliclick` present. Free disk **46 GiB**.
- **Her user-scope MCP servers, read now (names + a sha256 prefix of the `mcpServers` block, never values):**
  `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** (`u4/userscope-ready.txt`) — re-read at the window's start and
  after cleanup.
- **The fixture, generated (no stage act):** `notes/plans/vx246-screens/u4/fixture/` (gitignored; under home so the
  Open panel reads it plainly — the plan said "the scratchpad"; the generator `gen_fixture.py` stays there):
  `vx230-long.md` and `vx230-long-two.md` (140 blocks of ~60 words each, every block opening "Block NNN …"; block 1 ONE
  take; blocks 3, 40, 70, 100, 139 fanned ⑂2) and `vx230-book/` (`1 chapter one/`, `2 chapter two/`, two notes each, 70
  blocks, block 1 fanned, every block fanned but each fifth). The SECOND long note exists so W3 (g) can run once per
  voice (each half adds a different note to the book).

**Process choices (U2's and U3's lessons applied):** the A1 copy and the prefs export come FIRST, before W1 (the test
host is the dev-store app); W1 runs in the foreground (about a minute), W2 detached to its log and POLLED in the
foreground; every GUI act through `click.sh` / `keys.sh`, at least 2.6 s apart; the Debug app quit by bundle id; the
prefs restored by import, then a re-export and a diff, deleting every key the window added, until 0 differ.

**Minutes:** ~60 of work expected (W1 ~2 · W2 ~10 · the import ~6 · W3 ~30 for both voices · cleanup ~8); a **90-min
claim** asked. Batch-only fallback (~25 min, claim 35): steps 1, W1, W2, cleanup.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fixture generated, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the GO's exact line) |
| 0 | guards on every step; the claim from the GO's line | DONE — the GO from oct13coordinator (its pre-checks 03:05: no instances, no booted sims, 46 GiB free; the dev store left Standard/unlocked/Study at U3's 02:54 restore); its exact line run: `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u4 --reason "VX-246 U4: pins + 271-suite batch + import + dev-store walk both voices (A1)" --minutes 90` → **CLAIMED 03:05:45 MDT, 90 min** (expires 04:35:45). Pre-claim: `guard.sh --author` OK (idle 798 s), no Variorum instance, no xcodebuild. HEAD had moved to `9edd8439` (the orchestrator's record-only commit); `git diff --name-only 07f9f28d..HEAD -- Sources App` still EMPTY. **A machinery note:** `Tools/stage status` exits 1 while a claim is held, so it cannot sit in an `&&` chain (it ended W2's first launch line before `xcodebuild`; relaunched at once without it) |
| 1 | A1 prestage copy (every store file + key files, each `cmp`-verified, sha256 recorded) + `defaults export io.lduarte.Variorum.debug` + her user-scope fingerprint BEFORE | DONE (03:05:51) — **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T090551Z`**, five files each `cmp`-verified (sha256 prefixes: sqlite `088275b387ef` · wal `e961fd26b8bb` · shm `16c8d84a4fd6` · keys `3af4704371ff` / `7e12a1b85890`; `u4/store-hash-pre.txt`) — the sqlite and wal hash-EQUAL to U3's restored state (the shm was re-touched at 02:58, after U3's restore; the copy is the store exactly as handed over); prefs exported (**1,549 keys**, `appearanceChoice` = system) to `u4/prefs-pre.plist`; her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as at READY (`u4/userscope-pre.txt`) |
| W1 | `run-w1-red.sh` — the seven pins against `vx246-u4-red`; expected `FanBadgePlacementTests` 4 of 5 red + the characterization green, `BookcaseOutsideWriteTests` 1 of 2 red + the P1 guard green; a red on a `premise:` line or a `#require` ⇒ STOP after cleanup and report | DONE (03:05:58 → 03:06:51) — "✘ Test run with 7 tests in 2 suites failed after 10.354 seconds with 67 issues", EXIT 65 (`u4/logs/w1-red-on-old.log`, `u4/w1-red.xcresult`). **NO premise line and NO `#require` tripped** (the three `premise:` expectations, lines 185, 187 and 270, all held; zero "premise" in the log) — so not the STOP case. **But W1 does NOT match its design in three places, recorded as found:** **(1) AS DESIGNED, RED:** `blockOnesBadgeIsItsOwnAlone` (11 issues: `:218` "block 1 wears ONE ⑂ badge — its own — not 10 stacked into a disc"; `:139` ×9 "entry 8/10/11/12/13/15/16/17/18's badge stands on a fragment TextKit 2 has NOT laid out"; `:145` "9 ⑂ buttons stacked on another's place — ys [24.0 ×10, 116, 208, 300, 484, 576]"); `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` (53 issues: `:141` ×51 "entry N's badge at y=8.0, its block's first line at y=151/437/580/…"; `:145` "13 ⑂ buttons stacked … ys [8.0 ×14, 2881, 3034, …]"; and `:295` "every fanned block keeps a badge after the width change" — 52 of 80 — a non-premise line beyond the plan's two); `BookcaseOutsideWriteTests.aNoteJoiningFromOutsideTheBoardReReadsItsWords` (2 issues: `:107` "the row's word figure follows the join — 3 read, 12003 stored"; `:109` "the row as drawn pairs the fresh count with the fresh words"); `typingInAMemberNoteNeverReReadsTheOneShot` GREEN (the P1 guard, by nature). **(2) DESIGNED RED, GREEN ON OLD:** `aBadgeNeverSitsAtAnotherBlocksPlace` (U1's phantom shape: deep fans 40/70/100/119) and `aWidthChangeInWriteKeepsEachBadgeHome` (same deep fans) both PASSED on the pre-fix tree, their premises holding (the on-screen fan badged at home; at least one deep fan genuinely unlaid). Read as found: in this harness the DEEP unlaid fans carry no badge on the old tree either — consistent with the trace's own caveat that a fragment TK2 ESTIMATED reports a guessed frame (below the viewport, so it never intersects), while only the unlaid `.none` fragments just past the viewport read `.zero` and stack (exactly `blockOnesBadgeIsItsOwnAlone`'s entries 8–18). So these two pins are HOLLOW on old as written (green on both sides unless W2 says otherwise); U1's deep-fan phantom is not reproduced by them; the walk's (a)/(c) look at the live app. Not traced further under the claim. **(3) THE CHARACTERIZATION, DESIGNED GREEN, IS RED:** `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` fails `:397` "a fragment far below the viewport is not laid out" — in the test host, after `layoutViewport()` the deep fragment reads `.layoutAvailable`. Its other facts held (`:390` cold `.zero`/`.none`, `:395`, `:401` the width change returns the first fragment to `.zero`/`.none`, `:405` the degenerate-rect intersect). The pin builds a bare `NSTextView` and touches no product code, so it will be red on the fixed product too (W2): a defect of the characterization's line 397 in the test host (the probe's bare-script measurement differs here), not a product regression. Nothing changed under the claim; reported for the orchestrator |
| W2 | `run-w2-batch.sh` — 271 suites on `vx246-u4`; a red re-run alone once; standing reds named (VX-167, VX-245, VX-115) | DONE (03:07:47 → 03:18:26) — "✘ Test run with **1825 tests in 271 suites** failed after 593.712 seconds with 62 issues (including 4 warnings and 4 known issues)", EXIT 65 (`u4/logs/w2-batch.log`, `u4/w2-batch.xcresult`): **1,805 passed · 17 gated skips · 3 failed**. The skips are the gated set (the 7 UNKEYED-oracle singleton tests, the List-face harness's 5, the MCP capture harnesses); the 4 known issues are `IndexTierMetricsTests`' standing `withKnownIssue` (overTwoBlankLines, both voices, two tests); the 4 warnings are U3's door-pin harness noise ("@Dependency(\.withRandomNumberGenerator) has no test implementation", test «unknown»). **The pins on the fixed product:** `BookcaseOutsideWriteTests` 2/2 GREEN (the join pin red on old → green: **VX-231 proven by its pin**); `FanBadgePlacementTests` `blockOnesBadgeIsItsOwnAlone` GREEN (red on old → green), `aBadgeNeverSitsAtAnotherBlocksPlace` and `aWidthChangeInWriteKeepsEachBadgeHome` GREEN (green on BOTH sides — hollow as written, W1's finding). **The three reds, each re-run ALONE once (03:18–03:21, `u4/logs/w2-rerun-*.log`):** (1) `DestructiveUndoWarningTests.redoNeverAsks()` (`:141–143`) → **green alone** — VX-167's standing load flake, not a regression. (2) `FanBadgePlacementTests.textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects()` `:397` → **reproduces alone** — the characterization's line 397 ("a fragment far below the viewport is not laid out") does not hold in the test host on EITHER tree (it touches no product code): a pin defect, not a regression. (3) **`FanBadgePlacementTests.theBookEditorPutsEveryBadgeHomeAfterAWidthChange()` → REPRODUCES ALONE, 50 issues — A REAL RED ON THE FIXED PRODUCT (VX-230's inline half):** `:295` "every fanned block keeps a badge after the width change" — **51 of 80**; `:141` ×49 "entry N's badge at y=…, its block's first line at y=…" — entry 3 at 430 vs 437, 4 at 573 vs 580, 6 at 852 vs 866, … 73 at 10,844 vs 11,501, 75 at 11,164 vs 11,821 (every badge ABOVE its line, the gap growing down the post — positions of a layout with fewer wrapped lines than the one now laid out); **no stack line** (the old tree's 13-at-y=8 disc is gone). So the fix removes the disc in this pin but does not put the inline editor's badges home after a width change, and drops 29 of them. Not fixed under the claim; a read-only trace follows after the release (below). No VX-245 or VX-115 suite is in the set |
| F | the fixture through File ▸ Import… (the two long notes → the Pool; the folder → an unshelved book) | DONE (03:22) — the fixed app `open -n` 03:21 (pid 45161, 1380×900 at (60,36), **Study, light, the Bookcase; no What's New sheet, no lock screen**; `u4/w3/launch/w0.png`); File ▸ Import… (by its menu item) → the Open panel ⇧⌘G to `u4/fixture/`, all three items selected (`import-01`, `import-02`), Import → **"Imported 1 book and 2 notes to the Pool · ⌥⌘Z undoes"**, the new row **"vx230-book · 4 notes · 2 ch · 19,086w"** (`import-03/w0.png`). Plan deviation, said: the fixture lives under the evidence folder, not the scratchpad (the Open panel reads it plainly) |
| W3 | the walk, Study then Terminal: (a) Write first open · (b) a book note in Write · (c) scrolled · (d) Outline + a width change · (e) Index / Book / Read · (f) first launch · (g) the Bookcase row after a join from the Pool's Add to Book | **STUDY HALF DONE (03:22–03:33)**, captures `u4/w3/study/` (the read-only AX probe `badges` finds 0 buttons — the overlay's `NSButton`s are not in the window's AX tree — so the captures and their crops are the evidence). **(a) PASS** — ⌘K ▸ "vx230 long" → Write, "block 1/140": block 3's ⑂2 at block 3's first line, NO badge at block 1 (one take), no dark disc (`a-write-first-open`, crop `a-badge-column-crop`). **(b) PASS** — ⌘K ▸ "vx230 book opening" (chapter one's first note) → Write: block 1's ⑂2 is ONE muted badge like blocks 2–4's, block 5 (single take) bare (`b-book-note-write`, crop `b-badge-column-crop`). **(c) PASS** — the long note again; `walk-scroll` in guarded small steps (5, 9 ×4, 3): block 40's ⑂2 arrived AT block 40's first line as it came into view (`c3-block40-in-view`); back to the top (−15 ×3): block 1 bare, block 3 badged (`c4-back-at-top`, crop). **(d) MIXED — the top PASSES, the deep FAILS (a live finding matching W2's red):** ⌘K ▸ "vx230-book" → Outline (cards collapsed; a card-body click and the bullet click did nothing, `d2`/`d3`) → **expand all** (`d4`: the read tier, blocks 1–4 each ⑂2 at its line) → a click into block 2 → the live inline editor ("this note · editing", block 2/70; `d5`, crop `d5-badge-column-crop`): each visible ⑂2 at its own line, no disc. **The width change** (the window set to 1100 wide by System Events, `d6`; back to 1380, `d7`): the text rewrapped and every VISIBLE badge at the top of the note followed its block's new first line, no disc. **Then deep in the same live note** (scrolled ~63 units to blocks 49–54, `d8`, crop `d8-deep-misplaced-crop`): **the badges are NOT at their blocks** — blocks start at view y≈172 (049), 314 (050, single take), 434 (051), 575 (052), 695 (053), while the ⑂2s sit at ≈291 (049's last line), 433, 552 (051's last line), 672 (052's last line): stale offsets from the earlier layout, one coinciding with 051's start by chance. No stack anywhere. This is the live face of W2's `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` red (badges above their lines, the drift growing down the post): **VX-230's inline half is NOT fully fixed** — the disc is gone, but after a width change the inline editor's badges below the first screen stay where the old layout put them. **(e) PASS (as drawn)** — Index (`e1-index`): the index read tier draws NO badges (nothing at block 1, no disc); Book (`e2-book`, the two-page spread, left page live): every ⑂2 at its own block on both pages; Read (`e3-read`): the calm page draws no badges. **(f) PASS** — the long note open in Write → quit BY BUNDLE ID (`pgrep` empty) → `open -n` (pid 52705; the Bookcase, no sheet, no lock, `f0-relaunched`) → ⌘K ▸ "vx230 long" at once: block 3's ⑂2 home, block 1 bare, no disc (`f1-first-launch-write`, crop). **(g) PASS — VX-231 live:** View ▸ Open Beside (`g0`: two panes — the long note's read tier left, "vx230 book opening" right, every badge home in both half-width layouts) → the right pane to the Pool, the left to the Bookcase (`g1`, the BEFORE: **"vx230-book · 4 notes · 2 ch · 19,086w"**) → the Pool row "vx230 long" ▸ add to book (the first click only focused the pane) → the "Add to Book" sheet (`g2`) ▸ vx230-book → **WITHOUT leaving or re-entering the Bookcase, its row reads "5 notes · 2 ch · 28,508w"** (`g3-after-join`, crop `g3-row-crop`) — +9,422 words, exactly the long note's "9,422w in note"; the Pool "14 notes". **TERMINAL HALF DONE (03:33–03:40)**, captures `u4/w3/terminal/`: Settings from the app menu (`v0`, Study) → General ▸ Theme ▸ **Terminal** pressed by AX (the radio's AXPress after the guard; `v1`) → Settings closed by its own close button (`v2`, the split still up). **(g) PASS** first, the split being up: the Bookcase pane read **"vx230-book · 5 notes · 2 ch · 28,508w"** (`g1-before`) → the Pool pane's "vx230 long two" ▸ add to book ▸ the sheet (`g2`) ▸ vx230-book → the Bookcase pane, never re-entered: **"6 notes · 2 ch · 38,086w"** (`g3-after-join`, crop) — +9,578, the second note's words. View ▸ Close Split. **(a) PASS** — "vx230 long" in Write: block 3's ⑂2 at its line, block 1 bare, no disc (`a-write-first-open`, crop). **(b) PASS** — "vx230 book opening" in Write: block 1's ⑂2 ONE muted badge like 2/3/4/6, block 5 bare (`b-book-note-write`). **(c) PASS** — scrolled (9 ×5): block 40's ⑂2 at block 40's first line (`c1-scrolled`); back (−15 ×4): block 1 bare, block 3 badged (`c2-back-at-top`, crop). **(d) MIXED, as in Study, plus a second residual:** Outline (`d1`, cards collapsed; the tooltip says "Click to open this note in the full editor; • unfolds it here") → expand all (`d2`: the read tier, 1–4 and 6 badged at their lines) → a click into block 2 → live ("editing", block 2/70) — **`d3`: ONLY block 1 wears a ⑂2; fanned blocks 2, 3, 4 and 6 are BARE** (a missing-badge face: no disc, no phantom, but fans unbadged on the live inline editor right after it mounts) → the width change to 1100 (`d4`): every visible fanned block now badged at its line → back to 1380 (`d5`): every visible badge at its line, no disc → deep (9 ×7, blocks 54–60, `d6`, crop `d6-deep-misplaced-crop`): **the badges are NOT at their blocks** — blocks begin at view y≈95 (054), 265 (056), 356 (057), 447 (058), 538 (059) while each ⑂2 sits ~30–35 below its block's start (123, 300, 391, 482, 574): positions from the narrower 1100 layout, never moved after the widen-back. The unfanned 055 and 060 are bare. **(e) as drawn** — Index (`e1-index`) draws no badges; **Book (`e2-book`): the right page (read tier) badges 1–4 at their lines, but the LEFT page — the live inline editor — badges ONLY block 1** (crop `e2-book-left-page-crop`); re-reading Study's `study/e2-book` shows the SAME (the left live page badges block 1 alone, 2–4 bare) — missed at the Study pass, corrected here; Read (`e3-read`) draws none. **(f) PASS** — the long note open → quit BY BUNDLE ID → `open -n` (pid 59368; the Bookcase, no sheet, no lock, the row already "6 notes · 38,086w"; `f0-relaunched`) → ⌘K ▸ "vx230 long": block 3 badged at home, block 1 bare, no disc (`f1-first-launch-write`, crop). **W3's verdict, both voices:** the DISC and the PHANTOM are gone everywhere walked (Write at first open, first launch, scrolled; the book's read tier; the spread's read page) — her sightings' faces are fixed; **VX-231 PROVEN live in both voices**; **VX-230's INLINE editor is NOT done** — (i) after a width change its badges below the first screen stay at the old layout's offsets (= W2's red, live), and (ii) on the live inline editor (Outline after the click, the spread's live page) fanned blocks can stand UNBADGED after it mounts, only block 1 badged |
| C | cleanup: the Debug app quit by bundle id; prefs 0 keys differ; `restore.sh` → "Restored (verified)" + cmp SAME; her user-scope fingerprint AFTER; `Tools/stage release --who vx246-u4`; the result line | DONE (03:40–03:41) — the Debug app quit BY BUNDLE ID (03:40, `pgrep` empty; no shim, no xcodebuild); **no new backup** in the dev `Backups/` from the window's three launches (only the A1 folder under `safety-copies/`); **prefs:** the window added 25 keys (`currentBlock.*` ×6, `surfaceSize.outline.*` ×18, `surfaceSize.flow.*` ×1), removed 2, changed 8 → `defaults import` of `prefs-pre.plist` + `defaults delete` of the 25 → re-export **1,549 keys, 0 differ** (`u4/prefs-post.plist`); **the dev store:** `restore.sh …/scale-prestage-20261014T090551Z` → **"Restored (verified)"** (`u4/logs/restore.log`), a second `cmp` of all five files **SAME**, and the sha256 set equals the pre-window hashes (`store-hash-restored.txt` = `store-hash-pre.txt`) — the posture handed over (Standard, unlocked, Study voice in the store); her user-scope servers AFTER `['linear-server', 'variorum']`, **`bc64543e2f4e8e58` — SAME** (`u4/userscope-post.txt`); no stray `default.profraw`; the fixture folder deleted (the generator stays in the scratchpad); the tree clean. **RELEASED 03:41:03 MDT** (`Tools/stage release --who vx246-u4` → STAGE FREE), 35 of the 90 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx246-u4` 03:05:45–03:41:03 MDT, RELEASED (35 of 90 min).
- **W1** (the red product): 7 tests, 5 failed, 67 issues; NO premise line. As designed: `blockOnesBadgeIsItsOwnAlone`, the
  book-editor pin, and the Bookcase join pin red; the P1 guard green. NOT as designed: the two deep-fan Write pins GREEN on old
  (hollow as written), and the TK2 characterization RED at `:397` (a test-host fact).
- **W2** (the fixed product): 1,825 tests in 271 suites, 1,805 passed, 17 gated skips, 3 failed. VX-167's `redoNeverAsks` was
  green alone. The characterization's `:397` reproduced alone (both trees; no product code). **`theBookEditorPutsEveryBadgeHome
  AfterAWidthChange` REPRODUCES ALONE on the fixed product** (51 of 80 badges, each off its line). `BookcaseOutsideWriteTests`
  2/2 green.
- **W3**, the walk in both voices on the imported fixture:
  - **Proven:** VX-231, live (the row follows a Pool Add to Book: 19,086w → 28,508w Study, 28,508w → 38,086w Terminal).
  - **Fixed everywhere walked:** the disc and the phantom on a one-take block 1 (Write first open, first launch, scrolled; the
    read tiers).
  - **NOT fixed:** the inline book editor. Below the first screen its badges stay at the old layout's offsets after a width
    change (W2's red, seen live, both voices). Right after it mounts, fanned blocks can stand unbadged (Outline in Terminal; the
    spread's live page, both voices).
- **Posture: Standard/unlocked, cmp-SAME vs A1** (Study voice in the restored store); prefs re-exported and diffed, 0 keys
  differ. Her user-scope MCP fingerprint is SAME (`bc64543e2f4e8e58`).
- The A1 copy `scale-prestage-20261014T090551Z` is the coordinator's to prune.

**THE TRACE OF THE ONE REAL RED (read-only, after the release; by reading, NOT verified by a run — the orchestrator's to take
up).** The red: `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` on the fixed product. After the width change, 51 of 80
badges remain, each above its block's line by 7 pt growing to 657 pt down the post, and none stacked. The same class shows
live in both voices (W3 (d)/(e)). The fixed `refreshBadges` (`EditorViewModel.swift`) does three things on the inline surface
(`scrollView == nil`):
- it reads each fanned block's first fragment with `[.ensuresLayout]`;
- it keeps a frame only in `.layoutAvailable`;
- it keeps a badge only when the frame `intersects(visible)`, where `visible = viewportBounds(of:)` = **`textView.bounds`**.

Two candidate mechanisms, both consistent with the evidence:
- **(A) The missing badges.** The badge hop runs from the width door BEFORE the coordinator's remeasure, which is what grows
  the text view's HEIGHT to the narrower (taller) post. So at the hop, `textView.bounds` still has the old height, and every
  fanned block laid out below that old height fails `intersects(visible)` and gets no badge. Nothing re-runs the pass after the
  remeasure (no generation bump; no scroll observer on this surface), so they stay missing. That is 29 of 80 in the pin, the
  bottom third. The live "only block 1 badged after mount" (Outline in Terminal; the spread's live page, both voices) may be the
  same class: a pass that ran before the inline surface's height settled.
- **(B) The misplaced badges.** The frames the hop reads are not the final layout's: the drift grows down the post, as if every
  fragment above contributed a stale line count. The fix's premise, "a mid-document `.ensuresLayout` read is positionally exact"
  (`probes/probe4`), was measured on a document laid out cold, not right after a width change. After the hop, the remeasure
  lays the whole post out again at the final width and, again, no badge pass follows.
  - Live, after narrowing and widening back, the deep badges sit BELOW their lines: positions from the narrower layout.
  - In the pin (narrowing only) they sit ABOVE: positions from a wider layout.
  - Either way, it is the last pass's stale read.

**The common factor:** the fix makes the hop's read force layout, but it does not make the hop run AFTER the layout the inline
surface settles on. That is the U4 trace's own "not built, argued" item 3 (a re-run after
`InlineEditorSurface.Coordinator.remeasure`), set aside because `EditorView.swift` is on vx-282's file list. Not fixed here; the
cure's shape is the orchestrator's call (and vx-282's lane, if it lands in `EditorView.swift`).

**The other W1/W2 deviations, for the orchestrator:**
- The two deep-fan Write pins (`aBadgeNeverSitsAtAnotherBlocksPlace`, `aWidthChangeInWriteKeepsEachBadgeHome`) are green on
  both trees: hollow as written, because their deep fans are ESTIMATED by TK2 in the harness and never read `.zero`.
- The characterization's `:397` does not hold in the test host on either tree.

Both are pin defects, not product defects. Write's own faces walked clean in both voices.

### THE ORCHESTRATOR ON U4's WINDOW (2026-10-14, ~03:50 MDT)

- **VX-231 is accepted as proven:** the pin went red to green, the P1 guard is green, and the live row follows an
  outside join in both voices. It closes at the merge.
- **VX-230 is NOT closed.**
  - Write's half is proven. The inline book editor's half fails: W2's real red, seen live in both voices.
  - The runner's trace is plausible but unrun. U4b re-traces it before fixing.
  - The cure's one call is in `EditorView.swift`, a vx-282 file. It is cleared for that call alone (a different
    function from vx-282's two touches), and vx-282 was messaged.
- **The pins.** Two are hollow as written (green on old, because TK2 estimates in the harness) and one characterization
  is defective (red on both trees). By the hallucination guard, a pin green on both sides proves nothing: U4b
  re-designs or removes them, and the record says which.
- **Ruling 2 moves to U4b,** so the two small app-side fixes share one window. U5's live round keeps the real-client
  check of ruling 2.
- **The cutover.** U4's implementer was at ~513k. U4b is a FRESH implementer: the remainder is small, but it needs a
  clear head on the editor seam.

## U4b UNIT RECORD — the inline editor's badges, and ruling 2: VX-230's remainder · ruling 2 (opus-implementer, from 2026-10-14 ~04:00 MDT)

**What this unit has NOT done (said first; the state at READY, 2026-10-14 ~05:00 MDT):** nothing has run on a Mac yet (every pin is a Mac
pin: its red-on-old run is W1, its green W2); no stage window has run (no batch, no walk — READY, the stage not claimed); no QUESTIONS entry, canon edit or ticket (the
orchestrator's at the merge). Zero `Sync/`, custody, Keychain, schema, `Server/`, `BlockRangeIndex`, `PaneSurface`,
`runStructural`, VX-281's lane; in vx-282's files, ONLY the one cleared call in `InlineEditorSurface.Coordinator.remeasure`
(`EditorView.swift`), nowhere near its two touches (the fan-panel sheet, the selection delegate).

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon; this record's header, THE UNITS, the hard
rules, LIVE STATUS, Cross-run coordination, ORCHESTRATOR'S PROVISIONAL RULINGS, the U4 and U4b BRIEFs, U4's UNIT RECORD
whole, U4 STAGE RUN whole, THE ORCHESTRATOR ON U4's WINDOW; `notes/plans/mcp-pane-and-docs-kickoff.md` whole;
**`notes/TEXTKIT2_NOTES.md` whole, BEFORE any editor-seam edit**; `notes/SessionResiliencyProtocol.md` whole;
`notes/plans/phase-18l-navigation-feel.md`'s ITEM 2 (the settle net — the 631-pt class). Code read: `EditorView.swift`
(`EditorView.surfaceColumn` — `@State inlineHeight = 24`, `.frame(height: inlineHeight)`; `EditorSurface.Coordinator`;
`InlineEditorSurface` + its `Coordinator` whole — `install`, the composed width and settle doors, `scheduleRemeasure`,
`displayPassSettled`, `remeasure`; `BadgeOverlayController`; `ScrollAnchorController`), `EditorViewModel` (`attach`'s two
doors, `overlayLayoutDidSettle`, `refreshBadges` as U4 left it, `pushBadgesToSink`, `viewportBounds`, every
`overlayGeometryGeneration` bump, `keepingReadingPosition`, `restoreReadingAnchor`, the projection arms),
`EditorTextView` (`onLayoutSettle`/`viewWillDraw`, `onWidthReflow`/`setFrameSize`/`applyFrameHeight`,
`makeInlineEditor`), `PaneMeasurement.height`/`extent`, `EditorProjectionPolicy.decide`, `WorkspaceModel` whole to line
420 (`select`, `reportingFocusMove`, `reportingDepartures`, `notesDeleted`, `focus`, `openBeside`), `RootView`'s
`.variorumNotesDeleted` listener, `WingFollow.wire`; the pins `FanBadgePlacementTests` whole, `InlineEditorWindowTests`
(`makeInlineWindow`, the whole-post / budget / width-reflow pins, `withInlineEditor`), `FocusHandoffTests`'
`withEditorWorld`/`focus`, `EditorHarness`, `NoteDeletionNavigateAwayTests`, the `notesDeleted` arms of
`MCPHerEditorDoorTests` and `DocumentImportDoorTests`.

**Surfaces (planned):** THE EDITOR SEAM — `EditorViewModel.refreshBadges` (U4's function; no other function) and the ONE
cleared call in `InlineEditorSurface.Coordinator.remeasure`; the workspace — `WorkspaceModel.select`/`notesDeleted`
(VX-283's road, no running session lists it); Mac pins in `FanBadgePlacementTests.swift` and
`NoteDeletionDoorsTests.swift`. The TK2 probes live in `notes/plans/vx246-screens/u4b/probes/` (gitignored).

### LIVE STATUS — U4b's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + the trace re-run (confirm / correct the runner's) + the design, before code; the TK2 probes 5–7 | DONE (this commit) — probes `u4b/probes/probe5.swift`…`probe7.swift` + `*-output.txt` (macOS 27.0, 26A428) |
| 1 | the pins FIRST, on the pre-fix tree (U4's fix in place): the inline mount pin (new), the inline width pin (U4's, kept), the Write phantom pin RE-DESIGNED, the hollow Write width pin REMOVED, the characterization CORRECTED + the poison characterization (new), ruling 2's pin (new) | DONE (this commit) — `FanBadgePlacementTests.swift` (`theBookEditorBadgesEveryFanRightAfterItMounts` new; `aBadgeNeverSitsAtAnotherBlocksPlace` re-designed; `aWidthChangeInWriteKeepsEachBadgeHome` removed; the characterization's `:397` line removed; `textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace` new — probe9 ran its exact sequence first: 10,574 vs 11,570, deep 10,378 vs 11,374, after one pass 0.0 on every fan, top OR deep pass), `NoteDeletionDoorsTests.swift` (`NoteDeletionNavigateAwayTests.aNavigateAwayNeverTakesHerFocus` new). No warning in a touched line (the one at `NoteDeletionDoorsTests.swift:478` is `theActAnnouncesWhatItDeleted`'s, pre-existing) |
| 2 | the RED products: `DerivedData/vx246-u4b-red` (the pins commit: U4's fix, no U4b fix) and `DerivedData/vx246-u4b-red-pre-u4` (the pins commit with U4's `refreshBadges` hunk reverted in the working tree — for the re-designed Write pin only) | DONE — **`vx246-u4b-red`** = `7209cf2d`'s tree (an APFS clone of `vx246-u4`, `build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0; `u4b/logs/mac-red-build{,-2}.log`). **`vx246-u4b-red-pre-u4`** = `7209cf2d` with `91a56a7a`'s `EditorViewModel.swift` hunk reverse-applied in the working tree (announced `8fae1438`; a clone of `vx246-u4b-red`, `build-for-testing` → SUCCEEDED, EXIT 0; `u4b/logs/mac-red-pre-u4-build.log`), then RESTORED by `git checkout --` with an empty `git diff`. **Verified by symbol:** `EditorViewModel.refreshBadges()` measures 4,276 bytes in `vx246-u4b-red` (= `vx246-u4`, U4's body) and 3,336 in `vx246-u4b-red-pre-u4` (= `vx246-u4-red`, the pre-U4 body); both test bundles carry `theBookEditorBadgesEveryFanRightAfterItMounts` and `aNavigateAwayNeverTakesHerFocus` |
| 3 | VX-230's inline fix — `refreshBadges` (no forcing read; the inline region is the whole post) + the one cleared call in `remeasure` | DONE (this commit) — `EditorViewModel.refreshBadges` ONLY: the read is `options: []` on both surfaces (U4's `.layoutAvailable` check kept); `wholePost = scrollView == nil` skips the frame clip; U4's R1-1 oracle line for the forcing read removed with the read; the doc rewritten to the measured mechanism. `EditorView.swift`: ONE call, `if reportHeight != nil { model.refreshBadges() }` at the end of `InlineEditorSurface.Coordinator.remeasure` (vx-282's two touches untouched). Compiled in the fixed product (piece 5) with no warning in a touched file |
| 4 | ruling 2's fix — `WorkspaceModel.select(_:in:takingFocus:)` + `notesDeleted` lands in place | DONE (this commit) — `select` gains `takingFocus: Bool = true` (every existing caller unchanged): `false` skips `focusedPane = pane` and raises `onFocusedSubjectChanged` only when the landing pane is the focused one; a DEBUG `assert` that an in-place landing is never a note. `notesDeleted` passes `false`. Compiled in the fixed product (piece 5) with no warning in a touched file |
| 5 | the FIXED product `DerivedData/vx246-u4b` + the headless finals (core · MCP · workbook) | DONE — **the fixed product** `vx246-u4b` = `cd843647`'s App/Sources (both fixes + the pins; an APFS clone of `vx246-u4b-red`, `build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0, no warning in a touched file; `u4b/logs/mac-build-for-testing.log`), **verified by symbol:** `refreshBadges()` 3,696 bytes (neither U4's 4,276 nor the pre-U4 3,336) and `WorkspaceModel.select(_:in:takingFocus:)` present. **Headless, `swift build --build-tests` then `swift test --skip-build` on the same tree, EXIT 0: `VariorumMCPTests` 236 / 49 · `VariorumCoreTests` 2,826 / 326 · `StringsWorkbookTests` 40 / 6**, zero ✘, the skip set the standing gated nine — identical to U4's finals (no core line moved; `u4b/logs/p5-finals.log`) |
| 6 | THE STAGE WINDOW plan (claim `vx246-u4b`) → READY | DONE (this commit) — **READY for stage**; the stage NOT claimed. The scripts `u4b/run-w1-red.sh` (W1a + W1b) and `u4b/run-w2-batch.sh` (304 suites, `u4b/stage-suites.txt`, every name a declared type) parse (`zsh -n`); the fixture generator copied to `u4b/gen_fixture.py` (the scratchpad copy is not durable); the single-test `-only-testing:…/<test>()` form checked against U4's alone-rerun log. THE STAGE WINDOW below |

**No revert is in flight** (the pre-U4 build's revert ran and was restored: `git diff` empty after `git checkout --`, before any fix).

### The trace, re-run (inputs → wrong output) — the runner's trace CONFIRMED in shape, CORRECTED in two places

**Measured first, on a bare TK2 rig that replays the inline surface's order** (`u4b/probes/probe5`–`7`: an inline-shaped
`NSTextView` — not vertically resizable, width-tracking container, 8-pt inset — in an un-ordered window, the pin's own
120-block text; `displayIfNeeded` does not draw an un-ordered window, so the display pass's TK2 viewport layout is
`layoutViewport()` called explicitly; numbers are view-space y):

1. **A layout that runs AHEAD of unlaid predecessors poisons the next whole walk.** Cold, a whole `.ensuresLayout` walk
   with nothing laid out before it is EXACT (11,570 pt = the settled layout = a fresh view's). But a sparse mid-document
   `.ensuresLayout` read first (exactly U4's fixed badge read on the inline surface), THEN the whole walk: 10,574 pt, the
   fans up to **996 pt** off the settled place (probe7 `[mount]`). After a width change 700 → 420: the walk with no read
   ahead of it is exact (18,050); after U4's sparse read, the read itself and the walk sit up to **1,662 pt** off
   (probe5: S vs settled, R = S); after a viewport pass over a MID-document window (her scrolled-deep walk), the walk is
   **1,600 pt** off (probe7 `[scrolled deep]`). TK2 places a fragment laid out ahead of its predecessors at an estimated
   offset, and the whole walk does not re-position it.
2. **The next viewport pass re-positions EVERY fragment to the settled layout**, and a read taken after the settle net's
   heal is exact: heal-read vs settled 0.0, settled vs a fresh view 0.0, stable over ten further passes (probe5, all
   three widths; probe7 `[scrolled deep]`).
3. **So U4's premise was false, and its probe could not see it:** probe4 compared a sparse `.ensuresLayout` walk with the
   whole walk run right AFTER it, and both carry the same poison. This is TEXTKIT2_NOTES §3's 18l finding ("the first full
   measure after a reflow can be 1–5 % off the layout the next display pass settles to", the settle net's reason), with
   its mechanism now identified: out-of-order partial layout.

**The red, traced through the code (the pin `theBookEditorPutsEveryBadgeHomeAfterAWidthChange`, and her live (d)/(e)):**
- **(A) the region — CONFIRMED, with a correction.** `refreshBadges` keeps a badge only when its frame `intersects`
  `viewportBounds` = **`textView.bounds`** on the inline surface — the frame SwiftUI LAST APPLIED. On a width change the
  model's width door queues its badge hop before the coordinator's remeasure (`install`'s composed `onWidthReflow`: the
  model's handler first), so the hop clips to the OLD height: fans laid out below it get no badge (29 of 80 in the pin).
  **The correction:** the remeasure does NOT grow the view in the app. It writes a SwiftUI `@Binding`
  (`InlineEditorSurface.install`'s closure → `EditorView.inlineHeight`), and the frame lands on SwiftUI's next pass. So a
  badge re-run inside `remeasure` that kept the `bounds` clip would still clip to the old height in the app (the pin's
  harness sets the frame synchronously, which hides this).
- **THE MOUNT — the same clip, traced (her "only block 1 badged"):** `@State inlineHeight = 24`, so a freshly mounted
  inline editor is 24 pt tall until its first report lands. Every badge pass before that (the model's width hop at the
  mount's 0 → W width, renderFull's tail, the post-edit settle hop) badges only what lies in the top 24 pt — block 1 —
  and marks the generation delivered; the frame then grows with NO width change and NO storage edit, so nothing
  re-runs the pass. Her Terminal `d3` and both voices' spread `e2` exactly.
- **(B) the positions — CONFIRMED in shape, the cause CORRECTED.** The runner read "frames that aren't the settled
  layout's". The cause is fact 1: U4's own forcing read (sparse `.ensuresLayout` from each fanned block) lays the deep
  fans out ahead of their predecessors, so the badges AND the remeasure's report sit off the settled layout. The settle
  net (`displayPassSettled`) heals the HEIGHT on the next display pass, but no badge pass follows the heal. In the pin
  the drift is upward and grows down the post, 7 → 657 pt (the poisoned layout is short at 420, as in probe5). Live after
  narrow-then-widen it was downward (the poisoned layout is TALL when widening — probe5 `420 → 700`).
- **The common factor, as the runner said:** nothing re-runs the badge pass after the layout the inline surface settles
  on. The settle is the heal's remeasure (fact 2), so the re-run belongs in `remeasure`, and on a region the frame's
  timing can't clip.

### The design (argued; the code follows the pins)

1. **`EditorViewModel.refreshBadges` (U4's function):**
   - (a) **No forcing read on either surface** (`options: []`, as before U4). U4's `.layoutAvailable` state check STAYS
     (Write's proven half: an unlaid fragment is no position).
   - (b) **The inline surface's badge region is the whole post** (no `bounds` clip when `scrollView == nil`). The doc's
     own contract ("whole-post overlay work is the accepted inline cost model") made literal. The frame's height is
     SwiftUI's to apply later, and a laid-out fan below a frame that hasn't grown yet is still a fan of this post.
   - The R1-1 oracle line U4 added for the forcing read goes with it (no forcing read is left to count).
2. **`InlineEditorSurface.Coordinator.remeasure` — the one cleared call:** after the report, `model.refreshBadges()`.
   - Every remeasure runs the whole `.ensuresLayout` walk first, so the pass reads a fully laid-out post: the mount's
     first report, a width change, an update pass, a storage edit — and **the settle net's heal**, the moment the
     positions are the settled ones (fact 2).
   - Unconditional, never gated on "the height moved". A coalesced remeasure can be superseded and land AFTER the
     model's own settle hop, and that hop no longer forces layout, so the remeasure must always deliver.
   - Skipped once `uninstall` has run (`reportHeight == nil`), so a late hop never refreshes a dismantled surface.
3. **Cost (P1):** the inline surface's model has been whole-post since Phase 10. The remeasure already walks the whole post
   per edit (`PaneMeasurement`'s walk). The re-run adds one O(fans) badge pass, plus the decor pass that rides it (whole-
   post on this surface, and skipped entirely in the calm default), per COALESCED remeasure, not per trigger. The pinned
   per-keystroke budget (`InlineEditorWindowTests.inlineHeightMaintenanceStaysInsideTheFrameBudgetAtTenThousandWords`:
   keystroke + remeasure < 16.7 ms at 10k words) carries it, and W2 runs it.
4. **What this does NOT change:** the detail editor (Write) — its region, its reads, its width road; the decoration
   pass's own reads and region (VX-327's, below); `viewportBounds`; the settle net; the generation hop.
5. **Said plainly — a transient, argued not measured:** between a remeasure that grew the content and SwiftUI applying the
   new height, a badge may stand below the text view's current frame. AppKit lays out (the hosting view's update) before
   it draws in the same cycle, so it should never be drawn there. W3's mount rows look for a stray badge below the editor.
6. **VX-327, observed, not claimed:** `refreshDecorations` rides every `refreshBadges`, so on the inline surface the
   decorations are also re-read after each remeasure, the heal included. Their own reads (`.zero` for unlaid fragments)
   and their `bounds`-clipped region are unchanged, so VX-327 stays open for its red-first probe. It gains one fact: the
   inline decor region is the same transiently-short frame as the badges' (A).

**Ruling 2 — the mechanism (inputs → wrong state):** a note shown in pane 2 is deleted while her caret is in pane 1
(focused) → `.variorumNotesDeleted` → `RootView`'s listener → `WorkspaceModel.notesDeleted` → `select(.library, in: pane2)`
→ `select` writes `focusedPane = pane2` (`WorkspaceModel.swift:186`) and raises `onFocusedSubjectChanged` → her focus
(and the one live surface, `PaneMount`) moves to pane 2; her note drops to the read tier. **The fix:** `select` gains
`takingFocus: Bool = true` (the ONE door keeps its recording and departure halves; every other caller unchanged), and
`notesDeleted` passes `false`: the dead pane goes to the Library IN PLACE. The focused-subject signal is raised only when
the landing pane IS the focused one (its subject changed, as now). A focused pane showing the dead note still lands in
place and stays focused (the ruling: "only a pane that is itself focused stays focused, as now"). `takingFocus: false`
is asserted (DEBUG) to carry a non-note destination, so the same-note rule's focus move can never meet it.

### The pins (planned; each RED on its old tree on its designed line — the expectations W1 checks)

- **`FanBadgePlacementTests.theBookEditorBadgesEveryFanRightAfterItMounts` (NEW — the mount, her `d3`/`e2`):** the
  inline editor mounted at the app's shape — a 24-pt frame, a width change at the mount (600 → 700), the coordinator
  installed, and the height report applied on the NEXT main-queue turn (SwiftUI's binding, never inside the report),
  80 of 120 blocks fanned. **RED on `vx246-u4b-red`** on "every fanned block wears its badge right after the mount"
  (expected: 1 of 80 — block 1 alone, the 24-pt clip) and the home lines. The async report is load-bearing: a fix that
  re-ran the pass in `remeasure` but kept the `bounds` clip would stay red here.
- **`theBookEditorPutsEveryBadgeHomeAfterAWidthChange` (U4's, KEPT unchanged):** red on the U4 tree, recorded at U4's W2
  (51 of 80, 7 → 657 pt off). Re-run red in W1.
- **`aBadgeNeverSitsAtAnotherBlocksPlace` (RE-DESIGNED — U1's phantom, Write):**
  - **Why it was hollow:** its deep fans (40/70/100/119) are ESTIMATED in the harness, so their guessed frames lie below
    the viewport and never intersect it.
  - **The re-design** fans a contiguous band past the viewport (entries 5–30), where TK2 leaves fragments in `.none` with
    a `.zero` frame, like `blockOnesBadgeIsItsOwnAlone`'s red entries 8–18 at W1. Block 1 keeps ONE take.
  - **The premise line names the trigger state:** at least one fan reads `.none` with a `.zero` frame. If TK2 ever
    estimates all of them, the premise goes RED loudly instead of the pin going hollow.
  - **RED on the pre-U4 tree** (`vx246-u4b-red-pre-u4`) on the phantom ("⑂ at block 1's place, block 1 has ONE take")
    and stack lines. GREEN on `vx246-u4b-red` (U4's Write half covers it).
- **`aWidthChangeInWriteKeepsEachBadgeHome` — RECORDED HOLLOW AND REMOVED.**
  - **What it claimed:** Write's width road. Its old tree has no defect to be red against (W1: green, the end state clean
    on old).
  - **Why not re-design it:** making it red would borrow the phantom pin's band mechanism, a second copy of one red.
  - **What carries Write's width road:** W3 gets a Write width-change row, as use evidence.
- **`textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` (CORRECTED):**
  - **Removed:** line 397's claim. "A fragment far below the viewport is not laid out" is false in the host on both
    trees. The host lays out the document's LAST fragment in the viewport pass, which U4's own probe output also showed
    (`p159 state=3`), and the badge road depends on no fact about that fragment.
  - **Kept:** its four held facts (cold `.zero`/`.none`; the width change's return to `.zero`/`.none`; the degenerate-rect
    `intersects`).
- **`textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace` (NEW characterization — fact 1 + fact 2, on
  probe7's exact rig):** a whole walk with nothing laid out ahead is exact; a sparse read ahead poisons it; one viewport
  pass settles it. Green on both trees by design (no product code), the mechanism's evidence, and a point-release tripwire
  (TEXTKIT2_NOTES §5).
- **`NoteDeletionNavigateAwayTests.aNavigateAwayNeverTakesHerFocus` (NEW — ruling 2):**
  - **The case:** two panes, focus in pane 1 (her note), pane 2's note dies.
  - **The expectations:** pane 2 goes to the Library, pane 1 stays on her note and stays focused, and the focused-subject
    signal is NOT raised.
  - **Second arm, as now:** the focused pane showing a dead note lands on the Library, stays focused, and raises the
    signal once.
  - **RED on `vx246-u4b-red`** on "the focus stays where she is".

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u4b`)

**Built (rebuild ONLY if `git diff --name-only cd843647..HEAD -- Sources App` is non-empty; record-only commits since):**
- `App/Variorum/DerivedData/vx246-u4b-red`: `7209cf2d`'s tree (U4's fix, the U4b pins, no U4b fix). W1a only.
- `App/Variorum/DerivedData/vx246-u4b-red-pre-u4`: the same tree with U4's `refreshBadges` hunk reverted. W1b only (the
  re-designed phantom pin).
- `App/Variorum/DerivedData/vx246-u4b`: `cd843647`'s App/Sources (both fixes). W2 and W3.
- **Each verified by symbol** (piece 2 / piece 5): `refreshBadges()` measures 4,276 / 3,336 / 3,696 bytes, and
  `select(_:in:takingFocus:)` is present only in the fixed product.

**Estimate ~60 min of work → claim 75** (A1 + prefs ~3 · W1 ~3 · W2 ~12 · the fixture import ~6 · W3 ~28 for both voices ·
cleanup ~8). **Batch-only fallback (~30 min, claim 40):** steps 0–1, W1, W2, cleanup; the walk moves to the next window.

0. **Guards, every step** (U3's and U4's, verbatim):
   - `Tools/stage status` shows the claim held. It exits 1 while a claim is held, so never put it inside an `&&` chain
     (U4 STAGE RUN's note).
   - `Tools/WalkKit/guard.sh --author`: her `/Applications/Variorum.app` must be ABSENT. Present ⇒ STOP and report; never
     quit or kill it.
   - `pgrep -fl 'Variorum.app/Contents/MacOS'` is empty before any test run.
   - Every GUI act goes through `click.sh` / `keys.sh`, with synthetic events ≥ 2.6 s apart.
   - An undismissable system popup is reported word for word, and the window pauses.
1. **A1 prestage + prefs, FIRST** (the test host is the dev-store app):
   - Copy every dev-store file and the key files to `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each
     `cmp`-verified, sha256 recorded.
   - `defaults export io.lduarte.Variorum.debug`.
   - No MCP leg runs in this window, so her user-scope servers are not touched (U5's live round carries ruling 2's
     real-client check).
2. **W1 — RED ON OLD (~3 min):** `zsh notes/plans/vx246-screens/u4b/run-w1-red.sh`, foreground, about two minutes. Logs:
   `u4b/logs/w1a-red-on-old.log`, `w1b-red-pre-u4.log`. **Expected, by design:**
   - **W1a, `vx246-u4b-red`:**
     - `FanBadgePlacementTests` **2 of 6 red.**
       - `theBookEditorBadgesEveryFanRightAfterItMounts` on "every fanned block wears its badge right after the mount —
         1 of 80, not block 1 alone" (the `#expect` at ~404). Block 1's own badge is home, so no home line fails.
       - `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` on "every fanned block keeps a badge after the width change"
         (~330) and "entry N's badge at y=…, its block's first line at y=…" (~160), as U4's W2 measured.
     - **Green:** `aBadgeNeverSitsAtAnotherBlocksPlace` (U4's state check covers Write; its PREMISE line ~221 must hold, a
       `.zero` fan in the band), `blockOnesBadgeIsItsOwnAlone`, the corrected characterization, and the poison
       characterization.
     - `NoteDeletionNavigateAwayTests` **1 red,** `aNavigateAwayNeverTakesHerFocus`, on "the focus stays where she is"
       (~445), "no focused-subject change is announced" (~450) and arm 2's "announced once" (~457; old: `[.library,
       .library]`). Its other four tests are green.
   - **W1b, `vx246-u4b-red-pre-u4`:** `aBadgeNeverSitsAtAnotherBlocksPlace` RED on the phantom ("⑂ button(s) at block 1's
     place, and block 1 has ONE take", ~168), the stack (~164) and "stands on a fragment TextKit 2 has NOT laid out"
     (~158), with both premise lines (~215, ~221) holding.
   - **Not the STOP case:** a red on a `premise:` line or a `#require` is a harness defect. Stop after cleanup and report;
     nothing is fixed under the claim.
   - **If W1a's phantom premise (~221) fails:** TK2 estimated the whole band in the host, so the re-design is hollow too.
     Record it; the pin goes to the orchestrator.
3. **W2 — GREEN + THE MAC BATCH (~12 min):** `zsh notes/plans/vx246-screens/u4b/run-w2-batch.sh` runs 304 suites on
   `vx246-u4b` (`u4b/stage-suites.txt`: U4's 271 ∪ 33 workspace / navigation suites), detached and polled in the
   foreground.
   - **Read:** the summary, every `✘`, the `skipped:` lines (the gated capture suites).
   - **Expected:** every U4b pin green (all six `FanBadgePlacementTests`, both characterizations included, and
     `aNavigateAwayNeverTakesHerFocus`), and `BookcaseOutsideWriteTests` 2/2.
   - **A red not designed:** re-run it ALONE once, `"-only-testing:VariorumTests/<Suite>/<test>()"`.
     - Green alone and in a named load-flake class (VX-167's `redoNeverAsks`, VX-279) ⇒ recorded as that.
     - Reproduces alone ⇒ a REAL regression, reported with the test, its message and a trace (no fix under the claim).
     - Standing reds, named if met: VX-115, VX-245's sites, VX-167. The 4 known issues are `IndexTierMetricsTests`'.
   - **Watch especially:**
     - `InlineEditorWindowTests`: the per-keystroke budget now carries the remeasure's badge re-run.
     - `InlineHeightReportTests`: the report counts.
     - `InlineEditorWidthReflowTests`, the Book Outline and Index landing suites, `SpreadBookViewTests`.
     - `EditorDecorTransactionTests`: the R1-1 oracle at zero.
     - `WorkspaceModelTests`, `PaneSplit*`, `WingFollowTests`, `SavepointOnLeaveTests`: `select`'s new parameter.
4. **THE FIXTURE (~6 min, the dev store, her own Import door, as U4's window did):**
   - `python3 notes/plans/vx246-screens/u4b/gen_fixture.py notes/plans/vx246-screens/u4b/fixture`. This is U4's
     generator, copied here; the scratchpad copy is not durable.
   - It writes `vx230-long.md` and `vx230-long-two.md` (140 blocks, block 1 one take, fans 3/40/70/100/139) and
     `vx230-book/` (two chapters × two notes × 70 blocks, block 1 fanned, every fifth block single-take).
   - File ▸ Import… → ⇧⌘G to the fixture folder → select all three → Import. The receipt reads "Imported 1 book and 2
     notes…"; capture it once.
5. **W3 — THE WALK, Study then Terminal (~14 min each).** One capture per row into
   `notes/plans/vx246-screens/u4b/w3/<voice>/`, as region captures (`screencapture -x -R`), with crops of the badge
   column. The window starts at 1380 wide.
   - **(a) The Outline's live editor right after it MOUNTS (her `d3`):**
     - Open `vx230-book`, choose Outline, press **expand all**, and click into block 2 of chapter one's first note (the
       live inline editor, "this note · editing").
     - At once, every visible fanned block wears its ⑂2 at its own first line: blocks 1–4 and 6, with block 5 bare. Not
       block 1 alone.
     - No ⑂ stands below the live editor's bottom edge over the next note's row (the transient the design argued against,
       its point 5).
   - **(b) The Outline after a WIDTH change, at the top and deep (her `d6`/`d8`):** set the window to 1100 wide by
     System Events.
     - Capture the top: every ⑂ at its line.
     - Scroll the live note (`walk-scroll`, small guarded steps) to blocks ~50–60 and capture: every fanned block's ⑂ at
       its own first line, the single-take blocks (55, 60) bare.
     - Back to 1380, then capture the same deep stretch again: at their lines, not ~30 pt below (U4's live red).
   - **(c) The Book spread's LIVE left page (her `e2`):**
     - Choose Book mode and click into the left page: every fanned block on the left page is badged at its line, not
       block 1 alone. Capture it.
     - Then a width change (1380 → 1100) and capture: at their lines.
   - **(d) Write, a width change** (this replaces the removed pin as use evidence):
     - ⌘K ▸ "vx230 long" → Write at its top, at 1380: block 3's ⑂2 at its line, block 1 bare.
     - Set 1100 and capture: block 3's ⑂2 at its new line, block 1 bare, no disc.
     - Back to 1380 and capture.
   - **(e) RULING 2 — her own Delete, from pane 1, on the note open in pane 2:**
     - Open "vx230 long two" (⌘K), then View ▸ Open Beside so it stands in pane 2.
     - In pane 1, the focused pane with its ring, go to the Library.
     - Find the row "vx230 long two" and use Delete… → the confirm → Move to Trash.
     - **Expected:** pane 2 shows the Library IN PLACE; the focus ring and the keyboard stay in pane 1. A keystroke check:
       ⌘F or a typed letter lands in pane 1's Library, never pane 2's. Capture before and after.
     - **The pre-fix product would have moved the ring to pane 2** (U3 STAGE RUN's finding A). Afterwards, View ▸ Close
       Split.
     - **Terminal's half re-imports the second long note:** the Study half deletes it, so it goes back through File ▸
       Import… with the generator's file, or Study's Put back from the Trash.
   - **The voice switch, between halves:** Settings ▸ General ▸ Theme ▸ Terminal (pressed by AX, as U4's runner did),
     and Settings closed by its own button.
6. **CLEANUP (~8 min):** moving the imported notes and book to the Trash is NOT enough; the dev store is RESTORED.
   - Quit the Debug app BY BUNDLE ID (`pgrep` empty).
   - Prefs: `defaults import` the pre-window export, `defaults delete` every key the window added, re-export, and diff
     until 0 keys differ.
   - Store: `Tools/ScaleFixture/restore.sh <the prestage dir>` → "Restored (verified)", then a second `cmp`. The posture
     handed over: Standard, unlocked, Study voice.
   - Delete the fixture folder (the generator stays) and any stray `default.profraw`.
   - **`Tools/stage release --who vx246-u4b`** at once.
   - ONE result line: the claim times, W1's red counts, W2's totals, W3's verdicts (rows a–e per voice), the posture.

### SELF-ASSESSMENT (pre-stage — the implementer's)

- **Confident:**
  - **The mechanism is measured, not inferred.** Probes 5–9 (macOS 27.0) show:
    - a read ahead of unlaid predecessors poisons the next whole walk (996 / 1,662 / 1,600 pt);
    - one viewport pass settles every fragment, whether a top pass or a deep one;
    - the heal's read is exact;
    - a clean walk, or one after a TOP mount pass, is exact for every fan.
  - **Every sighting follows from it:** U4's W2 red (51 of 80, 7 → 657 pt above), her live `d3`/`e2` (block 1 alone, by
    `inlineHeight = 24`), and her live narrow-then-widen `d6`/`d8` (below the lines, the TALL poison of widening).
  - **The fix is small:** one read option, one region test, one call. Both products build clean, and the headless finals
    are identical to U4's.
- **Less sure, said plainly:**
  - (1) Nothing has run on a Mac. The mount pin's harness (async report, 24-pt frame) is new, and its trace on both trees
    is argued. W1 is its evidence.
  - (2) The phantom pin's premise (a `.zero` fan in band 5–30) rests on W1's measured `.none` band (entries 8–18 in
    `blockOnesBadgeIsItsOwnAlone`). A host that estimates the whole band makes the premise RED, never hollow green.
  - (3) The re-run runs per coalesced remeasure, i.e. per keystroke on the inline surface. Its cost is argued (one O(fans)
    pass, plus the decor walk only when decorated) against the pinned 16.7-ms budget, not separately measured.
  - (4) The transient badge below a not-yet-grown frame is argued away (AppKit lays out before it draws), and W3 (a)
    looks for it.
  - (5) In the scrolled-deep width case, the exact positions wait for the settle net's heal (one display pass). Between
    the walk and the heal the badges show the walk's positions for at most a frame or two.
- **Editor-seam letter:**
  - `refreshBadges` adds no attribute stamp, touches no storage, forces NO layout now (U4's forcing read is gone), and
    touches no `runStructural` or `BlockRangeIndex`.
  - The `remeasure` call runs on the coordinator's hop, outside any storage-edit transaction (R1-1).
  - TK1 is untouched (no `.layoutManager`).
  - vx-282's two `EditorView.swift` touches are untouched.
- **MOBILE PARITY:** nothing mobile-visible. VM-17 gains the poison fact (OWED 3).

### PROVISIONALs (with their options — the orchestrator files them at the merge)

**No new PROVISIONAL.** Ruling 2 is the orchestrator's own provisional ruling, already in its list. Its built letter adds no
product call: the focused-subject signal is now raised only when the landing pane is the focused one. That follows from
the ruling, since nothing she looks at changed. Its one consumer, `WingFollow`, follows a note's wing, and the Library
has none, so the old raise on an unfocused landing moved nothing either.

### FOR VX-234 (user-facing words, as built)

Nothing. No word changed.

### OWED (for the orchestrator)

1. **TEXTKIT2_NOTES §3: U4's PROPOSED finding (its OWED 2) must NOT land as written.** Its last sentence, "A mid-document
   `.ensuresLayout` read is positionally exact (TK2 lays out up to it)", is FALSE: U4's probe4 compared two poisoned
   layouts. The PROPOSED replacement (canon is the orchestrator's at the closeout):
   *"macOS 27.0 measured finding (VX-246 U4/U4b, 2026-10-14; pinned in `FanBadgePlacementTests`' two characterizations):
   a fragment TK2 has not laid out reports `layoutFragmentFrame == .zero` in the `.none` state (an estimated one a GUESSED
   frame), a width change returns every fragment to `.none`, and a `.zero` rect at the container origin `intersects` any
   rect holding that point. A layout that runs AHEAD of unlaid predecessors (a mid-document `.ensuresLayout` enumeration,
   or a viewport pass over a mid-document window) places those fragments at estimated offsets, and a following whole
   `.ensuresLayout` walk does NOT re-position them (996 pt cold, 1,662 pt after 700 → 420, on 120 paragraphs); the next
   viewport pass re-positions every fragment to the settled layout, and a whole walk with nothing laid out ahead of it is
   exact. This is the mechanism of the 18l first-measure finding above. **The rules:** a frame read with `options: []` is
   a position only in `.layoutAvailable`; never force layout from a mid-document location on a whole-post surface; read
   geometry after the whole walk, and again after the settle net's heal."*
2. **VX-327 (the decoration sibling): facts for its red-first probe.**
   - The decor pass's inline region is the same `textView.bounds`, the transiently-short frame of this unit's (A).
   - The model's pre-remeasure hop may run the decor pass's edge lookups at a mid-document point (the old frame bottom),
     which is the poison's shape.
   - U4b's `remeasure` re-run now re-reads decorations after every walk, the heal's included. That is observed, not
     claimed: VX-327 stays open for its own probe.
3. **VM-17 (the phone): add the poison fact to its probe.** Any TK2 surface that forces a mid-document read before a whole
   walk may badge off the settled layout.
4. **The 18l settle net, observed:** with U4's forcing read gone, a fanned inline post no longer has its first post-reflow
   report poisoned by the badge pass. The remaining poison source is a deep viewport pass, and the heal covers it.
5. **The Fable cold review** (CLAUDE.md: the editor seam) covers `refreshBadges` and the one `remeasure` call. It is the
   orchestrator's, at the run's end.
6. **U5's live round** keeps ruling 2's real-client check, unchanged.
7. **Canon at the merge:** none beyond OWED 1 (AppSpec §12's "a corner badge only on fanned blocks" holds; ruling 2 is
   view state, not canon).

## U4b STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14 ~04:40 MDT)

**What this run does NOT do (said first):** no product code is written or changed, under the claim or before it; a red
that needs code is recorded and reported, never fixed here. No MCP client is registered or run (ruling 2's real-client
check stays U5's); her user-scope servers are only fingerprinted, before and after. No canon, QUESTIONS or ticket edits.
No rebuild: the window runs the three products exactly as built, even after the next unit merges main into this branch
(expected before the GO — the products hold U4b's sources, which is what this window proves).

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, the Stage traffic log,
ORCHESTRATOR'S PROVISIONAL RULINGS (ruling 2), the U4b BRIEF; U2, U3 and U4 STAGE RUN whole (the A1 copy BEFORE the
batch; `defaults import` merges, so re-export and diff; the batch detached and polled in the foreground; `Tools/stage
status` exits 1 under a held claim, never in an `&&` chain); the U4b UNIT RECORD whole (the re-trace, the design, the
pins, THE STAGE WINDOW, the self-assessment, OWED); `notes/SessionResiliencyProtocol.md`; `Tools/stage`, `Tools/WalkKit/`
(README, `guard.sh`, `click.sh`, `keys.sh`), `Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); U4b's
`run-w1-red.sh`, `run-w2-batch.sh`, `stage-suites.txt`, `gen_fixture.py`; the memory notes walk-driving-lessons and
walk-restores-dev-store-posture. Code read for (e): `WorkspaceModel.select`/`openBeside`/`notesDeleted`,
`ShellRouter.openBesideMostRecent` (the View menu door opens the most recently opened note NO pane shows),
`PaneHost.nameLine` (an UNFOCUSED pane wears a thin "‹name› · click to edit" line in place of a masthead — "the
difference … IS the focus signal"), `RootView`'s palette rows (⌘K "Go to …" adopt in `focusedPane`), the Library row's
destructive `RecoveryCopy.deleteNoteTitle` door and the one confirm host (`deleteNoteConfirmDialog`: "Delete" / "Cancel").

**The build check (before READY):**
- **No source moved since the fixed product was built.** HEAD `d430bea8`; `git diff --name-only cd843647..HEAD -- Sources
  App` is EMPTY (record-only commits since, `52f6cc17`/`63410c1a`/`d430bea8`); `7209cf2d..cd843647` touches exactly the
  three fix files (`EditorView.swift`, `EditorViewModel.swift`, `WorkspaceModel.swift`); no test file moved since
  `7209cf2d`; no `.swift`/plist/pbxproj/xcstrings/`Package.swift` under `Sources` or `App/Variorum` is newer than the fixed
  dylib (04:25:32; the fix files 04:20:29–04:20:54; the pin files 04:04:31/04:09:46, before the red dylib 04:10:47). The
  tree is clean.
- **Each product is what its name says, read from its symbols** (`nm -n` + `swift-demangle`, size = the next text symbol's
  address minus this one's): `EditorViewModel.refreshBadges()` **4,276** bytes in `vx246-u4b-red` (U4's body), **3,336** in
  `vx246-u4b-red-pre-u4` (the pre-U4 body), **3,696** in `vx246-u4b` (U4b's); `WorkspaceModel.select(_:in:takingFocus:)`
  present ONLY in `vx246-u4b` (1,652 bytes + its default argument and closures). All three test bundles carry
  `theBookEditorBadgesEveryFanRightAfterItMounts`, `theBookEditorPutsEveryBadgeHomeAfterAWidthChange`,
  `aBadgeNeverSitsAtAnotherBlocksPlace`, `textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace`,
  `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` and `aNavigateAwayNeverTakesHerFocus`, and none carries the
  removed `aWidthChangeInWriteKeepsEachBadgeHome`. **→ no rebuild.**
- **The W2 list:** `run-w2-batch.sh`'s `-only-testing` names diffed against `stage-suites.txt`: IDENTICAL, 304 unique.
- **Host and tools:** grants probed with no prompt, `AX: true SCREEN: true`; `walk-cap` / `walk-scroll` compiled into the
  scratchpad; `Tools/WalkKit/wl2` present; `cliclick` present. Free disk **39 GiB**.
- **Her user-scope MCP servers (names + a sha256 prefix of the sorted, compact `mcpServers` JSON, never values):**
  `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — the same fingerprint U3's and U4's windows recorded. Re-read at
  the window's start and after cleanup.

**Process choices (U2's, U3's and U4's lessons applied):** the A1 copy, the prefs export and the fingerprint come FIRST,
before W1 (the test host is the dev-store app); W1 in the foreground (about two minutes), W2 detached to its log and POLLED
in the foreground; every GUI act through `click.sh` / `keys.sh`, at least 2.6 s apart; region captures; the Debug app quit
BY BUNDLE ID; the prefs restored by import, then a re-export and a diff, deleting every key the window added, until 0
differ. The fixture is generated under the claim (step F) into `u4b/fixture/` and deleted at cleanup.

**(e)'s road, made exact from the code (a refinement of the plan's wording, said):** open "vx230 long two" (⌘K) in pane 1
→ ⌘K "Go to Library" in pane 1 → View ▸ Open Beside (its candidate is the most recently opened note no pane shows, so
"vx230 long two" lands in a NEW right pane, which takes the focus) → one click on pane 1's thin "click to edit" line
focuses pane 1 (the masthead returns there, the thin line moves to pane 2) → CAPTURE (before) → pane 1's Library row
"vx230 long two" ▸ right-click ▸ the delete door ▸ the confirm's **Delete** → CAPTURE (after). **The focus evidence is the
pane's own focus signal** (the full masthead vs. the thin "click to edit" line): pane 2 must show the Library wearing the
THIN line, pane 1 keep its masthead. **The keyboard check** (in place of "⌘F or a typed letter"): ⌘K ▸ "Go to Pool" ⏎ —
the palette adopts in `focusedPane`, so pane 1 must turn to the Pool and pane 2 stay on the Library; the pre-fix road
would have turned pane 2. Then View ▸ Close Split. Terminal's half restores the note first by Put back from the Trash.

**Minutes:** ~60 of work expected (A1 + prefs ~3 · W1 ~3 · W2 ~12 · the fixture ~6 · W3 ~28 for both voices · cleanup ~8);
a **75-min claim** asked (the plan's). Batch-only fallback (~30 min, claim 40): steps 1, W1, W2, cleanup.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the GO's exact line) |
| 0 | guards on every step; the claim from the GO's line; the HEAD at the GO | DONE — the GO from oct13coordinator (the FULL window; its pre-checks 04:40: no instances, no booted sims, 39 GiB free; the dev store last left Standard/unlocked/Study at U4's window). **HEAD at the GO `c0e23c47`** (U1b's implementer PAUSED before its merge: tree clean, no `MERGE_HEAD`); `git diff --name-only cd843647..HEAD -- Sources App` still EMPTY. Its exact line run: `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u4b --reason "VX-246 U4b: red-on-old x2 + 304-suite batch + inline-editor walk both voices (A1)" --minutes 75` → **CLAIMED 04:42:07 MDT, 75 min** (expires 05:57). Pre-claim: `guard.sh --author` OK (idle 3,708 s), no Variorum app instance (`pgrep -lx Variorum` empty). **A machinery note:** vx-282 was running a headless `xcodebuild build-for-testing` in its own worktree (no stage needed); its shell's command line contains the string `Variorum.app/Contents/MacOS`, so `pgrep -f 'Variorum.app/Contents/MacOS'` matches it — app instances are checked with `pgrep -lx Variorum` instead, and `restore.sh` (which uses the `-f` form) waits for that build to end |
| 1 | A1 prestage copy (every store file + key files, each `cmp`-verified, sha256 recorded) + `defaults export io.lduarte.Variorum.debug` + her user-scope fingerprint BEFORE | DONE (04:42) — **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T104214Z`**, five files each `cmp`-verified (sha256 prefixes: sqlite `c21acf370329` · wal `e3b0c44298fc` (0 bytes) · shm `fae8b463e908` · keys `3af4704371ff` / `7e12a1b85890`; `u4b/store-hash-pre.txt`) — NOT U4's restored hashes: the store moved after U4's 03:41 restore (sqlite and wal 03:53, shm 03:44 — another session's use), and per the GO the copy is the store exactly as handed over; prefs exported (**1,567 keys**, `appearanceChoice` = system) to `u4b/prefs-pre.plist`; her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as at READY (`u4b/userscope-pre.txt`); the dev `Backups/` listing saved (`u4b/backups-pre.txt`) |
| W1 | `run-w1-red.sh` — W1a (`vx246-u4b-red`: `FanBadgePlacementTests` 2 of 6 red, `NoteDeletionNavigateAwayTests` 1 red) + W1b (`vx246-u4b-red-pre-u4`: the re-designed phantom pin red); a red on a `premise:` line or a `#require` ⇒ STOP that leg and report | DONE (04:42:38 → 04:45:04) — **RED ON OLD, EXACTLY AS DESIGNED, both legs; NO `premise:` line and NO `#require` tripped** (the only "premise" text in either log is the phantom pin's own doc comment echoed in its failure summary). **W1a** (`vx246-u4b-red`, `u4b/logs/w1a-red-on-old.log`, `u4b/w1a-red.xcresult`): "✘ Test run with **11 tests in 2 suites** failed after 8.355 seconds with **54 issues**", EXIT 65 — **3 red, 8 green.** `FanBadgePlacementTests` **2 of 6 red:** `theBookEditorBadgesEveryFanRightAfterItMounts` (1 issue, `:404` "every fanned block wears its badge right after the mount — 1 of 80, not block 1 alone", `badges.count → 1`; no home line, as designed); `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` (50 issues: `:330` "every fanned block keeps a badge after the width change", `badges.count → 51` of 80; `:160` ×49 "entry N's badge at y=…, its block's first line at y=…" — entry 3 430 vs 437, 4 573 vs 580, 6 852 vs 866 … 73 10,844 vs 11,501, 75 11,164 vs 11,821, every badge above its line, 7 → 657 pt, exactly U4's W2 numbers). **Green:** `aBadgeNeverSitsAtAnotherBlocksPlace` (its premises ~215/~221 held — a `.zero` fan in the band — and U4's state check covers Write), `blockOnesBadgeIsItsOwnAlone`, the corrected `textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects` (green now — the `:397` defect gone), and `textKitPlacesAFragmentLaidOutAheadOfItsPredecessorsOffItsSettledPlace`. `NoteDeletionNavigateAwayTests` **1 of 5 red:** `aNavigateAwayNeverTakesHerFocus` (3 issues: `:445` "the focus stays where she is", `focusedPane → pane-1`; `:450` "no focused-subject change is announced", `announced → [library]`; `:457` arm 2 "announced once", `→ [library, library]`); its four siblings green. **W1b** (`vx246-u4b-red-pre-u4`, `u4b/logs/w1b-red-pre-u4.log`, `u4b/w1b-red-pre-u4.xcresult`): "✘ Test run with **1 test in 1 suite** failed after 0.577 seconds with **14 issues**", EXIT 65 — the re-designed `aBadgeNeverSitsAtAnotherBlocksPlace` **RED on the phantom** (`:168` "12 ⑂ button(s) at block 1's place, and block 1 has ONE take (U1's phantom)"), **the stack** (`:164` "11 ⑂ buttons stacked on another's place (the dark disc) — ys [24.0 ×12, 208, 484, 576]") and `:158` ×12 "entry 8…19's badge stands on a fragment TextKit 2 has NOT laid out"; both premise lines held. **So the re-designed pin is NOT hollow: red on the pre-U4 tree, green on U4's** |
| W2 | `run-w2-batch.sh` — 304 suites on `vx246-u4b`; a red re-run alone once; standing reds named (VX-167, VX-245, VX-115) | DONE (04:45:31 → 04:56:28) — "✘ Test run with **1946 tests in 304 suites** failed after 596.468 seconds with 13 issues (including 4 warnings and 4 known issues)", EXIT 65 (`u4b/logs/w2-batch.log`, `u4b/w2-batch.xcresult`); the result bundle: **1,927 passed · 17 gated skips · 2 failed** (its third "failure" entry is the unattributed «unknown» warning, U3's door-pin harness noise, "@Dependency(\.withRandomNumberGenerator) has no test implementation" ×4). The skips are the gated set (the 7 UNKEYED-oracle singleton tests, the List-face harness, the MCP capture harnesses); the 4 known issues `IndexTierMetricsTests`' standing `withKnownIssue` (overTwoBlankLines, both voices). **Every U4b pin GREEN on the fixed product:** `FanBadgePlacementTests` 6/6 (`theBookEditorBadgesEveryFanRightAfterItMounts` and `theBookEditorPutsEveryBadgeHomeAfterAWidthChange` red on old → green; the phantom, `blockOnesBadgeIsItsOwnAlone`, both characterizations), `NoteDeletionNavigateAwayTests.aNavigateAwayNeverTakesHerFocus` (red on old → green), `BookcaseOutsideWriteTests` 2/2. The per-keystroke budget: `inlineHeightMaintenanceStaysInsideTheFrameBudgetAtTenThousandWords` GREEN, "inline keystroke + remeasure **4.89 ms**" at 10k words (the remeasure's badge re-run inside the 16.7 ms frame). **The two reds, each re-run ALONE once (`u4b/logs/w2-rerun-*.log`):** (1) `DestructiveUndoWarningTests.redoNeverAsks()` (`:141–143`) → **green alone** (04:57:41) — VX-167's standing load flake, not a regression. (2) **`InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport()` → REPRODUCES ALONE (04:56:45, 2 issues) — A REAL REGRESSION ON THE FIXED PRODUCT:** `:78` "the off-viewport fanned block badges — no stale pruning", `badges.map(\.blockID) → []` vs `[…0079]`; `:80` the `#require` on `badges.first?.frame` → nil (a consequence of `:78`, after the pin's own premise `:69` held). The same test PASSED in U4's W2 on `vx246-u4` (U4's forcing read) and in U3's W2 on `vx246-u3` (the pre-U4 body) — so it turns red with U4b's `refreshBadges`. Not fixed under the claim; the read-only trace follows after the release (below). No VX-245 or VX-115 suite in the set |
| F | the fixture generated, then through File ▸ Import… (two long notes → the Pool; the folder → an unshelved book) | DONE (04:47 generated; imported 05:00) — `gen_fixture.py` → `u4b/fixture/` (`vx230-long.md` 9,823 words incl. alternates, `vx230-long-two.md` 9,995, `vx230-book/` two chapters × two notes). The fixed app `open -n` 04:59 (pid 98326, 1380×900 at (60,36), **Study, light, the Bookcase; no What's New sheet, no lock screen**; `u4b/w3/launch/w0.png`); File ▸ Import… by its menu item → the Open panel ⇧⌘G to the fixture → the three items selected (a click, then a SHIFT-click: ⌘A and ⇧↓ did not reach the out-of-process panel after a click, `import-02`…`02e`) → Import (pressed by AX, `button "Import" of splitter group 1 of window "Open"` — a pointer click on it did not land) → **"Imported 1 book and 2 notes to the Pool · ⌥⌘Z undoes"**, the row **"vx230-book · 4 notes · 2 ch · 19,086w"** (`import-04`) |
| W3 | the walk, Study then Terminal: (a) Outline right after mount · (b) Outline after a width change, top and deep · (c) the spread's live left page (+ a width change) · (d) Write's width road · (e) ruling 2, her own Delete from pane 1 on the note in pane 2 | **STUDY HALF DONE (05:00–05:09)**, captures `u4b/w3/study/` (window region captures). **(a) PASS** — vx230-book → Outline (cards collapsed, `a0`) → expand all (`a1`: the read tier, 1–4 ⑂2 at their lines) → a click into block 2 → the live inline editor ("editing", block 2/70): **1 s after the mount, blocks 1, 2, 3 and 4 each wear their ⑂2 at their own first line, block 5 bare** (`a2`; settled 3 s later the same, `a3` + crop `a3-badge-column-crop`) — not block 1 alone (U4's `d3`/`e2` red is gone). **No stray ⑂ below the live editor:** at its end (after (b)'s scroll) block 069 badged at its line, 070 bare, and nothing between the live note's last line and "vx230 book second"'s header or over its read-tier rows (`b5`). **(b) PASS, top and deep, both directions** — the window to 1100 by System Events: the top re-wraps, blocks 1–4 and 6 badged at their new first lines, 5 bare (`b1`); scrolled deep in guarded steps (`walk-scroll` 9 ×6, then ×2): **blocks 039–044** (`b2`: 39, 41, 42, 43, 44 at their lines, 40 bare) and **blocks 051–056** (`b3`: 51–54 and 56 at their lines, 55 bare); back to 1380: the outer scroll landed past the live note (on "vx230 book second"'s read tier, `b4`), so up 3 (`b5`, the live note's end) and up 9 ×2 → **blocks 056–061 after narrow-then-widen: 56, 57, 58, 59, 61 at their own first lines, 60 bare** (`b6`) — not ~30 pt below (U4's live red is gone). **(c) PASS** — Book (the spread, `c1`): the LEFT page ("vx230 book opening", the focused note) badges 1–4 at their lines, the right page's read tier 1–4; a click into the left page's block 3 ("block 3/70", the grip at 3; `c2`): 1–4 at their lines — not block 1 alone; then 1380 → 1100 (`c3`): both pages re-wrap, 1–3 on each at their new lines. **(d) PASS, AS FOUND: Write's measure held** — ⌘K ▸ "vx230 long" → Write at 1380 (`d1`: block 1 bare, block 3's ⑂2 at its line, "block 1/140"); 1100 (`d2`): the SAME line breaks (the column's measure did not change between 1100 and 1380, so no re-wrap happened), block 3's ⑂2 at its line, block 1 bare, no disc; back to 1380 (`d3`): the same. So Write's row is a no-regression check at these widths, not a reflow proof. **(e) PASS — RULING 2 on her own door:** ⌘K ▸ "vx230 long two" (pane 1) → ⌘K ▸ "Go to Library" (pane 1) → View ▸ Open Beside → "vx230 long two" in a NEW right pane, focused; the Library on the left wears the thin "Library · click to edit" line (`e1`) → one click on that line → pane 1 focused (its masthead back, the sidebar on Library), pane 2 thin "vx230 long two · write · click to edit" (`e2`, BEFORE) → right-click the row "vx230 long two" in pane 1's Library → the row menu (`e3`) ▸ **Delete Note…** → the confirm "Delete Note — The note goes to the Trash for 30 days…" (`e4`) ▸ **Delete** → **AFTER (`e5`): the note gone from both listings, "Note moved to the Trash — 30 days to put it back."; PANE 2 SHOWS THE LIBRARY IN PLACE WEARING THE THIN "Library · click to edit" LINE (unfocused), and PANE 1 KEEPS ITS MASTHEAD (focused), the sidebar on Library.** **The keyboard check:** ⌘K ▸ "Go to Pool" ⏎ (`e6`) → **pane 1 turned to the Pool** ("Pool · 14 notes", its masthead, the sidebar on Pool) and **pane 2 stayed on the Library** with its thin line (`e7`) — the keyboard is in pane 1. View ▸ Close Split; ⌘K ▸ Trash (`e8`, `e9`: "vx230 long two · note · deleted Oct 14, 2026 at 5:08 AM" — the row deleted was the right one) ▸ **Put back** → "Note put back." (`e10`). **FINDING B again (VX-328, recorded as found):** while a pane shows the Library at half width, its catalog draws past the pane's LEFT edge — over the sidebar from pane 1 (`e1`, `e2`, `e5`) and over the divider into pane 1 from pane 2 (`e5`, `e7`: the Pool's "add" buttons covered) **TERMINAL HALF DONE (05:10–05:15)**, captures `u4b/w3/terminal/`: Settings from the app menu → General ▸ Theme ▸ **Terminal** pressed by AX (the radio's values read back `1, 0`; `v1`) → Settings closed by its own close button. **(a) PASS** — ⌘K ▸ vx230-book → Outline (`a0`) → expand all (`a1`: the read tier, 1–4 and 6 badged) → a click into block 2 → live ("editing", block 2/70): **1 s after the mount blocks 1, 2, 3, 4 and 6 each wear their ⑂2 at their own first line, block 5 bare** (`a2`; settled, `a3` + crop `a3-badge-column-crop`) — U4's Terminal `d3` ("ONLY block 1 wears a ⑂2") is gone. **(b) PASS** — 1100 (`b1`: the top re-wrapped, 1–4 and 6 at their new lines, 5 bare) → deep (`walk-scroll` 9 ×8, `b2`: **blocks 056–061 at 1100: 56, 57, 58, 59, 61 at their own first lines, 60 bare**) → back to 1380 (`b3`: the outer scroll landed on "vx230 book second"'s read tier, its 1–4, 6, 7 at their lines) → up 9 ×2 (`b4`: **the live note's blocks 057–062 after narrow-then-widen: 57, 58, 59, 61, 62 at their own first lines, 60 bare**) — not ~30 pt below (U4's Terminal `d6`). **(c) PASS** — Book (`c1`: the spread; the LEFT page, the live note, badges 1–4 at their lines; the right page's read tier 1–4) → a click into the left page's block 3 ("block 3/70", `c2`): 1–4 at their lines — not block 1 alone (U4's `e2`, both voices) → 1100 (`c3`): both pages re-wrap, 1–3 at their new lines on each. **(d) PASS, a REAL REFLOW this time** — ⌘K ▸ "vx230 long" → Write at 1380 (`d1`) → **900** wide (`d2`, chosen because 1100 left Write's measure unchanged in Study: the column narrowed and every paragraph re-wrapped) — block 3's ⑂2 at its new first line, block 1 bare, no disc → back to 1380 (`d3`): block 3's ⑂2 at its line, block 1 bare. **(e) PASS — RULING 2 in Terminal, the same road:** "vx230 long two" (pane 1) → Go to Library (pane 1) → View ▸ Open Beside (`e1`: long two in the new right pane, focused; pane 1 thin "library · click to edit") → a click on pane 1's line (`e2`, BEFORE: pane 1 the "~/library" masthead, the sidebar "› library"; pane 2 thin "vx230 long two · write · click to edit") → right-click its row (`e3`) ▸ Delete Note… ▸ the confirm (`e4`) ▸ Delete → **AFTER (`e5`): pane 2 shows the Library IN PLACE under the thin "library · click to edit" line; pane 1 keeps its masthead; "Note moved to the Trash — 30 days to put it back."** → ⌘K ▸ "Go to Pool" ⏎ (`e6`) → **pane 1 turned to "~/pool" (the sidebar "› pool") and pane 2 stayed on the Library with its thin line** (`e7`). Seen and recorded, not a finding: in Terminal BOTH quick-entry fields draw the voice's block caret glyph while unfocused (`e5`) — the keyboard check, not the glyph, is the focus evidence. Not put back by hand: the store restore below returns the pre-window state. **W3's verdict, both voices: VX-230's inline half is FIXED where it failed at U4's window** — the live inline editor badges every visible fan at its own line right after it mounts (Outline and the spread's live page), and after narrow-then-widen the deep badges stand at their own lines; no stray badge below the live editor; Write unchanged (a real reflow at 900 in Terminal). **Ruling 2 PROVEN on her own Delete door in both voices** (the pane leaves in place, the focus and the keyboard stay in pane 1). |
| C | cleanup: the Debug app quit by bundle id; prefs 0 keys differ; `restore.sh` → "Restored (verified)" + cmp SAME; the fingerprint AFTER; the fixture deleted; `Tools/stage release --who vx246-u4b`; the result line | DONE (05:15–05:16) — the Debug app quit BY BUNDLE ID (05:15:57; `pgrep -lx Variorum` empty; no shim, no xcodebuild of ours); **prefs:** the window added 20 keys (`surfaceSize.outline.*` ×15, `currentBlock.*` ×5), removed 2, changed 8 → `defaults import` of `prefs-pre.plist` + `defaults delete` of the 20 → re-export **1,567 keys, 0 added · 0 removed · 0 changed** (`u4b/prefs-post.plist`); **the dev store:** `restore.sh …/scale-prestage-20261014T104214Z` → **"Restored (verified)"** (`u4b/logs/restore.log`), a second `cmp` of all five files **SAME**, and the sha256 set equals the pre-window hashes (`store-hash-restored.txt` = `store-hash-pre.txt`) — the store exactly as handed over (Standard, unlocked, Study voice in the store); **no new backup** from the launch (the `Backups/` listing differs only in its parent folder's mtime, the restore's own touch; `backups-post.txt`); her user-scope servers AFTER `['linear-server', 'variorum']`, **`bc64543e2f4e8e58` — SAME**; no stray `default.profraw`; the fixture folder deleted (the generator stays); the tree clean. **RELEASED 05:16:26 MDT** (`Tools/stage release --who vx246-u4b` → STAGE RELEASED; `status` → STAGE FREE), 34 of the 75 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx246-u4b` 04:42:07–05:16:26 MDT, RELEASED (34 of 75 min).
- **W1, red on old exactly as designed, no premise line:** W1a (`vx246-u4b-red`) 11 tests, **3 red / 54 issues** (the mount pin 1 of 80; the
  width pin 51 of 80 + 49 home lines; `aNavigateAwayNeverTakesHerFocus` at `:445/:450/:457`); W1b (`vx246-u4b-red-pre-u4`) the re-designed
  phantom pin **red, 14 issues** (12 at block 1's place, 11 stacked, 12 unlaid) — not hollow.
- **W2** (`vx246-u4b`): **1,946 tests in 304 suites — 1,927 passed, 17 gated skips, 2 failed.** Every U4b pin green (`FanBadgePlacementTests`
  6/6, `aNavigateAwayNeverTakesHerFocus`, `BookcaseOutsideWriteTests` 2/2; the keystroke budget 4.89 ms). VX-167's `redoNeverAsks` green
  alone. **`InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport` REPRODUCES ALONE — a real regression of U4b's
  `refreshBadges`** (green on `vx246-u4` and `vx246-u3`); not fixed; trace below.
- **W3, both voices:** **PASS** on every row — (a) the Outline's live editor badges every visible fan at mount, block 5 bare, nothing below
  it; (b) after narrow-then-widen, deep blocks at their own lines (Study 39–61, Terminal 56–62); (c) the spread's live left page badged
  1–4, and after a width change; (d) Write unchanged (Terminal a real reflow at 900). **Ruling 2 PROVEN on her own Delete in both voices**:
  pane 2 lands on the Library in place under the thin line, pane 1 keeps the masthead, and ⌘K ▸ Go to Pool turns pane 1.
- **Posture: Standard/unlocked, cmp-SAME vs A1, prefs re-exported and diffed (1,567 keys, 0 differ).** Fingerprint **SAME**
  (`bc64543e2f4e8e58`). The A1 copy **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T104214Z`** is the coordinator's to prune.

**THE TRACE OF THE ONE REAL RED (read-only, after the release; by reading, NOT verified by a run — the orchestrator's to take up).**
- **The pin** (`InlineEditorWindowTests.swift:59–84`): an inline editor in a 700×300 window (the container clips it); `coordinator.remeasure()`
  (the whole `.ensuresLayout` walk), `pump()` (0.05 s: a display pass), then a take branched on block 40 (far below the clip),
  `h.reload()`, and a DIRECT `h.model.refreshBadges()`; it expects block 40's badge. On `vx246-u4b` the badge list is EMPTY.
- **The road, read:** `branchVariant` copies the chosen take's text and leaves the chosen take in place, so `reload()` →
  `applyProjection` → `EditorProjectionPolicy.decide` finds the ledger MATCHING (same blocks, variants, texts, editability —
  `EditorProjectionEngine.matches`) → **`.adoptEcho`**: `slots = new` and `refreshBadges()`, with NO storage edit — so no remeasure is
  scheduled after it, and U4b's new re-run in `InlineEditorSurface.Coordinator.remeasure` never fires on this road.
- **Why the badge is missing:** U4b's `refreshBadges` reads with `options: []` and keeps a frame only in `.layoutAvailable` (U4's check,
  kept). An empty list means block 40's first fragment was NOT `.layoutAvailable` at that call, although the remeasure's whole walk had laid
  it out before the `pump()`. So something between the walk and the read returned it to an unlaid state — by reading, the display pass in
  `pump()` (a viewport pass over the 300-pt clip, or a width settle at install), which the record's fact 2 says re-positions fragments but
  which, here, evidently leaves the far fragment unlaid. **Unverified: the decisive number is block 40's fragment `state` at the pin's
  `:76`.** U4's forcing read (`.ensuresLayout`) laid it out on demand, and the pre-U4 read took whatever frame it got without a state check,
  so both older trees badged it.
- **What it would mean in use (by reading):** in the book view's inline editor, a fan born on a block far outside the visible area with
  NO text change — an MCP `add_take`, a sync arrival, any branch whose chosen take stays — goes unbadged until the next remeasure (her next
  keystroke in that note, or a width change). Her own keyboard roads fan the block under her caret (laid out), so W3 could not show it.
- **Candidate shapes for the orchestrator (not chosen here):** a remeasure (or a badge re-run after a whole walk) on the `.adoptEcho` arm
  when the fan counts changed; or, on the inline surface only, an exact read for a fan whose fragment is unlaid AFTER a whole walk (the
  poison rule says never force from mid-document BEFORE the walk). Either touches the editor seam (`refreshBadges` / the inline coordinator),
  so it is the Fable review's surface too.

## U1b UNIT RECORD — VX-258's face and U1's remainder: VX-258 · VX-318 · VX-260 option (b), plus the carried live legs (opus-implementer, from 2026-10-14 ~05:00 MDT)

**Not done yet (first line, kept current — the state at READY, 2026-10-14 ~07:10 MDT):** NO STAGE WINDOW HAS RUN —
no Mac test (VX-258's pins are red-first only by construction of `vx246-u1b-red` and `-revert`, their red runs the
window's W1), no walk, no live round (legs 0–4, U2's W2/W3, ruling 2's real-client check, U4c's W1–W3 — all THE STAGE
WINDOW below); Codex's leg is N/A (not installed); **VX-318 was NOT fixed — DISMISSED AS HOLLOW** (its trace below);
no QUESTIONS, canon or ticket edit (the merge's); the field guide untouched (U8, the follow-on run).

**Machinery, said:** PAUSED once before piece 0 (`c0e23c47`, U4b's window took the stage; no merge was started), then
resumed at the orchestrator's word after U4b's run, U4c's unit and its notes (`a2d84e77`). Since then the scope gained
U4c's window (W1 its two pins, W2 its 13 suites, W3 the far-off-screen ⌘T walk) and ruling 2's REAL-CLIENT check only
(ruling 2 itself is built and proven on her own door — U4b).

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon; this record's header, THE UNITS, the hard
rules, LIVE STATUS, the Stage traffic log, Cross-run coordination, her rulings, ORCHESTRATOR'S PROVISIONAL RULINGS (rulings
1–3), the U1b BRIEF; U1's UNIT RECORD whole and THE ORCHESTRATOR ON U1's HAND-BACK; U2's THE STAGE WINDOW (steps 4–6 are
mine) and U2/U3/U4/U4b STAGE RUN whole; the U4c UNIT RECORD whole (its window rides mine) and THE ORCHESTRATOR ON U4c's
HAND-BACK; `notes/plans/mcp-pane-and-docs-kickoff.md` whole; `notes/SessionResiliencyProtocol.md` whole; VX-281's record
(`notes/plans/fixes/vx-281-mcp-settings-pane-shared-icon.md` — the header, rulings, FOR VX-234, U1's UNIT RECORD through
its design and pieces) after the merge; **`notes/SyncSpec.md` in full, BEFORE piece 3's schema commit** (read 2026-10-14
~06:10, this session).

### LIVE STATUS — U1b's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | merge `origin/main` (`fa3bc6e1`, VX-281) into the branch — a merge commit; then headless finals + Mac `build-for-testing` into `App/Variorum/DerivedData/vx246-u1b` | DONE (`5be99e6d` the merge; this commit the record) — **NO CONFLICTS:** git's automatic merge joined the three files both sides touched — `App/Variorum/Variorum/Features/MCP/MCPDoor.swift` (ours: U3's hooks — `onWrite` → `landWireWrite`, `beforeWrite` → `flushHerEditorBeforeWrite`; theirs: VX-232's `setupClient` / `chooseSetupClient(_:)` and ladder R1-3's `copySetupCommand(for:)` with no default argument — both intact, read in the merged file), `.gitignore` (both screens folders kept), `notes/plans/mcp-pane-and-docs-kickoff.md` (their U6-done marks beside ours). **Headless finals on the merged tree** (`swift build --build-tests` then `swift test --skip-build`, EXIT 0, zero ✘; `u1b/logs/p0-finals.log`): **`VariorumMCPTests` 236 / 49 · `VariorumCoreTests` 2,834 / 328 · `StringsWorkbookTests` 40 / 6** — core +8 tests / +2 suites against U4c's 2,826/326, exactly what main brought (VX-281's core suites); MCP and the workbook unchanged. **The Mac `build-for-testing`** into `DerivedData/vx246-u1b` (an APFS clone of `vx246-u4c` — U4c's window rides this product, so the source product is spent; its OWED 5 noted) → `** TEST BUILD SUCCEEDED **`, EXIT 0 (`u1b/logs/p0-mac-build-for-testing.log`) |
| 1 | VX-258's FACE — (a) the mint call site (THE MERGE GATE), (b) the re-bind row in Waiting, (c) the words, (d) L1 / `keyLine` truth | DONE, its Mac runs PENDING (the window) — **the pins first (`9df5e874`, pre-fix API only):** NEW `MCPSetupTabKeyTests` (each tab's copy carries its client's name; a client's own setup re-run moves its approved name with zero clicks, both tabs; the control — an Any copy under an approved name waits), and the RED PRODUCT built from that tree: `DerivedData/vx246-u1b-red` (`** TEST BUILD SUCCEEDED **`, `u1b/logs/p1-red-build.log`) — its red run is the window's W1 (expected: 3 of 4 cases red — the tag test, both re-run cases — the control green). **The face (`43ee6209`):** (a) `MCPSetupClient.expectedName` (inside its O-4 fence) + `copySetupCommand` minting `copiedFor:` the chosen client's name; (b) Waiting's re-bind row (`MCPRebindRowView`, above the asks; the snapshot reads `Queries.mcpRebindRequests`; Allow / Don't allow through the runner; a gone setup said by Waiting; ⌥⌘,'s count includes the setups; two new `.surface` capabilities); (c) the three Activity lines + the refusal words; (d) L1, `keyLine`, `keySummary` (L1's summary unchanged — still true). NEW `MCPRebindFaceTests` (8) + six JUSTIFIED EDITS (each commented in place). `build-for-testing` into `vx246-u1b` SUCCEEDED, no warning in a touched file (`u1b/logs/p1-face-build.log`); the O-4 sweep green headless 2/2 (the fence now 80 of 120 lines). The design and the words: THE FACE section below |
| 2 | VX-318 — the trace first; a red-on-old pin; the fix only if the pin is red | DONE — **DISMISSED AS HOLLOW** (no fix; the trace and the evidence: THE VX-318 TRACE below). The pin `7c69369a` — NEW `Tests/VariorumMCPTests/MCPReaderAfterCloseTests.swift` (the production road with the reuse made certain: a real `MCPSession`, a burst in flight, the session ended by each production road, the host's close, `dup2` onto the freed number at once, a byte written to the fresh socket) — **GREEN on the pre-fix tree:** 3 plain runs and 4 runs under 24 CPU hogs (`u1b/logs/p2/loaded-run-*.log`), 304 session endings a run (150 client hang-ups · 150 server stops · 4 over-the-cap), zero bytes taken. **Its detection power proven** by a POSITIVE CONTROL (a temporary, never-committed stray reader reading the number after the close): **RED 150 of 150 on both roads and 4 of 4 over the cap** (`u1b/logs/p2/positive-control.log`); the file restored (`git checkout --`, `git status` clean). The pin stays as the ordering's guard (green both sides by design — said in its header) |
| 3 | P-VX260-1 option (b) — its own schema commit (v1_29, local-only), then the code, red-first | DONE — **the pins first (`911494e4`, pre-fix API):** NEW `Tests/VariorumMCPTests/MCPCommentWordsServerTests.swift` — **RED on the pre-fix tree: 1 test, 2 issues** (the suggest client's `delete_comment` LANDED on the comment whose words changed with no door — "deleted":true — and the comment was gone); the control `actsThatChangeNoWordLeaveItTheClientsOwn` green (`u1b/logs/p3-pins-red.log`). **The schema ALONE (`dfc1c2cd`)** — `notes/SyncSpec.md` read in full first: `v1_29_mcp_comment_words` → `mcp_comment_author.text_digest` (nullable), local-only on the family's road, NO BACKFILL (NULL = unproven); 2 schema pins + 1 justified edit; the schema/migration/sync-registry/export suites 58/7 green (`p3-schema.log`). **The code (`ead29354`):** `Domain/MCPCommentWords` (digest + `isOwn`), the record's write carries the digest, `Queries.mcpCommentIsOwn`, `deleteRung` reads it. **GREEN:** the wire pin 2/2; NEW core `MCPCommentWordsTests` 5/5; every comment suite unmodified (MCP 13/5 · core 57/20 by filter — `p3-green.log`). THE OPTION (b) DESIGN below |
| 4 | pins red again by revert per member; headless finals + the Mac build(s) | DONE — **VX-260 (b) red again by revert** (its production files to `911494e4`, the new-API core pin aside, run on a committed tree): the wire pin **1 test, 2 issues — identical to piece 3** (`p4-revert-260.log`); **RESTORED** (`git checkout HEAD --` + the files back; `git status` clean, `git diff HEAD` empty) → 2/2 + 5/5 (`p4-restored-260.log`). **VX-258's merge gate:** the REVERT product `vx246-u1b-revert` built (HEAD with ONLY the mint call site reverted; `p4-revert-258-build.log`), `MCPDoor.swift` RESTORED after (`git status` clean) — its red run is the window's W1b. **VX-318:** nothing to revert (hollow). **The final product `vx246-u1b` rebuilt on piece 3's tree** (`p4-mac-build.log`, `** TEST BUILD SUCCEEDED **`); all three products verified by symbol (THE PINS below). **Headless finals EXIT 0: MCP 240/51 · core 2,841/329 · workbook 40/6** (after the pin's SIGPIPE fix `24cef7bd` — THE PINS below) |
| 5 | THE STAGE WINDOW plan (claim `vx246-u1b`) → READY | DONE (this commit) — **READY for stage**; the stage NOT claimed. Scripts `u1b/run-w1-red.sh`, `u1b/run-u4c-w1.sh`, `u1b/run-w2-batch.sh` (`zsh -n` clean), `u1b/stage-suites.txt` (279 suites, every name a declared type), `u1b/driver-u1b.py` (compiled), `u1b/gen_fixture.py` (U4c's). THE STAGE WINDOW below |

**No revert is in flight.**

**Continuation (for a resume):** the build is done — READY. What remains is THE STAGE WINDOW (below), on the
orchestrator's GO, then its record and the result line.

### THE VX-318 TRACE (inputs → the feared state; why it cannot be reached)

The feared state (U1's OWED 3): `MCPSocketTransport`'s reader THREAD issues a `read(fd)` after the host has closed the
session's descriptor and the process has handed the number to another socket — reading that socket's bytes.

1. The host closes a session's descriptor only after `session.run()` returns (`MCPServerHost.serve`: `await
   session.run()`, then `ended(session)` → `closeConnection()`; VX-279's order).
2. `run()` returns only after `await server.waitUntilCompleted()` — the SDK's message-loop task has ended (and then
   `server.stop()` → `transport.disconnect()`).
3. That loop (`swift-sdk` `Server.start`, `for try await data in stream`) ends only when the transport's stream FINISHES
   (it never throws: the transport only ever calls `finish()`), or when its task is cancelled — and only
   `server.stop()` cancels it, which only `run()` calls, after step 2. `MCPSession.server` is private; nothing else
   reaches it. The SDK never stops itself (an initialize hook's throw answers an error and keeps looping).
4. The stream finishes in exactly two places: the reader thread's own `continuation.finish()`, AFTER `readLines`
   returned — i.e., after its LAST `read` returned ≤ 0, or after the over-cap arm, which reads nothing more — and
   `disconnect()`, which (step 3) runs only after the loop already ended, so only after the reader's own finish.
5. Therefore the host's close is always preceded by the reader's last `read`: a reader "descheduled between two reads"
   is still before its last read, so the stream is unfinished, the loop alive, `run()` unreturned, and the
   descriptor open — its next `read` lands on its own socket (EOF after the shutdown), never a reused number. The
   handshake's reader thread (`MCPHandshake.openingOutcome`) resumes `run()` only when it has finished reading — the
   same ordering, no timeout.
6. The writes are ordered too: `send` and the over-cap answer run on the transport actor and guard `isConnected`,
   which `disconnect()` clears on that same actor before `run()` returns — so no write lands after the close either.

**Disposition (the hallucination guard):** the pin reproduces the feared input on the production road (reuse at the
earliest instant, a reader mid-loop, every ending, under load) and is green on the tree it was written against; its
detection power is proven by the positive control. **VX-318 is DISMISSED AS HOLLOW — no production line changed.** The
ticket's fix shape (a bounded wait in the session's close for its reader) would guard a state the code cannot reach.

### THE FACE (piece 1) — the design, argued

- **(a) The mint call site — THE MERGE GATE.** `MCPSetupClient.expectedName` (inside the setup menu's O-4 fence — the
  one place a provider is named): Claude Code `claude-code` (seen live: VX-184 U1's round, Claude Code 2.1.296; the Pro
  runs 2.1.299 — leg 0 re-reads it), Codex `codex-mcp-client` (an EXTERNAL LOOKUP of its source, U1's trace item 6;
  Codex is not installed), Any MCP client `nil`. `copySetupCommand(for:)` reads the menu's choice once — after it has
  made the copied client the chosen one (R1-3's road, fact 5) and BEFORE the mint's await — and mints
  `copiedFor:` it. So the key minted is always the copied client's, whatever choice lands during the await (R1-3's
  receipt rule untouched). A client whose real name differs from its tab's connects as a request (unknown name) or
  waits for her OK (a known one, P-VX258-1) — never refused.
- **(b) Waiting's re-bind row.** The door's snapshot reads `Queries.mcpRebindRequests` in the same fetch as the rest
  (GRDB's region tracking puts `mcp_rebind_request` in the observation — no explicit region needed). `MCPRebindRowView`
  leads Waiting (above the asks — identity before reach), every waiting setup listed (one per client by
  `uq_mcp_rebind_request_client`, so ∝ clients; no "all N ›"). Its words: "New setup for ‹name›" ·
  "Connected as ‹name› (version ‹v›) with a setup that wasn't copied for it, ‹age›. It reaches nothing until you allow
  it; allowing moves the name, with its grants, to this setup." — the declared version is what tells her a stranger
  from the client she knows. **Allow / Don't allow** call `allowMCPRebind` / `declineMCPRebind` through the session's
  runner (P2); neither is styled as the default (the safe answer is not to press — a stranger's setup would take the
  name's grants). A press on a setup no longer waiting (`mcpRebindRequestNotFound`) says "That setup isn't waiting any
  more." BY WAITING (W-UX-8's place; Settings has no status seam); a landed answer speaks no caption (the row leaving and
  the Activity line are the answer, as Approve's and Deny's are). ⌥⌘,'s landing counts the setups
  (`MCPDoor.waitingCount`). No glyph: a waiting setup names a client, not a place in the library, so the ask glyph's
  places have nothing to mark. **P-1:** two new `.surface` capabilities, `mcpAllowRebind` ("Allow") and
  `mcpDeclineRebind` (`MCPAskCopy.dontAllow` — the ask sheet's own word, one source), declared on the pane.
- **(c) The words.** Activity (special-cased before the allowed/refused split — the wait is logged as not allowed per
  P-VX258-5 but is no refusal of the client): `connect_rebind_waiting` → "‹name› asked to use a setup that wasn't
  copied for it"; `connect_rebind_allowed` → "‹name› took the new setup you allowed, which replaced its earlier one"
  (the tail only when the row's target says a key was replaced); `connect_rebind_declined` → "‹name›'s new setup wasn't
  allowed". The refusal: `mcpRebindRequestNotFound` → "That setup isn't waiting any more."
- **(d) The truth lines.** L1 (`clientBoundary`): "…Each setup copied here carries a key that binds that name to it.
  Running the client's own setup again moves the name to the new key; a setup copied for any MCP client waits for your
  OK before it takes a name you approved; any other key, or none, is refused. That tells two tools apart, not programs
  running as you: …" — its one-line summary is UNCHANGED (still true: "A setup key tells two clients apart — not
  programs running as you."). `keyLine`: "…Running a client's own setup again replaces the old one; a setup copied for
  any MCP client waits for your OK before it takes a name you approved." `keySummary` (it said "running it again
  replaces the old setup" — false for an Any copy now): "Each copy carries a fresh key; running a client's own setup
  again replaces the old one." The guide's lesson 2 is U8's (the follow-on run) — OWED there.

### THE OPTION (b) DESIGN (piece 3) — argued

- **The rule:** the authorship record keeps a DIGEST of the words the client wrote (`Domain/MCPCommentWords.digest` —
  hex SHA-256 over `"variorum.mcp-comment-words.v1:" + text`, byte-exact, the setup key hash's shape), written in the
  comment's own transaction by both add doors (`addComment`, `addComments`) from the INSERTED row's text. A comment is
  the client's own only while the record names it AND its words now hash to that digest (`MCPCommentWords.isOwn`,
  read by `Queries.mcpCommentIsOwn`, read by `delete_comment`'s `deleteRung`). Any change to the words — her edit on
  any device (arriving by sync, which runs no door here), any client's `edit_comment` — and deleting needs EDIT; acts
  that change no word (an undo/redo revive, her delete + Put back, a sync arrival of the same words, her no-op edit)
  leave it as it was; the very words written back make it the client's again ("an unchanged digest means unchanged
  words"). U1's option (a) — her edit on THIS Mac forgets the record — stays built (harmless and immediate); (b) is
  what reaches her other devices. `Queries.mcpCommentAuthor` stays the FACT of authorship; ownership is the new read.
- **Backfill vs NULL-means-legacy — NULL MEANS UNPROVEN (built).** A record written before `v1_29` has no digest.
  (i) Backfilling the digest from each comment's CURRENT words would bless exactly the comments the rule exists to
  protect: her daily build (VX-184's) never forgets a record on her edit, and her phone/Air edits arrive by sync — so a
  record may already name a comment she has rewritten, and its current words cannot say which. (ii) NULL read as the
  client's own (legacy trust) keeps that same hole open for every pre-upgrade comment. (iii) NULL read as UNPROVEN —
  never the client's own: the strict reading, "the best protection" her VX-258 words ask of the door. The cost, said:
  a client's comments written before this build ask EDIT to delete (a client at suggest hears her R-VX188-2 sentence
  for them). The migration keeps every record (the authorship fact stays) and writes no digest. PROVISIONAL with the
  options (P-VX260-2 below).
- **The accepted residual (the orchestrator's, restated):** an EDIT-rung client's rewrite of its own comment also
  ends its suggest-rung ownership (pinned: `changedWordsFromAnyRoadEndItsOwnership`).
- **Zero lockstep:** the column is local-only (the grants family's road) — no `sync_version`, no trigger, never the
  outbox, no mirror, the marker 13, the plaintext export keeps the family empty. The digest never leaves the store.

### THE PINS (each read from its log — `notes/plans/vx246-screens/u1b/logs/`, gitignored)

| member | pin(s) | red on the pre-fix tree | green | red again by revert |
|---|---|---|---|---|
| VX-258's face — the merge gate | Mac `MCPSetupTabKeyTests` (4 cases: the tag test, the re-run case ×2 tabs, the Any control) | **PENDING — the window's W1a** on `vx246-u1b-red` (the pins commit `9df5e874`'s tree); expected 3 of 4 cases red, the control green | PENDING — W2 on `vx246-u1b` | **PENDING — the window's W1b** on `vx246-u1b-revert` (HEAD with only the mint call site reverted — built `p4-revert-258-build.log`, verified by symbol below); expected the same 3 red, the control green, `MCPRebindFaceTests` 8/8 green |
| VX-258's face — the row, the words, the truth | Mac `MCPRebindFaceTests` (8, new API — state transitions) + six justified edits | n/a (new API; the row is a design row — the walk is its oracle) | PENDING — W2 | — |
| VX-318 | `MCPReaderAfterCloseTests` (headless, 3 cases) | **GREEN — the row is HOLLOW** (7 runs, 4 under 24 hogs; positive control red 150/150 · 150/150 · 4/4, and again 10/10 · 10/10 · 2/2 on the committed atomic form) | 240/51 whole MCP target ×3 | n/a (no fix) |
| VX-260 (b) | MCP `MCPCommentWordsServerTests` (pre-fix API) + core `MCPCommentWordsTests` (5, new API) + 2 schema pins | wire pin **1 test, 2 issues**; the control green (`p3-pins-red.log`) | 2/2 + 5/5 + every comment suite unmodified (`p3-green.log`) | **1 test, 2 issues — identical** (`p4-revert-260.log`); RESTORED → 2/2 + 5/5 (`p4-restored-260.log`) |

**The three Mac products, verified by symbol** (`nm -n` + `swift demangle`, size = the next symbol's address minus
this one's; `MCPDoor.copySetupCommand(for:to:)`'s async fragments): **`vx246-u1b`** (the FIXED, merged product — HEAD
`24cef7bd`'s app sources, dylib 06:44) fragments {208, 220, 272, 616, 660}, `MCPSetupClient.expectedName.getter` 248,
`MCPRebindRowView` present, `static Queries.mcpCommentIsOwn` 1,400 (piece 3 inside); **`vx246-u1b-revert`** (dylib
06:40) fragments {196, 220, 248, 580, 660} (the mint call site reverted), `expectedName` 248 and the row present;
**`vx246-u1b-red`** (dylib 06:08 — the pins commit's tree) fragments {192, 212, 220, 544, 608}, NO `expectedName`, NO
row. Every product's test bundle carries `MCPSetupTabKeyTests`; `vx246-u1b`'s and `-revert`'s carry
`MCPRebindFaceTests`.

**Headless finals (piece 4 — the whole package on `24cef7bd`'s tree, EXIT 0, zero ✘; `p4-finals.log`):
`VariorumMCPTests` 240 / 51 · `VariorumCoreTests` 2,841 / 329 · `StringsWorkbookTests` 40 / 6** — against piece 0's
236/49 · 2,834/328: MCP +4 / +2 (`MCPReaderAfterCloseTests` 2, `MCPCommentWordsServerTests` 2), core +7 / +1
(`MCPCommentWordsTests` 5 + the two schema pins). **A finding on the way, fixed (test-only, `24cef7bd`):** the first
finals run died with SIGPIPE in the MCP target (signal 13) — my VX-318 pin's close-then-`dup2` left a window in which
another test in the same process could take the freed number, which the `dup2` then closed under it (the very VX-279
class it probes). The reuse is now ONE atomic `dup2` (the session's own close never called); the MCP target then ran
240/51 green three times running, and the whole package once more. **Path check (`ec879967^..HEAD` plus the face
commits):** zero lines under `Sources/VariorumCore/Sync/`, custody/Keychain/`Crypto/`, `Server/`, the editor seam
(`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, `Shared/EditorBrain`); ONE local-only schema
step (`v1_29`, its own commit `dfc1c2cd`).

**A machinery note (the products):** every APFS-cloned product of this run carried its SwiftPM artifacts' ABSOLUTE
paths from the first product, `DerivedData/vx246-u1` (in `SourcePackages/workspace-state.json`), which the coordinator
deleted mid-unit — so the next build in a clone failed ("There is no XCFramework found at …vx246-u1/…"). Fixed by
pointing each of my three products' `workspace-state.json` at its own `SourcePackages` (the artifacts are there); the
builds after that succeeded. Clone-builders: check that file.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u1b`)

**Built (rebuild ONLY if `git diff --name-only 24cef7bd..HEAD -- App` is non-empty — record-only commits since):**
`App/Variorum/DerivedData/vx246-u1b` (the FIXED, merged product — the live round, the walks, W2, U4c's W1 and W3),
`vx246-u1b-red` (W1a) and `vx246-u1b-revert` (W1b) — each verified by symbol above. The shim the live legs run:
`App/Variorum/DerivedData/vx246-u1b/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp` (SHIM below).
Evidence → `notes/plans/vx246-screens/u1b/` (gitignored; keys redacted to their first 9 characters everywhere).

**Estimate ~100 min of work → claim 120.** (A1 + prefs + fingerprint ~3 · W1 ~3 · U4c-W1 ~2 · W2 ~12 · the fixture ~5
· the live round, Study ~45 · Terminal ~20 · U4c's W3 both voices ~14 · cleanup ~8.) **Batch-only fallback (~25 min,
claim 35):** steps 0–1, W1, U4c-W1, W2, cleanup — the acceptance then stays OPEN for the live legs and walks.

0. **Guards, every step** (U4b/U4c STAGE RUN's, in force): `Tools/stage status` shows the claim held — never inside an
   `&&` chain (it exits 1 under a held claim); `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app`
   ABSENT — present ⇒ STOP and report, never quit or kill it); app instances checked with `pgrep -lx Variorum` (a
   sibling's headless build matches the `-f` form); every GUI act through `click.sh` / `keys.sh`, synthetic events
   ≥ 2.6 s apart; an undismissable system popup reported word for word and the window paused. A What's New sheet: its
   own button. A lock screen: `source ~/.variorum/dev-castle.env`, those values only, never written anywhere; the
   posture restored before release.
1. **A1 prestage + prefs + fingerprint, FIRST** (the test host is the dev-store app): every dev-store file and the key
   files → `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified, sha256 recorded
   (`u1b/store-hash-pre.txt`); `defaults export io.lduarte.Variorum.debug u1b/prefs-pre.plist`; the dev `Backups/`
   listing saved; **her user-scope MCP servers** read BEFORE (names + the sha256 prefix of the sorted compact
   `mcpServers` JSON, never values — the last four windows read `['linear-server', 'variorum']`, `bc64543e2f4e8e58`).
2. **W1 — VX-258's merge-gate pins RED (~3 min):** `zsh notes/plans/vx246-screens/u1b/run-w1-red.sh`, foreground.
   **Expected, W1a (`vx246-u1b-red`):** `MCPSetupTabKeyTests` **3 of 4 cases RED** — `eachTabsCopyCarriesItsClientsName`
   (Claude Code's and Codex's copies read `copiedFor` nil: the untagged `vmk1_` form), and
   `aClientsOwnSetupRerunMovesItsApprovedNameWithZeroClicks` for BOTH tabs (`.awaitRebind`, not `.rebind`; the name
   kept its first key; a waiting row exists); `anAnyClientCopyUnderAnApprovedNameWaitsForHerOK` GREEN. **W1b
   (`vx246-u1b-revert`):** the same three red, the control green, AND `MCPRebindFaceTests` **8/8 GREEN**. A red on a
   `premise:` line or a `#require` ⇒ record it as a harness defect, not evidence (no fix under the claim).
3. **U4c's W1 (~2 min):** `zsh notes/plans/vx246-screens/u1b/run-u4c-w1.sh` on `vx246-u1b`. Expected (U4c's plan step
   2, verbatim in force): 2 tests GREEN and the host's decisive line `VX-230 U4c [after pump(), no hop run]: block 40
   laid out = false` — a `true` means U4c's trace item 2 is wrong in the host: record it (the pin's green stands as the
   in-use evidence either way).
4. **W2 — the Mac batch (~12 min):** `zsh notes/plans/vx246-screens/u1b/run-w2-batch.sh` (279 suites,
   `u1b/stage-suites.txt` — every name a declared type, verified), detached to its log and POLLED in the foreground
   (`grep -q 'XCODEBUILD EXIT' …; sleep 5`). Expected green but the standing ones, NAMED if met: VX-115's
   `BookCollectingDoorsTests` (in the set); the gated capture harnesses SKIPPED (5 MCP + `MCPPaneTabsCaptureTests`);
   `IndexTierMetricsTests`' known issues if any. A red not designed: re-run it ALONE once
   (`"-only-testing:VariorumTests/<Suite>/<test>()"`); green alone + a named load-flake class ⇒ recorded as that;
   reproduces alone ⇒ a real red, reported with its message (no fix under the claim). Read every `✘` and the
   `skipped:` lines; record the per-group counts.
5. **THE FIXTURE (~5 min, her own Import door — U4c's step 4):** `python3 notes/plans/vx246-screens/u1b/gen_fixture.py
   notes/plans/vx246-screens/u1b/fixture`; launch `open -n …/vx246-u1b/Build/Products/Debug/Variorum.app` (1380 wide);
   File ▸ Import… → ⇧⌘G to the fixture → select ONLY `vx230-book` → Import (pressed by AX if a pointer click does not
   land) → the receipt "Imported 1 book…" captured once.
6. **THE LIVE ROUND — Study half (the dev store's voice as found).** A scratch project `u1b/live/proj` (an empty folder
   — `-s local` registrations live there, never her user scope); the tee wrapper `u1b/live/tee-shim.sh` (`#!/bin/zsh` ·
   `tee -a "$TEE_IN" | <SHIM> | tee -a "$TEE_OUT"`, the env passing through — U1/U3's form). **The setup line the pane
   copies (`claude mcp remove -s user …; claude mcp add -s user …`) is NEVER run as copied:** only its KEY is taken from
   the clipboard (a regex on `VARIORUM_MCP_KEY=…` / `"VARIORUM_MCP_KEY": "…"`), and registered `-s local` in the
   scratch project, or written to a scratch `--mcp-config` JSON for `claude -p --strict-mcp-config` (U3's road). Her
   user-scope fingerprint re-read after every add/remove: SAME.
   - **Leg 0 — posture + Claude Code's real name:** Settings ▸ MCP (the app menu's Settings…, then the sidebar's MCP):
     the switch ON and "running"; the Clients tab: `claude-code`'s row (approved? N grants? — the Deny confirm names
     them) captured. **Branch:** `claude-code` unknown or pending ⇒ leg 1 starts as a first contact (a request →
     Approve… with NOTHING picked), then runs as written.
   - **Leg 1 — a Claude Code TAB key re-binds `claude-code`, zero clicks:** Connect tab ▸ the client menu on Claude Code
     ▸ the code block's copy icon (help "Copy setup command") → the key reads **`vmk2_claude-code_…`** (record its first
     9 characters — and the 17-character tag-bearing head) → `claude mcp add -s local variorum-dev -e
     VARIORUM_MCP_KEY=<key> -- u1b/live/tee-shim.sh` (TEE_IN/TEE_OUT set) in the scratch project → `claude mcp list`
     → **`variorum-dev` ✔ Connected** — NO pane press (Waiting stays empty: capture) → the tee's first frame: the
     `initialize` `clientInfo.name` **"claude-code"** (leg 0's live read — record the line) → ONE `claude -p` turn
     ("list my Variorum notes", allowed `mcp__variorum-dev__list_notes`) → served → Activity tab: "claude-code
     connected with a newer setup, which replaced its earlier one" (or "…with a new setup, now bound to its name" if it
     was unbound) — capture.
   - **THE GRANT for the legs below (U3's deviation, recorded):** `claude-code` ▸ Change… ▸ A wing · Home · Edit · Always
     (one sheet) — unless leg 0 found an equivalent standing grant. Recorded either way.
   - **Leg 2a — an Any-client key under `claude-code` WAITS, a REAL Claude Code; her Don't allow:** Connect ▸ Any MCP
     client ▸ copy icon → the JSON stanza's key **`vmk1_…`** → a SECOND scratch registration `variorum-dev-any`
     (`claude mcp add -s local variorum-dev-any -e VARIORUM_MCP_KEY=<any key> -- u1b/live/tee-shim.sh`, its own
     TEE files) → `claude mcp list` → **`variorum-dev-any` ✔ Connected** (admitted to a request's face) → ONE `claude -p
     --strict-mcp-config` turn whose config holds ONLY the any server, asked to list the books → it finds no Variorum
     tool (record its words); the tee: an EMPTY `tools/list` → **Settings ▸ MCP: Waiting, above the tabs: "New setup
     for claude-code" · "Connected as claude-code (version 2.1.299) with a setup that wasn't copied for it, … It
     reaches nothing until you allow it; …" · Allow · Don't allow** (capture; a crop of the row) → **Don't allow** → the
     row leaves (capture) → Activity: "claude-code asked to use a setup that wasn't copied for it" and "claude-code's
     new setup wasn't allowed" (capture) → `claude mcp list`: `variorum-dev-any` **✘** (its tee: the ONE refusal
     sentence) and `variorum-dev` **✔** (the client she knows never noticed). `claude mcp remove -s local
     variorum-dev-any`.
   - **Leg 2b — her Allow serves the SAME connection, no reconnect (the scripted client — `driver-u1b.py`, ruling 1's
     precedent: `claude -p` cannot hold a session across her press):** Connect ▸ Any MCP client ▸ copy → a fresh `vmk1_`
     key → `VARIORUM_MCP_KEY=<key> python3 -I u1b/driver-u1b.py <SHIM> claude-code waitallow 180 > u1b/live/2b.jsonl
     2> u1b/live/2b.err &` → READY → its first line: `"tools": []` and `list_notes` answering the pending sentence
     ("This client's connection request is waiting in Variorum ▸ Settings ▸ MCP. Nothing is readable until the author
     approves it.") → the Waiting row (capture) → **Allow** → within seconds the driver's lines: `"list_changed": true`,
     then `tool_count` > 0 and `list_notes_isError` false — the SAME connection served (capture the pane: no row;
     Activity "claude-code took the new setup you allowed, which replaced its earlier one") → `claude mcp list`:
     `variorum-dev` (leg 1's tab key, now REPLACED) ✘ — its tee shows the replaced key's own sentence → **re-run the
     Claude Code tab's setup** (copy → re-register `variorum-dev` with the fresh tab key) → ✔ zero clicks (Activity
     "connected with a newer setup…") — the real-client road restored for the legs below.
   - **Leg 3 — VX-259, the rename to a hidden book's name lands without echo:** her own doors: a new Home book
     **"u1b secret"** (the Bookcase's new-book door), its Book Settings ▸ State ▸ Private on (her door — R-VX184-2), and
     a new Home book **"u1b shelf"**; a third, **"u1b open"** (readable through the wing grant). ONE `claude -p` turn
     (allowed `list_books`, `rename_book`): rename "u1b shelf" to **"U1b Secret"** → LANDS; the tool's answer names
     only "U1b Secret" — a grep of the tee for the stored casing "u1b secret" finds nothing; the Bookcase shows both
     (capture). The control, the same or the next turn: rename "U1b Secret" to **"u1b open"** → refuses, naming "u1b
     open" (BookNameCopy's sentence; the client CAN read it). Name everything back is NOT needed (the store restore).
   - **Leg 4 — VX-260 (a) and (b) on the wire: a suggest delete of a comment whose words changed hears her sentence:**
     a Home note **"u1b c4"** with one block ("Comment me."), via the quick entry. The suggest client is the driver:
     `VARIORUM_MCP_KEY=<fresh Any key> python3 -I driver-u1b.py <SHIM> vx260-suggest hello` → "Connection request —
     vx260-suggest" → Approve… → Suggest · note "u1b c4" · Always. Driver `call add_comments
     '{"note_id":"…","comments":[{"block_id":"…","text":"C1 check this."},{"block_id":"…","text":"C2 a source?"},
     {"block_id":"…","text":"C3 tighten."}]}'` (ids from a driver `call read_note '{"note_id":"…","with_ids":true}'`).
     **(a) her edit:** her Comments panel ▸ C1 → rewrite to "C1 checked — it's 1971." (capture). **(b) a change with no
     door of hers:** ONE `claude -p` turn (claude-code at Home EDIT): `edit_comment` C2 to "C2 a source, please?" (the tool
     needs `expected_text` — the comment's current words; give the id and both texts in the prompt)
     (the record's digest no longer matches; option (a) alone would have let the suggest client delete it). Then the
     driver: `call delete_comment` C1 → **"You don't have permission to delete that comment. Suggest raising your
     permission level to edit."** byte-equal; C2 → the same sentence; C3 → deleted (`"deleted": true`). Her panel: C1
     (her words) and C2 (the rewrite) live, C3 in the deleted fold (capture).
   - **U2's W2 — the client's VALUE and TOGGLE directions:** a Home note **"u1b undo"** (One. / Two. / Three., quick
     entry), open in Write. ONE `claude -p` turn: `rename_note` it to "renamed by claude" and `lock_take` the take of
     block "One." (tee-captured answers). Her own doors: the title field back to "u1b undo"; the take's card ▾ ▸ Unlock
     (Takes). Then ⌥⌘Z → the toast **"Nothing to undo — claude-code's take lock was already undone or changed since."**
     (capture) → ⌥⌘Z → **"Nothing to undo — claude-code's note title was already undone or changed since."** (capture)
     → the Edit menu open: **Redo DISABLED** (on an empty redo stack the item is disabled — `EditorCommands.swift:576`,
     U2 STAGE RUN's finding; no toast is expected) → her title and her unlock stand (capture).
   - **U2's W3 — the REVIVE direction:** ONE `claude -p` turn: `add_comment` on block "One." of "u1b undo" → her
     Comments panel ▸ delete that comment → ⌥⌘Z → **"Nothing to undo — claude-code's comment was already undone or
     changed since."** (capture) → Redo disabled → the comment stays deleted (the panel's deleted fold shows it once).
   - **RULING 2's real-client check — the focus stays where she types:** two Home notes **"u1b r2 a"** (one block "Her
     page.") and **"u1b r2 b"** (one block "Its page."); ⌘K open "u1b r2 b", then ⌘K open "u1b r2 a" (pane 1) → View ▸
     Open Beside (the most recently opened note no pane shows: "u1b r2 b", in a new right pane) → click into pane 1's
     "Her page." (pane 1 focused, its masthead; pane 2 the thin "… · click to edit" line) → type " She types." through
     `keys.sh` (BEFORE capture) → ONE `claude -p` turn: `delete_note` "u1b r2 b" → **AFTER (capture): pane 2 shows the
     Library IN PLACE under the thin line; pane 1 keeps its masthead and the caret** → type " Still here." → it lands in
     "u1b r2 a" (capture). View ▸ Close Split.
   - **U4c's W3, Study (U4c's plan step 5, verbatim in force):** ⌘K ▸ "vx230-book" → Outline → expand all → click into
     block 2 of "vx230 book opening" → scroll down (guarded `walk-scroll` steps of 9) until blocks ~38–42 stand in view
     → click into **block 40**'s text ("block 40/70"; single take) → capture → scroll back UP the same steps to the
     note's top (block 40 far below; the caret stays in it) → **⌘T** → capture (the receipt; blocks 1–4 ⑂2 at their
     lines, 5 bare; NO stray ⑂, no disc) → scroll down the same steps → **block 40 wears ⑂2 AT ITS OWN FIRST LINE**,
     neighbours at theirs, no two ⑂ at one place (capture + crop). ⌘T refusing or doing nothing ⇒ the menu bar's "New
     Take (Branch)" by AX, recorded.
7. **THE VOICE SWITCH:** Settings ▸ General ▸ Theme ▸ Terminal (pressed by AX), Settings closed by its own button.
8. **Terminal half:** **Leg 2c** — the driver with a fresh Any key as `claude-code` (`waitallow 120`, background) → the
   Waiting row in Terminal (capture) → **Don't allow** → the driver's line `"list_changed": false` at its timeout
   (record it; its connection still reaches nothing), the row gone, Activity in Terminal (capture). **Leg 2d** — the
   same with **Allow** → the driver served on the same connection (record), Activity (capture) → re-run the Claude Code
   tab setup (as in 2b) so `variorum-dev` is ✔ again. **U4c's W3, Terminal:** the same road with **block 45** (40 is
   fanned by the Study half). **Leg 5 — Codex: N/A** (`which codex` empty at READY, 2026-10-14; its name stands on the
   external lookup).
9. **CLEANUP (~8 min):** both scratch registrations removed (`claude mcp get variorum-dev` → "No MCP server named …");
   her user-scope servers AFTER: byte-identical fingerprint; every scratch key, the mcp-config JSONs and the tee files
   checked for keys, then deleted; the clipboard emptied (`pbcopy < /dev/null`); a whole-key grep over
   `vx246-screens/u1b/`, the scratchpad, `~/.claude.json` and the scratch project's transcripts = 0 files; the Debug app
   quit BY BUNDLE ID (`pgrep -lx Variorum` empty; no shim or driver left); prefs: `defaults import` +
   `defaults delete` of every key the window added → re-export → 0 keys differ; the store: `Tools/ScaleFixture/restore.sh
   <the prestage dir>` → "Restored (verified)" + a second `cmp`, the sha256 set equal to the pre-window hashes (the
   posture handed over: Standard, unlocked, the store's voice — and `claude-code`'s pre-window binding and grants come
   back with it); no new backup from the launches (the `Backups/` listing diffed); the fixture folder deleted; no stray
   `default.profraw`; **`Tools/stage release --who vx246-u1b`** at once; ONE result line: the claim times, W1a/W1b,
   U4c-W1 + the decisive line, W2's totals, each leg's verdict, U2 W2/W3, ruling 2, U4c W3 per voice, the posture, the
   fingerprint, the A1 copy's path (the coordinator's to prune).

### SELF-ASSESSMENT (pre-stage — the implementer's)

- **Against the brief, per piece:** piece 0 merged with no conflicts and both sides intact (read in the merged
  `MCPDoor`); piece 1 builds the merge gate exactly as OWED 1 (a) specified and the face (b)–(d) on vx-281's five facts
  — the row in Waiting above the tabs, the refusal said where she pressed, the words in a single source, L1/keyLine
  true with their summaries brought along (fact 1); piece 2 traced VX-318 end to end and found it HOLLOW — the pin
  (production road, reuse certain, every ending, under load) is green on the pre-fix tree and its detection power is
  proven, so NO fix (the contract's rule 3 over the brief's "fix shape"); piece 3 built option (b) red-first with its
  schema commit alone and SyncSpec read first, backfill argued against.
- **Against the spec:** zero `Sync/`, custody/Keychain, `Server/`, editor-seam lines; one LOCAL-ONLY schema step (v1_29,
  marker 13, zero lockstep); I1–I10/P1–P3/S1–S5 untouched (the new reads are keyed — ∝ one comment, ∝ the clients);
  AppSpec §12's "a door that did nothing speaks a refusal" holds for the re-bind row; P-1 holds (two new declared
  `.surface` doors, walked by `surfaceCapabilities`).
- **Less sure, said plainly:** (1) the face is unseen on a screen — every Mac pin and the row's look are the window's;
  (2) Codex's `clientInfo.name` is an external lookup, never seen live (leg 5 N/A); a wrong name there costs a Codex user
  her approval click (the key waits for her OK), never a refusal; (3) option (b)'s strict NULL reading changes the
  suggest rung's reach over every comment a client wrote before this build (they need EDIT to delete) — the cost is
  bounded and recorded (P-VX260-2); (4) the window is long — the plan keeps a batch-only fallback.
- **Context:** this session is at roughly 300–350k tokens of context as the plan is written (an estimate: the run record
  and the code read in full); under the ~450k line, but the window is long — the orchestrator may prefer a fresh
  runner for it, and the plan above is written for one.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX258-7 — the re-bind row's place and look:** (a) as built — it LEADS Waiting (above the asks: identity before
  reach), every waiting setup listed (one per client), Allow and Don't allow equal and quiet (no default); (b) after
  the asks; (c) Allow styled primary (the request row's Approve… precedent) — rejected for now: the press hands a
  stranger the name's grants.
- **P-VX258-8 — what Activity says for the wait:** (a) as built — "‹name› asked to use a setup that wasn't copied for
  it" (an ask, though logged not-allowed per P-VX258-5); (b) the refusal form "‹name› was refused connecting with a
  setup that wasn't copied for it" (true of the log's outcome, false of what she can still do).
- **P-VX260-2 — a record from before the words' digest (v1_29):** (a) as built — NULL = UNPROVEN: never the client's
  own, so deleting it needs EDIT; (b) backfill the digest from the comment's current words at the migration — blesses
  any comment she already rewrote on another device or in a build without VX-260's forget; (c) NULL = the record's word
  (legacy trust) — the hole open for every pre-upgrade comment. **P-VX260-1** itself (her edit on another device)
  stays provisional with its options (a)/(b)/(c) — (b) is now built.

### FOR VX-234 (user-facing words, as built — her pane-wording pass)

| # | Words (as built) | Where it renders |
|---|---|---|
| U1b-1 | "New setup for ‹name›" | Settings ▸ MCP ▸ Waiting, the re-bind row's title (`MCPPaneCopy.rebindTitle`) |
| U1b-2 | "Connected as ‹name› (version ‹v›) with a setup that wasn't copied for it, ‹age›. It reaches nothing until you allow it; allowing moves the name, with its grants, to this setup." | the row's detail (`rebindDetail`; no version declared ⇒ no parenthesis) |
| U1b-3 | "Allow" · "Don't allow" | the row's two buttons (`mcpAllowRebind`, `mcpDeclineRebind` — the ask sheet's "Don't allow") |
| U1b-4 | "That setup isn't waiting any more." | by Waiting, after a press on a setup no longer waiting (`MCPPaneCopy.refusal`) |
| U1b-5 | "‹name› asked to use a setup that wasn't copied for it" · "‹name› took the new setup you allowed, which replaced its earlier one" (the tail only when a key was replaced) · "‹name›'s new setup wasn't allowed" | the Activity tab and its "all N ›" (`activityLine`) |
| U1b-6 | L1: "…Running the client's own setup again moves the name to the new key; a setup copied for any MCP client waits for your OK before it takes a name you approved; any other key, or none, is refused. …" | the Clients tab's (i) (`clientBoundary`; its one-line summary unchanged) |
| U1b-7 | "…Running a client's own setup again replaces the old one; a setup copied for any MCP client waits for your OK before it takes a name you approved." · its line "Each copy carries a fresh key; running a client's own setup again replaces the old one." | the Connect tab, under the code block (`keySummary`) and its (i) (`keyLine`) |
| U1b-8 | the unavailable note "A client's new setup waits for you in Settings ▸ MCP ▸ Waiting." | the registry's note for both new capabilities (shown where a declared door cannot act) |

### OWED (for the orchestrator)

1. **THE STAGE WINDOW** above (claim `vx246-u1b`) — W1/W2 and every live leg; U2's acceptance closes with W2/W3 there,
   U4c's with its W1–W3.
2. **U8 (the follow-on run):** the field guide's lesson 2 still says "Running the setup again moves the name to the new
   key" for every tab — true now only of a client's own tab; an Any-client re-run waits for her OK. The guide and
   `MCPSession.instructions` should say the tab rule and the Waiting row (and that a waiting connection sees no tools).
3. **Canon at the merge** (adding to U1's OWED 5): AppSpec §12 THE MCP DOOR — the re-bind row in Waiting (Allow / Don't
   allow; a waiting setup admitted with no reach), the mint copied FOR the tab's client; §7's grants-family bullet gains
   v1_29 (`mcp_comment_author.text_digest`, local-only, marker 13, zero lockstep) beside v1_28; the comment-ownership
   rule (VX-260 (a)+(b): her edit on this Mac forgets the record; any change to the words, from any device, ends a
   client's ownership; a pre-v1_29 record is unproven). MOBILE PARITY: nothing mobile-visible (the phone's comment edit
   reaches option (b) through sync — the phone holds no record).
4. **VX-318 → close as HOLLOW** (no fix; the trace and the pin are its record; the pin stays as the ordering's guard).
5. **Housekeeping:** the three products (`vx246-u1b`, `-red`, `-revert`) are the window's; after it, `-red` and
   `-revert` can go. The cloned-product absolute-path trap (the machinery note above) for whoever clones next.

## U4c UNIT RECORD — the inline editor's badge regression: VX-230 (opus-implementer, from 2026-10-14 ~05:35 MDT)

**Not done (first line, kept current; the state at READY, 2026-10-14 ~05:50 MDT):** NO product line changed — the trace
(measured) found no product defect, so there is no fix; the work is the regressed pin's HARNESS (corrected) and one
in-use pin. Nothing has run on a Mac (both pins are Mac pins: W1 and W2 below); no stage window has run (READY, the
stage NOT claimed); no walk; no QUESTIONS entry, canon edit or ticket (the orchestrator's). Zero `Sync/`, custody,
Keychain, schema, `Server/`, `BlockRangeIndex`, `PaneSurface`, `runStructural`, VX-281's lane — and zero product files:
`EditorView.swift` and `EditorViewModel.swift` are untouched (vx-282's two touches with them).

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon; this record's header, THE UNITS, the hard
rules, LIVE STATUS, Cross-run coordination; the U4c BRIEF; the U4 UNIT RECORD's traces; U4 STAGE RUN's trace; the U4b
UNIT RECORD whole and the U4b STAGE RUN whole; `notes/plans/mcp-pane-and-docs-kickoff.md`'s VX-230 entry;
**`notes/TEXTKIT2_NOTES.md` whole, BEFORE any editor-seam edit**; `notes/SessionResiliencyProtocol.md` whole. Code read:
`InlineEditorWindowTests` whole (the regressed pin's harness, `makeInlineWindow`), `withEditorWorld` / `EditorWorldHarness.focus`
(the 600×100 text view), `EditorHarness.reload`, `EditorViewModel.applyProjection` (the `.adoptEcho` arm), `attach`'s two
doors, `overlayLayoutDidSettle`, `refreshBadges` (U4b's), `refreshDecorations`' gate, `viewportBounds`;
`InlineEditorSurface.Coordinator` whole (`install`, `scheduleRemeasure`, `displayPassSettled`, `remeasure`);
`EditorTextView.setFrameSize` / `applyFrameHeight` / `viewWillDraw` / `makeInlineEditor`; `LongBlockLayout.considerLongBlockLayout`
(inert on the inline surface); U4b's probes 5–9.

### LIVE STATUS — U4c's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + the trace MEASURED on bare TK2 probes (the decisive number: block 40's fragment state at the pin's `:76`) | DONE (`d2e386d4`) — probes 10–13 + `*-output.txt` in `notes/plans/vx246-screens/u4c/probes/` (gitignored; macOS 27.0, 26A428). **The decisive number: block 40 is `estimated` at `:76` (y = 14,909, a GUESS; settled 14,560).** The finding: a HARNESS-order defect, no product defect (below) |
| 1 | the pins: the regressed pin's HARNESS corrected (it waits as the app runs; the in-use road folded in; the badge asserted at its own laid line) + the transient arm (a fan adopted mid-reflow) | DONE (`885f9d8e`) — `InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport` (after `remeasure(); pump()`, `await settle(window)` — 24 turns of display + `Task.yield` + 5 ms — so the width door's queued remeasure lands; then block 40 fanned by `branchVariant` (her panel's op) AND block 45 by `Operations.addTake` (the MCP door's op), adopted through `applyProjection(_, fromDelivery: true)` (the observation's road → `.adoptEcho`) with NO explicit refresh and NO wait; both badged at once, each at its own LAID line, outside the clip; the transient's state printed for the window's log, `VX-230 U4c [after pump(), no hop run]`); NEW `FanBadgePlacementTests.aFanAddedFarOffScreenMidReflowIsBadgedByTheQueuedRemeasure` (a client's take on block 100 adopted in the SAME turn as a width change 700 → 420: no badge at the adoption — premise: the fragment unlaid — then, with nothing more from her, the already-queued remeasure lays the post out and the badge stands at its own line, outside the clip, `expectEveryBadgeHome`). Compiled in `vx246-u4c` (piece 4); no warning in a touched line (the one at `InlineEditorWindowTests.swift:48` is `makeInlineWindow`'s pre-existing forced cast, in U4b's log too) |
| 2 | a RED product | NOT APPLICABLE — no product fix, so no red-first product: the OLD pin's red on `vx246-u4b` is U4b STAGE RUN W2's (reproduced alone, `:78`/`:80`), and the trace explains it (piece 0). The new transient arm's old-tree red (the origin badge before U4; a poisoned place never re-read after the heal on U4) is by trace only, NOT run (no product carries it with their code) — said in its doc |
| 3 | the fix | NONE — **DISMISSED AS HOLLOW** as a product defect (piece 0's trace): the inline post is laid in the steady state and a no-text-change fan is badged at once; in a transient the already-queued remeasure re-runs the pass. Zero product lines |
| 4 | the product `DerivedData/vx246-u4c` + the headless finals | DONE — **the product BUILT:** an APFS clone of `vx246-u4b`, `build-for-testing` → `** TEST BUILD SUCCEEDED **`, EXIT 0 (`u4c/logs/mac-build-for-testing.log`); **its app code IS U4b's, by symbol:** `EditorViewModel.refreshBadges()` 3,696 bytes and `WorkspaceModel.select(_:in:takingFocus:)` 1,652 in both `vx246-u4b` and `vx246-u4c` (`git diff --name-only cd843647..HEAD -- Sources App` was EMPTY before this commit; this commit touches two test files only). **Headless, `swift build --build-tests` then `swift test --skip-build` on `885f9d8e`'s tree, EXIT 0: `VariorumMCPTests` 236 / 49 · `VariorumCoreTests` 2,826 / 326 · `StringsWorkbookTests` 40 / 6**, zero ✘, the skip set the standing gated nine — identical to U4b's finals (no core line moved; `u4c/logs/p4-finals.log`). **A machinery note:** the clone's build removed the XCFramework copies (`Sparkle.framework`, `SQLCipher.framework`, their dSYMs, three xpc/app dSYMs) and the VFS `all-product-headers.yaml` from the SOURCE product's `Build/Products/Debug` — the same in every product this run cloned from (`vx246-u1` … `vx246-u4b-red`); each app bundle keeps its embedded frameworks, and those products ran their windows after it (W1a on `vx246-u4b-red`), so it is harmless to `test-without-building` |
| 5 | THE STAGE WINDOW plan (claim `vx246-u4c`) → READY | DONE (`bf25a92e`) — **READY for stage**; the stage NOT claimed. The scripts `u4c/run-w1.sh` (the two pins alone) and `u4c/run-w2-batch.sh` (`u4c/stage-suites.txt`, 13 suites, every name a declared type) parse (`zsh -n`); the fixture generator copied to `u4c/gen_fixture.py`. THE STAGE WINDOW below |

**No revert is in flight.**

### The trace, MEASURED (inputs → wrong output) — the runner's trace CORRECTED: the pin reads a transient its own pump cannot leave

**The rig** (`u4c/probes/probe10`/`12`/`13`): a bare TK2 `NSTextView` shaped like `makeInlineEditor` (inset 8, not
vertically resizable, a width-tracking container, Terminal's 14-pt monospace, `paragraphSpacing` 7), the pin's own
50-block corpus, the harness's `600×100` frame (`EditorWorldHarness.focus`), the caret parked at the end (the fill), in a
borderless window positioned off-display BEFORE it is ordered in (`.prohibited` activation — the VX-179 offscreen probe
rules), so the run loop drives a REAL display pass (`viewWillDraw` counted). Numbers are container-space y.

1. **The pin's `pump()` runs NO main-queue hop** (probe 11). Swift Testing runs a `@MainActor` test's body as a main-actor
   job — inside a main dispatch queue callback — and CFRunLoop does not service the main queue from a run loop nested in
   one: `RunLoop.main.run(until: +0.05 s)` left a `DispatchQueue.main.async` block un-run; one `await Task.yield()` ran it.
   (This is why the sibling pins wait with `await` — `inlineBadgesTrackAWidthReflow`'s "async polling drains the settle
   trigger's main-queue hop".)
2. **The pin's sequence, in its REAL order** (probe 12 §I; 400 blocks in probe 13 §I, the same shape):
   - `:67` `coordinator.remeasure()` walks the post at the harness's 600-pt width (all 50 laid), and its OWN report sets
     the frame to 700 × h — a WIDTH change, which returns EVERY fragment to `.none` (U4's fact 1). The width door queues
     the remeasure hop that would re-lay the post at 700.
   - `:68` `pump()`: one display pass and NO hop (fact 1 above). The viewport is the frame's END (the container is not
     flipped; vis 20,901–21,201, past the 700-pt text's end): TK2 lays out block 49 alone, ahead of its 49 unlaid
     predecessors, and ESTIMATES the rest. **Block 40 reads `estimated`, y = 14,909 — a guess** (settled: 14,560).
   - `:75`–`:77` `branchVariant` + `reload()` → `.adoptEcho` (`slots = new`, `refreshBadges()`, no storage edit) and the
     direct `refreshBadges()`: both read block 40 `estimated`. U4b's `refreshBadges` (U4's `.layoutAvailable` check) gives
     it NO badge — **its documented contract** ("unlaid-out blocks simply have no badge until laid out … the remeasure's
     walk, inline"). `:78` red; `:80`'s `#require` falls with it.
   - Had the queued hop run (the app's order — the next `await`), its walk lays all 50 out (block 40 `laid`, y = 14,560)
     and U4b's call re-runs the badge pass after it.
3. **The runner's trace, corrected in two places:** (a) nothing UN-laid block 40 "in between" — the `:67` walk laid it
   out at the OLD width, and the same call's report changed the width; (b) the display pass did not un-lay anything (it
   never does in the steady state, item 4) — it laid the END out ahead and left block 40 estimated, because the hop that
   would have re-laid the post never ran inside `pump()`.
4. **The in-use road is COVERED — the runner's "what it means in use" does not hold** (probe 12 §II; probe 13 §II at
   400 blocks, ~80k words). The inline editor mounted the app's way (a 24-pt frame, the first remeasure's walk, SwiftUI
   applying the height on a later pass, display passes): **every fragment `laid`**, and it STAYS laid through display
   passes and host scrolls to mid-post, the end and back. Fragments leave `laid` only on the two doors that queue the
   coordinator's remeasure: a storage edit (the edited paragraph `none`, then `estimated` after a display pass, until
   the hop's walk) and a width change (every fragment `none`, then the viewport `laid` and the rest `estimated`, until
   the hop's walk). So a fan adopted with no text change (an MCP `add_take`, a sync arrival, a take branched from a
   panel — all `.adoptEcho`) meets a laid post in the steady state and is badged AT ONCE, at its own line; adopted
   inside one of the two transients, it is unbadged until the hop that is ALREADY queued walks the post and U4b's call
   re-runs the badges (the same burst, the next main-queue turn), never "until her next keystroke or a width change".
5. **Why the pin was green on the older trees — for the wrong reason, both times.** It asserts PRESENCE and "outside
   the clip", never the line. On `vx246-u3` (no state check) the transient read badged block 40 at TK2's GUESS
   (14,909 + 8, ~350 pt off its line in the rig — VX-230's own estimate class, U4's trace). On `vx246-u4` the forced
   `.ensuresLayout` read laid block 40 out AHEAD of its unlaid predecessors — U4b's poison (fact 1 of its record). U4b's
   correct refusal to badge a guess is what turned it red.
6. **Write (the brief's "say which"):** the same transient reading exists by design and is no gap: the detail editor
   lays out only its viewport, an off-screen fan has no badge until it is scrolled to, and `ScrollAnchorController`'s
   scroll road re-runs the pass (U4's proven half). Unchanged.

**The disposition this trace forces (the hallucination guard):** no product mechanism is wrong, so there is no fix and
no red-first product pin — VX-230's U4c row is **DISMISSED AS A PRODUCT DEFECT (hollow); the defect is the PIN's
harness.** A forced read (banned), or any synchronous lay-out inside `refreshBadges`, is the only way to make the pin
green as written, and it would put the badge at a guessed or poisoned place. The work left is the pin itself
(piece 1): the harness waits as the app runs (the hops land), the in-use road is folded in (a fan through the MCP's
`addTake`, delivered on the observation's road), and the badge is asserted at its own laid line, which the old pin
never checked.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx246-u4c`)

**Built (rebuild ONLY if `git diff --name-only 885f9d8e..HEAD -- Sources App` is non-empty; record-only commits since):**
`App/Variorum/DerivedData/vx246-u4c` — `885f9d8e`'s tree: U4b's app code exactly (verified by symbol, piece 4) + the two
pins. No red product exists (no fix); the OLD pin's red on `vx246-u4b` is U4b STAGE RUN W2's, reproduced alone there.

**Estimate ~35 min of work → claim 45** (A1 + prefs ~3 · W1 ~2 · W2 ~6 · the fixture import ~4 · W3 ~14 for both
voices · cleanup ~6). **Batch-only fallback (~15 min, claim 20):** steps 0–1, W1, W2, cleanup; the walk moves to the
next window.

0. **Guards, every step** (U4b STAGE RUN's, verbatim in force): `Tools/stage status` shows the claim held — never inside
   an `&&` chain (it exits 1 under a held claim); `Tools/WalkKit/guard.sh --author` (her `/Applications/Variorum.app`
   ABSENT; present ⇒ STOP and report, never quit or kill it); app instances checked with `pgrep -lx Variorum` (a
   sibling's headless build matches the `-f` form); every GUI act through `click.sh` / `keys.sh`, synthetic events ≥ 2.6 s
   apart; an undismissable system popup reported word for word and the window paused.
1. **A1 prestage + prefs, FIRST** (the test host is the dev-store app): every dev-store file and the key files copied to
   `…/Variorum-dev/Backups/safety-copies/scale-prestage-<ts>/`, each `cmp`-verified, sha256 recorded
   (`u4c/store-hash-pre.txt`); `defaults export io.lduarte.Variorum.debug u4c/prefs-pre.plist`; the dev `Backups/`
   listing saved. No MCP leg runs, so her user-scope servers are not touched (fingerprint not needed; read it anyway if
   cheap, names + a sha256 prefix only — U4b's `bc64543e2f4e8e58`).
2. **W1 — the two pins alone (~2 min):** `zsh notes/plans/vx246-screens/u4c/run-w1.sh`, foreground; log `u4c/logs/w1.log`.
   **Expected: 2 tests GREEN**, and the decisive line printed by the host:
   `VX-230 U4c [after pump(), no hop run]: block 40 laid out = false` — the bare rig's transient (probe 12 §I) confirmed
   in the real host. **Read as found:**
   - the line reads `true` ⇒ the host lays block 40 out inside `pump()`, so the trace's item 2 is wrong in the host:
     record it, and re-trace before any claim (the pin's green stands as the in-use evidence either way);
   - a red on a `premise:` line or a `#require` (the mid-reflow pin's "the width change left the far block's fragment
     unlaid", the steady-state premise) is a harness defect, not evidence: record it, nothing fixed under the claim;
   - any other red is a FOUND product defect on the in-use road: re-run it ALONE once, then record it with its message
     (no fix under the claim).
3. **W2 — the inline-editor and badge family (~6 min):** `zsh notes/plans/vx246-screens/u4c/run-w2-batch.sh` (13 suites,
   `u4c/stage-suites.txt`), detached to its log and POLLED in the foreground (`grep -q 'XCODEBUILD EXIT' …; sleep 5`).
   Read the summary, every `✘`, the `skipped:` lines. **Expected: all green** — `InlineEditorWindowTests` 3/3 (the budget
   pin's "inline keystroke + remeasure" line read and recorded), `FanBadgePlacementTests` 7/7, the rest as at U4b's W2.
   A red not designed: re-run it ALONE once (`"-only-testing:VariorumTests/<Suite>/<test>()"`); green alone and in a named
   load-flake class ⇒ recorded as that; reproduces alone ⇒ a real red, reported with its message (no fix under the claim).
   VX-167's `redoNeverAsks` is not in this set.
4. **THE FIXTURE (~4 min, her own Import door):** `python3 notes/plans/vx246-screens/u4c/gen_fixture.py
   notes/plans/vx246-screens/u4c/fixture`, then the fixed app `open -n DerivedData/vx246-u4c/Build/Products/Debug/Variorum.app`
   (window 1380 wide; a What's New sheet closed by its own button; a lock screen unlocked from `~/.variorum/dev-castle.env`
   and the posture restored before release) → File ▸ Import… → ⇧⌘G to the fixture → select ONLY the `vx230-book` folder →
   Import (pressed by AX if a pointer click does not land — U4b's lesson) → the receipt "Imported 1 book…" captured once.
   The book: two chapters × two notes × 70 blocks, every block fanned (⑂2) but each fifth (5, 10, …, 70 single-take).
5. **W3 — THE WALK, Study then Terminal (~7 min each):** one region capture per row into
   `notes/plans/vx246-screens/u4c/w3/<voice>/`, crops of the badge column. **The road (her own door, ⌘T "New Take
   (Branch)", `EditorViewModel.mintCaretTake(blank: false)` — the caret block, no text change → `.adoptEcho`):**
   - **(a) mount + caret:** ⌘K ▸ "vx230-book" → Outline → **expand all** → click into block 2 of "vx230 book opening"
     (the live inline editor, "editing") → `walk-scroll` down in guarded steps (9 per step) until blocks ~38–42 stand in
     view → click into the TEXT of **block 40** (Study; **block 45** in Terminal — 40 is fanned by then) — the indicator
     reads "block 40/70" (45) → capture: block 40 BARE (single take), its fanned neighbours each ⑂2 at their own lines.
   - **(b) the fan lands far off-screen:** `walk-scroll` back UP the same number of steps to the note's top (block 40 far
     below the view; the caret stays in it) → ⌘T through `keys.sh` → capture: the receipt ("New take added on this block —
     ⌘⇧T shows the takes.", or its quiet bottom-bar line), the top unchanged (blocks 1–4 ⑂2 at their lines, 5 bare), NO
     stray ⑂ and no disc at block 1's place. If ⌘T refuses or does nothing on this surface: the menu bar's "New Take
     (Branch)" by AX — recorded as the road taken.
   - **(c) scrolled to:** `walk-scroll` down the same steps → capture: **block 40 (45) wears ⑂2 AT ITS OWN FIRST LINE**,
     its neighbours at theirs, no two ⑂ at one place, the single-take blocks around it bare.
   - **The voice switch, between halves:** Settings ▸ General ▸ Theme ▸ Terminal (pressed by AX), Settings closed by its
     own button.
6. **CLEANUP (~6 min):** the Debug app quit BY BUNDLE ID (`pgrep -lx Variorum` empty); prefs: `defaults import`
   `u4c/prefs-pre.plist`, `defaults delete` every key the window added, re-export, diff until 0 keys differ; the store:
   `Tools/ScaleFixture/restore.sh <the prestage dir>` → "Restored (verified)" + a second `cmp`, the sha256 set equal to the
   pre-window hashes — the posture handed over (Standard, unlocked, Study voice); no new backup from the launch (the
   `Backups/` listing diffed); the fixture folder deleted (the generator stays); no stray `default.profraw`;
   **`Tools/stage release --who vx246-u4c`** at once; ONE result line: the claim times, W1 (both green + the decisive
   line), W2's totals, W3's verdicts per voice, the posture.

### SELF-ASSESSMENT (pre-stage — the implementer's)

- **Confident:**
  - **The mechanism is measured, and it is two facts, each by its own probe.** Probe 11: a run loop nested in a
    main-actor job runs no main-queue hop (an `await` does). Probe 12 §I: in the pin's real order, block 40 is
    `estimated` at the read (a guess, ~350 pt off its settled line), and the queued hop would have laid it out. Probe 13
    repeats both at 400 blocks.
  - **The in-use claim is measured too** (probe 12 §II, probe 13 §II): in the steady state every fragment of the inline
    post is laid out and stays laid through display passes and host scrolls. Fragments leave that state only on the two
    doors that queue the coordinator's remeasure, whose walk U4b's call follows with the badge pass.
  - **No product line moved**, so nothing can regress the U4b window's walk or batch. The product's app code is U4b's by
    symbol, and the headless finals are identical.
- **Less sure, said plainly:**
  - (1) The probes are a bare rig: the system 14-pt monospace and an off-display borderless window, not the test host's
    titled window, the app's attribute set or its overlays. W1's printed line is the host's confirmation of the
    decisive number; if it reads `true`, the trace's item 2 is wrong in the host and W1's record says so.
  - (2) The corrected pin's `settle` is a fixed 24 turns (the FanBadgePlacement idiom). The hops it waits for need two or
    three turns, plus the heal's display pass.
  - (3) The mid-reflow pin's old-tree red is argued, not run: no product carries it with older code. Its premise (the far
    fragment unlaid right after a width change) is U4's fact 1, already green in this host
    (`textKitReportsAnUnlaidFragmentAsZeroAndAZeroRectIntersects`).
  - (4) The heal's edge trigger (a display pass that moves fragments without moving the last one's bottom re-runs
    nothing) is U4b's design, unchanged here; the mid-reflow pin has the same shape as U4b's green width pin.
- **The judgement this unit makes, for the orchestrator to accept or overturn:** it corrects a pre-existing pin rather than
  the product. The case: the old pin's red is a harness-order read of a transient the app never idles in, and its old
  green was a badge off its line. Making it green as written needs a synchronous lay-out inside `refreshBadges` (the
  brief bans the forced read), which would put the badge at a guessed or poisoned place, against VX-230's own rule. The
  corrected pin is STRONGER (the line, two roads, no explicit refresh, no wait after the adoption).
- **Editor-seam letter:** no editor-seam line changed (test files only). TK1 untouched. vx-282's two `EditorView.swift`
  touches untouched.
- **MOBILE PARITY:** nothing mobile-visible.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

**None.** No product behavior was decided: the corrected pin asserts U4/U4b's accepted contract (an unlaid fragment is no
position; the inline region is the whole post), and the mid-reflow pin asserts the same.

### FOR VX-234 (user-facing words, as built)

Nothing. No word changed.

### OWED (for the orchestrator)

1. **The U4b STAGE RUN trace's "what it would mean in use" paragraph is FALSE** (piece 0, item 4): a no-text-change fan
   is badged at once in the steady state, and in a transient by the already-queued hop. It must not reach the handoff,
   the ticket or canon as a known gap.
2. **TEXTKIT2_NOTES — a PROPOSED harness fact** (canon is the orchestrator's at the closeout), beside §3's existing
   "HARNESS fact (the walk/test families)" bullet: *"HARNESS fact (VX-246 U4c, 2026-10-14; probe-verified): Swift Testing
   runs a `@MainActor` test's body as a main-actor job, inside a main dispatch queue callback, and a run loop nested there
   (`RunLoop.main.run(until:)`) services display passes and timers but runs NO `DispatchQueue.main.async` block; an
   `await` (one `Task.yield()`) does. A pin that pumps the run loop and expects a queued hop (a remeasure, an overlay
   settle, the settle net's heal) to have run is reading the transient before it."* And one TK2 fact for U4b's proposed
   §3 finding: *"after a width change returns every fragment to `.none`, a display pass lays out only the viewport and
   ESTIMATES the rest (a guessed frame, ~350 pt off on 50 paragraphs)."*
3. **A sweep candidate (not this unit's):** other Mac pins may pump with `RunLoop.main.run` inside a main-actor body and
   expect a queued hop to have run. A pin like that can be hollow or flaky in the way this one was. Worth a ticket only if
   the orchestrator wants the audit.
4. **VX-327 (the decoration sibling) gains one fact:** the inline post is fully laid in the steady state (probe 12 §II),
   so the decor pass's `.zero` reads on the inline surface can occur only in the two transients — the probe should drive
   one.
5. **The machinery note** (piece 4): an APFS-cloned product's first build removes the SOURCE product's XCFramework copies
   from its `Build/Products/Debug`. Harmless to `test-without-building` (the app bundle embeds them), but a reason never to
   clone FROM a product a pending window still needs, without checking afterwards.
6. **The Fable cold review** covers U4b's `refreshBadges` and `remeasure` call; this unit adds only the two pins and this
   trace for it to weigh.

### THE ORCHESTRATOR ON U4c's HAND-BACK (2026-10-14, ~05:55 MDT)

- **The call: ACCEPTED (same-model arbitration).** U4c corrects a pre-existing pin rather than the product.
  - The red was measured to be the pin's harness: `pump()` runs no main-queue hop (probe 11), and the pin's own height
    report widened the frame and returned every fragment to `.none`.
  - The pin's old green was for the wrong reason: it asserted that a badge existed, never its line, so it passed on a
    guessed place (U3) and a poisoned one (U4).
  - The corrected pin is strictly stronger: it asserts the line, covers two roads (`branchVariant` and the MCP door's
    `addTake`), and allows no refresh after adoption.
  - Making the OLD pin green would need a forced synchronous layout in `refreshBadges`, which U4b measured as poisoning
    positions, against VX-230's own rule.
  - **The arbiter is the live walk** (U4c's W3, in U1b's window): a take branched far off-screen wears its badge at
    its own line in both voices. If it fails there, VX-230 reopens.
- **The U4b runner's "in use" paragraph** ("unbadged until her next keystroke or a width change") is FALSE by U4c's
  probes 12–13. It must not reach the handoff.
- **The OWED items.**
  - OWED 3 is now **VX-333** (the `pump()` sweep).
  - OWED 4 went to VX-327 as a comment: the inline post is fully laid out in the steady state, so only the two
    transients matter.
  - OWED 2 (the TEXTKIT2 harness and estimate facts) goes to the closeout's canon, together with U4b's corrected
    §3 proposal.
  - OWED 5 (cloned products lose their XCFramework copies) is a tooling note, recorded here.
  - OWED 6: the Fable review weighs this trace.
- **No separate U4c window.** It rides U1b's, on the merged product. The ladder waits for U1b either way, so this costs
  nothing on the critical path and saves a claim and an A1 cycle.

### THE ORCHESTRATOR ON U1b's HAND-BACK (2026-10-14, ~06:45 MDT)

- **Accepted as reported.** Green suites were not re-run.
  - The merge of main was CLEAN, with `MCPDoor.swift` auto-merged. The face closes THE MERGE GATE: the tab keys carry
    their names.
  - **VX-318 is dispositioned HOLLOW** by the hallucination guard: a self-traced mechanism shows the close can't
    precede the reader's finish, and the pin stayed green on the old tree under load while its positive control went
    red. No fix was made; the ticket closes at the merge as not-a-bug, and the pin stays as a guard.
- **The PROVISIONALs stand as built,** into QUESTIONS at the merge.
  - P-VX258-7: the re-bind row leads Waiting, with Allow and Don't allow equal and quiet.
  - P-VX258-8: the wait is worded as an ask in Activity.
  - **P-VX260-2:** a record from before the digest column counts as UNPROVEN, so deleting it needs EDIT. This is the
    strict reading, and the right one. A backfill would hash today's words and could bless an edit she made under
    VX-184's build: the exact VX-260 bug, inherited.
- **DOC-TRUTH OWED, which tonight's merge must not ship without.** The field guide's MCP chapter, lesson 2
  (`TutorialSeeder.swift`, near line 2552), says "Running the setup again moves the name to the new key". After
  VX-258 that holds only for a client's OWN tab; an Any-client setup waits for her OK.
  - The fix is a minimal truth edit, in VX-184's VX-198 way, with `TutorialMCPChapterTests`' pin moved with it.
  - It lands in the ladder's first fix pass, and the closeout's Mac run proves it on the final tree.
  - U8 (now the follow-on run) re-voices the chapter.
  - VX-292, the other `TutorialSeeder` writer, is not in flight: the in-flight table on main shows only VX-246 and
    VX-282.
- **A tooling lesson.** APFS-cloned DerivedData products keep ABSOLUTE package-artifact paths
  (`SourcePackages/workspace-state.json`) into the product they were cloned from. Deleting a finished unit's tree (the
  coordinator's disk ask) broke builds in its clones until U1b repaired its three products' files. Before deleting a
  product, check that no live product was cloned from it, or fix the clone's `workspace-state.json`.

## U1b STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14 ~07:00 MDT)

**What this run does NOT do (said first):** no product code is written or changed, under the claim or before it; a red
that needs code is recorded and reported, never fixed here. Leg 5 (Codex) is N/A: `codex` is not installed (`which
codex` empty at READY). No canon, QUESTIONS or ticket edits. No rebuild: the window runs the three products exactly as
built. The copied setup line (`claude mcp remove -s user …; claude mcp add -s user …`) is never run as copied: only its
key is taken, and it is registered `-s local` in a scratch project (or written to a scratch `--mcp-config` JSON).

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, the Stage traffic log,
Cross-run coordination's facts, her rulings, ORCHESTRATOR'S PROVISIONAL RULINGS (rulings 1–3); U1's THE STAGE WINDOW
(legs 0–5, step 2's A1 text, step 5's detour) and THE ORCHESTRATOR ON U1's HAND-BACK; U2's THE STAGE WINDOW (steps 4–6,
W2/W3) and THE ORCHESTRATOR ON U2's HAND-BACK; U2, U3, U4 and U4b STAGE RUN whole (the A1 copy BEFORE the batch;
`defaults import` merges, so re-export and diff; the batch detached and polled in the foreground; `Tools/stage status`
exits 1 under a held claim, never in an `&&` chain; `pgrep -lx Variorum`, never the `-f` form; the copied setup line
edits USER scope); the U1b UNIT RECORD whole (THE STAGE WINDOW plan, the products table, PROVISIONALs, FOR VX-234, OWED)
and THE ORCHESTRATOR ON U1b's HAND-BACK; the U4c UNIT RECORD whole (its W1–W3) and THE ORCHESTRATOR ON U4c's HAND-BACK;
`notes/SessionResiliencyProtocol.md`; `Tools/stage`, `Tools/WalkKit/` (README, `guard.sh`, `click.sh`, `keys.sh`),
`Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); U1b's `run-w1-red.sh`, `run-u4c-w1.sh`,
`run-w2-batch.sh`, `stage-suites.txt`, `driver-u1b.py`, `gen_fixture.py` and U4c's scripts; the memory notes
walk-driving-lessons and walk-restores-dev-store-posture. Code read for the live round: `MCPSetupMenu` (the code block,
the client picker, the copy icon "Copy setup command"), `MCPPaneCopy` (`setupCommand` / `setupJSON` — where the key sits
in each form; `MCPSetupClient.expectedName`), `MCPPane` (the switch, Waiting and the requests ABOVE the four tabs, the
re-bind row's Allow / Don't allow), the Settings pane order (MCP is the seventh), and the wire tools' schemas the driver
calls (`read_note` `with_ids`, `add_comments`, `delete_comment`).

**The build check (before READY):**
- **No source moved since the products were built.** HEAD `5f033dcb`; `git diff --name-only edfc0f12..HEAD -- Sources
  App` is EMPTY (and `24cef7bd..HEAD -- App` / `-- Sources` too; record-only commits since). No
  `.swift`/plist/pbxproj/xcstrings/entitlements/`Package.swift` under `Sources` or `App/Variorum` is newer than
  `vx246-u1b`'s `Variorum.debug.dylib` (06:44:28). The shim (`variorum-mcp`, 06:00) is current: no file under
  `App/Variorum/VariorumMCPShim` or `Sources/VariorumMCPSocket` is newer, and their last commit is VX-181's. The test
  edits since `9df5e874` (the red product's tree) are the face's justified edits, carried by `vx246-u1b`. The tree is
  clean.
- **Each product is what its name says, read from its symbols** (`nm -n` + `swift-demangle --simplified`, size = the
  next text symbol's address minus this one's; `scratchpad/u1b/syms.py`), matching the U1b products table exactly:
  - `vx246-u1b`: `MCPDoor.copySetupCommand(for:to:)` fragments {208, 220, 272, 616, 660} (+ its closure #1 188 and a
    partial apply 40, not in the table's set), `MCPSetupClient.expectedName.getter` 248, `MCPRebindRowView` 33 symbols,
    `static Queries.mcpCommentIsOwn(_:commentID:client:)` 1,400.
  - `vx246-u1b-revert`: fragments {196, 220, 248, 580, 660} (+ closure #1 172), `expectedName` 248, the row 33 symbols,
    `mcpCommentIsOwn` 1,400.
  - `vx246-u1b-red`: fragments {192, 212, 220, 544, 608} (+ closure #1 172), NO `expectedName`, NO row, NO
    `mcpCommentIsOwn`.
  - Test bundles: `MCPSetupTabKeyTests` in all three; `MCPRebindFaceTests` in `vx246-u1b` and `-revert` only; U4c's
    `aFanAddedFarOffScreenMidReflowIsBadgedByTheQueuedRemeasure` in all three. **→ no rebuild.**
- **The clone-paths trap, checked (THE ORCHESTRATOR ON U1b's HAND-BACK):** each product's
  `SourcePackages/workspace-state.json` names 5 absolute paths, every one EXISTS and every DerivedData path lies inside
  that product's own folder (the worktree root, `SourcePackages/artifacts/…/Sparkle.xcframework`,
  `…/SQLCipher.xcframework`, `SourcePackages/checkouts/…`). Each `Build/Products/Debug` still holds `Sparkle.framework`
  and `SQLCipher.framework`, each app bundle embeds both, and each product has its `.xctestrun`. The app is signed
  *[removed for publication]*
- **The W2 list:** `stage-suites.txt` 279 unique names, every one found in `vx246-u1b`'s test bundle symbols (0
  missing); U4c's 13 suites are all inside it; VX-115's `BookCollectingDoorsTests` is in the set; VX-167's
  `DestructiveUndoWarningTests` and VX-245's `ChromeLineLimit…` are not. The three run scripts parse (`zsh -n`); the
  driver compiles (`py_compile`).
- **Host and tools:** grants probed with no prompt, `AX: true SCREEN: true`; `walk-cap` / `walk-scroll` compiled into
  the scratchpad; `Tools/WalkKit/wl2` present; Claude Code **2.1.299**, Python 3.12.13, `cliclick` present; `codex` not
  installed. Free disk **63 GiB**. No Variorum instance (`pgrep -lx Variorum` empty).
- **Her user-scope MCP servers (names + a sha256 prefix of the sorted, compact `mcpServers` JSON, never values):**
  `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — the same as U3's, U4's and U4b's windows
  (`u1b/userscope-ready.txt`). Re-read at the window's start, after every add/remove, and after cleanup.

**Process choices (the earlier runs' lessons applied):** the A1 copy, the prefs export and the fingerprint come FIRST,
before W1 (the test host is the dev-store app); W1a/W1b and U4c's W1 in the foreground; W2 detached to its log and
POLLED in the foreground; every GUI act through `click.sh` / `keys.sh`, at least 2.6 s apart; region captures; the Debug
app quit BY BUNDLE ID; the prefs restored by import, then a re-export and a diff, deleting every key the window added,
until 0 differ; keys redacted to their first 9 characters in every record and capture name.

**Minutes:** ~100 of work expected (the plan's: A1 + prefs + fingerprint ~3 · W1 ~3 · U4c-W1 ~2 · W2 ~12 · the fixture
~5 · the live round, Study ~45 · Terminal ~20 · U4c's W3 both voices ~14 · cleanup ~8); a **120-min claim** asked.
Batch-only fallback (~25 min, claim 35): steps 1, W1, U4c-W1, W2, cleanup — the acceptance then stays OPEN for the live
legs and walks.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the GO's exact line) |
| 0 | guards on every step; the claim from the GO's line; HEAD at the GO | DONE — the GO from oct13coordinator under its **SEAM PLAN** (its pre-checks 07:06: no instances, no booted sims, 66 GiB free; the dev store last left Standard/unlocked/Study). **HEAD at the GO `34104d74`** (this section's READY commit; no source moved). Its exact line run: `Tools/stage release --who coord-for-vx246 && Tools/stage claim --who vx246-u1b --reason "VX-246 U1b: red-on-old + U4c W1 + 279-suite batch | SEAM | live round both voices (A1, MCP fingerprint)" --minutes 120` → **CLAIMED 07:06:46 MDT, 120 min** (expires 09:06:46). Pre-claim: `guard.sh --author` OK (idle 4,155 s), `pgrep -lx Variorum` empty. **THE SEAM PLAN re-orders the window (the coordinator's call):** W1a, W1b, U4c's W1 and W2 FIRST, with NO A1 copy and NO prefs export before them; then a SEAM (record, commit, push, keep the claim, report "SEAM"); the A1 copy, prefs export, fixture, live round and cleanup after it. Said: the A1 copy therefore holds the batch's store side effects, and the restore returns the POST-batch store (the coordinator's order — it keeps both runs' restore checks clean). For the record only, the store's sha256 set was read BEFORE the batch (`u1b/store-hash-prebatch.txt`: sqlite `c21acf370329` · wal `bf008b686e0e` · shm `42360ab67f3b` · keys `3af4704371ff` / `7e12a1b85890`) |
| 1 | A1 prestage copy (every store file + key files, each `cmp`-verified, sha256 recorded) + `defaults export` + the `Backups/` listing + her user-scope fingerprint BEFORE | DONE (07:18, after the seam — the coordinator's order) — **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T131848Z`** (`u1b/a1-path.txt`), five files each `cmp`-verified (sha256 prefixes: sqlite `c21acf370329` · wal `8fd7ce01dfb4` · shm `61beca20f145` · keys `3af4704371ff` / `7e12a1b85890`; `u1b/store-hash-pre.txt` — the sqlite equal to the pre-batch read, the wal/shm moved by the batch's test host, as the seam plan expected); prefs exported (**1,580 keys**, `appearanceChoice` = system) to `u1b/prefs-pre.plist`; `Backups/` listed (`backups-pre.txt`); her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME |
| W1 | `run-w1-red.sh` — W1a (`vx246-u1b-red`: `MCPSetupTabKeyTests` 3 of 4 red, the Any control green) + W1b (`vx246-u1b-revert`: the same 3 red, the control green, `MCPRebindFaceTests` 8/8 green); a red on a `premise:` line or a `#require` ⇒ a harness defect, that leg stopped and reported | DONE (07:06:53 → 07:08:12) — **RED ON OLD AND RED BY REVERT, EXACTLY AS DESIGNED; no `premise` and no `#require` line in either log.** **W1a** (`vx246-u1b-red`, `u1b/logs/w1a-red-on-old.log`, `w1a-red.xcresult`): "✘ Test run with 3 tests in 1 suite failed after 0.111 seconds with **10 issues**", EXIT 65 — `eachTabsCopyCarriesItsClientsName` RED (4 issues: `:82` `MCPSetupKeyRule.copiedFor(key) == name` and `:85` `key.hasPrefix(copiedForPrefix + name + "_")`, for Claude Code AND Codex — the copies untagged); `aClientsOwnSetupRerunMovesItsApprovedNameWithZeroClicks` RED for BOTH cases, `.claudeCode` and `.codex` (6 issues: `:117` `admitted.decision == .rebind` · `:119` the name did not take the new key · `:123` a waiting row exists); `anAnyClientCopyUnderAnApprovedNameWaitsForHerOK` GREEN. **W1b** (`vx246-u1b-revert`, `u1b/logs/w1b-red-by-revert.log`, `w1b-revert.xcresult`): "✘ Test run with 11 tests in 2 suites failed after 0.356 seconds with **10 issues**", EXIT 65 — the SAME three cases red on the same lines (`:82`/`:85` ×2, `:117`/`:119`/`:123` ×2), the Any control GREEN, and `MCPRebindFaceTests` **8/8 GREEN** (the face does not depend on the mint) — **the merge gate is exactly the mint call site** |
| U4c-W1 | `run-u4c-w1.sh` on `vx246-u1b` — the two pins GREEN + the host's line `VX-230 U4c [after pump(), no hop run]: block 40 laid out = false` | DONE (07:08:21 → 07:08:42) — "✔ Test run with **2 tests in 2 suites passed** after 1.231 seconds", EXIT 0 (`u1b/logs/u4c-w1.log`, `u4c-w1.xcresult`): `InlineEditorWindowTests.inlineBadgesCoverTheWholePostNotJustTheClippedViewport` ✔ (0.451 s) and `FanBadgePlacementTests.aFanAddedFarOffScreenMidReflowIsBadgedByTheQueuedRemeasure` ✔ (0.779 s). **The host's decisive line, as printed: `VX-230 U4c [after pump(), no hop run]: block 40 laid out = false`** — U4c's trace item 2 confirmed in the real host (the transient its own `pump()` cannot leave) |
| W2 | `run-w2-batch.sh` — 279 suites on `vx246-u1b`; a red re-run alone once; standing reds named (VX-115 in the set) | DONE (07:08:45 → 07:16:58) — "✘ Test run with **1838 tests in 279 suites** failed after 457.212 seconds with 5 issues (including 4 warnings)", EXIT 65 (`u1b/logs/w2-batch.log`, `u1b/w2-batch.xcresult`). **The result bundle: 1,818 passed · 19 skipped · 1 failed** (its second "failure" entry is the unattributed «Issues recorded without an associated test» — U3's door-pin harness noise, "@Dependency(\.withRandomNumberGenerator) has no test implementation, but was accessed from a test context" ×4, `FractionalIndex.swift:46`, seen at U3/U4/U4b; 0 expected failures). **The 19 skips are the gated set:** the 7 UNKEYED-oracle singleton tests, the List-face harness's 5, and the 7 MCP capture harnesses (`MCPPaneTabsCaptureTests` and the five U1 named, incl. `TutorialMCPChapterCaptureTests`). **The one red is VX-115's STANDING red, in the set as the plan said:** `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads()` at `:101` "`BookView.surfaceCapabilities == [.openBookSettings]`" (the surface now also declares `searchThisBook` …) → **re-run ALONE once (07:17): reproduces, 1 issue, the same line** (`u1b/logs/w2-rerun-bookcollecting.log`) — VX-115's standing red on main (listed at the VX-184 and VX-281 merge-moment runs), not this branch's; nothing changed. **Every face pin GREEN on the merged product:** `MCPSetupTabKeyTests` 4/4 (the red-first pins, green on the fix — **VX-258's merge gate proven red → green**), `MCPRebindFaceTests` 8/8, `MCPSetupMenuTests`, the MCP pane suites, U1's G1–G3 and U4c's 13 suites (`InlineEditorWindowTests`, `FanBadgePlacementTests` … ) — zero ✘ outside VX-115's line. VX-167's and VX-245's suites are not in the set |
| SEAM | the coordinator's seam: the batch recorded, committed and pushed; the claim KEPT; the turn ended with "SEAM" | DONE (07:18) — the claim `vx246-u1b` held (~11 of 120 min used); no Variorum instance; nothing launched yet; the dev store untouched by this window except the test host's opens. The window resumes at step 1 on "continue", or releases and later re-claims on the coordinator's word |
| F | the fixture (`gen_fixture.py`) through File ▸ Import… — ONLY `vx230-book` | DONE (07:19–07:21) — generated into `u1b/fixture/`; `open -n` the `vx246-u1b` Debug app (pid 39924, 1380×900 at (60,36); **Study, light, the Bookcase; no What's New sheet, no lock screen**, `live/s/00-launch`); File ▸ Import… by its menu item → ⇧⌘G to the fixture → ONLY `vx230-book` selected (`live/f/02`) → Import pressed by AX → **"Imported “vx230-book” — 4 notes in 2 chapters · ⌥⌘Z undoes"**, the book open in Outline (`live/f/03-imported`) |
*[removed for publication]*
| V | the voice switch to Terminal | DONE (07:45) — app menu ▸ Settings… ▸ General ▸ Theme: the two unnamed radios read `0, 1` (Terminal, Study) → the first pressed by AX → **`1, 0`**, the window in Terminal (`live/v/00`, `01`) |
*[removed for publication]*
| C | cleanup: registrations removed, fingerprint AFTER, keys/clipboard/grep = 0, the app quit by bundle id, prefs 0 differ, `restore.sh` + cmp SAME, `Tools/stage release --who vx246-u1b`, the result line | DONE (07:50–07:52) — **the scratch registrations GONE:** `claude mcp remove -s local variorum-dev` → removed; `claude mcp get variorum-dev` and `… variorum-dev-any` → "No MCP server named …" (the configured set: Claude Docs, linear-server, variorum); the scratch project's local `mcpServers` in `~/.claude.json` EMPTY. **Her user-scope servers AFTER `['linear-server', 'variorum']`, `bc64543e2f4e8e58` — SAME** (`userscope-post.txt`; re-read SAME after every add/remove in the window). The Debug app quit BY BUNDLE ID (`pgrep -lx Variorum` empty; no shim, no driver). **The whole-key grep:** each of the window's 8 keys (tab1–3, any2a–d, sug4) searched whole in `vx246-screens/u1b/`, `~/.claude.json`, the scratch project's transcripts and `notes/` → **0 files each**, and 0 in the scratchpad outside the key folder; then the keys and the mcp-config JSONs DELETED and the clipboard emptied (0 bytes). **Prefs:** the window added 9 keys and changed 7 → `defaults import` of `prefs-pre.plist` + `defaults delete` of the 9, then one late `surfaceSize.outline.*` key (written at the quit) deleted → re-export **1,580 keys, 0 added · 0 removed · 0 changed** (`prefs-post.plist`). **The dev store:** `restore.sh …/scale-prestage-20261014T131848Z` → **"Restored (verified)"** (`logs/restore.log`), a second `cmp` of all five files **SAME**, and the sha256 set EQUAL to the A1 copy's (`store-hash-restored.txt` = `store-hash-pre.txt`) — the store as handed over at the seam (Standard, unlocked, Study voice in the store; `claude-code`'s pre-window binding and grants return with it; every scratch note, book and comment gone with the window). **No new backup** from the launch (`Backups/` entries unchanged). The fixture folder deleted (the generator stays); no stray `default.profraw`; the tree clean. **RELEASED 07:52:05 MDT** (`Tools/stage release --who vx246-u1b` → STAGE RELEASED; `status` → STAGE FREE), 45 of the 120 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx246-u1b` 07:06:46–07:52:05 MDT, RELEASED (45 of 120 min), under the coordinator's SEAM PLAN
(the batch first, A1 after the seam).
- **W1a** (`vx246-u1b-red`): red on old exactly as designed — `MCPSetupTabKeyTests` 3 tests, 10 issues (the tag test for both tabs; the re-run case
  for both tabs), the Any-client control green; no premise or `#require` line. **W1b** (`vx246-u1b-revert`): the same 3 red (10 issues), the control
  green, `MCPRebindFaceTests` 8/8 green — the merge gate is exactly the mint call site.
- **U4c W1** (`vx246-u1b`): 2 tests in 2 suites passed; the host printed `VX-230 U4c [after pump(), no hop run]: block 40 laid out = false`.
- **W2** (`vx246-u1b`, 279 suites): 1,838 tests — 1,818 passed, 19 gated skips, 1 failed: VX-115's standing `BookCollectingDoorsTests:101` (reproduces
  alone; main's). The 4 warnings are U3's known harness noise. `MCPSetupTabKeyTests` 4/4 and `MCPRebindFaceTests` 8/8 green.
- **The live round, Study — every leg PROVEN:** leg 0 (claude-code's live `clientInfo.name` "claude-code", 2.1.299); leg 1 (a Claude Code tab key
  `vmk2_claude-code_…` binds with zero clicks, and its re-run replaces with zero clicks); leg 2a (an Any key under claude-code waits with no tools;
  her Don't allow; the one refusal; the client she knows unaffected); leg 2b (her Allow serves the scripted client's SAME connection — `list_changed`,
  61 tools — and the replaced key hears its own sentence); leg 3 (VX-259: the rename to a Private book's name lands without echoing its stored casing,
  0 lines in the tee; the readable control refuses); leg 4 (VX-260 (a)+(b): a suggest delete of a comment she edited, and of one rewritten with no
  door of hers, both hear her R-VX188-2 sentence byte-equal; its untouched comment deletes); U2's W2 (after her retitle and unlock, ⌥⌘Z speaks the
  take-lock and note-title refusals, Redo disabled, her values stand) and W3 (after her comment delete, ⌥⌘Z speaks the comment's refusal, the comment
  stays deleted); ruling 2's real-client check (a claude-code `delete_note` on pane 2's note sends pane 2 to the Library in place; her focus and caret
  stay in pane 1 and her next words land there); U4c's W3 (block 40's ⌘T take, far off-screen, badged at its own first line; the top unchanged).
- **The live round, Terminal — PROVEN:** leg 2c (her Don't allow; the waiting connection still reaches nothing at its timeout), leg 2d (her Allow
  serves the same connection), the tab re-run; U4c's W3 (block 45). **Leg 5 (Codex): N/A** — not installed.
- **Posture: Standard/unlocked, cmp-SAME vs A1, prefs re-exported and diffed (1,580 keys, 0 differ).** Fingerprint **SAME** (`bc64543e2f4e8e58`).
  The `-s local` scratch registrations are **GONE** (`claude mcp get` → "No MCP server named …"; the scratch project's local servers empty); the
  whole-key grep 0; the clipboard empty.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T131848Z`.

**Noticed, not fixed (no product change under the claim):** (1) **for VX-234's wording pass** — the re-bind row's detail reads "…with a setup that
wasn't copied for it, now. It reaches…" while fresh (the ‹age› slot renders "now"; `10`, `13`, `t/01`); (2) **VX-328** seen again — the half-width
Library draws past the divider over pane 1 (`73`); (3) the dev `claude-code` was approved but UNBOUND at the window's start, so leg 1's first copy
proved the BIND arm (P-VX258-2's), and the REPLACE arm was proven at 2b's re-run.

## THE LADDER — ROUND 1 (the Fable cold review, 2026-10-14)

**The reviewer:** `fable-reviewer`, cold, REVIEW_PROMPT verbatim (PHASE=VX-246), zero implementation context.
**What it read itself:** this record whole (4,127 lines); the kickoff plan + the runway's naming (no "Review foci"
section exists in either — checked); CLAUDE.md's loaded canon; `notes/SyncSpec.md` IN FULL (the diff carries two
schema steps); `notes/TEXTKIT2_NOTES.md` whole (the diff carries the editor seam); the whole branch diff
`main...HEAD` (103 files), file by file for every production surface. **What it ran itself:** the targeted headless
pins (89 tests / 19 suites green: the VX-258 tab/wait/impostor suites, VX-259's reach, VX-260's words, the undo-class
pins, the schema pins, the wire suites incl. `MCPPicksPlanTests`, `MCPServerHostReuseTests`,
`MCPReaderAfterCloseTests`), then the WHOLE headless package: **MCP 240/51 · core 2,841/329 · workbook 40/6 — green,
exactly the U1b finals.** Its own path check: zero lines under `Sync/`, custody/Keychain/`Crypto/`, `Server/`
(`git diff --name-only` filter); marker 13 untouched; zero commit trailers on the branch.

### Findings (severity-ranked; `[severity] · file:line · what · evidence · fix`)

- **F-1 [MINOR — MERGE-GATING by the orchestrator's own ruling] ·
  `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift:2554` · the field guide's MCP lesson 2 still
  teaches the pre-VX-258 key rule.** Evidence (doc-truth, traced): the lesson says "…the setup again moves the name
  to the new key…" unqualified, while `MCPSetupKeyRule.decide`'s `.unclaimed` arm now answers `.awaitRebind` for any
  key not copied for an APPROVED name — a reader following lesson 2 with the Any-client tab watches the tool wait
  with no reach, not bind. THE ORCHESTRATOR ON U1b's HAND-BACK already rules tonight's merge must not ship without
  the truth edit; this finding formalizes it into this fix pass. **Fix:** the minimal truth edit (scope the sentence
  to a client's OWN setup; add that an Any-client setup waits for her OK), with `TutorialMCPChapterTests`' lesson
  pin moved with it — the pin red on the unedited tree (the lesson's sentence against the rule as built), green
  after. U8 re-voices the chapter later; this is the truth stopgap.
- **F-2 [NIT] · `Sources/VariorumCore/Operations/Operations+MCPDeliberate.swift:157–159` · stale doc: "HER adopt
  doors keep `restoreChosenPointers`".** False since U2 (THE SWEEP TABLE rows 37–39): her adopt doors now register
  through `registerPointerEntry` and the unconditional helpers (`restoreChosenPointers`, `revertChosenPointers`,
  `adoptUndoHalves`) were deleted. A future reader could re-introduce VX-277's class on this comment's authority.
  Doc edit only; no pin (clarity class).
- **F-3 [NIT] · `Sources/VariorumCore/Operations/Operations+UndoInverses.swift:17` · the header's example names
  `revertChosenPointers`, which no longer exists.** Doc edit only (name `restoreChosenPointersIfUnchanged`, or drop
  the example).
- **F-4 [NIT] · `App/Variorum/VariorumTests/MCPHerEditorDoorTests.swift` (harness) · the door pins raise 4
  unattributed `@Dependency(\.withRandomNumberGenerator) has no test implementation` warnings in every Mac batch**
  (recorded as noise at the U3, U4, U4b and U1b windows — the served socket's side reads the dependency outside the
  pin's `withDependencies` scope). Pin the dependency in the suite's harness so batch triage stays clean. Test-only.

No BLOCKER, no MAJOR. No FINDER-FIXES: every fix is the implementer's (no `Sync/` line; nothing needs the
reviewer's own hands).

### Dispositions on the items this record routed to the Fable review

- **VX-318 "reader past close" — HOLLOW: CONFIRMED.** The ordering was re-traced independently (serve → `run()`
  returns only after the SDK loop ends → the loop ends only on the transport stream's finish → the reader's own
  finish precedes it; `ended` deregisters then closes under the one lock), and the pin's detection power stands on
  its positive control. The pin stays as the ordering's guard.
- **U4c's harness-defect disposition (VX-230's regressed pin) — CONFIRMED.** The probes' two facts (a nested run
  loop runs no main-queue hop; the pin's own report widened the frame) explain the red; the corrected pin asserts
  strictly more (the line, both no-text-change roads, no refresh after adoption), and the live W3 arbiter passed in
  both voices. Right call under the hallucination guard.
- **U3 STAGE RUN's Finding C (the red product's live `delete_block` not stranding) — disposition ACCEPTED.** The
  deterministic pins hold the debounce and carry the mechanism red-on-old/by-revert; the in-session rescue fits the
  VX-184 trace's step 5; the fixed product's live legs stand either way.
- **`add_note_to_book`'s seat residual (sweep row 82) — DISMISSED, not a bug.** The undo's demote-to-arrival
  necessarily unseats; an arrival row carries no member position/section semantics of hers to preserve, and a later
  re-seat lands END-unsectioned by intake's own rule. No pin could show a user-visible loss beyond the act's
  legitimate reversal. Stays recorded, unfixed.
- **The two deliberate behaviour changes (U2 risk 2) — SOUND.** `revertDeleteVariant`/`revertArchiveVariant` quiet
  on a live/active take (the old default-pointer re-assert overwrote what her Put back's own road set);
  `restorePlacementLocation` writing nothing when already there. Each makes the half's answer the truth the stack
  now acts on.
- **Every PROVISIONAL stands as built** (P-VX258-1…8, P-VX260-1/2, P-VX275-1/2, P-VX276-1…4, P-VX277-1):
  each is the defensible pick; P-VX260-2's NULL-means-unproven is the correct strict reading (a backfill would
  bless exactly the class the rule exists to catch); P-VX275-1's every-open-post flush is right (a per-note resolve
  would be a timing oracle before the grant decision).

### The clean bill (checked and found solid, line-level)

- **VX-258:** `MCPSetupKeyRule.decide` verified arm-by-arm against the design table (zero-click only for
  `copiedFor == name` under hash-verified unclaimed standing; unapproved names keep today's arms; `.awaiting`
  re-presentation and other-name refusals exact); the tag authenticated by the whole-key hash, parsed from the
  right past the fixed-length random; `admitMCPConnection`'s awaitRebind claim/replace/log; `allowMCPRebind`
  re-checking approval in-transaction and logging the replaced hash (VX-198's memory via `replacingActs`);
  `declineMCPRebind` forgetting the key (→ the ONE refusal); Deny and the adoption release dropping waits; the
  session's ONE choke point (both handlers; `awaitsHerOK` zero-cost when not waiting, flips once); a waiting
  connection never counted as the name's (`clientName` nil); the no-oracle letter held ("Unknown tool: …"
  byte-identical to `MCPReadTools`'; the pending sentence target-independent; P-VX258-3's malformed-args residual
  stands as recorded); the fingerprint carrying bindings so her Allow re-announces; the face (row, words,
  capabilities, `waitingCount`), the merge-gate pin driving the REAL mint call site.
- **Schema:** v1_28 + v1_29 genuinely LOCAL-ONLY against SyncSpec read in full — own commits ahead of the code, no
  `sync_version`, no outbox trigger, outside the sync registry, export strips the family, marker 13, zero lockstep;
  the FK to `mcp_client` safe (approved clients never cap-pruned).
- **VX-259:** `requireBookNameFree(counting:)` asked only of colliders; the wire's predicate is the listing's own
  rule, non-consuming; her doors nil (E13 whole); no oracle in either direction; the two justified pin edits
  (readable colliders) correct.
- **VX-260:** the digest domain-separated and byte-exact; both add doors write it from the INSERTED row's text;
  `deleteRung` reads `mcpCommentIsOwn`; her edit's forget only when `rewriteComment` wrote; the this-Mac
  forget-vs-digest asymmetry is the safe direction.
- **VX-279:** one per-session lock over `hangUp`/`closeConnection`; deregister-then-close in `ended`; the host-gone
  branch still closes; `stop()`'s snapshot hangUp is a no-op after a close.
- **VX-280:** `picksSQL`'s double `CROSS JOIN` (ids → take by PK → `uq_cblock_ownership`), plan-pinned, refusals
  parity-pinned on the wire.
- **U2:** the stack rule (quiet retires; redo mirror; compound leg states surviving a throwing leg for retry);
  per-parts records spot-checked at the riskiest sites (structural parts + `only`, diverge's `DivergeUndone`,
  conversion's stamp box, span-to-take's two parts, batches' `BatchParts`, pointer entries' slots record,
  minted-container's F1 stamp); the value family's compare-and-set kept; the Mac door's refusal on a quiet press
  (§12's letter); `insuring:` lists preserved exactly (3 sites, same as main).
- **U3:** the hook awaited after parse, before `executor.run`; `flushesHerEditorFirst` exhaustive per family and
  matching the argued act table exactly (lock-only on `lock_take`); `landWireWrite` posting THE ONE road then the
  receipt; the pre-grant flush residual accepted as argued; `renderFull`'s caret landing pure, identity-first,
  computed from the OLD tiling before the rewrite, no attribute stamp, no TK1 (TEXTKIT2_NOTES honored).
- **U4/U4b/U4c + ruling 2:** `refreshBadges`' `.layoutAvailable` gate with no forced layout on either surface (the
  poison rule); the whole-post inline region honest against the 24-pt mount frame; the ONE `remeasure` re-run
  (unconditional, post-walk, dead after uninstall); P1 held (O(fans); the budget pin 4.89 ms); `ShelfViewModel`'s
  single-flight follower on the held snapshot (MainActor-isolated; the P1 witness DEBUG-only);
  `select(_:in:takingFocus:)`'s assert + the `paneShowing` branch unreachable for non-note destinations, the
  focused-subject signal raised only when her subject changed.
- **Process:** red-on-old per member with revert verification recorded per piece; the live rounds' evidence
  consistent with the code as merged; the whole headless package re-run green by this reviewer; no history
  rewrites; no trailers; U5–U8's code confirmed absent from the branch (ruling 3's seam is real).

**Next:** the findings go to the implementer verbatim (the cross-model flow as amended 2026-10-13); its
agree/dispute returns to this reviewer for the final call; the implementer applies the confirmed fixes (F-1 with
its truth pin red-first), the suite green, then round 2 (`opus-reviewer` at max) re-checks them.

### ROUND 1 — THE FINAL CALLS (the Fable reviewer, 2026-10-14; the amended cross-model flow: the implementer applies)

The implementer AGREED on all four findings, disputing none, with refinements on F-1, F-2 and F-3. The reviewer
verified each refinement against the tree at `4e5d2943` (the lesson text at `TutorialSeeder.swift:2552–2557`, the
pin at `TutorialMCPChapterTests.swift:280–281`, `MCPPaneCopy.clientBoundary`'s exact clause, the deleted-helper
greps, and `FractionalIndex.swift:46`'s dependency read on the accept-thread-spawned task). **Every call below is
final; the implementer applies every fix — nothing is FINDER-FIXES, and no `Sync/` line exists.**

- **F-1 — CONFIRMED, the refinement ACCEPTED.** The fix is the implementer's proposed lesson paragraph (L1's exact
  clause, guide register, a literal), the VX-258 line added to the lesson's truth comment, and the pin moved as
  proposed: the `!contains` on the old sentence, the whole-new-sentence `contains`, and the PARITY GUARD — one
  shared test-side `let` holding the clause "Running the client's own setup again moves the name to the new key; a
  setup copied for any MCP client waits for your OK before it takes a name you approved", asserted contained in
  BOTH the guide's lesson text and `MCPPaneCopy.clientBoundary` (verified byte-exact as a substring of the built
  L1). Red-on-old: the pin commit first, the red product showing the three designed lines; then the lesson edit,
  green. The rule-side `decide` arms at `:296–305` stay byte-unchanged. The VX-292 re-check before touching
  `TutorialSeeder` is right (the U1b hand-back read the in-flight table as VX-246 + VX-282 only; re-check at edit
  time). **The residual is accepted as stated** (the other-tab-key wait stays unsaid in the guide — not false; U8
  re-voices). **The `ReleaseNotes-0.9.5.md:9` adjacent is the ORCHESTRATOR'S, not a fix:** the sentence holds on
  the own-tab reading, release notes are hers — route it to the handoff/VX-234 list, no edit.
- **F-2 — CONFIRMED, the widening ACCEPTED** (the last sentence replaced as proposed AND the heading retitled to
  name both families). Doc-only, no pin.
- **F-3 — CONFIRMED, the refinement ACCEPTED:** name `revertChosenPointersIfUnchanged` — the wrapper is the exact
  analogue of the deleted name ("called with the other pre-image"), which is what the header's example illustrates.
  Doc-only, no pin.
- **F-4 — CONFIRMED, the fix shape ACCEPTED** (the hoisted seeded RNG + the `ScopedRandomExecutor` wrapper around
  `executor.run`, the headless `SeededExecutor` precedent; task-locals carry across the runner hop in the same
  task; only the RNG is set so the captured clock/ids stay the harness's). The before/after check (4 warnings → 0,
  the suite alone) is the right evidence for a test-only NIT; any surviving warning gets its read site traced
  before anything else moves.

**The fix pass's order as proposed is accepted** (F-1 pin → lesson edit → F-2/F-3 doc edits → F-4 harness; each
commit naming its member + "Part of VX-246"; headless package green; ONE stage window with the red and fixed
products). **The reviewer's batch recommendation for that window** (the orchestrator names the final list): the
changed source file is `TutorialSeeder.swift`, so the Tutorial* family (U1's G2 set) + `TutorialMCPChapterTests`
alone red/green on the two products, plus `MCPHerEditorDoorTests` for F-4's warning count — the core doc edits
(F-2/F-3) ride the headless package. Round 2 (`opus-reviewer` at max) then re-checks the fixes.
