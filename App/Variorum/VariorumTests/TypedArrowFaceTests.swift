//
//  TypedArrowFaceTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 1, item 12 — the Mac face of the typed-arrow brain,
//  driven through the REAL input path (`insertText`, the same road typing
//  takes), so routing, autosave and undo are exercised rather than assumed.
//

import AppKit
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Typed arrows in the editor (Act 10 item 12)", .serialized)
struct TypedArrowFaceTests {
    /// The substitution lands on its own event turn (the undo-separation
    /// mechanism) — one pump is that turn.
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    @Test func typingAnArrowSubstitutesAndAutosaves() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let end = (h.documentText as NSString).length
            h.type(" ", at: end)
            h.type("-")
            h.type(">")
            pump()
            #expect(h.documentText.contains("alpha \u{2192}"))
            // The caret continues after the arrow.
            let doc = h.documentText as NSString
            #expect(h.textView.selectedRange().location
                == doc.range(of: "\u{2192}").location + 1)
            // The arrow is CONTENT: it reaches the store through the same
            // autosave as any typed character.
            await h.flush()
            let slots = try h.storeSlots()
            #expect(slots.first?.text?.contains("\u{2192}") == true)
        }
    }

    @Test func leftArrowSubstitutesToo() async throws {
        try await withEditor(seedBlocks: ["beta"]) { h in
            let end = (h.documentText as NSString).length
            h.type(" ", at: end)
            h.type("<")
            h.type("-")
            pump()
            #expect(h.documentText.contains("beta \u{2190}"))
            await h.flush()
        }
    }

    @Test func insideACodeSpanTheTypedPairStaysLiteral() async throws {
        try await withEditor(seedBlocks: ["see `code` here"]) { h in
            // Type "->" INSIDE the backticks: `co->de` must stay literal.
            let doc = h.documentText as NSString
            let inside = doc.range(of: "co").location + 2
            h.type("-", at: inside)
            h.type(">")
            pump()
            #expect(h.documentText.contains("`co->de`"))
            #expect(!h.documentText.contains("\u{2192}"))
            await h.flush()
        }
    }

    /// **The undo half of the smart-quotes convention, pinned at its
    /// mechanism.** The substitution is one ordinary undoable edit: applied
    /// on a document that saw no other edit, ⌘Z reverts exactly it and the
    /// typed pair comes back.
    ///
    /// The FULL convention (typing run + substitution as two steps) depends
    /// on per-event undo grouping, which this harness cannot produce: the
    /// event-opened top-level group never closes under `RunLoop.run(until:)`
    /// pumps (measured — groupingLevel stayed 1 across pumps, so one undo
    /// swallowed typing and substitution alike, whatever the face did; a
    /// manual end-grouping stand-in crashed NSUndoManager with
    /// `_registerUndoObject:: must begin a group`). The split rides real
    /// event turns in the app and is verified there (the wave record's
    /// walk); the face's own contribution — breakUndoCoalescing on both
    /// sides + its own runloop pass — is what this pin's mechanism needs.
    @Test func theSubstitutionIsItsOwnUndoableEdit() async throws {
        try await withEditor(seedBlocks: ["gamma x ->"]) { h in
            // Undo needs a window's undo manager (headless, the text view
            // has none and ⌘Z would be a no-op the test cannot see).
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 400),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            window.makeFirstResponder(h.textView)
            let um = try #require(h.textView.undoManager)

            // Caret just after the seeded "->", as the keystroke leaves it.
            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            MarkdownActs.applyTypedArrowSubstitution(in: h.textView)
            #expect(h.documentText.contains("gamma x \u{2192}"))

            um.undo()
            #expect(h.documentText.contains("gamma x ->"))
            #expect(!h.documentText.contains("\u{2192}"))
            await h.flush()
        }
    }

    /// **The BURST case** (measured live with synthesized zero-gap
    /// keystrokes): more text lands before the deferred pass runs. The
    /// substitution is anchored at the typed pair, so it still lands and
    /// everything typed after shifts with the 2-for-1 edit. RED on the
    /// unanchored implementation, which read the live caret, saw "> ",
    /// and declined.
    @Test func aFastBurstStillEarnsItsArrow() async throws {
        try await withEditor(seedBlocks: ["epsilon"]) { h in
            let end = (h.documentText as NSString).length
            // No pumps between keystrokes: the whole burst lands in one
            // turn, exactly as a zero-gap synthesizer (or a very fast
            // typist) delivers it.
            h.type(" p ", at: end)
            h.type("-")
            h.type(">")
            h.type(" q.")
            pump()
            #expect(h.documentText.contains("epsilon p \u{2192} q."))
            await h.flush()
        }
    }

    @Test func longerDashRunsStayLiteralThroughTheFace() async throws {
        try await withEditor(seedBlocks: ["delta"]) { h in
            let end = (h.documentText as NSString).length
            h.type(" -", at: end)
            h.type("-")
            h.type(">")
            pump()
            #expect(h.documentText.contains("delta -->"))
            #expect(!h.documentText.contains("\u{2192}"))
            await h.flush()
        }
    }
}
