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
| U7 — the agent's read-backs | Builder A DONE (`54cc62a5`…`ff43e84c`): VX-254 + VX-261 built, pinned, revert-checked; MCP 304/62 (1 known issue: VX-357's U+0000 pin) · core 2,871/333 · workbook 40/6; the orchestrator re-ran the pins, 50 green. Builder B (VX-256 + the window plan) next |
| U8 — the AI's docs (LAST) | NOT-STARTED |
| LADDER | NOT-STARTED |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- *(Newest first from here.)*
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
- **VX-284**: not started.

## Her rulings during the run (verbatim; each also on its ticket)

- **VX-330 JOINS (2026-10-14 ~13:45 MDT, in chat), verbatim:** *"I want you to add VX-330 to somewhere in the run - you
  can choose where it would slot in best. It's an issue where combined chapter / note headings don't show any AI symbol
  but that's how the example sherlock holmes looks and i think people might share that book with AI as an example so i
  want it fixed pre launch."* Promoted to Pre-launch, parented under VX-336. **Slotted into U6** (the orchestrator, at
  her delegation): U6 is the first unit with app-side code and a both-voices walk with a real client connected, and it
  lands before U8, so the guide's shared-icon sentence describes the panel as fixed. Also in the plan's HER ADDITIONS
  (`d7edfea1`).

## ORCHESTRATOR'S PROVISIONAL RULINGS (her away-mode delegation, kickoff answer 4 — each for her ratification)

*(none yet)*

## Tickets minted from this run

| ticket | born | what | fate |
|---|---|---|---|
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
| 6 — THE STAGE WINDOW plan (claim `vx336-u7`), headless + Mac build-for-testing, READY | IN-PROGRESS — builder B: the headless finals, then `build-for-testing` into `vx336-u7`, then the plan (BUILDER B's RECORD) |

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
