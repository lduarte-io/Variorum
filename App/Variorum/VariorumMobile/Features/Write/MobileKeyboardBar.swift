//
//  MobileKeyboardBar.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 2 (scope item 5) — the keyboard bar's live acts:
//  **B · I · # · • · ☑ · ⇥ · ⑂** (LK8's ruled eight MINUS ⋯, whose block
//  menu is S4's — a door that can never act in its context isn't
//  rendered, P-2; recorded as the application of LK8, not a deviation).
//  ⑂ JOINED as the seventh act at S2 batch 2, WITH its surface (the takes
//  browser): it opens the browser on the caret's block, refusing honestly
//  in the open tail. Extracted from the batch-1 shell in
//  `MobileEditorTextView.swift`; the bar itself is still the measured
//  `inputAccessoryView` home (spike item 6) — the look canon (L13)
//  restyles it.
//
//  Every act fires `MobileMarkdownActs` — the ordinary policed input path,
//  never a second brain (P-1: the acts' law is the shared
//  `MarkdownEditing`; this file only renders doors).
//
//  ⇥ carries BOTH directions (batch 2 — the software keyboard has no Tab
//  key at all, so the bar's ⇥ IS the phone's Tab): tap = indent,
//  long-press = outdent. Hardware Tab/⇧Tab ride the text view's key
//  commands; ⏎-on-an-empty-nested-item outdents too (K8's rule).
//
//  **⇤ IS ITS OWN VISIBLE DOOR since round 2 (M26 ≡ R21 — HER RULING:
//  *"i think an indent to the left button should be added to the set of
//  formatting buttons though - there's an indent in but not an
//  un-indent"*).** The batch-2 PROVISIONAL ("⇥ carries both directions")
//  is SUPERSEDED as the *only* visible door: outdent existed, was tested,
//  was documented — and the door did not reach her, because a long-press
//  is invisible and a VoiceOver hint is not an affordance for sighted
//  use. The long-press STAYS (four doors cost nothing and break no
//  muscle memory) and the ACT is byte-unchanged — `MarkdownEditing`'s
//  `.outdent`, the one shared brain, fired by the same `fireOutdent`.
//  **A DOOR change, never vocabulary.**
//

import UIKit
import VariorumCore

@MainActor
final class MobileKeyboardBarController: NSObject {
    private weak var textView: MobileEditorTextView?
    /// The LIVE toolbar (weak — the view owns it as its accessory), so
    /// the Aa door can swap its items IN PLACE.
    private weak var bar: UIToolbar?

    /// **The last real bar width this controller has BUILT AT — held
    /// strongly, precisely because `bar` is not.**
    ///
    /// Without it the strip's width had a hidden precondition at a call
    /// site no pin drove (4.5d's cold review): `makeBar()` read the
    /// OUTGOING bar's width, which survives only because
    /// `applyVoiceChrome` writes `inputAccessoryView =
    /// keyboardBarController.makeBar()` — evaluating the new bar while the
    /// old one is still assigned and therefore still retained. **A caller
    /// that tidied up first (`inputAccessoryView = nil;
    /// inputAccessoryView = makeBar()`) would release the outgoing bar,
    /// nil this weak reference, and rebuild an OPEN strip at 23 pt on a
    /// 402 pt phone — sticky until the next Aa toggle**, from a mechanism
    /// nobody would look at again. A remembered width cannot be nilled by
    /// a caller's assignment order.
    ///
    /// It can only ever be *stale*, never wrong-and-wider: it came from a
    /// toolbar that really was that wide, and a running app's bar width
    /// cannot change (portrait-locked iPhone; Display Zoom restarts the
    /// device). Zero until the first real bar is seen.
    private var lastBuiltBarWidth: CGFloat = 0

    /// **The Aa condensation (parity A3 item 1 — HER RULING, the
    /// architect's ADOPT of the proposed expanding row):** at rest the
    /// bar carries THREE doors — **Aa · ⑂ · ⋯** — and Aa expands the
    /// FORMATTING STRIP in place (× collapses back). A DOOR change, not
    /// a vocabulary change: the act grammar, the # cycle + P5
    /// long-press picker, and ⇥'s two directions are byte-identical —
    /// which is exactly why the door is a button strip and never a
    /// UIMenu (menu rows carry no second gesture; a menu-form Aa would
    /// amputate both ruled long-press doors).
    ///
    /// **Since round 2 the strip is ONE ROW of ELEVEN acts — × · B · I ·
    /// S · ⟨⟩ · 🔗 · # · • · ☑ · ⇥ · ⇤ (HER R22 + M26).** It was two
    /// rows from parity C4b until she ruled the one-row shape: *"agree:
    /// option 1 (one-row strip) is clearly better."* What the shape buys
    /// is VERTICAL and it is the whole point — a one-row capsule is
    /// 48 pt deep instead of 68 (see `expandedCapsuleBottomEdge`), so the
    /// resting trio and the expanded capsule now bottom out at the SAME
    /// depth, the 20 pt structural floor documented below **disappears
    /// by construction**, the bar drops 72 → 52 pt, and she gains those
    /// 20 pt back as text. The reading order is the two rows flattened
    /// unchanged, so LK8's relative order of the standing seven and
    /// C4b's after-Italic placement of strike/code/link both survive
    /// untouched, and ⇤ lands beside the ⇥ it mirrors.
    /// `formattingRowLabels` below is still the row split's truth (one
    /// row today; the machinery re-splits with no second edit). The
    /// bar is the `inputAccessoryView`, so expand/collapse happens with
    /// the keyboard up, in place; the strip RESETS TO COLLAPSED at each
    /// fresh keyboard presentation (the calm default — accepted at the
    /// ruling, hers to flip at the end sitting), via the keyboard-hide
    /// notification below.
    ///
    /// **The strip is ONE bar item, never seven (Stage A ladder FIX-5,
    /// the round-1.5 MAJOR):** as seven separate `UIBarButtonItem`s,
    /// iOS 26's circle-per-item toolbar gave every plain item a 62 pt
    /// glass cell (52 pt button + 5 pt padding each side), the two
    /// wrapped buttons 48 pt cells, and compressed the six flexible
    /// spaces to 12 pt gaps — 5×62 + 2×48 + 6×12 = **478 pt, centered
    /// in the 402 pt bar**, hanging 38 pt off EACH edge: × and ⇥
    /// rendered as edge slivers (the collapse door barely tappable, ⇥
    /// effectively invisible). The fix owns the geometry: the acts are
    /// real `UIButton`s in one `UIStackView` (`kbar.formattingStrip`)
    /// carried by a single customView item, sized so the capsule fits
    /// **the bar it is actually being built into** — see
    /// `stripButtonWidth(inBarOfWidth:)`. Overflow is impossible by
    /// construction, nothing scrolls, and nothing hides. Our own stack
    /// also lays out WINDOWLESS, which is what makes the visibility pin
    /// possible at all — the toolbar's private item cells only
    /// materialize in a window, which is exactly how the clip escaped
    /// A3's suite.
    private(set) var isFormattingExpanded = false

    /// The strip's geometry constants (pinned). The gap stays tight so
    /// the acts read as one strip.
    static let stripButtonHeight: CGFloat = 38
    static let stripSpacing: CGFloat = 2

    // MARK: - The strip's HORIZONTAL geometry (round 2 — R22 + M26)

    /// **THE 44 pt TAP-TARGET FLOOR IS GONE, and this is what it cost.**
    /// It used to be a hard constant here, with the doc comment "a 44 pt
    /// floor keeps every act a full HIG tap target". Two of her rulings
    /// arrived together and neither can hold it:
    ///
    /// - **R22** — the expanded strip becomes ONE row (the vertical win
    ///   documented on `isFormattingExpanded`), so all the acts must
    ///   share one line rather than two.
    /// - **M26 ≡ R21** — a visible ⇤ joins them, making **eleven**.
    ///
    /// Eleven 44 pt targets need 11×44 + 10×2 = **504 pt**; a 375 pt bar
    /// offers **333** (below). The arithmetic is not close, and **she
    /// ruled the shape knowing it** — she was told before choosing that
    /// eleven acts land near 31 pt, under the floor.
    ///
    /// **THE RULE, since this round's fit fix: 28 pt is a CEILING, and
    /// the strip is sized to the bar it is being built into.** An act is
    /// her 28 wherever 28 fits, and narrower only where it does not
    /// (`stripButtonWidth(inBarOfWidth:)`) — so every bar at or above
    /// `nominalBarWidth` renders byte-identically to what she has been
    /// looking at, and a **320 pt** Display-Zoom bar narrows to 23 rather
    /// than hanging two acts off the edges (`narrowestBarWidth` carries
    /// that measured clip). A WIDER bar deliberately does not get wider
    /// acts: that would be a look change on the device she uses, and the
    /// look is hers.
    ///
    /// Where the 28 comes from: it is what eleven acts derive at on
    /// `nominalBarWidth`, the narrowest iPhone hardware class.
    ///
    /// *What widening would buy, RECOMPUTED against
    /// `derivedStripButtonWidth` rather than quoted from the ruling's
    /// estimate: a 402 pt bar derives **30**, so letting the acts grow
    /// with the bar would buy **2 pt** on her phone. (This paragraph read
    /// "would allow 31 … to buy 3 pt" until 4.5d's cold review recomputed
    /// it — ~31 was the estimate she was quoted at R22, and the function
    /// says 30. A file whose thesis is that duplicated derivations drift
    /// had one of its own.)*
    ///
    /// Recorded plainly rather than quietly deleted: the floor did not
    /// stop applying, it stopped being satisfiable, and the honest guard
    /// is the crowding tripwire below. **Measured on the live surface**
    /// (iPhone 17 Pro / iOS 26.2): a 30.0 pt act-to-act pitch, every act
    /// whole, and a tap at each act's centre fires that act.
    ///
    /// Note the buttons were never a full target VERTICALLY either —
    /// `stripButtonHeight` has been 38 pt since the strip existed.
    ///
    /// **THE NARROWEST WIDTH THE APP CAN BE SHOWN AT — and it is NOT a
    /// hardware class.** 320 pt is what **Display Zoom** ("Larger Text
    /// and Icons" in Display & Brightness) renders at: a 375 pt SE *and*
    /// a 390/393/402 pt modern iPhone alike report a 320 pt window when
    /// their owner turns it on. So this is an ACCESSIBILITY setting on
    /// hardware anybody may carry, never a rare old phone.
    ///
    /// **This constant exists because the round shipped a strip that
    /// overflowed here.** `nominalBarWidth` below used to be the only
    /// width in this file, documented as "the tightest supported iPhone
    /// class" — which is true of *hardware* (SE 2/3, 12 mini and 13 mini
    /// are all 375 pt on iOS 26) and false of *rendered width*. Measured
    /// on the pre-fix tree, hosted in a real window at 320 pt: the
    /// strip's glass capsule laid out **338 × 48 at x = −9**, hanging
    /// **9 pt off each edge of the bar**, with × at x = −4 and ⇤ ending
    /// at 324 — **4 pt of each outer act off-screen and both rounded
    /// capsule ends sliced.** That is FIX-5's own defect, smaller.
    static let narrowestBarWidth: CGFloat = 320

    /// The narrowest iPhone HARDWARE class (SE 2/3, 12 mini, 13 mini —
    /// all 375 pt on iOS 26), and therefore the width her ruled **28 pt**
    /// act comes from: it is what `nominalStripButtonWidth` derives at.
    /// Bars at or above it get exactly the strip she ruled.
    static let nominalBarWidth: CGFloat = 375

    /// The allowance for the iOS 26 toolbar's own content-row inset, per
    /// side — **deliberately conservative, and the two measurements that
    /// bracket it are recorded rather than averaged.** Batch 2's frame
    /// dump of the live bar read `_UIInheritedView frame=(16, 0, 370, 48)`
    /// in a 402 pt bar (16 pt a side); this batch's windowed dump on
    /// iPhone 16e / iOS 26.2 reads `(8, 0, 386, 48)` at the same width
    /// (8 pt a side), and the same 8 at 320/375/393. **The real home — an
    /// `inputAccessoryView` on a presented keyboard — could not be
    /// measured in process** (the software keyboard never presents under
    /// `xcodebuild test`, so the accessory view's `window` stays nil);
    /// recorded as a RUNTIME GAP rather than resolved by guess. 16 is
    /// kept because erring wide only ever makes the strip *narrower*
    /// than it needs to be, which cannot clip, while erring narrow
    /// clips — FIX-5's doctrine, applied to an uncertainty.
    static let toolbarContentInset: CGFloat = 16

    /// What the customView's glass cell offers inside a bar of a given
    /// width: the bar, less the content row's inset a side, less the
    /// cell's own 5 pt padding a side. At 375 that is 375−32−10 = **333**
    /// (the number this file carried as a constant); at 320 it is
    /// 320−32−10 = **278**.
    static func stripWidthAvailable(inBarOfWidth barWidth: CGFloat) -> CGFloat {
        max(0, barWidth - 2 * toolbarContentInset - 2 * stripCellInset)
    }

    /// **Each act's width is DERIVED from the act count**, not chosen:
    /// the eleven acts and their ten 2 pt gaps divide the width the bar
    /// offers, rounded down.
    ///
    /// Deriving it is what keeps FIX-5's promise honest as the act list
    /// moves: a twelfth act narrows the row instead of overflowing the
    /// bar, and the crowding tripwire below is what makes that narrowing
    /// loud instead of silent.
    ///
    /// **It is an EXACT width, not a minimum, and that is a measured
    /// correction rather than a preference.** The constraint used to be
    /// `>=` — harmless while the number was 44, because nothing here is
    /// that wide. At 28 it stopped working: a titled `UIButton(type:
    /// .system)` reports an intrinsic width of **30 pt** whatever its
    /// glyph (UIKit's own floor — measured: every titled act said 30.0
    /// while the image-titled 🔗 said 22.3), so ten acts ignored the
    /// minimum and the strip measured **348 pt against the 333 it must
    /// fit**. `>=` also could never have caught it in the other
    /// direction, which is why the pin asserts the exact width.
    static func derivedStripButtonWidth(inBarOfWidth barWidth: CGFloat) -> CGFloat {
        let count = CGFloat(formattingActLabels.count)
        guard count > 0 else { return 0 }
        let available = stripWidthAvailable(inBarOfWidth: barWidth)
        return max(0, ((available - (count - 1) * stripSpacing) / count)
            .rounded(.down))
    }

    /// **Her ruled act width: 28 pt** — eleven acts sharing the 333 pt a
    /// 375 pt bar offers (11×28 + 10×2 = 328, five to spare). She ruled
    /// the one-row shape knowing the arithmetic (R22, and R25 pre-ruled
    /// the tap targets); this is the number that ruling produced, and it
    /// is the number every bar wide enough to hold it still gets.
    static var nominalStripButtonWidth: CGFloat {
        derivedStripButtonWidth(inBarOfWidth: nominalBarWidth)
    }

    /// **THE FIT RULE — an act is her ruled 28 pt wherever 28 pt fits,
    /// and narrower only where it does not.**
    ///
    /// The `min` is the whole of it, and it is deliberately asymmetric:
    /// a bar at or above `nominalBarWidth` renders **byte-identically to
    /// before this fix** (every act 28 pt, the strip 328 pt, the capsule
    /// centred inside the content row), so nothing she has looked at
    /// changes. Only a bar too narrow for that — today only the 320 pt
    /// Display-Zoom width — narrows, to **23 pt** an act (11×23 + 10×2 =
    /// 273 inside the 278 offered). It is her ruled SHAPE either way:
    /// one row, eleven acts, every one whole and on screen, nothing
    /// scrolling and nothing hidden. Widening past 28 on a big phone is
    /// deliberately NOT done — that would be a look change on the
    /// device she uses, and the look is hers (the same reasoning the
    /// 28-vs-30 note above records).
    ///
    /// **Where `barWidth` comes from:** one resolver, `currentBarWidth()`,
    /// which both the rebuild seam and the expand seam call — it carries
    /// the reasoning about staleness and about why too-narrow is the only
    /// safe direction to be wrong in. The app is portrait-locked iPhone
    /// (MobileSoul §4's ruled exclusion), the accessory bar spans the
    /// screen with or without a hardware keyboard, and changing Display
    /// Zoom **restarts the device** (Settings warns before it does it) —
    /// so a running app's bar width cannot change underneath a presented
    /// strip.
    static func stripButtonWidth(inBarOfWidth barWidth: CGFloat) -> CGFloat {
        min(nominalStripButtonWidth, derivedStripButtonWidth(inBarOfWidth: barWidth))
    }

    /// **The crowding tripwire — the 44 pt floor's replacement, and NOT
    /// a weakening of it.** The old constant asserted a HIG target her
    /// ruling made unreachable; this one asserts that nothing may crowd
    /// the strip FURTHER without her. Eleven acts sit exactly at it; a
    /// twelfth would compute 25 pt and trip the pin, which is the point
    /// — the next act to want a place on this row costs a ruling, not a
    /// constant edit.
    ///
    /// **It guards `nominalStripButtonWidth`, i.e. the ACT COUNT, and
    /// deliberately not the per-bar width.** The narrowing a 320 pt bar
    /// produces is the fit fix doing its job (23 pt, all eleven acts on
    /// screen); a twelfth ACT is a crowding of her ruled row at every
    /// width. Pointing the tripwire at the nominal width is what keeps
    /// those two apart.
    static let stripButtonCrowdingFloor: CGFloat = 28

    // MARK: - The bar's VERTICAL geometry (round 2, batch 2 — M4 ≡ R7)

    /// **HER COMPLAINT, verbatim: *"the buttons at the bottom, the three
    /// of them, also need more generous spacing because they're kind of
    /// touching the keyboard bar, which is annoying."*** Confirmed the
    /// same sitting as the resting trio Aa · ⑂ · ⋯.
    ///
    /// **THE MECHANISM — measured twice, never guessed** (a windowed frame
    /// dump of the live toolbar, plus live-simulator captures on
    /// iPhone 17 Pro / iOS 26.2 via `xcrun simctl io booted screenshot`;
    /// evidence in the batch record):
    ///
    /// 1. **The toolbar's content row is a FIXED 48 pt, anchored at the
    ///    bar's TOP** — `_UIInheritedView frame=(16, 0, 370, 48)` at a
    ///    78 pt bar AND at a 104 pt bar. It does NOT follow the bar's
    ///    height.
    /// 2. **iOS 26 wraps each item in a glass cell laid out against that
    ///    48 pt row.** A plain item's cell measures **62 × 48 at y = 0**
    ///    (`UIPlatformGlassInteractionView`; 52 pt button + the 5 pt
    ///    inset a side — FIX-5's own horizontal numbers, now with their
    ///    vertical twin), so it runs to **48 pt below the bar's top**.
    ///    The expanded strip's cell is **284 × 88 at y = −20** — the
    ///    capsule is CENTERED on the 48 pt row, so it overhangs 20 pt
    ///    above and runs to **68 pt below the bar's top**.
    /// 3. Against the old **44 pt** resting bar the resting cells
    ///    overflowed 4 pt and the expanded capsule overflowed 24 pt —
    ///    and the keyboard draws over the overflow. That is exactly what
    ///    she saw: three circles with sliced bottoms sitting ON the
    ///    keyboard, and (worse, unreported) the formatting strip's whole
    ///    SECOND ROW — # · • · ☑ · ⇥ — half-hidden behind it.
    ///
    /// **ONE height, because the second one never reached the screen.**
    /// The bar used to carry `restingBarHeight` 44 / `expandedBarHeight`
    /// 84 and grow on expand by setting its own frame + `reloadInputViews`.
    /// That mechanism is DEAD and was proven so: with the expanded height
    /// set to **160 pt** the captured screen was pixel-for-pixel the 104 pt
    /// capture (capsule top 436.7 pt, bottom 528.3 pt, keyboard top
    /// 537.7 pt in both) — UIKit keeps an installed `inputAccessoryView`
    /// at the height it had when the keyboard presented it, and the strip
    /// resets to collapsed at every keyboard hide, so **the resting height
    /// is the only height the screen ever sees**. The old expanded pin was
    /// green over wiring that never reached a pixel — this round's own
    /// §15 trap 1. So the grow-on-expand road is retired and ONE
    /// `barHeight` serves both states, sized for the TALLER of the two
    /// cells plus air.
    ///
    /// Why the trio is not folded into one customView capsule (the FIX-5
    /// mechanism) instead: that would replace three separate circles with
    /// one capsule — a LOOK change, and the look is hers to rule. A
    /// spacing complaint is answered by spacing.
    ///
    /// **If a future iOS lays these cells out differently, re-measure**:
    /// host `makeBar()` in a `UIWindow`, dump the subview frames, and
    /// re-derive — the numbers below are observations, not contracts.
    static let contentRowHeight: CGFloat = 48
    /// A plain bar item's glass cell: 62 × 48 at y = 0 of the content row.
    static let itemCellHeight: CGFloat = 48
    /// The glass cell's inset around a customView item, per side.
    static let stripCellInset: CGFloat = 5
    /// The air below the lowest cell edge.
    ///
    /// **HER CORRECTION (round 2, §29's R12), verbatim: *"it looks like
    /// the circles are now floating slightly high above the keyboard. i
    /// think the goal should just be for them to not be cut off but
    /// only be a bit above the [keyboard]."*** The first pass's 10 pt
    /// overshot; this is 4 pt, **arrived at by capture, not by
    /// formula** — three builds photographed on iPhone 17 Pro / iOS
    /// 26.2 and compared (captures in
    /// `notes/plans/mobile-round-2-screens/r12/`):
    ///
    /// | air | bar | resting circles clear the keyboard by | expanded capsule clears by |
    /// |----:|----:|--------------------------------------:|---------------------------:|
    /// |  10 |  78 |                              31.3 pt |                    11.3 pt |
    /// |   4 |  72 |                              25.3 pt |                     5.3 pt |
    /// |   2 |  70 |                              23.3 pt |                     3.3 pt |
    ///
    /// 2 pt was **rejected**: it buys 2 pt on the resting trio — below
    /// perception — and spends it making the EXPANDED capsule graze the
    /// keyboard, which is her original complaint wearing the other
    /// state's clothes.
    ///
    /// **THE 20 pt STRUCTURAL FLOOR IS GONE — she took the road that
    /// dissolves it (R22).** While the strip was TWO rows, the resting
    /// cells ran to 48 pt below the bar's top but the capsule's 88 pt
    /// cell, CENTERED on the fixed 48 pt content row, reached 68 — so
    /// the trio inherited the capsule's depth and could never sit
    /// closer than 20 pt + air without hiding the strip's second row.
    /// One height must serve both states (M17: an installed
    /// `inputAccessoryView` keeps its presented height), and
    /// repositioning inside a taller container never escaped it — the
    /// 20 pt rode the content row, not the bar. Two roads were put to
    /// her, both LOOK changes and therefore hers: a shorter expanded
    /// capsule, or a resting trio as tall as the capsule. **She ruled
    /// the first.** A one-row strip is 38 pt, its cell 48 — exactly a
    /// plain item's — so `expandedCapsuleBottomEdge == itemCellHeight`
    /// and the two states now bottom out at the SAME depth. The floor
    /// did not shrink; it stopped existing. Measured consequence: her
    /// three circles clear the keyboard by **5.33 pt** (the clearance
    /// she already accepted for the expanded state at R12), and the bar
    /// itself drops 72 → 52, handing 20 pt back to the text.
    ///
    /// **CONFIRMED BY MEASUREMENT, not only by derivation (round 2,
    /// sub-batch 4.5d).** The claim above was computed from these
    /// constants; a windowed frame dump now backs it. Hosted at 320,
    /// 375, 393 and 402 pt, iPhone 16e / iOS 26.2: the RESTING plain
    /// cells lay out `62 × 48 at y = 0` and the EXPANDED one-row capsule
    /// lays out `48` tall **also at y = 0** — no longer the `y = −20`
    /// overhang the two-row capsule had — so both states' lowest drawn
    /// edge measures **exactly 48**, and the bar's 52 leaves the ruled
    /// 4 pt in both. `MobileKeyboardBarGeometryTests` asserts that off
    /// real frames, so a silent re-split into two rows trips it.
    ///
    /// **What DOES still bind is the 48 pt content row itself** — it is
    /// fixed and anchored at the bar's top, so no bar shorter than
    /// `48 + air` can exist without clipping. The 20 pt was a *penalty
    /// on top of* that floor, and it is the penalty that is gone.
    ///
    /// The air stays **4** — untouched by the shape change, and still
    /// the photographed value.
    static let barVerticalAir: CGFloat = 4

    /// The expanded capsule's intrinsic height, DERIVED from the row
    /// table below (a future row grows the bar with no second edit).
    static var stripFittedHeight: CGFloat {
        let rows = CGFloat(formattingRowLabels.count)
        return rows * stripButtonHeight + max(rows - 1, 0) * stripSpacing
    }

    /// How far the expanded capsule reaches below the bar's top edge:
    /// the capsule is centered on the 48 pt content row (measured
    /// y = −20 for an 88 pt capsule), so its bottom sits at
    /// `(row + capsule) / 2`.
    static var expandedCapsuleBottomEdge: CGFloat {
        (contentRowHeight + stripFittedHeight + 2 * stripCellInset) / 2
    }

    /// The lowest edge any state draws — the number the bar must clear.
    static var lowestCellEdge: CGFloat {
        max(itemCellHeight, expandedCapsuleBottomEdge)
    }

    /// **72 → 52 at her R22 ruling.** The strip grew ROWS at parity C4b
    /// (strikethrough · inline code · add link joined the capsule) —
    /// ten 44 pt acts could not share one line of any iPhone class, so
    /// the capsule went two rows deep and dragged the whole bar down
    /// with it. R22 reverses that trade: the acts share ONE row (paid
    /// for horizontally — see `stripButtonWidth(inBarOfWidth:)`, where
    /// the 44 pt target floor is spent), the capsule is a plain item's
    /// depth, and
    /// `lowestCellEdge` falls 68 → 48. The bar does NOT change height
    /// between the states — one `barHeight` hosts both, sized for the
    /// lowest cell plus air (M4 ≡ R7; the vertical-geometry block above
    /// carries the measured mechanism and why the old grow-on-expand
    /// road was retired). The resting bar stays Aa · ⑂ · ⋯,
    /// byte-untouched in its DOORS.
    static var barHeight: CGFloat { lowestCellEdge + barVerticalAir }

    /// The two states' acts, in bar order — one table per state so the
    /// bar and any test walk read the same truth (the registry-walk
    /// spirit). ⑂ = Takes (S2 batch 2); ⋯ = Block (S4 batch 1, with its
    /// block menu); Aa/× = the formatting door's two faces. The
    /// formatting labels read in STRIP ORDER (`formattingRowLabels`
    /// carries the row split — ONE row since R22, the two former rows
    /// flattened in place so LK8's relative order and C4b's
    /// after-Italic placement both survive); every act wears the
    /// capability registry's own verb, ⇤'s "Outdent" included.
    static let restingActLabels = ["Formatting", "Takes", "Block"]
    static let formattingRowLabels: [[String]] = [
        ["Hide Formatting", "Bold", "Italic", "Strikethrough", "Inline Code",
         "Add Link", "Heading", "Bullet List", "Checklist", "Indent",
         "Outdent"],
    ]
    static var formattingActLabels: [String] { formattingRowLabels.flatMap(\.self) }

    init(textView: MobileEditorTextView) {
        self.textView = textView
        super.init()
        // Reset-per-presentation (the ruling's calm default): the strip
        // collapses when the keyboard goes away, so every fresh raise
        // starts on the resting bar; within one presentation it stays
        // as left. Selector-based observers self-remove on deinit.
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    /// The accessory bar riding the keyboard (spike item 6's measured
    /// home; its height is `barHeight` — 44 pt when this comment was
    /// written, measured to 52 since M4 ≡ R7 and R22), now with its acts live — and, since batch 3, styled by the
    /// LIVE VOICE (the look canon's kbar: the voice surface with a hairline
    /// top edge, act glyphs in the muted chrome ink, mono type in the
    /// terminal voice / the system sans in study — the mockups' own chrome
    /// rule). `MobileEditorTextView.applyVoiceChrome` rebuilds it at the
    /// LK2 switch, so the values are read fresh per build. Items resolve
    /// per the Aa door's state (`barItems`).
    func makeBar() -> UIView {
        let face = MobileEditorStyle.face
        // **The starting width comes from `currentBarWidth()`**, which is
        // load-bearing rather than tidy: `applyVoiceChrome` calls this
        // method again at an LK2 voice switch, and the controller's
        // `isFormattingExpanded` survives it — so a rebuild that happens
        // while the strip is OPEN sizes the strip from this frame, and a
        // fresh bar that started at the narrowest width would silently
        // narrow her acts on a wide phone until the next toggle.
        let bar = UIToolbar(frame: CGRect(
            x: 0, y: 0, width: currentBarWidth(), height: Self.barHeight))
        bar.autoresizingMask = [.flexibleWidth]

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = face.surface
        appearance.shadowColor = face.line
        bar.standardAppearance = appearance
        bar.compactAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.tintColor = face.muted

        self.bar = bar
        bar.items = barItems(face: face)
        return bar
    }

    /// **THE ONE PLACE the strip's width is resolved** — and it remembers.
    ///
    /// Both seams that build a strip need this number, and until 4.5d's
    /// cold review they each spelled it out separately, in a file whose
    /// whole thesis is that duplicated derivations drift.
    ///
    /// The order is narrowest-is-safe, because **too wide is the only
    /// direction that clips**:
    ///
    /// 1. **The LIVE toolbar's own width** — always right, and the only
    ///    source the ordinary paths ever need (the expanded strip can only
    ///    be reached by tapping Aa on a bar already on screen).
    /// 2. **The last width this controller built at** (`lastBuiltBarWidth`
    ///    — its doc has the mechanism this arm exists for: a caller that
    ///    releases the outgoing bar before asking for a new one).
    /// 3. **`narrowestBarWidth`** — a true placeholder, and the deliberate
    ///    default for a controller that has never seen a hosted bar. Only
    ///    the RESTING items are built at that point, so it costs nothing;
    ///    `.flexibleWidth` hands over the real width the moment UIKit
    ///    installs the accessory view, and the next `barItems(face:)` call
    ///    reads it.
    ///
    /// *Declined, and recorded rather than silently skipped: reading
    /// `textView?.window?.bounds.width` as a fourth source. It is an
    /// inference from the portrait-lock rather than a width this bar was
    /// ever given, and if the inference ever failed it would fail in the
    /// too-WIDE direction — the one that clips. Arm 2 is a width a real
    /// toolbar actually had.*
    private func currentBarWidth() -> CGFloat {
        if let live = bar?.bounds.width, live > 0 {
            lastBuiltBarWidth = live
            return live
        }
        if lastBuiltBarWidth > 0 { return lastBuiltBarWidth }
        return Self.narrowestBarWidth
    }

    /// One state's items. The resting bar is three flexible-spaced
    /// doors; the expanded state is the ONE-cell strip (FIX-5 — seven
    /// separate items overflowed the bar, see the class doc), centered.
    /// The strip's acts are the SAME builders the flat bar carried —
    /// byte-identical doors behind the one Aa gate (six of them when the
    /// door was built; ELEVEN since her R22 + M26).
    private func barItems(face: MobileEditorStyle.Face) -> [UIBarButtonItem] {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: face.chrome, .foregroundColor: face.muted,
        ]
        func act(_ title: String, _ label: String, _ selector: Selector) -> UIBarButtonItem {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
            item.accessibilityLabel = label
            item.setTitleTextAttributes(titleAttributes, for: .normal)
            item.setTitleTextAttributes(titleAttributes, for: .highlighted)
            return item
        }

        if isFormattingExpanded {
            // **The strip is sized to the bar it is going INTO** (this
            // batch's fix — a strip sized to a 375 pt assumption hung
            // 9 pt off each edge of a 320 pt Display-Zoom bar), through
            // the one resolver both seams share.
            return [
                .flexibleSpace(),
                formattingStripItem(face: face, barWidth: currentBarWidth()),
                .flexibleSpace(),
            ]
        }
        let acts: [UIBarButtonItem] = [
            act("Aa", "Formatting", #selector(toggleFormattingDoor)),
            act("⑂", "Takes", #selector(fireTakes)),
            blockMenuItem(face: face),
        ]
        var items: [UIBarButtonItem] = []
        for (index, item) in acts.enumerated() {
            if index > 0 { items.append(.flexibleSpace()) }
            items.append(item)
        }
        return items
    }

    /// The expanded formatting strip — ONE customView item (the FIX-5
    /// mechanism: owning the geometry is what makes overflow impossible
    /// and the visibility pin holdable windowless), a ONE-ROW capsule
    /// since her R22 (`kbar.formattingStrip`; the class doc above has
    /// the arithmetic): × · B · I · S · ⟨⟩ · 🔗 · # · • · ☑ · ⇥ · ⇤.
    /// Each button keeps its exact selector, label, and second gesture —
    /// the # picker and ⇥'s long-press outdent ride the same real
    /// buttons they always did; the C4b arrivals fire the SAME shared
    /// brain acts the Mac's Format menu fires (.strikethrough · .code ·
    /// .link — MarkdownSurfaceDoors, one computation both platforms),
    /// and M26's ⇤ fires the SAME `.outdent` the long-press always did.
    /// The `rows` table stays nested although it holds one row: it is
    /// `stripFittedHeight`'s source, so a future re-split grows the bar
    /// with no second edit.
    private func formattingStripItem(
        face: MobileEditorStyle.Face, barWidth: CGFloat
    ) -> UIBarButtonItem {
        func stripButton(
            _ title: String, _ label: String, _ selector: Selector
        ) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = face.chrome
            button.setTitleColor(face.muted, for: .normal)
            button.accessibilityLabel = label
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }
        /// The strike act's glyph is a struck-through S — the act shown
        /// by wearing it (the checklist's ☑ precedent).
        func strikeButton() -> UIButton {
            let button = UIButton(type: .system)
            button.setAttributedTitle(
                NSAttributedString(string: "S", attributes: [
                    .font: face.chrome, .foregroundColor: face.muted,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                ]), for: .normal)
            button.accessibilityLabel = "Strikethrough"
            button.addTarget(self, action: #selector(fireStrikethrough), for: .touchUpInside)
            return button
        }
        /// The link act wears the platform's own link glyph (the seal
        /// door's SF precedent; symbols tint with the voice ink exactly
        /// as titles do).
        func linkButton() -> UIButton {
            let button = UIButton(type: .system)
            button.setImage(UIImage(
                systemName: "link",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: face.chrome.pointSize, weight: .regular)), for: .normal)
            button.tintColor = face.muted
            button.accessibilityLabel = "Add Link"
            button.addTarget(self, action: #selector(fireLink), for: .touchUpInside)
            return button
        }

        let rows: [[UIButton]] = [
            [
                stripButton("×", "Hide Formatting", #selector(toggleFormattingDoor)),
                stripButton("B", "Bold", #selector(fireBold)),
                stripButton("I", "Italic", #selector(fireItalic)),
                strikeButton(),
                stripButton("⟨⟩", "Inline Code", #selector(fireCode)),
                linkButton(),
                headingButton(face: face),
                stripButton("•", "Bullet List", #selector(fireBullet)),
                stripButton("☑", "Checklist", #selector(fireChecklist)),
                indentButton(face: face),
                outdentButton(face: face),
            ],
        ]
        let actWidth = Self.stripButtonWidth(inBarOfWidth: barWidth)
        for button in rows.flatMap(\.self) {
            // EXACT, not `>=` — UIKit floors a titled system button's
            // intrinsic width at 30 pt regardless of its glyph, so a
            // minimum below 30 is silently ignored (see
            // `derivedStripButtonWidth`). Each act gets precisely its
            // share of THIS bar.
            button.widthAnchor.constraint(
                equalToConstant: actWidth
            ).isActive = true
            button.heightAnchor.constraint(
                equalToConstant: Self.stripButtonHeight
            ).isActive = true
        }
        let rowStacks = rows.map { buttons -> UIStackView in
            let row = UIStackView(arrangedSubviews: buttons)
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = Self.stripSpacing
            return row
        }
        let strip = UIStackView(arrangedSubviews: rowStacks)
        strip.axis = .vertical
        strip.alignment = .center
        strip.spacing = Self.stripSpacing
        strip.accessibilityIdentifier = "kbar.formattingStrip"
        let size = strip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        strip.frame = CGRect(origin: .zero, size: size)
        return UIBarButtonItem(customView: strip)
    }

    /// Aa opens the strip; × closes it — one door, two faces, swapping
    /// the LIVE bar's items in place. The bar's HEIGHT does not move with
    /// the state (M4 ≡ R7 — the geometry block's proven finding: an
    /// installed `inputAccessoryView` keeps the height it was presented
    /// at, so the old grow-on-expand road changed a frame and never a
    /// pixel). `barHeight` already clears the two-row capsule, so the
    /// swap is items only — and the keyboard never jumps.
    @objc func toggleFormattingDoor() {
        isFormattingExpanded.toggle()
        reloadBarItems()
    }

    private func reloadBarItems() {
        bar?.items = barItems(face: MobileEditorStyle.face)
    }

    /// The reset-per-presentation half (the ruling's calm default).
    @objc private func keyboardDidHide(_ note: Notification) {
        guard isFormattingExpanded else { return }
        isFormattingExpanded = false
        reloadBarItems()
    }

    /// ⋯ — the block menu on the caret's block (S4 batch 1; LK8's eighth
    /// act). A deferred menu rebuilt per open, so it always names the
    /// CURRENT caret block; in the open tail it offers one honest
    /// disabled line instead of a silent door (P-2's speaking form —
    /// the bar's ⑂ refusal, menu-grammared).
    private func blockMenuItem(face: MobileEditorStyle.Face) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle("⋯", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Block"
        button.accessibilityIdentifier = "kbar.block"
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                guard let model = self?.textView?.editorModel else {
                    completion([])
                    return
                }
                guard let blockID = model.blockIDAtCaret() else {
                    completion([UIAction(
                        title: MobileEditorStyle.chromeCase(
                            "Tap into a block first — block acts live on blocks."),
                        attributes: .disabled) { _ in }])
                    return
                }
                completion(model.blockMenu.menuElements(blockID: blockID))
            },
        ])
        return UIBarButtonItem(customView: button)
    }

    /// # carries two doors since parity A3 (P5, her ruled flip: "# tap
    /// still cycles; LONG-PRESS opens a direct H1/H2/H3/clear picker"):
    /// tap = the standing cycle, byte-unchanged; long-press = the direct
    /// picker (a real UIButton whose `menu` is NOT the primary action —
    /// UIKit's own long-press-reveals-menu behavior, the ⇥ button's
    /// wrap-a-button precedent). Rows are the Mac heading submenu's own
    /// words plus her "clear" row, voice-cased (P26/P43), rebuilt per
    /// open so the register follows a voice flip. (Since FIX-5 the
    /// button rides the one-cell strip rather than its own bar item;
    /// the wiring is byte-identical.)
    private func headingButton(face: MobileEditorStyle.Face) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("#", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Heading"
        button.accessibilityHint = "Long-press to pick a heading level"
        button.accessibilityIdentifier = "kbar.heading"
        button.addTarget(self, action: #selector(fireHeading), for: .touchUpInside)
        button.showsMenuAsPrimaryAction = false
        button.menu = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                completion(self?.headingPickerElements() ?? [])
            },
        ])
        return button
    }

    /// The picker's rows (test-visible): direct levels through the SAME
    /// shared toggle rule the Mac submenu rides — picking a line's own
    /// level clears it (one vocabulary, no invention) — plus her clear
    /// row, which no-ops where no heading exists.
    func headingPickerElements() -> [UIMenuElement] {
        let cased = MobileEditorStyle.chromeCase
        var rows: [UIMenuElement] = (1...3).map { level in
            UIAction(title: cased("Heading \(level)")) { [weak self] _ in
                self?.applyHeadingPick(level: level)
            }
        }
        rows.append(UIAction(title: cased("Clear Heading")) { [weak self] _ in
            self?.applyHeadingClear()
        })
        return rows
    }

    func applyHeadingPick(level: Int) {
        guard let textView else { return }
        MobileMarkdownActs.apply(.heading(level: level), to: textView)
    }

    func applyHeadingClear() {
        guard let textView,
              let act = MobileMarkdownActs.headingClearAct(in: textView)
        else { return }
        MobileMarkdownActs.apply(act, to: textView)
    }

    /// ⇥ needs a long-press (the outdent half), and a `UIBarButtonItem`
    /// can't carry one — so it has always been a real button. (Since
    /// FIX-5 it rides the one-cell strip; the wiring is byte-identical.)
    /// The long-press SURVIVES M26's visible ⇤ — she has muscle memory
    /// on nothing here, but a door that already works is never removed
    /// to make room for a second one, and the hint stays honest.
    private func indentButton(face: MobileEditorStyle.Face) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⇥", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Indent"
        button.accessibilityHint = "Long-press to outdent"
        button.accessibilityIdentifier = "kbar.indent"
        button.addTarget(self, action: #selector(fireIndent), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(
            target: self, action: #selector(fireOutdentLongPress(_:)))
        button.addGestureRecognizer(longPress)
        return button
    }

    /// **⇤ — M26 ≡ R21's visible un-indent, her ruled door.** The act is
    /// the one it always was (`MarkdownEditing.Act.outdent`, the shared
    /// brain — this doc named it `MarkdownEditing.outdent`, a path that
    /// does not exist, until 4.5d's cold review); what changed is that it is now VISIBLE. Its glyph mirrors
    /// ⇥ and it sits immediately beside it, so the pair reads as a pair.
    /// The hint names the other door rather than a gesture on this one —
    /// this button needs no long-press, and saying so is what keeps the
    /// long-press discoverable to VoiceOver at all.
    private func outdentButton(face: MobileEditorStyle.Face) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⇤", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Outdent"
        button.accessibilityHint = "Moves the line out one level"
        button.accessibilityIdentifier = "kbar.outdent"
        button.addTarget(self, action: #selector(fireOutdent), for: .touchUpInside)
        return button
    }

    // MARK: - The doors

    @objc func fireBold() { fire(.bold) }
    @objc func fireItalic() { fire(.italic) }
    /// The C4b arrivals — the same shared-brain acts the Mac menu fires.
    @objc func fireStrikethrough() { fire(.strikethrough) }
    @objc func fireCode() { fire(.code) }
    @objc func fireLink() { fire(.link) }
    @objc func fireBullet() { fire(.bullet) }
    @objc func fireChecklist() { fire(.checkbox) }

    /// The # cycle (PROVISIONAL — `MobileMarkdownActs.headingCycleAct`
    /// carries the reasoning: one button where the Mac has a submenu).
    @objc func fireHeading() {
        guard let textView else { return }
        MobileMarkdownActs.apply(
            MobileMarkdownActs.headingCycleAct(in: textView), to: textView)
    }

    /// The bar's ⇥ is the phone's Tab key — one behavior with the hardware
    /// key (indent a list line; an ordinary policed "\t" everywhere else).
    @objc func fireIndent() {
        textView?.performTabKey()
    }

    /// ⇤'s tap and ⇥'s long-press are the SAME act through the SAME
    /// brain — two doors, one computation (M26 is a door change).
    @objc func fireOutdent() { fire(.outdent) }

    @objc func fireOutdentLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        fireOutdent()
    }

    /// ⑂ — the takes browser on the caret's block (S2 batch 2; LK8's
    /// seventh act). The VM routes: a caret outside any block (the open
    /// tail) hears the honest refusal instead of a silent door (P-2).
    @objc func fireTakes() {
        textView?.editorModel?.openTakesBrowserAtCaret()
    }

    private func fire(_ act: MarkdownEditing.Act) {
        guard let textView else { return }
        MobileMarkdownActs.apply(act, to: textView)
    }
}
