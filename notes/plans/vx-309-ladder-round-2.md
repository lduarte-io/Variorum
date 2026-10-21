# VX-309 — LADDER ROUND 2 (fresh cold reviewer, Fable at xhigh; 2026-10-20)

**Scope (the ladder's rule):** re-review the ROUND-1 FIXES — the fix leg's diff `99bf2c260..a87250459` (8 files:
`CopyDoorsModel.swift`, `ProtectionWords.swift`, `CapabilityRegistry.swift`, `Executor/Acts/Copies.swift` comment,
three test files, the fix record) against `notes/plans/vx-309-ladder-round-1.md` (6 findings) and
`notes/plans/vx-309-ladder-round-1-fixes.md` (6 AGREED / 0 DISPUTED; F-R1/R2/R3/R4/R6 fixed, F-R5 record-only) —
with any new BLOCKER/MAJOR in scope. Spec anchors read myself: REVIEW_PROMPT.md; the phase plan's §6 U1c and U2
records (VX-210's line, rule 19's delete, T-8's words) and the fix record whole; CastleRules rules 19, 23, 25, 26;
every diff hunk read line by line; the traced mechanisms below are my own, never the records'.

**My own verification (headless only; this worktree never modified):**
- **Green on the final tree (my run):** the fix leg's surviving scratchpad harness (`u1-harness`, symlinked at this
  worktree), `swift test --skip-update --filter "OtherLibrariesDeleteRoadTests|U2WordsTests|PlaintextExportBringInRoadTests"`
  → `✔ Test run with 25 tests in 3 suites passed` — F-R1's behaviour pin, F-R6's case pin, and every flipped word pin
  among them.
- **Red-on-old reproduced myself:** a scratch COPY of the harness (in my scratchpad, outside this worktree) with the
  two fix-touched sources (`CopyDoorsModel.swift`, `ProtectionWords.swift`) replaced by their `99bf2c260` (pre-fix)
  contents and the NEW tests kept → `✘ Test run with 20 tests in 2 suites failed … with 10 issues`, exactly the
  claimed places: F-R1's behaviour pin 2 issues (`unmanagedCopies == 1`, both arms), F-R6's pin 1 issue (`0 ≠ 2`),
  the word flips 7 (staying sentence ×3 across both suites, VX-210's line, `bringInLead` ×2 arms, the guide pin) —
  and the F-R1 pin's four guards (no delete offered; twin standing ⇒ deletable, uncounted; the open library's and a
  protected library's far copies uncounted) GREEN on the old sources, as the fix record claims. Scratch copy removed
  after.
- Final-tree builds, my own runs, recorded below under THE RUNS.

**STATUS: COMPLETE — verdicts final (this file is the round's record).**

---

## Verdicts

### F-R1 (MINOR — the twin-less far copy: listed, never deletable, nothing said) — **CONFIRMED CLOSED**

The fix is the brief-permitted honest-words arm, the fence deliberately unwidened — exactly the round-1 fix shape's
(b)+rider, PROVISIONAL P-VX309-R1-1 with the option question routed to her bundle. My own trace of the mechanism:

- `CopyDoorsListing.unmanagedCopies(in:libraryID:protected:)` (`CopyDoorsModel.swift:147-155`): the old arms intact
  (foreign `.sqlite`, `library == nil`, `.farFolder` + `.unattributed`), plus the new arm — a key-filed, `.mac8`
  far copy counts iff `library != libraryID && !protected.contains(library) && !OwnCopies.isThisMacsCopy(copy, in:)`.
  `OwnCopies` itself UNTOUCHED (diffed — the delete fence is byte-identical), so rule 19's "never delete what might
  be another Mac's" stands; rule 23's reasoning (the `<mac8>` alone cannot tell this Mac's former ID from another
  Mac's) makes the unwidened fence the right call — I agree with the implementer's rejection of round 1's option (a).
- The one production call site (`ProtectionCopyDoors.listing`, `:100`) passes `libraryID` and
  `protectedFromDelete(ctx)`: library open ⇒ `[open]`; no library, slot empty ⇒ the remembered set; slot occupied
  (rule 27's lobby) or a failed read ⇒ EVERY library — so in the lobby the new arm counts nothing, consistent with
  the lobby offering no delete on any row (P-VX309-U1c-2's own scope). The pin covers the open, none-open and
  protected arms; both faces of the honest line (`CopyDoorsSheet:94` empty-slot listing, `:292` Data Safety's
  restore section) render the ONE `copiesElsewhereLine`, and the guide's lesson 3 INTERPOLATES that same constant —
  one source, no drift possible for this line.
- Catalog semantics verified against `Catalog.build` / `location(of:)` / `mac(_:_:)`: a far pair under
  `Variorum/Backups/<lib8>/<mac8>` parses to kind `.backup`, `mac8` attribution, library from its key file; one pair
  = ONE `CatalogCopy` row (the key file goes to `keyFiles`), so the count's unit is the pair — the pin's `== 1` means
  what it says. `backupSubfolder` compares the whole lowercased `Backups/<lib8>/<mac8>` prefix, so the twin check is
  per library per Mac, as rule 23 wants.
- Words: `deleteCopiesLead`'s staying sentence and `copiesElsewhereLine`'s second clause are true of the newly
  counted class and of the `.unattributed` class (both sit in the second folder); flips deliberate, mutation-checked
  (M-R1a..c red in the surviving logs), red-on-old reproduced myself (above). All words PROVISIONAL for her bundle.

### F-R2 (MINOR — T-8's confirm omits gatherings and entry dates) — **CONFIRMED CLOSED**

- Both hosts of the one list updated: `bringInLead` ("…its gatherings, entry dates, commits, comments, note
  versions, book settings, stars and shelves don't.") and the guide's plain-text paragraph ("…stay behind") — and a
  NEW pin holds the guide's host so the two cannot drift (mutation M-R2a: the guide alone reverted → red; log
  verified). Red-on-old reproduced myself (3 issues: both lead arms + the guide pin).
- The mechanism's truth re-verified: `PlaintextExportReading.plan` fetches books `kind IN ('book','curated')` (no
  gathering rides — ruling item 6) and reads `entry_date` only into the fallback title; `importDocument` mints with
  `entryDate: nil` — so the two named losses are real and the line now says them. Grepped for any third host of the
  list ("book settings, stars and shelves"): exactly the two, both flipped. The date QUESTIONS row is correctly NOT
  built (her bundle's — the fix record routes it).

### F-R3 (NIT — the stale header line) — **CONFIRMED CLOSED**

`Copies.swift:16-18` now says the truth; verified myself: `SyncSchema.localOnlyTables` names `protection_record`
(`SyncSchema.swift:369`) and `StorePlaintextExport` drops `localOnlyTables` (`StorePlaintextExport.swift:40,64`).
Comment only; no pin owed.

### F-R4 (NIT — the dead `unavailableNote`) — **CONFIRMED CLOSED**

`unavailableNote: ""` with the explaining comment. My own trace of "no reader": `.lockLibraryNow` is not a
`RoutedCommand` case (`Capability.swift:107ff` — block/take-targeted dispatches only), so `unhandledNote` can never
map to it; its only call sites are the File menu's direct `bootstrap.lock()` behind `canLock`
(`EditorCommands.swift:560-566`) and the pane's `model.lockNow()` (`RoadCrossingSheet.swift:270`); no site reads
`capability(.lockLibraryNow).unavailableNote`. The empty note is the registry's standing idiom for directly-wired
`always` doors (12+ precedents, `unavailableNote: "", availability: always`). Checked that no Mac suite walks ALL
declarations asserting non-empty notes (the non-empty assertions are per-capability-set — formatting, trash,
comments…; none touches `.lockLibraryNow`), so the orchestrator's pending Mac run cannot trip on the "". The added
assertion `capability.unavailableNote.isEmpty` (`RoadIdleDialRouteTests:54`) is red-on-old by construction (the old
literal was non-empty) — honest, and the run is correctly listed as the orchestrator's under the stage. **While this
round ran, the orchestrator's Mac delta landed (`8db8bfec3`): the 16-suite batch green (97/16) and F-R4's
red-by-revert verified on the Mac host — read after it landed; it confirms, and changes, nothing above.**

### F-R5 (NIT — the ⌃⌘L third spelling) — **RECORD-ONLY DISPOSITION SOUND**

The literal still stands (`RoadCrossingSheet.swift:273`), deliberately — P-VX309-U1c-4's accepted arm bought Release
parity at this price, and nothing in this leg was owed. The routing (a line on VX-329's comment beside the (b) arm,
the orchestrator's) is right. Nothing to re-check in code.

### F-R6 (NIT — case-sensitive `.sqlite` suffix) — **CONFIRMED CLOSED**

`$0.name.lowercased().hasSuffix(".sqlite")` (`CopyDoorsModel.swift:148`); a sidecar `.SQLITE-wal` still never counts
(lowercased it ends `-wal`). Pin red-on-old reproduced myself (1 issue, count 0 ≠ 2); green on the final tree in my
own run.

---

## New findings

**No BLOCKER, no MAJOR, no MINOR.** One observation, routed rather than found against the fix:

- **OBS-R2-1 (words, pre-existing — for her P-VX309-R1-1 bundle, not a reopen):** `unmanagedCopies`' oldest arm
  (`library == nil`) also counts a CONTAINER-place copy whose key file doesn't read (rule 26's unlisted class —
  e.g. an adoption-safety copy with undecodable key bytes). Neither of `copiesElsewhereLine`'s clauses describes
  that one ("outside the folders Variorum keeps" — it is inside; "in your second folder" — it is in the container).
  This predates the fix leg (the old arm and the old sentence had the same gap) and the fix's new clause is true of
  everything the fix ADDED to the count, so F-R1 stays closed; since P-VX309-R1-1 already puts this line's words in
  her bundle, the bundle sitting can take this clause gap in the same breath. Words only; no pin owed beyond the
  existing line pins that would flip deliberately.

---

## Clean bill (checked and found solid, beyond the six)

1. **Scope and parity:** the fix diff holds zero `Sources/VariorumCore/Sync/`, `Server/`, schema, migration or
   dependency lines (the one core file is `Protection/Executor/Acts/Copies.swift`, comment-only — diffed);
   `SyncSchema.lockstepVersion` untouched; every changed string renders only behind new-road gates (the listing
   faces, the guide's new-road chapter), so today's road — Release included — keeps its behaviour.
2. **No silent semantic shift in the old arms:** the pre-existing pin `theLineCountsTheCopiesVariorumLeavesAsTheyAre`
   (== 6) still passes with the new signature's defaults, and the old arms are byte-equivalent in effect (traced:
   `library == nil` any-place, `.farFolder`+`.unattributed`) — only the deliberate F-R1/F-R6 additions changed counts.
3. **The F-R1 pin's planted world is faithful:** `PlantCatalog.backup` builds real pairs (key file bytes decode), the
   test's `far()` preserves the `Backups/<lib8>/<mac8>` folders under `.farFolder`, and `Catalog.build` attributes
   them exactly as the lister would — the pin tests the production classification path, not a stub.
4. **No unflipped host anywhere:** grepped every test and source for the old strings ("another Mac made" bare, the
   old `copiesElsewhereLine`, the old bring-in list) — none remains outside the flipped pins; no Mac-only suite pins
   the old words, so the orchestrator's pending Mac batch has no known red waiting beyond its purpose (F-R4's
   assertion run).
5. **The fix record's claims vs. the surviving evidence:** the fix leg's scratchpad logs (r1fix-r1-red/green,
   r1fix-r6-red/green, r1fix-r2-red/green, r1fix-m-r1a..c, r1fix-m-r2a, r1fix-harness-all at 347/57) all end exactly
   as the record states; my own independent runs agree where I re-ran them.
6. **Dispositions and routing:** 6 AGREED / 0 DISPUTED is honestly recorded; the not-built list (the fence, the date
   question, F-R5, canon/QUESTIONS/tickets) matches the brief's allocation to her bundle and the merging session.

## THE RUNS (my own, final tree `a87250459`)

- Harness, fix-touched suites: `✔ Test run with 25 tests in 3 suites passed` (above).
- Harness, whole: `✔ Test run with 347 tests in 57 suites passed after 5.994 seconds.` — the fix leg's count exactly.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx309
  -skipPackageUpdates -onlyUsePackageVersionsFromResolvedFile build-for-testing` → `** TEST BUILD SUCCEEDED **`
  (the Mac pins — `RoadIdleDialRouteTests`' new assertion included — compile; their run stays the orchestrator's
  under the stage, as listed in the fix record).

## Tally

**6/6: F-R1, F-R2, F-R3, F-R4, F-R6 CONFIRMED CLOSED · F-R5 record-only disposition SOUND. 0 REOPENED. 0 new
findings (one routed words observation, OBS-R2-1, for the P-VX309-R1-1 bundle).**
