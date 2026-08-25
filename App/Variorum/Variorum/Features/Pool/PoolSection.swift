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

    /// The pool the surfaces show (13b Stage 3, 3D — N19): `pools.first`
    /// alone made every pool but the OLDEST unreachable in the Blocks
    /// area ("tutorial scraps" rendered nowhere on any store with an
    /// older pool). A picker now selects among them; the oldest stays the
    /// default (the pre-13b truth), and a dead selection falls back.
    private(set) var selectedPoolID: String?

    var activePool: Container? {
        pools.first { $0.id == selectedPoolID } ?? pools.first
    }

    /// The picker's door: select a pool and re-observe its items.
    func select(poolID: String) {
        guard selectedPoolID != poolID else { return }
        selectedPoolID = poolID
        let active = activePool?.id
        if active != observedPoolID {
            restartItems(active)
        }
    }

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observePools() {
                pools = value
                // Honors the selection (N19); a selected pool that died
                // falls back to the oldest via `activePool`.
                let active = activePool?.id
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

    // MARK: Delete a scrap (the post-13l polish round, ledger row 4(b))

    /// A successful delete's own words, kept apart from `lastError` so a
    /// receipt is never rendered in the slot errors use (the same split
    /// ledger row 6 gave the tray).
    private(set) var receipt: String?

    /// **Delete the scrap this row is** (her A4 ruling on the walk's P-8).
    ///
    /// The operation is the ordinary `deleteBlock` — so the scrap goes to
    /// the Trash for its 30 days like every other deletion, ⌥⌘Z reverses it
    /// like every other structural act, and the receipt names that road
    /// through the one home rather than in this file's own words.
    ///
    /// **It deletes a BLOCK, never the container.** The #77 fence — no door
    /// may tombstone the scraps area — is kept by construction here: there
    /// is no road from this method to `deleteContainer`.
    func deleteScrap(_ blockID: String) async {
        lastError = nil
        receipt = nil
        do {
            try await session.runner.run { ops in try ops.deleteBlock(blockID) }
            receipt = BlockSelectionCopy.deletedNote(1, home: .pool)
        } catch {
            lastError = DeletionRefusal.words(error, act: .delete)
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

// Batch 12 (Sitting 9): the sidebar `PoolSection` rows RETIRED — her
// ruling ("i don't like seeing the blocks on the side, i think it's way
// too crowded. i think blocks should just be a 4th area"); the Blocks
// AREA (`BlocksAreaView`) is the scraps' home now, and standalone blocks
// are born there. `PoolViewModel` + the drag payload live on unchanged.
