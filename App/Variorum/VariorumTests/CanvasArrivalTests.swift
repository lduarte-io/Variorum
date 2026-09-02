//
//  CanvasArrivalTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch G — **row 88 (R-cor-11(3)):** (a) a
//  FIRST arrival on a never-arranged canvas lands through the fit-all door
//  — never mid-bank (the orchestrator's walk: the 215-card story opened
//  with the viewport in the middle of its spread grid, edges clipped);
//  (b) the top strip is in the calm-chip grammar — no system picker beside
//  a label. RED ON OLD: (a) no arrival landing existed (the oracle stays
//  nil); (b) the strip composed a `Picker`.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Canvas arrives fitted and its strip is calm (correction round, row 88)", .serialized)
struct CanvasArrivalTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    @Test func theArrivalRuleFitsOnlyANeverArrangedBoardOnce() {
        #expect(CanvasArrival.fitsAllOnArrival(cards: 30, storedPositions: 0, alreadyFitted: false))
        #expect(!CanvasArrival.fitsAllOnArrival(cards: 30, storedPositions: 3, alreadyFitted: false),
                "a remembered layout is left as it was")
        #expect(!CanvasArrival.fitsAllOnArrival(cards: 0, storedPositions: 0, alreadyFitted: false),
                "nothing to fit")
        #expect(!CanvasArrival.fitsAllOnArrival(cards: 30, storedPositions: 0, alreadyFitted: true),
                "once per mount")
    }

    @Test func aNeverArrangedCanvasLandsThroughFitAllAsItsProjectionArrives() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 88))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a spread of cards")
            for i in 1...30 {
                _ = try session.operations.newBlock(in: post.id, text: "Card \(i) of a never-arranged canvas.")
            }
            #if DEBUG
            CanvasArrivalOracle.reset()
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let root = CanvasView(session: session, containerID: post.id)
            let hosting = NSHostingView(
                rootView: root.environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            #if DEBUG
            for _ in 0..<120 {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(20))
                if CanvasArrivalOracle.outcome != nil { break }
            }
            let outcome = try #require(CanvasArrivalOracle.outcome, "the arrival landed through fit-all")
            #expect(outcome != .empty, "…with cards to fit: \(outcome)")
            #endif
            // (b) the strip composes no system picker beside a label.
            let composition = SurfaceComposition.text(of: root.body)
            #expect(!composition.contains("Picker<"), "the tag filter is a calm menu, never a system popup")
            #expect(!composition.contains("\"Tag filter\""), "the redundant label is gone")
        }
    }
}
