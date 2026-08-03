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

    /// The eight acts, in bar order — one table so the bar and any test
    /// walk read the same truth (the registry-walk spirit; the real
    /// capability registry is a later-stage move). ⑂ = Takes (S2 batch 2);
    /// ⋯ = Block (S4 batch 1 — LK8's eighth JOINS with its block menu:
    /// Takes… · Comments… · Callout ▸ · Name… · Divide · Merge · Delete;
    /// P-2 satisfied now that the door can act).
    static let actLabels = [
        "Bold", "Italic", "Heading", "Bullet List", "Checklist", "Indent", "Takes",
        "Block",
    ]

    init(textView: MobileEditorTextView) {
        self.textView = textView
    }

    /// The 44 pt accessory bar riding the keyboard (spike item 6's measured
    /// home), now with its acts live — and, since batch 3, styled by the
    /// LIVE VOICE (the look canon's kbar: the voice surface with a hairline
    /// top edge, act glyphs in the muted chrome ink, mono type in the
    /// terminal voice / the system sans in study — the mockups' own chrome
    /// rule). `MobileEditorTextView.applyVoiceChrome` rebuilds it at the
    /// LK2 switch, so the values are read fresh per build.
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

        var items: [UIBarButtonItem] = [
            act("B", "Bold", #selector(fireBold)),
            .flexibleSpace(),
            act("I", "Italic", #selector(fireItalic)),
            .flexibleSpace(),
            act("#", "Heading", #selector(fireHeading)),
            .flexibleSpace(),
            act("•", "Bullet List", #selector(fireBullet)),
            .flexibleSpace(),
            act("☑", "Checklist", #selector(fireChecklist)),
            .flexibleSpace(),
        ]
        items.append(indentItem(face: face))
        items.append(.flexibleSpace())
        items.append(act("⑂", "Takes", #selector(fireTakes)))
        items.append(.flexibleSpace())
        items.append(blockMenuItem(face: face))
        bar.items = items
        return bar
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
                        title: "Tap into a block first — block acts live on blocks.",
                        attributes: .disabled) { _ in }])
                    return
                }
                completion(model.blockMenu.menuElements(
                    blockID: blockID, includeTakes: true))
            },
        ])
        return UIBarButtonItem(customView: button)
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
