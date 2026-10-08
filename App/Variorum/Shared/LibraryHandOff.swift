//
//  LibraryHandOff.swift
//  Variorum (shared — the brains; the Mac door that renders it is U2's,
//  reveal-in-Finder included)
//
//  Phase 13x, U1 row 2 — THE HAND-OFF PRODUCER (the kickoff ruling QC: the
//  folder pair). The AirDrop-your-library promise's producing half: one
//  folder, "Variorum Library — <date>", holding a SEALED snapshot of the
//  open library and the live key file's copy — the pair kept together, so
//  forgetting the key file is impossible and the bare `.sqlite` stays the
//  one open format (the arriving pair classifies as an ordinary
//  encrypted-library-with-key-file; `LibraryClassifier` reads it with no
//  new shape, no package, no new UTI).
//
//  The snapshot is the PROVEN keyed road — GRDB `backup(to:)` from the
//  open keyed connection (`AppDatabase.backup(to:)`, the `StoreBackup`
//  machinery's own door) — never a raw copy of a live WAL store; it is
//  then SEALED by the same act the backup legs use
//  (`StoreBackup.integrityCheck`: WAL flattened to a self-contained file,
//  sidecars swept, SQLite's own integrity answer read). The key file is
//  copied byte-for-byte under ITS OWN fingerprint name, so
//  `StoreKeyEnvelope.locate(besideStore:)` finds it beside the snapshot
//  exactly as it finds the live one (design §3.5), and the SOURCE pair is
//  only ever read.
//

import Foundation
import GRDB
import Observation
import VariorumCore

nonisolated enum LibraryHandOff {
    /// What one hand-off act produced.
    nonisolated struct Product: Equatable, Sendable {
        var folder: URL
        var snapshot: URL
        var keyFile: URL
        /// SQLite's own `integrity_check` answer for the sealed snapshot
        /// ("ok" or the act threw — a pair that fails its check is never
        /// handed to AirDrop believing it is good).
        var integrity: String
    }

    /// Typed refusals — the door words them (R94); every arm says what to
    /// do about it.
    nonisolated enum HandOffError: Error, Equatable {
        /// No key file sits beside the library — a pair without it opens
        /// NOTHING on arrival (corner 33), so the act refuses rather than
        /// produce a dead folder.
        case noKeyFile(storeFolder: String)
        /// The key file exists but could not be read (the P11 class).
        case keyFileUnreadable(String)
        /// The destination folder could not be created or written.
        case destinationUnwritable(String)
        /// The snapshot could not be taken or did not pass its check —
        /// the half-made folder is removed; nothing travels.
        case snapshotFailed(String)
    }

    nonisolated static let folderPrefix = "Variorum Library — "
    /// The snapshot's name inside the folder: the one open format's own
    /// name — the arriving pair looks exactly like a library folder.
    nonisolated static let snapshotFilename = "variorum.sqlite"

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

    /// THE ACT. Blocking (a library-sized copy) — callers run it off the
    /// main thread; the U2 door detaches and then reveals in Finder.
    /// `database` must be the OPEN keyed store at `storeURL` (the backup
    /// API and the seal both key through its own configuration).
    nonisolated static func produce(
        from database: AppDatabase, storeURL: URL, into parent: URL, now: Date = Date()
    ) throws -> Product {
        dispatchPrecondition(condition: .notOnQueue(.main))
        // The live key file FIRST — its absence refuses before anything
        // is created, and its bytes are read before the folder exists so
        // the source pair is only ever read.
        guard let liveKeyFile = StoreKeyEnvelope.locate(besideStore: storeURL) else {
            throw HandOffError.noKeyFile(
                storeFolder: storeURL.deletingLastPathComponent().path)
        }
        let keyFileBytes: Data
        do {
            keyFileBytes = try Data(contentsOf: liveKeyFile)
        } catch {
            throw HandOffError.keyFileUnreadable(String(describing: error))
        }

        let folder = availableFolderURL(in: parent, now: now)
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        } catch {
            throw HandOffError.destinationUnwritable(String(describing: error))
        }
        // Anything failing past here removes the half-made folder — a
        // hand-off either exists whole or not at all.
        do {
            let snapshot = folder.appendingPathComponent(snapshotFilename, isDirectory: false)
            do {
                try database.backup(to: snapshot)
            } catch {
                throw HandOffError.snapshotFailed(String(describing: error))
            }
            // THE SEAL: the backup legs' own act — journal mode flattened
            // so the file is the whole snapshot, sidecars swept, SQLite's
            // integrity answer read with the store's own key.
            let integrity = StoreBackup.integrityCheck(
                of: snapshot, using: database.artifactConfiguration())
            guard integrity == "ok" else {
                throw HandOffError.snapshotFailed(
                    "the snapshot did not pass its integrity check: \(integrity)")
            }
            let keyFile = folder.appendingPathComponent(
                liveKeyFile.lastPathComponent, isDirectory: false)
            do {
                try keyFileBytes.write(to: keyFile, options: .atomic)
            } catch {
                throw HandOffError.destinationUnwritable(String(describing: error))
            }
            return Product(
                folder: folder, snapshot: snapshot, keyFile: keyFile, integrity: integrity)
        } catch {
            try? FileManager.default.removeItem(at: folder)
            throw error
        }
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
/// the destination picked by the face's panel, the producer run OFF the
/// main thread over the OPEN keyed store, the folder revealed at
/// completion (the injected seam — the Mac wires Finder; the pins
/// record), every refusal worded per arm. The brains stay
/// `LibraryHandOff.produce` — this model adds NO file mechanics.
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

    /// THE ACT: produce off-main, then reveal once. `database` is the
    /// OPEN keyed store at `storeURL` (the producer's own precondition).
    func begin(database: AppDatabase, storeURL: URL, into parent: URL) async {
        phase = .producing
        let outcome: Result<LibraryHandOff.Product, any Error> = await Task.detached(
            priority: .userInitiated
        ) {
            do {
                return .success(try LibraryHandOff.produce(
                    from: database, storeURL: storeURL, into: parent))
            } catch {
                return .failure(error)
            }
        }.value
        switch outcome {
        case .success(let product):
            phase = .done(folder: product.folder)
            reveal(product.folder)
        case .failure(let error):
            phase = Self.refusal(for: error)
        }
    }

    /// The done face's door — the folder shown again on request.
    func revealAgain() {
        if case .done(let folder) = phase { reveal(folder) }
    }

    /// The per-arm words (facts binding; the strings 13s's).
    nonisolated static func refusal(for error: any Error) -> Phase {
        guard let handOff = error as? LibraryHandOff.HandOffError else {
            return .refused(
                LibraryOpenCopy.handOffFailedLead, detail: String(describing: error))
        }
        switch handOff {
        case .noKeyFile:
            return .refused(LibraryOpenCopy.handOffNoKeyFileRefusal, detail: nil)
        case .keyFileUnreadable(let detail), .destinationUnwritable(let detail),
             .snapshotFailed(let detail):
            return .refused(LibraryOpenCopy.handOffFailedLead, detail: detail)
        }
    }
}
