# Batch 6b — THE PER-NOTE TRAY · COLD REVIEW

**Reviewer:** cold reviewer (Opus 5), zero implementation context.
**Date:** 2026-08-31.
**Target:** `7d2b04f..8a956b3` (one commit, `8a956b3` — "The note gets its
tray, and the take's only purge road opens on it").
**Read in full, myself:** the whole diff (16 files, +3130/−130) ·
`notes/plans/mobile-batch-6b-brief.md` · `notes/plans/mobile-batch-6b-record.md`
· `mobile-round-2.md` §69 · `notes/plans/mobile-batch-6c-record.md` +
`-cold-review.md` · `notes/MobileSoul.md`'s changed rows ·
`MobileNoteTray.swift` · `MobileBlockList.swift` · `MobileBlockMenu.swift` ·
`MobileStructural.swift` · `MobileWriteView.swift` · `MobileLenses.swift` ·
`MobileBlockHistory.swift` · `MobileTutorialSeeder.swift` · all four touched
test files · the Mac's `Features/Tray/TrayPanel.swift` (the reference face) ·
`Shared/RecoveryActs.swift` (`TrashScope`, `TrashPurge`, `TrashListing`) ·
`Shared/RecoveryCopy.swift` · `Shared/BlockHistoryFace.swift` ·
`Queries/PoolAndTray.swift` · `Queries/Trash.swift` ·
`Queries/EditorSupport.swift` · `Queries/LensQueries.swift` ·
`Operations+BlockArchive.swift` · `Operations+Deletion.swift`.

**What I ran** (own fresh simulator `CR-6b-cold`, iPhone 17 / iOS 26.2 — the
only iOS-26 runtime here; `ApplicationAccessibilityEnabled` armed and **read
back `1`**; private `-derivedDataPath` under my session scratchpad; simulator
deleted at the end):

1. The **full mobile suite** from `App/Variorum/`.
2. **Four red-on-old reverts reproduced by hand**, in two batches, each on
   **PRODUCTION** code (zero fixture edits): A5 + A8, then A1 + A2.
3. **One adversarial probe I wrote myself** — driving Delete Now's confirm in
   the REAL sheet composition rather than over the section mounted alone —
   then deleted.
4. The fence check, re-derived myself.

**Tree state:** clean at start, byte-identical at finish (`shasum` re-checked
on both reverted files; `git status --porcelain` empty; `Package.resolved`
undrifted). The only working-tree change is this file, left uncommitted.

---

## Severity counts

| | count |
|---|---|
| **BLOCKER** | **0** |
| **MAJOR** | **0** |
| **MINOR** | **3** |
| **NIT** | **3** |

---

## Findings

### MINOR 1 — the `stranded` listing in Leaving is neither windowed nor marked, and two records claim it is

**Label: READ-ONLY traced.**

**Where.** `App/Variorum/VariorumMobile/Features/Write/MobileNoteTray.swift:193-209`
(`adopt`) and `:538-544` (the `ForEach(model.stranded)` render, and the only
truncation marker in `leavingSection`, which is `model.deletedTruncated`'s).

**Mechanism, inputs → output.** `start()` reads all four listings bounded in
SQL at `window + 1` — including `Queries.preservedOriginals(db, postID:, limit: 201)`
(`:173-174`). `adopt` then runs three of them through the shared windower:

```swift
(deleted,  deletedTruncated)  = TrashListing.windowed(snapshot.deleted,  window: window)
(archived, archivedTruncated) = TrashListing.windowed(snapshot.archived, window: window)
(takes,    takesTruncated)    = TrashListing.windowed(snapshot.takes,    window: window)
…
stranded = snapshot.originals.filter { if case .counting = strandedFates[$0.blockID] { return true }; return false }
```

`stranded` gets **no `prefix(window)` and no `…Truncated` flag**. So for a
note holding ≥ 201 preserved originals whose families are all counting, the
face renders **201 rows and says nothing**: the +1 probe row — which exists
precisely so truncation can be *detected* — is rendered as content instead,
and the SQL cut at 201 is invisible. That is the Phase 10 "window + probe,
never a silent cut" discipline broken on one of the four listings.

**P1 itself is NOT breached** — cost stays bounded by the SQL `LIMIT`. What
fails is the visible-truncation half, which is the honesty rule, not the
performance one. Stated plainly so the severity is not inflated.

**The claim inaccuracy is the reason this is worth filing at all.** Two
places assert four-of-four:

- the record's §D1: *"**P1:** all four listings bounded IN SQL at `window + 1`
  (200, the phone rooms' value) through the shared `TrashListing.windowed`,
  each with a visible truncation marker"*;
- `MobileNoteTrayTests.everyTrayListingIsWindowedAndSaysSo`
  (`MobileNoteTrayTests.swift:414-438`), whose doc comment reads *"The
  window+probe discipline, on **all four listings**"* and which asserts
  **three** — its `Snapshot` never populates `originals` at all, so the fourth
  listing is not merely unasserted, it is absent from the fixture.

**Mitigating, and I checked it rather than assuming it.** The Mac's
`TrayViewModel.adopt` (`App/Variorum/Variorum/Features/Tray/TrayPanel.swift:386-404`)
has the **identical** shape — same unwindowed `stranded` filter over an
`originals` read limited to `window + 1`. So this is inherited parity, not a
phone regression; and the phone actually *improved* on the Mac's `archived`
half (the Mac does a bare `Array(snapshot.archived.prefix(Self.window))` and
tracks no `archivedTruncated`; the phone tracks it and renders the marker).

**Fix shape.** Either (a) window it — `(stranded, strandedTruncated) =
TrashListing.windowed(snapshot.originals.filter { … }, window: window)` plus a
marker beside the deleted one, and extend the pin's `Snapshot` to carry
`originals`; or (b) if byte-parity with the Mac is preferred until a
Mac-touching phase can do both, then **correct the two four-of-four claims**
and record the gap with a named owner. What should not stand is a record and
a pin docstring that describe coverage the code does not have.

---

### MINOR 2 — the lens fallback chip goes stale: the two Put-back doors this same commit shipped never refresh the lens model

**Label: READ-ONLY traced.**

**Where.** `MobileWriteView.swift:499-511` (the chip reads
`lenses.activeLensHasFallback` and swaps its spoken label to
`"Lenses — a pick fell back"`); `MobileLenses.swift:214-219`
(`activeLensHasFallback` reads `rows`, which only `refresh()` writes);
`MobileLenses.swift:612` (`.task { await model.refresh() }`, on
`MobileLensSheet` — the ONLY external caller; every other `refresh()` call is
inside a lens act at `:365, :406, :447, :496, :512, :530`); and the two doors
that change a take's live-ness without touching it —
`MobileNoteTray.putBackTake` (`MobileNoteTray.swift:277-287`) and the Block
History deleted-region Put back. Grep-verified: **neither file mentions
`refresh()` on the lens model.**

**Mechanism, inputs → output.** Both directions are reachable, and both doors
are in *this* commit:

- *Stale ⚠ (the loud direction).* Open the lens sheet → activate a lens whose
  pick is a deleted take → the chip wears ⚠ in the alarm token. Dismiss the
  sheet (the lens stays active — session-local `@State` on
  `MobileWriteScreen`). Open **blocks ▸ leaving** and Put back that take —
  this batch's own door. The pick is effective again, but `rows` is still the
  snapshot taken at sheet-open, so the masthead keeps announcing a fallback
  that no longer exists, to VoiceOver as well as to the eye, until she
  reopens the sheet.
- *Missing ⚠ (the quiet direction).* With a lens active and no dangles,
  archive its picked take from the Takes surface or the block ⋯. `rows` is
  stale, so the chip never raises the marker the ruling asked for.

**Not overstated.** The batch DID close the loop *inside* the lens sheet —
`restoreDangling` → `refresh()` → `activate(_:)` (`MobileLenses.swift:485-500`)
— and I pinned that road works (`anArchivedPickSaysSoLoudlyAndRestoreBringsItBack`
asserts `!lenses.activeLensHasFallback` after the sheet's own Restore). What
is missing is only the cross-surface direction. Nothing is at risk and it
self-heals on the next sheet open; the cost is that a marker built entirely
for honesty can be wrong.

**Fix shape.** Refresh the lens model where the chip lives — a
`.task { await lenses.refresh() }` (or an on-appear) on `MobileWriteScreen`,
which costs one bounded read per screen appearance and heals both directions
at once. A tighter version (refresh on the tray/History take verbs) needs a
cross-feature call the phone's composition currently avoids, so the host-level
refresh is the cheaper honest answer.

---

### MINOR 3 — the new `MobileTrayRowFace` fork is recorded only in a file that closes; the tracked enumeration was left untouched

**Label: READ-ONLY traced.**

**The mitigation is real — I verified it rather than taking the record's word.**
`MobileNoteTray.swift:369-432` re-composes the Mac's `TrayRowFace` and
`TrayTakeFace` (`TrayPanel.swift:921` and `:947`). Read side by side, the
phone's `meta`/`takeLabel`/`takeMeta` compose the **same shared primitives** —
`TrayRowPreview.line` / `.stampText` / `.emptyBlock`,
`RecoveryCopy.trayTakeInBlock` / `.daysLeftLabel` / `.archivedForever` /
`.emptyTakeLabel`, `Queries.tocHandle` — which the Mac reaches through
`TrayPath`'s forwarders, so both sides land on one string. The only divergence
is a signature one (`takeMeta(_:daysLeft:)` takes the count; the Mac's
`meta(_:now:)` derives it), which cannot change the words. And
`everyTraySentenceIsTheSharedOne` (`MobileNoteTrayTests.swift:530-556`) really
does assert the **composition** (`== RecoveryCopy.emptyTakeLabel`,
`.contains(RecoveryCopy.daysLeftLabel(3))`, `== [RecoveryCopy.archivedForever]`)
rather than a literal. **So the answer to the record's own §7.4 question is:
yes, composing shared primitives + a composition pin is enough for a batch
that cannot touch `Shared/`. That half is a clean bill.**

**What is not right is where the residue was filed.** `notes/KnownIssuesAndTechDebt.md`'s
row *"Mac app-local brains are forked against mobile siblings"* is the
**durable, owned home for exactly this class**: it enumerates the remaining
set by name (*"Remaining: `ThemeStore`, `applyTypedPath`,
`CalloutPalette`/`CalloutMenu`, `BlockSelection`, `TakesReplacePlan`, and
`LensFallbackCopy`"*) and its owner clause reads *"any Mac phase touching one
of these brains hoists it THEN"*. This batch:

- created a NEW fork of the class (`TrayRowFace`/`TrayTakeFace`), and
- made an EXISTING listed one *actually forked* — the row still describes
  `LensFallbackCopy` as merely Mac-local, but the phone gained a live twin at
  `MobileLenses.swift:203-232` (four notices, a restore verb, three receipts),

and `git diff --name-only 7d2b04f..8a956b3 -- notes/KnownIssuesAndTechDebt.md`
is **empty**. Both facts live only in `mobile-batch-6b-record.md` §5 — a batch
record, i.e. a file that closes, which is the precise state the KnownIssues
row was *restored* (2026-08-22, round 2's finding 7) to prevent: *"the
forked-brain debt had no owner outside a plan file that closes."*

The notes tree is **not fenced** — the batch edited `MobileSoul.md` and
`mobile-round-2.md` — so nothing blocked the edit.

**Fix shape.** Add both to that row's enumeration (one clause each: the new
`TrayRowFace`/`TrayTakeFace` pair with `MobileTrayRowFace` named as the phone
twin; `LensFallbackCopy` upgraded from "still Mac-only" to "forked as of batch
6b"), so the next `Shared/`-touching batch reads them off the tracked list
instead of off a closed record.

---

### NIT 1 — a vacuous assertion in the door pin

**Label: READ-ONLY traced.**

`MobileNoteTrayTests.swift:581`, under the comment *"It opens on the note's
own blocks."*:

```swift
#expect(strip.contains { $0.contains("The block that stays") == false })
```

The predicate is true for any label that does **not** contain that string, and
`strip` (`surface.visibleLabels`) always holds at least the three segment
words `in the note` / `archived` / `leaving` — asserted two lines above at
`:577-579`. So the expectation **cannot fail**, for any implementation.

The intent looks inverted. In this test `seed.keep` (*"The block that stays."*)
is **archived** at `:565-568`, so the two assertions that would carry the
comment's meaning are `!strip.contains { $0.contains("The block that stays") }`
(the archived block is not in the note listing) or
`strip.contains { $0.contains("A fanned block") }` (the surviving block is).

Nothing is left unguarded — the neighbouring `:582` and the two segment
switches at `:584-594` are real — this line simply buys nothing while reading
as if it does.

---

### NIT 2 — the A2 red-on-old quote does not correspond to the shipped tree

**Label: MEASURED** (I have both outputs).

Record §2/A2 quotes the closed-fold label array as:

```
["Leaving — on the 30-day clock", "kept — no clock", "1 deleted take", …]
```

I applied the record's own described edit (`takesShown = true`,
`MobileNoteTray.swift:457`) to the shipped tree and nothing else, and got:

```
["Leaving — on the 30-day clock", "Everything this note has on the clock: blocks it
 deleted, takes deleted on their own, and originals riding a family's countdown.
 Put back keeps a row; Delete Now ends its days early.", "1 deleted take", …]
```

The second slot is the section header's explainer, which the shipped
`leavingSection` fills with `RecoveryCopy.trayLeavingExplainer` (`:522`), not
with `archivedForever` ("kept — no clock"). So that capture was taken against
a different tree state — either with a second revert also applied (**A4**,
whose description, *"the Leaving header rendered `archivedForever`"*, is the
one that matches), or before the explainer call was written.

**The pin itself is sound** — I reproduced its red at the same
`MobileNoteTrayTests.swift:180:17`, with the same assertion — so this is a
presentation caveat on a record that presents nine reverts as a coherent,
individually-captured set. Fix shape: say which reverts were stacked, or
re-capture.

---

### NIT 3 — the purge confirm is never driven in the REAL composition (checked: it works)

**Label: MEASURED.**

Every shipped purge pin mounts `MobileNoteTraySection` **alone** — `traySurface`
at `MobileNoteTrayTests.swift:80-85` is the section plus padding. In production
the section renders inside `MobileBlockListSheet`'s `ScrollView` →
`LazyVStack` (`MobileBlockList.swift:187-194`), itself inside a `.sheet` on
`MobileWriteScreen`. An `.alert` attached to a view inside a lazy container is
exactly the shape this app has been burned by: §15's trap (b), and batch
4.5b's BLOCKER found dead confirm doors at **five** hosts under green
view-model pins. The two pins that DO mount the real sheet
(`theBlocksSheetCarriesTheTrayInThreeSegments`,
`theBlocksChipOnTheRealScreenOpensTheTray`) never reach Delete Now.

**So I wrote the pin and ran it, and it PASSES.** Mounting the real
`MobileBlockListSheet` with a tray, switching to `leaving`, opening the
disclosure, activating `Delete Now take`: the alert presents, `tapAlertAction`
drives its installed action, and `purge_intent` ends at exactly 1. Probe
deleted; tree byte-identical.

This is therefore a **coverage gap, not a defect** — filed only because the
gap is in the one place this codebase's own history says to pin. Fix shape:
land the probe (it is ~40 lines and needs no new harness).

---

## Clean bill — what I specifically checked and found solid

1. **The fence, re-derived myself.**
   `git diff --name-only 7d2b04f..8a956b3 -- Sources/ App/Variorum/Shared App/Variorum/Variorum "*.xcodeproj" "*.pbxproj"`
   → **empty**. Zero core, zero `Shared/`, zero Mac app, zero build config,
   zero schema, zero migrations, zero `Package.resolved`.

2. **The suite, on my own environment.** Final line, verbatim:
   `✘ Test run with 659 tests in 98 suites passed after 294.752 seconds with 2 known issues.`
   followed by `** TEST SUCCEEDED **`. The 2 known issues are the one
   documented diagnostic test
   (`MobileTrashTests.anEmptyAccessibilityTreeIsDiagnosedRatherThanReadAsAnAbsentDoor`,
   one `withKnownIssue` block recording two) — no other test records an issue.
   `MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
   **passed**, so no isolated re-run was needed.

3. **The count accounting, re-derived per file** (`@Test`/`@Suite` counts at
   `7d2b04f` vs `8a956b3`): tray **+17** and +1 suite · lenses **+4** · block
   menu **+2** · block history **+0** (the 6c pin renamed and rewritten, not
   added) · tutorial walk **+4** and +1 suite. **= +27 / +2**, exactly the
   record's claim; 632/96 → 659/98 holds.

4. **The ruled shape (§69.3) is what renders and acts.** Archived = archived
   blocks with `archivedForever` and no clock, Put back through
   `unarchiveBlock`. Leaving = deleted blocks with their countdown + originals
   that have MOVED onto a family clock (`adopt` filters `strandedFates` to
   `.counting` only — line-for-line the Mac's split) + deleted takes under a
   **collapsed-by-default** disclosure that carries its own count either way,
   each take naming its block through `Queries.tocHandle`, each with Put back
   and Delete Now. **No unclocked-originals section** exists anywhere in the
   file. All of it driven through real mounted surfaces and
   `accessibilityActivate()`, not asserted at the view model.

5. **Purge doors leaked nowhere.** Grep over all of `VariorumMobile/`
   (non-test) for `deleteNowVerb` / `requestDeleteNow` / `TrashPurge.` /
   `emptyTrashVerb`: hits in exactly **two** files — `MobileNoteTray.swift`
   (take rows in the Leaving section only) and `MobileTrashModel/View` (the
   global Trash room). The archived segment and the in-the-note listing carry
   none, and `thePurgeDoorIsOnLeavingAndNowhereElseInThisNote` asserts that
   over **populated** screens (`!tray.archived.isEmpty`, `!list.rows.isEmpty`)
   — not over an empty one, which is the way that pin could have been hollow.

6. **Takes still never row in the GLOBAL Trash.** `Shared/RecoveryActs.swift`
   is untouched, so `TrashScope.listedKinds` is unchanged; the pin re-asserts
   `listedKinds`, `filterKinds`, `kinds(filter:)`, the phone's own filter row,
   **and** the absence of a really-deleted take from a live `Queries.trash`
   read. The record labels this a *precondition* pin rather than a red-on-old
   and says why — that is the honest label, and it is correct.

7. **Delete Now confirms EVERY time and cannot read state SwiftUI has
   cleared.** `confirmPendingPurge` takes the confirm as a **parameter**, with
   `presenting:` carrying it into the action closure, and the binding setter
   only ever *clears* (`MobileNoteTray.swift:306-338`). I reverted it to the
   4.5b read-back shape and got exactly the recorded red
   (`MobileNoteTrayTests.swift:284:17` / `:285:17`). The "every time" half is
   driven on a second row in the same pin. And per NIT 3, I additionally
   proved it works in the real sheet composition.

8. **The D4 flip names a road that really carries the take** (the 6c-D5 class,
   checked hardest). Traced end to end: `MobileBlockHistorySheetView` is
   constructed in exactly one place — `MobileEditorTextView.swift:210`, the
   Write editor — and `MobileWriteScreen` is reachable only through
   `MobileShellView`'s `.note` route (`MobileShellView.swift:257-258`), with
   search-hit routing explicitly refusing pool homes
   (`guard … !hit.homeIsPool`). So a take listed in the History deleted region
   belongs to a block **placed in this note**, and `trayTakes`'s
   `COALESCE(cb.container_id, b.last_container_id) = :post` matches it. Both
   reads apply the **same** 30-day cutoff and the same purge-intent fence
   (`EditorSupport.deletedTakes:141-153` vs `PoolAndTray.trayTakes:359-395`),
   so the History region cannot list a take the tray's Leaving section
   excludes. The sentence is true. Its precondition half is also intact: the
   flipped pin still asserts the explainer never names the global Trash, and
   the sibling pin's loop was narrowed by **excluding one line and asserting
   it separately** (`#expect(!…deletedExplainer.contains("Mac"))`), not by
   dropping the check.

9. **The two other copy flips pass the same test.** `deleteBlock` stamps
   `lastContainerId` (`Operations+Deletion.swift:253`) and `trayBlocks` scopes
   by it, so *"Block deleted — you can put it back from blocks ▸ leaving"* is
   true. `archiveBlock` stamps it too (`Operations+BlockArchive.swift:77`) and
   `archivedBlocks` scopes by it, so *"Block archived — kept, no clock, in
   blocks ▸ archived"* is true. And the road is always open: `blocksChip`
   renders unconditionally in the masthead's chip flow
   (`MobileWriteView.swift:253`), gated by nothing.

10. **The archive receipt's `.undo` is not a false promise.**
    `Operations.archiveBlock` registers an undo entry carrying **both** halves
    (`inverse: revertArchiveBlock`, `redo: performArchiveBlock`) —
    `Operations+BlockArchive.swift:49-55`. PR6's premise checks out too: at
    `7d2b04f`, `git grep archiveBlock|unarchiveBlock -- App/Variorum/VariorumMobile/`
    returns **zero** hits, while the Mac has carried both doors since 13j
    (`BlockTOCView.swift:238/446`, `TakesStructureController.swift:172`,
    `CapabilityID.archiveBlock`). A real parity gap, not an invention.

11. **The §4 INCIDENT: I find the shipped tree whole.** Independent of the
    record's own account: every marker it names is present in its file
    (`archiveTitle` ×3, `PR14` ×7, `purgeRoadPhrase` ×2, `keeping & letting go`
    ×3, `QUICK NOTE box` ×1, `blockArchivedStatus` ×2, `activeLensHasFallback`
    ×3, `lensFallbackChipLabel` ×2); the tree compiles; the full suite is green
    at the exactly-predicted counts, which a half-restored file could not
    survive since every one of the four files' additions is referenced by a
    pin; and reading each of the four diffs, the headers and doc comments match
    the code they describe (no orphan comment referring to a symbol that isn't
    there, no code without its claimed header). **No half-application found.**
    The rule the record offers the round — *undo a behavioural revert from a
    pre-revert copy, never `git checkout --` on a file the batch also edited* —
    is the right rule, and it is what I used here.

12. **Pin quality: four reverts reproduced by hand, all on PRODUCTION code,
    zero fixture edits.**
    - **A5** (production, `MobileNoteTray.swift` — the confirm reads its
      subject back): red at `MobileNoteTrayTests.swift:284:17` and `:285:17`,
      the record's exact lines and assertions.
    - **A8** (production, `MobileBlockHistory.swift` — `purgeRoad: nil`): red
      at `MobileBlockHistoryTests.swift:857:9` (+ `:855`, `:859`) **and** at
      `:451:13` in the sibling pin — the record's exact lines.
    - **A1** (production, `MobileNoteTray.swift` — a Delete Now added to the
      Archived row): red at `MobileNoteTrayTests.swift:318:17`, the record's
      exact line.
    - **A2** (production, `MobileNoteTray.swift` — `takesShown = true`): red at
      `MobileNoteTrayTests.swift:180:17` plus the record's own declared
      collateral on the two disclosure-driving pins. (Its quoted *output*
      differs — see NIT 2 — but the red is real and lands where recorded.)
    **None of the four is green-over-nothing:** each removed guard produced a
    failure, and each failure named the behaviour the guard exists for.

13. **The held observation is scoped correctly (P1/P3).**
    `MobileNoteTrayModel.start()` has exactly one caller — the section's
    `.task` (`MobileNoteTray.swift:477`) — which exists only while an
    `archived`/`leaving` segment is on screen. `MobileWriteScreen` constructs
    the model at init but never starts it, so **nothing observes while she is
    typing**, and the header's stated reason (the sheet covers the page) is
    accurate rather than decorative. Rows are read-cheap `Text`; no live
    editor anywhere in the tray.

14. **`home: ContainerKind` is `.post` at every reachable host today**, and
    parameterising it rather than hard-coding the noun is the right call under
    13l row 26 — I verified the scraps area is a *blocks* section
    (`MobileScrapsSection`), never a `MobileWriteScreen` host.

15. **Checked and judged NOT a finding:** the shared
    `RecoveryCopy.trayLeavingExplainer` ends *"Put back keeps a row; Delete Now
    ends its days early"* over a section where only **take** rows carry a
    Delete Now. I checked the Mac before filing: `TrayPanel.swift:844-845`
    renders Delete Now on take rows **only** too, from the identical shared
    string. Byte-parity with the reference face, no phone-side divergence, and
    the sentence is loose rather than false (a deleted block's purge road is
    the global Trash; an original has none by her round-8b ruling). Recording
    the check, not a finding.

16. **PR14's shape holds up** (the record's §7.5 question). The four
    `DanglingPick` states are worded apart, the two roadless ones render the
    plain sentence instead of a button that could only fail, `restoreDangling`
    reads the op's own answer so the exact-flip case (`restoredDeletedButArchived`)
    says the pick still dangles, and the lens is re-applied through
    `activate(_:)` — the same road switching to it takes — so there is no
    second assembly path for the display. The one unmintable state (`.gone`)
    is named as unmintable and pinned only at `isRestorable`, which is the
    honest disposition rather than a faked row. `refresh()` reads
    `Queries.blockTOC` once per pass rather than per pick, as claimed. The one
    gap is MINOR 2 above, which is about staleness, not shape.

17. **Housekeeping.** `Package.resolved` did not drift. Working tree
    byte-identical to `8a956b3` apart from this file. My simulator was created
    fresh for this review and deleted at the end.

---

## For the adjudicator, in one line each

- **MINOR 1** — window `stranded` (or correct the two "all four listings"
  claims); the Mac has the same gap, so parity is a legitimate answer, silence
  is not.
- **MINOR 2** — one `refresh()` at the chip's host stops the ⚠ marker lying
  in both directions.
- **MINOR 3** — two clauses on `KnownIssuesAndTechDebt.md`'s forked-brains
  row; the fork's *mitigation* is sound and needs nothing.
- **NIT 1** — one inverted expectation to rewrite.
- **NIT 2** — one revert quote to re-capture or annotate.
- **NIT 3** — land the real-composition purge pin (it passes today).

---

# ADJUDICATION + FIX-WAVE BRIEF (the Fable orchestrator, 2026-08-31)

**ALL SIX ACCEPTED, ZERO DISPUTES.** No BLOCKER/MAJOR at round 1 ⇒ the
unit closes after ONE fix wave (the 6c economics); the orchestrator
verifies the wave's diff. Adjudicated shapes:

1. **MINOR 1 — shape (a), window it.** `(stranded, strandedTruncated) =
   TrashListing.windowed(…)` + a visible marker beside the deleted one;
   extend `everyTrayListingIsWindowedAndSaysSo`'s `Snapshot` to carry
   `originals` so the pin asserts four of four (red-on-old: the unwindowed
   filter back). The phone already improved on the Mac's archived half —
   windowing `stranded` is the consistent move, not gold-plating. **The
   Mac's identical gap is RECORDED, not fixed** (the Mac target is
   fenced): one clause on `KnownIssuesAndTechDebt.md`'s standing
   *"Bounded view windows show markers, not more"* row (owner 12) naming
   `TrayViewModel.adopt`'s unwindowed `stranded` filter — found by this
   review, inherited parity, the phone fixed its side at this wave.
2. **MINOR 2 — the host-level refresh.** `.task { await lenses.refresh() }`
   (or on-appear) on `MobileWriteScreen`, healing BOTH directions; the
   tighter per-verb cross-feature call is declined (the phone's
   composition avoids feature-to-feature calls — CLAUDE.md's rule, and
   the reviewer's own reasoning). Red-on-old at the loud direction (the
   reviewer's script: dangle → ⚠ → tray Put back → the marker must
   clear without reopening the sheet); assert the quiet direction in the
   same pin if the harness reaches it cheaply, else state so.
3. **MINOR 3 — the two clauses on the forked-brains row** (notes are not
   fenced): the new `TrayRowFace`/`TrayTakeFace` pair with
   `MobileTrayRowFace` named as the phone twin (mitigation: shared
   primitives + a composition pin — the review's clean bill), and
   `LensFallbackCopy` upgraded from "still Mac-only" to "FORKED as of
   batch 6b" (the phone's live twin at `MobileLenses.swift:203-232`).
4. **NIT 1 — rewrite the vacuous line** to the two assertions that carry
   the comment's meaning (the archived block absent from the in-the-note
   listing; the surviving block present).
5. **NIT 2 — re-capture the A2 revert SOLO** and replace the record's
   quote with the true output (or, if re-capture is impractical, annotate
   which reverts were stacked). Re-capture preferred: the record presents
   nine reverts as individually-captured and should be right.
6. **NIT 3 — land the real-composition purge pin** (the reviewer wrote
   and ran it green; ~40 lines, no new harness). Label it NEW COVERAGE
   honestly — it passes today and that is its value.

**ONE Opus fix session, the six items above, then this R28 unit CLOSES.**
Fence and environment exactly as the batch brief (own armed simulator,
private DerivedData, deleted after; full mobile suite at the end —
baseline 659/98 + 2 known issues — final line quoted; the load-flaky perf
pin re-run isolated if red; `Package.resolved` never swept; fence grep
verified empty before the pathspec-limited commit; no pushes). Every new
pin proven red by behavioural revert with output quoted, naming
production or fixture — and per the record's own §4 rule, restore
reverts from a pre-revert copy, never `git checkout --` on a file the
wave also edits. Append a FIX WAVE RESULTS section to THIS file before
the final message.
