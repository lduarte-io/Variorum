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

    /// VX-82: the host's "this surface now shows its note" door — the
    /// inline editor's VX-75 announce, mirrored (`InlineEditorSurface.
    /// Coordinator.onShowing`): fired ONCE, by the first height report made
    /// after the surface rendered real content (`loaded`), so the host's
    /// release of whatever it was holding across the swap (the book
    /// Outline's outgoing live editor) lands in the same turn as the
    /// height. nil everywhere a host holds nothing — behaviour unchanged.
    @ObservationIgnored var onShowing: (() -> Void)?
    @ObservationIgnored private var announcedShowing = false

    /// Phase 13 C1 — the read tier renders the same decoration language as
    /// the editor (callouts, seams, read-only comment cards) through the
    /// shared controller; no indicator (no caret), no handles (no doors).
    @ObservationIgnored var decorSink: ((BlockDecor.State) -> Void)?
    @ObservationIgnored private var lastDecorState = BlockDecor.State()
    /// Theme context, pushed by the View.
    var appearance = EditorAppearance() {
        didSet { if oldValue != appearance { refreshDecor() } }
    }
    @ObservationIgnored private(set) var presentationsByBlock: [String: BlockPresentation] = [:]
    @ObservationIgnored private(set) var commentsByBlock: [String: [BlockDecor.CommentBrief]] = [:]

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
        onShowing = nil
        textView = nil
        // A dismantle→remake cycle on the SAME model (SwiftUI recreates
        // representables on container moves) must re-render the fresh,
        // EMPTY surface: with `loaded`/`slots` kept, the next projection
        // equals the stale slots, the differential finds nothing to
        // replace, and the view stays permanently blank (review round 1,
        // MINOR 4). Reset so the next attach renders fully.
        loaded = false
        slots = []
        index = BlockRangeIndex(entries: [], tailLength: nil)
        // VX-82: a remade surface announces again once it renders — the
        // host's flag is idempotent, a missed announce would strand it.
        announcedShowing = false
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
            canaryMessage = "Note observation failed: \(error)"
        }
    }

    /// The decoration context, live (Phase 13 C1) — one small per-post
    /// fetch; runs beside `start()` for the surface's lifetime.
    func startDecorContext() async {
        do {
            for try await value in session.database.observe({ [postID] db in
                DecorContext(
                    presentations: try Queries.blockPresentations(db, containerID: postID),
                    comments: try Queries.containerComments(db, containerID: postID)
                        .mapValues { comments in
                            comments.map { BlockDecor.CommentBrief(id: $0.id, text: $0.text) }
                        })
            }) {
                adoptDecorContext(value)
            }
        } catch is CancellationError {
        } catch {
            canaryMessage = "Decoration observation failed: \(error)"
        }
    }

    nonisolated struct DecorContext: Equatable, Sendable {
        var presentations: [String: BlockPresentation] = [:]
        var comments: [String: [BlockDecor.CommentBrief]] = [:]
    }

    /// Internal so tests drive the context without observations.
    func adoptDecorContext(_ context: DecorContext) {
        presentationsByBlock = context.presentations
        commentsByBlock = context.comments
        refreshDecor()
    }

    /// A freshly-wired overlay host gets the CURRENT state (Stage 2
    /// ladder, MAJOR-C — the starved-host class, read-tier edition): the
    /// editor's walk fix landed only in `EditorViewModel`'s
    /// convenience-init path, while this model wires its sinks through the
    /// controller's designated init with no push — and on the
    /// dismantle→remake cycle `detach()` already documents, the remade
    /// surface recomputes a decor state EQUAL to the stale
    /// `lastDecorState` (same content, same width), so the equality gate
    /// starved the fresh controller: no callouts/comments/seams — and,
    /// same gate one field over, no ⑂ badges — until the next real
    /// change. Wiring is a delivery: badges push from stored state, the
    /// decor gate re-arms and recomputes. The coordinator calls this as
    /// `install`'s last act, after both sinks exist.
    func pushOverlaysToSinks() {
        badgeSink?(badges)
        lastDecorState = BlockDecor.State()
        refreshDecor()
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
        // ONE tiling walk (13u1 UNIT 1 — P17's third site). The text
        // inequality above it kept this at O(N × changedSlots) rather than
        // the editors' full Σi, which is why the sweep rated it lower — but
        // a sync pull landing many of one note's slots at once makes
        // changedSlots ≈ N and the term is quadratic again. Correct BEFORE
        // the loop for the same reason as the editor's twin: the walk
        // descends, so no replacement can move a lower entry's prefix sum.
        let ranges = index.entryRanges()
        for i in stride(from: new.count - 1, through: 0, by: -1) {
            let newText = new[i].text ?? ""
            guard newText != (slots[i].text ?? "") else { continue }
            let range = ranges[i]
            guard range.upperBound <= storage.length else {
                renderFull(new)  // never out-of-bounds; heal from the store
                return
            }
            storage.beginEditing()
            storage.replaceCharacters(in: range, with: newText)
            var attributes = EditorDocument.baseAttributes
            attributes[EditorDocument.blockIDAttribute] = new[i].blockID
            let replaced = NSRange(
                location: range.location, length: (newText as NSString).length)
            storage.setAttributes(attributes, range: replaced)
            // 13g batch 2 (L7): the reset above drops the markdown face over
            // the replaced slot — re-derive it, lines-scoped. The read-cheap
            // tier wears the SAME dimmed-marker face as the editors (F-5's
            // surface rule: its click seeds a caret offset, so display must
            // equal stored here too).
            MarkdownStyling.restyle(storage, range: replaced)
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
    /// a typical post, 2.6 ms for a 50-block one). The formula is the ONE
    /// measurement brain (13b 1a — this was one of three private copies).
    func remeasure() {
        guard let textView else { return }
        let height = PaneMeasurement.height(of: textView)
        // 13u3 UNIT A1: the MEASURE is the prose container's width, not the
        // view's frame — the frame now spans the host's whole pane while the
        // column is capped, and only the column can change the wrapping.
        lastMeasuredWidth = max(0, textView.proseRight - textView.proseLeft)
        if abs(contentHeight - max(height, 1)) > 0.5 {
            contentHeight = max(height, 1)
        }
        // VX-82: the first report measured off real content is the announce
        // (the inline editor's exact rule — `loaded` flips in
        // `applyProjection`, and `renderFull` calls this synchronously, so
        // the height write and the host's release share one turn).
        if loaded, !announcedShowing {
            announcedShowing = true
            onShowing?()
        }
        refreshBadges()
    }

    /// Re-measures when the container reflowed the prose column's WIDTH (the
    /// height depends on wrapping, and nothing else here does).
    func viewWidthChanged() {
        guard let textView else { return }
        let column = max(0, textView.proseRight - textView.proseLeft)
        guard abs(column - lastMeasuredWidth) > 0.5 else { return }
        remeasure()
    }

    /// **THE PROSE COLUMN MOVED WITHOUT ITS WIDTH CHANGING** (13u3 UNIT A1 —
    /// the gutter grew or shrank around an unchanged measure, which is what
    /// a window resize does to a capped column). Every decoration's rect is
    /// computed from `textLeft`, so the badges and the decoration state are
    /// re-read against the new edge; nothing re-wrapped, so no height is
    /// measured and no layout is asked for.
    ///
    /// *(It replaces 17p batch b's door of the same name, which existed
    /// because the decoration LANE moved the container under a fixed frame.
    /// The lane is retired — a decoration cannot move this column at all
    /// now — and what is left is the honest other half: the frame moved and
    /// the column did not.)*
    func proseColumnDidChange() {
        refreshBadges()
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
        // ONE tiling walk (13u1 UNIT 1 — the editor badge pass's twin).
        let ranges = index.entryRanges()
        for (i, slot) in slots.enumerated() where slot.hasFan {
            guard i < ranges.count else { break }
            let range = ranges[i]
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
        refreshDecor()
    }

    /// The read tier's decoration pass (Phase 13 C1): whole-post frames —
    /// a read view is fully laid out by construction, and the walk runs
    /// only when something is decorated (calm default costs nothing).
    func refreshDecor() {
        func send(_ state: BlockDecor.State) {
            if state != lastDecorState {
                lastDecorState = state
                decorSink?(state)
            }
        }
        let needsFrames = appearance.seamsVisible
            || !presentationsByBlock.isEmpty
            || !commentsByBlock.isEmpty
        guard needsFrames, let textView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager,
              !index.entries.isEmpty
        else {
            send(BlockDecor.State())
            return
        }
        let origin = textView.textContainerOrigin
        let docStart = contentManager.documentRange.location

        // 13c 1A (A40) — the read tier is the SECOND host of the same
        // mis-mapping (class sweep): the fragment's TEXT rect, never its
        // frame (`BlockDecor.textBottom` carries the traced mechanism).
        func fragmentFrame(atOffset offset: Int) -> CGRect? {
            guard let location = contentManager.location(docStart, offsetBy: offset)
            else { return nil }
            var frame: CGRect?
            layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                frame = BlockDecor.textRect(of: $0)
                return false
            }
            return frame
        }

        var frames: [BlockDecor.Frame] = []
        var location = 0
        for (i, entry) in index.entries.enumerated() {
            defer { location += entry.length + 1 }
            guard let first = fragmentFrame(atOffset: location),
                  let last = fragmentFrame(atOffset: max(location, location + entry.length - 1))
            else { continue }
            frames.append(BlockDecor.Frame(
                entryIndex: i, blockID: entry.blockID,
                frame: BlockTint.viewRect(
                    containerTop: min(first.minY, last.minY),
                    containerBottom: max(first.maxY, last.maxY),
                    containerOrigin: origin,
                    viewWidth: textView.bounds.width)))
        }
        // Read tier: no caret (no indicator), no drop door (no handles) —
        // the controller's nil doors keep those dark.
        var readAppearance = appearance
        readAppearance.indicator = .off
        send(BlockDecor.State(
            frames: frames,
            fannedBlockIDs: Set(slots.filter(\.hasFan).map(\.blockID)),
            appearance: readAppearance,
            caretBlockID: nil,
            presentations: presentationsByBlock,
            comments: commentsByBlock,
            // 17p batch b (rows 5–6): ONE derivation for the prose column
            // (`PaneTextView.proseLeft`/`proseRight`) — identical to the
            // arithmetic that stood here on a surface with no decoration
            // lane, and the only correct answer once this surface reserves
            // one (the read tier is a CONTAINED surface: the walk found its
            // badge on the words in the book Outline).
            textLeft: textView.proseLeft,
            textRight: textView.proseRight,
            viewWidth: textView.bounds.width,
            entryCount: index.entries.count))
    }

    /// The surface's plain text — test convenience.
    var documentText: String { textView?.string ?? "" }
}
