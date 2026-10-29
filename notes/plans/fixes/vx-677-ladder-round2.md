# VX-677 — ladder ROUND 2 (fresh cold reviewer, Fable, 2026-10-29)

**Scope:** round 1's fix round — the diff `3cf128fed..HEAD` (five code files: `MCPDoor.swift`,
`MCPPaneCopy.swift`, `MCPShowOfferFacesTests.swift`, `OutsideWriteLivePaneTests.swift`,
`RestoreLandingInspectorTests.swift`; everything after `982aaa5c2` verified record-only by
`git diff --stat -- ':!notes'`), re-checked against round 1's FINAL CALL
(`notes/plans/fixes/vx-677-ladder-round1.md`, the anchor) item by item, every changed line read, every
API the new pins lean on traced to its definition, the four gone-table queries read in full, the wire
suites re-run headless by this reviewer at the tip (`MCPShowOfferServerTests` +
`MCPShowServerTests` + `MCPShowCompareServerTests` **21/21**, `MCPGrantOperationsTests` **17/17** —
my own numbers, matching the record's).

## Findings

**None.** No new BLOCKER, MAJOR, MINOR or NIT. The fix round implements the final call faithfully;
the two places where the built shape moves past the final call's letter are both inside its own
authorizations (below).

## Round 1's confirmed fixes, re-checked per the final call's list

**F-L1 — VERIFIED.** The Takes twin's two fixture predicates leave `#expect(await settle {…})` for
locals `showsTheTake` / `isLive` (D-1's steps 2–3); the closure bodies and both messages are
byte-unchanged (diff-verified); the decisive `shows`, its expectations and the Lenses sibling are
untouched. The scratch-binary re-check is recorded with symbol-level evidence (three distinct bodies,
`TY3_`/`TY5_`/`TY7_` partials loading #1/#2/#3, the detector finding only the standing MCP lead);
C12/C13 carry the red/green to the window with the binary check ordered first, on the REBUILT
product, exactly as the final call required.

**F-L2 — VERIFIED, every ruled specific:**
- *The gone table* (`MCPDoor.showTargetStands`, nonisolated static, pattern-matches verified against
  `MCPShowTarget`'s cases): note/takes/lens/compare → `Queries.mcpNoteFacts != nil` (read in full:
  live, `kind='post'`, never a born-archived version; an ARCHIVED note stands — kept, not gone;
  compare binds its ANCHOR noteID); version → that AND `Queries.isVersionHistory` (the predicate
  read); book → `Queries.reading` (nil on tombstone; books AND gatherings; archived stands); wing →
  `Queries.wingIsLive` (Home `''` always true, verified in source). The residual (dead compare peer,
  a takes block, a lens, a chapter) is recorded in the function's doc and as F-FR-1.
- *Her take:* the `noWindow` arm (ask kept) precedes `endShowOffer()` byte-identically; the ask ends
  at the press; GONE ⇒ `MCPShowOfferCopy.gone` refused, nothing delivered, NO take row (`logShowTaken`
  only on the standing arm — F-L3's `try?` posture preserved and now gated to standing takes, which
  strengthens ruling (4)); STANDING ⇒ the row then `deliverHerPress`, and a genuine `.unfinished`
  speaks her words, never `partialShowWords`.
- *The re-read off-main (P2):* `placeStands` → the door's `read` → `database.read` on the pool; a
  failed read answers STANDING (deliberate, recorded). No main-actor store read.
- *The fold-in (F-B3-2):* `openShow` takes `ShownChange` (target + the receipt's client + title,
  captured at land time — no second read); the nil-router arm speaks `MCPReceiptCopy.noWindow`; GONE
  ⇒ the refusal names place and client and `lastChange` retires only when it names that same target,
  so ⌥⌘O greys (P-FL2-1, PROVISIONAL-marked); `lastShow` survives as the computed target, so the
  registry fact (`aiLastChangeAvailable` reads `showOffer != nil || lastShow != nil`) and every
  existing pin compile and read unchanged. Swept: NO caller of `openShow` outside `MCPDoor`; the
  existing `lastShow` pins (`MCPNavigationTests:196–210`) read properties and never press; the Pool
  receipt test's action is synthetic. Every existing receipt-road pin stays green by construction.
- *The words:* `MCPAskCopy.gone`'s exact shape ("‹place› is gone, so ‹client›'s ask was let go."),
  sentence case throughout, the place quoted, Home a place-name never quoted, ASCII possessive as the
  precedent, all PROVISIONAL (P-FL2-2) for VX-234's pass.
- *The three fixture repairs:* staging only, byte-level verified — inserted stagers (`stageNote` /
  `stageBook` / `stageVersion`, raw rows under the pins' literal ids; the version staged as
  `versionHistoryPredicate`'s exact facts, edge canonically ordered), comment lines, and two closure
  parameter renames (`_: AppDatabase` → `db`); no assertion line moved. My own sweep of EVERY press
  site in the suite (16 `perform()`/`takeShowOffer`/`showLastChange` sites) confirms the three
  repaired fixtures are the complete set of presses on fabricated ids: the dismiss and the
  late-press (`older.perform()` — the itemID guard returns before the re-read) never meet the check,
  and `aVersionTargetOpensTheFullSizePage`'s move half rides the agent road, which has no re-read.
- *The pin/guard pair:* `aTakeWhoseTargetIsGoneSaysSoAndOpensNothing` (per-target: the exact refusal
  string, selection unchanged, zero `show_in_app_taken` rows, let go, no stale seam item — the
  let-go lines green on old as predicted), `aTakeWhoseTargetStandsStillOpensIt` (opens, logs once
  then twice, nothing refused — keeps the pin able to tell dead from alive),
  `aReceiptsOpenOnAGoneChangeSaysSoAndOpensNothing` (line + ⌥⌘O arms: refusal, nothing opened,
  retired, greyed), `aReceiptsOpenOnAStandingChangeStillOpensIt`,
  `aShowThatCannotFinishOrFindsNoWindowSaysSo` (unfinished take words / unfinished Open › words /
  the `noWindow` sibling on a windowless door, read synchronously — correct, the guard is before the
  Task). VX-692 honored: every read bound to a local before any macro reads it, stated at the MARK
  and verified by eye. The per-iteration `defer { rig.door.detach() }` fires per loop pass, so doors
  never overlap. `mountWait` mutation is the suite-serialized established pattern
  (`MCPCompareLandingTests`, `MCPNavigationTests`).
- *The wire untouched:* the fix-round diff holds ZERO files under `Sources/` (verified by stat);
  `MCPShowTool` zero diff; the wire suites green at the tip under my own run.
- *The C14 revert recipe:* all three one-line edits verified UNIQUE in today's `MCPDoor.swift`
  (`return stands` ×1, the unfinished-refuse line ×1, the `noWindow` refuse ×1); the predicted
  red/green per product traced by mechanism and found correct (on `revFL2` the three pins fail at
  exactly the recorded lines; the guards and the three repaired pins stay green — real rows pass the
  disabled check the same as the enabled one).

**F-L3 — the dismissal stands.** No code; the `try?` posture is now reachable only on a standing
take, as the final call noted.

**F-L4 — VERIFIED comment-only** (+4/−4 in the header; `grep VX668-TRACE|VX668Trace|vx668Road` over
App + Sources: 0, re-run by this reviewer).

**F-L5 — VERIFIED.** The drafts in the record match post-fix behaviour: the §Bookcase mode-row
paragraph carries the corrected VX-624 wording ("home at the page's floor and settles at the hold"),
the §The note Block History tail points at **(VX-668)** as ruled, and the fix round's own F-L2 canon
drafts (the MCPSpec `show_in_app` insertion, the SurfaceContracts status-seam sentence) state exactly
what is built. The canon application remains the closeout's, after claim C's gates.

## Within-authorization deviations (noted, not findings)

1. **C4 = 36/EXACTLY 15, not the final call's provisional 33/14.** The fold-in added a fifth test
   (`aShowThatCannotFinishOrFindsNoWindowSaysSo`), whose arm 1 also stages through `agentShow` — the
   final call itself ordered "exact counts restated by the implementer at build time since the
   fold-in moves them." Arithmetic verified: suite 13→18 (`@Test` count confirmed 18), failures
   12 + 3 (the three agentShow-staged tests red at their staged ask's own `#require` on `rev676`;
   the two receipt-road tests never meet the etiquette).
2. **P-FL2-1 (a gone last change retires)** was the final call's "implementer's build call, marked
   PROVISIONAL" — built as retire-on-press, marked, with option (b)/(c) recorded for the bundle.
   Correct handling.

## Concurrences on the self-assessment's stare points

- *The raise-before-re-read* (`creationRouter()` first): kept so the `noWindow`/ask-kept arm stays
  byte-identical; it is her own press's raise. Concur — recorded, not rebuilt.
- *The unfinished line replacing a `requestMode` refusal's own words:* traced in
  `MCPNavigator.deliver` — reachable only when `open()` succeeded and the mode request then refused
  (a different post mounting in between); one message at a time makes the replacement the seam's own
  rule. Concur — recorded, not built around; the words are P-FL2-2's anyway.
- *F-FR-1 / F-FR-2* (the note-level residual; the agent road's raceable adopt): correctly recorded
  for the orchestrator to ticket or dismiss — F-FR-2 is fenced by the wire's own just-made read, and
  F-FR-1 is the final call's own ruled scope. Suggest both land as the record proposes (Low).
- *P-FL2-3 (the unpressed edge)* is the final call's routing honored — the bundle's, never this
  ladder's ruling.

## Merge gates the ladder RESTATES (unchanged in force; the window's)

- C1 (`rev668` EXACTLY 1), C7 (`revFW2` EXACTLY 1), C4/C5 at the new counts, C12/C13 (the rebuilt
  binary check FIRST, then 2/EXACTLY 2 and 2/0), C14 (`revFL2` 18/EXACTLY 3), C15 (163/0), and
  W-668-V1 ×3 — every product rebuilt once at the FINAL tip, each revert re-applied as recorded. A
  pin green on its revert product = HOLLOW: record it, never fix it (the record's own rule).
- The main merge-in (`b5e809c36`) and the rebuild remain ahead of the window; this round reviewed the
  branch tip pre-merge, so the window's counts are the post-merge rebuild's to confirm.

## Clean bill (load-bearing things specifically checked and found solid)

- The fences, re-run over the WHOLE branch at the fix-round tip: `Sources/VariorumCore/Sync`,
  `Server/`, `Sources/VariorumCore/Protection`, `App/Variorum/Shared`, `VariorumMobile`,
  `Package.swift` — all EMPTY. No schema change, no new dependency, no literal colour, no editor-seam
  file in the fix round. Mobile parity: nothing mobile-visible (Mac-only door + copy).
- Isolation and compile shape: `MCPDoor` is `@MainActor @Observable`; `showTargetStands` correctly
  `nonisolated static` for the `@Sendable` pool read; `ShownChange` nonisolated Sendable;
  `deliverHerPress` static on the main actor; `MCPWriteReceipt`'s memberwise init with defaults
  matches every new call; `Queries.mcpActivity(_:limit:)`'s default-nil limit matches the pins'
  calls; `MCPShowActivity.takenAct` resolves; `eventually` is the file's own helper. The recorded
  scratch `build-for-testing` (TEST BUILD SUCCEEDED, the run-product dirs untouched) is consistent
  with everything I traced; the window's `test-without-building` on the final-tip rebuild is the
  binding verdict, as the record already orders.
- The status seam: GONE and `noWindow` and unfinished all speak as refusals (doors that did not do
  the asked thing), so "a door that did nothing speaks a refusal" now holds on the take AND the
  receipt road; `endShowOffer` still ends the standing item exactly once; dismiss logs nothing.
- No existence oracle toward the client: the gone refusal is app-side, spoken to her; the wire's
  byte-identical hidden/missing shape and `MCPSession.instructions` are untouched this round.
- Trailer discipline: 0 `Co-Authored-By`/`Claude-Session` lines over the fix-round commits.
- Process: the fix round's NOT-DONE line is honest (no test run, no stage claim, every red/green
  predicted and owed to claim C); the throwaway probe was run and removed, never committed; the
  record's claim-C table, the drafts and the PROVISIONALs are all repo-first.

**The ladder closes at round 2 with no new findings.** The remaining gates are claim C's window and
the closeout's canon application — the orchestrator's, already structured in the record.

— round 2 reviewer (Fable), 2026-10-29
