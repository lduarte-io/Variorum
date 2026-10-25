//
//  PairFollowFacesTests.swift
//  VariorumTests — VX-529 unit 2, scopes 1 and 6 (`notes/plans/fixes/vx-529-pair-catchup.md`): THE PAIR CATCH-UP'S FACES
//  — the follow sheet's pair kind (the half, the device and the day; one of the account's current secrets where the
//  passphrase moved, nothing where only the words did, E14's one secret where this Mac holds no account keys; the second
//  road said beside it), the account section's DURABLE notice for it (the pair kinds by their halves, R-529-5's words arm
//  with its window and Reset chain, the lobby's heal), and the OPEN-SESSION follow's Done made durable by the seam's own
//  rule (the run record's F-U2-1). Over planted leaves and pure values (no keychain, no network; headless in the
//  implementer's SwiftPM harness too).
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 2 — the pair catch-up's faces: the sheet, the durable notice, the open session's Done")
@MainActor
struct PairFollowFacesTests {
    typealias Account = PlantedAccount
    typealias Planted = PairPreflightAndGateTests

    static func day(_ world: Planted.World) throws -> String? {
        try #require(world.vault.snapshot(Account.account)).updatedAt.map { ProtectionWords.day($0) }
    }

    static func followDoor(_ session: ProtectionRoadSession) async throws -> RoadAccountDoorOpen {
        let read = try await Account.read(session, Account.signedIn)
        let faces = try #require(ProtectionPaneRead.accountFaces(read, session: session))
        return try #require(faces.follow.openDoor, "\(faces.follow)")
    }

    /// Another device re-made the account's TWELVE WORDS (a key door there: the vault's recovery wrap re-made, nothing
    /// else moved) — the planted vault written the way `VaultModel` writes it.
    static func wordsChangedElsewhere(
        _ vault: PlantedVaultLeaf, passphrase: String, to words: [String], device: String = "Studio Mac"
    ) throws {
        let snapshot = try #require(vault.snapshot(Account.account))
        let master = try #require(snapshot.vault.master(
            passphrase: try PassphraseKey.derive(passphrase, kdf: snapshot.vault.kdf), words: nil))
        var account = try #require(vault.accounts[Account.account])
        account.vault = try VaultModel.rewrappingWords(
            snapshot.vault, master: master, words: try WordsKey.derive(words), device: device)
        account.revision += 1
        account.updatedAt = (account.updatedAt ?? Date()).addingTimeInterval(3600)
        vault.accounts[Account.account] = account
    }

    // MARK: - The follow sheet's pair kind (scope 1)

    /// THE PASSPHRASE MOVED: the door names the half, the device and the day; it asks ONE of the account's current secrets
    /// (R-529-5 — the passphrase or the words); the second road is said beside it (P-VX529-2); no gate, no re-key.
    @Test func thePassphraseHalfAsksOneOfTheAccountsCurrentSecrets() async throws {
        let world = try await Planted.joinedWorld()
        try Planted.passphraseChangedElsewhere(world, to: "a passphrase made elsewhere")
        let door = try await Self.followDoor(world.session)
        let kind = FollowKind.pairChanged(passphrase: true, words: false)
        let notice = ProtectionWords.followNotice(kind, device: "Studio Mac", day: try Self.day(world))
        #expect(door.follow == kind && !door.rekeys && door.gate == nil)
        #expect(door.ask == .oneSecret)
        #expect(door.notice == notice && notice.hasPrefix("Your account's passphrase was changed on Studio Mac on "))
        #expect(door.sentences == [notice, ProtectionWords.followAsk(kind), ProtectionWords.pairSecondRoad])
        #expect(door.receipt == ProtectionWords.followDone(kind))
    }

    /// THE WORDS MOVED ALONE (R-529-2 — quiet): nothing typed while this Mac holds the account's keys (Standard — its silent
    /// item); the ask sentence says so; the second road said.
    @Test func theWordsHalfIsQuietWhileThisMacHoldsTheAccountsKeys() async throws {
        let world = try await Planted.joinedWorld()
        try Self.wordsChangedElsewhere(world.vault, passphrase: Account.passphrase, to: Planted.newWords)
        let door = try await Self.followDoor(world.session)
        let kind = FollowKind.pairChanged(passphrase: false, words: true)
        #expect(door.follow == kind && door.ask == .nothing)
        #expect(door.sentences == [ProtectionWords.followNotice(kind, device: "Studio Mac", day: try Self.day(world)),
                                   ProtectionWords.followAsk(kind), ProtectionWords.pairSecondRoad])
        #expect(ProtectionWords.followAsk(kind).contains("without asking you for anything"))
    }

    /// E14 (the architect's ruling): Castle Always ask, opened by its old words — no account keys in this Mac's session, no
    /// item — the words-only catch-up asks ONE secret, said; the press with the account's new words lands it and nothing is
    /// owed after.
    @Test func e14_aWordsOnlyCatchUpWithNoKeysInHandAsksOneSecret() async throws {
        let world = try await TypedUnlockSyncKeysTests.castleAlwaysAskSynced()
        try Self.wordsChangedElsewhere(world.vault, passphrase: Account.passphrase, to: Planted.newWords)
        // While the session holds the keys (the act that set it up held them): quiet.
        let held = try await Self.followDoor(world.session)
        #expect(held.ask == .nothing, "the session's keys serve — quiet")
        TouchIDUnlockSyncKeysTests.relaunched(world)
        let door = try await Self.followDoor(world.session)
        #expect(door.follow == .pairChanged(passphrase: false, words: true))
        #expect(door.ask == .oneSecret && door.sentences.contains(ProtectionWords.pairNeedsASecret))
        #expect(!door.sentences.contains(ProtectionWords.followAsk(.pairChanged(passphrase: false, words: true))))
        let press = await ProtectionAccountRoad.press(
            world.session, request: RoadAccountRequest(door: .follow, shown: door, typed: TypedSecrets(words: Planted.newWords)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(press == .made(receipt: ProtectionWords.followDone(.pairChanged(passphrase: false, words: true))), "\(press)")
        let faces = try #require(ProtectionPaneRead.accountFaces(try await Account.read(world.session, Account.signedIn)))
        #expect(faces.follow == .hidden, "nothing owed after")
    }

    // MARK: - The durable notice (scopes 1, 6)

    /// THE MARK carries every notice, by name, and reads each back; `owed` (a follow's kind) maps the words arm to the pair
    /// kind whose passphrase moved and the heal to none; a name a later build writes reads as none.
    @Test func theMarkCarriesEveryNotice() throws {
        let defaults = try FollowDoneNoticeTests.scratch("vx529-u2-notices")
        let notices: [FollowDoneNotice] = [
            .intoCastle, .intoStandard, .keysReplaced,
            .followed(.pairChanged(passphrase: true, words: false)), .followed(.pairChanged(passphrase: false, words: true)),
            .followed(.pairChanged(passphrase: true, words: true)), .followed(.pairChanged(passphrase: false, words: false)),
            .caughtUpByTheWords(wordsToo: false), .caughtUpByTheWords(wordsToo: true), .passphraseLanded,
        ]
        for notice in notices {
            FollowDoneMark.set("lib", notice: notice, in: defaults)
            #expect(FollowDoneMark.notice("lib", in: defaults) == notice, "\(notice)")
        }
        FollowDoneMark.set("lib", notice: .caughtUpByTheWords(wordsToo: true), in: defaults)
        #expect(FollowDoneMark.owed("lib", in: defaults) == .pairChanged(passphrase: true, words: true))
        FollowDoneMark.set("lib", notice: .passphraseLanded, in: defaults)
        #expect(FollowDoneMark.owed("lib", in: defaults) == nil, "the heal is no follow")
        // Unit 1's name (a settle's halves-unknown pair kind) reads back.
        defaults.set("pairChanged", forKey: FollowDoneMark.key("lib"))
        #expect(FollowDoneMark.owed("lib", in: defaults) == .pairChanged(passphrase: false, words: false))
        FollowDoneMark.set("lib", notice: nil, in: defaults)
        #expect(FollowDoneMark.notice("lib", in: defaults) == nil)
    }

    /// WHAT THE NOTICE SAYS: the pair kind names its half and what the old secrets open now (E8 — the words recorded before
    /// no longer open this library; the backups made with them do); the words arm says the window and the Reset chain; the
    /// heal says the account's passphrase opens it here now; a settle's halves-unknown Done says either.
    @Test func theNoticeSaysWhatChangedAndWhatOpensNow() {
        let device = ProtectionCopy.deviceName
        #expect(ProtectionWords.followDoneNotice(.followed(.pairChanged(passphrase: false, words: true)))
            == "Your account's twelve words were changed on another device, and this \(device) caught up. The twelve words "
                + "you had before no longer open this library; backups you made with them still do.")
        #expect(ProtectionWords.followDoneNotice(.followed(.pairChanged(passphrase: true, words: false)))
            == "Your account's passphrase was changed on another device, and this \(device) caught up. Your previous "
                + "passphrase no longer opens this library; backups you made with it still do.")
        #expect(ProtectionWords.followDoneNotice(.followed(.pairChanged(passphrase: false, words: false)))
            == "Your account's passphrase or twelve words were changed on another device, and this \(device) caught up.")
        let byWords = ProtectionWords.followDoneNotice(.caughtUpByTheWords(wordsToo: false))
        #expect(byWords.hasPrefix("Your account's passphrase was changed on another device, and this \(device) caught up "
            + "with your twelve words."))
        #expect(byWords.contains(ProtectionWords.pairWordsWindow) && byWords.contains(ProtectionWords.pairResetChain))
        #expect(ProtectionWords.followDoneNotice(.passphraseLanded) == ProtectionWords.passphraseLandedNotice)
        #expect(ProtectionWords.followDoneNotice(.intoCastle) == ProtectionWords.followDone(.intoCastle), "unchanged")
    }

    /// Her no-shouty-caps rule over every new line.
    @Test func noPairLineShouts() {
        var lines = [ProtectionWords.pairSecondRoad, ProtectionWords.pairNeedsASecret, ProtectionWords.pairWordsWindow,
                     ProtectionWords.pairResetChain, ProtectionWords.passphraseLandedNotice,
                     ProtectionWords.followFirstToCatchUpRoad]
        for (passphrase, words) in [(true, false), (false, true), (true, true), (false, false)] {
            let kind = FollowKind.pairChanged(passphrase: passphrase, words: words)
            lines += [ProtectionWords.followNotice(kind, device: "Studio Mac", day: "October 24"),
                      ProtectionWords.followAsk(kind), ProtectionWords.followDone(kind)]
        }
        lines += [ProtectionWords.followDoneNotice(.caughtUpByTheWords(wordsToo: true))]
        for line in lines {
            let shouting = line.split(whereSeparator: { !$0.isLetter }).filter { word in
                word.count > 1 && word == word.uppercased() && !["OK", "ID"].contains(String(word))
            }
            #expect(shouting.isEmpty, "\(line) — \(shouting)")
            #expect(line.first?.isUppercase == true && line.last == ".", "\(line)")
        }
    }

    // MARK: - The open session's Done (F-U2-1)

    /// THE SEAM'S OWN RULE ON THE OPEN SESSION: a follow that landed there owes its Done durably and no receipt — its kind,
    /// or R-529-5's words arm where the passphrase moved and only the words were typed; every other act keeps its receipt;
    /// a refusal owes nothing.
    @Test func anOpenSessionFollowOwesItsDoneDurablyNeverAReceipt() {
        let pair = FollowKind.pairChanged(passphrase: true, words: false)
        let door = RoadAccountDoorOpen(
            door: .follow, ask: .oneSecret, newPassphrase: false, sentences: [],
            spec: DoorSpec(requires: .oneSecret, synced: true), follow: pair)
        let made = RoadAccountPress.made(receipt: ProtectionWords.followDone(pair))
        let byPassphrase = ProtectionAccountRoad.openSessionLanding(
            made, request: RoadAccountRequest(door: .follow, shown: door, typed: TypedSecrets(passphrase: "p")))
        #expect(byPassphrase.press == .made(receipt: nil) && byPassphrase.followDone == .followed(pair))
        let byWords = ProtectionAccountRoad.openSessionLanding(
            made, request: RoadAccountRequest(door: .follow, shown: door, typed: TypedSecrets(words: Planted.newWords)))
        #expect(byWords.press == .made(receipt: nil) && byWords.followDone == .caughtUpByTheWords(wordsToo: false))
        let both = ProtectionAccountRoad.openSessionLanding(
            made, request: RoadAccountRequest(
                door: .follow, shown: door, typed: TypedSecrets(passphrase: "p", words: Planted.newWords)))
        #expect(both.followDone == .followed(pair), "the passphrase typed wins — the core's own arm")
        let refused = ProtectionAccountRoad.openSessionLanding(
            .refused("no"), request: RoadAccountRequest(door: .follow, shown: door, typed: .none))
        #expect(refused.press == .refused("no") && refused.followDone == nil)
        let leave = PlantedAccountRoads.leave(.stopSyncingHere)
        let left = ProtectionAccountRoad.openSessionLanding(
            .made(receipt: ProtectionWords.stopSyncingReceipt),
            request: RoadAccountRequest(door: .stopSyncingHere, shown: leave, typed: .none))
        #expect(left.press == .made(receipt: ProtectionWords.stopSyncingReceipt) && left.followDone == nil)
    }

    /// THE WORDS ARM'S SHEET (R-529-5): the catch-up landed by the twelve words — the sheet says the window and the Reset
    /// chain beside its round; the passphrase arm says neither.
    @Test func theWordsArmsSheetSaysTheWindowAndTheResetChain() async {
        let door = RoadAccountDoorOpen(
            door: .follow, ask: .oneSecret, newPassphrase: false, sentences: [],
            spec: DoorSpec(requires: .oneSecret, synced: true), follow: .pairChanged(passphrase: true, words: false))
        let byWords = RoadAccountConfirmModel(
            door: door, act: { _ in .made(receipt: nil) }, firstRound: { .notConfigured }, finished: { _ in })
        await byWords.submit(words: Planted.newWords.joined(separator: " "))
        #expect(byWords.landedLines == [ProtectionWords.pairWordsWindow, ProtectionWords.pairResetChain])
        let byPassphrase = RoadAccountConfirmModel(
            door: door, act: { _ in .made(receipt: nil) }, firstRound: { .notConfigured }, finished: { _ in })
        await byPassphrase.submit(passphrase: "a passphrase made elsewhere")
        #expect(byPassphrase.landedLines.isEmpty)
        _ = await byWords.awaitFirstRound()
        _ = await byPassphrase.awaitFirstRound()
    }
}

/// F-U2-1 END TO END — the bootstrap over the planted road, the app's real services, a fake server
/// (`FirstRoundAfterTheActTests`' world): the pair catch-up pressed through the account section lands on the OPEN session and
/// its Done is the section's DURABLE notice (VX-457's mark, by library) — RED by behavioral revert (the run record's RV-P1-1:
/// the open-session arm marked nothing; its `.made` carried the Done as a one-shot receipt).
@Suite("VX-529 unit 2 — F-U2-1: the open-session follow's Done is durable (bootstrap, real services)", .serialized)
@MainActor
struct PairFollowDoneDurableTests {
    typealias Account = PlantedAccount

    @Test func thePairCatchUpsDoneStandsAsTheSectionsNotice() async throws {
        try await FirstRoundWorld.run { world in
            let services = try await world.composeServices()
            try await world.settlePreActRounds(services)
            let setUp = try await world.turnOnSync()
            _ = await setUp.awaitFirstRound()
            setUp.done()
            let account = try #require(world.bootstrap.roadAccount)
            let libraryID = try #require(world.bootstrap.roadSession?.library.record?.libraryID)
            let defaults = try #require(UserDefaults(suiteName: PassphraseReminderLedger.testSuiteName))
            FollowDoneMark.set(libraryID, nil, in: defaults)
            // Another device re-makes the account's passphrase (the set-up handed this library's pair up — rule 7).
            let snapshot = try #require(world.vault.snapshot(Account.account))
            let master = try #require(snapshot.vault.master(
                passphrase: try PassphraseKey.derive(Account.passphrase, kdf: snapshot.vault.kdf), words: nil))
            var row = try #require(world.vault.accounts[Account.account])
            row.vault = try VaultModel.rewrappingPassphrase(
                snapshot.vault, master: master,
                passphrase: try PassphraseKey.derive("a passphrase made elsewhere", kdf: FastIDsLeaf().mintPassphraseKDF()),
                device: "Studio Mac")
            row.revision += 1
            world.vault.accounts[Account.account] = row
            await account.refresh()
            let door = try #require(account.faces?.follow.openDoor, "\(String(describing: account.faces?.follow))")
            #expect(door.follow == .pairChanged(passphrase: true, words: false) && !door.rekeys)
            account.open(.follow)
            let confirm = try #require(account.confirm)
            await confirm.submit(passphrase: "a passphrase made elsewhere")
            #expect(confirm.refusal == nil, "\(String(describing: confirm.refusal))")
            _ = await confirm.awaitFirstRound()
            confirm.done()
            #expect(FollowDoneMark.owed(libraryID, in: defaults) == .pairChanged(passphrase: true, words: false),
                    "the Done is the section's durable notice, by library")
            await account.refresh()
            #expect(account.faces?.follow == .hidden, "nothing owed after")
            #expect(account.followDone != nil, "the notice stands in the section until her OK")
            account.followDoneOK()
            #expect(FollowDoneMark.owed(libraryID, in: defaults) == nil)
        }
    }
}
