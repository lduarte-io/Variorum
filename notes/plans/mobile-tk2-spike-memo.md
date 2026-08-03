# Mobile Stage 0 — TK2-on-iOS spike memo

**Status: PENDING THE ARCHITECT'S RULING** (the Stage 0 gate — per the
execution plan's stage table: "Decision memo — the architect rules; any red
flag goes to the author").

**Environment (per-point-release scope — all numbers below are void on any
other OS/SDK until re-verified, per TEXTKIT2_NOTES §5):** iOS **26.2
(23C54)** on the **iPhone 17 Pro simulator** (`iPhone18,1`, runtime 26.2,
*[removed for publication]*
Swift 6.2.4 · host macOS 26.5.2 (25F84), the author's M3 · Debug build
(unoptimized — release only improves). Corpus: deterministic seeded
generator (the Mac spike's shape): **50,058 words / 823 blocks / 329,309
UTF-16 chars** (and a 200,005-word / 3,661-block variant), mixed paragraph
lengths with three ~2,000-word giants and markdown headings, **a block-ID
custom attribute on every paragraph range**. Two evidence channels, both
re-runnable: the in-process auto-run (`TK2SPIKE_AUTORUN=1`, full log in the
appendix below) and the real-touch XCUITest suite (`TK2SpikeUITests`
scheme, five tests, all green 2026-08-03) whose synthesized touches run the
genuine iOS gesture/input pipeline. Spike code: `App/Variorum/
VariorumMobile/Spike/` + `VariorumMobileUITests/TK2SpikeUITests.swift` +
the `TK2SpikeUITests` scheme — all THROWAWAY, deleted at stage close.

---

## Item 1 — TK2 opt-in + the downgrade-canary story

**Measured:** `UITextView(usingTextLayoutManager: true)` (iOS 16+) yields a
non-nil `textLayoutManager`; **zero fallbacks under the whole exercised
inventory** — typing bursts at start/middle/end, textStorage attribute
add/remove on visible + offscreen paragraphs, **rendering attributes set +
invalidate (no crash, no fallback)**, an 11-jump selection sweep (avg
0.02 ms), `setMarkedText`×2 + `unmarkText`, `UITextInput
replace(_:withText:)`, autocorrection/spell-checking trait toggles, a
2k-word attributed paste mid-document (0.1 ms), undo, and
isEditable/isSelectable toggles. Not exercised (out of product scope, same
as the Mac spike): NSTextList/lists, Writing Tools, custom caret.

**The iOS asymmetry (Apple-docs lookup, 2026-08-03):** UIKit has **NO
analog of AppKit's `willSwitchToNSLayoutManager` notifications** — no
public notification, no delegate callback. The only public signal is
`textLayoutManager` reading nil (TK1 "compatibility mode", permanent for
the instance). The known debug aid is a breakpoint on the private symbol
`_UITextViewEnablingCompatibilityMode` — usable in a dev session, never in
a shipped canary.

**Positive control (the honest half a poll canary needs):** deliberately
accessing `.layoutManager` on a scratch TK2 view returned a non-nil
NSLayoutManager and **`textLayoutManager` went nil immediately —
`pollCanaryDetects=YES`**. The downgrade trigger is real on iOS 26.2 and
the poll detects it synchronously at the next checkpoint.

**Verdict: ADOPT** — TK2-explicit construction + a **checkpoint canary**
(assert `textLayoutManager != nil` after editor-shaped mutations and on a
low-frequency idle tick; debug = hard assert, release = os_log fault + a
visible diagnostic, the Mac's accepted posture). Weaker than the Mac's
notification pair by necessity; recorded as the standing platform gap.
Silence must be re-earned per point release by re-running the inventory.

## Item 2 — 50k-word scale (typing · scroll · height · scroll-to-location)

**Load:** `setAttributedText` 1.2 ms; first viewport layout 0.7 ms.

**Height estimation:** initial `usageBoundsForTextContainer` = 139,320 px;
no revision at rest; **settled (true) height 160,424 px → the resting
estimate is 13.2% low** (worse than the Mac's 6.8%; same shape). Walking to
the end in 249 viewport steps: **223 estimate revisions, max single
revision 7,594 px** — and **`UITextView.contentSize` tracks `usageBounds`
1:1** (223 contentSize revisions), so the scrollbar breathes exactly as on
the Mac. **Content never moved backward: 0 regression steps** (top-block
monotonicity held the whole walk). At 200k words: identical shape (972
revisions, 13.6% low, 0 regressions).

**Scroll-to-end:** reachable warm (last line visible after the walk) and
**cold — 8.6 ms, 1 iteration, last line visible, 8 px residual** (25.3 ms /
3 iterations at 200k). The §2 "can't scroll to the end" report did not
reproduce on iOS 26.2.

**Scroll-to-location (the jump table, 5 positions × 3 reps, cold view per
rep):**

| Strategy | Landing error (max) | Time | Verdict |
|---|---|---|---|
| A — proportional offset | 694 px / 5 blocks (2,641 px / 17 blocks @200k) | avg 8.6 ms | first guess only |
| **C — bounded hybrid** (proportional + `ensuresLayout` on the ONE target fragment + offset correction) | **0.0 px / 0 blocks; post-settle drift 0.0 px** | avg 8.8 ms, p95 15.6 ms, ≤1 iteration (avg 19.9 ms @200k, still 0-error) | **THE primitive** |

**The Mac's hybrid primitive works verbatim on iOS** — pixel-exact, ≤1
correction, flat-shaped in document size. (`relocateViewport(to:)` was not
re-litigated: the Mac spike measured its mechanism broken inside a
scroll-view-hosted text view, and UITextView IS a UIScrollView — the
hybrid needs no undocumented API.)

**Typing latency (120-keystroke bursts, `insertText` + forced viewport
layout, cold view, attributes present):**

| Position | 50k words | after 5k paste (55k) | 200k words |
|---|---|---|---|
| start | avg 0.74 ms (p95 0.84) | — | avg 0.70 ms (p95 0.81) |
| middle | avg 2.54 ms (p95 2.68) | avg 3.56 ms (p95 4.01) | avg 0.63 ms (p95 0.70) |
| end | avg 0.55 ms (p95 0.58) | — | avg 0.54 ms (p95 0.58) |

Flat in document size (200k ≤ 50k everywhere); worst single sample 7.06 ms
— inside even ProMotion's 8.3 ms frame. The 50k "middle" sits amid the
giant-paragraph cluster (viewport holds ~2,000-word paragraphs), which is
the honest worst case, and it still averages 2.5–3.6 ms. 5k-word paste:
3.2 ms (10.4 ms @200k).

**Reference (the P1-banned door):** `ensureLayout(documentRange)` = 68.4 ms
@50k → 260.2 ms @200k — linear in document size, banned from user paths by
P1 exactly as on the Mac.

**Verdict: ADOPT live TK2 geometry on iOS** — continuous editor, long
scroll, and the jump primitive, all on the Mac memo's terms: estimates
converge (13% low at rest, cosmetic thumb-breathing), content is monotonic,
the end is reachable, the hybrid jump is exact, typing is flat. Same
obligations as the Mac (never px-anchor a scroll restore; re-run per point
release).

## Item 3 — block-ID attribute survival under iOS-native mutations ⚠ THE HEADLINE

**Measured (in-process UITextInput primitives, small corpus, fresh view per
case):**

| Case | Mechanism | Result |
|---|---|---|
| P | `insertText("inserted ")` mid-block (predictive-acceptance shape) | **GAP** — inserted 9 chars carry NO block ID |
| B | `insertText` at a block START (seam) | inserted text got **MISSING** (not the neighbor's ID — no bleed, just absence) |
| M | `setMarkedText`×2 + `unmarkText` (multi-stage input) | marked text MISSING while marked; **GAP** after commit |
| M2 | marked text replaced by `insertText` (QWERTY candidate accept) | **GAP** |
| R | `replace(_:withText:)` over a word (autocorrect's mechanism) | **GAP** |
| D | batch `insertText` (dictation proxy — `UIDictationPhrase` is not publicly constructible) | **GAP** |

**Root cause, measured:** `typingAttributes` at a mid-block caret carries
only `NSColor` + `NSFont` — **UIKit strips custom keys from typing
attributes on iOS** (`carryCustomKeyAtMidBlockCaret=NO`). This confirms the
community report (tannr.com 2022, autocorrect dropping custom attributes)
and generalizes it: on iOS 26.2 **every insertion path loses custom
attributes**, not just autocorrect replacements.

**Confirmed through the REAL pipeline (XCUITest, software keyboard visible,
height 379 px):** typing "I like teh " through the genuine keyboard landed
11 single-character storage edits — **every one MISSING the block ID**.
Real autocorrect itself could not be provoked (`typeText` synthesizes key
events that bypass the touch-prediction layer; "teh " was not corrected) —
the definitive live-autocorrect observation is a **device item for Stage
1's feel round**, but its mechanism (`replace(_:withText:)`) is measured
above and GAPs like everything else.

**The repair is trivial:** re-stamping the mutated paragraph's block ID is
**0.039 ms for a 508-char paragraph** — O(edited paragraph), never O(doc).

**Verdict: ADOPT WITH A DESIGN CONSEQUENCE — attribute inheritance is NOT
an identity mechanism on iOS.** No drift/bleed was ever observed (a
neighbor's ID never leaked); the failure mode is pure, detectable ABSENCE
at the edit site. Stage 1's continuous editor must treat attributes as a
**derived projection re-stamped from `BlockRangeIndex` after every edit**
(the edit-range delta arrives via `textViewDidChange`/storage-delegate
callbacks; repair cost measured trivial), never as the identity store the
Mac's typing-inheritance lets it lean on. This is exactly the "identity
risk the Mac never had" the brief named — real, measured, and cheaply
repairable. The store stays safe regardless (operations validate against
the DB, not the text view — AppSpec §15 risk 1).

## Item 4 — the M5 horizontal pan + peek overlay

**In-process:** fragment rects for the fanned block resolve in 0.03 ms;
peek overlay flips (an opaque view over the block's fragment-rect union —
overlays, never rendering attributes, per P-8) cost 0.24–0.53 ms; **storage
fingerprint identical before/after every flip (`storageUntouched=YES`)** —
the peek is provably display-only.

**Real touches (XCUITest, all green):** a horizontal drag across the fanned
block **flips the peek both ways**; the same drag on a NON-fanned block
does nothing (fragment-rect scoping holds under real gesture routing); a
vertical swipe **scrolls without peeking** (the `shouldBegin`
horizontal-dominance gate + never-simultaneous-with-scroll-pan
configuration works against the live UIScrollView pan);
**double-tap selection and the edit menu still work with the pan
installed** (the edit-menu test selects by double-tap and the menu
presents). Loupe/caret-drag FEEL under the pan is not machine-assertable —
a device item for the Stage 2 feel round.

**Verdict: ADOPT** — a delegate-gated `UIPanGestureRecognizer` scoped by
fragment rects coexists with selection and scroll on iOS 26.2, and the
peek-overlay pattern gives M5/M6/M9's swipe-peek with zero storage writes.

## Item 5 — custom block items on the edit menu (the M2 door)

**Mechanism:** `UITextViewDelegate.textView(_:editMenuForTextIn:
suggestedActions:)` (iOS 16+) returning `UIMenu(children: suggested +
custom)`. Never a second `UIEditMenuInteraction` — UITextView owns one
(community-confirmed conflict source). **Real presentation proven:**
double-tap selection presented the menu, the custom **"Block Takes"** item
was present, tapping it fired its action with the right block resolved
(the delegate receives the range; the block ID reads off the storage).
Delegate calls and ranges recorded per presentation.

**Lookup flag for the roadmap:** the delegate method carries a
**"Deprecated: iOS 27.0"** annotation in current docs — it is THE
documented iOS 26 mechanism and ships fine, but Stage 1 should isolate the
door behind one seam so the iOS 27-era successor API is a one-file swap.

**Verdict: ADOPT** (with the seam note above).

## Item 6 — keyboard avoidance/reflow with a bottom accessory bar

**Measured:** `inputAccessoryView` (a 44 pt toolbar) rides the keyboard and
reaches the window on focus; keyboard notifications fire with honest
frames (accessory-only h=44 when the software keyboard is absent; real
keyboard h=294–379 in the XCUITest runs); `keyboardLayoutGuide` tracks;
**UITextView does NOT auto-adjust its `contentInset` for the keyboard**
(`autoAdjusted=NO` — confirming the community consensus; avoidance is the
app's job, `keyboardLayoutGuide` being Apple's current pattern). The caret
stayed visible in the exercised case. Simulator caveat recorded honestly:
headless `simctl` runs kept the hardware-keyboard connection (no software
keyboard); the XCUITest runs brought the real keyboard up.

**Verdict: ADOPT with explicit avoidance** — Stage 1 wires the Write
surface's bottom edge to `keyboardLayoutGuide` (or inset-adjusts off the
notifications) and gives the M11 toolbar the accessory-bar home; nothing
here needs invention, only the known wiring.

---

## Overall recommendation (for the architect's ruling)

**ADOPT TK2-on-iOS for the M1 Write-true editor — every inventory item
passed or resolved into a bounded, named obligation.** No fallback under
the editor-shaped inventory; the Mac's geometry conclusions transfer
(convergent estimates, monotonic content, exact hybrid jumps, flat typing);
the M5/M2 interaction mechanics work under real touches; the keyboard story
is known wiring. **The one architecture-shaping finding is item 3:** iOS
strips custom attributes from every insertion path, so Stage 1's identity
design must re-stamp block-ID attributes from the shared identity core
after every edit (measured at ~0.04 ms/paragraph — noise) rather than
trusting inheritance. **Red flags for the author: none** — nothing here
threatens the settled shape; item 3 changes an implementation mechanism,
not a capability or a product behavior.

**Stage 1 obligations handed over (measured, not speculative):**
1. **Attributes are projection, not truth** — re-stamp from
   `BlockRangeIndex` after every edit; add a DEBUG audit asserting no
   MISSING runs after reconciliation (the GAP class is cheap to detect).
2. **Checkpoint canary** from the first editor commit (no notification
   exists on iOS): assert-after-mutation + idle tick; debug asserts,
   release logs + visible diagnostic.
3. **Never px-anchor scroll restoration** (estimates revise ~13% — restore
   by text location via the hybrid primitive, the Mac's obligation
   verbatim).
4. **Keyboard avoidance is explicit** (`keyboardLayoutGuide`), the M11 bar
   is an `inputAccessoryView`.
5. **Edit-menu door behind one seam** (the iOS 27 deprecation note).
6. **Device items** (not simulator-answerable): live autocorrect/dictation
   observation in the feel round; loupe/caret-drag feel under the pan.
7. **Re-run the spike after every iOS point update** before trusting an
   editor milestone (TEXTKIT2_NOTES §5 discipline; the auto-run is the
   executable form).

**Caveats on all numbers:** Debug build; simulator (real-device numbers
land with Stage 1's device round — simulator TK2 geometry has matched
device behavior historically, but the §5 discipline applies); programmatic
one-shot scrolling (no momentum phases); the typing probe times
`insertText` + viewport layout and excludes draw (viewport-proportional by
construction; the feel round covers keystroke-to-glass); single point
release (26.2).

---

## Appendix — the definitive in-process run (2026-08-03, verbatim)

```
TK2SPIKE|0.env|os=iOS 26.2|model=iPhone
TK2SPIKE|0.env|osVersion=Version 26.2 (Build 23C54)
TK2SPIKE|0.env|simulator=iPhone18,1|runtime=26.2
TK2SPIKE|1.begin|fallback trigger inventory (checkpoint canary after every action)
TK2SPIKE|1.action|typing burst @start|tk2Alive=YES
TK2SPIKE|1.action|typing burst @middle|tk2Alive=YES
TK2SPIKE|1.action|typing burst @end|tk2Alive=YES
TK2SPIKE|1.action|textStorage attribute add/remove (visible + offscreen)|tk2Alive=YES
TK2SPIKE|1.action|rendering attributes set + invalidate|tk2Alive=YES
TK2SPIKE|1.selectionSweep|avg=0.02ms p95=0.06ms max=0.06ms
TK2SPIKE|1.action|selection sweep (11 far jumps)|tk2Alive=YES
TK2SPIKE|1.action|setMarkedText x2 + unmarkText|tk2Alive=YES
TK2SPIKE|1.action|UITextInput replace(_:withText:)|tk2Alive=YES
TK2SPIKE|1.action|autocorrection/spellChecking trait toggles|tk2Alive=YES
TK2SPIKE|1.paste2k|0.1ms
TK2SPIKE|1.action|2k-word attributed paste mid-document|tk2Alive=YES
TK2SPIKE|1.action|undoManager undo x1|tk2Alive=YES
TK2SPIKE|1.action|isEditable/isSelectable toggles|tk2Alive=YES
TK2SPIKE|1.inventory|done|fallback=NONE under exercised inventory
TK2SPIKE|1.notExercised|NSTextList/lists, Writing Tools, custom caret (out of product scope — same as Mac spike)
TK2SPIKE|1.positiveControl|tk2Before=YES|layoutManagerReturned=nonnil|tk2After=NO|pollCanaryDetects=YES
TK2SPIKE|2.begin|scale=50000|blocks=823|words=50058|utf16=329309
TK2SPIKE|2.load|setAttributedText=1.2ms|firstViewportLayout=0.7ms
TK2SPIKE|2.estimate|initialUsage=139320px|restUsage=139320px|initialContentSize=139337px|restContentSize=139337px
TK2SPIKE|2.walk|steps=249|usageRevisions=223|maxUsageDelta=7594px|contentSizeRevisions=223|contentRegressions=0|settledHeight=160424px
TK2SPIKE|2.estimateError|initialVsSettled=13.2%|restVsSettled=13.2%
TK2SPIKE|2.endAfterWalk|lastFragMaxY=160424|visibleTop=159748|lastLineVisible=YES
TK2SPIKE|2.coldScrollToEnd|8.6ms|iterations=1|lastLineVisible=YES|residual=8.0px
TK2SPIKE|2.jumps.begin|scale=50000
TK2SPIKE|2.jump.A|n=15|avg=8.60ms p95=13.56ms max=13.56ms|maxErrorPX=694.3|maxErrorBlocks=5|maxPostSettleDrift=0.0px|maxIterations=0
TK2SPIKE|2.jump.C|n=15|avg=8.82ms p95=15.61ms max=15.61ms|maxErrorPX=0.0|maxErrorBlocks=0|maxPostSettleDrift=0.0px|maxIterations=1
TK2SPIKE|2.typing.begin|scale=50000
TK2SPIKE|2.typing.start|n=120|avg=0.74ms p95=0.84ms max=1.45ms
TK2SPIKE|2.typing.middle|n=120|avg=2.54ms p95=2.68ms max=3.83ms
TK2SPIKE|2.typing.end|n=120|avg=0.55ms p95=0.58ms max=1.30ms
TK2SPIKE|2.typing.paste5k|3.2ms
TK2SPIKE|2.typing.middleAfterPaste|n=120|avg=3.56ms p95=4.01ms max=6.10ms
TK2SPIKE|6.keyboard|WillHide@h=0|frame=(0.0, 874.0, 402.0, 0.0)
TK2SPIKE|6.keyboard|WillHide@h=0|frame=(0.0, 874.0, 402.0, 0.0)
TK2SPIKE|2.ensureLayoutReference|scale=50000|68.4ms|trueHeight=160424px
TK2SPIKE|3.begin|attribute survival (programmatic UITextInput primitives; the REAL keyboard pipeline is the UITest's half)
TK2SPIKE|3.typingAttributes|carryCustomKeyAtMidBlockCaret=NO|keys=NSColor,NSFont
TK2SPIKE|3.case|P.insertText-word+space|GAP|runs=[312,+20:1][332,+9:MISSING][341,+479:1]
TK2SPIKE|3.restampRepair|0.039ms|len=508|verdict=INTACT
TK2SPIKE|3.case|B.insertText-at-block-start|insertedTextGotID=MISSING|expectedOwn=2|prev=1
TK2SPIKE|3.case|M.marked-mid|whileMarked=[332,+5:MISSING]
TK2SPIKE|3.case|M.marked-committed|GAP|runs=[312,+20:1][332,+5:MISSING][337,+479:1]
TK2SPIKE|3.case|M2.marked-then-insertText|GAP|runs=[312,+20:1][332,+6:MISSING][338,+479:1]
TK2SPIKE|3.case|R.replace-word|GAP|runs=[312,+4:1][316,+5:MISSING][321,+490:1]
TK2SPIKE|3.case|D.dictation-proxy-batch-insert|GAP|runs=[976,+10:3][986,+32:MISSING][1018,+508:3]
TK2SPIKE|4.begin|fragment-rect scoping + peek overlay (in-process half; real touches are the UITest's)
TK2SPIKE|4.rects|count=1|0.03ms|union={{5, 448}, {390.0703125, 154}}
TK2SPIKE|4.peekFlips|flip1=0.27ms|flip2=0.53ms|back=0.24ms|storageUntouched=YES
TK2SPIKE|6.begin|keyboard avoidance + accessory bar
TK2SPIKE|6.keyboard|WillShow@h=44|frame=(0.0, 830.0, 402.0, 44.0)
TK2SPIKE|6.keyboard|DidShow@h=44|frame=(0.0, 830.0, 402.0, 44.0)
TK2SPIKE|6.show|becameFirstResponder=true|events=WillHide@h=0,WillHide@h=0,WillShow@h=44,DidShow@h=44
TK2SPIKE|6.frames|keyboard={{0, 830}, {402, 44}}|layoutGuide={{0, 724}, {402, 34}}|accessoryBarInWindow=YES
TK2SPIKE|6.avoidance|contentInsetBottomBefore=0.0|after=0.0|autoAdjusted=NO|caretVisible=YES
TK2SPIKE|6.keyboard|WillHide@h=44|frame=(0.0, 918.0, 402.0, 44.0)
TK2SPIKE|6.hide|events=WillHide@h=0,WillHide@h=0,WillShow@h=44,DidShow@h=44,WillHide@h=44
TK2SPIKE|2.begin|scale=200000|blocks=3661|words=200005|utf16=1315256
TK2SPIKE|2.load|setAttributedText=1.8ms|firstViewportLayout=0.7ms
TK2SPIKE|2.estimate|initialUsage=555741px|restUsage=555741px|initialContentSize=555757px|restContentSize=555757px
TK2SPIKE|2.walk|steps=998|usageRevisions=972|maxUsageDelta=25050px|contentSizeRevisions=972|contentRegressions=0|settledHeight=643082px
TK2SPIKE|2.estimateError|initialVsSettled=13.6%|restVsSettled=13.6%
TK2SPIKE|2.endAfterWalk|lastFragMaxY=643082|visibleTop=642406|lastLineVisible=YES
TK2SPIKE|2.coldScrollToEnd|25.3ms|iterations=3|lastLineVisible=YES|residual=8.0px
TK2SPIKE|2.typing.begin|scale=200000
TK2SPIKE|2.typing.start|n=120|avg=0.70ms p95=0.81ms max=1.25ms
TK2SPIKE|2.typing.middle|n=120|avg=0.63ms p95=0.70ms max=1.16ms
TK2SPIKE|2.typing.end|n=120|avg=0.54ms p95=0.58ms max=0.64ms
TK2SPIKE|2.typing.paste5k|10.4ms
TK2SPIKE|2.typing.middleAfterPaste|n=120|avg=5.84ms p95=6.45ms max=7.06ms
TK2SPIKE|6.keyboard|WillHide@h=233|frame=(0.0, 874.0, 402.0, 233.0)
TK2SPIKE|6.keyboard|WillHide@h=0|frame=(0.0, 874.0, 402.0, 0.0)
TK2SPIKE|2.jumps.begin|scale=200000
TK2SPIKE|2.jump.A|n=3|avg=16.49ms p95=20.55ms max=20.55ms|maxErrorPX=2641.3|maxErrorBlocks=17|maxPostSettleDrift=0.0px|maxIterations=0
TK2SPIKE|2.jump.C|n=3|avg=19.94ms p95=23.24ms max=23.24ms|maxErrorPX=0.0|maxErrorBlocks=0|maxPostSettleDrift=0.0px|maxIterations=1
TK2SPIKE|2.ensureLayoutReference|scale=200000|260.2ms|trueHeight=643082px
TK2SPIKE|DONE
```

**Real-touch UITest evidence (same day, five tests green, 63.5 s):**
`testHorizontalSwipeOnFannedBlockPeeks` (peek 0→1→0 through real drags) ·
`testHorizontalSwipeOutsideFannedBlockDoesNotPeek` (scoping holds) ·
`testVerticalSwipeScrollsWithoutPeeking` (offset changed, peek=0) ·
`testEditMenuCarriesCustomBlockItems` ("Block Takes" present on the real
menu, tapped, action fired) · `testRealTypingPipelineAndKeyboard`
(software keyboard h=379; 11 typed chars each `runs=[N,+1:MISSING]`;
autocorrect not provokable via key-event typing — device item). App-side
log lines from these runs are in `Documents/tk2spike-results.log` on the
simulator (appended after the in-process run above).
