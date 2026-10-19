//
//  ExportNoticeByLibraryTests.swift
//  VariorumTests — VX-308 U4 piece 2: NIT-R2-1 (`notes/plans/vx-307-ladder-round-2.md`) — RULE 11's durable export-off
//  notice is marked BY LIBRARY (`ExportNoticeMark`, the code the production switch runs — `AppBootstrap
//  .markdownInsuranceSwitch`), so a ready of ANOTHER library standing in the slot (Make this my library; a library moved in
//  by hand) never clears a notice she has not answered; the not-in-Castle clear fires only for the library that wrote it;
//  an earlier build's unkeyed mark migrates onto the first library consulted. Over planted roads (no keychain) and a
//  throwaway defaults suite — also runs headless in the implementer's SwiftPM harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// A scheduled-export switch over THE PRODUCTION MARK (`ExportNoticeMark`) in a throwaway defaults suite; the weekly
/// switch itself in memory.
nonisolated final class MarkedExportSwitch: @unchecked Sendable {
    let store = ThrowawayDefaults()
    private let lock = NSLock()
    private var on: Bool

    init(_ on: Bool) { self.on = on }

    var value: Bool { lock.withLock { on } }
    func owed(_ libraryID: String) -> Bool { ExportNoticeMark.owed(libraryID, in: store.defaults) }

    var road: ScheduledExportSwitch {
        let store = store
        return ScheduledExportSwitch(
            isOn: { self.value },
            set: { value in self.lock.withLock { self.on = value } },
            noticeOwed: { ExportNoticeMark.owed($0, in: store.defaults) },
            setNoticeOwed: { ExportNoticeMark.set($0, owed: $1, in: store.defaults) })
    }
}

@Suite("VX-308 U4 — NIT-R2-1: rule 11's notice is marked by library (planted, a throwaway suite)")
@MainActor
struct ExportNoticeByLibraryTests {
    /// Library A enters Castle with the weekly copy on (the notice owed — A's); library B stands at ready (not in Castle):
    /// its reconcile and its *OK* leave A's notice owed; A's own ready keeps it until A's *OK*; A leaving Castle clears
    /// A's at A's ready. RED before NIT-R2-1 (one mark per defaults domain): B's ready cleared A's notice.
    @Test func anotherLibrarysReadyNeverClearsANoticeItDidNotWrite() async throws {
        let exports = MarkedExportSwitch(true)
        defer { exports.store.purge() }
        let roadA = PlantedRoad()
        let (a, wordsA) = try await roadA.created()
        let entered = await ProtectionCrossings.cross(
            a, door: .useCastle, typed: TypedSecrets(words: wordsA, newPassphrase: Crossing.passphrase), gate: .alwaysAsk,
            exportSwitch: exports.road)
        #expect(entered.outcome == .made(.useCastle, exportTurnedOff: true))
        let idA = try #require(a.library.record?.libraryID)
        #expect(exports.owed(idA) && !exports.value, "rule 11: A's notice owed, the weekly copy off")

        // Another library at ready — Standard, not the one that entered.
        let roadB = PlantedRoad()
        let (b, _) = try await roadB.created()
        let idB = try #require(b.library.record?.libraryID)
        #expect(idA != idB)
        #expect(!ProtectionCrossings.reconcileExport(b.library, exportSwitch: exports.road))
        #expect(exports.owed(idA), "B's ready never clears A's unanswered notice")
        #expect(!exports.owed(idB), "and B owes none")
        ProtectionCrossings.dismissExportNotice(exportSwitch: exports.road, libraryID: idB)
        #expect(exports.owed(idA), "B's OK answers nothing of A's")

        // A back at ready (Castle, its sealed export off): still owed until A's OK.
        #expect(!ProtectionCrossings.reconcileExport(a.library, exportSwitch: exports.road))
        #expect(exports.owed(idA))

        // A leaves Castle: A's own ready clears A's mark (the not-in-Castle arm, for the library that wrote it).
        let left = await ProtectionCrossings.cross(
            a, door: .useStandard, typed: TypedSecrets(passphrase: Crossing.passphrase, words: wordsA), gate: .alwaysAsk,
            exportSwitch: exports.road)
        #expect(left.outcome == .made(.useStandard, exportTurnedOff: false))
        #expect(!ProtectionCrossings.reconcileExport(a.library, exportSwitch: exports.road))
        #expect(!exports.owed(idA))
    }

    /// An earlier build's UNKEYED mark (`ExportNoticeMark.legacyKey` — VX-307 MAJOR-1's one per domain) migrates onto the
    /// FIRST library whose mark is consulted (the first ready's reconcile), the legacy key then gone; never anyone else's.
    @Test func anEarlierBuildsUnkeyedMarkMigratesOntoTheFirstLibraryConsulted() {
        let store = ThrowawayDefaults()
        defer { store.purge() }
        store.defaults.set(true, forKey: ExportNoticeMark.legacyKey)
        #expect(ExportNoticeMark.owed("library-a", in: store.defaults), "adopted by the first library consulted")
        #expect(store.defaults.object(forKey: ExportNoticeMark.legacyKey) == nil, "the legacy key is gone")
        #expect(!ExportNoticeMark.owed("library-b", in: store.defaults), "never anyone else's")
        // A legacy mark already answered (false) is only removed; a write adopts first too.
        store.defaults.set(false, forKey: ExportNoticeMark.legacyKey)
        ExportNoticeMark.set("library-c", owed: true, in: store.defaults)
        #expect(store.defaults.object(forKey: ExportNoticeMark.legacyKey) == nil)
        #expect(ExportNoticeMark.owed("library-c", in: store.defaults) && ExportNoticeMark.owed("library-a", in: store.defaults))
        ExportNoticeMark.set("library-c", owed: false, in: store.defaults)
        #expect(!ExportNoticeMark.owed("library-c", in: store.defaults) && ExportNoticeMark.owed("library-a", in: store.defaults))
    }

    /// The key, by library (the per-library ledger idiom — `variorum.calmAsks.<topic>.<libraryID>.*`).
    @Test func theKeyCarriesTheLibrarysID() {
        #expect(ExportNoticeMark.key("abc") == "variorum.calmAsks.exportOffNotice.abc.owed")
        #expect(ExportNoticeMark.key("abc") != ExportNoticeMark.key("abd"))
        #expect(ExportNoticeMark.legacyKey == "variorum.protection.exportOffNoticeOwed")
    }
}
