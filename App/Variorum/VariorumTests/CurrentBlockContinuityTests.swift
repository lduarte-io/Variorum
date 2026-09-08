//
//  CurrentBlockContinuityTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch C — ledger row 39: **ONE current block
//  follows you across the modes.** The triage walk found position was
//  PER-MODE memory (Index kept block 03 while Takes made block 1 live; a
//  bare Write arrival landed at the document's END — row 49). The pins:
//  the memory itself (pure), and the ROUND TRIP through the REAL mounted
//  detail — Write caret in block 2 → Takes live block 2 → Read(edit) block
//  2 selected → Blocks block 2 focused → Write caret back in block 2.
//  Red-on-old: Takes landed on block 1 and Write on the document's end.
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
@Suite("The one current block across the modes (the Act 10 correction round, row 39)", .serialized)
struct CurrentBlockContinuityTests {
    @Test func theMemoryKeepsANotesLastFactAcrossMountsAndPerNote() {
        let defaults = UserDefaults(suiteName: "current-block-\(UUID().uuidString)")!
        var memory = CurrentBlockMemory()
        #expect(memory.current(for: "p1", defaults: defaults) == nil)
        memory.remember(FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2"), defaults: defaults)
        memory.remember(FocusedBlock(postID: "p2", blockID: "b9", variantID: nil), defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.blockID == "b2")
        #expect(memory.current(for: "p2", defaults: defaults)?.blockID == "b9")
        // A fresh memory (a new launch) reads the persisted fact back.
        let fresh = CurrentBlockMemory()
        #expect(fresh.current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2"))
        #expect(fresh.current(for: "p2", defaults: defaults)
                == FocusedBlock(postID: "p2", blockID: "b9", variantID: nil))
        memory.forget(postID: "p1", defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults) == nil)
    }

    @Test func theRouterRestoresANotesCurrentBlockWhenItMountsAgain() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let router = session.commandRouter
            defer {
                router.forgetCurrentBlock(for: "p1")
                router.forgetCurrentBlock(for: "p2")
            }
            let token = router.registerDetail(postID: "p1", mode: .write) { _ in }
            router.noteFocusedBlock("b2", variantID: "v2", postID: "p1")
            #expect(router.focusedBlock?.blockID == "b2")
            router.unregisterDetail(token)
            #expect(router.focusedBlock == nil, "the LIVE fact goes with the detail")
            #expect(router.currentBlock(for: "p1")?.blockID == "b2",
                    "…the MEMORY does not — the Library's Open door reads it")
            // Another note mounts: its own memory (none), never p1's.
            let other = router.registerDetail(postID: "p2", mode: .write) { _ in }
            #expect(router.focusedBlock == nil)
            router.unregisterDetail(other)
            // p1 mounts again: the fact is restored before any surface reports.
            let again = router.registerDetail(postID: "p1", mode: .takes) { _ in }
            #expect(router.focusedBlock == FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2"))
            router.unregisterDetail(again)
        }
    }

    // MARK: - The round trip through the real detail

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
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
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
        return predicate()
    }

    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    private static func livePanes(in view: NSView) -> [PaneTextView] {
        views(PaneTextView.self, in: view).filter(\.isEditable)
    }

    @Test func theCurrentBlockFollowsHerWriteTakesReadBlocksWrite() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "continuity")
            var blocks: [String] = []
            var variants: [String] = []
            for text in [
                "Block one, where a bare arrival used to land nowhere near.",
                "Block two — the current block this pin carries around.",
                "Block three, the document's end, where the old arrival went.",
            ] {
                let minted = try session.operations.newBlock(in: post.id, text: text)
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            let router = session.commandRouter
            router.forgetCurrentBlock(for: post.id)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            #if DEBUG
            ReadModeOracle.reset()
            BlocksWorkbenchOracle.focusedBlockID = nil
            #endif
            let slots = try await db.read { [id = post.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let blockTwoRange = index.range(ofEntryAt: 1)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(post.id))
                router.forgetCurrentBlock(for: post.id)
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            // 1. WRITE mounts bare: the caret lands at the START (row 49 —
            //    it used to land at the document's end).
            #expect(await Self.settle(window, hosting) {
                Self.views(EditorTextView.self, in: hosting).first?.window != nil
                    && router.activeMode == .write
            })
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            #expect(await Self.settle(window, hosting) {
                editor.string.count >= index.documentLength && router.focusedBlock != nil
            }, "the projection filled and the arrival reported its block")
            #expect(editor.selectedRange().location == 0,
                    "a bare arrival with no current block lands at the document START, never its end")
            #expect(router.focusedBlock?.blockID == blocks[0])

            // Her caret moves into block 2 — the surface reports the fact.
            editor.setSelectedRange(NSRange(location: blockTwoRange.location + 6, length: 0))
            #expect(await Self.settle(window, hosting) { router.focusedBlock?.blockID == blocks[1] },
                    "Write reports the caret's block as the ONE fact")

            // 2. TAKES enters on it: block 2's article pane takes the ring
            //    (it used to be the FIRST block's, whatever she was in).
            #expect(router.requestMode(.takes, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                Self.livePanes(in: hosting).contains {
                    $0.identifier?.rawValue.hasSuffix("|\(variants[1])") == true
                }
            }, "Takes lands with block 2 live")
            #expect(Self.livePanes(in: hosting).count == 1, "one ring")
            #expect(router.focusedBlock?.blockID == blocks[1])

            // 3. READ (its `edit` face) enters on it: block 2 is the
            //    selected/current block, scrolled to.
            #expect(router.requestMode(.read, postID: post.id))
            #expect(await Self.settle(window, hosting) { ReadModeOracle.selectedBlockID == blocks[1] },
                    "Read's edit face stands at block 2")
            #expect(ReadModeOracle.face == .edit)

            // 4. BLOCKS enters on it: block 2 is the focused row (its panel).
            #expect(router.requestMode(.blocks, postID: post.id))
            #expect(await Self.settle(window, hosting) { BlocksWorkbenchOracle.focusedBlockID == blocks[1] },
                    "Blocks focuses block 2's row")

            // 5. WRITE again: the caret is back WHERE IT WAS in block 2 —
            //    not at the document's end (row 49), not at block 1, and (the
            //    2026-09-06 use-report round, her ruling U-20 + ledger rows 7
            //    and 42) not at the block's START either: *"you also end up
            //    with your caret at the start of the block rather than where
            //    you were within it, which is annoying on long blocks"*. The
            //    caret went in at +6 above; +6 is where it comes back. This
            //    ONE expectation is what the ruling moved in this Act 10 pin;
            //    every other step rides unmodified.
            #expect(router.requestMode(.write, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockTwoRange.location + 6
            }, "Write re-enters with the caret where it was in block 2 — the round trip closes")
            let back = try #require(Self.views(EditorTextView.self, in: hosting).first)
            #expect(back.selectedRange().location == blockTwoRange.location + 6)
            #expect(router.focusedBlock?.blockID == blocks[1])
            #expect(router.currentBlock(for: post.id)?.blockID == blocks[1],
                    "and the memory holds it for the next mount")
        }
    }

    // MARK: - 17o batch b ladder, R1-1 (BLOCKER): a jump's caret seed is ONE-SHOT

    /// The 2026-09-06 use-report round, 17o batch b's ladder — round 1's
    /// R1-1. `PostDetailView.jump(to:)` (Blocks' *open in write*, the Index
    /// column's jump, Read's `onJump`, the canvas card, `initialBlockID`)
    /// seeds the Write editor's caret through `@State pendingCaret`, and
    /// nothing ever cleared it — so EVERY later mount of Write in the same
    /// note visit re-ran the seed arm (`EditorView.init` → `pendingCaretSeed`
    /// on a fresh model), landed at the jump's block START, claimed the caret
    /// so the bare arrival never read the memory, and reported offset 0 into
    /// it. Two arms, both red on the pre-fix tree: (1) after the jump, Write
    /// → Takes → Write lands where the caret WAS (U-20, rows 7 · 42) — not
    /// at the jump's block start; (2) after Takes → a click into ANOTHER
    /// block's pane → Write lands in THAT block (the Act 10 "one current
    /// block" rule) — a fix that cleared only the offset would still fail
    /// here.
    @Test func aJumpsCaretSeedIsSpentByItsOwnMountAndNeverReLandsALaterOne() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "one-shot seed")
            var blocks: [String] = []
            var variants: [String] = []
            for text in [
                "Block one, the opening paragraph of the note.",
                "Block two — the jump lands here, at its start, on purpose.",
                "Block three, where a click on the Takes board goes next.",
            ] {
                let minted = try session.operations.newBlock(in: post.id, text: text)
                blocks.append(minted.block.id)
                variants.append(minted.variant.id)
            }
            let router = session.commandRouter
            router.forgetCurrentBlock(for: post.id)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            #if DEBUG
            ReadModeOracle.reset()
            BlocksWorkbenchOracle.focusedBlockID = nil
            #endif
            let slots = try await db.read { [id = post.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let blockTwoRange = index.range(ofEntryAt: 1)
            let blockThreeRange = index.range(ofEntryAt: 2)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(post.id))
                router.forgetCurrentBlock(for: post.id)
            }
            // The JUMP door: `initialBlockID` runs `jump(to:)` on appear —
            // the same `pendingCaret` road as Blocks' *open in write*.
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id, initialBlockID: blocks[1])
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            // 1. The jump lands at block 2's START (the seed's job, unchanged).
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockTwoRange.location
                    && router.focusedBlock?.blockID == blocks[1]
            }, "the jump seeds the caret at block 2's start")
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)

            // Her caret moves six characters in; the surface reports it.
            editor.setSelectedRange(NSRange(location: blockTwoRange.location + 6, length: 0))
            #expect(await Self.settle(window, hosting) { router.focusedBlock?.utf16Offset == 6 },
                    "Write reports the caret's offset inside block 2")

            // 2. TAKES enters on block 2 — its pane's caret where she was.
            #expect(router.requestMode(.takes, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                Self.livePanes(in: hosting).contains {
                    $0.identifier?.rawValue.hasSuffix("|\(variants[1])") == true
                }
            }, "Takes lands with block 2 live")

            // 3. ARM 1 — WRITE again: the caret is back at +6 in block 2, NOT
            //    at the block's start. Red on the pre-fix tree: the never-
            //    cleared seed re-ran and landed at `blockTwoRange.location`.
            #expect(router.requestMode(.write, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == blockTwoRange.location + 6
            }, "Write re-enters where the caret was — the jump's seed was spent by its own mount")
            let back = try #require(Self.views(EditorTextView.self, in: hosting).first)
            #expect(back.selectedRange().location == blockTwoRange.location + 6,
                    "arm 1: not the jump's block start (\(back.selectedRange().location) vs start \(blockTwoRange.location))")

            // 4. ARM 2 — TAKES, a click into block THREE's pane, then WRITE:
            //    the caret is in block 3 (the one current block), never back
            //    at the jump's block. A fix that cleared only the OFFSET
            //    would still fail here.
            #expect(router.requestMode(.takes, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                !Self.livePanes(in: hosting).isEmpty
            }, "Takes lands again")
            let paneThree = try #require(Self.views(PaneTextView.self, in: hosting).first {
                $0.identifier?.rawValue.hasSuffix("|\(variants[2])") == true
            })
            // The click's own place, then the click-to-focus gesture.
            paneThree.setSelectedRange(NSRange(location: 3, length: 0))
            paneThree.onPlainClick?(3)
            #expect(await Self.settle(window, hosting) {
                Self.livePanes(in: hosting).contains {
                    $0.identifier?.rawValue.hasSuffix("|\(variants[2])") == true
                } && router.focusedBlock?.blockID == blocks[2]
            }, "block 3's pane takes the ring and is the current block")
            #expect(router.requestMode(.write, postID: post.id))
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                let caret = view.selectedRange().location
                return caret >= blockThreeRange.location && caret <= blockThreeRange.upperBound
            }, "Write re-enters in block 3 — the current block, never the jump's")
            let third = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let caret = third.selectedRange().location
            #expect(caret >= blockThreeRange.location && caret <= blockThreeRange.upperBound,
                    "arm 2: the caret is in block 3 (\(caret) vs block 3 \(blockThreeRange)), not at the jump's block start \(blockTwoRange.location)")
            #expect(router.focusedBlock?.blockID == blocks[2])
        }
    }
}
