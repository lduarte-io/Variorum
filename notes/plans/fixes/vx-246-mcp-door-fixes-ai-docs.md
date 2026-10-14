# VX-246 — Run: MCP door fixes & AI docs (the RUN record)

**STATUS: OPEN. Kickoff 2026-10-13, 21:20 MDT, by the orchestrator session variorum-84 (Opus 5.5 at max effort, her
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
- **Orchestrator:** variorum-84 (Opus 5.5, max effort).
- **Implementers:** `opus-implementer` at `effort: xhigh`, one fresh one per unit, strictly sequential.
- **The ladder:** `opus-reviewer` at `effort: max`, cold, over the whole run's diff, capped at three rounds, a fresh
  reviewer each round. Same-model flow (CLAUDE.md): the orchestrator arbitrates disputes against the spec, and the
  implementer applies the agreed fixes.
- **Fable:** a `fable-reviewer` cold review WHEN NEEDED. CLAUDE.md requires one whenever the diff touches `Sync/`,
  custody/keychain or the editor seam: here U3 (VX-275's `delete_block` half) and probably U4 (VX-230's badge). If no
  unit needs one, there is ONE Fable cold review at the end of the run anyway, her rule. A Fable review follows the
  cross-model flow: Fable makes the final call on disputes and implements its confirmed fixes itself.
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
| **U1** — the door's security and correctness | VX-258 · VX-259 · VX-260 · VX-279 · VX-280 | the setup-key rule and the admission; the wire's book-name check; comment authorship; the server host; the lens picks read | pins red-first per member, red again by revert; the MCP target green across repeated whole-target runs (VX-279); a Mac batch; a REAL-client live round on the dev store | VX-258's ask FACE is built on VX-281's tabbed pane after VX-281 merges (agreed with variorum-75, 2026-10-13). Its core goes first |
| **U2** — the undo class | VX-276 · VX-277 · VX-119 | the structural undo stack's rule (a redo after a quiet undo stays quiet), for MCP entries and her own doors alike | the round-2 probes plus one pin per family, red-first; the sweep (every registration whose redo reads current state: FIXED or provably SAFE); a Mac batch; her Edit menu walked for one family per direction | core only. No pane; no editor seam expected |
| **U3** — her editor vs the wire | VX-275 | a pre-act seam (the app's flush, then the navigate-away) before a wire write tombstones what her editor holds; `delete_block` under her caret | pins; a Mac live round: her pending keystrokes survive a wire delete, and her pane leaves the dead note | **EDITOR SEAM** (the `delete_block` half): read TEXTKIT2_NOTES first. The navigate-away road is shared with VX-283 (VX-123): one road, never a second |
| **U4** — the faces after big writes | VX-230 · VX-231 | the fan badge's placement and refresh (her evening lead on VX-230: badges of many fanned blocks drawn at the first block before layout reaches them); the Bookcase row's counts | red-first pins; a walk in both voices on the dev store with a large fanned note (U1-of-VX-184's repro and hers) | likely the **EDITOR SEAM** (the decoration layer): TEXTKIT2_NOTES first. Check VX-283's VX-122 revival signal before inventing one |
| **U5** — the write tools' shapes | VX-267 · VX-253 · VX-252 · VX-255 | `aiLabel`'s form; `save_lens` by label; `create_note`'s answer (take ids, `section_id`); `insert_blocks` | pins; a real-client live round | VX-253's matcher needs VX-267's form, so they share a unit |
| **U6** — Compare from the wire | VX-311 · VX-298 | `duplicate_note` (her Duplicate as Version); `show_in_app`'s Compare target; `link_versions`' "Open ›" opening Compare | pins; a real-client live round; the Compare board walked in both voices | — |
| **U7** — the agent's read-backs | VX-254 · VX-256 · VX-261 | write-reply digests (every take-writing tool, U5's and U6's new ones included); compact or paged `read_note`; the client's own recent acts | pins; a real-client live round | after U5 and U6, so the digests cover the new tools |
| **U8** — the AI's docs (LAST) | VX-197 | the field guide's MCP chapter; `MCPSession.instructions` (bound 3,000); the tool descriptions; the stargazing brief's delta | the truth pins (`TutorialMCPChapterTests`, the advice's caps); the chapter walked in both voices; a real client reading the instructions | starts ONLY after VX-281 merges and main is merged in. Never concurrent with VX-292, her tutorial session (`TutorialSeeder`) |
| **LADDER** | the whole run's diff | `opus-reviewer` at max, capped at three rounds (same-model flow) | — | plus a `fable-reviewer` cold review WHEN NEEDED (the editor-seam units), or once at the end if none was needed (her word at kickoff) |
| **CLOSEOUT** | — | the merge (serialized through the coordinator), canon deltas, the QUESTIONS bundle, the handoff | — | the `/Applications` refresh waits for the next release (her word, relayed by the coordinator 2026-10-13) |

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
- **VX-281's lane** belongs to variorum-75 (worktree `~/dev/variorum-vx-281`). It covers:
  - `App/Variorum/Variorum/Features/MCP/MCPPane*.swift`, `MCPPaneCopy.swift` and `MCPGrantSheet.swift`;
  - the shared-with-AI icon on the Library, Pool, Book Panel and wing-switcher rows.

  STOP and tell the orchestrator before editing any of them; the orchestrator sequences with variorum-75.
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
| U1 — the door's security and correctness | IN-PROGRESS — implementer spawned from the U1 BRIEF below |
| U2 — the undo class | NOT-STARTED |
| U3 — her editor vs the wire | NOT-STARTED |
| U4 — the faces after big writes | NOT-STARTED |
| U5 — the write tools' shapes | NOT-STARTED |
| U6 — Compare from the wire | NOT-STARTED |
| U7 — the agent's read-backs | NOT-STARTED |
| U8 — the AI's docs (LAST) | NOT-STARTED — waits for VX-281's merge |
| LADDER (`opus-reviewer` at max) | NOT-STARTED |
| FABLE review (when needed, or once at the end) | NOT-STARTED |
| CLOSEOUT | NOT-STARTED |

**No revert is in flight unless a unit's record says so.**

## Stage traffic log (the oct13coordinator protocol)

- 2026-10-13, ~21:00 MDT: the kickoff announcement went to oct13coordinator, and its protocol came back:
  - the stage runs REQUEST → READY → GO → RELEASE, with READY sent only once built;
  - merges serialize through the coordinator, asked with origin/main already merged in;
  - no real-store MCP calls and no real-app launches without her recorded word;
  - the `/Applications` refresh waits for the next release (her word);
  - the dev store is in Standard posture, unlocked and restored (vx-184's closeout).

  Zero-slot was confirmed after preflight. The coordinator's ordering call: VX-281 goes first when both runs are READY,
  unless our request is ≤10 min or gates a merge.

## Cross-run coordination

- **VX-281** (variorum-75, `~/dev/variorum-vx-281`, branch `vx-281-run-mcp-settings-pane-shared-icon`).
  - Its lane is listed under the hard rules above.
  - VX-258's ask face is built on the tabbed pane after VX-281 merges (agreed 2026-10-13). Per R-VX184-6 it is a row
    type in the Waiting section, which sits above the tabs, beside the existing grant asks.
  - variorum-75 pings the orchestrator at its merge. U8 waits on that merge.
- **VX-283** (VX-123's navigate-away road, VX-122's revival signal): U3 builds on the one navigate-away road
  (`.variorumNotesDeleted` → `WorkspaceModel.notesDeleted`). U4 checks VX-122's signal before inventing a refresh of
  its own (the runway, §2).
- **VX-282** (the editor seam: VX-290, VX-296): U3's and U4's editor-seam lines say so. Neither changes another run's
  landing or styling rules without saying so.
- **VX-292** (her tutorial session) and **VX-266** (Castle's words in the guide) also edit `TutorialSeeder`. U8 never
  runs at the same time as VX-292, and rebases onto whichever lands first.
- **VX-266** (Castle) is THE `Sync/`-custody effort. This run never touches `Sync/`, custody or the Keychain.

## Tickets minted from this run

*(none yet; any unit's mints join this table, and the closeout handoff lists them all)*

| ticket | born | what | fate |
|---|---|---|---|

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

## UNIT RECORDS

*(each written by its implementer from its first commit, under its own heading below)*

## U1 UNIT RECORD — the door's security and correctness: VX-258 · VX-259 · VX-260 · VX-279 · VX-280 (opus-implementer, from 2026-10-13 ~21:30 MDT)

**What this unit did NOT do (said first — rewritten at each checkpoint; the state at THIS commit):** nothing is built yet.
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
| 6 | VX-259 — the fix (the wire's name check counts only books the client can read; her doors keep the full guard), GREEN; red again by revert | NOT-STARTED |
| 7 | VX-260 — the pins (core: her edit clears the record; socket: a suggest delete after her edit hears her sentence), RED | NOT-STARTED |
| 8 | VX-260 — the fix, GREEN; red again by revert | NOT-STARTED |
| 9 | VX-258 — the red pins on the PRE-FIX API (the VX-168 impostor restored: a fresh MINT under a bound, approved name takes nothing; the same for a known approved UNBOUND name), RED | NOT-STARTED |
| 10 | VX-258 — SyncSpec read in full; the schema commit (v1_28, the waiting re-binds — local-only, the grants family's road) with its schema pins | NOT-STARTED |
| 11 | VX-258 — the core: the tab tag in the key, `decide`'s arms, the waiting re-bind (admitted with no reach until she allows), the ops her answer calls (allow / don't allow), Deny and the adoption tidy; the state-transition pins and the justified edits; GREEN | NOT-STARTED |
| 12 | VX-258 — red again by revert | NOT-STARTED |
| 13 | headless finals (the whole package) + the Mac `build-for-testing` | NOT-STARTED |
| 14 | STOP — VX-281's lane (VX-258's face, its Activity words, the mint call site); THE STAGE WINDOW plan; the report | NOT-STARTED |

**No revert is in flight** (VX-279's and VX-280's reverts ran and were RESTORED — `git diff HEAD` empty; every later revert is announced here first, on a committed tree).

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
   setup, now bound to its name", Claude Code 2.1.296; re-verified live in this unit's stage window on 2.1.299). Codex —
   NOT installed on the Pro (`which codex` empty, 2026-10-13); the name comes from an external lookup (the one Sonnet
   lookup agent, read-only), recorded below when it returns.

### The pins and the red counts

*(filled per piece — every count read from the log, never inferred)*

### THE STAGE WINDOW — the plan

*(PENDING — written at piece 14)*

### SELF-ASSESSMENT

*(PENDING)*

### PROVISIONALs (with their options — the orchestrator files them at the merge)

- **P-VX258-1 — a tab key under ANOTHER known approved name:** (a) as designed — it waits for her OK, as an untagged
  key does (a tag only ever adds the zero-click right for its own name); (b) refuse it (`notThisNamesKey`, the one
  sentence) — stricter, but a client whose real name differs from its tab's (a rename, a mistaken mapping) then has
  no road but the Any tab.
- **P-VX258-2 — the BIND arm (a known, approved, UNBOUND name — after an adoption, a Deny-then-approve, or a client
  approved before VX-168):** (a) as designed — an untagged (or another name's) key waits for her OK there too, the same
  hole closed the same way; a key copied for this name binds at once (R-VX168-1 unchanged for the tabs); (b) leave the
  bind arm as VX-168 built it (R-VX168-1's letter for every key) — the MAJOR's hole stays open for unbound approved
  names.
- **P-VX258-3 — the malformed-arguments residual** (above): (a) as designed — the waiting session short-circuits before
  any tool; (b) route it through every tool with a pending standing, closing the residual.
- **P-VX260-1 — her edit on another device:** (a) as designed — only her edit on THIS Mac (the record's own Mac)
  clears the record; (b) a text digest on the record (a local-only column): any change to the words, from any device
  or client, makes deleting need edit; (c) the `updated_at` compare (rejected above).

### FOR VX-234 (user-facing words, as built)

*(PENDING — none yet)*

### OWED

*(PENDING)*
