# VM-271 — cold review of the phone editor core plan (draft v1)

**Reviewed:** `notes/plans/vm-271-phone-editor-core.md` at `fbb956e07` (branch `vx-1033-nov-22-sitting`), read twice.
**Tested against:** `main` at `b23550bc8`: the phone editor (`VariorumMobile/Features/Write/`, `Features/Takes/`), `Shared/EditorBrain/*`, `Shared/AutosaveCoordinator.swift`, `Shared/AppSession.swift`, the operations and domain rules in `Sources/VariorumCore/`, and the Mac editor's dispatch (`EditorSurfaceController.swift`). Also the canon, `notes/TEXTKIT2_NOTES.md` §3, `notes/MobileSoul.md` §2/§3/§5, `notes/SurfaceContracts.md` (The note), and in the worktree `phone-editor-audit.md`, `ios-text-input-research.md`, `design/phone-editor-proposal.html` and `phone-editor-inventory.md` (which has landed).
**Posture:** read-only; nothing built, run or installed. "Inference" marks my own reasoning about UIKit, as opposed to code I read or a sourced or measured fact. Examples use neutral text ("Alpha", "Hello world"). None of it comes from her notes.

---

## 0. Verdict

The plan's central idea holds up for **typing inside one block**. Accepting every change and re-reading the regions around it is robust to every in-region input I tried: autocorrect, the grey prediction, unmarked Korean composition, IME padding characters, multi-edit passes. The ask-first classification is also a sound conservative fence against the keyboard's stale cross-break proposals.

The plan breaks at **structure**. It treats the page's surviving characters and marks as the record of which block survived. The shared rules decide survival from store state the page cannot see (fans, comments, the delete join's space, the seam trim, keep-on-top's release of A), and the text view's native result is often *not* the ruled result. Three findings, built as written, lose or corrupt her writing (B1–B3). Several more change the Mac's ruled results or make the safety checks blind. The plan's claim that "Return, backspace and cross-block edits use no programmatic character change" (§15 K2) is false for the ruled results. That moves the hardest unknown (is the door safe while the keyboard is up?) onto the most frequent keystrokes. I would not approve it before the changes in §10.

---

## 1. Findings, ranked

### BLOCKERS

#### B1 — After a structural keystroke or act, the surviving region is bound to the wrong block (the plan has no identity rule)

**Plan sections:** §3 rule 1, §5.1 ("the first region … its reference is held by the map's head. Nothing on the page can lose it"), §6.2 steps 2–5, §7.4 ("the region … carries the token"), §8.1–§8.4.

**Mechanism.** In the plan, which block a region belongs to is read from the break that survives on the page. But the text view's deletion or insertion decides *which* `"\n"` survives, and the shared rule decides *which block* survives. The two often disagree. The plan never says that marks (or the head) must be rewritten to match the rule's outcome. Its §6.5 invariants check only that the library's *texts*, joined, equal the page. A reconciler that binds the wrong identity passes every one of them. Wrong bindings then become silent loss, because of how `autosave` treats takes whose block has left the note:
- A take whose block has **no live placement** (released by `merge`, by `divideW`, or by keep-on-top) **accepts the write silently**. `editableVariant` checks liveness, archive and lock. `ensurePlacementUnlocked` is a no-op when there is no placement. `registerTextChange` returns early. Evidence: `Operations+Variant.swift:54-80, 681-691, 805-808`; `Operations.swift:178-182`.
- A take whose block was **deleted** refuses (`variantNotFound`, `Operations.swift:138-143`). `AutosaveCoordinator` keeps a refused entry pending indefinitely (`AutosaveCoordinator.swift:234-247`). The text exists only on the page and goes when she leaves.

**Scenarios.** Each is input, then what the plan's mechanics produce, then what goes wrong.

1. **A paragraph plus its newline, then Delete.** This is J9; a triple-tap or drag selection includes the newline (`BlockRangeIndex.swift:341-357`).
   - Input: the page reads `Alpha⏎Beta⏎Gamma`. She selects `Beta⏎` (Beta's text and Gamma's break) and deletes.
   - The Mac: `deleteWholeBlocks([Beta])`; Gamma is untouched.
   - The plan: Gamma's break lies inside the old range, so it is struck. Beta's break survives, and the region holding `Gamma` now carries Beta's reference.
   - What goes wrong: §7.1 flushes the region's save ahead of the act, so Beta's take becomes `Gamma` and is then sent to the tray. Put back would return a copy of Gamma, and Beta's own words are no longer in its buffer. Gamma has no region on the page. Her next words in that paragraph autosave into Beta's tombstoned take, are refused, and stay pending. On reopen, her typing is gone.
2. **Select All, Delete, keep writing.**
   - J9 sends every block to the tray. The head "cannot be lost" (§5.1), so it stays bound to the deleted first block.
   - Every later save is refused and the text is lost at leaving.
   - On the Mac this leaves a blockless note whose new text is the tail (`EditorSurfaceController` `deleteCaretBlock` doc: "the blockless post is an explicitly-modelled state").
3. **⌫ at the start of a block whose previous block is empty.**
   - The Mac's carve deletes the empty block *before* the separator; when both are empty, "the one BEFORE the separator wins" (`BlockRangeIndex.swift:241-265`). The caret's block keeps its identity.
   - The text view deletes the caret block's own break. The empty block's mark is left over the caret block's text, so the identity ends up reversed.
4. **⏎ mid-paragraph in a fanned block.**
   - The ruled default is keep-on-top, which is `divideW`. A is preserved whole and released, and both halves are new blocks B and C (`Operations+Structural.swift:285-291`; `KeepOnTopDivide.swift:44-60`; Mac `applyStructural` `.divideW`).
   - The plan claims only the new newline, as pending, so the top region stays bound to A.
   - What goes wrong: every later edit to the top half lands silently in A, which is now lineage off the page. B in the library keeps the old first half. On the next open her edits are gone from the note, with no message.
5. **⏎ at a block's start, or anywhere TypedReturn answers `.emptyBlock(edge: .above)`.** That covers a whitespace prefix and a word that starts the block (`TypedReturn.swift:183-193, 241-247`).
   - The text view inserts `"\n"` after the existing break. Claiming the *new* newline with the pending reference (§8.1) binds the block's text to the new block. The old block's identity (takes, comments, history, name, callout) goes to the empty region above it.
   - What goes wrong: the next save writes `""` into the old block's shown take. The same happens at the first block through the head.
6. **Menu acts.** For Delete Block, Archive Block, and a compound whose first block is wholly covered with nothing typed, *which* break the door removes decides which mark survives. The plan does not say.

**Data at risk:** stored text, sometimes silently.

**Change required.** Add an **identity table**: for every route arm and every act (carve, seam merge, whole-block delete, clamp, compound join and non-join, divide single and fanned, divideW, Return's four arms, extract, make-block, merge, delete, archive, crystallization), give the post-act binding of every affected region and the exact mark and head rewrites. Treat the head as a mark with no character, re-pointed like any other. Put a pending token on **every** region whose identity the act *might* change, including both halves of any divide until the result says whether A kept its identity, and resolve them from the operation's result. Give U2's random test an **identity oracle** (§7 below).

#### B2 — "The text view's replacement is the Mac's compound result" is false, and "the page wins" then duplicates or merges text

**Plan section:** §8.3.

**Mechanism.** The Mac's compound joins the two surviving ends only when *both* cuts sit mid-paragraph *and* neither end carries a fan. The fan is read from the store at run time (`CrossBlockCompound.swift:27-39, 470-481, 544-551`). Otherwise the ends stay two blocks (`:571-586`). The text view always puts them on one line.

**Scenario.**
- Input: the page reads `Alpha one⏎Beta two⏎Gamma three`. She selects from the *start* of `Alpha` to just after `Ga`, and types `X`.
- The Mac: Alpha is kept because she typed (`keepsFirst`, `:438`) and becomes `X`. Beta goes to the tray. Gamma becomes `mma three`. `joinsEnds` is false because `intraStart == 0` is a paragraph break. Result: two blocks, `X` and `mma three`.
- The page: one region, `Xmma three`, bound to Alpha's mark.
- "If they differ, the page wins and a save follows": Alpha becomes `Xmma three`, Gamma still holds `mma three`, and the map has no region for Gamma. **The next open shows `mma three` twice.**
- The same happens whenever either end is fanned (`joinSuppressedByFan`). There the only other way to make "the page win" is to fold a fan away by keystroke, which is ruled never.

This is the ordinary gesture of selecting from a paragraph's start into the next paragraph and typing.

**Data at risk:** stored text (duplication), or a ruled result broken.

**Change required.** Compute `CrossBlockCompound.plan` at the gate, from the surface as it stood before the change. When `joinsEnds` is false, **decline and re-issue** through the door: replace up to the trailing block's break so the break stays, carrying the trailing block's mark. When `joinsEnds` is true but a fan hangs (known only at run time), either decline whenever the map's fan hint says fanned and keep that hint fresh (M5), or on `joinSuppressedByFan` re-insert the break through the door at the join point as a counted, traced repair. Delete "the page wins" from §8.3.

#### B3 — There is no road for a save the library refuses or quietly diverts, and §9's default widens the window to the whole typing session

**Plan sections:** §7.2, §8.7, §9 ("the plan's default until then is wait for the keyboard to go down"), §8.8.

**Scenarios.**
- **(a) The Mac merges B and C** of a note open on the phone, with the phone's keyboard up. The delivery is deferred. She types in B. The phone's `autosave` into released B succeeds silently (B1's mechanism). When the keyboard goes down, the delivery applies. The region has no *unsaved* typing, so it is overwritten with A′'s text. Her edit now lives only in a lineage block. This hole exists today too, but §9's default stretches its window from about 0.5 s to as long as the keyboard is up. And §9's claim that "her next save rescues the other text as a take" holds only for *text* moves, never structural ones.
- **(b) A remote seal, a lock on the take, or deletion of the block or take** while she types. `autosave` refuses (`lockedPost`, `lockedVariant` or `variantNotFound`). The coordinator keeps the entry pending forever, which is the audit's "stuck save" (§4) and F9. The page-only text is lost when she leaves. §8.7 covers refused *structural* acts only.
- **(c) A structural undo she asks for from the message line.** §9 exempts only a take swap from "wait for keyboard down". The library reverts (A′ is tombstoned, B and C are re-placed) while the page still shows A′. Her next words save into A′'s dead take and are refused.

**Data at risk:** stored text, silently in (a).

**Change required.**
1. Each save verifies that its block is still placed in this note at write time. That needs either a guarded `autosave` (an operation change, which is the author's call because §18 says "no operation's contract") or a same-turn placement read in the runner body, accepting a millisecond race.
2. A save that is refused or finds its block unplaced **rescues** the region's text, for example as a new block at the region's place with a sentence. Never keep-pending forever.
3. Structural deliveries and undo/redo for regions she is *not* in apply without waiting for the keyboard, through the door, subject to the probe. The region she is in is lowered and rebuilt.

### MAJORS

#### M1 — Backspace and forward delete at a seam cannot be "Follow"; they must be decline-and-re-issue

**Plan sections:** §8.2, §15 K2.

The Mac's texted-seam merge reads the fan from the store, then runs `merge(…, joining: .deleteKeystroke)`. That join puts **a space** between the halves unless an edge is already whitespace (`MergeJoin.swift:78-81`; `EditorSurfaceController.swift:2470-2495`), followed by the receipt "Blocks joined — ⌥⌘Z undoes it." When either block is fanned it refuses in words.

Under Follow, `Hello⏎World` + ⌫ gives the page `HelloWorld` while the library holds `Hello World`. Either the page wins (her ruled space is undone and the result differs from the Mac) or the region's CAS base is stale (M3, a conflict take).

The fan is a store fact. The gate's only knowledge is the map's hint, which §9 freezes while the keyboard is up. So the gate "declines before anything changes" only when the hint happens to be right. Otherwise the page joins, the operation refuses, and M4's lossy put-back follows.

**Change.** The gate declines the deletion. Read the fan on the reader pool (milliseconds). Then re-issue through the door: replace the break with the join separator, stamp or unmark, and queue the merge with a token. A refusal changes nothing on the page. Keys typed in the gap land on the unjoined page and still compose correctly: `Hello⏎x|World` becomes `Hello x|World`, the Mac's result after its deferred-key replay. Rewrite §15 K2: the keystrokes *do* use the door.

#### M2 — Every normalizing operation leaves page and library apart, and a stale CAS base then mints "conflict" takes

**Plan sections:** §8.1 ("Nothing is redrawn: the only write is one attribute"), §8.4, §8.5.

The operations normalize text:
- `divide` trims whitespace at the seam (`Operations+Structural.swift:223`, `BoundarySnapping.seamTrimmedHalves`). A newline run keeps k−1 newlines on the first half (A11).
- The Mac's `.divideAtCaret` *settles* the cut (`StructuralGesturePlanner.swift` `divide(atCaret:)` → `snapToInteriorBoundary` → `settle`, `settlePull = 2`, the #161 tie).
- Type-time crystallization trims each piece (K8, `SegmentationRules.swift:149-167, 191-203`). Bulk and idle segmentation drop blank lines and trim (`CrystallizationPlanner.swift:152-214`).
- The list exit retracts its lead and makes an empty block below (VX-655, `EditorSurfaceController.swift:976-1013`).

**Scenario.**
- `Hello |world`, then ⏎. The library holds `Hello` and `world`; the page holds `Hello ` and `world`.
- If the top region's base is the pre-divide reading (`Hello world`), the next save is `autosave(text: "Hello ", expectedText: "Hello world")` against a row holding `Hello`. That gives displaced ≠ expected ≠ text, so a **'conflict' take `Hello`** is minted (`Operations+Variant.swift:66-75`).
- The block is now fanned, and every later backspace-join on it refuses as fanned.
- If the base is right, the page's `Hello ` simply overwrites the Mac's ruled trim: results differ from the Mac.

**Change.** For each act, decide one of two things: (i) normalize the page through the door, next turn, caret-adjacent (so it needs K2's answer); or (ii) the phone adopts the page as is, which changes the ruled result and is **her call**, to be listed in §17. In either case every touched region's CAS base becomes the text the operation stored, taken from its result.

#### M3 — "A reading" does two jobs that need two values

**Plan sections:** §4, §6.2 step 3, §7.2, §6.4.

The reading is defined as "the region's text as last read while settled", and also as "the base for the next save and for a put-back".
- As the **CAS base** it must be what the library holds: the first-edit snapshot of the current save run, advanced only when a save lands, a delivery is adopted, or an operation returns. That is `AutosaveCoordinator.record(basedOn:)`'s rule (`:138-153`).
- As the **put-back source** it must be the last settled *page* text.

During every debounce window they differ. If an implementer uses one value, every save mints a conflict take, or put-backs restore to the last *saved* text and drop up to 500 ms of her keystrokes.

**Change.** Two fields per region, each defined. Also rename the term: "reading" is the codebase's word for a book (`reading` table, `Reading`, `readingID`).

#### M4 — Put-back and the refused-act repair throw away her later typing

**Plan sections:** §6.4 step 2, §8.7, §7.4 ("no text is dropped"), §16.5 ("only ever discards a change that crossed a block boundary without being hers").

Both repairs restore "the regions … from their readings".

**Scenario.**
- ⌫ joins two blocks under a stale fan hint, and she types `and` straight away.
- The merge operation reaches the runner hundreds of milliseconds later on a long note (VM-69's reads), or later still if another surface holds the one shared runner.
- It refuses. Both regions are restored from their pre-join readings, and `and` vanishes.

Typing that waits for a put-back that is itself waiting for "nothing forming" is discarded the same way.

**Change.** Repair by the **inverse of the offending change only**. Re-insert the struck break at its position, tracked through later edits, with its mark; leave every later edit where it is. When a later edit has itself crossed the old break position, fall back to keeping all the text in the surviving block and saying so. The put-back must also clear system text undo (see the MINORs).

#### M5 — The shared rules need slots and fresh flags that the plan never maintains

**Plan sections:** §8.2, §8.6, §9.

`EditorEditRoute.route` and the planners read `slots: [Queries.RenderedBlock]`, aligned with the index entries, for the carve's guards (`activeVariantCount == 1`, `!carriesUnshownText`; `EditorEditRoute.swift:465-473`), the gap fence and the diagnosis. `StructuralGesturePlanner.World` needs fan arities.

The plan never says how these are kept:
- for **pending** regions, which have no slot;
- while the keyboard is up, when §9 defers deliveries.

**Scenario: an accidental ⏎ followed at once by ⌫**, about the commonest correction there is.
- The empty block is pending, so it has no slot and the carve declines. textedSeamMerge, J9 and the clamp decline too, leaving the diagnosis's refusal.
- If the change was not asked about, it is followed and then put back. Either way the stray empty line cannot be removed until the mint has landed *and* a delivery has refreshed the slots. With the keyboard up, that never happens.
- On the Mac the keys typed in flight are replayed after the mint, so the carve works.

A misaligned slots array (a pending region in the middle) also makes the enablement read the *neighbour's* slot. The operation re-checks, so this ends in a refusal or a put-back, not loss.

**Change.** The map supplies aligned slots. Synthesize a slot for each block this editor minted (one take, no comments, empty or known text). Apply fan, lock, gap and comment-count changes from deliveries to the map's flags even while the keyboard is up; these are metadata, with no page write. A ⌫ on a pending empty region cancels or chains the mint.

#### M6 — The reconciler cannot be both "in the core package, tested by `swift test` with no stage" and composed with the shared rules

**Plan sections:** §0, §4 ("PageReconciler (Core, headless)"), §12.1, §14 U2.

`TypedReturn`, `EditorEditRoute`, `CrossBlockCompound`, `CrystallizationPlanner` and `BlockRangeIndex` live in `App/Variorum/Shared/EditorBrain/`, compiled into the two *app* targets only. Their suites run only in the Mac app target (inventory §6 line 264, §8 line 377; `TypedReturnTests` etc. in `VariorumTests`). A reconciler in `Sources/VariorumCore/Domain` cannot import them.

As written, U2 can only test a geometry-only reconciler against a *model* of the rules. The random test then never exercises the real ruled behaviour that B1, B2, M1 and M2 turn on.

**Change.** Decide and schedule one of three options:
- (a) Move the EditorBrain rule files into a package target. Behaviour is unchanged, but the diff touches files the Mac compiles, so it needs her OK under §0's fence.
- (b) Put the reconciler in `Shared/EditorBrain` and accept stage-claimed `xcodebuild` runs for U2.
- (c) Split it: a geometric core in the package, and an app-layer composition tested with stage.

Recommend (a) or (b). Also note that the Mac target's `EditorEditRouteTableTests:111-120` pins `phoneArms` as data. Adopting the Mac's arms must be a *new* list (for example `pageArms`), not an edit to `phoneArms`. Editing it would change the old editor (constraint 3) and break a Mac suite.

#### M7 — The writer is not wired into the session's save machinery, so "one writer, in order" and sync's flush-before-apply break

**Plan sections:** §7.1, §7.5.

Every flush-first door in the app flushes the post's **AppSession `AutosaveCoordinator`**:
- `flushExistingAutosave`, used by `VersionActs`, the copy family and note deletion (`AppSession.swift:383-387`);
- sync's `flushPendingTypingBeforeRound`, VX-683 A (`:634-638`);
- `savepointOnLeaving` (`:668`);
- the lock teardown `mobileWillLock` → `editors.flushAll()` → `MobileEditorViewModel.finish()` (`MobileRelock.swift:80-93`; `MobileLivenessAuthority.swift:293-297`, whose registry is typed to the old view model).

The takes sheet's card editor records into that same coordinator (inventory §4, Takes sheet). The plan names none of these.

A separate `PageWriter` would make two writers for the same takes. Sync's pull could then apply before her pending page text lands (the VX-683 hole reopened). The lock could close the pool under a pending act. And ordering between writers would be undefined; the inventory (§1.1) notes there is no FIFO across tasks.

The plan also omits `isUnlanded`: a delivery read while her write is in flight is a snapshot from before her words (`AutosaveCoordinator.swift:112-123`).

**Change.** The `PageWriter` *is* the post's coordinator for notes open in the new core, or the coordinator delegates to it. List every flush road and make each await the writer, including in-flight acts. Make the liveness registry protocol-typed. Run the writer as one task.

#### M8 — Inline predictions: rule 5 widens a loss window, and `unmarkText()` would save her a guess

**Plan sections:** §3 rule 5, §7.3, §7.5, §10.

1. Rule 5 is "a *region* with text forming is not saved." The grey prediction appears at nearly every pause. So the text she typed just before pausing stays unsaved for as long as she thinks, not for 500 ms. A crash or kill in that pause loses it. Excising the marked range keeps rule 5's promise without the window: "the marked range is never saved".
2. §7.5 ends composition with `unmarkText()`, "which accepts it", at every durability moment, including ⌘S, the commit button and the leaving savepoint. A grey prediction is marked text with system-grey attributes (research §2, WebKit and Flutter). Inference: `unmarkText()` commits marked text as ordinary text, so at a leave, lock or commit **the predicted suffix becomes her words and is frozen into a commit**. That is exactly what rule 5 exists to prevent. It is latent while predictions are off (§10), but §10 and §17.3 plan to turn them on, and the probe never tests `unmarkText` with a prediction showing.

**Change.**
- Save regions with the marked range excised.
- At durability moments, discard a completion's marked suffix, accept dictation, and treat IME composition as her call, per kind.
- Identify the kind by the completion's grey/clear attributes and its selection at offset 0 in the marked range (research §2), or by the dictation hooks.
- Add probe steps (§5 below).

#### M9 — The open tail: nothing says what mints an unminted region

**Plan sections:** §5.3, §8.5 ("The idle mint and the leaving mint become 'flush the writer'").

Flushing the writer only runs queued effects. If no mint is queued for the tail region, the last paragraph is saved only when she leaves, or never if the app dies. Today the 2-second idle mint exists (`TailCrystallizer.swift:198-205, 240-256`), and this is the audit's F4 class, which the plan claims to fix.

**Change.** An unminted region with text queues its mint on the same idle clock and at every durability moment. "Unminted" is allowed only for the last region. `BlockRangeIndex`, `TypedReturn` and the planner all assume the tail is last (`TypedReturn.swift:133-142`; planner `frontRefusal`).

#### M10 — The idle rebuild-from-page merges two blocks' text after a dropped mark

**Plan section:** §5.2, last paragraph.

"A difference with no change to explain it rebuilds the map from the page." Suppose an attribute-only system road (proofreading, a future Writing Tools, a fixing pass) drops a mark from a `"\n"` it did not replace.
- Rebuilding from the page joins the two regions in the map with no operation.
- The next save writes block 1's take as `text1⏎text2`, while block 2 still holds `text2`.
- Result: duplicated text.

This contradicts §5.2's second bullet, which repairs the mark from the map.

**Change.** A missing mark on a `"\n"` still at the map's offset is re-marked from the map. An extra mark is stripped. Rebuild only after an unexplained *character* change, and then through the put-back logic.

#### M11 — The in-app page-against-library check can pass mis-bound text and will cry wolf

**Plan section:** §11, row 3.

"Region by region" is ambiguous:
- If it compares each region with its **bound take**, every B1/B3 mis-binding passes, because the text really is in that take.
- It must compare the page with the **note's rendered projection, in order**: `Queries.takesProjection` slots (the inventory's §1.3 read), with peeked takes mapped.

It will also false-alarm on every M2 normalization (each ⏎ between words) and on pending or unsettled regions. During the trial, a mismatch line that fires on ordinary Returns would teach her to ignore it.

**Change.** Specify the comparison: a projection-ordered sequence of block ids and texts, excluding pending, unsettled and marked text, with the M2 decisions encoded as expected differences.

#### M12 — Cross-break changes that were not asked are judged by a test narrower than the ruled route

**Plan section:** §6.3.

"Exactly the one break next to her caret, or exactly the selection" misses her own unasked gestures. Example: a word-delete or accelerated held delete at a block's start that removes `world⏎`.

The Mac's route sends that range to the **clamp** (#109: "a selection edge sitting on a boundary clamps to block text … NO boundary-anchored selection refuses"), which deletes the word and keeps the break (`CrossBlockCompound.swift:169-247`). The plan puts back both the break *and* the word.

**Change.** For every lost break, run `EditorEditRoute.route` on the reconstructed old range and replacement, asked or not. Put back only what the route refuses, and only the structure: re-insert the break and keep the in-block part of the change. Keep the ask-first test as the fence against stale *keyboard* proposals.

#### M13 — Lowering and raising the keyboard is used as a routine tool without weighing the cost to feel

**Plan sections:** §8.4 (the K2 fallback), §9 (take swap), §15 K2.

The swipe-peek is the phone's native takes gesture (R58; `MobileTakesController`), and it writes the page. Dropping and re-raising the keyboard on every peek, and on every menu act under K2, means a visible keyboard animation, a frame change (the text view is pinned to `keyboardLayoutGuide`, `MobileEditorTextView.swift:1111-1125`), a scroll jump, and the end of dictation.

**Change.** Name this cost in §15/§16. Add the peek-under-keyboard case to the probe (door versus lower-and-raise). Make "keyboard bounce on peek" an explicit K4 item in her gate.

#### M14 — Her performance bar is missing from every unit's evidence

**Plan sections:** §11, §12, §14.

MobileSoul §2 requires a 100k-word perf spot-check (typing latency, scroll, open time, memory) in every stage's ladder, plus `MobileHerPathsPerfTests` as its own leg. None appears.

The new costs are real:
- Shifting region offsets is O(regions after the change) per keystroke.
- `TypedReturn.act` and `EditorEditRoute.route` take a `BlockRangeIndex`, which costs O(n) to build per keystroke unless one is maintained incrementally. Make the `PageMap` *be* one.
- Region-by-region delivery comparison is O(note text) per save echo, every half second while typing.
- The idle whole-page mark walk is O(note) on the main thread.

**Change.** Add the 100k-word perf leg to U2 (reconciler microbenchmarks at 20,000 blocks, as `EditorSeamCostTests` does) and to U3 and U5 (device timing readout, before and after).

#### M15 — Sequencing: decisions the build depends on are never scheduled, and U3 is more than one unit

**Plan section:** §14. Details in §8 below.

### MINORS

- **§8.4, Merge "through the door … a removed break".** Every merge *door* uses the rendering join: R-13u4-3, "byte-exact", with the newline staying as content (`MergeJoin.swift`; the phone's Merge with Previous uses `.door`). A menu merge is therefore an attribute-only *unmark*, not a character removal. Removing the `"\n"` contradicts her ruling and the library.
- **§8.4, "a divide at an existing newline is only a stamp".** With a run of k newlines the operation keeps k−1 on the *first* half (A11), so the *last* newline of the run must be stamped. Spaces around the newline are trimmed, which is M2.
- **§8.1, list order.** The Mac runs the list door first; `TypedReturn` excludes a list line's end, and the exit retracts and makes an empty block below (`TypedReturn.swift:194-212`; VX-655). Today's phone exit only deletes the lead (`MobileMarkdownActs.swift:195-196, 208-214`). "A list line still continues its list after the newline" leaves the order and the exit arm to a guess.
- **§8.6 reason 2 versus the Mac.** ⏎ at the end or start of a **locked** block, or inside a **gap** slot, mints a neighbour on the Mac (`insertEmptyBlock` → `newBlock(.after/.before)`; the take is not touched). "The change touches a read-only region" may decline it. Claimed Returns must bypass reason 2.
- **§5.4, sealed note.** "The text view is not editable at all" changes today's phone face, where the page stays editable with the caret drawn and the gate refuses (inventory §4, read-only states). Check this against SurfaceContracts, The note, and list it in §18.
- **Unique references.** Add the invariant that no two breaks carry the same reference and that a mark on a non-`"\n"` character is stripped. Vectors: a pasteboard with attributes if `allowsEditingTextAttributes` is ever true; a system undo restoring an old mark (inference).
- **System text undo after put-backs and door changes.** Door calls register on UIKit's undo manager (AE, research §3). A shake after a put-back can re-apply the damage and, if it asks, be classified as hers, which is a join. Clear text undo after every put-back and structural door change. The manager is the responder chain's shared one (audit F7).
- **§6.5, "rebuilding the map from the page's marks alone gives the same map".** False as stated, because the head, the two text fields (M3), flags and pending tokens are not on the page. Restate it as "the region partition and the references".
- **Multi-range asks.** One multi-range ask can produce a union pass that matches no single asked range, so the change is classified as unasked. Say how K ranges map to the ask match. The random test should model a multi-range replace as one union pass.
- **§6.4 step 1, re-mark tie-break.** With several `"\n"` in the replacement, "from the start or from the end" can pick different newlines. Name the tie-break, and say what happens when one change loses several breaks.
- **Settle detection.** Accepting a prediction may produce no *character* edit, so a region would stay unsettled until the next keystroke. Use `textViewDidChange`, selection changes and the dictation hooks (`insertDictationResultPlaceholder`, `removeDictationResultPlaceholder`, `dictationRecordingDidEnd`, research §4) as triggers, not character edits alone.
- **`markedTextRange` timing.** DTS says it is not yet updated when the change delegate runs (research §1). Read it after the pass, or the first composed character is read as settled.
- **iOS 27 automatic proofreading.** Whether `writingToolsBehavior = .none` turns it off is unknown (research §9). Add it to the probe.
- **The existing executor.** §8.3's "the existing compound … run by the executor the phone already has": `MobileStructuralController.runCrossBlockEdit` ends in `refreshTakesFromStore()`, a full redraw under the keyboard (`MobileStructural.swift:825-867`). The new face must call `CrossBlockCompound.apply` itself.
- **Re-check after every await.** A deferred rebuild that awaits a read can land after she has raised the keyboard again (the audit's `MobileLenses.activate` class). State "re-check keyboard and forming after every await" as a rule.
- **Runner contention.** The writer shares the one `OperationsRunner` with every surface (`AppSession.swift:936-941`). Pending windows stretch under long turns elsewhere, so measure them.
- **U5 and constraint 3.** "Move features over behind a narrow interface" edits the files the old editor runs during the trial. Say so, keep the old editor's suites as the guard, or duplicate until U7.
- **Seam receipts.** The phone's wording for the carve and join receipts ("Empty block deleted — ⌥⌘Z undoes it." / "Blocks joined — ⌥⌘Z undoes it." on the Mac) is unspecified. The phone's message line shows removals and refusals only (SurfaceContracts, The app).
- **Return through dictation and hardware keys.** Dictated "new line" may not arrive at the `insertText` override (research §4), giving a content newline where Return would make a block. A hardware ⇧⏎ arrives as ⏎ (`MobileEditorTextView.swift:1010-1013`).
- **The trial installs onto her real-store phone.** Name the version label at her word (VX-931's spirit). Take the runbook's safety copy (§c) before every install, and confirm sync before she writes chosen real notes in U3.
- **VoiceOver.** Its text-editing road is absent from the probe and the trial (MobileSoul §5.6).

### NITS

- §0 lists `phone-editor-inventory.md` as "what exists", and §9 says "To confirm against the inventory: what today's peek saves". The inventory has answered: typing during a peek autosaves into the peeked take, and the take's lock refuses through the gate (inventory §4, takes). Close the open line.
- §17 says "none gates run 1". True, but items 1–2 (backspace joins, Return makes a block) gate **U3**. Say that.
- §12.3's Q10 (the long-note caret bug) cannot be answered by a four-paragraph probe (§5 below).

---

## 2. Each rule and mechanism, attacked

| Part | Strongest failure found | Or: could not break, and what I tried |
|---|---|---|
| **Rule 1 — the page describes itself** | B1. The page says which `"\n"` survived, and the rule says which block survived; they differ on J9 with a trailing newline, the carve of an empty block before, fanned divide, Return `.above`, and select-all. The head is also not on the page, so "rebuild from the page alone" is false (MINOR). | — |
| **Rule 2 — accept, then read** | Holds for in-region change. | Tried autocorrect, the prediction bar, the grey prediction inside a region, Korean's unmarked composition, Zhuyin's padding characters inside the marked range, two edits in one pass (union range plus delta). Region-scoped re-reading needs only the union range and net delta, and that is right in every case. |
| **Rule 3 — the library follows the page** | False for every normalizing act (M2) and for compounds that do not join (B2). The library *cannot* simply follow; somebody has to decide. | — |
| **Rule 4 — outside changes only through the door, or with the keyboard down** | The ruled keystroke results need the door (M1, M2, B2), so K2 hits the keystrokes themselves. Waiting for the keyboard widens B3. | The door-next-turn shape itself matches React Native's October 2026 change and Apple's advice; I could not break it on paper. The probe must show it. |
| **Rule 5 — forming text not saved** | M8: losing whole pauses, and `unmarkText` accepting the guess. | Korean (never marked): saving as it changes is harmless, as the plan says. Agreed. |
| **Marks and the two witnesses (§5.1–5.2)** | M10: the idle rebuild from the page. Duplicate-reference vectors (MINOR). | Stamping one character per block, with no per-character identity, survives the iOS-strips-custom-keys fact (TEXTKIT2_NOTES §3, VM-24), as long as typed characters never inherit the mark. That is measured for mid-block typing only (§5 A2 below). |
| **Classification of whose change (§6.3)** | M12: narrower than the route, so her own unasked gestures get put back. Multi-range (MINOR). | False positives (the keyboard's stale proposal treated as hers): a stale autocorrect spanning `word⏎- ` is neither her selection nor the single break, so it is declined. Keyboard deletes always act at the text view's own selection, so "the break next to her caret" is genuinely hers. I could not make a keyboard accident pass the test. |
| **The put-back (§6.4)** | M4: it discards later edits. Undo replay (MINOR). Re-mark tie-break (MINOR). | — |
| **Settling and what is saved when (§7.3, §7.5)** | M8; the settle trigger and `markedTextRange` timing (MINORs); M9 (the tail is never minted). | — |
| **Pending regions and the writer's order (§7.1, §7.4)** | Only one region gets a token (B1 #4). Debounced saves must carry text by value: a save that reads the page at flush time after a divide writes the first half into A, and the divide's cut then lands at A's end and is refused (`invalidCut`, `Operations+Structural.swift:223-225`). Two writers (M7). | Chained ⏎⏎⏎ and saves waiting behind acts work, as long as the writer is one task and tokens are first-class in every effect, including `newBlock(.after(token))`. |
| **Follow versus decline-and-re-issue (§8 intro)** | Backspace (M1), Return (M2, B1 #4–5) and type-over that does not join (B2) are all filed under Follow, but their ruled results differ from what the text view does. | The clamp is correctly decline-and-re-issue; the phone does this today (`runClampedInBlockEdit`). |
| **Return (§8.1)** | `.above` identity (B1 #5); fanned divide (B1 #4); seam trim and settle (M2); list order (MINOR); locked/gap neighbours (MINOR); the caret moved inside the keyboard's `insertText` call (inference: autocorrect-on-Return may already have replaced the partial word before the override runs). | Return at a block's end in a single-take block with no trailing space: the page and the library agree, a single attribute is right. Return in the empty tail: `closingEmptyTail` maps onto "the tail's break becomes a block's". |
| **Backspace and forward delete (§8.2)** | M1 (the space, the fan); B1 #3 (the carve's survivor); M5 (⌫ in a pending empty block). | Carving an empty block *after* the separator: the page and the rule agree, and the caret lands where the Mac's VX-290 landing does. |
| **Across blocks (§8.3)** | B2 (no join); B1 (a wholly covered first block deleted); J9's trailing newline (B1 #1). | A selection from mid-A to the end of C, typed over: the page and the library agree (`lastIsWhole`). Select-all then type: they agree (`keepsFirst`). |
| **Menu acts (§8.4)** | Merge "removed break" (MINOR); which break a Delete Block removes (B1 #6); normalization (M2); K2 lower-and-raise cost (M13). | — |
| **Refusals after the page changed (§8.7)** | M4 (lossy repair); B3 (refused *saves* not covered); "a refused mint: its newline becomes content of the block before it, which is then saved normally" fails under a remote seal, because that save is refused too. | — |
| **Undo (§8.8)** | Structural undo waits for the keyboard (B3c). Text undo must also be cleared after put-backs and door changes (MINOR). | Clearing text undo at structural changes matches the Mac, and I could not break that part. |
| **Changes from the library (§9)** | B3 (released and deleted blocks); M13 (bounce); deliveries read while a write is in flight (`isUnlanded`, M7); the O(note) compare per echo (M14). | Text-only remote edits to a region she is typing in: the VX-849 rescue makes a conflict take, as the plan says. Correct. |
| **Takes shown on a region (§9)** | The inventory settles the open line (NIT). A peeked take's lock must make the region read-only. Divide in a peeked region must pass `displayedVariantID` (`divideW` doc, QUESTIONS #91). | — |
| **Starting settings (§10)** | Proofreading not covered (MINOR); drag-out still allowed (fine). | Plain-text paste, attachments off and TextKit 2 required are all sound. |
| **In-app checks (§11)** | M11 (blind to mis-binding, false alarms); M10 (the idle rebuild). | The per-change neighbour check is cheap and right. |

---

## 3. Where the results would differ from the Mac's ruled behaviour

The left column is the Mac, checked against the shared rules' code and doc comments. The right column is the plan as written.

| Case | Mac (ruled, from code) | Plan as written |
|---|---|---|
| ⌫ at a texted seam, neither fanned | `merge(joining: .deleteKeystroke)`: one **space** unless an edge is whitespace, plus a receipt (`MergeJoin.swift:78-81`, `EditorSurfaceController.swift:2470-2495`) | Bare join, no space; receipt unspecified (M1) |
| ⌫ at a texted seam, either fanned | Refuses in words, nothing changes (store read) | Gate decides from a stale hint; otherwise joins, then puts back (M1, M4) |
| ⌫ at the start of a block after an empty block | The empty block **before** is carved; the caret's block keeps its identity (`BlockRangeIndex.swift:241-265`) | Empty block's mark left over the caret block's text (B1 #3) |
| ⌫ in an empty block just made by ⏎ | Carve, after the deferred key is replayed | Slots missing, so refused or put back (M5) |
| ⌦ at a block's end | Same arms as ⌫ (`isDeletion` geometry) | Same divergences |
| ⏎ between words | `divide` with **seam trim**; cut **settled** (`settlePull` 2) | Newline at the caret, whitespace kept, no settle (M2) |
| ⏎ inside a word | `divideAtWordStart`, cut taken exactly (VX-806) | Matches the cut; the seam trim still diverges (M2) |
| ⏎ at a block's start, or a word that starts the block | Empty block **above**; the block keeps its identity and the caret | Identity reversed if the new newline is claimed as pending (B1 #5) |
| ⏎ in a fanned block | Keep-on-top = `divideW`: A released, B and C fresh | Top region left bound to released A, so later edits go silently to lineage (B1 #4) |
| ⏎ at a list line's end, or on an empty item | List door first (continue/exit/outdent); exit = retract + empty block below (VX-655) | Order and exit arm unspecified (MINOR) |
| ⏎ at the end or start of a **locked** block; in a **gap** slot | Mints the neighbour (`newBlock`); allowed | May be declined by §8.6 reason 2 (MINOR) |
| Typing over a cross-block selection whose start is at a paragraph start, or whose end is before a paragraph break | Two blocks; ends not joined (R-13u-2) | One line on the page, then "page wins", giving duplication (B2) |
| Same, with either end fanned | Edit lands, join suppressed (#11a) | Same as above (B2) |
| Cutting or deleting a selection whose first block is wholly covered | First block to the tray; trailing block keeps its identity | First block's mark survives over the trailing text (B1 #6) |
| Whole paragraph plus newline, then Delete (J9) | The paragraph goes; the next block is untouched | The paragraph's mark left over the next block's text (B1 #1) |
| Select All, Delete | Blockless note; new text is the tail | Head bound to the deleted block, so saves are refused (B1 #2) |
| Word-delete or held-delete acceleration across a seam | Clamp: the word goes, the break stays (#109) | Both put back (M12) |
| The clamp (one block plus its boundary break, typed over) | In-block edit; break stands | Matches (decline and re-issue) |
| Menu Merge | Rendering join: the newline stays as content (R-13u4-3) | "A removed break" through the door (MINOR) |
| Menu Divide at an internal newline run | k−1 newlines on the first half (A11) | Which newline is stamped is unspecified (MINOR) |
| Type-time crystallization, bulk paste at the end | K8 trim per piece; bulk drops blank lines | Page keeps untrimmed text (M2) |
| Sealed note | Gate refuses; on today's phone the caret is still drawn | Not editable at all (a face change, MINOR) |
| A note with one block; an empty note | — | Match, apart from select-all (above) and the tail never being minted (M9) |

---

## 4. Ordering and concurrency

- **The writer's queue against the debounce.** Saves must carry text **by value**, captured at the change. A debounced save that reads the page when it fires, after a ⏎, writes only the first half into A. The divide's cut then sits at A's stored end, `invalidCut` refuses, and the second half sits unsaved as a content newline (`Operations+Structural.swift:223-225`). The simplest correct rule is to flush *every* pending save before *any* structural act, not only those "that name the region". Structural undo touches regions by inverse rows, and its targets are not knowable from the page.
- **Structural acts in flight while she types.** Only the region carrying a token waits (§7.4). A region that keeps a minted reference but whose block the act may re-identify (the top half of a fanned divide, the survivor of a carve) does not wait, so its later saves can run before the binding is corrected. Token every region the act may re-identify (B1).
- **Acts that fail.** M4, plus B3 for refused *saves*. A failed mint under a remote seal leaves its "content newline" save refused as well.
- **Sync deliveries.** These need `isUnlanded`, M7's flush-before-round, and structural deliveries for other regions applied while the keyboard is up (B3).
- **Backgrounding and lock mid-act.** These are safe only if `MobileLivenessAuthority.flushAll` and `mobileWillLock` await the writer, *including* acts in flight (M7). iOS's background time is bounded; a long act on a 100k-word note competes with it (measure).
- **Killed between the page changing and the operation landing.** On next open the library holds the state before the act, plus every save that landed.
  - Lost: everything typed in **pending** regions (memory only until the act returns and the region's save lands); an **unminted tail** in full, if M9 is not fixed; up to the debounce in ordinary regions.
  - Not lost: text under a pending put-back is safe, because the offending change was never saved.
  - §5.3's "never lost by this wait: it is on the page" is too strong. State the exposure (time for the act to land, plus the debounce) and measure it on the 100k fixture.
- **Two edits in one storage pass.** The union range plus net delta gives the old range correctly. Breaks inside the union that are still marked survive. A break inside the union whose mark a system road stripped looks struck, and the M10 or M12 handling then applies.
- **An operation that mints ids the page needed earlier.** The caret's block (keyboard bar ⑂ and ⋯), the comments sheet, jump-to-block, the edit menu's Takes… and `StructuralGesturePlanner.World` all need ids. Either resolve tokens, or disable those doors on a pending region with a sentence. No operation accepts a caller-supplied id (inventory §1.1), so tokens are mandatory.
- **Across tasks.** Swift gives no FIFO across tasks (inventory §1.1). "One serial writer" must literally be one task that awaits each runner call in order. Everything else (debounce timers, act buttons, deliveries, durability moments) enqueues into it.

---

## 5. Unstated assumptions about UIKit and TextKit

"Probe" means the plan's §12.3. "Detects?" says whether the probe as written would show the assumption false.

| # | Assumption | If false | Detects? | Probe step to add |
|---|---|---|---|---|
| A1 | A mark on a `"\n"` survives every road that does not replace that character | Re-mark storms, or K1 | Q1, partly | Dump attribute runs before and after every event |
| A2 | A newly typed character, **including a `"\n"` typed right after a marked `"\n"`**, never inherits the mark (TEXTKIT2_NOTES §3 measured mid-block typing in the simulator only) | Content newlines are born as breaks with duplicate references | No | Caret immediately after a break: type letters, then `"\n"` (segmentation off), then dump runs; repeat after a tap there |
| A3 | `willProcessEditing` carries the true change on **device** roads (measured in the simulator and on the replace road) | Wrong old-range inference, misclassified breaks | No (it logs reports, not truth) | Snapshot the whole probe page before and after every pass and log the real diff beside the report |
| A4 | `markedTextRange` is current when the reconciler reads it | The first composed character is saved | No | Log the marked range at `shouldChange…`, `willProcessEditing`, `didProcessEditing`, `textViewDidChange` and the next turn |
| A5 | The grey prediction is marked text, and its accept and reject sequences are known | Rule 5 depends on it | Q2 | — |
| A6 | `unmarkText()` discards a completion and commits dictation or IME, and is safe at background time | A guess saved and committed (M8), or dictation lost (F4) | No | `unmarkText` with a prediction showing, while dictating, with Japanese IME composing; background mid-dictation, kill, reopen (audit §8 Q3) |
| A7 | Door calls on the next turn are **byte-exact** (no smart insert or delete spacing), keep the keyboard in step, and leave the selection predictably | Pages drift; the caret jumps; predictions go stale | Q3, partly | Assert the exact inserted bytes; log the selection immediately after `replace(_:withText:)`, above and below the caret |
| A8 | **Declining** a keyboard insertion or deletion and re-issuing it through the door next turn is invisible to the keyboard (no lost following key, no re-applied autocorrect, no shift-state glitch) | M1, M2 and B2's fixes are not viable | No | Decline ⏎, ⌫-at-seam and a typed letter over a selection; re-issue next turn; type fast after it; watch autocorrect and autocapitalization |
| A9 | Every Return (software, hardware, dictated "new line") reaches the `insertText` override with no correction applied first | ⏎ sometimes becomes content | No | Log override calls against storage passes for each Return road; ⏎ after a misspelled partial word |
| A10 | Attribute-only writes (stamps, **paragraph-style reservations written on every edit**, typed-face reset, markdown face) are harmless during composition, dictation and predictions | F10-class damage; killed dictation | Q3, partly ("stamps an attribute") | Run the probe in a second mode with the real editor's attribute writers attached |
| A11 | Lowering and raising the keyboard is acceptable and keeps the caret and scroll | K4 | No | Time and record a peek done both ways |
| A12 | UIKit's undo groups for door calls and put-backs behave as modelled | Shake re-applies damage | Q6, partly | Shake right after a door change and right after a put-back |
| A13 | Triple-tap or paragraph selection includes the trailing `"\n"` (J9 geometry) | J9 never fires, or fires differently | No | Log the range of a triple-tap and of the "Select" menu |
| A14 | Writing Tools off also silences iOS 27 proofreading | Unasked rewrites across breaks | Q8, partly | Accept and reject a proofreading underline with `writingToolsBehavior = .none` |
| A15 | Held-delete and word-delete ranges | M12 | Q7, partly | Hold delete across two breaks and through an empty region; log each pass |
| A16 | The pasteboard round trip within the note carries plain text only | Duplicate references | No | Copy across a break, paste elsewhere, dump runs |
| A17 | The long-note caret bug (FB15241823) and idle-walk cost at her note lengths | Feel; P1 | **No: four short paragraphs cannot show it (Q10)** | A second probe page seeded with a 50–100k-word fixture |

**Logging.** The probe page is a fixture, not her notes. Logging its *characters* (fixture plus scripted input) is harmless and is the only way to tell a prediction from a composition. "Kinds, positions, lengths and flags" alone cannot.

---

## 6. What an implementer would have to guess

- Which region keeps which reference after each act, and when the head moves (B1). The plan has no table.
- Whether the CAS base is the run's first-edit snapshot or the latest reading (M3), and what it becomes after each operation's result (M2).
- Whether saves carry text by value; whether *all* pending saves flush before *any* act (§4).
- How slots are produced for pending regions, and whether deliveries update flags while the keyboard is up (M5).
- Where the reconciler lives, and therefore whether it may call the shared rules (M6).
- Whether `PageWriter` replaces, wraps or sits beside `AutosaveCoordinator`. Every flush road (M7).
- What mints the tail (M9).
- Which newline to stamp for a divide at a newline run; whether a menu merge removes the `"\n"` (MINORs).
- List door versus `TypedReturn` order, and the exit arm (MINOR).
- Whether a Return claim bypasses gate reason 2 for locked and gap neighbours (MINOR).
- How a multi-range ask matches a union pass (MINOR).
- What "compared region by region" compares (M11).
- What to do when a save is refused (B3), or when a refused mint's "content" save is itself refused (§8.7).
- Which arm list to pass, given `phoneArms` is pinned by a Mac suite (M6).
- **Names that are not what the plan implies.**
  - "the executor the phone already has" for the compound ends in a full redraw (MINOR).
  - `Operations.autosave` has no guard parameter; a placement check needs either a new form or a same-turn read (B3).
  - `TypedReturn.act` and `EditorEditRoute.route` *require* a `BlockRangeIndex` and `[Queries.RenderedBlock]`, while §18 retires the phone's use of `BlockRangeIndex` "as the authority". An adapter is mandatory and its cost matters (M14).
  - "a reading" collides with the codebase's book type.

---

## 7. Test strategy gaps

**What the random-change test cannot catch as specified.**
1. **Identity.** §6.5 compares only texts. Every B1 binding passes. Add an oracle: for each step, run the *real* shared route or act on the pre-change state against real `Operations` on an in-memory store (swift-testable once M6 is decided). Assert the post-act sequence of block ids with their texts equals the editor's map bindings joined with the library.
2. **The model library is not the operations.** It has no seam trim, no join space, no CAS rescue, and no silent writes to released blocks, so M1, M2, M3 and B3 are invisible to it. Use real `Operations`.
3. **No adversary.** Interleave a *library mutator* (remote text edits; structural edits from "another device"; locks, seals, deletes) with the writer's queue, refusals and kill points. At each kill point assert that nothing older than the debounce is lost.
4. **Timing and order.** It is pure, so it cannot see task interleaving (inventory §1.1). Add a writer-order model test with injected delays: runner latency, a debounce firing mid-act.
5. **UIKit facts** (A2–A17) are out of its reach by construction. Its "with text forming" is synthetic.

**Hosted and simulator tests (§12.2).** The simulator keyboard asks before every key and has no predictions or dictation (VM-24). With a hardware keyboard attached, `replace()` asked 0 of 24 times (VM-78). Pin which configuration each test runs in.

**What only a device shows, and whether the trial would see it.**
- Silent identity mis-binding: **missed** unless §11's check compares against the note's projection in order (M11). She will not notice a paragraph quietly moving to lineage until much later.
- Letters lost in a long note: missed by eye, caught only by the check.
- Mac deliveries arriving while she types: shown only if U4's two-device session scripts *structural* Mac edits, not just text edits, in a note open on the phone with the keyboard up.
- Durability under kill: not in the trial at all. Add "dictate, background, kill, reopen" and "type the last paragraph, kill, reopen".

**Recommended addition: a scripted self-test in the trial build.** In a scratch note she performs a fixed sequence (⏎ between words, ⏎ in a fanned block, ⌫ at a seam, a J9 delete, select-all and retype, a type-over from a paragraph start). The app compares the library's resulting block structure with the expected Mac result and shows pass or fail per step. This turns the trial from "did anything feel wrong" into evidence.

---

## 8. Sequencing and sizing

- **Decisions the plan never schedules**, which U3 depends on:
  - the identity table (B1);
  - the normalization policy (M2), partly her call;
  - the reconciler's home (M6);
  - the writer's integration (M7);
  - the refused-save rescue and the placement check (B3, possibly an operation change);
  - slot maintenance (M5);
  - decline-and-re-issue for backspace and type-over (M1, B2), which makes K2 a *keystroke* question.

  These belong in a design addendum before run 2, reviewed with this plan.
- **Move earlier.** The identity oracle and a Mac-parity table into **U2**. The probe steps of §5, especially A6, A8 and A2, into **U1**. A8 decides whether the M1, M2 and B2 fixes are viable, so it decides U3's shape. Without it, run 2's design is not settled.
- **U3 is at least two units.** It holds: the text view, observer, model and writer on real operations; open, type, save, leave and all durability roads; three structural keystroke families; the gate; the put-back; the in-app checks; the switch; the base look; and the session integration. That exceeds one implementer session (the ~500k context guidance) and the "one acceptance unit" rule. Suggested split:
  - U3a: typing, saving, durability, the switch, the checks, with Return as content and the seam declined as today;
  - U3b: the structural keystrokes.

  Run 2 then becomes U3a and U3b, with U4 in run 3. Say so to her, per the sizing guidance.
- **Missing from the units entirely:**
  - the 100k-word perf leg (M14);
  - the Mac source-reading suites at every run's first batch (§16.3 names them but no unit carries the evidence);
  - the phone-store safety copy and version label before each install;
  - VoiceOver;
  - the kill and durability device steps;
  - a phone-parity row in `notes/MobileSoul.md` §6, which §18 names only at ship.
- **Runs 2–4 depend on unscheduled decisions:** §17.1–17.2 gate U3, not "none"; the normalization ruling gates U3b; the B3 operation question gates U3a's save path.

---

## 9. The strongest case against doing this at all

A sceptical senior engineer would say: **D does not remove the map; it relocates it and adds a second source of identity truth that must agree with a third, the shared rules.**

Today's phone breaks because it redraws under the keyboard (F2–F5) and has a desync gap (F1). D fixes those by never redrawing. But the ruled results of the structural keystrokes are not what a stock text view does: the delete join's space, the seam trim, the settle, keep-on-top's release of A, compounds that do not join, the list exit. So D must either change the page through the door at the caret on exactly the keystrokes the plan calls door-free, or quietly diverge from the Mac. The only big unknown D was meant to sidestep (is the door safe while the keyboard is up?) comes back on the most frequent keystrokes. K2's fallback (lower the keyboard) applied to ⌫ and ⏎ would be unusable.

The engineer would add that the fan and comment facts the rules authorize on are store facts the page cannot carry. D therefore still needs a fresh projection beside the page, which is the same stale-state discipline the Mac fought (the 13c R3-1 doctrine) and which today's phone already has.

Their alternative, within her constraints, would be **"D, narrowed"**. Keep the phone's single text view and D's accept-then-read rule for in-block typing, which is where D is plainly right and where the keyboard's unasked roads live. Make **every** structural keystroke decline-and-re-issue, exactly as the Mac and React Native do: decline, decide against the store, apply the ruled result as one small door change next turn, and never follow. That is smaller than the plan (no put-back class, no "whose change" heuristics, no follow/repair split). Its one unknown, A8, can be tested in an afternoon in U1. And its results equal the Mac's by construction, because the same planners produce the same edits.

The plan should either adopt that shape or say why Follow is worth the B1 and B2 class it brings.

A second, honest concern: constraint 3 means her phone keeps today's editor, with its traced stored-corruption window (VM-252/F1), dictation's guesses saved into commits (F3) and the tail lost on background (F4), for all four runs. That is her ruling and not up for review. But the plan should state that exposure plainly next to its timeline, so the choice is made knowing it. The audit sized the smallest belt (the desync latch plus the Release length check) at one unit.

---

## 10. Changes I would require before approving, in priority order

1. **An identity table and tokens for every re-identifiable region** (B1), with an identity oracle in U2's random test run against real `Operations` (§7).
2. **Remove "the page wins" from §8.3.** Compute the compound plan at the gate and decline-and-re-issue whenever the ends do not join (B2).
3. **A save-refused and save-diverted road:** a placement check at write time (an operation change for her, or a same-turn read) and a rescue that never keeps pending forever. Structural deliveries and undo for other regions applied without waiting for the keyboard (B3).
4. **Seam backspace and forward delete as decline-and-re-issue** with the store's fan read and the delete join (M1). Rewrite §15 K2 accordingly, and add A8 to the probe.
5. **A normalization decision per act** (door-normalize or adopt the page, the latter listed in §17 for her), and **two text fields per region** with defined CAS-base updates (M2, M3).
6. **Repairs that invert only the offending change** and keep later typing (M4).
7. **Writer integration** with the session's coordinator, every flush road, liveness and lock, as one task, with `isUnlanded` (M7). **Slots and flags kept in the map**, including synthesized slots for blocks this editor minted (M5).
8. **Rule 5 restated as "the marked range is never saved",** with per-kind handling at durability moments and probe steps A4 and A6 (M8). **The tail minted on the idle clock** (M9).
9. **Decide the reconciler's home** (M6) and add a new arm list rather than editing `phoneArms`.
10. **Fix the in-app check** to compare against the note's projection in order, with expected differences (M11). **Fix the idle rebuild** to re-mark rather than rebuild (M10). **Route every lost break through the shared route** (M12).
11. **Extend the probe** with the §5 steps: a long-note page, true-diff snapshots, a mode with the editor's attribute writers attached, fixture characters logged.
12. **Add the 100k-word perf leg to every unit** (M14). **Split U3** and schedule the decisions above before run 2 (M15). **Name the keyboard-bounce cost** in the gate (M13).
13. The MINORs and NITs in §1, at the implementer's first pass.
