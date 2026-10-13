//
//  VX209LeavesCastleConfirmTests.swift
//  VariorumTests
//
//  VX-209 — THE CONFIRM'S CASTLE LINE (RUN VX-201, unit U5, step 2; the brief
//  is §G of notes/plans/fixes/vx-201-castle-prelaunch-fixes.md, the record its
//  "U5 RECORD (VX-209)"). Her pre-launch scope: when the CURRENT library is
//  Castle and the INCOMING copy reads Standard, the Open Library / Restore
//  confirm says so, naming the road back — on both classifier arms (a pair
//  whose own key file reads Standard, and a plaintext export).
//
//  WHY THE ROAD BACK IS USE CASTLE: `VX209WayBackRoundTripTests` ran the
//  audit's §W.2 trace — opening a Standard-era backup lands the library
//  Standard, and bringing the Castle copy of the same library back from
//  Previous Libraries lands it Standard too. Only Use Castle puts it back.
//
//  RED ON OLD (behavioural reverts, notes/plans/fixes/vx-201-u5-reverts/):
//    · R-209-rule      — the decision answers no line for any copy (the old
//                         confirm): the classifier pin's true arms and the
//                         model pin's two Castle-world lines go red;
//    · R-209-plaintext — the export arm answers no line: the plaintext legs;
//    · R-209-model     — the model never computes the fact: the model pin;
//    · R-209-face      — the sheet never renders it: the face pin.
//

import Dependencies
import Foundation
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("VX-209 — the Open/Restore confirm says when a copy takes the library out of Castle", .serialized)
struct VX209LeavesCastleConfirmTests {

    // MARK: - The decision, on the classifier's own verdicts (both arms)

    @Test func theLineRidesThePairArmAndThePlaintextArmOfTheClassifier() async throws {
        try await withWorld { world in
            // A pair whose own key file reads Standard (an Apple copy): the
            // app's own Standard-era backup.
            let standardPair = LibraryClassifier.classify(at: world.snapshot)
            guard case .snapshotPair = standardPair else {
                Issue.record("premise: the backup classifies as its pair, got \(standardPair)")
                return
            }
            #expect(LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: standardPair))
            #expect(!LibraryOpenModel.leavesCastle(currentIsCastle: false, incoming: standardPair),
                    "no line when the library standing here is not Castle")

            // The same pair carried in a folder (the hand-off shape).
            let folder = world.dir.appendingPathComponent("carried", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try FileManager.default.copyItem(
                at: world.snapshot, to: folder.appendingPathComponent("variorum.sqlite"))
            try FileManager.default.copyItem(
                at: LibraryClassifier.pairedKeyFile(for: world.snapshot),
                to: folder.appendingPathComponent("variorum-keys-\(StoreKeyEnvelope.fingerprint(of: world.standardKey)).json"))
            let carried = LibraryClassifier.classify(at: folder)
            guard case .folderHoldingPair = carried else {
                Issue.record("premise: a folder holding the pair, got \(carried)")
                return
            }
            #expect(LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: carried))

            // A Standard library that never had a passphrase (no Apple copy
            // either — Standard waiting for its Apple copy): reads Standard.
            let exposed = try makeEncryptedCopy(in: world.dir, named: "exposed") { key, file in
                try file.setRecoveryWrap(key: key, words: RecoveryPhrase.generate())
            }
            guard case .encryptedLibrary = exposed else {
                Issue.record("premise: a library with its key file, got \(exposed)")
                return
            }
            #expect(LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: exposed))

            // A Castle-era copy (a passphrase copy, no Apple copy): no line.
            let castleCopy = try makeEncryptedCopy(in: world.dir, named: "castle-era") { key, file in
                try file.setPassphraseWrap(
                    key: key, passphrase: VX209CastleWorld.passphrase, kdf: VX209CastleWorld.fastKDF())
            }
            #expect(!LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: castleCopy),
                    "a Castle copy stays Castle — no line")

            // The plaintext arm: an export is never in Castle.
            let export = LibraryClassifier.classify(at: world.plaintextExport)
            guard case .plaintextExport = export else {
                Issue.record("premise: the export classifies as one, got \(export)")
                return
            }
            #expect(LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: export))
            #expect(!LibraryOpenModel.leavesCastle(currentIsCastle: false, incoming: export))

            // Refusal-shaped verdicts carry no line (the flow refuses them).
            let bare = world.dir.appendingPathComponent("bare.sqlite")
            try Data((0..<64).map { _ in UInt8.random(in: 0...255) }).write(to: bare)
            #expect(!LibraryOpenModel.leavesCastle(
                currentIsCastle: true, incoming: LibraryClassifier.classify(at: bare)))
            #expect(!LibraryOpenModel.leavesCastle(currentIsCastle: true, incoming: nil))
        }
    }

    // MARK: - The model, on a Castle library at ready (the real flow)

    @Test func aCastleLibrarysConfirmCarriesTheLineForAStandardEraBackupAndAnExportOnly() async throws {
        try await withWorld { world in
            try await world.unlockIntoReady()
            #expect(world.bootstrap.protection.posture == .castle, "premise: the pane says Castle")

            // The Standard-era backup (Restore from Backup's row door): the line.
            let backup = LibraryOpenModel(bootstrap: world.bootstrap)
            backup.begin(picked: world.snapshot)
            try await VX209CastleWorld.waitUntil { backup.phase == .confirm }
            #expect(backup.leavesCastle, "a Standard-era backup over a Castle library: the line")

            // The plaintext export (File ▸ Open Library…): the line.
            let export = LibraryOpenModel(bootstrap: world.bootstrap)
            export.begin(picked: world.plaintextExport)
            try await VX209CastleWorld.waitUntil { export.phase == .confirm }
            #expect(export.isPlaintextRoad)
            #expect(export.leavesCastle, "an export over a Castle library: the line")

            // A Castle-era copy of the same library (the gated item serves it):
            // no line.
            let copyFolder = world.dir.appendingPathComponent("castle-copy", isDirectory: true)
            try FileManager.default.createDirectory(at: copyFolder, withIntermediateDirectories: true)
            try FileManager.default.copyItem(
                at: world.storeURL, to: copyFolder.appendingPathComponent("variorum.sqlite"))
            try FileManager.default.copyItem(
                at: world.storeURL.deletingLastPathComponent()
                    .appendingPathComponent(world.castleKeyFileName),
                to: copyFolder.appendingPathComponent(world.castleKeyFileName))
            let castle = LibraryOpenModel(bootstrap: world.bootstrap)
            castle.begin(picked: copyFolder)
            try await VX209CastleWorld.waitUntil { castle.phase == .confirm }
            #expect(!castle.leavesCastle, "a Castle copy over a Castle library: no line")

            // Once the library standing here is NOT Castle (the backup
            // adopted), the export earns no line.
            await backup.confirmAdoption()
            #expect(backup.phase == .done)
            #expect(world.bootstrap.protection.posture == .standard,
                    "premise: the adopted Standard-era copy reads Standard")
            let afterward = LibraryOpenModel(bootstrap: world.bootstrap)
            afterward.begin(picked: world.plaintextExport)
            try await VX209CastleWorld.waitUntil { afterward.phase == .confirm }
            #expect(!afterward.leavesCastle, "no line over a library that is not Castle")
        }
    }

    // MARK: - The face: ONE sheet renders it, for every adopt road

    @Test func theOneSheetRendersTheLineForEveryAdoptRoad() throws {
        let appRoot = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        func uncommented(_ source: String) -> String {
            source.split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
                .joined(separator: "\n")
        }
        func code(_ path: String) throws -> String {
            uncommented(try String(contentsOf: appRoot.appending(path: path), encoding: .utf8))
        }
        // The sheet renders the line under the model's fact.
        let sheet = try code("Variorum/LibraryOpenDoor.swift")
        #expect(sheet.contains("if model.leavesCastle {"))
        #expect(sheet.contains("Text(LibraryOpenCopy.confirmLeavesCastle)"))
        // Every adopt road presents that one sheet: the main window's
        // presenter (File ▸ Open Library… and the lobby faces) and Settings'
        // (Restore from Backup); the restore row drives Settings' presenter.
        let app = try code("Variorum/VariorumApp.swift")
        #expect(app.components(separatedBy: "LibraryOpenSheet(model: model)").count - 1 == 2,
                "two presenters, one sheet")
        #expect(try code("Variorum/EditorCommands.swift").contains("openDoor.openPanel(bootstrap: bootstrap)"))
        #expect(try code("Variorum/Features/Settings/DataSafetyPane.swift")
            .contains("restoreDoor(candidate.snapshot)"))
        // ONE home: the sentence is declared once and rendered only by the sheet.
        var renderers: [String] = []
        for root in ["Variorum", "Shared", "VariorumMobile"] {
            let walk = try #require(FileManager.default.enumerator(
                at: appRoot.appending(path: root), includingPropertiesForKeys: nil))
            for case let url as URL in walk where url.pathExtension == "swift" {
                let source = uncommented(try String(contentsOf: url, encoding: .utf8))
                if source.contains("LibraryOpenCopy.confirmLeavesCastle") {
                    renderers.append(url.lastPathComponent)
                }
            }
        }
        #expect(renderers == ["LibraryOpenDoor.swift"], "rendered by the one sheet alone: \(renderers)")
    }

    // MARK: - The words keep the register (PROVISIONAL — QUESTIONS #215)

    @Test func theLineNamesTheRoadBackInTheEverydayRegister() {
        let line = LibraryOpenCopy.confirmLeavesCastle
        #expect(line.contains("Castle"))
        #expect(line.contains("Use Castle again") && line.contains("Settings ▸ Protection"),
                "names the road back by the door and the pane")
        #expect(!line.contains("Previous Libraries"),
                "never sends her back through Previous Libraries — that road lands Standard too")
        #expect(!line.contains(CopyRegisterPinTests.forbidden))
        #expect(line.firstMatch(of: /\bMac\b/.wordBoundaryKind(.simple)) == nil,
                "Shared copy names no device by a literal")
        let shouted = line.split(separator: " ").filter { word in
            let letters = word.filter(\.isLetter)
            return letters.count > 1 && letters.allSatisfy(\.isUppercase)
        }
        #expect(shouted.isEmpty, "no capitals for emphasis: \(shouted)")
        #expect(line.first?.isUppercase == true && line.hasSuffix("."))
    }

    // MARK: - Helpers

    private func withWorld(
        _ body: @MainActor (VX209CastleWorld) async throws -> Void
    ) async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_790_000_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let world = try await VX209CastleWorld.make()
            defer { try? FileManager.default.removeItem(at: world.dir) }
            try await body(world)
        }
    }

    /// A closed encrypted library with ONE key file beside it, the wraps the
    /// caller lands; classified.
    private func makeEncryptedCopy(
        in dir: URL, named name: String,
        wraps: (StoreKey, inout StoreKeyEnvelope) throws -> Void
    ) throws -> LibraryClassifier.Verdict {
        let store = dir.appendingPathComponent("\(name)/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        var file = StoreKeyEnvelope()
        try wraps(key, &file)
        try file.write(at: file.preferredURL(besideStore: store))
        return LibraryClassifier.classify(at: store)
    }
}
