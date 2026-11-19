//
//  TrashSearchField.swift
//  Variorum (Mac)
//
//  **VX-93 (the vx-980 run, batch 3) — a search INSIDE the Trash.** Her words
//  at the VX-83 sitting: *"it might be better to just add a search to trash
//  later than add trash to the main search."* Her rulings at this run's
//  kickoff (`notes/plans/fixes/vx-980-her-rulings.md`):
//
//  · R-980-9 — names and deleted text (the read: `Queries.trashSearch`);
//  · R-980-10 — every word, case and accents ignored, partial words match, no
//    grammar (the match: `TrashTextMatch`);
//  · R-980-11 — one quiet passage line under a row matched by text it does
//    not already show (`RecoveryView.trashRow`);
//  · R-980-12 — the FIELD: always visible in the Trash's header beside the
//    kind filter, empty on every visit, esc clears it, it narrows as she
//    types, alongside the kind filter; Empty Trash stays a whole-Trash door.
//
//  This file is the field and its words. The model's half (the typed words,
//  the debounced ask, the question token) is `RecoveryViewModel`'s.
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The words (PROVISIONAL wording — R-980-4: "provisional wording is
// fine for now, you can keep them listed though"; every one is in the run
// record's RENDERED STRINGS)

enum TrashSearchCopy {
    /// The field's prompt — the Archived surface's own idiom one room over
    /// ("Search archived notes and books…").
    static let prompt = "Search the Trash\u{2026}"
    static let help = "Lists what in the Trash holds every word you type \u{2014} names and deleted text. Esc clears."
    static let accessibilityLabel = "Search the Trash"

    /// **The filtered-empty sentence** (R-980-12: with words typed and nothing
    /// matching, the surface says so in the filtered-empty idiom — never the
    /// Trash-is-empty sentence). The kind filter composes, so the sentence
    /// names the kind when one is picked.
    static func noMatches(filteredBy kind: Queries.TrashItem.Kind?) -> String {
        guard let kind else { return "Nothing in the Trash matches." }
        return "No \(RecoveryCopy.kindLabel(kind).lowercased()) in the Trash match."
    }
}

// MARK: - The timing

nonisolated enum TrashSearchTiming {
    /// The listing answers as she types, once the typing pauses this long
    /// (R-980-12's "narrows as she types", debounced). A field emptied by
    /// any road answers at once.
    static let debounce: Duration = .milliseconds(180)
}

// MARK: - The field

/// **The Trash's search field — AppKit's, on purpose** (the sidebar field's
/// precedent, `SidebarSearchTextField`). A SwiftUI `TextField` is an
/// `NSTextField` in the window's key-view loop; the Trash has no key-view stop
/// today, and a window whose first content is the Trash would make such a
/// field its OPENING first responder — the caret VX-332's law keeps for the
/// Bookcase's quick entry. This field is never a key-view stop
/// (`canBecomeKeyView` false — not the opening pick, not a Tab stop): a click
/// puts the caret here. Its keys are the delegate's: esc
/// (`cancelOperation:`) clears, ⏎ (`insertNewline:`) asks at once.
///
/// Its width never follows its text (`intrinsicContentSize` names no width):
/// the frame the surface gives it is the frame it keeps, so typing never moves
/// anything beside it or below it.
struct TrashSearchTextField: NSViewRepresentable {
    let text: String
    let prompt: String
    let font: NSFont
    let ink: NSColor
    let promptInk: NSColor
    let onEdit: (String) -> Void
    let onSubmit: () -> Void
    let onEscape: () -> Void

    /// The one AppKit subclass: never a key-view stop, no text-driven width.
    final class Field: NSTextField {
        override var canBecomeKeyView: Bool { false }
        override var intrinsicContentSize: NSSize {
            NSSize(width: NSView.noIntrinsicMetric, height: super.intrinsicContentSize.height)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeNSView(context: Context) -> Field {
        let field = Field()
        field.isBordered = true
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.usesSingleLineMode = true
        field.lineBreakMode = .byClipping
        field.cell?.wraps = false
        field.cell?.isScrollable = true
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        field.setAccessibilityLabel(TrashSearchCopy.accessibilityLabel)
        field.delegate = context.coordinator
        style(field)
        field.stringValue = text
        return field
    }

    func updateNSView(_ field: Field, context: Context) {
        context.coordinator.parent = self
        style(field)
        // The model's words are the truth: esc or a fresh visit clears them
        // here — through the field EDITOR while she is in it, so the caret
        // stays and the editing goes on.
        if field.stringValue != text {
            if let editor = field.currentEditor() as? NSTextView {
                editor.string = text
            } else {
                field.stringValue = text
            }
        }
    }

    private func style(_ field: Field) {
        if field.font != font { field.font = font }
        if field.textColor != ink { field.textColor = ink }
        let placeholder = NSAttributedString(
            string: prompt, attributes: [.font: font, .foregroundColor: promptInk])
        if field.placeholderAttributedString != placeholder { field.placeholderAttributedString = placeholder }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: TrashSearchTextField

        init(parent: TrashSearchTextField) { self.parent = parent }

        func controlTextDidChange(_ notification: Notification) {
            guard let field = notification.object as? NSTextField else { return }
            parent.onEdit(field.stringValue)
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            switch selector {
            case #selector(NSResponder.insertNewline(_:)):
                parent.onSubmit()
                return true
            case #selector(NSResponder.cancelOperation(_:)):
                // Esc clears a field holding words; an empty field lets the
                // key go on to whoever else answers it.
                guard !textView.string.isEmpty else { return false }
                parent.onEscape()
                return true
            default:
                return false
            }
        }
    }
}

/// **Where the field sits and how wide it is** — first in the Trash's
/// controls row, beside the kind filter (R-980-12). Its width is the row's
/// to give, between these bounds, and never its text's.
nonisolated enum TrashSearchFieldLayout {
    static let minWidth: CGFloat = 120
    static let maxWidth: CGFloat = 200
}
