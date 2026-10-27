# VX-620 — Ladder round 1 (cold review, fable-reviewer)

**Reviewer:** fable-reviewer (Fable 5, xhigh), fresh session, 2026-10-27. Diff: `origin/main...HEAD` on
`vx-620-run-mcp-umbrella-remainder` (58 files, +5,947 / −193, commits `2f84e3d6d..a593ea8da`). Prompt:
`notes/REVIEW_PROMPT.md` verbatim. Read in this session, directly: CLAUDE.md + auto-loaded canon,
`notes/MCPSpec.md` IN FULL, `notes/SurfaceContracts.md` (The app · The Bookcase and books · Doors to the
outside), the run record `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md` IN FULL, QUESTIONS #227/#243's
relevant entries, every source file in the diff, and the test suites (new ones whole; edits as diffs).
Re-run cold on the tip, headless: 23/4 core (`MCPStarActsTests` · `GatheringTagsSatisfyTests` ·
`MCPMintedBlocksActsTests` · `MCPPlaceTwiceProbeTests`) + 48/7 wire (`MCPStarServerTests` ·
`MCPGatheringGrantServerTests` · `MCPConnectionNamingSignalServerTests` · `MCPImportSectionServerTests` ·
`MCPBookImportRecordsServerTests` · `MCPAdviceServerTests` · `MCPMintedAnswerServerTests`) + 27/3
(`MCPServerTests` · `MCPWriteServerTests` · `MCPProviderNeutralityTests`) — **ALL GREEN**. Red-on-old evidence
verified from the batches' logs on disk (b1: `pins-red-on-old.log` 3 red / 6 issues, `star-acts-revert-red.log`
4 of 9 red / 11 issues; b2: `vx605-red-on-old.log` and `vx605-revert-red.log` each 1 of 3 red, green after;
b3: `vx566-red-on-old.log` 5/5 red / 27 issues, `vx567-red-on-old.log` 2/2 red / 4 issues).

**The run plan carries no "Review foci" section (a run, not a phase plan); the bundle's "for the ladder" items
(RB-8, RB-11, RB-17, W-3, batch 3's book-form note) are treated as the foci and each is dispositioned below.**

**VERDICT: no BLOCKER, no MAJOR, no MINOR. Four NIT-class observations, every one record-only — none has a
mechanism a red-on-old pin could catch (each is designed behavior, bookkeeping, or a pre-existing accepted
scope), so none enters the fix protocol. No fixes are owed from this round; the round's one standing
CONDITION is the final window (clean bill, item 14).**

## FINDINGS (severity-ranked)

- **[NIT] · W-3 (walker finding, referred to this ladder) · `Operations+MCPWrites` / the activity log ·
  Activity's `target_kind` says "book" on a REFUSED gathering mint and "gathering" on the allowed one, same id**
  · Evidence: the refused row logs the argument as sent (`book_id` ⇒ kind "book" — P-VX261-5/6's no-oracle
  posture: a refusal must not reveal that the hidden id is a gathering; a hidden gathering and a hidden book
  must read alike), while an allowed act logs the resolved kind. Both are correct by their own rules; the
  inconsistency is cosmetic, visible only in her own Activity pane across an allowed/refused pair on one id ·
  Fix: none (a pin would be green on both sides — the behavior is as designed). If she wants Activity's kind
  vocabulary harmonized it is a Wording ticket, her call. **Disposition: reviewed, record-only, no change.**

- **[NIT] · RB-11 (referred to this ladder) · `MCPSession` handler path (VX-605 sweep row 5) · VX-258's
  in-handler `awaitsHerOK` flip signals nothing** · Evidence: the batch 2 trace is correct — the flip is
  reachable only if her Allow commits inside the gap between the admission's commit and the SDK's `initialize`
  hook, a sub-second machine window her hand cannot hit; every reachable naming road is covered by the fix or
  pinned green (sweep rows 1–4, 6–11 read in this session against the code) · Fix: none now — a one-line signal
  at the flip would be an unpinnable fix (the hallucination guard: no red pin without a handshake test seam).
  **Disposition: agree with traced-not-fixed. If a handshake seam ever lands for another reason, close it then.**

- **[NIT] · RB-17 (i) (referred to this ladder) · `WingsModel.actGeneration` · the wing-act re-ask is per
  window** · Evidence: each window owns its `WingsModel`, so a wing act in one window leaves a second window's
  sidebar doors and indicator as they were — exactly the pre-existing per-door era's scope (the sidebar's own
  `wingActGeneration` was always per window); the second window still refreshes on its other keys (rows change,
  wing switch). The diff strictly widens reach within a window and regresses nothing · Fix: none (a
  cross-window signal is new design, unasked). **Disposition: accepted as the standing scope.** RB-17 (ii)
  verified — the shared signal closes VX-425's pre-existing cross-door half (Library/Pool row and note ▾ menu
  moves) and `aWingActFromAnyDoorReasksTheSidebarsReads` covers both roads; (iii) verified in
  `WingDestinationSheet` — ⌘L is consumed as a step and `.commandUp` returns false, so no release commits;
  (iv) the palette → selector hand-off is walk-verified only, and the final window's walk leg 1 plus the
  record's "Watch" line cover it — acceptable for a two-sheet shell hand-off no harness mounts.

- **[NIT] · scratchpad bookkeeping · `scratchpad/b3-logs/vx566-green.log` holds a 3-test run while the LIVE
  STATUS cites it for the 16/4 + 3/1 green set** (evidently overwritten by a later, narrower invocation) ·
  Evidence: the log on disk ends "3 tests in 1 suite passed"; the committed red pins (`6721d651c`), the
  batch-end `headless-all.log`, and this review's own cold re-run (48/7 wire green) carry the real evidence,
  so nothing load-bearing rests on that file · Fix: none owed in the repo (gitignored scratch); noted so round
  2 does not trip on it.

**Dispositions on the remaining referred items:**
- **RB-8 (the star undo's four design calls)** — reviewed at the mechanism level and ENDORSED as built: the
  place-restore (clamped insert, the un-starring half recording where it stood) is the exact-row-redo doctrine
  applied to a list; `heard: false` replays are `apply_tag`'s replay doctrine (pinned with a living ★-rule book
  as witness — a replayed star seats nothing, her own star at the same moment does); the cap-refusing half
  keeping its entry is VX-246 U2's retire-only-when-quiet rule read correctly (a refusal is not the world
  moving on — it is resolvable); the column-only book's star returning in both stores is the union's normal
  form. The boolean compare-and-set ("writes only while the star reads its partner's value") is equivalent to
  the differs-from-desired guard for a two-valued field — correct, and the trashed-note arm closes the one gap.
- **Batch 3's book-form note** — ENDORSED: the whole-book form refusing `section_id` in words (never ignoring)
  is the wire's standing discipline for a meaningful-elsewhere argument (`book_id`-with-a-book's precedent);
  ignoring would reproduce VX-566's own failure shape (success with nothing filed where the client asked).
  VX-606 (undeclared arguments generally) remains the wider open ticket, correctly untouched.
- **RB-1 / RB-3 / RB-4 / RB-16 (the PROVISIONALs)** — each is built as the most spec-defensible option, marked,
  and bundled with real alternatives; RB-4's supersession of a RATIFIED call (P-VX252-1/P-VX254-2, #227) is
  flagged loudly in the record, the pin's flip comment, and the bundle, with a one-commit revert road — the
  deliberate-flip ritual followed exactly. Nothing to change at this ladder; they are hers.

## CLEAN BILL (checked and found solid)

1. **RB-1's composition (`GatheringMint.starringOnlyWhereNeeded`)** — tags first, byte-equal to VX-549's plan
   wherever tags satisfy (the 10-row unit table pins wire == star-forbidden plan there); the star only on
   `.blocked(.needsStar)`, there her door's own plan; the wire never answers `.needsStar`; the gathering's own
   state (archived) still speaks first; the belt (`matchesRule`) runs with a FRESH `StarContext` so it sees the
   star the act just wrote; the mint order is her door's (rule tags → star → header tags → belt), and the star
   write is the ONE `writeStar`, cap-exempt via `newPostInGathering`'s own arm (P-13id-U2-1).
2. **`Operations.setStarredForClient`** — the guard FIRST inside the act's one transaction; the no-op answers
   `changed: false` with no write, no entry, no receipt, the landed Activity line (VX-362's shape; the once-spend
   on a no-op matches `apply_tag`'s — its `land` spends after a caught `alreadyTagged` too); the cap refuses as
   `starLimitReached` through the ONE chain in her `OpsRefusalCopy` words (pinned over the socket, byte-level);
   intake hears a wire star exactly as hers (her own door run as the witness in the same test); un-star a
   non-event; a book star writes both stores.
3. **The star fence and rungs on the wire** — a Private note, a ⌘J entry, the daily Journal, a Private book and
   a foreign wing's note each answer the ONE not-shared shape byte-identical to a missing id (pinned); below
   EDIT the rung sentence + her ask; the tool is not listed below edit; a readable gathering's own star answers
   the gathering sentence, now naming starring (P-VX196-2's posture, bundled RB-7). The daily Journal's per-ask
   fence (her re-confirmed line) is untouched and pinned.
4. **VX-605** — the trace verified in the code itself (`grantsFingerprint` never reads `last_seen_at`;
   `.removeDuplicates()` swallows it; the registration signal reads a nameless session); the fix signals the
   SAME road (P-4, no decision), outside the session lock, weak-host; the stop-race guard is by construction
   (the door re-reads its CURRENT host on the main actor) and pinned both sides; VX-394's rows and VX-180/181's
   window unregressed (64/12 seam suites green, re-confirmed in the naming suite's green run here); red-on-old
   AND one-line behavioral revert both red in the logs; the Mac door pin's anti-hollow choreography (register
   silently → assert the nameless hop → then name) read and sound.
5. **VX-590** — the gate is VX-512's one fact read the other way (`showsSharingFace = !saysClientsBelong…`), so
   the two faces can never disagree; "ever" is monotone (Deny keeps the row; the waiting room's cap prunes only
   the oldest past fifty; adoption keeps rows); her pick is kept while the shown tab clamps (`shown` falls back
   to the opening rule, never overwrites `paneTab`); the Settings search leaves out EXACTLY the hidden tab's
   row (`all.subtracting(hidden) == [the open book's lead]`), the one index consumer verified; every share face
   outside the pane already waits for an approved client (VX-272 — verified as probe, not rebuilt); the fix leg
   2-F1 is a pin-scope fix with the product unchanged and the Waiting-row question honestly bundled (RB-14).
6. **VX-566** — `create_note`'s exact shape on the one-document form through the SHARED body (`mintNoteEntry`):
   parse refusal without `book_id` in `create_note`'s own sentence; the book decided first (unreachable book =
   the one not-shared shape whatever `section_id` names, pinned); every bad chapter id class answers the ONE
   sentence byte-identical across `import_document` / `create_note` / `add_note_to_book` (pinned per id, per
   door); the filing rides the import's one undo and its redo; the answer echoes `section_id` only when given.
7. **VX-567** — `BookImport.notes` built at each seat from `mintDocument`'s own return, never a second read;
   her File ▸ Import and the Bookcase drop read none of it; the answer is ∝ the request itself (the client sent
   every byte it reads back as a digest) — no corpus-proportional cost anywhere in the diff; the digests pinned
   against the test's own CryptoKit SHA-256 of the sent words; the ratified-call flip done as a loud deliberate
   flip (RB-4) with the F-2 guard renamed, both suite headers re-said.
8. **VX-619** — the advice sentence is provider-neutral and the mechanics are EXECUTED in its pin (stop → all
   gone → start → reconnect served); the guide's Claude Code road sits inside lesson 2's O-4 fence and the
   provider-neutrality net ran green here; the ≤3,000 pin green; the traded sentence's rule proven present
   word-for-word in `move_note_to_wing`'s own description (pinned); existing libraries hear the guide only via
   Restore Field Guide (standing), the real store's re-seed noted for her window.
9. **VX-565** — an honest probe: no fix invented (the hallucination guard held); her exact shape reconstructed
   on every minting road of today's tree and impossible by VX-393's unique index; the three honest two-row
   shapes each pinned with what their rows say; the fourth look-alike (a waiting ask above the tabs) accounted
   for. Closes on the record.
10. **VX-377** — the three `.palette` doors declared once with the gate as registry data (P-1); the row doors
    unaffected (every renderer of the context/bar doors reads only the verb — verified across `WingsModel`,
    `ShelfView`, the door-set lists; no `isEnabled` reader meets these acts outside ⌘K's own road); the
    selector is the switcher's brain and key catcher over the act's own destination rows — no second picker,
    no second filtering rule; the choice runs the EXISTING acts and confirms (moveAsk/copy/bookMoveAsk), the
    confirm's Cancel returning to the selector and only Move closing both; open-time re-checks speak real
    refusals (the daily Journal the op's own sentence, by the same `isDailyJournalMintShape` the drawn rule
    uses); ⏎ safety is structural (`listedCommands` snapshot written with `items`, the `generation` guard, and
    `prepare()` before the first refresh — and even a race lands on the registry-note refusal, never a wrong
    act); the cross-door re-ask is a counted SIGNAL (P-4) bumped only on landed acts, keyed into exactly the
    three one-shot reads, with VX-439's m-3 contract (the column's own generation) kept beside it.
11. **The registry walk's justified edits** — the two new sampled contexts and `takesIsNeverBehindWrite`'s
    non-mode facts are the VX-570 class, each cited; no other `takesAccess` act reads the three facts (checked:
    the only availability readers of `focusedPaneShowsNote/Book` + `wingCount` are the three wing acts,
    `.closeNote`, `.newNoteInBook`, `.switchWing`).
12. **Lanes and canon** — diff-verified: nothing under `Sources/VariorumCore/Sync/`, `Server/`, custody,
    `Protection/`, the editor seam, `App/Variorum/Shared/` or `VariorumMobile/`; no schema change; grants stay
    local-only; `set_starred` stays clear of the hers-alone trio (Private · Seal · Own — R-VX184-2 upheld, the
    star provably not among them); every canon delta DRAFTED in the record, none applied (the two-file rule
    held); batch 4 confirmed App-only (`git diff 956c9984e..1e9a8f1f7 -- Sources Tests Server …` empty);
    MOBILE PARITY "nothing mobile-visible" confirmed by the same diff.
13. **Suites** — this review's own cold re-runs on the tip: 23/4 + 48/7 + 27/3, all green (the provider net's
    11.4 s run included); the batches' committed red-pin commits precede their fixes in history; the two
    standing flakes (VX-532, VX-625) did not appear in these targeted runs.
14. **CONDITION, not a finding** — the Mac pins of all four batches are COMPILED, NOT RUN (stated plainly in
    each batch's NOT-DONE line): `WingPaletteDoorsTests` (10, two mounted), `MCPSharingFaceTests` (5, one
    mounted), `MCPConnectionNamingDoorTests` (2), `MCPStarFacesTests` (5), `MCPPlaceTwiceFacesTests` (3), the
    flips in `MCPGatheringGrantFacesTests`, and the justified edits (`MCPPaneTabsTests` both voices,
    `SettingsAccountSurfaceTests`, `CapabilityRegistryTests`, `TutorialMCPChapterTests`, `WingSwitcherTests`,
    `WingBookMoveDoorTests`). This round's verdict is contingent on the final window's `DerivedData/b4` run
    going green (plus the planned walk legs — the palette → selector hand-off and the selector in both voices
    especially); any red there returns to the ladder as new material.

**Round 1 outcome: zero findings enter the fix protocol. Per the cross-model flow nothing goes to the
implementer; the next gate is the final window's Mac run + walk (ledger row 7), then round 2 is not earned —
there are no round-1 fixes for a fresh reviewer to re-check, so the orchestrator's line-by-line check clause
has nothing to cover either. The bundle items stand for her sitting as recorded.**
