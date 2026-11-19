# VX-981 — Umbrella: MCP door fixes & follow-ups

**STATUS: OPEN (kicked off 2026-11-19). Orchestrator session `vx-981`; /run-phase overnight; nov18 coordinating the stage. Branch `vx-981-mcp-door-followups`, worktree `~/dev/variorum-vx-981`, the Pro. PR at close: `VX-981: …`, merge commit only.**

Ticket: VX-981 · Project: none (an umbrella over MCP-area tickets) · Branch: `vx-981-mcp-door-followups`

## FOR A LATER READER

*(Written at closeout, from the settled facts. Until then the run is live: read LIVE STATUS and THE LEDGER.)*

---

## LIVE STATUS (flipped in the same commit as each piece; a fresh session with only the repo can finish the run from here)

| Piece | State |
|---|---|
| Kickoff: roster, worktree, in-flight row (`bc8f3d03a` on main), this record | DONE |
| BATCH 1 — the Journal shows as Private (VX-1007) | IN-PROGRESS — implementer live; its LIVE STATUS is the BATCH 1 RECORD below |
| BATCH 2 — the wire's ruled small fixes (VX-977 · VX-979 · VX-961) | NOT-STARTED |
| BATCH 3 — announces in order, never waiting on a stall (VX-951 · VX-944) | NOT-STARTED |
| BATCH 4 — the socket's edges (VX-959 · VX-952 · VX-963) | NOT-STARTED |
| BATCH 5 — the parity audit (VX-368); the output-cap measurement (VX-370) HELD | NOT-STARTED |
| Gates (Mac suites under a stage claim), the closing walk | NOT-STARTED |
| The ladder (cold review of the whole diff, up to three rounds) | NOT-STARTED |
| Closeout: canon deltas, QUESTIONS bundle, handoff, PR, merge through nov18 | NOT-STARTED |

No revert is in flight.

## Kickoff (2026-11-19)

**Her words (2026-11-19), verbatim:** "i want to get everything set up for an overnight session" · "i want one claude coordinator named nov18, then i want all the VM in the first wave launched with instructions to talk to stage coordinator nov18, i want the vx-981 and vx-980 added too. and add the high priority (private eye not shown on journal) to one of those runs - maybe the MCP run, since it deals with the private mark."

- **Members — the SUB-ISSUE roster, listed through Linear at kickoff (eleven; the description names ten, VX-1007 was seated 2026-11-19 at her word):**
  VX-1007 (High, Bug) · VX-951 (Medium, Bug) · VX-977 (Medium, Improvement) · VX-961 (Low, Bug) · VX-959 (Low, Bug, Suspected) · VX-979 (Low, Improvement, Wording) · VX-963 (Low, Bug, Suspected; was Parked) · VX-944 (Low, Bug; was Parked) · VX-952 (Low, Improvement; was Parked) · VX-368 (Low, Improvement) · VX-370 (Low, Exploration).
- **Cast:** `opus-implementer` (xhigh), FRESH per batch, one at a time; Fable orchestrates and adjudicates; the ladder's cold reviewer is `fable-reviewer`, a fresh one per round — the standing default, kept because the diff carries the door's connection lifecycle (wire order, the socket's writer and path) and the faces of the AI fence. Cross-model flow: the reviewer makes the final call on every finding, the implementer applies the confirmed fixes.
- **No `Sync/`, no custody, no editor seam, no schema.** Any batch line that would reach `Sources/VariorumCore/Sync/`, custody/keychain code, `EditorTextView`/`BlockRangeIndex`/`PaneSurface`/the read tier, or a migration STOPS the batch back to the orchestrator. No write of `ai_private_at`, `sealed_at` or `owned` from any new road (R-VX184-2).
- **Overlap (the in-flight table at kickoff):** VM-55 holds `Shared/AppSession.swift` (the status seam) and `Shared/OpsRefusalTable.swift`; VM-78 hoists book-state words into `Shared/`; VM-47 holds the phone's type layer. This run's candidates for a shared file are the status seam (VX-961's failure line) and the refusal table — a batch that must edit a file under `App/Variorum/Shared/` says so in its record at once, and the orchestrator tells nov18 (a `Shared/` line adds the phone suites to the merge gate). VX-980 (search) runs beside this run; no shared surface expected.
- **Stage protocol (nov18):** REQUEST early (what, window length, claim name) → READY → GO only from nov18 with the exact claim line (a free stage is never an invitation) → RELEASE with one result line naming every failing test by name plus the Executed counts. Headless `swift build` / `swift test` and `xcodebuild build` / `build-for-testing` never need the stage; EVERY `xcodebuild test`, simulator boot, walk, Debug launch or device install does. Merges serialize through nov18.
- **Away-run rule:** an ask that needs her hands is HELD and bundled for her next sitting while everything that does not depend on it continues.
- **Riders (CLAUDE.md's rule — offered, held for her, none taken without her word):** the open Low/Medium MCP-area tickets outside the roster: VX-131 (once grants time out when left unspent) · VX-133 (the coalesced receipt count includes acts since undone) · VX-705 (move-at-once adopts its target with no liveness check) · VX-930 (record the setup tab at key-bind) · VX-875 (a setting for the AI activity feed) · VX-773 (the release test split's DEBUG-only hooks).
- **Held at kickoff — VX-370:** no second MCP client is installed on the Pro (`codex` and `gemini` are not on the path), and installing or signing in to one is her hands. The measurement cannot run tonight; the ticket is re-owned at closeout with that reason.

**Preflight read at kickoff (none delegated):** CLAUDE.md and its auto-loaded canon (CoreDescription, OverallModel, AppSpec) · `notes/MCPSpec.md` IN FULL · `notes/SurfaceContracts.md` — The app (the AI section, the status seam), The Bookcase and books (the Bookcase, the book settings sheet, the badge family, the Private mark), Doors (the MCP door) · the master plan's head, in-flight table and latest closeout · `notes/plans/workflow-transition-2026-10-06.md` · `notes/TICKETS.md` (the non-mobile board; every open MCP-area row) · `notes/QUESTIONS.md` — the entries this run's members cite (#270 and its addenda 2–3, #271, #273 and its addenda), not the file whole · `notes/SessionResiliencyProtocol.md` · `notes/REVIEW_PROMPT.md` · every member ticket in full · the fence's legs (`Sources/VariorumCore/Queries/MCPGrantQueries.swift`, "THE FENCE's legs") and `Queries/PrivateMarkQueries.swift`. Not triggered: SyncSpec, TEXTKIT2_NOTES, CastleRules (a line reaching their seams stops the batch).

## ENVIRONMENT & TRAPS (every batch brief carries this section verbatim)

- Work ONLY in `~/dev/variorum-vx-981` (absolute paths in every command). Never commit from the main checkout; never push `main`.
- Commit per coherent piece, push after every commit; write your batch's LIVE STATUS lines from the first commit and flip them in the same commit as each piece; synchronous foreground waits only (poll with a `grep -q '<EXIT LINE>' <log> && break; sleep 5` loop — `tail -f | grep -m1` hangs after the line lands). `notes/SessionResiliencyProtocol.md` binds. Before a behavioural revert: commit first, name the revert in your record, and restore by `git checkout <fix-commit> -- <file>` followed by an explicit commit check (`git status` clean, `git diff HEAD` empty).
- The orchestrator shares this worktree: it writes nothing here while you are live. If files move under you that you did not change, write nothing, report, stop.
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing` (TYPE names, as a zsh array — a file name drops silently and "Executed 0" is no verdict); confirm the "Test run with N tests" line; Swift Testing's N COUNTS SKIPPED tests — read the `skipped:` lines. `build-for-testing` compiles without the runner and needs no stage. NEVER add a custom build configuration.
- **EVERY `xcodebuild test` run, simulator boot, Debug launch and anything touching the screen or a shared store needs a HELD stage claim, granted through the orchestrator (nov18 coordinates).** You do not claim the stage yourself: end your batch at READY, naming your gate's test TYPES and any red-on-old leg that needs the app target. Headless `swift build` / `swift test` runs freely — but other sessions build on this Mac tonight, so a timing-sensitive socket test that reds under load is re-run ALONE before it is called red or green.
- zsh `pipestatus` (not bash's PIPESTATUS). Screenshots only in gitignored dirs. Never `git checkout` over uncommitted work. No `git add -A` — pathspec adds and pathspec commits only.
- The REAL store and `/Applications/Variorum.app` are never touched. The walk app is the DEV-STORE Debug build only (`io.lduarte.Variorum.debug`).
- **The repo is PUBLIC:** every commit message and note is public copy. No names, emails, account ids or private paths beyond what the repo already carries; identifiers keep the placeholder vocabulary.
- Commits carry NO attribution trailer. Member work says `Part of VX-<member>` in its commit message, stating the traced mechanism and the pin.
- Rendered app text is sentence case; never capitalize a word for emphasis. Every new or changed sentence the app or the wire speaks is listed in your batch record under AUTHORED SENTENCES, for her pass.
- **The hallucination guard:** no fix without a mechanism you traced yourself; every bug-class fix lands with a pin that is red on the old code, verified by revert; a pin green on both sides means the finding is hollow — record it and do not fix it. An Improvement member pins the NEW contract.
- Ambiguity that does not gate your batch's core: write 2–3 options into your batch record, build the most spec-defensible, mark it PROVISIONAL with an id `P-981-B<batch>-<n>`. Ambiguity that gates the core: stop and report. QUESTIONS.md is a shared ledger touched only at the merge — PROVISIONALs live in your batch record until then.

## THE BATCHES (one acceptance unit each; a FRESH `opus-implementer` per batch; each brief names THESE sections plus the reading listed — never the orchestrator's context)

Every batch writes its record under its own heading at the END of this file's batch section (`### BATCH N — RECORD`): LIVE STATUS lines, the traced mechanism per member, what was built (one pointer per piece), pins with their red-on-old evidence, PROVISIONALs with options, AUTHORED SENTENCES, CANON LINES EARNED (drafted contract lines for MCPSpec / SurfaceContracts / AppSpec with the place each belongs — drafted here, applied to canon only at closeout), GATE TYPES (the app-target test types its change is exercised by — grep the tests for every changed source type, not only changed test files), and a self-assessment.

### BATCH 1 — the daily Journal shows as Private (VX-1007, High)

**Reading:** this file's Kickoff and ENVIRONMENT & TRAPS · the VX-1007 ticket text below · `notes/MCPSpec.md` IN FULL · `notes/SurfaceContracts.md` → The Bookcase and books (the book settings sheet, the badge family, the Private mark) and Doors (the MCP door) · `Sources/VariorumCore/Queries/MCPGrantQueries.swift` ("THE FENCE's legs") · `Sources/VariorumCore/Queries/PrivateMarkQueries.swift` · `App/Variorum/Variorum/Core/Views/PrivateMarkView.swift` and every host that reads `privateMarksDrawn` / `privateBookMarksDrawn` · the Private rows (the book settings sheet; the note's ▾ menu) · the VX-831 / VX-878 / VX-900 / VX-934 records where a rule's reason is needed.

**Her report (2026-11-18), verbatim:** "the journal does not wear the private eye icon & it doesn't show with "private" ticked in its book settings."

**Her ruling (2026-11-18), verbatim:** "I honestly think it always being private is good. I don't want to change it for now. It should just show as ticked and locked in the immediate sense also."

**The mechanism as filed (traced on the ticket, not yet pinned — trace it yourself):** the fence has three legs in one derivation site — (1) a note's own `profile = 'journal'`, (2) a live member of a live reading wearing the `'daily'` marker, (3) the Private mark, own or through a live Private book. The eye and both Private rows read leg 3 only (`ai_private_at`), so everything fenced by legs 1–2 reads as not private.

**The contract (faces only — the fence does not change):**
1. The daily Journal — every live reading wearing the `'daily'` marker, archived included — wears the Private eye on every book-row host the eye draws on today. A book's own masthead stays eyeless (VX-900).
2. A note fenced by a Journal leg wears the eye on every note host the eye draws on today (note rows, the note's masthead bar, the Book Panel).
3. Book Settings' Private row on the daily Journal shows ticked and locked: it cannot be unticked, and one line says why.
4. The gates are unchanged: the approved-client gate (R-878-K3), the `ai_marks` switch (VX-934), the server-off dimming (VX-900), and the row's own when-it-appears rule (VX-641). Cost stays ∝ the rows drawn (P1): every new statement is driven by the drawn ids and plan-pinned as `PrivateMarkFactsTests` pins today's.
5. **ONE derivation.** The faces' Journal facts come from the fence's own leg definitions (shared fragments, one site), never a second spelling. A parity pin proves it over a matrix of notes and books: the face says Private exactly where `mcpNoteFacts` says fenced, leg by leg.
6. **No write.** Nothing stamps `ai_private_at` on the Journal or its entries — not a migration, not a launch pass, not a repair. The row's locked state is derived at read. `setBookPrivate` / `setNotePrivate` on a Journal-fenced thing: read what they do today and keep their store behavior; if a door could still write a mark that the locked row now hides, close the DOOR (the row is locked), not the operation.

**Open edges — build the most spec-defensible, mark PROVISIONAL, list the options:**
- The eye is a door: an OWN mark un-privates on click, a via-book mark speaks "Private — via ‹book›" with one door, "Open ‹book›". A Journal entry that is a member of the daily Journal fits the via-book form naming the Journal. The Journal's own row, and a `profile = 'journal'` note outside the Journal, have no un-private road: their mark speaks a saying and un-privates nothing. The hover and the saying are new sentences.
- The note's ▾ menu Private row on a Journal-fenced note: her words name the book's row. An unticked row beside a drawn eye is the contradiction she reported, so the consistent reading is ticked and locked there too — PROVISIONAL.
- A note carrying BOTH its own Private mark and a Journal leg: un-privating its own mark leaves it fenced. The row must not lie in either direction.
- The why-line's wording. Draft it plain (the pane's open-book line already says "your daily Journal and anything Private still ask every time").

**Pins (bug-class — red on old, verified by revert):** core — the Journal's book mark, each Journal leg's note mark, the archived Journal, a stale second `'daily'` bearer, a journal-TRAIT book (`profile = 'journal'`, NOT fenced since VX-163) wearing no mark, the gate closed reading nothing past the grants store, the parity pin, the query plans. App target — the row's ticked-and-locked state on the Journal and its plain state on an ordinary book, the door's behavior per mark kind.

**Evidence of kind:** the core pins headless; the app-target types at the gate; a WALK on the dev-store Debug app at the closing walk (the Bookcase row, the Journal's book settings, a day entry's eye in the Library, the Book Panel and the masthead, the server-off dimming, both voices) — write the walk's script lines into your record so the orchestrator's window can run them.

**Mobile:** `VM-209` (the eye on the phone) is open and will read the same core facts. Do not build phone faces; say in your record what the phone inherits.

**Stop conditions:** any need to change `mcpNoteFacts`' answers, the grant rule, or a write road; any `Sync/`, schema or editor-seam line.

### BATCH 2 — the wire's ruled small fixes (VX-977 · VX-979 · VX-961)

**Reading:** Kickoff and ENVIRONMENT & TRAPS · `notes/MCPSpec.md` IN FULL · SurfaceContracts → The app (the status seam) and Doors (the MCP door) · `notes/plans/fixes/vx-915-recents-sweep.md` → FOR A LATER READER, BATCH 6 (the wire's unlink) and P-915-L2-1 · `notes/plans/fixes/vx-913-freeze-fixes.md` → FOR A LATER READER and ledger 3 (the landed-then-log split, the door road, P-913-B3-*) · QUESTIONS #271, #273 and #273's two addenda.

**VX-977 — `unlink_versions` at the EDIT rung on both notes.** Her words (2026-11-10): "i imagine with edit to both, they should also be able to unlink something a user made. I don't think AI links are stored differently." — and her dialog pick: Edit rung, post-1.4. No authorship fence (a `version_of` edge carries no author). A permission tightening: a write-new-only client loses unlink until granted edit, hearing the rung-too-low family with her ask raised, exactly as the door's other past-its-rung arms speak. Everything else stands as built (both ends readable before anything is said; the saved-version refusal; the already-gone answer; `still_versions`; one client-named undo with the quiet retire). `link_versions` stays at write new. The same commit carries every place the rung is SAID: the tool's description and catalog rung, `MCPSession.instructions` if it names the rung (≤ 3,100 characters, truth-pinned), the field guide's MCP chapter (lesson 3's cards name each rung's acts one by one — unlink moves to the Edit card), and the drafted MCPSpec line. Pin, red on old: a write-new-only client unlinks today and refuses after; edit on one side only refuses; edit on both lands; the two-store catalog (R-825) still holds for every arm.

**VX-979 — the title-free receipt arm.** Her words (2026-11-10): "A title free arm might be nice in the longrun, so it could be ticketed." When the two titles overflow the status bar's budget, the unlink receipt says "unlinked two notes as versions" in place of the generic "made a change" fallback (the wing-move receipt's precedent), and `link_versions` gains its twin. The unlink words are hers by the ticket; the link twin's words are yours to draft as the plain mirror — PROVISIONAL. Pins at the boundary: the longest pair that still fits keeps its titled form byte for byte; one character more takes the title-free arm; the generic fallback is no longer reachable from this pair.

**VX-961 — `show_in_app` when only its Activity line fails.** The ruled split, already built for the write family (VX-775): "the error goes to her, the truth goes to the client." Confirmed present on `show_in_app`'s own road: the act lands, the Activity write throws, the client hears an error. Fix through the VX-913 door road: the client gets the act's own answer byte for byte; she gets one refusal-kind line on the status seam naming the client and the store's words; `list_my_activity` simply lacks the row. Every arm of `show_in_app` that logs is covered (the ask, the move, her take is not the client's act). Pin, red on old, per arm.

**Evidence of kind:** state-transition and wire tests headless; the app-target types at the gate; one live wire round at the closing walk (a write-new-only client refused at unlink with the ask raised; an edit client's unlink landing with the title-free receipt on two long-titled notes) — write its script lines into your record.

**Stop conditions:** any change to who may unlink beyond the rung; any new refusal sentence not derivable from an existing family (draft it PROVISIONAL instead); a `Shared/` edit is allowed but must be named in your record at once.

### BATCH 3 — announces in order, never waiting on a stall (VX-951 · VX-944)

**Reading:** Kickoff and ENVIRONMENT & TRAPS · `notes/MCPSpec.md` IN FULL · `notes/plans/fixes/vx-940-pre-oss-followups.md` → FOR A LATER READER, W4 whole (F-W4-1, the P5b fast road, the soak), "The ladder" (F-R1-2's disposition) · `notes/plans/fixes/vx-940-ladder-round1.md` → F-R1-2 · QUESTIONS #270 addendum 2 · `Sources/VariorumMCP/MCPSession.swift`, `MCPServerHost.swift`, `MCPSocketTransport.swift`, `App/Variorum/Variorum/Features/MCP/MCPDoor.swift` (`resumeSuspended`).

**VX-951 — `tools/list_changed` never ahead of a connection's `initialize`.** Mechanism as filed: `announceToolsChanged` gates only on `declaredName != nil`, and the name is set in the SDK's `initialize` hook before the result is sent, so the grants observation can put `notifications/tools/list_changed` on a connection's wire before its `initialize` result. It is the recorded cause of `MCPSetupKeyServerTests.twoToolsUnderOneNameAreToldApart`'s load flake. Her ruling (2026-11-10, #270 addendum 2) settled WHEN (after the public flip — now) and left the SHAPE to this run's kickoff memo:

> **THE SHAPE MEMO (the orchestrator's, PROVISIONAL P-981-B3-1 — hers to flip).** MCP's lifecycle has the server send nothing but pings and logging before the client's `notifications/initialized` (confirm the sentence in the protocol's own text with your one lookup, and quote it in your record).
> - **(a) Gate on the `initialize` result having been written.** The smallest change; it closes the recorded flake. A `list_changed` can still precede the client's `notifications/initialized`, which the lifecycle also rules out.
> - **(b) Gate on the client's `notifications/initialized`, then one catch-up.** While the gate is closed an announce is remembered, never sent; when the gate opens, exactly ONE `list_changed` goes out if any was held, none otherwise. The sitting's recorded lean.
> - **(b′) (b), and a client's first post-`initialize` request also opens the gate.** A client that never sends `notifications/initialized` but calls `tools/list` or a tool has plainly finished initializing; without this arm such a client would never hear an announce again, and VX-258's "her Allow … serves the same connection at once (the tool list re-announced)" would silently break for it.
> **Build (b′).** It is the lifecycle's letter, it cannot strand a lax client, and it sends nothing a conforming client did not agree to hear. If the SDK already treats a first request as initialized, say so and (b) is (b′).

The contract the fix must keep, each with a pin or a named existing pin: VX-258's Allow re-announce on the SAME connection; VX-818's held connection (answered `initialize` during a lock, names no one, admitted at the unlock, resumed with its announce); the grants observation reaching every live session that is past its gate; VX-605's naming signals; `trail_dial` changes announcing nothing. Pin, red on old, deterministic (a test hook that holds the result or forces the grant change inside the window — no sleeps as the mechanism): the first frame a connection reads is its `initialize` result, and no `list_changed` precedes the gate's opening. Then the soak: `twoToolsUnderOneNameAreToldApart` run repeatedly ALONE and under a parallel core run, counts recorded.

**VX-944 — one stalled client never delays another's announce.** Mechanism as filed: `MCPServerHost`'s two announce loops run `for session in live { await session.announceToolsChanged() }`, and a send to a stalled connection waits on that connection's writer, so one client that stopped reading delays every LATER session's `list_changed`; `MCPDoor.resumeSuspended` awaits `resume(executor:)`, so the same stall keeps `resuming` true and the pane's state, `refreshConnected` and `reconcileServer` never run until the client reads. Fix shapes recorded on the ticket: announce per session without awaiting in series (per-connection order is the connection's own serial writer's); keep `resume` off the announces. Pin shape recorded: two sessions, A stalled with a large answer pending, B reading — a grant change reaches B within the bound (red on the old tree); a second pin for the unlock road — `resuming` falls and the pane's refresh runs while A is still stalled. The ticket's two riders ride this touch: (1) assert the mark's restore on `sayClosing`'s DROP path too; (2) route the never-waits pin through the `sayClosingBounded` helper it duplicates.

**Evidence of kind:** drills — real sockets, headless; the soak counts; the app-target types for `MCPDoor` at the gate.

**Stop conditions:** any change to WHAT is announced or to the fingerprint; any wire byte other than the ORDER and the held-then-one catch-up; a deadline that would close a slow-but-alive client's connection (not ruled — draft it as an option, do not build it).

### BATCH 4 — the socket's edges (VX-959 · VX-952 · VX-963)

**Reading:** Kickoff and ENVIRONMENT & TRAPS · `notes/MCPSpec.md` IN FULL · `notes/plans/fixes/vx-913-freeze-fixes.md` → FOR A LATER READER, ledger 7 and the ladder's F2 · `notes/plans/fixes/vx-913-ladder-round1.md` → the two C probes (stat-after-bind vs fstat) · `notes/plans/fixes/vx-940-pre-oss-followups.md` → FOR A LATER READER and W4 (VX-933's writer, F-W4-2, F-W4-3) · `notes/plans/fixes/vx-926-test-flakes.md` → FOR A LATER READER and U1 (F-U1-2) · `notes/plans/fixes/vx-180-discover-probe.md` (the opening window's contract) · `Sources/VariorumMCPSocket/`, `Sources/VariorumMCP/MCPSocketTransport.swift`, `MCPServerHost.swift`, `Tests/VariorumMCPTests/MCPStalledReaderPoolTests.swift`.

**VX-963 — investigate FIRST.** Filed from a stall sample the same day VX-933 landed ("no write the door makes waits on the app's cooperative pool — a frame a client does not read waits on its connection's own serial writer"). Establish from the code and `MCPStalledReaderPoolTests` whether any door write still blocks a cooperative-pool thread today (the SDK's response path included). If none does: DISMISS AS ALREADY FIXED — name the commit and the guard pin, add a guard for any path the existing pin does not cover, change no product line. If one does: trace it, pin it red, fix it on the transport's own thread (the ticket's first shape; `SO_SNDTIMEO` only with the reason the first shape cannot serve).

**VX-959 — the socket path's identity across hosts (Suspected).** A stale host can unlink a fresh host's freshly bound socket in narrow timings: three by-name unlink sites plus the double-start flicker. The first piece is chosen here: a stat-after-bind identity carried with the fd (NEVER `fstat` — it returns the socket object's identity, not the path's vnode; measured in the vx-913 round-1 probes) so a host unlinks only the path it bound, versus serializing the probe → unlink → bind sequence per directory. Write the choice and its reason into your record (a check-then-unlink is not atomic by itself — say what closes the gap). PIN FIRST: a deterministic interleaving (hooks, not sleeps) in which the old tree's stale host removes the fresh host's socket. No reachable red means the finding is hollow: record the attempts and fix nothing. "A server removes only its own socket" (MCPSpec) is the line this makes true in the narrow timings too.

**VX-952 — the opening window reads buffered.** `MCPOpeningWindow.readLine` reads a byte at a time; a 1 MiB opening line costs about a million `read` calls on the handshake's own thread. Bounded, off the pool — a performance cost only. A buffered reader removes it, with the one care the ticket names: the opening must not swallow bytes past what it consumes — whatever it read beyond its own lines reaches the transport untouched, the replayed `initialize` frame and anything pipelined behind it included. Improvement — pin the NEW contract: the read count (or an injected reader's call count) for a near-cap line; byte-exact handoff with frames pipelined in one segment; and every existing arm byte-unchanged (the pre-initialize `-32601` and `ping` answers, the skipped notification, the 1 MiB cap's answer, the setup-key preamble, the closed-app shim's road).

**Evidence of kind:** drills — real sockets, headless; the whole `VariorumMCPTests` target run repeatedly, alone, counts recorded.

**Stop conditions:** any byte of the handshake's answers changing; a lock file or new file in the container that the plaintext export, the backup or the library-send roads would carry (say so and stop).

### BATCH 5 — the parity audit (VX-368); the output-cap measurement (VX-370) HELD

**Reading:** Kickoff and ENVIRONMENT & TRAPS · `notes/MCPSpec.md` IN FULL · AppSpec §9 and §12 (loaded) · `notes/SurfaceContracts.md` IN FULL · `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` → FOR A LATER READER and CLOSEOUT RECORD — PHASE A, D6 · `notes/mcp-invisibility-residuals.md` · `Sources/VariorumMCP/MCPToolCatalog.swift` · the capability registry and the Mac's menus.

**VX-368.** R-VX184-1 says the edit rung is as capable as her at the keyboard. The ask is an audit: list every act she has at the keyboard against the wire's catalog, and put each gap as a proposed ticket or a proposed stated exception. NO code. The deliverable is `notes/plans/vx-981/mcp-parity-audit.md`: one row per act — her door(s), the §9 operation, the wire tool or NONE, the rung it would take by the door's existing rules, whether an open ticket already covers it (VX-145 · 146 · 147 · 148 · 159 · 161 · 316 …), and a recommendation (ticket, or exception with the reason) — sorted so the gaps lead. Acts ruled hers alone (Private, Seal, Own — R-VX184-2; a gathering's rule and wing move; the daily Journal's delete and move) are listed as RULED exceptions with their ids. The ticket names five known gaps (move a span to a new take · rename a tag · extract · the copy-takes divide · word targets): confirm each against the catalog as it stands today. Every recommendation is a PROPOSAL for her — the audit decides nothing; the orchestrator mints the tickets she would otherwise have to restate and bundles the proposed exceptions for her sitting.

**VX-370.** HELD — no second MCP client is installed on this Mac. Write the measurement recipe into the audit's last section from the vx-336 record's U7/U8 method, so the measurement is one sitting's work once a client is installed.

**Evidence of kind:** the audit is its own evidence: every row cites the file and line of the door and of the tool (or the catalog's absence).

## REVIEW FOCI (written at plan time, before any implementation)

1. **The fence did not move.** No answer of `mcpNoteFacts`, `decide`, `decideGathering` or `decideWing` differs on any input because of this run; nothing new writes `ai_private_at`, `sealed_at` or `owned`.
2. **One derivation for the Journal's faces** — the faces read the fence's own leg definitions; the parity pin is real (it would fail if a leg were respelled).
3. **P1 on every new read** — driven by drawn ids, plan-pinned; nothing read past the grants store while no client is approved.
4. **R-825 on every changed wire answer** — `unlink_versions`' new refusal and `show_in_app`'s split answer do not vary with what the client cannot reach; the two-store catalog covers the changed arms.
5. **Wire order** — no frame other than the `initialize` result (and the pre-initialize window's own answers) reaches a connection before its gate opens; a held announce yields exactly one catch-up; VX-258's Allow and VX-818's held-connection roads still announce.
6. **No await in series across connections** on any announce or resume road; no new unbounded task growth; per-connection frame order preserved.
7. **The opening window hands on every byte it did not consume**; the handshake's answers are byte-unchanged.
8. **Every pin is red on the old code** (bug-class) or pins a new contract (improvements); a pin green on both sides is recorded as hollow, not fixed around.
9. **Every authored sentence is listed** for her pass; sentence case; no ticket ids in rendered text.

## THE LEDGER (every row owned; updated as batches close)

| Member | Batch | State | Disposition |
|---|---|---|---|
| VX-1007 | 1 | In Progress | — |
| VX-977 | 2 | Todo | — |
| VX-979 | 2 | Todo | — |
| VX-961 | 2 | Todo | — |
| VX-951 | 3 | Todo | — |
| VX-944 | 3 | Todo | — |
| VX-959 | 4 | Todo | — |
| VX-952 | 4 | Todo | — |
| VX-963 | 4 | Todo | — |
| VX-368 | 5 | Todo | — |
| VX-370 | 5 | HELD | no second client installed; her hands |

## BATCH RECORDS

*(Each implementer appends its `### BATCH N — RECORD` below.)*

### BATCH 1 — RECORD (VX-1007 — the daily Journal shows as Private)

**Not done in this batch (first line, by the protocol):** no `xcodebuild test` run (no stage claim — the app-target gate and its red-on-old leg are the orchestrator's window); no walk (the orchestrator's closing walk runs the WALK SCRIPT LINES below); no canon file edited (the CANON LINES EARNED are drafts); `notes/QUESTIONS.md` untouched (the PROVISIONALs below wait for the merge).

**LIVE STATUS (implementer, flipped in the same commit as each piece):**

| Piece | State |
|---|---|
| R0 — this record's opening: the traced mechanism, the design, the commit plan | DONE (this commit) |
| S — the scaffold + pins: the new fact/face types with the OLD behaviour, every pin written; core pins run RED | DONE (this commit — its hash is the commit that adds this line; the red run is under PINS below) |
| F1 — core: the fence's journal legs as named fragments (one site), the faces' Journal facts read from them | DONE (this commit; green run under PINS) |
| F2 — app: the eye's Journal arms, the two Private rows ticked-and-locked with the why-line | NOT-STARTED |
| V — the revert check (core files to S → red → restored); `build-for-testing` | NOT-STARTED |
| C — the record's closing sections (sentences, canon drafts, gate types, walk script, VM-209, self-assessment); the run's table + ledger flipped | NOT-STARTED |

No revert is in flight.

**The mechanism, traced (inputs → wrong output):** the fence's three legs are derived in ONE place, `Queries.mcpNoteFacts` (`Sources/VariorumCore/Queries/MCPGrantQueries.swift`): leg 1 `(c.profile = 'journal')` (the day-entry shape ⌘J's `createOrOpenJournalEntry` and the Journal's `newJournalEntry` mint — `Operations+Container.swift:101/168`), leg 2 an `EXISTS` over a live member row of a live reading wearing `dailyJournalLegForBook` (`profile = 'daily'`), leg 3 `privateLegForNote` (`ai_private_at`, own or via a live Private book); a book's facts (`mcpReadingFacts`) read `dailyJournalLegForBook` OR `privateLegForBook`. The faces read a SEPARATE fact family, `Queries.privateMarks` / `privateBookMarks` (`Queries/PrivateMarkQueries.swift`), whose three statements (`privateMarkOwnSQL`, `privateMarkViaSQL`, `privateBookMarkSQL`) spell ONLY leg 3 (`ai_private_at IS NOT NULL`). Every eye host (`PrivateMarkHold.notes/books` → `PrivateMarkFace.note(_:)` / `book(marked:)`, `App/Variorum/Variorum/Core/Views/PrivateMarkView.swift`) and the masthead (`MCPNoteIndicatorState.read`) therefore get nil for a day entry and an empty set for THE daily Journal → no eye. The two Private rows read leg 3 alone too: the note ▾ menu's `NotePrivacyState.read` (`Queries.isNotePrivate` + `privateBooksHolding`) binds its toggle to `own`; Book Settings' `BookSettingsModel.load` binds the toggle to `Queries.isBookPrivate` → unticked on the Journal and on a day entry while the fence answers both as fenced. Her report's two symptoms are both this one read.

**The design (built as below; PROVISIONALs listed at the end):**
- **Core, ONE derivation.** The fence's two journal legs become named fragments beside `dailyJournalLegForBook` in `MCPGrantQueries.swift` — `fenceMemberRowSQL` (a live member row of a live reading), `journalEntryLegForNote` (leg 1), `journalMemberLegForNote` (leg 2, built from the two) — and `mcpNoteFacts` reads them (the same SQL text, factored; its answers unchanged). The faces' Journal facts are two new id-driven statements built FROM those fragments: `privateMarkJournalEntrySQL` (leg 1 per drawn note) and `privateMarkViaJournalSQL` (leg 2's books per drawn note, by name). `Queries.PrivateMark` gains `journalEntry` + `viaJournals` (defaulted, so every existing construction reads unchanged); `isPrivate` keeps its meaning (the Private-mark leg) and `isFenced` is new (any leg — exactly `mcpNoteFacts`' fence). `privateBookMarks` / `privateBookMarksDrawn` answer `[id: PrivateBookMark(own:dailyJournal:)]` (books only — a gathering never), the statement reading `privateLegForBook` and `dailyJournalLegForBook` themselves. The gate (`privateMarkGateOpen`) is untouched and still first.
- **App, the faces.** `PrivateMarkFace.note`: a journal leg wins the face — a live member of the daily Journal (with or without the day-entry shape) wears `.viaJournal(books)` (the via-book form naming the Journal — the hover is her "Private — via ‹book›"; the press SAYS, with one door "Open ‹Journal›", and writes nothing); a day entry outside the Journal wears `.journalEntry` (a saying, no door); otherwise today's arms byte-for-byte. `PrivateMarkFace.book`: the daily Journal wears `.dailyJournal` (a saying, no door, never `setBookPrivate`) — even if it also carries its own stamp; else `.ownBook` as today. The rows: the note ▾ menu's toggle and Book Settings' toggle read ticked and DISABLED wherever a journal leg holds, with one why-line; the setters' bindings refuse to act there (the door closed, never the op — contract 6). VX-641's appearance rule is unchanged (a journal leg is not a "mark": the row still waits for the library's first client).
- **Commit plan (pin before fix):** S = the new types and fields with the OLD behaviour (the journal fields never filled, the book dict own-only, the faces' journal arms declared but never chosen, the rows never locked) + every pin → the core pins run RED on S; F1 = core behaviour → core GREEN; F2 = app behaviour → `build-for-testing`; V = `git checkout <S> -- <core files>` → RED → `git checkout <F1> -- …` → GREEN, tree clean.

**PINS — the scaffold's red run (S, headless, 2026-11-19):** `swift test --filter "JournalPrivateFacesTests|PrivateMarkFactsTests"` → "Test run with 23 tests in 2 suites failed". `JournalPrivateFacesTests` (12): RED ×10 — `theDailyJournalWearsTheBookMark`, `anArchivedDailyJournalStillWearsIt`, `aStaleSecondDailyBearerWearsItToo`, `aJournalWithItsOwnStampReadsBoth`, `eachJournalLegMarksItsNote`, `onlyTheAskedIdsAreRead` (the journal one), `theFaceSaysPrivateExactlyWhereTheFenceSaysFencedLegByLeg` (the parity pin: its leg rows red, its fence-value GUARD rows green), `theGateClosedReadsNothingPastTheGrantsStore` (its approved half; the closed half green), `theDrawnFactsFollowTheJournalsFacts`, `theFacesJournalStatementsAreBuiltFromTheFencesOwnFragments` (new contract: the book statement does not yet read the fence's fragments); GREEN ×2 by nature (GUARDS) — `aTraitBookADeadJournalAndAGatheringWearNone`, `theJournalStatementsAreDrivenByTheIdsNeverAScan`. `PrivateMarkFactsTests` (11): all green with four JUSTIFIED EDITS (the book facts are keyed now — `Set(read.keys)` / a tuple's type; no assertion's meaning changed). A first draft held the Journal's book facts through `db.observe`; on the old behaviour the observation never re-emits and the run HUNG — that pin was rewritten as plain reads (the held reads' regions are the Private leg's held pin's tables) and the hung run killed (only this batch's own processes). `build-for-testing` at S: TEST BUILD SUCCEEDED (one JUSTIFIED fix on the way: `NotePrivacyAct.set(_:postID:session:)` kept, the row's guarded `set(_:state:session:)` delegating to it, so `MCPAskAndReceiptTests` reads unchanged).

**PINS — F1's green run (headless):** `swift test --filter "JournalPrivateFacesTests|PrivateMarkFactsTests|MCPFenceRekeyTests|MCPPrivateMarkTests"` → "Test run with 36 tests in 4 suites passed" (no skipped lines). The fence's neighbours, run to show the factoring of `mcpNoteFacts` moved nothing: `swift test --filter "MCPShareTests|MCPRowReachTests|MCPGrantInContextTests|MCPGrantPlacesTests|WireIntakeNeverFencesTests|MCPGatheringGrantDecideTests|MCPGrantRuleTests|MCPFenceRekeyServerTests|MCPReachPureAnswersServerTests|MCPTwoStoreCatalogServerTests|MCPWireIntakeNeverFencesServerTests"` → core "70 tests in 8 suites passed" + MCP "19 tests in 4 suites passed" (the two-store catalog and the fence re-key on the wire among them; 0 skipped).

