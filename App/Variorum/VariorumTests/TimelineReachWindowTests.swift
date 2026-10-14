//
//  TimelineReachWindowTests.swift
//  VariorumTests (Mac)
//
//  VX-281 ladder round 1, R1-1 (BLOCKER) — THE TIMELINE'S REACH HOLD IS
//  VIEWPORT-SHAPED. U2's Timeline held the shared icon's reach over EVERY row
//  she had loaded (`.task(id: items)`); each "Load More" grew the set by a page,
//  and the batch reads `container` (`mcpNoteFacts`) once an approved client
//  holds a live grant or the open book is on — so every autosave re-ran one
//  read over all the pages she had paged through, while the Timeline was
//  mounted (a split pane beside an editor included). Against U2's own
//  acceptance line ("P1: reach is read in proportion to the rows shown") and
//  the house rule at `AppDatabase.observe` ("a held observation's fetch must
//  itself be viewport-shaped").
//
//  The fix holds reach over the Library's own near window (`NearWindow` — the
//  pages around the rows on screen, quantized to the Timeline's pages), moved
//  by the rows' appear/disappear reports.
//
//  RED ON OLD, stated: the pre-fix tree cannot compile `reachIDs` (the hold's
//  ids were an inline expression), so the red tree is the SEAM commit — the
//  seam answering exactly what the old view held (every loaded row). Both legs
//  read red there: 350 ids held, the top of the list never left.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-281 R1-1 — the Timeline's reach hold is the window on screen, never every loaded page", .serialized)
struct TimelineReachWindowTests {
    private func withWorld<T>(_ body: @MainActor (AppSession) async throws -> T) async throws -> T {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 2811))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    /// `count` notes (each with a block, so each carries the Timeline's stamp),
    /// an approved client, and the open book on — so EVERY row is reached and
    /// the batch read is the live one (its `container` region included).
    private func world(_ session: AppSession, notes count: Int) throws {
        let ops = session.operations
        let client = try ops.recordMCPContact(name: "r11-client", version: "1")
        try ops.approveMCPClient(client.id, granting: nil)
        try ops.setMCPSwitch(.openBook, on: true)
        for index in 0..<count {
            let note = try ops.createPost(title: String(format: "timeline note %03d", index))
            _ = try ops.newBlock(in: note.id, text: "words of \(index)", registeringUndo: false)
        }
    }

    /// Seven pages loaded — her six "Load More" presses after the first page.
    private func loadSevenPages(_ model: TimelineViewModel) async {
        await model.reload()
        for _ in 0..<6 { await model.loadMore() }
    }

    /// Wait (bounded, ~4 s) for a condition a held observation settles.
    private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<400 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    /// The bound: the pages around what is on screen — the visible rows' pages
    /// and one beyond on each side, a screen spanning at most two pages.
    private func bound(_ model: TimelineViewModel) -> Int { 4 * model.pageSize }

    // MARK: - The model leg (the rows' own reports, driven by hand)

    @Test func theHoldIsThePagesAroundTheRowsOnScreenNeverEveryLoadedPage() async throws {
        try await withWorld { session in
            try world(session, notes: 360)
            let model = TimelineViewModel(session: session)
            await loadSevenPages(model)
            #expect(model.items.count >= 300, "non-vacuity: \(model.items.count) rows loaded")
            #expect(!model.exhausted)

            // Nothing on screen yet: the first page and the next.
            #expect(model.reachIDs.count <= 2 * model.pageSize,
                    "a fresh listing holds its first two pages, not \(model.reachIDs.count) rows")
            #expect(model.reachIDs.first == model.items.first?.postID)

            // She is looking at rows 280–299 (each row reports itself).
            let shown = Array(model.items[280..<300])
            for item in shown { model.rowAppeared(item.postID) }
            let held = model.reachIDs
            #expect(held.count <= bound(model),
                    "the hold is the window (≤ \(bound(model))), never the \(model.items.count) loaded — held \(held.count)")
            #expect(Set(shown.map(\.postID)).isSubset(of: Set(held)), "the rows on screen are held")
            #expect(!held.contains(model.items[0].postID), "the top of the list left the hold")

            // …and the reach lands for exactly the rows she sees.
            let hold = Task { await model.holdReach(model.reachIDs) }
            defer { hold.cancel() }
            #expect(try await settle { model.reach[shown[0].postID]?.first?.viaOpenBook == true },
                    "a row on screen wears the open book's reach")

            // The window follows her back to the top (the rows report leaving).
            for item in shown { model.rowDisappeared(item.postID) }
            let top = Array(model.items[0..<20])
            for item in top { model.rowAppeared(item.postID) }
            #expect(model.reachIDs.contains(top[0].postID), "back at the top, the top is held")
            #expect(model.reachIDs.count <= bound(model))
        }
    }

    // MARK: - The mounted leg (the real List's own reports, scrolled)

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, timeout: TimeInterval) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
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

    /// The List's scroll view (the tallest document on screen) to its very end.
    private func scrollToTheEnd(_ window: NSWindow, _ hosting: NSView) async {
        for _ in 0..<4 {
            guard let scroll = Self.scrollViews(in: hosting)
                .max(by: { ($0.documentView?.frame.height ?? 0) < ($1.documentView?.frame.height ?? 0) }),
                  let document = scroll.documentView
            else { return }
            let clip = scroll.contentView
            clip.scroll(to: NSPoint(x: 0, y: max(0, document.frame.height - clip.bounds.height)))
            scroll.reflectScrolledClipView(clip)
            await settle(window, hosting, timeout: 0.4)
        }
    }

    @Test func scrolledToTheEndTheHeldRowsAreTheEndsNeverTheWholeListing() async throws {
        try await withWorld { session in
            try world(session, notes: 360)
            let model = TimelineViewModel(session: session)
            await loadSevenPages(model)
            let first = try #require(model.items.first?.postID)
            let last = try #require(model.items.last?.postID)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 520),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: TimelineView(session: session, model: model) { _ in })
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 520)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, timeout: 1)
            #expect(model.reachIDs.contains(first), "non-vacuity: the top is held while it shows")

            await scrollToTheEnd(window, hosting)
            let held = model.reachIDs
            #expect(held.contains(last), "the rows at the end — on screen now — are held")
            #expect(held.count <= bound(model),
                    "the hold is the window (≤ \(bound(model))), never the \(model.items.count) loaded — held \(held.count)")
            #expect(!held.contains(first), "the top of the list left the hold as it left the screen")
        }
    }
}
