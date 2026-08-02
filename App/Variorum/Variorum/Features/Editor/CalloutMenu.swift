//
//  CalloutMenu.swift
//  Variorum
//
//  Phase 13k, K6 — **the right-click callout door**. Her report, 2026-08-01:
//  she went looking for callouts in the RIGHT-CLICK and they were not there.
//  They had exactly two doors — the menu bar's Block ▸ Callout submenu and
//  ⌥⌘C — and the context menu is where a per-block act is looked for first.
//
//  ── One vocabulary, three renderers ─────────────────────────────────────
//
//  The rows below are declared ONCE and rendered by the menu bar
//  (`EditorCommands`), the Write editor's context menu (`EditorTextView`) and
//  a take pane's context menu (`TakesShared`). This is the `MarkdownActs.rows`
//  pattern for the same P-1 reason: three surfaces rediscovering "toggle,
//  five colours, emoji, remove" is the drift class the registry exists to
//  kill — and a walk test asserts the three renderers offer the same words.
//
//  ── Nothing new happens ─────────────────────────────────────────────────
//
//  Every row dispatches the SAME routed `.callout(CalloutEdit)` command the
//  menu bar has dispatched since 13c R2-2, so the mounted surface applies it
//  through `updateBlockPresentation` on the block the caret is in (the frame
//  is the BLOCK's — R16/R27 — which is why every surface that knows which
//  block you are in can set it, and why Write was privileged only by where
//  the door was first hung, R118). No new operation, no schema, no second
//  transform.
//

import AppKit

@MainActor
enum CalloutMenu {
    /// The submenu's own title — the registry's verb, so the three doors
    /// cannot be named differently. Deliberately NOT a capability of its own
    /// (it names the group; the act is `.callout`), exactly as the Format
    /// submenu's title is.
    static var title: String { CapabilityRegistry.capability(.callout).verb }

    /// One row of the submenu. `edit == nil` marks the EMOJI row, which has
    /// to gather a glyph before it has an edit to send; `isSeparator` marks
    /// a divider (rendered by whichever item machinery the surface uses).
    struct Row {
        let title: String
        let edit: CalloutEdit?
        var isSeparator = false
        /// The emoji row: no edit until the prompt answers.
        var promptsForEmoji = false
    }

    /// The submenu's shape, in order — the menu bar's own long-standing
    /// arrangement, now shared rather than copied.
    static var rows: [Row] {
        var rows: [Row] = [
            Row(title: "Toggle Callout", edit: .toggle),
            Row(title: "", edit: nil, isSeparator: true),
        ]
        rows += CalloutPalette.names.map {
            Row(title: $0.capitalized, edit: .color($0))
        }
        rows += [
            Row(title: "", edit: nil, isSeparator: true),
            Row(title: "Emoji\u{2026}", edit: nil, promptsForEmoji: true),
            Row(title: "Remove Callout", edit: .color(nil)),
        ]
        return rows
    }

    /// The words the three renderers must agree on (separators excluded) —
    /// what the drift pin compares.
    static var rowTitles: [String] { rows.filter { !$0.isSeparator }.map(\.title) }

    /// **The emoji prompt, in one place** (moved here from `EditorCommands`
    /// at K6 so the right-click and the menu bar cannot ask differently).
    /// Returns the typed glyph, or nil when she cancels — an EMPTY string is
    /// a real answer ("no glyph"), which is why the nil is only cancellation.
    static func promptEmoji() -> String? {
        let alert = NSAlert()
        alert.messageText = "Callout Emoji"
        alert.informativeText = "A leading glyph for this callout (leave empty for none)."
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = field
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return nil }
        return field.stringValue
    }

    /// The context-menu item both TEXT SURFACE kinds insert beside Format —
    /// built here rather than by each surface, for the reason
    /// `MarkdownActs.formatMenuItem` gives: two surfaces rediscovering a
    /// submenu is the drift class.
    ///
    /// `dispatch` is the surface's own route to the act (Write's view model,
    /// a board's model) — this builder decides the WORDS and the ORDER and
    /// nothing else.
    static func menuItem(dispatch: @escaping (CalloutEdit) -> Void) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: title)
        for row in rows {
            if row.isSeparator {
                submenu.addItem(.separator())
                continue
            }
            let menuItem = NSMenuItem(
                title: row.title,
                action: #selector(CalloutMenuTrampoline.fire(_:)),
                keyEquivalent: "")
            let trampoline = CalloutMenuTrampoline(row: row, dispatch: dispatch)
            menuItem.target = trampoline
            menuItem.representedObject = trampoline  // retains it for the menu's life
            submenu.addItem(menuItem)
        }
        item.submenu = submenu
        return item
    }
}

/// The submenu's target object (the `StructuralMenuTrampoline` /
/// `FormatMenuTrampoline` pattern: `NSMenuItem` holds its target weakly, so
/// the item retains this through `representedObject`).
@MainActor
private final class CalloutMenuTrampoline: NSObject {
    private let row: CalloutMenu.Row
    private let dispatch: (CalloutEdit) -> Void

    init(row: CalloutMenu.Row, dispatch: @escaping (CalloutEdit) -> Void) {
        self.row = row
        self.dispatch = dispatch
    }

    @objc func fire(_ sender: Any?) {
        if row.promptsForEmoji {
            guard let glyph = CalloutMenu.promptEmoji() else { return }
            dispatch(.emoji(glyph))
            return
        }
        guard let edit = row.edit else { return }
        dispatch(edit)
    }
}
