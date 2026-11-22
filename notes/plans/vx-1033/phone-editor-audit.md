# The phone's Write editor: robustness and architecture audit (read-only, main @ 37cf317fe)

Scope: `App/Variorum/VariorumMobile/Features/Write/` (mainly `MobileEditorViewModel.swift`, `MobileEditorTextView.swift`, `MobileStructural.swift`, `MobileMarkdownActs.swift`, `MobileTypedFace.swift`), the takes and lens doors that write the page (`Features/Takes/MobileTakesController.swift`, `MobileLenses.swift`), and the shared brain they compose (`Shared/EditorBrain/*`, `Shared/AutosaveCoordinator.swift`, `Sources/VariorumCore/Domain/StructuralFlightFence.swift`). I also read: TEXTKIT2_NOTES §3, the VM-24 record, the VM-64 handoff and record, and her device edit trace of 2026-08-23 (`notes/author-reports/2026-08-23-device-walk-and-product-asks.md`, the only device trace in the repo). I edited nothing and ran nothing. Line numbers are main's.

## 0. The claims you asked me to check

| Claim | Verdict on main |
|---|---|
| No `unmarkText` or input-delegate handling anywhere in the phone editor | **True.** The only calls in `VariorumMobile/` are in `Spike/SpikeScenarios.swift`. Nothing in the editor calls `unmarkText`, touches `inputDelegate`, or implements `textViewDidBeginEditing`/`EndEditing`. |
| `renderFull`, `applyDifferential` and `desyncRecovery` have no marked-text guard | **True.** The policy's "busy" input is `autosave.isDirty \|\| mintInFlight` (`MobileEditorViewModel.swift:1026`). `renderFull` replaces the whole storage (`:1097`) and puts the caret back at a raw offset with zero length (`:1110-1113`). `applyDifferential` never restores the caret (`:1132-1161`). |
| `TailCrystallizer`, `MobileTakesController` and `MobileLenses` do check | **Partly.** `TailCrystallizer` checks only in `idleMintTail` (`TailCrystallizer.swift:270-273`). The type-time mint's `finishMint` → `replaceTailRegion` (`:482-485`) does not check. `MobileTakesController.flip`/`peek` check, but `endAllPeeksRestoringDisplay` (`:212-226`) does not. `MobileLenses.activate` checks before an `await` and writes the page after it without checking again (`MobileLenses.swift:316-326`). `MobileMarkdownActs` and the takes pan (`MobileTakesChrome.swift:573`) also check. |
| VM-64's fence can force a full render | **True.** `withholdsSystemEdit()` → `forceFullRender = true` (`:2324-2326`). `flushPendingText` then re-reads the page while the fence is up (`:1295-1297`). Both are full renders while a system input is under way, and dictation is the case P-2-3 names. |
| Once VM-24 routes a prediction ghost in-block, `recordAutosave` may save unaccepted ghost text | **True if the ghost's characters live in the storage.** `recordAutosave` saves the block's whole on-screen text, `viewText(index.range(ofEntryAt:))` (`:2450`), with no marked-text check. The recording saw the ghost's appearance reach `storageDidEdit` with no gate consult, which means its characters were in the storage. So on main the ghost is routed to its block, put in the ledger, and autosaved after 500 ms (finding 3). |

## 1. Ranked findings

### F1. TRACED-BUG: keys typed between a desync and its repair save the wrong text into the wrong block (stored corruption)

`storageDidEdit`'s refuse arm (`:2354-2359`), and every index method that refuses (`:2307`, `:2332`, `:2341`, `:2348`), leave the edit in the storage while the index keeps describing the document as it was before the edit. `desyncRecovery` (`:2486-2502`) sets `forceFullRender` and starts a Task that flushes, reads the store and then calls `ingest`. **Nothing stops typing in that gap.** The gate checks its verdict against the out-of-date index (`:1963`). `ArmedEdit.describes` compares the arming's `documentLength` with `index.documentLength` (`EditorEditRouting.swift:141`), never with `storage.length`, so the two out-of-date values agree and the edit binds. `recordAutosave` then cuts the block's text out of the storage at the index's offsets.

- **Concrete input.** Block A `Hello world` (11), block B `- milk`. A system edit inserts `!` at 11 and is refused. The storage now reads `Hello world!\n- milk`, and the index still says A is 11 long. She types `x` at the caret (12). The gate answers `.block(1)`, which is B, because B "starts" at 12 in the old tiling. The edit binds, B's length becomes 7, and B's take is saved as `x\n- mil` (expectedText `- milk` matches the store, so the CAS passes). The repair is postponed while the buffer is dirty (busy). After the flush, the forced render shows `Hello world` / `x\n- mil`. Her `!` is gone, the `x` sits on B's first line, and the `k` is lost from the store. The same out-of-date ranges in the open tail make `syncTailText` read a tail shifted by one character, and the crystallizer then mints that wrong text.
- **The window grows with the note.** It lasts one store read plus any pending flush. VM-69 measured a whole-note read at hundreds of ms for the 100k-word note. Release builds have no check: the identity audit is DEBUG-only (`:2686-2692`). The sitting ruled NT-17 / W-163 as "(b) keep the Debug oracle only" on a low-risk call that came before this trace.
- **Pins.** None. `MobileUnarmedEditRoutingTests.anUnarmedReplaceThatTrulySpansASeparatorStillRefusesAndHeals` repairs and checks the store, but it types nothing in the gap.
- **Fix shape.** A desync latch that reuses the fence's semantics: the gate refuses and says so, and the storage report withholds (no record) until the forced render lands. Also an O(1) Release check, `index.documentLength == storage.length`, before every `recordAutosave` and every bound verdict (withhold and repair when it fails). That is NT-17 (a), so the call goes back to her with this trace.

### F2. TRACED-RISK (device evidence in the recording): every programmatic rewrite ignores the keyboard's in-progress state, and the keyboard's next writes land at stale positions and are saved

Each road below rewrites the storage with no marked-text guard, no input-system notification, and a caret restored by raw offset or not at all:
- `renderFull`: desync repairs, the fence's re-read, every structural act's settle through `refreshTakesFromStore`, and a sync delivery that changes the block sequence;
- `applyDifferential`: a sync delivery that changes text;
- `desyncRecovery`.

The busy rule protects only a dirty buffer, and the 500 ms debounce makes the buffer clean exactly while she pauses, which is also when the inline prediction appears. The recording shows what follows. The caret's raw offset lands one line down, because the store lacks her letter. The keyboard's live prediction then writes at stale offsets.

**Those writes look like hers, and the editor saves them.** An in-block insert is I4 content: the empty paragraph that survived a lock and reopen. A cross-separator proposal that consults the gate becomes a stored merge (F6). One that does not consult the gate refuses, and the desync opens F1's gap.

Every keystroke-initiated compound also ends in `renderFull` under a live keyboard: the cross-block edit (`MobileStructural.swift:869-871`) and the whole-block delete.

- **Stored?** Yes, through the follow-on writes.
- **Pins.** None. No test writes the page while input is in progress.
- **Fix shape.** (a) Treat "input in progress" (`markedTextRange`, plus whatever the device shows for predictions and dictation) as busy in the policy, and settle when it ends. (b) Where a rewrite cannot wait, notify the input system around it and restore the caret by (block id, offset in block). (c) Settle structural acts with a structural differential, the Mac's `applyDifferentialStructural` (`EditorSurfaceController.swift:3159`), not a whole-storage replace.

### F3. TRACED-RISK: text that is still being composed is saved as hers inside a block

`recordAutosave` has no marked-text check. That covers dictation's live guesses, IME composition, and the inline prediction ghost if it is in the storage. Her device trace shows dictation's shape: gate-less, growing replacements at one anchor (#36–#42, `at 140 len 3…37`), a 1-character insert and removal (#43/#44, perhaps a placeholder), a gate-less delete of the whole guess (#45, Δ-37), then the final words through the gate (#46/#47). On main, each guess is routed in-block and recorded. So the 500 ms debounce, the background flush (`flushAll` → `finish`), the leaving savepoint, the ⌘S/commit doors (flush first) and the sync push can all capture provisional text. A savepoint is immutable, and a pushed guess appears on the Mac. Churn also counts every ghost and every guess.

- **Stored?** Yes: briefly in the take, and permanently in any commit or savepoint taken meanwhile.
- **Pins.** None. `setMarkedText`, `unmarkText` and `markedTextRange` appear zero times in `VariorumMobileTests`.
- **Fix shape.** One marked-text rule. Keep composed text out of the ledger and the autosave until it is committed: record when `markedTextRange` goes nil (from `textViewDidChange`/`DidChangeSelection`), and make the commit and savepoint doors flush only committed text.

### F4. TRACED-RISK: the open tail is never saved while text is being composed, so backgrounding mid-dictation can lose it

The tail exists only on screen until it is minted. `finish()` (`:840-852`) is the background road (`MobileLivenessAuthority.flushAll`) and the leaving road. It calls `idleMintTail`, which skips and re-arms under marked text (`TailCrystallizer.swift:270-273`), and the autosave holds no tail. If iOS ends the suspended app, or a Castle relock tears the editor down, the tail is lost. The most exposed case is dictating at the end of a note. This is the opposite of F3's rule for blocks: two policies for one condition.

- **Stored?** Loss.
- **Needs a device:** does UIKit commit marked text before `scenePhase` becomes `.background`?
- **Fix shape.** In the durability backstops only (background, teardown, relock), commit or mint the tail including the text before the marked range, so durability wins over composition there.

### F5. TRACED-RISK: VM-64's fence re-renders the page during dictation, and dictation's next replace or delete hits her real text

P-2-3 is withheld, then a full re-read (`:2324-2326`, `:1295-1297`, `settleFlightSurface`). The re-render removes the guess under the dictation engine. The trace shows that engine replacing `{anchor, previous length}` and finally deleting the whole guess (Δ-37). After the re-render, that range holds her own words. Those edits are gate-less. During the flight they are withheld. After the fence drops, they route in-block and save, which removes or overwrites up to a guess's length of her text.

- **Stored?** Loss.
- **Needs a device:** does UIKit keep dictation's range correct across an outside `setAttributedString`? The recording shows the prediction state does not.
- **Fix shape.** While marked text exists, never re-render under the fence. Hold the forced render until the composition ends, and keep refusing typed keys meanwhile.

### F6. TRACED-RISK: the gate turns a keyboard proposal into a structural act

A consult whose range crosses a separator schedules a whole-block delete or a cross-block merge-then-edit compound on the next turn (`:1983-2015`, `:2049-2103`, `:2186-2197`) before any edit lands. When the keyboard proposes from a stale range, she gets a stored merge she never selected: autocorrect or a prediction acceptance spanning `word\n- ` after an F2 rewrite. This matches the recording's swallowed break and lost `- `, with her next letters at the start of the next block. The compound's CAS protects only against text changing under the plan, not against the plan not being hers.

A correction to VM-64's stated evidence: in her trace, "most gate calls before one edit: 4" counts three of the editor's own refused selection-deletes (#2, #5, #7, each followed by `prog` renders) plus the key's consult (#10). So the trace does not show the keyboard asking without inserting.

- **Stored?** Yes, a structural change (the Undo door can reverse it).
- **Pins.** The compounds are pinned only as her selection's gesture (`MobileCrossBlockEditTests`).
- **Fix shape.** Let the cross-block arms answer only when the proposed range equals her current non-empty selection (and, once ruled, a ⌫ at a seam). Refuse any other cross-separator proposal that starts from a caret.

### F7. TRACED-RISK: system undo (shake, three-finger, hardware ⌘Z) replays UIKit's typing groups over a tiling crystallization has moved

The system text undo is cleared only on full renders, differentials, take swaps and a normalizing mint (`TailCrystallizer.swift:482-485`). It is not cleared when a paragraph crystallizes without a byte change, or on open/close tail or the leading-run attachment. So an undo of "Hello⏎World" can be one deletion across a new block and its separator. Without a gate consult, it desyncs (F1's gap). With one, the gate routes it to a whole-block delete or a compound, which is structural.

Also, `textView.undoManager` is the responder chain's shared manager, so `removeAllActions()` clears other fields' undo too.

- **Pins.** None for system undo in the editor (spike only).
- **Fix shape.** Clear text undo at every change to the tiling, or turn off the system text-undo gestures on this view until undo is designed (her call: VM-138's quick-row question touches it).

### F8. TRACED-RISK: Writing Tools is on by default and nothing fences it

`make()` (`MobileEditorTextView.swift:923-978`) sets no input traits. It has no `writingToolsBehavior` and no `textViewWritingToolsWillBegin`/`DidEnd`, and the policy never checks `isWritingToolsActive`. On an Apple Intelligence iPhone, an inline rewrite of a selection covering several blocks crosses separators: a compound, or a desync. The projection writes can also land in the middle of a session.

- **Needs a device:** her model, and whether a rewrite consults the gate.
- **Fix shape.** Use `.limited` or `.none` until a road through the gate exists, or fence the session like a structural flight.

### F9. TRACED-BUG (small window): Lock Note is not fenced

`lockNote` runs a flush, awaits, then `lockPost` (`:1531-1534`). A key or dictation word recorded in that window is refused at every later flush (`lockedPost`). The coordinator keeps it pending forever (`AutosaveCoordinator.swift:233-247`), so `isDirty` stays true, every delivery is deferred, and the note stops taking sync until she unlocks. The words exist only in memory.

- **Fix shape.** Hold the structural latch (the fence) across the seal.

### F10. TRACED-RISK (display): VM-243's reset paints over composed text

`MobileTypedFace.reset` (`:2377-2384`) writes the base font and ink, and removes background and strikethrough, over the changed characters, with no marked-text check. If the prediction ghost's grey, or IME/dictation styling, is a storage attribute, the ghost would read as typed text and the composition's highlight would vanish.

- **Needs a device.**
- **Fix shape.** Skip the marked range.

### F11. SMELL: the heart of the editor exists twice

These pieces live in both `MobileEditorViewModel` and the Mac's `EditorViewModel`/`EditorSurfaceController`: the gate switch, the consume road (bind → verdict → index change → re-stamp → record → desync), and the projection executor (`renderFull`, `applyDifferential`, `applyPendingIfClean` — "kept per-platform at 18m U2"). Each copy carries its own patches. VM-24's capture exists on the phone only, and VX-1031 owes it to the Mac. The VM also hand-walks the tiling in three places (`blockID(atSurfaceOffset:)`, `blockRangesByID`, `restampProjection`) instead of asking `BlockRangeIndex`. Every invariant F1–F5 needs (the latch, the length check, the marked-text rule) would land twice.

- **Fix shape.** A pure, headless edit-router state machine in `Shared/EditorBrain` (index + ledger + arming + changed characters + input state → actions), pinned once and adopted by the phone first.

### F12. SMELL: one god object, history-heavy comments, scattered global state

**`MobileEditorViewModel.swift`** is 2,985 lines: 1,328 code, 1,477 comment, 101 funcs. It mixes:
- edit routing;
- projection execution;
- the autosave-hold lifecycle;
- liveness;
- the flight fence;
- crystallization hosting;
- note acts (rename, delete, seal, entry date, version, copy);
- find and jump;
- UIKit presentation: `UIAlertController`s built and presented in `attach(textView:)` (`:576-658`), plus `becomeFirstResponder`/`endEditing`/`setContentOffset`.

Against CLAUDE.md:
- "a long view model is mixing concerns": broken.
- No side effects in view models: the alert presentation breaks it.
- Projections and IDs, never copies of persisted text: broken. `slots`, `ledger.textByVariant`, `pendingProjection` and `crystallizer.text` are sanctioned for the editor, but nothing checks the ledger against the storage (F1).

**The comments narrate rounds, batches and rulings rather than the contract, and several are stale.**
- `MobileStructural.swift:52-54` says "Structural UNDO stays Mac-side in v1", but `MobileUndoDoor` exists.
- The VM header says structural gestures, takes, markdown and find are "LATER batches".

A weaker model takes these as fact.

**Global state:**
- `MobileEditorStyle` (static mutable theme, `:57-59`).
- `MobileFallbackCanary.assertionHandler` is a static var: the process-global class `EditorAssertionSeam` already moved to `@TaskLocal`.
- The `MobileEditTrace`, `AppTiming` and `MobileTiming` statics.

**Dependencies:** persistence is reached through `AppSession` rather than `@Dependency(\.database)` (the established phone shape, not CLAUDE.md's letter).

### Largest files in scope

| File | Lines (code) |
|---|---|
| `MobileEditorViewModel.swift` | 2,985 (1,328) |
| `MobileEditorTextView.swift` | 1,129 (572) |
| `MobileStructural.swift` | 1,044 (533) |
| `MobileTakesBrowserView.swift` | 963 (656) |
| `MobileTakesBrowser.swift` | 929 (489) |
| `MobileKeyboardBar.swift` | 907 (320) |
| `MobileLenses.swift` | 797 (479) |
| `MobileNoteTray.swift` | 730 |
| `MobileWriteView.swift` | 708 |
| `MobileEditTrace.swift` | 702 |
| `Shared/EditorBrain/BlockRangeIndex.swift` | 627 |
| `Shared/EditorBrain/CrossBlockCompound.swift` | 622 |
| The Mac twin, `EditorViewModel.swift`, for scale | 4,948 (2,296) |

## 2. Roads by which text enters the storage from the system

Learned = how the editor finds out about it. Mapped = how it decides which block it belongs to.

| Road | Learned / mapped | Assumes | Pin | If the assumption fails |
|---|---|---|---|---|
| Ordinary key | Gate consult → `ArmedEdit` → bound at the report (device trace #10–#35: one consult per key) | The consult describes the next report | Hosted: `MobileStructuralFlightFenceTests.keysTypedWhileADivideLandsAreRefusedAndSaid` (consult then insert). Headless: `typeEdit` everywhere | An arming taken by another report routes by changed characters (`MobileUnarmedEditRoutingTests.aConsultedInsertWhoseArmingWasSpentRoutesToItsBlock`). In F1's gap it binds to the wrong block |
| Autocorrect on space | Device trace #14, #28: consulted and armed. The recording suggests a gate-less variant exists | The range is inside one block | Replace road: `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`, `MobileUnarmedEditRoutingTests.anUnarmedEditWhoseReportIsWidenedPastItsBlockRoutesToItsBlock` | A stale cross-separator range becomes a compound (F6) or a desync (F1) |
| Prediction-bar tap | Needs a device (gate, or the gate-less `replace(_:withText:)`) | Same | None specific | Same as autocorrect |
| Inline prediction ghost and its acceptance | Appears with no consult (the recording). Routed by changed characters into its block. Whether it is marked text: needs a device | That it is her text | None | Saved as hers (F3). Repainted in full ink (F10). A rewrite under it makes later writes stale (F2) |
| Dictation, guesses and final | Trace #36–#47: guesses gate-less, final through the gate | That a guess is text | Modelled by bare replaces only (named in comments) | Guesses saved (F3). Tail unsaved (F4). Fence re-read leads to stale deletes (F5) |
| Marked text / IME | Gate-less (consistent with the trace). `insertText`'s ⏎ door excludes it. Markdown acts, flips, pan and idle mint skip | — | None (zero `setMarkedText` in tests) | F2–F5, F10 |
| Paste | `paste(_:)` sets `isPasting`, the gate consults, and the tail paste is bulk | The consult happens inside `super.paste` | Flag simulated: `MobileEditorTests.bulkPasteSegmentsOnEntryAndPreservesGaps`, `MobileTrailingNewlinesTests.pastedGapsRoundTripByteExactly` | An asynchronous paste would mint as typing-kind (needs a device; small cost) |
| Drag and drop | UIKit default. Whether it consults, and whether an in-view move is on for iPhone: needs a device (her Aug 23 report: "had a cursor for placement but then just didn't move") | — | None | A move's source delete across blocks becomes a compound or a desync |
| Spelling menu's replacement | Needs a device; probably `replace(_:withText:)`, which is gate-less (VM-78) | In-block | Replace-road pins above | Same as autocorrect |
| Text-replacement shortcuts, swipe typing, smart dashes and quotes | Needs a device. Probably the keyboard's consulted road. Smart substitutions are left at the system default (VX-438, VM-145) | In-block | None specific | Same as autocorrect |
| System undo and redo, shake | UIKit's undo manager; whether it consults needs a device | Offsets still valid | None in the editor | F7 |
| Writing Tools | Needs a device. Not configured | — | None | F8 |
| Scribble | iPad and Pencil only; not reachable on iPhone | — | — | — |
| Hardware keyboard | Consulted input road. Tab and ⇧Tab are `keyCommands` into the markdown doors. ⇧⏎ arrives as ⏎ (a recorded limit). ⌘Z is system undo (F7). VM-78: `replace()` consulted in 0 of 24 tries with a keyboard connected | — | Tab/⏎ doors: `MobileMarkdownTests`, `MobileEditRoutingTests` | F7 |

## 3. Programmatic writes to the storage

None of these writes notifies the keyboard, so after any of them the keyboard's state is out of date (F2), and the next system write can be saved wrongly.

| Write | Safe while input is in progress | Safe if a key lands in its async gap | Caret | Can screen and store diverge, and be saved? |
|---|---|---|---|---|
| `renderFull` (initial, forced, structure change) | No guard | The decision is made after the awaited read. Busy covers a dirty buffer only | Raw offset, length 0 | The keyboard goes stale and its next writes are saved (F2, F6) |
| `applyDifferential` (sync text change, restore) | No guard | Same | Not restored (UIKit's own adjustment: needs a device) | Same |
| `desyncRecovery` → forced render | No guard | **No: the F1 gap** | Raw offset | **Yes, mis-sliced text is saved (F1)** |
| Fence withhold → re-read (VM-64) | No guard; the dictation case | Typed keys refused | Raw offset | F5 |
| Structural landings (divide, merge, extract, new block, delete, archive, cross-block, undo/redo) via `refreshTakesFromStore` | No guard | Fenced (VM-2); Insert Below exempt | Landing block by id | Display only, apart from VM-226's two roads and F2's follow-on writes |
| Sync apply landing (delivery → refetch → fresh read) | No guard | Busy defers a dirty buffer; the generation fence | As above | F2 |
| `displaySlot` (take flip, peek, lens) | Guarded at flip and peek; not at `endAllPeeksRestoringDisplay` or after `activate`'s await | Synchronous | Not restored | Display only |
| Mint reconciliation `replaceTailRegion` | Not guarded (the type-time mint) | Reconciles with the current tail | To the end only if it was at the end | Rare (only when normalizing) |
| Markdown face, re-stamp, typed-face reset, reservations, voice re-base | Attribute-only, written over marked text too | Synchronous | — | Display (F10) |
| Markdown acts, checkbox, list ⏎, Tab, clamp re-entry (`inputReplace`) | Guarded, except `runClampedInBlockEdit` | CAS | Placed by the plan | No |
| Lock and unlock | — | **Lock is not fenced (F9)** | — | Words stuck pending; the note stops taking sync |

## 4. Async and ordering hazards (beyond F1–F9)

- **Text CAS checks one thing.** `expectedText` rides every autosave (`basedOn` comes from the ledger). The ledger is filled from the screen, so the CAS catches a store that changed under her. It cannot catch a screen or tiling that is wrong (F1), or provisional text (F3). Divide, extract and merge carry no CAS. They rely on flush plus fence, and compute offsets from the screen. That is fine while the screen holds the store, and wrong inside F1's gap.
- **Span gestures read the selection before the flush.** `runSpanGesture` takes `range` from before the flush, while divide and merge re-check after it. Today it is protected by the fence's re-read; a later change could lose that protection silently.
- **A stuck save makes the note deaf.** One refused save (a remotely locked take) leaves `isDirty` true for good, so every delivery waits. P-2-4 and VM-226 cover the fence's version of this.
- **VM-227.** A note covered and shown again while its leaving flushes stops hearing `onSettled`, so deferred projections never apply.

## 5. Test reality

The ~30 editor suites type two ways:
- **Headless:** gate, then a bare `storage.replaceCharacters` (`MobileEditorTestSupport.swift:92-108`).
- **Hosted:** delegate consult, then `insertText` on a yes. `keyboardType` is copied into `MobileStructuralFlightFenceTests.swift:146` and `MobileTypedTextFaceTests.swift:112`.

Gate-less roads are modelled with bare replaces, `replace(_:withText:)` and font-only inserts. The one real-keyboard UI test (`MobileKeyboardRevealUITests`) checks scroll reveal only. As VM-24 recorded, the simulator's keyboard consults before every key, so the gate-less roads are reached only by pins and on a device. MobileSoul §5's "autocorrect and dictation test on a device" has not been met for VM-2 or VM-24 (VM-13 has not run).

**No pin at all for:** marked text, IME, dictation, the inline prediction and its acceptance, the prediction bar, system undo, Writing Tools, drag and drop, UIKit's real paste road, keys inside the desync gap, any programmatic write while input is in progress, a cross-separator proposal that starts from a caret, and Lock Note's gap.

## 6. Open tickets, clustered

- **A — the page or tiling stops describing the store, then a write follows** (F1, the fence's gaps): VM-226, VM-236, VM-19 (duplicate, a test-posture desync), VX-1031 (the Mac twin), W-163/NT-17 (Release belt, default (b); re-pose with F1).
- **B — rewrites under live keyboard input** (F2–F5, F10): no ticket names it. VM-177 and VM-178 (re-deliveries per pause and after a sync push) are perf tickets, but each re-delivery is a rewrite trigger, so they shrink the exposure. VM-77 (caret after Open) is next to it.
- **C — structure:** VM-12 (one editability authority, the self-dropping keyboard, the review backlog), VM-155 (retire the phone's copies of shared rules), VM-1 (hand-ins: seam carves, plain paste).
- **Independent:**
  - VM-228 (New Block Below refused on an empty last line);
  - VM-17 and VM-239 (chrome astray while scrolling);
  - VM-227 (autosave listening);
  - VM-217 (hold-to-select scrolls up; waits on VM-13);
  - VM-14 and VM-18 (comments sheet).
- **Features, wave 3 VM-137, all features, no hardening member:**
  - VM-140 (Return makes a block), VM-143 (backspace joins and removes), VM-142 (split at newlines), VM-146 (merge with next, block acts with the keyboard down) turn keystrokes into structural acts that end in a full render under a live keyboard. **They make F2 and F6 more likely.**
  - VM-144 (cross-block receipt) is a face on F6's compound.
  - VM-145 (paste plain, quotes, dashes, spelling) changes the input roads in §2.
  - VM-138, VM-139 (bar) and VM-141 (switch) are independent.
- **Vehicle:** VM-13, the device queue.

## 7. Recommendation: an editor hardening run before VM-137

Units in order, one implementer each, a Fable cold review (editor seam):

1. **U0 — the instrument and the road matrix.**
   - Build: the edit trace logs `markedTextRange`, every full or differential render with the caret before and after, the compound a gate refusal schedules, `index.documentLength` against `storage.length` after each routed edit (a counter), and whether Writing Tools is active.
   - Evidence: trace pins, then **one device session** with the road matrix (§8).
   - This settles the "needs a device" rows before any fix is designed around them.
2. **U1 — the desync latch and the Release length check** (F1, re-posing NT-17; VM-226 and VM-236 ride).
   - Evidence: a red-on-old pin of F1's exact scenario, the fence's pins, and a headless soak (random unarmed edits, typing and deliveries against the invariant "the store never receives a mis-sliced block").
3. **U2 — in-progress input as a state** (F3, F4, F5, F10).
   - Build: one marked-text rule; busy includes it; record on commit; backstops handle it; the fence does not re-render under it.
   - Evidence: hosted pins using real `setMarkedText`/`unmarkText` on a `MobileEditorTextView` (the spike already drives both APIs), then a device session dictating into a block and into the tail, across a divide and a backgrounding.
4. **U3 — rewrites that cannot wait** (F2, F9).
   - Build: notify the input system, restore the caret by identity, settle structural landings with a structural differential, fence the lock.
   - Evidence: pins, then a device session replaying the recording's scenario (type at the end of a non-last block, pause for the ghost, cause a structural act or a Mac edit) with the trace showing zero stale writes.
5. **U4 — proposals are not acts** (F6, F7, F8).
   - Build: compounds only for her selection; system-undo policy (hers); Writing Tools behaviour.
   - Evidence: pins and a device session.
6. **U5 — the split and the hoist** (F11, F12; VM-12, VM-155, and VX-1031's Mac half later).
   - Evidence: no behaviour change; the phone target and the Mac's source-scan suites green.
   - This can ride wave 3 or follow it.

Per the sizing guidance that is two runs: U0–U2 ("what gets saved"), then U3–U4 ("what we write under her"). U5 can stand alone.

**Must land before VM-137:** U1–U4 before VM-140, VM-143, VM-142 and VM-146; F6's guard before VM-144; U0's matrix before VM-145. **Can ride:** VM-138, VM-139, VM-141.

## 8. What I could not determine, and the device session that settles each

One session (VM-13's window), with U0's trace armed and copied after each step:

1. Is the inline prediction ghost marked text in the storage, and what does accepting or rejecting it write? Type at the end of a block that has a block after it, pause, then accept with space, and separately reject by typing on.
2. Does dictation use marked text, and does UIKit keep its range across our rewrites? Dictate into a block while the Mac edits another block of the note, then while a Divide lands.
3. Does UIKit commit marked text before the app backgrounds? Dictate at the note's end, go home mid-sentence, swipe the app away, reopen.
4. Does the keyboard ever consult without inserting? Look for GATE→no EDIT sequences that are not the editor's own refusals.
5. Do the prediction bar, the spelling menu's replacement, text replacements and swipe typing consult the gate?
6. Does system undo (shake, three-finger swipe) consult, and what range does it replace after a paragraph has crystallized?
7. Is Writing Tools available on her phone? Does a rewrite consult, and over what range?
8. Does UIKit move her caret correctly when a block above it is rewritten (a Mac edit while she types lower down)?
9. Is in-view drag-move on for iPhone, and does a drop consult?
10. Does VM-243's reset paint the ghost or the IME highlight in full ink?
