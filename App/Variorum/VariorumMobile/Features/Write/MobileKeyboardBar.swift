//
//  MobileKeyboardBar.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 2 (scope item 5) — the keyboard bar's SIX live
//  formatting acts: **B · I · # · • · ☑ · ⇥** (LK8's ruled eight MINUS ⑂
//  and ⋯, which arrive WITH their surfaces in S2 — a door that can never
//  act in its context isn't rendered, P-2; recorded as the application of
//  LK8, not a deviation). Extracted from the batch-1 shell in
//  `MobileEditorTextView.swift`; the bar itself is still the measured
//  `inputAccessoryView` home (spike item 6), functional-unstyled — the
//  look canon (L13) restyles it.
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

    /// The six acts, in bar order — one table so the bar and any test walk
    /// read the same truth (the registry-walk spirit; the real capability
    /// registry is a later-stage move).
    static let actLabels = ["Bold", "Italic", "Heading", "Bullet List", "Checklist", "Indent"]

    init(textView: MobileEditorTextView) {
        self.textView = textView
    }

    /// The 44 pt accessory bar riding the keyboard (spike item 6's measured
    /// home), now with its acts live.
    func makeBar() -> UIView {
        let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        bar.autoresizingMask = [.flexibleWidth]

        func act(_ title: String, _ label: String, _ selector: Selector) -> UIBarButtonItem {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
            item.accessibilityLabel = label
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
        items.append(indentItem())
        bar.items = items
        return bar
    }

    /// ⇥ needs a long-press (the outdent half), and a `UIBarButtonItem`
    /// can't carry one — so it wraps a real button.
    private func indentItem() -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setTitle("⇥", for: .normal)
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

    private func fire(_ act: MarkdownEditing.Act) {
        guard let textView else { return }
        MobileMarkdownActs.apply(act, to: textView)
    }
}
