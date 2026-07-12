//
//  ReadPostViewModel.swift
//  Variorum
//
//  The read-cheap tier's conductor (Phase 10 Step 2 — P3's workhorse: every
//  unfocused post renders through this, so the focused editor stays the ONE
//  live editor). Renders `Queries.renderPost` projections into a
//  non-editable TK2 text view per the Step 0 decision memo (candidate (b)):
//  the same `EditorDocument` materialization as the live editor — one
//  rendering brain — with Phase 4's read semantics displayed, never
//  re-decided (blank takes render as empty slots; gaps render as gaps and
//  never crash — SyncSpec §5).
//
//  Update discipline: projections apply DIFFERENTIALLY when the block
//  sequence is unchanged (only changed slots' ranges are replaced — the
//  Step 0 measurement pinned that a differential replace preserves an
//  active selection, where a full re-set destroys it); a sequence change
//  (structural op, reorder) re-renders fully. The surface is never edited
//  by the user (non-editable), so the last adopted projection IS the
//  surface text — comparisons are in-memory, zero surface reads (the
//  Step 1 doctrine).
//

import AppKit
import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class ReadPostViewModel {
    @ObservationIgnored let session: AppSession
    let postID: String

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    // MARK: - Observable UI state

    /// Drives the SwiftUI `.frame(height:)` — the view is sized to content
    /// (it lives inside the container's scroll, never its own). The
    /// pre-measurement placeholder is row-sized on purpose: near-zero
    /// heights would let a lazy container realize hundreds of rows into
    /// one viewport before the first measurements land.
    private(set) var contentHeight: CGFloat = 40
    /// The TK2→TK1 canary banner (every read-tier instance is armed — the
    /// Step 0 memo's multiplied-canary-surface obligation).
    private(set) var canaryMessage: String?
    /// Fan badges — on fanned blocks ONLY (AppSpec §12 badge behavior).
    private(set) var badges: [ReadBadge] = []

    struct ReadBadge: Equatable, Identifiable {
        let blockID: String
        let variantCount: Int
        /// Document coordinates (the block's first fragment frame).
        let frame: CGRect
        var id: String { blockID }
    }

    /// The AppKit badge overlay renders through this (overlay views, never
    /// rendering attributes — the Phase 6 memo obligation, same as the
    /// editor's).
    @ObservationIgnored var badgeSink: (([ReadBadge]) -> Void)?

    // MARK: - Internals (never observed)

    @ObservationIgnored private(set) var slots: [Queries.RenderedBlock] = []
    @ObservationIgnored private(set) var index = BlockRangeIndex(entries: [], tailLength: nil)
    @ObservationIgnored private(set) weak var textView: ReadPostTextView?
    @ObservationIgnored private let canary = FallbackCanary()
    @ObservationIgnored private var pendingProjection: [Queries.RenderedBlock]?
    @ObservationIgnored private var loaded = false
    @ObservationIgnored private var lastMeasuredWidth: CGFloat = 0
    /// Test seam (the Step 2 cost assertion): UTF-16 units written to the
    /// surface by differential applies — a one-slot change must cost that
    /// slot, never the document.
    @ObservationIgnored private(set) var differentialUnitsReplaced = 0
    /// Test seam: full re-renders performed (sequence changes only).
    @ObservationIgnored private(set) var fullRenderCount = 0

    // MARK: - Lifecycle

    func attach(textView: ReadPostTextView) {
        self.textView = textView
        canary.onFire = { [weak self] message in self?.canaryMessage = message }
        canary.arm(for: textView)
        if let pending = pendingProjection {
            pendingProjection = nil
            applyProjection(pending)
        }
    }

    func detach() {
        canary.disarm()
        badgeSink = nil
        textView = nil
    }

    /// Runs for the view's lifetime: the post's rendered slots, live.
    /// Bounded by construction — the observation's fetch is one post's
    /// traversal (cost ∝ this post, never the corpus; P1).
    func start() async {
        do {
            for try await value in session.database.observePost(postID) {
                applyProjection(value)
            }
        } catch is CancellationError {
        } catch {
            canaryMessage = "Post observation failed: \(error)"
        }
    }

    // MARK: - Projection → surface

    /// Internal so tests drive projections deterministically.
    func applyProjection(_ new: [Queries.RenderedBlock]) {
        guard textView != nil else {
            pendingProjection = new
            return
        }
        if loaded,
           new.count == slots.count,
           zip(new, slots).allSatisfy({ $0.blockID == $1.blockID && $0.variantID == $1.variantID }) {
            applyDifferential(new)
        } else {
            renderFull(new)
            loaded = true
        }
    }

    /// Same slot sequence, possibly different texts: replace only the
    /// changed slots' ranges, last-to-first so earlier ranges stay valid.
    /// The comparison is in-memory (the last adopted projection IS the
    /// surface — non-editable); NSTextView adjusts an active selection
    /// across the replacement, which is the pinned selection-survival
    /// behavior.
    private func applyDifferential(_ new: [Queries.RenderedBlock]) {
        guard let storage = textView?.textStorage else { return }
        var edited = false
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            guard newText != (slots[i].text ?? "") else { continue }
            let range = index.range(ofEntryAt: i)
            guard range.upperBound <= storage.length else {
                renderFull(new)  // never out-of-bounds; heal from the store
                return
            }
            storage.beginEditing()
            storage.replaceCharacters(in: range, with: newText)
            var attributes: [NSAttributedString.Key: Any] = [.font: EditorDocument.baseFont]
            attributes[EditorDocument.blockIDAttribute] = new[i].blockID
            storage.setAttributes(
                attributes,
                range: NSRange(location: range.location, length: (newText as NSString).length))
            storage.endEditing()
            differentialUnitsReplaced += range.length + (newText as NSString).length
            edited = true
        }
        index = BlockRangeIndex(slots: new, tail: nil)
        slots = new
        if edited { remeasure() } else { refreshBadges() }
    }

    private func renderFull(_ new: [Queries.RenderedBlock]) {
        guard let textView, let storage = textView.textStorage else { return }
        fullRenderCount += 1
        let (attributed, newIndex) = EditorDocument.materialize(new, tail: nil)
        storage.setAttributedString(attributed)
        index = newIndex
        slots = new
        remeasure()
    }

    // MARK: - Geometry (height + badges)

    /// Lays out and publishes the content height; cost ∝ this post's own
    /// size (the Step 0 memo's accepted cost model — measured 0.35 ms for
    /// a typical post, 2.6 ms for a 50-block one).
    func remeasure() {
        guard let textView, let layoutManager = textView.textLayoutManager else { return }
        layoutManager.ensureLayout(for: layoutManager.documentRange)
        let height = layoutManager.usageBoundsForTextContainer.height
            + textView.textContainerInset.height * 2
        lastMeasuredWidth = textView.bounds.width
        if abs(contentHeight - max(height, 1)) > 0.5 {
            contentHeight = max(height, 1)
        }
        refreshBadges()
    }

    /// Re-measures when the container reflowed the view's width (the
    /// height depends on wrapping).
    func viewWidthChanged() {
        guard let textView, textView.bounds.width != lastMeasuredWidth else { return }
        remeasure()
    }

    /// Badges for fanned blocks — the whole post (a read view is fully laid
    /// out by construction; fans are opt-in and rare, so this walk is
    /// ∝ fanned blocks).
    private func refreshBadges() {
        guard let textView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else {
            if !badges.isEmpty { badges = [] }
            badgeSink?([])
            return
        }
        // Container→view conversion (the Step 8 traced mechanism, shared
        // with the editor's overlays): fragment frames are
        // container-relative; the badge buttons live in the view.
        let origin = textView.textContainerOrigin
        var result: [ReadBadge] = []
        for (i, slot) in slots.enumerated() where slot.hasFan {
            guard i < index.entries.count else { break }
            let range = index.range(ofEntryAt: i)
            guard let location = contentManager.location(
                contentManager.documentRange.location, offsetBy: range.location)
            else { continue }
            var frame: CGRect?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) { fragment in
                frame = fragment.layoutFragmentFrame
                return false
            }
            if let frame {
                result.append(ReadBadge(
                    blockID: slot.blockID,
                    variantCount: slot.activeVariantCount,
                    frame: frame.offsetBy(dx: origin.x, dy: origin.y)))
            }
        }
        if result != badges {
            badges = result
            badgeSink?(result)
        }
    }

    /// The surface's plain text — test convenience.
    var documentText: String { textView?.string ?? "" }
}
