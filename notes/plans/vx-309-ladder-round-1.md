# VX-309 — LADDER ROUND 1 (cold review, Fable at xhigh; 2026-10-20)

**Reviewer:** fresh `fable-reviewer`, zero implementation context, running `notes/REVIEW_PROMPT.md` verbatim
({PHASE} = VX-309). **Subject:** the whole phase diff `git diff d3bb6a791..HEAD` on `vx-309-copies-and-words`
(105 files, ~10k insertions). **Read in full before the code:** CastleRules.md WHOLE (+ the
considered-and-not-pursued ledger) · SyncSpec.md WHOLE · SurfaceContracts.md WHOLE · the phase plan WHOLE
(§0–§7 and all four §6 unit records with their arbitrations and Mac batches) · KnownIssuesAndTechDebt.md ·
REVIEW_PROMPT.md. No "Review foci" section exists in the plan or beside it (checked). Read myself, never
delegated: every `Sources/` diff hunk (the custody lines whole), the app's protection diffs whole
(`ProtectionBackupPair`/`ProtectionBackupHook`, `FileBackupsLeaf`, `ProtectionCopyDoors`, `CopyDoorsModel`,
`AppBootstrap`, `ProtectionWords`, `ProtectionAccountActs`, `RoadAccountModel/Faces`, `ProtectionOpenFaces`,
`SetPassphraseModel`, `RoadCrossingsModel`/`ProtectionCrossingActs`/`RoadCrossingFaces`, `WordsBand`,
`PickedCopy`, `ProtectionRoadActs`, `ProtectionCopyCounts`, the sheets, Data Safety, the registry,
`TutorialSeeder`, `SettingsShape`/`AppSettingsView`, `VariorumApp`/`LibraryMissingView`/`StoreLockView`/
`LibraryOpenDoor`), the three notes-record edits (vx-191 / run-b-stress-pass / stargazing delta brief), and
the new test suites' claims against the record. Headless verification on the final tree:
`swift test --filter "JoinWordsMomentTests|KeyDoorOldPassphraseResumeTests|EmptySlotMakeMineTests|OtherLibrarysCopiesDeleteTests|OwnCopiesTests|RetentionTests|PlaintextExportImportTests|PassphraseStrengthTests|KeyDoorResumeTests"`
→ **47 tests in 10 suites passed**. Findings are written incrementally; severity per the prompt
(BLOCKER · MAJOR · MINOR · NIT), each with the traced mechanism and the pin that would go red on the current
tree, or honestly labelled.

**STATUS: COMPLETE — findings and clean bill final (this file is the round's record).**

---

## Findings

### F-R1 · MINOR · `Sources/VariorumCore/Protection/Assess/OwnCopies.swift:81-90` + `App/Variorum/Shared/Protection/CopyDoorsModel.swift` (`unmanagedCopies`) · an orphaned far pair of another library is listed but silently undeletable, and neither rule 19's door nor VX-210's honest line covers it

- **What:** `OwnCopies.isThisMacsCopy`'s `.farFolder` arm claims a far copy only when a CONTAINER copy of the
  same library stands under the same `Backups/<library8>/<mac8>` subfolder. When another library X has far
  pairs in the picked folder but **no container copy left**, X's far pairs are: (a) listed in both listings
  (`CopyDoorsListing.make` lists every catalogued copy whose key file names a library), (b) **never
  deletable** — `thisMacsCopies(ofLibrary: X)` is empty, so no `CopyDeleteChoice` exists and no *Delete…*
  renders (rule 19's letter is "listed **and can be deleted**"), and (c) **not counted by VX-210's line**
  (`unmanagedCopies` counts only `library == nil` copies and `.unattributed` far copies — these are
  attributed, key-filed rows). The copy is visible, undeletable, and nothing says why.
- **Evidence (inputs → wrong state):** the state is reachable without any Finder hand-work: press X's
  *Delete…* **while the picked folder is unplugged** (or its delete of a far file fails — logged and skipped
  by design, `ProtectionBackupHook`/leaf semantics). The fresh catalogue read at the press
  (`ProtectionCopyDoors.deleteCopies`) sees only the container copies; the act deletes them; the drive
  remounts; X's far pairs are now twin-less. From then on each listing shows X's rows with Look inside /
  Make this my library but no delete door and no honest line. (Also reachable by hand-deleting X's container
  `Backups/<x8>/` folder.) Traced from the code: the fence `OwnCopies.isThisMacsCopy` (container-twin
  requirement), `CopyDoorsListing.deleteChoices` (`guard !mine.isEmpty else { continue }`),
  `CopyDoorsListing.unmanagedCopies(in:)` (the two-arm filter).
- **Red-on-old pin:** plant X's far pair (key-filed, `<x8>/<xmac8>` subfolder) with no container copy of X →
  assert `listing.deleteChoice(for: xRow) != nil || listing.unmanagedCopies > 0` — red on the current tree.
- **Fix shape (for the implementer / her bundle):** the honest options differ in meaning, so the choice may
  be hers: (a) widen the delete fence — a far pair twin-less in the container is still deletable when **no
  other Mac could own it** (undecidable from the subfolder alone; likely wrong), (b) count the twin-less far
  copy into the one honest line's number (its sentence "copies outside the folders Variorum keeps" would
  then be false of it — it IS in Variorum's folder — so the line would need a clause), or (c) the smallest
  true fix: such a row renders *Delete…* with the confirm's count naming it as "a copy in your backup folder
  this Mac can no longer vouch for" — my recommendation is to put the OPTION QUESTION in the bundle and
  meanwhile at least stop the row from being silently door-less. A rider on the same mechanism:
  `deleteCopiesLead`'s staying sentence says "copies **another Mac made** stay" for every listed-but-not-
  deletable copy; for an `.unattributed` far copy (library known from its key file, no `<mac8>` subfolder)
  that claim is not knowable. One clause ("or that this Mac can't vouch for") makes it honest. The words are
  PROVISIONAL (P-VX309-U2-10), so this can fold into her words bundle.

### F-R2 · MINOR · `App/Variorum/Shared/Protection/ProtectionWords.swift` (`bringInLead`) + `Sources/VariorumCore/Operations/Operations+PlaintextExportImport.swift:137-160` · T-8's confirm omits two real losses: gatherings, and every note's worn date

- **What:** the ruling (§5b-R) binds the mechanism — "content and its placement ride; configuration does
  not", the boundary being what the document format can say — and requires "the confirm says so in one
  line". The built line names "its commits, comments, note versions, book settings, stars and shelves
  don't". Two things the user will actually miss are not named:
  1. **Gatherings** — a whole Bookcase object class (`kind='gathering'` is excluded by the books fetch,
     `WHERE kind IN ('book','curated')` — correct per ruling item 6), invisible in the don't-list ("book
     settings" does not read as "your gatherings").
  2. **Worn dates** — `Queries.variorumDocument` carries title + tagPaths + blocks only; `entry_date` is
     read by the planner **solely as a title fallback** (`DisplayTitle.note(...)`). Every note re-minted by
     `importDocument` has a fresh `created_at` and no `entry_date`: a journal brought in through T-8 loses
     every entry's worn day and its day ordering, silently (an untitled entry keeps the day only as its
     fallback TITLE). The mechanism is as ruled (the format cannot say dates), but the one line promises
     "notes … come in" without saying the days don't.
- **Evidence:** `PlaintextExportReading.plan` (the notes fetch and `fallback` use of `entry_date`);
  `importPlaintextExport` (no date rides); `bringInLead`'s don't-list. Traced, no pin needed for the words
  half (words finding); for the behavior half no fix is proposed — it is the ruling's letter — but the gap
  belongs in her bundle as a QUESTIONS row (is a worn date "content" the rescue door should carry? The
  format would need a date token — 13m's full-fidelity tier territory, or one header token now).
- **Fix shape:** one clause in `bringInLead` ("its gatherings, entry dates, commits, comments, …") — the
  as-drafted pins flip deliberately (the P-VX309-U2-10 class); plus the QUESTIONS row for the date question.

### F-R3 · NIT · `Sources/VariorumCore/Protection/Executor/Acts/Copies.swift:16` · the stale header line F-U1b-4, routed to this ladder, is still standing

- "// - A PLAINTEXT EXPORT carries its library ID." — false since `protection_record` became local-only
  (`StorePlaintextExport` drops it); the U1b arbitration routed it to "the ladder's NIT or the closeout's
  comment fix". Confirmed still present at line 16. One comment line; the closeout can take it.

### F-R4 · NIT · `App/Variorum/Variorum/Registry/CapabilityRegistry.swift` (`.lockLibraryNow`) · a dead, literal `unavailableNote`

- The declaration's availability is `always`, so `unavailableNote` ("Only a library in Castle locks — in
  Standard this Mac opens it again at once.") can never render — dead words — and it is a bare literal in
  the registry rather than a `ProtectionCopy`/`ProtectionWords` constant (the registry's own precedent is
  constants, e.g. `WingCopy.switchWingUnavailable`). Harmless; tidy at the next touch.

### F-R5 · NIT · `App/Variorum/Variorum/Features/Protection/RoadCrossingSheet.swift` (`RoadCrossingsSection`) · the ⌃⌘L chord is a third hardcoded spelling

- The pane's subline says "⌃⌘L does the same from anywhere." as a literal, beside the menu call site's own
  literal chord — with the declaration deliberately carrying no `shortcutLabel` (P-VX309-U1c-4, accepted at
  arbitration). That ruling bought Release parity at the price of the chord living outside the registry;
  this third spelling widens the drift surface by one. Record-only: when VX-329 takes P-VX309-U1c-4's (b)
  arm (declare the chord + helper row), this literal should fold into it.

### F-R6 · NIT · `App/Variorum/Shared/Protection/CopyDoorsModel.swift` (`unmanagedCopies`) · case-sensitive `.sqlite` suffix on the foreign arm

- `catalog.foreign.filter { $0.name.hasSuffix(".sqlite") }` misses `FOO.SQLITE`-cased files; the honest
  line's count would silently exclude them. Trivial; a `lowercased()` at the next touch. (No pin worth a
  fix cycle on its own — label honestly: cosmetic.)

---

## Dispositions of the records' own routed items (checked, not re-found)

The four unit records route a set of findings to tickets/her bundle; I re-read each against the code and
agree with the routing (no re-litigation, no silent drops found): F-U1a-1 (fixed as U1b piece 0 — the fix
is sound, see clean bill), F-U1a-2 (test trap — ticket), F-U1b-1/F-U1c-4 (Castle entry / delete leaves
quiet roads — genuinely her CastleRules call; the probe facts are recorded), F-U1b-7's writing-road arm
(ticket; the read-only arm verified fixed and pinned), F-U1b-8 (T-8 from Castle lands Standard — her
bundle; the lead says it plainly), F-U1c-3 (planned delete wedge class — ticket), F-U2-2 (hold banner's
hasAccount — ticket), F-U2-3 (Protection row blurb "escrow" — VX-234 comment), F-U2-4 (delta brief rewrite
— VX-329 comment), F-U2-6 (arm-10 pin reads file 12 — ticket). MAJOR-1's residue (1) for Change/Reset is
recorded, not built, as the brief ordered.

---

## Clean bill (load-bearing things specifically checked and found solid)

1. **VX-450 + F-U1a-1 (the resume rollback, `KeyDoors.swift` / `PlanRunner.resume`):** traced all arms —
   `resumeCannotFinish` guards `ctx.resuming` first (M-450c pins the press path), Change/Reset need the NEW
   passphrase and a live key file; `typedPassphraseOpensOnlyTheReplacedLock` answers false when the typed
   text opens a lock under the plan's descriptor (same-text re-choice after the key file lands finishes),
   true only when it opens an older-descriptor lock in the live file or this Mac's sealed mirror (M-0c pins
   the mirror load-bearing); the drop happens in `resume` only, before any write, and `drive`'s one
   rollback carries it. The synced twin's landed-vault-write consequence is honestly pinned. I also checked
   the floor-validation edge inside `opens` (a legacy below-floor descriptor would read "does not open" —
   unreachable on the new road, which wrote every file at current parameters).
2. **VX-456 (`wordsAreTheAccountsAlready`):** the quiet arm is provable exactly as claimed — no own words
   lock + the master's twelve-words copy byte-equal to the vault's recovery wrap (RFC 3394 deterministic,
   the copy IS the vault's bytes copied) + the master lock opening under the master the typed secret
   reached ⇒ the only words that open the library are the account's current words. The dangerous direction
   (quiet on a REAL replacement) is closed by each guard: an own words lock ⇒ speaks (M-456a); words
   changed elsewhere ⇒ byte identity fails (M-456b); master rotated ⇒ the master lock check fails
   (M-456c). The conservative first-device false-negative is recorded (P-VX309-U2-1). Reads only;
   `wordsReplaced` is the only effect. **Red-on-old reproduced myself** (see the note at the end).
3. **The far pair leg + retention (`ProtectionBackupPair`, `FileBackupsLeaf.landFarPair`, `OwnCopies`,
   `Retention.plan(now:)`):** one pair in two places under the same name; the due-check is the catalogue's,
   per library per Mac, over trusted stamps; a vanished picked folder is never re-made (the guard precedes
   the `createDirectory` of the SUBPATH only); write-once + verify + half-landed cleanup; MB-1's
   future-stamp slot rule holds in both places (`trusted` filters both the slot claim and the prune set;
   future-stamped and undated copies are kept and claim no slot); every `Retention.plan` call site passes
   an explicit clock (compile-enforced — no default `now`); the prune is one id per call with failures
   logged and skipped; the pair road is one-at-a-time under an `NSLock`; the pair's outcome stays the
   container's for every caller.
4. **VX-397 / Data Safety counts:** `ProtectionCopyCounts.read` → `OwnCopies.summary` per place; the pane's
   gate is `roadStanding` (nil on today's road ⇒ `refresh` assigns the flat reads byte-unchanged, and the
   counts are awaited BEFORE assigning, so no flash).
5. **T-5 (`makeThisMyLibraryInTheEmptySlot` core + app):** the slot and the live key file must be empty
   before anything is minted; the copy must open by the TYPED road (`openCopy` tries typed secrets before
   quiet roads — verified in `Copies.swift:352-396` — and both the preflight and the core act refuse
   `.quietRoad`); typed words become the words lock with no passphrase lock
   (`newLocks(passphrase: secrets.passphrase != nil, …)`); a typed passphrase lands on a fresh descriptor
   beside freshly minted words that are dropped unseen (redacted in `LandedCopy.description`); ONE plan
   sealed under the new key with the swap as commit point; `drive` persists step completion per step, so a
   post-swap resume runs only `MakeMineProgram.afterCommit` (the "appleKey" step is marked done pre-swap —
   no unknown-step gap in the registry resume); `ExecutorConfiguration` is a struct, so
   `configuration.libraryID` mutates only the act's own executor instance. Pre-swap keychain/staged-file
   debris is recorded (P-VX309-U1b-4) and flagged for her bundle by the arbitration — I weighed it and
   agree MINOR-recorded is right (Standard-posture container-internal, overwritten by the next landing).
6. **T-8 (`PlaintextExportReading` / `importPlaintextExport` / `landPlaintextExport`):** the read is on a
   private staged copy, schema-equality gated both directions; versions fenced by the classifier
   (`archived_at = created_at`); members `status='member'`, live posts only, `(position, id)`; notes are
   imported before books so intake cannot misfire (and the minted books are rule-less); archived books
   first with the name guard's archived-skip in mind, archived as they land; archived notes archived after
   memberships; wings minted only where content lands, tags adopting per wing (R-13ia-1 honored — no merged
   vocabularies); membership refusals counted, never thrown; `landed:` reports under `defer` so a thrown
   import still counts; the read-only-road refusal precedes the step-aside (F-U1b-7's fixed arm); the hold
   is carried aside with the outgoing library and cleared for the new one; the end log line + receipt name
   what landed vs. the pre-import "it holds" line (the ruling's crash-window requirement).
7. **VX-265 / F-U1c-1 / F-U1c-2:** the place-told fence is right (rule 23 — a device ID is per library per
   Mac, so the old `<mac8>`-comparison fence could never match another library's backups; the fix's pin was
   genuinely red-on-old per the record and the `CopyActTests` flip is a justified edit); the no-library act
   refuses over an occupied slot and never offers a remembered library; the aside-folder delete takes the
   key file, the hold and `.DS_Store` and keeps any file of hers, removing the folder only when empty; the
   open library's copies are never offered (double-fenced, app guard + act fence).
8. **VX-444 (`WordsCardLedger.carry`):** only standing marks carry; the outgoing library keeps its own;
   T-5 by typed words marks recorded, by passphrase marks nothing, T-8 marks nothing (the fresh-words offer
   stays). The claim "Make this my library keeps the current pair" is true of the standing act (the confirm
   types the current pair and the new library locks under it), so the carry is semantically sound.
9. **VX-451:** the dial writes THIS MAC's sealed `idleLockMinutes` through `changeSettings` on the open
   session (never UserDefaults), Castle-only with the write refusing outside Castle; Lock Now is the
   bootstrap's one `lock()`; the registry declares `.lockLibraryNow` once with today's exact verb
   (`ProtectionCopy.lockNowLabel` == "Lock Library Now", checked) and no `shortcutLabel`, so Release's File
   menu renders the same words and no helper row appears.
10. **VX-454:** `rereadPassphrase` only ever retires, runs first at `refreshPane` and at the account
    `landed` chain (which now also re-reads the key doors); the probe was genuinely red (the record's 2
    issues match the mechanism I traced: `offersSetPassphrase` is a stored flag the pane never re-read).
11. **VX-457 (`FollowDoneMark`):** written exactly where the Done was owed (the landed-whole press via
    `ProtectionAccountRoad.owed` — follow kinds only, other acts keep their reopen receipts — and the
    settling open via `RoadStandingModel.make`), keyed by library ID (stable across a follow's re-key),
    read at every section landing, cleared only by OK; the one-shot receipt retired at
    `RoadStandingFaces.derive`. Survives `receipt_style` off and a quit by construction (UserDefaults).
12. **The words against the rules:** `keyDoorsLine` is the ledger's route-finder sentence, true under rule
    4 (current secrets reach every copy through the carried history; quiet roads only direct); the join
    moment's built text matches the F-U2-1 arbitration and its middle sentence is true exactly when the
    moment now fires (VX-456); `moveNotYet` names a road the faces actually render (This Mac Only only
    while signed out — checked against `assess`'s refusal); `makeMineLead`'s Castle surgery needle exists
    byte-exact in the base draft (and is pinned); the guide's three lessons and Data Safety's lines say
    the phase's own behavior (pairs, 14/14+4, one-a-day far, rule 5's sentence, rule 17's sentence
    verbatim-pinned to the rules file); the seeder's gate is the readme's own
    (`opensOnTheNewRoad(devStore:)`), so today's road — Release included — seeds byte-unchanged.
13. **VX-453:** the catalog/rendered-map/index all take the road; the statics read `newRoadIsLive` so
    Release keeps `everyRoadsRows` byte for byte; the results pane asks with the window's road, so a Debug
    build over a today's-road store never names the section (R-U2-8's double gate).
14. **Release parity / the one law:** zero `Sources/VariorumCore/Sync/`, `Server/`, schema, migration or
    dependency lines in the diff (checked the file list); `SyncSchema.lockstepVersion` untouched; every
    new behavior is reached only through new-road sessions/roads/faces (`newRoad` guards at the bootstrap,
    `roadStanding` gates at the panes, the seeder's variant gate; `LibraryMissingView.restoreDoor` nil on
    today's road); no `#if DEBUG` beyond the established guard switches entered this diff (rule 24).
15. **The import is sync-shaped where it matters (S1/S2/I-invariants):** every T-8 row is minted through
    the ordinary operations API (never ad-hoc row writes); no copy of persisted text crosses entities
    outside the import road's own bulk-entry semantics ("a file is bulk entry, never reconciled truth" —
    AppSpec §9 honored); nothing in the diff tracks word-level change; no operation's cost scales with
    corpus size (the far due-check, counts, listing and retention all read the CATALOG — a per-copy-count
    read, not a corpus read; the import is O(export) by nature as bulk entry).
16. **The headless suites:** the nine suites covering the phase's core custody lines run green on the
    final tree (47/10, my own run). The counts in the four unit records match the suites on disk
    (spot-checked the suite names and test names cited for every red-on-old claim I relied on).

**Red-on-old reproduced myself (one claim, the highest-stakes):** VX-456's core pin — in a scratch
detached checkout of `9ed104688` (pins-first, pre-fix) at a temp path, `JoinWordsMomentTests` fails with
exactly the recorded 2 issues (a passphrase-joined library, left and re-joined, hears its words replaced);
green on the final tree. The scratch checkout was created outside this worktree and removed after; this
tree was never modified (the review stayed read-only).

---

## Tally

**0 BLOCKER · 0 MAJOR · 2 MINOR (F-R1, F-R2) · 4 NIT (F-R3–F-R6).**
