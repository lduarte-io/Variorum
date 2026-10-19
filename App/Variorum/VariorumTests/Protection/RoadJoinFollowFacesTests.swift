//
//  RoadJoinFollowFacesTests.swift
//  VariorumTests — VX-308 U2 piece 2: THE JOIN'S AND THE FOLLOW'S FACES over the pane's one read on the new road's PLANTED
//  leaves (a real library on the planted road, the planted vault — no network, no keychain; also runs headless in the
//  implementer's SwiftPM harness). Every door reads `assess` over that read: the join's three plans said at the consent
//  (entering Castle — Use Castle's own words and the gate choice; leaving it — rule 12's sentence; the same posture),
//  ONE of the account's secrets (rule 14); Move (rule 16's leave, then the join) and its two other arms; the follow's three
//  kinds (one secret into Castle and on a replaced key, the gate into Castle, nothing out of it — rule 12's sentence said),
//  its notice naming the vault's last writer and day; VX-113's refusal sentence. The record-binding states are planted
//  facts of the real library, mutated per state (U1's and U2a's idiom); the acts are piece 3's.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U2 — the join's and the follow's faces (planted, no network)")
@MainActor
struct RoadJoinFollowFacesTests {
    typealias Account = PlantedAccount

    private func library(castle: Bool = false) async throws -> (road: PlantedRoad, vault: PlantedVaultLeaf, session: ProtectionRoadSession) {
        let (road, vault, _) = Account.road()
        let session: ProtectionRoadSession
        if castle {
            session = try await Crossing.inCastle(road).session
        } else {
            session = try await road.created().session
        }
        return (road, vault, session)
    }

    /// The read with the record bound to `account` (following the vault's current sync key unless told otherwise).
    private func bound(
        _ read: ProtectionPaneFacts, to account: String, vault: PlantedVaultLeaf, followsCurrentKey: Bool = true
    ) -> ProtectionPaneFacts {
        var read = read
        read.facts.unlocked?.record.account = account
        read.facts.unlocked?.record.accountRowKeyID = followsCurrentKey ? vault.snapshot(account)?.rowKeyID : "an-older-key"
        return read
    }

    private func faces(_ read: ProtectionPaneFacts) throws -> RoadAccountFaces {
        try #require(ProtectionPaneRead.accountFaces(read))
    }

    private func plant(_ vault: PlantedVaultLeaf, _ mode: ProtectionMode) throws {
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase, words: try RecoveryPhrase.generate(),
                        mode: mode)
    }

    // MARK: - The join

    /// A Standard library joining a CASTLE account is entering Castle: the consent says so, with Use Castle's own words
    /// (rule 9's promise, what entering does, the floor, the export-first line) and the gate choice; one secret; it re-keys.
    @Test func joiningACastleAccountEntersCastleAndSaysSo() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .castle)
        let join = try #require(try faces(try await Account.read(session, Account.signedIn)).turnOnSync.openDoor)
        #expect(join.spec.join == .entersCastle && join.ask == .oneSecret && join.rekeys && join.follow == nil)
        #expect(join.sentences == [
            ProtectionWords.joinLead, ProtectionWords.onePairAtATime,
            ProtectionWords.joinPlanLine(.entersCastle, library: .standard)!, ProtectionWords.castlePromise,
            ProtectionWords.useCastleLead, ProtectionWords.castleFloor, ProtectionWords.exportAPlainCopyFirst,
        ])
        #expect(join.gate == RoadGateChoice(touchIDAvailable: false, preselected: .alwaysAsk))
        #expect(join.receipt == ProtectionWords.joinedReceipt(.entersCastle, moved: false))
        // This Mac's scheduled export on: the door says it turns off (rule 11 — the join's own `exportOff` step).
        var exporting = try await Account.read(session, Account.signedIn)
        exporting.facts.unlocked?.thisMac.settings.scheduledExport = true
        #expect(try faces(exporting).turnOnSync.openDoor?.sentences.last == ProtectionWords.scheduledExportTurnsOff)
    }

    /// A Castle library joining a STANDARD account is leaving Castle: rule 12's leave sentence at the consent (`ruleFive`
    /// — hers); no gate; it re-keys.
    @Test func joiningAStandardAccountLeavesCastleAndSaysRule12() async throws {
        let (_, vault, session) = try await library(castle: true)
        try plant(vault, .standard)
        let join = try #require(try faces(try await Account.read(session, Account.signedIn)).turnOnSync.openDoor)
        #expect(join.spec.join == .leavesCastle && join.ask == .oneSecret && join.rekeys && join.gate == nil)
        #expect(join.sentences == [
            ProtectionWords.joinLead, ProtectionWords.onePairAtATime,
            ProtectionWords.joinPlanLine(.leavesCastle, library: .castle)!, ProtectionWords.leaveSentence,
        ])
    }

    /// The same posture: the key stays (no re-key — it runs on the open session); the plan line, nothing more.
    @Test func joiningInTheSamePostureKeepsTheKey() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .standard)
        let join = try #require(try faces(try await Account.read(session, Account.signedIn)).turnOnSync.openDoor)
        #expect(join.spec.join == .sameMode && join.ask == .oneSecret && !join.rekeys && join.gate == nil)
        #expect(join.sentences == [ProtectionWords.joinLead, ProtectionWords.onePairAtATime,
                                   "Your account is in Standard, like this library."])
        #expect(join.receipt == ProtectionWords.joinedReceipt(.sameMode, moved: false))
    }

    /// MOVE (another account signed in, and it already syncs): rule 16's leave said first, then the join; the door names
    /// the account signed in. Its vault unreadable → said; no vault there → the honest not-yet line (P-VX308-U2-6).
    @Test func moveLeavesThenJoinsAndItsOtherArmsSayWhy() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .standard)
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.other, vault: vault)
        let faces = try faces(read)
        #expect(faces.situation == .otherAccount(signedInEmail: Account.email, sameEmail: false))
        let move = try #require(faces.move.openDoor)
        #expect(move.door == .moveToSignedInAccount && move.doorLabel == ProtectionWords.moveDoor(Account.email))
        #expect(move.ask == .oneSecret && move.spec.join == .sameMode && !move.rekeys)
        #expect(move.sentences == [
            ProtectionWords.moveLead, ProtectionWords.ruleSixteen, ProtectionWords.joinLead, ProtectionWords.onePairAtATime,
            "Your account is in Standard, like this library.",
        ])
        #expect(move.receipt == ProtectionWords.joinedReceipt(.sameMode, moved: true))
        #expect(faces.face(.moveToSignedInAccount) == faces.move)
        var unreadable = read
        unreadable.vault = .unreachable
        #expect(try self.faces(unreadable).move == .refused(ProtectionWords.doorRefusedNeedsVault))
        let (_, emptyVault, emptySession) = try await library()
        let none = bound(try await Account.read(emptySession, Account.signedIn), to: Account.other, vault: emptyVault)
        #expect(try self.faces(none).move == .notYet(ProtectionWords.moveNotYet))
    }

    // MARK: - The follow

    /// INTO CASTLE (the account entered elsewhere): the notice names the vault's last writer and its day; rule 10's
    /// "said plainly"; one secret; the gate choice (the follow's own default); with the export on, rule 11's sentence.
    @Test func theFollowIntoCastleAsksOneSecretWithTheGateChoice() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .castle)
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault)
        let faces = try faces(read)
        #expect(faces.situation == .inSync(email: Account.email))
        let follow = try #require(faces.follow.openDoor)
        let notice = ProtectionWords.followNotice(.intoCastle, device: "Another Mac", day: ProtectionWords.day(vault.clock))
        #expect(follow.door == .follow && follow.follow == .intoCastle && follow.notice == notice)
        #expect(follow.ask == .oneSecret && follow.rekeys && follow.gate?.preselected == .alwaysAsk)
        #expect(follow.sentences == [notice, ProtectionWords.followUntilThen, ProtectionWords.followAsk(.intoCastle)])
        #expect(follow.receipt == ProtectionWords.followDone(.intoCastle))
        #expect(faces.stopSyncingHere == .refused(ProtectionWords.doorRefusedFollowOwed), "the other doors wait for it")
        var exporting = read
        exporting.facts.unlocked?.thisMac.settings.scheduledExport = true
        #expect(try self.faces(exporting).follow.openDoor?.sentences.last == ProtectionWords.scheduledExportTurnsOff)
    }

    /// OUT OF CASTLE (rule 12: "other devices follow out quietly, with a notice"): nothing typed; rule 12's sentence said.
    @Test func theFollowOutOfCastleIsQuietAndSaysRule12() async throws {
        let (_, vault, session) = try await library(castle: true)
        try plant(vault, .standard)
        let follow = try #require(try faces(bound(
            try await Account.read(session, Account.signedIn), to: Account.account, vault: vault)).follow.openDoor)
        #expect(follow.follow == .intoStandard && follow.ask == .nothing && follow.gate == nil && follow.rekeys)
        #expect(follow.sentences == [
            ProtectionWords.followNotice(.intoStandard, device: "Another Mac", day: ProtectionWords.day(vault.clock)),
            ProtectionWords.leaveSentence, ProtectionWords.followAsk(.intoStandard),
        ])
        #expect(follow.receipt == ProtectionWords.followDone(.intoStandard))
    }

    /// A REPLACED KEY in the same posture (the library lagged through an entry): one secret to catch up; no gate.
    @Test func aReplacedKeyCatchesUpWithOneSecret() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .standard)
        let follow = try #require(try faces(bound(
            try await Account.read(session, Account.signedIn), to: Account.account, vault: vault, followsCurrentKey: false))
            .follow.openDoor)
        #expect(follow.follow == .keysReplaced && follow.ask == .oneSecret && follow.gate == nil)
        #expect(follow.sentences.last == ProtectionWords.followAsk(.keysReplaced))
        #expect(follow.receipt == ProtectionWords.followDone(.keysReplaced))
    }

    /// No follow owed (in sync, the same posture, the current sync key): the follow renders nothing (P-2).
    @Test func noFollowOwedRendersNothing() async throws {
        let (_, vault, session) = try await library()
        try plant(vault, .standard)
        let faces = try faces(bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault))
        #expect(faces.follow == .hidden && faces.stopSyncingHere.openDoor != nil)
    }

    // MARK: - VX-113

    /// VX-113 — the old passphrase after a change elsewhere: the refusal names the device and the day (her #205 (ii)).
    @Test func vx113_theChangedElsewhereRefusalNamesTheDeviceAndTheDay() {
        let day = Date(timeIntervalSinceReferenceDate: 790_000_000)
        let said = RoadAccountFaces.actRefusalSentence(
            ExecutorRefusal.passphraseChangedElsewhere(device: "Studio Mac", day: day), unfinished: false)
        #expect(said == "Your passphrase was changed on Studio Mac on \(ProtectionWords.day(day)).")
        #expect(RoadAccountFaces.actRefusalSentence(
            ExecutorRefusal.passphraseChangedElsewhere(device: nil, day: nil), unfinished: false)
            == "Your passphrase was changed on another device.")
    }
}
