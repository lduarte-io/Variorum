//
//  BookcaseQuickEntryPlacementTests.swift
//  VariorumTests
//
//  13s-b U1a, piece 1 — R-13s-3, her words: *"please make the 'new note, just
//  start typing' default to being at the bottom of the page again (above the
//  bottom bar, but not right up next to books)."*
//
//  A DESIGN row (her ruling), so its pin is a GEOMETRY ORACLE rather than a
//  red-on-old bug pin: the board's own record of where things sit
//  (`BookcaseRowOracle.frame`, `.global` — top-left origin, y grows down).
//  What the ruling says, as geometry:
//    · the box sits directly ABOVE the bottom bar (its foot meets the bar's
//      top — nothing between them while no tour offer is showing);
//    · on a short board there is AIR between the last book and the box (the
//      R102 hug that seated it right under the rows is retired);
//    · on a board taller than the window, the box stays on screen above the
//      bar and the rows scroll above it (R3's "max height + scrollable").
//
//  On the pre-U1a tree the first and second expectations are red by
//  construction (the box rode right under the rows, with a Spacer between it
//  and the bar); recorded, not run — taste rows take an oracle, not a revert.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13s-b U1a — the quick-entry box sits at the Bookcase's foot", .serialized)
struct BookcaseQuickEntryPlacementTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, turns: Int = 150, until predicate: () -> Bool
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// The mounted root's own frame, read in the SAME `.global` space the
    /// board's oracle records in (the stage window's lesson: the first draft
    /// compared a `.global` frame with the content view's height).
    @MainActor
    private final class RootFrame {
        var frame: CGRect?
    }

    /// Mounts the Bookcase over `bookCount` books in a 900×640 window and
    /// hands the body the frames it needs (`root` = the whole mounted board).
    private func onTheBookcase(
        bookCount: Int,
        _ body: (_ rows: [CGRect], _ entry: CGRect, _ hint: CGRect, _ root: CGRect) throws -> Void
    ) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "bookcase-entry-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            var ids: [String] = []
            for n in 0..<bookCount {
                ids.append(try ops.createReading(
                    name: String(format: "book %02d", n), kind: .book).id)
            }
            let model = ShelfViewModel(session: session, defaults: defaults)
            BookcaseRowOracle.forgetAll()

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 640),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let root = RootFrame()
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model,
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {})
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    root.frame = $0
                })
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.close()
            }

            let first = ids.first
            await settle(window, hosting) {
                BookcaseRowOracle.frame(BookcaseRowOracle.entryKey) != nil
                    && BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey) != nil
                    && (first.map { BookcaseRowOracle.frame($0) != nil } ?? true)
            }
            // A few more turns so the board's async load has landed every row
            // it is going to draw.
            await settle(window, hosting, turns: 30) { false }
            let rows = ids.compactMap { BookcaseRowOracle.frame($0) }
            let entry = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.entryKey))
            let hint = try #require(BookcaseRowOracle.frame(BookcaseRowOracle.hintBarKey))
            let board = try #require(root.frame, "the mounted root reported its frame")
            print("[13s U1a entry placement] books \(bookCount) · root \(board) · entry \(entry) · bar \(hint) · window frame \(window.frame.size) · content \(window.contentView?.bounds.size ?? .zero)")
            try body(rows, entry, hint, board)
        }
        #endif
    }

    @Test func onAShortBoardTheBoxSitsAboveTheBarWithAirAboveIt() async throws {
        try await onTheBookcase(bookCount: 2) { rows, entry, hint, _ in
            #expect(rows.count == 2, "both books drew a row")
            #expect(abs(entry.maxY - hint.minY) < 1.5,
                    "the box's foot meets the bottom bar's top (entry \(entry), bar \(hint))")
            let lastRowFoot = rows.map(\.maxY).max() ?? 0
            #expect(entry.minY - lastRowFoot > 200,
                    "air between the last book and the box, never right under the rows (last row foot \(lastRowFoot), box top \(entry.minY))")
        }
    }

    @Test func onABoardTallerThanTheWindowTheBoxStaysOnScreenAboveTheBar() async throws {
        try await onTheBookcase(bookCount: 40) { _, entry, hint, root in
            #expect(abs(entry.maxY - hint.minY) < 1.5,
                    "the box still meets the bar (entry \(entry), bar \(hint))")
            // Both sides in ONE space: the bar's foot against the mounted
            // board's own foot (the first draft read a `.global` frame against
            // the content view's height — the stage window's red, recorded in
            // the U1a RECORD).
            #expect(hint.maxY <= root.maxY + 1.5,
                    "the bar and the box above it stay inside the window (bar foot \(hint.maxY), board foot \(root.maxY))")
            #expect(root.height <= 640 + 1.5,
                    "the board itself is no taller than the window's content (\(root.height))")
            #expect(entry.height > 20, "the box drew whole")
        }
    }
}
