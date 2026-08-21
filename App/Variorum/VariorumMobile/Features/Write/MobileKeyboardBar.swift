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
    /// FORMATTING STRIP in place (× collapses back). A DOOR change, not
    /// a vocabulary change: the act grammar, the # cycle + P5
    /// long-press picker, and ⇥'s two directions are byte-identical —
    /// which is exactly why the door is a button strip and never a
    /// UIMenu (menu rows carry no second gesture; a menu-form Aa would
    /// amputate both ruled long-press doors). Since parity C4b the strip
    /// is TWO ROWS inside the one capsule — **× · B · I · S · ⟨⟩ ·
    /// link**, then **# · • · ☑ · ⇥** (the strike/code/link doors
    /// joined the grammar; the standing seven keep their LK8 relative
    /// order; `formattingRowLabels` below is the split's truth). The
    /// bar is the `inputAccessoryView`, so expand/collapse happens with
    /// the keyboard up, in place; the strip RESETS TO COLLAPSED at each
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
    /// every act a full HIG tap target; the gap stays tight so the acts
    /// read as one strip and each row keeps headroom on every supported
    /// width.
    static let stripButtonMinWidth: CGFloat = 44
    static let stripButtonHeight: CGFloat = 38
    static let stripSpacing: CGFloat = 2

    // MARK: - The bar's VERTICAL geometry (round 2, batch 2 — M4 ≡ R7)

    /// **HER COMPLAINT, verbatim: *"the buttons at the bottom, the three
    /// of them, also need more generous spacing because they're kind of
    /// touching the keyboard bar, which is annoying."*** Confirmed the
    /// same sitting as the resting trio Aa · ⑂ · ⋯.
    ///
    /// **THE MECHANISM — measured twice, never guessed** (a windowed frame
    /// dump of the live toolbar, plus live-simulator captures on
    /// iPhone 17 Pro / iOS 26.2 via `xcrun simctl io booted screenshot`;
    /// evidence in the batch record):
    ///
    /// 1. **The toolbar's content row is a FIXED 48 pt, anchored at the
    ///    bar's TOP** — `_UIInheritedView frame=(16, 0, 370, 48)` at a
    ///    78 pt bar AND at a 104 pt bar. It does NOT follow the bar's
    ///    height.
    /// 2. **iOS 26 wraps each item in a glass cell laid out against that
    ///    48 pt row.** A plain item's cell measures **62 × 48 at y = 0**
    ///    (`UIPlatformGlassInteractionView`; 52 pt button + the 5 pt
    ///    inset a side — FIX-5's own horizontal numbers, now with their
    ///    vertical twin), so it runs to **48 pt below the bar's top**.
    ///    The expanded strip's cell is **284 × 88 at y = −20** — the
    ///    capsule is CENTERED on the 48 pt row, so it overhangs 20 pt
    ///    above and runs to **68 pt below the bar's top**.
    /// 3. Against the old **44 pt** resting bar the resting cells
    ///    overflowed 4 pt and the expanded capsule overflowed 24 pt —
    ///    and the keyboard draws over the overflow. That is exactly what
    ///    she saw: three circles with sliced bottoms sitting ON the
    ///    keyboard, and (worse, unreported) the formatting strip's whole
    ///    SECOND ROW — # · • · ☑ · ⇥ — half-hidden behind it.
    ///
    /// **ONE height, because the second one never reached the screen.**
    /// The bar used to carry `restingBarHeight` 44 / `expandedBarHeight`
    /// 84 and grow on expand by setting its own frame + `reloadInputViews`.
    /// That mechanism is DEAD and was proven so: with the expanded height
    /// set to **160 pt** the captured screen was pixel-for-pixel the 104 pt
    /// capture (capsule top 436.7 pt, bottom 528.3 pt, keyboard top
    /// 537.7 pt in both) — UIKit keeps an installed `inputAccessoryView`
    /// at the height it had when the keyboard presented it, and the strip
    /// resets to collapsed at every keyboard hide, so **the resting height
    /// is the only height the screen ever sees**. The old expanded pin was
    /// green over wiring that never reached a pixel — this round's own
    /// §15 trap 1. So the grow-on-expand road is retired and ONE
    /// `barHeight` serves both states, sized for the TALLER of the two
    /// cells plus air.
    ///
    /// Why the trio is not folded into one customView capsule (the FIX-5
    /// mechanism) instead: that would replace three separate circles with
    /// one capsule — a LOOK change, and the look is hers to rule. A
    /// spacing complaint is answered by spacing.
    ///
    /// **If a future iOS lays these cells out differently, re-measure**:
    /// host `makeBar()` in a `UIWindow`, dump the subview frames, and
    /// re-derive — the numbers below are observations, not contracts.
    static let contentRowHeight: CGFloat = 48
    /// A plain bar item's glass cell: 62 × 48 at y = 0 of the content row.
    static let itemCellHeight: CGFloat = 48
    /// The glass cell's inset around a customView item, per side.
    static let stripCellInset: CGFloat = 5
    /// The air below the lowest cell edge.
    ///
    /// **HER CORRECTION (round 2, §29's R12), verbatim: *"it looks like
    /// the circles are now floating slightly high above the keyboard. i
    /// think the goal should just be for them to not be cut off but
    /// only be a bit above the [keyboard]."*** The first pass's 10 pt
    /// overshot; this is 4 pt, **arrived at by capture, not by
    /// formula** — three builds photographed on iPhone 17 Pro / iOS
    /// 26.2 and compared (captures in
    /// `notes/plans/mobile-round-2-screens/r12/`):
    ///
    /// | air | bar | resting circles clear the keyboard by | expanded capsule clears by |
    /// |----:|----:|--------------------------------------:|---------------------------:|
    /// |  10 |  78 |                              31.3 pt |                    11.3 pt |
    /// |   4 |  72 |                              25.3 pt |                     5.3 pt |
    /// |   2 |  70 |                              23.3 pt |                     3.3 pt |
    ///
    /// 2 pt was **rejected**: it buys 2 pt on the resting trio — below
    /// perception — and spends it making the EXPANDED capsule graze the
    /// keyboard, which is her original complaint wearing the other
    /// state's clothes.
    ///
    /// **THE FLOOR IS STRUCTURAL, AND IT IS 20 pt + this air.** The
    /// resting cells run to 48 pt below the bar's top; the two-row
    /// capsule runs to 68 pt (its 88 pt cell is CENTERED on the fixed
    /// 48 pt content row, so it always hangs exactly 20 pt lower than a
    /// resting cell). One bar height must serve both states (M17: an
    /// installed `inputAccessoryView` keeps its presented height), so
    /// the trio can never sit closer than 20 pt + air without hiding
    /// the strip's second row. Repositioning the toolbar inside a taller
    /// container does NOT escape it — the 20 pt rides the row, not the
    /// bar. Getting the circles genuinely close needs one of two things,
    /// **both of which change the LOOK and are therefore hers to rule**:
    /// a shorter expanded capsule (one row, or shorter rows), or a
    /// resting trio whose own cells are as tall as the capsule.
    static let barVerticalAir: CGFloat = 4

    /// The expanded capsule's intrinsic height, DERIVED from the row
    /// table below (a future row grows the bar with no second edit).
    static var stripFittedHeight: CGFloat {
        let rows = CGFloat(formattingRowLabels.count)
        return rows * stripButtonHeight + max(rows - 1, 0) * stripSpacing
    }

    /// How far the expanded capsule reaches below the bar's top edge:
    /// the capsule is centered on the 48 pt content row (measured
    /// y = −20 for an 88 pt capsule), so its bottom sits at
    /// `(row + capsule) / 2`.
    static var expandedCapsuleBottomEdge: CGFloat {
        (contentRowHeight + stripFittedHeight + 2 * stripCellInset) / 2
    }

    /// The lowest edge any state draws — the number the bar must clear.
    static var lowestCellEdge: CGFloat {
        max(itemCellHeight, expandedCapsuleBottomEdge)
    }

    /// **The strip grew ROWS at parity C4b item 2** (the markdown
    /// vocabulary's remaining acts — strikethrough · inline code · add
    /// link — join the strip INSIDE its capsule, per the brief's LK8
    /// answer): ten 44 pt acts cannot sit on one line of any iPhone
    /// class (10×44 + 9×2 = 458 pt against the tightest cell's 333), so
    /// the capsule holds TWO rows — the character acts (× B I S ⟨⟩ 🔗),
    /// then the line acts (# • ☑ ⇥) — the standing seven keeping their
    /// LK8 relative order and the three new acts landing exactly where
    /// the Mac's act table puts them (after Italic). The bar does NOT
    /// change height between the states — one `barHeight` hosts both,
    /// sized for the taller cell plus air (M4 ≡ R7; the vertical-geometry
    /// block above carries the measured mechanism and why the old
    /// grow-on-expand road was retired). The resting bar stays
    /// Aa · ⑂ · ⋯, byte-untouched in its DOORS.
    static var barHeight: CGFloat { lowestCellEdge + barVerticalAir }

    /// The two states' acts, in bar order — one table per state so the
    /// bar and any test walk read the same truth (the registry-walk
    /// spirit). ⑂ = Takes (S2 batch 2); ⋯ = Block (S4 batch 1, with its
    /// block menu); Aa/× = the formatting door's two faces. The
    /// formatting labels read in STRIP READING ORDER (row 1, then row
    /// 2 — `formattingRowLabels` carries the split); the three C4b
    /// arrivals wear the registry's own verbs.
    static let restingActLabels = ["Formatting", "Takes", "Block"]
    static let formattingRowLabels: [[String]] = [
        ["Hide Formatting", "Bold", "Italic", "Strikethrough", "Inline Code",
         "Add Link"],
        ["Heading", "Bullet List", "Checklist", "Indent"],
    ]
    static var formattingActLabels: [String] { formattingRowLabels.flatMap(\.self) }

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
        let bar = UIToolbar(frame: CGRect(
            x: 0, y: 0, width: 320, height: Self.barHeight))
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

    /// The expanded formatting strip — ONE customView item (the FIX-5
    /// mechanism: owning the geometry is what makes overflow impossible
    /// and the visibility pin holdable windowless), now a TWO-ROW
    /// capsule (`kbar.formattingStrip`, parity C4b item 2 — the class
    /// doc above has the arithmetic): the character acts
    /// × · B · I · S · ⟨⟩ · link, then the line acts # · • · ☑ · ⇥.
    /// Each button keeps its exact selector, label, and second gesture —
    /// the # picker and ⇥'s long-press outdent ride the same real
    /// buttons they always did; the three arrivals fire the SAME shared
    /// brain acts the Mac's Format menu fires (.strikethrough · .code ·
    /// .link — MarkdownSurfaceDoors, one computation both platforms).
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
        /// The strike act's glyph is a struck-through S — the act shown
        /// by wearing it (the checklist's ☑ precedent).
        func strikeButton() -> UIButton {
            let button = UIButton(type: .system)
            button.setAttributedTitle(
                NSAttributedString(string: "S", attributes: [
                    .font: face.chrome, .foregroundColor: face.muted,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                ]), for: .normal)
            button.accessibilityLabel = "Strikethrough"
            button.addTarget(self, action: #selector(fireStrikethrough), for: .touchUpInside)
            return button
        }
        /// The link act wears the platform's own link glyph (the seal
        /// door's SF precedent; symbols tint with the voice ink exactly
        /// as titles do).
        func linkButton() -> UIButton {
            let button = UIButton(type: .system)
            button.setImage(UIImage(
                systemName: "link",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: face.chrome.pointSize, weight: .regular)), for: .normal)
            button.tintColor = face.muted
            button.accessibilityLabel = "Add Link"
            button.addTarget(self, action: #selector(fireLink), for: .touchUpInside)
            return button
        }

        let rows: [[UIButton]] = [
            [
                stripButton("×", "Hide Formatting", #selector(toggleFormattingDoor)),
                stripButton("B", "Bold", #selector(fireBold)),
                stripButton("I", "Italic", #selector(fireItalic)),
                strikeButton(),
                stripButton("⟨⟩", "Inline Code", #selector(fireCode)),
                linkButton(),
            ],
            [
                headingButton(face: face),
                stripButton("•", "Bullet List", #selector(fireBullet)),
                stripButton("☑", "Checklist", #selector(fireChecklist)),
                indentButton(face: face),
            ],
        ]
        for button in rows.flatMap(\.self) {
            button.widthAnchor.constraint(
                greaterThanOrEqualToConstant: Self.stripButtonMinWidth
            ).isActive = true
            button.heightAnchor.constraint(
                equalToConstant: Self.stripButtonHeight
            ).isActive = true
        }
        let rowStacks = rows.map { buttons -> UIStackView in
            let row = UIStackView(arrangedSubviews: buttons)
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = Self.stripSpacing
            return row
        }
        let strip = UIStackView(arrangedSubviews: rowStacks)
        strip.axis = .vertical
        strip.alignment = .center
        strip.spacing = Self.stripSpacing
        strip.accessibilityIdentifier = "kbar.formattingStrip"
        let size = strip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        strip.frame = CGRect(origin: .zero, size: size)
        return UIBarButtonItem(customView: strip)
    }

    /// Aa opens the strip; × closes it — one door, two faces, swapping
    /// the LIVE bar's items in place. The bar's HEIGHT does not move with
    /// the state (M4 ≡ R7 — the geometry block's proven finding: an
    /// installed `inputAccessoryView` keeps the height it was presented
    /// at, so the old grow-on-expand road changed a frame and never a
    /// pixel). `barHeight` already clears the two-row capsule, so the
    /// swap is items only — and the keyboard never jumps.
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
    /// The C4b arrivals — the same shared-brain acts the Mac menu fires.
    @objc func fireStrikethrough() { fire(.strikethrough) }
    @objc func fireCode() { fire(.code) }
    @objc func fireLink() { fire(.link) }
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
