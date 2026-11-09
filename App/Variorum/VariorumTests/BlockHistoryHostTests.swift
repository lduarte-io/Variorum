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
            NoteMemoryDefaults.store.set(mode.rawValue, forKey: "postMode.\(post.id)")
            session.commandRouter.forgetCurrentBlock(for: post.id)
            if currentBlock {
                // The remembered current block (row 39's memory) — the
                // detail registers and restores it; Blocks then opens on it.
                let token = session.commandRouter.registerDetail(postID: post.id, mode: mode) { _ in }
                session.commandRouter.noteFocusedBlock(blocks[1], variantID: variants[1], postID: post.id)
                session.commandRouter.unregisterDetail(token)
            }
            #if DEBUG
            // Row 50: this pin's OWN workbench, named by its own session.
            let workbench = BlocksWorkbenchOracle.reader(session.debugProbeScope)
            workbench.reset()
            #endif
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: width, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                NoteMemoryDefaults.store.removeObject(forKey: "postMode.\(post.id)")
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

    // **RETIRED at VX-827 U3b — A JUSTIFIED EDIT, both:** `aModeSwitchCloses
    // ThePaneTheModeOpened` and `fromBlocksThePaneIsTheOneRightRegionAndNothing
    // RunsPastTheWindow` pinned the PANEL's host (rows 27 + 29) through the
    // origin door's seam, which U3a kept for gate G2. The panel and that seam
    // retired whole at U3b; both rulings stand, pinned on the surface that
    // succeeds it — `aModeSwitchFromTheFaceShowsTheMode` (row 29: the
    // question one mode asked goes with it) and `fromBlocksTheFaceReplacesThe
    // WorkbenchAndGivesItBack` (one region, nothing past the edge) below, and
    // the origin door's own landing in `theOriginDoorOpensTheLineageFaceOnThe
    // Original`.

    // MARK: - VX-801 (VX-827 U3a) — the Commits face takes the FULL pane

    /// The face stands in the detail (the oracle's request), its model loaded.
    private static func faceOpen(_ post: String) -> Bool {
        PostDetailOracle.historyFace?.postID == post
            && CommitsFaceOracle.model(forPost: post)?.loaded == true
    }

    /// **THE DESIGN MEMO: "The surface takes the FULL pane; ‹ back returns
    /// exactly where she was."** A history door opens the Commits face IN
    /// PLACE of the mode's surface — never in the inspector, never beside a
    /// live editor (Write's bar, which the editor composes, is gone while it
    /// stands) — and a request for the mode it covers (the ‹ back road's own
    /// state change: the face cleared, the mode unchanged) brings Write back.
    /// RED on the pre-U3a tree: the door opened the inspector's panel beside
    /// a still-mounted editor (`historyFace` did not exist).
    @Test func theHistoryDoorOpensTheCommitsFaceInTheFullPane() async throws {
        try await mounted(mode: .write) { session, post, blocks, variants, window, hosting in
            #if DEBUG
            #expect(await Self.settle(window, hosting) {
                CommitBarGeometry.mounted("horizontal", post: post) == 1
            }, "Write stands with its bar")
            let request = BlockHistoryRequest(
                postID: post, blockID: blocks[1], focusedVariantID: variants[1])
            #expect(session.commandRouter.requestBlockHistory(request))
            #expect(await Self.settle(window, hosting) { Self.faceOpen(post) },
                    "the Commits face stands, its block's time loaded")
            #expect(PostDetailOracle.historyFace == request)
            #expect(PostDetailOracle.inspectorPanel == nil, "not the inspector — the full pane")
            #expect(await Self.settle(window, hosting) {
                CommitBarGeometry.mounted("horizontal", post: post) == 0
            }, "the mode's surface is REPLACED, not covered: no editor stands under the face")
            let model = try #require(CommitsFaceOracle.model(forPost: post))
            #expect(model.blockID == blocks[1])
            let takeID = try #require(variants[1])
            let newest = try #require(model.history.savepoints[takeID]?.first?.id)
            #expect(model.selection == .commit(commitID: newest),
                    "it opens on the newest moment (PROVISIONAL P-U3a-2)")
            // The same mode, asked: the face goes and Write is back.
            #expect(session.commandRouter.requestMode(.write, postID: post))
            #expect(await Self.settle(window, hosting) {
                PostDetailOracle.historyFace == nil
                    && CommitBarGeometry.mounted("horizontal", post: post) == 1
            }, "Write returns where the face stood")
            #expect(session.commandRouter.activeMode == .write)
            #endif
        }
    }

    /// A mode switch from the face shows the asked mode (row 29's scoping,
    /// the face's twin): the face is the question one mode asked.
    @Test func aModeSwitchFromTheFaceShowsTheMode() async throws {
        try await mounted(mode: .write) { session, post, blocks, variants, window, hosting in
            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blocks[0], focusedVariantID: variants[0])))
            #expect(await Self.settle(window, hosting) { Self.faceOpen(post) })
            #expect(session.commandRouter.requestMode(.takes, postID: post))
            #expect(await Self.settle(window, hosting) {
                session.commandRouter.activeMode == .takes && PostDetailOracle.historyFace == nil
            }, "Takes shows; the face is gone with the question")
        }
    }

    /// From Blocks the face replaces the WORKBENCH (its context panel with
    /// it — one region, the whole pane), nothing past the window's edge; the
    /// same-mode request brings the workbench back with its panel.
    @Test func fromBlocksTheFaceReplacesTheWorkbenchAndGivesItBack() async throws {
        try await mounted(mode: .blocks, currentBlock: true) { session, post, blocks, variants, window, hosting in
            let workbench = BlocksWorkbenchOracle.reader(session.debugProbeScope)
            #expect(await Self.settle(window, hosting) { workbench.panelMounted })
            #expect(session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(postID: post, blockID: blocks[1], focusedVariantID: variants[1])))
            #expect(await Self.settle(window, hosting) {
                Self.faceOpen(post) && !workbench.panelMounted
            }, "the face stands where the workbench was")
            _ = await Self.settle(window, hosting, timeout: 0.5) { false }
            let offenders = Self.viewsPastTheEdge(hosting, window: window)
            #expect(offenders.isEmpty, "nothing past the window's edge: \(offenders.prefix(5))")
            #expect(session.commandRouter.requestMode(.blocks, postID: post))
            #expect(await Self.settle(window, hosting) {
                PostDetailOracle.historyFace == nil && workbench.panelMounted
            }, "back in Blocks, the workbench and its panel stand again")
        }
    }

    // MARK: - VX-801 (VX-827 U3b) — the origin door lands on the LINEAGE face

    /// **G2's ruling: "See original from…" lands on the Lineage face with the
    /// ORIGINAL selected** — in the same full pane as every history door,
    /// its pane and rail over the original's takes and commits, its header's
    /// Put back offered (a merge's source, kept whole as lineage). The request
    /// is the one both origin doors build (`revealCaretBlockOrigin`,
    /// `revealOriginBlock(ofBlock:)` — pinned in `RecoveryDoorsTests` and
    /// `OriginBlockDoorTests`). RED on the pre-U3b tree: no Lineage face
    /// existed (the door opened the inspector's panel).
    @Test func theOriginDoorOpensTheLineageFaceOnTheOriginal() async throws {
        try await mounted(mode: .write) { session, post, blocks, variants, window, hosting in
            #if DEBUG
            // A JUSTIFIED EDIT (the window's fix leg 2): stage exactly as
            // `theHistoryDoorOpensTheCommitsFaceInTheFullPane` does — Write
            // STANDS with its bar before the door is pressed. The first cut
            // merged and opened the face as soon as the detail registered, so
            // the bar's appear raced the face's swap and the per-post refcount
            // (a global static every test here shares — `.incrementing` ids)
            // was left off by the straddle; the face's own claims all held.
            #expect(await Self.settle(window, hosting) {
                CommitBarGeometry.mounted("horizontal", post: post) >= 1
            }, "Write stands with its bar")
            let barsBefore = CommitBarGeometry.mounted("horizontal", post: post)
            let merged = try session.operations.merge(blocks[1], blocks[2])
            let request = BlockHistoryRequest(
                postID: post, blockID: merged.block.id, focusedVariantID: merged.variant.id,
                opening: .lineage(select: blocks[1]))
            #expect(session.commandRouter.requestBlockHistory(request))
            #expect(await Self.settle(window, hosting) {
                LineageFaceOracle.model(forPost: post)?.loaded == true
            }, "the Lineage face stands, its family loaded")
            #expect(PostDetailOracle.historyFace == request)
            #expect(PostDetailOracle.inspectorPanel == nil, "the full pane, never the inspector")
            let model = try #require(LineageFaceOracle.model(forPost: post))
            #expect(model.selectedBlockID == blocks[1], "the original is selected")
            #expect(model.node?.blockID == blocks[1] && model.node?.isRelative == true,
                    "its pane and rail are the original's")
            #expect(model.selected?.acts.contains(.putBack) == true, "kept whole: Put back")
            #expect(Set(model.members.map(\.blockID)).isSuperset(of: [blocks[1], blocks[2], merged.block.id]),
                    "both originals and this block")
            #expect(await Self.settle(window, hosting) {
                CommitBarGeometry.mounted("horizontal", post: post) == barsBefore - 1
            }, "no editor stands under the face — Write's one bar left with it")
            #endif
        }
    }
}
