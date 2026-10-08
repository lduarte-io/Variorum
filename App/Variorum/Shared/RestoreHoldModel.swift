//
//  RestoreHoldModel.swift
//  Variorum (shared — the restore-hold's observable face-state; the Mac's
//  banner renders it; `wireGates` points the round and ceremony gates at
//  the marker itself)
//
//  Phase 13x, U2 row 7 — THE LANDING STATE's brain (round 3, ruled on
//  BOTH doors): the hold is the `LibraryRestoreHold` marker beside the
//  store; this model is its MainActor projection — refreshed at every
//  ready (the composition root's `.task` re-runs after each adoption's
//  reopen) and rendered by the banner, cleared by the ONE Resume press,
//  which then lets the account catch up (`onResume` — the Mac wires
//  `AppServices.resumeSync`; QD's kept outbox pushes in that first round
//  because nothing ever cleared it). The GATES never read the projection
//  (13x F3, ladder R3-2): `wireGates` points them at the marker.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class RestoreHoldModel {
    private(set) var hold: LibraryRestoreHold.Hold?
    private(set) var resuming = false
    /// The PROJECTION's answer — the banner's. The gates read
    /// `markerGate` instead (R3-2).
    var isHeld: Bool { hold != nil }

    /// 13x F3 (ladder R3-2): the gates' ONE source — the MARKER beside
    /// the store (`LibraryRestoreHold.isHeld(besideStore:)`, one file
    /// stat), never the projection above. The projection refreshes only
    /// where a main window's `.task` runs, so an adoption run from the
    /// Settings scene with no main window left it answering "not held"
    /// over a standing marker — the ruled "until Resume, no round runs"
    /// then held only because no trigger road outlived the window. The
    /// marker IS the fact; reading it is what makes any future trigger
    /// road (a scheduler, a menu-bar door) honor the hold for free.
    var markerGate: @MainActor () -> Bool {
        let storeURL = self.storeURL
        return { storeURL.map { LibraryRestoreHold.isHeld(besideStore: $0) } ?? false }
    }

    /// The composition root's ONE wiring of both gates (R3-2): the round
    /// trigger (`SyncSession.roundsHeld`) and the rotation ceremonies'
    /// door (`ProtectionController.restoreHoldStands`, F1 R1-M1) — each
    /// reading the marker.
    func wireGates(sync: SyncSession, protection: ProtectionController) {
        let gate = markerGate
        sync.roundsHeld = gate
        protection.restoreHoldStands = gate
    }

    @ObservationIgnored private let storeURL: URL?
    /// Wired by the composition root: what Resume does once the hold is
    /// cleared (trigger a round / connect the chain). nil = nothing to
    /// resume (no account — P-U2-2: the press still clears the hold).
    @ObservationIgnored var onResume: (@MainActor () async -> Void)?
    /// Whether this Mac belongs to an account — the banner's account
    /// clause reads it (round 4's NIT). Wired with `onResume`; true until
    /// wired, the shipped wording's default.
    var hasAccount = true

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
