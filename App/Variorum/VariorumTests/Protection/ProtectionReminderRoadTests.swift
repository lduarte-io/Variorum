//
//  ProtectionReminderRoadTests.swift
//  VariorumTests — VX-306 U2 piece 6: RULE 3 from a real open over planted facts — the model's two moments (the quiet-road moment
//  survives the repair that answers it — `RoadOpenReport.acts` is the union of every pass's), the dismissal recorded
//  through the executor, and THE SET-PASSPHRASE ROAD (P-VX306-U2-0 (a)): the key file gains the passphrase lock, the
//  record's fact flips, the lobby's typed roads now say passphrase; refused once one exists. (The schedule's
//  arithmetic and the sheet's model are `PassphraseReminderTests`'.)
//  (`notes/plans/vx-306-castle-open-road.md` §2 U2 + its addendum; the contract `notes/CastleRules.md`.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U2 — rule 3 on the road (planted facts)")
@MainActor
struct ProtectionReminderRoadTests {
    static let day: (Date) -> String = { ProtectionWords.day($0) }

    // MARK: - Rule 3: the moments, the dismissal, the first passphrase

    /// The model's two moments, read from the open: before the first backup; and at the open after a quiet road failed
    /// — owed at the open's FIRST pass, which the same open's repair then answers (`RoadOpenReport.acts` is the union).
    @Test func theTwoMomentsAreReadFromTheOpen() async throws {
        let road = PlantedRoad()
        let (created, _) = try await road.created()
        #expect(RoadStandingFaces.derive(created.report).passphraseMoment == .beforeFirstBackup)
        let own = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        try road.system().backups.takeBackupPair(with: created.key, keyFile: own, deviceID: created.library.section.deviceID)
        guard case .opened(let quiet) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        #expect(RoadStandingFaces.derive(quiet.report).passphraseMoment == nil, "a backup exists, every road works")
        road.custody.items = [:]
        guard case .opened(let failed) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        #expect(failed.report.repairsDone.contains(.remakeOnDeviceItem), "the open re-made the on-device road …")
        #expect(RoadStandingFaces.derive(failed.report).passphraseMoment == .quietRoadFailed, "… and still asks, once")
    }

    /// A dismissal is ONE record write through the executor.
    @Test func aDismissalIsRecordedInTheLibrarysRecord() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(ProtectionOpenRoad.recordReminderDismissed(session: session))
        #expect(ProtectionOpenRoad.recordReminderDismissed(session: session))
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: session.key))
        #expect(record.reminderDismissals == 2)
        #expect(session.library.record?.reminderDismissals == 2)
    }

    /// THE SET-PASSPHRASE ROAD through the executor (P-VX306-U2-0 (a)): the key file gains the passphrase lock, the
    /// record's `passphraseSet` flips, the lobby's typed roads now include the passphrase and it opens the library;
    /// a second set is refused.
    @Test func theFirstPassphraseIsSetOnTheResetDoorsStandardRoadAndRefusedOnceItExists() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(session.library.record?.passphraseSet == false)
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: " a passphrase ") == .set)
        let live = try #require(try road.system().leaves.keyFiles.readLiveKeyFile())
        #expect(live.passphrase != nil && live.fingerprint == session.library.fingerprint, "the key does not change")
        let record = try #require(try ProtectionLibraryFiles.readRecord(at: road.slot.places.slot, key: session.key))
        #expect(record.passphraseSet)
        #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: "another") == .alreadySet)
        // The lobby (both quiet roads gone) now offers the passphrase, and it opens the library.
        road.custody.items = [:]
        road.apple.keys = [:]
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(road.context()) else { Issue.record("the road did not open as planted"); return }
        #expect(lobby.offeredTyped.contains(.passphrase))
        #expect(ProtectionLobbyFace.derive(lobby).passphraseField)
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(
            road.context(), secret: .passphrase(" a passphrase ")) else {
            Issue.record("the passphrase opens the library")
            return
        }
        #expect(opened.key == session.key)
        #expect(RoadStandingFaces.derive(opened.report).passphraseMoment == nil, "no reminder once a passphrase exists")
    }
}
