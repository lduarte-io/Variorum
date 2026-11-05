//
//  LibraryReturnRoadTests.swift
//  VariorumTests
//
//  **VX-823 (the VX-828 run, batch C) — THE RETURN ROAD THROUGH THE SHELL
//  ITSELF.** The stage window's walk (window 1) went red on the primary leg:
//  in the real app, with ~47 rows, a title click into a note and ⌥⌘[ back
//  landed the Library at its TOP — the return MARK came back (so the place
//  memory survived the trip), the place did not. The mounted pins
//  (`LibraryReturnPlaceMountTests`) were green because they re-mount the
//  catalog by hand onto a fresh hosting root; this pin walks the road the walk
//  walked: the real `RootView`, the Library reached through `ShellRouter`
//  (the sidebar's own road), a note opened through the catalog's open door's
//  two statements (`rowOpened`, then the shell's `adopt` — `openHit` minus the
//  panel's close), the pane's arm swapped by the shell, and `goBack()` (⌥⌘[).
//
//  THE MECHANISM IT REPRODUCES (the record's "Batch C — THE WALK'S RED"): the
//  return landing waited for this mount's first scroll READING, and
//  `onScrollGeometryChange` calls its action only when the scroll geometry
//  CHANGES — a short listing swapped into an already-sized pane lays out once
//  and never changes, so no reading came and nothing landed. The fix lands as
//  soon as the pane has its proxy and its own height (`onGeometryChange` on the
//  scroll view, which reports at mount). RED under revert R-C4 (the landing
//  gated on a reading again — `landIfReady` requiring `memory.window
//  .isMeasured`). A red here prints the scroll's DEBUG decision log
//  (`LibraryPlaceTrace`) in its message, so a red says which step failed.
//

import AppKit
import CoreGraphics
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-823 — the Library comes back where she left it, through the shell's road", .serialized)
struct LibraryReturnRoadTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(37) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2823))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "vx823-road-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// The walk's shape: a few books, then ~47 notes (the prince's chapters).
    private func library(_ session: AppSession) throws {
        for name in ["the prince", "field guide", "journal", "quicknotes", "sherlock"] {
            _ = try session.operations.createReading(name: name, kind: .book)
        }
        for index in 0..<47 {
            let note = try session.operations.createPost(title: String(format: "chapter %02d", index))
            _ = try session.operations.newBlock(in: note.id, text: "words of chapter \(index)")
        }
    }

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 4,
        until predicate: () -> Bool = { false }
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private static func scrollViews(in view: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        if let scroll = view as? NSScrollView { found.append(scroll) }
        for sub in view.subviews { found += scrollViews(in: sub) }
        return found
    }

    /// The Library's listing: the tallest document in the window (the
    /// sidebar's sections are a few rows each).
    private static func listingScroll(_ hosting: NSView) -> NSScrollView? {
        scrollViews(in: hosting)
            .max { ($0.documentView?.frame.height ?? 0) < ($1.documentView?.frame.height ?? 0) }
    }

    private func realizedIDs(_ model: LibraryCatalogModel) -> Set<String> {
        Set(model.visibleNoteIndices.compactMap {
            model.noteHits.indices.contains($0) ? model.noteHits[$0].id : nil
        })
    }

    /// A row ON SCREEN now (the mounted pins' chooser): realized, nearest the
    /// catalog's vertical middle, its frame in the catalog's own space.
    private func readingRow(_ model: LibraryCatalogModel) -> (id: String, top: CGFloat)? {
        #if DEBUG
        guard let root = LibraryPanelOracle.rootFrame else { return nil }
        let realized = realizedIDs(model)
        return LibraryPanelOracle.noteRowFrames
            .filter { realized.contains($0.key) }
            .min { abs($0.value.midY - root.midY) < abs($1.value.midY - root.midY) }
            .map { ($0.key, $0.value.minY) }
        #else
        return nil
        #endif
    }

    private func top(of id: String, _ model: LibraryCatalogModel) -> CGFloat? {
        #if DEBUG
        guard realizedIDs(model).contains(id) else { return nil }
        return LibraryPanelOracle.noteRowFrames[id]?.minY
        #else
        return nil
        #endif
    }

    /// **The walk's two roads, through the shell.** `openedFromARow`: she
    /// opens the row she is reading by its title (the catalog's open door —
    /// `rowOpened`, then the shell's adopt), and ⌥⌘[ brings her back: the row
    /// back where it sat, wearing the return mark. Otherwise she leaves by the
    /// sidebar (the Bookcase) and comes back: the row where it sat, no mark.
    /// RED under revert R-C4, the walk's own red: the Library at its top.
    @Test(arguments: [true, false])
    func theLibraryComesBackWhereSheLeftItThroughTheShell(openedFromARow: Bool) async throws {
        #if DEBUG
        try await withLibrary { session in
            try library(session)
            LibraryPanelOracle.reset()
            let catalog = LibraryCatalogModel(
                session: session, defaults: try scrubbed(openedFromARow ? "open" : "sidebar"))
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: RootView(
                session: session, router: router, catalog: catalog))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer { window.orderOut(nil); window.close() }
            var log: [String] = []
            LibraryPlaceTrace.sink = { log.append($0) }
            defer { LibraryPlaceTrace.sink = nil }

            // The sidebar's road into the Library.
            router.adopt(.library, in: router.workspace.focusedPane)
            await settle(window, hosting, timeout: 4) {
                catalog.noteHits.count == 47 && LibraryPanelOracle.rootFrame != nil
            }
            try #require(catalog.noteHits.count == 47, "the Library listed")
            await settle(window, hosting, timeout: 0.5)

            // Her scroll, well down the list, and its rest.
            let scroll = try #require(Self.listingScroll(hosting), "the Library's listing")
            let document = try #require(scroll.documentView).frame.height
            let maxOffset = document - scroll.contentView.bounds.height
            try #require(maxOffset > 300, "the listing scrolls (\(maxOffset))")
            scroll.contentView.scroll(to: NSPoint(x: 0, y: (maxOffset * 0.75).rounded()))
            scroll.reflectScrolledClipView(scroll.contentView)
            await settle(window, hosting, timeout: 0.8)
            let reading = try #require(readingRow(catalog), "a row on screen to read")
            let index = try #require(catalog.noteHits.firstIndex { $0.id == reading.id })
            try #require(index > 10, "a row well down the list (\(index))")

            // The trip, through the shell.
            if openedFromARow {
                catalog.rowOpened(reading.id, placeKey: PaneID.primary.raw)
                router.adopt(.post(reading.id), in: router.workspace.focusedPane)
            } else {
                router.adopt(.shelf, in: router.workspace.focusedPane)
            }
            await settle(window, hosting, timeout: 1.2)
            #expect(router.workspace.focusedSelection != .library, "she left the Library")
            log.append("— back —")
            router.goBack()
            await settle(window, hosting, timeout: 4) {
                top(of: reading.id, catalog).map { abs($0 - reading.top) <= 1 } ?? false
            }
            // Past the hold's last check: the place must STAY.
            await settle(window, hosting, timeout: 1.0)

            #expect(router.workspace.focusedSelection == .library)
            let after = top(of: reading.id, catalog)
            #expect(after.map { abs($0 - reading.top) <= 1 } == true,
                    "the row back where it sat: \(after.map { "\($0)" } ?? "not on screen") vs \(reading.top) — trace: \(log.joined(separator: " | "))")
            if openedFromARow {
                #expect(catalog.placeMemory.mark(in: PaneID.primary.raw) == reading.id,
                        "the row she left from wears the return mark")
            }
        }
        #endif
    }
}
