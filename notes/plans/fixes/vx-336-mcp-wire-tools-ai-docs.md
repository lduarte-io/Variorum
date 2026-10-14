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

**Members (11, sub-issues of VX-336):** VX-267 · VX-253 · VX-252 · VX-255 · VX-311 · VX-298 · VX-254 · VX-256 · VX-261 ·
VX-197 · VX-342. All pre-launch except VX-342 (a one-word copy fix she added: *"if it's a tiny wording issue you can add
it to the 336 run i suppose."*).

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
| **U6** — Compare from the wire (+ VX-342) | VX-311 · VX-298 · VX-342 | `duplicate_note`; `show_in_app`'s Compare target; `link_versions`' Open › opening Compare; the undo warning's one word (Mac + phone) | red-first pins; a Mac batch; a real-client live round; the Compare board walked in BOTH voices |
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

## LIVE STATUS (orchestrator — flipped as units land)

| unit | status |
|---|---|
| U5a — the label pair | NOT-STARTED — the next spawn (U5a BRIEF below) |
| U5b — the block-writing pair | NOT-STARTED |
| U6 — Compare from the wire (+ VX-342) | NOT-STARTED |
| U7 — the agent's read-backs | NOT-STARTED |
| U8 — the AI's docs (LAST) | NOT-STARTED |
| LADDER | NOT-STARTED |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- *(Newest first from here.)*
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
- **VX-283 / VX-284**: not started. VX-283 shares the navigate-away road (`.variorumNotesDeleted`); this run adds no
  second road.

## Her rulings during the run (verbatim; each also on its ticket)

*(none yet beyond the kickoff answers above)*

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
   - Name the answer shape once (a shared encoder) so `insert_blocks` (below) and U6's `duplicate_note` reuse it.
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

**Lanes.** Compare's board is no other run's surface. If a trace reaches the editor seam (vx-282's merged files are
main's now, but the seam rule stands): STOP and report.

**Evidence that closes U6.** Pins red-first per member, red again by revert; headless green with counts; THE STAGE
WINDOW plan (claim `vx336-u6`; minutes; a batch-only fallback): a Mac batch over every changed source file's suites; a
REAL-client live round on the dev store — `claude -p` turns: `duplicate_note` an existing note, edit the copy,
`show_in_app` with a Compare target naming the pair (rows line up), then an unrelated pair (opens with "related blocks
only" off), and `link_versions`' Open ›; **the Compare board walked in BOTH voices** with captures (`show_in_app` moves
only while Variorum is frontmost, so the walk keeps it in front); the undo warning's new word seen once (Mac).

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
