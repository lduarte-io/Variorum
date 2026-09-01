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

    /// 13b 4D (S4-20 — JUSTIFIED PIN EDIT, line by line, her reversal on
    /// the record: "I want to default to the write view on new opens"):
    /// every `.takes` default expectation flips to `.write` — the edited
    /// pin is RED ON OLD code (pre-4D `rememberedMode` returns `.takes`
    /// for a virgin post), which is exactly the flip's proof. The per-post
    /// MEMORY lines are UNCHANGED — only the first-open default moved
    /// (the R72/R79 takes-first half superseded; memory stands).
    @Test func aPostOpensInWriteFirstThenWhereItWasLeft() {
        let defaults = freshDefaults("memory")
        // S4-20: the first open is WRITE (was .takes — R79's half, superseded).
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .write)
        // Thereafter: whatever mode was last used THERE (per post) — a
        // post you left in Takes reopens in Takes (memory untouched).
        defaults.set("Takes", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .takes)
        defaults.set("Lenses", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .lenses)
        #expect(PostDetailView.rememberedMode(postID: "p2", defaults: defaults) == .write,
                "memory is per-post; the default is Write (S4-20)")
        // A stale/unknown value falls back to the default, never crashes.
        defaults.set("NotAMode", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .write)
    }

    /// 13b 4C (S4-3) — red-on-old: a post left in the RETIRED Outline tab
    /// reopens in Compare, its successor (pre-4C code decoded "Outline"
    /// to the outline tab; a naive case-drop would strand it on the
    /// `.takes` fallback — the migration pin holds the successor mapping).
    @Test func aRememberedOutlineModeMigratesToCompare() {
        let defaults = freshDefaults("outline-migration")
        defaults.set("Outline", forKey: "postMode.p1")
        #expect(PostDetailView.rememberedMode(postID: "p1", defaults: defaults) == .compare,
                "outline retired INTO compare — no stored value strands")
        #expect(PostMode.fromStored("Outline") == .compare)
        #expect(PostMode.fromStored("Compare") == .compare)
        #expect(PostMode.fromStored("NotAMode") == nil)
    }

    /// The row is SEVEN — Index and Read joined at pre-13u Act 10 wave 2c
    /// (eight), and the Act 10 correction round folded Index INTO Read (her
    /// rulings R-cor-5/7: one tab named Read with an in-place `edit · read`
    /// switch). Justified pin edit, the fourth in this pin's own lineage:
    /// seven → six (Outline retired, 13b 4C/S4-3) → eight → seven; the
    /// mode-row change IS the ruled behavior change each time.
    @Test func theModeVocabularyIsTheSevenModeRail() {
        #expect(PostDetailView.Mode.allCases.map(\.rawValue) ==
                ["Write", "Takes", "Read", "Lenses", "Compare", "Blocks", "Canvas"])
    }
}

@MainActor
@Suite("PostDetail mode routing (13b 1b, P-4)", .serialized)
struct PostDetailRoutingTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
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

    private func contains<V: NSView>(_ type: V.Type, in view: NSView) -> Bool {
        if view is V { return true }
        return view.subviews.contains { contains(type, in: $0) }
    }

    /// The mounted detail registers with the CommandRouter, and a routed
    /// mode request actually SWITCHES the surface — the composed
    /// replacement for `.variorumSwitchMode`, exercised over the real
    /// mounted shell (the wiring no other test touched).
    @Test func theMountedDetailRegistersAndRoutedRequestsSwitchTheSurface() async throws {
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
            let post = try session.operations.createPost(title: "routing")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so Takes can host.")
            // 13b 4D (S4-20 — justified edit): the first-open DEFAULT is
            // Write now, so this test seeds a REMEMBERED Takes mode — the
            // takes-mounted → write-request transition it exercises is
            // unchanged, and the seeding doubles as a memory-stands pin.
            UserDefaults.standard.set(PostMode.takes.rawValue, forKey: "postMode.\(post.id)")

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            await settle(window, hosting, until: {
                session.commandRouter.activePostID == post.id
            })
            #expect(session.commandRouter.activePostID == post.id,
                    "the detail registered with the router")
            #expect(session.commandRouter.activeMode == .takes,
                    "the per-post MEMORY landed it in Takes (S4-20: the default is Write; memory stands)")

            // The routed request (⌘1 / the sidebar rail) switches the REAL
            // surface: Write's full-document editor mounts.
            #expect(session.commandRouter.requestMode(.write, postID: post.id))
            await settle(window, hosting, until: {
                self.contains(EditorTextView.self, in: hosting)
            })
            #expect(session.commandRouter.activeMode == .write,
                    "the detail reported its new truth (the rail's mirror)")
            #expect(contains(EditorTextView.self, in: hosting),
                    "the Write editor actually mounted — the request ACTED")
        }
    }
}

@MainActor
@Suite("Sidebar smoke (13b 1b — zero-test-view obligation)", .serialized)
struct SidebarSmokeTests {
    /// The sidebar mounts with the post-mode rail (its ThemeStore
    /// environment requirement and the rail's router-fed marker input —
    /// a missing environment or a rail regression crashes/fails here).
    @Test func theSidebarMountsWithThePostModeRail() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "sidebar")
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 260, height: 600),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let selection = Binding<SidebarSelection?>.constant(.post(post.id))
            let hosting = NSHostingView(
                rootView: SidebarView(
                    session: session, model: LibraryViewModel(session: session),
                    pool: PoolViewModel(session: session),
                    workspace: WorkspaceModel(),  // 13f batch 3: the Open strip's state
                    stars: StarsModel(session: session),  // 13f batch 6: the Starred section
                    selection: selection,
                    postMode: PostMode.takes.rawValue)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 260, height: 600)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            window.layoutIfNeeded()
            window.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.1))
            #expect(hosting.subviews.isEmpty == false, "the sidebar rendered")
        }
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
