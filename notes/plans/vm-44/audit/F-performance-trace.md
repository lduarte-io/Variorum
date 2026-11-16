# F — The phone's performance trace (VM-44 audit, reader F)

**Her words:** "There's significant lag when going to the quick entry box, when going from the quick entry box into a note."
**The bar (MobileSoul §2):** P1–P3 verbatim on the phone, "I do not want the mobile app to choke even on 100k words", memory (jetsam) as a first-class metric.

**Method.** Code reading only, at `main` 5dde1bcf9. Nothing was built, run or measured. Every mechanism below is labelled:

- **TRACED**: the work is shown in code (file:line). This is VERIFIED by reading.
- **SUSPECTED**: plausible from the code, but its size or its runtime behaviour needs a measurement.

Paths are relative to `App/Variorum/` unless they start with `Sources/` or `notes/`.

**Order of this file.** §1–§6 cover the six paths from the brief. §7 is the observation "wake map", the one mechanism under most of them. §8 lists P-violations. §9 covers tooling and fixtures. §10 ranks the causes of the two lags. §11 is the device session plan. §12 lists side findings for other readers.

---

## 1 · Tapping into the quick-entry box

### The sequence as built

1. **The box is a SwiftUI `TextField(axis: .vertical)` inside a dashed frame.** `Features/Shell/MobileQuickNote.swift:1228-1274`. The ZStack also carries `.contentShape(Rectangle()).onTapGesture { focused = true }` at 1272-1273.
   - At rest it is one line: `collapsed` (1224-1226) gives `lineCap = 1` (1212-1216) and `fieldMinHeight = nil` (1278-1281).
   - In the Terminal voice, a `BlinkingCursorBlock` runs a 550 ms `.task` toggle loop while the box is empty and unfocused (`MobileShelfView.swift:461-478`, used at `MobileQuickNote.swift:1235-1237`).
2. **The tap moves focus.** `@FocusState focused` flips, and UIKit makes the field's backing text view first responder, which starts the keyboard.
3. **The focus is reported to the model.** `.onChange(of: focused)` calls `model.setFocused(true)` (1183-1187). That writes the observed `isFocused` (262-268), guarded by an equality check.
4. **The whole shelf re-lays out.** `MobileShelfView.body` reads `quickNote.isFocused` inside its `GeometryReader` (`MobileShelfView.swift:89-114`, read at 95). This:
   - recomputes `MobileShelfLayout.split` (`MobileShelfLayout.swift:178-205`) from `.collapsed` to `.expanded`;
   - resizes the books region and the writing region, animated by `.animation(.easeOut(duration: 0.18), value: quickNote.isFocused)` (`MobileShelfView.swift:113`);
   - re-creates `MobileQuickNoteBox` with a new `writingHeight`, so `lineCap` jumps from 1 to `writingLineCap(...)` (`MobileShelfLayout.swift:214-221`) and the field gains a `minHeight` (`MobileQuickNote.swift:1257-1259`).
5. **Keyboard avoidance resizes the whole band.** The shell's root `GeometryReader` holds all three pages: Starred, Shelf and Library (`MobileShellView.swift:194-264`). None of them opts out of the keyboard safe area. Only Write does, with `.ignoresSafeArea(.keyboard)` at `Features/Write/MobileWriteView.swift:185`. So when the keyboard arrives, all three NavigationStacks are re-proposed a smaller height, including the off-screen Library list.
6. **The split runs a second time.** The shelf's own GeometryReader region shrinks too, so `split` recomputes and `lineCap` changes again. The layout brain's header says this is by design: "a keyboard that halves the room halves the BOOKS" (`MobileShelfLayout.swift:28-42`).
7. **No store I/O happens on a tap-in.** No read, write or view-model work runs beyond `setFocused`. Nothing mints until the first non-whitespace character arms the 1 s clock (`MobileQuickNote.swift:550-558`, `680-687`, `mintDelay` 302).

**"Going to" the box can also mean getting back to it from a note.**
- **Back from a note on the shelf stack:** `MobileWriteScreen.onDisappear` (`MobileWriteView.swift:206-226`) runs `teardown()` and then `savepointOnLeaving`. That is `finish()`, a flush, and `closeAutoCommit`, which reads every take's `working_text` for that post (`AppSession.swift:660-691`). All of it goes through the ONE serial `OperationsRunner` (`Shared/OperationsRunner.swift:17-31`). A mint typed into the box right after a pop queues behind it.
- **From the Library tab:** `selectPage` (`MobileShellView.swift:407-417`) runs `quickNote.fileOnLeaving()`, which is cheap on an empty box. It then runs `editors.tabDidBecomeVisible(.shelf)`, which is a cheap stand-down when the shelf stack is at its root.

### Suspects

| # | Mechanism | Label | Why | P | Cheapest confirming measurement |
|---|---|---|---|---|---|
| 1A | **Every return under Castle rebuilds the whole shell on a freshly reopened, cold, encrypted store** (see §6). The tap lands while that rebuild is busy. | TRACED (mechanism) · SUSPECTED (size) | Every observation's first fetch, `AppServices.start()` with its owner-adoption full-table UPDATEs (`Shared/AppServices.swift:531`, `Sources/VariorumCore/Operations/OwnerIdentity.swift:87-104`), and the first sync round plus janitor scans all run just as she reaches for the box. | P1 (owner adoption and janitor are O(corpus)) | Time Profiler + System Trace over "return → Face ID → tap box". Main-thread busy ms in the 2 s after `road: opened` (os_log, category `protection`). |
| 1B | **Competing layout passes.** The 0.18 s easeOut split animation, a vertical TextField whose `lineLimit` (1→N) and `minHeight` change while it takes first responder, and the keyboard-avoidance resize of all three pages. | TRACED (two to three passes) · SUSPECTED (cost or visible stutter) | The passes are in code. Whether they drop frames or only look like a jump needs the Hitches instrument. | — | Animation Hitches + SwiftUI instrument over the tap. Count body updates of `MobileShelfView`, `MobileQuickNoteBox`, `MobileLibraryView` and `MobileStarredView`, and hitch milliseconds. |
| 1C | **The platform's text-input session start-up.** The first keyboard in a process, QuickType, and a fresh first responder after a rebuilt shell. | SUSPECTED | This is an iOS fact, not app code. Under Castle every return gives a fresh field instance. | — | Compare the first tap after unlock with a second tap 10 s later, in the same Time Profiler trace (system time in keyboard / input frames). |
| 1D | **Back from a long note.** `teardown` plus `closeAutoCommit` are O(note) on the serial runner, and the box's first mint waits behind them ("saving…" lingers). | TRACED | Serial runner (`OperationsRunner.swift:27-30`). `closeAutoCommit` reads the post's take texts. | P1-ish (∝ the note left) | os_log is absent here. Use Time Profiler and look for `closeAutoCommit` → `importPost` ordering on the runner thread after a pop from the 100k note. |
| 1E | **Typing in the box wakes the off-screen Library.** Every autosave (500 ms debounce, `MobileQuickNote.swift:309`) writes `container`. The Library's two held observations re-run and deliver new stamps (§7), so the off-screen `MobileLibraryView.body` re-evaluates twice per autosave. Three seconds later the sync round wakes them again. | TRACED | `MobileLibraryView.swift:130-131`. `observeLibrary` at `Sources/VariorumCore/Queries/Observations.swift:50-62` is ordered by last-touched, so the top row's `stamp` changes every autosave. | P1 (`poolPosts` is corpus-scale, §5) | SwiftUI instrument: `MobileLibraryView` body count while typing 10 s in the box (expect about 2 per autosave). Time Profiler: `notePoolListing` and `Queries.library` frames under `sqlite3_step`. |

---

## 2 · Quick entry → into a note

### The sequence as built

**A · The press.** ⏎ arrives as a newline in the binding. `text.didSet` (`MobileQuickNote.swift:211-217`) calls `handleTextChange`, and `isTypedReturn` (429-435) calls `write(oldValue)` and then `open()` (535-538). The `open ↵` door calls `open()` directly (1293-1295).
- `write(oldValue)` runs inside the same turn's `didSet`. The file's own analysis says a same-turn write does not reach the field (600-627), so the field keeps showing the stray newline (one extra line) until `reset()` writes `""`. INFERRED from the file's own measurement of the same mechanism.

**B · The filing, before any navigation.** `open()` (882-887) spawns a Task that awaits `file()` (930-1054):

| Step | What it is | Where | Store trips |
|---|---|---|---|
| B1 | `cancelMintClock()` | | none |
| B2 | `mintNow()` (988). If she pressed within ~1 s of the first character, it runs `runner.run { importPost }` (714-718); otherwise it returns the minted id. | | write (pre-mint only) |
| B3 | `adopt` → `database.read { renderPost }` (769-771) → `session.autosave(forPost:)` (819-821) | | read (pre-mint only) |
| B4 | `session.flushEveryOpenPost()` (1027). Walks EVERY coordinator the session holds (`AppSession.swift:607-611`). The box's own coordinator is dirty if she typed in the last 500 ms, and so is any other open editor's. | | 0..k writes |
| B5 | `session.savepointOnLeaving(minted)` (1033). `closeAutoCommit` through the runner (`AppSession.swift:679-681`). | | write |
| B6 | `reset()` (1051, body 1082-1110). Calls `setFocused(false)` at 1084, which makes the face drop the caret (1192-1200), so **the keyboard starts going DOWN**. Then `handOffCount += 1` (1052). | | none |
| B7 | Back in `open()`: `pendingOpen = id`. | | none |

So **1–4 serialized runner/writer transactions** run with no visual change except the stray line. All of them are off the main thread: the runner is an actor and GRDB does the I/O. But they are serial behind whatever holds the runner or the GRDB writer.

**C · The navigation.**
1. `.onChange(of: model.pendingOpen)` → `onOpen` (1201-1203).
2. That is the shelf's `onOpenForWriting` → `leavingShelf { shelfPath.append(.note(id, focus: true)) }` (`MobileShellView.swift:214-218`, `536-540`). `leavingShelf` also spawns another `fileOnLeaving()`, a cheap no-op `reset()` on the now-empty box.
3. The `shelfPath` change re-renders the shell body.
4. `navigationDestination` builds `MobileWriteScreen` (`MobileShellView.swift:457-468`).
5. Its `init` (`MobileWriteView.swift:143-174`) **eagerly constructs seven models**:
   - `MobileEditorViewModel`, whose own init (`MobileEditorViewModel.swift:190-233`) acquires a holder on the post's autosave coordinator (206), adds an observer (225-232), and builds seven sibling controllers;
   - plus the membership, tags, references, block-list, tray and lenses models.
6. Meanwhile the shelf collapses its box: `isFocused` became false, which triggers the 0.18 s split animation (§1 step 4).

**D · The arrival: `.task` on `MobileWriteScreen`** (`MobileWriteView.swift:188-205`).

| Step | What it is | Where | Store trips |
|---|---|---|---|
| D1 | `router.editors.register(model, tab:)` → `takeLiveness(refresh: false)` (`MobileLivenessAuthority.swift:109-116`, `154-265`): stand down the others, `autosave.flushNow()` (195, a fresh clean coordinator), then `confirmNoteStillLive()` reads the header (207 → `MobileEditorViewModel.swift:392-415`) | | **read 1** |
| D2 | `model.arrive(focus: true)` (549-557) → `loadOnce()` (581-597) reads `takesProjection + containerHeader` in one transaction | | **read 2** |
| D3 | `ingest` → `applyProjection` → `.initialRender` → `renderFull` (827-867) on the main thread: `EditorDocument.materializeCore` over the whole note (838), `MarkdownFace.style` over the whole note (843), `storage.setAttributedString` (847), the caret restore (837, 860-863), `auditIdentityProjection` (DEBUG only, 2206-2212), and `refreshChrome()` at `.document` scope (866). `ingest` then calls `refreshChrome()` again (615). | | none (main thread) |
| D4 | No place memory exists for a fresh note (551-553), so the page lands at the top. Then `textView?.becomeFirstResponder()` (555), so **the keyboard comes back UP**. | | none |
| D5 | `model.start()` (573-578), forever. It runs two observation loops, and **each starts with an initial fetch**: the header again, and **the whole `takesProjection` again** (`observeTakes`, 667-678). That second projection goes through `ingest(fromDelivery: true)`, which runs `ledger.matches` O(note) and another `.document` chrome pass. | | **reads 3–4** |
| D6 | The masthead chips each start a `.task(id: postID)` read in parallel: membership reads `readingsContaining` and **ALL readings** (`MobileMembership.swift:90-104`); tags reads `postTags` and **ALL tags** (`MobileNoteTags.swift:71-82`); references (`MobileReferences.swift:120-129`). Lenses refresh only at sheet dismissal. | | **reads 5–7** |

**Store round trips.** 1–4 serial trips before navigation, 2 serial reads before first paint, then 2 observation initials and 3 parallel chip reads. That is **8–11 trips** around one hand-off, with the full note projection read **twice**. The keyboard goes down at B6 and comes back up at D4. The push animation and the shelf collapse play in between.

**E · The aftershock (about 3 s later).**
1. The mint and the closeAutoCommit put rows in `sync_outbox`.
2. `SyncSession` observes `COUNT(*) FROM sync_outbox` (`Shared/SyncSession.swift:229-241`) and debounces 3 s (`settleDebounce`, 141; `scheduleSettleTrigger` 416-423) before calling `triggerSync()` (287-299).
3. The round runs `beforeRound` (flushes pending typing), pull, push, then `PurgeJanitor.sweep()` after every clean round (`Sources/VariorumCore/Sync/SyncScheduler.swift:212-300`).
4. Push bookkeeping writes `UPDATE … SET sync_version` (`Sources/VariorumCore/Sync/SyncEngine.swift:973`, `982-988`).
5. `takesProjection` carries whole `Variant` records, and `syncVersion` is one of their fields (`Sources/VariorumCore/Models/Variant.swift:25`). So the push makes the just-opened note's observation **deliver again**: another `ingest` and `.document` chrome pass on the main thread, just as she starts typing. TRACED.

### Suspects

| # | Mechanism | Label | Why | P | Cheapest confirming measurement |
|---|---|---|---|---|---|
| 2A | **Silent serial store work before the push.** Steps B2–B5 must finish before `pendingOpen` is set. The writer is often busy: a round fires 3 s after every typing pause, and at launch or unlock owner adoption holds the writer for full-table scans (§3). | TRACED (sequence) · SUSPECTED (wait size) | No visual feedback until navigation (the field only shows a stray line). | P2 is honoured (off-main), but latency is user-visible. | Time Profiler + System Trace. Measure the interval from ⏎ to the `pendingOpen` change (the push animation start in the screen recording). Look for `importPost`, `Operations.autosave`, `closeAutoCommit` and a waiting GRDB writer queue. |
| 2B | **Keyboard down then up, with four motions at once.** `reset()` drops focus (B6), the shelf collapses (0.18 s), the push slides in, and two reads plus `renderFull` later the new editor becomes first responder (D4). | TRACED | This is the code order. Even with fast I/O it reads as a stutter. | — | A screen recording (QuickTime on the Mac, or Instruments' screen capture) plus the Animation Hitches lane. Count keyboard dismiss/present pairs per hand-off (expect 1 of each today). |
| 2C | **Redundant arrival reads.** A header read for liveness, then `loadOnce`, then the observation's initial projection fetch re-reads the whole note. The chips read every reading and every tag in the store. | TRACED | D1–D6 above. Small for a fresh quick note, but the same road is O(note) ×2 for long notes (§4). | P1 (chips ∝ readings and tags; projection ×2 ∝ note) | Time Profiler: count `Queries.takesProjection` calls per open (expect 2). Optional: GRDB statement counts via `sqlite3_step` sample attribution. |
| 2D | **Twin view-model graphs.** The seven models are built eagerly in a View `init`. `State(initialValue:)` evaluates its argument on every struct init, and SwiftUI may re-invoke `navigationDestination`'s builder on any shell body change (`tab`, the path, `scenePhase` via the App, the voice). A discarded twin also leaves an autosave holder that is never released (`AppSession.swift:304-320`; the phone never calls `releaseAutosave` for editors, see §12). | SUSPECTED (count) | Construction happens in init; whether SwiftUI re-inits during the push needs counting. | P3-adjacent | **Allocations** instrument, filtered on `MobileEditorViewModel`: allocations per hand-off (expect 1; >1 confirms twins). No code needed. |
| 2E | **The 3 s aftershock.** The `sync_version` bump re-delivers the open note's projection, giving a main-thread `ingest` and `.document` chrome pass while she types. | TRACED | Step E above. | P1 (the delivery is ∝ the note) | Time Profiler window 3–5 s after the hand-off. `MobileEditorViewModel.ingest` and `MobileTakesChromeController.refresh` samples coinciding with a network round. |
| 2F | **The caret lands at the START of her text** (not lag, but friction that feels like it). `renderFull` restores the fresh view's caret (0,0) (837, 860-863), and no place memory exists for a new note. She must tap to the end to continue. | TRACED by reading · confirm on device | | — | Observe on device. |

---

## 3 · Cold start to first interactive frame

### The sequence as built

1. **App init.** `VariorumMobileApp` creates `@State bootstrap = AppBootstrap()` (`VariorumMobile/VariorumMobileApp.swift:29`).
   - `AppBootstrap.init` (`Shared/AppBootstrap.swift:227-271`) composes values: the auth authority (which reads nothing), the sync-keys leaf, the road inputs, defaults-backed ledgers and `ProtectionController`. It then calls `beginOpening()`.
   - `beginOpening()` (314-334) runs `roadInputs.compose()` on the main thread (a struct), then a **detached** `routeAndOpen` (351-401).
   - The first frame is `.opening` → `MobileStoreOpeningView` (`VariorumMobileApp.swift:184-189`).
2. **Off the main thread.** `ProtectionOpenRoad.route`. Under Castle this goes to the **lobby**: Face ID (auto-asked) or the passphrase. After unlock, `openOnTheRoad` → `AppDatabase.openStore(at:custody:)` (`Sources/VariorumCore/Persistence/AppDatabase+Dependency.swift:103-140`). That covers creating the directory, classifying the file, resolving the key, a no-op encryption migration, the `DatabasePool` open with the raw-key PRAGMA (~1 ms, not the KDF; `AppDatabase.swift:107-129`), and `migrator.migrate`.
   - **The store open is off the main thread since 13l L-c** (VERIFIED: `AppBootstrap.swift:53-70`, `322-333`). The previously measured main-thread P2 violation is closed.
   - Previous measurements: simulator 54 ms first launch, ~5 ms reopen, flat in corpus size. Her device: D8, "almost imperceptible" (`notes/plans/mobile-round-2-device-walk.md:223`).
3. **Back on the main thread.** `finish(.ready)` (404-506) builds the road standing and protection models, adopts or installs the binding, installs `OwnerIdentity`, creates a new `AppSession`, and sets `state = .ready`.
4. **The shell.** `MobileShellView.init` constructs six models and binds the quick note (`MobileShellView.swift:156-176`). Its body mounts all three pages, which start their tasks:
   - Starred: `starsModel.start()` (277);
   - Shelf: `model.start()` + `refreshTags()` (`MobileShelfView.swift:145-146`);
   - Library: `startAll()` + **`startBookless()`, which always runs** (`MobileLibraryView.swift:130-131`).
5. **Services, in the App's `.task`** (`VariorumMobileApp.swift:90-183`):
   - `AppServices(...)` init (`AppServices.swift:168-267`) and `attach`;
   - `start()` (298-335): `auth.setOnChange`, the retired-credential sweep (detached), `auth.currentUserID` (Keychain on the auth actor);
   - `connectSyncIfAllowed()` (518-547) runs **`runOwnerAdoption()` first** (584-595). That is `Operations.adoptOwnerID()`, which for every synced table with `owner_id` runs `UPDATE t SET owner_id=? WHERE owner_id IS NULL` in **one write transaction**. There is **no `owner_id` index** (none found in `Sources/VariorumCore/Persistence/Migrations.swift`), so these are **full scans of `block`, `container`, `tag`, `reading`, …, every launch and every unlock** (`OwnerIdentity.swift:87-104`). TRACED.
   - Then `sync.configure` and `triggerSync()`, which is a full round including the janitor's scans (§7);
   - `idleCommits.start()`, an immediate sweep (`IdleCommitScheduler.swift` `start`/`sweepNow`), bounded by a low-water mark;
   - the local purge loop (a no-op while sync is configured);
   - `furniture.prime()`, two reads (`MobileFirstWriteFurniture.swift:176`). For an account-owned store the first-write occasion returns `.accountOwned` at once (234ff).
6. **First interactive frame.** The shelf root draws as soon as `.ready` renders. The quick-note box needs no store to be tappable. **Its first mint, though, queues on the serial runner, which owner adoption (one runner transaction) may be holding**, and the GRDB writer may be busy with the first round's apply and bookkeeping.

### Suspects

| # | Mechanism | Label | P | Measurement |
|---|---|---|---|---|
| 3A | Owner adoption scans every synced table with `owner_id` on every services start, holding the runner and writer. | TRACED · SUSPECTED size (her block count × a cold SQLCipher page cache) | **P1** (O(corpus) per launch/unlock) | Time Profiler: the `adoptOwnerID` → `sqlite3_step` / sqlcipher decrypt samples in the first 5 s after `road: opened`. |
| 3B | The first sync round plus `PurgeJanitor.reconcileLedger`/`sweep`. `collectRoots` scans `container`, `reading` and `block` for tombstones (`Sources/VariorumCore/Sync/PurgeJanitor.swift` `collectRoots`, around 369-410; `deleted_at IS NOT NULL` with no index). | TRACED (scan shape) · SUSPECTED size | **P1** per round | The Network lane (round duration) + Time Profiler on the `SyncScheduler` actor thread. |
| 3C | Every held list fetches at once on a cold store; `startBookless` is the corpus-scale one (§5). | TRACED | P1 | As above; SwiftUI body counts for the three roots in the first 2 s. |
| 3D | Face ID plus the keychain read plus the store open on every cold start (Castle). | SUSPECTED (size) | — | Time from the lobby's Face ID success to the `road: opened` os_log line. |

---

## 4 · Opening an existing note (short and very long), and switching between notes

### Open from a Library or book row

The route is `onOpen(.note(id, focus: false))` → `libraryPath.append` → `MobileWriteScreen` (the same as §2 C–D, minus the quick-note filing, minus the keyboard). Per open:

- the seven-model construction (2D);
- liveness: a header read;
- `loadOnce`: the **whole** `takesProjection`;
- `renderFull` on the main thread, **O(note)**;
- `restore(place)` if she visited this session (`MobileEditorTextView.swift:535-549`, `.ensuresLayout` on the anchor fragment only);
- the observation's initial fetches (header + **the whole projection again**);
- three chip reads;
- **three `.document`-scope chrome passes** (from `renderFull`, from `ingest` after `loadOnce`, and from `ingest` after the first delivery: `MobileEditorViewModel.swift:615`, 866).

**What `takesProjection` reads** (`Sources/VariorumCore/Queries/TakesQueries.swift:83-113`):
- `renderPost` (every slot's text);
- `activeFans` for **every** non-gap block, carrying whole `Variant` rows including `workingText`. So the note's text is read twice per projection, and a fanned block's takes are read too;
- lenses, each lens's selection and dangles, `fanStyle`, `unplacedOrigins`, `blockPresentations`.

Its own recorded measurement: 32 ms for a 212-block note and 237 ms for the fan fetch alone on an 800-block note (Mac, encrypted; 119-130).

**`.document` chrome.** For every fanned block it runs `firstLineGeometry(atOffset:)` with **`.ensuresLayout`** (`Features/Takes/MobileTakesChrome.swift:156-157`, 195-224), plus an O(entries) `blockRangesByID` walk (`MobileEditorTextView.swift:320-331`). Its cost is proportional to the decorated blocks, not to the viewport.

**Short note.** Each piece is small, so the visible cost is the push plus about four reads before the first paint.

**Very long note (the 100k fixture: about 1,370 blocks, a fan every 41st block).** Recorded on the **simulator**: open 433–464 ms (`notes/plans/mobile-parity-end-bundle.md` §5; `notes/plans/mobile-parity-round.md:3280`). **That walk's `openSurface` never calls `start()`** (`VariorumMobileTests/MobilePerfWalkTests.swift:188-205`). So the second projection read, the delivery `ingest`, the chips, the liveness read and the SwiftUI push are **outside every recorded number**. No device run of the 100k fixture is on record: grep finds no `PERF[device]` line, and the parity bundle lists it as "yours, when you want it" (INFERRED).

### Typing in a long note

- **The keystroke path is viewport- and edit-scoped** (`storageDidEdit`, `MobileEditorViewModel.swift:1818-1950`; `.edit` chrome scope at 1949). Simulator p95 is 6–7 ms at 100k against a 12 ms budget (`MobilePerfWalkTests.swift:551-568`).
- Two O(entries) walks remain per keystroke: `restampProjection` (2152-2185), and `index.range(ofEntryAt:)` in `recordAutosave` (1972), which "walks from zero" per the file's own note at 873-881. DEBUG adds `auditIdentityProjection` per edit.
- **What the walk never measured — the autosave echo.** Every 500 ms settle writes `variant` + `container`. `observeTakes` is a **table-grained** observation (`Sources/VariorumCore/Persistence/AppDatabase.swift:237-270`; `TakesQueries.swift:511-516`), so it **re-runs the whole projection off the main thread, compares it whole (`removeDuplicates`), and delivers** because the typed variant's `workingText` changed.
- On the main thread the delivery then runs:
  - `takes.adoptFans` and `takes.overlay` (O(blocks));
  - `EditorProjectionPolicy.decide`, whose `ledger.matches` compares every slot's text (O(note); `Shared/EditorBrain/EditorProjectionEngine.swift:83-103`) and the block-ID sequence;
  - `adoptEcho`: `slots = new; ledger.adopt(new)`;
  - **a `.document` chrome pass** (615);
  - three sibling `projectionDidChange` calls (620-622).
- **This happens on every typing pause, and again after each push's `sync_version` bump.** TRACED. This is P1 in spirit: per-pause work ∝ the document. Its size on device is SUSPECTED.

### Memory

A mounted editor holds the note's text at least four times (TRACED by the fields):
- the `NSTextStorage`;
- `slots` (`MobileEditorViewModel.swift:114`);
- `ledger.textByVariant`;
- `takes`' fans (every take's `workingText`).

Every delivery allocates a fresh projection, so there is churn at each pause. The simulator walk measured a 43 MiB delta against a 250 MiB PROVISIONAL ceiling (`MobilePerfWalkTests.swift:570-582`), without the observation running.

### Switching between notes

- **Pop.** `onDisappear` → `deregister`, `teardown` (disarm canary, await the gesture task, `finish` = idle-mint the tail, flush), then `savepointOnLeaving` (`MobileWriteView.swift:206-226`).
- **The coordinator is kept.** The phone never releases an editor's coordinator: `releaseAutosave` is called only by the quick note (`MobileQuickNote.swift:1099`), and the editor acquires one at init (206). So `postAutosaves` grows by one per note opened per session. `flushEveryOpenPost` and `hasPendingAutosave` walk all of them (`AppSession.swift:416-418`, 607-611). Each item is cheap; TRACED growth.
- **Tab switch with a note open on the target tab.** `selectPage` → `tabDidBecomeVisible` → `takeLiveness(refresh: true)` → flush, header read, **`refreshTakesFromStore()`**: a full projection read plus `ingest` plus `.document` chrome (`MobileLivenessAuthority.swift:135-147`, 213-214; `MobileEditorViewModel.swift:1437-1443`). For a long note, every swipe back to that tab pays O(note). TRACED.
- **Two or three editors can be fully mounted at once** (one per stack; the authority's own header, `MobileLivenessAuthority.swift:13-19`). A stood-down editor keeps its full storage, both observation loops (each re-fetching its whole projection on every write anywhere, §7) and its chrome. **P3 holds for the pen, not for the cost.** TRACED.

---

## 5 · The Library, book and shelf listings

| Listing | Read | Window | Wakes on (table-grained, §7) | Delivers when | Row/body cost on main |
|---|---|---|---|---|---|
| Library "all" (`startAll`, `MobileLibraryViewModel.swift:316-327`) | `observeLibrary(sort:.lastTouched, limit: 200)`: `SELECT … FROM container WHERE kind='post' … ORDER BY COALESCE(last_touched_at, created_at)` (`Sources/VariorumCore/Queries/Timeline.swift:229-252`). **The COALESCE cannot use `idx_container_touched`, so it is a full scan plus a top-N sort over all posts.** | Fixed 200, **silent cut, no probe** (the view's own comment, `MobileLibraryView.swift:419-422`) | Every `container` write: every autosave, every mint, every sync apply and push bookkeeping | Every autosave (the top row's `stamp` moves) | Body re-eval: `rows(books:)` re-unions and re-sorts ≤200 notes + windowed books **per body evaluation**, formatting each book's stamp with `DateFormatter` (196-251); a `ForEach` diff over the union; `LazyVStack` builds only visible rows |
| Library "bookless" (`startBookless`, 331-343) | `Queries.poolPosts` → `notePoolListingSQL` (`Sources/VariorumCore/Queries/ShelfQueries.swift:499-503`, 576-655): **every live post**, each tested by `NOT EXISTS` against memberships **and against every gathering's rule** (`ruleMatchSQL` per gathering), then `ROW_NUMBER()`/`COUNT(*) OVER` partitions | Fixed 200 | `container`, `reading_post`, `reading`, `post_tag`, star `setting`, … | Every autosave of a bookless note (her quick notes are bookless) | Same body as above |
| **Held regardless of the active filter.** `.task { await model.startBookless() }` runs for the Library root's whole life, and the root is always mounted. | TRACED | | | | |
| Shelf books (`MobileShelfViewModel.swift:62-80`) | `Queries.bookshelf` (`ShelfQueries.swift:57-84`): readings + three `GROUP BY` counts over `reading_post` + starred ids | Author-scale, unwindowed (books) | `reading`, `reading_post`, `setting` (NOT `container`; pinned by `MobileShelfPerfTests` via `observationTicks`) | On membership or reading changes | `orderedBooks` is recomputed several times per body (`MobileShelfView.swift:92`, 188, 194); author-scale, so cheap |
| Starred (`MobileStars.swift:130-175`) | `Queries.starred` + one header read per starred note | ∝ stars (deliberately unwindowed) | Reads `container` names, so it re-runs on every autosave | Only when starred names change | Small |
| Book contents (`MobileBookViewModel.swift:90-130`) | `assembleReading(limit: window+1)` | 300 + probe | Table-grained, including `container` | Each autosave of a member note | ≤300 rows, lazy |
| Read flow (`Features/Read/MobileReadView.swift:150-180`) | Per realized row: `renderPost` + `joinRenderedTexts` + `MobileReadPage.paragraphs` | Rows are lazy, but **one row = one whole note** (a 100k note is one realized row of all its paragraphs) | | | Simulator-measured as "READ(100k)"; not the named lag |

**What a sync apply does to visible lists.**
- Every `applyingRemote` transaction and every push bookkeeping write touches `container`, `variant`, `block`, etc.
- That re-runs every held observation listed above (the Library's two, Starred, any open book, **every mounted editor's whole projection**), off the main thread.
- Each list whose rows changed delivers to the main thread, including the **off-screen** Library (it is alive in the band at `MobileShellView.swift:227-241`; offset, not removed).
- The round fires 3 s after every write settles (§2 E), so while she types the cycle is roughly autosave → fetch storm → 3 s → round → fetch storm. TRACED.

**The shelf root's own cost** is small and bounded. The listings' risk is the **Library's two corpus-scale queries re-run at autosave cadence**, plus their off-screen re-renders.

---

## 6 · Returning from background (and leaving)

### Leaving

`.background` → `mobileScenePhaseChanged` (`Features/Shell/MobileShellRouter.swift:306-363`) takes the grant synchronously, then runs:

1. `performBackgroundFlush` (208-277):
   - quick note `fileOnLeaving` (mint + flush + `closeAutoCommit` if text is held);
   - `editors.flushAll()` (each registered editor's `finish`);
   - `savepointOnLeaving` per registered post;
   - **`sync.flush()`, a full network round inside the grant** (`SyncSession.swift:353-365`).
2. `relock.didLeaveTheScreen()` (`Features/Protection/MobileRelock.swift:126-131`). **Under Castle `locksOnLeaving` is always true** (50-52), so `bootstrap.lock()` → `lockOnNewRoad` (`AppBootstrap.swift:1471-1493`):
   - `onWillLock` = `mobileWillLock` (`MobileRelock.swift:80-96`) runs **`flushAll` and the savepoints a second time**, then stops the services;
   - `state = .opening`, which **tears down the whole `.ready` tree**. Each mounted Write screen's `onDisappear` fires a teardown and a savepoint again, racing the lock;
   - `binding.lock()` closes the pool; `finish(.roadLobby)`.

So leaving runs up to three savepoint attempts per open note and one network round, then the lock.

### Returning (Castle: her phone has run Castle with Face ID since VM-8, INFERRED from the run record's summary)

1. `.active` → `relock.didReturnToTheScreen()` → `leftAt` was cleared by the lock, so it returns false → `services?.sync` was captured as nil, so there is no trigger (`VariorumMobileApp.swift:252-255`; `MobileShellRouter.swift:316-325`).
2. **The lobby** → Face ID → `beginOpening(roadOpened:)` → detached store open (§3 step 2) → `finish(.ready)` with a **new `AppSession`** (`AppBootstrap.swift:496`).
3. The App body switches to `.ready` and builds a **brand-new `MobileShellView`**:
   - every `@State` resets: the three navigation paths go empty and `tab = .shelf`, so **she lands on the Shelf root, not her note**;
   - every model is new and every observation's initial fetch runs on a cold store;
   - new `AppServices` → `start()` → **owner adoption full scans** (3A) → configure → **a sync round** (pull + push + janitor scans);
   - `furniture.prime()`.
4. The pool was closed, so **the SQLite page cache is gone** and every first read decrypts its pages from flash. SUSPECTED as a large share of "everything feels slow right after coming back".
5. **Without Castle** (Standard), `.active` simply triggers one round (`MobileShellRouter.swift:316-319`).

**Scene-phase churn while the app is open.** The root applies `.redacted(reason: SnapshotPrivacy.redactionReasons(for: scenePhase))` (`VariorumMobileApp.swift:73`; `Features/Shell/SnapshotPrivacy.swift:25-27`). Every active↔inactive flip (Control Center, a banner, the app switcher) changes `redactionReasons` for the whole tree, and Text resolves redaction. That re-evaluates the App body, which re-inits `MobileShellView` (six model inits, which are cheap) and may re-run `navigationDestination` (2D). SUSPECTED; SwiftUI instrument body counts across a Control Center pull.

### Suspects

| # | Mechanism | Label | P |
|---|---|---|---|
| 6A | The full rebuild on every return under Castle: cold store, every list's first fetch, owner adoption, first round, lost navigation. Her separate high-priority ask ("app staying unlocked for a few minutes") is exactly this road. | TRACED | P1 (adoption, janitor) |
| 6B | Leaving does a network round, then the lock. If the round is slow, the grant can expire. The lock leg runs anyway, "deliberately NOT gated" (`MobileShellRouter.swift:346-351`). | TRACED | — |
| 6C | Duplicate flush and savepoint attempts on leaving: up to three per note. Each is deduped by `closeAutoCommit`, but each is a runner transaction. | TRACED | — |

---

## 7 · The one mechanism under most of this: the observation wake map

`AppDatabase.observe` tracks **whole tables** (raw SQL with TEXT primary keys cannot narrow by rowid). Its own doc: "any write to a tracked table re-runs the fetch — in the worst case at autosave rate … A held observation's fetch must itself be viewport-shaped" (`Sources/VariorumCore/Persistence/AppDatabase.swift:237-249`). The constant-region variant (`observe(tracking:)`, 272-296) exists, but no phone list uses it.

| Write (frequency) | Re-runs off main | Delivers to main (re-render) |
|---|---|---|
| Quick-note autosave (each 500 ms pause while typing in the box) | Library `library` (O(posts)) · Library `poolPosts` (O(posts × gatherings)) · Starred · outbox count · **every mounted editor's whole `takesProjection`** (O(that note), even though she is typing elsewhere) · any open book | Library ×2 (off-screen) |
| Editor autosave (each pause in a note) | All of the above | Library ×2 · **the open editor: O(note) `ingest` + `.document` chrome** |
| Mint (`importPost`) | All of the above | Library ×2 |
| Sync push bookkeeping (3 s after any of the above) | All of the above | Open editor (`Variant.syncVersion` changed) · Library only if rows changed |
| Sync apply (remote changes) | All of the above | Whatever changed, including off-screen pages |

Every row is TRACED from the observation definitions cited in §4 and §5.

---

## 8 · P-violations, consolidated

**P1 — cost ∝ viewport + edit, never document or corpus:**
1. `startBookless` / `notePoolListing`: corpus-scale, re-run on every `container` write, held always. TRACED.
2. `observeLibrary`'s COALESCE ordering: an O(posts) scan + sort per `container` write. TRACED. The core doc names it "∝ post count"; it is corpus-shaped.
3. `adoptOwnerID`: full-table UPDATE scans on every launch and every Castle unlock, no index. TRACED.
4. `PurgeJanitor.collectRoots`: full tombstone scans of `container`, `reading` and `block` after every clean round, and a round follows every write settle. TRACED shape.
5. Every mounted editor's `observeTakes` re-reads its whole note on writes to **any** note; the open editor's delivery does O(note) main-thread work per typing pause. TRACED. Never measured: the walk omits `start()`.
6. `.document` chrome on every delivery: `.ensuresLayout` for every fanned block, not the viewport. TRACED.
7. Open is O(note) by design (AppSpec §4: within-post virtualization is the unbuilt escape hatch). Accepted, but the note is read twice and the chrome is laid out three times. TRACED.

**P2 — no database I/O on main:**
- Honoured as far as read.
- The store open is off main since 13l L-c (VERIFIED).
- No synchronous `database.read`/`write` was found on main-actor phone code. The one synchronous read in `Features/Write/MobileStructural.swift:822` is inside a runner closure (VERIFIED).
- `Shared/SampleLibrary/*` synchronous reads were not exhaustively checked; they are a furniture path, and an account-owned store skips it.

**P3 — one live editor:**
- The pen is single (the liveness authority).
- Up to three **mounted** editors, each with full storage, observations and chrome (§4). TRACED.
- Possible twin view-model graphs per re-render (2D, SUSPECTED).

**Memory:** at least four text copies per mounted editor, plus projection churn at each pause (TRACED fields; size unmeasured on device).

---

## 9 · Perf tooling and fixtures for the phone, and whether they still build (by reading)

| Item | What it is | Builds against today's tree? | Gaps |
|---|---|---|---|
| `VariorumMobile/Features/Perf/MobilePerfFixtureSeeder.swift` | A deterministic ~100k-word post ("the long haul", ~1,370 blocks, a fan every 41st block, a comment every 53rd, a callout every 97th), a 300-note corpus over six books, and a 4k control post. | **Likely yes (INFERRED).** Last touched 2026-09-30 (the 13i-a schema sweep). Its core calls exist with matching labels; spot-checked `createReading(name:kind:profile:)` and `addBlockComment(to:text:)`, the rest present by grep. | The door is **DEBUG-only** (Settings ▸ "Seed the 100k fixture", `MobileSettingsView.swift:294-345`, 422-505), and DEBUG resolves the **dev store** (`Shared/StoreLocation.swift:30-39`). So on device the 100k numbers are **-Onone + DEBUG oracles** numbers. All Home wing; no 9-wing shape. |
| `VariorumMobileTests/MobilePerfWalkTests.swift` | Fixture shape pins; open/typing/scroll/memory walk with budgets (open floor 30 ms, typing 12 ms, scroll 4 ms, memory delta 250 MiB PROVISIONAL); a Read-surface probe; launch-path store-open timing (`MobileLaunchPathTests`). | **Likely yes (INFERRED).** Symbols spot-checked: `MobileEditorViewModel(session:postID:sleep:)`, `MobileWriteSurfaceView`, `attach(textView:)`, `loadOnce`, `rangeOfBlock`, `AppSession(database:)`, `AppDatabase.openStore(at:)`, `typeEdit`, `SeededGenerator`. | Simulator only, under `xcodebuild test` (stage claim). **Windowless editor with no `start()`, no shell, no push, no keyboard, no SwiftUI**, so none of §2's choreography or §7's storms is measured. **`MobileLaunchPathTests`' doc (985-989) is stale**: it says the main-thread open "is live on every launch", but L-c closed it. |
| `VariorumMobileTests/MobileShelfPerfTests.swift` | Quick-note mint and per-keystroke cost, flat in corpus size; proves a bookless mint does not wake the shelf observation (`observationTicks`). | Likely yes (INFERRED). | Never counts **Library** wakes, which is where the box's real churn goes (§5). |
| `VariorumMobile/Spike/*` (the Stage 0 TK2 bench) | A UIKit-only TK2 scenario bench. DEBUG; auto-runs with `TK2SPIKE_AUTORUN=1` or `-TK2SPIKE_AUTORUN`, and `TK2SPIKE_UI`. Prints `TK2SPIKE|` lines and `Documents/tk2spike-results.log` (`Spike/SpikeScreen.swift:12-25`). | Likely yes (INFERRED): no VariorumCore dependency; last touched 2026-08-03. | Bare TK2 only; it is the platform floor, not the app. |
| Settings ▸ Diagnostics: the E1 edit trace (`Features/Write/MobileEditTrace.swift`) | A gate/report trace for the input path. | Ships in Release. | Not a timing instrument. |
| `Tools/ScaleFixture/stage.sh`, `restore.sh` | The Mac dev-store large fixture. | n/a | **Mac-only** (Mac container path, `open -n Variorum.app`). Not usable for the phone. |
| os_log markers already in the app | `io.lduarte.Variorum` categories: `protection` ("road: opened — …" once per open, "road: locked — …" per lock: `Shared/Protection/ProtectionOpenRoad.swift:339`, 1077, 1129-1140; `AppBootstrap.swift:1491`) · `first-write-furniture` (`MobileFirstWriteFurniture.swift:150-232`) · `sync` (errors only, `Sources/VariorumCore/Sync/PullStage.swift:60`) · `tk2-canary-ios` (fault only). | | **No `os_signpost`, no MetricKit, no timing log anywhere in the app** (grep). The shell, the hand-off, the arrival and the first paint have no marker. |
| Numbers on record | Simulator: open(100k) 433–464 ms; keystroke 6–7 ms; scroll step 1.7 ms; walk delta 43 MiB; launch open 54 ms first / ~5 ms reopen. Device: D8 cold launch "almost imperceptible". **No on-device 100k run is on record** (INFERRED: no `PERF[device]` line; the parity bundle §5 still lists it as hers). | | |

---

## 10 · Ranked likely causes of the two lags

### Lag 1 — "going to the quick entry box"

1. **Castle re-lock on every leave.** Every return rebuilds the whole shell on a cold, reopened, encrypted store while owner-adoption full scans, the first sync round plus janitor scans, and every list's first fetch (including the corpus-scale bookless query) run. Main-thread deliveries and CPU contention land exactly when she reaches for the box. (§6, §3; TRACED mechanism, SUSPECTED size.) *Likeliest when the lag is "after I open the app".*
2. **The focus choreography.** The 0.18 s split animation, a vertical TextField re-shaped (lineLimit 1→N, minHeight) while it takes first responder, and keyboard avoidance re-laying out all three pages, including the off-screen Library. (§1 1B; TRACED passes, SUSPECTED cost.) *Likeliest when the lag is every time.*
3. **First-keyboard / input-session start-up** on a freshly built field after every unlock. (§1 1C; SUSPECTED, platform.)
4. **Coming back from a long note:** teardown plus closeAutoCommit O(note) on the serial runner delay the box's first mint ("saving…" lingers). (§1 1D; TRACED.)
5. **Typing in the box wakes the off-screen Library twice per autosave,** plus a round 3 s later. This costs typing smoothness more than the tap-in itself. (§1 1E, §7; TRACED.)

### Lag 2 — "going from the quick entry box into a note"

1. **Silent serial store work before any navigation.** 1–4 runner/writer transactions (mint if under 1 s, render read, flush-all, closeAutoCommit) must finish before the push even starts, often behind a sync round's writer work, since a round fires 3 s after every typing pause. (§2 2A; TRACED sequence, SUSPECTED wait.)
2. **Keyboard down then up, with four motions at once.** `reset()` drops the keyboard and collapses the box; the push slides; two reads and a full render later the editor takes first responder and the keyboard rises again. (§2 2B; TRACED.)
3. **Redundant arrival reads.** A liveness header read plus `loadOnce` before first paint, then the observation's initial fetch reads the whole note again. The chips read every reading and every tag. That is 8–11 round trips around one hand-off. (§2 2C; TRACED.)
4. **The 3 s aftershock.** The push's `sync_version` bump re-delivers the note's projection, giving a main-thread `ingest` plus `.document` chrome just as she starts typing. (§2 2E; TRACED.)
5. **Possible twin construction** of the seven-model editor graph in a View init during the push. (§2 2D; SUSPECTED; one Allocations count settles it.)
- *Felt as lag: the caret lands at the start of her text* (2F).

---

## 11 · DEVICE SESSION PLAN (her iPhone plugged into the Mac)

Written for another agent to run. **This needs her hands and her word** (CLAUDE.md: device, GUI, her install). Ask before step 0.

### 0 · Decisions to ask her first, and the setup

- **Which store.** Ask her which arm, or both:
  - **(A) Realistic:** Xcode ▸ Product ▸ **Profile** (Release, development-signed) over **her real store**. Same bundle id `io.lduarte.VariorumMobile` for Debug and Release (`Variorum.xcodeproj/project.pbxproj:955`, 990), so this **replaces her installed app** and opens her real corpus (Castle; she unlocks with Face ID). Before installing, confirm the phone's sync row says synced, so no phone-only writes are pending. Note the installed version so it can be restored.
  - **(B) Synthetic 100k:** a **Debug** run on the dev store, seed via Settings ▸ "Seed the 100k fixture". Numbers are **-Onone + DEBUG oracles**; use them only for the document-size axis and for ratios. Never quote them as absolutes.
- **Stage.** Hold a `Tools/stage` claim on the Pro, since Instruments drives the Mac GUI. Use the Pro, not the Air, unless she says otherwise.
- **Record the environment:** iPhone model, iOS version, the app version and build, her Castle mode, her wing count (9), and her note count (Library ▸ All count).
- **Tooling:**
  - `xcrun xctrace list devices` gives the UDID.
  - Record with `xcrun xctrace record --device <UDID> --template '<T>' --attach VariorumMobile --time-limit 30s --output notes/plans/vm-44/audit/traces/<flow>-<n>.trace`. Add the os_log instrument; check its name with `xcrun xctrace list instruments`.
  - Templates used: **Time Profiler**, **Animation Hitches**, **SwiftUI**, **Allocations**, **System Trace**, **App Launch**.
  - A screen recording (QuickTime ▸ New Movie Recording ▸ the iPhone) runs beside every flow, so keyboard and animation choreography is visible frame by frame.
  - Markers: the existing os_log lines `subsystem:io.lduarte.Variorum category:protection` ("road: opened", "road: locked"). Mark taps by the screen recording's frame numbers.
- **Repetitions:** each flow 5×. Report the median and the range, never a single number (the record's own rule, `MobilePerfWalkTests.swift:976-978`).

### The flows

| Flow | Do | Instruments | Numbers to report |
|---|---|---|---|
| **F1 Tap into the box** (cold and warm) | (a) Background 10 s → return → Face ID → tap the box at once. (b) Then dismiss the keyboard, wait 10 s, tap again. | Time Profiler + Animation Hitches + SwiftUI | Tap → keyboard fully up (ms, from the recording) · main-thread busy ms from tap to keyboard settled · hitch count and total hitch ms · body-update counts for `MobileShelfView`, `MobileQuickNoteBox`, `MobileLibraryView`, `MobileStarredView` · cold − warm difference |
| **F2 Type in the box** | Type one sentence over ~10 s, then wait 5 s (mint, autosaves, a round). | SwiftUI + Time Profiler + System Trace | `MobileLibraryView` body updates per autosave (§7 predicts ~2) · CPU ms in `notePoolListing` / `Queries.library` frames per autosave · round start (Network lane) ≈ 3 s after the last keystroke · writer-queue waits |
| **F3 Box → note** | Type a sentence, wait 2 s, press ⏎. Repeat with `open ↵`. Repeat pressing ⏎ within 0.5 s of the first character (the pre-mint arm). | Time Profiler + System Trace + **Allocations** (filter `MobileEditorViewModel`) + screen recording | ⏎ → push animation start (ms) · push start → first text paint · → keyboard live · keyboard dismiss/present pairs (expect 1 each) · `MobileEditorViewModel` allocations per hand-off (1 = no twins) · `takesProjection` call count (expect 2) · the 3–5 s window after: `ingest` + `MobileTakesChromeController.refresh` samples |
| **F4 Cold launch** | Force-quit, then launch (arm A: through Face ID). Type into the box within 2 s and press ⏎. | App Launch + Time Profiler | Launch → lobby · Face ID success → `road: opened` · → shelf rows populated · CPU in `adoptOwnerID` (UPDATE scans), `PurgeJanitor` and sync in the first 5 s · whether the F3 hand-off is slower here than in F3 |
| **F5 Leave and return** (Castle) | Open a note, background the app; 10 s later return. | Time Profiler + os_log | `.background` → "road: locked" (ms; includes a network round) · return → Face ID → "road: opened" → shelf interactive · CPU breakdown: store open, owner adoption, first round, list initial fetches · confirm she lands on the Shelf root, not her note |
| **F6 Open notes** | From the Library open (i) a short note, (ii) her longest real note (arm A) or "the long haul" (arm B). Close each and repeat. | Time Profiler + Allocations (+ VM Tracker) | Tap → first paint · main-thread ms in `renderFull` (`materializeCore`, `MarkdownFace.style`, `setAttributedString`) · `takesProjection` count and duration (off main) · `.document` chrome ms · memory: phys-footprint delta after open and peak during, in MiB (the jetsam bar) |
| **F7 Type in the long note** | 30 keystrokes, pause 2 s; ×3. | Animation Hitches + Time Profiler | Keystroke p95 (compare to the simulator's 6–7 ms) · **the hitch at each pause** (`ingest`, `EditorSurfaceLedger.matches`, `.document` chrome) in ms · the same 3 s after (the `sync_version` re-delivery) |
| **F8 Tab switch with a long note open** | Library stack holds the long note; swipe Shelf ↔ Library ×5. | Time Profiler | ms per switch in `refreshTakesFromStore` / `ingest` |
| **F9 A remote change arriving** | Phone on the Library; edit a note on the Mac; wait for the round. | SwiftUI + Time Profiler | Body updates per apply for off-screen pages · main-thread ms per apply |

### Output and stop

- **Write up:** a table per flow (median, range, n), the trace file paths, and for each suspect in §10 a verdict: CONFIRMED (number), REFUTED (number), or INCONCLUSIVE. Put it in `notes/plans/vm-44/audit/F-device-results.md`.
- **Stop:** restore her normal Release install, or leave it if arm A was a Release Profile build. Release the stage claim.

---

## 12 · Side findings outside perf (for the relevant readers)

1. **After a Castle relock the quick note is bound to a STALE session.**
   - `MobileQuickNoteModel.bind` is a no-op once set (`MobileQuickNote.swift:328-330`), but every unlock creates a new `AppSession` (`AppBootstrap.swift:496`), and the router, which owns the box, outlives it (`VariorumMobileApp.swift:33`).
   - After the first relock the box mints, flushes (`flushEveryOpenPost` walks the OLD registry, not the open editors') and registers undo through the old session.
   - Mechanism TRACED; behavioural consequence not run. (Capture / Castle reader.)
2. **The caret lands at the note's start** after the quick-note hand-off (2F). (Capture / editor reader.)
3. **The Library note listing silently cuts at 200** (`MobileLibraryViewModel.swift:77`; the view admits it at `MobileLibraryView.swift:419-422`). If her library holds more than 200 notes (likely with 9 wings; INFERRED, her count is unmeasured), older notes are reachable only by search. (Library reader.)
4. **The phone never releases editor autosave coordinators** (`MobileEditorViewModel.swift:206`; only the quick note releases, `MobileQuickNote.swift:1099`). The registry grows by one per note opened per session.
5. **Some editor state is not observed.** The masthead's date chip reads `model.header?.entryDate`, but `header` is `@ObservationIgnored` (`MobileEditorViewModel.swift:128`; chip at `MobileWriteView.swift:456-468`). It refreshes only because `displayTitle` changes in the same pass. (Editor reader.)
6. **`MobileLaunchPathTests`' doc comment is stale** (it says the main-thread open is still live; 13l L-c closed it).
