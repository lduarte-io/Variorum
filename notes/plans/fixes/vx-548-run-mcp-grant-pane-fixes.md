# VX-548 — Run: MCP grant & pane fixes

**STATUS: OPEN — kicked off 2026-10-27 (overnight, `/architect-phase vx-548`).**
Ticket: VX-548 (run ticket; members are sub-issues) · Project: 13n — The MCP door · Branch: `vx-548-run-mcp-grant-pane-fixes` · Worktree: `~/dev/variorum-vx-548` (the Pro).

**Her kickoff words (2026-10-27, verbatim):** *"overnight protocol: run autonomously, provisional-and-continue, bundle every question for my morning. Batches in ticket order, gates first (VX-516/515/512 — VX-516 is Urgent). The VX-394 trace clue and all my rulings (VX-549's sitting, VX-126 n/a here) are on the tickets. Stage claims through tonight's coordinator. No release without my word. coordinator is oct26coordinator"*

**The overnight protocol as applied here:** PROVISIONAL-and-continue everything that doesn't hit an author-only hard stop; every question, taste call and ratification lands in §MORNING BUNDLE below (and the QUESTIONS.md bundle at the merge); nothing improvised around, nothing silently dropped. No release, no `/Applications` refresh, no deploy. Stage claims only through the coordinator session `oct26coordinator`.

**Cast:** Fable architect/orchestrator (this session) · `opus-implementer` (xhigh), ONE per batch, fresh each time · `fable-reviewer` (xhigh) for the ladder — the run's diff is MCP (grants decide AI reach — default's-meaning content), so the cold review is Fable's. One ladder over the run's whole diff after the batches; pin-before-fix binds PER MEMBER.

**Not in this run:** VX-126 (her word: n/a here). VX-554 (the gathering new-note button — VX-549's wire shape mirrors it, never builds it). VX-565 / VX-590 / VX-566 / VX-567 and every other open MCP ticket: rider candidates bundled for her morning (§MORNING BUNDLE), never seated without her word.

---

## THE BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied byte-verbatim per the architect-phase skill; binding on every batch)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

**Application notes that bind the same way (the skill's precisions):** P-1's scope is the ROUTED vocabulary, grown incrementally — surface-local doors that already work are not retro-declared wholesale; acts whose only doors are inline declare `.surface`, never mis-file under `.contextMenu`. Storage-coupled code lives feature-side, never in shared `Registry/`/`Surface/` layers. Every equality-gated sink delivers its stored state AT WIRE TIME, and overlay geometry refreshes trigger on every input axis. The closing form for a recurrence of a fixed class is the sweep table: instance × host/path, each cell FIXED-with-named-pin or provably SAFE with the mechanism stated.

**Standing rules restated for every batch (CLAUDE.md's, applied hard):** no fix without a self-traced concrete mechanism; every bug-class fix lands with a red-on-old pin verified by behavioral revert; a pin green on both sides exposes the finding as hollow — record it, don't fix it. Every mutation through the operations API; the grant check inside the op's own transaction; grants are LOCAL-ONLY, never synced; no literal colour outside the token layer; rendered app text is sentence case (her "I hate unnecessary caps"); messages carry a kind (refusal / offer / receipt) decided at the door. Commits carry NO attribution trailer. Commit per piece, push after every commit (the resiliency protocol binds; briefs restate the checkpoint rules).

---

## REQUIRED READING (preflight per batch — reading is never delegated)

Every implementer reads: CLAUDE.md + its auto-loaded canon (automatic) · **`notes/MCPSpec.md` IN FULL** (the door's authoritative contract — every batch here touches it) · `notes/SurfaceContracts.md` — "Doors to the outside" and "The app" sections (batch 2a adds "The note" for the Takes card and "The Bookcase and books" for the Book Panel) · this plan file IN FULL · `notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from the first commit). Batch-specific reading is named in each brief. **SyncSpec note:** the MCP grants family is LOCAL-ONLY (v1_24 → v1_30) — never synced, no mirror, no §12 lockstep; batch 3's migration extends that local-only family. Nothing in this run touches `Sources/VariorumCore/Sync/`, `Server/`, or custody. If any member's trace leads into those trees, STOP and report to the orchestrator — that re-scopes the run.

## ENVIRONMENT TRAPS (carried into every brief by reference; binding)

- Run everything from `~/dev/variorum-vx-548`. Never commit from `~/dev/variorum` (main).
- Headless `swift build` / `swift test [--filter Name]` on the core package: free, no stage. **EVERY `xcodebuild test` run and anything touching the screen or a shared store needs a HELD `Tools/stage` claim — request it through the ORCHESTRATOR, who clears it with tonight's coordinator (`oct26coordinator`).** Do not claim the stage yourself without the orchestrator's go.
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines before claiming a gated suite ran. NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).
- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or kill one. No Release builds or `/Applications` refreshes in this run at all (her word: no release without her word).
- The dev store is the Debug app (`io.lduarte.Variorum.debug`); walks via `cliclick` + `Tools/WalkKit/` on the dev store only, under a held stage claim. The dev store's Castle credentials are `~/.variorum/dev-castle.env` on the Pro — never invent new ones; restore the dev store's posture before releasing a claim.
- zsh `pipestatus` (not bash's `PIPESTATUS`). Screenshots in gitignored dirs. Never `git checkout` over uncommitted work. Push after every commit; never rewrite pushed history. Synchronous foreground waits only — poll logs with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1` after the fact, never end a turn awaiting a background run.
- No subagents inside implementer/reviewer sessions except ONE read-only Sonnet for external facts (spawn with `model: "sonnet"`).
- **The VX-604 false-green trap (coordinator heads-up, 2026-10-27, from VX-439's run):** a lone-suite Mac run on this machine can false-green through a test-host launch crash, reporting "0 tests in 1 suite passed". Every Mac run's verdict states its EXECUTED test count; a run that executed 0 is NO verdict, red-on-old legs included. (The b1 window's verdict stands: 141 executed in 12 suites, one invocation.)
- **Two load-sensitive flakes are standing — VX-532 and VX-607 (the ladder's round 1, finding 2):** a full-parallel failure in either is re-run isolated before it counts. VX-532: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (a 15 s wall clock). VX-607: `MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds` (its "premiseFailures == 0" — every session's `initialize` answered inside the client socket's 5 s receive timeout, 150 rounds × 2 endings). Every headless suite claim in this record that says "the one standing flake" predates VX-607's sighting and reads as "the standing flakes" from here on.
- **The coordinator's stage protocol (oct26coordinator's, RATIFIED by her 2026-10-27 — see SITTING/RULING RECORD):** only the ORCHESTRATOR talks to the coordinator; REQUEST early → READY when built-and-startable → start only on the coordinator's GO → `Tools/stage release` + one result line. Strict instance checks: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the loose form matches builds). After every Debug launch, dismiss a What's New sheet if one shows. Walks are DEV STORE only; no real-store MCP tool calls or real-app launches. A walk that would write MCP client config outside the dev store (Claude Code's / Claude Desktop's server entries, setup keys) is DECLARED in the request and restored at release. Debug prefs: export first; at restore re-export and diff (`defaults import` merges). Merges serialize through the coordinator.

---

## THE BATCHES (her ruling: ticket order, gates first)

| Batch | Members | Session | State |
|---|---|---|---|
| 1 — the gates | VX-516 (Urgent) · VX-515 · VX-512 | opus-implementer №1 | **ACCEPTED** (window vx548-b1-walk: Mac suites 141/12 green, zero skips; orchestrator walk green — ORCHESTRATOR ACCEPTANCE, BATCH 1) |
| 2a — faces & wire answers | VX-352 · VX-354 · VX-365 · VX-358 | opus-implementer №2 | BUILT (headless green, red-on-old verified incl. two behavioural reverts; Mac pins compiled into `DerivedData/b2a`) — Mac run + faces walk ride the MID WINDOW after 2b — BATCH 2a RECORD |
| 2b — the disconnect story | VX-394 | opus-implementer №3 | BUILT (headless green, red-on-old verified 3/6; the sweep table 12 roads — 2 FIXED, 9 PINNED-GREEN, 1 safe; App Nap NOT built; reconnect options for her; Mac pins compiled into `DerivedData/b2b`, run rides the MID WINDOW) — BATCH 2b RECORD |
| 3 — gatherings as a grant place | VX-549 (not launch-gating) | opus-implementer №4 | BUILT (headless green, red-on-old by construction + two behavioural reverts — decide 6/7, wire 7/9; the VX-273/VX-185 pins flipped deliberately; Mac pins compiled into `DerivedData/b3`, run rides the stage) — BATCH 3 RECORD |
| L — the ladder | the run's whole diff | fable-reviewer, fresh per round | NOT STARTED |

---

## BATCH 1 BRIEF — the gates: VX-516 · VX-515 · VX-512 (one surface: the grant road + Settings ▸ MCP)

**Extra required reading:** `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5 + the U5 UNIT RECORD (VX-393's build — R-VX348-6 "Upgrade in place", P-VX393-1…3) · the VX-510 record's MCP sections (`notes/plans/fixes/vx-510-first-run-sync.md` — grep "MCP"; her Air reports are the gates' birth record). Code anchors: `Sources/VariorumCore/Operations/Operations+MCPGrants.swift` (`insertMCPGrant`, both `grantMCPAccess` forms, `revokeReplacedMCPGrants`) · `Sources/VariorumCore/Persistence/MCPGrantSchema.swift` (`uq_mcp_grant_standing_place`, :263) · `Sources/VariorumCore/Queries/MCPGrantQueries.swift` (`mcpSharedGroups`, the pane's listings, `MCPSwitch.server`) · `App/Variorum/Variorum/Features/MCP/MCPGrantSheet.swift` (`submit()`, `load()`) · `App/Variorum/Variorum/Features/MCP/MCPDoor+Share.swift` (`changeOpening(_:)`, `changeOpening(act:)`, `speakShared` — every road that fills `replacing:`) · `App/Variorum/Variorum/Features/MCP/MCPPane.swift` (the Clients row :432, the Shared with AI tab) · `App/Variorum/Variorum/Core/Views/MCPShareRoad.swift` (`MCPGrantOpening`).

**The tickets' text (verbatim-faithful; the full bodies are on the Linear tickets — these carry everything load-bearing):**

- **VX-516 (Bug · Confirmed · Pre-launch · URGENT).** Her report (2026-10-23, re-granting claude-code on a fresh library after the 0.10 crossing): *"it keeps just changing what is shown though - it doesn't show both & I can see that the other one is revoked when I grant that one."* Granting claude-code a second wing (PlanetLillian already granted, always) REPLACES the first instead of adding a second row — contrary to VX-393's rule (one standing grant per client × PLACE; two wings are two places). Not the schema: the partial unique index is per place. Untraced suspects: the grant road's replace/upgrade-in-place logic keying on the client or scope kind rather than the place, or the sheet's `replacing:` set (`MCPGrantOpening`) filled on a road that should add. **An orchestrator's earlier reading that the Clients row's Change… "replaces nothing" was wrong in practice (it read only the sheet's opening) — do not repeat that mistake: prove each road's behavior by test, not by reading the opening.** Her urgency (2026-10-26): *"allowing multiple grants is one of my highest priorities because it's so annoying that only you or planetlillian can be working at one time."* ("PlanetLillian" = her Claude agent working in that wing — two agents forced to take turns.)
- **VX-515 (Improvement · Confirmed · Medium).** Her words: *"how am I supposed to be able to grant multiple wings to claude code? I don't see the option to add another one here and when I added it, it was in the old MCP pane."* And: *"there also needs to be a way to see everything you've granted, following that more will be granted."* Two asks: (1) a visible way to share ANOTHER place — today the Clients row's add door is named "Change…" and Shared with AI offers only Change… (which REPLACES) and Revoke per row; her candidate: a "Share another place…" door on Shared with AI (and per client), and the Clients row's door renamed to say it adds. (2) one place to see EVERYTHING granted — every grant every client holds (note · book · wing, rung, duration).
- **VX-512 (Improvement · Confirmed · Medium).** Her report: *"my variorum mcp connection is refusing with: Failed to connect to Variorum -32000. re-set up? unexpected or normal?"* Traced EXPECTED by construction — the switch and every client binding live in the library's LOCAL-ONLY grants tables, so Start fresh → join made a library with the door off. The gap is the SILENCE: nothing told her the door stayed with the old library. Her candidate: the MCP pane on a library that has none says the previous library's clients don't carry over; a release-notes line for any Start-fresh release (that half is a release-drafting note, not code — record it in §MORNING BUNDLE).

**Orchestrator's orientation (verify, never trust — your trace is the record):** the core op is already per-place-correct: `insertMCPGrant`'s VX-393 standing-replace is keyed `client_id AND scope_kind AND scope_id` (Operations+MCPGrants.swift:289–297), so `grantMCPAccess(_:_:)` with no `replacing` cannot revoke another place's grant. The revoke she saw therefore almost certainly came from a road that filled `replacing:` — the Shared-with-AI row's Change… (`changeOpening(_:)`), the receipt's Change… (`speakShared`), or the act-group Change… — confirmed in a sheet where she then PICKED A DIFFERENT PLACE: `MCPGrantSheet.submit()` passes `opening.replacing` regardless of whether the confirmed place is the place the opening named, so "Change…" on wing A + picking wing B revokes A and mints B. Trace her exact repro against every road (the Clients tab row :432 opens with empty `replacing` — prove in practice what it does); if any road reaches the op with a cross-place `replacing`, that is the mechanism to pin.

**The build (most spec-defensible; PROVISIONAL where marked):**
1. **VX-516 pin + fix.** Red-on-old pin at the decisive seam: with wing A's standing grant held, the act her repro performs must leave BOTH wings standing afterwards. The spec-defensible rule (PROVISIONAL — bundled as MB-1): **Change… keeps its T-U3-8 replace semantics ONLY while the confirmed place IS the place the opening was made for; confirming a DIFFERENT place is a new grant — `replacing` is dropped, nothing revoked.** (T-U3-8's ruled purpose is "change its details fast" — rung/duration on the same place; it was never ruled as a move-the-place door.) Implement at the sheet's seam as a pure, unit-testable decision (place-at-open vs place-at-confirm → replacing kept or dropped), so the pin is headless. Keep the sheet's quiet "replaces" line, and make it NAME what it replaces (place + client) so a true replace is visible before the confirm — one line, sentence case.
2. **VX-515 ask 1.** A "Share another place…" door: on the Shared with AI tab (top-level, and per client where the tab groups by client), opening THE grant sheet with the client pre-picked, nothing else pre-filled, `replacing` empty. Rename the Clients row's "Change…" to a word that says it adds (settings voice, sentence case — "Share a place…" is the default; final wording is hers, PROVISIONAL MB-2). These are surface-local pane doors (the P-1 `.surface` class) — no registry retro-declaration owed, but any door you add renders only when the pane's existing gates allow (an approved client; VX-272's canShare for place-side faces).
3. **VX-515 ask 2.** The Shared with AI tab lists EVERY live grant every client holds — place (note · book · wing), rung, duration, grouped as today's exact-stamp groups where they exist; nothing hidden by collapsing. Read `Queries.mcpSharedGroups` and the tab's rendering; if the listing already shows all and her "doesn't show both" was VX-516's revoke, say so in the record (that is a finding about the listing being honest, not a fix). P1: the tab reads grant rows, never the corpus.
4. **VX-512.** The MCP pane's zero-state (no clients, door off — the Connect tab's resting face) gains ONE quiet explainer line (the `ExplainerLine` idiom, one line + full text behind the (i)): AI clients and their grants belong to one library — another library's clients don't carry over; enable the server and run each client's setup again here. Exact wording PROVISIONAL (MB-3), sentence case, no shouty caps. It renders on every library whose grants tables are empty (no "came from Start fresh" detection — the store has no such fact; the general sentence is true in every such case).
5. **Note, don't build:** VX-565 (duplicate grant rows per client) and VX-590 (Shared with AI face hidden until a client connects) are OPEN tickets adjacent to this surface. If your listing work changes their symptoms, record what changed in the batch record — do not claim or expand into them.

**Evidence of its kind:** exact state-transition tests for every grant-op path touched; the VX-516 pin red-on-old, verified by behavioral revert; pure unit tests for the sheet's keep-or-drop-replacing decision; `swift build` + the targeted core suites green; the Mac app target compiles (`xcodebuild build` needs no stage). A pane screenshot walk is the ORCHESTRATOR's acceptance step (stage via coordinator) — do not run GUI walks yourself.

**Checkpoint rules (binding):** commit per coherent piece, push after every commit; LIVE STATUS section in this file's BATCH 1 RECORD from your first commit, flipped per piece in the same commit; PENDING on every unverified claim; foreground waits only; one batch, this batch, nothing else. When done: fill the BATCH 1 RECORD below (trace, mechanism, pins with their test names, dispositions, files touched, counts), commit, push, report.

---

## BATCH 2a BRIEF — faces & wire answers: VX-352 · VX-354 · VX-365 · VX-358

**Extra required reading:** `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md` — the U5 STAGE RUN step 12 (VX-352's capture), U6b UNIT RECORD (VX-354, "the sweep table, OWED 2"), U7 UNIT RECORD + BUILDER A's RECORD (VX-358, OWED 3), U9 UNIT RECORD (VX-365, OWED 4) · SurfaceContracts "The note" (Takes) and "The Bookcase and books" (the Book Panel) sections.

**The tickets (verbatim-faithful):**
- **VX-352 (Improvement · Confirmed · Low · Takes & Lenses).** In Terminal, the Takes card header ("choose ‹label›" + the ◀ ▶ ⌄ controls) tail-truncates an AI take's label at the card's width: "claude-code · english" reads "claude-code · e…" — the part that tells takes apart is lost. Study shows it whole. Possible fix per the ticket: middle truncation, or keep the label's own part and let the client name yield, plus a hover with the whole label. Wording/face only. **Default build (PROVISIONAL MB-4): keep the label's own part, let the client-name part yield, add the whole-label hover.** Prefer a pure label-elision rule unit-testable headlessly; the hover through the one hover idiom the surface already uses.
- **VX-354 (Improvement · Confirmed · Low · MCP).** The Book Panel's header (the shown book's name) and the names of the gatherings it lists wear neither `MCPSharedIcon` nor `MCPAskGlyph`; every note row (and collapsed one-note chapter row, VX-330) does. Build: they wear the marks, reach read through the ONE rule (`decide` / `decideGathering` — never a parallel rule), rows-drawn-only (P1), nothing read while no client is approved (VX-272's gate). A note- or book-level share never icons a gathering (R-VX185-1 stands).
- **VX-365 (Improvement · Suspected · Low · MCP).** `add_note_to_book` applies the book's outflow tags on a hand-add but its answer names no tags. Build VX-361's shape: the answer gains `tag_ids` + parallel `tags` (paths) listing EVERY tag the note wears when the act lands — applied-then-outflow, each once. Update the tool's description if it enumerates answer fields; the answer for a book the client can't fully read keeps every existing fence rule byte-unchanged.
- **VX-358 (Improvement · Suspected · Low · MCP).** `edit_take`/`restore_commit`'s no-op check uses Swift canonical equality, so an NFC↔NFD re-spelling answers `changed: false` while the answered `sha256` (the stored text's) differs from the digest of the bytes the client sent — honest about the store, surprising to an agent proving its write by digest. **Default build (PROVISIONAL MB-5): keep canonical equality for the no-op (an invisible re-normalization must not rewrite prose, churn, or mint undo entries); when the no-op's sent bytes ≠ stored bytes, the answer says so** — one additive field (e.g. `stored_text_normalization_differs: true` beside the digest; absent otherwise so every other answer stays byte-unchanged) and one sentence in the two tools' descriptions. The digest stays the stored text's (VX-254's definition untouched).

**Evidence:** per member, a pin of its kind — the elision rule's unit tests (red-on-old for the "claude-code · e…" case); the Book Panel reach-mark tests at whatever seam the panel's row marks are already pinned (read VX-330's tests and extend); exact answer-shape tests for `add_note_to_book`, `edit_take`, `restore_commit` (red-on-old: the old answer lacks the field); `swift build` + targeted suites green; Mac target compiles. GUI confirmation of VX-352/354 is the orchestrator's walk.

**Checkpoint rules:** as batch 1's. Fill the BATCH 2a RECORD below.

---

## BATCH 2b BRIEF — VX-394: the mid-session disconnect story

**Extra required reading:** `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5 (the client-session report VERBATIM — your trace source) + the U5 UNIT RECORD's VX-394 sections (the drop-line build, P-VX394-1…6) · MCPSpec's "A dropped connection says why (VX-394)" contract sentence (already shipped — this batch builds on it, never regresses it) · the VX-445 lock-road record pointers in SurfaceContracts' protection bullet (the idle/sleep monitors lock through the road session).

**The ticket (verbatim-faithful):** the client-session report: all tools vanished mid-session with "MCP server disconnected" while Settings ▸ MCP read "running · socket in the app container"; /mcp reconnect fixed it; always-grants survived. Suspects: App Nap / idle throttling (consider `ProcessInfo.beginActivity` while clients are connected), socket idle timeouts, the socket path across restarts/sleep. Ship: the traced fix + a drop line in Activity (NOTE: the drop line SHIPPED at VX-348 U5 — verify, don't rebuild). Don't regress VX-180/181 (the closed-app error + mid-session connect). Second sighting 2026-10-26 (PlanetLillian's agent): same shape; its suggestions — a keep-alive, and verifying the socket path survives app restarts. **HER TRACE CLUE (2026-10-27): today's two drops happened when her MacBook AIR locked (the session ran against the Air's Variorum).** That fits a mechanism partly BY DESIGN: the MCP server host stops at store close, LOCK and quit — a screen lock that locks the library stops the door, every client connection drops, and after unlock the server restarts but the client never reconnects without her /mcp. The original 3–4 AM idle report is plausibly the same road (idle → lock). The run's questions become: (a) the honest story — a drop line in Activity ("the library locked; ‹client› disconnected") and the pane never reading "running" while stopped; (b) whether the door should survive a lock at all (security says probably not — the door serves only while the library is open); (c) client-side reconnect ergonomics. Probe whether her Air's lock locks the library (the idle-lock dial) or only the screen.

**Scope rulings for this batch (the orchestrator's; overnight):**
1. **(b) is ANSWERED by standing canon — do not build around it:** A-8 and MCPSpec — the lock stops the server and every connection with it; the next unlock starts it again. The door never survives a lock. Nothing here changes that.
2. **The honest story (buildable):** (i) VERIFY by test that EVERY lock road writes the ruled drop line — the explicit Lock Now, the idle-lock monitor, the sleep monitor (VX-445's roads), store close and quit. The ruled line for the lock road is written after the notes' savepoints and before the store closes (`macWillLock`'s `endingConnections` step). If any road misses it, that is the bug-class fix: pin red-on-old per missed road. (ii) The pane's status must never read "running" while the server is stopped — trace the pane's status source; if there is a state where the server is stopped and the pane would say running, pin and fix. (If the pane is simply unreachable while locked and honest after unlock, record that as the mechanism — her "running" reading was POST-unlock with the client dead, which the status cannot see; say so in the record.)
3. **(c) reconnect ergonomics — INVESTIGATE AND PROPOSE ONLY.** The shim is MCP-blind by design (MCPSpec); any auto-reconnect that replays a handshake is a design event. Write the options (shim-side reconnect-with-re-init, a client-visible "server restarting" close reason, documentation-only) with tradeoffs into the BATCH 2b RECORD for her morning. Build nothing on this leg.
4. **App Nap (the original 3–4 AM case, PROVISIONAL MB-6):** if and only if your trace shows the in-app server host can be throttled while clients are connected AND the Air-lock mechanism does not fully explain the original report, add `ProcessInfo.beginActivity` held exactly while ≥1 named connection is live (released at zero), with the mechanism stated. If the lock road explains everything, record that and build nothing — a fix without a traced mechanism is forbidden.
5. **Her Air's idle-lock dial:** cannot be probed tonight (her real store, her machine). Bundled as MB-7 with the exact check for her morning.

**Evidence:** the lock-road sweep as a table (road × drop-line, each cell PINNED-green or FIXED-with-pin — the skill's sweep form); pane-status pin if traced dishonest; no regression on VX-180/181's pins (run their suites); `swift build` + targeted suites green.

**Checkpoint rules:** as batch 1's. Fill the BATCH 2b RECORD below.

---

## BATCH 3 BRIEF — VX-549: a gathering as a grant place (feature; NOT launch-gating — if this batch slips, launch doesn't wait)

**Extra required reading:** the VX-549 ticket's sitting record (copied verbatim-faithful below — it IS the ruling set) · MCPSpec in full with special attention to: grants per client × scope, the four rungs, durations, the fence (VX-163's keys; the ONE not-shared shape), VX-273's facts-only rule (being superseded HERE), R-VX185-1 (`decideGathering`), VX-392 (`list_wings` counts gatherings), VX-393 (one standing row per client × place) · AppSpec §7 reading/`query_spec` (the v2 rule grammar; "a gathering requires a rule"; archived gatherings assemble empty) · `Domain/RuleGrammar.swift` · `Domain/MCPGrantRule` + `Queries/MCPGrantQueries.swift` (decide/decideGathering/decideWing) · `Sources/VariorumCore/Persistence/MCPGrantSchema.swift` (the migration family v1_24 → v1_30).

**HER SITTING (2026-10-27, from the ticket, verbatim-faithful — RATIFIED):** the supersession of VX-273's facts-only rule is RATIFIED. Gathering joins the grant scopes; reach is resolved by assembling the rule at read time. Reach moving with her tagging is confirmed as the feature, her words: *"this is the feature, routing work to an agent by each tag."* The Private fence wins every tie, confirmed: a rule-matching note carrying the Private MARK answers as nonexistent (the byte-identical missing shape) — and the fence is the MARK, never a tag that happens to be named "private". Rungs: read/suggest behave normally over members; write_new mints the note bookless in the wing and applies the rule's tags so it assembles in (the same shape as the human door VX-554); edit applies to member notes. Starring is not on the wire (a VX-368 parity item), so write_new on a rule tagging can't satisfy (star terms) refuses honestly and the grant sheet presents such a grant as read/suggest-shaped. MCPSpec carries the superseding rule at the run's closeout.

**The build:**
1. **Schema (own commit, before the code that uses it):** the next local-only grants-family migration extends `scope_kind` to include `'gathering'` (the family is local-only — no sync, no mirror, no §12 lockstep; the migration proves existing rows untouched). The partial unique index `uq_mcp_grant_standing_place` already keys on (client, kind, id) and needs no change — verify by test.
2. **The decide rule:** `Domain/MCPGrantRule` + the queries learn the gathering scope. A note is reached at a gathering grant's rung iff it is IN the gathering's assembly at read time (the rule assembled exactly as the gathering's own surfaces assemble it — the ONE membership function, never a parallel evaluation) AND not fenced (the Private mark, the daily-Journal/⌘J keys — every existing fence key wins, answering the ONE byte-identical not-shared/missing shape). An ARCHIVED gathering assembles empty everywhere (standing rule) — so its grant reaches nothing while archived; a rule-less gathering (Trash restoree) likewise. A DEAD gathering grant target answers as every dead place does today. Cost: ∝ the rows decided, never the corpus (P1) — note the assembly is a rule query per decided note; keep it to the rows drawn/asked about, and reuse the existing assembled-membership query machinery.
3. **The wire:** tools that read/list under a place learn the gathering scope exactly as far as the ruling says: read/suggest over members; `list_notes` on the gathering id lists its assembly (chapters: a gathering has none — `grouping_tag_id` sectioning only; follow how the open-book/wing roads list a gathering today); search/list within reach honors it. `write_new`: minting under a gathering grant lands the note BOOKLESS in the gathering's wing and applies the rule's tags through the ONE application road (so living books hear them — the standing intake law), one client-named undo entry, the answer in VX-252's record shape with VX-361's tags listing. A rule whose satisfaction REQUIRES a star (no tag-only assignment can assemble the note in — a pure function on the rule grammar decides this; NOT terms count as tag-satisfiable) refuses write_new honestly with a worded sentence (never the not-shared shape — the grant holder can read the place; this is a rungTooLow-family honest refusal). `edit` applies to member notes through the existing op guards.
4. **The faces:** the grant sheet's WHERE grows a gathering option (the one sectioned `SearchPicker`; a star-term-rule gathering presents read/suggest-shaped — the write rungs not offered, with the one-line why, mirroring how fenced picks offer only honest durations). The shared icon: a DIRECTLY granted gathering wears it through `decideGathering` grown for the new scope (never a parallel rule); its reached member notes wear note-row marks through the one `decide`, rows-drawn-only. `list_wings`' counts are untouched (it counts a wing's gatherings as facts; a gathering grant grants no wing and never lists there — hidden = missing holds: a client holding only a gathering grant sees no wing row). Durations: once · while connected · always, as every place; the ask road (⌥⌘A and the just-in-time ask) offers a gathering exactly where it offers a book today IF the road's picker reaches gatherings — follow the sheet's existing picker structure; expand no other road.
5. **Every refusal worded** (the OpsRefusalTable / MCPWireRefusalCopy chain — no raw Swift case reaches the wire); Activity speaks every new act in words; `MCPSession.instructions` and tool descriptions updated ONLY where they enumerate grant places (keep ≤3,000 chars — R-VX184-3).

**Evidence:** state-transition tests per op path (grant mint on a gathering; decide over assembly; fence wins; archived/rule-less assemble empty; write_new mints + tags + undo + answer shape; star-term refusal; dead target); the pure tags-can-satisfy function's unit table; red-on-old where a behavior changes (the VX-273 facts-only pin that today refuses a gathering grant flips — flip it DELIBERATELY, citing the ticket's ratified supersession, never silently); `swift build` + targeted suites green; Mac target compiles.

**Checkpoint rules:** as batch 1's. Fill the BATCH 3 RECORD below. This is one acceptance unit; if mid-build you find it larger than one session honestly carries, STOP at a clean committed seam and report — the run proceeds without batch 3 before it proceeds badly (her word: launch doesn't wait on it).

---

## THE LADDER (after the batches; the run's whole diff)

Fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md` VERBATIM with zero framing (the diff is MCP/default's-meaning — Fable reviews). Round 1 → fixes (implementer applies confirmed fixes, red-on-old per finding) → round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; hard cap three. Cross-model flow: findings go to the implementer verbatim, its agree/dispute returns to the reviewer, the reviewer makes the final call; FINDER-FIXES only per its mark (then one implementer sanity pass). Findings + dispositions land in this file before the next round. Disputes on undefined product behavior → QUESTIONS.md.

## CLOSEOUT CHECKLIST (the standing ritual; run at the merge, on latest main, serialized with other closeouts)

Results + counts here; in-flight row retired; MCPSpec gains VX-549's superseding contract lines + any VX-393-rule clarification exactly as built (two-file shape: contract lines in MCPSpec/SurfaceContracts/AppSpec §7 comment, the dated entry + narrative appended to `notes/AppSpecRecord.md`); `Tools/canon-size` run, its line in the handoff; QUESTIONS.md bundle #243 (the §MORNING BUNDLE below); tickets closed per member (Done rides the PR merge), every ticket the run FILES triaged to the labeling rule; rulings reconciled against what shipped ("every road", "everywhere" re-read); MOBILE PARITY line (expect "nothing mobile-visible" — the phone has no MCP door; confirm); the PR merges as a MERGE COMMIT titled `VX-548: …`; branch + worktree removed after merge; build debris + walk evidence deleted; the author handoff `notes/handoffs/vx-548-handoff.md` with her checklist at top; memory updated; hard stop. NO release, NO `/Applications` refresh (her word).

---

## MORNING BUNDLE (accumulates; becomes QUESTIONS #243 and the handoff's checklist)

- **MB-1 (PROVISIONAL, batch 1):** Change… replaces only while the confirmed place is the opened place; a changed place grants NEW and revokes nothing. Ratify or redirect.
- **MB-2 (PROVISIONAL, batch 1):** the Clients row's add door wording ("Share a place…" default) + the "Share another place…" door's wording.
- **MB-3 (PROVISIONAL, batch 1):** the VX-512 explainer line's wording; ALSO the release-notes practice note — any Start-fresh release's notes carry the clients-don't-carry-over line (for her release drafting).
- **MB-4 (PROVISIONAL, batch 2a):** VX-352 elision rule — label's own part kept, client name yields, whole-label hover.
- **MB-5 (PROVISIONAL, batch 2a):** VX-358 — canonical no-op kept; additive `…normalization_differs` honesty field.
- **MB-6 (PROVISIONAL, batch 2b):** App Nap guard built only if traced warranted; see the batch record.
- **MB-7 (her hands, batch 2b):** does her AIR's lock lock the LIBRARY (Settings ▸ Protection ▸ On this Mac — the idle-lock dial) or only the screen? Decides whether the Air drops are fully the by-design lock road. Also: her call on the reconnect-ergonomics options (batch 2b record).
- **MB-8 (riders, the standing rule's offer — none seated tonight):** open Low/Medium tickets in this run's Areas, cheapest while this code is open: **VX-565** (duplicate grant rows per client — same pane listing as VX-515), **VX-590** (Shared with AI face hidden until a client ever connects — same zero-state as VX-512), **VX-566/VX-567** (import_document: section_id; book-form sha256s — same wire family as VX-365/358), VX-367/368/369 (MCP docs/parity/raw-error sweeps), VX-321 (Takes wording). Say the word and any of these ride before the ladder.
- **MB-1, as built (batch 1):** Change… keeps its replace only while the place confirmed IS the place it was opened on
  (an act's Change… — its notes said, never re-chosen — keeps it over the notes that stand). Picking another place in a
  Change… sheet turns it into a new grant on the spot: the title reads "Grant access — ‹client›", the replaces line
  goes, the receipt says "Shared …", and the grant it was opened on stands. A consequence to rule on: Change… on an
  INERT row (a book fenced since, not in the offer) can no longer move that grant to another book — the inert grant
  stays (Revoke takes it). Alternative (b): keep Change…'s replace across places but say so in the sheet when the place
  changes ("replaces the PlanetLillian grant") — the pre-fix behaviour, made visible.
- **MB-2, as built (batch 1):** "Share a place…" (the Clients row) and "Share another place…" (under Shared with AI's
  rows). The empty Shared tab (an approved client, nothing shared) shows NO add door — "another" would be false there;
  the Clients row's "Share a place…" is the road. Options: (a) as built; (b) the empty tab also carries a door, worded
  "Share a place…" (one more `.surface` door); (c) one word for both doors. The guide's two new sentences are hers to
  re-voice too: lesson 2 "…with Share a place… to share more with it…", lesson 5 "Share another place… adds one beside
  them, so a client can reach several places at once." (Existing libraries keep their seeded guide until Help ▸ Restore
  Tutorial….)
- **MB-3, as built (batch 1):** the line sits in the pane's top section under the server's line, on every tab, while the
  library has no client at all — "Clients belong to the library they were set up in — run each one’s setup here." with
  its (i). Alternatives: (b) on Connect only, under the setup block; (c) other words (her copy pass). The release-notes
  practice note stands as written above.
- **MB-9 (batch 1 — for the ladder or her; not built):** the place rule lives at the sheet's one confirm (the brief's
  seam); the core op `grantMCPAccess(_:_:replacing:)` still revokes whatever grants it is named, its pinned contract
  (`changingAGrantToAnotherPlaceReplacesThatPlacesRowToo`). Option: also hold the op to it — a named grant on another
  place refused (`mcpGrantNotFound`-family) or skipped — so a future road that forgets the decision cannot revoke across
  places (defence in depth; flips that pin deliberately).
- **MB-4, as built (batch 2a — VX-352):** a narrow take card splits the label at its FIRST " · " — the client's name
  (with the legacy "suggested" word) yields, the separator and the label's own words are kept whole — and the whole
  label is the hover: "claude-code · english" reads "claud… · english", then "… · english". A label of hers that holds
  " · " splits the same way (its first part yields first). Alternatives: (b) middle truncation of the whole label
  ("claude…english"); (c) on a narrow card drop the client's name entirely (own words only; the name in the hover).
  Ratify or redirect. **The hover's shape (fix leg 2a-F2, PROVISIONAL — the mid window's MID-4):** the label sits inside
  the choose band's button, so its own hover was subsumed; the band's ONE hover now reads the whole label on its own
  line, then "Choose this take — the note shows it (everywhere); ⌘⏎ from the keyboard" unchanged (no label: the sentence
  alone). Alternatives: (b) the label first in ONE line ("claude-code · english — choose this take…"); (c) move the
  label out of the button (its own hover; the band no longer clickable over the label).
- **MB-5, as built (batch 2a — VX-358):** canonical equality stays `edit_take`'s and `restore_commit`'s no-op rule; a
  re-spelled no-op (the same characters in other code points — NFC against NFD) answers
  `stored_text_normalization_differs: true` beside the stored text's `sha256`, absent otherwise; one sentence in both
  descriptions. Alternatives: (b) byte equality as the no-op rule — the re-spelling WRITES (commits, churn, an undo
  entry for an invisible change); (c) the same field under another name, or echoing the sent bytes' digest too.
- **MB-10 (batch 2a — VX-354's face, for the walk and batch 3):** the header's marks are row-size beside the
  heading-size book name (the Bookcase's and the Library's row size); a gathering's name wears its marks only while
  "appears in N gatherings" is open (rows drawn). A gathering wears NO ask glyph because no ask targets a gathering
  today (`MCPAskTarget`); when batch 3 (VX-549) makes a gathering a grant place, its ask's key decides whether the
  panel's `MCPAskGlyph(.book(id))` already marks it or a `.gathering` target is owed.
- **MB-11 (rider candidate + copy, batch 2a):** Read mode's takes view cuts a take's label the same one-run way
  (`ReadTier/ReadTakesView.swift:108`) — `TakeLabelLine` would serve it in one line; NOT seated (another surface; her
  word to ride). The two new model-facing sentences (VX-365's on `add_note_to_book`, VX-358's `spellingSentence`) join
  VX-234's copy list.
- **MB-6, as built (batch 2b — VX-394): NO App Nap guard.** App Nap lowers priority and delays timers; it never
  suspends a process or closes a socket, so it can make an answer late, never end a connection — and "MCP server
  disconnected" is the stdio shim EXITING, which happens only when the app closes the socket (or the client kills the
  shim). No traced road from throttling to a drop, so `ProcessInfo.beginActivity` would fix nothing it can name, and its
  `.userInitiated` form would hold her Mac awake while an AI sits connected. Ratify, or name an observed case to trace.
- **MB-7, sharpened (her hands, batch 2b):** on the AIR — (1) Settings ▸ Protection: is that library in **Castle**? In
  Castle the SCREEN LOCK always locks the library (not dial-dependent — decision 18) and the idle dial (On this Mac,
  default 10 minutes, counted from her own use of Variorum, never the AI's calls) does too; Standard never locks. (2)
  Settings ▸ MCP ▸ **Activity** on the Air, at today's two drops: "claude-code was disconnected when the library locked
  or closed" = the lock road (by design, A-8); "claude-code disconnected" = the client's side ended it (Claude Code, its
  process, or a kill). That one look decides the Air's story. (3) Her call on the reconnect options (A) shim reconnect
  with replay · (B) say why before the close · (C) docs only · (D) fewer locks — the BATCH 2b RECORD's section; the
  implementer's read is (C) now, (B2) if wanted, (A) only with the MCP-blind design event accepted.
- **MB-12 (PROVISIONAL, batch 2b — the quit's line):** built as P-VX394-5 says — a QUIT logs nothing, now every time
  (since VX-348's fix leg it logged "…when the library locked or closed" whenever the connection's end beat the
  process's exit). Alternative (b): a quit says that line too (MCPSpec's "every connection that named itself leaves ONE
  line", without the quit exception) — buildable at `applicationShouldTerminate`'s road AFTER its decline decision (so a
  cancelled ⌘Q never claims a drop), off the main thread and awaited like the lock road; one async hop on ⌘Q only while a
  client is connected.
- **MB-13 (proposed tickets, batch 2b — traced, unobserved, DEFERRED):** (i) **the dead listener** — the accept loop
  returns on EMFILE/ENFILE/ENOMEM/ENOBUFS, poll's EAGAIN or a listener error and nothing tells the host or the door:
  "running" while no new client is served; the shape: retry the transient class, a fatal exit closes the listener and
  flips the host to failed, the door adopts it, her words for "stopped by itself" (Bug · Suspected · MCP · Low). (ii)
  **the door's toggle races** — a stale start's completion clears `starting` for its replacement (a double start that can
  end "couldn't start: another Variorum is already serving mcp.sock" beside a serving listener), and a stale start that
  wins the bind fails the new host with that same false reason; the flag's half is a one-line reorder, the pin needs a
  start-timing seam (Bug · Suspected · MCP · Low).
- **MB-14 (her face call, batch 2b):** the status line says "running" of the SERVER and nothing of the clients, so after
  an unlock it read true while her client's connection was dead (the Clients row's "last seen …" and Activity's line
  are where it shows). Option: the status line carries the live count ("running · 1 client connected" / "running · no
  client connected"). Not built.
- **MB-15 (the orchestrator's evidence call, for her eyes):** batch 2b's optional Castle lock GUI leg was SKIPPED — a live Castle walk trips [cyber] on Fable (the standing safeguard), and the Mac pin `everyRoadThatClosesTheLibrarySaysEachConnectionsEndOnceThroughTheProductionTeardown` drives every lock road (crossing · Lock Now · idle · sleep) on a real Castle library through the production teardown factory, which the orchestrator judges sufficient evidence of the lock-road drop lines. If you want the GUI confirmation too it is a 5-second ⌃⌘L on any Castle library (Activity then shows "…locked or closed"), or an Opus-hand walk leg at the next window.
- **MB-16 (PROVISIONAL, batch 3 — VX-549's W1):** a gathering as a PLACE is reached by its own grant OR its WING's
  grant at that grant's rung (as a book is), so a wing write-new grant may write a new note into a gathering of its wing
  (no new reach — it could already mint in the wing and tag) and the shared icon on a gathering under a wing grant says
  the wing grant's rung (VX-185's "read, whatever the wing grant's" flipped). Alternative (b): wing grants keep reading a
  gathering as facts at READ only; writing into it takes a gathering grant (a wing-grant `create_note` into a gathering
  then refused with a worded sentence). Ratify or redirect.
- **MB-17 (PROVISIONAL, batch 3 — MB-10's question answered):** an ask on a gathering keys as its READING (`.book(id)`):
  the gathering rows' existing glyph marks it, no new `MCPAskTarget` case, no face change. Alternative (b): a
  `.gathering(id)` target, every gathering face asking with it (more faces, same pixels).
- **MB-18 (offer, batch 3 — not built):** a gathering's own place doors — Book Settings' "Shared with" row + Share… on a
  gathering, a gathering row menu's Share with AI… — are not built ("expand no other road"); the grant sheet's WHERE (and
  Change… / Share another place…) is its road. Say the word and they ride (the P-1 registry's `.mcpShareBook` family).
- **MB-19 (copy, her pass — batch 3):** the new words, all PROVISIONAL: the sheet's "A gathering", "“X” — the notes its
  rule gathers now, as your tags change", the star why ("Its rule needs a starred note, and only you can star one — so a
  client can read and suggest here, but not write new or edit."), the row footing "read and suggest only", the archived
  note; the confirm's clause ", including notes its rule gathers later"; the write-new rung sentence; the wire refusal
  "Its rule needs a starred note, and only the author can star one."; the guide's places card and fourth card;
  `MCPSession.instructions`' "A gathering grant reaches the notes its rule gathers now; create_note into one applies
  its tags." (2,988/3,000); the list_books / create_note / import_document description sentences. They join VX-234's
  copy list.
- **MB-20 (rider candidates, batch 3 — traced, not built):** `duplicate_note {book_id: <gathering>}` and
  `add_note_to_book {book_id: <gathering>}` answer the one not-shared shape even to a client that can read the gathering
  (the VX-273-era posture: the book road, unchanged). Honest options: a worded "a gathering holds no notes — tag the
  note instead" refusal where the client can read it, or the wire's collect road (R98's apply-what-the-rule-needs on an
  existing note — `collectPostIntoSmartReading`, without the star). A VX-368 parity item; never seated without her word.
- **MB-21 (design note, batch 3):** the sheet's gathering rows carry no note count (an assembly per gathering, at sheet
  open — the books' count is a membership read); the Bookcase's own gathering counts exist if she wants them there.
- (Batch records may append more.)

## LEDGER

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Worktree + branch + in-flight row + Linear In Progress | orchestrator | DONE (`472ed9bfe` on main; branch pushed) |
| 2 | This plan file | orchestrator | DONE |
| 3 | Batch 1 (VX-516 · VX-515 · VX-512) | opus-implementer №1 | BUILT — `d0e7f1302` core · `965a05521` app; Mac run + walk PENDING (BATCH 1 RECORD, "For the orchestrator") |
| 4 | Batch 2a (VX-352 · VX-354 · VX-365 · VX-358) | opus-implementer №2 | BUILT — `15f94f154` VX-365 · `4d3f3f3d1` VX-358 · `3e1aaa26f` VX-352 · `e3d46b202` VX-354; Mac run + walk PENDING (BATCH 2a RECORD, "For the orchestrator") |
| 5 | Batch 2b (VX-394) | opus-implementer №3 | BUILT — `fcf13b569` pins (red) · `bf8fa207d` fixes (green); Mac run + walk PENDING (BATCH 2b RECORD, "For the orchestrator") |
| 6 | Batch 3 (VX-549) | opus-implementer №4 | BUILT — `b783533c9` schema · `0883d80c6` decide · `cc73fc8cf`/`45cb7ee93` wire · `18f46f182`/`1dfc1818f`/`66096499e` faces; Mac run + walk PENDING (BATCH 3 RECORD, "For the orchestrator") |
| 7 | Orchestrator acceptance walks (stage via coordinator) | orchestrator | NOT STARTED |
| 8 | The ladder (whole-run diff, fable-reviewer) | orchestrator | NOT STARTED |
| 9 | Closeout + handoff + QUESTIONS #243 | orchestrator | NOT STARTED |

## BATCH 1 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI walk, no stage claim (the
orchestrator's) — the Mac pins (`MCPGrantRoadsTests` ×6, the `TutorialMCPChapterTests` justified edit) are written and
COMPILED (`build-for-testing` green), their RUN PENDING the orchestrator's stage window (the list and command at "For the
orchestrator" below); no capture of any face; nothing in `Sync/`, `Server/`, custody, the synced schema or the editor
seam; no op-level guard on `grantMCPAccess(_:_:replacing:)` (the brief places the decision at the sheet's seam — MB-9);
VX-565 / VX-590 untouched (their symptoms recorded unchanged below).

*Implementer: `opus-implementer` №1 (xhigh), fresh session, 2026-10-27 overnight. Read in its own context before any
code: CLAUDE.md + its canon, `notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · Doors to the outside),
this plan IN FULL, `notes/SessionResiliencyProtocol.md`, `notes/plans/fixes/vx-348-prelaunch-sweep.md` §U5 + the U5
UNIT RECORD (VX-393's section, R-VX348-6, P-VX393-1…3), `notes/plans/fixes/vx-510-first-run-sync.md` "HER AIR REPORT"
items 1/5/6, and every code anchor the brief names. Lane: no `Sync/`, `Server/`, custody, synced schema or editor seam;
no `xcodebuild test`, no walk, no stage claim (the orchestrator's).*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (VX-516's headless red leg ran over the committed `d0e7f1302` —
  `MCPGrantChange.replacing`'s body reverted to `named`, the pre-fix sheet's pass-through — and was restored by
  `git checkout --`; `git diff` clean after; green again, `scratchpad/b1-logs/vx516-green2.log`.)
- **VX-516 (Change… on one place, confirmed on ANOTHER, revoked the first):** DONE — core `d0e7f1302` (the pure
  `Domain/MCPGrantChange` + `Tests/VariorumCoreTests/MCPGrantChangeTests.swift`); RED ON OLD verified
  (`scratchpad/b1-logs/vx516-red.log`: 3 of the 6 new tests red — her repro 5 issues, every Change… road 3, the
  decision table 8 — the 3 guards and VX-393's 8 green); 14 of 14 green after. The app wiring `965a05521`: the
  sheet's one act (`MCPGrantSheet.act` — pure; `submit()` performs exactly it), its title and its replaces line read the
  decision (the line NAMES whose grant, which place, how far, how long — `MCPPaneCopy.replacesLine(client:…)`); the
  receipt's Change… opening factored pure (`MCPDoor.receiptChangeOpening`). Mac pins `MCPGrantRoadsTests` — every
  road's opening by its own door's builder → `MCPGrantSheet.act` → the door → both wings stand — written and COMPILED
  (`build-for-testing` green, `scratchpad/b1-logs/mac-bft2.log`), their RUN **PENDING** the orchestrator's stage window.
- **VX-515 ask 1 (a visible add door):** DONE (`965a05521`) — `.mcpChangeClientAccess`'s verb "Share a place…"
  (`MCPPaneCopy.sharePlaceVerb`; PROVISIONAL MB-2) and its one opening home (`MCPGrantOpening.clientRow`); the new
  `.surface` capability `.mcpShareAnotherPlace` "Share another place…" on the Shared with AI tab
  (`MCPGrantOpening.shareAnotherPlace()` — WHO asked, nothing pre-filled, nothing replaced), drawn by the pure gate
  `MCPPane.offersShareAnotherPlace` (an approved client AND ≥1 listed grant); the guide's two lessons, the Settings
  catalog's Clients blurb and the approval lead say the new words (the guide pin `TutorialMCPChapterTests` gains the
  new door, a JUSTIFIED EDIT — the H pattern). Mac pins compiled, RUN **PENDING**.
- **VX-515 ask 2 (see everything granted):** DONE — VERIFIED, no fix owed: `Queries.mcpSharedGroups` lists every live
  grant of every client, one row per place (a bulk act one row with its members road), the pane's 5-act page + its
  "all N ›" road; headless guard `sharedWithAIListsEveryLiveGrantOfEveryClient` (green on both sides — her "doesn't
  show both" was VX-516's revoke).
- **VX-512 (a fresh library's silence):** DONE (`965a05521`) — one `ExplainerLine` in the pane's top section while the
  library has no client at all (`MCPPane.saysClientsBelongToTheLibrary` — pending + approved + denied = 0), words
  `MCPPaneCopy.libraryClientsSummary` / `libraryClientsDetail` (PROVISIONAL MB-3). Mac pin compiled, RUN **PENDING**.
- **Suites:** `swift build --build-tests` green; the targeted core suites green (14/14); the Mac app + test bundle
  compile (`build-for-testing` green, `scratchpad/b1-logs/mac-bft2.log`, no warning in a touched file); the WHOLE
  headless suite run at the end (`scratchpad/b1-logs/headless-all.log`): core **3441 tests / 458 suites passed** (5
  known issues, standing), StringsWorkbook **32 / 4 passed**, VariorumMCPTests **383 / 71 with ONE issue —
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`'s 15 s wall clock under the
  full-parallel run (23.3 s)**: the standing **VX-532** class (untouched by this batch — no `VariorumMCP` line changed),
  run ISOLATED green ×2 (`harness-isolated-1/2.log`: 3/1 passed, 2.1 s each). **PENDING:** the Mac pins' run (stage).

### VX-516 — THE TRACE (inputs → wrong state), road by road

Her act (2026-10-23, the Air, a fresh library after the 0.10 crossing; `vx-510-first-run-sync.md` HER AIR REPORT items
5/6): PlanetLillian already granted to claude-code (a standing wing grant); she shares a second wing. Every road that can
reach the grants store, PROVEN BY TEST (the brief's warning — never by reading the opening):

| Road | Opening it builds | What the confirm sent the op (pre-fix) | Pin |
|---|---|---|---|
| Clients row's door (was "Change…", now "Share a place…") | `client`, place nil, `replacing []` | `grantMCPAccess(_:_:)` — per place | headless `everyAddingRoadLeavesBothWingsStanding` (GREEN on both sides — the road always added); Mac `everyRoadConfirmedOnAnotherWingLeavesBothWingsStanding` |
| ⌥⌘A, an ask's answer | — (no sheet) / `.note(id)`, `replacing []` | `grantMCPAccess(_:_:)` — per place | headless guard (same) |
| Approve… with a grant on an approved client | `approving` | `approveMCPClient(_:granting:)` — per place | headless guard (same) |
| A place-door sheet (Library row, Book Settings, ⌘L) | `place`, `replacing []` | `grantMCPAccess(_:_:replacing: [])` — per place | headless guard (same) |
| **A Shared-with-AI row's Change…** (`MCPDoor.changeOpening(_:)`) | the grant's own place, `replacing [grant]` | **`grantMCPAccess(_:_:replacing: [grant])` WHATEVER place was confirmed** | headless `changeOnOneWingConfirmedOnAnotherLeavesBothWingsStanding` RED on old; Mac road pin |
| **A receipt's Change…** (`speakShared` → now `MCPDoor.receiptChangeOpening`) | the act's place, `replacing [act's grants]` | **the same pass-through** | headless `everyChangeRoadConfirmedElsewhereRevokesNothing` RED on old; Mac road pin |
| **A shared icon's Change…** (`MCPReachPopover.changeOpening` — Bookcase, Library rows, ⌘L's wing rows, the in-note indicator) | the grant's own place, `replacing [grant]` | **the same pass-through** | headless (book → wing leg) RED on old; Mac road pin |
| An act's Change… (`changeOpening(act:)`) | `.notes(ids)` — WHERE said, never re-chosen | replaces the act — correct (T-U3-8) | headless `changeOnTheSamePlaceStillReplacesWhatItNames` (guard); Mac `anActsChangeKeepsItsReplace…` |

**The mechanism (stated once):** the one mint (`Operations.insertMCPGrant`) is per place — VX-393's standing replace is
keyed `client_id AND scope_kind AND scope_id` (`Operations+MCPGrants.swift:289–297`), and `uq_mcp_grant_standing_place`
is per client × place — so no ADDING road can touch another wing (every adding road proven above). The revoke came from
Change…: each Change… road opens THE grant sheet pre-filled on exactly the grant(s) it names and fills
`MCPGrantOpening.replacing` (T-U3-8); the sheet keeps WHERE open to a new pick; and `MCPGrantSheet.submit()` handed
`opening.replacing` to `grantMCPAccess(_:_:replacing:)` regardless of the place confirmed. Shared with AI's only doors
were Change… and Revoke, so her road to "another wing" was Change… on PlanetLillian's row (or its icon's popover, or a
receipt) with the other wing picked — PlanetLillian revoked, the other minted ("it keeps just changing what is shown …
the other one is revoked when I grant that one"). Whether her Air press was the row's, the popover's or the receipt's is
not knowable from here; all three share the one mechanism and the one fix. (The orchestrator's VX-510 reading — "the
Clients row's Change… replaces nothing" — was TRUE of that road; the road she could see, Shared with AI's Change…, was
the one that replaced.)

### VX-516 — THE FIX (PROVISIONAL MB-1)

- **The rule, pure and headless:** `Sources/VariorumCore/Domain/MCPGrantChange.swift` — `keepsReplacing(opened:confirmed:)`
  (both non-empty and confirmed ⊆ opened) and `replacing(_:opened:confirmed:)` (the named grants while kept, else none).
  A grant place is `scope_kind × scope_id` (Home `""` is a place; a kind is part of the place). An act's notes are said,
  never re-chosen, and a note gone since leaves the confirm (never adds one) — so ⊆, not =.
- **The one seam:** `MCPGrantSheet.act(opening:place:spec:noteIDs:rung:duration:)` (pure) decides the confirm's act on
  the very place(s) it grants (`.approve` · `.grantNotes(…, replacing:)` · `.grant(spec, replacing:)`); `submit()`
  performs exactly it. The title (`sheetTitle(changing:)`) and the replaces line read the same decision on the place
  picked NOW (`confirmedPlaces`), once the pre-fill has landed (`prefillApplied` — a Change… sheet's first frames never
  flash a new grant's title); the receipt says "Changed …" only when something was replaced (its `changed:` reads the
  decided `replacing`). Picking another place in a Change… sheet flips the title to "Grant access — ‹client›" and the
  replaces line goes; confirming mints a new grant beside the one it was opened on.
- **The replaces line NAMES what it replaces** (`MCPPaneCopy.replacesLine(client:place:rung:duration:)`): "Confirming
  replaces claude-code’s grant on the PlanetLillian wing — read, suggest, write new and edit, always." — the receipt's own
  shape; the plain sentence (`replacesLine`, unchanged) stays where no name is to hand.
- The receipt's Change… opening is factored pure (`MCPDoor.receiptChangeOpening`) so its road is pinned with the others.
- **Unchanged on purpose:** the core op `grantMCPAccess(_:_:replacing:)` still revokes the grants it is named — its
  pinned contract (`MCPOneGrantPerPlaceTests.changingAGrantToAnotherPlaceReplacesThatPlacesRowToo` stands, green); the
  place rule lives at the one confirm that names them (the brief's seam). An op-level guard is MB-9.

**Pins.** Headless (`Tests/VariorumCoreTests/MCPGrantChangeTests.swift`, suite "VX-516 — Change… replaces only its own
place; two wings stand together"): `changeOnOneWingConfirmedOnAnotherLeavesBothWingsStanding` (her repro + the second
hop: both wings live, each at its rung, both reached through the ONE rule, both listed) · `everyChangeRoadConfirmedElsewhereRevokesNothing`
(the receipt's, a popover's book→wing, a note's note→note) · `theDecisionTable` — RED ON OLD (behavioural revert of
`replacing` to the old pass-through over the committed `d0e7f1302`: 16 issues across exactly these three,
`scratchpad/b1-logs/vx516-red.log`), green after (`vx516-green2.log`). Guards, green on both sides by design:
`changeOnTheSamePlaceStillReplacesWhatItNames` (T-U3-8 kept: a lowered rung, a once → always on the same note, an act
with a note gone), `everyAddingRoadLeavesBothWingsStanding` (the brief's "prove each road"), and VX-515's
`sharedWithAIListsEveryLiveGrantOfEveryClient`. Mac (`App/Variorum/VariorumTests/MCPGrantRoadsTests.swift`, compiled,
RUN PENDING): `everyRoadConfirmedOnAnotherWingLeavesBothWingsStanding` (five openings, each by its own door's builder —
`MCPGrantOpening.clientRow`, `.shareAnotherPlace()`, `door.changeOpening(row)`, `MCPDoor.receiptChangeOpening`,
`MCPReachPopover.changeOpening` — through `MCPGrantSheet.act` and the real door: PlanetLillian stands every time) ·
`changeOnItsOwnPlaceStillReplacesAndNamesWhatItReplaces` · `anActsChangeKeepsItsReplaceAndTheApprovalRoadIsUntouched`.
Red-on-old for the Mac road pin is by construction (`MCPGrantSheet.act` did not exist; the old `submit()` passed
`opening.replacing`, which is the reverted decision the headless red leg ran).

### VX-515 — the two asks

- **Ask 1 (a visible add door):** `.mcpChangeClientAccess`'s verb is "Share a place…" (`MCPPaneCopy.sharePlaceVerb`;
  the id kept), opening from one home (`MCPGrantOpening.clientRow` — the pane's row and its "all N ›" sheet); a NEW
  `.surface` capability `.mcpShareAnotherPlace` "Share another place…" (`MCPPaneCopy.shareAnotherPlaceVerb`) under
  Shared with AI's rows, opening `MCPGrantOpening.shareAnotherPlace()` (WHO asked — the most recently granted client
  picked first — nothing pre-filled, nothing replaced), drawn by `MCPPane.offersShareAnotherPlace` (an approved client
  — VX-272's gate — AND ≥1 listed grant, so "another" is true); declared in `MCPPane.surfaceCapabilities` (the registry
  walk). The tab does not group by client, so the per-client door is the Clients row's. Every sentence naming the row's
  door follows: the approval lead (interpolates the constant), the Settings catalog's Clients blurb (the same), the
  guide's lesson 2 ("…with Share a place… to share more with it and Deny…") and lesson 5 (+ "Share another place… adds
  one beside them, so a client can reach several places at once."). The guide pin `TutorialMCPChapterTests`
  (`lessonFiveSharingFromWhereYouAre`) gains the new door from its registry home — A JUSTIFIED EDIT (the H pattern: the
  lesson names a new door). Mac pins `theClientRowsDoorAddsAndIsNamedForIt`,
  `sharedWithAIsAddDoorIsDeclaredOnceAndDrawnOnlyWhereItCanAct` — compiled, RUN PENDING.
- **Ask 2 (see everything granted) — VERIFIED, no fix owed:** `Queries.mcpSharedGroups` reads every live grant (not
  revoked, not a spent once) of every client; a book or wing grant is always its own row, note grants group only by one
  act's exact stamp (the bulk share), each row says place · kind chip · client · rung · duration; the pane shows the
  newest 5 acts and its "all N ›" road (R-13n-10) opens the whole list, and a grouped act's "and N more ›" names every
  member. Two wings for one client are two rows. Guard `sharedWithAIListsEveryLiveGrantOfEveryClient` (green on both
  sides). **Her "it doesn't show both" was VX-516's revoke — the listing never hid a grant.**

### VX-512 — a library's clients are its own (PROVISIONAL words MB-3)

The silence traced at VX-510 (her -32000 after Start fresh): the switch and every client binding are this library's
LOCAL-ONLY grants rows, so a library started fresh — or filled from the account by sync — has the server off and no
clients, and nothing said so. Built: ONE `ExplainerLine` in the pane's top section, under the server's own line, while
the library has no client at all (`MCPPane.saysClientsBelongToTheLibrary` — pending + approved + denied = 0; the store
has no "came from Start fresh" fact, and the sentence is true of every such library): "Clients belong to the library
they were set up in — run each one’s setup here." (371 pt at caption size — narrower than two summaries that already
pass the pane's 420 pt room); its (i): local-only, never synced or carried into another library, a fresh or synced
library begins with the server off and no clients, turn the server on, run each client's setup again from Connect. No
"AI" in the line (VX-272). The pane renders only over a ready library (Settings' panes need one), so the line never
speaks for a locked library. Mac pin `aLibraryWithNoClientSaysItsClientsAreItsOwn` (a real door: fresh → line; a
connection request → gone; the words fit one line, no "AI", no shouted word) — compiled, RUN PENDING. The release-notes
half is MB-3 (her drafting).

### Adjacent tickets (noted, not touched)

- **VX-565** (duplicate grant rows per client with different rungs): unchanged — the one-row rule is per place, and a
  once grant beside a standing one stays its own row (P-VX393-3). After VX-516, one client holding grants on two places
  shows two rows by design (two places) — not VX-565's class.
- **VX-590** (Shared with AI out of sight until a client has ever connected): unchanged — the new door draws only with an
  approved client; VX-512's line sits above the tabs, not on Shared with AI.

### Files touched

Core: `Sources/VariorumCore/Domain/MCPGrantChange.swift` (new) · `Tests/VariorumCoreTests/MCPGrantChangeTests.swift`
(new). App: `Core/Views/MCPShareRoad.swift` (`MCPGrantPrefill.places`, `MCPGrantOpening.clientRow` /
`.shareAnotherPlace`) · `Features/MCP/MCPGrantSheet.swift` (`confirmedPlaces`, `replacing`, `Act`, `act`, the faces,
`submit`) · `Features/MCP/MCPDoor+Share.swift` (`receiptChangeOpening`) · `Features/MCP/MCPPane.swift` (the two gates,
the Shared door, VX-512's line, the client rows' opening) · `Features/MCP/MCPPaneCopy.swift` (the named replaces line,
the two verbs, the library line, the approval lead) · `Registry/Capability.swift` + `Registry/CapabilityRegistry.swift`
(`.mcpChangeClientAccess`'s verb, `.mcpShareAnotherPlace`) · `Features/Settings/SettingsShape.swift` (the Clients blurb)
· `Features/Tutorial/TutorialSeeder.swift` (lessons 2 and 5). Tests: `VariorumTests/MCPGrantRoadsTests.swift` (new) ·
`VariorumTests/TutorialMCPChapterTests.swift` (justified edit). Commits: `eff04ea00` (LIVE STATUS) · `d0e7f1302` (core)
· `965a05521` (app) · this record's commit.

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

*Written at the ladder's L1 (round 1, finding 1 — batch 1 had drafted none; 2a/2b/3's blocks are the shape). The words in
quotes are the app's as built (`MCPPaneCopy`); each line is PROVISIONAL until QUESTIONS #243 rules MB-1/2/3.*

- **MCPSpec, W-UX-19's sentence (corrected — VX-516, PROVISIONAL MB-1):** "**every Shared-with-AI row carries Change…
  beside Revoke** (W-UX-19 ruled — the receipt's pre-filled REPLACE sheet, one grant or a whole act; a GONE target keeps
  Revoke only)" → append: "— **and Change… replaces only on the place it was opened on (VX-516, PROVISIONAL MB-1; the record
  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md` BATCH 1):** confirmed on that place (an act's notes, said and
  never re-chosen, over the notes that still stand), it replaces what it names, and its sheet's line names whose grant,
  which place, how far and how long ("Confirming replaces ‹client›’s grant on ‹place› — ‹reach›, ‹duration›."); a
  DIFFERENT place picked in its sheet makes a new grant there — the title reads "Grant access — ‹client›", the line goes,
  nothing is revoked and the grant it was opened on stands — on every Change… road (a Shared-with-AI row, a receipt, a
  shared icon's popover), so one client holds several places at once". (MB-1's consequence stated with it if ruled as
  built: Change… on an INERT row can no longer move that grant to another place — Revoke takes it.)
- **MCPSpec, the pane's sentence (the two doors — VX-515, PROVISIONAL MB-2):** "The pane: per-client grant rows (counts
  say "grants"), …" → after "per-client grant rows (counts say "grants")" insert: "— the client row's add door **Share a
  place…** (THE grant sheet with that client picked, nothing replaced) and, under Shared with AI's rows while an approved
  client holds at least one listed grant, **Share another place…** (the sheet asking WHO, the most recently granted client
  first, nothing pre-filled, nothing replaced); Shared with AI lists every live grant every client holds, one row per place
  (VX-515)". (Each is a `.surface` door declared in the capability registry — `.mcpChangeClientAccess` (its id kept) and
  `.mcpShareAnotherPlace`.)
- **MCPSpec, THE PANE AND THE SHARED ICON (VX-281's paragraph — the zero-state, VX-512, PROVISIONAL MB-3):** after "every
  explainer is ONE line with its whole text behind an (i) (`Core/Views/ExplainerLine`)." insert: "While the library has
  no client at all (none waiting, approved or denied), the pane's top section carries ONE such line under the server's —
  "Clients belong to the library they were set up in — run each one’s setup here." — its (i) saying that clients,
  approvals and grants are this library's local-only rows, never synced or carried into another library, so a library
  started fresh or filled by sync begins with the server off and no clients (VX-512)."
- **SurfaceContracts, Doors to the outside (the MCP door bullet): nothing owed** — its "One standing grant row exists per
  client and place." stays true (two places are two rows); the pane's doors and words are MCPSpec's, not a cross-cutting
  rule. (The closeout may add "a client may hold grants on several places at once" beside it if it reads that rule as
  cross-cutting — a judgment, not a correction.)
- **The dated entry + narrative → `notes/AppSpecRecord.md`:** VX-516's trace (the three Change… roads that passed
  `replacing` through on a re-picked place; her words "it keeps just changing what is shown though …" and her urgency
  "allowing multiple grants is one of my highest priorities …"), VX-515's two asks (the doors; the listing verified honest —
  her "doesn't show both" was VX-516's revoke), VX-512's silence; MB-1/2/3 as provisionals; MB-9 (no op-level guard) as an
  open option. MB-3's release-notes practice note is her release drafting, not canon.

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator): the product is prebuilt at
  `~/dev/variorum-vx-548/DerivedData/b1` from `965a05521`'s sources (this record's commit changes no code) —
  `cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  ~/dev/variorum-vx-548/DerivedData/b1 test-without-building` with `-only-testing:VariorumTests/<Suite>` for:
  `MCPGrantRoadsTests` (new) · `TutorialMCPChapterTests` (justified edit; lesson text) · `TutorialCurrencyTests` ·
  `MCPShareFacesTests` · `MCPGrantSheetTests` · `MCPPaneTabsTests` (**re-check `aFreshPaneOpensOnConnectWithItsCodeBlockInSight`
  — a fresh pane now carries VX-512's line above the tabs, ~one caption line; the VX-281 captures showed the block plus
  four more lines in sight, so ≥ 56 pt should hold — unmeasured here**) · `MCPPaneTests` · `CapabilityRegistryTests` (the
  new capability in the registry walk) · `SettingsShapeTests` · `CommitVocabularyTests` · `ChromeLineLimitTests` ·
  `MCPGatheringIconTests`. Read the `skipped:` lines (Swift Testing counts skips).
- **The walk (both voices, the dev store):** (1) Shared with AI with one wing granted → "Share another place…" under the
  rows → the sheet asks WHO → another wing → both rows stand. (2) A wing row's Change… → "Change access — ‹client›" and
  the NAMED replaces line → pick another wing → the title reads "Grant access — ‹client›", the line goes → confirm →
  both rows. (3) The same Change… kept on its own wing at a lower rung → one row, lowered (T-U3-8 kept). (4) Clients:
  the row reads "Share a place…". (5) VX-512's line needs a library with NO client — the dev store has clients, so it
  needs a fresh throwaway library or the gated capture road; the orchestrator's call.

## BATCH 2a RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`TakeLabelLineTests` ×3 new, `BookPanelMCPMarksTests` +4) are written and
COMPILED (`build-for-testing` green into `DerivedData/b2a`), their RUN PENDING the orchestrator's stage window (the list
and the walk legs at "For the orchestrator" below); no red PRODUCT was built for the Mac pins (VX-352's red leg is the
core's, run headless; VX-354's is by construction); no canon edit (MCPSpec / SurfaceContracts lines are the closeout's —
listed below); nothing in `Sync/`, `Server/`, custody, the synced schema or the editor seam; VX-566/567 and every other
open ticket untouched; the read tier's take label (`ReadTakesView`, the same one-`Text` tail cut) observed, NOT built.

*Implementer: `opus-implementer` №2 (xhigh), fresh session, 2026-10-27 overnight. Read in its own context before any
code: CLAUDE.md + its canon, `notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` IN FULL (The app · The note ·
The Bookcase and books · Doors to the outside among it), this plan IN FULL, `notes/SessionResiliencyProtocol.md`, the
vx-336 record's U5 STAGE RUN step 12 (VX-352's capture), U6b UNIT RECORD (the sweep table, OWED 2 — VX-354), U7 UNIT
RECORD's D-254-1 + BUILDER A's RECORD and OWED 3 (VX-358), U9 UNIT RECORD's traces + D1/F-1 (VX-365, OWED 4), and every
code anchor below. Lane: no `Sync/`, `Server/`, custody, synced schema or editor seam; headless `swift build`/`swift
test` + `xcodebuild build-for-testing` into `DerivedData/b2a` only — no `xcodebuild test`, no walk, no stage claim (the
orchestrator's). Batch 1's code and record untouched.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (VX-358's ran over `4d3f3f3d1`, VX-352's over `3e1aaa26f`, fix leg 2a-F2's
  over `2cee65c55`; each restored by `git checkout --`, `git diff` clean after, green again.)
- **VX-365 (`add_note_to_book`'s answer names no tags):** DONE (`15f94f154`) — core
  `Operations.addNoteToBookForClient` → `MCPBookAdd {membership, tagIDs, tagPaths}` (the same body and ONE undo entry;
  `addNoteToBook` keeps its signature and returns `.membership`), the tags composed INSIDE the act's transaction by
  VX-361's one rule (`mintedNoteTags`: the note's own tags in application order, read before the add, then the book's
  outflow in outflow order, each once); the wire answer gains `tag_ids` + `tags` (always present, `[]` when none); the
  description's "Returns JSON." gains create_note's tag sentence. RED ON OLD (`scratchpad/b2a-logs/vx365-red.log`, the
  pins run on the pre-fix tree `1fc292c02`): 3 of 4 failed, 8 issues — the guard green; GREEN after
  (`vx365-green.log`): the pins 4/4 + `MCPTagTruthServerTests`, `MCPWriteServerTests`, `MCPWingReachServerTests`,
  `MCPAdviceServerTests`, both neutrality walks, `MCPWriteActsTests`, `MCPEditActsTests`, `UndoQuietPressTests` — 94
  tests in 10 suites passed.
- **VX-358 (an NFC↔NFD re-spelling answers `changed: false` with a digest that isn't the sent bytes'):** DONE
  (`4d3f3f3d1`; revert run recorded `79d9ec85a`; PROVISIONAL MB-5) — canonical equality stays the no-op rule; the pure `StoredText.spellingDiffers(_:from:)`
  (canonically equal, UTF-8 bytes unequal) is read INSIDE each act's transaction (`MCPTakeEdit.spellingDiffers`,
  `MCPCommitRestore.spellingDiffers` — the sent text after the U+0000 strip, or the commit's text, against the stored
  take); the wire adds `stored_text_normalization_differs: true` (`MCPTextDigest.spellingDiffersKey`) ONLY then;
  `MCPToolCatalog.spellingSentence` in both descriptions. The digest stays the stored text's (VX-254 untouched). RED ON
  OLD (`vx358-red.log`, the wire pins on the pre-fix product `15f94f154`): 3 of 7 failed, 5 issues — the fixture's
  precondition and the 3 byte-unchanged guards green, and the old tree's `changed: false` + stored-digest assertions
  passed (the traced mechanism, observed); GREEN (`vx358-green.log`): the 8 wire pins + the pure table + the digest,
  null, edit, commit, catalog, neutrality and edit-act suites — 105 tests in 14 suites. THE BEHAVIOURAL REVERT RUN
  (`vx358-revert-red.log`): the wire suite 4 of 8 failed, 7 issues (the three answer pins + the description pin; the
  fixture precondition and the three byte-unchanged guards green) and the pure table 5 issues (its five true rows);
  restored → 9/9 green (`vx358-green2.log`).
- **VX-352 (Terminal's take card cuts "claude-code · english" to "claude-code · e…"):** DONE (`3e1aaa26f`; revert run
  recorded `92b6172d0`; PROVISIONAL MB-4) — the pure `Sources/VariorumCore/Domain/TakeLabelFace.swift`: `parts` splits a label at its first " · " into a
  YIELDING head (the client name — and the legacy "suggested" word with it) and a KEPT tail (the separator + the
  label's own words); `allocate` gives the kept part its whole width first and the head what is left. The card header
  (`TakeChooseHeader`, every fan style) draws the parts through `App/…/Features/Takes/TakeLabelLine.swift` — a custom
  `Layout` (`TakeLabelLayout`) that asks `allocate` for each part's width (each `Text` tail-truncates inside its own),
  `.help(label)` and the accessibility label the whole label; a label with no separator is one part (today's face).
  Pins: core `TakeLabelFaceTests` (4 — her capture's width in monospace columns; the legacy form; the parts and
  allocation tables) GREEN; `MCPTakeLabelFormServerTests.theTakeCardSplitsTheLabelWhereThisConventionPutsItsSeparator`
  (the card's separator and legacy word ARE the wire's) GREEN (`vx352-green.log`); Mac `TakeLabelLineTests` (3 — the
  real header swept in Terminal and Study, the placed widths read from the DEBUG `TakeLabelLayoutProbe`) COMPILED
  (`build-for-testing` green, `mac-bft1.log`), RUN **PENDING** the orchestrator's stage. THE BEHAVIOURAL REVERT RUN
  (`vx352-revert-red.log`; `allocate` back to reading order — the old face): 3 of 4 failed, 10 issues (the parts table
  green — the split alone changes no face); its `!= "claude-code · e…"` expectation FAILED, i.e. the reverted
  arithmetic reproduces her capture exactly; restored → 4/4 green (`vx352-green2.log`).
- **VX-354 (the Book Panel's header and gatherings wear neither mark):** DONE (`e3d46b202`) — `BookPanelModel` holds
  the READING reach (`readingReach`, `holdReadingReach` — `Queries.mcpBookReaches(readingIDs:)`: `decide` for the book,
  `decideGathering` for a gathering, behind `mcpReachStandings`' VX-272 gate; never `container`) over exactly the
  readings DRAWN — the pure `BookPanelBrain.markedReadings`: the shown book always, the gatherings' names only while
  "appears in N gatherings" is open; `BookPanelView` holds it by `.task(id:)` and the header and each listed gathering
  wear the Bookcase row's pair through ONE helper, `readingMarks` — `MCPSharedIcon` then `MCPAskGlyph(.book(id))` (no ask
  ever targets a gathering — `MCPAskTarget`, VX-273 — so a gathering's glyph is the calm no-view, as on the Bookcase).
  The pins' seam: `BookPanelView(…, gatheringsOpen:)` (default false — the panel still opens collapsed). Mac pins
  extend `BookPanelMCPMarksTests` (4 — the pure decision; the header's icon + book ask, each press its own, no open; a
  gathering's icon only through its wing, never a note or book grant, lit live by a wing grant; nothing read or drawn
  with no approved client even with the open book on) COMPILED (`build-for-testing` green, `mac-bft2.log`, no warning
  in a touched file), RUN **PENDING** the orchestrator's stage. Red-on-old by construction (the old panel neither held
  nor drew a reading's reach; `holdReadingReach` is new).
- **Suites (the end, on the final tree `e3d46b202`'s sources):** the WHOLE headless suite
  (`scratchpad/b2a-logs/headless-all.log`): core **3446 tests / 460 suites passed** (5 known issues, standing — batch
  1's 3441/458 + this batch's 5/2), StringsWorkbook **32 / 4 passed**, VariorumMCPTests **396 / 73 with ONE issue —
  `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`'s 15 s wall clock under the
  full-parallel run (19.8 s)**: the standing **VX-532** class batch 1 met too (no harness line changed), run ISOLATED
  green ×2 (`harness-isolated-1/2.log`: 3/1 passed, 2.1–2.2 s) — batch 1's 383/71 + this batch's 13/2. The Mac app +
  test bundle: `build-for-testing` **TEST BUILD SUCCEEDED** (`mac-bft2.log`, the final app sources), no warning in a
  touched file (the one `TakesBoardView.swift:2058` warning is pre-existing code — `TakeCardProbeSlot.space`, unchanged
  since HEAD). **PENDING:** the Mac pins' run (the stage).

### VX-365 — the trace (inputs → wrong output), the build

- **Inputs:** a client at write new on a note and a book whose OUTFLOW is a tag set (her rule editor's outflow
  chooser), `add_note_to_book {note_id, book_id}`.
- **The road:** `MCPWriteTools.perform`'s `.addNoteToBook` arm → `noteIntoBook` (both sides decided at write new) →
  `Operations.addNoteToBook` → the hand-add's ONE choke point `addPostToReading(db, …)` whose last line is
  `applyAutoTag` (`Operations+Intake.swift:310` — every outflow tag through the one application road, a worn one
  skipped). So the note WEARS the outflow's tags when the act lands.
- **Wrong output:** the answer was `{note_id, book_id, section_id?}` — no tag — so a client that meant to tag the note
  could not know the book already had (VX-361's class on the one road VX-361 left out — the U9 record's OWED 4).
- **The build:** VX-361's shape exactly (P-VX361-1 — the brief's "applied-then-outflow, each once"). Core
  `Operations.addNoteToBookForClient(…) -> MCPBookAdd {membership, tagIDs, tagPaths}` runs the SAME body with the SAME
  one undo entry (`addNoteToBook` now returns its `.membership`, its signature and every caller unchanged), reading the
  note's own live tags in application order BEFORE the add, then `mintedNoteTags(db, header: own, outflow:
  book.autoTagIDs)` AFTER it — inside the act's transaction, ∝ the note's applications, never a read after the commit.
  The wire answer gains `tag_ids` + `tags` (always present; `[]` when none). The description's "Returns JSON." gains
  create_note's own sentence shape ("…its tag_ids and tags (their paths) list every tag the note wears once it is in
  the book — its own first, then the book's outflow — so there is nothing to tag again.").
- **The fence, unchanged (the brief's "byte-unchanged"):** both decisions run before the act as before; a refused add
  is the ONE not-shared sentence, a hidden note's identical to a missing id's (the guard pin). The tags listed are the
  NOTE's — which a client allowed write new on that note can already read in `read_note`'s header.
- **Pins** (`Tests/VariorumMCPTests/MCPBookAddTagsServerTests.swift`, wire only — compile on both trees):
  `addingANoteToAnOutflowBookAnswersEveryTagItNowWears` (her tag + two outflow tags, the exact key set, ids and paths in
  the ruled order, the store agreeing, still one undo entry) · `anOutflowTagTheNoteAlreadyWoreIsListedOnceAtItsOwnPlace`
  · `aBookWithNoOutflowAnswersTheNotesOwnTagsOrNoneAndKeepsTheChapterEcho` (`[]` never absent; `section_id` stays) — RED
  ON OLD 3 of 4, 8 issues; GUARD `aRefusedAddAnswersTheOneNotSharedShapeWithNoTags` green on both sides.

### VX-358 — the trace, the build (PROVISIONAL MB-5)

- **Inputs:** a take stored "Um café." in one spelling (NFC U+00E9, say); a client sends `edit_take` with the other
  spelling (NFD e + U+0301) — or `restore_commit` of a commit holding the other spelling.
- **The road:** `Operations.editTakeUnderInsurance`'s no-op guard `variant.workingText != newText`
  (`Operations+MCPEdits.swift`) and `restoreCommitForClient`'s `variant.workingText != commitPoint.text`
  (`Operations+MCPNoteEdits.swift`) are Swift `String` equality — CANONICAL equivalence.
- **Wrong output (observed on the old tree by the pins' own assertions):** `changed: false`, nothing written (no bytes,
  no commit, no undo entry), and `sha256` — VX-254's digest of the STORED bytes — differs from the digest of what the
  client sent, with nothing saying why. Honest about the store; surprising to an agent proving its write by digest.
- **The build (the brief's default):** canonical equality STAYS the no-op rule (an invisible re-normalization never
  rewrites prose, churns, or mints commits and an undo entry). The pure `StoredText.spellingDiffers(_:from:)`
  (canonically equal AND UTF-8 bytes unequal) is read INSIDE each act's transaction — the sent text after the U+0000
  strip (so a null-only difference is the null count's, never this), or the commit's text — into
  `MCPTakeEdit.spellingDiffers` / `MCPCommitRestore.spellingDiffers` (always false when `changed`). The wire adds ONE
  key, `stored_text_normalization_differs: true` (`MCPTextDigest.spellingDiffersKey` — its one home), only then; absent
  otherwise, so every other answer is byte-unchanged (the guards pin the exact key sets). `sha256` stays the stored
  text's (VX-254's definition untouched). One shared sentence (`MCPToolCatalog.spellingSentence`, reading the key) in
  both tools' descriptions, no other tool's.
- **The sweep (every tool that answers a `sha256`, × whether a canonical no-op can meet it):** `add_take`, `add_takes`,
  `create_note`, one-document `import_document`, `insert_blocks`, `duplicate_note` — each MINTS, never short-circuits,
  so the stored bytes are the sent bytes (minus U+0000, VX-357's own key) — SAFE, no change. `edit_take` and
  `restore_commit` — the two canonical no-ops — FIXED (pinned). `read_note`'s `ids_only` digests what is read — SAFE.
  The other no-op acts that compare text canonically (`set_take_label`, the renames, `set_block_name`, comment edits)
  answer no digest — nothing for a client to mismatch; out of VX-358's scope, unchanged.
- **Pins:** wire `Tests/VariorumMCPTests/MCPSpellingNoOpServerTests.swift` —
  `editTakeSendingAnotherSpellingIsANoOpThatSaysTheSpellingsDiffer` (exact keys; store bytes kept; no commit; no undo
  entry) · `editTakeSendingNFCOntoAnNFDTakeSaysTheSpellingsDifferToo` ·
  `restoringACommitSpelledOtherwiseIsANoOpThatSaysTheSpellingsDiffer` ·
  `bothToolsDescriptionsSayTheSpellingRuleAndNoOtherDoes`; GUARDS (green both sides)
  `theFixturesTwoSpellingsAreCanonicallyEqualAndByteDifferent`, `everyOtherEditTakeAnswerKeepsItsExactKeys`,
  `aNullCharacterOnlyNoOpSaysTheNullsAndNotTheSpelling`, `everyOtherRestoreCommitAnswerKeepsItsExactKeys`; core
  `Tests/VariorumCoreTests/StoredTextSpellingTests.swift` `theTable` (NFC/NFD both ways, the Ångström singleton,
  Hangul, reordered marks → true; byte-identical, different words, case, a trailing space, a compatibility ligature →
  false). Red on old 3 of 7 (5 issues, the description pin added after); the behavioural revert 4 of 8 + the table's 5.

### VX-352 — the trace, the build (PROVISIONAL MB-4)

- **Inputs:** an AI take labelled `claude-code · english` (VX-267's `‹client› · ‹label›`); Takes mode, Terminal voice,
  a margin-grid card (her U5 STAGE RUN step 12 capture, `live/t/02-u5a-A-card-crop-block1`).
- **The road:** `TakeChooseHeader` (`TakesBoardView.swift`) drew `Text(label).lineLimit(1)` beside "choose" and a
  `Spacer` — ONE run, truncated at its TAIL by SwiftUI.
- **Wrong output:** "choose claude-code · e…" — the client's name whole, "english" (what tells two takes apart) cut.
  Study's proportional face fit it whole.
- **The build:** the pure `Domain/TakeLabelFace` (core — headless-pinned): `parts` splits at the FIRST " · " into a
  YIELDING head (the client's name; the legacy `suggested` word folds into it, so `‹client› · suggested · ‹label›` keeps
  `‹label›` too) and a KEPT tail (the separator + the own words); a label with no separator, a separator with nothing
  before it, or nothing after it, is ONE kept part (today's face). `allocate` gives the kept part its whole width FIRST,
  the head what is left. `TakeLabelLine` (app) draws each part as its own one-line `Text`, laid out by
  `TakeLabelLayout` (a custom `Layout` whose widths ARE `allocate`'s over the parts' ideal widths), `.help(label)` (the
  surface's one hover idiom) and the whole label as the accessibility label. Narrowing reads "claud… · english", then
  "… · english", and only then " · engl…". Every fan style's card shares the header, so all four get it. A label of
  hers that holds " · " splits the same way (only which side yields first is at stake; the hover is always whole).
- **Why a Layout, not two `Text`s with `layoutPriority`:** the pinned arithmetic is then the card's own — the pure
  rule is the layout, not a model of it — and the DEBUG `TakeLabelLayoutProbe` reads the widths the REAL header placed.
- **Pins:** core `Tests/VariorumCoreTests/TakeLabelFaceTests.swift` — `terminalsNarrowCardKeepsEnglishAndLetsTheClientNameYield`
  (monospace columns = Terminal: at 16 columns "claud… · english", never "claude-code · e…"; then 12/11/10/8; whole at
  21+) · `theLegacyFormKeepsItsOwnLabelToo` · `thePartsTable` · `theAllocationTable`; the cross-module
  `MCPTakeLabelFormServerTests.theTakeCardSplitsTheLabelWhereThisConventionPutsItsSeparator` (the card's separator and
  legacy word ARE `MCPWriteTools`'); Mac `App/Variorum/VariorumTests/TakeLabelLineTests.swift` —
  `terminalsNarrowHeaderKeepsTheLabelsOwnWordsWholeAndTheNameYields` (the real `TakeChooseHeader` swept from its ideal
  width down, Terminal: the own part placed whole whenever the line has room for it; widths where the name is cut
  exist) · `studyShowsTheWholeLabelWhenItFits` · `aLabelWithNoSeparatorIsOnePart` — compiled, RUN PENDING. RED ON
  OLD: the behavioural revert (reading-order allocation = the old one-run face) reproduces "claude-code · e…" exactly
  (3 of 4, 10 issues).
- **Observed, NOT built (another surface):** Read mode's takes view (`ReadTier/ReadTakesView.swift:108`) draws a take's
  label as `Text(tokens.chromeLabel(label)).lineLimit(1)` beside "✓ chosen" — the same one-run tail cut, on the read
  tier. Write's take panel (`WriteTakesPanel.swift:475`) draws it with no `lineLimit` (it wraps — no cut). A candidate
  rider/ticket for her (MB-11), never seated here.

### VX-354 — the trace, the build

- **Inputs:** an approved client with a book or wing grant (or the open book), a note in that book and in a gathering;
  the note open with its Book Panel.
- **The road:** `BookPanelView.header` drew the shown book's name (a `Text` or the switcher's `VoicedMenu`) and
  `gatheringsLine` the gatherings' names (`Button(gathering.name)` once the line is open) with no mark; the model held
  only its note rows' reach (`holdReach` over `entryIDs`) — the U6b sweep's two OUTSIDE rows (its OWED 2).
- **Wrong output:** the panel's own book — reached, icon'd on its Bookcase row — read as unshared at the panel's top;
  a gathering reached through its wing likewise; a waiting ask on the book never marked there.
- **The build:** `BookPanelModel.readingReach` / `holdReadingReach(ids)` — `Queries.mcpBookReaches(readingIDs:)`, THE
  read the Bookcase and the Library's book rows use (each reading by its kind's ONE rule: `decide` for a book,
  `decideGathering` for a gathering — so a note or book grant never icons a gathering, R-VX185-1; behind
  `mcpReachStandings`: no approved client, or no live grant with the open book off, reads nothing — VX-272). Its ids
  are exactly the readings DRAWN — the pure `BookPanelBrain.markedReadings(shown:gatherings:gatheringsOpen:)`: the shown
  book always, the gatherings only while their line is open — held by the view's `.task(id:)` (a book switch, the line
  toggling, a gathering coming or going restart it). ∝ a handful of readings; never `container`, so never at autosave
  rate. One helper, `readingMarks(id)`, draws the Bookcase row's pair in its order — `MCPSharedIcon` then
  `MCPAskGlyph(.book(id))` — after the header's name/switcher and after each gathering's name. A gathering's glyph is
  the calm no-view: no ask ever targets a gathering (`MCPAskTarget` has none — a gathering is no grant scope, VX-273),
  exactly as on the Bookcase, which draws the same pair on its gathering rows.
- **The sweep (the U6b table's two OUTSIDE rows, closed):** the header → **FIXED** (icon + book ask, pinned); the
  gatherings' names → **FIXED** (icon through the wing, pinned; ask glyph SAFE — no gathering ask target exists); every
  other row of that table unchanged (its note rows, collapsed chapter row, headings, "unfiled", the words).
- **Pins** (`App/Variorum/VariorumTests/BookPanelMCPMarksTests.swift`, an extension of VX-330's suite, its rig):
  `thePanelHoldsTheReachOfExactlyTheReadingsItNames` (pure) · `theShownBooksNameWearsItsIconAndItsWaitingAskAndEachPressIsItsOwn`
  (a book grant: two icons — header above the rows — and the book's ask on the header's row, icon first; each press its
  own; no open fires) · `aGatheringsNameWearsTheIconOnlyThroughItsWingNeverThroughANoteOrBookGrant` (book + note grants:
  the gathering's reach absent, two icons; a wing grant made while mounted lights the gathering's name on the held
  read, three) · `nothingIsReadOrDrawnWhileNoClientIsApproved` (a pending client, the open book ON: nothing held, no
  mark). ~~The VX-330 sweep pin stays as it was (it never starts the reading hold, so its count stays the note
  rows').~~ **WRONG — CORRECTED by the FIX LEG (2a-F1) below:** an unverified premise (VX-330's harness comment "the test
  host never fires a view's `.task`"); in the rig the view's `.task` DOES hold the reading reach, so the sweep saw the
  header's fifth icon. Compiled; RUN PENDING.

### Files touched

Core: `Sources/VariorumCore/Operations/Operations+MCPWrites.swift` (`MCPBookAdd`, `addNoteToBookForClient`) ·
`Sources/VariorumCore/Domain/StoredText.swift` (`spellingDiffers`) · `Operations+MCPEdits.swift` /
`Operations+MCPNoteEdits.swift` (`spellingDiffers` on the two results) · `Sources/VariorumCore/Domain/TakeLabelFace.swift`
(new). Wire: `Sources/VariorumMCP/MCPWriteTools.swift` (the add's answer) · `MCPWriteTools+Edit.swift` /
`MCPWriteTools+NoteEdits.swift` (the key) · `MCPTextDigest.swift` (`spellingDiffersKey`) · `MCPToolCatalog.swift` (the
add's sentence, `spellingSentence`). App: `Features/Takes/TakeLabelLine.swift` (new — the line, its layout, the DEBUG
probe) · `Features/Takes/TakesBoardView.swift` (the header draws the line) · `Features/BookView/BookPanelModel.swift`
(`markedReadings`, `readingReach`, `holdReadingReach`) · `Features/BookView/BookPanelView.swift` (`gatheringsOpen` seam,
the hold, `readingMarks` on the header and the gatherings). Tests: `Tests/VariorumMCPTests/MCPBookAddTagsServerTests.swift`
(new) · `MCPSpellingNoOpServerTests.swift` (new) · `MCPTakeLabelFormServerTests.swift` (+1) ·
`Tests/VariorumCoreTests/StoredTextSpellingTests.swift` (new) · `TakeLabelFaceTests.swift` (new) ·
`App/Variorum/VariorumTests/TakeLabelLineTests.swift` (new) · `BookPanelMCPMarksTests.swift` (+4, extension). Commits:
`1fc292c02` (LIVE STATUS) · `15f94f154` (VX-365) · `4d3f3f3d1` (VX-358) · `b374ce98a`/`79d9ec85a` (its revert run) ·
`3e1aaa26f` (VX-352) · its revert run's two record commits (`cdf517b5a`/`92b6172d0`) · `e3d46b202` (VX-354) · this record's
commit.

### Canon owed at the closeout (not this batch's to write — the two-file rule)

- MCPSpec (THE WIRE TOOLS…, VX-361's sentence): `add_note_to_book` answers `tag_ids` + `tags` by the same rule (its own
  tags first, then the outflow — VX-365); the write digest's clause: a canonical no-op of `edit_take`/`restore_commit`
  whose asked text is spelled otherwise answers `stored_text_normalization_differs: true`, absent otherwise (VX-358,
  MB-5).
- MCPSpec (THE PANE AND THE SHARED ICON): "…Book Panel rows (a collapsed one-note chapter row is its note's row and wears
  its marks — VX-330), the Book Panel's shown book and the gatherings its line names (VX-354), and ⌘L's wing rows…".
- SurfaceContracts, The note (Takes): a narrow take card keeps the label's own words and lets the client's name yield,
  the whole label on hover (VX-352, MB-4).

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator): the product is prebuilt at `~/dev/variorum-vx-548/DerivedData/b2a`
  from the final app sources (`e3d46b202`; this record's commit changes no code) — `cd App/Variorum && xcodebuild -scheme
  Variorum -destination 'platform=macOS' -derivedDataPath ~/dev/variorum-vx-548/DerivedData/b2a test-without-building`
  with `-only-testing:VariorumTests/<Suite>` for: **the pins** `TakeLabelLineTests` (new, 3) · `BookPanelMCPMarksTests`
  (7 = VX-330's 3 + 4); **the header's and the panel's neighbours** `TakeCardDoorTests` · `TakesCardHeightTests` ·
  `TakesMarginGridAlignmentTests` · `TakesBoardTests` · `TakesPresentationTests` · `TakesChooseRingTests` ·
  `FanReorderDoorTests` · `TakesLensFilterTests` · `TutorialTakesActsTests` · `BookPanelBrainTests` ·
  `BookPanelActingTests` · `BookPanelDeclarationTests` · `BookPanelDragGateTests` · `MCPSharedIconClickTests` ·
  `MCPSharedRowsTests` · `MCPSharedRowsRulesTests` · `CapabilityRegistryTests` · `ChromeLineLimitTests`; **the wire's
  Mac readers** `MCPWingFacesTests` · `TutorialMCPChapterTests`. Read the `skipped:` lines (Swift Testing counts skips;
  `TakesMarginGridCaptureTests` is a gated capture — not listed). Batch 1's `DerivedData/b1` is untouched by this batch;
  `b2a` CONTAINS batch 1's code too (built on its tip), so batch 1's list may also run from `b2a` if the window prefers
  one product.
- **The walk (dev store, both voices, a client approved):** (1) **VX-352:** a note with an AI take labelled
  `claude-code · english` (`add_take` with label "english", or Label… by hand) → Takes → margin grid in **Terminal**:
  the card header reads "choose claud… · english" (or "… · english") — never "claude-code · e…"; hover the label: the
  whole label; **Study**: whole, unchanged; also a stack and a carousel card. (2) **VX-354:** a note in a book shared at
  read (or its wing) → the Book Panel: the shown book's name wears the shared icon (hover names who; click opens the
  popover) and, with an ask raised on the book (a client's `create_note` into it at the read rung raises one), the
  pending glyph beside it; "appears in N gatherings ▸" → open → a gathering under a WING grant wears the icon, under a
  book grant only it wears none; the note rows unchanged. (3) VX-365/358 are wire-only and headless-proven; a
  real-client turn is optional (`add_note_to_book` into an outflow book → `tag_ids`/`tags`).

### FIX LEG (2a-F1 · 2a-F2 — the mid window's FINDINGS MID-1 and MID-4; implementer №2 resumed, 2026-10-27)

**NOT DONE BY THE FIX LEG (first line):** no Mac test run, no GUI, no stage — both legs' Mac proof (the edited VX-330
sweep pin's green; the band's AX help carrying the whole label) RIDES THE FINAL WINDOW. Pulled first (batch 3's
commits on the tree); nothing of batch 3's touched. The Mac product for the re-run: `DerivedData/b2afix`
(`build-for-testing` TEST BUILD SUCCEEDED, `scratchpad/b2a-logs/mac-bft-fix.log`; the only warning in a touched file is
the pre-existing `TakeCardProbeSlot.space` line, now `TakesBoardView.swift:2071`); `b1`/`b2a`/`b2b`/`b3` untouched.

**2a-F1 — FINDING MID-1 (`underABookGrantEveryNotesRowWearsBothMarksTheCollapsedChapterRowIncluded` red on the 2a
tree). THE TRACE — the red log's own words, not the finding's reading:** the isolated run
(`mid-bpm-iso1.log`) says **"(icons 5, asks 4)"** — the note rows did NOT lose their marks (four asks, and four of the
five icons); a FIFTH icon appeared. The only icon the panel can draw outside its note rows is VX-354's header icon
(`readingMarks(shown.id)`), which draws only when `model.readingReach[book.id]` is non-empty — written by
`holdReadingReach` alone, and the pin never calls it — so the view's own `.task(id: namedReadings(shown))` FIRED in the
rig (an `NSPanel` ordered front): VX-330's harness comment "the test host never fires a view's `.task`" — which batch 2a's
record repeated, unverified — is false here. Under the pin's BOOK grant the header reached its book and wore its icon
(VX-354 working as ruled); the pin counted every icon in the window and read "never a fifth". **Not a product
regression; a pin whose premise VX-354 changed.** **THE FIX — a JUSTIFIED EDIT of VX-330's pin (the H pattern; no product
line changes):** the reading hold started by hand too (so the count never rides on the `.task`); it now expects FIVE
icons (the four note rows' + the header's) and FOUR asks (no ask waits on the book); the header's icon is the topmost,
above every table-of-contents row's marks; the remaining four sit on four distinct rows, each sharing its row with its
note's ask; no chapter heading wears either — VX-330's claim unchanged, VX-354's header counted apart. The pin's doc
says all of this in place. **Red evidence:** the mid window's run of the unedited pin on `b2b` ("icons 5, asks 4", 3
issues, `mid-suites.log` + `mid-bpm-iso1.log`). **Green: PENDING — the final window** (`BookPanelMCPMarksTests`, 7 tests,
from `b2afix`). The four VX-354 pins were green in the mid window and are unchanged.

**2a-F2 — FINDING MID-4 (the whole-label hover may be dead).** **THE TRACE:** `TakeLabelLine` is content INSIDE the choose
`Button`'s label (`TakeChooseHeader`), and that Button carries its own `.help` (the choose sentence); a Button is met as
ONE element whose help is the Button's own — the walker's accessibility tree showed exactly that (one button, help = the
choose sentence, no element carrying the label), so the label's own `.help(label)` was subsumed: dead for an AX reader,
and not provably raised as a tooltip either (synthetic pointers raise none). **SHADOWED — fixed (PROVISIONAL, under
MB-4):** the band's ONE `.help` now carries the whole label on its own line, then the band's sentence unchanged — the
pure `TakeLabelFace.hover(label:act:)` (core); `TakeChooseHeader.chooseHelp` / `chosenHelp` (the old sentences, byte for
byte) and `bandHelp(isChosen:label:)` (the view's one call); the inner `.help(label)` removed (the line keeps the whole
label as its accessibility label). A take with no label (or a blank one) hears the band's sentence exactly as before. Why
this shape: the whole label is hoverable over the WHOLE band (the cut label included) without a second hover region
inside one button and without displacing the choose sentence; and it is the one help an AX reader meets, so the final
window can verify it as the walker tried to. **Pins:** core `TakeLabelFaceTests.theBandsOneHoverCarriesTheWholeLabelThenTheActsSentence`
GREEN (`fix-f2-green.log`: 5/5 + the label-form suite 3/3); Mac `TakeLabelLineTests.theHeadersHoverCarriesTheWholeLabelAndKeepsTheChooseSentence`
(the exact strings, both states, no-label byte-unchanged) COMPILED, run PENDING. **Red-on-old — THE BEHAVIOURAL REVERT
RUN** (announced `d388bdfb9`; `hover` forced to `return act`, the old band's hover):
`fix-f2-revert-red.log` — the core pin RED on exactly its two label rows (2 issues), its three no-label rows green (the
old sentence IS the no-label answer); restored by `git checkout --`, `git diff` clean, green again (`fix-f2-green2.log`:
5/5 + 3/3). **Final-window check:** the take card header button's AX help reads "claude-code · english⏎Choose this take
— …" (and a real hover shows both lines — her 5-second hand-check if the walker's pointer can't raise tooltips).

**Suites (the fix leg's end, on the merged tree — batches 1 + 2a + 2b + 3 + this leg, `3440bf92d`'s sources):** the WHOLE
headless suite (`scratchpad/b2a-logs/fix-headless-all.log`): core **3463 tests / 463 suites passed** (5 known issues,
standing), StringsWorkbook **32 / 4 passed**, VariorumMCPTests **411 / 75 with ONE issue — the standing VX-532
wall clock** (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 23.1 s under the
full-parallel run), ISOLATED green ×2 (`fix-harness-isolated-1/2.log`: 3/1, 2.1–2.2 s). The Mac app + tests:
`build-for-testing` into `DerivedData/b2afix` TEST BUILD SUCCEEDED (`mac-bft-fix.log`). *(L1 note: two load-sensitive
flakes are standing — VX-532 and VX-607 — a full-parallel failure in either is re-run isolated before it counts;
ENVIRONMENT TRAPS.)*

**For the final window (the orchestrator's):** from `DerivedData/b2afix` — or the window's merged product — re-run at
least `BookPanelMCPMarksTests` (7: VX-330's 3 with the sweep's justified edit + VX-354's 4) and `TakeLabelLineTests`
(4: the three placed-width pins + the band's help strings), with 2a's neighbour list above; the walk adds the band's
AX help (or her hand-check) for the whole label.

## BATCH 2b RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`MCPStopRoadsDoorTests` ×3) are written and COMPILED (`build-for-testing`
into `DerivedData/b2b`), their RUN PENDING the orchestrator's stage window (the list at "For the orchestrator"); NO App
Nap guard (`ProcessInfo.beginActivity`) — the trace found no road from throttling to a closed connection (MB-6); NO
reconnect machinery — options only (the brief's ruling 3); NOTHING against A-8 (the door never survives a lock — the
brief's ruling 1); two traced dishonest-status corners DEFERRED, not fixed (the dead listener, the door's toggle races —
each with its mechanism and a proposed ticket, MB-13); her Air never probed (MB-7 is her look); no canon edit (the
closeout's — listed below); nothing in `Sync/`, `Server/`, custody, the synced schema or the editor seam.

*Implementer: `opus-implementer` №3 (xhigh), fresh session, 2026-10-27 overnight. Read in its own context before any
code: CLAUDE.md + its canon, this plan IN FULL, `notes/MCPSpec.md` IN FULL, `notes/SessionResiliencyProtocol.md`, the
vx-348 record's §U5 (the client-session report verbatim) + the U5 UNIT RECORD's VX-394 sections (the trace, P-VX394-1…6,
the fix leg `0ebf5c926`, THE U5 BATCH + LIVE ROUND, the U5 adjudications, the ladder's NIT 3), QUESTIONS #233 (P-VX394
still PROVISIONAL — her product call (a)/(b)/(c) still open), SurfaceContracts' protection bullet (VX-445's lock road),
and the code anchors below. Lane: headless `swift build`/`swift test` + `xcodebuild build-for-testing` into
`DerivedData/b2b` only. One read-only Sonnet lookup for external facts (Claude Code's disconnect/reconnect behaviour,
App Nap, AF_UNIX across sleep, the MCP spec's close/ping/stdio rules) — its facts cited below with their sources.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (The red leg needed none: the pins ran against the committed pre-fix
  behaviour, the one new API — `MCPServerHost.stopWithTheProcess` — a SEAM whose body WAS the old quit road,
  `stop(ending: .libraryClosed)`, and the DEBUG `stopWindowProbe` a no-op hook — commit `fcf13b569`.)
- **Preflight + the road map:** DONE (`20f1400f6`).
- **The host's three stop-road findings — pins RED ON OLD:** DONE (`fcf13b569`, WIP) — 3 of 6 red, 5 issues, the 3
  guards green (`scratchpad/b2b-logs/stoproads-red.log`).
- **…FIXED, green; the door's quit; the lock teardown as ONE factory; the Mac pins:** DONE (`bf8fa207d`) — headless 16/4
  green (`stoproads-green.log`); Mac pins COMPILED (`mac-bft2.log`), RUN **PENDING** the stage.
- **The sweep table · the pane-status trace · the App Nap verdict · the reconnect options · MORNING BUNDLE:** DONE
  (this commit) — below.
- **Suites:** DONE — the whole headless run on the final code (`headless-all.log`): core 3446/460 passed (5 standing
  known issues), StringsWorkbook 32/4, VariorumMCPTests 402/74 with the one standing VX-532 flake (green isolated ×2);
  VX-180/181's suites 30/4 green. **PENDING:** the Mac pins' run (the stage).

### THE SWEEP TABLE — every road that ends a connection × the ruled Activity line

The words (P-VX394-1, PROVISIONAL in #233): clientClosed "‹client› disconnected" · libraryClosed "‹client› was
disconnected when the library locked or closed" · serverOff "… when the MCP server was turned off" · overLimit "… after
a message over the size limit". Only a connection that NAMED itself (admitted past its setup key, `initialize` read —
P-VX394-6 + the ladder's clarification) has a line. Every lock road converges on ONE function, `AppBootstrap.lock()` →
`lockOnNewRoad` → `onWillLock` (production: `macLockTeardown` — `recordLibraryClosing` after the notes' savepoints and
before the store closes, then the services stop and `detach()`).

| # | Road (its trigger, in code) | Ruled line | Cell | Pin(s) |
|---|---|---|---|---|
| 1 | **Client closed** — the client quits, restarts its server, or its process ends → the reader's EOF → `MCPServerHost.ended` → `writeEndLine` | "‹client› disconnected", once | **PINNED-GREEN.** The b1 walk's live line "claude-code disconnected" IS the ruled clientClosed wording (pinned verbatim by `aConnectionsEndReadsInWords`), and it was this arm: the shim closed before the switch went off (a switch-off would have read "…when the MCP server was turned off") | headless `MCPConnectionEndServerTests.aClientThatClosesItsConnectionLeavesOneLineSayingSo`; Mac `MCPConnectionEndDoorTests.aConnectionsEndReadsInWords`; live (b1 walk) |
| 2 | **Server switched off** — Settings ▸ MCP's switch → `reconcileServer` → `stopServer(.serverOff)` (the host stopped and let go; each session writes its own end — VX-348's fix leg) | "…when the MCP server was turned off", once | **PINNED-GREEN** | headless `theServerSwitchedOffEndsEveryConnectionAndSaysSo`, `aStopThatLetsGoOfItsHostStillSaysEachConnectionsEnd`; Mac `theDoorsTwoStopRoadsSayTheirReasonsOnce` |
| 3 | **A message over the size cap** (16 MiB after admission) → the transport's flag → answered, closed | "…after a message over the size limit", once | **PINNED-GREEN** | headless `aMessageOverTheCapEndsTheConnectionAndSaysSo` |
| 4 | **Over the session cap** (a 17th connection) → `refuseOverCap` (answered with the cap's sentence, closed — never a session) | none (never admitted, never named itself) | **PINNED-GREEN** (new guard — the cell was by-construction only) | headless `MCPStopRoadsServerTests.pastTheSessionCapTheRefusedConnectionSaysNothing` |
| 5 | **Lock Library Now** — ⌃⌘L, the File menu, Settings ▸ Protection's button (`EditorCommands.swift:568`, `AppBootstrap.swift:957`) → `lock()` | "…when the library locked or closed", once, written while the store is open | **PINNED-GREEN** — the road was right; its production composition (an inline closure in `VariorumApp`) was reached by NO pin, so a deleted wire would have stayed green. Now ONE factory, `macLockTeardown`, driven end to end | Mac `MCPStopRoadsDoorTests.everyRoadThatClosesTheLibrary…` (leg 2: a real Castle library on the planted road, a real door + host + client); `MCPConnectionEndDoorTests.theLockRoadSaysTheConnectionsEndAfterTheSavepointsAndBeforeTheStop`; `RoadLockRouteTests.lockNowClosesACastleLibrary…` |
| 6 | **The idle-lock monitor** (Castle; this Mac's sealed minutes, default 10; counted from HER use of Variorum only — never a client's calls) → `relockIfIdle` → `lock()` | the same | **PINNED-GREEN** | Mac leg 3; `RoadLockRouteTests.theMonitorsLock…` |
| 7 | **The sleep monitor / the screen-lock monitor** (Castle — always on, decision 18; `NSWorkspace.willSleepNotification`, `com.apple.screenIsLocked`) → `relockIfPolicySays` → `lock()` | the same | **PINNED-GREEN** (the two subscriptions are VX-445's wiring — read, not driven) | Mac leg 4; `RoadLockRouteTests.theMonitorsLock…` |
| 8 | **Store close** — every re-keying reopen runs `onWillLock` before the pool closes: the crossings (Use Castle… · Use Standard… · Replace All Keys…) and the account acts through `reopenAround` (`AppBootstrap.swift:1244`), Make this my library (`:876`), a plain-text export brought in (`:741`) | the same | **PINNED-GREEN** (one representative driven; the rest share the line, read) | Mac leg 1 (Use Castle…, the crossings' seam) |
| 9 | **App quit** — `applicationWillTerminate` → was `door.detach()`: a stop "as the library closes" whose lines each session writes itself (VX-348's fix leg), racing the process's exit | **none** (P-VX394-5 — "a QUIT logs nothing") | **FIXED** — RED ON OLD: the old road logged `disconnect_library_closed` whenever the session's end beat the exit; now `door.quit()` → `MCPServerHost.stopWithTheProcess` forgoes every live line before the hang-up (a client that left first keeps its own line) | headless `aQuitSaysNothingForAConnectionItEnds` (RED → GREEN) + guard `aClientThatLeftBeforeTheQuitKeepsItsOwnLine`; Mac `MCPStopRoadsDoorTests.theQuitRoadStopsTheServerAndSaysNothing` |
| 10 | **A connection accepted WHILE a stop runs** (rows 2, 5–9) — the stop took its list of connections before its accept loop had stopped | the stop's own line | **FIXED** — RED ON OLD: the latecomer was never hung up (it outlived the stop, served on with the switch OFF) and never said its end; now the list is taken after the accept loop stops | headless `aConnectionAcceptedWhileTheServerStopsIsHungUpAndSaysWhy` (RED → GREEN; the DEBUG `stopWindowProbe` opens it in exactly that window) |
| 11 | **A re-attach to another session** (`attach` → `detach()` with no lock road before it — defensive: every session change runs `onWillLock` first today) | "…when the library locked or closed", once | **PINNED-GREEN** (new guard) | Mac `aDetachWithNoLockRoadBeforeItStillSaysTheLibraryClosedOnce` |
| 12 | **A crash / a force quit** — the process is gone | none possible | **SAFE by construction** (nothing is left to write; the next start sweeps every while-connected grant) | — |

### THE PANE-STATUS TRACE — "running" while stopped?

**The source.** The status line is `MCPPaneCopy.status(door.serverState)` (`MCPPane.swift:204`); `serverState` is
written only by the door: `reconcileServer` (off · waiting for the library · running once a host's start succeeds ·
failed) and `detach()` (`.waitingForLibrary` — "on · starts when the library is open" — or off).

**Her report's "running · socket in the app container" — the mechanism, not a dishonest status.** While the library is
locked the pane cannot be seen: the lock closes the Settings window and its content falls to the "Open the main window
first." stub (VX-224, `SettingsLockCloseTests`); and were it drawn, `detach()` left it at "on · starts when the library is
open" — now pinned on every lock road (the Mac leg's `closedHonestly`). At the unlock the window's ready re-attaches the
door and the server starts again: "running" is TRUE of the server. What died was the CLIENT's connection — and the status
line speaks only of the server. Where the pane does say it: the Clients row reads "last seen …", not "connected now"
(`door.connected` is emptied at the stop and refilled only by live sessions), and Activity reads "‹client› was
disconnected when the library locked or closed". Her reading was honest about the server and silent about the client —
a face question for her (MB-14), not a status bug.

**The trace's dishonest states (the brief: "if there is a state where the server is stopped and the pane would say
running, pin and fix"):**
- **FIXED — "running" while nothing can reach the server** (row 10's sibling, `bf8fa207d`): `stop()` unlinked the socket
  PATH unconditionally. The door's stale start — switch ON, OFF and ON again while the first start is still sweeping its
  grants (`reconcileServer`: the OFF let the first host go, so the ON makes a second while the first's detached start
  still runs) — races the new host for the path; when the new host binds first, the stale one's start hears "already served", fails, and its completion arm
  (`guard self.host === fresh else { fresh.stop() }`) stops it: the unconditional unlink removed the LIVE host's file.
  The new host's start then landed `.running` — "running · socket in the app container" — while every client's connect
  met ENOENT and its shim said "Variorum must be open". Now a host removes only the socket it bound, and before its
  listener closes (while its listener holds the path no other host can bind it — `MCPSocketRoad.listen`'s probe — so the
  file removed is always its own). Pin `aStopThatNeverServedLeavesTheServingHostsSocketInPlace` (RED ON OLD: "the serving
  host's socket is gone"); guard `aHostsOwnStopStillRemovesItsSocket`.
- **DEFERRED — a listener that dies by itself (M1).** The accept loop (`MCPServerHost.acceptLoop`) returns on any
  `poll` error but EINTR, any non-POLLIN event on the listener, and any `accept` error but EINTR/ECONNABORTED — EMFILE /
  ENFILE (descriptors exhausted, even for a moment), ENOMEM, ENOBUFS, poll's EAGAIN among them. Nothing then tells the
  host or the door: `_state` stays `.running`, the pane says "running", the listening descriptor stays open (connects
  queue in its 8-deep backlog and are never answered; the client times out at its 30 s connect), and a restart's probe
  would even hear that zombie as "another Variorum is already serving". UNOBSERVED, and its honest fix is a small design,
  not a line: retry the transient class (EMFILE/ENFILE/ENOMEM/ENOBUFS, poll EAGAIN) after a short pause; on a truly
  fatal exit close the listener and its socket, flip the host to failed and signal the door, which adopts the host's
  state on that signal — and the pane's words for "the server stopped by itself" are hers ("couldn't start: …" would be
  false). Proposed ticket (Bug · Suspected · MCP · Low), MB-13.
- **DEFERRED — the door's toggle races (M4).** In `reconcileServer`'s completion, `self.starting = false` runs BEFORE
  `guard self.host === fresh`, so a stale start's completion clears the flag for the host that replaced it; a reconcile
  during that host's start (any snapshot change) then starts it a SECOND time — its own live listener answers the second
  start's probe, so the host can end `.failed("another Variorum is already serving mcp.sock")` beside a listener that
  serves, and the pane says "couldn't start: another Variorum is already serving mcp.sock" while it serves (which
  completion lands last decides). And when the STALE start wins the bind (the mirror of the fixed case), the new host fails with that same
  false reason and the server stays down until the next snapshot change. Needs a quick OFF → ON while a start waits on
  the writer. The flag's half is a one-line reorder (clear `starting` only for the host it belongs to); the pin needs a
  start-timing seam the door doesn't have. Proposed ticket (Bug · Suspected · MCP · Low), MB-13.

### THE APP NAP VERDICT (MB-6) — not built; the trace says why

- **What "MCP server disconnected" is.** A stdio server's process EXITED: Claude Code's docs (code.claude.com/docs/en/mcp
  — "The server's process exits mid-session: Claude Code marks the server as failed. To start it again, select
  Reconnect…"). Our stdio server is the `variorum-mcp` shim, which exits only when its socket → stdout copy ends
  (`MCPShim.pump`): the app closed the connection, a read error, or stdout failed — or the client killed it.
- **What App Nap does** (Apple, Energy Efficiency Guide for Mac Apps, "App Nap"; WWDC13 session 209): lowers CPU and
  I/O priority and throttles/coalesces TIMERS ("we do not fire timers early: we only delay them"). Nothing in Apple's
  sources suspends a process or closes a socket. The host's accept loop blocks in `poll`, each reader in `read` — both
  wake on data, not on a timer; the shim is a command-line child of the client, never napped. **So App Nap can make an
  answer late; it cannot end a connection.** The host CAN be napped (a background, occluded app), but throttling is not
  a disconnect road.
- **The only road from "late" to "dropped" is the CLIENT killing a slow server** — and the facts don't carry it: Claude
  Code documents no keep-alive ping for stdio; its timeouts abort a call or a startup (`MCP_TIMEOUT` 30 s startup;
  `MCP_TOOL_TIMEOUT`; the per-call idle timeout, 30 min for stdio) — never a connected server. One user report (GitHub
  anthropics/claude-code #54544, closed not planned, no maintainer word) describes pings every ~5 min and a SIGTERM on a
  late pong — a lead, not a fact; and our reply rides no timer (a socket read wakes it), so a napped app answers late
  only by its lowered priority — App Nap's own timer delays are ~100 ms to seconds (WWDC13 209), never minutes. Even if such a kill happened, Activity now names it: a client-side kill reads "‹client›
  disconnected", a lock reads "…when the library locked or closed".
- **The lock road is the definite path that fits every fact** (VX-348 U5's trace, re-traced here on today's road: every
  trigger → `lock()` → `onWillLock` → the line → the stop), and her 2026-10-27 clue (the drops came when her Air locked)
  is that road IF the Air's library is in Castle (MB-7). Whether her ORIGINAL 3–4 AM night was the lock road needs that
  night's posture — unknowable here; no other traced road ends a connection from the app's side with the app alive.
- **Verdict:** the brief's conjunction is not met in the way that matters — no traced mechanism leads from throttling
  to a closed connection, so a `beginActivity` guard would fix nothing it can name (the hallucination guard), and it has
  a real cost: `.userInitiated` carries the idle-system-sleep-disabled bit, so it would hold her Mac awake for as long as
  an AI client sits connected. NOT BUILT. If a ping-kill is ever observed (an Activity "‹client› disconnected" at a
  moment she knows the client didn't quit), that is the mechanism to trace next.

### RECONNECT ERGONOMICS — investigated, proposed, NOT built (her call, MB-7)

**The facts** (the lookup, cited): Claude Code interactive marks an exited stdio server failed and does NOT reconnect it
(HTTP/SSE servers: five tries with exponential backoff; stdio: none — the docs' table; GitHub #43847, closed); `/mcp` →
Reconnect respawns it; `claude -p` / Agent SDK sessions restart a stdio server lazily on the next tool call. The MCP spec
has no close reason for a server to send (lifecycle: "No specific shutdown messages are defined") and no stdio
resumption — but its newest revision (2026-07-28, which Claude Code negotiates for stdio by default since 2.1.292) says
"If the server process exits unexpectedly, the client SHOULD restart it… the protocol is stateless", and that the stdio
framing "works unchanged over Unix domain sockets". A server's `list_changed` is honoured by Claude Code.

**The options (each with its cost; none built):**
- **(A) Shim-side reconnect with replay.** When the app ends the socket, the shim keeps its stdio open, waits for the
  socket to return, reconnects, re-sends its setup-key preamble, replays the client's original `initialize` (+
  `notifications/initialized`), swallows the server's second answer, and resumes pumping; requests in flight at the drop
  are answered with an error (or lost). The client never sees a drop and "always" grants work the moment she unlocks.
  Costs: the shim stops being MCP-BLIND (MCPSpec's A-2 shape — it must recognise, keep and replay the opening frames and
  filter one response: a design event); while the library is locked every call must be answered by the shim ("the
  library is locked") or hang — more MCP inside the shim; a replayed connection is a NEW connection to the server, so
  "until it disconnects" grants are already gone (swept at the start) while the drop is hidden from the client; and every
  handshake change (VX-180's probe; 2026-07-28's `server/discover`) must now be mirrored in the shim.
- **(B) Say why before the close.** (B1) The server sends each named connection one MCP log notification before the
  lock's hang-up ("Variorum's library locked — reconnect from /mcp once it is unlocked"): standard MCP, shim untouched;
  but Claude Code's display of server log messages is undocumented (may be invisible), and the 2026-07-28 revision
  removed `logging/setLevel` — a dead end there. (B2) The shim writes one stderr line as it exits ("Variorum closed the
  connection — reconnect with /mcp"): lands in Claude Code's MCP logs, not the chat; the shim cannot know WHY unless the
  app tells it out of band (a tiny shim↔app close-reason line before EOF — a private protocol, not MCP).
- **(C) Documentation only.** The guide's MCP chapter and `MCPSession.instructions` say it: "If Variorum's tools vanish,
  the library may have locked — tell the author; reconnect with /mcp once it's unlocked." (The instructions are at
  2,994 of 3,000 characters — room must be made; R-VX184-3.) Activity already says why on her side. Costs nothing; still
  one manual /mcp per lock.
- **(D) Fewer locks — her standing product call (#233, VX-394 "Needs Lillian"):** a connected client's calls count as
  use for Castle's idle dial, or a Castle setting "stay unlocked while an AI client is connected" (default off). It
  removes the idle-dial drops only — sleep and the screen lock always lock in Castle (decision 18). Relaxing a lock is
  author-only.
- **The implementer's read:** (C) now (a copy change for her pass) — it is honest and free; (B2) is the cheapest honest
  add if she wants the client side told; (A) only if she wants seamless and accepts the MCP-blind design event (and
  clients are moving toward restarting exited stdio servers themselves — 2026-07-28's SHOULD — which would make (A)'s
  value shrink); (D) stays hers.

### Files touched

Core/wire: `Sources/VariorumMCP/MCPServerHost.swift` (`halt` — the one stop; `stopWithTheProcess`; the DEBUG
`stopWindowProbe`) · `Sources/VariorumMCP/MCPSession.swift` (`forgoEndLine`). App: `Features/MCP/MCPDoor.swift`
(`quit()`, `detach(ending:)`, `stopServer(ending:)` optional) · `VariorumAppDelegate.swift` (`applicationWillTerminate`
→ `mcp.quit()`) · `MacWillLock.swift` (`macLockTeardown`) · `VariorumApp.swift` (wires `macLockTeardown` — behaviour
identical). Tests: `Tests/VariorumMCPTests/MCPStopRoadsServerTests.swift` (new, 6) ·
`App/Variorum/VariorumTests/MCPStopRoadsDoorTests.swift` (new, 3). Commits: `20f1400f6` (LIVE STATUS) · `fcf13b569` (the
pins, red) · `bf8fa207d` (the fixes, green) · this record's commits.

### Suites (the end, on the final code `bf8fa207d`)

- `swift build --build-tests` green; the new suite + its neighbours 16/4 green (`stoproads-green.log`).
- **VariorumMCPTests whole: 402 tests / 74 suites, ONE issue** — `MCPHarnessTimeLimitTests.aPeerThatNeverAnswers…`'s
  15 s wall clock under the full-parallel run (22.7 s): the standing **VX-532** class batches 1 and 2a met (no harness line
  changed), green ISOLATED ×2 (`harness-isolated-1/2.log`: 3/1, 2.2 s each). Batch 2a's 396/73 + this batch's 6/1.
- **VX-180 / VX-181 no-regress** (`MCPDiscoverProbeServerTests`, `MCPShimClosedAppTests`, `MCPPreInitializeWindowTests`,
  `MCPShimTests`): **30 / 4 green** (`vx180-181.log` — U5's same count): the closed-app sentence and the mid-session
  connect unchanged.
- **The whole headless run** (`headless-all.log`, `swift test` on the final code): VariorumCoreTests **3446 tests / 460
  suites passed** (5 known issues, standing — batch 2a's same count: no core line changed), StringsWorkbook **32 / 4
  passed**, VariorumMCPTests **402 / 74 with the same ONE VX-532 issue** (19.6 s this run; green isolated above).
- Mac: `build-for-testing` into `DerivedData/b2b` — **TEST BUILD SUCCEEDED** (`mac-bft2.log`), no warning in a touched
  file. **PENDING:** the Mac pins' run (the stage).

### Canon owed at the closeout (not this batch's to write — the two-file rule)

- MCPSpec, "A dropped connection says why (VX-394)": after the four ends — "a quit says none (P-VX394-5); a stop ends
  every connection it served, one accepted while it stops included, and a server removes only its own socket".
- (Nothing for AppSpec or SurfaceContracts — no face changed.)

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator): `DerivedData/b2b` holds batch 1's, 2a's AND 2b's code (cloned from b2a,
  rebuilt incrementally from the tip `bf8fa207d`; this record's commits change no code), so the mid window can run every
  list from ONE product — `cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  ~/dev/variorum-vx-548/DerivedData/b2b test-without-building` with `-only-testing:VariorumTests/<Suite>` for 2b's:
  **the pins** `MCPStopRoadsDoorTests` (new, 3); **the neighbours** `MCPConnectionEndDoorTests` · `MacWillLockTests` ·
  `RoadLockRouteTests` · `SettingsLockCloseTests` · `AutosaveRegistryLifecycleTests` · `LandingOffsetTests` ·
  `FirstRoundAfterTheReopenTests` · `MCPPaneTests` · `MCPPaneTabsTests`. Read the `skipped:` lines. (2a's list may run
  from `b2b` too; `b2a` is untouched.)
- **The walk legs (dev store):** (1) THE QUIT — a client connected (the shim driven directly with the pane-copied key,
  as the b1 walk did), quit the Debug app, relaunch: Activity shows NO line for that connection (P-VX394-5). (2) THE
  LOCK — needs the dev store in Castle (`~/.variorum/dev-castle.env`; restore the posture after): a connected client,
  ⌃⌘L, unlock → Activity "claude-code was disconnected when the library locked or closed" (once), the status line
  "running" again, the Clients row "last seen …". (A LIVE CASTLE WALK trips [cyber] on Fable — hand it to Opus, per
  the standing safeguard.) Leg (2) is optional: the Mac pin drives every lock road on a real Castle library.

### MORNING BUNDLE items born here (folded into §MORNING BUNDLE above)

MB-6 (as built: not built) · MB-7 (sharpened: the exact look) · MB-12 (the quit's line) · MB-13 (two proposed tickets) ·
MB-14 (the status line's client count).

## BATCH 3 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`MCPGatheringGrantFacesTests` ×6 new; the justified edits and deliberate
flips listed below) are written and COMPILED (`build-for-testing` into `DerivedData/b3`), their RUN PENDING the
orchestrator's stage window; NO place doors for a gathering (Book Settings' Shared-with row, a row menu's Share
with AI… — the grant sheet's WHERE is its road, "expand no other road": MB-18); `duplicate_note` / `add_note_to_book`
with a gathering's id keep their not-shared answer (MB-20); no canon edit (MCPSpec's superseding lines are DRAFTED
below for the closeout, not applied); nothing in `Sync/`, `Server/`, custody, the synced schema or the editor seam
(the migration is the LOCAL-ONLY grants family's).

*Implementer: `opus-implementer` №4 (xhigh), fresh session, 2026-10-27 overnight. Read in its own context before any
code: CLAUDE.md + its canon, this plan IN FULL (the BATCH 3 BRIEF and HER SITTING), `notes/MCPSpec.md` IN FULL,
`notes/SurfaceContracts.md` (The app · The Bookcase and books · Doors to the outside), `notes/SessionResiliencyProtocol.md`,
the VX-549 ticket body (her sitting, read-only), AppSpec §7's reading/`query_spec` contract, and the code anchors:
`Domain/RuleGrammar.swift`, `Domain/GatheringMint.swift`, `Domain/MCPGrantRule(+Wing).swift`,
`Queries/MCPGrantQueries.swift`, `Queries/MCPShareQueries.swift`, `Queries/ReadingAssembly.swift`
(`gatheringMembership` — the ONE membership function), `Queries/GatheringMintQueries.swift`,
`Operations/Operations+SmartCollect.swift` (`newPostInGathering` — the human door the wire mirrors),
`Operations/Operations+MCPGrants.swift`, `Operations/Operations+MCPWrites.swift`, `Persistence/MCPGrantSchema.swift` +
`Migrations.swift` (v1_24 → v1_32), `VariorumMCP/MCPGrantAuthority.swift`, `MCPReadTools.swift`, `MCPWriteTools.swift`,
`MCPWriteSupport.swift`, `MCPToolCatalog.swift`, `MCPSession.swift`, and the VX-273 / VX-185 pins. Lane: headless
`swift build`/`swift test` + `xcodebuild build-for-testing` into `DerivedData/b3` only (cloned from `b2b` by APFS
clone; `b2b` untouched — the build refused to touch paths outside its root). No subagent.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (Two revert runs, each over a committed state and restored by `git
  checkout --`, `git diff` clean after: the decide layer's over `0883d80c6`, the wire's over `45cb7ee93`.)
- **Preflight:** DONE (`dd1c3fb6c`).
- **1 · Schema (`v1_33_mcp_gathering_grants`, its own commit):** DONE (`b783533c9`).
- **2 · The decide layer:** DONE (`0883d80c6`; the bound-gathering title `1dfc1818f`).
- **3 · The wire:** DONE (`cc73fc8cf` + `45cb7ee93`).
- **4 · The faces:** DONE (`18f46f182`; the Mac icon pin's flip `66096499e`).
- **5 · Suites + Mac build-for-testing:** DONE — counts under "Suites" below. **PENDING:** the Mac pins' run (the stage).

### THE DESIGN, as built (the decisions the brief left to the build)

1. **The schema (v1_33, local-only).** `mcp_grant.scope_kind`'s CHECK gains `'gathering'` (`scope_id` = the
   gathering's `reading.id`). SQLite cannot alter a CHECK, so the table is REBUILT on v1_18's road: every row copied
   with its `rowid` (Shared with AI orders one stamp's act by `rowid`; ⌥⌘A's newest-grant tiebreak reads it), the two
   indexes re-made with their v1_24 / v1_30 text byte-unchanged. Nothing references `mcp_grant` (no FK, no trigger).
   `uq_mcp_grant_standing_place` keys a place as client × KIND × id, so a gathering is one more place under VX-393's
   one standing row with no change — proven by test (one standing per client × gathering; a once beside it; another
   client's; the same id string under another kind).
2. **The membership — the ONE function, assembled at read.** `MCPGrantRule.NoteFacts` gains `gatheringIDs`: the
   live gatherings, among those a live grant NAMES (any client's — the facts are the store's; the rule reads only the
   asking client's grants), whose assembly holds the note NOW. `Queries.mcpNoteFacts` derives it (its one derivation
   site) by asking each granted gathering's `gatheringMembership` — the very conditions `assembleReading` and the
   search composer read (wing, rule, hide-owned, living unarchived posts) — over exactly the notes being decided:
   `mcpGatheringMembersSQL`, page-driven (`json_each` CROSS JOIN, each note a PK seek — plan-pinned). An archived,
   rule-less or malformed gathering (the function's nil) or a FENCED one (a stale Private stamp / 'daily' marker — no
   op mints either on a gathering) holds nothing, so its grant reaches no note. P1: one read of the live gathering
   grants (∝ her grants); per granted gathering its row, its fence, ONE statement over the ids decided; with no
   gathering granted, one read and nothing else (pinned by statement capture).
3. **The rule.** `reaches`: a gathering grant reaches a note iff the facts name it (the fence first — a fenced note is
   reached ONLY by a per-ask note grant, so every fence key wins: the Private MARK, its own or through a Private book;
   ⌘J entries; the daily Journal's members — all answering the one not-shared shape; a tag named "private" is just a
   tag — pinned); a gathering grant never reaches a book. `best`: note < book < gathering < wing. **The PLACE**
   (`decideGathering(rung:consumes:)`, defaults READ / non-consuming so every old caller is byte-identical): its OWN
   grant or its WING's grant at that grant's rung (the least that suffices, once spent per AF-7), or the open book at
   READ; a note or book grant never (R-VX185-1 kept); fenced → the one answer. **W1 — PROVISIONAL MB-16:** a wing
   grant reaches a gathering place at ITS rung, as it reaches a book (so a wing write-new grant may write a new note
   into a gathering of its wing — no new reach: it could already mint in the wing and tag), flipping VX-185's "read,
   whatever the wing grant's". `reach(gathering:)` is read off it at every rung.
4. **write_new (her door's shape, without the star).** `create_note` and `import_document`'s one-document form take a
   gathering's id in `book_id` (`MCPWriteTools.into(…, admitsGathering: true)` → `intoGathering`; `create_section` and
   `set_book_rule` keep the book road). The PLACE is decided at write new (consuming); refused, it answers EXACTLY as a
   book id does (`MCPRefusalCopy`'s `.book` noun — the client sent `book_id`, and a hidden gathering must read as a
   missing id), its row logged as the BOOK id sent (`list_my_activity` never tells hidden from missing — pinned), the
   just-in-time ask raised ON the gathering where it exists unfenced. Allowed, the act is
   `Operations.MCPNoteDestination.gathering` inside `mintNoteEntry`'s ONE transaction: her door's refuse-before-mint
   (`Queries.gatheringMintOutcome(…, starrable: false)` — the ONE planner, `newPostInGathering`'s), the note minted
   bookless in the gathering's wing (live-or-Home), the plan's tags through `insertPostTag` (the ONE application road —
   living books hear them, pinned), then the document's own header tags, then the belt (`matchesRule` — a header tag can
   break a NOT; a miss unwinds the whole mint), ONE client-named undo (`registerMintedContainerEntry`). The answer is
   VX-252's shape exactly (`note_id`, `block_ids`, `tag_ids`, `tags`, `blocks` — no key more), `tags` VX-361's listing
   (header first, then the rule's). Activity logs the landed act on the gathering ("made the note “X”").
5. **The star (her ruling).** `GatheringMint.outcome` learns `starrable:` (default true — her doors byte-unchanged) and
   `Blocker.needsStar`, defined as "blocked without the star, PLANNED with it" (a wrapper re-runs the walk with the star
   allowed), so `(★ OR #a) AND NOT #a` is a star rule while `★ AND NOT ★` is unreachable. With the star forbidden an
   any-of group takes a TAG option where it has one (`★ OR #a` lands wearing #a on the wire — pinned). The pure
   functions on the grammar: `GatheringMint.tagsCanSatisfy(term)` (the planner with every tag live, the star
   forbidden; NOT terms count as tag-satisfiable — a fresh note meets `NOT #x` and `NOT ★`) and `needsStar(term)` —
   the unit table `GatheringTagsSatisfyTests`. The wire's refusal is her door's sentence through the ONE chain
   (`MCPWireRefusalCopy` words `smartFilterUnsatisfiable` as its `reason`, R-13n-4's "exactly as they speak to you"):
   "Its rule needs a starred note, and only the author can star one." — never the not-shared shape, nothing minted, the
   once grant unspent, no ask (pinned). Every other blocker speaks her door's words too ("Archived — unarchive it to add
   notes." — pinned).
6. **The wire's reads.** `list_books`' prefilter takes gathering grants (the gathering lists, counted through the
   per-note fence); `list_notes(book_id: gathering)` and `search(book_id: …)` already went through `decideGathering`
   (now its own grant too); `list_notes()` takes each granted gathering's assembly as candidates; `search`'s reached
   scopes take a standing gathering grant outside the reached wings (a note it assembles is not searched again on its
   own note grant's scope); `list_wings` is untouched (a gathering grant lists no wing — pinned empty). The catalog:
   `everyScope` gains `.gathering` (every note-acting tool acts on its members), `list_books` / `create_note` /
   `import_document` list under it; the book-only acts do not (P-2).
7. **The faces.** The grant sheet's WHERE: "A note · A book · A gathering · A wing" — the gathering on the same
   `SearchPicker` (`MCPGrantPicker.gatheringArrangements`: Starred quick, then a–z; each row's footing: a non-Home
   wing, its shelf, "archived", and "read and suggest only" where its rule needs a star). A star-rule gathering offers
   read and suggest only (`MCPGrantPicker.offeredRungs(needsStar:)`), with `MCPPaneCopy.starRuleWhy` under HOW MUCH;
   an archived one says it gathers nothing until unarchived. Spec, confirmed place, receipt place, prefill
   (`MCPGrantPrefill.gathering`, `.place(of:)` — ONE switch every Change… road reads), VX-516's keep-or-drop rule on
   the new kind (pinned). The shared icon: a directly granted gathering through the grown `decideGathering`
   (`mcpBookReaches` — rows drawn only, nothing read with no approved client, unchanged gates), its own grant named as
   no "through"; member note rows through the one `decide`, the why naming the gathering (core-pinned). Core read for
   the sheet: `Queries.mcpGrantableGatherings` (live, unfenced; `needsStar`, `archived`; no note count — that would be
   an assembly). **The ask's key (MB-10's question) — PROVISIONAL MB-17:** an ask on a gathering keys as its READING,
   `.book(id)` (`MCPAskQueue.target`) — the key every reading row's glyph already asks with (the Bookcase's and
   Library's gathering rows, the Book Panel's gatherings line) — so no new `MCPAskTarget` case and no face change;
   `askStanding`, `durations(for:)` (a fenced gathering offers nothing) and the ask copy (title, reach line, fenced
   lead, receipt) learn it. Copy for the kind chip, the write-new rung sentence ("it can also make new notes in it,
   wearing the tags its rule needs, and apply tags" — the W-UX-14 truth pin extended to the new scope), the live-reach
   clause (", including notes its rule gathers later"), the inert detail, Activity's fallback noun. The field guide's
   two cards (lesson 3's places card and its fourth card) and `MCPSession.instructions` name the gathering grant
   (PROVISIONAL copy, MB-19). **`MCPSession.instructions` = 2,988 characters (measured), ≤ 3,000** — the delta fit
   inside the sentences this change owns (no trim of anyone else's).
8. **A bound gathering** (bound into a book — `convertSmartReadingToCurated`): its grant reaches nothing (a gathering
   grant never reaches a book; the facts read the kind) and its place reads gone (`mcpScopeTitle(.gathering)` checks the
   kind) — pinned; the un-bind brings it back.

### THE DELIBERATE FLIPS (VX-273's facts-only rule, superseded — her sitting 2026-10-27, RATIFIED; each cites it in its comment)

| Pin | Was | Now |
|---|---|---|
| `MCPWingReachServerTests.aGatheringStaysNoGrantsScopeAndNoWritesTarget` (wire) → renamed `aGatheringIsAGrantScopeAndANewNotesTargetButNoBookStill` | no grant may name a gathering; `create_note` into one under a wing EDIT grant answered "as a book that isn't there" | a grant NAMES it (its own kind — the book road still refuses its id); `create_note` into it LANDS wearing the rule's tag (W1, MB-16); `add_note_to_book` on it still answers as no book |
| `MCPAdviceServerTests` (the advice's tool names + facts) | "A wing grant also reads that wing's gatherings … none is ever granted alone"; names `list_books`; "a note, a book or a wing" | "A gathering grant reaches the notes its rule gathers now; create_note into one applies its tags."; names `create_note`; "a note, a book, a gathering or a wing" |
| `TutorialMCPChapterTests` (Mac, compiled) | the fourth card "a gathering is never shared on its own: no grant may name one" (truth leg `#expect(throws:)`) | the card teaches the gathering grant; truth: a grant NAMES it and "follows your tags" (tag in → reached, untag → out) |
| `MCPGatheringReachRuleTests.theTable` / `.itAgreesWithDecideGatheringEverywhere` (core) | a gathering's reach is READ "whatever its rung" | the grant's rung (own or wing); the agreement grid read at every rung, the pool grown with gathering grants (8,192 worlds) |
| `MCPGatheringReachTests.aWingGrantIconsTheWingsGatheringsAndNamesTheWing` (core) | the icon's rung `.read` under a wing edit / write-new grant | the wing grant's rung (`.edit`, `.writeNew`) |
| `MCPGatheringIconTests` (Mac, compiled) | the popover says "(read)" / "read · always" under a wing edit grant | the wing grant's rung's words |

Justified edits (not flips — the sweep or the scope set grows): `MCPGrantRuleTests.theBoundaryHoldsOverEveryGrantShape`
(the gathering scope joins every grant shape; 3·8·… worlds) · `MCPAskAndReceiptTests` (the W-UX-14 truth pin's scope
loops + `.gathering`) · `MCPWireRefusalSweepTests` (`smartFilterUnsatisfiable` now reachable and worded: 33→32 unspoken,
75→76 walked) · `MCPShareFacesTests` (messages only: the gathering's place doors are unbuilt, MB-18 — the
assertions hold as they were).

### PINS (red-on-old evidence)

- **Schema** `Tests/VariorumCoreTests/MCPGatheringGrantSchemaTests.swift` (4): `aStoreBeforeTheGatheringPlaceKeepsEveryGrantRowExactly`
  (rows + rowids + both indexes' text exact across v1_33; FK check clean) · `theFamilyStaysLocalOnlyAndTheMarkerStays` ·
  `theCheckAdmitsAGatheringAndStillRefusesAnythingElse` · `theStandingPlaceIndexHoldsAGatheringAsOnePlaceUnchanged`.
  RED ON OLD (`scratchpad/b3-logs/schema-red.log`, the migration's registration reverted): 3 of 4, the CHECK refusing
  'gathering'; the rows-exact guard green both sides by nature.
- **Decide** `Tests/VariorumCoreTests/MCPGatheringGrantDecideTests.swift` (9): `aGatheringGrantReachesItsAssemblyAndMovesWithHerTagging`
  · `theFactsAgreeWithTheAssemblyNoteForNote` (the ONE function, across subtree / other-wing twin / ★ rule / hide-owned)
  · `everyFenceKeyWinsAndTheFenceIsTheMarkNeverATagNamedPrivate` · `aGatheringThatAssemblesEmptyReachesNothingAndADeadOneToo`
  (archived, rule-less, malformed, fenced, bound, dead) · `theGrantOpNamesAGatheringAndRefusesWhatIsNotOne` (VX-393 on
  the new kind; inert under a fence) · `thePlaceIsReachedByItsOwnGrantOrItsWingsAtTheRungNeverANoteOrBookGrant` ·
  `theSheetsOfferIsEveryUnfencedGatheringWithItsStarShape` · `aGrantedGatheringAndItsMembersWearTheMarkThroughTheOneRule`
  · `theMembershipReadIsPageDrivenAndAbsentWithNoGatheringGrant` (P1: statement capture + query plan). Red on old by
  construction (no gathering scope); BEHAVIOURAL REVERT RUN (`decide-revert-red.log`: the facts derivation a no-op +
  `decideGathering` without the gathering's own grant): 6 of the then-7 red, 18 issues; restored, green.
- **The pure table** `Tests/VariorumCoreTests/GatheringTagsSatisfyTests.swift` (3): `theTable` (22 rules × tags-can-satisfy
  × needs-a-star, never both) · `herDoorsStillStarAndNeverSayNeedsStar` · `theWirePlanTakesATagWhereHerDoorWouldStar`.
- **Wire** `Tests/VariorumMCPTests/MCPGatheringGrantServerTests.swift` (9): `aGatheringGrantReadsListsAndSearchesItsAssemblyAndNothingElse`
  · `suggestActsOnAMemberAndANoteOutsideTheRuleAnswersAsMissing` · `editAppliesToMemberNotesThroughTheExistingGuardsAndStopsWhenTheNoteLeaves`
  · `writeNewMintsBooklessInTheWingWearingTheRulesTagsWithOneClientNamedUndo` · `importDocumentIntoAGatheringWearsTheHeadersTagsThenTheRules`
  · `aRuleThatNeedsAStarRefusesWriteNewInWordsAndWritesNothing` · `aStarOrATagRuleTakesTheTagOnTheWire` ·
  `aWriteIntoAGatheringPastTheRungAsksOnItAndAHiddenOneAnswersAsMissing` ·
  `anArchivedGatheringReachesNothingAndRefusesTheMintInHerWordsAndADeadOneIsGone`. Red on old by construction;
  BEHAVIOURAL REVERT RUN (`wire-revert-red.log`: `intoGathering` bypassed, `list_books`' prefilter without gathering
  ids, the refusal arm off): 7 of 9 red, 15 issues (suggest/edit green — they live on the decide layer, reverted on its
  own); restored, green.
- **Mac** `App/Variorum/VariorumTests/MCPGatheringGrantFacesTests.swift` (6, COMPILED, RUN PENDING):
  `aGatheringPickedIsAGatheringGrantOnItsOwnPlace` · `changeOnAGatheringGrantReplacesOnlyOnItsOwnPlace` ·
  `aStarRuleGatheringOffersReadAndSuggestOnlyWithTheWhy` · `theGatheringPickerIsStarredThenAToZWithEachRowsFooting` ·
  `anAskOnAGatheringKeysAsItsReading` · `theWordsAGatheringGrantWears`. Red on old by construction.

### Files touched

Core: `Persistence/MCPGrantSchema.swift` (`v1_33DDL`) · `Persistence/Migrations.swift` (`v1_33_mcp_gathering_grants`) ·
`Domain/MCPGrantRule.swift` (`ScopeKind.gathering`, `NoteFacts.gatheringIDs`, `reaches`, `best`, `decideGathering`,
`reach(gathering:)`) · `Domain/GatheringMint.swift` (`starrable:`, `needsStar`, the wrapper, `tagsCanSatisfy`,
`needsStar(_:)`) · `Queries/GatheringMintQueries.swift` (`starrable:`) · `Queries/MCPGrantQueries.swift`
(`mcpGatheringMemberships`, `mcpGatheringMembersSQL`, `mcpScopeTitle`, `mcpGrantInertFence`, `MCPGrantableGathering`,
`mcpGrantableGatherings`) · `Queries/MCPGrantPlaces.swift` (`gatherings`, `place(_:)`, `gatheringDistinguishers`) ·
`Queries/MCPShareQueries.swift` (`isOwn`, docs) · `Operations/Operations+MCPGrants.swift` (the gathering scope) ·
`Operations/Operations+MCPWrites.swift` (`MCPNoteDestination.gathering`, the mint's gathering arm). Wire:
`VariorumMCP/MCPGrantAuthority.swift` · `MCPReadTools.swift` · `MCPWriteTools.swift` (`admitsGathering`,
`intoGathering`) · `MCPWriteSupport.swift` (the refusal words) · `MCPToolCatalog.swift` (`everyScope`, three tools'
scopes and descriptions) · `MCPSession.swift` (the instructions). App: `Core/Views/MCPShareRoad.swift` ·
`Core/Views/MCPSharedIcon.swift` · `Features/MCP/MCPGrantSheet.swift` · `MCPGrantPicker.swift` · `MCPPaneCopy.swift` ·
`MCPDoor.swift` · `MCPDoor+Share.swift` · `MCPAskQueue.swift` · `MCPAskSheet.swift` · `MCPPane.swift` ·
`Features/BookView/BookPanelView.swift` + `BookSettingsSheet.swift` (comments) · `Features/Tutorial/TutorialSeeder.swift`
(the two cards). Tests: the four new files above; edits to `MCPGrantRuleTests`, `MCPGatheringReachRuleTests`,
`MCPGatheringReachTests`, `MCPWingReachServerTests`, `MCPAdviceServerTests`, and Mac `TutorialMCPChapterTests`,
`MCPAskAndReceiptTests`, `MCPWireRefusalSweepTests`, `MCPShareFacesTests`, `MCPGatheringIconTests`. Commits:
`dd1c3fb6c` · `b783533c9` · `0883d80c6` · `cc73fc8cf` · `45cb7ee93` · `18f46f182` · `1dfc1818f` · `66096499e` · this
record's commit.

### Suites (the end, on the final code `66096499e`)

- **The whole headless run** (`scratchpad/b3-logs/headless-all.log`): VariorumCoreTests **3462 tests / 463 suites
  passed** (5 known issues, standing) — batch 2b's 3446/460 + this batch's 16/3; StringsWorkbook **32 / 4 passed**;
  VariorumMCPTests **411 / 75 with ONE issue — the standing VX-532 flake**
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 20.2 s under the
  full-parallel run; no harness line changed), green ISOLATED ×2 (`harness-isolated-1/2.log`: 3/1, 2.2 s) — batch 2b's
  402/74 + this batch's 9/1.
- **Mac:** `build-for-testing` into `DerivedData/b3` — **TEST BUILD SUCCEEDED** (`mac-bft5.log`, the final tree); no
  warning in a touched file (the `MCPGrantPicker.swift` `durations(connected:)` isolation warning is pre-existing — it
  stood at :201 in batch 2b's log). **PENDING:** the Mac pins' run (the stage).

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

- **MCPSpec, the grants sentence:** "per CLIENT × SCOPE (note · book · wing)" → "per CLIENT × SCOPE (note · book ·
  gathering · wing — v1_33, VX-549)".
- **MCPSpec, replacing VX-273's clause** ("a wing grant (or the open book) reads its wing's GATHERINGS as facts (listed,
  assembled, searched, shown — never a grant's scope or a write's target; VX-273)") with: "**A GATHERING IS A GRANT
  PLACE (VX-549 — her sitting 2026-10-27, superseding VX-273's facts-only rule; the record
  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md` BATCH 3):** a gathering grant reaches the notes its rule
  assembles AT READ TIME, through the ONE membership function — reach moves with her tagging; every fence key wins (the
  Private MARK, never a tag named "private"; the daily Journal's and ⌘J entries), answering the one not-shared shape; an
  archived, rule-less or malformed gathering assembles empty, so its grant reaches nothing. The gathering itself is
  reached by its own grant or its wing's, at that grant's rung (PROVISIONAL MB-16), or the open book at read — never a
  note or book grant (R-VX185-1). Read, suggest and edit act on its members through the existing guards;
  `create_note` / `import_document` with its id write a new note bookless in its wing wearing the tags its rule needs
  (her own gathering door's planner without the star; the ONE application road, so living books hear it; one
  client-named undo; VX-252's answer with VX-361's tags); a rule only a star could satisfy refuses in her door's words
  ("Its rule needs a starred note, and only the author can star one."), never the not-shared shape, and the grant sheet
  offers such a gathering read and suggest only, with the why. An ask on a gathering keys as its reading (PROVISIONAL
  MB-17). `list_wings` lists no wing for a gathering grant (hidden = missing)."
- **MCPSpec, the grant road:** "(WHERE = **a note · a book · a wing** on the one sectioned `SearchPicker`; …)" → "(WHERE =
  **a note · a book · a gathering · a wing** …)".
- **MCPSpec, the shared icon:** "a wing wears it only under a wing grant or the open book" → add "a gathering under its
  own grant, its wing's, or the open book".
- **AppSpec §7, the MCP GRANTS family:** "(v1_24 → v1_30)" → "(v1_24 → v1_33)"; "per-client × per-scope grant rows (the
  four rungs)" → "+ (note · book · gathering · wing)".
- **SurfaceContracts, Doors to the outside (the MCP door bullet):** after "Grants are local-only and never synced (§7)."
  add "A gathering is a grant place whose reach follows her tags (VX-549)."
- **The dated entry + narrative → `notes/AppSpecRecord.md`** (her sitting's words; the W1 / MB-17 provisionals).

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator): the product is prebuilt at `~/dev/variorum-vx-548/DerivedData/b3` from
  the final sources (`66096499e`; this record's commit changes no code) — `cd App/Variorum && xcodebuild -scheme Variorum
  -destination 'platform=macOS' -derivedDataPath ~/dev/variorum-vx-548/DerivedData/b3 test-without-building` with
  `-only-testing:VariorumTests/<Suite>` for: **the pins** `MCPGatheringGrantFacesTests` (new, 6); **the flips and
  justified edits** `TutorialMCPChapterTests` · `MCPAskAndReceiptTests` · `MCPWireRefusalSweepTests` ·
  `MCPShareFacesTests` · `MCPGatheringIconTests`; **the neighbours** `MCPGrantSheetTests` · `MCPGrantRoadsTests` ·
  `MCPPaneTests` · `MCPPaneTabsTests` · `MCPSharedRowsTests` · `MCPSharedRowsRulesTests` · `MCPSharedIconClickTests` ·
  `BookPanelMCPMarksTests` · `MCPWingFacesTests` · `MCPAsksWaitTests` · `MCPDoorErgonomicsFacesTests` ·
  `MCPEditParityFacesTests` · `MCPLibraryParityFacesTests` · `CapabilityRegistryTests` · `TutorialCurrencyTests` ·
  `ChromeLineLimitTests`. `b3` CONTAINS batches 1/2a/2b too (cloned from `b2b`, rebuilt from this tip), so every list
  may run from it in one window. State the EXECUTED count (VX-604). Read the `skipped:` lines.
- **The walk (dev store, both voices, a client approved — the shim driven with the pane-copied key as before):** (1) a
  tag `parser` and a gathering "parser things" (rule #parser) with two tagged notes, one marked Private; Settings ▸ MCP
  ▸ Share another place… → WHERE "A gathering" → the picker (Starred, a–z rows with their footing) → pick it → Read,
  always → Shared with AI shows the row, kind chip "gathering". (2) The Bookcase: the gathering's row wears the shared
  icon (its own grant — no "through"); open it / a member: the member rows wear the icon, the Private one does not. (3)
  The client: `list_books` lists it; `read_note` the Private member answers the one not-shared sentence; tag a third
  note #parser → `read_note` it succeeds. (4) Change the grant to Write new → `create_note {book_id: <gathering>}` →
  the note lands bookless in the wing, wearing #parser, the gathering shows it; ⌥⌘Z (named after the client) takes it
  back. (5) A gathering with rule `#parser AND ★`: the sheet offers Read and Suggest only with the one-line why; with a
  write-new grant made before the rule changed, `create_note` into it answers "Its rule needs a starred note, and only
  the author can star one." (6) A read-only gathering grant + `create_note` into it → the ask waits ON the gathering's
  Bookcase row (the reading glyph) and in Waiting; Allow → a gathering grant. Restore: revoke the walk grants, delete the
  walk gathering/notes/tag, server off.

### MORNING BUNDLE items born here (folded into §MORNING BUNDLE above)

MB-16 (W1 — a gathering place under its wing's grant) · MB-17 (the ask's key) · MB-18 (place doors not built) · MB-19
(the copy) · MB-20 (two wire roads keep the not-shared answer on a gathering) · MB-21 (no note count on the sheet's
gathering rows).

## LADDER RECORD

### ROUND 1 — fable-reviewer (fresh, REVIEW_PROMPT verbatim, zero framing; whole-run diff `origin/main...HEAD` at `1ca1a297e`+fix legs; 2026-10-27)
**Verdict: 0 BLOCKER · 0 MAJOR · 2 MINOR · 2 NIT.** The reviewer re-ran the headless pin suites itself (100/17 green + the whole MCP package) and read the Mac pins (their run stays the final window's). Findings VERBATIM (the reviewer's message is quoted; dispositions follow the cross-model flow):

1. **[MINOR] · the run record, BATCH 1 RECORD** — batch 1 drafts NO "Canon owed at the closeout" block while 2a/2b/3 each do; after merge, MCPSpec's standing W-UX-19 line ("every Shared-with-AI row carries Change… beside Revoke — the pre-filled REPLACE sheet") would stand contradicted on the cross-place arm (Change… now replaces only while the confirmed place is the opened place), and nothing drafts MB-2's two door verbs or MB-3's zero-state explainer for MCPSpec/SurfaceContracts. Fix: a batch-1 canon-owed block in the record before the closeout applies canon. Doc fix — no pin.
2. **[MINOR] · Tests, tree-wide** — a SECOND load-sensitive flake beside VX-532: `MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds` failed under the reviewer's full-parallel run ("premiseFailures == 0", its own rehearsal premise), green isolated; acceptance verdicts keyed on "the one standing flake" can mis-read noise. Fix: a ticket (Tests & tooling, the VX-532 class) + a run-record note. No product pin applies.
3. **[NIT] · Sources/VariorumMCP/MCPWriteTools.swift:757 (intoGathering)** — the gathering arm spends a once grant without the book arm's `spendsAfter` guard; unreachable today (both callers default spendsAfter true) — hollow as a bug, cleanliness only. Fix shape: thread `spendsAfter` through for symmetry.
4. **[NIT] · App/…/MCPPaneCopy.swift (MCPAskCopy, `case (.gathering, _?)`)** — the fenced-gathering ask sentence hardcodes "marked Private" for ANY fence (a stale `'daily'` marker included) while the book arm distinguishes `.journal` from `.privateMark`; reachable when an ask raised on an unfenced gathering meets a fence synced in afterwards; behavior right, the why-word wrong. PINNABLE (a `.journal`-fenced gathering copy unit test is red today). Fix: match the fence kind as the book arm does, or word fence-neutrally.

**Considered-and-dismissed (the reviewer's traced non-findings, kept):** decideGathering's grant-before-openBook ordering mirrors decideWing (house shape); list_notes() fenced-gathering assembly is cost-only (facts derivation skips fenced gatherings); halt()'s 2-second wait residual window is pre-existing shape, narrowed; MCPGrantChange's ⊆ rule can't revoke an act's grants from a single-note confirm (a `.notes` opening renders no WHERE picker — verified in the sheet body).
**Clean bill:** the reviewer's full clean-bill list is preserved in this section's source message (the orchestrator's transcript) and summarized: VX-516's mechanism-in-the-removed-code + the one-confirm decision + all five roads pinned; VX-393/v1_33 proven (rows+rowids verbatim, indexes byte-unchanged, local-only correctly outside §12); the VX-549 decide layer through the ONE membership function, fence-first, P1 statement-pinned; write_new's refuse-before-mint + in-transaction re-check; VX-358/365/352/354 each verified to their rule; VX-394's quit/socket/teardown shapes; hygiene (no Sync//custody/editor-seam touch, two-file rule held, no trailers, sentence case, P-1 registry declaration).
**Dispositions:** all four findings to a FRESH L1 fix session verbatim (none disputed-by-construction, no FINDER-FIXES); its agree/dispute returns to the round-1 reviewer for the final call; the confirmed fixes then land red-on-old where pinnable (finding 4), and round 2's fresh reviewer re-checks the fixes.

### L1 agree/dispute (the L1 fix session — `opus-implementer`, fresh, xhigh; 2026-10-27; each finding traced in its own context, read from the tree at `f611b8ef7`)

**AGREE ×4 — no dispute; the session proceeds to the fixes (step 2) in the same session.**

1. **AGREE (MINOR, doc).** The BATCH 1 RECORD's sections are LIVE STATUS · the trace · the fix · VX-515 · VX-512 · adjacent
   tickets · files · for the orchestrator — no "Canon owed at the closeout" block, while 2a (:758), 2b (:1053) and 3 (:1284)
   each draft one. MCPSpec's standing sentence "every Shared-with-AI row carries Change… beside Revoke (W-UX-19 ruled — the
   receipt's pre-filled REPLACE sheet, one grant or a whole act; …)" says REPLACE unconditionally; after `d0e7f1302` /
   `965a05521` the replace survives only while `MCPGrantChange.keepsReplacing(opened:confirmed:)` holds (confirmed ⊆
   opened), so on the cross-place arm the canon line would describe the pre-fix behaviour VX-516 removed. MCPSpec's pane
   sentence ("per-client grant rows …, the client row's Deny…-with-confirm") and SurfaceContracts' MCP bullet name neither
   door verb (MB-2) nor the zero-state line (MB-3). Nothing in the record carries those three lines to the closeout.
2. **AGREE (MINOR).** `MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds` counts a round as a
   PREMISE failure when the session's `initialize` answer is not read inside the client socket's 5 s receive timeout
   (`prepare(client, receiveTimeout: 5)` → `readLine` nil → `oneSession` returns nil → `premiseFailures += 1` →
   `#expect(premiseFailures == 0)`); 150 rounds × 2 endings, each spinning a real `MCPSession`, under the whole-package
   parallel load can push one answer past 5 s — a wall-clock premise, the VX-532 class, no product line involved (the file
   is untouched by this run). The record's suite claims say "the one standing flake"; with two, a full-parallel red in
   either must be re-run isolated before it counts. Ticket filed (VX-607); the record note is owed.
3. **AGREE (NIT — hollow as a bug).** `into(_:job:clientName:spendsAfter:admitsGathering:_:)` (`MCPWriteTools.swift:694`)
   threads `spendsAfter` into the book arm's `land(spending: consumesOnce && spendsAfter ? …)` (:720) but hands the gathering
   arm to `intoGathering` (:743), which takes no `spendsAfter` and spends `consumesOnce ? [grantID] : []` (:758). Reachable
   only as `admitsGathering: true` + `spendsAfter: false`: the two `admitsGathering: true` callers (`create_note` :459,
   `import_document` :473) take the default `spendsAfter: true`, and the two `spendsAfter: false` callers
   (`MCPWriteTools+Carriage.swift:227`, `MCPWriteTools+Edit.swift:292`) leave `admitsGathering` false, so they never reach
   the gathering arm. No tool reaches the combination — cleanliness only, as the finding says.
4. **AGREE (NIT — pinnable).** `MCPAskCopy.lead(_:)` (`MCPPaneCopy.swift:1319`) matches `(.gathering, _?)` before the
   kind-agnostic arms, so ANY fence on a gathering ask reads "This gathering is marked Private now, …". The ask's fence is
   re-read at her open by `MCPDoor.askStanding` (`MCPDoor.swift:868`) through `Queries.mcpGatheringFacts` →
   `mcpReadingFacts`, whose `dailyJournalLegForBook` (`r.profile = 'daily'`) yields `.journal` for a gathering row that
   carries a stale daily marker (`MCPGrantRule.fence(journal:privateMark:)` — Private wins, else journal). So an ask raised
   on an unfenced gathering (`intoGathering` raises one only while `facts.fence == nil`) that meets a synced-in 'daily'
   marker before she opens it hears the Private why-word. Behaviour right (no grant offered — `durations(for:)` and
   `reachLine` read the fence, not its kind), the word wrong; the pane's own `inertDetail(.journal, kind: .gathering)`
   already distinguishes ("it's your daily Journal now"), so the ask's lead is the one face that doesn't.

### L1 FIXES (the same session, the confirmed findings — all four agreed, no dispute pending)

**NOT DONE BY L1 (first line):** no `xcodebuild test`, no GUI, no stage; no canon applied (finding 1's lines are DRAFTED
for the closeout, the two-file rule); nothing in `Sync/`, `Server/`, custody, the synced schema or the editor seam.

**LIVE STATUS (per piece, flipped in the same commit as each piece):**
- **No behavioural revert is in flight.**
- Finding 1 (batch 1's canon-owed block): DONE (this commit) — the BATCH 1 RECORD's new "Canon owed at the closeout"
  block (after its "Files touched"): W-UX-19's sentence corrected (Change… replaces only on its own place — MB-1), the two
  door verbs (MB-2) and the zero-state line (MB-3) drafted for MCPSpec in 2a/2b/3's shape; SurfaceContracts owed nothing
  (its one-row-per-place line stays true), said with the reason; the AppSpecRecord narrative's batch-1 items listed. Doc
  only — no pin (the finding's own disposition).
- Finding 2 (the two-flake note): DONE (this commit) — ENVIRONMENT TRAPS gains the binding line ("two load-sensitive
  flakes are standing — VX-532 and VX-607 — a full-parallel failure in either is re-run isolated before it counts", each
  named with its premise), and the latest merged-tree suite claim (the 2a fix leg's) carries the same note. The ticket
  (VX-607) was filed by the orchestrator. No product pin applies (the finding's own disposition).
- Finding 3 (`intoGathering` takes `spendsAfter`): NOT-STARTED.
- Finding 4 (the fenced-gathering ask's why-word): NOT-STARTED — pin first, red on the current code, then the fix.
- The whole headless suite at the end: NOT-STARTED.

## ORCHESTRATOR ACCEPTANCE

### BATCH 1 — ACCEPTED 2026-10-27 (window `vx548-b1-walk`, GO from oct26coordinator 02:48 MDT, released clean)
- **Mac suites:** 141 tests / 12 suites GREEN on the FROZEN `DerivedData/b1` products via `test-without-building`, zero skips; the flagged `MCPPaneTabsTests.aFreshPaneOpensOnConnectWithItsCodeBlockInSight` passed in BOTH voices (the VX-512 line above the tabs fits).
- **The walk (dev store, Debug from the b1 products):** every brief leg verified in use — (1) VX-512's zero-state explainer live on a clientless library ("Clients belong to the library they were set up in — run each one's setup here." + (i)), and it correctly DISAPPEARS the moment a pending client exists; (2) approve-alone sheet speaks the new "Share a place…" wording in its lead; (3) the Clients row door reads "Share a place…" and ADDS; (4) "Share another place…" on Shared with AI grants a SECOND wing — **both wing grants stand side by side** (Home + Walk Wing, each claude-code · read · always); the door correctly vanishes at zero listed grants; (5) a wing row's Change… opens titled "Change access — ‹client›" with the NAMED replaces line ("Confirming replaces claude-code's grant on the Walk Wing wing — read, always."); picking the OTHER wing flips the title to "Grant access — ‹client›", the line goes, and the confirm REVOKES NOTHING (the opened-on wing's row stands — her Air's exact loss, closed); the other place's standing row upgrades in place (Home read → "read and suggest"); (6) same-place Change… at a lower rung replaces: one Home row back to read (T-U3-8 kept). Bonus: Activity shows the test client's end line "claude-code disconnected" (the client-closed arm — BATCH 2b verifies the arm wordings against P-VX394-1…6).
- **Walk mechanics:** no set-aside needed — the dev slot currently holds an EMPTY HELD library ("as of October 20, 2026", restore-hold banner; id `1787a29ea0d545b9`), which has no clients, so the zero-state showed directly; found that way, left that way. The test client was the shim driven DIRECTLY with the pane-copied key (no `claude mcp add`; nothing written outside the dev store). Cleanup: both walk grants revoked; server back OFF; same library id reopened UNLOCKED (no lock screen, no pre-design face, no start-fresh offer), quit clean, zero instances (strict pgrep forms). Prefs diff vs pre-walk export: no keys added/removed, only the app's own launch bookkeeping values (the per-launch dev-store backup ledger). **Residue (deliberate, harmless):** the approved client row `claude-code` (zero grants, door off — no removal door short of Deny, and a denied row is a worse trap) and the empty wing "Walk Wing" (the ⌘L switcher offers no per-row delete; left for a later tidy or her hand).
- Captures lived in the session scratchpad only (deleted at the merge per the closeout rule); this record is the evidence of record.

### THE MID WINDOW — RUN 2026-10-27 (claim `vx548-mid`, GO 04:53 MDT; VX-502's hand-returned library e11e5233 found as briefed)
- **Suites (the VX-604 rule applied):** ONE invocation on the frozen `DerivedData/b2b` (batches 1+2a+2b): **336 tests EXECUTED in 39 suites — ONE failure.** Isolated re-run: 7 executed in 1 suite, same failure — NOT a flake.
- **FINDING MID-1 (a 2a REGRESSION, routed to implementer №2 as FIX LEG 2a-F1):** `BookPanelMCPMarksTests.underABookGrantEveryNotesRowWearsBothMarksTheCollapsedChapterRowIncluded` (VX-330's pre-existing pin) fails on the 2a tree: 3 issues — "Expectation failed: drawn" (:308), icon frames ≠ 4 (:309), iconRows/askRows ≠ 4 (:314). Under a BOOK grant the panel's NOTE ROWS lose their marks. The pin was green at VX-336's close, so VX-330's own test IS the red-on-old; the suspect is 2a's `BookPanelModel.readingReach`/`holdReadingReach` work displacing or gating the note-row reach hold. FIX LEG 2a-F1: the 2a implementer traces and fixes (the pin goes green on the fixed tree; the header/gathering marks its 4 new pins cover stay green); the Mac re-run rides the FINAL window. **Batch 3 note:** batch 3 landed before this finding's fix — its decide-layer work is disjoint, but the final window re-runs everything on the merged tree.
- **The walk (an Opus walker under the same claim — the orchestrator's own synthetic-input leg was stopped by a safety classifier, the standing Fable-safeguard remedy, coordinator ack'd): ALL LEGS GREEN.** (1) **VX-352 in use:** Terminal + margin grid reads "choose claud… · english" — the label's own part whole, the client name yielding, never "claude-code · e…"; Study reads the whole label; stack style whole in both. (2) **VX-354 in use:** the Book Panel header ("VX548 Book") and the gathering ("VX548 gathering", via "appears in 1 gathering ▸") wear the shared icon under the Home wing grant; AX descriptions name the client and rungs. (3) **Batch 2b's quit leg GREEN:** with a named connection live, quit → relaunch → Activity UNCHANGED ("all 11", no end line for the quit-time connection) — P-VX394-5 live. Cleanup complete to the declared posture (the walker's report is quoted in this section's findings; its two walk-added per-note prefs keys removed by the orchestrator post-quit; the VX548 content in the Trash, 30 days; VX-502's residue and the hold banner untouched).
- **FINDING MID-2 → VX-605 (Bug · Confirmed · MCP · Medium):** a live NAMED connection can read "last seen …" on the Clients row — `onConnectionsChanged` fires before the session has its name, and `MCPSession` sets the name at initialize signalling nothing; the set catches up only on a later event. Traced read-only by the walker; VX-394's family; NOT fixed in this run.
- **FINDING MID-3 → VX-606 (Bug · Suspected · MCP · Low):** `read_note` served a call carrying an undeclared argument (`"ids": true`) despite `additionalProperties: false` — the wire may not validate the schema it publishes.
- **FINDING MID-4 → FIX LEG 2a-F2:** the whole-label hover (MB-4's hover half) is UNVERIFIED and may not work: synthetic pointers raise no tooltips (a positive control also failed), and the AX tree shows the take-card header as ONE button whose help is the choose capability's sentence — no AX element carries the whole label as help, so the outer button's `.help` may shadow `TakeLabelLine`'s `.help(label)`. The 2a fix session verifies (an AX/unit seam) and fixes if shadowed; else it lands as her 5-second hand-check in the bundle.
- **Final-window check item:** the gathering icon's AX on b2b read "Shared with claude-code (read)" under a read-and-suggest wing grant — expected to read the grant's own rung on the b3 tree (batch 3's MB-16); confirm there.

### THE MID WINDOW (as planned; kept for the record)
One claim (`vx548-mid`): (a) 2a's + 2b's Mac suites via `test-without-building` on the frozen `DerivedData/b2a` (+ 2b's product dir); (b) the 2a faces walk — Terminal voice + margin-grid Takes card showing an AI take labelled `claude-code · english` (minted through the wire: re-grant, reconnect the bound shim key, `add_take`, then revoke + server off + voice restored), the whole-label hover, and the Book Panel header/gathering marks (a minted book + gathering; tidied after); (c) MB-10's taste capture for her morning. Batch 3 spawns only after this window passes.

## SITTING / RULING RECORD (anything she says mid-run lands here verbatim, same turn)

- **2026-10-27, in-session, pre-sleep — the coordinator's stage protocol RATIFIED.** She read the orchestrator's point-by-point comparison of oct26coordinator's protocol lines against canon (REQUEST/READY/GO/RELEASE; strict pgrep forms; "the Air runs nothing tonight" as tonight's default, not a ban; What's-New dismissal + Debug-prefs export/diff; the NEW declare-and-restore rule for MCP client config a walk writes outside the dev store) and ruled, verbatim: *"ok yes I like it - makes sense. good luck overnight."* The protocol lines are folded into ENVIRONMENT TRAPS above; the declare-and-restore rule is adopted as this run's walk law.
- **Her question the same sitting** — *"what is this about the coordinator's stricter environment lines? i haven't said anything to it about that so i'm curious if you think it's going too far"* — answered point by point (not overreach; every line queue arbitration or a condition on the stage it grants; the watch-line is "coordinator: stage only" drift into code/ladder/release calls, none present). Recorded because it bounds what the coordinator's messages may bind: stage conduct yes, build content never.
