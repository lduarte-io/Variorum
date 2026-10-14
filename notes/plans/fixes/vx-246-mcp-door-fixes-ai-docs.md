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
