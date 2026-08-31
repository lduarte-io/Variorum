# Cold review — `16ba929` ("The Block History twin lands on the phone")

**Reviewer:** cold session, zero implementation context, `notes/REVIEW_PROMPT.md` run verbatim.
**Diff:** `git diff 16ba929^..16ba929` — 20 files, +2030 / −706. Parent is `e495ce8`.
*[removed for publication]*
private DerivedData `…/scratchpad/dd-6a`. Every number below marked MEASURED was produced in this
session on that pair.

**Verdict up front: the change is sound.** The hoist really is an address move, the four regions are
built the way the record says, the fifteen new pins are real and green, and the hygiene rails hold
(zero `Sources/`, zero `Sync/`, no project/config files, marker 7). Nothing here touches an invariant
or the store. The findings below are all in the phone's **pixels** — a face whose thesis is honest
copy has two places where it silently stops telling the truth on screen — plus one record-accuracy
note about a build the tree could not have made.

**Counts: 0 BLOCKER · 2 MAJOR · 4 MINOR · 3 NIT.**

---

## MAJOR

> **✔ FIXED 2026-08-30**, both halves — the line cap resets on every
> `configure` (the recycling rule the file's own header states) and section
> headers are MEASURED rather than pitched at 52pt. This review's measurements
> were independently reproduced within a percent (41.17 / 54.89 against 41.3 /
> 55.0), and each half was proven red SEPARATELY, confirming "jointly wrong".
> **`m3` below is still open** and was deliberately not fixed with it.
> Record: `notes/plans/mobile-major-fix-round-record.md` (C1).

### M1 · `MobileBlockHistorySheetView.swift:324, 354–359` (+ `MobileBlockHistory.swift:286`) · Both long section explainers are silently truncated, and the came-from one loses the half that explains the button beside it · **MEASURED**

`MobileBlockHistoryCell` sets `metaLabel.numberOfLines = 2` once in `init` (line 324) and never
changes it. The `.sectionHeader` case (354) puts the region's *explainer* in that label, and
`Row.height` pins a section header at a fixed **52pt** (`MobileBlockHistory.swift:286`).

Measured on the assigned simulator, at the **default** content size category and the real sheet
geometry (sheet = view width; `table.frame` inset 8 each side; cell text width = `width − 24` with no
act button ⇒ 362pt at 402pt device width; font `monospacedSystemFont(14).withSize(11.5)`, text
lowercased by `chromeCase` for the terminal voice):

| explainer | needs | gets (2 lines) | outcome |
|---|---|---|---|
| `BlockHistoryPath.explainer` (Savepoints) | 41.3pt / 3 lines | 27.7pt | **truncated** |
| `OriginPeekCopy.explainer` (Came from) | 55.0pt / 4 lines | 27.7pt | **truncated** |
| `BlockHistoryCopy.archivedExplainer` | 14.0pt | 14.0pt | fits |
| `MobileBlockHistoryController.deletedExplainer` | 14.0pt | 14.0pt | fits |

What is lost is not decoration. The Savepoints explainer is the sentence the shared file calls *"what
the whole face says about itself, once, at the top"* and its dropped tail is `…and the block it came
out of` — the clause naming the fourth region. The Came-from explainer is the one whose own doc says
*"Saying so is the whole point of the surface"*; its dropped tail is `…and Put back returns it to the
note beside the blocks it became`, i.e. the sentence explaining the **Bring back** button rendered
inches away. A user at default text size reads two sentences that stop mid-thought.

Note the two constraints are jointly wrong, so fixing one is not enough: even at `numberOfLines = 0`
the content is 15.0 + 2 + 41.3 = 58.3pt (Savepoints) and 72.0pt (Came from) against the 52pt row.

**Proposed fix:** `metaLabel.numberOfLines = 0` reset at the top of `configure`, and let the table
measure section-header rows (`rowHeight = UITableView.automaticDimension` + `estimatedRowHeight`, or
a per-row measured height). **Red-on-old pin:** configure a `.sectionHeader` cell with
`OriginPeekCopy.explainer` at 362pt and assert `metaLabel.sizeThatFits(...).height` equals the
unbounded height, and that `metaLabel.frame.maxY <= contentView.bounds.height`.

---

> **✔ FIXED 2026-08-30.** The quiet sentence is now reserved for the case
> where it is TRUE (`history.isEmpty && activeTakes.count <= 1`); above one
> take the regions draw exactly as the Mac's do. **One deliberate stop short
> of literal Mac convergence is recorded for the author** — the ordinary
> one-take block keeps its calm one-line answer rather than a header plus a
> "this take · 0" row, because I10 makes the Mac's branch unreachable there
> and the sentence is true. One line and one pin if she wants it gone.
> Record: `notes/plans/mobile-major-fix-round-record.md` (C2).

### M2 · `MobileBlockHistory.swift:298–302` · On a fanned block with no savepoints the face says *"This block has no past yet: one take…"* and hides every take section · **MEASURED (the core value) + traced (the branch)**

```swift
func rows() -> [Row] {
    guard loaded else { return [] }
    if history.isEmpty { return [.quiet(BlockHistoryPath.nothingHere)] }
```

`Queries.BlockHistory.isEmpty` (`Sources/VariorumCore/Queries/EditorSupport.swift:252–256`) is
`takes.allSatisfy { savepoints[$0.id]?.isEmpty ?? true } && archivedTakes.isEmpty &&
deletedTakes.isEmpty && origins.isEmpty` — it says nothing about how many takes there are. Measured
against the real core (a scratch executable linking `VariorumCore`, outside the repo):

```
two-take block, no savepoints          -> activeTakes = 2  | isEmpty = true
two-take block, savepoints key absent  -> isEmpty = true
ten-take block, no savepoints          -> activeTakes = 10 | isEmpty = true
```

So for **any block she has fanned but not yet committed** — the everyday state after `branchVariant`
— the phone's whole Block History face is one line:

> This block has no past yet: **one take**, no saved moments, nothing set aside, and nothing it came
> out of.

Two things are wrong. (a) The sentence is **false**: the block has two, or ten. (b) Her ruled design
for region 1 — *"ALL live takes, sectioned, the take you're in expanded"*, which this batch's own
header comment and its `everyLiveTakesRunIsSectionedAndTheFocusedOneOpensExpanded` pin both state —
is not honoured in exactly this state; no take section is drawn at all.

**This is a divergence from the Mac, not a shared rule.** `BlockHistoryPane.swift:475` guards the
same sentence on `model.history.activeTakes.isEmpty`, then draws the take sections unconditionally —
so on the Mac a two-take, no-savepoint block correctly shows two take headers each reading *"No saved
moments yet — ⌘S saves one."*, and `nothingHere` is a defensive branch I10 makes practically
unreachable. The phone is the first surface that actually renders that sentence, and the `one take`
clause it was written with was never load-bearing before.

The existing pin `anOrdinaryBlockHasNoPastAndTheCopySaysWhat` seeds a **one-take** block, so it
passes over the hole.

**Proposed fix:** mirror the Mac — draw the savepoints region and its take headers whenever
`activeTakes` is non-empty, and reserve `nothingHere` for the one-take case (or reword it so it does
not assert a count). **Red-on-old pin:** seed a block, `branchVariant` it, commit nothing, open the
face, assert two `.takeHeader` rows.

---

## MINOR

### m3 · `MobileBlockHistorySheetView.swift:361–370` · A recycled cell keeps the take-header's right-aligned meta line, and the file's own comment says it cannot · **READ-ONLY**

`configure`'s header comment reads *"Recycled by the table, so `configure` sets every field each time
(a half-configured recycled cell is the classic table defect)."* Two fields are not:

- **`metaLabel.textAlignment`** is set to `.right` at line 370, only in `.takeHeader`, and never reset.
- **`titleLabel.numberOfLines`** is set per case at 365/376/384/408/420/432 but **not** in
  `.sectionHeader` (354) or `.quiet` (399).

There is ONE reuse identifier (`MobileBlockHistoryCell.reuseID`), so a take-header cell is reused for
whatever row scrolls in next. Mechanism, concretely: a face with several takes and a real savepoint
run; scroll so a `.takeHeader` cell leaves the viewport; the table dequeues it for a `.savepoint` row;
`configure` sets that row's meta text and colour but not its alignment, so the savepoint's
`"30 aug 2026 at 4:43 pm · quiet"` renders flush right, jammed against the Restore button, while its
neighbours read left. Same for a `.deletedTake`'s clock and an `.origin`'s lineage row.

The `numberOfLines` half is the smaller one (a `.quiet` line inheriting `1` from a savepoint cell —
`noSavepoints` fits one line at the measured width; `nothingHere` is only ever drawn as the sole row,
so it cannot be recycled into).

**Proposed fix:** reset `metaLabel.textAlignment = .natural` and `titleLabel.numberOfLines = 2` in the
unconditional block at the top of `configure`, beside the resets already there. **Red-on-old pin:**
configure one cell with a `.takeHeader` row, then re-configure the *same instance* with a `.savepoint`
row, and assert `metaLabel.textAlignment == .natural`.

### m4 · `MobileBlockHistory.swift:284–295` · Fixed row heights against a Dynamic-Type-scaled title font — and this is a NEW exposure, not inherited · **MEASURED**

`Row.height` returns constants. Four row kinds (`.savepoint`, `.archivedTake`, `.deletedTake`,
`.origin`) leave `titleLabel.font = face.body`, which is
`UIFontMetrics(.body).scaledFont(for: monospacedSystemFont(14))` — it scales. The meta line is
`face.chrome.withSize(11.5)`, which does not. Measured in the simulator:

| content size | title line | meta (2 lines) | total | vs `.deletedTake` 62pt | vs `.archivedTake` 56pt |
|---|---|---|---|---|---|
| L (default) | 17.0 | 27.7 | 46.7 | fits | fits |
| XXXL | 21.7 | 27.7 | 51.3 | fits | fits |
| AX-L | 30.0 | 27.7 | 59.7 | fits (2.3pt) | **over by 3.7** |
| AX-XXXL | 46.7 | 27.7 | 76.3 | **over by 14.3** | **over by 20.3** |

`layoutSubviews` clamps `top` to `max(…, 4)` rather than clipping, and I measured
`cell.clipsToBounds = false`, `contentView.clipsToBounds = false` — so the overflow draws over the
neighbouring rows rather than being cut.

Worth flagging as new rather than as prior art: the sheet this replaces
(`16ba929^:…/MobileBlockHistorySheetView.swift`) used a fixed `rowHeight = 64` but only fixed-size
chrome fonts (`face.chrome.withSize(12)`) in it, so its geometry was self-consistent. Introducing a
scaling font into fixed-height rows is this batch's change.

**Proposed fix:** `UITableView.automaticDimension` with an `estimatedRowHeight` (the same fix M1 wants),
or derive the constants from the current metrics. **Red-on-old pin:** configure a `.deletedTake` cell
under `UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)` and assert
`metaLabel.frame.maxY <= contentView.bounds.height`.

### m5 · `Shared/BlockHistoryFace.swift` · The new shared home carries three sentences nothing says, one of them duplicated verbatim inside the same file, and one that names a Mac door the file's own criterion says must stay Mac-local · **READ-ONLY (grep-verified across `App/`)**

The file's header sets a clear rule — a sentence naming *"a MAC DOOR or a MAC CHORD"* stays Mac-local,
and `BlockHistoryCopy.deletedExplainer` is kept back specifically *because it names This Note's Tray*.
Against that rule:

- `BlockHistoryPath.openTrayVerb` = `"Open this note's tray"` **is** in the shared home, and its one
  call site is a Mac `Button` (`BlockHistoryPane.swift:650`). Same surface, same sentence, opposite
  treatment to `deletedExplainer` eight lines away.
- `OriginPeekCopy.openTrayVerb` is the **byte-identical string a second time**, in the same file,
  with **zero** call sites — a shared home holding one sentence twice is precisely the drift class this
  batch exists to end.
- `OriginPeekCopy.originGone` and `BlockPastCopy.seeOriginVerb`: **zero** call sites. Both belonged to
  the J3 peek panel, which no longer exists. The file's comment claims *"these sentences outlived it,
  and now both platforms read them"* — for these three, neither platform reads them.

**Proposed fix:** delete the three unreferenced constants; keep one `openTrayVerb`; and either move it
beside `deletedExplainer` in the Mac extension or move `deletedExplainer` in, so the criterion is
applied once. Cleanliness class — no test pin owed beyond the existing copy pins.

### m6 · Record accuracy · This commit also repaired a Mac target that could not compile, and §70 stops one step short of saying so · **MEASURED (by grep over both trees)**

`notes/plans/mobile-round-2.md` §70's staging-incident section is honest and useful: `a232455` swept
four of this session's staged index entries — including the `OriginPeek.swift` deletion — into a
commit about something else. What it concludes is *"Nothing was lost … the moves simply live one
commit early, under the wrong sentence."* That is true about **content**, and it understates the
consequence:

At `16ba929^` (`e495ce8`), `OriginPeekCopy` has **eight non-test reference sites** in the Mac target
(`EditorViewModel.swift:1957,1991`, `TakesShared.swift:224`, `TakesViewModel.swift:1484`,
`BlockHistoryPane.swift:749,773`, `CapabilityRegistry.swift:677,683`) plus three test files — and
**no declaration anywhere in `App/`** (`git grep -E '(enum|struct|class) +OriginPeekCopy' e495ce8`
returns nothing). The declaration only reappears in **this** commit, in `Shared/BlockHistoryFace.swift`.
So the Mac target was un-buildable from `a232455` through `16ba929^`, and this diff is what fixes it.

Two consequences worth writing down. (1) The commit message's provenance line — *"arrived verbatim
from … `Features/Tray/OriginPeek.swift`"* — points at a file that did not exist at the parent, which
will confuse anyone tracing the hoist. (2) The load-bearing hoist proof *"The Mac suite rode
unmodified at 1843/312"* is still sound as a statement about the **post**-commit tree (no
`VariorumTests/` file is touched by this diff, and I verified the resurrected strings are
byte-identical to `a232455^:…/OriginPeek.swift`), but it cannot be read as a before/after comparison
for `OriginPeekCopy`, because there was no green "before".

**Proposed fix:** one sentence in §70 saying the sweep left the Mac target un-buildable and that batch
6a restored it, so a bisect through that window is not a mystery. No code change.

---

## NIT

### n7 · Three phone-side hard-coded `"Block History"` strings · **READ-ONLY**

`Shared/BlockHistoryFace.swift`'s `BlockHistoryPath.name` is documented as *"the ONE place … menu
labels on BOTH platforms promise this surface by name"*, but the phone spells it literally at
`MobileBlockMenu.swift:107` (`historyTitle = "Block History…"`), `MobileUndoDoor.swift:267`, and
`MobileTutorialSeeder.swift:344`. The commit message says the renamed undo pin *"reads the SHARED
name, so the pin and the door can never drift again"* — the pin cannot drift from the constant, but
the **door** can: renaming `BlockHistoryPath.name` reds the pin while leaving all three phone strings
saying the old name. Interpolating `BlockHistoryPath.name` closes it.

### n8 · `TrayPanel.swift` lost its trailing newline · **MEASURED** (`\ No newline at end of file` in the diff)

The hoist removed `TrayRowPreview` from the end of the file and left the replacement comment
unterminated. One character.

### n9 · `MobileBlockHistorySheetView.swift:213–239` · The pre-split alert arms its gate before presenting · **SPECULATIVE**

`presentedRestoreID = pending.commit.id` is assigned before `root.present(alert…)`, and the alert goes
to `window?.rootViewController` rather than the topmost presented controller. If presentation is ever
refused (something already presented on that controller), the gate is latched, `pendingRestore` stays
set, and Restore on a pre-split savepoint would do nothing visible until the face is closed. **I could
not trace a reachable trigger** — the sheet is a `UIView`, the block ⋯ is a `UIMenu`, and the page
editor is stood down — so this is shape, not a defect. Assigning after a successful present, and
walking to the topmost presented controller, costs two lines.

---

## Clean bill — what I specifically checked and found solid

- **Hygiene, verified not assumed.** `git diff --name-only 16ba929^..16ba929` contains no `Sources/`
  path, no `Sources/VariorumCore/Sync/` path, and no `pbxproj`/`xcconfig`/`entitlements`/`Info.plist`/
  `Package.swift`. `SyncSchema.lockstepVersion == 7`, untouched. No schema.
- **The hoist is genuinely an address move.** I diffed each moved body against its pre-move original,
  including `OriginPeekCopy` against `a232455^:…/OriginPeek.swift`: every string and rule is
  byte-identical. `BlockHistoryPath.noSavepoints` is the same sentence with `—`/`⌘` written as escapes.
  `BlockHistoryCopy.deletedExplainer` reconstituted through `deletedRegionExplainer(purgeRoad:)` yields
  the Mac's exact prior sentence. `DeletedTakeFace`'s `TrayPath.daysLeftLabel` → `RecoveryCopy
  .daysLeftLabel` swap is a forwarder to the same function (`TrayPanel.swift:138–139`). **No Mac test
  file is touched by this diff**, which is the 3C parity proof the record claims.
- **`RecoveryStatus` and `BlockHistoryExpansion` were hoisted behind forwarders** (`typealias Status =
  RecoveryStatus`; `BlockHistoryModel.initiallyExpanded` delegating), so every shipped Mac call site
  and pin rides unmodified — the right shape for this class of move.
- **The project needs no edit.** `Shared` is a `PBXFileSystemSynchronizedRootGroup` listed in the
  `fileSystemSynchronizedGroups` of both the `Variorum` and `VariorumMobile` targets, so the new file
  is picked up by both automatically.
- **The pins are real and green, measured here.** `MobileBlockHistoryTests` 15/15 passed; the LR2-4
  Trash pin (`aSavedVersionsDoorsAnnounceThemselvesAsSavedVersions`) and the renamed
  `undoWarnsBeforeDiscardingWritingDoneSince` passed; `MobileTrashTests` + `MobileUndoDoorTests`
  26/26 (2 deliberate `withKnownIssue` records in the a11y self-diagnosis test). Isolated
  DerivedData, own simulator.
- **The LR2-4 fix is the right shape and its second half is real.** `RecoveryCopy.rowKind(_ item:)`
  is one rule in one home; `RecoveryView.swift:801` now reads it instead of its inline ternary, so the
  Mac display line and the phone's VoiceOver labels cannot drift. The `item.kind != .note` guard fix
  in `MobileTrashView.rowMeta` is a genuine second find — a version *is* `.note`-kind, so the old guard
  hid the parent note's name from exactly the row that needs it.
- **Invariants.** The face is read-only over `Queries.blockHistory`; every write is an existing core
  op (`commit`, `restoreCommit`, `unarchiveVariant`, `restoreVariant`, and `placeBlock` through the
  shared `PreservedOriginPutBack`). No text is copied between entities, nothing tracks word-level
  change, no ad-hoc row edit. I1–I10 untouched.
- **P1 / P3.** `Queries.blockHistory` is block-scoped by its own indexes; `rows()` is pure and
  proportional to that block's history; the face is summoned and reads refresh-on-event rather than
  holding a `variant`+`commit_point` observation (correctly reasoned in the header comment — the Mac
  accepts that observation because its pane sits beside a live editor). The table's laziness is pinned
  in a **real key window** with `table.window != nil` asserted, `numberOfRows == renderedRows.count`
  and `visibleCells.count < renderedRows.count` — a genuinely non-vacuous version of that claim.
- **The stale-flush class is handled.** `restore` is flush-first and refuses while `autosave.isDirty`;
  `unarchive`/`putBackTake` do not rewrite a buffer, and `refreshTakesFromStore()` itself begins with
  `await autosave.flushNow()` (`MobileEditorViewModel.swift:1126`), so no pending keystrokes can be
  overwritten on those roads either.
- **The in-flight-read guard still holds where it matters.** `refresh()`'s capture check dropped the
  old `variantID` half, which is correct now that the read is block-scoped: an open(A) → close →
  open(B) race is refused by `openBlockID == blockID`, and the surviving same-block race can only
  adopt an equal-or-staler snapshot of the same block, which the next `projectionDidChange` heals.
- **"No purge door" is checkable as a value, twice.** `surfaceCapabilities` omits `deleteNow`, the row
  enum has no purge case, the copy sweep over the face's own rows asserts neither
  `RecoveryCopy.deleteNowVerb` nor the string `"Mac"` appears, and the mounted pin reads a really
  configured deleted-take cell's buttons (exactly one, and it is Put back). The phone's
  `deletedRegionExplainer(purgeRoad: nil)` genuinely ends the sentence rather than dangling — pinned
  to the literal.
- **`KnownIssuesAndTechDebt.md`'s forked-brains row was updated honestly**: `BlockPastCopy` and
  `OriginPeekCopy` moved from "still Mac-local" to discharged, `LensFallbackCopy` correctly kept, and
  the deliberate Mac-local residue named. No row this batch owned was left stale.
- **No already-owned issue was reported above.** I checked the current KnownIssues rows —
  `planVisibleTakeEdit` (13u1), the intermittent Mac latency pin (12), the gate-less insertion (13u2),
  the forked-brains row, the version-anchor row — none is touched or widened by this diff.

