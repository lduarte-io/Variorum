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
    ///
    /// **The strip is ONE bar item, never seven (Stage A ladder FIX-5,
    /// the round-1.5 MAJOR):** as seven separate `UIBarButtonItem`s,
    /// iOS 26's circle-per-item toolbar gave every plain item a 62 pt
    /// glass cell (52 pt button + 5 pt padding each side), the two
    /// wrapped buttons 48 pt cells, and compressed the six flexible
    /// spaces to 12 pt gaps — 5×62 + 2×48 + 6×12 = **478 pt, centered
    /// in the 402 pt bar**, hanging 38 pt off EACH edge: × and ⇥
    /// rendered as edge slivers (the collapse door barely tappable, ⇥
    /// effectively invisible). The fix owns the geometry: the seven
    /// acts are real `UIButton`s in one `UIStackView`
    /// (`kbar.formattingStrip`) carried by a single customView item —
    /// 7×44 pt targets + 6×2 pt gaps = 320 pt intrinsic, inside the
    /// tightest iPhone class's cell (measured windowed: the toolbar's
    /// content row insets 16 pt a side and the customView's glass cell
    /// pads 5 pt a side, so a 375 pt bar still offers 375−32−10 =
    /// 333 pt), so overflow is impossible by construction, nothing
    /// scrolls, and nothing hides. Our own stack also lays out
    /// WINDOWLESS, which is what makes the visibility pin possible at
    /// all — the toolbar's private item cells only materialize in a
    /// window, which is exactly how the clip escaped A3's suite.
    private(set) var isFormattingExpanded = false

    /// The strip's geometry constants (pinned): a 44 pt floor keeps
    /// every act a full HIG tap target; the gap stays tight so seven
    /// acts read as one strip and the row keeps headroom on every
    /// supported width.
    static let stripButtonMinWidth: CGFloat = 44
    static let stripButtonHeight: CGFloat = 38
    static let stripSpacing: CGFloat = 2

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

    /// One state's items. The resting bar is three flexible-spaced
    /// doors; the expanded state is the ONE-cell strip (FIX-5 — seven
    /// separate items overflowed the bar, see the class doc), centered.
    /// The strip's six acts are the SAME builders the flat bar carried —
    /// byte-identical doors behind the one Aa gate.
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

        if isFormattingExpanded {
            return [.flexibleSpace(), formattingStripItem(face: face), .flexibleSpace()]
        }
        let acts: [UIBarButtonItem] = [
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

    /// The expanded formatting strip — ONE customView item whose seven
    /// acts are real buttons in one stack (`kbar.formattingStrip`), in
    /// the LK8 order behind the door: × · B · I · # · • · ☑ · ⇥. Owning
    /// the row's geometry is the FIX-5 mechanism (the class doc has the
    /// overflow arithmetic); each button keeps its exact selector, label,
    /// and second gesture — the # picker and ⇥'s long-press outdent ride
    /// the same real buttons they always did.
    private func formattingStripItem(face: MobileEditorStyle.Face) -> UIBarButtonItem {
        func stripButton(
            _ title: String, _ label: String, _ selector: Selector
        ) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = face.chrome
            button.setTitleColor(face.muted, for: .normal)
            button.accessibilityLabel = label
            button.addTarget(self, action: selector, for: .touchUpInside)
            return button
        }

        let buttons: [UIButton] = [
            stripButton("×", "Hide Formatting", #selector(toggleFormattingDoor)),
            stripButton("B", "Bold", #selector(fireBold)),
            stripButton("I", "Italic", #selector(fireItalic)),
            headingButton(face: face),
            stripButton("•", "Bullet List", #selector(fireBullet)),
            stripButton("☑", "Checklist", #selector(fireChecklist)),
            indentButton(face: face),
        ]
        for button in buttons {
            button.widthAnchor.constraint(
                greaterThanOrEqualToConstant: Self.stripButtonMinWidth
            ).isActive = true
            button.heightAnchor.constraint(
                equalToConstant: Self.stripButtonHeight
            ).isActive = true
        }
        let strip = UIStackView(arrangedSubviews: buttons)
        strip.axis = .horizontal
        strip.alignment = .center
        strip.spacing = Self.stripSpacing
        strip.accessibilityIdentifier = "kbar.formattingStrip"
        let size = strip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        strip.frame = CGRect(origin: .zero, size: size)
        return UIBarButtonItem(customView: strip)
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
    /// open so the register follows a voice flip. (Since FIX-5 the
    /// button rides the one-cell strip rather than its own bar item;
    /// the wiring is byte-identical.)
    private func headingButton(face: MobileEditorStyle.Face) -> UIButton {
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
        return button
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
    /// can't carry one — so it has always been a real button. (Since
    /// FIX-5 it rides the one-cell strip; the wiring is byte-identical.)
    private func indentButton(face: MobileEditorStyle.Face) -> UIButton {
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
        return button
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
