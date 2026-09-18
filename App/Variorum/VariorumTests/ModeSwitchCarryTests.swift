//
//  ModeSwitchCarryTests.swift
//  VariorumTests
//
//  **Phase 13u2b UNIT 3 — the MODE-SWITCH viewport-fraction carry.** Her
//  secondary report at the 13u2b kickoff: switching tabs/modes lands the same
//  text at different heights — *"if this is very difficult bc of the different
//  visual elements of takes & stuff, I do think that's fine"*, which is the
//  ≈one-line tolerance these pins hold the rule to. The design is the
//  architectural trace's §6: ONE rule for note mode switches — the carried
//  block is placed at the same VIEWPORT FRACTION it occupied in the outgoing
//  mode, a fraction and never a pixel.
//
//  **Why the round-trip pins mount the REAL detail.** The behaviour is *where
//  a mode switch puts a block on the screen*, so a pin has to perform a real
//  mode switch through the app's own road (`CommandRouter.requestMode`) and
//  measure a real screen position — and it has to compile and run on the
//  PRE-FIX tree, which rules out any pin that speaks through the new seam.
//  `CurrentBlockContinuityTests` established this rig (row 39's round trip);
//  these pins reuse its shape rather than inventing a second one.
//
//  Read's `edit` face lands its target at `anchor: .center` (the shipped
//  policy, `ReadEditPane.land`), so PIN A needs no synthetic scrolling: going
//  through Read puts the carried block at viewport fraction ≈ 0.5 by
//  construction, and the question is only whether Write then keeps it there.
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
@Suite("The mode switch keeps the carried block's height (13u2b UNIT 3)", .serialized)
struct ModeSwitchCarryTests {
    // MARK: - The rig (CurrentBlockContinuityTests' shape)

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

    /// **Where a block sits in the WRITE editor's viewport, as a fraction** —
    /// in the one sense the carry means: the block's own f-point sits at the
    /// viewport's f-point (f = 0 flush at the top, 1 flush at the bottom, 0.5
    /// centred). The geometry is `JumpPrimitive`'s own, so a pin reading it
    /// and the landing that produced it can never disagree; a block is its own
    /// paragraph (R26/R33) but may carry internal newlines (I4), so the span
    /// runs first line's top → last line's bottom.
    ///
    /// It is a FUNCTION rather than four lines in the test body on purpose:
    /// the `SendNonSendable` SIL pass crashes the compiler on a body that
    /// holds several non-Sendable values (the text view, its scroll view)
    /// across an `await` — the crash `LandingOffsetTests` records as biting
    /// "richer shapes". Keeping them inside one synchronous main-actor call
    /// is the same workaround that file uses, stated here so the next reader
    /// does not inline it back.
    private static func writeFraction(in hosting: NSView, block range: NSRange) -> Double? {
        guard let editor = views(EditorTextView.self, in: hosting).first,
              let scrollView = editor.enclosingScrollView,
              let first = JumpPrimitive.lineSpan(ofOffset: range.location, in: editor),
              let last = JumpPrimitive.lineSpan(
                ofOffset: range.location + max(0, range.length - 1), in: editor)
        else { return nil }
        let visible = scrollView.contentView.bounds
        let height = max(1, last.bottom - first.top)
        let f = (first.top - Double(visible.minY)) / (Double(visible.height) - height)
        print("[13u2b U3] block top \(first.top) bottom \(last.bottom) "
              + "· visible \(visible.minY)…\(visible.maxY) · fraction \(f)")
        return f
    }

    /// The caret goes into a block — one synchronous main-actor call, for the
    /// same reason as above.
    private static func putCaret(in hosting: NSView, at location: Int) -> Bool {
        guard let editor = views(EditorTextView.self, in: hosting).first else { return false }
        editor.setSelectedRange(NSRange(location: location, length: 0))
        return true
    }

    // MARK: - PIN A — READ → WRITE

    /// **The carried block keeps its screen height across Read → Write.**
    ///
    /// The gesture: the caret goes into a block in the middle of a long note;
    /// ⌘3 (Read) lands that block CENTRED in the `edit` pane — the shipped
    /// `.center` anchor — and ⌘1 (Write) should find it still centred.
    ///
    /// **Red on the pre-fix tree (measured, 2026-09-18, zero instances):**
    /// `f = 0.0001` — Write's cold mount restored its own session scroll
    /// anchor (the note's top, where it was when she left) and then revealed
    /// the caret through `JumpPrimitive.jump`, which lands the line at the
    /// viewport TOP. Two surfaces, two reveal policies, the same block at two
    /// heights — the trace's §6 finding exactly.
    @Test func aBlockCentredInReadComesBackCentredInWrite() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 71))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the long note")
            let target = 60
            var targetBlock = ""
            for i in 1...120 {
                let minted = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i): a sentence of the story, long enough to read as prose "
                        + "and to take a line or two of the column at this width.")
                if i == target + 1 { targetBlock = minted.block.id }
            }
            let targetBlockID = targetBlock
            let postID = post.id
            let router = session.commandRouter
            router.forgetCurrentBlock(for: postID)
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(postID)")
            ReadModeOracle.reset()
            defer {
                UserDefaults.standard.removeObject(forKey: "postMode.\(postID)")
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(postID))
                router.forgetCurrentBlock(for: postID)
            }
            let slots = try await db.read { [id = postID] db in
                try Queries.renderPost(db, containerID: id)
            }
            let index = BlockRangeIndex(slots: slots, tail: nil)
            let targetRange = index.range(ofEntryAt: target)

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: postID)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)

            // 1. WRITE fills; her caret goes into the middle block.
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.window != nil else { return false }
                return view.string.count >= index.documentLength && router.activeMode == .write
            }, "Write mounts and fills")
            #expect(Self.putCaret(in: hosting, at: targetRange.location + 5))
            #expect(await Self.settle(window, hosting) {
                router.focusedBlock?.blockID == targetBlockID
            }, "Write reports the caret's block as the ONE carried fact")

            // 2. READ — the `edit` face lands the carried block CENTRED.
            #expect(router.requestMode(.read, postID: postID))
            #expect(await Self.settle(window, hosting) {
                ReadModeOracle.selectedBlockID == targetBlockID
            }, "Read's edit face stands at the carried block")
            _ = await Self.settle(window, hosting, timeout: 1.5) { false }  // its landing settles

            // 3. WRITE again — where does the block sit now?
            #expect(router.requestMode(.write, postID: postID))
            #expect(await Self.settle(window, hosting) {
                guard let view = Self.views(EditorTextView.self, in: hosting).first,
                      view.string.count >= index.documentLength else { return false }
                return view.selectedRange().location == targetRange.location + 5
            }, "Write re-enters with the caret where it was")
            _ = await Self.settle(window, hosting, timeout: 1.5) { false }  // the settle hop lands
            let f = try #require(
                Self.writeFraction(in: hosting, block: targetRange), "the block is laid out")
            #expect(abs(f - 0.5) <= 0.08,
                    "the block holds the height Read gave it — red-on-old: the viewport top. \(f)")
            window.orderOut(nil)
            window.close()
        }
    }
}
