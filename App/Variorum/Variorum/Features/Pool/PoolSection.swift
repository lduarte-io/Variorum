//
//  PoolSection.swift
//  Variorum
//
//  The minimal pool (Phase 10 Step 7, ratified scope: listing +
//  drag-into-draft), living in the sidebar per interpretation 3
//  (PROVISIONAL) — the pool and the draft must be VISIBLE TOGETHER for the
//  drag to mean anything. Dragging a scrap into an editor lands as EXACTLY
//  `poolDragCopy` (lineage edge `pool_copy`; ⌥ carries the whole fan); the
//  drag payload is the block ID and nothing else. Opening the pool shows
//  it in the detail editor — a pool is a container and renders/edits like
//  one (one traversal, never a bespoke subsystem); that is also how scraps
//  are typed in until Phase 11's fuller pool.
//

import AppKit
import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

@MainActor
@Observable
final class PoolViewModel {
    @ObservationIgnored private let session: AppSession

    private(set) var pools: [Container] = []
    private(set) var items: [Queries.PoolItem] = []
    private(set) var lastError: String?
    @ObservationIgnored private var itemsTask: Task<Void, Never>?
    @ObservationIgnored private var observedPoolID: String?

    /// THE pool (CoreDescription's singular; the schema allows several —
    /// the section shows the oldest, the fuller pool is Phase 11's).
    var activePool: Container? { pools.first }

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observePools() {
                pools = value
                let active = value.first?.id
                if active != observedPoolID {
                    restartItems(active)
                }
            }
        } catch is CancellationError {
            itemsTask?.cancel()
        } catch {
            lastError = String(describing: error)
        }
    }

    private func restartItems(_ poolID: String?) {
        itemsTask?.cancel()
        observedPoolID = poolID
        items = []
        guard let poolID else { return }
        itemsTask = Task { [session, weak self] in
            do {
                for try await value in session.database.observePool(poolID) {
                    self?.items = value
                }
            } catch is CancellationError {
            } catch {
                self?.lastError = String(describing: error)
            }
        }
    }

    /// Internal so tests drive listings deterministically.
    func adopt(pools: [Container], items: [Queries.PoolItem]) {
        self.pools = pools
        self.items = items
    }

    @discardableResult
    func createPool() async -> String? {
        do {
            let pool = try await session.runner.run { ops in
                try ops.createPool(title: "Pool")
            }
            return pool.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// The drag payload: the pool block's ID, under the custom type — the
    /// text itself never rides the pasteboard (review focus 6: the copy is
    /// the operation's, at the drop).
    nonisolated static func dragProvider(blockID: String) -> NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(
            forTypeIdentifier: EditorTextView.poolBlockType.rawValue,
            visibility: .all
        ) { completion in
            completion(Data(blockID.utf8), nil)
            return nil
        }
        return provider
    }
}

struct PoolSection: View {
    let model: PoolViewModel
    /// Opens the pool container in the detail editor.
    var openPool: (String) -> Void

    var body: some View {
        Section("Pool") {
            if let pool = model.activePool {
                ForEach(model.items, id: \.block.blockID) { item in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(preview(item))
                            .lineLimit(2)
                        if !item.tagPaths.isEmpty {
                            Text(item.tagPaths.joined(separator: " · "))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDrag { PoolViewModel.dragProvider(blockID: item.block.blockID) }
                }
                if model.items.isEmpty {
                    Text("No scraps yet — open the pool and type some.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button("Open Pool") { openPool(pool.id) }
                    .buttonStyle(.borderless)
                    .font(.caption)
            } else {
                Button("Create Pool") {
                    Task {
                        if let id = await model.createPool() { openPool(id) }
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption)
            }
        }
    }

    private func preview(_ item: Queries.PoolItem) -> String {
        let text = item.block.text ?? ""
        return text.isEmpty ? "(empty scrap)" : text
    }
}
