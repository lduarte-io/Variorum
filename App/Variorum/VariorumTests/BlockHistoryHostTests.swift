//
//  BlockHistoryHostTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch C — the Block History pane's HOST
//  (rows 27 + 29; her words: "opening block history doesn't open it
//  correctly" · "the block history tab stays open as you move to other
//  modes which looks bad and is confusing"). The pane is SCOPED to the mode
//  that opened it (a mode switch closes it — RED on old: it persisted), and
//  in Blocks it is the ONE right region (the workbench's context panel
//  yields; nothing stands past the window's edge). The REAL detail is
//  mounted in a real window (the BlockHistoryPaneTests harness).
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
@Suite("Block History's host — scoped to its mode, one right region (the Act 10 correction round)", .serialized)
struct BlockHistoryHostTests {
    private nonisolated static func pump(_ seconds: TimeInterval = 0.03) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 6,
        until predicate: () -> Bool
    ) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if predicate() { return true }
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    /// The pane is OPEN when the detail's inspector holds a history request.
    /// (The inspector's AppKit container — `InspectorStyleContext` — stays in
    /// the tree collapsed after a close, so the class name cannot say
    /// "closed"; the state that decides the column can.)
    private static func historyOpen() -> Bool {
        PostDetailOracle.inspectorPanel?.isBlockHistory == true
    }

    private static func inspectorColumnMounted(_ hosting: NSView) -> Bool {
        TrayPanelMoveTests.classNames(hosting).contains { $0.contains("InspectorStyleContext") }
    }

    /// Every view in the tree whose frame (in the window) runs past the
    /// window's content width — the "third column cut at the edge" class.
    private static func viewsPastTheEdge(_ hosting: NSView, window: NSWindow) -> [String] {
        guard let content = window.contentView else { return [] }
        let limit = content.bounds.maxX + 0.5
        var offenders: [String] = []
        func walk(_ view: NSView) {
            if !view.isHidden, view.alphaValue > 0.01 {
                let frame = view.convert(view.bounds, to: nil)
                if frame.width > 0, frame.maxX > limit {
                    offenders.append("\(type(of: view)) maxX=\(frame.maxX)")
                }
            }
            for sub in view.subviews { walk(sub) }
        }
        walk(hosting)
        return offenders
    }

    /// Mounts the REAL `PostDetailView` in a real window over a three-block
    /// note remembered on `mode`, with the router's current block set to the
    /// SECOND block when asked (so Blocks opens its panel on arrival).
    private func mounted(
        mode: PostMode, currentBlock: Bool = false, width: CGFloat = 1100,
        _ body: @escaping (AppSession, String, [String], [String?], NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the host")
            var blocks: [String] = []
            var variants: [String?] = []
            for text in ["The first block.", "The second block, with a past.", "The third block."] {
                let minted = try session.operations.newBlock(in: post.id, text: text)
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
                if blocks.count == 2 {
                    _ = try session.operations.commit(minted.variant.id, kind: .manual)
                }
            }
            UserDefaults.standard.set(mode.rawValue, forKey: "postMode.\(post.id)")
            session.commandRouter.forgetCurrentBlock(for: post.id)
            if currentBlock {
                // The remembered current block (row 39's memory) — the
                // detail registers and restores it; Blocks then opens on it.
                let token = session.commandRouter.registerDetail(postID: post.id, mode: mode) { _ in }
                session.commandRouter.noteFocusedBlock(blocks[1], variantID: variants[1], postID: post.id)
                session.commandRouter.unregisterDetail(token)
            }
            #if DEBUG
            BlocksWorkbenchOracle.reset()
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                session.commandRouter.forgetCurrentBlock(for: post.id)
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            _ = await Self.settle(window, hosting) {
                session.commandRouter.activePostID == post.id
            }
            try await body(session, post.id, blocks, variants, window, hosting)
        }
    }

    @Test func aModeSwitchClosesThePaneTheModeOpened() async throws {
        try await mounted(mode: .write) { session, post, blocks, variants, window, hosting in
            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blocks[1], focusedVariantID: variants[1])))
            #expect(await Self.settle(window, hosting) {
                Self.historyOpen() && Self.inspectorColumnMounted(hosting)
            }, "the pane opened in Write, beside the page")
            // ⌘2 — the pane was Write's question; Takes asks its own.
            #expect(session.commandRouter.requestMode(.takes, postID: post))
            #expect(await Self.settle(window, hosting) {
                session.commandRouter.activeMode == .takes && !Self.historyOpen()
            }, "the pane is GONE with the mode that opened it (it used to persist, stale)")
            #expect(PostDetailOracle.inspectorPanel == nil, "nothing else took the column")
            // The door still works in the new mode: open again, then leave.
            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blocks[0], focusedVariantID: variants[0])))
            #expect(await Self.settle(window, hosting) { Self.historyOpen() })
            #expect(session.commandRouter.requestMode(.read, postID: post))
            #expect(await Self.settle(window, hosting) {
                session.commandRouter.activeMode == .read && !Self.historyOpen()
            })
        }
    }

    @Test func fromBlocksThePaneIsTheOneRightRegionAndNothingRunsPastTheWindow() async throws {
        try await mounted(mode: .blocks, currentBlock: true) { session, post, blocks, variants, window, hosting in
            #expect(await Self.settle(window, hosting) { BlocksWorkbenchOracle.panelMounted },
                    "Blocks arrived on the current block with its context panel open")
            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blocks[1], focusedVariantID: variants[1])))
            #expect(await Self.settle(window, hosting) {
                Self.historyOpen() && Self.inspectorColumnMounted(hosting)
            }, "the history pane opened")
            #expect(await Self.settle(window, hosting) { !BlocksWorkbenchOracle.panelMounted },
                    "…and the workbench's own panel YIELDED — one right region at a time")
            // Give the columns a layout pass, then read every frame.
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            let offenders = Self.viewsPastTheEdge(hosting, window: window)
            #expect(offenders.isEmpty,
                    "nothing stands past the window's edge (her cut 'Clos…' / 'Restore'): \(offenders.prefix(5))")
            // JUSTIFIED PIN EDIT (the correction round, batch F rows 28/65 —
            // the completion session, caught by the full-suite run): this
            // assertion named "ListTableHeaderView", the List's own section
            // header backing — and the List's fixed header measurement was
            // exactly the mechanism that clipped the region headers to
            // slivers, so batch F's piece 3 retired it for a ScrollView of
            // calm sections. Same edit BlockHistoryPaneTests already carries.
            let paneClasses = TrayPanelMoveTests.classNames(hosting)
            #expect(paneClasses.contains("HostingScrollView"),
                    "the pane's calm scroll is really drawn, inside the window")
            #expect(!paneClasses.contains("ListTableHeaderView"),
                    "no List section headers — the clipping mechanism is gone")
            // Closing the pane gives the context panel back.
            #expect(session.commandRouter.requestMode(.blocks, postID: post), "a same-mode request is a no-op switch")
            #expect(session.commandRouter.requestMode(.write, postID: post))
            #expect(await Self.settle(window, hosting) { !Self.historyOpen() })
            #expect(session.commandRouter.requestMode(.blocks, postID: post))
            #expect(await Self.settle(window, hosting) { BlocksWorkbenchOracle.panelMounted },
                    "back in Blocks with no inspector, the context panel stands again")
        }
    }
}
