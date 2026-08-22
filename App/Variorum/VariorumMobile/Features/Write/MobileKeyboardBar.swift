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
//  ⇥ carries BOTH directions (batch 2 — the software keyboard has no Tab
//  key at all, so the bar's ⇥ IS the phone's Tab): tap = indent,
//  long-press = outdent. Hardware Tab/⇧Tab ride the text view's key
//  commands; ⏎-on-an-empty-nested-item outdents too (K8's rule).
//
//  **⇤ IS ITS OWN VISIBLE DOOR since round 2 (M26 ≡ R21 — HER RULING:
//  *"i think an indent to the left button should be added to the set of
//  formatting buttons though - there's an indent in but not an
//  un-indent"*).** The batch-2 PROVISIONAL ("⇥ carries both directions")
//  is SUPERSEDED as the *only* visible door: outdent existed, was tested,
//  was documented — and the door did not reach her, because a long-press
//  is invisible and a VoiceOver hint is not an affordance for sighted
//  use. The long-press STAYS (four doors cost nothing and break no
//  muscle memory) and the ACT is byte-unchanged — `MarkdownEditing`'s
//  `.outdent`, the one shared brain, fired by the same `fireOutdent`.
//  **A DOOR change, never vocabulary.**
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
    /// amputate both ruled long-press doors).
    ///
    /// **Since round 2 the strip is ONE ROW of ELEVEN acts — × · B · I ·
    /// S · ⟨⟩ · 🔗 · # · • · ☑ · ⇥ · ⇤ (HER R22 + M26).** It was two
    /// rows from parity C4b until she ruled the one-row shape: *"agree:
    /// option 1 (one-row strip) is clearly better."* What the shape buys
    /// is VERTICAL and it is the whole point — a one-row capsule is
    /// 48 pt deep instead of 68 (see `expandedCapsuleBottomEdge`), so the
    /// resting trio and the expanded capsule now bottom out at the SAME
    /// depth, the 20 pt structural floor documented below **disappears
    /// by construction**, the bar drops 72 → 52 pt, and she gains those
    /// 20 pt back as text. The reading order is the two rows flattened
    /// unchanged, so LK8's relative order of the standing seven and
    /// C4b's after-Italic placement of strike/code/link both survive
    /// untouched, and ⇤ lands beside the ⇥ it mirrors.
    /// `formattingRowLabels` below is still the row split's truth (one
    /// row today; the machinery re-splits with no second edit). The
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

    /// The strip's geometry constants (pinned). The gap stays tight so
    /// the acts read as one strip.
    static let stripButtonHeight: CGFloat = 38
    static let stripSpacing: CGFloat = 2

    // MARK: - The strip's HORIZONTAL geometry (round 2 — R22 + M26)

    /// **THE 44 pt TAP-TARGET FLOOR IS GONE, and this is what it cost.**
    /// It used to be a hard constant here, with the doc comment "a 44 pt
    /// floor keeps every act a full HIG tap target". Two of her rulings
    /// arrived together and neither can hold it:
    ///
    /// - **R22** — the expanded strip becomes ONE row (the vertical win
    ///   documented on `isFormattingExpanded`), so all the acts must
    ///   share one line rather than two.
    /// - **M26 ≡ R21** — a visible ⇤ joins them, making **eleven**.
    ///
    /// Eleven 44 pt targets need 11×44 + 10×2 = **504 pt**; the tightest
    /// supported iPhone class offers **333** (below). The arithmetic is
    /// not close, and **she ruled the shape knowing it** — she was told
    /// before choosing that eleven acts land near 31 pt, under the
    /// floor. The built number is **28**, not 31, because the strip is
    /// sized to the TIGHTEST class rather than to the bar it happens to
    /// be in (FIX-5's rule, below): a 402 pt phone would allow 31, and
    /// spending FIX-5's construction-time safety to buy 3 pt was not a
    /// trade worth making without her. Recorded plainly rather than
    /// quietly deleted: the floor did not stop applying, it stopped
    /// being satisfiable, and the honest guard is the crowding tripwire
    /// below. **Measured on the live surface** (iPhone 17 Pro / iOS
    /// 26.2): a 30.0 pt act-to-act pitch, every act whole, and a tap at
    /// each act's centre fires that act.
    ///
    /// Note the buttons were never a full target VERTICALLY either —
    /// `stripButtonHeight` has been 38 pt since the strip existed.
    ///
    /// The tightest supported iPhone class's bar width (the SE class;
    /// iOS 26 still runs on 375 pt-wide hardware). FIX-5's rule is that
    /// the strip's intrinsic width fits the TIGHTEST class, so overflow
    /// is impossible on any device by construction — never a scroll,
    /// never a clip.
    static let tightestBarWidth: CGFloat = 375
    /// The iOS 26 toolbar insets its content row by this much per side
    /// (measured — FIX-5's probe).
    static let toolbarContentInset: CGFloat = 16
    /// What the customView's glass cell actually offers inside the
    /// tightest bar: 375 − 2×16 − 2×5 = **333 pt**.
    static var tightestStripWidth: CGFloat {
        tightestBarWidth - 2 * toolbarContentInset - 2 * stripCellInset
    }

    /// **Each act's width is DERIVED from the act count**, not chosen:
    /// the eleven acts and their ten 2 pt gaps divide the 333 pt the
    /// tightest class offers, rounded down. Today that is **28 pt**
    /// (11×28 + 10×2 = 328, five to spare).
    ///
    /// Deriving it is what keeps FIX-5's promise honest as the act list
    /// moves: a twelfth act narrows the row instead of overflowing the
    /// bar, and the tripwire below is what makes that narrowing loud
    /// instead of silent.
    ///
    /// **It is an EXACT width, not a minimum, and that is a measured
    /// correction rather than a preference.** The constraint used to be
    /// `>=` — harmless while the number was 44, because nothing here is
    /// that wide. At 28 it stopped working: a titled `UIButton(type:
    /// .system)` reports an intrinsic width of **30 pt** whatever its
    /// glyph (UIKit's own floor — measured: every titled act said 30.0
    /// while the image-titled 🔗 said 22.3), so ten acts ignored the
    /// minimum and the strip measured **348 pt against the 333 it must
    /// fit**. `>=` also could never have caught it in the other
    /// direction, which is why the pin now asserts the exact width.
    static var stripButtonWidth: CGFloat {
        let count = CGFloat(formattingActLabels.count)
        guard count > 0 else { return 0 }
        return ((tightestStripWidth - (count - 1) * stripSpacing) / count)
            .rounded(.down)
    }

    /// **The crowding tripwire — the 44 pt floor's replacement, and NOT
    /// a weakening of it.** The old constant asserted a HIG target her
    /// ruling made unreachable; this one asserts that nothing may crowd
    /// the strip FURTHER without her. Eleven acts sit exactly at it; a
    /// twelfth would compute 25 pt and trip the pin, which is the point
    /// — the next act to want a place on this row costs a ruling, not a
    /// constant edit.
    static let stripButtonCrowdingFloor: CGFloat = 28

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
    /// **THE 20 pt STRUCTURAL FLOOR IS GONE — she took the road that
    /// dissolves it (R22).** While the strip was TWO rows, the resting
    /// cells ran to 48 pt below the bar's top but the capsule's 88 pt
    /// cell, CENTERED on the fixed 48 pt content row, reached 68 — so
    /// the trio inherited the capsule's depth and could never sit
    /// closer than 20 pt + air without hiding the strip's second row.
    /// One height must serve both states (M17: an installed
    /// `inputAccessoryView` keeps its presented height), and
    /// repositioning inside a taller container never escaped it — the
    /// 20 pt rode the content row, not the bar. Two roads were put to
    /// her, both LOOK changes and therefore hers: a shorter expanded
    /// capsule, or a resting trio as tall as the capsule. **She ruled
    /// the first.** A one-row strip is 38 pt, its cell 48 — exactly a
    /// plain item's — so `expandedCapsuleBottomEdge == itemCellHeight`
    /// and the two states now bottom out at the SAME depth. The floor
    /// did not shrink; it stopped existing. Measured consequence: her
    /// three circles clear the keyboard by **5.33 pt** (the clearance
    /// she already accepted for the expanded state at R12), and the bar
    /// itself drops 72 → 52, handing 20 pt back to the text.
    ///
    /// The air stays **4** — untouched by the shape change, and still
    /// the photographed value.
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

    /// **72 → 52 at her R22 ruling.** The strip grew ROWS at parity C4b
    /// (strikethrough · inline code · add link joined the capsule) —
    /// ten 44 pt acts could not share one line of any iPhone class, so
    /// the capsule went two rows deep and dragged the whole bar down
    /// with it. R22 reverses that trade: the acts share ONE row (paid
    /// for horizontally — see `stripButtonWidth`, where the 44 pt
    /// target floor is spent), the capsule is a plain item's depth, and
    /// `lowestCellEdge` falls 68 → 48. The bar does NOT change height
    /// between the states — one `barHeight` hosts both, sized for the
    /// lowest cell plus air (M4 ≡ R7; the vertical-geometry block above
    /// carries the measured mechanism and why the old grow-on-expand
    /// road was retired). The resting bar stays Aa · ⑂ · ⋯,
    /// byte-untouched in its DOORS.
    static var barHeight: CGFloat { lowestCellEdge + barVerticalAir }

    /// The two states' acts, in bar order — one table per state so the
    /// bar and any test walk read the same truth (the registry-walk
    /// spirit). ⑂ = Takes (S2 batch 2); ⋯ = Block (S4 batch 1, with its
    /// block menu); Aa/× = the formatting door's two faces. The
    /// formatting labels read in STRIP ORDER (`formattingRowLabels`
    /// carries the row split — ONE row since R22, the two former rows
    /// flattened in place so LK8's relative order and C4b's
    /// after-Italic placement both survive); every act wears the
    /// capability registry's own verb, ⇤'s "Outdent" included.
    static let restingActLabels = ["Formatting", "Takes", "Block"]
    static let formattingRowLabels: [[String]] = [
        ["Hide Formatting", "Bold", "Italic", "Strikethrough", "Inline Code",
         "Add Link", "Heading", "Bullet List", "Checklist", "Indent",
         "Outdent"],
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
    /// and the visibility pin holdable windowless), a ONE-ROW capsule
    /// since her R22 (`kbar.formattingStrip`; the class doc above has
    /// the arithmetic): × · B · I · S · ⟨⟩ · 🔗 · # · • · ☑ · ⇥ · ⇤.
    /// Each button keeps its exact selector, label, and second gesture —
    /// the # picker and ⇥'s long-press outdent ride the same real
    /// buttons they always did; the C4b arrivals fire the SAME shared
    /// brain acts the Mac's Format menu fires (.strikethrough · .code ·
    /// .link — MarkdownSurfaceDoors, one computation both platforms),
    /// and M26's ⇤ fires the SAME `.outdent` the long-press always did.
    /// The `rows` table stays nested although it holds one row: it is
    /// `stripFittedHeight`'s source, so a future re-split grows the bar
    /// with no second edit.
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
                headingButton(face: face),
                stripButton("•", "Bullet List", #selector(fireBullet)),
                stripButton("☑", "Checklist", #selector(fireChecklist)),
                indentButton(face: face),
                outdentButton(face: face),
            ],
        ]
        for button in rows.flatMap(\.self) {
            // EXACT, not `>=` — UIKit floors a titled system button's
            // intrinsic width at 30 pt regardless of its glyph, so a
            // minimum below 30 is silently ignored (see
            // `stripButtonWidth`). Each act gets precisely its share.
            button.widthAnchor.constraint(
                equalToConstant: Self.stripButtonWidth
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
    /// The long-press SURVIVES M26's visible ⇤ — she has muscle memory
    /// on nothing here, but a door that already works is never removed
    /// to make room for a second one, and the hint stays honest.
    private func indentButton(face: MobileEditorStyle.Face) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⇥", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Indent"
        button.accessibilityHint = "Long-press to outdent"
        button.accessibilityIdentifier = "kbar.indent"
        button.addTarget(self, action: #selector(fireIndent), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(
            target: self, action: #selector(fireOutdentLongPress(_:)))
        button.addGestureRecognizer(longPress)
        return button
    }

    /// **⇤ — M26 ≡ R21's visible un-indent, her ruled door.** The act is
    /// the one it always was (`MarkdownEditing.outdent`, the shared
    /// brain); what changed is that it is now VISIBLE. Its glyph mirrors
    /// ⇥ and it sits immediately beside it, so the pair reads as a pair.
    /// The hint names the other door rather than a gesture on this one —
    /// this button needs no long-press, and saying so is what keeps the
    /// long-press discoverable to VoiceOver at all.
    private func outdentButton(face: MobileEditorStyle.Face) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("⇤", for: .normal)
        button.titleLabel?.font = face.chrome
        button.setTitleColor(face.muted, for: .normal)
        button.accessibilityLabel = "Outdent"
        button.accessibilityHint = "Moves the line out one level"
        button.accessibilityIdentifier = "kbar.outdent"
        button.addTarget(self, action: #selector(fireOutdent), for: .touchUpInside)
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

    /// ⇤'s tap and ⇥'s long-press are the SAME act through the SAME
    /// brain — two doors, one computation (M26 is a door change).
    @objc func fireOutdent() { fire(.outdent) }

    @objc func fireOutdentLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        fireOutdent()
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
