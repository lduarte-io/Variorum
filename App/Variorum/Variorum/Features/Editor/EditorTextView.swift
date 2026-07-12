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
    /// Set while a bulk-entry-classed insertion is being applied — a
    /// clipboard PASTE or a text DROP (author-ratified contract item 7,
    /// Phase 9: a drop into the open tail is bulk entry exactly like paste —
    /// segments on entry, closes the tail; a drop into an existing block is
    /// a content edit at the drop point, I4 — the flag arms nothing when the
    /// verdict isn't the tail, per Phase 7's MAJOR-3 fix).
    private(set) var isPasting = false

    /// ⌘S — commit the caret block's variant (AppSpec §9 commit shortcut).
    var onCommitShortcut: (() -> Void)?

    /// Text drops route through the same bulk-entry flag as paste
    /// (contract item 7 — resolves Phase 7's deferred PROVISIONAL as the
    /// author decided 2026-07-06). AppKit plumbing only: the routing lives
    /// in the flag + the verdict, tested through the seam paste shares.
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        withPasteFlag { super.performDragOperation(sender) }
    }

    /// The context-menu door for structural gestures (Phase 9): the view
    /// model supplies items whose enablement came from THE planner — the
    /// same brain as the menu bar and shortcuts.
    struct StructuralMenuItem {
        let title: String
        let enabled: Bool
        let action: () -> Void
    }

    var structuralMenuItems: (() -> [StructuralMenuItem])?

    override func menu(for event: NSEvent) -> NSMenu? {
        let inherited = super.menu(for: event)
        guard let items = structuralMenuItems?(), !items.isEmpty else { return inherited }
        let menu = inherited ?? NSMenu()
        for (i, item) in items.enumerated() {
            let menuItem = NSMenuItem(
                title: item.title,
                action: #selector(StructuralMenuTrampoline.fire(_:)),
                keyEquivalent: "")
            let trampoline = StructuralMenuTrampoline(enabled: item.enabled, action: item.action)
            menuItem.target = trampoline
            menuItem.representedObject = trampoline  // retains it for the menu's life
            menu.insertItem(menuItem, at: i)
        }
        menu.insertItem(NSMenuItem.separator(), at: items.count)
        return menu
    }

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

    /// The INLINE editor variant (Phase 10 Step 3): the same spike-proven
    /// configuration with NO scroll view of its own — it lives inside the
    /// multi-post container's scroll, sized to content by its SwiftUI
    /// wrapper (the coordinator publishes layout height).
    static func makeInlineEditor() -> EditorTextView {
        let textView = EditorTextView(usingTextLayoutManager: true)
        precondition(textView.textLayoutManager != nil, "TK2 opt-in failed at construction")

        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isVerticallyResizable = false  // the wrapper sizes the frame
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.font = EditorDocument.baseFont
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        return textView
    }
}

/// Target for the structural context-menu items: carries the action closure
/// and answers menu validation with the planner's verdict (NSMenu
/// auto-enablement asks the target, so the standard items keep their own
/// validation untouched).
@MainActor
private final class StructuralMenuTrampoline: NSObject, NSMenuItemValidation {
    private let enabled: Bool
    private let action: () -> Void

    init(enabled: Bool, action: @escaping () -> Void) {
        self.enabled = enabled
        self.action = action
    }

    @objc func fire(_ sender: Any?) {
        action()
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        enabled
    }
}
