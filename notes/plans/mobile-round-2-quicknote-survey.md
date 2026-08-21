# Mobile Round 2 — the QUICK NOTE survey (M5)

**A COLD DESIGN SURVEY, written 2026-08-21 before any build.** It maps
what already exists for the home-screen quick note, answers what the
"saved" icon can honestly claim, traces the app-kill path to a verdict,
and lays out the design forks for the architect to rule. **It decides
nothing** and touches no source file.

Her requirement and the ruled save model are recorded verbatim in
`notes/plans/mobile-round-2.md` §2, ruling **R5**; the ledger row is
**M5**, batch 3. Everything below is evidence for that row.

---

## 0. The one-paragraph answer

The Mac has **two** quick-capture surfaces and the phone has **neither**;
both Mac surfaces mint through `Operations.importPost`, and **neither
persists a single byte before the mint** — the Mac's grammar is
"type, then a deliberate act files it". Her ruling inverts that: the
phone's box mints *first* and edits *after*, which is a genuinely new
shape for this codebase. Every mechanism it needs already exists
(`importPost`, `autosave`, `AutosaveCoordinator`, the scenePhase
background flush) except one honest gap: **the shelf is not an editor
surface, so nothing on the shelf is registered with
`MobileLivenessAuthority`, and the app-level background flush therefore
does not cover it.** The single hardest fork is not saving — it is
**what the note's BLOCK STRUCTURE is** while she keeps typing into a
box that is not the crystallizing editor.

---

## 1. THE MECHANISM MAP (what exists, cited)

### 1a. The Mac's two capture surfaces — the reference she named

**(i) `QuickEntryBar` — the shelf/Library bar she praised.**
`App/Variorum/Variorum/Features/Shelf/QuickEntryBar.swift`

- A plain SwiftUI `TextField(axis: .vertical)` with a dashed-box cutout
  and the hint *"new note — just start typing · ⏎ opens it"*
  (`QuickEntryBar.swift:44`, `:62-68`).
- ⏎ (`.onSubmit`) calls `submit()`, which clears the field, trims, and
  refuses whitespace-only, then runs ONE op —
  `ops.importPost(title: nil, text: text)` — and **navigates**:
  `onOpen(.post(result.container.id))` (`QuickEntryBar.swift:96-112`).
- `autofocus` is true on the Shelf, false on Library
  (`QuickEntryBar.swift:19-22`) — "the shelf opens with the cursor
  already in the bar" (R102).
- **Persistence before ⏎: NONE.** The text lives in `@State private var
  entryText` (`:26`) and nowhere else. Kill the app mid-typing and it is
  gone. Her phone requirement is explicitly *more generous than this.*

**(ii) `QuickNotePad` — the floating ⌘⇧N sticky.**
`App/Variorum/Variorum/Features/QuickNote/QuickNoteView.swift`

- Its header states the architecture directly: *"IT IS A CAPTURE
  SURFACE, NOT AN EDITOR"* — no TK2 surface, no block identity, no live
  ring, *"a plain SwiftUI text field"* (`QuickNoteView.swift:10-27`).
- **This is the load-bearing precedent for P3 on the shelf:** *"P-3
  holds trivially rather than carefully. The sticky mounts no text
  surface, so there is nothing for it to be live with… The
  one-live-ring invariant is not extended here; it is simply not
  engaged"* (`:16-20`).
- Three mint triggers — close, ⌘⏎, quit — all routed through ONE body,
  `QuickNotePad.take()`, which clears first so one summon mints one note
  (`:67-97`). Since 13j J11 it also calls
  `session.savepointOnLeaving(postID)` (`:95`).
- The stated cost, in the file: *"a summon she abandons keeps nothing,
  and re-summoning gives a fresh pad rather than the last note"*
  (`:24-27`). Again — the exact behaviour her ruling rejects.
- The mint is `QuickNoteMint.file` (`:209-266`): `importPost(title: nil,
  text:, undoLabel: "Quick Note")` **and** `ops.fileAsQuicknote(...)` in
  one runner turn (`:241-245`).

### 1b. The core operations in play

| Op | File:line | What it does that matters here |
|---|---|---|
| `importPost(title:text:undoLabel:)` | `Sources/VariorumCore/Operations/Operations+Import.swift:40-57` | Mints a NEW post and segments `text` by the **global** `default_segmentation` via `SegmentationRules.bulkSegments`; refuses whitespace-only (`emptyImport`, `:47`); each segment stamps touch + churn like `newBlock` (`:98-111`); registers ONE undo entry whose inverse tombstones the post. **Its own doc comment already names this feature:** *"it is a parameter and not a constant because the QUICK NOTE mints through exactly this path"* (`:36-39`). |
| `createPost(title:profile:entryDate:)` | `Operations+Container.swift:15-27` | Mints an **empty** post — no block, no variant, no text. This is what the phone's `+ New Note` door uses today. |
| `newBlock(in:text:at:)` | `Operations+Block.swift:26-42` | One block + one variant + one placement; stamps touch and churn with the text length. The crystallizer's only mint call. |
| `autosave(_:text:charDelta:)` | `Operations+Variant.swift:16-27` | Overwrites ONE variant's `working_text` and accumulates churn. **The only op that edits existing text.** |
| `createOrOpenJournalEntry(entryDate:)` | `Operations+Container.swift:52-72` | The notebook rule — one entry per calendar day, `profile:'journal'`, `entry_date` set. **Not a candidate for the quick note** (she is explicitly keeping the journal button separate). |
| `fileAsQuicknote(_:)` | `Operations+Quicknote.swift:39-79` | Tags the post `quicknote` and ensures + designates + **pins to the shelf** the smart Quicknotes book. Never throws. |
| `closeAutoCommit(_:)` | `Operations+Variant.swift:113-146` | The 13j sixth quiet auto-commit occasion; obeys `savepoint_cadence`; never throws at a leaving. |
| `deleteContainer(_:)` | `Operations+Container.swift:361-367` | Tombstone → the 30-day Trash. |
| `requestPurge(_:)` | `Operations+Purge.swift:43+` | **REFUSES a live row** (`purgeTargetNotDeleted`) — *"only things in the Trash purge; a full-delete door must never exist in a note context, her round-3 rider"* (`:26-33`). Physical removal is the janitor's, horizon-gated. |

### 1c. The segmentation rule — the fork's root

`Sources/VariorumCore/Domain/SegmentationRules.swift` has exactly two
entry points (`:3-21`):

- **`bulkSegments(_:mode:)`** (`:59-91`) — "bulk entry (paste, import,
  pool-drop, mobile capture) segments on entry". What `importPost`
  calls.
- **`crystallizedBoundary(openTail:)`** (`:110+`) — type-time
  crystallization: a paragraph becomes a block when *the next paragraph
  begins*, not at its own newline (`:97-106`).

And the invariant that binds both: *"Crystallization only ever sees text
that has not yet become a block, so **I4** (newlines inside an existing
block are content, never structure) holds by construction"* (`:13-15`).

**This is the whole difficulty of mint-as-you-type.** The moment the
note exists, its blocks exist, and every further keystroke that lands
through `autosave` is *content of an existing block* — a newline typed
in the box after the mint can never become a block boundary without a
structural operation. See §7 fork **F1**.

### 1d. The phone's autosave machinery

`App/Variorum/Shared/AutosaveCoordinator.swift` (shared, both platforms):

- Debounce default **500 ms** (`:96`); `record(variantID:text:charDelta:)`
  coalesces a burst into the newest text + summed cost (`:106-116`) and
  re-arms one `flushTask` (`:118-125`).
- `flushNow()` drains everything pending through `Operations.autosave`,
  **per variant independently**, and a refused entry goes BACK into
  `pending` so nothing is dropped (`:142-174`).
- `var isDirty: Bool { !pending.isEmpty || flushesInFlight > 0 }` (`:92`).
- Observers: `observe(onError:onSettled:)` / `stopObserving` (`:66-79`),
  multicast because one coordinator serves several surfaces.
- **It is NOT `@Observable`** — `@MainActor final class` (`:22-23`), and
  the editor holds it `@ObservationIgnored`
  (`MobileEditorViewModel.swift:52`). A SwiftUI view therefore cannot
  bind to `isDirty`; the existing signal is the `onSettled` callback.
  (See §2.)
- One coordinator PER POST, session-cached:
  `AppSession.autosave(forPost:debounce:sleep:)`
  (`App/Variorum/Shared/AppSession.swift:115-149`). Note `:125-147` —
  the quit-door registration and the W22 first-edit hook are
  **`#if os(macOS)`**; the comment says plainly *"The phone has neither
  a quit door nor the multi-book note; its background flush rides the
  liveness authority's own bookkeeping."*

### 1e. The phone's home screen today

`App/Variorum/VariorumMobile/Features/Shell/MobileShelfView.swift`

Composition (`:39-88`): a `VStack(spacing: 0)` of —

1. `pathLine` — `"~/shelf · N books"` + **`+ New Note`** + **`Settings`**
   (`:93-125`). Two doors wide by deliberate design: *"the path line
   stays two doors wide (the P38 crowding lesson)"* (`:237-241`).
2. `ScrollView { LazyVStack { starredSection; bookRows; newBookRow } ;
   todayButton }` — note the **Today button is INSIDE the ScrollView**,
   after the LazyVStack (`:42-58`, `:265-297`).
3. `lastReport` / `lastError` / `starsError` lines (`:59-82`).
4. `tabBar()` (`:83`).

Header, verbatim: *"Reading is cheap: no live editor exists here at all
(P3); the list is author-scale"* (`:13-15`).

Doors:
- **`+ New Note`** → `MobileShelfViewModel.newNote()`
  (`MobileShelfViewModel.swift:112-119`) → `MobileNewNoteDoor.mint` →
  `ops.createPost(title: nil)` (`MobileTodayDoor.swift:77-88`) → opens
  the note **focused for writing** (`MobileShelfView.swift:99-104`,
  `MobileShellView.swift:87`). **A quick note that mints an untitled
  bookless post is already reachable in two taps — what is missing is
  typing it FROM the shelf.**
- **`✎ Today's Entry`** → `MobileShelfViewModel.openToday()`
  (`:124-133`) → `MobileTodayDoor.open` = `createOrOpenJournalEntry` +
  `shelveInDailyJournalBook` in ONE runner closure
  (`MobileTodayDoor.swift:37-48`). **Her ruling keeps this untouched.**

### 1f. The Library tab — the existing keyboard precedent

`MobileLibraryView.swift` has the SAME composition shape (`:29-81`) —
`VStack` → pathLine → **`searchField` (a real `TextField`, `:109-130`)**
→ filterRow → `ScrollView` → error lines → `tabBar()` — with
`.background(tokens.room.ignoresSafeArea())` (`:67`) and **no**
`.ignoresSafeArea(.keyboard)`. So a keyboard rising over this exact
composition is not new behaviour on the phone; §6 reads what it does.

### 1g. Where a bookless note lands

`MobileLibraryViewModel.Filter` is `.all | .bookless | .scraps`
(`:32-39`); `.bookless` holds `Queries.poolPosts` — *"no live curated
membership AND no smart book collecting"* (`:115-116`). So:

- A **plain bookless** quick note appears in Library → bookless (the
  Pool's phone home) and in Library → all.
- A **`quicknote`-tagged** note is *collected* by the smart Quicknotes
  book and therefore **leaves** the bookless filter, and the Quicknotes
  book gets **pinned onto her shelf** (`Operations+Quicknote.swift:48-54`).

### 1h. What it will be CALLED in a list

`Sources/VariorumCore/Domain/DisplayTitle.swift:31-60` — nameless notes
display their date today. **13u item 4 was RULED 2026-08-21** (master
plan row 13u): a card leads with the explicit title else a
**length-capped snippet of the note's first words**, derived at read
time, never stored — *and it names this very feature*: **"the
title-suggestion chip at quick-note/capture"**. A mint-as-you-type quick
note is therefore expected to read as its own first words, and the chip
is 13u's, not this round's.

---

## 2. WHAT "SAVED" CAN HONESTLY CLAIM

Her words: *"it should show a little icon when saved… they can fully
write it and know it's saved from the homescreen."*

### 2a. The five states, enumerated

| # | State | Reached when | Survives an app kill? | Readable today? |
|---|---|---|---|---|
| S0 | **Text in the field only** | first keystroke → the mint fires | **No** — SwiftUI `@State`, nowhere else | trivially (the box owns it) |
| S1 | **Minted** — post + block + variant rows committed | the mint op returns | **Yes** | the op returns the id |
| S2 | **Autosave pending** | `record()` called, debounce not elapsed | **No** (that keystroke burst only) | `AutosaveCoordinator.isDirty` (`:92`) — but see 2c |
| S3 | **Written to SQLite** | `flushNow()` → `Operations.autosave` committed | **Yes** | `onSettled` fires (`:86-89`) |
| S4 | **Queued for sync** | *the same instant as S3* | Yes | `SELECT COUNT(*) FROM sync_outbox` |
| S5 | **Pushed to the mirror** | a sync round accepts the row | n/a | `SyncSession.status` / `SyncRowFace` |

**S3 and S4 are the same instant, not two.** Outbox population is by
**trigger**, inside the writing transaction (SyncSpec §3 — *"Outbox
population is by trigger, not by the operations layer"*). There is no
window in which text is in SQLite but not queued.

### 2b. The recommended honest claim

**The icon should assert S3 and nothing beyond it: "this is on your
phone."** Grounds:

- **It is the only state that is both true and useful.** S1 alone is a
  lie the moment she types the next character; S5 is not hers to promise
  (offline is the phone's normal — MobileSoul §5.3), and an icon that
  goes dark on the tube would be actively misleading about her writing's
  safety, which is exactly backwards.
- **S3 durability is real.** GRDB `DatabasePool` = WAL
  (`Sources/VariorumCore/Persistence/AppDatabase.swift:6`, `:23`); a
  committed transaction survives an app kill. The store directory is
  created `completeUntilFirstUserAuthentication`
  (`App/Variorum/Shared/AppBootstrap.swift:94-102`), so writes work with
  the device locked after first unlock — the background path is not
  blocked by the lock screen.
- **S5 already has its own honest home** — the sync row
  (`App/Variorum/Shared/SyncStatusViews.swift:36-96`), which is shared
  chrome and already speaks offline/error/idle. A second sync claim in
  the capture box would be a second voice for one fact.

**What the icon must NOT do:** claim "saved" during S0 or S2. The
dangerous shape is an icon that settles optimistically on a timer rather
than on a settle callback.

### 2c. The machinery gap the icon needs closed

There is **no** dirty/clean signal a SwiftUI view can bind to today.
`AutosaveCoordinator` is a plain `@MainActor final class` (`:22-23`) —
not `@Observable` — and `isDirty` is read imperatively at act sites
(`MobileEditorViewModel.swift:499`, `:603`, `:707`;
`MobileStructural.swift:563`; `MobileTakesBrowser.swift:494`).

Two shapes, both cheap:

1. **Compose the existing callback** — the quick-note model registers
   `autosave.observe(onSettled:)` (`:66-79`) and flips its own
   `@Observable` `saveState`. Zero change to shared code; the exact
   pattern `MobileEditorViewModel.swift:171-178` already uses.
2. **Make the coordinator observable** — a both-platform change under
   `Shared/` (M-B: core + Mac + spine + mobile all run), and it would
   invite every surface to bind, which is more than M5 needs.

(1) is what the existing architecture makes cheapest and is
`MobileEditorViewModel`'s own precedent.

**One honesty trap to state for the record:** `flushNow()` puts a
REFUSED entry back into `pending` and keeps `isDirty` true
(`AutosaveCoordinator.swift:126-141`) — so a settle-driven icon
correctly stays un-saved on a refusal instead of falsely settling. Any
implementation must read the same source `isDirty` reads, not a
"we called flush" flag.

---

## 3. THE APP-CLOSE TRACE — and the verdict

### 3a. What runs today

`App/Variorum/VariorumMobile/VariorumMobileApp.swift:61-82`:

```
.onChange(of: scenePhase) { _, phase in
    case .active:     services?.sync.triggerSync()
    case .background: Task { await performBackgroundFlush(editors:sync:) }
    default:          break            // ← .inactive does nothing
}
```

`performBackgroundFlush` (`MobileShellRouter.swift:68-72`):
`await editors.flushAll()` **then** `await sync?.flush()` — ordering is
load-bearing (flush the text, then push it).

`MobileLivenessAuthority.flushAll()` (`:115-119`) loops **`registered`**
— every editor that called `register(_:tab:)` (`:65-69`) — and calls
`editor.finish()`.

`MobileEditorViewModel.finish()` (`:385-397`): cancel the idle clock →
mint the open tail (or fold a pure-newline tail) → `awaitMintSettle()` →
`autosave.flushNow()`.

Also relevant: `.onDisappear` calls `teardown()`
(`MobileWriteView.swift:149-153`), but the codebase records that
`onDisappear` **never fires on whole-app backgrounding** — the Phase 8
review-round-2 finding, cited at `VariorumMobileApp.swift:68-71`. That
is *why* the app-level flush exists.

### 3b. THE GAP

**`registered` is a set of `MobileEditorViewModel`s.** A quick-note box
on the shelf is not one — the shelf mounts no editor at all
(`MobileShelfView.swift:13-15`). Unless the box's model is explicitly
enrolled in the background-flush path (by registering with the liveness
authority, which would be a category error — it grants the TK2 pen — or
by a second, parallel registration), **`.background` will flush every
open editor and skip the box entirely.**

Two further facts the architect should hold:

- **No background-task assertion exists.** Nothing in the app calls
  `beginBackgroundTask` (grep: the only `UIApplication.shared` use is
  `SignInFlow.swift:98`). The `.background` flush is a bare `Task` racing
  suspension. Fine for a 500 ms debounce drain; not a promise.
- **`.inactive` is unhandled.** The app switcher and Control Center pass
  through `.inactive`; only a real `.background` triggers anything.

### 3c. Savepoints — the phone owes a hook

`AppSession.savepointOnLeaving(_:)`
(`App/Variorum/Shared/AppSession.swift:239-250`) is shared and is the
one leaving road (flush, then `ops.closeAutoCommit`). Its registration
into a quit door is **Mac-only** (`:125-147`), the Mac's four callers are
Mac-only (`SavepointOnLeave.swift`), and **nothing on the phone calls
it** — `performBackgroundFlush` does not. `MobileSettingsView` has no
savepoint-cadence rows either (grep: zero hits; the Mac's are at
`AppSettingsView.swift:169-183`).

This is exactly `MobileSoul.md` PL-11 item **(e)**: *"its OWN on-leaving
savepoint hook (the cadence SEMANTICS are synced settings, the leaving
FUNNEL is per-platform)"* — owned by ledger row **M6**, not M5. Flagged
here because the quick note is a *capture that is never opened in an
editor*, and the Mac's own pad calls `savepointOnLeaving` at its filing
for precisely that reason (`QuickNoteView.swift:87-96`). **If M6 lands
the phone's leaving hook, M5 gets the same insurance for free; if the
batches land in the ledger's order (M5 before M6), the quick note ships
without it.** Worth an architect decision on ordering.

### 3d. VERDICT

**Does a minted-and-typed quick note survive an app kill today?**

- **The rows survive.** Everything committed through `importPost` /
  `autosave` is durable in WAL and is queued in `sync_outbox` in the
  same transaction. Nothing about a kill can un-write them.
- **The last ≤ 500 ms of typing does NOT survive**, in the ordinary
  case, **because the box would not be enrolled in the background
  flush.** The editor's protection (`flushAll` → `finish`) is
  registration-based, and the shelf registers nothing.
- **Foreground crash / jetsam** loses the same ≤ 500 ms window (and, in
  the editor, the un-crystallized tail up to the 2 s idle-mint clock,
  `MobileEditorViewModel.swift:129`) — that is the existing, accepted
  posture for the editor and would be the box's too.
- **App-switcher swipe-kill** is the *good* case: the scene enters
  `.background` when it leaves the screen, so the flush has already been
  scheduled before the kill.

**So: her requirement — "if the user just closes the app, their note
should still be saved" — is met for everything already flushed, and is
NOT met for the final keystrokes unless M5 explicitly adds the box to
the background-flush path.** That is one concrete, non-optional
deliverable, and it is small: the box's model needs a flush entry that
`performBackgroundFlush` reaches.

---

## 4. WHERE A QUICK NOTE LANDS

### 4a. Confirming the Mac

- **`QuickEntryBar` mints BOOKLESS.** `submit()` calls `importPost` and
  nothing else (`QuickEntryBar.swift:96-112`) — no tag, no membership.
  `Queries.poolPosts` therefore lists it. **Confirmed.**
- **`QuickNotePad` does NOT.** Since 13g batch 7 (R6-4) it also calls
  `fileAsQuicknote` (`QuickNoteView.swift:241-245`), which tags the note
  `quicknote` and ensures/designates/**pins** the smart Quicknotes book
  (`Operations+Quicknote.swift:39-79`). Its own copy says so:
  *"Filed in Quicknotes — tagged #quicknote"*, and *"the Pool lists what
  no book holds, and a collected note is held"*
  (`QuickNoteView.swift:308-313`).

So "the Mac's quick note is bookless" is true of the **bar** and false
of the **pad** — and the surface she praised is the bar.

### 4b. What the phone would need

Either landing works with zero new machinery:

- **Bookless** — `importPost` alone. Appears immediately in Library →
  *all* and Library → *bookless*
  (`MobileLibraryViewModel.swift:115-123`). No shelf change.
- **Quicknotes-collected** — `importPost` + `fileAsQuicknote` in one
  runner turn (the Mac's exact composition). Consequence to state
  plainly: **a "Quicknotes" book appears and is PINNED on her phone's
  shelf** the first time she uses the box, because `ensureQuicknotesBook`
  designates and pins it. That is a visible change to the surface she
  said she likes.

Neither is a journal entry, which is the important half: `createPost` /
`importPost` set no `entry_date` and no `profile`
(`Operations+Container.swift:15-27`), so the Today button's notebook
rule is untouched and the two doors cannot collide.

### 4c. Two structural notes

- **Nothing appears until the mint.** Both listings are
  `ValueObservation`s over live rows; a minted note appears in the
  Library the instant its transaction commits — which is exactly what
  makes the ruled model honest ("it appears in the library").
- **The block-order rule.** `importPost` mints at `.end` and
  `MobileNewNoteDoor.mint` mints nothing at all; either way the block
  order is deterministic. No fork here.

---

## 5. THE ABANDONMENT PROBLEM — the tradeoff table

She accepted the cost. This section exists so the architect rules with
the mechanisms in view, not to re-open it.

The governing constraints:

- **A tombstone is a real synced write.** `deleteContainer` is a
  tombstone (S2), it pushes rows, and it lands the note in the **30-day
  Trash** (`Queries/Trash.swift`, `TrashWindow`). It does not disappear.
- **A live note cannot be purged.** `requestPurge` refuses a live row —
  *"a full-delete door must never exist in a note context, her round-3
  rider"* (`Operations+Purge.swift:26-33`). So "quietly remove it" is
  two acts (tombstone, then intent) plus a horizon-gated janitor. There
  is no undo-the-mint door short of exactly this.
- **The undo entry exists but is Mac-shaped.** `importPost` registers a
  structural-undo entry (`Operations+Import.swift:52-56`); the phone has
  no undo surface for it.

| Option | Mechanism | Sync cost | What it risks |
|---|---|---|---|
| **A — Mint after a debounce on first non-whitespace** (the ruled default) | One `importPost` ~1 s after the first keystroke | 1 mint (N block/variant/placement rows) per capture, abandoned or not | Abandoned one-word notes accumulate as real rows, in the library and on the Mac. **Her accepted cost.** |
| **B — A grace window: clearing the field back to empty tombstones the note** | mint as A; on `text.isEmpty` within a window, `deleteContainer` | mint **plus** tombstone; both push | Fights sync twice over. Worse: the tombstone lands in the **Trash for 30 days**, so "I cleared it" produces a Trash entry — a surprise, and one M6 is about to make visible. Also racy: the mint may still be in flight when the field empties. |
| **C — Discard-if-never-more-than-N-chars on leave** | as B, gated on length | as B | Same Trash consequence, plus an arbitrary threshold that will be wrong for a real four-word note. A heuristic deciding what she meant. |
| **D — Raise the mint threshold instead** (mint at first *word boundary*, or after ~2 s of quiet, rather than ~1 s of any keystroke) | pure timing change to A | identical to A | Costs nothing, deletes nothing, and shrinks the abandoned-stub population without a second write. Widens the S0 window (§2a) where nothing is saved — a direct trade against her "generous instant saving". |
| **E — Mint always; make abandoned stubs EASY to delete** | A + M6's deletion doors | identical to A | Leans on batch 4 landing. Costs nothing in this batch. Matches her own framing (*"a real note you'd have to delete"*). |

**The architecture's own lean, stated without choosing:** A (or A tuned
by D) composes with everything and writes once; **B and C are the only
options that fight sync, and both do it by producing Trash rows**, which
is a worse surprise than a stub in the Pool. Nothing here needs a
ruling *for M5 to build A* — but the mint threshold (D) is a real dial
and is fork **F3** below.

---

## 6. LAYOUT & KEYBOARD ASSESSMENT

### 6a. What the shelf does today when a keyboard rises

The shelf's root is a `VStack(spacing: 0)` with `pathLine`, a
`ScrollView`, status lines, and `tabBar()` — background
`.ignoresSafeArea()` but **no `.ignoresSafeArea(.keyboard)`**
(`MobileShelfView.swift:39-88`). SwiftUI's default keyboard avoidance
therefore insets the whole `VStack`: **the tab bar rides up on top of
the keyboard**, and the ScrollView's height shrinks.

The Write screen is the deliberate counter-example — it opts OUT
(`MobileWriteView.swift:130`: `.ignoresSafeArea(.keyboard) // the
container's keyboardLayoutGuide owns avoidance`) because the TK2
container handles avoidance itself.

**The Library tab is the live precedent**: same composition, same
absence of a keyboard opt-out, and it already has a focusable
`TextField` (`MobileLibraryView.swift:109-130`). So "keyboard over this
shape" is shipped behaviour, not an unknown — but it has never been
exercised with a field the user *dwells* in.

### 6b. What the new box must not displace

Her constraint is explicit: keep the journal button. Concretely at risk:

- **`✎ Today's Entry` is INSIDE the ScrollView**, below the book list
  (`:42-58`, `:265-297`). It is already not pinned; with a keyboard up
  and the ScrollView shortened, it moves further. A box placed *below*
  the list would compound this.
- **The path line is deliberately two doors wide** (`+ New Note`,
  `Settings`) with a recorded crowding lesson (`:237-241`). A third
  door there is against a recorded decision.
- **The starred section sits at the ScrollView's top** (`:181-200`) —
  the first thing she sees.
- **The tab bar** is the only pinned chrome and will be pushed by the
  keyboard.

### 6c. The three phone-native shapes

| Shape | Mechanics | For | Against |
|---|---|---|---|
| **Inline at the top of the ScrollView** (mirrors the Mac bar's placement, above starred/books) | a `TextField(axis: .vertical)` as the LazyVStack's first row | Closest to the Mac bar she praised; scrolls with the content; zero new chrome | Scrolls **away**; with the keyboard up the visible list collapses to almost nothing; a field inside a `LazyVStack` can lose focus if the row is recycled |
| **`safeAreaInset(edge: .bottom)` above the tab bar** | the box rides the keyboard as pinned chrome | Always reachable, thumb-natural, and the standard iOS capture idiom | It is a second pinned bar next to the tab bar; needs a rule for whether the tab bar hides while typing; furthest from "type it on the home screen" as a *page* element |
| **Fixed under the path line, above the ScrollView** | a third row in the outer `VStack` | Never scrolls away; keyboard avoidance behaves predictably; the Today button and starred section keep their order below it | Permanent vertical cost on every shelf visit even when she is not capturing |

The Mac's bar sits **at the top of the page above the list** in both its
hosts; the third shape is its literal translation and is the one that
touches least. Not a recommendation — fork **F4**.

### 6d. P1 / P3 — the honest cost

**P3 is not violated by a `TextField`.** The Mac already reasoned this
out for the same feature and wrote it down: the pad *"mounts no text
surface, so there is nothing for it to be live with… The one-live-ring
invariant is not extended here; it is simply not engaged"*
(`QuickNoteView.swift:16-20`). The phone's `MobileLivenessAuthority`
governs `MobileEditorViewModel`s specifically (`:44-53`); a SwiftUI
`TextField` is not one, mounts no `UITextView`, carries no
`BlockRangeIndex`, and the Library already ships one on a "no live
editor here" surface. **The shelf's header comment (`:13-15`) will need
its wording refined — the claim it makes stops being literally true —
but the invariant behind it holds.**

**P1 costs are real but bounded:**
- A held observation already runs on the shelf (`bookshelf` + pins +
  daily designation — `MobileShelfViewModel.swift:50-66`, author-scale
  rows). The quick note adds writes at autosave rate to ONE variant.
  Those writes fire the outbox trigger, which the shelf does **not**
  observe — but `SyncSession` does
  (`SyncSession.swift:128-143`), debounced 3 s (`:60`). Typing on the
  shelf will therefore schedule sync rounds exactly as typing in the
  editor does. Expected, not new.
- The **one genuine new risk**: the minted note appears in the shelf's
  and Library's observations, so each autosave settle can re-deliver a
  list snapshot **while she is typing into the box**. On the shelf the
  observed snapshot is books/pins/designation only — a bookless note
  does not touch it — so the shelf is safe. **A Quicknotes-collected
  note is a different story:** it changes book membership counts and
  could re-deliver the book list under her cursor at autosave rate.
  That is a real argument for the bookless landing (§7 **F2**), and it
  is measurable rather than a matter of taste.

---

## 7. OPEN DESIGN FORKS (for the architect to rule)

Each names its options and consequences. Where the existing
architecture makes one cheapest, that is stated with the reason — as
information, not a recommendation.

---

### F1 — What is the note's BLOCK STRUCTURE while she keeps typing? ★ *the hard one*

The ruled model mints early; `SegmentationRules` segments at the mint
and never again (`:13-15` — I4 holds by construction). So a newline
typed **after** the mint cannot become a block boundary through
`autosave`.

- **(a) One block, always.** Mint via `newBlock` (or `importPost` on a
  newline-free first snippet — which yields exactly one block) and
  `autosave` that single variant forever. Paragraph breaks she types in
  the box are block *content*.
  - *Consequence:* opening it in the editor shows a one-block note where
    the Mac's bar would have produced N. It is coherent, honest and I4-safe;
    it is a **different note** from the same keystrokes on the Mac.
  - *Cheapest by a distance:* it is one `newBlock` plus the standing
    `AutosaveCoordinator`, with no new brain (M-C satisfied by
    construction).
- **(b) Re-segment at hand-off.** Keep (a) while on the shelf, then
  segment when she presses ⏎ / opens the editor.
  - *Consequence:* needs an op that turns one block into N. **None
    exists** — `importPost` mints a *new post*; `importBlocks` *appends*;
    `divide` is structural and per-cut. Building one is a core change and
    a new brain. Against M-C and against the round's scope.
- **(c) Crystallize in the box.** Compose `CrystallizationPlanner`
  (`App/Variorum/Shared/EditorBrain/CrystallizationPlanner.swift`) over
  the box's text, minting blocks as paragraphs complete — the editor's
  own brain, not a copy.
  - *Consequence:* the box becomes a second crystallizing surface. The
    planner is pure and reusable (`nonisolated enum`, `:25`), but its
    reconciliation half assumes an open tail region in a text view and a
    `BlockRangeIndex` — **and `BlockRangeIndex` is the very thing
    trapping in M1.** Pointing a second surface at it during the round
    that is fixing its crashes is a real risk.
- **(d) Defer the mint until a newline is typed.** Newline-free text
  stays a single block by definition, so (a)'s divergence never arises;
  a newline flushes and hands off to the editor.
  - *Consequence:* changes the capture gesture (⏎ would file rather than
    type a newline — which is the Mac **bar**'s grammar, `:68`, and the
    opposite of the Mac **pad**'s, `:29-34`). Cheap, but it decides F5
    by side effect.

*(In practice (a) and (d) are close: a home-screen capture is usually a
sentence or two with no newline, in which case every option produces the
same one block. The fork matters exactly for the multi-paragraph
capture.)*

---

### F2 — Bookless, or filed into Quicknotes?

- **(a) Bookless** (the Mac bar's grammar): `importPost` alone. Lands in
  Library → bookless. No shelf change, no new book, and the shelf's held
  observation is untouched by autosaves (§6d).
- **(b) Quicknotes** (the Mac pad's grammar): + `fileAsQuicknote`. Gives
  her one place to find captures and matches her own R6-4 ruling on the
  Mac — but **mints and pins a "Quicknotes" book onto her phone's
  shelf**, and makes the note's membership churn under the shelf's own
  observation while she types.
- **(c) Bookless while typing, filed at hand-off** — `fileAsQuicknote`
  runs only when she commits (⏎ / opens it), so an abandoned stub never
  reaches the shelf.

Cheapest: (a). Most consistent with the Mac's *pad*: (b). (c) costs one
extra call and is the only one that keeps abandoned stubs off the shelf.
**It is a product call — the two Mac surfaces disagree with each other,
so precedent does not settle it.**

---

### F3 — The mint threshold

The ruling says "~1 s after your first keystroke". Dials available, none
of which reopen the model:

- trigger on **first non-whitespace** vs. any keystroke (whitespace-only
  refuses at `importPost` anyway — `emptyImport`, `:47` — so the guard
  must exist regardless);
- **~1 s of any typing** vs. **first quiet gap** (the editor's own idle
  clock is 2 s — `MobileEditorViewModel.swift:129`; matching it would
  make one number govern both surfaces);
- a **minimum length** before minting.

Consequence of a longer threshold: a wider S0 window in which nothing is
saved (§2a) — directly against "generous instant saving". Consequence of
a shorter one: more abandoned stubs. **The 2 s idle-mint number is the
one the codebase already chose for "typed text becomes durable"; reusing
it needs no new justification.**

---

### F4 — Placement (see §6c)

Inline-at-top-of-scroll · pinned `safeAreaInset(.bottom)` · fixed row
under the path line. Constraint from her: the Today button and the
shelf's feel must not be displaced. Constraint from the repo: the path
line is deliberately two doors wide (`:237-241`).

---

### F5 — What ⏎ does

Her sentence: *"still enter to go into the full editor with takes and
everything."*

- **(a) ⏎ = open the note in the editor** (the Mac bar's grammar,
  `QuickEntryBar.swift:68`, `:107`). Then a multi-paragraph capture is
  impossible from the shelf — which makes F1 moot and is arguably the
  point of a *quick* note.
- **(b) ⏎ = newline; a separate button opens it** (the Mac pad's
  grammar, `QuickNoteView.swift:29-34`, `:128-129`). Her phrasing —
  *"press a button to go into the particular note"* AND *"still enter to
  go into the full editor"* — mentions **both** a button and ⏎.

Note the phone has no ⌘⏎, so the pad's "⏎ types, ⌘⏎ files" split has no
phone translation; on a phone keyboard there is one return key and it
must mean one thing (or the box must show an explicit open door beside
it). **This fork and F1 are coupled: (a) collapses F1 entirely.**

---

### F6 — Does the box get the background flush, and does it get a savepoint?

Not optional-optional — §3 shows the flush gap is real. The fork is
*how*:

- **(a) A parallel flush registry** on `MobileShellRouter` beside
  `editors`, drained by `performBackgroundFlush`
  (`MobileShellRouter.swift:68-72`). Honest: the box is not an editor
  and should not hold the pen.
- **(b) The box registers with `MobileLivenessAuthority`.** Wrong
  category — `takeLiveness` stands other editors down and grants the TK2
  pen (`MobileLivenessAuthority.swift:98-109`). Would stand the real
  editor down from the shelf.
- **(c) Rely on the coordinator cache** — the box uses
  `AppSession.autosave(forPost:)`, so a `flushEveryOpenPost()`-shaped
  drain (`AppSession.swift:209-213`, which already exists and is shared)
  would cover it with no new registry at all.

**(c) is the cheapest and needs no new type**: `flushEveryOpenPost()`
already loops every cached coordinator, and the box's writes would live
in one. It flushes text but not the *un-minted* S0 text, so it must be
paired with the mint decision.

And the savepoint half: whether M5 waits for M6's phone leaving hook
(PL-11(e)) or lands its own single `savepointOnLeaving` call at the
hand-off — which is exactly what the Mac pad does
(`QuickNoteView.swift:95`), one line on the shared entry.

---

### F7 — The icon's vocabulary

Given §2b's claim (S3 = "on your phone"), what does it *say* and how
does it behave?

- states: **typing / saving / saved** vs. **saved / not-saved** binary;
- does it appear at all before the first mint (S0)? An icon that is
  absent for the first second is honest but reads as broken; an icon
  that says "saving…" from the first keystroke is honest and continuous;
- does it ever mention sync? (§2b says no — the sync row owns S5.)
- VoiceOver: MobileSoul §5.6 makes an accessibility label mandatory for
  a custom indicator, and a purely-glyph state has no spoken form
  without one.
- Voice: it must render through `tokens.chromeLabel` like every other
  string on the shelf (the ONE voice register — `MobileShelfView.swift`
  throughout).

---

### F8 — Does the box survive a tab switch / navigation away?

The shelf's `@State` dies with the view; both tab stacks stay alive
opacity-switched (`MobileShellView.swift:81-104`), so the shelf is not
torn down by a tab switch — but a push (opening a book or a note)
leaves it mounted underneath, and popping back returns to the same
`@State`.

- If the note is already minted, "surviving" is automatic — the rows
  exist; the only question is whether the *box* still shows its text.
- If it is not yet minted (S0), a navigation away is the same loss class
  as an app kill.

Fork: does navigating away **file** the note (the pad's "closing files
it" grammar, `QuickNoteView.swift:72-74`) or **keep the box warm**? The
ruled model makes the first mostly moot; the residue is only the
sub-mint window.

---

## 8. WHAT THIS SURVEY DID NOT ANSWER

- **Whether the ~1 s mint measurably degrades shelf typing at corpus
  scale.** Not measured; the shelf's held observation does not watch the
  outbox, so the expectation is "no", but MobileSoul §2's bar says
  measure rather than expect. A 100k-corpus dev store already exists
  from the parity round's proving ground.
- **The 13u title-suggestion chip.** Ruled 2026-08-21 and explicitly
  scoped "at quick-note/capture" — but it is **13u's row, not M5's**.
  M5 should leave a place for it, not build it.
- **Whether the Mac's `QuickEntryBar` should adopt the phone's
  mint-as-you-type shape** (the divide/merge precedent — a phone
  workaround becoming the Mac's default). Her ruling was for the phone
  only; recording the question, not raising it.

---

*Written cold from the source. Every claim above carries a file:line;
nothing was taken from a summary.*
