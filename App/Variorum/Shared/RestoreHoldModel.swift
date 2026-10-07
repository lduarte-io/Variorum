//
//  RestoreHoldModel.swift
//  Variorum (shared — the restore-hold's observable face-state; the Mac's
//  banner renders it, `SyncSession.roundsHeld` reads it)
//
//  Phase 13x, U2 row 7 — THE LANDING STATE's brain (round 3, ruled on
//  BOTH doors): the hold is the `LibraryRestoreHold` marker beside the
//  store; this model is its MainActor projection — refreshed at every
//  ready (the composition root's `.task` re-runs after each adoption's
//  reopen), consulted synchronously by the round-trigger gate, cleared by
//  the ONE Resume press, which then lets the account catch up
//  (`onResume` — the Mac wires `AppServices.resumeSync`; QD's kept
//  outbox pushes in that first round because nothing ever cleared it).
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class RestoreHoldModel {
    private(set) var hold: LibraryRestoreHold.Hold?
    private(set) var resuming = false
    /// The round-trigger gate's synchronous read.
    var isHeld: Bool { hold != nil }

    @ObservationIgnored private let storeURL: URL?
    /// Wired by the composition root: what Resume does once the hold is
    /// cleared (trigger a round / connect the chain). nil = nothing to
    /// resume (no account — P-U2-2: the press still clears the hold).
    @ObservationIgnored var onResume: (@MainActor () async -> Void)?

    init(storeURL: URL?) {
        self.storeURL = storeURL
        refresh()
    }

    /// Re-read the marker (every ready; cheap — one file stat).
    func refresh() {
        guard let storeURL else {
            hold = nil
            return
        }
        hold = LibraryRestoreHold.read(besideStore: storeURL)
    }

    /// The banner's as-of day, worded (nil = the marker carries none).
    var asOfDay: String? {
        hold?.asOf.map { Self.dayFormatter.string(from: $0) }
    }

    /// THE ONE PRESS: clear the marker, then catch up.
    func resume() async {
        guard !resuming, hold != nil else { return }
        resuming = true
        defer { resuming = false }
        if let storeURL {
            LibraryRestoreHold.clear(besideStore: storeURL)
        }
        hold = nil
        await onResume?()
    }

    nonisolated private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
