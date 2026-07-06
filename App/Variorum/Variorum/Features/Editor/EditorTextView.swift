//
//  EditorTextView.swift
//  Variorum
//
//  The TK2 NSTextView + scroll view, configured exactly as the Phase 6 spike
//  proved out (explicit usingTextLayoutManager:true opt-in; nothing in this
//  target touches .layoutManager or any NSLayoutManager API — grep-audited
//  per the phase ground rule). Plain text: block text is the only content;
//  the block-ID attribute is bookkeeping, not styling.
//

import AppKit

@MainActor
final class EditorTextView: NSTextView {
    /// Set while a clipboard paste is being applied — the tail treats paste
    /// as bulk entry (segments on entry) rather than typing.
    private(set) var isPasting = false

    /// ⌘S — commit the caret block's variant (AppSpec §9 commit shortcut).
    var onCommitShortcut: (() -> Void)?

    override func paste(_ sender: Any?) {
        withPasteFlag { pasteAsPlainText(sender) } // plain text: never import foreign styling
    }

    /// Runs `body` with the paste flag raised — the paste path itself, and a
    /// seam for tests to drive bulk entry without the global pasteboard.
    func withPasteFlag<T>(_ body: () -> T) -> T {
        isPasting = true
        defer { isPasting = false }
        return body()
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
           event.charactersIgnoringModifiers == "s",
           let onCommitShortcut {
            onCommitShortcut()
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    /// Builds the spike-proven editor stack. The precondition is the TK2
    /// opt-in guarantee; the canary guards the rest of the session.
    static func makeEditor() -> (scrollView: NSScrollView, textView: EditorTextView) {
        let textView = EditorTextView(usingTextLayoutManager: true)
        precondition(textView.textLayoutManager != nil, "TK2 opt-in failed at construction")

        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.font = EditorDocument.baseFont
        // Substitutions rewrite text behind the caret; keep the surface
        // literal (they would also route through the edit pipeline, but the
        // author's prose should not be silently rewritten). Spell checking
        // stays available via the Edit menu; continuous checking defaults
        // off pending the §3 completion-popover crash class — the diagnostic
        // toggle the plan calls for.
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        return (scrollView, textView)
    }
}
