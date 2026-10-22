//
//  PlaintextExportDoorTests.swift
//  VariorumTests
//
//  pre-13x batch 3b — the decrypted export's door (copy §4; decision 15):
//  the authorization by posture, the refused folder, the export only after
//  the word is verified — over the shared `PlaintextExportModel` with
//  scripted facts (the core road is pinned in `StorePlaintextExportTests`).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("pre-13x 3b — the decrypted export's door")
struct PlaintextExportDoorTests {
    /// VX-329 U1: the facts read the open library's posture (Castle or not) — today's `Posture` left with today's road.
    private func facts(
        castle: Bool, hasPassphrase: Bool, exports: LockIsolated<[URL]>,
        refused: [URL] = []
    ) -> PlaintextExportModel.Facts {
        PlaintextExportModel.Facts(
            isCastle: { castle },
            hasPassphrase: { hasPassphrase },
            verifyPassphrase: { typed in typed == "sesame" ? .match : .mismatch("not it") },
            refusedFolders: { refused },
            export: { url in exports.withValue { $0.append(url) } })
    }

    @Test func castleTakesThePassphraseRefusesAWrongOneAndNeverTheBackupsFolder() async throws {
        let exports = LockIsolated<[URL]>([])
        let backups = URL(fileURLWithPath: "/tmp/variorum-3b/Backups", isDirectory: true)
        let model = PlaintextExportModel(facts: facts(castle: true, hasPassphrase: true, exports: exports, refused: [backups]))
        #expect(model.phase == .authorize(needsPassphrase: true))
        await model.authorize(passphrase: "not-it")
        #expect(model.lastError == "not it" && model.phase == .authorize(needsPassphrase: true))
        await model.authorize(passphrase: nil)
        #expect(model.lastError != nil && model.phase == .authorize(needsPassphrase: true), "Touch ID alone is never enough — the word")
        await model.authorize(passphrase: "sesame")
        #expect(model.phase == .choosing)
        let inside = backups.appendingPathComponent("Variorum-unencrypted.sqlite")
        await model.export(to: inside)
        #expect(model.lastError == ProtectionCopy.exportPlaintextNotIntoBackups && exports.value.isEmpty,
                "never into the backups folder")
        let elsewhere = URL(fileURLWithPath: "/tmp/variorum-3b/Desktop/Variorum-unencrypted.sqlite")
        await model.export(to: elsewhere)
        #expect(model.phase == .done(elsewhere.path) && exports.value == [elsewhere])
    }

    @Test func standardWithoutAPassphraseExportsOnThePlainConfirm() async throws {
        let exports = LockIsolated<[URL]>([])
        let model = PlaintextExportModel(facts: facts(castle: false, hasPassphrase: false, exports: exports))
        #expect(model.phase == .authorize(needsPassphrase: false))
        await model.authorize(passphrase: nil)
        #expect(model.phase == .choosing)
        // Standard WITH a passphrase set asks for it.
        let withWord = PlaintextExportModel(facts: facts(castle: false, hasPassphrase: true, exports: exports))
        #expect(withWord.phase == .authorize(needsPassphrase: true))
    }
}
