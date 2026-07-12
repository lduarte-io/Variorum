//
//  BookViewTests.swift
//  VariorumTests
//
//  Phase 10 Step 4 — the continuous book view: the view model adopts the
//  Phase 4 assembly VERBATIM (no re-decided semantics), section headers are
//  a presentation of the query's sectionPath, virtualization is real
//  (off-viewport posts never instantiate — counted, not asserted), the
//  realization cost is ratio-asserted flat as the reading grows, and a
//  sync-gap slot inside a member post renders without crashing.
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
private func withBookWorld<T>(
    posts: Int, blocksPerPost: Int = 3,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "book", kind: .curated)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(
                title: "post \(p)",
                entryDate: String(format: "2026-%02d-%02d", (p / 28) % 12 + 1, p % 28 + 1))
            for b in 0..<blocksPerPost {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Sentence one lives here. Sentence two of block \(b) in post \(p) "
                        + "carries on for a while so the buffer resembles real prose.")
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
private func countReadSurfaces(in view: NSView) -> Int {
    var count = view is ReadPostTextView ? 1 : 0
    for sub in view.subviews { count += countReadSurfaces(in: sub) }
    return count
}

@MainActor
@Suite("Book view (Phase 10 Step 4)", .serialized)
struct BookViewTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// Drives a hosted SwiftUI hierarchy through realization → observation
    /// delivery → re-layout. Two kinds of turns interleave deliberately:
    /// run-loop pumps (layout/display sources) and REAL await suspensions —
    /// a nested `RunLoop.run` never drains the main queue, so main-actor
    /// observation tasks only progress while the test itself is suspended.
    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    @Test func viewModelAdoptsTheAssemblyVerbatim() async throws {
        try await withBookWorld(posts: 6) { session, db, readingID, postIDs in
            // Reorder + archive through operations so the assembly has real
            // shape; the VM must reproduce the QUERY, never its own order.
            try session.operations.reorderReadingPost(
                postIDs[5], in: readingID, to: .start)
            try session.operations.archiveContainer(postIDs[2])
            let assembled = try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            }
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(assembled)
            #expect(model.entries == assembled)
            #expect(model.entries.map(\.postID).contains(postIDs[2]) == false,
                    "archived posts are out of ambient view — the query's call, rendered")
            #expect(model.entries.first?.postID == postIDs[5])
        }
    }

    @Test func theTruncationMarkerNeverFalsePositivesAtExactlyTheWindow() async throws {
        // Round 2 NIT: the +1 probe — a reading of EXACTLY the window size
        // shows no marker; one past it caps the render and marks.
        try await withBookWorld(posts: 1) { session, _, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            func entry(_ i: Int) -> Queries.ReadingEntry {
                Queries.ReadingEntry(postID: "p\(i)", title: nil, entryDate: nil, sectionPath: nil)
            }
            model.adopt((0..<BookViewModel.entryWindow).map(entry))
            #expect(!model.truncated)
            #expect(model.entries.count == BookViewModel.entryWindow)
            model.adopt((0..<(BookViewModel.entryWindow + 1)).map(entry))
            #expect(model.truncated)
            #expect(model.entries.count == BookViewModel.entryWindow,
                    "the probe row is consumed into the flag, never rendered")
        }
    }

    @Test func sectionHeadersRenderExactlyAtSectionBoundaries() async throws {
        try await withBookWorld(posts: 1) { session, _, readingID, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            func entry(_ id: String, section: String?) -> Queries.ReadingEntry {
                Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: section)
            }
            model.adopt([
                entry("a", section: nil),
                entry("b", section: "life/goals"),
                entry("c", section: "life/goals"),
                entry("d", section: "life/travel"),
            ])
            #expect(model.sectionHeader(at: 0) == nil)
            #expect(model.sectionHeader(at: 1) == "life/goals")
            #expect(model.sectionHeader(at: 2) == nil)
            #expect(model.sectionHeader(at: 3) == "life/travel")
        }
    }

    @Test func offViewportPostsNeverInstantiate() async throws {
        try await withBookWorld(posts: 60) { session, db, readingID, _ in
            // The model is injected and hand-driven: the test host never
            // fires SwiftUI's `.task` appearance callbacks (representable
            // lifecycles DO run — the read surfaces' observations start
            // from makeNSView by design).
            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: readingID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) > 0 })
            // Let the surfaces' observations deliver and heights settle.
            await settle(window, hosting, until: { false }, maxTurns: 8)

            let instantiated = countReadSurfaces(in: hosting)
            #expect(instantiated > 0, "the visible posts rendered")
            #expect(instantiated < 30,
                    "a 60-post reading must not instantiate its whole extent: \(instantiated) live read surfaces")
            // And the surfaces carry REAL content — the coordinator-started
            // observations delivered (the projection reached the surface).
            var sawContent = false
            func walk(_ v: NSView) {
                if let read = v as? ReadPostTextView, read.string.contains("Sentence one") {
                    sawContent = true
                }
                for s in v.subviews { walk(s) }
            }
            walk(hosting)
            #expect(sawContent, "read surfaces render their posts' projections")
        }
    }

    @Test func realizationCostStaysFlatAsTheReadingGrows() async throws {
        // The Phase 4 discipline at the view layer: the first realization
        // pass costs the viewport, never the reading. Debug build, generous
        // ratio — this guards the shape, the Step 0 memo owns the numbers.
        func firstLayoutMS(posts: Int) async throws -> Double {
            try await withBookWorld(posts: posts) { session, db, readingID, _ in
                let model = BookViewModel(session: session, readingID: readingID)
                model.adopt(try await db.read { [readingID] in
                    try Queries.assembleReading($0, readingID: readingID, limit: 300)
                })
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 700, height: 800),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                let hosting = NSHostingView(
                    rootView: BookView(session: session, readingID: readingID, model: model))
                hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 800)
                let t0 = ContinuousClock.now
                window.contentView = hosting
                hosting.layoutSubtreeIfNeeded()
                window.orderFrontRegardless()
                window.displayIfNeeded()
                let elapsed = t0.duration(to: .now)
                pump(0.2)
                return Double(elapsed.components.seconds) * 1000
                    + Double(elapsed.components.attoseconds) / 1e15
            }
        }
        let small = try await firstLayoutMS(posts: 20)
        let large = try await firstLayoutMS(posts: 200)
        print("Phase 10 Step 4: book-view first realization — 20 posts \(small) ms · 200 posts \(large) ms")
        #expect(large < small * 5 + 50,
                "realization must not scale with reading size: \(small) ms -> \(large) ms")
    }

    @Test func aSyncGapSlotInsideAMemberPostRendersWithoutCrashing() async throws {
        try await withBookWorld(posts: 2, blocksPerPost: 2) { session, db, readingID, postIDs in
            // Manufacture the SyncSpec §5 gap state (a live placement whose
            // block is dead — only sync apply order produces it locally):
            // tombstone the block (the cascade takes the placement), then
            // revive JUST the placement.
            let slots = try await db.read { [post = postIDs[0]] in
                try Queries.renderPost($0, containerID: post)
            }
            let gapBlock = slots[0].blockID
            try session.operations.deleteBlock(gapBlock)
            try await db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [gapBlock])
            }
            let rendered = try await db.read { [post = postIDs[0]] in
                try Queries.renderPost($0, containerID: post)
            }
            #expect(rendered.count == 2)
            #expect(rendered[0].isGap)

            let model = BookViewModel(session: session, readingID: readingID)
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BookView(session: session, readingID: readingID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { countReadSurfaces(in: hosting) >= 2 })
            // Renders: the gap is an empty slot, the sibling text shows.
            #expect(countReadSurfaces(in: hosting) >= 2)
        }
    }
}
