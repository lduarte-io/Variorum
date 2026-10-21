# VX-309 — LADDER ROUND 1: THE FIX LEG (Opus implementer, 2026-10-20)

**NOT DONE in this leg, first:** NO Mac suite RUN, no walk, no stage, no store, no network, no Linear, no subagent (the
brief) — the Mac-only assertion F-R4 added (`RoadIdleDialRouteTests`) and the Mac runs of the flipped suites are the
orchestrator's under the stage (the list below). F-R1's DELETE fence is NOT widened and no door is added to a twin-less
row (her option question). F-R2's date question (does an entry date ride T-8?) is NOT built — her QUESTIONS row. F-R5 is
record-only. No canon line, no QUESTIONS row, no ticket — the merging session's. Zero DISPUTES (nothing goes back to the
reviewer).

**Cast:** the round-1 fix leg under the cross-model flow (Fable reviewed, Opus implements): each finding of
`notes/plans/vx-309-ladder-round-1.md` gets an AGREE or a DISPUTE with my own traced reasoning; an AGREED finding is
fixed with its discipline (red-on-old pins where behaviour changes; deliberate pin flips where words change, each
mutation-checked where a mutation can run); a DISPUTE goes back to the reviewer through the orchestrator, unfixed.
**Hard limits:** headless + `build-for-testing` only; no stage, no store, no network, no Linear, no subagents; today's
road byte-unchanged; zero `Sync/`, `Server/`, schema, migration or dependency lines; `SyncSchema.lockstepVersion` 13.

**Read first, in full, myself:** the round-1 findings file whole; this phase's plan
`notes/plans/vx-309-copies-and-words.md` WHOLE (§0–§7, the four §6 unit records with their arbitrations and Mac
batches); CLAUDE.md + its auto-loaded canon; `notes/SessionResiliencyProtocol.md`; `notes/CastleRules.md` WHOLE (+ the
considered-and-not-pursued ledger); `notes/SurfaceContracts.md` (The app · Doors — portability + Library protection);
the code each finding names (`Assess/OwnCopies.swift`, `Assess/Catalog.swift`, `CopyDoorsModel.swift` whole,
`ProtectionCopyDoors.swift`'s listing and protected set, `ProtectionWords.swift`'s U1b/U1c/guide sections,
`Operations+PlaintextExportImport.swift`'s plan, `Operations+DocumentImport.swift`'s mint, `Domain/VariorumDocument`'s
`Document`, `StorePlaintextExport.swift` + `SyncSchema.localOnlyTables`, `Executor/Acts/Copies.swift`'s header,
`CapabilityRegistry.swift`'s `always` declarations + `Capability.unavailableNote`'s consumers, `EditorCommands`'s
Lock Library Now call site, `RoadCrossingSheet.swift`'s section) and their pins (`OtherLibrariesDeleteRoadTests`,
`U2WordsTests`, `RoadIdleDialRouteTests`, `CopyDoorsModelTests`' `PlantCatalog`). `notes/SyncSpec.md` NOT read: no
finding touches sync, custody or a schema (the one core file touched is a comment line).

## LIVE STATUS (per piece; PENDING = unverified)
- Piece 0 — this file: the dispositions below, written before any code: DONE (`d508136ff`).
- Piece 1 — F-R3 (the stale header line): DONE (`3963de6c6`) — comment only; `swift build` green.
- Piece 2 — F-R4 (the dead `unavailableNote`): DONE (`c2909d98a`) — `unavailableNote: ""` + the comment; the Mac pin
  `RoadIdleDialRouteTests.lockLibraryNowIsOneDeclarationTheMenuAndThePaneRender` gains `unavailableNote.isEmpty` (BUILT;
  its run the orchestrator's under the stage — red on the old tree by construction: the literal was non-empty).
- Piece 3 — F-R6 (the case-sensitive `.sqlite` suffix): DONE (pin first `fb33935f8` · fix `c388a0619`). Pin `OtherLibrariesDeleteRoadTests.theLineCountsALibraryShapedFileWhateverTheCaseOfItsSuffix`
  RED ON THE PRE-FIX TREE `✘ Test run with 6 tests in 1 suite failed … with 1 issue.` (`0 ≠ 2`) → green `✔ Test run with 6
  tests in 1 suite passed`.
- Piece 4 — F-R1 (the twin-less far copy: never deleted, now SAID): DONE (pins first `fce59feae` · fix `789240c32`). Pins
  RED ON THE PRE-FIX TREE `✘ Test run with 20 tests in 2 suites failed after 0.533 seconds with 6 issues.` — the behaviour
  pin `OtherLibrariesDeleteRoadTests.aFarPairNoContainerTwinVouchesForIsSaidAndNeverDeleted`'s 2 (`unmanagedCopies == 1`
  with the library open, and with none open — the reviewer's red, reproduced) + the 4 deliberate word flips (the staying
  sentence's singular in both suites and its plural, new; VX-210's line); the pin's four guards (no delete offered; the twin standing ⇒ deletable,
  uncounted; the open library's far copy uncounted; a protected library's uncounted) green on both trees. With the fix
  `✔ Test run with 20 tests in 2 suites passed`. MUTATIONS on `789240c32` (each restored by `git checkout --`, `cmp`-identical
  to `scratchpad/r1fix-prerevert/CopyDoorsModel.swift`): M-R1a the twin-less arm dropped → `✘ … 2 issues` (the pre-fix
  behaviour red exactly); M-R1b the open/protected exclusion dropped → `✘ … 2 issues` (the protected guard + the open
  library's far copy counted); M-R1c the fence check dropped → `✘ … 1 issue` (the twinned pair counted). The words'
  red-on-old is the pre-fix run above (the old strings, 4 issues).
- Piece 5 — F-R2 (gatherings and entry dates named in T-8's confirm + the guide's twin sentence): DONE (pins first
  `92bb95a55` · fix `23a76bc6f`). Pins RED ON THE PRE-FIX TREE `✘ Test run with 13 tests in 1 suite failed after
  0.049 seconds with 3 issues.` (the lead's flip ×2 arms + the guide's new pin) → with the words `✔ Test run with 25 tests in
  3 suites passed` (U2WordsTests · OtherLibrariesDeleteRoadTests · PlaintextExportBringInRoadTests). MUTATION on `23a76bc6f`
  (restored `cmp`-identical to `scratchpad/r1fix-prerevert/ProtectionWords.swift`): M-R2a the guide's paragraph back alone
  (the two hosts drifting) → `✘ Test run with 13 tests in 1 suite failed … with 1 issue.`
- Piece 6 — the close: DONE (this commit; it changes only this file). Every run on the final code tree `23a76bc6f`:
  - HEADLESS HARNESS (the scratchpad `u1-harness`, pointed at this worktree, `--skip-update`): **`✔ Test run with 347 tests
    in 57 suites passed after 6.242 seconds.`** (the U2 close's 345/57 + 2: F-R6's and F-R1's new pins; the flips edit
    existing tests).
  - CORE: the protection set (the 90 `@Suite` types under `Tests/VariorumCoreTests/Protection`, re-derived by
    `protection-filter.py`, + `PassphraseStrengthTests` — U2's filter) Debug **`✔ Test run with 385 tests in 91 suites
    passed after 6.002 seconds.`**; Release (`swift test -c release`, the same filter) **`✔ Test run with 361 tests in 87
    suites passed after 4.211 seconds.`** — both the U2 close's counts exactly (the one core line here is a comment).
  - `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
    -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → **`** TEST BUILD SUCCEEDED **`** (no
    warning in a touched file); the phone (`-scheme VariorumMobile -destination "generic/platform=iOS Simulator"
    -derivedDataPath DerivedData/vx309-mobile … build`, U2's command) → **`** BUILD SUCCEEDED **`**; the Release check
    (`-configuration Release -derivedDataPath DerivedData/vx309-release … build`) → **`** BUILD SUCCEEDED **`**.
  - The leg's diff (`git diff 99bf2c260 --stat`): 8 files — `CopyDoorsModel.swift`, `ProtectionWords.swift`,
    `CapabilityRegistry.swift`, `Executor/Acts/Copies.swift` (comment), three test files, this record. Zero `Sync/`,
    `Server/`, schema, migration or dependency lines; `SyncSchema.lockstepVersion` 13.
- No revert is in flight (every mutation ran on a committed tree and was restored by `git checkout --`, `cmp`-identical to
  `scratchpad/r1fix-prerevert/`; `git status` clean at the close).

## THE LINES AS BUILT (for round 2 — every one PROVISIONAL P-VX309-R1-1 / the P-VX309-U2-10 class)
- `CopyDoorsListing.unmanagedCopies(in:libraryID:protected:)` (`CopyDoorsModel.swift`; `make` passes the open library and
  the protected set): foreign `.sqlite` case-folded (F-R6) + every copy no key file names + every `.unattributed` far copy
  (unchanged) + (F-R1) a `.mac8` far copy of a library that is neither `libraryID` nor `protected` that
  `OwnCopies.isThisMacsCopy` does not claim. `OwnCopies` UNTOUCHED — the delete fence is exactly as it was.
- VX-210's line (`ProtectionWords.copiesElsewhereLine` — both listings and the guide's lesson 3): *Copies outside the folders
  Variorum keeps — older backups, or a folder you made — are left as they are, and so are copies in your second folder that
  this Mac can't vouch for as its own. They're yours to manage in the Finder.* ("second folder" — Data Safety's own name for
  the picked folder; the device through `ProtectionCopy.deviceName`.)
- The delete confirm's staying sentence (`deleteCopiesLead`): *One copy another Mac made, or that this Mac can't vouch for,
  stays.* / *N copies another Mac made, or that this Mac can't vouch for, stay.*
- T-8's one line (`bringInLead`): *… come in, written fresh; its gatherings, entry dates, commits, comments, note versions,
  book settings, stars and shelves don't.* — and the guide's plain-text paragraph: *… written fresh; its gatherings, entry
  dates, commits, comments, note versions, book settings, stars and shelves stay behind.*
- `.lockLibraryNow`: `unavailableNote: ""` (+ the comment); `Copies.swift`'s header: *A PLAINTEXT EXPORT carries no library
  ID: `protection_record` is local-only and `StorePlaintextExport` drops it. Brought in, it is a NEW library (VX-309 T-8 —
  the import road, never this file's acts).*
- Release / today's road: unchanged in behaviour — the listing, its line, the delete confirm, T-8's door and the guide's
  new-road chapter render only on the new road; `.lockLibraryNow`'s note was never spoken on either road.

## THE FIX-LEG MAC DELTA — RUN (the orchestrator, 2026-10-20 02:20–02:40 MDT, stage claim `vx-309-fixleg-mac`,
the coordinator's GO; log `/tmp/vx309-fixleg-mac.log`, deleted at closeout): suite types verified first (no
phantoms); `✔ Test run with 97 tests in 16 suites passed` — zero reds. F-R4's revert (the old literal back on
`.lockLibraryNow`) → `RoadIdleDialRouteTests.lockLibraryNowIsOneDeclaration…` RED (1 issue), restored
`cmp`-identical, status clean; the confirming re-run `✔ 2 tests in 1 suite`. 0 instances; the stage released.

## THE MAC SUITES FOR THE ORCHESTRATOR (under the stage; from `App/Variorum/`; PENDING)
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309 test \
  -only-testing:VariorumTests/RoadIdleDialRouteTests \
  -only-testing:VariorumTests/OtherLibrariesDeleteRoadTests \
  -only-testing:VariorumTests/U2WordsTests \
  -only-testing:VariorumTests/OtherLibrariesDeleteRouteTests \
  -only-testing:VariorumTests/CopyListingFacesSurfaceTests \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/PlaintextExportBringInRoadTests \
  -only-testing:VariorumTests/PlaintextExportBringInRouteTests \
  -only-testing:VariorumTests/TutorialNewRoadChapterTests \
  -only-testing:VariorumTests/TutorialPrivacyChapterTests \
  -only-testing:VariorumTests/CapabilityRegistryTests \
  -only-testing:VariorumTests/HelperCurrencyTests \
  -only-testing:VariorumTests/CommandRouterTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/DeadVocabularyTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The suite TYPES were checked against the files before this list was written (the U2 batch's lesson — no phantom names).
The first is the one Mac-only assertion this leg added (F-R4); the next two are this leg's headless suites (green in the
harness); then the suites over the touched files — the listing's faces and roads, the doors' brain, T-8's road and route
(the lead's hosts), the guide's new-road chapter (lesson 3 carries VX-210's line, lesson 3's last paragraph the T-8 list),
the registry walks and the router (the note), and the copy scans over `ProtectionWords`. **RED-ON-OLD for F-R4's assertion
(the orchestrator's, from a committed tree, restored by `git checkout --`):** (R-R4) in `CapabilityRegistry.swift`,
`.lockLibraryNow`'s `unavailableNote: ""` back to the old literal → `RoadIdleDialRouteTests
.lockLibraryNowIsOneDeclarationTheMenuAndThePaneRender` RED (1 issue).

## MOBILE PARITY
NOTHING MOBILE-VISIBLE: no phone face reads `copiesElsewhereLine`, `deleteCopiesLead`, `bringInLead`, `guideCopiesLesson` or
`unmanagedCopies` (grep over `VariorumMobile/` empty); the phone's guide edition (`MobileTutorialSeeder`) is its own; the
shared files compile for iOS (the phone build green).

## TALLY
**6 findings: 6 AGREED, 0 DISPUTED. FIXED: F-R1 (honest-words arm, PROVISIONAL — the fence unwidened), F-R2, F-R3, F-R4,
F-R6. RECORD-ONLY: F-R5.** Pins: 2 new (F-R1, F-R6) + 1 extended (F-R2's guide arm) + 1 Mac assertion (F-R4); 6 deliberate
word flips (F-R1 ×4, F-R2 ×2). Mutations: M-R1a..c, M-R2a — all red, all restored identical. PENDING: the Mac run above (the
orchestrator's, under the stage).

## THE DISPOSITIONS (each my own trace; AGREE ⇒ fixed below, DISPUTE ⇒ back to the reviewer unfixed)

### F-R1 · MINOR · AGREE — the twin-less far copy of another library: listed, never deletable, and nothing said it
**My trace (inputs → wrong state).** `OwnCopies.isThisMacsCopy` (`Assess/OwnCopies.swift:71-82`) claims a `.farFolder`
copy only when a CONTAINER backup of the same library stands under the same `Backups/<library8>/<mac8>` subfolder.
Planted: library X's far pair, key-filed, under `<x8>/<xmac8>`, with no container copy of X. Then
`CopyDoorsListing.make` lists it (its key file names X — `CopyDoorsModel.swift:102`); `deleteChoices` finds
`OwnCopies.thisMacsCopies(ofLibrary: X)` empty and skips X (`:120`), so no row of X carries *Delete…*; and
`unmanagedCopies(in:)` (`:138-141`) counts only foreign `.sqlite`, `library == nil` copies and `.unattributed` far
copies — X's row is key-filed AND `.mac8`-attributed, so it counts nowhere. Visible, door-less, unsaid. The reviewer's
road to it is real (X's delete pressed while the second folder is unplugged: `ProtectionCopyDoors.deleteCopies` reads a
fresh catalogue holding only the container, deletes those, and the far pairs come back twin-less on remount). **A road
the review did not name, which makes this the NORMAL state rather than a leftover:** two Macs sharing one second folder
(iCloud Drive — VX-302's own case), each with its own library — Mac B's pairs of its library Y sit under `<y8>/<bmac8>`
and every listing on Mac A shows Y's rows with no door and no line, from the first day. Same mechanism, same fix.
**The fence stays as it is** — the reviewer's option (a) is rightly "likely wrong": the `<mac8>` a twin-less pair is
filed under may be another Mac's (rule 23 — a device ID is per library per Mac, and the subfolder alone cannot tell this
Mac's former one from another's), and rule 19's own fence ("this Mac's copies of it only, never another Mac's") is what
"never delete what might be another Mac's" means. **The OPTION QUESTION goes to her bundle** (for the orchestrator's
list): (a) widen the delete fence (rejected here as unsafe without her word); (b) the honest-words arm — BUILT
PROVISIONAL (below); (c) a door on such a row naming it "a copy in your second folder this Mac can no longer vouch
for" (the reviewer's recommendation — a delete of what might be another Mac's, so hers alone).
**The fix (the brief's honest-words arm — PROVISIONAL, P-VX309-R1-1):** the twin-less, key-filed far copy of a library
whose delete question is live (neither the open library nor a protected one — their rows are the restore list's and the
empty-slot landing's, never rule 19's) joins VX-210's ONE line's count; the line gains the clause that keeps it true of
it (it IS inside a folder Variorum writes); `deleteCopiesLead`'s staying sentence gains the reviewer's "can't vouch for"
clause (an `.unattributed` far copy's maker is not knowable — "another Mac made" was not true of it). The row stays
delete-less. Pins below.
**A related observation, not built (the orchestrator's to route):** the listing's second heading reads *Other
libraries on this Mac* (`ProtectionWords.otherLibrariesHeading`) over rows that, in a shared second folder, another Mac
made — the line built here says why they stay, but the heading's "on this Mac" is loose for them. Words only; her
bundle's words pass or a ticket.

### F-R2 · MINOR · AGREE — T-8's confirm omits gatherings and entry dates
**My trace.** `PlaintextExportReading.plan` (`Operations+PlaintextExportImport.swift:113-174`): the notes fetch reads
`entry_date` ONLY into `DisplayTitle.note(…)`'s fallback title (`:134`); `importPlaintextExport` mints every note through
`importDocument`, whose `Document` carries title, tag paths and blocks only (`Domain/VariorumDocument.swift:137-148`) and
whose mint passes `entryDate: nil` (`Operations+DocumentImport.swift:290`) — so every brought-in note has a fresh
creation stamp and no entry date (a journal loses its days and their order; an untitled entry keeps its day only as its
fallback title). Books are fetched `kind IN ('book','curated')` (`:154`), so gatherings never ride (ruling item 6 —
correct). Both are the ruling's letter; neither is in the one line her confirm says (`bringInLead`). **The fix:** one
clause naming gatherings and entry dates among what doesn't come in (the as-drafted pins flip deliberately, the
P-VX309-U2-10 class), AND the guide's plain-text paragraph (`guideCopiesLesson`'s last — the U2 record: it "follows the
lead's list") takes the same two words, so the two hosts of one list never drift. **For the orchestrator's bundle list:**
the reviewer's QUESTIONS row — is a note's entry date "content" the rescue door should carry (the format would need a
date token — 13m's full-fidelity tier, or one header token now)? Not built.

### F-R3 · NIT · AGREE — `Copies.swift:16`'s stale header line
**My trace.** `StorePlaintextExport` drops `SyncSchema.localOnlyTables` inside the export
(`Persistence/StorePlaintextExport.swift:40,64-66`), and that set names `protection_record`
(`Sync/SyncSchema.swift:369`) — the export carries no library ID. **The fix:** the line says what is true (a comment
only; routed to this ladder by the U1b arbitration).

### F-R4 · NIT · AGREE — `.lockLibraryNow`'s dead `unavailableNote`
**My trace.** `availability: always`, and nothing speaks the note: `.lockLibraryNow` is not a `RoutedCommand` (so
`CapabilityRegistry.unhandledNote` never maps to it), and no call site reads `capability(.lockLibraryNow)
.unavailableNote` — the menu calls `bootstrap.lock()` directly behind `canLock` (`EditorCommands.swift:560-566`), the
pane's button calls `model.lockNow()` (`RoadCrossingSheet.swift:270`). The registry's own idiom for a directly-wired,
always-acting door is the EMPTY note (`.mcpSettings`, `.newPost`, `.findAnything`, `.importFiles`, `.exportLibrary`,
`.helper`, `.takeTour` …). **The fix — the smaller true change:** the note becomes `""` (no constant to make — nothing
is kept), the declaration's comment says why, and the declaration's Mac pin gains the one assertion.

### F-R5 · NIT · AGREE — RECORD-ONLY (no code)
The pane's subline literal *⌃⌘L does the same from anywhere.* is a third spelling of the chord beside the menu's
`.keyboardShortcut` and the declaration's deliberate absence of a `shortcutLabel` (P-VX309-U1c-4, accepted at the U1c
arbitration — Release parity). When VX-329 takes P-VX309-U1c-4's (b) arm (declare `shortcutLabel: "⌃⌘L"` + the ⌘/
helper row), this literal folds into the declaration's label. For the orchestrator: a line on VX-329's comment beside
P-VX309-U1c-4's (b) arm. Nothing built.

### F-R6 · NIT · AGREE — the foreign arm's case-sensitive `.sqlite`
**My trace.** `CopyDoorsListing.unmanagedCopies` filters `catalog.foreign` by `$0.name.hasSuffix(".sqlite")`; a foreign
`OLD.SQLITE` (a hand-renamed file, a case-preserving volume) is library-shaped and still not counted, so the one line can
stay unrendered over it. **The fix:** `lowercased()` before the suffix test (a sidecar `….SQLITE-wal` still never
counts); a small pin, red-on-old.

## PROVISIONALs (for the orchestrator's bundle)
- **P-VX309-R1-1 — F-R1's honest-words arm:** the twin-less, key-filed far copy of a library whose delete question is
  live joins VX-210's line's count; the line's clause and the staying sentence's clause as built (Piece 4's lines);
  (a) BUILT; (b) a door on the row with the "can no longer vouch for" confirm (the reviewer's (c) — hers); (c) widen the
  fence (the reviewer's (a) — unsafe: the `<mac8>` may be another Mac's).

## FOR THE ORCHESTRATOR'S BUNDLE LIST (not built here)
- F-R1's OPTION QUESTION (above) + the heading observation.
- F-R2's QUESTIONS row: a note's entry date through T-8 (content or configuration?).
- F-R5: the VX-329 comment line.
