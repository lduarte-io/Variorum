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
| 1 — starring on the wire | VX-596 + rider VX-609 | opus-implementer №1 | DONE (Mac run + walk PENDING the window) |
| 2 — the pane's honesty | VX-590 (Pre-launch) · VX-605 (Pre-launch) | opus-implementer №2 | DONE (Mac run + walk PENDING the window) |
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
- **RB-1 (PROVISIONAL, batch 1):** the mint-then-star call — whether `create_note`/`import_document` into a star-rule gathering stars at WRITE NEW through her door's planner. **As built (batch 1):** TAGS FIRST (VX-549's plan, byte-unchanged for every rule a tag can satisfy), born STARRED (cap-exempt, her door's arm) only where a star is the only way in; the answer adds `starred: true`. Options (a) her door's planner outright · (b) as built · (c) keep refusing, reworded · (d) the wire's star respects the cap — the BATCH 1 RECORD's bundle section has the consequences.
- **RB-2 (rider offers, the standing rule — NOT seated without her word):** open tickets in this run's Areas, cheapest while this code is warm: VX-367 (guide lesson 3's edit acts) · VX-368 (the parity audit — set_starred retires one row) · VX-369 (raw errors reaching the wire) · VX-606 (read_note's undeclared-argument acceptance) · VX-612/613 (the server races). Also noted: VX-189 (Backlog, "share a gathering directly") looks substantially DELIVERED by VX-549 — her triage call whether it closes or narrows to MB-18's place doors.
- **RB-3 (PROVISIONAL, batch 2):** VX-590's exact visibility fact and any hidden-state wording. **As built (batch 2):**
  the sharing face (the Shared with AI tab + the open book inside it) shows once a client row exists — waiting,
  approved or denied (VX-512's fact read the other way; monotone — "ever"); no new words (nothing names the hidden
  tab). Options (a) as built · (b) also while the open book is ON · (c) an approved client only (VX-272's gate) — the
  BATCH 2 RECORD's bundle section has the consequences.
- **RB-4 (PROVISIONAL, batch 3):** VX-567's book-form answer shape (P-VX252-1 extended; P-VX254-2 flipped).
- **RB-5 (copy, her pass, batch 3):** VX-619's two docs sentences + the instructions trade; batch 1's reworded star strings join the same list (batch 1's list: the BATCH 1 RECORD's bundle section — the tool description, Activity's "changed the star on", the receipts, the undo labels, `starHeadsUp`, the gathering write-new sentence, the guide's two edits, `create_note`'s sentence, `gatheringWords`' "starring", `needsStar`'s bare fact). **Batch 1 left `MCPSession.instructions` untouched: 2,988 / 3,000 — 12 characters for VX-619.**
- **RB-6 (her call, batch 4):** a chord for Move to Wing — the collision-sweep facts recorded; the ⌘K door ships either way.
- **RB-7 (PROVISIONAL, batch 1):** `set_starred` on a gathering's id answers the gathering sentence (P-VX196-2's posture), now naming "starring" among the author's acts; alternative: R-VX184-1 parity — an edit grant reaching the gathering place stars it.
- **RB-8 (design calls, batch 1 — for the ladder or her):** `set_starred`'s undo halves restore the star AT ITS PLACE in the Starred list, are not applying acts (a re-star replay seats nothing), refuse past the cap keeping the entry, and bring a column-only book's star back in both stores.
- **RB-9 (ticket to file, batch 1):** a third load-sensitive pin — `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` timed out once under the full-parallel headless run, green isolated and in a second whole run (Tests & tooling, the VX-532 class).
- **RB-10 (her call, batch 2 — not built):** two AI-naming faces still show in a library that never had a client,
  outside the pane her VX-590 words named: the note's Private row "Private — never shared with AI", and the ⌘/
  helper's / Settings ▸ Shortcuts' MCP group (⌥⌘A, ⌥⌘O). Leave · hide clientlessly · reword, per face.
- **RB-11 (for the ladder, batch 2):** VX-605's sweep row 5 — VX-258's in-handler flip signals nothing; unreachable in
  practice, traced, not fixed (no red pin without a handshake seam).
- (Batch records append more.)

## LEDGER

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Worktree + branch + in-flight row + Linear In Progress + riders seated | orchestrator | DONE (in-flight on main; branch pushed; VX-609/VX-619 sub-issues) |
| 2 | This plan file | orchestrator | DONE |
| 3 | Batch 1 (VX-596 + VX-609) | opus-implementer №1 | DONE 2026-10-27 — headless green (core 3477/464 · MCP 420/76 bar VX-532, isolated green · Strings 32/4); Mac pins COMPILED into fresh `DerivedData/b1`, RUN + walk PENDING the window; record: BATCH 1 RECORD |
| 4 | Batch 2 (VX-590 · VX-605) | opus-implementer №2 | DONE 2026-10-27 — headless green (core 3477/464 · MCP 423/77 bar VX-532, isolated green · Strings 32/4); VX-605 red-on-old on the pre-fix tree AND under the behavioural revert; VX-590 red by construction; Mac pins COMPILED into fresh `DerivedData/b2`, RUN + walk PENDING the window; record: BATCH 2 RECORD |
| 5 | Batch 3 (VX-565 · VX-566 · VX-567 + VX-619) | opus-implementer №3 | NOT STARTED |
| 6 | Batch 4 (VX-377) | opus-implementer №4 | NOT STARTED |
| 7 | Orchestrator acceptance windows (stage via oct27coordinator) | orchestrator | NOT STARTED (plan: a mid window after batches 1–2, the final window after 3–4 + ladder fixes) |
| 8 | The ladder (whole-run diff, fable-reviewer; roster re-listed first) | orchestrator | NOT STARTED |
| 9 | Closeout + handoff + QUESTIONS bundle | orchestrator | NOT STARTED |

## THE MID WINDOW — PLAN (claim `vx620-mid`, accepted by oct27coordinator with three conditions; READY sent after batch 2)

**Shape:** tests FIRST (one `test-without-building` invocation from the FRESH `DerivedData/b2`, which holds batches 1+2 — the union of both batches' "For the orchestrator" suite lists; executed counts per VX-604) → **SEAM ping** to the coordinator (a merge-gating run may slot in; yield if vx-601/vx-562 is READY) → the WALK (an Opus walker under the claim; batch 1's six legs + batch 2's V1/V2; both voices where a face shows; restore steps per the batch records).

**The coordinator's three conditions (2026-10-27, folded verbatim-faithfully):**
1. The walk's leg 0 records the dev store's as-found Enable-the-MCP-server state; the restore returns to THAT state, not blanket OFF; the RELEASE line carries both values (found, returned).
2. The fresh setup key under claude-code's bound name is the standing VX-258 road (a pane-tab copy carries the name, re-binds with zero clicks, no `mcp_rebind_request`); the changed key hash on the dev row is expected residue, NAMED at release. The key value lives only in the walk's gitignored scratch; the clipboard is cleared at restore.
3. The RELEASE line names the residue that can't be undone: the walk's Activity rows (the 500-act window), revoked/spent grant tombstones, the superseded setup-key row and the re-bound hash.

**VX-590's hidden-state leg (V3): NOT walked** — the dev store as found holds the claude-code row, and a throwaway-library reset buys nothing the Mac pin (`MCPSharingFaceTests`, a real door) hasn't proven. The shown-state leg (V2) walks; recorded here so the window's evidence story is honest.

## SITTING / RULING RECORD (anything she says mid-run lands here verbatim, same turn)

*(empty so far)*

---

## BATCH 1 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins are written and COMPILED (`build-for-testing` into a FRESH
`DerivedData/b1`), their RUN PENDING the orchestrator's stage window; no canon edit (MCPSpec's replacing lines are
DRAFTED below, the two-file rule); `MCPSession.instructions` UNTOUCHED (2,988 / 3,000 — 12 characters left for
VX-619); no ticket filed or moved (RB-9's flake ticket is the orchestrator's to file); a gathering's OWN star not built
(RB-7); nothing in `Sync/`, `Server/`, custody, the synced schema, the editor seam or `VariorumMobile/`.

*Implementer: `opus-implementer` №1 (xhigh), fresh session, 2026-10-27. Read in its own context before any code:
CLAUDE.md + its canon, this plan IN FULL, `notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · The
Bookcase and books · Doors to the outside), `notes/SessionResiliencyProtocol.md`, the VX-548 record's BATCH 3 BRIEF /
HER SITTING / BATCH 3 RECORD / THE DELIBERATE FLIPS / MB-16·17·19·22 / the L1 + round-2 ladder entries, QUESTIONS
#243 (MB-16/MB-17 still PROVISIONAL — followed), the VX-596 and VX-609 ticket bodies (read-only), and the code
anchors the brief names. No subagent.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (The announced revert RAN over `7aa602636` and was restored by `git
  checkout --`, `git diff` clean after — see piece 3.)
- **0 · Preflight + this record:** DONE (this commit).
- **1 · Pins first (red on the pre-fix tree):** DONE (this commit) — `MCPGatheringGrantServerTests`: the deliberate
  flip `aRuleThatNeedsAStarMintsTheNoteStarredWithOneClientNamedUndo` (was `…RefusesWriteNewInWordsAndWritesNothing`),
  `aStarOrATagRuleTakesTheTagOnTheWire` grown (the star-only leg + the unsatisfiable leg + "nothing starred"), and
  VX-609's `anAnsweredAskOnAStarRuleGatheringLandsTheNoteNeverADeadDoor`. RED ON THE PRE-FIX TREE
  (`scratchpad/b1-logs/pins-red-on-old.log`): 11 tests / 1 suite, 3 red with 6 issues — every red leg the refusal
  "Its rule needs a starred note, and only the author can star one." (VX-609's retry after her answered Once among
  them: the P-2 dead door, reproduced); the 8 others green. The pins are committed RED; the fix follows.
- **2 · The mint flow (RB-1):** DONE (this commit) — `GatheringMint.starringOnlyWhereNeeded` (pure; the
  star-forbidden walk first, her door's walk only on `.blocked(.needsStar)`) + `Queries.gatheringWireMintOutcome`;
  `mintNoteEntry`'s gathering arm plans through it and writes the star right after the rule's tags through
  `writeStar(…, enforcingCap: false)` (her door's arm); `DocumentImport.starred` → the answer's additive
  `starred: true` (absent otherwise). `Blocker.needsStar.reason` reworded to the bare fact ("Its rule needs a starred
  note." — no door speaks it now). GREEN (`scratchpad/b1-logs/mint-green.log`): the wire suite 11/1 (the three pins
  red at `5c88eee55` now green) + the core 42/5 (`GatheringTagsSatisfyTests` with the new wire table + the flipped
  reason pin, `GatheringMintTests`, `CollectSetsTheStarTests`).
- **3 · `setStarredForClient` (core op + exact-row undo):** DONE (this commit) — `Operations+MCPStars.swift`
  (`setStarredForClient`, `replayMCPStar`), `writeStar` grows `at:` + `heard:` (both defaulted — every other caller
  byte-unchanged; `starTargetIsLive` internal), `MCPWriteAct.star` / `.unstar`. `MCPStarActsTests` (9) GREEN
  (`scratchpad/b1-logs/star-acts.log`); red on old by construction (no such act). **BEHAVIOURAL REVERT RUN**
  (`star-acts-revert-red.log`: the replay's place → `nil`, `heard` → `true`, its compare-and-set removed): **4 of 9
  red, 11 issues** — `anUnstarsUndoPutsTheStarBackWhereItStood`, `eachHalfWritesOnlyWhileTheStarReadsItsPartnersValue`,
  `aReplayedStarIsNoApplyingAct`, `aHalfThatWouldPassTheCapRefusesAndKeepsItsEntry`; restored, GREEN again
  (`star-acts-restored.log`, 9/1).
- **4 · `set_starred` on the wire (catalog, decisions, answers):** DONE (this commit) — `MCPWriteTools+Star.swift`
  (parse + perform: a note through `onNote` at EDIT + `guardEdit`, a book through `onBook` at EDIT + `guardBooks`, a
  readable gathering hearing `gatheringWords` — now naming starring), `Job.setStarred` (flushes nothing; writes no
  text), `MCPToolCatalog.setStarred` (EDIT, every scope), `create_note` / `import_document` descriptions say the born
  star. `MCPStarServerTests` (7, over the socket) GREEN (`star-wire.log`); red on old by construction (no such tool).
  Justified edits: `MCPServerTests.everyDeclaredToolIsHandledAndEveryHandledToolDeclared` (the edit set +
  `set_starred`) and `MCPWriteServerTests.aSuggestGrantProvablyCannotModifyAnExistingTake` (the proof's completeness —
  two `set_starred` calls refusing at the rung). The whole MCP target before these two edits: 420/76 with the two
  expected reds (the catalog-completeness pin) + VX-532's standing flake (`mcp-all-1.log`); the suggest proof green
  after (`mcp-fix-1.log`). Activity's words ride piece 5 (the app's table).
- **5 · The faces + the seven wording points + the deliberate flips:** DONE (`695161d4c` + this commit) —
  `MCPPaneCopy` (Activity's words for `set_starred`, the `.star`/`.unstar` receipts, the gathering write-new rung
  sentence with the star, `starHeadsUp` replacing `starRuleWhy`, `readAndSuggestOnly` retired), `MCPGrantPicker`
  (`offeredRungs(needsStar:)` retired → `starHeadsUp(needsStar:rung:)`; the footing retired), `MCPGrantSheet` (every
  rung offered; the heads-up at write new/edit; the clamp + onChange retired), `TutorialSeeder` (lesson 3's Edit card
  names "star, unstar"; the gathering card's star clause). Mac pins: NEW `MCPStarFacesTests` (5); FLIPS in
  `MCPGatheringGrantFacesTests` (3) + VX-609's new face pin; JUSTIFIED EDITS in `TutorialMCPChapterTests`. COMPILED:
  `build-for-testing` into the FRESH `DerivedData/b1` — **TEST BUILD SUCCEEDED** (`scratchpad/b1-logs/mac-bft1.log`);
  no new warning in a touched file (the two in the log are pre-existing: `MCPGrantPicker.swift`'s
  `durations(connected:)` isolation warning and `MCPGatheringGrantFacesTests`' redundant `#require`, batch 3's,
  moved from :104 to :122). **PENDING:** the Mac run (the stage).
- **6 · Suites + Mac `build-for-testing` (fresh `DerivedData/b1`):** DONE (this commit) — counts under "Suites"
  below. **PENDING:** the Mac pins' RUN (the stage) and the walk (the orchestrator's window).

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

### THE TRACE (inputs → wrong state), the mechanisms the build closes

- **VX-609 — the dead door (traced, then reproduced red at `5c88eee55`).** A client holding READ on a gathering whose
  rule is `#parser AND ★` calls `create_note {book_id: <gathering>}` → `MCPWriteTools.into` finds no book facts,
  finds gathering facts (`admitsGathering`), and `intoGathering` decides the PLACE at write new
  (`MCPGrantAuthority.decide(…, gathering:, rung: .writeNew)`): refused `rungTooLow`, and because the gathering is
  unfenced the ask is raised ON the gathering at `.writeNew` — the ask never consulted the rule. Her answer
  (`MCPDoor.answer` → `grantMCPAccess(spec(ask.rung, ask.scopeKind, ask.scopeID, duration))`) minted a write-new
  gathering grant. The retry passes the decision, lands in `mintNoteEntry`'s gathering arm, where
  `Queries.gatheringMintOutcome(…, starrable: false)` answers `.blocked(.needsStar)` → `smartFilterUnsatisfiable`
  → "Its rule needs a starred note, and only the author can star one." — the grant minted by her answer could never
  act (P-2), unspent. Red on the pre-fix tree: `anAnsweredAskOnAStarRuleGatheringLandsTheNoteNeverADeadDoor`, the
  retry's text exactly that sentence (`scratchpad/b1-logs/pins-red-on-old.log`).
- **The mechanism closed:** the refusal's premise (no star on the wire) is gone — the wire's write new plans through
  `GatheringMint.starringOnlyWhereNeeded` (THE DESIGN, item 1), so exactly the rules that answered `.needsStar` now
  plan her door's starred plan, and the note is born starred through `writeStar(…, enforcingCap: false)` right after
  the rule's tags. The ask's face needed no structural change: its durations were always the honest ones for an
  unfenced gathering; what was dead was the act, and the act now lands. Its lead (`rungDetail(.writeNew, .gathering)`,
  the sheet's HOW MUCH line too — one function) now says the star.
- **The order inside the mint** (her door's, `newPostInGathering`): the rule's tags, the star, then (the wire's own
  addition since VX-549) the document's header tags, then the belt (`matchesRule` with a FRESH star context, so the
  belt sees the star the act just wrote). A header tag that breaks a NOT still unwinds the whole mint, star included.
- **The undo of a starred mint:** `registerMintedContainerEntry` tombstones the note; its star entry is then a dead
  list entry the read rule hides (`Queries.starred` reads live targets only) and the next star write self-heals away —
  the standing star semantics for any deleted starred note (pinned: `!starredNotes.contains(noteID)` after the undo).
  A redo revives the note; its star reads again unless a star write in between self-healed the entry (then the
  revived note reads unstarred and leaves the gathering — the same edge her own Put back of a trashed starred note has;
  recorded, not changed).

### PINS (red-on-old evidence)

- **Wire, `Tests/VariorumMCPTests/MCPGatheringGrantServerTests.swift`** — RED ON THE PRE-FIX TREE
  (`pins-red-on-old.log`, committed red at `5c88eee55`: 11 tests, 3 red, 6 issues), GREEN after (`mint-green.log`):
  `aRuleThatNeedsAStarMintsTheNoteStarredWithOneClientNamedUndo` (THE DELIBERATE FLIP — table below; with the Starred
  list FULL first, so the born star is proven cap-exempt; a living ★-rule book seats it; one client-named undo;
  `import_document` the same road) · `aStarOrATagRuleTakesTheTagOnTheWire` (grown: "nothing starred", no `starred`
  key; a star-only rule's mint starred and tagless; `#a AND NOT #a` still refusing in her words) ·
  `anAnsweredAskOnAStarRuleGatheringLandsTheNoteNeverADeadDoor` (VX-609).
- **Pure, `Tests/VariorumCoreTests/GatheringTagsSatisfyTests.swift`:** `theWirePlansTagsFirstAndStarsOnlyWhereAStarIsTheOnlyWayIn`
  (the unit table — 10 rules: every tag-satisfiable rule's wire plan IS the star-forbidden plan, every needs-a-star
  rule's IS her door's, the wire never answers `.needsStar`) + the flipped reason pin. Red on old by construction.
- **Core act, `Tests/VariorumCoreTests/MCPStarActsTests.swift` (9):** `aStarActStarsTheNoteAsHerStarDoesWithOneClientNamedEntry`
  (seat + bell exactly as her own star — her door the witness) · `anUnstarIsANonEventAndABookStarWritesBothStores` ·
  `aStarAlreadyAsAskedWritesNothingAndRegistersNoEntry` (no setting write, no outbox row, the column-only book) ·
  `theCapRefusesTheActAndWritesNothing` · `theGuardRunsFirstAndARefusalWritesNothing` ·
  `anUnstarsUndoPutsTheStarBackWhereItStood` · `eachHalfWritesOnlyWhileTheStarReadsItsPartnersValue` (VX-276, both
  halves, and a trashed note) · `aReplayedStarIsNoApplyingAct` · `aHalfThatWouldPassTheCapRefusesAndKeepsItsEntry`.
  Red on old by construction (no such act); BEHAVIOURAL REVERT RUN on the design lines — 4 of 9 red, 11 issues
  (`star-acts-revert-red.log`), restored green.
- **Wire act, `Tests/VariorumMCPTests/MCPStarServerTests.swift` (7, over the socket):**
  `aNoteStarredAtEditIsHeardAsHersWithOneClientNamedUndo` · `aStarAlreadyAsAskedAnswersChangedFalseWithNothingToUndo`
  · `aBookStarsUnderItsOwnGrantInBothStores` · `theCapRefusesThroughTheOneChainAndWritesNothing` ·
  `anUnreachedOrFencedTargetAnswersTheOneShapeAndBelowEditTheRungAsks` (a Private note, a ⌘J daily-Journal entry, a
  note of another wing, the daily Journal and a Private book — each byte-identical to a missing id; below edit the
  rung's sentence + her ask; not listed below edit) · `aGatheringsOwnStarIsTheAuthors` ·
  `theArgumentsAreSaidNeverGuessedAndAOnceGrantIsOneAct`. Red on old by construction ("Unknown tool").
- **Mac (COMPILED into `DerivedData/b1`, RUN PENDING the orchestrator's window):** NEW
  `App/Variorum/VariorumTests/MCPStarFacesTests.swift` (5: receipts both ways, undo labels, Activity's words allowed
  and refused, the tool's rung and scopes, the cap's words through the chain with `OpsRefusalCopy`); in
  `MCPGatheringGrantFacesTests` the three FLIPS (table) + NEW `theWriteNewAskOnAGatheringOffersItsDurationsAndSaysTheStar`
  (VX-609's face: durations `[.once, .always]` for a not-connected client, the lead says the star — red on old: the
  lead never said "starred"); `TutorialMCPChapterTests`' JUSTIFIED EDITS (below).

### THE DELIBERATE FLIPS (VX-549's star-rule shaping, superseded — her ruling 2026-10-27, "let's add the star over the wire, it might as well be included"; each cites it in its comment)

| Pin | Was | Now |
|---|---|---|
| `MCPGatheringGrantServerTests.aRuleThatNeedsAStarRefusesWriteNewInWordsAndWritesNothing` → renamed `aRuleThatNeedsAStarMintsTheNoteStarredWithOneClientNamedUndo` (wire) | `create_note` into `#parser AND ★` refused "Its rule needs a starred note, and only the author can star one.", nothing minted, the once grant unspent, no ask | the note lands born starred (cap-exempt past a full list), tagged, assembled in, heard by a living ★ book, one client-named undo, the once grant spent, `starred: true` in the answer |
| `GatheringTagsSatisfyTests.theWirePlanTakesATagWhereHerDoorWouldStar` — its last expectation (core) | `Blocker.needsStar.reason` == "Its rule needs a starred note, and only the author can star one." | == "Its rule needs a starred note." (no door speaks it now; the premise is gone) |
| Mac `MCPGatheringGrantFacesTests.aStarRuleGatheringOffersReadAndSuggestOnlyWithTheWhy` → renamed `aStarRuleGatheringOffersEveryRungWithAHeadsUpWhereANoteIsWritten` | `offeredRungs(needsStar: true) == [.read, .suggest]`; `starRuleWhy` "…only you can star one…" | every rung offered; `starHeadsUp(needsStar:rung:)` — the line at write new and edit only, nil for a tag rule |
| Mac `MCPGatheringGrantFacesTests.theGatheringPickerIsStarredThenAToZWithEachRowsFooting` | the star-rule row's footing contains "read and suggest only" | its footing is its shelf alone |
| Mac `MCPGatheringGrantFacesTests.theWordsAGatheringGrantWears` | `rungDetail(.writeNew, .gathering)` == "…wearing the tags its rule needs, and apply tags" | "…wearing the tags its rule needs (starred, if it needs a star), and apply tags" |

**Justified edits (not flips — a set grows or a sentence gains a clause):** `MCPServerTests.everyDeclaredToolIsHandledAndEveryHandledToolDeclared`
(the edit set + `set_starred`) · `MCPWriteServerTests.aSuggestGrantProvablyCannotModifyAnExistingTake` (the proof's
completeness: two `set_starred` calls, refusing at the rung) · `TutorialMCPChapterTests.lessonThreeHowMuchWhereHowLong`
(the Edit step's "star, unstar," + `set_starred` in its truth loop) and its fourth-card leg (the star clause + its
truth: `Queries.gatheringWireMintOutcome` plans a star-only gathering's note starred).

**The sweep for every pin asserting the old shaping (the brief's list, each read):** the sheet's `offeredRungs` —
FLIPPED (above); `starRuleWhy` — FLIPPED; "the ask's withholding" — no pin asserted one (the ask never withheld:
that was VX-609's finding; `MCPAskAndReceiptTests.anAskOffersOnlyTheDurationsThatCanActAsNamed` and
`MCPAsksWaitTests`' duration pins read fences only — untouched, still true); `MCPLibraryParityFacesTests`' scope
expectations — UNTOUCHED (no existing tool's rung or scopes changed; `set_starred` is pinned in its own faces suite);
the refusal sweep's walked set — UNCHANGED (no new `OperationError` case; `starLimitReached` was already walked and
worded; `smartFilterUnsatisfiable` stays reachable through the other blockers — 32 unspoken / 76 walked hold);
W-UX-14's truth pin (`MCPAskAndReceiptTests.anAsksRungSentenceClaimsOnlyWhatItsScopeAllows`) — holds (the gathering
line claims "new notes" and "tags" only, `create_note` and `apply_tag` both act under a gathering); the guide's
other cards — no pin on the changed prose outside `TutorialMCPChapterTests` (grep-swept).

### Suites (the end, on the final code — `swift build` green; the record's own commits change no code)

- **The whole headless run, twice** (`scratchpad/b1-logs/headless-all.log`, `headless-all-2.log`) — the SECOND is the
  verdict: VariorumCoreTests **3477 tests / 464 suites passed** (5 known issues, standing; this batch adds 10 —
  `MCPStarActsTests` 9 + the wire-plan table 1); StringsWorkbook **32 / 4 passed**; VariorumMCPTests **420 / 76 with
  ONE issue — the standing VX-532 flake** (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`,
  24.6 s against its 15 s under the full-parallel run; no harness line changed), re-run ISOLATED green ×2
  (`harness-isolated-1/2.log`: 3/1, 2.2 s each) — 412 + this batch's 8 (`MCPStarServerTests` 7 + VX-609's pin 1);
  VX-607 green both runs. **The FIRST run carried one more red, not reproduced:**
  `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` hit its one-minute `.timeLimit` (204.9 s elapsed,
  under the full-parallel load — a held `ValueObservation`'s `next()` starved); green ISOLATED ×2
  (`starcontext-isolated-1/2.log`: 11/1, 0.8 s each) and green in the whole second run. Not this diff's mechanism: the
  test drives her `setStarred` (whose `writeStar` this batch touched only by two DEFAULTED parameters — `at: nil`,
  `heard: true` — byte-identical on her road) and an observation on its own in-memory store; its own doc already records
  one starvation ("a 5 s poll starved there once"). A load-sensitive third beside VX-532/VX-607 — RB-9 (ticket for the
  orchestrator to file).
- **Targeted, along the way (each green):** `MCPGatheringGrantServerTests` 11/1 · `GatheringTagsSatisfyTests` +
  `GatheringMintTests` + `CollectSetsTheStarTests` (42/5 with the wire suite's run) · `MCPStarActsTests` 9/1 ·
  `MCPStarServerTests` 7/1 · `MCPWriteServerTests` 10/1 · `StarContextTests` 11/1 (×2).
- **Mac:** `build-for-testing` into the FRESH `DerivedData/b1` — **TEST BUILD SUCCEEDED** (`mac-bft1.log`, built from
  `695161d4c`'s sources — every later commit is record-only). **PENDING:** the Mac pins' run (the stage).

### THE SEVEN WORDING POINTS (the VX-596 ticket's block — each dispositioned)

| # | The string (VX-548's, PROVISIONAL) | Disposition | As built |
|---|---|---|---|
| 1 | The grant sheet's star-rule why: "Its rule needs a starred note, and only you can star one — so a client can read and suggest here, but not write new or edit." | REWORDED (the shaping retired) | Every rung is offered; at write new or edit only, one quiet line: "Its rule needs a star, so a new note a client writes here is starred." (`MCPPaneCopy.starHeadsUp`, shown through `MCPGrantPicker.starHeadsUp(needsStar:rung:)`; nil at read/suggest and for a tag rule) |
| 2 | The picker row's footing "read and suggest only" | RETIRED | The row's footing is its wing/shelf/marks/archived state, as every row (`MCPGrantPicker.gatheringOption`) |
| 3 | The wire refusal "Its rule needs a starred note, and only the author can star one." | RETIRED from every road | The wire stars where the rule needs it (RB-1); no door speaks `.needsStar`; the case keeps only the fact, "Its rule needs a starred note." (`GatheringMint.Blocker.needsStar.reason`) |
| 4 | The ask's shape on a star-rule gathering (VX-609) | LEGITIMATE — follows the new reach | Its durations stand (each honest — the answered grant now acts, pinned on the wire); its lead (one function with the sheet's line) says "…wearing the tags its rule needs (starred, if it needs a star), and apply tags." |
| 5 | The guide's gathering card | STAR CLAUSE ADDED | "…the note wears the tags the rule needs, starred if the rule needs a star." Also lesson 3's Edit card names the new act ("…take a tag off a note, star, unstar, rename, archive or delete notes and books…") — VX-197's truth-pass rule (every added tool taught where its rung's acts are named); VX-367's remaining-acts list NOT touched |
| 6 | MCPSpec's VX-549 paragraph lines | DRAFTED, NOT APPLIED | "Canon owed" below (the two-file rule) |
| 7 | `MCPSession.instructions` | UNTOUCHED — 0 characters spent | Nothing in it went false: the edit rung's list is examples ("most of what the author can do at the keyboard: …"), and "create_note into one applies its tags" stays true (it applies them; the star is said in `create_note`'s description). **The count stays 2,988 / 3,000** (the VX-548 batch 3 measurement; the string is byte-unchanged — `git diff` on `MCPSession.swift` is empty; `MCPAdviceServerTests`' bound pin green in the headless run) — **12 characters of headroom remain for batch 3's VX-619** |

### Files touched

Core: `Domain/GatheringMint.swift` (`starringOnlyWhereNeeded`, `wireGrammarOutcome`, the `needsStar` case's doc and
words, the docs of `starrable` / `tagsCanSatisfy` / `needsStar(_:)`) · `Queries/GatheringMintQueries.swift`
(`gatheringWireMintOutcome`) · `Queries/MCPGrantQueries.swift` (a doc) · `Operations/Operations+MCPWrites.swift`
(`MCPNoteDestination` doc; the gathering arm plans through the wire outcome and writes the star; `MCPWriteAct.star` /
`.unstar`) · `Operations/Operations+DocumentImport.swift` (`DocumentImport.starred`) · `Operations/Operations+Appearance.swift`
(`writeStar`'s `at:` / `heard:`, `starTargetIsLive` internal) · NEW `Operations/Operations+MCPStars.swift`. Wire:
NEW `VariorumMCP/MCPWriteTools+Star.swift` · `MCPWriteTools.swift` (`Job.setStarred`, the parse/perform arms, the
minted answer's `starred` key, `starredMintKey`) · `MCPToolCatalog.swift` (`setStarred`; `create_note` /
`import_document` descriptions) · `MCPWriteTools+LibraryEdits.swift` (`gatheringWords` names starring) ·
`MCPNullCharacters.swift` · `MCPWriteSupport.swift` (a comment). App: `Features/MCP/MCPPaneCopy.swift` ·
`MCPGrantPicker.swift` · `MCPGrantSheet.swift` · `Features/Tutorial/TutorialSeeder.swift`. Tests: NEW
`Tests/VariorumCoreTests/MCPStarActsTests.swift`, `Tests/VariorumMCPTests/MCPStarServerTests.swift`,
`App/Variorum/VariorumTests/MCPStarFacesTests.swift`; edits to `GatheringTagsSatisfyTests`,
`MCPGatheringGrantServerTests`, `MCPServerTests`, `MCPWriteServerTests`, Mac `MCPGatheringGrantFacesTests`,
`TutorialMCPChapterTests`. Untouched, by the lane: `Sources/VariorumCore/Sync/`, `Server/`, custody, every schema,
the editor seam, `VariorumMobile/`, `MCPSession.swift`.

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

- **MCPSpec, the VX-549 paragraph — replacing** "`create_note` / `import_document` with its id write a new note bookless
  in its wing wearing the tags its rule needs (her own gathering door's planner without the star; the ONE application
  road, so living books hear it; one client-named undo; VX-252's answer with VX-361's tags); a rule only a star could
  satisfy refuses in her door's words ("Its rule needs a starred note, and only the author can star one."), never the
  not-shared shape, and the grant sheet offers such a gathering read and suggest only, with the why." **with:**
  "`create_note` / `import_document` with its id write a new note bookless in its wing wearing the tags its rule needs
  — tags first, as her door's planner plans them without the star, and born STARRED (her door's star, cap-exempt) only
  where a star is the only way in (VX-596, PROVISIONAL RB-1 — `★ OR #a` takes #a); the ONE application road and the
  one star write, so living books hear both; one client-named undo; VX-252's answer with VX-361's tags, plus
  `starred: true` on a starred mint (absent otherwise). The grant sheet offers such a gathering every rung, saying at
  write new and edit that a client's new note there is starred; the just-in-time ask offers its honest durations."
- **MCPSpec, the EDIT rung's reach (R-VX184-1's list) — after** "a note deleted (the Trash, 30 days), archived or
  unarchived;" **add:** "a note or a book starred or un-starred (`set_starred` — VX-596, her ruling 2026-10-27, "let's
  add the star over the wire, it might as well be included"; the record `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`
  BATCH 1): her star write — the union star's two stores, the cap of fifteen refusing in her words, intake hearing a
  note's star as hers, un-starring a non-event; a star already as asked answers `changed: false` with nothing to undo;
  ONE client-named undo (her door has none — the `move_note_to_wing` wrap) whose halves write only while the star
  reads the value their partner left and put it back at its place in the Starred list, and are not applying acts; a
  gathering's own star is the author's (the gathering sentence);"
- **AppSpec / SurfaceContracts:** nothing goes false (AppSpec §12's MCP summary and SurfaceContracts' MCP bullet name
  neither the star nor the star-rule refusal; "Private, Seal and Own are hers alone" stands — the star is not among
  them). No line owed.
- **The dated entry + narrative → `notes/AppSpecRecord.md`:** her ruling's words (the ticket), the two wording asks,
  RB-1's trace (why tags first), VX-609's mechanism and its pin, the undo's place-restore.

### THE BUNDLE items born here (fold into §THE BUNDLE)

- **RB-1, as built (PROVISIONAL):** the wire's write new into a gathering plans TAGS FIRST (VX-549's plan, byte-unchanged
  for every rule a tag can satisfy) and stars ONLY where a star is the only way in — there her door's plan, born
  starred, cap-exempt (`newPostInGathering`'s arm); the answer adds `starred: true` (absent otherwise). Consequences
  for her eyes: (i) a client minting many notes into a star-only gathering can push her Starred list past fifteen, as
  her own gathering door can (cap-exempt — "a mint never fails on a star"); (ii) `★ OR #a` takes #a on the wire where
  her door stars. Options: (a) her door's planner outright (the wire stars `★ OR #a` too — one planner, no
  composition; flips `aStarOrATagRuleTakesTheTagOnTheWire`); **(b) as built**; (c) keep refusing, reworded to point at
  `set_starred`; and, independent of the three, (d) the wire's star respects the cap (a full list refuses the mint in
  her cap words).
- **RB-7 (PROVISIONAL):** `set_starred` on a GATHERING's id answers the gathering sentence (P-VX196-2's posture — "read,
  never changed through this door"), which now names "starring" among the author's acts. Alternative (b): R-VX184-1's
  parity — she stars a gathering at the keyboard, so an edit grant reaching the gathering place (its own or its
  wing's, MB-16) could star it.
- **RB-8 (design calls, for the ladder or her):** the entry's halves restore the star AT ITS PLACE in the Starred list
  (an un-star's undo returns the row where it stood, never at the end); they are not applying acts (`apply_tag`'s
  replay doctrine — a re-star replay seats nothing); a half that would pass the cap refuses in her words and keeps
  its entry; a column-only book's star comes back in both stores (the union's normal form).
- **RB-5 (copy, joins her pass):** the tool's description; Activity's "changed the star on “X”" / "was refused changing
  the star on “X”" (one tool both ways — the coarse log keeps no direction); the receipts "starred “X”" / "unstarred
  “X”"; the undo labels "‹client›'s star" / "‹client›'s unstar"; `starHeadsUp`; the gathering write-new rung sentence;
  the guide's two edits; `create_note`'s new sentence; `gatheringWords`' "starring"; `needsStar`'s bare fact.
- **RB-9 — FILED as VX-625 (Bug · Test-only · Tests & tooling · Low, 2026-10-27):**
  `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` timed out once under the full-parallel headless run
  (its one-minute limit; 204.9 s), green isolated ×2 and in a second whole run — a held observation starving under
  load. Until ticketed, a full-parallel failure there is re-run isolated before it counts.
- **For VX-368's parity audit (offer, not built):** `set_starred` retires the star row; a gathering's own star (RB-7)
  is the one star-shaped act the wire still lacks.

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator) — the products are prebuilt at `~/dev/variorum-vx-620/DerivedData/b1`
  (a FRESH dir, never a clone) from the final sources: `cd App/Variorum && xcodebuild -scheme Variorum -destination
  'platform=macOS' -derivedDataPath ~/dev/variorum-vx-620/DerivedData/b1 test-without-building` with
  `-only-testing:VariorumTests/<Suite>` for: **the pins** `MCPStarFacesTests` (NEW, 5) · `MCPGatheringGrantFacesTests`
  (8 — the three flips + VX-609's face pin) · `TutorialMCPChapterTests` (the justified edits); **the neighbours**
  `MCPWireRefusalSweepTests` · `MCPAskAndReceiptTests` · `MCPAsksWaitTests` · `MCPGrantSheetTests` · `MCPGrantRoadsTests`
  · `MCPPaneTests` · `MCPPaneTabsTests` · `MCPSharedRowsTests` · `MCPWingFacesTests` (W-UX-13's every-tool words) ·
  `MCPLibraryParityFacesTests` · `MCPEditParityFacesTests` · `MCPDeliberateFacesTests` · `MCPDoorErgonomicsFacesTests`
  · `MCPGatheringIconTests` · `StarDoorTests` · `BookcaseStarredShelfTests` · `TutorialCurrencyTests` · `TutorialWalkTests`
  · `ChromeLineLimitTests` · `CapabilityRegistryTests`. State the EXECUTED count (VX-604); read the `skipped:` lines.
  If a later batch rebuilds, run from the newest FRESH dir (each batch's dir is built from the tip it saw).
- **The walk (dev store, both voices where a face shows; the shim driven with the pane-copied key; VX-prefixed
  content):** (1) an EDIT wing grant: `set_starred {note_id, starred: true}` → the note in the sidebar's Starred list;
  the receipt "‹client› starred “VX…” · ⌥⌘Z undoes"; Activity "‹client› changed the star on “VX…”"; ⌥⌘Z (named "Undo
  ‹client›'s star") takes it off. (2) Star three notes by hand; `set_starred {…, starred: false}` on the MIDDLE one;
  ⌥⌘Z → it returns to the middle of Starred (the place-restore). (3) `set_starred {book_id}` → the Bookcase floats it
  and the starred shelf shows it. (4) A gathering "VX starred walk" with rule `#vxwalk AND ★`: Settings ▸ MCP ▸ Share
  another place… → A gathering → pick it → HOW MUCH offers all four rungs; at Write new and at Edit the quiet line
  "Its rule needs a star, so a new note a client writes here is starred." shows, at Read/Suggest it does not — capture
  in BOTH voices. (5) VX-609: a READ grant on that gathering; `create_note` into it → refused, the ask waits on the
  gathering's row; open the ask: its lead says "(starred, if it needs a star)"; Allow Once → the retry LANDS: the note
  wears #vxwalk, is starred, the gathering shows it. (6) The cap: with fifteen starred, `set_starred` on a sixteenth →
  her words ("You can star 15 things at a time — …"). **Restore:** un-star every walk star, revoke the walk grants,
  delete the walk gathering/notes/tag, server off; the known dev-store residue untouched.

---

## BATCH 2 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`MCPConnectionNamingDoorTests` 2, `MCPSharingFaceTests` 5, the JUSTIFIED
EDITS in `MCPPaneTabsTests` and `SettingsAccountSurfaceTests`) are written and COMPILED (`build-for-testing` into a
FRESH `DerivedData/b2`), their RUN PENDING the orchestrator's stage window, so VX-590's mount pins and VX-605's door
pin are UNRUN; no canon edit (MCPSpec's lines are DRAFTED below, the two-file rule); no new words (VX-590's hidden state
says nothing new — RB-3); NOT BUILT, bundled for her: hiding the two AI-naming faces outside the pane (the note's
Private row, the ⌘/ helper's MCP group — RB-10) and a signal at VX-258's in-handler flip (an unreachable-in-practice
sub-edge, sweep row 5 — no pin can open its window); `MCPSession.instructions` byte-unchanged (2,988 / 3,000 — batch
3's 12 characters untouched); no ticket filed or moved; nothing in `Sync/`, `Server/`, custody, the schema, the editor
seam or `VariorumMobile/`.

*Implementer: `opus-implementer` №2 (xhigh), fresh session, 2026-10-27. Read in its own context before any code:
CLAUDE.md + its canon, this plan IN FULL (the BATCH 1 RECORD included — the tree this batch stands on),
`notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · Doors to the outside),
`notes/SessionResiliencyProtocol.md`, the VX-548 record's BATCH 1 BRIEF + RECORD (the tabs, VX-512's line,
`MCPPane.saysClientsBelongToTheLibrary`), BATCH 2b BRIEF + RECORD (the connection story, the stop-roads sweep rows
1–12), its LADDER RECORD and its MID WINDOW (finding MID-2 = VX-605's birth), the VX-590 and VX-605 ticket bodies
(read-only), and the code anchors. Lane: no `Sync/`, `Server/`, custody, schema, editor seam or `VariorumMobile/`; no
`xcodebuild test`, no GUI, no walk, no stage claim. No subagent.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.** (Piece 3's revert RAN over `eaf8a3112` — the one line `self.onNamed()`
  removed — and was restored by `git checkout -- Sources/VariorumMCP/MCPSession.swift`; `git diff` clean after.)
- **0 · Preflight + this record:** DONE (`8f103741d`).
- **1 · VX-605 — the headless pin, RED on the pre-fix tree:** DONE (`ebef21198`, the pin committed RED) —
  `Tests/VariorumMCPTests/MCPConnectionNamingSignalServerTests.swift`: a door-shaped recorder on
  `MCPServerHost.onConnectionsChanged` (each signal re-reads `connectedClientNames`, exactly as
  `MCPDoor.refreshConnected`). RED ON THE PRE-FIX TREE (`scratchpad/b2-logs/vx605-red-on-old.log`): 3 tests / 1
  suite, ONE red — `aReconnectUnderItsBoundKeyIsHeardConnectedOnceItNamesItself` at :79, the door's reads after the
  reconnect `[Set([])]` (ONE read — the registration's, nameless — and nothing after), while its non-vacuity checks
  held (the host's `connectedClientNames == ["claude-code"]`; the registration read empty); the two guards green
  (`aConnectionWaitingForHerOKIsNeverHeardAsTheNamesUntilSheAllowsIt`, `aConnectionRefusedAtItsKeyIsNeverHeardAsAnyone`).
- **2 · VX-605 — the fix:** DONE (`eaf8a3112`) — `MCPSession` takes an `onNamed` signal (defaulted `{}` for the two
  tests that build a session by hand) and calls it right after its `initialize` hook sets the name, outside the
  session's lock; `MCPServerHost.serve` hands it `{ [weak self] in self?.onConnectionsChanged?() }` — the SAME road, a
  signal carrying no decision (P-4); the door's hop to the main actor and its re-read of the CURRENT host are
  untouched, so a late signal from a stopped host can never resurrect its names. GREEN
  (`scratchpad/b2-logs/vx605-green.log`): 3 / 1, the red pin passing in 0.43 s.
- **3 · VX-605 — the behavioural revert + the Mac door pin:** the revert DONE — RED under it
  (`scratchpad/b2-logs/vx605-revert-red.log`: 1 of 3, the same :79, the door's reads `[Set([])]`), restored GREEN
  (`vx605-restored.log`, 3/1). The seam's no-regress suites GREEN on the fix (`vx605-seam-suites.log`: **64 tests / 12
  suites**) — VX-394's `MCPConnectionEndServerTests` + `MCPStopRoadsServerTests` (rows 1–4, 9, 10's headless pins),
  VX-180/181's four (`MCPDiscoverProbeServerTests`, `MCPPreInitializeWindowTests`, `MCPShimClosedAppTests`,
  `MCPShimTests`), the setup-key roads (`MCPSetupKeyServerTests`, `MCPSetupKeyTabServerTests`,
  `MCPSetupKeyRebindServerTests`), the two suites that build a session by hand (`MCPServerHostReuseTests`,
  `MCPReaderAfterCloseTests` — VX-607 green this run). The Mac door pin: DONE (`be4a68456`, compile fix `01380bf10`)
  — `App/Variorum/VariorumTests/MCPConnectionNamingDoorTests.swift` (2), COMPILED; its RUN **PENDING** the stage.
- **4 · VX-590 — the sharing face hidden until the library has ever had a client:** DONE (`a4e757d02`; COMPILED —
  piece 5; the Mac pins' RUN **PENDING** the stage) — `MCPPane.showsSharingFace`, `MCPPaneTab.offered(sharing:)` / `.shown(_:sharing:approvedCount:)`,
  the pane's tab row and switch read them at render (her pick kept); `SettingsSearch.settingsEntries/wholeIndex(…,
  mcpSharingFace:)` + the results pane's question; NEW Mac `MCPSharingFaceTests` (5); JUSTIFIED EDITS in
  `MCPPaneTabsTests` (2) and `SettingsAccountSurfaceTests` (1). The settled design:
  the store fact is VX-512's own (client rows — pending + approved + denied — exist; monotone: the pending room's
  prune never empties it), PROVISIONAL RB-3; the Shared with AI tab (and the open-book switch it holds) is not
  offered while it is false; the pane's tab is clamped to the offered set (her pick otherwise remembered as before);
  the Settings search does not name the open-book row while the face hides (the account-row precedent,
  `wholeIndex(accountSection:)`); no new words.
- **5 · Suites + Mac `build-for-testing` (FRESH `DerivedData/b2`):** DONE — Mac `build-for-testing` into the
  FRESH `DerivedData/b2` (absent before, never a clone): **TEST BUILD SUCCEEDED** (`scratchpad/b2-logs/mac-bft2.log`;
  the first attempt, `mac-bft1.log`, failed on ONE line of the new door pin — `MCPShim.writeAll` is package-internal;
  it now writes with the `Darwin.write` loop `MCPConnectionEndDoorTests` uses). No warning on a touched line (the one
  in a touched file, `AppSettingsView.swift:1270`, is 2026-07-18's). The whole headless suite: DONE (this commit) —
  counts under "Suites" below. **PENDING:** the Mac pins' run (the stage) and the walk (the orchestrator's window).

### VX-605 — THE TRACE (inputs → wrong state), verified in this session's own reading

Her client reconnects under the setup key it is already bound to (her `/mcp` after a lock — the mid window walker's
repro, MID-2): the shim connects → `MCPServerHost.acceptLoop` → `serve(_:)` registers the new `MCPSession` and fires
`onConnectionsChanged` (`MCPServerHost.swift`, the line after `sessions[session.id] = session`) — the session's
`run()` has not started, so its `name` is nil → the door's closure hops to the main actor and `refreshConnected()`
reads `host.connectedClientNames` = `[]`. Then `run()` reads the opening, `Operations.admitMCPConnection` decides
`.admit` (a bound key under an approved name) and writes only `recordMCPContact`'s `last_seen_at` — which
`MCPServerHost.grantsFingerprint` does not read (it reads `mcp_client`'s id · state · setup_key_hash for decided
clients, the grants' stamps, the switches), and `AppDatabase.observe` applies `.removeDuplicates()`, so the grants
observation delivers NOTHING. The SDK's `initialize` hook sets `self.name = admitted` (`MCPSession.swift`) and signals
nothing. Wrong state: `door.connected` stays `[]` while the host serves the connection named — `MCPClientRow`'s
detail reads `MCPPaneCopy.lastSeen(…)` ("last seen 11 seconds ago") instead of `connectedNow` — until some later
event (a grant or binding change, another connection opening or closing) happens to re-read. The host's own doc
already promised the signal "when a connection opens, NAMES ITSELF or closes" — the middle clause was never built.
(A FIRST connection usually escaped it: its `.bind`/`.rebind` writes `setup_key_hash`, which the fingerprint reads,
so the observation's later signal re-read — a race the reconnect never gets.)

**The mechanism closed (`eaf8a3112`):** the naming moment signals the SAME road. `MCPSession` holds an
`onNamed: @Sendable () -> Void` (init parameter, default `{}` — `MCPServerHostReuseTests` and
`MCPReaderAfterCloseTests` build sessions by hand) and calls it in the `initialize` hook right after `name` is set,
outside the session's lock; `serve` hands it `{ [weak self] in self?.onConnectionsChanged?() }`. Nothing else changed:
the signal still carries no decision (P-4) and the door still re-reads.

**Threading — who signals, on what, and why a signal can't race a stop.** Callers of `onConnectionsChanged`: the
accept thread (`serve` — registration), the session's own task (`ended` — the end; NOW also `onNamed`, inside the
SDK's `initialize` hook, after the session lock is released), the grants observation's task. The door's closure only
hops to the main actor; `refreshConnected` re-reads `host?.connectedClientNames` — the door's CURRENT host — and every
stop road (`stopServer`: `host?.stop(…)`, `host = nil`, `connected = []`) runs on the main actor too, so a naming signal
that races a stop lands after it and reads no host (`[]`), and one from a host the door has since replaced reads the
new host's set (the stale host's sessions are not in it). Every read is idempotent and order-free. Lock order: the
re-read takes the host lock, then each session's lock (`clientName`) — the order `ended` already uses; `onNamed`
fires with no session lock held, so no inversion. A host the door has let go of signals no one (`[weak self]`).

### VX-605 — THE SWEEP TABLE (every road that changes the connected set × the signal)

| # | Road | Signal | Cell | Pin |
|---|---|---|---|---|
| 1 | A connection REGISTERS (`serve`) | yes (pre-existing), reads it nameless | by design | `…SignalServerTests` pin 1 (`door.all.first == []`) |
| 2 | **It NAMES itself at `initialize`** | **was NONE** | **FIXED** (`onNamed`) — RED ON OLD + under the revert | headless `aReconnectUnderItsBoundKeyIsHeardConnectedOnceItNamesItself`; Mac `aReconnectUnderItsBoundKeyReadsConnectedNowOnceItNamesItself` |
| 3 | A WAITING setup's connection names itself (VX-258 — `clientName` nil while it waits) | now yes; the re-read finds nothing new | PINNED-GREEN (guard, both sides) | `aConnectionWaitingForHerOKIsNeverHeardAsTheNamesUntilSheAllowsIt` |
| 4 | Her Allow of a waiting setup — the binding is in the fingerprint → the observation's `announceToolsChanged` flips `awaitingKey` → then the signal | yes (pre-existing) | PINNED-GREEN | the same guard's second half |
| 5 | The flip inside a HANDLER (`ListTools`/`CallTool` → `awaitsHerOK`) with no observation after it | none | **SAFE IN PRACTICE — traced, NOT fixed:** reachable only if her Allow commits inside the window between the admission's commit (which itself writes the waiting row she would answer) and the SDK's `initialize` hook — then the observation's announce skips the flip (`declaredName` nil) and its signal reads nothing new, the naming's signal reads nothing new (still waiting), and the client's next call flips silently. No pin can open that window without a test seam in the handshake (the hallucination guard: no fix without a red pin); recorded for the ladder (RB-11) | — |
| 6 | A connection ENDS (`ended`) | yes (pre-existing) | PINNED-GREEN | pin 1's two end legs; Mac pin's end leg |
| 7 | A STOP (`halt` → each session's `ended`; the door's own `connected = []`) | yes; the door empties at once | PINNED-GREEN | VX-394's `MCPStopRoadsServerTests` (unchanged, green); Mac guard `aStoppedHostsLateSignalNeverBringsItsNamesBack` |
| 8 | A late signal from a host the door stopped or replaced | — | SAFE BY CONSTRUCTION (the door re-reads its CURRENT host, on the main actor) | Mac guard (above) |
| 9 | Past the session cap (`refuseOverCap` — never a session) | none needed | SAFE — never registered, never named | VX-394's `pastTheSessionCapTheRefusedConnectionSaysNothing` (unchanged) |
| 10 | A connection refused at its key (never named) | registration + end only, each reading nobody | PINNED-GREEN (guard) | `aConnectionRefusedAtItsKeyIsNeverHeardAsAnyone` |
| 11 | The grants observation (approve, deny, grant, revoke, binding) | yes (pre-existing) | unchanged | pin 1's first leg (non-vacuity) |

**VX-394's sweep (the VX-548 BATCH 2b table, rows 1–12) — not regressed:** this batch changed no stop road, no end
line and no lock road; the end lines are written by `writeEndLine`/`recordConnectionEnds`, untouched. Headless rows
1–4, 9, 10 GREEN on the fix (`vx605-seam-suites.log`); the Mac rows (2, 5–8, 11 — `MCPConnectionEndDoorTests`,
`MCPStopRoadsDoorTests`, `MacWillLockTests`, `RoadLockRouteTests`) ride the stage window (listed below). **VX-180/181:**
`MCPDiscoverProbeServerTests`, `MCPPreInitializeWindowTests`, `MCPShimClosedAppTests`, `MCPShimTests` GREEN on the fix
(the pre-initialize window answers before admission — no session is named there, so `onNamed` never fires in it).

**Why the Mac door pin is choreographed (hollowness avoided):** a door-level pin whose raw connect blocks the main
actor through the whole handshake (`MCPConnectionEndDoorTests`' `connect`) lets the registration's ONE main-actor hop
land AFTER the naming — it then reads the name and the pin goes green on the OLD code. The new pin opens its socket
off the main actor with not a word sent, lets the registration's hop land (`door.connected` still empty — asserted),
and only then names itself — the walker's own order.

### VX-590 — THE DESIGN, as built (PROVISIONAL RB-3)

**The store fact:** a client row exists — waiting, approved or denied (`MCPPane.showsSharingFace` =
`!saysClientsBelongToTheLibrary` — VX-512's own gate, read the other way, so the two faces are ONE fact: while the
library says "Clients belong to the library they were set up in…", nothing in the pane says sharing). "EVER" holds:
no road removes a client row but the waiting room's cap (`Operations.recordMCPContact`: past fifty pending requests it
forgets the OLDEST, never the one just inserted), Deny keeps the row (`denied`), an adopted library keeps its rows (it
releases only the bindings) — so once shown, the face stays for that library. Not the activity log (capped at 500,
rows roll out). Not the approved count (VX-272's gate — denying the only client would hide it again, and a pending
request alone would not reveal it; "ever connected" is her ticket's own word).

**What hides:** the Shared with AI tab (`MCPPaneTab.offered(sharing:)` — Connect · Clients · Activity until the fact
holds, her four after), and with it the open-book switch it holds, its "Share another place…" door (already gated on
an approved client) and its "all N ›" road. **What stays:** Connect (the road the first client arrives by), Clients,
Activity, the server switch, VX-512's line (unchanged), the open-on rule (`MCPPaneTab.opening` unchanged: Connect while
no client is approved, else Clients), and her remembered pick (`MCPDoor.paneTab` is never overwritten: the pane renders
`MCPPaneTab.shown(tab, …)` — her pick while offered, else the opening rule — so a Shared with AI pick remembered from
another library this app run opens on Connect and returns with the face). **The Settings search** names no row the
hidden tab holds: `SettingsSearch.settingsEntries/wholeIndex(accountSection:mcpSharingFace:)` leaves out the rows
whose finding lands there (`MCPPaneTab.holding(findingLead:) == .shared` — the open book), the account row's precedent;
the results pane asks `mcp.map { MCPPane.showsSharingFace($0.snapshot) } ?? true`. **Words: none new** — the hidden
state says nothing (naming the hidden tab would show the very word she wants hidden); VX-512's one line is the
zero-state's sentence.

**The open book ON in a clientless library** (reachable only from before this build — the switch was drawn
clientlessly): it hides with the tab. It reaches nobody (only approved clients read through it), the first connection
request reveals the tab with the switch ON, and the approval sheet already says so ("The open book is on, so once
approved it can read everything except what always asks." — `approveAloneDetail(openBook:)`), so nothing reaches
anyone unannounced. Option (b) in RB-3 keeps the face shown while it is ON.

**The probe (the brief's): every app-wide share door is ALREADY hidden clientlessly — VERIFIED, not rebuilt.** VX-272's
`MCPDoor.hasApprovedClient` (an APPROVED client) gates: ⌥⌘A (`EditorCommands` — `if mcp.hasApprovedClient`, the menu
item not drawn at all), the note/book row menus' "Share with AI…" (`BookRowMenu`, `LibraryCatalogView`'s context menu,
`ShelfView` — `road.canShare`), the Library's bulk "Share N notes with AI…" (`LibraryBulkRow.canShare`), Book Settings'
"Shared with" row (`BookSettingsFace.showsGrantRow(canShare:)`), the shared icon and the in-note indicator (VX-272 /
VX-164 — nothing read while no client is approved; `indicatorOn` also needs the server on); "Allow AI here" offers
approved clients only (`NotePrivacyState.allowable` — empty ⇒ no menu). Pinned already:
`MCPShareFacesTests.theGatesFollowAnApprovedClientAndTheServerSwitch` ("no client, no server — no share face at all"),
`theBookRowMenuDrawsShareOnlyOnAShareableBook`, `theBookSettingsGrantRowDrawsOnlyWhereAGrantCanLand`. **Two AI-naming
faces DO show clientlessly outside the pane** — the note's Private row "Private — never shared with AI" (the fence's
own toggle, `.markNotePrivate`) and the ⌘/ helper's (and Settings ▸ Shortcuts') MCP group (⌥⌘A "share the note you're
in…", ⌥⌘O "show the AI's last change") — neither is the "Shared with AI" face her words name; both are her call
(RB-10), not built. **The field guide** names no tab: its "one switch in Settings ▸ MCP" (the open book, lesson 3)
reads true from lesson 2 on — the first connection request reveals it. No guide edit owed.

**Red-on-old BY CONSTRUCTION (the mechanism):** before this batch the pane's tab row was `ForEach(MCPPaneTab.allCases)`
and its body `switch tab` — Shared with AI and the open-book switch rendered whatever the library held; the search's
index took no MCP question. The new pure rules did not exist; the mount pin
`aFirstConnectionRequestBringsTheTabAndThePaneStaysWhereSheIs` cannot find a three-tab row on the old pane (four labels
always).

### PINS

- **Headless (run here), `Tests/VariorumMCPTests/MCPConnectionNamingSignalServerTests.swift` (NEW, 3):**
  `aReconnectUnderItsBoundKeyIsHeardConnectedOnceItNamesItself` — RED ON THE PRE-FIX TREE (`vx605-red-on-old.log`) and
  RED UNDER THE BEHAVIOURAL REVERT of the one line (`vx605-revert-red.log`), both `[Set([])]` at :79; GREEN on the fix
  (`vx605-green.log`, `vx605-restored.log`) · guards, green on both sides:
  `aConnectionWaitingForHerOKIsNeverHeardAsTheNamesUntilSheAllowsIt`, `aConnectionRefusedAtItsKeyIsNeverHeardAsAnyone`.
- **Mac (COMPILED into `DerivedData/b2`, RUN PENDING the stage):** NEW `MCPConnectionNamingDoorTests` (2) —
  `aReconnectUnderItsBoundKeyReadsConnectedNowOnceItNamesItself` (red on old by the headless pin's mechanism; the
  choreography above makes it so) · `aStoppedHostsLateSignalNeverBringsItsNamesBack` (guard, green both sides). NEW
  `MCPSharingFaceTests` (5) — `theFaceShowsOnceTheLibraryHasHadAClientWaitingApprovedOrDenied` (the gate table; VX-512's
  line and the face one fact; the open book alone never brings it, the approval sheet says it) ·
  `theDoorsFactFollowsTheClientRowsAndNeverGoesBack` (a real door: fresh → hidden; a request → shown; Deny → stays) ·
  `theTabsOfferedLeaveOutSharedWithAIUntilTheFaceShows` (offered/shown; a remembered Shared with AI pick opens on
  Connect) · `theSearchNeverNamesTheOpenBookWhileTheFaceHides` (exactly the open-book row leaves; Connect's words still
  land on Connect; the window's wiring by source) · `aFirstConnectionRequestBringsTheTabAndThePaneStaysWhereSheIs`
  (mounted: three tabs on Connect → a request → four, still on Connect, nothing picked for her).
- **JUSTIFIED EDITS (VX-590 cited in each, the ritual):** `MCPPaneTabsTests.aFreshPaneOpensOnConnectWithItsCodeBlockInSight`
  — a fresh library's row is the three it offers (found by `freshTabLabels`; + `labels == ["Connect", "Clients",
  "Activity"]`); every geometry expectation unchanged, both voices · `MCPPaneTabsTests.herPickedTabIsRememberedAcrossTheSettingsWindow`
  — a first connection request arrives before the pane mounts (her four tabs show), the pick-memory subject unchanged
  · `MCPPaneTabsTests.tabRow(in:labels:)` (the helper, defaulted to her four) · `SettingsAccountSurfaceTests.theResultsPaneAsksForTheWindowsSection`
  — the pinned source literal carries the second question (`wholeIndex(accountSection: accountSection, mcpSharingFace:
  mcpSharingFace)`); the account question asked exactly as before. **Re-read and UNCHANGED:** `theTabsAreHerFourInHerOrder`
  (`allCases` still her four) · `thePaneOpensOnConnectUntilAClientIsApprovedAndKeepsHerPick` (`opening` untouched) ·
  `aSearchForTheOpenBookLandsOnItsTab` (the all-rows index, default) · `aRemountedPaneShowsTheClientItsCopyReceiptNames`
  (Connect stays offered) · VX-512's `MCPGrantRoadsTests.aLibraryWithNoClientSaysItsClientsAreItsOwn` (its gate
  untouched) · the gated capture harnesses (`MCPPaneTabsCaptureTests`' fresh frame now shows three tabs — no assertion
  reads the count).

### Files touched

Wire: `Sources/VariorumMCP/MCPSession.swift` (`onNamed` — the property, the init parameter, the call in the
`initialize` hook; `instructions` byte-unchanged) · `Sources/VariorumMCP/MCPServerHost.swift` (`serve` hands `onNamed`).
App: `Features/MCP/MCPPane.swift` (the header's VX-590 paragraph; `MCPPaneTab.offered(sharing:)` /
`shown(_:sharing:approvedCount:)`; `MCPPane.showsSharingFace`; `sharing` / `shownTab`; the tab row and the body's
switch) · `Features/Settings/SettingsShape.swift` (`settingsEntries` / `wholeIndex` — `mcpSharingFace:`) ·
`Features/Settings/AppSettingsView.swift` (the results pane's second question). Tests: NEW
`Tests/VariorumMCPTests/MCPConnectionNamingSignalServerTests.swift`, `App/Variorum/VariorumTests/MCPConnectionNamingDoorTests.swift`,
`App/Variorum/VariorumTests/MCPSharingFaceTests.swift`; JUSTIFIED EDITS `MCPPaneTabsTests`, `SettingsAccountSurfaceTests`.
Untouched, by the lane: `Sources/VariorumCore/` entirely, `Sync/`, `Server/`, custody, every schema, the editor seam,
`VariorumMobile/`, every word in `MCPPaneCopy`, the field guide. Commits: `8f103741d` (record) · `ebef21198` (pin, red)
· `eaf8a3112` (fix) · `58f33aedd` (revert evidence) · `be4a68456` (door pin) · `a4e757d02` (VX-590) · `01380bf10`
(compile fix) · this record's commits.

### Suites (the end, on the final code — `swift build` green; the record's commits change no code)

- **The whole headless run** (`scratchpad/b2-logs/headless-all.log`, `swift build` then `swift test` on `01380bf10`'s
  code): VariorumCoreTests **3477 tests / 464 suites passed** (5 known issues, standing — batch 1's count: no core line
  changed); StringsWorkbook **32 / 4 passed**; VariorumMCPTests **423 / 77 with ONE issue — the standing VX-532 flake**
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 24.0 s against its 15 s
  under the full-parallel run; no harness line changed), re-run ISOLATED green ×2 (`harness-isolated-1/2.log`: 3 / 1,
  2.2 s each) — batch 1's 420 / 76 + this batch's 3 / 1. VX-607 (`MCPReaderAfterCloseTests`) and VX-625
  (`StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar`) green this run; the new suite green under the
  full-parallel load (14.2 s).
- **Targeted, along the way (each green):** `MCPConnectionNamingSignalServerTests` 3 / 1 (×2 + the red legs) · the
  seam's no-regress set 64 / 12 (`vx605-seam-suites.log`).
- **Mac:** `build-for-testing` into the FRESH `DerivedData/b2` — **TEST BUILD SUCCEEDED** (`mac-bft2.log`), built from
  `01380bf10`'s sources (batch 1's code + this batch's). **PENDING:** the Mac pins' run (the stage).

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

- **MCPSpec, THE PANE AND THE SHARED ICON (VX-281's paragraph) — after** "it opens on Connect while no client is
  approved, else on Clients, and remembers her pick for the app run;" **insert:** "its sharing face — the Shared with AI
  tab and the open book inside it — is offered only once the library has had a client (a client row exists, waiting,
  approved or denied: VX-512's fact read the other way — VX-590, PROVISIONAL RB-3; the record
  `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md` BATCH 2): until then the tabs are Connect · Clients ·
  Activity, a remembered Shared with AI pick opens by the rule and returns with the face, and the Settings search names
  no row the hidden tab holds; every share face outside the pane waits for an approved client already (VX-272);"
- **MCPSpec, the same paragraph or VX-394's "A dropped connection says why" — add:** "the Clients row reads "connected
  now" from the moment a connection names itself — the host signals at a connection's naming as well as at its
  registration and its end (VX-605), so a client reconnecting under its bound key never reads "last seen …" while it
  is served".
- **SurfaceContracts / AppSpec:** nothing goes false (neither names the pane's tabs nor the connected marker; AppSpec
  §12's "Settings (nine searchable panes)" stands). No line owed.
- **The dated entry + narrative → `notes/AppSpecRecord.md`:** her VX-590 words (the ticket's: "what's the lift on only
  showing the 'share with AI' in the settings menu if someone has connected an MCP server? ... I don't want someone who
  doesn't use AI to see that & get scared that their work is shared."), the design care (Connect stays), the fact
  chosen and why "ever"; VX-605's MID-2 trace (registration-only signal, `.admit`'s fingerprint-blind write) and the
  choreographed door pin.

### THE BUNDLE items born here (fold into §THE BUNDLE)

- **RB-3, as built (PROVISIONAL):** the sharing face (Shared with AI + the open book) shows once a client row exists —
  waiting, approved or denied, monotone. Options: **(a) as built**; (b) as (a) OR while the open book is ON (a live
  switch never hidden — its corner: turning the open book off in a clientless library hides the tab under her cursor);
  (c) an approved client (VX-272's gate — not "ever": a Deny of the only client hides it again, and a waiting request
  alone does not reveal it). Hidden-state words: **none** — nothing names the hidden tab; VX-512's line is the
  zero-state's one sentence.
- **RB-10 (her call — not built):** two AI-naming faces still show in a library that never had a client, outside the
  pane her words named: (i) the note's Private row "Private — never shared with AI" (the fence's own toggle — hiding it
  would stop her marking a note Private before any client exists); (ii) the ⌘/ helper's and Settings ▸ Shortcuts' MCP
  group (⌥⌘A "share the note you're in with the client you granted last…", ⌥⌘O "show the AI's last change") — the
  helper's list is the registry walk's pinned mirror, so a conditional row is a design event. Options per face: leave
  (as built) · hide while the library has never had a client · reword.
- **RB-11 (for the ladder):** VX-605's sweep row 5 — VX-258's in-handler flip signals nothing; unreachable in practice
  (her Allow would have to commit inside the admission → `initialize` window); traced, not fixed (no red pin without a
  handshake seam). A one-line signal at the flip would close it by construction if the ladder wants it.

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator) — `DerivedData/b2` is FRESH (built from `01380bf10`, batch 1's code
  included — a superset of `b1`; run batch 1's list from `b2` too): `cd App/Variorum && xcodebuild -scheme Variorum
  -destination 'platform=macOS' -derivedDataPath ~/dev/variorum-vx-620/DerivedData/b2 test-without-building` with
  `-only-testing:VariorumTests/<Suite>` for: **the pins** `MCPConnectionNamingDoorTests` (NEW, 2) ·
  `MCPSharingFaceTests` (NEW, 5) · `MCPPaneTabsTests` (the two justified edits; the geometry oracle in BOTH voices) ·
  `SettingsAccountSurfaceTests` (justified edit); **the neighbours** `MCPPaneTests` · `MCPGrantRoadsTests` (VX-512's
  line) · `MCPConnectionEndDoorTests` · `MCPStopRoadsDoorTests` · `MacWillLockTests` · `RoadLockRouteTests` ·
  `SettingsLockCloseTests` · `SettingsShapeTests` · `SettingsAccountSearchTests` · `MCPShareFacesTests` (VX-272's gates)
  · `MCPSetupMenuTests` · `MCPRebindFaceTests` · `MCPAskAndReceiptTests` · `MCPAsksWaitTests` · `CapabilityRegistryTests`
  · `ChromeLineLimitTests` · `TutorialMCPChapterTests`. State the EXECUTED count (VX-604); read the `skipped:` lines.
  **Optional red-on-old leg for the door pin:** revert the one line `self.onNamed()` in `MCPSession.swift`, rebuild
  `b2`, run `MCPConnectionNamingDoorTests` (expect `aReconnect…` red, the guard green), restore by `git checkout --`.
- **The walk legs (dev store, Debug from `b2`; both voices where a face shows; VX-prefixed content; the shim driven
  directly with the pane-copied key — batch 1's road; compose after batch 1's legs, before its restore):**
  (V1 · VX-605) server ON; Settings ▸ MCP ▸ Connect → Claude Code's tab → copy its setup (its key binds or re-binds the
  approved `claude-code` row with zero clicks); start the shim with that key → `initialize` → Clients: "claude-code ·
  connected now · …". Close the shim → "last seen …" and Activity "claude-code disconnected". **Start the same shim
  again with the same key and make one call (`list_my_activity`), touching nothing else** → the row reads "connected
  now" at once (MID-2's exact road — before the fix it read "last seen N seconds ago" until another event). Capture
  the Clients row at that moment in BOTH voices. (V2 · VX-590, shown) the dev store as found holds an approved client,
  so the tab row is Connect · Clients · Shared with AI · Activity — capture in both voices. (V3 · VX-590, hidden) a
  library with NO client row cannot be shown on the dev store as found (e11e5233 holds `claude-code`); the
  non-invasive road is the gated capture harness `MCPPaneTabsCaptureTests` (`TEST_RUNNER_VARIORUM_CAPTURE=vx281-u1`,
  in-memory library — its "u1-fresh-connect" frames, both voices, light and dark, now show the three tabs), else a
  throwaway library is the orchestrator's call. **Restore:** stop the shim, server OFF, nothing else written (no grant,
  no client, no wing — `claude-code` stays the known residue); Debug prefs export/diff per the protocol.

---

## BATCH 3 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** PENDING — written at the batch's close. While in flight: no
`xcodebuild test`, no GUI, no walk, no capture, no stage claim (the orchestrator's); no canon edit (drafted only);
nothing in `Sync/`, `Server/`, custody, the schema, the editor seam or `VariorumMobile/`.

*Implementer: `opus-implementer` №3 (xhigh), fresh session, 2026-10-27. Read in its own context before any code:
CLAUDE.md + its canon, this plan IN FULL (the BATCH 1 and 2 RECORDS — the tree this batch stands on),
`notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · Doors to the outside),
`notes/SessionResiliencyProtocol.md`, the VX-548 record's BATCH 1 RECORD (VX-515 ask 2, VX-516's trace) and BATCH 2b
RECORD's RECONNECT ERGONOMICS (option C — VX-619's birth), the VX-348 record's §U5 + VX-393 section (her original
duplicate-rows report), QUESTIONS #227 (P-VX252-1 / P-VX254-2 — RATIFIED 2026-10-15), the four ticket bodies via
Linear (read-only; no comments on any), and the code anchors. One read-only Sonnet lookup for external facts (the
clients' reconnect roads — VX-619's guide sentence).*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight.**
- **0 · Preflight + this record:** DONE (this commit).
- **1 · VX-565 — the probe (reconstruction tests):** NOT-STARTED — the probe's finding so far (read, not yet pinned):
  her report's shape — PlanetLillian (wing) twice and "o ladrão de raios" (book) twice for one client with different
  rungs — is EXACTLY VX-393's report (the VX-348 record §U5: "PlanetLillian (wing) twice for claude-code — `read ·
  always` AND `read, suggest, write new and edit · always` — and "o ladrão de raios" (book) twice"), fixed at 0.9.8
  (v1_30's merge + `uq_mcp_grant_standing_place` + the one mint's replace). Pins to write: her exact shape on today's
  merged tree through every minting road (one row each); the honest two-row shapes (a once beside a standing; two
  clients; two places sharing a name) each SAID by its row.
- **2 · VX-566 — `import_document` takes `section_id`:** NOT-STARTED — design: the one-document form takes
  `create_note`'s exact shape (parse: without `book_id` → `sectionWithoutBookWords`; the op: `importNote(…, section:)`
  through `mintNoteEntry`'s existing chapter check; the answer echoes `section_id`); the BOOK form REFUSES `section_id`
  at the parse (its chapters come from `book.chapters`; the wire's discipline for a meaningful-elsewhere argument —
  `book_id` with a book refuses in words — never a silent ignore).
- **3 · VX-567 — the book form answers per-note records:** NOT-STARTED — design: `BookImport.notes` (what each seat
  minted, from `mintDocument`'s return — no second read); the wire answers `notes: [{note_id, block_ids, blocks}]` in
  `note_ids`' order beside the three id lists; MCPMintedAnswerServerTests' F-2 guard flips DELIBERATELY (VX-567).
- **4 · VX-619 — the lock/quit docs:** NOT-STARTED — `MCPSession.instructions` at 2,988 / 3,000 (re-measured here);
  O-4 (her 2026-10-11 ruling, `MCPProviderNeutralityTests`) forbids a provider's name in the instructions, so the
  advice says the client's own road neutrally; the guide names Claude Code's road only inside lesson 2's O-4 SETUP
  COPY fence.
- **5 · Suites + Mac `build-for-testing` (FRESH `DerivedData/b3`):** NOT-STARTED.
