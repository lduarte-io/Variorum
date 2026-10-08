//
//  MobileTakesBrowserView.swift
//  VariorumMobile
//
//  Mobile Stage 2, batch 2 — the takes browser's PIXELS: the RATIFIED
//  sheet-over-page (LK4, mockup v1 §3's literal geometry — the sheet
//  rides over the dimmed page in the SAME screen, never a separate one;
//  an overlay view, not a modal presentation, so the page stays visibly
//  behind and the house harness drives it headlessly. The presentation
//  MECHANISM is an interpretation recorded for the ladder; the drawn
//  shape is hers).
//
//  The grammar, from the mockup: dim over the page → the sheet from
//  ~120 pt down, rounded top corners → the shead ("takes · block k of n"
//  · done) → take cards in fan order (meta row: ✓ chosen state / peeking
//  / take N · label · ✓ door · ⋯ menu; body text below) → the footer
//  new-take row (+ new take · branch this one ⧉ · blank ○). Terminal
//  lowercases its chrome; study keeps case (the voice rule) — every
//  color/font resolves from `MobileEditorStyle.face` (P-8, the S1 flag-6
//  duty).
//
//  P3 IN THE SHEET: cards render read-cheap (labels); a tapped card
//  upgrades to THE one live editor — a single reused `UITextView`
//  (`cardEditor`) that moves between cards. While the browser is open the
//  in-page editor STANDS DOWN (isEditable = false, first responder
//  resigned) — the stricter reading of "the in-page editor stands down
//  while a card is live": the sheet covers the page, and a live-but-
//  covered page editor would be a second liveness ambiguity (recorded).
//
//  The card editor is a PLAIN UITextView, deliberately: one take's text,
//  no block index, no separators — the page's TK2-explicit construction
//  and canary guard the CONTINUOUS surface (P1's mechanism); a one-take
//  card is the pane class (recorded for the ladder).
//

import UIKit
import VariorumCore

@MainActor
final class MobileTakesBrowserView: UIView {
    private weak var pageTextView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// The sheet's top edge (the mockup's 120 px) — PROVISIONAL visual
    /// constant like every other; the look rounds rule.
    static let sheetTop: CGFloat = 120

    private let dimView = UIView()
    private let sheetView = UIView()
    private let headerLabel = UILabel()
    private let doneButton = UIButton(type: .custom)
    private let cardsScroll = UIScrollView()
    private let footerLabel = UILabel()
    private let branchButton = UIButton(type: .custom)
    private let blankButton = UIButton(type: .custom)
    /// **BATCH 7 — the sheet's ACTIONS ROW** (PL-10(d), E6b's one door).
    /// A block-scoped act among take-scoped ones, so it gets its own line
    /// above the mint footer rather than a fourth word crowding it, and it
    /// renders ONLY while a fan exists (P-2: `canTurnTakesIntoBlocks`) — so
    /// the calm one-take sheet is byte-identical to the one that shipped and
    /// gives up no card height. PROVISIONAL placement, recorded.
    private let takesToBlocksButton = UIButton(type: .custom)

    /// THE one live card editor (P3): a single instance that moves onto
    /// whichever card is being edited.
    let cardEditor = UITextView()

    /// Whether the page editor was editable before the sheet stood it
    /// down (restored at close).
    private var pageWasEditable = true
    private(set) var cardViews: [String: MobileTakesCardView] = [:]
    /// The archived section (parity C4a — see-your-data): a small header
    /// + read-only cards below the live fan, inside the same scroll.
    private let archivedHeader = UILabel()
    private(set) var archivedCardViews: [String: MobileArchivedTakeCardView] = [:]

    /// The keyboard's current end frame (screen coordinates; nil = no
    /// keyboard). THE GATE DEFECT (parity round Stage A, batch A1 — her
    /// report: "i could make a new take but i couldn't scroll down through
    /// the list of takes to edit it better"): this sheet was laid out
    /// keyboard-blind — full-bounds manual frames, zero insets — so the
    /// moment minting raised focus (the S2 MINOR-2 fix), the card list's
    /// max scroll offset ignored the occluded band (with few takes it is
    /// exactly ZERO — the list cannot scroll at all), the minted card (the
    /// fan's end) sat behind the keyboard, and the new-take footer
    /// vanished. The sheet is manual-frames over the page, so keyboard
    /// geometry arrives by the system notifications (the surface
    /// container's `keyboardLayoutGuide` is a constraint mechanism;
    /// nothing here is constraint-laid) — and tests post the same
    /// notifications deterministically.
    private var keyboardEndFrame: CGRect?
    /// Written once in init, read in deinit for removal — the
    /// `nonisolated(unsafe)` is exactly that write-once shape.
    private nonisolated(unsafe) var keyboardObservers: [NSObjectProtocol] = []
    /// The take whose live card was last REVEALED (scrolled into the
    /// unoccluded band) — one reveal per editing transition or keyboard
    /// move, never per render, so her own scrolling is not fought.
    private var lastRevealedEditingVariantID: String?

    /// **True while THIS view is moving the one card editor between cards
    /// (or tearing it down).** A resign inside that window is the app's own
    /// doing and must never be read as "she stopped writing": the model's
    /// live take is already correct, and re-deciding it from the responder
    /// would cancel the very card the transition is installing (tapping
    /// card B while A is live removes the shared editor from A first, which
    /// resigns it). Only a resign this flag is DOWN for came from her.
    private var isRehostingCardEditor = false

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.pageTextView = textView
        self.model = model
        super.init(frame: .zero)
        isHidden = true
        accessibilityIdentifier = "takes.browser"

        dimView.accessibilityIdentifier = "takes.browser.dim"
        addSubview(dimView)

        sheetView.layer.cornerRadius = 22
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.accessibilityIdentifier = "takes.browser.sheet"
        addSubview(sheetView)

        headerLabel.accessibilityIdentifier = "takes.browser.header"
        sheetView.addSubview(headerLabel)

        doneButton.accessibilityIdentifier = "takes.browser.done"
        doneButton.accessibilityLabel = "Done"
        doneButton.addAction(
            UIAction { [weak self] _ in
                guard let self, let model = self.model else { return }
                Task { await model.takesBrowser.close() }
            }, for: .touchUpInside)
        sheetView.addSubview(doneButton)

        sheetView.addSubview(cardsScroll)

        archivedHeader.accessibilityIdentifier = "takes.browser.archivedHeader"
        archivedHeader.isHidden = true
        cardsScroll.addSubview(archivedHeader)

        footerLabel.accessibilityIdentifier = "takes.browser.newtake"
        branchButton.accessibilityIdentifier = "takes.browser.branch"
        branchButton.accessibilityLabel = "Branch this one"
        branchButton.addAction(
            UIAction { [weak self] _ in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.branchDisplayed() }
            }, for: .touchUpInside)
        blankButton.accessibilityIdentifier = "takes.browser.blank"
        blankButton.accessibilityLabel = "Blank take"
        blankButton.addAction(
            UIAction { [weak self] _ in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.newBlank() }
            }, for: .touchUpInside)
        takesToBlocksButton.accessibilityIdentifier = "takes.browser.takesToBlocks"
        takesToBlocksButton.accessibilityLabel =
            MobileTakesBrowserController.takesToBlocksTitle
        takesToBlocksButton.isHidden = true
        takesToBlocksButton.addAction(
            UIAction { [weak self] _ in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.takesToBlocks() }
            }, for: .touchUpInside)
        for view in [footerLabel, branchButton, blankButton, takesToBlocksButton] {
            sheetView.addSubview(view)
        }

        cardEditor.accessibilityIdentifier = "takes.browser.cardEditor"
        cardEditor.delegate = self
        cardEditor.isScrollEnabled = true

        // **THE WAY OUT OF A LIVE CARD** (the batch-7 fix wave, cold review
        // MAJOR 2). Before this, nothing a user could do ended a card's
        // live state except closing the whole sheet — so the actions row
        // that stands down while she types (below) had no road back, and
        // the rule it was justified by ("while a take is being written")
        // outlived the writing. This is iOS's own standard gesture, on the
        // scroll this sheet already owns: dragging the card list puts the
        // keyboard away, which resigns the card editor, which ends the live
        // card (`textViewDidEndEditing`) — and the row returns. Nothing is
        // invented and nothing is lost: every keystroke has already reached
        // the VM's ledger through `cardTextDidChange`.
        cardsScroll.keyboardDismissMode = .onDrag

        // A tap on the dimmed page margin closes too (the sheet-over-page
        // convention); the sheet itself swallows its touches.
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)

        // The keyboard joins the layout (batch A1 — see keyboardEndFrame).
        let center = NotificationCenter.default
        keyboardObservers = [
            center.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil, queue: .main
            ) { [weak self] note in
                let end = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
                    as? NSValue)?.cgRectValue
                MainActor.assumeIsolated { self?.keyboardMoved(to: end) }
            },
            center.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.keyboardMoved(to: nil) }
            },
        ]
    }

    deinit {
        for token in keyboardObservers {
            NotificationCenter.default.removeObserver(token)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    /// How far the keyboard intrudes into this view. Computed fresh per
    /// layout (the conversion depends on where the view sits). `from: nil`
    /// converts from window base coordinates; the app is portrait-locked
    /// iPhone (the platform ruling), so screen and window bases agree.
    private var keyboardOverlap: CGFloat {
        guard let keyboardEndFrame, window != nil else { return 0 }
        let local = convert(keyboardEndFrame, from: nil)
        return max(0, bounds.maxY - local.minY)
    }

    private func keyboardMoved(to endFrame: CGRect?) {
        guard keyboardEndFrame != endFrame else { return }
        keyboardEndFrame = endFrame
        guard !isHidden, superview != nil, let model else { return }
        // The live card re-reveals under the NEW geometry (on device the
        // keyboard's frame arrives a beat after the mint's transition).
        lastRevealedEditingVariantID = nil
        layoutChrome()
        renderCards(model.takesBrowser)
    }

    @objc private func dimTapped() {
        guard let model else { return }
        Task { await model.takesBrowser.close() }
    }

    // MARK: - Render (the controller's onChanged hook)

    func render() {
        guard let model else { return }
        let browser = model.takesBrowser
        let wasHidden = isHidden
        let open = browser.isOpen

        if open, superview == nil, let host = pageTextView?.superview {
            // Installed lazily over the page (the host is the keyboard-
            // avoiding surface container; the sheet covers it whole).
            frame = host.bounds
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            host.addSubview(self)
        }
        isHidden = !open

        // The page editor stands down while the sheet is up; restored at
        // close (the P3 one-live-pane rule).
        if let page = pageTextView {
            if open, wasHidden {
                pageWasEditable = page.isEditable
                page.isEditable = false
                _ = page.resignFirstResponder()
            } else if !open, !wasHidden {
                page.isEditable = pageWasEditable
            }
        }
        guard open else {
            detachCardEditor()
            for (_, card) in cardViews { card.removeFromSuperview() }
            cardViews = [:]
            for (_, card) in archivedCardViews { card.removeFromSuperview() }
            archivedCardViews = [:]
            archivedHeader.isHidden = true
            return
        }

        layoutChrome()
        renderCards(browser)
    }

    private func layoutChrome() {
        let face = MobileEditorStyle.face
        guard let model else { return }
        let browser = model.takesBrowser

        dimView.frame = bounds
        dimView.backgroundColor = face.ink.withAlphaComponent(0.25)
        sheetView.frame = CGRect(
            x: 0, y: Self.sheetTop,
            width: bounds.width, height: max(bounds.height - Self.sheetTop, 0))
        sheetView.backgroundColor = face.surface

        let chrome = face.chrome.withSize(13)
        if let (k, n) = browser.headerOrdinal() {
            headerLabel.text = chromeCase("Takes · block \(k) of \(n)")
        } else {
            headerLabel.text = chromeCase("Takes")
        }
        headerLabel.font = chrome
        headerLabel.textColor = face.muted
        headerLabel.sizeToFit()
        headerLabel.frame.origin = CGPoint(x: 20, y: 14)

        doneButton.setTitle(chromeCase("Done"), for: .normal)
        doneButton.setTitleColor(face.accent, for: .normal)
        doneButton.titleLabel?.font = face.chrome.withSize(12.5)
        doneButton.sizeToFit()
        doneButton.frame = CGRect(
            x: sheetView.bounds.width - doneButton.bounds.width - 20, y: 10,
            width: doneButton.bounds.width, height: 24)

        footerLabel.text = chromeCase("+ New take")
        footerLabel.font = chrome
        footerLabel.textColor = face.muted
        footerLabel.sizeToFit()
        branchButton.setTitle(chromeCase("Branch this one ⧉"), for: .normal)
        blankButton.setTitle(chromeCase("Blank ○"), for: .normal)
        for button in [branchButton, blankButton] {
            button.setTitleColor(face.accent, for: .normal)
            button.titleLabel?.font = chrome
            button.sizeToFit()
        }
        // THE KEYBOARD'S SHARE (batch A1, the gate defect): the footer and
        // the card list end ABOVE the keyboard — the sheet is bottom-
        // pinned, so the overlap subtracts directly from its usable
        // height. Without this the list's max scroll offset ignored the
        // occluded band entirely and the new-take doors sat behind the
        // keyboard. The clamp keeps the header row alive in degenerate
        // geometries.
        let footerY = max(sheetView.bounds.height - keyboardOverlap, 96) - 44
        footerLabel.frame.origin = CGPoint(x: 20, y: footerY + 6)
        branchButton.frame = CGRect(
            x: footerLabel.frame.maxX + 14, y: footerY,
            width: branchButton.bounds.width, height: 32)
        blankButton.frame = CGRect(
            x: branchButton.frame.maxX + 14, y: footerY,
            width: blankButton.bounds.width, height: 32)

        // BATCH 7's actions row, directly above the mint footer. Hidden —
        // and costing NO card height — whenever there is nothing to convert.
        //
        // **AND IT STANDS DOWN WHILE A CARD IS LIVE, which is a real rule
        // rather than a workaround, and it was caught by the A1 gate
        // defect's own pin** (`theKeyboardNeverStrandsTheCardListFooterOr
        // LiveCard`): with the keyboard up, the unoccluded band is barely
        // taller than one live card, so 30 pt spent on chrome left the live
        // card's top cut off — the exact class of her report *"i could make
        // a new take but i couldn't scroll down through the list of takes to
        // edit it better."* The mint footer stays because minting is the
        // ADJACENT act; converting the whole fan is not something she is
        // doing mid-keystroke. So while a take is being written, the sheet's
        // job is typing room, and this row's geometry is byte-identical to
        // the sheet that shipped.
        //
        // **AND THE ROW COMES BACK** (the fix wave, MAJOR 2): the rule reads
        // "while a take is being WRITTEN", and it now means that — putting
        // the keyboard away (dragging the card list, `.onDrag` in init) ends
        // the live card through `textViewDidEndEditing`, and this row
        // returns on the very next layout. Before that road existed the
        // condition outlived the writing and the only way back was to close
        // the sheet and reopen it.
        let showTakesToBlocks = browser.canTurnTakesIntoBlocks
            && browser.editingVariantID == nil
        takesToBlocksButton.isHidden = !showTakesToBlocks
        var listBottom = footerY - 8
        if showTakesToBlocks {
            takesToBlocksButton.setTitle(
                chromeCase(MobileTakesBrowserController.takesToBlocksTitle), for: .normal)
            takesToBlocksButton.setTitleColor(face.accent, for: .normal)
            takesToBlocksButton.titleLabel?.font = chrome
            takesToBlocksButton.sizeToFit()
            let actionsY = footerY - 30
            takesToBlocksButton.frame = CGRect(
                x: 20, y: actionsY,
                width: takesToBlocksButton.bounds.width, height: 26)
            listBottom = actionsY - 8
        }

        cardsScroll.frame = CGRect(
            x: 16, y: 44,
            width: sheetView.bounds.width - 32,
            height: max(listBottom - 44, 0))
    }

    private func renderCards(_ browser: MobileTakesBrowserController) {
        let face = MobileEditorStyle.face
        let cards = browser.cards()
        var seen: Set<String> = []
        var y: CGFloat = 0
        let width = cardsScroll.bounds.width

        for card in cards {
            seen.insert(card.variantID)
            let view = cardViews[card.variantID] ?? makeCard(variantID: card.variantID)
            let isLive = browser.editingVariantID == card.variantID
            view.apply(
                card: card, face: face, live: isLive,
                chromeCase: chromeCase(_:),
                canMoveUp: browser.canMoveTake(variantID: card.variantID, by: -1),
                canMoveDown: browser.canMoveTake(variantID: card.variantID, by: 1),
                fanned: cards.count > 1)
            if isLive {
                attachCardEditor(to: view, text: card.text, face: face)
            }
            let height = view.preferredHeight(width: width, live: isLive)
            view.frame = CGRect(x: 0, y: y, width: width, height: height)
            view.layoutContent()
            y += height + 10
        }
        for (variantID, view) in cardViews where !seen.contains(variantID) {
            if cardEditor.superview === view { detachCardEditor() }
            view.removeFromSuperview()
            cardViews[variantID] = nil
        }
        if let editing = browser.editingVariantID, !seen.contains(editing) {
            detachCardEditor()
        }
        if browser.editingVariantID == nil { detachCardEditor() }

        // The archived section (parity C4a): below the live fan, inside
        // the same scroll — "archived · n" then read-only cards whose ⋯
        // holds the road back (Unarchive) and Delete.
        let archivedCards = browser.archivedCards()
        var archivedSeen: Set<String> = []
        if archivedCards.isEmpty {
            archivedHeader.isHidden = true
        } else {
            archivedHeader.isHidden = false
            archivedHeader.text = chromeCase("Archived · \(archivedCards.count)")
            archivedHeader.font = face.chrome.withSize(12)
            archivedHeader.textColor = face.muted
            archivedHeader.sizeToFit()
            y += 6
            archivedHeader.frame.origin = CGPoint(x: 0, y: y)
            y += archivedHeader.bounds.height + 8
            for card in archivedCards {
                archivedSeen.insert(card.variantID)
                let view = archivedCardViews[card.variantID]
                    ?? makeArchivedCard(variantID: card.variantID)
                view.apply(card: card, face: face, chromeCase: chromeCase(_:))
                let height = view.preferredHeight(width: width)
                view.frame = CGRect(x: 0, y: y, width: width, height: height)
                view.layoutContent()
                y += height + 10
            }
        }
        for (variantID, view) in archivedCardViews where !archivedSeen.contains(variantID) {
            view.removeFromSuperview()
            archivedCardViews[variantID] = nil
        }

        cardsScroll.contentSize = CGSize(width: width, height: y)

        // The live card is REVEALED when editing begins or moves (batch
        // A1): the mint lands at the FAN'S END — exactly where the
        // keyboard hides it — so the transition scrolls it into the
        // unoccluded band. Once per transition (and once per keyboard
        // move, which resets the marker), never per render.
        if let editing = browser.editingVariantID {
            if editing != lastRevealedEditingVariantID, let live = cardViews[editing] {
                lastRevealedEditingVariantID = editing
                cardsScroll.scrollRectToVisible(
                    live.frame.insetBy(dx: 0, dy: -10), animated: false)
            }
        } else {
            lastRevealedEditingVariantID = nil
        }
    }

    private func makeCard(variantID: String) -> MobileTakesCardView {
        let view = MobileTakesCardView(
            variantID: variantID,
            onEdit: { [weak self] in self?.model?.takesBrowser.beginEditing(variantID: variantID) },
            onChoose: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.choose(variantID: variantID) }
            },
            onArchive: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.archive(variantID: variantID) }
            },
            onDelete: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.delete(variantID: variantID) }
            },
            onSetLocked: { [weak self] locked in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.setLocked(variantID: variantID, locked: locked) }
            },
            onLabel: { [weak self] in
                self?.model?.takesBrowser.requestLabel(variantID: variantID)
            },
            onHistory: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.openHistory(variantID: variantID) }
            },
            onMove: { [weak self] delta in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.moveTake(variantID: variantID, by: delta) }
            },
            onTakeToBlock: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.takeToBlockBelow(variantID: variantID) }
            })
        cardsScroll.addSubview(view)
        cardViews[variantID] = view
        return view
    }

    private func makeArchivedCard(variantID: String) -> MobileArchivedTakeCardView {
        let view = MobileArchivedTakeCardView(
            variantID: variantID,
            onUnarchive: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.unarchive(variantID: variantID) }
            },
            onDelete: { [weak self] in
                guard let model = self?.model else { return }
                Task { await model.takesBrowser.delete(variantID: variantID) }
            },
            onLabel: { [weak self] in
                self?.model?.takesBrowser.requestLabel(variantID: variantID)
            })
        cardsScroll.addSubview(view)
        archivedCardViews[variantID] = view
        return view
    }

    // MARK: - The one card editor

    private func attachCardEditor(to card: MobileTakesCardView, text: String, face: MobileEditorStyle.Face) {
        if cardEditor.superview !== card {
            // The rehost window: the removal below resigns the shared
            // editor, and that resign is OURS, not hers (see the flag).
            isRehostingCardEditor = true
            defer { isRehostingCardEditor = false }
            cardEditor.removeFromSuperview()
            card.hostEditor(cardEditor)
            cardEditor.text = text
            // Activation RAISES FOCUS (S2 ladder round 1, MINOR 2): "the
            // minted card goes live so she is typing instantly" needs the
            // keyboard, not just an editable editor — without this a
            // second tap was owed. Fires only on the attach transition
            // (this branch), never on the per-render restyle below.
            // Windowless (headless harness) it is a no-op returning
            // false — harmless.
            cardEditor.becomeFirstResponder()
        }
        cardEditor.font = face.body
        cardEditor.textColor = face.ink
        cardEditor.backgroundColor = .clear
        cardEditor.tintColor = face.accent
    }

    private func detachCardEditor() {
        guard cardEditor.superview != nil else { return }
        // Same window as the rehost: this teardown's resign is the app's.
        isRehostingCardEditor = true
        defer { isRehostingCardEditor = false }
        _ = cardEditor.resignFirstResponder()
        cardEditor.removeFromSuperview()
        cardEditor.text = ""
    }

    // MARK: - Voice casing (the terminal-lowercase chrome rule)

    /// The ONE UIKit register (P26/P43, parity A3 — this local helper
    /// used to carry its own copy of the rule; delegating kills the fork).
    private func chromeCase(_ text: String) -> String {
        MobileEditorStyle.chromeCase(text)
    }
}

// MARK: - The card editor's delegate (routes to the controller's gate)

extension MobileTakesBrowserView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        guard let model else { return false }
        return model.takesBrowser.cardGateAllows(range: range, replacement: text)
    }

    func textViewDidChange(_ textView: UITextView) {
        model?.takesBrowser.cardTextDidChange(textView.text ?? "")
    }

    /// **THE LIVE STATE FOLLOWS THE RESPONDER** (the fix wave, MAJOR 2).
    /// When she puts the keyboard away — the scroll's `.onDrag` dismissal
    /// above, the standard iOS road, and any other resign the app did not
    /// perform itself — the card stops being live, so the sheet's chrome
    /// (the actions row) comes back and its geometry returns to the calm
    /// one. Guarded by `isRehostingCardEditor` so the app's own moves of
    /// the one shared editor are never mistaken for hers.
    func textViewDidEndEditing(_ textView: UITextView) {
        guard !isRehostingCardEditor else { return }
        model?.takesBrowser.endEditing()
    }
}

// MARK: - One take card (the v2 card grammar's phone cousin)

@MainActor
final class MobileTakesCardView: UIView {
    let variantID: String
    private let stateLabel = UILabel()
    private let takeLabel = UILabel()
    private let chooseButton = UIButton(type: .custom)
    private let menuButton = UIButton(type: .custom)
    private let bodyLabel = UILabel()
    private let edgeBar = UIView()
    private var editorHost: UIView?
    private let onEdit: () -> Void
    private let onArchive: () -> Void
    private let onDelete: () -> Void
    private let onSetLocked: (Bool) -> Void
    private let onLabel: () -> Void
    private let onHistory: () -> Void
    private let onMove: (Int) -> Void
    private let onTakeToBlock: () -> Void

    /// The live editor's card height (functional; the look rounds rule).
    static let editorHeight: CGFloat = 120

    init(
        variantID: String,
        onEdit: @escaping () -> Void,
        onChoose: @escaping () -> Void,
        onArchive: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onSetLocked: @escaping (Bool) -> Void = { _ in },
        onLabel: @escaping () -> Void = {},
        onHistory: @escaping () -> Void = {},
        onMove: @escaping (Int) -> Void = { _ in },
        onTakeToBlock: @escaping () -> Void = {}
    ) {
        self.variantID = variantID
        self.onEdit = onEdit
        self.onArchive = onArchive
        self.onDelete = onDelete
        self.onSetLocked = onSetLocked
        self.onLabel = onLabel
        self.onHistory = onHistory
        self.onMove = onMove
        self.onTakeToBlock = onTakeToBlock
        super.init(frame: .zero)
        accessibilityIdentifier = "takes.card.\(variantID)"
        layer.cornerRadius = 10
        layer.borderWidth = 1

        edgeBar.isUserInteractionEnabled = false
        addSubview(edgeBar)

        stateLabel.accessibilityIdentifier = "takes.card.state"
        takeLabel.accessibilityIdentifier = "takes.card.label"
        bodyLabel.accessibilityIdentifier = "takes.card.body"
        bodyLabel.numberOfLines = 0

        chooseButton.setTitle("✓", for: .normal)
        chooseButton.accessibilityIdentifier = "takes.card.choose"
        chooseButton.accessibilityLabel = "Choose this take"
        chooseButton.addAction(UIAction { _ in onChoose() }, for: .touchUpInside)

        menuButton.setTitle("⋯", for: .normal)
        menuButton.accessibilityIdentifier = "takes.card.menu"
        menuButton.accessibilityLabel = "Take actions"
        menuButton.showsMenuAsPrimaryAction = true
        // The rows are built in `apply` (P26/P43, parity A3): titles are
        // VOICE-CASED, and apply re-runs per render, so a voice flip
        // reaches an already-built card's menu. P26's recorded
        // system-register posture is the flipped PROVISIONAL.

        for view in [stateLabel, takeLabel, chooseButton, menuButton, bodyLabel] {
            addSubview(view)
        }

        // Tapping the card's BODY upgrades it to the live editor (edit
        // any take — R8/R23); the meta row's doors keep their own acts.
        let tap = UITapGestureRecognizer(target: self, action: #selector(bodyTapped))
        bodyLabel.isUserInteractionEnabled = true
        bodyLabel.addGestureRecognizer(tap)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    @objc private func bodyTapped() { onEdit() }

    func apply(
        card: MobileTakesBrowserController.Card,
        face: MobileEditorStyle.Face,
        live: Bool,
        chromeCase: (String) -> String,
        canMoveUp: Bool = false,
        canMoveDown: Bool = false,
        fanned: Bool = false
    ) {
        backgroundColor = card.isPeeked ? face.takeTint : face.card
        layer.borderColor = (card.isChosen ? face.chosenMark : face.line)
            .resolvedColor(with: traitCollection).cgColor
        edgeBar.backgroundColor = card.isPeeked ? face.takeLine : .clear

        let chrome = face.chrome.withSize(12)
        let state: String
        if card.isChosen {
            state = chromeCase("✓ Chosen")
        } else if card.isPeeked {
            state = chromeCase("Peeking")
        } else {
            state = chromeCase(
                card.isLocked ? "Take \(card.ordinal) · locked" : "Take \(card.ordinal)")
        }
        stateLabel.text = state
        stateLabel.font = chrome
        stateLabel.textColor = card.isChosen ? face.chosenMark : face.muted

        takeLabel.text = card.label
        takeLabel.font = chrome
        takeLabel.textColor = face.muted
        takeLabel.isHidden = (card.label ?? "").isEmpty

        // ✓ is a DOOR only where it can act (P-2): the chosen card wears
        // the state, never an inert button.
        chooseButton.isHidden = card.isChosen
        chooseButton.setTitleColor(face.chosenMark, for: .normal)
        chooseButton.titleLabel?.font = chrome

        menuButton.setTitleColor(face.muted, for: .normal)
        menuButton.titleLabel?.font = face.chrome.withSize(14)
        // Rebuilt per apply, so the lock row MIRRORS the take's state
        // (parity C4a — the seal glyph's one-reversible-tap grammar,
        // menu-rowed) and a voice flip reaches an already-built card.
        let locked = card.isLocked
        // **BATCH 9 — `Block History…` JOINS THIS MENU, at her instruction**
        // (*"take history should move into the three ... menu on each take
        // rather than the main three dot menu"*), and it leads: the two rows
        // above the divide are about IDENTITY and STATE, this one is the
        // take's whole past, and reading before acting is the calmer order.
        // The title is the shared face's own name
        // (`MobileTakesBrowserController.historyTitle`), and pressing it
        // closes this browser before the face opens — the reasons are at
        // `openHistory(variantID:)`.
        // **BATCH 7 — THREE ROWS JOIN** (PL-10(a) + PL-10(d)), and the ORDER
        // is the menu's existing grammar continued: read (history), then the
        // card's own identity facts — its name, and its PLACE in the fan
        // beside the ordinal the meta row shows — then state (lock), then
        // the three ways a take LEAVES this fan, gentlest first (into a block
        // of its own · archived aside · deleted).
        //
        // **The move pair is absent on a ONE-TAKE fan and DISABLED at the end
        // it cannot reach** — #57(e)'s ruled shape, in menu-row register: the
        // Mac greys the end arrow rather than vanishing it, so the card's
        // furniture never jumps as takes move, and a fanless block draws no
        // arrows at all. `.disabled` is UIKit's own greying, and the
        // enablement is a projection HINT — `moveTake` re-decides from the
        // store, and speaks if the fan moved underneath.
        //
        // The order lives ONCE, in `cardRowTitles`, which the drift pin reads.
        var rows: [UIMenuElement] = [
            UIAction(title: chromeCase(MobileTakesBrowserController.historyTitle)) {
                [onHistory] _ in onHistory()
            },
            UIAction(title: chromeCase(MobileTakesBrowserController.labelRowTitle)) {
                [onLabel] _ in onLabel()
            },
        ]
        if fanned {
            rows += [
                UIAction(
                    title: chromeCase(MobileTakesBrowserController.moveUpTitle),
                    attributes: canMoveUp ? [] : .disabled
                ) { [onMove] _ in onMove(-1) },
                UIAction(
                    title: chromeCase(MobileTakesBrowserController.moveDownTitle),
                    attributes: canMoveDown ? [] : .disabled
                ) { [onMove] _ in onMove(1) },
            ]
        }
        rows += [
            UIAction(title: chromeCase(
                locked ? MobileTakesBrowserController.unlockTitle
                       : MobileTakesBrowserController.lockTitle)
            ) { [onSetLocked] _ in onSetLocked(!locked) },
            // E5. NOT `.destructive`: nothing is destroyed — the take becomes
            // a block and the original is archived (AR-1), which is exactly
            // what separates it from the row two below.
            UIAction(title: chromeCase(MobileTakesBrowserController.takeToBlockTitle)) {
                [onTakeToBlock] _ in onTakeToBlock()
            },
            UIAction(title: chromeCase(MobileTakesBrowserController.archiveTitle)) {
                [onArchive] _ in onArchive()
            },
            UIAction(
                title: chromeCase(MobileTakesBrowserController.deleteTitle),
                attributes: .destructive
            ) { [onDelete] _ in onDelete() },
        ]
        menuButton.menu = UIMenu(children: rows)

        bodyLabel.text = card.text.isEmpty ? chromeCase("(Empty take)") : card.text
        bodyLabel.font = face.body
        bodyLabel.textColor = card.text.isEmpty ? face.muted : face.ink
        bodyLabel.isHidden = live
    }

    func hostEditor(_ editor: UITextView) {
        editorHost = editor
        addSubview(editor)
    }

    func preferredHeight(width: CGFloat, live: Bool) -> CGFloat {
        if live { return Self.editorHeight + 34 }
        let bodyWidth = width - 24
        let size = bodyLabel.sizeThatFits(
            CGSize(width: bodyWidth, height: .greatestFiniteMagnitude))
        return max(size.height, 18) + 42
    }

    func layoutContent() {
        edgeBar.frame = CGRect(x: 0, y: 0, width: 2.5, height: bounds.height)
        stateLabel.sizeToFit()
        stateLabel.frame.origin = CGPoint(x: 12, y: 8)
        takeLabel.sizeToFit()
        takeLabel.frame.origin = CGPoint(x: stateLabel.frame.maxX + 10, y: 8)
        menuButton.frame = CGRect(x: bounds.width - 36, y: 2, width: 30, height: 26)
        chooseButton.frame = CGRect(x: menuButton.frame.minX - 32, y: 2, width: 28, height: 26)
        let bodyTop: CGFloat = 30
        if let editor = editorHost, editor.superview === self {
            editor.frame = CGRect(
                x: 8, y: bodyTop, width: bounds.width - 16,
                height: bounds.height - bodyTop - 4)
        }
        bodyLabel.frame = CGRect(
            x: 12, y: bodyTop, width: bounds.width - 24,
            height: max(bounds.height - bodyTop - 12, 0))
    }
}

// MARK: - One archived take card (parity C4a — see-your-data + the road back)

/// Read-only by the model's own rule (an archived buffer refuses edits —
/// history is not an editing surface); the ⋯ carries Unarchive (the road
/// back) and Delete. The Mac WriteTakesPanel's archived card, phone-carded.
@MainActor
final class MobileArchivedTakeCardView: UIView {
    let variantID: String
    private let stateLabel = UILabel()
    private let takeLabel = UILabel()
    private let menuButton = UIButton(type: .custom)
    private let bodyLabel = UILabel()
    private let onUnarchive: () -> Void
    private let onDelete: () -> Void
    private let onLabel: () -> Void

    init(
        variantID: String,
        onUnarchive: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        onLabel: @escaping () -> Void = {}
    ) {
        self.variantID = variantID
        self.onUnarchive = onUnarchive
        self.onDelete = onDelete
        self.onLabel = onLabel
        super.init(frame: .zero)
        accessibilityIdentifier = "takes.archived.\(variantID)"
        layer.cornerRadius = 10
        layer.borderWidth = 1

        stateLabel.accessibilityIdentifier = "takes.archived.state"
        takeLabel.accessibilityIdentifier = "takes.archived.label"
        bodyLabel.accessibilityIdentifier = "takes.archived.body"
        bodyLabel.numberOfLines = 2

        menuButton.setTitle("⋯", for: .normal)
        menuButton.accessibilityIdentifier = "takes.archived.menu"
        menuButton.accessibilityLabel = "Archived take actions"
        menuButton.showsMenuAsPrimaryAction = true

        for view in [stateLabel, takeLabel, menuButton, bodyLabel] {
            addSubview(view)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    func apply(
        card: MobileTakesBrowserController.ArchivedCard,
        face: MobileEditorStyle.Face,
        chromeCase: (String) -> String
    ) {
        backgroundColor = face.card
        layer.borderColor = face.line.resolvedColor(with: traitCollection).cgColor

        let chrome = face.chrome.withSize(12)
        stateLabel.text = chromeCase("Archived")
        stateLabel.font = chrome
        stateLabel.textColor = face.muted

        takeLabel.text = card.label
        takeLabel.font = chrome
        takeLabel.textColor = face.muted
        takeLabel.isHidden = (card.label ?? "").isEmpty

        menuButton.setTitleColor(face.muted, for: .normal)
        menuButton.titleLabel?.font = face.chrome.withSize(14)
        // **NO `Block History…` ROW HERE, and the absence is deliberate**
        // (batch 9). Her letter says *"each take"*, and an archived take is
        // one — but the door's whole gain over the retired block-⋯ row is
        // that it FOCUSES the take it was pressed on, and an archived take
        // has no savepoint run to focus: `BlockHistoryExpansion` would take
        // the id (it reads `history.takes`, which carries archived rows) and
        // then find no `takeHeader` for it, because `rows()` sections the
        // ACTIVE takes only — so the face would open with nothing expanded,
        // which is worse than the default. The archived listing is itself
        // one of the face's four regions, and every archived take on this
        // card is already visible in it. On her sitting list.
        menuButton.menu = UIMenu(children: [
            UIAction(title: chromeCase("Unarchive Take")) { [onUnarchive] _ in onUnarchive() },
            UIAction(title: chromeCase("Label Take…")) { [onLabel] _ in onLabel() },
            UIAction(
                title: chromeCase("Delete Take"), attributes: .destructive
            ) { [onDelete] _ in onDelete() },
        ])

        bodyLabel.text = card.text.isEmpty ? chromeCase("(Empty take)") : card.text
        bodyLabel.font = face.body
        bodyLabel.textColor = face.muted
    }

    func preferredHeight(width: CGFloat) -> CGFloat {
        let size = bodyLabel.sizeThatFits(
            CGSize(width: width - 24, height: .greatestFiniteMagnitude))
        return max(min(size.height, 44), 18) + 42
    }

    func layoutContent() {
        stateLabel.sizeToFit()
        stateLabel.frame.origin = CGPoint(x: 12, y: 8)
        takeLabel.sizeToFit()
        takeLabel.frame.origin = CGPoint(x: stateLabel.frame.maxX + 10, y: 8)
        menuButton.frame = CGRect(x: bounds.width - 36, y: 2, width: 30, height: 26)
        bodyLabel.frame = CGRect(
            x: 12, y: 30, width: bounds.width - 24,
            height: max(bounds.height - 42, 0))
    }
}
