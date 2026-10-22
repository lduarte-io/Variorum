//
//  LibraryHandOff.swift
//  Variorum (shared — the brains; the Mac door that renders it is U2's,
//  reveal-in-Finder included)
//
//  Phase 13x, U1 row 2 — THE HAND-OFF (the kickoff ruling QC: the folder
//  pair). The AirDrop-your-library promise's producing half: one folder,
//  "Variorum Library — <date>", holding a snapshot of the open library and
//  its key file — the pair kept together, so forgetting the key file is
//  impossible. VX-329 U1 — THE RELEASE SWITCH: the pair is the protection
//  road's own (the executor's `sendLibrary` act — CastleRules rule 18: a
//  library sent to another Mac is a COPY there; vx-266 §3.7: "Send Library
//  writes the pair and says nothing about sharing"): the snapshot as
//  `variorum.sqlite` beside this design's key file
//  (`variorum-library-keys.json`), exactly what the road's Open Library…
//  files on the other Mac (`PickedCopy`). Today's producer — a sealed
//  snapshot beside TODAY's key file — was today's road and was deleted with
//  it. PROVISIONAL P-VX329-U1-1 (the U1 record).
//

import Foundation
import Observation
import VariorumCore

nonisolated enum LibraryHandOff {
    /// Typed refusals — the door words them (R94); every arm says what to do about it.
    nonisolated enum HandOffError: Error, Equatable {
        /// No live key file of the library's key — a pair without it opens NOTHING on arrival (corner 33), so the act
        /// refuses rather than produce a dead folder.
        case noKeyFile
        /// The destination folder could not be created or written, or the snapshot could not be taken.
        case failed(String)
    }

    nonisolated static let folderPrefix = "Variorum Library — "

    /// "Variorum Library — 2026-10-06" (the user's own calendar day —
    /// local time on purpose; this is a human name, not a sort key).
    nonisolated static func folderName(on date: Date) -> String {
        folderPrefix + dayFormatter.string(from: date)
    }

    /// The first free folder URL for the day: the plain name, then
    /// " (2)", " (3)", … (PROVISIONAL P-U1-4 — same-day repeats).
    nonisolated static func availableFolderURL(in parent: URL, now: Date) -> URL {
        let base = folderName(on: now)
        var candidate = parent.appendingPathComponent(base, isDirectory: true)
        var counter = 2
        while FileManager.default.fileExists(atPath: candidate.path) {
            candidate = parent.appendingPathComponent("\(base) (\(counter))", isDirectory: true)
            counter += 1
        }
        return candidate
    }

    nonisolated private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

/// 13x F1 (ladder R1-MAJOR) — THE HAND-OFF DOOR's one flow behind both
/// faces (File ▸ Send Library to Another Mac… and Data Safety's twin):
/// the destination picked by the face's panel, the road's act run OFF the
/// main thread (`produce` — the bootstrap's `sendLibrary(into:)`), the
/// folder revealed at completion (the injected seam — the Mac wires Finder;
/// the pins record), every refusal worded per arm.
@MainActor
@Observable
final class LibraryHandOffModel {
    enum Phase: Equatable {
        case producing
        case done(folder: URL)
        /// A worded refusal; `detail` carries the quiet facts.
        case refused(String, detail: String?)
    }
    private(set) var phase: Phase = .producing
    /// Reveal-in-Finder, injected (the Mac activates Finder; tests record).
    private let reveal: @MainActor (URL) -> Void

    init(reveal: @escaping @MainActor (URL) -> Void) {
        self.reveal = reveal
    }

    /// THE ACT: the road's pair into a fresh folder under `parent`, then reveal once.
    func begin(into parent: URL, produce: @escaping @MainActor (URL) async -> Result<URL, LibraryHandOff.HandOffError>) async {
        phase = .producing
        switch await produce(parent) {
        case .success(let folder):
            phase = .done(folder: folder)
            reveal(folder)
        case .failure(let error):
            phase = Self.refusal(for: error)
        }
    }

    /// The done face's door — the folder shown again on request.
    func revealAgain() {
        if case .done(let folder) = phase { reveal(folder) }
    }

    /// The per-arm words (facts binding; the strings 13s's).
    nonisolated static func refusal(for error: LibraryHandOff.HandOffError) -> Phase {
        switch error {
        case .noKeyFile:
            return .refused(LibraryOpenCopy.handOffNoKeyFileRefusal, detail: nil)
        case .failed(let detail):
            return .refused(LibraryOpenCopy.handOffFailedLead, detail: detail)
        }
    }
}
