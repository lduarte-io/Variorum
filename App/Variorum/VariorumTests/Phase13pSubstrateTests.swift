//
//  Phase13pSubstrateTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 1 (commit 4) — the R13p-8 default flip (the automatic
//  plain-text export is OFF by default the moment encryption is present,
//  surviving as an opt-in) and R13p-11's attribution obligation (the
//  acknowledgments copy carries the Zetetic line and the license texts).
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — the plain-text insurance defaults OFF (R13p-8's rider)")
struct MarkdownInsuranceFlipTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-flip-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func scratchDefaults() -> UserDefaults {
        UserDefaults(suiteName: "variorum-13p-flip-\(UUID().uuidString)")!
    }

    private func populatedDatabase() throws -> AppDatabase {
        let db = try AppDatabase.inMemory()
        try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1))
        } operation: {
            let ops = Operations()
            let post = try ops.createPost(title: "flip", profile: .journal)
            _ = try ops.newBlock(in: post.id, text: "Prose the flip must not auto-export.")
        }
        return db
    }

    /// THE PIN, red-on-old: on pre-13p code a picked destination + a due
    /// run WRITES her prose to disk in plain text with no way to stop it;
    /// with the flip, the default run reports `.disabled` and writes
    /// NOTHING — not even under `force` (Back Up Now must not become a
    /// plaintext door; the setting is the door).
    @Test func aDefaultRunWritesNoPlainTextEvenForced() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let bookmark = try dir.bookmarkData(
            options: bookmarkCreationOptions, includingResourceValuesForKeys: nil,
            relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
        let source = try populatedDatabase()

        let leg = await Task.detached {
            MarkdownInsurance.performRun(
                database: source, defaults: defaults, now: Date(), force: true)
        }.value

        #expect(leg.outcome == .disabled)
        let exports = MarkdownInsurance.exportsFolder(in: dir)
        #expect(!FileManager.default.fileExists(atPath: exports.path),
                "nothing may land on disk while the option is off")
        // And the run record's roll-up treats OFF as had-no-job, so the
        // freshness face never reads a designed state as a failure.
        let record = BackupRunRecord(
            at: Date(),
            primary: .init(outcome: .written, integrity: "ok"),
            secondary: .init(outcome: .noDestination),
            markdown: leg)
        #expect(record.everythingWorked)
    }

    /// The opt-in half (R13p-8's "still available to users that want it"):
    /// with the setting ON, the same run writes exactly what it always
    /// wrote — readable prose in `.md` files.
    @Test func theOptInStillWritesProse() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let defaults = scratchDefaults()
        let bookmark = try dir.bookmarkData(
            options: bookmarkCreationOptions, includingResourceValuesForKeys: nil,
            relativeTo: nil)
        defaults.set(bookmark, forKey: BackupDestination.defaultsKey)
        MarkdownInsurance.setEnabled(true, in: defaults)
        let source = try populatedDatabase()

        let leg = await Task.detached {
            MarkdownInsurance.performRun(
                database: source, defaults: defaults, now: Date(), force: true)
        }.value

        #expect(leg.outcome == .written)
        #expect((leg.files ?? 0) > 0)
        let exports = MarkdownInsurance.exportsFolder(in: dir)
        let folders = try MarkdownInsurance.existingExports(in: exports)
        let written = try #require(folders.last)
        let bodies = try FileManager.default
            .subpathsOfDirectory(atPath: written.path)
            .filter { $0.hasSuffix(".md") }
            .map { try String(contentsOf: written.appendingPathComponent($0), encoding: .utf8) }
        #expect(bodies.contains { $0.contains("Prose the flip must not auto-export.") },
                "the opt-in restores exactly the old behavior")
    }

    @Test func theDefaultIsOffAndTheSettingRoundTrips() {
        let defaults = scratchDefaults()
        #expect(MarkdownInsurance.isEnabled(in: defaults) == false,
                "off unless deliberately turned on — the rider's letter")
        MarkdownInsurance.setEnabled(true, in: defaults)
        #expect(MarkdownInsurance.isEnabled(in: defaults))
        MarkdownInsurance.setEnabled(false, in: defaults)
        #expect(MarkdownInsurance.isEnabled(in: defaults) == false)
    }

    /// App-scoped security bookmarks need the entitled host; the plain form
    /// serves anywhere the entitlement is absent. Either resolves for a
    /// folder this process can already reach.
    private var bookmarkCreationOptions: URL.BookmarkCreationOptions {
        #if os(macOS)
        [.withSecurityScope]
        #else
        []
        #endif
    }
}

@Suite("13p — the acknowledgments carry the attribution obligation (R13p-11)")
struct AcknowledgmentsCopyTests {
    @Test func theZeteticLineAndLicenseTextShipVerbatim() {
        let sqlcipher = AcknowledgmentsCopy.sqlcipher
        #expect(sqlcipher.text.contains("Copyright (c) 2025, ZETETIC LLC"),
                "the copyright line is the obligation's first clause")
        #expect(sqlcipher.text.contains("Redistribution and use in source and binary forms"))
        #expect(sqlcipher.text.contains(
            "THIS SOFTWARE IS PROVIDED BY ZETETIC LLC ''AS IS''"))
        #expect(AcknowledgmentsCopy.all.first?.name == "SQLCipher",
                "SQLCipher leads — it is the phase's dependency and the ruling's subject")
    }

    @Test func theDependencyNoticesRideAlongside() {
        let names = AcknowledgmentsCopy.all.map(\.name)
        #expect(names.contains("GRDB.swift"))
        #expect(AcknowledgmentsCopy.grdb.text.contains("Gwendal Roué"))
        #expect(names.contains("swift-dependencies"))
        #expect(AcknowledgmentsCopy.swiftDependencies.text.contains("Point-Free, Inc."))
        #expect(names.contains("SQLite"))
        #expect(names.contains { $0.contains("Argon2") })
        #expect(names.contains { $0.contains("BIP-39") })
        // Every notice has real text — no empty attribution card.
        for notice in AcknowledgmentsCopy.all {
            #expect(!notice.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!notice.role.isEmpty)
        }
    }

    /// 13n-b (R-13n-2): the MCP SDK family rides the MAC's notices — the SDK
    /// with its MIT copyright line and the transition statement, the three
    /// packages it links, SwiftLog's NOTICE reproduced (Apache 2.0 §4(d)), and
    /// the Apache 2.0 text itself (§4(a)).
    @Test func theMCPFamilyRidesTheMacNotices() {
        let names = AcknowledgmentsCopy.all.map(\.name)
        for expected in ["MCP Swift SDK", "SwiftLog", "Swift System", "EventSource", "Apache License 2.0"] {
            #expect(names.contains(expected), "missing \(expected)")
        }
        #expect(AcknowledgmentsCopy.mcpSDK.text.contains(
            "Copyright (c) 2024-2025 Model Context Protocol a Series of LF Projects, LLC."))
        #expect(AcknowledgmentsCopy.mcpSDK.text.contains("licensing transition from the MIT License"))
        #expect(AcknowledgmentsCopy.swiftLog.text.contains("Copyright 2018, 2019 The SwiftLog Project"))
        #expect(AcknowledgmentsCopy.eventSource.text.contains("Copyright 2025 Mattt"))
        #expect(AcknowledgmentsCopy.apache2.text.contains("END OF TERMS AND CONDITIONS"))
        #expect(AcknowledgmentsCopy.swiftSystem.text.contains("Runtime Library Exception"))
        // The shared list (the phone's) never names the Mac-only family.
        #expect(!AcknowledgmentsCopy.shared.map(\.name).contains("MCP Swift SDK"))
    }
}

// MARK: - Batch 2 additions (the owed Batch-1 items)

@Suite("13p Batch 2 — the key envelope rides the backups")
struct Phase13pBackupEnvelopeTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-benv-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A ciphertext backup restored on a NEW machine is unopenable without
    /// the wraps — so the key file must ride into the backup folder, under
    /// its fingerprint name. pre-13x 1a (decision 11 / §6): it is written
    /// ONCE and NEVER REWRITTEN — a re-wrap of the live key file does not
    /// reach the folder (a snapshot opens with the passphrase its folder's
    /// key file was written under, the twelve words, or the master copy).
    /// RED ON OLD: 13p refreshed the carried copy when its bytes changed —
    /// the second assertion below read the re-wrapped envelope.
    @Test func theEnvelopeRidesBesideTheCopiesAndIsNeverRewritten() async throws {
        let sourceDir = try temporaryDirectory()
        let backupDir = try temporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: sourceDir)
            try? FileManager.default.removeItem(at: backupDir)
        }
        let storeURL = sourceDir.appendingPathComponent("variorum.sqlite")
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "first", kdf: fastKDF())
        let envelopeURL = envelope.preferredURL(besideStore: storeURL)
        try envelope.write(at: envelopeURL)
        #expect(envelopeURL.lastPathComponent
                == StoreKeyEnvelope.filename(forFingerprint: StoreKeyEnvelope.fingerprint(of: key)))

        let database = try AppDatabase.inMemory()
        let suite = "variorum-13p-benv-\(UUID().uuidString)"
        let record = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeStoreURL: storeURL),
                defaults: UserDefaults(suiteName: suite)!,
                now: Date(timeIntervalSince1970: 1_782_900_000), force: true)
        }.value
        #expect(record.primary.outcome == .written)
        let carried = backupDir.appendingPathComponent(envelopeURL.lastPathComponent)
        #expect(try StoreKeyEnvelope.load(at: carried) == envelope,
                "the key file rides beside the copies under its fingerprint name")
        let carriedBytes = try Data(contentsOf: carried)

        // The live key file is RE-WRAPPED (a passphrase change) — the next
        // run leaves the folder's copy exactly as it was written.
        try envelope.setPassphraseWrap(key: key, passphrase: "second", kdf: fastKDF())
        try envelope.write(at: envelopeURL)
        _ = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeStoreURL: storeURL),
                defaults: UserDefaults(suiteName: suite)!,
                now: Date(timeIntervalSince1970: 1_783_000_000), force: true)
        }.value
        #expect(try Data(contentsOf: carried) == carriedBytes,
                "a backup folder's key file is NEVER rewritten after it is written")
        #expect(try StoreKeyEnvelope.load(at: carried)?.unwrapKey(passphrase: "first") == key,
                "the folder's copy still opens with the passphrase it was written under")
    }

    /// Two keys' files coexist in one folder (§6: "a folder holds one per
    /// library key it has ever held") — a second key's file never replaces
    /// the first (the pin the brief names).
    @Test func twoKeysFilesCoexistAndNeitherOverwritesTheOther() throws {
        let sourceDir = try temporaryDirectory()
        let backupDir = try temporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: sourceDir)
            try? FileManager.default.removeItem(at: backupDir)
        }
        let storeURL = sourceDir.appendingPathComponent("variorum.sqlite")
        let first = StoreKey.mint(), second = StoreKey.mint()
        var a = StoreKeyEnvelope(); try a.setPassphraseWrap(key: first, passphrase: "pp", kdf: fastKDF())
        var b = StoreKeyEnvelope(storeID: a.storeID); try b.setPassphraseWrap(key: second, passphrase: "pp", kdf: fastKDF())
        let aURL = a.preferredURL(besideStore: storeURL), bURL = b.preferredURL(besideStore: storeURL)
        try a.write(at: aURL)
        StoreBackup.copyKeyEnvelope(aURL, into: backupDir)
        try b.write(at: bURL)
        StoreBackup.copyKeyEnvelope(bURL, into: backupDir)
        let carriedA = backupDir.appendingPathComponent(aURL.lastPathComponent)
        let carriedB = backupDir.appendingPathComponent(bURL.lastPathComponent)
        #expect(try StoreKeyEnvelope.load(at: carriedA) == a)
        #expect(try StoreKeyEnvelope.load(at: carriedB) == b)
        #expect(try StoreBackup.existingBackups(in: backupDir).isEmpty)  // no snapshots involved
        // The legacy-named file, once in a folder, is left alone too.
        let legacy = backupDir.appendingPathComponent(StoreKeyEnvelope.filename)
        try Data("legacy".utf8).write(to: legacy)
        var c = StoreKeyEnvelope()
        try c.write(at: StoreKeyEnvelope.legacyURL(besideStore: storeURL))
        StoreBackup.copyKeyEnvelope(StoreKeyEnvelope.legacyURL(besideStore: storeURL), into: backupDir)
        #expect(try Data(contentsOf: legacy) == Data("legacy".utf8))
        _ = c
    }

    @Test func noEnvelopeMeansNothingCarriedAndNothingBroken() async throws {
        let backupDir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: backupDir) }
        let database = try AppDatabase.inMemory()
        let suite = "variorum-13p-benv-\(UUID().uuidString)"
        let record = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeStoreURL: nil),
                defaults: UserDefaults(suiteName: suite)!,
                now: Date(timeIntervalSince1970: 1_782_900_000), force: true)
        }.value
        #expect(record.primary.outcome == .written)
        #expect(!FileManager.default.fileExists(
            atPath: backupDir.appendingPathComponent(StoreKeyEnvelope.filename).path))
    }
}

@MainActor
@Suite("13p Batch 2 — the plain-text opt-in's face state")
struct Phase13pInsuranceFaceTests {
    @Test func theToggleActWritesTheOneKeyAndTheStateFollows() async {
        let suite = "variorum-13p-face-\(UUID().uuidString)"
        let model = DataSafetyModel(
            backup: nil, defaults: { UserDefaults(suiteName: suite)! })
        await model.refresh()
        #expect(!model.insuranceEnabled, "off by default — R13p-8's rider")
        await model.setInsurance(true)
        #expect(model.insuranceEnabled)
        #expect(MarkdownInsurance.isEnabled(in: UserDefaults(suiteName: suite)!),
                "the face flips exactly the key the run gates on")
        await model.setInsurance(false)
        #expect(!MarkdownInsurance.isEnabled(in: UserDefaults(suiteName: suite)!))
    }

    /// The receipt stays SILENT about the designed default (`.disabled`) —
    /// the setting's face is where the state speaks (Batch 1 PROVISIONAL 3,
    /// completed by this batch's toggle + captions).
    @Test func theDisabledLegStaysSilentInTheReceipt() {
        var record = BackupRunRecord(
            at: Date(),
            primary: BackupRunRecord.Leg(outcome: .written),
            secondary: BackupRunRecord.Leg(outcome: .noDestination),
            markdown: BackupRunRecord.Leg(outcome: .disabled))
        record.primary.integrity = "ok"
        let receipt = DataSafetyModel.receipt(record)
        #expect(!receipt.localizedCaseInsensitiveContains("plain"),
                "a designed default does not speak on every run")
        #expect(receipt.contains("Copied"))
    }
}
