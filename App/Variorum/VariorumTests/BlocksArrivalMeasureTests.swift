//
//  BlocksArrivalMeasureTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch G — **row 83: Blocks arrives PAINTED.**
//  Batch C measured the mode's first paint EMPTY for ~0.25–0.5 s on the
//  215-block story (the tool row up, the list blank) until the observations'
//  first delivery. The workbench now PRIMES its rows with one bounded read
//  before the observation starts and lets the sibling observations wait for
//  it. This is the MEASURE (the `ModesSherlockMeasureTests` shape): the real
//  workbench mounted on a 215-block note, the time from mount to the first
//  painted row printed and held under a ceiling. The ceiling is a sanity
//  bound (the harness is an in-memory store on a loaded box — the
//  latency-pin lesson); the batch record carries the measured numbers on
//  both trees, and the USE gate's timing series on the dev store is the
//  evidence her hands feel.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Blocks arrives painted (correction round, row 83)", .serialized)
struct BlocksArrivalMeasureTests {
    /// The sanity ceiling — two orders above a primed arrival on the
    /// in-memory store, well under the ~0.25–0.5 s she saw on the dev store.
    static let ceiling: TimeInterval = 1.5

    private func pump(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    @Test func theFirstRowPaintsWithinTheCeilingOnATwoHundredBlockNote() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 83))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the boscombe valley mystery")
            for i in 1...215 {
                _ = try session.operations.newBlock(
                    in: post.id, text: "Block \(i): a sentence of the story, long enough to read as prose.")
            }
            #if DEBUG
            // Row 50: this pin's OWN workbench, named by its own session.
            let workbench = BlocksWorkbenchOracle.reader(session.debugProbeScope)
            workbench.reset()
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BlocksWorkbenchView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            let mountedAt = Date()
            window.makeKeyAndOrderFront(nil)
            #if DEBUG
            let deadline = Date().addingTimeInterval(6)
            while Date() < deadline, workbench.firstRowPaintedAt == nil {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump(0.005)
                await Task.yield()
            }
            let painted = try #require(workbench.firstRowPaintedAt, "the list painted a row")
            let elapsed = painted.timeIntervalSince(mountedAt)
            print("[batch-g row 83] Blocks: mount → first painted row in \(elapsed) s (ceiling \(Self.ceiling) s)")
            #expect(elapsed <= Self.ceiling,
                    "the first row paints within \(Self.ceiling) s of the mount: \(elapsed)")
            #endif
        }
    }

    /// **VX-223 — a Blocks row's ⋯ pops at menu size** (her report: "very
    /// small text … in Blocks"). The row's controls carry `.controlSize(.mini)`
    /// for the ↑ ↓ keys and the ⋯ beside them inherited it — its popped rows
    /// drew at the mini 9 pt. RED ON OLD by that mechanism; the class lives in
    /// `ChromeMenuRowSizeTests`. (Hosted here: this suite owns the
    /// workbench's mount.)
    @Test func theRowMenuPopsAtMenuSize() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 223))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a few blocks")
            for i in 1...3 {
                _ = try session.operations.newBlock(in: post.id, text: "Block \(i) of the note.")
            }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: BlocksWorkbenchView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            #if DEBUG
            let workbench = BlocksWorkbenchOracle.reader(session.debugProbeScope)
            workbench.reset()
            #endif
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            // Wait for the ROWS (the header's own menus exist before them, so
            // counting pop-ups alone could pass before a row's ⋯ is built).
            #if DEBUG
            let deadline = Date().addingTimeInterval(6)
            while Date() < deadline, workbench.firstRowPaintedAt == nil {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump(0.01)
                await Task.yield()
            }
            #expect(workbench.firstRowPaintedAt != nil, "the list painted its rows")
            #endif
            for _ in 0..<20 {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump(0.01)
                await Task.yield()
            }
            let sizes = ChromeMenuProbe.rowSizes(in: hosting)
            #expect(sizes.count >= 3, "each of the three rows built its ⋯ (\(sizes))")
            #expect(sizes.allSatisfy { $0 >= ChromeMenuProbe.menuSize },
                    "every popped row reads at menu size, never mini: \(sizes)")
        }
    }
}
