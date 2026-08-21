# Mobile round 2 — the delete-at-the-end crash, traced

**Status:** cold investigation, 2026-08-21. **Nothing was modified** — this file is the
whole output. Every claim below carries an explicit label: **[PROVEN]** (from the crash
logs, the shipped binary's own instructions, or code I read), **[DEDUCED]** (a closed
arithmetic argument over proven facts), **[SUSPECTED]** (consistent with the evidence,
not yet settled), **[UNKNOWN]**.

The repo's hallucination guard binds: no fix without a self-traced mechanism and a
red-on-old pin. The mechanism is traced to certainty at the trap; one link in the chain
(the exact UIKit decomposition) is **SUSPECTED** and §4 gives the experiment that settles
it. The fix in §6 is correct **whether or not** that link resolves the way I expect,
because it is derived from the arithmetic in §3, not from the UIKit hypothesis.

---

## 1. The evidence

Two crash reports from the author's iPhone (iPhone18,1, iOS 26.6 / 23G71), app
`io.lduarte.VariorumMobile` 1.0 (1):

| | 2026-08-20 13:59:27 | 2026-08-20 15:52:43 |
|---|---|---|
| type | `EXC_BREAKPOINT` / `SIGTRAP` | `EXC_BREAKPOINT` / `SIGTRAP` |
| frame 0 | `BlockRangeIndex.applyTailEdit(lengthDelta:)` +18340 | `BlockRangeIndex.applyBlockEdit(at:lengthDelta:)` +18220 |
| uptime before crash | ~10 s after launch | ~31 s after launch |

Frames 1–13 are **identical** in both:

```
 1 MobileEditorViewModel.storageDidEdit(_:changeInLength:)
 2 closure #1 in MobileStorageObserver.textStorage(_:didProcessEditing:range:changeInLength:)
 4 MainActor.assumeIsolated
 5 @objc MobileStorageObserver.textStorage(_:didProcessEditing:range:changeInLength:)
 6 -[NSTextStorage processEditing]
 7 -[NSTextStorage endEditing]
 8 -[NSTextStorage coordinateEditing:]
 9 -[UITextInputController _insertText:fromKeyboard:]
10 -[UITextInputController deleteBackward]
11 -[UITextView deleteBackward]
12 -[UIKBInputDelegateManager _deleteBackwardAndNotify:reinsertText:overrideOriginalContextBeforeInputWith:]
13 -[_UIKeyboardStateManager deleteBackwardAndNotifyAtEnd:deletionCount:reinsertTextInLoop:]
```

The author's description of the trigger, verbatim:

> "the app completely crashes frequently when I'm trying to highlight and select
> something at the end or delete a paragraph at the end of something, with multiple lines
> selected. there might be more cases that trigger it but i've been seeing it crash."

### 1a. The crashed binary is on disk, and it is today's source **[PROVEN]**

The `.ips` slice UUID `05B3A2C8-0732-3A39-B887-F1596D6DF21A` matches exactly one artifact:

```
~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/
    Build/Products/Release-iphoneos/VariorumMobile.app{,.dSYM}
```

built **2026-08-19 18:03**. The last commits touching the three files in the fault path
are older than that build (`BlockRangeIndex.swift` → `d40e46a`, 2026-08-18 21:53;
`MobileEditorViewModel.swift` → `1be635f`, 2026-08-09; `MobileEditorTextView.swift` →
`20ddadd`, 2026-08-09). **So the line numbers below cite the crashed build and today's
working tree at once.** No archaeology is needed and no fix is chasing a ghost.

### 1b. Which precondition, exactly — symbolicated and then disassembled **[PROVEN]**

`atos` against the matching dSYM:

```
crash 1 frame 0 → BlockRangeIndex.swift:341
crash 2 frame 0 → BlockRangeIndex.swift:347
crash 2 frame 1 → MobileEditorViewModel.swift:1014   (the `case .tail:` arm)
```

Line 341 is ambiguous on its face — the array subscript **and** the precondition both
live there:

```swift
340    mutating func applyBlockEdit(at index: Int, lengthDelta: Int) {
341        precondition(entries[index].length + lengthDelta >= 0, "block length went negative")
342        entries[index].length += lengthDelta
343    }
```

So I disassembled the shipped Release binary. `applyBlockEdit` begins at `0x100004670`;
the faulting PC is `base+18220 = 0x10000472c`:

```
0x1000046a4  tbnz x0, #0x3f, 0x100004720   ; index < 0            → brk @0x100004720
0x1000046b0  ldr  x8, [x22, #0x10]         ; entries.count
0x1000046b8  b.ls 0x100004724              ; count <= index       → brk @0x100004724
0x1000046cc  ldr  x8, [x8, #0x40]          ; entries[index].length
0x1000046d0  adds x8, x8, x1               ; + lengthDelta
0x1000046d4  b.vs 0x100004728              ; overflow             → brk @0x100004728
0x1000046d8  tbnz x8, #0x3f, 0x10000472c   ; RESULT NEGATIVE      → brk @0x10000472c  ★ PC
```

**The faulting `brk` is reachable from exactly one branch: the sign test on
`entries[index].length + lengthDelta`.** Not the bounds check, not a negative index, not
overflow.

> **Crash 1 is PROVEN to be: the index was in bounds, and the reported deletion was
> larger than the target block's recorded length.**

`applyTailEdit` begins at `0x100004748`; the faulting PC is `base+18340 = 0x1000047a4`:

```
0x100004768  ldrb w8, [x20, #0x10]         ; tailLength == nil flag
0x10000476c  tbnz w8, #0x0, 0x10000479c    ; NIL  → brk @0x10000479c   (line 346)
0x100004770  ldr  x8, [x20, #0x8]          ; tailLength
0x100004784  adds x8, x8, x0               ; + lengthDelta
0x100004788  b.vs 0x1000047a0              ; overflow
0x10000478c  tbnz x8, #0x3f, 0x1000047a4   ; RESULT NEGATIVE → brk @0x1000047a4 ★ PC
```

> **Crash 2 is PROVEN to be: the tail region *was* open (`tailLength != nil` passed), and
> the reported deletion was larger than the tail's recorded length.** Line 347, not 346.

Both `.ips` files carry an `instructionByteStream`; decoded, `beforePC`/`atPC` match the
disassembly **word for word** (`d4200020` = `brk #0x1`; crash 2's `beforePC` reproduces
`adds/b.vs/tbnz/str/strb/ret/brk/brk` at `0x100004784…0x1000047a0` exactly). The
symbolication is not an approximation.

### 1c. The Release-configuration asymmetry — this is the crux **[PROVEN]**

`App/Variorum/Variorum.xcodeproj/project.pbxproj` sets `SWIFT_OPTIMIZATION_LEVEL =
"-Onone"` and `SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)"` **only on the
Debug configuration** (line 544–547). The crashed build is `Release-iphoneos`. Therefore,
in the app the author actually runs:

| construct | in her build | consequence |
|---|---|---|
| `precondition(…)` in `BlockRangeIndex` | **live** (the `brk`s are in the binary) | **kills the app** |
| `assertionFailure(…)` in `desyncRecovery()` (`MobileEditorViewModel.swift:1095`) | **removed** | silent |
| `#if DEBUG auditIdentityProjection` body (`:1429`) | **compiled out** | silent |

So the recovery road this file argues for is **already inert and safe in her build**. The
only thing standing between her and a quiet re-render is a `precondition` that fires one
instruction before that road could ever be taken. That is the entire bug's shape.

---

## 2. The code under the trap (what routes an edit)

Two phases, exactly as the file header (`MobileEditorViewModel.swift:25–31`) describes:

**Phase 1 — the gate.** `MobileEditorGateDelegate` (`:1531`) forwards
`textView(_:shouldChangeTextIn:replacementText:)` to `shouldChangeText(in:replacement:)`
(`:952`). On an approvable verdict it **arms two fields and returns true**:

```swift
 985            pendingVerdict = verdict
 986            pendingEditCost = range.length + (replacement as NSString).length
 987            return true
```

**Phase 2 — the report.** `MobileStorageObserver` (`:1549`) forwards
`textStorage(_:didProcessEditing:range:changeInLength:)` to `storageDidEdit` (`:996`):

```swift
 997        guard !suppressEditProcessing else { return }
 998        let verdict = pendingVerdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
 999        pendingVerdict = nil
...
1003        case .block(let i):
1004            index.applyBlockEdit(at: i, lengthDelta: delta)
...
1012        case .tail:
1013            index.applyTailEdit(lengthDelta: delta)
```

**The load-bearing observation, and it is a plain reading of the code [PROVEN]:** the
verdict carries an *identity* (`.block(i)` / `.tail`) and nothing else — no range, no
document length, no sequence number. The delta comes from a completely different source
(the storage's own report). **Nothing anywhere checks that the two describe the same
edit.** `pendingVerdict` is written at `:985` and read at `:998`; the only other writes
are the two refuse arms (`:972`, `:977`) and `desyncRecovery` (`:1097`). There is no
expiry, no invalidation on selection change, no invalidation when the index is rebuilt,
and — note this — the `suppressEditProcessing` early-return at `:997` returns **before**
`pendingVerdict` is cleared, so a programmatic write does not consume a stale verdict; it
steps over it and leaves it armed.

---

## 3. The mechanism

### 3a. The lemma: the fallback road cannot produce these traps **[DEDUCED, closed]**

`fallbackVerdict` (`:1060`) reconstructs the pre-edit range:

```swift
1062        let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
1063        guard oldRange.length >= 0, oldRange.upperBound <= index.documentLength else {
1064            return .refuse(.crossesBlockBoundary)
1065        }
1066        return index.verdict(replacing: oldRange, …)
```

For a deletion (`delta < 0`) and any `editedRange.length ≥ 0`:

```
oldRange.length = editedRange.length − delta  ≥  −delta  =  |delta|
```

`verdict` (`BlockRangeIndex.swift:132–177`) returns `.block(i)` only when
`oldRange ⊆ entries[i]`, i.e. `entries[i].length ≥ oldRange.length ≥ |delta|`, hence
`entries[i].length + delta ≥ 0` — the precondition **cannot** fail. Identically for
`.tail`: containment in `tailRange` gives `tailLength ≥ oldRange.length ≥ |delta|`.

This holds *even under iOS's report widening* — the wrinkle the file itself documents at
`:102–108` and `:1369–1378` (a 5→6 replacement reporting length 7; an insert of 2
reporting +9 across a separator). Widening only makes `editedRange.length` larger, which
only makes `oldRange` larger, which only makes containment *harder*. A widened report
either overshoots `documentLength` and takes the `:1063` guard into `desyncRecovery`, or
lands contained and is safe.

> **Therefore the trap requires the verdict to have come from `pendingVerdict`** — a gate
> call whose approved range does not describe the storage edit that consumed it — **or an
> index that already disagreed with the storage before the edit began** (in which case the
> surface was already desynced, which needs the same honest road anyway).

Question 4 of the brief asked whether `fallbackVerdict`'s arithmetic is correct for a pure
deletion. **It is:** post-edit `editedRange` for a pure deletion is `(L, 0)` with
`delta = −N`, giving `oldRange = (L, N)` — exactly the pre-edit range. The arithmetic is
not the bug; it is in fact the *safe* road, and the fix in §6 leans on that.

### 3b. The proven core of the mechanism **[PROVEN]**

Combining §1b and §3a:

> A gate call armed `.block(i)` (crash 1) / `.tail` (crash 2). A subsequent
> `didProcessEditing` reported a **net deletion larger than that region held**. The apply
> step trusted the identity from one source and the magnitude from another, and the
> arithmetic went negative. `BlockRangeIndex` answered by killing the process, because the
> mutators are `precondition`-guarded rather than fallible — even though the surrounding
> design already has a name and a road for exactly this state (`.refuse(.indexDesync)` →
> `desyncRecovery()`, whose own comment reads *"The store is truth: drop local bookkeeping
> and re-render from the projection"*, `:1026–1030`).

That is enough to justify the fix. What is *not* yet proven is which of the three concrete
sources below armed the mismatched verdict.

### 3c. The three candidate sources, ranked

**M1 — the gate and the storage report are not 1:1 within one coordinated edit.
[SUSPECTED — strongly, and with an in-repo measured precedent]**

Frames 6–8 show `coordinateEditing:` → `endEditing` → `processEditing`. That is
`NSTextStorage`'s coalescing contract: **however many `replaceCharacters` calls happen
inside the block, exactly one `didProcessEditing` fires at its end, carrying the union
range and the net delta.** Frame 12's selector is
`_deleteBackwardAndNotify:reinsertText:overrideOriginalContextBeforeInputWith:` and frame
13's is `deleteBackwardAndNotifyAtEnd:deletionCount:reinsertTextInLoop:` — a delete
composed with a reinsertion, driven by the keyboard's autocorrection context machinery,
with a loop count. A delete-plus-reinsert inside one `_insertText:fromKeyboard:` is one
coordinated edit with **two** mutations; if the gate is consulted per mutation, the second
consult overwrites the first and the surviving verdict describes only the reinsertion
while the delta is the net.

This is not speculation about a platform nobody here has measured. **The repo has already
measured the same class on the other platform and paid for it.**
`App/Variorum/Variorum/Features/Editor/EditorFind.swift:16–34`, verbatim:

> **M1b — AppKit applies Replace All as ONE COALESCED STORAGE TRANSACTION.** Three matches
> across three blocks produced exactly one `didProcessEditing` with `editedRange = {4, 48}`
> and `changeInLength = 0` — a single edited range spanning both block seams. … The first
> cut of that measurement wired the real model in and the process died with *"Fatal error:
> editor surface desynced from the block index"*.
>
> **M1 — the gate is BATCHED.** Replace All asks ONE question about ALL its ranges … A
> single boolean cannot apply some and refuse others.

The Mac's answer was to refuse the system road outright and re-drive intent through the
ordinary input path one match at a time. The phone's `supportsTextReplacement: false`
(`MobileEditorTextView.swift:728`) declines the *find-replace* version of this road for
exactly this reason — while the **delete-backward** road, which the stack shows using the
same coalescing primitive, was never examined.

**M2 — a verdict armed for an edit that never landed, consumed by the next one.
[PROVEN as a code shape; live occurrence SUSPECTED]**

Nothing bounds a pending verdict's lifetime (§2). Provable arming-without-landing sites:

- `MobileMarkdownActs.inputReplace` (`MobileMarkdownActs.swift:53–69`) calls `gateAllows`
  (arming `pendingVerdict`) and *then* `textView.deleteBackward()` / `insertText()`.
- `MobileEditorTextView.performTabKey` (`:686`) arms via `gateAllows`, then
  `super.insertText("\t")`.
- `MobileMarkdownActs.handleReturnKey`'s `.continueList` arm (`:180–187`) arms, calls
  `ordinary()`, and **returns early** if the newline did not land
  (`textStorage.length == before + 1` fails) — leaving whatever the last consult armed.
- Any speculative delegate consult UIKit makes without editing (autocorrect candidate
  evaluation, `unmarkText` bookkeeping). **[UNKNOWN whether iOS does this]**

In most of these UIKit's own consult re-arms or clears immediately afterwards, which is
why the shape has survived; it is a real hole, not obviously the live one.

**M3 — the index moved between arming and consuming. [PROVEN as a code shape]**

`finishMint` (`:1217`) can close the tail entirely (`index.crystallize(…,
remainingTailLength: nil)`, `:1281`) and `renderFull` (`:559`) replaces the whole index. A
`.tail` verdict armed before either would then meet a shorter or absent tail. This is the
*only* path that reaches crash 2's **line 346** (`tailLength == nil`) — and line 346 is
**not** where she crashed, which is a small piece of counter-evidence against M3 being the
dominant story and a small piece *for* M1, where the tail is still open and merely too
short.

### 3d. Why the cross-block refusal did not save her **[DEDUCED]**

`verdict(replacing:)` handles her described selection correctly *on paper*: a span from
mid-block through the document end is contained in no entry and not inside `tailRange`, so
the entry walk falls through to `return .refuse(.crossesBlockBoundary)`
(`BlockRangeIndex.swift:176`), and mobile's `shouldChangeText` refuses and speaks
(`:976–980`, message at `:1500–1505`). **The refuse path exists and is reachable.** The
fact that she gets a crash instead of that sentence is itself evidence that **the gate is
never asked about the full span** on this road — which is M1's signature. (The phone has
no cross-block compounds: the Mac routes such a span into merge-then-edit / whole-block
delete / visible-take planners at `EditorViewModel.swift:836–909`; the phone only speaks.
So on the phone, "the gate saw it" and "the app crashed" are mutually exclusive.)

---

## 4. What remains hypothesis, and the experiment that settles it

**Open:** the exact UIKit decomposition of a selection-backspace on iOS 26.6 — how many
`shouldChangeTextIn` consults, with which ranges, versus how many `didProcessEditing`
reports, with which `editedRange`/`delta`.

**E1 — the instrumented gesture (30 minutes, device or simulator; settles it outright).**
Add temporary logging, **at these two sites only**:

- `MobileEditorViewModel.shouldChangeText` (`:952`), first line:
  `os_log("GATE #%d range=%@ repl=%d live=%d", seq, NSStringFromRange(range), (replacement as NSString?)?.length ?? -1, isLive)`
- `MobileEditorViewModel.storageDidEdit` (`:996`), first line:
  `os_log("REPORT #%d edited=%@ delta=%d pending=%@ suppressed=%d", seq, NSStringFromRange(editedRange), delta, String(describing: pendingVerdict), suppressEditProcessing)`

Build **Debug** (so a trap is a debugger stop, not a lost session) with a
`-Ounchecked`-free config, open a note of ≥3 blocks with a freshly-typed open tail, and
run this matrix:

1. select mid-block-2 → document end, backspace;
2. select two whole paragraphs in the middle, backspace;
3. same as (1) with the selection ending one character *short* of the end;
4. (1) again with **autocorrect/predictive text OFF** (`Settings → General → Keyboard`) —
   frame 12's `reinsertText:`/`overrideOriginalContextBeforeInputWith:` is the
   autocorrection context machinery, so this arm discriminates M1 sharply;
5. (1) again with a hardware keyboard's delete key (a different `_UIKeyboardStateManager`
   road).

**What each outcome means.** *Gate calls > reports* ⇒ M1 confirmed, and the last-consult
range names precisely which sub-edit armed the surviving verdict. *One gate call carrying
the full cross-block span, and a report anyway* ⇒ UIKit ignored the `false` return — a
different and more serious finding. *Zero gate calls* ⇒ pure fallback road, which §3a
proves cannot trap, so the index was already desynced and the hunt moves to §8's list.

**E2 — the same pairing, in CI.** A simulator-hosted XCTest that builds a real
`MobileEditorTextView`, attaches the real VM, sets `selectedRange` across a block boundary,
calls `textView.deleteBackward()`, and records the (gate, report) sequence. Cheaper to
re-run than E1 and it becomes a permanent regression fixture for the platform's behaviour.

**Note:** the fix in §6 does not wait on either experiment. §3a proves the *class*
independently; E1/E2 tell us how often it fires and whether a second finding (an ignored
refusal) rides along.

---

## 5. The worked numeric example

Document (segmentation `paragraph`, freshly typed so the tail is still open):

```
offset  0     5 6         15 16    21 22    27
        [ B0  ]|[   B1     ]|[ B2  ]|[ tail ]
         Alpha    Beta beta    Gamma   delta
entries: B0 len 5 · B1 len 9 · B2 len 5      tailLength = 5
separators: 5, 15, 21                         documentLength = 5+9+5 + 3 + 5 = 27
tailRange = (22, 5)          (BlockRangeIndex.swift:84–89)
```

**Gesture:** drag-select from offset 12 (mid-`B1`) to 27 (document end) — four visual
lines — and press backspace. `range = (12, 15)`, `replacement = ""`, `delta = −15`.

**Path A — the gate is asked about the whole span.** `verdict(replacing: (12,15))`:
`22 > 12` so not `.tail`; no entry contains it (`B1` ends at 15); →
`.refuse(.crossesBlockBoundary)` → `shouldChangeText` returns `false`, storage untouched,
she reads *"This edit spans more than one block — edit inside one block for now."*
**No crash.** Not what happened.

**Path B — the coalesced edit (M1).** Inside one `coordinateEditing:` block UIKit deletes
`(12,15)` and re-establishes its input context. The **last** gate consult before the block
closes describes only a sub-edit:

- *crash 2's shape* — last consult `(22, 5)` + `""`: `22 ≥ 22`, `27 ≤ 27` ⇒ **`.tail`
  armed**. One report arrives: `editedRange = (12, 0)`, `delta = −15`.
  `applyTailEdit(lengthDelta: −15)` → `tailLength != nil` **passes** (line 346) →
  `5 + (−15) = −10 < 0` → **`brk` at line 347.** ← the proven signature of 13:59:27.

- *crash 1's shape* — last consult `(16, 5)` + `""`: contained in `entries[2]` ⇒
  **`.block(2)` armed**. Same report. `applyBlockEdit(at: 2, lengthDelta: −15)` → index in
  bounds **passes** → `5 + (−15) = −10 < 0` → **`brk` at line 341.** ← the proven signature
  of 15:52:43.

Both proven trap identities fall out of one gesture with one substitution. Note also that
the *right* answer was available and cheap: `fallbackVerdict` on this report would compute
`oldRange = (12, 15)`, find no containment, return `.refuse(.crossesBlockBoundary)`, and
land in `desyncRecovery()` — a silent re-render in Release (§1c). **The stale verdict is
the only reason the safe road was skipped.**

---

## 6. The fix shape

**The guarantee to preserve:** `BlockRangeIndex` must never hold a length that fails to
describe the storage. A negative length is *proof* that the bookkeeping and the surface
have already diverged. The preconditions are right that this state is intolerable; they
are wrong about the remedy. The design already names the remedy —
`Refusal.indexDesync`'s own doc comment (`BlockRangeIndex.swift:122–126`):

> "The proposed range lies outside the document this index describes — the index has
> desynced from the storage. **Never a crash** (review round 1, MINOR 7): the view model's
> recovery re-renders from the store, which is truth."

The fix makes the *mutators* obey the rule the *router* already obeys. Three parts,
smallest first.

### Part 1 — make the mutators fallible instead of fatal (`BlockRangeIndex.swift`)

```swift
@discardableResult
mutating func applyBlockEdit(at index: Int, lengthDelta: Int) -> Bool {
    guard entries.indices.contains(index),
          entries[index].length + lengthDelta >= 0 else { return false }
    entries[index].length += lengthDelta
    return true
}

@discardableResult
mutating func applyTailEdit(lengthDelta: Int) -> Bool {
    guard let tail = tailLength, tail + lengthDelta >= 0 else { return false }
    tailLength = tail + lengthDelta
    return true
}
```

**Why this does not weaken the guarantee:** the impossible state is still refused — the
struct still will not hold a negative length, and a caller that ignores the result mutates
nothing. All that changes is *how* the refusal is delivered: a value instead of a process
death. The index-bounds check is folded in for free (it is the same class of "this
verdict does not describe me" and the disassembly shows it is a separate live trap today
at `0x100004724`).

### Part 2 — route the refusal to the honest road (both view models)

`MobileEditorViewModel.storageDidEdit` (`:1002–1031`):

```swift
case .block(let i):
    guard index.applyBlockEdit(at: i, lengthDelta: delta) else { desyncRecovery(); break }
    restampProjection(over: editedRange)
    recordAutosave(entryIndex: i, editedRange: editedRange, delta: delta, exactCost: exactCost)
case .tail:
    guard index.applyTailEdit(lengthDelta: delta) else { desyncRecovery(); break }
    …
```

The `break` matters: on the failure road nothing must re-stamp or autosave against
bookkeeping we have just declared untrustworthy. The identical change goes in
`EditorViewModel.storageDidEdit` (`:940–964`) — see §9.

`desyncRecovery` flushes, re-reads the projection and re-renders (`:1093–1107`), and in
Release its `assertionFailure` is compiled out (§1c). **In her build the crash becomes a
brief re-render.**

**One necessary companion:** `desyncRecovery`'s `assertionFailure` currently makes the
honest road untestable in Debug and would kill any pin that exercises it. Give it the
seam the canary already has (`MobileFallbackCanary.assertionHandler`,
`MobileEditorTextView.swift:48`) — a `static var assertionHandler` a pin can replace for
its own scope. `desyncRecoveryCount` (`:118`) is already the observable oracle and the
existing soaks already assert it stays 0.

### Part 3 — bind the verdict to its edit (the real fix; kills M1, M2 and M3 at once)

Parts 1–2 stop the crash. Part 3 stops the **wrong bookkeeping**, which is the same bug
one notch quieter — a stale verdict that happens *not* to go negative silently records the
wrong block's length, and the surface drifts from the index with no trap to announce it.

Carry the arming context with the verdict:

```swift
private var pendingVerdict: (verdict: BlockRangeIndex.Verdict,
                             range: NSRange,
                             documentLength: Int)?
```

armed at `:985` with `(verdict, range, index.documentLength)`, and consumed at `:998`
only when it still describes the arriving report:

```swift
let pending = pendingVerdict.flatMap { p -> BlockRangeIndex.Verdict? in
    // the index must not have moved under it (M3)
    guard p.documentLength == index.documentLength else { return nil }
    // a deletion can never remove more than the approved range (M1)
    guard -delta <= p.range.length else { return nil }
    // …and the landing must start inside what was approved (M2)
    guard editedRange.location >= p.range.location,
          editedRange.location <= p.range.upperBound else { return nil }
    return p.verdict
}
let verdict = pending ?? fallbackVerdict(editedRange: editedRange, delta: delta)
```

Rejecting a pending verdict falls through to `fallbackVerdict`, which §3a **proves** is
arithmetically safe and which — on the §5 example — produces the correct
`.refuse(.crossesBlockBoundary)` → `desyncRecovery()`. `pendingEditCost` (`:109`) should
be discarded on the same condition; churn is approximate by design (`:106–108`), so the
report-derived fallback cost is the right answer there.

**Also clear the arming when it can no longer be meaningful** — one line each in
`renderFull` (`:559`, where `index` is wholly replaced), `applyDifferential` (`:587`) and
`finishMint`'s `index.crystallize` (`:1281`). Cheap, and it closes M3 structurally rather
than by predicate.

**Deliberately NOT in scope of this fix:** widening the phone's cross-block behaviour. Her
gesture *should* eventually do something better than refuse — the Mac's `wholeBlockRun`
(`BlockRangeIndex.swift:280`, 13j's J9) and merge-then-edit exist for exactly this, and
the phone has neither wired. That is product work, it is 13j/13e-shaped, and it is hers to
rule. **This fix's whole claim is: the app must not die, and the bookkeeping must not
lie.**

---

## 7. Red-on-old pin design

The repo's binding rule: each pin **fails on the pre-fix tree and passes after**, and a
pin that passes on both exposes the finding as hollow. Fixtures use the existing harness
(`VariorumMobileTests/MobileEditorTestSupport.swift` — `withEditorWorld`, `makeEditor`,
`typeEdit`); a new file `VariorumMobileTests/MobileEditRoutingTests.swift` is the natural
home. The §5 document is the shared fixture:

```swift
// three blocks + an open tail: "Alpha\nBeta beta\nGamma\ndelta"
// entries 5 / 9 / 5, tailLength 5, documentLength 27
```

**P1 — `aStaleVerdictIsNotAppliedToTheNextEdit` — the headline pin (clean red, no
process death).**
Arm a verdict that never lands, then land an unrelated edit elsewhere.
*Act:* `_ = model.shouldChangeText(in: NSRange(location: 0, length: 1), replacement: "X")`
(arms `.block(0)`, no storage mutation follows), then a real one-character insertion inside
`B1` via `typeEdit(model, storage, range: NSRange(location: 8, length: 0), replacement: "!")`.
*Assert:* `model.index.entries[1].length == 10` **and** `model.index.entries[0].length == 5`
**and** `model.index.documentLength == storage.length`.
*Red on old:* today the stale `.block(0)` is consumed at `:998`; `entries[0]` grows to 6
and `entries[1]` stays 9. Both first assertions fail. **No crash — this pin is the clean
oracle for Part 3** and it is the one that proves the fix is the binding fix rather than
a crash bandage.

**P2 — `aCoalescedDeleteWiderThanItsTailVerdictHealsInsteadOfTrapping` — crash 2's exact
reproduction.**
*Act:* `#expect(model.shouldChangeText(in: NSRange(location: 22, length: 5), replacement: ""))`
(arms `.tail`), then reproduce the coalesced transaction the way `coordinateEditing:`
delivers it — **one** report for a wider mutation:
```swift
storage.beginEditing()
storage.replaceCharacters(in: NSRange(location: 12, length: 15), with: "")
storage.endEditing()          // → ONE didProcessEditing, editedRange (12,0), delta −15
```
*Assert:* the process survives; `model.desyncRecoveryCount == 1`; after the recovery
settles, `model.index.documentLength == storage.length`; the store's block texts are
unchanged (nothing was autosaved from poisoned bookkeeping).
*Red on old:* today this **traps at `BlockRangeIndex.swift:347`** — the test process dies.
That is a legitimate red but an ugly one; note it in the pin's comment, and run P2/P3 in
their own file so a pre-fix verification run does not take the whole suite's report down
with it. (`desyncRecovery`'s assertion seam from §6 Part 2 is a prerequisite for the
post-fix green in Debug.)

**P3 — `aCoalescedDeleteWiderThanItsBlockVerdictHealsInsteadOfTrapping` — crash 1's twin.**
Identical, arming `.block(2)` via
`shouldChangeText(in: NSRange(location: 16, length: 5), replacement: "")`.
*Red on old:* traps at `BlockRangeIndex.swift:341`.

**P4 — `aVerdictArmedBeforeTheTailClosedIsRefused` — M3, and crash 2's line-346 sibling.**
*Act:* arm `.tail` for `(22,5)`; then close the tail deterministically (`model.idleMintTail()`
+ `await model.awaitMintSettle()`, the harness's existing deterministic mint road); then
deliver a small storage edit.
*Assert:* no trap; `desyncRecoveryCount == 1` **or** the edit routes by `fallbackVerdict`
to the correct entry (whichever the fix yields — pin the observable, not the branch).
*Red on old:* traps at `BlockRangeIndex.swift:346`.

**P5 — pure-value pins, `VariorumTests`/core-side, `BlockRangeIndexTests`:**
`aBlockEditLargerThanItsEntryIsRefused` and `aTailEditLargerThanTheTailIsRefused` —
construct the index directly, call the mutator, assert `false` **and** that the entry/tail
is byte-unchanged. *Red on old:* these do not compile against `-> Void` (an API-shape red),
and written against today's signature they trap. Record the pre-fix red **by behavioural
revert**, the method the 13j ladder already uses.

**Bridging pin, optional but valuable — `theRealDeleteBackwardPairsGateCallsToReports`:**
the E2 experiment promoted to a permanent simulator-hosted fixture (real
`MobileEditorTextView`, real selection, real `deleteBackward()`), asserting only that the
index still tiles the storage afterwards. It will not be red-on-old *deterministically* if
UIKit's decomposition depends on keyboard state — so it is a **regression fixture, not a
pin**, and must be labelled as such rather than counted as the guard's satisfaction.

---

## 8. Every other path that can reach an unvalidated delta, ranked

Ranked by likelihood of reaching the same trap. Everything here becomes **safe by
construction** once §6 Part 2 lands, because every one of them funnels through
`storageDidEdit`'s two apply calls.

| # | Path | Why it can reach the trap | Likelihood |
|---|---|---|---|
| 1 | **Selection-delete via the keyboard** (`deleteBackward`) | The proven crash road. Coalesced delete+reinsert under one `coordinateEditing:`; last gate consult survives. | **Observed twice** |
| 2 | **Autocorrect / predictive replacement** | The same frame-12 machinery (`reinsertText:`, `overrideOriginalContextBeforeInputWith:`) drives correction acceptance. Replacements can be net-negative (a long word → short), and the file already measures that iOS *widens* these reports (`:102–108`). | **High** |
| 3 | **Paste over a multi-line selection** | `MobileEditorTextView.paste` (`:749`) sets `isPasting` and calls `super.paste`; UIKit implements it as replace-selection — the same coordinated delete+insert shape, and a paste smaller than the selection is net-negative. `bulkPending` (`:982`) additionally arms tail semantics off that same verdict. | **High** |
| 4 | **Marked text / CJK + emoji composition** | `setMarkedText`/`unmarkText` mutate storage repeatedly; the file's own header (`:28–31`) names marked text as a gate-bypassing system path, and `markedTextActive` (`:811`) exists precisely because these rewrite regions. Composition commits replace the marked run — net-negative when a composition shrinks. | **Medium-high** |
| 5 | **Dictation** | Named in the same header line as a gate-bypassing path; the spike exercised it (`SpikeScenarios.swift:666`). Dictation revises previously-inserted text, i.e. replacements. | **Medium** |
| 6 | **`MobileMarkdownActs.inputReplace`** (`:53–69`) | Arms via `gateAllows`, then calls `deleteBackward()`/`insertText()` — a *second* consult that may re-arm with a different range, or (at the document start) a `deleteBackward` that does nothing and leaves the arming. Reaches ⏎-exit-list, ⏎-outdent, Tab, and the checkbox toggle. | **Medium** |
| 7 | **`handleReturnKey` `.continueList`** (`:180–187`) | Arms, calls `ordinary()`, early-returns without clearing if the newline did not land. | **Low-medium** |
| 8 | **UIKit undo (`textView.undoManager`)** | An undo of a coalesced edit replays it as one storage transaction with no gate call at all → `fallbackVerdict`, which §3a proves is safe *unless the index is already wrong*. Several sites call `undoManager?.removeAllActions()` (`:564`, `:593`, `:926`, `:1276`) exactly because stale entries replay at stale offsets — the gaps between those calls are where this lives. | **Low** |
| 9 | **Drag-and-drop into the text view** | UITextView's drop is a coordinated replace; unexamined on this surface. | **Low / [UNKNOWN]** |
| 10 | **The structural doors** (`MobileStructural.swift`, takes flip, comments) | These write through `programmaticReplace` under `suppressEditProcessing` (`:1330–1347`) and rebuild the index themselves — but note `:997` returns **before** clearing `pendingVerdict`, so they can *step over* a stale arming and hand it to the next real keystroke together with a changed index. That is M2×M3 composed. | **Low, but it is the compound that explains "frequently"** |
| 11 | **Find** (`isFindInteractionEnabled`, `:605`) | Find-only; `supportsTextReplacement: false` (`:728`) closes the replace road structurally and deliberately. **Not a path today** — recorded so the fence is not removed later without re-reading this. | **None today** |

---

## 9. The Mac verdict

**The same class is LATENT on the Mac. It is not structurally prevented — it is merely
un-triggered.** [PROVEN by reading]

`BlockRangeIndex` is shared (`App/Variorum/Shared/EditorBrain/`), and
`EditorViewModel.storageDidEdit` (`:930–975`) is the *same* two-source shape, line for
line:

```swift
938        let verdict = pendingVerdict ?? fallbackVerdict(editedRange: editedRange, delta: delta)
939        pendingVerdict = nil
...
942            index.applyBlockEdit(at: i, lengthDelta: delta)
...
946            index.applyTailEdit(lengthDelta: delta)
```

No range check, no document-length check, no expiry — and its `pendingVerdict` is likewise
a bare `Verdict?` (`:232`) with the same `suppressEditProcessing`-returns-before-clearing
shape at `:937`.

**Why the Mac has not crashed here** — three accidents, not a design:

1. **AppKit's contract is closer to 1:1 for typing.** `NSTextView` consults
   `shouldChangeTextInRange:replacementString:` and then performs one
   `replaceCharacters` per approved change. There is no `_UIKeyboardStateManager`
   delete-and-reinsert composite on the delete key.
2. **Cross-block spans are answered, not merely refused.** `shouldChangeText`
   (`:836–909`) returns `false` for every cross-block range and re-drives the intent as a
   compound (`planEmptyBlockDeletion` / `planSeamMerge` / `planWholeBlockDeletion` /
   `planCrossBlockEdit` / `planVisibleTakeEdit`) through Operations plus a re-render. The
   dangerous range never becomes an unpoliced storage edit.
3. **The one AppKit road that *does* coalesce was found and fenced.** `EditorFind`'s M1/M1b
   (§3c) measured it, and the file's whole existence is the workaround — it answers the
   system finder `NO` and re-drives per match. `EditorFind.swift:544` even re-consults
   `shouldChangeText` immediately before each `replaceCharacters`, which is the 1:1
   discipline written out by hand.

**Where the Mac's exposure is real:**

- `EditorView.swift:561–571` implements `shouldChangeTextInRanges:` — the **batched**
  multi-range gate M1 measured. Whatever single verdict that arms describes at most one of
  N ranges, while the coalesced report carries the net. `isFindReplacing` guards the find
  road specifically; any *other* AppKit client of the multi-range gate is unguarded.
- `MarkdownActs.apply` (`:200`), `toggleCheckbox` (`:246`),
  `insertNewlineContinuingLists` (`:306`) and `deleteWithoutNewline` (`:318`) each arm and
  then immediately `replaceCharacters` — 1:1 **today**, and one refactor away from not
  being.
- The Mac's `desyncRecovery` (`:1006`) has the identical Release/Debug asymmetry, so on
  the Mac too the honest road is already the cheap one.

**Recommendation:** §6 Parts 1–3 land on **both** view models in the same change.
Part 1 is a shared-file edit and would break the Mac's build if applied alone; the Mac's
Part 2 is four lines; the Mac's Part 3 additionally hardens the multi-range gate against
the class its own file already documents. Per `notes/MobileSoul.md` §3 (brains in the
shared/core layer, faces per platform), a shared brain gaining a guard is exactly the
place both platforms should collect at once — and this one is a shared brain whose
*crash* has now been observed on one of them.

---

## 10. Index — the brief's seven questions

1. **What makes each precondition false?** §1b (proven trap identities), §3a (the closed
   arithmetic), §3b, §5. `applyBlockEdit`: a `.block(i)` verdict armed by a gate call for a
   sub-range while the report carried the net delta of a wider coalesced deletion.
   `applyTailEdit`: **`tailLength` was NOT nil** — the crash is line 347, the negative-length
   arm — same mechanism against the tail region.
2. **Is `pendingVerdict` bound to the edit that lands?** **No.** §2 (the code shape,
   proven), §3c (M1/M2/M3), §6 Part 3 (the binding). It carries an identity only; nothing
   expires it; `suppressEditProcessing` steps over it without consuming it. Frames 12–13's
   decomposition is **verified as a stack fact and as an in-repo measured class on AppKit**
   (§3c's M1b quote); the precise iOS decomposition is **SUSPECTED** and E1 settles it.
3. **What does `verdict()` return for a boundary-spanning / tail-ending selection?** §3d.
   `.refuse(.crossesBlockBoundary)` for the spanning case; `.tail` for a span fully inside
   `tailRange`. The refuse path exists and is reachable and speaks — it did not fire
   because the gate was not asked about the full span.
4. **Is `fallbackVerdict` implicated?** **No — it is the safe road.** §3a proves its
   arithmetic is exactly right for a pure deletion (`editedRange.length == 0`,
   `oldRange.length == −delta`) and that it cannot produce either trap. §5 shows it would
   have produced the *correct* refusal for her gesture.
5. **Where is the honest refusal road, and why was it skipped?** §6, and §1c for why it is
   already free in her build: `desyncRecovery()` is inert-and-safe in Release; the
   `precondition` fires one instruction before it can be reached.
6. **Every other input path with an unvalidated delta.** §8, ranked, all closed by §6
   Part 2.
7. **The Mac verdict.** §9 — latent, not prevented; fix both.

---

## Confidence

**The trap identities: certain** (symbolicated, disassembled, byte-verified against the
crash reports' own instruction streams, and against a binary proven to be built from
today's source).

**The mechanism class — a verdict not bound to the edit that consumes it: proven**, by the
closed arithmetic argument in §3a plus the plain code shape in §2. There is no other way
in.

**The specific arming source (M1, the coalesced delete+reinsert): high confidence, not
proven.** It fits every frame, both trap identities under one gesture, her described
trigger, and the repo's own measurement of the same class on the other platform. E1
settles it in half an hour, and the fix does not wait on it.
