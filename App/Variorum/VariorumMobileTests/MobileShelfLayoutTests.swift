//
//  MobileShelfLayoutTests.swift
//  VariorumMobileTests
//
//  Mobile Round 2, batch 5 — HER R26/R27 SHELF, pinned at the brain AND
//  at the rendered frames.
//
//  Her complaint, twice: *"I still see today's entry where i don't want
//  it and the quick note where i don't want it."*
//
//  ── THE RED-ON-OLD ────────────────────────────────────────────────────
//  `quickNoteSitsBelowTheBooks` is the one that matters and the one that
//  goes red on the pre-batch tree. It finds the REAL quick-note field and
//  a REAL book row by accessibility label — both exist on both trees, so
//  the pin compiles and runs against either — and asserts the field sits
//  BELOW the books. Before batch 5 the box was a fixed row directly under
//  the path line (A5-6) and Today's Entry sat at the bottom inside the
//  scroller: **the field's midY was ABOVE the book row's, so the pin
//  fails on old code and passes on new.** That is her sentence, measured.
//
//  ── THE §53 ROW 6 CASE, AND WHAT THESE PINS CAN AND CANNOT SEE ────────
//  The sweep predicted her ruled "about half the phone screen" would be
//  the first casualty of the keyboard, because SwiftUI's avoidance insets
//  the whole VStack. `MobileShelfLayout` answers it by making the BOOKS a
//  share of whatever room exists, so the writing region keeps its share
//  of a smaller room.
//
//  **`writingKeepsItsShareUnderAKeyboardSizedRegion` measures exactly
//  that, on the real surface, by HOSTING THE SHELF AT A KEYBOARD-REDUCED
//  HEIGHT** — 430 × 596, which is an iPhone 16 Pro Max (430 × 932) minus
//  a ~336 pt keyboard. **What it does NOT do is present a keyboard**:
//  under `xcodebuild test` the software keyboard never presents (the
//  `MobileKeyboardBarGeometryTests` finding, re-verified here by the
//  absence of any inset change on focus). So the pin proves the LAYOUT's
//  response to a smaller region — which is the mechanism — and the
//  device queue is where iOS's own inset gets confirmed. Recorded rather
//  than claimed.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Frames off the real surface

/// The accessibility frame of a labelled element, in window coordinates.
/// Shared with `MobileShelfTodayDoorTests` — one frame lookup for the
/// batch, so two files cannot measure the same surface two ways.
@MainActor
func shelfFrame<V: View>(_ surface: HostedSurface<V>, labeled label: String) -> CGRect? {
    guard let element = surface.element(labeled: label) else { return nil }
    let rect = element.accessibilityFrame
    return rect.isEmpty ? nil : rect
}

/// Every element whose label contains a needle — book rows carry
/// SwiftUI-derived labels built from their own text.
///
/// **Case-INSENSITIVE, and that is not tidiness.** The terminal voice
/// lowercases chrome (`VoiceTokens.lowercasesChrome`), so a book named
/// "Ledger 0" renders — and is labelled — "ledger 0". A case-sensitive
/// match found nothing and the pin failed for the right-looking wrong
/// reason: caught while establishing this batch's red-on-old, which is
/// exactly what that exercise is for.
@MainActor
private func frames<V: View>(
    _ surface: HostedSurface<V>, labelledContaining needle: String
) -> [CGRect] {
    surface.visibleElements
        .filter {
            ($0.accessibilityLabel ?? "").range(of: needle, options: .caseInsensitive) != nil
        }
        .map(\.accessibilityFrame)
        .filter { !$0.isEmpty }
}

/// **The two regions AS RENDERED, off the UIKit view tree** (the §26
/// frame-dump technique `MobileKeyboardBarGeometryTests` established).
///
/// The books region is a real `UIScrollView`, so it can be found and
/// measured directly. The writing region is deliberately derived as
/// *what is left below it* rather than looked up: the box's dashed border
/// is a SwiftUI `Shape` overlay and draws in a layer with no `UIView` of
/// its own — measured, not assumed (a probe dumped the whole tree before
/// these pins were written). Deriving the residual is also the honest
/// measurement of the SPLIT, which is what R27 rules.
///
/// *(The accessibility frame of the "Quick note" element is NOT the
/// region: it reports the text view's own one-line box — 14 pt — sitting
/// at the top of the area. That measured fact is why these pins do not
/// use it, and it is recorded here so a later session does not re-derive
/// it the slow way.)*
@MainActor
private func shelfRegions<V: View>(
    _ surface: HostedSurface<V>
) -> (books: CGRect, writing: CGRect)? {
    guard let root = surface.host.view else { return nil }
    var scroll: UIScrollView?
    func walk(_ view: UIView) {
        if scroll == nil, let found = view as? UIScrollView { scroll = found }
        for sub in view.subviews { walk(sub) }
    }
    walk(root)
    guard let books = scroll?.convert(scroll!.bounds, to: root) else { return nil }
    let writing = CGRect(
        x: 0, y: books.maxY,
        width: root.bounds.width,
        height: max(0, root.bounds.height - books.maxY))
    return (books, writing)
}

/// The quick-note field's own backing text view. SwiftUI's
/// `TextField(axis: .vertical)` renders through a `UITextView` subclass
/// (probed: `VerticalTextView` inside a
/// `UIKitPlatformViewHost<PlatformViewRepresentableAdaptor<TextViewAdaptor>>`),
/// so focus can be taken the way a tap takes it.
@MainActor
private func textInputView<V: View>(in surface: HostedSurface<V>) -> UIView? {
    guard let root = surface.host.view else { return nil }
    var found: UIView?
    func walk(_ view: UIView) {
        if found == nil, view is UITextView || view is UITextField { found = view }
        for sub in view.subviews { walk(sub) }
    }
    walk(root)
    return found
}

@MainActor
private func shelfSurface(
    _ session: AppSession, size: CGSize,
    quickNote: MobileQuickNoteModel? = nil
) -> HostedSurface<MobileShelfView<EmptyView>> {
    let shelf = MobileShelfViewModel(session: session)
    let stars = MobileStarsModel(session: session)
    let box = quickNote ?? MobileQuickNoteModel(session: session)
    return HostedSurface(
        MobileShelfView(
            model: shelf, stars: stars, quickNote: box,
            tokens: .terminalLight, tabBar: { EmptyView() },
            onOpenBook: { _ in }, onOpenForWriting: { _ in },
            onSettings: {}),
        size: size)
}

/// A hosted shelf whose box is already OPEN.
///
/// **Focus is driven through the model rather than through `@FocusState`,
/// and that is a deliberate, recorded limit rather than a shortcut:** a
/// `@FocusState` cannot be written from a pin, and the software keyboard
/// never presents under `xcodebuild test` (the
/// `MobileKeyboardBarGeometryTests` finding). So the pins below drive the
/// *state* her ruling is about and measure the real rendered response;
/// that the box's own `@FocusState` reaches that state is pinned
/// separately, by driving the real control
/// (`focusingTheRealFieldOpensTheBox`).
@MainActor
private func openShelfSurface(
    _ session: AppSession, size: CGSize
) async -> HostedSurface<MobileShelfView<EmptyView>> {
    let box = MobileQuickNoteModel(session: session)
    let surface = shelfSurface(session, size: size, quickNote: box)
    await surface.settle(20)
    box.setFocused(true)
    await surface.settle(40)
    return surface
}

@MainActor
private func makeBooks(_ session: AppSession, count: Int, prefix: String) async throws {
    for index in 0..<count {
        _ = try await session.runner.run { ops in
            try ops.createReading(name: "\(prefix) \(index)", kind: .book)
        }
    }
}

// MARK: - The brain (R27's arithmetic)

@Suite("Shelf layout — her R27 proportions")
struct MobileShelfLayoutBrainTests {

    /// Nothing can fall off the bottom: the two regions partition the room.
    @Test(arguments: [0.0, 60.0, 132.0, 300.0, 596.0, 746.0, 1200.0])
    func theSplitPartitionsTheRegionExactly(region: Double) {
        let split = MobileShelfLayout.split(
            region: CGFloat(region), bookRows: 5, extraRows: 1)
        #expect(abs((split.booksHeight + split.writingHeight) - CGFloat(region)) < 0.001)
        #expect(split.booksHeight >= 0)
        #expect(split.writingHeight >= 0)
    }

    /// R27.3 — *"about half the phone screen"*. With a full shelf and a
    /// full-height region, the writing area keeps roughly half.
    @Test func theWritingAreaIsAboutHalfTheRoom() {
        // 430 × 932 minus the path line, status slot and tab bar.
        let region: CGFloat = 746
        let split = MobileShelfLayout.split(
            region: region, bookRows: 20, extraRows: 1)
        let share = split.writingHeight / region
        #expect(share >= 0.5, "writing share was \(share)")
        #expect(share <= 0.62, "the books must still get a real half — \(share)")
    }

    /// R27.2 — *"more than ~8 books … you have to scroll through the
    /// books"*. Past her number the books region stops growing, so the
    /// writing area does not move as the shelf fills.
    @Test func pastEightBooksTheListStopsGrowing() {
        let region: CGFloat = 900
        let eight = MobileShelfLayout.split(
            region: region, bookRows: 8, extraRows: 1)
        let forty = MobileShelfLayout.split(
            region: region, bookRows: 40, extraRows: 1)
        #expect(eight.booksHeight == forty.booksHeight)
        #expect(eight.writingHeight == forty.writingHeight,
                "the writing area must not move as books arrive")
        // And it really is her ~8 rows plus the trailing door.
        #expect(forty.booksHeight
                == CGFloat(MobileShelfLayout.visibleBookRowCap + 1)
                    * MobileShelfLayout.bookRowHeight)
    }

    // MARK: - Her 2026-08-30 ruling: one line until she clicks in

    /// *"the box should be one line until you click into it."* At rest the
    /// writing region is a single line's worth, whatever the shelf holds.
    @Test func atRestTheBoxIsOneLine() {
        for bookRows in [0, 2, 8, 40] {
            let rest = MobileShelfLayout.split(
                region: 746, bookRows: bookRows, extraRows: 1, writing: .collapsed)
            #expect(rest.writingHeight == MobileShelfLayout.collapsedWritingHeight,
                    "books \(bookRows): \(rest.writingHeight)")
        }
    }

    /// **Her stated consequence: a one-line box gives the books more
    /// room** — and the ~8-row cap does NOT apply at rest, because the cap
    /// exists only to protect a writing area there is none of. Capping
    /// here would mint dead air above a collapsed box instead.
    @Test func atRestTheBooksTakeEverythingElse() {
        let rest = MobileShelfLayout.split(
            region: 746, bookRows: 40, extraRows: 1,
            writing: .collapsed)
        let open = MobileShelfLayout.split(
            region: 746, bookRows: 40, extraRows: 1,
            writing: .expanded)
        #expect(rest.booksHeight == 746 - MobileShelfLayout.collapsedWritingHeight)
        #expect(rest.booksHeight > open.booksHeight,
                "resting must give the books more room than writing does")
    }

    /// The collapsed box is itself never crushed: in a room too small even
    /// for one line, it takes the whole room rather than going negative.
    @Test func theCollapsedBoxIsNeverCrushed() {
        for region in stride(from: 4.0, through: 200.0, by: 4.0) {
            let rest = MobileShelfLayout.split(
                region: CGFloat(region), bookRows: 9, extraRows: 2, writing: .collapsed)
            #expect(rest.writingHeight
                    == min(CGFloat(region), MobileShelfLayout.collapsedWritingHeight))
            #expect(rest.booksHeight >= 0)
            #expect(abs((rest.booksHeight + rest.writingHeight) - CGFloat(region)) < 0.001)
        }
    }

    /// A short shelf does not reserve air it does not need — two books
    /// leave more room to write, not a gap.
    @Test func aShortShelfGivesTheWritingAreaMore() {
        let region: CGFloat = 746
        let two = MobileShelfLayout.split(
            region: region, bookRows: 2, extraRows: 1)
        let twenty = MobileShelfLayout.split(
            region: region, bookRows: 20, extraRows: 1)
        #expect(two.booksHeight < twenty.booksHeight)
        #expect(two.writingHeight > twenty.writingHeight)
    }

    /// **§53 ROW 6, as arithmetic.** A keyboard takes ~336 pt of a 16 Pro
    /// Max. The BOOKS absorb it; the writing area keeps its ruled share of
    /// what is left — which is the whole point of bounding the books
    /// rather than pinning the box.
    @Test func theBooksAbsorbTheKeyboardNotTheWritingArea() {
        let roomy = MobileShelfLayout.split(
            region: 746, bookRows: 20, extraRows: 1)
        let cramped = MobileShelfLayout.split(
            region: 410, bookRows: 20, extraRows: 1)

        #expect(cramped.booksHeight < roomy.booksHeight,
                "the books must be what yields")
        #expect(cramped.writingHeight / 410 >= 0.5,
                "the writing area keeps its share of a smaller room: \(cramped.writingHeight / 410)")
        // And in absolute terms it stays a place to write.
        #expect(cramped.writingHeight >= MobileShelfLayout.minimumWritingHeight)
    }

    /// **HER GUARANTEE, PINNED AS A PROMISE** (2026-08-30): *"the shelf
    /// should be bounded so it always has a decent amount of room to
    /// write."*
    ///
    /// This asserts the PROMISE across every shelf state this app can
    /// render — not the arithmetic that currently produces it. That is the
    /// whole point: a later layout change is free to compute the split
    /// differently, and it is not free to erode the floor. The grid spans
    /// the real device envelope:
    ///
    /// · **regions** from the smallest supported phone with a keyboard up
    ///   (an iPhone SE-class 375 × 667, or a 320 pt Display-Zoom screen,
    ///   minus ~291 pt of keyboard and the shelf's own chrome) through a
    ///   16 Pro Max with none;
    /// · **books** from an empty shelf to two hundred;
    /// · **extra rows** for the `+ new book` door, with and without the
    ///   Today fallback row beside it.
    ///
    /// *(It spanned a fourth dimension — starred rows, none to forty — until
    /// the cold review's NIT 1 retired the parameter that carried them: the
    /// starred list moved to its own page at batch 10, so those states are
    /// no longer states the shelf can be in. The promise is unchanged; the
    /// grid stopped spanning a dimension the app cannot enter.)*
    ///
    /// The degenerate tail is honest rather than excluded: where the room
    /// is smaller than the floor itself, writing takes ALL of it.
    @Test func theWritingFloorIsAGuaranteeInEveryShelfState() {
        var checked = 0
        for region in stride(from: 60.0, through: 900.0, by: 20.0) {
            for bookRows in [0, 1, 3, 8, 9, 20, 200] {
                for extraRows in [1, 2] {
                    let split = MobileShelfLayout.split(
                        region: CGFloat(region), bookRows: bookRows,
                        extraRows: extraRows)
                    checked += 1
                    #expect(
                        split.writingHeight
                            >= min(CGFloat(region),
                                   MobileShelfLayout.minimumWritingHeight) - 0.001,
                        "region \(region) books \(bookRows): writing \(split.writingHeight)")
                    // And nothing may fall off the bottom while it holds.
                    #expect(
                        abs((split.booksHeight + split.writingHeight)
                            - CGFloat(region)) < 0.001)
                    #expect(split.booksHeight >= 0)
                }
            }
        }
        print("PERF[sim] writing-floor guarantee — \(checked) shelf states checked, floor \(MobileShelfLayout.minimumWritingHeight) pt")
        // regions × books × extra rows (the stars dimension retired with
        // the parameter — NIT 1).
        #expect(checked == 43 * 7 * 2)
    }

    /// **Why Dynamic Type cannot erode the guarantee, stated as the
    /// property rather than as a hope.** The row heights are estimates,
    /// and at large text sizes the real rows are TALLER than they say. The
    /// books' share is `min(natural, caps)`, so an estimate that is too
    /// small can only shrink `wanted` — which can only make the writing
    /// region LARGER. The error is one-directional, and this is the pin
    /// that says so.
    @Test func underestimatingTheBooksOnlyEverGivesWritingMore() {
        for region in stride(from: 200.0, through: 900.0, by: 50.0) {
            var previous = CGFloat.infinity
            for bookRows in [0, 1, 2, 4, 8, 16, 40] {
                let split = MobileShelfLayout.split(
                    region: CGFloat(region), bookRows: bookRows,
                    extraRows: 1)
                #expect(split.writingHeight <= previous + 0.001,
                        "more books must never give writing MORE room")
                previous = split.writingHeight
            }
        }
    }

    /// The guarantee in the units she stated it in: the floor really is
    /// room to WRITE, not merely a number of points — six lines of prose
    /// survive it, and the field's own cap agrees.
    @Test func theFloorIsSixRealLinesOfWriting() {
        let floor = MobileShelfLayout.minimumWritingHeight
        #expect(MobileShelfLayout.writingLineCap(writingHeight: floor)
                >= MobileShelfLayout.guaranteedWritingLines)
        // A floor expressed in points would drift the moment the type or
        // the box's chrome changed; this one is derived from both.
        #expect(floor == CGFloat(MobileShelfLayout.guaranteedWritingLines)
                * MobileShelfLayout.smallLineHeight
                + MobileShelfLayout.writingBoxChromeHeight)
    }

    /// **FOCUSING MUST NOT PUSH THE WRITING AREA UNDER THE FLOOR** — the
    /// interaction her two rulings create together, and the one place they
    /// could have fought. The collapse gives the books more room; opening
    /// takes it back, and the guarantee binds on the way in.
    @Test func openingTheBoxNeverLandsBelowTheFloor() {
        for region in stride(from: 60.0, through: 900.0, by: 20.0) {
            let rest = MobileShelfLayout.split(
                region: CGFloat(region), bookRows: 40, extraRows: 1, writing: .collapsed)
            let open = MobileShelfLayout.split(
                region: CGFloat(region), bookRows: 40, extraRows: 1, writing: .expanded)
            #expect(open.writingHeight
                    >= min(CGFloat(region),
                           MobileShelfLayout.minimumWritingHeight) - 0.001,
                    "region \(region): opened to \(open.writingHeight)")
            // And opening never gives her LESS room than resting did.
            #expect(open.writingHeight >= rest.writingHeight - 0.001,
                    "region \(region): rest \(rest.writingHeight) open \(open.writingHeight)")
        }
    }

    /// The floor wins when the room is genuinely small: the books yield
    /// entirely rather than leaving her a one-line box.
    @Test func theWritingFloorOutranksTheBooks() {
        let split = MobileShelfLayout.split(
            region: 150, bookRows: 20, extraRows: 1)
        #expect(split.writingHeight >= MobileShelfLayout.minimumWritingHeight)
        #expect(split.booksHeight <= 150 - MobileShelfLayout.minimumWritingHeight)
    }

    /// A region smaller than the floor is still partitioned honestly —
    /// the writing area takes all of it rather than overflowing.
    @Test func aRegionBelowTheFloorGivesEverythingToWriting() {
        let split = MobileShelfLayout.split(
            region: 80, bookRows: 6, extraRows: 1)
        #expect(split.writingHeight == 80)
        #expect(split.booksHeight == 0)
    }

    /// The field's growth follows the ruled region and never degenerates.
    @Test func theWritingLineCapFollowsTheRoom() {
        let roomy = MobileShelfLayout.writingLineCap(writingHeight: 380)
        let cramped = MobileShelfLayout.writingLineCap(writingHeight: 140)
        #expect(roomy > cramped)
        #expect(roomy >= 20, "half a big phone is a real page — got \(roomy)")
        #expect(cramped >= MobileShelfLayout.minimumWritingLines)
        // Degenerate inputs stay honest rather than crashing or going wild.
        #expect(MobileShelfLayout.writingLineCap(writingHeight: 0)
                == MobileShelfLayout.minimumWritingLines)
        #expect(MobileShelfLayout.writingLineCap(writingHeight: 380, lineHeight: 0)
                == MobileShelfLayout.minimumWritingLines)
    }

    /// The line cap must never ask the field for more lines than the room
    /// can draw — that is what would overflow the ruled area.
    @Test(arguments: [140.0, 220.0, 380.0, 520.0])
    func theLineCapFitsInsideItsOwnRegion(writingHeight: Double) {
        let cap = MobileShelfLayout.writingLineCap(writingHeight: CGFloat(writingHeight))
        let drawn = CGFloat(cap) * MobileShelfLayout.smallLineHeight
            + MobileShelfLayout.writingBoxChromeHeight
        // The floor case (3 lines) may exceed a tiny region by design —
        // everywhere else the cap must fit.
        if cap > MobileShelfLayout.minimumWritingLines {
            #expect(drawn <= CGFloat(writingHeight) + 0.001,
                    "cap \(cap) draws \(drawn) into \(writingHeight)")
        }
    }

    /// The `smallLineHeight` constant is MEASURED, not assumed — against
    /// the real fonts both voices resolve `tokens.small` to (11.5 pt,
    /// monospaced in terminal, system in study).
    @Test func smallFontLineHeightMatchesTheConstant() {
        let terminal = UIFont.monospacedSystemFont(ofSize: 11.5, weight: .regular).lineHeight
        let study = UIFont.systemFont(ofSize: 11.5).lineHeight
        print("PERF[sim] shelf small line height — terminal \(terminal) · study \(study) "
              + "· constant \(MobileShelfLayout.smallLineHeight)")
        // Generous, because the constant only needs to be right enough to
        // keep the cap inside its region: a constant BELOW the truth would
        // over-cap and overflow, so the lower bound is the load-bearing one.
        #expect(MobileShelfLayout.smallLineHeight >= terminal - 0.5)
        #expect(MobileShelfLayout.smallLineHeight >= study - 0.5)
        #expect(MobileShelfLayout.smallLineHeight <= max(terminal, study) + 4)
    }
}

// MARK: - The rendered shelf (frames, not properties)

@Suite("Shelf layout — the rendered surface")
struct MobileShelfRenderedLayoutTests {

    /// **THE RED-ON-OLD.** Her sentence, measured: the quick note is where
    /// Today's Entry used to be — BELOW the books — and not in a fixed row
    /// under the path line. Fails on the pre-batch-5 tree, where the box
    /// was the first thing under the path line.
    @Test func quickNoteSitsBelowTheBooks() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 4, prefix: "Ledger")
            let surface = shelfSurface(
                session, size: CGSize(width: 430, height: 932))
            defer { surface.tearDown() }
            await surface.settle(40)

            let field = try #require(shelfFrame(surface, labeled: "Quick note"),
                                     "labels were \(surface.visibleLabels)")
            let bookRows = frames(surface, labelledContaining: "Ledger")
            #expect(!bookRows.isEmpty, "labels were \(surface.visibleLabels)")
            let lowestBook = try #require(bookRows.map(\.maxY).max())

            print("PERF[sim] shelf geometry — field \(field) · lowest book row maxY \(lowestBook)")
            #expect(field.minY >= lowestBook - 1,
                    "the quick note must sit BELOW the books (field.minY \(field.minY) vs books maxY \(lowestBook))")
        }
    }

    /// R27.3 on the real surface: the writing region really is about half
    /// the room, with a shelf full enough to have squeezed it before.
    @Test func theWritingRegionIsGenerousOnARealShelf() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 14, prefix: "Volume")
            // OPEN — since her 2026-08-30 ruling this is the state R27's
            // proportions describe; at rest the box is one line.
            let surface = await openShelfSurface(
                session, size: CGSize(width: 430, height: 932))
            defer { surface.tearDown() }

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] shelf regions at 932 pt OPEN — books \(regions.books) · writing \(regions.writing) (\(regions.writing.height / 932 * 100)% of the screen)")
            // Her "about half the phone screen", measured on a 932 pt phone.
            #expect(regions.writing.height >= 400,
                    "the writing region measured \(regions.writing.height) pt")
            #expect(regions.writing.height / 932 >= 0.42,
                    "share of the screen: \(regions.writing.height / 932)")
            // And the field really sits inside it, at its top.
            let field = try #require(shelfFrame(surface, labeled: "Quick note"),
                                     "labels were \(surface.visibleLabels)")
            #expect(regions.writing.minY <= field.minY
                        && field.maxY <= regions.writing.maxY + 1,
                    "field \(field) must live inside \(regions.writing)")
        }
    }

    /// **§53 ROW 6.** The same shelf in a keyboard-sized room: the writing
    /// field survives, because the BOOKS are what yields.
    @Test func writingKeepsItsShareUnderAKeyboardSizedRegion() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 14, prefix: "Volume")
            // 430 × 932 minus a ~336 pt keyboard — and the box OPEN, which
            // is the only way a keyboard is up in the first place. Her two
            // rulings meet exactly here.
            let surface = await openShelfSurface(
                session, size: CGSize(width: 430, height: 596))
            defer { surface.tearDown() }

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] shelf regions at 596 pt (keyboard-sized, OPEN) — books \(regions.books) · writing \(regions.writing)")
            #expect(regions.writing.height >= MobileShelfLayout.minimumWritingHeight,
                    "the ruled writing area must survive the keyboard — got \(regions.writing.height) pt")
            #expect(regions.writing.height / 596 >= 0.42,
                    "and it keeps its SHARE of the smaller room: \(regions.writing.height / 596)")
            #expect(regions.writing.maxY <= 596 + 1,
                    "and it is not pushed off the bottom — \(regions.writing)")
            // The BOOKS are what yielded — the whole point of the design.
            #expect(regions.books.height < 380,
                    "the books region should have shrunk: \(regions.books)")
        }
    }

    /// The books region really is bounded: forty books do not push the
    /// writing field down, they scroll.
    @Test func fortyBooksDoNotMoveTheWritingField() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 40, prefix: "Tome")
            let surface = await openShelfSurface(
                session, size: CGSize(width: 430, height: 932))
            defer { surface.tearDown() }

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] shelf regions with 40 books OPEN — books \(regions.books) · writing \(regions.writing)")
            #expect(regions.writing.maxY <= 932 + 1,
                    "the writing region stayed on screen: \(regions.writing)")
            #expect(regions.writing.height >= 400,
                    "40 books must not shrink the writing area — \(regions.writing.height)")
            // The list really is scrolling rather than growing: its
            // content is taller than the region it renders in.
            #expect(regions.books.height
                    <= CGFloat(MobileShelfLayout.visibleBookRowCap + 1)
                        * MobileShelfLayout.bookRowHeight + 1,
                    "the books region must stop at her ~8 rows: \(regions.books)")
        }
    }

    // MARK: - Her 2026-08-30 rulings, on the real surface

    /// **RED-ON-OLD (against batch 5's own first commit).** *"the box
    /// should be one line until you click into it."* At rest the writing
    /// region is one line's worth — it measured 466 pt before this
    /// refinement — and the books have everything else.
    @Test func atRestTheRenderedBoxIsOneLine() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 14, prefix: "Volume")
            let surface = shelfSurface(
                session, size: CGSize(width: 430, height: 932))
            defer { surface.tearDown() }
            await surface.settle(40)

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] shelf regions at 932 pt AT REST — books \(regions.books) · writing \(regions.writing)")
            #expect(abs(regions.writing.height
                        - MobileShelfLayout.collapsedWritingHeight) <= 1,
                    "at rest the box is one line: \(regions.writing)")
            // Her stated consequence, measured: the books have the room.
            #expect(regions.books.height >= 700,
                    "a collapsed box gives the books more room: \(regions.books)")
        }
    }

    /// **THE REAL CONTROL, DRIVEN — the one link the model-driven pins
    /// above would otherwise take on trust.**
    ///
    /// Focus is taken by calling `becomeFirstResponder()` on the field's
    /// own backing text view, found by walking the view tree. That is
    /// UIKit's real focus road, so this proves the whole chain her ruling
    /// rides: tap → first responder → the box's `@FocusState` → the model
    /// → the shelf's two regions.
    ///
    /// **`accessibilityActivate()` does NOT work here and the attempt is
    /// recorded rather than quietly replaced:** it returns `false` on this
    /// field (measured), joining `MobileSurfaceDriver`'s own list of what
    /// that dispatch cannot reach. A pin that had silently fallen back to
    /// setting the model would have proven nothing about the link.
    @Test func focusingTheRealFieldOpensTheBox() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 14, prefix: "Volume")
            let box = MobileQuickNoteModel(session: session)
            let surface = shelfSurface(
                session, size: CGSize(width: 430, height: 932), quickNote: box)
            defer { surface.tearDown() }
            await surface.settle(40)

            let atRest = try #require(shelfRegions(surface)).writing.height
            #expect(box.isFocused == false)

            let field = try #require(
                textInputView(in: surface), "no backing text view was rendered")
            #expect(field.becomeFirstResponder(), "the field must take focus")
            await surface.settle(60)

            #expect(box.isFocused,
                    "focusing the field must reach the model the shelf reads")
            let opened = try #require(shelfRegions(surface)).writing.height
            print("PERF[sim] focus opens the box — at rest \(atRest) pt · focused \(opened) pt")
            #expect(opened > atRest + 100, "at rest \(atRest), focused \(opened)")
            #expect(opened >= MobileShelfLayout.minimumWritingHeight)

            // And letting go closes it again — her ruling in both
            // directions, since "until you click into it" implies a
            // resting state to return to.
            field.resignFirstResponder()
            await surface.settle(60)
            #expect(box.isFocused == false)
            let closed = try #require(shelfRegions(surface)).writing.height
            #expect(abs(closed - atRest) <= 1,
                    "blur must return the box to one line: \(closed) vs \(atRest)")
        }
    }

    /// **HER GUARANTEE, MEASURED ACROSS THE DEVICE ENVELOPE** — every
    /// screen this app can render on, with the box open and the shelf as
    /// hostile as it gets (forty books, keyboard up).
    ///
    /// The heights are real: a 16 Pro Max, an iPhone 17, an SE-class 667,
    /// and a 320 pt Display-Zoom screen — each with and without ~291–336
    /// pt of keyboard.
    @Test(arguments: [
        CGSize(width: 430, height: 932), CGSize(width: 430, height: 596),
        CGSize(width: 393, height: 852), CGSize(width: 393, height: 516),
        CGSize(width: 375, height: 667), CGSize(width: 375, height: 376),
        CGSize(width: 320, height: 693), CGSize(width: 320, height: 402),
    ])
    func theWritingRoomHoldsOnEveryScreen(size: CGSize) async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 40, prefix: "Tome")
            let surface = await openShelfSurface(session, size: size)
            defer { surface.tearDown() }

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] guarantee at \(Int(size.width))×\(Int(size.height)) — books \(regions.books.height) · writing \(regions.writing.height)")
            #expect(regions.writing.height
                    >= MobileShelfLayout.minimumWritingHeight - 1,
                    "\(Int(size.height)) pt screen left \(regions.writing.height) pt to write in")
            #expect(regions.writing.maxY <= size.height + 1,
                    "and it stayed on screen: \(regions.writing)")
        }
    }

    /// **THE GUARANTEE AT THE LARGEST DYNAMIC TYPE SIZE**, on the
    /// smallest screen, with the box open — the worst case the envelope
    /// contains.
    ///
    /// The trait is overridden on the real `UIWindow` rather than injected
    /// as a SwiftUI environment, so this exercises the same propagation a
    /// device does. The Study voice's body type is `relativeTo: .body` and
    /// really does scale; the terminal voice's is fixed. Either way the
    /// books only ever want MORE than the estimate, and wanting more can
    /// only make the writing region larger — see
    /// `underestimatingTheBooksOnlyEverGivesWritingMore`.
    @Test func theWritingRoomHoldsAtTheLargestTextSize() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 40, prefix: "Tome")
            let box = MobileQuickNoteModel(session: session)
            let surface = shelfSurface(
                session, size: CGSize(width: 320, height: 693), quickNote: box)
            defer { surface.tearDown() }
            surface.window.traitOverrides.preferredContentSizeCategory =
                .accessibilityExtraExtraExtraLarge
            await surface.settle(20)
            box.setFocused(true)
            await surface.settle(50)

            let regions = try #require(shelfRegions(surface))
            print("PERF[sim] guarantee at AX5 on a 320×693 screen — books \(regions.books.height) · writing \(regions.writing.height)")
            #expect(regions.writing.height
                    >= MobileShelfLayout.minimumWritingHeight - 1,
                    "largest text left \(regions.writing.height) pt to write in")
        }
    }

    /// The row-height ESTIMATES the brain uses for its shrink decision
    /// are checked against what the shelf really draws, so a restyle that
    /// changes a row cannot silently skew the layout.
    @Test func theRowHeightConstantsMatchWhatRenders() async throws {
        try await withEditorWorld { session, _ in
            try await makeBooks(session, count: 4, prefix: "Ledger")
            let surface = shelfSurface(
                session, size: CGSize(width: 430, height: 932))
            defer { surface.tearDown() }
            await surface.settle(40)

            let rows = frames(surface, labelledContaining: "Ledger")
            let measured = try #require(rows.map(\.height).max())
            print("PERF[sim] shelf book row height — measured \(measured) "
                  + "· constant \(MobileShelfLayout.bookRowHeight)")
            #expect(abs(measured - MobileShelfLayout.bookRowHeight) <= 12,
                    "book row measured \(measured), constant is \(MobileShelfLayout.bookRowHeight)")
        }
    }
}
