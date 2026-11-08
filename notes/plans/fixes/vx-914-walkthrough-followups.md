# VX-914 — Run: the walkthrough followups

**STATUS: OPEN (kicked off 2026-11-08). Orchestrator session `vx-914` (renamed by her from variorum-a7); /architect-phase; branch `vx-914-walkthrough-followups`; worktree `~/dev/variorum-vx-914`; the Pro. Coordinator: `nov7` (wave 3 — VX-912 runs alongside and holds the Sync/-custody slot; this run needs none).**

## FOR A LATER READER

*(Written at closeout. Until then: the kickoff section below is the map; the LIVE LEDGER is the state.)*

---

## Kickoff (2026-11-08)

The last wave before the open-source flip (VX-894, her frame). This run builds her Nov 7–8 walkthrough and bundle rulings: **all small, all ruled, no editor seam, no custody, zero `Sources/VariorumCore/Sync/` lines** — verified at kickoff: the one Castle-&-sync-labeled member (VX-909) lives app-side in `App/Variorum/Shared/SyncStatusViews.swift:362–367`, pinned by `App/Variorum/VariorumTests/SyncOutOfDateFaceTests.swift`.

- **Members (sub-issue roster, re-listed at kickoff):** VX-900 · VX-901 · VX-902 · VX-903 · VX-904 · VX-905 · VX-911 · VX-870 + wording riders VX-896 · VX-897 · VX-898 · VX-909. **Kickoff riders, accepted by her at the sitting:** VX-401 · VX-45 · VX-667 (seated as sub-issues 2026-11-08).
- **Cast:** standard — `opus-implementer` (xhigh) per batch, fresh per batch; **`opus-reviewer`** on the ladder (the umbrella's call: no editor seam, no custody, no `Sync/`, no default's-meaning content); Fable orchestrates and adjudicates. Pin-before-fix binds PER MEMBER (bug-class members; Improvement members pin the NEW contract); the cold review covers the run's whole diff.
- **Her rulings at the kickoff sitting (2026-11-08):** the three riders join ("VX-401, VX-45, VX-667"); VX-872 stays outside the wave — her words: *"I don't even think vx-872 is high priority. we don't need to do it."* (recorded on the ticket).
- **Coordinator protocol (nov7, in writing):** REQUEST (what/minutes/claim name, sent early) → READY (separate ping, able to start NOW) → GO (only from nov7, with the exact claim line; a FREE stage is never an invitation) → RELEASE + one result line naming EVERY failing test by name plus Executed counts. Headless `swift build`/`swift test` and `xcodebuild build`/`build-for-testing` never need the stage; **EVERY `xcodebuild test` does.** Windows over an hour: tests first, ping SEAM before any dev-store write.
- **Merge gate additions (nov7):** `Shared/SyncStatusViews.swift` compiles into VariorumMobile → **the phone suites ride the merge gate** beside the Mac whole target. VX-911/VX-901 touch the capability registry → **CapabilityRegistryTests + ShellChromeTests in the gate**, and nov7 is told when the registry change lands (trial-merging against vx-912).
- **Known false reds (name, never chase):** VX-850 (MCP socket timing under load, passes alone), VX-661 (swift-testing encoder SIGSEGV at exit), VX-855 (purge-sweep vs pool teardown SIGSEGV at teardown), the standing phone red `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`.
- **Dev store state (her word at nov5's close, relayed by nov7):** Settings ▸ MCP server is **ON** with `variorum-de` an approved client — KEEP it so; walk rows lean on it. Never press Resume Sync. Castle values only from `~/.variorum/dev-castle.env` if a walk meets the lock screen.

**Preflight read at kickoff:** CLAUDE.md + auto-loaded canon · the master plan (in-flight table; row added) · `notes/TICKETS.md` (fresh snapshot, pushed) · `notes/QUESTIONS.md` (the #264 bundle in full — the source of most members; open rows checked, none gates a member) · `notes/SessionResiliencyProtocol.md` · `notes/SurfaceContracts.md` IN FULL · `notes/MCPSpec.md` IN FULL (members touch Settings ▸ MCP, the shared icon, the sidebar AI section) · `notes/plans/open-source-readiness.md`. Not triggered: SyncSpec (no `Sync/` line), TEXTKIT2_NOTES (no editor seam), CastleRules (no protection sentence — VX-909 is the update-pause face, not an encryption/backup/words sentence).

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

## The batches (one acceptance unit each; a FRESH implementer per batch; briefs name THESE sections only)

### BATCH 1 — the MCP pane & the sidebar trail (VX-903 · VX-905 · VX-902 · VX-904 · rider VX-401)

All in Settings ▸ MCP and the sidebar AI section. **Required reading for the implementer: `notes/MCPSpec.md` IN FULL; SurfaceContracts "The app" (the AI-section bullet) and "Doors to the outside".**

- **VX-903 — the trail dial moves to the pane's top section.** Her ruling (#264 sitting, Nov 8): *"I also don't think it should be in activity, i think it should be right under 'when a client shows you something'. ticket that."* Move the three-state "Client activity in the sidebar" dial (local-only `mcp_switch` key `trail_dial`, VX-874) from Settings ▸ MCP ▸ Activity's own section to the pane's TOP section, directly under the show dial's row ("When a client shows you something"). **THE TRAP, recorded so it is solved rather than repeated:** the dial's FIRST seat in the top section broke VX-281's fresh-open geometry contract and was caught by the VX-878 whole-target gate — that is why it was exiled to Activity. The move back must keep the pane's fresh-open geometry GREEN: grow the contract deliberately or reshape the section — never silently. The Settings-search entry follows the move.
- **VX-905 — "Show ownership badges" moves to Settings ▸ MCP.** Her ruling: *"ticket moving 'show ownership badges' into the mcp part of settings - it makes more sense there."* Today: Settings ▸ Editor (`SettingsShape` pane `.editor`, title `OwnershipSettingsCopy.badgesTitle`). The switch governs the WHOLE badge family — the owned-by chips AND the AI marks (shared icon, Private eye; D-831's one-switch rule) — so the moved row's help sentence may want to say so (propose wording; sentence case; one line + (i) where the pane's idiom wants it). The settings-search entry follows the move.
- **VX-902 — the trail group heading drops "From ‹client-name›".** Her ruling: *"we should make it the provider's name like 'from claude' or 'from codex', if possible. or just mcp… I don't like the From random name."* Supersedes P-874-1's kept "From ‹client›" heading grammar. Mechanism: the door only knows the client's self-declared setup name (`clientInfo.name` — hers that night was "variorum-de"); **no provider brand rides the wire**, so "MCP" is the reliable form unless a TRUSTWORTHY provider mapping exists (the setup-tab names — Claude Code · Codex — are bound per-client via the per-setup key, `vmk2_<name>_…`; if the client's bound setup identity names a provider, that may be the honest source — investigate, don't guess). She half-recalls having ruled "mcp" for this heading once before — **re-check the VX-679/VX-874 records at fix time and cite it if found.** The row-level details (the shared-with-AI symbol's popover naming the client, when it came in, the act) are UNCHANGED — only the group heading. DESIGN FORK for the architect (the implementer proposes before building): when two clients both resolve to "MCP", do the two groups keep separate "MCP" headings (groups stay per-client underneath) or merge visually? Propose; the orchestrator rules; PROVISIONAL.
- **VX-904 — a whole client group can collapse.** Her word: *"asks floating within each client group - fine, maybe add ability to collapse a whole client group."* The ordering stands AS BUILT (asks float within their client's group, ask-holding groups lead, no cross-client interleaving). Add collapse on the group header (the sidebar's section idioms; session-scoped state like the section itself); dismissal, drag strata and the header right-click (Clear All + the dial's values) all keep working; a collapsed group's count stays honest on the header.
- **VX-401 (rider) — Activity stamps recompute.** `MCPActivityRowView` (MCPPane.swift ~:915) renders `MCPPane.relative(line.at)` once with no `TimelineView`, so "39 seconds ago" sticks. Fix per the ticket: the same `TimelineView(.periodic(from: .now, by: 30))` wrapper Waiting's row already uses — here, on the request first-seen (~:416) and client last-seen (~:604) stamps.

**Evidence:** the VX-281 fresh-open geometry pin green WITH the moved dial (the contract grown deliberately, the growth named in the batch record); Settings-search pins for both moved rows; a heading pin (approved client ⇒ "MCP"/provider form, never the raw client name); a collapse state test if the section has a test home, else the walk row; stamps-recompute covered by code shape (TimelineView present) + the walk.

#### BATCH 1 — LIVE STATUS (implementer: opus-implementer, session started 2026-11-08)

*Code + headless verification only (the brief: no GUI, no store, no `xcodebuild test` — Mac pins land PENDING(gate)).*

| Piece | Item | Status |
|---|---|---|
| 1 | VX-903 trail dial → top section (+ VX-281 geometry contract grown, named) | NOT-STARTED |
| 2 | VX-905 ownership-badges row → Settings ▸ MCP (+ search entry, help sentence proposed) | NOT-STARTED |
| 3 | VX-902 trail heading → provider / "MCP" (fork proposal to the orchestrator first) | NOT-STARTED |
| 4 | VX-904 whole client group collapses | NOT-STARTED |
| 5 | VX-401 Activity stamps recompute (TimelineView, two sites) | NOT-STARTED |

### BATCH 2 — the icon twins (VX-900)

**Required reading: `notes/MCPSpec.md` IN FULL (the shared-icon law); SurfaceContracts — the Private mark bullet and the shared-icon lines.**

- Her ruling (#264 sitting, Nov 8): *"it's weird for private and shared to go by different rules. I do think they should show, but maybe they should be a bit greyed out or something when the server is off (and hovering it could say the server is off). they should both be standardized though. and it's helpful to see what's shared / what's private BEFORE you flip the server to on."*
- **ONE rule for both marks:** drawn while a client is APPROVED (R-878-K3's gate, now for BOTH the Private eye and the shared icon), a dimmed/greyed state while the server is OFF, the hover carrying the server-off fact. This supersedes the shared icon's wait-for-the-server behavior on rows AND the masthead nuance recorded at #264 (the note masthead showing the eye but not the shared icon while the server is off). **Settled beside it, her word, same sitting: a BOOK's own masthead stays eyeless — the eye's HOSTS are unchanged.** The badge-family switch (`ownership_badges`) still governs all of it; D-831-3 accepted ("no badges is no badges").
- **The laws that must not move:** reach is read through the one rule (`decide`/`decideGathering`/`decideWing`) for the rows DRAWN, never the corpus (P1); **nothing is read while no client is approved** — the dimmed state exists only in the approved-client world; the via-book eye semantics (full strength, "Private — via ‹book›") unchanged; the menu's Private row keeps VX-641.
- **Evidence:** pins — (a) approved client + server OFF ⇒ both marks drawn dimmed, hover says the server is off; (b) no client approved ⇒ neither drawn, nothing read (the existing no-client read-fence pin extended, not weakened); (c) approved + server ON ⇒ today's behavior byte-unchanged. Dimming via tokens (no literal colour — the token-layer law).

### BATCH 3 — the book faces (VX-901 · VX-896 · VX-897 · riders VX-45 · VX-667)

**Required reading: SurfaceContracts "The Bookcase and books" in full.**

- **VX-901 — the Index row's ⋯ carries the note-title menu's set.** Her ruling: *"the index ... line should get the same options."* Extend D-802-1's note-title menu set (note-own doors: the note-row vocabulary minus list-local acts — Open Beside · Open in New Window · Star/Unstar · Rename… · Move to Wing ▸ / Copy to Wing ▸ while another wing exists · Export Note… · Archive · Delete Note… set apart — beside Move to Chapter ▸, Pin to Top/Unpin, then Remove from This Book / Release) to the book Index face's ⋯ row, which VX-878 left unchanged as a recorded residual. **DERIVED from the one registry table (the VX-829 two-faces precedent; P-1) — never a drift-copy.** The Index's existing local acts stay. The OTHER D-802-1 residual stands as built at her word: a gathering's note titles keep note-own doors with NO "remove #tag" (*her reasoning matched the build's: "which tag?"*).
- **VX-896 — the masthead one-line threshold.** Her ruling (Nov 7 walkthrough), superseding R-878-K4's kept-strict threshold at exactly the door the VX-878 handoff left open: *"it should go on the row above as soon as it would have standard spacing that the others have, it's weird it needs such a wide gap to go up."* The mode row joins the title row as soon as it fits WITH STANDARD SPACING; the wrapped (two-row) masthead stays the narrow state; ONLY the threshold moves. The law stands: a width-class decision at WHOLE points from STABLE widths, never ViewThatFits. Update the D-887-family pins to the new threshold.
- **VX-897 — the delete-confirm em-dashes become commas, both lines.** RULED (her chat, Nov 7): `BookStateDoors.deleteOwnedBook` (App/Variorum/Variorum/Features/Readings/BookStateDoors.swift:393) — *"…the book goes to the Trash for 30 days, and Put back returns whatever went in together, together."* (comma replaces the em-dash; the N stays dynamic). The sibling `keptLine` (~:436, the archive confirm, "…with no countdown — and Unarchive brings back…") follows: its em-dash becomes a comma too. Both lines, one fix; update any word pins.
- **VX-45 (rider) — the copy family.** The book-only delete receipt over-says for archived members; the archived gathering's empty state wants its own words; the "(M archived)" refinement. The row's detail: `notes/KnownIssuesArchive-2026-10-06.md` row 102 — the implementer reads that row and proposes the words (public-copy rules; receipts' honest-counts idiom); the orchestrator rules; PROVISIONAL if latitude remains.
- **VX-667 (rider) — the popover kind-words.** A note in one book and one gathering shows the header popover "This note is in 2 books — open one at this note:" while the header line itself says "in ‹book› · 1 gathering" correctly (VX-611's kind-word family, one surface over). Fix the popover to speak kinds honestly (counts split or the family's ruled phrasing — follow VX-611's precedent). Text-only.

**Evidence:** the registry-walk test covers the Index ⋯ derivation; masthead threshold pins updated and green (the D-887 family); word pins for 897/667/45; the walk rows.

### BATCH 4 — the shell singles (VX-911 · VX-870 · VX-898 · VX-909)

**Required reading: SurfaceContracts "The app" (keyboard family, quick entry, the wing switcher) and "The note" (History & lineage); the VX-833 contract line; `App/Variorum/VariorumTests/SyncOutOfDateFaceTests.swift`.**

- **VX-911 — the quick-entry band files without opening.** Her ask (Nov 8): *"it would be nice to have a button + an enter chord … that lets you file a quicknote without entering into the quicknote — sometimes i want to write a bunch and file them in succession from that main page."* Today the Bookcase band's ⏎ opens the minted note. Build: a file-without-opening act on the band — a visible button plus the chord — clearing the band for the next note, with a quiet receipt naming where it landed. **Chord: ⌘⏎** (the ticket's recommendation — already the quicknote MINI-WINDOW's own file chord, `QuickNoteView.swift:357`, "one act, three doors", so the gesture stays one thing everywhere; she floated ⌥⌘⏎ as the alternative) — **check both against the capability registry first**; a conflict flips to ⌥⌘⏎ with the reason recorded. ⏎-opens and ⇧⏎-paragraph untouched. The act is DECLARED in the capability registry (P-1). The capture box's own undo and the filing-ends-it rule (QUESTIONS #222), the microsyntax, and the caret law (VX-332) all keep working.
- **VX-870 — the Library masthead's cycling word switches wings in place.** Her word (Nov 5, the VX-828 bundle sitting, Q-B2): *"it would be nice if clicking it in library didn't move you either (a followup ticket could be minted for that)."* A DELIBERATE carve-out from VX-833's one road: the Library masthead's cycle keeps her in the Library (the wing switching under her, the Library re-scoping); the Bookcase cycle stays as is (in place already); every OTHER deliberate switch (⌘L, the ▾ list, ⌘1–⌘9) still lands in the wing's Bookcase. The eventual opens-on preference is VX-834 — out of scope. Update the VX-833 pins for the carve-out; the record pointer is `notes/plans/fixes/vx-828-editor-shell-qol.md` (Q-B2).
- **VX-898 — the History & Lineage header naming on a lineage member.** Her note (Nov 7 walkthrough, the edge-case flag she asked for): on the Lineage face viewing a historical (kept-as-lineage) block, the pane header reads "the take now / this take" — but the now-take is the post-merge SUCCESSOR's, and a released block's take doesn't always exist "now" at all. *"a bit of an edge case but should file a note for it."* Needs a naming honest on lineage members; on the whole she likes the surface. The implementer proposes 2–3 namings (the commit vocabulary; sentence case); the orchestrator picks the most spec-defensible; PROVISIONAL for her bundle. Keep the change tiny — the CommitsFaceModel split (VX-906) is unseated post-flip; do not restructure.
- **VX-909 — the older-build sync pause says the update fact twice.** Her find (Nov 8, a 1.2 build pre-update): the row title "Sync paused — this version of Variorum needs an update" stacks directly over "This version of Variorum is older than your account's sync format. Update Variorum to continue syncing — nothing is lost while sync is paused." — the same fact twice. ONE line carries the fact and the other earns its place (short title + explaining body, not two tellings). Home: `App/Variorum/Shared/SyncStatusViews.swift:362–367` (`appOutOfDateLabel` / the detail). Every user meets this face at every lockstep bump. **The file compiles into VariorumMobile — check the phone's use of the same face and keep both platforms coherent; the phone suites ride the gate.** Propose the pair (public-copy rules; the "nothing is lost" reassurance must survive somewhere); PROVISIONAL for her bundle; update `SyncOutOfDateFaceTests`.

**Evidence:** registry-walk + a chord test for VX-911 (and the receipt); a pin that the Library masthead cycle keeps the Library and switches the wing (and that ⌘L/▾/⌘1–⌘9 still land in the Bookcase); `SyncOutOfDateFaceTests` updated; the lineage-header wording pinned where the face has pins; the walk rows.

## Order, gates, the ladder

1. Batches run 1 → 2 → 3 → 4, one FRESH `opus-implementer` each, strictly sequential. Headless `swift build` + any core-level suites freely; **targeted Mac-suite runs per batch go through nov7** (REQUEST early; `-only-testing` takes TYPE names as a zsh array; "Executed 0" is no verdict). Batch 2 may fold into batch 1's gate window if timing suits.
2. **The ladder after batch 4:** one ladder over the run's WHOLE diff; `opus-reviewer`, fresh per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing; findings land in `notes/plans/fixes/vx-914-ladder-round1.md` (repo-first) before any fix session sees them; round 2 re-reviews the fixes; hard cap three; same-model, so the orchestrator arbitrates against the spec.
3. **The merge gate (nov7's additions included):** the Mac suites covering every changed SOURCE file (not only changed test files) — Settings/MCP pane suites, the masthead/D-887 family, CapabilityRegistryTests, ShellChromeTests, SyncOutOfDateFaceTests, the registry walk — plus **the phone suites** (the standing caret red named, not chased) on the final tree; the screenshot walk (below); then closeout.
4. **The walk (one stage window near close):** Settings ▸ MCP (both dials seated together, badges row, fresh-open geometry), the sidebar AI section (heading, collapse) against the dev store's live `variorum-de` client, the icon twins' dimmed state (server flipped OFF for the shot, back ON after — the resting posture is ON, her word), the book masthead join at the new threshold, the Index ⋯, the delete/archive confirms, the quick-entry button + ⌘⏎, the Library masthead cycle staying in the Library. Never press Resume Sync; dismiss a What's New sheet after every Debug launch.

## Canon deltas owed at closeout (the two-file rule; contract lines in place + pointers; narrative to AppSpecRecord)

- **SurfaceContracts, The app:** the AI-section bullet (heading form, collapse, the dial's home back beside the show dial); the quick-entry/keyboard-family line (⌘⏎ files without opening). **The Bookcase and books:** the mode-row/masthead line (the R-878-K4 "kept strict at her word" clause superseded by VX-896); the Index ⋯ line (VX-901); the Private-mark bullet + shared-icon sentences (VX-900's one rule + dimmed state). **The app, wing switcher line:** VX-870's carve-out from VX-833's "every deliberate switch" sentence.
- **MCPSpec:** the shared-icon law line (drawn while approved, dimmed while the server is off; nothing read while no client is approved — unchanged); the AI-section/trail lines (dial home, heading).
- **AppSpec §12:** the sidebar/AI-section summary sentence and the keyboard family line, where touched.
- QUESTIONS: the run's PROVISIONAL bundle, filed at the merge moment.

## Environment traps (every batch brief carries this section verbatim)

- Instance checks: `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the strict forms); treat real-store instances by STORE, never quit/kill one; no Release builds or /Applications refreshes while one lives (the refresh decision is nov7's, folded at the wave's end).
- NEVER add a custom build configuration (anything not named exactly "Debug" builds the SPM packages Release and strips the DEBUG oracles). Mac tests from `App/Variorum/`, suite-level `-only-testing` with TYPE names as a zsh array; confirm the "Test run with N tests" line; Swift Testing's N counts skipped tests — read the `skipped:` lines. zsh `pipestatus`.
- EVERY `xcodebuild test` (Mac or simulator) needs a HELD stage claim through nov7 (REQUEST → READY → GO → RELEASE with every failing test NAMED). Headless `swift build`/`swift test`/`build-for-testing` never do. App suites flash the test host's windows — zero-instance windows for timing-sensitive measurements.
- The worktree is `~/dev/variorum-vx-914`; all work and every command runs there by absolute path; `notes/TICKETS.md` is READ from `~/dev/variorum/notes/TICKETS.md` (main's copy), never regenerated here.
- Commit per coherent piece, push after EVERY commit (no attribution trailers — her rule overrides the harness reminder, PR descriptions bare too); LIVE STATUS in this file from the first commit; synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops — `tail -f | grep -m1` hangs after the line lands); never `git checkout` over uncommitted work; commit before any behavioral revert.
- Implementers: never spawn subagents; never run `git add -A` (pathspec-limited adds only); screenshots in gitignored dirs; the dev store's content is the agents' to manage, but the MCP server stays ON with `variorum-de` approved, Resume Sync is never pressed, and Castle values come only from `~/.variorum/dev-castle.env`.
- Known false reds: VX-850 · VX-661 · VX-855 · the standing phone caret red (name them in result lines, never chase).

## LIVE LEDGER (flip rows in the same commit as the work)

| # | Item | Batch | Status |
|---|---|---|---|
| 1 | VX-903 trail dial moves to the top section | 1 | NOT-STARTED |
| 2 | VX-905 ownership badges row moves to Settings ▸ MCP | 1 | NOT-STARTED |
| 3 | VX-902 trail heading → provider/MCP | 1 | NOT-STARTED |
| 4 | VX-904 client group collapse | 1 | NOT-STARTED |
| 5 | VX-401 Activity stamps recompute (rider) | 1 | NOT-STARTED |
| 6 | VX-900 the icon twins' one rule + dimmed state | 2 | NOT-STARTED |
| 7 | VX-901 Index ⋯ carries the note-title set | 3 | NOT-STARTED |
| 8 | VX-896 masthead one-line threshold | 3 | NOT-STARTED |
| 9 | VX-897 delete/archive confirm em-dashes → commas | 3 | NOT-STARTED |
| 10 | VX-45 copy family (rider) | 3 | NOT-STARTED |
| 11 | VX-667 popover kind-words (rider) | 3 | NOT-STARTED |
| 12 | VX-911 quick-entry files without opening | 4 | NOT-STARTED |
| 13 | VX-870 Library masthead cycles in place | 4 | NOT-STARTED |
| 14 | VX-898 lineage header naming | 4 | NOT-STARTED |
| 15 | VX-909 sync-pause face says it once | 4 | NOT-STARTED |

## PROVISIONALs (filed to QUESTIONS at the merge moment)

*(none yet)*

## Sitting records

**2026-11-08 kickoff sitting (her words verbatim):** riders — *"VX-401, VX-45, VX-667"* (all three seated); VX-872 — *"I don't even think vx-872 is high priority. we don't need to do it."* (left outside the wave; comment on the ticket). The composition double-check she asked for is recorded in the kickoff section above and was reported in chat: the roster is complete against the sitting record, nothing mis-seated, VX-909 verified app-side, the wave's severity-heavy work correctly lives in 913/849/912.
