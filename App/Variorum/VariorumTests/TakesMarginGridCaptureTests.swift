//
//  TakesMarginGridCaptureTests.swift
//  VariorumTests
//
//  VX-136 (the VX-143 run) — THE CAPTURE HARNESS behind her report: *"the
//  margin grid items are a little bit weirdly misaligned when you have
//  several - the new take area will push others down and it looks weird."*
//
//  The real board, margin grid at the stored defaults, a three-block note
//  whose middle block carries four takes of very different lengths: bloom it,
//  capture, mint a blank take through the board's own ＋ blank take act,
//  capture again — and print every card's rectangle in the window, so the
//  record can say what moved where.
//
//  It writes into the TEST HOST'S OWN TEMP DIRECTORY and prints the path
//  (`ContextBarCaptureTests`' recorded reason: the host is sandboxed).
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
@Suite("Margin grid captures (VX-136)", .serialized)
struct TakesMarginGridCaptureTests {
    static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-vx136-screens")

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

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

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func capture(_ view: NSView, _ name: String) {
        try? FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            print("[VX-136] no bitmap rep for \(name)")
            return
        }
        view.cacheDisplay(in: view.bounds, to: rep)
        let url = Self.outputDirectory.appendingPathComponent(name)
        if let png = rep.representation(using: .png, properties: [:]) {
            try? png.write(to: url)
            print("[VX-136] wrote \(url.path)")
        }
    }

    private func report(_ label: String, hosting: NSView, takeIDs: [String]) {
        for pane in panes(in: hosting) {
            guard let raw = pane.identifier?.rawValue else { continue }
            let frame = pane.convert(pane.bounds, to: nil)
            var visible = pane.visibleRect
            visible = pane.convert(visible, to: nil)
            let tag = takeIDs.firstIndex { raw.hasSuffix($0) }.map { "take\($0 + 1)" } ?? "-"
            print("[VX-136] \(label) \(raw.prefix(14)) \(tag) frame=\(frame.integral) visible=\(visible.integral)")
        }
    }

    @Test func captureTheRailWithSeveralTakesBeforeAndAfterANewTake() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let defaults = UserDefaults.standard
        let savedRows = defaults.object(forKey: "takesGridRows")
        let savedCols = defaults.object(forKey: "takesGridCols")
        // Her STORED defaults are unknown here; capture the shipped defaults
        // (no key ⇒ the AppStorage default).
        defaults.removeObject(forKey: "takesGridRows")
        defaults.removeObject(forKey: "takesGridCols")
        defer {
            if let savedRows { defaults.set(savedRows, forKey: "takesGridRows") }
            else { defaults.removeObject(forKey: "takesGridRows") }
            if let savedCols { defaults.set(savedCols, forKey: "takesGridCols") }
            else { defaults.removeObject(forKey: "takesGridCols") }
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 136))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let sentence = "Honest prose keeps flowing along the measured line and wraps. "
            let post = try session.operations.createPost(title: "the margin grid")
            _ = try session.operations.newBlock(
                in: post.id, text: String(repeating: sentence, count: 4))
            let middle = try session.operations.newBlock(
                in: post.id, text: String(repeating: sentence, count: 5))
            var takeIDs = [middle.variant.id]
            for count in [14, 1, 7] {
                let take = try session.operations.branchVariant(
                    middle.block.id, from: middle.variant.id)
                try session.operations.autosave(
                    take.id, text: String(repeating: sentence, count: count), charDelta: 9)
                takeIDs.append(take.id)
            }
            _ = try session.operations.newBlock(
                in: post.id, text: String(repeating: sentence, count: 3))
            try session.operations.setFanStyle(.marginGrid)

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1400, height: 1000),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1400, height: 1000)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
            model.toggleExpanded(middle.block.id)
            await settle(window, hosting, until: {
                panes(in: hosting).contains { $0.identifier?.rawValue.hasPrefix("pane:mini|") == true }
            })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            print("[VX-136] density rows=\(model.gridRows) cols=\(model.gridCols)")
            report("before", hosting: hosting, takeIDs: takeIDs)
            capture(hosting, "vx136-before-mint.png")

            // The ＋ blank take door's own act.
            if let minted = await model.newBlankTakeRevealed(blockID: middle.block.id) {
                takeIDs.append(minted.id)
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            report("after", hosting: hosting, takeIDs: takeIDs)
            capture(hosting, "vx136-after-mint.png")

            // The ruled default's shape: two columns.
            model.gridCols = 2
            defaults.set(2, forKey: "takesGridCols")
            await settle(window, hosting, until: { false }, maxTurns: 10)
            report("twowide", hosting: hosting, takeIDs: takeIDs)
            capture(hosting, "vx136-two-wide.png")
        }
    }
}
