//
//  SecretCheckCompositionTests.swift
//  VariorumTests — VX-510 D-B7 (VX-513, her R-510-15): THE READ-ONLY CHECK DOOR's composition, by source — "Check my
//  passphrase or twelve words…" in Settings ▸ Protection beside the key doors (after the words section), its sheet carried
//  by THE ONE PRESENTER's host, the bootstrap's road running the check off the main actor on the OPEN session, and the
//  check's road naming no writer at all (D-B7: "It WRITES NOTHING — no key file, no keychain item, no vault, no ledger, no
//  session hold"). The behaviour is pinned headless (`SecretCheckRoadTests`, `SecretCheckModelTests`); these pins read CODE
//  lines (comments dropped — vx-488 RM3-4: a source pin matches code, never a comment), with `#filePath`'s symlinks resolved
//  so they run in the implementer's SwiftPM harness too.
//

import Foundation
import Testing

@testable import Variorum

@Suite("VX-510 D-B7 — the read-only check door's composition (source)")
struct SecretCheckCompositionTests {
    /// `App/Variorum`, from this file (symlinks resolved — the harness links the suite in).
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent()  // Protection
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// A source file's CODE lines (line comments dropped).
    static func code(_ relative: String) throws -> String {
        let source = try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
        return source.split(separator: "\n").filter {
            let line = $0.trimmingCharacters(in: .whitespaces)
            return !line.hasPrefix("//")
        }.joined(separator: "\n")
    }

    /// The pane renders the check door beside the key doors — after the words section (the set row, the key doors and the
    /// words section keep their order), as its own section read from the key doors' model (a door that cannot act is not
    /// rendered — the section decides, P-2); still ONE presenter host on the pane.
    @Test func thePaneRendersTheCheckDoorAfterTheWordsSection() throws {
        let pane = try Self.code("Variorum/Features/Settings/ProtectionPane.swift")
        let body = try #require(pane.range(of: "var body: some View {")).upperBound
        let rest = String(pane[body...])
        let keyDoors = try #require(rest.range(of: "RoadKeyDoorsSection(model: keyDoors)"))
        let words = try #require(rest.range(of: "WordsLookSection(standing: roadStanding, keyDoors: roadStanding.keyDoors)"))
        let check = try #require(rest.range(of: "RoadSecretCheckSection(model: keyDoors)"), "the check door is rendered")
        #expect(keyDoors.lowerBound < words.lowerBound && words.lowerBound < check.lowerBound)
        #expect(rest.components(separatedBy: ".protectionSheets(").count == 2, "still one host on the pane")
    }

    /// THE ONE PRESENTER's host carries the check's sheet (one protection sheet at a time, on Settings alone).
    @Test func thePresentersHostCarriesTheCheckSheet() throws {
        let host = try Self.code("Variorum/Features/Protection/RoadAccountSheet.swift")
        #expect(host.contains("case .checkSecrets(let model):") && host.contains("RoadSecretCheckSheet(model: model)"))
        let presenter = try Self.code("Shared/Protection/ProtectionSheetPresenter.swift")
        #expect(presenter.contains("case checkSecrets(RoadSecretCheckModel)"))
    }

    /// The bootstrap's key-door roads carry the check: the OPEN session (ready only), the sign-in NOW, off the main actor.
    @Test func theBootstrapWiresTheCheckRoadOnTheOpenSession() throws {
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        let start = try #require(bootstrap.range(of: "func keyDoorRoads() -> RoadKeyDoorRoads {")).upperBound
        let end = try #require(bootstrap.range(of: "func attach(services: AppServices) {")).lowerBound
        let roads = String(bootstrap[start..<end])
        let check = try #require(roads.range(of: "check: {"), "the key doors' roads carry the check")
        let tail = String(roads[check.lowerBound...])
        #expect(tail.contains("case .ready = self.state, let session = self.roadSession"))
        #expect(tail.contains("Task.detached(priority: .userInitiated)"))
        #expect(tail.contains("ProtectionSecretCheck.check(session, typed: typed, signIn: signInNow())"))
    }

    /// GUARD — THE CHECK WRITES NOTHING, BY CONSTRUCTION: its road names no writer of any home (the key file, custody, the
    /// sync keys and their session memory, the memory item, Apple keys, plans, the record, the vault), never the executor
    /// (whose vault read fills its session cache — `freshVaults`), never the act lock, never a ledger or a defaults domain,
    /// and no keychain READ either (a custody or sync-keys Touch ID read prompts — VX-503's lesson: a typed-secret road never
    /// reads the Touch ID item). No stored state: nothing of a check outlives the call.
    @Test func theCheckRoadNamesNoWriterAndNoKeychainRead() throws {
        let road = try Self.code("Shared/Protection/ProtectionSecretCheck.swift")
        #expect(road.contains("enum ProtectionSecretCheck"), "the road exists")
        for writer in [
            "writeLiveKeyFile", "writeCustody", "deleteCustody", "writeSyncKeys", "deleteSyncKeys", "holdInSession",
            "writeMemory", "deleteMemory", "addAppleKey", "deleteAppleKey", "writePlan", "writeRecord", "createVault",
            "updateVault", "readVault(", "freshVaults", "executor", "beginAct", "WordsCardLedger", "UserDefaults",
            "readCustody", "readSyncKeys", "sessionSyncKeys", "static var", "nonisolated(unsafe) static",
        ] {
            #expect(!road.contains(writer), "the check's road names \(writer)")
        }
    }
}
