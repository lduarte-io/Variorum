//
//  BookcaseDragFaceTests.swift
//  VariorumTests
//
//  **librarywalkpolish VR-116 (17y B-WALK W-4 + W-5) — what a Bookcase book
//  drag SHOWS.** Her walk, two findings:
//
//  - W-4 (R-LWP-3): the drag image was the row's scattered full-line
//    snapshot — "needs to be clearer what is being dragged... maybe as you
//    drag it becomes just the title", refined at her sitting: "you should be
//    able to start the drag from anywhere on the row though - even if it's
//    only the title it should move to be where your cursor is so dragging
//    into something feels natural and you aren't dragging with an offset."
//  - W-5: in a–z a book drag shows a line that does nothing on release —
//    "remove the useless line". TRACED (the B-WALK record): the line is a
//    section HEADER's drop hairline — drawn under the header (right above
//    its first row, reading as an insertion line) for ANY book hovering it,
//    while a drop on the book's OWN shelf's header re-shelves it nowhere
//    (`reshelve`'s same-shelf guard returns silently). A door that does
//    nothing must not offer (§12).
//
//  Red-on-old, stated: the source pin was committed AHEAD of the fix and ran
//  red on that tree (no drag preview on the book row; the header's hover
//  lit for every drag). The rule's own pins land with the fix.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("librarywalkpolish VR-116 — a book drag shows its title; a header lights only where a drop acts")
struct BookcaseDragFaceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    @Test func theBookRowDragsItsTitleAndTheHeaderAsksTheRule() throws {
        let shelf = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/ShelfView.swift"),
            encoding: .utf8)
        #expect(shelf.contains("BookDragChip("), "the book row's drag image is the compact title chip")
        #expect(shelf.contains("model.headerDropLights("),
                "a header lights only where its drop would act")
    }

    // MARK: - The rule and the image (landed with the fix)

    private func withSession<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func defaults() throws -> UserDefaults {
        let suite = "bookcase-drag-face-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// W-5's rule: a header lights for a BOOK from elsewhere — never for the
    /// book's own shelf (that drop is a silent nothing), never for a shelf
    /// name, never with nothing in flight.
    @Test func aHeaderLightsOnlyWhereItsDropActs() async throws {
        try await withSession { session in
            let ops = session.operations
            let work = try ops.createShelf(name: "Work")
            let ideas = try ops.createShelf(name: "Ideas")
            let onWork = try ops.createReading(name: "on work", kind: .book, shelfId: work.id)
            let loose = try ops.createReading(name: "loose", kind: .book)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            for _ in 0..<300 where model.books.count < 2 { try? await Task.sleep(for: .milliseconds(10)) }

            #expect(!model.headerDropLights(sectionShelfID: work.id), "nothing in flight lights nothing")
            _ = model.beginDrag(.book(onWork.id))
            #expect(!model.headerDropLights(sectionShelfID: work.id), "its own shelf: the drop would do nothing")
            #expect(model.headerDropLights(sectionShelfID: ideas.id))
            #expect(model.headerDropLights(sectionShelfID: nil), "Unshelved takes it off its shelf")
            _ = model.beginDrag(.book(loose.id))
            #expect(!model.headerDropLights(sectionShelfID: nil), "an unshelved book over Unshelved: nothing")
            #expect(model.headerDropLights(sectionShelfID: work.id))
            _ = model.beginDrag(.shelf(ideas.id))
            #expect(!model.headerDropLights(sectionShelfID: work.id), "a header takes no shelf name")
            // …and a shelf drop elsewhere still LANDS (the drop-on-shelf
            // targets are unchanged).
            await model.reshelve(loose.id, to: work.id)
            let landed = try await session.database.read { try Queries.reading($0, id: loose.id)?.shelfId }
            #expect(landed == work.id, "a drop on another shelf's header still lands")
        }
    }

    /// The payload is made when a drag BEGINS, never while the board draws —
    /// the rule above reads the drag in flight, so an eager payload would
    /// name the last row drawn. Mounting a board with books makes none.
    @Test func mountingTheBoardBeginsNoDrag() async throws {
        try await withSession { session in
            _ = try session.operations.createReading(name: "alpha", kind: .book)
            _ = try session.operations.createReading(name: "beta", kind: .book)
            let model = ShelfViewModel(session: session, defaults: try defaults())
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 500),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model, readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer { window.orderOut(nil); window.close() }
            for _ in 0..<60 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                Self.pump()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(model.books.count == 2, "the rows were drawn")
            #expect(model.dragInFlight == nil, "drawing the rows made no payload")
        }
    }

    private nonisolated static func pump() {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
    }

    /// W-4's placement, pure: the chip centres on the grab point (clamped to
    /// the row), the row's centre when no pointer was seen.
    @Test func theChipCentresOnTheGrabPoint() {
        let size = CGSize(width: 800, height: 34)
        #expect(BookDragSource.chipCenter(size: size, grab: CGPoint(x: 612, y: 20)) == CGPoint(x: 612, y: 20))
        #expect(BookDragSource.chipCenter(size: size, grab: nil) == CGPoint(x: 400, y: 17))
        #expect(BookDragSource.chipCenter(size: size, grab: CGPoint(x: 900, y: -5)) == CGPoint(x: 800, y: 0))
    }

    /// W-4's image, rendered: the preview is a canvas the SOURCE's size
    /// (SwiftUI centres a preview over its source — Apple's words for
    /// `draggable(_:preview:)`), clear but for the compact chip, whose ink
    /// sits around the grab point — a press far right of the title drags the
    /// title THERE, not at its own x.
    @Test func thePreviewIsTheTitleAtTheGrabPoint() throws {
        let made = Date(timeIntervalSince1970: 1_782_864_000)
        let book = Queries.ShelfBook(
            reading: Reading(id: "b", name: "Encryption Explained", kind: .book,
                             createdAt: made, updatedAt: made),
            postCount: 0, sectionCount: 0, arrivalCount: 0)
        let size = CGSize(width: 800, height: 34)
        let grab = CGPoint(x: 600, y: 17)
        let renderer = ImageRenderer(content: BookDragSource.canvas(
            book: book, tokens: .studyLight, size: size, grab: grab))
        renderer.scale = 1
        let image = try #require(renderer.nsImage)
        #expect(abs(image.size.width - size.width) < 1 && abs(image.size.height - size.height) < 1,
                "the canvas is the source's size (\(image.size))")
        let tiff = try #require(image.tiffRepresentation)
        let rep = try #require(NSBitmapImageRep(data: tiff))
        var minX = Int.max, maxX = Int.min
        for x in 0..<rep.pixelsWide {
            for y in 0..<rep.pixelsHigh where (rep.colorAt(x: x, y: y)?.alphaComponent ?? 0) > 0.1 {
                minX = min(minX, x); maxX = max(maxX, x)
            }
        }
        #expect(minX < maxX, "the chip is drawn")
        let center = CGFloat(minX + maxX) / 2
        #expect(abs(center - grab.x) < 2, "the chip centres on the grab point (ink \(minX)…\(maxX))")
        #expect(CGFloat(maxX - minX) < 260, "compact — the title, never the full row (\(maxX - minX) pt)")
    }

    // MARK: - Round 1 (librarywalkpolish ladder) — the fix round's pins

    /// **Round 1's MAJOR-1 — the chip is NEVER CUT** (the reviewer's pin, as
    /// specified: red on the shipped canvas). The preview canvas was the
    /// row's own size with the chip centred on the grab, so a grab off the
    /// row's vertical centre, or within half a chip of either end, clipped
    /// it — the reviewer's probe lost 82 of 186 pt (the end of the book's
    /// name) on a trailing-end grab. At a grab 4 pt under the row's top and
    /// one 10 pt short of its trailing end, the rendered chip's ink must be
    /// a bare `BookDragChip`'s whole ink.
    @Test func theChipIsNeverCutAtTheRowsEdges() throws {
        let book = Self.book("Encryption Explained")
        let size = CGSize(width: 800, height: 34)
        let bare = try Self.inkBox(BookDragChip(book: book, tokens: .studyLight))
        for grab in [CGPoint(x: 600, y: 4), CGPoint(x: 790, y: 17)] {
            let ink = try Self.inkBox(BookDragSource.canvas(
                book: book, tokens: .studyLight, size: size, grab: grab))
            #expect(abs(ink.width - bare.width) <= 1 && abs(ink.height - bare.height) <= 1,
                    "a grab at \(grab) draws the whole chip — ink \(ink.size), bare \(bare.size)")
        }
    }

    static func book(_ name: String) -> Queries.ShelfBook {
        let made = Date(timeIntervalSince1970: 1_782_864_000)
        return Queries.ShelfBook(
            reading: Reading(id: "b", name: name, kind: .book, createdAt: made, updatedAt: made),
            postCount: 0, sectionCount: 0, arrivalCount: 0)
    }

    /// The rendered view's canvas and the box its ink covers (alpha over
    /// ~10 %), at scale 1 — rows counted from the TOP.
    static func render<V: View>(_ view: V) throws -> (canvas: CGSize, ink: CGRect) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1
        let image = try #require(renderer.cgImage)
        let (width, height) = (image.width, image.height)
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress, width: width, height: height, bitsPerComponent: 8,
                bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        try #require(drawn)
        var (minX, minY, maxX, maxY) = (Int.max, Int.max, Int.min, Int.min)
        for y in 0..<height {
            for x in 0..<width where pixels[(y * width + x) * 4 + 3] > 25 {
                minX = min(minX, x); maxX = max(maxX, x)
                minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        try #require(minX <= maxX, "something is drawn")
        return (CGSize(width: width, height: height),
                CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1))
    }

    static func inkBox<V: View>(_ view: V) throws -> CGRect { try render(view).ink }

    /// **Round 1's NIT-3 — the strip's drop outlines ask the rule** (the
    /// source pin, committed AHEAD of the fix: red on the shipped strip,
    /// whose "starred" word and shelf names outlined for ANY hovering drag —
    /// an already-starred book over "starred", a book over its OWN shelf's
    /// name, a shelf name over itself — each releasing into a silent guard).
    /// W-5's rule completes: an outline lights only where the drop acts.
    @Test func theStripsOutlinesAskTheRule() throws {
        let strip = try String(
            contentsOf: Self.appRoot.appending(path: "Variorum/Features/Shelf/BookcaseStrip.swift"),
            encoding: .utf8)
        #expect(strip.contains("model.starredDropLights()"),
                "the starred word outlines only for a book its drop would star")
        #expect(strip.components(separatedBy: "model.shelfNameDropLights(").count - 1 >= 2,
                "a shelf name (the strip's and the ⋯ panel's) outlines only where its drop acts")
    }
}
