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

    /// A ciphertext backup restored on a NEW machine is unopenable without
    /// the wraps — so the sidecar must ride into the backup folder, and
    /// refresh when it changes (a re-wrapped passphrase must not leave a
    /// stale envelope in the recovery folder).
    @Test func theEnvelopeRidesBesideTheCopiesAndRefreshes() async throws {
        let sourceDir = try temporaryDirectory()
        let backupDir = try temporaryDirectory()
        defer {
            try? FileManager.default.removeItem(at: sourceDir)
            try? FileManager.default.removeItem(at: backupDir)
        }
        let storeURL = sourceDir.appendingPathComponent("variorum.sqlite")
        let envelopeURL = StoreKeyEnvelope.url(besideStore: storeURL)
        var envelope = StoreKeyEnvelope()
        try envelope.write(at: envelopeURL)

        let database = try AppDatabase.inMemory()
        let suite = "variorum-13p-benv-\(UUID().uuidString)"
        let record = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeSourceURL: envelopeURL),
                defaults: UserDefaults(suiteName: suite)!,
                now: Date(timeIntervalSince1970: 1_782_900_000), force: true)
        }.value
        #expect(record.primary.outcome == .written)
        let carried = backupDir.appendingPathComponent(StoreKeyEnvelope.filename)
        #expect(try StoreKeyEnvelope.load(at: carried) == envelope)

        // The source gains a wrap (a set/reset) — the next run refreshes
        // the carried copy rather than leaving the stale one.
        envelope.recovery = Data([0x01, 0x02, 0x03])
        try envelope.write(at: envelopeURL)
        _ = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeSourceURL: envelopeURL),
                defaults: UserDefaults(suiteName: suite)!,
                now: Date(timeIntervalSince1970: 1_783_000_000), force: true)
        }.value
        #expect(try StoreKeyEnvelope.load(at: carried) == envelope)
    }

    @Test func noEnvelopeMeansNothingCarriedAndNothingBroken() async throws {
        let backupDir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: backupDir) }
        let database = try AppDatabase.inMemory()
        let suite = "variorum-13p-benv-\(UUID().uuidString)"
        let record = await Task.detached {
            StoreBackup.performRun(
                database: database, directory: backupDir,
                configuration: .init(keyEnvelopeSourceURL: nil),
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
