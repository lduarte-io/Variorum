//
//  LibraryPlaceTests.swift
//  VariorumTests
//
//  **VX-823 (the VX-828 run, batch C) — the Library's place, the PURE brain.**
//  The ruling on batch C's fork (P-828-11): the place is the rows that were ON
//  SCREEN, each re-resolved by id in the CURRENT listing; the OPENED row is
//  not an anchor while another on-screen row survives; then the nearest
//  surviving neighbour; then the top. Exact pins over `LibraryPlace` alone —
//  no store, no view.
//
//  NEW BEHAVIOUR: compile-red on the pre-fix tree (no `LibraryPlace`). Their
//  strength is the exact values, and the model and mounted pins
//  (`LibraryReturnPlaceTests`, `LibraryReturnPlaceMountTests`) carry the
//  behavioural red-on-old.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@Suite("VX-823 — the Library's place: capture and resolve (pure)")
struct LibraryPlaceTests {
    private typealias Place = LibraryPlace

    /// Twenty rows, 30 pt each from y = 40 (a header's lead above them).
    private static let ids = (0..<20).map { "n\($0)" }
    private static func frames(_ ids: [String] = ids, top: CGFloat = 40, pitch: CGFloat = 30)
        -> [String: CGRect]
    {
        Dictionary(uniqueKeysWithValues: ids.enumerated().map { index, id in
            (id, CGRect(x: 0, y: top + CGFloat(index) * pitch, width: 600, height: pitch))
        })
    }

    @Test func theCaptureIsTheOnScreenRowsTopDownWithTheirInto() throws {
        // The viewport shows y 205…355: n5 (190…220) is cut by the top edge —
        // its top sits 15 pt ABOVE the viewport's top; n10 (340…370) is cut
        // by the bottom edge and still on screen; n11 (370…) is not.
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: nil))
        #expect(place.rows.map(\.id) == ["n5", "n6", "n7", "n8", "n9", "n10"])
        #expect(place.rows.first?.into == -15)
        #expect(place.rows.map(\.into) == [-15, 15, 45, 75, 105, 135])
        #expect(place.rows.allSatisfy { $0.height == 30 })
        // The neighbourhood, nearest first, bounded at the listing's ends.
        #expect(place.above == ["n4", "n3", "n2", "n1", "n0"])
        #expect(place.below == Array(Self.ids[11...19]))
        #expect(place.openedID == nil)
    }

    @Test func theCaptureSkipsWhatIsNotListedAndWhatIsOffScreen() throws {
        var frames = Self.frames()
        // A stale frame for a row the listing no longer draws, on screen.
        frames["gone"] = CGRect(x: 0, y: 50, width: 600, height: 30)
        // n2 (100…130) only TOUCHES the viewport's bottom edge: not on it.
        let window = Place.Window(offset: 40, viewport: 60, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: frames, order: .init(ids: Self.ids), openedID: "n1"))
        #expect(place.rows.map(\.id) == ["n0", "n1"])
        #expect(place.openedID == "n1")
        #expect(Place.capture(
            window: .unmeasured, frames: frames, order: .init(ids: Self.ids), openedID: nil) == nil)
    }

    @Test func anUnchangedListingLandsTheTopRowExactlyWhereItSat() throws {
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: nil))
        #expect(Place.resolve(place, in: .init(ids: Self.ids))
            == Place.Landing(id: "n5", into: -15, height: 30))
    }

    /// **The edited sort's own move (P-828-11's reason):** she opened n5 — the
    /// top on-screen row — and typed in it, so under `edited · newest first`
    /// it is now the FIRST row. The place holds: the next on-screen row lands
    /// where it sat, never the top of the Library.
    @Test func theOpenedRowIsNotTheAnchorWhileAnotherOnScreenRowSurvives() throws {
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: "n5"))
        let movedToTheTop = ["n5"] + Self.ids.filter { $0 != "n5" }
        #expect(Place.resolve(place, in: .init(ids: movedToTheTop))
            == Place.Landing(id: "n6", into: 15, height: 30))
        // …and when it is the ONLY on-screen row left, it is the anchor.
        let alone = ["n5", "x", "y"]
        #expect(Place.resolve(place, in: .init(ids: alone))
            == Place.Landing(id: "n5", into: -15, height: 30))
    }

    /// **A row deleted or filtered away since** — the next surviving
    /// on-screen row lands at ITS OWN place.
    @Test func aGoneTopRowLandsTheNextSurvivingOnScreenRowAtItsOwnInto() throws {
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: nil))
        let withoutTheFirstTwo = Self.ids.filter { $0 != "n5" && $0 != "n6" }
        #expect(Place.resolve(place, in: .init(ids: withoutTheFirstTwo))
            == Place.Landing(id: "n7", into: 45, height: 30))
    }

    /// **Every on-screen row gone** — the nearest surviving neighbour, where
    /// the on-screen rows began; below first at a tie.
    @Test func everyOnScreenRowGoneLandsTheNearestSurvivingNeighbour() throws {
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: nil))
        let screenGone = Self.ids.filter { !(5...10).map { "n\($0)" }.contains($0) }
        // n11 (below, distance 1) and n4 (above, distance 1): below wins.
        #expect(Place.resolve(place, in: .init(ids: screenGone))
            == Place.Landing(id: "n11", into: -15, height: 30))
        // Below gone too as far as n12: n4 (above, distance 1) lands with its
        // foot where the on-screen rows began.
        let belowGone = screenGone.filter { $0 != "n11" && $0 != "n12" }
        #expect(Place.resolve(place, in: .init(ids: belowGone))
            == Place.Landing(id: "n4", into: -45, height: 30))
    }

    @Test func nothingSurvivingLandsTheTop() throws {
        let window = Place.Window(offset: 205, viewport: 150, content: 640)
        let place = try #require(Place.capture(
            window: window, frames: Self.frames(), order: .init(ids: Self.ids), openedID: nil))
        #expect(Place.resolve(place, in: .init(ids: ["other", "notes"])) == nil)
        #expect(Place.resolve(place, in: .init(ids: [])) == nil)
    }

    /// The answer sheet and the List draw SEGMENTS (books · notes · blocks):
    /// one order across them, the neighbourhood crossing the seam.
    @Test func aSegmentedOrderReadsAsOneList() throws {
        let order = Place.Order.concatenated([
            .init(ids: ["b0", "b1"]), .init(ids: ["n0", "n1", "n2"]), .init(ids: ["k0"]),
        ])
        #expect(order.count == 6)
        #expect(order.position("b1") == 1)
        #expect(order.position("n0") == 2)
        #expect(order.position("k0") == 5)
        #expect(order.position("zz") == nil)
        #expect((0..<6).compactMap { order.id($0) } == ["b0", "b1", "n0", "n1", "n2", "k0"])
        #expect(order.id(6) == nil)
        #expect(order.id(-1) == nil)
        let frames = Self.frames(["b0", "b1", "n0", "n1", "n2", "k0"])
        let place = try #require(Place.capture(
            window: Place.Window(offset: 70, viewport: 30, content: 300),
            frames: frames, order: order, openedID: nil))
        #expect(place.rows.map(\.id) == ["b1"])
        #expect(place.above == ["b0"])
        #expect(place.below == ["n0", "n1", "n2", "k0"])
    }

    @Test func theAnchorArithmeticPutsTheRowsTopAtItsInto() {
        // into / (viewport − height)
        #expect(Place.anchorY(into: 135, height: 30, viewport: 300) == 0.5)
        #expect(Place.anchorY(into: 0, height: 30, viewport: 300) == 0)
        // A row cut by the top edge — negative, honoured linearly (Takes'
        // measured proxy).
        #expect(Place.anchorY(into: -27, height: 30, viewport: 300) == -0.1)
        // Never past the bottom; no room beside the row → the top.
        #expect(Place.anchorY(into: 900, height: 30, viewport: 300) == 1)
        #expect(Place.anchorY(into: 50, height: 300, viewport: 300.5) == 0)
    }

    @Test func aLandingHasArrivedWithinHalfAPointOrAtTheScrollsEnds() {
        let landing = Place.Landing(id: "n5", into: 45, height: 30)
        let window = Place.Window(offset: 200, viewport: 150, content: 640)
        let row = { (y: CGFloat) in CGRect(x: 0, y: y, width: 600, height: 30) }
        #expect(Place.isSettled(frame: row(245), window: window, landing: landing))
        #expect(Place.isSettled(frame: row(245.4), window: window, landing: landing))
        #expect(!Place.isSettled(frame: row(246), window: window, landing: landing))
        #expect(!Place.isSettled(frame: row(230), window: window, landing: landing))
        // At the very top a row that wanted to sit lower cannot.
        let top = Place.Window(offset: 0, viewport: 150, content: 640)
        #expect(Place.isSettled(frame: row(20), window: top, landing: landing))
        #expect(!Place.isSettled(frame: row(80), window: top, landing: landing))
        // At the very end a row that wanted to sit higher cannot.
        let end = Place.Window(offset: 490, viewport: 150, content: 640)
        #expect(Place.isSettled(frame: row(600), window: end, landing: landing))
        #expect(!Place.isSettled(frame: row(500), window: end, landing: landing))
    }

    /// Q5 (ruled "∝ the place's depth"): the deepest remembered position plus
    /// one page; nothing remembered asks the first page.
    @Test func theReasksDepthIsThePlacesReachPlusOnePage() {
        #expect(Place.depth(reach: nil, page: 80) == 80)
        #expect(Place.depth(reach: 0, page: 80) == 81)
        #expect(Place.depth(reach: 312, page: 80) == 393)
        #expect(Place.depth(reach: 12, page: 25) == 38)
    }
}
