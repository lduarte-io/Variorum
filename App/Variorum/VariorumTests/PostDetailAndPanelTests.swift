//
//  PostDetailAndPanelTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the brief's zero-test-view obligation:
//  PostDetailView and WriteTakesPanel gain focused coverage as they are
//  touched. PostDetailView: the mode-memory brain (R79's takes-first
//  default + per-post persistence). WriteTakesPanel: the panel renders
//  the block's whole fan on the unified pane surface, and an edit typed
//  through the REAL pane path lands in the store through the post's ONE
//  shared coordinator (the N3 shape, end to end).
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
@Suite("PostDetail mode memory (13b 1a)")
struct PostDetailModeMemoryTests {
    private func freshDefaults(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: "PostDetailTests-\(name)")!
        defaults.removePersistentDomain(forName: "PostDetailTests-\(name)")
        return defaults
    }

    @Test func aPostOpensInTakesFirstThenWhereItWasLeft() {
        let defaults = freshDefaults("memory")
        // R79: the first open is TAKES.
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .takes)
        // Thereafter: whatever mode was last used THERE (per post).
        defaults.set("Lenses", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .lenses)
        #expect(PostDetailView.rememberedMode(postID: "p2", defaults: defaults) == .takes,
                "memory is per-post")
        // A stale/unknown value falls back to the default, never crashes.
        defaults.set("NotAMode", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .takes)
    }

    @Test func theModeVocabularyIsTheSevenModeRail() {
        #expect(PostDetailView.Mode.allCases.map(\.rawValue) ==
                ["Write", "Takes", "Lenses", "Compare", "Outline", "Blocks", "Canvas"])
    }
}

@MainActor
@Suite("WriteTakesPanel (13b 1a)", .serialized)
struct WriteTakesPanelTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
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
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panelPanes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView,
           pane.identifier?.rawValue.hasPrefix("pane:panel|") == true {
            found.append(pane)
        }
        for sub in view.subviews { found.append(contentsOf: panelPanes(in: sub)) }
        return found
    }

    @Test func thePanelRendersTheFanAndEditsLandThroughTheSharedCoordinator() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let (postID, blockID, takeIDs): (String, String, [String]) = try {
                let post = try session.operations.createPost(title: "panel post")
                let minted = try session.operations.newBlock(in: post.id, text: "the chosen take")
                let branch = try session.operations.branchVariant(
                    minted.block.id, from: minted.variant.id)
                try session.operations.autosave(
                    branch.id, text: "the other take", charDelta: 6)
                return (post.id, minted.block.id, [minted.variant.id, branch.id])
            }()

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 800, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: WriteTakesPanel(session: session, postID: postID, blockID: blockID))
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { panelPanes(in: hosting).count >= 2 })

            // The whole fan renders as panel cards (the one v2 grammar).
            let panes = panelPanes(in: hosting)
            #expect(panes.count == 2, "both takes render (found \(panes.count))")
            let rendered = Set(panes.compactMap {
                $0.identifier?.rawValue.dropFirst("pane:panel|".count)
            }.map(String.init))
            #expect(rendered == Set(takeIDs), "the cards are exactly the fan")

            // Click-to-focus, then type through the REAL pane path (the
            // NSTextView edit pipeline → onEdit → paneEdited → the post's
            // ONE shared coordinator).
            let target = try #require(panes.first {
                $0.identifier?.rawValue == "pane:panel|\(takeIDs[1])"
            })
            target.onPlainClick?(0)
            await settle(window, hosting, until: { target.isEditable })
            #expect(target.isEditable, "the clicked pane went live")

            target.window?.makeFirstResponder(target)
            target.setSelectedRange(NSRange(location: 0, length: 0))
            target.insertText("Panel-typed: ", replacementRange: NSRange(location: 0, length: 0))
            // The N3 shape: the panel's edit is pending on the SESSION's
            // per-post coordinator — flush it and the store converges.
            await session.autosave(forPost: postID).flushNow()
            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [takeIDs[1]])
            }
            #expect(stored == "Panel-typed: the other take",
                    "the panel edit landed through the shared coordinator (stored: \(stored ?? "nil"))")
        }
    }
}
