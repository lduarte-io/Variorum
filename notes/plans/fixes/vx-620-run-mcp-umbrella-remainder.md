# VX-620 — Run: MCP umbrella remainder

**STATUS: OPEN — kicked off 2026-10-27 (the VX-548 remainder, a fresh orchestrator per her ruling).**
Ticket: VX-620 (run ticket; members are sub-issues) · Project: 13n — The MCP door · Branch: `vx-620-run-mcp-umbrella-remainder` · Worktree: `~/dev/variorum-vx-620` (the Pro).

**Her kickoff words (2026-10-27, verbatim):** */architect-phase vx-620 — the VX-548 remainder (the record's CORRECTION section has the story; resolve the members by LISTING VX-620's sub-issues, per the skill's new rule). Members are SIX (her add of VX-605 the same sitting) — resolve by the sub-issue listing. Suggested batches: (1) VX-596 — set_starred at the edit rung, one client-named undo, AND the VX-549 star-rule revisit it unlocks (the grant sheet's read/suggest-shaping, the mint flow on star-rule gatherings, the just-in-time ask — VX-609 describes the ask's current dead-door state and is a natural rider); (2) the pane — VX-590, the "Shared with AI" face hidden until a client has ever connected (Pre-launch; keep the Connect road findable — the design care is on the ticket), and VX-605, the Clients row's "last seen" staleness on a live named connection (Pre-launch; traced on the ticket — the session names itself at initialize and signals nothing); (3) VX-565 (probe first — VX-548 rebuilt that listing, re-probe on main) + VX-566 + VX-567 (the import_document pair). My rulings are on the tickets. Rider candidates at kickoff: VX-609, VX-619. Stage, merges and any walk per the standing rules and whichever coordinator is live; no release without my word. Send messages to oct27coordinator.*

**THE ROSTER (resolved by the SUB-ISSUE LISTING at kickoff, 2026-10-27 — the rule this run exists to prove; re-list before the ladder):** her words said six, the listing says **SEVEN members** — VX-377 was re-parented into VX-620 at the VX-439 closeout (its one missed member) after she wrote the kickoff. The listing governs. Members: **VX-596** (set_starred + the VX-549 star-rule revisit) · **VX-590** (Pre-launch) · **VX-605** (Pre-launch) · **VX-565** · **VX-566** · **VX-567** · **VX-377** (Move/Copy to Wing from ⌘K). **Riders seated at kickoff (sub-issues now, so the roster stays the listing):** **VX-609** (named in her kickoff; functionally inseparable from VX-596's wording point 4) · **VX-619** (her kickoff file: "a cheap rider here"). Nine sub-issues total.

**The protocol:** autonomous, PROVISIONAL-and-continue everything short of an author-only hard stop; every question, taste call and ratification lands in §THE BUNDLE below (and the QUESTIONS.md bundle at the merge); nothing improvised around, nothing silently dropped. No release, no `/Applications` refresh, no deploy (her word). Stage claims only through the coordinator session **`oct27coordinator`** — only the orchestrator talks to it.

**Cast:** Fable architect/orchestrator (this session) · `opus-implementer` (xhigh), ONE per batch, fresh each time · `fable-reviewer` (xhigh) for the ladder — the run's diff is MCP (grants decide AI reach — default's-meaning content), so the cold review is Fable's. One ladder over the run's whole diff after the batches; pin-before-fix binds PER MEMBER.

**Open context that binds:** QUESTIONS #243's remaining provisionals include MB-16/MB-17 (a wing grant reaches a gathering place at its own rung; asks keyed as the reading) — if she rules them while this run is open, VX-596's faces follow her ruling, not the provisionals. The daily Journal's per-ask fence is RE-CONFIRMED (her 2026-10-27 word: "I don't want the daily journal itself to be shareable standing still - Im pleased with that line") — nothing here touches it; the star work changes gathering reach only.

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

Every implementer reads: CLAUDE.md + its auto-loaded canon (automatic) · **`notes/MCPSpec.md` IN FULL** (the door's authoritative contract — every batch here touches it except batch 4) · `notes/SurfaceContracts.md` — "Doors to the outside" and "The app" (batch 1 adds "The Bookcase and books" for the star and gatherings; batch 4 reads "The app" with special care for the keyboard family) · this plan file IN FULL · `notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from the first commit) · **the VX-548 record's sections each brief names** (`notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md` — the predecessor; its BATCH 3 RECORD is VX-596's foundation). Batch-specific reading is named in each brief. **SyncSpec note:** the MCP grants family is LOCAL-ONLY (v1_24 → v1_33) — never synced, no mirror, no §12 lockstep. The star is a synced `setting` list (zero schema — `StarTarget.swift`'s doc); `setStarred` is an existing synced-semantics op and this run ADDS NO SCHEMA. Nothing here touches `Sources/VariorumCore/Sync/`, `Server/`, or custody. If any member's trace leads into those trees, STOP and report to the orchestrator — that re-scopes the run.

## ENVIRONMENT TRAPS (carried into every brief by reference; binding)

- Run everything from `~/dev/variorum-vx-620`. Never commit from `~/dev/variorum` (main).
- Headless `swift build` / `swift test [--filter Name]` on the core package: free, no stage. **EVERY `xcodebuild test` run and anything touching the screen or a shared store needs a HELD `Tools/stage` claim — request it through the ORCHESTRATOR, who clears it with the live coordinator (`oct27coordinator`).** Do not claim the stage yourself.
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines before claiming a gated suite ran. NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).
- **The VX-604 executed-count rule:** a lone-suite Mac run on this machine can false-green through a test-host launch crash ("0 tests in 1 suite passed"). Every Mac run's verdict states its EXECUTED test count; a run that executed 0 is NO verdict, red-on-old legs included.
- **Two load-sensitive flakes are standing — VX-532 and VX-607:** a full-parallel failure in either is re-run isolated before it counts. VX-532: `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (a 15 s wall clock). VX-607: `MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds` ("premiseFailures == 0" under full-parallel load).
- **The APFS-clone DerivedData trap (VX-548 ladder r2, finding 1):** an APFS-cloned DerivedData is NOT isolated from its source — clone manifests carry absolute paths and a later build's stale sweep reaches back into the source dir. Every batch builds into a FRESH DerivedData dir (`~/dev/variorum-vx-620/DerivedData/<batch>`), never a clone of another batch's.
- Instance checks: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the loose form matches builds); discriminate by PATH (the test host matches mid-run). Real-store instances are identified by STORE, not path — NEVER quit or kill one. No Release builds or `/Applications` refreshes in this run at all.
- The dev store is the Debug app (`io.lduarte.Variorum.debug`); walks via `cliclick` + `Tools/WalkKit/` on the dev store only, under a held stage claim. Dev-store Castle credentials: `~/.variorum/dev-castle.env` on the Pro — never invent new ones; restore the dev store's posture before releasing a claim. **Known dev-store residue (VX-548's, deliberate):** library e11e5233 with the restore-hold banner standing (never press Resume), an approved `claude-code` client row (zero grants, server off), an empty wing "Walk Wing", walk content in the Trash. Found that way, left that way unless a leg needs it.
- **Walk conduct (the ratified stage protocol):** REQUEST early → READY when built-and-startable → start only on the coordinator's GO → `Tools/stage release` + one result line. The test client is the shim driven DIRECTLY with the pane-copied key — never `claude mcp add`; VX-prefixed walk content; a walk that would write MCP client config outside the dev store is DECLARED in the request and restored at release. After every Debug launch, dismiss a What's New sheet if one shows. Debug prefs: export first; at restore re-export and diff (`defaults import` merges). A LIVE CASTLE WALK trips [cyber] on Fable — GUI walk legs go to an Opus walker under the claim.
- zsh `pipestatus` (not bash's `PIPESTATUS`). Screenshots in gitignored dirs. Never `git checkout` over uncommitted work. Push after every commit; never rewrite pushed history. Synchronous foreground waits only — poll logs with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never end a turn awaiting a background run.
- No subagents inside implementer/reviewer sessions except ONE read-only Sonnet for external facts (spawn with `model: "sonnet"`).
- **oct27coordinator's protocol (received at kickoff, 2026-10-27 — the oct26 protocol she ratified, sharpened; stage conduct only, build content never):** REQUEST early (what, minutes, claim name) → a separate READY ping when startable NOW → GO only from the coordinator with the exact claim line (a FREE stage is never an invitation) → `Tools/stage release --who <claim>` + ONE result line carrying EXECUTED test counts (VX-604), the dev-store posture at release, and instance + sim state (`pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"`, `xcrun simctl list devices booted`). `Tools/stage renew` RESETS expiry to now+N — tell the coordinator BEFORE renewing. A mid window of an hour or more runs its TESTS FIRST and pings "SEAM" before the walk, so a merge-gating run can slot in. The walk REQUEST names every client, grant, setup key, wing and note it will add and how each leaves; the RELEASE line states the MCP pane's end state against the as-found (the `claude-code` row with zero grants, the empty "Walk Wing"); it says how the shim is pointed at the DEBUG app and how that is verified. Zero real-store MCP calls, no real-app launch. She deleted the throwaway Supabase project (variorum-vault-throwaway) — nothing here needs it. Merges: closeouts serialize, first-ready first; "rebase" = MERGE main IN, never rewrite a pushed branch; at every merge the coordinator intersects the merged files with ours — any overlap means we merge main in and re-run the overlapping files' suites on the merged tree before our MERGE ASK.

---

## THE BATCHES (her suggested batching + the listing's seventh member; strictly sequential, a fresh implementer each)

| Batch | Members | Session | State |
|---|---|---|---|
| 1 — starring on the wire | VX-596 + rider VX-609 | opus-implementer №1 | NOT STARTED |
| 2 — the pane's honesty | VX-590 (Pre-launch) · VX-605 (Pre-launch) | opus-implementer №2 | NOT STARTED |
| 3 — the wire's imports & docs | VX-565 (probe first) · VX-566 · VX-567 + rider VX-619 | opus-implementer №3 | NOT STARTED |
| 4 — the wing doors from ⌘K | VX-377 | opus-implementer №4 | NOT STARTED |
| L — the ladder | the run's whole diff | fable-reviewer, fresh per round | NOT STARTED |

---

## BATCH 1 BRIEF — VX-596: starring on the wire (set_starred at EDIT) + the VX-549 star-rule revisit + rider VX-609

**Extra required reading:** the VX-548 record's **BATCH 3 BRIEF, HER SITTING, BATCH 3 RECORD and THE DELIBERATE FLIPS** (the VX-549 machinery this batch revisits) + its MB-16/MB-17/MB-19/MB-22 bundle items (PROVISIONAL — follow them unless QUESTIONS #243 shows her ruling otherwise) · the VX-596 ticket body IN FULL (the seven-point "WORDING THIS BUILD MUST REVISIT" block is this batch's checklist) · the VX-609 ticket body · SurfaceContracts "The Bookcase and books" (the union star, the collect door). Code anchors: `Sources/VariorumCore/Models/StarTarget.swift` (the star's one home — a synced `setting` list, zero schema) · `Operations+Appearance.swift` (`setStarred`, `writeStar` — the cap 15, `starLimitReached`, the union star, intake fired on a note's star, un-star a non-event, born-starred mints cap-exempt) · `Domain/GatheringMint.swift` (`starrable:`, `needsStar`, `tagsCanSatisfy`) · `Queries/GatheringMintQueries.swift` · `Operations/Operations+MCPWrites.swift` (`MCPNoteDestination.gathering`, `intoGathering`) · `VariorumMCP/MCPWriteTools.swift` (`into(…, admitsGathering:)`) · `MCPWriteSupport.swift` (the star refusal's words) · `MCPToolCatalog.swift` · `MCPSession.swift` (the instructions — ≤3,000 chars, at 2,988) · `Features/MCP/MCPGrantPicker.swift` (`offeredRungs(needsStar:)`) · `MCPPaneCopy.swift` (`starRuleWhy`) · `MCPAskQueue.swift` / `MCPAskSheet.swift` (the ask's durations and copy — VX-609's seam) · `Features/Tutorial/TutorialSeeder.swift` (the guide's gathering card).

**Her ruling (the ticket, verbatim-faithful):** "let's add the star over the wire, it might as well be included." Stars are NOT in the hers-alone trio (Private · Seal · Own) — nothing ruled blocks it; it was a VX-368 parity item. Shape: **a `set_starred` tool under the EDIT rung, one ⌥⌘Z entry naming the client like every write.** It unlocks write_new on star-rule gatherings (VX-549's refusal "stands until this lands" — its own text). And her wording ask: "the star rule wording should be changed since the starring is being added" — the ticket's seven-point block enumerates every string.

**The build:**
1. **`set_starred` (the tool).** EDIT rung. Targets: a NOTE (its place decided through the one `decide` — note grant, book member, gathering member, wing) and — for keyboard parity, R-VX184-1 — a BOOK (decided on the book). Both route through `Operations.setStarred` (or a ForClient wrapper in its exact shape), so intake HEARS a note's star through the standing table (a living ★-rule book seats or bells exactly as when she stars — the one application road's twin; verify, don't re-implement). Un-star: same tool, `starred: false`, idempotent; un-starring is an intake non-event (standing). The cap (15) refuses in her door's words through the one refusal chain (`starLimitReached` — verify it is worded in `OpsRefusalTable`/`MCPWireRefusalCopy`, never a raw case). ONE client-named ⌥⌘Z entry per act, on the `move_note_to_wing` precedent (the MCP road wraps an undo-less-for-her act with a client-named entry; the replay writes back only while the row still reads the act's value, else quiet-retires — the standing MCP undo rule). A no-op (already starred / already un-starred) answers `changed: false`, no undo entry, no receipt, the landed Activity line (the VX-362 apply_tag shape). Activity speaks it in words; the receipt family as every edit act. A fenced or unreached target answers the ONE not-shared shape, byte-identical (no oracle).
2. **The mint flow on star-rule gatherings — the VX-549 revisit.** The spec-defensible default: `intoGathering`'s planner flips to `starrable: true` — the ONE planner (`gatheringMintOutcome`), now her own door's shape WITH the star, so `create_note` / `import_document` into a star-rule gathering mints the note starred (born-starred, cap-exempt — trace `newPostInGathering`'s exact arm and mirror it) and the note assembles in. The `needsStar` refusal retires from the wire's mint road. **The mint-then-star order is this build's one product call — if your trace finds it genuinely open (e.g. a reason write_new should NOT star), build the most spec-defensible, mark PROVISIONAL, bundle it (RB-1).** The pure `tagsCanSatisfy`/`needsStar` functions stay (the sheet and picker may still want the fact).
3. **The seven wording points (the ticket's block — every one addressed, each disposition recorded):** (i) the grant sheet's star-rule why retires or rewords (the sheet stops shaping such a grant read/suggest-only — `offeredRungs(needsStar:)` offers all four rungs once write new can satisfy); (ii) the picker row's "read and suggest only" footing retires with the shaping; (iii) the wire refusal "Its rule needs a starred note, and only the author can star one." retires if the mint flow stars, else rewords to point at set_starred; (iv) **VX-609** — the just-in-time ask on a star-rule gathering becomes legitimate: its copy and offered durations follow the new reach instead of being removed (if the mint flow stars, the ask's write-new offer is honest again — pin the P-2 dead-door shape red-on-old on the PRE-fix tree if feasible, else by construction with the mechanism stated); (v) the guide's gathering card gains the star clause if the mint flow stars (don't conflate with VX-367's edit-acts lesson); (vi) MCPSpec's VX-549 paragraph lines — DRAFT the closeout's replacing lines in your "Canon owed" block, apply nothing (the two-file rule); (vii) `MCPSession.instructions` — touch only if the edit-rung description must name starring; the ≤3,000 cap stands (2,988 now; batch 3's VX-619 ALSO needs instruction room — spend none you don't need, and record the count you leave).
4. **Scopes and descriptions:** `set_starred` declared in the catalog at its scopes; every description that enumerates the edit rung's acts or grant places says only what is true as built. No raw Swift case reaches the wire (extend the refusal-sweep pin's walked set as VX-549's batch did).

**Evidence of its kind:** state-transition tests per op path (star a note / a book; un-star; the no-op; the cap's worded refusal; intake seats/bells on a wire star exactly as on hers; fenced target answers the one shape; the undo entry's write-back-while-unchanged rule); the mint-flow flip's red-on-old (the star refusal pin flips DELIBERATELY, citing the ticket's ruling, never silently — the VX-273-flip precedent, and sweep for every pin that asserts the old shaping: the sheet's `offeredRungs`, `starRuleWhy`, the ask's withholding, `MCPLibraryParityFacesTests`' scope expectations — the final-window lesson); VX-609's ask-shape pin; `swift build` + targeted suites green; Mac pins compiled into FRESH `DerivedData/b1` (never a clone), run riding the orchestrator's window.

**Checkpoint rules (binding):** commit per coherent piece, push after every commit; LIVE STATUS in this file's BATCH 1 RECORD from your first commit, flipped per piece in the same commit; PENDING on every unverified claim; foreground waits only; one batch, this batch, nothing else. When done: fill the BATCH 1 RECORD (trace, mechanism, pins with names, dispositions, the seven wording points' table, files touched, counts, canon-owed draft), commit, push, report.

---

## BATCH 2 BRIEF — the pane's honesty: VX-590 · VX-605 (both Pre-launch)

**Extra required reading:** the VX-548 record's BATCH 1 RECORD (the pane's current shape: the tabs, VX-512's zero-state line, `MCPPane.saysClientsBelongToTheLibrary`) and BATCH 2b RECORD (the connection story: `MCPServerHost.serve`, `onConnectionsChanged`, the stop roads — don't regress rows 1–12 of its sweep table) · the two ticket bodies IN FULL. Code anchors: `Features/MCP/MCPPane.swift` (the tabs, the Clients row ~:432, the open-on-Connect/Clients memory) · `MCPPaneCopy.swift` · `Sources/VariorumMCP/MCPServerHost.swift` (`serve`, `onConnectionsChanged`) · `MCPSession.swift` (`self.name = admitted` at initialize, ~:339 — VX-605's traced silence) · `Features/MCP/MCPDoor.swift` (`connected`, the pane's reader).

**VX-590 (her words on the ticket):** "what's the lift on only showing the 'share with AI' in the settings menu if someone has connected an MCP server? ... I don't want someone who doesn't use AI to see that & get scared that their work is shared." Design care: **the Connect road stays findable** (it is how the first client arrives); it's the sharing/grants face that hides while no client exists. Build: the Shared with AI tab (and any sharing face the pane shows clientlessly) renders only once the library has ever had a client — the honest store fact is the client rows (pending + approved + denied, VX-512's own gate) and/or the activity log; pick the most defensible, state it, PROVISIONAL the wording of anything the hidden state says (RB-3). Probe what already gates the app-wide share doors (VX-272's canShare gates place-side faces on an approved client) — if they are already hidden clientlessly, record that as VERIFIED, don't rebuild. The pane's open-on memory (opens on Connect while no client is approved) and VX-512's zero-state line stay.

**VX-605 (traced on the ticket, read-only — verify the trace, then pin):** `MCPServerHost.serve` fires `onConnectionsChanged` when a session registers, BEFORE it has a name; `MCPSession` sets `self.name = admitted` at initialize and signals nothing — so a client reconnecting under an already-bound key serves calls while the Clients row reads "last seen N seconds ago", catching up only on a later event. Fix at the traced seam: the session's naming moment signals the same connections-changed road (or the host observes it), so the Clients row's connected set refreshes when a connection NAMES itself. Red-on-old pin at the honest seam (a named live connection reads connected, never "last seen"); don't regress VX-394's end-line sweep (rows 1–12) or the VX-180/181 pre-init window.

**Evidence:** red-on-old pins per member (VX-605's by behavioral revert; VX-590's by construction if the gate is new — state the mechanism); the pane's existing suites green (`MCPPaneTests`, `MCPPaneTabsTests`, the zero-state pin — VX-590 CHANGES what a clientless pane shows, so re-read `aFreshPaneOpensOnConnectWithItsCodeBlockInSight` and VX-512's line pin and make any edit a JUSTIFIED one, cited); `swift build` + targeted suites green; Mac pins compiled into FRESH `DerivedData/b2`.

**Checkpoint rules:** as batch 1's. Fill the BATCH 2 RECORD.

---

## BATCH 3 BRIEF — the wire's imports & docs: VX-565 (probe) · VX-566 · VX-567 + rider VX-619

**Extra required reading:** the VX-548 record's BATCH 1 RECORD (VX-515 ask 2 — `Queries.mcpSharedGroups` verified honest; P-VX393-1…3) · MCPSpec's VX-252/VX-363 clauses (what a minted note answers; the book-name predicate) · the three ticket bodies + VX-619's IN FULL · the vx-548 BATCH 2b RECORD's reconnect options (C ruled — VX-619's birth). Code anchors: `Queries/MCPGrantQueries.swift` (`mcpSharedGroups`) · `VariorumMCP/MCPWriteTools.swift` (`import_document`'s two forms; `create_note`'s `section_id` arm — the shape VX-566 mirrors) · `MCPToolCatalog.swift` (descriptions) · `MCPSession.swift` (the instructions, the cap after batch 1) · `Features/Tutorial/TutorialSeeder.swift` (the guide's MCP chapter — VX-619's lesson).

- **VX-565 — PROBE FIRST (her kickoff: "VX-548 rebuilt that listing, re-probe on main").** Her report (relayed 2026-10-26, pre-VX-548): PlanetLillian (and "o ladrão de raios") show twice in the pane with different rungs. On TODAY's main: VX-516 fixed the cross-place revoke, VX-393 holds one standing row per client × place, P-VX393-3 keeps a once beside a standing row its own row, and VX-515's listing was verified honest (one row per place). The probe: reconstruct her report's shape against the merged listing — two rows per client are now HONEST when they are two places or a once beside a standing grant. If the rows are honest and the face doesn't say why, the fix is the face SAYING it (place/duration made visible per row — likely already shown; verify). If the probe finds the symptom gone, the disposition is RESOLVED-BY-VX-548 with the evidence, and the ticket closes on that record — no fix invented (the hallucination guard).
- **VX-566 — `import_document` takes `section_id`.** The agent report: importing 49 notes into a chapter cost 49 extra `file_note_in_chapter` calls; `create_note` already takes `section_id`. Build `create_note`'s exact shape onto the one-document form (with `book_id` only): the note files under that chapter in the same call and the same client-named undo; after the book's own decision, a `section_id` that is not a live chapter of that book answers the ONE chapter sentence `add_note_to_book` speaks (byte-identical). Probe whether the BOOK form (a folder-as-book import) has any honest `section_id` meaning — expected NO (its chapters come from the document); refuse or ignore per the existing arg-discipline, state which and why.
- **VX-567 — the book form answers per-take sha256s.** The agent report: the book form answers without per-take hashes, so verifying a batch means reading every note back. Build: the book form's answer gains per-note records in VX-252's exact shape (`note_id`, `block_ids`, `blocks` with per-take `take_id`/`label`/`sha256` — no text), built from what the act minted, never a second read; `book_id`, `note_ids`, `chapter_ids` stay (P-VX252-1 extended, flagged PROVISIONAL RB-4). Mind the answer's size honestly: it is ∝ the imported document itself (the client sent every byte), so no paging is owed — state that reasoning in the record. P-VX254-2 ("the book import answers none") flips DELIBERATELY, citing this ticket.
- **VX-619 — the lock/quit docs (her C pick).** `MCPSession.instructions` and the field guide's MCP chapter say plainly: locking or quitting Variorum ends every client connection by design (A-8), and the client reconnects with its own road (Claude Code: /mcp). The instructions cap is the work: ≤3,000 characters (R-VX184-3) — measure after batch 1's edit, trade a sentence in, record the trade and the final count. The guide's chapter stays seven lessons; the new sentences join the copy list (RB-5, her pass). Existing libraries hear the guide change only through Help ▸ Restore Field Guide… (standing); the real store's re-seed is a closeout note for her window.

**Evidence:** VX-565's probe record (evidence either way; a fix only on a traced mechanism); VX-566/567 red-on-old answer-shape pins (the old answer lacks the field/record — the VX-365 pattern), the deliberate P-VX254-2 flip cited; the descriptions' sentences pinned where the catalog pins exist; the instructions-cap pin (≤3,000) green; `swift build` + targeted suites green; Mac impact expected nil-to-small (the guide seeder pin if lesson text changes — a JUSTIFIED edit); FRESH `DerivedData/b3` if any Mac pin lands.

**Checkpoint rules:** as batch 1's. Fill the BATCH 3 RECORD.

---

## BATCH 4 BRIEF — VX-377: Move to Wing (and Copy to Wing) from the keyboard

**Extra required reading:** the VX-377 ticket body IN FULL (her two asks, the traced registry state) · SurfaceContracts "The app" (the keyboard family; the palette) and "The Bookcase and books" (the wing switcher; R-13ia-1's tag adoption rides the existing operations — untouched here). Code anchors: `App/Variorum/Variorum/Registry/CapabilityRegistry.swift` (`.moveNoteToWing` / `.copyNoteToWing` :2077–2089, `.moveBookToWing` :2096, ⌘L Switch Wing :2469–2484) · the palette's handling of acts that need a second pick (find the existing precedent — e.g. the wing-pick sheet the context-menu doors open) · `EditorCommands.keyEquivalent` (the chord collision sweep — READ ONLY, for the bundle).

**Her words:** (2026-10-16) "hmm yeah go ahead and file a ticket for that."; (10-21) "The keyboard shortcut for moving something to a wing I also basically need NOW for my own use - it should pull up a selector that I can also operate via keyboard to make it truly fast."

**The build (the ticket's own shape 1):** add the `.palette` door to `.moveNoteToWing`, `.copyNoteToWing` and `.moveBookToWing`, so "Move to Wing…" / "Copy to Wing…" are reachable from ⌘K on the focused note (and book). Gate by the existing rules: only while another wing exists, never on the daily Journal. The act opens the existing wing selector, and that selector must be fully KEYBOARD-OPERABLE (arrive focused, arrows + type-to-filter + ⏎ confirm, ⎋ cancels) — her "truly fast" ask; if the existing sheet already is, verify and pin; if not, the focus/keyboard wiring is this batch's one face fix. A registry-walk change (P-1) — the walk test covers the new doors by construction. **Shape 2 (a chord) is HER call — do not build; record the collision-sweep facts for the bundle (RB-6).**

**Evidence:** the registry walk green with the new doors; a Mac pin that the palette lists the doors exactly under their gates (another wing exists; not the daily Journal) and that the selector is keyboard-operable at whatever seam the palette's pins use; red-on-old by construction (the doors did not exist); `swift build` + Mac pins compiled into FRESH `DerivedData/b4`.

**Checkpoint rules:** as batch 1's. Fill the BATCH 4 RECORD.

---

## THE LADDER (after the batches; the run's whole diff)

**Re-list VX-620's sub-issues FIRST (the member-resolution rule — the roster may have grown).** Fresh `fable-reviewer` per round, `notes/REVIEW_PROMPT.md` VERBATIM with zero framing (the diff is MCP/default's-meaning — Fable reviews). Round 1 → fixes (implementer applies confirmed fixes, red-on-old per finding) → round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; hard cap three. Cross-model flow: findings go to the implementer verbatim, its agree/dispute returns to the reviewer, the reviewer makes the final call; FINDER-FIXES only per its mark (then one implementer sanity pass). Findings + dispositions land in this file before the next round. Disputes on undefined product behavior → QUESTIONS.md.

## CLOSEOUT CHECKLIST (the standing ritual; run at the merge, on latest main, serialized through the coordinator)

Results + counts here; the sub-issue listing re-run and every member accounted for (the VX-548 lesson — no orphans, PROVEN by the listing); in-flight row retired; canon deltas in the two-file shape (MCPSpec's VX-549 star-rule lines replaced as built; the set_starred clause; VX-566/567's answer clauses; the instructions/docs lines; SurfaceContracts only if a cross-cutting rule changed; AppSpec §12/§9 only if the summary's words went false) + the dated entry and narrative appended to `notes/AppSpecRecord.md`; `Tools/canon-size` run, its line in the handoff; the QUESTIONS.md bundle (§THE BUNDLE below); tickets closed per member (Done rides the PR merge), every ticket the run FILES triaged to the labeling rule; rulings reconciled ("every", "everywhere" re-read against what shipped — the star-rule sweep especially); MOBILE PARITY line (expect "nothing mobile-visible" — the phone has no MCP door and no ⌘K; CONFIRM `VariorumMobile/` untouched); the PR merges as a MERGE COMMIT titled `VX-620: …`; branch + worktree removed after merge; build debris (`DerivedData/b1…b4`) + walk evidence deleted; the real store's field-guide re-seed noted for her window IF guide lesson text changed (VX-619); the author handoff `notes/handoffs/vx-620-handoff.md` with her checklist at top; memory updated; hard stop. NO release, NO `/Applications` refresh (her word).

---

## THE BUNDLE (accumulates; becomes the QUESTIONS bundle and the handoff's checklist)

- **RB-0 (kickoff fact, for her eyes):** her kickoff said SIX members; the sub-issue listing said SEVEN (VX-377, re-parented at VX-439's closeout). The listing governed — exactly the rule's purpose. VX-377 runs as batch 4.
- **RB-1 (PROVISIONAL, batch 1):** the mint-then-star call — whether `create_note`/`import_document` into a star-rule gathering stars at WRITE NEW through her door's planner. (Batch 1 records the as-built choice.)
- **RB-2 (rider offers, the standing rule — NOT seated without her word):** open tickets in this run's Areas, cheapest while this code is warm: VX-367 (guide lesson 3's edit acts) · VX-368 (the parity audit — set_starred retires one row) · VX-369 (raw errors reaching the wire) · VX-606 (read_note's undeclared-argument acceptance) · VX-612/613 (the server races). Also noted: VX-189 (Backlog, "share a gathering directly") looks substantially DELIVERED by VX-549 — her triage call whether it closes or narrows to MB-18's place doors.
- **RB-3 (PROVISIONAL, batch 2):** VX-590's exact visibility fact and any hidden-state wording.
- **RB-4 (PROVISIONAL, batch 3):** VX-567's book-form answer shape (P-VX252-1 extended; P-VX254-2 flipped).
- **RB-5 (copy, her pass, batch 3):** VX-619's two docs sentences + the instructions trade; batch 1's reworded star strings join the same list.
- **RB-6 (her call, batch 4):** a chord for Move to Wing — the collision-sweep facts recorded; the ⌘K door ships either way.
- (Batch records append more.)

## LEDGER

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Worktree + branch + in-flight row + Linear In Progress + riders seated | orchestrator | DONE (in-flight on main; branch pushed; VX-609/VX-619 sub-issues) |
| 2 | This plan file | orchestrator | DONE |
| 3 | Batch 1 (VX-596 + VX-609) | opus-implementer №1 | NOT STARTED |
| 4 | Batch 2 (VX-590 · VX-605) | opus-implementer №2 | NOT STARTED |
| 5 | Batch 3 (VX-565 · VX-566 · VX-567 + VX-619) | opus-implementer №3 | NOT STARTED |
| 6 | Batch 4 (VX-377) | opus-implementer №4 | NOT STARTED |
| 7 | Orchestrator acceptance windows (stage via oct27coordinator) | orchestrator | NOT STARTED (plan: a mid window after batches 1–2, the final window after 3–4 + ladder fixes) |
| 8 | The ladder (whole-run diff, fable-reviewer; roster re-listed first) | orchestrator | NOT STARTED |
| 9 | Closeout + handoff + QUESTIONS bundle | orchestrator | NOT STARTED |

## SITTING / RULING RECORD (anything she says mid-run lands here verbatim, same turn)

*(empty so far)*

---

## BATCH 1 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins are written and COMPILED (`build-for-testing` into a FRESH
`DerivedData/b1`), their RUN PENDING the orchestrator's stage window; no canon edit (MCPSpec's replacing lines are
DRAFTED below, the two-file rule); `MCPSession.instructions` untouched unless the record below says otherwise; nothing
in `Sync/`, `Server/`, custody, the synced schema or the editor seam.

*Implementer: `opus-implementer` №1 (xhigh), fresh session, 2026-10-27. Read in its own context before any code:
CLAUDE.md + its canon, this plan IN FULL, `notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · The
Bookcase and books · Doors to the outside), `notes/SessionResiliencyProtocol.md`, the VX-548 record's BATCH 3 BRIEF /
HER SITTING / BATCH 3 RECORD / THE DELIBERATE FLIPS / MB-16·17·19·22 / the L1 + round-2 ladder entries, QUESTIONS
#243 (MB-16/MB-17 still PROVISIONAL — followed), the VX-596 and VX-609 ticket bodies (read-only), and the code
anchors the brief names. No subagent.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.**
- **0 · Preflight + this record:** DONE (this commit).
- **1 · Pins first (red on the pre-fix tree):** DONE (this commit) — `MCPGatheringGrantServerTests`: the deliberate
  flip `aRuleThatNeedsAStarMintsTheNoteStarredWithOneClientNamedUndo` (was `…RefusesWriteNewInWordsAndWritesNothing`),
  `aStarOrATagRuleTakesTheTagOnTheWire` grown (the star-only leg + the unsatisfiable leg + "nothing starred"), and
  VX-609's `anAnsweredAskOnAStarRuleGatheringLandsTheNoteNeverADeadDoor`. RED ON THE PRE-FIX TREE
  (`scratchpad/b1-logs/pins-red-on-old.log`): 11 tests / 1 suite, 3 red with 6 issues — every red leg the refusal
  "Its rule needs a starred note, and only the author can star one." (VX-609's retry after her answered Once among
  them: the P-2 dead door, reproduced); the 8 others green. The pins are committed RED; the fix follows.
- **2 · The mint flow (RB-1):** NOT-STARTED — settled design below (THE DESIGN, item 1).
- **3 · `setStarredForClient` (core op + exact-row undo):** NOT-STARTED.
- **4 · `set_starred` on the wire (catalog, decisions, answers, Activity):** NOT-STARTED.
- **5 · The faces + the seven wording points + the deliberate flips:** NOT-STARTED.
- **6 · Suites + Mac `build-for-testing` (fresh `DerivedData/b1`):** NOT-STARTED.

### THE DESIGN (settled before code; each PROVISIONAL item is bundled)

1. **The mint flow on a star-rule gathering (RB-1, PROVISIONAL).** The trace (`newPostInGathering` ·
   `Operations.mintNoteEntry`'s gathering arm · `GatheringMint.outcome`): her door plans with the star allowed, so an
   any-of group takes its FIRST satisfiable option — `★ OR #a` stars and does not tag. Flipping the wire's planner to
   `starrable: true` outright would therefore change VX-549's RATIFIED, pinned behaviour on every rule a tag could
   already satisfy (`MCPGatheringGrantServerTests.aStarOrATagRuleTakesTheTagOnTheWire` flips: the wire would star where
   it tags today), and every such mint would put a cap-exempt star in her Starred list. The build takes the narrower
   road: **the wire plans as VX-549 built it (the star forbidden — tags wherever tags can satisfy), and ONLY where that
   plan is `.blocked(.needsStar)` — exactly the rules VX-549 refused — does it plan with the star (her door's plan,
   `starrable: true`)**: born starred through the ONE star write, cap-exempt (`newPostInGathering`'s arm, mirrored),
   the star written right after the rule's tags (her door's order), intake hearing it. The `needsStar` refusal retires
   from the wire. Options for her: (a) her door's planner outright (`★ OR #a` stars on the wire too); **(b) as built —
   tags first, the star only where a star is the only way in**; (c) keep refusing, reworded to point at `set_starred`.
2. **`set_starred` (EDIT).** `note_id` XOR `book_id`, `starred` (boolean, required). A note decided at EDIT through the
   one `decide` (note · book · gathering · wing grants; the fence wins); a book at EDIT through `decide(book:)`; a
   GATHERING id the client can read answers the existing gathering sentence (P-VX196-2's posture — read, never changed
   through this door; the sentence now names starring among the author's acts — PROVISIONAL, bundled); anything else
   unreachable the ONE not-shared shape. The act is `Operations.setStarredForClient` — the caller's guard FIRST inside
   the act's transaction, then her `writeStar` (the union star, the cap 15, the self-heal, intake on a note's star; un-star
   a non-event). A star already as asked writes nothing: `changed: false`, no undo entry, no receipt, the landed Activity
   line (VX-362's shape). ONE client-named undo entry per landed act — her door registers none; the MCP road wraps it
   (`move_note_to_wing`'s precedent). Each half is compare-and-set on the STAR (writes only while the target still reads
   the value the act — or the last half — left: starred or not, by the union), quiet otherwise (VX-276), and puts the
   star back AT THE PLACE IN THE STARRED LIST it was taken from (so an un-star's undo returns the row where it stood, not
   at the end). The replays are not applying acts (`apply_tag`'s replay doctrine — an exact revival seats nothing); a
   replay that would star past the cap refuses in her words and keeps its entry (resolvable: un-star one, then ⌥⌘Z).
3. **The faces (the seven points — the table lands at the end).** The grant sheet stops shaping a star-rule gathering
   (all four rungs); its why line is reworded into a heads-up shown only at write new or edit on such a gathering ("a
   new note a client writes here is starred"); the picker's "read and suggest only" footing retires; the gathering
   write-new rung sentence (the sheet's HOW MUCH line AND the ask's lead — one function) says the star; the guide's
   gathering card gains the star clause and lesson 3's Edit card names starring; `MCPSession.instructions` untouched
   (2,988 — nothing in it is false as built); MCPSpec drafted only.
