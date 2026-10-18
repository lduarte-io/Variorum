//
//  BookOrderConversionTests.swift
//  VariorumTests
//
//  Phase 13c, Batch 2D — the app-side halves of the smart→curated
//  conversion (C2/N38) and book order as a lens (A31).
//
//  The core contract is pinned in `SmartConversionTests` (core suite). This
//  suite pins what only exists up here: the order VOCABULARY (pure), the
//  view-local override actually reaching the assembly, the save door, and
//  the P-2 choreography — "+ new chapter" on a smart book converts and then
//  the chapter really is creatable, which it was not one step earlier.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

/// The leftmost point at which the view has drawn INK (a pixel materially
/// darker than the light chrome behind it), scanned over a vertical band.
///
/// Pixels rather than view frames, deliberately: SwiftUI `Text` is not an
/// `NSView`, and the navigator's clipping showed up in exactly the elements
/// that have no view of their own to interrogate — the post rows, the
/// chapter doors, the notice. This measures what she would see.
@MainActor
private func leftmostInkX(in view: NSView, band: ClosedRange<CGFloat>, maxX: CGFloat) -> CGFloat? {
    guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
    view.cacheDisplay(in: view.bounds, to: rep)
    let scale = CGFloat(rep.pixelsWide) / view.bounds.width
    for px in 0..<Int(maxX * scale) {
        for py in Int(band.lowerBound * scale)...Int(band.upperBound * scale) {
            guard let color = rep.colorAt(x: px, y: py) else { continue }
            let luminance = 0.299 * color.redComponent + 0.587 * color.greenComponent
                + 0.114 * color.blueComponent
            if luminance < 0.6 { return CGFloat(px) / scale }
        }
    }
    return nil
}

@MainActor
private func withBooksWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("Book order + smart conversion faces (13c 2D — A31, N38)", .serialized)
struct BookOrderConversionTests {
    // MARK: - The order vocabulary (pure)

    @Test func theOrderListIsTheRetiredSidebarsListVerbatim() {
        // The Phase 10 sidebar's `sortChoices` — carried over unchanged when
        // `ReadingsSection` was deleted, because its shape was never the
        // problem; its unreachability was.
        #expect(BookOrderChoices.all.map(\.label) == [
            "Manual order", "Entry date ↑", "Entry date ↓",
            "Created ↑", "Created ↓", "Last touched ↓", "Major revision ↓",
        ])
        #expect(Set(BookOrderChoices.all.map(\.id)).count == BookOrderChoices.all.count)
    }

    @Test func anUnlistedStoredPairStillGetsAReadableName() {
        // A book stored with a pair the menu doesn't offer (last-touched
        // ASCENDING, say) must not render a raw enum in chrome.
        #expect(
            BookOrderChoices.label(for: .init(field: .lastTouched, direction: .asc))
                == "last touched ↑")
    }

    @Test func aSmartBooksStoredOrderIsNotCalledManual() throws {
        // `manual` on a smart book falls back to created-ascending (the
        // ratified Phase 4 rule) — calling it "Manual order" in the one
        // place she is choosing an order would be a small lie.
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        let smart = Reading(
            id: "s", name: "collected", kind: .gathering, createdAt: now, updatedAt: now)
        let curated = Reading(
            id: "c", name: "book", kind: .book, createdAt: now, updatedAt: now)
        #expect(BookOrderChoices.storedLabel(for: smart) == "as collected")
        #expect(BookOrderChoices.storedLabel(for: curated) == "Manual order")
        #expect(BookOrderChoices.storedLabel(for: nil) == "book's order")
    }

    // MARK: - The override reaches the assembly, and writes nothing

    @Test func theViewOrderChangesWhatTheBookModelHoldsWithoutTouchingTheBook() async throws {
        try await withBooksWorld { session, db in
            let reading = try session.operations.createReading(name: "book", kind: .book)
            let late = try session.operations.createPost(
                title: "late", entryDate: "2026-09-01")
            let early = try session.operations.createPost(
                title: "early", entryDate: "2026-01-01")
            try session.operations.addPostToReading(late.id, to: reading.id)
            try session.operations.addPostToReading(early.id, to: reading.id)

            let model = BookViewModel(session: session, readingID: reading.id)
            // `start()` reads its order at subscribe time — the same shape
            // the view's `.task(id:)` restart drives.
            model.viewOrder = .init(field: .entryDate, direction: .asc)
            let task = Task { await model.start() }
            try await Task.sleep(for: .milliseconds(120))
            task.cancel()
            #expect(model.entries.map(\.postID) == [early.id, late.id])

            // The BOOK is untouched: its own order still reads hand-order.
            #expect(try await db.read { try Queries.reading($0, id: reading.id)?.sortField } == .manual)
            #expect(
                try await db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == [late.id, early.id])
        }
    }

    @Test func savingTheOrderMakesItTheBooksOwn() async throws {
        try await withBooksWorld { session, db in
            let reading = try session.operations.createReading(name: "book", kind: .book)
            let structure = BookStructureModel(session: session, readingID: reading.id)
            await structure.saveOrder(.init(field: .lastTouched, direction: .desc))
            let row = try #require(await db.read { try Queries.reading($0, id: reading.id) })
            #expect(row.sortField == .lastTouched)
            #expect(row.sortDir == .desc)
            #expect(structure.lastError == nil)
        }
    }

    @Test func aFinishedBookRefusesToSaveAnOrderAndSaysSo() async throws {
        try await withBooksWorld { session, db in
            let reading = try session.operations.createReading(name: "book", kind: .book)
            try session.operations.lockReading(reading.id)
            let structure = BookStructureModel(session: session, readingID: reading.id)
            await structure.saveOrder(.init(field: .entryDate, direction: .asc))
            #expect(structure.lastError != nil)
            #expect(try await db.read { try Queries.reading($0, id: reading.id)?.sortField } == .manual)
        }
    }

    // MARK: - The conversion choreography (P-2)

    @Test func chaptersAreADeadEndBeforeConversionAndReachableImmediatelyAfter() async throws {
        try await withBooksWorld { session, db in
            let tag = try session.operations.createTag(name: "work")
            let spec = try Queries.SmartQuerySpec(tags: ["work"]).encodedJSON()
            let reading = try session.operations.createReading(
                name: "collected", kind: .gathering, querySpec: spec)
            let post = try session.operations.createPost(title: "one")
            _ = try session.operations.applyTag(tag.id, toPost: post.id)

            let structure = BookStructureModel(session: session, readingID: reading.id)
            // Before: the act she asked for is genuinely impossible.
            await structure.createChapter(named: "I")
            #expect(structure.lastError != nil)
            #expect(try await db.read { try Queries.readingSections($0, readingID: reading.id) }.isEmpty)

            // The offer's confirm, then the follow-up the door promised.
            // (13i-b U3: the confirm is the BIND now — same act, same row.)
            let converted = await structure.bind()
            #expect(converted)
            await structure.createChapter(named: "I")
            #expect(structure.lastError == nil)
            #expect(
                try await db.read { try Queries.readingSections($0, readingID: reading.id) }
                    .map(\.name) == ["I"])
            // …and the post it collected is really in the book now.
            #expect(
                try await db.read { try Queries.assembleReading($0, readingID: reading.id) }
                    .map(\.postID) == [post.id])
        }
    }

    /// 13c K6 review, K2 (the face half — red-on-old by behavioral revert:
    /// drop the `order:` forwarding in `BookStructureModel.bind` (13c's `convertToCurated`)
    /// and the memberships land in the STORED order, failing the assertion).
    /// The core half's pin is `conversionUnderAViewOrderOverrideFreezesThe-
    /// OrderSheIsLookingAt` (SmartConversionTests); this one pins the door
    /// the book view actually calls. The one line left unpinned is BookView's
    /// sheet closure passing `model.viewOrder` — stated in the fix record.
    @Test func theNavigatorConversionFreezesTheOrderSheIsBrowsing() async throws {
        try await withBooksWorld { session, db in
            let tag = try session.operations.createTag(name: "work")
            let spec = try Queries.SmartQuerySpec(tags: ["work"]).encodedJSON()
            let reading = try session.operations.createReading(
                name: "collected", kind: .gathering, querySpec: spec)
            var postIDs: [String] = []
            for i in 0..<3 {
                let post = try session.operations.createPost(title: "p\(i)")
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
                postIDs.append(post.id)
            }

            // She is browsing newest-first through the A31 override.
            let looking = Queries.ReadingOrder(field: .createdAt, direction: .desc)
            let structure = BookStructureModel(session: session, readingID: reading.id)
            let converted = await structure.bind(order: looking)
            #expect(converted)

            let frozen = try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            }
            #expect(frozen.map(\.postID) == [postIDs[2], postIDs[1], postIDs[0]],
                    "the conversion froze the order she was browsing, not the stored pair")
        }
    }

    /// 13i-b U3 — the report says the BIND's truth now: the same book,
    /// N notes bound in, and it KEEPS COLLECTING (the sitting record §14.6).
    /// The pre-U3 report ("a hand-shaped book now … “<collector>” keeps
    /// collecting the filter") named the retired "(collecting)" sibling.
    @Test func theShelfReportsWhatTheBindDidRatherThanGoingQuiet() async throws {
        try await withBooksWorld { session, db in
            let tag = try session.operations.createTag(name: "work")
            let spec = try Queries.SmartQuerySpec(tags: ["work"]).encodedJSON()
            let reading = try session.operations.createReading(
                name: "collected", kind: .gathering, querySpec: spec)
            for i in 0..<2 {
                let post = try session.operations.createPost(title: "p\(i)")
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            let model = ShelfViewModel(session: session)
            await model.bind(reading.id)

            #expect(model.lastError == nil)
            let report = try #require(model.lastReport)
            #expect(report == BindCopy.bound("collected", count: 2))
            #expect(report.contains("2 notes bound in"))
            #expect(report.contains("keeps collecting"))
            #expect(try await db.read { try Queries.readings($0).count } == 1,
                    "no \"(collecting)\" sibling — the ruling's own clause")
        }
    }

    @Test func theSessionsUndoDoorReachesAConversionMadeFromTheShelf() async throws {
        // QUESTIONS #46 tells her "⌥⌘Z puts the smart book back exactly".
        // `structuralUndo` is an APP-scope capability gated only on
        // `undoAvailable`, so the shelf is not a special case — but the
        // claim is only true if the shelf's writes ride the SESSION's
        // stack, which is what this pins.
        try await withBooksWorld { session, db in
            let tag = try session.operations.createTag(name: "work")
            let spec = try Queries.SmartQuerySpec(tags: ["work"]).encodedJSON()
            let reading = try session.operations.createReading(
                name: "collected", kind: .gathering,
                sortField: .entryDate, sortDir: .desc, querySpec: spec)
            let post = try session.operations.createPost(title: "one")
            _ = try session.operations.applyTag(tag.id, toPost: post.id)

            let model = ShelfViewModel(session: session)
            await model.bind(reading.id)
            #expect(session.undoStack.topLabel == "Convert to Book")

            let stack = session.undoStack
            try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            let back = try #require(await db.read { try Queries.reading($0, id: reading.id) })
            #expect(back.kind == .gathering)
            #expect(back.sortField == .entryDate)
            #expect(back.sortDir == .desc)
            // One row throughout — the bind mints no sibling (13i-b U3).
            #expect(try await db.read { try Queries.readings($0).count } == 1)
        }
    }

    @Test func aRefusedConversionSpeaksAndClearsTheReport() async throws {
        try await withBooksWorld { session, _ in
            let reading = try session.operations.createReading(
                name: "already hand-shaped", kind: .book)
            let model = ShelfViewModel(session: session)
            await model.bind(reading.id)
            #expect(model.lastReport == nil)
            // The direction-aware message: a BOOK asked to bind throws
            // `expected: .gathering`, and the old copy stated the other
            // direction ("Only curated readings hold a hand-picked post
            // list"), which read as nonsense here. (13i-b U3: worded for the
            // bind door — the door 13c 2D shipped as "convert".)
            #expect(model.lastError == "That's already a book — only a gathering binds into one.")
        }
    }

    // MARK: - The navigator fits its own column (the b6dae25 chrome class)

    @Test func theNavigatorsChromeStaysInsideItsColumn() async throws {
        // RED on the pre-fix code (verified by behavioral revert: removing
        // `.controlSize(.small)` from the mode picker puts the segmented
        // control at minX ≈ -9.5, i.e. drawn LEFT of the window edge).
        //
        // The defect is PRE-EXISTING (2A-era) and was found by this batch's
        // visual loop: `.frame(width: 190)` does not clip an over-wide
        // child, it CENTERS it — so a picker whose minimum exceeded the
        // column pushed the entire navigator left and every row lost its
        // first character. The pin is on the CONTAINMENT, not on the
        // remedy: any future control that over-runs the column fails here.
        try await withBooksWorld { session, db in
            let reading = try session.operations.createReading(name: "orbit", kind: .book)
            let post = try session.operations.createPost(title: "one")
            try session.operations.addPostToReading(post.id, to: reading.id)

            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            })
            let structure = BookStructureModel(session: session, readingID: reading.id)
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: reading.id) },
                sections: [], deletedSections: [], assignments: [:]))

            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: 1000, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            // VX-77 (R-U2-B): the scan reads LUMINANCE — a host left dark (the
            // test host IS the dev-store app) draws a black room the scan reads
            // as "ink at 0.0". Pinned light, so the verdict is the chrome's.
            window.appearance = NSAppearance(named: .aqua)
            defer { window.orderOut(nil); window.close() }
            let hosting = NSHostingView(
                rootView: BookView(
                    session: session, readingID: reading.id, model: model,
                    structure: structure))
            hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            for _ in 0..<6 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                try await Task.sleep(for: .milliseconds(40))
            }

            // The navigator's own band, below the header rows, where the
            // post list and the chapter doors live.
            let leftMargin = try #require(
                leftmostInkX(in: hosting, band: 60...260, maxX: 40))
            #expect(
                leftMargin >= 6,
                "navigator content clipped at the window edge: ink at \(leftMargin) pt")
        }
    }

    @Test func theOfferPromisesTheDERIVEDCountNotTheShelfsMembershipCount() async throws {
        // The shelf's own `postCount` counts `reading_post` rows, and a
        // smart book has none — the sheet would have promised "0 posts
        // stay" on every book it is ever shown for.
        try await withBooksWorld { session, db in
            let tag = try session.operations.createTag(name: "work")
            let spec = try Queries.SmartQuerySpec(tags: ["work"]).encodedJSON()
            let reading = try session.operations.createReading(
                name: "collected", kind: .gathering, querySpec: spec)
            for i in 0..<3 {
                let post = try session.operations.createPost(title: "p\(i)")
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            let shelfCount = try await db.read { db in
                try Queries.bookshelf(db).first { $0.reading.id == reading.id }?.postCount
            }
            #expect(shelfCount == 0)
            let promised = await SmartConversionCount.collected(session, readingID: reading.id)
            #expect(promised == 3)
            // And it IS the number of rows minted.
            let result = try session.operations.convertSmartReadingToCurated(reading.id)
            #expect(result.membershipIDs.count == promised)
        }
    }
}
