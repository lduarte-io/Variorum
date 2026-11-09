# VX-915 — Umbrella: the recents sweep

**STATUS: OPEN (kicked off 2026-11-09). Orchestrator session `vx-915`; /architect-phase; nov7 coordinating. Branch `vx-915-recents-sweep`, worktree `~/dev/variorum-vx-915`, the Pro. PR at close: `VX-915: …`, merge commit only.**

## FOR A LATER READER

*(Written at closeout. Until then this file is the night's working record — LIVE STATUS tables and batch records below.)*

---

## Kickoff (2026-11-09)

Her Nov 8 composition ("there's lots of quick follow ups"): the recently-minted small items from the November waves' born piles, gathered under one umbrella. Part of the LAST code wave before her open-source pause (#268 addendum: "I'll be pausing code changes once this current wave is done (including the umbrella we're about to mint)"). Runs beside VX-940 (pre-OSS follow-ups) and VX-926 (test flakes) on the Pro — overlap notes below.

- **Members (the SUB-ISSUE roster, re-listed at kickoff per the VX-548 rule — the description was stale by two):** VX-888 · VX-782 · VX-869 · VX-841 · VX-843 · VX-848 · VX-852 · **VX-916** · **VX-934** (the two the description never named). **Kickoff riders, accepted by her at the sitting (2026-11-09):** VX-793 · VX-928 · VX-929 · VX-927 (all four offered, all four taken). **Minted at her kickoff ask:** VX-943 (`unlink_versions` — her planetlillian agent's note, her words verbatim on the ticket). Fourteen members, six batches.
- **Cast (the umbrella's line, hers):** standard — `opus-implementer` (xhigh) per batch, FRESH per batch; Fable orchestrates and adjudicates; the ladder's cold reviewer is **`opus-reviewer` eligible EXCEPT where the run's diff touches the pane seam** (VX-782's territory — decided at the ladder from the actual diff; `fable-reviewer` if any diff line reaches `PaneSurface`/`EditorTextView`/`BlockRangeIndex`/the read tier). Pin-before-fix binds PER MEMBER (bug-class members red-on-old; Improvement members pin the NEW contract); the cold review covers the run's whole diff.
- **No `Sync/`, no custody (the umbrella's line: "No Sync/ — runs free of the slot").** VX-916 is GUIDE SEED TEXT (CastleRules wording territory, app-side seeder) — zero `Sources/VariorumCore/Protection/` or custody code; any batch line that would reach `Sources/VariorumCore/Sync/`, custody/keychain code, or the editor seam's identity machinery STOPS the batch back to the orchestrator.
- **Overlap (the in-flight table, checked at kickoff):** VX-940 holds the MCP door's INTERNALS (VX-922 wing projection, VX-925 NUL version, VX-933 socket transport) and repo-level files (LETTER.md, Acknowledgments — Settings-adjacent); this run holds the MCP PANE/FACES (VX-934) and ONE wire tool (VX-943). Different functions, same neighbourhood — `SettingsShape.swift` and the MCP tool files are the conflict candidates. CLOSEOUTS SERIALIZE: first-ready merges first, the next rebases. VX-926 owns the flaky-test seams (MCP socket clock, hermetic defaults) — this run's gates treat its targets as known false reds and never "fix" one in passing.
- **Coordinator protocol (nov7, in writing):** REQUEST (what/minutes/claim name, sent early) → READY (separate ping, able to start NOW) → GO (only from nov7, with the exact claim line; a FREE stage is never an invitation) → RELEASE + one result line naming EVERY failing test by name plus Executed counts. Headless `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` never need the stage; **EVERY `xcodebuild test` does** (the test host IS the dev-store app). Windows over an hour: tests first; ping before any dev-store write.
- **Known false reds (name, never chase; VX-926 is fixing this family — re-check its state at each gate):** VX-850 (MCP socket timing under parallel load, green alone) · VX-661 (swift-testing encoder SIGSEGV at exit) · VX-855 (purge-sweep vs pool teardown SIGSEGV) · VX-701 (standing flake, proven green alone) · the standing phone red `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`.
- **Dev store state (as left by vx-914, 2026-11-08):** Settings ▸ MCP server **ON**, `variorum-de` an approved client — KEEP it so (walk rows lean on it). Never press Resume Sync. Castle values only from `~/.variorum/dev-castle.env` if a walk meets the lock screen. Dev-store CONTENT is agents' to manage freely (her 2026-10-28 rule); the stage/account/Castle fences are unchanged.

**Preflight read at kickoff (none delegated):** CLAUDE.md + auto-loaded canon · the master plan (in-flight table; this run's row added at `1421ed8e9`) · `notes/TICKETS.md` (fresh snapshot pushed) · `notes/QUESTIONS.md` (#268 + addendum, #269 in full — VX-934's source; open rows scanned, none gates a member) · `notes/SessionResiliencyProtocol.md` · `notes/SurfaceContracts.md` IN FULL · `notes/MCPSpec.md` IN FULL (VX-934, VX-943) · `notes/CastleRules.md` IN FULL (VX-916 is a protection sentence) · `notes/TEXTKIT2_NOTES.md` (VX-782 may reach the pane seam) · the member records: `vx-914-walkthrough-followups.md` (F-905 + FOR A LATER READER), `vx-770-takes-compare-window.md` (R-B2-1, P-770-3, AS BUILT), `vx-805-journal-cluster.md` (VX-561's mechanism and fix shape), `vx-819-search.md` (batch 1 "Observed, pre-existing"), `vx-781-lockfile-pins.md` (§THE release.sh WIRING), `vx-529-pair-catchup.md` (THE COMPROMISE-RECOVERY RECIPE, R-529-6). Not triggered: SyncSpec (zero `Sync/` lines expected — any line reaching one stops the run).

**Coordinator window facts (nov7's ack, 2026-11-09):** dev-store posture CONFIRMED as vx-914 left it (18:06, untouched) — MCP server ON, `variorum-de` approved, test grant revoked, Private staging reverted, Resume Sync never pressed. VX-849 holds the `Sync/` slot this window (this run never needs it). Live beside this run: vx-926, vx-940 (MCP trio in `Sources/VariorumMCP` — the overlap is recorded with nov7, who trial-merges at flagged landings), vx-913 and vx-849. **Merges serialize through nov7, and the second merger MERGES main IN (a merge-in, never a rebase).** The MERGE GATE is the WHOLE Mac target (+ the phone target if any `App/Variorum/Shared/` line) on the final MERGED tree — never changed-source suites alone; a registry/ShortcutCatalog touch adds `CapabilityRegistryTests` + `ShellChromeTests`. `-only-testing` takes TYPE names as a zsh array (a file name drops silently; "Executed 0" is no verdict). Strict instance checks: `pgrep -lx Variorum`, `pgrep -lf "MacOS/Variorum$"`. Dismiss What's New after a Debug launch; a window over an hour pings SEAM; crash labels only after reading the faulting thread. Handoff notes owed: the wave's release run is the FIRST to exercise VX-852's verify-pins hooks; batch 4's guide edits join the owed real-store re-seed list.

**Her rulings at the kickoff sitting (2026-11-09):** the four offered riders all join ("VX-793, VX-928, VX-929, VX-927"); VX-943 minted at her ask, her relay of the planetlillian agent's note verbatim on the ticket: *"The item says link_versions has no opposite, so a version link can't be removed over MCP. It records today's stale day 42 ↔ V97 link and its ID. It asks for an unlink_versions that takes the ID link_versions already returns, at the same permission level. For now the stale link has to be removed by hand in Compare."*

## Binding principles — the 13b constitution (copied per the architect-phase skill; BYTE-VERBATIM)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut / palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data, never per-view if-statements. A registry-walk test asserts every declared door exists and every rendered door is declared. This kills the D3/D4 class structurally — the capability matrix stays green by construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch choreography, done visibly for the user — or delivers the operations layer's real refusal. A door that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component (live + read modes; one measurement brain — the width-gated remeasure; the shared canary) that every pane composes; the live editor core's identity machinery (`BlockRangeIndex`, crystallization) becomes its live mode, not a sibling implementation. "What text does this pane show, and is it live" is answered by ONE pure, unit-tested authority (`PaneTextAuthority`); views never re-derive it. Its invariants stated as code: exactly one live pane; the live pane is buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter may announce that something happened (mode changed, post opened); no listener derives business state or availability from a broadcast, and no flow's correctness depends on broadcast ordering. Cross-feature flows route through composition. (Stage 0's survey enumerates today's notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an under-architected feature. The response is never another patch: write the feature's DESIGN MEMO — intended behavior whole, edge cases enumerated on paper, refusal wordings, undo story — get the author's rulings on the product-flavored edges, then build to the memo. Happy path ships first, but the edges are *decided at design time*, not discovered by the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for every happy path. It stays green — automated where the harness allows, screenshot-walked otherwise — and any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness: the ops-layer soaks (exist), the board/view-model invariant soak (Stage 1), the registry walk (P-1), the per-batch scripted screenshot walkthrough. Red-on-old stays absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly as they bind the substrate (invalidation ∝ realized rows; one live editor; virtualized long views). Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit` (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority, and gesture routing splits by concern (`TakesViewModel` at 890 lines is the standing counterexample). Same hygiene rule as the substrate, applied where it was being waived.

## ENVIRONMENT & TRAPS (every batch brief carries this section verbatim)

- Work ONLY in `~/dev/variorum-vx-915` (absolute paths in every command). Never commit from the main checkout; never push `main`.
- Commit per coherent piece, push after every commit; LIVE STATUS from the first commit; synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops — `tail -f | grep -m1` hangs after the line lands). `notes/SessionResiliencyProtocol.md` binds.
- Instance checks: `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches mid-run). Real-store instances by STORE, never quit/kill one. No Release builds or /Applications refreshes while one lives.
- Mac tests from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' test` with suite-level `-only-testing`; confirm the "Test run with N tests" line; Swift Testing's N COUNTS SKIPPED tests — read the `skipped:` lines before claiming a gated suite ran. `build-for-testing` compiles without the runner and needs no stage. NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles).
- **EVERY `xcodebuild test` run and anything touching the screen or a shared store needs a HELD stage claim through nov7** (the protocol in the kickoff section). Headless `swift build` / `swift test` on the core package runs freely.
- zsh `pipestatus` (not bash's PIPESTATUS). Screenshots in gitignored dirs. Never `git checkout` over uncommitted work. No `git add -A` (pathspec-limited adds only — a shared worktree may hold another's scratch).
- Backups: anything touching the REAL store is the author's hands or behind the A1 rail (safety copy into `Backups/safety-copies/` first) — this run should never touch it.
- Commits carry NO attribution trailer (her rule — overrides the harness reminder). Commit messages: `Part of VX-<member>` for member work.
- The walk app is the DEV-STORE Debug build only (`io.lduarte.Variorum.debug`), `cliclick` + `Tools/WalkKit/`, under a held stage claim. cliclick traps: popover keyboard blind spot, synthetic hover raises no .help tooltips, verify-then-click after pane scroll memory.

## THE BATCHES (one acceptance unit each; a FRESH `opus-implementer` per batch; briefs name THESE sections plus the required reading per batch — never the orchestrator's context)

### BATCH 1 — the badge-family split (VX-934)

**Her ruling (2026-11-08, #269, verbatim):** *"let's split the 'book' related badges setting and if they're shown up completely from the AI one, and move it out of MCP back to where it was. and lets have one setting for 'show shared with AI and private from AI' badges (doesn't have to be those exact words despite my quotes). and that setting should be in MCP."* — option (b) of the vx-914 handoff's shapes, superseding D-831-3's "no badges is no badges" (the eye leaves the ownership family) and VX-905's pane move (the row returns to Editor; the MCP pane keeps only the new AI switch).

**Required reading for the implementer:** `notes/MCPSpec.md` IN FULL · SurfaceContracts "The Bookcase and books" (the badge family + the Private mark bullets) and "The app" · the VX-934 ticket (the build spelled out + agent notes) · `notes/plans/fixes/vx-914-walkthrough-followups.md` F-905 + batch-2 rows (VX-900/VX-905) + "Read as settled" + residuals.

- The BOOK-structure marks — the shared-across-books mark, the "owned by …" chip, the navigator's sealed chip — stay on `ownership_badges`; its "Show ownership badges" row moves BACK to Settings ▸ Editor (where it lived before VX-905).
- A NEW switch (wording the implementer proposes, hers to bless — NOT her quoted words; sentence case, no shouty caps) covers the AI pair: the shared-with-AI icon AND the Private eye, seated in Settings ▸ MCP. The shared icon becomes switchable for the FIRST time; the new switch is an AND on top of the approved-client gate and P1's rows-drawn law (nothing new is read); VX-900's dimmed server-off state rides the pair unchanged. The new key is a **synced setting of the enum class** (no prose — the E2EE PLAIN promise holds; default applied at READ time per the settings convention, no seed row).
- Both settings-search entries follow their rows. Code seams (the ticket's agent notes): `OwnershipSettingsCopy`, `SettingsShape` (pane membership ×2 + search entries), `MCPSharedIcon` / `PrivateMarkView` / `MCPShareRoad` (ONE shared read for the pair's new switch — both faces). The MCP pane's fresh-open geometry contract (`MCPPaneTabsTests`) must stay green when the pane's foot section changes — **grow it deliberately, never silently** (the VX-903 lesson).

**Evidence:** `OwnershipBadgeTests` + `PrivateMarkFaceTests` + `MCPIconTwinsTests` + `SettingsShapeTests` pins follow the split (justified edits named per pin); a NEW pin for the AI switch's AND (switch off ⇒ neither AI mark draws while the owned-by chip still does, and the reverse); the geometry contract grown by a named arm; settings-search pins both rows. Mac pins land PENDING(gate) headless; the batch gate runs them under a stage claim.

#### BATCH 1 — LIVE STATUS

*(the implementer writes this from its first commit)*

### BATCH 2 — Takes & Compare (VX-782 · VX-848 · riders VX-793 · VX-927)

**Required reading:** SurfaceContracts "The note" (the editor language — the one-law; the Compare bullet) · `notes/plans/fixes/vx-770-takes-compare-window.md` (R-B2-1; P-770-3 + AS BUILT; the F1 open-panel rule) · `notes/TEXTKIT2_NOTES.md` IF the fix reaches the pane surface (report to the orchestrator BEFORE touching `PaneSurface` or the read tier — that moves the ladder to Fable).

- **VX-782 (Bug, Confirmed — pin red-on-old):** `TakesCalloutFrame` pads the whole row by 5 pt (`Features/Takes/TakesCalloutFrame.swift:61-62`), so a callout block's prose moves right and narrows — against the pinned contract "the prose column's measure and left edge never move for a decoration". Write's callout rendering is the reference (the frame outside the text area; the measure untouched). Trace first; the fix keeps the callout's visible frame without moving the prose column.
- **VX-848 (Improvement — her ruling 2026-11-04):** the comment lane's EXISTENCE stays a pure function of column width (the one-law; presence-dependent lanes stay declined), but the FORM tier flips: wide Compare columns carry the **36-pt badge lane by default**, full comment cards only at genuinely wide layouts — the threshold is the implementer's to propose (bring the number and its why to the orchestrator before building; her eye at the walk). `CompareGutter.lane` (P-770-3's one-line flip, named in the vx-770 record).
- **VX-793 (rider, Improvement):** Compare can't add a block's FIRST comment — "Comments…" and ⌘⇧' are disabled on an uncommented block. With the gutter live in Compare (VX-728), an uncommented block has no door at all. Fire-and-DO (P-2): the door opens the panel on its block. If the trace reveals a deliberate reading-surface rule, STOP and report rather than flip it.
- **VX-927 (rider, Wording):** the Lineage face's against-now wash chip and "N changes since" still say "now" on a lineage member — VX-898's place-aware naming applied to the chip and the count line ("the take as kept" grammar; the pane headers already flipped).

**Evidence:** VX-782's red-on-old pin (the prose column's left edge and measure byte-equal with and without the callout frame — revert-verified); VX-848's lane pin flipped to the new default + the threshold pinned; VX-793's door pin (uncommented block's Comments… enabled in Compare, panel opens); VX-927's wording pins. The batch gate's suites under a stage claim.

#### BATCH 2 — LIVE STATUS

### BATCH 3 — the app shell (VX-869 · VX-841 · rider VX-928)

**Required reading:** SurfaceContracts "The app" (the capture bullet, the keyboard family, the quick-entry band) · `notes/plans/fixes/vx-805-journal-cluster.md` (VX-561's row — the traced mechanism and the sheet fix shape) · the VX-841 ticket (the design wrinkle resolved in it).

- **VX-869 (Bug, Suspected — the sweep):** VX-561 traced Esc-dead New Book to the macOS 26/27 `.alert` with a text field and THREE OR MORE buttons never drawing its declared Cancel. SWEEP every other `.alert` of that shape (enumerate by grep over `.alert(` + `TextField` + button count; record the table instance × verdict), confirm each live (the stage walk window — a sheet-conversion without a live confirm is not evidence), convert the affected ones to SHEETS per `NewBookSheet.swift`'s precedent (drawn Cancel on `.cancelAction`, the default act on `.defaultAction`, the field focused on arrival, words verbatim, dismissal-run choices). The class-completeness table lands in this record (the N14 closing form). A clean sweep (no other instance) is a legal outcome — record the table, close the ticket on it.
- **VX-841 (Improvement — her ask):** the quick note optionally picks the wing it lands in. The capture keeps its current default (NO extra press on the fast path); a QUIET wing control on the quicknote face redirects this one capture. The ruled wrinkle (on the ticket): a capture aimed at wing W lands BOOKLESS in W; the quicknote tag adopts-or-mints by path in W's vocabulary (R-13ia-1, the cross-wing move's precedent); W grows NO Quicknotes gathering unless one is deliberately made there. The control's exact seat and face: the implementer proposes to the orchestrator BEFORE building that half (the in-batch fork rule). Declared through the capability registry where a door is added (P-1).
- **VX-928 (rider, Bug — pin red-on-old):** the quick-entry band's ⏎ has no in-flight guard — two presses inside one mint file twice. The fix is VX-911's ⌘⏎-road guard applied to ⏎'s own road (the vx-914 record, batch 4 residual 2).

**Evidence:** the VX-869 sweep table (every instance FIXED-with-named-pin or provably SAFE with the mechanism stated) + live Esc confirms per converted dialog; VX-841's state-transition tests (the capture's wing landing + tag adoption by path — core tests, headless) + the fast-path-unchanged pin; VX-928's red-on-old double-⏎ pin.

#### BATCH 3 — LIVE STATUS

### BATCH 4 — the seeded words (VX-843 · VX-916 · rider VX-929)

**Required reading:** `notes/CastleRules.md` IN FULL (VX-916 writes protection sentences) · SurfaceContracts "The app" (the tour bullet, the seed set) and "Doors to the outside" (protection — context only; no code there) · `notes/plans/fixes/vx-529-pair-catchup.md` §THE COMPROMISE-RECOVERY RECIPE (her words verbatim — the content direction) + R-529-6 · the VX-843 ticket (her two ruled sentences) · the VX-916 ticket.

- **VX-843 (Wording, her ruled sentences verbatim):** (1) the end card's keep-going door: "Keep going: two more minutes on stars, tags, books, snippets and settings" (adds the fifth stop, Settings). (2) the Prince front note's last sentence becomes: "Restarting the tutorial restores any deleted parts of this book." THE TRAP (on the ticket): the front note is SEEDED text — check whether the mend/provenance machinery compares seed bytes (VX-716's territory) so the seed change neither reads as a user edit nor mints a twin at the next tour mend. Trace it; if the mend would double the note, the batch solves that first or stops back to the orchestrator.
- **VX-916 (Wording/Improvement — VX-529's riders, verified absent from the guide seeder):** the guide's protection chapter gains (1) THE COMPROMISE-RECOVERY RECIPE (her words in the vx-529 record are the content direction; the chapter's prose follows the guide's existing voice; the three moves, the already-in-Castle road, the honest limit, why a new account is not needed); (2) R-529-6's one line: the "your account's passphrase hasn't been typed on this Mac yet" state — why, why it isn't ideal, the road (type it once, or Reset forgotten passphrase) — agreeing with VX-538's card. CastleRules is the authority on every sentence: nothing promised beyond the rules; detect-and-say language; no sentence contradicts rules 2–7/25.
- **VX-929 (rider, Wording):** the guide teaches ⌘⏎ file-without-opening in the capture lessons; lesson 8's owned-book delete aside "(they go to the Pool)" softened to VX-45's honest split (archived members stay archived).

**Evidence:** the tour-copy pins updated to the ruled sentences (justified edits); the seed-provenance answer RECORDED with its trace (and pinned if machinery changes); the guide seeder's protection-chapter and lesson pins; guide content edits stale the REAL store's seeded guide — this run ADDS to the already-owed re-seed (vx-827 + vx-914's lesson 7) and the closeout says so to nov7/her.

#### BATCH 4 — LIVE STATUS

### BATCH 5 — small mechanics (VX-888 · VX-852)

**Required reading:** SurfaceContracts "The Library" (the search bullet) · `notes/plans/fixes/vx-819-search.md` (batch 1 "Observed, pre-existing") · `notes/plans/fixes/vx-781-lockfile-pins.md` §THE release.sh WIRING (the exact diff) + the VX-853 supersession note.

- **VX-888 (Bug, Suspected — repro FIRST):** a question whose only "words" are punctuation (e.g. `— #tag`) has `text != nil` but nothing the index can serve — the sheet lists no groups while the band reads the no-words branch's tag numbers. Pin the disagreement red-on-old, then make band and sheet agree (the spec-defensible shape: a word list that folds to nothing takes the no-words branch — the band's own read; propose if the trace argues otherwise). Present under All and under a picked facet (VX-734's path).
- **VX-852 (Improvement — the diff shape is ready):** wire `Tools/verify-pins` into release.sh exactly as the vx-781 record proposes — the preflight hook after the clean-tree refusal and the post-archive hook over `${BUILD_DIR}/DerivedData` with `verify-pins.txt` retained beside RELEASE-INFO.txt. **The release road is hers:** the wiring lands in this run's PR for her eyes at the merge; release.sh is never EXECUTED by this run. A dry syntax check (`zsh -n`) plus a verify-pins run against a scratch DerivedData is the evidence; no release is cut.

**Evidence:** VX-888's red-on-old pin (band and sheet agree on the punctuation-only question); VX-852's `zsh -n` + the two hooks' presence pinned by a source-walk test if the Tools tests have a home for it, else the record's diff + dry-run transcript.

#### BATCH 5 — LIVE STATUS

### BATCH 6 — the wire's unlink (VX-943)

**Required reading:** `notes/MCPSpec.md` IN FULL (binding — a new wire tool) · the VX-943 ticket (her relay verbatim) · the link_versions implementation and its R-VX187-1 record · AppSpec §9 (edges; the undo conventions).

- **VX-943:** `unlink_versions` — the opposite of `link_versions`, at the same permission level (her words; link_versions is WRITE NEW on BOTH notes — R-VX187-1). The request shape follows the TRACE of what link_versions actually answers today (her agent says it returns an id; if it does, take that id; if it does not, the implementer proposes the shape to the orchestrator BEFORE building — the in-batch fork rule). The door's standard posture, every piece: the grant check inside the op's transaction; ONE client-named ⌥⌘Z entry whose write-back honors VX-276 (quiet-retire when the row moved on); anything unreachable answers the ONE not-shared shape (hidden = missing — removing a link must leak nothing about an unreadable far side; VX-825's pure-function law pinned by the two-store catalog's pattern); worded refusals through the one chain (no raw Swift case); VX-606's undeclared-argument check comes free at the call door; the U+0000 identifier rule (VX-396) applies to the new id argument; Activity speaks it in words; `list_my_activity` lists it; the tool description states the rule and rung; `MCPSession.instructions` is touched ONLY if the budget allows and the sentence earns it (≤3,100 chars — check before writing; likely NOT needed, the description carries it). Compare's own unmark door is the semantic reference (a bare edge delete for an ordinary peer; note the SAVED-VERSION arm — unmarking a saved version PROMOTES, never a bare delete — the wire tool must refuse or exclude the version class the same way, since Promote is a bigger act; trace Compare's rule and mirror it, and bring the version-arm call to the orchestrator).

**Evidence:** the tool's pins in the MCP test home (the grant matrix including the not-shared shape on an unreadable side; the undo entry + quiet-retire; the refusal wording walk; the id-shape round trip with link_versions); red-on-old is the NEW contract's pin (Improvement class). Headless `swift test` covers most of this; the batch gate adds the Mac target's MCP suites under a stage claim if any app-side face changed (none expected).

#### BATCH 6 — LIVE STATUS

## THE LADDER

*(One ladder over the run's whole diff at the batches' close; fresh cold reviewer per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings land here repo-first before any fix session sees them; reviewer choice per the cast line above.)*

## THE LEDGER (every row owned; updated point-by-point as batches close)

| # | Member | Batch | Status |
|---|---|---|---|
| 1 | VX-934 badge-family split | 1 | NOT-STARTED |
| 2 | VX-782 Takes callout one-law | 2 | NOT-STARTED |
| 3 | VX-848 Compare lane default | 2 | NOT-STARTED |
| 4 | VX-793 Compare first comment (rider) | 2 | NOT-STARTED |
| 5 | VX-927 lineage "now" wording (rider) | 2 | NOT-STARTED |
| 6 | VX-869 alert-Cancel sweep | 3 | NOT-STARTED |
| 7 | VX-841 quick-note wing pick | 3 | NOT-STARTED |
| 8 | VX-928 ⏎ in-flight guard (rider) | 3 | NOT-STARTED |
| 9 | VX-843 tour wording | 4 | NOT-STARTED |
| 10 | VX-916 guide protection chapter | 4 | NOT-STARTED |
| 11 | VX-929 guide wording pair (rider) | 4 | NOT-STARTED |
| 12 | VX-888 search punctuation-only | 5 | NOT-STARTED |
| 13 | VX-852 release.sh pin check | 5 | NOT-STARTED |
| 14 | VX-943 unlink_versions (her mint) | 6 | NOT-STARTED |
