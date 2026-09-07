//
//  LandingOffsetTests.swift
//  VariorumTests
//
//  The 2026-09-06 use-report round, 17o batch b — **THE LANDING FAMILY**
//  (ledger rows 7 · 20 · 42; her ruling U-20, verbatim: *"when you are within
//  a block and then click go to write, you also end up with your caret at the
//  start of the block rather than where you were within it, which is annoying
//  on long blocks"*, and row 20: *"Opening in write from blocks puts your
//  cursor in the right place but doesn't move you there"*).
//
//  ONE rule: every door into Write lands at the REMEMBERED CARET OFFSET
//  inside the note's current block, and the arrival REVEALS it. Surfaces
//  with no caret report nil and land at the block's start, exactly as today.
//
//  Three pins live here:
//   1. the memory (pure) — it round-trips the offset, an OLD two-field
//      string reads nil, and a nil report never erases what it does not know;
//   2. `bareArrivalLanding` (pure over the index) — start + clamped offset;
//   3. the REVEAL (mounted, 250 paragraphs) — the seeded caret's line is
//      inside the scroll view's visible rect. Red on the old tree: the seed
//      arm set the selection and never scrolled, so a far block's caret sat
//      thousands of points below the viewport.
//
//  The round-trip across the modes is `CurrentBlockContinuityTests` (row 39's
//  rig, one expectation moved by this ruling — see its step 5).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Every door into Write lands where the caret was (17o batch b — rows 7 · 20 · 42)", .serialized)
struct LandingOffsetTests {

    // MARK: - 1. The memory (pure)

    @Test func theMemoryRoundTripsTheCaretOffsetAndReadsOldTwoFieldFactsAsUnknown() {
        let defaults = UserDefaults(suiteName: "landing-offset-\(UUID().uuidString)")!
        var memory = CurrentBlockMemory()

        // An OLD memory — written before this batch, two fields — reads as an
        // unknown offset, which the landing spells "the block's start".
        defaults.set("b1|v1", forKey: CurrentBlockMemory.key("p1"))
        let old = CurrentBlockMemory()
        #expect(old.current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: nil))

        // A fact with an offset round-trips through a fresh memory (a relaunch).
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: 417),
            defaults: defaults)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: 417))

        // nil means UNKNOWN, never zero: a surface with no caret (Blocks' row,
        // the outline's card) reporting the SAME block keeps what is known.
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b1", variantID: "v1", utf16Offset: nil),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.utf16Offset == 417)
        #expect(CurrentBlockMemory().current(for: "p1", defaults: defaults)?.utf16Offset == 417,
                "…and it survives the persisted form too")

        // A DIFFERENT block resets it — an offset inside block one means
        // nothing inside block two.
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: nil),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)
                == FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: nil))

        // Zero is a real place (the block's first character), not "unknown".
        memory.remember(
            FocusedBlock(postID: "p1", blockID: "b2", variantID: "v2", utf16Offset: 0),
            defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults)?.utf16Offset == 0)
        memory.forget(postID: "p1", defaults: defaults)
        #expect(memory.current(for: "p1", defaults: defaults) == nil)
    }

    // MARK: - 2. The bare arrival's landing (pure over the index)

    @Test func theBareArrivalLandsAtTheBlocksStartPlusTheRememberedOffsetClamped() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "landings")
            var blocks: [String] = []
            for text in [
                "Block one — a short opening line.",
                "Block two — the long one she was standing in the middle of.",
                "Block three — the last.",
            ] {
                blocks.append(try session.operations.newBlock(in: post.id, text: text).block.id)
            }
            let slots = try await db.read { [id = post.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let model = EditorViewModel(session: session, postID: post.id)
            model.index = BlockRangeIndex(slots: slots, tail: nil)
            let two = model.index.range(ofEntryAt: 1)

            // No fact at all: the document's start (unchanged).
            #expect(model.bareArrivalLanding(fact: nil) == 0)
            // A fact with NO offset: the block's start (unchanged — surfaces
            // that hold no caret land exactly as they did).
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(postID: post.id, blockID: blocks[1], variantID: nil))
                == two.location)
            // U-20: the remembered offset INSIDE the block.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: post.id, blockID: blocks[1], variantID: nil, utf16Offset: 12))
                == two.location + 12)
            // Past the block's current length (it shrank while she was away):
            // clamped to the block's END, never into the next block.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: post.id, blockID: blocks[1], variantID: nil, utf16Offset: 9_999))
                == two.location + two.length)
            // A negative offset is nonsense: the block's start.
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: post.id, blockID: blocks[1], variantID: nil, utf16Offset: -5))
                == two.location)
            // Another post's fact is not this post's business (unchanged).
            #expect(model.bareArrivalLanding(
                fact: FocusedBlock(
                    postID: "elsewhere", blockID: blocks[1], variantID: nil, utf16Offset: 12))
                == 0)
        }
    }

    // MARK: - 3. The reveal (mounted, 250 paragraphs) — row 20

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView, timeout: TimeInterval = 8,
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

    /// The laid-out line's top for a UTF-16 offset, in the text view's own
    /// coordinates — the same geometry `JumpPrimitive` steers (fragment frame
    /// + the container origin), so the pin measures what the primitive moves.
    /// TK2 only: no `.layoutManager`, no TK1 API (TEXTKIT2 §4).
    static func lineTop(ofOffset offset: Int, in textView: NSTextView) -> Double? {
        guard let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return nil }
        let length = contentManager.offset(
            from: contentManager.documentRange.location,
            to: contentManager.documentRange.endLocation)
        let clamped = min(max(0, offset), length)
        guard let target = contentManager.location(
            contentManager.documentRange.location, offsetBy: clamped)
        else { return nil }
        var top: Double?
        layoutManager.enumerateTextLayoutFragments(
            from: target, options: [.ensuresLayout]
        ) { fragment in
            let fragmentTop = Double(fragment.layoutFragmentFrame.minY)
            let fragmentStart = contentManager.offset(
                from: contentManager.documentRange.location,
                to: fragment.rangeInElement.location)
            let lines = fragment.textLineFragments
            if let i = FragmentLines.lineIndex(
                atLocalOffset: max(0, clamped - fragmentStart),
                lineRanges: lines.map(\.characterRange)) {
                top = fragmentTop + Double(lines[i].typographicBounds.minY)
            } else {
                top = fragmentTop
            }
            return false
        }
        guard let top else { return nil }
        return top + Double(textView.textContainerOrigin.y)
    }

    @Test func aSeededCaretFarDownALongNoteArrivesInsideTheVisibleRect() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 20))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the long note")
            for i in 1...250 {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i): a sentence of the story, long enough to read as prose "
                        + "and to take a line or two of the column at this width.")
            }
            let slots = try await db.read { [id = post.id] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            // Block 200's start — the "far block" the workbench's Open in
            // Write hands to `PostDetailView.jump(to:)`, which is exactly the
            // `caretSeed` this mount receives.
            let seed = index.range(ofEntryAt: 199).location

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                session.commandRouter.forgetCurrentBlock(for: post.id)
            }
            let hosting = NSHostingView(
                rootView: EditorView(session: session, postID: post.id, caretSeed: seed)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first else {
                    return false
                }
                return view.string.count >= index.documentLength
                    && view.selectedRange().location == seed
            }, "the seeded caret lands in block 200")
            let editor = try #require(Self.views(EditorTextView.self, in: hosting).first)
            let scrollView = try #require(editor.enclosingScrollView)
            // Let the reveal settle (the arrival's own next-turn retry runs).
            _ = await Self.settle(window, hosting, timeout: 2) { false }

            let caretTop = try #require(
                Self.lineTop(ofOffset: seed, in: editor), "the caret's line is laid out")
            let visible = scrollView.contentView.bounds
            print("[17o b row 20] caret line top \(caretTop) · visible "
                + "\(visible.minY)…\(visible.maxY) · document \(editor.frame.height)")
            #expect(caretTop >= Double(visible.minY) - 1,
                    "the caret's line is not above the viewport (\(caretTop) vs \(visible.minY))")
            #expect(caretTop <= Double(visible.maxY) - 1,
                    "the caret's line is ON SCREEN, not thousands of points below "
                        + "(\(caretTop) vs \(visible.maxY))")
        }
    }
}
