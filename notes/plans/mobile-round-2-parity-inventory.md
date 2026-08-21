# Variorum for iPhone — Round 2 Parity Inventory (COLD SURVEY)

**Status: a SURVEY, not a plan.** Produced 2026-08-21 by a cold surveyor
in the `~/dev/variorum-mobile` worktree (branch `mobile`, fast-forwarded
to `main`'s tip). Nothing in the source tree was modified. Every symbol
named below was grep-verified against the tree at that tip; every "the
phone has no X" claim is a verified sweep, not an inference.

**What this is for:** the Mac phases that closed since the phone's last
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

So **everything is in scope.** The ordering below is by how much daily
use each row unblocks, not by what to drop.

**Her instruction on ONE row needing more than parity, verbatim:**

> "one of the phases (trash) needs more than even phase parity - the
> actual deletion buttons weren't added, they're in the next variorum
> core phase, even though the mechanism was added, and you should add
> deletion buttons."

That row is **PL-11**, and §2 below is written to it. Read §2 before
anything else in this file.

**The sweep basis (belt and braces — MobileSoul §6's mobile duty).**
`git log` over `notes/DetailedPlanForPhases.md` confirms exactly four
phase closeouts since the 2026-08-11 seam: **14c** (2026-08-11 — PL-8,
already CLOSED at 14d), **14d** (2026-08-16 — PL-9), **13e**
(2026-08-18 — PL-10), **13j** (2026-08-19 — PL-11). No un-ledgered
phase closed in the window. What the ledger's *prose* missed inside
those phases is §4(b).

---

## 1. The one-screen summary

Sizes: **SMALL** = a door over a brain that already exists · **MEDIUM** =
a new surface · **LARGE** = a surface + its own state + its own held
observation.

| # | Capability | Source row | Size | Priority |
|---|---|---|---|---|
| R1 | **Delete a note** — the phone has NO note-delete door anywhere | PL-11 (+ her "more than parity") | SMALL | **1** |
| R2 | **The Trash** — see what's deleted, Put back, Delete Now, Empty Trash | PL-11 (b) | LARGE | **2** |
| R3 | **The per-note tray** — deleted + archived blocks + preserved originals, Put back | PL-11 (a) | MEDIUM | **3** |
| R4 | **Delete a book** — the phone can't delete a reading either | §4(b) missed | SMALL | **4** |
| R5 | **Deleted takes come back** — the History face's past region | PL-11 (d) | MEDIUM | **5** |
| R6 | **Archive / unarchive a block** | PL-11 (c) | SMALL | **6** |
| R7 | **The phone's own on-leaving savepoint funnel** | PL-11 (e) | SMALL | **7** |
| R8 | **Reorder takes** | PL-10 (a) | SMALL | **8** |
| R9 | **Duplicate-book-name refusal** at create + rename | PL-10 (b) | SMALL | **9** |
| R10 | **Copy all takes** (`UIPasteboard` twin) | PL-10 (c) | SMALL | **10** |
| R11 | **Take → block below · takes → blocks** | PL-10 (d) | SMALL | **11** |
| R12 | **Savepoint cadence + history pruning settings rows** | PL-11 (f) | SMALL | **12** |
| R13 | **The lineage door** to a preserved original | PL-11 (rides a+b) | SMALL | **13** |
| R14 | **PL-9's three judgment acts** — verify the sheet, decide the bridge door, exercise the iOS auth anchor | PL-9 | SMALL | **14** |
| R15 | **The rest of the document settings** — segmentation, seams, editing indicator, inline comments, follow-the-scroll | §4(b) missed | MEDIUM | **15** |
| R16 | **Callout colour swatches + a real emoji picker** | PL-10 (her word) | SMALL | 16 |
| R17 | **Block multi-select + multi-delete** | §4(b) missed (13e E2) | MEDIUM | 17 |
| R18 | **In-note replace, then replace-all-in-every-take** | §4(b) missed (13e E9) | MEDIUM | 18 |
| R19 | **A deletion chapter in the phone's pocket guide** | §4(b) missed (13j J10) | SMALL | 19 |
| R20 | **The voice preference is a FORKED BRAIN** (UserDefaults vs synced `theme_voice`) | §4(c) | SMALL | 20 |
| R21 | **Two design calls held for her** — the ●n comment marker's side; the margin-comment door's tap shape | PL-10 | — | her word |

**The three things that matter most, in one line each:**

1. **The phone cannot delete a note, and nothing it deletes can ever come
   back** (R1–R3). Every other row is polish beside this.
2. **The Mac's own purge doors are DEAD at this tip** — a real SwiftUI
   observation defect, traced but unfixed (13l owns it). If the phone's
   Trash copies the Mac's pattern it inherits the same dead door. §2.4
   says exactly how to not do that.
3. **Seven brains are now forked or Mac-local** (§4(c)). Each one the
   phone needs is a hoist, not a copy — MobileSoul §3, and the
   KnownIssues "six mobile brains" row is the precedent.

---

## 2. PL-11 — DELETION, THE TRASH & THE PURGE (the row that needs MORE than parity)

### 2.1 What the phone can and cannot do TODAY (verified sweep)

| Act | Phone today | Verified at |
|---|---|---|
| Delete a **block** | YES — long-press → Delete Block, with a confirm | `Features/Write/MobileBlockMenu.swift:258` (`confirmDelete`), `:279` (`delete`) → `MobileStructural.deleteBlock` (`Features/Write/MobileStructural.swift:527`) |
| Archive / delete a **take** | YES — the takes browser's card menu | `Features/Takes/MobileTakesBrowser.swift:466` (`archiveVariant`), `:472` (`deleteVariant`), `:221` (`unarchiveVariant`) |
| Delete a **comment** | YES, and restore it | `Features/Write/MobileComments.swift:123`, `:127` |
| Delete a **reference** | YES | `Features/Write/MobileReferences.swift:162` |
| Delete a **tag** | YES | `Features/Shell/MobileTagManager.swift:242` |
| Delete a **note** | **NO DOOR ANYWHERE** | `deleteContainer` appears in `VariorumMobile/` exactly once — in `Features/Tutorial/MobileTutorialSeeder.swift:166`, the seeder's own cleanup |
| Delete a **book** | **NO DOOR ANYWHERE** | `deleteReading` appears once — `MobileTutorialSeeder.swift:170` |
| **Restore** anything | **NO DOOR ANYWHERE** | zero `restoreBlock` / `restoreContainer` / `restoreReading` / `restoreVariant` / `unarchiveBlock` call sites in `VariorumMobile/` |
| See a **Trash** | **NO SURFACE** | zero `Queries.trash` call sites in `VariorumMobile/` |
| See a note's **tray** | **NO SURFACE** | zero `Queries.trayBlocks` / `archivedBlocks` / `preservedOriginals` / `trayCounts` call sites |

The phone's own delete confirm says this today, and it is currently true:

> `MobileBlockMenu.deleteConfirmDetail` = *"The block leaves this note,
> with its takes. There's no undo here."*
> (`Features/Write/MobileBlockMenu.swift:255`)

**That literal must change when R3 lands** — a tray makes "there's no
undo here" false, and a stale honest sentence becomes a dishonest one.
The comment above it already names this as the parity ledger's row.

### 2.2 The core/Shared brains the phone inherited FREE (verified)

Everything below is `Sources/VariorumCore/` or `App/Variorum/Shared/` —
the phone can call all of it today.

| Brain | Symbol | File |
|---|---|---|
| The 30-day read-side clock | `TrashWindow` (`.cutoffStamp`, day math) | `Sources/VariorumCore/Domain/TrashWindow.swift:22` |
| The whole Trash listing, filtered + windowed | `Queries.trash(_:now:kinds:oldestFirst:limit:)` | `Sources/VariorumCore/Queries/Trash.swift:82` |
| The Trash row model + its five kinds | `Queries.TrashItem`, `.Kind` (`note · book · block · take · preservedOriginal`) | `Queries/Trash.swift:12`, `:13` |
| A note's deleted blocks | `Queries.trayBlocks` | `Queries/PoolAndTray.swift:89` |
| A note's archived blocks | `Queries.archivedBlocks` | `Queries/Trash.swift:445` |
| A note's preserved originals | `Queries.preservedOriginals` | `Queries/PoolAndTray.swift:163` |
| The tray door's badge counts | `Queries.trayCounts` | `Queries/PoolAndTray.swift:253` |
| Stranded originals + their family clocks | `Queries.strandedOriginals`, `.originFamilyClocks`, `.originalsStrandedBy`, `.OriginFamilyFate` | `Queries/Trash.swift:249`, `:343`, `:401`, `:318` |
| A block's past (lineage row + deleted takes) | `Queries.blockPast`, `Queries.BlockPast` | `Queries/EditorSupport.swift:177`, `:165` |
| Unplaced blocks | `Queries.unplacedBlocks`, `.UnplacedBlock` | `Queries/PoolAndTray.swift:312`, `:298` |
| Archive / unarchive a block | `Operations.archiveBlock`, `.unarchiveBlock` → `BlockUnarchiveLanding` | `Operations/Operations+BlockArchive.swift:49`, `:97` |
| Put a deleted take back | `Operations.restoreVariant` → `VariantStatus` | `Operations/Operations+Deletion.swift:101` |
| True delete | `Operations.requestPurge(_ targets:)` | `Operations/Operations+Purge.swift:43` |
| The purge janitor + the ledger | `PurgeJanitor`, `.reconcileLedger`, `LocalPurge` | `Sources/VariorumCore/Sync/PurgeJanitor.swift:25`, `:239`, `:742` |
| The janitor wired into rounds | `SyncSession` (line 102–111) | `App/Variorum/Shared/SyncSession.swift` |
| The local (unsynced) purge cadence | `AppSession.sweepLocalPurge`, `AppServices.localPurgeTask` | `Shared/AppSession.swift:81`, `Shared/AppServices.swift:102–107`, `:283–299` |
| The on-leaving savepoint | `AppSession.savepointOnLeaving(_ postID:)` | `Shared/AppSession.swift:239` |
| The cadence + pruning vocabulary | `SavepointCadence`, `HistoryPruning` | `Sources/VariorumCore/Models/Enums.swift:110`, `:144` |
| Their setters | `Operations.setSavepointCadence`, `.setHistoryPruning` | `Operations/Operations+Appearance.swift:93`, `:106` |
| The pruning brain | `SavepointPruning.prunable` | `Sources/VariorumCore/Domain/SavepointPruning.swift:43` |

**Consequence: PL-11 is almost entirely FACE work.** The phone's purge
already runs — `AppServices` starts `localPurgeTask` and `SyncSession`
starts `PurgeJanitor` on the phone exactly as on the Mac. What the phone
lacks is every door onto it.

### 2.3 The deletion DOORS this round must build — enumerated, with what each must do

Her instruction is that the phone gets **real, working deletion buttons
this round regardless of the Mac's state.** Here is the exact door set,
with the semantic each carries. Three semantics exist and must never be
confused in copy:

- **Move to Trash** = an ordinary tombstone. Recoverable for 30 days
  (`TrashWindow`). This is what "Delete" means everywhere outside the
  Trash surface.
- **Archive** = kept, out of view, **no clock**. `RecoveryPath` on the
  Mac words this "kept — no clock". Never a deletion.
- **True delete / purge** = `requestPurge`. Unrecoverable. **In-Trash
  only, confirm every time** (her standing 13j round-10 rider).

| Door | Where on the phone | Semantic | Confirmation |
|---|---|---|---|
| **D1 · Delete Note** | Library row long-press (`Features/Shell/MobileLibraryView.swift:210`, beside the existing Star row) AND the note masthead (a new row; the masthead has no ▾ menu today — see R1's shape note) | Move to Trash | **YES** — container-scale, deliberate. Receipt names the Trash and its clock. |
| **D2 · Delete Book** | Shelf row long-press (`Features/Shell/MobileShelfView.swift:162`, beside Pin/Star) and/or `MobileBookDetailsSheet` | Move to Trash (`deleteReading`) | **YES** — same wording family as D1 |
| **D3 · Delete Block** | EXISTS (`MobileBlockMenu`) | Move to Trash | keeps its confirm; **its detail sentence must be rewritten once R3 lands** |
| **D4 · Archive Block** | a new `MobileBlockMenu` row beside Delete | Archive (no clock) | **NO** — in-flow, reversible, no clock |
| **D5 · Put back** (note · book · block · take · preserved original) | Trash rows (R2) and tray rows (R3) | Restore | NO |
| **D6 · Delete Now** | **Trash rows ONLY** | **True delete** | **YES, EVERY TIME** — her ruling |
| **D7 · Empty Trash** | **The Trash surface ONLY** | **True delete, everything** | **YES** — and the confirm **names the full count by kind** (her 13j round-8 ruling; the Mac's `RecoveryPath.emptyTrashConfirm` is the reference wording) |

**The confirmation-consistency principle, from 13l §8 — copy it, don't
re-derive it:** *notes confirm* (container-scale, deliberate); *blocks
and takes do NOT* (in-flow acts, covered by undo and the tray) — the one
exception is D3, which already confirms on the phone because the phone
had no tray; *Delete Now / Empty Trash always confirm* (unrecoverable).
Once R3 lands, whether D3 keeps its confirm is a small judgment call —
recommendation: **keep it** (a phone tap is easier to fire by accident
than a Mac click, and the phone has no ⌥⌘Z chord culture).

**Preserved originals never render a Delete Now** (they ride their
family's clock — her 13j round-8b ruling; the Mac enforces this at
`RecoveryView.swift:306`).

### 2.4 ⚠️ THE DEAD-DOOR DEFECT — read this before writing the phone's Trash

**The Mac's purge doors do not work at this tip.** `13l` owns the fix
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
Setting it re-renders nothing, the binding's `get` is never re-asked,
and the dialog never presents. **Both purge doors ride this road**
(`requestDeleteNow` and `requestEmptyTrash` both set `pendingConfirm`),
so **true delete is currently unreachable from the Mac's UI entirely.**
The 30-day clock and the janitor still purge on schedule; nothing else is
affected; no data is at risk.

**Would the phone inherit it?** **Only if it copies that pattern — and
it must not.** The phone's existing confirm roads are both immune, and
either is a correct model:

- **The UIKit road** (`MobileEditorViewModel.swift:262–277`): a
  `confirmDestructive` closure seam that presents a `UIAlertController`
  imperatively. No SwiftUI observation involved at all. This is the
  pattern `MobileBlockMenu` uses.
- **The SwiftUI road as the phone already writes it**
  (`MobileWriteView.swift:230`, `MobileBookDetails.swift:195`,
  `MobileLenses.swift:408`): `.alert(..., isPresented: $someState)` where
  `someState` is a real `@State` / `@Bindable` property. The `$` binding
  *is* the dependency — this is exactly what the Mac's computed binding
  lacks.

**Rule for this round, stated loudly:** *the phone's Trash must never
present a destructive dialog through a `Binding(get:set:)` computed over
an `@Observable` property.* Use `@Bindable var model` and bind
`$model.pendingConfirm`, or use the UIKit `confirmDestructive` seam. And
**the pin must mount the real surface and drive the real button** — the
13j view-model seam pins stayed green over the dead Mac wiring, which is
precisely how the defect shipped.

*(Worth relaying to her: if she wants, the phone's correct pattern can be
the reference the Mac's 13l fix copies — the same "workaround that became
the Mac's default" road her divide and merge rulings already took.)*

---

## 3. The rows, in priority order

---

### R1 · Delete a note — PRIORITY 1 · SMALL

**Capability.** Get rid of a note you don't want, from the phone, and
have it be recoverable for 30 days.

**Brain (exists, core).** `Operations.deleteContainer(_:)` +
`Operations.restoreContainer(_:)` — `Sources/VariorumCore/Operations/`
(the Phase 2 lifecycle ops; `restoreContainer`'s exact-stamp cascade
revival is AppSpec §9). The Trash listing that shows it afterwards is
`Queries.trash` (R2).

**Mac's face.** `LibraryViewModel.delete(postID:)`
(`App/Variorum/Variorum/Features/Library/LibraryViewModel.swift:131`),
worn as a row action in `LibraryCatalogView`. **Today it carries NO
confirmation, and there is NO "Delete Note…" in the note's own ▾ menu** —
both are 13l §8's ruled work, unbuilt. So the phone is not behind the Mac
here; it is behind *zero*.

**Phone's face.**
- **`Features/Shell/MobileLibraryView.swift:210`** — the note row's
  `.contextMenu` already exists and holds exactly one row (Star). Add
  `Button(role: .destructive)` "Delete Note…". Long-press is the phone's
  row-menu grammar and is already established here.
- **`Features/Write/MobileWriteView.swift`, the masthead** — the note's
  own door. The masthead has a title button, `findDoor`, `sealDoor`, and
  the chip flow; there is **no ▾ menu**. Two shapes fit: (i) add a `⋯`
  `Menu` beside `sealDoor` holding Delete Note (and later the tray, R3);
  or (ii) a "Delete Note…" row inside a `MobileNoteMenu` sheet. **(i) is
  recommended** — it gives R3, R13 and future note-scale acts a home
  without a new surface.
- Confirmation: the phone's SwiftUI `.alert(isPresented: $state)` shape.
  Receipt names the Trash and the clock.
- **Navigate-away**: deleting the note you are *in* must pop the stack.
  The phone's liveness authority (`MobileLivenessAuthority`) is where the
  open-editor bookkeeping lives; the Mac's equivalent choreography is
  13l's "navigate-away covers every pane". On the phone this is one
  `dismiss()` / path-pop plus a deregister.

**Dependencies.** None. This is buildable first and alone. It is *more
useful* once R2 exists (so she can undo a mistake), so build R1+R2 as one
batch if possible.

---

### R2 · The Trash — PRIORITY 2 · LARGE

**Capability.** See everything deleted in the last 30 days, filter it,
put things back — and really delete when she means it.

**Brain (exists, core).** `Queries.trash(_:now:kinds:oldestFirst:limit:)`
(`Queries/Trash.swift:82`) returns `[TrashItem]` across all five kinds,
filtered by `kinds`, sorted, **and limited in SQL per arm** (the 13j
ladder-B B4 discipline — the limit must be passed, P1). `TrashWindow`
fences the 30 days read-side. Put-back roads: `restoreContainer`,
`restoreReading`, `restoreBlock` + `placeBlock`, `restoreVariant`,
`unarchiveBlock`. True delete: `requestPurge`. Local road:
`AppSession.sweepLocalPurge` (Shared).

**Mac's face.** `App/Variorum/Variorum/Features/Library/RecoveryView.swift`
— reached from `LibraryCatalogView.swift:348` as **"Archived & Deleted"**
(`RecoveryPath.menuLabel:73`), and from `RootView.swift:602/694`. It
wears: a **kind Picker** + a **date sort**, both applied *inside* the
query before the window (`:542`); per-row **Put back** (`putBackVerb:84`)
and **Delete Now** (`deleteNowVerb:121`); a header **Empty Trash…**
(`emptyTrashVerb:122`) rendered only when the Trash is non-empty; and the
count-by-kind confirm at `:131`. **Its two purge doors are dead — §2.4.**

**Phone's face (new files).**
- `Features/Shell/MobileTrashView.swift` — the surface.
- `Features/Shell/MobileTrashModel.swift` — `@Observable`, holding the
  windowed listing, the kind filter, the sort, and the pending confirm.
  Follow `MobileLibraryViewModel`'s shape exactly: a bounded observation
  restarted on filter/sort change via `.task(id:)`.
- **Entry point — pick one:** (i) a fourth filter beside
  `MobileLibraryViewModel.Filter`'s `all / bookless / scraps` (the
  Library already wears a filter `Menu` at `MobileLibraryView.swift:152`),
  or (ii) a row in `MobileSettingsView`. **(i) is recommended** — it puts
  the Trash where the notes are, mirrors the Mac's "Library → Archived &
  Deleted" placement, and costs no new navigation. Note the Trash is a
  *deliberately opened* surface (its stranded-originals arm walks lineage
  families), so it should be its own pushed screen rather than a
  held-open filter if the observation cost measures badly on the 100k
  fixture.
- **Phone-native shapes:** kind filter as a `Menu` (the Library's
  existing grammar) — not the Mac's segmented Picker; **Put back as a
  leading swipe action** and Delete Now as a **trailing destructive
  swipe**, with both also present in the row's long-press menu (swipe
  alone is undiscoverable); Empty Trash as a toolbar/header row.
- **The confirm road: §2.4's rule is binding.**
- **Days-left copy:** the Mac's `RecoveryPath.daysLeftLabel(_:)` (`:95`),
  `archivedForever` (`:105`) and `goesWithItsFamily` (`:113`) are the
  reference sentences. These are **Mac-app-local strings** — see §4(c).

**Dependencies.** R1 gives it something to hold (and R4). Nothing else.

**P1 note.** `limit:` is not optional in spirit — pass it, and carry a
truncation marker the way the phone's other listings do (the Phase 10
window+probe discipline, MobileSoul §2).

---

### R3 · The per-note tray — PRIORITY 3 · MEDIUM

**Capability.** From inside a note: see the blocks it has deleted, the
blocks it has archived, and the originals a divide/merge preserved — and
put any of them back.

**Brain (exists, core).** `Queries.trayBlocks` (`PoolAndTray.swift:89`),
`Queries.archivedBlocks` (`Trash.swift:445`),
`Queries.preservedOriginals` (`PoolAndTray.swift:163`),
`Queries.trayCounts` (`PoolAndTray.swift:253`) for the badge. Put-back:
`restoreBlock`, `unarchiveBlock` (→ `BlockUnarchiveLanding`),
`placeBlock`.

**Mac's face.** `App/Variorum/Variorum/Features/Tray/TrayPanel.swift`.
The door is the **⌫ N glyph in the note's context bar**
(`TrayPath.doorLabel(deleted:)`, `:115`; `doorGlyph = "⌫"`, `:76`) plus a
**"This Note's Tray"** item in the note ▾ menu (`menuLabel:74`). Two
quiet sections: **"Deleted & archived"** (`:86`) and **"Preserved
originals"** (`:87`). Three put-back roads with three distinct receipts
(`putBackWhereItWas:125`, `putBackAtEnd:126`, `putBackBeside:127`). The
panel is raised by a `TrayRequest` (`:156`) which carries an optional
`revealBlockID` — that is what makes R13's lineage door land on a marked
row. Window: 500 (`:170`).

**Phone's face.**
- **The door: a SIXTH chip in the masthead's `MobileChipFlow`**
  (`MobileWriteView.swift:186–192`, beside date · tags · more info ·
  blocks · lens). The chip renders `⌫ N` from `Queries.trayCounts` and is
  hidden at zero — the phone's chip grammar already does exactly this.
  *(Note her 13j 8b watch-item: the Mac's badge counts DELETED only, so a
  note with only archived blocks shows no badge. The phone should decide
  the same way for consistency, or count both — a small call; recommend
  matching the Mac and watching it in use, as she ruled.)*
- **The surface:** `Features/Write/MobileTrayView.swift` + a model, as a
  `.sheet` off the chip — the phone's established grammar for summoned
  machinery (`MobileMembershipSheet`, `MobileNoteTagsSheet`,
  `MobileReferencesSheet`, `MobileBlockListSheet`, `MobileLensSheet` all
  do this from the same masthead).
- Rows: title/preview + kind + days-left; **Put back** as the row's
  primary action (a trailing swipe or a plain trailing button — the tray
  is small, so a visible button reads better than a hidden swipe here).
- **Then rewrite `MobileBlockMenu.deleteConfirmDetail`** — see §2.1.

**Dependencies.** None technically; ordering after R1/R2 keeps the
deletion story's copy consistent.

---

### R4 · Delete a book — PRIORITY 4 · SMALL

**Capability.** Get rid of a book from the phone.

**Brain (exists, core).** `Operations.deleteReading` and
`Operations.restoreReading` (AppSpec §9 — the 13b S4-28.2 restore door).
`Queries.trash`'s `.book` kind already lists it.

**Mac's face.** `ReadingsViewModel` / the shelf's row menu.

**Phone's face.** `Features/Shell/MobileShelfView.swift:162` — the book
row's `.contextMenu`, which today holds Pin and Star. Add "Delete
Book…" (destructive, confirmed). Optionally also on
`MobileBookDetailsSheet` beside its finish/rename rows
(`MobileBookDetails.swift:152`).

**Why it is here and not in the ledger:** PL-11 names notes and blocks;
`TrashItem.Kind` has a `.book` case that the phone can never populate,
which is the tell. See §4(b).

**Dependencies.** None. Best built in the same batch as R1 (one
confirmation wording family serves both).

---

### R5 · Deleted takes come back — the History face's past region — PRIORITY 5 · MEDIUM

**Capability.** A take you deleted is still there, in the block's history,
with a Put back — and the block's lineage row sits beside it.

**Brain (exists, core).** `Queries.blockPast(_:)` →
`Queries.BlockPast` (`Queries/EditorSupport.swift:177`, `:165`) — the
lineage row and the deleted takes in one read.
`Operations.restoreVariant(_:)` → `VariantStatus`
(`Operations/Operations+Deletion.swift:101`) — note it returns the
*status it came back as*, because a take deleted while archived comes back
archived.

**Mac's face.**
`App/Variorum/Variorum/Features/Tray/BlockPastSection.swift` — a quiet
region under a block's savepoints in the History face, with
**"Deleted takes"** (`:44`), a **Put back** per row (`:241`) and a
**"See original"** button for the lineage row (`:215`). Its receipts
distinguish the two landings (`takeRestored:50`,
`takeRestoredArchived:57`). Capability IDs: `.showOriginBlock`,
`.restoreTake` (`:168`).

**Phone's face.**
`Features/Takes/MobileTakeHistorySheetView.swift` (+
`MobileTakeHistory.swift`, which already has `restore(_:confirmed:)` for
savepoints at `:183`). Add a past region below the savepoint list:
a "Deleted takes" section with Put back per row, and the lineage row with
a "See original" that raises R3's tray with the original revealed (the
Mac's `TrayRequest.revealBlockID`, `TrayPanel.swift:156`).

**Note (belt and braces):** the phone's takes browser already renders
**archived** takes with a road back
(`MobileArchivedTakeCardView`, `MobileTakesBrowserView.swift:674`;
`unarchiveVariant` at `MobileTakesBrowser.swift:221`). So archived takes
are covered; **deleted** takes are the gap.

**Dependencies.** R3 for the "See original" landing (or ship "See
original" with R13/R3 and the deleted-takes half alone first).

---

### R6 · Archive / unarchive a block — PRIORITY 6 · SMALL

**Capability.** Keep a block out of the note without deleting it — no
clock, no Trash.

**Brain (exists, core).** `Operations.archiveBlock(_:)`,
`Operations.unarchiveBlock(_:)` → `BlockUnarchiveLanding`
(`Operations/Operations+BlockArchive.swift:49`, `:97`).

**Mac's face.** The block's context menu / the editor command family;
the unarchive road lives in `TrayPanel`'s "Deleted & archived" section
(`putBackArchived`, `TrayPanel.swift:330`).

**Phone's face.** `Features/Write/MobileBlockMenu.swift:99` —
`menuElements` already composes the long-press menu; add an "Archive
Block" `UIAction` beside Delete (no confirm — reversible, no clock). The
unarchive road is R3's tray section.

**Copy discipline:** archive is **not** deletion. The Mac's word for its
clock state is "kept — no clock" (`RecoveryPath.archivedForever:105`).

**Dependencies.** Best with R3 (so archiving has a visible road back the
same day it becomes possible). Shipping the archive door *before* the
tray would create exactly the "a promise a user cannot act on" problem
13j batch 2 named.

---

### R7 · The phone's own on-leaving savepoint funnel — PRIORITY 7 · SMALL

**Capability.** Leaving a note leaves a savepoint behind, so version
history is real without remembering to commit.

**Brain (exists, Shared).** `AppSession.savepointOnLeaving(_ postID:)`
(`App/Variorum/Shared/AppSession.swift:239`) — it flushes first, then
leaves one quiet savepoint per changed take, honours
`SavepointCadence`, never throws. **"Every leaving road calls THIS and
nothing else"** is written into its own doc comment (`:219`).

**Mac's face (the FUNNEL, which is Mac-local by design).**
`App/Variorum/Variorum/Workspace/SavepointOnLeave.swift:64`, `:85` —
four leaving roads; plus `Features/QuickNote/QuickNoteView.swift:95`;
plus the ⌘Q registration inside `AppSession.swift:141`, which is
`#if os(macOS)` and whose own comment says *"The phone has neither a
quit door nor the multi-book note; its background flush rides the
liveness authority's own bookkeeping."*

**Phone's face.** **Zero call sites exist today** (verified). The phone's
leaving moments are:
1. `MobileWriteScreen.onDisappear` (`MobileWriteView.swift:149`) — the
   note is popped/replaced. Today it deregisters and tears down.
2. The background transition — `performBackgroundFlush(editors:sync:)`
   (`Features/Shell/MobileShellRouter.swift`, bottom) — which today
   flushes but does not savepoint. **On iOS, backgrounding is the
   nearest thing to ⌘Q**: MobileSoul §5.1 — the app dies without warning.
3. A same-post sibling stand-down inside `MobileLivenessAuthority`.

Recommendation: route (1) and (2) through the one Shared entry, keeping
`performBackgroundFlush`'s ordering (store first, then one sync round).
`savepointOnLeaving` flushes internally, so it *replaces* the flush call
rather than following it — check the ordering carefully against the
existing background-flush pin.

**Dependencies.** R12 gives her the switch; the funnel is useful without
it (the default cadence is `everySession`).

**Why it matters more than its size suggests:** her own 13j words were
*"unless you've been remembering to commit version history is kind of
weak right now"*. On the phone, where she writes in bed and the app is
killed rather than quit, this is the difference between having history
and not.

---

### R8 · Reorder takes — PRIORITY 8 · SMALL

**Capability.** Put the takes of a block in the order she wants.

**Brain (exists, core).** `Operations.reorderTake(_ variantID:to:)`
(`Operations/Operations+Variant.swift:250`), taking an `InsertPosition`
— the one ordered-list resolver 13e routed everything through.

**Mac's face.** `Features/Takes/TakesStructureController.swift:494`,
worn as **◀ ▶ / ▲ ▼ arrows on the take card** (the board's card chrome).

**Phone's face.** `Features/Takes/MobileTakesBrowserView.swift` — the
card's `menuButton` (`:505`, on `MobileTakesCardView`) already hosts a
per-card menu. Add "Move earlier" / "Move later" rows there. **A drag
handle is the wrong first shape** on a phone card stack: the browser is a
custom UIKit scroll surface, drag-to-reorder there is real work, and her
own instruction anticipates crowding ("if things like take reordering
look too crowded later on mobile, i'll consider different UX solutions").
Two menu rows are the honest cheap door; a drag shape can follow if she
wants it.

**Dependencies.** None.

**Rider (from KnownIssues, now RESOLVED at 13e but worth knowing):** the
single-pass fan-copy remap row was the reason reorder was risky; 13e's
FIX-2 landed the pre-assigned-ID + second-pass shape. Nothing outstanding.

---

### R9 · Duplicate-book-name refusal — PRIORITY 9 · SMALL (two lines)

**Capability.** Two live books can't share a name — the phone refuses the
same way the Mac does.

**Brain (exists, core).**
`Operations.assertBookNameIsFree(_ name:excluding:)`
(`Operations/Operations+Reading.swift:337`).

**Mac's face.** SIX doors call it, all verified:
`Features/Readings/ReadingsViewModel.swift:56` (create) and `:74`
(rename), `Features/BookView/BookStructureModel.swift:446`, `:493`,
`Features/Shelf/ShelfViewModel.swift:179`,
`Features/Settings/AppSettingsView.swift:460`. Each is pinned by a
discriminating revert in `VariorumTests/DoorSetTests.swift`.

**Phone's face — ZERO doors call it (verified).** Two one-line additions:
- `Features/Shell/MobileCreateBook.swift:95` — inside `create()`, before
  the `createReading` call in each of the three `kind` arms (or once,
  before the `switch`).
- `Features/Shell/MobileBookDetails.swift:112` — inside `rename(_:)`,
  with `excluding: readingID`.

Refusal copy rides the phone's existing `lastError` / `report` road.

**Dependencies.** None. Cheapest row in the file.

---

### R10 · Copy all takes — PRIORITY 10 · SMALL

**Capability.** Copy a block's whole fan to the clipboard.

**Brain (exists, core).** `Queries.blockTakes(...)`
(`Sources/VariorumCore/Queries/Export.swift:126`) — the same read the
Mac's door uses; the "Alternates" projection shape is core's.

**Mac's face.** `Features/Takes/TakeClipboard.swift` — `copyBlock(...)`
(`:74`) and `write(_:to:)` (`:93`), over an `NSPasteboard`
`Destination` (`:42`), injectable for tests (`:46`). Worn as a take-card
menu row (`TakesShared.swift:305`, capability `.copyAllTakes`).

**Phone's face.** A `UIPasteboard` twin. **Put the composition where it
can be shared:** `TakeClipboard` splits cleanly into (a) *what text a
block's takes become* — which is core-shaped and belongs beside
`Queries.blockTakes`, and (b) *which pasteboard it goes to* — which is
the only per-platform half. Recommendation: if (a) is not already core,
hoist it (§4(c)); then the phone's file is a ~20-line
`Features/Takes/MobileTakeClipboard.swift` with the same injectable
destination shape, wired to the take card's `menuButton` and/or the
block long-press menu.

**Dependencies.** None.

---

### R11 · Take → block below · takes → blocks — PRIORITY 11 · SMALL

**Capability.** Move one take out into its own block below; or explode a
whole fan into blocks.

**Brain (exists, core).**
`Operations.takeToBlockBelow(_:variantID:)` → `TakeToBlockResult`
(`Operations/Operations+TakeStructure.swift:75`, `:42`) and
`Operations.takesToBlocks(_ blockID:)` → `TakesToBlocksResult`
(`:149`, `:123`). These are 13e's **AR-1** ops — ruled **mint-copy with
the source take ARCHIVED**, deliberately not a row move (a row move opens
a repair-less I10 hole in the sync repair layer). The phone must not
invent a different semantic.

**Mac's face.** `TakesStructureController.swift:535`, `:562`; menu rows
in `TakesShared.swift:147`, `:153`; keyboard **⌥⌘⏎** and **⇧⌥⌘⏎**
(`EditorCommands.swift:168`, `:169`); command rows at `:480`, `:483`.

**Phone's face.** The take card's `menuButton` menu
(`MobileTakesBrowserView.swift:505`) for take→block-below; the block's
long-press menu (`MobileBlockMenu.menuElements`) for takes→blocks. **No
chords on the phone** — the keybinds have no twin and none is owed.

**Dependencies.** None. Sits naturally in the same batch as R8 and R10
(all three are take-card menu rows).

---

### R12 · Savepoint cadence + history pruning settings — PRIORITY 12 · SMALL

**Capability.** Choose how often the app leaves history behind, and
whether old quiet savepoints ever prune.

**Brain (exists, core).** `SavepointCadence`
(`Models/Enums.swift:110` — `everySession · idleOnly · onlyOnCommit`,
with `savesOnLeaving` / `savesWhenIdle`) and `HistoryPruning`
(`:144` — `standard · never`). Setters:
`Operations.setSavepointCadence` (`Operations+Appearance.swift:93`),
`Operations.setHistoryPruning` (`:106`). Both are **synced settings**
(document semantics — one answer on every device), and both are
E2EE-clean by construction (enum tokens, never prose — AppSpec §7's
column fence).

**Mac's face.** `Features/Settings/AppSettingsView.swift:171` (cadence
picker) and `:199` (pruning picker), with the write helpers at `:276`,
`:289`.

**Phone's face.** `Features/Shell/MobileSettingsView.swift` — a new
section after Sync/Tags. The phone's Settings today has **Voice · Sync ·
Tags · (DEBUG) Tutorial · Performance · Spike** and nothing else.

**Dependency / hoist warning.** The Mac reads and writes these through
`App/Variorum/Variorum/Theme/ThemeStore.swift` — a **Mac-app-local**
brain for *synced document settings*. Building the phone's rows means
either duplicating that read/write shape (a new forked brain) or hoisting
it. **Hoist.** See §4(c).

---

### R13 · The lineage door to a preserved original — PRIORITY 13 · SMALL

**Capability.** From a block that came out of a divide or a merge, get to
the original it was derived from.

**Brain (exists, core).** `Queries.preservedOriginals`
(`PoolAndTray.swift:163`), `Queries.strandedOriginals`
(`Trash.swift:249`), `Queries.originalsStrandedBy` (`:401`),
`Queries.blockPast` (the lineage row half). Put back:
`Operations.placeBlock`.

**Mac's face.** `Features/Tray/OriginPeek.swift` + the "See original"
button in `BlockPastSection.swift:215`, plus a context-menu row and a
palette entry; the landing is the note's own tray with the row revealed
(`TrayRequest.revealBlockID`, `TrayPanel.swift:156`). This is her
2026-08-03 mobile-gate ruling (13j item 3) made real: *"there needs to be
some way to see unplaced blocks from a block that was derived from
them."*

**Phone's face.** A "See original" row in the block's long-press menu
(`MobileBlockMenu.menuElements`) and/or in R5's History past region,
landing on R3's tray with the row marked.

**Dependencies.** R3 (the landing) and R5 (the second door). Genuinely
cheap once both exist; near-worthless before either.

---

### R14 · PL-9's three judgment acts — PRIORITY 14 · SMALL (mostly judgment)

PL-9 says explicitly that 14d's account work **reached the phone by
construction** (all `App/Variorum/Shared/`) and that mobile owes
**judgment, not code**. The three acts, verified against the tree:

**(a) Verify the account sheet reads right on the phone.** The unified
Stargazing sheet is `Shared/AuthViews.swift`; its only platform fence is
`#if os(macOS) .frame(minWidth: 460, minHeight: 340)` at `:165–166`, so
the phone gets the full sheet. This is a look-at-it act on device.

**(b) DECIDE the phone's bridge-connect door.** Confirmed shape:
`Shared/AuthViews.swift:290–308` renders the "Journal bridge
(Fragments)" row and its **"Connect with your Stargazing account"**
`PageDoor` **unconditionally on both platforms**. But the phone passes
no `bridgeEnabled` — `VariorumMobileApp.swift:50` constructs
`AppServices(session:storeVariant:backupEnabled:false)` with the
parameter defaulted `false` (`Shared/AppServices.swift:144`), so
`allowsBridge` is false (`:189`) and `BridgeStatusViews` shows
**"Bridge off"** with no door (`Shared/BridgeStatusViews.swift:23`).
Net: **the phone can connect a Fragments session that nothing on the
phone ever consumes.** Three options, hers or the mobile session's:
  - *(i) Hide the row on the phone* — honest, one `#if os(iOS)`; costs
    her the ability to connect from the phone.
  - *(ii) Keep it as account plumbing* and label it truthfully (it *is*
    an account link; the bridging happens on the Mac).
  - *(iii) Turn the phone's bridge on* — a real capability decision, not
    a face decision, and out of this round's scope.
  **Recommendation: (ii)**, with one honest clarifying line — it obeys
  the no-redirect principle (a road exists) without promising bridging
  the phone does not do.

**(c) Exercise the iOS `presentationAnchor` arm once.**
`Shared/SignInFlow.swift:88–106` has a real `#else` iOS branch
(connected scenes → foreground-active → `keyWindow`) that **compiles but
has never run on a device.** If (b) keeps the door, drive it once on
hardware. If (b) hides the door, this arm becomes unreachable and should
be recorded as such rather than left as untested live code.

---

### R15 · The rest of the document settings — PRIORITY 15 · MEDIUM

Not in the ledger; see §4(b). The phone exposes **none** of the synced
document settings the Mac does. Verified: `setSeamsVisible`,
`setEditingIndicator`, `setInlineComments`, `setFollowTheScroll`,
`setDefaultSegmentation` all have Mac call sites
(`AppSettingsView.swift:93, 96, 103, 114, 152`) and **zero** mobile call
sites. Several are meaningful on the phone (seams visibility, the editing
indicator, default segmentation, follow-the-scroll — which is explicitly
a takes-viewing option in all modes, AppSpec §12 R25). Same
`ThemeStore` hoist dependency as R12; build them in one batch.

---

### R16 · Callout swatches + a real emoji picker — PRIORITY 16 · SMALL (her word)

**Mac (13e E1).** `Features/Editor/CalloutMenu.swift` — coloured
swatches on every menu row (`rows:82`, `swatchImage:126`), the system
**"Emoji & Symbols…"** picker (`emojiPickerButtonTitle:174`,
`emojiAccessory:179`, `promptEmoji:212`), across three renderers with a
drift pin (`rowTitles:100`).

**Phone today.** `MobileBlockMenu.calloutSubmenu` (`:141`) renders plain
text rows from `MobileCallout.names` (`MobileCallout.swift:23` —
`["blue","green","sand","violet","rose"]`), and the "emoji" door is a
**plain text-field alert** (`promptEmoji:181`). Colour swatches in a
`UIMenu` are `UIImage` on `UIAction` (straightforward); a real emoji
picker on iOS means a text field with `UIKeyboardType`/emoji-only entry
or a small grid — a genuine design call, hers.

**Hoist note:** `CalloutPalette` lives at
`App/Variorum/Variorum/Features/Editor/BlockDecor.swift:253` and the
phone keeps its own copy of the same five names. **Forked brain** —
§4(c).

---

### R17 · Block multi-select + multi-delete — PRIORITY 17 · MEDIUM

Not in the PL-10 prose; 13e's E2 shipped it Mac-side (⌘-click selection
in the block list + one compound delete entry). The phone has a block
list sheet (`Features/Write/MobileBlockList.swift`, raised from the
`blocksChip`) with no selection mode. Phone-native shape: an "Edit"/
select mode in that sheet with checkmarks and one confirmed delete-all
naming the count. **No chords exist on the phone**, so the Mac's
⌘-click has no twin — the selection mode is the phone's own grammar.
Core brain: the same compound delete entry 13e built (ordinary
`deleteBlock` legs under one undo entry).

---

### R18 · In-note replace, then replace-all-in-every-take — PRIORITY 18 · MEDIUM

Not in the PL-10 prose. Two layers, and the phone is behind on **both**:

- The phone's find is **find-only**. `MobileEditorTextView.swift:728`
  sets `override var supportsTextReplacement: Bool { false }`, with a
  recorded reason at `:713–726`: iOS's system replace road applies
  Replace All as one coalesced multi-block storage edit the identity
  pipeline can't take, so the phone declines it at the protocol switch
  and the in-note replace face is deferred to a UIKit-spelled
  application. **The comment itself names the takes-aware replace as
  downstream of that.**
- 13e's **E9 Replace-All-in-Every-Take** (the apply-and-report shape)
  therefore has no phone foundation yet.

Real work, correctly deferred at the time, and worth a row so it does not
become a lost capability.

---

### R19 · A deletion chapter in the phone's pocket guide — PRIORITY 19 · SMALL

13j grew the Mac's tutorial spine by a **4-lesson deletion chapter**
(51/7 → 63/8). The phone has its own pocket guide with a walk-asserted
plan contract:

```
MobileTutorialSeeder.plan  (Features/Tutorial/MobileTutorialSeeder.swift:71)
  welcome            · start here · getting around
  writing            · blocks & typing · formatting
  takes              · your first take · swipe & choose · the browser · lenses
  structure          · divide · divide with takes · merge
  the library of things · comments & callouts · the seal · the voice switch
```

No deletion chapter. Under the 13b tutorial-as-spec precedent (which the
phone adopted at parity Stage B), **the lessons ARE the acceptance
script** — `MobileTutorialWalkTests` executes every lesson's acts
headlessly. A deletion chapter should land in the same round as R1–R3,
which is also how the round proves its own doors.

---

### R20 · The voice preference is a FORKED BRAIN — PRIORITY 20 · SMALL

The Mac writes the voice to the **synced `setting` table**
(`Operations.setThemeVoice` → key `theme_voice`,
`Operations+Appearance.swift:19`, via `ThemeStore.swift:53`). The phone
writes it to **`UserDefaults`** (`MobileVoicePreference`,
`Theme/MobileVoicePreference.swift`, driven from
`MobileShellRouter.setVoice`). Consequence: the voice she picks on the
Mac never reaches the phone, and vice versa — for a setting that is
document semantics by design.

MobileSoul §3's reverse reading is exact: *"mobile never forks a brain. A
behaviour difference between platforms is either a RULED compromise
(recorded) or a bug."* This one is neither — it is unrecorded. Either
ratify it as a deliberate per-device preference (defensible: the phone's
voice may genuinely want to differ), or move the phone onto
`theme_voice`. **A one-line judgment for her, not an autonomous call.**

---

### R21 · Two design calls held for her (PL-10)

- **The ●n comment marker's side.** The phone's marker sits **trailing**
  by its own M12 ruling; 13e batch 6 swept the Mac's comment affordances
  **LEFT** and flagged the phone rather than changing it. Her call
  whether the phone follows. *(Live rider: 13l §8c has her ruling to
  REMOVE the Mac's left-margin comment ＋ entirely — so the Mac's left
  placement is itself in flux. Worth waiting for 13l before moving the
  phone.)*
- **The margin-hover comment door.** The Mac's add-door is a hover
  affordance; **the phone has no hover.** A tap shape is hers to pick.

---

## 4. Closing findings

### (a) What in the ledger I judge NOT owed

- **PL-11's exclusions are right and I add nothing.** The divide/merge
  quick defaults are the phone's own (Q-M2 / C5 — the phone shipped
  first, the Mac caught up at J4/J4b); the ceremonies stay Mac-only per
  her ruled exclusion list; the **⌘Z→⌥⌘Z hint** has no phone twin (no
  chord culture); **W26-class system-wide hotkeys are impossible on iOS**
  (the share-sheet / App Intents road is the phone's future-list
  equivalent, not this round's).
- **13e's E12 canvas jitter fix and the canvas bank** — canvas editing is
  on her **ruled exclusion list** (MobileSoul §4.5, "sticky-note/canvas
  editing"). Not owed.
- **13e's E3 ⌘-click merge selection** — the *chord* is not owed. The
  underlying capability (merge a fanned pair) the phone already has in
  its own shape (C5's carry-all merge). Nothing owed.
- **13e's E11 book-icon ascent declaration and E15 Takes-board policy
  routing** — Mac-internal (the board is a Mac surface; the phone's
  browser was already policy-routed at the S3 ladder). Nothing owed.
- **13j's stranded-originals-ride-their-family's-clock, the say-so
  returner, the ledger machinery, the verdict hardening** — all core or
  `Shared/`; the phone has them by construction. Verified: `PurgeJanitor`
  is started by `Shared/SyncSession.swift:110` and `LocalPurge` by
  `Shared/AppServices.swift:285`, both on the phone.
- **13j's marker 6→7 lockstep** — server-side; the phone speaks it
  through the shared core.
- **PL-9's (a)/(b)/(c)** are judgment acts, and I have kept them as such
  (R14) rather than inventing code the ledger says is not owed.

### (b) Capabilities the ledger MISSED (my own closeout sweep)

The ledger prose is good but not exhaustive. These are real, and each is
a row above:

1. **Delete a book (R4).** PL-11 names notes and blocks. `TrashItem.Kind`
   carries a `.book` case the phone can never produce, because the phone
   has no `deleteReading` door.
2. **The document settings section (R15).** Five synced settings the Mac
   exposes and the phone does not — `seams_visible`, `editing_indicator`,
   `inline_comments`, `follow_the_scroll`, `default_segmentation`. These
   predate 13e/13j (Phase 13/13d era) and simply never got a ledger row.
   They are *synced document semantics*, so the phone silently ignores
   choices she made on the Mac.
3. **Block multi-select / multi-delete (R17)** — 13e E2, absent from
   PL-10's four lettered items.
4. **Replace, and replace-all-in-every-take (R18)** — 13e E9, absent from
   PL-10. The phone lacks even single-note replace.
5. **The pocket guide's deletion chapter (R19)** — 13j J10 grew the Mac's
   spine; the phone's spine is its own acceptance script and PL-11 does
   not mention it.
6. **The voice-preference fork (R20)** — not a phase deliverable at all,
   which is exactly why no ledger row caught it. It is a live §3
   violation.
7. **`MobileBlockMenu.deleteConfirmDetail` goes stale (§2.1).** The
   phone's honest sentence becomes a lie the moment the tray lands. Not a
   capability, but a shipped promise this round must maintain — recorded
   so it is not forgotten mid-batch.

### (c) Brains that must be HOISTED, not copied (MobileSoul §3)

The KnownIssues **"six mobile brains are byte-copies of Mac app-local
view-model code"** row is the standing precedent, and PL-10 already
extends it with `applyTypedPath`. Building the faces above adds these:

| Brain | Where it lives now | Needed by | Note |
|---|---|---|---|
| **`ThemeStore`** — read/write of the synced document settings (`theme_voice`, `seams_visible`, `editing_indicator`, `inline_comments`, `follow_the_scroll`) | `App/Variorum/Variorum/Theme/ThemeStore.swift` — **Mac app-local**, for *synced* settings | R12, R15, R20 | The clearest hoist in the file. Move to `App/Variorum/Shared/`; the Mac's pins ride unmodified (the 3C parity pattern). |
| **`CalloutPalette`** — the callout colour vocabulary + defaults | `App/Variorum/Variorum/Features/Editor/BlockDecor.swift:253` — Mac app-local; the phone keeps a byte-copy of the five names at `MobileCallout.swift:23` | R16 | Already forked *today*. A sixth colour added Mac-side would silently not exist on the phone. |
| **`CalloutMenu.rows`** — the callout menu's row vocabulary and order (it even carries a drift pin across three *Mac* renderers) | `App/Variorum/Variorum/Features/Editor/CalloutMenu.swift:82` | R16 | The drift pin proves the vocabulary is load-bearing; it should span four renderers, not three. |
| **`RecoveryPath` / `TrayPath` / `BlockPastCopy`** — the deletion story's user-facing sentences (`daysLeftLabel`, `archivedForever`, `goesWithItsFamily`, the three put-back receipts, the Empty-Trash count-by-kind confirm) | `Features/Library/RecoveryView.swift:73–136`, `Features/Tray/TrayPanel.swift:67–132`, `Features/Tray/BlockPastSection.swift:40–88` — all Mac app-local | R2, R3, R5 | Each file's own comment says the strings live in one place *because copy elsewhere promises the surface by name and would drift*. That argument does not stop at the platform boundary. Hoist at least the semantic-bearing ones (clock language, archive-has-no-clock, the count-by-kind confirm); pure Mac chrome wording can stay. |
| **`TakeClipboard`'s composition half** — what a block's takes become as text | `Features/Takes/TakeClipboard.swift:74` — Mac app-local (the `NSPasteboard` half is correctly platform-owned) | R10 | Split: composition → core (beside `Queries.blockTakes`); destination → per platform. |
| **`TakesStructureController`'s reorder/AR-1 call shapes** | `Features/Takes/TakesStructureController.swift:494, 535, 562` — Mac app-local | R8, R11 | Lower risk: these are thin wrappers over core ops with real semantics already in core. Copy is tolerable; a shared entry is better if the refusal/receipt wording is non-trivial. |

**One process note for whoever runs the round.** Several of these hoists
touch Mac app code. Per MobileSoul §3 that is the *correct* seam
(a mobile ladder fix was explicitly ruled the wrong seam for a
Mac-touching refactor at C3-R1-4) — but it means the round's batches will
carry Mac-suite runs, and the Mac's pins must ride unmodified as proof.
Plan for it rather than discovering it mid-batch.

---

## Appendix — files this round would create or touch

**New (phone):**
`Features/Shell/MobileTrashView.swift` · `Features/Shell/MobileTrashModel.swift` ·
`Features/Write/MobileTrayView.swift` (+ model) ·
`Features/Takes/MobileTakeClipboard.swift`

**Touched (phone):**
`Features/Shell/MobileLibraryView.swift` (D1 row, Trash entry) ·
`Features/Shell/MobileLibraryViewModel.swift` (filter) ·
`Features/Shell/MobileShelfView.swift` (D2 row) ·
`Features/Shell/MobileBookDetails.swift` (R9, D2) ·
`Features/Shell/MobileCreateBook.swift` (R9) ·
`Features/Shell/MobileSettingsView.swift` (R12, R15) ·
`Features/Shell/MobileShellRouter.swift` (R7) ·
`Features/Write/MobileWriteView.swift` (masthead ⋯ menu, tray chip) ·
`Features/Write/MobileBlockMenu.swift` (D4, R13, R16, and the stale confirm sentence) ·
`Features/Takes/MobileTakesBrowserView.swift` (R8, R10, R11 card menu rows) ·
`Features/Takes/MobileTakeHistorySheetView.swift` + `MobileTakeHistory.swift` (R5) ·
`Features/Tutorial/MobileTutorialSeeder.swift` (R19)

**Touched (Mac / Shared — the hoists):**
`App/Variorum/Variorum/Theme/ThemeStore.swift` → `App/Variorum/Shared/` ·
`App/Variorum/Variorum/Features/Editor/BlockDecor.swift` (`CalloutPalette`) ·
`App/Variorum/Variorum/Features/Editor/CalloutMenu.swift` (row vocabulary) ·
`App/Variorum/Variorum/Features/Takes/TakeClipboard.swift` (composition half) ·
the three deletion-copy homes listed in §4(c)

**Tests:** every new phone face gets its pins in
`App/Variorum/VariorumMobileTests/` alongside the existing suite (mobile
baseline at this tip: **314/60**). The R2 Trash pin **must mount the real
surface and drive the real button** — §2.4.
