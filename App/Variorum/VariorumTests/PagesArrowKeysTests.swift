//
//  PagesArrowKeysTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-5: the note's
//  `read ▸ pages` face bound unmodified ← / → as SwiftUI key equivalents,
//  which the hosting view resolves BEFORE the first responder's `keyDown` —
//  so an arrow typed in the index column's filter field turned a page and
//  never moved the caret. The pins: the rule, pure; and the pages face + the
//  column MOUNTED in the rig's panel, the filter field made first responder,
//  a synthesized ← → the field's caret moved and NO page turned; then with
//  no text field in charge, → turns a leaf. RED ON OLD: the shortcut fired
//  (a turn), the caret stayed.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The pages face's arrow keys (ladder R1-5)")
struct PageTurnKeysRuleTests {
    @Test func anUnmodifiedArrowTurnsOnlyWhileNoTextFieldIsInCharge() {
        #expect(PageTurnKeys.turn(keyCode: 123, modifiers: [], textIsFirstResponder: false) == .back)
        #expect(PageTurnKeys.turn(keyCode: 124, modifiers: [], textIsFirstResponder: false) == .forward)
        // A text-editing first responder owns the arrows.
        #expect(PageTurnKeys.turn(keyCode: 123, modifiers: [], textIsFirstResponder: true) == nil)
        #expect(PageTurnKeys.turn(keyCode: 124, modifiers: [], textIsFirstResponder: true) == nil)
        // A chord is not a page turn; neither is any other key.
        #expect(PageTurnKeys.turn(keyCode: 123, modifiers: .command, textIsFirstResponder: false) == nil)
        #expect(PageTurnKeys.turn(keyCode: 124, modifiers: .shift, textIsFirstResponder: false) == nil)
        #expect(PageTurnKeys.turn(keyCode: 125, modifiers: [], textIsFirstResponder: false) == nil)
    }
}

@MainActor
@Suite("The pages face yields the arrows to a text field (ladder R1-5)", .serialized)
struct PagesArrowKeysHostTests {
    private static func views<V: NSView>(_ type: V.Type, in view: NSView) -> [V] {
        var found: [V] = []
        if let v = view as? V { found.append(v) }
        for sub in view.subviews { found.append(contentsOf: views(type, in: sub)) }
        return found
    }

    /// A key event as the window would receive it.
    private static func key(_ keyCode: UInt16, _ character: String, window: NSWindow) -> NSEvent? {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: character, charactersIgnoringModifiers: character,
            isARepeat: false, keyCode: keyCode)
    }

    /// The pages face beside the column, as Read composes them.
    private struct Host: View {
        let session: AppSession
        let postID: String
        let model: BlockTOCViewModel
        @State private var columnTarget: String?

        var body: some View {
            HStack(spacing: 0) {
                NoteIndexColumn(
                    session: session, model: model, tokens: .fallback(for: .light),
                    selectedBlockID: nil, showsCount: false,
                    columnTarget: $columnTarget, onSelect: { _ in }, onJump: nil)
                    .frame(width: NoteIndexColumn.width)
                NotePagesView(session: session, postID: postID)
            }
        }
    }

    @Test func anArrowInTheFilterFieldMovesTheCaretAndTurnsNoPageAndTurnsALeafOtherwise() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "leaves")
            for i in 1...6 {
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: String(repeating: "Paragraph \(i) of a note long enough to page. ", count: 40))
            }
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            let model = BlockTOCViewModel(session: session, postID: post.id)
            let rig = BlocksWorkbenchFaceTests.Rig(
                Host(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session)),
                width: 1100, height: 750)
            defer { rig.close() }
            // The spread drawn (two leaves) and the column's filter field up.
            #expect(await rig.poll(timeout: 8) {
                Self.views(PageFrameNSView.self, in: rig.hosting).filter { $0.visibleRange.length > 0 }.count >= 2
                    && !Self.views(NSTextField.self, in: rig.hosting).isEmpty
            }, "the pages drawn and the filter field mounted")
            let field = try #require(Self.views(NSTextField.self, in: rig.hosting).first)

            // The filter field takes the keyboard: type into it, caret at the end.
            rig.window.makeFirstResponder(field)
            #expect(await rig.poll(timeout: 2) { rig.window.firstResponder is NSTextView },
                    "the field's editor is first responder")
            let editor = try #require(rig.window.firstResponder as? NSTextView)
            editor.string = "filter"
            editor.setSelectedRange(NSRange(location: 6, length: 0))
            #expect(ReadModeOracle.pageTurns == 0)

            // ← while the field is in charge: the caret moves, no page turns.
            let left = try #require(Self.key(PageTurnKeys.leftArrowKeyCode, "\u{F702}", window: rig.window))
            NSApp.sendEvent(left)
            rig.pump(0.05)
            await rig.turn()
            #expect(editor.selectedRange().location == 5,
                    "the arrow moved the caret in the field: \(editor.selectedRange())")
            #expect(ReadModeOracle.pageTurns == 0, "no page turned while a text field held the keyboard")

            // The field let go: → turns a leaf.
            rig.window.makeFirstResponder(nil)
            _ = await rig.poll(timeout: 2) { !(rig.window.firstResponder is NSTextView) }
            let right = try #require(Self.key(PageTurnKeys.rightArrowKeyCode, "\u{F703}", window: rig.window))
            NSApp.sendEvent(right)
            rig.pump(0.05)
            #expect(await rig.poll(timeout: 2) { ReadModeOracle.pageTurns == 1 },
                    "with no text field in charge the arrow turns the leaf")
        }
    }
}
