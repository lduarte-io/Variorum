//
//  MobileKeyboardBar.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 2 (scope item 5) — the keyboard bar's live acts:
//  **B · I · # · • · ☑ · ⇥ · ⑂** (LK8's ruled eight MINUS ⋯, whose block
//  menu is S4's — a door that can never act in its context isn't
//  rendered, P-2; recorded as the application of LK8, not a deviation).
//  ⑂ JOINED as the seventh act at S2 batch 2, WITH its surface (the takes
//  browser): it opens the browser on the caret's block, refusing honestly
//  in the open tail. Extracted from the batch-1 shell in
//  `MobileEditorTextView.swift`; the bar itself is still the measured
//  `inputAccessoryView` home (spike item 6) — the look canon (L13)
//  restyles it.
//
//  Every act fires `MobileMarkdownActs` — the ordinary policed input path,
//  never a second brain (P-1: the acts' law is the shared
//  `MarkdownEditing`; this file only renders doors).
//
//  ⇥ carries BOTH directions (PROVISIONAL, batch 2 — the software keyboard
//  has no Tab key at all, so the bar's ⇥ IS the phone's Tab): tap =
//  indent, long-press = outdent. Hardware Tab/⇧Tab ride the text view's
//  key commands; ⏎-on-an-empty-nested-item outdents too (K8's rule), so
//  outdent has three doors and none of them is invented vocabulary.
//

import UIKit
import VariorumCore

@MainActor
final class MobileKeyboardBarController: NSObject {
    private weak var textView: MobileEditorTextView?
    /// The LIVE toolbar (weak — the view owns it as its accessory), so
    /// the Aa door can swap its items IN PLACE.
    private weak var bar: UIToolbar?

    /// **The Aa condensation (parity A3 item 1 — HER RULING, the
    /// architect's ADOPT of the proposed expanding row):** at rest the
    /// bar carries THREE doors — **Aa · ⑂ · ⋯** — and Aa expands the
    /// FORMATTING STRIP in place: **× · B · I · # · • · ☑ · ⇥** (the
    /// LK8 order behind one door; × collapses back). A DOOR change, not
    /// a vocabulary change: the six-act grammar, the # cycle + P5
    /// long-press picker, and ⇥'s two directions are byte-identical —
    /// which is exactly why the door is a button strip and never a
    /// UIMenu (menu rows carry no second gesture; a menu-form Aa would
    /// amputate both ruled long-press doors). The bar is the
    /// `inputAccessoryView`, so expand/collapse happens with the
    /// keyboard up, in place; the strip RESETS TO COLLAPSED at each
    /// fresh keyboard presentation (the calm default — accepted at the
    /// ruling, hers to flip at the end sitting), via the keyboard-hide
    /// notification below.
    private(set) var isFormattingExpanded = false

    /// The two states' acts, in bar order — one table per state so the
    /// bar and any test walk read the same truth (the registry-walk
    /// spirit). ⑂ = Takes (S2 batch 2); ⋯ = Block (S4 batch 1, with its
    /// block menu); Aa/× = the formatting door's two faces.
    static let restingActLabels = ["Formatting", "Takes", "Block"]
    static let formattingActLabels = [
        "Hide Formatting", "Bold", "Italic", "Heading", "Bullet List",
        "Checklist", "Indent",
    ]

    init(textView: MobileEditorTextView) {
        self.textView = textView
        super.init()
        // Reset-per-presentation (the ruling's calm default): the strip
        // collapses when the keyboard goes away, so every fresh raise
        // starts on the resting bar; within one presentation it stays
        // as left. Selector-based observers self-remove on deinit.
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    /// The 44 pt accessory bar riding the keyboard (spike item 6's measured
    /// home), now with its acts live — and, since batch 3, styled by the
    /// LIVE VOICE (the look canon's kbar: the voice surface with a hairline
    /// top edge, act glyphs in the muted chrome ink, mono type in the
    /// terminal voice / the system sans in study — the mockups' own chrome
    /// rule). `MobileEditorTextView.applyVoiceChrome` rebuilds it at the
    /// LK2 switch, so the values are read fresh per build. Items resolve
    /// per the Aa door's state (`barItems`).
    func makeBar() -> UIView {
        let face = MobileEditorStyle.face
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.autoresizingMask = [.flexibleWidth]

        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = face.surface
        appearance.shadowColor = face.line
        bar.standardAppearance = appearance
        bar.compactAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.tintColor = face.muted

        self.bar = bar
        bar.items = barItems(face: face)
        return bar
    }

    /// One state's items, flexible-spaced. The strip's six acts are the
    /// SAME builders the flat bar carried — byte-identical doors behind
    /// the one Aa gate.
    private func barItems(face: MobileEditorStyle.Face) -> [UIBarButtonItem] {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: face.chrome, .foregroundColor: face.muted,
        ]
        func act(_ title: String, _ label: String, _ selector: Selector) -> UIBarButtonItem {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
            item.accessibilityLabel = label
            item.setTitleTextAttributes(titleAttributes, for: .normal)
            item.setTitleTextAttributes(titleAttributes, for: .highlighted)
            return item
        }

        let acts: [UIBarButtonItem] = isFormattingExpanded
            ? [
                act("×", "Hide Formatting", #selector(toggleFormattingDoor)),
                act("B", "Bold", #selector(fireBold)),
                act("I", "Italic", #selector(fireItalic)),
                headingItem(face: face),
                act("•", "Bullet List", #selector(fireBullet)),
                act("☑", "Checklist", #selector(fireChecklist)),
                indentItem(face: face),
            ]
            : [
                act("Aa", "Formatting", #selector(toggleFormattingDoor)),
                act("⑂", "Takes", #selector(fireTakes)),
                blockMenuItem(face: face),
            ]
        var items: [UIBarButtonItem] = []
        for (index, item) in acts.enumerated() {
            if index > 0 { items.append(.flexibleSpace()) }
            items.append(item)
        }
        return items
    }

    /// Aa opens the strip; × closes it — one door, two faces, swapping
    /// the LIVE bar's items in place (the keyboard never moves).
    @objc func toggleFormattingDoor() {
        isFormattingExpanded.toggle()
        reloadBarItems()
    }

    private func reloadBarItems() {
        bar?.items = barItems(face: MobileEditorStyle.face)
    }

    /// The reset-per-presentation half (the ruling's calm default).
    @objc private func keyboardDidHide(_ note: Notification) {
        guard isFormattingExpanded else { return }
        isFormattingExpanded = false
        reloadBarItems()
    }

    /// ⋯ — the block menu on the caret's block (S4 batch 1; LK8's eighth
    /// act). A deferred menu rebuilt per open, so it always names the
    /// CURRENT caret block; in the open tail it offers one honest
    /// disabled line instead of a silent door (P-2's speaking form —
    /// the bar's ⑂ refusal, menu-grammared).
    private func blockMenuItem(face: MobileEditorStyle.Face) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle("⋯", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Block"
        button.accessibilityIdentifier = "kbar.block"
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                guard let model = self?.textView?.editorModel else {
                    completion([])
                    return
                }
                guard let blockID = model.blockIDAtCaret() else {
                    completion([UIAction(
                        title: MobileEditorStyle.chromeCase(
                            "Tap into a block first — block acts live on blocks."),
                        attributes: .disabled) { _ in }])
                    return
                }
                completion(model.blockMenu.menuElements(
                    blockID: blockID, includeTakes: true))
            },
        ])
        return UIBarButtonItem(customView: button)
    }

    /// # carries two doors since parity A3 (P5, her ruled flip: "# tap
    /// still cycles; LONG-PRESS opens a direct H1/H2/H3/clear picker"):
    /// tap = the standing cycle, byte-unchanged; long-press = the direct
    /// picker (a real UIButton whose `menu` is NOT the primary action —
    /// UIKit's own long-press-reveals-menu behavior, the ⇥ button's
    /// wrap-a-button precedent). Rows are the Mac heading submenu's own
    /// words plus her "clear" row, voice-cased (P26/P43), rebuilt per
    /// open so the register follows a voice flip.
    private func headingItem(face: MobileEditorStyle.Face) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle("#", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Heading"
        button.accessibilityHint = "Long-press to pick a heading level"
        button.accessibilityIdentifier = "kbar.heading"
        button.addTarget(self, action: #selector(fireHeading), for: .touchUpInside)
        button.showsMenuAsPrimaryAction = false
        button.menu = UIMenu(children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                completion(self?.headingPickerElements() ?? [])
            },
        ])
        return UIBarButtonItem(customView: button)
    }

    /// The picker's rows (test-visible): direct levels through the SAME
    /// shared toggle rule the Mac submenu rides — picking a line's own
    /// level clears it (one vocabulary, no invention) — plus her clear
    /// row, which no-ops where no heading exists.
    func headingPickerElements() -> [UIMenuElement] {
        let cased = MobileEditorStyle.chromeCase
        var rows: [UIMenuElement] = (1...3).map { level in
            UIAction(title: cased("Heading \(level)")) { [weak self] _ in
                self?.applyHeadingPick(level: level)
            }
        }
        rows.append(UIAction(title: cased("Clear Heading")) { [weak self] _ in
            self?.applyHeadingClear()
        })
        return rows
    }

    func applyHeadingPick(level: Int) {
        guard let textView else { return }
        MobileMarkdownActs.apply(.heading(level: level), to: textView)
    }

    func applyHeadingClear() {
        guard let textView,
              let act = MobileMarkdownActs.headingClearAct(in: textView)
        else { return }
        MobileMarkdownActs.apply(act, to: textView)
    }

    /// ⇥ needs a long-press (the outdent half), and a `UIBarButtonItem`
    /// can't carry one — so it wraps a real button.
    private func indentItem(face: MobileEditorStyle.Face) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle("⇥", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Indent"
        button.accessibilityHint = "Long-press to outdent"
        button.addTarget(self, action: #selector(fireIndent), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(
            target: self, action: #selector(fireOutdent(_:)))
        button.addGestureRecognizer(longPress)
        return UIBarButtonItem(customView: button)
    }

    // MARK: - The doors

    @objc func fireBold() { fire(.bold) }
    @objc func fireItalic() { fire(.italic) }
    @objc func fireBullet() { fire(.bullet) }
    @objc func fireChecklist() { fire(.checkbox) }

    /// The # cycle (PROVISIONAL — `MobileMarkdownActs.headingCycleAct`
    /// carries the reasoning: one button where the Mac has a submenu).
    @objc func fireHeading() {
        guard let textView else { return }
        MobileMarkdownActs.apply(
            MobileMarkdownActs.headingCycleAct(in: textView), to: textView)
    }

    /// The bar's ⇥ is the phone's Tab key — one behavior with the hardware
    /// key (indent a list line; an ordinary policed "\t" everywhere else).
    @objc func fireIndent() {
        textView?.performTabKey()
    }

    @objc func fireOutdent(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        fire(.outdent)
    }

    /// ⑂ — the takes browser on the caret's block (S2 batch 2; LK8's
    /// seventh act). The VM routes: a caret outside any block (the open
    /// tail) hears the honest refusal instead of a silent door (P-2).
    @objc func fireTakes() {
        textView?.editorModel?.openTakesBrowserAtCaret()
    }

    private func fire(_ act: MarkdownEditing.Act) {
        guard let textView else { return }
        MobileMarkdownActs.apply(act, to: textView)
    }
}
