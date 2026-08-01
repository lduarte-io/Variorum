//
//  MarkdownActs.swift
//  Variorum
//
//  Phase 13g, batch 3 (L8 + L9's ruled half) — the FORMATTING ACTS' faces
//  over the pure edit computations in `MarkdownEditing`.
//
//  ── The one architectural claim ──────────────────────────────────────────
//
//  **A formatting act is an ordinary edit, applied through the ordinary
//  input path.** It calls `shouldChangeText` → `replaceCharacters` →
//  `didChangeText` on the surface she is typing in, which is exactly what
//  typing does: the Write editor's delegate routes the verdict, updates
//  `BlockRangeIndex`, records autosave and churn and refuses under a seal or
//  a locked take; a pane's coordinator restyles its lines and hands the new
//  text to its board's autosave. Nothing here writes a row, adds an
//  operation, or touches a schema — under her ruling F-1 the markers ARE the
//  text (`EditorFind`'s precedent, same reasoning, same trio of calls).
//
//  **It can never restructure a note.** Every edit `MarkdownEditing` emits
//  sits inside ONE LINE, and a line sits inside one block (blocks are joined
//  on the editor surface by a single `"\n"`, so a seam always terminates a
//  line). The cross-block arm of the editor's pipeline — which MERGES blocks,
//  the ratified 2026-07-09 merge-then-edit made for a deliberate hand-made
//  selection — is therefore unreachable from here BY CONSTRUCTION, rather
//  than by a pre-check the way find-and-replace needs.
//
//  ── Why the target is the FIRST RESPONDER ────────────────────────────────
//
//  Formatting acts on the text she is typing in, and the object that knows
//  which surface that is is the key window's first responder — the same
//  mechanism AppKit's own Format menu uses. It is NOT a second liveness
//  mechanism (P-3): it decides nothing about which pane is live; it asks who
//  currently holds the keyboard, which liveness has ALREADY decided (a live
//  pane makes itself first responder; `PaneTextAuthority` remains the only
//  authority on which pane that is). The alternative — plumbing a text-view
//  reference out of five boards — is the private-copy class this app has
//  paid for before.
//
//  The target must also be OURS: `MarkdownFormattable` is opted into by the
//  two surface kinds and nothing else, so a rename field, the ⌘K search field
//  or the quick-note pad (all NSTextViews, all editable) can never receive
//  `****` from a menu key.
//

import AppKit
import Foundation
import VariorumCore

/// A text surface the formatting acts may act on. Opted into explicitly by
/// the app's two surface kinds (P-3's deliberate pair) — a field editor is
/// an editable `NSTextView` too, and this is what keeps ⌘B out of it.
protocol MarkdownFormattable: NSTextView {}

@MainActor
enum MarkdownActs {
    // MARK: - The act table (menu order)

    /// One row of the Format menu: a registry id, its act, and — for the
    /// heading family — its children. Declared once and rendered by both the
    /// menu bar and the context menu, so the two can never disagree.
    struct Row {
        let id: CapabilityID
        let act: MarkdownEditing.Act?
        var children: [(title: String, act: MarkdownEditing.Act)] = []
    }

    static let rows: [Row] = [
        Row(id: .formatBold, act: .bold),
        Row(id: .formatItalic, act: .italic),
        Row(id: .formatStrikethrough, act: .strikethrough),
        Row(id: .formatCode, act: .code),
        Row(id: .formatHeading, act: nil, children: [
            ("Heading 1", .heading(level: 1)),
            ("Heading 2", .heading(level: 2)),
            ("Heading 3", .heading(level: 3)),
        ]),
        Row(id: .formatBulletList, act: .bullet),
        Row(id: .formatChecklist, act: .checkbox),
    ]

    /// The heading submenu's rows — read by BOTH the menu bar and the
    /// context menu, so the two can never offer different sizes.
    static var headingRows: [(title: String, act: MarkdownEditing.Act)] {
        rows.first { $0.id == .formatHeading }?.children ?? []
    }

    /// The registry ids the FORMAT CONTEXT SUBMENU renders — walk-asserted
    /// against the `.contextMenu` door set like every other door table. The
    /// submenu is built here rather than by each surface for the same reason
    /// the acts share one applier: seven surfaces rediscovering the rows is
    /// the drift class P-1 exists to kill.
    nonisolated static let contextMenuCapabilities: [CapabilityID] = [
        .formatBold, .formatItalic, .formatStrikethrough, .formatCode,
        .formatHeading, .formatBulletList, .formatChecklist,
    ]

    /// What the menu door says when a note is open but the keyboard is
    /// somewhere that cannot be formatted (a sidebar row, a read pane, a
    /// sealed note's read-only editor). One sentence, one place — the
    /// registry's own note covers the other case, where nothing is open at
    /// all and the item is honestly grey.
    static let noTargetNote =
        "Click into the text you want to format first — formatting acts on "
        + "the writing surface you're in."

    /// The submenu's own title — not a capability (it names the group, it is
    /// not an act), so it is deliberately undeclared, exactly as the callout
    /// menu's colour rows are.
    static let menuTitle = "Format"

    // MARK: - Targeting

    /// The surface a menu-bar or palette door acts on: the key window's first
    /// responder, when it is one of ours AND editable. Nil ⇒ the door speaks
    /// its declared note instead of acting (P-2 — never a silent key).
    static func target(in window: NSWindow?) -> NSTextView? {
        guard let view = window?.firstResponder as? NSTextView,
              view is MarkdownFormattable, view.isEditable
        else { return nil }
        return view
    }

    // MARK: - Applying

    /// Runs `act` on `textView` through the ordinary input path. Returns
    /// whether anything changed.
    ///
    /// Edits are applied LAST FIRST so every earlier offset stays valid (the
    /// reason the SDK's own finder gives for its reverse ordering), under ONE
    /// undo group so ⌘Z takes back the act she performed rather than one of
    /// its halves. A range the pipeline refuses (a locked take inside a
    /// multi-line selection) is SKIPPED — its refusal has already spoken
    /// through the delegate — and the selection is only re-placed when every
    /// edit landed, because a partly-applied plan's computed selection would
    /// be a guess.
    @discardableResult
    static func apply(_ act: MarkdownEditing.Act, to textView: NSTextView) -> Bool {
        guard textView.isEditable else { return false }
        let string = textView.string as NSString
        let selection = textView.selectedRange()
        guard selection.location != NSNotFound,
              selection.upperBound <= string.length
        else { return false }

        // Whole lines in, shifted results out — the `MarkdownStyling.restyle`
        // shape, and the whole of the P1 claim: the cost is the lines the
        // selection touches, never the note.
        let lines = string.lineRange(for: selection)
        let low = selection.location - lines.location
        let high = selection.upperBound - lines.location
        let plan = MarkdownEditing.plan(
            act, inLines: string.substring(with: lines), selection: low..<high)
        guard !plan.isEmpty else { return false }

        let undoManager = textView.undoManager
        undoManager?.beginUndoGrouping()
        defer { undoManager?.endUndoGrouping() }

        var applied = 0
        for edit in plan.edits.reversed() {
            let range = NSRange(
                location: lines.location + edit.range.lowerBound,
                length: edit.range.count)
            guard textView.shouldChangeText(in: range, replacementString: edit.replacement)
            else { continue }
            textView.replaceCharacters(in: range, with: edit.replacement)
            textView.didChangeText()
            applied += 1
        }
        guard applied == plan.edits.count else { return applied > 0 }
        textView.setSelectedRange(NSRange(
            location: lines.location + plan.selection.lowerBound,
            length: plan.selection.count))
        return true
    }

    // MARK: - L9: the checkbox click

    /// A click landing ON a checkbox's box toggles it — one ordinary edit of
    /// three characters for three, so every offset in the note (the caret
    /// included) is exactly where it was.
    ///
    /// **Mechanism, and why it cannot eat an ordinary caret click:** the
    /// surface asks this BEFORE `super.mouseDown` (which runs AppKit's
    /// selection-tracking loop, so there is no "after" in which to decline),
    /// and the answer is no unless the click's insertion index lands STRICTLY
    /// INSIDE the box's three characters. A click yields a BOUNDARY index, so
    /// the box's own outer boundaries are also produced by clicks on the half
    /// character outside it; accepting those would steal a caret aimed at the
    /// text. Everything else — a read pane, a sealed editor (neither is
    /// editable), any click a character away — falls straight through to the
    /// standing behaviour, click-to-focus included. This is the batch-1
    /// `PaneFocusCatcher` lesson in its other form: that one observes and
    /// never consumes because it has no target of its own; this one consumes
    /// exactly when it has one.
    static func toggleCheckbox(at point: NSPoint, in textView: NSTextView) -> Bool {
        guard textView.isEditable else { return false }
        let string = textView.string as NSString
        guard string.length > 0 else { return false }
        let index = textView.characterIndexForInsertion(at: point)
        guard index >= 0, index <= string.length else { return false }

        let lines = string.lineRange(for: NSRange(location: index, length: 0))
        guard let edit = MarkdownEditing.checkboxToggle(
            inLines: string.substring(with: lines),
            insertionIndex: index - lines.location)
        else { return false }

        let range = NSRange(
            location: lines.location + edit.range.lowerBound, length: edit.range.count)
        let selection = textView.selectedRange()
        textView.window?.makeFirstResponder(textView)
        // A refusal (a sealed note reached by a race, a locked take) has
        // already spoken through the delegate; the click is still consumed,
        // because it landed on a box and moving the caret there instead would
        // be answering a different gesture.
        if textView.shouldChangeText(in: range, replacementString: edit.replacement) {
            textView.replaceCharacters(in: range, with: edit.replacement)
            textView.didChangeText()
            // The replacement is the same length as what it replaces, so the
            // caret can simply go back where it was.
            textView.setSelectedRange(selection)
        }
        return true
    }

    // MARK: - The context-menu door

    /// The "Format" submenu a surface inserts into its context menu — nil
    /// where the surface cannot be edited, because a door that can never act
    /// in its context is not rendered at all (P-2).
    static func formatMenuItem(for textView: NSTextView) -> NSMenuItem? {
        guard textView is MarkdownFormattable, textView.isEditable else { return nil }
        let item = NSMenuItem(title: menuTitle, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: menuTitle)
        for row in rows {
            let capability = CapabilityRegistry.capability(row.id)
            if let act = row.act {
                submenu.addItem(menuItem(
                    title: capability.verb, act: act, textView: textView))
            } else {
                let parent = NSMenuItem(title: capability.verb, action: nil, keyEquivalent: "")
                let children = NSMenu(title: capability.verb)
                for child in row.children {
                    children.addItem(menuItem(
                        title: child.title, act: child.act, textView: textView))
                }
                parent.submenu = children
                submenu.addItem(parent)
            }
        }
        item.submenu = submenu
        return item
    }

    private static func menuItem(
        title: String, act: MarkdownEditing.Act, textView: NSTextView
    ) -> NSMenuItem {
        let item = NSMenuItem(
            title: title, action: #selector(FormatMenuTrampoline.fire(_:)), keyEquivalent: "")
        let trampoline = FormatMenuTrampoline(act: act, textView: textView)
        item.target = trampoline
        item.representedObject = trampoline  // retains it for the menu's life
        return item
    }
}

/// The context menu's target object (the `StructuralMenuTrampoline` pattern:
/// `NSMenuItem` holds its target weakly, so the item retains this through
/// `representedObject`). It holds its text view weakly for the same reason
/// every other controller here does — a menu outliving its surface must do
/// nothing, not crash.
@MainActor
private final class FormatMenuTrampoline: NSObject {
    private let act: MarkdownEditing.Act
    private weak var textView: NSTextView?

    init(act: MarkdownEditing.Act, textView: NSTextView) {
        self.act = act
        self.textView = textView
    }

    @objc func fire(_ sender: Any?) {
        guard let textView else { return }
        MarkdownActs.apply(act, to: textView)
    }
}
