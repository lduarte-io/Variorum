//
//  CanvasViewModel.swift
//  Variorum
//
//  Phase 11, Step A7 — the sticky-notes canvas model (extracted from
//  CanvasView.swift at 13b 4E per P-9: board geometry, text authority,
//  and gesture state were about to triple the file).
//
//  Phase 13b, Stage 4 (4E — N30/S4-7, built to the Batch 4E Phase-1
//  ruling; the record is the plan file's Batch 4E section):
//  - SPREAD-GRID default placement (S4-7a): unpositioned cards derive
//    grid slots in pointer order — the pile dies; nothing persists until
//    a drag (the A7 rule, untouched).
//  - LAZY REALIZATION by pure 2D viewport culling (S4-7b, the ruled
//    model): `realizedCards` filters the ForEach through
//    `CanvasBoardGeometry.realized` — a never-opened long post's mount
//    realizes a viewport-bounded set, independent of post size (P1). The
//    live pane's card and an in-flight drag are exempt (the ring never
//    dies by scrolling).
//  - EDITABLE cards (S4-7c — supersedes R40's arrange-only, her
//    direction): card prose is a PaneSurface pane over THE ONE
//    `PaneTextAuthority` (single post context — the pre-4C identity
//    shape; never a second liveness mechanism). Edits land on the take
//    the card DISPLAYS (the R88 view-local pick) through the per-post
//    autosave. Chosen never moves except through the explicit ✓ (R88
//    untouched). Sealed posts refuse liveness through the authority's
//    sealed gate and refuse edits through the ops layer, spoken;
//    arrangement stays allowed under seal (#18 ratified).
//  - RESIZABLE cards (S4-7d): size is LOCAL view memory (the Phase-1
//    ruling's (b) — canvas_layout has no size home; synced w/h columns
//    are a recorded 13c lockstep input).
//  - CLICK-IN-ORDER (S4-7f): an explicit mode — click cards in sequence,
//    numbered preview, ONE confirm applies the whole reorder through
//    ordinary `reorder` ops under ONE undo compound (⌥⌘Z undoes); cancel
//    inert; unclicked cards keep their relative order after the clicked
//    prefix (the endorsed default).
//  - FIT-ALL (S4-7g): the read-only overview zoom (ruling (c)(1) option
//    (i)) — strictly transient, edit/drag-inert below 1:1; a click
//    returns to 1:1 centered, except in order mode where clicks assign
//    sequence numbers (the γ rider, built).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// The canvas's one observed value (nonisolated — the observation hops
/// executors): the A7 projection plus the container's seal, delivered
/// atomically so liveness gating never races the cards.
nonisolated struct CanvasFace: Equatable, Sendable {
    var projection = Queries.CanvasProjection()
    var sealed = false
}

@MainActor
@Observable
final class CanvasViewModel {
    @ObservationIgnored let session: AppSession
    let containerID: String

    init(session: AppSession, containerID: String) {
        self.session = session
        self.containerID = containerID
        self.forwarder = StatusForwarder(session.status)
        // The coordinator is tracked from birth (edits may land the moment
        // a pane goes live) — the ONE per-post pipeline (N3). 18k C1: taken
        // ONCE, here; it used to be a computed property that acquired again
        // on every read (every projection, keystroke and focus move).
        self.coordinator = session.autosave(forPost: containerID)
        observeCoordinator()
    }

    /// **18k C1 — the ONE release for the ONE acquisition in `init`.** The
    /// instance's death is the only point that runs exactly once per
    /// acquisition: `CanvasView` builds this model eagerly in its `init`
    /// (`State(initialValue:)` evaluates its argument on EVERY re-init and
    /// keeps only the first), so discarded twins acquire too and never see
    /// `onDisappear`. Nothing records through this instance after it dies. A
    /// flush still in flight when it does (teardown's Task holds the
    /// coordinator, not the model) is covered by the session: a dirty
    /// coordinator is never dropped, and the Mac's drop waits for a leaving
    /// savepoint, which flushes first.
    isolated deinit {
        session.releaseAutosave(forPost: containerID)
    }

    private(set) var projection = Queries.CanvasProjection()
    /// The container's seal — panes refuse liveness under it (viewing
    /// isn't authoring); arrangement stays allowed (#18 ratified).
    private(set) var sealed = false
    /// In-flight drag offsets (view state; the store writes at drag END).
    var dragOffsets: [String: CGSize] = [:]
    /// In-flight resize offsets (view state; local memory writes at END).
    var resizeOffsets: [String: CGSize] = [:]
    /// Presentation is the shell's StatusCenter (13b 1b, AD-14); the
    /// property remains the tested truth and forwards on set.
    private(set) var statusMessage: String? {
        didSet {
            // 18i (her R-Q5): the forward carries a KIND, named by the door
            // that is writing and RESET after each delivery — so every bare
            // `statusMessage = …` assignment here (refusals and errors, all
            // of them) is byte-unchanged. The rule lives ONCE, in
            // `StatusForwarder` beside the centre (J30).
            forwarder.deliver(statusMessage)
        }
    }

    /// The one home for the forward's rule (18i — J30).
    @ObservationIgnored private var forwarder: StatusForwarder

    /// A RECEIPT: an act landed, and this says what. Where it shows is her
    /// setting's answer; the words are untouched.
    func showReceipt(_ message: String) {
        forwarder.outgoing = .receipt
        statusMessage = message
    }

    /// The routed commands' speaking surface (fire-and-speak, never dead).
    func refuse(_ message: String) {
        statusMessage = message
    }

    /// The pool's tag filter (Phase 11, A8): nil = everything; a tag
    /// filters to `everythingTagged`'s BLOCK semantics, subtree included.
    private(set) var filterTagID: String?
    @ObservationIgnored private(set) var filteredBlockIDs: Set<String>?
    private(set) var allTags: [Tag] = []

    // MARK: - Lifecycle (observation with the dirty-deferral discipline)

    @ObservationIgnored private var coordinatorToken: UUID?
    @ObservationIgnored private var deferredFace: CanvasFace?

    /// The post's ONE coordinator, held for this model's life (18k C1).
    @ObservationIgnored private let coordinator: AutosaveCoordinator

    private func observeCoordinator() {
        guard coordinatorToken == nil else { return }
        coordinatorToken = coordinator.observe(
            onError: { [weak self] error in
                self?.statusMessage = OpsRefusalCopy.message(for: error)
            },
            onSettled: { [weak self] in self?.settleIfClean() })
    }

    private func settleIfClean() {
        guard !coordinator.isDirty, let deferred = deferredFace else { return }
        deferredFace = nil
        adopt(deferred)
    }

    func start() async {
        do {
            let id = containerID
            for try await face in session.database.observe({ db in
                CanvasFace(
                    projection: try Queries.canvasProjection(db, container: id),
                    sealed: try Queries.containerHeader(db, containerID: id)?.locked == true)
            }) {
                // The buffer is authoritative while dirty (the takes/compare
                // discipline): defer the adopt until the pipeline settles.
                if coordinator.isDirty {
                    deferredFace = face
                } else {
                    adopt(face)
                }
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    func teardown() {
        authority.blur()
        if let coordinatorToken {
            coordinator.stopObserving(coordinatorToken)
            self.coordinatorToken = nil
        }
        let coordinator = coordinator
        Task { await coordinator.flushNow() }
    }

    /// Test seam (kept from A7 — existing pins drive projections through
    /// it; sealed rides the face overload).
    func adopt(_ new: Queries.CanvasProjection) {
        adopt(CanvasFace(projection: new, sealed: sealed))
    }

    func adopt(_ face: CanvasFace) {
        projection = face.projection
        sealed = face.sealed
        // Convergence: every buffer with no pending autosave record has
        // landed — drop it so external edits reach the display.
        authority.settle(isPending: { [coordinator] in coordinator.pending[$0] != nil })
        recomputeSpreadDefaults()
        recull()
    }

    func startTags() async {
        do {
            for try await value in session.database.observeTags() {
                allTags = value
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// The cards the filter shows (unfiltered = the pool verbatim).
    var visibleCards: [Queries.PoolItem] {
        guard let filteredBlockIDs else { return projection.cards }
        return projection.cards.filter { filteredBlockIDs.contains($0.block.blockID) }
    }

    /// The cards the BOARD draws: what the filter shows, minus whatever the
    /// OPEN bank is holding (13e E7). With the bank closed — the default —
    /// this is `visibleCards` verbatim, so the 4E board is byte-unchanged.
    var boardCards: [Queries.PoolItem] {
        guard bankOpen else { return visibleCards }
        return visibleCards.filter { projection.positions[$0.block.blockID] != nil }
    }

    /// One-shot filter application — exactly `everythingTagged`'s block
    /// half (subtree semantics; pinned).
    func applyFilter(tagID: String?) async {
        filterTagID = tagID
        guard let tagID else {
            filteredBlockIDs = nil
            recull()
            return
        }
        do {
            let tagged = try await session.database.read { db in
                try Queries.everythingTagged(db, tagID: tagID, includeSubtree: true)
            }
            filteredBlockIDs = Set(tagged.blockIDs)
            recull()
        } catch {
            statusMessage = String(describing: error)
        }
    }

    // MARK: - Geometry (spread grid + frames + the realized set)

    /// Derived spread-grid slots for the unpositioned cards (pointer
    /// order; recomputed on adopt — never persisted). 4E: replaces the
    /// A7 default stack (x: 20, y: 20 + index*90 — the pile S4-7's
    /// concern named).
    @ObservationIgnored private var spreadDefaults: [String: CGPoint] = [:]

    private func recomputeSpreadDefaults() {
        let positioned = projection.cards.compactMap { item -> CGRect? in
            guard let stored = projection.positions[item.block.blockID] else { return nil }
            return CGRect(origin: CGPoint(x: stored.x, y: stored.y),
                          size: cardSize(blockID: item.block.blockID))
        }
        let unpositioned = projection.cards
            .map(\.block.blockID)
            .filter { projection.positions[$0] == nil }
        let origin = CanvasBoardGeometry.gridOrigin(positionedFrames: positioned)
        let columns = CanvasBoardGeometry.spreadColumns(count: unpositioned.count)
        spreadDefaults = Dictionary(uniqueKeysWithValues: unpositioned.enumerated().map {
            ($1, CanvasBoardGeometry.spreadPosition(index: $0, columns: columns, origin: origin))
        })
    }

    /// A card's resting position: the stored one, else its spread-grid
    /// slot (derived, never persisted — the store only learns a position
    /// when the author drags).
    func restingPosition(blockID: String) -> CGPoint {
        if let stored = projection.positions[blockID] {
            return CGPoint(x: stored.x, y: stored.y)
        }
        return spreadDefaults[blockID] ?? CGPoint(
            x: CanvasBoardGeometry.boardInset, y: CanvasBoardGeometry.boardInset)
    }

    /// Every BOARD card's resting frame (position + size) — the culling
    /// brain's input and fit-all's bounding-box source. Banked cards are
    /// not on the board, so they shape neither its extent nor its zoom.
    var cardFrames: [String: CGRect] {
        Dictionary(uniqueKeysWithValues: boardCards.map { item in
            let id = item.block.blockID
            return (id, CGRect(origin: restingPosition(blockID: id),
                               size: cardSize(blockID: id)))
        })
    }

    /// The scroll geometry's report (content coordinates). Hysteresis:
    /// the realized set recomputes only when the viewport has moved
    /// beyond the re-cull threshold — scrolling never outruns the
    /// culling margin between culls.
    private(set) var visibleRect: CGRect = .zero
    @ObservationIgnored private var lastCullRect: CGRect = .null
    private(set) var realizedIDs: Set<String> = []

    func noteVisibleRect(_ rect: CGRect) {
        visibleRect = rect
        let threshold = CanvasBoardGeometry.recullThreshold
        if lastCullRect.isNull
            || abs(rect.origin.x - lastCullRect.origin.x) > threshold
            || abs(rect.origin.y - lastCullRect.origin.y) > threshold
            || abs(rect.width - lastCullRect.width) > threshold
            || abs(rect.height - lastCullRect.height) > threshold {
            recull()
        }
    }

    private func recull() {
        lastCullRect = effectiveVisibleRect
        realizedIDs = CanvasBoardGeometry.realized(
            frames: cardFrames, visible: effectiveVisibleRect)
    }

    /// Before the first scroll-geometry report lands, cull against a
    /// generous default window — bounded regardless of post size (the
    /// mount must never realize everything while geometry settles).
    private var effectiveVisibleRect: CGRect {
        visibleRect.isEmpty
            ? CGRect(x: 0, y: 0, width: 1600, height: 1200)
            : visibleRect
    }

    /// What the ForEach renders (the 4E realization bound, applied):
    /// the culled set, plus the LIVE pane's card (the ring never dies by
    /// scrolling) and any card mid-drag/mid-resize.
    var realizedCards: [Queries.PoolItem] {
        boardCards.filter { item in
            let id = item.block.blockID
            if realizedIDs.contains(id) { return true }
            if authority.livePane?.blockID == id { return true }
            if let offset = dragOffsets[id], offset != .zero { return true }
            if let offset = resizeOffsets[id], offset != .zero { return true }
            return false
        }
    }

    /// Drag end → exactly ONE layout op (the A7 pin). Coordinates are FREE
    /// (Sitting 9 — the origin clamp removed): negatives are legal stored
    /// positions; the view renders origin-shifted so nothing is ever
    /// walled in at the top-left.
    func dragEnded(blockID: String, translation: CGSize) async {
        let resting = restingPosition(blockID: blockID)
        let x = resting.x + translation.width
        let y = resting.y + translation.height
        dragOffsets[blockID] = .zero
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                _ = try ops.setCanvasPosition(
                    container: containerID, block: blockID, x: x, y: y)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    func resetPosition(blockID: String) async {
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                try ops.removeCanvasPosition(container: containerID, block: blockID)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - The BANK (13e E7 — her sitting Round 2 pick)
    //
    // Her original alternative to the spread grid (S4-7a): *"an explicit
    // drag-in from a scrollable bank of posts when there are many"*. The 4E
    // ruling took the grid and recorded her fork verbatim — the bank
    // returns "as a future FACE on top of culling (a listing of
    // never-positioned cards; culling is needed under it anyway)". This is
    // that face, and the shape is the one that needs NO schema: a card the
    // store has no `canvas_layout` position for IS a banked card. Dragging
    // one out writes its first position (`setCanvasPosition`); dragging one
    // back clears it (`removeCanvasPosition`) — the standing 11a ops, no
    // new rows, nothing to sync that was not already synced.
    //
    // The bank is a FACE, not a mode change: CLOSED (the default) the board
    // is byte-for-byte 4E's, spread grid included, so a never-arranged post
    // still opens to its cards rather than to an empty board — the exact
    // objection that rejected the bank MODEL in 4E. Open, the never-placed
    // cards move into the strip, and click-in-order still reaches them
    // there (the other half of that objection, answered by the γ rider's
    // pattern: a chip click numbers the card).

    /// Open/closed, remembered per canvas — the LOCAL view-memory class
    /// (`viewPicks`/`cardSizes`' shelf: `UserDefaults`, never a row).
    private(set) var bankOpen = false
    private var bankMemoryKey: String { "canvasBankOpen.\(containerID)" }

    /// What the bank holds: the cards the store has no position for.
    /// Order is the post's pointer order (the projection's) — deliberately
    /// NOT a bank order of its own, which would want a persisted home.
    var bankCards: [Queries.PoolItem] {
        visibleCards.filter { projection.positions[$0.block.blockID] == nil }
    }

    /// Is this card in the (open) bank rather than on the board?
    func isBanked(blockID: String) -> Bool {
        bankOpen && projection.positions[blockID] == nil
    }

    func toggleBank() {
        bankOpen.toggle()
        defaults.set(bankOpen, forKey: bankMemoryKey)
        // The board's card set just changed under the culler.
        recull()
    }

    // MARK: The drop decision (one brain, the `visibleRect` precedent)

    /// The bank strip's frame, in the canvas SURFACE space. Reported by the
    /// view exactly as the scroll geometry is (`noteVisibleRect`) — the
    /// decision below is the model's, so no gesture re-derives it.
    private(set) var bankRect: CGRect = .zero
    /// The board's viewport (the ScrollView's frame), same space.
    private(set) var boardViewportRect: CGRect = .zero

    func noteBankRect(_ rect: CGRect) { bankRect = rect }
    func noteBoardViewport(_ rect: CGRect) { boardViewportRect = rect }

    /// Where the board's rendered content starts: FREE movement means
    /// stored coordinates may be negative, so the board draws shifted, with
    /// the leftmost/topmost card at the inset margin.
    var boardOrigin: CGPoint {
        var minX: CGFloat = 0
        var minY: CGFloat = 0
        for frame in cardFrames.values {
            minX = min(minX, frame.minX)
            minY = min(minY, frame.minY)
        }
        return CGPoint(x: minX - CanvasBoardGeometry.boardInset,
                       y: minY - CanvasBoardGeometry.boardInset)
    }

    /// What a drop at this surface point means.
    enum DropTarget: Equatable {
        /// The board, at this point in STORED (canvas_layout) coordinates.
        case board(CGPoint)
        /// The open bank strip.
        case bank
        /// Neither (the top strip, the gap outside both) — the gesture
        /// leaves everything where it was.
        case nowhere
    }

    /// The ONE answer both bank gestures ask (13e E7). The bank is tested
    /// FIRST: a drop on the open strip means "unplace", never a board
    /// coordinate that happens to sit behind it.
    func dropTarget(atSurface point: CGPoint) -> DropTarget {
        if bankOpen, bankRect.contains(point) { return .bank }
        // The OVERVIEW is read- and arrange-INERT below 1:1 (4E's α rider):
        // a drop onto a zoomed-out board is not a placement, so the bank
        // obeys the same rule the board's own cards do.
        guard overviewScale == nil, boardViewportRect.contains(point) else { return .nowhere }
        let origin = visibleRect.isEmpty ? boardOrigin : visibleRect.origin
        return .board(CGPoint(
            x: origin.x + (point.x - boardViewportRect.minX),
            y: origin.y + (point.y - boardViewportRect.minY)))
    }

    /// Drag OUT of the bank: the card's FIRST stored position, at the board
    /// point it was dropped on. One op, exactly like a drag on the board.
    func placeFromBank(blockID: String, at point: CGPoint) async {
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                _ = try ops.setCanvasPosition(
                    container: containerID, block: blockID, x: point.x, y: point.y)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// Drag back INTO the bank (or the card's own door): the position row
    /// tombstones, so the card is "not placed yet" again. Already-banked
    /// cards are a no-op rather than a refusal — the gesture's meaning is
    /// "be in the bank", and it already is (`canvasPositionNotFound` would
    /// be a true statement about rows and a lie about what she did).
    func returnToBank(blockID: String) async {
        dragOffsets[blockID] = .zero
        guard projection.positions[blockID] != nil else { return }
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                try ops.removeCanvasPosition(container: containerID, block: blockID)
            }
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - Card sizes (S4-7d — LOCAL view memory, the Phase-1 ruling)

    /// blockID → the card's size where the author resized it. Persisted
    /// locally per container (the TakesViewMemory class; loaded at init
    /// beside the picks, saved on change). NEVER store rows: canvas_layout
    /// has no size home this batch (synced w/h = a recorded 13c input).
    private(set) var cardSizes: [String: CGSize] = [:]
    private var sizeMemoryKey: String { "canvasSizeMemory.\(containerID)" }

    func cardSize(blockID: String) -> CGSize {
        cardSizes[blockID] ?? CanvasBoardGeometry.defaultCardSize
    }

    func resizeEnded(blockID: String, translation: CGSize) {
        let current = cardSize(blockID: blockID)
        cardSizes[blockID] = CanvasBoardGeometry.clampedSize(
            CGSize(width: current.width + translation.width,
                   height: current.height + translation.height))
        resizeOffsets[blockID] = .zero
        saveSizeMemory()
        recull()
    }

    func resetSize(blockID: String) {
        cardSizes.removeValue(forKey: blockID)
        resizeOffsets.removeValue(forKey: blockID)
        saveSizeMemory()
        recull()
    }

    private func saveSizeMemory() {
        let raw = cardSizes.mapValues { [Double($0.width), Double($0.height)] }
        defaults.set(raw, forKey: sizeMemoryKey)
    }

    // MARK: - The minimal takes switcher (Phase 13 C3, R40 — VIEW-LOCAL
    // per R88: ‹ › changes what the card shows; ✓ is the only chooser)

    /// Per-canvas view picks: blockID → the take this CANVAS shows (never
    /// the post's chosen — R88). Persisted locally per container (the
    /// view-memory class; loaded at init, saved on change).
    private(set) var viewPicks: [String: String] = [:]
    @ObservationIgnored private let defaults: UserDefaults = .standard
    private var memoryKey: String { "canvasViewMemory.\(containerID)" }

    func loadViewMemory() {
        viewPicks = (defaults.dictionary(forKey: memoryKey) as? [String: String]) ?? [:]
        if let raw = defaults.dictionary(forKey: sizeMemoryKey) as? [String: [Double]] {
            cardSizes = raw.compactMapValues { pair in
                pair.count == 2 ? CGSize(width: pair[0], height: pair[1]) : nil
            }
        }
        // 13e E7: the bank's own memory — absent key ⇒ CLOSED (#61(a)).
        bankOpen = defaults.bool(forKey: bankMemoryKey)
    }

    private func saveViewMemory() {
        defaults.set(viewPicks, forKey: memoryKey)
    }

    /// What the card SHOWS: the canvas's own pick where one exists and is
    /// still a live ACTIVE take, else the block's rendered (chosen) text.
    func displayedTake(blockID: String) -> Variant? {
        guard let pick = viewPicks[blockID],
              let fan = projection.fans[blockID],
              let take = fan.first(where: { $0.id == pick })
        else { return nil }
        return take
    }

    /// The card's pane resolution (4E): the R88 pick's fall-through WITH
    /// the live-buffer overlay — the authority's one rule, same as every
    /// pane everywhere (a card can never render staler than its buffer).
    func resolvedCard(item: Queries.PoolItem) -> (variantID: String, text: String)? {
        authority.resolvedText(
            pick: viewPicks[item.block.blockID],
            slot: item.block,
            fan: projection.fans[item.block.blockID])
    }

    /// The differs-from-chosen marker's condition (#28e's recorded cost,
    /// built): the card is viewing something the post doesn't show.
    func viewedDiffersFromChosen(blockID: String) -> Bool {
        guard let viewed = displayedTake(blockID: blockID) else { return false }
        let chosen = projection.cards
            .first { $0.block.blockID == blockID }?.block.variantID
        return viewed.id != chosen
    }

    /// Where the VIEWED take sits in its fan: (index, count) — nil for
    /// single-take blocks (no switcher).
    func takePosition(blockID: String) -> (index: Int?, count: Int)? {
        guard let fan = projection.fans[blockID], fan.count > 1 else { return nil }
        let currentID = displayedTake(blockID: blockID)?.id
            ?? projection.cards.first { $0.block.blockID == blockID }?.block.variantID
        return (fan.firstIndex { $0.id == currentID }, fan.count)
    }

    /// ‹ › — VIEW-LOCAL (R88): one take at a time, this canvas's eyes
    /// only. Ends clamp. Chosen never moves here. 4E: if the stepped
    /// card holds the LIVE ring, the ring follows the card onto the newly
    /// displayed take (the card is the surface; what it shows is what
    /// you edit).
    func switchTake(blockID: String, delta: Int) {
        guard let fan = projection.fans[blockID], fan.count > 1 else { return }
        let currentID = displayedTake(blockID: blockID)?.id
            ?? projection.cards.first { $0.block.blockID == blockID }?.block.variantID
        let target: Int
        if let index = fan.firstIndex(where: { $0.id == currentID }) {
            target = index + delta
        } else {
            // The rendered take fell out of the active fan (fallback
            // display): › enters the fan at its front; ‹ does nothing.
            target = delta > 0 ? 0 : -1
        }
        guard fan.indices.contains(target) else { return }
        viewPicks[blockID] = fan[target].id
        saveViewMemory()
        if authority.livePane?.blockID == blockID {
            focus(blockID: blockID, variantID: fan[target].id)
        }
    }

    /// ✓ — the ONE careful gesture (R88: "it's only chosen if chosen very
    /// carefully"): the viewed take becomes the post's chosen; the pick
    /// clears (viewed == chosen again); a sealed post's refusal speaks.
    func chooseViewedTake(blockID: String) async {
        guard let viewed = displayedTake(blockID: blockID) else { return }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try ops.chooseVariant(blockID, variantID: viewed.id)
            }
            viewPicks.removeValue(forKey: blockID)
            saveViewMemory()
            showReceipt("✓ chosen — the note shows this take everywhere now.")
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    /// 💾 — the canvas arrangement as a LENS (her "the post it notes
    /// should also be savable as a lens, right?" — yes): every live view
    /// pick becomes an explicit lens choice. Posts only (a pool has no
    /// lens home — the door hides there).
    func saveViewPicksAsLens(name: String) async {
        let picks = viewPicks
        statusMessage = nil
        do {
            let lens: Lens = try await session.runner.run { [containerID] ops in
                let lens = try ops.createLens(post: containerID, name: name)
                for (blockID, variantID) in picks.sorted(by: { $0.key < $1.key }) {
                    _ = try ops.setLensChoice(lens: lens.id, block: blockID, variant: variantID)
                }
                return lens
            }
            showReceipt("Saved — “\(lens.name)” remembers this canvas's takes (open it in Lenses).")
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - Editable cards (4E — S4-7c: the one ring reaches the canvas)

    /// THE pane-text/liveness authority — the pre-4C single-post shape
    /// (one container, default context); never a second liveness
    /// mechanism beside it.
    private(set) var authority = PaneTextAuthority()

    func paneKey(blockID: String, variantID: String) -> PaneTextAuthority.PaneKey {
        PaneTextAuthority.PaneKey(
            columnID: "canvas", blockID: blockID, variantID: variantID)
    }

    /// The surface's liveness answer for a card's pane. Sealed posts have
    /// no live pane (viewing isn't authoring); order mode suspends
    /// liveness (clicks assign sequence numbers).
    func isPaneLive(blockID: String, variantID: String) -> Bool {
        !orderMode && authority.isLive(
            paneKey(blockID: blockID, variantID: variantID), sealed: sealed)
    }

    /// A card's click-to-focus: the ONE live ring migrates here (P3). In
    /// order mode clicks are sequence clicks, never focus.
    func focus(blockID: String, variantID: String) {
        guard !orderMode else { return }
        // 18k C5 (KnownIssues row 59): the card she clicked is the note's
        // current block — the fact every writing surface reports through the
        // router, and the one the ⌘K "Block History" row falls through to here
        // (this board's handler takes only ⌘S and the switcher). Reported
        // BEFORE the ring's switch, as the Takes board reports: a click on the
        // card that already holds the ring changes nothing in the authority,
        // but the fact may have moved meanwhile. No caret offset (nil is
        // UNKNOWN, U-20's rule — the memory keeps a known offset for the same
        // block); a canvas caret reporter would be a design act, as Blocks'
        // row records. A scraps-area canvas is not the router's note, and the
        // router ignores it.
        session.commandRouter.noteFocusedBlock(
            blockID, variantID: variantID, postID: containerID)
        switch authority.focus(paneKey(blockID: blockID, variantID: variantID)) {
        case .unchanged:
            return
        case .migrated:
            // Single post context: the leaving pane's text lands through
            // the one per-post pipeline.
            let coordinator = coordinator
            Task { await coordinator.flushNow() }
        }
    }

    func blur() {
        authority.blur()
        let coordinator = coordinator
        Task { await coordinator.flushNow() }
    }

    /// A live pane's keystroke: buffer-authoritative while dirty; the
    /// edit lands on the take the card DISPLAYS (R88 — the view-local
    /// pick), through the per-post autosave.
    func paneEdited(blockID: String, variantID: String, newText: String) {
        let store = storeText(blockID: blockID, variantID: variantID) ?? ""
        let old = authority.text(variantID: variantID, storeText: store)
        let cost = TakeEditCost.utf16Cost(from: old, to: newText)
        guard cost > 0 else { return }
        authority.bufferEdited(variantID: variantID, text: newText)
        coordinator.record(variantID: variantID, text: newText, charDelta: cost)
    }

    private func storeText(blockID: String, variantID: String) -> String? {
        if let take = projection.fans[blockID]?.first(where: { $0.id == variantID }) {
            return take.workingText
        }
        guard let slot = projection.cards.first(where: { $0.block.blockID == blockID })?.block,
              slot.variantID == variantID else { return nil }
        return slot.text
    }

    /// **THE COMMIT DOOR'S PENDING NAME** (13u3 UNIT D — item 14): the top
    /// strip presents it, since this board renders no commit door of its own
    /// (⌘S is its whole commit road).
    var savepointAsk: SavepointNameAsk?

    /// ⌘S — the DOOR. It summons the optional name; ⏎ on the empty field
    /// files what it has always filed. No live pane refuses HERE, before a
    /// field opens over a gesture that cannot land (P-2).
    func askSavepointName() {
        guard let pane = authority.livePane else {
            statusMessage = "Click into a card first — ⌘S commits the take you're editing."
            return
        }
        // 13u3 ladder round 1, R1-3 (the widen): `livePane` is the raw
        // pointer and `focus` has no seal test, so a card clicked under a
        // seal would open a field the filer refuses. Same sentence as the
        // post-⏎ road's.
        guard !sealed else {
            statusMessage = OpsRefusalCopy.message(
                for: OperationError.lockedPost(id: containerID))
            return
        }
        savepointAsk = .naming(variantID: pane.variantID)
    }

    func fileSavepoint(named name: String?) async {
        savepointAsk = nil
        await commitFocusedTake(named: name)
    }

    /// ⌘S in canvas (the Phase-1 ruling's (c)(2) — the 4D compare
    /// precedent, third surface): commit the LIVE pane's take; no focus
    /// speaks instead of guessing.
    func commitFocusedTake(named name: String? = nil) async {
        guard let pane = authority.livePane else {
            statusMessage = "Click into a card first — ⌘S commits the take you're editing."
            return
        }
        await coordinator.flushNow()
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                _ = try ops.commit(pane.variantID, message: name)
            }
            showReceipt(name.map(SavepointNameCopy.filed) ?? SavepointNameCopy.unnamedReceipt)
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - Click-in-order (4E — S4-7f: the ONE spatial→structural door)

    /// The explicit mode: click cards in the order the post should read.
    private(set) var orderMode = false
    /// The pending sequence (blockIDs in click order) — model state, so
    /// derealized cards keep their numbers.
    private(set) var orderSequence: [String] = []

    /// The door refuses honestly under seal (the mode exists to reorder;
    /// `reorder` would refuse at apply — say it at the entrance instead
    /// of after the clicking).
    func enterOrderMode() {
        guard !sealed else {
            statusMessage = "This note is sealed — order stays frozen until it's unsealed."
            return
        }
        blur()  // the ring rests while ordering; clicks mean sequence now
        orderMode = true
        orderSequence = []
    }

    /// Cancel is INERT: no op ran, nothing changed.
    func cancelOrderMode() {
        orderMode = false
        orderSequence = []
    }

    /// A sequence click: appends the card; clicking a numbered card again
    /// removes it (the rest renumber).
    func toggleOrderClick(blockID: String) {
        guard orderMode else { return }
        if let index = orderSequence.firstIndex(of: blockID) {
            orderSequence.remove(at: index)
        } else {
            orderSequence.append(blockID)
        }
    }

    /// The numbered preview: a clicked card's pending sequence number.
    func pendingOrderNumber(blockID: String) -> Int? {
        orderSequence.firstIndex(of: blockID).map { $0 + 1 }
    }

    /// The card's current block ordinal (S4-7e — read-time derived from
    /// pointer order, never stored).
    func currentOrdinal(blockID: String) -> Int? {
        projection.cards.firstIndex { $0.block.blockID == blockID }.map { $0 + 1 }
    }

    /// ONE confirm applies the whole reorder: the clicked cards become the
    /// post's prefix in click order; unclicked cards keep their relative
    /// order after it (the endorsed default). k clicked cards = k ordinary
    /// `reorder` ops under ONE undo compound — ⌥⌘Z restores the old order
    /// whole; a mid-apply refusal unwinds what applied (withCompound's
    /// catch path).
    func applyOrder() async {
        guard orderMode, !orderSequence.isEmpty else {
            cancelOrderMode()
            return
        }
        let sequence = orderSequence
        let stack = session.undoStack
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try stack.withCompound(label: "Order Blocks", operations: ops) {
                    var previous: String?
                    for blockID in sequence {
                        if let previous {
                            try ops.reorder(blockID, to: .after(previous))
                        } else {
                            try ops.reorder(blockID, to: .start)
                        }
                        previous = blockID
                    }
                }
            }
            let count = sequence.count
            showReceipt("Ordered — \(count) card\(count == 1 ? "" : "s") lead the note now (⌥⌘Z undoes).")
            orderMode = false
            orderSequence = []
        } catch {
            statusMessage = OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - Fit-all (4E — S4-7g: the read-only overview zoom)

    /// Non-nil while the overview is active (strictly transient — never
    /// persisted; edit/drag-inert below 1:1 per the ruling's α rider).
    private(set) var overviewScale: CGFloat?

    var overviewActive: Bool { overviewScale != nil }

    enum FitAllOutcome: Equatable {
        /// Nothing to fit (no cards).
        case empty
        /// Everything already fits at 1:1 — just scroll to show it.
        case scroll(to: CGPoint)
        /// The overview engaged at this scale (floor-clamped; below the
        /// floor the overview scrolls for the rest — honest, never a lie
        /// of fit).
        case overview(scale: CGFloat)
    }

    /// The fit-all door: small boards scroll into view at 1:1; larger
    /// boards enter the read-only overview.
    func fitAll(viewport: CGSize) -> FitAllOutcome {
        let frames = cardFrames
        guard !frames.isEmpty else {
            statusMessage = "Nothing to fit — this canvas has no cards."
            return .empty
        }
        let bounds = CanvasBoardGeometry.boundingBox(frames: frames.values)
        let scale = CanvasBoardGeometry.fitScale(bounds: bounds, viewport: viewport)
        if scale >= 1 {
            return .scroll(to: CGPoint(x: bounds.midX, y: bounds.midY))
        }
        blur()  // read-only below 1:1 (the α rider)
        overviewScale = scale
        return .overview(scale: scale)
    }

    /// Leaving the overview: back to 1:1; the view scrolls to center the
    /// clicked card (nil = plain exit).
    func exitOverview() {
        overviewScale = nil
    }

    /// An overview click: in order mode it assigns the sequence number
    /// (the γ rider — "see everything, order by clicking"); otherwise it
    /// returns to 1:1 centered on the clicked card (the caller scrolls).
    /// Returns the 1:1 center point to scroll to, nil when staying.
    func overviewClicked(blockID: String) -> CGPoint? {
        if orderMode {
            toggleOrderClick(blockID: blockID)
            return nil
        }
        exitOverview()
        let frame = CGRect(origin: restingPosition(blockID: blockID),
                           size: cardSize(blockID: blockID))
        return CGPoint(x: frame.midX, y: frame.midY)
    }
}
