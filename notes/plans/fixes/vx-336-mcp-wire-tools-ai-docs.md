# VX-336 — Run: MCP wire tools & AI docs (the RUN record)

**STATUS: OPEN — kicked off 2026-10-14 ~13:15 MDT by the orchestrator session vx-336 (Opus 5.5; her launch,
`/architect-phase vx-336`) on the Pro. This file is the live state; read its LIVE STATUS first on any resume.**

**What this run is.** VX-246's follow-on. VX-246 merged the door's FIX units (PR #162, `712bbb4f`); its four other units
(the new wire shapes and the docs that describe them) moved here under its orchestrator's ruling 3, which she RATIFIED
(`notes/QUESTIONS.md` #226: *"that's fine on them moving to 336 I suppose."*). Every member keeps its ruling and ticket.

**The binding sources.** Every implementer reads these in full, in its own context, before touching code:
- **This record:** header, THE UNITS, Hard rules, LIVE STATUS, Stage traffic log, Cross-run coordination, Her rulings,
  ORCHESTRATOR'S PROVISIONAL RULINGS, and its own unit's BRIEF.
- **The plan:** `notes/plans/mcp-pane-and-docs-kickoff.md` in full. It holds the rulings carried from VX-184's
  pre-run sitting (R-VX184-2/3/4), the docs plan (its "U7: the AI's docs" section is this run's U8) and HER ADDITIONS
  (every member's ruling, verbatim).
- **`notes/MCPSpec.md` in full** (the door's authoritative contract; CLAUDE.md requires it before touching the door, its
  tools, the guide's MCP chapter, `MCPSession.instructions`, or any op the wire calls).
- **VX-246's record** `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`: its Hard rules, THE RUN AS IT MERGES, the
  U1/U1b, U2 and U3 UNIT RECORDs (what the door does now: the tab-tied keys, the quiet-half undo rule, the pre-act flush
  and its exhaustive `flushesHerEditorFirst` switch), and the U1b STAGE RUN (the live round's worked form).
- **VX-184's record** `notes/plans/fixes/vx-184-mcp-launch-polish.md` where a member's ruling points there.
- **Each member's Linear ticket** (her rulings verbatim; each brief below restates what binds).

**Coordinates.** Ticket VX-336 (project *13n — The MCP door*). Branch `vx-336-mcp-wire-tools-ai-docs`. Worktree
`~/dev/variorum-vx-336` on the Pro. One PR, `VX-336: …`, merged with a merge commit. Members close one by one as their
fixes land; every commit names its member and `Part of VX-336`. In-flight row on main `ee17a12b`.

## Her kickoff answers (2026-10-14 ~13:20 MDT, through the question tool; recorded as she chose them)

1. **The cast — she chose "VX-246's cast":** *Opus implementers at xhigh, Opus cold reviews at max, and ONE Fable
   review over the whole diff as ladder round 1* (her VX-246 rule: a Fable review when one is needed, else once at
   the end).
2. **The sizing — she chose "As sized":** *U5a → U5b → U6 (+VX-342) → U7 → U8, strictly in order, each with its own
   red-first pins, Mac batch and real-client live round (U5's shared). Then the ladder and the closeout.*
3. **VX-292 — "Not running now":** *U8 proceeds when it's reached. Tell me if you start VX-292 before then, and I'll
   sequence: whichever lands second rebases onto the first.*
4. **Away mode — "Rule provisionally, continue":** *VX-246's overnight shape: product-flavored edges are ruled
   PROVISIONAL, built the most spec-defensible way, and bundled into one QUESTIONS ratify list plus a handoff. I never
   rule on author-only acts (accounts, deleting your things, history rewrites, a synced lockstep). The run continues to
   its merge via the coordinator.*

Her launch line: *"message the oct13coordinator to claim whatever stage you need at any point in time."*

**The cast, as it runs.**
- **Orchestrator:** session vx-336 (Opus 5.5). Holds the architect mandate (`.claude/skills/architect-phase`).
- **Implementers:** `opus-implementer` at `effort: xhigh`, ONE fresh session per unit, strictly sequential; a fresh
  stage runner when a unit's implementer is past ~500k at READY.
- **The ladder:** round 1 = ONE `fable-reviewer` cold review over the whole run's diff, REVIEW_PROMPT verbatim
  (`PHASE=VX-336`), cross-model flow as amended 2026-10-13 (CLAUDE.md "Two reviews"): Fable makes the final call on each
  finding; the OPUS IMPLEMENTER applies the confirmed fixes red-on-old; Fable writes a fix itself only for `Sync/` lines
  (none here) or a finding it marks FINDER-FIXES. Rounds 2–3 = a fresh `opus-reviewer` at `effort: max` each, re-checking
  the fixes; a new BLOCKER/MAJOR earns round 3; hard cap three. A final round's fixes get the orchestrator's
  line-by-line check.

**Members (12, sub-issues of VX-336):** VX-267 · VX-253 · VX-252 · VX-255 · VX-311 · VX-298 · VX-330 · VX-254 · VX-256 ·
VX-261 · VX-197 · VX-342. All pre-launch except VX-342 (a one-word copy fix she added: *"if it's a tiny wording issue you
can add it to the 336 run i suppose."*). VX-330 joined mid-run at her word (Her rulings during the run).

**The gates this run carries.**
- **The stargazing page (R-VX184-4):** a build whose `MCPSession.instructions` carries the link to
  `https://stargazing.tech/variorum/mcp` ships PUBLICLY only after that page is live. U8 adds the link; the closeout
  handoff leads with carrying the brief to her site agent. (Her own `/Applications` refresh is not a public ship.)
- **The instructions bound rises 2,000 → 3,000 (R-VX184-3)** in U8, `MCPSession.instructionsBound` and its pin
  together, and MCPSpec's "≤2,000" moves with it at this run's merge.

## THE UNITS (her "As sized")

No unit is phase-sized (none is a new mode, a token pass, a lockstep event or a posture model); the run sits inside the
guidance. Each unit's evidence is named before its spawn.

| unit | members | the surface | acceptance evidence |
|---|---|---|---|
| **U5a** — the label pair | VX-267 · VX-253 | `aiLabel`'s form; `save_lens` by label (the matcher, `unmatched_blocks`, the ambiguity refusal, `picks` first) | red-first pins per member, red again by revert; the headless package green; the live round is U5b's (shared) |
| **U5b** — the block-writing pair | VX-252 · VX-255 | `create_note`'s answer (take ids, `section_id`), `import_document`'s answer if the same gap; the new `insert_blocks` | red-first pins; headless green; a Mac batch; ONE real-client live round covering U5a and U5b |
| **U6** — Compare from the wire (+ VX-330, VX-342) | VX-311 · VX-298 · VX-330 · VX-342 | `duplicate_note`; `show_in_app`'s Compare target; `link_versions`' Open › opening Compare; the Book Panel's collapsed one-note chapter row wearing both MCP glyphs; the undo warning's one word (Mac + phone) | red-first pins; a Mac batch; a real-client live round; the Compare board AND sherlock's Book Panel walked in BOTH voices |
| **U7** — the agent's read-backs | VX-254 · VX-256 · VX-261 | write-reply digests on EVERY take-writing tool (U5's and U6's new ones included); a compact/paged `read_note`; the client's own recent acts | red-first pins; a Mac batch if app code moves; a real-client live round |
| **U8** — the AI's docs (LAST) | VX-197 | the field guide's MCP chapter; `MCPSession.instructions` (bound 3,000, the link); the tool descriptions; the stargazing brief's delta | the truth pins (`TutorialMCPChapterTests`, the advice's caps); the chapter walked in both voices; a real client reading the instructions |
| **LADDER** | the whole run's diff | R1 Fable (cross-model) → R2/R3 `opus-reviewer` max | — |
| **CLOSEOUT** | — | the merge (serialized through the coordinator), canon deltas, the QUESTIONS bundle, the handoff, the refresh if the coordinator says we're last | — |

## Hard rules binding every unit

- **Zero `Sources/VariorumCore/Sync/`, custody or Keychain lines.** The run is zero-slot (VX-305 holds the slot).
- **Schema is ALLOWED if needed** (her word, 2026-10-13: *"the next MCP fix session can have a schema change event if
  it seems like we need one."*). A LOCAL-ONLY change rides the grants family's road (`Persistence/MCPGrantSchema.swift`
  + `Migrations.swift`, its own commit ahead of the code, no `sync_version`, no trigger, stripped by the export, marker
  13 untouched). A SYNCED change is a SyncSpec §12 lockstep event: STOP and report before writing it. Read
  `notes/SyncSpec.md` in full BEFORE any schema commit. No unit is expected to need one.
- **The editor seam** (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, `PaneTextAuthority`, the decoration layer,
  `Shared/EditorBrain`) is NOT expected anywhere in this run. If a trace reaches it: STOP and report (it changes the
  review's cast and needs `notes/TEXTKIT2_NOTES.md` first).
- **Every new or changed wire act answers the two questions the compiler asks** (VX-246 U2/U3): whether it meets her
  text (`flushesHerEditorFirst`, the exhaustive switch per job family — argue each answer in the record), and, for every
  undo half it registers, whether that half changed anything (U2's `Bool`; §9's quiet-half rule).
- **The fence and the one not-shared shape stand:** an unreachable note/book/take answers the ONE byte-identical
  not-shared shape; no new tool or field may tell hidden from missing. Private, Seal and Own stay hers alone.
- **P1:** every new read or answer costs ∝ what it names or returns (the note's blocks, the page, the write), never the
  corpus.
- **Lanes.** VX-281 has MERGED, so its files (`Features/MCP/MCPPane*.swift`, `MCPPaneCopy.swift`, `MCPGrantSheet.swift`,
  `MCPSetupMenu.swift`, the shared icon) are no longer another run's lane: Activity words for a new act may be written
  in `MCPPaneCopy.swift` directly. Every user-facing word ships AS BUILT and goes on the unit record's **FOR VX-234**
  list (her pane-wording review); pure pane wording never goes to QUESTIONS. No other live run shares these files
  (VX-305 is `Protection/` only; VX-283/VX-284 are not started).
- **`TutorialSeeder`** (U8 only): never while VX-292 runs (her answer: not running now; the orchestrator re-checks
  before U8 spawns).
- **The stage.** Every `xcodebuild test`, walk, live round, Debug launch and dev-store reset goes through the
  orchestrator to the stage coordinator (session **oct13coordinator**): REQUEST (what, minutes, claim name) → READY
  (built, able to start NOW) → GO (only from the coordinator, carrying the exact claim line `Tools/stage release --who
  coord-for-vx336 && Tools/stage claim --who <name> …`) → RELEASE (released, then one result line: dev store restored?
  MCP registrations fingerprint same?). Implementers NEVER message the coordinator: they write THE STAGE WINDOW plan
  into their unit record, report READY and end their turn; the orchestrator resumes them with the GO. Headless
  `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` need no stage. A FREE stage is never an
  invitation.
- **Live-round machinery (the coordinator's facts, 2026-10-14 13:22, plus VX-246's):**
  - Instance guard: the STRICT forms `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`. The loose
    `-f "Variorum.app/Contents/MacOS"` matches headless xcodebuild command lines.
  - `Tools/stage status` exits 1 while a claim is held: never in an `&&` chain.
  - Dismiss the What's New sheet after each Debug launch with its own button (until VX-237).
  - Restoring Debug prefs: `defaults import` MERGES — re-export after the import and diff against the pre-window export.
  - The dev store is Standard/unlocked. Its `Backups/safety-copies/` holds `castle-W1-20261013`, her undispositioned W-1
    repro: LEAVE IT ALONE. Any Castle/credential step uses `~/.variorum/dev-castle.env` exactly (source it; never invent
    values, never write them anywhere).
  - A window of an hour or more: run the tests first and ping **SEAM** (through the orchestrator) before taking the
    dev-store A1 copy, so a merge-gating run can slot in.
  - **The Castle heads-up:** once VX-306 (Castle phase 2) merges and migrates the dev store, a Debug build from a branch
    cut before it can't open the dev store. Merge main before any live round after that point (the coordinator asks at
    the GO).
  - **The DEV store only**, behind an A1 prestage copy that is restored and verified (cmp). Never her real store, never
    `/Applications/Variorum.app`, never her USER-scope MCP registrations: a copied setup line (`claude mcp remove -s
    user …; claude mcp add -s user …`) is never run as copied — only its key is taken and registered `-s local` in a
    scratch project (or a scratch `--mcp-config` JSON). Fingerprint her user-scope servers before and after.
  - **Connecting a real client** (since VX-258): a setup key copied from the Claude Code tab carries the client's name
    and, under an APPROVED name, binds with zero clicks; an unknown name arrives as a connection request in Waiting
    (approve it there). The U1b STAGE RUN in VX-246's record is the worked form (legs 0–1).
  - Blocked by a state another session made: ask the orchestrator. Never discard or reset a store to get past it.
  - Walk clearance: she's off the Pro for the whole day 2026-10-14 (her word 13:15, relayed). That does not carry into
    a new day. An undismissable system popup is reported word for word.
- **Commits** name the member and `Part of VX-336`, with NO attribution trailers (CLAUDE.md overrides the harness
  reminder), and push after every commit (`git pull --rebase` first). `notes/SessionResiliencyProtocol.md` binds: a
  LIVE STATUS from the first commit, records before final verification (claims PENDING until read from a log),
  synchronous foreground waits only (poll the log; never end a turn to wait), never spawn subagents.
- **Pin before fix, PER MEMBER, red on the old tree.** A pure addition (a new parameter, field or tool) is red by its
  absence on the old tree. Verify by revert: announce the revert in the record first, commit before reverting, run it,
  restore, verify the restore. A pin green on both sides exposes the row as hollow; record it, don't fix it.
- **Every PROVISIONAL** lands in the unit record with its options; the orchestrator files `notes/QUESTIONS.md` at the
  merge (the next free number). Design forks the briefs reserve ("argue which") are proposed by the implementer and
  RULED by the orchestrator before that half is built (the architect-phase "implementer proposes, architect rules").
- **Disk.** Build into `App/Variorum/DerivedData/vx336-<unit>` (gitignored); check free space before a Mac build.
- **Context:** past ~500k, stop at the next clean seam (committed, green, the continuation written in the record) and
  report.
- **Never run `claude mcp list` in a window** (U6's runner slip, 2026-10-14): its health check SPAWNS every user-scope
  server, her `variorum` shim included. With her real app running, that would present her real setup key to her real
  store. Use only the fingerprint one-liner (names + hash, never values) and `claude -p --strict-mcp-config` with the
  scratch config.
- **Labeling (CLAUDE.md since `ebd16909`, her triage sitting 2026-10-14):** every ticket this run files gets ONE kind,
  an Evidence label on Bug/Improvement/Debt, ONE Area, a Priority; Pre-launch only at her call; **never an assignee**.
  Riders: the open Low/Medium tickets in the run's Areas were offered to her mid-run (the MCP area, 2026-10-14 ~17:45),
  awaiting her pick.
- **Tickets this run FILES are triaged before it closes** (her word 2026-10-14, now CLAUDE.md's closeout ritual): a kind
  label (Bug / Improvement / Feature / Debt), exactly one Evidence label (Confirmed · Suspected · Test-only), a Priority
  (Linear's field), Pre-launch if it gates launch, Wording for text-only fixes, and "Needs Lillian" if it waits on her.
  A unit that mints a ticket proposes those fields in its record's OWED.

## LIVE STATUS (orchestrator — flipped as units land)

| unit | status |
|---|---|
| U5a — the label pair | **PROVEN 2026-10-14 15:13–15:50** (U5 STAGE RUN): legs A–D all passed in a real Claude Code 2.1.300 round on the dev store — the new `claude-code · english` label on Takes cards in both voices, `save_lens` by label refusing the ambiguous block and its `take_ids` retry, the legacy form matched as its own, `pin_chosen` holding. Built at `590c0cb8` (U5a UNIT RECORD) |
| U5b — the block-writing pair | **PROVEN 2026-10-14 15:13–15:50** (U5 STAGE RUN): the 31-suite Mac batch green (251 tests, 0 failed, 7 gated skips); V252-a (create_note's `blocks` = read_note's records; filed under its chapter), V255-a/b/c (the end at write new with her ⌥⌘Z/⇧⌥⌘Z; any anchor at write new hears the rung sentence and asks her; anywhere at edit), D8-a passed; D8-b's open tail is unreachable from the keyboard (THE ORCHESTRATOR ON U5's WINDOW). The store was restored cmp-SAME. Built `7a15376c`…`93edbc2e` (U5b UNIT RECORD, three sessions) |
| U6 — Compare from the wire (+ VX-330, VX-342) | **PROVEN 2026-10-14 17:52–18:35** (U6 STAGE RUN). The 125-suite batch: 790 tests, 786 passed, 2 gated skips, 2 standing reds (VX-115, VX-167; neither on U6's paths). Every red run exact: U6a's router clears (9 pairs), U6b Mac (15), the phone (4), the phone green 18/3. The live round passed in both voices: L0–L5 (`duplicate_note` with her ⌥⌘Z/⇧⌥⌘Z, the AI's edit on the copy, Compare aligned on lineage with related-only on, an unrelated pair with it off, `link_versions`' Open › opening Compare, not-frontmost moving nothing); VX-330's walk (all twelve of sherlock's collapsed chapter rows wear the shared icon, the waiting mark on one, pressed, Don't allow clearing it); VX-342's "before" seen. The store was restored cmp-SAME. Built: U6a `2836171c`…`48e250e0`, U6b `12efb039`…`a1a094dc` |
| U7 — the agent's read-backs | **PROVEN 2026-10-14 20:44–21:12 EXCEPT THE CAP** (U7 STAGE RUN). Batch 176/173, 0 failed. L1 (15/15 digests equal from the wire), L2a (6 inline pages of 50 = block_count 300), L3 (ids_only at limit 100, 300/300 equal), L4 (a killed create, found by `list_my_activity`), L5 (a refused row title-less; reads only with `include_reads`) all PROVEN. **THE CAP FAILED:** a budget-ended page (32,000 characters of take text, about 65k answer) spills past Claude Code 2.1.300's inline limit, which sits between 43,062 (inline) and 50,984 characters (spilled); `ids_only` at limit 200 spills too. → **U7c**, the cap fix (THE ORCHESTRATOR ON U7's WINDOW) · **U7c BUILT** (`0b1be274`…`12df7a8c`): the page budget bounds the whole serialized answer at 32,000 characters (UTF-16 units); 8 pins red on old, 3 of builder B's re-pinned; revert check in 4 arms; MCP 329/66 · core 2,871/333 · workbook 40/6; the orchestrator re-ran the paging suites, 25 green. Its RE-PROBE rides U8b's window |
| U8 — the AI's docs (LAST) | **PROVEN 2026-10-14 23:07–23:33** (U8 STAGE RUN). 66-suite batch 432/429, 0 failed; the red run exact on the old seed; Restore Tutorial minted a fresh guide (the old one in the Trash with 30 days); the chapter walked word for word in Study and Terminal; the instructions read from bytes at 2,969 with the link last; **U7c's RE-PROBE: all three pages INLINE** (71 blocks / 31,825 · the same · ids_only 115 / 31,751). The organization ask did the advice unprompted (a book with a tag rule + outflow, a summary note filed) but met two pre-existing wire truths → **U9** (VX-361, VX-362) |
| U9 — wire truths from U8's round | **PROVEN 2026-10-15 00:57–01:12** (U9 STAGE RUN). 121-suite Mac batch 771/765, 0 failed; the Mac red exact (20 issues, the ten R/E cases); the phone red exact (5) and green 120/15 on one simulator; the real-client turn 6/6 from the bytes (VX-361: `tag_ids`/`tags` carry the outflow tag; VX-362: `apply_tag` → `changed:false`, the add refused in words; the import's collision gone; no `Refused:`/Swift case anywhere); the faces in both voices. Built `4ff629ad`…`e454a8ef` (U9 UNIT RECORD) |
| LADDER | **ROUND 1 DONE** (Fable xhigh, 2026-10-15 ~01:30): 0 BLOCKER · 1 MAJOR (R1-1, U9's pending evidence — closed by U9's window) · 2 MINOR · 2 NIT; no code fix (THE LADDER — ROUND 1 below). ROUND 2 (a fresh Fable xhigh) runs after the closeout's in-branch canon |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- *(Newest first from here.)*
- 2026-10-15 01:12:51: **RELEASE `vx336-u9`** (15 of 75 min); every leg passed; the restore line as U5–U8's; the A1
  `scale-prestage-20261015T070459Z` is the coordinator's to prune. 00:57: **GO** (`Tools/stage release --who coord-for-vx336 &&
  Tools/stage claim --who vx336-u9 --reason "VX-336 U9: 121-suite Mac batch + Mac red + one-sim phone red/green, SEAM, A1 +
  real-client turn + faces both voices on the Debug dev store" --minutes 75`), SEAM "continue" pre-given.
- 2026-10-15 ~00:55: **the stargazing page went LIVE** (the orchestrator, at her word): site commit `2896a7f` (pushed), `npm run
  deploy`; `https://stargazing.tech/variorum/mcp` → 307 → `/variorum/mcp/` → 200 (the same trailing-slash redirect `/variorum`
  uses). The coordinator was told before the deploy and at 200; its release-GO check is the URL answering 200 (cache-busted, -L).
- **The coordinator's overnight rulings (2026-10-15 ~00:45):** (1) the release GO probes the page for 200 (met); (2) the last
  merger's release window ends with the `/Applications` refresh under the full rule card (A1 of her real store + key files,
  zero-instance checks that ABORT, stage beside, codesign, swap, verify; nothing launched, no real-store MCP calls, no re-seed;
  install the build the website serves); (3) a MAIN FREEZE from the version-bump commit until release.sh has stamped; (4) the
  stray `~/dev/variorum/default.profraw` is moved aside (never deleted) before release.sh's clean-tree preflight; (5) the
  notes are written one bullet per line (VX-343's parser trap).
- 2026-10-14 23:33:52: **RELEASE `vx336-u8`** (26 of 100 min). Result line to the coordinator: the re-probe INLINE ×3; batch
  432/429, 0 failed; the red run exact; dev store cmp-SAME vs A1; prefs 0 differ; fingerprint same; clipboard
  restored; Standard/unlocked; castle-W1 untouched. The A1 `scale-prestage-20261015T051427Z` is the coordinator's to
  prune.
- 23:07: **GO for `vx336-u8`** (`Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u8 --reason
  "VX-336 U8: 66-suite batch + red, SEAM, then A1 + guide MCP chapter walk (Study, Terminal) + real-client round +
  read_note re-probes on the Debug dev store" --minutes 100`); the coordinator PRE-GAVE "continue" at the SEAM, so the
  window ran whole. vx-283's walk followed.
- ~23:00: REQUEST then READY for `vx336-u8` (queued behind `vx283-u1c`/`u1c2`).
- 2026-10-14 21:12:37: **RELEASE `vx336-u7`** (28 of 95 min). Result line to the coordinator: batch 176/173, 0 failed; dev store
  cmp-SAME vs A1; prefs 0 differ; fingerprint same; Standard/unlocked; castle-W1 untouched. The ScaleFixture A1
  `scale-prestage-20261015T024700Z` is the coordinator's to prune. The cap finding is ours, and its re-probe rides U8's window.
- ~20:47: SEAM (the batch green); "continue" (vx-283's re-test not READY).
- 20:43: **GO for `vx336-u7`** (`Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u7 --reason
  "VX-336 U7: 21-suite Mac batch, SEAM, then ScaleFixture A1 + real-client MCP live round on the Debug dev store"
  --minutes 95`), run at 20:44:51, after U8a PAUSED clean at `f420f52e`.
- ~20:30: REQUEST then READY for `vx336-u7` (queued behind `vx283-u1-walk`, which released at 20:41 with the store
  verified).
- 2026-10-14 18:35:06: **RELEASE `vx336-u6`** (42 of 130 min). Result line to the coordinator: batch 790/786 (2
  standing reds, 2 gated skips); the red runs exact; dev store cmp-SAME vs A1; prefs 0 differ (1,602 keys); fingerprint same; 0
  sims booted; Standard/unlocked; castle-W1 untouched. The A1 copy `scale-prestage-20261015T000711Z` is the
  coordinator's to prune. The `claude mcp list` slip was reported (nothing changed).
- ~18:10: SEAM (the batch and reds done, the simulator shut, the red products deleted); "continue".
- 17:52: **GO for `vx336-u6`** (`Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u6 --reason
  "VX-336 U6: 125-suite Mac batch + reds (one sim), SEAM, then real-client MCP live round + Compare/Book Panel walk on
  the Debug dev store (A1 prestage)" --minutes 130`), run at 17:52:45.
- ~17:50: REQUEST, then READY for `vx336-u6` (first in the queue; vx-283 waits on her ⇧⌘W ruling).
- 2026-10-14 15:49:56: **RELEASE `vx336-u5`** (37 of 110 min). Result line to the coordinator: batch green (251 / 31, 0 failed); dev store
  cmp-SAME vs A1; prefs 0 differ (1,596 keys); user-scope fingerprint same (`bc64543e2f4e8e58`, no `-s local` ever
  made); posture Standard/unlocked; castle-W1 untouched. The A1 copy `scale-prestage-20261014T211517Z` is the
  coordinator's to prune.
- ~15:15: **SEAM** (the batch green); the coordinator answered "continue" (nobody else READY; vx-283 waits on her ruling).
- 15:12: **GO for `vx336-u5`**, carrying `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u5
  --reason "VX-336 U5: 31-suite Mac batch, SEAM, then real-client MCP live round on the Debug dev store (A1 prestage)"
  --minutes 110`. The coordinator's pre-checks: no instances, no booted sims, 68 GiB free, the dev store restored and
  verified after vx-283's 15:03–15:06 window, Standard/unlocked. Run at 15:13:00.
- ~15:10: READY sent (the fresh stage runner read in, the product matched `c9c7f637`).
- 2026-10-14 ~14:05: REQUEST `vx336-u5` (~60–75 min: the batch, SEAM, then the live round) sent early; the coordinator
  queued it. Ahead of it in READY order: vx-283's `vx283-u1` (~35 min batch), then `vx283-u1-walk` (~45 min). We may get
  the gap between them. A short window slots in only at our SEAM, never mid-round. At the GO it checks the dev store
  was left restored and unlocked.
- 2026-10-14 ~13:22: the kickoff announcement went to oct13coordinator; it answered: in the queue, zero-slot recorded,
  the queue empty, ask early. Its protocol and live-round facts are in Hard rules above. Main had moved to `8a0b766f`
  (PR #164, notes/.claude only) — already on this branch. Merges serialize through it (at the merge ask it checks
  `--is-ancestor` of origin/main, MERGEABLE CLEAN, the only open PR, and the non-notes diff since the tested tree); the
  burst's last merger does the `/Applications` refresh, decided at the merge.

## Cross-run coordination

- **VX-305** (Castle phase 1, `~/dev/variorum-vx-305`): holds the ONE `Sync/`-or-custody slot; `Protection/` only,
  headless. No overlap. **VX-306** (Castle phase 2) migrates the dev store when it merges: merge main before any live
  round after that (Hard rules).
- **VX-292** (her tutorial/onboarding session): NOT running (her kickoff answer 3). U8 re-checks before it spawns;
  whichever lands second rebases onto the first.
- **VX-234** (her Settings wording review, MCP included): every unit's FOR VX-234 list is posted there at the closeout.
- **VX-283** (Sidebar & Library polish, `~/dev/variorum-vx-283`, branch `vx-283-sidebar-library-polish`) is LIVE since
  2026-10-14. Its surfaces: `SidebarView`, `SidebarLayout`, `WorkspaceModel`, a Close Note act (the registry and
  `EditorCommands`), the toasts, the Library's controls row, six `.fixedSize()` sites. **Overlap:** U6's VX-342 edits
  `Registry/ShellActions.swift`, and U6's Compare target may reach `WorkspaceModel`/`ShellRouter`. Before U6 edits any
  of those, the orchestrator messages vx-283; whoever merges second merges main in first. It also shares the
  navigate-away road (`.variorumNotesDeleted`), where this run adds no second road.
  - **Told and answered (2026-10-14):** the orchestrator sent three notices (U6a's one `CommandRouter` property, its
    three clears, U6b's one `ShellActions` word). vx-283's reply: *no real collision.* Its U1 adds ~4 lines to
    `CommandRouter.swift` (a `focusedPaneShowsNote` context fact, in the context-facts area), `.closeNote` /
    `.closeAllNotes` in `Capability.swift` / `CapabilityRegistry.swift`, and View-menu items in `EditorCommands.swift`.
    It doesn't touch `ShellActions`, `ShellRouter` or the navigate-away road, and the VX-342 word is fine. Whoever merges
    second merges main in first.
- **VX-284**: not started.

## Her rulings during the run (verbatim; each also on its ticket)

- **THE STARGAZING PAGE IS OURS TO PUBLISH (2026-10-15 ~00:15 MDT, in chat), verbatim:** *"honestly - just go ahead and do the
  stargazing MCP link yourself. the stargazing agent doesn't have to do that part, you can do that part rather than the
  brief"*.
  - This run builds and DEPLOYS the page `https://stargazing.tech/variorum/mcp` itself, in the site repo
    (`~/dev/stargazing.tech/stargazing-tech`), from the brief's content (`notes/stargazing-mcp-guide-brief-2026-10-12.md`).
  - The site repo's own CLAUDE.md binds there: its subagent policy, the matte style, `COMPLETED.md` and `DECISIONS.md`
    kept current, and its hard rule that published prose is hers. The page therefore carries the site's PLACEHOLDER marker
    noting it was drafted at her word, and is listed in PLAN.md's content-owed section.
  - The page goes live BEFORE any build carrying the instructions' link ships, so R-VX184-4 is met by the page existing.
  - **Ruling 3's gating is SUPERSEDED:** the link sentence stays in `MCPSession.instructions`.
- **HER OVERNIGHT WORD (2026-10-15 ~00:05 MDT, in chat), verbatim:** *"I am going to sleep, rule provisionally overnight in
  my absence and leave me a handoff in the morning. you or 283 can merge last, whoever does should have a release build
  ready, write notes on what was updated (I don't have to review those notes, it's fine), and push a release to the
  website so I can try the new things out tomorrow morning."*
  - The run continues through the night: U9, the ladder, the closeout and the merge, ruling provisionally where she would
    rule. It never rules on the author-only irreversible list (her accounts or credentials, deleting her things, history
    rewrites, a synced lockstep deploy).
  - **Whoever merges LAST tonight (VX-336 or VX-283; the coordinator decides) cuts the release:**
    - the release notes, written by that session; her review is waived for this release ("I don't have to review those
      notes, it's fine"), the named exception to her standing notes rule;
    - the MARKETING_VERSION bump;
    - `Tools/Release/release.sh`;
    - the site road to stargazing.tech;
    - the `/Applications` refresh, so her Mac has it in the morning.
  - A handoff for the morning.
- **THE LADDER'S CAST (2026-10-14 ~19:55 MDT, in chat), verbatim:** *"you can use fable xhigh to review instead of opus
  at max"*. Every ladder round is a FRESH `fable-reviewer` at effort xhigh (REVIEW_PROMPT verbatim, PHASE=VX-336),
  replacing the kickoff's Opus rounds 2–3, under the cross-model flow each round: Fable's final call, the Opus implementer
  applies the fixes red-on-old, the next fresh Fable round re-checks them, and the final round's fixes get the
  orchestrator's line-by-line check. Also in the plan's Rules (`4915493b`).
- **VX-330 JOINS (2026-10-14 ~13:45 MDT, in chat), verbatim:** *"I want you to add VX-330 to somewhere in the run - you
  can choose where it would slot in best. It's an issue where combined chapter / note headings don't show any AI symbol
  but that's how the example sherlock holmes looks and i think people might share that book with AI as an example so i
  want it fixed pre launch."* Promoted to Pre-launch, parented under VX-336. **Slotted into U6** (the orchestrator, at
  her delegation): U6 is the first unit with app-side code and a both-voices walk with a real client connected, and it
  lands before U8, so the guide's shared-icon sentence describes the panel as fixed. Also in the plan's HER ADDITIONS
  (`d7edfea1`).

## ORCHESTRATOR'S PROVISIONAL RULINGS (her away-mode delegation, kickoff answer 4 — each for her ratification)

1. **U9 joins the run (2026-10-14 ~23:40):** two wire truths that U8's real-client organization round met, VX-361 and
   VX-362, are fixed in THIS run before the ladder, as sub-issues. Both predate this run, but both sit on the answers
   and refusals this run reshaped (VX-252's answer; the wire every new tool speaks through). A fix is cheapest while
   that code is open (her rider rule), and the ladder then reviews it with the rest. Option: (b) ticket them for
   later and merge without them.
2. **VX-363 joins U9 (2026-10-14 ~23:58):** U9's design traced a FENCE LEAK. `import_document`'s book form checks the
   name against every live book, so a book the client can't read blocks the name and is named back (VX-259 missed this
   road). It is the same class VX-246 fixed, on a road this run's tools speak through, and a fence breach is a launch
   matter, so it is fixed in-run, red-first. Pre-launch is HER call on the ticket (High, flagged). Option: (b) ticket
   it for later.
3. ~~**The stargazing gate vs tonight's release (2026-10-15 ~00:05).**~~ **SUPERSEDED ~00:15 by her word** (Her rulings during the run: the stargazing page is ours to publish). The page goes live before the release, and the link stays. Kept for the record:
   - **The conflict:** her overnight word asks for a public release to the website. Her standing gate R-VX184-4 says *a
     build carrying the instructions' link to `https://stargazing.tech/variorum/mcp` must not ship before the page is
     live*, and the page answered **404** at 00:05 (checked by the orchestrator).
   - **Ruled:** the release ships, and `MCPSession.instructions` OMITS the one link sentence until the page is live.
     - Nothing else changes: the instructions' other words, the guide, the descriptions.
     - The sentence returns in a one-line change the moment her site agent publishes the page, under a ticket and the
       handoff's lead item.
     - The pins move with it: the link sentence stays pinned as a constant, gated OFF.
   - **Why:** both of her words hold at once. The release she asked for ships, and the gate she ruled is not broken.
   - **Option:** (b) ship with the link; until the page is live an AI reading it meets a dead link (a breach of
     R-VX184-4). Hers to choose in the morning.


## Tickets minted from this run

| ticket | born | what | fate |
|---|---|---|---|
| (VX-122) | U7 STAGE RUN noticed 1 | NOT minted: a comment on VX-122 (Parked, a live Library misses revivals). An open Library list didn't show two wire-made notes until re-entered; it may be the same class (outside inserts) | a comment; split off if VX-122's fix doesn't cover it |
| VX-361 | U8 STAGE RUN, the organization leg (F1) | `create_note`'s answer says `tag_ids: []` when the book's outflow tags the note in the same act | a MEMBER (sub-issue), U9; Bug · Confirmed · MCP · Medium |
| VX-362 | U8 STAGE RUN, the organization leg (F2) | An unworded refusal reaches the wire as a raw Swift case (`Refused: alreadyTagged(...)`) | a MEMBER (sub-issue), U9; Bug · Confirmed · MCP · Medium |
| VX-363 | U9's design (OWED 1) | `import_document`'s book form checks the name against every book, naming one the client can't read (VX-259 missed this road) — a fence leak | a MEMBER (sub-issue), U9; Bug · Suspected (until pinned) · MCP · High; Pre-launch her call |
| VX-364 | U9's design (OWED 2) | A book whose wing pointer dangles refuses any outflow with `tagNotFound` (`set_book_rule` and her Save) | Todo, 13n, Bug · Suspected · Books · Low; not this run's |
| VX-365 | U9's design (OWED 4) | `add_note_to_book`'s answer doesn't say the outflow tagged the note (VX-361's class, kept out of scope) | Todo, 13n, Improvement · Suspected · MCP · Low |
| VX-366 | the closeout's rulings reconciled (D6 row 11) | `divide_block`, `merge_blocks`, `save_version` and the book import answer no `sha256` (P-VX254-1/2's remainder if she reverses them) | Needs Lillian, 13n, Improvement · Confirmed · MCP · Low |
| VX-367 | D6 row 14 | the guide's lesson 3 names the remaining edit acts one by one | Todo, 13n, Improvement · Confirmed · MCP · Wording · Low |
| VX-368 | D6 row 15 | an MCP parity audit against R-VX184-1 (move span, tag rename, extract, copy-takes divide, word targets) | Todo, 13n, Improvement · Confirmed · MCP · Low; Pre-launch her call |
| VX-369 | D6 row 16 | errors other than `OperationError` may still reach the wire as raw text | Todo, 13n, Improvement · Suspected · MCP · Low |
| VX-370 | D6 row 12 | measure another MCP client's output cap against the 32,000 page bound | Todo, 13n, Exploration · MCP · Low |
| VX-357 | U7 builder A's U+0000 check | Text containing U+0000 is stored truncated at the NUL (GRDB binds text with length -1); VX-254's digest overclaims for such a take | Todo, 13n, Bug · Confirmed · MCP · Medium; Pre-launch is her call; pinned as a known issue |
| VX-358 | U7 builder A's OWED 3 | `edit_take` / `restore_commit` treat an NFC↔NFD re-spelling as no change, so the digest differs from what the client sent | Todo, 13n, Improvement · Suspected · MCP · Low |
| VX-355 | U6 STAGE RUN (the runner's note 2) | The Pool has no bottom bar, so receipts (an AI's, her undo's) show nowhere while it's open | Todo, 13n, Improvement · Confirmed · Library & sidebar · Low |
| VX-356 | U6 STAGE RUN (the runner's note 4) | Book Panel in Study: the open note's collapsed chapter row shows no open-note marker (Terminal shows "›") | Todo, 13n, Improvement · Suspected · Books · Low |
| VX-354 | U6b's sweep (OWED 2) | Book Panel: the header's book name and its gatherings names wear neither MCP glyph (outside VX-268's parity and VX-330) | Todo, 13n, Improvement · Confirmed · MCP · Low; Pre-launch is her call |
| VM-20 | U6b (OWED 5) | The phone's undo warning says "It is saved first" where the Mac says "committed" — the commit vocabulary (R-13s-31/32) looks missed there | VM Backlog, Improvement · Confirmed · Wording · Low |
| VX-353 | U6a's build (the implementer, 2026-10-14) | `MCPHarnessTimeLimitTests`' never-answers-initialize pin overruns its 15 s bound under heavy machine load (16.3–16.7 s at load 9–67; green alone) | Todo, 13n, Debt · Test-only · Low; not pre-launch; not this run's |
| VX-352 | U5 STAGE RUN step 12 (the runner's note 2) | Takes card header tail-truncates an AI take's label to "claude-code · e…" in Terminal at the margin-grid card width | Todo, 13n, Improvement · Confirmed · Low; not pre-launch; FOR VX-234's eye too |

## UNIT BRIEFS (the orchestrator's; each unit's implementer is spawned from its brief)

*(Re-aimed 2026-10-14 from VX-246's drafted U5–U7 BRIEFS against main at `074c0f94`: claim names `vx336-*`; VX-281's
lane is merged, so Activity words may be written directly; the client connects by VX-258's tab key, no detour; ruling 2
is DONE (VX-246 U4b). Line numbers quoted from tickets are drafting-time; re-read the code.)*

### U5a BRIEF — the label pair (VX-267 · VX-253)

**Order:** VX-267 first (VX-253's matcher needs its form), then VX-253. Both are ruled; each ticket is the record.

1. **VX-267: AI take labels drop "suggested".**
   - **HER RULING, verbatim:** *"why do we need claude-code \* suggested \* english. isn't it obvious it's suggested if
     it's claude? seems like an extra word."*
   - Since her label-split ruling (VX-197: *"it would be a mess to have claude code suggested english on every label if
     you're having claude make a ton of htem."*), the client prefix appears only on takes an AI adds at SUGGEST, inside
     her writing (`add_take`, `add_takes` — `MCPWriteTools.aiLabel(client:own:)`, `MCPWriteTools.swift` ~l.752, its two
     call sites `MCPWriteTools.swift` ~l.361 and `+Batches.swift` ~l.147); at WRITE NEW and EDIT labels are stored
     exactly as given (`create_note`, `import_document`, `set_take_label` — P-VX195-5).
   - `aiLabel` (13n's P-13n-3 convention, hers to re-voice) becomes `<client>` or `<client> · <label>`.
   - Existing takes keep their labels: labels are text, so no migration. `aiLabel`'s tests are re-pinned.
   - **Truth:** any tool description, `MCPSession.instructions` line or guide sentence that states the OLD form is now
     false; correct it in this unit (doc-truth, minimal). U8 re-voices the docs later.
   - Pre-launch: settle the convention before public users create takes in the old form.
2. **VX-253: `save_lens` by take label.** RULED, her word: *"I like your 253 recommendation"*, with her clarification:
   - **Three explicit fills, never a magic word:** `picks`, `label`, or `pin_chosen: true`. `picks` ride on either
     rule as per-block overrides, applied FIRST, so a block a pick covers is never ambiguous.
   - **A block with no take of that label** shows its chosen take and is listed in `unmatched_blocks`.
   - **An AMBIGUOUS block** (two takes matching that label) that no pick covers refuses the WHOLE call, naming those
     blocks. The retry passes the same rule plus `picks` for exactly those blocks, or the first call does when the agent
     already knows.
   - **Labels match exactly as stored,** plus one convenience: a client's OWN suggestions match by their own part. Per
     VX-267 the stored form is `<client> · <label>`, and the legacy `<client> · suggested · <label>` matches too. Never
     another client's. Her "english" plus the AI's suggested "english" on one block counts as two matches, so the call
     refuses.
   - `save_lens` stays at SUGGEST. Its cost is ∝ the note's blocks (the lens names one take per block). VX-280 (VX-246
     U1) fixed `save_lens`' picks read to P1 — build on it, never around it.
   - Argue in the record: what `pin_chosen: true` means exactly (today's lens semantics for a block with no pick), how a
     malformed combination refuses (e.g. `label` and `pin_chosen` together), and the answer's shape (`unmatched_blocks`
     ids; the refusal's block ids) — none may name a take or block the client can't read.

**Lanes and words.** Tool descriptions live in `Sources/VariorumMCP` (ours). Activity words, if a new phrasing is
needed, go in `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift` (VX-281 merged). Every user-facing word ships as
built and goes on the unit record's FOR VX-234 list.

**Evidence that closes U5a.** Pins red-first per member and red again by revert (a pure addition is red by its absence);
the whole headless package green with counts (`swift test` — MCP, core and workbook targets as VX-246 counted them); a
Mac `build-for-testing` (no stage) if any app file moved. **No stage window of its own:** U5a's live legs (the new label
seen in Takes; `save_lens` by label meeting an ambiguous block, then its `picks` retry; an own-suggestion legacy match)
are written into the record as LIVE LEGS FOR U5b's WINDOW, with exact `claude -p` turns.

**Out of scope:** U5b's members (VX-252, VX-255) and every later unit; the guide and `MCPSession.instructions` beyond
doc-truth (U8).

### U5b BRIEF — the block-writing pair (VX-252 · VX-255), plus U5's shared window

**Order:** VX-252 first (its answer shape is what `insert_blocks` and U6's `duplicate_note` reuse), then VX-255.

1. **VX-252: `create_note` returns take ids, and accepts `section_id`.**
   - Per block, it answers the shown take's id plus each extra take's id and label, in order. This matches `add_take`,
     which already returns `take_id`. (Cost today: a full `read_note with_ids` per note just to learn ids the write
     itself minted — 25 reads, ~2.7M chars in her bilingual-book run.)
   - An optional `section_id` files the note in a chapter in the same call. Argue its rung and its refusals: the chapter
     must belong to the book the note joins (and be live, in a book that accepts it — the §9 gate); a section in a book
     the client can't read answers the one not-shared shape.
   - Check `import_document`'s answer for the same gap, and close it the same way if it is real.
   - Name the answer shape once (a shared encoder) so `insert_blocks` (below) and U6's `duplicate_note` reuse it. U7's
     VX-254 will add a per-take digest to it, so leave the per-take record room to grow (no positional arrays).
2. **VX-255: `insert_blocks` into an existing note.**
   - **RULED, her word:** *"VX-255: agreed, write new lets them add blocks at the end, edit lets them write blocks
     anywhere. I think that's a fair line to draw."*
   - The shape is `insert_blocks(note_id, after_block_id?, blocks)`, using `create_note`'s block shape.
   - At WRITE NEW it appends at the note's END only (an `after_block_id` naming anything but the last block — or any
     `after_block_id` at all; argue which reads cleaner — needs EDIT and hears the rungTooLow family's sentence, never the
     not-shared shape for a note the client CAN read). Inserting after a specific block needs EDIT, the line the catalog
     already draws for every placing act. Argue "at the start" (no anchor block) at EDIT.
   - It runs as ONE transaction with ONE client-named undo, on §9 newBlock's road (segmentation as `create_note` does it;
     a sealed post refuses; the post's lock and the take-lock rules as her doors have them). The entry follows U2's undo
     rule: each half answers whether it changed anything.
   - It answers `flushesHerEditorFirst` (U3's exhaustive switch), argued in the record: it adds blocks and touches no
     existing take's text — but say what happens when her caret is in the block it inserts after, and when she is typing
     at the note's end.
   - It answers VX-252's id shape.
   - Pre-launch: it closes an R-VX184-1 parity gap ("as capable as her at the keyboard").

**Evidence that closes U5 (a and b together).**
- Pins red-first per member, red again by revert; the whole headless package green with counts.
- **THE STAGE WINDOW plan** in the record (claim `vx336-u5`; minutes; a batch-only fallback):
  - a Mac batch over every changed source file's suites (grep the tests for the changed types — 13x's lesson);
  - a REAL-client live round on the dev store: `claude -p` turns using each new shape — `create_note` answering ids and
    filing into a chapter; `insert_blocks` at the end at WRITE NEW, refused mid-note at WRITE NEW, then anywhere at
    EDIT, and its ⌥⌘Z; U5a's LIVE LEGS (the new label seen in Takes, captured; `save_lens` by label meeting an ambiguous
    block, then its `picks` retry);
  - the client connects by VX-258's Claude Code tab key, registered `-s local` in a scratch project only; her
    user-scope servers fingerprinted before and after.
- If the implementer is past ~500k at READY, a FRESH stage runner takes the window from the record.

**Out of scope:** U6–U8's members; the guide and `MCPSession.instructions` beyond doc-truth.

### U6 BRIEF — Compare from the wire (VX-311 · VX-298), plus VX-342

**Order:** VX-311 first, so an AI can make a lineage-aligned draft; then VX-298, so it can open Compare on it; VX-342
any time (one word). VX-311 and VX-298 are ruled pre-launch; each ticket is the record.

1. **VX-311: `duplicate_note`, her Duplicate as Version on the wire.**
   - **Her words, verbatim:** *"the duplicate note tool should be easy? if you save the note as a version and immediately
     promote the version it duplicates the note. so i feel like that is actually not hard to accomplish and idk if
     duplicate note tool needs to be its own post launch ticket."*
   - **Why it matters:** Compare lines rows up by shared `derived_from` lineage (`Queries.blockKinship`). A
     `create_note` draft shares none, so Compare opens to empty columns. A duplicate keeps block-by-block lineage.
   - **The build wraps her own op.** `duplicateAsVersion` (AppSpec §9; `Operations+Versions.swift`) makes per-block
     copies carrying comments, presentation and `block.name`, plus a `version_of` edge, in one transaction with ONE
     client-named ⌥⌘Z. Her other road (`saveNoteVersion` then `promoteNoteVersion`) composes the same result from two
     acts. **Argue which the tool wraps** (the direct op is one transaction and her visible door) — the orchestrator
     rules before that half is built.
   - **Access:** the READ rung on the source, plus WRITE NEW where the copy lands (wherever her door puts it — say where
     that is, and what reach decides it); an unreachable source answers the ONE not-shared shape, no oracle; it returns
     the new note's id and take ids in VX-252's shape (U5b's shared encoder).
   - **The undo entry** follows U2's rule, and the tool answers U3's `flushesHerEditorFirst`: a copy reads her latest
     words, so argue it from U3's `save_version` row (which flushes).
   - No schema, no `Sync/`, no custody.
2. **VX-298: `show_in_app` opens Compare with two or more notes side by side.**
   - **HER ANSWERS, 2026-10-13, verbatim where quoted:** (1) any two notes her picker would offer, with no link
     required: YES; (2) "related blocks only" opens OFF when the pair shares no lineage: *"related blocks only off when
     they have no history - that's fine"*; (3) up to three peers: YES; (4) **replace the open columns** — the board shows
     exactly what the AI named, A with B beside it; (5) `link_versions`' "Open ›" opens Compare A|B: YES; (6)
     `duplicate_note` is pre-launch (VX-311, above).
   - **The trace** is the ticket's; read it whole. `show_in_app`'s targets and `MCPShowRule`'s etiquette are in
     `Sources/VariorumMCP/MCPShowTool.swift`: read rung only, never spends a once grant, moves only while Variorum is
     frontmost in a full window, refuses in words otherwise, never queues or raises windows (R-13nb-23/26g). Her Compare
     is ⌘5 (`CompareBoardView`) with its "Compare with" picker (`Core/Views/NotePicker.swift`).
   - **The build:** a `.compare(noteID, peerIDs)` target; a read check on each note in order, where the first refusal
     gives the ONE not-shared answer (`link_versions`' order); then the same wing, and only notes her picker would
     offer; delivery on the lens target's model (`App/Variorum/Variorum/Features/MCP/MCPNavigator.swift`), filling the
     columns the way `makeOutlinePost` does, with "related blocks only" OFF when the notes share no lineage; the catalog
     entry and its Activity words.
   - **`link_versions`' Open ›** (the receipt's one-press door, R-13nb-27) opens Compare A|B.
   - Her ratified word on #226: *"that's fine for the AI to move your view if you ask it to."*
3. **VX-342: the undo-overwrite warning's "BEFORE" in capitals.** Her rule: no shouty caps in rendered text. Lowercase
   it in BOTH doors: the Mac's `ShellActions.discardingUndoDetail` (`App/Variorum/Variorum/Registry/ShellActions.swift`
   ~l.637) and the phone's `MobileUndoDoor.discardingUndoDetail` (`App/Variorum/VariorumMobile/Features/Write/
   MobileUndoDoor.swift` ~l.279); check the shared `StructuralUndoCopy.discardingUndoQuestion` (`App/Variorum/Shared/`).
   Find any pin that asserts the string and move it; if none, add a small one. The phone line makes this run
   mobile-visible: record it for the closeout's MOBILE PARITY line, and name the phone suite that would run it (its run
   rides a simulator stage only if a phone pin changes — say which).
4. **VX-330: the Book Panel's collapsed one-note chapter row wears neither MCP glyph.** **Her words, verbatim:** *"It's an
   issue where combined chapter / note headings don't show any AI symbol but that's how the example sherlock holmes looks
   and i think people might share that book with AI as an example so i want it fixed pre launch."* Found by VX-281 U2's
   walk (its record `notes/plans/fixes/vx-281-mcp-settings-pane-shared-icon.md`, U2 OWED item 5). The row stands for a
   note (a chapter heading and its one note shown as one row — every chapter of the seeded sherlock), but wears neither
   `MCPAskGlyph` nor `MCPSharedIcon`, so VX-268's parity rule ("wherever the ask glyph marks a place, the shared icon marks
   it too") never reached it. **Build:** both glyphs on that row, the same as the panel's note rows (hover, popover,
   pending mark), the note's reach read through the ONE `MCPRowReach` hold the panel already uses (`entryIDs`) — never a
   second rule; reach read only for the rows drawn (P1), nothing read while no client is approved. Pin red-first (the row's
   glyph decision, on the face's pure seam where VX-281 put one; read its record's U2 for the pin forms it used). Sweep
   the panel's other row shapes in the record (instance × glyph: FIXED or provably SAFE) so no sibling shape is left.

**Lanes.** Compare's board is no other run's surface. If a trace reaches the editor seam (vx-282's merged files are
main's now, but the seam rule stands): STOP and report. **VX-283 is live** (Cross-run coordination). Before editing
`Registry/ShellActions.swift` (VX-342), `WorkspaceModel`, `ShellRouter` or any registry file, say so in the record and
STOP for the orchestrator, who tells vx-283 first.

**Evidence that closes U6.** Pins red-first per member, red again by revert; headless green with counts; THE STAGE
WINDOW plan (claim `vx336-u6`; minutes; a batch-only fallback): a Mac batch over every changed source file's suites; a
REAL-client live round on the dev store — `claude -p` turns: `duplicate_note` an existing note, edit the copy,
`show_in_app` with a Compare target naming the pair (rows line up), then an unrelated pair (opens with "related blocks
only" off), and `link_versions`' Open ›; **the Compare board walked in BOTH voices** with captures (`show_in_app` moves
only while Variorum is frontmost, so the walk keeps it in front); **sherlock's Book Panel walked in BOTH voices** — the
book shared with the client (its chapter rows wear the shared icon) and a per-ask pending on one of its notes (that row
wears the waiting mark), captured; the undo warning's new word seen once (Mac).

**Out of scope:** U7–U8's members; the guide (U8) beyond doc-truth for any description this unit makes false.

### U7 BRIEF — the agent's read-backs (VX-254 · VX-256 · VX-261)

**Why after U5 and U6:** the digests must cover every take-writing tool, U5's and U6's new ones included
(`insert_blocks`, `create_note`'s new answer, `duplicate_note`). Source for all three:
`notes/mcp-agent-notes-2026-10-13-bilingual-book.md` (the agent's own notes from her bilingual-book build).

1. **VX-254: content digests on write replies.**
   - Every tool that writes a take's text answers a short digest per take of the STORED text (e.g. SHA-256 of the exact
     UTF-8 bytes, no normalization), so an agent compares it with a digest of its SOURCE and proves the write without
     pulling 130k characters back. Her run's one transcription slip ("beliscáu" → "beliscou", ch. 11) was caught only by
     a full read-back.
   - Cost ∝ the write's size (P1-clean). The descriptions state the algorithm and the byte rule.
   - **Scope by the class rule:** EVERY tool that writes a take's text answers it, and the record lists them as a sweep
     table (tool × writes take text? × digest answered / why not) — `create_note`, `import_document`, `edit_take`, the
     batch adds, `add_take`, `insert_blocks`, `duplicate_note`, `divide_block`/`merge_blocks`, `restore_commit` … every
     one decided.
2. **VX-256: a compact or paged `read_note`.**
   - A big chapter's `read_note with_ids` was 100–133k characters — over Claude Code's tool-output cap (it spilled to a
     file; an agent without a filesystem couldn't verify its work). VX-186's dedupe left ~65k.
   - Add an ids-only form (block, take and label ids, no text) and/or block-range paging, so any client reads a big note
     in pieces. **Argue which, or both** (the orchestrator rules before that half is built). Cost ∝ the page.
   - Keep the ONE not-shared answer and `read_note`'s existing forms byte-unchanged where not asked for.
3. **VX-261: a read tool listing the client's OWN recent acts.**
   - **The chosen road,** her word: *"if you think that a read tool listing the client's own recent acts from the
     activity log suffices then that's fine"*. A read tool over the existing activity log answering the CALLER'S OWN
     recent acts: the act, the target id, the title it wrote, and when. No schema.
   - It covers recovery after a dropped call, and resuming a long job after the agent's own context is lost.
   - **Mind the oracle:** answer only what the client itself sent or was told at act time, never the CURRENT state of a
     target that has since become unreachable. Say what "own" keys on (the client NAME — so two sessions under one name
     see each other's acts; argue it against the name-scoped grant model).
   - The log is capped at 500 rows, which is fine for recovery. Not chosen, recorded only: an idempotency token on
     creating calls.

**Lanes and words.** Tool descriptions in `Sources/VariorumMCP`; Activity words in `MCPPaneCopy.swift` if needed; FOR
VX-234 list.

**Evidence that closes U7.** Pins red-first per member, red again by revert; headless green with counts; THE STAGE WINDOW
plan (claim `vx336-u7`; minutes; a batch-only fallback): a Mac batch over every changed source file's suites; a
REAL-client live round on the dev store — `claude -p` turns: a write whose reply digest the turn checks against its own
source digest; a big note read in pages or ids-only that stays under the client's output cap; and the recent-acts tool
after a deliberately dropped call.

**Out of scope:** U8 (the guide) beyond doc-truth.

### U8 BRIEF — the AI's docs, LAST (VX-197)

**SPLIT before its spawn (the orchestrator, 2026-10-14 ~20:30; U5–U7's lesson):**
- **U8a — the model-facing words:** item 2 (`MCPSession.instructions`, bound 3,000, the ONE link sentence) + the tool
  descriptions' truth (`edit_take`'s deduped before-commit; every take-writing tool's label rule per VX-197's split and
  VX-267; the new tools' descriptions read once for consistency) + item 3 (the stargazing brief's FURTHER delta, the file
  left ONE send-ready message). Headless pins (`MCPSession`'s bound and truth pins; the provider-neutrality pins).
- **U8b — the field guide's MCP chapter:** item 1 + item 4 (the re-seed note) + THE STAGE WINDOW (claim `vx336-u8`: the
  Tutorial*/MCP Mac suites, the chapter walked in both voices on a fresh dev-store guide via the product door, a real
  client reading the instructions and answering one organization ask by the advice).
- **Carried into U8 from U7 (builder A's OWED 6, builder B's OWED 3):** "Tools appear only for what they have shared"
  is UNTRUE once `list_my_activity` lists at zero reach; the instructions and the chapter name paging (`limit`/`cursor`,
  `ids_only`), the `sha256` write digest, and `list_my_activity` (recovery after a dropped call). **Numbers that U7's
  window may still move** (the 32,000-character page budget, the 200 `limit` max): U8a states them only through the tool
  descriptions it does not own, or writes them as `PENDING-U7` and the orchestrator confirms them after U7's window —
  never a number the window could falsify.
- **The PAUSE protocol (U8a starts while U7's window waits in the queue):** at the orchestrator's message "PAUSE",
  U8a reaches a clean seam (committed, pushed, `git status` clean), records it, and ENDS ITS TURN; it is resumed after
  U7's RELEASE. It never runs `xcodebuild test`, launches the app, or touches a store.

*(The plan's "U7: the AI's docs" section is this brief's base — read it in full; this adds the carried facts.)* It runs
over the AS-BUILT state, after U5–U7 are proven. Re-check VX-292 is not running before spawning.

1. **The field guide's MCP chapter** (`TutorialSeeder.mcpChapter`; truth suite `TutorialMCPChapterTests`): 13s's quality
   pass (sentence case, no shouty caps, the guide's calm, clear voice, nothing that reads as AI-written; lesson 1 says
   "way in" twice); organization encouraged explicitly (notes, books, chapters, tags, books that collect by tag rules) as
   recipes beside her four; every tool VX-184, VX-246 and THIS run added, taught in its lesson (batch adds, comment
   deletes — own at suggest while its words are unchanged, any at edit — `remove_tag`, `link_versions`, the note-edit
   and library acts, `insert_blocks`, `duplicate_note`, Compare from the wire, the digests, paged reads, recent acts);
   Private / Seal / Own as hers alone (R-VX184-2); lesson 7's icon sentence says "a book or a gathering" AND the shared
   icon's rows as VX-281 built them (Library, Pool, Book Panel, ⌘L rows — the guide still says Bookcase only); lesson 3's
   edit step ("commits just before and just after" holds for take text changes only); **lesson 2 re-voiced** (VX-246's
   F-1 left a truth stopgap shared with the pane's `clientBoundary` by a parity pin): it teaches VX-258's tab rule — a
   client's own setup moves its name with no clicks, while any other new setup waits in Settings ▸ MCP ▸ Waiting for her
   Allow and sees no tools until then; the copy act is now an icon on the setup's code block (not "press Copy setup
   command"); the label form per VX-267 and her label split; build on VX-201's merged guide changes (VX-204, VX-209) —
   never overwrite them.
2. **`MCPSession.instructions`** (bound 3,000, R-VX184-3 — `instructionsBound` and its pin together): the organization
   advice, R-VX184-2's awareness (what Private/Seal/Own are, that only she sets them, so the AI can suggest them), the
   edit rung's reach, the new tools' roads, and ONE sentence linking `https://stargazing.tech/variorum/mcp` (exactly that
   URL). Provider-neutral (O-4) and truth-pinned. `edit_take`'s description over-promises the "before" commit (deduped
   when unchanged): fix it to the truth. Every take-writing tool's description says which label rule applies.
3. **The stargazing brief** (`notes/stargazing-mcp-guide-brief-2026-10-12.md`): append a FURTHER delta for everything
   VX-246 and this run changed on the page, and leave the file reading as ONE send-ready message (she carries it to her
   site agent). VX-148 stays honest there (deleted comments aren't readable on the wire; `restore_comment` works on ids
   the client holds).
4. **Re-seed note for her handoff:** her library gains the updated chapter only via Help ▸ Restore Tutorial… (it
   tombstones the old guide into the Trash and mints a fresh one; say so).

**Evidence that closes U8.** The truth pins green (headless where they are core; the Mac Tutorial* family under the
stage); THE STAGE WINDOW plan (claim `vx336-u8`): the Tutorial*/MCP Mac suites; the chapter walked in BOTH voices with
captures (a fresh dev-store field guide via the product door); a real client reading the instructions and answering one
organization ask by the advice.

### U9 BRIEF — two wire truths from U8's round (VX-361 · VX-362)

Both were seen live in U8's real-client organization round (U8 STAGE RUN, F1/F2). The orchestrator's provisional ruling 1
joined them to the run. **Design first, then STOP for the orchestrator's ruling on any fork, then build** (one fresh
implementer can do both halves if context allows; else a continuation builds from the record).

1. **VX-361: `create_note`'s `tag_ids` misses the outflow.**
   - **The symptom:** a client filed a note into a book whose outflow tags notes made inside it. The note was tagged in
     the same act (`applyAutoTag` on mint-inside, AppSpec §9), but the answer said `tag_ids: []`. The client then
     called `apply_tag` and was refused.
   - **The design:** trace where `tag_ids` comes from and what the outflow writes. Argue the shape: `tag_ids` = every
     tag the note carries after the act, or the requested ones plus a separate `outflow_tag_ids`. Keep every existing
     caller's meaning honest; a shape change is a fork to propose. Check `import_document` (one document, and the book
     form) and `insert_blocks` / `duplicate_note` for the same class.
2. **VX-362: no wire answer may show a raw Swift case.**
   - **The symptom:** `apply_tag` on an already-applied tag answered `Refused: alreadyTagged(tagID: "…", targetID: "…")`,
     the `OpsRefusalTable.message(for:roads:)` fallthrough (`App/Variorum/Shared/OpsRefusalTable.swift` ~l.383).
   - **(a) The act:** her own doors treat an already-applied tag as done (`BlockTOCView`, `TutorialSeeder` catch
     `alreadyTagged`). Propose the wire's posture: an idempotent answer (`changed: false`, no undo entry, no Activity
     noise beyond the read-like line) or worded refusal. Same for `remove_tag` on an absent tag and any sibling
     no-op.
   - **(b) The class:** a SWEEP TABLE of every `OperationError` case a wire tool can reach (trace the wire's error
     roads), each either WORDED (words in the shared table, in the house voice, each on the FOR VX-234 list) or PROVEN
     unreachable from the wire. Plus a pin that walks every case the sweep marks reachable and asserts no answer
     starts "Refused:" with a Swift case.
   - **Mobile:** the table is shared with the phone, so new words are mobile-visible; record it for MOBILE PARITY. A
     phone pin that changes needs a simulator run in the window.
- **Pins:** red-first per member and by revert, the house rule.
- **Evidence:** a short window (claim `vx336-u9`): the Mac suites reaching the table and the tag doors (and a phone suite
  if one changed), plus a short real-client leg that repeats U8's organization case (make a book with a tag rule and
  outflow, `create_note` into it, then see `tag_ids` carry the tag, and an `apply_tag` of it answered without a raw case).
  Never `claude mcp list`.
- **Lanes:** `App/Variorum/Shared/OpsRefusalTable.swift` is no other live run's file today. Before editing any registry
  file, `WorkspaceModel` or `ShellRouter`, STOP and report (vx-283 is live).

### CLOSEOUT BRIEF — VX-336 (the orchestrator's, 2026-10-15 ~01:45; her overnight word binds: merge tonight, and the LAST merger releases)

The CLAUDE.md closeout ritual, for this run's scope (U5a–U9, twelve members plus VX-361/362/363). The run is in three
phases, each a fresh `opus-implementer` at xhigh unless context allows one to carry on.
- **The shared ledgers** (`notes/QUESTIONS.md`, the master plan, AppSpec §14, `notes/MobileSoul.md`,
  `notes/plans/run-finals-ledger.md`) are touched ONLY at the merge moment, on LATEST main merged in, in PHASE C.
- **PHASE A** writes their DRAFTS into this record, so PHASE C only applies them.

**PHASE A — in-branch canon + drafts (no stage):**
1. **`notes/MCPSpec.md` — canon IN-BRANCH (R1-2).** The bound "≤2,000" becomes "≤3,000", and the one link sentence
   (the page is LIVE). Add a contract line plus a pointer to this record for every new surface:
   - `insert_blocks` (rung from the arguments, P-VX255-1/2; one undo; the 200 cap);
   - `duplicate_note` (READ on the source + WRITE NEW on its wing; the fence's one sentence; `source_block_id`; one undo);
   - `show_in_app`'s compare target (`note_id` + `peer_ids` 1–3, decisions first, the board decides related-only);
   - `link_versions`' Open › opening Compare;
   - `save_lens` by `label` / `pin_chosen` (the matcher, `unmatched_blocks`, the ambiguity refusal);
   - the AI label form `<client>` / `<client> · <label>`;
   - `create_note`'s / one-document `import_document`'s `blocks` records, `section_id`, and `tag_ids` + `tags` (every
     worn tag);
   - paged and `ids_only` `read_note` (the WHOLE ANSWER bound at ~32,000 UTF-16 units, a block never split, a larger
     block alone, a once grant reads one page, pages not a snapshot);
   - the `sha256` write digests (which tools; divide/merge, `save_version` and the book import answer none);
   - `list_my_activity` (every approved client, the era cut, refused rows title-less, looked-up ids hidden);
   - `apply_tag`'s `changed:false`;
   - the refusal sweep (no wire answer shows a raw case);
   - VX-363's import road;
   - VX-330's collapsed chapter row wearing its note's marks;
   - the guide's chapter (still seven lessons).

   Read AppSpec §12's always-loaded MCP summary and say whether anything there changed (edit it only if a contract
   line there is now false).
2. **QUESTIONS draft** (the next free number at PHASE C): every PROVISIONAL with its options (P-VX253-1/2 + R1-4's
   option, P-VX252-1, P-VX255-1…4, P-VX311-1…3, P-VX298-1…3, P-VX254-1/2, P-VX256-1 re-ruled with U7c's e1–e4,
   P-VX256-2…4, P-VX261-1…6, P-VX197-U8b-1/2, P-VX361-1, P-VX362-1 incl. its once-grant note), plus the orchestrator's
   rulings 1–3 (3 superseded by her word). Lead with what she'd most want to know.
3. **AppSpec §14 draft:** the slim VX-336 entry leads (contract + provenance), and VX-246's entry becomes "Before it —".
   Roll the oldest entry beyond ~five to `notes/AppSpecDeltaArchive.md` per VX-341, always keeping the most recent MCP
   effort. Write the finals/ladder text for `run-finals-ledger.md`.
4. **The master plan draft:** retire VX-336's in-flight row ONLY (VX-246's precedent).
5. **MOBILE PARITY draft:** a `MobileSoul.md` row. VX-342's phone word lowercased, and the shared refusal table's nine new
   sentences reach the phone's fall-through sites (no phone face changed). Also VM-20, the "saved/committed" gap,
   ticketed.
6. **RULINGS RECONCILED** (her 2026-10-13 rule): re-read each ruling this run built against what shipped, especially
   "every", "all" and "everywhere" (VX-254's "EVERY tool", VX-268's parity under VX-330, R-VX184-1). Ticket any remainder
   as OWED (the orchestrator mints).
7. **The handoff draft** `notes/handoffs/vx-336-handoff.md`, her checklist at the top:
   - the release she'll try (0.9.7, what's new, what to try first);
   - the stargazing page (live; its copy PLACEHOLDER-marked for her words; her site repo's DECISIONS #86);
   - the re-seed note (Help ▸ Restore Tutorial…);
   - the QUESTIONS bundle to ratify;
   - the pre-launch calls on VX-357 and VX-363;
   - the filed tickets, grouped by priority;
   - the FOR VX-234 words (consolidated);
   - her overnight word and the rulings made under it.

   Self-contained for a fresh session.
8. **The plan's STATUS banner** (`notes/plans/mcp-pane-and-docs-kickoff.md`) and this record's STATUS line are DRAFTED
   CLOSED, to flip at PHASE C.
9. **THE 0.9.7 NOTES SECTION for this run** is below (the orchestrator's draft, one line per bullet, VX-343's trap).
   Whoever cuts the release lifts it whole and merges it with vx-283's section.

**PHASE B — the closeout window** (claim `vx336-close`; through the orchestrator):
- merge `origin/main` into the branch;
- headless finals (MCP · core · workbook);
- `xcodebuild build-for-testing` of the merged tree;
- the WHOLE Mac target (VX-246's merge-moment form; standing reds named: VX-115, VX-167, VX-245's sites), plus the
  phone suites U9 ran (the shared table);
- no A1 copy is needed unless a walk runs.

**PHASE C — the merge-moment ledgers:** on latest main merged in, apply the drafts (QUESTIONS, AppSpec §14 and its roll,
`run-finals-ledger.md`, the master plan row, MobileSoul), flip the STATUS lines and finalize the handoff. Then the PR
`VX-336: MCP wire tools & AI docs` and the merge ask to the coordinator. Then, if we are the last merger: the release
(0.9.7) and the `/Applications` refresh under the coordinator's rule card. Then the cleanup: delete the worktree, the
branch (GitHub + local), ALL evidence (`notes/plans/vx336-screens/`, the kits `notes/plans/fixes/vx-336-u7-kit/` and
`vx-336-u9-sweep/` committed in-branch, and DerivedData).

#### THE 0.9.7 NOTES — VX-336's section (orchestrator's draft; her review waived tonight)

**More your AI can do.** For anyone using Variorum's MCP door:
- An AI can add paragraphs to a note: at the end with Write new, anywhere with Edit.
- An AI can duplicate a note the way Duplicate as Version does, so Compare lines its rewrite up with your original row by row, and it can open Compare to show you two notes side by side when you ask.
- An AI can save a lens by take label instead of naming every take, and its own takes are labeled with just its name, like "claude-code · english".
- Writes answer with the ids of everything they made and a fingerprint of the words stored, so an AI can check its work without reading the whole note back.
- Long notes are read in pages small enough for an AI to take in whole, and an AI can look up its own recent acts to see whether a call went through after a dropped connection.
- Clearer answers: notes made in a book that tags its notes say so, tagging a note twice is simply fine, and every refusal the door knows of is in plain words.
- The field guide's chapter on AI is refreshed. To get it, choose Help ▸ Restore Tutorial… (your old guide goes to the Trash for 30 days).
- An AI can no longer learn the name of a book it can't read by importing one with the same name.
- In the book panel, a chapter that is one note wears that note's shared-with-AI mark.
- The undo warning no longer shouts "BEFORE".

## UNIT RECORDS

## U5a UNIT RECORD — the label pair: VX-267 · VX-253 (opus-implementer, from 2026-10-14 ~13:35 MDT)

**What this unit has NOT done (said first; updated at every piece):** (1) **no stage window of its own** (the brief: U5a's
live legs ride U5b's window — LIVE LEGS FOR U5b's WINDOW below, written as exact `claude -p` turns, NOT run); so the new
label has not been seen in Takes and `save_lens` by label has not met a real client; (2) the field guide and
`MCPSession.instructions` are untouched beyond doc-truth (U8) — and the doc-truth sweep found nothing there stating the
old form (the sweep below); (3) no `notes/QUESTIONS.md` entry and no canon edit (the merge's). Everything else is the plan
below until each LIVE STATUS row says DONE with its log.

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (AppSpec §9's standing conventions and
structural undo, §12's THE MCP DOOR summary); this run record's header, Her kickoff answers, THE UNITS, Hard rules, LIVE
STATUS, Stage traffic log, Cross-run coordination, the U5a BRIEF and the U5b BRIEF; the plan
`notes/plans/mcp-pane-and-docs-kickoff.md` whole; `notes/MCPSpec.md` whole; VX-246's record — its Hard rules, THE RUN AS
IT MERGES, the U1 UNIT RECORD (VX-280's `picksSQL` trace, fix and plan pin), the U2 UNIT RECORD (the quiet-half rule and
THE SWEEP TABLE — `save_lens` is row 78, SAFE, already stamp-keyed), the U3 UNIT RECORD (the act list and
`flushesHerEditorFirst`); the U5 BRIEF there (the source of this one); `notes/SessionResiliencyProtocol.md` whole;
`notes/mcp-agent-notes-2026-10-13-bilingual-book.md` whole (items 2 and 9); the two tickets' bodies (VX-253, VX-267 —
read-only, matching the brief's quotes; VX-253 also names its DESIGN CALLS (a) no magic label value, (b) refuse or pick
deterministically, (c) the match rule must say which form it compares). Code read: `MCPWriteTools.swift` whole
(`aiLabel` and its call sites, `parse`, `perform`'s `saveLens` arm, `onNote`, `land`, `picks`/`picksSQL`),
`MCPWriteTools+Batches.swift` whole (`add_takes`' call site, `placedBlocksSQL`), `MCPToolCatalog.swift`'s read and suggest
declarations (`add_take`, `add_takes`, `save_lens`, `read_note`), `MCPSession.instructions`, `MCPNoteStructure.read` and
`lenses` (the shown-take rule on the wire; read_note's `picks` shape), the core `Operations.saveLens` + its undo halves,
`setLensChoice`, `Queries.effectiveLensSelection` / `danglingLensPicks`, `Queries.renderedVariantIDs` (the one render
rule), her own Save Choices as Lens doors (`TakesViewModel.saveCurrentChoicesAsLens`,
`EditorViewModel.saveCurrentChoicesAsLens`), `MCPPaneCopy`'s `save_lens` Activity words (unchanged — the act is the
same tool), the field guide's MCP chapter (`TutorialSeeder` lessons 1–7); tests: `MCPWriteServerTests`,
`MCPLensDoorsServerTests`, `MCPBatchDoorsServerTests`, `MCPPicksPlanTests`, `MCPServerTests`' harness.

**Surfaces (planned):** `Sources/VariorumMCP/MCPWriteTools.swift` (`aiLabel`; the `saveLens` job, parse and arm),
a NEW `Sources/VariorumMCP/MCPWriteTools+LensRule.swift` (the lens rule: the matcher, its one read, the answer and the
refusal), `Sources/VariorumMCP/MCPToolCatalog.swift` (`save_lens`' schema and description; `add_take`/`add_takes`
descriptions only if the doc-truth sweep needs them); tests under `Tests/VariorumMCPTests/`. ZERO core op change (the
lens rule resolves to picks; `Operations.saveLens` and its undo entry are untouched), ZERO `Sync/`, custody, schema,
`Server/`, editor seam, app files (no Activity word changes — `save_lens` keeps its words), `MCPSession.instructions`
(doc-truth found nothing to fix). So **no Mac build is owed** unless a piece moves an app file (the record will say).

### LIVE STATUS — U5a's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the traces and the design (before code); `notes/plans/vx336-screens/` gitignored | DONE (this commit) |
| 1 | VX-267 — the pin on the OLD tree (the wire: `add_take` and `add_takes` store `<client>` / `<client> · <label>`), RED | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPTakeLabelFormServerTests.swift` (`aSuggestedTakeIsLabelledWithTheClientAloneOrTheClientAndItsLabel`: `add_take` with a label, none and a blank one; `add_takes` with and without; the control — `create_note` at write new keeps "english" exactly). Wire only, so it compiles on the old tree. **RED on the old tree (`f43cef82`'s sources): 1 test, 2 issues, each on its designed line** — `singles → ["claude-code · suggested · english", "claude-code · suggested", "claude-code · suggested"]` and `batched → ["claude-code · suggested · english", "claude-code · suggested"]`; the control GREEN, by design (log `notes/plans/vx336-screens/u5a/logs/p1-pin-red.log`, gitignored) |
| 2 | VX-267 — the fix (`aiLabel`'s body + doc) + the three old pins re-pinned as JUSTIFIED EDITS + the doc-truth sweep, GREEN | DONE (this commit) — **the fix:** `MCPWriteTools.aiLabel` → the client alone, or `client + labelSeparator + own` (trimmed; blank = none); `labelSeparator` named (` \u{00B7} `, the matcher reads it next); its doc says the split and the legacy form. **JUSTIFIED EDITS (the ritual comment in place, each asserting the new form, nothing else changed):** `MCPWriteServerTests.theFactCheckShape…` (`"claude-code · english"` ×2), `MCPBlankTakeDoorsServerTests.addTakeAcceptsAnEmptyTextAsABlankTake` (`"claude-code"`), `MCPBatchDoorsServerTests.addTakesLandsEveryTakeAsOneUndo` (`"claude-code · english"`, `"claude-code"`). **The doc-truth sweep:** nothing states the old form (the trace above) — no description, instructions or guide edit. **GREEN:** the pin 1/1; the whole MCP target **241 / 52**, EXIT 0, zero ✘ (log `p2-mcp-target.log`) |
| 3 | VX-267 — red again BY REVERT (announced first, on a committed tree; restored and verified) | DONE (announced `db64a76f`, recorded in this commit) — on the committed tree `db64a76f`, `MCPWriteTools.swift` back to the pins commit `df9cca89` (`git diff HEAD --stat`: that one file, +6/−16), the pins kept → **RED again: 4 tests, 6 issues** — the new pin **2 issues on the SAME two lines as piece 1** (`:66`, `:82`), and each justified edit red on its edited line (`MCPLensDoorsServerTests.swift:82`, `MCPBatchDoorsServerTests.swift:124` + `:125`, `MCPWriteServerTests.swift:85`) — the edits assert the new form, not something weaker (`p3-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/VariorumMCP/MCPWriteTools.swift`, `git diff HEAD` empty, `git status` clean → **4/4 green** (`p3-restored.log`) |
| 4 | VX-253 — the pins on the OLD tree (wire only: label fill, unmatched, ambiguity refusal + retry, own-suggestion forms, pin_chosen, the malformed combinations, the not-shared guard), RED | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPLensByLabelServerTests.swift`, 7 tests, wire only: `aLabelPicksEachBlocksTakeOfThatLabelAndListsTheBlocksWithNone` (hers exact, its own in VX-267's and the legacy form, never another client's; `unmatched_blocks`/`_count`; the page unchanged; one client-named undo; another client's FULL label matches exactly as stored) · `anAmbiguousBlockRefusesTheWholeCallNamingItsTakesAndTheRetryWithTakeIdsLands` (her "english" + its own suggested "english" on one block, her "english" + a legacy own one on another → one refusal naming both blocks and their matching takes, nothing saved; the retry with `take_ids` for exactly those lands) · `pinChosenPinsWhatEachBlockShowsNowWithThePicksFirst` (the pick first, every other block pinned; her later ✓ never moves it) · `everyMalformedFillRefusesAndSavesNothing` (8 cases) · `anUnreachableNoteAnswersTheOneNotSharedShapeWhateverTheFill` (the GUARD) · `unmatchedBlocksCarryTheFirstTwoHundredAndTheCountTheWhole` · `theAmbiguityRefusalNamesTheFirstTwoHundredAndTheCountTheWhole`. **RED on the old tree (`f5f86487`'s sources): 6 of 7 failed, 35 issues, every one on its designed line, no premise line** — the old parse ignores `label` and `pin_chosen` and saves an EMPTY lens (`picked → [:]`; the ambiguous call `isError → false`; the 8 malformed calls each LANDED a lens); **the guard green, by design** (an unreachable note answered the one not-shared shape on the old tree too — it pins what the fix must not change) (log `p4-pins-red.log`) |
| 5 | VX-253 — the fix (parse, the rule, the read, the answer, the catalog) + the new-API pins (the pure matcher, the plan pin), GREEN | DONE (this commit) — **the fix:** `MCPWriteTools.swift` — `Job.saveLens` carries `rule: LensRule?`; the parse reads `take_ids` (now optional), the rule (`parseLensRule`), and refuses no fill at all; the arm resolves the picks FIRST (VX-280's `picksSQL`, unchanged), then `fillLens` over the uncovered blocks inside the act's closure (after the decision), merges, answers `unmatched_blocks` (≤200) + `unmatched_count` only when a rule was given (a `take_ids`-only answer byte-unchanged), and calls the UNCHANGED `Operations.saveLens`. NEW `MCPWriteTools+LensRule.swift` — `LensRule`, `labelAnswers` (the matcher: exact, `‹client› · ‹label›`, `‹client› · suggested · ‹label›`), `parseLensRule`, the two statements (`lensRulePlacementsSQL`, `lensRuleTakesSQL`), `fillLens`, `ambiguityWords` (the sentence + one JSON line). `MCPToolCatalog.saveLens` — the schema (`take_ids` optional, `label`, `pin_chosen`; required `note_id`, `name`) and the description (below, AS BUILT). **The plans (printed once by a temporary line, removed before this commit — `p5-plans.log`):** placements `SEARCH cb USING INDEX idx_cblock_order (container_id=?)` → `SEARCH b USING INDEX sqlite_autoindex_block_1 (id=?)` → `USE TEMP B-TREE FOR LAST TERM OF ORDER BY`; takes `SCAN j VIRTUAL TABLE INDEX 1:` → `SEARCH v USING INDEX idx_variant_block (block_id=? AND status=?)` → `USE TEMP B-TREE FOR ORDER BY` — ∝ the note's blocks and their takes, no table scanned. **NEW-API PINS (green by construction, state):** `Tests/VariorumMCPTests/MCPLensRulePlanTests.swift` — the matcher's cases (exact; its own in both forms; never another client's by its own part, but by its FULL label; case- and byte-exact; the client alone; nil), the round trip (what `aiLabel` writes the matcher finds for its own client only), the plan pin (both statements). **GREEN:** `MCPLensByLabelServerTests` **7/7** (`p5-pins-green.log`); `MCPLensRulePlanTests` 3/3 (`p5-newapi.log`); the whole MCP target **251 / 54**, EXIT 0, zero ✘ (= piece 2's 241/52 + 7 + 3, two suites; every existing pin UNMODIFIED — `MCPPicksParityServerTests` and every `take_ids` caller included) (`p5-mcp-target.log`) |
| 6 | VX-253 — red again BY REVERT (announced first; the new-API test file moved aside inside the worktree) | DONE (announced `fa348102`, recorded in this commit) — on the committed tree `fa348102`: `MCPWriteTools.swift` + `MCPToolCatalog.swift` back to the pins commit `d030deaa`, `MCPWriteTools+LensRule.swift` and `MCPLensRulePlanTests.swift` moved aside to `notes/plans/vx336-screens/u5a/prerevert-253/` (gitignored) → **RED again: 6 of 7 failed, 35 issues, the test × line set IDENTICAL to piece 4's** (35 pairs, `diff` empty — `p4-pins-red.pairs` vs `p6-revert-red.pairs`); the guard green as before (`p6-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/VariorumMCP/ Tests/VariorumMCPTests/`, `git status` clean, `git diff HEAD` empty, the aside folder removed → **10/10 green** across the two suites (`p6-restored.log`) |
| 7 | headless finals (MCP · core · workbook) | DONE (this commit) — **the whole package, `swift test --skip-build` on `580e2867`'s sources (the tree clean), EXIT 0 in 6:44: `VariorumMCPTests` 251 / 54 · `VariorumCoreTests` 2,860 / 330 · `StringsWorkbookTests` 40 / 6**, zero ✘; the standing gated skips only (the 13o measurements, the real-server convergence pass, the fixture/bench probes) (`p7-finals.log`). MCP = main's target + `MCPTakeLabelFormServerTests` 1 + `MCPLensByLabelServerTests` 7 + `MCPLensRulePlanTests` 3; core and workbook untouched by this unit (no core line moved). **No Mac `build-for-testing` owed:** no app file moved (`git diff --name-only 501c367e..HEAD -- App` is empty — the app's `save_lens` Activity words are the same tool's, unchanged) |
| 8 | LIVE LEGS FOR U5b's WINDOW + FOR VX-234 + PROVISIONALs + self-assessment → the report | DONE (this commit) — the sections below; U5a's acceptance closes with U5b's window (the brief) |

**No revert is in flight** (pieces 3 and 6 ran their reverts and RESTORED them — `git status` clean, `git diff HEAD` empty).

### The traces (written before code)

**VX-267 — the label an AI take wears (a convention row, her ruling — not a bug; the pin is a FORM pin).** Inputs →
output: a client named `claude-code` at SUGGEST calls `add_take(block_id, text, label: "english")` →
`MCPWriteTools.perform`'s `.addTake` arm (`MCPWriteTools.swift:358–366`) → `ops.addTake(…, label:
Self.aiLabel(client: clientName, own: takeLabel))` → `aiLabel` (`:752–756`) builds `"claude-code · suggested"`, then
`" · english"` → stored in `variant.label` → her Takes card shows **"claude-code · suggested · english"**. `add_takes`
(`MCPWriteTools+Batches.swift:145–148`) relabels every item through the same function. Those are its ONLY two call sites
(grep: `aiLabel` appears nowhere else under `Sources/`, `App/` or `Tests/`); every other take-writing tool stores labels
as given (`create_note`'s blocks, `import_document`, `set_take_label` — P-VX195-5, her VX-197 split). **The ruled form:**
`<client>` or `<client> · <label>` (the label trimmed as today; a blank label → the client alone). Existing takes keep
their stored labels (text, no migration). **Who else reads the form:** nothing in the app parses an AI label (grep for
`· suggested` under `App/` and `Sources/`: only `aiLabel` itself); three MCP pins assert the old form
(`MCPWriteServerTests.swift:82`, `MCPLensDoorsServerTests.swift:84`, `MCPBatchDoorsServerTests.swift:122–123`) — they
become JUSTIFIED EDITS (the ritual comment in place), each asserting the new form.
**The doc-truth sweep (the brief: any description, instructions line or guide sentence that states the OLD form):**
- `add_take`'s description — "labeled with this client's name (plus your label, if given)": TRUE of the new form; it
  never stated "suggested". `add_takes`' — the same words, TRUE. `create_note`/`import_document`/`set_take_label` say
  nothing of a client prefix (true — they store labels as given).
- `MCPSession.instructions` — no label sentence at all ("suggest (add takes and comments beside their text, save
  lenses)"): nothing false.
- The field guide's MCP chapter (`TutorialSeeder` lessons 1–7) — no sentence states an AI label's form (lesson 3 says
  "Suggest: it can add new takes and comments beside your text"; lesson 6 says new takes "join the block's takes
  unchosen"; lesson 7's "Undo ‹name›'s take" is the undo label, not the take label): nothing false.
- `notes/stargazing-mcp-guide-brief-2026-10-12.md` (her site agent's brief — U8's file): no label form either.
So **VX-267's doc-truth is nothing to correct**; the matcher's description (VX-253) is the one place that must STATE the
form, and it states the new one plus the legacy match. Said so U8 knows the guide's label sentence is still to write
(her VX-197 split: "every take-writing tool's description says which label rule applies" — U8's).

**VX-253 — a lens by label costs one UUID per block (agent ergonomics, ruled — a pure addition).** Inputs → cost: the
bilingual book (25 notes, 3,843 blocks, two lenses each) — `save_lens(note_id, name, take_ids: [one per block])`
(`MCPWriteTools.swift:188–194` parses `take_ids`; `:376–384` resolves them through `picks(noteID:takeIDs:)` → VX-280's
`picksSQL`, ∝ the ids) → about 7,700 take ids retyped by a model, each learned first from a full `read_note with_ids`.
Today a `label` argument is silently IGNORED (the parse reads only `take_ids`, `?? []`), so `save_lens(note, name,
label: "english")` lands an EMPTY lens (no picks: every block falls through to its chosen take) and answers success —
the red-on-old pins read exactly that. **The ruled behaviour** (the brief, the ticket — quoted there, not repeated):
three explicit fills — picks, `label`, `pin_chosen: true` — picks first; an unmatched block shows its chosen take and is
listed in `unmatched_blocks`; an AMBIGUOUS uncovered block refuses the whole call naming those blocks; labels match
exactly as stored plus the client's OWN suggestions by their own part (`<client> · <label>`, and the legacy
`<client> · suggested · <label>`), never another client's; `save_lens` stays at SUGGEST; cost ∝ the note's blocks.

### The design (argued — the brief's three "argue" items, and the edges it leaves)

1. **The picks fill IS `take_ids`** (PROVISIONAL **P-VX253-1**). The ruling's "picks" is the fill a lens has always been
   given — explicit take ids, one per block — and the wire's name for it is `take_ids` (read_note's `with_lenses` answers
   a lens's `picks` as `[{block_id, take_id}]`, the read side of the same thing). Kept: one wire name per concept, every
   existing caller and pin byte-unchanged; `take_ids` stops being REQUIRED (a rule may now stand alone) and its
   description calls them the per-block picks, applied first. Options: (a) AS BUILT; (b) rename to `picks` (breaks every
   existing caller's habit for a word); (c) accept both names (two words for one thing on one tool).
2. **The fills and their combinations (refusals at the PARSE — before any decision, so no oracle):**
   - `take_ids` alone — today's call, unchanged (an explicit `[]` stays legal: an empty lens, as today).
   - `label` (a non-blank string) — with or without `take_ids`.
   - `pin_chosen: true` — with or without `take_ids`. `pin_chosen: false` reads as not given (a boolean, never a magic
     value); a non-boolean refuses "pin_chosen must be true or false."
   - `label` AND `pin_chosen: true` → refused: "Pass label or pin_chosen, not both — take_ids can ride either." (two
     rules for the same uncovered blocks contradict each other; no precedence is ruled, so none is invented).
   - **none of the three** → refused: "Pass take_ids (the take to show per block), label, or pin_chosen: true." — the
     ruling's "explicit": the old schema REQUIRED `take_ids`, so no conforming client ever sent nothing; the lenient
     parse's empty lens for an absent key was an accident, not a door.
   - a blank `label` (empty or whitespace) → "label can't be blank."; a non-string → "label must be a string." The label
     is otherwise compared EXACTLY as given (no trimming — "exactly as stored").
3. **What `pin_chosen: true` means exactly — her own door, on the wire.** Today a lens block with no pick falls through to
   the note's chosen take AT READ TIME (`effectiveLensSelection`; the Lenses board), so the lens moves when her ✓ moves.
   `pin_chosen` makes it an EXPLICIT pick of the take each block shows NOW — exactly her **Save Choices as Lens…** (⌘⇧L,
   `EditorViewModel.saveCurrentChoicesAsLens` / `TakesViewModel.saveCurrentChoicesAsLens`: "a lens whose EXPLICIT pick on
   every renderable slot is what the post currently shows"), so a later ✓ never moves it. "Shows now" is the store's ONE
   render rule (`Queries.renderedVariantIDs` / `Operations.renderedVariant`: the chosen take while it is live, active and
   on this block, else the block's default), restricted to ACTIVE takes because a lens may only name an active take
   (`setLensChoice` / `saveLens` refuse an archived one); a block whose rendered take is an archived default (a render
   edge — the default is normally reassigned on archive) gets no pick, still shows it, and is listed in
   `unmatched_blocks` (honest, never a refusal).
4. **The matcher (VX-253's design call (c) — which form it compares).** For the calling client C (the session's
   name — the same name the take was labelled with) and the given label L, a take MATCHES when its stored label is
   exactly `L`, or exactly `C · L` (VX-267's form), or exactly `C · suggested · L` (the legacy form). Three byte-exact
   comparisons, case-sensitive; the separator is ` \u{00B7} ` (`aiLabel`'s). Never another client's: D's `D · english`
   matches C's `english` only if C passes `D · english` itself (exact as stored — its own read showed it that label). Only
   LIVE, ACTIVE takes of the note's live-placed blocks are candidates (a lens may name nothing else). A take that would
   match by two roads counts once (a set). **Recorded limit:** a label SHE typed by hand as `claude-code · english`
   reads, for claude-code, as its own suggestion — labels are text; the form cannot know who typed it.
5. **Picks first, then the rule, per block** (the ruling): a block named by `take_ids` takes that pick and is never
   ambiguous or unmatched; every other live-placed block gets — under `label` — its ONE matching take (a pick), no pick
   when nothing matches (listed in `unmatched_blocks`), or makes the call AMBIGUOUS when two or more match; under
   `pin_chosen` — its rendered active take (a pick). The resolved picks go to the UNCHANGED `Operations.saveLens` (which
   re-validates every pick inside its transaction: live, active, this note — a race refuses in its existing words).
6. **The ambiguity refusal (the brief's "the refusal's block ids").** One refusal for the whole call, nothing saved:
   `label "‹L›" matches more than one take on ‹one block | N blocks›, and a lens shows one take per block. Call again with
   the same label and take_ids naming the take to show on each of these blocks:` then one line of JSON —
   `{"ambiguous_blocks":[{"block_id":…,"takes":[{"label":…,"take_id":…}, …]}, …]}` — the blocks in note order, each
   block's MATCHING takes in fan order with their stored labels, so the retry needs no `read_note` (the cost the ticket
   exists to remove). Capped at 200 blocks (`MCPNoteStructure.carriageCap`, the house's per-answer bound) with
   `"ambiguous_count"` the total (the retry then meets the rest). **No oracle:** every id named is a block of the note
   the decision ALREADY allowed at suggest (≥ read) and an active take of it — exactly what `read_note with_ids` shows
   this client; the refusal runs inside the act's closure, after the decision, so an unreachable note answers the ONE
   not-shared shape byte-identical whatever fill it was given (a guard pin).
7. **The answer's shape.** `take_ids` alone: `{"lens_id","note_id"}` — byte-unchanged. With a rule: plus
   `"unmatched_blocks"` (block ids in note order, the first 200) and `"unmatched_count"` (the total) — so an agent checks
   at a glance that every block it expected was matched, with an answer bounded however long the note is (a 3,000-block
   note with a mistyped label would otherwise answer 100k characters). Every id is a block of the allowed note.
8. **A label that matches nothing anywhere in the note refuses** (PROVISIONAL **P-VX253-2**): "No take in this note is
   labelled “‹L›” — nothing was saved." Such a lens names no take by label, so it reads exactly as the note (or as its
   picks alone): a mistyped label would leave her a junk lens a suggest client cannot delete (`delete_lens` is edit). §12's
   "a door that did nothing speaks a refusal", applied. Options: (a) AS BUILT — refuse when no active take of the note
   matches; (b) the letter alone — save it, every block listed in `unmatched_blocks`; (c) refuse only when, besides, no
   take_ids were given.
9. **Cost (P1).** The rule's read is ∝ the note's blocks and their takes — necessarily (a rule speaks of every block),
   which is the brief's own bound — in TWO statements on the read_note shape: the note's live placements by
   `idx_cblock_order (container_id=?)` (with each block's chosen and default ids), then their live active takes by
   `json_each` → `idx_variant_block (block_id=? AND status=?)` (`CROSS JOIN`, the house's `json_each` discipline). Both
   statements are named constants pinned on the plan (no table scan; the takes driven by the ids). The given `take_ids`
   still resolve through VX-280's `picksSQL` (∝ the ids) — built on, never around. The core op's validation is ∝ the
   picks (one per block).
10. **`flushesHerEditorFirst` — false, argued (U3's exhaustive switch; `.saveLens` already answers false).** A lens names
    takes; it never reads, rewrites, copies, freezes or tombstones a take's TEXT. The rule reads LABELS (her label edits
    are committed by her own act, `setTakeLabel` — never pending in the autosave coordinator) and the CHOSEN pointer
    (her ✓ is an immediate op, never debounced). Her pending typing is text in a take the lens may name — it lands in
    that take by her own debounce, exactly as before; the lens shows whatever the take holds. Nothing to flush.
11. **The undo entry (U2's rule) — unchanged.** One `Operations.saveLens` call, one client-named entry (`"‹client›'s
    lens"`), whose halves already answer whether they changed anything (THE SWEEP TABLE row 78: the inverse returns the
    stamp it wrote or nil — quiet, retires; the redo revives only on that stamp). The rule adds no half.
12. **The fence and Private/Seal/Own:** untouched — the decision is `onNote(noteID, rung: .suggest)` as today, before
    anything of the rule runs; a lens is allowed under a seal (lens CRUD's posture, unchanged).
13. **The descriptions (doc-truth for this unit's own tool):** `save_lens` says the three fills, picks first, the match
    rule with the stored forms (`<client> · <label>`, and older takes' `<client> · suggested · <label>`), unmatched
    blocks showing their chosen take and the cap, the ambiguity refusal and its retry, and `pin_chosen` as the note's
    current takes made explicit. Words AS BUILT (FOR VX-234 lists tool descriptions only for the record — they are the
    model's, not her pane's; nothing renders in her app).

### LIVE LEGS FOR U5b's WINDOW (U5a's share of the shared round — NOT run here; claim `vx336-u5`)

**Where they sit in U5b's window:** after U5b's connect leg (the Claude Code TAB key re-binding `claude-code` with zero
clicks — VX-246 U1b STAGE RUN leg 1's worked form) and its grant (`claude-code` ▸ Change… ▸ a wing · Home · Edit · Always
reaches every leg here — suggest is inside edit). The product is U5b's Debug build (`DerivedData/vx336-u5`, which carries
this unit's sources). The client is a REAL Claude Code over the REAL shim
(`…/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp`), configured by a scratch JSON —
`$SCRATCH/u5a-mcp.json` = `{"mcpServers":{"variorum-dev":{"command":"<the shim, or U1b's tee-shim.sh wrapping it>",
"env":{"VARIORUM_MCP_KEY":"<the tab key>"}}}}` — and `claude -p --strict-mcp-config --mcp-config $SCRATCH/u5a-mcp.json
--output-format json`, each answer tee'd to `notes/plans/vx336-screens/u5/u5a-<leg>.json` (keys redacted to 9 characters in
every record and capture name). Never her user scope; her user-scope fingerprint read before and after (U5b's). **~20
minutes**, Study first, the label capture again in Terminal.

0. **The fixture, through her own doors (≈3 min):** Bookcase quick entry: `{t:"vx336 u5a"}Olá.` ⇧⏎ `Tudo bem?` ⇧⏎
   `Adeus.` ⇧⏎ `Fim.` ⏎ — a note of four blocks in Home (if the chip's Return makes blocks differently, use four ⏎ — the
   evidence needs four blocks, not a recipe). Capture the page.
1. **Leg A — VX-267, the new label seen in Takes (≈5 min, BOTH voices).** ONE turn, allowed
   `mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,mcp__variorum-dev__add_take,mcp__variorum-dev__add_takes`:
   > In Variorum, find the note titled "vx336 u5a" (list_notes, then read_note with with_ids true). Add a take labelled
   > english to its FIRST block with add_take, text "Hello.". Then in ONE add_takes call add takes labelled english to its
   > second block (text "All good?") and third block (text "Goodbye."). Then read_note with with_ids true again and reply
   > with each new take's take_id and the label read back.
   **Expected:** three take ids; every label read back **`claude-code · english`** (never "suggested"). **Her face:** the
   note in Takes (⌘2) — each of blocks 1–3 shows a new card labelled **"claude-code · english"**, unchosen; the page
   unchanged. Capture one card's label as a crop; flip the voice (Settings ▸ General ▸ Theme) and capture the same card
   in Terminal; flip back.
2. **Leg B — VX-253, save_lens by label meets an ambiguous block, then its retry (≈5 min).** Her own door first: in
   Takes, on block 1 ("Olá."), ＋ new take (blank) → type `Hi.` → label it **`english`** (the take's label field) — block
   1 now holds her "english" AND claude-code's "claude-code · english" (her ruling's case: two matches). Capture. ONE
   turn, allowed `mcp__variorum-dev__list_notes,mcp__variorum-dev__save_lens,mcp__variorum-dev__read_note`:
   > In Variorum, on the note titled "vx336 u5a", call save_lens with name "english" and label "english", and do NOT pass
   > take_ids. It should refuse, naming a block and its matching takes. Then call save_lens again with the same name and
   > label, plus take_ids holding exactly the take labelled "claude-code · english" on the block the refusal named. Quote
   > both answers verbatim.
   **Expected:** answer 1 `isError` — "label "english" matches more than one take on one block, and a lens shows one take
   per block. Call again…" + the JSON naming block 1 with two takes (labels `english`, `claude-code · english`); answer 2
   `{"lens_id":…,"note_id":…,"unmatched_blocks":["<block 4>"],"unmatched_count":1}` (block 4 "Fim." has no english take).
   **Her face:** Lenses (⌘4) — the "english" lens column reads "Hello." / "All good?" / "Goodbye." / "Fim." (the last
   its chosen take, unmatched). Capture. Activity: one "saved a lens" line and the refused one before it, in words.
3. **Leg C — VX-253, an own suggestion in the LEGACY form matches (≈4 min).** Her own door: on block 4 ("Fim."), ＋ new
   take (blank) → type `The end.` → label it by hand **`claude-code · suggested · english`** (a take as a pre-VX-267
   client left it — labels are text). ONE turn, allowed `mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,
   mcp__variorum-dev__save_lens`:
   > In Variorum, on the note "vx336 u5a", call save_lens with name "english, legacy too", label "english", and take_ids
   > holding exactly the take labelled "claude-code · english" on the first block. Then read_note with with_lenses true
   > and reply with that lens's picks and the answer's unmatched_blocks.
   **Expected:** lands; `unmatched_blocks` `[]`, `unmatched_count` 0; the lens's picks name block 4's **"The end."** take
   (the legacy form matched as claude-code's own). **Her face:** the new lens column reads "…/ The end." Capture.
4. **Leg D — optional, if minutes remain (≈3 min): `pin_chosen`.** ONE turn (save_lens only): `save_lens(name: "as it
   reads", pin_chosen: true)` → `unmatched_count` 0. Her ✓ on block 2's "claude-code · english" take (Takes); Lenses: the
   "as it reads" column still shows "Tudo bem?" (pinned, not a fall-through). Capture.
5. **Nothing to clean beyond U5b's:** the notes live in the dev store, which U5b's window restores from its A1 copy
   (`Tools/ScaleFixture/restore.sh` → "Restored (verified)").

**A red here is a finding, never a fix under the claim:** record the answer and the capture, finish the window's
cleanup, and report.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX253-1 — the picks fill keeps the wire name `take_ids`:** (a) AS BUILT — `take_ids` is the ruling's "picks" (the
  explicit per-block takes a lens has always been given; read_note's `picks` is the same thing read back), now optional;
  (b) rename it `picks` (every existing caller re-learns a word); (c) accept both names.
- **P-VX253-2 — a label that no take in the note wears refuses:** (a) AS BUILT — "No take in this note is labelled
  “‹L›” — nothing was saved." (a lens naming nothing by label reads as the note: a mistyped label would leave her a junk
  lens a suggest client can't delete — §12's "a door that did nothing speaks a refusal"); (b) the ruling's letter alone —
  save it, every block listed in `unmatched_blocks`; (c) refuse only when no `take_ids` were given either.

**Argued, not provisional (the brief's own "argue" items — design §2, §3, §6, §7):** `label` with `pin_chosen` refuses
(no precedence is ruled, so none is invented); no fill at all refuses (the old schema required `take_ids`); `pin_chosen`
means her Save Choices as Lens (an explicit pick of each block's rendered ACTIVE take); the answer and the refusal list at
most 200 blocks with a count of the whole (the house's per-answer bound); the refusal names each ambiguous block's
matching takes so the retry needs no read. **Recorded limits:** a label she typed by hand as `‹client› · ‹label›` reads,
for that client, as its own suggestion (labels are text); `pin_chosen` on a block whose rendered take is an archived
default (a render edge) leaves that block unpinned and lists it.

### FOR VX-234 (user-facing words, as built)

1. **An AI take's label on her Takes cards, the take panel and the Lenses board** (VX-267, her ruling): **`‹client› ·
   ‹label›`**, or **`‹client›`** alone when the client gave no label — "suggested" dropped (was `‹client› · suggested ·
   ‹label›`). Takes made before keep their old labels (text, no migration). Written by `MCPWriteTools.aiLabel`.

Nothing else she sees changed: `save_lens`' description, its refusals and its answer are the model's words (on the wire,
never rendered); the Activity line for a refused or landed `save_lens` uses the pane's existing words.

### SELF-ASSESSMENT (the implementer's)

- **Against the brief:** VX-267 first, then VX-253, as ordered. VX-267: the form is exactly the ruling's (`‹client›` or
  `‹client› · ‹label›`), at both call sites, existing takes untouched; the doc-truth sweep found nothing stating the old
  form (said with what was read, so U8 knows the label sentence is still to write). VX-253: the three explicit fills, the
  picks first, `unmatched_blocks`, the whole-call ambiguity refusal naming the uncovered blocks, the match rule exactly as
  ruled (exact, own in both forms, never another's — her "english" plus its suggested "english" refuses), SUGGEST
  unchanged, VX-280's picks read built on. Each member pinned red-first on the wire (VX-267 1 test / 2 issues; VX-253 6 of
  7 / 35 issues, the guard green by design) and red again by revert (VX-267 4 tests / 6 issues; VX-253 the identical 35
  test × line pairs), green after; the whole package green (MCP 251/54 · core 2,860/330 · workbook 40/6).
- **Against the spec:** every write is still ONE §9 operation (`saveLens`, unchanged) with ONE client-named undo entry
  whose halves already answer U2's question; `flushesHerEditorFirst` stays false, argued (§10 of the design); the fence
  holds (the rule runs only after the decision — the guard pin; malformed fills refuse at the parse, independent of any
  note); Private/Seal/Own untouched; P1 — the rule's read ∝ the note's blocks and their takes, both statements pinned on
  the plan, the picks still ∝ the ids. Zero `Sync/`, custody, schema, `Server/`, editor seam, app files, core lines
  (path-checked: `git diff --name-only 501c367e..HEAD` = the record, `.gitignore`, three `Sources/VariorumMCP` files, six
  `Tests/VariorumMCPTests` files — plus the kickoff plan, which only the orchestrator's `d7edfea1` touched, VX-330's
  join into U6).
- **Less sure, said plainly:** (1) the description of `save_lens` is long (the rule has several edges and the model needs
  each); U8 may tighten it — the facts it states are pinned by the wire tests; (2) the ambiguity refusal mixes a sentence
  and a line of JSON in one error text — chosen so the retry needs no read, readable by a model and a person alike, but
  it is the first refusal of that shape on the wire; (3) nothing here has met a real client yet (U5b's window).

### OWED (for the orchestrator)

1. **U5b's window runs LIVE LEGS A–C (D optional)** above; U5a's acceptance closes there.
2. **Canon at the merge (proposed, not written):** MCPSpec's THE MCP DOOR line gains a clause — "an AI take's label is
   `‹client›` or `‹client› · ‹label›` (VX-267; earlier takes keep `‹client› · suggested · ‹label›`); `save_lens` fills
   explicitly by `take_ids`, `label` or `pin_chosen: true` (VX-253) — the picks first, a label matching exactly as stored
   plus the client's own suggestions in either form, an unmatched block shown by its chosen take and listed, an
   ambiguous uncovered block refusing the whole call by name, `pin_chosen` her Save Choices as Lens" — with a pointer to
   this record.
3. **QUESTIONS at the merge:** P-VX253-1 and P-VX253-2.
4. **For U8 (docs):** the guide and `MCPSession.instructions` say nothing yet of a label rule or of `save_lens` by label
   (true, but they undersell); the stargazing brief's FURTHER delta should carry both (the label form, `save_lens`' three
   fills).
5. **For U7 (VX-254's sweep table):** `save_lens` writes no take text — no digest owed; `add_take`/`add_takes` write take
   text and keep VX-267's label (their digest row is U7's).

### THE ORCHESTRATOR ON U5a's HAND-BACK (2026-10-14 ~14:05 MDT)

- **Verified, not trusted:** the nine commits `f43cef82`…`590c0cb8` are on the branch and pushed, the tree is clean, and
  no revert is in flight. The diff is wire-only (`Sources/VariorumMCP` plus `Tests/VariorumMCPTests`, 806+/23−). The
  orchestrator re-ran the seven touched and new pin suites headless (`MCPTakeLabelFormServerTests`,
  `MCPLensByLabelServerTests`, `MCPLensRulePlanTests`, `MCPLensDoorsServerTests`, `MCPBatchDoorsServerTests`,
  `MCPWriteServerTests` and their kin) and got 35 tests in 7 suites, green. `aiLabel` reads `<client>` / `<client> · <label>`
  as ruled.
- **P-VX253-1 (a) and P-VX253-2 (a) stand as built**, PROVISIONAL for QUESTIONS at the merge. For (a) of 2: refusing a
  label that matches nowhere follows §12's "a door that did nothing speaks a refusal", and it spares her a lens a suggest
  client can't delete. The per-block ruling is untouched, since a partly-matching label still saves and lists its
  unmatched blocks.
- **The argued items are accepted:** `label` with `pin_chosen` refuses, no fill refuses, `pin_chosen` = Save Choices as
  Lens, the 200 bound with a count, and the refusal names the matching takes.
- **U5a's acceptance closes in U5b's window** (LIVE LEGS A–C, D optional). OWED 2 (the MCPSpec clause) and 3 (QUESTIONS)
  ride the closeout. OWED 4 rides U8's brief, and OWED 5 rides U7's sweep table.
- **VX-330's owed record edits are applied in this commit:** the member list, THE UNITS' U6 row, Her rulings during the
  run, and the U6 BRIEF's item 4 with its walk leg. So is CLAUDE.md's new triage rule for filed tickets (Hard rules).
- **Next:** U5b (a fresh `opus-implementer` at xhigh from the U5b BRIEF), and REQUEST `vx336-u5` to the coordinator.


## U5b UNIT RECORD — the block-writing pair: VX-252 · VX-255, plus U5's shared window (opus-implementer, from 2026-10-14 ~14:15 MDT)

**What this unit has NOT done (said first; updated at every piece):** (1) **the build is in progress** — VX-252 is whole
(pieces 1–3); VX-255 is the SECOND continuation's (pieces 4–8, below): its pins red on old (piece 4), its fix green
(piece 5), red again by revert and restored (piece 6), the headless finals green and the Mac product built (piece 7),
THE STAGE WINDOW written and READY reported (piece 8); (2) **no stage window has run: no Mac batch, no live round, no
capture yet** — U5's acceptance (U5a's included) closes only in that window; (3) the guide and `MCPSession.instructions` untouched (U8's — the
doc-truth sweep below finds nothing false); (4) no `notes/QUESTIONS.md` entry and no canon edit (the merge's). Everything
below "The design" is the ruled plan; a claim is only what a LIVE STATUS row says DONE with its log.

**THE CONTINUATION (pieces 1–8): a FRESH opus-implementer (xhigh), from 2026-10-14 ~14:45 MDT,** built from this record,
the U5b BRIEF and THE ORCHESTRATOR'S RULINGS ON U5b's FORKS alone (the designer retired at ~468k after piece 0). It re-read
the cited code before relying on any line: the design's pointers hold (`perform`'s `createNote` arm 404–415, `noteAnswer`
757–766, `mintDocument` 213–248 keeping only `minted.block.id` at 237, the parse's silence on `section_id` 202–214).

**THE SECOND CONTINUATION (pieces 4–8): a FRESH opus-implementer (xhigh), from 2026-10-14 ~14:37 MDT,** built from THE
CONTINUATION'S BUILD PLAN below, this record's design D4–D10, THE ORCHESTRATOR'S RULINGS ON U5b's FORKS and U5a's LIVE
LEGS; read in its own context: this record (header, Hard rules, LIVE STATUS, Stage traffic log, Cross-run coordination,
the U5b BRIEF, this UNIT RECORD whole, U5a's LIVE LEGS), `notes/MCPSpec.md` whole, VX-246's SWEEP TABLE rows 2–13, its U3
traces and design (`flushesHerEditorFirst`) and its U1b STAGE RUN whole, `notes/SessionResiliencyProtocol.md`'s implementer
rules, and the code the plan names (each pointer re-checked at `41e91f87` before editing: `perform`'s arms, `noteBlocks`
`private` at `MCPWriteTools.swift:252`, `placedBlocks`/`batchCap`/`overCapWords` in `+Batches`, `guardNotes` in `+Edit`,
`containerPosition`'s `.after` → `blockNotPlaced`, `mintFanBlock`, `registerStructuralEntry`/`MintedPreImage`,
`registerTextChange`, `MintedBlockTakes.init(_:shownIndex:)`, `MCPWriteAct`, the app's three `MCPPaneCopy` switches).

**Read in full before code (never delegated):** CLAUDE.md and its loaded canon (AppSpec §9's newBlock, merge, import,
the standing conventions and structural undo; §12's THE MCP DOOR summary); this run record — header, Her kickoff
answers, THE UNITS, Hard rules, LIVE STATUS, Stage traffic log, Cross-run coordination, Her rulings during the run,
the U5a/U5b/U6/U7 BRIEFs, the U5a UNIT RECORD whole and THE ORCHESTRATOR ON U5a's HAND-BACK; the plan
`notes/plans/mcp-pane-and-docs-kickoff.md` whole; `notes/MCPSpec.md` whole; VX-246's record — Hard rules, THE RUN AS IT
MERGES, the U5 BRIEF there, the U2 UNIT RECORD (the quiet-half rule, THE SWEEP TABLE — rows 2–13 `registerStructuralEntry`,
25–34 `registerMintedContainerEntry`, 36 imported paste blocks, 82 `add_note_to_book`), the U3 UNIT RECORD (the act
list, `flushesHerEditorFirst`, the editor's delivery road) and the U1b STAGE RUN whole (the live round's worked form);
`notes/SessionResiliencyProtocol.md` whole; `notes/mcp-agent-notes-2026-10-13-bilingual-book.md` whole (items 1, 4, 10);
the two tickets' bodies (VX-252, VX-255 — read-only, matching the brief's quotes). Code read: `MCPWriteTools.swift` whole
(`parse`, `noteBlocks`, `place`, `parseImport`, `perform`'s `createNote`/`importNote`/`importBook`/`addNoteToBook` arms,
`onNote`, `noteIntoBook`, `into`, `inWing`, `land`, `noteAnswer`, `aiLabel`); `+Batches` whole (the guard pattern for a
new act, `placedBlocksSQL`, `batchCap`, `itemized`); `+Edit` whole (`move_block`'s anchors and `at`, `guardEdit` /
`guardNotes` / `guardBook`); `MCPWriteSupport` whole (`MCPWriteReceipt`, `MCPHostHooks`, `MCPWireRefusalCopy`);
`MCPToolCatalog` (the rungs' lists; `create_note`, `import_document`, `add_note_to_book`, `create_section`, `move_block`,
`add_takes` declarations); `MCPGrantAuthority`'s `MCPRefusalCopy` / `MCPAsking`; `MCPNoteStructure.read` (read_note's
with-ids record — the vocabulary an answer should share); `MCPSession.instructions`; core `Operations+MCPWrites` whole
(`createNote`, `createStructuredNote`, `importNote`, `mintNoteEntry`, `addNoteToBook`, `MCPWriteAct`),
`Operations+DocumentImport` whole (`mintDocument`, `DocumentImport`, `importBook`), `Operations+Block.newBlock`,
`Operations+Import` whole (`importBlocks` — paste into an existing note, its parts entry), `Operations+MCPBatches` whole,
`Operations.swift` (`InsertPosition`, `listPosition` / `containerPosition`, the seal guards), `mintBlock` /
`mintFanBlock`, `registerStructuralEntry` / `revertStructural` / `reapplyStructural`, `registerMintedContainerEntry` /
`revertMintedContainer`, `Operations+Sections` (`assignSectionRow`, `liveSection`), `Operations+Reading`
(`addPostToReading`, her `newPostInReading` — New Note in a Book with a chapter); the app's `MCPPaneCopy` Activity table
and `MCPReceiptCopy.phrase` (the one exhaustive switch over `MCPWriteAct` in the app); read-only for D8's argument: the
crystallizer's mint (`TailCrystallizer.mintBlocks` — `newBlock(at: .end)`) and `EditorProjectionPolicy.decide`
(`Shared/EditorBrain` — READ ONLY, no line changes). Tests read: the harness (`MCPServerTests.ServerHarness`), the catalog
pins (`MCPServerTests.everyDeclaredTool…`), the suggest proof (`MCPWriteServerTests.aSuggestGrantProvablyCannot…` — it
calls every declared tool), the create/import pins (`MCPEditServerTests` structured create + format v2,
`MCPLensDoorsServerTests` blank takes), the app's every-tool walks (`MCPWingFacesTests.activitySpeaksEveryAct…`, the
hers-alone name sweeps), `MCPWireNeutralityTests` / `MCPProviderNeutralityTests` (no pronoun, no provider in any literal).

**Surfaces (planned — final list at READY):** wire `Sources/VariorumMCP/{MCPWriteTools.swift, MCPToolCatalog.swift}`, a
NEW `MCPWriteTools+InsertBlocks.swift` (the parse, the rung, the anchor check, the arm), a NEW `MCPMintedBlocks.swift`
(THE shared answer encoder); core `Operations+DocumentImport.swift` (`MintedDocument`/`DocumentImport` carry what was
minted per block), `Operations+MCPWrites.swift` (`createNote`/`createStructuredNote` take `section`; a NEW
`MCPWriteAct.blocks`), a NEW `Operations+MCPInsertBlocks.swift` (the act); app
`App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift` (Activity words + the receipt phrase for `.blocks` — the
exhaustive switch makes it compulsory); tests. ZERO `Sync/`, custody, schema, `Server/`, editor seam, `TutorialSeeder`.
An app file moves ⇒ a Mac `build-for-testing` (into `App/Variorum/DerivedData/vx336-u5`) and the Mac batch in the window.

### LIVE STATUS — U5b's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | this record + LIVE STATUS + the traces and the design; the FORKS proposed for the orchestrator's ruling | DONE (this commit) — **STOPPED here for the ruling** (FORKS F-1…F-6 below) |
| 1 | VX-252 — the pins on the OLD tree (wire: `create_note` + single `import_document` answer per-block take records; `section_id` files in the same call, its refusals; the book form a guard), RED | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPMintedAnswerServerTests.swift`, 5 tests, wire only: `createNoteAnswersEveryBlocksTakesInFanOrderWithTheShownOne` (structured + prose payloads: the answer's `blocks` == `read_note with_ids`' block id, shown take and every take with its label in fan order — a blank take listed; `block_ids` kept, F-6) · `importDocumentAnswersTheSameRecordsForOneDocumentAndABookKeepsItsAnswer` (an exported document with an Alternates section; the BOOK form's keys exactly `book_id`/`note_ids`/`chapter_ids` — F-2's GUARD) · `sectionIDFilesTheNewNoteUnderItsChapterInTheSameCallAndTheSameUndo` (filed, echoed, ONE `claude-code's note` entry, ⌥⌘Z then ⇧⌥⌘Z returns it filed) · `everySectionIDThatIsntALiveChapterOfTheBookAnswersOneSentenceAndMintsNothing` (nothing · a deleted chapter · a READABLE book's · a HIDDEN book's → one sentence, nothing minted; `section_id` with `wing_id` or with no place → the parse sentence) · `anUnreachableBookAnswersTheOneNotSharedSentenceWithOrWithoutASection` (THE GUARD, F-3). **RED on the old tree (`f50c77e6`'s sources): 4 of 5 failed, 15 issues, each on its designed line, no premise line** — no `blocks` in either answer (`:119`, `:133`, `:167`); the note landed UNSECTIONED with no echo (`:204`, `:205`, `:212`); all four bad chapters LANDED (`:241` ×4, `:244`, `:246`) and the parse sentence never spoken (`:255` ×2, `:258`); **the guard green, by design** (log `notes/plans/vx336-screens/u5b/logs/p1-pins-red.log`, gitignored) |
| 2 | VX-252 — the fix (core: what was minted rides `DocumentImport`; `section`; wire: `MCPMintedBlocks`, `noteAnswer`, the parse + catalog) + any justified edits, GREEN | DONE (this commit) — **core:** `Operations+DocumentImport.swift` — NEW public `MintedBlockTakes {blockID, shownTakeID, takes: [MintedTake {id, label}]}` built from `mintFanBlock`'s own returned variants (no read), carried `MintedDocument.blocks` → `DocumentImport.blocks` (both doors: the file import and the wire's notes); `Operations+MCPWrites.swift` — `createNote` / `createStructuredNote` take `section: String? = nil`, threaded into `mintNoteEntry`: on a BOOK destination, after its live/kind/finished gates and BEFORE the mint, `liveSection` + `readingId == book` (`sectionNotFound` / `sectionNotInReading`); on a wing destination any section refuses `sectionNotFound` (a wing holds no chapter — the wire never reaches it); the pointer set on the membership `addPostToReading` wrote, same transaction; the ONE `registerMintedContainerEntry` entry unchanged (the membership dies and revives on the note's stamp, its chapter with it). **wire:** NEW `Sources/VariorumMCP/MCPMintedBlocks.swift` — THE encoder (`records(_:)`, D1 as confirmed); `MCPWriteTools.swift` — `Job.createNote` carries `sectionID`; the parse refuses `section_id` without `book_id` (`sectionWithoutBookWords`, before any decision); the arm passes the section; `noteAnswer` answers `blocks` beside `block_ids`/`tag_ids` (+ `section_id` when given) — so the single `import_document` closes too (D3); the book form's arm untouched (F-2). `MCPToolCatalog.swift` — `create_note` gains `section_id` and its description the records' and the chapter's sentences; `import_document`'s description says one document answers `blocks` and a book its three id lists. **The order note (recorded, not a fork):** her New Note in a Book checks capacity before the chapter; here the chapter is checked before the mint and capacity inside the hand-add after it — both refusals mint nothing (one transaction); a FULL book with a bad chapter hears the chapter sentence first. **NEW-API PINS (green by construction, state):** `Tests/VariorumCoreTests/MCPMintedBlocksActsTests.swift` (3 — the record is the fan row for row; the filing and its undo/redo; every non-chapter refuses before a row). **GREEN:** the pins 5/5 + the core file 3/3 (`p2-pins-green.log`); the whole MCP target **256 / 55**, EXIT 0, zero ✘ (= U5a's 251/54 + these 5/1; every existing pin UNMODIFIED — no justified edit needed) (`p2-mcp-target.log`) |
| 3 | VX-252 — red again BY REVERT (announced first, committed tree, restored, verified) | DONE (announced `50fb1564`, recorded in this commit) — on the committed tree `50fb1564`: the four fix files back to the pins commit `3ccfaa12` (`git checkout 3ccfaa12 -- …`), `MCPMintedBlocks.swift` and the new-API `MCPMintedBlocksActsTests.swift` moved aside to `notes/plans/vx336-screens/u5b/prerevert-252/` (`git diff HEAD --stat`: those six, +18/−240) → **RED again: 4 of 5 failed, 15 issues, the test × line set IDENTICAL to piece 1's** (15 pairs, `diff` empty — `p1-pins-red.pairs` vs `p3-revert-red.pairs`); the guard green as before (`p3-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/ Tests/`, the aside folder removed, `git status` clean, `git diff HEAD` empty → **8/8 green** across the two suites (`p3-restored.log`) |
| 4 | VX-255 — the pins on the OLD tree (wire: end at write new, anchor/start refused at write new with the rungTooLow family, anywhere at edit, one undo walks it back whole and redo returns it, a sealed note refuses, anchor of another note refused alike, the fence), RED by absence | DONE (this commit) — NEW `Tests/VariorumMCPTests/MCPInsertBlocksServerTests.swift`, 8 tests in 2 suites, wire only (`MCPWriteAct.blocks` is read as `act.rawValue == "blocks"`, the anchor sentence as a literal, so the file compiles on the old tree): 1 `writeNewAddsTheBlocksAtTheNotesEndInOrderAndOneUndoWalksThemBack` (three blocks — a fan with a labelled and a blank take, a named one, an empty one — after her three, in order; the answer's `blocks` == `read_note with_ids`' last three records, `block_ids`; labels as given; the name; ONE `claude-code's blocks`; the receipt `blocks` ×3, Open › the first new block; `last_touched_at` moved; ⌥⌘Z → all three dead, none trayed, her three untouched; ⇧⌥⌘Z → the same ids in place; `at: "end"` the same) · 2 `writeNewWithAnyAnchorHearsTheRungsSentenceAndAsksHerForEdit` (her LAST block as anchor, and `at: "start"` → the rungTooLow sentence + asked, her ask at edit on the note, nothing minted) · 3 `editAddsTheBlocksRightAfterAnyBlockOrAtTheStart` · 4 `anAnchorThatIsntABlockOfThisNoteAnswersOneSentenceAndMintsNothing` (a readable note's block and `no-such-block`, byte-identical) · 5 `malformedCallsAreRefusedAtTheParseNamingWhatIsWrong` (8 forms — both anchors, also on a note that doesn't exist; `at: "middle"`; an empty `after_block_id`; no `blocks`; `[]`; 201; a block without text) · 6 `aSealedNoteRefusesAndALockedTakeAtTheAnchorNeverDoes` · 7 `anUnreachableNoteAnswersTheOneNotSharedSentenceWhateverTheCallNames` · 8 `MCPInsertBlocksHerEditorTests.herTypingInTheBlockItLandsAfterIsNeverFlushedOrMoved` (D8; `HerOpenEditor` + `TurnLogExecutor` copied). **RED on the old tree (`41e91f87`'s sources): 8 of 8 failed, 26 issues, 17 distinct test × line pairs** — every call answered `Unknown tool: insert_blocks.` (30 times in the log); each red sits on its designed line: an answer `isError` (`:133`, `:239`, `:345`, `:475`, `:489`), its JSON (three "Caught error … Code=3840" at the `@Test` lines `:107`, `:225`, `:322` — `json(…)` of the absent tool's text throws inside the shared helper, the answer's own line), the sentences (`:213` ×2, `:275`, `:313` ×8, `:338`, `:381`), the ask (`:215` ×2), the turn log (`:474` — `[]`, the parse refused before any turn), the landings (`:479`, `:493`); **no premise line.** **On the plan's "7 and 8 green on both sides":** an ABSENT tool cannot be green on its own answer, so cases 7 and 8 each carry GUARD lines that held on the old tree, exactly as designed — 7's byte-identity across the three forms (`Set(said).count == 1`) and nothing minted; 8's no flush asked (`:473`, `:488`) and her words where she typed them (`:477`, `:491`) — beside the lines that need the tool (7's sentence `:381`; 8's turn log and landings). Recorded, not a contradiction (no decision needed). Log `notes/plans/vx336-screens/u5b/logs/p4-pins-red.log` + `p4-pins-red.pairs` (gitignored) |
| 5 | VX-255 — the fix (the act, the wire, the catalog, `MCPWriteAct.blocks`, the app's words) + justified edits (the catalog set, the suggest proof), GREEN | DONE (this commit) — **core:** NEW `Sources/VariorumCore/Operations/Operations+MCPInsertBlocks.swift` — `insertBlocks(_:intoNote:at:undoLabel:guardedBy:) -> [MintedBlockTakes]` exactly as the build plan: `emptyImport` on `[]`; ONE `database.write` — the guard FIRST, `livePost` + `ensureUnlocked` (a sealed post refuses; no take touched, so a locked take never does), one clock read, per block `containerPosition` (`.after` re-resolved in the transaction → `blockNotPlaced`), `mintFanBlock(texts: [text] + takes, defaultIndex: 0, chosenIndex: 0, labels: [nil] + labels)` (blank takes kept), the trimmed non-empty name (`createStructuredNote`'s finish), `registerTextChange(charDelta: text.count)` (newBlock's stamp rule), `at = .after(this block)`; after the write ONE `registerStructuralEntry(label:, minting: [MintedPreImage])` (newBlock's helper — the SWEEP TABLE rows 2–13's road; each half answers `!changed.isEmpty`). `Operations+MCPWrites.swift` — `MCPWriteAct` gains `case blocks` (raw `"blocks"` → "claude-code's blocks"; `isUndoable` true) beside `takes, comments`. **wire:** NEW `Sources/VariorumMCP/MCPWriteTools+InsertBlocks.swift` — `BlockInsertPlace {end, start, after}` (`rung`: end → write new, start/after → edit; `insert`), `anchorNotThisNotesWords`, `parseInsertBlocks` (note_id; an empty `after_block_id`; `at`'s value; both; `blocks` required / an array / non-empty / ≤ `batchCap` with `overCapWords`; then `noteBlocks`), `performInsertBlocks` (`onNote` at the call's rung, `spendsAfter: false`; the anchor checked AFTER the decision by `placedBlocks` (∝ one id); the act guarded by `guardNotes` at the same rung; a `blockNotPlaced` naming the anchor → the same sentence; the answer `{note_id, block_ids, blocks}` (VX-252's records); the receipt `.blocks`, `count`, Open › the first new block). `MCPWriteTools.swift` — `noteBlocks` no longer `private`; `Job.insertBlocks(noteID:place:blocks:)`, tool `insert_blocks`, `flushesHerEditorFirst` **false** with D8's reason at the arm; `parse` and `perform` route it. `MCPToolCatalog.swift` — `insertBlocks` (write new, everyScope; schema `note_id`, `after_block_id`, `at` enum, `blocks` minItems 1 / maxItems `batchCap`, create_note's block item copied; the description says the end at write new, any anchor or the start at edit, one block per item with a blank line inside, takes unchosen with labels as given and a blank take legal, at most 200, one undo, the answer as create_note's — no pronoun), joining `writeNew` after `linkVersions`. **app:** `MCPPaneCopy.swift` — `refusedPhrase` "adding blocks to ‹X›", `activityPhrase` "added blocks to ‹X›" + times (one row per call), the receipt `phrase` `.blocks` summed like `.takes` ("added a block" / "added N blocks") — the ONE exhaustive switch over `MCPWriteAct` in the app (grep: no other). **JUSTIFIED EDITS (the ritual comment in place):** `MCPServerTests.everyDeclaredToolIsHandledAndEveryHandledToolDeclared` (the write-new set gains `insert_blocks`); `MCPWriteServerTests.aSuggestGrantProvablyCannotModifyAnExistingTake` (two calls appended — at her note's end, and after her block — each refusing at the rung; the completeness line now sees the tool). The grep for other exact tool sets in the MCP and Mac tests found none (`MCPToolFacts.toolNames` is derived from the catalog; `activitySpeaksEveryActInWordsNeverAToolID` walks it and now meets real words). **NEW-API core pins (green by construction):** `Tests/VariorumCoreTests/MCPInsertBlocksActsTests.swift`, 4 tests — the run's order at end / start / after; born as given (one block with a blank line inside, the fan and labels, chosen AND default, none locked, the trimmed name, a blank name none, the touch); the ONE entry (untouched → gone, no `last_container_id`; the exact-id redo; a block she typed into → TRAYED, its sibling gone); the refusals (`emptyImport`, an anchor of another note and a dead one → `blockNotPlaced`, a locked anchor take lands, a sealed note → `lockedPost`, nothing minted). **GREEN:** the pins 8/8 (2 suites) + the core file 4/4 (`p5-pins-green.log`); the whole MCP target **264 / 57**, EXIT 0, zero ✘ (= 256/55 + this unit's 8/2) (`p5-mcp-target.log`). No warning in a touched file. **The VX-255 revert check is ANNOUNCED here (piece 6 runs it on this commit's tree).** |
| 6 | VX-255 — red again BY REVERT | DONE (announced `3e9f625d`, recorded in this commit) — on the committed tree `3e9f625d`: the three package source files back to the pins commit `7a15376c` (`git checkout 7a15376c -- Operations+MCPWrites.swift MCPToolCatalog.swift MCPWriteTools.swift`), the three NEW files (`Operations+MCPInsertBlocks.swift`, `MCPWriteTools+InsertBlocks.swift`, `MCPInsertBlocksActsTests.swift`) moved aside to `notes/plans/vx336-screens/u5b/prerevert-255/` (`git diff HEAD --stat`: those six, +2/−432); the two justified edits KEPT (they assert the new tool); `MCPPaneCopy.swift` is app-only (outside `swift test`) → **RED again: 10 tests in 4 suites failed, 28 issues** — the 8 pins' **26 issues, the test × line set IDENTICAL to piece 4's** (26 pairs, `diff p4-pins-red.pairs p6-revert-red.pairs` empty), and each justified edit red on its edited line (`MCPServerTests.swift:257` the write-new set; `MCPWriteServerTests.swift:334` the completeness line) (`p6-revert-red.log`). **RESTORED:** `git checkout HEAD -- Sources/ Tests/`, the aside folder removed, `git status` clean, `git diff HEAD` empty → **14/14 green** (the 10 + the core file's 4) (`p6-restored.log`) |
*[removed for publication]*
| 8 | THE STAGE WINDOW plan (claim `vx336-u5`; Mac batch; the live round incl. U5a's LEGS A–C, D optional; A1 + restore; fingerprint) → READY | DONE (this commit) — **THE STAGE WINDOW** below the build plan (steps 0–13: guards; the 31-suite Mac batch FIRST, then the SEAM; A1 + prefs + the fingerprint, its one-liner reproducing VX-246's `bc64543e2f4e8e58`; the tab key into a scratch `--mcp-config`, never her user scope; V252-a, V255-a/b/c, D8-a/b, U5a's LEGS A–C (D optional), the Terminal pass; cleanup to cmp SAME, prefs 0 differ, fingerprint SAME). **~95 minutes of work, a 110-minute claim; batch-only fallback ~15 (claim 20).** **READY reported; the stage is NOT claimed** (the orchestrator relays the coordinator's GO and its exact claim line) |

**No revert is in flight** (pieces 3 and 6 ran and RESTORED — `git status` clean, `git diff HEAD` empty).

**THE SEAM (2026-10-14 ~15:05 MDT): this continuation STOPPED here, after piece 3, at ~500k context** (the brief's rule:
past ~500k, stop at the next clean seam — committed, green, the continuation written). VX-252 is whole (pins red-first,
red again by revert, green; the MCP target 256/55; at the seam the core and workbook targets ran too, `swift test
--skip-build` on `0ca63296`'s sources: **`VariorumCoreTests` 2,863 / 331 · `StringsWorkbookTests` 40 / 6**, EXIT 0, zero ✘
— U5a's 2,860/330 + `MCPMintedBlocksActsTests` 3/1; the counts include the standing gated skips — log
`p3-seam-core.log`). **Pieces 4–8 go to a FRESH implementer**, who builds from THE
CONTINUATION'S BUILD PLAN below (no design latitude left; every line pointer re-verified at `50fb1564`).

### THE CONTINUATION'S BUILD PLAN — pieces 4–8 (written at the seam; the rulings applied to code)

**Piece 4 — VX-255's pins on the OLD tree** (wire only, so they compile there; red by ABSENCE — the old tree answers
`Unknown tool: insert_blocks.`). NEW `Tests/VariorumMCPTests/MCPInsertBlocksServerTests.swift`, the pattern of
`MCPMintedAnswerServerTests` (`ServerHarness`, `h.connect(as: "claude-code")`, `h.approve`, `json`/`text`; seed blocks with
`newBlock(…, registeringUndo: false)`). The cases:
1. **write new, at the end:** a note of three blocks in a book; `writeNew` on the book; `insert_blocks(note_id, blocks:
   [{text, takes: [{text, label}]}, {text, name}, {text: ""}])` with no anchor → lands AFTER the last block, in the given
   order (`Queries.renderedText` or the placements' order); the answer's `blocks` == `read_note with_ids`' records for the
   new blocks (reuse `BlockRecord` — copy it, it is `private`) and `block_ids` their ids; labels stored as given (never
   `aiLabel`'s prefix — VX-197's split), the blank take kept, the name set; ONE entry `claude-code's blocks`; ⌥⌘Z
   (`h.undoStack.undo(with: h.writeOperations)`) → every new block dead, her three untouched; ⇧⌥⌘Z → the SAME ids back,
   in place; the receipt `.blocks` with `count` = 3 and `show` = `.note(noteID:, blockID: <first new>, select: nil)`;
   the container's `last_touched_at` moved. `at: "end"` spells the same.
2. **write new with ANY anchor refuses** (F-1 (a)): `after_block_id` = her LAST block, and separately `at: "start"` →
   `isError`, the text is `MCPRefusalCopy.words(.rungTooLow(granted: .writeNew), .note, asked: true)` ("This client may
   only read, suggest and write new here. Variorum has asked the author — call again once they answer."), NEVER the
   not-shared shape; `h.asks` gained an ask at `.edit` on the note; nothing minted, depth unchanged.
3. **edit, anywhere:** `edit` on the book → `after_block_id` = her FIRST block with two blocks → they sit between her 1st
   and 2nd, in order; `at: "start"` → before her first.
4. **the anchor's one sentence:** at edit, `after_block_id` = a block of ANOTHER readable note, and = `"no-such-block"` →
   both `isError`, byte-identical: `after_block_id isn't a block of this note — read_note with with_ids: true gives its
   block ids.`; nothing minted.
5. **parse refusals** (before any decision): `after_block_id` + `at` → `Pass after_block_id or at, not both.`; `at:
   "middle"` → `at must be "start" or "end".`; `blocks: []` → `blocks must list at least one block.`; 201 blocks →
   `insert_blocks takes at most 200 blocks in one call; this call has 201. Split it into calls of 200 or fewer.`
   (`overCapWords`); a block without text → `blocks[0] needs a text.` (`noteBlocks`' own words); nothing minted.
6. **a sealed note refuses** (her `lockPost`) → `isError` (the harness's `Refused: …lockedPost…`), nothing minted;
   **a locked take at the anchor never refuses** (her `lockVariant` on the anchor's take, edit rung, `after_block_id` it
   → lands).
7. **THE FENCE (a guard, green on both sides):** an unreachable note → the ONE not-shared sentence, byte-identical with
   no anchor, with an anchor, with a malformed-but-parseable block list; the anchor never looked at.
8. **D8's characterization (green on both sides by design):** the `MCPHerEditorServerTests` world (copy its
   `HerOpenEditor` + `TurnLogExecutor` + hooks into this file — they are `private`): she types in the take of the block
   `insert_blocks` lands after; the call's turn log is `["act"]` (NO `flush:`); her `flush()` after the act lands her
   words in that take, the new blocks below it.
**Run** `swift build --build-tests` then `swift test --skip-build --filter MCPInsertBlocksServerTests` →
`notes/plans/vx336-screens/u5b/logs/p4-pins-red.log`; expect every case but 7 and 8 RED on its designed line (no premise
line), record the counts, commit (the record row + the file), push.

**Piece 5 — the fix.**
- **Core, NEW `Sources/VariorumCore/Operations/Operations+MCPInsertBlocks.swift`:**
  `@discardableResult public func insertBlocks(_ blocks: [MCPNoteBlock], intoNote noteID: String, at insert:
  InsertPosition, undoLabel: String, guardedBy guardian: WriteGuard? = nil) throws -> [MintedBlockTakes]` —
  `guard !blocks.isEmpty else { throw OperationError.emptyImport }`; ONE `database.write`: `try guardian?(db)` FIRST;
  `let post = try livePost(db, noteID)`; `try ensureUnlocked(post)` (a sealed post refuses; a locked TAKE never does — no
  take is touched); `let now = date.now` (one clock read); `var at = insert`; per block: `let position = try
  containerPosition(db, containerID: noteID, at: at)` (`.after(anchor)` throws `blockNotPlaced(id:)` when the anchor is
  not live-placed in THIS note — the in-transaction re-resolution), `let fan = try mintFanBlock(db, texts: [block.text] +
  block.takes.map(\.text), in: noteID, position: position, defaultIndex: 0, chosenIndex: 0, labels: [nil] +
  block.takes.map(\.label), now: now)` (blank takes KEPT — R-VX171-2; no take born locked or chosen but the shown one),
  the block's name (`createStructuredNote`'s finish: trimmed, non-empty → `UPDATE block SET name = ? WHERE id = ?`),
  `try registerTextChange(db, blockID: fan.block.id, charDelta: block.text.count, forceMajorRevision: false, now: now)`
  (newBlock's stamp rule, per block — `importBlocks`' `mintSegments` precedent), `at = .after(fan.block.id)` (the run
  keeps its order). After the write: `registerStructuralEntry(label: undoLabel, minting: minted.map {
  MintedPreImage($0.block.id, $0.variants) })` (newBlock's helper — untouched vanish, edited tray, a sealed note refuses
  the undo and keeps the entry; each half's `!changed.isEmpty` answers U2's question); return
  `minted.map { MintedBlockTakes($0) }`. **`MCPWriteAct`** (`Operations+MCPWrites.swift`): add `case blocks` (raw
  `"blocks"` → "claude-code's blocks"; `isUndoable` true) beside `takes, comments`, with a `// VX-336 U5b — VX-255` line.
- **Wire, NEW `Sources/VariorumMCP/MCPWriteTools+InsertBlocks.swift`:** `enum BlockInsertPlace { case end, start,
  after(String) }` with `var rung: MCPGrantRule.Rung` (`.end` → `.writeNew`; `.start`, `.after` → `.edit` — F-1 (a),
  F-1b (a)) and `var insert: Operations.InsertPosition`; `func parseInsertBlocks(_ args:) throws -> Job` (note_id
  required; `after_block_id` optional, an empty one refused `after_block_id must be a block id.`; `at` optional, `"start"`
  / `"end"` else `at must be "start" or "end".`; both → `Pass after_block_id or at, not both.`; `blocks` present (`blocks
  is required.`), an array, non-empty (`blocks must list at least one block.`), `≤ batchCap` (`overCapWords(tool:
  "insert_blocks", noun: "blocks", count:)`), then `noteBlocks(value)` — **drop `private` from `noteBlocks` in
  `MCPWriteTools.swift`** so this file can call create_note's one block parse); `func performInsertBlocks(…)`:
  `onNote(noteID, rung: place.rung, job:, clientName:, spendsAfter: false) { title in … }` (the snapshot speaks the
  rungTooLow family + the ask, or the one not-shared shape); inside, for `.after(anchor)`: `Self.placedBlocks(db, among:
  [anchor], in: noteID)` (+Batches' P1 read) else `ArgumentFailure(Self.anchorNotThisNotesWords)`; then
  `ops.insertBlocks(blocks, intoNote: noteID, at: place.insert, undoLabel: label(.blocks), guardedBy: guardNotes(
  clientName, rung: place.rung) { _ in [noteID] })`, catching `OperationError.blockNotPlaced(let id)` where `id ==
  anchor` → the same `ArgumentFailure` (a block that left between the look and the act); answer `["note_id", "block_ids":
  minted.map(\.blockID), "blocks": MCPMintedBlocks.records(minted)]`; receipt `MCPWriteReceipt(clientName:, act:
  .blocks, targetID: noteID, targetTitle: title, count: minted.count, show: .note(noteID: noteID, blockID:
  minted.first?.blockID, select: nil))`. **`MCPWriteTools.swift`:** `Job` gains `case insertBlocks(noteID: String, place:
  BlockInsertPlace, blocks: [Operations.MCPNoteBlock])` — `tool` `"insert_blocks"`, `flushesHerEditorFirst` **false**
  with D8's reason at the arm ("adds blocks; no take's text is read, rewritten, copied, frozen or tombstoned — her caret's
  block survives and her tail stays below, D8"); `parse` routes `MCPToolCatalog.insertBlocks.name`; `perform` routes the
  case. **`MCPToolCatalog.swift`:** `static let insertBlocks` (`rung: .writeNew`, title "Add blocks to a note", scopes
  `everyScope`; schema: `note_id` (required), `after_block_id`, `at` enum start/end, `blocks` (required; `minItems` 1,
  `maxItems` `.int(MCPWriteTools.batchCap)`, items = create_note's block item schema — copy it); the description says:
  appends at the note's END with write new; `after_block_id` (any block, the last included) or `at: "start"` needs EDIT;
  each block exactly one block (a blank line stays inside), its takes unchosen with labels as given, a blank take legal;
  at most 200 blocks a call; one undo for the author; answers `block_ids` and `blocks` as create_note does — NO pronoun
  (`MCPWireNeutralityTests` sweeps every literal in the target), and joins `writeNew` after `linkVersions` with a
  `// VX-336 U5b — VX-255` comment.
- **App `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift`** (the exhaustive receipt switch makes it compulsory):
  `refusedPhrase` `case "insert_blocks": return "adding blocks to \(at)"`; `activityPhrase` `case "insert_blocks": return
  "added blocks to \(at)" + times` (one log row per CALL, the batches' rule); the receipt `phrase` `case .blocks:` summed
  like `.takes` — `total == 1 ? "added a block" : "added \(total) blocks"`.
- **JUSTIFIED EDITS (the ritual comment in place):** `MCPServerTests.everyDeclaredToolIsHandledAndEveryHandledToolDeclared`
  (the writeNew set gains `"insert_blocks"`); `MCPWriteServerTests.aSuggestGrantProvablyCannotModifyAnExistingTake`
  (append `("insert_blocks", ["note_id": .string(note.id), "blocks": .array([.object(["text": .string("x")])])])` and an
  anchored one `after_block_id: one.block.id` — each refusing at the rung; the snapshot already covers blocks and
  placements). Grep the MCP tests for any other exact tool set before the run.
- **NEW-API core pins** (green by construction): `Tests/VariorumCoreTests/MCPInsertBlocksActsTests.swift` — positions at
  end / start / after with the run's order; the fan, labels, names, blank takes; touch; the entry's undo (untouched →
  gone, no `last_container_id`; an edited one → trayed) and exact-id redo; a sealed post refuses; a dead anchor →
  `blockNotPlaced`; empty → `emptyImport`.
- **GREEN:** the pins + the core file; the whole MCP target (expect 256/55 + piece 4's tests/1 suite).

**Piece 6 — red again BY REVERT:** announce in the record + commit FIRST; revert the four touched source files to the
piece-4 commit, move the three NEW files (`Operations+MCPInsertBlocks.swift`, `MCPWriteTools+InsertBlocks.swift`, the
core test file) and the two justified edits' files back or aside (the justified edits assert the new tool; on the
reverted tree they are red too — record them like U5a piece 3 did), `MCPPaneCopy.swift` is app-only (not in `swift
test`); diff the test × line pairs against piece 4's; restore with `git checkout HEAD -- Sources/ Tests/`, verify clean.

**Piece 7 — headless finals + the Mac build:** `swift test --skip-build` whole package (MCP · core · workbook, counts
vs U5a's 251/54 · 2,860/330 · 40/6 plus this unit's); then `xcodebuild -scheme Variorum -destination 'platform=macOS'
-derivedDataPath App/Variorum/DerivedData/vx336-u5 build-for-testing` from `App/Variorum/` (an app file moved:
`MCPPaneCopy.swift`; check free disk first; no warning in a touched file). NO `xcodebuild test`.

**Piece 8 — THE STAGE WINDOW plan (claim `vx336-u5`) → READY.** Its parts are the brief's list (the run record's U5b
BRIEF and the continuation's own brief): the Mac batch over every changed source file's suites (grep
`App/Variorum/VariorumTests` for `MCPPaneCopy`, `MCPReceiptCopy`, `MCPWriteAct`, `MCPToolFacts`, `activityLine`,
`DocumentImport`, `createNote`, `createStructuredNote`, `importDocument`); the SEAM ping after the batch and before the A1
copy; the A1 prestage copy and a cmp-verified restore (`Tools/ScaleFixture/restore.sh`); her user-scope MCP servers
fingerprinted before and after (the VX-246 U1b form: names + the sha256 prefix of the sorted compact `mcpServers` JSON —
last read `['linear-server', 'variorum']`, `bc64543e2f4e8e58`); prefs exported, re-imported, re-exported and diffed (0
differ); the strict instance guard (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"`); both voices for the captures;
the client connected by the Claude Code TAB key registered `-s local` in a scratch project (or a scratch
`--mcp-config` JSON, `claude -p --strict-mcp-config`), with grant `claude-code` ▸ Change… ▸ a wing · Home · Edit ·
Always — and a WRITE-NEW grant for the insert legs that need it (Change… to Write new on the note's book, then back to
Edit). **The legs:** (V252-a) `create_note` structured with takes into a book, filed by `section_id` into a chapter made
by `create_section` — the answer's `blocks` read against `read_note with_ids` in the same turn, the note under its chapter
in the Book Panel / Index (capture); (V255-a) at WRITE NEW `insert_blocks` at the end → lands, ⌥⌘Z in the app walks it
back whole, ⇧⌥⌘Z returns it (captures); (V255-b) at write new with `after_block_id` → the rungTooLow sentence and her
Waiting ask (capture the ask), nothing minted; (V255-c) at EDIT `after_block_id` mid-note and `at: "start"` → land where
named (capture); (D8-leg, the rulings' added leg) her caret typing at a note's end in Write while one `claude -p` turn
calls `insert_blocks` at its end → the AI's run lands BELOW her typing tail and her tail crystallizes after it (capture
before/after); then U5a's LIVE LEGS A–C (D optional) exactly as its record writes them (the fixture "vx336 u5a" through
her quick entry; leg A the label `claude-code · english` in Takes, both voices; leg B the ambiguity refusal and its
`take_ids` retry; leg C the legacy form). Minutes: estimate per leg (~100 of work, the U1b window's shape) and a
batch-only fallback. Then build the products, report **READY**, end the turn.

### THE STAGE WINDOW — the plan (runs ONLY on the orchestrator's GO, under the exact claim line it relays — expected `vx336-u5`)

**What this window does NOT do (said first):** no product code is written or changed, before the claim or under it — a
red that needs code is RECORDED and REPORTED, never fixed here (U5a's rule: "a red here is a finding, never a fix under
the claim"); no rebuild (if `git diff --name-only c9c7f637..HEAD -- Sources App Package.swift` is not empty at the GO, or
the coordinator says VX-306 has merged and main must come in first: STOP before any launch and report — the rebuild is an
implementer's); no canon, QUESTIONS or ticket edits; never her real store, never `/Applications/Variorum.app`, never her
USER-scope MCP registrations (no copied setup line is ever run as copied — only its key is taken).

**The products (built at piece 7, READY):** `App/Variorum/DerivedData/vx336-u5/Build/Products/` from `c9c7f637`'s
sources — **TEST BUILD SUCCEEDED, XCB-EXIT 0**, no warning in a touched file (`u5b/logs/mac-build-for-testing.log`): the
*[removed for publication]*
`Debug/Variorum.app/Contents/MacOS/variorum-mcp`, the test bundle and `Variorum_Variorum_macosx27.0-arm64.xctestrun`. The
product carries U5a's and U5b's sources (`MCPWriteTools+InsertBlocks`, the receipt's `.blocks`, the Activity words — read
from the dylib's strings at READY).

**Minutes:** the batch ~10 · SEAM · A1 + prefs + fingerprint ~4 · launch, connect and grant ~5 · the fixture book ~2 ·
V252-a ~6 · V255-a ~8 · V255-b ~5 · the re-grant ~2 · V255-c ~5 · D8 ~10 · U5a's LIVE LEGS A–C ~17 (D +3) · the Terminal
pass ~10 · cleanup ~8 → **~95 of work; ask a 110-minute claim.** **Batch-only fallback (~15 min, claim 20):** steps 0, 1,
the SEAM and 13's quit/prefs/release (nothing launched by the window, so no A1 is needed — U1b's precedent) — U5's
acceptance then stays OPEN for every live leg.

**Evidence:** `notes/plans/vx336-screens/u5/` (gitignored): `logs/`, the turn answers `<leg>.json`, captures `live/s/`
(Study) and `live/t/` (Terminal). Keys redacted to their first 9 characters in every record and capture name.

0. **Guards, every step.** `Tools/WalkKit/guard.sh --author` before anything touches the GUI (her `/Applications/Variorum.app`
   absent — exit 3 ⇒ STOP, never quit or kill it; exit 4 ⇒ someone at the machine, STOP); the STRICT instance guard,
   `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`, both empty before the launch (the loose `-f
   "Variorum.app/Contents/MacOS"` matches another session's headless xcodebuild — and `Tools/ScaleFixture/restore.sh`
   uses that loose form inside, so if it STOPs with exit 3 on a stranger's xcodebuild line, wait for that build to end;
   never edit the script); then the claim line EXACTLY as the GO relays it; `Tools/stage status` never inside an `&&`
   chain (it exits 1 while a claim is held); `guard.sh <devpid> x y` before each click; ≥ 2.6 s between synthetic events;
   region captures; HEAD at the GO recorded.
1. **The Mac batch (~10 min) — FIRST, before the A1 copy** (the Hard rules' SEAM order; the A1 copy then holds the batch's
   test-host side effects, as at U1b). From `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum
   -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u5 -resultBundlePath
   ../../notes/plans/vx336-screens/u5/u5-batch.xcresult` + one `-only-testing:VariorumTests/<Suite>` per suite below,
   detached to `notes/plans/vx336-screens/u5/logs/u5-batch.log` and POLLED in the foreground. **The 31 suites** — every
   Mac test file reaching a type U5a or U5b changed (grepped in `App/Variorum/VariorumTests` for `MCPPaneCopy`,
   `MCPReceiptCopy`, `MCPWriteAct`, `MCPToolFacts`, `activityLine`, `DocumentImport`, `createNote(`,
   `createStructuredNote`, `importDocument`, `importNote`, `aiLabel`, `saveLens`/`save_lens`, `insert_blocks`,
   `create_note`, `import_document`, `add_takes`, `"add_take"`, `MCPWriteTools`, `MCPToolCatalog`, `MCPServerHost`,
   `MCPDoor`, `MintedBlockTakes`): BookcaseOutsideWriteTests · CapabilityRegistryTests · DocumentImportDoorTests ·
   MCPAskAndReceiptTests · MCPAsksWaitCaptureTests · MCPAsksWaitTests · MCPDeliberateFacesTests ·
   MCPDoorErgonomicsFacesTests · MCPEditFacesTests · MCPEditParityFacesTests · MCPGrantSheetCaptureTests ·
   MCPGrantSheetTests · MCPGrantSheetU2CaptureTests · MCPHerEditorDoorTests · MCPLibraryParityFacesTests ·
   MCPNavigationTests · MCPPaneTabsCaptureTests · MCPPaneTabsTests · MCPPaneTests · MCPRebindFaceTests ·
   MCPSetupKeyFacesTests · MCPSetupMenuTests · MCPSetupTabKeyTests · MCPShareFacesCaptureTests · MCPShareFacesTests ·
   MCPWingFacesTests · TutorialMCPChapterCaptureTests · TutorialMCPChapterTests · VX206ProtectionLandingTests ·
   WriteTakesPanelKeysTests · WriteTakesPanelRoutedCommandTests (the suite in `WriteTakesPanelRoutedTests.swift`).
   **Expected:** green; the `*CaptureTests` skip (env-gated); `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID`
   now walks `insert_blocks` and meets its words. Known noise, not a red: «Issues recorded without an associated test»
   ×4 (`@Dependency(\.withRandomNumberGenerator)` — U3's door-pin harness noise). A red: re-run that suite ALONE once; a
   red that reproduces is a FINDING — recorded and reported; the live round continues only if the red is outside every
   type this run changed (else cleanup, release, report). VX-115's standing `BookCollectingDoorsTests` is not in the set.
   **→ THE SEAM:** record the batch's counts in this record, commit, push, KEEP the claim, report "SEAM" through the
   orchestrator (the coordinator may slot a short window in; re-claim on its word if it takes the stage).
2. **A1 prestage copy + prefs + fingerprint (~4 min).** The copy exactly as `Tools/ScaleFixture/stage.sh` makes it (its
   copy loop only — never its launch): `variorum.sqlite`, `-wal`, `-shm` and every `variorum-keys-*.json` from
   `~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/` into
   `…/Variorum-dev/Backups/safety-copies/scale-prestage-<UTC yyyymmddTHHMMSSZ>/` (the name MUST start
   `scale-prestage-` — `restore.sh` refuses any other), each `cmp`-verified, its sha256 prefixes recorded; the
   `castle-W1-20261013` folder (her W-1 repro) is LEFT ALONE. `defaults export io.lduarte.Variorum.debug
   …/u5/prefs-pre.plist` (key count recorded). `Backups/` listed. **Her user-scope servers** — names + the sha256
   prefix of the sorted compact `mcpServers` JSON, never values: `python3 -I -c 'import json,hashlib,os;
   d=json.load(open(os.path.expanduser("~/.claude.json"))).get("mcpServers",{}); print(sorted(d),
   hashlib.sha256(json.dumps(d,sort_keys=True,separators=(",",":")).encode()).hexdigest()[:16])'` — **READY's read
   (~15:00 MDT): `['linear-server', 'variorum']`, `bc64543e2f4e8e58`** (= VX-246's windows'; the method reproduces it).
   Re-read after every registration change and after cleanup.
3. **Launch, connect, grant (~5 min).** `open -n …/vx336-u5/Build/Products/Debug/Variorum.app`; a What's New sheet → its
   own button; a lock screen → `source ~/.variorum/dev-castle.env`, those values only, and the posture restored before
   release. Study expected (capture the launch). App menu ▸ MCP Settings… → the switch ON. **Connect ▸ Claude Code ▸ the
   copy icon** → from the clipboard take ONLY the key (`vmk2_claude-code_…`); never run the copied line. Write a scratch
   config OUTSIDE the repo (the runner's scratchpad): `u5-mcp.json` = `{"mcpServers":{"variorum-dev":{"command":"<the
   shim's absolute path>","env":{"VARIORUM_MCP_KEY":"<the key>"}}}}` (U5a's `u5a-mcp.json` IS this file). Every turn
   below, from a scratch project directory: `claude -p --strict-mcp-config --mcp-config <scratch>/u5-mcp.json
   --output-format json --allowedTools "<the leg's list>" "<the prompt>"`, its answer tee'd to `…/u5/<leg>.json`. A first
   turn (`mcp__variorum-dev__list_books`) BINDS the tab key with zero clicks (Activity "claude-code connected with a new
   setup, now bound to its name" or "…a newer setup, which replaced its earlier one"); if the restored store doesn't
   know claude-code, it arrives in Waiting as a connection request → Approve… (alone — zero reach). **THE GRANT for steps
   5–7:** claude-code's Shared-with-AI row ▸ Change… (with no row to change: ⌥⌘A from the Bookcase) ▸ **A wing · Home ·
   Write new · Always** (capture the sheet and the row).
4. **The fixture book (~2 min):** Bookcase ▸ + New Book → **"vx336 u5b"** (Home, unshelved). Capture.
5. **V252-a — `create_note` answers its ids and files into a chapter (~6 min, WRITE NEW).** ONE turn, allowed
   `mcp__variorum-dev__list_books,mcp__variorum-dev__create_section,mcp__variorum-dev__create_note,mcp__variorum-dev__read_note`:
   > In Variorum, find the book named "vx336 u5b" (list_books). Make a chapter named "um" in it with create_section. Then
   > call create_note with that book_id, the new chapter's section_id, title "u5b ch 1", and blocks [{"text": "Olá.",
   > "takes": [{"text": "Hello.", "label": "english"}]}, {"text": "Adeus.", "name": "the end"}]. Then call read_note on
   > the new note with with_ids true. Reply with create_note's answer verbatim, and say whether its blocks (each
   > block_id, shown_take_id, and every take's take_id and label) match what read_note reports.
   **Expected:** create_note lands; its keys `block_ids`, `blocks`, `note_id`, `section_id` (= the new chapter's id),
   `tag_ids`; `blocks` two records — the first `{"block_id", "shown_take_id", "takes": [{"take_id"}, {"take_id", "label":
   "english"}]}`, the second one take — equal to read_note's with-ids records; the client says they match.
   **Her face:** the receipt "claude-code made the note “u5b ch 1”" with Open › and ⌥⌘Z (capture); the book (Bookcase ▸
   vx336 u5b ▸ Outline or Index) shows "u5b ch 1" UNDER the chapter "um", never in "unfiled" (capture).
6. **V255-a — `insert_blocks` at the end at WRITE NEW, then her ⌥⌘Z and ⇧⌥⌘Z (~8 min).** Open "u5b ch 1" in Write
   (BEFORE: Olá. / Adeus. — capture). ONE turn, allowed
   `mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,mcp__variorum-dev__insert_blocks`:
   > In Variorum, find the note "u5b ch 1" in the book "vx336 u5b" (list_notes with that book). Call insert_blocks on it
   > with NO after_block_id and NO at, and blocks [{"text": "Três."}, {"text": "Quatro.", "takes": [{"text": "Four.",
   > "label": "english"}]}]. Then read_note with with_ids true. Reply with insert_blocks' answer verbatim and the note's
   > blocks in order (block_id and shown text).
   **Expected:** lands; the answer `{"block_ids": [2 ids], "blocks": [2 records — "Quatro."'s takes [{"take_id"},
   {"take_id", "label": "english"}]], "note_id"}`; the order **Olá. / Adeus. / Três. / Quatro.** **Her face:** Write
   shows the four blocks (capture); the receipt **"claude-code added 2 blocks"** · Open › · ⌥⌘Z (capture); Settings ▸
   MCP ▸ Activity **"claude-code added blocks to “u5b ch 1”"** (capture). **Her undo, the note focused in Write:** the
   Edit menu reads **"Undo claude-code's blocks"** (capture the menu) → ⌥⌘Z → Três. and Quatro. GONE, her two untouched
   (capture) → ⇧⌥⌘Z → both BACK, in place (capture).
7. **V255-b — write new with an anchor hears the rung's sentence, and she is asked (~5 min).** ONE turn, allowed as 6:
   > In Variorum, on the note "u5b ch 1" (book "vx336 u5b"), call read_note with with_ids true. Then call insert_blocks
   > with after_block_id set to the FIRST block's id and blocks [{"text": "Entre."}]. Then call insert_blocks again with
   > at "start" and blocks [{"text": "Início."}]. Quote both answers verbatim. Do not retry or work around a refusal.
   **Expected:** both `isError`, each EXACTLY **"This client may only read, suggest and write new here. Variorum has
   asked the author — call again once they answer."**; nothing minted (Write still shows the four — capture). **Her
   face:** Settings ▸ MCP's Waiting (above the tabs): claude-code asking for **edit** on "u5b ch 1" (capture), the
   note's pending-ask mark where it shows; Activity "claude-code was refused adding blocks to “u5b ch 1”" (capture).
   Answer the ask **Don't allow** (or Esc) — the edit grant comes by step 8, not by this ask (capture Waiting cleared).
8. **The re-grant (~2 min):** claude-code's wing row ▸ Change… ▸ **A wing · Home · Edit · Always** (U5a's legs need it;
   suggest is inside edit). Capture the row.
9. **V255-c — anywhere at EDIT (~5 min).** ONE turn, allowed as 6:
   > In Variorum, on the note "u5b ch 1", call read_note with with_ids true. Call insert_blocks with after_block_id set to
   > the FIRST block's id and blocks [{"text": "Entre."}]. Then call insert_blocks with at "start" and blocks [{"text":
   > "Início."}]. Then read_note again and reply with the blocks' shown texts in order.
   **Expected:** both land; the order **Início. / Olá. / Entre. / Adeus. / Três. / Quatro.** **Her face:** Write (capture).
10. **D8 — her typing beside the AI's run (~10 min; the orchestrator's added leg).** A turn here is STARTED DETACHED
    (`nohup claude -p … > …/u5/<leg>.json &`) so her keys can be typed while it runs, and its answer file is polled in the
    foreground.
    - **D8-a — her caret in the block the run lands after:** Bookcase quick entry `{t:"u5b d8"}Her first line.` ⏎ → a
      one-block note in Home; open it in Write; click at the END of "Her first line." and type ` She keeps typing` (no
      Return) — BEFORE (capture, the caret after "typing"). Start ONE turn, allowed
      `mcp__variorum-dev__list_notes,mcp__variorum-dev__insert_blocks`:
      > In Variorum, find the note "u5b d8" (list_notes), then call insert_blocks on it with no after_block_id and
      > blocks [{"text": "The AI's paragraph."}]. Reply with the answer verbatim.
      While it runs, type ` and more.` (her block). **Expected AFTER (capture):** the AI's block BELOW hers; her block
      reads **"Her first line. She keeps typing and more."**; her caret still at its end; ` Still here.` typed then lands
      in HER block (capture).
    - **D8-b — her open TAIL:** the note's segmentation chip OFF (Write's bar — ⏎ is then content), at the end of her
      block press ⏎ and type `Her tail line` (no ⏎) — the open tail; BEFORE (capture). Start ONE turn as D8-a with text
      "The AI's second paragraph." **Expected AFTER (capture):** the AI's paragraph sits below her stored blocks and her
      tail line still below it on the page; then ⏎ → the tail crystallizes; ONE read turn (`list_notes,read_note`, "reply
      with the blocks' shown texts in order") → **Her first line. She keeps typing and more. Still here. / The AI's
      paragraph. / The AI's second paragraph. / Her tail line** — her tail after the AI's run, where the screen showed it.
      If the chip isn't found within 2 minutes, D8-b is recorded NOT RUN (D8-a carries the caret case of the ruled leg).
11. **U5a's LIVE LEGS A–C (D optional) (~17 min, +3)** — EXACTLY as the U5a UNIT RECORD's "LIVE LEGS FOR U5b's WINDOW"
    writes them (its fixture "vx336 u5a" through her quick entry; leg A's "claude-code · english" cards in Takes, captured
    in Study now and in Terminal at step 12; leg B's ambiguity refusal and its `take_ids` retry; leg C's legacy form; D's
    `pin_chosen` if minutes remain), on `u5-mcp.json`, answers tee'd to `…/u5/u5a-<leg>.json`.
12. **The Terminal pass (~10 min):** Settings ▸ General ▸ Theme → Terminal (U1b's AX road: the two unnamed radios read
    `0, 1` → press the first). Capture in Terminal: U5a leg A's card label; "u5b ch 1" in Write (V255-c's order); then ONE
    turn (allowed as 6) `insert_blocks` on "u5b ch 1" with blocks [{"text": "Fim."}] → the receipt **"claude-code added a
    block"** (capture) → her ⌥⌘Z → "Fim." gone (capture). Flip back to Study.
13. **Cleanup (~8 min):** the scratch config and every key deleted, the clipboard emptied, a whole-key grep (each key in
    full) over `…/vx336-screens/u5/`, `~/.claude.json`, the scratch project's transcripts and `notes/` → 0 files; no
    `-s local` registration was made (if one was: `claude mcp remove -s local variorum-dev`, then `claude mcp get
    variorum-dev` → "No MCP server named …"); her user-scope fingerprint AFTER = BEFORE; the Debug app quit BY BUNDLE ID
    (`osascript -e 'tell application id "io.lduarte.Variorum.debug" to quit'`), the strict guard empty, no shim left;
    prefs: `defaults import io.lduarte.Variorum.debug prefs-pre.plist`, then re-export and diff, `defaults delete` every key
    the window ADDED (import merges), until **0 added · 0 removed · 0 changed**; `Tools/ScaleFixture/restore.sh "<the A1
    dir>"` → "Restored (verified)", a second `cmp` of every file SAME and the sha256 set equal to the A1 copy's (the store
    Standard, unlocked, Study, claude-code's pre-window binding and grants back with it); `Backups/` unchanged (no new
    backup from the launch); a stray `default.profraw` removed; the tree clean; `Tools/stage release --who vx336-u5`;
    **THE RESULT LINE** for the coordinator: claim times; the batch's counts; each leg PROVEN or RED (a red with its
    answer and capture); the posture (Standard/unlocked, cmp SAME vs A1, prefs 0 differ, fingerprint SAME); the A1 path
    (the coordinator's to prune).

### The traces (written before code)

**VX-252 — the write mints ids it never says (agent ergonomics, ruled; a pure addition).** Inputs → output: a client
calls `create_note(book_id, title, blocks: [{text: "Olá.", takes: [{text: "Hello.", label: "english"}]}, …])` →
`MCPWriteTools.perform`'s `.createNote` arm (`MCPWriteTools.swift:404–415`) → `ops.createStructuredNote` →
`mintNoteEntry` (`Operations+MCPWrites.swift:517–558`) → `mintDocument` (`Operations+DocumentImport.swift:213–248`) →
per block `mintFanBlock(texts: [shown] + takes, labels: [nil] + labels)` (`Operations+Structural.swift:1296`) — which
RETURNS every minted variant — but `mintDocument` keeps only `minted.block.id` (`:237`), so `MintedDocument` and then
`DocumentImport` carry `blockIDs` and an `alternateCount`, never a take id → `noteAnswer` (`MCPWriteTools.swift:757–766`)
answers `{"note_id","block_ids","tag_ids"}`. To learn the take ids the write itself minted (to `save_lens` them, to
`edit_take` one) the client must `read_note with_ids` the note it just wrote — 100–133k characters per chapter in her
run (25 reads, ~2.7M characters). `add_take` answers its `take_id` (`:370`): the two disagree. **`import_document` with
ONE document** rides the same road (`.importNote` → `ops.importNote` → `mintNoteEntry` → `noteAnswer`): **the same gap,
real** — a document's Alternates sections mint takes whose ids are dropped the same way. **`import_document` with a
`book`** (`.importBook` → `ops.importBook(_:wingId:undoLabel:)` → `BookImport`) answers `{"book_id","note_ids",
"chapter_ids"}`: no block ids at all — a wider gap, argued at D3. **`section_id`:** `create_note`'s parse never reads it
(`MCPWriteTools.swift:202–214`), and the server's parse ignores a key the schema doesn't name (U5a's red-on-old run
proved the class: `label`/`pin_chosen` were silently ignored) — so today `create_note(book_id, section_id, …)` LANDS the
note UNSECTIONED and answers success. The red-on-old pin reads exactly that (the membership's `section_id` NULL).

**VX-255 — the door cannot add a paragraph to a note (R-VX184-1's parity gap; a pure addition).** Her doors add a block
anywhere: ⌘⇧⏎ (`newBlock(at: .after(block))`), the Return key's act (`TypedReturn` → `newBlock` below/above), paste
(`importBlocks(into:)` — segmented into an existing note, one parts entry). The wire has none: a client can only mint a
whole note (`create_note`) or `divide_block` a block whose text already holds the words (the agent's chapter-16 case:
four late paragraphs would have been "a chain of divides"). On the old tree `insert_blocks` answers `Unknown tool:
insert_blocks.` (`MCPWriteTools.swift:240`) — red by its absence.

### The design (argued — the brief's "argue" items; the FORKS it leaves are proposed at the end, NOT built until ruled)

**D1 — THE SHARED ANSWER SHAPE: one record per minted block (VX-252; reused by `insert_blocks` and U6's
`duplicate_note`; U7's VX-254 grows it).** Named ONCE: a NEW `Sources/VariorumMCP/MCPMintedBlocks.swift`,
`MCPMintedBlocks.records(_:) -> [[String: Any]]`, fed by a core value the op returns from what it MINTED (no second read,
no race, ∝ the write): `Operations.MintedBlockTakes { blockID, shownTakeID, takes: [MintedTake { id, label }] }`, built
in `mintDocument` from `mintFanBlock`'s own variants and carried on `MintedDocument` → `DocumentImport.blocks`. Each
record, in note order:
```json
{"block_id": "…", "shown_take_id": "…", "takes": [{"take_id": "…"}, {"take_id": "…", "label": "english"}]}
```
- **`takes` lists EVERY take in fan order, the shown one included** (at mint the first — the in-place text, chosen AND
  default), so every take has an OBJECT record U7's digest can join (`{"take_id", "label", "sha256"}` — no positional
  arrays anywhere); `shown_take_id` names which take the block shows (read_note's own word; a `duplicate_note` copy's
  shown take need not be first in its fan, so the field is not redundant for U6).
- **read_note's vocabulary, no text:** `block_id`, `shown_take_id`, `takes[].take_id`, `takes[].label` (omitted when the
  take has none — read_note's convention); a blank take is a take and is listed.
- **The answer keeps `block_ids`** (byte-unchanged for every existing caller and pin) and gains `blocks`:
  `{"note_id", "block_ids", "blocks", "tag_ids"}` (+ `section_id` when one was given, `add_note_to_book`'s echo).
  Size, honestly: her biggest chapter (253 blocks, one extra take each) answers ≈ 60k characters with `blocks` — under a
  read_note of the same note (100–133k), and the first answer that needs no read at all; keeping `block_ids` costs one
  id per block (~16% of it). FORK F-6 offers dropping it.

**D2 — `create_note`'s `section_id` (VX-252) — its rung and refusals.**
- **Rung: WRITE NEW on the book**, the note's own decision (`into(.book)`) — filing under a chapter of the SAME book adds
  no reach (`add_note_to_book`'s `section_id` and `file_note_in_chapter` are write new already). Nothing new is decided.
- **The parse (before any decision — independent of any target, so no oracle):** `section_id` without `book_id` refuses
  "section_id goes with book_id: it files the note under a chapter of the book the note joins." (with `wing_id`, or
  with neither).
- **Inside the act's ONE transaction, her own door's order** (`newPostInReading` — New Note in a Book, with a chapter):
  the book's gates first, exactly as today (a live BOOK, not a gathering, not finished or sealed, capacity, the wing —
  `mintNoteEntry` + `addPostToReading`), then the chapter: `liveSection` + `readingId == book` (`sectionNotFound` /
  `sectionNotInReading`), checked BEFORE anything is minted; then the mint, the membership and its chapter pointer in
  the same transaction. Any refusal mints nothing.
- **The words — the brief's "a section in a book the client can't read answers the one not-shared shape":** the book is
  decided first (an unreachable book answers the ONE not-shared sentence before any chapter is looked at, byte-identical
  with or without `section_id`). For a REACHABLE book, every `section_id` that isn't a live chapter of THAT book —
  naming nothing, a deleted chapter, a chapter of another book the client reads, or of one it can't — answers ONE
  sentence, byte-identical: `MCPWireRefusalCopy`'s existing "section_id isn't a chapter of this book (list_notes or
  create_section gives chapter ids)." (what `add_note_to_book` and `file_note_in_chapter` say today). So a chapter in a
  book the client can't read is indistinguishable from a missing id — hidden never told from missing. The literal
  "not-shared shape" for those ids is FORK F-3.
- **Undo:** unchanged — the ONE minted-container entry (`registerMintedContainerEntry`, SWEEP TABLE rows 25–34) takes the
  filing with the note (the membership dies on the note's stamp) and the redo returns it filed (the row revives with its
  `section_id`). The receipt and its Open › unchanged (the note).

**D3 — `import_document`.** The ONE-document form has the same gap and closes the same way (`noteAnswer` is shared — the
`blocks` records ride both doors, from the same `DocumentImport`). The BOOK form's answer stays as it is: FORK F-2.

**D4 — `insert_blocks`' shape (VX-255, ruled `insert_blocks(note_id, after_block_id?, blocks)`).** `blocks` is
`create_note`'s structured shape, parsed by the SAME `noteBlocks` (`[{text, name?, takes?: [{text, label?}]}]`): each
block's text is exactly ONE block (a blank line inside stays inside — I4; create_note's structured rule, so "segmentation
as create_note does it" is: none), its name set, its takes at the fan's end unchosen, labels stored AS GIVEN (VX-197's
split — work a client is authorized to write keeps clean labels; `aiLabel` is suggest's alone), blank takes legal
(R-VX171-2). 1 to 200 blocks per call (FORK F-5). A `text` payload is FORK F-4.

**D5 — WHERE the blocks land, and the rung (the brief's "argue which reads cleaner" — FORK F-1, and "argue at the
start" — FORK F-1b).** Proposed: the rung is read from the call's ARGUMENTS alone —
- no anchor (or `at: "end"`) → the note's END, at **WRITE NEW**;
- `after_block_id` (ANY block — the note's last included) → right after it, at **EDIT**;
- `at: "start"` → before the first block, at **EDIT** (`move_block`'s own word and enum, `at: "start" | "end"`).
`after_block_id` with `at` refuses at the parse ("Pass after_block_id or at, not both."). The argument for "any anchor
needs edit" over "the last block counts as the end": (1) her line is about the END, a place — "write new lets them add
blocks at the end" — while naming a block places relative to HER blocks, which the catalog keeps at edit (`move_block`'s
`after_block_id`/`before_block_id`/`at`); (2) the rung is legible from the call itself — the description says it in one
sentence and the decision is one rule (`onNote` at the call's rung), with no read of the note's order before it;
(3) **no flip under her:** the note's last block moves while she types (type-time crystallization mints a block at the
end for each paragraph she types past — `TailCrystallizer.mintBlocks`, `newBlock(at: .end)`), so a call naming "the
last block" a second after its read could flip rung, or — at edit — land ABOVE her newest paragraph; an anchorless call
always lands at the current end. **The refusal:** a write-new holder passing an anchor is decided on the note at EDIT and
hears the rungTooLow family's sentence ("This client may only read, suggest and write new here." + the asked sentence
when an edit ask was raised) — never the not-shared shape for a note it can read; the ask queues quietly for her.
**The anchor's check (after the note's decision, so an unreachable note never reveals a block):** a live block
live-placed in THIS note (`placedBlocksSQL`, ∝ the one id), else "after_block_id isn't a block of this note —
read_note with with_ids: true gives its block ids." — the same words for a block of another note and for nothing (the
batches' rule); inside the transaction the op re-resolves the anchor (`containerPosition(.after)` → `blockNotPlaced`,
spoken in those same words) so a block that left since never anchors.

**D6 — the act (core, NEW `Operations+MCPInsertBlocks.swift`): `insertBlocks(_:intoNote:at:undoLabel:guardedBy:)` on
§9 newBlock's road.** ONE transaction: the guard FIRST (it re-decides the note at the call's rung inside the act and
spends a once grant atomically — the batch doors' pattern for a new act, VX-184 U3); the note live, a post, not sealed
(`ensureUnlocked` → `lockedPost` — "a sealed post refuses"); per block, in order: its position
(`containerPosition(at:)` for the first, `.after(previous)` for each next — the run keeps its order wherever it lands),
`mintFanBlock` (the shown text chosen AND default, the takes after it unchosen and unlocked with their labels, blank
takes kept), its name, and `registerTextChange(charDelta: shown text)` — newBlock's stamp rule: minting text IS working
on the post (touch + churn), fan growth never churns. **Locks, as her doors have them:** the post's seal refuses; a
LOCKED take anywhere — the anchor's included — never refuses (her ⌘⇧⏎ below a locked take doesn't: the act touches no
take); no take is born locked or chosen. **ONE entry, newBlock's own helper:** `registerStructuralEntry(label: "‹client›'s
blocks", minting: [MintedPreImage per block])` — an untouched block vanishes on ⌥⌘Z, one she has typed into since TRAYS
(the insurance doctrine, `revertStructural`), a sealed note refuses the undo and keeps the entry; **U2's question is
answered by the helper:** each half returns the parts it changed and `!changed.isEmpty` (SWEEP TABLE rows 2–13's road),
so a quiet half retires the entry. A NEW `MCPWriteAct.blocks = "blocks"` ("Undo claude-code's blocks" — the takes
batch's twin, "claude-code's takes"); `isUndoable` true.

**D7 — the wire.** `insert_blocks` joins the WRITE NEW list (listed from write new up; scopes: note · book · wing — a
grant reaching the note at write new, `apply_tag`'s scopes). The snapshot: `onNote(noteID, rung: <the call's rung>,
spendsAfter: false)` (the refusal and the ask); the act's guard: `guardNotes(clientName, rung: <the same>) { _ in
[noteID] }`. The answer: `{"note_id", "block_ids", "blocks"}` — D1's records. The receipt: act `.blocks`, `count` = the
blocks, Open › at the note's first new block. **Words (FOR VX-234, as built):** Activity "added blocks to “X”" / refused
"adding blocks to “X”" (the takes batch's family); the receipt "added a block" / "added N blocks" (summed over a run).

**D8 — `flushesHerEditorFirst`: FALSE, argued (U3's exhaustive switch; the add family's answer, `create_note`/`add_take`).**
The act adds blocks and reads, rewrites, copies, freezes or tombstones no take's text. (i) **Her caret in the block it
inserts after:** her pending typing is that block's take's text; the take is untouched (same row, live, unlocked, same
place), so her debounce flush lands where she typed. While her editor is dirty the delivery defers
(`EditorProjectionPolicy.decide`'s busy arm); once clean, the structure changed, so a full render rebuilds from the store —
the new blocks below her block — and restores her caret BY IDENTITY because her block survives (U3's trace 4:
`renderFull`'s survivor restore). Nothing of hers moves. (ii) **She is typing at the note's end:** an open tail is editor
state, not a take (nothing pending in a row); the act appends after the last STORED block; the full render keeps her
tail (`preserveTail`) below the new blocks, and when she types past it the crystallizer mints her paragraph at
`.end` — after the AI's blocks, exactly where the screen showed it. Nothing is overwritten, reordered or refused. (iii)
**Her ⏎ in flight:** `runStructural` flushes first and acts on the store's current order (a block below hers lands
between hers and the AI's run). The editor seam is READ, not touched.

**D9 — P1.** Every new read and answer ∝ what it names: the parse ∝ the call; the anchor pre-check ∝ one id
(`placedBlocksSQL`); per block one position seek (`idx_cblock_order`) and its own rows; the answer ∝ the blocks minted
(D1's records come from the op's return, no read). `create_note`'s records add nothing to its read cost (none).

**D10 — the fence and Private / Seal / Own:** untouched — every decision is the one rule's (`onNote` / `into`), an
unreachable note or book answers the ONE not-shared sentence byte-identical whatever else the call names (the anchor,
the chapter and the blocks are looked at only after it allows); nothing writes `ai_private_at`, `sealed_at` or `owned`.

**The doc-truth sweep (minimal; U8 re-voices):** `create_note`'s description says "Returns JSON with the note_id and its
block_ids" — true and incomplete; it gains the records and `section_id` in this unit (its own tool). `import_document`'s
"Returns JSON with the new ids" — true; it gains the records' sentence. `MCPSession.instructions` ("write new (new notes,
books, chapters, tags, versions)") and the field guide's MCP chapter undersell `insert_blocks` but state nothing false —
U8's. The stargazing brief: U8's.

### THE FORKS — proposed, for the orchestrator's ruling BEFORE the halves they touch are built

- **F-1 (VX-255, the brief's "argue which") — the write-new anchor rule:** (a) PROPOSED — the rung is read from the
  arguments: no anchor = the end at write new; ANY `after_block_id` (the last block included) = edit (D5's three
  reasons — her "at the end" is a place; one legible rule; no flip as her typing moves the last block); (b) an
  `after_block_id` naming the note's CURRENT last block is allowed at write new (reads "after the last block" as "the
  end"; needs the note's order read before the rung, and flips under her typing).
- **F-1b (VX-255, "argue at the start") — the start door at edit:** (a) PROPOSED — `at: "start"` (`move_block`'s word;
  `at: "end"` accepted as the default's spelling); (b) `before_block_id` (any block, edit — a second anchor kind the
  ruling's shape didn't name); (c) no start door (insert after the first block, then `move_block` it down).
- **F-2 (VX-252, "check import_document's answer") — the BOOK form's answer:** (a) PROPOSED — unchanged (`book_id`,
  `note_ids`, `chapter_ids`): closing it "the same way" would answer every note's every block and take, ∝ the WHOLE
  book (her bilingual book: 3,843 blocks ≈ 0.8M characters — eight times a client's tool-output cap, VX-256's very
  failure); the single-document form closes, the book form reads its notes as needed; (b) per note the D1 records (∝ the
  book); (c) per note its `block_ids` only (still ~150k characters for her book).
- **F-3 (VX-252, the brief's "a section in a book the client can't read answers the one not-shared shape"):** (a)
  PROPOSED — the book decided first (unreachable ⇒ the one not-shared sentence); then EVERY `section_id` that isn't a live
  chapter of that book answers ONE sentence, byte-identical — the existing `MCPWireRefusalCopy` chapter sentence
  `add_note_to_book` and `file_note_in_chapter` already speak — so a chapter of an unreadable book can't be told from a
  missing id (D2); (b) the not-shared sentence for every such `section_id` (oracle-free too, but it tells a client with
  a mistyped chapter in a book it CAN write in that the book isn't shared — false — and disagrees with the two siblings);
  (c) not-shared only for a chapter of an unreadable book — an ORACLE (it differs from a missing id), rejected.
- **F-4 (VX-255) — the payload:** (a) PROPOSED — `blocks` only (the ruled shape; "segmentation as create_note does it"
  read as its structured rule — none); (b) also `text` (plain prose, segmented by the NOTE's effective default — paste's
  road, `importBlocks`), as `create_note` offers both.
- **F-5 (VX-255) — a cap:** (a) PROPOSED — at most 200 blocks per call, stated in the description, refused naming it
  (`batchCap`, the house's per-call bound: the act runs on HER runner while her note may be open — the takes batch's
  argument; `insert_blocks` exists partly to write big documents in chunks); (b) no cap (`create_note` has none — it
  took 253 blocks in her run).
- **F-6 (VX-252) — `block_ids` in the answer:** (a) PROPOSED — kept beside `blocks` (additive: every existing caller and
  pin byte-unchanged; ~16% of the answer); (b) dropped (`blocks[].block_id` says it; two pins become justified edits;
  any client habit breaks).
- **Confirm, too, the D1 record shape** (U6 and U7 build on it): `blocks: [{block_id, shown_take_id, takes: [{take_id,
  label?}]}]`, every take an object, the shown one included.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

*(Filed at the seam from THE ORCHESTRATOR'S RULINGS; the VX-255 ones are built in pieces 4–6.)*

- **P-VX252-1 — `import_document`'s BOOK form keeps its answer** (F-2): (a) AS BUILT — `book_id`, `note_ids`,
  `chapter_ids` (closing it the way the one-document form closes would answer ∝ the WHOLE book — ~0.8M characters for her
  bilingual book, eight times a client's output cap; a client reads a book's notes as needed); (b) per note the D1
  records (∝ the book); (c) per note its `block_ids` only (~150k characters for her book).
- **P-VX255-1 — the write-new anchor rule** (F-1): (a) TO BUILD — the rung is read from the arguments: no anchor (or `at:
  "end"`) lands at the note's end at write new; ANY `after_block_id`, the last block included, needs edit (her ruling
  names a place — "add blocks at the end"; one legible rule decided before any read of the note's order; it never flips
  rung or lands above her newest paragraph as her typing crystallizes); (b) an `after_block_id` naming the note's CURRENT
  last block is allowed at write new (needs the order read before the rung, and flips under her typing).
- **P-VX255-2 — the start door** (F-1b): (a) TO BUILD — `at: "start"` at edit (`move_block`'s word), `at: "end"` the
  default's spelling, `after_block_id` with `at` refused at the parse; (b) `before_block_id` (any block, edit — a second
  anchor kind the ruling's shape didn't name); (c) no start door (insert after the first block, then `move_block` it).
- **P-VX255-3 — the payload** (F-4): (a) TO BUILD — `blocks` only (the ruled shape, create_note's block parse; a blank
  line stays inside its block); (b) also `text` (plain prose segmented by the note's own default — paste's road,
  `importBlocks`), as `create_note` offers both.
- **P-VX255-4 — the cap** (F-5): (a) TO BUILD — at most 200 blocks a call (`batchCap`), stated in the description and
  refused naming it (the act runs on her runner while her note may be open; the tool exists partly to write big
  documents in chunks); (b) no cap (`create_note` has none — it took 253 blocks in her run).

**Recorded, not provisional:** F-3 and F-6 are the orchestrator's (the fence; compatibility) — `section_id`'s one chapter
sentence for every non-chapter of a reachable book, and `block_ids` kept beside `blocks`. The order note in piece 2's row
(a full book with a bad chapter hears the chapter sentence first) is a consequence, not a choice.

### FOR VX-234 (user-facing words, as built)

**VX-252 (as built): nothing she sees changed.** `create_note`'s and `import_document`'s new answer fields, the
`section_id` refusal sentences ("section_id goes with book_id: …", and the existing chapter sentence) and the two
description sentences are the MODEL's words on the wire, never rendered in her app; a filed note's Activity line and
receipt are the existing `create_note` words.

**VX-255 (as built, piece 5 — her app's words; PROVISIONAL, her pane-wording pass):**
- Activity, allowed: **"‹client› added blocks to “‹note›”"** (+ " (N times)" for a coalesced run — one row per CALL,
  the batches' rule; `MCPPaneCopy.activityPhrase`).
- Activity, refused: **"‹client› was refused adding blocks to “‹note›”"** (`MCPPaneCopy.refusedPhrase`).
- The receipt: **"‹client› added a block"** / **"‹client› added N blocks"** (summed over a run, as the takes batch's;
  `MCPReceiptCopy.phrase`), with Open › at the first new block and "⌥⌘Z undoes".
- The undo entry: **"Undo ‹client›'s blocks"** (`MCPWriteAct.blocks`), and its refusal family "Nothing to undo —
  ‹client›'s blocks was already undone or changed since." (VX-276's existing sentence with this label).
- The wire's own words (the MODEL's, never rendered in her app): the `insert_blocks` description; the refusals
  "after_block_id isn't a block of this note — read_note with with_ids: true gives its block ids.", "Pass after_block_id
  or at, not both.", "at must be "start" or "end".", "after_block_id must be a block id.", "blocks is required.",
  "blocks must be an array.", "blocks must list at least one block.", and the cap's "insert_blocks takes at most 200
  blocks in one call; this call has N. Split it into calls of 200 or fewer."

### OWED (for the orchestrator)

1. **The ruling on F-1…F-6** (and the D1 shape) before pieces 1–6.
2. *(Recorded, not proposed for this run:)* `import_document` could take a `section_id` too (one document into a
   chapter) — not asked by VX-252; a client files it with `file_note_in_chapter` after. A ticket only if the orchestrator
   wants one. **(Ruled at the forks: no ticket.)**
3. **A FRESH implementer for pieces 4–8** (this continuation stopped at the seam after piece 3, ~500k): its brief is THE
   CONTINUATION'S BUILD PLAN above plus this record's design and rulings — the reading list can be the U5b BRIEF, this
   UNIT RECORD, the RULINGS, the U5a LIVE LEGS, the code the plan names, and VX-246's U1b STAGE RUN (for piece 8's form).
4. **For VX-234 / U8 (an observation, not a change — pane wording is hers to re-voice):** the grant sheet's and the ask's
   write-new sentence at a NOTE scope (`MCPPaneCopy.rungDetail(.writeNew, scope: .note)` — "it can also apply tags and save
   versions of it") will UNDERSELL once `insert_blocks` lands (write new on a note may then add blocks at its end). Not
   false (the sentence never claims to be the whole list) and pinned exactly by `MCPAskAndReceiptTests`; the guide and
   `MCPSession.instructions` likewise undersell (U8's).
5. *(The second continuation, at READY.)* **3 is DONE:** pieces 4–8 landed (`7a15376c` · `3e9f625d` · `96c84c05` ·
   `c9c7f637` · this commit); READY is reported. **The GO:** relay the coordinator's exact claim line `vx336-u5` (a
   110-minute claim asked; batch-only fallback 20) to whoever runs THE STAGE WINDOW — this implementer if resumed, else a
   fresh stage runner from that section alone.
6. **No ticket is proposed by pieces 4–8.** The P-VX255-1…4 PROVISIONALs stand as filed above (built as their (a)); the
   FOR VX-234 list carries `insert_blocks`' words as built.
7. **For the cold reviewer's attention (no change asked):** (i) `noteBlocks` (`MCPWriteTools.swift`) lost its `private`
   so `+InsertBlocks` calls create_note's one block parse — a visibility widening inside the target, nothing public;
   (ii) the record's THE TRACES heading had been overwritten by the first continuation's build-plan tail (its seam
   commit `0ca63296`); this commit restores the two lost lines verbatim from `9b05e442` — a record repair, no meaning
   changed; (iii) the D8 argument stays read-only analysis of the editor seam (no seam line moved); the window's D8 leg is
   its use-shaped evidence.

### SELF-ASSESSMENT — VX-255 (the second continuation's, pre-stage)

- **What is proven headless:** the rung rule (end = write new; any anchor or the start = edit, with the asked sentence
  and her ask — never the not-shared shape for a readable note); the order wherever the run lands; the answer equal to
  read_note's records; one client-named entry, untouched → vanish, worked-on → tray, exact-id redo; the parse's eight
  refusals before any decision; a sealed note refuses and a locked anchor take never does; the fence byte-identical
  across forms; D8's no-flush with her words landing where she typed and the run below her block. Red on old by absence
  (8/8, 26 issues), red again by revert with an identical test × line set, green after; the package green.
- **What is NOT proven until the window:** the Mac faces (Activity, receipt, the Edit menu's "Undo claude-code's
  blocks", her Waiting ask) and a REAL client reading the description and calling the tool; D8 against her live editor
  (the headless pin models her coordinator, not `EditorTextView`'s render and caret restore).
- **Judgment calls inside the ruled design (not forks):** the parse order (note_id · an empty anchor · `at`'s value ·
  both · blocks) — a call wrong in two ways hears the first; a `blockNotPlaced` from the op is translated only when it
  names THE ANCHOR (any other id would be a run-internal impossibility and keeps the room's words); the empty-`text` block
  is legal (an empty block is a block her ⏎ makes too) — the plan's case 1 pins it.
- **Risk I see:** a finished (not sealed) book's member takes an insert at write new — the same as `add_takes` and her
  own doors (Finished freezes assembly, not text); an ARCHIVED note takes one too (`livePost` passes it, as every
  in-note wire act does). Both follow the existing door family; neither is new behaviour.

### THE ORCHESTRATOR'S RULINGS ON U5b's FORKS (2026-10-14 ~14:35 MDT — binding on pieces 1–8)

The design D1–D10 is ACCEPTED as written, with these rulings on its forks. The "PROVISIONAL" ones are the ones she would
otherwise rule (her away-mode answer); each goes to QUESTIONS at the merge with the options the record lists.

- **D1, the shared answer shape: CONFIRMED.** It is `blocks: [{block_id, shown_take_id, takes: [{take_id, label?}]}]`:
  every take an object, the shown one included, in fan order, built from what the op minted (no second read).
  `MCPMintedBlocks` is THE encoder. U6's `duplicate_note` reuses it, and U7's VX-254 adds a per-take field to the take
  objects.
- **F-1: (a), PROVISIONAL P-VX255-1.** The rung is read from the arguments. No anchor (or `at: "end"`) lands at the
  note's end at write new; any `after_block_id`, the last block included, needs edit. Her ruling names a place ("add
  blocks at the end"). (a) is one legible rule, decided before any read of the note's order, and it never flips rung or
  lands above her newest paragraph as her typing crystallizes. (b) is the option.
- **F-1b: (a), PROVISIONAL P-VX255-2.** `at: "start"` (`move_block`'s word) at edit; `at: "end"` is accepted as the
  default's spelling; `after_block_id` with `at` refuses at the parse. Options (b) `before_block_id`, (c) no start door.
- **F-2: (a), PROVISIONAL P-VX252-1.** `import_document`'s BOOK form keeps its answer (`book_id`, `note_ids`,
  `chapter_ids`). Closing it the same way would answer ∝ the whole book, about 0.8M characters for her bilingual book,
  breaking P1's spirit and the output cap VX-256 exists to respect. A client reads a book's notes as needed (U7's paged
  `read_note`). The single-document form closes as D3 says. Options (b) and (c) are recorded.
- **F-3: (a), the orchestrator's (the fence, not a product call).** The book is decided first, so an unreachable book
  answers the one not-shared sentence, byte-identical with or without `section_id`. Then every `section_id` that isn't a
  live chapter of THAT book answers the ONE existing sentence its siblings speak (`add_note_to_book`,
  `file_note_in_chapter`). Hidden is never told from missing, and a client with a mistyped chapter in a book it can
  write in isn't told the book is unshared. This corrects the U5b BRIEF's wording ("answers the one not-shared shape"):
  the brief's intent is the no-oracle rule, which (a) keeps exactly. (c) is an oracle and is rejected.
- **F-4: (a), PROVISIONAL P-VX255-3.** `blocks` only, the ruled shape (`insert_blocks(note_id, after_block_id?,
  blocks)`). A plain `text` payload segmented by the note's default, option (b), is recorded and not built.
- **F-5: (a), PROVISIONAL P-VX255-4.** At most 200 blocks per call (`batchCap`), stated in the description and refused
  by naming it. The act runs on her runner while her note may be open, and `insert_blocks` exists partly to write big
  documents in chunks. (b), no cap, is recorded.
- **F-6: (a), the orchestrator's (compatibility).** `block_ids` stays beside `blocks`, so every existing caller and pin
  is byte-unchanged.
- **D8 (`flushesHerEditorFirst` = false) is ACCEPTED** as argued. U5's live round adds one leg: while her caret types
  in a note, a client's `insert_blocks` at its end lands below her typing tail, and her tail crystallizes after the
  AI's run. Captured.
- **OWED 2 (`import_document` + `section_id`):** not asked and not mandated, so no ticket. A client files with
  `file_note_in_chapter`.
- **Next:** a FRESH `opus-implementer` (xhigh) builds pieces 1–8 from this record alone: the U5b BRIEF, the U5b UNIT
  RECORD's design and these rulings. It then writes THE STAGE WINDOW (`vx336-u5`, with U5a's LIVE LEGS A–C, D optional,
  and D8's leg) and reports READY.


## U5 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14)

**What this run does NOT do (said first):** no product code is written or changed, before the claim or under it — a red
that needs code is RECORDED as a FINDING and reported, never fixed here; no rebuild (the window runs the `vx336-u5`
products exactly as piece 7 built them); no canon, QUESTIONS or ticket edits; never her real store, never
`/Applications/Variorum.app`, never her USER-scope MCP registrations (the copied setup line is never run as copied — only
its key is taken, into a scratch `--mcp-config` JSON in the runner's scratchpad, OUTSIDE the repo); `castle-W1-20261013`
left alone. The plan is the U5b UNIT RECORD's THE STAGE WINDOW (steps 0–13); step 11 is the U5a UNIT RECORD's LIVE LEGS
FOR U5b's WINDOW, run exactly as written there.

**Read in full before READY (never delegated):** this record's header, Hard rules (the stage and live-round machinery),
LIVE STATUS, Stage traffic log and Cross-run coordination; the U5b UNIT RECORD's LIVE STATUS, "What this unit has NOT
done", THE STAGE WINDOW, PROVISIONALs and FOR VX-234 (and its build plan, OWED and self-assessment); the U5a UNIT RECORD's
LIVE LEGS FOR U5b's WINDOW; VX-246's `## U1b STAGE RUN — the whole window` whole (the A1 copy, `restore.sh`, the
fingerprint, the AX theme switch, `defaults import` merging); `notes/SessionResiliencyProtocol.md` (the implementer rules
and the addenda); `Tools/stage`; `Tools/WalkKit/` (README, `guard.sh`, `click.sh`, `keys.sh`); `Tools/ScaleFixture/`
(`stage.sh`'s copy loop, `restore.sh`); the memory notes walk-driving-lessons, walk-restores-dev-store-posture and the
Castle coordinator note.

**The build check (READY, 2026-10-14 ~15:11 MDT):**
- **The product matches the tree.** HEAD `93edbc2e` (U5b piece 8's READY commit); `git diff --name-only c9c7f637..HEAD --
  Sources App Package.swift` is EMPTY; the tree is clean; no `.swift`/plist/pbxproj/xcstrings/entitlements/`Package.swift`
  under `Sources`, `App/Variorum` or the root is newer than the product's `Variorum.debug.dylib` (15:03).
- **The products exist:** `App/Variorum/DerivedData/vx336-u5/Build/Products/Debug/Variorum.app` (signed
  *[removed for publication]*
  `Contents/PlugIns/VariorumTests.xctest`, and `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun` (15:03). The
  dylib carries "added blocks to" (U5b's Activity words).
- **The 31 suites are real type names in the test bundle** (`nm` + `swift demangle`, a `-only-testing` name that matches
  no type runs 0 tests silently): every one of the 31 found (≥ 119 symbols each); `activitySpeaksEveryActInWordsNeverAToolID`
  present.
- **Host and tools:** `AX: true SCREEN: true` (a compiled non-prompting probe); `walk-cap` / `walk-scroll` compiled into
  the runner's scratchpad; `Tools/WalkKit/wl2` compiled into this worktree (gitignored — `guard.sh <pid>` needs it, and this
  worktree had only `wl2.swift`); Claude Code **2.1.300**; `cliclick` present. Free disk **68 GiB**. No Variorum instance
  (`pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` both empty).
- **Her user-scope MCP servers (names + a sha256 prefix of the sorted compact `mcpServers` JSON, never values):**
  `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as U5b's READY read and VX-246's windows.
- **The dev store (read-only listing):** `variorum.sqlite` (14 Oct 08:50), `-wal`, `-shm` (09:17/09:19), key files
  `variorum-keys-b831b428ce0d67b1.json` · `variorum-keys-e86ed514dc8dab5a.json`; `Backups/` 57 entries;
  `Backups/safety-copies/` holds only `castle-W1-20261013` (left alone).
- **The stage at READY:** `STAGE HELD by 'oct13coordinator' — HOLD: coordinator queue` (claimed 15:07:31). Not ours; the
  GO's relayed line is run exactly as relayed.

**Process choices (the earlier windows' lessons applied):** the Mac batch FIRST, detached to its log and POLLED in the
foreground (a `grep -q` loop, never `tail -f | grep -m1`); the SEAM after it; the A1 copy, prefs export and fingerprint
after the SEAM (the A1 copy then holds the batch's test-host side effects — the Hard rules' order); every GUI act through
`click.sh` / `keys.sh` (keys only by System Events), at least 2.6 s apart; region captures (`screencapture -x -R`); the
Debug app quit BY BUNDLE ID; prefs restored by import, then re-export, diff, delete every added key until 0 differ; keys
redacted to their first 9 characters in every record and capture name; the `claude -p` turns from a scratch project
directory in the scratchpad, each answer tee'd to `notes/plans/vx336-screens/u5/<leg>.json`.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the coordinator's GO and its exact line) |
| 0 | guards on every step; the claim from the GO's line; HEAD at the GO | DONE — the GO from oct13coordinator at 15:12 (its pre-checks: no Variorum instances by the strict forms, no booted simulators, 68 GiB free; vx-283's 15:03–15:06 window restored and verified the dev store and prefs; the dev store Standard/unlocked; Debug launches cleared for today). **HEAD at the GO `62d7b92c`** (this section's READY commit; no source moved). Pre-claim: `guard.sh --author` OK (idle 413 s), both strict guards empty, `stage status` → held by `coord-for-vx336` ("GO pending: vx336-u5"). The exact line run: `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u5 --reason "VX-336 U5: 31-suite Mac batch, SEAM, then real-client MCP live round on the Debug dev store (A1 prestage)" --minutes 110` → **STAGE RELEASED (was 'coord-for-vx336') · STAGE CLAIMED by 'vx336-u5' for 110 min at 15:13:00 MDT** (expires 17:03:00) |
| 1 | the Mac batch (31 suites, `test-without-building`, detached + polled) | DONE (15:13:09 → 15:14:05) — from `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u5 -resultBundlePath …/u5/u5-batch.xcresult` + the 31 `-only-testing:VariorumTests/<Suite>`, detached to `u5/logs/u5-batch.log`, polled in the foreground. **"✔ Test run with 251 tests in 31 suites passed after 29.049 seconds" · `** TEST EXECUTE SUCCEEDED **`.** The result bundle: **result Passed — 251 total · 244 passed · 0 failed · 7 skipped · 0 expected failures**; the 7 skips are the gated capture harnesses (`MCPAsksWaitCaptureTests` 1, `MCPGrantSheetCaptureTests` 2, `MCPGrantSheetU2CaptureTests` 1, `MCPPaneTabsCaptureTests` 1, `MCPShareFacesCaptureTests` 1, `TutorialMCPChapterCaptureTests` 1). `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` ✔ (it now walks `insert_blocks`). No «Issues recorded without an associated test» noise this run. **Zero reds — no finding** |
| SEAM | the batch's counts recorded, committed, pushed; the claim KEPT; turn ended "SEAM" | DONE (15:15) — the claim `vx336-u5` held (~2 of 110 min used); no Variorum instance; nothing launched; no A1 copy taken (the coordinator's order: not until its one word, "continue" or "release for X") |
| 2 | A1 prestage copy (cmp + sha256) + `defaults export` + `Backups/` listed + the fingerprint BEFORE | DONE (15:15:17, after the coordinator's "continue") — **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T211517Z`** (`u5/a1-path.txt`), `stage.sh`'s copy loop only: five files each `cmp`-verified (sha256 prefixes: sqlite `c17923414b2e` · wal `7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890`; `u5/store-hash-pre.txt`) — the A1 holds the batch's test-host side effects (the Hard rules' order); `castle-W1-20261013` untouched. Prefs exported: **1,596 keys** (`appearanceChoice` = system; `variorum.whatsNew.lastVersion` = 0.9.6 = the product's) → `u5/prefs-pre.plist`. `Backups/` 57 entries (`u5/backups-pre.txt`). Her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME (`u5/userscope-pre.txt`) |
| 3 | launch, connect (the Claude Code tab key → scratch `u5-mcp.json`), the first turn binds; THE GRANT Home · Write new · Always | DONE (15:15–15:20) — `open -n` the `vx336-u5` Debug app (**pid 75448**, 1380×900 at (60,36); **Study, light, the Bookcase; no What's New sheet, no lock screen** — `live/s/00-launch`). App menu ▸ MCP Settings… (by AX): the switch already ON, "running · socket in the app container · serves while Variorum is open"; Clients: claude-code "last seen 4 days ago · 3 grants" (`01-mcp-pane`). Connect ▸ **Claude Code** ▸ the copy icon (`02-connect`) → from the clipboard ONLY the key (**`vmk2_clau…`**, 60 chars, `vmk2_claude-code_` prefix) into the scratchpad's `keys/u5-mcp.json` (command = a scratchpad tee wrapper around the product's shim `variorum-mcp`; never the copied line, never `-s local`, never her user scope). The tee: `initialize` OK, **`tools/list` 61 tools, `insert_blocks` among them**. The first turn (`list_books`, `u5/u5-bind.json`) SERVED ("o ladrão de raios" — claude-code's existing book grants); **Activity "claude-code connected with a new setup, now bound to its name"** with zero clicks (`03-bind-activity`) — the BIND arm (as at U1b). (A machinery note: the first `turn.sh` attempt passed the prompt after `--allowedTools`, which is variadic, so `claude` exited "Input must be provided…" — but its connect alone had bound the key; the runner now passes the prompt on stdin.) **THE GRANT:** Clients ▸ claude-code ▸ Change… ▸ **A wing · Home · Write new · Always** (`04-grant-sheet-writenew`: "Grant write new in “Home” always, including notes added later") → "4 grants" (`05-grant-row`); Shared with AI: **Home (wing) · claude-code · read, suggest and write new · always** (`06-shared-writenew`) |
| 4 | the fixture book "vx336 u5b" | DONE (15:21) — Bookcase ▸ + New Book ▸ Name "vx336 u5b" ▸ Create Book → **"vx336 u5b" unshelved, 0 notes, wearing the shared icon** (every Home book does under the wing grant — `07-fixture-book`) |
| 5 | V252-a — `create_note` with `section_id` answers its records; filed under "um" | **PROVEN** (15:20:21–15:20:50, `u5/v252a.json` + the tee's exact calls and answers `u5/v252a-tee.txt`) — ONE turn: `list_books` → `create_section(book F95905A6…, "um")` → `section_id` `1A68183F…` → `create_note(book_id, section_id, title "u5b ch 1", blocks [Olá.+english Hello. · Adeus. named "the end"])` landed: keys **`block_ids`, `blocks`, `note_id`, `section_id` (= `1A68183F…`, the new chapter), `tag_ids`**; `blocks` = `[{block_id 863A93E3…, shown_take_id 1A75262D…, takes [{take_id 1A75262D…}, {label "english", take_id FECF0595…}]}, {block_id B31829A3…, shown_take_id FB35D63C…, takes [{take_id FB35D63C…}]}]` — **EQUAL to `read_note with_ids`' records** (read from the tee; the client said so too), the second block named "the end"; read_note's `books` lists vx336 u5b with `section_name` "um". **Her face:** the book's Outline shows **"u5b ch 1" UNDER the chapter "um"**, never unfiled; Bookcase "1 note · 1 ch · 2w" (`09-v252a-book-outline`). The receipt had faded before the capture (the turn's read_note ran ~30 s after the act); it is seen merged at step 6 — the door's 120 s same-client-same-note receipt run (`MCPDoor.receiptWindow`) — as "claude-code made the note “u5b ch…and added 2 blocks · ⌥⌘Z undoes Open ›" |
| 6 | V255-a — `insert_blocks` at the end at write new; her ⌥⌘Z and ⇧⌥⌘Z | **PROVEN** (15:21:46–15:22:23; `u5/v255a.json`, `v255a-tee.txt`) — "u5b ch 1" open in Write, BEFORE Olá. / Adeus. (`10-v255a-before`). ONE turn (`list_notes`, `insert_blocks` with no anchor, `read_note`): **landed, not isError**; the answer `{"block_ids":[7C497397…, 6CCC4537…], "blocks":[{7C497397…, shown 377B9E91…, takes [{377B9E91…}]}, {6CCC4537…, shown A35C9D36…, takes [{A35C9D36…}, {label "english", take_id DBF2E541…}]}], "note_id"}`; read_note's order **Olá. / Adeus. / Três. / Quatro.** **Her face:** Write shows the four blocks, Quatro. wearing ⑂2 (`12-v255a-write-after`); the bottom bar's receipt, caught by a 0.7 s strip loop during the turn (`11-v255a-receipt`): **"claude-code made the note “u5b ch…and added 2 blocks · ⌥⌘Z undoes Open ›"** — the `.blocks` phrase "added 2 blocks" as built, coalesced with step 5's create_note receipt by the door's 120 s same-client-same-note run (not a defect; the bar truncates the title); Activity **"claude-code added blocks to “u5b ch 1”"** (`18-v255b-activity`). **Her undo:** the Edit menu read **"Undo claude-code's blocks" ⌥⌘Z (enabled)** · "Redo Structural Change" (disabled) (`13-v255a-edit-menu`, `v255a-edit-menu-before.txt`) → ⌥⌘Z → **Três. and Quatro. GONE, her two untouched**, the bar "Undid: claude-code's blocks" (`14`, `14b`) → ⇧⌥⌘Z → **both BACK in place**, "Redid: claude-code's blocks" (`15`, `15b`); step 7's read_note shows the SAME ids `7C497397…` / `6CCC4537…` (the exact-id redo) |
| 7 | V255-b — write new with an anchor / `at: "start"` → the rung's sentence + her Waiting ask; Don't allow | **PROVEN** (15:24:19–15:25:01; `u5/v255b.json`, `v255b-tee.txt`) — ONE turn: `read_note` (four blocks, ids as above), then `insert_blocks(after_block_id = 863A93E3… the FIRST block, [Entre.])` and `insert_blocks(at "start", [Início.])` — **both `isError: true`, each EXACTLY "This client may only read, suggest and write new here. Variorum has asked the author — call again once they answer."** (byte-read from the tee; never the not-shared shape); nothing minted — Write still the four (`16-v255b-write-unchanged`). **Her face:** Settings ▸ MCP's **Waiting, above the tabs: "claude-code asks to edit in “u5b ch 1”" · Answer…** (ONE ask for the two calls; `17-v255b-waiting`); Activity **"claude-code was refused adding blocks to “u5b ch 1” (2 times)"** (muted) above "claude-code read “u5b ch 1”" (`18-v255b-activity`). Answer… → the ask sheet "claude-code asks to edit in “u5b ch 1”" with Once · Always · Don't allow (`19-v255b-ask-sheet`) → **Don't allow** → Waiting gone (`20-v255b-waiting-cleared`) |
| 8 | the re-grant Home · Edit · Always | DONE (15:27) — Shared with AI ▸ Home (wing) ▸ Change… ▸ Edit · Always ("Confirming replaces the grant you opened this from"; `21-regrant-edit-sheet`) → **Home · claude-code · read, suggest, write new and edit · always** (`22-regrant-edit-row`) |
| 9 | V255-c — at edit, after the first block and at the start | **PROVEN** (15:27:18–15:27:46; `u5/v255c.json`, `v255c-tee.txt`) — ONE turn at Home EDIT (no ask — the grant is Always): `insert_blocks(after_block_id = 863A93E3… the first block, [Entre.])` → **landed**, `block_ids [F44C794D…]` + its record; `insert_blocks(at "start", [Início.])` → **landed**, `[8391B134…]`; read_note → **Início. / Olá. / Entre. / Adeus. / Três. / Quatro.** **Her face:** Write shows exactly that order, her caret still in Olá. (`23-v255c-write`) |
| 10 | D8-a (her caret beside the run) · D8-b (her open tail) | **D8-a PROVEN · D8-b's OPEN TAIL NOT REACHABLE as written — an adapted end-of-note leg PROVEN (recorded, not a product finding).** **D8-a** (15:28–15:30; `u5/d8a.json`, `d8a-tee.txt`): Bookcase quick entry `{t:"u5b d8"}Her first line.` ⏎ → the note "u5b d8" in Home (titled by the token), one block, Write; a click past the line's end, ` She keeps typing` typed — BEFORE, the caret after "typing" (`24-d8a-before`); the turn started detached; the moment the tee showed `list_notes` (15:29:24) ` and more.` was typed (15:29:25); `insert_blocks` reached the wire 15:29:29 and landed (`block_ids [E58D83A5…]`). **AFTER (`25-d8a-after`): the AI's block BELOW hers; her block "Her first line. She keeps typing and more."; her caret still at its end**; ` Still here.` then landed IN HER BLOCK (`26-d8a-still-here`). **D8-b:** the chip is in Write's bar under **Aa** ("newlines make blocks: on"); pressed OFF it said "Newlines now stay inside the block in this note — typing and pasting won't m…" (`27-d8b-chip-off`) — and with the chip OFF a tail CANNOT open (`App/Variorum/Shared/EditorBrain/BlockRangeIndex.swift:180–187`: "One-block posts never open a tail"), so the plan's recipe could not produce its expected order; the chip went back ON. With the chip ON, ⏎ is structural and ⇧⏎ (held shift) stays inside the block — measured: at the note's end ⇧⏎ + `Her tail line` made block 2 "6w" (3w → 6w, "block 2/2"), i.e. in-block, no tail (`28-d8b-before`). **The adapted leg (her caret at the note's very end, in the last block):** the turn detached, ` goes on` typed the moment `list_notes` reached the wire (15:32:45), `insert_blocks` landed 15:32:48 (`[1568613D…]`, `u5/d8b.json`) → **AFTER (`29-d8b-after`, `29b`): her "Her tail line goes on" where she typed it, caret at its end, the AI's second paragraph BELOW**; a read turn (`d8b-read.json`, `d8b-read-tee.txt`): **"Her first line. She keeps typing and more. Still here." / "The AI's paragraph.\nHer tail line goes on" / "The AI's second paragraph."** — none of her words lost or moved, the run below her caret's block. **For the orchestrator:** the open-tail case D8's ruling names is not reachable from her Mac keyboard (chip OFF never opens a tail; chip ON's ⏎ is structural and ⇧⏎ in-block) — D8-b as written is a plan premise, not a product red; the headless pin (`MCPInsertBlocksHerEditorTests`) stays its only evidence for a tail |
| 11 | U5a's LIVE LEGS 0, A–C (D optional) | **0 DONE · A PROVEN (Study) · B PROVEN · C PROVEN · D PROVEN** (15:34–15:45; answers `u5/u5a-{A,B,C,D}.json`, the exact wire calls/answers `u5/u5a-{A,B,C,D}-tee.txt`). **Leg 0:** Bookcase quick entry `{t:"vx336 u5a"}Olá.` ⇧⏎ `Tudo bem?` ⇧⏎ `Adeus.` ⇧⏎ `Fim.` ⏎ (held-shift ⇧⏎; System Events dropped the á — fixed in the box with ⌥e a before filing) → **"vx336 u5a", in no book, "block 1/4"** (`30-u5a-fixture`). **Leg A (VX-267):** ONE turn: `add_take(block 1, "Hello.", label "english")` → take `41FCD208…`; ONE `add_takes` (block 2 "All good?", block 3 "Goodbye.") → `476C6B65…`, `20347607…`; the second read_note (from the tee): **every new take's label `claude-code · english`** (never "suggested"), unchosen, block 4 untouched. **Her face:** Takes ▸ expand all — blocks 1–3 each show a card **"choose claude-code · english"**, unchosen, the page unchanged (`31-u5a-A-takes-expanded`; the Study crop `32-u5a-A-card-crop`); Terminal at step 12. **Leg B (VX-253):** her door — block 1's + blank take → `Hi.` → card ▾ Label… → **`english`** (`33-u5a-B-her-english`: block 1 holds her "english" AND "claude-code · english"). ONE turn: `save_lens(name "english", label "english")` → **isError, "label "english" matches more than one take on one block, and a lens shows one take per block. Call again with the same label and take_ids naming the take to show on each of these blocks:" + `{"ambiguous_blocks":[{"block_id":"4EE34C07…","takes":[{"label":"claude-code · english","take_id":"41FCD208…"},{"label":"english","take_id":"C10801F5…"}]}],"ambiguous_count":1}`**; the retry with `take_ids [41FCD208…]` → **`{"lens_id":"06B9122A…","note_id":…,"unmatched_blocks":["5E317F89…"],"unmatched_count":1}`** (block 4 "Fim."). **Her face:** Lenses ▸ + column ▸ Open “english” — **Hello. / All good? / Goodbye. / Fim.** (the last its chosen, unwashed — `34-u5a-B-lens-english`); Activity **"claude-code was refused saving a lens on “vx336 u5a”"** (muted) then **"claude-code saved a lens on “vx336 u5a”"** (`40-activity-all`). **Leg C (VX-253, the legacy form):** her door — block 4's + blank take → `The end.` → Label take… → **`claude-code · suggested · english`** typed by hand (the middle dots by ⌥⇧9; `35-u5a-C-legacy-label`). ONE turn: `save_lens(name "english, legacy too", label "english", take_ids [41FCD208…])` → **`unmatched_blocks []`, `unmatched_count 0`**; read_note `with_lenses` (from the tee): the lens's picks Hello. · All good? · Goodbye. · **"The end." (`claude-code · suggested · english`)** — the legacy form matched as claude-code's own. **Her face:** the "english, legacy too" column **Hello. / All good? / Goodbye. / The end.** (`36-u5a-C-lens-legacy`). **Leg D (`pin_chosen`):** ONE turn: `save_lens(name "as it reads", pin_chosen true)` → **`unmatched_count 0`**; her ✓ on block 2's "claude-code · english" ("All good?" now chosen — `37-u5a-D-her-choose`); Lenses: **"as it reads" still shows "Tudo bem?"** while the note reads "All good?" (pinned, not a fall-through — `38-u5a-D-as-it-reads`) |
| 12 | the Terminal pass (leg A's card, V255-c's order, one `insert_blocks` + ⌥⌘Z); back to Study | **PROVEN** (15:45–15:49; captures `live/t/`) — Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control took; `00-theme-terminal`). **Leg A's card in Terminal:** "vx336 u5a" in Takes — block 1's card "choose claude-code · e…" beside her "choose english", block 3's "choose claude-code · e…" (`01`, `03`, the crop `02-u5a-A-card-crop-block1`) — **the label truncates in Terminal's monospace at a margin-grid card's width** (Study showed it whole; the stored label is `claude-code · english`, read from the wire at step 11) — a face note for VX-234, not a red. **"u5b ch 1" in Write:** Início. / Olá. / Entre. / Adeus. / Três. / Quatro. (`04-v255c-write-terminal`). **ONE turn** `insert_blocks("u5b ch 1", [Fim.])` → landed `[C3E937CA…]` (`u5/t-insert.json`, `t-insert-tee.txt`); the bar's receipt **"claude-code added a block · ⌥⌘Z undoes Open ›"** (the strip loop, `05-terminal-receipt-added-a-block`); Write shows Fim. last (`06`) → her **⌥⌘Z → "Fim." gone, "Undid: claude-code's blocks"** (`07`, `07b`). Theme back to **Study** (`live/s/41-theme-back-study`) |
| 13 | cleanup → cmp SAME vs A1, prefs 0 differ, fingerprint SAME, instances quit, claim released; THE RESULT LINE | DONE (15:48–15:50) — **the Debug app quit BY BUNDLE ID** (`tell application id "io.lduarte.Variorum.debug" to quit`; both strict guards empty, no `variorum-mcp` shim, her `/Applications` app never running). **The one window key** (`vmk2_clau…`, the tab key) searched WHOLE in `vx336-screens/u5/`, `~/.claude.json`, the scratch project's transcripts, `notes/` and the scratchpad outside the key folder → **0 files**; then the key, the copied text and the scratch `u5-mcp.json` DELETED, the clipboard emptied (0 bytes). **No `-s local` registration was ever made** (`claude mcp get variorum-dev` in the scratch project → "No MCP server named \"variorum-dev\"…"; the scratch project has no `~/.claude.json` entry). **Her user-scope servers AFTER `['linear-server', 'variorum']`, `bc64543e2f4e8e58` — SAME** (`u5/userscope-post.txt`). **Prefs:** the window added 5 keys (`currentBlock.<id>` ×3, `postMode.<id>`, `takesViewMemory.<id>`) and changed 5 (`IdleCommitSweepMark.Variorum-dev`, the Settings window frame, `openNotes.remembered.ids`/`.recency`, `variorum.backup.log`) → `defaults import prefs-pre.plist` + `defaults delete` of the 5 → re-export **1,596 keys, 0 added · 0 removed · 0 changed** (`u5/prefs-post.plist`). **The dev store:** `restore.sh …/scale-prestage-20261014T211517Z` → **"Restored (verified)"** (`u5/logs/restore.log`), a second `cmp` of all five files **SAME**, the sha256 set **EQUAL** to the A1 copy's (`store-hash-restored.txt` = `store-hash-pre.txt`) — Standard, unlocked, the Study voice and claude-code's pre-window binding and grants back with it; every scratch note, book, lens and take gone with the window. `Backups/` listing **unchanged** (57 entries; no new backup from the launch); `castle-W1-20261013` untouched. No stray `default.profraw`; the tree clean. **RELEASED 15:49:56 MDT** (`Tools/stage release --who vx336-u5` → STAGE RELEASED; `status` → STAGE FREE), ~37 of the 110 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx336-u5` 15:13:00–15:49:56 MDT, RELEASED (~37 of 110 min), the batch first, the SEAM,
then the coordinator's "continue".
- **The Mac batch (31 suites, `vx336-u5`):** 251 tests in 31 suites passed — 244 passed · 7 gated capture skips · 0 failed; `** TEST EXECUTE SUCCEEDED **`.
- **V252-a PROVEN:** `create_note` with `section_id` answers `block_ids`, `blocks`, `note_id`, `section_id`, `tag_ids`, and its `blocks` equal `read_note
  with_ids`' records; the note filed UNDER its chapter "um" in the book's Outline in the same call.
- **V255-a PROVEN:** `insert_blocks` with no anchor at WRITE NEW lands at the end in order; the receipt says "added 2 blocks" (coalesced with the
  create_note receipt by the door's 120 s same-note run); Activity "claude-code added blocks to “u5b ch 1”"; the Edit menu "Undo claude-code's blocks"
  → ⌥⌘Z walks both back, her two untouched → ⇧⌥⌘Z returns them with the SAME ids.
- **V255-b PROVEN:** at write new, an `after_block_id` and `at: "start"` each answer exactly "This client may only read, suggest and write new here.
  Variorum has asked the author — call again once they answer."; nothing minted; ONE Waiting ask "claude-code asks to edit in “u5b ch 1”"; Activity
  "…was refused adding blocks to “u5b ch 1” (2 times)"; her Don't allow clears it.
- **V255-c PROVEN:** at EDIT, after the first block and at the start → Início. / Olá. / Entre. / Adeus. / Três. / Quatro., in Write.
- **D8-a PROVEN:** her words typed while the turn ran stay in her block, the AI's block lands below, her caret kept, her next words land in her block.
  **D8-b:** the OPEN TAIL is not reachable from her keyboard (the chip OFF never opens a tail — `BlockRangeIndex.swift:180–187`; the chip ON makes ⏎
  structural and ⇧⏎ in-block, measured), so the plan's recipe could not run as written — a plan premise, not a product red; the adapted end-of-note
  leg PROVEN (her in-block words where she typed them, the AI's paragraph below).
- **U5a's legs:** **A PROVEN** (every new take reads `claude-code · english`, never "suggested"; the cards in Takes in Study, and in Terminal where the
  label TRUNCATES at the card's width — a face note for VX-234); **B PROVEN** (the ambiguity refusal naming block 1's two takes, the `take_ids` retry
  with `unmatched_blocks` [block 4], the lens column Hello. / All good? / Goodbye. / Fim., both Activity lines); **C PROVEN** (the hand-typed
  `claude-code · suggested · english` matched as claude-code's own, `unmatched_count` 0, "The end." in the column); **D PROVEN** (`pin_chosen`
  `unmatched_count` 0; after her ✓ the lens still shows "Tudo bem?").
- **The Terminal pass PROVEN:** "claude-code added a block · ⌥⌘Z undoes Open ›", her ⌥⌘Z → gone; V255-c's order in Terminal; back to Study.
- **Posture:** dev store cmp-SAME vs A1 (sha256 set equal), prefs 0 differ (1,596 keys), user-scope fingerprint SAME (`bc64543e2f4e8e58`), posture
  Standard/unlocked, castle-W1 untouched, no `-s local` registration, the whole-key grep 0, the clipboard empty, no instance left.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261014T211517Z`.

**Noticed, not fixed (no product change under the claim):** (1) **D8-b's premise** — the open tail the D8 ruling names cannot be opened from her Mac
keyboard (see step 10); the headless `MCPInsertBlocksHerEditorTests` is its only tail evidence; (2) **for VX-234** — in Terminal the take card's
header truncates "choose claude-code · e…" at the margin-grid width (Study shows it whole); (3) the coalesced receipt "claude-code made the note
“u5b ch…and added 2 blocks" is the existing 120 s same-client-same-note run (`MCPDoor.receiptWindow`), not this unit's; (4) machinery: `claude -p`'s
`--allowedTools` is variadic and eats a trailing prompt (the runner passes the prompt on stdin); System Events' `keystroke` drops non-ASCII (á, ·) —
typed instead as ⌥e a and ⌥⇧9.

### THE ORCHESTRATOR ON U5's WINDOW (2026-10-14 ~15:55 MDT)

- **Verified, not trusted:**
  - `Tools/stage status` reads FREE; both strict instance guards are empty; the tree is clean at `617c5498`.
  - Her user-scope fingerprint re-read by the orchestrator: `['linear-server', 'variorum']` `bc64543e2f4e8e58`, SAME.
  - 49 Study and 9 Terminal captures exist. Four were viewed by the orchestrator: V252-a's Outline (the note under
    "um"), V255-a's Edit menu ("Undo claude-code's blocks"), leg A's Takes board, and the Terminal card crop.
  - **U5 (U5a + U5b) is PROVEN**, and its members' acceptance is closed. VX-267, VX-253, VX-252 and VX-255 close at the
    merge.
- **D8-b's premise was the orchestrator's error, not a product red.** The rulings' D8 leg assumed she can open a tail
  from the keyboard. She can't on the Mac: with the segmentation chip ON, ⏎ is the structural gesture; with it OFF, ⏎ is
  content and no tail crystallizes. The runner read it at `BlockRangeIndex.swift:180–187` and measured it; AppSpec §7
  agrees: "the tail opens only from a newline arriving as text". The adapted end-of-note leg passed: her words stayed
  where typed, and the AI's block landed below. The open-tail case's evidence is the headless pin
  `MCPInsertBlocksHerEditorTests` (D8's tail arm). Recorded; nothing owed.
- **Two notes, neither a finding:**
  - VX-352 was minted (the Terminal card truncation; it is on VX-234's list too).
  - `create_note`'s and `insert_blocks`' receipts merged into one line by the door's existing 120 s
    same-client/same-note rule (`MCPDoor.receiptWindow`), as designed.
- **The machinery lessons**, for every later runner:
  - `claude -p --allowedTools <list>` swallows a trailing prompt, so pass the prompt on stdin.
  - System Events drops `á` and `·`, so type them by their option chords.
  - `Tools/WalkKit/wl2` must be compiled per worktree, since `guard.sh <pid>` needs it.
- **U6 is SPLIT before its spawn** (the lesson of U5b: an implementer spends ~450k reading in, so a four-member unit
  ran three sessions):
  - **U6a** = VX-311 (`duplicate_note`) + VX-298 (`show_in_app`'s Compare target, `link_versions`' Open ›): the
    Compare pair. Headless pins, plus a Mac `build-for-testing` if app code moves. Its live legs are written for U6b's
    window.
  - **U6b** = VX-330 (the Book Panel's chapter row) + VX-342 (the one word) + U6's shared window: the Mac batch, the
    live round, the Compare board and sherlock's Book Panel walked in both voices.
  - Each gets a narrow reading list.
  - Before ANY edit to `WorkspaceModel`, `ShellRouter`, `Registry/ShellActions.swift` or a registry file, the
    implementer records it and stops; the orchestrator tells vx-283 first.


## U6a UNIT RECORD — Compare from the wire: VX-311 · VX-298 (opus-implementer, from 2026-10-14 ~15:40 MDT)

**NOT DONE YET (THE CLOSER's first line — a fresh, narrow opus-implementer from 2026-10-14 ~17:30 MDT, briefed by THE
ORCHESTRATOR'S RULING ON U6a's ONE OPEN DECISION, (a)): the ruled pin is WRITTEN (row 6a) but NOT RUN — it is an app
test, so its red on `vx336-u6-red` and its green on `vx336-u6` are U6b's batch to read (PENDING). The live legs are
WRITTEN, not run (U6b's window). Everything else is DONE: the three clears (6b), both revert checks (7), the headless
finals (8), both Mac products (8b), the legs' final form and the suite list (9).**
No stage claimed, no app launched, no `xcodebuild test`, no store touched by this session.

**(The build continuation's first line, kept:) NOT DONE YET (the build continuation's first line, per the contract — 2026-10-14 ~17:05 MDT): pieces 7–9 (the revert
checks, the headless finals, the LIVE LEGS' final form) are NOT run; the build STOPPED after piece 6 for THE ONE OPEN
DECISION below (the Compare landing's "one round" — its router clears are outside the lane go).** Pieces 2–6 are built,
pinned red-first and green, and the Mac `build-for-testing` SUCCEEDED; no stage claimed, no app launched, no store
touched. The continuation's exact steps are in LIVE STATUS rows 7–9.

**(Piece 0's first line, kept:) NOT DONE YET (the record's first line, per the contract): no product code, no pins.** This session read in, traced
both members, and wrote the design and its forks below. It STOPPED for the orchestrator's rulings (the brief reserves
"which op `duplicate_note` wraps", "where the copy lands and what reach decides it", and the edges the tickets leave
open), and for the LANE edits that need vx-283 told first (`Registry/CommandRouter.swift`, possibly
`Registry/Capability.swift`). No trace reached the editor seam (the Compare board's cells are `PaneSurface` panes over
`PaneTextAuthority`, but the design only calls the board model's existing slot API — no seam file is edited).

**THE BUILD CONTINUATION (a FRESH opus-implementer, from 2026-10-14 ~16:15 MDT — pieces 2–9).** Built from this record
alone: the traces, D-311-1…8, D-298-1…8, the LANES and THE ORCHESTRATOR'S RULINGS ON U6a's FORKS below (binding).
Read in, in its own context: CLAUDE.md + its canon; this record's header, Hard rules, LIVE STATUS, Cross-run
coordination, the U6 BRIEF items 1–2, this UNIT RECORD whole and the rulings; U5b's D1 + its RULINGS; `notes/MCPSpec.md`
in full; `notes/SessionResiliencyProtocol.md`'s implementer section; and the code each design item names, every pointer
re-verified at `6502db0d`. The lane go (the orchestrator's brief): ONE stored property
`CommandRouter.pendingCompareLanding: CompareLanding?`, `CompareLanding` in `Features/Takes/CompareBoardView.swift`;
nothing in `WorkspaceModel`, `ShellRouter`, `ShellActions.swift` or any other registry file. Headless only (no
`xcodebuild test`, no app launch, no store). Logs: `notes/plans/vx336-screens/u6a/logs/` (gitignored).

**Read in (in full, this session's own context):** CLAUDE.md + its canon; this record's header, Hard rules, LIVE STATUS,
Cross-run coordination, Her rulings, the U6 BRIEF, THE ORCHESTRATOR ON U5's WINDOW, U5b's D1 + its RULINGS + D6;
`notes/MCPSpec.md`; `notes/SessionResiliencyProtocol.md`'s implementer section; VX-246's U3 act table (the COPY row). Code:
`MCPShowTool.swift`, `MCPNavigator.swift`, `MCPDoor.swift` (agentShow/openShow), `CompareBoardView.swift` (the model
whole, the view's lifecycle), `NotePicker.swift`, `Queries.notePickerNotes`, `Queries.blockKinship` + the lineage walk,
`versionPeerPosts`/`versionPeerSplit`, `MCPWriteTools+LinkVersions.swift`, `Operations+Versions.swift` (duplicate, the
copy machine), `Operations+NoteVersions.swift` (save/promote), `Operations+MCPCarriage.swift` (`saveVersion`), the
wire's `create_note`/`save_version` arms, `MCPWriteTools+WingMove.swift` (the two-sided guard), `MCPMintedBlocks.swift`,
`MintedBlockTakes`, `copyFan`, `registerMintedContainerEntry`, `mcpNoteFacts` + the fence legs, `MCPGrantRule.decide`.

### LIVE STATUS — U6a's pieces (flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | read-in, the traces, the design, the forks, the lane flags, the draft live legs | DONE (this commit) |
| 1 | the orchestrator's rulings on F-1…F-9 + the lane edits told to vx-283 | DONE (`6502db0d` — THE ORCHESTRATOR'S RULINGS ON U6a's FORKS; vx-283 told, the CommandRouter go in the build brief) |
| 2 | VX-311 seam (core): the copy machine says what it minted (`PlacementCopyOutcome`/`PostCopyResult` carry `[MintedBlockTakes]`; `MintedBlockTakes` gains `sourceBlockID`; `duplicateAsVersion`'s body extracted, behaviour unchanged) + the encoder's one field | DONE (this commit) — `Operations+DocumentImport.swift`: `MintedBlockTakes.sourceBlockID: String?` (nil for every mint) + an internal memberwise init (the mint init delegates to it). `Operations+Versions.swift`: `PostCopyResult.blocks: [MintedBlockTakes]` (a `var`, default `[]`, outside its custom `==`; `copyPost` fills it from `outcome.minted`, the outline and the saved version keep `[]`); `PlacementCopyOutcome.minted` appended per copied block from the rows just written — the copy's ACTIVE takes sorted by the copies' own `(fanPosition, id)`, `shownTakeID` = `[chosenCopyID, defaultCopyID]`'s first ACTIVE id, else the first active, else the default (read_note's rule, `MCPNoteStructure.swift:152`), `sourceBlockID` = the source block; `duplicateAsVersion`'s transaction body extracted byte-for-byte into internal `duplicateAsVersionBody(_:_:)` (her door calls it inside its own write, registration unchanged). `MCPMintedBlocks.records` emits `source_block_id` only when set. **Behaviour unchanged, measured:** `swift build` clean; the copy family and the minted-answer suites — `DuplicateCarriesTagsTests`, `VersionOperationsTests`, `NoteVersionsTests`, `MCPMintedBlocksActsTests` + 2 more core suites, `MCPMintedAnswerServerTests`, `MCPInsertBlocksServerTests` (both suites), `MCPCarriageServerTests` — **90 tests in 10 suites green, EXIT 0** (`p2-seam-regress.log`) |
| 3 | VX-311 pins (core acts + wire), RED on the seam tree | DONE (this commit) — **The honest form (U5b's precedent, pieces 4–5):** the WIRE pins compile on the seam tree (`MCPWriteAct` read by `rawValue`, the fence sentence a literal) and run RED by absence; the CORE acts pins name the new `Operations.duplicateNoteForClient`, so they cannot compile on the seam tree — they land with the fix (piece 4) as NEW-API state pins, green by construction, and piece 7's revert moves them aside. NEW `Tests/VariorumMCPTests/MCPDuplicateNoteServerTests.swift`, 7 tests: `theCopyLandsBooklessInTheSourcesWingAndAnswersWhatItMinted` (a 3-block source in a book, block 2 fanned with its second take chosen + an ARCHIVED blank take, a tag; note READ + Home write new → `note_id`, `source_note_id`, `landed` "the Pool of Home"; `blocks` == `read_note with_ids` of the copy record for record, `[1, 2, 1]` active takes, the chosen copy shown, `block_ids` kept, `source_block_id` per record in order; **`Queries.blockKinship(source, copy)` maps every copy block to its source block — the VX-311 point**; bookless, wing '', the tag riding; the source's text and book untouched; ONE `claude-code's duplicate`; the receipt `duplicate` on the copy, Open › `.note(copy)`; ⌥⌘Z tombstones the copy, ⇧⌥⌘Z revives it) · `aCopyInAnotherWingLandsInThatWingsPool` ("the Pool of “research”", wing kept) · `anUnreachableSourceAnswersTheOneNotSharedShapeAndMintsNothing` (unknown id = `MCPRefusalCopy.words(.notShared, .note)`; another wing's note, a version, a tombstoned note, a scraps group, an UNREACHED Private note — each byte-identical; nothing minted, no entry) · `aBookLevelWriteNewHearsTheWingsRefusalAndAsksForTheWing` (the wing's not-shared words; her ask = the wing '' at write new) · `aFencedSourceUnderAPerAskGrantRefusesInOneSentenceAndMintsNothing` (a Private note and a journal entry READ through per-ask grants → the one sentence; nothing minted, no entry, no ask) · `onceGrantsOnBothSidesSpendAsOneAndARefusedActSpendsNothing` (a once note READ grant survives the wing's refusal; with a once wing write new both spend on the landing; the next call refuses) · `aCallWithoutANoteIsRefusedAtTheParse`. APPENDED (nothing modified) to `MCPHerEditorServerTests`: `aWireDuplicateAsksForHerFlushAndCopiesHerLatestText` (the log `["flush:duplicate_note", "act"]`; the copy renders her pending words). **RED on the seam tree (`2836171c` + these files): 8 of 8 new tests failed, 16 issues, 16 test × line pairs, each on its designed line** — the answers' `isError` (`:111`, `:180`, `:316`, HerEditor `:518`), their JSON (the shared helper's "Code=3840" at the `@Test` lines `:86`, `:169`, HerEditor `:508`), the sentences (`:220`, `:251`, `:287` ×2, `:309`, `:337`), the ask (`:252`), the spend (`:319`), the flush log (HerEditor `:519`); the 13 existing editor pins GREEN (`p3-pins-red.log`, `p3-pins-red.pairs`) |
| 4 | VX-311 fix: `Operations.duplicateNoteForClient` + `duplicate_note` on the wire (+ the app's words) | DONE (this commit) — **core:** NEW `Operations+MCPDuplicate.swift` — `duplicateNoteForClient(_:undoLabel:guardedBy:) -> PostCopyResult`: ONE `database.write`, the guard FIRST, then `duplicateAsVersionBody` (her door's body, piece 2's extraction); after it `registerMintedContainerEntry(label:)` (her door's own helper — the inverse answers `false` and retires the entry when the copy is already dead; the redo revives only on its undo's stamp). `Operations+MCPWrites.swift`: `MCPWriteAct.duplicate` (raw `"duplicate"` → "claude-code's duplicate"; undoable). **wire:** NEW `MCPWriteTools+DuplicateNote.swift` — `duplicateFencedWords` (D-311-3's sentence); `performDuplicateNote`: one snapshot read (standing, the note's facts and title, its RESOLVED wing's title), the note at READ (`consumes: true`) — a refusal logs the note and raises the note's ask at read; then THE FENCE (`facts.fence != nil` → the one sentence, logged on the note, NO ask — checked BEFORE the wing so no wing ask is raised for an act that can never land); then `decideWing(facts.wingID, .writeNew, consumes: true)` — a refusal logs the wing and raises the wing's write-new ask; then `land` (logged on the SOURCE note, `logsReceiptTitle: false`; nothing spent there) around `duplicateNoteForClient` guarded by `guardDuplicate` (both sides + the fence re-decided on ONE standing read inside the act's transaction; the once grants of both sides consumed as one sorted union there). The answer `{note_id, source_note_id, block_ids, blocks, landed}` (`MCPMintedBlocks.records(copy.blocks)`, `landedWords` — `move_note_to_wing`'s); the receipt `.duplicate`, target the COPY (its title), Open › `.note(copy)` (F-5 (a)). `MCPWriteTools.swift`: `Job.duplicateNote(noteID:)`, tool `duplicate_note`, `flushesHerEditorFirst` **true** (D-311-6's reason at the arm — the COPY class beside `save_version`), parse (`note_id` required) and perform. `MCPToolCatalog.swift`: `duplicateNote` in WRITE NEW, `scopes: [.wing]`, schema `note_id` only, `additionalProperties: false`, the description (FOR VX-234). **app (compiled at piece 8):** `MCPPaneCopy.swift` — refused "duplicating “X”" / on the wing side "duplicating a note in “X”" (UXR1-1's two-sided rule), allowed "duplicated “X”" (+ "(n times)"), the receipt phrase "duplicated “X”" / "made N duplicates". **Justified edits (the ritual):** `MCPServerTests` — the write-new set gains `duplicate_note`; `MCPWriteServerTests` — the suggest proof's completeness gains a `duplicate_note` call aimed at her note (refusing at the rung). **NEW-API PINS (green by construction, state):** NEW `Tests/VariorumCoreTests/MCPDuplicateNoteActsTests.swift`, 4 tests — `theRowsAreHerDuplicateAsVersionsExactly` (her door and the wire on one SEALED source in a wing with a book, a fan, a tag and a date: the two copies' shapes EQUAL — title, profile, date, wing, never locked, rendered takes, the tag, no book, one `derived_from` per block to its source block, one `version_of`) · `aThrowingGuardWritesNothing` · `oneEntryUndoesAndRedoesTheCopyAndACopySheDeletedStaysDeleted` (`undoReporting` changed/true, the copy tombstoned, the source never; redo the same copy; after her Delete the undo is QUIET and the entry RETIRES, both stacks empty, her stamp kept) · `theRecordsAreTheCopysLiveFans` (active takes in fan order with labels; an ARCHIVED chosen falls back to the default — read_note's rule; `sourceBlockID` per record; the archived take rides outside the record). **GREEN:** the VX-311 pins and the two justified-edit suites — **MCP 45 / 4 + core 4 / 1, EXIT 0** (`p4-pins-green.log`); the whole MCP target **272 / 58 with ONE issue**: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` exceeded its 15 s bound (16.3 s) under load average 9 (another worktree building) — untouched by this change; **re-run alone it PASSED in 1.0 s, its suite 3/3** (`p4-mcp-target.log`, `p4-timelimit-rerun.log`); the finals (piece 8) re-run the whole package |
| 5 | VX-298 pins (headless show + link receipt; the app's landing pins compiled) RED | DONE (this commit) — **headless** NEW `Tests/VariorumMCPTests/MCPShowCompareServerTests.swift`, 5 tests (the target read through `showCompareParts` — REFLECTION on the case label `compare` — so the file names no symbol the old tree lacks; the fake app is `MCPShowServerTests`' own): `aPairAndUpToThreePeersAreDeliveredInColumnOrderNeverSpendingAOnceGrant` (ONCE read grants only: A|B, then A|D,B,C in the named order, `shown: true`; each once grant still reads afterwards) · `theParseRefusesEveryMalformedCompareNamingWhatIsWrong` (8 forms: no `peer_ids`, no `note_id`, a non-array, `[]`, four, a non-string, a repeat, `note_id` among them — each its own sentence; nothing moved) · `anUnreachableAnchorOrPeerAnswersTheOneNotSharedShapeLoggedOnThatSide` (an unshared anchor, an unshared peer, an unknown peer after a readable one, a version's id → the ONE `notShared` note words; the activity row on the refusing note) · `anotherWingsPeerAndAnArchivedPeerRefuseAfterTheDecisionsAndAnArchivedAnchorShows` (another wing's peer → the wings sentence; an archived peer → “shelved” is archived…; an unreadable peer beside another wing's still answers not-shared — the decisions first; an ARCHIVED anchor shows, P-VX298-2) · `aCompareShowMovesNothingWhileSheIsAway`. APPENDED (nothing modified) to `MCPLinkVersionsServerTests`: `theReceiptsOpenOpensTheTwoInCompare` (the receipt's `show` is compare A|B). **RED on the old tree (`6a8423c4` + these files): 6 of 6 new tests failed, 25 issues** — every compare call answered the old `target must be …` sentence (the pair's `isError` `:96` and its JSON at `:82`; the eight parse forms `:137` ×8; not-shared ×4 `:165` and the log side ×4 `:167`; the wings `:195`, archived `:199`, decisions-first `:203`, the archived anchor `:207`/`:208`; away `:226`); the receipt's show `MCPLinkVersionsServerTests.swift:251` (it opened note A); the 3 existing link pins GREEN (`p5-pins-red.log`, `p5-pins-red.pairs`). **app** NEW `App/Variorum/VariorumTests/MCPCompareLandingTests.swift`, 5 tests — `thePostureOpensRelatedOnlyOnlyWhenEveryNamedPeerSharesLineage` (the pure rule: a pair with kin ON, none OFF, mixed OFF, all ON) · `aLandingReplacesTheColumnsExactlyAndReleasesADepartingPeersLivePane` (twin + an empty slot → stranger, other exactly; the twin's live pane released; `onNotesLeft == [[twin]]`; related-only off) · `theFirstProjectionHoldingEveryLandedPeerSetsThePostureOnce` (a projection without the peer decides nothing; the duplicate's pair ON; her toggle off survives a later projection; unrelated OFF with the column whole; mixed OFF) · `aParkedLandingIsConsumedOnlyByItsOwnNotesBoard` · `theNavigatorDeliversCompareOnHerOwnRoad` (`.navigate`, the landing parked, `applied == [.compare]`; a note that never registers → `partialShowWords`, nothing parked, no mode switch). **RED on the old tree BY COMPILATION — stated, not measured** (every symbol it names is absent there; the brief's honest form). Compiled by piece 8's `build-for-testing`; RUN in U6b's batch |
*[removed for publication]*
| 6a | the ruled pin — the Compare landing's ONE ROUND (THE ORCHESTRATOR'S RULING ON U6a's ONE OPEN DECISION, (a)) | WRITTEN (`a2e6dfd6`; the closer) — APPENDED (nothing modified) to `App/Variorum/VariorumTests/MCPCompareLandingTests.swift` (the suite "VX-298 — Compare from the wire: the delivery, the board's landing, its posture"; the lens clears have no router-suite pin of their own — `pendingLensLanding` is asserted only in `MCPNavigationTests:109` — so the compare suite, which owns the world and the delivery scaffold, is the home). Two tests, each parking the landing through the REAL delivery (`door.agentShow(.compare(anchor, [stranger]))` on a detail registered for the anchor, the frontmost main window), pre-empting it before any board consumes it, asserting the router's `pendingCompareLanding == nil`, then driving HER OWN ⌘5 on the anchor (`requestMode(.compare)` + `noteMode(.compare)`, a fresh `CompareViewModel` whose `onAppear` consume and two observation adopts run in the board's own order) and asserting HER columns: `peerSlots == [twin]` (the auto-filled linked version — the anchor's `duplicateAsVersion` copy) and `relatedOnly` at her default ON. `aLandingSheOutrunsWithAnotherModeIsDroppedAndHerOwnCompareKeepsHerColumns` (the landing kept across the Compare report — the ordering-safety half — then her ⌘2: `requestMode(.takes)` + `noteMode(.takes)` drops it) · `aLandingWhoseNoteLeavesBeforeTheBoardTakesItIsDroppedAndHerOwnCompareKeepsHerColumns` ((i) another note's `registerDetail` drops it, the late/stale unregisters no-ops, back to the anchor, her ⌘5; (ii) her ⌘1 back to Write first — the refinement `c30fa9a7` adds, so the teardown races a board that is NOT yet mounted, as the modeled world requires — then parked again, a genuine `unregisterDetail` drops it, the anchor re-opened, her ⌘5). **Red on the one-property tree BY ASSERTION, not compilation** (every symbol it names exists at `a846a5f1`): expected there — test 1: the `== nil` after ⌘2 and both her-columns expectations (the board lands `[stranger]`, the filter off); test 2: both `== nil` drops and both her-columns pairs. **The expected red on `vx336-u6-red` — 2 of 7 tests failed, 9 issues, these test × line pairs:** `aLandingSheOutruns…` at `MCPCompareLandingTests.swift:272` (the drop after ⌘2), `:239` and `:241` (her columns: `[stranger]`, the filter off); `aLandingWhoseNoteLeaves…` at `:300` (the other note's registration), `:239`, `:241`, `:317` (the teardown), `:239`, `:241` (`:239`/`:241` are `expectHerColumns`' two expectations, reported once per call). The 5 earlier tests GREEN there. **PENDING: run red on `vx336-u6-red` and green on `vx336-u6` in U6b's batch** (row 8b's products; THE MAC SUITES FOR U6b's BATCH) |
| 6b | the fix — the three clears in `CommandRouter.swift`, one beside each lens clear | DONE (this commit; the closer) — `registerDetail` drops a landing parked for another note (`:130–132`, after the lens twin), `unregisterDetail` drops it at a genuine teardown (`:155`), `noteMode` drops it once the detail reports a mode other than `.compare` (`:470–472`); 7 lines, nothing else in `CommandRouter.swift` (the property's comment untouched) or any other registry file. **The main road traced against the clears:** the detail registers once per note (`PostDetailView.swift:554`, `onAppear`) and a mode switch is its `@State` reported through `noteMode` (`:634`), so the navigator's park → `requestMode(.compare)` → the detail's `.compare` report KEEPS the landing and the board consumes it on appear (or, already mounted, on change) — the lens landing's exact shape, proven live at 13n-b. **The pin's green: PENDING for U6b's batch on `vx336-u6`** (an app test; nothing app-side runs here) |
| 7 | revert checks (announced here first, committed before reverting) | **DONE (the closer — both as expected).** **VX-311 — DONE, as expected** (announced `8fe762f2`, run on that committed tree): `MCPDuplicateNoteActsTests.swift` moved aside, `git show 6a8423c4 -- Sources/ \| git apply -R` (`Operations+MCPDuplicate.swift` and `MCPWriteTools+DuplicateNote.swift` deleted, `MCPWriteAct.duplicate`, the Job/parse/perform arms and the catalog entry reverted); `swift build --build-tests` EXIT 0. `MCPDuplicateNoteServerTests|MCPHerEditorServerTests`: **21 tests, 8 failed, 13 passed, 16 issues; the 16 test × line pairs IDENTICAL to piece 3's (`diff p3-pins-red.pairs p7-311-red.pairs` empty)** (`p7-311-red.log`). The justified edits, `MCPServerTests|MCPWriteServerTests` (24 tests, 2 issues): **each red on the expectation it feeds** — `everyDeclaredToolIsHandledAndEveryHandledToolDeclared` at `MCPServerTests.swift:259` (the write-new set the edit extended at `:262`), `aSuggestGrantProvablyCannotModifyAnExistingTake` at `MCPWriteServerTests.swift:338` (the completeness the appended call at `:326` feeds) (`p7-311-justified.log`). **Restored:** `git checkout HEAD -- Sources/ Tests/`, the aside copy `cmp`-SAME as the restored pin and removed, `git status` empty, `git diff --quiet HEAD`; rebuilt EXIT 0 and **green: MCP 45 / 4 + core 4 / 1, EXIT 0** (`p7-311-restore-green.log` — piece 4's exact counts). **VX-298 — DONE, as expected** (announced `aebd2317`, run on that committed tree): `git show a846a5f1 -- Sources/ \| git apply -R` (`MCPShowTool.swift`, `MCPToolCatalog.swift`, `MCPWriteTools+LinkVersions.swift` reverted); `swift build --build-tests` EXIT 0. `MCPShowCompareServerTests|MCPLinkVersionsServerTests`: **9 tests, 6 failed, 3 passed, 25 issues; the 25 test × line pairs IDENTICAL to piece 5's (`diff p5-pins-red.pairs p7-298-red.pairs` empty)** (`p7-298-red.log`). No justified test edit exists for VX-298 (`a846a5f1` touched no `Tests/` file). **Restored:** `git checkout HEAD -- Sources/`, `git status` empty, `git diff --quiet HEAD`; rebuilt EXIT 0 and **green: 17 / 4 (the VX-298 pins + `MCPShowServerTests` + `MCPWingReachServerTests`), EXIT 0** (`p7-298-restore-green.log` — piece 6's exact counts). (The app pins are red by compilation, or — the closer's 6a — by assertion on `vx336-u6-red`; neither is revert-run here.) The steps as written: **after the ruling** (its outcome touches only app files, so these headless steps stand as written). **VX-311:** announce in this row and commit; on the committed tree `git show 6a8423c4 -- Sources/ \| git apply -R` (the fix's package files: `Operations+MCPDuplicate.swift` and `MCPWriteTools+DuplicateNote.swift` removed, `MCPWriteAct.duplicate`, the Job and the catalog entry reverted — VX-298's later catalog hunks are disjoint); move `Tests/VariorumCoreTests/MCPDuplicateNoteActsTests.swift` (new-API) aside to `notes/plans/vx336-screens/u6a/prerevert-311/`; KEEP the two justified edits → expect `p3-pins-red.pairs`' 16 pairs IDENTICAL (`diff` empty) plus each justified edit red on its edited line (`MCPServerTests` write-new set, `MCPWriteServerTests` completeness); restore (`git checkout HEAD -- Sources/ Tests/`, the aside folder removed, `git status` clean) and re-run green. **VX-298:** `git show a846a5f1 -- Sources/ \| git apply -R` (`MCPShowTool.swift`, the catalog's `show_in_app` + `link_versions` hunks, `MCPWriteTools+LinkVersions.swift`) → expect `p5-pins-red.pairs`' 25 pairs IDENTICAL; restore; green. (The app pins are red by compilation only — stated, not revert-run.) |
| 8 | headless finals (MCP · core · workbook) | **DONE (the closer, on `b139044e`'s sources — the final package tree; the clears are app-only) — `swift build --build-tests` EXIT 0, then `swift test --skip-build` on the whole package: MCP 278 / 59 · core 2,871 / 333 · workbook 40 / 6, EXIT 0, zero ✘ — exactly the expected counts below** (`p8-finals.log`). `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` PASSED in the whole run at **14.889 s against its 15 s bound** (load average 19–29 at the end — another worktree building), so no re-run was needed; 0.11 s of margin is VX-353's point, recorded for it, the pin untouched. The plan as written: `swift build --build-tests` then `swift test --skip-build` on the whole package (expected, from U5b's finals 264/57 · 2,867/332 · 40/6: **MCP 278/59** — +7/+1 duplicate, +1 HerEditor, +5/+1 compare, +1 link — **core 2,871/333**, workbook 40/6; `MCPHarnessTimeLimitTests` is load-sensitive — two full-target runs this session exceeded its 15 s bound at load 9 and 67, each passing alone in ~1 s — run the finals on a quiet machine or re-run that suite alone and say so). |
| 8b | the Mac products for U6b: `vx336-u6` (the final tree) + `vx336-u6-red` (ONLY the three clears reverted) | **DONE (the closer).** Both built from `App/Variorum/` with `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/<name> build-for-testing`, detached to a log and polled in the foreground; 63–66 GiB free throughout (2.5 GB each). NO `xcodebuild test`, no launch, no store. **`App/Variorum/DerivedData/vx336-u6` — the final tree, `c30fa9a7`** (status clean): TEST BUILD SUCCEEDED, XCB-EXIT 0, zero `error:`, no warning in either touched file (`p8b-mac-final-2.log`; the first build on `398a9d26`, `p8b-mac-final.log`, was superseded by the pin's (ii) refinement). **`App/Variorum/DerivedData/vx336-u6-red` — `c30fa9a7` with ONLY the three clears reverted:** made by `git show 4ef02349 -- App/Variorum/Variorum/Registry/CommandRouter.swift \| git apply -R` in the working copy (−7 lines; the reverted router's blob `47db0c25` = `a846a5f1`'s, the one-property router exactly); TEST BUILD SUCCEEDED, XCB-EXIT 0, zero `error:` (`p8b-mac-red-2.log`; the first red build, `p8b-mac-red.log`, superseded the same way). **The tree restored:** `git checkout HEAD -- App/Variorum/Variorum/Registry/CommandRouter.swift` → `git status` empty, `git diff --quiet HEAD`, the router's blob `71504ce0` = HEAD's, `pendingCompareLanding` ×6. **Each product:** the Debug app signed `io.lduarte.Variorum.debug`; its test bundle (17:09:49 / 17:10:52) carries both new pin names; `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun` present. **U6b's use:** the red product runs ONE suite once, by `test-without-building -xctestrun App/Variorum/DerivedData/vx336-u6-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun -only-testing:VariorumTests/MCPCompareLandingTests` under the stage claim (THE MAC SUITES FOR U6b's BATCH) |
| 9 | LIVE LEGS for U6b's window (final form) | DONE (`a726afd0`; the closer) — **LIVE LEGS FOR U6b's WINDOW (FINAL)** below: the turn form (prompts on STDIN, ids by substitution, Variorum frontmost per `show_in_app` turn), L0 (the fixture through the wire), L1a (`duplicate_note` + read_note's equality, her ⌥⌘Z/⇧⌥⌘Z), L1b (the AI edits the copy), L2 (Compare on the pair from a fresh open — rows aligned, "versions", related-only ON), L3 (the stranger on the MOUNTED board — the column replaced, "there is no relationship here", related-only OFF), L4 (`link_versions`' Open › → Compare A\|B, "versions · no shared lineage — loose alignment"), L5 (not frontmost: the exact sentence, nothing moved), THE TERMINAL PASS (L2 and L3 again); no live leg for the orphaned landing (tens of ms — the pin carries it). **THE MAC SUITES FOR U6b's BATCH** updated: 38 suites (`NoteOpenLandingTests` joins; the pin lives in `MCPCompareLandingTests`, now 7 tests) + the ONE red run on `vx336-u6-red` with its expected 9 pairs |

### THE ONE OPEN DECISION — the Compare landing's "one round" (found at piece 6; for the orchestrator)

**The contradiction (code vs the design as constrained by the lane go).** D-298-5 has the board consume the landing on
"the Lenses board's `consumePendingLensLanding` pattern; post-stamped, ONE ROUND". In the code, the one-round half of that
pattern does not live in the board at all: it is the ROUTER's three clears beside each parked landing —
`registerDetail` drops a landing parked for ANOTHER post (`CommandRouter.swift:127–128` for the lens), `unregisterDetail`
drops every landing at a genuine teardown (`:151`), and `noteMode` drops a landing whose mode the detail has left
(`:463–464` — the Round-2 MINOR-R2 "aborted-round window", which its ladder found reachable: a competing ⌘1–⌘4 in the
tens of ms before the arriving surface consumes). The lane go allows ONE stored property in `CommandRouter.swift`, so as
built the compare landing has none of the three. The consequence: a landing parked and then orphaned waits on the router
until she next opens Compare on THAT note herself — and then her board replaces its columns with the AI's set, long after
the call. That is a queued move, which her etiquette rules out (R-13nb-23: "never queued").
**Reachability:** the main road is unaffected (park → `requestMode(.compare)` → the board consumes on appear or on change
in the same runloop turn); only the aborted-round window (and a teardown racing the mount) leaves the parcel.
**Options:**
- **(a) RECOMMENDED — three more lines in `CommandRouter.swift`, one beside each lens clear** (`pendingCompareLanding` dropped
  for another post in `registerDetail`, at teardown in `unregisterDetail`, and when the detail reports a mode other than
  `.compare` in `noteMode`), plus one app pin (a parked compare landing dies with the mode switch, the other note's
  register and the teardown). The precedent's exact shape; vx-283 would be told about three more lines in the one file
  it was already told of.
- (b) Inside the lane: the navigator bounds the parcel itself — after a successful mode request it waits (≤ `mountWait`)
  for the board to take the landing, else clears it and answers `partialShowWords`. No router lines and an honest answer
  (F-4's spirit), but it departs from the lens target's model the design names, and her own Open › would wait too.
- (c) Accept as built and record the window.
**What it gates:** nothing headless (the wire, its pins, the revert check and the headless finals are independent of it);
in the app half only those three lines, one pin and one more `build-for-testing`. **THIS SESSION STOPPED HERE for the
ruling** (the contract: a contradiction that needs a decision is written, committed, pushed and reported) — pieces 7–9
continue after it.

### The traces (written before code)

**VX-311 — why a `create_note` draft opens Compare empty.** Compare's rows align by `Queries.blockKinship(anchor, other)`
(`TakesQueries.swift:235`): each placed block of `other` maps to its nearest kin among `anchor`'s placed blocks by walking
`derived_from` edges ONLY (`Lineage.swift`'s `lineageWalk`, `e.type = 'derived_from'`). A `create_note` draft mints fresh
blocks with no edge to anything → `kinship[peer] = [:]` → `CompareViewModel.compositionInputs` with `relatedOnly` ON (her
default, #47(c)) filters every peer block away (`CompareComposition.relatedOnly`) → the peer column is empty and the
board's honesty line shows. Even `link_versions` doesn't fix it: its `version_of` edges are not walked by kinship (its own
description says so). Her Duplicate as Version (`Operations.duplicateAsVersion`, `Operations+Versions.swift:209`) runs
`copyPost` → `copyPlacements`, which inserts ONE `derived_from` edge per copied block (`insertLineageEdge(from: copy, to:
source)`, `:792`) plus one `version_of` anchor (`:653`) — so every copy block has kin at depth 1 and Compare aligns row
for row. The wire has no road to that op today (no tool; `save_version`'s copy is born archived + sealed and lives only
in Note ▸ Versions — `mcpNoteFacts` reads a version as nil, so a client can't even address it).

**VX-298 — why the AI can't open Compare.** `show_in_app`'s targets (`MCPShowTarget`, `MCPShowTool.swift:13`) are note ·
takes · lens · book · wing; the parse refuses any other `target` (`:173`). Delivery (`MCPNavigator.deliver`) has no
Compare road: the board (`CompareBoardView`, mode `.compare`) fills its peer columns only from her picker
(`setPeer(slotID:postID:)`), `makeOutlinePost` (`peerSlots[index].postID = …`, `:810`), or the one-time auto-fill of the
first same-wing version peer (`adopt`, `:373`). `link_versions`' receipt carries `show: .note(noteID: noteA, …)`
(`MCPWriteTools+LinkVersions.swift:118`), so its Open › opens note A in whatever mode it remembers — never A|B.

### The design — VX-311 `duplicate_note` (argued; the forks it leaves are below, NOT built until ruled)

**D-311-1 — WHICH OP IT WRAPS: `duplicateAsVersion`, the direct op (argued; the brief's "argue which").** Her other road
(`saveNoteVersion` then `promoteNoteVersion`) is NOT the same result, measured against the code:
- **tags:** `duplicateAsVersion` rides the note's tags (`copyLiveTags`, 17y item (c), her ruling); `mintNoteVersion`
  copies none, and `promoteNoteVersion` adds none → the promoted copy is untagged;
- **the date:** `mintNoteVersion` drops `entry_date` (V3 — "a saved moment is not a day"); the duplicate keeps it;
- **commits:** `mintNoteVersion` seals, so it auto-commits every dirty copied take first (LR1-2); the duplicate's takes
  are born with no commits (the copy doctrine);
- **undo:** `saveNoteVersion` registers ONE entry, `promoteNoteVersion` NONE — two acts, and ⌥⌘Z would tombstone a note
  she now sees as live but registered as a "Save a Version"; the wire would need two transactions or a new composite;
- **her door:** Duplicate as Version is the visible door (the Takes board's ▾, the Library row, the chip's menu), and its
  copy machine is the one Compare's kinship reads.
So the tool wraps `duplicateAsVersion` exactly — ONE transaction, ONE client-named ⌥⌘Z, `saveVersion`'s precedent beside
`saveNoteVersion` (`Operations+MCPCarriage.swift:86`: the op's own body with the caller's `WriteGuard` FIRST inside the
transaction and the client's label). Her own words ("save the note as a version and immediately promote the version")
describe the EFFECT she wants — a duplicate — and this is her own door for it.

**D-311-2 — WHERE THE COPY LANDS, AND WHAT REACH DECIDES IT (FORK F-1; (a) recommended).** Her door's copy lands
**bookless in the source's wing** — that wing's Pool: `copyPost` sets `wingId: source.wingId` (`:642`) and "reading
memberships … deliberately do NOT ride" (`:191`). So the reach is `move_note_to_wing`'s two-sided shape
(`MCPWriteTools+WingMove.swift`, R1), applied:
- the SOURCE: the note at **READ** through the ordinary rule (any note, book or wing grant reaching it; the open book;
  `consumes: true` — a copy reads its content, so a once READ grant is spent by it, AF-7 as amended);
- the LANDING: the source's (resolved) wing at **WRITE NEW** through `decideWing` — a wing grant on THAT wing. A book
  grant can never name where a bookless note lands, and the open book is read only (R1's words). So a client whose
  write-new reach is a BOOK can't duplicate: honest, since the copy lands outside the book.
- **the snapshot** decides both and raises ONE ask (the source's READ ask, or else the wing's WRITE NEW ask); the act runs
  behind a guard that decides both AGAIN on one standing read inside its own write transaction and stamps the once grants
  of both sides there as ONE union (both spend or neither; a refused act spends nothing) — `guardWingMove`'s shape.
- An unreachable source (missing, tombstoned, a version, a scraps group, unshared, fenced without a per-ask grant)
  answers the ONE not-shared shape, byte-identical — the rule's own `missingTarget`/`notShared`; nothing is minted.
- **F-1 options:** (a) as above — her door's landing, wing-level write new (RECOMMENDED: no invention, R1's precedent);
  (b) an optional `book_id`: the copy also joins that book at its end, decided `into(.book)` at write new (a book-level
  client could then duplicate — but no door of hers files a duplicate into a book; it would be a new act, and Diverge,
  her one book-level copy door, swaps the membership instead); (c) the copy joins every book the source is in (rejected:
  not her door; an owned book would refuse or fork).

**D-311-3 — THE FENCE: a fenced source refuses (FORK F-2; (a) recommended, PROVISIONAL P-VX311-1).** Traced: the copy
keeps the fence's leg 1 (`profile = 'journal'` rides `copyPost`), but LOSES legs 2 and 3 — membership in THE daily
Journal and membership in a Private book do not ride (no memberships do), and the note's OWN Private mark doesn't ride
either (`copyPost`'s `Container(…)` never sets `ai_private_at`). So a client holding a per-ask grant on a Private note
(or a daily-Journal member) plus wing write new could duplicate it into an UNFENCED copy — readable afterwards under the
wing grant forever (after its once grant is spent), by every other client with wing reach, and by the open book. That
expands the writer's own reach (P-13nb-U4-16's principle) and opens her fence from the wire. For an UNFENCED source no
expansion exists: a wing grant already reaches every unfenced note of its wing, so the copy's reach ⊆ the source's.
- **(a) RECOMMENDED:** a fenced source the client CAN read (its live per-ask grant) refuses at the snapshot and again in
  the guard, minting nothing, with one sentence that names no leg (FOR VX-234): *"This note is shared with you only per
  ask, so it can't be duplicated — a copy would reach further than the note does. The author can duplicate it in
  Variorum."* No oracle opens for an UNREACHED fenced note (it never gets past the rule: the one not-shared shape). The
  holder learns only that its note is per-ask — which its own grant's road already implies (a per-ask grant is never
  "always").
- (b) carry the source's OWN Private mark onto the copy, and refuse only the membership legs (rejected by R-VX184-2's
  letter: "no MCP road writes `ai_private_at`", a copied mark included);
- (c) allow, as her own door does (rejected: the expansion above).

**D-311-4 — THE ANSWER: U5b's D1 records, from what the copy MINTED (FORK F-3 and F-4 on two edges).**
```json
{"note_id": "<copy>", "source_note_id": "<source>", "block_ids": ["…"],
 "blocks": [{"block_id": "…", "source_block_id": "…", "shown_take_id": "…", "takes": [{"take_id": "…", "label": "…"}]}],
 "landed": "the Pool of Home"}
```
- **Built from the copy machine's own rows, never a second read** (D1's ruling): `copyPlacements` already holds, per
  block, `copied.variants` (in source fan order), `copyIDs`, `chosenCopyID` and `defaultCopyID` (`:769–782`). The seam:
  `PlacementCopyOutcome` gains `minted: [MintedBlockTakes]`, appended per copied block (additive — every caller of the
  copy machine is byte-unchanged in rows); `PostCopyResult` gains `blocks: [MintedBlockTakes]` (a `var` with a default,
  outside its custom `==`, so every existing construction compiles unchanged); `MintedBlockTakes` gains
  `sourceBlockID: String?` (nil for every mint) and an internal memberwise init.
- **`shown_take_id`** = the read-time rule applied to the minted rows: the chosen copy while it is an ACTIVE take, else
  the default copy (an archived chosen renders the default — AppSpec §7's fallback, read_note's own,
  `MCPNoteStructure.swift:152`). D1's note that a copy's shown take need not be first in its fan is exactly this case.
- **`takes`** (F-3): (a) RECOMMENDED — the copy's ACTIVE takes, in the store's fan order (sorted by the copies' own
  `(fan_position, id)`, so the records equal what `read_note(with_ids)` will list — the V252-a equality, pinned); archived
  copies ride the note (her door) but are out of the fan, as read_note's resting answer has them. (b) every copied take,
  archived ones marked `"archived": true` (read_note's `include_archived` vocabulary — one more field on the shared
  encoder).
- **`source_block_id`** (F-4): (a) RECOMMENDED — each record names the block it was copied from, so a client that read
  the source with ids can edit "the copy of block X" without positional guessing (U5b's "nothing anywhere is positional").
  One optional field on THE encoder (`MCPMintedBlocks.records` emits it only when set; `create_note`/`insert_blocks`
  answers byte-unchanged). (b) no mapping (the client reads the copy, or matches by order).
- `block_ids` kept beside `blocks` (F-6's compatibility reading — every minted-note answer carries it); `landed` says
  where the copy is, in `move_note_to_wing`'s words (`landedWords`: "the Pool of Home" / "the Pool of “X”").

**D-311-5 — THE UNDO ENTRY: `registerMintedContainerEntry`, her door's own helper (U2's rule, answered).** Not
`registerStructuralEntry` (D6's block-level helper): `duplicateAsVersion` registers through `registerMintedContainerEntry`
(the VX-119 single-container pair, `Operations+UndoInverses.swift:546`), and the wire keeps it with the client's label.
U2's question is answered by the helper: the inverse returns `false` when it tombstoned nothing (the copy already dead —
her Delete, a sync tombstone), which RETIRES the entry; the redo revives only while the copy is dead on the stamp its own
undo wrote. ⌥⌘Z on a copy she has typed in tombstones the whole copy into the Trash (her door's doctrine: "deleted posts
are recoverable — nothing typed becomes unreachable"); Put back returns it whole. A NEW
`Operations.MCPWriteAct.duplicate = "duplicate"` → "Undo claude-code's duplicate" / "Undid: claude-code's duplicate";
`isUndoable` true (not a commit).

**D-311-6 — `flushesHerEditorFirst`: TRUE, argued from U3's COPY row.** VX-246's U3 act table: `save_version` is IN
because "the commit / the version misses her last words while answering success … her own Save Version flushes first".
A duplicate is the same class — `copyPlacements` reads stored `working_text` rows — and her own Duplicate as Version
flushes first: every door rides `AppSession.runCopying(from:)` (13e E10, "THE COPY FAMILY'S ONE ENTRY": "a row
duplicated while its post is open and dirty must carry what she just typed"). So `Job.duplicateNote` answers `true`
(a new top-level case in the exhaustive switch), and the flush runs in its own turn before the act's, whatever id the
call names (P-VX275-1).

**D-311-7 — THE WIRE.** NEW `Sources/VariorumMCP/MCPWriteTools+DuplicateNote.swift`: `Job.duplicateNote(noteID:)` (parse:
`note_id` required; `additionalProperties: false`); `performDuplicateNote` (the snapshot's two decisions, the fence
check, `land` spending nothing after the act — the guard spends inside the transaction); `guardDuplicate` (both sides + the fence, one
standing read, one union). NEW core `Operations.duplicateNoteForClient(_:undoLabel:guardedBy:) -> PostCopyResult` in a
NEW `Operations+MCPDuplicate.swift` — `duplicateAsVersion`'s transaction body extracted ONCE into an internal
`duplicateAsVersionBody(_:_:)` that both call (so the two can never drift), the guard FIRST. Catalog: `duplicateNote` in
WRITE NEW, `scopes: [.wing]` (it acts only under a wing grant — the W-UX-14 truth pin's sense), description below (FOR
VX-234). The receipt: act `.duplicate`, target the COPY (`targetTitle` = its title), `show` per FORK F-5. App: the
Activity words (`MCPPaneCopy`: "duplicating “X”" / "duplicated “X”"), the receipt phrase ("duplicated “X”" / "made N
duplicates"). Answer P1: ∝ the copied note (the write itself); the decisions ∝ one note + one wing.

**FORK F-5 — duplicate_note's Open ›:** (a) RECOMMENDED — the COPY (`.note(copy)`, every note-minting act's receipt);
(b) Compare source | copy (`.compare(source, [copy])` — what the copy is for, but her answers (5) ruled Open › → Compare
only for `link_versions`; the client can call `show_in_app` with the compare target when she asks).

**D-311-8 — the pins (red-first; a new tool is red by its absence).** Core `Tests/VariorumCoreTests/
MCPDuplicateNoteActsTests.swift`: the rows equal `duplicateAsVersion`'s (bookless in the source's wing, tags ride, one
`derived_from` per block, one `version_of`, a sealed source legal, the copy never locked); a throwing guard writes
nothing (the guard first); ONE entry labeled as given, its undo tombstoning the copy and its redo reviving it on the
stamp, a copy she deleted staying deleted; the records equal the copy's live fans (active, fan order, labels, a shown
take falling back past an archived chosen, `source_block_id`). Wire `Tests/VariorumMCPTests/
MCPDuplicateNoteServerTests.swift`: read on the note + write new on the wing lands, `blocks` == `read_note(with_ids)`'s
records of the copy, and `Queries.blockKinship(source, copy)` maps EVERY copy block (the VX-311 point); the unreachable
source answers byte-identically to an unknown id and mints nothing; read on the note with only a BOOK write-new grant
hears the wing's refusal and raises the wing's write-new ask; a fenced source under a live per-ask grant hears F-2's
sentence and mints nothing; once grants on both sides spend as one union, a refused act spends nothing; the label on
the stack and the receipt's act and show. `MCPHerEditorServerTests` (APPENDED, nothing modified): `duplicate_note`
asks for her flush by name and the copy carries her latest words. Justified edits (the ritual): `MCPServerTests`' write
new set and `MCPWriteServerTests`' suggest-proof completeness gain `duplicate_note`.

### The design — VX-298 `show_in_app`'s Compare target + `link_versions`' Open ›

**D-298-1 — THE TARGET: `.compare(noteID: String, peerIDs: [String])` (FORK F-6 on the wire's words).** (a)
RECOMMENDED: `target: "compare"`, `note_id` (the first column — the note whose Compare opens) and `peer_ids` (one to three
other notes, in column order — her board holds four, `addPeerSlot`'s cap; her answer (3)). The parse refuses, before any
read: no `peer_ids`, not an array, empty, more than three, a non-string, a repeat, or `note_id` among them. (b) one list
`note_ids` of two to four, the first the anchor.

**D-298-2 — THE DECISION (read, never spending; the brief's order).** On ONE read: the anchor at READ, then each peer in
order (`decide(…, rung: .read, consumes: false)`); the FIRST refusal answers with that note's refusal — the ONE
not-shared shape for anything unreachable, byte-identical to an unknown id (`link_versions`' order, no ask raised:
`show_in_app`'s own refusal road). Only after every note is decided (so nothing is told about a note the client can't
read): (1) the SAME WING — every peer's resolved wing (`facts.wingID`) equals the anchor's, else one sentence (FOR VX-234:
"Those notes are in different wings — each wing is a separate library, so Compare can't show them side by side."); (2)
only notes HER PICKER WOULD OFFER — `Queries.notePickerNotes`' WHERE: a live, non-archived post of the anchor's wing, not
the anchor (versions are archived, so `mcpNoteFacts` already answers them nil → not-shared); so an ARCHIVED peer refuses
(FOR VX-234: "\(title) is archived — Compare offers only notes in the library (unarchive_note first).") — FORK F-7: (a)
the anchor may be archived (she can open an archived note and press ⌘5; the picker's rule binds the PEERS), (b) refuse an
archived anchor too. Cost ∝ the named notes (≤ 4 facts reads + one archived read), never the corpus. Logged on the
refusing side, else on the anchor ("showed you “A”").

**D-298-3 — WHERE "related blocks only" IS DECIDED (FORK F-8; (a) recommended).** (a) The BOARD decides it when the
landing lands, from its OWN projection — the kinship it computes to draw the rows anyway (`CompareViewModel.read` →
`projection.kinship`, "verbatim, never re-derived view-side"). The target carries no posture (P-4: a signal, never a
decision), the wire's read stays ∝ facts, and `link_versions`' receipt stays ∝ its pairs (VX-184 ladder round 2's P1
shape — option (b) would make every `link_versions` call walk both notes' whole lineage just to word an Open › she may
never press). (b) The wire computes it (`blockKinship` per peer in the decision's read) and the target carries
`relatedOnly`: pinnable headless, at that cost.

**D-298-4 — THE POSTURE RULE (FORK F-9; (a) recommended, PROVISIONAL P-VX298-1).** Her answer (2): *"related blocks only
off when they have no history - that's fine"*; her answer (4): the board shows exactly what the AI named. (a)
RECOMMENDED: ON only when EVERY named peer shares lineage with the anchor (`!kinship[peer].isEmpty` for each); otherwise
OFF — so no named column opens filtered empty. (b) OFF only when NO peer shares any (a mixed set keeps her default ON,
its unrelated columns showing the honesty note). One pure function on the board's pure brain:
`CompareComposition.landingShowsRelatedOnly(peerKinships:) -> Bool` (app-side, beside `relatedOnly`), pinned in the app
suite.

**D-298-5 — THE DELIVERY (the lens target's model).** `MCPNavigator.deliver` gains `.compare(noteID, peerIDs)`: open the
anchor (`open(noteID, in:)`, the mount wait), re-check `stillStanding()`, park the landing on the router
(`commandRouter.pendingCompareLanding = CompareLanding(postID: noteID, peerIDs: peerIDs)`), then
`requestMode(.compare, postID: noteID)`; a refused request clears the landing and answers false (→ `partialShowWords`).
The board consumes it on appear and on change (the Lenses board's `consumePendingLensLanding` pattern; post-stamped, one
round, a landing for another note left alone). `CompareViewModel.land(peers:)`: `autoFilled = true`; any departing
column's live pane released through the model's existing `releaseLivePane(leavingPost:)` (4C's NIT-1); `peerSlots =
peers.map { PeerSlot(postID: $0) }` — REPLACING the open columns (her answer (4)); the departed peers leave through the
board's own leaving road (`onNotesLeft` in `peerSlots.didSet`, 18o U4); `relatedOnly = false` while the lineage is read
(nothing named is hidden), and the first projection holding every landed peer applies D-298-4 once (later projections
never flip it). No seam file is edited: the model's own slot API only.

**D-298-6 — `link_versions`' Open › opens Compare A|B (her answer (5)).** The receipt's `show` becomes `.compare(noteID:
noteA, peerIDs: [noteB])` — her press delivers it through `MCPDoor.openShow` (no etiquette gate: she is at the app), and
⌥⌘O's last change follows. The posture comes from the board (D-298-3 (a)), so the call's cost is unchanged.

**D-298-7 — the catalog and the words.** `show_in_app`'s description gains the target (FOR VX-234): *"…, "compare"
(note_id + peer_ids — one to three other notes in the same wing: Variorum's Compare with note_id first and each peer
beside it, replacing the columns open; rows line up where the notes share history, as duplicate_note's copies do, and
"related blocks only" opens off when they don't) …"*; its schema: `target`'s enum gains "compare", a `peer_ids` array
(1–3 strings). Activity: logged on the anchor, the existing words ("showed you “A”") — FOR VX-234 whether Compare is
named. `link_versions`' description gains: "The receipt's Open opens the two in Compare."

**D-298-8 — the pins (red-first).** Headless `Tests/VariorumMCPTests/MCPShowCompareServerTests.swift`: a read-shared pair
delivers `.compare(A, [B])` and up to three peers in order, never spending a once grant; the parse's refusals; the anchor
unreachable and a peer unreachable each answer the one not-shared shape byte-identically (logged on that side), nothing
delivered; another wing's peer and an archived peer refuse in words AFTER the decisions; a version's id answers
not-shared; not frontmost moves nothing. `MCPLinkVersionsServerTests` (appended): the receipt's `show == .compare(A,
[B])`. All red on the old tree by absence ("target must be …") or by the old `.note(A)`. App (`App/Variorum/VariorumTests/
MCPCompareLandingTests.swift`, compiled by build-for-testing here, RUN in U6b's batch — red on the old tree by
compilation, the symbols absent): the landing replaces the columns exactly (a live pane on a departing peer released),
a landing for another note is left alone, the posture rule (OFF for an unrelated pair, ON for a duplicate's pair, the
mixed case per F-9), and `MCPNavigator` delivering `.compare` (the anchor opened, the mode Compare, the landing
consumed).

### LANES — the edits that need vx-283 told FIRST (the brief's rule; NOT made)

- **`App/Variorum/Variorum/Registry/CommandRouter.swift`:** ONE stored property beside `pendingLensLanding` —
  `var pendingCompareLanding: CompareLanding?` (observed, so a mounted board consumes it). Required by D-298-5: the
  router is the session's choreography-intent home (`pendingWriteIntent`, `pendingTakesLanding`, `pendingLensLanding`),
  and a feature never holds a sibling's model.
- **`CompareLanding`'s home:** (a) RECOMMENDED — `Features/Takes/CompareBoardView.swift`, beside its consumer, so the
  registry is touched in ONE file by three lines; (b) `Registry/Capability.swift` beside `LensLanding` (the precedent's
  placement — a second registry file).
- **Not touched:** `WorkspaceModel`, `ShellRouter` (the delivery uses `router.adopt` as the lens target does — a call,
  no edit), `Registry/ShellActions.swift` (VX-342 is U6b's), any other registry file.

### PROVISIONALs (with their options — the orchestrator files them at the merge)

*(Every one RULED (a) by THE ORCHESTRATOR'S RULINGS ON U6a's FORKS and BUILT (a) — pieces 4 and 6; the options stay for
her ratification in the QUESTIONS bundle at the merge.)*

- **P-VX311-1** (F-2) — a fenced source refuses `duplicate_note`: **(a) refuse, the leg unnamed — BUILT** (checked after
  the note's READ decision and BEFORE the wing's, so no wing ask is raised for an act that can never land; re-checked in
  the guard; pinned `aFencedSourceUnderAPerAskGrantRefusesInOneSentenceAndMintsNothing`); (b) carry the own Private mark,
  refuse the membership legs (ruled out by R-VX184-2); (c) allow.
- **P-VX311-2** (F-1) — the copy lands bookless in the source's wing, wing-level write new: **(a) BUILT** (a book-level
  write new hears the wing's refusal and raises the wing's ask — pinned `aBookLevelWriteNewHearsTheWingsRefusalAndAsksForTheWing`);
  (b) an optional `book_id` filing the copy into that book at write new; (c) the source's books.
- **P-VX311-3** (F-3/F-4/F-5) — the answer's edges: **active takes only [a] BUILT** vs archived marked [b];
  **`source_block_id` [a] BUILT** vs none [b]; **Open › to the copy [a] BUILT** vs Compare [b].
- **P-VX298-1** (F-9) — **related blocks only ON only when every named peer shares lineage [a] BUILT** (a mixed set opens
  off) vs OFF only when none does [b].
- **P-VX298-2** (F-7) — **an archived anchor shows [a] BUILT** vs refuses [b]; an archived peer refuses either way (the
  picker's rule).
- **P-VX298-3** (F-6) — **`note_id` + `peer_ids` [a] BUILT** vs `note_ids` [b].

### FOR VX-234 (user-facing words, AS BUILT — pieces 4 and 6)

**Her surfaces (the app's voice, P-13n-1):**
- The undo family (`MCPWriteAct.duplicate`, raw "duplicate"): Edit ▸ "Undo claude-code's duplicate", the undo receipt
  "Undid: claude-code's duplicate".
- The write receipt (`MCPReceiptCopy`, `.duplicate`): "claude-code duplicated “u6a source” · ⌥⌘Z undoes" (a run of
  several on one copy: "made N duplicates" — unreachable in practice, each copy its own target), with Open › opening the
  copy.
- Activity (`MCPPaneCopy`): allowed "duplicated “X”" (+ " (N times)"); refused on the note side "duplicating “X”", on the
  wing side "duplicating a note in “X”" (UXR1-1's two-sided rule — e.g. "…was refused duplicating a note in “Home”").
- Compare: NO new words (the board's own chip and honesty line; `show_in_app`'s Activity keeps "showed you “A”" /
  "showing you “A”", logged on the anchor or the refusing note).

**The wire (the MCP room's technical register):**
- `duplicate_note`'s description (`MCPToolCatalog.duplicateNote`, quoted whole in the catalog).
- The fence sentence: "This note is shared with you only per ask, so it can't be duplicated — a copy would reach further
  than the note does. The author can duplicate it in Variorum."
- `show_in_app`: the compare clause in its description; `target`'s sentence now ends "…, \"wing\" or \"compare\"."; the
  parse's sentences — "target compare needs note_id and peer_ids (one to three other notes)." · "peer_ids must be an array
  of note ids." · "peer_ids must name one to three other notes — Compare shows a note and up to three beside it." ·
  "peer_ids must hold note ids (strings)." · "peer_ids names a note twice." · "peer_ids can't include note_id — it is the
  first column already."; the refusals — "Those notes are in different wings — each wing is a separate library, so
  Compare can't show them side by side." · "“X” is archived — Compare offers only notes in the library (unarchive_note
  first)." (**the title QUOTED** — the design's draft had it bare; quoted as the wire's other sentences quote names).
- `link_versions`' description: "The author's receipt for it opens the two side by side in Compare."
- Not changed, for her eye: the write-new rung's consent sentence ("make new notes…") already covers a duplicate (a new
  note); it names no duplicate, as it names no link or block insert.

### LIVE LEGS FOR U6b's WINDOW (FINAL — the closer, after the ruling; claim `vx336-u6`; NOT run here)

**Setup and cleanup are U6b's STAGE WINDOW** in U5's worked form (THE STAGE WINDOW steps 0–3 and 13 in the U5b record,
run as the U5 STAGE RUN ran them): the products are `App/Variorum/DerivedData/vx336-u6` (`c30fa9a7`, the final tree —
the app launched from it) and `vx336-u6-red` (only for the one red run in THE MAC SUITES below — never launched); the
A1 prestage copy, the prefs export, her user-scope fingerprint before and after; the Claude Code tab key taken from the
clipboard into a scratch `u6-mcp.json` OUTSIDE the repo (`{"mcpServers":{"variorum-dev":{"command":"<the shim's absolute
path>","env":{"VARIORUM_MCP_KEY":"<the key>"}}}}`), never `-s user`, never run as copied. **THE GRANT for every leg:**
claude-code's Shared-with-AI row ▸ Change… ▸ **A wing · Home · Edit · Always** (read for `show_in_app`/`read_note`;
write new for `create_note`, `apply_tag`, `duplicate_note` — which acts only under a WING grant — and `link_versions`;
edit for `choose_take`, `edit_take`). Captures into `notes/plans/vx336-screens/u6/` (gitignored), one per face below.

**Every turn's form** (prompts on STDIN — `--allowedTools` is variadic and swallows a trailing prompt; U5's lesson), from
a scratch project directory:

```sh
cat > "$SCRATCH/u6-<leg>.prompt" <<'PROMPT'
<the leg's prompt, its <ID> placeholders substituted from the earlier answers>
PROMPT
claude -p --strict-mcp-config --mcp-config "$SCRATCH/u6-mcp.json" --output-format json \
  --allowedTools "<the leg's list>" < "$SCRATCH/u6-<leg>.prompt" \
  | tee notes/plans/vx336-screens/u6/<leg>.json
```

Each `claude -p` is a fresh client with no memory, so ids travel by substitution: the runner reads them from the tee'd
answers and writes them into the next prompt — `SOURCE_ID`, `SOURCE_B1`, `STRANGER_ID`, `STRANGER_B1` from L0;
`COPY_ID`, `COPY_B1_TAKE` from L1a. (The copy keeps the source's title — two "u6a source" notes — so no prompt finds a
note by title.) **Variorum is FRONTMOST for every `show_in_app` turn** — `osascript -e 'tell application id
"io.lduarte.Variorum.debug" to activate'` right before it (the claude process runs in the runner's shell and never
takes focus) — except L5, which is the not-frontmost leg. All fixture text is ASCII (System Events drops non-ASCII).

- **L0 — the fixture (~3 min).** Allowed `mcp__variorum-dev__create_note,mcp__variorum-dev__apply_tag,mcp__variorum-dev__choose_take`:
  > In Variorum, call create_note with wing_id "" (Home), title "u6a source", and blocks [{"text": "The first paragraph
  > of the source."}, {"text": "The second paragraph, first take.", "takes": [{"text": "The second paragraph, second
  > take.", "label": "alt"}]}, {"text": "The third paragraph of the source."}]. Then call apply_tag on that note with tag
  > "u6a/demo". Then call choose_take with the take_id of block 2's take labelled "alt". Then call create_note with
  > wing_id "", title "u6a stranger", and blocks [{"text": "A stranger's first paragraph."}, {"text": "A stranger's
  > second paragraph."}]. Reply with both create_note answers verbatim, and say whether apply_tag and choose_take
  > succeeded.

  **Expected:** both create_note answers land (keys `block_ids`, `blocks`, `note_id`, `tag_ids`), the source's block 2
  record with two takes (`[{"take_id"}, {"take_id", "label": "alt"}]`); apply_tag and choose_take succeed. Record
  `SOURCE_ID`, `SOURCE_B1` (its first `block_id`), `STRANGER_ID`, `STRANGER_B1`. **Her face:** "u6a source" in Write
  reads first paragraph / "The second paragraph, second take." / third paragraph, wearing u6a/demo (capture `L0-source`).

- **L1a — `duplicate_note`, then her undo and redo (~7 min, VX-311).** Before: the window on the Bookcase. Allowed
  `mcp__variorum-dev__duplicate_note,mcp__variorum-dev__read_note`:
  > In Variorum, call duplicate_note with note_id "<SOURCE_ID>". Then call read_note on the copy's note_id with
  > with_ids true. Reply with duplicate_note's answer verbatim, and say whether its blocks (each block_id,
  > shown_take_id, and every take's take_id and label) match what read_note reports for the copy.

  **Expected:** lands; keys `block_ids`, `blocks`, `landed`, `note_id`, `source_note_id`; `source_note_id` =
  `SOURCE_ID`; `landed` **"the Pool of Home"**; `blocks` three records in order, each with `source_block_id` = the
  source's block 1, 2, 3 ids (L0's answer); block 2's record carries two takes `[{"take_id"}, {"take_id", "label":
  "alt"}]` and its `shown_take_id` is the SECOND (the chosen take, carried); blocks 1 and 3 one take each; the client
  says they match read_note. Record `COPY_ID` and `COPY_B1_TAKE` (block 1's `shown_take_id`).
  **Her face, in this order:** the receipt **"claude-code duplicated “u6a source” · ⌥⌘Z undoes"** with Open ›
  (capture `L1a-receipt`); press Open › → the COPY in Write: the three paragraphs with "The second paragraph, second
  take.", wearing u6a/demo, in no book (capture `L1a-copy-write`); Settings ▸ MCP ▸ Activity **"claude-code duplicated
  “u6a source”"** (capture `L1a-activity`); the Pool lists two "u6a source" rows (capture `L1a-pool`). **Her undo, from
  the Pool (no pane showing the copy):** the Edit menu reads **"Undo claude-code's duplicate"** (capture
  `L1a-edit-menu`) → ⌥⌘Z → one "u6a source" left, the undo receipt **"Undid: claude-code's duplicate"** (capture
  `L1a-undone`) → ⇧⌥⌘Z → the copy back in the Pool (capture `L1a-redone`). The source never changes. (L1b's edit of
  `COPY_B1_TAKE` landing proves the redo revived the SAME rows.)

- **L1b — the AI edits the copy (~3 min).** Allowed `mcp__variorum-dev__edit_take,mcp__variorum-dev__read_note`:
  > In Variorum, call edit_take with take_id "<COPY_B1_TAKE>", expected_text "The first paragraph of the source.", and
  > text "The first paragraph, edited by the AI in the copy." Then call read_note on note "<SOURCE_ID>" and on note
  > "<COPY_ID>". Reply with edit_take's answer verbatim and each note's first block's shown text.

  **Expected:** lands; the copy's first block reads the edit; the source's still "The first paragraph of the source."
  **Her face:** the receipt for claude-code's edit (it may coalesce with L1a's into one line — the door's 120 s
  same-client/same-note run, `MCPDoor.receiptWindow`, as designed) (capture `L1b-receipt`).

- **L2 — `show_in_app` Compare on the pair: the rows line up (~4 min, VX-298).** Before: Variorum FRONTMOST, the window
  on the Bookcase (no note open — so the delivery takes the open → register → park road, the board MOUNTING onto the
  landing). Allowed `mcp__variorum-dev__show_in_app`:
  > In Variorum, call show_in_app with target "compare", note_id "<SOURCE_ID>" and peer_ids ["<COPY_ID>"]. Reply with
  > its answer verbatim.

  **Expected:** `{"shown":true}`. **Her face:** the window in Compare (the mode row on Compare), "u6a source" first,
  the copy beside it; the copy column's relationship line **"versions"** (lineage and the version link); the chip
  **"related blocks only: on"** (every named peer shares lineage — F-9 (a)); three rows aligned with lineage rails; the
  copy's row 1 reads "The first paragraph, edited by the AI in the copy.", row 2 "The second paragraph, second take."
  in both columns (capture `L2-study`); Activity "claude-code showed you “u6a source”" (capture `L2-activity`).

- **L3 — an unrelated pair, on the MOUNTED board (~3 min).** Before: L2's Compare still showing (the board mounted —
  this leg proves the already-mounted board's consumption on change, the other road). Allowed as L2:
  > In Variorum, call show_in_app with target "compare", note_id "<SOURCE_ID>" and peer_ids ["<STRANGER_ID>"]. Reply
  > with its answer verbatim.

  **Expected:** `{"shown":true}`. **Her face:** the copy's column REPLACED by "u6a stranger" — ONE peer column, not two
  (her answer (4)); its relationship line **"there is no relationship here"**; the chip **"related blocks only: off"**;
  both notes whole, no rails, no "related blocks only — nothing from this note" honesty line (capture `L3-study`).

- **L4 — `link_versions`' Open › opens Compare A|B (~4 min).** Before: the window moved off that board — open the copy
  in Write (a Pool row, or a `show_in_app` note turn). Allowed `mcp__variorum-dev__link_versions`:
  > In Variorum, call link_versions with note_a "<SOURCE_ID>", note_b "<STRANGER_ID>", and pairs [{"block_a":
  > "<SOURCE_B1>", "block_b": "<STRANGER_B1>"}]. Reply with its answer verbatim.

  **Expected:** `{"links":[{"block_a":"<SOURCE_B1>","block_b":"<STRANGER_B1>","edge_id":"…"}],"note_a":"<SOURCE_ID>",
  "note_b":"<STRANGER_ID>"}`. **Her face:** the receipt **"claude-code linked “u6a source” and “u6a stranger” as
  versions · ⌥⌘Z undoes"** with Open › (capture `L4-receipt`); press **Open ›** (click; if it has faded, ⌥⌘O — "Show
  the AI's Last Change" — the same show) → Compare: "u6a source" first, "u6a stranger" beside it; the relationship line
  **"versions · no shared lineage — loose alignment"**; the chip **"related blocks only: off"** (no lineage); the
  stranger's column offers "unmark" (capture `L4-compare`). Her press has no frontmost gate (she is at the app).

- **L5 — the etiquette: nothing moves while she is away (~2 min).** Before: `osascript -e 'tell application "Finder"
  to activate'` (Variorum NOT frontmost); Variorum's window shows L4's Compare. Allowed as L2:
  > In Variorum, call show_in_app with target "compare", note_id "<SOURCE_ID>" and peer_ids ["<COPY_ID>"]. Reply with
  > its answer verbatim. Do not retry.

  **Expected:** `isError`, EXACTLY **"The author isn't at Variorum right now, so nothing was moved — showing happens
  only while Variorum is the app in front. Ask them to switch to it, then call again."** **Her face:** Variorum
  re-activated: the window still on L4's source | stranger — nothing moved and nothing waits to move (the etiquette
  gate refuses before any landing is parked) (capture `L5-unmoved`).

- **THE TERMINAL PASS (~6 min — the Compare board in her second voice).** Settings ▸ General ▸ Theme → Terminal (U1b's
  AX road). The window on the Bookcase, Variorum frontmost: re-run L2's turn → the same face in Terminal (capture
  `L2-terminal`); then L3's turn on the mounted board → the same face (capture `L3-terminal`). Flip back to Study.

- **No live leg for the orphaned landing** (the ruling's (a) case): the window between her Compare request and the
  board's mount is tens of ms — not reachable from her keyboard. The ruled pin carries it (row 6a), run red on
  `vx336-u6-red` and green on `vx336-u6` in U6b's batch (below).

### THE MAC SUITES FOR U6b's BATCH (U6a's share — every suite that reaches an app type this unit changed; grep of `App/Variorum/VariorumTests` at `a846a5f1`, brought to `c30fa9a7` by the closer)

**Run on `vx336-u6` (the final tree), all GREEN expected.** The closer's changes after `a846a5f1` are the three clears
(`CommandRouter.registerDetail` / `unregisterDetail` / `noteMode`, `pendingCompareLanding` only) and the ruled pin, which
lives IN `MCPCompareLandingTests` (now 7 tests: piece 5's 5 + the pin's 2) — so no new suite joins for the pin itself;
`NoteOpenLandingTests` joins because it drives the very functions the clears sit in (`registerDetail` and `noteMode`,
12 calls).

- **Compare's board, model and brain** (`CompareViewModel` · `CompareComposition` · `CompareBoardView` · `CompareLanding`):
  `MCPCompareLandingTests` (NEW) · `CompareCompositionTests` · `CompareViewModelTests` · `CompareAnchorWholeTests` ·
  `CompareOnePlacementTests` · `CompareLensesAlignmentTests` · `CompareLeavingSavepointTests` (`land` leaves through
  `onNotesLeft`) · `AutosaveRegistryLifecycleTests` · `CapabilityRegistryTests` · `SavepointSealedDoorTests` ·
  `TutorialLookingActsTests` · `NavigationDoorsTests` · `TakesBoardSoakTests` · `ScrubAndOutlineTests`.
- **The delivery** (`MCPNavigator`, `MCPShowTarget`): `MCPNavigationTests` · `MCPWingFacesTests` (its
  `activitySpeaksEveryActInWordsNeverAToolID` walks `duplicate_note`).
- **The words and the catalog's facts** (`MCPPaneCopy` · `MCPReceiptCopy` · `MCPToolFacts` · `MCPWriteAct`):
  `MCPAsksWaitTests` · `MCPEditParityFacesTests` · `MCPEditFacesTests` · `MCPGrantSheetTests` ·
  `MCPLibraryParityFacesTests` · `MCPAskAndReceiptTests` · `MCPDoorErgonomicsFacesTests` · `MCPPaneTests` ·
  `MCPPaneTabsTests` · `MCPDeliberateFacesTests` · `MCPSetupMenuTests` · `MCPGrantSheetU2CaptureTests` ·
  `MCPSetupKeyFacesTests` · `MCPRebindFaceTests` · `MCPShareFacesTests` · `TutorialMCPChapterCaptureTests` ·
  `TutorialMCPChapterTests`.
- **The router's landings** (`CommandRouter` — one additive observed property and, since the closer, its three clears;
  54 test files hold a router, these are the ones that exercise its parked landings or the three functions the clears
  sit in): `CommandRouterTests` · `StaleWriteIntentTests` · `TakesLandingTests` · `BlockHistoryPaletteDoorTests` ·
  `NoteOpenLandingTests` (joined by the closer).
- **38 suites** (37 + `NoteOpenLandingTests`; U6b adds VX-330's and VX-342's).
- **AND ONE RED RUN on `vx336-u6-red`** (`c30fa9a7` with ONLY the three clears reverted — row 8b), under the same claim,
  before or after the batch, the ruled pin's red-on-old shown on the Mac: from `App/Variorum/`, `xcodebuild
  test-without-building -xctestrun DerivedData/vx336-u6-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun
  -destination 'platform=macOS' -only-testing:VariorumTests/MCPCompareLandingTests`. **Expected: 7 tests, 2 FAILED, 5
  passed, 9 issues** — `aLandingSheOutrunsWithAnotherModeIsDroppedAndHerOwnCompareKeepsHerColumns` at
  `MCPCompareLandingTests.swift:272`, `:239`, `:241`; `aLandingWhoseNoteLeavesBeforeTheBoardTakesItIsDroppedAndHerOwnCompareKeepsHerColumns`
  at `:300`, `:239`, `:241`, `:317`, `:239`, `:241` (row 6a). The same two GREEN in the batch on `vx336-u6` = the pin
  red-on-old and green-on-new; any other red there is a finding. The red product runs ONLY as this one run's test host — never launched for a walk or the live round.

### SELF-ASSESSMENT (the closer's — the ruled fix and its pin)

- **What the fix is:** three clears, each a line-for-line twin of the lens landing's, on `pendingCompareLanding` only.
  The main road traced against them (row 6b): the detail registers once per note, and a mode switch is its `@State`
  reported through `noteMode`, so the delivery's own `.compare` report keeps the landing.
- **The one ordering I checked hardest** — a note opened fresh whose REMEMBERED mode is neither Write nor Compare (its
  `onAppear` sets the mode, so its `onChange(of: mode)` reports later): the navigator's park and `requestMode(.compare)`
  run synchronously in ONE main-actor job, so that report either comes BEFORE anything is parked (harmless) or, after
  both, reports the coalesced final value `.compare` (kept). No window drops a landing the board was about to take; the
  lens landing rests on the same fact. L2 (fresh open from the Bookcase) and L3/L4 (a mounted board, and her press)
  walk the real roads.
- **What the pin is, honestly:** a model of her ⌘5 driven by hand in the board's own order (`onAppear`'s consume, then
  the observation's adopts — the test host never fires `.task`), not the SwiftUI lifecycle itself. Its red-on-old and
  green-on-new are by ASSERTION on two built products, read in U6b's batch; nothing app-side ran here. The (ii)
  refinement (`c30fa9a7`) keeps the modeled world honest — the teardown races a board not yet mounted.
- **Not done here (by the brief):** no stage, no app launch, no `xcodebuild test`, no store; the live legs are written,
  not run; no new user-facing words (FOR VX-234 unchanged), no new PROVISIONAL, nothing for QUESTIONS.

### OWED (for the orchestrator)

1. ~~The rulings on F-1…F-9~~ — DONE (`6502db0d`). ~~Telling vx-283 about the one property~~ — DONE (the build brief).
2. ~~THE ONE OPEN DECISION's ruling~~ — RULED (a) (`cdcccbd0`), vx-283 told by the orchestrator; BUILT by the closer:
   the pin `a2e6dfd6` (refined `c30fa9a7`), the three clears `4ef02349`.
3. ~~Pieces 7–9~~ — DONE by the closer (rows 7, 8, 8b, 9).
4. ~~A ticket to propose~~ — minted as VX-353 by the orchestrator. The closer's finals add one data point for it: the
   pin passed at 14.889 s of its 15 s bound under load 19–29 (row 8).
5. **For U6b's window** (its STAGE WINDOW plan writes the setup and cleanup): THE MAC SUITES' 38-suite batch on
   `vx336-u6` AND the ONE red run of `MCPCompareLandingTests` on `vx336-u6-red` (the expected 9 pairs), then LIVE LEGS
   L0–L5 + the Terminal pass. Both products are on disk at `App/Variorum/DerivedData/vx336-u6{,-red}` (2.5 GB each);
   if main moves before the window (VX-306's Castle migration of the dev store), the brief's merge-main rule applies
   and both products are rebuilt from the merged tree the same way (row 8b's exact steps).
6. **Context:** the closer stopped at ~310k by the harness count (inside the ~400k line).

### THE ORCHESTRATOR'S RULINGS ON U6a's FORKS (2026-10-14 ~16:30 MDT — binding on pieces 2–9)

The design D-311-1…8 and D-298-1…8 is ACCEPTED as written, with these rulings. The PROVISIONALs go to QUESTIONS at the
merge with the record's options.

- **D-311-1: `duplicate_note` wraps `duplicateAsVersion`, CONFIRMED.** Save-then-promote differs in tags, date, commits
  and undo, as traced. The op's body is extracted ONCE (`duplicateAsVersionBody`), so her door and the wire can't drift.
- **F-1: (a), PROVISIONAL P-VX311-2.** The copy lands bookless in the source's wing; the rungs are READ on the source and
  WRITE NEW on that wing (`decideWing`, `move_note_to_wing`'s two-sided guard). This is the ticket's letter: *"write new
  where the copy lands, which is wherever her door puts it."* **The consequence, for her eye in the bundle:** a client
  whose write-new reach is only a BOOK can't duplicate; the refusal and the wing's ask say so honestly. Option (b), an
  optional `book_id` filing the copy into that book at write new, is recorded for her.
- **F-2: (a), PROVISIONAL P-VX311-1.** A fenced source refuses, minting nothing, with the record's one sentence that
  names no leg. The copy would shed two of the three fence legs, so an unrefused copy would expand the writer's own
  reach (P-13nb-U4-16's principle). Option (b) is ruled out by R-VX184-2 (no MCP road writes `ai_private_at`).
- **F-3 (a), F-4 (a), F-5 (a), PROVISIONAL P-VX311-3.**
  - The answer lists ACTIVE takes in fan order (equal to `read_note(with_ids)`).
  - Each record carries `source_block_id` (one optional field on the shared encoder; every other answer is
    byte-unchanged).
  - Open › opens the COPY, like every note-minting act. Her Compare-Open answer (5) was `link_versions`'.
- **F-6: (a), PROVISIONAL P-VX298-3.** `target: "compare"`, `note_id` plus `peer_ids` (1–3).
- **F-7: (a), PROVISIONAL P-VX298-2.** An archived anchor may show (she can open one and press ⌘5). An archived peer
  refuses, by her picker's rule.
- **F-8: (a), the orchestrator's (architecture).** The BOARD decides "related blocks only" from its own projection when
  the landing arrives. The target carries no posture (P-4: signals, never decisions), and the wire's read and
  `link_versions`' cost stay ∝ what they name (P1).
- **F-9: (a), PROVISIONAL P-VX298-1.** ON only when EVERY named peer shares lineage with the anchor, else OFF. Her answers
  (2) and (4) together: no column the AI named opens filtered empty. A pure function on the board's brain, pinned.
- **Lanes:**
  - **(a):** `CompareLanding` lives in `Features/Takes/CompareBoardView.swift`, and the registry gains ONE stored property,
    `CommandRouter.pendingCompareLanding`.
  - **vx-283 is TOLD by the orchestrator before the build edits `CommandRouter.swift`** (sent with this ruling; its answer
    is recorded in Cross-run coordination). The builder makes that one edit only after the orchestrator's go, which comes
    in its brief.
  - Nothing in `WorkspaceModel`, `ShellRouter` or `ShellActions.swift`.
- **Next:** a FRESH `opus-implementer` builds pieces 2–9 from this record: the U6a UNIT RECORD and these rulings. Its live
  legs L1–L5 go to U6b's window.

### THE ORCHESTRATOR'S RULING ON U6a's ONE OPEN DECISION (2026-10-14 ~17:20 MDT)

- **(a) RULED: three clears for `pendingCompareLanding` in `CommandRouter.swift`, one beside each of the lens landing's,
  plus one app pin, red-first.** The three clears:
  - `registerDetail` drops a landing parked for another note (beside `:127–128`);
  - `unregisterDetail` drops it at teardown (beside `:151`);
  - `noteMode` drops it once the mode leaves `.compare` (beside `:463–464`).
- **Why (a):**
  - The design named the lens target's model, and the model's "one round" lives in those router clears (Round-2
    MINOR-R2's aborted-round window).
  - Without them, a landing she pre-empts (⌘1–⌘4 before the board mounts, or a teardown) waits on the router. It then
    replaces her own columns the next time she opens Compare: a queued move, which R-13nb-23 forbids.
  - (b) departs from the named model and makes her own Open › wait.
  - (c) leaves a real hole open.
- **The pin:** a landing parked, then the mode changed away (and the detail re-registered for another note) before the
  board consumes it, then her own ⌘5 on that note: her columns are untouched. It must be red on the one-property tree
  (`a846a5f1`) and green with the clears. The pin and the clears go in their own commits.
- **Lane:** vx-283 has been told about the three extra lines (the orchestrator's message with this ruling). The build
  continuation may make exactly those edits in `CommandRouter.swift`, and nothing else in the registry.
- **Context:** the harness reports the build session at ~570k (its own estimate said ~210k; the harness count governs).
  Pieces 7–9 plus this fix go to a FRESH, narrow continuation: the ruling's clears and pin, the two revert checks (row
  7's exact steps), the headless finals, and the LIVE LEGS' final form for U6b.
- **The flake** the build met (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`,
  16.3–16.7 s against its 15 s bound at load average 9–67, green alone) is minted as VX-353 (Debt · Test-only · Low, 13n,
  not pre-launch). It's not this run's.


## U6b UNIT RECORD — the Book Panel's collapsed chapter row (VX-330) · the undo warning's one word (VX-342) · U6's shared window (opus-implementer, from 2026-10-14 ~18:00 MDT)

**NOT DONE YET (the record's first line, per the contract — READY 2026-10-14):** THE STAGE WINDOW is not run: no stage
claimed, no app launched, no `xcodebuild test`, no simulator booted, no store touched by this session. So every app
pin's red and green (VX-330's three, VX-342's Mac and phone, U6a's `MCPCompareLandingTests`), the 125-suite batch,
VX-330's walk, VX-342's word on screen and U6a's live legs are PENDING. Everything else is DONE: the traces, the seam,
the pins, both fixes, the four products (no revert ever applied), the suite list, the window plan.

**Read in (in full, this session's own context):** CLAUDE.md + its canon; this record's header, Hard rules, LIVE STATUS,
Cross-run coordination, Her rulings (VX-330's verbatim), the U6 BRIEF items 3–4 + Lanes + Evidence, THE ORCHESTRATOR ON
U5's WINDOW, the U6a UNIT RECORD's LIVE STATUS (rows 0–9), LIVE LEGS FOR U6b's WINDOW (FINAL), THE MAC SUITES FOR U6b's
BATCH, its self-assessment and OWED, the U5b record's THE STAGE WINDOW and the U5 STAGE RUN whole; VX-281's U2 UNIT RECORD
whole (the trace, the site list, the design, P1 per site, the walk, the PROVISIONALs, OWED item 5 — this ticket's origin)
and its round-1 R1-5 row (the click pins); `notes/MCPSpec.md` in full; `notes/SessionResiliencyProtocol.md`'s implementer
section + the machinery addenda. Code at `48e250e0`: `BookPanelView.swift` and `BookPanelModel.swift` whole,
`MCPRowReach`, `MCPSharedIcon` (+ its DEBUG probe), `MCPAskGlyph`, `MCPAskBoard`, `MCPShareRoad`,
`BookOutlineRows.noteLineCollapsesIntoChapter`, the glyph hosts app-wide (grep), the pins `MCPSharedIconClickTests`,
`MCPSharedRowsTests`, `DestructiveUndoWarningTests`, `MobileUndoDoorTests`' A12 leg; `ShellActions.discardingUndoDetail`,
`MobileUndoDoor.discardingUndoDetail`, `StructuralUndoCopy`; the sherlock seed (`SampleLibrarySeeder` — one note per
chapter, each chapter's heading its note's title).

**Lanes.** VX-342's two edits are the brief's go: the ONE word in `Registry/ShellActions.swift` (`discardingUndoDetail`;
vx-283 told by the orchestrator) and its phone twin `VariorumMobile/Features/Write/MobileUndoDoor.swift`. Nothing else in
the registry, `WorkspaceModel` or `ShellRouter`. VX-330's trace stays in `Features/BookView/` and `Core/Views/` (the ask
glyph's DEBUG probe) — no registry file, no editor-seam file.

### LIVE STATUS — U6b's pieces (flipped in the same commit as each piece)

| # | piece | status |
|---|---|---|
| 0 | read-in, the traces, the design, the sweep table | DONE (this commit) |
| 1 | VX-330 SEAM + harness: `BookPanelBrain.markedNote` with the OLD behaviour (a chapter line stands for no note), ONE face helper on both rows, the ask glyph's DEBUG probe | DONE (this commit) — `BookPanelModel.swift`: `BookPanelBrain.markedNote(_:)` (a note line → its note; `.chapter` → nil, marked SEAM; `.unfiled` → nil). `BookPanelView.swift`: ONE helper `noteMarks(for:)` (`MCPSharedIcon(reaches: model.reach[id])` then `MCPAskGlyph(.note(id))` when `markedNote` names a note); `noteRow` draws its pair through it (the same two views on the same reads — behaviour unchanged) and `chapterRow` calls it after the chapter's name (draws nothing at the seam). `Core/Views/MCPAskGlyph.swift`: the DEBUG anchor `MCPAskGlyphProbe` (the icon's R1-5 shape — an AppKit view behind the button, `hitTest → nil`; Release draws exactly what it drew). Compiled at piece 6 |
| 2 | VX-330 pins (pure + two mounts), red on the seam by assertion — PENDING for the window's red run | WRITTEN (this commit) — NEW `App/Variorum/VariorumTests/BookPanelMCPMarksTests.swift`, suite `BookPanelMCPMarksTests` (3 tests, `.serialized`): `aLineThatStandsForANoteWearsItsMarksAndAHeadingWearsNone` (pure — `BookPanelTests`' grouping fixture; `lines.map(markedNote) == [nil, p1, p2, p3, nil, p4]`, the collapsed `.chapter(two, collapsed: e3)` → `p3`, a plain heading and `unfiled` → nil) · `theCollapsedChapterRowWearsItsNotesIconAndWaitingAskAndEachPressIsItsOwn` (MOUNTED in R1-5's `SharedIconRig`: sherlock's shape — a chapter "a scandal in bohemia" holding its one same-named note, the open note unfiled; a note READ grant on the story; the window's board carrying one ask on it and a road recording her presses; the collapsed row draws ONE waiting ask — her press answers `ask-vx330` — and ONE shared icon on the same row, icon first — her press presents its popover; the row's open, `.variorumOpenBookAtPost`, never fires) · `underABookGrantEveryNotesRowWearsBothMarksTheCollapsedChapterRowIncluded` (MOUNTED: a collapsed chapter, a plain heading over two notes, `unfiled` over the open note; a BOOK grant + an ask on each of the four notes → exactly 4 icons and 4 asks on 4 distinct rows, never a fifth). **Expected red on the seam (the red product): test 1 — the `lines.map` and the collapsed `== "p3"` expectations (2 issues); test 2 — the glyph and icon `drawn` expectations and their `#require`s (it stops at the glyph's `#require`); test 3 — the decision's count at `:289` (three lines stand for notes), `drawn` (3 icons · 3 asks), both `== 4` expectations and the four-rows line (exact pairs: THE STAGE WINDOW step 2). PENDING — the window's red run on `vx336-u6b-red`, green on `vx336-u6`** |
| 3 | VX-330 fix (one line: a collapsed chapter line stands for its note) | DONE (this commit) — `BookPanelBrain.markedNote`: `case .chapter(_, let collapsed): collapsed?.postID` (the SEAM line and its comment gone). Nothing else: the face helper, the hold and the reads are piece 1's / VX-281's. Green PENDING for the window (`vx336-u6`) |
| 4 | VX-342 pins (Mac + phone, new pure suites), red on the old words by assertion | WRITTEN (this commit) — NEW `App/Variorum/VariorumTests/UndoWarningWordsTests.swift` (suite `UndoWarningWordsTests`, 1 test) and NEW `App/Variorum/VariorumMobileTests/MobileUndoWarningWordsTests.swift` (suite `MobileUndoWarningWordsTests`, 1 test): `theWarningsDetailSaysBeforeInLowercaseAndShoutsNothing` — for the labels Divide (1 take) · Make Block (3) (· the Mac adds an MCP label, `claude-code's blocks`) the door's detail contains "as it was before the <label lowercased>," and no word of two letters or more written all in capitals; the shared question held to the same (green on both trees). (A pin-authoring compile error met at piece 6's first phone build and fixed in the pin, never the code: `MobileUndoDoor` is main-actor isolated, so the phone suite is `@MainActor` — `e10d3f57`.) **Expected red on the old words: the `contains` and the no-shouting expectations for each label — Mac 6 issues, phone 4. PENDING — the window's red runs (Mac `vx336-u6b-red`, phone `vx336-u6b-ios-red` on a simulator), green on `vx336-u6` / `vx336-u6b-ios`** |
| 5 | VX-342 fix ("BEFORE" → "before", both doors) | DONE (this commit) — `Registry/ShellActions.swift` `discardingUndoDetail` (the brief's lane go; vx-283 told) and `VariorumMobile/Features/Write/MobileUndoDoor.swift` `discardingUndoDetail`: one word each, nothing else in either file. `Shared/StructuralUndoCopy.swift` checked whole — already sentence case, untouched. Green PENDING for the window (Mac `vx336-u6`, phone `vx336-u6b-ios`) |
| 6 | the products: `vx336-u6` rebuilt from the final tree; `vx336-u6b-red` (my two fixes reverted); phone `vx336-u6b-ios` + `vx336-u6b-ios-red` | DONE — four `build-for-testing` products, each **TEST BUILD SUCCEEDED, XCB-EXIT 0, zero `error:`, no warning in a touched file** (logs `notes/plans/vx336-screens/u6b/logs/`), 56–63 GiB free throughout. **NO REVERT EVER APPLIED:** the pins were committed AHEAD of both fixes (pieces 2 and 4 before 3 and 5), so the red products are built from the committed pre-fix tree itself (vx-282 U2's precedent), and `git diff` from each red tree to the final shows ONLY the fix lines (the collapsed case's one line + its SEAM comment; the two words; the Mac red's tree also lacks the phone pin's `@MainActor` line, which is outside the Mac product). **Mac red `App/Variorum/DerivedData/vx336-u6b-red` — from `99dd1177`** (U6a's final + the seam + both members' pins, no fix; `mac-red-build.log`): its app dylib carries "as it was BEFORE the " ×1, its test bundle `BookPanelMCPMarksTests` (442 symbols) and `UndoWarningWordsTests` (39). **Phone red `vx336-u6b-ios-red` — from `e10d3f57`** (the same + the phone pin's `@MainActor`; `generic/platform=iOS Simulator`; `ios-red-build-2.log` — the first attempt, `ios-red-build.log`, failed on the pin-authoring error recorded at row 4): `VariorumMobile.debug.dylib` "BEFORE" ×2 (the fat binary's two slices), "before" ×0. **Mac final `vx336-u6` — rebuilt in place from `006e45f8`** (U6a's `c30fa9a7` products + U6b; incremental; `mac-final-build.log`): "as it was before the " ×1, `MCPAskGlyphProbe` in the app dylib (71 symbols). **Phone final `vx336-u6b-ios` — from `006e45f8`** (`ios-final-build.log`): "before" ×2, "BEFORE" ×0. `vx336-u6-red` (U6a's — the router clears reverted at `c30fa9a7`) is KEPT AS BUILT for its one red run. Each Mac product: the Debug app `io.lduarte.Variorum.debug`, `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`; each phone product `Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun`. **Headless:** U6b changes no package line (`git diff --stat 48e250e0..HEAD -- Sources Tests Package.swift` is empty), so U6a's finals stand for the package (MCP 278/59 · core 2,871/333 · workbook 40/6, `48e250e0`'s row 8) — no `swift test` re-run owed |
| 7 | the batch's suite list (grep), every name verified in the test bundles | DONE — **125 Mac suites** (`notes/plans/vx336-screens/u6b/batch-suites.txt`): U6a's 38 (its THE MAC SUITES list, verbatim) ∪ every suite type with a `@Test` in every Mac test file naming a type U6b changed — `BookPanel*` (`BookPanelBrain`/`BookPanelView`/`BookPanelModel`, one file pair), `MCPAskGlyph`, `ShellActions` — plus the two new pin suites (95; 8 already in U6a's). **Every one of the 125 is a real type in BOTH Mac test bundles** (`nm -j` + `swift-demangle --simplified`, ≥ 20 symbols each — a name that matches nothing runs 0 tests silently). **Phone:** `MobileUndoWarningWordsTests` (the pin, 45 symbols), `MobileUndoDoorTests` (886 — the A12 alert renders the changed sentence) and `MobileRefusalTableTests` (320 — the other suite calling `MobileUndoDoor` in code), present in both phone bundles. Expected standing reds met by this set (not U6b's): VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (Todo on the board); VX-167's order-dependent `DestructiveUndoWarningTests.redoNeverAsks` (Parked — red only in wide parallel runs) |
| 8 | THE STAGE WINDOW plan (claim `vx336-u6`) → READY | DONE (this commit) — THE STAGE WINDOW below: ~105 min of work, a 130-minute claim; batch-only fallback ~30 min (claim 35) |

### The traces (written before code)

**VX-330 — the collapsed one-note chapter row wears neither MCP glyph (bug class).** Inputs → wrong output:
- An approved client reaches note N (a note, book or wing grant, or the open book), or an ask waits on N. N is the ONE
  note of chapter C and its title says C's name (`BookOutlineRows.noteLineCollapsesIntoChapter`,
  `BookOutlineRows.swift:237–242` — `BookNaming.sameName`). That is every chapter of the seeded sherlock. The Book Panel
  shows N's book.
- `BookPanelBrain.lines` (`BookPanelModel.swift:203–220`) emits ONE `.chapter(C, collapsed: N)` line and NO `.note(N)`
  line (`if collapsed == nil { lines += … }`).
- `BookPanelView.lineView` (`BookPanelView.swift:211–229`) sends `.chapter` to `chapterRow` (`:232–277`), whose label
  (`:244–259`) draws the grip, the open note's marker and the chapter's name — and no `MCPSharedIcon`, no `MCPAskGlyph`.
  Only `noteRow` (`:279–316`) draws them (`:297`, `:300`).
- **The reach IS held, never drawn:** `entryIDs(for:)` (`BookPanelModel.swift:470–473`) maps every snapshot entry, the
  collapsed one included, so `holdReach` lands `model.reach[N]`; the window's ask board carries `.note(N)`'s face. Neither
  reaches a view.
- **Wrong output:** the row that stands for N (its click opens N in its book, `:242`; its menu carries N's menu,
  `:268–271`) wears neither glyph, while every sibling note row in the same panel does. A sherlock panel shows no glyph at
  all under a grant that reaches the whole book — her report.
- **Not the cause:** the rule, the core reads and the hold (VX-281 U2's, unchanged); the icon and the glyph are
  place-blind. Only the face is missing.

**VX-342 — the undo-overwrite warning's "BEFORE" (copy).** `ShellActions.discardingUndoDetail`
(`Registry/ShellActions.swift:637–646`) and its phone twin `MobileUndoDoor.discardingUndoDetail`
(`VariorumMobile/Features/Write/MobileUndoDoor.swift:279–286`) each build "…undoing puts back the text as it was BEFORE
the <label>…" — shouty caps in rendered text, against her rule. The shared `StructuralUndoCopy` (`Shared/`) was checked
whole: its question ("Undo <label>?") and every other sentence there are sentence case — nothing to change. **No pin
asserts the word on either platform** (grep of `VariorumTests` and `VariorumMobileTests`: `DestructiveUndoWarningTests`
reads "One take has been edited", "set aside", "history"; `MobileUndoDoorTests`' A12 leg reads the phone's road name and
no "⌘"), so each door gets a small new pin.

### The design (argued — no fork; the brief's "which note's reach" is one-answer here)

- **D-330-1 — which note's reach the row reads: the note it collapsed.** The collapsed row IS the note's row (row 8,
  `BookPanelBrain.Line.chapter`'s own doc: "that line IS the note's"): her click is the note's click-through, the row's
  menu is the note's menu, the open-note marker is the note's. A chapter is no MCP place: a grant scopes a note, book or
  wing (`MCPGrantRule.ScopeKind`), an ask targets a note, book or wing (`MCPAskTarget`), and the reach rule decides notes,
  books, gatherings and wings only (`MCPReachPlace`). So exactly one reach and one ask target exist for the row — the
  note's. Argued, not provisional.
- **D-330-2 — ONE decision, ONE face, both rows.** A pure `BookPanelBrain.markedNote(_ line:) -> String?` (the note a
  line stands for: a note line's note, a collapsed chapter line's note, nil for a plain heading and "unfiled"); ONE view
  helper `noteMarks(for:)` draws `MCPSharedIcon(reaches: model.reach[id])` then `MCPAskGlyph(.note(id))` — the note
  row's exact pair, so hover, popover, the pending mark and the nested-button click are the same views on both rows.
- **D-330-3 — no new read (P1, VX-272).** The hold is unchanged: the collapsed note was already one of `entryIDs(for:)`'s
  ids (the panel's own window, ≤ `entryWindow` 300 — VX-281's P1 table). With no approved client `mcpReachStandings`
  still stops the read at the grants store. Nothing new is read anywhere.
- **D-330-4 — placement:** grip · marker · chapter name · shared icon · waiting ask — the note row's order, the
  Bookcase's (name, then the icon, then the ask). The marks keep the note row's font (`tokens.small`, the icon's own
  `rowScale`).
- **D-330-5 — the pins' form (VX-281 U2's and R1-5's).** App pins can't run headless and a pure addition can't be
  revert-run, so the SEAM form: piece 1 lands the decision and the one face helper with the OLD behaviour (a chapter
  line stands for no note — exactly what the old face drew: note rows both marks, every chapter row none); the pins
  follow; the fix is the one line flipping the collapsed case. The red product is the final tree with ONLY that line
  (and VX-342's words) reverted, so the pins compile there and fail by ASSERTION. The ask glyph gets a DEBUG anchor
  probe in `MCPAskGlyph.swift` (`MCPAskGlyphProbe` — the icon's R1-5 shape: an AppKit anchor behind the button, never a
  click target; Release draws exactly what it drew), so a mount pin can find and press it.
- **D-342-1 — the word:** "before", both doors; nothing else in either sentence moves. The pins are NEW pure suites
  (one per platform), not appended to `DestructiveUndoWarningTests` (that suite carries VX-167's order-dependent
  `redoNeverAsks`; a one-suite red run must not meet it).

### THE SWEEP — the Book Panel's shapes × the two glyphs

| shape (`BookPanelBrain.Line` / face) | drawn by | shared icon | waiting ask | disposition |
|---|---|---|---|---|
| `.note(entry, indented: true)` — a note under a chapter | `noteRow` | yes (VX-268) | yes (13n-c U4) | **SAFE** — unchanged behaviour; now drawn through `noteMarks(for:)` on the same reads (pinned in the sweep mount) |
| `.note(entry, indented: false)` — a chapterless book's notes, or under "unfiled" | `noteRow` | yes | yes | **SAFE** — the same |
| `.chapter(C, collapsed: N)` — the collapsed one-note chapter row | `chapterRow` | **no → yes** | **no → yes** | **FIXED (VX-330)** |
| `.chapter(C, collapsed: nil)` — a plain chapter heading | `chapterRow` | no | no | **SAFE** — a chapter is no MCP place (no grant scope, no ask target, no reach rule); `markedNote` answers nil (pure pin + the sweep mount) |
| `.unfiled` — the heading over chapterless notes | `lineView` | no | no | **SAFE** — a heading, no place; nil (pinned the same) |
| the header — the shown book's name, or the switcher menu | `header` | no | no | **OUTSIDE the parity rule** — the ask glyph never marks it (VX-268's site list row 5 is the panel's NOTE rows). It names a place (a book), so it is observed for the orchestrator in OWED, not built |
| "appears in N gatherings" and the gathering names it opens | `gatheringsLine` | no | no | **OUTSIDE the parity rule** — no ask targets a gathering (`MCPAskTarget`); observed in OWED with the header |
| "Showing the first 300 notes…", "This note is in no book…" | `contents`, `body` | no | no | **SAFE** — words, not places |

### THE STAGE WINDOW — the plan (claim `vx336-u6`; runs ONLY on the orchestrator's GO, under the exact claim line it relays)

**What this window does NOT do (said first):** no product code is written or changed, before the claim or under it — a
red that needs code is RECORDED as a FINDING and reported, never fixed here; no rebuild (if `git diff --name-only
006e45f8..HEAD -- Sources App Package.swift` is not empty at the GO, or the coordinator says VX-306 has merged and main
must come in first: STOP before any launch and report — the rebuild is an implementer's, row 6's exact steps); no canon,
QUESTIONS or ticket edits; never her real store, never `/Applications/Variorum.app`, never her USER-scope MCP
registrations (a copied setup line is never run as copied — only its key is taken); `castle-W1-20261013` left alone.

**The products (row 6; all on disk, nothing to build):** from `App/Variorum/`:
- `DerivedData/vx336-u6` — THE FINAL TREE (`006e45f8`: U6a + U6b): the batch, the green runs, the app launched for the
  live round and both walks (`Build/Products/Debug/Variorum.app`, `io.lduarte.Variorum.debug`, its shim
  `Contents/MacOS/variorum-mcp`).
- `DerivedData/vx336-u6-red` — U6a's (`c30fa9a7`, only the router's three clears reverted): ONE red run, never launched.
- `DerivedData/vx336-u6b-red` — U6b's Mac red (`99dd1177`, the pre-fix tree): ONE red run, never launched.
- `DerivedData/vx336-u6b-ios` / `vx336-u6b-ios-red` — the phone, final (`006e45f8`) and red (`e10d3f57`):
  simulator runs only.

**Minutes:** guards ~2 · the Mac batch ~12 · the Mac red runs ~4 · the phone red + green ~10 (a first simulator boot) ·
SEAM · A1 + prefs + fingerprint ~4 · launch, connect, bind ~5 · VX-330's walk in both voices ~19 · VX-342's word ~5 ·
U6a's grant + L0–L5 ~26 · U6a's Terminal pass ~6 · cleanup ~10 → **~105 of work; ask a 130-minute claim.** **Batch-only
fallback (~30 min, claim 35):** steps 0–3 and the SEAM, then step 11's release lines that apply (nothing launched, so no
A1 — U1b's precedent); U6's acceptance then stays OPEN for every live leg and both walks.

**Evidence:** `notes/plans/vx336-screens/u6/` (gitignored — U6a's legs' folder): `logs/`, the turn answers `<leg>.json`,
captures `live/s/` (Study) and `live/t/` (Terminal). Keys redacted to their first 9 characters in every record and capture
name.

0. **Guards, every step (U5b's step 0, unchanged).** `Tools/WalkKit/guard.sh --author` before anything touches the GUI
   (exit 3 ⇒ STOP, never quit or kill her app; exit 4 ⇒ someone at the machine, STOP); the STRICT instance guard
   `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` both empty before any launch (`restore.sh` uses the loose form
   inside — a stranger's xcodebuild line makes it exit 3: wait for that build, never edit the script); no simulator booted
   (`xcrun simctl list devices booted` — none); the claim line EXACTLY as the GO relays it; `Tools/stage status` never in
   an `&&` chain; `guard.sh <devpid> x y` before each click; ≥ 2.6 s between synthetic events; region captures; HEAD at the
   GO recorded; `Tools/WalkKit/wl2` present in this worktree (compiled at U5 — re-compile if missing; `guard.sh <pid>` needs
   it).
1. **THE MAC BATCH (~12 min) — FIRST.** From `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum
   -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u6 -resultBundlePath
   ../../notes/plans/vx336-screens/u6/u6-batch.xcresult` + one `-only-testing:VariorumTests/<Suite>` per suite below,
   detached to `…/u6/logs/u6-batch.log` and POLLED in the foreground (a `grep -q` loop on `** TEST EXECUTE` — never
   `tail -f | grep -m1`). **The 125 suites:** U6a's 38 (THE MAC SUITES FOR U6b's BATCH, verbatim) and these 87 (every
   suite in a Mac test file naming a type U6b changed — row 7; the 125 names, one per line, also at
   `notes/plans/vx336-screens/u6b/batch-suites.txt`): AutosaveRegistryReleaseGuardTests · AutosaveRegistryReleaseTests ·
   BlockDeletionAndRedoTests · CarveCaretLandingTests · BlockHistoryPaneTests · BookArchiveDeclarationTests ·
   BookArchiveDoorActTests · BookSettingsArchiveRowTests · ArchivedBooksGroupTests · ArchivedMarkTests ·
   ComesBackReceiptTests · WingContentsArchivedWordsTests · BookAnchorTests · BookCarryTests · PagedAnchorReportTests ·
   BookChooserOrderTests · ContextBarTests · AscentDoorTests · AscentRoutingTests · MultiBookEditNoteRuleTests ·
   MultiBookEditNoteTriggerTests · DivergeDoorTests · BookCollectingDoorsTests · BookPanelDragGateTests ·
   BookPanelMCPMarksTests · BookPanelBrainTests · BookPanelDeclarationTests · BookPanelActingTests ·
   BookViewDropGateTests · CanvasAndPoolTests · CanvasTakesSwitcherTests · CanvasBoardGeometryTests ·
   CanvasRealizationTests · CanvasHostedRealizationTests · CanvasOrderAndOverviewTests · CanvasFocusedBlockFactTests ·
   StatusCenterTests · MoveAndExecuteTests · SealDoorTests · BlockTOCStatusTests · TakesWordCountTests ·
   DestructiveUndoWarningTests · DocumentImportDoorTests · DragTypeDeclarationTests · EncryptionBookDoorTests ·
   FormattingSurfacesTests · MCPSharedIconClickTests · MCPSharedRowsRulesTests · MCPSharedRowsTests ·
   NoteBoxGeometryTests · NoteBoxCompositionTests · NoteVersionsPaneTests · QuickNoteMintTests · QuickNoteDoorTests ·
   QuickNoteWindowTests · QuickNoteWordTests · RecoveryDoorsTests · SampleLibraryTests · EncryptionExplainedSeedTests ·
   SampleLibraryWelcomeTests · SealedBookMemberDoorTests · ShellConfirmTests · StarTargetingTests ·
   StarDeclarationTests · StarActingTests · TrayPanelMoveTests · TutorialBookShapeTests · TutorialDoorTests ·
   TutorialWritingActsTests · TutorialTakesActsTests · TutorialStructureActsTests · TutorialLibraryActsTests ·
   TutorialDeletionActsTests · TutorialWherePlacesActsTests · TutorialPrivacyChapterTests · TutorialFannedMatrixTests ·
   UndoWarningWordsTests · UnfiledWordTests · WindowRegistryTests · PaneMountWindowTests · NoteOnlyWindowTests ·
   IndependentWorkspaceTests · TwoWindowMountTests · WindowUnmountTests · CreationTargetTests ·
   WriteTakesPanelChooseTests · WriteTakesPanelKeysTests.
   **Expected:** green, the gated `*CaptureTests` skipping (read the `skipped:` lines — Swift Testing's "N tests passed"
   counts skips); **`MCPCompareLandingTests` 7/7, `BookPanelMCPMarksTests` 3/3, `UndoWarningWordsTests` 1/1 GREEN** (the
   pins' green-on-new); `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` walks `duplicate_note`. **Standing
   reds, not U6's (named if met):** VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` (Todo — stale
   on main since 13o U3); VX-167's `DestructiveUndoWarningTests.redoNeverAsks` (Parked — red only in wide parallel runs;
   re-run that suite ALONE once). Known noise, not a red: «Issues recorded without an associated test». Any other red:
   re-run that suite ALONE once; a red that reproduces is a FINDING — recorded and reported; the live round continues only
   if it is outside every type this run changed (else cleanup, release, report).
2. **THE MAC RED RUNS (~4 min) — the pins' red-on-old.** From `App/Variorum/`, each detached to its log and polled:
   - **U6a's:** `xcodebuild test-without-building -xctestrun
     DerivedData/vx336-u6-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
     -only-testing:VariorumTests/MCPCompareLandingTests` → `logs/u6a-red.log`. **Expected EXACTLY: 7 tests, 2 failed, 5
     passed, 9 issues** — `aLandingSheOutrunsWithAnotherModeIsDroppedAndHerOwnCompareKeepsHerColumns` at
     `MCPCompareLandingTests.swift:272`, `:239`, `:241`; `aLandingWhoseNoteLeavesBeforeTheBoardTakesItIsDroppedAndHerOwnCompareKeepsHerColumns`
     at `:300`, `:239`, `:241`, `:317`, `:239`, `:241` (U6a row 6a).
   - **U6b's:** `xcodebuild test-without-building -xctestrun
     DerivedData/vx336-u6b-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
     -only-testing:VariorumTests/BookPanelMCPMarksTests -only-testing:VariorumTests/UndoWarningWordsTests` →
     `logs/u6b-red.log`. **Expected EXACTLY: 4 tests, 4 failed, 15 issues** — VX-330 (`BookPanelMCPMarksTests.swift`):
     `aLineThatStandsForANoteWearsItsMarksAndAHeadingWearsNone` at `:83`, `:85`;
     `theCollapsedChapterRowWearsItsNotesIconAndWaitingAskAndEachPressIsItsOwn` at `:233`, `:235` (the `#require` ends
     it — no glyph drew); `underABookGrantEveryNotesRowWearsBothMarksTheCollapsedChapterRowIncluded` at `:289`, `:308`,
     `:309`, `:310`, `:314` (three icons, three asks); VX-342 (`UndoWarningWordsTests.swift`):
     `theWarningsDetailSaysBeforeInLowercaseAndShoutsNothing` at `:34` ×3, `:36` ×3. Every other expectation in those
     tests GREEN there (the reach holds, the fixtures' shapes, the questions). The same four GREEN in step 1's batch =
     red-on-old and green-on-new for both members on the Mac. Any other pair is a finding.
3. **THE PHONE (~10 min) — VX-342's phone pin, red then green** (a phone pin changed, so it runs on a simulator under
   the claim; the phone line makes this run mobile-visible). `xcrun simctl list devices available | grep iPhone` — take
   an iPhone 17 Pro on iOS 27.x if listed, else 26.2 (the products are generic-simulator builds, deployment iOS 26); record
   its UDID. From `App/Variorum/`, each detached and polled, both with `-collect-test-diagnostics never` (vx-282's
   lesson: without it a run loses 600 s collecting diagnostics):
   - **red:** `xcodebuild test-without-building -xctestrun
     DerivedData/vx336-u6b-ios-red/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun
     -destination 'platform=iOS Simulator,id=<UDID>' -collect-test-diagnostics never
     -only-testing:VariorumMobileTests/MobileUndoWarningWordsTests` → `logs/u6b-ios-red.log`. **Expected EXACTLY: 1 test,
     1 failed, 4 issues** — `MobileUndoWarningWordsTests.swift:35` ×2, `:37` ×2.
   - **green:** the same against `DerivedData/vx336-u6b-ios/…xctestrun` with `-only-testing:VariorumMobileTests/` ×3 —
     `MobileUndoWarningWordsTests` `MobileUndoDoorTests` `MobileRefusalTableTests` → `logs/u6b-ios.log`. **Expected: all
     green in ONE launch** (no "Restarting after unexpected exit"; read the ✔/✘ lines per suite).
   - `xcrun simctl shutdown <UDID>`; confirm 0 booted.
   **→ THE SEAM:** record steps 1–3's counts in this record, commit, push, KEEP the claim, report "SEAM" through the
   orchestrator; the A1 copy waits for the coordinator's one word ("continue" or "release for X").
4. **A1 prestage copy + prefs + fingerprint (~4 min) — U5b's step 2, exactly.** `stage.sh`'s copy loop only (the five
   store files into `…/Variorum-dev/Backups/safety-copies/scale-prestage-<UTC yyyymmddTHHMMSSZ>/`, each `cmp`-verified,
   sha256 prefixes recorded → `u6/store-hash-pre.txt`, the path → `u6/a1-path.txt`); `defaults export
   io.lduarte.Variorum.debug …/u6/prefs-pre.plist` (key count); `Backups/` listed; her user-scope servers' names + the
   sha256 prefix (U5b step 2's `python3 -I` line) — expected `['linear-server', 'variorum']`, `bc64543e2f4e8e58`; the
   clipboard saved (`pbpaste > <scratch>/clip-before.txt`).
5. **Launch, connect, bind (~5 min) — U5b's step 3, exactly** (`open -n DerivedData/vx336-u6/Build/Products/Debug/Variorum.app`;
   a What's New sheet → its own button; Study expected — capture `live/s/00-launch`; MCP Settings ▸ the switch ON;
   Connect ▸ Claude Code ▸ the copy icon → ONLY the key into `<scratch>/keys/u6-mcp.json` per U6a's LIVE LEGS' form; the
   first turn binds with zero clicks — Activity "…bound to its name" or "…replaced its earlier one"; an unknown name →
   Waiting ▸ Approve… alone). Every turn per U6a's LIVE LEGS form (prompts on STDIN). **No grant yet** — VX-330's walk
   makes its own.
6. **VX-330's WALK — sherlock's Book Panel in BOTH voices (~19 min).**
   - **W0 — sherlock present.** Bookcase: "the adventures of sherlock holmes" (Home; owned). Absent ⇒ Help ▸ **Restore
     the Sample Library** (its door; the store is restored at cleanup). Capture `live/s/W0-bookcase`.
   - **W1 — the grant: the BOOK, at READ.** claude-code ▸ Change… (with no row yet: ⌥⌘A from the Bookcase, or the book's
     row menu ▸ Share with AI…) ▸ **A book · the adventures of sherlock holmes · Read · Always** (capture the sheet
     `W1-grant-sheet` and the Shared-with-AI tab `W1-grant-row`). The Bookcase row wears the shared icon (`W1-bookcase-icon`).
     **Read the Shared-with-AI tab first:** if any OTHER claude-code grant (the restored store's standing ones) reaches
     Home or this book at SUGGEST or above, W3's `add_take` would land rather than ask — then W3 uses `edit_take` on that
     block's take instead (its text as `expected_text`; the edit rung), and if even that lands, ⌥⌘Z it and record W3 NOT
     RUN (the waiting mark's evidence is then the mount pin `theCollapsedChapterRowWears…` alone).
   - **W2 — the panel, Study.** Open the book's first story (its title read from the Bookcase / the book's Index) in
     Write; the masthead's **Book Panel** door (`book.closed`). **Expected (capture `W2-panel-study`):** sherlock's chapter
     rows are COLLAPSED one-note rows (each chapter heads its one story) and EVERY one wears the shared icon right after
     its name — the open story's row with the voice's marker (the pre-fix face wore none — VX-281 U2's walk, OWED item
     5). Any chapter that is NOT collapsed shows a bare heading over its marked note rows (the sweep's SAFE rows). Click
     ONE row's icon (not the open story's) → its popover: "Shared with" · claude-code · "read · always" · "through “the
     adventures of sherlock holmes”" · Change… · "Revoke the grant on “the adventures of sherlock holmes”" (capture
     `W2-popover-study`); Escape by `keys.sh` → the popover gone, the panel still showing the SAME note (the row's open
     never fired — her click opened only the popover).
   - **W3 — a waiting ask on one story.** ONE turn, allowed
     `mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,mcp__variorum-dev__add_take`,
     answer → `u6/w3-ask.json`:
     > In Variorum, find the book "the adventures of sherlock holmes" (list_books), then list its notes (list_notes with
     > that book_id). Take its THIRD note: call read_note on it with with_ids true, then call add_take on its first block
     > with text "A take the AI suggests." Reply with each answer verbatim. Do not retry or work around a refusal.
     **Expected:** `add_take` `isError`, "This client may only read here." + the asked sentence ("Variorum has asked the
     author — call again once they answer." — read from the answer, U5's V255-b form); nothing written. **Her face
     (capture `W3-panel-ask-study`):** that story's collapsed chapter row wears the WAITING MARK (`questionmark.bubble`)
     right after its shared icon; every other row the icon alone. Settings ▸ MCP ▸ Waiting: "claude-code asks to suggest
     in “<that story>”" (capture `W3-waiting`). Leave the ask WAITING for W4.
   - **W4 — Terminal.** Settings ▸ General ▸ Theme → **Terminal** (U1b's AX road / a pointer click on the segmented
     control, as U5's step 12). Back to the same note's Book Panel (capture `live/t/W4-panel-ask-terminal`: every
     collapsed row's icon, the third story's waiting mark). One row's icon → its popover in Terminal (capture
     `W4-popover-terminal`); Escape. **Her press on the waiting mark** → THE ask's sheet opens in this window
     ("claude-code asks to suggest in “…”" · Once · Always · Don't allow — capture `W4-ask-sheet`) → **Don't allow**
     (or Esc) → the mark leaves the row, the icon stays (capture `W4-mark-gone`). Theme back to **Study** (capture
     `live/s/W4-back-study`).
7. **VX-342's word, once on the Mac (~5 min).** Bookcase quick entry `{t:"u6b undo"}One two three four.` ⏎ → the note
   in Write; click at the END of the line, then ← ×11 by `keys.sh` (key code 123) so the caret sits before "three", and
   press ⏎ (the segmentation chip ON: a divide at the caret — "One two" / "three four."); click at the end of the FIRST
   block and type ` more` (an edit to the take the divide's inverse would overwrite), then wait ~3 s (autosave).
   The Edit menu's structural undo names the entry (read it); **⌥⌘Z → the A12 warning (capture `live/s/V342-warning`):**
   "Undo <label>?" over the detail "One take has been edited since — undoing puts back the text as it was **before** the
   <label lowercased>, so that writing is set aside. It is committed first, …" — the word lowercase. **Cancel** →
   nothing changed (Write still "One two more" / "three four." — capture `V342-cancelled`). (If the ⏎ made no divide,
   use the block ▾ menu's or ⌘K's divide at the caret — the warning is the point.)
8. **U6a's GRANT + LIVE LEGS L0–L5 (~26 min) — EXACTLY as U6a's "LIVE LEGS FOR U6b's WINDOW (FINAL)" writes them**
   (THE GRANT: claude-code's Shared-with-AI row ▸ Change… ▸ **A wing · Home · Edit · Always** — "Confirming replaces
   the grant you opened this from": from W1's book row it REPLACES the sherlock book grant, which is fine — the wing
   grant reaches the book; then L0 the fixture through the wire, L1a `duplicate_note` + her ⌥⌘Z/⇧⌥⌘Z, L1b the AI edits
   the copy, L2 Compare on the pair from the Bookcase, L3 the stranger on the mounted board, L4 `link_versions`' Open ›,
   L5 not frontmost; Variorum frontmost for every `show_in_app` turn but L5; ids by substitution; every capture named
   there, into `live/s/`).
9. **U6a's TERMINAL PASS (~6 min) — exactly as written there** (Theme → Terminal; L2's and L3's turns again → `live/t/L2-terminal`,
   `L3-terminal`; back to Study).
10. **Cleanup (~10 min) — U5b's step 13, exactly:** the scratch config and every key deleted, the clipboard restored
    from `clip-before.txt` (`pbpaste | cmp - clip-before.txt` SAME), a whole-key grep (each key in full) over
    `…/vx336-screens/u6/`, `~/.claude.json`, the scratch project's transcripts and `notes/` → 0 files; no `-s local`
    registration (`claude mcp get variorum-dev` in the scratch project → "No MCP server named …"); her user-scope
    fingerprint AFTER = BEFORE (`bc64543e2f4e8e58`); the Debug app quit BY BUNDLE ID, the strict guard empty, no shim
    left, 0 simulators booted; prefs `defaults import …/u6/prefs-pre.plist`, re-export, diff, `defaults delete` every key
    the window ADDED (import merges) until **0 added · 0 removed · 0 changed**; `Tools/ScaleFixture/restore.sh "<the A1
    dir>"` → "Restored (verified)", a second `cmp` of every file SAME and the sha256 set equal to the A1 copy's (Standard,
    unlocked, Study, claude-code's pre-window binding and grants back — sherlock's grant, the fixture notes, the copy, the
    scratch undo note all gone with it); `Backups/` unchanged; `castle-W1-20261013` untouched; a stray `default.profraw`
    removed; the tree clean.
11. **Release + THE RESULT LINE:** `Tools/stage release --who vx336-u6`; then one line to the coordinator: claim times;
    the batch's counts; each red run EXACT or not; the phone runs; VX-330's walk (W2–W4) PROVEN or RED; VX-342's word
    seen; each U6a leg PROVEN or RED; posture (Standard/unlocked, cmp SAME vs A1, prefs 0 differ, fingerprint SAME, 0
    simulators booted); the A1 path (the coordinator's to prune).

**The coordinator's machinery facts, carried (Hard rules + THE ORCHESTRATOR ON U5's WINDOW):** the strict instance
forms only; `Tools/stage status` exits 1 while held — never in `&&`; the What's New sheet dismissed by its own button;
`defaults import` MERGES (re-export and diff); the dev store is Standard/unlocked — a lock screen means `source
~/.variorum/dev-castle.env`, those values only, posture restored before release; a window of an hour or more runs its
tests FIRST and pings SEAM before the A1; the Castle heads-up (VX-306 merged ⇒ merge main first, STOP here); `claude -p
--allowedTools <list>` swallows a trailing prompt (prompts on STDIN); System Events drops non-ASCII (every fixture here is
ASCII); `Tools/WalkKit/wl2` per worktree; a system popup Variorum can't dismiss = STOP, its exact words reported.

### PROVISIONALs

*None.* VX-330's one product question — which reach a collapsed row wears — has one answer (D-330-1, argued); VX-342 is
her rule applied to one word. Nothing for `notes/QUESTIONS.md`.

### FOR VX-234 (user-facing words, as built)

- **The Mac's A12 warning detail** (`ShellActions.discardingUndoDetail`, the alert under "Undo <label>?"): "One take
  has been edited since — undoing puts back the text as it was before the <label>, so that writing is set aside. It is
  committed first, so you can bring it back from the take's history (⌘S's list) at any time." — only "before" changed.
- **The phone's twin** (`MobileUndoDoor.discardingUndoDetail`): "… as it was before the <label>, so that writing is set
  aside. It is saved first, so you can bring it back from the block's Block History at any time." — only "before"
  changed. **For her eye, not changed here:** the phone says "It is saved first" where the Mac says "It is committed
  first" (13s-b's commit vocabulary, R-13s-31/32, said "commit" on both platforms where a savepoint was named).
- **VX-330: no new words.** The collapsed chapter row wears the existing icon (hover "Shared with … — click for details",
  its popover) and the existing waiting mark (hover "‹client› asks to … here — press to answer.").

### MOBILE PARITY (for the closeout's line)

**VX-342 is mobile-visible:** the phone's undo-overwrite warning now reads "before" in lowercase (the same one-word
change as the Mac). **VX-330: nothing mobile-visible** (the Book Panel and the MCP door are Mac-only).

### SELF-ASSESSMENT (the implementer's, pre-stage)

- **The trace held to the line:** the collapsed row's reach was ALREADY held (`entryIDs` maps every entry) and its asks
  were already on the window's board — only the face was missing. So the fix adds no read: P1 and VX-272 are untouched
  by construction, and the one decision (`markedNote`) feeds ONE face helper for both row kinds, so the collapsed row
  wears exactly the note row's two views.
- **The seam carries one refactor, said plainly:** piece 1 moved the note row's two glyphs into `noteMarks(for:)` (the
  same two views, the same arguments). The red product therefore runs that refactor too; the pins' red is the collapsed
  row only, and the note rows' marks are re-proven green in the sweep and in VX-281's suites in the batch
  (`MCPSharedIconClickTests`, `MCPSharedRowsTests`, `MCPSharedRowsRulesTests`).
- **No revert was ever applied:** the pins were committed ahead of both fixes, so the red products are the committed
  pre-fix trees; `git diff` red → final shows only the fix lines (row 6).
- **One pin-authoring error,** caught by the first phone build and fixed in the pin (`e10d3f57`): the phone suite needs
  `@MainActor`.
- **What is NOT proven yet:** every app pin's red and green, the phone runs, both walks and U6a's legs — the window's.
  The mounts' synthetic presses follow R1-5's rig exactly; the ask glyph's press is new ground for that rig (the probe is
  the icon's shape). If the glyph press misses in the batch while the frame is found, that is a rig finding to report,
  not a product red.
- **Risks I see:** (1) the DEBUG ask-glyph anchor adds an AppKit view behind every drawn glyph in DEBUG builds (∝ the
  glyphs alive, pruned on append; Release draws exactly what it drew); (2) the 125-suite batch carries VX-115's standing
  red and may meet VX-167's order-dependent one; (3) the dev store's standing claude-code grants are unknown to me (I
  never read the store) — W1 reads them before W3 relies on an ask arising.

### OWED (for the orchestrator)

1. **THE WINDOW:** REQUEST `vx336-u6` (a 130-minute claim; the batch-only fallback 35) to the coordinator; relay the
   GO's exact line. The runner: this session if resumed, else a fresh stage runner reading THE STAGE WINDOW above, U6a's
   LIVE LEGS and THE MAC SUITES, and U5's worked run.
2. **Observed, not built (the sweep's OUTSIDE rows):** the Book Panel's HEADER (the shown book's name) and its
   GATHERINGS line's names are places that wear neither glyph. Both sit outside VX-268's parity rule (no ask glyph marks
   them; `MCPAskTarget` has no gathering) and outside VX-330. To weigh; if filed: *"Book Panel: the shown book's name and
   the gatherings line wear no shared icon"* — Improvement · Confirmed · Low · project 13n; not Pre-launch; no Needs
   Lillian.
3. **Canon at the merge (MCPSpec, THE PANE AND THE SHARED ICON):** "…Pool rows, Book Panel rows (a collapsed one-note
   chapter row is its note's row and wears its marks — VX-330) and ⌘L's wing rows…".
4. **The closeout's MOBILE PARITY line:** VX-342's phone word (above).
5. **Disk after the window:** `DerivedData/vx336-u6b-red`, `vx336-u6b-ios`, `vx336-u6b-ios-red` (≈ 2.4–2.5 GB each) and
   U6a's `vx336-u6-red` serve only the window and may be deleted after it; `vx336-u6` stays until the ladder's needs are
   known. (`vx336-u5`, 2.6 GB, is still on disk — not U6b's.)
6. **Context:** ~240k by this session's own estimate at READY (the harness count governs).


## U6 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14)

**What this run does NOT do (said first):** no product code is written or changed, before the claim or under it — a red
that needs code is RECORDED as a FINDING and reported, never fixed here; no rebuild (the window runs the five products
exactly as U6a row 8b and U6b row 6 built them); no canon, QUESTIONS or ticket edits; never her real store, never
`/Applications/Variorum.app`, never her USER-scope MCP registrations (the copied setup line is never run as copied — only
its key is taken, into a scratch `--mcp-config` JSON in the runner's scratchpad, OUTSIDE the repo, deleted at cleanup);
`castle-W1-20261013` left alone. The plan is the U6b UNIT RECORD's THE STAGE WINDOW (steps 0–11); its step 8 is the U6a
UNIT RECORD's LIVE LEGS FOR U6b's WINDOW (FINAL), run exactly as written there, and its step 1 carries U6a's THE MAC
SUITES FOR U6b's BATCH.

**Read in full before READY (never delegated):** this record's header, Hard rules, LIVE STATUS, Stage traffic log and
Cross-run coordination; the U6b UNIT RECORD whole; the U6a UNIT RECORD's first lines, LIVE STATUS (rows 0–9, the products
and the red-run notes of rows 6a/8b), LIVE LEGS FOR U6b's WINDOW (FINAL), THE MAC SUITES FOR U6b's BATCH, its
self-assessment, OWED and the two rulings; THE ORCHESTRATOR ON U5's WINDOW; the U5 STAGE RUN whole and the U5b STAGE
WINDOW it ran (steps 0–13 — the exact commands U6b's steps 4, 5 and 10 point at); `notes/SessionResiliencyProtocol.md`
(the implementer rules and the addenda); `Tools/stage`; `Tools/WalkKit/` (README, `guard.sh`, `click.sh`, `keys.sh`);
`Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); the memory note walk-driving-lessons.

**The build check (READY, 2026-10-14 ~18:15 MDT):**
- **The final product matches the tree.** HEAD `2e90594f` (the orchestrator's U6-ready commit); `git diff --name-only
  006e45f8..HEAD -- Sources App Package.swift` is EMPTY (the only file changed since is this record); the tree is clean;
  no `.swift`/plist/pbxproj/xcstrings/entitlements/`Package.swift` under `Sources`, `App/Variorum` or the root is newer
  than `vx336-u6`'s `Variorum.debug.dylib` (17:39).
- **The red products' trees are as recorded:** `git diff 99dd1177..006e45f8` (Mac red → final) and `e10d3f57..006e45f8`
  (phone red → final), over `Sources App Package.swift`, are EXACTLY the fix lines — `BookPanelModel.swift`'s SEAM comment
  + `case .chapter: nil` → `case .chapter(_, let collapsed): collapsed?.postID`; "BEFORE" → "before" in `ShellActions.swift`
  and `MobileUndoDoor.swift` — plus, for the Mac red only, the phone pin's `@MainActor` (outside the Mac product).
  `vx336-u6-red` = `c30fa9a7` with only `4ef02349`'s seven router lines reverted: the router blob at `a846a5f1` is
  `47db0c25` and at `c30fa9a7`/HEAD `71504ce0` (U6a row 8b's two blobs).
- **The five products exist** (2.4–2.5 GB each), each read from its binaries:
  *[removed for publication]*
    `.xctestrun`; the dylib "as it was before the " ×1 / "BEFORE" ×0, `CompareLanding` 64 symbols, `MCPAskGlyphProbe` 73,
    "duplicating a note in" ×1.
  - `vx336-u6-red` (17:10): signed the same; "BEFORE" ×1 (U6b not in it), `MCPAskGlyphProbe` 0; its test bundle carries
    `MCPCompareLandingTests` (592 symbols) and both ruled pin names (`aLandingSheOutruns…` 50, `aLandingWhoseNoteLeaves…` 67).
  - `vx336-u6b-red` (17:33): signed the same; "BEFORE" ×1, "before" ×0, `MCPAskGlyphProbe` 73 (the seam is in it).
  - `vx336-u6b-ios` (17:41): `VariorumMobile.debug.dylib` "before" ×2, "BEFORE" ×0; the `…iphonesimulator27.0-arm64-x86_64.xctestrun`.
  - `vx336-u6b-ios-red` (17:36): "BEFORE" ×2, "before" ×0; the same `.xctestrun` name.
- **The suites are real types** (`nm -j` + `swift-demangle --simplified`, matched on word edges — a name that matches no
  type runs 0 tests silently): all **125** of `notes/plans/vx336-screens/u6b/batch-suites.txt` (= U6a's 38 verbatim + the
  plan's 87, no duplicate, checked name by name against the plan's text) in BOTH `vx336-u6` and `vx336-u6b-red`, ≥ 56
  symbols each (the least `UndoWarningWordsTests`); `BookPanelMCPMarksTests` 471 and its three test names, and
  `UndoWarningWordsTests`' one test name, in both; `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` present.
  Phone, in both bundles: `MobileUndoWarningWordsTests` 62 · `MobileUndoDoorTests` 891 · `MobileRefusalTableTests` 325.

**Host and tools:** `AX: true SCREEN: true` (a compiled non-prompting probe); `walk-cap` / `walk-scroll` compiled into the
runner's scratchpad; `Tools/WalkKit/wl2` present in this worktree (gitignored, compiled at U5); Claude Code **2.1.300**;
`cliclick` present. Free disk **57 GiB**. No Variorum instance (`pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"`
both empty; the loose form empty too). **No simulator booted.** The phone's device for step 3: no iPhone 17 Pro is listed
*[removed for publication]*

**Her user-scope MCP servers (names + a sha256 prefix of the sorted compact `mcpServers` JSON, never values):**
`['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as U5's windows.

**The dev store (read-only listing):** `variorum.sqlite` (14 Oct 08:50), `-wal` 09:17, `-shm` 15:13 (U5's restore keeps
the A1's stamps), key files `variorum-keys-b831b428ce0d67b1.json` · `variorum-keys-e86ed514dc8dab5a.json`; `Backups/` 57
entries; `Backups/safety-copies/` holds only `castle-W1-20261013` (left alone — U5's A1 copy already pruned). Prefs 1,596
keys, `variorum.whatsNew.lastVersion` 0.9.6, `appearanceChoice` system. The stage log shows no window since U5's release
(15:49:56).

**The stage at READY:** `STAGE HELD by 'oct13coordinator' — HOLD: coordinator queue` (claimed 17:48:31). Not ours; the
GO's relayed line is run exactly as relayed.

**Process choices (the earlier windows' lessons applied):** the Mac batch FIRST, then the two Mac red runs, then the phone
red and green, each detached to its log and POLLED in the foreground (a `grep -q` loop, never `tail -f | grep -m1`); the
SEAM after them; the A1 copy, prefs export and fingerprint after the SEAM; every GUI act through `click.sh` / `keys.sh`
(keys only by System Events), at least 2.6 s apart; region captures (`screencapture -x -R`); `á`/`·` never typed (every
fixture is ASCII); the Debug app quit BY BUNDLE ID; prefs restored by import, then re-export, diff, delete every added key
until 0 differ; keys redacted to their first 9 characters in every record and capture name; the `claude -p` turns from a
scratch project directory in the scratchpad, prompts on STDIN, each answer tee'd to `notes/plans/vx336-screens/u6/<leg>.json`.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the coordinator's GO and its exact line) |
| 0 | guards; the claim from the GO's line; HEAD at the GO | DONE — the GO from oct13coordinator at 17:52 (its checks: no instances by the strict forms, no booted simulators, 57 GiB free, Debug launches cleared today; its two asks: ONE simulator, shut down BEFORE the SEAM ping; each red product deleted once its red run is recorded). **HEAD at the GO `276b3059`** (this section's READY commit; no source moved). Pre-claim: `guard.sh --author` OK (idle 7,468 s), both strict guards empty, no simulator booted, `stage status` → held by `coord-for-vx336` ("GO pending: vx336-u6"). The exact line run: `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u6 --reason "VX-336 U6: 125-suite Mac batch + reds (one sim), SEAM, then real-client MCP live round + Compare/Book Panel walk on the Debug dev store (A1 prestage)" --minutes 130` → **STAGE RELEASED (was 'coord-for-vx336') · STAGE CLAIMED by 'vx336-u6' for 130 min at 17:52:45 MDT** (expires 20:02:45) |
| 1 | the Mac batch (125 suites on `vx336-u6`, `test-without-building`, detached + polled) | DONE (17:52:49 → 17:59:19) — from `App/Variorum/`, the 125 `-only-testing:VariorumTests/<Suite>` from `u6b/batch-suites.txt`, `-resultBundlePath …/u6/u6-batch.xcresult`, detached to `u6/logs/u6-batch.log`, polled. **"Test run with 790 tests in 125 suites failed after 351.013 seconds with 4 issues" · `** TEST EXECUTE FAILED **`**; the result bundle: **790 total · 786 passed · 2 failed · 2 skipped · 0 expected failures** (125 suites seen). **The pins' green-on-new: `MCPCompareLandingTests` 7/7 · `BookPanelMCPMarksTests` 3/3 · `UndoWarningWordsTests` 1/1** (per-test results from the bundle; both ruled pins ✔, the three VX-330 pins ✔, the VX-342 pin ✔); `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` ✔ (walks `duplicate_note`). The 2 skips are the gated capture harnesses (`MCPGrantSheetU2CaptureTests` 1, `TutorialMCPChapterCaptureTests` 1). No «Issues recorded without an associated test». **The two reds are EXACTLY the plan's two named standing reds, neither U6's:** (a) **VX-115** `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` at `:101` (`BookView.surfaceCapabilities == [.openBookSettings]` — stale on main since 13o U3; U6 changes no `BookView` capability); (b) **VX-167** `DestructiveUndoWarningTests.redoNeverAsks` at `:141`/`:142`/`:143` (after the undo the redo never ran: slots `["First sentence. Second one."]`, `redoDepth` 1, the status not "Redid"). **The plan's re-run ALONE:** the suite alone (`u6/logs/u6-destructive-alone.log`, 18:00:39) — **still red, the same three lines** (7 tests, 1 failed); so, to split VX-167's mechanism from this run's lines, the SINGLE test alone (`-only-testing:…/DestructiveUndoWarningTests/redoNeverAsks()`, `u6-redoNeverAsks-single.log`, 18:02:16) — **✔ passed in 0.078 s, `** TEST EXECUTE SUCCEEDED **`**. So it is VX-167's shared-process dependence (Swift Testing runs a suite's tests in parallel — its six siblings share the process), now seen at SUITE scope too (load average 12–15 during the run, another worktree's `swift test` busy) — a data point for VX-167, not a U6 finding: the path the test walks (`UndoStack`, the divide ops, `structuralRedo`) has no line changed on this branch (`git diff 074c0f94..HEAD` — `ShellActions.swift`'s one change is the word in `discardingUndoDetail`, a string the test's `confirm: { _ in true }` never reads) |
| 2 | the Mac red runs: U6a's `MCPCompareLandingTests` on `vx336-u6-red` (expect 7 · 2 failed · 9 issues); U6b's two suites on `vx336-u6b-red` (expect 4 · 4 failed · 15 issues) | DONE — **both EXACT.** **U6a's** (`-xctestrun …/vx336-u6-red/…xctestrun -only-testing:VariorumTests/MCPCompareLandingTests`, `u6/logs/u6a-red.log`, 18:02:50): **7 tests, 2 failed, 5 passed, 9 issues** — `aLandingSheOutruns…` at `:272`, `:239`, `:241`; `aLandingWhoseNoteLeaves…` at `:300`, `:239`, `:241`, `:317`, `:239`, `:241` (`u6a-red.pairs`) — the plan's nine pairs in order; the 5 earlier tests ✔. With step 1's 7/7 on `vx336-u6`: **the ruled pin red-on-old and green-on-new on the Mac.** **U6b's** (`-xctestrun …/vx336-u6b-red/…xctestrun -only-testing:VariorumTests/BookPanelMCPMarksTests -only-testing:VariorumTests/UndoWarningWordsTests`, `u6b-red.log`, 18:03:37): **4 tests, 4 failed, 15 issues** — VX-330 `aLineThatStandsForANote…` `:83`, `:85`; `theCollapsedChapterRowWears…` `:233`, `:235`; `underABookGrantEveryNotesRow…` `:289`, `:308`, `:309`, `:310`, `:314`; VX-342 `theWarningsDetailSaysBefore…` `:34` ×3, `:36` ×3 (`u6b-red.pairs`) — exactly the plan's fifteen. With step 1's 3/3 and 1/1: **VX-330 and VX-342 red-on-old and green-on-new on the Mac.** Both Mac red products then DELETED at the coordinator's ask (`DerivedData/vx336-u6-red`, `vx336-u6b-red`) |
*[removed for publication]*
| SEAM | steps 1–3's counts recorded, committed, pushed; the claim KEPT; turn ended "SEAM" | DONE (18:06) — the claim `vx336-u6` held (~13 of 130 min used; expires 20:02:45); no Variorum instance; nothing launched; 0 simulators booted; no A1 copy taken (it waits for the coordinator's one word, "continue" or "release for X"). The red products are deleted; on disk `DerivedData/vx336-u6` (the final — the live round's) and `vx336-u6b-ios` (U6b OWED 5: deletable after the window); 62 GiB free |
| 4 | A1 prestage copy (cmp + sha256) + prefs export + `Backups/` + the fingerprint BEFORE + the clipboard saved | DONE (18:07:11, after the coordinator's "continue" at the SEAM) — **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T000711Z`** (`u6/a1-path.txt`), `stage.sh`'s copy loop only, every instance guard empty first: five files each `cmp`-verified (sha256 prefixes: sqlite `c17923414b2e` · wal `7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890`; `u6/store-hash-pre.txt`) — EQUAL to U5's A1 set (the store unchanged since U5's restore); `castle-W1-20261013` untouched. Prefs exported: **1,602 keys** (the batch's test host added 6 since READY's 1,596 — the Hard rules' order: this export, after the batch, is the restore target) → `u6/prefs-pre.plist`. `Backups/` 57 entries (`u6/backups-pre.txt`). Her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME (`u6/userscope-pre.txt`). The clipboard saved: **0 bytes** (empty) |
| 5 | launch `vx336-u6`, connect (the Claude Code tab key → scratch `u6-mcp.json`), the first turn binds | DONE (18:07–18:10) — `open -n` the `vx336-u6` Debug app (**pid 40633**, 1380×900 at (60,36)); **Study, light, the Bookcase; no What's New sheet, no lock screen** (`live/s/00-launch`) — sherlock present (W0). App menu ▸ MCP Settings… (by AX): the switch ON, "running · socket in the app container · serves while Variorum is open"; Clients: claude-code "last seen 4 days ago · 3 grants" (`01-mcp-pane`). **Shared with AI read first (W1's check):** claude-code's three grants are ALL on the book "o ladrão de raios" (read, suggest, write new and edit · read and suggest · read — all always); none on Home or sherlock; Open book OFF (`02-shared-before`, `02b-…-scrolled`) — so W3's `add_take` will ask as written. Connect ▸ **Claude Code** ▸ the copy icon (`03-connect`) → from the clipboard ONLY the key (**`vmk2_clau…`**, 60 chars, `vmk2_claude-code_` prefix) into the scratchpad's `keys/u6-mcp.json` (command = a scratchpad tee wrapper around the product's shim `variorum-mcp`; never the copied line, never `-s local`, never her user scope). The first turn (`list_books`, `u6/u6-bind.json`, prompt on STDIN) SERVED "o ladrão de raios"; the tee: `initialize` OK (`variorum` 0.9.6), **`tools/list` 61 tools — `show_in_app` among them, `duplicate_note` NOT, by design**: the catalog lists a tool only for a grant of a scope kind it acts under (`MCPToolDeclaration.isListed`, `MCPToolCatalog.swift:44`), and `duplicate_note` is `scopes: [.wing]` while claude-code holds book grants only — it lists once step 8's Home wing grant lands. **Activity "claude-code connected with a new setup, now bound to its name"** with zero clicks, then "claude-code listed books" (`04-bind-activity`) |
| 6 | VX-330's walk: W0 sherlock · W1 the book grant at READ · W2 the panel + popover (Study) · W3 a waiting ask · W4 Terminal + the mark's press | **PROVEN in both voices** (18:10–18:19). **W0:** "the adventures of sherlock holmes" on the Bookcase (Welcome; 13 notes · 13 ch · owned) — no restore needed (`live/s/W0-bookcase`). **W1:** Clients ▸ claude-code ▸ Change… → the grant sheet (A book) → the book chooser popover → sherlock → **"Grant read in “the adventures of sherlock holmes” always, including to future entries"** (`W1-change`, `W1-picker`, `W1-grant-sheet`) → Shared with AI: **"the adventures of sherlock holmes · book · claude-code · read · always"** (`W1-grant-row`); the Bookcase's sherlock row now wears the shared icon (`W1-bookcase-icon`). (The standing grants, read first at step 5: none reaches Home or the book at SUGGEST, so W3 runs as written.) **W2 (Study):** the book opens in Outline (`W2-book-open`); "A Scandal in Bohemia" ▸ open ↗ (it opened in its remembered Takes; ⌘1 → Write — `W2-story-write`); the masthead's "Show this note's book beside the draft" door → **the Book Panel: the header "the adventures of sherlock holmes · owned"; "about this text" a BARE heading (its note is titled "About this book", so it does not collapse) over the note row "About this book" wearing the icon — the sweep's SAFE rows; then the TWELVE story chapters, every one a COLLAPSED one-note row, EVERY one wearing the shared icon right after its name** (`W2-panel-study`, the crop `W2-panel-study-crop`) — the pre-fix face wore none (VX-281 U2's walk). The Red-Headed League's icon → its popover **"Shared with · claude-code read · always · through “the adventures of sherlock holmes” · Change… · Revoke the grant on “the adventures of sherlock hol…”"** (truncated by the popover's width) while the page stayed "A Scandal in Bohemia" — the row's open never fired (`W2-popover-study`); ⎋ by `keys.sh` → the popover gone, the same note (`W2-popover-escaped`). *Observed, not this unit's:* in Study the open story's collapsed row wears no visible marker (Terminal shows its "›" — W4); VX-330 adds glyphs, not the marker. **W3:** ONE turn (`u6/w3-ask.json`; the tee's calls) — `list_books` (sherlock `53E760EF…`), `list_notes` (About this book · A Scandal in Bohemia · **The Red-Headed League** · …), `read_note(829C81B9…, with_ids)`, `add_take(block 5BD3738E…, "A take the AI suggests.")` → **`isError: true`, EXACTLY "This client may only read here. Variorum has asked the author — call again once they answer."**; nothing written. **Her face:** the Red-Headed League's collapsed row wears **the WAITING MARK (`questionmark.bubble`) right after its shared icon**, every other row the icon alone (`W3-panel-ask-study`, `-crop`); Settings ▸ MCP ▸ **Waiting: "claude-code asks to suggest in “The Red-Headed League”" · Answer…** (`W3-waiting`). **W4 (Terminal):** Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control — `live/t/00-theme-terminal`); the panel in Terminal: "› a scandal in bohemia" (the voice's open-note marker), every collapsed row its icon, "the red-headed league" icon + waiting mark (`live/t/W4-panel-ask-terminal`); "a case of identity"'s icon → the same popover in Terminal (`W4-popover-terminal`), ⎋ (`W4-popover-escaped`); **her press on the waiting mark → THE ask's sheet in this window: "claude-code asks to suggest in “The Red-Headed League”" · "If you allow it, it can add new takes and comments beside your text, and save a lens of its takes — it cannot touch a word you wrote." · Once · Always · Don't allow** (`W4-ask-sheet`) → **Don't allow** → the mark LEFT the row, the icon stayed (`W4-mark-gone`). Theme back to **Study** (`live/s/W4-back-study`) |
| 7 | VX-342's word once on the Mac (the A12 warning) | **PROVEN** (18:18–18:20). Bookcase quick entry `{t:"u6b undo"}One two three four.` (System Events typed the quotes; the box showed them curly — `V342-entry`) ⏎ → **"u6b undo", in no book, "One two three four."** in Write (`V342-note` — the token parsed, the title set). A click past the line's end, ← ×11 by `keys.sh` (key code 123), ⏎ → **"One two" / "three four."** (the chip ON: a divide at the caret — `V342-divided`); a click at the first block's end, ` more` typed, 3.5 s → "One two more" (`V342-edited`); the Edit menu's items 3–4: **"Undo Divide" (enabled) · "Redo Structural Change"**. **⌥⌘Z → the A12 warning** (an AppKit `AXDialog`, 260×298 at (734,212); `V342-warning`, the text read by AX into `u6/V342-warning-text.txt`): **"Undo Divide?" over "One take has been edited since — undoing puts back the text as it was before the divide, so that writing is set aside. It is committed first, so you can bring it back from the take's history (⌘S's list) at any time."** — **"before" lowercase**, nothing shouted. **Cancel** (by name) → unchanged "One two more" / "three four." (`V342-cancelled`). With step 2–3's pins: VX-342 red-on-old, green-on-new and seen on the Mac |
| 8 | U6a's grant (Home · Edit · Always) + L0 · L1a · L1b · L2 · L3 · L4 · L5 | **DONE — L0 · L1a · L1b · L2 · L3 · L4 · L5 all PROVEN** (L4's receipt words by design, see below). **THE GRANT (18:20):** Shared with AI ▸ the sherlock row ▸ Change… → "Change access — claude-code · Confirming replaces the grant you opened this from." → A wing · **Home** · **Edit** · Always → "Grant edit in “Home” always, including notes added later" (`L-grant-sheet-open`, `L-grant-wing`, `L-grant-sheet-edit`) → **"Home · wing · claude-code · read, suggest, write new and edit · always"** in the sherlock row's place (`L-grant-row`); every Home book now wears the icon on the Bookcase. **L0 PROVEN** (18:21:21–18:21:54; `u6/L0.json`, the tee) — `tools/list` now **63 tools, `duplicate_note` listed** (the wing grant — step 5's note); `create_note` "u6a source" → keys `block_ids`, `blocks`, `note_id`, `tag_ids`, block 2's record `[{take_id}, {label "alt", take_id}]`; `apply_tag` u6a/demo ✔; `choose_take` (the "alt" take) `changed: true`; `create_note` "u6a stranger" ✔. `SOURCE_ID 5F849F14…`, `SOURCE_B1 137A55E3…` (b2 `6034B548…`, b3 `D1FDF6C2…`), `STRANGER_ID 7BCFF1A7…`, `STRANGER_B1 354E8323…`. **Her face:** ⌘K "u6a source" ⏎ → Write: first paragraph / **"The second paragraph, second take."** (⑂2) / third, wearing `demo` (u6a/demo's leaf), in no book (`L0-source`). **L1a PROVEN** (18:22:59–18:25:50; `u6/L1a.json`, the tee) — from the Bookcase, ONE turn: `duplicate_note(SOURCE_ID)` → **landed; keys `block_ids`, `blocks`, `landed`, `note_id`, `source_note_id`; `source_note_id` = SOURCE_ID; `landed` "the Pool of Home"; three records, `source_block_id` = the source's b1/b2/b3 in order; takes `[1, 2, 1]`, block 2's `[{take_id}, {label "alt", take_id}]` with `shown_take_id` = the SECOND (the chosen, carried)**; `read_note(copy, with_ids)` → every block_id, shown_take_id, take_id and label EQUAL (the runner's own comparison from the tee, and the client's). `COPY_ID 5E77F1F1…`, `COPY_B1_TAKE AE3DD18F…`. **Her face:** the receipt **"claude-code duplicated “u6a source” · ⌥⌘Z undoes Open ›"** (`L1a-receipt-window`); it FADED ~15 s after the act, before the runner's click (`L1a-receipt-preclick`), so the same show by **⌥⌘O "Show the AI's Last Change"** → **the COPY in Write**: "u6a source" stamped "edited today 6:23 PM" (the source's 6:21), the three paragraphs with "The second paragraph, second take.", `demo`, in no book (`L1a-copy-write`); Activity **"claude-code duplicated “u6a source”"** (with "claude-code read “u6a source”" above — `L1a-activity`); **the Pool: two "u6a source" rows**, 17 notes (`L1a-pool`). **Her undo from the Pool:** the Edit menu **"Undo claude-code's duplicate ⌥⌘Z" (enabled) · "Redo Structural Change"** (`L1a-edit-menu`, `u6/L1a-edit-menu.txt`) → ⌥⌘Z → **one "u6a source" left, 16 notes** (`L1a-undone`) → ⇧⌥⌘Z → the Bookcase bar **"Redid: claude-code's duplicate"** (`L1a-redone-bookcase-bar`). *Machinery note:* the Pool surface has no bottom bar, so the undo/redo receipts render nowhere there (the window's AX text holds no "Undid"); the pair was therefore run once more from the Bookcase (also no pane showing the copy): ⌥⌘Z → **"Undid: claude-code's duplicate"** (`L1a-undone-bookcase-bar`; the Edit menu then "Undo claude-code's note · Redo claude-code's duplicate") → ⇧⌥⌘Z → "Redid…" (`L1a-redone2-bookcase-bar`) → the Pool **two "u6a source" rows again, 17 notes** (`L1a-redone-pool`). The source never changed (L1b's read). **L1b PROVEN** (18:26:41–18:26:52; `u6/L1b.json`) — `edit_take(COPY_B1_TAKE, expected "The first paragraph of the source.", "The first paragraph, edited by the AI in the copy.")` → **`changed: true`**, `after_commit_id`, on the COPY's block `6B936850…` — the redo revived the SAME rows; `read_note`: the source's first block **"The first paragraph of the source."**, the copy's **"The first paragraph, edited by the AI in the copy."**. **Her face:** the receipt **"claude-code edited a take · ⌥⌘Z undoes Open ›"** (`L1b-receipt`). **L2 PROVEN** (18:27:50; `u6/L2.json`) — from the Bookcase, Variorum activated (frontmost pid 40633): `show_in_app(compare, SOURCE_ID, [COPY_ID])` → **`{"shown":true}`**. **Her face (`L2-study`):** the window in **Compare** (the mode row on Compare), **"u6a source · this note" first (stamped 6:21 — the source), the copy beside it, its relationship line "versions"** (unmark · diff · Open); the chip **"related blocks only: on"** (with "follow this note's order: on", "lineage colors: on"); **three rows aligned on lineage colour rails** (green · gold · pink); the copy's row 1 **"The first paragraph, edited by the AI in the copy."**, row 2 **"The second paragraph, second take."** in both columns; Activity **"claude-code showed you “u6a source”"** (`L2-activity`). **L3 PROVEN** (18:28:34; `u6/L3.json`) — L2's board still mounted (`L3-before`), Variorum activated: `show_in_app(compare, SOURCE_ID, [STRANGER_ID])` → `{"shown":true}`. **Her face (`L3-study`):** the copy's column **REPLACED by "u6a stranger" — ONE peer column**; its line **"there is no relationship here"** (mark as versions · diff · Open); the chip **"related blocks only: off"**; both notes whole, no rails, no honesty line — the mounted board's consumption on change. **L4 PROVEN, with two notes** (18:29–18:30; `u6/L4.json`) — the window moved off the board first by a `show_in_app(note, COPY_ID)` turn (`u6/L4-pre.json`; the copy in Write — `L4-before`); ONE turn `link_versions(SOURCE_ID, STRANGER_ID, [{SOURCE_B1, STRANGER_B1}])` → **EXACTLY the expected shape** `{"links":[{"block_a":"137A55E3…","block_b":"354E8323…","edge_id":"88C7DD36…"}],"note_a":"5F849F14…","note_b":"7BCFF1A7…"}`. **The receipt (`L4-receipt`) read "claude-code made a change · ⌥⌘Z undoes Open ›", NOT the plan's "claude-code linked “u6a source” and “u6a stranger” as versions · ⌥⌘Z undoes" — BY DESIGN, not a red:** that line is **75 characters**, past the bar's quiet-slot budget of 72 (`MCPPaneCopy.budget`, VX-184 U2's W-2: "past the budget the run speaks as a count"; 13n-c U6's D-U6-1: one act is "a change"), so the plan's expected words were a premise these fixture titles cannot meet (a face note for VX-234: a two-title link receipt reaches the budget at short titles). The receipt faded ~13 s after the act, before the runner's click; **the same show by ⌥⌘O → Compare A|B (`L4-compare`): "u6a source" first, "u6a stranger" beside it, the line "versions · no shared lineage — loose alignment", the chip "related blocks only: off", the stranger's column offering "unmark"** (and diff · Open). **L5 PROVEN** (18:30:56; `u6/L5.json`) — `Finder` activated (frontmost read back: Finder, before and after the turn); `show_in_app(compare, SOURCE_ID, [COPY_ID])` → **`isError: true`, EXACTLY "The author isn't at Variorum right now, so nothing was moved — showing happens only while Variorum is the app in front. Ask them to switch to it, then call again."**; Variorum re-activated → the window still on **source | stranger** ("versions · no shared lineage — loose alignment") — nothing moved, nothing waiting to move (`L5-while-away`, `L5-unmoved`) |
| 9 | U6a's Terminal pass (L2, L3) → back to Study | **PROVEN** (18:31–18:33; captures `live/t/`) — Settings ▸ General ▸ Theme ▸ **Terminal** (`T-theme-terminal`); the Bookcase in Terminal (`T-bookcase`); Variorum activated. **L2's turn again** (`u6/L2-terminal.json`) → `{"shown":true}` → **Compare in Terminal: "u6a source · this note" | the copy "versions", "related blocks only: on", three rows aligned on the lineage rails, the copy's row 1 the AI's edit, row 2 the second take in both** (`L2-terminal`). **L3's turn on the mounted board** (`u6/L3-terminal.json`) → `{"shown":true}` → **the copy's column REPLACED by "u6a stranger" (one peer column), "related blocks only: off", both whole, no rails** (`L3-terminal`); its relationship line now reads "versions · no shared lineage — loose alignment" (L4 linked these two before this pass — the plan's "there is no relationship here" is L3's face before L4, seen at step 8). Theme back to **Study** (`T-back-study-settings`, `T-back-study`) |
| 10 | cleanup → cmp SAME vs A1, prefs 0 differ, fingerprint SAME, 0 sims booted, instances quit by their own menu | DONE (18:33–18:35) — **the Debug app quit BY BUNDLE ID** (`tell application id "io.lduarte.Variorum.debug" to quit`; both strict guards and the loose form empty, no `variorum-mcp` shim; her `/Applications` app never running). **The one window key** (`vmk2_clau…`) searched WHOLE in `vx336-screens/u6/`, `~/.claude.json`, the scratch project's transcripts, `notes/` and the scratchpad outside the key folder → **0 files**; the tee logs (no key — checked) kept as evidence in `u6/tee/` (24 files); then the key, the copied text and the scratch `u6-mcp.json` DELETED; **the clipboard restored** (`pbpaste \| cmp - clip-before.txt` SAME — 0 bytes before and after). **No `-s local` registration was ever made** (`claude mcp get variorum-dev` in the scratch project → "No MCP server named \"variorum-dev\"…"). *Said honestly:* the runner also ran `claude mcp list` there, whose health check briefly spawned her user-scope `variorum` shim (`/Applications/Variorum.app/…/variorum-mcp`), which failed to connect ("Variorum must be open…" — her app not running) and exited; no registration changed, no shim lingered, her app never ran. **Her user-scope servers AFTER `['linear-server', 'variorum']`, `bc64543e2f4e8e58` — SAME** (`u6/userscope-post.txt`). **Prefs:** the window added 4 keys (`currentBlock.<id>` ×3, `postMode.<id>`) and changed 7 (`IdleCommitSweepMark.Variorum-dev`, the Settings window frame, `currentBlock`/`postMode` of one note, `openNotes.remembered.ids`/`.recency`, `variorum.backup.log`) → `defaults import prefs-pre.plist` + `defaults delete` of the 4 → re-export **1,602 keys, 0 added · 0 removed · 0 changed** (`u6/prefs-post.plist`). **The dev store:** `restore.sh …/scale-prestage-20261015T000711Z` → **"Restored (verified)"** (`u6/logs/restore.log`), a second `cmp` of all five files **SAME**, the sha256 set **EQUAL** to the A1 copy's (`store-hash-restored.txt` = `store-hash-pre.txt`) — Standard, unlocked, Study, claude-code's pre-window binding and grants back with it (the sherlock grant, the Home edit grant, the fixture notes, the copy, the link, "u6b undo" all gone with the window). `Backups/` **unchanged** (57 entries); `castle-W1-20261013` untouched. **0 simulators booted.** No stray `default.profraw`; the tree clean; 64 GiB free |
| 11 | release + THE RESULT LINE | DONE — **RELEASED 18:35:06 MDT** (`Tools/stage release --who vx336-u6` → STAGE RELEASED; `status` → STAGE FREE), ~42 of the 130 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx336-u6` 17:52:45–18:35:06 MDT, RELEASED (~42 of 130 min); the batch and reds first, the SEAM, then the coordinator's "continue".
- **The Mac batch (125 suites, `vx336-u6`):** 790 tests — 786 passed · 2 failed · 2 gated capture skips; the two reds are EXACTLY the plan's named standing reds, neither U6's: VX-115's `BookCollectingDoorsTests.theSettingsDoorIsOneActOnBothRoads` and VX-167's `DestructiveUndoWarningTests.redoNeverAsks` (red with its suite alone too; **green as a single test alone, 0.078 s** — VX-167's shared-process dependence, a data point for that ticket). The pins green: `MCPCompareLandingTests` 7/7 · `BookPanelMCPMarksTests` 3/3 · `UndoWarningWordsTests` 1/1.
- **The red runs, all EXACT:** U6a's on `vx336-u6-red` — 7 tests · 2 failed · 9 issues (the nine pairs); U6b's Mac on `vx336-u6b-red` — 4 · 4 failed · 15 issues (the fifteen pairs); the phone red on `vx336-u6b-ios-red` (iPhone 17 Pro, iOS 26.2) — 1 · 1 failed · 4 issues. **The phone green:** 18 tests in 3 suites, one launch, no restart. The three red products deleted at the coordinator's ask.
- **VX-330's walk PROVEN in both voices** (W0–W4): every collapsed one-note chapter row in sherlock's Book Panel wears the shared icon (twelve of them; the plain "about this text" heading bare over its marked note row); the icon's popover opens without opening the row; the waiting mark sits after the icon on the asked story ("The Red-Headed League"); her press on it opens THE ask's sheet; Don't allow clears the mark, the icon stays.
- **VX-342's word seen on the Mac:** "…puts back the text as it was before the divide, so that writing is set aside. It is committed first, …"; Cancel changed nothing.
- **U6a's legs:** **L0 PROVEN · L1a PROVEN** (`duplicate_note` lands in "the Pool of Home", `source_block_id` per record, its `blocks` equal `read_note`'s; her ⌥⌘Z "Undid: claude-code's duplicate" / ⇧⌥⌘Z "Redid…") · **L1b PROVEN** (the AI's edit lands on the copy's same rows; the source untouched) · **L2 PROVEN** (Compare from a fresh mount: "versions", related-only ON, three aligned rows) · **L3 PROVEN** (the stranger REPLACES the column on the mounted board: "there is no relationship here", related-only OFF) · **L4 PROVEN** (the link's exact answer; its show opens Compare A|B "versions · no shared lineage — loose alignment", related-only OFF, "unmark"; the receipt said "claude-code made a change · ⌥⌘Z undoes Open ›" — the plan's 75-character line past the bar's 72-character budget, BY DESIGN) · **L5 PROVEN** (the exact not-frontmost sentence; nothing moved) · **the Terminal pass PROVEN** (L2 and L3 again).
- **Posture:** dev store cmp-SAME vs A1 (sha256 set equal), prefs 0 differ (1,602 keys), user-scope fingerprint SAME (`bc64543e2f4e8e58`), 0 simulators booted, Standard/unlocked, castle-W1 untouched, no `-s local` registration, the whole-key grep 0, the clipboard as before, no instance left.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T000711Z`.

**Noticed, not fixed (no product change under the claim):** (1) **L4's receipt words** — "claude-code linked “u6a source” and “u6a stranger” as versions · ⌥⌘Z undoes" is 75 characters, so the bar speaks the designed fallback "made a change" (`MCPPaneCopy.budget` 72); a two-title link receipt reaches the budget even at short titles — for VX-234's eye; (2) **the Pool surface has no bottom bar**, so a receipt spoken there (her ⌥⌘Z/⇧⌥⌘Z of the duplicate) renders nowhere until she reaches a surface with the bar — the plan expected "Undid…" in the Pool; seen instead from the Bookcase; (3) **receipts fade in ~13–15 s**, before a runner's capture-read-click loop — both Open › presses went through ⌥⌘O, the plan's named same show; (4) in **Study the open story's collapsed Book Panel row wears no visible open-note marker** (Terminal shows "›") — not VX-330's (glyphs only), observed; (5) **VX-167's `redoNeverAsks` reds at SUITE scope too** (alone it passes) — a data point for VX-167; (6) machinery: a `while read` over a list without a trailing newline skips its last line (one prefs key needed a second delete); `claude mcp list`'s health check spawns every registered server's command, her user-scope shim included — use `claude mcp get <name>` alone in later windows.

### THE ORCHESTRATOR ON U6's WINDOW (2026-10-14 ~18:45 MDT)

- **Verified, not trusted:**
  - the stage reads FREE;
  - no Variorum instance, and 0 simulators booted;
  - her user-scope fingerprint is SAME (`bc64543e2f4e8e58`), re-read by the orchestrator;
  - the tree is clean at `0c6e7f50`.
  - The orchestrator viewed four captures: sherlock's Book Panel in Study with every collapsed row's shared icon and the
    waiting mark on "The Red-Headed League"; the same in Terminal; L2's Compare, with the source and its duplicate aligned
    on lineage rails and the AI's edit in the copy; VX-342's warning reading "…as it was before the divide…".
- **U6 is PROVEN.** VX-311, VX-298, VX-330 and VX-342 close at the merge.
- **The two standing reds:**
  - VX-115 is unchanged.
  - VX-167 (`redoNeverAsks`, divide → edit → undo → redo) stayed red with its suite run alone, but passed as a single test. The
    orchestrator read its body: it walks the divide ops, `UndoStack` and `structuralRedo`, none of which this branch
    changes. The data point is now on VX-167.
- **The runner's notes:**
  1. `link_versions`' receipt line falls back to a count past the bar's 72-character budget (by design) → FOR VX-234.
  2. The Pool shows no receipts → VX-355.
  3. Receipts fade in ~13–15 s; the plan's ⌥⌘O road was used.
  4. The Study open-note marker on the collapsed row → VX-356 (Suspected).
  5. The `claude mcp list` slip: nothing changed, the fingerprint is SAME. It is now a Hard rule.
  6. Another app's banner, which was not Variorum's.
- **Disk:** `vx336-u6` and `vx336-u6b-ios` are deleted (U7 builds its own); the red products went at the coordinator's
  ask.
- **Next: U7** (VX-254 digests · VX-256 paged `read_note` · VX-261 the client's own recent acts), in U5b's and U6a's
  shape: ONE design session for all three members (narrow reading; its forks ruled by the orchestrator), then fresh
  builders, then a runner.


## U7 UNIT RECORD — the agent's read-backs: VX-254 · VX-256 · VX-261 (design)

*(opus-implementer as DESIGNER, piece 0 only, from 2026-10-14 ~19:00 MDT; HEAD at start `5c48547f`.)*

**NOT DONE here (said first):** no product code, no pins, no test run, no stage. Every build piece below is NOT-STARTED
and waits for the orchestrator's rulings on THE FORKS. No subagent was spawned, so one external fact is UNVERIFIED and
marked so: Claude Code's MCP tool-output cap (recalled as 25,000 tokens by default, `MAX_MCP_OUTPUT_TOKENS`; past it the
reply lands in a file — the bilingual-book notes saw that at 100–133k characters). The live round measures it. The
designer stopped at ~370k context, past the 350k line; the design is complete for all three members, and what remains
is in OWED.

### LIVE STATUS — U7's pieces

**BUILDER A** (opus-implementer, from 2026-10-14 ~19:30 MDT; HEAD at start `e9ac7005`): VX-254 (pieces 1a–3) then
VX-261 (piece 4), under THE ORCHESTRATOR'S RULINGS ON U7's FORKS (F-254-2 (b): divide/merge answer NO digest; P-VX261-5
(b): the F7 row omits `target_*`; the U+0000 CHECK). Builder A's own record is the section **BUILDER A's RECORD** at
the end of this U7 section. Claims stay PENDING until read from a log.

| piece | status |
|---|---|
| 0 — traces, design, forks (this section) | DONE (`01860640`) |
| 1a — VX-254: `MCPTextDigest` (its own commit — builder B calls it) + P-254-1 | DONE (this commit): red by absence (`cannot find 'MCPTextDigest' in scope`), then 4/4 green |
| 1b — VX-254: `MintedTake.text` + the encoder's `sha256` | DONE (this commit) — BUILDER A's RECORD |
| 2 — VX-254: the flat answers (`add_take`, `add_takes`' `takes[]`, `edit_take`, `restore_commit`); `divide_block`/`merge_blocks` answer NO digest (F-254-2 (b), ruled) | DONE (this commit): P-254-2…10 red-on-old (9 failed, 50 issues) then 10/10 green |
| 3 — VX-254: descriptions, pins red by absence, revert run, the U+0000 CHECK | DONE (this commit): descriptions `5852e474`; the U+0000 CHECK FOUND truncation (BUILDER A's RECORD); the whole MCP suite 293/61 green (1 known issue) + the touched core suites 171/42 green; THE REVERT RUN (announced `badcf3b7`): the eight product files back to `54cc62a5` → `MCPWriteDigestServerTests` 10 of 11 FAILED, 52 issues (the guard green); restored by `git checkout HEAD -- Sources` (status clean) → 15/15 green in both digest suites (1 known issue). No revert in flight. |
| 4 — VX-261: `list_my_activity` (query, catalog listing rule, handler, Activity words, pins) | DONE (`c22a57d2` + this commit): 11 pins red by absence (11 failed, 24 issues) then green; PROVISIONAL P-VX261-6 built; THE REVERT RUN (announced `fdd82382`): arm (a) the product back to `b0175aeb` → 11 of 11 failed, 24 issues; arm (b) `hidesTarget` forced false → exactly the two hidden-target pins failed (7 issues), nine green; restored (status clean) → 35/35 green (`MCPOwnActivityServerTests`, `MCPServerTests`, `MCPWriteServerTests`). No revert in flight. The Mac pin's run is THE WINDOW's (PENDING). The headless finals GREEN (core 2,871/333 · MCP 304/62, 1 known issue · workbook 40/6) and `build-for-testing` SUCCEEDED into `vx336-u7a` (BUILDER A's RECORD). **BUILDER A STOPPED at this seam; builder B (VX-256 + THE STAGE WINDOW) is next.** |
| 5 — VX-256: `read_note` paging + `ids_only` (pins, revert) | DONE — **BUILDER B** (opus-implementer, from 2026-10-14 ~20:00 MDT; HEAD at start `b5d838e1`). The build plan is BUILDER B's RECORD (end of this U7 section). **The wire pins** (`52b2e246`) RED on `b5d838e1`'s sources: 14 tests, 12 failed (22 issues), the two GUARDS green by design. **The product landed (this commit):** `MCPReadTools.readNote`'s parse and cursor check, `MCPNoteStructure`'s page (`pageSQL`, the budget walk, `NotePageCursor`, `ids_only`), `Queries.effectiveLensSelection(_:lens:blocks:)`, the catalog's words and inputs → the 14 pins GREEN (`cbdf0002`). **The plan pin** (`d2897dd8`) 2/2 green. **The whole MCP target GREEN:** 320 tests / 65 suites, 1 known issue (VX-357's U+0000 pin), no existing pin edited. **THE REVERT RUN — DONE** (announced `5df458b9`; three arms, each read from its own run's output, each restored by `git checkout HEAD -- Sources Tests`, status clean): see THE REVERT RUN in BUILDER B's RECORD. **No revert in flight.** Next: piece 6 |
| 6 — THE STAGE WINDOW plan (claim `vx336-u7`), headless + Mac build-for-testing, READY | **READY** — the headless finals green (`cfda547a`: MCP 321/65, 1 known issue · core 2,871/333 · workbook 40/6); `build-for-testing` of `cfda547a`'s sources into `vx336-u7` SUCCEEDED (`vx336-u7a` deleted — one product); the kit (`ba220af6`, tested headlessly) and its prompts; THE STAGE WINDOW written (BUILDER B's RECORD). The Mac batch, builder A's Mac pin and the live round are the window's — PENDING. **Builder B stopped here (READY), past ~400k context.** |

### The traces (read in this session; file:line at `5c48547f`)

**T-254 — what a write answers today.** No answer carries anything that proves the stored bytes.
- **Records:** `create_note`, `import_document` (one document), `insert_blocks` and `duplicate_note` answer U5b's D1
  records through ONE encoder, `MCPMintedBlocks.records` (`MCPMintedBlocks.swift:26–41`). It is fed by
  `Operations.MintedBlockTakes` / `MintedTake {id, label}` (`Operations+DocumentImport.swift:71–101`). Those are built from
  the mint's own `Variant` rows (`:83–87`, `Operations+Versions.swift:836–838`), which hold `workingText`, so a digest
  needs no second read.
- **Flat answers:**
  - `add_take` answers `{take_id, block_id, note_id}` (`MCPWriteTools.swift:402–410`; the op returns the `Variant`,
    `Operations+MCPWrites.swift:147–186`, its text stored verbatim);
  - `add_takes` answers `{note_id, take_ids}` (`MCPWriteTools+Batches.swift:154–161`, the ops return `[Variant]`);
  - `edit_take` answers `{take_id, block_id, note_id, changed, before/after_commit_id}`
    (`MCPWriteTools+Edit.swift:159–176`; `MCPTakeEdit.take` is the post-edit `Variant`, `Operations+MCPEdits.swift:38–48`);
  - `restore_commit` answers likewise (`MCPWriteTools+NoteEdits.swift:286–304`; `MCPCommitRestore.take`, `:370–379`).
- **Block ids only, no take ids at all:**
  - `divide_block` (`MCPWriteTools+Edit.swift:178–195`);
  - `merge_blocks` (`:197–206`).
- **Facts the digest rule must state:**
  - **The plain-prose payload is segmented by her setting.** `create_note`'s `text` goes through
    `SegmentationRules.bulkSegments(text, mode: defaultSegmentation)` (`Operations+MCPWrites.swift:438–440`), so its blocks
    are the library's segments, not the client's lines.
  - **The file doors drop blank takes** (`Operations+DocumentImport.swift:255`).
  - **A divided half is seam-trimmed.** `BoundarySnapping.seamTrimmedHalves` (`BoundarySnapping.swift:214–233`) trims
    whitespace at the cut and re-adds newlines by a rule, so a client cannot reproduce a half's bytes. A merge's join IS
    reproducible (`a + "\n" + b`, R-13u4-3).
  - **The store's own hashes are domain-separated:** `MCPCommentWords.digest` (`MCPCommentWords.swift:21–24`) and
    `MCPSetupKeyRule.hash` (`MCPSetupKeyRule.swift:128–131`). A plain SHA-256 on the wire therefore never equals, or
    reveals, either.

**T-256 — why ids-only alone cannot fix it.**
- **How the read works now:** `read_note` with ids is ONE write transaction (`MCPReadTools.swift:114`, the once stamp
  atomic with the read, `:150`). It builds the WHOLE note (`MCPNoteStructure.read`, `:88–227`): every placement (`:94–102`),
  every take's text (`:106–117`), comments, carriage. Nothing bounds it, so it is ∝ the note.
- **Measured on her 253-block, two-take chapter (encoded the way `encode` sorts its keys):** a block's ids and keys are
  ≈ 280 characters, and its two texts ≈ 250 (≈ 64k of text / 253).
  - The full form: ≈ 134k, matching her 100–133k.
  - An ids-only WHOLE note: ≈ 71k — ids are half the answer for short paragraphs. With a 64-hex digest per take it is
    ≈ 109k.
  - A 1,000-block note is ≈ 280k ids-only.
- **So an ids-only form shrinks a note but never bounds it.** Only a PAGE is bounded.
- **Two smaller facts:**
  - The keyset is index-served: `idx_cblock_order(container_id, position)` (AppSpec §7; the read's own `ORDER BY
    cb.position, cb.id`).
  - Lens picks are index-served per block: `uq_lens_choice_live(lens_id, block_id)` (`Migrations.swift:227`).
    `effectiveLensSelection` reads a lens's picks whole (`LensQueries.swift:47–65`).
- **Two precedents:** `list_notes`' opaque keyset cursor and its stale-cursor sentence (`MCPReadTools.swift:43–45,
  838–878`), and AF-10 (d)'s bounded commit-text budget (`MCPNoteStructure.swift:494–533`).

**T-261 — what the activity log holds.**
- **Shape:** `mcp_activity(id INTEGER PK, client_name, act, target_kind, target_id, target_title, outcome, at)`
  (`MCPGrantSchema.swift:140–149`). It has no index but the PK and is capped at 500 rows across ALL clients
  (`Operations+MCPGrants.swift:43, 350–365`). The reader is `Queries.mcpActivity` (`MCPGrantQueries.swift:375–385`).
- **Who writes it:** `MCPWriteTools.log`/`land` (`MCPWriteTools.swift:707–731, 852–860`), the reads' `log`/`logAfter`
  (`MCPReadTools.swift:751–769`), `MCPShowTool` (`:116–128`) and the connection doors (`Operations+MCPSetupKeys.swift:103–214`).

**Seven findings:**
- **F1 — a REFUSED row records the real title of a target that exists.** `onNote` computes the title whenever the note
  exists (`MCPWriteTools.swift:571–578`; reads `MCPReadTools.swift:118–120`; `noteIntoBook`, `into` and `inWing` alike),
  so a refused row's title is that of a note the client was told is not shared. Answered as is, it would be an oracle
  twice over: the title, and title-present-versus-absent (hidden versus missing).
- **F2 — connection-admission rows sit under the client's NAME** (`connect_*`). They include a stranger's refused
  presentation under that name. `connect_rebound` and `connect_rebind_allowed` carry a REPLACED key's hash as `target_id`
  (`MCPSetupKeyRule.swift:270–290`). None is a tool act.
- **F3 — a creating act records the PLACE, not what it made.**
  - `create_note` and `import_document` record kind `book`/`wing` with the place's id (`into`/`inWing`,
    `MCPWriteTools.swift:648–697`), titled with the MADE note's title (`land`'s `logsReceiptTitle`, `:717`).
  - `create_book` records the wing, `create_section` the book, `save_version` the note, and `duplicate_note` the SOURCE
    (`logsReceiptTitle: false`, `MCPWriteTools+DuplicateNote.swift:85`).
  - No row holds a minted id.
- **F4 — the pane coalesces on (client, act, target_kind, target_id, allowed)** (`MCPPaneCopy.swift:1487–1500`). That
  is why 25 `create_note`s into one book read "made 25 notes". Changing what a creating act records changes her face.
- **F5 — some connections log nothing, others log refused rows.** A waiting setup's calls hear the pending sentence and
  log nothing (`MCPSession.swift`, `waitingAnswer` and the `CallTool` handler). A pending client's calls log refused
  rows under its name.
- **F6 — approval and Deny.** `decided_at` is stamped only on the move to approved (`Operations+MCPGrants.swift:101–105`).
  Deny revokes every grant and releases the key (`:125–144`).
- **F7 — one row records an id the client did not send:** `duplicate_note`'s wing-side refusal records the source's
  resolved wing (`MCPWriteTools+DuplicateNote.swift:79`). It is readable to that client at that moment, because its read
  on the note had just been allowed and `list_notes` shows `wing_id`.

**Every other row's id is an argument the client sent.**
- It is `note_id`, `block_id`, `take_id`, `commit_id`, `comment_id`, `lens_id`, `book_id` or `wing_id`, through
  `onNote`'s `logged:` (`+Edit :162`, `+NoteEdits :163–344`, `+Deliberate :73–104`, `+Carriage :125/160`,
  `+CommentDelete :53`).
- Every ALLOWED row's title is one the client could read at act time. Rungs are cumulative, and every write is decided at
  or above read on the logged target. The two-sided acts decide both sides (`noteIntoBook`, `+WingMove`,
  `+LinkVersions`, `+DuplicateNote`).

### VX-254 — content digests on write replies

**D-254-1 — THE DIGEST.**
- **Key and value:** a take's `sha256` is the SHA-256 of the take's STORED text, as its UTF-8 bytes, in lowercase hex
  (64 characters).
  - No Unicode normalization: NFC "é" and NFD "é" digest differently.
  - No trimming, no newline conversion, and no domain prefix. That is deliberate: a client computes it with any stock tool
    (`shasum -a 256`, `hashlib.sha256(s.encode()).hexdigest()`), unlike the store's own domain-separated hashes (T-254).
- **The empty take** digests to `e3b0c442…b855` (SHA-256 of nothing), so a blank take is answered and recognizable.
- **One home:** `Sources/VariorumMCP/MCPTextDigest.swift` holds `static func sha256(_ text: String) -> String` (CryptoKit,
  `Data(text.utf8)`). It is the wire's only digest function; the encoder, the flat answers and VX-256's `ids_only` all
  call it.
- **"Stored" means the text the act WROTE** — the value it bound, read from the op's returned rows, never a second read
  (D1's rule: no race, ∝ the write). OWED 2 pins that this equals what a read returns.

**D-254-2 — WHERE IT RIDES.**
- **The encoder (one change for every record answer):**
  - `Operations.MintedTake` gains `text: String`, the minted row's `workingText`. Its three constructions pass `$0.workingText`:
    `Operations+DocumentImport.swift:86` and `Operations+Versions.swift:838`, plus `MCPInsertBlocks` through `:83–87`.
  - `MCPMintedBlocks.records` emits `"sha256": MCPTextDigest.sha256(take.text)` on EVERY take object.
  - So the take object becomes `{take_id, label?, sha256}`. `create_note`, `import_document` (one document), `insert_blocks`
    and `duplicate_note` all carry it with no per-tool code.
  - Text never rides the wire answer; the core value holds it only to hash.
- **The flat answers each gain ONE key, `sha256`, computed from the returned row:**
  - `add_take` → `take.workingText`;
  - `edit_take` → `edit.take.workingText`. On `changed: false` it is the digest of the current text, which equals the
    text sent;
  - `restore_commit` → `result.take.workingText`, which equals the commit's text.
- **`add_takes`** gains `takes: [{take_id, block_id, label?, sha256}]` in the items' order (F-254-5). D1's take object plus
  its block; `label` is the label as STORED, the `aiLabel` form. `take_ids` stays beside it, byte-unchanged (F-6's
  compatibility ruling).
- **`divide_block` / `merge_blocks`** answer per F-254-2.

**D-254-3 — THE SWEEP TABLE** (every catalog tool; "writes take text" = writes a variant's `working_text`).

| tool | writes take text? | digest answered / why not |
|---|---|---|
| `create_note` | yes (each block's take 0 and its takes) | **yes**, the encoder. `blocks` verifies byte-for-byte; `text` is split by her segmentation setting, so the description says to verify by `blocks` |
| `import_document`, one document | yes | **yes**, the encoder (minted takes only; the format drops blank takes) |
| `import_document`, book form | yes | **no** (F-254-4 (a)): P-VX252-1 ruled this answer stays `book_id, note_ids, chapter_ids` because a per-take list is ∝ the whole book (her bilingual book ≈ 7,700 takes ≈ 0.6M characters with digests). Verify each note by VX-256's `ids_only` pages |
| `insert_blocks` | yes | **yes**, the encoder |
| `duplicate_note` | yes (byte copies of the ACTIVE takes; archived copies ride unlisted, P-VX311-3) | **yes**, the encoder. A copy's digest equals its source take's, so a client checks the copy against what it read |
| `add_take` | yes | **yes**, flat `sha256` |
| `add_takes` | yes | **yes**, `takes[]` objects (F-254-5) |
| `edit_take` | yes | **yes**, flat `sha256` |
| `restore_commit` | yes (the commit's text into the take) | **yes**, flat `sha256` (equals the commit's text, which the client may read `with_commits`) |
| `divide_block` | yes (the cut halves) | **F-254-2 (a): yes**, `blocks` records for the two resulting blocks. The halves are seam-trimmed, so their digests say what was stored, and the records end the read-again a divide forces today |
| `merge_blocks` | yes (the joined take; carried takes are byte copies) | **F-254-2 (a): yes**, `blocks` records for the merged block. The join is reproducible: sha256(a + "\n" + b) |
| `save_version` | yes (a full family copy, sealed + archived) | **no** (F-254-3 (a)): its takes are a sealed moment no write can address; the answer is one id; digests would grow it ∝ the note. `read_note(version_id, ids_only)` pages give every one |
| `lock_take` | no (its insurance commit copies the text; a commit is not a take) | no, writes no take text |
| `save_commit` | no (a commit) | no, writes no take text; the commit holds the take's current text, which `ids_only` digests |
| `put_back` | no (a tombstone flip; the take returns as it was) | no, writes no take text |
| `choose_take` · `adopt_lens` · `archive_take` · `unarchive_take` · `delete_take` · `set_take_label` · `unlock_take` | no (pointers, statuses, labels) | no, writes no take text |
| `delete_block` · `move_block` · `set_block_name` · `move_note_to_wing` | no | no, writes no take text |
| comments: `add_comment(s)` · `edit_comment` · `restore_comment` · `delete_comment` | comment text, not a take's | no; outside the class (a take's text). VX-260's comment digest is a different, domain-separated, local record |
| notes/books/chapters/tags/lenses/rules: `rename_note` · `set_entry_date` · `delete/archive/unarchive_note` · `create_book` · `create_section` · `add_note_to_book` · `file_note_in_chapter` · `set_book_rule` · `apply_tag` · `remove_tag` · `link_versions` · `save_lens` · `delete_lens` · `rename_commit` · every book act · every chapter act | no | no, writes no take text |
| the reads (`list_books` · `list_notes` · `read_note` · `search` · `export_note` · `show_in_app`) | no | n/a; `read_note`'s `ids_only` carries `sha256` (VX-256) |

**D-254-4 — COST AND THE ORACLE.**
- **Cost:** one SHA-256 pass per take the act wrote, over bytes the act already holds in memory. That is ∝ the write
  (∝ the copied note for `duplicate_note`, an act ∝ the note already). No query is added.
- **The oracle:** a digest is a function of text the caller may already read, so it adds no reach. Case by case:
  - every client-sent write (`create`, `import`, `insert`, `add`, `edit`) digests the caller's own words;
  - `duplicate_note` needs read on the source;
  - `divide`, `merge` and `restore_commit` need edit on the note (cumulative, so ≥ read).
- **No digest of a take the caller cannot read appears anywhere.** The encoder lists only active copies (P-VX311-3), and
  every answer is behind the act's decided reach. The plain wire hash cannot collide with or reveal the store's
  domain-separated hashes.

**D-254-5 — flush and undo.**
- **No act changes.** The answer's contents don't change whether the act meets her text, so every
  `flushesHerEditorFirst` answer stands as built:
  - `edit_take`, `restore_commit`, `divide`, `merge`, `duplicate_note`: true;
  - `add_take(s)`, `create_note`, `import_document`, `insert_blocks`: false.
  For the true ones, the digest is of what the act wrote AFTER her flush landed.
- **No undo registration changes.**

**D-254-6 — THE PINS** (wire, `ServerHarness`; each red by absence on the old tree, red again by revert).
- **The digest definition — P-254-1:**
  - `MCPTextDigest.sha256("")` = e3b0…b855, and `"abc"` = ba7816bf…15ad;
  - NFC "é" ≠ NFD "é";
  - "beliscou" ≠ "beliscáu";
  - each value equals `shasum -a 256` of the same bytes (vectors computed by the builder, quoted in the test).
- **The record answers:**
  - **P-254-2 — `create_note` (blocks):** every take object's `sha256` = the digest of the text SENT (curly quotes, em
    dash, an embedded newline, a trailing space, an emoji, an NFD é, a blank take). Each also equals the digest of
    `read_note(with_ids)`'s text for that `take_id`.
  - **P-254-3 — `create_note` (text):** each record's digest = the digest of `read_note`'s text.
  - **P-254-4:** the same for `import_document`, one document.
  - **P-254-5:** the same for `insert_blocks`.
  - **P-254-6 — `duplicate_note`:** each copy take's `sha256` = the digest of its SOURCE take's text (matched through
    `source_block_id`).
- **The flat answers:**
  - **P-254-7 — `add_take`:** `sha256` = the digest of the sent text; a blank take gives e3b0….
  - **P-254-8 — `add_takes`:** `takes[i]` = `{take_id: take_ids[i], block_id: items[i].block_id, sha256}`, with
    `take_ids` byte-unchanged.
  - **P-254-9 — `edit_take`:** the new text's digest; on `changed: false`, the current text's.
  - **P-254-10 — `restore_commit`:** `sha256` = the digest of the commit's text.
- **P-254-11 (only if F-254-2 (a)):**
  - `divide_block`'s `blocks`: both resulting blocks, every active take, digests equal to `read_note`'s texts after the
    divide (a single-take divide and a fanned keep-on-top divide);
  - `merge_blocks`' record: the joined take's digest = sha256(a + "\n" + b), and a carried take's = its source's.
- **GUARDS (green on both sides, by design — not red pins):**
  - G-254-1: the book form's answer is byte-unchanged (no `sha256`);
  - G-254-2: every existing answer key is unchanged. `MCPMintedAnswerServerTests` projects records (`BlockRecord`), so it
    stays green unedited. Any pin found comparing a whole answer string is a named, justified edit.

### VX-256 — a compact / paged `read_note`

**D-256-1 — WHICH: BOTH, with paging the load-bearing half** (F-256-1 (a)).
- **Ids-only alone fails the ticket's "any client reads a big note in pieces"** (T-256). Her chapter's ids alone are
  ≈ 71k characters, and any note a few times larger is past any cap.
- **Paging alone meets the ticket.**
- **`ids_only` with digests is the cheap verification read.** It covers what no write reply digests:
  - a book-form import (F-254-4);
  - a `save_version` (F-254-3);
  - a note after a dropped call;
  - her own note.
  It halves the pages a structural read needs, and a client compares a whole note to its source without pulling text.
- **Both are explicit asks, never ambient.**

**D-256-2 — THE PARAMETERS** (`read_note` only; `export_note` untouched).
- **`limit`** (integer 1–200): blocks per page. **`cursor`** (string): the previous page's `next_cursor`. Passing either
  asks for pages: it implies `with_ids`, as `with_commits` does. With `cursor` alone the limit defaults to 50
  (`list_notes`' default and maximum; the names are `list_notes`').
- **The page ends at the FIRST of:**
  - `limit` blocks;
  - a take-text budget of **32,000 characters** (F-256-2 (a), PROVISIONAL), counted over the page's takes' text and,
    under `with_commits`, its commits' text.
  A page always holds at least one whole block, so a single block bigger than the budget is a page of its own. The
  budget never applies without `limit`/`cursor`, which keeps the unpaged form byte-unchanged.
- **`ids_only`** (boolean, implies `with_ids`, combines with paging or not): every TAKE entry drops `text` and carries
  `sha256` (D-254-1) instead.
  - Everything else is unchanged: comments keep their text, and so do explicit asks (`with_commits`, lineage's released
    originals, the tray).
  - The budget then counts only commit or tray text, so `limit` governs.
  - The description says ids_only is cap-safe only paged: a whole note ids-only is ≈ 109k for her chapter.

**D-256-3 — THE ANSWER: the `with_ids` object, per page.**
- **Every page** carries the note's header (`note_id`, `title`, `entry_date`, `books`, the `lens_id` / `version_id`
  echoes — ∝ 1 and the note's memberships) and THIS page's `blocks`, each exactly as the unpaged form says it.
- **`next_cursor`** comes back only while blocks remain. Its absence is the end.
- **The first page** (no cursor) adds `block_count`, the note's live blocks now (F-256-5 (a)).
- **The cursor** is opaque and new: base64 of `n\n<container id>\n<position>\n<placement id>`. It keys on the
  placement's `(position, id)`, the read's own order, and names the note or version it pages.
- **It resumes only that container.** An undecodable cursor, `list_notes`' shapes, or another note's cursor all answer
  `MCPReadTools.staleCursorMessage`.

**D-256-4 — THE INTERPLAY.**
- **`with_ids`:** implied by paging and by `ids_only`.
- **`lens_id`:** every page reads through the lens. Per block the pick comes from `lens_choice` on THAT block, served by
  `uq_lens_choice_live` and ∝ the page; the builder adds a page-scoped variant of `effectiveLensSelection`. `via` and
  `shown_take_id` are as unpaged.
- **`include_archived`:** archived takes join each paged block's takes, as unpaged.
- **`with_lineage`:** the page's blocks' edges and parents (the queries already take the block ids).
- **`with_commits`:** the page's takes' commits, under the PAGE budget (past it `text_omitted`, AF-10 (d)'s shape).
- **`commit_ids`** must be commits of THIS PAGE's takes. Otherwise it refuses "commit_id X isn't a commit of a take on
  this page." (PROVISIONAL words). The page with that take is where its text rides.
- **`with_tray`, `with_versions`** (note-wide lists, capped at 200) ride the FIRST page only.
- **`with_lenses`:** the lens list (`lens_id`, `name`) on every page, each lens's `picks` restricted to the page's blocks,
  and `dangling_picks` on the first page only (F-256-7 (a)).
- **`version_id`:** pages the saved version the same way; the cursor names the version.
- **No parameter given:** every existing form, the Level 0 text included, is byte-unchanged (F-256-4 (a)). The text form
  is the round-trip format `import_document` reads, and a fragment of it would not import.

**D-256-5 — COST per page (∝ the page).**
- **The page query** is the placements range with `(cb.position, cb.id) > (:pos, :id) … ORDER BY cb.position, cb.id
  LIMIT :limit`, on `idx_cblock_order`. Takes, comments, lineage, commits and lens picks follow by `json_each(page block
  ids)`, the existing statements.
- **Not ∝ the page, and why it is acceptable:**
  - `books` is ∝ the note's memberships (small, as unpaged);
  - `block_count` is one index count over the note's placements, first page only — "the note's blocks" is the Hard
    rules' named allowance;
  - the budget trims after the fetch, so a page reads ≤ `limit` blocks' takes.
- **Builder pin:** the plan through `idx_cblock_order` (an `EXPLAIN QUERY PLAN` pin, the `MCPPicksPlanTests` precedent).

**D-256-6 — THE ONE NOT-SHARED SHAPE, AND WHAT IS BYTE-UNCHANGED.**
- **Order (`list_notes`' discipline):**
  1. The parse, independent of any target: `limit`'s range, the cursor's DECODE, and `ids_only`'s type.
  2. The decision on the note, exactly as today. An unreachable note answers the ONE refusal, byte-identical with or
     without `limit`/`cursor`/`ids_only`, and identical for a missing id.
  3. Only then the cursor's container check (stale).
  A cursor of an unreachable note sent with a readable note says "stale". A readable note's cursor sent with an
  unreachable note says not-shared. Neither tells anything about the other note.
- **`lens_id`'s and `version_id`'s existing checks** keep their order and words.

**D-256-7 — STABILITY WHILE THE NOTE CHANGES (not a snapshot, said plainly; F-256-6 (a)).**
- **Each page is one transaction, consistent in itself.** Between pages, her typing or another client may change the
  note, and a page shows the note as it is THEN.
- **The keyset's exact behaviour:**
  - a block added before the cursor is not seen;
  - one added after it is;
  - a block moved from after the cursor to before it is missed;
  - one moved from before to after is seen twice;
  - a deleted block, the cursor's own included, never breaks the resume (the key is a position, not a live row);
  - a divide of an already-read block mints its second half after it, which is seen. The read first half is stale, the
    ids-live doctrine.
- **No change token is added:** `last_touched_at` misses labels, choices and comments (`touchContainer`'s callers,
  `Operations+Variant.swift:635`), so it would promise more than it delivers.
- **What the description says:** pages are read one at a time; if the note may have changed, read it again, and compare
  `ids_only` digests to tell cheaply. A write with a stale id is refused, as ever.

**D-256-8 — ONCE GRANTS.** A once read grant is spent by its first read (AF-7, `MCPReadTools.swift:150`), so under a once
grant the FIRST page spends it and page 2 refuses, as any second read does today. This is the existing rule, unchanged.
The description says "a note shared once is read in one call". It is recorded for her eye (P-VX256-3) because a big note
shared once still can't be read under the cap.

**D-256-9 — flush and undo.** `read_note` is not a `Job`: `MCPReadTools` never consults `flushesHerEditorFirst`.
- A page reads stored rows, so her unflushed typing isn't in them, exactly as the unpaged read and the ids-live
  doctrine already say.
- The flush exists so an ACT never overwrites or strands her typing. A read cannot. Making pages flush would queue every
  page behind her runner (P2's spirit).
- No undo: a read registers none.

**D-256-10 — THE PINS** (wire; red by absence unless marked GUARD).
- **Paging:**
  - **P-256-1 — pages tile the note:** a 7-block note with `limit: 3` reads as 3 + 3 + 1, with `next_cursor` on the first
    two only. The concatenated `blocks` equal the unpaged `with_ids` blocks entry for entry, in order.
  - **P-256-2 — the budget:** blocks of 20k characters page one per page, the first block always whole, and a single 40k
    block is a page alone.
  - **P-256-3 — `ids_only`:** no take `text`; `sha256` = the digest of the unpaged text per `take_id`; everything else
    equals `with_ids`.
- **Cursors and the fence:**
  - **P-256-4 — stale cursors:** an undecodable cursor, a `list_notes` cursor and another note's cursor each answer the
    stale sentence.
  - **P-256-5 — the fence:** an unreachable note answers byte-identically with paging, without it, and as a missing id,
    with a cursor of a readable note passed.
- **Change and grants:**
  - **P-256-6 — stability:** with a block inserted before the cursor and one after between pages, the second page shows
    the after-one only; a deleted cursor block still resumes.
  - **P-256-7 — once:** page 1 spends the once grant; page 2 refuses.
- **Composition:**
  - **P-256-8 — `lens_id` + paging:** per block, `via`/`shown_take_id` equal the unpaged lens read; `with_lenses`' picks
    are restricted to the page.
  - **P-256-9 — the commit asks:** `with_commits` + paging rides the page budget; a `commit_ids` entry off the page is
    refused.
  - **P-256-10 — `version_id` + paging** tiles the version.
  - **P-256-11 — the plan pin** (D-256-5).
- **GUARD G-256-1:** every existing `read_note`/`export_note` form is byte-unchanged with no new parameter
  (`MCPReadShapeServerTests`' existing pins stay green unedited).

### VX-261 — `list_my_activity`, the client's own recent acts

**D-261-1 — NAME, RUNG, LISTING.**
- **Name and rung:** `list_my_activity` (F-261-1 (a); the pane's own word, "Activity"; verb-first like `list_notes`).
  Rung READ, all scope kinds, `readOnlyHint` true.
- **Listing:** for EVERY APPROVED client, no grant needed (F-261-2 (a)). The declaration gains one flag,
  `listedWhenApproved: true`, and `isListed` reads it before the grant check (`MCPToolCatalog.swift:44–49`).
- **Why no grant:** the case it exists for is a lost reach. A "until you disconnect" grant ends at the disconnect and
  "reconnecting does not restore it" (`MCPSession.instructions`), so a client recovering from a dropped call often holds
  nothing. P-2's "no door that can never act" holds, because this door always acts for an approved client: its own history.
- **The refusals:** a pending or denied client gets the standing's own sentence (`list_books`' guard,
  `MCPReadTools.swift:202–204`). A waiting setup hears the pending sentence before any tool runs (F5).

**D-261-2 — THE ANSWER** (newest first; the row as LOGGED, nothing else):
```json
{"acts": [
  {"tool": "create_note", "outcome": "allowed", "at": "2026-10-14T19:02:11.123Z",
   "target_kind": "book", "target_id": "…", "title": "Capítulo 11"},
  {"tool": "read_note", "outcome": "refused", "at": "…", "target_kind": "note", "target_id": "…"}],
 "next_cursor": "…"}
```
- `tool` is the row's act. A target field is omitted when the row has none. `title` appears only on ALLOWED rows that
  have one.
- **Inputs:** `limit` (1–200, default 50), `cursor`, `include_reads` (default false).
- **Excluded always:**
  - this tool's own rows;
  - every non-tool row: `connect_*` and any act not in `MCPToolFacts.toolNames`.
- **Reads:** by default the read-rung tools' rows (`list_books`, `list_notes`, `read_note`, `export_note`, `search`,
  `show_in_app`) are excluded too, so the listing is about acts that changed something. `include_reads: true` adds them
  (F-261-5 (a)).
- **The minted-id gap, said in the description (F-261-6 (a), F3):** a creating act's row names the PLACE it made
  something in, with what it made's name at the time. To recover a made note, the client looks for that title in
  `list_notes(book_id or wing_id)`. Two rows with one title mean two notes were made.

**D-261-3 — WHAT "OWN" KEYS ON: the client NAME, since its current approval** (F-261-3 (a)).
- **A-4's ruled honest boundary is the argument:** the name IS the identity.
  - Grants hang on the name.
  - "Until you disconnect" is name-scoped: later sessions count.
  - The setup key binds to the name.
  - The log records the name and nothing finer (no session column).
  So two sessions under one name are ONE client to the door, holding the same grants, and each may see the other's acts.
- **This adds no reach:** every allowed row's title was readable under the SAME name's grants at act time, and refused
  rows carry none (D-261-4).
- **Per-session keying would defeat the purpose:** recovery after a dropped call happens in a NEW session (the old
  connection is dead), and per-session keying would hide exactly the acts it must find. It would also need a schema.
- **The era cut:** rows logged before `mcp_client.decided_at` are never listed (the one indexed client read, F6).
  - Deny is her "stop trusting this client" act: it revokes every grant and releases the key.
  - A re-approved name starts with zero reach (APPROVAL IS ALONE), so it starts with no history either. Whatever program
    holds the name after her next approval reads nothing from before it.
- **What a pending client's refused calls do:** they predate its approval and stay out.

**D-261-4 — THE ORACLE RULE, PROVEN BY ROW CLASS** (answer only what the client sent or was told at act time; never the
CURRENT state of a target).
- **The answer is a pure projection of `mcp_activity` rows:** no join to any store table, no "is it still there", no
  current title. A target that became unreachable, was renamed or was deleted reads exactly as it did at act time. A
  pin renames and then deletes the target and sees an identical row (P-261-5).
- **What each field is:**
  - `tool` — the tool it called (sent);
  - `outcome` — what it was told;
  - `at` — when it called;
  - `target_kind` / `target_id` — the argument it sent. The one exception, F7's wing on `duplicate_note`'s wing-side
    refusal, is an id the client could read at that moment (recorded PROVISIONAL P-VX261-5; the builder may omit
    `target_*` on that one row class instead — option (b));
  - `title` — ALLOWED rows only. The act was decided at ≥ read on its target, so the title was readable then (T-261's
    last paragraph), and for a made note or book it is the name the client itself gave.
- **Refused rows NEVER carry a title (F1).** With it gone, a refused act on a HIDDEN note and one on a MISSING id log the
  same act, kind and id, so the rows are byte-identical. That is the one-not-shared shape carried into the log
  (P-261-4).
- **Excluded rows:**
  - connection rows (F2) are not the client's acts. Some are a stranger's attempts under the name, and two carry a
    replaced key's hash;
  - this tool's own rows.

**D-261-5 — REFUSED ACTS: listed, title-less** (F-261-4 (a)). "Did my call land?" is exactly what a refused row answers.
Leaving refusals out would make a refused call indistinguishable from a dropped one.

**D-261-6 — LIMIT, PAGING, COST.**
- **The cursor:** a keyset on `id` (`id < :after`), opaque base64 `a\n<id>`; a stale or foreign cursor answers the
  stale sentence.
- **The statement:**
  ```sql
  SELECT id, act, target_kind, target_id, target_title, outcome, at FROM mcp_activity
  WHERE client_name = ? AND at >= ? AND act IN (SELECT value FROM json_each(?))
    AND (? IS NULL OR id < ?)
  ORDER BY id DESC LIMIT ?
  ```
- **Cost:** ∝ the cap (≤ 501 rows), never the corpus. No index is needed; the table is bounded by construction.
- **The answer** is read in one read snapshot, and its activity line is written after (the F3 pattern, `logAfter`).
- **The cap, said in the description:** 500 rows across ALL clients. VX-256's pages each log a read row, and a long paged
  read pushes older rows out sooner.

**D-261-7 — flush, undo, log.**
- Not a `Job`: it reads only the log, nothing of her text, so no flush. No undo.
- It is logged like every read (target-less). Its rows never list in its own answer, and the pane speaks them (FOR
  VX-234).

**D-261-8 — THE PINS** (wire; red by absence).
- **What lists:**
  - **P-261-1:** after `create_note` into a book and an `edit_take`, the tool lists both newest first, with
    `tool`/`outcome`/`at`/target as logged and `title` as logged.
  - **P-261-2:** another client's rows never list.
  - **P-261-3:** `connect_rebound` and `connect_not_this_names_key` rows under the same name never list.
- **The oracle:**
  - **P-261-4:** a refused `read_note` on an existing unshared note and one on a missing id answer byte-identical
    entries (an injected clock), and neither has a title.
  - **P-261-5:** an allowed row's title survives a rename and a delete of its target unchanged (act-time, never current).
- **Who may read:**
  - **P-261-6:** after Deny and re-approval, earlier rows never list.
  - **P-261-7:** an approved client with ZERO grants has the tool listed and answered; pending and denied clients are
    refused with their sentences; a waiting setup hears the pending sentence.
- **The answer's shape:**
  - **P-261-8:** reads are absent by default and present with `include_reads`; the tool's own rows are absent.
  - **P-261-9:** `limit`/`next_cursor` tile the rows.
- **The Mac suite:** `MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` walks the new tool, red by absence of
  its words.
- **Catalog:** `MCPServerTests`' declared ⇔ handled walk includes it in `MCPReadTools.handledToolNames`.

### THE FORKS — proposed, for the orchestrator's ruling (my pick first)

**VX-254**
- **F-254-1 — the field:**
  - (a) `sha256`, lowercase hex, plain SHA-256 of the stored UTF-8 bytes, nothing normalized;
  - (b) `digest` + `digest_algorithm`;
  - (c) base64 (44 characters; stock tools default to hex).
- **F-254-2 — `divide_block` / `merge_blocks`:**
  - (a) answer D1 `blocks` records (with `sha256`) for the resulting blocks. This keeps the class rule, and the records
    end the forced re-read after a divide or merge.
    - The core cost: `MCPDivideResult`/`MCPMergeResult` gain `blocks: [MintedBlockTakes]`, built from
      `DivideWResult.first/second.variants`, `MergeResult.variant` and `MergeCeremonyResult.variants`.
    - A single-take divide's first half is the SOURCE take rewritten, which `DivideResult` does not return. It gains the
      updated source `Variant` (one construction, `Operations+Structural.swift:248`).
    - Additive: existing keys are unchanged.
  - (b) no digest: the halves are derived by a seam rule the client cannot reproduce, and it sent no words. Verify with
    `ids_only` pages (zero build).
- **F-254-3 — `save_version`:**
  - (a) none (sealed, unaddressable, ∝ the note; `ids_only` on `version_id`);
  - (b) records, as `duplicate_note`.
- **F-254-4 — the book-form import:**
  - (a) none (P-VX252-1's ruled answer; `ids_only` pages per note);
  - (b) per-note `blocks` (∝ the book, which P-VX252-1's argument rejects);
  - (c) a per-note aggregate digest (no canonical form a client can reproduce).
- **F-254-5 — `add_takes`:**
  - (a) `takes: [{take_id, block_id, label?, sha256}]` beside `take_ids`;
  - (b) a parallel `sha256s` array (positional, against U5b's no-positional rule).

**VX-256**
- **F-256-1:**
  - (a) BOTH: keyset paging plus `ids_only` with digests;
  - (b) paging only;
  - (c) ids-only only. It fails at scale: ≈ 71k for her chapter.
- **F-256-2 — the page bound:**
  - (a) `limit` (default 50, max 200) AND a 32,000-character take-text budget, never splitting a block;
  - (b) `limit` only. Not cap-safe for long paragraphs: 50 × 2k characters = 100k;
  - (c) a budget only.
- **F-256-3 — `ids_only` carries `sha256`:**
  - (a) yes;
  - (b) ids alone;
  - (c) a separate `with_digests` flag (orthogonal, one more ask).
- **F-256-4 — the Level 0 text form:**
  - (a) unpaged and byte-unchanged; paging implies `with_ids`;
  - (b) paged documents (a fragment wouldn't import).
- **F-256-5 — `block_count`:**
  - (a) the first page only;
  - (b) every page (∝ the note per page);
  - (c) none.
- **F-256-6 — a change signal:**
  - (a) none, the ids-live doctrine said plainly;
  - (b) `edited` (`last_touched_at`) per page, which misses labels, choices and comments.
- **F-256-7 — note-wide carriage under paging:**
  - (a) tray and versions on the first page; the lens list on every page with page-scoped picks; `dangling_picks` on the
    first page;
  - (b) the carriage asks refuse with paging.

**VX-261**
- **F-261-1 — the name:**
  - (a) `list_my_activity`;
  - (b) `list_my_acts`;
  - (c) `recent_acts`.
- **F-261-2 — listing:**
  - (a) every approved client, no grant needed;
  - (b) only while it holds a live grant (it then can't recover after a while-connected grant ends).
- **F-261-3 — "own":**
  - (a) the name, since its current approval (`decided_at`);
  - (b) the name, every retained row.
- **F-261-4 — refused acts:**
  - (a) listed, never with a title;
  - (b) not listed (a refusal then looks like a drop).
- **F-261-5 — reads:**
  - (a) excluded by default, `include_reads` adds them;
  - (b) always listed.
- **F-261-6 — the minted-id gap:**
  - (a) the row as logged (a creating act names its place), with the recovery road said;
  - (b) creating acts LOG the made note or book as their target. No schema, but the pane's coalescing changes
    ("made 25 notes" becomes 25 lines), her face, for VX-234;
  - (c) a local-only `result_id` column (a schema, outside the brief's "no schema").

### PROVISIONALs (proposed — the orchestrator files the ruled ones at the merge)
- **VX-254:**
  - **P-VX254-1:** divide and merge answer records (if F-254-2 (a)).
  - **P-VX254-2:** `save_version` and the book-form import answer no digests (F-254-3/4 (a)).
- **VX-256:**
  - **P-VX256-1:** the page bound: 50 default, 200 max, 32,000-character budget.
  - **P-VX256-2:** pages are not a snapshot (D-256-7).
  - **P-VX256-3:** a once grant reads one page (the existing rule's consequence, for her eye).
  - **P-VX256-4:** `commit_ids` binds to the page, with the words.
- **VX-261:**
  - **P-VX261-1:** own = the name since its current approval.
  - **P-VX261-2:** listed for any approved client.
  - **P-VX261-3:** refused rows listed, title-less.
  - **P-VX261-4:** a creating act's row names its place.
  - **P-VX261-5:** F7's row keeps its target, or option (b) omits it.

### FOR VX-234 (planned words — to be written AS BUILT by the builder)
- **Activity (`MCPPaneCopy`):**
  - `list_my_activity` allowed: "‹client› checked its recent activity" (+ the times suffix);
  - refused: "‹client› was refused checking its recent activity" (the `refusedPhrase` pattern).
- **Tool descriptions (model-facing; the docs pass U8 polishes):**
  - **The digest sentence**, shared by every answering tool: "…and sha256: the SHA-256 of the take's text exactly as
    stored, as UTF-8 bytes, in lowercase hex — nothing normalized or trimmed — so a digest of your own text proves it
    landed byte for byte."
  - **`create_note` adds:** "(with text, Variorum splits the prose into blocks by its own setting; to verify byte for
    byte, send blocks)."
  - **`read_note` adds:** "Big notes read in pages: pass limit (blocks per page, up to 200), then each answer's
    next_cursor as cursor until none comes back; a page also ends once its takes' text passes about 32,000 characters
    (a block is never split), and the first page says block_count. Pages are read one at a time, not as a snapshot — if
    the note may have changed, read again. ids_only: true gives each take without its text, with its sha256 instead —
    page it to check a whole note against your source cheaply. A note shared once is read in one call."
  - **`list_my_activity`:** "What this client did, newest first, from Variorum's activity log: each act's tool, allowed
    or refused, when, and the id it named (for a note or book it made, the book or wing it was made in); an allowed act
    also says what its target was called at the time — refused ones never do. Use it after a dropped call or a lost
    context to learn whether a call landed (a made note: look for its title with list_notes). Every session under this
    client's name, since the author last approved it; never another client's. Reads join with include_reads: true. The
    log keeps the library's last 500 acts across all clients. Paged — pass next_cursor back as cursor. Returns JSON."

### THE SPLIT for the builders (one fresh `opus-implementer` each, strictly in order)
- **Builder A — VX-254 (pieces 1–3) + VX-261 (piece 4).** VX-254's sweep is wide but shallow: one encoder field, four flat
  keys, and F-254-2's core result types if ruled (a). VX-261 is self-contained: one query, one catalog flag, one handler,
  one pane phrase. Together they are the "answer shapes and the log" half.
  - It reads: this record's U7 section; `MCPWriteTools*.swift`; `MCPMintedBlocks`; `Operations+DocumentImport/Versions/
    MCPInsertBlocks/MCPEdits`; the `Structural` divide/merge results; `MCPReadTools` (for the handler's home);
    `MCPToolCatalog`; `MCPGrantQueries`' activity section; `MCPPaneCopy`'s activity tables.
  - It lands `MCPTextDigest` FIRST (builder B's `ids_only` calls it).
  - Seam: committed, headless green (`swift test --filter VariorumMCPTests` + the touched core suites), the revert runs
    recorded.
- **Builder B — VX-256 (piece 5) + THE STAGE WINDOW (piece 6).** VX-256 is the deepest single design: seven interacting
  parameters in `MCPReadTools.readNote` + `MCPNoteStructure.read`. The window needs every member's legs final, so the
  last builder writes it.
  - It reads: this U7 section; `MCPReadTools`; `MCPNoteStructure`; `LensQueries`; the U5b/U6 STAGE WINDOW plans as the
    template.
  - It writes THE STAGE WINDOW from the draft below, runs `xcodebuild build-for-testing` into
    `App/Variorum/DerivedData/vx336-u7`, and reports READY.
- **If A runs long**, VX-261 moves to B whole (it shares no file with VX-254 except the catalog and `MCPReadTools`'
  dispatch).

### THE LIVE LEGS for U7's window (DRAFT — builder B finalizes; claim `vx336-u7`)
- **Turn mechanics:**
  - Every turn: `claude -p --strict-mcp-config --mcp-config <scratch>/u7-mcp.json --output-format stream-json` (or
    `json`), its PROMPT ON STDIN, `--allowedTools` listing only the leg's MCP tools plus `Bash(python3:*)` where a digest
    is computed. The answer is tee'd to `notes/plans/vx336-screens/u7/<leg>.json`.
  - NEVER `claude mcp list`. Her user-scope fingerprint is taken before and after.
  - Only the setup KEY is taken from the Connect tab, registered in the scratch config (U5's step 3).
- **Fixture road:**
  - `Tools/ScaleFixture/stage.sh notes=10,long=300 App/Variorum/DerivedData/vx336-u7`. It takes the A1 `scale-prestage-*`
    copy itself and launches the Debug app minting "scale fixture · long note": 300 blocks, a long paragraph every 25th,
    ≈ 105k characters unpaged with ids.
  - `Tools/ScaleFixture/restore.sh <dir>` restores it at cleanup, cmp-verified.
  - Its internal pgrep is the loose form: wait out any stranger's xcodebuild line, never edit the script.
- **The grant:** claude-code · a wing · Home · Edit · Always.

**The legs:**
- **L1 — VX-254, a write proves itself.**
  1. One turn has python write `src.json`: six strings, namely curly quotes and an em dash; "beliscou"; an NFD "é";
     an emoji; a line with an embedded newline; a trailing space.
  2. It then `create_note`s them as `blocks` in Home (the model transcribes them — the very failure under test) and
     computes `hashlib.sha256(s.encode()).hexdigest()` of each source string.
  3. It reports MATCH or MISMATCH per take against the reply's `sha256`.
  4. A control: the digest of "beliscáu" against the "beliscou" take must MISMATCH.
  - **Pass:** all MATCH and the control MISMATCHes.
  - **Then:** `edit_take` one take, `add_take` a blank take (e3b0…), and `duplicate_note` the note. Each reply's digests
    match the local ones, and the copy's equal the source's.
- **L2 — VX-256, the big note in pages.**
  1. One turn: `list_notes(wing_id: "")` finds "scale fixture · long note".
  2. It reads it with `read_note(limit: 50)`, following `next_cursor` to the end.
  3. It reports: pages, the block total against `block_count` (300), unique `block_id`s, and the largest page's character
     count.
  - **Pass:** every tool result came back INLINE — the stream-json shows no saved-to-file notice — and the total = 300.
  - **Optional baseline:** one unpaged `with_ids` read in its own turn shows the spill.
- **L3 — VX-256, `ids_only` verifies.** In the SAME turn as L2 (its texts in context), or with L2's texts saved by
  python:
  - `read_note(ids_only: true, limit: 100)` pages;
  - per `take_id`, the reply's `sha256` against python's digest of the text L2 read.
  - **Pass:** all 300 MATCH, every page inline.
- **L4 — VX-261, a dropped call.**
  1. Turn A (background, a unique scratch config path as its pgrep marker) is told: `create_note` "vx336 u7 dropped" in
     Home, THEN run Bash `sleep 120`, then report.
  2. The runner kills that process ~60 s after launch, so the reply never surfaces and the session is gone.
  3. Turn B, a FRESH session under the same name: "you may have done something in Variorum in the last ten minutes; use
     list_my_activity to say what landed".
  - **Pass:** B reports `create_note` · allowed · target_kind wing, id "" · title "vx336 u7 dropped", then finds its id
    with `list_notes`. The runner captures the note in the Library and the Activity line.
- **L5 — VX-261, refused and own.**
  1. Turn C: `read_note` on a made-up UUID (refused).
  2. `list_my_activity(include_reads: true)` shows it refused with NO title, and shows L1–L4's acts.
  3. The pane's Activity tab shows "claude-code checked its recent activity" in BOTH voices (captures `live/s/`, `live/t/`).
- **Optional L6:** Deny then re-approve claude-code (the setup re-run binds the key), then `list_my_activity` lists
  nothing from before.
- **The Mac batch:** the suites reaching `MCPPaneCopy`, `activityLine`, `MCPToolFacts`, `MCPToolCatalog`,
  `MintedBlockTakes`, `MCPDivideResult`/`MCPMergeResult` and `DivideResult` (grep at build time; U5's 31-suite list is the
  starting set), `MCPWingFacesTests` included.
- **Sizing and fallback:** ≈ 75 minutes; ask 95. Batch-only fallback: 20.
- **The Castle heads-up:** if VX-306 has merged, merge main and rebuild before any launch (the coordinator asks at the
  GO).

### OWED (for the orchestrator)
1. **The rulings on every fork above** before any build piece starts (the architect-phase "implementer proposes,
   architect rules").
2. **P-254-NUL, a builder check.** Does a take holding U+0000 survive the store byte-for-byte? GRDB reads TEXT back
   through a C string. Pin it: the reply digest must equal the digest of `read_note`'s text.
   - If it truncates, that is a latent door bug outside U7: ticket it (Bug · Suspected · MCP · Medium).
   - The digest stays computed from the act's rows, and the description must then not overclaim.
3. **U8's doc truth.**
   - `MCPSession.instructions`' "Tools appear only for what they have shared" becomes untrue once `list_my_activity` is
     listed with zero reach (F-261-2 (a)).
   - The instructions (bound 3,000 at U8) should name paging, `sha256` and `list_my_activity` in one line each.
   - The field guide's MCP chapter likewise.
4. **MCPSpec at the merge:** contract lines for the digest (definition and the answering tools), paged and `ids_only`
   `read_note`, and `list_my_activity` (own, the oracle rule, the era cut, title-less refusals).
5. **The cap fact** (UNVERIFIED here): the live round records the measured inline-versus-file threshold. If 32,000 trips
   it, P-VX256-1's number moves before the merge.
6. **No ticket minted.** If F-261-6 is ruled (a), the idempotency token stays "not chosen, recorded only" (the brief).

### THE ORCHESTRATOR'S RULINGS ON U7's FORKS (2026-10-14 ~19:15 MDT — binding on pieces 1–6)

The design (D-254-*, D-256-*, D-261-*) is ACCEPTED as written, with these rulings. The PROVISIONALs go to QUESTIONS at the
merge with the record's options.

**VX-254:**
- **F-254-1 (a), the orchestrator's.** The field is `sha256`: lowercase hex, plain SHA-256 of the stored UTF-8 bytes,
  nothing normalized. One function, `MCPTextDigest`.
- **F-254-2 (b), PROVISIONAL P-VX254-1 (re-worded: divide and merge answer NO digest).** The digest exists to prove the
  client's OWN words landed byte for byte. A divide or merge sends no words; its halves come from the seam rule. (a) would
  change the core structural result types every editor door shares (`DivideResult` and its kin) for a check the client can
  already make with `ids_only` pages. Keep the structural core untouched. (a) is recorded for her.
- **F-254-3 (a) and F-254-4 (a), PROVISIONAL P-VX254-2.** `save_version` and the book-form import answer no digests.
- **F-254-5 (a), the orchestrator's (U5b's no-positional rule).** `add_takes` answers `takes: [{take_id, block_id,
  label?, sha256}]` beside its unchanged `take_ids`.

**VX-256:**
- **F-256-1 (a), PROVISIONAL P-VX256-1.** Both halves: keyset paging and `ids_only` (with digests).
- **F-256-2 (a).** `limit` (default 50, max 200) AND a 32,000-character take-text budget, never splitting a block.
  PROVISIONAL with P-VX256-1's numbers. The live round MEASURES the real client's output cap. If 32,000 trips it, the
  budget moves, and the change is recorded before the merge.
- **F-256-3 (a), F-256-4 (a), F-256-5 (a), F-256-6 (a), F-256-7 (a), the orchestrator's** (P1, the ids-live doctrine,
  byte-unchanged existing forms).
- **P-VX256-2** (pages are not a snapshot), **P-VX256-3** (a once grant reads one page) and **P-VX256-4** (`commit_ids`
  binds to the page) stand as proposed, for her eye.

**VX-261:**
- **F-261-1 (a).** The tool is `list_my_activity`.
- **F-261-2 (a), PROVISIONAL P-VX261-2.** It is listed for every APPROVED client, with no grant needed. Recovery after a
  dropped "until you disconnect" grant is the case the tool exists for. It reads only the caller's own log rows since its
  approval, so it adds no reach to her library.
- **F-261-3 (a), PROVISIONAL P-VX261-1.** "Own" means the client name, since its current approval.
- **F-261-4 (a), PROVISIONAL P-VX261-3.** Refused rows are listed, never with a title.
- **F-261-5 (a), the orchestrator's.** Reads are excluded unless `include_reads` is set.
- **F-261-6 (a), PROVISIONAL P-VX261-4.** Rows are answered exactly as logged, and a creating act's row names its place
  with the recovery road stated. (b) would change her pane's coalescing; (c) is a schema, outside the brief.
- **P-VX261-5: (b), RULED by the orchestrator (the oracle rule's strict letter).** On `duplicate_note`'s wing-side
  refusal row, `target_*` is OMITTED: the wing id is one the client never sent.

**The split: CONFIRMED.**
- **Builder A:** VX-254 + VX-261, landing `MCPTextDigest` first.
- **Builder B:** VX-256 + THE STAGE WINDOW (`vx336-u7`).
- If A runs long, VX-261 moves to B whole.

**OWED 2 (U+0000), carried to builder A as a CHECK.** Pin a take containing U+0000 through the write and read roads. If
GRDB truncates it, that is a separate door bug: record it, mint nothing yourself (the orchestrator tickets it), and do not
fix it in U7.

**OWED 3 goes to U8's brief:** "Tools appear only for what they have shared" becomes untrue once `list_my_activity` is
listed at zero reach. The instructions also name paging, `sha256` and the new tool.


### BUILDER A's RECORD (VX-254 + VX-261; opus-implementer, from 2026-10-14 ~19:30 MDT)

**NOT DONE by builder A (said first):** VX-256 (builder B's), THE STAGE WINDOW (builder B's), any Mac test run (the
window's), any stage. Everything below is headless (`swift build` / `swift test`) plus, at the end, one Mac
`build-for-testing`.

**VX-254 — what landed (pieces 1a–3).**
- `MCPTextDigest.sha256` (`Sources/VariorumMCP/MCPTextDigest.swift`): CryptoKit over `Data(text.utf8)`, lowercase hex.
  The wire's only digest; builder B's `ids_only` calls it.
- `Operations.MintedTake` gains `text` (the minted row's own `working_text`) at its two constructions
  (`Operations+DocumentImport.swift`'s `MintedBlockTakes.init(_:)` — create_note, import_document, insert_blocks — and
  `Operations+Versions.swift`'s copy machine — duplicate_note). `MCPMintedBlocks.records` emits `sha256` on EVERY take
  object.
- Flat answers: `add_take` · `edit_take` (the take as it now stands; on `changed: false` the text it already held) ·
  `restore_commit` gain `sha256`; `add_takes` gains `takes: [{take_id, block_id, label?, sha256}]` beside its unchanged
  `take_ids` (F-254-5 (a)).
- NOT answered, as ruled: `divide_block` / `merge_blocks` (F-254-2 (b) — the structural core's result types untouched),
  `save_version` and the book-form import (F-254-3/4 (a)). Pinned as guards.
- Descriptions: ONE shared sentence, `MCPToolCatalog.digestSentence`, on all eight answering tools; `create_note` adds
  the segmentation sentence; `import_document`'s book form says it carries no sha256.

**VX-254 — the pins** (`Tests/VariorumMCPTests/MCPTextDigestTests.swift`, `MCPWriteDigestServerTests.swift`; expected
digests computed by the TEST's own CryptoKit over the UTF-8 bytes, never by `MCPTextDigest`, so the wire pins compile on
the old tree).
- P-254-1 (`MCPTextDigestTests`, 4 tests): red by ABSENCE on `e9ac7005` (`cannot find 'MCPTextDigest' in scope`), then
  green. Vectors from `printf … | shasum -a 256`.
- P-254-2…10 (9 tests): RED on the tree with `MCPTextDigest` but no sweep (`54cc62a5` + the pins): 9 failed, 50
  issues, every one a missing `sha256`/`takes` (the guard green) — read from the run's own output. Then 10/10 green
  after the sweep.
- Guards (green both sides, by design): `divideAndMergeAnswerNoDigest`; the book-form import's exact key set stays
  pinned in `MCPMintedAnswerServerTests` (`["book_id", "note_ids", "chapter_ids"]`), unedited.
- THE REVERT RUN (announced in `badcf3b7` before it ran): the sweep's eight product files back to `54cc62a5` in the
  working tree (`MCPTextDigest` and the tests kept) → 10 of 11 failed, 52 issues — the nine pins and the U+0000 pin's
  "the answer digests the act's row" line; `divideAndMergeAnswerNoDigest` green. Restored with `git checkout HEAD --
  Sources` (status clean) → `MCPWriteDigestServerTests` + `MCPTextDigestTests` 15/15 green, 1 known issue.
- No existing pin needed an edit (G-254-2): the whole MCP target 293 tests / 61 suites green, the touched core suites
  171 / 42 green.

**THE U+0000 CHECK — FOUND: a take holding U+0000 is STORED TRUNCATED at its first NUL** (recorded, NOT fixed, no
ticket minted — the orchestrator's ruling).
- Read from the run: `add_take` with "before\0after" (12 bytes) → the store holds 6 bytes ("before"); `read_note`
  returns "before"; the answer's sha256 = the digest of the 12 bytes SENT.
- The mechanism (traced): GRDB binds TEXT with length −1 — `sqlite3_bind_text(sqliteStatement, index, self, -1,
  SQLITE_TRANSIENT)` (`.build/checkouts/GRDB.swift/GRDB/Core/Support/StandardLibrary/StandardLibrary.swift:625`) — so
  SQLite takes the C string only up to the NUL as the row is WRITTEN (the read side, `String(cString:)` at `:595`, would
  truncate too). It is the whole store's text road, not only the wire's: every take-writing door, the wire's and hers
  (a paste carrying U+0000), stores the prefix while answering success.
- What it means for VX-254: the digest is computed from the act's in-memory row (D-254-1's no-second-read rule), so for
  a NUL-bearing take it digests what was SENT while the store holds the prefix — the one case where `sha256` overclaims
  "exactly as stored". Nothing else in the sweep is affected.
- Pinned as found: `aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims` asserts the truncation and wraps the
  digest agreement in `withKnownIssue` — green while the bug stands, RED the day the door keeps (or refuses) the bytes,
  so its fixer flips it.
- For the orchestrator's ticket (proposed fields, CLAUDE.md's labeling rule): **Bug · Confirmed · MCP (or the store's
  Area — the bind is store-wide) · Medium**; not Pre-launch unless she says. The fix's two roads (the fixer's, not
  U7's): refuse U+0000 at every text door, or bind TEXT by explicit byte length — the latter is a GRDB-wide change.

**One more fact noticed (not a bug in U7's scope; for the orchestrator's eye):** `edit_take`'s "nothing to write" test
is Swift `String` equality, which is CANONICAL equivalence — so an `edit_take` replacing an NFC take with its NFD
spelling answers `changed: false` and writes nothing. The new `sha256` (the stored text's) then honestly differs from
the client's digest of what it sent, which is exactly what the digest is for; the client cannot re-spell a take's
normalization through `edit_take`. Proposed if she wants it: Improvement · Suspected · MCP · Low.

**VX-261 — what landed (piece 4).**
- `Queries.mcpOwnActivity` (core, `MCPGrantQueries.swift`): D-261-6's statement exactly — the name, `at >= since`, `act IN
  json_each(acts)`, the keyset `id < before`, newest first, `LIMIT`; rows as LOGGED, joined to nothing.
- `MCPToolDeclaration.listedWhenApproved` (`isListed` reads it right after the approved guard) and the declaration
  `MCPToolCatalog.listMyActivity` (read rung, in `read`; inputs `limit` 1–200 default 50, `cursor`, `include_reads`).
- The handler `MCPReadTools.listMyActivity`: the parse first (a cursor that isn't this tool's answers
  `staleCursorMessage`), ONE read snapshot (a pending or denied client hears its standing's sentence — `list_books`'
  guard; the era cut at the client's `decided_at`, failing closed if an approved row ever lacked one), one extra row read
  so `next_cursor` comes back only while rows remain, then the activity line in its own write (`logAfter`, target-less).
- The projection `MCPOwnActivity` (`Sources/VariorumMCP/MCPOwnActivity.swift`): the listed acts (every catalog tool but
  itself, reads only with `include_reads`), the entry (`tool`, `outcome`, `at`, the target when present, `title` on
  allowed rows only), the hidden-target rule, the cursor (`a\n<id>`).
- Activity words (`MCPPaneCopy.swift`): allowed "‹client› checked its recent activity" (+ " (N times)"), refused
  "‹client› was refused checking its recent activity".

**VX-261 — FOUND while building: the design's "every other row's id is an argument the client sent" is not true** —
two more row classes log a RESOLVED id, F7's class (traced in the code, at `5c48547f` lines unchanged):
- the chapter acts (`rename_chapter`, `delete_chapter`, `move_chapter`) — `onChapter`
  (`MCPWriteTools+LibraryEdits.swift:207–215`) resolves the section's BOOK (`Queries.mcpBookOf(section:)`, `""` when the
  section names nothing) and `onBook` logs that id, refusals included;
- `delete_take` on a block's LAST take — `MCPWriteTools+NoteEdits.swift:209–213` logs `("block", road.blockID)` whenever
  the take's note exists, reachable or not; otherwise `("take", the sent id)`.
As logged, both would tell a hidden chapter or take from a missing one in `list_my_activity` (the kind and id differ) —
the Hard rules forbid that. **Built PROVISIONAL P-VX261-6 (below):** every REFUSED row of those four acts answers no
`target_*` (hidden and missing then read byte-identical, pinned); their ALLOWED rows keep the target (the act's answer
told the client that id — `book_id`, `block_id`). The log itself is untouched (her pane keeps its words).

**VX-261 — the pins** (`Tests/VariorumMCPTests/MCPOwnActivityServerTests.swift`, 11 tests; the tool named by string so
they compile on the old tree):
- RED by absence on `b0175aeb` (VX-254 done, no tool): 11 of 11 failed, 24 issues, every one "Unknown tool:
  list_my_activity." — read from the run's own output. Then 11/11 green.
- P-261-1 (newest first, exactly as logged, the creating act naming its place) · P-261-2 (another client's rows) ·
  P-261-3 (connection rows) · P-261-4 (a refused read on a hidden note = one on a missing id, no title, no leaked title)
  · P-VX261-6 (the chapter acts and `delete_take`: refused rows target-less, hidden = missing) · P-261-11 (F7: the wing
  side target-less, the note side keeps its sent id; the log keeps both) · P-261-5 (act-time title through a rename and a
  delete) · P-261-6 (Deny and re-approval: nothing from before) · P-261-7 (zero grants: offered ONLY this tool and
  answered; pending, denied and a waiting setup hear their sentences) · P-261-8 (reads only with `include_reads`; its
  own rows never) · P-261-9 (pages of 2 tile 5 rows as 2·2·1; two foreign cursors stale).
- The Mac pin: `MCPWingFacesTests.listMyActivitySpeaksItsOwnWords` (the three lines exactly). The design's
  "`activitySpeaksEveryActInWordsNeverAToolID` walks the new tool, red by absence" is NOT true: that walk is green on the
  old tree (the fallback says "used list my activity" — no underscore, no id), so the words got their own pin. It
  compiles in the `build-for-testing` below; its RED (old tree) and GREEN runs are THE WINDOW's (builder B's plan) —
  PENDING.
- THE REVERT RUN (announced in `fdd82382` before it ran): arm (a) `MCPReadTools`, `MCPToolCatalog`, `MCPGrantQueries`
  back to `b0175aeb` and `MCPOwnActivity.swift` moved aside → 11 of 11 failed, 24 issues; arm (b) the product restored,
  `MCPOwnActivity.hidesTarget` forced to `false` → exactly `refusedRowsLoggingAResolvedTargetAnswerNoTarget` (6 issues)
  and `duplicateNotesWingSideRefusalAnswersNoTarget` (1) failed, the other nine green — so the hidden-target rule is
  pinned on its own. Restored with `git checkout HEAD -- Sources` (status clean) → 35/35 green.
- The whole MCP target with VX-261 in: 304 tests / 62 suites — green but for `MCPHarnessTimeLimitTests`' never-answers
  pin at 16.4 s and 20.3 s against its 15 s bound (load average 26): VX-353's recorded overrun, not U7's — the suite
  alone is green (3/3, the pin 1.04 s).
- Justified edits (the ritual, each commented in place): `MCPServerTests` (the read list; the book grant's exact tool
  set) and `MCPWriteServerTests` (the suggest grant's exact tool set; the suggest proof's every-door completeness
  subtracts this tool, which names no note, block or take).

**THE HEADLESS FINALS (builder A's stop seam, read from the logs at `29481994`):** `VariorumCoreTests` 2,871 tests / 333
suites green · `VariorumMCPTests` 304 / 62 green with 1 known issue (the U+0000 pin, by design) · `StringsWorkbookTests`
40 / 6 green. **The Mac build:** `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
App/Variorum/DerivedData/vx336-u7a build-for-testing` → `** TEST BUILD SUCCEEDED **` (cold, 2.5 GB; 68 GiB free before).
No `xcodebuild test`, no launch, no store touched.

**THE MAC SUITES FOR THE WINDOW** (grep of `App/Variorum/VariorumTests` for `MCPPaneCopy`, `MCPActivityFace`,
`activityLine`, `MCPToolFacts`, `MintedTake`, `MintedBlockTakes`, `mcpActivity`, `MCPActivityRow`, `DocumentImport`,
`listTools`, `MCPServerHost`, `MCPReadTools`, `MCPWriteTools`, `callTool` — 19 suites; the phone's: none):
MCPAskAndReceiptTests · MCPAsksWaitTests · MCPDeliberateFacesTests · MCPDoorErgonomicsFacesTests · MCPEditFacesTests ·
MCPEditParityFacesTests · MCPGrantSheetTests · MCPGrantSheetU2CaptureTests · MCPHerEditorDoorTests ·
MCPLibraryParityFacesTests · MCPPaneTabsTests · MCPPaneTests · MCPRebindFaceTests · MCPSetupKeyFacesTests ·
MCPSetupMenuTests · MCPShareFacesTests · MCPWingFacesTests (the new `listMyActivitySpeaksItsOwnWords` in it) ·
TutorialMCPChapterCaptureTests · TutorialMCPChapterTests. (`MCPToolFacts.toolNames` now includes `list_my_activity`, so
every walk over it reaches the new words; the grant sheets' W-UX-14 truth pins read its scopes.)

**PROVISIONALs (builder A's — the orchestrator files them at the merge with these options):**
- **P-VX261-6 (NEW, built — the hidden-target rule's two missed row classes):** the refused rows of `rename_chapter`,
  `delete_chapter`, `move_chapter` and `delete_take` answer no `target_*` in `list_my_activity`.
  - (a) refused rows target-less, allowed rows keep the logged target (the answer told the client that id) — BUILT;
  - (b) target-less on both outcomes (the strictest "never sent" letter; an allowed row's book or block id then gone);
  - (c) those acts LOG the id the client sent (the section, the take) — the cleanest log, but her pane's lines and
    coalescing change (her face, VX-234).
- The ruled ones stand as the orchestrator ruled them: P-VX254-1 (divide and merge answer NO digest), P-VX254-2,
  P-VX261-1…4, and P-VX261-5 (b) (RULED).
- Two small built choices, said for the eye (not forks): `list_my_activity`'s `limit` CLAMPS to 1–200 like
  `list_notes` (never refuses); its `next_cursor` comes back only while rows remain (one extra row read), VX-256's
  D-256-3 rule rather than `list_notes`' full-page rule.

**FOR VX-234 (user-facing words, AS BUILT):**
- **Activity (`MCPPaneCopy.swift`):** allowed "‹client› checked its recent activity" (+ " (N times)"); refused
  "‹client› was refused checking its recent activity".
- **Tool descriptions (model-facing; U8 polishes):**
  - the shared digest sentence (`MCPToolCatalog.digestSentence`, on all eight answering tools): "Each sha256 is the
    SHA-256 of that take's text exactly as stored, as UTF-8 bytes, in lowercase hex — nothing normalized or trimmed — so
    a digest of your own text proves it landed byte for byte."
  - `add_take`: "Returns JSON with the new take_id and its sha256." · `add_takes`: "…and takes: per item its take_id,
    block_id, label as stored, and sha256." · `create_note` / `insert_blocks`: "(take_id, label where it has one, and
    sha256)"; `create_note` adds "With text, Variorum splits the prose into blocks by its own setting; to verify byte for
    byte, send blocks." · `import_document`: "(… take_id, label and sha256); for a book, its book_id, note_ids and
    chapter_ids (no sha256 — check a book's notes with read_note)." · `duplicate_note`: "(take_id, label where it has
    one, and sha256 — equal to its source take's)" · `edit_take` / `restore_commit`: "Returns JSON with the commit ids
    and sha256, the take's text as it now stands."
  - `list_my_activity` (title "List my recent activity"): "What this client did in Variorum, newest first, from its
    activity log: each act's tool, whether it was allowed or refused, when, and the id it named (for a note or book it
    made, the book or wing it was made in). An allowed act also says what its target was called at the time; a refused
    one never does, and names only an id you sent. Use it after a dropped call or a lost context to learn whether a call
    landed — for a made note, look for its title with list_notes (two rows with one title mean two notes). It lists
    every session under this client's name since the author last approved it, never another client's. Reads join with
    include_reads: true. The log keeps the library's last 500 acts across all clients. Paged — pass next_cursor back as
    cursor. Returns JSON." Inputs: "Also list reads (default false)." · "next_cursor from the previous page." · "Page
    size (default 50)."

**SELF-ASSESSMENT (builder A's).** Both members built as designed and ruled; every pin red on the old tree and red again
by revert, the hidden-target rule by a narrow revert of its own. What I'd have a reviewer press on: (1) P-VX261-6 —
the design's trace missed two resolved-id row classes; I closed the fence for their refusals by the ruled F7 principle
and kept allowed rows, which is a call the orchestrator should look at; the table in `MCPOwnActivity.hidesTarget` must
grow with any future act that logs a resolved id (said in its doc comment; nothing enforces it mechanically). (2) The
U+0000 finding makes "exactly as stored" untrue for one byte; the descriptions do not caveat it (I did not want to
document a bug as behavior) — the orchestrator's ticket decides. (3) The digest is of the act's in-memory row by design;
the pins tie it to `read_note` byte for byte in every answering tool, so a future op that rewrote text after returning
its row would be caught. (4) The Mac words pin is unrun here (the window's).

**OWED (builder A → the orchestrator):**
1. **The U+0000 ticket** (yours to mint — proposed: Bug · Confirmed · MCP, or the store's Area since the bind is
   store-wide · Medium; never an assignee): the store keeps a text only up to its first NUL (GRDB's −1 bind length), so
   every door answers success on a truncated take, and the wire's `sha256` digests the bytes sent. The pin to flip on
   the fix: `MCPWriteDigestServerTests.aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims`.
2. **P-VX261-6** for your ruling (options above); built (a).
3. **Optional, for her eye:** `edit_take` / `restore_commit`'s no-op test is Swift canonical equality, so an NFC↔NFD
   re-spelling answers `changed: false` (the digest then honestly differs) — proposed Improvement · Suspected · MCP · Low.
4. **Builder B's window:** the 19 Mac suites above; `MCPWingFacesTests.listMyActivitySpeaksItsOwnWords` GREEN on the
   final tree (its red-on-old is by construction — the old table's fallback said "used list my activity"; a red run
   needs a build without the two `MCPPaneCopy` lines, if the window wants one). `App/Variorum/DerivedData/vx336-u7a`
   (2.5 GB) is built at `29481994` + this record commit — reusable for builder B's `build-for-testing` or deleted.
5. **The live legs (draft L1, L4, L5) match what was built:** L4's expected row is `create_note · allowed ·
   target_kind wing · target_id "" · title …`; L5's refused `read_note` row carries `target_kind note`, the sent id, no
   title. The draft's "`MCPWingFacesTests.activitySpeaksEveryActInWordsNeverAToolID` walks the new tool, red by
   absence" is wrong (green on the old tree) — the new words pin replaces it.
6. **U8 / MCPSpec at the merge (carried, plus):** the instructions' "Tools appear only for what they have shared" is
   now untrue (an approved client sees `list_my_activity` at zero reach); MCPSpec's contract lines for the digest (the
   definition; the eight answering tools; none for divide, merge, save_version or a book import) and for
   `list_my_activity` (own = the name since its approval; as logged; refused rows untitled; resolved-target refusals
   target-less; listed when approved).
7. `MCPHarnessTimeLimitTests`' never-answers pin overran twice in the full MCP runs at load 21–26 (16.4 s, 20.3 s) and
   passed alone — VX-353, already filed; nothing new.

### THE ORCHESTRATOR ON BUILDER A's STOP (2026-10-14 ~19:45 MDT)

- **Verified:** the tree is clean at `ff43e84c`, and the orchestrator re-ran the digest, own-activity and catalog suites
  headless: 50 tests, green, with the one known issue (U+0000).
- **P-VX261-6 (a) stands, PROVISIONAL.** On the four acts whose refused rows log a LOOKED-UP id (the three chapter acts
  log the chapter's book, and `delete_take` on a last take logs its block), refused rows answer no `target_*`, and allowed
  rows keep it, since their answer told the client the id. This is the strict oracle rule, the same class as P-VX261-5.
  Builder A's catch corrects the design's "every logged id is one the client sent".
- **U+0000 → VX-357** (Bug · Confirmed · MCP · Medium; Pre-launch is HER call, flagged in the bundle). The digest sentence
  stays as built. The known-issue pin marks it, and the fix belongs to that ticket: refuse, strip, or store faithfully.
- **NFC↔NFD → VX-358** (Improvement · Suspected · Low).
- **Next:** builder B, VX-256 plus THE STAGE WINDOW (`vx336-u7`) with the 19 Mac suites carried. It may reuse or replace
  `DerivedData/vx336-u7a`; the window runs one final product.


### BUILDER B's RECORD (VX-256 + THE STAGE WINDOW; opus-implementer, from 2026-10-14 ~20:00 MDT)

**NOT DONE by builder B (said first):** everything below is NOT-STARTED until its line says otherwise. No subagent is
spawned (the brief); no `xcodebuild test`, no launch, no store touched before the GO.

**Read in full in this session:** the run record's header, Hard rules, LIVE STATUS and the U7 BRIEF; the U7 UNIT RECORD
whole (the traces, D-254/256/261, THE FORKS, PROVISIONALs, FOR VX-234, THE SPLIT, the live-leg draft, OWED, THE
ORCHESTRATOR'S RULINGS ON U7's FORKS, BUILDER A's RECORD, THE ORCHESTRATOR ON BUILDER A's STOP); U5b's THE STAGE WINDOW,
the U5 STAGE RUN, THE ORCHESTRATOR ON U5's and ON U6's WINDOW; `notes/MCPSpec.md`; the resiliency protocol's implementer
section; `MCPReadTools`, `MCPNoteStructure`, `LensQueries`, `MCPToolCatalog`'s read rung, `MCPReadShapeServerTests`,
`MCPPicksPlanTests`, the harness (`MCPServerTests`' `ServerHarness`), `Tools/ScaleFixture/{stage,restore}.sh` and
`ScaleFixture.swift`.

**THE BUILD PLAN (the rulings applied to code; re-verified pointers at `b5d838e1`):**
- **The parse** (`MCPReadTools.readNote`, inside `if !plain` — `export_note` untouched): `limit` (`optionalInt`, CLAMPED
  1–200 like `list_notes` and `list_my_activity`), `cursor` (decoded by a new `NotePageCursor`, base64 of
  `n\n<container id>\n<position>\n<placement id>`; undecodable → `staleCursorMessage`, thrown before the transaction
  exactly as `list_notes` does), `ids_only` (`optionalBool`). Either of `limit`/`cursor` asks for pages (cursor alone =
  50); paging and `ids_only` each imply `with_ids`.
- **The order (D-256-6):** the parse → the note's decision exactly as today (the ONE refusal, byte-identical) → the
  `version_id` and `lens_id` checks, their order and words kept → NEW: the cursor's container must be the container
  paged (`version_id ?? note_id`), else the stale sentence, logged refused like the version check → the once spend → the
  read. A stale cursor never spends a once grant.
- **The page (`MCPNoteStructure.read`, `Options.page`/`Options.idsOnly`):** ONE keyset statement on `idx_cblock_order`
  (exposed as `MCPNoteStructure.pageSQL` for the plan pin), `limit + 1` rows (the extra says blocks remain); the takes for
  the first `limit`; then the budget walk — a block joins while the page's take text (its fan as emitted, archived takes
  included under `include_archived`; zero under `ids_only`) plus, on the first page, the tray's text stays ≤ 32,000
  characters (`pageTextBudget`, PROVISIONAL P-VX256-1), the first block always whole; comments, lineage, parents,
  commits and lens picks are then read for the page's blocks only. Commits ride newest-first across the PAGE within what
  the budget has left (`text_omitted` past it; `commit_ids` always ride); a `commit_ids` entry off the page refuses
  "commit_id X isn't a commit of a take on this page." (P-VX256-4; the unpaged words unchanged).
- **The answer:** the with_ids object per page; `next_cursor` only while blocks remain (the last page block's placement
  `(position, id)`, naming the container); `block_count` on the first page only (one index count); `with_tray` and
  `with_versions` on the first page only; `with_lenses` on every page with picks for the page's blocks (a page-scoped
  `Queries.effectiveLensSelection(_:lens:blocks:)` on `uq_lens_choice_live`) and `dangling_picks` on the first page only;
  `lens_id` reads each page through the lens by the same page-scoped picks. `ids_only`: every take entry carries
  `sha256` (`MCPTextDigest`) in place of `text`; comments, commits, tray and lineage keep their text.
- **No flush, no undo** (D-256-9): `read_note` is not a `Job`.
- **The pins** (`Tests/VariorumMCPTests/MCPPagedReadServerTests.swift`, wire, compiling on the old tree; then
  `MCPPagedReadPlanTests.swift`, red by absence of the SQL): P-256-1…4 and 6–10 red; P-256-5 (the fence) and G-256-1
  (every form without the new asks byte-unchanged — a golden-byte pin) are GUARDS, green on both sides by design; a
  catalog pin for the three new inputs; P-256-11 the plan.

**THE PINS — RED ON THE OLD TREE (read from the run's own output, `b5d838e1`'s sources + the new file):**
`swift test --filter 'MCPPagedReadServerTests|MCPReadFormsUnchangedServerTests'` → **14 tests, 12 failed, 22 issues.**
Every red is the new asks' absence:
- nine tests fail parsing the answer as JSON: the old tree ignores `limit`/`cursor`/`ids_only` and their with-ids
  implication, so it answers the Level 0 TEXT (P-256-1, the cursor/clamp test, P-256-2, P-256-3, P-256-4, P-256-6,
  P-256-7, P-256-8, P-256-10);
- two stop at a `#require` of the page count — one whole-note page (P-256-9's `with_commits`; F-256-7's tray test);
- the catalog pin's 11 issues (no `limit`/`cursor`/`ids_only` input, none of the words).
The two GUARDS are GREEN on the old tree, as designed: `theFenceAnswersOneShapeWithOrWithoutTheNewAsks` (P-256-5) and
`MCPReadFormsUnchangedServerTests.everyFormWithoutTheNewAsksIsByteUnchanged` (G-256-1 — the with-ids, with-commits,
with-lenses + with-tray and through-a-lens answers written out byte for byte, the Level 0 text, `export_note` given the
new arguments, and the unpaged `commit_ids` words; the hand-written bytes matched the old tree on the first run).

**THE PLAN PIN (P-256-11, `MCPPagedReadPlanTests`):** red by absence on the old tree (neither `MCPNoteStructure.pageSQL`
nor `Queries.pageLensSelectionSQL` exists there). It also went RED on the first lens statement written: with plain
JOINs SQLite planned `SEARCH lc USING INDEX uq_lens_choice_live (lens_id=?)` OUTERMOST and `json_each` inside — ∝ the
lens's picks over the whole note, P1's letter broken (the VX-280 lesson again). The fix is the house idiom, `CROSS JOIN`
(SQLite never reorders one; `MCPWriteTools.picksSQL`'s precedent). Now green: the page statement plans `idx_cblock_order
(container_id=? AND position>?)` with no whole-note `USE TEMP B-TREE FOR ORDER BY` and no `SCAN cb`; the lens read plans
`SCAN j` first, then `uq_lens_choice_live` per block, no table scan.

**THE REVERT RUN (announced in `5df458b9` before it ran; every count read from that arm's own output):**
- **Arm (a), the product back:** `MCPReadTools`, `MCPNoteStructure`, `MCPToolCatalog` and `LensQueries` checked out from
  `b5d838e1` in the working tree, the plan pin moved aside (it cannot compile there) → the wire suites **14 tests, 12
  failed, 22 issues** — the original red exactly; both GUARDS green.
- **Arm (b), the budget disabled** (`pageTextBudget = Int.max`, the rest of the product in) → **exactly the three budget
  pins failed, 5 issues:** P-256-2's three page shapes, P-256-9's omitted commit text, and F-256-7's tray counting toward
  the first page; the other 13 green.
- **Arm (c), the cursor's container check removed** → **exactly the crossing pins failed, 3 issues:** P-256-4's
  another-note cursor, and P-256-10's version-cursor-on-the-note and note-cursor-on-the-version; the other 13 green.
- **Restored** (`git checkout HEAD -- Sources Tests`, status clean) → the three suites **16/16 green**.
- **One more pin after the revert run — `aStaleCursorNeverSpendsAOnceGrant`** (D-256-6's ordering: the cursor's
  container is checked after the decision and BEFORE the once spend). RED on the old tree (the four files from
  `b5d838e1`: the other note's paged read answers the Level 0 text — by absence); RED with the check moved AFTER the once
  spend (the stale call spent the grant, so the next read refused — 1 issue); restored → the three suites **17/17 green**.

**THE HEADLESS FINALS (builder B, the whole package at `aee135bc`, read from the log):** `swift test` → **VariorumMCPTests
321 tests / 65 suites green, 1 known issue** (VX-357's U+0000 pin, by design; `MCPHarnessTimeLimitTests` green this
run, no VX-353 overrun) · **VariorumCoreTests 2,871 / 333 green** · **StringsWorkbookTests 40 / 6 green**. No existing
pin edited by VX-256 (G-254-2's ritual not needed).

**THE MAC PRODUCT (builder B, piece 6):** `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
App/Variorum/DerivedData/vx336-u7 build-for-testing` of `cfda547a`'s sources (every later commit is notes-only) → **`** TEST
BUILD SUCCEEDED **`, XCB-EXIT 0**, 194 warnings, none in a touched file (`u7/logs/mac-build-for-testing.log`); 65 GiB free
*[removed for publication]*
`Contents/MacOS/variorum-mcp`, `Contents/PlugIns/VariorumTests.xctest`, `Variorum_Variorum_macosx27.0-arm64.xctestrun`.
The dylib carries both builders' words ("isn't a commit of a take on this page", "about 32,000 characters", "ids_only",
"checked its recent activity", "list_my_activity"); all 21 batch suites are real types in the test bundle (`nm` +
`swift demangle`, ≥ 132 symbols each), `listMyActivitySpeaksItsOwnWords` among them. **`vx336-u7a` DELETED — one product
(2.5 GB) remains.** No `xcodebuild test`, no launch, no store touched.

### THE STAGE WINDOW — the plan (claim `vx336-u7`; runs ONLY on the orchestrator's GO, under the exact claim line it relays)

**What this window does NOT do (said first):** no product code is written or changed, before the claim or under it — a
red that needs code is RECORDED as a FINDING and reported, never fixed here; no rebuild (if `git diff --name-only
cfda547a..HEAD -- Sources App Package.swift` is not empty at the GO, or the coordinator says VX-306 has merged and main
must come in first: STOP before any launch and report — the rebuild is an implementer's); no canon, QUESTIONS or ticket
edits; never her real store, never `/Applications/Variorum.app`, never her USER-scope MCP registrations (the copied setup
line is never run as copied — only its key is taken, into the runner's scratchpad); **never `claude mcp list` (nor `claude
mcp get`)**; `castle-W1-20261013` left alone.

**The kit** (committed `ba220af6` + the prompts in this commit; tested headlessly against a fake shim at READY):
`notes/plans/fixes/vx-336-u7-kit/` — `turn.sh <leg> "<allowedTools>" [relay] < prompts/<leg>.txt` (ONE `claude -p
--strict-mcp-config --mcp-config <scratch cfg> --output-format stream-json --verbose --allowedTools …` turn from the
scratch project `$U7_SCRATCH/proj`, the prompt on STDIN; its config `$U7_SCRATCH/keys/cfg-<leg>.json` chmod 600, built
from `$U7_SCRATCH/keys/u7.key`), `tee-shim.sh` (the config's command: the product's shim, the wire tee'd to
`u7/tee/<leg>-in.jsonl` / `-out.jsonl`), `drop-relay.py` (L4a's command: holds `create_note`'s answer, writes
`u7/tee/L4a.HELD`), `measure.py <leg>` (per wire call: the server's answer size, what the MODEL received, INLINE /
NOT-INLINE with what arrived instead, the page's facts, the context growth ≈ tokens; writes `u7/<leg>-measure.txt`),
`verify-digests.py` (the digests' byte truth from the wire, independent of the model). **Before any turn:** `export
U7_SCRATCH=<the runner's scratchpad>`; `alias T=$PWD/notes/plans/fixes/vx-336-u7-kit/turn.sh` (or the full path);
`K=notes/plans/fixes/vx-336-u7-kit`; `U=notes/plans/vx336-screens/u7` (from the repo root).

**Minutes:** the batch ~6 · SEAM · prefs + fingerprint ~2 · the fixture + A1 ~3 · connect, bind, grant ~6 · L1 ~8 · L2a ~5
· L2b ~10 · L3 ~8 · L4 ~8 · L5 ~5 · the Terminal pass ~5 · cleanup ~8 → **~75 of work; ask a 95-minute claim.**
**Batch-only fallback (~15 min, claim 20):** steps 0, 1, the SEAM and the release (nothing launched, so no A1 — U1b's
precedent); U7's live round then stays OPEN.

**Evidence:** `notes/plans/vx336-screens/u7/` (gitignored): `logs/`, `<leg>.jsonl`, `tee/`, `<leg>-measure.txt`, captures
`live/s/` (Study) and `live/t/` (Terminal). Keys redacted to their first 9 characters in every record and capture name.

0. **Guards, every step** — exactly U5b's step 0: `Tools/WalkKit/guard.sh --author` before anything touches the GUI (exit 3
   ⇒ her app is running: STOP, never quit or kill it; exit 4 ⇒ someone at the machine: STOP); the STRICT instance guards
   `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` both empty before the launch; the claim line EXACTLY as the GO
   relays it; `Tools/stage status` never inside an `&&` chain; `guard.sh <devpid> x y` before each click (`Tools/WalkKit/wl2`
   compiled in this worktree first — the U5 lesson); ≥ 2.6 s between synthetic events; region captures; keys by System
   Events (it drops `á` and `·` — use their option chords); HEAD at the GO recorded; the product check above.
1. **The Mac batch (~6 min) — FIRST, before the A1** (the Hard rules' SEAM order). From `App/Variorum/`: `xcodebuild
   test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u7
   -resultBundlePath ../../notes/plans/vx336-screens/u7/u7-batch.xcresult` + one `-only-testing:VariorumTests/<Suite>` per
   suite, detached to `u7/logs/u7-batch.log` and POLLED in the foreground (a `grep -q` loop). **The 21 suites** — builder
   A's 19 (every Mac file reaching `MCPPaneCopy`, `MCPActivityFace`, `activityLine`, `MCPToolFacts`, `MintedTake`,
   `MintedBlockTakes`, `mcpActivity`, `MCPActivityRow`, `DocumentImport`, `listTools`, `MCPServerHost`, `MCPReadTools`,
   `MCPWriteTools`, `callTool`) plus builder B's grep (`MCPNoteStructure`, `NotePageCursor`, `effectiveLensSelection`,
   `read_note`, `MCPReadTools`) which adds `MCPPaneTabsCaptureTests` (it names `read_note`) and `TakesBoardTests` (it calls
   the lens query family VX-256 grew; the app and the phone call only the UNCHANGED two-argument form, the new overload
   being additive behind `blocks:` — so no phone run): MCPAskAndReceiptTests · MCPAsksWaitTests ·
   MCPDeliberateFacesTests · MCPDoorErgonomicsFacesTests · MCPEditFacesTests · MCPEditParityFacesTests ·
   MCPGrantSheetTests · MCPGrantSheetU2CaptureTests · MCPHerEditorDoorTests · MCPLibraryParityFacesTests ·
   MCPPaneTabsCaptureTests · MCPPaneTabsTests · MCPPaneTests · MCPRebindFaceTests · MCPSetupKeyFacesTests ·
   MCPSetupMenuTests · MCPShareFacesTests · MCPWingFacesTests · TakesBoardTests · TutorialMCPChapterCaptureTests ·
   TutorialMCPChapterTests. **Expected:** green; the three gated `*CaptureTests` skip; **builder A's Mac pin
   `MCPWingFacesTests.listMyActivitySpeaksItsOwnWords` ✔ — its FIRST run (PENDING until read here; its red-on-old is by
   construction — the old table's fallback said "used list my activity", builder A's record)** and
   `activitySpeaksEveryActInWordsNeverAToolID` ✔ (it now walks `list_my_activity`). Known noise, not a red: «Issues
   recorded without an associated test» ×4. A red: re-run that suite ALONE once; a red that reproduces is a FINDING —
   recorded and reported; the live round continues only if it is outside every type this run changed. **→ THE SEAM:**
   record the counts here, commit, push, KEEP the claim, report "SEAM" through the orchestrator; continue only on its word.
2. **Prefs, Backups, fingerprint — BEFORE the fixture (~2 min; `stage.sh` launches the app the moment its copy is done,
   and a launch writes prefs):** `defaults export io.lduarte.Variorum.debug $U/prefs-pre.plist` (key count recorded);
   `ls -la …/Variorum-dev/Backups/ > $U/backups-pre.txt`; the dev store listed read-only; her user-scope servers — names +
   the sha256 prefix, never values: `python3 -I -c 'import json,hashlib,os;
   d=json.load(open(os.path.expanduser("~/.claude.json"))).get("mcpServers",{}); print(sorted(d),
   hashlib.sha256(json.dumps(d,sort_keys=True,separators=(",",":")).encode()).hexdigest()[:16])' > $U/userscope-pre.txt`
   — **READY's read (2026-10-14 ~20:20 MDT): `['linear-server', 'variorum'] bc64543e2f4e8e58`** (= U5's and U6's).
3. **THE FIXTURE AND THE ONE A1 (~3 min):** from the repo root, `Tools/ScaleFixture/stage.sh notes=10,long=300
   "$PWD/App/Variorum/DerivedData/vx336-u7"`. **How it meets the run's other A1 needs:**
   - **It IS the window's only A1.** Its copy loop takes `variorum.sqlite`, `-wal`, `-shm` and every `variorum-keys-*.json`
     into `…/Variorum-dev/Backups/safety-copies/scale-prestage-<UTC>/`, each `cmp`-verified, prints that dir, THEN launches
     the Debug app with `VARIORUM_SCALE_FIXTURE`, which mints once (10 `#scale-fixture` notes + **"scale fixture · long
     note"**, 300 blocks, in Home). U5 and U6 ran that copy loop ALONE (no fixture); here the loop and the launch come
     together, so no separate A1 is taken — a second copy after the launch would hold the fixture.
   - **Its place in the order:** after the batch (the A1 then holds the batch's test-host side effects — the Hard rules'
     order, as at U5/U6) and after step 2 (the launch writes prefs).
   - **Its guard is the LOOSE `pgrep -f 'Variorum.app/Contents/MacOS'`** (so is `restore.sh`'s): it STOPs (exit 3) on our
     own batch's test host if it is still alive, on another session's headless xcodebuild line, or on her real app. A build
     line: wait for it to end — never edit the script. Her app: STOP the window, never quit or kill it.
   - **Record** the printed dir to `$U/a1-path.txt` and the sha256 prefixes of the copied files to
     `$U/store-hash-pre.txt` (U5's form). `restore.sh` at cleanup removes the current `-wal`/`-shm`, copies the A1 set back
     and `cmp`-verifies each file; it refuses any dir not `scale-prestage-*` under the dev store. castle-W1 untouched.
   - **The mint:** poll `log show --last 3m --style compact --predicate 'eventMessage CONTAINS "ScaleFixture:"'` until
     "minted 10 notes + a 300-block note" (≤ 2 min); fallback: a Library capture showing "scale fixture · long note".
4. **Launch, connect, bind, grant (~6 min).** The app is already up (`stage.sh`'s `open -n`); its pid by the strict guard;
   a What's New sheet → its own button; a lock screen → `source ~/.variorum/dev-castle.env`, those values only (none
   expected — the store is Standard/unlocked). Study expected (capture `live/s/00-launch`). App menu ▸ MCP Settings… → the
   switch ON (expected already). **Connect ▸ Claude Code ▸ the copy icon** → ONLY the key: `mkdir -p
   "$U7_SCRATCH/keys" && pbpaste | python3 -I -c 'import re,sys; m=re.search(r"vmk2_claude-code_[^\s\"'"'"';]+",
   sys.stdin.read()); print(m.group(0) if m else "")' > "$U7_SCRATCH/keys/u7.key" && chmod 600 "$U7_SCRATCH/keys/u7.key"`
   (non-empty; record only its first 9 characters); never run the copied line. **The bind turn:** `T bind
   mcp__variorum-dev__list_books < $K/prompts/bind.txt` → Activity "claude-code connected with a new setup, now bound to its
   name" (or "…a newer setup, which replaced its earlier one") with zero clicks (capture); an unknown name → Waiting →
   Approve… (alone — zero reach). **THE GRANT:** Clients ▸ claude-code ▸ Change… (no row to change: ⌥⌘A from the Bookcase)
   ▸ **A wing · Home · Edit · Always** (capture the sheet, and the Shared-with-AI row "Home (wing) · claude-code · read,
   suggest, write new and edit · always"). It reaches the fixture's notes and sherlock (both Home).
5. **L1 — VX-254, a write proves its words (~8 min).** `T L1
   "mcp__variorum-dev__create_note,mcp__variorum-dev__edit_take,mcp__variorum-dev__add_take,mcp__variorum-dev__duplicate_note,Bash(python3:*)"
   < $K/prompts/L1.txt`. **Expected on the wire** (read from `tee/L1-out.jsonl`): `create_note` → `block_ids`, `blocks` (six
   records, each take `{take_id, sha256}`), `note_id`, `tag_ids`; `edit_take` → `changed: true`, the two commit ids and
   `sha256`; `add_take` → `sha256` **`e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`**; `duplicate_note` →
   records with `source_block_id`, every copy's `sha256` its source's. **THE BYTE TRUTH (the product, independent of the
   model):** `python3 -I $K/verify-digests.py L1` → **"no mismatch · 15 checked · 15 equal"** (6 + edit + blank + 7 copies).
   **The client's road:** the model's table MATCH for every string whose bytes it sent faithfully (the tee shows the bytes
   sent: a MISMATCH that coincides with a re-spelled string — an NFD é sent as NFC, say — is the digest catching the very
   slip it exists for, a client fact, never a product red); the **control MISMATCHES**; the edit and the blank match; the
   duplicate matches. **Her face:** Write of "vx336 u7 digests" (six blocks, block 1 edited, block 2 ⑂2) and the Library
   rows (the note and its copy) — captures.
6. **L2a — VX-256, the long note in pages (~5 min).** `T L2a "mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" <
   $K/prompts/L2a.txt`, then `python3 -I $K/measure.py L2a`. **Expected:** 6 pages of 50 = 300 = `block_count` 300, 300
   distinct ids; **every `read_note` INLINE** (each page ≈ 10–15k characters; the measure prints each). **Her face:**
   Settings ▸ MCP ▸ Activity — the six page reads coalesce to ONE line, "claude-code read “scale fixture · long note” (6
   times)" (the pane's coalescing, F4 — capture; FOR VX-234).
7. **L2b — THE CAP: a budget-ended page (~10 min).** On sherlock's "The Red-Headed League" (49,221 characters over ~215
   paragraph blocks, Home): three turns, ONE read each, so each answer is measured alone — `T L2b-200
   "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" < $K/prompts/L2b-200.txt`,
   then `L2b-50`, then `L2b-whole` (same tools); `measure.py` after each. **Expected:** `L2b-200`'s page ENDS BY THE
   BUDGET — ≈ 140 blocks, take text ≤ 32,000 characters (the measure prints it), `next_cursor` present, `block_count` ≈ 215;
   **THE MEASUREMENT the orchestrator asked for: does that ≈ 55–60k-character page arrive INLINE?** Recorded either way,
   with the answer's size and the context growth. `L2b-50` ≈ 20k characters, INLINE expected. `L2b-whole` (the "before" —
   the unpaged with-ids read her book met) ≈ 90k characters, NOT-INLINE expected; what arrived instead is recorded
   verbatim (the saved-to-file notice). **If `L2b-200` is NOT-INLINE:** run the same turn at limit 150 and 100 (edit the
   limit in a copy of the prompt under `$U7_SCRATCH`) and record the largest page that arrives inline — the data the
   orchestrator moves P-VX256-1's numbers by.
8. **L3 — VX-256, `ids_only` verifies (~8 min).** `T L3-100
   "mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,Bash(python3:*)" < $K/prompts/L3-100.txt`, then
   `measure.py L3-100` and **`python3 -I $K/verify-digests.py L3-100 --texts L2a` → "no mismatch · 300 checked · 300 equal"**
   (every take's `sha256` against the text L2a read for that take). **Expected:** 3 pages of 100, 300 takes, 300 with
   `sha256`, 0 with text, every page INLINE; the model's three spot checks MATCH. Then **the ids_only cap:** `T L3-200
   "mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" < $K/prompts/L3-200.txt` + `measure.py L3-200` — a 200-block
   ids-only page (≈ 50k characters of UUIDs and hex, the token-heaviest shape) — INLINE or NOT-INLINE, recorded.
9. **L4 — VX-261, a dropped call (~8 min).** `rm -f $U/tee/L4a.HELD`; start Turn A DETACHED: `nohup zsh -c "$K/turn.sh L4a
   mcp__variorum-dev__create_note relay < $K/prompts/L4a.txt" > $U/logs/L4a.turn.txt 2>&1 &`. Poll ≤ 90 s for
   `$U/tee/L4a.HELD`; the moment it exists, `pkill -TERM -f "keys/cfg-L4a.json"` (only claude's command line holds that
   path); within 10 s confirm `pgrep -lf "cfg-L4a.json"`, `pgrep -lf drop-relay.py` and `pgrep -lf
   "vx336-u7/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp"` all empty (kill any leftover of OURS by its
   pid — never anything else). **Recorded:** `tee/L4a-out.jsonl` holds `create_note`'s answer (the note made, its
   `note_id`); `measure.py L4a` says **NO-RESULT** for that call (the client never heard). HELD never in 90 s → kill the
   turn, record L4 NOT RUN with its tee and stderr, continue. **Turn B, a FRESH session:** `T L4b
   "mcp__variorum-dev__list_my_activity,mcp__variorum-dev__list_notes" < $K/prompts/L4b.txt`. **Expected:** the newest act
   `{"at": …, "outcome": "allowed", "target_id": "", "target_kind": "wing", "title": "vx336 u7 dropped", "tool":
   "create_note"}` above L1's acts (no reads — `include_reads` off); B finds the note by title and its id EQUALS the tee's
   `note_id`. **Her face:** the Library row "vx336 u7 dropped" and Activity's line for it (captures).
10. **L5 — VX-261, refused and own (~5 min).** `T L5 "mcp__variorum-dev__read_note,mcp__variorum-dev__list_my_activity" <
    $K/prompts/L5.txt`. **Expected:** the read refused with the one not-shared sentence ("That note isn't shared with this
    client…"); `list_my_activity(include_reads: true, limit: 30)` newest first: the refused read as `{"at", "outcome":
    "refused", "target_id": "00000000-0000-4000-8000-000000000000", "target_kind": "note", "tool": "read_note"}` — **NO
    title** — then L4b's, L4a's `create_note`, L3's and L2's reads, L1's acts; **never a `list_my_activity` row, never a
    connection row**; the second call (no arguments) lists **no read rows**. **Her face, Study:** Settings ▸ MCP ▸ Activity
    — "claude-code checked its recent activity" (with its "(N times)") — capture `live/s/`.
11. **The Terminal pass (~5 min):** Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control —
    U5's road) → Settings ▸ MCP ▸ Activity: the same lines in Terminal, "claude-code checked its recent activity" among
    them (capture `live/t/`). Theme back to **Study** (capture).
12. **L6 (Deny, then re-approval) is NOT in this window:** its evidence is builder A's headless P-261-6 (after Deny and
    re-approval nothing from before lists); the re-approval road needs a fresh setup and her approval sheet's sequence —
    minutes this window spends on the cap.
13. **Cleanup (~8 min)** — U5b's step 13, adapted: the Debug app quit BY BUNDLE ID (`osascript -e 'tell application id
    "io.lduarte.Variorum.debug" to quit'`), both strict guards empty, no turn, relay or shim of ours left; **the key**
    (read whole from `keys/u7.key`) grepped over `$U`, `~/.claude.json`, `~/.claude/projects/` (the scratch project's
    transcripts), `notes/` and the scratchpad outside `keys/` → **0 files**; then `keys/` deleted (the key and every
    `cfg-*.json`) and the clipboard emptied (`pbcopy < /dev/null`); **no `-s local` registration was ever made** — read-only:
    `python3 -I -c` that `~/.claude.json`'s `projects` entry for `$U7_SCRATCH/proj` has no `mcpServers` (never `claude mcp
    get`/`list`); her user-scope fingerprint AFTER = BEFORE; prefs: `defaults import io.lduarte.Variorum.debug
    $U/prefs-pre.plist`, re-export, diff, `defaults delete` every key the window ADDED (import merges), until **0 added · 0
    removed · 0 changed**; `Tools/ScaleFixture/restore.sh "$(cat $U/a1-path.txt)"` → "Restored (verified)", a second `cmp`
    of every file SAME and the sha256 set equal to `store-hash-pre.txt` (the fixture, L1's notes, the dropped note — every
    window write — gone with it; Standard, unlocked, Study, claude-code's pre-window binding and grants back);
    `Backups/` unchanged against `backups-pre.txt` (no new backup from the launch); castle-W1 untouched; a stray
    `default.profraw` removed; the tree clean; `Tools/stage release --who vx336-u7`; **THE RESULT LINE** for the
    coordinator: claim times; the batch's counts; each leg PROVEN or RED (a red with its answer and capture); **the cap
    measurement** (each probe: page size, INLINE or not, what arrived instead); the posture (cmp SAME vs A1, prefs 0
    differ, fingerprint SAME, Standard/unlocked); the A1 path (the coordinator's to prune).

**For the orchestrator — the cap, predicted (not measured; the window measures):** the default page (50 blocks) is ≈
10–20k characters — far inside any cap. A budget-ended page is ≈ 32k characters of prose plus ≈ 140 blocks of ids ≈
55–60k characters ≈ 20–25k tokens (UUIDs tokenize poorly), near Claude Code's recalled 25,000-token default
(`MAX_MCP_OUTPUT_TOKENS` is unset on the Pro, so the default holds). An `ids_only` page of 200 is ≈ 50k characters of
UUIDs and hex, ≈ 25–30k tokens — the likelier spill. If either spills, the numbers to move are the budget AND the limit's
maximum (ids dominate a big `ids_only` page, which the take-text budget never counts) — the orchestrator's call, before
the merge.

**PROVISIONALs (builder B's — the orchestrator files them at the merge):**
- The ruled ones stand as ruled, for her eye: **P-VX256-1** (both halves; the page bound 50 default · 200 max · 32,000
  characters — the window measures the cap), **P-VX256-2** (pages are not a snapshot), **P-VX256-3** (a once grant reads
  one page — pinned, `aOnceGrantIsSpentByTheFirstPage`), **P-VX256-4** (`commit_ids` binds to the page, with the words
  "commit_id X isn't a commit of a take on this page.").
- Small built choices, said for the eye (none is a fork; each follows the design's letter):
  - `limit` CLAMPS to 1–200 like `list_notes` and `list_my_activity`, never refuses.
  - The first page's TRAY text counts toward its budget (D-256-2's "the budget then counts only commit or tray text");
    lineage's released-original text and comments are not counted (the budget is a take-text budget; both are bounded by
    the page's own blocks).
  - A stale cursor on a readable note is logged as a REFUSED read row, like the `version_id` check (its title then never
    reaches `list_my_activity`, whose refused rows are untitled).
  - `ids_only` with `with_commits` keeps the commits' text (D-256-2: explicit asks keep their text) — so commit text still
    rides within the page's budget.

**FOR VX-234 (user-facing words, AS BUILT — builder B):**
- **No pane word changed.** One FACE consequence for her review: a paged read logs one read row per page, and the pane's
  coalescing (F4) shows them as ONE line — "‹client› read “‹note›” (6 times)" for a six-page read. The window captures it
  (step 6).
- **Tool description (model-facing; U8 polishes), appended to `read_note`'s:** "Big notes read in pages: pass limit
  (blocks per page, 1–200), then each answer's next_cursor as cursor until none comes back (a cursor alone reads 50). A
  page also ends once its takes' text passes about 32,000 characters — a block is never split — and commit text rides in
  what is left of that; the first page says block_count. Pages imply with_ids; with_tray and with_versions ride the first
  page, and each page's lenses pick only among its own blocks. Pages are read one at a time, not as a snapshot — if the
  note may have changed, read it again. A note shared once is read in one call. ids_only: true gives each take without
  its text, with its sha256 instead — page it to check a whole note against your source cheaply." + the shared digest
  sentence (`MCPToolCatalog.digestSentence`, builder A's).
- **Inputs:** `limit` "Blocks per page (default 50); asks for pages (implies with_ids)." · `cursor` "next_cursor from the
  previous page (implies with_ids)." · `ids_only` "Each take's sha256 instead of its text (implies with_ids)."

**SELF-ASSESSMENT (builder B's).** VX-256 is built as designed and ruled (F-256-1…7 (a), P-VX256-1's numbers); every red
pin was red on the old tree by absence, and red again by revert in three arms that each failed exactly the pins naming
their mechanism; the guards hold the fence's one shape and every existing form byte for byte (hand-written golden bytes,
green on both trees). What I'd have a reviewer press on: (1) **the plan pin caught my first lens statement** — plain
JOINs let SQLite put the lens's picks outermost (∝ the note's picks); `CROSS JOIN` fixed it — so any future page-scoped
read should be plan-pinned the same way; (2) **the budget counts take text, not the answer** — a page's ids are bounded
only by `limit` (≈ 280 characters a block), so the real cap question is the 200-block page, above all `ids_only` (the
window measures both); (3) `block_count` and the first page's `dangling_picks` are ∝ the note (the design's named
allowances, first page only); (4) the unpaged read now reads its tray before its blocks (to count it) — the answer is
byte-identical (pinned), only the order of the reads moved; (5) the Mac batch, builder A's Mac pin and the whole live
round are the window's — PENDING.

**OWED (builder B → the orchestrator):**
1. **The cap measurement** (the window's L2b and L3-200): if the budget-ended page or the 200-block `ids_only` page spills,
   P-VX256-1's numbers move before the merge — the budget AND/OR the limit's maximum (see the prediction above the plan).
   A rebuild then needs a fresh builder and a re-run of the touched pins.
2. **MCPSpec at the merge:** a contract line for paged `read_note` (limit/cursor, the budget, `next_cursor`,
   `block_count`, not a snapshot, the cursor resumes only its container, a once grant reads one page) and `ids_only`
   (each take's `sha256` in place of its text).
3. **U8's doc truth (carried, with builder A's OWED 6):** the instructions and the field guide's MCP chapter name paging
   and `ids_only` ("check a whole note against your source cheaply") beside the digests and `list_my_activity`.
4. **FOR VX-234:** the coalesced "read “X” (N times)" line for a paged read (above).
5. **No ticket minted by builder B.** None proposed.


### THE ORCHESTRATOR ON U7's WINDOW (2026-10-14 ~21:20 MDT)

- **Verified, not trusted:** the stage reads FREE; no Variorum instance; her fingerprint SAME (`bc64543e2f4e8e58`, re-read by
  the orchestrator); the tree is clean at `fcae0574`. The runner measured the cap from bytes (the server's answer from the
  tee against the tool result the model received, from stream-json), never from the client's wording.
- **Proven:** VX-254 (L1) and VX-261 (L4, L5) are PROVEN; they close at the merge. VX-256 is PROVEN on paging and
  `ids_only` (L2a, L3) EXCEPT its page bound.
- **THE CAP, RULED (P-VX256-1 re-ruled, PROVISIONAL):** the page budget moves from the TAKE TEXT to the WHOLE ANSWER. A
  page ends at `limit` blocks, or as soon as adding the next block would carry the SERIALIZED ANSWER past **32,000
  characters**. A block is never split: a single block larger than the budget is returned alone, and the description
  says so.
  - **Why the answer:** the ids and records add about 210 characters a block, so the answer runs about 2× its text, and
    `ids_only` pages carry no text at all, so a text budget can't bound them.
  - **Why 32,000:** the measured inline limit sits between 43,062 and 50,984 characters for prose. `ids_only`'s denser
    tokens (about 1.5 characters a token, against prose's about 2.06) put 32,000 characters near 21k tokens, under Claude
    Code's 25,000-token default with margin, for both forms.
  - **What stays:** `limit`'s default 50 and max 200 stand; the answer budget is what bounds a page now.
  - **The description says it:** "a page also ends once the answer reaches about 32,000 characters".
- **Who builds it: U7c**, a FRESH, narrow builder:
  - the budget's meaning changed in `MCPNoteStructure`/`MCPReadTools`;
  - the budget pins re-pinned red-first: on the current tree, a 200-block page of sherlock-sized prose answers over
    32,000 characters, which is red;
  - a revert check;
  - `read_note`'s description;
  - headless finals;
  - no Mac change, unless a pin finds one.
- **The re-probe rides U8b's window:** the same three probes on "The Red-Headed League" (limit 200 and limit 100 with
  text; `ids_only` at limit 200) must all arrive INLINE, read from bytes.
- **U8a resumes after U7c**, so its descriptions and instructions match the final bound; a FRESH U8a continuation takes it
  (its harness count was ~398k at the pause).

## U7c UNIT RECORD — the page budget bounds the whole answer (VX-256; opus-implementer, from 2026-10-14 ~21:20 MDT)

**NOT DONE (said first, at close):** the RE-PROBE is NOT run — the real-client proof that the three probes now arrive
inline rides U8b's window (written below). No `xcodebuild`, no Mac build or suite, no launch, no stage claim, no store
touched (headless `swift build` / `swift test` only; no app file changed). No MCPSpec, QUESTIONS or ticket edit (the
orchestrator's at the merge — OWED). No subagent was spawned.

**Read in full in this session (never delegated):** this record's header and Hard rules; THE ORCHESTRATOR ON U7's
WINDOW (the ruling); the U7 STAGE RUN (its cap table, steps 7–8, THE RESULT LINE); the U7 UNIT RECORD's D-256-1…10;
BUILDER B's RECORD whole (its build plan, pins, revert run, PROVISIONALs, FOR VX-234, OWED); `notes/MCPSpec.md` whole;
`notes/SessionResiliencyProtocol.md`'s implementer section; the kit's `measure.py`, `turn.sh`, `tee-shim.sh` and the
L2b/L3 prompts; code: `MCPReadTools.swift` whole, `MCPNoteStructure.swift` whole, `MCPToolCatalog.readNote`,
`MCPSession`'s tool-result wrapping (`.text(outcome.text)` — the content text IS the serialized answer),
`MCPPagedReadServerTests.swift` and `MCPPagedReadPlanTests.swift` whole, the `text`/`json` harness helpers.

**The ruling, as this unit builds it (THE ORCHESTRATOR ON U7's WINDOW, P-VX256-1 re-ruled, PROVISIONAL):** a page ends
at `limit` blocks, or as soon as adding the next block would carry the SERIALIZED ANSWER past 32,000 characters —
counted on the very JSON text the tool returns (the content the client receives and measured as "65,807 characters").
A block is never split; a single block larger than what the page has left comes alone. `limit` 50 / 200 stand. The
first page's note-wide carriage counts toward its budget. `ids_only` pages are bounded the same. Every form without the
paging parameters is byte-unchanged, and so is the one not-shared shape.

### LIVE STATUS — U7c's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | read-in; this record | DONE (this commit) |
| 1 | the pins on the OLD tree (Tests only) → RED, counts read from the run's own output | DONE (this commit) — see THE PINS below: 22 tests, 9 failed, 18 issues on `0b1be274`'s product |
| 2 | the product: the answer budget (`MCPNoteStructure`, `MCPReadTools`'s shared encoder + the version echoes) + `read_note`'s description; builder B's budget pins re-pinned (each edit commented) → GREEN | DONE (this commit) — the four suites 24/24 green (read from the log; THE DESIGN AS BUILT and THE GREEN RUN below); one more of builder B's pins re-pinned (the clamp, a FINDING); the whole package's finals are piece 4's, PENDING |
| 3 | the revert check (announced here and committed BEFORE it runs; restore verified) | DONE (this commit) — announced in `39fb5320` before any arm ran; four arms on that tree, each undone by `git checkout HEAD -- Sources`; the restore verified (status clean, 25/25 green) — THE REVERT CHECK's results below |
| 4 | headless finals (whole package) · the measured page sizes · FOR VX-234 · PROVISIONAL · the RE-PROBE for U8b · OWED | DONE (this commit) — the record parts in `4ba742a1`; THE HEADLESS FINALS below (read from the logs, at `4ba742a1`) |

### THE DESIGN AS BUILT (piece 2 — the ruling applied to code; no fork: every choice below follows the ruling's letter)

- **D-U7c-1 — THE RULE (`MCPNoteStructure.fitPage`).** The page's candidates are read as before (≤ `limit` placements,
  one keyset statement), each candidate's block entry is built, and the page keeps the first `k`: block 1 always, whole;
  each next block only while the answer WITH it — its entry, its lens picks, the `next_cursor` moved to it (or gone, at
  the note's end) — stays ≤ `pageAnswerBudget` = 32,000 (renamed from `pageTextBudget`: its meaning changed). The sizes
  are exact, piece by piece, on the wire's encoding: a sorted, compact JSON object is its pieces' JSON joined by commas,
  so the page with no block, pick or cursor (`base` — the header and every note-wide list) + each entry (+ a comma) +
  each pick (+ a comma after its lens's first) + the cursor pair (+ a comma) IS the answer's size. **The finished
  answer is then measured once more** and the page shrinks if it is over — the bound holds by that measurement, never
  by the arithmetic alone (the pins' fullness check shows the arithmetic never needs it).
- **D-U7c-2 — WHERE IT IS MEASURED: the one encoder.** `MCPNoteStructure.answerText` is the serialization the tool
  sends (`MCPReadTools.encode` now delegates to it — byte-identical, the same options and the same U4 guard), and a
  version read's echoes (`version_id`, `version_of`, `note_id` = the live note's, `saved_at`) now ride INTO the read
  (`read(…, echo:)`) instead of being set on its result, so a version page weighs them as the wire sends them (P-U7c-1's
  version leg: 72 blocks / 31,990).
- **D-U7c-3 — THE UNIT: UTF-16 code units** (`answerSize` = `utf16.count`). The description says "characters"; the
  client that measured the cap (Claude Code, JavaScript) counts UTF-16 units ("65,807 characters"), and UTF-16 units are
  never fewer than Unicode scalars (Python's `len`, the kit's `measure.py`) or Swift Characters — so "about 32,000
  characters" holds under every reading. Sherlock's prose is BMP-only, so the three counts agree there.
- **D-U7c-4 — THE CARRIAGE.** Everything on the first page that is not a block — `block_count`, the tray, the versions,
  each lens's name and `dangling_picks`, `books`, `entry_date`, the echoes — is in `base`, so it counts toward page 1's
  budget (P-U7c-4: a 28,000-character tray leaves room for one 2,000-character block, page 1 = 31,160). Each lens's
  `picks` grow with the page (the picks list on every page — P-U7c-5's eight lenses). **The one-block floor stands over
  the carriage:** when page 1's carriage alone leaves no room, page 1 still carries its first block, past the budget
  (P-U7c-4b: 32,443) — the PROVISIONAL's open edge (a), below.
- **D-U7c-5 — COMMITS ("commit text rides in what is left of that", kept).** With `with_commits` / `commit_ids`, the
  weighed blocks' commits are read (for the blocks the first fit kept — never the whole candidate set) and weigh WITH
  their blocks as metadata — an asked commit (`commit_ids`) with its text, every other `text_omitted` — the page
  shrinking while over; a `commit_ids` entry off the final page refuses "commit_id X isn't a commit of a take on this
  page." (P-VX256-4's words, unchanged); then unasked texts ride newest-first across the page while the answer stays
  within, and the FIRST that does not fit ends them (a newest-first prefix; the unpaged read's own walk — under
  `commitTextBudget`, with its empty-text quirk — is untouched). An asked commit whose text is larger than the budget
  makes its block a lone oversize block, on the page where that block comes first.
- **D-U7c-6 — THE COST BOUND (P1).** The old take-text walk survives as a COST bound, never the page rule: the answer
  carries every take's text verbatim (escaping only adds), so no block past the point where take text alone (+ page 1's
  tray text) passes 32,000 can ride; comments, lineage, parents and lens picks are read only for the blocks before it
  (none cut under `ids_only`, where `limit` bounds the read — ≤ 200 blocks). Every piece measured is one candidate's: ∝
  the page. The plan pin (P-256-11) is untouched and green.
- **D-U7c-7 — BYTE-UNCHANGED.** Every form without `limit`/`cursor` takes the unpaged road exactly as before (its reads,
  its `commitTextBudget`, its words) — G-256-1's golden bytes green UNEDITED; the fence's one shape — P-256-5 green
  unedited; `export_note` untouched.
- **A FINDING, for the orchestrator (no product change — `limit`'s 200 stands as ruled):** under a 32,000-character
  answer no 200-block page can exist — the smallest block entry (its id, its shown take's id, one take's id and an empty
  text) is ≈ 207 characters, so ≈ 150 blocks reach the budget, and prose or `ids_only` pages end far sooner
  (sherlock: 72–81 blocks with text, 99–116 `ids_only`). `limit` above ≈ 150 is therefore never what ends a page; the
  description's "limit (blocks per page, 1–200)" stays true (the page ALSO ends at the answer bound). Builder B's clamp
  pin is re-pinned accordingly (below).

### THE GREEN RUN (piece 2; read from the log)

`swift test --filter 'MCPPageAnswerBudgetServerTests|MCPPagedReadServerTests|MCPReadFormsUnchangedServerTests|MCPPagedReadPlanTests'`
→ **"Test run with 24 tests in 4 suites passed"** (the 22 of the red run + the two plan pins). One more of builder B's
pins needed a justified re-pin on the fixed tree (commented in the file): **P-256-1b `aCursorAloneReadsFiftyAndTheLimitClamps`**
read `limit: 1000` as [200, 5]; no 200-block page fits the answer (the FINDING above), so the clamp is pinned as what it
is — the parse: `limit: 1000` reads page for page as `limit: 200`, every block read, every page under 200 blocks.
P-U7c-5's fixture gained a short newest commit per take (its first green run showed every page so full of metadata
that no 900-character text had room — which is the rule working; the pin's "some ride" half needed a text that fits).

**THE MEASURED PAGES (characters = UTF-16 units, from the run's own prints):**

| pin | pages (blocks / answer characters) |
|---|---|
| P-U7c-1 the fixture | 215 blocks · 49,007 characters of take text · the unpaged with-ids answer 93,708 |
| P-U7c-1 `limit: 200` | 72 / **31,952** · 81 / 31,818 · 62 / 30,672 (was 161 / 65,712 · 54 / 28,388) |
| P-U7c-1 `limit: 100` | 72 / 31,952 · 81 / 31,818 · 62 / 30,672 (was 100 / 42,967 · 100 / 43,049 · 15 / 8,450) |
| P-U7c-1 `limit: 50` | 50 / 21,275 · 50 / 22,022 · 50 / 18,038 · 50 / 25,381 · 15 / 8,450 (the limit governs) |
| P-U7c-1 a version, `limit: 200` | 72 / 31,990 · 81 / 31,856 · 62 / 30,710 |
| P-U7c-2 `ids_only`, `limit: 200` | 116 / **31,928** · 99 / 27,125 (was 200 / 54,812 · 15 / 4,277) |
| P-U7c-3 the quoted block | 1 / 511 · **1 / 34,486 (alone, oversize)** · 2 / 589 |
| P-U7c-3 the commented block, `ids_only` | 1 / 571 · **1 / 40,618 (alone, oversize)** · 2 / 702 |
| P-U7c-4 the carriage | 1 / 31,160 · 11 / 24,511 |
| P-U7c-4b the crowded first page | **1 / 32,443 (the floor)** · 3 / 795 |
| P-U7c-5 the composed asks | 14 / 31,779 · 14 / 31,624 · 14 / 31,632 · 14 / 31,636 · 4 / 23,836 |

### P-U7c-7 (added after the green run, before the revert check)

**`aVersionPageWeighsItsEchoes`** — no earlier pin told the version echoes apart (sherlock's version pages land hundreds
of characters from the boundary), so this one is calibrated: a twin note's version is read whole and its echoes measured
(`version_id`, `version_of`, `saved_at` — **142 characters**), and the probe's first take is lengthened (+1,422) so its
version's two-block page lands HALF the echoes' width past 32,000 — within it without them. Green on the fixed tree:
**[1, 1]**, page 1 = 31,989. Red on the old tree is the revert check's arm (a), and on the echoes-outside shape its arm (b).

### THE REVERT CHECK (piece 3 — ANNOUNCED here and committed BEFORE any arm runs; every count read from that arm's own output)

The tree under test is this commit's. Each arm changes `Sources/VariorumMCP/` in the WORKING TREE only (never committed),
runs `swift test --filter 'MCPPageAnswerBudgetServerTests|MCPPagedReadServerTests|MCPReadFormsUnchangedServerTests|MCPPagedReadPlanTests'`
(25 tests in 4 suites), and is undone by `git checkout HEAD -- Sources` before the next:
- **Arm (a) — the product back:** `MCPNoteStructure.swift`, `MCPReadTools.swift`, `MCPToolCatalog.swift` from `b3b66903`
  (builder B's product, the pins' red tree). EXPECTED: the eight new pins RED, and the three re-pinned (P-256-2, F-256-7,
  P-256-1b) RED; the other 14 green.
- **Arm (b) — the echoes set AFTER the read** (`MCPReadTools`' old shape: the structure read without `echo:`, the four
  keys set on its result): EXPECTED exactly P-U7c-7 RED.
- **Arm (c) — the final measurement removed** (`fitPage` returns its first assembly): EXPECTED all GREEN — the
  arithmetic alone is exact; the measurement is the bound's guarantee, not its mechanism.
- **Arm (d) — the lens picks unweighed** (each pick's size taken as 0): EXPECTED P-U7c-5 RED (its pages over the budget).
- **Restore:** `git checkout HEAD -- Sources`, `git status` clean, the four suites green again.

**THE RESULTS (read from each arm's own log; 25 tests in 4 suites each):**
- **Arm (a), builder B's product back** (the three files from `b3b66903`): **11 failed, 20 issues — exactly as
  expected:** the eight new pins (P-U7c-1: 161 / 65,716 · 54 / 28,388 at 200, 100 / 42,967 at 100, the version 161 /
  65,754 — 4 issues; P-U7c-2: 200 / 54,808; P-U7c-3: 4 / 35,026 — 2; P-U7c-4: 2 / 33,366 — 3; P-U7c-4b: 4 / 32,957;
  P-U7c-5: ONE page, 60 / 161,088; P-U7c-6 — 2; **P-U7c-7: [2] / 32,071 — 2**) and the three re-pinned (P-256-2,
  F-256-7, P-256-1b); the other 14 green, both GUARDS among them.
- **Arm (b), the echoes set after the read:** **2 failed, 3 issues** — P-U7c-7 ([2] / 32,071, 2 issues) as expected,
  AND P-U7c-1's version leg (page 2: 82 blocks / **32,091**, 1 issue) — the same mechanism caught twice (the sherlock
  version happened to land a page within its echoes' width of the bound under this arm). Every other pin green.
- **Arm (c), the final measurement removed:** **25/25 GREEN, as expected** — the piece-by-piece arithmetic alone is
  exact on every pin; the measurement is the bound's guarantee, not its mechanism.
- **Arm (d), the lens picks unweighed:** **1 failed, 12 issues** — P-U7c-5, but NOT as the announcement predicted
  ("its pages over the budget"): the final measurement HELD the bound (every page ≤ 32,000 — 5 blocks / 29,599–29,888),
  and the wrong arithmetic showed instead as **11 pages not full** (the fullness check: 5 blocks where 14 fit — each
  shrink step re-filled commit text from an over-estimated room, so the page kept shrinking) plus **commit text never
  omitted** (1). So the fullness half of the rule is what pins the arithmetic, and the measurement is what pins the
  bound — the two halves work as designed.
- **Restore:** `git checkout HEAD -- Sources` → `git status` clean, `git diff HEAD` empty; the four suites **25/25
  green** (read from `u7c-restore.log`).

### THE PINS — RED ON THE OLD TREE (piece 1; read from the run's own output)

**The new suite** `Tests/VariorumMCPTests/MCPPageAnswerBudgetServerTests.swift` (wire, the SDK's own client; it compiles on
the old tree — only builder B's arguments and types are named, the budget is the file's literal 32,000; "characters" are
measured as UTF-16 code units, see D-U7c-3):
- **P-U7c-1 `aSherlockSizedNoteReadsInPagesWithinTheAnswerBudget`** — THE FIXTURE is sherlock's "The Red-Headed League"
  exactly as the sample library seeds it (`App/Variorum/Shared/SampleLibrary/SherlockAdventures.txt` read from disk by
  `#filePath`, the `SampleBookDrillTests` precedent; split on its `%%% ` lines and trimmed as `SampleLibrarySeeder.parse`
  does; `importPost(segmentation: .paragraph)`, the seeder's own mode) → **215 blocks · 49,007 characters of take text**
  (the live note's exact numbers); the unpaged with-ids answer 93,708. Read at `limit` 200, 100 and 50, and a saved
  version at 200: every page with more than one block ≤ 32,000; every non-final page FULL (with the next block — its
  lens picks and its commits' text back to `text_omitted` — the answer would pass 32,000; skipped at `limit`); the pages
  tile the note (every block once, in order, entry for entry the unpaged with-ids blocks); `block_count` on page 1 only.
- **P-U7c-2 `idsOnlyPagesStayWithinTheAnswerBudget`** — the same note `ids_only` at `limit: 200`: within the budget,
  full, tiling entry for entry the unpaged `ids_only` read, digests never text.
- **P-U7c-3 `aBlockLargerThanTheBudgetComesAloneNeverSplit`** — 17,000 double quotes are 17,000 characters of text but
  ≈ 34,000 of answer (each travels escaped — the wire's own encoding counts): the block comes ALONE, whole, the others
  around it [1, 1, 2]; under `ids_only` a block with a 40,000-character comment comes alone the same way.
- **P-U7c-4 `theFirstPagesCarriageCountsTowardItsAnswer`** — a 28,000-character tray + a version + a lens (its
  `dangling_picks`) on page 1: one 2,000-character block fits, a second would not; page 1 ≤ 32,000; the next page holds
  several; tray/versions on page 1 only.
- **P-U7c-4b `theFirstPageHoldsOneBlockWhenItsCarriageLeavesNoRoom`** — the one-block floor over the carriage (the
  PROVISIONAL's edge (e1), below): a 31,800-character tray, page 1 still carries its first block (over the budget), later pages within.
- **P-U7c-5 `lensPicksLineageAndCommitsAllCountTowardThePage`** — 60 two-take blocks, eight lenses each picking every
  block, three 900-character commits on every take, read `with_lenses` + `with_lineage` + `with_commits` at `limit: 200`:
  every page within and full, tiling (commit text set aside), each lens's picks exactly the page's blocks, commit text
  riding only in what each page has left (some ride, some omitted).
- **P-U7c-6 `theDescriptionSaysTheAnswerBound`** — the ruled sentence present, "takes' text passes" gone, the commit
  sentence kept.

**Builder B's budget pins RE-PINNED (justified edits, each commented in the file):**
- **P-256-2 `aPageEndsAtItsTextBudgetNeverSplittingABlock`** — its `tens` note (four blocks of 10,000 read [3, 1]) was
  true under BOTH budgets, so it no longer told them apart: re-pinned to 10,600 a block, whose three blocks' TEXT (31,800)
  fits the old budget while their ANSWER does not — [3, 1] before, **[2, 2]** now. Its `ids_only` line keeps [3] but its
  meaning changed ("the limit governs" → "three digest entries fit the answer budget"); the doc comment says the answer.
- **F-256-7 `theNoteWideCarriageRidesTheFirstPage`** — at a 31,000-character tray, page 1's one block now rides only by
  the floor (the answer past the budget), no longer "room for one more block": re-pinned to **28,000**, where one block
  fits the ANSWER budget and a second does not (the old text budget seated two), plus the page's answer ≤ 32,000.
- **Unchanged and still green, their meaning the answer budget's:** P-256-9 `theCommitAsksRideThePage` (commit text in
  what the page has left), P-256-1/4–8/10, the catalog pin, and the two GUARDS (P-256-5, G-256-1).

**THE RED RUN** (`swift test --filter 'MCPPageAnswerBudgetServerTests|MCPPagedReadServerTests|MCPReadFormsUnchangedServerTests'`
on `0b1be274`'s product + these tests): **22 tests in 3 suites, 9 failed, 18 issues.** Every new pin RED, each by its
mechanism: P-U7c-1 (limit 200: pages 161 blocks / **65,712** · 54 / 28,388; limit 100: 100 / 42,967 · 100 / 43,049 ·
15 / 8,450; limit 50: all within; the version at 200: 161 / 65,750 — 4 issues, the page sizes); P-U7c-2 (one 200-block
page of **54,812** · 15 / 4,277); P-U7c-3 (the quotes shared ONE page, 4 blocks / 35,026 — 2 issues); P-U7c-4 (page 1
seated 2 blocks, **33,366** — 3 issues); P-U7c-4b (page 1 seated all 4, 32,957); P-U7c-5 (34 blocks / **105,800** · 26 /
87,984 — 2 issues); P-U7c-6 (2 issues, the words); the re-pinned P-256-2 ([3, 1]) and F-256-7 (2 blocks; 1 + 1
issues). The other 13 GREEN (builder B's unchanged pins and both guards). The live round's 65,807 vs this run's 65,712:
the same 161-block page; the ids and the book's name differ.

### THE HEADLESS FINALS (piece 4 — the whole package, one target per run, at `4ba742a1`; read from the logs)

- **VariorumMCPTests: 329 tests in 66 suites PASSED, 1 known issue** (VX-357's U+0000 pin
  `aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims`, by design) — builder B's 321 / 65 + this unit's
  eight-test suite. **`MCPHarnessTimeLimitTests` green this run** (no VX-353 overrun; one run, nothing to re-run).
- **VariorumCoreTests: 2,871 tests in 333 suites PASSED** (201 s).
- **StringsWorkbookTests: 40 tests in 6 suites PASSED.**
- No existing pin edited beyond the three re-pins recorded above (P-256-2, F-256-7, P-256-1b); no Mac file changed, so
  no Mac build or suite is U7c's.

### PROVISIONALs (the orchestrator files them at the merge)

- **P-VX256-1, RE-RULED (the orchestrator's ruling at U7's window, PROVISIONAL for her eye) — the page bound is the
  SERIALIZED ANSWER.** Options: **(a) AS BUILT — 32,000 characters of answer**, the ruled number (between the measured
  inline 43,062 and spilled 50,984 for prose, with margin for `ids_only`'s denser tokens: the 116-block `ids_only` page
  is 31,928 characters ≈ 21k tokens at U7's ≈ 1.5 a token); (b) a higher answer budget nearer the measured threshold
  (e.g. 40,000) — fewer pages, `ids_only` near the 25,000-token default; (c) a per-form budget (prose vs `ids_only`) —
  two numbers to explain where one suffices. The edges this unit decided under (a), each the ruling's letter or the most
  spec-defensible reading, for her eye:
  - **(e1) the floor over the carriage:** page 1 always carries its first block, even when its note-wide carriage alone
    leaves no room (P-U7c-4b: 32,443). Options: (i) AS BUILT (D-256-2's "a page always holds at least one whole block");
    (ii) a block-less first page carrying only the carriage and a `next_cursor` (a new shape: a page of zero blocks);
    (iii) move the note-wide lists to a page of their own always (a change to F-256-7's ruling — not this unit's).
  - **(e2) the unit:** UTF-16 code units (D-U7c-3). Options: (i) AS BUILT (what the measuring client counts; never fewer
    than any other reading of "characters"); (ii) Unicode scalars (Python's count — up to 2× looser on emoji-heavy text);
    (iii) UTF-8 bytes (stricter still, but not "characters").
  - **(e3) commit text in what is left — a newest-first PREFIX:** the first unasked text that does not fit ends them
    (D-U7c-5). Options: (i) AS BUILT (the unpaged walk's own rule, minus its empty-text quirk); (ii) first-fit — keep
    scanning older, smaller texts that still fit (more text per page, a non-prefix the client must reason about).
  - **(e4) an asked commit counts with its block.** `commit_ids` texts are part of the answer, so a text larger than
    what its page leaves after the blocks before its own pushes that block off the page, and the ask refuses with
    P-VX256-4's words ("…isn't a commit of a take on this page."); such a commit rides only where its block heads a
    page. Options: (i) AS BUILT (the ruling's letter: every multi-block page ≤ 32,000); (ii) the asked commits' blocks
    are always kept and their texts ride on top of the page decided by metadata ("the same cursor gives the same page",
    the answer then past the budget by what was asked); (iii) as (i), with a refusal that names the cursor to ask from
    (new words — U8/VX-234's). Practically rare: a commit that large belongs to a take that was once that long.
- **A FINDING, not a fork (no product change — `limit` 200 stands as ruled):** no 200-block page fits 32,000 (the
  smallest block entry ≈ 207 characters), so `limit` above ≈ 150 never ends a page (D-U7c FINDING above).

### FOR VX-234 (user-facing words, AS BUILT — U7c)

- **No pane word changed.** The paged read's Activity line ("‹client› read “‹note›” (N times)") is unchanged; a page
  now holds fewer blocks, so a long note's N is larger (sherlock at `limit: 200`: 3 pages, was 2).
- **`read_note`'s description (model-facing; U8 polishes)** — ONE sentence changed, everything else byte-identical:
  "A page also ends once its takes' text passes about 32,000 characters — a block is never split — and commit text rides
  in what is left of that; the first page says block_count." → **"A page also ends once the answer reaches about 32,000
  characters (a block is never split; a single larger block comes alone), and commit text rides in what is left of
  that; the first page says block_count."**
- The inputs' words (`limit`, `cursor`, `ids_only`) unchanged.

### THE RE-PROBE — for U8b's window (NOT run here; the runner runs it under U8b's claim, on U8b's product)

**What it proves:** the three probes U7's window failed now arrive INLINE in Claude Code — read from BYTES, never the
client's wording. **The note:** sherlock ▸ "The Red-Headed League" in the dev store (block_count 215, 49,007 characters
of take text — this unit's fixture is the same text, same segmentation). **Reach:** the window's grant must read the
sherlock book (U7's Home · Edit · Always serves; a read grant on the book suffices).

**The kit** (`notes/plans/fixes/vx-336-u7-kit/`, U7c added two env overrides with the old defaults and three prompts):
- `U7_SCRATCH` = a FRESH scratch directory outside the repo (its `keys/u7.key` = ONLY the key from the Claude Code
  tab's copy, the clipboard emptied at once; never the copied line, never `-s local`, never her user scope).
- `U7_SHIM_PATH` = U8b's product's shim, e.g. `$R/App/Variorum/DerivedData/vx336-u8/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp`
  (the default is U7's product — rebuild or override; the product must carry U7c, i.e. contain `d807cca6`).
- `U7_SCREENS` = the window's gitignored evidence folder, e.g. `$R/notes/plans/vx336-screens/u8` (default `…/u7`).
- **Never `claude mcp list` (nor `get`)** — `turn.sh` runs `claude -p --strict-mcp-config --mcp-config <scratch cfg>
  --output-format stream-json --verbose --allowedTools <tools>` with the PROMPT ON STDIN, the shim tee'd both ways.

**The three turns** (ONE read each, so each answer is measured alone; `K=notes/plans/fixes/vx-336-u7-kit`, from the repo
root, the three env vars exported):
1. `zsh $K/turn.sh U7c-200 "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" < $K/prompts/U7c-200.txt`, then `python3 -I $K/measure.py U7c-200`
2. `zsh $K/turn.sh U7c-100 "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" < $K/prompts/U7c-100.txt`, then `python3 -I $K/measure.py U7c-100`
3. `zsh $K/turn.sh U7c-ids-200 "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note" < $K/prompts/U7c-ids-200.txt`, then `python3 -I $K/measure.py U7c-ids-200`

**How inline is read from bytes (`measure.py`, as U7's window did):** it pairs each `mcp__variorum-dev__read_note`
tool_use in `<screens>/<leg>.jsonl` (stream-json: what the MODEL received as its tool_result) with the `tools/call`
the tee recorded (`tee/<leg>-in.jsonl`) and the server's answer by JSON-RPC id (`tee/<leg>-out.jsonl`), and prints the
server's answer size, the size of what the model received, and **INLINE iff the model's tool_result text equals the
server's answer text** (else NOT-INLINE with the first 300 characters of what arrived — U7's spill was "Error: result
(N characters across 1 line) exceeds maximum allowed tokens. Output has been saved to …"). For a read_note page it also
prints blocks, block_count, next_cursor and the page's take-text characters.

**Expected (from this unit's headless measurement of the same text):** (1) `limit: 200` → **72 blocks, ≈ 31,950
characters, next_cursor, block_count 215, INLINE**; (2) `limit: 100` → the same 72-block page (the answer bound ends it
before the limit), INLINE; (3) `ids_only`, `limit: 200` → **116 blocks, ≈ 31,930 characters, INLINE**. Every answer's
size must read ≤ 32,000 in `measure.py` (Python counts code points, never more than the product's UTF-16 count). Any
NOT-INLINE is a FINDING for the orchestrator (the budget's number), recorded and not fixed in the window. The dev store
ids differ from the harness's, so the sizes may differ by a few characters; the block counts should match.

### SELF-ASSESSMENT (the implementer's)

The ruling is built to its letter: a page ends at `limit` or as soon as the next block would carry the serialized
answer past 32,000; the measure is the wire's own encoder (one function now); the first page's carriage and a version's
echoes are inside the measured answer; a larger block comes alone; `ids_only` is bounded the same; every unpaged form
and the fence are byte-unchanged (the two guards green unedited). Every new pin was red on builder B's product by its
own mechanism and green after; the revert arms each failed exactly the pins naming their mechanism (arm (b) caught the
echoes twice; arm (d) showed the fullness check — not the bound — is what pins the arithmetic, and the final measurement
holds the bound even when the arithmetic is wrong). What I'd have a reviewer press on: **(1)** the piece-sum's exactness
claim (a sorted compact JSON object is its pieces joined by commas) — arm (c) and the fullness check are its evidence;
**(2)** the asked-commit edge (e4) — the letter's consequence, recorded with options; **(3)** the floor over the carriage
(e1); **(4)** cost: each page serializes every candidate's entry once, the base once, the finished answer once (≈ 3× the
answer, ∝ the page; the take-text walk now only bounds which candidates' carriage is read); **(5)** P-U7c-1 reads the
bundled sherlock text from `App/Variorum/Shared/SampleLibrary/` by `#filePath` (the `SampleBookDrillTests` precedent)
and `#require`s it sherlock-sized, so a moved resource fails loudly, never silently passes; **(6)** builder B's three
re-pinned pins (P-256-2, F-256-7, P-256-1b) — each edit commented in the file with why its meaning changed.

### OWED (U7c → the orchestrator)

1. **The re-probe** (above) rides U8b's window, on a product containing `d807cca6`.
2. **MCPSpec at the merge** (builder B's OWED 2, amended): the paged `read_note` contract line says the ANSWER bound —
   "a page ends at `limit` blocks or once the answer reaches about 32,000 characters (a block is never split; a single
   larger block comes alone); the first page's note-wide carriage counts toward it; `ids_only` pages are bounded the
   same" — not the take text.
3. **U8a's continuation:** its instructions / field-guide truth must say the answer bound wherever they mention paging
   (none of U8a's words is written yet; the description's sentence above is the model-facing truth).
4. **The FINDING:** `limit` above ≈ 150 never ends a page under the answer bound (no product change; ruled). For her
   eye at the ratification, beside P-VX256-1.
5. **The PROVISIONAL** P-VX256-1 re-ruled + its edges (e1)–(e4) → QUESTIONS at the merge.
6. **No ticket minted.** One proposal, only if the orchestrator rules (e4) worth a follow-up: an Improvement, Evidence
   Test-only, Area MCP, Priority Low — "a paged read's asked commit larger than its page's room is reachable only where
   its block heads a page".
7. **No Mac change** (no app file moved): no Mac build or suite owed by U7c; the stage was never needed.

### THE ORCHESTRATOR ON U7c (2026-10-14 ~22:10 MDT)

- **Verified:** the tree is clean at `12df7a8c`; the diff touches only `MCPNoteStructure`, `MCPReadTools` and
  `MCPToolCatalog`; the orchestrator re-ran the four paging suites headless, 25 green.
- **Its four open edges stand as built, PROVISIONAL under P-VX256-1 (re-ruled), each with its options in the U7c UNIT
  RECORD for her bundle:**
  - e1: page 1 keeps its first block when the carriage fills the budget;
  - e2: UTF-16 counting;
  - e3: commit text rides newest-first;
  - e4: a requested commit too large for its page's room refuses.
  No ticket for e4 unless she rules a follow-up.
- **Its finding 4 is recorded, not a change:** no 200-block page fits 32,000 characters (≈150 blocks at the smallest
  entry). `limit`'s 200 max stands as ruled; the answer bound governs.
- **Next:** a FRESH U8a continuation (the paused session's harness count was ~398k), from the U8a UNIT RECORD's piece-0
  plan, writing the paging words as the answer bound. Then U8b with the re-probe in its window.

## U8a UNIT RECORD — the model-facing words: `MCPSession.instructions`, the tool descriptions, the stargazing brief's delta (VX-197; opus-implementer, from 2026-10-14 ~20:40 MDT)

**NOT DONE (said first, at the continuation's close):** the field guide's MCP chapter, the re-seed note, the Mac
Tutorial*/MCP suites, the chapter walk and the real client reading the instructions are all U8b's (OWED FOR U8b
below), and so is U7c's re-probe. No `xcodebuild`, no Mac build or suite, no launch, no stage claim, no store touched
(headless `swift build` / `swift test` only; no app file changed). No MCPSpec, AppSpec, QUESTIONS or ticket edit
(MCPSpec's "≤2,000" → "≤3,000" is the merge's, OWED). The four OBSERVATIONS below are recorded, not changed. No
subagent was spawned.

*(The first U8a session's line, kept: it read in, then PAUSED at the orchestrator's word, U7's window having taken its
GO, before its first product or test commit.)*

**THE CONTINUATION (a FRESH opus-implementer, from 2026-10-14 ~22:20 MDT, after THE ORCHESTRATOR ON U7c).** The paused
session (harness ~398k) does not resume; this continuation builds pieces 1–6 from the plan below, adjusted only by U7c's
final bound: wherever paging is described, the words describe the ANSWER bound — and the instructions carry NO paging
number at all (the numbers live in `read_note`'s description, U7c's sentence, byte-unchanged here). **Read in full in
this session (never delegated):** this record's header, Hard rules, LIVE STATUS, Her rulings; the U8 BRIEF (its SPLIT and
the U7 carries); this U8a UNIT RECORD; THE ORCHESTRATOR ON U7's WINDOW; the U7c UNIT RECORD whole and THE ORCHESTRATOR ON
U7c; THE ORCHESTRATOR'S RULINGS on U5b's, U6a's (and its ONE OPEN DECISION) and U7's FORKS; the kickoff plan's "U7: the
AI's docs" and R-VX184-2/3/4; `notes/MCPSpec.md` whole; `notes/stargazing-mcp-guide-brief-2026-10-12.md` whole;
`notes/SessionResiliencyProtocol.md`'s implementer section; code: `MCPSession.swift` whole, `MCPToolCatalog.swift` whole,
`MCPAdviceServerTests`, `MCPWireNeutralityTests`, `MCPProviderNeutralityTests`, `MCPTakeLabelFormServerTests`, and for
the truth checks `editTakeUnderInsurance` + `isDirty`, the edit_take answer (`MCPWriteTools+Edit`), `aiLabel`,
`noteBlocks`, `setTakeLabelRows` (trimmed, blank = none, no prefix), `VariorumDocument`'s `take: "label"` lines,
`MCPWriteTools+CommentDelete` (VX-260), `readableBooks` + `requireBookNameFree` (VX-259: live, UNARCHIVED readings of
any kind, counted only while this client can read them), `mcpEditCommitNames` / `mcpRestoreCommitNames` /
`mcpCommitMessage`.

**Read in full in this session (never delegated):** this record's header, Hard rules, LIVE STATUS, Her rulings, the U8
BRIEF (its SPLIT and the U7 carries), the U5a UNIT RECORD (traces, design, FOR VX-234, OWED), U5b's design D1–D10, its
FORKS, PROVISIONALs, FOR VX-234, OWED and THE ORCHESTRATOR'S RULINGS ON U5b's FORKS, THE ORCHESTRATOR ON U5's WINDOW,
U6a's design (D-311-*, D-298-*), PROVISIONALs, FOR VX-234, OWED, its RULINGS and its ONE OPEN DECISION's ruling, U6b's
FOR VX-234 and OWED, THE ORCHESTRATOR ON U6's WINDOW, U7's FORKS and THE ORCHESTRATOR'S RULINGS ON U7's FORKS, BUILDER A's
RECORD, THE ORCHESTRATOR ON BUILDER A's STOP, BUILDER B's RECORD (its PROVISIONALs, FOR VX-234, OWED);
`notes/plans/mcp-pane-and-docs-kickoff.md` ("U7: the AI's docs", HER ADDITIONS, R-VX184-2/3/4); `notes/MCPSpec.md`
whole; `notes/stargazing-mcp-guide-brief-2026-10-12.md` whole; `notes/SessionResiliencyProtocol.md`'s implementer
section; code: `MCPSession.swift` whole, `MCPToolCatalog.swift` whole, `MCPAdviceServerTests`,
`MCPWireNeutralityTests`, `MCPProviderNeutralityTests`, and for the truth checks `editTakeUnderInsurance` and
`restoreCommitForClient` (the dedupe: `isDirty`), `commitTakeForClient`, `MCPWriteTools.aiLabel` / `noteBlocks` (labels
trimmed, no prefix), `MCPWriteTools+CommentDelete` (VX-260), `readableBooks` (VX-259), `MCPBookFacts.matchesWaitWords`,
`MCPNoteStructure`'s comment read (live comments only — VX-148), `MCPOwnActivityServerTests` P-261-7.

### LIVE STATUS — U8a's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | read-in; this record | DONE (this commit) |
| P | **PAUSED** at the orchestrator's word (U7's window has its GO), 2026-10-14 ~20:45 MDT: committed, pushed, `git status` clean; resumed after U7's RELEASE | DONE — the paused session ended; a FRESH continuation took over after U7c (this commit) |
| 1 | the pins on the OLD tree (Tests/ only): the advice (bound 3,000; the tools line; every new claim; the link) + the descriptions' truth (edit_take's deduped before-commit; the label rule per take-writing tool; `<your client name>`; delete_comment's VX-260 clause; rename_book's VX-259 rule) → RED | DONE (this commit) — THE PINS below: 28 tests in 7 suites, 13 failed, 36 issues on `758abded`'s product, every one by its words; every mechanics half green on the old tree |
| 2 | the instructions (new text with the old bound → RED on the bound; then 3,000 → GREEN) | DONE (this commit) — the new text under the OLD bound: `MCPAdviceServerTests\|MCPWireNeutralityTests\|MCPProviderNeutralityTests\|MCPDiscoverProbeServerTests` 25 tests in 4 suites, **failed with 3 issues** — exactly the bound (`theAdviceIsBoundedAsStated` 2: the literal and "the advice is 2969 characters"; `theAdviceNamesTheAuthorNeverAPronoun` 1: inside its bound); then `instructionsBound = 3_000` → **25 tests in 4 suites passed** (both read from the logs). **2,969 of 3,000 characters** (Swift `count`) |
| 3 | the descriptions → GREEN | DONE (this commit) — twelve descriptions (THE DESCRIPTIONS AS BUILT in piece 6's record); the piece-1 filter + `MCPProviderNeutralityTests` → **30 tests in 8 suites passed**, re-run after a source reflow, **30/8 passed** again (both from the logs); a temporary, uncommitted dump test proved the reflow byte-clean (no double space, no joined word) |
| 4 | revert checks (announced, committed first) | DONE (this commit) — announced in `d9ca204d` before any arm ran; three arms, each EXACTLY as announced, each undone by `git checkout HEAD -- Sources`; the restore verified (status clean, `git diff HEAD` empty, 30/8 green) — THE REVERT CHECK's results below |
| 5 | the stargazing brief's FURTHER delta, one send-ready message | DONE (this commit) — THE BRIEF'S DELTA in piece 6's record; the appendix checked against the catalog (64 tools, none missing, none extra) |
| 6 | headless finals (the MCP target) + the instructions' final text whole + FOR VX-234 + OWED for U8b | DONE (this commit) — the record parts in `9ed8452e`; THE HEADLESS FINALS: 340 tests in 66 suites, the one red VX-353's flake (15.34 s), green alone 3/1; 1 known issue (VX-357) |

**For the orchestrator, said before any Sources line moves (no action taken):** U7's runner checks at its step 0 that
`git diff --name-only cfda547a..HEAD -- Sources App Package.swift` is empty. U8a's pieces 2–3 commit to
`Sources/VariorumMCP/MCPSession.swift` and `MCPToolCatalog.swift` (model-facing strings and the bound constant only). The
U7 product is built from `cfda547a` and stays the one under test, but that check would then read non-empty. So U8a orders
its pieces to keep Sources last (record, Tests-only pins and the brief first), and leaves the call to the orchestrator.

**The truth findings so far (read, not yet pinned or changed):**
- `edit_take` promises a "before" commit, but `editTakeUnderInsurance` writes none when `isDirty` is false: the take's
  latest commit already holds its words, or the take is blank and was never committed. The answer then has no
  `before_commit_id`. `restore_commit` already says its dedupe and is true (a take with a commit to restore is never
  uncommitted).
- `delete_comment` (VX-184's words) misses VX-260: a comment whose words anyone has changed since is refused at suggest too.
- `rename_book` says "a name another live book already wears … is refused, as the author's rename is": since VX-259 only
  books this client can READ count, unlike her rename.
- `<your name>` (edit_take, restore_commit, save_commit) means the client name, which save_lens calls `<your client
  name>`; a model may read "your name" as its own. To be made consistent.
- The label rule is unstated on create_note, import_document, duplicate_note and set_take_label, and add_take/add_takes
  state it without its form (VX-197's split, VX-267's form).

**The Sources order (the continuation's note):** U7's window RELEASED at 21:12:37 and U7c rebuilt the product, so the
"keep Sources last" reason above is spent. The pieces still run in the plan's order (pins → instructions → descriptions).

**The checked facts each fix states (read from code in this session):** edit_take's "before" commit is skipped by
`isDirty` exactly when the take's latest commit holds the words it replaces OR the take is blank and never committed;
the "after" commit is always written when the text changed (a blank `text` refuses at the parse, R-VX171-2); writing
the text the take already has returns `changed: false` with no commit and no undo entry; the brackets survive the undo
(P-13nb-U3-2). Labels: `aiLabel` = `client` or `client · label` (trimmed) on add_take/add_takes only; create_note and
insert_blocks (`noteBlocks`) and set_take_label (`setTakeLabelRows`) store a label trimmed, a blank one as none, no
prefix; import_document's label is its `take: "…"` line's (inside the quotes, untrimmed; `take: N` = none);
duplicate_note copies each take's label (the fan-copy machine). VX-259: `requireBookNameFree` counts live, UNARCHIVED
readings of either kind, any wing, and the wire passes `readableBooks` so only those this client can read count. VX-260:
at suggest a comment is the client's own only while its words' digest matches; a record without the digest (before
v1_29) or no record (before v1_27) is not its own.

### THE PINS — RED ON THE OLD TREE (piece 1; read from the run's own output)

**The red run:** `swift test --filter 'MCPAdviceServerTests|MCPEditServerTests/editTakesBeforeCommitIsDeduped|MCPServerTests/theDescriptionsNameTheClientOneWay|MCPTakeLabelFormServerTests|MCPCommentWordsServerTests|MCPBookNameReachServerTests|MCPWireNeutralityTests'`
on `758abded`'s product + these tests → **"Test run with 28 tests in 7 suites failed … with 36 issues"; 13 tests failed,
15 passed.** Every failure is the WORDS; every mechanics half of a mixed pin passed on the old tree.

**The advice** (`MCPAdviceServerTests`):
- **`theAdviceIsBoundedAsStated`** (JUSTIFIED EDIT: `instructionsBound == 3_000`, R-VX184-3) — RED, 1 issue (the bound).
- **`everyToolTheAdviceNamesIsDeclared`** (JUSTIFIED EDIT: the names grow by `list_my_activity` and `duplicate_note`, and
  ONE parameter, `ids_only`, must be a declared input of `read_note` — a parameter is not a tool) — RED, 1 issue.
- **`theToolsLineSaysWhatIsListedOnApproval`** (new) — "Tools appear only for what they have shared" gone; the built
  line present; the catalog fact: the ONE `listedWhenApproved` tool is `list_my_activity` — RED, 2 issues.
- **`theAdviceNamesPagingDigestsAndRecoveryWithNoNumber`** (new) — paging (`limit`, `cursor`, `ids_only` — read_note's
  own inputs), the write digests, the lost-answer road; plus a GUARD (green on both sides by design): no digit in the
  advice outside the format's version token and the word `sha256` — RED, 3 issues (the three sentences).
- **`theRungsSayTheirReachAsBuilt`** (new) — write new's "blocks added at a note's end" (insert_blocks lists from write
  new) and edit's "most of what the author can do at the keyboard" (six edit tools checked edit's) — RED, 2 issues.
- **`theAdviceEncouragesOrganization`** (new) — the three organization sentences; every tool they lean on declared —
  RED, 3 issues.
- **`theAdviceSaysTheThreeActsAreTheAuthorsAlone`** (new, R-VX184-2) — the sentence; no tool name carries
  private/seal/own — RED, 1 issue.
- **`theAdviceLinksTheGuideOnce`** (new, R-VX184-4) — the URL exactly once, no other `://`, the one sentence last — RED,
  3 issues.
- Unchanged and green on the old tree: the format markers, the guide facts, the ladder carries, the arrival, snippets,
  until-you-disconnect; `MCPWireNeutralityTests` (4, green — they ride every later run).

**The descriptions' truth:**
- **`MCPEditServerTests/editTakesBeforeCommitIsDedupedAndTheDescriptionSaysSo`** (new) — runs (1) a take whose latest
  commit holds its words: no `before_commit_id`, history `["after claude-code's edit", "her moment"]`; (2) a blank take
  never committed: no `before_commit_id`; (3) the same text: `changed: false`, no commit, no undo entry; (4) undone: the
  text back, the commits stay — all GREEN on the old tree; the words RED, 3 issues (the dedupe sentence, the no-change
  sentence, the old "Variorum saves a commit named" still present).
- **`MCPServerTests/theDescriptionsNameTheClientOneWay`** (new) — every `<…name>` placeholder in every tool as the SDK
  sends it is `<your client name>`; edit_take / restore_commit quote `Operations.mcpEditCommitNames` /
  `mcpRestoreCommitNames(client: "<your client name>")` and save_commit `mcpCommitMessage(client:message:)` exactly —
  RED, 6 issues (three tools' placeholders + three quotes).
- **`MCPTakeLabelFormServerTests/everyLabelWritingToolSaysWhichLabelRuleApplies`** (new) — per tool: add_take/add_takes
  carry the suggest form with `aiLabel`'s example (tied to `aiLabel` and `labelSeparator`); create_note, insert_blocks,
  set_take_label, import_document and duplicate_note carry their as-given clause + "your client name is added only by
  add_take and add_takes"; the wire controls (import keeps the line's label, the duplicate keeps it, set_take_label
  stores "  warmest  " as "warmest") GREEN on the old tree — the words RED, 7 issues (one per tool).
- **`MCPCommentWordsServerTests/deleteCommentsDescriptionSaysChangedWordsNeedEdit`** (new) — RED, 2 issues.
- **`MCPBookNameReachServerTests/renameBooksDescriptionSaysOnlyBooksYouCanReadCount`** (new) — RED, 2 issues.

### THE REVERT CHECK (piece 4 — ANNOUNCED here and committed BEFORE any arm runs; every count read from that arm's own log)

The tree under test is `97b04d4a`'s. Each arm changes `Sources/VariorumMCP/` in the WORKING TREE only (never
committed), runs THE FILTER — `swift test --filter 'MCPAdviceServerTests|MCPEditServerTests/editTakesBeforeCommitIsDeduped|MCPServerTests/theDescriptionsNameTheClientOneWay|MCPTakeLabelFormServerTests|MCPCommentWordsServerTests|MCPBookNameReachServerTests|MCPWireNeutralityTests|MCPProviderNeutralityTests'`
(30 tests in 8 suites) — and is undone by `git checkout HEAD -- Sources` before the next:
- **Arm (a) — the whole product back:** `MCPSession.swift` and `MCPToolCatalog.swift` from `758abded` (the pre-U8a
  product). EXPECTED: exactly the piece-1 red — 13 tests failed, 36 issues; the other 17 green.
- **Arm (b) — the instructions alone back:** `MCPSession.swift` from `758abded`, the new catalog kept. EXPECTED: the eight
  advice pins red (bound 1, names 1, tools line 2, paging 3, rungs 2, organization 3, three acts 1, link 3 — 16 issues),
  the five description pins green.
- **Arm (c) — the descriptions alone back:** `MCPToolCatalog.swift` from `758abded`, the new instructions kept.
  EXPECTED: the five description pins red (edit_take 3, the client placeholder 6, the label rule 7, delete_comment 2,
  rename_book 2 — 20 issues); every advice pin green (each tool and input it names exists in the old catalog too).
- **Restore:** `git checkout HEAD -- Sources`, `git status` clean, THE FILTER 30/8 green again.

**THE RESULTS (read from each arm's own log; 30 tests in 8 suites each):**
- **Arm (a), the whole product back:** **13 failed, 36 issues — exactly the piece-1 red** (the eight advice pins and the
  five description pins, issue for issue); the other 17 green.
- **Arm (b), the instructions alone back:** **8 failed, 16 issues — exactly as announced** (bound 1, names 1, tools line
  2, paging 3, rungs 2, organization 3, three acts 1, link 3); the five description pins green.
- **Arm (c), the descriptions alone back:** **5 failed, 20 issues — exactly as announced** (edit_take 3, the client
  placeholder 6, the label rule 7, delete_comment 2, rename_book 2); every advice pin green.
- **Restore:** `git checkout HEAD -- Sources` → `git status` clean, `git diff HEAD` empty; THE FILTER **30 tests in 8
  suites passed** (`u8a-restore.log`).

### THE INSTRUCTIONS AS BUILT (piece 2 — 2,969 of 3,000 characters, Swift `count`; exactly what `initialize` sends)

Kept whole from the old text: the opening sentence, the connection-request sentence, the rung list's frame, the
places and durations, the once grant, the until-you-disconnect sentence, search, gatherings and the wing move, live ids,
the format, the fence with snippets and the one shape, the refusal posture, show_in_app, the undo. Changed or new: the
tools line (U7's carry), write new's and edit's reach, paging, digests and recovery (no number), organization, the three
acts, the link. Provider-neutral and pronoun-free (both nets green). The text, whole, as read from the product:

```text
Variorum is a writing app; this server is the door to its library, on the author's Mac, open only while Variorum runs. A new client is a connection request until the author approves it in Variorum ▸ Settings ▸ MCP. Once approved, list_my_activity is always listed; other tools appear only for what the author has shared (re-announced when that changes).
Grants have four rungs, each including those before it: read (read and search), suggest (add takes and comments beside their text, save lenses), write new (new notes, books, chapters, tags, versions; blocks added at a note's end), edit (most of what the author can do at the keyboard: edit, choose and commit takes; divide, merge, move, delete; rename, archive). Each names a note, a book or a wing, for once, until you disconnect, or always; they may also open the whole library to reading (the open book). A once grant is one act: a read grant's first read of a note's text, a higher grant's first write. Until you disconnect lasts while any connection under your client's name stays open, sessions opened later included; it ends when the last one closes or Variorum's server stops, and reconnecting does not restore it.
search covers standing grants only; read a once grant's note by id.
A wing grant also reads that wing's gatherings (list_books lists them, kind gathering); none is ever granted alone. move_note_to_wing needs edit on the note and write new on the wing it goes to.
Ids are live: after any divide or merge, theirs or yours, read again.
read_note speaks the Variorum document format; when its header starts with {v:2}, a "--- next block ---" line separates the blocks. Read a long note in pages (limit, then cursor); ids_only gives each take's sha256 instead of its text. Many writes answer each take's sha256, to prove your words landed.
Help the author stay organized: put plans, summaries and research into notes, not just chat; file notes into books and chapters; tag them, and make books that collect by tag rules. Offer a rewrite as a new take beside theirs, not an edit of their words; leave review as comments. For a revision, copy the note with duplicate_note and edit the copy, so Compare lines the two up.
Three acts are the author's alone: marking something Private, sealing a book (finished, its text frozen) and making a book own its notes. You can't do them, but suggest one when it would help.
The daily Journal's entries and anything marked Private are shared one ask at a time; snippets are not reachable at all. Anything you can't reach answers exactly as if it did not exist.
If a call is refused, don't retry around it: tell the author what you need (Variorum may already have asked them). If an answer is lost, list_my_activity shows whether the call landed.
Never call show_in_app unless the author asks you to show them something.
Every change you make is one undo for the author, named after you; commits stay.
The guide to this door: https://stargazing.tech/variorum/mcp
```

### THE DESCRIPTIONS AS BUILT (piece 3 — twelve tools; every other description byte-unchanged)

Two shared sentences join `digestSentence` in `MCPToolCatalog`: **`suggestedLabelRule`** (`labeled with your client name,
then " · " and your label when you give one (e.g. "<your client name> · english"; a blank label is none)` — the
separator read from `MCPWriteTools.labelSeparator`) and **`labelNotPrefixed`** (`your client name is added only by
add_take and add_takes`).
- **edit_take** — "Variorum saves a commit named "before <your name>'s edit" and one named "after <your name>'s edit", so
  the author can always compare and come back, and the edit is one undo for the author." → "Variorum first commits the
  words it replaces, named "before <your client name>'s edit" (unless they are already the take's latest commit, or the
  take is blank and was never committed — then the answer has no before_commit_id), and then the new text, named "after
  <your client name>'s edit", so the author can always compare and come back; these commits stay even if the edit is
  undone. Writing the text the take already has changes nothing (changed: false). The edit is one undo for the author."
- **restore_commit** — `<your name>` → `<your client name>` (twice); the words otherwise unchanged.
- **save_commit** — `"<your name>: <message>"` → `"<your client name>: <message>"`.
- **add_take** — "labeled with this client's name (plus your label, if given), is never chosen and never locked" → "The
  take is ‹suggestedLabelRule›, so the author sees who suggested it; it is never chosen and never locked".
- **add_takes** — "labeled with this client's name (plus the item's label, if given)" → "‹suggestedLabelRule›".
- **create_note** — adds "Each label is stored as given (trimmed; a blank label is none) — ‹labelNotPrefixed›." after the
  blocks' description.
- **insert_blocks** — "never chosen, each label kept as given (an empty text is a blank take)" → "never chosen (an empty
  text is a blank take). Each label is stored as given (trimmed; a blank label is none) — ‹labelNotPrefixed›."
- **import_document** — "sections as extra takes;" → "sections as extra takes, each labeled as its take: line says —
  ‹labelNotPrefixed›;".
- **duplicate_note** — adds "In the copy every take keeps its label — ‹labelNotPrefixed›." after "The original is never
  changed."
- **set_take_label** — adds "The label is stored as given (trimmed) — ‹labelNotPrefixed›."
- **delete_comment** — ": one Variorum doesn't have on file as yours (the author's, another client's, or one left before
  Variorum kept that record) is refused." → " whose words no one has changed since you wrote them; any other is refused —
  the author's, another client's, one left before Variorum kept a record of its words, or one whose words were changed
  after you wrote them (by the author on any device, or by another client)."
- **rename_book** — "A name another live book already wears (ignoring case) is refused, as the author's rename is; a
  finished or sealed book can still be renamed." → "A name already worn (ignoring case) by another live, unarchived book
  or gathering that you can read is refused; one you can't read never counts, so it can't block the name. A finished or
  sealed book can still be renamed."
- **read_note** — UNCHANGED here: U7c's answer-bound sentence stands as the one place the paging numbers live.

### THE BRIEF'S DELTA (piece 5 — `notes/stargazing-mcp-guide-brief-2026-10-12.md`, one send-ready message)

- **R-VX184-4's gate at the top:** the page goes live first; the release whose instructions end "The guide to this door:
  https://stargazing.tech/variorum/mcp" publishes only after it.
- **"When" rewritten:** the next MCP update is the first release that links the page; the things that arrive only with
  it are named (paragraphs added to a note, duplicating for Compare, Compare from the AI, an AI's own activity, labels
  without "suggested"). No release number is claimed.
- **The 2026-10-13 change list kept**, and a **FURTHER list** appended (11 items) for an agent that built from the
  2026-10-13 version: the gate; the setup's code block and the waiting new setup (VX-258); Read's own activity and
  Compare (VX-261, VX-298); Suggest's label form (VX-267) and the changed-words comment rule (VX-260); Write new's
  duplicate (VX-311) and end-of-note paragraphs (VX-255); Edit's paragraphs anywhere and the comment restore made honest
  (VX-148: an AI can bring back only a deleted comment it already knows of); the book-name rule (VX-259); undo never
  overwriting her later change (VX-276), her typing saved first and a deleted open note going to the Library (VX-275 ·
  VX-323), the icon's Pool and Book Panel rows (VX-268, VX-330), Activity's self-checks; a short section for the AI
  reading the page; the refreshed chapter and Restore Tutorial…; the final appendix.
- **The page content updated in place** to match, so the message never contradicts itself.
- **The appendix:** 64 tools, checked against the catalog dump (none missing, none extra); `list_my_activity` (no share
  needed), `insert_blocks` (end at write new, anywhere at edit), `duplicate_note` (a wing share).
- **The note for Lillian:** what VX-246 and VX-336 fold in; two things that may still move (U8b's chapter wording and
  title — the brief quotes "AI & the MCP door" — and VX-234's pane renames); the gate is hers.

### FOR VX-234 (user-facing words, AS BUILT — U8a)

- **No pane, sheet or receipt word changed.** Everything U8a wrote is model-facing (the instructions, twelve tool
  descriptions) or the public page's brief.
- **The instructions' new lines** (above, whole): the tools line; write new's and edit's parentheses; the paging and
  digest sentences; the lost-answer sentence; the organization paragraph; the three-acts paragraph; the link line "The
  guide to this door: https://stargazing.tech/variorum/mcp".
- **The twelve descriptions** (above), with the two shared sentences.
- **The public page's brief** — hers to carry to the site agent; its words are the site agent's to voice.

### PROVISIONALs

None. Every sentence states a built mechanism or a ruling (R-VX184-2/3/4, P-VX261-2, P-VX255-1, VX-258/259/260,
VX-267, VX-148); the word choices are on FOR VX-234.

### OBSERVATIONS (read, NOT changed — outside the plan's five; for the orchestrator)

1. **edit_take** doesn't say a blank `text` refuses (R-VX171-2); the refusal's own sentence tells a client. Not untrue.
2. **create_book** says nothing about the name check, which VX-259 also narrowed. Not untrue.
3. **The instructions sit at 2,969 of 3,000:** 31 characters of room. Any later line must trim one.
4. **The brief quotes the chapter's title** "AI & the MCP door" in "Learn more inside the app": if U8b retitles the
   chapter, that line changes with it.

### SELF-ASSESSMENT (the implementer's)

Built to the plan's pieces 1–6, with U7c's bound respected by stating NO paging number in the instructions (the page
bound lives in `read_note`'s description, untouched). Every new claim in the instructions is pinned sentence by sentence
and tied where possible to a catalog fact (the one listed-on-approval tool, read_note's inputs, insert_blocks' rung, six
edit tools, the tools the organization advice leans on, no tool that sets Private/Seal/Own); a GUARD keeps every digit
out of the advice except the version token and `sha256`. Every description fix is pinned with its words, and the mixed
pins run the mechanics the words state (edit_take's four cases, the label rule's three as-given roads); all mechanics
halves were green on the old tree, so each fix is a words fix, as the findings said. The revert arms each failed
exactly their announced pins. What I'd have a reviewer press on: **(1)** the instructions' "most of what the author can
do at the keyboard" (R-VX184-1 says broadly as capable; "most" leaves room for the three acts and any door not on the
wire); **(2)** "Many writes answer each take's sha256" — deliberately not "every" (divide, merge, save_version and the
book-form import answer none, P-VX254-1/2); **(3)** import_document's label clause — its labels are the `take: "…"`
line's, untrimmed inside the quotes, so it says "as its take: line says" rather than "trimmed"; **(4)** the brief's new
page facts, each checked against the as-built code or MCPSpec (listed in THE BRIEF'S DELTA).

### THE HEADLESS FINALS (piece 6 — the MCP target, at `9ed8452e`; read from the logs)

- **Run 1, `swift test --filter VariorumMCPTests`:** "Test run with **340 tests in 66 suites** failed with 2 issues
  (including 1 known issue)" — 339 passed. The one failure is **VX-353's load flake**:
  `MCPHarnessTimeLimitTests/aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` at **15.34 s** against its
  15 s bound (load average about 7 / 9 / 14 at the time). The known issue is VX-357's U+0000 pin
  (`aTakeHoldingUPlus0000IsStoredTruncatedSoItsDigestOverclaims`), by design. 340 = U7c's 329 + this unit's 11 new tests.
- **Run 2, the flake's suite alone, `swift test --filter MCPHarnessTimeLimitTests`:** "Test run with **3 tests in 1
  suite passed**" — the never-answers-initialize pin green.
- No Core, workbook or app file changed, so no other target is U8a's.

### OWED FOR U8b (every fact the guide chapter must match)

1. **The label rule (VX-197's split, VX-267's form).** Takes a client adds at suggest (`add_take`, `add_takes`) wear
   "‹client›" or "‹client› · ‹label›" — no "suggested"; takes from before VX-267 keep "‹client› · suggested · ‹label›",
   and `save_lens` by label matches both forms (its own takes only). Every other tool that writes a label (create_note,
   insert_blocks, set_take_label — trimmed; import_document — the take line's; duplicate_note — copied) adds no name.
2. **The new tools, taught in their lessons:** `insert_blocks` (write new at a note's end; edit anywhere — after a
   block or at the start; ≤ 200 blocks; one undo); `duplicate_note` (read on the note + write new on its WING; the copy
   lands bookless in that wing's Pool; per-ask notes refuse; Compare lines the copy up row by row); `show_in_app`'s
   Compare target (a note + one to three peers in the same wing, only when she asks, only while Variorum is in front;
   "related blocks only" on when every peer shares history); `link_versions`' Open › opens Compare; `list_my_activity`.
3. **Paging and the answer bound:** `read_note` pages with `limit` and `cursor` (a cursor alone reads 50; `limit` up to
   200); a page also ends once the ANSWER reaches about 32,000 characters — a block is never split, a single larger
   block comes alone, commit text rides in what is left, the first page carries `block_count`, the tray and versions;
   `ids_only` gives each take's `sha256` instead of its text. P-VX256-1 (the bound) is PROVISIONAL in her bundle, so
   the chapter is safest naming pages WITHOUT the numbers, as the instructions do.
4. **`sha256`:** lowercase hex SHA-256 of the take's stored UTF-8 bytes, nothing normalized; answered by add_take,
   add_takes, create_note (its blocks), import_document (one document; not a book), insert_blocks, duplicate_note,
   edit_take, restore_commit — NOT divide/merge, save_version or a book import (P-VX254-1/2). VX-357 (U+0000) is a
   known issue.
5. **`list_my_activity`:** listed for every APPROVED client with no grant (P-VX261-2); its own rows only, every
   session under its name since its current approval; a refused row never carries a title; reads join only with
   `include_reads`; the log keeps the library's last 500 acts; Activity shows "‹client› checked its recent activity".
6. **The changed tools line:** the instructions now say "Once approved, list_my_activity is always listed; other tools
   appear only for what the author has shared." The chapter must not say an approved client with nothing shared sees
   NO tools; a connection request, and a new setup waiting for her OK (VX-258), see none.
7. **Private, Seal and Own** are hers alone (R-VX184-2): no MCP road writes `ai_private_at`, `sealed_at` or `owned`;
   the AI knows them and may suggest one (the instructions' "Three acts are the author's alone…").
8. **This unit's description truths the chapter touches:** lesson 3's edit step — the before/after commits bracket
   take TEXT changes only, the "before" deduped (none when the take's latest commit already holds the words, or the
   take was blank and never committed), a no-change write does nothing, the commits stay after an undo; a suggest
   client deletes only its own comments whose words are unchanged (VX-260); book names are checked only against books
   the client can read (VX-259); deleted comments are not readable on the wire — `restore_comment` works on an id the
   client holds (VX-148).
9. **The link and its gate:** the instructions end with "The guide to this door: https://stargazing.tech/variorum/mcp";
   the build ships publicly only after the page is live (R-VX184-4). If the chapter mentions the page, it says so
   plainly; the brief's "Learn more" quotes the chapter's title "AI & the MCP door" (OBSERVATION 4).
10. **Provider neutrality (O-4):** any provider's name in the chapter stays inside `TutorialSeeder`'s ONE setup fence.

### OWED (U8a → the orchestrator)

1. **MCPSpec at the merge:** the docs line's "`MCPSession.instructions` (≤2,000 characters, …)" → "≤3,000" (R-VX184-3),
   and the instructions' one link sentence with its gate (R-VX184-4).
2. **The brief** goes to her at the closeout; the handoff leads with carrying it to her site agent, the gate first.
3. **The four OBSERVATIONS** — any follow-up is the orchestrator's call; none is a truth fix.
4. **No ticket minted, no PROVISIONAL.**


## U7 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14)

**What this run does NOT do (said first):** no product code is written or changed, before the claim or under it. A red
that needs code is RECORDED as a FINDING and reported, never fixed here, and so is a page that spills past the client's
cap (the orchestrator rules whether the budget or the limit moves). No rebuild: the window runs the `vx336-u7` product
exactly as builder B's piece 6 built it. No canon, QUESTIONS or ticket edits. Never her real store, never
`/Applications/Variorum.app`, never her USER-scope MCP registrations: the copied setup line is never run as copied; only
its key is taken, into a scratch config in the runner's scratchpad, OUTSIDE the repo, deleted at cleanup. **Never `claude
mcp list` (nor `claude mcp get`).** `castle-W1-20261013` left alone. The plan is BUILDER B's RECORD → THE STAGE WINDOW
(steps 0–13), run as written, with its kit `notes/plans/fixes/vx-336-u7-kit/`.

**Read in full before READY (never delegated):**
- this record's header, Hard rules, LIVE STATUS, Stage traffic log and Cross-run coordination;
- the U7 UNIT RECORD's LIVE STATUS, THE LIVE LEGS draft, THE ORCHESTRATOR'S RULINGS ON U7's FORKS, BUILDER A's RECORD,
  THE ORCHESTRATOR ON BUILDER A's STOP, and BUILDER B's RECORD whole (THE STAGE WINDOW included);
- THE ORCHESTRATOR ON U5's WINDOW and ON U6's WINDOW, the U5 STAGE RUN and the U6 STAGE RUN whole;
- every kit file (`turn.sh`, `tee-shim.sh`, `drop-relay.py`, `measure.py`, `verify-digests.py`, the eleven prompts);
- `Tools/stage`; `Tools/WalkKit/` (README, `guard.sh`, `click.sh`, `keys.sh`, `wl2.swift`); `Tools/ScaleFixture/`
  (`stage.sh` whole, `restore.sh`);
- `notes/SessionResiliencyProtocol.md` (the implementer rules and the addenda); the memory note walk-driving-lessons.

**The build check (READY, 2026-10-14 ~20:31 MDT):**
- **The product matches the tree.** HEAD `d4106244`. `git diff --name-only cfda547a..HEAD -- Sources App Package.swift`
  is EMPTY (since `cfda547a` only this record, the kit and `notes/plans/mcp-pane-and-docs-kickoff.md` changed). The tree is
  clean. No `.swift`, plist, pbxproj, xcstrings, entitlements, xcconfig or `Package.swift` under `Sources`, `App/Variorum` or
  the root is newer than the product's `Variorum.debug.dylib` (20:16:27).
- **The product exists:** `App/Variorum/DerivedData/vx336-u7/Build/Products/Debug/Variorum.app`, signed
  *[removed for publication]*
  `Contents/PlugIns/VariorumTests.xctest` (20:16:26), and `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`
  (20:16:27). The dylib carries both builders' words: "isn't a commit of a take on this page" ×1, "about 32,000
  characters" ×1, "ids_only" ×2, "checked its recent activity" ×1, "list_my_activity" ×1.
- **The 21 suites are real type names in the test bundle** (`nm -j` + `swift-demangle --simplified`, matched as
  `<Suite>.` on a word edge; a `-only-testing` name that matches no type runs 0 tests silently). All 21 of THE STAGE
  WINDOW's step-1 list are found, ≥ 121 symbols each (the least is `MCPSetupKeyFacesTests`). Builder A's Mac pin
  `listMyActivitySpeaksItsOwnWords` is present (51 symbols), and so is `activitySpeaksEveryActInWordsNeverAToolID` (44).

**Host and tools:** `AX: true SCREEN: true` (a compiled non-prompting probe). `walk-cap` and `walk-scroll` are compiled
into the runner's scratchpad `bin/`. `Tools/WalkKit/wl2` is present in this worktree (arm64, compiled at U5). Claude Code
**2.1.300**; `cliclick` 5.1. Free disk **64 GiB**. No simulator booted.

**Her user-scope MCP servers (names + a sha256 prefix of the sorted compact `mcpServers` JSON, never values):**
`['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as builder B's READY read and U5's and U6's windows.

**The instances and the stage at READY — NOT ours:** `Tools/stage status` → **STAGE HELD by `vx283-u1-walk`** (VX-283
U1: "CapabilityRegistryTests re-run + Open list screenshot walk on the Debug dev store, both voices, light/dark", claimed
20:15:31 for 65 min, expiring ~21:20). Its Debug instance is running: **pid 93969**,
`…/variorum-vx-283/…/DerivedData/vx283-u1/…/Variorum.app/Contents/MacOS/Variorum` (both strict guards show it). It is
vx-283's under its own claim, never touched here. Our product's shim is not running (`pgrep -lf variorum-mcp` empty).
The dev store is in that walk's use (`-wal` 20:19); the coordinator checks its restore at our GO. The strict guards must
read EMPTY at our step 0, or the window stops.

**The dev store (read-only listing at READY):** `variorum.sqlite` (14 Oct 08:50), `-wal` 20:19, `-shm` 20:17 (vx-283's
walk). Key files: `variorum-keys-b831b428ce0d67b1.json` and `variorum-keys-e86ed514dc8dab5a.json`. `Backups/` holds 57
entries; `Backups/safety-copies/` holds only `castle-W1-20261013` (left alone). **Main:** VX-306 has NOT merged
(`origin/main` `ebd16909` is ahead of this branch by notes, `.claude` and `CLAUDE.md` only), so no rebuild is owed.

**Process choices (the earlier windows' lessons applied):**
- The Mac batch FIRST, detached to its log and POLLED in the foreground (a `grep -q` loop, never `tail -f | grep -m1`).
  Then the SEAM.
- Prefs, `Backups/` and the fingerprint BEFORE `stage.sh` (its launch writes prefs). `stage.sh`'s copy is the window's
  ONLY A1.
- Every GUI act goes through `click.sh` / `keys.sh` (keys only by System Events), at least 2.6 s apart. Captures are
  region captures. `á` and `·` are never typed.
- The Debug app is quit BY BUNDLE ID. Prefs are restored by import, then re-export, diff, and delete every added key
  until 0 differ.
- Keys are redacted to their first 9 characters in every record and capture name.
- **`U7_SCRATCH` is a FRESH subdirectory of the runner's scratchpad, `…/scratchpad/u7w`.** The scratchpad is shared with
  this run's earlier runners (U6's `proj/` and its stray `default.profraw` are still there). A fresh directory keeps this
  window's `keys/`, `proj/` and configs apart from theirs, and makes the cleanup grep and the no-`mcpServers` check name
  only this window's paths. The kit's `turn.sh` reads only `$U7_SCRATCH`, so nothing in the kit changes.
- Every turn goes through the kit's `turn.sh` (prompt on STDIN, `--strict-mcp-config`), with the evidence in the
  gitignored `notes/plans/vx336-screens/u7/`.
- **The cap is read from BYTES:** `measure.py` compares the server's answer from the tee with the tool_result the model
  received from the stream-json. The client's own wording never decides it.

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the coordinator's GO and its exact line) |
| 0 | guards; the claim from the GO's line; HEAD at the GO | DONE — the GO from oct13coordinator at 20:43. Its checks: vx-283's walk released at 20:41 with the dev store restored and verified; no instances by the strict forms; no simulators; 64 GiB free; dev `safety-copies` holds only castle-W1. The orchestrator's note: the U8a implementer is PAUSED at `f420f52e` (record-only), so no source moves before our RELEASE. **HEAD at the GO `f420f52e`**; `git diff --name-only cfda547a..HEAD -- Sources App Package.swift` still EMPTY. Pre-claim: `guard.sh --author` OK (idle 262 s); both strict guards and the loose form EMPTY; 0 simulators booted; `stage status` → held by `coord-for-vx336` ("GO pending: vx336-u7"). The exact line run: `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u7 --reason "VX-336 U7: 21-suite Mac batch, SEAM, then ScaleFixture A1 + real-client MCP live round on the Debug dev store" --minutes 95` → **STAGE RELEASED (was 'coord-for-vx336') · STAGE CLAIMED by 'vx336-u7' for 95 min at 20:44:51 MDT** (expires 22:19:51) |
| 1 | the Mac batch (21 suites on `vx336-u7`, `test-without-building`, detached + polled) | DONE (20:44:59 → 20:45:39) — from `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u7 -resultBundlePath ../../notes/plans/vx336-screens/u7/u7-batch.xcresult` + the 21 `-only-testing:VariorumTests/<Suite>`, detached to `u7/logs/u7-batch.log`, polled in the foreground. **"✔ Test run with 176 tests in 21 suites passed after 11.903 seconds" · `** TEST EXECUTE SUCCEEDED **`.** The result bundle (`xcresulttool get test-results summary`): **result Passed — 176 total · 173 passed · 0 failed · 3 skipped · 0 expected failures**, 21 suites seen (per-test results in `u7/u7-batch-tests.json`). The 3 skips are EXACTLY the plan's three gated capture harnesses: `MCPGrantSheetU2CaptureTests`, `MCPPaneTabsCaptureTests`, `TutorialMCPChapterCaptureTests` (one test each). **Builder A's Mac pin `MCPWingFacesTests.listMyActivitySpeaksItsOwnWords` ✔ — its FIRST run, green on the final tree** (its red-on-old is by construction, builder A's record), and `activitySpeaksEveryActInWordsNeverAToolID` ✔ (it walks `list_my_activity`). No «Issues recorded without an associated test» this run (0 in the log). **Zero reds — no finding.** The test host exited: both strict guards and the loose form EMPTY after the run |
| SEAM | the batch's counts recorded, committed, pushed; the claim KEPT; turn ended "SEAM" | DONE (20:46) — the claim `vx336-u7` held (~2 of 95 min used; expires 22:19:51); no Variorum instance; nothing launched; no prefs export, no A1, no fixture yet (they wait for the coordinator's word, "continue" or "release for X") |
| 2 | prefs export, `Backups/` listing, the fingerprint BEFORE (before the fixture's launch) | DONE (20:46:49, after the coordinator's "continue" at the SEAM) — every instance guard EMPTY first (the batch's test host gone). Prefs exported: **1,602 keys** (`variorum.whatsNew.lastVersion` 0.9.6 = the product's; `appearanceChoice` system) → `u7/prefs-pre.plist` — the restore target. `Backups/` **57 entries** (`u7/backups-pre.txt`); the store listing `u7/store-listing-pre.txt` (`variorum.sqlite` 08:50, `-wal` 09:17 — vx-283's restore kept the A1's stamps — `-shm` 20:45, the two key files); `safety-copies/` holds only `castle-W1-20261013`. Her user-scope servers BEFORE `['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME (`u7/userscope-pre.txt`). **The clipboard SAVED: 1,686 bytes, not this window's** (`$U7_SCRATCH/clip-before.txt`, never read or recorded here) — restored at cleanup |
| 3 | `stage.sh notes=10,long=300` — the ONE A1 (cmp + sha256 recorded) and the launch; the mint polled | DONE (20:47:00) — `guard.sh --author` OK (idle 394 s), both strict guards EMPTY; from the repo root `Tools/ScaleFixture/stage.sh notes=10,long=300 "$PWD/App/Variorum/DerivedData/vx336-u7"` (`u7/logs/stage-sh.log`) → **"A1 prestage copy (verified): …/Variorum-dev/Backups/safety-copies/`scale-prestage-20261015T024700Z`"** (`u7/a1-path.txt`) — THE WINDOW'S ONLY A1: five files, each `cmp`-verified by the script; their sha256 prefixes (`u7/store-hash-pre.txt`) sqlite `c17923414b2e` · wal `7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890` — **EQUAL to U5's and U6's A1 sets** (the store unchanged since); castle-W1 untouched. Then `open -n --env VARIORUM_SCALE_FIXTURE=notes=10,long=300` → **pid 15806** (`…/vx336-u7/…/Variorum.app/Contents/MacOS/Variorum`; the env read back from `ps -wwE`). **The mint:** the plan's `log show` poll found NO "ScaleFixture:" line in 2.5 min — the predicate matched only `log`'s own command lines, and the app's `NSLog` line never surfaced in `log show` (process, pid and `--info --debug` forms all empty) — so **the plan's fallback: the Library shows "scale fixture · long note" `#scale-fixture`, "edited today 8:47 PM"** (`live/s/01-library`); its 300 blocks are L2a's `block_count` to prove. *Machinery note:* `log show` does not surface this build's `NSLog` lines here; the Library capture is the reliable mint check |
| 4 | connect (the Claude Code tab key → `$U7_SCRATCH/keys/u7.key`), the bind turn, THE GRANT Home · Edit · Always | DONE (20:47–20:55) — the app up from `stage.sh`: **Study, light, the Bookcase; no What's New sheet, no lock screen** (`live/s/00-launch`). App menu ▸ MCP Settings… (by AX, through `keys.sh`) → the Settings window 748×552 at (200,33): **the switch ON, "running · socket in the app container · serves while Variorum is open"**; Clients: claude-code "last seen 4 days ago · 3 grants", u3-walk, u2-walk, u1-walk (`02-mcp-pane`). Connect ▸ **Claude Code** ▸ the copy icon (`03-connect`, `04-copied`) → from the clipboard ONLY the key (**`vmk2_clau…`**, 60 chars, `vmk2_claude-code_` prefix) into `$U7_SCRATCH/keys/u7.key` (dir 700, file 600); never the copied line, never `-s local`, never her user scope; **the clipboard emptied at once** (0 bytes). **The bind turn** (`T bind mcp__variorum-dev__list_books < prompts/bind.txt`, 20:52, `u7/bind.jsonl`, the tee `tee/bind-*`): `variorum-dev` "connected" (dynamic); **`tools/list` 62 tools, `list_my_activity` and `read_note` among them**; the answer "list_books lists 1 book ("o ladrão de raios", with 6 notes)". **Activity: "claude-code connected with a new setup, now bound to its name"** then "claude-code listed books" — ZERO clicks, the BIND arm (`05-bind-activity`). **THE GRANT:** Clients ▸ claude-code ▸ Change… → "Grant access — claude-code" (A book · the field guide · Read, `06-change`) → **A wing · Home** ("everything in Home except your daily Journal and anything Private, which always ask", `07-grant-wing`) → **Edit** · Always → **"Grant edit in “Home” always, including notes added later"** (`08-grant-sheet-edit`) → Shared with AI: **"Home · wing · claude-code · read, suggest, write new and edit · always"** atop claude-code's three o-ladrão-de-raios grants (`09-grant-row`, `10-shared-with-ai`) |
| 5 | L1 — VX-254: a write proves its words (create_note · edit_take · add_take "" · duplicate_note; `verify-digests.py L1`) | **PROVEN — the product byte-true; the client NFC-normalized the NFD string before the wire (a client fact, recorded)** (20:54:09–20:55:25; `u7/L1.jsonl`, the wire `tee/L1-{in,out}.jsonl`, `L1-measure.txt`, `L1-verify.txt`). ONE turn (model `claude-fable-5`, 9 turns): python wrote `src.json` and printed the six digests; `create_note(wing "", "vx336 u7 digests", blocks)` → **keys `block_ids`, `blocks` (six records, each take `{sha256, take_id}`), `note_id` `42488E5C…`, `tag_ids` []**; `edit_take` (the model read "block 1" 0-based, so it edited block 2 "beliscou" — harmless) → **`changed: true`, `before_commit_id` `28208F3F…`, `after_commit_id` `CE3211EA…`, `sha256` `fbba9b40…911c`**; `add_take(block 3, "")` → **`sha256` `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`** exactly; `duplicate_note` → six records with `source_block_id`, landed in the Pool of Home (`4A03B86C…`). **THE BYTE TRUTH (`verify-digests.py L1`): "no mismatch · 15 checked · 15 equal"** (6 + the edit + the blank + 7 copy takes) — every answered `sha256` is the SHA-256 of the exact bytes the client sent, and every copy's digest is its source take's as it then stood (block 2's copy the EDITED digest; block 3's copy both takes in fan order). Every call INLINE (1,786 · 355 · 225 · 2,348 characters). **The client's road:** the model's table MATCH ×6, **the control "beliscáu" MISMATCH** (`dce72ca8…` vs `1ed8e723…`), the edit MATCH, the blank MATCH, the duplicate all MATCH. **The NFD note (read from the wire and the stream, not the model's words):** the "café (NFD)" string reached the wire as **`café` — PRECOMPOSED (NFC)**, and so did the Bash command the model ran (U+0301 ×0, U+00E9 ×1; `src.json` holds `0xe9`) — the decomposed form was normalized on the CLIENT's side before python ran (whether Claude Code's prompt intake or the model's transcription is not separable from here), so python's digest and the product's agree on the NFC bytes (`dd83ce5e…`; the NFD digest would be `f8f25eac…`). The NFD byte case was therefore NOT exercised end to end by this client — the headless P-254 pins (`MCPWriteDigestServerTests`) remain its evidence; not a product red. **Her face:** ⌘K "vx336 u7 digests" lists TWO notes (the note and its copy — `12-L1-palette`); Write of the first: **"“Curly” quotes — and an em dash" / "Edited — with an em dash." / "café (NFD)" wearing ⑂2 / "🦊 an emoji" / "two⏎lines" (one block — "block 1/6") / "a trailing space"**, in no book, edited today 8:54 PM (`13-L1-write`). *Observed:* the Library's edited-newest list (open since before the turn) did not show the two new notes at its top (`11-L1-library`) — re-checked at L4 |
| 6 | L2a — VX-256: the long note in pages of 50 (`measure.py L2a`); Activity's coalesced line | **PROVEN** (20:57:30–20:58:26; `u7/L2a.jsonl`, `tee/L2a-*`, `L2a-measure.txt`). ONE turn: `list_notes(wing_id "")` → "scale fixture · long note" (`3D48F858…`); `read_note(limit 50)` + five cursor pages. **From the wire (the runner's own count, not the model's):** **6 pages × 50 = 300 blocks = `block_count` 300 (first page only), 300 DISTINCT block ids, 300 takes**, `next_cursor` on pages 1–5 and none on page 6; page keys `block_count` (first) · `blocks` · `books` · `next_cursor` · `note_id` · `title`. **Every `read_note` INLINE** (the model received exactly the server's text): 18,164 · 12,455 · 12,084 · 12,509 · 12,098 · 12,304 characters; context growth ≈ 9.2k · 7.7k · 7.6k · 7.8k · 7.6k · 7.6k tokens a page. **The fixture is lighter than the plan predicted:** the whole note's take text is **16,235 characters** (page 1 7,597, the rest 1.5–1.9k) — the ≈ 105k the plan named is the unpaged answer's size with ids (here ≈ 80k across the six pages), so the 32,000 budget never bound here; the cap is L2b's. The model's report agrees (6 pages, 50 each, 300, 300 distinct). **Her face:** Settings ▸ MCP ▸ Activity — **"claude-code read “scale fixture · long note” (6 times)"** — the six page reads coalesced to ONE line (F4), above "claude-code listed a wing's notes" and L1's three lines ("duplicated", "added a take to", "edited" “vx336 u7 digests”) (`14-L2a-activity`; FOR VX-234) |
| 7 | L2b — THE CAP: sherlock's "The Red-Headed League" at limit 200, 50, and whole (each measured alone; 150/100 if 200 spills) | **DONE — THE CAP MEASURED: the budget-ended page DOES NOT arrive inline. A FINDING for the orchestrator (P-VX256-1's numbers), not fixed here** (20:59–21:03:27; one read per turn, each measured alone from BYTES — the tee's server answer against the tool_result in the stream-json; `u7/L2b-*.jsonl`, `tee/L2b-*`, `L2b-*-measure.txt`). The note: sherlock ▸ "The Red-Headed League" (`829C81B9…`), **`block_count` 215, 49,007 characters of take text**. Claude Code 2.1.300, model `claude-fable-5`, `MAX_MCP_OUTPUT_TOKENS` UNSET (the default holds). **The measurements:**<br>• **limit 200 → the page ENDED BY THE BUDGET at 161 blocks, take text 31,993 characters (≤ 32,000 ✔), `next_cursor` present; the answer 65,807 characters → NOT-INLINE.** The model received a 1,603-character notice instead: *"Error: result (65,807 characters across 1 line) exceeds maximum allowed tokens. Output has been saved to <home>/.claude/projects/…-u7w-proj/<session>/tool-results/mcp-variorum-dev-read_note-<n>.txt. Format: Plain text"* + slice/grep advice; context +865 tokens; the model reported "zero of its actual content reached my context" and could answer nothing about the page.<br>• **limit 150 → 150 blocks (limit-ended), take text 29,213; answer 60,750 characters → NOT-INLINE** (the same notice).<br>• **limit 125 → 125 blocks, take text 24,630; answer 50,984 characters → NOT-INLINE** (an extra probe beyond the plan's two, to bracket the threshold).<br>• **limit 100 → 100 blocks, take text 21,895; answer 43,062 characters → INLINE** (context +20,946 tokens ≈ 2.06 characters a token).<br>• **limit 50 → 50 blocks, take text 10,573; answer 21,370 characters → INLINE** (context +10,564 tokens); the model read it whole: `block_count` 215, `next_cursor` present, first block "I had called upon my", last "'Oh, merely a couple of".<br>• **the whole read (`with_ids`, unpaged — the "before") → 215 blocks, 49,007 take text; answer 93,799 characters → NOT-INLINE** (the same notice).<br>**So the client's inline cap lies between 43,062 characters (inline) and 50,984 (spilled)** for prose-with-ids pages (≈ 2.06 characters a token by the inline pages' growth — consistent with the recalled 25,000-token default). **The answer's size is ≈ 2.0–2.1× its take text** (the ids, the records and the JSON around each block — ≈ 210–216 characters a block here: (65,807 − 31,993) / 161 = 210; (43,062 − 21,895) / 100 = 212; (21,370 − 10,573) / 50 = 216), so **a page whose take text reaches the 32,000 budget is ≈ 64–66k characters — past the cap by ~30%**; and limit 125 spilled at only 24,630 characters of text. With the shipped numbers (50 default · 200 max · 32,000 characters), the default page is safe here and a client that asks `limit` ≥ ~110 on prose like this meets the file notice. **For the orchestrator (OWED 1 / OWED 5): the budget, and/or the limit's maximum, must move for a budget-ended page to arrive inline** — e.g. a take-text budget ≈ 20,000 (≈ 43k-character answers at this note's ratio) or an ANSWER-size budget ≈ 40,000 characters; the ruling is yours, before the merge. Each saved-to-file answer left a file under the scratch project's `~/.claude/projects/…-u7w-proj/` (note text only, no key; cleaned at step 13) |
| 8 | L3 — VX-256: `ids_only` pages of 100 verified (`verify-digests.py L3-100 --texts L2a`); then the 200-block ids-only cap | **PROVEN at limit 100 · the 200-block ids-only page NOT-INLINE (the cap's second probe — a FINDING with L2b's)** (21:04–21:05:41; `u7/L3-*.jsonl`, `tee/L3-*`, `L3-*-measure.txt`, `L3-100-verify.txt`). **L3-100, ONE turn:** `read_note(ids_only, limit 100)` + two cursor pages → **3 pages × 100 = 300 takes, all 300 with `sha256`, 0 with text** (each take `{chosen, sha256, take_id}` — read from the wire), `block_count` 300 on the first, no `next_cursor` on the third; **every page INLINE** (27,487 · 27,513 · 27,308 characters; context ≈ 18.2k · 18.5k · 18.2k tokens a page — ≈ 1.5 characters a token, UUIDs and hex tokenize heavily); then `read_note(limit 26)` (12,696 characters, inline) and the model's three python spot checks (blocks 1, 2, 26) **MATCH ×3**. **THE BYTE TRUTH (`verify-digests.py L3-100 --texts L2a`): "no mismatch · 300 checked · 300 equal"** — every ids-only `sha256` is the SHA-256 of the text L2a read for that take. **L3-200, the ids-only cap:** ONE read, `ids_only` limit 200 → 200 blocks, `block_count` 300, `next_cursor` present; **the answer 54,731 characters → NOT-INLINE** (the same "exceeds maximum allowed tokens … saved to …/tool-results/…" notice, 1,603 characters reached the model). An ids-only page costs ≈ 274 characters a block, so at ≈ 1.5 characters a token the client's cap (~25k tokens ≈ 37–38k characters of ids) is reached near **≈ 135 blocks** (an estimate from the measured ratio, not a probe) — **`limit`'s maximum 200 spills an ids-only page.** For the orchestrator with L2b: the limit's maximum and/or an answer-size bound must move (ids dominate an ids-only page; the take-text budget never counts them) |
| 9 | L4 — VX-261: a dropped call (the relay holds create_note's answer; the turn killed) → a fresh session's `list_my_activity` | **PROVEN** (21:06:14–21:07:47; `u7/L4a.jsonl`, `L4b.jsonl`, `tee/L4a-*`, `tee/L4b-*`, `logs/L4a.turn.txt`, `L4a/L4b-measure.txt`). **Turn A (detached, through `drop-relay.py`):** `create_note(wing "", "vx336 u7 dropped", text "This answer never arrives.")` reached the wire as request id 2; the relay HELD its answer (`tee/L4a.HELD`: "held the answer to request id 2 at 21:06:22", 8 s after launch) and the runner `pkill -TERM -f "keys/cfg-L4a.json"` at once (the turn exit 143); **no turn, relay or shim of ours left** (plain `pgrep` of `cfg-L4a.json`, `drop-relay.py`, the product's `variorum-mcp`: all empty). **On the wire the act LANDED:** `tee/L4a-out.jsonl` holds the answer `{"block_ids":["DAA57CF3…"],"blocks":[…{"sha256":"62e2d06d…","take_id":"3B50B77A…"}],"note_id":"A89F562E-4555-4400-98A1-C2D7AAD8A86B","tag_ids":[]}`; **the client never heard it** — the stream's only tool_result is "Connection closed" (17 characters; `measure.py` NOT-INLINE) and the stream has no result line. **Turn B, a FRESH session under the same name:** `list_my_activity()` (no arguments) → `{"acts":[…]}`, 17 rows newest first, NO `next_cursor`, **NO read rows** (`include_reads` off), the newest EXACTLY **`{"at":"2026-10-15T03:06:22.763Z","outcome":"allowed","target_id":"","target_kind":"wing","title":"vx336 u7 dropped","tool":"create_note"}`**, then L1's four (`duplicate_note` note `42488E5C…` · `add_take` block `85E0EBBD…` · `edit_take` take `326439BA…` · `create_note` wing "" — each titled "vx336 u7 digests"), then claude-code's Oct 9–10 acts (its approval predates this window — the re-bound setup key is not a re-approval, P-VX261-1's era), the two REFUSED rows among them (`create_section` book `E25D6F49…`, `edit_take` take `B060A7B7…`) **with NO title**; `list_notes(wing "")` → the model gave **"vx336 u7 dropped" `A89F562E-4555-4400-98A1-C2D7AAD8A86B` — EQUAL to the held answer's `note_id`**, and told the two "vx336 u7 digests" rows apart by their act times. Both calls INLINE (2,765 · 8,688 characters). **Her face:** Activity **"claude-code made the note “vx336 u7 dropped”"** and **"claude-code checked its recent activity"** (Study, `15-L4-activity`); the Library: **"vx336 u7 dropped" edited today 9:06 PM** atop the two "vx336 u7 digests" (8:54 PM) and the fixture (`16-L4-library`). *Observed (L1's row):* the Library list that was OPEN across L1's turn did not show L1's two new notes until the Library was re-entered (now it does) — a live-refresh question outside every type this run changed; for the orchestrator's eye |
| 10 | L5 — VX-261: a refused read, then `list_my_activity` with and without reads; Activity in Study | **PROVEN** (21:09:01–21:09:44; `u7/L5.jsonl`, `tee/L5-*`, `L5-measure.txt`). ONE turn, every call INLINE: (1) `read_note("00000000-0000-4000-8000-000000000000")` → **`isError: true`, EXACTLY "That note isn't shared with this client, or doesn't exist. The author can share it from Variorum ▸ Settings ▸ MCP."** (114 characters — the ONE not-shared shape); (2) `list_my_activity(include_reads: true, limit: 30)` → `{"acts": [30 rows], "next_cursor": …}` newest first: **the refused read EXACTLY `{"at":"2026-10-15T03:09:01.349Z","outcome":"refused","target_id":"00000000-0000-4000-8000-000000000000","target_kind":"note","tool":"read_note"}` — NO title**, then L4b's `list_notes` (wing ""), L4a's `create_note` "vx336 u7 dropped", L3's reads of "scale fixture · long note" (titled) and `list_notes`, and on back into L2's (the 30-row page ends there; `next_cursor` offered); the page's tools are only `create_note`, `list_books`, `list_notes`, `read_note` — **never a `list_my_activity` row, never a connection row**; (3) `list_my_activity()` → 17 rows, no `next_cursor`, **no read rows** (the same set as L4b's). **Her face, Study:** Activity **"claude-code checked its recent activity (2 times)"** atop **"claude-code was refused reading a note"** (muted), "claude-code listed a wing's notes", L4b's "claude-code checked its recent activity", "claude-code made the note “vx336 u7 dropped”" (`17-L5-activity`) |
| 11 | the Terminal pass (Activity in Terminal) → back to Study | **PROVEN** (21:10–21:11; captures `live/t/`, `live/s/18`) — Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control took — `t/01-theme-terminal`) → Settings ▸ mcp ▸ Activity in Terminal (monospace pane names, the green accent): **"claude-code checked its recent activity (2 times)"** · "claude-code was refused reading a note" (muted) · "claude-code listed a wing's notes" · "claude-code checked its recent activity" · "claude-code made the note “vx336 u7 dropped”" (`t/02-activity-terminal`). Theme back to **Study** (General: Theme Study selected, Appearance follow system, palette Default — `s/18-back-study`) |
| 12 | L6 — NOT in this window (the plan: builder A's headless P-261-6 is its evidence) | NOT IN THIS WINDOW (by the plan) |
| 13 | cleanup → quit by bundle id, the key grep 0 and `keys/` deleted, the clipboard emptied, no `mcpServers` for the scratch project, fingerprint SAME, prefs 0 differ, `restore.sh` cmp-SAME + sha256 set equal, `Backups/` unchanged, castle-W1 untouched; release; THE RESULT LINE | DONE (21:11:40–21:12:37) — **the Debug app quit BY BUNDLE ID** (`tell application id "io.lduarte.Variorum.debug" to quit`): both strict guards and the loose form EMPTY; no `variorum-mcp` shim, no turn (`cfg-L*`), no relay of ours; her `/Applications` app never running. **The key** (read whole from `keys/u7.key`, 60 characters) grepped over `$U`, `~/.claude.json`, `~/.claude/projects/` (the whole tree), `notes/` + `Tools/`, and the scratchpad outside `keys/` → **0 files** (only `keys/` held it: `u7.key` + the 15 `cfg-*.json`); then **`keys/` DELETED**. **The clipboard RESTORED** to the 1,686 bytes it held before the window (`pbpaste | cmp` SAME), the saved copy deleted. **No `-s local` registration was ever made:** `~/.claude.json` has NO `projects` entry for `$U7_SCRATCH/proj` (read-only `python3 -I`; never `claude mcp get`/`list`). The five saved-to-file tool results (L2b-200, -150, -125, -whole and L3-200; note text only, no key) under the scratch project's `~/.claude/projects/…-u7w-proj/` deleted (5 files; 0 left). **Her user-scope servers AFTER `['linear-server', 'variorum']`, `bc64543e2f4e8e58` — SAME** (`u7/userscope-post.txt`). **Prefs:** the window added 1 key (`currentBlock.<the L1 copy>`) and changed 5 (`openNotes.remembered.ids`/`.recency`, `variorum.backup.log`, `IdleCommitSweepMark.Variorum-dev`, the Settings window frame) (`u7/prefs-window-diff.txt`) → `defaults import prefs-pre.plist` + `defaults delete` of the 1 → re-export **1,602 keys, 0 added · 0 removed · 0 changed** (`u7/prefs-post.plist`). **The dev store:** `Tools/ScaleFixture/restore.sh …/scale-prestage-20261015T024700Z` → **"Restored (verified)"** (`u7/logs/restore.log`), a second `cmp` of all five files **SAME**, the sha256 set **EQUAL** to the A1's (`store-hash-restored.txt` = `store-hash-pre.txt`) — Standard, unlocked, Study, claude-code's pre-window binding and its three grants back (the Home edit grant, the fixture, L1's notes and copy, the dropped note — every window write — gone with it). `Backups/` names **UNCHANGED** (57 entries); `safety-copies/` holds `castle-W1-20261013` (untouched, its Oct 13 stamps) + this window's A1. 0 simulators booted; no stray `default.profraw` in the tree (the scratch project's own deleted); the tree clean; 62 GiB free. **RELEASED 21:12:37 MDT** (`Tools/stage release --who vx336-u7` → STAGE RELEASED (was 'vx336-u7'); `status` → STAGE FREE), ~28 of the 95 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx336-u7` 20:44:51–21:12:37 MDT, RELEASED (~28 of 95 min); the batch first, the SEAM, then the coordinator's "continue".
- **THE CAP (first): the budget-ended page does NOT arrive inline — a FINDING for P-VX256-1's numbers.** On "The Red-Headed League" (215 blocks, 49,007 characters of text), Claude Code 2.1.300 (`MAX_MCP_OUTPUT_TOKENS` unset): **limit 200 → the page ended by the budget at 161 blocks (take text 31,993 ≤ 32,000), a 65,807-character answer → saved to a file**, the model got a 1,603-character "exceeds maximum allowed tokens … saved to …/tool-results/…" notice and nothing of the page. limit 150 (60,750 characters) and 125 (50,984) → saved to file; **limit 100 (43,062) and 50 (21,370) → INLINE**; the unpaged whole (93,799) → saved to file. **The inline cap sits between 43,062 and 50,984 characters** for prose pages (≈ 2.06 characters a token); an answer is ≈ 2× its take text (≈ 210 characters a block of ids and records), so a budget-ended page is ≈ 64–66k characters. **The 200-block `ids_only` page (54,731 characters) → saved to file**; 100-block ids-only pages (≈ 27.5k characters, ≈ 18.2k tokens) inline. The budget and/or the limit's maximum must move before the merge — the orchestrator's ruling.
- **The Mac batch (21 suites, `vx336-u7`):** 176 tests — 173 passed · 0 failed · 3 gated capture skips; `** TEST EXECUTE SUCCEEDED **`; `listMyActivitySpeaksItsOwnWords` ✔ (its first run), `activitySpeaksEveryActInWordsNeverAToolID` ✔.
- **L1 PROVEN** (VX-254): every write's `sha256` is the SHA-256 of the bytes sent — **15 checked · 15 equal** from the wire (create_note ×6, edit_take, add_take "" = `e3b0c442…b855`, duplicate_note ×7 = its sources'); the control mismatches; all inline. The client NFC-normalized the NFD é before the wire (a client fact; the headless pins stay the NFD evidence).
- **L2a PROVEN** (VX-256): 6 pages × 50 = 300 = `block_count`, 300 distinct ids, every page inline (12–18k characters); Activity coalesces to "claude-code read “scale fixture · long note” (6 times)".
- **L3 PROVEN at 100**: 3 ids-only pages, 300 takes all with `sha256`, 0 with text, **300 checked · 300 equal** against L2a's texts, inline; the 200-block ids-only page NOT inline (the cap, above).
- **L4 PROVEN** (VX-261): the relay held `create_note`'s answer and the turn was killed (the client saw only "Connection closed"); a fresh session's `list_my_activity` named `create_note · allowed · wing "" · "vx336 u7 dropped"` newest, no reads, and `list_notes` found the held `note_id` `A89F562E…`.
- **L5 PROVEN**: the made-up note answers the ONE not-shared sentence; listed `refused · note · 00000000-…` with NO title; reads only with `include_reads`, never a `list_my_activity` or connection row; Activity "claude-code checked its recent activity (2 times)" in Study AND Terminal.
- **Posture:** dev store cmp-SAME vs A1 (sha256 set equal), prefs 0 differ (1,602 keys), user-scope fingerprint SAME (`bc64543e2f4e8e58`), Standard/unlocked, Study, castle-W1 untouched, `Backups/` unchanged, no `-s local` registration, the whole-key grep 0, `keys/` deleted, the clipboard restored, no instance left, 0 simulators booted.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T024700Z`.

**Noticed, not fixed (no product change under the claim):**
1. **THE CAP** (above) — the window's key fact, for the orchestrator's ruling on the budget and the limit's maximum (builder B's OWED 1).
2. **The client normalized NFD → NFC** before any MCP call (the Bash command the model ran already held U+00E9), so a real Claude Code client cannot be relied on to send decomposed text through a prompt; the digest is byte-true for what was SENT.
3. **The open Library list did not show L1's two wire-made notes** until the Library was re-entered (the ⌘K palette found both at once; at L4 the list showed all three). A live-refresh question outside every type this run changed — for the orchestrator's eye (Suspected).
4. **The fixture's mint line is not visible to `log show`** on this build (the `NSLog` "ScaleFixture: minted …" never surfaced under any predicate); the Library capture is the reliable mint check — a machinery note for later runners.
5. Machinery: the L1 prompt's "block 1" was read 0-based by the model (it edited block 2) — harmless; `measure.py` and `verify-digests.py` read every verdict from bytes.

### THE ORCHESTRATOR ON U8a (2026-10-14 ~22:50 MDT)

- **Verified:** the tree is clean at `593008d3`; the orchestrator re-ran the advice, label-form, comment-words and
  book-name pin suites headless (22 green) and READ the instructions whole (THE INSTRUCTIONS AS BUILT). They are calm,
  provider-neutral and number-free apart from the version token, with organization first-class, the three acts named as
  hers, recovery by `list_my_activity`, and the one link last. No PROVISIONAL.
- **The four observations stay recorded, not changed:** `edit_take` doesn't say a blank text is refused; `create_book`
  doesn't mention the name check; 31 characters remain under the bound; the brief quotes the chapter's title (U8b keeps
  it or updates the brief in the same unit).
- **Next: U8b** (a fresh `opus-implementer`): the field guide's MCP chapter, built against U8a's OWED FOR U8b, plus THE STAGE
  WINDOW (`vx336-u8`), which carries U7c's RE-PROBE.

## U8b UNIT RECORD — the field guide's MCP chapter + U8's stage window plan (VX-197; opus-implementer, from 2026-10-14 ~23:00 MDT)

**NOT DONE (said first, at READY):** the chapter's Mac pins have never RUN — their red run on `vx336-u8-red` and
their green run in the batch, the both-voices walk on a fresh guide, the real client reading the advice and answering
the organization ask, and U7c's re-probe are all THE STAGE WINDOW's (claim `vx336-u8`, below; PENDING). No
`xcodebuild test`, no launch, no stage claim, no store touched; no `Sources/` line changed; no canon, QUESTIONS, ticket
or stargazing-brief edit (the title is unchanged); no subagent. This session is past ~500k by the harness count: a
FRESH stage runner takes the window.

**Read in full in this session (never delegated):** this record's header, Hard rules (incl. never `claude mcp list`),
LIVE STATUS, Stage traffic log, Her rulings; the U8 BRIEF (items 1 and 4, the SPLIT, the U7 carries); the U8a UNIT
RECORD whole (THE INSTRUCTIONS AS BUILT, THE DESCRIPTIONS AS BUILT, OWED FOR U8b); THE ORCHESTRATOR ON U8a; the U7c
UNIT RECORD's THE RE-PROBE and THE ORCHESTRATOR ON U7c; the U7 STAGE RUN whole and builder B's STAGE WINDOW (the
worked form); the U6 window's A1 and sherlock steps; `notes/plans/mcp-pane-and-docs-kickoff.md` ("U7: the AI's docs",
HER ADDITIONS incl. the label split and R-VX184-2); `notes/MCPSpec.md` whole; AppSpec §12's FIRST OPEN and COMMIT
VOCABULARY lines; R-13s-22 (no em dashes, no emoji; quoted-UI dashes legal); the memory note no-shouty-caps-in-copy;
`notes/SessionResiliencyProtocol.md`'s implementer section and addenda. Code: `TutorialSeeder.swift` (the MCP chapter
whole, the plan, the restore door's discovery and seed, its neighbours' voice — books chapter, privacy chapter);
`TutorialMCPChapterTests.swift` and `TutorialMCPChapterCaptureTests.swift` whole; the guide-wide sweeps in
`TutorialCurrencyTests` (no Canvas, the practice word, the indent pair, the star row) and `TutorialBooksChapterTests`
(no hidden Bookcase door); `MCPProviderNeutralityTests` (the O-4 fence: one in the seeder); `MCPPaneCopy` (the
setup's words, `clientBoundary` — VX-246's F-1 parity — `keyLine`, the rebind row, the activity line), `MCPSetupMenu`
(the code block and its copy icon), `MCPPane` (tabs, Waiting and requests above them, Connect's section title),
the registry's MCP verbs, `MCPToolCatalog` (every description the chapter leans on), `MCPWriteTools.aiLabel`,
`MCPWriteTools+CommentDelete` / `Operations+MCPCommentAuthors` (VX-260), `editTakeUnderInsurance` /
`labelTakeForClient`, `setBookRule` + `MCPBookFacts.matchesWaitWords`, `duplicateNoteForClient`, `MCPNavigator`'s
Compare road, `MCPSharedRowsRulesTests` / `BookPanelMCPMarksTests` (the icon's hosts, VX-330's `markedNote`),
`ShellActions.restoreTutorial` and its confirm. VX-204's and VX-209's guide changes live in `ProtectionCopy`
(the privacy chapter) — this unit never touches that file or chapter.

### LIVE STATUS — U8b's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | read-in; this record | DONE (`9060e968`) |
| 1 | the chapter's truth pins on the OLD seed (Tests only — `TutorialMCPChapterTests`), committed ahead of the chapter | DONE (`c29a2b8e`; compile fixes `60aa6ba4`, `c7fa39c4`) — WRITTEN; they run only on the Mac, so their red run on the old seed rides the window (step 1b, on the red product of THIS commit); the list is THE PINS below (written at piece 5) |
| 2 | the red product `DerivedData/vx336-u8-red` (`build-for-testing` from piece 1's commit) | DONE — built from `c7fa39c4` (the pins + the OLD seed; two earlier builds failed on the pins themselves — `60aa6ba4` fixed the type-checker's limit, `c7fa39c4` a duplicate `stack` in lesson three): **TEST BUILD SUCCEEDED**, zero `error:`, no warning in the pin file (`u8/logs/build-red.log`); `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun` present. Never launched; its one use is the window's red run |
| 3 | the chapter (`TutorialSeeder`'s MCP lessons) | DONE (`f887d8c7`) — lessons 1, 2, 3, 6 and 7 rewritten (4 and 5 byte-unchanged); a scratch containment check (the seven lessons' literals compiled with every `text.contains` expectation of the suite, constants substituted) passed every expectation on the new text and failed 37 on the old — the predicted red set, read before the Mac run that decides it |
| 4 | the green product `DerivedData/vx336-u8`; the headless guards (`MCPProviderNeutralityTests`, the core/MCP targets untouched) | DONE — THE PRODUCTS below: `vx336-u8` from `f887d8c7`, **TEST BUILD SUCCEEDED**, all 66 batch suites found in its bundle; `MCPProviderNeutralityTests` **2 tests in 1 suite passed** |
| 5 | THE STAGE WINDOW plan (claim `vx336-u8`), the chapter's text whole, FOR VX-234, PROVISIONALs, OWED (the re-seed note) → READY | DONE (this commit) — READY for a fresh runner; the kit gains `prompts/U8-org.txt` and `instructions.py` (dry-run on U7's tee) |

### THE PINS (piece 1) — `App/Variorum/VariorumTests/TutorialMCPChapterTests.swift`, written AHEAD of the chapter

**Mac-only** (the seed is an app type), so the red run on the old seed rides the window (step 1b, on `vx336-u8-red`).
**`@testable import VariorumMCP`** replaces `import VariorumMCP` in this one file, so a claim whose truth lives inside
the wire is tied to the catalog itself (a tool's rung and description, `aiLabel`, `MCPSession.instructions`,
`MCPBookFacts.matchesWaitWords`) — W-UX-14's `MCPToolFacts` tie made direct, zero `Sources/` change. The behaviour
behind each tie is the headless suite the pin names. Every NEW sentence is pinned by its words (RED on the old seed);
every CHANGED pinned sentence is a JUSTIFIED EDIT commented in place with what it said before:

- **The chapter test** — JUSTIFIED EDIT: the gathering guard lets lesson 7 say "gathering" (VX-185's icon on
  gatherings); NEW guard: no em dash outside a quoted surface (R-13s-22; `PrivateMarkCopy.rowWords` the one quoted
  dash) — red on old lessons 1 and 6.
- **Lesson 1** — JUSTIFIED EDIT: "Your grants stay on this Mac and never sync to your other devices." (the dash).
- **Lesson 2** — JUSTIFIED EDIT: "press Copy setup command" now ABSENT, and the code block's copy icon named (truth:
  `MCPSetupCodeBlock.copySymbol == "doc.on.doc"`, the pane declares `.mcpCopySetupCommand`); NEW: requests "at the top
  of Settings ▸ MCP"; THE TOOLS LINE "Until then, the one thing an approved client can do is look back over its own
  recent acts." (truth: the ONE `listedWhenApproved` tool is `list_my_activity`, read rung); "listed under Clients";
  VX-258's tab rule — "A client names itself…", "A client's own setup is the one copied from its tab, and moving its
  name takes no clicks.", "Any other new setup for a name you approved waits under Waiting…", "It sees no tools until
  you choose Allow…; Don't allow turns it away." (truths: `rebindTitle`, the registry's Allow / Don't allow,
  `rebindDetail`'s "allowing moves the name, with its grants", the tabs' `expectedName`s, and `decide` → `.awaitRebind`
  for ANOTHER tab's key under an approved name); "One honest limit: the key sits…" + L1's "tells two tools apart"
  (parity). **The F-1 parity clause and its pins are byte-unchanged.**
- **Lesson 3** — NEW: Suggest "one at a time or many at once" (`add_takes`/`add_comments` suggest); the Write new card
  (ten tools, write new; `insert_blocks`' "at the note's END — write new on the note is enough"; `link_versions`' "Name
  at least one pair"); JUSTIFIED EDIT: the Edit card as built (twenty-five tools, edit; `insert_blocks` "anywhere else
  needs edit"; `delete_comment` "any comment" at edit); JUSTIFIED EDIT: "commits the take just before and just after"
  now ABSENT, the new sentence pinned and EXECUTED on the wire's act (`editTakeUnderInsurance`: no before-commit when
  the latest commit holds the words; before + after otherwise, named `mcpEditCommitNames`; the undo restores the words
  and the commits stay; `labelTakeForClient` commits nothing and stores "  english  " as "english"); NEW: the label rule
  (`aiLabel(‹name›, "english") == "‹name› · english"`, the separator, no label = the name; `suggestedLabelRule` on
  add_take/add_takes, `labelNotPrefixed` on the five others); NEW: the comment rule EXECUTED (`addComment` by a client
  → `mcpCommentIsOwn` true; her `editBlockComment` → false); NEW: the three acts hers alone (the instructions name the
  same three phrases — D-2; no tool name carries private/seal/own).
- **Lesson 6** — JUSTIFIED EDIT: recipe 3's exception parenthesized (the dash); NEW: her four first, then organization,
  a revision, a long job, in that order (`#require` on each opening); the organization recipe (the advice's own
  "put plans, summaries and research into notes"; `create_book` wing-only; `matchesWaitWords`) EXECUTED on the wire's
  acts (a note she tagged before the client's `setBookRule` stands at `arrival`; a note the client tags with
  `applyTagPath` afterwards, and one she tags, stand at `member`); the revision recipe (Compare is ⌘5 by the mode
  row's order; `duplicate_note` "read on the note and write new on its wing"; `show_in_app`'s "compare" target)
  EXECUTED (`duplicateNoteForClient`: no live membership, the note's wing, one `derived_from` edge per block, the
  original's text unchanged); the long-job recipe (no digit but sha256's — P-VX256-1 is provisional; `read_note`'s
  pages; the eight digest-answering tools carry `digestSentence`, divide/merge carry none — "most"; `list_my_activity`
  "after a dropped call").
- **Lesson 7** — JUSTIFIED EDIT: "a book or a gathering"; NEW: the icon's rows (the Library, Pool, book panel, wing
  switcher and Bookcase hosts each declare `.mcpShowSharing`; `BookPanelBrain.markedNote(.chapter(_, collapsed: e))`
  is `e`'s note — VX-330), the ⌘L chord from the registry; NEW: own activity, quoting Activity's own line
  (`activityLine(list_my_activity)` = "‹name› checked its recent activity"); NEW: Compare on `link_versions`' Open ›
  and on a show ask (both descriptions tie).

**Lesson 1's "way in" (the brief's item) — DISMISSED AS HOLLOW:** the 13n-c UX walk fixed it (W-UX-17; the seed's
comment says so) and its pin (`"way in"` at most once) is green on both sides — the old seed holds zero. Nothing to fix.

**Predicted red on the old seed** (a scratch containment check — the seven lessons' literals compiled with every
`text.contains` of the suite, constants substituted — read in this session; the Mac run decides it): **8 tests, 6
failed, 30 issues** — `theChapterIsSevenLessonsAndTheGuidesAppendix` 3 (lesson 7's gathering; the dash in lessons 1
and 6) · `lessonOneTheDoorIsShutUntilYouOpenIt` 1 · `lessonTwoConnectingAClient` 10 · `lessonThreeHowMuchWhereHowLong`
9 · `lessonSixHowToUseIt` 2 (recipe 3's parenthesis; then the `#require` on recipe 5's opening ends the test) ·
`lessonSevenSeeingAnsweringUndoing` 5; `lessonFour…` and `lessonFive…` green. Every failure by its WORDS; every truth
half that runs on the old seed (lessons 2, 3 and 7's ties and executed acts) green. The same check on the new seed:
every expectation holds.

**No revert was ever applied** (U6b's precedent): the pins were committed ahead of the chapter, so the red product is
the committed pre-fix tree `c7fa39c4`; the fix commit `f887d8c7` touches only `TutorialSeeder.swift`, so reverting it
on the final tree would rebuild exactly that product.

### THE PRODUCTS (pieces 2 and 4 — `xcodebuild build-for-testing`, never launched here)

- **`App/Variorum/DerivedData/vx336-u8`** — the final tree `f887d8c7` (every later commit is `notes/` only): **TEST
  BUILD SUCCEEDED**, zero `error:`, no warning in the seeder or the pin file (`u8/logs/build-green.log`). Signed
  *[removed for publication]*
  22:49:14; the xctestrun `Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun`. The dylib carries "click the
  copy icon" ×1 and "press Copy setup command" ×0, U8a's link `stargazing.tech/variorum/mcp` ×1 and U7c's "about 32,000
  characters" ×1; the tree contains `d807cca6` (U7c), so the re-probe runs on it. **All 66 batch suites are real type
  names in its test bundle** (`nm -j` + `swift-demangle`, matched as `<Suite>.`).
- **`App/Variorum/DerivedData/vx336-u8-red`** — `c7fa39c4` (the pins + the OLD seed): **TEST BUILD SUCCEEDED**
  (`u8/logs/build-red.log`); its one use is step 1b's red run, never launched.
- **Headless guard (the working tree at `f887d8c7`):** `swift test --filter MCPProviderNeutralityTests` → **2 tests in
  1 suite passed** (no provider outside the seeder's ONE O-4 fence; the fence short and live). No `Sources/` line
  changed, so no core or MCP target is this unit's.

### THE STAGE WINDOW — the plan (claim `vx336-u8`; runs ONLY on the orchestrator's GO, under the exact claim line it relays)

**What this window does NOT do (said first):** no product code is written or changed, before the claim or under it — a
red that needs code is RECORDED as a FINDING and reported; no rebuild (if `git diff --name-only f887d8c7..HEAD -- Sources
App Package.swift` is not empty at the GO, or the coordinator says VX-306 has merged and main must come in first: STOP
before any launch and report — the rebuild is an implementer's); no canon, QUESTIONS or ticket edits; never her real
store, never `/Applications/Variorum.app`, never her USER-scope MCP registrations (the copied setup line is never run as
copied — only its key is taken, into the runner's scratchpad); **never `claude mcp list` (nor `claude mcp get`)**;
`castle-W1-20261013` left alone.

**Minutes:** guards 1 · the batch ~10 · the red run ~2 · SEAM · prefs, Backups, fingerprint, clipboard 2 · the A1 2 ·
launch 2 · sherlock present 1 · the fresh guide through the product door 2 · the chapter walk in Study ~12 · connect,
bind, the advice read, the grant 6 · the organization ask ~8 · U7c's re-probe ~8 · the Terminal pass (the chapter again
+ Activity) ~12 · cleanup 8 → **~76 of work; ask a 100-minute claim.** **Batch-only fallback (~15 min, claim 20):**
steps 0, 1a, 1b, the SEAM and the release (nothing launched, so no A1 — U1b's precedent); the walk, the client and the
re-probe then stay OPEN.

**Evidence:** `notes/plans/vx336-screens/u8/` (gitignored): `logs/`, `<leg>.jsonl`, `tee/`, `<leg>-measure.txt`,
`<leg>-instructions.txt`, captures `live/s/` (Study) and `live/t/` (Terminal). Keys redacted to their first 9
characters in every record and capture name. **The kit:** `notes/plans/fixes/vx-336-u7-kit/` as U7 used it, plus
U7c's three prompts and U8b's two additions — `prompts/U8-org.txt` (the organization ask) and `instructions.py <leg>`
(from the tee: the advice the server sent at `initialize` — its length, first and last lines, the four U8a markers
CARRIES/LACKS — then every `tools/call` in order with ok / REFUSED; dry-run on U7's tee at READY: U7's pre-U8a product
read LACKS ×4, the control). **Before any turn:** `export U7_SCRATCH=<the runner's scratchpad>/u8w` (FRESH — never a
directory an earlier window used), `export U7_SHIM_PATH=$PWD/App/Variorum/DerivedData/vx336-u8/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp`,
`export U7_SCREENS=$PWD/notes/plans/vx336-screens/u8`; `K=notes/plans/fixes/vx-336-u7-kit`; `T=$K/turn.sh`; from the
repo root.

0. **Guards, every step** — U7's step 0 exactly: `Tools/WalkKit/guard.sh --author` before anything touches the GUI
   (exit 3 ⇒ her app is running: STOP, never quit or kill it; exit 4 ⇒ someone at the machine: STOP); the STRICT
   instance guards `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` both empty before the launch; the claim line
   EXACTLY as the GO relays it; `Tools/stage status` never inside an `&&` chain; `guard.sh <devpid> x y` before each
   click (`Tools/WalkKit/wl2` compiled in this worktree); ≥ 2.6 s between synthetic events; region captures; every key
   through `keys.sh` (System Events — it drops `á` and `·`; nothing here types either); HEAD at the GO recorded; the
   product check above.
1. **1a — the Mac batch (~10 min) FIRST, before the A1.** From `App/Variorum/`: `xcodebuild test-without-building
   -scheme Variorum -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u8 -resultBundlePath
   ../../notes/plans/vx336-screens/u8/u8-batch.xcresult` + one `-only-testing:VariorumTests/<Suite>` per suite below,
   detached to `u8/logs/u8-batch.log` and POLLED in the foreground (a `grep -q` loop, never `tail -f | grep -m1`).
   **The 66 suites** — every suite type in every Mac test file naming `TutorialSeeder` (the type this unit changed) ∪
   U7's 21 (U8a's descriptions and instructions have met no Mac batch yet) ∪ the four the chapter's ties lean on:
   CalmAsksTests · CaptureUndoHistoryTests · CaptureUndoSyncTests · CaptureHostsUndoFilingTests ·
   CaptureFocusReattachTests · CaptureTourFocusTests · EncryptionExplainedDrillTests · EncryptionBookDoorTests ·
   LaunchFurnitureTests · NewModesTests · SampleLibraryWelcomeTests · ShellConfirmTests · SnippetOpenTargetTests ·
   SnippetsLandingTests · SnippetTagDoorTests · TakeCardDoorTests · TourScriptTests · TourSpotlightTests ·
   TourEngineTests · TourPoolTuckTests · TourEntryTests · TourEndCardTests · TourEndCardAsideGateTests ·
   TutorialFurnitureFoldTests · TutorialBuildFlavorTests · TutorialBooksLessonTests · TutorialBooksRitualTests ·
   TutorialCurrencyTests · TutorialMCPChapterCaptureTests · TutorialMCPChapterTests · TutorialBookShapeTests ·
   TutorialDoorTests · TutorialWritingActsTests · TutorialTakesActsTests · TutorialStructureActsTests ·
   TutorialLookingActsTests · TutorialLibraryActsTests · TutorialDeletionActsTests · TutorialWherePlacesActsTests ·
   TutorialPrivacyChapterTests · TutorialFannedMatrixTests · VX209GuideWarningTests · VX204PrivacyLessonTests (VX-201's
   guide changes, never overwritten — this unit touched neither) · MCPAskAndReceiptTests · MCPAsksWaitTests ·
   MCPDeliberateFacesTests · MCPDoorErgonomicsFacesTests · MCPEditFacesTests · MCPEditParityFacesTests ·
   MCPGrantSheetTests · MCPGrantSheetU2CaptureTests · MCPHerEditorDoorTests · MCPLibraryParityFacesTests ·
   MCPPaneTabsCaptureTests · MCPPaneTabsTests · MCPPaneTests · MCPRebindFaceTests · MCPSetupKeyFacesTests ·
   MCPSetupMenuTests · MCPShareFacesTests · MCPWingFacesTests · TakesBoardTests · BookPanelMCPMarksTests ·
   MCPSharedRowsTests · MCPSharedRowsRulesTests · MCPCompareLandingTests. **Expected:** green; the three gated
   capture harnesses skip (TutorialMCPChapterCaptureTests, MCPGrantSheetU2CaptureTests, MCPPaneTabsCaptureTests — a
   different skip set is a finding); **`TutorialMCPChapterTests` 8 tests green — its FIRST run (PENDING until read
   here)**. Neither standing red (VX-115's `BookCollectingDoorsTests`, VX-167's `DestructiveUndoWarningTests`) is in
   the set. A red: re-run that suite ALONE once; a red that reproduces is a FINDING — recorded and reported; the live
   round continues only if it is outside every type this run changed.
   **1b — THE RED RUN (~2 min), on `vx336-u8-red` (never launched):** `xcodebuild test-without-building -xctestrun
   DerivedData/vx336-u8-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
   -only-testing:VariorumTests/TutorialMCPChapterTests` → `u8/logs/u8b-red.log`. **Expected EXACTLY: 8 tests, 6
   failed, 30 issues** (THE PINS' predicted red, test by test: 3 · 1 · 10 · 9 · 2 · 5; lessons 4 and 5 green), every
   failure an expectation on the chapter's WORDS (none on a tie or an executed act). Any other count is a finding,
   recorded and reported. Then the red product may be deleted (`rm -rf DerivedData/vx336-u8-red`, the coordinator's
   disk). **→ THE SEAM:** record 1a's and 1b's counts here, commit, push, KEEP the claim, report "SEAM" through the
   orchestrator; continue only on its word ("continue" or "release for X").
2. **Prefs, Backups, fingerprint, clipboard — BEFORE the A1 and the launch (~2 min):** `defaults export
   io.lduarte.Variorum.debug $U7_SCREENS/prefs-pre.plist` (key count recorded); `ls -la …/Variorum-dev/Backups/ >
   $U7_SCREENS/backups-pre.txt`; the dev store listed read-only; her user-scope servers — names + the sha256 prefix,
   never values (U7 step 2's `python3 -I` one-liner) → `userscope-pre.txt` — **expected `['linear-server', 'variorum']`,
   `bc64543e2f4e8e58`** (U5–U7's); the clipboard saved (`pbpaste > $U7_SCRATCH/clip-before.txt`, never read or
   recorded).
3. **THE ONE A1 (~2 min) — `stage.sh`'s copy loop ONLY, no fixture** (U5/U6's form): the store must be quiet (both
   strict guards and the loose `pgrep -f 'Variorum.app/Contents/MacOS'` EMPTY — a headless build line of another
   session: wait for it to end); `DEST=…/Variorum-dev/Backups/safety-copies/scale-prestage-$(date -u
   +%Y%m%dT%H%M%SZ)` (the name `restore.sh` accepts); `cp -p` each of `variorum.sqlite`, `-wal`, `-shm` and every
   `variorum-keys-*.json` into it, each `cmp`-verified; the path → `a1-path.txt`; the sha256 prefixes →
   `store-hash-pre.txt`. castle-W1 untouched.
4. **Launch (~2 min):** `open -n App/Variorum/DerivedData/vx336-u8/Build/Products/Debug/Variorum.app`; its pid by the
   strict guard; a What's New sheet → its own button; a lock screen → `source ~/.variorum/dev-castle.env`, those values
   only (none expected — the store is Standard/unlocked); Study expected (capture `live/s/00-launch`).
5. **Sherlock present (~1 min):** the Bookcase shows "the adventures of sherlock holmes" (Home). Absent ⇒ Help ▸
   Restore the Sample Library (its door; restored at cleanup). Capture `live/s/01-sherlock`.
6. **THE FRESH GUIDE THROUGH THE PRODUCT DOOR (~2 min) — item 4's road, walked:** Help ▸ **Restore Tutorial…** → the
   confirm "Restore the tutorial?" (its detail names the tag, the pool and the book) → **Replace** (capture the confirm
   `02-confirm`) → the receipt "The tutorial is fresh — “the field guide” is on your Bookcase, on the “Welcome” shelf."
   and the guide opens (capture `03-fresh`). Then the Library's Trash: the OLD guide's book and lessons are there,
   deletable or put back like any (capture `04-trash` — the re-seed note's own claim, seen).
7. **THE CHAPTER WALK, Study (~12 min):** the guide's Outline with the chapter "AI & the MCP door" and its seven
   lessons in order (capture `C0-outline`). Then each lesson by ⌘K → its title → ⏎ (the reliable road — WalkKit's
   13u3 note): "what the door is" · "connecting a client" · "how much, where, how long" · "what always asks" ·
   "sharing from where you are" · "how to use it" · "seeing, answering, undoing" — each opens at its start (a first
   open, R-18l-1); capture `live/s/C1`…`C7`; a lesson taller than the window (lessons 3 and 6 for sure): `walk-scroll`
   down and capture `C3b`, `C6b` (and `c`, as needed) until its last paragraph shows. **Read against THE CHAPTER AS
   BUILT below:** every paragraph present, in order, nothing clipped; the only em dash is lesson 4's quoted Private
   row; "‹name› · english" (lesson 3) and "‹name› checked its recent activity" (lesson 7) render their marks.
8. **Connect, bind, THE ADVICE READ, the grant (~6 min):** App menu ▸ MCP Settings… → the switch ON (expected already).
   **Connect ▸ Claude Code ▸ the copy icon** → ONLY the key: `mkdir -p "$U7_SCRATCH/keys" && pbpaste | python3 -I -c
   'import re,sys; m=re.search(r"vmk2_claude-code_[^\s\"'"'"';]+", sys.stdin.read()); print(m.group(0) if m else "")' >
   "$U7_SCRATCH/keys/u7.key" && chmod 600 "$U7_SCRATCH/keys/u7.key"` (non-empty; record only its first 9 characters);
   the clipboard emptied at once (`pbcopy < /dev/null`); never run the copied line. **The bind turn:** `zsh $T bind
   mcp__variorum-dev__list_books < $K/prompts/bind.txt` → Activity "claude-code connected with a new setup, now bound to
   its name" (or "…a newer setup, which replaced its earlier one") with zero clicks (capture `05-bind`); an unknown
   name → Waiting ▸ Approve… (alone — zero reach). **THE ADVICE, from bytes:** `python3 -I $K/instructions.py bind` →
   **expected: the advice ≈ 2,969 code points (U8a's Swift count; a different count is recorded, not a red unless a
   marker LACKS), its last line exactly "The guide to this door: https://stargazing.tech/variorum/mcp", CARRIES ×4**
   (the tools line, the organization sentence, the three acts, the link) — the real client received U8a's advice.
   **THE GRANT:** Clients ▸ claude-code ▸ Change… ▸ **A wing · Home · Write new · Always** (capture the sheet
   `06-grant` and the Shared-with-AI row `07-row`). It reads sherlock (Home) for step 10 and can do every
   organizing act the advice names (create_book is wing-only).
9. **THE ORGANIZATION ASK — a real client answering by the advice (~8 min):** `zsh $T U8-org
   "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note,mcp__variorum-dev__search,mcp__variorum-dev__create_note,mcp__variorum-dev__apply_tag,mcp__variorum-dev__create_book,mcp__variorum-dev__create_section,mcp__variorum-dev__add_note_to_book,mcp__variorum-dev__file_note_in_chapter,mcp__variorum-dev__set_book_rule,mcp__variorum-dev__list_my_activity"
   < $K/prompts/U8-org.txt`, then `python3 -I $K/instructions.py U8-org` (the advice again + the acts in order) and
   `python3 -I $K/measure.py U8-org` (every answer INLINE). The prompt asks for a tea-research summary kept "organized
   and easy to find" and NAMES no book, chapter or tag — the advice must supply the shape. **PASS:** (a) the summary
   lands as a NOTE (`create_note` ok), not only in the chat; (b) at least one organizing act the advice names — a tag
   (`apply_tag`), a book (`create_book`), chapters (`create_section`, `add_note_to_book` / `file_note_in_chapter`), or
   the strongest form, a book that collects by a tag rule (`set_book_rule`); (c) zero REFUSED calls; (d) the model's
   closing lines say what it made. **Record exactly which acts, in order.** **Her face (Study):** the Bookcase (any new
   book; a rule it wrote → the note at that book's Arrivals if it was tagged first, a member if tagged after — lesson
   6's own recipe sentence, seen live), the Library row, Activity's lines (captures `08-org-bookcase`,
   `09-org-library`, `10-org-activity`). A client that answers only in chat, or makes one untagged bookless note: a
   FINDING for the orchestrator (the advice's force), never a product red.
10. **U7c's RE-PROBE (~8 min) — THE RE-PROBE in the U7c UNIT RECORD, run as written** (one read per turn, each measured
    alone from BYTES): `zsh $T U7c-200 "mcp__variorum-dev__list_books,mcp__variorum-dev__list_notes,mcp__variorum-dev__read_note"
    < $K/prompts/U7c-200.txt` then `python3 -I $K/measure.py U7c-200`; the same for `U7c-100` and `U7c-ids-200`.
    **Expected:** (1) limit 200 → 72 blocks, ≈ 31,950 characters, `next_cursor`, `block_count` 215, **INLINE**; (2) limit
    100 → the same 72-block page, **INLINE**; (3) `ids_only` limit 200 → 116 blocks, ≈ 31,930 characters, **INLINE**;
    every answer ≤ 32,000 in `measure.py`. Any NOT-INLINE is a FINDING (the budget's number), recorded, not fixed.
11. **The Terminal pass (~12 min):** Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented
    control — U5's road; capture `t/00-theme`); **the chapter walk again** — `C0-outline`, `C1`…`C7` (+ `b`/`c` scrolls)
    under `live/t/`, read as in step 7; Settings ▸ MCP ▸ Activity in Terminal (step 9's lines; capture
    `t/10-activity`); Theme back to **Study** (capture `s/11-back-study`).
12. **Cleanup (~8 min)** — U7's step 13 exactly, adapted: the Debug app quit BY BUNDLE ID (`osascript -e 'tell
    application id "io.lduarte.Variorum.debug" to quit'`), both strict guards empty, no turn or shim of ours left;
    **the key** (read whole from `keys/u7.key`) grepped over `$U7_SCREENS`, `~/.claude.json`, `~/.claude/projects/`,
    `notes/` + `Tools/` and the scratchpad outside `keys/` → **0 files**; then `keys/` deleted (the key and every
    `cfg-*.json`); the clipboard RESTORED (`pbcopy < $U7_SCRATCH/clip-before.txt`, `pbpaste | cmp` SAME, the copy
    deleted); **no `-s local` registration was ever made** — read-only: `~/.claude.json` has no `projects` entry for
    `$U7_SCRATCH/proj` with `mcpServers` (never `claude mcp get`/`list`); any saved-to-file tool result under the scratch
    project's `~/.claude/projects/…-u8w-proj/` deleted; her user-scope fingerprint AFTER = BEFORE; prefs: `defaults
    import io.lduarte.Variorum.debug $U7_SCREENS/prefs-pre.plist`, re-export, diff, `defaults delete` every key the
    window ADDED (import merges), until **0 added · 0 removed · 0 changed**; `Tools/ScaleFixture/restore.sh "$(cat
    $U7_SCREENS/a1-path.txt)"` → "Restored (verified)", a second `cmp` of every file SAME and the sha256 set equal to
    `store-hash-pre.txt` (the fresh guide, the old guide's Trash rows, the organization note and book — every window
    write — gone with it; Standard, unlocked, Study, claude-code's pre-window binding and grants back); `Backups/`
    unchanged against `backups-pre.txt`; castle-W1 untouched; 0 simulators booted; the tree clean;
    `Tools/stage release --who vx336-u8`; **THE RESULT LINE** for the coordinator: claim times; 1a's counts and 1b's
    exact red; the walk in both voices (PROVEN or the paragraph that wasn't); the advice from bytes; the organization
    acts; the re-probe's three verdicts; the posture (cmp SAME vs A1, prefs 0 differ, fingerprint SAME,
    Standard/unlocked); the A1 path (the coordinator's to prune).

### THE CHAPTER AS BUILT (piece 3 — "AI & the MCP door", seven lessons; rendered from the seed's own literals at `f887d8c7`; lessons 4 and 5 byte-unchanged)

The title is unchanged, so the stargazing brief's "Learn more" line (it quotes "AI & the MCP door") needs no edit.

**Lesson 1 — what the door is**

> Variorum can let an AI work in your library, if you want it to. It works through MCP, the Model Context Protocol: a standard way for AI apps to use another app's tools. Variorum calls this connection the door, and it stays shut until you open it. It lives on the Mac; the phone has no door.

> Open it in Settings ▸ MCP (⌥⌘, takes you there) with Enable the MCP server. It works only while Variorum is open, and nothing in your library can be read through it until you share something with a client. Your grants stay on this Mac and never sync to your other devices. What a client reads goes wherever that client sends its work: for most clients, the company that runs its model.

> A client can only do what you could do yourself, through the same acts. What it writes arrives as takes, notes and commits you can see, and every act it takes comes back out with ⌥⌘Z for as long as this session is open, except a commit, which stays, as yours do. The chapter's last lesson, “seeing, answering, undoing”, shows how to watch it, answer it and undo it.

**Lesson 2 — connecting a client**

> To connect a client, open Settings ▸ MCP; under Connect a client, choose yours at the top of the setup block: Claude Code, Codex, or Any MCP client. Then click the copy icon in the block's upper right corner. For Claude Code or Codex it is one command: run it in a terminal, then start a new session of that app. For any other client it is a few lines of JSON to paste into that client's MCP settings. The pane also shows the path they all point at, because the door is a standard MCP server: one program inside the app.

> The first time a client connects, it shows up at the top of Settings ▸ MCP as a connection request, and it can reach nothing yet. Approve… lets it in, still reaching nothing until you share something: its sheet offers a first grant, with nothing picked for you. Until then, the one thing an approved client can do is look back over its own recent acts. Deny turns it away. Every approved client is listed under Clients, with Change… to share more and Deny… to shut it out again, every grant it holds revoked.

> A client names itself when it connects, and the setup you copy carries a key that ties that name to it. Running the client's own setup again moves the name to the new key; a setup copied for any MCP client waits for your OK before it takes a name you approved; and a tool still using an older key, or none, is turned away.

> A client's own setup is the one copied from its tab, and moving its name takes no clicks. Any other new setup for a name you approved waits under Waiting, above the tabs in Settings ▸ MCP, as a new setup for that name. It sees no tools until you choose Allow, which moves the name and its grants to it; Don't allow turns it away.

> One honest limit: the key sits in the client's own settings, where any program running as you can read it. It tells two tools apart, not programs running as you.

**Lesson 3 — how much, where, how long**

> Each grant says how much a client may do, in four steps, each including the ones before it. Read: it can read and search what you shared. Suggest: it can add new takes and comments beside your text, one at a time or many at once, and save a lens; it can't change a word you wrote.

> Write new: it can also make new notes, books, chapters and tags, file notes into books and chapters, and give a book a rule that collects notes by tag. It can add blocks at the end of a note, duplicate a note to work on a copy, and link two notes as versions by naming which paragraphs match.

> Edit: it can also do most of what you can do at the keyboard. In a note, it can change, choose, commit, archive or delete takes, restore a commit, make a lens the note, add blocks anywhere, divide, merge, move or delete blocks, and edit or delete any comment. Across the library, it can take a tag off a note, rename, archive or delete notes and books, finish or reopen a book, reorder a book's notes and chapters, and rename or delete a chapter. When it rewrites the words of a take, Variorum first commits the words it replaces, unless the take's latest commit already holds them, and then commits the new words, so you can always compare and come back. Both commits stay even if you undo the edit.

> You can always see who suggested a take. A take a client adds beside yours wears its name, then a dot and its own label if it gave one, like ‹name› · english. Takes it writes into a new note or new blocks, and labels it sets on a take, carry only the label it gave. With Suggest it can delete a comment it left, but only while the words are still the ones it wrote; once anyone changes them, deleting that comment takes Edit, which can delete any comment.

> Three things stay yours alone, whatever you grant: marking something Private, sealing a book, and making a book own its notes. A client knows what each one does and may suggest one when it would help, but only you can do it.

> Each grant also says where: one note; one book, with its notes now and any added to it later; or a whole wing and everything in it, except what always asks: your daily Journal's entries and anything Private (the next lesson). And for how long: once, for a single act (one read of a note, or one change); until it disconnects, which ends when the client goes away (offered while it's connected); or always, until you revoke it.

> A wing grant also lets a client read that wing's gatherings; a gathering is never shared on its own. And a client can move a note to another wing only with edit where the note is and write new in the wing it goes to: the note leaves its books there, its tags come along, and ⌥⌘Z brings it back.

> The open book is the widest grant of all: one switch in Settings ▸ MCP that lets every approved client read everything, always, again except what always asks. It is off to begin with; leave it off unless that is what you mean.

**Lesson 4 — what always asks**

> Two things are never reached by a book grant, a wing grant or the open book: the entries in your daily Journal (the journal ⌘J and Today's Entry file into), and anything marked Private. A client can read one of them only through a grant on that one note, once or until it disconnects. Always is never offered for them.

> To mark a note Private, open the note ▾ menu in the bar at the bottom of the note and choose Private — never shared with AI. A book has the same mark in its Book Settings, and it covers every note in the book. Other books with date-stamped entries share like any book; only the daily Journal asks. An entry made with ⌘J keeps asking even if you later file it in another book.

> Snippets can't be reached through the door at all: no grant reaches them. And each wing is a separate library: a grant in one wing never reaches another (⌘L switches wings). Snippets is the one room every wing shares, and it stays closed to clients.

> To a client, something it can't reach looks exactly like something that isn't there. No answer it gets tells it that a Private page or a journal entry exists.

**Lesson 5 — sharing from where you are**

> Once a client is approved, you can share from wherever you are. Right-click a note in the Library, or a book on the Bookcase or in the Library, and choose Share with AI…: the grant sheet opens with that place already picked. ⌘-click several notes in the Library and doors appear under the controls at the top of the list, Share 3 notes with AI… among them (the number is how many you picked): one grant for all of them. And a book's Book Settings says who reaches it, with Share… beside.

> ⌥⌘A (Edit ▸ Share This Note with AI) shares the note you're in with the client you granted most recently, at that grant's step: until it disconnects if it's connected, otherwise once, never always. Its confirmation says what was shared, with Change… to adjust it and Revoke › to take it back. With no grant yet to follow, it opens the grant sheet on this note instead.

> Every grant shows in Settings ▸ MCP, with Change… to raise or lower it and Revoke to take it back. Sharing several notes at once makes one row there, and one Revoke covers them all.

**Lesson 6 — how to use it**

> Say your notes for a design doc live in a book. Share that book at Suggest and ask your AI to go through it: it can leave implementation ideas or tradeoffs as new takes on each block, and they join the block's takes unchosen, so the page doesn't change until you choose one. Review them in Takes (⌘2); ⌥⌘O shows the client's last change, and ⌥⌘Z takes the latest back, named after the client.

> Or make a book just for your AI, even an empty one, and grant it Write new on that book alone. It can read what's in that book and add new notes to it; if that is its only grant and the open book is off, nothing else in your library is readable to it.

> For help across everything, grant a whole wing instead: it reaches every note, book and gathering in the wing except what always asks (your daily Journal's entries and anything marked Private, which a client reaches only through a grant on that one note). So mark Private whatever should stay off-limits first, then grant the wing.

> And for a one-off, right-click a note in the Library, choose Share with AI… and grant Read, once: the client's first read of the note spends the grant, and nothing stands afterwards.

> Your AI can help keep the library in order, too. Grant it Write new on a wing and ask it to put plans, summaries and research into notes rather than leave them in the chat. It can make a book for a project, give it chapters and file notes into them, tag notes, and make a book that collects every note wearing a tag. A rule it writes moves nothing by itself: notes that already match wait at the book's Arrivals for you to let in, and notes it tags afterwards join the way they would if you had tagged them.

> For a revision, grant Edit on the note's wing and ask your AI to duplicate the note and rewrite the copy. The copy lands in that wing's Pool, in no book, and your original never changes. Because each block of the copy remembers the block it came from, Compare (⌘5) lines the two up row by row. Ask your AI to show you the two side by side and, while Variorum is the app in front, it opens Compare on them.

> For a long job, like translating a whole book, ask your AI to check its work as it goes. It can read a long note a page at a time instead of all at once. Most writes that add or rewrite words answer with a fingerprint of exactly what was stored (a sha256), so it can confirm every word landed as it sent it. And if the connection drops partway through, it can look back over its own recent acts to see which ones landed before it carries on.

**Lesson 7 — seeing, answering, undoing**

> On the Bookcase, a small icon beside a book or a gathering means a client can reach it. The same icon shows on notes, books and gatherings in the Library, on notes in the Pool, on the notes listed in the panel that shows a note's book, and on wings in the switcher that ⌘L opens. In that panel, a chapter that shares a row with its only note wears the note's icon. Point at the icon to see who and how far; click it for the details, including why (through the Home wing grant, say), with Change… and Revoke. Inside a note, while the door is open, the same icon sits at the right end of the context bar above the page, or a lock when the note is Private.

> Settings ▸ MCP lists every client, everything shared, and, under Activity, the calls clients made recently. A client can look back over its own recent acts as well, which is how it learns whether a call landed after a dropped connection; Activity then says “‹name› checked its recent activity”.

> When a client wants more than you've shared, nothing pops up and nothing interrupts you. Its ask waits: a small mark appears beside the place it names (the note's row in the Library, the book on the Bookcase, the wing's name, the note's context bar) and under Waiting in Settings ▸ MCP, which ⌥⌘, opens. Press the mark to answer: Once, Until it disconnects or Always, whichever fit, or Don't allow. Don't allow, or Esc, lets the ask go; the client can ask again.

> Whatever a client writes, a line at the bottom of the window says so, naming the client, with Open › to go and look (unless Confirmations after an act is off, in Settings ▸ General); when it links two notes as versions, Open › shows them side by side in Compare. ⌥⌘O (Show the AI’s Last Change, in the Edit menu) takes you there later, even after the line fades. ⌥⌘Z takes a client's act back, one act at a time, and the Edit menu names it after the client: Undo ‹name›'s take.

> A client is told to move your window only when you ask it to show you something, and it can only while Variorum is the app in front; it never brings a window forward. Asked to show you a note beside another, it opens Compare with them side by side.

### FOR VX-234 (user-facing words, AS BUILT — U8b)

- **No pane, sheet, receipt or menu word changed.** Every word U8b wrote is the field guide's (above, whole).
- **Changed or new, by lesson:** 1 — the dash sentence ("Your grants stay on this Mac and never sync…"); 2 — the
  setup block and its copy icon, "at the top of Settings ▸ MCP", the tools line ("Until then, the one thing an
  approved client can do is look back over its own recent acts."), "listed under Clients", the re-voiced key cards
  (the parity clause kept byte for byte), the Waiting card, the one honest limit; 3 — the Suggest clause, the Write
  new card, the Edit card and its commits sentence, the who-wrote-what card ("You can always see who suggested a
  take…", the label shown as "‹name› · english"), the three-acts card; 6 — recipe 3's parenthesis, and the three new
  recipes (organization, a revision, a long job — "fingerprint" is the guide's word for the sha256); 7 — the icon's
  rows, own activity (quoting Activity's "‹name› checked its recent activity"), Compare on Open › and on a show ask.
- **For her eye:** lesson 3 is now eight paragraphs (P-VX197-U8b-1); "fingerprint" for the digest; "the panel that
  shows a note's book" for the Book Panel (the guide never names it — the books chapter says "the panel it opens").

### PROVISIONALs (the orchestrator files them at the merge)

- **P-VX197-U8b-1 — where the tools are taught: lesson 3 grows, the chapter stays seven lessons.** The brief's "taught
  in its lesson" put every rung's acts in lesson 3, which went from four paragraphs to eight (Read + Suggest, Write
  new, Edit, who wrote what, the three acts, then the three it had). Options: **(a) as built** — seven lessons, every
  title, seat and pointer unchanged (lesson 1's "the chapter's last lesson", lesson 3's "the next lesson"); (b) split
  lesson 3 into "how much" and "where and how long" (eight lessons; the plan, the pins' indices and MCPSpec's "seven
  lessons" move); (c) a new lesson "what a client can do" between 3 and 4 (the same moves). Built (a): the least
  structure moved, and the reference lesson reads as one list of steps.
- **P-VX197-U8b-2 — the revision and long-job recipes.** Organization as recipes is the plan's ruling; teaching
  `duplicate_note` + Compare and pages + digests + `list_my_activity` as two more RECIPES beside her four (rather than
  as facts inside lesson 3 or 7) is this unit's choice. Options: **(a) as built** — recipes 6 and 7 in "how to use it",
  lesson 3 naming the acts and lesson 7 the faces; (b) facts only, no recipes (lessons 3 and 7 carry everything);
  (c) one combined "careful work" recipe. Built (a): each tool sits where a reader would reach for it — the steps say
  what is allowed, the recipes say when to use it — and her four still lead, unchanged in order and words but for
  recipe 3's dash.

### MOBILE PARITY (for the closeout's line)

Nothing mobile-visible: the phone has no door and its pocket guide (`MobileTutorialSeeder`) carries no MCP chapter.

### SELF-ASSESSMENT (the implementer's)

The chapter is built to the brief's item 1 point by point, each claim pinned by its words and, where the truth is
reachable from the app, by the act itself (the commit dedupe, the label as given, the comment rule, the organization
recipe's arrival-then-member, the duplicate's landing) or by the catalog the wire serves (rungs, descriptions,
`aiLabel`, the advice). The old seed fails the new pins by words only (predicted 30 issues in 6 tests by a scratch
containment check; the Mac run decides it). What I'd have a reviewer press on: **(1)** `@testable import VariorumMCP` in
a Mac test — new in this target (VariorumCore's precedent exists; no name collision, checked; the build is green);
**(2)** the tool lists in lesson 3's Write new and Edit cards are the catalog's AS OF NOW — a tool added later is not
caught by these pins (the pins catch only a named tool changing rung); **(3)** "the one thing an approved client can do"
assumes the open book is off — I read turning the open book on as sharing (lesson 3 calls it "the widest grant of
all"); **(4)** "Most writes that add or rewrite words" — divide, merge, `save_version` and a book import answer no
digest (P-VX254-1/2); **(5)** the commits sentence leaves out the blank-never-committed edge (`isDirty` false: no
before-commit, nothing to keep) — said simply rather than exactly; **(6)** lesson 7's book-panel sentence describes the
collapsed row by its shape ("a chapter that shares a row with its only note") — true only of the row-8 collapse, which
is the only time they share a row; **(7)** the window's organization leg PASSES on any one advice shape — a stricter
bar (a tag-rule book) would test the model as much as the advice.

### OWED (U8b → the orchestrator)

1. **THE STAGE WINDOW (claim `vx336-u8`, ~100 min; batch-only fallback 20)** — a FRESH stage runner takes it (this
   session is past ~500k by the harness count). The products are on disk; the plan is above; nothing in it needs
   code.
2. **THE RE-SEED NOTE for her handoff (item 4), ready to paste:** *Your library keeps the field guide it already has.
   To get the new MCP chapter, choose Help ▸ Restore Tutorial…: it asks first, then moves the old guide (the book
   "the field guide", every note tagged exactly "tutorial", including any of yours with that tag, and the "tutorial
   scraps" pool) to the Trash and puts a fresh guide on your Bookcase, on the Welcome shelf (its confirm also says what it arranges there). Anything you changed in
   the old guide is in the Trash for 30 days if you want it back. The same command brings the guide back if you have
   deleted it.* (The window's step 6 walks this road on the dev store.)
3. **The two PROVISIONALs** above → QUESTIONS at the merge.
4. **FOR VX-234** above → posted to VX-234 at the closeout.
5. **MCPSpec at the merge:** its docs clause "the field guide's MCP chapter (seven lessons, her ruled 'how to use it'
   recipes sixth)" stays true; the orchestrator may add that the chapter teaches the as-built door (VX-197) beside
   U8a's "≤2,000" → "≤3,000".
6. **The stargazing brief:** no edit owed — the chapter's title is unchanged and the brief's "Learn more" paragraph is
   true of the as-built door (read in this session).
7. **No ticket minted.** No observation outside the chapter.

## U8 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-14)

**What this run does NOT do (said first):** no product code is written or changed, before the claim or under it. A red
that needs code is RECORDED as a FINDING and reported, never fixed here, and so is a re-probe page that spills (the
orchestrator rules the budget). No rebuild: the window runs `vx336-u8` (from `f887d8c7`) and `vx336-u8-red` (from
`c7fa39c4`) exactly as U8b built them. No canon, QUESTIONS or ticket edits. Never her real store, never
`/Applications/Variorum.app`, never her USER-scope MCP registrations: the copied setup line is never run as copied; only
its key is taken, into a scratch config in the runner's scratchpad, OUTSIDE the repo, deleted at cleanup. **Never `claude
mcp list` (nor `claude mcp get`).** `castle-W1-20261013` left alone. The plan is the U8b UNIT RECORD → THE STAGE WINDOW
(claim `vx336-u8`, steps 0–12), run as written, with its kit `notes/plans/fixes/vx-336-u7-kit/` (U7c's three prompts and
U8b's `prompts/U8-org.txt` + `instructions.py` included).

**Read in full before READY (never delegated):** this record's header, Hard rules (never `claude mcp list`; the
live-round machinery), LIVE STATUS, Stage traffic log and Cross-run coordination; the U8b UNIT RECORD whole (THE PINS,
THE PRODUCTS, THE STAGE WINDOW, THE CHAPTER AS BUILT, FOR VX-234, PROVISIONALs, OWED); the U7c UNIT RECORD's THE
RE-PROBE; THE ORCHESTRATOR ON U5's, U6's and U7's WINDOW; the U7 STAGE RUN whole (and builder B's STAGE WINDOW it ran;
the U6 STAGE RUN for the A1 copy-loop form); every kit file (`turn.sh`, `tee-shim.sh`, `drop-relay.py`, `measure.py`,
`instructions.py`, `verify-digests.py`, the sixteen prompts); `Tools/stage`; `Tools/WalkKit/` (README, `guard.sh`,
`click.sh`, `keys.sh`); `Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); `notes/SessionResiliencyProtocol.md`
(the implementer rules and the addenda); the memory note walk-driving-lessons.

**The build check (READY, 2026-10-14 ~23:00 MDT):**
- **The products match their trees.** HEAD `a2fb6459`; the tree clean; `git diff --name-only f887d8c7..HEAD -- Sources
  App Package.swift` is **EMPTY** (since `f887d8c7` only this record, `instructions.py` and `prompts/U8-org.txt` changed);
  `git diff --name-only c7fa39c4..f887d8c7 -- Sources App Package.swift` is **exactly
  `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift`** (the fix commit — so `vx336-u8-red` = the pins + the
  OLD seed). No `.swift`, plist, pbxproj, xcstrings, entitlements, xcconfig or `Package.swift` under `Sources`,
  `App/Variorum` or the root is newer than `vx336-u8`'s `Variorum.debug.dylib` (22:49:14).
- **The products exist, read from their binaries:**
  *[removed for publication]*
    0.9.6; dylib 22:49:14, shim `variorum-mcp` 22:47:19, test binary 22:49:14, the
    `Variorum_Variorum_macosx27.0-arm64.xctestrun` 22:49:15. The dylib: "click the copy icon" ×1 · "press Copy setup
    command" ×0 · "Until then, the one thing an approved client can do" ×1 · "Your AI can help keep the library in
    order" ×1 · `stargazing.tech/variorum/mcp` ×1 (U8a) · "about 32,000 characters" ×1 (U7c).
  - `App/Variorum/DerivedData/vx336-u8-red` — signed the same; dylib 22:45:17 (BEFORE the seeder's 22:45:33 edit),
    shim 22:38:42, the `.xctestrun` 22:45:17. The dylib: "press Copy setup command" ×1 · "click the copy icon" ×0 · the
    two new lessons' sentences ×0 — **the OLD seed**; U8a's link ×1 and U7c's words ×1 (both predate `c7fa39c4`).
  - Both test binaries carry the new pins ("Until then, the one thing an approved client can do" ×2 in each).
- **The 66 suites are real type names in BOTH test bundles** (`nm -j` + `swift-demangle --simplified`, matched as
  `<Suite>.` on a word edge — a name that matches no type runs 0 tests silently): the plan's step-1a list parsed from
  this record = **66 names, 66 distinct, 66 of 66 found** in `vx336-u8` and in `vx336-u8-red`, ≥ 49 symbols each (the
  least `TourEndCardAsideGateTests`); `TutorialMCPChapterTests` 1,771 symbols, and **its eight test names present in both**
  (`theChapterIsSevenLessonsAndTheGuidesAppendix` · `lessonOne…` · `lessonTwoConnectingAClient` ·
  `lessonThreeHowMuchWhereHowLong` · `lessonFourWhatAlwaysAsks` · `lessonFiveSharingFromWhereYouAre` ·
  `lessonSixHowToUseIt` · `lessonSevenSeeingAnsweringUndoing`).

**Host and tools:** `AX: true SCREEN: true` (a compiled non-prompting probe); `walk-cap` and `walk-scroll` compiled into
the runner's scratchpad `u8w/bin/`; `Tools/WalkKit/wl2` present in this worktree (arm64, compiled 15:10, newer than
`wl2.swift`); Claude Code **2.1.300**; `cliclick` at `/opt/homebrew/bin`. Free disk **52 GiB**. Load average ~12 (another
session's batch). **`U7_SCRATCH` = `<the runner's scratchpad>/u8w`** — created FRESH by this runner at READY (the shared
scratchpad holds the earlier windows' `u7w`, `proj/`, `clip-before.txt`; none is reused).

**Her user-scope MCP servers (names + a sha256 prefix of the sorted compact `mcpServers` JSON, never values):**
`['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as U5–U7's windows and U8b's plan.

**The instances and the stage at READY — NOT ours:** both strict guards (`pgrep -lx Variorum`, `pgrep -lf
"MacOS/Variorum$"`) EMPTY, the loose form EMPTY, no `variorum-mcp`; **0 simulators booted**. `Tools/stage status` →
**STAGE HELD by `vx283-u1c2`** (VX-283 U1 fix close: 93 suites + mount ×5 + reverts, claimed 23:00:00 for 30 min) — not
ours; the GO's relayed line is run exactly as relayed. **Main:** `origin/main` is `ebd16909` (ahead of this branch by
notes, `.claude` and `CLAUDE.md` only) — VX-306 has NOT merged, so no rebuild is owed.

**The dev store (read-only listing at READY):** `variorum.sqlite` (14 Oct 08:50), `-wal` 09:17, `-shm` 23:00 (vx-283's
window starting); key files `variorum-keys-b831b428ce0d67b1.json` · `variorum-keys-e86ed514dc8dab5a.json`; `Backups/` 57
entries; `Backups/safety-copies/` holds only `castle-W1-20261013` (left alone). Prefs 1,602 keys,
`variorum.whatsNew.lastVersion` 0.9.6 (= the product's, so no What's New sheet is expected), `appearanceChoice` system —
informational only: the restore target is step 2's export, taken after the batch.

**Process choices (the earlier windows' lessons applied):** the batch and the red run FIRST, each detached to its log
and POLLED in the foreground (a `grep -q` loop, never `tail -f | grep -m1`); the SEAM after them; prefs, `Backups/`, the
fingerprint and the clipboard BEFORE the A1; the A1 by `stage.sh`'s copy loop ONLY (no fixture), with every guard (strict
and loose) empty; every GUI act through `click.sh` / `keys.sh` (keys only by System Events), at least 2.6 s apart;
region captures; `á` and `·` never typed; every lesson by ⌘K → its title → ⏎; the Debug app quit BY BUNDLE ID; prefs
restored by import, then re-export, diff, delete every added key until 0 differ; keys redacted to their first 9
characters everywhere; every client turn through the kit's `turn.sh` (prompt on STDIN, `--strict-mcp-config`); inline
read from BYTES (`measure.py`), the advice read from BYTES (`instructions.py`).

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the coordinator's GO and its exact line) |
| 0 | guards; the claim from the GO's line; HEAD at the GO; the product check | DONE — the GO from oct13coordinator at 23:07 (its checks: vx-283's window released 23:06 with the dev store restored and verified; no instances by the strict forms; no sims; 56 GiB; dev `safety-copies` holds only castle-W1; **the SEAM's "continue" PRE-GIVEN** — vx-283's walk waits for our RELEASE). **HEAD at the GO `55953071`**; `git diff --name-only f887d8c7..HEAD -- Sources App Package.swift` still EMPTY. Pre-claim: `guard.sh --author` OK (idle 4,186 s); both strict guards and the loose form EMPTY; 0 sims; `stage status` → held by `coord-for-vx336` ("GO pending: vx336-u8"). The exact line run: `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u8 --reason "VX-336 U8: 66-suite batch + red, SEAM, then A1 + guide MCP chapter walk (Study, Terminal) + real-client round + read_note re-probes on the Debug dev store" --minutes 100` → **STAGE RELEASED (was 'coord-for-vx336') · STAGE CLAIMED by 'vx336-u8' for 100 min at 23:07:35 MDT** (expires 00:47:35) |
| 1a | the Mac batch (66 suites on `vx336-u8`, `test-without-building`, detached + polled) | DONE (23:07:44 → 23:12:44) — from `App/Variorum/`, the 66 `-only-testing:VariorumTests/<Suite>`, `-resultBundlePath …/u8/u8-batch.xcresult`, detached to `u8/logs/u8-batch.log`, polled. **"✔ Test run with 432 tests in 66 suites passed after 270.211 seconds" · `** TEST EXECUTE SUCCEEDED **`.** The result bundle: **Passed — 432 total · 429 passed · 0 failed · 3 skipped · 0 expected failures**, 66 suites seen (per-test results `u8/u8-batch-tests.json`). The 3 skips are EXACTLY the plan's three gated capture harnesses (`MCPGrantSheetU2CaptureTests` "13n-c U2…", `MCPPaneTabsCaptureTests` "VX-281 U1…", `TutorialMCPChapterCaptureTests` "13n-c U5…", one test each). **`TutorialMCPChapterTests` 8/8 ✔ — its FIRST run, green on the final tree** (all eight by name). No «Issues recorded without an associated test». **Zero reds — no finding.** The test host exited (every guard EMPTY after) |
| 1b | THE RED RUN on `vx336-u8-red` (`TutorialMCPChapterTests` alone) | DONE (23:12:50 → 23:13:31) — `-xctestrun DerivedData/vx336-u8-red/…xctestrun -only-testing:VariorumTests/TutorialMCPChapterTests` → `u8/logs/u8b-red.log`: **"✘ Test run with 8 tests in 1 suite failed after 5.971 seconds with 30 issues" — EXACT: 8 tests · 6 failed · 30 issues, test by test 3 · 1 · 10 · 9 · 2 · 5** (`theChapterIsSevenLessons…` 3 at `:176`, `:189` ×2 · `lessonOne…` 1 at `:247` · `lessonTwo…` 10 at `:294 :295 :354 :356 :358 :364 :368 :423 :424 :429` · `lessonThree…` 9 at `:458 :463 :490 :508 :509 :520 :522 :531 :540` · `lessonSix…` 2 at `:941 :987` (the `#require` on recipe 5's opening ends it) · `lessonSeven…` 5 at `:1112 :1126 :1160 :1191 :1194`); **`lessonFourWhatAlwaysAsks` ✔ and `lessonFiveSharingFromWhereYouAre` ✔**. **Every one of the 30 is an expectation on the chapter's WORDS** (`text.contains` / `!text.contains` / `text.range(of:)` / the per-lesson "gathering" list / the em-dash guard) — none on a tie or an executed act. With 1a's 8/8: **the pins red on the old seed and green on the new.** The red product then DELETED (`DerivedData/vx336-u8-red`; 58 GiB free) |
| SEAM | 1a/1b counts recorded, committed, pushed; the claim KEPT | DONE (23:14) — the claim `vx336-u8` held (~7 of 100 min used; expires 00:47:35); no instance; nothing launched; no A1 yet. **The coordinator's "continue" was PRE-GIVEN in the GO**, so the turn did NOT end: straight on to step 2 |
| 2 | prefs export, `Backups/` listing, the store listing, the fingerprint BEFORE, the clipboard saved | DONE (23:14:20) — every guard EMPTY first. Prefs exported **1,602 keys** (`variorum.whatsNew.lastVersion` 0.9.6, `appearanceChoice` system) → `u8/prefs-pre.plist` (the restore target). `Backups/` **57 entries** (`u8/backups-pre.txt`); the store listing `u8/store-listing-pre.txt` (`variorum.sqlite` 08:50, `-wal` 09:17, `-shm` 23:13, the two key files); `safety-copies/` holds only castle-W1. Her user-scope servers BEFORE `['linear-server', 'variorum']` **`bc64543e2f4e8e58`** — SAME (`u8/userscope-pre.txt`). The clipboard saved: **0 bytes** (empty; `u8w/clip-before.txt`) |
| 3 | THE ONE A1 (`stage.sh`'s copy loop only; cmp + sha256) | DONE (23:14:27) — strict and loose guards EMPTY; **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T051427Z`** (`u8/a1-path.txt`): five files, each `cmp`-verified; sha256 prefixes (`u8/store-hash-pre.txt`) sqlite `c17923414b2e` · wal `7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890` — **EQUAL to U5's, U6's and U7's A1 sets**; castle-W1 untouched |
| 4 | launch `vx336-u8` (Study expected) | DONE (23:14:33) — `guard.sh --author` OK; `open -n …/vx336-u8/…/Variorum.app` → **pid 86346** (both strict guards show it, the `vx336-u8` path), window 1380×900 at (60,36); **Study, light, the Bookcase; no What's New sheet, no lock screen** (`live/s/00-launch`) |
| 5 | sherlock present | DONE — "the adventures of sherlock holmes" on Welcome (13 notes · 13 ch · 105,335w · owned) — no restore needed (`live/s/01-sherlock`); the OLD guide on Welcome too (49 notes · 11 ch · 341% of 4,000w) |
| 6 | the fresh guide through Help ▸ Restore Tutorial… (confirm, receipt, the old guide in the Trash) | **PROVEN, the receipt's words not seen** (23:15–23:17). Help ▸ **Restore Tutorial…** (by AX, `keys.sh`) → the confirm (a SwiftUI alert as its own 260×330 window; `live/s/02-confirm`): **"Restore the tutorial?" · "This replaces the tutorial with a fresh copy: every note tagged exactly “tutorial”, every pool named “tutorial scraps”, and every book named “the field guide” are deleted and re-seeded. It also sets up the Welcome shelf the books chapter walks: …" · Cancel · Replace** → **Replace** (by AX description). The act is async: at +4 s (`03-fresh`) the Bookcase showed the guide mid-seed (UNSHELVED, 40 notes); at +19 s **the fresh guide OPEN in Outline: "book · 11 chapters · 49 notes"** (`03b-fresh-later`), and the Bookcase then shows **"the field guide" on Welcome, 49 notes · 11 ch · 361% of 4,000w** (`03c-bookcase-after` — the old was 341%). **The receipt "The tutorial is fresh — … on the “Welcome” shelf." was NOT captured:** it lands with the open, between the two captures, and had faded by +19 s (the async seed under a load of ~6–12); its words are `WelcomeDoorCopy.tutorialRestored`, pinned headless, and its two facts (the guide on the Bookcase, on Welcome) are seen. **The Library's Trash** (`04-trash`): **"the field guide" book · "tutorial scraps" snippet group · the old lessons ("lenses", "read", "sharing from where you are", "start here", "connecting a client", …), each "deleted Oct 14, 2026 at 11:15 PM · 30 days left" with Put back · Delete Now** — the re-seed note's own claim, seen |
| 7 | the chapter walk, Study (C0 outline, C1–C7 + scrolls) against THE CHAPTER AS BUILT | **PROVEN in Study** (23:17–23:22). The guide's navigator: chapter **"AI & the MCP door"** after "keeping it private", its seven lessons in order — what the door is · connecting a client · how much, where, how long · what always asks · sharing from where you are · how to use it · seeing, answering, undoing (`C0b-nav`); its press scrolls the Outline to the chapter's cards (`C0-outline`). Each lesson by ⌘K → its title → ⏎, each opening in Write AT ITS START (the caret before the first word, a first open): **C1** 3 paragraphs · **C2** 5 · **C3** + **C3b** 8 (to "leave it off unless that is what you mean.") · **C4** 4 · **C5** 3 · **C6** + **C6b** 7 (to "…which ones landed before it carries on.") · **C7** 5 — **every paragraph present, in order, word for word against THE CHAPTER AS BUILT, nothing clipped**; the only em dash is lesson 4's quoted "Private — never shared with AI"; lesson 3 renders "like ‹name› · english" and lesson 7 "“‹name› checked its recent activity”"; every lesson "in the field guide" (the fresh one), "edited today 11:16 PM" |
| 8 | connect (the key only), the bind turn, THE ADVICE from bytes (`instructions.py bind`), THE GRANT Home · Write new · Always | **PROVEN** (23:20–23:22). App menu ▸ **MCP Settings…** (by AX) → the Settings window 748×552 at (200,33): **the switch ON, "running · socket in the app container · serves while Variorum is open"**; Clients: claude-code "last seen 4 days ago · 3 grants", u3-walk, u2-walk, u1-walk (`05a-mcp-pane`). **Connect ▸ Claude Code ▸ the copy icon** (`05b-connect`; the block shows this product's shim path) → from the clipboard ONLY the key (**`vmk2_clau…`**, 60 characters, the `vmk2_claude-code_` prefix) into `u8w/keys/u7.key` (dir 700, file 600); never the copied line, never `-s local`, never her user scope; **the clipboard emptied at once** (0 bytes). **The bind turn** (23:21:09–23:21:19, `u8/bind.jsonl`, `tee/bind-*`): `variorum-dev` "connected" (dynamic), model `claude-fable-5`; `initialize` → serverInfo `variorum` 0.9.6; **`tools/list` 62 tools, `list_my_activity` and `read_note` among them**; the answer "list_books returned 1 book: “o ladrão de raios” (6 notes, in the Home wing)". **Activity: "claude-code connected with a new setup, now bound to its name"** then "claude-code listed books" — ZERO clicks, the BIND arm (`05-bind`). **THE ADVICE, from BYTES** (`instructions.py bind` → `u8/bind-instructions.txt`): **2,969 code points — EXACTLY U8a's Swift count**; first line "Variorum is a writing app; this server is the door to its li…"; **last line EXACTLY "The guide to this door: https://stargazing.tech/variorum/mcp"**; **CARRIES ×4** ("Once approved, list_my_activity is always listed" · the organization sentence "Help the author stay organized: put plans, summaries and research into notes, not just chat; file notes into books and chapters; tag them, and make books that collect by tag rules." · "Three acts are the author's alone" · the link) — **the real client received U8a's advice whole.** **THE GRANT:** Clients ▸ claude-code ▸ Change… → "Grant access — claude-code" (it opened on A book · the field guide · Read — `06a-change`) → **A wing · Home** ("everything in Home except your daily Journal and anything Private, which always ask" — `06b-wing`) → **Write new** ("it can also make new notes, apply tags and build books") · Always → **"Grant write new in “Home” always, including notes added later"** (`06-grant`) → Shared with AI: **"Home · wing · claude-code · read, suggest and write new · always"** atop the standing "o ladrão de raios" rows (`07-row`) |
| 9 | THE ORGANIZATION ASK (`U8-org`; `instructions.py` + `measure.py`), her face in Study | **(a) (b) (d) PASS · (c) FAILS BY ITS LETTER: one REFUSED call — a FINDING for the orchestrator (two observations below), not a product red under the plan's rule** (23:22:28–23:23:47; `u8/U8-org.jsonl`, `tee/U8-org-*`, `U8-org-instructions.txt`, `U8-org-measure.txt`). The advice again: 2,969 code points, CARRIES ×4. **THE ACTS, IN ORDER (from the wire):** (1) `list_books {}` ok; (2) **`create_book`** `{name "Green Tea Brewing — blog research", wing_id ""}` ok → `book_id E47CF87D…`; (3) **`set_book_rule`** `{rule {tag "green-tea"}, outflow ["green-tea"], new_matches "join"}` ok → `changed true, collecting true, minted_tags 1, matches_wait "Saved — this write makes no note a member; undecided matches wait at Arrivals for the author to let in."` — **the strongest form: a book that collects by a tag rule, with the tag as its outflow**; (4) **`create_note`** `{book_id E47CF87D…, title "Green tea brewing — research summary", blocks: 6}` ok → `note_id 3F1D2A78…`, six `block_ids`, **`tag_ids: []`**; (5) **`apply_tag`** `{note_id 3F1D2A78…, tag "green-tea"}` → **REFUSED, the wire text EXACTLY `Refused: alreadyTagged(tagID: "006D2ECE-966F-4D19-88B6-DB1854A7BC53", targetID: "3F1D2A78-2765-4E6A-96AF-E4D5340BCF8C")`** (119 characters). Every answer INLINE (1,130 · 93 · 338 · 1,786 · 119). **(a) PASS** — the summary is a NOTE (six blocks: water temperature, leaf amount, steep time, re-steeping, open threads); **(b) PASS** — a book, a tag rule with outflow, the note filed in it (no chapters); **(c) FAILS by its letter** — the one REFUSED is a redundant `apply_tag` on a note the book's OUTFLOW had already tagged; **(d) PASS** — the closing lines: "I created a book in Home called Green Tea Brewing — blog research and wrote the summary into it as a note … The book collects by the tag green-tea and also stamps that tag on anything written inside it — so future research joins automatically whether you tag a note green-tea anywhere in the library or just write it straight into the book. New matches join quietly at the end …" (and it read the refusal right: "the note already wore the tag (the book applied it automatically)"). **Her face, Study:** the Bookcase **"Green Tea Brewing — blog research" #green-tea · 1 note · 402w · living**, Unshelved, wearing the shared icon (`08-org-bookcase`); the Library: the book, and **"Green tea brewing — research summary" wearing `green-tea`**, edited 11:23 PM (`09-org-library`); Activity: **"claude-code was refused tagging “Green tea brewing — research summary”" (muted)** · "claude-code made the note “Green tea brewing — research summary”" · "claude-code set what “Green Tea Brewing — blog research” collects" · "claude-code made the book “Green Tea Brewing — blog research”" · "claude-code listed books (2 times)" (`10-org-activity`). **THE FINDING (two observations, for the orchestrator; nothing fixed):** **(F1)** `create_note`'s answer says `tag_ids: []` for a note filed into a book whose outflow tags it in the same act, so the client cannot see the tag landed and tagged again; **(F2)** the wire refusal for that redundant tag is the RAW ENUM (`OperationError.alreadyTagged` has no words in `OpsRefusalTable`, so `OpsRefusalCopy.message(for:)` falls to its `"Refused: \(error)"` fallback, `App/Variorum/Shared/OpsRefusalTable.swift:383`; the MCP door's chain `MCPWireRefusalCopy.words ?? hooks.refusalWords ?? String(describing:)`, `MCPWriteTools.swift:730`) — UUIDs and a Swift case name on the wire, where every other refusal is a sentence. Both predate this run's diff (the table's fallback since 13n-b) |
| 10 | U7c's RE-PROBE (U7c-200 · U7c-100 · U7c-ids-200, each measured alone from bytes) | **ALL THREE INLINE — U7c's cap PROVEN on a real client** (23:25:11–23:27:02; ONE read per turn; `u8/U7c-*.jsonl`, `tee/U7c-*`, `U7c-*-measure.txt`; Claude Code 2.1.300, model `claude-fable-5`, `MAX_MCP_OUTPUT_TOKENS` unset). The note: sherlock ▸ "The Red-Headed League" (`829C81B9…`). **(1) limit 200 → 71 blocks, the answer 31,825 characters (UTF-16 = code points here), `next_cursor` present, `block_count` 215, take text 16,673 — INLINE** (the model received exactly the server's text; context +15,360 tokens); **(2) limit 100 → the SAME 71-block page, 31,825 characters — INLINE** (the answer bound ends it before the limit); **(3) `ids_only` limit 200 → 115 blocks, 31,751 characters, `next_cursor`, `block_count` 215, 0 take text — INLINE** (context +20,341 tokens). Every answer ≤ 32,000. The model's own words, each: "JSON I could read in full". **Against the plan's numbers (72 / ≈31,950 and 116 / ≈31,930): one block FEWER each, not a red** — the bound is the ANSWER's size and it held; the dev store's first page carries a 444-character header (`books` with sherlock's `section_id` and `section_name` "The Red-Headed League") and every record a `comments` key, so the next block would have crossed 32,000. For contrast, U7's window: limit 200 → 161 blocks, 65,807 characters, saved to a file |
| 11 | the Terminal pass (the chapter again + Activity) → back to Study | **PROVEN in Terminal** (23:29–23:36). Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control — `t/00a-general`, `t/00-theme`). The guide's navigator: **"ai & the mcp door"** with its seven lessons in order (`t/C0b-nav`); its press → the Outline's seven cards (`t/C0-outline`). Each lesson by ⌘K → its title → ⏎ (in-session RE-opens: lessons 3 and 6 came back at the page left, scrolled to their tops): **C1** 3 · **C2** 5 · **C3** + **C3b** 8 · **C4** 4 · **C5** 3 · **C6** 7 (one capture) · **C7** 5 paragraphs — **every paragraph present, in order, word for word, nothing clipped**, in the voice's monospace and "~/the field guide"; the one em dash lesson 4's quoted Private row; "‹name› · english" and "“‹name› checked its recent activity”" render; the note's context bar wears the shared icon at its right end (the Home grant — lesson 7's own sentence, seen). **Activity in Terminal** (`t/10-activity`): the three re-probe reads "claude-code read “The Red-Headed League”" with their list lines; its "all 152 ›" sheet (`t/10b-activity-all`, `t/10c-activity-org`) shows step 9's lines — "claude-code was refused tagging “Green tea brewing — research summary”" (muted) · "made the note …" · "set what “Green Tea Brewing — blog research” collects" · "made the book …" · "listed books (2 times)" · "connected with a new setup, now bound to its name"; Done. Theme back to **Study** (Appearance Follow system, palette Default — `s/11-back-study`) |
| 12 | cleanup → quit by bundle id, key grep 0 + `keys/` deleted, clipboard restored, no `mcpServers` for the scratch project, fingerprint SAME, prefs 0 differ, `restore.sh` cmp-SAME + sha256 equal, `Backups/` unchanged, castle-W1 untouched, 0 sims; release; THE RESULT LINE | DONE (23:33:01–23:33:52) — **the Debug app quit BY BUNDLE ID** (`tell application id "io.lduarte.Variorum.debug" to quit`; gone within 1 s): both strict guards and the loose form EMPTY; no `variorum-mcp`, no turn (`keys/cfg-`), no relay of ours; her `/Applications` app never running. **The key** (read whole from `keys/u7.key`, 60 characters) grepped over `u8/`, `~/.claude.json`, `~/.claude/projects/` (the whole tree), `notes/` + `Tools/`, and the whole scratchpad outside `keys/` → **0 files** (only `keys/` held it: `u7.key` + the five `cfg-*.json`); then **`keys/` DELETED**. **The clipboard RESTORED** (0 bytes before and after, `pbpaste \| cmp` SAME), the saved copy deleted. **No `-s local` registration was ever made:** `~/.claude.json` has NO `projects` entry for `u8w/proj` (read-only `python3 -I`; never `claude mcp get`/`list`); no saved-to-file tool result exists under the scratch project's `~/.claude/projects/…-u8w-proj/` (every answer was inline). **Her user-scope servers AFTER `['linear-server', 'variorum']` `bc64543e2f4e8e58` — SAME** (`u8/userscope-post.txt`). **Prefs:** the window added 7 keys (`currentBlock.<id>` ×7 — the lessons opened) and changed 5 (`IdleCommitSweepMark.Variorum-dev`, the Settings window frame, `openNotes.remembered.ids`/`.recency`, `variorum.backup.log`) (`u8/prefs-window-diff.txt`) → `defaults import prefs-pre.plist` + `defaults delete` of the 7 → re-export **1,602 keys, 0 added · 0 removed · 0 changed** (`u8/prefs-post.plist`). **The dev store:** `Tools/ScaleFixture/restore.sh …/scale-prestage-20261015T051427Z` → **"Restored (verified)"** (`u8/logs/restore.log`), a second `cmp` of all five files **SAME**, the sha256 set **EQUAL** to the A1's (`store-hash-restored.txt` = `store-hash-pre.txt`) — Standard, unlocked, Study, claude-code's pre-window binding and its three "o ladrão de raios" grants back (the fresh guide, the old guide's Trash rows, the Home write-new grant, the green-tea book and note — every window write — gone with it); the store folder's names unchanged (two key files). `Backups/` names **UNCHANGED** (57 entries); `safety-copies/` holds `castle-W1-20261013` (untouched, its Oct 13 stamps) + this window's A1. **0 simulators booted**; no stray `default.profraw`; the tree clean; 58 GiB free. **RELEASED 23:33:52 MDT** (`Tools/stage release --who vx336-u8` → STAGE RELEASED (was 'vx336-u8'); `status` → STAGE FREE), ~26 of the 100 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx336-u8` 23:07:35–23:33:52 MDT, RELEASED (~26 of 100 min); the batch and the red run first, the SEAM (its "continue" pre-given), then the rest.
- **U7c's RE-PROBE (first): ALL THREE INLINE, read from bytes** (Claude Code 2.1.300, `MAX_MCP_OUTPUT_TOKENS` unset, sherlock ▸ "The Red-Headed League", `block_count` 215): limit 200 → 71 blocks, 31,825 characters, `next_cursor` · limit 100 → the same 71-block page, 31,825 · `ids_only` limit 200 → 115 blocks, 31,751 — every answer ≤ 32,000 and received by the model exactly as sent (U7's window: 65,807 characters, saved to a file). One block fewer than the harness predicted on each (the dev store's first page carries sherlock's chapter in `books` and a `comments` key per record); the bound held.
- **The Mac batch (66 suites, `vx336-u8`):** 432 tests — 429 passed · 0 failed · 3 gated capture skips (exactly the plan's three); `TutorialMCPChapterTests` 8/8 on its first run.
- **The red run (`vx336-u8-red`, the old seed):** EXACT — 8 tests · 6 failed · 30 issues (3 · 1 · 10 · 9 · 2 · 5; lessons 4 and 5 green), every issue on the chapter's words. The red product deleted.
- **The fresh guide through Help ▸ Restore Tutorial… PROVEN:** the confirm's words, the fresh guide open (49 notes, 11 chapters) and on Welcome, the old guide and its lessons in the Trash (30 days, Put back · Delete Now). The receipt's words were not captured (the async seed; it faded before the capture) — its two facts were seen.
- **The chapter walk PROVEN in both voices:** "AI & the MCP door", seven lessons in order, every paragraph word for word against THE CHAPTER AS BUILT, nothing clipped, the one em dash lesson 4's quoted Private row, "‹name› · english" and "“‹name› checked its recent activity”" rendered; Study (first opens at their start) and Terminal.
- **The advice from bytes PROVEN:** the bind with zero clicks ("claude-code connected with a new setup, now bound to its name"); `initialize`'s instructions 2,969 code points (U8a's count), the last line exactly "The guide to this door: https://stargazing.tech/variorum/mcp", CARRIES ×4; 62 tools.
- **The organization ask: (a) (b) (d) PASS, (c) FAILS by its letter — a FINDING.** The client (no names given) made a book "Green Tea Brewing — blog research", gave it a tag rule `green-tea` with the tag as its outflow (`new_matches` join), and filed the summary note in it (six blocks) — the advice's strongest form; Activity and the Bookcase show it ("living", wearing the icon). One redundant `apply_tag` was REFUSED, because the outflow had already tagged the note. Two observations: (F1) `create_note`'s answer says `tag_ids: []` when the book's outflow tags the note in the same act; (F2) the wire refusal for it is the raw enum `Refused: alreadyTagged(tagID: "…", targetID: "…")` — `alreadyTagged` has no words in `OpsRefusalTable` (fallback at `App/Variorum/Shared/OpsRefusalTable.swift:383`). Both predate this run's diff.
- **Posture:** dev store cmp-SAME vs A1 (sha256 set equal), prefs 0 differ (1,602 keys), fingerprint SAME (`bc64543e2f4e8e58`), clipboard restored (0 bytes), Standard/unlocked, Study, castle-W1 untouched, `Backups/` unchanged (57), no `-s local` registration, the whole-key grep 0, `keys/` deleted, no instance left, 0 simulators booted.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T051427Z`.

**Noticed, not fixed (no product change under the claim):**
1. **The organization leg's finding** (F1, F2 above) — for the orchestrator: whether `create_note` should list the outflow's tags in `tag_ids` (or a separate field), and words for `alreadyTagged` on the wire (and in the Mac table).
2. **The re-probe's one-block difference** from the harness's prediction (71 vs 72, 115 vs 116) — explained by the dev store's first-page header and per-record keys; not a red.
3. **The Restore Tutorial receipt** lands only when the async seed finishes (≈ 5–19 s under load) and fades within ~15 s, so a runner's capture missed it; the act's result (the guide open, on Welcome) is the evidence here.
4. **The model named the book with an em dash** ("Green Tea Brewing — blog research") — its own choice of name, outside the product's words.

### THE ORCHESTRATOR ON U8's WINDOW (2026-10-14 ~23:40 MDT)

- **Verified, not trusted:** the stage reads FREE; no instance; her fingerprint SAME (`bc64543e2f4e8e58`, re-read by the
  orchestrator); the tree is clean at `092adc56`.
- **U8 is PROVEN.** VX-197 closes at the merge.
- **U7c's re-probe closes VX-256's last open evidence:** all three pages arrived INLINE. VX-256 is PROVEN whole.
- **The receipt words** for Help ▸ Restore Tutorial… faded before the capture. Its two facts (a fresh guide on the
  Bookcase, on Welcome) were SEEN and the old guide was in the Trash, so this is recorded, not owed.
- **F1/F2 → VX-361/VX-362, U9** (provisional ruling 1), before the ladder.

## U9 UNIT RECORD — two wire truths from U8's round: VX-361 · VX-362 (opus-implementer, from 2026-10-14 ~23:55 MDT)

**What this unit has NOT done (said first; updated at every piece):** (1) **No Mac or phone test has RUN** — the Mac sweep pin,
the Mac batch and the phone pins wait for THE STAGE WINDOW (built: two finals, two reds); pieces 1–7 are done; the Mac and phone reds run only in the window. (2) No stage window yet, no live round.
(3) VX-364 (the dangling-wing outflow) and VX-365 (`add_note_to_book`'s answer) are tickets, NOT this unit's (the
orchestrator's rulings). *(Piece 0's own line, kept: piece 0 was the design and stopped for the ruling on F-1.)*

**THE BUILDER (pieces 1–7 + VX-363): a fresh `opus-implementer`, from 2026-10-15 ~00:05 MDT** (the designer stopped at
~447k after piece 0). Read in its own context before any code: this record's header, Hard rules (never `claude mcp
list`), ORCHESTRATOR'S PROVISIONAL RULINGS 1–2, the U9 BRIEF, this U9 UNIT RECORD whole and THE ORCHESTRATOR'S RULINGS ON
U9's FORKS; VX-246's U1 record on VX-259 (the brief, the trace, the fix row, the self-assessment line);
`notes/MCPSpec.md` whole; `notes/SessionResiliencyProtocol.md`'s implementer section; the code the build plan names
(re-verified at `0f011e10`: `land` l.730, `itemized` l.238, `noteAnswer` l.812, the `apply_tag` arm l.475,
`mintNoteEntry` l.538, `applyTagPath` l.621, `applyDocumentTags` l.305, `importBook` l.149/l.600, `requireBookNameFree`
l.945, `addPostToReading` l.738 → `applyAutoTag` l.310, `OperationError.swift` whole, `OpsRefusalTable.swift` whole, the
Mac half `macWords`, `MCPDoor`'s hook l.404, `readableBooks` l.774) and the sweep tool's output (68 reachable · 40
unreachable · 0 thrown nowhere — the record's table re-derived from it: W 65 = 42 reachable + 23 graph-unreachable; C 2;
U-hand 13; R/E 10; X 1; U-graph 17).

**Read in full before any code (never delegated):** this record's header, Hard rules (incl. never `claude mcp list`),
LIVE STATUS, ORCHESTRATOR'S PROVISIONAL RULINGS (ruling 1), the U9 BRIEF, the U8 STAGE RUN (its organization leg, step
9, F1/F2 and the result line), THE ORCHESTRATOR ON U8's WINDOW, U5b's D1 and its rulings; `notes/MCPSpec.md` whole;
`notes/SessionResiliencyProtocol.md`'s implementer section; the code — `MCPWriteTools.swift` (the `create_note` /
`import_document` / `apply_tag` arms, `noteAnswer`, `land`), `MCPWriteTools+RemoveTag.swift`, `+Batches.swift`
(`itemized`), `+Carriage.swift` (`set_book_rule`), `+NoteEdits.swift` (`restore_comment`), `+LibraryEdits.swift`,
`+WingMove.swift`, `MCPWriteSupport.swift` (`MCPWireRefusalCopy`, `MCPHostHooks.refusalWords`), `MCPReadTools.swift` /
`MCPShowTool.swift` / `MCPSession.swift` (their error roads); core `Operations+Tag.swift`, `Operations+MCPWrites.swift`
(`mintNoteEntry`, `applyTagPath`, `removeTagForClient`), `Operations+Intake.swift` (`insertPostTag`, `applyAutoTag`,
`writeReadingOutflow`), `Operations+Reading.swift` (`addPostToReading`, `newPostInReading`), `Operations+DocumentImport.swift`
(`DocumentImport`, `applyDocumentTags`, `importBook`), `OperationError.swift` whole; `App/Variorum/Shared/OpsRefusalTable.swift`
whole and the Mac half `Registry/OpsRefusalCopy.swift` (`macWords`, `message(for:)`), `MCPDoor.swift`'s hook (l.404);
her doors catching `alreadyTagged` (`BlockTOCView` l.634, `TutorialSeeder` l.1898, `LibraryCatalogTagActs` l.36,
`PoolPostsView` l.183, `SnippetsSurface` l.438, `TypedTagPath` l.155, `Operations+Quicknote` l.90) and her
`alreadyInReading` words (`ReadingsViewModel.message`, `MembershipChip`, `MembershipChoice`, `MobileMembership`);
`OpsRefusalTableIntegrityTests`; the tests around `apply_tag` (`MCPWriteActsTests` l.247, `MCPWriteServerTests` l.513)
and the minted answer (`MCPMintedAnswerServerTests`).

### LIVE STATUS — U9's pieces (flipped in the same commit as each piece)

| piece | what | status |
|---|---|---|
| 0 | the design: traces (probed), F-1 proposed, F-2/F-3 argued, THE SWEEP TABLE, the build plan | DONE (`cd11c83e`) — ruled (THE ORCHESTRATOR'S RULINGS ON U9's FORKS, `0f011e10`) |
| 1 | refactor, behaviour-neutral: the wire's ONE refusal chain named (`MCPWireRefusalCopy.spoken`), used by `land` and `itemized` | DONE (this commit) — `MCPWriteSupport.swift` `MCPWireRefusalCopy.spoken(_:appWords:)` = `words(e) ?? appWords(e) ?? String(describing: e)`; `land` (`MCPWriteTools.swift` l.730) and `itemized` (`+Batches.swift` l.238) call it with `hooks.refusalWords` — the same three steps in the same order, nothing else touched. **Headless: `swift build` clean; `swift test --filter 'MCPBatchDoorsServerTests|MCPWriteServerTests|MCPCarriageServerTests|MCPWingMoveServerTests'` → "Test run with 37 tests in 4 suites passed"** (the suites holding `land`'s and `itemized`'s raw-`Refused:` pins, unmodified; `u9/logs/p1-refactor.log`). The whole MCP target runs at piece 6 |
| 2 | the pins, red on the old tree (headless VX-361 · VX-362 (a) · the wire-copy row; the Mac sweep pin; the phone guard's re-point + its parity line) | DONE (this commit) — **NEW `Tests/VariorumMCPTests/MCPTagTruthServerTests.swift`** (8 tests, the wire over a real socket + one table row): VX-361 `createNoteIntoAnOutflowBookAnswersTheTagItWears` · `aDocumentWhoseHeaderNamesTheOutflowTagLandsAndListsItOnce` (the collision) · `headerTagsComeFirstThenTheOutflowsOthersInOutflowOrder` (outflow [green-tea, research]; header {#steeping} → [steeping, green-tea, research]; header {#research} {#steeping} → [research, steeping, green-tea]) · `aBooklessNoteAnswersItsHeadersTagsAndTheirPaths`; VX-362 (a) `applyingATagTheNoteWearsAnswersUnchangedWithNothingToUndo` (the first `changed: true`; the second `changed: false`, the same `tag_id`, undo depth and top label unchanged, no receipt, one application, Activity `allowed` ×2) · `theOrganizationRoundsRedundantTagIsUnchanged` (U8's round: create_note into the outflow book, then apply_tag green-tea); GUARD `removingATagTheNoteDoesNotWearStillRefusesInWords`; VX-362 (b)'s wire row `anEntryDateTheOpRefusesSpeaksTheWiresParseSentence`. **RED ON THE OLD TREE (read from `u9/logs/p2-pins-red.log`): "Test run with 8 tests in 1 suite failed … with 18 issues" — 7 failed, the guard green; per test 2 · 3 · 4 · 2 · 4 · 2 · 0 · 1** (the answers' `tag_ids` [] and no `tags`; the import refused whole, so its answer was not JSON; the redundant apply refused; `words(.invalidEntryDate)` nil). **NEW Mac `App/Variorum/VariorumTests/MCPWireRefusalSweepTests.swift`** (3 tests): the enum read by `#filePath` and ONE sample per case (108 = 108, checked by script at authoring), the 33 unspoken cases each with its proof line (U-graph 17 · U-hand 13 · X 1 · C 2), and the other 75 run through `MCPWireRefusalCopy.spoken(e) { OpsRefusalCopy.message(for: $0) }` — none may start "Refused:", carry `<case>(`, or equal the description. **Predicted red on the old tree: 1 test (the walk), 20 issues — the ten R/E cases × (prefix, name)**; PENDING — the window's red run on `vx336-u9-red`. **The phone `MobileRefusalTableTests`:** the guard `eachSiteKeepsItsOwnFallbackWhereTheTableHasNoWords` RE-POINTED from `containerNotFound` (worded by this unit) to `referenceNotFound` (U-graph, stays unworded) — a justified edit, commented in place; NEW `theSweepsNoteGoneSentenceReachesEveryFallThroughSite` (MOBILE PARITY: the five fall-through sites speak the new note-gone sentence). **Predicted phone red: 1 test, 5 issues**; PENDING — the window's simulator red run on `vx336-u9-ios-red`. *(Found at authoring, against the design's MOBILE PARITY line "no phone pin changes": the phone guard used `containerNotFound` as its unworded sample, so a phone pin DOES change and the window gets ONE simulator.)* |
| 2b | **VX-363** — the pin, red on the old tree (`import_document`'s book form beside a hidden book's name) | DONE (this commit) — NEW test in VX-259's suite `Tests/VariorumMCPTests/MCPBookNameReachServerTests.swift`: `importingABookBesideAHiddenBooksNameLandsAndNamesNothing` — a Private Home book "secret", another wing's "ledger", a readable Home "letters"; a write-new Home wing grant; `import_document {wing_id: "", book: {name: "SECRET" / "Ledger", documents: [one]}}` must LAND naming neither hidden book (the stored name is the client's spelling — a duplicate, as ruled), the hidden book untouched; the control "LETTERS" still refuses naming "letters"; and a guard on both trees: her own `importBook` (no reach) refuses `duplicateBookName(name: "secret")` — E13 whole at her doors. **RED ON THE OLD TREE (`u9/logs/p2b-vx363-red.log`): "Test run with 4 tests in 1 suite failed … with 4 issues" — the new test 2 × (refused; echoed), the wire saying `Refused: duplicateBookName(name: "secret")` and `…"ledger")` (the harness's words; the app's would be `BookNameCopy`'s "A book named “secret” already exists…"); VX-259's three tests green.** *(The traced mechanism, re-read: `parseImport`'s book form → `MCPWriteTools.perform` `.importBook` → `ops.importBook(_:wingId:undoLabel:)` (`Operations+MCPWrites.swift:600`) → `importBook(_:wingId:shelfId:)` (`Operations+DocumentImport.swift:149`) → `requireBookNameFree(db, name)` l.165 with no `counting:` — every live, unarchived reading in every wing counts and the collider's stored name rides the refusal.)* |
| 3 | VX-361 — the fix (as ruled) + the import collision | DONE (this commit) — **core** `Operations+DocumentImport.swift`: `DocumentImport.tagIDs` now means every tag the note wears when the act lands, + NEW `tagPaths` (parallel); `applyDocumentTags` returns the header's `Tag`s and SKIPS-BUT-REPORTS one the note already wears (`liveApplication` first — the outflow's own rule; a file import's fresh note never meets it, byte-unchanged); `importDocument` fills both from the header. `Operations+MCPWrites.swift` `mintNoteEntry` keeps the destination book's `autoTagIDs` and composes the answer INSIDE the transaction through NEW `mintedNoteTags` (the note's live applications, joined to live tags: the header's in header order, then the outflow's in outflow order, then — a belt — any other by path; ∝ the act's own applications). **Wire** `noteAnswer` answers `tags` beside `tag_ids`; `create_note`'s and `import_document`'s descriptions gain their tag sentence (FOR VX-234). **GREEN (`u9/logs/p3-vx361-green.log`):** VX-361's four pins ✔; VX-362's three still red as they must be (its fix is piece 4/5); `MCPMintedAnswerServerTests` + `MCPWriteServerTests` green; core `DocumentImportOperationTests` + `MCPWriteActsTests` "33 tests in 2 suites passed" (unmodified — the file doors' header-only lists hold) |
| 3b | **VX-363** — the fix (`importBook` takes VX-259's `counting:`; the wire passes `readableBooks`) | DONE (this commit) — **core** `importBook(_:wingId:shelfId:namesCountedBy:)` (`Operations+DocumentImport.swift`; default nil) passes `counting: reach` to `requireBookNameFree`; the MCP overload `importBook(_:wingId:undoLabel:namesCountedBy:)` (`Operations+MCPWrites.swift`) passes it through both arms. **Wire** the `.importBook` arm passes `readableBooks(clientName)` — VX-259's one predicate (`decide(standing, reading: readPlace)`, the listing's rule, non-consuming, asked only of colliders); its doc names the third road. Her doors (`DocumentImporter.swift:156` — File ▸ Import… and the Bookcase drop) call the 3-argument form: nil, E13 whole. **NEW core contract pin** `MCPBookNameReachTests.theBookImportCountsOnlyWhatItIsToldTo` (a non-counting collider passed by and asked alone; nil refuses naming it) — a new parameter, red by its absence on the old tree (VX-259's own pattern). **GREEN (`u9/logs/p3b-vx363-green.log`):** `MCPBookNameReachServerTests` 4/4 (VX-363's server pin ✔), core `MCPBookNameReachTests` 2/2, `MCPWriteServerTests`, `DocumentImportOperationTests`, `MCPWriteActsTests` — "14 tests in 2 suites" + "35 tests in 3 suites" passed |
| 4 | VX-362 (a) — `apply_tag`'s no-op answer | DONE (this commit) — `MCPWriteTools.swift`'s `.applyTag` arm catches `OperationError.alreadyTagged(let worn, _)` around `applyTagPath` (the op's contract untouched — `MCPWriteActsTests`' throw pin unmodified): `tag_id` = the worn tag, `changed: false`, receipt nil; a landed apply answers `changed: true` (additive). The op threw, so its transaction rolled back and no undo entry registered; `land` logs the act's landed Activity line and spends a once grant as any landed call (D2). `flushesHerEditorFirst` unchanged (false — no take). `apply_tag`'s description: "Returns JSON with the tag_id and changed — false when the note already wore the tag: nothing was written and there is nothing to undo." (FOR VX-234). **GREEN (`u9/logs/p4-vx362a-green.log`):** VX-362 (a)'s two pins ✔ + the `remove_tag` guard ✔; `MCPWriteServerTests`, `MCPRemoveTagServerTests`, `MCPWireNeutralityTests`, `MCPProviderNeutralityTests` green; the one red left is the wire-copy row (piece 5) — "28 tests in 5 suites … 1 issue" |
| 5 | VX-362 (b) — the sweep's words (shared table + wire copy) | DONE (this commit) — **the wire copy** (`MCPWriteSupport.swift` `MCPWireRefusalCopy.words`): `.invalidEntryDate` → `MCPWriteTools.entryDateWords`, the parse's own sentence now named once (`MCPWriteTools.swift` — the parse's `ArgumentFailure` and the op's refusal speak the one constant). **The shared table** (`App/Variorum/Shared/OpsRefusalTable.swift`, a commented block before `default:`, each arm commented with its road): `alreadyInReading` · `readingAtCapacity` (her generic arm's two sentences, `ReadingsViewModel.message` — that arm KEPT as is, byte-identical, a one-line forward at its next touch: the plan's piece 5 names only the table) · `commentNotDeleted` · `invalidSectionName` · `containerNotFound` · `wrongReadingKind` (both directions — `.gathering` her bind door's, hoisted) · `tagNotFound` · `blockAlreadyPlaced` · `blockNotInContainer` (`blockNotPlaced`'s sentence). The words are FOR VX-234's list below, exactly as planned. **GREEN (`u9/logs/p5-vx362b-green.log`):** the wire-copy row ✔ — `MCPTagTruthServerTests` 8/8 now; `MCPWireNeutralityTests` (its source net reads `OpsRefusalTable.swift`), `MCPCarriageServerTests`, `MCPMintedAnswerServerTests` — "32 tests in 4 suites passed". The Mac sweep pin and the phone parity line compile and run only in Xcode: the products (piece 6), the runs (the window) |
| 6 | revert check (announced first), headless finals, `build-for-testing` (Mac + phone), red products | DONE (`c2f77ce9` + this commit) — **THE REVERT CHECK** all four arms EXACT and restored (its section below). **HEADLESS FINALS** (`u9/logs/p6-finals.log`, the whole package `swift test --skip-build` on `c2f77ce9`'s sources): **MCP 349 tests / 67 suites — 1 issue: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` 24.6 s > its 15 s bound (VX-353's load flake — load averages 30–37 from another session's builds at the time), plus the 1 KNOWN issue (VX-357's U+0000 pin); RE-RUN ALONE (`p6-timelimit-alone.log`) → "3 tests in 1 suite passed"** · **core 2,872 / 333 passed** · **workbook 40 / 6 passed**. **THE PRODUCTS** (52 → 46 GiB free): Mac final `App/Variorum/DerivedData/vx336-u9` from `c2f77ce9` (`build-mac-final.log`) and phone final `vx336-u9-ios` (`build-ios-final.log`, `generic/platform=iOS Simulator`) — each TEST BUILD SUCCEEDED, XCB-EXIT 0, zero `error:`, no warning in a touched file; the Mac app `Variorum.debug.dylib` carries the note-gone sentence ×1, create_note's tag sentence ×1, apply_tag's ×1 (the red `vx336-u9-red`: ×0 each); the phone dylib the note-gone sentence ×2 (two slices; the red ×0). Signed `io.lduarte.Variorum.debug`; shim `Contents/MacOS/variorum-mcp`; `Variorum_Variorum_macosx27.0-arm64.xctestrun` / `VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun`. Every batch suite below is a real type in its bundle (`nm -j` + `swift-demangle`). The red products: built at piece 2 from `ce4f2ed9` (above) |
| 7 | THE STAGE WINDOW plan (`vx336-u9`) → READY | DONE (this commit) — THE STAGE WINDOW below; the kit gains `prompts/U9-tags.txt` and `answers.py` (dry-run on U8's tee: it reads U8's `apply_tag` answer as `Refused: alreadyTagged(…)` from bytes — the control). **READY** |

### THE REVERT CHECK (piece 6 — ANNOUNCED here and committed BEFORE any arm runs; every count read from that arm's own log)

**NO REVERT IS IN FLIGHT — every arm ran and was RESTORED (the line below).** *(While it ran: a revert was in flight
from `104f4ab3` until RESTORED was filled.)* (a fresh session: `git diff HEAD
--stat` shows what is reverted right now; `git checkout HEAD -- Sources` restores it). One arm at a time, each a fix's
lines ONLY, applied to the working tree of this committed state, its pins run, then `git checkout HEAD --` of the
arm's files and `git status` clean before the next arm:
- **Arm A — VX-361** (`git diff 7ae1551a^ 7ae1551a -- Sources | git apply -R`: `applyDocumentTags`' skip-but-report,
  `tagPaths`, `mintedNoteTags`, `noteAnswer`'s `tags`, the two description sentences) → `swift test --filter
  MCPTagTruthServerTests`. **Predicted: VX-361's four pins red exactly as at piece 2 — 2 · 3 · 4 · 2 = 11 issues; the
  other four green** (VX-362 (a)'s two hold on their own fix; the guard; the wire row).
- **Arm B — VX-363** (the wire's one line only — the `.importBook` arm without `namesCountedBy:`; the core keeps its new
  parameter, so the core contract pin compiles and stays green, as VX-259's arm did) → `--filter MCPBookNameReach`.
  **Predicted: the server pin red, 4 issues (as at piece 2b); VX-259's three and the core pin green.**
- **Arm C — VX-362 (a)** (`git diff 0a6d9c78^ 0a6d9c78 -- Sources | git apply -R`: the `apply_tag` arm's catch and
  `changed`, the description) → `--filter MCPTagTruthServerTests`. **Predicted: VX-362 (a)'s two pins red — 4 · 2 = 6
  issues; the rest green.**
- **Arm D — VX-362 (b), the wire half** (`git diff b0be6e69^ b0be6e69 -- Sources | git apply -R`: the wire copy's
  `invalidEntryDate` arm and `entryDateWords`) → `--filter MCPTagTruthServerTests`. **Predicted: the wire row red, 1
  issue.** *(The shared table's nine arms are Mac/phone code: their red-on-old evidence is the RED PRODUCTS built from
  `ce4f2ed9` — no shared-table arm in them — run in the window: Mac 20 issues, phone 5.)*
- **THE RESULTS (each read from its own log, `u9/logs/`):** **Arm A** (`p6-armA-vx361.log`, 4 files reverted, +18 −86)
  → "8 tests … failed … with 11 issues": VX-361's four red 2 · 3 · 4 · 2 — **EXACT**; VX-362 (a)'s two, the guard and
  the wire row green. **Arm B** (`p6-armB-vx363.log`, the one wire line) → the server suite "4 tests … 4 issues", the new
  test red with 4, VX-259's three green; core `MCPBookNameReachTests` "2 tests … passed" — **EXACT**. **Arm C**
  (`p6-armC-vx362a.log`, +7 −26) → "8 tests … 6 issues": VX-362 (a)'s two red 4 · 2 — **EXACT**; VX-361's four green.
  **Arm D** (`p6-armD-vx362b.log`, +1 −13) → "8 tests … 1 issue": the wire row red — **EXACT**.
- **RESTORED:** after each arm `git checkout HEAD -- Sources`, `git status --short` empty (CLEAN-A…D); after the last,
  `git diff HEAD --stat` empty, and `swift test --filter 'MCPTagTruthServerTests|MCPBookNameReach'` → "12 tests in 2
  suites passed" + "2 tests in 1 suite passed" (`p6-restored.log`).

### The traces (written before code; each mechanism PROBED on the pre-fix tree `35f9cd70`)

The probe: a scratch `swift test` suite (never committed, deleted after) over the real wire (`ServerHarness`, the SDK
client on a socket; the harness's `refusalWords` is `"Refused: \(error)"`, the app table's fallback shape): a book with
outflow `[green-tea]`, a wing grant at write new. Its four answers, verbatim (ids are the harness's `.incrementing`):
- `create_note {book_id, text}` → `…"note_id":"…0004","tag_ids":[]}` while `post_tag` holds `green-tea` for the note.
- `apply_tag {note, "green-tea"}` → isError, `Refused: alreadyTagged(tagID: "…0000", targetID: "…0004")`.
- `import_document {book_id, document "{t:\"second\"} {#green-tea}\n\nSteep 2 minutes."}` → isError,
  `Refused: SQLite error 19: UNIQUE constraint failed: post_tag.tag_id, post_tag.post_id - while executing INSERT INTO "post_tag" …`
  — **the whole import refused**, a third finding in VX-361's class (below).
- `add_note_to_book` of the note again → isError, `Refused: alreadyInReading(postID: "…0004", readingID: "…0001")`.

**VX-361 — `tag_ids` misses the outflow (and the outflow breaks a tagged import).** `noteAnswer`
(`MCPWriteTools.swift:812`) answers `minted.tagIDs`; `mintNoteEntry` (`Operations+MCPWrites.swift:538`) builds it as
`applyDocumentTags(db, named.document.tagPaths, …)`'s return — the DOCUMENT HEADER's tags only. For a book destination the
hand-add runs first (`addPostToReading(db, …)` l.577, by design: "BEFORE the header's tags, so this book's own pair is
decided"), and the hand-add's last line applies the book's OUTFLOW (`applyAutoTag`, `Operations+Reading.swift:781` →
`Operations+Intake.swift:310` — each tag through `insertPostTag`, silent for a dangling tag, another wing's, or one
already worn). So a note minted into a book with an outflow WEARS the outflow's tags while the answer lists only the
header's: `create_note` (no header at all — `tagPaths: []`, l.445/494) always answers `[]`; one `import_document`
answers its header only. **The collision:** `applyDocumentTags` (`Operations+DocumentImport.swift:305`) inserts every
header tag with NO live-application check (it was written for a fresh, untagged note — `importDocument`, `importBook`'s
seat), so a header tag the outflow already applied hits `uq_post_tag_live` → `DatabaseError` → the wire's chain
(`land`, l.730: `MCPWireRefusalCopy.words ?? hooks.refusalWords ?? String(describing:)`) → the SQLite text, and the
transaction rolls the whole import back. The other doors: `importDocument` (the file door) mints bookless — no outflow;
`importBook` (the folder door and the wire's book form) mints a NEW book with no outflow — no collision, and its answer
has no tag field; `insert_blocks` mints blocks into an existing note — no tags; `duplicate_note` carries the source's
tags (17y B3 (c)) and answers no tag field — none of the three can say something false about tags. **Sibling (no false
field, OWED 4):** `add_note_to_book` also wears the outflow onto the note (the same hand-add) and its answer names no
tags — after F-2 a redundant `apply_tag` there answers `changed: false`, so the U8 failure cannot recur on that road.

**VX-362 — the raw case.** `applyTagPath` (`Operations+MCPWrites.swift:621`) throws `alreadyTagged` for a tag the note
already wears; the arm (`MCPWriteTools.swift:475`) does not catch it; `land`'s chain asks `MCPWireRefusalCopy.words`
(no arm — nil), then the app hook (`MCPDoor.swift:404`: `OpsRefusalCopy.message(for:)` → the Mac half's `macWords` (no
arm) → the shared `words(for:roads:)` (no arm) → `"Refused: \(error)"`, `OpsRefusalTable.swift:383`). **The error roads
of the whole door** (traced for the sweep): (1) `MCPWriteTools.land` — every write act's thrown error past `Refused` /
`ArgumentFailure`; (2) `MCPWriteTools.itemized` (the batches) — the same chain, prefixed by the item; (3) the outer
catches — `MCPWriteTools.call`, `MCPReadTools.call`, `MCPShowTool.call` — `"Variorum couldn't complete X: \(error)"`
for anything thrown OUTSIDE `land` (every `ops.` call sits inside a decision's closure, so only reads, logging and the
transport reach them — never an `OperationError`); (4) the handshake (`MCPSession` l.214) — catches every admission
error into its own sentence. Only `Operations` throws `OperationError` (no `Queries` function does).

### The design (argued; the forks it leaves are proposed at the end)

**D1 — VX-361's fix, every shape alike: the answer is built inside the act's transaction.** The note is minted in that
transaction, so its live tags at commit are exactly this act's — read there, ∝ the outflow (a handful of ids), never a
read after the commit (D1-of-U5b's no-race rule holds). `applyDocumentTags` gains the outflow's own rule — a header tag
the note already wears is not inserted again (the application exists; its intake already ran) but IS reported (the note
wears it). That closes the collision for every shape; `importDocument` and `importBook` mint untagged notes, so their
behaviour is byte-unchanged. The shapes differ only in what the answer lists (F-1).

**D2 — VX-362 (a): `apply_tag` on a tag the note already wears answers SUCCESS, `changed: false` (argued single-answer;
offered for confirmation as F-2).** AF-11 F-1 rules the door "refuse exactly where her door refuses, never more", and
R-13n-6 "exactly as her gestures do": every tag door of hers treats an already-applied tag as done — seven sites catch
`alreadyTagged` and move on, `TypedTagPath`'s in her words *"Already wearing it — typing it again is a no-op, never an
error"*. So: the arm catches `alreadyTagged(tagID:…)` and answers `{"note_id", "tag_id", "tag", "changed": false}` (the
path read for the id the error names — the success arm's own read); the op threw, so its transaction rolled back (a
segment it would have minted was not — the tag exists) and NO undo entry registered; the receipt is nil (a receipt may
only claim what landed — the U3 no-op rule); the Activity line is the act's landed line, as every no-op act on the wire
logs (`rename_book`, `choose_take`, `edit_take` with `changed: false`); a once grant is spent as by any landed call (AF-7
as amended: "spent by its first write of any rung" — the no-op edits spend theirs in their guards). A landed apply
gains `"changed": true` (additive; every existing caller and pin reads the same keys). The op keeps its contract
(`MCPWriteActsTests` l.263 pins `applyTagPath` throwing — unmodified). `flushesHerEditorFirst` stays false (no take).
**`remove_tag` on a tag the note doesn't wear keeps its worded refusal** (VX-184 U3, pinned in
`MCPRemoveTagServerTests`): her un-tag can't meet that state (her chips list only worn tags), so no ruling of hers binds
it; a path naming nothing (a typo) is indistinguishable from not-worn there and the sentence points at `read_note`'s
header — while `apply_tag` cannot meet a typo at all (any path adopts or mints). **The siblings:** the wire's other
no-ops either answer `changed: false` already (the renames, finish/reopen, choose, adopt, label, date, filing, block
name, edits) or refuse in words (`archive_*`/`unarchive_*` "already … — nothing changed", `put_back` "already back",
`link_versions` "already linked"); the two that refused RAW are swept below (`add_note_to_book`'s `alreadyInReading` —
her doors REFUSE it, in words, so the wire refuses in those words; `restore_comment`'s `commentNotDeleted` —
`put_back`'s "already back" twin).

**D3 — VX-362 (b): where the words live (argued single-answer; F-3 for confirmation).** `MCPWireRefusalCopy`'s own
contract (13n-b U4) splits the homes: it holds "the op refusals only the WIRE can meet … an address a client typed",
and "the app's own table speaks" the rest (the hook). So a refusal her doors can also meet gets words in the SHARED table
(`OpsRefusalTable.swift` — her voice, both platforms; mobile-visible, MOBILE PARITY below), and one only a client can
type gets words in `MCPWireRefusalCopy` (it runs first). Words are reused from her own doors wherever a sentence already
exists. The pin (piece 2) walks every `OperationError` case through the door's EXACT chain, named once (piece 1).

**D4 — the fence, P1, undo, her editor.** No new answer or refusal can tell hidden from missing: every swept case is
raised only AFTER the act's decision allowed its target (the snapshot or the in-transaction guard), so its words speak
of a thing the client could reach; the not-shared shape stays first on every road. P1: the answer's tags ∝ the outflow;
no new read elsewhere. Undo: no new entry anywhere (the no-op registers none; D1 changes no entry). `flushesHerEditorFirst`:
no job changes family.

### THE FORKS — F-1 proposed for the orchestrator's ruling; F-2, F-3 argued and offered for confirmation

**F-1 (VX-361) — what `create_note`'s and one `import_document`'s answer says about tags.** *(Recommendation first.)*
- **(a) RECOMMENDED — `tag_ids` = every tag the note wears when the act lands, plus `tags`, their paths, parallel.**
  Order: the header's tags in header order (a header tag the outflow also applied is listed once, here), then the
  outflow's tags the header didn't name, in outflow order. `tags` is the wire's tag vocabulary everywhere else —
  `apply_tag`/`remove_tag` answer `tag` (a path), `read_note`'s header lists paths, the book facts' `outflow` (what
  `set_book_rule` answers) lists paths — so a client that set an outflow by path sees the same words come back, with no
  read. Why (a): `create_note` has NO tag input, so its `tag_ids` could only ever have meant "the note's tags", and it has
  answered `[]` for every note an outflow tagged; for `import_document` the header's tags stay the prefix, in order, so
  a caller pairing them with its header still reads right. The meaning widens from "the tags the header named" to "the
  tags the note wears" — which is what the name says, what neither description ever narrowed (`create_note`'s never
  mentions `tag_ids`; `import_document`'s says "the new ids"), and what the client needed to not tag again. Each
  description gains one sentence (FOR VX-234's planned list).
- **(a′) — (a) without `tags`** (ids only): the smallest change; a client maps ids to paths by reading.
- **(b) — `tag_ids` unchanged (the header's) + a new `outflow_tag_ids`** (and paths): keeps the old meaning exactly; a
  client must learn a second field, and `create_note`'s `tag_ids` stays `[]` forever — the field that misled U8's client.

**F-2 (VX-362 (a)) — argued single-answer (D2); offered for confirmation:** `apply_tag` on a worn tag = success,
`changed: false`, no entry, no receipt, the landed Activity line; `changed: true` on a landed apply; `remove_tag` on an
absent tag keeps its worded refusal; `add_note_to_book` on a member refuses in her words. (The rejected option: a worded
refusal for `apply_tag` — "That note already wears the tag “…” — nothing changed." — refuses where her doors don't.)

**F-3 (VX-362 (b)) — argued single-answer (D3); offered for confirmation:** the shared table for refusals her doors can
meet; `MCPWireRefusalCopy` for client-typed ones; her doors' existing sentences reused.

### THE SWEEP TABLE (VX-362 (b)) — all 108 `OperationError` cases at `35f9cd70`

**Method.** (i) **The worded set** — read from the three tables' switches: the shared `words(for:roads:)` (53), the Mac
half `macWords` (8), `MCPWireRefusalCopy` (4) = **65**; plus tool-level catches that word a case on its only wire road.
(ii) **The over-approximate call graph** (`notes/plans/fixes/vx-336-u9-sweep/callgraph.py`, output
`callgraph-35f9cd70.json`; re-run: `python3 -I notes/plans/fixes/vx-336-u9-sweep/callgraph.py <repo>`, `--why <case>`
prints a chain): every function body in `Sources/VariorumCore` parsed (comments and strings stripped), calls matched BY
NAME (overloads merged, every closure body counted for its enclosing function — undo inverses included), rooted at
EVERY call `Sources/VariorumMCP` makes (136 roots in core, 695 functions reached). Over-approximation makes its
"unreachable" column a proof (modulo the parser) and its "reachable" column a candidate list. **40 unreachable, 68
candidates.** (iii) **The candidates not already worded (26) traced by hand**, below.

| class | n | cases | disposition |
|---|---|---|---|
| **W — worded already** (any reachable road speaks a sentence) | 65 | shared: archivedVariant · blockCarriesUnshownText · blockNotDeleted · blockNotPlaced · blocksNotAdjacent · bufferChangedSinceGesture · commitNotFound · crossWingMembership · dailyJournalCannotBeDeleted · dailyJournalIsHomeOnly · dailyJournalTraitIsConstitutive · duplicateBookName · duplicateWingName · emptyTakeCannotBecomeABlock · fannedBlock · gatheringRequiresRule · invalidCommentText · invalidCut · invalidExtent · invalidShelfGlyph · invalidShelfName · invalidTint · invalidWingName · lastActiveVariant · lockedPost · lockedVariant · noConvertibleTakes · noRenderableVariant · noteInSealedBook · noteMemberedElsewhere · noteOwnedElsewhere · ownedBookDuplicatesDeep · placementAnchorNotOnShelf · postAlreadyInWing · postHasNoBlocks · postsAlreadyVersionLinked · purgeTargetNotDeleted · readingAlreadyArchived · readingAlreadyInWing · readingNotArchived · readingNotDeleted · readingNotFound · readingNotSealed · readingSealed · shelfNotFound · unsupportedPurgeTarget · variantIsChosen · variantNotDeleted · variantNotFound · versionLinkNotFound · wingMoveIntoItself · wingNotEmpty · wingNotFound — Mac half: blockNotFound · deliberateSavepointNeverPruned · divideSideWouldBeEmpty · lockedReading · mergedBlockWouldHaveNoTake · starLimitReached · takePairedTwice · wingMoveChangedSince — wire copy: invalidTagName · postNotInReading · sectionNotFound · sectionNotInReading | none (two observations on their WORDS: OWED 3) |
| **C — worded by the tool on its only wire road** | 2 | `tagNotApplied` (`remove_tag` → `notWornWords`; `removeTagForClient` is its one road) · `versionLinkExists` (`linkVersionsForClient` catches → `alreadyLinked`; `duplicate_note`'s edges join FRESH blocks) | none |
| **U-graph — unreachable by the call graph, unworded** | 17 | arrivalNotFound · blockAlreadyArchived · blockNotArchived · blockNotInPool · canvasPositionNotFound · invalidPresentationKind · lensChoiceNotFound · mcpClientNotApproved · mcpGrantScopeFenced · mcpGrantScopeNotFound · mcpRebindRequestNotFound · noOwnerIdentity · notVersionHistory · readingHasNoAutoTag · referenceNotFound · smartFilterUnsatisfiable · spanNotExtractable | PROVEN unreachable (no function the wire reaches throws it) |
| **U-hand — candidates proven unreachable by hand** | 13 | see the rows below | PROVEN unreachable |
| **R/E — reachable, unworded → WORDED in this unit** | 10 | see the rows below | words (pieces 5) |
| **X — reachable, closed by the act's posture** | 1 | `alreadyTagged` | F-2: `apply_tag` (its only wire road — `applyTagPath`; `applyTag(_:toPost:)` / `toBlock` are never wire-called) catches it; then U |

**U-hand — the proofs (13):**
- `duplicateTagPath` — `insertTag` is wire-reached only through `adoptPath`, which mints a segment only after reading
  that no live tag holds that path in that wing, in the same transaction (`ensureNoLiveTagPath` re-reads the same rows).
  `createTag`/`renameTag` are never wire-called.
- `noMarkedVariants` — `divideW` is wire-called only by `divideBlock`, whose `KeepOnTopDivide.compose` always carries the
  shown take's cut (`cuts = [displayedID: cut]` first).
- `cannotVersionLinkBlockToItself` — `link_versions` refuses `sameNote` before the op and a block lives in one note (I2),
  so a pair's blocks differ; `duplicate_note` links a source block to its FRESH copy.
- `lensNotFound` — `delete_lens` / `adopt_lens` decide on `mcpContainerOf(lens:)` (live lenses only) in the snapshot AND
  in the in-transaction guard that runs FIRST in the op's transaction (`deleteLensForClient` l.556, `adoptLensAsNote`
  l.227); `read_note`'s `lens_id` answers the not-shared shape.
- `invalidLensName` — `save_lens`'s `name` is `requiredText` (non-blank) at the parse; the op's check is the same trim.
- `emptyImport` — `insert_blocks` refuses an empty `blocks` at the parse (1–200); `import_document`'s book form refuses
  "The book holds no documents." at the parse; `importText`/paste are never wire-called.
- `commentNotFound` — `edit_comment`/`delete_comment` decide on a LIVE comment's note, `restore_comment` on
  `mcpCommentHome` (nil for no row), each in the snapshot and again in the guard first in the transaction.
- `sectionNotDeleted` — no wire tool restores a chapter (`restoreSectionRow` runs only in her ⌥⌘Z of `delete_chapter`).
- `containerNotDeleted` — `restoreContainerRows` runs only inside undo inverses (her ⌥⌘Z), never a wire act.
- `wrongContainerKind` — `container.kind` is never written after its mint (no op updates it), and every container id an
  op receives on a wire road was decided as a live POST (`mcpNoteFacts` requires `kind = 'post'`).
- `mcpInvalidClientName` · `mcpClientNotFound` — `recordMCPContact` runs only at admission, whose `catch`
  (`MCPSession.swift:214`) answers the handshake's own sentence — never a tool answer; the other throwers are her pane's.
- `mcpGrantNotFound` — every consume runs in the same transaction as the decision that found the once grant live and
  unspent (the guards, `read_note`); `land`'s after-the-act spend is `try?`.

**R/E — reachable and unworded (10), each with its road (R = an ordinary call; E = a sync race between the act's
decision and its transaction, or a sync-made store state), its home (D3) and its words (PLANNED — FOR VX-234):**

| case | road | home | words (PLANNED) |
|---|---|---|---|
| `alreadyInReading` | R — `add_note_to_book` on a note already in the book (probed) | shared | **"That note is already in this book."** — her generic arm's sentence (`ReadingsViewModel.message`), hoisted |
| `readingAtCapacity` | R — `create_note` / one `import_document` into a full book (`max_posts`), `add_note_to_book` | shared | **"This book is at its note limit."** — her generic arm's, hoisted |
| `commentNotDeleted` | R — `restore_comment` on a live comment (its arm's own note: "a live one reaches her restore's own 'not deleted' refusal") | shared | **"That comment is already back."** — NEW, `put_back`'s "That block is already back." twin |
| `invalidSectionName` | R — `import_document`'s book form with a blank chapter name (the parse accepts `""`) | shared | **"A chapter needs a name."** — NEW, the shelf's/wing's "A … needs a name." twin |
| `invalidEntryDate` | E/belt — the wire parses `entry_date` with its own formatter, the op with `JournalDay.isValid`; a probe of 1,000+ shapes found no disagreement, but two validators are not one | wire copy | the wire's OWN parse sentence: "entry_date must be a real day written yyyy-MM-dd (e.g. 2019-03-04)." (no new words) |
| `containerNotFound` | E — a write-new/suggest act with no in-transaction guard whose op reads the note by `livePost` (`apply_tag`, `save_lens`, `add_note_to_book`) while a sync apply tombstones the note between the decision and the act | shared | **"That note isn't there any more — it may have just been deleted."** — NEW, `variantNotFound`'s first clause, one row-kind up |
| `wrongReadingKind` | E — `create_note` / one `import_document` into a book, or `add_note_to_book`, while a sync apply turns the book back into a gathering (another device's un-bind) | shared | `.book`: **"That isn't a book — a gathering shows the notes its rule matches and holds none of its own."** — NEW (the wire's `gatheringWords` register); `.gathering`: "That's already a book — only a gathering binds into one." — her bind door's, hoisted |
| `tagNotFound` | E — `set_book_rule`'s outflow on a book whose wing pointer dangles (the adoption resolves in Home; `writeReadingOutflow` compares the stored id — OWED 2; her Save shares it) | shared | **"That tag isn't there any more — nothing changed."** — NEW, the shelf's/library's "isn't there any more — nothing changed." twin |
| `blockAlreadyPlaced` | E — `put_back` on a deleted block a sync apply left with a live placement (`restoreBlock` → `insertPlacement`) | shared | **"That block is already in a note — nothing changed."** — NEW |
| `blockNotInContainer` | E — `save_lens` whose picked block a sync apply moves out between the picks' read and the act (the batches already word it on their road) | shared | `blockNotPlaced`'s sentence, reused: "That block is no longer in this note — it may have moved while you worked. Nothing was changed here." |

**Other error TYPES on the wire** (the class beyond `OperationError` — no raw Swift case may reach a client): the MCP
refusal enums are each caught by their tool and worded (`MCPBookRuleRefusal` — `set_book_rule`; `MCPNoteEditRefusal`'s
two — `edit_comment`, `delete_take`; `MCPLibraryRefusal` — `move_note_in_book`; `MCPVersionLinkRefusal`'s five —
`link_versions`); `MCPBatchItemRefusal` — `itemized`; `VariorumDocument.Failure` — parsed into an `ArgumentFailure`;
`MCPAnswerEncodingFailure` — a `CustomStringConvertible` sentence; `SearchComposer.Refusal.negativeOnlyText` — the v1
parser (`SearchQueryParser`) never emits `.not` (U); a `DatabaseError` — the one reachable today is the import
collision (closed by D1). Nothing else found.

### THE BUILD PLAN after the ruling (pieces 1–7 — a fresh session can run these from this record)

1. **Refactor (neutral, its own commit):** `MCPWireRefusalCopy.spoken(_ error: Error, appWords: (Error) -> String?) ->
   String` = `words(error) ?? appWords(error) ?? String(describing: error)`; `land` (l.730) and `itemized` (l.238) call
   it. Headless MCP target green, unchanged.
2. **Pins (red on the old tree, committed before any fix):** headless `Tests/VariorumMCPTests/MCPTagTruthServerTests.swift`
   — (VX-361) `create_note` into an outflow book answers the outflow's tag (per the ruled shape); one `import_document`
   whose header names the outflow tag LANDS (old: the SQLite refusal) and lists it once; a header tag + a different
   outflow tag both listed, header first; a bookless note's answer unchanged; (VX-362 (a)) `apply_tag` twice → the second
   `changed: false`, the undo stack's top label and count unchanged, no receipt, the first `changed: true`;
   `remove_tag` of an absent tag still refuses in its words (a guard); `MCPWireRefusalCopy.words(.invalidEntryDate)` is
   the parse sentence (old: nil). Mac `App/Variorum/VariorumTests/MCPWireRefusalSweepTests.swift` — reads
   `OperationError.swift` by `#filePath`, holds ONE sample per case (the case-name sets must be EQUAL — a new case fails
   the pin until it is swept), the U list with each proof's one line; every case not in U runs the door's exact chain
   (`MCPWireRefusalCopy.spoken(e) { OpsRefusalCopy.message(for: $0) }` — `MCPDoor`'s hook) and must not start
   "Refused:", contain the case name followed by "(", or equal `String(describing:)`; plus `OpsRefusalTableIntegrityTests`
   unmodified. **Predicted red on old:** the Mac pin's 10 R/E cases (+ any I mis-swept); the headless pins' VX-361 and
   VX-362 (a) tests and the wire-copy row.
3. **VX-361:** `applyDocumentTags` skips-but-reports a worn tag; `mintNoteEntry` composes the answer's tags inside the
   transaction (D1, the ruled shape); `DocumentImport` carries what the shape needs; `noteAnswer` answers it; the two
   descriptions gain their sentence.
4. **VX-362 (a):** the `apply_tag` arm's catch and `changed`; `apply_tag`'s description gains "changed is false when
   the note already wore the tag — nothing written, nothing to undo".
5. **VX-362 (b):** the nine shared-table arms (`OpsRefusalTable.swift`, each commented with its road) and the wire-copy
   arm.
6. **Revert check** (ANNOUNCED in this record and committed first): each fix's lines reverted alone, its pins red,
   restored, green. **Headless finals** (`swift build`; `swift test` per target: `VariorumMCPTests` (VX-353's flake
   re-run alone), the core tag/intake/import/MCP-write suites). **Products** (disk checked): `xcodebuild
   build-for-testing` → `App/Variorum/DerivedData/vx336-u9` (Mac) + the phone target (the shared table moved); a red
   product `vx336-u9-red` from the pins commit for the Mac sweep pin.
7. **THE STAGE WINDOW plan** (`vx336-u9`): the Mac suites reaching the table and the tag doors (named by grep), the red
   run, the SEAM, the A1, the short real-client leg (a book with a tag rule + outflow → `create_note` → `tag_ids`/`tags`
   carry it → `apply_tag` → `changed: false`, no raw case → `add_note_to_book` again → "That note is already in this
   book."), cleanup to cmp-SAME / prefs 0 differ / fingerprint SAME → READY.

### THE STAGE WINDOW — the plan (claim `vx336-u9`; runs ONLY on the orchestrator's GO, under the exact claim line it relays)

**What this window does NOT do (said first):** no product code is written or changed under the claim — a red that
needs code is RECORDED as a FINDING and reported; no rebuild (if `git diff --name-only c2f77ce9..HEAD -- Sources App
Tests Package.swift` is not empty at the GO, or the coordinator says VX-306 has merged: STOP before any launch and
report); never her real store, never `/Applications/Variorum.app`, never her user-scope MCP registrations (the copied
setup line is never run — only its key is taken); **never `claude mcp list` (nor `claude mcp get`)**; `castle-W1-20261013`
left alone; ONE simulator, shut down before the SEAM.

**Minutes:** guards 1 · the Mac batch (121 suites) ~15 · the Mac red ~2 · the phone red + green ~8 (a simulator boot) ·
SEAM · prefs/Backups/fingerprint/clipboard 2 · the A1 2 · launch 2 · bind + grant 5 · the U9 turn ~4 · the faces (Study,
Terminal) ~8 · cleanup 8 → **~57 of work; ask a 75-minute claim.** **Batch-only fallback (~28 min, claim 35):** steps 0,
1a, 1b, 1c, the SEAM and the release (nothing launched, so no A1); the live leg then stays OPEN.

**Evidence:** `notes/plans/vx336-screens/u9/` (gitignored): `logs/`, `tee/`, `U9-tags.jsonl`, `U9-tags-answers.txt`,
captures `live/s/` and `live/t/`. **The kit** `notes/plans/fixes/vx-336-u7-kit/` as U8 used it, plus `prompts/U9-tags.txt`
and `answers.py <leg>` (every `tools/call` with its arguments, isError and the answer WHOLE, from the tee). **Before any
turn:** `export U7_SCRATCH=<the runner's scratchpad>/u9w` (FRESH), `export U7_SHIM_PATH=$PWD/App/Variorum/DerivedData/vx336-u9/Build/Products/Debug/Variorum.app/Contents/MacOS/variorum-mcp`,
`export U7_SCREENS=$PWD/notes/plans/vx336-screens/u9`; `K=notes/plans/fixes/vx-336-u7-kit`; `T=$K/turn.sh`; repo root.

0. **Guards, every step** — U8's step 0 exactly (`Tools/WalkKit/guard.sh --author` before anything touches the GUI —
   exit 3/4 STOP; the strict instance guards `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` empty before the
   launch; the claim line EXACTLY as relayed; `Tools/stage status` never in an `&&` chain; ≥ 2.6 s between synthetic
   events; region captures; HEAD at the GO recorded; the product check above).
1. **1a — the Mac batch (~15 min) FIRST.** From `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum
   -destination 'platform=macOS' -derivedDataPath DerivedData/vx336-u9 -resultBundlePath
   ../../notes/plans/vx336-screens/u9/u9-batch.xcresult` + one `-only-testing:VariorumTests/<Suite>` per suite below,
   detached to `u9/logs/u9-batch.log` and POLLED in the foreground (a `grep -q` loop). **The 121 suites** — every
   suite in every Mac test file naming the shared table, a refusal copy, one of the ten worded cases, `alreadyTagged`,
   `importBook`/`DocumentImporter` or a document import's tags (the types this unit changed), ∪ every MCP Mac suite (the
   wire's answers changed), ∪ the new `MCPWireRefusalSweepTests`: ArchivedBooksGroupTests · ArchivedMarkTests · AscentDoorTests · AscentRoutingTests · BindDoorTests · BlockHighlightTests · BlockHistoryPaletteDoorTests · BlockHistorySealTests · BlockSelectionRegistryTests · BlockSelectionRuleTests · BlockTOCStatusTests · BoardBlockSelectionTests · BookAnchorTests · BookArchiveDeclarationTests · BookArchiveDoorActTests · BookArrivalsTests · BookCarryTests · BookcaseStarredShelfBrainTests · BookcaseStarredShelfDropTests · BookChooserOrderTests · BookDropTests · BookPanelMCPMarksTests · BookSettingsArchiveRowTests · BookStructureModelTests · ComesBackReceiptTests · CommandRouterTests · CommentPanelFixLeg2Tests · CommentPanelGeometryRuleTests · CommentPanelWordsTests · CommentTextAreaMountedTests · CommitVocabularyTests · CompareCompositionTests · CompareViewModelTests · ContextBarTests · DifferentialApplyTests · DivergeDoorTests · DivideExtractGestureTests · DivideWCeremonyTests · DocumentImportDoorTests · DropAndRefusalCopyTests · EncryptionBookDoorTests · JournalBooksTests · LifecycleFacesTests · MakeBlockGestureTests · MCPAskAndReceiptTests · MCPAsksWaitCaptureTests · MCPAsksWaitTests · MCPCompareLandingTests · MCPDeliberateFacesTests · MCPDoorErgonomicsFacesTests · MCPEditFacesTests · MCPEditParityFacesTests · MCPGatheringIconTests · MCPGrantSheetCaptureTests · MCPGrantSheetTests · MCPGrantSheetU2CaptureTests · MCPHerEditorDoorTests · MCPLibraryParityFacesTests · MCPNavigationTests · MCPPaneTabsCaptureTests · MCPPaneTabsTests · MCPPaneTests · MCPRebindFaceTests · MCPSetupKeyFacesTests · MCPSetupMenuTests · MCPSetupTabKeyTests · MCPSharedIconClickTests · MCPSharedRowsRulesTests · MCPSharedRowsTests · MCPShareFacesCaptureTests · MCPShareFacesTests · MCPWingFacesTests · MCPWireRefusalSweepTests · MembershipChoiceTests · MergeGestureTests · MoveAndExecuteTests · MultiBookEditNoteRuleTests · MultiBookEditNoteTriggerTests · NoteTrayTests · OpsRefusalTableIntegrityTests · OutflowChooserTests · PagedAnchorReportTests · PaletteDerivationTests · RecoveryDoorsTests · RefusalTableConvergenceTests · ReviewRound1FixTests · ReviewRound2FixTests · ReviewRound3FixTests · RuleEditorMakeTagTests · SavepointCommitDoorTests · SavepointNameAskTests · SavepointNameCopyTests · SavepointNameFaceTests · SavepointRenameDoorTests · SavepointSealedDoorTests · SavepointTakesDoorTests · SealDoorTests · SealedBookMemberDoorTests · SearchPickerBrainTests · StaleWriteIntentTests · StarActingTests · StarDeclarationTests · StarTargetingTests · StatusCenterTests · StructuralRewriteDoorTests · TakeCardDoorTests · TakesDivideTests · TakesLandingTests · TakesWordCountTests · TrashConfirmEdgeTests · TrashPoolHonestyTests · TrashPurgeDoorsTests · TrashPurgeSharedLayerTests · TrashSurfaceTests · TutorialBooksLessonTests · TutorialBooksRitualTests · TutorialMCPChapterTests · VocabularySweepTests · WingBookMoveDoorTests · WingContentsArchivedWordsTests · WriteBlockSelectionTests. **Expected:** green; the five
   gated capture harnesses skip (`MCPAsksWaitCaptureTests`, `MCPGrantSheetCaptureTests`, `MCPGrantSheetU2CaptureTests`,
   `MCPPaneTabsCaptureTests`, `MCPShareFacesCaptureTests` — a different skip set is a finding); **`MCPWireRefusalSweepTests`
   3 tests green — its FIRST run (PENDING until read here)**; `OpsRefusalTableIntegrityTests` green (the nine new
   sentences name no platform door). Neither standing red (VX-115's `BookCollectingDoorsTests`, VX-167's
   `DestructiveUndoWarningTests`) is in the set. A red: re-run that suite ALONE once; one that reproduces is a FINDING.
   **1b — THE MAC RED RUN (~2 min), on `vx336-u9-red` (never launched):** `xcodebuild test-without-building -xctestrun
   DerivedData/vx336-u9-red/Build/Products/Variorum_Variorum_macosx27.0-arm64.xctestrun -destination 'platform=macOS'
   -only-testing:VariorumTests/MCPWireRefusalSweepTests` → `u9/logs/u9-mac-red.log`. **Expected EXACTLY: 3 tests, 1
   failed, 20 issues** — the walk, two per unworded case (the "Refused:" prefix; the case's name + "(") for exactly
   `alreadyInReading · readingAtCapacity · commentNotDeleted · invalidSectionName · invalidEntryDate · containerNotFound ·
   wrongReadingKind · tagNotFound · blockAlreadyPlaced · blockNotInContainer`; the sample-coverage and proof tests green.
   Any other count — above all a W-class case red — is a FINDING (a mis-swept case), recorded and reported. Then
   `rm -rf DerivedData/vx336-u9-red`.
   *[removed for publication]*
   the products are generic-simulator builds, deployment iOS 26), `-collect-test-diagnostics never`, detached and polled.
   **red** on `DerivedData/vx336-u9-ios-red/Build/Products/VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun`
   `-only-testing:VariorumMobileTests/MobileRefusalTableTests` → `u9/logs/u9-ios-red.log`: **Expected EXACTLY: 7 tests,
   1 failed, 5 issues** (`theSweepsNoteGoneSentenceReachesEveryFallThroughSite`; the re-pointed guard green). **green** on
   `vx336-u9-ios`'s xctestrun with `-only-testing:VariorumMobileTests/` × MobileRefusalTableTests · MobileTrashTests ·
   MobileDeletionTests · MobileSeededBookRestoreTests · MobileBookDetailsTests · MobileBookNameGuardTests ·
   MobileBookCreateTests · MobileBookPinTests · MobileArchivedTakesTests · MobileBlockHistoryTests ·
   MobileDailyJournalArchiveTests · MobileCrossBlockEditTests · MobileCrossBlockEditBrainTests · MobileNavigationTests ·
   MobileTakeLockTests → `u9/logs/u9-ios.log` — expected green, no "Restarting after unexpected exit". Then `xcrun
   simctl shutdown` it, `simctl list devices booted` → none; `rm -rf DerivedData/vx336-u9-ios-red DerivedData/vx336-u9-ios`.
   **→ THE SEAM:** record 1a–1c here, commit, push, KEEP the claim, report "SEAM" through the orchestrator; continue only on
   its word.
2. **Prefs, Backups, fingerprint, clipboard — BEFORE the A1 (~2 min):** U8's step 2 exactly (`prefs-pre.plist` and its
   key count; `backups-pre.txt`; her user-scope servers by U7 step 2's `python3 -I` one-liner → expected `['linear-server',
   'variorum']`, `bc64543e2f4e8e58`; the clipboard saved, never read).
3. **THE ONE A1 (~2 min):** U8's step 3 exactly (`stage.sh`'s copy loop only; `scale-prestage-<UTC stamp>`; `cmp` each;
   `a1-path.txt`; `store-hash-pre.txt`).
4. **Launch (~2 min):** `open -n App/Variorum/DerivedData/vx336-u9/Build/Products/Debug/Variorum.app`; What's New → its
   own button; a lock screen → `source ~/.variorum/dev-castle.env`, those values only (none expected); Study expected.
5. **Bind and grant (~5 min):** Settings ▸ MCP ▸ Connect ▸ Claude Code ▸ the copy icon → ONLY the key into
   `$U7_SCRATCH/keys/u7.key` (U8 step 8's one-liner; record its first 9 characters only; `pbcopy < /dev/null` at once);
   `zsh $T bind mcp__variorum-dev__list_books < $K/prompts/bind.txt` → Activity's bind line with zero clicks (capture
   `live/s/00-bind`); then Clients ▸ claude-code ▸ Change… ▸ **A wing · Home · Write new · Always** (capture `01-grant`).
6. **THE U9 TURN (~4 min):** `zsh $T U9-tags "mcp__variorum-dev__create_book,mcp__variorum-dev__set_book_rule,mcp__variorum-dev__create_note,mcp__variorum-dev__apply_tag,mcp__variorum-dev__import_document,mcp__variorum-dev__add_note_to_book" < $K/prompts/U9-tags.txt`
   then `python3 -I $K/answers.py U9-tags`. **PASS, read from the answers' bytes:** (1) `create_book` ok; (2)
   `set_book_rule` ok, its `outflow` `["u9-green-tea"]`; (3) `create_note` ok with **`tag_ids` = ONE id and `tags` =
   `["u9-green-tea"]`** (VX-361 — U8's `[]`); (4) `apply_tag` **NOT isError, `"changed":false`**, the same `tag_id`
   (VX-362 (a) — U8's raw `alreadyTagged`); (5) `import_document` **NOT isError — the import landed whole** with `tag_ids`
   = that one id ONCE and `tags` = `["u9-green-tea"]` (VX-361's collision — the trace's `SQLite error 19`); (6)
   `add_note_to_book` isError with **exactly "That note is already in this book."** (VX-362 (b), the Mac table through the
   door — the trace's raw `alreadyInReading`); **no answer anywhere starts "Refused:" or carries a Swift case.** A client
   that skips or adds a step: recorded; ONE re-run of the same prompt into a fresh leg name (`U9-tags-2`).
7. **The faces (~8 min), Study:** the Bookcase shows "u9 tea" (capture `live/s/02-bookcase`); open it → its two notes,
   "u9 brewing" and "u9 second" (`03-book`); open "u9 second" → its tag shows ONCE (`04-note-tag`); Settings ▸ MCP ▸
   Activity: the six acts' lines in words — the `apply_tag` line landed, the `add_note_to_book` line refused, no tool id
   (`05-activity`). **Terminal:** Settings ▸ General ▸ Theme ▸ Terminal; Activity again (`live/t/05-activity`) and the
   book (`live/t/03-book`); Theme back to **Study** (`live/s/06-back-study`).
8. **Cleanup (~8 min)** — U8's step 12 exactly: quit BY BUNDLE ID; the key grep → 0 files, then `keys/` deleted; the
   clipboard restored (`cmp` SAME); no `mcpServers` for `$U7_SCRATCH/proj` in `~/.claude.json` (read-only, never `claude
   mcp get`/`list`); any saved-to-file tool result under the scratch project deleted; the fingerprint AFTER = BEFORE;
   prefs imported, re-exported, every added key deleted → **0 added · 0 removed · 0 changed**; `Tools/ScaleFixture/restore.sh
   "$(cat $U7_SCREENS/a1-path.txt)"` → "Restored (verified)", a second `cmp` SAME, the sha256 set equal; `Backups/`
   unchanged; castle-W1 untouched; 0 simulators booted; the tree clean; `Tools/stage release --who vx336-u9`; **THE
   RESULT LINE** for the coordinator (claim times; 1a's counts, 1b's and 1c's exact reds; the six answers' verdicts; the
   faces in both voices; the posture; the A1 path, the coordinator's to prune).

### FOR VX-234 (user-facing words, AS BUILT — U9)

- **Her app's shared refusal table (both platforms; also what the MCP door speaks):** "That note is already in this
  book." · "This book is at its note limit." · "That comment is already back." · "A chapter needs a name." · "That note
  isn't there any more — it may have just been deleted." · "That isn't a book — a gathering shows the notes its rule
  matches and holds none of its own." · "That's already a book — only a gathering binds into one." · "That tag isn't
  there any more — nothing changed." · "That block is already in a note — nothing changed." · (`blockNotInContainer`
  speaks `blockNotPlaced`'s existing sentence). The first two and the bind sentence are byte-identical to
  `ReadingsViewModel.message`'s.
- **Model-facing (tool descriptions):** `create_note` — "Its tag_ids and tags (their paths) list every tag the note wears
  once it lands, a book's outflow included, so there is nothing to tag again." · `import_document` — "…and tag_ids and tags
  (their paths): every tag the note wears, the header's first, then a book's outflow;" · `apply_tag` — "Returns JSON with
  the tag_id and changed — false when the note already wore the tag: nothing was written and there is nothing to undo."
  The wire's `invalidEntryDate` speaks the parse's existing sentence (no new words).
- **OWED 3, for her eye:** two worded cases speak Mac-door words on the wire — `blockNotFound` → "…since you picked it"
  (`BlockSelectionCopy.blockGone`) and `lockedReading` → "…if it's sealed, unseal it."

### PROVISIONALs (as built — the orchestrator files them at the merge)

- **P-VX361-1 — what `create_note`'s and a one-document `import_document`'s answer says about tags** (F-1, ruled (a)): (a)
  AS BUILT — `tag_ids` = every tag the note wears when the act lands (the header's in header order, then the outflow's
  others in outflow order) with `tags`, their paths, parallel; (a′) the same without `tags`; (b) `tag_ids` stays the
  header's plus a new `outflow_tag_ids`.
- **P-VX362-1 — `apply_tag` on a worn tag, and the sweep's new words** (F-2 + D3): (a) AS BUILT — success, `changed: false`,
  no undo entry, no receipt, the landed Activity line, a once grant spent as by any landed call (D2's argued posture; the
  ruling is silent on the once grant), `changed: true` on a landed apply; the ten words above; (b) her VX-234 pass rewords
  any; (c) a worded refusal for `apply_tag` ("That note already wears the tag “…” — nothing changed." — rejected: it
  refuses where her doors don't); (d) the wire speaks the one not-shared shape for the race-only "isn't there any more"
  class (rejected: every such refusal follows a decision that allowed the target).

### MOBILE PARITY (as built)

The shared table's nine new arms speak on the phone wherever a phone door falls through to `OpsRefusalCopy.words(for:roads:
.phone)` — `MobileBlockMenuController`, `MobileUndoDoor`, `MobileCommentsController`, `MobileStructuralController`,
`MobileMembershipModel` (its own `alreadyInReading`/`readingAtCapacity`/`lockedReading` arms stay first), the editor's
status line, the shelf's and the book details' archive doors: mobile-VISIBLE words, the same sentences, no new face.
**A phone pin changed** (the design's "no phone pin changes" was wrong — found at piece 2): `MobileRefusalTableTests`'
guard re-pointed from `containerNotFound` to `referenceNotFound`, + the parity test; so the window runs ONE simulator
(1c). The closeout's line: "VX-362: nine refusal sentences in the shared table, mobile-visible; no phone face changed."

### SELF-ASSESSMENT (the builder's, pre-stage)

- **VX-361:** the answer is composed inside the act's transaction from the note's own live applications (∝ the act's
  writes, P1), so it cannot omit a tag the note wears; the belt ("any other, by path") is unreachable today (intake
  seats, it never applies an outflow) and is there so the field can never lie. The file doors' behaviour is unchanged
  (their notes are fresh); their `applyDocumentTags` now does one indexed `post_tag` read per header tag (∝ the header).
- **VX-363:** exactly VX-259's predicate, on the third road; her doors keep the full guard (pinned on both trees by the
  server test's guard line). The import's answer names only the client's spelling.
- **VX-362 (a):** the op's contract is untouched (`MCPWriteActsTests`' throw pin unmodified); the no-op still spends a once
  grant (D2) — said in P-VX362-1 since the ruling is silent there.
- **VX-362 (b):** the shared table's new arms reach every door of hers that fell through to "Refused: …" — strictly dumps
  turned into sentences (the table's own contract). `ReadingsViewModel.message` keeps its two byte-identical sentences (a
  second home, a one-line forward at its next touch — the plan's piece 5 named only the table). The `wrongReadingKind
  (.book)` sentence is the wire's register; a Mac door that met it fell to the raw case before.
- **Not verified here:** every Mac and phone test (the window); the real client (the window).

### OWED (U9 builder → the orchestrator)

1. THE STAGE WINDOW above (claim `vx336-u9`, ~75 min; batch-only 35).
2. Disk: the window deletes `vx336-u9-red`, `vx336-u9-ios-red` and `vx336-u9-ios`; `vx336-u9` is the ladder's product.
3. VX-353's flake met again at the finals (24.6 s under load 30–37; green alone) — a data point for its ticket.
4. The design's MOBILE PARITY line corrected (a phone pin changed) — the window's 1c covers it.
5. VX-364 and VX-365 stay their tickets (the rulings); OWED 3's two phrasings are on FOR VX-234.

### FOR VX-234 (PLANNED words — superseded by the AS BUILT list above; kept as the design wrote it)

Her app's table (both platforms): "That note is already in this book." (hoisted) · "This book is at its note limit."
(hoisted) · "That comment is already back." · "A chapter needs a name." · "That note isn't there any more — it may have
just been deleted." · "That isn't a book — a gathering shows the notes its rule matches and holds none of its own." ·
"That's already a book — only a gathering binds into one." (hoisted) · "That tag isn't there any more — nothing
changed." · "That block is already in a note — nothing changed." · (`blockNotPlaced`'s sentence reused). Model-facing:
`create_note`'s and `import_document`'s tag sentence (per F-1), `apply_tag`'s `changed` sentence.

### PROVISIONALs (planned — superseded by the AS BUILT list above)

- **P-VX362-1 — the new refusal words** (the table above): (a) as built; (b) her VX-234 pass rewords any; (c) the wire
  speaks the one not-shared shape for the race-only "isn't there any more" class instead (rejected here: the wire
  already speaks the shared table's not-found sentences for takes and books, and every such refusal follows a decision
  that allowed the target).
- **F-1's shape** if the orchestrator rules it PROVISIONAL (her away-mode answer): the options as listed above.

### MOBILE PARITY (planned — corrected by the AS BUILT line above: a phone pin DID change)

The shared table's new arms speak on the phone wherever a phone door falls to `OpsRefusalCopy.words(for:roads: .phone)`
(e.g. `MobileMembership`'s default arm): mobile-VISIBLE words, the same sentences. No phone pin changes; the phone target
is built headless at piece 6.

### OWED (U9 → the orchestrator)

1. **A fence leak in `import_document`'s BOOK form (VX-259's class)** — `importBook` (`Operations+DocumentImport.swift`,
   the E13 guard `requireBookNameFree(db, name)` with no reach) counts EVERY live book, so a book the client cannot read
   blocks the name AND is named back ("A book named “…” already exists — …"). `create_book` and `rename_book` pass
   `readableBooks(clientName)` since VX-259; the import's book form was missed. Traced, not pinned (outside U9's surface).
   **Proposed ticket:** Bug · Suspected · MCP · High (a no-oracle breach); Pre-launch is her call.
2. **A dangling-wing book refuses an outflow** — `set_book_rule` (and her own rule editor's Save, through
   `writeReadingOutflow`) resolves tags in the EFFECTIVE wing (Home for a dangling pointer) but checks them against the
   STORED wing id, so it refuses `tagNotFound`. Reachable only after a sync-made dangling wing. **Proposed ticket:** Bug ·
   Suspected · Books · Low.
3. **Two worded cases speak Mac-door words on the wire** (not raw, so outside VX-362's letter): `blockNotFound` → "…since
   you picked it" (`BlockSelectionCopy.blockGone`, the ⌘-click vocabulary) and `lockedReading` → "…if it's sealed, unseal
   it." For VX-234's eye; no ticket proposed.
4. **`add_note_to_book`'s answer doesn't say the outflow tagged the note** (no false field; after F-2 a redundant
   `apply_tag` answers `changed: false`). **Proposed ticket (optional):** Improvement · Suspected · MCP · Low.

### THE ORCHESTRATOR'S RULINGS ON U9's FORKS (2026-10-14 ~23:58 MDT — binding on pieces 1–7)

The design D1–D3 and the SWEEP TABLE (108 cases: 10 to word, 1 closed by F-2, the rest worded or proven unreachable)
are ACCEPTED as written, with these rulings.

- **F-1 (a), PROVISIONAL P-VX361-1.** On `create_note` and a one-document `import_document`, `tag_ids` lists EVERY tag
  the note wears when the act lands: header tags in header order, then outflow-only tags. A parallel `tags` array gives
  their paths, the wire's tag vocabulary. The answer then tells the truth about the note, and the old meaning (the header's
  tags) is a prefix of the new one, so no caller loses what it had. Option (b) is recorded: keep `tag_ids` as the header's
  plus a new `outflow_tag_ids`.
- **D1's collision fix is CONFIRMED.** `applyDocumentTags` skips a worn tag but still reports it. This closes the import's
  `SQLite error 19` whatever shape was ruled. That error was a third face of VX-361's class, so it is pinned under VX-361.
- **F-2, CONFIRMED (PROVISIONAL P-VX362-1).** `apply_tag` on a tag the note already wears answers success with
  `changed: false`, with no undo entry and no receipt; a landed apply answers `changed: true`. Her seven doors already
  treat `alreadyTagged` as done. `remove_tag` on an absent tag keeps its worded refusal, and `add_note_to_book` on a
  member refuses in her doors' own words.
- **F-3, CONFIRMED (the orchestrator's).** Words her doors can also meet go in the shared `OpsRefusalTable`; words only a
  client can meet go in `MCPWireRefusalCopy`, the split its own doc comment states. The new shared words are
  mobile-visible (MOBILE PARITY).
- **VX-363 joins U9** (provisional ruling 2). `import_document`'s book form takes VX-259's readable-books check. The pin
  is red-first: a book the client can't read neither blocks the name nor is named. Her own doors keep the full guard.
- **The OWED tickets are minted:** VX-364 (the dangling-wing outflow, Low) and VX-365 (`add_note_to_book`'s answer, Low).
  OWED 3, the two Mac-door phrasings speaking to clients, goes on FOR VX-234.
- **Next:** a FRESH builder (the designer's harness count was ~447k) builds pieces 1–7 from the U9 UNIT RECORD's build
  plan plus VX-363, and writes THE STAGE WINDOW (`vx336-u9`).

## U9 STAGE RUN — the whole window (a fresh stage runner, from 2026-10-15)

**What this run does NOT do (said first):** no product code is written or changed, before the claim or under it. A red
that needs code is RECORDED as a FINDING and reported, never fixed here. No rebuild: the window runs `vx336-u9` and
`vx336-u9-ios` (from `c2f77ce9`) and `vx336-u9-red` and `vx336-u9-ios-red` (from `ce4f2ed9`) exactly as the U9 builder
made them. No canon, QUESTIONS or ticket edits. Never her real store, never `/Applications/Variorum.app`, never her
USER-scope MCP registrations: the copied setup line is never run as copied; only its key is taken, into a scratch config
in the runner's scratchpad (`u9w/keys/`), OUTSIDE the repo, deleted at cleanup. **Never `claude mcp list` (nor `claude mcp
get`).** `castle-W1-20261013` left alone. ONE simulator, shut down before the SEAM. The plan is the U9 UNIT RECORD → THE
STAGE WINDOW (claim `vx336-u9`, steps 0–8), run as written, with the kit `notes/plans/fixes/vx-336-u7-kit/` (incl.
`answers.py` and `prompts/U9-tags.txt`).

**Read in full before READY (never delegated):** this record's header, Hard rules (never `claude mcp list`; the
live-round machinery), LIVE STATUS, Stage traffic log and Cross-run coordination; the U9 UNIT RECORD whole (incl. THE
STAGE WINDOW, FOR VX-234, PROVISIONALs, MOBILE PARITY, SELF-ASSESSMENT, OWED) and THE ORCHESTRATOR'S RULINGS ON U9's
FORKS; THE ORCHESTRATOR ON U5's, U6's and U7's WINDOW; the U8 STAGE RUN and the U6 STAGE RUN whole (and U8b's STAGE
WINDOW, whose steps 0/2/3/8/12 the U9 plan names "U8's step N exactly", and U7's step 2 for the fingerprint one-liner);
every kit file (`turn.sh`, `tee-shim.sh`, `answers.py`, `drop-relay.py`, `instructions.py`, `measure.py`,
`verify-digests.py`, the seventeen prompts); `Tools/stage`; `Tools/WalkKit/` (README, `guard.sh`, `click.sh`,
`keys.sh`); `Tools/ScaleFixture/` (`stage.sh`'s copy loop, `restore.sh`); `notes/SessionResiliencyProtocol.md` (the
implementer rules and the addenda); the memory note walk-driving-lessons.

**The build check (READY, 2026-10-15 ~00:50 MDT):**
- **The products match their trees.** HEAD `44d28ad9`; the tree clean; `git diff --name-only c2f77ce9..HEAD -- Sources
  App Package.swift` is **EMPTY**, and so is the plan's wider form with `Tests` (since `c2f77ce9` only this record,
  `answers.py` and `prompts/U9-tags.txt` changed). No `.swift`, plist, pbxproj, xcstrings, entitlements, xcconfig or
  `Package.swift` under `Sources`, `App/Variorum` or the root is newer than `vx336-u9`'s `Variorum.debug.dylib`
  (00:35:10). **The reds' tree:** `git diff --name-only ce4f2ed9..c2f77ce9 -- Sources App Tests Package.swift` is
  exactly the fix files (`OpsRefusalTable.swift`, `Operations+DocumentImport.swift`, `Operations+MCPWrites.swift`,
  `MCPToolCatalog.swift`, `MCPWriteSupport.swift`, `MCPWriteTools.swift`) plus the headless core pin
  `Tests/VariorumCoreTests/MCPBookNameReachTests.swift` — NO Mac or phone test file differs, so the red products carry
  the same Mac sweep pin and phone parity test as the finals. `ce4f2ed9` committed 00:12:24; the red dylibs 00:14:20 (Mac)
  / 00:16:00 (phone); the first fix commit `7ae1551a` 00:18:24.
- **The products exist, read from their binaries:**
  *[removed for publication]*
    00:35:10, shim `variorum-mcp` 00:33:24, test binary 00:35:10, `Variorum_Variorum_macosx27.0-arm64.xctestrun`
    00:35:11. The dylib: "it may have just been deleted" ×1 · "once it lands, a book's outflow included" ×1 · "nothing
    was written and there is nothing to undo" ×1 · "That comment is already back." ×1 · "A chapter needs a name." ×1.
  - `App/Variorum/DerivedData/vx336-u9-red` (2.5 GB) — signed the same, 0.9.6; dylib 00:14:20, shim 00:11:36, the
    `.xctestrun` 00:14:21. The same five strings ×0 each — **the old wire and the old table** ("must be a real day written
    yyyy-MM-dd" ×1 in both, the parse's sentence predates the fix).
  - `App/Variorum/DerivedData/vx336-u9-ios` (2.4 GB) — `VariorumMobile.debug.dylib` 00:37:07: the note-gone sentence ×2
    and "That comment is already back." ×2 (two slices); `VariorumMobile_VariorumMobile_iphonesimulator27.0-arm64-x86_64.xctestrun` 00:37:08.
  - `App/Variorum/DerivedData/vx336-u9-ios-red` (2.4 GB) — dylib 00:16:00: both ×0; the same `.xctestrun` name (00:16:01;
    it also lists the `VariorumCore` product, a build-graph difference only — the test target, host and plan are the same).
- **The suites are real types** (`nm -j` + `swift-demangle --simplified`, matched as `<Suite>.` on a word edge — a name
  that matches no type runs 0 tests silently): the plan's step-1a list parsed from this record = **121 names, 121
  distinct**, identical in order to the builder's `u9/mac-batch-suites.txt`, **121 of 121 found in BOTH `vx336-u9` and
  `vx336-u9-red`**, ≥ 52 symbols each (the least `BlockTOCStatusTests`); `MCPWireRefusalSweepTests`' three test names in
  both (`theSamplesNameEveryCaseExactlyOnce` · `theUnspokenCasesAreRealCasesWithTheirProofs` ·
  `everyCaseTheWireCanCarrySpeaksWordsNeverARawCase`). The phone list (step 1c) = **15 names, 15 of 15 found in BOTH
  `vx336-u9-ios` and `vx336-u9-ios-red`** (≥ 117 symbols, the least `MobileBookPinTests`); `MobileRefusalTableTests`
  carries **7 test names** in both, `theSweepsNoteGoneSentenceReachesEveryFallThroughSite` and the re-pointed
  `eachSiteKeepsItsOwnFallbackWhereTheTableHasNoWords` among them — the plan's "7 tests".
- **The kit:** `answers.py` dry-run on a COPY of U8's `U8-org` tee (in the runner's scratchpad, so U8's evidence folder
  is untouched) reads step 5's answer from bytes as `isError=True  answer: Refused: alreadyTagged(tagID: "…", targetID:
  "…")` — the control.

**Host and tools:** `AX: true SCREEN: true` (a compiled non-prompting probe); `walk-cap`, `walk-scroll` and the probe
compiled FRESH into `u9w/bin/`; `Tools/WalkKit/wl2` present in this worktree (arm64, 15:10, newer than `wl2.swift`); Claude
Code **2.1.300**; `cliclick` at `/opt/homebrew/bin`. Free disk **51 GiB**. Load average 18–30 (another session's work).
**`U7_SCRATCH` = `<the runner's scratchpad>/u9w`** — created FRESH at READY (absent before; the shared scratchpad holds the
earlier windows' `u7w`, `u8w`, `proj/`, none reused).

**Her user-scope MCP servers (names + a sha256 prefix of the sorted compact `mcpServers` JSON, never values):**
`['linear-server', 'variorum']`, **`bc64543e2f4e8e58`** — SAME as U5–U8's windows.

**The instances, the simulators and the stage at READY — NOT ours:** both strict guards (`pgrep -lx Variorum`, `pgrep -lf
"MacOS/Variorum$"`) EMPTY, the loose form EMPTY, no `variorum-mcp`; **0 simulators booted**; the plan's device **iPhone
*[removed for publication]*
`oct13coordinator`** ("HOLD: coordinator queue", claimed 00:05:36 for 180 min) — not ours; the GO's relayed line is run
exactly as relayed. The stage log since U8's release: `vx283-u1b-walk` 23:35:55–00:04:14. **Main:** `origin/main` is
`ebd16909` (ahead of this branch by notes, `.claude` and `CLAUDE.md` only) — VX-306 has NOT merged, so no rebuild is owed.

**The dev store (read-only listing at READY):** `variorum.sqlite`, `-wal`, `-shm` all stamped 15 Oct 00:03:06 (vx-283's
window ended 00:04; earlier windows saw 14 Oct stamps), key files `variorum-keys-b831b428ce0d67b1.json` ·
`variorum-keys-e86ed514dc8dab5a.json`; **the sha256 prefixes EQUAL U5–U8's A1 set** (sqlite `c17923414b2e` · wal
`7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890`) — the content is as U8 left it, only the
stamps moved. `Backups/` 57 entries; `Backups/safety-copies/` holds only `castle-W1-20261013` (left alone). Prefs 1,602
keys, `variorum.whatsNew.lastVersion` 0.9.6 (= the product's, so no What's New sheet is expected), `appearanceChoice`
system — informational only: the restore target is step 2's export, taken after the batch.

**Process choices (the earlier windows' lessons applied):** the Mac batch, the Mac red and the phone red + green FIRST,
each detached to its log and POLLED in the foreground (a `grep -q` loop, never `tail -f | grep -m1`); the simulator shut
and the three red/phone products deleted before the SEAM; prefs, `Backups/`, the fingerprint and the clipboard BEFORE the
A1; the A1 by `stage.sh`'s copy loop ONLY (no fixture), with every guard (strict and loose) empty; every GUI act through
`click.sh` / `keys.sh` (keys only by System Events), at least 2.6 s apart; region captures; `á` and `·` never typed;
Settings driven by AX; the Debug app quit BY BUNDLE ID; prefs restored by import, then re-export, diff, delete every
added key until 0 differ; keys redacted to their first 9 characters everywhere; every client turn through the kit's
`turn.sh` (prompt on STDIN, `--strict-mcp-config`); the six answers read from BYTES (`answers.py`).

### LIVE STATUS — the stage run's steps

| step | what | status |
|---|---|---|
| R | read-in, the build check, the fingerprint, this section → READY | DONE (this commit) — READY reported; the stage is NOT claimed (the orchestrator relays the coordinator's GO and its exact line) |
| 0 | guards; the claim from the GO's line; HEAD at the GO; the product check | DONE — the GO from oct13coordinator at 00:57 (its checks: vx283-u3 released 00:56 with the dev store restored and verified; no instances by the strict forms; no sims; 50 GiB; dev `safety-copies` holds only castle-W1; **the SEAM's "continue" PRE-GIVEN**; shut the simulator before the A1). **HEAD at the GO `aef3149f`**; `git diff --name-only c2f77ce9..HEAD -- Sources App Tests Package.swift` still EMPTY. Pre-claim: `guard.sh --author` OK (idle 3,298 s); both strict guards and the loose form EMPTY; 0 sims; `stage status` → held by `coord-for-vx336` ("GO pending: vx336-u9"). The exact line run: `Tools/stage release --who coord-for-vx336 && Tools/stage claim --who vx336-u9 --reason "VX-336 U9: 121-suite Mac batch + Mac red + one-sim phone red/green, SEAM, A1 + real-client turn + faces both voices on the Debug dev store" --minutes 75` → **STAGE RELEASED (was 'coord-for-vx336') · STAGE CLAIMED by 'vx336-u9' for 75 min at 00:57:47 MDT** (expires 02:12:47) |
| 1a | the Mac batch (121 suites on `vx336-u9`, `test-without-building`, detached + polled) | DONE (00:57:52 → 01:00:46) — from `App/Variorum/`, the 121 `-only-testing:VariorumTests/<Suite>` from `u9/mac-batch-suites.txt`, `-resultBundlePath …/u9/u9-batch.xcresult`, detached to `u9/logs/u9-batch.log`, polled. **"✔ Test run with 771 tests in 121 suites passed after 134.892 seconds" · `** TEST EXECUTE SUCCEEDED **`.** The result bundle: **Passed — 771 total · 765 passed · 0 failed · 6 skipped · 0 expected failures**, 121 suites seen (per-test results `u9/u9-batch-tests.json`). **The 6 skips are EXACTLY the plan's five gated capture harnesses** (`MCPAsksWaitCaptureTests` 1 · `MCPGrantSheetCaptureTests` 2 · `MCPGrantSheetU2CaptureTests` 1 · `MCPPaneTabsCaptureTests` 1 · `MCPShareFacesCaptureTests` 1 — five suites, six tests). **`MCPWireRefusalSweepTests` 3/3 ✔ — its FIRST run, green on the final tree** (`theSamplesNameEveryCaseExactlyOnce` · `theUnspokenCasesAreRealCasesWithTheirProofs` · `everyCaseTheWireCanCarrySpeaksWordsNeverARawCase`); **`OpsRefusalTableIntegrityTests` 2/2 ✔** (the nine new sentences name no platform door). No «Issues recorded without an associated test». **Zero reds — no finding.** The test host exited (every guard EMPTY after) |
| 1b | THE MAC RED RUN on `vx336-u9-red` (`MCPWireRefusalSweepTests` alone), then `rm -rf` the red | DONE (01:01:06 → 01:01:32) — `-xctestrun DerivedData/vx336-u9-red/…xctestrun -only-testing:VariorumTests/MCPWireRefusalSweepTests` → `u9/logs/u9-mac-red.log`: **"✘ Test run with 3 tests in 1 suite failed after 0.011 seconds with 20 issues" — EXACT: 3 tests · 1 failed · 20 issues**, all in `everyCaseTheWireCanCarrySpeaksWordsNeverARawCase` — 10 at `:194` (the "Refused:" prefix) + 10 at `:195` (the case's name + "("), **two per case for EXACTLY the ten R/E cases** (`alreadyInReading · readingAtCapacity · commentNotDeleted · invalidSectionName · invalidEntryDate · containerNotFound · wrongReadingKind · tagNotFound · blockAlreadyPlaced · blockNotInContainer`, read from each issue's comment line, e.g. `containerNotFound: Refused: containerNotFound(id: "c")`; `u9/u9-mac-red.pairs`) — **no W-class case red, nothing mis-swept**; `theSamplesNameEveryCaseExactlyOnce` ✔ and `theUnspokenCasesAreRealCasesWithTheirProofs` ✔. With 1a's 3/3: **the sweep pin red on the old table and green on the new.** The red product then DELETED (`DerivedData/vx336-u9-red`) |
*[removed for publication]*
| SEAM | 1a–1c recorded, committed, pushed; the claim KEPT; turn ended "SEAM" (unless the GO pre-gives "continue") | DONE (01:05) — the claim `vx336-u9` held (~7 of 75 min used; expires 02:12:47); no instance; nothing launched; 0 simulators booted; no A1 yet. **The coordinator's "continue" was PRE-GIVEN in the GO**, so the turn did NOT end: straight on to step 2 |
| 2 | prefs export, `Backups/` listing, the store listing, the fingerprint BEFORE, the clipboard saved | DONE (01:04:52) — every guard EMPTY first. Prefs exported **1,602 keys** (`variorum.whatsNew.lastVersion` 0.9.6, `appearanceChoice` system) → `u9/prefs-pre.plist` (the restore target). `Backups/` **57 entries** (`u9/backups-pre.txt`); the store listing `u9/store-listing-pre.txt` (`variorum.sqlite` 00:03:06, `-wal` 00:03:06, `-shm` 01:01:10 — the batch's test host — and the two key files); `safety-copies/` holds only castle-W1. Her user-scope servers BEFORE `['linear-server', 'variorum']` **`bc64543e2f4e8e58`** — SAME (`u9/userscope-pre.txt`). The clipboard saved, never read: **349 bytes** (`u9w/clip-before.txt`) |
| 3 | THE ONE A1 (`stage.sh`'s copy loop only; cmp + sha256) | DONE (01:04:59) — strict and loose guards EMPTY; **`…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T070459Z`** (`u9/a1-path.txt`): five files, each `cmp`-verified; sha256 prefixes (`u9/store-hash-pre.txt`) sqlite `c17923414b2e` · wal `7f2fcf1ec90d` · shm `e4e2b900d45c` · keys `3af4704371ff` / `7e12a1b85890` — **EQUAL to U5–U8's A1 sets**; castle-W1 untouched |
| 4 | launch `vx336-u9` (Study expected) | DONE (01:05:06) — `guard.sh --author` OK (idle 3,740 s); `open -n …/vx336-u9/…/Variorum.app` → **pid 52422** (both strict guards show it, the `vx336-u9` path), window 1380×900 at (60,36); **Study, light, the Bookcase; no What's New sheet, no lock screen** (`live/s/00-launch`) — sherlock and the field guide on Welcome, quicknotes · o ladrão de raios · starred notes unshelved |
| 5 | bind (the key only) + THE GRANT A wing · Home · Write new · Always | DONE (01:05–01:07). App menu ▸ **MCP Settings…** (by AX, `keys.sh`) → the Settings window 748×552 at (200,33): **the switch ON, "running · socket in the app container · serves while Variorum is open"**; Clients: claude-code "last seen 4 days ago · 3 grants", u3-walk, u2-walk, u1-walk (`00a-mcp-pane`). **Connect ▸ Claude Code ▸ the copy icon** (`00b-connect`; the block shows this product's shim path, the key masked) → from the clipboard ONLY the key (**`vmk2_clau…`**, 60 characters, the `vmk2_claude-code_` prefix) into `u9w/keys/u7.key` (dir 700, file 600); never the copied line, never `-s local`, never her user scope; **the clipboard emptied at once** (0 bytes). **The bind turn** (01:06:30–01:06:39, `u9/bind.jsonl`, `tee/bind-*`): `variorum-dev` "connected" (dynamic), model `claude-fable-5`; `initialize` → serverInfo `variorum` 0.9.6, instructions 2,969 code points; **`tools/list` 62 tools**; the answer "list_books returned **1** book: \"o ladrão de raios\" (6 notes, in the Home wing)." **Activity: "claude-code connected with a new setup, now bound to its name"** then "claude-code listed books" — ZERO clicks, the BIND arm (`00-bind`). **THE GRANT:** Clients ▸ claude-code ▸ Change… → "Grant access — claude-code" (it opened on A book · the field guide · Read — `01a-change`) → **A wing · Home** ("everything in Home except your daily Journal and anything Private, which always ask" — `01b-wing`) → **Write new** ("it can also make new notes, apply tags and build books") · Always → **"Grant write new in “Home” always, including notes added later"** (`01-grant`) → Shared with AI: **"Home · wing · claude-code · read, suggest and write new · always"** atop the standing "o ladrão de raios" rows (`01c-row`) |
| 6 | THE U9 TURN (`U9-tags`) + `answers.py` — the six verdicts from bytes | **ALL SIX PASS, read from the wire's bytes** (01:07:42–01:08:22; `u9/U9-tags.jsonl`, `tee/U9-tags-*`, `U9-tags-answers.txt`, `U9-tags-measure.txt`; model `claude-fable-5`). Exactly six `tools/call`, in the prompt's order, no step skipped or added; every answer INLINE (66 · 344 · 433 · 135 · 433 · 34 characters). **(1) `create_book`** `{name "u9 tea", wing_id ""}` ok → `book_id 25461506…`. **(2) `set_book_rule`** `{rule {tag "u9-green-tea"}, outflow ["u9-green-tea"]}` ok → `changed true, collecting true, minted_tags 1, new_matches "join", outflow ["u9-green-tea"]`. **(3) `create_note`** `{book_id, title "u9 brewing", text "Water at 80 degrees."}` ok → `note_id 04578DD3…`, **`tag_ids: ["68EEE693-CB36-4C98-B5CE-F51049E21CB7"]` (ONE id), `tags: ["u9-green-tea"]`** — **VX-361 PROVEN** (U8's `[]`). **(4) `apply_tag`** `{note_id 04578DD3…, tag "u9-green-tea"}` → **NOT isError: `{"changed":false,"note_id":"04578DD3…","tag":"u9-green-tea","tag_id":"68EEE693…"}`** — the SAME `tag_id` — **VX-362 (a) PROVEN** (U8's raw `Refused: alreadyTagged(…)`). **(5) `import_document`** `{book_id, document "{t:\"u9 second\"} {#u9-green-tea}\n\nSteep 2 minutes."}` → **NOT isError — the import LANDED whole**: `note_id 9A53D88E…`, one block, **`tag_ids` = that one id ONCE, `tags: ["u9-green-tea"]`** — **VX-361's collision PROVEN closed** (the trace's `SQLite error 19`). **(6) `add_note_to_book`** (the note from step 3, the same book) → **isError, EXACTLY "That note is already in this book."** — **VX-362 (b) PROVEN** through the Mac table and the door (the trace's raw `alreadyInReading`). **No answer starts "Refused:" or carries a Swift case** (`grep` over the server's side of the tee: "Refused:" 0, `alreadyTagged`/`alreadyInReading`/`tagID:`/`targetID:`/`postID:`/`readingID:` 0). The model's closing reply repeated each answer verbatim and read step 4 right: "changed is false because the note already wore the tag from the book's outflow" |
| 7 | the faces: Study (Bookcase, book, the note's tag once, Activity) → Terminal (Activity, book) → back to Study | **PROVEN in both voices** (01:09–01:11). **Study:** the Bookcase (the main window captured by id, unoccluded) shows **"u9 tea" #u9-green-tea · 2 notes · 7w · living**, Unshelved, wearing the shared icon (every Home book wears it under the wing grant) (`live/s/02-bookcase`); Settings closed by its AX close button, a pointer click on the row → the book in Outline: **"u9 tea" · book · 2 notes — "u9 brewing" ("Water at 80 degrees.") and "u9 second" ("Steep 2 minutes.")** (`03-book`); "u9 second" ▸ open ↗ → Write: **"u9 second" · in u9 tea · ONE tag chip `u9-green-tea`** · "Steep 2 minutes." — the header's `{t:…}` became the title and its `{#…}` the one tag, no token left in the body (`04-note-tag`). App menu ▸ MCP Settings… ▸ **Activity** (`05-activity`) and its "all 144 ›" sheet (`05b-activity-all`): **"claude-code was refused adding “u9 brewing” to a book" (muted) · "claude-code imported “u9 second”" · "claude-code tagged “u9 brewing”" (the `apply_tag` line LANDED, not muted) · "claude-code made the note “u9 brewing”" · "claude-code set what “u9 tea” collects" · "claude-code made the book “u9 tea”"** — the six acts in words, no tool id; then "listed books" and the bind line; Done. **Terminal:** Settings ▸ General ▸ Theme ▸ **Terminal** (a pointer click on the segmented control — `live/t/00a-general`, `t/00-theme-terminal`); Settings ▸ mcp ▸ Activity in Terminal — the same lines (`t/05-activity`); the note in Terminal: "u9 second" · "~/u9 tea" · the one `u9-green-tea` chip (`t/04-note-tag`); ← to the book: **"~/u9 tea" · book · 2 notes, u9 brewing / u9 second** (`t/03-book`). Theme back to **Study** (Appearance Follow system, palette Default — `s/06-back-study-settings`, `s/06-back-study`) |
| 8 | cleanup → quit by bundle id, key grep 0 + `keys/` deleted, clipboard restored, no `mcpServers` for the scratch project, fingerprint SAME, prefs 0 differ, `restore.sh` cmp-SAME + sha256 equal, `Backups/` unchanged, castle-W1 untouched, 0 sims; release; THE RESULT LINE | DONE (01:12:00–01:12:51) — **the Debug app quit BY BUNDLE ID** (`tell application id "io.lduarte.Variorum.debug" to quit`, rc 0; no modal was up): both strict guards and the loose form EMPTY; no `variorum-mcp`, no turn (`keys/cfg-`); her `/Applications` app never running. **The key** (read whole from `keys/u7.key`, 60 characters) grepped over `u9/`, `~/.claude.json`, `~/.claude/projects/` (the whole tree), `notes/` + `Tools/`, and the whole scratchpad outside `keys/` → **0 files** (only `keys/` held it: `u7.key` + `cfg-bind.json` + `cfg-U9-tags.json`); then **`keys/` DELETED**. **The clipboard RESTORED** (349 bytes; `pbpaste \| cmp` SAME), the saved copy deleted. **No `-s local` registration was ever made:** `~/.claude.json` has NO `projects` entry naming `u9w` (read-only `python3 -I`; never `claude mcp get`/`list`); the scratch project's `~/.claude/projects/…-u9w-proj/` holds only its two session transcripts — no saved-to-file tool result (every answer was inline). **Her user-scope servers AFTER `['linear-server', 'variorum']` `bc64543e2f4e8e58` — SAME** (`u9/userscope-post.txt`). **Prefs:** the window added 1 key (`currentBlock.<u9 second's id>`) and changed 5 (`IdleCommitSweepMark.Variorum-dev`, the Settings window frame, `openNotes.remembered.ids`/`.recency`, `variorum.backup.log`) (`u9/prefs-window-diff.txt`) → `defaults import prefs-pre.plist` + `defaults delete` of the 1 → re-export **1,602 keys, 0 added · 0 removed · 0 changed** (`u9/prefs-post.plist`). **The dev store:** `Tools/ScaleFixture/restore.sh …/scale-prestage-20261015T070459Z` → **"Restored (verified)"** (`u9/logs/restore.log`), a second `cmp` of all five files **SAME**, the sha256 set **EQUAL** to the A1's (`store-hash-restored.txt` = `store-hash-pre.txt`) — Standard, unlocked, Study, claude-code's pre-window binding and its three "o ladrão de raios" grants back (the u9 tea book, its two notes, the tag, the Home write-new grant — every window write — gone with it); the store folder's names unchanged (two key files). `Backups/` names **UNCHANGED** (57 entries); `safety-copies/` holds `castle-W1-20261013` (untouched, its Oct 13 stamps) + this window's A1. **0 simulators booted**; no stray `default.profraw`; the tree clean; `DerivedData/vx336-u9` kept (the ladder's product), the three others deleted; 56 GiB free. **RELEASED 01:12:51 MDT** (`Tools/stage release --who vx336-u9` → STAGE RELEASED (was 'vx336-u9'); `status` → STAGE FREE), ~15 of the 75 claimed minutes |

**THE RESULT LINE (for the coordinator):** claim `vx336-u9` 00:57:47–01:12:51 MDT, RELEASED (~15 of 75 min); the batch, the Mac red and the phone first, the SEAM (its "continue" pre-given), then the rest.
- **The Mac batch (121 suites, `vx336-u9`):** 771 tests — 765 passed · 0 failed · 6 skipped (exactly the five gated capture harnesses; `MCPGrantSheetCaptureTests` holds two); `MCPWireRefusalSweepTests` 3/3 on its FIRST run; `OpsRefusalTableIntegrityTests` 2/2.
- **The Mac red (`vx336-u9-red`):** EXACT — 3 tests · 1 failed · 20 issues, two per case for exactly the ten R/E cases (no W-class case red). Deleted.
- **The phone (iPhone 17 Pro, iOS 26.2, one simulator):** the red EXACT — 7 tests · 1 failed · 5 issues (the five fall-through sites; the re-pointed guard green); the green — 120 tests in 15 suites passed, no restart (2 known issues BY DESIGN, a `withKnownIssue` pin). The simulator shut; both phone products deleted.
- **THE U9 TURN — all six PASS from the wire's bytes:** (1) `create_book` ok; (2) `set_book_rule` ok, outflow `["u9-green-tea"]`; (3) `create_note` → `tag_ids` one id, `tags ["u9-green-tea"]` (**VX-361**, U8's `[]`); (4) `apply_tag` → NOT an error, `changed:false`, the same `tag_id` (**VX-362 (a)**, U8's raw `alreadyTagged`); (5) `import_document` whose header names the outflow's tag → LANDED whole, the tag listed once (**VX-361's collision**, the trace's `SQLite error 19`); (6) `add_note_to_book` again → exactly "That note is already in this book." (**VX-362 (b)**). No answer starts "Refused:" or carries a Swift case.
- **The faces PROVEN in both voices:** "u9 tea" on the Bookcase (2 notes, living, the shared icon), its two notes, "u9 second" wearing its tag once, Activity's six acts in words (the `apply_tag` line landed, the add refused, muted) — Study and Terminal; back to Study.
- **Posture:** dev store cmp-SAME vs A1 (sha256 set equal), prefs 0 differ (1,602 keys), fingerprint SAME (`bc64543e2f4e8e58`), clipboard restored (349 bytes, cmp SAME), Standard/unlocked, Study, castle-W1 untouched, `Backups/` unchanged (57), no `-s local` registration, the whole-key grep 0, `keys/` deleted, no instance left, 0 simulators booted.
- **The A1 copy, the coordinator's to prune:** `…/Variorum-dev/Backups/safety-copies/scale-prestage-20261015T070459Z`.

**Noticed, not fixed (no product change under the claim):** none that is a finding. (1) The dev store's three files carried 15 Oct 00:03 stamps at READY (vx-283's restore does not keep the A1's stamps) while their content equalled U5–U8's A1 set — informational. (2) The phone green's "2 known issues" are `MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`'s deliberate `withKnownIssue`. (3) The phone red product's `.xctestrun` also lists the `VariorumCore` product (a build-graph difference; the run was exact).

## THE LADDER — ROUND 1 (the Fable cold review, effort xhigh — her cast word; REVIEW_PROMPT verbatim, PHASE=VX-336; read-only; recorded verbatim by the orchestrator, 2026-10-15 ~01:30 MDT)

Diff reviewed: origin/main (074c0f94)…HEAD (aef3149f) — 101 files, +16,589/−331. Zero `Sync/`, custody/keychain,
schema/Persistence or editor-seam files (verified by path grep). The reviewer ran the new/modified headless suites itself:
114 tests/18 suites + 71/10 (MCP) + 10/3 (core), all green, 1 known issue (VX-357). No "Review foci" section exists.

### Findings (as reported; severity-ranked)

- **R1-1 [MAJOR]** · the record's U9 STAGE RUN (steps 0–8 NOT-STARTED at review time) · U9's acceptance evidence was
  unexecuted — a merge gate, not a code bug. The 108-case sweep pin (`MCPWireRefusalSweepTests`) and the phone pins had
  never run; the 121-suite Mac batch over the shared-table change and the real-client leg were NOT-STARTED. Fix: run the
  planned `vx336-u9` window (at minimum its batch-only fallback) and record the exact counts BEFORE the PR merges. The
  reviewer cross-checked the pin's source-walk itself (108 declared = 108 unique samples; 33 unspoken = 17+13+1+2; 75
  walked) and the hook it replays (`MCPDoor.swift:404` → `OpsRefusalCopy.message(for:)`).
- **R1-2 [MINOR]** · `notes/MCPSpec.md:9` ("≤2,000") vs `MCPSession.swift:166` (`instructionsBound = 3_000`) · canon is
  false the moment the PR merges unless the owed deltas land in-branch first; none of the run's new contract surface is in
  MCPSpec yet (insert_blocks, duplicate_note, paged/ids_only read_note, sha256, list_my_activity, apply_tag's
  changed:false, the ten worded refusals, VX-363's import road, VX-361's every-tag answer). Fix: the closeout's canon-delta
  step, before the merge commit.
- **R1-3 [MINOR]** · the record's top LIVE STATUS (U9 row and LADDER row) · stale state lines on the file that declares
  itself the live state. Fix: a two-line status refresh (orchestrator).
- **R1-4 [NIT]** · `MCPWriteTools.swift:216–224` · `take_ids: []` still saves an EMPTY lens, while P-VX253-2 refuses a
  label matching nothing to avoid "a junk lens a suggest client can't delete". Pre-existing, deliberately byte-unchanged;
  offered for P-VX253-2's QUESTIONS bundle as a consistency option.
- **R1-5 [NIT]** · `MCPNoteStructure.swift:864` (`"length": text.count`) vs the page budget's UTF-16 count · two meanings
  of "characters" in one answer; pre-existing (G-256-1), wording-class only.

**Clean bill (the reviewer's, mechanism-level):** U5b/U6a core ops (insertBlocks' guard-first transaction, seal, anchor
in-transaction, touch+churn, one entry; duplicateNoteForClient wraps the one extracted body); the shared answer shape
(no second read, I10 honored, `source_block_id` only when set); duplicate_note's two-sided reach and fence; insert_blocks'
rung-from-arguments and both `flushesHerEditorFirst` answers; VX-256/U7c paging (keyset range seek, exact piece
accounting belt-checked by a final measurement, cursor checked before any once spend, unpaged forms byte-unchanged);
VX-254 digests (and the code matching the F-254-2 (b) RULING); VX-261 (a pure projection, era-cut, oracle-clean); U9 (the
one refusal chain, the nine arms + invalidEntryDate, apply_tag's changed:false with no undo/receipt, the import's
UNIQUE collision closed, VX-363's one predicate); show_in_app compare and the landing with the three router clears;
VX-330/VX-342; U8's docs (instructions 2,969/3,000, truth pins, guide parity clause, the stargazing brief); process
(pin-before-fix per member, revert checks, forks ruled before halves, lanes honored, no trailers, tickets labeled).

**Summary:** 0 BLOCKER · 1 MAJOR (evidence: the pending U9 window) · 2 MINOR · 2 NIT. No code-level bug with a traceable
wrong-output mechanism.

### ROUND 1 — dispositions (the orchestrator; no finding needs a code change, so there is nothing for the implementer to apply)

- **R1-1 — AGREED, closed by evidence:** the `vx336-u9` window was GO'd at 00:57 and ran whole (pre-given SEAM); its
  counts are recorded in the U9 STAGE RUN. No code.
- **R1-2 — AGREED:** the closeout applies every canon delta IN-BRANCH before the merge commit (MCPSpec's bound line
  ≤3,000 and contract lines for every new surface). R2 re-checks them.
- **R1-3 — AGREED, done by the orchestrator** (the top LIVE STATUS refreshed in the same commit as this record).
- **R1-4 — AGREED as a NIT, no change:** filed with P-VX253-2's options in the QUESTIONS bundle (option: refuse an empty
  `take_ids` too).
- **R1-5 — AGREED as a NIT, no change:** recorded; a wording note for a later description pass (VX-234's list).
- **Round 2:** a FRESH `fable-reviewer` at xhigh (her cast word), REVIEW_PROMPT verbatim, after U9's window and the
  closeout's in-branch canon deltas, so it reads the evidence and the canon together. A new BLOCKER/MAJOR earns round 3.

## CLOSEOUT RECORD — PHASE A (the closeout implementer — opus-implementer, from 2026-10-15 ~02:00 MDT)

**Not done (first line, kept current):** PHASE A is DONE (items 1–9 below). PHASE B (the closeout window) and PHASE C
(the merge-moment ledgers, the kits' deletion, the PR, the merge, the release, the refresh, the cleanup) are later
sessions; ladder round 2 has not run; no shared ledger on
main is touched (QUESTIONS, the master plan, AppSpec §14, MobileSoul, the finals ledger — their DRAFTS are below); no
Linear edit, no ticket minted (proposals are in OWED); no product code, no test beyond a headless `swift build`, no
`xcodebuild`, no stage, no store.

**Read in full in this session (never delegated):** CLAUDE.md and its loaded canon (main's CLAUDE.md for the labeling
rule and the closeout ritual, `ebd16909`); this record whole, section by section (the header, kickoff answers, Hard
rules, LIVE STATUS, Stage traffic log, Cross-run coordination, her rulings, the ORCHESTRATOR'S PROVISIONAL RULINGS,
Tickets minted, every UNIT BRIEF, every UNIT RECORD's design, PROVISIONALs, FOR VX-234, OWED and self-assessment, every
ORCHESTRATOR ON … section, every STAGE RUN's result line, THE LADDER — ROUND 1, the CLOSEOUT BRIEF); `notes/MCPSpec.md`
whole; `notes/plans/mcp-pane-and-docs-kickoff.md` whole; VX-246's CLOSEOUT RECORD and CLOSEOUT DRAFTS D1–D9 and its
handoff; on main (`ebd16909`, read-only): QUESTIONS' tail, AppSpec §14, `notes/plans/run-finals-ledger.md`,
`notes/AppSpecDeltaArchive.md`'s roll headings, MobileSoul's newest rows, the master plan's in-flight table;
`notes/SessionResiliencyProtocol.md`'s implementer section. Code read to check every number and rule MCPSpec now
states (below).

### LIVE STATUS — PHASE A's items (flipped in the same commit as each item)

| # | item | state |
|---|---|---|
| 1 | `notes/MCPSpec.md` in-branch: the bound ≤3,000, the link, a contract line + pointer for every new surface; AppSpec §12 checked | DONE (this commit) — ### ITEM 1 below; AppSpec §12 UNCHANGED (argued there) |
| 2 | the QUESTIONS bundle draft (D1) | DONE (this commit) — D1 below (#227 unless taken) |
| 3 | the AppSpec §14 draft + the roll + the finals ledger text (D2, D3) | DONE (this commit) — D2 (the entry, the VX-179 roll, the VX-283-first case) and D3 below |
| 4 | the master plan draft: retire VX-336's in-flight row only (D4) | DONE (this commit) — D4 below |
| 5 | the MOBILE PARITY draft (D5) | DONE (this commit) — D5 below (PL-56 unless taken) |
| 6 | RULINGS RECONCILED (D6), remainders proposed in OWED | DONE (this commit) — D6 below: 24 rulings; REMAINDERS rows 11, 14, 15, 16 (+ row 12's optional evidence gap) → OWED T1–T5 |
| 7 | the handoff draft `notes/handoffs/vx-336-handoff.md` (D7) | DONE (this commit) — the file in the branch; D7 below lists its «…» fills |
| 8 | the STATUS lines drafted closed (D8) | DONE (this commit) — D8 below |
| 9 | the kits' deletion and PHASE C's own steps written into the PHASE C draft (D9) | DONE (this commit) — D9 below: the kits `git rm -r` in-branch BEFORE the merge; the evidence and DerivedData after it. **PHASE A DONE** |

### ITEM 1 — `notes/MCPSpec.md`, in-branch (R1-2's fix; round 2 reads it)

Four in-place edits and one new block, each a contract line with a pointer, nothing of history:
1. **The binding records** (line 5) gain `vx-336-mcp-wire-tools-ai-docs.md`.
2. **The docs clause:** `MCPSession.instructions` "(≤2,000 characters, …)" → "(≤3,000 characters — R-VX184-3, raised at
   VX-336 — …)". Checked: `MCPSession.instructionsBound = 3_000` (`MCPSession.swift:166`); the instructions as read from
   the code end "The guide to this door: https://stargazing.tech/variorum/mcp" (`:158`), 2,969 characters by U8a's pin.
3. **The shared icon's rows:** "Book Panel rows" gains "(a collapsed one-note chapter row is its note's row and wears its
   marks — VX-330, built at VX-336)" — U6b's OWED 3 wording.
4. **The pre-act flush list** gains `duplicate_note` ("since VX-336 … a copy reads her latest words") — checked:
   `Job.flushesHerEditorFirst` answers `true` for `.duplicateNote` and `false` for `.insertBlocks`
   (`MCPWriteTools.swift:146–176`).
5. **NEW block "THE WIRE TOOLS AND THE AI'S DOCS (VX-336 …)"** before "Level 0 is 13n-a's format", one bold head per
   surface the brief names: the AI label form (VX-267) · `save_lens`' fills (VX-253) · the minted answers, `section_id`
   and `tag_ids`/`tags` (VX-252, VX-361) · `insert_blocks` (VX-255) · `duplicate_note` (VX-311) · Compare from the wire
   and `link_versions`' Open › (VX-298) · the `sha256` digest (VX-254) · paged and `ids_only` `read_note` (VX-256) ·
   `list_my_activity` (VX-261) · `apply_tag`'s `changed: false` (VX-362 (a)) · the refusal sweep (VX-362 (b)) · the
   book import's name check (VX-363) · the docs, the link and the chapter (VX-197). Every provisional choice is named by
   its P- id; the block's head names the bundle as **QUESTIONS #227** (the next free number on main at `ebd16909`;
   PHASE C renumbers here if a sibling run takes it first — D9).

**Every number and rule checked against the code at this commit's tree:** `batchCap = 200`
(`MCPWriteTools+Batches.swift:52`); `comparePeerCap = 3` (`MCPShowTool.swift:210`); `pageAnswerBudget = 32_000`
(`MCPNoteStructure.swift:112`) and `read_note`'s `limit` 1–200 default 50 (the catalog's schema and description);
`lensListCap = carriageCap = 200` for `unmatched_blocks` and the ambiguity list, with `unmatched_count` /
`ambiguous_count` (`MCPWriteTools.swift:437–438`, `MCPWriteTools+LensRule.swift:211`); `sectionWithoutBookWords`
(`MCPWriteTools.swift:865`); `duplicate_note`'s answer keys `source_note_id` and `landed`
(`MCPWriteTools+DuplicateNote.swift:93–95`), its `rung: .writeNew`, `scopes: [.wing]`; `list_my_activity`'s
`listedWhenApproved: true`, `limit` 1–200 default 50, `include_reads` (the catalog, `:361–386`) and the log's cap
`mcpActivityCap = 500` (`Operations+MCPGrants.swift:43`); `MCPOwnActivity.hidesTarget` — a refused row of
`duplicate_note` on its wing side and EVERY refused row of the three chapter acts and `delete_take` (so the block says
"`delete_take`", not only its last-take case); the eight tools carrying `digestSentence` (`addTake`, `addTakes`,
`createNote`, `importDocument`, `editTake`, `insertBlocks`, `duplicateNote`, `restoreCommit`, plus `readNote`'s
`ids_only`); `show_in_app`'s `compare` enum and description; the chapter title `TutorialSeeder.mcpChapter = "AI & the
MCP door"`.

**AppSpec §12 — UNCHANGED (no contract line there is now false).** Read against the as-built run, line by line:
"every AI write is one of §9's operations with the grant check inside the op's own transaction and ONE ⌥⌘Z entry naming
the client" — `insert_blocks` and `duplicate_note` are new MCP wrappers in the operations layer on §9 roads (newBlock's
mint, `duplicateAsVersion`'s body), exactly as VX-184's batches were, each with its guard inside and one entry;
`apply_tag`'s `changed: false` writes nothing, so it is no write; "her pending typing lands first" — `duplicate_note`
joins the flushing family (MCPSpec's list, item 4); "Private, Seal and Own are hers alone" — nothing here writes them;
"the fence … ONE byte-identical not-shared shape" — truer now (VX-363 closed a leak; P-VX261-5/6 keep the activity list
oracle-clean); "a book rule an AI writes BELLS" — untouched; "the shared icon reads reach only for the rows DRAWN" —
VX-330 added no read; "`show_in_app` moves things only while Variorum is frontmost and never queues" — the compare
landing's router clears keep it unqueued. §9's lines are untouched too (`importBook`'s new parameter defaults to her
doors' full guard).

### CLOSEOUT DRAFTS (exactly as they will land at PHASE C; each anchor quoted)

*(Numbers are the next free ones on main at `ebd16909`: QUESTIONS **#227**, MobileSoul **PL-56**. VX-283 is live and may
merge first; PHASE C re-reads main and renumbers every draft, and MCPSpec's one "#227", if a sibling took it — D9.)*

#### D1 — `notes/QUESTIONS.md`, the bundle (a new section at the end of the file; #227 unless taken)

Anchor: after the last line of the file (on `ebd16909`, the VX-246 section's "Status: open — your eye; the handoff's
checklist leads with this bundle."), one blank line, then:

> ## VX-336 — Run: MCP wire tools & AI docs (2026-10-15)
>
> #227 — **THE VX-336 RATIFY BUNDLE (merged 2026-10-15, «PR #N», merge commit «sha»; the binding record is
> `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` — her rulings during the run, the ORCHESTRATOR'S PROVISIONAL
> RULINGS, each UNIT RECORD's PROVISIONALs with their options and the orchestrator's rulings on its forks, THE LADDER;
> your handoff `notes/handoffs/vx-336-handoff.md`).** Built through the evening and the night under your away-mode answer
> (*"Rule provisionally, continue"*) and your overnight word (*"rule provisionally overnight in my absence and leave me a
> handoff in the morning"*). Each was built as stated below, with a line to reverse it.
> - **The ones most worth your eye:**
>   - **Two pre-launch calls, yours to make:** **VX-363** — an AI could learn the name of a book it can't read by
>     importing a book with the same name. Fixed in this run; filed High. Is it Pre-launch? · **VX-357** — text holding
>     the invisible character U+0000 is stored cut off at it, on every door (yours and the AI's), and the AI's new
>     fingerprint then vouches for the whole text. Not fixed (Todo, Medium). Is it Pre-launch?
>   - **P-VX311-2 — where an AI's duplicate lands, and who may make one.** As built: like your Duplicate as Version, the
>     copy lands in no book, in the note's own wing's Pool, so the AI needs Read on the note and Write new on the whole
>     wing; an AI whose Write new reaches only a book can't duplicate (it asks you for the wing). Options: (b) an
>     optional `book_id` that also files the copy into that book at Write new (no door of yours does that today);
>     (c) the copy joins every book the original is in (not your door; an owned book would refuse or fork).
>   - **P-VX255-1 — "at the end" for `insert_blocks`.** As built: with Write new an AI adds paragraphs only at the very
>     end of a note, by giving no anchor at all; naming any block, even the last one, needs Edit. Your ruling names a
>     place ("add blocks at the end"), the rule is decided before the note is read, and it never flips while you type
>     new paragraphs at the end. Option: (b) naming the note's current last block also counts as the end at Write new.
>   - **P-VX362-1 — the new refusal sentences you may see, on the Mac and the phone** (they replace raw dumps like
>     "Refused: alreadyInReading(…)"): "That note is already in this book." · "This book is at its note limit." · "That
>     comment is already back." · "A chapter needs a name." · "That note isn't there any more — it may have just been
>     deleted." · "That isn't a book — a gathering shows the notes its rule matches and holds none of its own." · "That's
>     already a book — only a gathering binds into one." · "That tag isn't there any more — nothing changed." · "That
>     block is already in a note — nothing changed." (and a block not in its note speaks the existing "not placed"
>     sentence). The first two and the bind sentence are your own doors' words already. And `apply_tag` on a tag the
>     note already wears now answers "done, nothing changed" (`changed: false`): no undo entry, no confirmation line, the
>     Activity line as for any landed act, and a once grant spent as by any landed call (your rulings don't say; this
>     follows the door's rule for every other act that changes nothing). Options: (b) your VX-234 pass rewords any of
>     these; (c) a worded refusal for the second `apply_tag` instead ("That note already wears the tag … — nothing
>     changed.") — set aside, since your seven tag doors treat it as done; (d) the not-shared sentence for the "isn't
>     there any more" class — set aside, since every such refusal follows a decision that allowed the target.
>   - **P-VX256-1 — how big a page of a long note is.** Your first real-client round showed a page ended by 32,000
>     characters of TEXT came to about 65,000 characters of answer, which Claude Code saves to a file instead of
>     reading. Re-ruled and rebuilt: a page ends at `limit` blocks or before the WHOLE ANSWER would pass 32,000
>     characters (all three re-probes then arrived whole: 71 blocks · 71 · 115 with `ids_only`). Options: (b) a higher
>     bound nearer the measured limit (e.g. 40,000: fewer pages, `ids_only` pages close to the client's default);
>     (c) one bound for prose and another for `ids_only`. Its four edges, each built as (i): **e1** the first page
>     always carries its first block, even when the note-wide lists alone fill it ((ii) a first page with no block;
>     (iii) the note-wide lists on a page of their own) · **e2** characters are counted as UTF-16 units, what the
>     client counts ((ii) Unicode characters, looser on emoji; (iii) UTF-8 bytes) · **e3** old commits' text rides
>     newest first until the first that doesn't fit ((ii) keep scanning for smaller older ones) · **e4** an asked-for
>     commit too large for its page's room refuses with "…isn't a commit of a take on this page", and rides where its
>     block starts a page ((ii) always keep it, the page then past the bound; (iii) as (i), with words naming the cursor
>     to ask from). A finding, no change: no page can hold 200 blocks under this bound (about 150 at the smallest), so a
>     `limit` above about 150 never ends a page.
> - **Labels and lenses (VX-267, VX-253):**
>   - **P-VX253-1** — the per-block picks your ruling names keep the wire's existing name, `take_ids` (now optional).
>     Options: (b) rename them `picks`; (c) accept both names.
>   - **P-VX253-2** — a lens label that no take of the note wears refuses ("No take in this note is labelled … — nothing
>     was saved."), so a typo never leaves you a lens a Suggest client can't delete. Options: (b) save it anyway, every
>     block listed as unmatched; (c) refuse only when no `take_ids` were given either; (d) (the review's note, round 1)
>     also refuse an EMPTY `take_ids`, which still saves an empty lens today, unchanged.
> - **Notes an AI makes (VX-252, VX-361):**
>   - **P-VX252-1** — a whole book imported at once answers only its book, note and chapter ids, not every block's
>     takes (that answer would run to about 0.8 million characters for your bilingual book; the AI reads notes as
>     needed). Options: (b) every note's block records; (c) every note's block ids only.
>   - **P-VX361-1** — a new note's answer lists every tag it wears once it lands (`tag_ids`, with their paths in
>     `tags`): the header's first, then the tags a book adds to notes made in it. Option: (b) keep `tag_ids` as the
>     header's only and add `outflow_tag_ids` (the field that misled the AI in your organization round would then stay
>     empty).
> - **Adding paragraphs to a note (VX-255):** **P-VX255-1** is above. **P-VX255-2** — "at the start" is `at: "start"`
>   at Edit (`move_block`'s word); options (b) a `before_block_id`, (c) no start door. **P-VX255-3** — paragraphs come
>   as blocks only; option (b) also plain text split by the note's own setting. **P-VX255-4** — at most 200 a call,
>   said in the description; option (b) no cap.
> - **Duplicating and Compare (VX-311, VX-298):** **P-VX311-2** is above.
>   - **P-VX311-1** — a note shared with the AI only per ask (a daily Journal entry, anything Private) can't be
>     duplicated by it: the copy would lose the protection and stay readable afterwards. One sentence says so without
>     naming why. Options: (b) carry the note's Private mark onto the copy (ruled out: no AI road may write Private);
>     (c) allow it, as your own door does.
>   - **P-VX311-3** — the answer lists the copy's active takes only, each block says which block it was copied from,
>     and the confirmation's Open › opens the copy. Options: (b) archived takes listed too, marked; no source mapping;
>     Open › opening Compare.
>   - **P-VX298-1** — "related blocks only" opens on only when every note the AI names shares history with the first;
>     otherwise off, so no column it names opens empty. Option: (b) off only when none shares any.
>   - **P-VX298-2** — the first note may be archived (you can open one and press ⌘5); the others may not (your
>     picker's rule). Option: (b) refuse an archived first note too.
>   - **P-VX298-3** — the target is a `note_id` plus one to three `peer_ids`. Option: (b) one list of two to four.
> - **An AI checking its own work (VX-254, VX-256, VX-261):** **P-VX256-1** is above.
>   - **P-VX254-1** — dividing and merging answer no fingerprint (the AI sent no words; the halves come from the seam
>     rule, and it can check with `ids_only` pages). Option: (b) answer block records with fingerprints (changes the
>     result types your own editor doors share).
>   - **P-VX254-2** — saving a version and importing a whole book answer no fingerprints. Options: (b) records as
>     `duplicate_note` answers (a version); every note's records (a book).
>   - **P-VX256-2** — pages are read one at a time, not as a snapshot; the description says to read again if the note
>     may have changed. **P-VX256-3** — a note shared once is read in one call, so a once grant reads one page.
>     **P-VX256-4** — a commit asked for by id must be on the page being read ("commit_id … isn't a commit of a take on
>     this page.").
>   - **P-VX261-1** — "its own acts" means every session under the client's name since you last approved it. Option:
>     (b) every row the log still keeps under that name. **P-VX261-2** — any approved client may list its own acts with
>     nothing shared (recovering after a dropped "until it disconnects" grant is the case it exists for). Option: (b)
>     only while it holds a grant. **P-VX261-3** — refused acts are listed, never with a title. Option: (b) not listed
>     (a refusal then looks like a dropped call). **P-VX261-4** — an act that made something names where it was made;
>     the AI finds the made note by its title. Options: (b) log the made note itself (your Activity's "made 25 notes"
>     would become 25 lines); (c) a new local-only column (a schema change). **P-VX261-5** (ruled (b) by the
>     orchestrator) — a refused duplicate's wing-side row shows no target, since the AI never sent the wing's id;
>     option (a) keep it. **P-VX261-6** — likewise every refused row of the chapter acts and of `delete_take`, which log
>     an id the AI didn't send; allowed rows keep it. Options: (b) no target on allowed rows either; (c) log the id the
>     AI sent (your Activity's lines would change).
> - **The guide (VX-197):** **P-VX197-U8b-1** — the chapter stays seven lessons; lesson 3 grew from four paragraphs to
>   eight to name every step's acts. Options: (b) split lesson 3 in two; (c) a new lesson "what a client can do".
>   **P-VX197-U8b-2** — two new recipes (a revision with Compare; a long job checked as it goes) join your four in "how
>   to use it". Options: (b) facts only, in lessons 3 and 7; (c) one combined recipe.
> - **The orchestrator's provisional rulings (ORCHESTRATOR'S PROVISIONAL RULINGS in the record):**
>   - **Ruling 1** — two problems your first organization round met (VX-361: a note's answer said it had no tags when
>     its book had tagged it; VX-362: one refusal arrived as a raw Swift dump) were fixed in this run, before the review,
>     as unit U9. Option: (b) ticket them for later and merge without them.
>   - **Ruling 2** — U9's design found VX-363 (above), the same class VX-246 closed for renaming and making books, and
>     fixed it in the run. Option: (b) ticket it for later.
>   - **Ruling 3 — superseded by your word.** It would have shipped tonight's release without the guide link while the
>     page was missing; you said to publish the page ourselves (*"just go ahead and do the stargazing MCP link
>     yourself"*), so the page went live first and the link stays.
> - **For your eye, not provisional:** the page `https://stargazing.tech/variorum/mcp` is live with stand-in copy
>   marked PLACEHOLDER for your words (your site repo's DECISIONS #86 and PLAN.md's content-owed list) · the night's
>   release notes (0.9.7) were written without your review, at your word for tonight («by this run or VX-283,
>   whichever merged last») · every word your app shows that this run
>   added or changed is on VX-234's list (the handoff gathers them) · two worded refusals speak Mac-door words to an AI
>   ("…since you picked it", "…if it's sealed, unseal it.") — on VX-234's list too · an open Library didn't show two
>   notes an AI made until re-entered (a comment on VX-122, not a new ticket). Cross-refs: VX-267 · VX-253 · VX-252 ·
>   VX-255 · VX-311 · VX-298 · VX-330 · VX-342 · VX-254 · VX-256 · VX-261 · VX-197 · VX-361 · VX-362 · VX-363 · VX-357 ·
>   VX-358 · VX-364 · VX-365 · VX-352 · VX-353 · VX-354 · VX-355 · VX-356 · VM-20.
> *(Numbering: the next free number on main when written; a sibling run merging first may take it — the merging session
> renumbers.)*
> Status: open — your eye; the handoff's checklist leads with this bundle.

#### D2 — AppSpec §14: the new entry leads; VX-246's becomes "Before it —"; the roll (her VX-341 rule)

**D2a — the entry.** Anchor: in §14's one paragraph, replace the exact text `**Most recent canon deltas — VX-246 (a RUN,`
with:

> **Most recent canon deltas — VX-336 (a RUN, 2026-10-14/15 overnight, `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`
> — MCP wire tools & AI docs: VX-246's U5–U8 moved here by its ruling 3 (ratified, #226), VX-330 and VX-342 joined at her
> word; her kickoff answers (VX-246's cast, "as sized", rule provisionally and continue), her ladder-cast word (a fresh
> Fable at xhigh every round), her stargazing word (the page published by this run) and her overnight mandate; the
> orchestrator's provisional rulings 1–2 (U9 joins with VX-361 · VX-362 · VX-363), ruling 3 superseded by her word;
> units U5a · U5b · U6a · U6b · U7 + U7c · U8a · U8b · U9, each proven by red-on-old pins and a Mac batch with a
> real-client live round on the dev store, both voices where a face changed, across five stage windows):** MCPSpec gains
> THE WIRE TOOLS AND THE AI'S DOCS — the AI label form, `save_lens` by `label` or `pin_chosen`, the minted answers with
> `section_id` and every worn tag, `insert_blocks`, `duplicate_note`, Compare from the wire and `link_versions`' Open ›,
> the `sha256` write digest, paged and `ids_only` `read_note` bounded by the answer, `list_my_activity`, `apply_tag`'s
> `changed: false`, no raw refusal on the wire, the book import's readable-books name check — plus the instructions
> bound ≤3,000 with the one public-guide link (R-VX184-3/4; the page live 2026-10-15), the collapsed chapter row's marks
> and `duplicate_note` in the pre-act flush list; AppSpec §12 unchanged. The shared refusal table gains nine sentences
> (both platforms); the undo-overwrite warning says "before" (Mac and phone). Zero `Sync/`, custody, schema and
> editor-seam lines; marker 13 untouched; zero lockstep. The ratify bundle QUESTIONS #227; «PR #N» (merge commit
> «sha»). Before it — **VX-246 (a RUN,

(Everything after it is unchanged: VX-246's entry keeps its text and its bold head, now read as "Before it — ".)

**D2b — the roll (the 2026-09-26 rule as amended by VX-341: keep the most recent ~five, always the most recent MCP
effort).** With VX-336 added, §14 holds six (VX-336 · VX-246 · VX-282 · VX-281 · VX-184 · VX-179): the OLDEST, VX-179,
rolls.
- In §14, delete the exact text from ` Before it — **VX-179 (a TICKET run, architect shape, 2026-10-12/13 overnight,` through
  `PR #154 (merge commit d6caafc1).**` (the entry's last words, bold close included), and replace the closing italic
  `*(Entries before VX-179 live verbatim in` with `*(Entries before VX-184 live verbatim in`.
- In `notes/AppSpecDeltaArchive.md`, append at the end a new section, the removed text verbatim:
  > ## Rolled at the VX-336 closeout (2026-10-15)
  >
  > Before it — **VX-179 (a TICKET run, … PR #154 (merge commit d6caafc1).**
- **If VX-283 merges first** and rolls VX-179 itself, §14 then holds VX-283 · VX-246 · VX-282 · VX-281 · VX-184 under
  this entry: roll **VX-184** instead (the same two steps, its exact text; the closing italic then names VX-281). The
  most recent MCP effort stays in §14 either way (VX-336 itself).

#### D3 — `notes/plans/run-finals-ledger.md`, the new section (newest first)

Anchor: insert after the file's intro paragraph (the one ending "…append the finals/ladder text here in the same
commit.") and its blank line, ahead of `## VX-246`:

> ## VX-336
>
> the ladder «CLOSED at round N» — Fable xhigh R1 0B/1M/2m/2n (R1-1, U9's window then pending, closed by its evidence;
> R1-2, the canon owed, landed in-branch before the merge; R1-4/R1-5 nits, no change; no code fix) → «Fable xhigh R2 …»
>
> Finals: on the tree merged with main, headless VariorumMCPTests «N/M» · core «N/M» · workbook «40/6»; Mac: the
> merge-moment WHOLE target «N tests / M suites — issues incl. known; reds named, each standing on main (VX-115; VX-167;
> VX-245/VX-283's lint sites)»; the phone suites U9 ran «120/15». Per window: U5 31 suites 251 (244 passed, 7 gated
> skips) · U6 125 suites 790 (786 passed, the 2 standing reds VX-115 and VX-167, 2 gated skips) with every red run exact
> · U7 21 suites 176 (173 passed, 3 gated) · U8 66 suites 432 (429 passed, 3 gated) with the old seed's red exact · U9
> 121 suites 771 (765 passed, 6 gated) with the Mac red (20 issues) and the phone red (5) exact and the phone green
> 120/15; every real-client leg proven from the wire's bytes.

#### D4 — the master plan (`notes/DetailedPlanForPhases.md`): retire VX-336's in-flight row ONLY

Delete the one table line beginning `| Run: MCP wire tools & AI docs | VX-336 · \`vx-336-mcp-wire-tools-ai-docs\` |`
(on `ebd16909` it is the IN-FLIGHT table's third row, after VX-305's and VX-283's). Nothing else: no "Latest closeout"
paragraph — CLAUDE.md keeps fixes and runs out of the master plan, and VX-184 (`b228e51c`), VX-281 (`3d42df78`) and
VX-246 (its PHASE A finding 2, ruled (a)) each retired their row and wrote no paragraph. The run's story lives in this
record, AppSpec §14's entry and the handoff.

#### D5 — MOBILE PARITY: a `notes/MobileSoul.md` ledger row (PL-56 unless taken)

Anchor: a new list item directly after the PL-55 row (the one beginning `- **PL-55 (VX-246, 2026-10-14 — MCP door
fixes):**`, line 259 on `ebd16909`). *(For PHASE C's eye, not ours to fix: main's MobileSoul has two rows named PL-53 —
VX-143's and VX-168's. Recorded in OWED.)*

> - **PL-56 (VX-336, 2026-10-15 — MCP wire tools & AI docs):** the MCP door is Mac-only, so every wire tool this run built
>   or reshaped (`insert_blocks`, `duplicate_note`, Compare from the wire, the `sha256` digests, paged `read_note`,
>   `list_my_activity`, the AI label form, `save_lens` by label, the minted answers, `apply_tag`'s `changed: false`), the
>   Compare landing and VX-330's Book Panel marks are Mac faces and wire, and the field guide's MCP chapter is Mac-only
>   (the phone's pocket guide carries none). **Two phone-visible changes, both through shared code:** (1) **VX-342** —
>   the phone's undo-overwrite warning (`MobileUndoDoor.discardingUndoDetail`) says "before" in lowercase, as the Mac's
>   does (`MobileUndoWarningWordsTests`, red then green on a simulator in U6's window); (2) **VX-362** — the shared
>   `OpsRefusalTable` gains nine refusal sentences, which reach the phone wherever a phone door falls through to
>   `OpsRefusalCopy.words(for:roads: .phone)` (`MobileBlockMenuController`, `MobileUndoDoor`,
>   `MobileCommentsController`, `MobileStructuralController`, `MobileMembershipModel` after its own arms, the editor's
>   status line, the shelf's and the book details' archive doors): a raw "Refused: …" dump becomes a sentence, and no
>   phone face changed (`MobileRefusalTableTests`' guard re-pointed to a still-unworded case, plus a parity test — red
>   5 issues and green 120 tests / 15 suites on a simulator in U9's window). The shared-core changes ride to the phone
>   behaviour-neutral: the minted-take records on `DocumentImport` and the copy machine, `duplicateAsVersion`'s body
>   extracted once, `importBook`'s optional name reach (nil = the full guard, her doors), `applyDocumentTags` skipping
>   a tag the note already wears (a file import's fresh note never does). **VM-20** carries the phone warning's "It is
>   saved first" where the Mac says "committed" (the commit vocabulary, R-13s-31/32).

#### D6 — RULINGS RECONCILED (her rule, 2026-10-13: each ruling re-read against what shipped, "every" / "all" / "anywhere" first)

| # | ruling (whose; its words) | what shipped | verdict |
|---|---|---|---|
| 1 | **VX-267** (hers): *"isn't it obvious it's suggested if it's claude? seems like an extra word."* | `aiLabel` → `‹client›` / `‹client› · ‹label›` at its only two call sites (`add_take`, `add_takes`); existing takes keep theirs; leg A seen in both voices | SHIPPED |
| 2 | **VX-197's split** (hers): *"it would be a mess to have claude code suggested english on every label"* — keep the split; the plan: **every** take-writing tool's description says which label rule applies | the prefix only at SUGGEST; `create_note`, `insert_blocks`, `import_document`, `duplicate_note`, `set_take_label` say "stored as given — your client name is added only by add_take and add_takes"; `add_take`/`add_takes` say the prefixed form; the other take-text writers (`edit_take`, `restore_commit`, `divide_block`, `merge_blocks`) write no label | SHIPPED |
| 3 | **VX-253** (hers + her clarification): three explicit fills, never a magic word; picks FIRST; unmatched listed; an ambiguous uncovered block refuses the whole call; exact as stored plus the client's **own** suggestions in either form, **never** another client's | all of it, pinned red-first and proven live (legs B–D) | SHIPPED (R1-4's empty-`take_ids` consistency is an OPTION in #227's P-VX253-2, not a remainder) |
| 4 | **VX-252** (her adjudication): `create_note` returns take ids + optional `section_id`; the brief: check `import_document` and close the same gap "if it is real" | `create_note` and a one-document `import_document` answer `blocks`; `section_id` files in the same call; the BOOK form keeps its ids (P-VX252-1, ∝ the whole book otherwise) | SHIPPED (the book form's shape is a provisional call in #227) |
| 5 | **VX-255** (hers): *"write new lets them add blocks at the end, edit lets them write blocks **anywhere**"* | the end at write new; at edit after ANY block (the last included) or at the start — every gap between blocks and both ends | SHIPPED ("anywhere" holds; "at the end" read as a place, P-VX255-1) |
| 6 | **VX-311** (hers): *"the duplicate note tool should be easy?"* — pre-launch | `duplicate_note` = her Duplicate as Version, one shared body | SHIPPED |
| 7 | **VX-298** (her answers 1–6, 2026-10-13): any two notes her picker would offer · related-only off when no history · up to three peers · **replace** the open columns · `link_versions`' Open › opens Compare A\|B · `duplicate_note` pre-launch | all six, proven live in both voices (L2–L5); her #226 add (*"fine for the AI to move your view if you ask it to"*) consistent | SHIPPED (the mixed-set posture is P-VX298-1) |
| 8 | **VX-330** (hers): *"combined chapter / note headings don't show **any** AI symbol … i want it fixed pre launch"* | the Book Panel's collapsed one-note chapter row wears its note's shared icon and waiting mark; all twelve sherlock rows walked in both voices | SHIPPED. Read against "any heading": the same collapse also draws in the book's own navigator (`BookView`) and the Library's info panel (`LibraryInfoPanel`), where NO row — note or chapter — wears either MCP glyph (neither file hosts one; VX-268's site list never named them), so no row there is inconsistent with its siblings; the panel's header and gatherings line → VX-354 (filed) |
| 9 | **VX-268's parity** (her one-icon ruling, VX-271): wherever the ask glyph marks a place, the shared icon marks it too — re-read under VX-330 | the ask glyph's nine hosts vs the icon's: the two without it (`CommitBar`, `TakesBottomBar` — the note ▾) were ruled OUT by VX-281's site list rows 8–9 (the in-note indicator carries it); the ⌘L ▾ menu carries a mark only (MCPSpec, ruled) | SHIPPED (no new remainder) |
| 10 | **VX-342** (her rule: no shouty caps) — lowercase it in **both** doors | the Mac and the phone; `StructuralUndoCopy` checked; the pins assert no all-caps word in either detail | SHIPPED (VM-20, the phone's "saved"/"committed", filed) |
| 11 | **VX-254** (the brief, from her bilingual-book adjudication): **"EVERY tool that writes a take's text answers it"** | eight answer (`add_take`, `add_takes`, `create_note`, one-document `import_document`, `insert_blocks`, `duplicate_note`, `edit_take`, `restore_commit`); four take-text writers answer NONE — `divide_block`, `merge_blocks` (P-VX254-1), `save_version`, the book import (P-VX254-2); and VX-357 makes "exactly as stored" untrue for U+0000 | **REMAINDER, held by a provisional:** the four are a ruled exception for her eye in #227; a ticket is proposed (OWED T1) should she want the letter; VX-357 is filed |
| 12 | **VX-256** (the brief): ids-only and/or paging "so **any** client reads a big note in pieces" | both; the bound re-ruled to the whole answer and re-probed inline | SHIPPED for the client measured (Claude Code 2.1.300); no other client's cap was measured (Codex not installed) — an evidence gap, OWED T5 (optional) |
| 13 | **VX-261** (hers): *"a read tool listing the client's own recent acts"*; the brief: answer only what the client sent or was told | `list_my_activity`; the design's "every logged id is one the client sent" was found false and closed by P-VX261-5/6 | SHIPPED |
| 14 | **The plan's docs item 1** (U8): **"every tool** VX-184, VX-246 and this run added, taught in its lesson" | lesson 3 teaches each rung's acts by family; the new tools all taught (batches, own-comment deletes, `remove_tag`, `link_versions`, `insert_blocks`, `duplicate_note`, Compare, digests, pages, recent acts); NOT named one by one: locking a take, renaming a commit, deleting a lens, naming a block, taking a note out of a book, putting back from the tray, setting a note's date, restoring a deleted comment | **REMAINDER (wording):** OWED T2 |
| 15 | **R-VX184-1** (hers): at edit the door is broadly **as capable as her at the keyboard** | this run closed the gap VX-255 named and added duplicate and Compare | **REMAINDER (pre-existing, not this run's members):** by the catalog the wire still reaches none of moving a span to a new take, renaming a tag, extract, the copy-takes-to-both divide, word targets (callouts are VX-147's, Backlog) — OWED T3, one audit ticket |
| 16 | **VX-362** (the ruled class): **no** wire answer may show a raw Swift case | all 108 `OperationError` cases worded or proven unreachable, walked by a pin; no answer starts "Refused:" | SHIPPED for `OperationError`. Read wider: the chain's last step still speaks any OTHER error raw (`String(describing:)` — e.g. a database error like the import's former "SQLite error 19") — OWED T4 |
| 17 | **R-VX184-2** (hers): Private, Seal, Own hers alone, *"though the AI should know about them so it can tell a user"* | no road writes them; the instructions' three-acts paragraph and lesson 3 | SHIPPED |
| 18 | **R-VX184-3** (hers): the bound 2,000 → 3,000, with its pin | `instructionsBound = 3_000` and its pin; MCPSpec in-branch | SHIPPED |
| 19 | **R-VX184-4** (hers): the page live before a build carrying the ONE link ships | the page live 2026-10-15 ~00:55 (200); the link the instructions' last line | SHIPPED (its copy is PLACEHOLDER for her words — her site's content-owed list, not a remainder of the gate) |
| 20 | **Her stargazing word** (2026-10-15): publish the page ourselves | built and deployed in her site repo (DECISIONS #86) | SHIPPED |
| 21 | **Her ladder-cast word**: a fresh Fable at xhigh every round | round 1 so; round 2 after this canon | IN PROGRESS (round 2 pending) |
| 22 | **Her overnight word**: merge tonight; the last merger writes notes, releases to the website and refreshes `/Applications`; a handoff for the morning | the notes section drafted (CLOSEOUT BRIEF item 9); the handoff drafted (D7) | PENDING — PHASE C's (the release and refresh only if this run merges last) |
| 23 | **Her kickoff answer 2** ("as sized", each unit with its own red-first pins, Mac batch and real-client round, U5's shared) | every unit pinned red-first and proven in its window; U6/U7/U8 split into sub-units before spawn (said in the record); U9 added by ruling 1 | SHIPPED |
| 24 | **The orchestrator's provisional rulings 1–2** (U9; VX-363) | both fixed red-first and proven in U9's window | SHIPPED (for her ratification, #227) |

#### D7 — the handoff: `notes/handoffs/vx-336-handoff.md` (in the branch, a DRAFT)

Her checklist first (the release and what to try · the re-seed through Help ▸ Restore Tutorial… · the live guide page
with its PLACEHOLDER copy, DECISIONS #86 · the #227 bundle with the five most worth her eye · the two pre-launch calls
VX-363 and VX-357 · VX-234's words · the filed tickets), then what to know (her overnight word and the calls made under
it), what shipped, how it was checked, the consolidated VX-234 list, the tickets by priority, the other runs, what is
left on disk, MOBILE PARITY, and the fresh-session pointer. **PHASE C fills every «…»:** the PR number and merge sha;
the release (version, build, who cut it — this run or VX-283 — and where its notes are); round 2's result; the closeout
window's counts; the refresh's A1 path and the replaced app, if this run refreshed; the tickets minted from OWED T1–T5;
the bundle's number if renumbered; and it deletes the italic DRAFT line under the title.

#### D8 — the STATUS lines, drafted CLOSED (flipped at PHASE C)

- **The plan's banner** (`notes/plans/mcp-pane-and-docs-kickoff.md`, line 3): replace the exact bold sentence
  `**STATUS (VX-336): STARTED 2026-10-14 at her kickoff (\`/architect-phase vx-336\`, the Pro).**` with
  > **STATUS (VX-336): CLOSED 2026-10-15 — merged as «PR #N» (merge commit «sha»); every unit this file planned
  > (U5–U8, with VX-330 and VX-342) shipped, and U9 (VX-361 · VX-362 · VX-363) joined; the record
  > `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` (its CLOSEOUT RECORD), the handoff
  > `notes/handoffs/vx-336-handoff.md`, the ratify bundle QUESTIONS #227. Nothing in this plan remains open.**

  and keep the sentences after it as they stand (the history of the file).
- **This record's STATUS** (lines 3–4): replace the exact text `**STATUS: OPEN — kicked off 2026-10-14 ~13:15 MDT` with
  `**STATUS: CLOSED 2026-10-15 — merged as «PR #N» (merge commit «sha»); the CLOSEOUT RECORD at the end names what landed
  where. Kicked off 2026-10-14 ~13:15 MDT`, and the line's last sentence `This file is the live state; read its LIVE
  STATUS first on any resume.**` with `This file was the live state while it ran.**`
- **This record's LIVE STATUS, the CLOSEOUT row:** `| CLOSEOUT | NOT-STARTED |` → `| CLOSEOUT | **DONE 2026-10-15** —
  PHASE A (the in-branch canon + the drafts, the CLOSEOUT RECORD) · PHASE B («the window's result line») · PHASE C (the
  ledgers' commits «…»; «PR #N» merged «sha»; «the release and the refresh, or VX-283's») |`, and the LADDER row gains
  round 2's result.
- **"Tickets minted from this run":** one row per ticket the orchestrator mints from OWED T1–T5, as the table's other rows.

#### D9 — PHASE C's own steps (in this order; the kits FIRST, before the PR merges)

1. **Delete the run's two kits in the branch, before the PR merges** — they must not reach main:
   `git rm -r notes/plans/fixes/vx-336-u7-kit notes/plans/fixes/vx-336-u9-sweep` (25 tracked files: the u7 kit's six
   scripts and its 17 prompts, the u9 sweep's `callgraph.py` and its JSON), its own commit ("VX-336: the closeout deletes
   the run's test kits before the merge. Part of VX-336"), pushed. Their last tree stays reachable from the merge commit's
   second parent (last touched at `e454a8ef`), which is what the record's mentions of them point at.
2. **Merge latest `origin/main` into the branch** (PHASE B did it once; again if main moved), then apply D1–D5 and D8 on
   that tree, one family per commit, VX-246's precedent: QUESTIONS (D1) · AppSpec §14 + the archive roll (D2) · the
   finals ledger (D3, with PHASE B's counts and round 2's tally) · the master plan row (D4) · MobileSoul (D5) · the STATUS
   lines (D8).
3. **Renumber if a sibling merged first:** if #227 or PL-56 is taken on main, use the next free and change it everywhere
   it appears — D1's heading, D2's entry, D8's banner, the handoff (three places) and `notes/MCPSpec.md`'s one "QUESTIONS
   #227" (grep for it). D2b's VX-283-first case decides which entry rolls.
4. **Finalize the handoff** (D7's fill list) and delete its DRAFT line.
5. **The PR** `VX-336: MCP wire tools & AI docs` (merge commit, never squash), the merge ask to the coordinator, then —
   if this run merges last — the 0.9.7 release and the `/Applications` refresh under the coordinator's rule card
   (CLOSEOUT BRIEF item 9's notes section, merged with VX-283's; see OWED 4 on one of its lines).
6. **After the merge:** delete the gitignored evidence (`notes/plans/vx336-screens/`), every `App/Variorum/DerivedData/vx336-*`
   folder (`vx336-u9` is kept until then for the ladder), the worktree and the branch (GitHub and local); the dev-store
   A1 copies are the coordinator's to prune (the handoff lists them).
7. **Linear (the orchestrator):** the members close one by one; VX-234 gets the handoff's consolidated wording list; every
   ticket this run filed is checked against the labeling rule (the "Tickets minted" table carries each one's fields;
   VX-363's and VX-357's Pre-launch are hers); OWED T1–T5 minted or declined.

### OWED (PHASE A → the orchestrator)

1. **Tickets proposed by the reconcile (D6) — the orchestrator mints, never an assignee:**
   - **T1 (D6 row 11) — the four take-text writers that answer no digest** (`divide_block`, `merge_blocks`,
     `save_version`, the book import), VX-254's "every tool" letter. Held by P-VX254-1/2 in #227: mint now in the Needs
     Lillian state (it waits on her answer), or let her answer decide. Improvement · Confirmed · MCP · Low.
   - **T2 (D6 row 14) — the field guide's MCP lesson 3 names the edit rung's remaining acts one by one** (locking a take,
     renaming a commit, deleting a lens, naming a block, taking a note out of a book, putting back from the tray, setting
     a note's date, restoring a deleted comment). Improvement · Confirmed · MCP · Low · Wording.
   - **T3 (D6 row 15) — an MCP parity audit against R-VX184-1:** the keyboard doors the wire still lacks — at least moving
     a span to a new take, renaming a tag, extract, the copy-takes-to-both divide and word targets (callouts are VX-147's).
     Improvement · Confirmed · MCP · Low; Pre-launch is hers.
   - **T4 (D6 row 16) — the wire's refusal chain still speaks a non-`OperationError` raw** (`String(describing:)`, e.g. a
     database error such as the import's former "SQLite error 19"). Improvement · Suspected · MCP · Low.
   - **T5 (D6 row 12, optional) — measure another MCP client's tool-output cap against `read_note`'s 32,000-character
     page** (only Claude Code 2.1.300 was measured; Codex isn't installed). Exploration · MCP · Low.
2. **MCPSpec's VX-246 block still reads "PROVISIONAL #226"** in four places, though #226 was ratified whole on
   2026-10-14. Not changed here (another run's canon, not this brief's); the orchestrator's call whether PHASE C writes
   "ratified #226".
3. **MobileSoul on main has two rows named PL-53** (VX-143's and VX-168's) — a numbering note, not this run's to fix.
4. **The 0.9.7 notes' sixth bullet** says "every refusal an AI can meet is in plain words" — true of every
   `OperationError` (the sweep), not of a non-operation error (T4). Suggested at PHASE C: "every refusal the door knows
   of is now in plain words" (the handoff's wording).
5. **The board snapshot** (`~/dev/variorum/notes/TICKETS.md`) predates VX-352…VX-365; the filed-ticket check (D9 step 7)
   reads Linear itself.
6. **No `swift build` was run:** PHASE A changed no source, test or package file (`git diff --name-only 93d707eb..HEAD`
   = `notes/` only); PHASE B's headless finals run on the merged tree.

### THE ORCHESTRATOR ON PHASE A (2026-10-15 ~01:35 MDT)

- **Verified:** the commits `93d707eb`…`d3f36598` are pushed and the tree is clean; MCPSpec gained the VX-336 block, the
  ≤3,000 bound and the VX-330 row, with its numbers checked against the code; AppSpec §12 is unchanged (argued).
- **D6's remainders are MINTED:** VX-366 (Needs Lillian), VX-367, VX-368, VX-369 and VX-370, all Low, none with an
  assignee. PHASE C lists them in the handoff by priority, beside the run's other filed tickets.
- **The orchestrator's two small fixes, in this commit:**
  - MCPSpec's four "PROVISIONAL #226" read "#226, ratified 2026-10-14" (she ratified #226 whole);
  - the 0.9.7 notes' "every refusal an AI can meet" reads "every refusal the door knows of" (true under VX-369).
- **Left as-is:** MobileSoul's two PL-53 rows predate this run and go on the handoff's notes, not fixed here.
- **Next:** ROUND 2, a fresh `fable-reviewer` at xhigh with REVIEW_PROMPT verbatim, over the evidence and the in-branch
  canon. Then PHASE B.
