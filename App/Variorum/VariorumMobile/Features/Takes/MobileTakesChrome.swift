//
//  MobileTakesChrome.swift
//  VariorumMobile
//
//  Mobile Stage 2, batch 1 — the takes surface's PIXELS (the brain is
//  `MobileTakesController`; NIT-3's sibling discipline). Three overlays +
//  one gesture, all styled from `MobileEditorStyle.face` (never literals —
//  the S1 flag-6 forward-duty):
//
//  - THE BADGE (LK3): fanned blocks wear ⑂ ALONE — count-free, an OVERLAY
//    at the block's first fragment's trailing corner (P-8: overlays, never
//    rendering attributes). Tapping it opens the TAKES BROWSER (S2 batch
//    2 — LK3's "the tap is the door"; counts appear once open. Batch 1's
//    interim pill reveal, P15, is RETIRED as its own record planned).
//  - THE GUTTER (LK10, her ruling: "text shouldn't go under the take
//    icon … maybe just reserve some space for it?"): an exclusion rect at
//    the block's first fragment's trailing corner, so the first line ends
//    short of the badge. Non-fanned blocks reserve NOTHING.
//  - THE PEEK MARKER (M9): while a block displays a peeked take it wears
//    the takes register visibly — the `takeTint` wash behind the block
//    with a `takeLine` edge bar (the ratified v1 mockup's `.peeked`
//    grammar: "tinted + edge-marked — visibly not-chosen").
//  - THE PILL (LK6, shape A): under the block on any flip — ‹ take k/n ·
//    label › with ✓ while peeked (✓ is the ONLY choosing act); displaying
//    the chosen truth states "✓ chosen" instead (P-2: no inert door).
//    Fades after a beat; back on any flip.
//  - THE PAN (M5, the spike's proven shape): a delegate-gated horizontal
//    `UIPanGestureRecognizer` — horizontal-dominance gate, never
//    simultaneous with the scroll pan, scoped to fanned blocks by
//    fragment hit-testing. Non-fanned blocks don't respond.
//
//  Geometry discipline: every refresh is EQUALITY-GATED (frames and
//  exclusion rects only write when they moved), so the steady state is
//  write-free and the layoutSubviews hook cannot loop. Fragment lookups
//  ride `enumerateTextLayoutFragments(.ensuresLayout)` per FANNED block —
//  the spike's measured 0.03 ms/rect class. SCOPES (S2 ladder round 1,
//  MINOR 3 — the P-8 shape fix): content/geometry input axes (edits,
//  projections, flips, voice, width) run `.document` — cost ∝ the post's
//  fanned blocks (opt-in and rare by the model's own doctrine); the
//  per-scroll-tick layoutSubviews hook runs `.nearViewport` — geometry is
//  forced ONLY for blocks intersecting the padded TK2 viewport (the
//  queryable `viewportRange`), so a tick's cost ∝ realized rows, never
//  the post, and far-off-screen fragments are never layout-forced at
//  scroll rate against TK2's own laziness (TEXTKIT2 §2). Off-band chrome
//  keeps its last resolved geometry — every overlay is a content-anchored
//  subview, so scrolling itself never moves it — and heals the moment its
//  block scrolls near. The device round measures the magnitude.
//

import UIKit
import VariorumCore

// MARK: - The chrome controller

@MainActor
final class MobileTakesChromeController {
    static let badgeGlyph = "⑂"
    /// The LK10 gutter's width (badge + breathing room). PROVISIONAL like
    /// every visual constant — the look rounds rule.
    static let gutterWidth: CGFloat = 30

    private weak var textView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    private var badges: [String: UIButton] = [:]
    /// blockID → the peek marker (the tint wash; its edge bar is a subview).
    private var markers: [String: UIView] = [:]
    private var pill: MobileTakesPillView?
    private(set) var pillBlockID: String?
    private var fadeTimer: Timer?
    private var currentExclusions: [CGRect] = []
    /// blockID → its last resolved gutter rect — what a `.nearViewport`
    /// pass keeps for off-band blocks (dropping an off-band exclusion
    /// would reflow the whole document per tick).
    private var exclusionByBlock: [String: CGRect] = [:]
    /// The container width of the last `.document` pass — a width change
    /// moves every rect, so a tick under a new width escalates to full.
    private var lastFullPassWidth: CGFloat = -1
    /// Test seam (the MINOR-3 call-shape pin): the blocks whose geometry
    /// the most recent refresh actually resolved (fragment layout forced).
    private(set) var lastGeometryResolvedBlockIDs: Set<String> = []
    private var refreshing = false

    /// The pill's fade-out delay ("fades after a beat" — LK6). Test seam.
    var pillFadeDelay: TimeInterval = 2.4

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.textView = textView
        self.model = model
    }

    // MARK: Test-visible lookups

    func badgeView(for blockID: String) -> UIView? { badges[blockID] }
    func markerView(for blockID: String) -> UIView? { markers[blockID] }
    var pillView: UIView? { pill }
    var pillIsShowing: Bool { (pill?.alpha ?? 0) > 0.5 && pill?.isHidden == false }

    // MARK: The refresh (all input axes land here; equality-gated)

    /// The refresh's cost scope (S2 ladder round 1, MINOR 3): `.document`
    /// for content/geometry input axes; `.nearViewport` for the
    /// per-scroll-tick hook — geometry forced only inside the padded TK2
    /// viewport, off-band chrome untouched (content-anchored; scrolling
    /// never moves it).
    enum RefreshScope { case document, nearViewport }

    func refresh(scope: RefreshScope = .document) {
        guard !refreshing, let textView, let model,
              textView.bounds.width > 0 else { return }
        refreshing = true
        defer { refreshing = false }
        let face = MobileEditorStyle.face
        let inset = textView.textContainerInset
        let containerWidth = textView.textContainer.size.width

        // The near band. A tick under a changed width escalates to a full
        // pass (every rect moved); an unavailable viewport reads as
        // everything-near (honest fallback — never a silently skipped
        // block). nil band = full pass.
        var band: NSRange?
        if scope == .nearViewport, containerWidth == lastFullPassWidth {
            band = textView.nearViewportBand()
        } else {
            lastFullPassWidth = containerWidth
        }
        lastGeometryResolvedBlockIDs = []
        func near(_ range: NSRange) -> Bool {
            guard let band else { return true }
            return range.location < band.location + band.length
                && band.location < range.location + max(range.length, 1)
        }

        // 1 — badges + gutters for FANNED blocks (LK3/LK10).
        var exclusions: [CGRect] = []
        var seen: Set<String> = []
        for slot in model.slots where slot.hasFan {
            guard let range = model.rangeOfBlock(slot.blockID) else { continue }
            if !near(range), let cached = exclusionByBlock[slot.blockID],
               badges[slot.blockID] != nil {
                // Off the band: last resolved geometry stands — the
                // exclusion MUST stay in the assembled set (dropping it
                // would reflow the document), the badge frame is
                // content-anchored, and styling belongs to the full pass.
                seen.insert(slot.blockID)
                exclusions.append(cached)
                continue
            }
            guard let line = textView.firstLineGeometry(atOffset: range.location)
            else { continue }
            lastGeometryResolvedBlockIDs.insert(slot.blockID)
            seen.insert(slot.blockID)
            // The gutter: text-container coordinates (exclusion space).
            let gutter = CGRect(
                x: containerWidth - Self.gutterWidth,
                y: line.fragmentMinY,
                width: Self.gutterWidth,
                height: line.firstLineHeight)
            exclusionByBlock[slot.blockID] = gutter
            exclusions.append(gutter)
            // The badge: view (content) coordinates, inside the gutter.
            let badge = badges[slot.blockID] ?? makeBadge(blockID: slot.blockID)
            let frame = CGRect(
                x: inset.left + containerWidth - Self.gutterWidth + 4,
                y: inset.top + line.fragmentMinY,
                width: Self.gutterWidth - 4,
                height: max(line.firstLineHeight, 18))
            if badge.frame != frame { badge.frame = frame }
            badge.setTitleColor(face.muted, for: .normal)
            badge.titleLabel?.font = face.chrome.withSize(12)
        }
        for (blockID, badge) in badges where !seen.contains(blockID) {
            badge.removeFromSuperview()
            badges[blockID] = nil
            exclusionByBlock[blockID] = nil
        }
        // S4: the block decor's emoji gutters join the ONE exclusion
        // assembly (one container property, one owner — the decor runs
        // first in `refreshChrome`, so its rects are fresh here).
        exclusions += textView.blockDecor?.currentEmojiExclusions ?? []
        exclusions.sort { ($0.minY, $0.minX) < ($1.minY, $1.minX) }
        if !rectsMatch(exclusions, currentExclusions) {
            currentExclusions = exclusions
            textView.textContainer.exclusionPaths = exclusions.map { UIBezierPath(rect: $0) }
        }

        // 2 — peek markers (M9: sticky, visible, per-block).
        var peeked: Set<String> = []
        for blockID in model.takes.peeks.keys {
            guard let range = model.rangeOfBlock(blockID) else { continue }
            if !near(range), markers[blockID] != nil {
                // Off the band: the marker keeps its content-anchored
                // frame; it heals when the block scrolls near.
                peeked.insert(blockID)
                continue
            }
            guard let union = textView.blockRectsUnion(range: range) else { continue }
            lastGeometryResolvedBlockIDs.insert(blockID)
            peeked.insert(blockID)
            let marker = markers[blockID] ?? makeMarker(blockID: blockID)
            let frame = CGRect(
                x: inset.left + union.minX,
                y: inset.top + union.minY,
                width: union.width,
                height: union.height
            ).insetBy(dx: -6, dy: -2)
            if marker.frame != frame {
                marker.frame = frame
                marker.subviews.first?.frame = CGRect(
                    x: 0, y: 0, width: 2.5, height: frame.height)
            }
            marker.backgroundColor = face.takeTint
            marker.subviews.first?.backgroundColor = face.takeLine
        }
        for (blockID, marker) in markers where !peeked.contains(blockID) {
            marker.removeFromSuperview()
            markers[blockID] = nil
        }

        // 3 — the pill follows its block (and dies with a vanished fan).
        if let pillBlockID {
            if let pill, seen.contains(pillBlockID),
               let content = model.takes.pillContent(blockID: pillBlockID),
               let range = model.rangeOfBlock(pillBlockID) {
                if near(range) {
                    guard let union = textView.blockRectsUnion(range: range) else {
                        hidePill()
                        return
                    }
                    lastGeometryResolvedBlockIDs.insert(pillBlockID)
                    pill.apply(content: content, face: face)
                    pill.sizeToFitContent()
                    let origin = CGPoint(
                        x: inset.left + union.minX,
                        y: inset.top + union.maxY + 6)
                    if pill.frame.origin != origin { pill.frame.origin = origin }
                }
                // Off the band: untouched this tick (content-anchored;
                // it fades on its own timer).
            } else {
                hidePill()
            }
        }
    }

    // The band / fragment-geometry helpers moved to MobileEditorTextView
    // at S4 batch 1 (move-only): the block decor consults the SAME
    // implementations, so the two chrome controllers can never disagree
    // about a rect.

    // MARK: Peek events (the controller's hook)

    func peekDidChange(_ blockID: String) {
        refresh()
        showPill(anchoredTo: blockID)
    }

    /// The badge's tap: THE takes browser's door (LK3's "the tap is the
    /// door" — counts appear once open). S2 batch 2 repointed this from
    /// batch 1's interim pill reveal (P15 RETIRES as recorded); the pill
    /// remains the in-page FLIP's face (`peekDidChange` shows it).
    func badgeTapped(_ blockID: String) {
        model?.openTakesBrowser(blockID: blockID)
    }

    func showPill(anchoredTo blockID: String) {
        guard let textView, let model,
              model.takes.pillContent(blockID: blockID) != nil else { return }
        if pill == nil {
            let view = MobileTakesPillView(
                onPrevious: { [weak self] in self?.flipFromPill(forward: false) },
                onNext: { [weak self] in self?.flipFromPill(forward: true) },
                onChoose: { [weak self] in self?.chooseFromPill() })
            textView.addSubview(view)
            pill = view
        }
        pillBlockID = blockID
        pill?.isHidden = false
        pill?.layer.removeAllAnimations()
        pill?.alpha = 1
        refresh()
        armFade()
    }

    private func hidePill() {
        fadeTimer?.invalidate()
        fadeTimer = nil
        pill?.isHidden = true
        pill?.alpha = 0
        pillBlockID = nil
    }

    private func armFade() {
        fadeTimer?.invalidate()
        fadeTimer = Timer.scheduledTimer(
            withTimeInterval: pillFadeDelay, repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, let pill = self.pill else { return }
                UIView.animate(withDuration: 0.35) {
                    pill.alpha = 0
                }
            }
        }
    }

    private func flipFromPill(forward: Bool) {
        guard let pillBlockID else { return }
        model?.takes.flip(blockID: pillBlockID, forward: forward)
    }

    private func chooseFromPill() {
        guard let pillBlockID, let model else { return }
        Task { await model.takes.chooseDisplayed(blockID: pillBlockID) }
    }

    // MARK: View factories

    private func makeBadge(blockID: String) -> UIButton {
        let badge = UIButton(type: .custom)
        badge.setTitle(Self.badgeGlyph, for: .normal)
        badge.accessibilityIdentifier = "takes.badge.\(blockID)"
        badge.accessibilityLabel = "Takes"
        badge.accessibilityHint = "Shows this block's takes"
        badge.addAction(
            UIAction { [weak self] _ in self?.badgeTapped(blockID) },
            for: .touchUpInside)
        textView?.addSubview(badge)
        badges[blockID] = badge
        return badge
    }

    private func makeMarker(blockID: String) -> UIView {
        let marker = UIView()
        marker.accessibilityIdentifier = "takes.peek.\(blockID)"
        marker.isUserInteractionEnabled = false
        marker.layer.cornerRadius = 6
        marker.clipsToBounds = true
        let edge = UIView()
        edge.isUserInteractionEnabled = false
        marker.addSubview(edge)
        // BEHIND the text: subview index 0 sits under the TK2 text canvas,
        // so the wash tints without veiling glyphs (device-round check
        // rides the feel round; the subview ordering is pinned).
        textView?.insertSubview(marker, at: 0)
        markers[blockID] = marker
        return marker
    }

    // MARK: Geometry

    private func rectsMatch(_ a: [CGRect], _ b: [CGRect]) -> Bool {
        guard a.count == b.count else { return false }
        for (x, y) in zip(a, b) {
            if abs(x.minX - y.minX) > 0.5 || abs(x.minY - y.minY) > 0.5
                || abs(x.width - y.width) > 0.5 || abs(x.height - y.height) > 0.5 {
                return false
            }
        }
        return true
    }
}

// MARK: - The pill (LK6, shape A)

@MainActor
final class MobileTakesPillView: UIView {
    private let previousButton = UIButton(type: .custom)
    private let nextButton = UIButton(type: .custom)
    private let infoLabel = UILabel()
    private let chooseButton = UIButton(type: .custom)
    private let chosenLabel = UILabel()

    init(
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onChoose: @escaping () -> Void
    ) {
        super.init(frame: .zero)
        accessibilityIdentifier = "takes.pill"
        layer.cornerRadius = 14
        layer.borderWidth = 1
        previousButton.setTitle("‹", for: .normal)
        previousButton.accessibilityIdentifier = "takes.pill.previous"
        previousButton.accessibilityLabel = "Previous take"
        previousButton.addAction(UIAction { _ in onPrevious() }, for: .touchUpInside)
        nextButton.setTitle("›", for: .normal)
        nextButton.accessibilityIdentifier = "takes.pill.next"
        nextButton.accessibilityLabel = "Next take"
        nextButton.addAction(UIAction { _ in onNext() }, for: .touchUpInside)
        chooseButton.setTitle("✓", for: .normal)
        chooseButton.accessibilityIdentifier = "takes.pill.choose"
        chooseButton.accessibilityLabel = "Choose this take"
        chooseButton.addAction(UIAction { _ in onChoose() }, for: .touchUpInside)
        chosenLabel.text = "✓ chosen"
        chosenLabel.accessibilityIdentifier = "takes.pill.chosenState"
        for view in [previousButton, infoLabel, nextButton, chooseButton, chosenLabel] {
            addSubview(view)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    func apply(content: MobileTakesController.PillContent, face: MobileEditorStyle.Face) {
        backgroundColor = face.card
        layer.borderColor = face.takeLine.resolvedColor(
            with: traitCollection).cgColor
        let chrome = face.chrome.withSize(12)
        infoLabel.text = content.text
        infoLabel.font = chrome
        infoLabel.textColor = face.muted
        for button in [previousButton, nextButton] {
            button.setTitleColor(face.muted, for: .normal)
            button.titleLabel?.font = face.chrome.withSize(15)
        }
        chooseButton.setTitleColor(face.chosenMark, for: .normal)
        chooseButton.titleLabel?.font = chrome.bold
        chooseButton.isHidden = !content.canChoose
        chosenLabel.font = chrome
        chosenLabel.textColor = face.chosenMark
        chosenLabel.isHidden = content.canChoose
    }

    /// Manual layout: ‹ · text · › · (✓ | "✓ chosen"), 28 pt tall.
    func sizeToFitContent() {
        let height: CGFloat = 28
        let arrow: CGFloat = 20
        infoLabel.sizeToFit()
        chosenLabel.sizeToFit()
        var x: CGFloat = 10
        previousButton.frame = CGRect(x: x, y: 0, width: arrow, height: height)
        x += arrow + 2
        infoLabel.frame = CGRect(
            x: x, y: 0, width: infoLabel.bounds.width, height: height)
        x += infoLabel.bounds.width + 2
        nextButton.frame = CGRect(x: x, y: 0, width: arrow, height: height)
        x += arrow + 4
        if chooseButton.isHidden {
            chosenLabel.frame = CGRect(
                x: x, y: 0, width: chosenLabel.bounds.width, height: height)
            x += chosenLabel.bounds.width
        } else {
            chooseButton.frame = CGRect(x: x, y: 0, width: 22, height: height)
            x += 22
        }
        frame.size = CGSize(width: x + 10, height: height)
    }
}

extension UIFont {
    fileprivate var bold: UIFont {
        UIFont(
            descriptor: fontDescriptor.withSymbolicTraits(.traitBold) ?? fontDescriptor,
            size: pointSize)
    }
}

// MARK: - The pan router (M5 — the spike's proven gesture shape)

@MainActor
final class MobileTakesPanRouter: NSObject, UIGestureRecognizerDelegate {
    private weak var textView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?
    private(set) var activeBlockID: String?

    /// The flip threshold (the spike's 30 pt) and dominance gate (1.5×).
    static let flipThreshold: CGFloat = 30

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.textView = textView
        self.model = model
    }

    /// The block under a point in VIEW (content) coordinates — fragment
    /// hit-test → surface offset → the index authority. nil off-text.
    func blockID(at point: CGPoint) -> String? {
        guard let textView, let model,
              let tlm = textView.textLayoutManager,
              let cm = tlm.textContentManager
        else { return nil }
        let containerPoint = CGPoint(
            x: point.x - textView.textContainerInset.left,
            y: point.y - textView.textContainerInset.top)
        guard let fragment = tlm.textLayoutFragment(for: containerPoint),
              fragment.layoutFragmentFrame.insetBy(dx: -4, dy: -4).contains(containerPoint)
        else { return nil }
        let offset = cm.offset(
            from: tlm.documentRange.location, to: fragment.rangeInElement.location)
        return model.blockID(atSurfaceOffset: offset)
    }

    /// The scoping brain, test-visible: the FANNED block a pan starting at
    /// this point would flip — nil means the gesture never begins (the
    /// scroll keeps the touch). Non-fanned blocks don't respond (M5).
    func panTargetBlockID(at point: CGPoint) -> String? {
        guard let blockID = blockID(at: point),
              model?.slot(for: blockID)?.hasFan == true
        else { return nil }
        return blockID
    }

    // MARK: UIGestureRecognizerDelegate

    nonisolated func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        MainActor.assumeIsolated {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer,
                  let textView else { return false }
            let translation = pan.translation(in: textView)
            // Horizontal dominance — vertical drags stay the scroll's.
            guard abs(translation.x) > abs(translation.y) * 1.5,
                  abs(translation.x) > 4 else { return false }
            // Never mid-IME (the flip would rewrite the composition).
            guard textView.markedTextRange == nil else { return false }
            guard let blockID = panTargetBlockID(at: pan.location(in: textView))
            else { return false }
            activeBlockID = blockID
            return true
        }
    }

    nonisolated func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        // Never simultaneous with the scroll pan (the spike's proven
        // configuration): once this pan begins it owns the touch.
        false
    }

    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .ended:
            defer { activeBlockID = nil }
            guard let activeBlockID, let textView else { return }
            let tx = gesture.translation(in: textView).x
            guard abs(tx) > Self.flipThreshold else { return }
            // Swipe left → next take; swipe right → previous (the spike's
            // carousel direction).
            model?.takes.flip(blockID: activeBlockID, forward: tx < 0)
        case .cancelled, .failed:
            activeBlockID = nil
        default:
            break
        }
    }
}
