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
        // The landing from fit-all's verdict: a fitting board on its centre;
        // a board too big to fit at its top-left at 1:1 — never the overview.
        #expect(CanvasArrival.landing(after: .scroll(to: CGPoint(x: 300, y: 200))) == .centre(CGPoint(x: 300, y: 200)))
        #expect(CanvasArrival.landing(after: .overview(scale: 0.3)) == .origin)
        #expect(CanvasArrival.landing(after: .empty) == .none)
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
            let model = CanvasViewModel(session: session, containerID: post.id)
            // Ladder R1-14: the projection PRE-LOADED, so the arrival's
            // `initial: true` fires BEFORE any viewport report — the app's
            // remembered-note case, and exactly where the old decision ran
            // against the 1200 × 800 fallback.
            model.adopt(try await db.read { try Queries.canvasProjection($0, container: post.id) })
            #expect(model.projection.cards.count == 30, "the cards are in hand before the mount")
            let root = CanvasView(session: session, containerID: post.id, model: model)
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
                if CanvasArrivalOracle.landing != nil { break }
            }
            let landing = try #require(CanvasArrivalOracle.landing, "the arrival landed")
            #expect(landing == .origin,
                    "a 30-card spread is too big to fit at 1:1 in 900 × 600, so it lands at its top-left: \(landing)")
            #expect(!model.overviewActive, "…at 1:1 — never in the read-only overview")
            // Ladder R1-14: the decision read a REPORTED viewport — never the
            // 1200 × 800 fallback. (The first report under the test host is
            // the hosting view's provisional layout — 1050 × 649 for a
            // 900 × 600 window, measured — and settles to 900 × 566 after;
            // the row-54 class of first measure, recorded, not chased here.)
            let viewport = try #require(CanvasArrivalOracle.viewport, "the arrival recorded its viewport")
            #expect(viewport != CGSize(width: 1200, height: 800), "never the fallback: \(viewport)")
            #expect(viewport.width > 0 && viewport.height > 0, "a reported viewport: \(viewport)")
            for _ in 0..<20 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                pump()
                await Task.yield()
            }
            let unscaled = try #require(CanvasArrivalOracle.boardContentSize, "the 1:1 board reported its content size")
            // Row 91: the SUMMONED overview's scroll content is the SCALED
            // board — the 1:1 content × the overview's scale, exactly — so
            // the silhouettes fit the viewport (the old ZStack kept its
            // unscaled size and the overview drew off screen).
            let outcome = model.fitAll(viewport: CGSize(width: 900, height: 600))
            guard case .overview(let scale) = outcome else {
                Issue.record("the summoned fit-all opens the overview on a 30-card spread: \(outcome)")
                return
            }
            for _ in 0..<40 {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                pump()
                await Task.yield()
                if let content = CanvasArrivalOracle.boardContentSize, content.width < unscaled.width - 1 { break }
            }
            let content = try #require(CanvasArrivalOracle.boardContentSize, "the board reported its content size")
            #expect(abs(content.width - unscaled.width * scale) <= 1 && abs(content.height - unscaled.height * scale) <= 1,
                    "the overview's content (\(content)) is the 1:1 content (\(unscaled)) × \(scale) — never the unscaled board")
            model.teardown()
            #endif
            // (b) the strip composes no system picker beside a label.
            let composition = SurfaceComposition.text(of: root.body)
            #expect(!composition.contains("Picker<"), "the tag filter is a calm menu, never a system popup")
            #expect(!composition.contains("\"Tag filter\""), "the redundant label is gone")
        }
    }

    /// **Row 92 (found by row 88's walk): a silhouette click in the overview
    /// must return to 1:1 on that card** — the walk's clicks on clear
    /// silhouette centres left the overview standing ("a click that does
    /// nothing is a defect"). A REAL click (the read rig's road: a
    /// non-activating panel, `NSApp.sendEvent`) at the first silhouette's
    /// centre after fit-all summons the overview.
    @Test func aRealClickOnASilhouetteReturnsToOneToOne() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 92))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a spread of cards")
            for i in 1...30 {
                _ = try session.operations.newBlock(in: post.id, text: "Card \(i) of a never-arranged canvas.")
            }
            #if DEBUG
            CanvasArrivalOracle.reset()
            #endif
            let model = CanvasViewModel(session: session, containerID: post.id)
            let window = NSPanel(
                contentRect: NSRect(x: 120, y: 120, width: 900, height: 600),
                styleMask: [.titled, .nonactivatingPanel], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.isFloatingPanel = true
            window.becomesKeyOnlyIfNeeded = false
            window.hidesOnDeactivate = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: AnyView(
                CanvasView(session: session, containerID: post.id, model: model)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 900, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            @MainActor func turn() async {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                let deadline = Date().addingTimeInterval(0.02)
                while Date() < deadline {
                    if let event = NSApp.nextEvent(matching: .any, until: deadline, inMode: .default, dequeue: true) {
                        if event.type == .appKitDefined || event.type == .systemDefined
                            || event.type == .applicationDefined { continue }
                        NSApp.sendEvent(event)
                    }
                }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(15))
            }
            for _ in 0..<120 where CanvasArrivalOracle.landing == nil { await turn() }
            #expect(CanvasArrivalOracle.landing == .origin, "the arrival landed at the top-left at 1:1")
            // Summon the overview (the `fit all` chip's road).
            _ = model.fitAll(viewport: CGSize(width: 900, height: 600))
            for _ in 0..<40 where !model.overviewActive { await turn() }
            #expect(model.overviewActive, "the summoned fit-all opened the overview on a 30-card spread")
            for _ in 0..<20 { await turn() }
            // The scroll view under the strip: the first silhouette sits at
            // the content's top-left (the arrival lands there) — click a
            // point just inside it.
            let scroll = try #require(Self.firstScrollView(in: hosting), "the board's scroll view")
            let inScroll = NSPoint(x: 30, y: scroll.isFlipped ? 30 : scroll.bounds.height - 30)
            let inWindow = scroll.convert(inScroll, to: nil)
            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                guard let event = NSEvent.mouseEvent(
                    with: type, location: inWindow, modifierFlags: [],
                    timestamp: ProcessInfo.processInfo.systemUptime,
                    windowNumber: window.windowNumber, context: nil,
                    eventNumber: 1, clickCount: 1, pressure: type == .leftMouseUp ? 0 : 1)
                else { continue }
                NSApp.sendEvent(event)
                await turn()
            }
            for _ in 0..<40 where model.overviewActive { await turn() }
            #expect(!model.overviewActive,
                    "a click on a silhouette returns the board to 1:1 (the overview's own promise)")
            model.teardown()
        }
    }

    private static func firstScrollView(in view: NSView) -> NSScrollView? {
        if let scroll = view as? NSScrollView { return scroll }
        for sub in view.subviews {
            if let found = firstScrollView(in: sub) { return found }
        }
        return nil
    }
}
