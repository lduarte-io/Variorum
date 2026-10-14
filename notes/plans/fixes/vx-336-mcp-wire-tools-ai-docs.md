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
- **Tickets this run FILES are triaged before it closes** (her word 2026-10-14, now CLAUDE.md's closeout ritual): a kind
  label (Bug / Improvement / Feature / Debt), exactly one Evidence label (Confirmed · Suspected · Test-only), a Priority
  (Linear's field), Pre-launch if it gates launch, Wording for text-only fixes, and "Needs Lillian" if it waits on her.
  A unit that mints a ticket proposes those fields in its record's OWED.

## LIVE STATUS (orchestrator — flipped as units land)

| unit | status |
|---|---|
| U5a — the label pair | **BUILT, headless green at `590c0cb8`** (U5a UNIT RECORD): VX-267 and VX-253 fixed, each pin red on old and red again by revert; MCP 251/54 · core 2,860/330 · workbook 40/6 (the orchestrator re-ran the seven pin suites: 35 tests green). No app file moved. Its acceptance closes in U5b's window (LIVE LEGS A–C, D optional). Implementer retired (~437k) |
| U5b — the block-writing pair | **DESIGNED, FORKS RULED** (U5b UNIT RECORD piece 0 `9b05e442`; THE ORCHESTRATOR'S RULINGS ON U5b's FORKS below). Pieces 1–8 go to a FRESH implementer (the designer's context was ~468k at its stop) |
| U6 — Compare from the wire (+ VX-342) | NOT-STARTED |
| U7 — the agent's read-backs | NOT-STARTED |
| U8 — the AI's docs (LAST) | NOT-STARTED |
| LADDER | NOT-STARTED |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- *(Newest first from here.)*
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

**What this unit has NOT done (said first; updated at every piece):** (1) **the build is in progress** — pieces 1–8
are a CONTINUATION's (below); each LIVE STATUS row says what landed; (2) no stage window, no Mac build, no live round yet
(THE STAGE WINDOW is written at READY, after the build); (3) the guide and `MCPSession.instructions` untouched (U8's — the
doc-truth sweep below finds nothing false); (4) no `notes/QUESTIONS.md` entry and no canon edit (the merge's). Everything
below "The design" is the ruled plan; a claim is only what a LIVE STATUS row says DONE with its log.

**THE CONTINUATION (pieces 1–8): a FRESH opus-implementer (xhigh), from 2026-10-14 ~14:45 MDT,** built from this record,
the U5b BRIEF and THE ORCHESTRATOR'S RULINGS ON U5b's FORKS alone (the designer retired at ~468k after piece 0). It re-read
the cited code before relying on any line: the design's pointers hold (`perform`'s `createNote` arm 404–415, `noteAnswer`
757–766, `mintDocument` 213–248 keeping only `minted.block.id` at 237, the parse's silence on `section_id` 202–214).

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
| 3 | VX-252 — red again BY REVERT (announced first, committed tree, restored, verified) | **ANNOUNCED (this commit) — the revert runs on THIS committed tree:** the five fix files (`Operations+DocumentImport.swift`, `Operations+MCPWrites.swift`, `MCPWriteTools.swift`, `MCPToolCatalog.swift` back to the pins commit `3ccfaa12`; `MCPMintedBlocks.swift` removed) and the new-API file `MCPMintedBlocksActsTests.swift` moved aside to `notes/plans/vx336-screens/u5b/prerevert-252/` (gitignored, inside the worktree); expected the piece-1 test × line set; then `git checkout HEAD -- Sources/ Tests/`, the aside folder removed, `git status` clean |
| 4 | VX-255 — the pins on the OLD tree (wire: end at write new, anchor/start refused at write new with the rungTooLow family, anywhere at edit, one undo walks it back whole and redo returns it, a sealed note refuses, anchor of another note refused alike, the fence), RED by absence | NOT-STARTED |
| 5 | VX-255 — the fix (the act, the wire, the catalog, `MCPWriteAct.blocks`, the app's words) + justified edits (the catalog set, the suggest proof), GREEN | NOT-STARTED |
| 6 | VX-255 — red again BY REVERT | NOT-STARTED |
| 7 | headless finals (MCP · core · workbook) + the Mac `build-for-testing` (`DerivedData/vx336-u5`) | NOT-STARTED |
| 8 | THE STAGE WINDOW plan (claim `vx336-u5`; Mac batch; the live round incl. U5a's LEGS A–C, D optional; A1 + restore; fingerprint) → READY | NOT-STARTED |

**No revert is in flight.**

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

*(Pending the ruling: whichever of F-1…F-6 the orchestrator rules "provisional" lands here as P-VX252-n / P-VX255-n with
its options as above.)*

### FOR VX-234 (user-facing words, as built)

*(Pending the build: the Activity line for `insert_blocks` (allowed and refused), its receipt phrase, and its undo
label "‹client›'s blocks".)*

### OWED (for the orchestrator)

1. **The ruling on F-1…F-6** (and the D1 shape) before pieces 1–6.
2. *(Recorded, not proposed for this run:)* `import_document` could take a `section_id` too (one document into a
   chapter) — not asked by VX-252; a client files it with `file_note_in_chapter` after. A ticket only if the orchestrator
   wants one.

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

