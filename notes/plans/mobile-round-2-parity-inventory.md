# Variorum for iPhone — Round 2 Parity Inventory (COLD SURVEY)

**Status: a SURVEY, not a plan.** Produced 2026-08-21 by a cold surveyor
in the `~/dev/variorum-mobile` worktree (branch `mobile`, fast-forwarded
to `main`'s tip, `46ffa0c`). **Nothing in the source tree was modified.**
Every symbol named below was grep-verified against the tree at that tip;
every "the phone has no X" claim is a verified sweep, not an inference.

**What this is for.** The Mac phases that closed since the phone's last
parity act (2026-08-11, the §5 seam) left three open rows in
`notes/MobileSoul.md` §6 — **PL-9** (14d), **PL-10** (13e), **PL-11**
(13j). Those rows name what mobile owes *in prose*. This file turns each
into concrete, file-level work: which brain already exists, where the
Mac's face is, where the phone's face would live, what shape fits a
phone, what must come first, and how big it is.

**Her instruction on scope, verbatim:**

> "you can order by importance but i want to stay on top of the backlog
> and try to add it all - if things like take reordering look too crowded
> later on mobile, i'll consider different UX solutions or remove them
> later. let's get the parity built in code so i can keep using the app
> as fully as possible"

**Everything is in scope.** The ordering below is by how much daily use
each row unblocks, never by what to drop.

**Her instruction on the ONE row needing more than parity, verbatim:**

> "one of the phases (trash) needs more than even phase parity - the
> actual deletion buttons weren't added, they're in the next variorum
> core phase, even though the mechanism was added, and you should add
> deletion buttons."

That row is **PL-11**, and **§2 is written to it. Read §2 first.**

**The sweep basis (belt and braces — MobileSoul §6's mobile duty).**
`git log` over `notes/DetailedPlanForPhases.md` confirms exactly four
phase closeouts since the seam: **14c** (2026-08-11 — PL-8, already
CLOSED at 14d), **14d** (2026-08-16 — PL-9), **13e** (2026-08-18 —
PL-10), **13j** (2026-08-19 — PL-11). No un-ledgered phase closed in the
window. What the ledger's *prose* missed **inside** those phases is
§4(b) — five real capabilities.

---

## 1. The one-screen summary

Sizes: **SMALL** = a door over a brain that already exists · **MEDIUM** =
a new surface · **LARGE** = a surface + its own state + its own held
observation.

| # | Capability | Source | Size | Pri |
|---|---|---|---|---|
| R1 | **Delete a note** — the phone has NO note-delete door anywhere | PL-11 + her "more than parity" | SMALL | **1** |
| R2 | **The Trash + Archived surface** — see it, filter it, Put back, Delete Now, Empty Trash | PL-11 (b) | LARGE | **2** |
| R3 | **The per-note tray** — deleted + archived blocks + preserved originals, Put back | PL-11 (a) | MEDIUM | **3** |
| R4 | **Delete a book** | §4(b) missed | SMALL | **4** |
| R5 | **Deleted takes come back** — the History past region + quiet-run collapse | PL-11 (d) | MEDIUM | **5** |
| R6 | **Archive / unarchive a block** — the third verb, no clock | PL-11 (c) | SMALL | **6** |
| R7 | **The phone's own on-leaving savepoint hook** | PL-11 (e) | SMALL | **7** |
| R8 | **Reorder takes** | PL-10 (a) | SMALL | **8** |
| R9 | **Duplicate-book-name refusal** at create + rename | PL-10 (b) | SMALL | **9** |
| R10 | **The tag-chip grammar on listings** — ✕ remove, type-to-create ＋ | §4(b) missed (13e E8) | MEDIUM | **10** |
| R11 | **Copy all takes** (`UIPasteboard` twin) | PL-10 (c) | SMALL | 11 |
| R12 | **Take → block below · takes → blocks** | PL-10 (d) | SMALL | 12 |
| R13 | **Savepoint cadence + history pruning settings rows** | PL-11 (f) | SMALL | 13 |
| R14 | **The lens-dangles-at-an-archived/deleted-take notice + Restore** | §4(b) missed (13j J5) | SMALL | 14 |
| R15 | **The lineage door / preserved-original peek** | PL-11 (rides a+d) | SMALL | 15 |
| R16 | **PL-9's three judgment acts** | PL-9 | SMALL | 16 |
| R17 | **The rest of the document settings** — segmentation, seams, indicator, inline comments, follow-the-scroll | §4(b) missed | MEDIUM | 17 |
| R18 | **Whole-block-selection delete routing** (the brain is already `Shared/`) | §4(b) missed (13j J9) | SMALL | 18 |
| R19 | **Callout colour swatches + a real emoji picker** | PL-10 (her word) | SMALL | 19 |
| R20 | **Block multi-select + multi-delete** | §4(b) missed (13e E2) | MEDIUM | 20 |
| R21 | **In-note replace, then replace-all-in-every-take** | §4(b) missed (13e E9) | MEDIUM | 21 |
| R22 | **A deletion chapter in the phone's pocket guide** | §4(b) missed (13j J10) | SMALL | 22 |
| R23 | **The voice preference is a FORKED BRAIN** | §4(c) | SMALL | 23 |
| R24 | **Design calls held for her** — ●n marker side; margin-comment tap shape | PL-10 | — | her word |

**The three things that matter most, one line each:**

1. **The phone cannot delete a note, and nothing it deletes can ever come
   back** (R1–R3). Every other row is polish beside this.
2. **The Mac's own purge doors are DEAD at this tip** — a real SwiftUI
   observation defect, traced but unfixed (13l owns it). If the phone's
   Trash copies the Mac's presentation shape it inherits the same dead
   door. §2.4 says exactly how to not do that, and it is the single
   loudest thing in this file.
3. **Eight brains are forked or Mac-local** (§4(c)). Each one the phone
   needs is a **hoist**, not a copy — MobileSoul §3, and the KnownIssues
   "six mobile brains" row is the standing precedent.

---

## 2. PL-11 — DELETION, THE TRASH & THE PURGE (the row that needs MORE than parity)

### 2.1 What the phone can and cannot do TODAY (verified sweep)

A grep of `App/Variorum/VariorumMobile/` for
`TrashWindow|Queries.trash|archiveBlock|unarchiveBlock|restoreVariant|trayBlocks|preservedOriginals|blockPast|deletedTakes|SavepointCadence|HistoryPruning|requestPurge|danglingLensPicks|savepointOnLeaving|LocalPurge`
returns **zero hits.** The phone has **none** of 13j's faces.

| Act | Phone today | Verified at |
|---|---|---|
| Delete a **block** | YES — long-press → Delete Block, confirmed | `Features/Write/MobileBlockMenu.swift:258` (`confirmDelete`), `:279` → `Features/Write/MobileStructural.swift:527` |
| Archive / delete a **take** | YES — the takes browser's card menu | `Features/Takes/MobileTakesBrowser.swift:466` (`archiveVariant`), `:472` (`deleteVariant`), `:221` (`unarchiveVariant`) |
| Delete a **comment** | YES, and restore it | `Features/Write/MobileComments.swift:123`, `:127` |
| Delete a **reference** | YES | `Features/Write/MobileReferences.swift:162` |
| Delete a **tag** | YES | `Features/Shell/MobileTagManager.swift:242` |
| Delete a **note** | **NO DOOR ANYWHERE** | `deleteContainer` appears in `VariorumMobile/` exactly once — `Features/Tutorial/MobileTutorialSeeder.swift:166`, the seeder's own cleanup |
| Delete a **book** | **NO DOOR ANYWHERE** | `deleteReading` appears once — `MobileTutorialSeeder.swift:170` |
| **Restore** anything | **NO DOOR ANYWHERE** | zero `restoreBlock` / `restoreContainer` / `restoreReading` / `restoreVariant` / `unarchiveBlock` call sites |
| See a **Trash** | **NO SURFACE** | zero `Queries.trash` call sites |
| See a note's **tray** | **NO SURFACE** | zero `Queries.trayBlocks` / `archivedBlocks` / `preservedOriginals` / `trayCounts` call sites |

The phone's own delete confirm says this today, and it is currently true:

> `MobileBlockMenu.deleteConfirmDetail` (`Features/Write/MobileBlockMenu.swift:255`)
> = *"The block leaves this note, with its takes. There's no undo here."*

**That literal must change when R3 lands.** A tray makes "there's no undo
here" false, and a stale honest sentence becomes a dishonest one. The
comment above it (written at 13j batch 2, when the Mac phase made the
phone's copy honest rather than promising a surface it lacked) names this
as the parity ledger's row. Its J8 doctrine binds: *a promise a user
cannot act on is not a fact she can use.*

### 2.2 The core/Shared brains the phone inherited FREE (all verified)

| Brain | Symbol | File |
|---|---|---|
| The 30-day clock | `TrashWindow` — `days = 30`, `cutoff(now:)`, `cutoffStamp(now:)`, `isInWindow`, `daysLeft` | `Sources/VariorumCore/Domain/TrashWindow.swift:22` |
| The whole Trash listing | `Queries.trash(_:now:kinds:oldestFirst:limit:)` · `Queries.observeTrash` | `Queries/Trash.swift:82`, `:484` |
| Its row model + five kinds | `Queries.TrashItem`, `.Kind` (`note · book · block · take · preservedOriginal`) | `Queries/Trash.swift:12`, `:13` |
| Archived notes (no clock) | `Queries.archivedPosts` — deliberately takes **no** `now:` | `Queries/Timeline.swift:183` |
| Deleted notes / books | `Queries.deletedPosts(_:now:)` · `Queries.deletedReadings(_:now:)` | `Queries/Timeline.swift:214`, `Queries/ReadingAssembly.swift:155` |
| A note's deleted blocks | `Queries.trayBlocks` · `Queries.TrayItem` · `observeTray` | `Queries/PoolAndTray.swift:89`, `:53`, `Queries/Observations.swift:118` |
| A note's archived blocks | `Queries.archivedBlocks` | `Queries/Trash.swift:445` |
| Preserved originals | `Queries.preservedOriginals` · `.PreservedOriginal` · `observePreservedOriginals` | `Queries/PoolAndTray.swift:163`, `:139`, `Observations.swift:126` |
| The tray badge's numbers | `Queries.trayCounts` · `observeTrayCounts` — **never reads `variant`**, so it does not re-run at autosave rate (P1) | `Queries/PoolAndTray.swift:253`, `Observations.swift:136` |
| Stranded originals + fates | `Queries.strandedOriginals` · `.originFamilyClocks` → `OriginFamilyFate` (`.counting` / `.gone`) · `.originalsStrandedBy` | `Queries/Trash.swift:249`, `:343`, `:318`, `:401` |
| A block's past | `Queries.blockPast(_:blockID:now:)` → `Queries.BlockPast` · `Queries.deletedTakes` · `observeBlockPast` · `observeDeletedTakes` | `Queries/EditorSupport.swift:177`, `:165`, `:141`, `:210`, `:197` |
| Unplaced origins (lineage) | `Queries.unplacedOrigins` (two overloads) · `Queries.UnplacedOrigin` — **both exclude archived blocks** | `Queries/Lineage.swift:104`, `:151`, `:82` |
| Dangling lens picks | `Queries.danglingLensPicks` · `Queries.DanglingPick.State` (`.archived`/`.deleted`/`.gone`/`.foreign`) | `Queries/LensQueries.swift:107`, `:80` |
| Archive / unarchive a block | `Operations.archiveBlock` · `.unarchiveBlock` → `BlockUnarchiveLanding` | `Operations/Operations+BlockArchive.swift:49`, `:97` |
| Put a deleted take back | `Operations.restoreVariant` → `VariantStatus` (returns the status it revived AS) | `Operations/Operations+Deletion.swift:101` |
| Put a block back, where it was | `Operations.restoreBlock` → `BlockRestoreLanding` (`.itsOldPlace`/`.endOfNote`/`.unplaced`) | `Operations/Operations+Placement.swift:86`, `:46` |
| True delete | `Operations.requestPurge(_ targets:)` → Int · `Operations.voidPurgeIntents` (the restore-side belt) · `PurgeIntent` · `SyncPurgeTarget` | `Operations/Operations+Purge.swift:43`, `:95`, `Models/PurgeIntent.swift:18`, `Sync/SyncTransport.swift:89` |
| The janitor + the local road | `PurgeJanitor` (`sweep`, `reconcileLedger`, `familyVerdict`) · `LocalPurge` · `PurgeFamily` | `Sync/PurgeJanitor.swift:25`, `:79`, `:239`, `:742`, `Sync/PurgeFamily.swift:71` |
| Both wired on the phone already | `SyncSession` builds `PurgeJanitor`; `AppServices` runs `LocalPurge` launch + hourly via `AppSession.sweepLocalPurge` | `Shared/SyncSession.swift:110–112`, `Shared/AppServices.swift:107, 185, 284–299`, `Shared/AppSession.swift:81` |
| The on-leaving savepoint | `AppSession.savepointOnLeaving(_:)` → `Operations.closeAutoCommit` (the **sixth** quiet auto-commit occasion) | `Shared/AppSession.swift:239`, `Operations/Operations+Variant.swift:137` |
| Cadence + pruning vocabulary | `SavepointCadence` · `HistoryPruning` · `SavepointPruning.prunable` · `SavepointRuns` (the quiet-run collapse rule) | `Models/Enums.swift:96`, `:130`, `Domain/SavepointPruning.swift`, `Domain/SavepointRuns.swift` |
| Their setters + readers | `Operations.setSavepointCadence` / `.setHistoryPruning`; `Queries.idleCommitHours` / cadence / pruning | `Operations/Operations+Appearance.swift:93`, `:106`, `Queries/IdleCommit.swift:19, 33, 45` |
| Whole-block-run geometry | `BlockRangeIndex.wholeBlockRun(covering:)` — **already in `Shared/`** | `Shared/EditorBrain/BlockRangeIndex.swift:280` |

**Consequence: PL-11 is almost entirely FACE work.** The phone's purge
already runs — `AppServices` starts the local sweep and `SyncSession`
starts `PurgeJanitor` on the phone exactly as on the Mac, and the phone
speaks lockstep marker **7** through the shared core
(`Sync/SyncSchema.swift:90`). What the phone lacks is every door onto it.

**A `now:` note worth knowing:** the recovery queries take `now:` as a
**required** parameter, deliberately, so that a new surface has to decide
about the clock rather than inherit a default. `archivedPosts` takes none
— archive has no clock, by design.

### 2.3 The deletion DOORS this round must build — enumerated

Her instruction is that the phone gets **real, working deletion buttons
this round regardless of the Mac's state.** Three semantics exist and
must never blur in copy:

- **Move to Trash** = an ordinary tombstone, recoverable for 30 days
  (`TrashWindow`). This is what "Delete" means everywhere *outside* the
  Trash surface.
- **Archive** = kept, out of view, **no clock**. The Mac's word for the
  state is `RecoveryPath.archivedForever` = *"kept — no clock"*. Never a
  deletion.
- **True delete / purge** = `requestPurge`. Unrecoverable. **In-Trash
  only, confirm every time.**

| Door | Where on the phone | Semantic | Confirm |
|---|---|---|---|
| **D1 · Delete Note** | Library row long-press (`Features/Shell/MobileLibraryView.swift:210`, beside the existing Star row) AND a new `⋯` menu in the note masthead | Move to Trash | **YES** — receipt names the Trash and its clock |
| **D2 · Delete Book** | Shelf row long-press (`Features/Shell/MobileShelfView.swift:162`, beside Pin/Star) and/or `MobileBookDetailsSheet` | Move to Trash (`deleteReading`) | **YES** — one wording family with D1 |
| **D3 · Delete Block** | EXISTS (`MobileBlockMenu`) | Move to Trash | keeps its confirm; **its detail sentence must be rewritten** once R3 lands (§2.1) |
| **D4 · Archive Block** | a new `MobileBlockMenu` row beside Delete | Archive (no clock) | **NO** — in-flow, reversible, no clock |
| **D5 · Put back** (note · book · block · take · preserved original) | Trash rows (R2) and tray rows (R3) | Restore | NO |
| **D6 · Delete Now** | **Trash rows ONLY** | **True delete** | **YES, EVERY TIME** |
| **D7 · Empty Trash** | **The Trash surface ONLY** | **True delete, everything** | **YES**, and the confirm **names the full count by kind** |

**The ruled rider, her words verbatim (13j sitting round 3):**

> "everything deleted, one uniform story, but have a delete now option
> WITHIN the trash (not from within the normal note). maybe you can sort
> the trash by blocks or note or whatever would be important for that to
> be a real option, but never accidental full delete from within a note,
> but an option for full delete without waiting."

The Mac enforces this **structurally**, and the phone should mirror the
technique: `RecoveryView.surfaceCapabilities = [.deleteNow, .emptyTrash]`
(`RecoveryView.swift:467`) is their ONE declared renderer, and the
registry's surface-walk union makes a leaked purge door a build failure.
Both capabilities are declared `scope: .app, doors: [.surface]`
(`Registry/Capability.swift:622, 629`) with the unavailable note *"Delete
Now lives in the Trash — … never a note."*

**Confirm-every-time (13j round 10):** *"Delete Now confirm RULED: EVERY
TIME — no session-scoped don't-ask; Empty Trash is the one-confirm bulk
road."* There is **no don't-ask state anywhere in the code** to set, and
none should be added.

**Preserved originals never render a Delete Now** — they ride their
family's clock (her round-8b ruling; the Mac enforces at
`RecoveryView.swift:306`).

### 2.4 ⚠️ THE DEAD-DOOR DEFECT — read this before writing the phone's Trash

**The Mac's purge doors do not work at this tip.** Her live report
(2026-08-19, verbatim): *"I did a delete from the trash (which should be
a true delete) but nothing visually changed and the item is still
there."* 13l owns the fix
(`notes/plans/phase-13l-data-safety-floor.md` §8, "FIRST ACT") and 13l
has not run. I confirmed the defect is still present:

```
App/Variorum/Variorum/Features/Library/RecoveryView.swift:573–577

.confirmationDialog(
    model.pendingConfirm?.message ?? "",
    isPresented: Binding(
        get: { model.pendingConfirm != nil },
        set: { presented in if !presented { model.cancelPendingPurge() } }),
    titleVisibility: .visible
)
```

`pendingConfirm` is a property on an `@Observable` model. It is read
**only inside the closure of a computed `Binding`**, never during `body`
evaluation — so SwiftUI registers no observation dependency on it.
Setting it re-renders nothing, the binding's `get` is never re-asked, and
the dialog never presents. **Both purge doors ride this road**
(`requestDeleteNow` and `requestEmptyTrash` both set `pendingConfirm`),
so **true delete is currently unreachable from the Mac's UI entirely.**
The 30-day clock and the janitor still purge on schedule; no intent is
minted, so nothing half-happened; no data is at risk.

**Would the phone inherit it? Only if it copies that pattern — and it
must not.** Both of the phone's existing confirm roads are immune, and
either is a correct model:

- **The UIKit road** (`Features/Write/MobileEditorViewModel.swift:262–277`):
  a `confirmDestructive` closure seam presenting a `UIAlertController`
  imperatively. No SwiftUI observation involved at all. This is what
  `MobileBlockMenu` uses.
- **The SwiftUI road as the phone already writes it**
  (`MobileWriteView.swift:230`, `MobileBookDetails.swift:195`,
  `MobileLenses.swift:408`): `.alert(..., isPresented: $someState)` where
  `someState` is a real `@State` property. **The `$` binding IS the
  dependency** — precisely what the Mac's computed binding lacks.

**Rule for this round, stated loudly:** *the phone's Trash must never
present a destructive dialog through a `Binding(get:set:)` computed over
an `@Observable` property.* Use `@Bindable var model` and bind
`$model.pendingConfirm`, or use the UIKit `confirmDestructive` seam.

**And the pin must mount the REAL surface and drive the REAL button.**
The 13j view-model seam pins stayed green over the dead Mac wiring — that
is exactly how the defect shipped. There is a second, compounding reason
it hid: the 13j record notes that `TrayPanel`, `OriginPeekPanel` and the
Trash listing are SwiftUI `List`s (NSTableView-backed) and **cannot be
captured by `ImageRenderer`** — measured, not assumed — so the visual
drive never saw them. **The phone's equivalent surfaces will be
`UICollectionView`-backed `List`s with the same property.** Plan a real
device/simulator hand-check for R2 and R3 rather than trusting a
screenshot pass.

*(Worth relaying to her: the phone's correct pattern can be the reference
that 13l's Mac fix copies — the same "workaround that became the Mac's
default" road her divide and merge rulings already took.)*

---

## 3. The rows, in priority order

---

### R1 · Delete a note — PRIORITY 1 · SMALL

**Capability.** Get rid of a note you don't want, from the phone, and
have it be recoverable for 30 days.

**Brain (exists, core).** `Operations.deleteContainer(_:)` /
`Operations.restoreContainer(_:)` (AppSpec §9 — the exact-stamp cascade
revival). `Queries.trash`'s `.note` kind lists it afterwards.

**Mac's face.** `LibraryViewModel.delete(postID:)`
(`App/Variorum/Variorum/Features/Library/LibraryViewModel.swift:131`),
worn as a Library row action and a Pool row action. **Today it carries NO
confirmation, and there is NO "Delete Note…" in the note's own ▾ menu** —
both are 13l §8's ruled work, unbuilt. Her report, verbatim: *"how do i
even delete a note? I'm within a note I want to delete right now and I
don't see how to delete it."* So the phone is not behind the Mac here; it
is behind *zero*.

**Phone's face.**
- **`Features/Shell/MobileLibraryView.swift:210`** — the note row's
  `.contextMenu` exists and holds exactly one row (Star). Add
  `Button(role: .destructive)` "Delete Note…". Long-press is the phone's
  established row-menu grammar here.
- **`Features/Write/MobileWriteView.swift`, the masthead** — the note's
  own door. The masthead has a title button, `findDoor`, `sealDoor` and
  the five-chip flow; there is **no ▾ menu**. Two shapes fit: (i) add a
  `⋯` `Menu` beside `sealDoor`; or (ii) a `MobileNoteMenu` sheet.
  **(i) is recommended** — it gives R3, R15 and future note-scale acts a
  home without a new surface.
- Confirmation via the phone's `.alert(isPresented: $state)` shape;
  receipt names the Trash and the clock.
- **Navigate-away:** deleting the note you are *in* must pop the stack.
  The Mac's 13l ruling is "navigate-away covers every pane"; on the phone
  that is one path-pop plus a `MobileLivenessAuthority` deregister.

**Dependencies.** None — buildable first and alone. Far more *useful*
with R2, so ship R1 + R4 + R2 as one batch if scheduling allows.

---

### R2 · The Trash + Archived surface — PRIORITY 2 · LARGE

**Capability.** See everything deleted in the last 30 days and everything
archived, filter it, put things back — and really delete when she means
it.

**Note the Mac surface has TWO sections, not one:**
`RecoveryPath.archivedSection = "Archived"` (kept forever, **no clock**)
and `RecoveryPath.trashSection = "Trash"`. The phone owes both; conflating
them would make archive read as a deletion.

**Brain (exists, core).** `Queries.trash(_:now:kinds:oldestFirst:limit:)`
(`Queries/Trash.swift:82`) + `Queries.observeTrash` (`:484`) return
`[TrashItem]` across all five kinds, filtered by `kinds`, sorted, **and
limited in SQL per arm** (the 13j ladder-B B4 discipline — each arm
carries its own `ORDER BY` + `LIMIT` in the caller's direction, because
the top-N of a merged union equals the top-N over per-arm top-Ns only
when every arm sorts the way the merge does). `Queries.archivedPosts`
(`Timeline.swift:183`) is the archived half. Put-back routes by kind:
`.note → restoreContainer`, `.book → restoreReading`,
`.block → restoreBlock`, `.take → restoreVariant`,
`.preservedOriginal → placeBlock`. True delete: `requestPurge`; the
restore-side belt `voidPurgeIntents` is already called by all six
tombstone-flip doors in core, so a Put back after a Delete Now is safe by
construction.

**Mac's face.**
`App/Variorum/Variorum/Features/Library/RecoveryView.swift` — reached
from the Library ⋯ menu and the ⌘K palette as **"Archived & Deleted"**
(`RecoveryPath.menuLabel:73`), also at
`LibraryCatalogView.swift:348` and `RootView.swift:602/694`. It wears:
a kind `Picker("Show", …)` over **Notes · Books · Blocks · Takes ·
Originals**; a newest/oldest sort toggle (both restart the observation so
filter+sort apply *in SQL* before the window); `RecoveryPath.windowNote`
as the section header; per row a preview, "from ‹note›" context (saying
*"also in the Trash"* when that note is gone too), days-left
(`daysLeftLabel:95`), **Put back** (`putBackVerb:84`), an **Open note**
door only where the note is live, and **Delete Now**
(`deleteNowVerb:121`, row button at `:639`); plus a header **Empty
Trash…** (`emptyTrashVerb:122`, `:565`) rendered only when the Trash
holds something, whose confirm reads the **unwindowed** counts at ask
time and names the full count by kind (`emptyTrashConfirm:135`).
Receipts `deleteNowReceipt(…synced:familyEverSynced:)` (`:172`) and
`emptyTrashReceipt` (`:186`) word three populations honestly (synced ·
local-only · never-synced). **Its two purge doors are dead — §2.4.**

**Phone's face (new files).**
- `Features/Shell/MobileTrashView.swift` — the surface.
- `Features/Shell/MobileTrashModel.swift` — `@Observable`, holding the
  windowed listing, the kind filter, the sort, and the pending confirm.
  Follow `MobileLibraryViewModel`'s shape exactly: a bounded observation
  restarted on filter/sort change via `.task(id:)`, with the Phase 10
  window+probe truncation marker (MobileSoul §2).
- **Entry point — pick one:** (i) a fourth case beside
  `MobileLibraryViewModel.Filter`'s `all / bookless / scraps`, surfaced
  through the Library's existing filter `Menu`
  (`MobileLibraryView.swift:152`); or (ii) a row in
  `MobileSettingsView`. **(i) is recommended** — it puts the Trash where
  the notes are and mirrors "Library → Archived & Deleted". Push it as
  its own screen rather than holding it open as a filter: the Trash's
  stranded-originals arm walks lineage families, which is why the Mac
  treats it as a deliberately-opened surface, not a held per-keystroke
  one.
- **Phone-native shapes:** the kind filter as a `Menu` (the Library's
  existing grammar), not a segmented Picker; **Put back as a leading
  swipe** and Delete Now as a **trailing destructive swipe**, with both
  also in the row's long-press menu (swipe alone is undiscoverable);
  Empty Trash as a header/toolbar row.
- **§2.4's confirm rule is binding.**
- Copy: the Mac's `RecoveryPath` sentences are the reference — and are
  **Mac-app-local strings**, §4(c).

**Dependencies.** R1 and R4 give it something to hold.

---

### R3 · The per-note tray — PRIORITY 3 · MEDIUM

**Capability.** From inside a note: see the blocks it has deleted, the
blocks it has archived, and the originals a divide/merge preserved whole
— and put any of them back.

**Brain (exists, core).** `Queries.trayBlocks`
(`PoolAndTray.swift:89`), `Queries.archivedBlocks`
(`Trash.swift:445`), `Queries.preservedOriginals`
(`PoolAndTray.swift:163`), `Queries.trayCounts`
(`PoolAndTray.swift:253`) for the badge, plus the three observations at
`Queries/Observations.swift:118, 126, 136`. Put-back:
`restoreBlock` → `BlockRestoreLanding`, `unarchiveBlock` →
`BlockUnarchiveLanding`, `placeBlock`.

**Mac's face.**
`App/Variorum/Variorum/Features/Tray/TrayPanel.swift` — `TrayPath` (the
one naming home), `TrayRequest`, `TrayViewModel` (windowed 500 + probe
row), `TrayPanel` (read-cheap `Text` rows, **never a pane** — P3),
`TrayRefusalCopy`, `TrayRowPreview`, `PreservedOriginPutBack` (`:381`),
`StrandedOriginals` (`:412`).

*Doors* — one act, `.showNoteTray` (`Registry/Capability.swift:609`,
`scope: .post, doors: [.surface, .bottomBar]`):
- the **⌫ N badge** in the note's context bar
  (`Workspace/ContextBar.swift:299–310`, shown when `deletedCount > 0`);
- **"This Note's Tray…"** in the `note ▾` menu of **both** bars
  (`Features/Editor/CommitBar.swift:172`,
  `Features/Takes/TakesBottomBar.swift:315`) — always present, because a
  badge that hides at zero cannot be the only way in.

*Sections* — `deletedSection = "Deleted & archived"` (`:86`) and
`originalsSection = "Preserved originals"` (`:87`). Deleted rows wear
`daysLeftLabel`; archived rows wear `archivedForever = "kept — no
clock"`; both wear one `putBackVerb`. Once the last descendant of a
preserved original is deleted, its row **moves** into the clock-bearing
section wearing `goesWithItsFamily` (her round-8b ruling — derived state,
not a stored flag). Three put-back roads with three distinct receipts
(`putBackWhereItWas` / `putBackAtEnd` / `putBackBeside`). Under a seal
the tray still **opens** (reading is free) and Put back refuses with
`TrayRefusalCopy.sealed`.

**Phone's face.**
- **The door: a SIXTH chip in the masthead's `MobileChipFlow`**
  (`MobileWriteView.swift:186–192`, beside date · tags · more info ·
  blocks · lens), rendering `⌫ N` from `Queries.trayCounts`, hidden at
  zero — exactly the phone's existing chip grammar. *(Her ratified
  #67(a): the Mac's badge counts DELETED only, so a note with only
  archived blocks shows no badge and the `note ▾` item is the road. Match
  the Mac and watch it in use, as she ruled — the phone's `⋯` menu from
  R1 is the equivalent always-present road.)*
- **The surface:** `Features/Write/MobileTrayView.swift` + a model, as a
  `.sheet` off the chip — the phone's established grammar for summoned
  machinery (`MobileMembershipSheet`, `MobileNoteTagsSheet`,
  `MobileReferencesSheet`, `MobileBlockListSheet`, `MobileLensSheet` all
  present this way from the same masthead).
- Rows: preview + kind + days-left (or "kept — no clock"); **Put back**
  as a visible trailing button rather than a hidden swipe — the tray is
  small and discoverability matters more than density here.
- **Then rewrite `MobileBlockMenu.deleteConfirmDetail`** (§2.1).
- Also worth mirroring: the Mac's Blocks-mode tray section became a
  one-line door into this one panel (round-7 ruling). The phone's
  `MobileBlockList` sheet should do the same rather than growing a second
  recovery listing.

**Dependencies.** None technically; after R1/R2 for copy consistency.

---

### R4 · Delete a book — PRIORITY 4 · SMALL

**Capability.** Get rid of a book from the phone.

**Brain (exists, core).** `Operations.deleteReading` /
`Operations.restoreReading` (AppSpec §9, the 13b S4-28.2 restore door).
`Queries.trash`'s `.book` kind already lists it — **the tell that this is
a real gap is that the phone can never populate a case the core listing
defines.**

**Mac's face.** `ReadingsViewModel` / the shelf's row menu.

**Phone's face.** `Features/Shell/MobileShelfView.swift:162` — the book
row's `.contextMenu`, which today holds Pin and Star. Add "Delete Book…"
(destructive, confirmed). Optionally also on `MobileBookDetailsSheet`
(`MobileBookDetails.swift:152`) beside its finish/rename rows.

**Dependencies.** None. Best in the same batch as R1 — one confirmation
wording family serves both.

---

### R5 · Deleted takes come back — the History past region — PRIORITY 5 · MEDIUM

**Capability.** A take you deleted is still there, in the block's
History, with a Put back — and the block's lineage row sits beside it.
Plus: long runs of quiet savepoints collapse instead of burying the
deliberate ones.

**Brain (exists, core).** `Queries.blockPast(_:blockID:now:)` →
`Queries.BlockPast { deletedTakes, origins }`
(`Queries/EditorSupport.swift:177`, `:165`), `Queries.deletedTakes`
(`:141`), observations at `:197`, `:210`.
`Operations.restoreVariant(_:) -> VariantStatus`
(`Operations/Operations+Deletion.swift:101`) — a **recovery-door class**
op: no undo entry, exact tombstone flip (label, `fan_position`, parent,
text, status revive as they were), `default_variant_id` deliberately NOT
re-pointed. It **returns the revived status**, so a receipt cannot claim
the fan for a take that came back archived. The archived-take road stays
the pre-existing `Operations.unarchiveVariant` (`:55`) — no second
unarchive road. Quiet-run collapse rule: `SavepointRuns`
(`Sources/VariorumCore/Domain/SavepointRuns.swift` — `collapseFrom = 2`,
generic `Row<Item>`, `runLabel`, `showVerb`/`hideVerb`).

**Mac's face.**
`App/Variorum/Variorum/Features/Tray/BlockPastSection.swift` —
`BlockPastModel` (`:97`) + `BlockPastSection` (`:156`), ONE shared
component mounted by **both** history faces (Write's `CommitBar` →
`CommitHistoryView`, and the Takes history sheet) so they cannot drift.
Copy home `BlockPastCopy`: `deletedTakesHeader = "Deleted takes"`,
`putBackVerb`, `seeOriginVerb = "See original"`,
`takeRestored` / `takeRestoredArchived` via `restored(_ status:)`,
`rowLabel`, `emptyTake = "(empty take)"`. Capabilities
`[.showOriginBlock, .restoreTake]` (`:168`). **No countdown in this
face** — the clock is the Trash's and the tray's. The quiet-run collapse
face is `Features/Editor/SavepointHistory.swift`
(`SavepointHistoryFace:25`, `QuietRunRow:58`), shared by both history
faces the same way.

> **This region was 13j ladder A's BLOCKER** — the `.task` sat inside the
> emptiness conditional, so the whole region was dead in the real app.
> Fixed with an always-mounted zero-size container carrying the
> `.task(id:)`, pinned by a test that mounts against a real store. **The
> phone's version must mount its load the same way** — this is the same
> "wiring is the delivery" family as §2.4.

**Phone's face.**
`Features/Takes/MobileTakeHistorySheetView.swift` (+
`Features/Takes/MobileTakeHistory.swift`, which already has
`restore(_:confirmed:)` for savepoints at `:183`). Add a past region
below the savepoint list: a "Deleted takes" section with Put back per
row, and the lineage row with a "See original" that raises R3's tray with
the original revealed. Adopt `SavepointRuns` for the collapse in the same
pass — it is a pure core rule and the phone's history list is exactly
where it pays.

**Note (belt and braces):** the phone's takes browser **already** renders
archived takes with a road back (`MobileArchivedTakeCardView`,
`MobileTakesBrowserView.swift:674`; `unarchiveVariant` at
`MobileTakesBrowser.swift:221`). Archived takes are covered; **deleted**
takes are the gap.

**Dependencies.** R3 for the "See original" landing.

---

### R6 · Archive / unarchive a block — PRIORITY 6 · SMALL

**Capability.** Set a block aside **forever, with no clock**, keeping its
tie to this note. Archive · Delete · Move to scraps is taught as one
trio.

**Brain (exists, core).** `Operations.archiveBlock(_:)`
(`Operations/Operations+BlockArchive.swift:49`),
`Operations.unarchiveBlock(_:) -> BlockUnarchiveLanding` (`:97`).
Semantics: releases the placement (tombstoned, stamp-matched to
`archived_at`) and stamps `block.archived_at`; the note renders on with
**no view-level filtering**; unarchive clears the stamp and revives THAT
placement row (the F2 road), fresh-at-end as fallback. Refuses
`blockAlreadyArchived` / `blockNotArchived` and the seal in **both**
directions. Registers structural undo **with** redo. Zero schema —
`archived_at` has existed since v1.

**Mac's face.** Capability `.archiveBlock`, verb **"Archive Block"**,
`scope: .block, doors: [.menuBar, .contextMenu]`, no shortcut
(`Registry/Capability.swift:267`). Rendered at
`Features/Editor/EditorViewModel.swift:1724` (block context menu),
`Features/Editor/EditorView.swift:297`, executed at
`Features/Editor/EditorSurfaceController.swift:772`; plus
`Features/Takes/TakesBoardView.swift:257`,
`Features/Takes/LensesBoardView.swift:205`, executed at
`Features/Takes/TakesStructureController.swift:156`.

**Phone's face.** `Features/Write/MobileBlockMenu.swift:99` —
`menuElements` already composes the long-press menu; add an "Archive
Block" `UIAction` beside Delete. **No confirm** (reversible, no clock).
The unarchive road is R3's tray section.

**Ordering rider.** Shipping the archive door *before* the tray would
create exactly the "a promise a user cannot act on" problem 13j batch 2
named — archiving with no visible road back. **Build R6 with or after
R3.**

---

### R7 · The phone's own on-leaving savepoint hook — PRIORITY 7 · SMALL

**Capability.** Leaving a note leaves a savepoint behind, so version
history is real without remembering to commit.

**Brain (exists, Shared).** `AppSession.savepointOnLeaving(_ postID:)`
(`App/Variorum/Shared/AppSession.swift:239`) — flushes first, then calls
`Operations.closeAutoCommit` (`:248`), the **sixth** quiet auto-commit
occasion (`Operations/Operations+Variant.swift:137`). It honours
`SavepointCadence`, and **never throws** — a vanished or sealed container
answers `[]`, because a lifecycle moment must not refuse at a surface
that is going away. Its own doc comment says **"Every leaving road calls
THIS and nothing else"** (`:219`). It sits **deliberately outside** the
`#if os(macOS)` fence so the phone's hook is one call.

**Mac's face (the FUNNEL, correctly per-platform).**
`App/Variorum/Variorum/Workspace/SavepointOnLeave.swift` —
`wire(workspace:session:)` (`:60`), `windowClosing` (`:74`), `leaving`
(`:79`), off `WorkspaceModel.reportingDepartures`, `RootView.onDisappear`
and `NoteWindowView.onDisappear`; plus `QuickNotePad.take()`
(`Features/QuickNote/QuickNoteView.swift:95`); plus the ⌘Q per-post
registration inside `AppSession.swift:139–142`, whose own comment reads:
*"The phone has neither a quit door nor the multi-book note; its
background flush rides the liveness authority's own bookkeeping."*

**Phone's face.** **Zero call sites exist today** (verified). The phone's
leaving moments:
1. `MobileWriteScreen.onDisappear` (`MobileWriteView.swift:149`) — the
   note is popped or replaced; today it deregisters and tears down.
2. The background transition —
   `performBackgroundFlush(editors:sync:)` (bottom of
   `Features/Shell/MobileShellRouter.swift`), which today flushes but
   does not savepoint. **On iOS, backgrounding is the nearest thing to
   ⌘Q**: MobileSoul §5.1 — the app dies without warning.
3. A same-post sibling stand-down inside `MobileLivenessAuthority`.

Route (1) and (2) through the one Shared entry, preserving
`performBackgroundFlush`'s ordering (store first, then one sync round).
`savepointOnLeaving` flushes internally, so it **replaces** the flush
call rather than following it — check that against the existing
background-flush pin.

**Also inherited, no work:** migration `v1_13_savepoint_backstop`
(`Persistence/Migrations.swift:410`) moved `idle_commit_hours` `'24' →
'2'` (only where still exactly `'24'`) and the seed itself is now `'2'`
(`:791`). The phone's `IdleCommitScheduler` (Shared) already obeys the
cadence gate, because the gate lives **inside** the two ops.

**Why it matters more than its size.** Her 13j words: *"unless you've
been remembering to commit version history is kind of weak right now."*
On the phone — where she writes in bed and the app is *killed*, not quit
— this is the difference between having history and not.

---

### R8 · Reorder takes — PRIORITY 8 · SMALL

**Capability.** Move a take earlier or later within its fan.

**Brain (exists, core).** `Operations.reorderTake(_:to:)`
(`Operations/Operations+Variant.swift:250`). Ordering resolves through
`OrderedList.positionColumn` + `Operations.fanPosition(_:blockID:at:)`
(`Operations/Operations.swift:149`, `:225`) — the same jitter /
`(position, id)` / no-rebalance code as every pointer list. Exact-row
inverse `restoreFanPosition` (`Operations+UndoInverses.swift:148`). No
touch, no churn; the seal refuses; undo **and** redo.

**Mac's face.** `Features/Takes/TakesBoardView.swift` —
`TakeChooseHeader.ReorderDoors` (~`:1245`): **arrows on the take card**
(◀ ▶ in carousel/slot-split/rail, ▲ ▼ in stack), the end direction
greyed, no arrows on a one-take fan. Entry
`TakesStructureController.moveTake(_:in:by:)` (`:466`). Registry
`.moveTakeEarlier` / `.moveTakeLater`, `doors: [.surface]`, **keyless**
(`CapabilityRegistry.swift:373`, `:379`).

**Phone's face.** `Features/Takes/MobileTakesBrowserView.swift` — the
card's `menuButton` (`:505` on `MobileTakesCardView`) already hosts a
per-card menu; add "Move earlier" / "Move later" rows. **A drag handle is
the wrong first shape**: the browser is a custom UIKit scroll surface,
drag-to-reorder there is real work, and her own instruction anticipates
crowding. Two menu rows are the honest cheap door; a drag can follow if
she wants it.

**Rider, now resolved:** the KnownIssues single-pass fan-copy remap row
was the reason reorder was risky. 13e landed `Operations.copyFan`
(`Operations+Variant.swift:351`) — one machine replacing the
byte-identical single-pass loops in `poolDragCopy` and `copyPost`, with a
second pass landing forward parent pointers after every row exists. Core,
so the phone has it. Nothing outstanding.

---

### R9 · Duplicate-book-name refusal — PRIORITY 9 · SMALL (two lines)

**Capability.** Two live books can't share a name — the phone refuses the
way the Mac does.

**Brain (exists, core, and cleanly so).** Pure rule `BookNaming`
(`key(_:)`, `sameName(_:_:)`) —
**`Sources/VariorumCore/Domain/BookNaming.swift`**. Store-truthful read
`Operations.assertBookNameIsFree(_ name:excluding:)` —
`Operations/Operations+Reading.swift:337`. Error
`OperationError.duplicateBookName(name:)` (`OperationError.swift:217`).
`createReading` / `renameReading` are byte-unchanged — this is a
**door-level** guard by her ruling. Case-insensitive; a finished book
counts as taken; a deleted one frees the name.

**Mac's face — FIVE doors, all verified:**
`Features/Readings/ReadingsViewModel.swift:56` (create), `:74` (rename);
`Features/Shelf/ShelfViewModel.swift:179`;
`Features/BookView/BookStructureModel.swift:446`, `:493`;
`Features/Settings/AppSettingsView.swift:460`. Each pinned by a
discriminating revert in `VariorumTests/DoorSetTests.swift`. Copy home
`BookNameCopy` (`Registry/OpsRefusalCopy.swift:137`).

**Phone's face — ZERO doors call it (verified).** Two one-line additions:
- `Features/Shell/MobileCreateBook.swift:95` — inside `create()`, before
  the `createReading` call (once, before the `switch`, covers all three
  `kind` arms).
- `Features/Shell/MobileBookDetails.swift:112` — inside `rename(_:)`,
  with `excluding: readingID`.

Refusal copy rides the phone's existing `lastError` / `report` road.
**Cheapest row in the file.**

---

### R10 · The tag-chip grammar on listings — PRIORITY 10 · MEDIUM (hoist required)

**Capability (13e E8, absent from PL-10's four lettered items).** The
Library's and Pool's note rows wear the note's own tag chip grammar —
**`✕` to remove, type-to-create `＋`** — plus a bulk "Untag N notes".

**Brain — ⚑ MAC-APP-LOCAL, and 13e explicitly named the hoist.**
`NoteTagsRow` / `NoteTagChips`
(`App/Variorum/Variorum/Features/Tags/NoteTagChips.swift:211`); the
type-to-create brain
`TagAssignmentViewModel.applyTypedPath(_:)`
(`App/Variorum/Variorum/Features/Tags/TagsViewModel.swift:140`). Core ops
used: `applyTag` / `removeTag`. `TagChips.load` now returns whole `Tag`s
rather than paths.

**Mac's face.** `Features/Library/LibraryCatalogView.swift:554` (rows) +
`:398` (bulk "Untag N notes", listing only worn tags via `tagsOn` at
`:229`); `Features/Pool/PoolPostsView.swift:195`;
`Workspace/ContextBar.swift`. Registry `.tagNote`, `doors: [.surface]`,
keyless (`CapabilityRegistry.swift:508`).

**Phone's face.** Wherever the phone lists a note's tags — today the
`tagsChip` sheet (`Features/Write/MobileNoteTags.swift`) and the Library
rows — the same ✕-remove + type-to-create ＋ grammar.

**⚠️ The binding constraint PL-10 states outright:** `applyTypedPath` is
Mac-app-local, so **copying it would make it the SEVENTH row of the
KnownIssues "six mobile brains are byte-copies" family. It must be
HOISTED, never copied** (MobileSoul §3). That is what makes this row
MEDIUM rather than SMALL.

**Bulk semantics (her ratified B-2):** bulk tagging is a
**forgiving batch** — skip the vanished, report partiality (matching
removal's semantics, deliberately NOT multi-delete's all-or-nothing). The
report wording is draft-grade and hers to reword.

---

### R11 · Copy all takes — PRIORITY 11 · SMALL

**Capability.** Copy a block's whole fan as the app's ratified export
shape (the shown take, then `--- Alternates for this block ---`), with a
confirmation naming the count.

**Brain — SPLIT, and the split is already right.** The projection is
**core**: `Queries.blockTakes(_:blockID:) -> (markdown: String,
takeCount: Int)` (`Sources/VariorumCore/Queries/Export.swift:126`);
`exportBlock` now delegates to it, byte-identical. **⚑ The clipboard
writer is Mac-app-local AppKit**: `TakeClipboard` with an injectable
`Destination`, `@MainActor`
(`App/Variorum/Variorum/Features/Takes/TakeClipboard.swift:42, 74, 93`).

**Mac's face.** `EditorCommands.swift:474` (menu bar, **⌘⇧C**, key table
at `:163`); `Features/Takes/TakesShared.swift:141` (take-card
right-click); Write via `EditorViewModel.copyCaretBlockTakes`; board via
`TakesViewModel.copyAllTakes`. Registry `.copyAllTakes`,
`doors: [.menuBar, .contextMenu]`, `"⌘⇧C"`
(`CapabilityRegistry.swift:433`).

**Phone's face.** `Features/Takes/MobileTakeClipboard.swift` — a
~20-line `UIPasteboard` twin with the same injectable destination shape,
wired to the take card's `menuButton` and/or the block long-press menu.
Because the projection is already core, **only the destination half is
platform work** — no hoist needed. A share-sheet row is the natural
phone sibling of "copy".

---

### R12 · Take → block below · takes → blocks — PRIORITY 12 · SMALL

**Capability.** Move one take out into its own block below; or explode a
whole fan into sibling blocks.

**Brain (exists, core — a new file at 13e).**
`Operations.takeToBlockBelow(_:variantID:) -> TakeToBlockResult`
(`Operations/Operations+TakeStructure.swift:75`, `:42`) and
`Operations.takesToBlocks(_ blockID:) -> TakesToBlocksResult` (`:149`,
`:123`).

**⚠️ Semantics the phone must not re-invent — 13e's ruling AR-1, the
phase's one propose-first fork:** these are **MINT-COPY with the source
take ARCHIVED**, deliberately *not* a row move — the architect
independently verified a row move opens a repair-less I10 hole in the
sync repair layer. Six ratified edge defaults (QUESTIONS #58): archived
takes stay behind · locked takes convert, copy unlocked · takes-to-blocks
keeps the CHOSEN take on the source · blanks skipped-and-counted ·
refusals `emptyTakeCannotBecomeABlock` (`OperationError.swift:113`) and
`noConvertibleTakes` (`:117`). One transaction, one undo entry each.

**Mac's face.** `EditorCommands.swift:480` (**⌥⌘⏎**) and `:483`
(**⇧⌥⌘⏎**); `Features/Takes/TakesShared.swift:147`, `:153` (card
right-click); Write via `EditorSurfaceController.runStructural` and
`EditorView.swift:320`, `:325`; Lenses via `LensesBoardView.swift`;
controller entries `TakesStructureController.moveTakeIntoBlockBelow` /
`.turnTakesIntoBlocks`. Registry `.takeToBlockBelow` / `.takesToBlocks`,
`doors: [.menuBar, .contextMenu]` (`CapabilityRegistry.swift:451`,
`:457`). Copy home `TakeStructureCopy` (`OpsRefusalCopy.swift:154`).

**Phone's face.** The take card's `menuButton` menu
(`MobileTakesBrowserView.swift:505`) for take→block-below; the block's
long-press menu (`MobileBlockMenu.menuElements`) for takes→blocks. **No
chords on the phone** — the keybinds have no twin and none is owed.

**Dependencies.** None. Natural batch-mates with R8 and R11 (all three
are take-card menu rows).

---

### R13 · Savepoint cadence + history pruning settings — PRIORITY 13 · SMALL

**Capability.** Choose how often the app leaves history behind, and
whether old quiet savepoints ever prune.

**Brain (exists, core).** `SavepointCadence` (`Models/Enums.swift:96` —
`everySession · idleOnly · onlyOnCommit`, with `savesOnLeaving` /
`savesWhenIdle`) and `HistoryPruning` (`:130` — `standard · never`).
Setters `Operations.setSavepointCadence` / `.setHistoryPruning`
(`Operations+Appearance.swift:93`, `:106`) writing keys
**`savepoint_cadence`** and **`history_pruning`**. Readers in
`Queries/IdleCommit.swift:19, 33, 45`. Pruning brain
`SavepointPruning.prunable(among:now:)`
(`Domain/SavepointPruning.swift` — `ageDays = 90`, `keepNewestQuiet =
10`, quiet rows only; deliberate ⌘S commits are **never** prunable in
either mode).

Both are **synced settings** (document semantics — one answer on every
device, which is what makes "Never means never on every device" true),
and both are E2EE-clean by construction: enum tokens, never prose, so
`setting.value`'s PLAIN classification and its column-fenced disclosure
promise (AppSpec §7, the 14b ladder R1-9) hold unchanged.

**Mac's face.** `Features/Settings/AppSettingsView.swift:169–204` — two
Settings ▸ Writing pickers; copy in
`Features/Settings/SavepointCadenceCopy.swift`
(`SavepointCadenceCopy:20`, `HistoryPruningCopy:55`, including
`insuranceNote`, which names the four insurance occasions the setting
does *not* govern — an honesty line worth carrying to the phone verbatim).

**Phone's face.** `Features/Shell/MobileSettingsView.swift` — a new
section. The phone's Settings today has **Voice · Sync · Tags · (DEBUG)
Tutorial · Performance · Spike** and nothing else.

**Dependency / hoist warning.** The Mac reads and writes the synced
appearance/document settings through
`App/Variorum/Variorum/Theme/ThemeStore.swift` — a **Mac-app-local**
brain for *synced* settings. Building the phone's rows means duplicating
that read/write shape (a new forked brain) or hoisting it. **Hoist.**
See §4(c), and batch this with R17.

---

### R14 · The lens-dangles notice + Restore — PRIORITY 14 · SMALL

**Capability (13j J5, absent from PL-11's six lettered items but folded
into "the faces owed").** When a saved lens's pick points at a take that
was archived or deleted, the lens says so **in place** and offers
one-click Restore.

This is a **direct author ruling** from the 2026-08-03 mobile gate
sitting (recorded on the 13j row, item 5): the surface must *"say loudly
if that take was archived and this is a fallback WITH a button for quick
restore."*

**Brain (exists, core).** `Queries.danglingLensPicks(_:lens:)`
(`Queries/LensQueries.swift:107`) → `Queries.DanglingPick` (`:77`) with
`State = .archived | .deleted | .gone | .foreign` (`:80–89`) —
`effectiveLensSelection` seen from the other side, carrying **why**.

**Mac's face.** `Features/Takes/LensesBoardView.swift` —
`LensFallbackCopy` (`:33`): `restoreVerb = "Restore"`,
`restoreHelp(for:)`, `restoredArchived`, `restoredDeleted`,
`restoredDeletedButArchived`, `nothingToRestore`. The notice renders
under the cell in both column layouts; **a Restore button appears only on
the two states that have a road** (`.archived → unarchiveVariant`,
`.deleted → restoreVariant`); `.gone` / `.foreign` say so instead of
offering a button that could only fail. Restore routed through
`TakesViewModel` (`:1183–1202`); rides `TakesProjection.lensDangles`.
Scope recorded: **lens columns only** — a scratch column's picks are
view-local.

**Phone's face.** `Features/Takes/MobileLenses.swift` /
`MobileLensSheet` — the phone's lenses are "saved peeks" (parity C5), so
the notice belongs on the peek's cell with the same two-states-have-a-road
discipline.

**Dependencies.** None (both restore ops are core). Its Restore door is
more meaningful once R2/R3 exist, but it stands alone.

---

### R15 · The lineage door / preserved-original peek — PRIORITY 15 · SMALL

**Capability.** From a block that came out of a divide or merge, see the
original it was derived from, and put it back.

Her ruling (2026-08-03, 13j row item 3): *"there needs to be some way to
see unplaced blocks from a block that was derived from them"* — a lineage
door **on the successor block**, not only a global list.

**Brain (exists, core).** `Queries.unplacedOrigins` — two overloads
(`Queries/Lineage.swift:104` map form for menu builders, `:151`
`ofBlock:` form), value `Queries.UnplacedOrigin { blockID, originOp, at }`
(`:82`), dated by the **edge's own `created_at`**. **Both overloads
exclude archived blocks** (a 13j batch-6 self-audit fix — otherwise
`placeBlock` would re-place a still-stamped block). Put back:
`Operations.placeBlock`.

**Mac's face.** `App/Variorum/Variorum/Features/Tray/OriginPeek.swift` —
`OriginPeekCopy` (`:44`: `doorVerb(op:)` → "See original from divide…/…
merge…/…extract…", `lineageRow(op:at:)`, `putBackVerb = "Put back in
note"`, `openTrayVerb = "Open this note's tray"`, `noOriginHere`,
`originGone`), `OriginPeekRequest` (`:129`), `OriginPeekModel` (`:137`),
`OriginPeekPanel` (`:196` — read-only, read-cheap).

Doors — `.showOriginBlock`, `doors: [.contextMenu, .palette, .surface]`
(`Capability.swift:576`), per her round-4 ruling *"I think context menu
only… I honestly feel like this will rarely matter to people so it
shouldn't be part of the daily chrome"*: the block's right-click row
(rendered only where a live unplaced original exists); the ⌘K palette
(`Registry/ShellActions.swift:466`); **and the History face's lineage
row** (her round-5 amendment, *"since it is lineage"*).

**Phone's face.** A "See original" row in the block's long-press menu
(`MobileBlockMenu.menuElements`) and in R5's History past region, landing
on R3's tray with the row revealed (the Mac's
`TrayRequest.revealBlockID`, `TrayPanel.swift:156`). The phone likely
does not need a separate peek panel — the tray with the row marked is the
honest cheap shape, and the Mac's peek keeps the tray door as its own
second action anyway.

**Dependencies.** R3 (the landing) and R5 (the second door). Cheap once
both exist; near-worthless before either.

---

### R16 · PL-9's three judgment acts — PRIORITY 16 · SMALL (mostly judgment)

PL-9 says explicitly that 14d's account work **reached the phone by
construction** (all `App/Variorum/Shared/`) and that mobile owes
**judgment, not code**. The three acts, verified:

**(a) Verify the account sheet reads right on the phone.** The unified
Stargazing sheet is `Shared/AuthViews.swift`; its only platform fence is
`#if os(macOS) .frame(minWidth: 460, minHeight: 340)` (`:165–166`), so
the phone gets the full sheet. A look-at-it act on device.

**(b) DECIDE the phone's bridge-connect door.** Confirmed shape:
`Shared/AuthViews.swift:290–308` renders the "Journal bridge
(Fragments)" row and its **"Connect with your Stargazing account"**
`PageDoor` **unconditionally on both platforms**. But the phone passes no
`bridgeEnabled` — `VariorumMobileApp.swift:50` constructs
`AppServices(session:storeVariant:backupEnabled: false)` with the
parameter defaulted `false` (`Shared/AppServices.swift:144`), so
`allowsBridge` is false (`:189`) and `BridgeStatusViews` shows **"Bridge
off"** with no door (`Shared/BridgeStatusViews.swift:23`). **Net: the
phone can connect a Fragments session that nothing on the phone ever
consumes.** Three options:
  - *(i) Hide the row on the phone* — honest, one `#if os(iOS)`; costs
    her the ability to connect from the phone.
  - *(ii) Keep it as account plumbing*, labelled truthfully (it *is* an
    account link; the bridging happens on the Mac).
  - *(iii) Turn the phone's bridge on* — a capability decision, not a
    face decision, and out of this round's scope.
  **Recommendation: (ii)** with one honest clarifying line — it obeys the
  no-redirect principle (a road exists) without promising bridging the
  phone does not do.

**(c) Exercise the iOS `presentationAnchor` arm once.**
`Shared/SignInFlow.swift:88–106` has a real `#else` iOS branch (connected
scenes → foreground-active → `keyWindow`) that **compiles but has never
run on a device.** If (b) keeps the door, drive it once on hardware. If
(b) hides it, record the arm as unreachable rather than leaving untested
live code.

---

### R17 · The rest of the document settings — PRIORITY 17 · MEDIUM

Not in the ledger; see §4(b). The phone exposes **none** of the synced
document settings the Mac does. Verified: `setSeamsVisible`,
`setEditingIndicator`, `setInlineComments`, `setFollowTheScroll`,
`setDefaultSegmentation` all have Mac call sites
(`Features/Settings/AppSettingsView.swift:93, 96, 103, 114, 152` via
`Theme/ThemeStore.swift:56–69`) and **zero** mobile call sites.

Several are meaningful on the phone — seam visibility, the editing
indicator, default segmentation, and **follow-the-scroll**, which AppSpec
§12 (R25) makes a takes-viewing option in *all* modes. Because they are
*synced document semantics*, the phone today silently ignores choices she
made on the Mac.

Same `ThemeStore` hoist dependency as R13 — build them in one batch.

---

### R18 · Whole-block-selection delete routing — PRIORITY 18 · SMALL

**Capability (13j J9).** Selecting a whole paragraph (or several) and
pressing delete removes those blocks through the delete compound, rather
than refusing with a guessed message.

**Brain — ALREADY IN `Shared/`.**
`BlockRangeIndex.wholeBlockRun(covering:)`
(`App/Variorum/Shared/EditorBrain/BlockRangeIndex.swift:280`) — purely
geometric; ranges of exactly 1 character are excluded so A7's
empty-block carve and #34's seam merge keep every case they ruled. **The
phone can adopt the same road with no hoist.**

**Mac's face.** `planWholeBlockDeletion` → the shared
`runBlockDeleteCompound`
(`Features/Editor/EditorSurfaceController.swift:838`). Her ratified
consequences: a whole-paragraph delete removes a **fanned** block, takes
and all (#66(b)); N whole paragraphs delete all N (#66(c), formally
superseding the Phase-11 join-and-leave-empty outcome).

**Phone's face.** `Features/Write/MobileStructural.swift` /
`MobileEditorTextView` — the phone's editor has selection and a delete
path; routing a whole-block-run selection into the delete compound is the
same shape. Worth a measurement first: whether the phone's selection
grammar makes whole-paragraph selection common enough to matter. **A
candidate, not an obligation** — but the brain is free, which is why it
is a row rather than a footnote.

**Not owed alongside it:** the Mac's **⌘Z→⌥⌘Z hint**
(`Features/Editor/EditorUndoHint.swift`) — PL-11 rules it out explicitly:
*"no chord culture on the phone — judgment, not code."*

---

### R19 · Callout swatches + a real emoji picker — PRIORITY 19 · SMALL (her word)

**Mac (13e E1).** `App/Variorum/Variorum/Features/Editor/CalloutMenu.swift`
— coloured swatches on every menu row (`rows:82`, `swatchImage:126`,
`isDarkAppearance:114`), and the system **"Emoji & Symbols…"** picker
(`emojiPickerButtonTitle:174`, `emojiAccessory:179`, `promptEmoji:212`,
calling `NSApp.orderFrontCharacterPalette`) across three renderers with a
drift pin (`rowTitles:100`).

**Phone today.** `Features/Write/MobileBlockMenu.swift:141`
(`calloutSubmenu`) renders plain text rows from `MobileCallout.names`
(`Features/Write/MobileCallout.swift:23` —
`["blue","green","sand","violet","rose"]`), and the "emoji" door is a
**plain text-field alert** (`promptEmoji:181`). Colour swatches in a
`UIMenu` are `UIImage` on `UIAction` (straightforward); a real emoji
picker on iOS means an emoji-only keyboard field or a small grid — a
genuine design call, hers.

**Hoist note.** `CalloutPalette` lives at
`App/Variorum/Variorum/Features/Editor/BlockDecor.swift:253` and the
phone keeps a byte-copy of the same five names. **Already forked today** —
a sixth colour added Mac-side would silently not exist on the phone.
§4(c).

---

### R20 · Block multi-select + multi-delete — PRIORITY 20 · MEDIUM

Not in PL-10's four lettered items. 13e's **E2** shipped it Mac-side:
⌘-click toggles a block, ⌘⇧-click extends a run, picked blocks get a
wash+accent highlight, and one gesture deletes them all under **one**
⌥⌘Z entry.

**Brain — ⚑ MAC-APP-LOCAL.** `BlockSelection`
(`toggle` · `extend(to:in:)` · `prune(to:)` · `inOrder(_:)` ·
`isContiguousRun`) —
`App/Variorum/Variorum/Registry/BlockSelection.swift`. **The core it
calls is already shared**: `deleteBlock` (`.none` precondition) +
`UndoStack.withCompound`.

**Mac's faces.** Write banner `Features/Editor/EditorView.swift:197, 216`;
Write context menu `Features/Editor/EditorViewModel.swift`; board banner
`Features/Takes/TakesBoardView.swift`; card context menu
`Features/Takes/TakesShared.swift:178`. Gesture:
`Features/Editor/EditorTextView.swift:484` (`mouseDown`, after the link
door, before `super`) and `Surface/PaneSurface.swift:515`. Highlight:
`BlockDecor.State.selectedBlockIDs` + pooled `DecorRectView`. Registry
`.deleteSelectedBlocks`, `doors: [.contextMenu, .surface]`, **no chord**
(`CapabilityRegistry.swift:413`). Copy `BlockSelectionCopy`
(`OpsRefusalCopy.swift:186`).

**Phone's face.** **The phone has no pointer chord**, so this is a
*deliberate design*, not a port: an "Edit"/select mode in the block-list
sheet (`Features/Write/MobileBlockList.swift`, raised from the
`blocksChip`) with checkmarks and one confirmed delete-all naming the
count. 13e's own record says the same thing.

---

### R21 · In-note replace, then replace-all-in-every-take — PRIORITY 21 · MEDIUM

Not in PL-10's four lettered items. **Two layers, and the phone is behind
on both:**

- The phone's find is **find-only**.
  `Features/Write/MobileEditorTextView.swift:728` sets
  `override var supportsTextReplacement: Bool { false }`, with a recorded
  reason at `:713–726`: iOS's system replace road applies Replace All as
  **one coalesced multi-block storage edit** the identity pipeline cannot
  take, so the phone declines at the protocol's own switch and the system
  never offers a replace field. The in-note replace face is deferred to a
  UIKit-spelled application — **and the comment itself names the
  takes-aware replace as downstream of it.**
- 13e's **E9 Replace-All-in-Every-Take** therefore has no phone
  foundation. Its rule brain `TakesReplacePlan` is Mac-app-local
  (`Features/Editor/EditorFind.swift`); its landing is **core** —
  `Operations.editTakesAtomically(_:undoLabel:)`
  (`Operations/Operations+TakeEdits.swift:49`, one transaction, one undo
  entry, `expectedText` CAS). So if the phone ever grows a find bar,
  `TakesReplacePlan` is a **hoist, not a copy**.

Real work, correctly deferred at the time, and worth a row so it does not
become a lost capability.

---

### R22 · A deletion chapter in the phone's pocket guide — PRIORITY 22 · SMALL

13j grew the Mac's tutorial spine by a **4-lesson deletion chapter**
(spine 51/7 → **63/8**). The phone has its own pocket guide with a
walk-asserted plan contract
(`Features/Tutorial/MobileTutorialSeeder.swift:71`):

```
welcome                · start here · getting around
writing                · blocks & typing · formatting
takes                  · your first take · swipe & choose · the browser · lenses
structure              · divide · divide with takes · merge
the library of things  · comments & callouts · the seal · the voice switch
```

No deletion chapter. Under the 13b tutorial-as-spec precedent (which the
phone adopted at parity Stage B), **the lessons ARE the acceptance
script** — `MobileTutorialWalkTests` executes every lesson's acts
headlessly, and `MobileTutorialBookShapeTests` pins the seed against the
plan. A deletion chapter should land **in the same round as R1–R3**,
which is also how the round proves its own doors end-to-end.

---

### R23 · The voice preference is a FORKED BRAIN — PRIORITY 23 · SMALL

The Mac writes the voice to the **synced `setting` table**
(`Operations.setThemeVoice` → key `theme_voice`,
`Operations+Appearance.swift:19`, via `Theme/ThemeStore.swift:53`). The
phone writes it to **`UserDefaults`**
(`Theme/MobileVoicePreference.swift`, driven from
`MobileShellRouter.setVoice`). Consequence: **the voice she picks on the
Mac never reaches the phone, and vice versa** — for a setting that is
document semantics by design.

MobileSoul §3's reverse reading is exact: *"mobile never forks a brain. A
behaviour difference between platforms is either a RULED compromise
(recorded) or a bug."* This one is neither — it is unrecorded. Either
ratify it as a deliberate per-device preference (defensible — the phone's
voice may genuinely want to differ from the desk's) or move the phone
onto `theme_voice`. **A one-line judgment for her, not an autonomous
call.**

---

### R24 · Design calls held for her (PL-10)

- **The ●n comment marker's side.** The phone's marker sits **trailing**
  by its own M12 ruling; 13e batch 6 swept the Mac's comment affordances
  **LEFT** and flagged the phone rather than changing it. Her call
  whether the phone follows.
  *Live rider:* **13l §8c carries her ruling to REMOVE the Mac's
  left-margin comment ＋ entirely** (*"it's too crowded and I don't like
  the look of seeing it there"*), and 13u item 3 is a fuller comments-area
  rework. The Mac's left placement is itself in flux — **wait for 13l
  before moving the phone.**
- **The margin-hover comment door.** The Mac's add-door is a hover
  affordance (`BlockDecor.leftAddChipRect`,
  `Features/Editor/BlockDecor.swift:243`); **the phone has no hover.** A
  tap shape is hers to pick.
- **Callout swatches / emoji picker** (R19) — "at her word".
- **13j's ⌫ badge counts deleted only** (#67(a)) — her recorded
  watch-item; the phone should match and watch, not diverge quietly.

---

## 4. Closing findings

### (a) What in the ledger I judge NOT owed

- **PL-11's stated exclusions are right and I add nothing.** The
  divide/merge quick defaults are the phone's **own** (Q-M2 / C5 — the
  phone shipped first; the Mac caught up at J4/J4b). The two ceremony
  doors (**⌥⌘⇧D** "Divide with Ceremony…", **⌥⌘⇧M** "Merge with
  Ceremony…", `Capability.swift:178`, `:206`) and the carry-all-inside-an
  N-way-chain stay Mac-only per her ruled exclusion list. The **⌘Z→⌥⌘Z
  hint** has no phone twin. **W26-class system-wide hotkeys are
  impossible on iOS** (`RegisterEventHotKey` does not exist there) — the
  share-sheet / App Intents road is the phone's future-list equivalent,
  not this round's.
- **13e E12 (canvas jitter) and the canvas bank** — canvas editing is on
  her **ruled exclusion list** (MobileSoul §4.5). Not owed. **But keep
  the standing rider 13e recorded:** the jitter's mechanism was a
  *SwiftUI* fact, not a Mac one — **any future iOS drag that moves its
  own gesture view via `.offset`/frame must be born in a NAMED coordinate
  space.** Verified at 13e: `VariorumMobile/` + `Shared/` contain zero
  `DragGesture` constructions today, so the rider is preventive.
- **13e E3 (⌘-click merge selection)** — the *chord* is not owed; the
  capability (merge a fanned pair) the phone already has in its own shape
  (C5's carry-all merge).
- **13e E11 (book-icon registry declaration) and E15 (Takes-board policy
  routing)** — Mac-internal. E15 in particular: the phone's
  `MobileEditorViewModel.observeTakesProjection` → `ingest(_:fromDelivery:)`
  was **already** policy-routed at the S3 ladder; the Mac was the one
  catching up, and that KnownIssues row is now closed on both platforms.
- **13e E10 (copy doors flush first)** — the brain
  `AppSession.runCopying(from:_:)` is in **`Shared/`**
  (`Shared/AppSession.swift:195`), and the phone's membership chip
  already calls `divergeForBook`. Nothing owed.
- **13e batch 9 (the Keychain lazy/off-main load)** — every changed file
  is in `Shared/` (`AuthSession.swift:278`,
  `EncryptionKeychain.swift:142`, `EncryptionSession.swift`), so **the
  phone has the fix by construction.** Launch-path benefit, zero work.
- **13j's core-side machinery** — stranded originals riding their
  family's clock, the say-so returner, the ledger, the verdict hardening,
  `voidPurgeIntents`, the marker 6→7 lockstep — all core or `Shared/`.
  Verified: `PurgeJanitor` is constructed at `Shared/SyncSession.swift:110`
  and `LocalPurge` scheduled at `Shared/AppServices.swift:285`, both on
  the phone.
- **PL-9's three items are judgment acts**, and I kept them as such (R16)
  rather than inventing code the ledger says is not owed.

### (b) Capabilities the ledger MISSED (my own closeout sweep)

The ledger prose is good but not exhaustive. Each of these is a row
above:

1. **Delete a book (R4).** PL-11 names notes and blocks. `TrashItem.Kind`
   carries a `.book` case the phone can never produce — that is the tell.
2. **The tag-chip grammar on listings (R10)** — 13e **E8**, absent from
   PL-10's four lettered items. PL-10 mentions the `applyTypedPath` hoist
   *constraint* without naming the capability the constraint serves.
3. **The lens-dangles notice + Restore (R14)** — 13j **J5**, and a direct
   author ruling from the mobile gate sitting. PL-11's six lettered items
   do not name it.
4. **Block multi-select / multi-delete (R20)** — 13e **E2**.
5. **Replace, and replace-all-in-every-take (R21)** — 13e **E9**. The
   phone lacks even single-note replace.
6. **The document settings section (R17)** — five synced settings the Mac
   exposes and the phone does not. These predate 13e/13j (Phase 13/13d
   era) and simply never got a ledger row; they are synced document
   semantics, so the phone silently ignores Mac-side choices.
7. **The pocket guide's deletion chapter (R22)** — 13j **J10** grew the
   Mac's spine; the phone's spine is its own acceptance script.
8. **The voice-preference fork (R23)** — never a phase deliverable, which
   is exactly why no ledger row caught it. A live §3 violation.
9. **Whole-block-selection delete routing (R18)** — 13j **J9**, whose
   brain already sits in `Shared/`.
10. **`MobileBlockMenu.deleteConfirmDetail` goes stale (§2.1).** Not a
    capability, but a *shipped promise* this round must maintain —
    recorded so it is not forgotten mid-batch.

### (c) Brains that must be HOISTED, not copied (MobileSoul §3)

The KnownIssues **"six mobile brains are byte-copies of Mac app-local
view-model code"** row is the standing precedent; PL-10 already extends
it with `applyTypedPath`. Building the faces above adds these:

| Brain | Where it lives now | Needed by | Note |
|---|---|---|---|
| **`ThemeStore`** — read/write of the *synced* document settings (`theme_voice`, `seams_visible`, `editing_indicator`, `inline_comments`, `follow_the_scroll`) | `App/Variorum/Variorum/Theme/ThemeStore.swift` — **Mac app-local, for SYNCED settings** | R13, R17, R23 | The clearest hoist in the file. Move to `App/Variorum/Shared/`; the Mac's pins ride unmodified (the 3C parity pattern). |
| **`TagAssignmentViewModel.applyTypedPath`** — the type-to-create tag rule | `Features/Tags/TagsViewModel.swift:140` | R10 | PL-10 names it explicitly: copying it makes it the **seventh** six-brains row. Hoist, never copy. |
| **`CalloutPalette`** — the callout colour vocabulary + defaults | `Features/Editor/BlockDecor.swift:253`; the phone keeps a byte-copy at `MobileCallout.swift:23` | R19 | **Already forked today.** A sixth colour added Mac-side would silently not exist on the phone. |
| **`CalloutMenu.rows`** — the callout menu's row vocabulary and order (it carries a drift pin across three *Mac* renderers) | `Features/Editor/CalloutMenu.swift:82` | R19 | The drift pin proves the vocabulary is load-bearing; it should span four renderers, not three. |
| **`RecoveryPath` / `TrayPath` / `BlockPastCopy` / `OriginPeekCopy` / `LensFallbackCopy`** — the deletion story's user-facing sentences (`daysLeftLabel`, `archivedForever`, `goesWithItsFamily`, the three put-back receipts, the count-by-kind Empty-Trash confirm, the three honest purge-receipt populations) | `Features/Library/RecoveryView.swift:73–186`, `Features/Tray/TrayPanel.swift:67–132`, `Features/Tray/BlockPastSection.swift:40–88`, `Features/Tray/OriginPeek.swift:44`, `Features/Takes/LensesBoardView.swift:33` — all Mac app-local | R2, R3, R5, R14, R15 | Each file's own comment says the strings live in one home *because copy elsewhere promises the surface by name and would drift.* **That argument does not stop at the platform boundary.** Hoist at least the semantic-bearing ones (clock language, archive-has-no-clock, the count-by-kind confirm, the three receipt populations); pure Mac chrome wording can stay. |
| **`TakeClipboard`'s composition half** | `Features/Takes/TakeClipboard.swift:74` | R11 | Mostly already right — the *projection* is core (`Queries.blockTakes`); only the `NSPasteboard`/`UIPasteboard` destination is per-platform. Verify nothing else leaked into the Mac half. |
| **`BlockSelection`** | `Registry/BlockSelection.swift` | R20 | Only if she wants phone multi-select; no pointer chord means the phone's *gesture* differs, but the selection **rule** should be one brain. |
| **`TakesReplacePlan`** | `Features/Editor/EditorFind.swift` | R21 | Not now (no phone find bar). A hoist if one ever ships — 13e says so explicitly. |

**Sibling implementations to be aware of (not hoists, recorded so they
are not mistaken for drift):** the Mac's `CarryAllMerge`
(`Features/Editor/FannedDefaults.swift:46`) and the phone's C5 carry-all
merge composition are **siblings**, built independently — the phone's
came first and is the reference the Mac's copied. Any future change to
the carry-all rule must touch both, or become one brain.

**One process note for whoever runs the round.** Several of these hoists
touch Mac app code. Per MobileSoul §3 that is the **correct** seam (a
mobile ladder fix was explicitly ruled the *wrong* seam for a
Mac-touching refactor at C3-R1-4) — but it means the round's batches will
carry Mac-suite runs, and the Mac's pins must ride unmodified as proof.
Plan for it rather than discovering it mid-batch.

---

## Appendix A — baselines and environment facts (verify with your own runs)

- Suites at the last closeout (13j, 2026-08-19): core **1350/141** · Mac
  **1546/269 FULLY GREEN** · tutorial spine **63/8** · mobile
  **314/60**.
- Mirror lockstep marker **7**, live. `SyncSchema.lockstepVersion = 7`
  (`Sources/VariorumCore/Sync/SyncSchema.swift:90`) — the phone speaks it
  through the shared core.
- **ZERO schema is expected for this round.** Every capability above
  rides existing tables and existing ops. Anything firming toward a
  schema change is a SyncSpec §12 lockstep event and a **STOP** for her
  explicit go.
- **ZERO `Sources/VariorumCore/Sync/` lines** expected — the standing
  rider applies if any appear.
- The **A4 fence** binds: Debug = dev store, never her corpus; Release
  installs are the real app.
- iPhone-only, portrait-only stays pinned (MobileSoul §4.5 — declaring
  iPad capability forbids portrait-only; never declare it).

## Appendix B — files this round would create or touch

**New (phone):**
`Features/Shell/MobileTrashView.swift` ·
`Features/Shell/MobileTrashModel.swift` ·
`Features/Write/MobileTrayView.swift` (+ model) ·
`Features/Takes/MobileTakeClipboard.swift`

**Touched (phone):**
`Features/Shell/MobileLibraryView.swift` (D1 row, Trash entry, tag chips) ·
`Features/Shell/MobileLibraryViewModel.swift` (filter) ·
`Features/Shell/MobileShelfView.swift` (D2 row) ·
`Features/Shell/MobileBookDetails.swift` (R9, D2) ·
`Features/Shell/MobileCreateBook.swift` (R9) ·
`Features/Shell/MobileSettingsView.swift` (R13, R17) ·
`Features/Shell/MobileShellRouter.swift` (R7) ·
`Features/Write/MobileWriteView.swift` (⋯ menu, tray chip) ·
`Features/Write/MobileBlockMenu.swift` (D4, R15, R19, and the stale confirm sentence) ·
`Features/Write/MobileBlockList.swift` (R20 select mode, R3 tray door) ·
`Features/Write/MobileNoteTags.swift` (R10) ·
`Features/Write/MobileStructural.swift` (R18) ·
`Features/Takes/MobileTakesBrowserView.swift` (R8, R11, R12 card menu rows) ·
`Features/Takes/MobileTakeHistorySheetView.swift` + `MobileTakeHistory.swift` (R5) ·
`Features/Takes/MobileLenses.swift` (R14) ·
`Features/Tutorial/MobileTutorialSeeder.swift` (R22)

**Touched (Mac / Shared — the hoists, §4(c)):**
`App/Variorum/Variorum/Theme/ThemeStore.swift` → `App/Variorum/Shared/` ·
`Features/Tags/TagsViewModel.swift` (`applyTypedPath`) ·
`Features/Editor/BlockDecor.swift` (`CalloutPalette`) ·
`Features/Editor/CalloutMenu.swift` (row vocabulary) ·
`Features/Takes/TakeClipboard.swift` (verify the split) ·
the five deletion-copy homes listed in §4(c)

**Tests.** Every new phone face gets its pins in
`App/Variorum/VariorumMobileTests/` alongside the existing suite. **The
R2 and R3 pins must mount the real surface and drive the real button** —
§2.4 — and both surfaces need a real device/simulator hand-check, because
`List`-backed surfaces cannot be captured by the screenshot drive.
