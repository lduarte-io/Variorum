//
//  ProtectionNoticeFaceTests.swift
//  VariorumTests — VX-306 U2 piece 2: RULE 21's NOTICE from planted facts — an older copy (her sentence with its date), a different
//  library, none at an ordinary open, none on a read-only road; the interlude's one *OK* goes on once.
//  (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; the contract `notes/CastleRules.md`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 21's notice (planted facts)")
@MainActor
struct ProtectionNoticeFaceTests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    // MARK: - Rule 21: the notice

    /// An OLDER COPY: this Mac remembers the library under its current key, and the live place holds the same library
    /// under another key with that key's own file beside it (a hand-copied older pair) — the notice with the record's
    /// date, then the open; this Mac remembers this one after.
    @Test func anOlderCopyIsSaidOnceWithItsDateThenTheLibraryOpens() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        let libraryID = try #require(created.library.record?.libraryID)
        // The older pair: the same library under K0, its record dated, its key file beside it, a quiet road to K0.
        let older = StoreKey.mint()
        let date = Date(timeIntervalSinceReferenceDate: 780_000_000)
        try Plant.moveLibraryAway(road, to: road.slot.root.appendingPathComponent("kept-aside"))
        let record = ProtectionRecord.minting(
            libraryID: libraryID, mode: .standard, account: nil,
            currentFingerprint: StoreKeyEnvelope.fingerprint(of: older), at: date)
        try road.system().leaves.library.createLibrary(with: older, record: record)
        try road.system().leaves.keyFiles.writeLiveKeyFile(try Plant.keyFile(older, libraryID: libraryID))
        try road.custody.writeCustody(older, itemClass: .silent, libraryID: libraryID)

        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the older copy opens by its quiet road")
            return
        }
        #expect(session.report.notice == LibraryNotice(kind: .olderCopy(date: date)))
        #expect(session.owesInterlude)
        let cards = RoadInterlude.cards(session.report)
        #expect(cards == [.notice(LibraryNotice(kind: .olderCopy(date: date)))])
        let sentence = RoadInterlude.sentence(try #require(cards.first), day: Self.day)
        #expect(sentence == "This is an older copy of your library, from \(Self.day(date))")
        #expect(sentence == LibraryNotice.olderCopyWords.replacingOccurrences(of: "<date>", with: Self.day(date)))
        // The open's repairs already made this Mac remember this one: the next open says nothing.
        #expect(session.report.repairsDone.contains(.refreshMemory))
        guard case .opened(let again) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the next open")
            return
        }
        #expect(again.report.notice == nil && !again.owesInterlude, "said ONCE")
    }

    /// A DIFFERENT LIBRARY: this Mac last opened another library (it remembers only that one).
    @Test func aDifferentLibraryIsSaidOnce() async throws {
        let road = PlantedRoad()
        let (first, _) = try await road.created()
        let aside = road.slot.root.appendingPathComponent("first-aside")
        try Plant.moveLibraryAway(road, to: aside)
        // A second library made here: this Mac now remembers only it (rule 21: ONE library).
        guard case .created(let second, _) = await ProtectionOpenRoad.create(road.context(), setAsideLiveKeyFile: false)
        else {
            Issue.record("a second library is made in the empty slot")
            return
        }
        #expect(road.memory.items.keys.sorted() == [try #require(second.library.record?.libraryID)])
        try Plant.moveLibraryAway(road, to: road.slot.root.appendingPathComponent("second-aside"))
        try Plant.moveLibraryBack(road, from: aside)
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the first library opens by its own quiet road")
            return
        }
        #expect(session.key == first.key)
        #expect(session.report.notice == LibraryNotice(kind: .differentLibrary))
        let sentence = RoadInterlude.sentence(try #require(RoadInterlude.cards(session.report).first), day: Self.day)
        #expect(sentence == LibraryNotice.differentLibraryWords)
    }

    /// No disagreement, no notice — and a read-only road (a hosted test run) never owes the interlude.
    @Test func anOrdinaryOpenSaysNothingAndAReadOnlyRoadNeverInterrupts() async throws {
        let road = PlantedRoad()
        _ = try await road.created()
        guard case .opened(let session) = await ProtectionOpenRoad.route(road.context()) else {
            Issue.record("the quiet reopen")
            return
        }
        #expect(RoadInterlude.cards(session.report).isEmpty && !session.owesInterlude)
        try Plant.strayBeside(road)
        guard case .opened(let readOnly) = await ProtectionOpenRoad.route(road.context(writes: false)) else {
            Issue.record("read-only still opens")
            return
        }
        #expect(!RoadInterlude.cards(readOnly.report).isEmpty, "the offer is owed …")
        #expect(!readOnly.owesInterlude, "… but a read-only road shows no interlude (nothing could act)")
    }

    /// The interlude's *OK*: the notice goes, the open goes on ONCE.
    @Test func theNoticesOneButtonGoesOnOnce() {
        var finished = 0
        let model = RoadInterludeModel(
            cards: [.notice(LibraryNotice(kind: .differentLibrary))], day: Self.day,
            useOffer: { _ in .failed }, receipt: { _ in }, finished: { finished += 1 })
        #expect(model.sentence == LibraryNotice.differentLibraryWords)
        model.notNow()
        #expect(finished == 0 && model.current != nil, "the notice has one button — OK")
        model.ok()
        #expect(finished == 1 && model.current == nil)
        model.ok()
        #expect(finished == 1)
    }
}
