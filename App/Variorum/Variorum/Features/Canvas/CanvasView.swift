//
//  CanvasView.swift
//  Variorum
//
//  Phase 11, Step A7 — the sticky-notes canvas (AppSpec §12), pools first.
//  Blocks-as-cards over `canvas_layout`: a drag's END is ONE
//  `setCanvasPosition` (metadata CAS — a two-device race converges to
//  either position, pinned in core); cards render read-cheap;
//  un-positioned cards stack in a default column until first dragged
//  (nothing persisted until the author places them). Layout rows tombstone
//  with their block/container (the A1 triggers).
//
//  Phase 13, Stage C3 (R40) — canvas is a VIEW you open on a post or the
//  scraps (the sidebar door is gone; PostDetailView + PoolDetailView carry
//  the mode). Cards move onto the voice tokens, and fanned cards gain the
//  MINIMAL takes switcher — "see takes" → a small ‹ take k of n › selector
//  that switches THAT block's take one at a time, deliberately the
//  mobile-inheritable pattern (R58's seed). ‹ › = `chooseVariant`
//  (PROVISIONAL reading of R40's "switch that block to another one of its
//  own takes" — an explicit per-block gesture, so I3's deliberate-choice
//  doctrine holds; the view-local-display alternative is recorded —
//  QUESTIONS #28).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class CanvasViewModel {
    @ObservationIgnored let session: AppSession
    let containerID: String

    init(session: AppSession, containerID: String) {
        self.session = session
        self.containerID = containerID
    }

    private(set) var projection = Queries.CanvasProjection()
    /// In-flight drag offsets (view state; the store writes at drag END).
    var dragOffsets: [String: CGSize] = [:]
    private(set) var statusMessage: String?
    /// The pool's tag filter (Phase 11, A8): nil = everything; a tag
    /// filters to `everythingTagged`'s BLOCK semantics, subtree included.
    private(set) var filterTagID: String?
    @ObservationIgnored private(set) var filteredBlockIDs: Set<String>?
    private(set) var allTags: [Tag] = []

    func start() async {
        do {
            for try await value in session.database.observeCanvas(containerID) {
                projection = value
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// Test seam.
    func adopt(_ new: Queries.CanvasProjection) { projection = new }

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

    /// One-shot filter application — exactly `everythingTagged`'s block
    /// half (subtree semantics; pinned).
    func applyFilter(tagID: String?) async {
        filterTagID = tagID
        guard let tagID else {
            filteredBlockIDs = nil
            return
        }
        do {
            let tagged = try await session.database.read { db in
                try Queries.everythingTagged(db, tagID: tagID, includeSubtree: true)
            }
            filteredBlockIDs = Set(tagged.blockIDs)
        } catch {
            statusMessage = String(describing: error)
        }
    }

    /// A card's resting position: the stored one, else the default stack
    /// slot (index-derived, never persisted — the store only learns a
    /// position when the author drags).
    func restingPosition(blockID: String) -> CGPoint {
        if let stored = projection.positions[blockID] {
            return CGPoint(x: stored.x, y: stored.y)
        }
        let index = projection.cards.firstIndex { $0.block.blockID == blockID } ?? 0
        return CGPoint(x: 20, y: 20 + Double(index) * 90)
    }

    /// Drag end → exactly ONE layout op (the A7 pin).
    func dragEnded(blockID: String, translation: CGSize) async {
        let resting = restingPosition(blockID: blockID)
        let x = max(0, resting.x + translation.width)
        let y = max(0, resting.y + translation.height)
        dragOffsets[blockID] = .zero
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                _ = try ops.setCanvasPosition(
                    container: containerID, block: blockID, x: x, y: y)
            }
        } catch {
            statusMessage = TakesViewModel.message(for: error)
        }
    }

    func resetPosition(blockID: String) async {
        statusMessage = nil
        do {
            try await session.runner.run { [containerID] ops in
                try ops.removeCanvasPosition(container: containerID, block: blockID)
            }
        } catch {
            statusMessage = TakesViewModel.message(for: error)
        }
    }

    // MARK: - The minimal takes switcher (Phase 13 C3, R40)

    /// Where the block's RENDERED take sits in its fan: (index, count) —
    /// nil for single-take blocks (no switcher) and for a rendered take
    /// that isn't in the active fan (a fallback state; the switcher then
    /// starts from the front on ›).
    func takePosition(blockID: String) -> (index: Int?, count: Int)? {
        guard let fan = projection.fans[blockID], fan.count > 1 else { return nil }
        let currentID = projection.cards
            .first { $0.block.blockID == blockID }?.block.variantID
        return (fan.firstIndex { $0.id == currentID }, fan.count)
    }

    /// ‹ › — ONE take at a time: `chooseVariant` to the previous/next
    /// ACTIVE take (the deliberate, explicit per-block gesture — I3). Ends
    /// clamp; a sealed post's refusal speaks through the message path.
    func switchTake(blockID: String, delta: Int) async {
        guard let fan = projection.fans[blockID], fan.count > 1 else { return }
        let currentID = projection.cards
            .first { $0.block.blockID == blockID }?.block.variantID
        let target: Int
        if let index = fan.firstIndex(where: { $0.id == currentID }) {
            target = index + delta
        } else {
            // The rendered take fell out of the active fan (fallback
            // display): › enters the fan at its front; ‹ does nothing.
            target = delta > 0 ? 0 : -1
        }
        guard fan.indices.contains(target) else { return }
        statusMessage = nil
        do {
            try await session.runner.run { ops in
                try ops.chooseVariant(blockID, variantID: fan[target].id)
            }
        } catch {
            statusMessage = TakesViewModel.message(for: error)
        }
    }
}

struct CanvasView: View {
    let session: AppSession
    let containerID: String
    @State private var model: CanvasViewModel

    init(session: AppSession, containerID: String, model: CanvasViewModel? = nil) {
        self.session = session
        self.containerID = containerID
        _model = State(initialValue: model
            ?? CanvasViewModel(session: session, containerID: containerID))
    }

    @State private var tagSheetBlock: TagSheetBlock?
    /// C3 (R40): the ONE open takes switcher — minimal by design (opening
    /// another card's closes this one).
    @State private var switcherBlockID: String?
    /// The voice reaches the canvas (optional environment, terminal
    /// fallback — the established pattern).
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    struct TagSheetBlock: Identifiable {
        let id: String
        let preview: String?
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Picker("Filter", selection: Binding(
                    get: { model.filterTagID },
                    set: { tagID in Task { await model.applyFilter(tagID: tagID) } })) {
                    Text("All scraps").tag(String?.none)
                    ForEach(model.allTags, id: \.id) { tag in
                        Text(tag.path).tag(String?.some(tag.id))
                    }
                }
                .fixedSize()
                Spacer()
            }
            .controlSize(.small)
            .padding(6)
            if let status = model.statusMessage {
                Text(status).font(.caption).foregroundStyle(.red).padding(.horizontal, 12)
            }
            ScrollView([.horizontal, .vertical]) {
                ZStack(alignment: .topLeading) {
                    // The board's extent grows with the cards.
                    Color.clear.frame(width: boardSize.width, height: boardSize.height)
                    ForEach(model.visibleCards, id: \.block.placementID) { item in
                        card(item)
                    }
                }
            }
        }
        .background(tokens.room)
        .task { await model.start() }
        .task { await model.startTags() }
        .sheet(item: $tagSheetBlock) { target in
            BlockTagAssignmentSheet(
                session: session, blockID: target.id, preview: target.preview)
        }
    }

    private var boardSize: CGSize {
        var maxX: Double = 600
        var maxY: Double = 400
        for item in model.projection.cards {
            let p = model.restingPosition(blockID: item.block.blockID)
            maxX = max(maxX, p.x + 320)
            maxY = max(maxY, p.y + 160)
        }
        return CGSize(width: maxX, height: maxY)
    }

    private func card(_ item: Queries.PoolItem) -> some View {
        let blockID = item.block.blockID
        let resting = model.restingPosition(blockID: blockID)
        let offset = model.dragOffsets[blockID] ?? .zero
        let hasFan = item.block.hasFan
        return VStack(alignment: .leading, spacing: 4) {
            // Gap slots render gaps, never crash (SyncSpec §5).
            Text(item.block.text?.isEmpty == false ? item.block.text! : "· · ·")
                .font(Font(EditorDocument.baseFont))
                .foregroundStyle(tokens.ink)
                .textSelection(.enabled)
                .lineLimit(8)
            if !item.tagPaths.isEmpty {
                Text(item.tagPaths.joined(separator: " · "))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            if hasFan {
                takesFooter(item: item, blockID: blockID)
            }
        }
        .padding(8)
        .frame(width: 240, alignment: .topLeading)
        .background(tokens.card)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tokens.takeLine, lineWidth: 1))
        .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
        .offset(x: resting.x + offset.width, y: resting.y + offset.height)
        .gesture(
            DragGesture()
                .onChanged { value in
                    model.dragOffsets[blockID] = value.translation
                }
                .onEnded { value in
                    Task {
                        await model.dragEnded(blockID: blockID, translation: value.translation)
                    }
                })
        .contextMenu {
            Button("Tags…") {
                tagSheetBlock = TagSheetBlock(id: blockID, preview: item.block.text)
            }
            Button("Reset position") {
                Task { await model.resetPosition(blockID: blockID) }
            }
        }
    }

    /// R40's MINIMAL takes switcher: "see takes" → ‹ take k of n › — one
    /// at a time, that block only, nothing else of the fan machinery (the
    /// mobile-inheritable pattern).
    @ViewBuilder
    private func takesFooter(item: Queries.PoolItem, blockID: String) -> some View {
        if switcherBlockID == blockID, let position = model.takePosition(blockID: blockID) {
            HStack(spacing: 6) {
                Button("‹") { Task { await model.switchTake(blockID: blockID, delta: -1) } }
                    .disabled((position.index ?? 0) <= 0)
                Text(switcherLabel(item: item, position: position))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Button("›") { Task { await model.switchTake(blockID: blockID, delta: 1) } }
                    .disabled(position.index.map { $0 >= position.count - 1 } ?? false)
                Spacer()
                Button("done") { switcherBlockID = nil }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .controlSize(.mini)
        } else {
            Button("⑂ see takes (\(item.block.activeVariantCount))") {
                switcherBlockID = blockID
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
        }
    }

    private func switcherLabel(
        item: Queries.PoolItem, position: (index: Int?, count: Int)
    ) -> String {
        guard let index = position.index else { return "take — of \(position.count)" }
        let fan = model.projection.fans[item.block.blockID] ?? []
        let label = fan.indices.contains(index) ? fan[index].label : nil
        let name = label.map { " · \($0)" } ?? ""
        return "take \(index + 1) of \(position.count)\(name)"
    }
}


// MARK: - The pool detail's mode switcher (editor | canvas)

/// The pool's two faces (Phase 11, A7/A8): the ordinary detail editor (the
/// ratified Phase 10 shape — a pool is a container; scraps get typed here)
/// and the canvas as its second face.
struct PoolDetailView: View {
    let session: AppSession
    let poolID: String
    /// Stage C: a caret-precise landing (palette/Library block hits).
    var initialBlockID: String? = nil

    enum Mode: String, CaseIterable {
        case scraps = "Scraps"
        case canvas = "Canvas"
    }

    @State private var mode: Mode = .scraps
    @State private var pendingCaret: Int?

    var body: some View {
        VStack(spacing: 0) {
            Picker("Pool mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 220)
            .padding(6)
            Divider()
            switch mode {
            case .scraps:
                EditorView(session: session, postID: poolID, caretSeed: pendingCaret)
                    .id("\(poolID)-caret-\(pendingCaret ?? -1)")
            case .canvas:
                CanvasView(session: session, containerID: poolID)
                    .id("canvas-\(poolID)")
            }
        }
        .onAppear {
            guard let initialBlockID else { return }
            Task {
                // The same landing math as PostDetailView.jump — the
                // block's surface offset seeds the editor's caret.
                let offset: Int? = try? await session.database.read { [poolID] db in
                    let slots = try Queries.renderPost(db, containerID: poolID)
                    guard let i = slots.firstIndex(where: { $0.blockID == initialBlockID })
                    else { return nil }
                    return BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i).location
                }
                if let offset { pendingCaret = offset }
            }
        }
    }
}
