//
//  ConfirmationsSettingTests.swift
//  VariorumTests
//
//  **18i — THE CONFIRMATIONS SETTING** (her ruling R-Q5, the 2026-09-12
//  use-report round; her words: *"there's these little text confirmation
//  popups that are always appearing… i either need them off, more subtle in
//  the bottom bar in more muted text, or a setting if i can turn it on or
//  off"*, and on the default: *"Quiet should be the default, but toast
//  should still be an option"*).
//
//  `StatusCenterTests` pins the SEAM — which slot each kind lands in under
//  each setting. THIS suite pins the classification BY BEHAVIOUR, through
//  two real doors driven the way she drives them: the seam backspace that
//  joins two blocks (her image 6) and the newlines chip (her image 7). It is
//  the brief's "pin by BEHAVIOUR on two representative doors" — a grep over
//  the source would prove a spelling, not a behaviour.
//
//  RED ON OLD (by behavioural revert of the two SITES — `showReceipt` back
//  to `showStatus`, which is exactly what they said before 18i): the receipt
//  lands as a TOAST under `.quiet`. The numbers are in the batch record.
//

import AppKit
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The confirmations setting — the doors (18i, R-Q5)", .serialized)
struct ConfirmationsSettingTests {
    private static let joinReceipt = "Blocks joined — \u{2325}\u{2318}Z undoes it."

    private func hosted(_ h: EditorHarness) throws -> (window: NSWindow, teardown: () -> Void) {
        let hosted = ReturnKeyTraceTests.host(try #require(h.textView.enclosingScrollView))
        hosted.window.makeFirstResponder(h.textView)
        return hosted
    }

    private func caret(_ h: EditorHarness, entry i: Int, offset: Int) {
        h.textView.setSelectedRange(
            NSRange(location: h.model.index.range(ofEntryAt: i).location + offset, length: 0))
        h.model.updateCaretContext()
    }

    /// A real Delete key through `keyDown` — the road a seam backspace
    /// takes (`ReturnKeyTraceTests`' own helper, same reasoning: the
    /// question is what the KEY does).
    private func deleteKey(_ h: EditorHarness, _ window: NSWindow) {
        let event = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [], timestamp: 0,
            windowNumber: window.windowNumber, context: nil,
            characters: "\u{7F}", charactersIgnoringModifiers: "\u{7F}",
            isARepeat: false, keyCode: 51)!
        h.textView.keyDown(with: event)
    }

    /// Backspace at the seam between two texted blocks: they join, and the
    /// receipt says so. Shared by the three setting arms below so the
    /// GESTURE is written once and only the setting differs.
    private func joinAtTheSeam(_ h: EditorHarness) async throws {
        let window = try hosted(h)
        defer { window.teardown() }
        caret(h, entry: 1, offset: 0)
        deleteKey(h, window.window)
        await h.flush()
        for _ in 0..<400 where h.model.statusMessage == nil {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    // MARK: - Her image 6: the seam backspace's join

    /// **HER DEFAULT.** The join lands, and its confirmation is a muted line
    /// in the bottom bar — no toast over the prose.
    @Test func theSeamJoinSpeaksQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .quiet
            try await joinAtTheSeam(h)

            #expect(try h.storeSlots().count == 1, "the blocks really joined")
            #expect(h.session.status.current == nil, "NO TOAST — this is the whole row")
            #expect(h.session.status.quietLine?.text == Self.joinReceipt,
                    "…the bar's quiet line carries her words, unchanged")
            #expect(h.session.status.quietLine?.kind == .receipt)
            #expect(h.model.statusMessage == Self.joinReceipt,
                    "the model's tested property is untouched by the routing")
        }
    }

    /// **TOAST STAYS AN OPTION** (her words). The same gesture, the old face.
    @Test func theSameJoinToastsWhenSheAsksForToasts() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .toast
            try await joinAtTheSeam(h)

            #expect(h.session.status.current?.text == Self.joinReceipt)
            #expect(h.session.status.quietLine == nil)
        }
    }

    /// **OFF MEANS OFF** — and the receipt still REACHED the centre, so the
    /// door is speaking and the setting is swallowing (not a door gone
    /// silent by accident).
    @Test func theSameJoinSaysNothingWhenConfirmationsAreOff() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .off
            try await joinAtTheSeam(h)

            #expect(try h.storeSlots().count == 1, "the act still lands")
            #expect(h.session.status.current == nil && h.session.status.quietLine == nil)
            #expect(h.session.status.lastDroppedReceipt == Self.joinReceipt)
        }
    }

    // MARK: - Her image 7: the newlines chip

    /// The chip's sentence is a RECEIPT of a toggle that landed — quiet by
    /// default, with the words untouched.
    @Test func theNewlinesChipSpeaksQuietlyUnderHerDefault() async throws {
        try await withEditor(seedBlocks: ["alpha."]) { h in
            h.session.status.receiptStyle = .quiet
            await h.model.setNewlinesMintBlocks(false)

            #expect(h.session.status.current == nil, "no toast")
            #expect(h.session.status.quietLine?.text == SegmentationFaceCopy.mintOffNote,
                    "the chip's own sentence, byte-unchanged")
            #expect(h.session.status.quietLine?.kind == .receipt)
        }
    }

    // MARK: - What the setting must NEVER reach

    /// **A REFUSAL IS NOT A CONFIRMATION.** With receipts OFF — the most
    /// aggressive setting she can choose — a door that could not act still
    /// delivers the operations layer's real refusal, as a toast (P-2,
    /// fire-and-DO). This is the guard that makes the setting safe to
    /// default to something other than `toast`.
    @Test func aRefusalStillToastsWithConfirmationsOff() async throws {
        try await withEditor(seedBlocks: []) { h in
            h.session.status.receiptStyle = .off
            await h.model.commitCaret()  // no caret block: the real refusal

            #expect(h.session.status.current?.text == "Place the caret in a block to commit.")
            #expect(h.session.status.current?.kind == .refusal)
            #expect(h.session.status.quietLine == nil)
            #expect(h.session.status.lastDroppedReceipt == nil, "nothing was dropped")
        }
    }

    /// **A DIRECTION RIDES THE REFUSAL CLASS** (the brief's letter: the undo
    /// hint is a direction, not a receipt). ⌘Z with nothing on the text
    /// stack and something on the structural one points at the other chord —
    /// and she must see it whatever her confirmations setting says.
    @Test func theUndoHintIsADirectionAndAlwaysShows() async throws {
        try await withEditor(seedBlocks: ["alpha.", "beta."]) { h in
            h.session.status.receiptStyle = .off
            // A structural act, so the structural stack has an entry and
            // the text stack does not (the rewrite clears it by design).
            try await joinAtTheSeam(h)
            h.session.status.clear()

            h.model.speakUndoHint(.undo)
            let spoken = try #require(h.session.status.current?.text)
            #expect(spoken.contains("\u{2325}\u{2318}Z"), "it names the chord that CAN: \(spoken)")
            #expect(h.session.status.current?.kind == .refusal,
                    "a direction is not a confirmation — it always shows")
        }
    }
}
