//
//  BindDoorTests.swift
//  VariorumTests
//
//  13i-b U3 — the two strengthening doors (the plan §4 item 2; the sitting
//  record §3, §14.6, §19.6) and F-U2-3's pin.
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
private func withBindWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A gathering on `#door` with `count` tagged notes.
@MainActor
private func gathering(
    _ session: AppSession, name: String = "the door", count: Int
) throws -> (reading: Reading, posts: [Container], tag: VariorumCore.Tag) {
    let ops = session.operations
    let tag = try ops.createTag(name: "door")
    let reading = try ops.createReading(
        name: name, kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
    var posts: [Container] = []
    for i in 0..<count {
        let post = try ops.createPost(title: "door \(i)")
        _ = try ops.applyTag(tag.id, toPost: post.id)
        posts.append(post)
    }
    return (reading, posts, tag)
}

private func pump(_ seconds: TimeInterval = 0.2) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

/// Pump and yield until `condition` holds — bounded, so silence fails
/// rather than hangs.
@MainActor
private func settle(until condition: () -> Bool) async {
    for _ in 0..<40 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

@MainActor
@Suite("The bind + spawn doors (13i-b U3)", .serialized)
struct BindDoorTests {
    /// **F-U2-3 — the shelf's bind sheet promised "Its current 0 notes" for
    /// a gathering showing 2** (U2's walk, observed live; the conversion then
    /// kept 2). The COUNT was right — `SmartConversionCount.collected` is
    /// pinned at 3 of 3 (`BookOrderConversionTests`) — so the fault was the
    /// door's PLUMBING. The traced mechanism: the door set a separate
    /// `@State` count and then the sheet's item, and the sheet read the count
    /// inside its content closure; nothing in the shelf's body READ that
    /// count, so no re-render captured its new value, and the closure ran on
    /// a view value whose `@State` snapshot still held the old number (0 on
    /// a first open). The fix carries the count IN the sheet's item.
    ///
    /// Driven through the REAL shelf: the door's own function (the one the
    /// menu item calls), reached through a DEBUG hook because the shelf's
    /// `@State` is unreachable from outside, and the sheet's promise read
    /// from what the presented sheet recorded on appear.
    @Test func theShelfsBindSheetPromisesTheCountTheGatheringShows() async throws {
        try await withBindWorld { session, _ in
            let (reading, _, _) = try gathering(session, count: 2)
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 900, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.attachedSheet.map { window.endSheet($0) }
                window.orderOut(nil)
                window.close()
            }
            BindDoorProbe.shown = nil
            BindDoorProbe.openShelfDoor = nil
            window.contentView = NSHostingView(rootView: ShelfView(
                session: session,
                model: ShelfViewModel(session: session),
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.orderFrontRegardless()
            await settle(until: { BindDoorProbe.openShelfDoor != nil })
            let open = try #require(BindDoorProbe.openShelfDoor, "the shelf mounted its door")

            open(reading)
            await settle(until: { BindDoorProbe.shown != nil })

            let shown = try #require(BindDoorProbe.shown, "the bind sheet presented")
            #expect(shown.readingID == reading.id)
            #expect(shown.count == 2, "the sheet promises the 2 notes the gathering shows")
        }
    }
}
