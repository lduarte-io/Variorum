# VX-143 — cold review of the post-ladder additions (opus-reviewer, 2026-10-11)

**Scope (the brief):** commits `3e93389a` + `c36c423f` (VX-155 pin + fix), `a4d2d798` (VX-139 — the Open strip across launches), `834296d0` + `44744d22` (the consequential pin edits). Not under review: the `eca507b2` merge of main (13n-b), the record commits.
**Prompt:** `notes/REVIEW_PROMPT.md`, verbatim.
**Seam check (first, per the brief):** the diff's file list is `TakesShared.swift`, `TakeCardDoorTests.swift`, `WorkspaceNavigation.swift`, `WorkspaceModel.swift`, `RootView.swift`, `AppSettingsView.swift`, `SettingsShape.swift`, `OpenNotesMemoryTests.swift`, `DiagnosticsPaneTests.swift`, `SettingsShapeTests.swift`. No `Sync/`, no custody/keychain code, no editor seam, no schema, no `Shared/`, no `Sources/`. One note for the orchestrator: VX-139 ships a NEW setting whose default (ON) changes what every launch shows — a new default for a new feature (PROVISIONAL (i) in the record), not a change to an existing default's meaning; I judge it outside Fable's mandatory scope, but it is the orchestrator's call.

**STATUS: COMPLETE.** Verdict: **0 BLOCKER · 1 MAJOR · 5 MINOR · 4 NIT.**

## Findings

### [MAJOR-1] · `WorkspaceModel.swift:397/421` + `RootView.swift:152,169,429` + `VariorumApp.swift:161–169,430–433` · VX-139's launch claim is process-global and never released, so the first relock of a session silently ends the remembered strip, and the next launch restores a stale one

- **What's wrong.** `launchRestoreClaimed` is a `static` set once per process and never cleared; `remembersOpenNotes` is per-instance. A relock tears down the claimant shell and builds a successor that can never claim. From the relock on, the strip is neither restored nor persisted. The store keeps the pre-relock strip, so the next launch restores that strip rather than the one she left. That breaks the setting's own words (`AppSettingsView.swift:521`: "returns as you left it the next time Variorum opens").
- **Evidence (traced):**
  1. Sleep, screen lock, or the 10-minute idle clock reaches `relockIfPolicySays` / `relockIfIdle`, which calls `performLock` (`ProtectionController.swift:1892–1903`). That calls `AppBootstrap.lock()` (`AppBootstrap.swift:157/213 → 870`), which sets `state = .locked(...)` (`:892`).
     - The idle clock defaults to 10 minutes (`StoreProtection.swift:219–221`) and counts only Variorum's own events (the VX-140 trace in this run's record). So for her Touch-ID-protected store this happens in nearly every working session.
  2. `mainWindowContent` switches from `RootView` to `StoreLockView` (`VariorumApp.swift:162/430`). This tears down the `.ready` subtree and the RootView's `@State router`.
  3. On unlock, a new `RootView` is built with the init's default `ShellRouter()` (`RootView.swift:152,169`). It has a fresh `WorkspaceModel` and an empty strip.
  4. Its `.task` (`RootView.swift:429`) calls `restoreRememberedOpenNotes`, which returns at `guard !Self.launchRestoreClaimed` (`WorkspaceModel.swift:421`). As a result:
     - `remembersOpenNotes` stays `false`.
     - Every later `visit`/`closeNote`/`moveOpenNotes`/`notesDeleted` skips `rememberOpenNotesIfClaimed()` (`:452–455`).
     - The defaults hold the strip as it was at the relock.
  5. At quit and relaunch, the stale strip comes back. The same road runs when she closes the main window (⌘W) and reopens one from the Dock.
  - The record's corner (iv) names only "the claiming window closes". It misses the relock, which happens without any window closing. The codebase itself treats relock + unlock as an OPEN: "a relock + unlock is an OPEN — every per-open deferral … resets here" (`AppBootstrap.swift:894–896`).
  - The existing pin `theFirstShellRestoresLiveRowsAndWritesBackTheSecondStaysEmpty` is right for a concurrent second window. It cannot tell that window apart from the claimant's successor, which is the case that breaks.
- **Proposed fix.** Release the claim when the claimant's shell tears down: in `RootView.onDisappear`, if `router.workspace.remembersOpenNotes`, clear the static. Alternatively, key the claim to the ready epoch (for example, a flag on the per-ready `AppSession` instead of a process static).
  - The successor shell then claims, restores the stored strip (which was current up to the teardown), and keeps persisting. This brings her tabs back after unlock too, which follows the code's own "relock + unlock is an OPEN" reading.
  - If restoring after unlock is judged a product step beyond her ask, the minimum fix is still that the successor re-claims and persists. Bring the restore-after-unlock arm to her as a PROVISIONAL.
- **Pin (red on this tree).**
  1. Mount `RootView` (the claimant) in a window, visit `p1`, then close the window. This is the same `onDisappear` teardown the lock's state flip performs.
  2. Mount a second `RootView` over the same store, the unlock analog. Visit `p2`.
  3. Assert the remembered ids equal the second shell's strip. Assert also that the second shell came back with `p1` if the restore arm is adopted.
  - On the current tree the stored ids stay `[p1]`, so the pin is red.
  - The pin needs a defaults seam on `RootView`, or a snapshot/restore of the `.standard` keys, because `RootView.swift:429` hard-wires `.standard` (see MINOR-4).

### [MINOR-1] · `GeneralPane` (`AppSettingsView.swift:442,520`) + `OpenNotesMemory.remember` (`WorkspaceNavigation.swift:427–431`) + `WorkspaceModel.swift:425` · the toggle takes effect only at the next strip change, so the stored strip can be stale in both directions

- **What's wrong.** Flipping the toggle writes only the `keepOpenNotes` key. Nothing observes it. `remember` runs only when the strip changes, and a launch with the setting off returns at `:425` before touching the stored rows.
- **Mechanism (a) — on with notes open, then an empty restore:**
  1. On, strip `[A]`.
  2. Toggle off, then open B. `remember` calls `forget`, so the store is empty.
  3. Toggle on again and quit without touching the strip.
  4. The next launch restores nothing, even though she left `[A, B]` open with the setting on.
- **Mechanism (b) — an old strip resurrected:**
  1. On, strip `[A, B]`. Toggle off and quit; the rows stay on disk.
  2. The next launches run with the setting off and no strip change, so they never clear the rows.
  3. Weeks later she toggles on and quits without a strip change.
  4. The next launch restores the weeks-old `[A, B]`.
- **Fix.** Make the setting act when it changes, not at the next strip change:
  - The claimant observes the key: a KVO / `UserDefaults.didChangeNotification` observer in `WorkspaceModel`, or a notification posted from `GeneralPane`'s `.onChange(of: keepOpenNotes)`. When the setting turns on, write the current strip; when it turns off, forget.
  - Also call `forget` at a launch with the setting off.
- **Pin (red on this tree).** Claim with private defaults, visit p1 and p2, set the key false, visit p3 (the store clears), set the key true, and post the change signal the fix listens to. Then `#expect(stored.ids == shell.openNotes.ids)`. Today the store is `[]`, so the pin is red.

### [MINOR-2] · `WorkspaceModel.swift:428–435` · any read failure wipes the remembered strip

- **What's wrong.** `(try? await session.database.read { … }) ?? []` treats any error as "every stored note is dead". Line `:431` then builds an empty strip, and `:435` writes it, so the remembered rows are destroyed.
- **Evidence.** GRDB's async read throws `CancellationError` when the task is cancelled (the `DatabaseReader.swift:214–217` contract in the checked-out GRDB). It also throws `connectionIsClosed` on a closed pool, and `AppDatabase` raises `StoreLockedError` once locked (`AppDatabase.swift:171`). The restore runs in RootView's `.task`, which is cancelled when the `.ready` subtree tears down, for example at a lock or a window close during the read. The window is milliseconds at launch, so this is narrow but destructive and silent. It also contradicts the init's own "defensive against a torn store" posture.
- **Fix.** `guard let live = try? await … else { return }`. On an error, leave both the strip and the store untouched (the claim may stay).
- **Pin (red on this tree).** Store `[p.id]` in private defaults, `let t = Task { await shell.restoreRememberedOpenNotes(session:, defaults:) }`, `t.cancel()`, `await t.value`, then `#expect(OpenNotesMemory.stored(defaults).ids == [p.id])`. On this tree the stored ids come back `[]`.

### [MINOR-3] · `TakeCardDoorTests.swift:448–463` (VX-155's pin) · a whole-file source lint stands in for a behavioural pin that is available

- **What's wrong.** The lint counts `.controlSize(` across all 851 lines of `TakesShared.swift`. That file holds about ten other views (`TakesEmptyStateView`, `TakesCellView`, `CommentMarginNote`, `TakeLabelSheet`, `LensNameSheet`, …).
  - **False red:** any future control size on one of those views, for example a sheet's buttons, fails the pin with a message that blames the card menu.
  - **False green:** the bug can come back one layer up. Any `.controlSize(.mini)` applied by an ancestor at either mount site (`WriteTakesPanel.swift:319`, `TakesBoardView.swift:1769`) is inherited by the popped `NSMenu` exactly as before, and an `.environment(\.controlSize, …)` spelling also passes the lint.
  - The "control" arm (`source.contains("systemFontSize(for: .mini)")`) checks a spelling, not that the glyph is still mini.
- **Evidence — a behavioural pin is reachable.** The suite header says a `Menu` "is not an NSView a pin can find". That holds for clicking, not for introspection. I hosted the old and new menus in an `NSHostingView` in a standalone probe on this Mac (macOS 27 SDK), outside the repo. The `Menu` is backed by `SwiftUIPopupButton`, an `NSPopUpButton`.

  | Menu | Control size | Font | `menu.font` | Fitting size |
  |---|---|---|---|---|
  | Old | mini | 9 pt | 9 pt — the bug, measured | 28×11 |
  | New | regular | 13 pt | 13 pt | 28×11 — identical, so the ⋯ chrome did not grow |

  A no-font label measures 32×16, which shows the label font is honoured.
- **Fix.** Replace or supplement the lint with an introspection pin at both mounts (the Write panel's card and the board's card). Find the `NSPopUpButton`, assert `menu?.font.pointSize == NSFont.systemFontSize` and `controlSize == .regular`, and assert the glyph's fitting size equals the mini metric. It is red on the old tree (9 pt / mini), green on the fix, and discriminates by behaviour rather than spelling. If the lint stays, scope it to `TakeCardMenu`'s body.

### [MINOR-4] · `RootView.swift:429` + `WorkspaceModel.swift:418–420` · the launch restore hard-wires `.standard` with a process-global claim, so the test host's shells share it

- **What's wrong.** `RootView`'s `.task` passes no defaults, so production `.standard` is used, and about 20 suites mount `RootView` (`grep "RootView(" VariorumTests`). Whichever shell first runs the task becomes the process claimant. That is the host app's own window if the dev store reaches `.ready` first; otherwise it is the first RootView-mounting test. The claimant restores from the dev app's real defaults domain and writes back to it.
  - When a test shell claims, its in-memory fixture's ids land in the dev app's `.standard`.
  - Under `$0.uuid = .incrementing`, the next run's first claimant can find those ids live in its own fixture. Its strip is then replaced after the read's await.
  - The outcome is environment- and order-dependent strip contents in the shell suites.
- **SPECULATIVE as to frequency.** I ran `NavigationDoorsTests` alone (`App/Variorum/DerivedData/vx143-review-navdoors.log`, 6/1 green). The dev domain's `openNotes.remembered.*` was unchanged afterwards (snapshot taken before and after), which is consistent with the host window claiming first in this environment. The mechanism is traced; I did not observe a failure.
  - It is the known shared-`UserDefaults` class (CLAUDE.md), made sharper by the first-claimant-wins static.
  - It cuts against "persistence and side effects live in injected dependencies".
- **Fix.** Give the claim a seam: a `RootView` init parameter for the defaults and the claim, or carry them on the session, in the `freshTakeCardDefaults` precedent. MAJOR-1's pin needs the same seam.

### [MINOR-5] · `WorkspaceNavigation.swift:19–21, 236–239, 256`, `SidebarView.swift:727` · the governing docs now contradict the code, and the record mis-frames PROVISIONAL (iii)

- **Stale docs.**
  - The file header still promises "View state, and only view state … never persisted" and "Nothing here touches the store". The same file now hosts `OpenNotesMemory`, a `UserDefaults` persistence shim, which is a side-effecting type in the file whose header is the pure-types promise.
  - `:236–239` says a note "leaves only when its row is closed or it falls off the session bound".
  - `:256` says "Manual reorder is hers, session-only and never a setting".
  - `SidebarView.swift:727` cites "her session-only ruling".
  - All four now describe behaviour the code no longer has.
- **The record's framing.** The 13f record (`phase-13f-workspace.md:1600–1605`) recorded the round-7.1 ruling as "session-only manual drag-reorder". The ruling-faithful alternative to PROVISIONAL (iii) is therefore "restore in INSERTION order, dropping only her manual arrangement". That needs the insertion order tracked beside `ids`. The record's option (b), "re-derive recency order", is not that alternative, so she is not offered the choice the ruling implies.
- **Fix.**
  - Amend the four doc sites to say what is now true.
  - Move `OpenNotesMemory` into its own file beside `WorkspaceModel`.
  - Re-word PROVISIONAL (iii)'s alternative before it goes to QUESTIONS at the merge. Name the supersession plainly: her VX-139 ask ("a keep tabs open setting") supersedes the strip's session-only lifetime, and the reorder's persistence is the open question.

### [NIT-1] · `WorkspaceNavigation.swift:288–293` + `OpenNotesMemoryTests.swift` `restoreHonorsTheTrackedCap` · the torn-store cap evicts by strip position, against the ruled membership rule

- **What's wrong.** The cap uses `prefix(trackedCap)` in strip order. The ruled rule is "membership is RECENCY's — the LEAST-RECENTLY-OPENED note leaves, never the oldest-inserted one" (`:252–255`), and the pin enshrines the position-based cut.
- **Reach.** Only a torn or hand-edited store gets here, because a valid `OpenNotes` never exceeds 20.
- **Related.** `liveNoteIDs` runs over the uncapped stored list, so the doc's "bounded by the tracked cap" (`WorkspaceModel.swift:411`) is literally true only for a well-formed store.
- **Fix.** Keep the 20 most recent by stored recency, in strip order, and cap the query list.

### [NIT-2] · `WorkspaceModel.swift:427–433` · the restore replaces the strip after its await

- **What's wrong.** A note opened between the pre-await `openNotes.ids.isEmpty` check and the read's return is dropped from the strip while its pane shows it. Examples are a launch-time `.variorumOpenPost` broadcast, ⌘N, or a pending selection. The window is milliseconds.
- **Fix.** Merge the restored rows first, then any ids opened meanwhile.

### [NIT-3] · stale comments and wording in the touched files

- `TakesShared.swift:597–599` and `WriteTakesPanel.swift:315` still say the chrome is "unchanged to the byte"; VX-155 moved the control size off the `Menu`.
- `AppSettingsView.swift:429–433` ("this one holds four") and `SettingsShapeTests.swift:158–159` ("which holds four") are stale.
- The P-VX139-vi annotations say the section sits "at the pane's BOTTOM". That is true only where Updates is not live (Debug); in Release, Updates renders below it (`AppSettingsView.swift:531`).
- The DiagnosticsPaneTests row-59 intent would be held directly by `!SettingsCatalog.rows(in: .general).contains { $0.id == "crashReports" }` rather than the count proxy now loosened to 6.

### [NIT-4] · `OpenNotesMemoryTests.swift` `freshDefaults()` (both suites) · leaked suite plists

- **What's wrong.** `removePersistentDomain` runs before use, never after. Each run leaks per-test suite plists into the dev container's Preferences; 10 `OpenNotes*` files are there now, and the directory already holds about 12.7k files of the same class.
- **Fix.** `defer { defaults.removePersistentDomain(forName: suite) }`.

## Clean bill

- **VX-155 mechanism and fix, verified by my own probe** (MINOR-3's table): the old menu's popped `NSMenu` font was 9 pt / mini, which was her report. The new one is 13 pt / regular, and the label's fitting size is identical, so the glyph metric is preserved.
  - Neither mount site's ancestors carry a control size. In `WriteTakesPanel.swift:288–339` only sibling buttons do. `TakesBoardView.swift:1732–1773` and its mounts in `PostDetailView.swift:429` and `SpreadBookView.swift:355` carry none, and neither does the `EditorView.swift:190` sheet host. So the fix reaches both of her surfaces.
- **P-8 kept:** `lineLimit(1)` + `fixedSize()` remain on the chrome. The label font is the system font at the mini metric (no colour literal); the old control drew the same.
- **The claimed runs, verified in the logs:**
  - `vx155-green` 11/1.
  - `vx139-green` 18/4: 7 OpenNotes plus 11 TakeCardDoor. Its `-only-testing:…/WorkspaceNavigationTests` entry matches no suite type and ran nothing, but the counts claimed do not rely on it.
  - `vx139-settings-rerun` 31/4.
  - `vx143-pro-full` 4,251/699 failed exactly the five tests the record names: the three pre-edit P-VX139-vi shape pins, VX-115, and the environmental `LobbyAutoAsk` precondition.
- **The strip's mutation surface is closed.** `openNotes` is `private(set)`, and all five mutation sites (`visit`, `closeNote`, `notesDeleted`, `moveOpenNotes`, the restore) persist through the one helper. No other file writes the strip.
- **P1 holds:** one PK-indexed `IN` read over the stored ids, and at most 20 ids written per change. Nothing scales with the corpus.
- **Ids only, never titles:** local `UserDefaults`, never the synced `setting` table (the `postMode.<id>` keys already store note ids locally). S1–S5 untouched, nothing new on the wire.
- **Liveness is tombstone-only:** Trash rows drop and archived rows return (PROVISIONAL (v)). Ids from a previously adopted library fall out by the same filter.
- **Only the main shell asks:** `RootView` is constructed only at `VariorumApp.swift:163`, so note-only and quick-note windows never claim.
- **Settings consistency:**
  - Catalog row, rendered registry and pane render agree.
  - The `@AppStorage` default `true` matches `isOn`'s "nil ⇒ ON".
  - The copy is sentence case, and its "Open section" matches `WorkspaceNaming.openSectionHeader` ("Open").
  - "tabs" is in the keywords, her word.
- **The consequential pin edits are honest.** The appearance row is still second on General (`AppSettingsView.swift:446–481`). Row 59's fold cause (controls ABOVE appearance) is untouched by a section placed below the palette. The 5→6 caps are annotated in place and carried as P-VX139-vi.
- **The VX-139 pure-restore pins and the shim pins exercise what they claim** (order kept, dead dropped, dupes collapsed, torn recency reconciled, off-switch forgets). So does the model pin that reads a real in-memory store with a trashed row.
