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
//    icon … maybe just reserve some space for it?"): first-paragraph
//    trailing room, so the badge line ends short of the badge.
//    Non-fanned blocks reserve NOTHING. MECHANISM since parity B3
//    (FB2-1): a paragraph-style tail reservation through
//    `MobileEditorTextView.setTailReservation` — container
//    `exclusionPaths` are RETIRED on this surface (their PRESENCE made
//    every keystroke's relayout document-scale; the B3 record has the
//    probe), and no code may reinstall one (pinned).
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
//  Geometry discipline (VM-17, batch D — ladder round 3's called shape,
//  `notes/plans/fixes/vm-78-ladder-round3.md`; TEXTKIT2 §3): a takes
//  overlay is drawn only from text TextKit has laid out in its OWN
//  viewport (`MobileEditorTextView.viewportCharacterRange()`, unpadded) —
//  outside it nothing is read, nothing is forced and nothing stands.
//  A badge or marker VIEW exists only once placed (frame written, styled,
//  shown); while its block has nothing inside the viewport it is HIDDEN,
//  its frame kept and never read; it is removed when its fan or its peek
//  dies. The pill hides the same way and keeps its fade timer and its
//  block, coming back with it. Every read BEGINS inside the viewport
//  (`firstLineGeometry` at a block start that is inside;
//  `blockRectsUnion(range:within:)`, clipped to it), so its
//  `.ensuresLayout` is a lookup, or the in-place re-layout of a paragraph
//  an edit just invalidated — never layout ahead of unlaid text, the
//  read that once left badges 74 pt off their line, and never a frame
//  left standing while TextKit re-positions its fragment (the 1,260-pt
//  strays). TWO WALKS PER LAYOUT PASS: every refresh runs ONE geometry
//  walk over the viewport as TextKit last reported it, then arms the
//  RE-READ — a zero-size anchor subview whose `layoutSubviews` runs after
//  TextKit's own subviews in the same pass, on the fresh viewport (where
//  the unforced read was measured equal to the settled position, 118 of
//  118). The three SCOPES share that one geometry walk; a scope decides
//  only the reservation walk's continuation heal and the `.edit` road's
//  residue heal. Every write is EQUALITY-GATED (frames and reservations
//  write only when they moved), so the steady state is write-free and
//  the layoutSubviews hook cannot loop. RESERVATIONS are
//  viewport-INDEPENDENT: storage-attribute truth (no geometry, no layout
//  forcing to verify), checked against the paragraph's governing
//  character every pass and written only on real change — one paragraph
//  invalidated per real change, zero at steady state.
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
    /// P38 (parity A3 — the ruled fix for the recorded one-line
    /// fanned+commented crowding corner): a fanned block that is ALSO
    /// commented reserves this much extra first-line room, so a one-line
    /// block's ●n marker (which sits at the LAST line's end — the first
    /// line, for one-liners) can never run under the ⑂ badge. Keyed on
    /// CONTENT (fanned ∧ commented), never on measured line count —
    /// a geometry key would oscillate (widening the exclusion can wrap
    /// the line, unwrapping un-widens it, forever). A multi-line block
    /// pays one slightly shorter first line; marker PLACEMENT itself
    /// stands (her ruling).
    static let commentMarkRoom: CGFloat = 26

    private weak var textView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    private var badges: [String: UIButton] = [:]
    /// blockID → the peek marker (the tint wash; its edge bar is a subview).
    private var markers: [String: UIView] = [:]
    private var pill: MobileTakesPillView?
    private(set) var pillBlockID: String?
    private var fadeTimer: Timer?
    /// The blocks currently carrying a tail reservation — cleanup
    /// targeting only (which paragraphs to CLEAR when a fan dies); the
    /// reservation's truth always lives in storage, never here.
    private var reservedBlocks: Set<String> = []
    /// Test seam (the MINOR-3 call-shape pin): the blocks whose geometry
    /// the LATEST geometry walk read — whichever walk ran last, a
    /// refresh's or the anchor's re-read (VM-17). Only blocks inside
    /// TextKit's viewport are ever read.
    private(set) var lastGeometryResolvedBlockIDs: Set<String> = []
    private var refreshing = false
    /// The re-read's anchor (VM-17, round 3's S6): a zero-size subview
    /// added AFTER TextKit's own, so its `layoutSubviews` runs once TextKit
    /// has laid out the fresh viewport.
    private let anchor: MobileTakesChromeAnchor
    /// The latest refresh's ranges, kept for the re-read (FIX-B2's one
    /// index walk per event stands — the re-read never builds its own);
    /// nil = nothing armed.
    private var rereadRanges: [String: NSRange]?

    /// The pill's fade-out delay ("fades after a beat" — LK6). Test seam.
    var pillFadeDelay: TimeInterval = 2.4

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.textView = textView
        self.model = model
        let anchor = MobileTakesChromeAnchor(frame: .zero)
        self.anchor = anchor
        anchor.controller = self
        textView.addSubview(anchor)
    }

    // MARK: Test-visible lookups

    func badgeView(for blockID: String) -> UIView? { badges[blockID] }
    func markerView(for blockID: String) -> UIView? { markers[blockID] }
    var pillView: UIView? { pill }
    var pillIsShowing: Bool { (pill?.alpha ?? 0) > 0.5 && pill?.isHidden == false }

    // MARK: The refresh (all input axes land here; equality-gated)

    /// The refresh's scope — which input axis called (S2 ladder round 1,
    /// MINOR 3; the third case is parity B3's FB2-1 fix): `.document` for
    /// content/styling axes (deliveries, flips, voice — user-act or settle
    /// cadence, never keystroke); `.nearViewport` for the per-layout-pass
    /// hook; `.edit` for the KEYSTROKE road. Since VM-17 the three share
    /// ONE geometry walk over TextKit's own viewport — nothing outside it
    /// is read, forced or left standing (the header) — so no scope ever
    /// forces layout for a block off screen, and an edit no longer widens
    /// what geometry reads (an edit made off screen keeps its overlays
    /// hidden until it scrolls in). A scope decides only the reservation
    /// walk's continuation heal (the `.edit`/`.document` roads) and the
    /// `.edit` road's typing-residue heal over the edited range
    /// (invalidation ∝ viewport + edit, never post length — FB2-1's law).
    enum RefreshScope { case document, nearViewport, edit(NSRange) }

    /// `ranges`: the per-event ranges index the ONE `refreshChrome` door
    /// builds and shares with both controllers (FIX-B2 — one O(entries)
    /// walk per refresh event, not one per controller). nil ⇒ this
    /// controller was refreshed alone (peek/pill roads, direct test
    /// calls) and builds its own. Whichever, the refresh KEEPS them for
    /// the re-read it arms (VM-17, round 3's S5).
    func refresh(scope: RefreshScope = .document, ranges: [String: NSRange]? = nil) {
        guard !refreshing, let textView, let model,
              textView.bounds.width > 0 else { return }
        refreshing = true
        defer { refreshing = false }
        // Every decorated block's range from ONE index walk (B3 —
        // per-block `rangeOfBlock` is O(entries), and the per-pass
        // decorated×entries scans were real per-tick milliseconds at
        // 100k; FB2-1's record has the measurement), shared across both
        // controllers per event since FIX-B2.
        let ranges = ranges ?? model.blockRangesByID()
        // R2-1: strands are only born by edits — the continuation-heal
        // half of the reservation walk rides the `.edit`/`.document`
        // roads; a scroll tick pays O(first paragraph) per block.
        let healContinuations: Bool = {
            if case .nearViewport = scope { return false }
            return true
        }()

        // 1 — first-paragraph tail RESERVATIONS for FANNED blocks
        // (LK3/LK10; B3's mechanism — see the header and
        // `MobileEditorTextView.setTailReservation`): viewport-independent
        // storage truth, every fan on every pass, written only on real
        // change. A dead fan's badge view goes with it (the view's life,
        // not its geometry — the geometry walk below places or hides).
        var seen: Set<String> = []
        for slot in model.slots where slot.hasFan {
            guard let range = ranges[slot.blockID] else { continue }
            seen.insert(slot.blockID)
            // The gutter: a commented fanned block reserves the ●n
            // marker's room too (P38's one-line crowding fix —
            // content-keyed, see the constant).
            textView.setTailReservation(
                Self.gutterWidth
                    + (slot.commentCount > 0 ? Self.commentMarkRoom : 0),
                blockRange: range, healContinuations: healContinuations)
            reservedBlocks.insert(slot.blockID)
        }
        for (blockID, badge) in badges where !seen.contains(blockID) {
            badge.removeFromSuperview()
            badges[blockID] = nil
        }
        // A dead fan's paragraph gives its room back (a block gone from
        // the surface has no paragraph left to clear).
        for blockID in reservedBlocks.subtracting(seen) {
            if let range = ranges[blockID] {
                textView.setTailReservation(
                    0, blockRange: range, healContinuations: healContinuations)
            }
            reservedBlocks.remove(blockID)
        }
        // FIX-B1 road (b): the EDIT road heals typing-inherited residue —
        // UIKit derives typingAttributes from the character before the
        // caret, and attribute fixing keeps a reserved block's separator
        // styled, so characters typed right after a one-paragraph fanned
        // block (the open tail, the next block's start) land carrying the
        // dent in paragraphs this walk never visits. Zero the tail field
        // across the edited range's paragraphs, skipping exactly the
        // first paragraphs this walk governs (the reserved blocks').
        if case .edit(let edited) = scope {
            textView.healTailReservationResidue(
                in: edited,
                skippingParagraphsAt: Set(seen.compactMap { ranges[$0]?.location }))
        }

        // 2 — the overlays' lives (never their geometry): an ended peek's
        // marker goes; the pill hides for its two causes only — no content
        // left, or its fan gone (its block merely off screen is the
        // geometry walk's, which hides it and keeps its timer and block).
        for (blockID, marker) in markers
        where model.takes.peeks[blockID] == nil || ranges[blockID] == nil {
            marker.removeFromSuperview()
            markers[blockID] = nil
        }
        if let pillBlockID,
           !(pill != nil && seen.contains(pillBlockID)
             && model.takes.pillContent(blockID: pillBlockID) != nil
             && ranges[pillBlockID] != nil) {
            hidePill()
        }

        // 3 — ONE geometry walk over the viewport as TextKit last reported
        // it, then the re-read armed: the anchor lays out after TextKit's
        // own subviews — in this layout pass when the refresh runs inside
        // one (the scroll tick), else in the next — and walks again on the
        // fresh viewport with these same ranges.
        geometryWalk(ranges: ranges)
        rereadRanges = ranges
        anchor.setNeedsLayout()
    }

    /// The re-read (VM-17, round 3's S5): the anchor's `layoutSubviews`.
    /// The geometry walk once more, on the viewport TextKit has just laid
    /// out, with the ranges the latest refresh kept — which it then drops.
    /// It writes no reservation, never arms itself, and never builds a
    /// ranges index of its own (FIX-B2): with nothing kept it does nothing.
    fileprivate func reread() {
        guard !refreshing, let ranges = rereadRanges else { return }
        rereadRanges = nil
        guard let textView, textView.bounds.width > 0 else { return }
        refreshing = true
        defer { refreshing = false }
        geometryWalk(ranges: ranges)
    }

    /// The ONE geometry walk every scope and both walks share (VM-17,
    /// round 3's S1–S4): reads begin only inside TextKit's viewport, a view
    /// is made only when placed, and an overlay whose block has nothing
    /// inside is hidden with its frame kept — never read, never forced.
    /// A nil viewport resolves NOTHING: it makes nothing, shows nothing
    /// and hides nothing (the re-read decides; the everything-near
    /// fallback is the block decor's alone now).
    private func geometryWalk(ranges: [String: NSRange]) {
        guard let textView, let model else { return }
        lastGeometryResolvedBlockIDs = []
        guard let viewport = textView.viewportCharacterRange() else { return }
        let face = MobileEditorStyle.face
        let inset = textView.textContainerInset
        let containerWidth = textView.textContainer.size.width
        let textLength = textView.textStorage.length

        // The badges (LK3): a fan whose first line starts inside the
        // viewport is placed from it; any other fan's view (if it has
        // one) is hidden, frame kept, not read.
        var fans: Set<String> = []
        for slot in model.slots where slot.hasFan {
            guard let range = ranges[slot.blockID] else { continue }
            fans.insert(slot.blockID)
            guard MobileEditorTextView.viewport(
                      viewport, holdsBlockStartAt: range.location, textLength: textLength),
                  let line = textView.firstLineGeometry(atOffset: range.location)
            else {
                badges[slot.blockID]?.isHidden = true
                continue
            }
            lastGeometryResolvedBlockIDs.insert(slot.blockID)
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
            if badge.isHidden { badge.isHidden = false }
        }

        // The peek markers (M9: sticky, visible, per-block): placed from
        // the block's part inside the viewport, hidden while it has none.
        for blockID in model.takes.peeks.keys {
            guard let range = ranges[blockID] else { continue }
            guard let union = textView.blockRectsUnion(range: range, within: viewport) else {
                markers[blockID]?.isHidden = true
                continue
            }
            lastGeometryResolvedBlockIDs.insert(blockID)
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
            if marker.isHidden { marker.isHidden = false }
        }

        // The pill (LK6) follows its block while it is alive for it (its
        // life is the refresh's — above): placed under the block's part
        // inside the viewport, hidden while it has none — `isHidden`, never
        // `hidePill()`: it keeps its timer and its block and comes back
        // with it. It carries the one choosing act (✓), so it never stands
        // where its block is not.
        if let pillBlockID, let pill, fans.contains(pillBlockID),
           let content = model.takes.pillContent(blockID: pillBlockID),
           let range = ranges[pillBlockID] {
            if let union = textView.blockRectsUnion(range: range, within: viewport) {
                lastGeometryResolvedBlockIDs.insert(pillBlockID)
                pill.apply(content: content, face: face)
                pill.sizeToFitContent()
                let origin = CGPoint(
                    x: inset.left + union.minX,
                    y: inset.top + union.maxY + 6)
                if pill.frame.origin != origin { pill.frame.origin = origin }
                if pill.isHidden { pill.isHidden = false }
            } else {
                pill.isHidden = true
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

}

// MARK: - The re-read's anchor (VM-17, round 3's S6)

/// A zero-size, never-hidden subview of the text view, added with
/// `addSubview` when the chrome controller is made — so it sits after
/// TextKit's own subviews (the peek markers and the decor's washes still go
/// in at index 0, beneath the text). Every chrome refresh marks it for
/// layout; UIKit then lays it out after its superview, in the same layout
/// pass when the refresh ran inside one, and its `layoutSubviews` runs the
/// chrome's RE-READ on the viewport TextKit has just laid out. It is the
/// settle measurement's sentinel made product: zero-size and not hidden is
/// the configuration that fired at every stop (61 of 61). No interaction,
/// not an accessibility element, a weak hold on its controller.
@MainActor
private final class MobileTakesChromeAnchor: UIView {
    weak var controller: MobileTakesChromeController?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("not used") }

    override func layoutSubviews() {
        super.layoutSubviews()
        controller?.reread()
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
