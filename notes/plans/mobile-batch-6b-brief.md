# Batch 6b — THE PER-NOTE TRAY (brief; written 2026-08-31 by the Fable orchestrator)

**The design is fully ruled — nothing here needs the author.** The binding
shape is `mobile-round-2.md` **§69.3** (the post-13l polish round's ruled
tray, PL-14(e)'s letter): a per-note recovery face with

- **Archived** — this note's archived blocks: kept, forever, NO clock;
  put back / unarchive.
- **Leaving** — every CLOCKED thing of THIS note: its deleted blocks, plus
  its **deleted takes under a COLLAPSED-BY-DEFAULT disclosure**, each take
  naming its block and carrying **Put back** + **Delete Now with
  confirm-EVERY-time** (M-E binds; Delete Now here is legal because the
  tray is a trash-class surface for this note's clocked things — the
  evolved purge-door rule's letter: purge doors live on TRASH SURFACES
  only, and this is one).
- **NO unclocked-originals section** — preserved originals while unclocked
  are LINEAGE-ONLY (Block History's came-from, already shipped at 6a);
  clocked originals join Leaving when their family clock starts.

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 + PL-11/PL-14 · `mobile-round-2.md` §69–§70 ·
`notes/plans/mobile-batch-6c-record.md` (the rooms this face sits beside,
and its §7 deviation — YOUR deliverable 4 flips it) ·
`notes/plans/mobile-archive-trash-design/README.md` §7 Q8 · the code:
`MobileBlockHistory*.swift` + `Shared/BlockHistoryFace.swift` (READ-only —
fenced), `MobileTrashView/Model` + `MobileArchiveView/Model` (6c's rooms),
`Shared/RecoveryCopy.swift` + `Shared/RecoveryActs.swift` (READ-only —
fenced), `MobileNoteActions.swift`, the blocks chip's sheet, and
`Queries` for the per-note recovery reads (find the block-scoped/tray
reads the Mac's tray uses — the brains are core; the phone owes a face).

## Deliverables

1. **THE TRAY FACE** in §69.3's exact shape above, per note, reading core
   queries only (the Mac's This Note's Tray is the reference for WHICH
   reads exist — never copy its Mac-door wording; phone copy through the
   shared `RecoveryCopy` vocabulary where it is platform-neutral, and
   phone-voiced sentences where the Mac's name Mac doors, the 6a
   precedent).
2. **THE DOOR — PROVISIONAL (design-record Q8, log it):** the phone-native
   shape the design record names as the candidate: the existing **blocks
   chip's sheet gains segments** `in the note | archived | leaving` — one
   subject in three states. (Q8 was flagged "6b may place this door before
   she reads the page; if it does, that answer stands.") If the segments
   shape fights the existing sheet's structure, the fallback is a row in
   the note ⋯ — pick ONE, record why.
3. **ARCHIVE/UNARCHIVE DOORS (PR6):** the block-level archive door
   wherever block acts live (the block ⋯), if not already present via 6a's
   Block History Unarchive — verify what exists first; build only the
   missing direction(s).
4. **FLIP 6c's §7 DEVIATION:** the tray's Leaving section IS the take's
   purge road, so the Block History deleted-region caller now passes the
   tray door's name to `deletedRegionExplainer(purgeRoad:)` (phone
   call-site only — the shared function is fenced and already takes the
   argument). 6c left a precondition pin for exactly this flip — update it
   to the new truth.
5. **PR14 — the lens-dangles notice:** when a saved lens's pick dangles at
   an archived/deleted take (core's read-time fallback,
   `effectiveLensSelection`), the phone SAYS so loudly where the lens
   renders, with a one-tap restore (her 13j gate ruling (5): "say loudly
   if that take was archived and this is a fallback WITH a button for
   quick restore"). The restore rides the existing core ops
   (`unarchiveVariant` / `restoreVariant`).
6. **PR22 — the pocket guide's deletion chapter:** the guide teaches the
   five-places map in phone grammar (where you left it · Archived · the
   Trash · this note's Versions · this block's History) and the two exits
   (deletion → Trash; transformation → lineage). Re-teach, don't copy the
   Mac's field-guide text (it names Mac doors/chords). Note the guide
   already gained one savepoint lesson at 6a and the batch-5 review's NIT
   flagged its stale shelf description — fix that stale lesson while in
   the file (the Today's-Entry badge + the quick-note box).
7. **THE commitNow RIDER (carried from the sweep):** if — and only if —
   you give any surface its own Commit button while in here, that door
   takes the `MobileWriteLatch` the same day (the sweep's carried rider).
   Not otherwise your scope.

## Pins & discipline

Real mounted surfaces; the standing harness patterns; Delete Now
confirm-every-time driven at the real control (`tapAlertAction`);
red-on-old for any bug-class fix and for guards the face must not lose
(a Delete Now outside a trash-class surface must fail a pin; takes still
never row in the GLOBAL Trash — `TrashScope` pinned still true); P1:
windowed reads with visible truncation if the tray lists can grow;
PROVISIONALs (the door shape Q8; any copy calls) recorded in
`notes/plans/mobile-batch-6b-record.md`, written as you go. STOP AND
REPORT any deliverable that seems to need `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/`, or `EditorBrain/`.

## Environment (binding)

As every batch: own simulator (iPhone 17 family, newest iOS 26 runtime;
16-series sims are iOS 18.3, invalid), armed accessibility flag, private
`-derivedDataPath`, simulator deleted at the end; full mobile suite at the
end (baseline: the 6c record's final line — 607/94 with 2 known issues —
PLUS whatever the 6c review's fix wave adds; read the latest counts in
`mobile-batch-6c-record.md` / the review record before claiming a
baseline); never sweep `Package.resolved`; never touch the real store;
never quit the live Mac app; no Release builds, installs, or pushes;
pathspec-limited commits with the standing trailer. R28: your cold review
is dispatched from your report.
