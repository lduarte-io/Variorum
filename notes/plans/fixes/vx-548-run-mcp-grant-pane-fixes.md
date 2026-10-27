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
- **The coordinator's stage protocol (oct26coordinator's, RATIFIED by her 2026-10-27 — see SITTING/RULING RECORD):** only the ORCHESTRATOR talks to the coordinator; REQUEST early → READY when built-and-startable → start only on the coordinator's GO → `Tools/stage release` + one result line. Strict instance checks: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the loose form matches builds). After every Debug launch, dismiss a What's New sheet if one shows. Walks are DEV STORE only; no real-store MCP tool calls or real-app launches. A walk that would write MCP client config outside the dev store (Claude Code's / Claude Desktop's server entries, setup keys) is DECLARED in the request and restored at release. Debug prefs: export first; at restore re-export and diff (`defaults import` merges). Merges serialize through the coordinator.

---

## THE BATCHES (her ruling: ticket order, gates first)

| Batch | Members | Session | State |
|---|---|---|---|
| 1 — the gates | VX-516 (Urgent) · VX-515 · VX-512 | opus-implementer №1 | BUILT (headless green, red-on-old verified; Mac pins compiled — run + walk PENDING the stage) — BATCH 1 RECORD |
| 2a — faces & wire answers | VX-352 · VX-354 · VX-365 · VX-358 | opus-implementer №2 | IN FLIGHT (spawned at the batch-1 seam) |
| 2b — the disconnect story | VX-394 | opus-implementer №3 | NOT STARTED |
| 3 — gatherings as a grant place | VX-549 (not launch-gating) | opus-implementer №4 | NOT STARTED |
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
- (Batch records may append more.)

## LEDGER

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Worktree + branch + in-flight row + Linear In Progress | orchestrator | DONE (`472ed9bfe` on main; branch pushed) |
| 2 | This plan file | orchestrator | DONE |
| 3 | Batch 1 (VX-516 · VX-515 · VX-512) | opus-implementer №1 | BUILT — `d0e7f1302` core · `965a05521` app; Mac run + walk PENDING (BATCH 1 RECORD, "For the orchestrator") |
| 4 | Batch 2a (VX-352 · VX-354 · VX-365 · VX-358) | opus-implementer №2 | NOT STARTED |
| 5 | Batch 2b (VX-394) | opus-implementer №3 | NOT STARTED |
| 6 | Batch 3 (VX-549) | opus-implementer №4 | NOT STARTED |
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

**NOT DONE BY THIS BATCH (first line, by the rule):** IN PROGRESS — this line is rewritten at the batch's close.

*Implementer: `opus-implementer` №2 (xhigh), fresh session, 2026-10-27 overnight. Read in its own context before any
code: CLAUDE.md + its canon, `notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` IN FULL (The app · The note ·
The Bookcase and books · Doors to the outside among it), this plan IN FULL, `notes/SessionResiliencyProtocol.md`, the
vx-336 record's U5 STAGE RUN step 12 (VX-352's capture), U6b UNIT RECORD (the sweep table, OWED 2 — VX-354), U7 UNIT
RECORD's D-254-1 + BUILDER A's RECORD and OWED 3 (VX-358), U9 UNIT RECORD's traces + D1/F-1 (VX-365, OWED 4), and every
code anchor below. Lane: no `Sync/`, `Server/`, custody, synced schema or editor seam; headless `swift build`/`swift
test` + `xcodebuild build-for-testing` into `DerivedData/b2a` only — no `xcodebuild test`, no walk, no stage claim (the
orchestrator's). Batch 1's code and record untouched.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **A BEHAVIOURAL REVERT IS IN FLIGHT (VX-352), over the committed `3e1aaa26f`:** `TakeLabelFace.allocate`'s body put
  back to READING ORDER (the yielding part first — one run cut at its tail, the old face); restore = `git checkout --
  Sources/VariorumCore/Domain/TakeLabelFace.swift` (committed — safe). If this line still stands, check `git diff`
  first. (VX-358's ran earlier over `4d3f3f3d1` and was restored, `git diff` clean, green again —
  `vx358-green2.log`.)
- **VX-365 (`add_note_to_book`'s answer names no tags):** DONE (this commit) — core
  `Operations.addNoteToBookForClient` → `MCPBookAdd {membership, tagIDs, tagPaths}` (the same body and ONE undo entry;
  `addNoteToBook` keeps its signature and returns `.membership`), the tags composed INSIDE the act's transaction by
  VX-361's one rule (`mintedNoteTags`: the note's own tags in application order, read before the add, then the book's
  outflow in outflow order, each once); the wire answer gains `tag_ids` + `tags` (always present, `[]` when none); the
  description's "Returns JSON." gains create_note's tag sentence. RED ON OLD (`scratchpad/b2a-logs/vx365-red.log`, the
  pins run on the pre-fix tree `1fc292c02`): 3 of 4 failed, 8 issues — the guard green; GREEN after
  (`vx365-green.log`): the pins 4/4 + `MCPTagTruthServerTests`, `MCPWriteServerTests`, `MCPWingReachServerTests`,
  `MCPAdviceServerTests`, both neutrality walks, `MCPWriteActsTests`, `MCPEditActsTests`, `UndoQuietPressTests` — 94
  tests in 10 suites passed.
- **VX-358 (an NFC↔NFD re-spelling answers `changed: false` with a digest that isn't the sent bytes'):** DONE (this
  commit; PROVISIONAL MB-5) — canonical equality stays the no-op rule; the pure `StoredText.spellingDiffers(_:from:)`
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
- **VX-352 (Terminal's take card cuts "claude-code · english" to "claude-code · e…"):** DONE (this commit; PROVISIONAL
  MB-4) — the pure `Sources/VariorumCore/Domain/TakeLabelFace.swift`: `parts` splits a label at its first " · " into a
  YIELDING head (the client name — and the legacy "suggested" word with it) and a KEPT tail (the separator + the
  label's own words); `allocate` gives the kept part its whole width first and the head what is left. The card header
  (`TakeChooseHeader`, every fan style) draws the parts through `App/…/Features/Takes/TakeLabelLine.swift` — a custom
  `Layout` (`TakeLabelLayout`) that asks `allocate` for each part's width (each `Text` tail-truncates inside its own),
  `.help(label)` and the accessibility label the whole label; a label with no separator is one part (today's face).
  Pins: core `TakeLabelFaceTests` (4 — her capture's width in monospace columns; the legacy form; the parts and
  allocation tables) GREEN; `MCPTakeLabelFormServerTests.theTakeCardSplitsTheLabelWhereThisConventionPutsItsSeparator`
  (the card's separator and legacy word ARE the wire's) GREEN (`vx352-green.log`); Mac `TakeLabelLineTests` (3 — the
  real header swept in Terminal and Study, the placed widths read from the DEBUG `TakeLabelLayoutProbe`) COMPILED
  (`build-for-testing` green, `mac-bft1.log`), RUN **PENDING** the orchestrator's stage. The behavioural revert run:
  PENDING (next).
- **VX-354 (the Book Panel's header and gatherings wear neither mark):** NOT-STARTED — settled design: the panel's
  model holds the READING reach (`Queries.mcpBookReaches(readingIDs:)` — `decide` for the book, `decideGathering` for a
  gathering, behind `mcpReachStandings`' VX-272 gate) over exactly the readings DRAWN: the shown book always, the
  gatherings' names only while "appears in N gatherings" is open (the pure `BookPanelBrain.markedReadings`); the header
  and each listed gathering wear the Bookcase row's pair — `MCPSharedIcon` then `MCPAskGlyph(.book(id))` (no ask ever
  targets a gathering — `MCPAskTarget`, VX-273 — so a gathering's glyph draws nothing, exactly as on the Bookcase).
  Mac pins extend `BookPanelMCPMarksTests` (compiled; RUN PENDING the orchestrator's stage).
- **Suites:** PENDING (the headless targeted suites per piece; the whole headless suite and `build-for-testing` at
  the end).

## BATCH 2b RECORD

## BATCH 3 RECORD

## LADDER RECORD

## SITTING / RULING RECORD (anything she says mid-run lands here verbatim, same turn)

- **2026-10-27, in-session, pre-sleep — the coordinator's stage protocol RATIFIED.** She read the orchestrator's point-by-point comparison of oct26coordinator's protocol lines against canon (REQUEST/READY/GO/RELEASE; strict pgrep forms; "the Air runs nothing tonight" as tonight's default, not a ban; What's-New dismissal + Debug-prefs export/diff; the NEW declare-and-restore rule for MCP client config a walk writes outside the dev store) and ruled, verbatim: *"ok yes I like it - makes sense. good luck overnight."* The protocol lines are folded into ENVIRONMENT TRAPS above; the declare-and-restore rule is adopted as this run's walk law.
- **Her question the same sitting** — *"what is this about the coordinator's stricter environment lines? i haven't said anything to it about that so i'm curious if you think it's going too far"* — answered point by point (not overreach; every line queue arbitration or a condition on the stage it grants; the watch-line is "coordinator: stage only" drift into code/ladder/release calls, none present). Recorded because it bounds what the coordinator's messages may bind: stage conduct yes, build content never.
