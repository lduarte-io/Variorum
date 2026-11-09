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

    /// **VX-923 — every library the binary links is credited, and BIP-39 reads
    /// as the BIP reads** (F-B3-1 / F-B3-2, the VX-912 B3 dependency check —
    /// `notes/plans/fixes/vx-912-open-source-gating.md`, "## B3 record"). The
    /// five Point-Free libraries ride BOTH platforms' notices (VariorumCore links
    /// swift-dependencies, whose default traits link the other four), each its
    /// own MIT text under its own copyright line; Sparkle rides the MAC's alone
    /// (the Xcode project links it to the Mac app target only), its whole
    /// LICENSE — the MIT grant and the four external licenses it reproduces;
    /// BIP-39 is MIT at the pinned commit, in the BIP's own words. Notices are
    /// looked up BY NAME, so the pin compiles on the tree it reds on.
    @Test func everyLinkedLibraryIsCreditedAndBIP39ReadsMIT() {
        func notice(_ name: String, in list: [AcknowledgmentsCopy.Notice] = AcknowledgmentsCopy.all)
            -> AcknowledgmentsCopy.Notice? {
            list.first { $0.name == name }
        }
        let pointFree: [(name: String, copyright: String)] = [
            ("swift-dependencies", "Copyright (c) 2022 Point-Free, Inc."),
            ("xctest-dynamic-overlay", "Copyright (c) 2021 Point-Free, Inc."),
            ("swift-concurrency-extras", "Copyright (c) 2023 Point-Free"),
            ("combine-schedulers", "Copyright (c) 2020 Point-Free, Inc."),
            ("swift-clocks", "Copyright (c) 2022 Point-Free"),
        ]
        for library in pointFree {
            let shared = notice(library.name, in: AcknowledgmentsCopy.shared)
            #expect(shared != nil, "\(library.name) rides both platforms' notices")
            // The line ends at the newline: "Point-Free" never passes for "Point-Free, Inc.".
            #expect(shared?.text.hasPrefix("MIT License\n\n\(library.copyright)\n") == true,
                    "\(library.name): its own MIT text under its own copyright line")
        }

        let sparkle = notice("Sparkle")
        #expect(sparkle != nil, "Sparkle rides the Mac's notices")
        #expect(notice("Sparkle", in: AcknowledgmentsCopy.shared) == nil,
                "…and never the phone's: only the Mac app links it")
        for line in [
            "Copyright (c) 2006-2013 Andy Matuschak.",                    // the MIT grant
            "Copyright (c) 2011-2014 Kornel Lesi\u{144}ski.",
            "EXTERNAL LICENSES",
            "Copyright 2003-2005 Colin Percival",                         // bsdiff 4.3 — BSD-2
            "Copyright (c) 2008-2010 Yuta Mori All Rights Reserved.",     // sais-lite — MIT
            "Copyright (c) 2015 Orson Peters <orsonpeters@gmail.com>",    // ed25519 — zlib
            "Copyright (c) 2011 Mark Hamlin.",                            // SUSignatureVerifier — BSD-2
        ] {
            #expect(sparkle?.text.contains(line) == true, "Sparkle's LICENSE carries \(line)")
        }

        let bip39 = AcknowledgmentsCopy.bip39.text
        #expect(bip39.contains("MIT License"), "BIP-39 is MIT at the pinned commit")
        #expect(bip39.contains("\"This BIP falls under the MIT License.\""), "…in the BIP's own words")
        #expect(!bip39.contains("BSD") && !bip39.contains("PD/") && !bip39.contains("public-domain"),
                "the old PD/BSD-2-Clause statement is gone")

        // The pane's ForEach is keyed by name: a new entry may never collide.
        let names = AcknowledgmentsCopy.all.map(\.name)
        #expect(Set(names).count == names.count, "every notice's name is unique")
    }
}

// MARK: - Batch 2 additions (the owed Batch-1 items)

// (VX-329 U1: "13p Batch 2 — the key envelope rides the backups" pinned today's flat legs carrying today's key file
// beside the copies — `StoreBackup.copyKeyEnvelope`, deleted with the flat legs; the pair road's own key file rides each
// pair, pinned in `ProtectionBackupHookTests`.)

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
