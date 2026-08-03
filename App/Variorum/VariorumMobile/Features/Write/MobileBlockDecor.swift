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
//    block's first line — LK10's exclusion mechanism at the mirror corner
//    (the ratified mockup draws the glyph before the first words), so
//    text never runs under it.
//  - THE COMMENT MARKER (M12; the mockup's ●n form): a commented block
//    wears a small ●n at the end of its LAST line; tapping it opens the
//    block's comments sheet (the badge-tap grammar).
//
//  Exclusion composition: `textContainer.exclusionPaths` is ONE container
//  property, owned by the takes chrome's assembly — this controller only
//  PUBLISHES its emoji gutters (`currentEmojiExclusions`); the chrome
//  unions them in. `MobileEditorTextView.refreshChrome` runs the decor
//  FIRST for exactly that reason.
//
//  Geometry discipline is the chrome's own: equality-gated writes, the
//  near-viewport band on scroll ticks (the S2 MINOR-3 scope law), cost ∝
//  the post's framed/commented blocks on content axes.
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
    /// The emoji gutters for the chrome's ONE exclusion assembly
    /// (container coordinates).
    private(set) var currentEmojiExclusions: [CGRect] = []
    private var emojiExclusionByBlock: [String: CGRect] = [:]
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

        var band: NSRange?
        if scope == .nearViewport, containerWidth == lastFullPassWidth {
            band = textView.nearViewportBand()
        } else {
            lastFullPassWidth = containerWidth
        }
        func near(_ range: NSRange) -> Bool {
            guard let band else { return true }
            return range.location < band.location + band.length
                && band.location < range.location + max(range.length, 1)
        }

        // 1 — callout frames + emoji (M12; the one-frame rule).
        var framed: Set<String> = []
        var emojiExclusions: [CGRect] = []
        var emojiSeen: Set<String> = []
        for slot in model.slots {
            guard let presentation = model.presentations[slot.blockID] else { continue }
            guard let range = model.rangeOfBlock(slot.blockID) else { continue }
            let emoji = presentation.emoji ?? ""
            if !near(range), frames[slot.blockID] != nil {
                framed.insert(slot.blockID)
                if !emoji.isEmpty, let cached = emojiExclusionByBlock[slot.blockID] {
                    emojiSeen.insert(slot.blockID)
                    emojiExclusions.append(cached)
                }
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
                emojiSeen.insert(slot.blockID)
                let label = emojiLabels[slot.blockID] ?? makeEmojiLabel(blockID: slot.blockID)
                if label.text != emoji {
                    label.text = emoji
                    label.sizeToFit()
                }
                // The reserved leading gap (the LK10 mechanism, mirrored):
                // text on the first line starts after the glyph.
                let gutterWidth = label.bounds.width + 8
                let gutter = CGRect(
                    x: 0, y: line.fragmentMinY,
                    width: gutterWidth, height: line.firstLineHeight)
                emojiExclusionByBlock[slot.blockID] = gutter
                emojiExclusions.append(gutter)
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
            emojiExclusionByBlock[blockID] = nil
        }
        emojiExclusions.sort { ($0.minY, $0.minX) < ($1.minY, $1.minX) }
        currentEmojiExclusions = emojiExclusions

        // 2 — comment markers (●n at the block's last line end).
        var commented: Set<String> = []
        for slot in model.slots where slot.commentCount > 0 {
            guard let range = model.rangeOfBlock(slot.blockID) else { continue }
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

    private func makeEmojiLabel(blockID: String) -> UILabel {
        let label = UILabel()
        label.accessibilityIdentifier = "decor.emoji.\(blockID)"
        label.font = .systemFont(ofSize: 13)
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
