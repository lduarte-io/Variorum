# VX-309 — LADDER ROUND 1: THE FIX LEG (Opus implementer, 2026-10-20)

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
- Piece 0 — this file: the dispositions below, written before any code: DONE (this commit).
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
  sentence ×3 hosts in two suites, VX-210's line); the pin's four guards (no delete offered; the twin standing ⇒ deletable,
  uncounted; the open library's far copy uncounted; a protected library's uncounted) green on both trees. With the fix
  `✔ Test run with 20 tests in 2 suites passed`. MUTATIONS on `789240c32` (each restored by `git checkout --`, `cmp`-identical
  to `scratchpad/r1fix-prerevert/CopyDoorsModel.swift`): M-R1a the twin-less arm dropped → `✘ … 2 issues` (the pre-fix
  behaviour red exactly); M-R1b the open/protected exclusion dropped → `✘ … 2 issues` (the protected guard + the open
  library's far copy counted); M-R1c the fence check dropped → `✘ … 1 issue` (the twinned pair counted). The words'
  red-on-old is the pre-fix run above (the old strings, 4 issues).
- Piece 5 — F-R2 (gatherings and entry dates named in T-8's confirm + the guide's twin sentence): FIX COMMITTED (this
  commit); pins first (the commit before) RED ON THE PRE-FIX TREE `✘ Test run with 13 tests in 1 suite failed after 0.049
  seconds with 3 issues.` (the lead's flip ×2 arms + the guide's new pin) → with the words `✔ Test run with 25 tests in 3
  suites passed` (U2WordsTests · OtherLibrariesDeleteRoadTests · PlaintextExportBringInRoadTests). MUTATION M-R2a (the
  guide's paragraph back alone — the two hosts drifting) STARTING on this committed tree — PENDING.
- Piece 6 — the close: evidence (the touched suites headless; the core protection set Debug + Release;
  `build-for-testing`; the phone; the Release build): NOT-STARTED.

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
