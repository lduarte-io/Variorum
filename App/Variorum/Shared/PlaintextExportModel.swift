//
//  PlaintextExportModel.swift
//  Variorum (shared: Mac + Mobile — the decrypted export's brain; the Mac's
//  Data Safety pane renders it; the phone renders no door until a
//  document-picker road exists there — P-2)
//
//  pre-13x batch 3b — copy §4's *Export a decrypted copy* (the postures
//  design decision 15; §5's row): the authorization by posture — Castle: the
//  passphrase, NEVER Touch ID alone; Standard: the passphrase if one is set,
//  else a plain confirm — then a user-chosen destination (the picker refuses
//  the backups folder), then `StorePlaintextExport` off the main actor. Never
//  scheduled. VX-329 U1: the facts come from the protection road (the open
//  library's posture, and the typed passphrase checked against its key file —
//  rule 7: a synced library's pair IS the account's); today's posture, its
//  envelope and its vault tie left with today's road.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class PlaintextExportModel {
    enum Phase: Equatable {
        /// The authorization: the passphrase, or the plain confirm.
        case authorize(needsPassphrase: Bool)
        /// Authorized — the caller picks the destination.
        case choosing
        case exporting
        /// The export's path, for the receipt.
        case done(String)
        case failed(String)
    }

    /// What a passphrase check found.
    enum Verify: Equatable, Sendable {
        case match
        case mismatch(String)
        case couldNotCheck(String)
    }

    nonisolated struct Facts: Sendable {
        /// Whether the open library is in Castle (nil posture — nothing open — reads Standard).
        var isCastle: @MainActor () -> Bool
        var hasPassphrase: @MainActor () -> Bool
        /// The typed passphrase against the open library's key file (the caller composes the road).
        var verifyPassphrase: @MainActor (String) async -> Verify
        /// Folders an export must never land in (the app's own backups —
        /// beside the library, and the picked second folder's).
        var refusedFolders: @MainActor () -> [URL]
        var export: @MainActor (URL) async throws -> Void
    }

    private(set) var phase: Phase
    private(set) var busy = false
    var lastError: String?
    private let facts: Facts

    init(facts: Facts) {
        self.facts = facts
        let needsPassphrase = facts.isCastle() || facts.hasPassphrase()
        phase = .authorize(needsPassphrase: needsPassphrase)
    }

    /// Castle, or Standard with a passphrase set: the passphrase; Standard
    /// without one: `nil` — the plain confirm (copy §4: *Export* directly).
    func authorize(passphrase: String?) async {
        guard case .authorize(let needsPassphrase) = phase, !busy else { return }
        lastError = nil
        guard needsPassphrase else {
            phase = .choosing
            return
        }
        guard let passphrase, !passphrase.isEmpty else {
            lastError = ProtectionCopy.emptyPassphraseRefusal
            return
        }
        busy = true
        defer { busy = false }
        switch await facts.verifyPassphrase(passphrase) {
        case .match:
            phase = .choosing
        case .mismatch(let message):
            lastError = message
        case .couldNotCheck(let reason):
            lastError = "Couldn't verify the passphrase (\(reason))."
        }
    }

    /// The picker's own refusal: never into a backups folder.
    func refusal(for destination: URL) -> String? {
        let folder = destination.deletingLastPathComponent().standardizedFileURL.path
        for refused in facts.refusedFolders() {
            let path = refused.standardizedFileURL.path
            if folder == path || folder.hasPrefix(path + "/") {
                return ProtectionCopy.exportPlaintextNotIntoBackups
            }
        }
        return nil
    }

    func export(to destination: URL) async {
        guard case .choosing = phase, !busy else { return }
        lastError = nil
        if let refusal = refusal(for: destination) {
            lastError = refusal
            return
        }
        busy = true
        defer { busy = false }
        phase = .exporting
        do {
            try await facts.export(destination)
            phase = .done(destination.path)
        } catch {
            phase = .failed(String(describing: error))
        }
    }
}
