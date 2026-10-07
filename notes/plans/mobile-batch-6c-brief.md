# Batch 6c — THE TWO-ROOMS IA (brief; written 2026-08-30 by the Fable orchestrator)

**Her ruling, verbatim (QUESTIONS #84, 2026-08-30):** *"i read the proposal
and I want this option: **Two rooms** — The Mac's own asymmetry, translated
literally. Archive becomes a room you browse; the Trash becomes a utility
you visit. Two doors, two destinations, nothing shared."* This discharged
PL-14(b)/§69.5's design-session gate. The design record is
`notes/plans/mobile-archive-trash-design/` (README + `proposal.html` —
option 2 is the ruled one; the shared Versions/tray/Block-History section
was on the page she ruled from). The five-places map
(`mobile-round-2.md` §69.1) is the tie-breaker for every face call.

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 + ledger rows PL-11/PL-13/PL-14 ·
`notes/plans/mobile-archive-trash-design/README.md` ·
`notes/plans/mobile-round-2.md` §69–§70 · `notes/QUESTIONS.md` #84–#87 and
#80(c)/(d)/(e) (her ratified Versions confirms) · the code:
`MobileTrashView.swift`, `MobileTrashModel.swift`, `MobileLibraryView.swift`
(`recoveryRow`, `pathLine`, `filterRow`), `MobileShelfView.swift`'s path
line, `MobileNoteActions.swift`, `Shared/RecoveryCopy.swift` (READ-only —
fenced), `Shared/VersionsCopy.swift` (READ-only — fenced),
`Shared/BlockHistoryFace.swift`'s `deletedRegionExplainer(purgeRoad:)` and
the phone caller that passes `nil`.

## Deliverables

1. **THE SPLIT.** The combined `MobileTrashView` (one ScrollView: trash
   half → Divider → archived half) becomes TWO pushed screens:
   - **The Trash room** — the trash half moves whole: the kind filter row
     (TrashScope order), the clocks, Put back, **Empty Trash and Delete Now
     staying IN-TRASH-ONLY with confirm-every-time** (M-E binds; the
     existing confirm machinery and its pins ride), the truncation marker,
     the report line. **Door: a trash glyph in the LIBRARY's path line** —
     option 2's letter, the analogue of her Mac B1 ruling (the masthead
     trash icon).
   - **The Archive room** — the archived half moves whole (kept forever,
     no clock, put back / unarchive as shipped). **Door: the Library's
     trailing row, narrowed** — it no longer claims deletion.
   - The combined "Archived & Deleted" surface RETIRES. Its name string
     (`RecoveryCopy.surfaceName`) lives in `Shared/` and is FENCED — stop
     calling it from the phone and record the string as a one-line Shared
     residue for the post-13u cleanup; do not edit the file.
2. **NAMES — PROVISIONAL (design-record Q7, log it):** the Archive room and
   its door say **"Archived"** (the Mac's surface noun,
   `RecoveryCopy.archivedSection`); the Trash says **"Trash"**. One string
   each if she re-words.
3. **THE SHELF'S TRASH DOOR — PROVISIONAL (design-record Q6 / finding 1,
   log it):** the Shelf's path line renders the SAME trash glyph from the
   SAME door declaration (one declaration, two renderers — a deleted book
   rows in the Trash while books live on the Shelf, so the door must not
   require a tab switch). Build it; it works identically under every
   option and costs one row of chrome.
4. **THE VERSIONS FACE (§69.6) — build PROVISIONAL to the proposal's drawn
   shape (Q5/Q9, log both):**
   - The note ⋯ sheet gains **"Save a Version"** and **"Versions…"** rows
     beside Undo · Redo · Delete Note… (the design record's finding 2 —
     the phone's two ⋯ menus teach the two grains: block ⋯ = Commit Take +
     Block History…, note ⋯ = Save a Version + Versions…).
   - The Versions screen lists `Queries.noteVersions`
     (`NoteVersionItem`: savedAt · blockCount · preview · cadence); a
     row's tap is **Read** (a push — the phone covers, never peeks; the
     design record §5.1); **Restore CONFIRMS** (her ratified #80(d)),
     **Promote is fast with NO confirm** (her ratified #80(c)), **Delete
     confirms** (the Trash rider). The ops are core
     (`saveNoteVersion` / `restoreNoteVersion` / `promoteNoteVersion`);
     restore is flush-first per its own discipline.
   - **Every sentence comes from `Shared/VersionsCopy.swift`
     (`VersionsPath`) — invent NO copy.** Where the Mac's face has wording
     the shared file does not carry, use the shared vocabulary and record
     the gap; do NOT pre-build 13u2 item 15's faces (the restore-confirm
     ancestor-naming and the tutorial lesson are that phase's — the fence).
5. **THE EXPLAINER'S SECOND HALF:** the phone now HAS a purge road, so the
   Block History deleted-region caller passes the Trash's door name to
   `BlockHistoryFace.deletedRegionExplainer(purgeRoad:)` (the §70
   handed-forward hook — phone-side call-site change only; the shared
   function already takes the parameter).
6. **NOT THIS BATCH:** kind filters on the Library/Archive (the NEXT batch
   — her #85 row; structure the Archive room so the Library's filter-row
   component can land on both later, one brain); the per-note tray's
   three-section rework (6b); anything in `Shared/`, `EditorBrain/`,
   `Sources/`, schema, build configs. `TrashScope` (takes never row in a
   global Trash) is untouched and must be pinned-still-true after the
   split.

## Pins & discipline

- **Real mounted surfaces, real doors** — the standing harness patterns
  (`HostedSurface` armed; alert doors through `tapAlertAction`; SwiftUI
  `Menu`/`.contextMenu` rows are undrivable in process, so shape doors
  accordingly, as batch 4 did with sheets).
- **Red-on-old where the split could lose a guard:** the
  purge-doors-exist-ONLY-in-the-Trash pin (the shipped
  nowhere-else assertion updates to the new room and must fail if a purge
  door leaks into Archive or the Library); confirm-every-time preserved at
  both purge doors; the Library's narrowed door no longer reaching trash
  rows.
- **P1 rides the split:** both rooms keep their windowed observations and
  visible truncation markers; no unwindowed read appears.
- New-surface behaviour pins (doors present and routed, both rooms render
  their halves, versions listed/read/restored/promoted through the real
  ops) need not be red-on-old (new capability), but every BUG-class fix
  found along the way lands with a proven red.
- **PROVISIONALs land in the batch record** (`mobile-batch-6c-record.md` —
  write it as you go: brief → what landed → pins with quoted reds →
  PROVISIONALs → counts), queued for her sitting bundle; nothing here is
  escalated mid-run (the away-run protocol; hard stops only for
  author-only calls).

## Environment (binding)

Worktree `~/dev/variorum-mobile`, branch `mobile`. Own simulator (iPhone 17
family, newest iOS 26 runtime; 16-series sims are iOS 18.3, invalid), arm
`ApplicationAccessibilityEnabled`, private `-derivedDataPath` under the
session scratchpad, delete the simulator when done. Full mobile suite at
the end — **the baseline is the WAVE 2 RESULTS final suite line in
`notes/plans/mobile-fable-sweep-review.md`**; quote your own "Test run with
N tests" line. Never sweep `Package.resolved` into a commit (test runs
drift it — revert). Never touch the real store; never quit the live Mac
app; no Release builds, no installs, no pushes. Commit pathspec-limited.
Verify before committing that `git diff --name-only` for your commit shows
NOTHING under `Sources/`, `App/Variorum/Shared/`, `App/Variorum/Variorum/`,
or `EditorBrain/`. R28: your build's cold review is dispatched by the
orchestrator from your report — write the record so a zero-context
reviewer can verify every claim.
