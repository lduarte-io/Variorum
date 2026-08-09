//
//  MobileBlockDecor.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M12) — the Write page's block DECOR: callout
//  frames and comment markers. A SIBLING chrome controller beside
//  `MobileTakesChromeController` (the S2 pattern: pixels here, brains in
//  the store/projection), styled from `MobileCallout` / the face — never
//  literals (P-8).
//
//  - THE CALLOUT FRAME (13k's one-frame rule; R16/R27): a framed block
//    wears ONE wash behind its whole text region — an OVERLAY inserted
//    below the text canvas (P-8: overlays, never rendering attributes;
//    the S2 peek marker's exact z-order), color resolved from the stored
//    THEME-TOKEN name. The EMOJI renders in a reserved leading gap on the
//    block's first line — LK10's reservation at the mirror corner
//    (the ratified mockup draws the glyph before the first words), so
//    text never runs under it. MECHANISM since parity B3 (FB2-1): the
//    gap is a `firstLineHeadIndent` reservation through
//    `MobileEditorTextView.setLeadingFirstLineReservation` — exactly
//    first-line-only. Container `exclusionPaths` are RETIRED on this
//    surface (their PRESENCE made every keystroke's relayout
//    document-scale — the B3 record's probe), and no code may reinstall
//    one (pinned).
//  - THE COMMENT MARKER (M12; the mockup's ●n form): a commented block
//    wears a small ●n at the end of its LAST line; tapping it opens the
//    block's comments sheet (the badge-tap grammar).
//
//  Geometry discipline is the chrome's own: equality-gated writes, the
//  banded scopes on scroll/edit ticks (the S2 MINOR-3 scope law + B3's
//  `.edit`), cost ∝ the post's framed/commented blocks on content axes.
//  Reservations are band-independent storage truth, exactly as in the
//  takes chrome (its header has the full B3 rationale).
//

import UIKit
import VariorumCore

@MainActor
final class MobileBlockDecorController {
    private weak var textView: MobileEditorTextView?
    private weak var model: MobileEditorViewModel?

    /// blockID → the callout wash (its emoji label rides `emojiLabels`).
    private var frames: [String: UIView] = [:]
    private var emojiLabels: [String: UILabel] = [:]
    private var commentMarks: [String: UIButton] = [:]
    /// The blocks currently carrying an emoji head reservation —
    /// cleanup targeting only (the takes chrome's `reservedBlocks`
    /// discipline); the reservation's truth lives in storage.
    private var emojiReservedBlocks: Set<String> = []
    private var lastFullPassWidth: CGFloat = -1
    private var refreshing = false

    init(textView: MobileEditorTextView, model: MobileEditorViewModel) {
        self.textView = textView
        self.model = model
    }

    // MARK: Test-visible lookups

    func frameView(for blockID: String) -> UIView? { frames[blockID] }
    func emojiLabel(for blockID: String) -> UILabel? { emojiLabels[blockID] }
    func commentMark(for blockID: String) -> UIView? { commentMarks[blockID] }

    // MARK: The refresh

    func refresh(scope: MobileTakesChromeController.RefreshScope = .document) {
        guard !refreshing, let textView, let model,
              textView.bounds.width > 0 else { return }
        refreshing = true
        defer { refreshing = false }
        let face = MobileEditorStyle.face
        let inset = textView.textContainerInset
        let containerWidth = textView.textContainer.size.width

        // The band mirrors the takes chrome's exactly (the sibling
        // discipline — one scope law, two controllers): `.edit` unions
        // the edited range into the near band (parity B3's FB2-1 fix —
        // invalidation ∝ viewport + edit, never post length).
        var band: NSRange?
        switch scope {
        case .document:
            lastFullPassWidth = containerWidth
        case .nearViewport, .edit:
            guard containerWidth == lastFullPassWidth else {
                lastFullPassWidth = containerWidth
                break
            }
            band = textView.nearViewportBand()
            if case .edit(let edited) = scope, let near = band {
                band = NSUnionRange(near, edited)
            }
        }
        func near(_ range: NSRange) -> Bool {
            guard let band else { return true }
            return range.location < band.location + band.length
                && band.location < range.location + max(range.length, 1)
        }
        // One index walk for every range (the takes chrome's B3 read).
        let ranges = model.blockRangesByID()

        // 1 — callout frames + emoji (M12; the one-frame rule).
        var framed: Set<String> = []
        var emojiSeen: Set<String> = []
        for slot in model.slots {
            guard let presentation = model.presentations[slot.blockID] else { continue }
            guard let range = ranges[slot.blockID] else { continue }
            let emoji = presentation.emoji ?? ""
            // The reserved leading gap (LK10's mirror corner; B3's
            // band-independent reservation walk — content-derived width,
            // storage-truth gated, no geometry consulted): text on the
            // first line starts after the glyph. The LABEL itself is
            // geometry (made/placed in the banded arm below).
            if !emoji.isEmpty {
                emojiSeen.insert(slot.blockID)
                let width = ceil((emoji as NSString).size(
                    withAttributes: [.font: Self.emojiFont]).width)
                textView.setLeadingFirstLineReservation(
                    width + 8, blockRange: range)
                emojiReservedBlocks.insert(slot.blockID)
            }
            if !near(range), frames[slot.blockID] != nil {
                framed.insert(slot.blockID)
                continue
            }
            guard let union = textView.blockRectsUnion(range: range) else { continue }
            framed.insert(slot.blockID)
            let wash = frames[slot.blockID] ?? makeFrame(blockID: slot.blockID)
            let frame = CGRect(
                x: inset.left + union.minX,
                y: inset.top + union.minY,
                width: union.width,
                height: union.height
            ).insetBy(dx: -8, dy: -4)
            if wash.frame != frame { wash.frame = frame }
            wash.backgroundColor = MobileCallout.color(presentation.color)

            if !emoji.isEmpty, let line = textView.firstLineGeometry(atOffset: range.location) {
                let label = emojiLabels[slot.blockID] ?? makeEmojiLabel(blockID: slot.blockID)
                if label.text != emoji {
                    label.text = emoji
                    label.sizeToFit()
                }
                let origin = CGPoint(
                    x: inset.left + 2,
                    y: inset.top + line.fragmentMinY)
                if label.frame.origin != origin { label.frame.origin = origin }
            }
        }
        for (blockID, wash) in frames where !framed.contains(blockID) {
            wash.removeFromSuperview()
            frames[blockID] = nil
        }
        for (blockID, label) in emojiLabels where !emojiSeen.contains(blockID) {
            label.removeFromSuperview()
            emojiLabels[blockID] = nil
        }
        // A retired emoji's paragraph gives its gap back (a block gone
        // from the surface has no paragraph left to clear).
        for blockID in emojiReservedBlocks.subtracting(emojiSeen) {
            if let range = ranges[blockID] {
                textView.setLeadingFirstLineReservation(0, blockRange: range)
            }
            emojiReservedBlocks.remove(blockID)
        }
        // FIX-B1 road (b), the leading field's twin (the takes chrome's
        // call site has the mechanism): text typed right after a callout
        // block must not inherit its emoji gap.
        if case .edit(let edited) = scope {
            textView.healLeadingReservationResidue(
                in: edited,
                skippingParagraphsAt: Set(emojiSeen.compactMap { ranges[$0]?.location }))
        }

        // 2 — comment markers (●n at the block's last line end).
        var commented: Set<String> = []
        for slot in model.slots where slot.commentCount > 0 {
            guard let range = ranges[slot.blockID] else { continue }
            if !near(range), commentMarks[slot.blockID] != nil {
                commented.insert(slot.blockID)
                continue
            }
            guard let end = textView.lastLineEnd(range: range) else { continue }
            commented.insert(slot.blockID)
            let mark = commentMarks[slot.blockID] ?? makeCommentMark(blockID: slot.blockID)
            let title = "●\(slot.commentCount)"
            if mark.title(for: .normal) != title {
                mark.setTitle(title, for: .normal)
            }
            mark.setTitleColor(face.commentInk, for: .normal)
            mark.titleLabel?.font = face.chrome.withSize(10.5)
            mark.sizeToFit()
            let frame = CGRect(
                x: inset.left + end.x + 3,
                y: inset.top + end.lineMinY,
                width: max(mark.bounds.width, 20),
                height: max(end.lineHeight, 18))
            if mark.frame != frame { mark.frame = frame }
        }
        for (blockID, mark) in commentMarks where !commented.contains(blockID) {
            mark.removeFromSuperview()
            commentMarks[blockID] = nil
        }
    }

    // MARK: View factories

    private func makeFrame(blockID: String) -> UIView {
        let wash = UIView()
        wash.accessibilityIdentifier = "decor.callout.\(blockID)"
        wash.isUserInteractionEnabled = false
        wash.layer.cornerRadius = 10
        wash.clipsToBounds = true
        // Below the text canvas (the peek marker's z-order — the wash
        // tints without veiling glyphs). Behind any peek marker too:
        // index 0 keeps callout under everything.
        textView?.insertSubview(wash, at: 0)
        frames[blockID] = wash
        return wash
    }

    /// The emoji glyph's font — ONE constant for the label AND the
    /// reservation width (B3: the gap is content-derived, so the two
    /// must never disagree).
    static let emojiFont = UIFont.systemFont(ofSize: 13)

    private func makeEmojiLabel(blockID: String) -> UILabel {
        let label = UILabel()
        label.accessibilityIdentifier = "decor.emoji.\(blockID)"
        label.font = Self.emojiFont
        label.isUserInteractionEnabled = false
        textView?.addSubview(label)
        emojiLabels[blockID] = label
        return label
    }

    private func makeCommentMark(blockID: String) -> UIButton {
        let mark = UIButton(type: .custom)
        mark.accessibilityIdentifier = "decor.comments.\(blockID)"
        mark.accessibilityLabel = "Comments"
        mark.accessibilityHint = "Shows this block's comments"
        mark.addAction(
            UIAction { [weak self] _ in self?.model?.openComments(blockID: blockID) },
            for: .touchUpInside)
        textView?.addSubview(mark)
        commentMarks[blockID] = mark
        return mark
    }
}
