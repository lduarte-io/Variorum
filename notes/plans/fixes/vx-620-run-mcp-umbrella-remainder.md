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
| 3 — the wire's imports & docs | VX-565 (probe first) · VX-566 · VX-567 + rider VX-619 | opus-implementer №3 | DONE (Mac run PENDING the window; walk legs optional) |
| 4 — the wing doors from ⌘K | VX-377 | opus-implementer №4 | DONE (Mac run + walk PENDING the window) |
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
- **RB-4 (PROVISIONAL, batch 3 — SUPERSEDES A RATIFIED CALL):** VX-567's book-form answer: `notes` (per note `note_id`, `block_ids`, `blocks` with every take's `sha256`) beside the three id lists. P-VX252-1/P-VX254-2 ("ids only") were RATIFIED 2026-10-15 (#227) — her explicit word asked. Options (a) as built · (b) keep ids only (revert one commit) · (c) as built + per-note `tag_ids`/chapter. The BATCH 3 RECORD's bundle section has the size reasoning.
- **RB-5 (copy, her pass, batch 3):** VX-619's two docs sentences + the instructions trade; batch 1's reworded star strings join the same list (batch 1's list: the BATCH 1 RECORD's bundle section — the tool description, Activity's "changed the star on", the receipts, the undo labels, `starHeadsUp`, the gathering write-new sentence, the guide's two edits, `create_note`'s sentence, `gatheringWords`' "starring", `needsStar`'s bare fact). **Batch 1 left `MCPSession.instructions` untouched: 2,988 / 3,000 — 12 characters for VX-619.** **Batch 3 (VX-619): 2,988 → 2,994 — the trade (move_note_to_wing's sentence out; show_in_app's tail) and the lock/quit clause, plus the guide's sentence and VX-566's book-form refusal; the list in the BATCH 3 RECORD's bundle section.**
- **RB-6 (her call, batch 4):** a chord for Move to Wing — the collision-sweep facts recorded; the ⌘K door ships either way.
  **The sweep (batch 4, at its tip — the BATCH 4 RECORD's RB-6 section):** free — **⌥⌘L "Move to Wing…"** (the ⌥
  "deliberate variant" of ⌘L, her ⌥⌘Z / ⌥⌘N / ⌥⌘S grammar) and **⇧⌥⌘L "Copy to Wing…"**; not free — ⌥⌘W, ⌥⌘M (the
  system's), ⇧⌘M (Merge). A chord would be a menu item reading the availability batch 4 made honest.
- **RB-7 (PROVISIONAL, batch 1):** `set_starred` on a gathering's id answers the gathering sentence (P-VX196-2's posture), now naming "starring" among the author's acts; alternative: R-VX184-1 parity — an edit grant reaching the gathering place stars it.
- **RB-8 (design calls, batch 1 — for the ladder or her):** `set_starred`'s undo halves restore the star AT ITS PLACE in the Starred list, are not applying acts (a re-star replay seats nothing), refuse past the cap keeping the entry, and bring a column-only book's star back in both stores.
- **RB-9 (ticket to file, batch 1):** a third load-sensitive pin — `StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar` timed out once under the full-parallel headless run, green isolated and in a second whole run (Tests & tooling, the VX-532 class).
- **RB-10 (her call, batch 2 — not built):** two AI-naming faces still show in a library that never had a client,
  outside the pane her VX-590 words named: the note's Private row "Private — never shared with AI", and the ⌘/
  helper's / Settings ▸ Shortcuts' MCP group (⌥⌘A, ⌥⌘O). Leave · hide clientlessly · reword, per face.
- **RB-11 (for the ladder, batch 2):** VX-605's sweep row 5 — VX-258's in-handler flip signals nothing; unreachable in
  practice, traced, not fixed (no red pin without a handshake seam).
- **RB-12 (batch 3 — the ticket's close):** VX-565 RESOLVED, no code — her report's exact shape is VX-393's (fixed 0.9.8); the honest two-row shapes each say what differs (probe pins). Closes on the BATCH 3 RECORD.
- **RB-14 (her call, batch 2's fix leg 2-F1 — not built):** the Settings search's WAITING row (`mcpWaiting`, "A client's
  ask past what you shared waits here…") is listed whatever the library holds (13n-c U4's standing — Waiting renders
  only while something waits), so a library that never had a client still finds it (e.g. "open book" matches its
  detail; "ai", "ask", "mcp" its keywords). Options: (a) as built — listed always; (b) leave it out while the library
  has never had a client, with the open book (VX-590's spirit carried into the search's vocabulary); (c) leave out
  every MCP row but the server switch and Connect while clientless.
- **RB-13 (her call, batch 3 — O-4 vs VX-619's letter):** the advice says the reconnect road provider-neutrally (O-4, her 2026-10-11 ruling, pinned); the guide names Claude Code's /mcp inside lesson 2's setup fence. Options (a) as built · (b) "/mcp" in the advice without a provider · (c) an O-4 carve-out for the advice.
- **RB-15 (copy, her pass, batch 4):** the wing selector's words — the field "Move to a wing" / "Copy to a wing", the
  foot "“X” is in Home · ⏎ chooses · esc closes", no-match "No wing has that name." (the switcher's); the palette rows
  wear the registry's verbs "Move to Wing" / "Copy to Wing" (no ellipsis — the submenus' titles). Options for the rows:
  (a) as built · (b) "…" on the verb (the submenus then carry it too) · (c) a palette-only title (a second spelling).
- **RB-16 (PROVISIONAL, batch 4 — the palette's second grammar):** ⌘K lists Move/Copy to Wing ONLY where they act (a
  note pane: the note's two; a book or gathering pane: the book's one; never with one wing, never on the daily
  Journal); every other palette row stays listed always, speaking its note. Options (a) as built · (b) always listed,
  speaking (two identical "Move to Wing" rows on every pane, one refusing) · (c) extend (a) to every context-gated
  palette row (its own ticket).
- **RB-17 (for the ladder, batch 4):** the wing-act re-ask signal is per window (a second window's sidebar/bars
  unchanged, as before); it also closes the pre-existing cross-door half of VX-425 (a Library/Pool row's or note ▾
  menu's move left the sidebar's Open indicator and row doors stale — one pin covers both roads); the selector consumes
  ⌘L as a step and commits on no release; the palette → selector sheet hand-off is walk-verified only.
- (Batch records append more.)

## LEDGER

| # | Item | Owner | Status |
|---|---|---|---|
| 1 | Worktree + branch + in-flight row + Linear In Progress + riders seated | orchestrator | DONE (in-flight on main; branch pushed; VX-609/VX-619 sub-issues) |
| 2 | This plan file | orchestrator | DONE |
| 3 | Batch 1 (VX-596 + VX-609) | opus-implementer №1 | DONE 2026-10-27 — headless green (core 3477/464 · MCP 420/76 bar VX-532, isolated green · Strings 32/4); Mac pins COMPILED into fresh `DerivedData/b1`, RUN + walk PENDING the window; record: BATCH 1 RECORD |
| 4 | Batch 2 (VX-590 · VX-605) | opus-implementer №2 | DONE 2026-10-27 — headless green (core 3477/464 · MCP 423/77 bar VX-532, isolated green · Strings 32/4); VX-605 red-on-old on the pre-fix tree AND under the behavioural revert; VX-590 red by construction; Mac pins COMPILED into fresh `DerivedData/b2`, RUN + walk PENDING the window; record: BATCH 2 RECORD |
| 5 | Batch 3 (VX-565 · VX-566 · VX-567 + VX-619) | opus-implementer №3 | DONE 2026-10-27 — headless green (core 3484/465 · MCP 431/79 bar VX-532, isolated green ×2 · Strings 32/4); VX-565 RESOLVED by VX-393 (probe pins, no fix); VX-566/567 red-on-old on the pre-fix tree; VX-619 2,994/3,000; Mac pins COMPILED into fresh `DerivedData/b3`, RUN PENDING the window; record: BATCH 3 RECORD |
| 6 | Batch 4 (VX-377) | opus-implementer №4 | DONE 2026-10-27 — headless green (core 3484/465 bar VX-625 · MCP 431/79 bar VX-532, each isolated green ×2 · Strings 32/4 — no core line changed); the existing selector was a SUBMENU, so the face fix is a keyboard wing selector on ⌘L's brain; ⌘K lists the three rows only where they act (RB-16); the re-ask made cross-door (it did NOT hold by construction — THE TRACE); RB-6's chord sweep recorded, no chord; Mac pins (`WingPaletteDoorsTests` 10) COMPILED into fresh `DerivedData/b4` — the final window's one product — RUN + walk PENDING; record: BATCH 4 RECORD |
| 7 | Orchestrator acceptance windows (stage via oct27coordinator) | orchestrator | MID WINDOW DONE 2026-10-27 (vx620-mid: 366 executed / 50 suites / 1 red = MID620-1 fixed as 2-F1; the walk ALL GREEN; released clean). FINAL WINDOW PENDING (from `DerivedData/b4`; the Mac pins of all four batches + the 2-F1 re-run + batch 4's ⌘K walk leg) |
| 8 | The ladder (whole-run diff, fable-reviewer; roster re-listed first) | orchestrator | ROUND 1 DONE 2026-10-27 — **0 BLOCKER · 0 MAJOR · 0 MINOR · 4 NIT (all record-only)**; no fixes owed, so THE LADDER CLOSES IN ONE ROUND, CONTINGENT on the final window's Mac run + walk going green (any red returns as new material). The record: `notes/plans/fixes/vx-620-ladder-round1.md` (the roster was re-listed before the round: nine sub-issues, unchanged) |
| 9 | Closeout + handoff + QUESTIONS bundle | orchestrator | NOT STARTED |

## THE MID WINDOW — PLAN (claim `vx620-mid`, accepted by oct27coordinator with three conditions; READY sent after batch 2)

**Shape:** tests FIRST (one `test-without-building` invocation from the FRESH `DerivedData/b2`, which holds batches 1+2 — the union of both batches' "For the orchestrator" suite lists; executed counts per VX-604) → **SEAM ping** to the coordinator (a merge-gating run may slot in; yield if vx-601/vx-562 is READY) → the WALK (an Opus walker under the claim; batch 1's six legs + batch 2's V1/V2; both voices where a face shows; restore steps per the batch records).

**The coordinator's three conditions (2026-10-27, folded verbatim-faithfully):**
1. The walk's leg 0 records the dev store's as-found Enable-the-MCP-server state; the restore returns to THAT state, not blanket OFF; the RELEASE line carries both values (found, returned).
2. The fresh setup key under claude-code's bound name is the standing VX-258 road (a pane-tab copy carries the name, re-binds with zero clicks, no `mcp_rebind_request`); the changed key hash on the dev row is expected residue, NAMED at release. The key value lives only in the walk's gitignored scratch; the clipboard is cleared at restore.
3. The RELEASE line names the residue that can't be undone: the walk's Activity rows (the 500-act window), revoked/spent grant tombstones, the superseded setup-key row and the re-bound hash.

**VX-590's hidden-state leg (V3): NOT walked** — the dev store as found holds the claude-code row, and a throwaway-library reset buys nothing the Mac pin (`MCPSharingFaceTests`, a real door) hasn't proven. The shown-state leg (V2) walks; recorded here so the window's evidence story is honest.

### THE MID WINDOW — PART 1 RUN (claim `vx620-mid`, GO 14:42 MDT 2026-10-27; coordinator pre-checks: ambient off, zero instances strict forms, no booted sims; vx-562's return verified by its own release — dev store at no books / 1 note / Walk Wing empty / Trash 30 rows / banner standing)

- **Suites, two invocations from the FROZEN `DerivedData/b2`:** (1) the 37-name list → **267 tests EXECUTED in 34 suites, 0 skipped, ONE failure** (`vx620-mid-suites.log`); (2) a correction run — **three of the 37 names were FILE names, not suite TYPE names** (`StarDoorTests`, `BookcaseStarredShelfTests`, `TutorialWalkTests`), and an unmatched `-only-testing` DROPS SILENTLY — the 16 real types inside those files (StarTargeting · StarDeclaration · StarActing · the two BookcaseStarredShelf suites · the eleven TutorialWalk suites, the acceptance spine among them) ran as the second invocation: **99 tests EXECUTED in 16 suites, ALL GREEN** (`vx620-mid-suites2.log`). **Window total: 366 executed / 50 suites / 0 skipped / 1 failure.** TRAP RECORDED for every later list: `-only-testing` takes the suite TYPE name; a file name silently matches nothing — verify the started-suite names against the request (the VX-604 family).
- **THE ONE RED — FINDING MID620-1 (routed to batch 2's implementer as a fix leg; the re-run rides the final window):** `MCPSharingFaceTests.theSearchNeverNamesTheOpenBookWhileTheFaceHides` on its FIRST run (it only ever compiled in batch 2). The caught finding is NOT the open-book row (correctly filtered) — it is the pane's WAITING explainer row (`lead: "Waiting"`, detail "A client's ask past what you shared waits here…"), which matches the query "open book" incidentally ("…the note, book or wing it names…", "⌥⌘, opens it"). Orchestrator's orientation (the implementer traces and decides): the pin's query is over-broad for its name, AND there is a product-flavored question underneath — should the Waiting search row hide clientlessly too (VX-590's spirit: no AI-scary rows for someone who never connected a client)? If that half is genuinely open it is a PROVISIONAL + bundle item, not an invention.
- Part 2 (the walk) proceeded on the coordinator's word at the SEAM (nobody READY).

### THE MID WINDOW — PART 2, THE WALK (an Opus walker under the claim, 14:51–15:17 MDT; released clean 15:2x, no renew; the full report is quoted in the orchestrator's transcript — this is the record of substance)

- **Leg 0 as-found (independently confirmed):** server switch OFF (returned OFF); claude-code "last seen 8 hours ago · approved · nothing shared"; no books; one note (Oct 19); Archived empty; the hold banner standing, Resume never pressed; unlocked; Study/dark/default palette/quiet receipts. The shim was verified against the DEBUG app by `lsof` (socket peer = `io.lduarte.Variorum.debug`'s container `mcp.sock`); the pane-copied key re-bound the approved name with ZERO clicks (the VX-258 road, as predicted); no `claude mcp add`, no config written outside the dev store.
- **ALL WALKED LEGS PASS, both voices where asked:** A1 `set_starred` on a note — Starred list, the receipt "claude-code starred … · ⌥⌘Z undoes · Open ›", Activity "changed the star on", ⌥⌘Z "Undid: claude-code's star" (VX-596 live in use); A2 the PLACE-RESTORE — a wire un-star of the middle of three undone by ⌥⌘Z returns it to the MIDDLE, never the end (RB-8's design live); A3 a book's union star by wire (Bookcase float + starred shelf + sidebar, both stores; the coalesced receipt); A4 the star-rule gathering offers ALL FOUR rungs with the heads-up ("Its rule needs a star, so a new note a client writes here is starred.") at Write new and Edit ONLY, captured Study + Terminal (the seven-points build live); A5 VX-609's dead door CLOSED in use — a READ grant's `create_note` refused with the ask raised, the ask's lead carrying "(starred, if it needs a star)", her Once answered, and the retry LANDS the note born starred (`starred: true`, `tags: ["vxwalk"]`), assembled in, the spent Once leaving no row; B1 VX-605 live — "connected now" AT ONCE on a one-call reconnect of the same shim+key, in BOTH voices; B2 the four tabs as found. **A6 (the cap) CUT for time — pin-covered** (`theCapRefusesTheActAndWritesNothing` + `MCPStarFacesTests`' cap words), recorded.
- **Restore complete, verified:** every walk star off, grants revoked, the gathering/book/notes to the Trash (6 rows, ≈36 total), #vxwalk tombstoned, server OFF as found, shim stopped, clipboard cleared, voice Study, zero instances (strict forms), no booted sims; the four walk notes' per-note caret pref keys deleted by the orchestrator post-quit at zero instances (the VX-548 precedent); prefs diff then launch churn only. Expected residue named at RELEASE: the re-bound key hash + superseded setup-key row, ~15 Activity rows, three grant tombstones.
- **Walker findings → dispositions:** (W-1) the Clients row's "last seen" shows the session's START time, not its close — a fresh ticket (filed below, the VX-605/VX-394 honest-pane family; NOT this run's mechanism: `last_seen_at` is written at admission and never on close). (W-2) receipts name a quick-entry note by its date ("2026-10-27") — the standing title derivation, wording-consistent with the data; record-only. (W-3) `list_my_activity` says `target_kind: "book"` on the REFUSED gathering mint and `"gathering"` on the allowed one, same id — consistent with P-VX261-5/6's no-oracle posture (the refused row speaks the argument as sent, `book_id`), recorded FOR THE LADDER's eyes as a possible NIT, not changed. (W-4) the gathering context menu reads "Delete Book…" while its confirm says Gathering — ADDED to VX-611 (a comment on the ticket; same wording family as its Trash row). (W-5) walker machinery: WalkKit's ≥2 s idle guard eats a keystroke sent within 2 s of a synthetic click — pauses fixed it; one early keystroke landed in the Settings window with NO stored effect (prefs diff clean, all settings re-verified as found) — the gitignored `Tools/WalkKit/wl2` helper dies with the worktree.

### THE FINAL WINDOW (claim `vx620-final`, GO 16:20 MDT 2026-10-27, merge-gating priority; coordinator pre-checks clean)

- **Part 1, suites:** ONE invocation from `DerivedData/b4` over 67 verified suite TYPES (the mid window's list corrected + batches 3/4's pins and neighbours + `CommandRoutingTests`/`BrowserNavKeysTests` for the ShellRouter/ShellActions edits — the changed-sources rule): **470 tests EXECUTED in 66 suites, 0 skipped, ONE failure** (`vx620-final-suites.log`; the 67→66 is the nested-suite counting artifact; every requested name accounted for). **FINDING MID620-F1:** `WingPaletteDoorsTests.theSelectorArrivesFocusedAndAnswersTypingReturnAndEsc` red on its first run — the rig reads `input.currentEditor()` nil on arrival. Routed to batch 4's implementer as a fix leg.
- **Part 2, the walk (an Opus walker under the claim; the stage log's authoritative window 16:20:00–16:35:12 — the walker's self-reported 16:24–16:41 ran fast of the clock):** VX-377's ⌘K leg **ALL SIX STEPS PASS**, and **the FOCUS VERDICT ADJUDICATES MID620-F1: the selector arrives KEYBOARD-FOCUSED WITHOUT A CLICK in BOTH voices** (typing landed in the field straight after ⏎ on the palette row, three times) — the product is right; the red is the RIG's. Also verified live: the move's receipt, the Open row's wing indicator, the note ▾ menu re-ask after a ⌘K move (the cross-door re-ask live), Esc's no-op on Copy, the Bookcase listing no Move row with nothing focused, and the coordinator's untagged condition — NO tag appeared in the Walk Wing at any point. Restore complete and verified (the walk note to the Trash, the Walk Wing empty, voice Study, zero instances, no booted sims; the walk note's caret pref key deleted by the orchestrator post-quit; prefs diff launch churn only).
- **Walk observations → dispositions:** (F-W1) Terminal's bottom-bar receipt TRUNCATES on the move's sentence ("Moved “VX377 walk note” to “…") while Study's fits — a face ticket (filed below, the P-8 width family). (F-W2) after a ⌘K move of the FOCUSED note to another wing, the app's wing does not follow (title bar and quick entry still "in Home") — consistent with SurfaceContracts' letter (the follow is "on open and on focus"; a move is neither); bundled as **RB-18** for her: should the wing follow a move of the focused note? (F-W3) walker machinery: the ≥2 s idle guard also refuses a keystroke within 2 s of a prior synthetic KEY — 2.6 s gaps; quits by bundle id, never a blind ⌘Q.

### THE RERUN WINDOW (claim `vx620-rerun`, the stage log's 17:00:04–17:02:36; released promptly — vx-562's walk waited behind)

- **WingPaletteDoorsTests from the rebuilt b4: 10 EXECUTED / 1 red, TWICE** (the repeat a diagnostic) — `theSelectorArrivesFocusedAndAnswersTypingReturnAndEsc` STILL red on 4-F1's fixed rig: `currentEditor()` nil through the 80-turn wait in a settled, shown window (the edited :518, ~9.3 s). 4-F1's settled-window theory was INSUFFICIENT; the prime suspect is the host fact 4-F1 itself cited — test-host windows never become KEY, so field EDITING may be unreachable at this seam. The control stayed unfocused; the other nine green. The red teeth-proof leg was MOOT (the pin red without it) and was not run; no product line was touched (tree clean, coordinator-verified).
- **The product stands proven by the walk** (the final window: focused without a click, both voices, three times, captured). Routed to batch 4's implementer as **FIX LEG 4-F2** with a decisive brief: trace the two green precedents' exact focus mechanics; make the rig genuinely focus-capable OR re-seat the mounted assertion at the honest pinnable seam (the focus REQUEST + what AppKit reachably shows), the live arrival staying walk-verified evidence (the MB-15 evidence-shape precedent) — one more cycle only. The merge waits on its re-run window.

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

### FIX LEG 2-F1 (the mid window's FINDING MID620-1; implementer №2 resumed, 2026-10-27)

**LIVE STATUS (per piece, flipped in the same commit as each piece):**
- **No behavioural revert is in flight** (none is planned — the leg edits a pin, no product line).
- **F1-0 · The trace + the disposition:** DONE (`68e119590`) — below.
- **F1-1 · The pin's JUSTIFIED EDIT + RB-14:** DONE (this commit) — `MCPSharingFaceTests.theSearchNeverNamesTheOpenBookWhileTheFaceHides`
  (MID620-1 cited in its comment): the query asks for the open book's OWN row by its lead (absent while the face hides,
  present once it shows), and a query-independent invariant joins it — for each of the open-book row's words ("open
  book", "read everything", "share all", "always", "mcp", "ai", "everything is readable"), no finding lands on the
  hidden tab (`MCPPaneTab.holding(findingLead:) != .shared`). Its teeth, by construction: with the leave-out removed,
  "open book" finds the open-book row, whose finding lands on `.shared` — both expectations go red (the same mechanism
  the sibling expectation `all.subtracting(hidden) == [the open book's lead]` already proved GREEN in the window). No
  product line changed, so no product red-on-old is owed (the hallucination guard: the product was right). RB-14 folded
  into §THE BUNDLE. **The re-run rides the final window** (no `xcodebuild test` here).
- **F1-2 · Recompile into the EXISTING `DerivedData/b2`:** DONE (this commit) — `swift build` green
  (`scratchpad/b2-logs/f1-swift-build.log`); `build-for-testing` into `DerivedData/b2` (NOT a clone — the same dir,
  rebuilt in place): **TEST BUILD SUCCEEDED** (`f1-mac-bft.log`), no warning in the edited pin. **`b2` is NO LONGER the
  frozen batches-1+2 evidence the mid window ran:** it is now built from `68e119590`'s tree + this pin edit — batches
  1, 2 AND 3 (pulled before this leg) — so the final window runs from the newest FRESH dir, as planned.

**The trace (inputs → wrong output), from the window's log** (`scratchpad/vx620-mid-suites.log` :2338–2344): the red is
`MCPSharingFaceTests.swift:133`, `mcpFindings("open book", sharing: false).isEmpty` → false; the one finding it returned
is `SettingsFinding(kind: .setting, pane: .mcp, lead: "Waiting", detail: "A client's ask past what you shared waits
here, newest first, and at its icon on the note, book or wing it names — nothing pops up by itself. ⌥⌘, opens it.")`.
`SettingsSearch.findings` ANDs the query's terms across a row's lead, keywords and DETAIL (rank 4): "open" is in the
detail's "opens it", "book" in "the note, book or wing" — so the Waiting row (`mcpWaiting`, `SettingsShape.swift:392`)
matches "open book" by its detail, sharing face or not. The open-book row itself WAS left out (the same test's
`all.subtracting(hidden) == [the open book's lead]` held in the window, and only :133 recorded an issue).

**The disposition: a PIN BUG — the product is right as built.** The pin's name is "the search never names the open
book while the face hides", but its query asserted "no MCP setting row at all" — over-broad for its subject, and it
was never run before the window (batch 2 compiled it only). VX-590's leave-out did exactly what was designed: the rows
the hidden tab holds (the open book) are out; the Waiting row was never one of them (it sits ABOVE the tabs — its finding
lands on no tab, `MCPPaneTab.holding` → nil). **The product question underneath is genuinely open — RB-14, her call, not
built:** the Waiting row is the 13n-c U4 standing (`AppSettingsView.paneRowIDs` comment: "Waiting renders while an
ask waits (the catalog row says so)") — the search lists it whether or not anything waits, and a library that never
had a client can have nothing waiting; its blurb says "past what you shared". Leaving it out clientlessly would extend
VX-590 past the face her words named ("the 'share with AI' in the settings menu") into the search's vocabulary — a
product call, so the most spec-defensible narrow thing is the pin fixed to its subject and the question bundled.

## BATCH 3 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`MCPPlaceTwiceFacesTests` 3 NEW, `TutorialMCPChapterTests`' justified
edit) are written and COMPILED (`build-for-testing` into a FRESH `DerivedData/b3`), their RUN PENDING the
orchestrator's stage window; no canon edit (MCPSpec's lines DRAFTED below, the two-file rule); no fix for VX-565 (the
probe found no mechanism — RESOLVED by VX-393, re-proven here); no ticket filed, moved or commented (VX-565's close on
this record is the orchestrator's at the merge); the real store's field-guide re-seed (VX-619's lesson-2 sentence
reaches an existing library only through Help ▸ Restore Field Guide…) is HER window's; the instructions do NOT carry
the ticket's literal "(Claude Code: /mcp)" (O-4 — RB-13); the book import's per-note record carries no `tag_ids` /
`section_id` (the brief's list — RB-4 option); nothing in `Sync/`, `Server/`, custody, the schema, the editor seam or
`VariorumMobile/`.

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
- **1 · VX-565 — the probe (reconstruction tests):** DONE (this commit) — disposition RESOLVED, no fix (no mechanism
  on today's tree): her report's shape is VX-393's report word for word, fixed at 0.9.8; every other way one place
  lists twice is an honest second row that says what differs. Headless NEW
  `Tests/VariorumCoreTests/MCPPlaceTwiceProbeTests.swift` — **5 / 1 GREEN** (`scratchpad/b3-logs/vx565-probe.log`);
  Mac NEW `App/Variorum/VariorumTests/MCPPlaceTwiceFacesTests.swift` (3 — the rows' drawn words) — compile PENDING
  (piece 5), RUN PENDING the stage. The record: "VX-565 — THE PROBE" below.
- **2 · VX-566 — `import_document` takes `section_id`:** DONE (pins red `6721d651c`; the fix this commit) — core
  `Operations.importNote(_:in:section:undoLabel:)` (threads `createNote`'s `section` into `mintNoteEntry`'s existing
  chapter check — no new op); wire `Job.importNote(…, sectionID:)`, the parse (one document: without `book_id` →
  `sectionWithoutBookWords`; the BOOK form: `section_id` → `bookFormSectionWords`, after the `book_id` refusal), the
  perform (`into` decides the book first; `noteAnswer(…, sectionID:)` echoes it), `MCPNullCharacters`' pattern;
  `MCPToolCatalog.importDocument` declares `section_id` and its description says both forms. GREEN
  (`scratchpad/b3-logs/vx566-green.log`): `MCPImportSectionServerTests` 5/5 + `MCPMintedAnswerServerTests` 5 +
  the two neutrality nets + core `MCPMintedBlocksActsTests` 3 (16 / 4 + 3 / 1). The record: "VX-566" below.
- **3 · VX-567 — the book form answers per-note records:** DONE (pins red `8d34b3f34`; the fix this commit) — core
  `BookImport.notes: [MintedNote]` (NEW public `MintedNote {postID, blockIDs, blocks}`, appended at each seat from
  `mintDocument`'s own return — no read); wire: the `.importBook` arm answers `notes` (VX-252's record per note, through
  `MCPMintedBlocks.records` — the one encoder, no text) beside `book_id` / `note_ids` / `chapter_ids`;
  `MCPToolCatalog.importDocument`'s description says it (the "no sha256" clause retired). THE DELIBERATE FLIP:
  `MCPMintedAnswerServerTests`' F-2 guard (renamed `…AndABookAnswersItsNotesToo`; header + the digest suite's header
  re-said). NEW core state-transition pins in `MCPMintedBlocksActsTests` (+2: VX-566's op half, VX-567's notes).
  GREEN (`scratchpad/b3-logs/vx567-green.log`): MCP 23 / 4 (the VX-567 2, VX-566 5, VX-252 5 with the flip, VX-254 11)
  + core 34 / 3 (`MCPMintedBlocksActsTests` 5, `DocumentImportOperationTests`, `ImportOperationTests`). The record:
  "VX-567" below.
- **4 · VX-619 — the lock/quit docs:** DONE (this commit) — `MCPSession.instructions`: the opening says it,
  provider-neutral (O-4), with THE TRADE (the move_note_to_wing sentence out — the tool's own description says it word
  for word; show_in_app's tail shortened, its pinned clause kept): **2,988 → 2,994 / 3,000**. The guide: lesson 2's
  setup card, INSIDE its O-4 SETUP COPY fence, names Claude Code's road (/mcp ▸ Reconnect — the Sonnet lookup's cited
  docs) and the any-client road (restart it). Pins: NEW `MCPAdviceServerTests.theAdviceSaysALockOrQuitEndsEveryConnectionAndReconnectingWorks`
  (the sentence + the mechanics executed: stop → every connection gone → start → a reconnect served); JUSTIFIED EDITS
  in `MCPAdviceServerTests` (the names set; the move sentence's two lines → the trade's premise pinned on the tool's
  description) and Mac `TutorialMCPChapterTests.lessonTwoConnectingAClient` (the new sentence, its client by its
  label, the advice's parity line). GREEN headless (`scratchpad/b3-logs/vx619-advice.log`: 26 / 4 — the advice suite,
  both neutrality nets — the provider net proves the fence holds the new literal — and the VX-180 probe suite);
  the Mac edits compile PENDING (piece 5), RUN PENDING the stage.
- **5 · Suites + Mac `build-for-testing` (FRESH `DerivedData/b3`):** DONE — Mac `build-for-testing` into the FRESH
  `DerivedData/b3` (absent before, never a clone; built from `bab5c38b3`'s sources — every later commit is
  record-only): **TEST BUILD SUCCEEDED** (`scratchpad/b3-logs/mac-bft3.log`; no warning in a touched file). The whole
  headless suite on the final code: GREEN bar the standing VX-532 flake, isolated green ×2 — counts under "Suites"
  below. **PENDING:** the Mac pins' RUN (the stage) and any walk leg (the orchestrator's window).
- **Machinery honesty:** `bab5c38b3`'s LIVE STATUS flip (a scripted replace whose end anchor "- **5 · Suites" first
  matched BATCH 2's piece-5 line) duplicated 298 lines into this file — batch 2's record tail and a stale copy of this
  record's head; found while closing, removed by `37704ae76` (0 added / 298 deleted; batch 1 and 2's records verified
  byte-identical to their pre-batch text). Every later flip anchored on a string asserted unique.

### VX-565 — THE PROBE (her kickoff: "VX-548 rebuilt that listing, re-probe on main")

**Her report** (an agent's feedback, relayed 2026-10-26, filed 2026-10-27 01:01 UTC — before VX-548 merged):
"PlanetLillian (and "o ladrão de raios") show twice in the pane with different rungs. Either the rows are honest
(different places or durations) and the face doesn't say why, or they really are duplicates — probe first, then merge
per client+target into the strongest rung or label the difference."

**The finding — the shape is VX-393's own report, word for word.** The VX-348 record §U5 (2026-10-18): "Her
screenshot (Settings ▸ MCP ▸ Shared with AI) shows the duplicate rows VX-393 names: PlanetLillian (wing) twice for
claude-code — `read · always` AND `read, suggest, write new and edit · always` — and "o ladrão de raios" (book)
twice." The mechanism (VX-393's trace): the grants store's one mint never read what the client already held on the
place, so a second grant from any fresh sheet ADDED a row. VX-393 fixed it at 0.9.8 (2026-10-18; `98c88a686` the
one-row rule, `00c754151` the local-only `v1_30` — the merge of every store's existing duplicates to the strongest,
and `uq_mcp_grant_standing_place`, which refuses a second live standing row per client × place by construction), and
its walk saw it live ("granting the SAME wing × client a second time from a fresh sheet left ONE row"). Her real store
crossed 0.9.8 before the report was relayed (0.10.x since 2026-10-23), so the agent's feedback file — not in the repo,
not found on disk — most plausibly carried a sighting from before 0.9.8. VX-548 did not change this: VX-516 changed
which grant Change… revokes (never adds a row), VX-515 added the "Share a place…" / "Share another place…" doors (both
mint through the same one-row rule) and VERIFIED the listing honest. **Disposition: RESOLVED — duplicate shape gone
since VX-393 (0.9.8), re-proven on today's merged tree; no fix (the hallucination guard: no mechanism found).** The
ticket closes on this record.

**What each honest second row already says** (the brief: "check what each row already shows … and whether her
confusion survives it"). `MCPSharedRowView` draws the place's title, its kind chip (note · book · wing · gathering),
its DISTINGUISHER when the name collides (the door's `PlaceLabels` ladder — shelf, count, made-when, down to the
second), and the detail line `client · rung · duration` (`MCPPaneCopy.sharedDetail`); an inert grant adds its why.
The three ways one place lists twice on today's tree, each pinned:

| Shape | Honest? | What the row says | Headless pin (`MCPPlaceTwiceProbeTests`) | Face pin (`MCPPlaceTwiceFacesTests`, Mac) |
|---|---|---|---|---|
| Her shape — one client, one place, two standing grants | IMPOSSIBLE since VX-393 (one row, the newer) | — | `herShapeListsEachPlaceOnceOnEveryRoad` (the sheet's new grant — Share a place… / Share another place… / a place door / ⌘L; ⌥⌘A and an ask's answer; Approve… with a grant; Change… kept on its place under VX-516's rule) · `theStoreRefusesASecondStandingRowOnHerPlace` (the index) | — |
| Two CLIENTS on one place | yes | the detail line leads with each row's client | `twoClientsOnOnePlaceAreTwoRowsEachNamingItsClient` | `twoClientsOnOnePlaceReadAsTheirOwnClients` |
| A ONCE grant beside a standing one (P-VX393-3 — an ask answered Once) | yes, until its one act spends it | the detail line ends "once" vs "always" / "until it disconnects" | `aOnceGrantBesideAStandingOneIsTwoRowsUntilItsActSpendsIt` | `aOnceBesideAStandingGrantReadsItsDuration` |
| Two PLACES wearing one name (two wings named PlanetLillian; two books named "o ladrão de raios" — legal for both) | yes | each twin's head wears its distinguisher | `twoPlacesSharingANameAreTwoRowsEachWithItsDistinguisher` | `twoPlacesSharingANameReadWithTheirDistinguishers` |

A fourth place a place name can appear twice in the pane — a waiting ask on PlanetLillian above the tabs ("‹client›
asks to write new in “PlanetLillian”") beside its grant row below — is an ask, said as one by its own title
(`MCPAskCopy.title`, pinned in `MCPAskAndReceiptTests`); not a grant row. **Nothing is unsaid** — no face fix.

**Red-on-old:** the duplicate shape's red-on-old is VX-393's own (`MCPOneGrantPerPlaceTests` — red before
`98c88a686`); these probe pins are green on this tree by design (the probe found no mechanism to pin red). Not
re-run on a pre-VX-393 tree (the record cites VX-393's).

### VX-566 — `import_document` takes `section_id` (the build)

**The trace (inputs → wrong output), red on the pre-fix tree:** `import_document {document, book_id, section_id}` →
`parseImport` never read `section_id` (the schema didn't declare it either) → `.importNote(named, place:)` →
`ops.importNote` → `mintNoteEntry(section: nil)` → the note joined the book at its end UNSECTIONED and the call answered
success with no echo — the client's chapter silently dropped (her agent's 49 follow-up `file_note_in_chapter` calls).
A bad chapter could not refuse (it was never read); `section_id` without `book_id` landed bookless in the wing; the
book form imported past it.

**The build — `create_note`'s exact shape (VX-252), no new road:** the parse refuses `section_id` without `book_id` in
`create_note`'s own sentence (`sectionWithoutBookWords`, before any decision); the job carries it; `into` decides the
BOOK first (an unreachable book answers the one not-shared shape whatever `section_id` names — the guard pinned);
inside, `Operations.importNote(_:in:section:undoLabel:)` hands it to `mintNoteEntry`, whose chapter check
(`liveSection` + `readingId == book`, BEFORE the mint; a wing or a gathering holds no chapter — `sectionNotFound`) and
whose filing (the pointer set on the membership the hand-add wrote, same transaction, the one
`registerMintedContainerEntry` entry) are `create_note`'s byte for byte; the answer echoes `section_id`
(`noteAnswer(…, sectionID:)` — absent when not given, so every other answer is byte-unchanged; batch 1's `starred` key
untouched). Every id that isn't a live chapter of that book — nothing, a deleted chapter, a readable book's, a hidden
book's, any chapter under a gathering's id — answers "section_id isn't a chapter of this book (list_notes or
create_section gives chapter ids)." byte-identical across `import_document`, `create_note` and `add_note_to_book`
(pinned all three, each id).

**The BOOK form — REFUSES `section_id` (the brief's probe: expected no honest meaning; confirmed).** A whole book's
chapters are `book.chapters` (each a new `reading_section` the act mints), and the book is new, so no existing chapter
of it can be named; filing the whole book's notes under one chapter of ANOTHER book is not an import of a book. The
wire's argument discipline for an argument meaningful in one form only is to REFUSE in words: `book_id` with a book
already refuses ("A book imports into a wing: pass wing_id, not book_id."), `create_note`'s `section_id` without
`book_id` refuses, `text` with `blocks` refuses. Ignoring would answer success with nothing filed where the client asked
— VX-566's own failure. The refusal is at the parse, after the `book_id` check: "section_id goes with document and
book_id: a book brings its own chapters in book.chapters." (PROVISIONAL words, RB-5). (Undeclared arguments in general
are VX-606's question — `section_id` is declared on this tool, so its meaning per form is this tool's to say.)

### VX-567 — the whole-book import answers per-take sha256s (the build; PROVISIONAL RB-4)

**FOR HER EYE FIRST — this flips a RATIFIED call.** P-VX252-1 ("a whole book imported at once answers only its book,
note and chapter ids") and P-VX254-2 ("… importing a whole book answer[s] no fingerprints") were RATIFIED as built at
her 2026-10-15 sitting (QUESTIONS #227, batches 2 and 5 — VX-366 closed as decided). VX-567 (Confirmed Improvement,
filed from her agent's report: "verifying a batch means reading every note back — the agent fell back to importing one
note at a time") asks the opposite; she seated it in VX-548 and then in this run ("VX-566 + VX-567 (the import_document
pair). My rulings are on the tickets."), and the brief flips the call DELIBERATELY. Built, and flagged as a superseded
ratification — RB-4 asks her to confirm the flip in words, or to keep "ids only" (then the flip reverts: one commit).

**The trace (inputs → wrong output), red on the pre-fix tree:** `import_document {book, wing_id}` →
`ops.importBook` minted every note (`mintDocument` returns each note's blocks with every take's stored text —
VX-252's core half) and returned only `BookImport {reading, sectionIDs, postIDs}` → the wire answered `book_id`,
`note_ids`, `chapter_ids`; the minted takes' ids and texts were dropped at the op's return, so a client could prove its
words only by reading every note back.

**The build:** `BookImport.notes: [MintedNote]` — NEW public `MintedNote {postID, blockIDs, blocks:
[MintedBlockTakes]}`, appended at each seat from `mintDocument`'s own return (never a second read), parallel to
`postIDs`; her File ▸ Import… and the Bookcase drop read none of it (no face changed). The wire answers `notes` — per
note, in `note_ids`' order, VX-252's record exactly: `note_id`, `block_ids`, `blocks` (per block `block_id`,
`shown_take_id`, every take in fan order as `{take_id, label?, sha256}`) through `MCPMintedBlocks.records`, the one
encoder — no text. `book_id`, `note_ids`, `chapter_ids` stay. No per-note `tag_ids`/`section_id` (the brief's list —
an option in RB-4). The description's "(no sha256 — check a book's notes with read_note)" is retired for the record's
sentence.

**The answer's size, honestly (why no paging is owed):** the answer is ∝ the write itself — one fixed-size record per
take the act minted (~150 characters with its digest and ids; ~430 per two-take block with its `block_ids` entry) —
so it is never larger in order than the rows the act wrote, and it is linear in the request the client sent (every
take whose digest it reads back is text the client itself sent; the inbound cap, 16 MiB after admission, bounds the
request). For prose the answer is SMALLER than the request; for a degenerate book of one-word paragraphs it can be
tens of times larger, as the one-document form's and `create_note`'s answers already can (VX-252 answered them whole,
unpaged). Paging would need a finished act's records kept server-side for later cursor reads — no write on the door
keeps such state (every write answers once, whole). Her bilingual book (3,843 blocks × two takes) would answer ≈1.7M
characters — the order of the text it sent; a client host that spills a large result (Claude Code past ~43–51k
characters, measured at VX-336 U7) still receives it whole, and a client that wants inline answers imports in smaller
books or one document at a time (VX-370 is the open ticket on other clients' output caps).

### VX-619 — the lock/quit docs (her C pick; docs only)

**The facts the sentences state:** a lock ends every connection by design — A-8 (the lock road stops the server: the
door's `macLockTeardown` → `stopServer`; each connection's end line "‹client› was disconnected when the library locked
or closed", VX-394), and the server starts again at the next unlock while the client stays disconnected
(`MCPConnectionEnd.libraryClosed`'s doc); a quit ends the process and with it every socket. The clients' roads back
(the read-only Sonnet lookup, 2026-10-27, cited): Claude Code interactive marks an exited stdio server failed and does
NOT reconnect it — "select **Reconnect** from the server's menu in `/mcp`" (code.claude.com/docs/en/mcp, "Stdio
servers that exit or fail to start"); `claude -p` and the Agent SDK restart it on the next tool call; Codex CLI's
`/mcp` only lists (quit and relaunch it); Claude Desktop and Cursor restart with the app. So "any client reconnects
when you restart it" holds for every client named, and Claude Code's in-session road is /mcp ▸ Reconnect.

**The instructions — provider-neutral, and THE TRADE.** The ticket's "(Claude Code: /mcp)" cannot go into
`MCPSession.instructions`: O-4 (her 2026-10-11 ruling — "outside of the provider setup, claude / claude code isn't
hardwired anywhere since people may use different providers") and its source net `MCPProviderNeutralityTests` forbid a
provider's name outside the setup's fence; a model inside Claude Code knows its own /mcp. So the advice's OPENING says
it: "…on the author's Mac, open only while Variorum runs unlocked: locking or quitting it ends every connection, by
design, so reconnect once it's back." (+98 characters). The trade, chosen as the least load-bearing words whose loss
makes no claim false: (1) the sentence "move_note_to_wing needs edit on the note and write new on the wing it goes to."
(−80) — the ONE sentence in the advice that is a tool description's copy (the tool's own description says "Needs edit
on the note and write new on the wing it goes to." word for word, and the tool is listed only to a client holding
edit, so any client that can call it reads it); (2) show_in_app's sentence ends "asks to see something" for "asks you
to show them something" (−10; its pinned clause "Never call show_in_app unless the author asks" unchanged, R-13nb-23's
meaning intact). **Count: 2,988 → 2,994 / 3,000** (measured over the literal's decoded text, the method re-checked
against the record's 2,988 baseline; `theAdviceIsBoundedAsStated` green). Six characters of headroom remain.

**The guide — where, and why there.** One addition (two short sentences) at the end of lesson 2's setup card
("connecting a client"), INSIDE its `O-4 SETUP COPY` fence: "Locking Variorum or quitting it ends every client's
connection, by design. Once it's open again, reconnect the client: in Claude Code, choose Reconnect for it in /mcp; any
client reconnects when you restart it." Why lesson 2, not lesson 1 (where the brief guessed "the door's conduct is
taught"): it names Claude Code's road, which O-4 allows only inside the provider setup's fence (lesson 2's setup card
holds the guide's one fence; lesson 1's pin forbids "claude" outright); and reconnecting is connecting — the lesson
that teaches the setup command teaches how to bring the client back. Lesson 1 still says "It works only while Variorum
is open" (true; unchanged). The chapter stays seven lessons. **Existing libraries hear it only through Help ▸ Restore
Field Guide… (standing) — the real store's re-seed rides her window (closeout note).**

### PINS (red-on-old evidence)

- **VX-565 (probe — green by design; no mechanism to pin red):** headless `MCPPlaceTwiceProbeTests` (5) · Mac
  `MCPPlaceTwiceFacesTests` (3, RUN PENDING). The duplicate shape's red-on-old is VX-393's (`MCPOneGrantPerPlaceTests`).
- **VX-566:** `MCPImportSectionServerTests` (5, wire) — RED ON THE PRE-FIX TREE, committed red at `6721d651c`
  (`vx566-red-on-old.log`: 5/5 failed, 27 issues), GREEN after (`vx566-green.log`):
  `oneDocumentFilesUnderItsChapterInTheSameCallAndTheSameUndo` ·
  `everySectionIDThatIsntALiveChapterOfTheBookAnswersTheOneSentenceAndMintsNothing` (with the unreachable-book guard) ·
  `sectionIDWithoutABookIsRefusedAtTheParseInCreateNotesWords` · `aWholeBookRefusesASectionIDItsChaptersComeFromTheBook`
  · `theCatalogDeclaresSectionIDAndSaysBothForms`. Core `MCPMintedBlocksActsTests.anImportedDocumentFilesUnderItsChapterAsCreateNoteDoes`
  (new API's state transitions; green by construction).
- **VX-567:** `MCPBookImportRecordsServerTests` (2, wire) — RED ON THE PRE-FIX TREE, committed red at `8d34b3f34`
  (`vx567-red-on-old.log`: 2/2 failed, 4 issues — no `notes`, "no sha256" in the description), GREEN after
  (`vx567-green.log`): `aWholeBookAnswersEveryNotesRecordsWithEachTakesDigest` (three notes across a chapter and the
  unfiled list, labelled and unlabelled alternates; every record == `read_note with_ids`, every digest the test's own
  CryptoKit SHA-256 of the sent words, no text key) · `theDescriptionSaysTheBookFormsRecords`. Core
  `MCPMintedBlocksActsTests.aBookImportsNotesAreWhatEachSeatMinted` (each record the fan rows and stored texts).
- **VX-619:** headless `MCPAdviceServerTests.theAdviceSaysALockOrQuitEndsEveryConnectionAndReconnectingWorks` (the
  sentence, then stop → every connection gone → start → a reconnect served under its always grant) — red on old by
  construction (the sentence absent); Mac `TutorialMCPChapterTests.lessonTwoConnectingAClient` (the guide's sentence,
  its client by label, the advice's parity line, a lock's end a named Activity end) — RUN PENDING.

### THE DELIBERATE FLIP (VX-567 — superseding P-VX252-1 / P-VX254-2's RATIFIED "ids only", PROVISIONAL RB-4)

| Pin | Was | Now |
|---|---|---|
| `MCPMintedAnswerServerTests.importDocumentAnswersTheSameRecordsForOneDocumentAndABookKeepsItsAnswer` → renamed `…AndABookAnswersItsNotesToo` (F-2's guard) | `Set(json(whole).keys) == ["book_id", "note_ids", "chapter_ids"]` | `== ["book_id", "note_ids", "chapter_ids", "notes"]` (the records' truth in `MCPBookImportRecordsServerTests`) |

**Justified edits (each cites its ticket):** `MCPAdviceServerTests.everyToolTheAdviceNamesIsDeclared` (the names set
drops move_note_to_wing — VX-619's trade) and `theAdviceSaysTheSameFactsTheGuideTeaches` (the move sentence's two lines
→ the trade's premise: absent from the advice, present in the tool's description); `TutorialMCPChapterTests.lessonTwoConnectingAClient`
(+ VX-619's sentence); header comments re-said in `MCPMintedAnswerServerTests` and `MCPWriteDigestServerTests` (the
F-254-4 exception retired).

### Files touched

Core: `Operations/Operations+MCPWrites.swift` (`importNote(_:in:section:undoLabel:)` — `section` threaded into
`mintNoteEntry`) · `Operations/Operations+DocumentImport.swift` (`BookImport.notes`; NEW public `MintedNote`; the seat
appends what it minted). Wire: `MCPWriteTools.swift` (`Job.importNote` carries `sectionID`; `parseImport` — the parse
sentence and the book form's refusal; the `.importNote` arm passes the section and echoes it; the `.importBook` arm
answers `notes`; NEW `bookFormSectionWords`) · `MCPNullCharacters.swift` (the job's pattern) · `MCPToolCatalog.swift`
(`import_document` declares `section_id`; its description says both forms and the book form's records) ·
`MCPSession.swift` (the instructions — the lock/quit clause, the trade; its doc). App: `Features/Tutorial/TutorialSeeder.swift`
(lesson 2's setup card, inside the O-4 fence). Tests: NEW `Tests/VariorumCoreTests/MCPPlaceTwiceProbeTests.swift`,
`Tests/VariorumMCPTests/MCPImportSectionServerTests.swift`, `Tests/VariorumMCPTests/MCPBookImportRecordsServerTests.swift`,
`App/Variorum/VariorumTests/MCPPlaceTwiceFacesTests.swift`; edits to `MCPMintedBlocksActsTests` (+2),
`MCPMintedAnswerServerTests` (the flip), `MCPWriteDigestServerTests` (header), `MCPAdviceServerTests` (+1, two justified
edits), Mac `TutorialMCPChapterTests` (justified edit). Untouched, by the lane: `Sources/VariorumCore/Sync/`, `Server/`,
custody, every schema, the editor seam, `VariorumMobile/`, batch 1's `set_starred` and `starred` key (the one-document
answer's `starred` rides `noteAnswer` exactly as before; the gathering mint's shape is byte-unchanged), batch 2's pane.
Commits: `1033b29da` (record) · `c5d8d3c50` (VX-565) · `6721d651c` (VX-566 red) · `37ffefefb` (VX-566 fix) ·
`8d34b3f34` (VX-567 red) · `313cb5e6c` (VX-567 fix) · `bab5c38b3` (VX-619) · `2be48176d` (record) · `683dc757f` (Mac
compile) · `37704ae76` (record repair) · this record's commits.

### Suites (the end, on the final code — `swift build` green; the record's commits change no code)

- **The whole headless run** (`scratchpad/b3-logs/headless-all.log`, `swift test` on `bab5c38b3`'s code):
  VariorumCoreTests **3484 tests / 465 suites passed** (5 known issues, standing — batch 2's 3477 / 464 + this batch's
  7 / 1: `MCPPlaceTwiceProbeTests` 5, `MCPMintedBlocksActsTests` +2); StringsWorkbook **32 / 4 passed**;
  VariorumMCPTests **431 / 79 with ONE issue — the standing VX-532 flake**
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 25.0 s against its 15 s
  under the full-parallel run; no harness line changed), re-run ISOLATED green ×2 (`harness-isolated-1/2.log`: 3 / 1,
  2.2 s each) — batch 2's 423 / 77 + this batch's 8 / 2 (`MCPImportSectionServerTests` 5, `MCPBookImportRecordsServerTests`
  2, the advice suite +1). VX-607 (`MCPReaderAfterCloseTests.aReusedNumberKeepsItsBytesAfterTheSessionEnds`) and VX-625
  (`StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar`) green this run.
- **Targeted, along the way (each green):** `MCPPlaceTwiceProbeTests` 5/1 · VX-566's set 16/4 + 3/1 · VX-567's set
  23/4 + 34/3 · VX-619's set 26/4 (logs named in LIVE STATUS).
- **Mac:** `build-for-testing` into the FRESH `DerivedData/b3` — **TEST BUILD SUCCEEDED** (`mac-bft3.log`).
  **PENDING:** the Mac pins' run (the stage).

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

- **MCPSpec, VX-252's clause ("What a minted note answers") — replacing** "the BOOK form keeps `book_id`, `note_ids`,
  `chapter_ids` (P-VX252-1)." **with:** "the BOOK form keeps `book_id`, `note_ids`, `chapter_ids` and answers `notes` —
  per minted note, in `note_ids`' order, its `note_id`, `block_ids` and `blocks` in that same record, built from what
  the act minted (VX-567, PROVISIONAL RB-4 — superseding P-VX252-1's ratified ids-only answer; the record
  `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md` BATCH 3)."
- **MCPSpec, the same clause — replacing** "`create_note`'s optional `section_id` (with `book_id` only) files the note
  under that chapter …" **with:** "`create_note`'s and a one-document `import_document`'s optional `section_id` (with
  `book_id` only — VX-566 for the import) files the note under that chapter in the same call and the same undo; after
  the book's own decision, any `section_id` that is not a live chapter of that book answers the ONE chapter sentence
  `add_note_to_book` speaks; the whole-book form refuses a `section_id` in words (its chapters are `book.chapters`)."
- **MCPSpec, VX-254's clause — replacing** "`create_note`, a one-document `import_document`, `insert_blocks`,
  `duplicate_note`, `edit_take` and `restore_commit` answer it per take; `divide_block`, `merge_blocks`, `save_version`
  and the book import answer none (P-VX254-1/2)" **with:** "`create_note`, `import_document` (one document, and a whole
  book per note — VX-567), `insert_blocks`, `duplicate_note`, `edit_take` and `restore_commit` answer it per take;
  `divide_block`, `merge_blocks` and `save_version` answer none (P-VX254-1/2 — the book import's exception retired by
  VX-567, PROVISIONAL RB-4)".
- **MCPSpec, VX-197's docs clause — after** "and the three acts that are hers alone, so an AI may suggest one
  (R-VX184-2);" **insert:** "that a lock or a quit ends every connection by design and the client reconnects once
  Variorum is back — provider-neutral, O-4 (VX-619, her C pick; the move_note_to_wing sentence traded out, its rule
  kept in the tool's description; 2,994 of 3,000);" **and after** "The field guide's chapter "AI & the MCP door" stays
  seven lessons —" **insert in the list:** "lesson 2's setup card saying a lock or a quit ends every connection and each
  client's road back (Claude Code's /mcp ▸ Reconnect, inside its O-4 fence — VX-619),".
- **MCPSpec, VX-394's last clause** ("a locked library still serves no one (A-8 — …)") — **append:** "; the AI's
  docs and the guide say so (VX-619)". (Optional — the VX-197 insert already carries it.)
- **VX-565:** no canon line (RESOLVED by VX-393's shipped rule, which MCPSpec already states: "One grant row per
  client × place (VX-393 …)").
- **AppSpec / SurfaceContracts:** nothing goes false (AppSpec §12's MCP summary and SurfaceContracts' MCP bullet name
  neither `section_id`, the import answers nor the reconnect road; "Every connection's end says why in Activity"
  stands). No line owed.
- **The dated entry + narrative → `notes/AppSpecRecord.md`:** VX-565's finding (her VX-393 report resurfacing via the
  agent's file; RESOLVED, no fix); VX-566's agent report ("49 extra file_note_in_chapter calls") and the book form's
  refusal; VX-567's agent report and the supersession of P-VX252-1/P-VX254-2's 2026-10-15 ratification (RB-4); VX-619's
  ruling (MB-7 → C, 2026-10-27), O-4's shaping of the two sentences, the trade and the count.

### THE BUNDLE items born here (fold into §THE BUNDLE)

- **RB-4, as built (PROVISIONAL — and it SUPERSEDES A RATIFIED CALL):** the whole-book `import_document` answers
  `notes` (per note: `note_id`, `block_ids`, `blocks` with every take's `sha256`) beside its three id lists. P-VX252-1
  and P-VX254-2 ("ids only", "no fingerprints from … the book import") were RATIFIED 2026-10-15 (#227); VX-567 asks the
  opposite and she seated it in this run — her explicit word is asked. Options: **(a) as built**; (b) keep ids only
  (revert `313cb5e6c` + the flip — one commit); (c) as built plus each note's `tag_ids`/`tags` and chapter (the full
  one-document answer per note). Size: linear in the request (prose answers smaller than it sent; her bilingual book
  ≈1.7M characters), no paging (no write keeps a finished act's state).
- **RB-5 (copy, joins her pass):** the advice's new clause "open only while Variorum runs unlocked: locking or quitting
  it ends every connection, by design, so reconnect once it's back." and the trade (move_note_to_wing's sentence out;
  show_in_app's "asks to see something"); the guide's "Locking Variorum or quitting it ends every client's connection,
  by design. Once it's open again, reconnect the client: in Claude Code, choose Reconnect for it in /mcp; any client
  reconnects when you restart it."; VX-566's "section_id goes with document and book_id: a book brings its own chapters
  in book.chapters."; `import_document`'s two new description sentences and its `section_id` input description.
- **RB-12 (for the closeout — the ticket's close):** VX-565 RESOLVED — her report's exact shape is VX-393's (fixed
  0.9.8, 2026-10-18; v1_30 merged any store's duplicates); the agent's feedback file evidently carried a pre-0.9.8
  sighting. Closes on this record (Done, with the reason), no code. If her real store's pane still shows one place
  twice for one client, it is one of the three honest shapes (another client · a once beside a standing grant · two
  places sharing a name), each said by its row — a screenshot would tell which.
- **RB-13 (her call — O-4 vs the ticket's letter):** the ticket says "the client reconnects with its own road (Claude
  Code: /mcp)"; her O-4 ruling (2026-10-11) keeps every provider's name out of everything but the provider setup, and
  `MCPProviderNeutralityTests` sweeps `MCPSession.swift`. As built: the ADVICE is provider-neutral ("so reconnect once
  it's back" — a model in Claude Code knows /mcp); the GUIDE names Claude Code's road inside lesson 2's setup fence.
  Options: **(a) as built**; (b) the advice names "/mcp" without a provider (O-4's net would pass, but Codex's /mcp only
  lists — misleading there); (c) her explicit carve-out of O-4 for the advice (one fenced line in `MCPSession.swift`;
  the fence table's file list grows).
- **For the ladder:** the book form refuses `section_id` rather than ignoring it — a declared argument meaningless in
  one form; VX-606 (undeclared arguments accepted silently) is the wider question and untouched.

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator) — the products are prebuilt at `~/dev/variorum-vx-620/DerivedData/b3`
  (a FRESH dir, never a clone; built from `bab5c38b3` — batches 1, 2 and 3's code, so a superset of `b1`/`b2`: batch 1's
  and 2's lists can run from it too): `cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS'
  -derivedDataPath ~/dev/variorum-vx-620/DerivedData/b3 test-without-building` with `-only-testing:VariorumTests/<Suite>`
  for: **the pins** `MCPPlaceTwiceFacesTests` (NEW, 3) · `TutorialMCPChapterTests` (the justified edit — lesson 2);
  **the neighbours** `TutorialCurrencyTests` · `TutorialWalkTests` · `MCPShareFacesTests` · `MCPGrantRoadsTests` ·
  `MCPSharedRowsTests` · `MCPPaneTests` · `MCPPaneTabsTests` · `MCPSharingFaceTests` · `MCPAskAndReceiptTests` ·
  `CapabilityRegistryTests` · `ChromeLineLimitTests`. State the EXECUTED count (VX-604); read the `skipped:` lines.
- **Walk legs (optional — every answer change is wire-proven headless; dev store, the shim driven directly, VX-prefixed
  content):** (W1 · VX-566) a book "VX import" with a chapter "um"; `import_document {document, book_id, section_id}` →
  the note sits under "um" in the book's Outline; ⌥⌘Z (named "Undo ‹client›'s import") takes it away. (W2 · VX-567) a
  whole-book `import_document` → the answer's `notes` (one per note, the digests). (W3 · VX-619) Help ▸ Restore Field
  Guide… on the DEV store → "AI & the MCP door" ▸ "connecting a client" shows the new sentence (both voices if captured);
  and the lock leg already walked at the mid window (MID-2's road) is the mechanism. **Restore:** delete the walk's
  book/notes; the restored guide is dev-store content (replaceable). **The real store's re-seed is HER window's** (the
  closeout note).

---

## BATCH 4 RECORD

**NOT DONE BY THIS BATCH (first line, by the rule):** no `xcodebuild test` run, no GUI, no walk, no capture, no stage
claim (the orchestrator's) — the Mac pins (`WingPaletteDoorsTests` 10 NEW, the justified edits in
`CapabilityRegistryTests`, `WingSwitcherTests`, `WingBookMoveDoorTests`) are written and COMPILED (`build-for-testing`
into a FRESH `DerivedData/b4`), their RUN PENDING the final window, so the selector's mounted keyboard pin and the
sidebar re-ask pin are UNRUN; the palette → selector sheet hand-off (the palette sheet dismissing as the selector's
request lands) is walk-verified only — no harness mounts the shell's two sheets; NO CHORD (RB-6 — her call; the sweep
is recorded); no canon edit (the SurfaceContracts lines are DRAFTED below, the two-file rule); no guide lesson text
(lesson 11's "a note's right-click carries Move to Wing…" stays true — a ⌘K mention is her copy call); a second
window's sidebar and bars do not hear a wing act from this one (the re-ask signal is per window, as the per-door
re-ask was — RB-17, for the ladder); no ticket filed or moved; nothing in `Sync/`, `Server/`, custody, the schema, the
editor seam, `VariorumMobile/`, `App/Variorum/Shared/` or any MCP file.

*Implementer: `opus-implementer` №4 (xhigh), fresh session, 2026-10-27. Read in its own context before any code:
CLAUDE.md + its canon, this plan IN FULL (BATCH 1–3 RECORDS and the mid window's two parts — the tree this batch
stands on), `notes/SurfaceContracts.md` (The app — the keyboard family, the palette; The Bookcase and books — the wing
switcher), `notes/SessionResiliencyProtocol.md`, the VX-377 ticket body (read-only), the VX-439 ladder round 1's m-3
(the re-ask finding) and the code anchors. MCPSpec not required (no MCP surface). Lane: no `Sync/`, `Server/`,
custody, schema, editor seam, `VariorumMobile/` or MCP wire/door file; no `xcodebuild test`, no GUI, no walk, no
stage claim. No subagent.*

### LIVE STATUS (per piece — flipped in the same commit as each piece)

- **No behavioural revert is in flight** (none is planned: the doors are new, so their red-on-old is by construction).
- **0 · Preflight + this record:** DONE (`8b10ece08`).
- **1 · The registry: `.palette` on the three wing acts, their routed availability, the walk's justified edits:**
  DONE (`fc25c3092`) — `CapabilityRegistry.swift`: `.palette` on `.moveNoteToWing` / `.copyNoteToWing` (availability
  `noteWingDoor`: `focusedPaneShowsNote && wingCount > 1`) and `.moveBookToWing` (`focusedPaneShowsBook && wingCount >
  1`). JUSTIFIED EDITS (VX-377 cited in each): `CapabilityRegistryTests` — the walk's sampled contexts gain (note +
  two wings) and (book + two wings), and `takesIsNeverBehindWrite`'s two contexts satisfy the pane facts and the wing
  count (non-mode gates, as undo's); `WingSwitcherTests.theWingActsAreDeclaredAndRendered` and
  `WingBookMoveDoorTests.theBookMoveActsAreDeclaredAndRendered` — the door sets gain `.palette` (+ `paletteActs`
  carries each). Compiled with pieces 2–4 (`b4`, TEST BUILD SUCCEEDED — `scratchpad/b4-logs/mac-bft1.log`); RUN
  PENDING the final window.
- **2 · The palette's context-listed rows + the acts' request:** DONE (`b9d26b816`) — `ShellActions`: the three join
  `paletteActs`; `paletteEntries()` stays EVERY row (the harnesses' list), `paletteEntries(listing:)` /
  `listedPaletteEntries()` filter by `WingPaletteDoors.lists` over `paletteListingFacts()` (the focused selection —
  `.post` a note, `.reading` a book read whole for its marker — and `session.wing.wingCount`);
  `openWingDestination(_:)` names `ShellRouter.wingDestinationRequest` (NEW, `bookMintRequest`'s shape) under the
  registry's gate, else speaks the act's note. `PaletteModel`: `commandSource` + `prepare()` (once per open, before the
  first refresh) and `listedCommands` (the list the rows were built from — `execute` reads it). `RootView`:
  `wirePaletteCommands` sets the source (navigation rows + `listedPaletteEntries()`). Compiled (`b4`); RUN PENDING.
- **3 · The keyboard wing selector (the probe's face fix) + its confirms:** DONE (`b9d26b816`) — NEW
  `Core/Views/WingDestinationSheet.swift`: `WingPaletteDoors` (pure listing + `context(showing:wingCount:)`),
  `WingDestinationModel` (`open(_:wings:session:)` resolves + re-checks; `choose(_:)` runs `moveAsk` / `copy` /
  `bookMoveAsk`, one choice in flight) and `WingDestinationSheet` (the switcher's brain + `WingSwitcherKeyCatcher`; the
  two confirms hosted over it); `WingCopy` +3 words (RB-15). `RootView` presents it from the request. Compiled (`b4`);
  RUN + the walk leg PENDING.
- **4 · The re-ask after any wing act, by construction (VX-425's rule on the new road):** DONE (`403c6e843`) —
  `WingsModel.actGeneration` + `wingActLanded()`, called after each landed `move` / `copy` (`WingsModel.swift`) and
  `moveBook` / `moveContents` (`WingBookMoves.swift`); `SidebarView`'s `noteRowsWingKey` + `openWingsKey` and
  `noteMenuWingDoors`' task (`NoteMenuWingContext.loadKey` — the note + the signal; both bars) key on it. Compiled
  (`b4`); RUN PENDING.
- **5 · Pins + Mac `build-for-testing` (FRESH `DerivedData/b4`) + the whole headless suite:** DONE (`1e9a8f1f7` + the
  suites below) — NEW `App/Variorum/VariorumTests/WingPaletteDoorsTests.swift` (10 tests — PINS below);
  `build-for-testing` into the FRESH `DerivedData/b4` (absent before this batch, never a clone; built from
  `1e9a8f1f7`'s sources — every later commit is record-only, `git diff 1e9a8f1f7..HEAD -- App` empty): **TEST BUILD
  SUCCEEDED** (`scratchpad/b4-logs/mac-bft4.log`; `-bft2/-bft3` were the test file's two isolation fixes; no warning in
  a touched file — the one in `SidebarView.swift` is :453's, `98924b443c`'s). The whole headless suite GREEN bar the
  two standing flakes, each isolated green ×2 (Suites below). **PENDING:** the Mac pins' RUN and the walk leg (the
  final window).
- **6 · The record's close (RB-6's chord sweep, canon owed, the orchestrator's leg), ledger row 6 + the batches
  table:** DONE (this commit).

### THE PROBE (her "a selector that I can also operate via keyboard"; the brief's "probe the existing sheet first")

- **The doors today** (`CapabilityRegistry.swift` — `.moveNoteToWing` / `.copyNoteToWing` :2173–2186, `.moveBookToWing`
  :2192–2197; ⌘L `.switchWing` :2620–2625): the note acts' doors are `[.contextMenu, .bottomBar]`, the book's
  `[.contextMenu]`, availability `always` (each row door carries its own target); no `.palette`, no chord.
- **"The existing wing selector" is a SUBMENU, not a sheet.** Every Move/Copy to Wing door renders a SwiftUI `Menu` of
  the destination wings (`WingNoteDoors` — `WingsModel.swift` :366–409, the Library/Pool/sidebar rows and both note ▾
  menus; the Bookcase row's — `ShelfView.swift` :858–868). A submenu is reachable only by pointing at its parent menu:
  ⌘K cannot open it, so there is no existing move sheet to verify. **The app's one keyboard-operable wing selector is
  ⌘L's switcher** (`WingSwitcherSheet` + the pure `WingSwitcherBrain` + `WingSwitcherKeyCatcher`): the field arrives
  focused (`.task { fieldFocused = true }`), typing filters (case- and diacritic-insensitive), ↑/↓ step and wrap, ⏎
  commits the highlight, Esc closes through the window-scoped monitor — every behaviour her words ask for, pinned at
  the brain (`WingSwitcherChordTests`). It is bound to a different act (it SWITCHES), so it cannot be opened as-is for
  a move. **Outcome: the face fix is a destination-picking twin of the switcher — the same brain and key catcher over
  the act's own destination rows (`WingsModel.destinations(from:)`), never a second filtering rule.**
- **The gates the context doors read today** (the rules this batch shares, never copies): a note's doors draw while
  `wings.destinations(from: <the note's wing>)` is non-empty (`WingNoteDoors.body`, `CommitBar` :909–911); a book's
  draw on `WingBookMoveDoor.drawn(reading:destinations:)` (`WingBookMoves.swift` :36–43 — another wing exists AND not
  the daily Journal's 'daily' marker).
- **The re-ask (the brief's item 3 — "should hold by construction; verify"): it does NOT hold by construction.** The
  VX-425 re-ask is PER DOOR: each renderer's `onDone` bumps its own surface's one-shot reads (the sidebar's
  `wingActGeneration` — `SidebarView.swift` :265, :1344–1352, :1123–1126; the bars' `NoteMenuWingContext` reload —
  `CommitBar.swift` :916–928, `TakesBottomBar.swift` :528–540; the Library catalog's `model.refresh()`). A ⌘K door
  has no `onDone` into any of them: moving the focused note (which sits in the Open list) from ⌘K would leave the
  sidebar row's doors listing from the OLD wing and its indicator blank (VX-439 ladder r1's m-3 exactly), and the open
  note's own note ▾ menu listing the wing it now lives in. THE DESIGN item 6 closes it at the shared brain.

### THE DESIGN (settled before code; each PROVISIONAL item is bundled)

1. **The `.palette` door on `.moveNoteToWing`, `.copyNoteToWing`, `.moveBookToWing`** (P-1 — declared once; the walk
   `thePaletteRendersExactlyTheDeclaredPaletteDoors` covers them by construction once `ShellActions.paletteActs`
   carries them). Verbs unchanged ("Move to Wing" / "Copy to Wing" — the registry's, worn by the submenus too).
2. **The routed availability — the ⌘K door's gate as REGISTRY DATA** (the `.toggleStar` / `.newNoteInBook` split:
   the row doors carry their own target and keep their drawing rules; the target-less door reads the context): note
   acts `focusedPaneShowsNote && wingCount > 1`, the book act `focusedPaneShowsBook && wingCount > 1`. No door reads
   `isEnabled` for these today (verified: `EditorCommands`, `ContextBar`, `OneWingChord`, `RootView.navigate` are the
   only readers), so nothing she sees elsewhere changes. The per-TARGET half is the existing rule:
   `WingBookMoveDoor.drawn` keeps the daily Journal out. **Note vs book focus:** a pane showing a note (`.post`) offers
   the note's two rows; a pane showing a book (`.reading` — a book or a gathering, any book mode) offers the book's
   row — never both, so the two identical "Move to Wing" verbs never list together (C-570-1's reading: a book pane is a
   book context, a note pane a note context; `.newNoteInBook` / `.closeNote` read the same two facts).
3. **The palette lists these three only where they can act** (P-2: "a door that can never act in its context isn't
   rendered"; the ticket's "gate it by the existing rules") — `WingPaletteDoors.lists` (pure, `Core/Views`):
   the registry's availability over the facts, then `WingBookMoveDoor.drawn` for the book. Every OTHER palette row
   keeps the palette's standing grammar (listed always, speaking its honest note). The facts are the focused pane's
   at ⌘K's press, read once per open (`PaletteModel.prepare()` asks the shell's source; the book's row is read for the
   daily-Journal marker); `refresh()` keeps the command list its rows were built from, so a row's index always names
   the command it listed (a source answering mid-open can never skew ⏎). PROVISIONAL RB-16 (the palette's second
   grammar).
4. **The act opens the keyboard wing selector** — `ShellActions` names the request (`ShellRouter.wingDestinationRequest`
   — the `bookMintRequest` shape: the focused note or book, a fresh token per press); the window adopts it
   (`RootView`), the model resolves the subject (the note's own wing through `NoteMenuWingContext.load` — an open
   note can be another wing's; the book's `wingId`) and its rows (`wings.destinations(from:)` — exactly the submenu's
   rows, Home first), re-checks the gate at open (a race speaks the act's registry note or the op's own daily-Journal
   refusal), and presents `WingDestinationSheet`: the switcher's idiom — the field focused on arrival, type-to-filter,
   ↑/↓, ⏎ chooses, a row click chooses, Esc closes (the switcher's window-scoped monitor); ⌘L inside it steps like ↓
   and is consumed (so the menu's ⌘L never stacks the switcher under it), and NOTHING commits on a key's release (a
   move is never a held-⌘ release). Words: the field "Move to a wing" / "Copy to a wing"; the foot "“X” is in Home ·
   ⏎ chooses · esc closes"; no match "No wing has that name." (the switcher's). PROVISIONAL RB-15.
5. **The choice runs the EXISTING acts and confirms** — never a second road: a note's move through `WingsModel.moveAsk`
   (a bookless note moves at once; a note in books opens `wingMoveConfirm`, its frozen-book refusal said), a copy
   through `WingsModel.copy`, a book through `WingsModel.bookMoveAsk` → `wingBookMoveConfirm` (it always asks). The
   confirms are hosted ON the selector (an alert over the sheet — the switcher's nested-ask precedent); the act's
   receipt closes it; the confirm's Cancel returns to the selector (Esc then closes it). One choice in flight at a
   time (a second ⏎ while the act lands does nothing).
6. **The re-ask after ANY wing act, by construction** — `WingsModel.actGeneration` (observable, bumped after every
   landed `move` / `copy` / `moveBook` / `moveContents`) joins the keys of the window's one-shot wing reads: the
   sidebar's two (`noteRowsWingKey`, `openWingsKey` — its own `wingActGeneration` stays, the VX-439 contract) and the
   note ▾ menu's context (`noteMenuWingDoors`' task, both bars). A signal, never a decision (P-4): each read re-asks the
   store. Any door that runs the shared acts — the ⌘K selector included — re-asks every one of them in its window.
7. **No chord** (her call — RB-6: the collision sweep is recorded, nothing built).

### THE TRACE — the re-ask (the one mechanism this batch closes beyond the new door)

- **Inputs → wrong state, on the pre-fix tree (traced in this session's reading; red by the pin below):** a note open
  in the Open list (Home) is moved to "Work" by a door OUTSIDE the sidebar — ⌘K's selector (new) or, already before this
  batch, a Library/Pool row's Move to Wing ▸ or the open note's own note ▾ menu — all through `WingsModel.moveAsk` →
  `move` → `Operations.moveNoteToWing`. The sidebar's two one-shot reads are keyed on `noteRowsWingKey` /
  `openWingsKey` = rows + current wing + the column's PRIVATE `wingActGeneration`, which only the sidebar's own row
  doors' `onDone` bump (`wingActDone`). The rows are unchanged (the note stays open), she still stands in Home, and no
  other door can reach the private generation — so neither read re-runs: the row's Move/Copy ▸ still lists from Home
  (offering "Work", the note's own wing, and omitting Home) and its wing indicator stays blank. The same for the open
  note's note ▾ menu: its `NoteMenuWingContext` loads per `postID` (`.task(id: postID)`) and re-loads only after ITS
  OWN doors' acts. (VX-439 ladder r1's m-3 named the row-door half and closed it per door; the cross-door half — any
  door but the surface's own — was never keyed.)
- **The mechanism closed (`403c6e843`):** the shared brain counts every landed wing act (`WingsModel.actGeneration`,
  bumped by `wingActLanded()` after `move` / `copy` / `moveBook` / `moveContents` land — a refusal changed nothing and
  signals nothing), and the three one-shot reads key on it. Every door that runs the shared acts — the ⌘K selector,
  the Library/Pool rows, the sidebar rows, both note ▾ menus, the Bookcase row, the switcher's Move Everything —
  re-asks them all in its window. The sidebar's own `wingActGeneration` stays (VX-439's pinned contract); for a
  sidebar row's act both fire, two idempotent re-reads.

### PINS (red-on-old evidence)

All in NEW `App/Variorum/VariorumTests/WingPaletteDoorsTests.swift` (suite `WingPaletteDoorsTests`, 10 tests,
`.serialized`) — COMPILED into `b4`, RUN PENDING the final window:

- `theThreeWingActsGainThePaletteDoorWithTheirGateAsData` — `.palette` on each, in `paletteActs`, no chord; the gate
  table (a note pane + two wings acts; one wing, a book pane, a place never; the book act the mirror) and the two
  identical "Move to Wing" verbs never enabled together. **Red on old by construction:** no `.palette`, availability
  `always` (every `!act(…)` expectation fails).
- `thePaletteListsTheWingRowsExactlyUnderTheirGates` — `WingPaletteDoors.lists` over seven facts (a note / one wing /
  a book / a gathering / the daily Journal / a book with one wing / a place), every other palette act listed under
  every facts; `paletteEntries(listing:)`'s titles: one "Move to Wing" + one "Copy to Wing" on a note, one "Move to
  Wing" and no "Copy" on a book, neither elsewhere (`paletteActs.count - 3`), and the unfiltered list whole.
- `theListingFactsAreWhatTheFocusedPaneShows` — the facts at the press: `.post` → the note; `.reading` → the book read
  whole (the row lists); the daily Journal's pane → the row does NOT list; a place → `.other`.
- `aRowAsksTheWindowForTheSelectorOrSaysWhyNot` — one wing: the press speaks the act's note (a refusal), no request;
  two wings: `.moveNote` / `.copyNote` requests, a fresh token per press, the palette row runs the same; a book pane:
  the note's acts speak, the book's requests `.moveBook`.
- `theSelectorListsTheSubmenusRowsAndItsKeysChoose` — the rows == `wings.destinations(from:)` (never its own wing;
  Home included for a note living elsewhere); the brain's keys (↓, ↓ wraps, ↑ wraps, case-insensitive filter, nothing
  listed ⇒ ⏎ stays); ⏎ moves a bookless note at once with the act's own receipt; a click chooses; Copy leaves the
  original and lands one copy in the chosen wing with its receipt.
- `aNoteInABookAndEveryBookAskFirstAndTheGatesHoldAtOpen` — one wing: `open` says `switchWingUnavailable`, no empty
  selector; a membered note asks (`pendingMove.leaves == ["Alpha"]`, nothing moved until the confirm's Move); a book
  always asks; the daily Journal never opens a selector (the op's own words).
- `theSelectorArrivesFocusedAndAnswersTypingReturnAndEsc` — **MOUNTED** (NSWindow + NSHostingView, the
  `MastheadTagDoorTests` / `LibraryControlsFlowTests` idioms): the field is EDITING on arrival with the window's first
  responder its editor (nobody clicked), typing through the field editor reaches the brain and filters, ⏎
  (`doCommand(by: insertNewline:)`, the Return key's own road) closes the selector and the note lands in the chosen
  wing; a real Esc `NSEvent` (`NSApp.sendEvent`, the `BookcaseMastheadPopoverTests` road) closes it with nothing moved.
  ↑/↓ are the palette's and the switcher's walked `.onKeyPress` idiom, pinned at the model above and driven for real by
  the walk. Red on old by construction (no selector).
- `everyLandedWingActSignalsAndTheNoteMenusContextKeysOnIt` — move, copy, book move and move-everything each bump the
  signal; a refusal (a note in a finished book) does not; the note ▾ menu's load key changes with it, and the bars'
  modifier keys its task on it (source).
- `aWingActFromAnyDoorReasksTheSidebarsReads` — **MOUNTED** (VX-439's m-3 pin, WITHOUT its `done()`): after
  `wings.moveAsk` (the act every outside door runs) the row's doors read from Work and its indicator names "Work".
  **RED ON OLD by mechanism (THE TRACE):** on the pre-fix keys nothing outside the column re-keys the reads — the m-3
  pin's own premise, which is why it had to call `done()`. Optional behavioural leg for the window: delete the two
  `+ "|\(wings?.actGeneration ?? 0)"` clauses in `SidebarView.swift`, rebuild `b4`, run this test → the two polls red;
  restore with `git checkout -- App/Variorum/Variorum/Features/Library/SidebarView.swift`.
- `theWindowPresentsTheSelectorAndThePaletteListsPerOpen` — the window's wiring, read: the selector sheet and its
  request, the palette's per-open source, `prepare()` before the first `refresh()`, ⏎ through `listedCommands`, the
  sheet's focus task, its arrow keys and its Esc catcher.

**Justified edits (each cites VX-377 in place):** `CapabilityRegistryTests` — two sampled contexts (note + two wings;
book + two wings) and `takesIsNeverBehindWrite`'s two contexts satisfying the pane facts and the wing count (non-mode
gates); `WingSwitcherTests.theWingActsAreDeclaredAndRendered` and `WingBookMoveDoorTests.theBookMoveActsAreDeclaredAndRendered`
— the door sets gain `.palette`, `paletteActs` carries each. **Re-read and UNCHANGED:**
`SidebarNoteRowMenuTests.aMoveFromTheRowReasksWhichWingItsDoorsAndIndicatorRead` (its `done()` still re-asks; the
new signal re-asks first — its expectations hold either way) and `theColumnsWingDoorsHandTheReaskAndBothReadsAreKeyedOnIt`
(both keys still carry `wingActGeneration`); `PromoteAndPaletteTests` (a harness palette has no source — `prepare()`
leaves its `commands`; `execute` reads the list `refresh()` built from, which the pins set before refreshing);
`WingSwitcherChordTests` (the brain and the catcher are reused, never changed).

### Files touched

App: `Registry/CapabilityRegistry.swift` (the three declarations; `noteWingDoor`) · `Registry/ShellActions.swift`
(`paletteActs` +3; `paletteEntries(listing:)`, `listedPaletteEntries()`, `paletteListingFacts()`,
`openWingDestination(_:)`; the three palette actions) · `ShellRouter.swift` (`WingDestinationRequest`,
`wingDestinationRequest`) · `Features/CommandPalette/CommandPalette.swift` (`commandSource`, `prepare()`,
`listedCommands`; the view's task) · `RootView.swift` (the per-open source; the selector's state, sheet and request
adoption) · NEW `Core/Views/WingDestinationSheet.swift` (`WingPaletteDoors`, `WingDestinationModel`,
`WingDestinationSheet`, three `WingCopy` words) · `Core/Views/WingsModel.swift` (`actGeneration`, `wingActLanded()`,
the two bumps; `NoteMenuWingContext.LoadKey` / `loadKey`; `noteMenuWingDoors`' task key) · `Core/Views/WingBookMoves.swift`
(the two bumps) · `Features/Library/SidebarView.swift` (the two keys). Tests: NEW `VariorumTests/WingPaletteDoorsTests.swift`;
justified edits to `CapabilityRegistryTests`, `WingSwitcherTests`, `WingBookMoveDoorTests`. Untouched, by the lane
(verified by `git diff --stat 956c9984e..HEAD`): `Sources/`, `Tests/`, `Server/`, `App/Variorum/Shared/`,
`App/Variorum/VariorumMobile/`, every MCP file, the editor seam, every schema. Commits: `8b10ece08` (record) ·
`fc25c3092` (registry) · `b9d26b816` (listing, request, selector) · `403c6e843` (re-ask) · `1e9a8f1f7` (pins) · this
record's commit.

### Suites (the end, on the final code — `swift build` green; the record's commits change no code)

- **The whole headless run** (`scratchpad/b4-logs/headless-all.log`, `swift build` then `swift test` on `1e9a8f1f7`'s
  code — no core, MCP or Strings line changed this batch, so the counts are batch 3's exactly): VariorumCoreTests
  **3484 tests / 465 suites** (5 known issues, standing) with ONE red — the standing VX-625 flake
  (`StarContextTests.aHeldObservationOfAStarGatheringHearsTheUnstar`, its one-minute limit under the full-parallel
  load), re-run ISOLATED green ×2 (`starcontext-isolated-1/2.log`: 11 / 1, 0.8 s each); VariorumMCPTests **431 / 79**
  with ONE red — the standing VX-532 flake (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`,
  24.9 s against its 15 s), re-run ISOLATED green ×2 (`harness-isolated-1/2.log`: 3 / 1, 2.2 s each); StringsWorkbook
  **32 / 4 passed**. VX-607 green in the run.
- **Mac:** `build-for-testing` into the FRESH `DerivedData/b4` — **TEST BUILD SUCCEEDED** (`mac-bft4.log`), built from
  `1e9a8f1f7` (batches 1–4 + the 2-F1 leg: `b4` is the final window's one product). **PENDING:** the Mac pins' run.

### RB-6 — THE CHORD SWEEP (her call; nothing built), at this tip

- **`EditorCommands.keyEquivalent`'s `l` chords:** ⌘L (Switch Wing), ⇧⌘L (Save Choices as Lens), ⌃⌘L (Lock Library
  Now). The table's ⌥⌘ family: ⌥⌘Z / ⇧⌥⌘Z, ⌥⌘O, ⌥⌘A, ⌥⌘, , ⇧⌥⌘D / ⇧⌥⌘M, ⌥⌘T / ⇧⌥⌘T, ⌥⌘⏎ / ⇧⌥⌘⏎, ⌥⌘← / ⌥⌘→,
  ⌥⌘C, ⌥⌘F, ⌥⌘S, ⌥⌘[ / ⌥⌘], ⌥⌘N — **no ⌥⌘L, no ⇧⌥⌘L.**
- **Every `.keyboardShortcut(` call site in `Variorum/` and `Shared/`:** `l` only as ⌘L (`EditorCommands.swift:545`),
  ⌃⌘L (:592) and ⇧⌘L (:828); `m` as ⇧⌘M (:752) and ⇧⌥⌘M (:760); `w` as ⇧⌘W (:1054). **`NSMenuItem` keyEquivalents:**
  all "" (`MarkdownActs`, `CalloutMenu`, `EditorTextView`, `PaneSurface`).
- **The local key monitors:** `WingSwitcherKeyCatcher` (⌘L / Esc / ⌘'s release — the switcher's sheet, and now the
  selector's, its own window only; it classifies ⌥⌘L as nothing), `OneWingChord` (bare ⌘L with one wing),
  `BrowserNavKeyMonitor` (⌘← / ⌘→), `PageTurnKeys` (bare ← / →), `CommentsPanel` (⌘⏎, ⎋), `MenuLifeReporter` (⎋),
  `DivideWSheet` (refuses ⌘/⌃ events), `CalmAsks` / `ProtectionController` (observe only), `PressReporter` /
  `PaneFocusCatcher` (mouse). **System hot keys:** `[.quickNote]` ⌃⌥⌘N. **The platform:** ⌘M, ⌘W, ⌥⌘W (Close All),
  ⌥⌘M (Minimize All), ⌥⌘H, ⌥⌘D, ⌥⌘Esc, ⌥⌘Space are the system's.
- **The free candidates:** (a) **⌥⌘L "Move to Wing…"** — the ⌥ "deliberate variant" of ⌘L, her standing modifier
  grammar (⌥⌘Z beside ⌘Z, ⌥⌘N beside ⌘N, ⌥⌘S beside ⌘S, the ⌥⌘⇧ ceremonies), on the wings letter; Finder's and
  Safari's ⌥⌘L (Downloads) are app-scoped; (b) **⇧⌥⌘L "Copy to Wing…"** — the ⇧ step of the same family (⇧⌥⌘T,
  ⇧⌥⌘Z); (c) ⌃⌘M (free, an unrelated letter — listed for completeness). Not free: ⌥⌘W, ⌥⌘M (system), ⇧⌘M (Merge).
- **What a chord would cost:** a `.menuBar` door + its `keyEquivalent` row + its helper (⌘/) row (R73/R91/R93), reading
  the availability THIS batch made honest (grey without a focused note/book or with one wing); a chord pressed on the
  daily Journal's pane would reach the selector's open-time re-check and speak the op's own refusal (a menu item cannot
  read the book row synchronously) — P-2-honest, no new road.

### Canon owed at the closeout (DRAFTED for the closeout — not applied; the two-file rule)

- **SurfaceContracts, The app — the keyboard family bullet, after** "⌥⌘S is Export Note… (VX-125);" **insert:** "⌘K
  reaches Move to Wing and Copy to Wing on the focused note, and Move to Wing on the focused book or gathering —
  listed only while another wing exists and never on the daily Journal — each opening a keyboard wing selector (the
  field focused on arrival, type to filter, ↑/↓, ⏎ chooses, esc closes) whose choice runs the right-click's act and
  confirm (VX-377, PROVISIONAL RB-15/RB-16; no chord — RB-6);".
- **SurfaceContracts, The app — the Open list bullet:** "and the wing listings re-ask after any move (VX-425)" →
  "and the wing listings re-ask after any move from any door in the window (VX-425; VX-377)".
- **AppSpec:** nothing goes false (§12's keyboard-family summary names chords only; "⌘K is the palette" stands). No line
  owed.
- **The dated entry + narrative → `notes/AppSpecRecord.md`:** her two quotes (2026-10-16, 2026-10-21); the probe (the
  doors were a submenu; ⌘L's switcher the one keyboard wing selector, its brain reused over the destinations); the
  listing grammar (RB-16) and the note-vs-book focus; THE TRACE's cross-door re-ask and the shared signal; RB-6's sweep.

### THE BUNDLE items born here (fold into §THE BUNDLE)

- **RB-6 (her call — the chord; nothing built):** the sweep above. Free: **⌥⌘L Move to Wing…** (the ⌥ deliberate
  variant of ⌘L) and **⇧⌥⌘L Copy to Wing…**; not free: ⌥⌘W, ⌥⌘M, ⇧⌘M. The ⌘K door ships either way.
- **RB-15 (copy, her pass):** the selector's field "Move to a wing" / "Copy to a wing"; its foot "“X” is in Home · ⏎
  chooses · esc closes" ("chooses", never "moves" — a note in books and every book ask first); no-match "No wing has
  that name." (the switcher's). The palette rows wear the registry's verbs "Move to Wing" / "Copy to Wing" (the
  submenus' titles, no ellipsis) — options: (a) as built; (b) "Move to Wing…" on the verb (the submenus then read with
  an ellipsis); (c) a palette-only title (a second spelling of one act — against P-1's one verb).
- **RB-16 (PROVISIONAL, design — the palette's second grammar):** these three rows list ONLY where they act; every
  other palette row is listed always and speaks its note where it cannot. Options: **(a) as built** (P-2's letter; on a
  note pane the note's two rows, on a book pane the book's one — never two identical "Move to Wing" rows); (b) always
  listed, speaking the note (the older grammar — two identical "Move to Wing" rows on every pane, one refusing); (c) (a)
  extended to every context-gated palette row (a sweep — its own ticket).
- **RB-17 (for the ladder):** (i) the re-ask signal is PER WINDOW (each window owns its `WingsModel`), as the per-door
  re-ask was — a wing act in one window leaves a second window's sidebar and bars as they were before this batch;
  (ii) the shared signal also closes the pre-existing cross-door half (a Library/Pool row's or the note ▾ menu's move
  left the sidebar's Open indicator and row doors stale) — the same pin covers both roads; (iii) the selector consumes
  ⌘L as a step (like ↓) so the menu's ⌘L never stacks the switcher under it, and no key's release ever commits; (iv) the
  palette → selector hand-off is two RootView sheets in sequence (the palette dismissing as the request's async open
  lands) — walk-verified only; ⌘K's ceremony rows opening the ceremony sheets are the standing precedent.

### For the orchestrator (not this batch's to run)

- **The Mac batch** (stage, via the coordinator) — the product is prebuilt at `~/dev/variorum-vx-620/DerivedData/b4` (a
  FRESH dir, never a clone; built from `1e9a8f1f7` — batches 1–4 and the 2-F1 leg, so every batch's list runs from it):
  `cd App/Variorum && xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  ~/dev/variorum-vx-620/DerivedData/b4 test-without-building` with `-only-testing:VariorumTests/<SuiteType>` — TYPE
  names, verified against the files (the mid window's trap): **the pins** `WingPaletteDoorsTests` (NEW, 10) ·
  `CapabilityRegistryTests` · `WingSwitcherTests` · `WingBookMoveDoorTests` (the justified edits); **the neighbours**
  `WingSwitcherChordTests` · `SidebarNoteRowMenuTests` (VX-425's m-3 pins — the keys grew) · `PromoteAndPaletteTests`
  (the palette's execute) · `PaletteSearchTests` · `BlockHistoryPaletteDoorTests` · `QuickNoteDoorTests` ·
  `NewNoteInBookTests` · `DuplicateDoorsTests` · `NoteExportTests` · `WingFollowTests` · `WingFollowDecisionTests` ·
  `StarTargetingTests` · `StarActingTests` · `ChromeLineLimitTests`. State the EXECUTED count (VX-604); read the
  `skipped:` lines. Optional red leg: PINS' `aWingActFromAnyDoorReasksTheSidebarsReads` note.
- **The walk leg (dev store, Debug from `b4`; the selector's face in BOTH voices; VX-prefixed content):** the dev store
  as found holds Home + the empty "Walk Wing" (two wings — no wing to make). (1) A bookless note "VX377 walk note" in
  Home, open in Write. ⌘K, type "move" → the rows "Move to Wing" and "Copy to Wing" show (one of each) → ⏎ → the
  selector appears with the keyboard already in its field (type WITHOUT clicking) — its one row "Walk Wing", the foot
  "“VX377 walk note” is in Home · ⏎ chooses · esc closes"; capture both voices → type "walk" → ⏎ → the receipt
  "Moved “VX377 walk note” to “Walk Wing”."; the sidebar's Open row now wears the "Walk Wing" indicator and the note ▾
  menu's Move to Wing ▸ lists Home (the re-ask). (2) ⌘K → "Move to Wing" → the selector lists Home → ↓ / ↑ step (one
  row: the highlight stays) → ⏎ → back in Home. (3) ⌘K → "Copy to Wing" → Esc → nothing copied. (4) The gates: on the
  Bookcase (no note in the pane) ⌘K "move" lists no "Move to Wing". Optional (the pins cover both; the dev store as
  found has no books, so each needs walk content): a VX-prefixed book's pane lists ONE "Move to Wing" and no "Copy to
  Wing" (open its selector, Esc — move nothing); the daily Journal's pane lists none — only if a daily Journal already
  exists (⌘J would mint one: residue). **Restore:** the walk note (and any walk book) → the Trash; "Walk Wing" left
  EMPTY as found; nothing else written. **Watch:** if the selector does not appear after ⌘K
  closes (RB-17 (iv)), that hand-off is the suspect — report, don't work around.
- **MOBILE PARITY line:** nothing mobile-visible — the ⌘K palette, the registry, the sidebar and the selector are Mac
  only; `App/Variorum/VariorumMobile/` and `App/Variorum/Shared/` untouched (verified by diff).

### FIX LEG 4-F1 (the final window's red: `WingPaletteDoorsTests.theSelectorArrivesFocusedAndAnswersTypingReturnAndEsc`; implementer №4 resumed, 2026-10-27)

**The finding — MID620-F1 (THE FINAL WINDOW section; the coordinator's relay, the log `scratchpad/vx620-final-suites.log` :10979–11029):** the final window
ran the Mac pins from `DerivedData/b4` — 470 executed / 66 suites, all green but ONE: this pin, on its first run, at
`WingPaletteDoorsTests.swift:471` — `input.currentEditor()` nil ("the field is EDITING on arrival — nobody clicked
it"); the field itself WAS found (the `#require` on line 470 held), the suite's nine other tests green (the other
mounted pin, the sidebar's, among them). Failed after 1.084 s.

**LIVE STATUS (per piece, flipped in the same commit as each piece):**
- **No behavioural revert is in flight.**
- **F1-0 · The trace + the disposition:** DONE (this commit) — RIG-SIDE; the product's focus is right (below).
- **F1-1 · The fix (the rig — a JUSTIFIED EDIT, no product line):** DONE (this commit) — below.
- **F1-2 · Rebuild `DerivedData/b4` in place:** DONE (this commit) — `build-for-testing` into the EXISTING
  `DerivedData/b4` (rebuilt in place, never a clone): **TEST BUILD SUCCEEDED** (`scratchpad/b4-logs/f1-mac-bft2.log`;
  `f1-mac-bft.log` was the rig's first cut, before the control got the selector's wait), no warning in the edited pin.
  **`b4` is NO LONGER the final window's frozen evidence:** it is built from this commit's tree (batches 1–4, the 2-F1
  leg and this leg — the PRODUCT byte-unchanged since `1e9a8f1f7`; only this pin's rig differs). The re-run is a
  single-suite window (the coordinator's). Headless suites not re-run: no product line changed. (The build ran while
  another worktree's test host — `variorum-vx-562`'s own DerivedData, pid 89445 — was up; a build needs no stage and
  touches nothing of theirs.)

**The trace (inputs → wrong output), from the pin and the log — no `xcodebuild test` is mine to run, so the mechanism
is established by comparison, not by a run:**
- The rig mounted `WingDestinationSheet` as a NEW window's content and ordered the window in IN THE SAME TURN
  (`window.contentView = hosting; window.makeKeyAndOrderFront(nil)`), settled a FIXED 30 turns (~1 s — the test failed
  at 1.084 s) and read `currentEditor()` once. The field WAS in the hierarchy (line 470's `#require` held) but never
  editing.
- The test host's facts, measured by this target's own rigs: its windows are never key (`LaunchFocusRig`: "ordered in
  (never key here)" — `QuickEntryLaunchFocusTests` simulates key status for that reason), and AppKit picks a window's
  first text field as first responder AT ITS FIRST ORDER-IN (measured there). At this rig's order-in the hosting view had
  not yet realized its `NSTextField` (SwiftUI builds the platform view on its first layout pass, inside the settle), so
  nothing was picked; the field's only road to the keyboard was the selector's `.task { fieldFocused = true }`, firing
  during the brand-new window's very first passes, and the read came after a fixed ~1 s.
- The target's two GREEN pins on the IDENTICAL product idiom (`.task { focused = true }`) do neither:
  `MastheadTagDoorTests.oneDoorAtRestAndTheFieldTakesFocusWhenItOpens` (green in prior full runs, 3.1 s) orders its
  window in with a field-less host, settles 20 turns, THEN swaps the focusing view in and settles 30 longer turns;
  `TitleQuickfillTests` opens its field after the window settled and waits UNTIL the field editor holds the keyboard
  (≤ 80 turns). This rig was the outlier on both axes (mounted at first order-in; a short fixed read). Which of the two
  bit cannot be singled out without a run; the fix closes both.
- **The product — focused in use (the walk's verdict, THE FINAL WINDOW part 2):** the selector arrives KEYBOARD-FOCUSED
  WITHOUT A CLICK in both voices, three times; the captures agree (`scratchpad/walk-final/selector-move-study.png` — the
  caret IN the field under the prompt "Move to a wing", before any typing; `selector-typed-walk-study.png` — "walk"
  typed, filtering to "Walk Wing"). The same idiom arrives focused in her daily ⌘K (`CommandPaletteView`) and in ⌘L's
  switcher. **Disposition: RIG-SIDE — no product line changes; a product fix would have no red to turn green.**

**The fix (the rig only; 4-F1 cited in the pin's doc — a JUSTIFIED EDIT):** `mount` orders the window in EMPTY (a clear
host), settles 20 turns, clears the first responder, and only then mounts the content (the tag pin's shape — and the
sheet's own situation: a face arriving in a window already on screen); the read waits UNTIL the field's editor exists (≤
80 turns, the title pin's bound) before the UNCHANGED `#require` on `currentEditor()` and the UNCHANGED
`window.firstResponder === editor`. **The teeth — a CONTROL in the same rig:** a plain SwiftUI `TextField` that asks for
nothing is mounted through the same `mount`, given the SAME wait, and must stay unedited with its window's keyboard
free — the rig grants no field focus by itself, so the selector's focus can only be its own `.task`'s (remove that line
and the pin goes red at "the field is EDITING on arrival"). The typing, ⏎ and Esc legs are unchanged. **Optional red
leg for the re-run window:** delete `.task { fieldFocused = true }` in `Core/Views/WingDestinationSheet.swift`, rebuild
`b4`, run this one test → red at "the field is EDITING on arrival" (the control still green); restore with `git checkout
-- App/Variorum/Variorum/Core/Views/WingDestinationSheet.swift`, rebuild.
