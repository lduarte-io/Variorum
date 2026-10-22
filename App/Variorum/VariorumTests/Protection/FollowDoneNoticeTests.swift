//
//  FollowDoneNoticeTests.swift
//  VariorumTests — VX-309 U2 piece 2: VX-457 — THE FOLLOW'S DONE IS A DURABLE PANE NOTICE UNTIL OK (her ruling 2026-10-19 on
//  P-VX308-U2-7: "I agree with B"). The other-device sentence (VX-107's) was a one-shot RECEIPT on the status seam, so
//  `receipt_style` off hid it and a quit before she looked lost it. Now it is the export notice's idiom: a durable mark in
//  this Mac's defaults, KEYED BY LIBRARY (`variorum.calmAsks.followDone.<libraryID>.kind`), written where the Done was
//  owed (the press that landed whole; the open whose settle finished the follow), read at every refresh of the account
//  section, cleared only by its OK — and never written on today's road (no new-road face exists there). Also runs headless
//  in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-309 U2 — VX-457: the follow's Done, a durable pane notice until OK")
@MainActor
struct FollowDoneNoticeTests {
    /// RED ON OLD: an open whose settle finished a follow owed the Done as a one-shot receipt (VX-107's), which
    /// `receipt_style` off hides and a quit loses. It is no receipt any more — the durable notice carries it.
    @Test func theSettlesDoneIsNoReceiptAnyMore() {
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            var report = RoadOpenReport()
            report.settledFollow = kind
            #expect(!RoadStandingFaces.derive(report).receipts.contains(ProtectionWords.followDone(kind)),
                    "\(kind): the Done rides the durable notice, never a one-shot receipt")
        }
    }

    /// A scratch defaults suite (never the app's domain), emptied.
    static func scratch(_ name: String) throws -> UserDefaults {
        let suite = "io.lduarte.Variorum.vx309-u2-\(name)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// THE MARK — by library (another library standing in the slot later reads only its own), every kind round-trips, a
    /// later follow's kind replaces an unread one, and it clears only when cleared (the OK). Its key is the calm-asks
    /// ledger's idiom.
    @Test func theMarkIsByLibraryAndClearsOnlyWhenCleared() throws {
        let defaults = try Self.scratch("mark")
        #expect(FollowDoneMark.key("lib-a") == "variorum.calmAsks.followDone.lib-a.kind")
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            FollowDoneMark.set("lib-a", kind, in: defaults)
            #expect(FollowDoneMark.owed("lib-a", in: defaults) == kind)
        }
        #expect(FollowDoneMark.owed("lib-b", in: defaults) == nil, "another library reads only its own mark")
        FollowDoneMark.set("lib-b", .intoCastle, in: defaults)
        FollowDoneMark.set("lib-a", nil, in: defaults)
        #expect(FollowDoneMark.owed("lib-a", in: defaults) == nil && FollowDoneMark.owed("lib-b", in: defaults) == .intoCastle)
        defaults.set("aNameFromALaterBuild", forKey: FollowDoneMark.key("lib-c"))
        #expect(FollowDoneMark.owed("lib-c", in: defaults) == nil, "a name this build doesn't know reads as none")
    }

    /// THE PRESS ARM (the bootstrap's seam reads it): a follow that landed whole owes its Done DURABLY and no receipt; any
    /// other act that landed whole owes its receipt, as before; an act stopped past its swap owes nothing here (the next
    /// open's settle marks it — VX-107's road); a refusal owes nothing.
    @Test func aFollowThatLandedWholeOwesItsDoneDurablyNeverAReceipt() throws {
        let follow = PlantedJoin.follow(.intoCastle)
        let join = PlantedJoin.join()
        let key = StoreKey.mint()
        func result(_ press: RoadAccountPress, whole: Bool) -> AccountActResult {
            AccountActResult(press: press, reopenKey: key, landedWhole: whole)
        }
        let followed = ProtectionAccountRoad.owed(
            after: result(.made(receipt: ProtectionWords.followDone(.intoCastle)), whole: true),
            request: RoadAccountRequest(door: .follow, shown: follow, typed: .none))
        #expect(followed.receipts.isEmpty && followed.followDone == .intoCastle)
        let joined = ProtectionAccountRoad.owed(
            after: result(.made(receipt: "joined", wordsReplaced: true), whole: true),
            request: RoadAccountRequest(door: .turnOnSync, shown: join, typed: .none))
        #expect(joined.receipts == ["joined"] && joined.followDone == nil)
        let pastItsSwap = ProtectionAccountRoad.owed(
            after: result(.made(receipt: ProtectionWords.followDone(.intoCastle)), whole: false),
            request: RoadAccountRequest(door: .follow, shown: follow, typed: .none))
        #expect(pastItsSwap.receipts.isEmpty && pastItsSwap.followDone == nil, "the settle that finishes it marks it")
        let refused = ProtectionAccountRoad.owed(
            after: result(.refused("no"), whole: false),
            request: RoadAccountRequest(door: .follow, shown: follow, typed: .none))
        #expect(refused.receipts.isEmpty && refused.followDone == nil)
    }

    /// THE NOTICE: the section reads the mark at every landing (a fresh model — the relaunch's — finds it standing), and
    /// only its OK clears it.
    @Test func theSectionReadsTheDoneAtEveryLandingAndOnlyOKClearsIt() async throws {
        let defaults = try Self.scratch("section")
        func model() -> RoadAccountModel {
            RoadAccountModel(roads: RoadAccountRoads(
                read: { nil }, press: { _ in .refused("no") },
                followDoneOwed: { FollowDoneMark.owed("lib-a", in: defaults) },
                dismissFollowDone: { FollowDoneMark.set("lib-a", nil, in: defaults) }))
        }
        let first = model()
        await first.refresh()
        #expect(first.followDone == nil, "nothing owed yet")
        FollowDoneMark.set("lib-a", .intoStandard, in: defaults)
        await first.refresh()
        #expect(first.followDone == .intoStandard)
        await first.refresh()
        #expect(first.followDone == .intoStandard, "a re-read never clears it")
        let relaunched = model()
        await relaunched.refresh()
        #expect(relaunched.followDone == .intoStandard, "standing after a relaunch")
        relaunched.followDoneOK()
        #expect(relaunched.followDone == nil && FollowDoneMark.owed("lib-a", in: defaults) == nil, "OK clears the mark")
        await relaunched.refresh()
        #expect(relaunched.followDone == nil)
    }

    /// NEVER ON TODAY'S ROAD (by source): only the new road's files name the mark — the shared account acts (its home and the
    /// press arm's rule), the open's faces (`RoadStandingModel.make`, the settle arm), the account section's model, and
    /// the bootstrap's new-road arms (`accountActOnNewRoad`, `accountRoads`) — never today's follow (`PostureFollowModel`,
    /// `ProtectionController`).
    @Test func onlyTheNewRoadNamesTheMark() throws {
        let app = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        var naming: Set<String> = []
        for folder in ["Shared", "Variorum"] {
            let root = app.appendingPathComponent(folder)
            let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)?
                .compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" } ?? []
            for file in files where try String(contentsOf: file, encoding: .utf8).contains("FollowDoneMark") {
                naming.insert(file.lastPathComponent)
            }
        }
        #expect(naming == ["ProtectionAccountActs.swift", "ProtectionOpenFaces.swift", "RoadAccountModel.swift",
                          "AppBootstrap.swift"], "\(naming)")
        let bootstrap = try String(contentsOf: app.appendingPathComponent("Shared/AppBootstrap.swift"), encoding: .utf8)
        for line in bootstrap.components(separatedBy: "\n") where line.contains("FollowDoneMark.") {
            #expect(line.contains("FollowDoneMark.set(libraryID") || line.contains("FollowDoneMark.owed(libraryID"), "\(line)")
        }
        let accountActs = bootstrap.components(separatedBy: "func accountActOnNewRoad(").last ?? ""
        // VX-329 U1: one road — the press arm sits behind the open road's own guard (its `newRoad` half left with the fork).
        #expect(accountActs.prefix(400).contains("guard case .ready = state, let binding, let session = roadSession, session.writes"),
                "the press arm sits behind the open road's guard")
    }

    /// The notice's words: VX-107's other-device sentence (unchanged) and one button.
    @Test func theNoticeSaysTheDoneWithOneButton() {
        #expect(ProtectionWords.followDoneOK == "OK")
        for kind in [FollowKind.intoCastle, .intoStandard, .keysReplaced] {
            #expect(ProtectionWords.followDone(kind).contains("on another device"))
        }
    }
}
