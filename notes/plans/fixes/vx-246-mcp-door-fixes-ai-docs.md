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
| U1b — VX-258's face and U1's remainder | WAITS for VX-281's merge, then a FRESH implementer: the face incl. the mint call site (**THE MERGE GATE** — U1's core must not merge or reach her build without it), VX-318 (OWED 3), P-VX260-1 rebuilt as option (b), the live round (U1's legs 0–5), and U2's MCP walk legs W2/W3 (no detour needed once the face exists). Note for W2/W3: on an empty redo stack the Redo item is DISABLED (`EditorCommands.swift:576`, unchanged), so "nothing to redo" reads as a disabled item, never a toast (U2 STAGE RUN's finding 1) |
| U2 — the undo class | **WINDOW 1 PROVEN 2026-10-14 00:23–00:38** (U2 STAGE RUN below): the Mac batch 1,084 tests / 148 suites green (1,078 + 6 gated skips, 0 failed — U1's G1–G3 included), W1 proven in both voices, the dev store restored cmp-SAME. Open only for W2/W3 in U1b's window. — Earlier: BUILT, headless green at `10223a2d` (MCP 223/48 · core 2,826/326 · workbook 40/6; the Mac build-for-testing built). The implementer is retired at ~634–690k context (the cutover rule). Its stage window (the Mac batch with U1's groups, plus W1, her own door) goes to a FRESH runner; W2/W3 move to U1b's window. The acceptance closes when W1–W3 have run |
| U3 — her editor vs the wire | IN-PROGRESS — implementer spawned from the U3 BRIEF below (2026-10-14 ~00:50) |
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
- **P-VX258-2 (U1's bind arm) RATIFIED, 2026-10-13 ~23:35 MDT, in chat.** The orchestrator told her what was built:
  an approved client name with no key tied to it yet (after opening a library from another Mac, or after a deny and
  a re-approve) accepts a key copied from that client's own setup tab with no clicks; any other new key waits for her
  OK. Her answer: *"i ratify what you built"*. It covers only that call; P-VX260-1's option (b) isn't built yet and
  stays provisional. On VX-258 as a comment.

## Tickets minted from this run

*(any unit's mints join this table, and the closeout handoff lists them all)*

| ticket | born | what | fate |
|---|---|---|---|
| VX-318 | U1's OWED 3 (the implementer, 2026-10-13) | MCP socket: a session's reader thread can read another socket's bytes after the host closes its descriptor. Same fd-reuse class as VX-279; traced by reading | a member (sub-issue of VX-246, Pre-launch); built in U1b with a red-first pin |
| VM-16 | U2's OWED 2 (the implementer, 2026-10-14) | The phone's undo door says "Undid: …" on a quiet press: `MobileUndoDoor` still calls `undo(with:)`/`redo(with:)`. The fix is the Mac door's two lines; the rule itself already reaches the phone | the VM board (Mobile — editor & capture faces, Backlog); it needs a simulator stage; related to VX-276 |

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
     from its stderr); the caret clicked to the end of "Three."; then IN ONE Bash call `keys.sh <pid> type " pending words"`
     immediately followed by `touch <scratch>/go-e` → the driver's answer (`isError` false, `ms_after_trigger`) → capture:
     the block gone, the caret at the END of "Two." (no block below — the block above's end). This Note's Tray ▸ Leaving ▸
     "Three. pending words" ▸ Put back → **"Three. pending words"** on the page (capture) — her keystrokes, typed
     milliseconds before the delete, survived it.
   - **delete_note while she types:** a fresh note **"vx275 f"** ("Fresh line." ⏎) open in Write, the driver armed for
     `delete_note "vx275 f"`; type " pending words" + touch the trigger in one call → the pane leaves the note (capture) →
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
  the timing it exposes is "something was pending somewhere", never which note.
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
