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
