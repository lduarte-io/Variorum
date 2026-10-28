# VX-648 — Ladder round 1 (cold review: fable-reviewer, 2026-10-28)

**Reviewer:** Fable (fresh session, zero implementation context), running `notes/REVIEW_PROMPT.md`
VERBATIM over the whole run's diff (`git diff origin/main...HEAD` in `~/dev/variorum-vx-648`,
merge-base `896b8d1a0` — main merged in at the batch-3 seam; origin/main has not moved since).
No "Review foci" section exists in the run record or beside it (grepped). Canon read for the
touched seams: MCPSpec IN FULL · SyncSpec IN FULL (the run mints migration v1_34) ·
SurfaceContracts in full · TEXTKIT2_NOTES §3–4 · AppSpec/OverallModel/CoreDescription (loaded) ·
QUESTIONS #245/#246 · the master plan's in-flight table · the run record
`notes/plans/fixes/vx-648-launch-week.md` in full. Code and diff read directly, 110 files;
targeted headless verification run by this reviewer (see the clean bill).

**Verdict: NO BLOCKER, NO MAJOR in the run's own diff.** Findings below are MINOR/NIT.
Every bug-class member's red-on-old is recorded with a traced mechanism and the pins exist as
claimed; the suites I could run headless I ran, green, with the record's exact printed numbers.

---

## Findings (severity-ranked)

**[MINOR] · notes/DetailedPlanForPhases.md:16 (the in-flight table) · the run's row still
declares "no `Sync/`, no custody, no schema" while the run minted migration
`v1_34_placement_by_block` (`Sources/VariorumCore/Persistence/Migrations.swift:1074`).**
Evidence: the row text vs the diff; the in-flight table is the parallel-session coordination
instrument and VX-440 is live in parallel — a session consulting the table would mis-read the
run's schema footprint (the coordinator's v1_34 reservation lives only in the run record and
coordinator memory). No concrete wrong outcome remains reachable (the number is reserved, the
id froze at walk 1 per A-648-4), so this is a ledger correction, not a bug. Fix: amend the row's
surfaces clause ("one local-only migration, v1_34 — no synced schema") when the merging session
touches the table at closeout; the row retires then anyway. No pin (doc-only).

**[NIT] · App/Variorum/Variorum/Features/BookView/BookView.swift:3066 + BookNavigatorFollow.swift:193
· the highlighted note row reports the LABEL's frame (~16 pt) while the row's hit target is
~24 pt, and the conditional `NavigatorFollowReport` flips the label's view identity when the
highlight moves.** Evidence: `NavigatorFollowReport` is applied to `NavigatorNoteLabel`'s HStack,
inside the row's padding; `reveal(top:height:viewport:)` therefore judges "wholly in view" on the
label, so up to ~4 pt of row padding can sit clipped without a reveal; the `if active` branch
re-builds the label subtree when `active` flips (two labels per step). Both implementer-flagged
(batch 4 self-assessment (4)). Cosmetic: the reveal's `scrollTo` targets the whole row id, and a
half-point-to-4-pt shortfall is below the row gap. No red-on-old pin could distinguish it from
design tolerance — recorded, not to fix. (If it ever reads clipped live, the fix shape is to
report from the row container rather than the label.)

**[NIT] · App/Variorum/Variorum/Features/BookView/BookViewModel.swift:1385 (navigatorViewedPair,
the `.pages` arm) · Read ▸ Pages' navigator mark trusts `pagedAnchorPostID` as last reported, so
a stale pre-adopt report marks the stale note for a beat on arrival.** Evidence: the pair is
derived from the reader's report with no membership re-check at the label (the stale-report guard
lives only in `BookNoteStep.viewedNote`, which checks the order); the underlying arrival defect —
a fresh `PagedReadView` seeds its reader before `adopt` hands it entries, so every Pages arrival
opens at the book's first page — is pre-existing (13f W21, `67ee0ff36`), was found and ticketed
by this run (**VX-663**, Medium, Confirmed; seen live as walk 2's O-4). Disposition: agree with
the ticketing; not this diff's to fix — the mark follows the reader's next report within a beat.

**[NIT, SPECULATIVE] · App/Variorum/Variorum/EditorCommands.swift:577 + Registry/ShellActions.swift:951
· ⌥⌘L pressed while VX-377's wing selector is already up re-fires `openWingDestination` (a fresh
request token), since the registry gate doesn't know a sheet is presented.** Mechanism as far as
traced: the grey-chord monitor passes an ENABLED chord to the menu; the menu item re-runs
`wingChord(.move)` → `openWingDestination` → `shell.wingDestinationRequest = …(token: UUID())`.
What a duplicate request does to a presented selector (reset of the typed filter, or ignored) was
not traced to the presentation seam, so this is below the pin bar — the same class as re-pressing
the ⌘K row, pre-existing grammar. Recorded for the implementer's one-line confirmation in the
round-2 disposition, not as a defect.

---

## Dispositions on the items the record flagged "for the ladder"

- **VX-639's three deliberate flips** (`MCPStarServerTests.aGatheringsOwnStarLandsAtEditOnItsPlace`,
  `MCPBookStateServerTests`' narrowed refusing loop, `MCPCarriageServerTests:433`'s set_book_rule
  arm): **APPROVED** — each cites RB-7/A-648-5 in place; the superseded P-13nb-U1-4 comment is
  replaced with the justification; MCPSpec itself already records RB-7 as "ruled 2026-10-28 to
  change", so the flips track a ruling, not a preference.
- **VX-606's export_note flip + MCPSizeCapTests edit**: **APPROVED** — the old pin
  ("export_note ignores the new arguments") pinned MID-3's bug class itself; the new pin asserts
  the exact refusal words AND keeps the declared form byte-unchanged; the size-cap pad moved to
  `params` (the `initialize` helper's own precedent), the 16 MiB subject intact, the line still
  exactly the cap.
- **VX-626's MCPSetupKeyServerTests edit**: **APPROVED** — the stamp made an existing race
  visible; the edit waits for the end line before reading `before`, its subject ("no refusal
  touched the row") unchanged.
- **VX-643's six flips, four retirements and the literal-15 justified edits**: **APPROVED** —
  red on the pre-fix tree is recorded per flip (36 issues + the P1 pin's 4); the retired pins'
  subjects are gone with the cap; `GatheringMintTests`/`MCPGatheringGrantServerTests`' literal 15
  keeps the mint's past-any-cap subject without resurrecting the symbol. The
  `MCPWireRefusalSweepTests` count 76 → 75 is the TRACED delta: I counted the declared
  `OperationError` cases at main (108) and HEAD (107) myself — exactly `starLimitReached` gone,
  nothing joined (VX-606's and VX-639's new refusals are not `OperationError` cases).
- **VX-632's one-owner shape** (⌥⌘L declared and keyed once, on the note's Move; the book's act
  declares the same item's `.menuBar` door with no key and is reached by focus): **APPROVED** —
  honest under P-1: the act's door is declared and rendered, the key table keeps one owner (four
  standing pins), `WingChords.acts` names the sharing as data, and bending the table for a
  focus-exclusive pair would weaken the collision pins for no user-visible gain.
- **`BrowserNavKeysTests`' alternates edit** (⌘↑/⌘↓ join the no-menu-key guard): **APPROVED** —
  the same class as VX-560's own keys.
- **VX-563's takes-parity exemption + VX-644's walk union line** (`CapabilityRegistryTests`):
  **APPROVED** — the exemption's reason is `.newNoteInBook`'s own (a book-surface navigation act,
  no note mode behind another); the union gains `QuickEntryBar.surfaceCapabilities` exactly as
  the E2/E8 class requires (a new renderer is a new line).
- **VX-645's seam flip** (`BookNoteStepTests.theSeamReadsEachModesOwnViewedNote` — the flow arm
  reads `flowViewed` with no fallback): **APPROVED** — nil is "before the first note", the
  Outline's title-block rule; the interim standing-anchor source is gone as A-648-6 (2) ordered.
- **VX-630's focus-at-the-switch** (arrival logic at the departure site): **APPROVED** — the
  justification is real: `EditorView`'s model is `@State`, seeds are taken once at init, and the
  focused row mounts its editor in the very update the mode changes in; every other focus,
  collapse and collapseAll clears `caretBlockSeed` (verified in `BookViewModel`); the one-shot
  resolves through the EXISTING `rememberedArrivalLanding` brain and `EditorTextView` /
  `BlockRangeIndex` / `PaneSurface` are untouched.
- **The w2a pin fixes (B4-6)**: **APPROVED** — both were pin faults, both edits keep every
  assertion (the fixture gains the sibling fixtures' seeded RNG; the Pages pin mounts the reader
  and `#require`s its report before the row's act); the pre-existing seed-before-adopt arrival
  finding was correctly NOT fixed under cover and is VX-663.
- **B1-7 / A-648-2's SKIP** (narrowing the tray-badge observation): **AGREED** — the traced read
  set genuinely includes `container` (the fence's `cc.deleted_at = b.deleted_at`), and
  `registerTextChange`'s full-record update makes a column-level narrowing useless; the evidence
  landed on VX-618 where the class lives. With v1_34 the held re-run is a seek per deleted block
  — the P1 pin holds the shape.

---

## Clean bill — load-bearing things specifically checked and found solid

1. **v1_34 (VX-647) — the mechanism, the shape, the lockstep claim.** The fence
   (`Queries/PoolAndTray.swift:183–187, 343–347`) joins `cb.deleted_at = b.deleted_at`; before
   v1_34 nothing served a tombstoned placement by `block_id` (`uq_cblock_ownership` is partial
   live-only, `idx_cblock_order` leads with `container_id`) — the SCAN-per-deleted-block shape is
   real in source. The amended index is PARTIAL on `deleted_at IS NOT NULL`; the equality term
   implies NOT NULL so SQLite can use it there, and no live seek can adopt it, so the six pinned
   live plans stand unedited. **NOT a SyncSpec §12 lockstep event — verified against SyncSpec §2
   (the mirror deliberately carries no indexes beyond the PK) and §12 (mirror-visible shape and
   semantics only), and against the v1_15/v1_17 precedents; marker stays 14.** The migration sits
   in its own commit (`c63f2e67c`), ahead of the pins, with the arrival pin asserting the exact
   partial DDL. **Ran by this reviewer:** `TrayBadgeP1Tests` (4) + `MigrationTests` green with
   the record's exact numbers — badge 2,124/2,124, listing 2,612/2,612, held carve round
   6,801/6,801, autosave 3,224/3,224 at library ×1/×15. The id/body freeze (A-648-4) was honored:
   the partial amendment predates walk 1.
2. **VX-649's shared-cause verdict** — the flight anatomy (retraction one turn before the landing;
   both writes paying the held badge) is coherent with the trace, and the LIVE capture landed:
   walk 1 measured the vanish at ~50–67 ms post-fix (was ~1 s), flat across 0→305 carved blocks,
   worst gesture 88.7 ms. The frame-scale residual is honestly ticketed (VX-655) and the editor
   seam was NOT touched to chase it.
3. **VX-643 — complete retirement.** No code reference to `starLimit`/`starLimitReached` survives
   (comments only); every "fifteen"/cap sentence swept on Mac, wire and phone; the mobile seeder
   no longer tolerates a cap refusal; the mint/collect exemptions collapse into the one star
   write with their subjects pinned. The found-and-fixed P1 read (`+kind` in
   `starredListItems`) is semantics-identical (same predicate, evaluated per row) and in-scope
   under the ticket's own P1 clause (A-648-7); `StarsP1Tests` green at 525→525 / 855→855.
   `starredReadingRows`' author-scale reading SCAN left as documented. MOBILE PARITY row drafted.
4. **VX-606 — one rule, one door.** `MCPArgumentSchema` walks the DECLARED schema only (open
   schemas honored, nested closed objects and array items covered, paths and the past-five count
   correct); the check sits in `MCPSession`'s CallTool handler AFTER the VX-258 waiting branch
   (the pending sentence preserved — pinned) and BEFORE routing, so nothing is read, written,
   asked, spent or logged; unknown tools keep the router's answer. The 66-tool walk pin, the
   once-grant-unspent pin and the whole-target sweep's two honest edits all verified; suites ran
   green here.
5. **VX-626 — the stamp rides the line.** `recordMCPConnectionEnd` is the ONE body both end-line
   roads call (`MCPSession.writeEndLine`, `MCPServerHost.recordConnectionEnds`), one clock read
   for row and Activity; a quit/crash/unnamed connection stamps nothing (P-VX394-5 honored).
   **Checked: `last_seen_at` has no semantic consumer** — grants' while-connected liveness never
   reads it; only pane display and two ORDER BYs (Clients row order, Share-another-place's WHO
   order) — both of which the close-stamp makes more honest, not less. Suites ran green here.
6. **VX-612 — fail loud, retry the transient class.** The classification is pure and pinned;
   the pause is bounded (10 ms → 1 s cap) and woken by a stop; tries never run out by design
   (a success resets). `listenerDied` takes ownership under the lock (`listenFD == fd &&
   _state == .running`), so a stop that won the race leaves it inert; **the fresh-host unlink
   race is closed by the `acceptDone` semaphore** — `halt` waits on `done` before any unlink or
   her switch's fresh host can bind, and `done` signals only after `listenerDied` returns. The
   door adopts the state only from the host it still holds, never restarts a self-stopped host
   on a snapshot change (the while-connected-grants reason is real), and the start-completion
   race (listener died in the hop back) is read. Served sessions deliberately kept. Suites ran
   green here; the Mac door pin ran in w2a's union.
7. **VX-639 — parity at edit, the rule hers, no new oracle.** The gathering place is decided
   ONLY through `decideGathering` (its own grant or its wing's — never a note or book grant,
   pinned byte-identical to a missing id); the act's guard re-decides and spends inside the
   transaction; refused rows log the argument's noun "book" AND `MCPOwnActivity.entry` never
   carries a refused row's title or a looked-up target — so `list_my_activity` still cannot
   tell a gathering from an unreachable book. `set_book_rule` on a readable gathering refuses
   with the reworded sentence (A-648-5) and writes nothing; the unreadable arm keeps the one
   shape. The hers-alone trio is asserted around EVERY call (`callKeepingHersAlone`). The name
   guard's reach (`readableBooks` → `decide(reading:)`) covers books AND gatherings through the
   one rule. The ops called (rename/archive/unarchive/delete/star ForClient) write none of
   `ai_private_at`/`sealed_at`/`owned`; the daily Journal cannot be a gathering (the `'daily'`
   marker is a book's). Walked live (W3): receipts, undo labels, Activity words, the rule
   refused, the parse-vs-gathering arms distinguished.
8. **VX-640** — bound 3,000 → 3,100 with the pin moved (JUSTIFIED); "/mcp" provider-neutral with
   the O-4 net re-asserted in the same pin; the MCPSpec deltas (3,011/3,100, the clause texts)
   are DRAFTED and match the as-built strings — they must land at closeout exactly as drafted
   (L-9).
9. **VX-641 — one monotone fact.** `MCPLibraryClients.everHadClient` is VX-590's fact read the
   other way; the pane's `saysClientsBelongToTheLibrary` now derives from it (byte-identical
   logic), the note row reads it inside the bar's held observation (the row appears the moment a
   first client row lands), a marked note or book always shows the row (its own mark or a
   Private book's — the "never invisible" reading is sound), the Book Settings latch is recorded
   PROVISIONAL (B2-P4), and the lock popover's by-construction gate is real (approved client
   required). The held observation's region growing by `mcp_client` is connection-scale, not
   keystroke-scale — no P1 concern.
10. **VX-563 — the rule and the door.** Pure `BookNoteStep` (exactly ⌘; `.numericPad`/`.function`
    ignored; nil while text holds the keyboard through the ONE `PageTurnKeys.textIsFirstResponder`
    answer; Index never consumed; stale viewed notes guarded against the order); no menu item for
    VX-560's exact reason, the keys recorded as alternates and shown in ⌘/; the monitor is
    window-scoped, pane-focus-gated, and consumes only when the step was used; the Outline step is
    reveal-only so repeated stepping survives (A-648-6 (3) — the mechanism is real: a focus would
    mount the live editor and the next press would go document-end). Walked (W3-4) including the
    end words and the in-text document-end half.
11. **VX-632/VX-644** — the chords ride VX-377's selector through the ⌘K rows' own road under the
    same gates; the collision sweep was re-run at the tip and recorded in place; the grey chord
    speaks existing words only; the labels are the same `.switchWing` act in THIS window
    (per-window ShellActions), one-wing speaking ⌘L's ruled note; the quiet voiced style gives
    its insets back so the words rest where the label's did. Walked (W3-2/3-3, both voices on
    the label).
12. **VX-645/VX-646 — one brain, report-only.** `BookOutlineFollower`/`BookOutlineViewed.rule`
    reused unchanged over the flow's own rows (`FlowRows.viewedRows` = `BookOutlineRows.rows`;
    the undrawn unfiled heading closes the chapter above — pinned); the adoption/release/clamp
    wiring mirrors `landOutline` one-for-one (her scroll lets go FIRST; the box captured, never
    the view; one look per turn; `live` fences a queued look after teardown); `viewedFlowPair` is
    its own equality-gated slot and reaches no focus, reveal or landing; the discrete modes'
    pairs are DERIVED (no slot); 13c 2A's deleted progress machinery does NOT return (checked:
    no bar, no visibility brain — the follower reads geometry the landing already takes).
    VX-646 reuses `SidebarLayout.SectionFollow` whole; only the highlighted row reports (P1);
    `scrollTo` clamps so VX-562's inset-extended-travel trap cannot bite; P-562-1's supersession
    is her 2026-10-28 word at #246 (verified in QUESTIONS) and nothing encoded the old behavior
    (grepped). P-562-8 (the bottom twitch) untouched, as ordered. Walked (W4-3/W4-4).
13. **VX-630/VX-631** — traced above (dispositions); both revert-verified headlessly on the REAL
    source files; VX-630's uncovered stale-anchor neighbour honestly ticketed (VX-662) rather
    than stretched into the fix; the walk confirmed the round trip and the Index-first arrival
    (W4-2) and the "2 stories came back" receipt (W4-1).
14. **Process and hygiene.** `Sources/VariorumCore/Sync/`, `Server/`, custody/keychain and the
    editor seam files (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`,
    `PaneTextAuthority`) are untouched by the whole diff (verified by pathspec diff). The only
    notes file in the diff is the run record — the two-file rule held; every canon delta is
    DRAFTED for closeout and I verified each drafted line against the as-built strings. No
    commit in `origin/main..HEAD` carries an attribution trailer. Main was merged IN at the
    batch seam and origin/main has not moved since (merge-base = origin/main tip). The roster's
    17 members are all accounted for in the diff and record; VX-612's membership is her
    kickoff's own word (the #245 "riders not taken" line predates it). The evidence phase is
    real: w2a's union 953/146 with its 3 reds traced (two pin faults, one stale count — all
    three re-run green 28/3 at the final tree), sim 20/3, walks 1 and 2 all sets pass with the
    posture restored line by line (the two classifier-denied stray Trash rows and the
    tutorial/walk tags are recorded residue for her/the coordinator — O-2).
15. **Reviewer-run verification:** `swift test --filter 'TrayBadgeP1Tests|MigrationTests|
    StarsP1Tests|MCPUndeclaredArguments|MCPArgumentSchema|MCPAcceptLoop|MCPConnectionCloseStamp|
    MCPGatheringBookActs|MCPLibraryClients|StarsTests|UnionStarTests|MCPStarActsTests|
    MCPStarServerTests|CollectSetsTheStar|GatheringMintTests'` — **101 tests in 13 suites, all
    green**, printed numbers byte-matching the record's claims.

## For the closeout (reminders, not findings)

- Land the drafted canon deltas exactly as written in the batch records (MCPSpec's 3,100 line,
  the R-VX184-1 gathering paragraph, the VX-606 clause, the VX-626 clause, the pane's VX-612 +
  VX-641 sentences, the guide lessons; SurfaceContracts' keyboard-family, wing-label, star-cap,
  navigator and Index-carry lines; AppSpec §12's keyboard line; the MobileSoul PL row;
  AppSpecRecord's dated entry) — I checked each draft against the shipped strings.
- Fix the in-flight row's "no schema" word as it retires (the MINOR above).
- The release that carries this run states "local-only migration v1_34" as a release fact
  (the coordinator's reservation note).
- VX-440 is still in flight on overlapping surfaces (Book Settings, the navigator, gathering
  faces) — the serialize-and-re-run-overlap duty stands for whichever merges second.

**Round-1 outcome: no finding requires a fix leg. The MINOR is a closeout ledger edit; the NITs
are recorded with dispositions. Per the ladder, round 2 is not earned by any new BLOCKER/MAJOR.**
