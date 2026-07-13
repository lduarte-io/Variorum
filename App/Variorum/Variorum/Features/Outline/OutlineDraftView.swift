//
//  OutlineDraftView.swift
//  Variorum
//
//  Phase 11, Step A5 — outline-left / draft-right (AppSpec §12): outline
//  items map via `derived_from` to the blocks they BECAME —
//  `Queries.derivedBlocks`, rendered verbatim (the mapping is the CTE's,
//  never re-derived view-side). Independent or TRACKED scroll (clicking an
//  outline item scrolls the draft to its first derived block); connector
//  polish stays deferred (the standing §13 note). Functional, unstyled.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// The observed value (nonisolated — the observation hops executors).
nonisolated struct OutlineDraftProjection: Equatable, Sendable {
    var outlineSlots: [Queries.RenderedBlock] = []
    var draftSlots: [Queries.RenderedBlock] = []
    /// outline block → the draft blocks derived from it, in the CTE's
    /// (depth, id) order.
    var mapping: [String: [String]] = [:]
    var outlineTitle: String?
}

@MainActor
@Observable
final class OutlineDraftViewModel {
    @ObservationIgnored let session: AppSession
    /// The DRAFT is the opened post; the outline is picked.
    let draftPostID: String

    init(session: AppSession, draftPostID: String) {
        self.session = session
        self.draftPostID = draftPostID
    }

    private(set) var projection = OutlineDraftProjection()
    private(set) var candidates: [Queries.TimelineItem] = []
    private(set) var statusMessage: String?
    var outlinePostID: String? {
        didSet { restartObservation() }
    }
    /// Which outline block is selected (highlights its derived blocks).
    private(set) var selectedOutlineBlock: String?
    var trackedScroll = true

    @ObservationIgnored private var observation: Task<Void, Never>?

    func start() async {
        do {
            let draftID = draftPostID
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: 100
            ) {
                candidates = items.filter { $0.postID != draftID }
            }
        } catch is CancellationError {
        } catch {
            statusMessage = String(describing: error)
        }
    }

    private func restartObservation() {
        observation?.cancel()
        selectedOutlineBlock = nil
        guard let outlineID = outlinePostID else {
            projection = OutlineDraftProjection()
            return
        }
        let draftID = draftPostID
        observation = Task { [session] in
            do {
                for try await value in session.database.observe({ db -> OutlineDraftProjection in
                    let outlineSlots = try Queries.renderPost(db, containerID: outlineID)
                    let draftSlots = try Queries.renderPost(db, containerID: draftID)
                    var mapping: [String: [String]] = [:]
                    for slot in outlineSlots where !slot.isGap {
                        // The CTE, verbatim — the view never re-derives.
                        mapping[slot.blockID] = try Queries.derivedBlocks(
                            db, fromOutlineBlock: slot.blockID, inContainer: draftID)
                            .map(\.blockID)
                    }
                    let title = try String.fetchOne(
                        db, sql: "SELECT title FROM container WHERE id = ?",
                        arguments: [outlineID])
                    return OutlineDraftProjection(
                        outlineSlots: outlineSlots, draftSlots: draftSlots,
                        mapping: mapping, outlineTitle: title)
                }) {
                    self.projection = value
                }
            } catch is CancellationError {
            } catch {
                self.statusMessage = String(describing: error)
            }
        }
    }

    func teardown() {
        observation?.cancel()
    }

    func selectOutlineBlock(_ blockID: String) {
        selectedOutlineBlock = blockID
    }

    /// The draft blocks the selected outline item became.
    var highlightedDraftBlocks: Set<String> {
        guard let selected = selectedOutlineBlock else { return [] }
        return Set(projection.mapping[selected] ?? [])
    }

    /// The tracked scroll's landing (the first derived block, CTE order).
    var scrollTarget: String? {
        guard trackedScroll, let selected = selectedOutlineBlock else { return nil }
        return projection.mapping[selected]?.first
    }
}

struct OutlineDraftView: View {
    let session: AppSession
    let draftPostID: String
    @State private var model: OutlineDraftViewModel

    init(session: AppSession, draftPostID: String, model: OutlineDraftViewModel? = nil) {
        self.session = session
        self.draftPostID = draftPostID
        _model = State(initialValue: model
            ?? OutlineDraftViewModel(session: session, draftPostID: draftPostID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let status = model.statusMessage {
                Text(status).font(.caption).foregroundStyle(.red).padding(.horizontal, 12)
            }
            if model.outlinePostID == nil {
                Spacer()
                Text("Pick the outline post — its items map to the draft blocks they became.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                columns
            }
        }
        .task { await model.start() }
        .onDisappear { model.teardown() }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Picker("Outline", selection: $model.outlinePostID) {
                Text("Choose the outline…").tag(String?.none)
                ForEach(model.candidates, id: \.postID) { item in
                    Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                        .tag(String?.some(item.postID))
                }
            }
            .fixedSize()
            Toggle("Tracked scroll", isOn: $model.trackedScroll)
                .toggleStyle(.checkbox)
                .help("Clicking an outline item scrolls the draft to what it became")
            Spacer()
        }
        .controlSize(.small)
        .padding(8)
    }

    private var columns: some View {
        HStack(alignment: .top, spacing: 0) {
            // Outline (left): compact rows; click maps.
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    Text(model.projection.outlineTitle ?? "Outline")
                        .font(.caption.weight(.semibold))
                    ForEach(model.projection.outlineSlots, id: \.placementID) { slot in
                        outlineRow(slot)
                    }
                }
                .padding(8)
            }
            .frame(width: 280)
            Divider()
            // Draft (right): the post's blocks, derived ones highlighted.
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(model.projection.draftSlots, id: \.placementID) { slot in
                            draftRow(slot)
                                .id("draft-\(slot.blockID)")
                        }
                    }
                    .padding(8)
                }
                .onChange(of: model.scrollTarget) { _, target in
                    if let target {
                        withAnimation { proxy.scrollTo("draft-\(target)", anchor: .top) }
                    }
                }
            }
        }
    }

    private func outlineRow(_ slot: Queries.RenderedBlock) -> some View {
        let derivedCount = model.projection.mapping[slot.blockID]?.count ?? 0
        let selected = model.selectedOutlineBlock == slot.blockID
        return Button {
            model.selectOutlineBlock(slot.blockID)
        } label: {
            HStack(alignment: .top, spacing: 6) {
                Text(slot.text?.isEmpty == false
                     ? String(slot.text!.prefix(120))
                     : "· · ·")
                    .font(.callout)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                Spacer()
                if derivedCount > 0 {
                    Text("→\(derivedCount)")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                } else {
                    Text("→0")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(6)
            .background(selected ? Color.accentColor.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }

    private func draftRow(_ slot: Queries.RenderedBlock) -> some View {
        let highlighted = model.highlightedDraftBlocks.contains(slot.blockID)
        return Text(slot.text ?? "· · ·")
            .textSelection(.enabled)
            .font(Font(EditorDocument.baseFont))
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(6)
            .background(highlighted ? Color.accentColor.opacity(0.14) : Color.gray.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
