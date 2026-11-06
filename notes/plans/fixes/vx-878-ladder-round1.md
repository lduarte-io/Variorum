# VX-878 — ladder round 1 (cold review, fable-reviewer, 2026-11-06)

**Reviewed:** `git diff origin/main...HEAD` at head **4b1b10847** (branch `vx-878-book-doors-faces`),
against the run record `notes/plans/fixes/vx-878-book-doors-faces.md`, CLAUDE.md + the auto-loaded canon,
`notes/SurfaceContracts.md` in full, `notes/MCPSpec.md` in full. Every changed file under `Sources/`,
`App/` and `VariorumMobile/` was read in this session; the test diffs read or skimmed by suite with the
load-bearing pin bodies read (the VX-868 arms pin, the dangling-wing guard pin, the plan pin, the
derivation pin, the rename-repaint mount pin, the trail-dial round-trip pin, the two-store arms).
Verified by run on the head (headless, no stage): `BookNameGuardPerWingTests | BookNameGuardTests |
PrivateMarkFactsTests | MCPGrantOperationsTests` → **39 tests in 5 suites passed**;
`MCPTrailDialFingerprintTests | MCPBookNamePerWingServerTests | MCPTwoStoreCatalogServerTests` (alone)
→ **6 tests in 3 suites passed**. Pin-before-fix ordering verified in history for all four bug-class
members (3263e5877→7656bc887 · 4a41141b3→747db1385 · 470615279→f34c3b45d · 7f9e7855a→f02fcf48b).

No BLOCKER. No MAJOR. Findings below, severity-ranked.

---

## Findings

### F1 · MINOR · the Move to Wing destinations read the STORED wing, not the effective wing
`App/Variorum/Variorum/Features/Shelf/ShelfView.swift:776` ·
`App/Variorum/Variorum/Core/Views/BookRowMenu.swift:565` and `:664` ·
`App/Variorum/Variorum/Features/BookView/BookSettingsSheet.swift:871` (and, same class,
`BookNoteTitleMenu.swift:245`'s `fromWing`).

- **What.** Every new Move to Wing ▸ face computes its destination list as
  `wings.destinations(from: reading.wingId)` — the stored id. `WingsModel.destinations(from:)`
  (`Core/Views/WingsModel.swift:112`) is `rows.filter { $0.id != wingID }` over the LIVE wings, so a
  reading whose `wing_id` names a DEAD wing (R-13ia-2's dangling case — reachable by the sync race
  `BookNameGuardPerWingTests.aBookWhoseWingDiedCountsAsHomes` itself constructs) filters nothing out:
  **Home is offered as a destination for a book every surface already reads as Home's**, and the list
  is one row longer than the truth. On the Bookcase this is a small regression: the old board passed
  `model.wingID` (the board's own wing — the effective one, since the board lists by `wingScope`), so a
  dangling-wing book on Home's board correctly excluded Home. The elsewhere faces and the Book Settings
  wing row are new and inherit the same skew.
- **Evidence (mechanism).** reading.wing_id = ‹dead id› → surfaces list it under Home (`wingScope`)
  → `destinations(from: ‹dead id›)` returns every live wing **including ""** → the menu offers
  "Home"; a pick runs `bookMoveAsk(reading:, to: "")` — a counting confirm for a move to where the
  book already effectively lives.
- **Pin.** A unit test: mint a book, tombstone its wing by SQL (the guard pin's own fixture shape),
  build the menu facts / `BookSettingsSheet.wingDestinations` — assert Home is NOT offered (red on this
  head, green after the fix). Note the GUARD half of the doors is NOT wrong: `DuplicateBookDoor`,
  `BookFilterDoor.save` and `BookRowActs.spawnBook` check `source.wingId`, and `duplicateReading` /
  `saveFilterAsGathering` land the copy in exactly that stored wing — guard and landing agree.
- **Fix shape.** Resolve the FROM wing to its effective value at the door (the already-built
  `Queries.effectiveWing(_:ofReading:)`, or normalize inside `WingsModel.destinations(from:)`: an id
  naming no live row reads as "" — one change that heals all four faces at once).

### F2 · MINOR · `NoteRename` stays under `Features/Library/` at the touch that gave it a second feature
`App/Variorum/Variorum/Features/Library/NoteRename.swift:48` (the hoisted `rename` body; the file also
carries the shared `noteRenameAlert` modifier both features now render).

- **What.** VX-802 hoisted the one rename body into `NoteRename.rename` and made BookView (via
  `BookNoteTitleDoors` and `.bookNoteTitleAsks`) its second consumer — CLAUDE.md's architecture rule:
  "A view consumed by two features moves to the shared home (`Core/Views/` Mac-only) at the next
  touch." This run IS the next touch, and it left the file in `Features/Library/`. (This also answers
  the orchestrator's held batch-1 observation: the shape is legal — a helper enum plus a view modifier,
  not a sibling's view model — but the HOME is wrong by the rule's letter now that two features render
  the alert.)
- **Evidence.** The rule's text + the diff: `LibraryViewModel.rename` delegates to it;
  `BookNoteTitleDoors.rename` calls it; `noteRenameAlert` is rendered by SidebarView, the Library and
  now the book host.
- **Fix shape.** Move `NoteRename.swift` to `Core/Views/` (mechanical; no behavior change; no pin —
  architectural-clarity class, justification above).

### F3 · NIT · `MCPNoteIndicator` now always emits a layout node where it used to vanish
`App/Variorum/Variorum/Core/Views/MCPNoteIndicator.swift:92–150`.

- **What.** The old body was `if road?.indicatorOn == true { HStack(…) }` — with the server off or no
  client approved the view produced NO layout node, so `ContextBar`'s trailing cluster
  (`Workspace/PaneHost.swift:107`) paid no spacing for it. The new body always produces the
  `HStack(spacing: 4)` (possibly with zero children) so the mark can draw under R-878-K3's
  approved-client gate with the server off. A zero-size child is still a subview: the bar's own stack
  spacing is now paid around an empty node in the calm state (server off / nothing to say) — a few
  points of extra air at the bar's trailing end.
- **Evidence.** SwiftUI layout semantics (an empty conditional contributes no subview; an empty stack
  contributes one of zero size) + the diff's structural change. Visual-only; the indicator capture
  suites re-run at the closing window and will show whether it reads.
- **Fix shape (if wanted).** Wrap the body in one emptiness check (`if indicatorOn || mark != nil`),
  keeping the held read as it is. Honest severity: cosmetic, possibly invisible at spacing 4.

### F4 · NIT · cross-feature statics concentrated in the shared brain (recorded, no action demanded)
`App/Variorum/Variorum/Core/Views/BookRowMenu.swift` (BookRowDoors holds a `ReadingsViewModel`) ·
`App/Variorum/Variorum/Features/Readings/BookRowActs.swift` (calls `ShelfViewModel.spawnPrefill`).

- **What.** The one brain constructs and holds a `ReadingsViewModel` (for `ManageReadingPostsSheet` and
  the rename's E13 guard) and `BookRowActs.spawnBook` reaches a static on `ShelfViewModel`
  (`spawnPrefill`). Both are relocations of pre-existing shapes (ShelfView held the same VM; the spawn
  body lived on the shelf model) and the one-body rule is well served — but `spawnPrefill` is a pure
  read helper that no longer has any reason to live on the Shelf's view model; at a later touch it
  wants a Queries/shared home. Clarity note only; the prohibition's letter ("a feature never holds a
  sibling's view model") binds features, and `Core/Views` is the shared home.

### Process notes (not findings against the diff)

- **P-a.** Batch 3's NOT-DONE item (5) — Settings ▸ Tags' Make a Gathering mints in Home whatever wing
  the pane shows — is recorded "for the orchestrator to ticket". Confirm the ticket exists before
  closeout; VX-816's guard deliberately matches the buggy mint (honest), so the ticket is the only
  trace that will survive.
- **P-b.** The canon deltas exist as DRAFTS in the record (correct — not applied). At closeout the
  MCPSpec VX-259/VX-363 lines MUST land, since the spec's current sentence ("her own doors keep the
  full guard") is falsified by the shipped per-wing scope until the draft lands.
- **P-c.** The App-target pins are compiled, not run — the record says so honestly everywhere. The
  closing window's runs (notably `BookRenameRepaintTests` on 4a41141b3 red / head green, and
  `MCPGonePlaceNamesTests` + `BookNamePerWingDoorTests` on their pin trees) remain the run's
  use-shaped evidence; nothing in this round substitutes for them.

---

## Clean bill (checked and found solid)

1. **The per-wing name guard (VX-816).** One predicate (`requireBookNameFree(_:_:inWing:excluding:counting:)`),
   `wingScope`'d exactly as surfaces read wings (dangling ⇒ Home — pinned and RUN red-on-old on the
   pre-fix tree); the mint form forces every create door to name its wing at compile time; the rename
   form reads the book's own effective wing; every citer surveyed in the record is present in the diff
   (her doors, both renames, import, duplicate, filter-save, spawn, membership mint, PromoteTags-as-Home,
   the phone's four, the wire's four); VX-259's reach filter composes unchanged (readable AND in-wing,
   two-store arms added and green); `rename_book`'s description updated under VX-197's truth rule;
   `move_book_to_wing`'s `same_name_in_wing` verified already per-wing. Archived-skip and excluding
   semantics pinned unchanged.
2. **The Private mark (VX-831 + R-878-K3).** The facts are the fence's Private leg split in two, pinned
   byte-equal to `privateLegForNote` (I read both SQL fragments side by side — live member, live
   reading, archived-Private still counts, gathering never via `kind='book'` on the book arm); the
   drawn reads gate on ≥1 approved client (the shared icon's exact gate, `mcpClients(states:[.approved])`,
   the same read `mcpReachStandings` opens with), with the plan pin proving seeks never scans
   (`EXPLAIN QUERY PLAN`, non-vacuous) and the no-client pin proving nothing past the grants store is
   read; every host holds ∝ its drawn ids (Library near-window slices, Timeline reach window, Pool
   drawnIDs, Bookcase bookIDs, Book Panel entryIDs, the masthead's one note); the menu's Private row
   keeps VX-641 ungated so the un-private road survives; `ai_private_at`'s writers unchanged (her two
   ops only — grepped; nothing under `Sources/VariorumMCP/` writes it); the via-book click acts on
   nothing and speaks an OFFER with one door riding `MembershipChip.ascend`; the own arm runs the
   existing ops with the rows' receipts plus the honest stays-private arm.
3. **VX-804.** The mechanism as recorded is real (I read the retired one-shot in `BookViewModel.start()`
   and its own confession comment on origin/main via the diff); the fix is one derivation over the
   structure model's held row, the never-passed `readingName:` override deleted, three faces re-pointed;
   the mount pin drives Book Settings' own road, asserts not-a-lost-write, and starts the models by
   hand with a window — a genuine red-on-old shape (its RUN is the window's, honestly recorded).
4. **VX-858.** The one brain (`MCPTrail.placeTitle`) now feeds both the trail rows and
   `landReceipt`'s `ShownChange`; the only readers of `ShownChange.title` are the gone/unfinished
   words (grepped), so every receipt whose landing IS its target stays byte-identical; the
   `.bookRemove`/`.bookRelease` arms join `.bookAdd`'s shape; the coalescing key untouched; nil titles
   fall to the place-noun arm of `MCPShowOfferCopy.place` (read). The seven-act class table matches the
   code.
5. **VX-874.** The dial is one local-only `mcp_switch` key, absent/unknown ⇒ everything-on, no-op
   guarded (pin read and run green); excluded from `grantsFingerprint` beside `show_dial` (so no
   `tools/list_changed` and no change to the lock's identity belt a client can't already cause —
   VX-676's exact precedent, revert-shown per the record); the trail keeps recording under every value;
   fully-off collapses the section AND its separator (`footerRows == 0` read in SidebarView); the ask's
   bottom-bar offer road untouched and pinned. The float is pure
   (`groups(showing:)` — asks first in their group, ask-holding groups first by newest ask, P-874-1
   recorded); dismiss removes the row only; the drag acts only within a client × kind stratum with the
   false-offer rule honored on both halves of every boundary (I walked `reordered`'s edge cases:
   own-slot, adjacent-slot and cross-stratum drops all answer nil consistently on both halves);
   `move` permutes the stratum in place with positions kept; the drop door double-guards on the
   section's own listID; the drag token is declared in Info.plist and pinned in
   `DragTypeDeclarationTests`. Registry: three new acts declared once, the walk's union lines edited
   with justification, `surfaceCapabilities` (the guide's pinned pair) unchanged.
6. **VX-829/VX-802 (the doors).** One table, two faces, the elsewhere face DERIVED (shelf-placement
   removed, Open leading) and pinned both as the derivation and as concrete door lists; N-1 (the daily
   Journal's Delete beside Archive) pinned on both faces; one renderer (`BookRowMenuItems`), one brain
   (`BookRowDoors`) with `landed()` re-reading ∝ the listed rows (P1) so the next right-click is true
   (Finish ⇒ Reopen); act bodies never forked (`BookRowActs.bind`/`spawnBook`, one body, two speakers;
   `ReadingsViewModel.run` resets `lastError` on success so the brain's refusal read is safe — checked);
   `BookExtentSheet` moved to the shared home with a closure save; the four undeclared doors declared
   at their second renderer with the board's words; `.moveBookToWing` gains `.surface` for the sheet's
   wing row, rendered behind `WingBookMoveDoor.drawn` (P-2). The note-title menu is table-driven, its
   doors a pinned subset of the note-row grammar, the ruled left-offs pinned never-drawn, the acts all
   shared roads (one rename body, one delete confirm via `NoteDeletion.fire`, `WingNoteDoors`,
   `NoteExport`, `archiveContainer` with the one receipt), asks hosted on the book, roads handed from
   RootView by composition (P-4: no broadcasts anywhere in the diff).
7. **VX-868.** Both arms rewritten, the pin asserts both exact sentences, the old shape gone, the zero
   arm unchanged; red-on-old by construction (pin committed alone on the pre-fix tree).
8. **VX-887.** One `Layout`, never `ViewThatFits`; the class decided at whole points from stable widths
   (tabs at widest-active, dial at widest of `everyName` — which the wire's `set_book_order` makes
   reachable, D-887-3's renames pinned); the both-passes edge (a room narrower than the tab line) fixed
   in the rule before any run; on one line the dial is offered ≥ its widest form so it never truncates
   there; the tabs keep `Button { switchMode(to: mode) }` (vx-808's constraint 1) and the stepper call
   is untouched by the diff (constraint 2); the doubled word gone; R-878-K4 closes D-887-4 as built.
9. **Fences.** Nothing under `Sources/VariorumCore/Sync/`, `Protection/`, custody/keychain, or the
   editor seam; no migration, no dependency; the only `Sources/VariorumMCP/` edits are the two the
   record pre-announced (the fingerprint exclusion and the `rename_book` description), both read and
   sound; the mobile edits are call-shape only (Home named).
10. **P1/P2/P3 sweep.** No new cost ∝ corpus anywhere in the diff: every new read is id-driven
    (json_each seeks, plan-pinned) or ∝ listed rows; the trail is memory with cap 50; the stable-width
    measure is memoized constant work; no copies of persisted text entered any view model (the one
    retired — `BookViewModel.readingName` — was exactly that, removed).

**Mandatory foci:** the phase plan carries no "Review foci" section; the orchestrator's one held
observation (NoteRename's layer placement) is answered as F2.

---

## ORCHESTRATOR DISPOSITIONS (round 1 — before the fix session; the cross-model flow: findings go to the implementer VERBATIM, its agree/dispute returns to the reviewer for the final call, the implementer applies the confirmed fixes)

- **F1 (MINOR, the dangling-wing destination): BUILD** — with the reviewer's named pin (dead-wing fixture → Home not offered; expected RED on this head), revert-verified; prefer the one-heal shape (normalize inside `destinations(from:)`) unless the survey argues otherwise.
- **F2 (MINOR, NoteRename's home): BUILD** — the mechanical move to `Core/Views/`, the shared-home-at-next-touch rule; no pin owed (clarity class), existing pins expected to pass unmodified (the 3C parity bar).
- **F3 (NIT, the empty HStack slot): BUILD** — the reviewer's one-line emptiness check; cheap, and the calm state's chrome should not pay an air slot.
- **F4 (NIT, spawnPrefill's later home): RECORD-ONLY** — as the reviewer scoped it ("no action demanded"); noted for a later touch.
- **P-a: ALREADY DONE** — the ticket is **VX-889** (filed 2026-11-06, Bug · Confirmed · Settings & onboarding · Medium), minted before this round.
- **P-b: ON THE CLOSEOUT PLAN** — the canon drafts (batches 3–4's CANON DRAFT sections) land at closeout in the two-file shape; the reviewer's falsified-until-then observation is exactly why they are staged.
- **P-c: ACKNOWLEDGED** — the closing window's runs are the evidence of record; the record says so honestly throughout.

---

## FIX SESSION — agree/dispute (opus-implementer, the round-1 fix session, 2026-11-06; head a4ca7d253)

**Summary: F1 AGREE · F2 AGREE · F3 — mechanism AGREE (measured), fix shape DISPUTE (measured). Per the cross-model flow the session STOPS here; nothing is built until the reviewer's final call on F3.**

### F1 — AGREE (mechanism and fix shape)

- **Mechanism, re-traced on the head.** `WingsModel.destinations(from:)` (`Core/Views/WingsModel.swift:112`) is `rows.filter { $0.id != wingID }`, `rows` = Home + the LIVE wings (`Queries.wings`, `deleted_at IS NULL`). A reading whose stored `wing_id` names a dead wing filters nothing, so `""` (Home) stays in the list — while every surface lists that book under Home (`Queries.wingScope`'s Home arm: `column = '' OR column NOT IN (live wing ids)`) and `Queries.effectiveWing(_:ofReading:)` reads it as `""`. Confirmed the Bookcase regression the finding names: `origin/main`'s board read `wings.destinations(from: model.wingID)` (ShelfView.swift:874 there), the board's own — effective — wing; the head's ShelfView.swift:776, BookRowMenu.swift:565/:664 and BookSettingsSheet.swift:871 read `reading.wingId`; BookNoteTitleMenu.swift:245 hands `structure.reading?.wingId` into `WingNoteDoors` (→ WingsModel.swift:468). Beyond the finding's list, the same stored-id read sits in `WingDestinationModel.open`'s `.moveBook` arm (WingDestinationSheet.swift:310) and its init (:213) — the ⌘K selector — healed by the same one change.
- **The shape the code argues for: normalize inside `destinations(from:)`** (the reviewer's second option). Why: (1) the model ALREADY applies R-13ia-2 to its own ids — `name(of:)` (WingsModel.swift:101) answers Home for an id naming no live wing — so `destinations` disagreeing with `name` is an inconsistency inside one model (⌘K's foot would say "in Home" above a list offering Home); (2) every caller is a synchronous menu/sheet builder over a held projection — `Queries.effectiveWing` is an async DB read and would need held state at four-plus sites; (3) one change heals every face, the ⌘K selector included, and is a no-op for ids that are already effective (`""` or a live wing — every `context.wingID` from `NoteMenuWingContext`, the session's revalidated `currentID`). Planned body: an id is effective iff it is `""` or names a row of the held `wings`, else `""`; filter on that. Recorded edge: a wing minted on THIS device is loaded before anything can live in it (`mint` awaits `load()` before `switchTo`), and a remote mint lands in the held `track()` observation on the same commit, so the projection never lags a live wing a surface can show; were it ever to, `name(of:)` already calls that id Home today.
- **The pin (as briefed):** App-target — `WingsModel` lives in the app — so it is committed on the pre-fix head first, compiled there (`build-for-testing`), its red evaluated by the mechanism above; its RUN on both trees joins the closing window's debt. Fixture: the guard pin's own shape (mint a wing, a book in it, tombstone the wing by SQL), then `wings.load()`; assert `destinations(from: reading.wingId)` excludes `""` and `BookSettingsSheet.wingDestinations(for:wings:)` offers no Home (with a second live wing present so the door is drawn and the list is non-empty — the arm that distinguishes "Home wrongly offered" from "no door").

### F2 — AGREE

- The rule's letter binds (two features render `noteRenameAlert` — the Library/sidebar and BookView's `.bookNoteTitleAsks` — and both call `NoteRename.rename`/`storedTitle`); this run is the next touch.
- **Planned: a pure `git mv` to `Core/Views/NoteRename.swift`** (+ the header comment's home line). Surveyed: the Xcode project uses file-system-synchronized groups with no membership exceptions (no pbxproj edit); no test reads `NoteRename.swift` by path (the source-reading pins read `SidebarView.swift` / `LibraryCatalogView.swift`, which do not move); the directory-walking pins (`ChromeMenuRowSizeTests`, `DuplicateDoorsTests`, `GlyphRainTests`, `MCPAsksWaitTests`, `OneRefreshAuthorityTests`) carry no path allowlist naming it; same module, so no import changes. Parity proof at the fix: `git diff --stat` touching zero test files.

### F3 — mechanism AGREE (measured); fix shape DISPUTE (measured)

- **Mechanism — AGREE, and measured.** A throwaway probe (an `NSHostingView` in an off-screen borderless window, `fittingSize` read; not committed) in ContextBar's exact shape — `HStack(spacing: 1) { Text; Spacer(minLength: 0); AnyView(trailing) }` — gives ideal widths **30.0 pt** (no trailing) · **31.0 pt** (an always-present empty `HStack`, today's indicator body) · **30.0 pt** (a vanishing `if`). So the calm state pays exactly the bar's 1 pt of spacing, and it sits AFTER a `Spacer(minLength: 0)`: nothing before it moves; the point is visible only when the bar is compressed to its ideal width.
- **Fix shape — DISPUTE: the one-line emptiness check strands the held read, and with it R-878-K3's server-off mark.** The condition's second arm, `mark`, is the OUTPUT of the read the `.task(id: WatchKey…)` holds (`state?.mark` → `PrivateMarkFace.note`). Wrapping the body in `if indicatorOn || mark != nil` leaves that `.task` riding a node that is absent in exactly the state that must learn the mark, and a `.task` on absent content never starts — measured in the same probe: `.task` on `Group { if false { … } }` — did NOT run; on a bare `@ViewBuilder` `if` — did NOT run; on `.background { Color.clear.task {…} }` of an empty conditional — did NOT run; on an always-present empty `HStack` — RAN (a `Text(...).task` control ran, so the harness fires tasks). Consequence: with the server OFF and a client approved, `indicatorOn` is false and `state` starts nil ⇒ the body draws nothing ⇒ the read never starts ⇒ `mark` stays nil forever ⇒ **the Private mark never draws on the note's masthead with the server off** — R-878-K3's ruled gate is "while a client is approved" (the server on or off; the reason the body became an always-present stack in batch 2). And with the server on, the stack vanishing (server turned off on an unmarked note) cancels the read, so a later mark made while the server stays off is never learned.
- **The slot IS the read's carrier.** Every carrier that pays no slot also hosts no task (above); keeping the read live needs a node somewhere. Options for the reviewer's final call:
  - **(a) RECORD-ONLY — recommended.** The 1 pt is the honest cost of R-878-K3's server-off mark staying live, after a flexible spacer; optionally one comment line at the `HStack` saying the stack is always present because it carries the held read (so a later reader does not "fix" it the stranding way) — the comment only at the reviewer's word.
  - **(b) Hoist the held read into the parent** — `PaneHost` owns the `@State` and the `.task(id:)` (it already reads the window's road), hands `MCPNoteIndicator` its state, and the indicator becomes a pure conditional that vanishes when calm. Correct, but structural: a second file (`Workspace/PaneHost.swift`), the indicator's API and its `WatchKey` move — not a one-liner, for an invisible point.
  - **(c) ContextBar carries the trailing view's read on its own `HStack` (`.background`)** — equally structural, and it teaches the generic bar about one trailing occupant.
- If the reviewer rules (b) or (c), it is built with a pin on the server-off arm (a mount: no server, one approved client, an own-Private note ⇒ the mark is drawn, AND the calm state contributes no node) — that pin would be red on the literal one-liner, which is the point of raising this before building.

## REVIEWER'S FINAL CALLS (fable-reviewer, round 1 — the cross-model flow's final word, 2026-11-06)

### F3 — FINAL CALL: option (a), RECORD-ONLY, with the one comment line. No pin owed.

- **The dispute is CONFIRMED, against my own proposed fix shape.** Re-read on the head: the
  `.task(id: WatchKey(postID:includingReach:))` rides the indicator's `HStack`
  (`MCPNoteIndicator.swift:142–149`), and the condition I proposed (`indicatorOn || mark != nil`)
  has the read's own OUTPUT as its second arm — with the server off and a client approved,
  `indicatorOn` is false and `state` starts nil, so the conditional removes the node, the task never
  starts, `mark` never arrives, and the view can never earn its way back: a bootstrap deadlock that
  silently reverses R-878-K3's server-off mark. The implementer's probe matrix (bare `if`, Group-if,
  background-of-conditional all strand the task; the always-present stack runs it, with a running
  `Text(...).task` control) matches SwiftUI's semantics as I know them and the code as I read it.
  The mid-session arm is real too: a vanishing node cancels the held read, so a mark made while the
  server stays off would never be learned.
- **The finding's visual premise is largely falsified by the measurement:** 1 pt of ideal width after
  a `Spacer(minLength: 0)` — visible only at the bar's compression floor, moving nothing before it.
  A NIT whose cost is one invisible point does not buy a structural hoist: options (b) and (c) are
  correct but move the read's ownership across a file seam to save that point — rejected.
- **The ruled shape (the implementer applies it with F1/F2 — not FINDER-FIXES):** keep the body as
  built; add ONE comment line at the `HStack` stating that the stack is always present because it
  carries the held read (`.task`), and that a conditional here strands the mark's server-off read
  (R-878-K3) — so the stranding "fix" this round itself proposed is never written by a later session.
  No pin: nothing behavioral changes under this call. (Had (b)/(c) been ruled, the implementer's
  proposed server-off mount pin would have been owed — recorded for any future reshaping of this seam.)
- F3's severity falls from NIT to RECORD-ONLY; the next round's reviewer checks only that the comment
  line landed.

### F1 — shape CONFIRMED as the implementer re-traced it (of the two I offered, the second):
normalize inside `WingsModel.destinations(from:)` — an id is effective iff it is `""` or names a row
of the held `wings`, else `""` — healing all four faces AND the ⌘K selector sites the fix session
found beyond my list (`WingDestinationSheet.swift:310`/`:213`), and restoring consistency with the
model's own `name(of:)`. The App-target pin as they briefed it (committed on the pre-fix head,
compiled there, RUN at the closing window), with the second-live-wing arm that distinguishes "Home
wrongly offered" from "no door drawn". APPROVED to build.

### F2 — shape CONFIRMED: the pure `git mv` to `Core/Views/NoteRename.swift` plus the header's home
line; the survey (no pbxproj membership exceptions, no path-reading pin names the file, same module)
is accepted; the zero-test-files `git diff --stat` parity proof at the fix commit. APPROVED to build.
