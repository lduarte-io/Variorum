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

    /// VX-339: why the last Resume press did NOT resume — the marker beside
    /// the store could not be removed, so the hold still stands. The banner
    /// says it (`LibraryOpenCopy.resumeMarkerNotRemoved`) and stays; nil when
    /// nothing failed. Cleared by the next press that removes the marker.
    private(set) var resumeFailure: String?

    /// Removes the marker beside the store; true when it is gone after the
    /// call (`LibraryRestoreHold.clear`'s answer — removed, or never there).
    /// A seam so a test can stand in a marker whose removal fails.
    @ObservationIgnored private let clearMarker: @MainActor (URL) -> Bool

    init(
        storeURL: URL?,
        clearMarker: @escaping @MainActor (URL) -> Bool = { LibraryRestoreHold.clear(besideStore: $0) }
    ) {
        self.storeURL = storeURL
        self.clearMarker = clearMarker
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
    ///
    /// **VX-339 (her ruling 2026-10-14, VX-266 design §9 call 4 — "yeah we
    /// can do the small bug fix"; the run record
    /// `notes/plans/fixes/vx-348-prelaunch-sweep.md`, U1):** the banner clears
    /// only once the marker is GONE. Before, the press ignored the clear's
    /// answer and dropped the projection whatever happened, so a removal
    /// that failed left the marker standing beside the store with no banner
    /// over it: the gates (which read the marker, R3-2) kept every round held
    /// while nothing on screen said so — the Sync-now door's refusal even
    /// pointed at "the banner below" that was gone — and the next launch came
    /// up held again with no explanation. Now a failed removal keeps the hold
    /// visible, says why (`resumeFailure`), and resumes nothing (the gates
    /// would refuse the round anyway); a later press tries again.
    func resume() async {
        guard !resuming, hold != nil else { return }
        resuming = true
        defer { resuming = false }
        if let storeURL, !clearMarker(storeURL) {
            resumeFailure = LibraryOpenCopy.resumeMarkerNotRemoved
            return
        }
        resumeFailure = nil
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
