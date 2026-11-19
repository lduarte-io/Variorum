# VX-980 — Umbrella: search fixes & small improvements (the run record)

**STATUS: OPEN (kicked off 2026-11-19, overnight). Orchestrator session `vx-980`; `/run-phase`; stage coordinator this window: `nov18`.**
Ticket: VX-980 · Project-less umbrella (the sub-issues are the roster) · Branch: `vx-980-search-fixes` · Worktree: `~/dev/variorum-vx-980` (the Pro) · PR at close: `VX-980: …`, merge commit only.

## FOR A LATER READER

*PENDING — written at closeout from the settled facts (the mechanisms as settled, the fixes as built with one pointer each, her rulings by id, the evidence lines that matter, the open items). Until then the sections below are the plan and the working record.*

---

## Kickoff (2026-11-19)

**Her words tonight, verbatim:** "i want to get everything set up for an overnight session" · "the whole issue is that i need to use my weekly limit up before tomorrow" · "i want one claude coordinator named nov18, then i want all the VM in the first wave launched with instructions to talk to stage coordinator nov18, i want the vx-981 and vx-980 added too. and add the high priority (private eye not shown on journal) to one of those runs - maybe the MCP run, since it deals with the private mark."

**The mandate as this run reads it.** An overnight run without her at the keyboard: an ask that needs her hands or her call is HELD and bundled for her next sitting while everything that does not depend on it continues. Nothing she owns is decided for her — every product choice the spec does not settle is built at its most spec-defensible option, marked PROVISIONAL, and listed in the ratify bundle (the P-980 family below, QUESTIONS at the merge moment).

**Members — the SUB-ISSUE roster, listed through Linear at kickoff (the VX-548 rule; the description agrees with it this time):**

| Member | Kind · Evidence · Priority | What |
|---|---|---|
| **VX-955** | Bug · Confirmed · Medium | A symbol word beside real words empties the whole answer — `red +` finds nothing while `red` finds the note. |
| **VX-954** | Bug · Confirmed · Low | A dash beside a tag answers less than the tag alone — `— #tag` counts only the books while `#tag` counts books, notes and blocks. |
| **VX-79** | Feature · Medium | The search index's rebuild and check doors have no face — a Settings ▸ Data Safety row (and the post-restore question). |
| **VX-93** | Feature · Low | Search the Trash — a search INSIDE the Trash, never the Trash in the main search. |

**Riders (CLAUDE.md's rule — the open Low and Medium tickets in the Search area, checked at kickoff):** VX-987 (a wing-blind search) says on its own face that it needs her design sitting; VX-73 (the power-search grammar) is a design-sized feature. Neither is runnable as-is, so none is offered; both stay where they are.

**Cast.** `opus-implementer` (xhigh), a FRESH one per batch, one at a time. The ladder's cold reviewer runs `notes/REVIEW_PROMPT.md` verbatim with zero framing: `fable-reviewer` by CLAUDE.md's standing default; `opus-reviewer` is eligible for this diff class (no `Sync/`, no custody, no editor seam — the VX-819 precedent on the same code) and is the fallback if the Fable budget is short at the ladder. Decided from the actual diff at the ladder and recorded there. Pin-before-fix binds PER MEMBER (the two bugs red-on-old, verified by revert; the two features pin their NEW contract); the cold review covers the run's whole diff.

**Surfaces (declared; the in-flight row on main at `1d84b85a4`).** `Sources/VariorumCore/Domain/SearchComposer.swift` and the search reads under `Queries/` (`SearchQueries.swift`, `TagListingQueries.swift`, `Trash.swift`); the Mac's Library search model and the ⌘K and book-band guards; Settings ▸ Data Safety (one row); the Trash surface (`Features/Library/RecoveryView.swift`). **No `Sync/`, no custody, no editor seam, no schema, no MCP tool change.** The wire's `search` reads through the same composer (`Sources/VariorumMCP/MCPReadTools.swift`), so batch 1's core fix changes what it answers — for the better, with no schema or description change planned; batch 1 states the wire consequence in its record.

**THE FENCE (binding on every batch).** Any line that would land under `Sources/VariorumCore/Sync/`, `Sources/VariorumCore/Protection/`, `App/Variorum/Shared/Protection/`, custody or keychain code, the copy doors' landing acts in `App/Variorum/Shared/AppBootstrap.swift` (`makeThisMyLibrary…`, the Open Library road), the editor seam (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the read tier), or `Sources/VariorumMCP/` product code STOPS the batch back to the orchestrator before it is written. vm-64 holds this window's one `Sync/`-or-custody slot; this run never asks for it.

**Overlap (the in-flight table, read at kickoff).** vm-64 lists `Queries/LibraryPaging.swift` (it calls `SearchComposer.listingNarrowing`; this run changes the callee's guard, not that file) · vm-78 has the PHONE's Trash face (this run's is the Mac's, plus possibly `Queries/Trash.swift`) · vx-981 owns `Sources/VariorumMCP/` · vm-55 hoists the Mac's wing brains to `Shared/`. `SettingsShape.swift` is the likely shared file if VX-79's row joins the Settings search. Closeouts serialize through nov18; the second merger of a pair merges main IN (never a rebase) and re-proves the named files on the merged tree.

**Coordinator protocol (nov18).** REQUEST (what · about how long · claim name, sent early) → READY (a separate ping, able to start now, carrying the exact `-only-testing` TYPE list) → GO (only from nov18, with the claim line; a FREE stage is never an invitation) → RELEASE with one result line naming EVERY failing test by name plus the Executed counts. EVERY `xcodebuild test`, simulator boot, walk, Debug launch or device install needs the GO. Headless `swift build` / `swift test` on the core package and `xcodebuild build` / `build-for-testing` never need the stage — but no HEAVY headless run (the whole core package, a cold build-for-testing) while another session's stage window is live: small targeted runs only, heavy ones in the gaps.

**Preflight read at kickoff (none delegated):** CLAUDE.md and its auto-loaded canon (CoreDescription, OverallModel, AppSpec) · the master plan's in-flight table and latest closeout · `notes/plans/workflow-transition-2026-10-06.md` · `notes/TICKETS.md` (the 03:02 snapshot) · `notes/QUESTIONS.md` (the header and the search-bearing bundles — #201, #265 closed at VX-894, #273 closed at VX-973; no open row gates a member) · `notes/SessionResiliencyProtocol.md` · `notes/SurfaceContracts.md` IN FULL · `notes/SyncSpec.md` IN FULL (as the arbiter of the post-restore question; no `Sync/` line is planned) · `notes/MCPSpec.md` IN FULL (the wire's `search` reads the composer) · `notes/REVIEW_PROMPT.md` · the member records: `vx-915-recents-sweep.md` (FOR A LATER READER + BATCH 5 whole — N-888-1/-2 are VX-954/955), `vx-819-search.md` (FOR A LATER READER), `phase-13o-search.md` (R-13o-3/-4, U1's rebuild door, the ladder's MINOR-3), `vx-83-search-followup.md` (the Trash split). Not triggered: CastleRules and TEXTKIT2_NOTES (the fence above keeps the run out of both seams; a batch that would reach either stops).

---

## ENVIRONMENT & TRAPS (every batch brief carries this section verbatim)

- Work ONLY in `~/dev/variorum-vx-980` (absolute paths in every command). Never commit from the main checkout; never push `main`.
- `notes/SessionResiliencyProtocol.md` binds: commit per coherent piece and push after every commit; write this batch's LIVE STATUS from the FIRST commit and flip it in the same commit as each piece; every unverified claim is marked PENDING; synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops — `tail -f | grep -m1` hangs after the line has landed); commit before any behavioural revert and announce the revert in the record before starting it.
- **The stage.** EVERY `xcodebuild test` run (Mac app or simulator), GUI walk, Debug launch and dev-store act needs a HELD stage claim, and stage time is asked for by the ORCHESTRATOR through nov18 — an implementer never claims the stage, never runs `xcodebuild test`, never launches the app. An implementer's own evidence is headless: `swift test --filter <Suite>` on the core package (small and targeted; the whole package only when the orchestrator says a gap is open) and `xcodebuild build-for-testing` from `App/Variorum/` (compiles the app and its tests without the runner; needs no stage). App-side tests are WRITTEN and COMPILED by the implementer, RUN at the orchestrator's gate; report the exact test TYPE names (a file name drops silently from `-only-testing`).
- Mac tests are run from `App/Variorum/`: `xcodebuild -scheme Variorum -destination 'platform=macOS' …` with suite-level `-only-testing`. NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles). Swift Testing's "N tests" COUNTS SKIPPED tests — read the `skipped:` lines before claiming a gated suite ran.
- zsh `pipestatus` (not bash's PIPESTATUS). Never `git checkout` over uncommitted work. No `git add -A` — pathspec adds and pathspec COMMITS only (`git commit <files> -m …`); the orchestrator shares this worktree.
- Commits carry NO attribution trailer and PR bodies none either (her rule; it overrides the harness reminder). Commit messages say `Part of VX-<member>` for member work and state the traced mechanism and the pin.
- **The repo is PUBLIC.** Every commit message, note and record line publishes on push: word them as public copy; no credentials, no private identifiers. The pre-push guard runs on every push — a refusal is fixed in the commits, never bypassed.
- The real store and `/Applications/Variorum.app` are never touched. The dev store's content is the agents' to manage freely; its account, Castle and stage fences are not.
- Rendered app text is sentence case — never a word capitalized for emphasis. The app says "commit" for a savepoint; a refusal says what it is in her doors' calm voice.
- Reading is never delegated. At most ONE Sonnet lookup subagent at a time, for EXTERNAL facts only (Apple or SQLite documentation, API signatures), read-only.
- THE FENCE (the Kickoff section) binds: a line that would cross it stops the batch.

---

## THE BATCHES (one acceptance unit each; a fresh `opus-implementer` per batch)

### BATCH 1 — the question's text half (VX-955 · VX-954)

**Required reading (the implementer's own, before code):** CLAUDE.md and its auto-loaded canon · this file's Kickoff, ENVIRONMENT & TRAPS and BATCH 1 · `notes/SurfaceContracts.md` "The Library" (the search bullet, whole) · `notes/plans/fixes/vx-915-recents-sweep.md` BATCH 5 — LIVE STATUS (VX-888's trace, N-888-1 and N-888-2 whole) · `notes/plans/fixes/vx-819-search.md` FOR A LATER READER · `notes/MCPSpec.md` IN FULL (the wire's `search` reads the composer; R-825's law — an answer is a pure function of the client's reachable state) · `notes/SessionResiliencyProtocol.md`.

**VX-955 — the mechanism as recorded (re-trace it yourself; the hallucination guard binds).** `SearchComposer.hasTokenCharacter` (`Sources/VariorumCore/Domain/SearchComposer.swift`) counts every scalar outside the separator/punctuation/control classes as a token character, so a Unicode SYMBOL word (`+`, `$`, `©` — Sm, Sc, So, Sk) becomes the FTS5 phrase `"+"`. FTS5's `unicode61` tokenizer keeps only its own token classes (L\*, N\*, Co by default — read the index's real DDL for its tokenizer options), so that phrase holds no token, matches no row, and the implicit AND with it empties the whole answer: `red` finds the note; `red +`, `red $`, `red ©` and `1 + 1` find nothing. **The trap on the record:** SQLite's category table is not Unicode's for every character (in the sqlite3 3.54 CLI, U+1F642 tokenizes and U+1F600 does not; `½` and `²` tokenize as numbers). **The contract to build:** a word is asked of the index exactly when the INDEX would find a token in it — the predicate follows the index's own tokenizer, the one linked into the app (SQLCipher's FTS5), never Unicode's general categories alone. How it follows is yours to choose and justify (a ported category table, or another exact road), with ONE hard requirement: a pin that compares the predicate against the app's own FTS5 tokenizer over a sweep wide enough to catch drift (every scalar if the cost allows; otherwise every assigned BMP scalar plus astral samples including the recorded pair), so a future SQLCipher bump that moves the table turns the pin red instead of silently emptying answers. P1: the predicate stays pure Swift over the parsed words — no read is added to a question.
- **Pins (red-on-old, verified by revert):** `red +` · `red $` · `red ©` · `1 + 1` each find what the words without the symbol find (the note, and the band's counts agree with the listing); a symbol-only word beside a tag behaves as batch 1's other half rules. Controls that must stay green on both sides: `red —` (already fine), a quoted phrase holding a symbol inside real words (`"a + b"`), a prefix query, negation (`-word` still refuses when only negations remain), `½` and other number-class characters still found.

**VX-954 — the mechanism as recorded (re-trace it).** `— #flora`: the parser reads the dash as a bare word, so `query.text != nil`; `ftsMatch` returns nil for it; `SearchComposer.listingNarrowing` is guarded `query.text == nil`, so the tag-alone narrowing never runs and the tagged notes and blocks vanish from BOTH the band and the sheet (`#flora` alone answers "1 book · 2 notes · 1 block"; `— #flora` answers "1 book"). **The fix shape on the record:** a word list that FOLDS TO NOTHING takes the no-words branch — ONE pure core predicate ("the text half has something the index can serve": `ftsMatch` non-nil, with `negativeOnlyText` counted as servable so it keeps refusing) read by `listingNarrowing`'s guard, `searchCounts(…facet:…)`'s arm, `searchTagOffers`' guard, and the app's `hasWords` (`LibrarySearchModel` — the Library, the book's band, ⌘K's guard), so `— #tag` IS `#tag` everywhere. After VX-955 a symbol-only word (`+ #flora`) folds to nothing too and takes the same road — the two fixes must agree; say in the record how each of VX-888's six shapes reads after both.
- **Pins (red-on-old, verified by revert):** `— #flora` answers exactly what `#flora` answers — the band under All and under every facet, the narrowed listing, the tag offers — and the same for `#flora —`, `"—" #flora`, `… #flora`, `- #flora` and `+ #flora`; the existing guard pin `SearchPunctuationOnlyTests` must be read first — its oracle compares the band with what the Library shows, so it should stay green while its SHOWN side changes; if a case of it must change, say exactly why in the record. App-side: `hasWords` (and whatever routes on it) reads the one core predicate — pinned in the app tests, written and compiled here, run at the gate.
- **The wire.** Trace what the MCP `search` tool answers for `red +` and for `— #tag` before and after, and state it in the record. No `Sources/VariorumMCP/` product line changes (the fence); if the wire's own guard (`query.isEmpty`) wants the predicate, STOP and report — that is a line in vx-981's surface.

**PROVISIONAL P-980-1 — the one edge that is hers (VX-954's own words: "One edge needs her call").** A field holding ONLY punctuation or symbols (`—`, a lone `#`, `+`) asks nothing the index can serve and names no tag. Options: **(a) the face keeps today's reading** — the field is not blank, nothing is found, and the Library says what it says today for such a field ("nothing found" over "Nothing matches") — BUILT; **(b)** the field reads as blank and the Library stays at rest, as if nothing were typed; **(c)** a sentence of its own saying the field holds nothing to search for. (a) is built because it changes nothing she sees today; the predicate must therefore not blank a tagless punctuation-only field. Pin (a) so a later change is deliberate.

**Evidence the batch owes:** every pin above with its red-on-old run NAMED (the revert announced in the record first, per the protocol) · the tokenizer sweep pin's numbers · `swift test --filter` over the search suites green with counts and the skipped lines read · `xcodebuild build-for-testing` green · the exact app test TYPE names for the gate · a self-assessment.

#### BATCH 1 — LIVE STATUS

*The implementer writes this from its first commit.*

### BATCH 2 — the index's doors get their face (VX-79)

**Required reading:** CLAUDE.md and canon · this file's Kickoff, ENVIRONMENT & TRAPS and BATCH 2 · `notes/SurfaceContracts.md` "The app" (messages carry a kind; Settings has nine searchable panes) and "Doors to the outside" (the portability and protection bullets — to know the restore-shaped roads, never to edit them) · `notes/plans/phase-13o-search.md`: R-13o-3 and R-13o-4 in THE SITTING RECORD, U1's item 3 and the U1 RECORD's P5 row, LADDER ROUND 1's MINOR-3 and its disposition · `Sources/VariorumCore/Operations/Operations+SearchIndex.swift` and `Persistence/SearchIndex.swift` · the Data Safety pane as it stands (`App/Variorum/Variorum/Features/Settings/DataSafetyPane.swift`, `DataSafetyModel.swift`, `DataSafetyCopy.swift`, `SettingsShape.swift`) · `notes/SessionResiliencyProtocol.md`.

**The unit.** `Operations.rebuildSearchIndex()` and `verifySearchIndex()` exist and are pinned, with zero production callers. Her ruling R-13o-3 named "an explicit rebuild door"; this batch builds its FACE: a row in Settings ▸ Data Safety with two doors — check the index, rebuild the index — and honest receipts.

**The contract.**
- A section of its own in Settings ▸ Data Safety (placement: after the copies and restore matter, before the log — PROVISIONAL P-980-2), one line saying what the index is in her terms (search reads a local index built from her notes; nothing of hers lives only in it), and the two doors. Check writes nothing and says what it found: healthy in one calm sentence, or out of step with the honest numbers `SearchIndexIntegrity` carries and the road ("Rebuild it to fix that"). Rebuild re-derives the index from her notes, then says the state it leaves — what `rebuildSearchIndex()` returns, never a bare "done". A failure says the system's reason as a refusal.
- Both run off the main thread (P2). While one runs the row says so and both doors wait; a second press is no second flight. The pane's standing-state rule holds: where the pane draws nothing actionable today (no library open, a locked library), the row follows the pane's own precedent — read how the other sections behave and match it.
- The words are PROVISIONAL (P-980-2): draft them in the pane's existing voice, sentence case, no jargon she has not been taught ("search index" is the one new term; say what it is in the row's one line), and LIST every rendered string in the record for her wording pass. The row joins the Settings search (the pane's searchable-rows table) so "search" and "index" find it.
- P-1 (one capability registry): read how the Data Safety pane's existing doors are declared and follow that precedent exactly — declared once if this pane's doors are registry acts, plain pane buttons if the pane's doors are. Say which in the record.
- No ⌘K command, no menu item, no automatic run at launch (P1: the check is ∝ the corpus — a deliberate act only).

**The post-restore question — TRACE, do not build (PROVISIONAL P-980-3).** The ticket's title carries "a post-restore check"; its body says "and/or an automatic integrity check at restore-shaped moments". No mechanism is on the record by which a restore leaves the index out of step, and the hallucination guard forbids building a net for an untraced fall. So this batch TRACES each restore-shaped road and records, per road, how the index arrives and whether it can arrive out of step: Make this my library (a backup pair, a Previous Library, the empty-slot landing) · a plaintext export brought in at Open Library (the export KEEPS the derived tables — how does the new library's index come to be?) · an export from an earlier build (migrations a subset of this build's) · a first sync round into a fresh library (the capture triggers fire during remote apply) · Send Library to Another Mac → Open Library on the other side. Reading those roads is allowed everywhere; EDITING them is fenced. Where a road is reachable headless without touching fenced code, add a GUARD PIN (the road runs, then `verifySearchIndex().isHealthy`) — tests only. Report the table. If a road CAN leave the index unhealthy, that is a finding with its mechanism: STOP and report to the orchestrator — the automatic check is then her call with evidence, a ticket, never a line in a fenced file tonight. Options for the record: **(a) the explicit row only, plus the trace and the guard pins — BUILT;** (b) an automatic check after a library lands, healing by rebuild with a quiet receipt; (c) a check at every open (rejected on its face — P1).

**Evidence the batch owes:** the pane's model tests (check healthy · check unhealthy with the numbers · rebuild heals · a failure speaks · one flight per press · the standing-state rule) written and compiled, TYPE names reported · any core guard pins green headless · the Settings-search pin · `build-for-testing` green · the rendered strings listed · the restore-roads table · a self-assessment. The walk (the row pressed in the dev store's Debug app, both receipts read) is the orchestrator's at the gate.

#### BATCH 2 — LIVE STATUS

*The implementer writes this from its first commit.*

### BATCH 3 — a search inside the Trash (VX-93)

**Required reading:** CLAUDE.md and canon · this file's Kickoff, ENVIRONMENT & TRAPS and BATCH 3 · `notes/SurfaceContracts.md` "The Bookcase and books" — the Delete bullet's Trash sentences (the listing never claims emptiness before its first value; multi-select and the bulk row; Delete N empty blocks…; the messages' own band) and "The Library" (the search bullet — the sameness rule and the finder's voice) · `notes/plans/fixes/vx-83-search-followup.md` (the lines recording the Trash split and her words) · `Sources/VariorumCore/Queries/Trash.swift` whole · `App/Variorum/Variorum/Features/Library/RecoveryView.swift` whole (the view model, `TrashGrouping`, the kind filter chip, the empty-vs-filtered sentence, `showsEmptyTrashDoor`'s whole-Trash rule, the selection's prune-to-visible) · `notes/SessionResiliencyProtocol.md`.

**Her words (2026-10-07, the VX-83 sitting, verbatim):** "searching stuff that *wasn't* saved and was purposefully deleted is a different issue. it might be better to just add a search to trash later than add trash to the main search."

**The unit.** A quiet search field ON the Trash surface that narrows the Trash's own listing to the rows matching the typed words. The main search is untouched: the Trash stays out of the finder, the index keeps dropping tombstoned docs, no visibility fact, no composer fence, no purge coordination.

**The contract (each line PROVISIONAL where marked — the spec is silent beyond her sentence; the built option is the most defensible one and the alternatives are recorded for her).**
- **What it searches (P-980-4).** What was deleted: a row matches when its name OR its deleted text holds the words — a note by its title and the text of the takes that went into the Trash with it (its cascade family, exact-stamp as Put back reads it); a block or a take by its text; a book or a gathering by its name; a snippet group by its name and its snippets' text; a preserved original by its text. Built: name-or-text. Alternative (b): only what the row already shows.
- **How words match (P-980-5).** Every typed word must be found (the finder's implicit AND), compared with case and accents folded (the finder's third sameness rule), as a contained run of characters — no index exists over the Trash, so there are no tokens to match; whitespace separates words; no `#tag`, facet, date or negation grammar (a `#` is a character like any other). Alternative (b): the finder's full grammar over the Trash.
- **What a match shows (P-980-6).** The row as the Trash lists it today, in today's grouping and order. A row matched only by text it does not show (a note found by its body) carries ONE quiet line under it with the matched passage, the words around the first match, in the row's muted small type — so she can see why it is listed. Alternative (b): rows only, no passage line.
- **The field (P-980-7).** In the Trash's own header beside the kind filter, composing with it (both narrow; neither resets the other); empty by default on every arrival; esc clears it; the listing answers as she types, debounced. With words typed and nothing matching, the surface says so in the filtered-empty sentence's idiom — never the Trash-is-empty sentence. The field is never a key-view stop that steals the opening caret (read VX-332's law in SurfaceContracts and the sidebar field's precedent in `Features/Library/SidebarSearchField.swift`); typing in it never moves the rows' own measure.
- **Everything else keeps its rule.** Empty Trash and Delete N empty blocks… stay whole-Trash doors (the kind filter's precedent: a door over the whole Trash never vanishes or narrows with a filter); the selection is pruned to the visible rows exactly as today; the per-wing scope, the 30-day window and the purge-intent fence are the listing's own and the search inherits them by narrowing the listing, never by a second listing rule; Put back, Delete Now and the bulk row act on the rows shown.
- **Cost (P1, P2).** The match is ∝ this wing's Trash — driven from the Trash's rows and their families through the existing indexes, never a scan of the living corpus; off the main thread; a superseded question's answer is dropped (the VX-408 question-token precedent in `LibraryCatalogModel.read`). State the plan shape in the record (EXPLAIN QUERY PLAN for any new statement, the driving table named) and pin it the way the search suites pin theirs.
- **Reads only.** No operation, no schema, no trigger, no new index, no setting. No registry act is expected (a filter field is not an act — say so if the trace argues otherwise).

**Evidence the batch owes:** core tests for the match read (a trashed note found by title and by body · a block · a take · a book · a snippet group · folding · every-word · the wing fence · the window · a purge-fenced row never listed · the plan shape) green headless with counts · view-model tests (narrowing composes with the kind filter · the filtered-empty sentence · whole-Trash doors unmoved · the selection pruned · a superseded answer dropped) written and compiled, TYPE names reported · `build-for-testing` green · every rendered string listed · a self-assessment. The walk (delete a note with a distinctive word, find it in the Trash by that word, Put it back from the narrowed listing) is the orchestrator's at the gate.

#### BATCH 3 — LIVE STATUS

*The implementer writes this from its first commit.*

---

## Review foci (written at plan time, before any implementation existed)

1. **The predicate follows the INDEX.** For VX-955, is "the index would find a token in this word" decided by the app's own linked FTS5 tokenizer's rule, and would a tokenizer-table change turn a pin red? Try characters the pins do not name.
2. **One predicate, every reader.** For VX-954, does every place that asks "does this question have words" read the ONE core predicate — `listingNarrowing`, the counts' facet arm, the tag offers, the app's `hasWords` and everything routed on it (the Library, the book's band, ⌘K) — or does a twin survive? Do the band and the sheet still agree for every shape in `SearchPunctuationOnlyTests`?
3. **Negation still refuses.** A question of only negations must refuse exactly as before; a punctuation word beside a negation must not turn a refusal into an answer or an answer into a refusal.
4. **The wire is unchanged in shape.** Does the MCP `search` answer stay a pure function of the client's reachable state (R-825), with no schema, description or refusal-sentence change?
5. **The index doors are honest and deliberate.** Does Check write nothing? Does Rebuild say the state it leaves rather than "done"? Is either reachable from any automatic path (launch, open, a timer)? Do both stay off the main thread, one flight per press?
6. **The Trash search never reaches the living corpus or the main search.** Is every new read driven from the Trash's own rows (plan shape), wing-fenced and window-fenced exactly as the listing is? Is the finder's index, composer or fence touched anywhere? Do the whole-Trash doors keep their whole-Trash rule under a typed search?
7. **The fence held.** Is there any line under `Sync/`, `Protection/`, custody or keychain code, the copy doors' landing acts, the editor seam, or `Sources/VariorumMCP/` product code?
8. **P1.** Does any question's cost now scale with the corpus where it did not before?

---

## THE GATES AND THE WALK

*PENDING — each stage window recorded here: the claim, the TYPE list, the Executed counts, every failing test by name, the walk's rows.*

## THE LADDER

*PENDING — round by round: the reviewer cast and why, the findings file, each finding's disposition.*

## CLOSEOUT

*PENDING — the canon deltas in the two-file shape, the ratify bundle (the P-980 family), the born tickets triaged, the mobile parity line, canon-size's line, the merge.*

## THE LEDGER (every row owned; updated as batches close)

| # | Row | State |
|---|---|---|
| 1 | Kickoff: worktree, branch, in-flight row (`1d84b85a4`), VX-980 In Progress, nov18 told | DONE |
| 2 | BATCH 1 — VX-955 · VX-954 | NOT STARTED |
| 3 | BATCH 2 — VX-79 | NOT STARTED |
| 4 | BATCH 3 — VX-93 | NOT STARTED |
| 5 | The gates and the walk (through nov18) | NOT STARTED |
| 6 | The ladder | NOT STARTED |
| 7 | Closeout: canon deltas, record, handoff, merge gate, PR, merge-moment ledgers, tickets, debris, worktree and branch removal | NOT STARTED |
