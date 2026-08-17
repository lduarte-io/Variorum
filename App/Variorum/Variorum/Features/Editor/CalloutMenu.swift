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
//  ── Phase 13e, E1 — THE CONTROLS GROW UP (her A13(b) ask) ───────────────
//
//  Colour rows gain a SWATCH and the emoji row gains a real PICKER. Both
//  land HERE, in the one vocabulary, rather than at the three doors — which
//  is the whole point of K6's consolidation: an upgraded control that had to
//  be re-hung per door would be three chances to drift (and today's doors
//  are already three: the menu bar, Write's right-click, a take card's).
//
//  **The swatch stores a NAME, never a value.** A callout colour is a
//  THEME-TOKEN NAME by AppSpec §7 (R1) — the swatch is only a rendering of
//  what `CalloutPalette` resolves that name to under the CURRENT appearance,
//  so a palette change reaches the menus and the blocks together and nothing
//  new is ever persisted. The row's title keeps the colour's word beside it:
//  a swatch alone would be the one control in the app that cannot be read
//  aloud (R93's legibility mandate), and it keeps the words a walk test
//  compares identical across the three renderers.
//
//  **The picker is the system's own** (`orderFrontCharacterPalette`) — the
//  zero-dependency road, and the one place every Mac user already knows how
//  to find an emoji. It rides an accessory BUTTON rather than an alert
//  button on purpose: an `NSAlert` button ends the modal session, which
//  would dismiss the prompt the picked glyph is supposed to land in.
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
        /// 13e E1 — the palette TOKEN NAME this row wears as a swatch (nil on
        /// every row that is not a colour: toggle, emoji, and Remove, which
        /// takes a frame away rather than choosing one). It is deliberately
        /// the name and not a colour: the renderer resolves it through
        /// `CalloutPalette` at draw time, under the appearance in force.
        var swatch: String?
    }

    /// The submenu's shape, in order — the menu bar's own long-standing
    /// arrangement, now shared rather than copied.
    static var rows: [Row] {
        var rows: [Row] = [
            Row(title: "Toggle Callout", edit: .toggle),
            Row(title: "", edit: nil, isSeparator: true),
        ]
        rows += CalloutPalette.names.map {
            Row(title: $0.capitalized, edit: .color($0), swatch: $0)
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

    // MARK: - E1: the colour swatches

    /// The swatch's edge, in points — a menu-image size (`NSMenuItem` scales
    /// larger images down, and a 14pt chip sits on the cap height of the row
    /// beside it).
    static let swatchSize: CGFloat = 14

    /// Is the app drawing DARK right now? One reading, shared by all three
    /// renderers, so the menu bar's swatches and a right-click's can never
    /// disagree about which wash the block will wear. (Deliberately the app's
    /// effective appearance rather than a SwiftUI `\.colorScheme`: two of the
    /// three renderers are `NSMenu`s with no environment to read.)
    static func isDarkAppearance() -> Bool {
        NSApp?.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
    }

    /// A colour chip for one palette token. The colour comes from
    /// `CalloutPalette` — the SAME resolution the block's own frame uses — so
    /// the swatch is a preview and never a second source of truth (R1: the
    /// stored value is the NAME).
    ///
    /// `isTemplate = false` is load-bearing: a template image is recoloured by
    /// AppKit/SwiftUI to the control tint, which is exactly the one thing a
    /// colour swatch must not be.
    static func swatchImage(
        for name: String, dark: Bool? = nil, size: CGFloat = swatchSize
    ) -> NSImage {
        let dark = dark ?? isDarkAppearance()
        let fill = CalloutPalette.color(name, dark: dark)
        let image = NSImage(size: NSSize(width: size, height: size), flipped: false) { rect in
            let body = rect.insetBy(dx: 0.5, dy: 0.5)
            let path = NSBezierPath(roundedRect: body, xRadius: 3, yRadius: 3)
            fill.setFill()
            path.fill()
            // A hairline edge, because the lighter washes are close enough to
            // a light menu's own background to read as nothing at all.
            NSColor.separatorColor.setStroke()
            path.lineWidth = 1
            path.stroke()
            return true
        }
        image.isTemplate = false
        image.accessibilityDescription = name
        return image
    }

    // MARK: - E1: the emoji prompt, with the system picker

    /// The prompt's accessory: the field she can type or paste into, and the
    /// door to the system picker beside it.
    ///
    /// Returned as a value (rather than assembled inside `promptEmoji`) so a
    /// pin can inspect the parts and fire the button without running a modal
    /// loop — the `MembershipChip.ascend` lesson: a promise made inside a
    /// closure is a promise no test can keep.
    struct EmojiAccessory {
        let view: NSView
        let field: NSTextField
        let pickerButton: NSButton
        /// Retains the button's target for the accessory's life (`NSButton`
        /// holds its target weakly, the `CalloutMenuTrampoline` reason).
        private let trampoline: NSObject
        init(view: NSView, field: NSTextField, pickerButton: NSButton, trampoline: NSObject) {
            self.view = view
            self.field = field
            self.pickerButton = pickerButton
            self.trampoline = trampoline
        }
    }

    /// The picker door's words. Apple's own name for the panel, so the button
    /// says what will open (⌃⌘Space's own menu item is worded this way).
    static let emojiPickerButtonTitle = "Emoji & Symbols\u{2026}"

    /// Builds the accessory. `openPicker` is injectable for the pin's sake and
    /// defaults to the real thing: focus the field, then hand the system panel
    /// that field as its insertion target.
    static func emojiAccessory(
        openPicker: @escaping (NSTextField) -> Void = { field in
            field.window?.makeFirstResponder(field)
            NSApp?.orderFrontCharacterPalette(field)
        }
    ) -> EmojiAccessory {
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        field.placeholderString = "e.g. \u{1f4a1}"
        let trampoline = EmojiPickerTrampoline(field: field, open: openPicker)
        let button = NSButton(
            title: emojiPickerButtonTitle, target: trampoline,
            action: #selector(EmojiPickerTrampoline.fire(_:)))
        button.bezelStyle = .rounded
        button.controlSize = .small
        // A plain button inside an accessory view does NOT end the alert's
        // modal session — which is why the picker lives here and not as a
        // third alert button (an alert button would dismiss the prompt the
        // glyph is meant to land in).
        let stack = NSStackView(views: [field, button])
        stack.orientation = .horizontal
        stack.spacing = 8
        stack.alignment = .firstBaseline
        stack.frame = NSRect(x: 0, y: 0, width: 320, height: 26)
        return EmojiAccessory(
            view: stack, field: field, pickerButton: button, trampoline: trampoline)
    }

    /// **The emoji prompt, in one place** (moved here from `EditorCommands`
    /// at K6 so the right-click and the menu bar cannot ask differently; 13e
    /// E1 gave it the system picker).
    /// Returns the typed-or-picked glyph, or nil when she cancels — an EMPTY
    /// string is a real answer ("no glyph"), which is why the nil is only
    /// cancellation.
    static func promptEmoji() -> String? {
        let alert = NSAlert()
        alert.messageText = "Callout Emoji"
        alert.informativeText =
            "A leading glyph for this callout — type or paste one, or pick from "
            + "Emoji & Symbols (leave empty for none)."
        let accessory = emojiAccessory()
        alert.accessoryView = accessory.view
        alert.addButton(withTitle: "Set")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return nil }
        return accessory.field.stringValue
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
            // 13e E1 — the swatch, from the one vocabulary's own row.
            if let swatch = row.swatch {
                menuItem.image = swatchImage(for: swatch)
            }
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

/// The emoji prompt's picker button target (13e E1) — the
/// `CalloutMenuTrampoline` pattern, for the same retention reason: `NSButton`
/// holds its target weakly, so the accessory keeps this alive.
@MainActor
private final class EmojiPickerTrampoline: NSObject {
    private weak var field: NSTextField?
    private let open: (NSTextField) -> Void

    init(field: NSTextField, open: @escaping (NSTextField) -> Void) {
        self.field = field
        self.open = open
    }

    @objc func fire(_ sender: Any?) {
        guard let field else { return }
        open(field)
    }
}
