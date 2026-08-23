//
//  MobileKeyboardBarGeometryTests.swift
//  VariorumMobileTests
//
//  **THE KEYBOARD BAR'S GEOMETRY, MEASURED OFF THE REAL SURFACE**
//  (round 2, sub-batch 4.5d).
//
//  These pins replace two that lived in `MobileMarkdownTests.swift` and
//  could not see the defect they were written to guard. Both failures are
//  the round's §15 trap 1 — *a pin asserting a view model's number, or a
//  view's configured property, proves nothing about what renders*:
//
//  1. **The width pin compared the strip to a LITERAL 375-derived number
//     while its own toolbar was 320 pt wide.** So a strip that hung off
//     both edges of a 320 pt bar measured green. (Its buttons were also
//     read in the STRIP's coordinates, where they always fit by
//     construction — the strip is the thing that overflows, so no
//     assertion inside it can witness the clip.)
//  2. **The clearance pin reduced to `air >= air`.** It asserted
//     `toolbar.frame.height - lowestCellEdge >= barVerticalAir`, and
//     `toolbar.frame.height` IS `barHeight` IS `lowestCellEdge +
//     barVerticalAir` — a tautology that holds whatever iOS draws. The
//     recorded guarantee that *"a future iOS trips here and gets
//     re-measured rather than silently re-broken"* did not exist: every
//     one of its assertions reads a constant this file computes, so a
//     layout that disagrees with the constants is invisible to it.
//
//  **So every assertion below is taken from FRAMES IN THE RENDERED VIEW
//  TREE of a toolbar hosted in a real `UIWindow`** — the §26 frame-dump
//  technique, which is also the only technique available here
//  (`ImageRenderer` cannot capture this surface, and the toolbar's private
//  glass cells only materialize in a window, which is exactly how the
//  original FIX-5 clip escaped A3's suite).
//
//  ── WHAT THE HOSTED DUMP MEASURED, before any of it was relied on ──────
//  iPhone 16e / iOS 26.2, `makeBar()` in a `UIWindow`, expanded:
//
//  | bar | content row | strip capsule cell | verdict |
//  |----:|------------:|-------------------:|---------|
//  | 320 | (8, 0, 304, 48) | **(−9, 0, 338, 48)** | **CLIPPED** — 9 pt off each bar edge; × at x = −4, ⇤ ending at 324 |
//  | 375 | (8, 0, 359, 48) | (8, 0, 359, 48) | whole |
//  | 393 | (8, 0, 377, 48) | (8, 0, 377, 48) | whole |
//  | 402 | (8, 0, 386, 48) | (8, 0, 386, 48) | whole |
//
//  Two facts fell out of it that the constants did not carry. **A bar wide
//  enough STRETCHES the customView's cell to the whole content row** and
//  centres the fitted button row inside it (at 393 the row sits at
//  x = 32.7, width 328) — which is why every wide phone looks right. **A
//  bar too narrow does NOT clamp the cell to the content row**: at 320 the
//  cell measured 338 wide against a 304 pt row, and hung off both ends.
//
//  *What that dump CANNOT tell you — corrected here, because the first
//  version of this paragraph said the cell "centres on the BAR" as though
//  it had been measured:* the content row's insets are symmetric, so the
//  bar's centre and the content row's centre are the SAME POINT (at 320:
//  bar 160.0, row 8 + 304/2 = 160.0, cell −9 + 338/2 = 160.0). The data
//  distinguishes clamped from unclamped; it cannot distinguish which of
//  the two the oversized cell centres on, and nothing here depends on
//  knowing.
//
//  And the toolbar's content-row inset measured **8 pt a side at every
//  width**, where batch 2's dump of the live bar recorded 16 — the two are
//  recorded on `toolbarContentInset`, which keeps the conservative 16.
//
//  **RUNTIME GAP, recorded rather than papered over:** the bar's real home
//  is an `inputAccessoryView` on a presented keyboard, and that cannot be
//  measured in process — under `xcodebuild test` the software keyboard
//  never presents, so the accessory view's `window` stays nil and its
//  content never lays out (probed, both at 320 and 393). Everything here
//  is measured in a plain window host. Her device is on iOS 26.6; this
//  simulator is 26.2.
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The real-surface host

/// Every descendant of a toolbar, with its frame in the TOOLBAR's own
/// coordinates — the space the keyboard clips against.
@MainActor
private func framesDrawn(by toolbar: UIToolbar) -> [(view: UIView, frame: CGRect)] {
    var out: [(UIView, CGRect)] = []
    func walk(_ view: UIView) {
        for sub in view.subviews {
            out.append((sub, sub.convert(sub.bounds, to: toolbar)))
            walk(sub)
        }
    }
    walk(toolbar)
    return out
}

/// The formatting strip a toolbar is RENDERING — found by walking the view
/// tree, not by reading `toolbar.items`, so a strip that is configured but
/// never laid out cannot pass for one that is on screen.
///
/// **This is the ONLY strip lookup in the file** (it was written out twice
/// until 4.5d's cold review — the drift class this file's own thesis is
/// about). `HostedBar` exposes it; every pin reads it from there.
@MainActor
private func stripRendered(by toolbar: UIToolbar) -> UIStackView? {
    framesDrawn(by: toolbar)
        .compactMap { $0.view as? UIStackView }
        .first { $0.accessibilityIdentifier == "kbar.formattingStrip" }
}

/// The act buttons of that strip, in strip order — the rows flattened, so
/// the walk keeps reading in door order however the strip is split.
@MainActor
private func actsRendered(by toolbar: UIToolbar) -> [UIButton] {
    (stripRendered(by: toolbar)?.arrangedSubviews ?? [])
        .flatMap { ($0 as? UIStackView)?.arrangedSubviews ?? [$0] }
        .compactMap { $0 as? UIButton }
}

/// A `makeBar()` toolbar hosted in a real window — VISIBLE, never key (the
/// long note in `withHostedBar` has the measurement that decided it) — at a
/// chosen bar width. The §26 frame-dump technique, as a fixture.
///
/// **The WINDOW is the fixture's real owner, not any one toolbar.**
/// `replacingToolbar` hands back a second `HostedBar` over the SAME window
/// (that is what a voice-switch rebuild does), so tearing down either one
/// must clear the window of every bar it is hosting — otherwise the first
/// value's teardown leaves the rebuilt toolbar in a hidden window and the
/// second value's teardown is never reached at all. `tearDown()` empties
/// the window, so ownership does not depend on which value the pin happens
/// to be holding.
@MainActor
private struct HostedBar {
    let window: UIWindow
    let toolbar: UIToolbar
    let controller: MobileKeyboardBarController
    /// Kept alive: the controller holds its text view weakly.
    let surface: MobileWriteSurfaceView

    /// Every descendant of the toolbar, in the TOOLBAR's own coordinates.
    var drawnFrames: [(view: UIView, frame: CGRect)] { framesDrawn(by: toolbar) }

    /// The lowest edge any laid-out CONTENT actually draws at, measured —
    /// the number the keyboard's top edge meets.
    ///
    /// Two exclusions, both principled rather than convenient: zero-sized
    /// scaffolding (UIKit parks a couple of those at the origin), and the
    /// toolbar's own backing views — the ones whose frame IS the toolbar's
    /// bounds (iOS 26 renders the bar's items through a
    /// `UICoreHostingView<RootView>` that fills it). Excluding by *exact
    /// bounds match* rather than by "taller than some threshold" is what
    /// keeps the measurement honest: a future iOS whose glass cell runs
    /// PAST the bar's bottom does not match the bounds, so it is still
    /// counted and still trips the clearance law.
    var lowestDrawnEdge: CGFloat {
        drawnFrames
            .filter { $0.frame.height > 0 && $0.frame.width > 0 }
            .filter { $0.frame != CGRect(origin: .zero, size: toolbar.bounds.size) }
            .map(\.frame.maxY)
            .max() ?? 0
    }

    /// The formatting strip as it RENDERS (`stripRendered(by:)`).
    var renderedStrip: UIStackView? { stripRendered(by: toolbar) }

    /// The eleven act buttons as they render, in strip order.
    var renderedActs: [UIButton] { actsRendered(by: toolbar) }

    /// Swaps a rebuilt bar into the same window (what `applyVoiceChrome`
    /// does at an LK2 voice switch) and settles it.
    func replacingToolbar(_ rebuilt: UIToolbar) async -> HostedBar {
        toolbar.removeFromSuperview()
        rebuilt.frame = toolbar.frame
        window.addSubview(rebuilt)
        await settleBar(window)
        return HostedBar(
            window: window, toolbar: rebuilt, controller: controller, surface: surface)
    }

    func frame(of view: UIView) -> CGRect { view.convert(view.bounds, to: toolbar) }

    /// Empties the WINDOW — every bar it hosts, not merely this value's —
    /// then hides it. See the type's doc: the window is the owner.
    func tearDown() {
        for hosted in window.subviews { hosted.removeFromSuperview() }
        window.isHidden = true
    }
}

/// Hosts the bar at `barWidth`, in the requested state, settled, and hands
/// back the live tree.
///
/// **The toolbar's frame is set to `barWidth` BEFORE the strip is ever
/// built, and that is the whole point:** the strip is sized from the bar's
/// own bounds, so a test that wants to prove the 320 pt case must actually
/// give the bar 320 pt rather than assert against a literal.
///
/// **The expand happens BEFORE the bar joins the window, and that is a
/// measured constraint, not a preference.** iOS 26 renders a toolbar's
/// items through a SwiftUI hosting view, and in this host it does not pick
/// up an items swap that happens after the bar is already on screen — a
/// dump taken after a live `toggleFormattingDoor()` still shows the RESTING
/// buttons, with the strip present in `toolbar.items` and absent from the
/// rendered tree, through any number of layout passes and
/// `CATransaction.flush()`es. So a pin that toggled in place would find no
/// strip and would be measuring nothing. **This is a HOST limitation, not
/// app behaviour** — batch 2 photographed the expanded strip on a real
/// device — and it is recorded as a runtime gap in the file header. The
/// geometry is identical either way (both orders reproduce the 320 pt clip
/// frame-for-frame), and the in-place items swap itself keeps its own pin
/// in `MobileMarkdownTests.swift`.
@MainActor
private func withHostedBar(
    barWidth: CGFloat, expanded: Bool,
    _ body: (HostedBar) async throws -> Void
) async rethrows {
    MobileEditorStyle.voice = .terminal
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: barWidth, height: 700)
    let controller = MobileKeyboardBarController(textView: surface.textView)
    guard let toolbar = controller.makeBar() as? UIToolbar else {
        Issue.record("makeBar() did not return a UIToolbar")
        return
    }
    toolbar.frame = CGRect(
        x: 0, y: 700 - MobileKeyboardBarController.barHeight,
        width: barWidth, height: MobileKeyboardBarController.barHeight)
    if expanded { controller.toggleFormattingDoor() }
    // **VISIBLE, NEVER KEY — stated as WHAT WAS MEASURED, because the
    // first version of this comment named a mechanism a cold reviewer
    // then falsified** (`notes/plans/mobile-round-2.md` §61).
    //
    // MEASURED: the toolbar's private glass cells only materialize inside
    // a window, so the bar must be hosted — and hosting it HERE with
    // `makeKeyAndVisible()` reproducibly killed the full mobile run on
    // `MobileEditorViewModel`'s "surface desynced from the block index"
    // fatal. Isolated three ways: this file held out → clean; this file's
    // SOURCE change alone → clean; source + this harness → crash.
    // `isHidden = false` lays the cells out identically and fixes it.
    //
    // NOT ESTABLISHED — and the first comment asserted it: that key-window
    // theft is the mechanism. The tree already holds THREE other
    // key-window hosts (`MobileTakesBrowserTests` :770 and :946,
    // `MobileLivenessTests` :199), untouched and green in the same runs,
    // and a counting probe found two hosted surfaces alive at once in
    // fifteen passing tests. **Overlap is the normal green state.** The
    // untraced difference: this window has **no `rootViewController`** —
    // it bare-`addSubview`s a toolbar, unlike every other host.
    //
    // **AND NEVER READ A 1540 DESYNC FATAL AS HARNESS NOISE.**
    // `EditorAssertionSeam.fire` defaults to `assertionFailure` precisely
    // to surface routing failures that `desyncRecovery()` then heals. If
    // you hit it, it is REAL until YOU have isolated it.
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: barWidth, height: 700))
    window.isHidden = false
    window.addSubview(toolbar)
    await settleBar(window)
    let hosted = HostedBar(
        window: window, toolbar: toolbar, controller: controller, surface: surface)
    defer { hosted.tearDown() }
    try await body(hosted)
}

/// iOS 26's toolbar renders its items through a SwiftUI hosting view, which
/// updates on a CoreAnimation commit rather than on `layoutIfNeeded` alone —
/// so a settle here needs the transaction flush as well as the layout pass.
/// (Found by dump: without it, a toolbar whose `items` had already been
/// swapped still rendered the previous items.)
@MainActor
private func settleBar(_ window: UIWindow, turns: Int = 12) async {
    for _ in 0..<turns {
        try? await Task.sleep(for: .milliseconds(20))
        await Task.yield()
        window.setNeedsLayout()
        window.layoutIfNeeded()
        CATransaction.flush()
    }
}

/// **A SAMPLE of the widths the app can be shown at, narrowest first — not
/// the complete set**, which is every portrait iPhone width iOS 26 runs on
/// (390, 428, 430, 440 … all sit above the interesting boundary). The four
/// are chosen: **320 is not a device — it is Display Zoom**, which any
/// modern iPhone reports when its owner turns on larger text and icons, and
/// it is the only width where the fit rule changes anything; 375 is the
/// narrowest hardware class still running iOS 26 (SE 2/3, 12 mini,
/// 13 mini), and therefore the boundary itself; 393 and 402 are ordinary
/// modern phones, one of them hers.
///
/// **What generalises the sample to every unsampled width is monotonicity,
/// not luck** (4.5d's cold review made this explicit): `stripWidthAvailable`
/// is increasing in the bar's width and `derivedStripButtonWidth` is a
/// non-decreasing function of it, so `min(28, derived(w)) == 28` for
/// **every** w ≥ 375, not merely for the three sampled above it. Below 375
/// the only width this round found reachable is 320 — 4.5d's cold reviewer
/// confirmed externally that **no iOS-26 iPhone renders narrower than 320
/// in portrait** — and nothing in the fit rule special-cases it: an
/// unforeseen intermediate width would narrow by the same monotone
/// derivation. Sampling is the right shape here precisely because the
/// function is monotone; a pin per width would prove no more.
private let supportedBarWidths: [CGFloat] = [320, 375, 393, 402]

// MARK: - The pins

@MainActor
@Suite("Mobile keyboard bar — geometry, measured on the real surface", .serialized)
struct MobileKeyboardBarGeometryTests {

    /// **THE FIT LAW: every act lands wholly inside the bar, at every width
    /// the app can be shown at.** This is FIX-5's adjudicated letter — *no
    /// act may leave the strip and no scroll may hide one* — finally
    /// asserted against the bar rather than against a literal.
    ///
    /// **RED ON OLD, and the mechanism is measured.** On the pre-fix tree
    /// the strip was sized once, for an assumed 375 pt bar: eleven 28 pt
    /// acts and ten 2 pt gaps = 328 pt, plus the glass cell's 5 pt a side =
    /// a 338 pt capsule. Hosted at 320 pt that capsule laid out at
    /// `(−9, 0, 338, 48)` — **9 pt off each edge of the bar** — with the ×
    /// button at x = −4 and the ⇤ button ending at 324, so each outer act
    /// lost 4 pt of its 28 and both rounded capsule ends were sliced. The
    /// per-act assertions below fail on exactly those two buttons.
    ///
    /// **Why the old pin could not see it, twice over:** it compared the
    /// strip to `375 − 32 − 10 = 333` (a literal, while its own toolbar was
    /// 320), and it read each button's frame inside the STRIP's coordinate
    /// space — where every button fits by construction, because the strip
    /// is the thing that overflows. A width pin must read the toolbar's own
    /// width, and a visibility pin must read the toolbar's own space.
    @Test func everyFormattingActLandsWhollyInsideTheBarAtEverySupportedWidth() async throws {
        for barWidth in supportedBarWidths {
            await withHostedBar(barWidth: barWidth, expanded: true) { bar in
                // The bar really is the width this case is about — asserted,
                // because the defect's whole hiding place was a pin whose
                // toolbar was not the width it reasoned about.
                #expect(bar.toolbar.bounds.width == barWidth)

                guard let strip = bar.renderedStrip else {
                    Issue.record("""
                        the expanded bar renders no formatting strip at \
                        \(barWidth) pt — separate items cannot promise \
                        on-screen visibility (the FIX-5 defect)
                        """)
                    return
                }
                let acts = bar.renderedActs
                #expect(acts.count == 11)
                #expect(acts.compactMap(\.accessibilityLabel)
                        == MobileKeyboardBarController.formattingActLabels)

                // **The law, in the toolbar's own coordinates.** Every act
                // whole — no sliver, no negative origin, nothing past the
                // right edge. At 320 pt on the pre-fix tree × sits at −4
                // and ⇤ ends at 324, so both of these fail.
                for act in acts {
                    let frame = bar.frame(of: act)
                    #expect(frame.minX >= -0.5,
                            "\(act.accessibilityLabel ?? "?") hangs off the left of a \(barWidth) pt bar at x=\(frame.minX)")
                    #expect(frame.maxX <= bar.toolbar.bounds.width + 0.5,
                            "\(act.accessibilityLabel ?? "?") hangs off the right of a \(barWidth) pt bar, ending at \(frame.maxX)")
                    #expect(frame.width > 0)
                    #expect(frame.height == MobileKeyboardBarController.stripButtonHeight)
                }

                // The capsule itself, with its glass cell's 5 pt padding a
                // side — the rounded end she would see sliced.
                let stripFrame = bar.frame(of: strip)
                let inset = MobileKeyboardBarController.stripCellInset
                #expect(stripFrame.minX - inset >= -0.5,
                        "the capsule's left end is cut on a \(barWidth) pt bar")
                #expect(stripFrame.maxX + inset <= bar.toolbar.bounds.width + 0.5,
                        "the capsule's right end is cut on a \(barWidth) pt bar")

                // And the fitted row fits the width the BAR offers — both
                // sides of this read the toolbar, never a literal.
                let fitted = strip.systemLayoutSizeFitting(
                    UIView.layoutFittingCompressedSize).width
                #expect(fitted <= MobileKeyboardBarController.stripWidthAvailable(
                    inBarOfWidth: bar.toolbar.bounds.width) + 0.5)
            }
        }
    }

    /// **HER RULED WIDTH SURVIVES WHEREVER IT FITS — and narrows only where
    /// it cannot.** R22 ruled one row of eleven acts and R25 pre-ruled the
    /// tap targets at the quoted ~31 pt; the built number is 28. This pin
    /// is what keeps the fit fix from quietly becoming a look change: on
    /// every bar wide enough for her strip, the acts measure exactly 28 pt
    /// on the real surface, as they did before the fix.
    ///
    /// The 320 pt case is the one that changes, and its number is stated
    /// rather than merely bounded: 11×23 + 10×2 = 273 inside the 278 the
    /// conservative allowance offers. **Narrowing is the only mechanism
    /// that keeps her ruled shape at that width** — one row, eleven acts,
    /// every one whole, nothing scrolled and nothing hidden.
    @Test func herRuledActWidthSurvivesWhereverItFitsAndNarrowsOnlyWhereItCannot() async throws {
        // The ruled number, and the tripwire that makes a TWELFTH act cost
        // a ruling rather than a constant edit (a twelfth computes 25).
        #expect(MobileKeyboardBarController.nominalStripButtonWidth == 28)
        #expect(MobileKeyboardBarController.nominalStripButtonWidth
                >= MobileKeyboardBarController.stripButtonCrowdingFloor)
        #expect(MobileKeyboardBarController.formattingActLabels.count == 11)

        for barWidth in supportedBarWidths {
            await withHostedBar(barWidth: barWidth, expanded: true) { bar in
                let acts = bar.renderedActs
                #expect(acts.count == 11)
                let expected = MobileKeyboardBarController.stripButtonWidth(
                    inBarOfWidth: bar.toolbar.bounds.width)
                for act in acts {
                    // EXACT, not `>=`: a `>=` cannot catch a button growing
                    // past its allotment and pushing the strip off the edge,
                    // which at these widths is a live risk (a wide glyph, a
                    // larger chrome font) rather than a theoretical one.
                    #expect(abs(bar.frame(of: act).width - expected) <= 0.5)
                }
                if barWidth >= MobileKeyboardBarController.nominalBarWidth {
                    // Byte-identical to what she has been looking at.
                    #expect(expected == MobileKeyboardBarController.nominalStripButtonWidth)
                } else {
                    // The Display-Zoom width — narrower, and stated.
                    #expect(barWidth == 320)
                    #expect(expected == 23)
                    #expect(expected < MobileKeyboardBarController.nominalStripButtonWidth)
                }
            }
        }
    }

    /// **THE CLEARANCE LAW, MEASURED — the rebuild of the `air >= air`
    /// pin.** Her complaint, verbatim: *"the buttons at the bottom, the
    /// three of them, also need more generous spacing because they're kind
    /// of touching the keyboard bar, which is annoying"* — answered at
    /// M4 ≡ R7 and retuned at R12 to 4 pt of air, *"only be a bit above"*.
    ///
    /// The pin that shipped with that fix asserted
    /// `toolbar.frame.height - lowestCellEdge >= barVerticalAir`, and every
    /// term of it is a constant this file computes from the others — so it
    /// held whatever iOS drew. **This one measures the lowest edge anything
    /// in the rendered tree actually reaches**, in the toolbar's own
    /// coordinates, and bounds the remaining air on BOTH sides — the R12
    /// pattern, so re-inflating trips exactly as clipping does.
    ///
    /// **RED ON OLD by behavioural revert:** give the strip's buttons a
    /// height the constants do not know about (58 pt instead of
    /// `stripButtonHeight`) and the real capsule reaches 68 pt inside a
    /// 52 pt bar. Every assertion in the OLD pin still passes — the
    /// constants are untouched and still agree with each other — while
    /// `lowestDrawnEdge` here reads 68 against a 52 pt bar and the air goes
    /// negative. That is precisely the class the old pin was blind to, and
    /// it is the same shape as batch 1's lesson: *when the bug is "the
    /// totals agree while the content is wrong", no oracle derived from the
    /// totals can witness it.*
    ///
    /// **It also settles the 20 pt STRUCTURAL FLOOR by measurement**
    /// (§35 recorded it; R22's one-row strip was ruled to dissolve it).
    /// Resting and expanded now bottom out at the SAME measured edge, so
    /// the floor is gone in fact and not merely in derivation — and a
    /// silent re-split into two rows pushes the expanded edge to 68 and
    /// trips here, which is the guard she is owed for the 20 pt of text her
    /// ruling bought back.
    @Test func theBarClearsEveryDrawnCellByTheRuledAirAtEveryWidth() async throws {
        for barWidth in supportedBarWidths {
            var restingEdge: CGFloat = 0
            await withHostedBar(barWidth: barWidth, expanded: false) { bar in
                #expect(!bar.controller.isFormattingExpanded)
                restingEdge = bar.lowestDrawnEdge
                // The resting glass cells are laid out against a fixed
                // content row and reach exactly its depth — the measured
                // observation the constants encode. A future iOS that lays
                // them out lower trips HERE, which is what the old pin
                // promised and could not do.
                #expect(restingEdge == MobileKeyboardBarController.itemCellHeight)
                let air = bar.toolbar.bounds.height - restingEdge
                #expect(air > 0, "the resting cells reach the keyboard at \(barWidth) pt")
                #expect(air <= 6, "the resting cells float \(air) pt above the keyboard")
                #expect(air == MobileKeyboardBarController.barVerticalAir)
                // **R12's third clause, restored** (4.5d's cold review: the
                // rebuild kept the first two and swapped the third for
                // `== barVerticalAir`, which is a better check — it proves
                // iOS HONOURS the constant — but it left nothing pinning
                // her photographed VALUE, so the constant could drift
                // 4 → 5 → 6 with every assertion passing). Both belong:
                // one guards the layout, this one guards the taste ruling.
                #expect(air == 4, "her photographed air is 4 pt (R12)")
            }
            await withHostedBar(barWidth: barWidth, expanded: true) { bar in
                #expect(bar.controller.isFormattingExpanded)
                #expect(bar.renderedStrip != nil)
                let expandedEdge = bar.lowestDrawnEdge
                let air = bar.toolbar.bounds.height - expandedEdge
                #expect(air > 0, "the expanded capsule reaches the keyboard at \(barWidth) pt")
                #expect(air <= 6, "the expanded capsule floats \(air) pt above the keyboard")
                #expect(air == MobileKeyboardBarController.barVerticalAir)
                #expect(air == 4, "her photographed air is 4 pt (R12)")
                // **The 20 pt floor, dissolved — measured, not derived.**
                #expect(expandedEdge == restingEdge)
                #expect(expandedEdge == MobileKeyboardBarController.itemCellHeight)
            }
        }
    }

    /// **A REBUILT BAR RENDERS WHAT THE BAR WAS ALREADY RENDERING — the
    /// seam the fit fix creates, closed and pinned.**
    ///
    /// `MobileEditorTextView.applyVoiceChrome()` calls `makeBar()` again at
    /// an LK2 voice switch, replacing the accessory view wholesale — and
    /// the controller's `isFormattingExpanded` survives that, so the strip
    /// can be REBUILT while it is open. Sizing the strip from the bar's own
    /// width makes that path load-bearing: a fresh toolbar that started at
    /// the narrowest supported width would have built her acts at 23 pt on
    /// a 402 pt phone and stayed that way until the next toggle — a visible
    /// narrowing, from a mechanism nobody would look at again.
    ///
    /// **RED ON OLD by behavioural revert**: give `makeBar()` a fixed
    /// `narrowestBarWidth` frame instead of inheriting the live bar's, and
    /// the acts below measure 23 pt on a 402 pt bar. The fix inherits the
    /// width, so a rebuild is invisible.
    @Test func aRebuiltBarKeepsTheWidthTheBarWasAlreadyRendering() async throws {
        let barWidth: CGFloat = 402
        await withHostedBar(barWidth: barWidth, expanded: true) { bar in
            #expect(bar.renderedActs.count == 11)
            for act in bar.renderedActs {
                #expect(abs(bar.frame(of: act).width
                            - MobileKeyboardBarController.nominalStripButtonWidth) <= 0.5)
            }
            // The voice switch, in the shape `applyVoiceChrome` performs it.
            guard let rebuilt = bar.controller.makeBar() as? UIToolbar else {
                Issue.record("the rebuilt bar is not a toolbar")
                return
            }
            #expect(rebuilt.bounds.width == barWidth)
            let after = await bar.replacingToolbar(rebuilt)
            #expect(after.controller.isFormattingExpanded)
            #expect(after.renderedActs.count == 11)
            for act in after.renderedActs {
                let frame = after.frame(of: act)
                #expect(abs(frame.width
                            - MobileKeyboardBarController.nominalStripButtonWidth) <= 0.5)
                #expect(frame.minX >= -0.5)
                #expect(frame.maxX <= after.toolbar.bounds.width + 0.5)
            }
        }
    }

    /// **THE REBUILD SEAM WITH THE OUTGOING BAR ALREADY GONE — the call
    /// site no pin drove, and the one the whole fit fix's correctness was
    /// resting on.**
    ///
    /// The pin above rebuilds the way `applyVoiceChrome` does *today*:
    /// `inputAccessoryView = keyboardBarController.makeBar()` evaluates the
    /// new bar while the old one is still assigned — and therefore still
    /// retained — so the controller's `weak var bar` is alive and the new
    /// bar inherits its width. **4.5d's cold review found that the fix
    /// therefore depended on an ASSIGNMENT ORDER at a call site in another
    /// file.** A caller that tidied up first — `inputAccessoryView = nil;
    /// inputAccessoryView = makeBar()` — releases the outgoing bar, nils the
    /// weak reference, and rebuilds an OPEN strip from the fallback width:
    /// **23 pt acts on a 402 pt phone, sticky until the next Aa toggle**,
    /// from a mechanism nobody would look at again.
    ///
    /// So this pin drives exactly that order: host a real 402 pt bar, open
    /// the strip on it, **release the toolbar**, and only then ask for the
    /// rebuild. The fix is `currentBarWidth()`'s second arm — a width the
    /// controller remembers, which no caller's assignment order can nil.
    ///
    /// **RED ON OLD by behavioural revert:** put the shipped expression
    /// back (`(self.bar?.bounds.width ?? 0) > 0 ? … : narrowestBarWidth`)
    /// in place of `currentBarWidth()` and the rebuilt bar is born 320 pt
    /// wide with 23 pt acts — two independent assertions below.
    ///
    /// **Its precondition is REQUIRED, not assumed.** If the outgoing
    /// toolbar were still alive, the rebuild would inherit its width and
    /// this pin would pass on the pre-fix tree for the wrong reason — the
    /// false-green shape the round exists to stop.
    @Test func aRebuiltBarKeepsHerWidthWhenTheOutgoingBarIsReleasedFirst() async throws {
        MobileEditorStyle.voice = .terminal
        let barWidth: CGFloat = 402
        let height = MobileKeyboardBarController.barHeight
        let surface = MobileWriteSurfaceView()
        surface.frame = CGRect(x: 0, y: 0, width: barWidth, height: 700)
        let controller = MobileKeyboardBarController(textView: surface.textView)
        // Visible, never key — the same measured choice `withHostedBar`
        // makes, for the reasons written there.
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: barWidth, height: 700))
        window.isHidden = false
        defer {
            for hosted in window.subviews { hosted.removeFromSuperview() }
            window.isHidden = true
        }

        // A bar that really WAS 402 wide, with her strip open on it —
        // scoped so nothing it makes outlives the call.
        weak var outgoing: UIToolbar?
        func hostThenRelease() async {
            guard let toolbar = controller.makeBar() as? UIToolbar else {
                Issue.record("makeBar() did not return a UIToolbar")
                return
            }
            toolbar.frame = CGRect(
                x: 0, y: 700 - height, width: barWidth, height: height)
            controller.toggleFormattingDoor()
            window.addSubview(toolbar)
            await settleBar(window)
            #expect(toolbar.bounds.width == barWidth)
            #expect(actsRendered(by: toolbar).count == 11)
            outgoing = toolbar
            toolbar.removeFromSuperview()
        }
        await hostThenRelease()
        for _ in 0..<10 {
            try? await Task.sleep(for: .milliseconds(20))
            await Task.yield()
        }
        try #require(
            outgoing == nil,
            """
            the outgoing toolbar is still alive, so this pin would inherit \
            its width and pass for the wrong reason
            """)

        guard let rebuilt = controller.makeBar() as? UIToolbar else {
            Issue.record("makeBar() did not return a UIToolbar")
            return
        }
        // RED ON OLD (1): born at the fallback width.
        #expect(rebuilt.bounds.width == barWidth)
        rebuilt.frame = CGRect(
            x: 0, y: 700 - height, width: barWidth, height: height)
        window.addSubview(rebuilt)
        await settleBar(window)

        #expect(controller.isFormattingExpanded)
        let acts = actsRendered(by: rebuilt)
        #expect(acts.count == 11)
        for act in acts {
            let frame = act.convert(act.bounds, to: rebuilt)
            // RED ON OLD (2): 23 pt acts on her 402 pt phone.
            #expect(abs(frame.width
                        - MobileKeyboardBarController.nominalStripButtonWidth) <= 0.5)
            #expect(frame.minX >= -0.5)
            #expect(frame.maxX <= rebuilt.bounds.width + 0.5)
        }
    }

    /// **ONE HEIGHT SERVES BOTH STATES, on the real toolbar** (M17: an
    /// installed `inputAccessoryView` keeps the height it was presented at,
    /// so a second height never reaches a pixel — proven at batch 2 by
    /// capture, and the reason the grow-on-expand road was retired).
    /// Driven across the expand → collapse round trip on a hosted bar.
    ///
    /// **Named honestly: this is COVERAGE, not a pin.** There is no
    /// grow-on-expand code left to revert — the second height was retired
    /// at batch 2 when it was proven never to reach a pixel — so nothing on
    /// this tree can turn it red, and manufacturing a precondition to make
    /// it red would pin a fiction. It stands as the regression guard for
    /// anyone who tries the road again.
    ///
    /// *And one honesty note about its own first line, added at 4.5d's
    /// cold review:* `resting == barHeight` **restates the harness** —
    /// `withHostedBar` sets the toolbar's frame height FROM `barHeight`.
    /// The substance is everything after it: that the door's items swap,
    /// and the swap back, leave the toolbar's height where it was.
    @Test func theBarHeightNeverMovesBetweenTheTwoStates() async throws {
        await withHostedBar(barWidth: 320, expanded: false) { bar in
            let resting = bar.toolbar.bounds.height
            // Restates the harness — see the note above; kept as the
            // reading anchor for the three assertions that follow.
            #expect(resting == MobileKeyboardBarController.barHeight)
            bar.controller.toggleFormattingDoor()
            await settleBar(bar.window)
            #expect(bar.toolbar.bounds.height == resting)
            bar.controller.toggleFormattingDoor()
            await settleBar(bar.window)
            #expect(bar.toolbar.bounds.height == resting)
        }
    }
}
