//
//  TakesEmptyBlockFaceTests.swift
//  VariorumTests
//
//  17p batch a (the 2026-09-12 use-report round, ledger row 2) — HER RULING
//  R-Q2, "no placeholder anywhere": *"the invitation to write a block is
//  weird… The empty take — line kept instruction is not good… I want it to
//  return to what it used to look like."*
//
//  An empty block in Takes is an empty LINE, exactly as Write renders it, and
//  the article's ＋ new block door lines up with the prose rather than with
//  the cell. Both are FACE claims about a REAL mount, and a SwiftUI `Text` or
//  `Button` is drawn, not an `NSView` (KnownIssues' rig row) — so both are
//  measured through DEBUG render oracles the views themselves feed, the
//  `TakesEmptyStateDoors` / `LensesGeometry` pattern. (The accessibility tree
//  was tried first and is NOT an option here: a hosted board reports exactly
//  one AX element, the hosting view itself, with no children — measured.)
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
@Suite("The empty block's face and the article door's edge (17p a, row 2)", .serialized)
struct TakesEmptyBlockFaceTests {

    // MARK: - Harness

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

    private func articlePanes(in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
    }

    /// A note whose LAST block is empty — 18c's Return mints one at every
    /// paragraph break, so this is the everyday shape, not a corner.
    private func withBoard(
        _ body: @MainActor (
            _ hosting: NSHostingView<TakesBoardView>, _ window: NSWindow,
            _ model: TakesViewModel
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        // The model's OWN defaults (the sibling suite's rule): the test host
        // is the dev-store app, `.standard` is shared with every suite and
        // with hand walks, and `.incrementing` mints the same post id in every
        // world (the R1-7 class, KnownIssues, owner 12).
        let suiteName = "TakesEmptyBlockFace-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "empty block fixture")
            _ = try session.operations.newBlock(in: post.id, text: "Paragraph one.")
            _ = try session.operations.newBlock(in: post.id, text: "Paragraph two is a line.")
            _ = try session.operations.newBlock(in: post.id, text: "")

            let model = TakesViewModel(session: session, postID: post.id, defaults: defaults)
            model.landingEnabled = true
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            TakesCellChrome.reset()
            TakesArticleDoorProbe.reset()
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !articlePanes(in: hosting).isEmpty })
            await settle(window, hosting, until: { false }, maxTurns: 8)
            try await body(hosting, window, model)
        }
    }

    // MARK: - R-Q2: an empty block is an empty line

    /// **RED ON THE PRE-FIX CODE.** Phase 13 batch 9's R103 overlay
    /// ("empty take — line kept") was written for a take deleted down to
    /// nothing; 18c's Return and 17o's ＋ new block door made empty blocks
    /// everyday, so the words greeted a block she had just made — and under
    /// the indicator OFF, where a live pane draws no ring, the caret sat in
    /// the middle of them. Her ruling retires the FACE and keeps the
    /// SUBSTANCE: the line itself is still there.
    @Test func anEmptyBlockShowsNoPlaceholderWords() async throws {
        try await withBoard { hosting, _, _ in
            let words = TakesCellChrome.overlayWords
            #expect(words.count == 3,
                    "non-vacuity: all three cells reported what they drew (\(words.count))")
            let all = words.values.flatMap { $0 }
            #expect(all.isEmpty,
                    """
                    a take cell draws NO words over its pane — an empty block \
                    is an empty line, as Write renders it (found: \(all))
                    """)
        }
    }

    /// R103's SUBSTANCE, which her ruling keeps: the empty block still has a
    /// row of its own on the board — the line is not removed, only the words
    /// that described it.
    @Test func theEmptyBlockStillHasItsOwnRow() async throws {
        try await withBoard { hosting, _, model in
            #expect(model.projection.slots.count == 3)
            #expect(articlePanes(in: hosting).count == 3,
                    "the empty block keeps its own pane — the line is kept")
        }
    }

    // MARK: - R-Q2's second half: the door lines up with the prose

    /// **RED ON THE PRE-FIX CODE.** The in-article ＋ new block door padded
    /// from the CELL's edge while the prose sits a pane inset plus the cell's
    /// own padding further in — ~8 pt of daylight she reads as misalignment
    /// (her image 2). Measured through the accessibility frame of the real
    /// button against the real pane's text origin.
    @Test func theNewBlockDoorsEdgeSitsOnTheProsesEdge() async throws {
        try await withBoard { hosting, window, _ in
            guard let pane = articlePanes(in: hosting).first else {
                Issue.record("no article pane")
                return
            }
            guard let door = TakesArticleDoorProbe.frame else {
                Issue.record("the ＋ new block door reported no frame")
                return
            }
            // The prose's left edge: the pane's own text origin, in the same
            // WINDOW x-space the SwiftUI probe reports (x is unaffected by the
            // two frameworks' opposite y conventions).
            let textOriginInPane = NSPoint(x: pane.textContainerInset.width, y: 0)
            let textLeft = pane.convert(textOriginInPane, to: nil).x

            #expect(door.width > 10, "non-vacuity: the door has a real frame (\(door))")
            #expect(pane.textContainerInset.width > 0,
                    "non-vacuity: the pane really does inset its text")
            #expect(abs(door.minX - textLeft) < 1,
                    """
                    the door's leading edge sits on the prose's left edge \
                    (door \(door.minX), prose \(textLeft), off by \
                    \(door.minX - textLeft)) — before the fix it was padded \
                    from the CELL's edge instead, leaving the daylight she \
                    read as misalignment
                    """)
            _ = window
        }
    }
}
