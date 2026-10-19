//
//  ProtectionWordsVX307Tests.swift
//  VariorumTests — VX-307 U2c, VX-414 (her rulings on QUESTIONS #234, 2026-10-18): U2-6 "sure we can drop the sentence"
//  — the split-pair line is gone; U2-7 "I agree with your suggested wording" — her two sentences, BYTE-EQUAL to the
//  ticket's text as the plan's U2c record carries it (`notes/plans/vx-307-castle-crossings.md`, "THE WORDS THIS BATCH
//  LANDS"), and each said in exactly the one state it was ruled for: (1) the standing banner after a quiet open with no
//  key file anywhere (the lobby's moment keeps §7c (3)'s refusal); (2) the key-file offer when the place beside the
//  library is EMPTY and a backup holds the right file (a stray beside keeps her sentence). Planted roads — headless too.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2c — VX-414: the split pair dropped, her two U2-7 sentences byte-equal, each in its state")
@MainActor
struct ProtectionWordsVX307Tests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    static var repo: URL {
        URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
    }

    /// The plan's U2c words block, its whitespace runs collapsed (the prose wraps mid-sentence).
    static func wordsBlock() throws -> String {
        let text = try String(contentsOf: repo.appendingPathComponent("notes/plans/vx-307-castle-crossings.md"), encoding: .utf8)
        let collapsed = text.split(whereSeparator: { $0 == " " || $0 == "\n" || $0 == "\t" }).joined(separator: " ")
        let start = try #require(collapsed.range(of: "**THE WORDS THIS BATCH LANDS"))
        let end = try #require(collapsed.range(of: "## 7. LIVE STATUS", range: start.upperBound..<collapsed.endIndex))
        return String(collapsed[start.lowerBound..<end.lowerBound])
    }

    /// Code lines of a file under `App/Variorum/` (comments dropped).
    static func code(_ relative: String) throws -> String {
        try String(contentsOf: repo.appendingPathComponent("App/Variorum/" + relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    @Test func herTwoU27SentencesAreTheTicketsByteForByteAndTheSplitPairIsGone() throws {
        let words = try Self.wordsBlock()
        #expect(words.contains("*\(ProtectionWords.noKeyFileAfterAQuietOpen)*"), "U2-7 (1), byte-equal")
        #expect(words.contains("*\(ProtectionWords.offerBesideEmptyFromABackup)*"), "U2-7 (2), byte-equal")
        // Her offer sentence's remainder — the question her own sentence ends with (the model's constant).
        #expect(KeyFileOffer.backupHoldsOne.hasSuffix(" " + ProtectionWords.offerUseItQuestion))
        // U2-6: the line is gone from the words and from every face.
        for file in ["Shared/Protection/ProtectionWords.swift", "Shared/Protection/ProtectionOpenFaces.swift",
                     "Variorum/Features/Protection/ProtectionRoadBar.swift"] {
            let source = try Self.code(file)
            #expect(!source.contains("is an older one"), "\(file) still says the split-pair line")
            #expect(!source.contains("splitPair"), "\(file) still carries the split pair's face")
        }
    }

    /// U2-7 (1) in its one state: the banner after a QUIET open (the Mac's bar, the phone's sheet) — while the lobby's
    /// moment, where nothing opened, keeps §7c (3)'s refusal on both platforms.
    @Test func theBannerAfterAQuietOpenSpeaksHerWordsAndTheLobbyKeepsTheRefusal() throws {
        let bar = try Self.code("Variorum/Features/Protection/ProtectionRoadBar.swift")
        #expect(bar.contains("Text(ProtectionWords.noKeyFileAfterAQuietOpen)"))
        #expect(!bar.contains("ProtectionWords.noKeyFileAnywhere)"))
        let phone = try Self.code("VariorumMobile/Features/Protection/MobileRoadFaces.swift")
        let sheet = try #require(phone.range(of: "struct MobileNoKeyFileSheet"))
        let sheetBody = phone[sheet.lowerBound...]
        #expect(sheetBody.contains("Text(ProtectionWords.noKeyFileAfterAQuietOpen)"))
        let lobby = phone[..<sheet.lowerBound]
        #expect(lobby.contains("sentence(ProtectionWords.noKeyFileAnywhere)"), "the phone's lobby keeps §7c (3)")
        #expect(try Self.code("Variorum/StoreLockView.swift").contains("sentence(ProtectionWords.noKeyFileAnywhere)"),
                "the Mac's lobby keeps §7c (3)")
        // The standing face is owed exactly where it was (the after-open fault), its words now hers.
        var report = RoadOpenReport()
        report.faults = [.noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: false))]
        #expect(RoadStandingFaces.derive(report).noKeyFileAnywhere == NoKeyFileAnywhere(accountRoad: false))
    }

    /// U2-7 (2) through the real road: NO key file beside the library, this Mac's sealed copy gone too (so rule 1's quiet
    /// restore has nothing to put back), a backup holding the library's own — the offer opens with her variant and asks
    /// her question; the receipt still names the backup's day; *Use it* puts the file back. A STRAY beside keeps her
    /// sentence as it was.
    @Test func anEmptyPlaceBesideOpensTheOfferWithHerVariant() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let own = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try road.system().backups.takeBackupPair(with: created.key, keyFile: own, deviceID: created.library.section.deviceID)
        try FileManager.default.removeItem(at: road.slot.places.liveKeyFile)
        road.memory.items = [:]
        let ctx = road.context()
        guard case .opened(let session) = await ProtectionOpenRoad.route(ctx),
              case .offer(let offer)? = session.report.keyFileSearch,
              case .backup(_, let date?) = offer.source else {
            Issue.record("a backup's key file offered over an empty place")
            return
        }
        #expect(session.report.besideIsEmpty)
        let card = try #require(RoadInterlude.cards(session.report).first)
        #expect(card == .offer(offer, besideEmpty: true))
        #expect(RoadInterlude.sentence(card, day: Self.day)
            == "There is no key file beside your library. A backup holds one that opens it. Use it?")
        #expect(RoadInterlude.receipt(offer, day: Self.day) == "Key file restored from the backup from \(Self.day(date)).")
        #expect(await ProtectionOpenRoad.useOffer(ctx, session: session, offer: offer) == .used)
        #expect(try road.system().leaves.keyFiles.readLiveKeyFile()?.fingerprint == created.library.fingerprint)
        #expect(!session.report.besideIsEmpty, "re-read after Use it: the place beside holds the file again")

        // A stray beside (a key file that doesn't open it): her sentence, as it was.
        let stray = PlantedRoad()
        let (strayCreated, _) = try await stray.created()
        let strayOwn = try #require(try stray.system().leaves.keyFiles.readLiveKeyFile())
        try stray.system().backups.takeBackupPair(
            with: strayCreated.key, keyFile: strayOwn, deviceID: strayCreated.library.section.deviceID)
        try Plant.strayBeside(stray)
        stray.memory.items = [:]
        guard case .opened(let straySession) = await ProtectionOpenRoad.route(stray.context()),
              case .offer(let strayOffer)? = straySession.report.keyFileSearch,
              case .backup(_, let strayDate?) = strayOffer.source else {
            Issue.record("a backup's key file offered over a stray")
            return
        }
        #expect(!straySession.report.besideIsEmpty)
        let strayCard = try #require(RoadInterlude.cards(straySession.report).first)
        #expect(RoadInterlude.sentence(strayCard, day: Self.day) == "The key file beside your library doesn't open it. "
            + "The backup from \(Self.day(strayDate)) holds a key file that does. Use it?")
    }

    /// The variant is the BACKUP offer's only: this Mac's keychain copy over an empty place (unreached — rule 1's quiet
    /// restore puts it back first) keeps her keychain sentence.
    @Test func theKeychainOfferKeepsHerSentence() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        try Plant.strayBeside(road)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()),
              case .offer(let offer)? = session.report.keyFileSearch, offer.source == .thisMacsKeychain else {
            Issue.record("this Mac's keychain copy offered")
            return
        }
        #expect(RoadInterlude.sentence(.offer(offer, besideEmpty: true), day: Self.day)
            == "The key file beside your library doesn't open it. This Mac's keychain holds a copy that does. Use it?")
    }
}
