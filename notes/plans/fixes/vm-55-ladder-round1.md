# VM-55 — Ladder round 1 (cold review, `fable-reviewer`, 2026-11-19)

Diff reviewed: `git diff origin/main...vm-55-wings-underneath` at 26fd77b82 (code tip c75bdb9af; the
two later commits are this record). Read whole: the run record (`vm-55-wings-underneath.md`, all 1999
lines), every changed source file's diff, every new test file (the raw-error pin, the picker pins, the
wings/door/message-line/direction suites, the four Mac pins), the SurfaceContracts Messages and wing
bullets, MobileSoul §1–§5, and the local stage logs under `App/Variorum/DerivedData/` to corroborate
the recorded verdict lines. Fences checked at file level: no `Sources/VariorumCore/`, no `Sync/`, no
`Features/Protection/` or `Shared/Protection/`, no editor-brain file in the diff.

## Findings

**No BLOCKER and no MAJOR found.** The findings below are MINOR and NIT.

1. `[MINOR]` · `notes/plans/fixes/vm-55-wings-underneath.md` (LIVE STATUS, batches 3–4) · **Two
   test-only fixes have never run green** — `MobileWingDoorShellTests` (fixed 931c77f79) and
   `VM63MacWingBrainsHoistPinTests` (fixed c75bdb9af) are both marked "re-run alone PENDING" and no
   later window ran them. · Evidence: the LIVE STATUS rows and the "Owed to the first fix window"
   paragraph under Ladder; `vm55-b4-phone-window.log` and `vm55-b4-mac-leg.log` show each red once and
   red again alone, nothing after. · Fix: no code — the round's fix window (or the merge gate's
   whole-target runs) must execute both suites on c75bdb9af-or-later products before the ladder closes;
   the orchestrator carries it. A process item, not a defect: the record is honest about it.

2. `[MINOR]` · `App/Variorum/Shared/StatusCenter.swift:~370` (`stand`/`endStanding`/`lineItem`) ·
   **A standing offer is invisible and unkillable on the phone.** `stand()` puts the offer in `current`
   for 6 s, then it lives only in `standing`/`lineItem` — and the phone's face
   (`MobileMessageLine.swift`) draws `status.current` alone: no phone view reads `lineItem`, nothing
   phone-side calls `endStanding`, and the line's design has no ✕. A standing offer raised on the phone
   would show for 6 s, then persist forever in state with no surface and no dismissal road. ·
   Evidence (architectural, no pin possible — the mechanism is complete except that no caller exists):
   the only `stand` caller today is `AppSession`'s MCP ask inside its `#if os(macOS)` block, so no
   red-on-old test can be written; but the seam is now shared, and the MCP door's phone arrival (the
   VM catch-up's) would hit this silently. · Fix shape (later umbrella's, or a one-line guard now):
   either assert/log when `stand` runs under `.phoneLine`, or route `stand` to a plain `offer` on the
   phone placement until a phone face for standing offers exists. At minimum the batch record's
   P-55-6 note should name it so the MCP umbrella inherits the fact.

3. `[NIT]` · `App/Variorum/VariorumMobile/Features/Shell/MobileMessageLine.swift:345` (`Probe.
   didMoveToWindow` → `raise(over:)`) · **A probe moved directly between two windows keeps the overlay
   and its observers on the OLD scene** — `raise` guards `overlay == nil` and `takeDown` runs only on a
   nil window, so a window-to-window move (no intermediate nil) never re-raises. `SPECULATIVE`: the
   phone app is single-scene and portrait-only; the shell's view has no road that re-parents it across
   windows, so no failing-on-old test exists. Noted as a hazard for a future multi-window/iPad world
   (which is itself a ruled exclusion). No fix owed now.

4. `[NIT]` · `App/Variorum/VariorumMobile/Features/Shell/MobileMessageLine.swift:185` (`ink`) with
   P-55-7/P-55-11 · **Directions wear the alarm ink.** A direction is delivered as kind `.refusal`
   (the Mac `direct`'s class), and the phone's face inks every refusal in `tokens.alarm` — so "Put back
   where it came from." (an original landing at the note's end) reads in the error red, while the same
   sentence on the Mac rides a neutral toast. Her P-55-7/P-55-11 ruled the CLASS; the ink consequence
   is this face's and is not named on the ratify list. · Fix: one line on the ratify list so she rules
   the ink knowingly (or a `direction` ink arm later); no code owed this round.

5. `[NIT]` · `App/Variorum/Shared/OpsRefusalTable.swift:~478` (`sentence(for:roads:)`) · **The
   unworded error's raw dump goes to the unified log with `privacy: .public`**, via
   `String(reflecting: error)`. An unworded error can carry user-named content (a book name, a rule
   reason) which then persists unredacted in the log archive. Precedent exists (the Mac StatusCenter's
   dropped-receipt debug line is public, and the dump used to be ON SCREEN, which is worse), and the
   level is `notice`, so this is hygiene, not a leak class — but `.private` (or auto) would keep
   Console debuggability for her own device while redacting sysdiagnoses. One-word change if wanted.

6. `[NIT]` · `App/Variorum/VariorumTests/VM61MacStatusSeamPinTests.swift:156` (`hoistedMacBrains`) ·
   **The Mac source scans cover `Variorum/` plus a hand-kept six-file list of hoisted brains; the rest
   of `Shared/` — which also compiles into the Mac — is unscanned.** A future Shared file that says
   `status.removal(` or takes a phone refusal road changes Mac behaviour without tripping either pin.
   The boundary is declared in both pins' docs, and scanning all of `Shared/` would false-positive on
   `StatusCenter.swift` itself and the phone-road declarations — so the list is a reasonable trade;
   the next hoist owns adding its file. Recorded so the convention is visible.

7. `[NIT]` · `App/Variorum/VariorumMobile/Features/Shell/MobileWingDoor.swift:178`
   (`.accessibilityLabel(wing)`) · **VoiceOver loses the page word on a root's path line**: the whole
   title is one button whose label is the wing's name alone, so "Home · Library" reads as "Home,
   button" — batch 1's plain line read the full path. The page is still announced by the selected tab
   door, and batch 4's observation 3 already routes the missing hint to the VoiceOver audit (VM-216);
   this widens that ticket's note to include the swallowed page word. No code owed this round.

## Review foci (each checked explicitly)

1. **`readScope` on iOS / every Shared caller** — solid. The only Shared readers are the three
   `TrashPurge` sites in `RecoveryActs.swift` (479, 525, 589 — ask-time count, act-time re-read,
   selection delete), the bootstrap's attach-and-revalidate, `commandRouter.wingCount` (inside
   `#if os(macOS)`), and `TypedTagPath` (note's own wing, untouched) — grep-verified on the tip.
   The Trash door takes exactly what the phone's room shows, pinned end-to-end by
   `theTrashListsAndEmptiesTheCurrentWing` (confirm counts one; `purge_intent` holds the wing's row
   alone).
2. **A wing that dies under the phone** — solid. `WingsModel.adopt` runs `revalidate` on every held
   delivery; pinned for a local delete (`aWingDeletedHereReturnsThePhoneHome`), for a sync tombstone
   landed in apply mode (`aWingArrivingDeletedBySyncReturnsThePhoneHomeAndTheListingsFollow` — the
   Library re-reads in Home and the dead wing's note reads as Home's), and for the open list
   (`aWingThatDiesWhileTheListIsOpenReturnsThePhoneHome` — the stale pick refuses with the table's
   `wingNotFound` sentence, nothing switches, nothing lands).
3. **Pickers read their own subject's wing** — solid. `MobileNoteTagsModel.refresh` and
   `MobileMembershipModel.refresh` read `Queries.effectiveWing(ofPost:)` inside their one read;
   `MobileCreateBookModel` snapshots the wing at open for guard+mint+vocabulary (VX-889's shape).
   The three pins stand the app in a DIFFERENT wing from the note (so a current-wing fix stays red);
   the record's red-on-old run (3/3, 7 issues, twin-mint and dead-term observed) matches the pin code
   and the local log.
4. **Snippets unscoped / Today / mints** — solid. `MobileScrapsModel` takes no wing (pinned
   `snippetsStayTheOneSharedRoom`); `MobileTodayDoor` passes `standingWing` to Core and the pin proves
   the Journal's wing wins from another wing; new note, quick note (SW-5) and the create-book sheet
   mint in the current wing with the per-wing name guard (pinned, including the cross-wing legal-twin
   "Essays").
5. **P1/P2** — solid. Every scoped listing is the same Core read narrowed by `wingID:`; the only new
   held read is the `wing` table (plus one `wingName` row in the tag manager's listing); all reads go
   through `session.database.read/observe` off the main actor; the overlay window adds no store read.
   Nothing scales with corpus; nothing copies text across entities; nothing tracks word-level change.
6. **The Mac unchanged** — solid. `readScope` pinned (`VM56MacWingScopePinTests`); the routing table
   pinned kind × style with `leavesPage` ignored on `.receiptStyle` (`VM61MacStatusSeamPinTests`, and I
   diffed the moved `StatusCenter` against origin/main's — the Mac path through `deliver`→`place` is
   behaviour-identical); the refusal homes' last resorts pinned byte-for-byte
   (`VM62MacRefusalWordsPinTests`; I verified `knownWords ?? fallback` ≡ the old switch for every arm,
   including the non-OperationError road in `VersionActs`); the hoist pinned by the whole Mac wing
   family green on the merged tree plus `VM63MacWingBrainsHoistPinTests` on the words seam (its
   `.mac`-roads comparison is equivalent to `.phone` for the three parting cases — both reduce to the
   plain fallback — so the pin discriminates correctly). `WingPaletteDoorsTests`' one edit is the
   source-pin path only.
7. **One seam, one brain** — solid. The kinds carry no platform fork; the one `#if os(` in
   `StatusCenter` is the placement DEFAULT (composition — no caller sets it; both sides pinned); the
   six hoisted brains carry no `#if` and no AppKit/UIKit/SwiftUI import (grep-verified and pinned on
   both targets); the Mac hands its refusal words in (`WingsModel+Mac.swift`), the phone hands the
   table's phone road. See finding 6 for the scan's declared boundary and finding 2 for the one
   phone-side gap in the shared seam (`stand`).
8. **Her ruling on the phone** — solid. `StatusCenter.slot` is the one pure rule: refusal/offer always,
   receipt only with `leavesPage`, `receiptStyle` never consulted on `.phoneLine` (P-55-1 recorded
   PROVISIONAL); a dropped ordinary receipt leaves the standing line alone; Undo rides only the three
   existing roads (`MobileLine.Undo`: structural / Put back ×2 / unarchive) and the stale-Undo law is
   carried (`withdraw(owner:)`, pinned by `theNotesUndoNeverOutlivesItsMoment`; a stale press is
   covered by the undo door's own already-gone refusal, per AppSpec §9). Every silenced ordinary line
   is listed verbatim in the record for her call-back; P-55-11's directions were re-voiced through
   shared `isDirection` facts beside the words they class (no second copy of a rule).
9. **No rendered raw error** — solid. Branch grep finds only the three declared exemptions (two
   never-surfaced `MobileStarterJournal` lines, one `privacy:`-bearing Logger line); the scan pin's
   red-on-old (97 offenders) and the five per-case pins' old-text dumps are corroborated by
   `vm55-b2-last-c-pinred.log`. The pin's blind spots are honestly documented in its header.
10. **Editor-seam files** — solid. `MobileEditorViewModel` and `MobileStructural` changed only
    error-to-words expressions and `line:` class arguments on existing `report` calls; the one
    funnel change (`refuse(_:)` now routes through `report`) adds the `statusAction = nil` clear,
    which is the masthead `didSet` law's own behaviour, not a seam change. `Shared/EditorBrain/`,
    `MobileEditorTextView`, `BlockRangeIndex` untouched (file-level verified).
11. **Protection untouched** — solid. No file under `Features/Protection/` or `Shared/Protection/` in
    the diff; the two stale-doc observations are recorded for VM-103.

## Clean bill (beyond the foci)

- **The record's load-bearing claims verify.** Every stage verdict line quoted in the record matches
  the local logs byte-for-byte (251/32 and 13/3 for batch 1; 7 tests/16 issues for VM-62's red-on-old;
  949/161 with 2 failed and 537/74 with 1 failed for the shared window). The "69 sites across 23
  files" fix is real on the tip; the pbxproj claim (fs-synchronized groups, zero
  `membershipExceptions`) verified.
- **`MobileWingScope.follow`** — the once-per-wing discipline is correctly built: the losing child is
  cancelled AND awaited by the task group's scope exit, so a listing can never interleave two wings;
  `Observations`' initial emission closes the switch-during-handoff gap; a body ending on its own ends
  the follow exactly as the pre-VM-55 held observations did.
- **The search staleness guard** — the wing axis does NOT reopen the cancelled-search hole I went
  hunting for: `search` already filters `CancellationError` and clears `lastError` only on a landed
  search; the same-query/other-wing overwrite window is bounded by main-actor ordering and self-heals.
- **The wing door** — `pick` re-reads the store before acting, refuses a dead wing with the table's
  existing sentence through the handed-in phone road, files the capture draft only when the wing
  actually changes (P-55-18 pinned on a real box), and lands through the shared deliberate road
  (`goTo`, saying nothing — her ruling). The 44 pt target is real (negative-padding overlap, measured
  on the real roots with a fed status-bar inset), and the undoored line is byte-identical to batch 1's
  (`theLineReadsTheSameWithItsDoor`).
- **The overlay window** — passthrough hit-testing is correct both ways (door takes the touch, window
  returns nil elsewhere so lower windows get it); never key; the snapshot/lock/background edges are
  pinned (`MobileMessageLineSceneTests`, `MobileMessageLineHostTests`) and the home-indicator inset
  defect found in the window was fixed at the right layer (UIKit feeds `safeBottom`; the pure rule's
  inputs now driven by `MobileMessageLineInsetTests` at 34 and 0).
- **Sync-shape** — no schema, no Core, no trigger, no write outside the operations API anywhere in the
  diff; the one new "state" is the device-local wing memory (`UserDefaults`), which is 13i-d's
  established local-only class; the sync-tombstone fixture writes through `_sync_applying` exactly as
  an apply would.
- **Process** — commits carry no trailers; the branch touches no shared ledger; her mid-run rulings
  (the five-round cap, the interim door, P-55-11) are recorded verbatim with their supersessions; the
  PROVISIONAL set (P-55-1…18) is complete, each with options and the built choice, ready for the
  ratify list.

**Verdict: no new BLOCKER or MAJOR — on her rule ("a round that surfaces a new BLOCKER or MAJOR earns
the next"), round 1 closes the ladder once finding 1's two pending re-runs land green and findings
2/4/5/7's one-line record notes are carried into the ratify list / tickets at the orchestrator's
discretion.**
