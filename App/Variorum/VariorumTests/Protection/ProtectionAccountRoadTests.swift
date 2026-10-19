//
//  ProtectionAccountRoadTests.swift
//  VariorumTests — VX-308 U1 piece 4: THE ACCOUNT ROADS (`ProtectionAccountRoad`) over the new road's PLANTED leaves — a
//  real library on the planted road, the planted vault (the core `ExecutorVault`'s semantics, no network) and planted
//  sync keys (also runs headless in the implementer's SwiftPM harness). Turning sync on hands the library's pair up (rule
//  7) and binds the record, the key unchanged; a wrong word writes nothing; the door re-read at the press (VX-108); the
//  CURRENT sign-in is adopted under the act (R-2); the three LOCAL leaves (rule 16) unbind the record and forget the sync
//  keys while the key file, its locks and the server's vault stay exactly as they were; P-VX308-U1-F1's hook runs the
//  protection half after the Account sheet's deletion — only for this library's account.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U1 — the account roads over planted leaves (no network)")
@MainActor
struct ProtectionAccountRoadTests {
    typealias Account = PlantedAccount

    struct World {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let keys: PlantedSyncKeysLeaf
        let session: ProtectionRoadSession
        let words: [String]
    }

    /// A library created on the planted road — composed SIGNED OUT (the open's sign-in; she signs in later).
    private func world() async throws -> World {
        let (road, vault, keys) = Account.road()
        let (session, words) = try await road.created()
        return World(road: road, vault: vault, keys: keys, session: session, words: words)
    }

    private func shown(_ world: World, _ door: RoadAccountDoor, _ signIn: SessionFact) async throws -> RoadAccountDoorOpen {
        let read = try await Account.read(world.session, signIn)
        return try #require(ProtectionPaneRead.accountFaces(read)?.face(door).openDoor)
    }

    private func press(
        _ world: World, _ door: RoadAccountDoor, _ signIn: SessionFact, typed: TypedSecrets = .none,
        shown: RoadAccountDoorOpen? = nil
    ) async throws -> RoadAccountPress {
        let open: RoadAccountDoorOpen
        if let shown { open = shown } else { open = try await self.shown(world, door, signIn) }
        return await ProtectionAccountRoad.press(
            world.session, request: RoadAccountRequest(door: door, shown: open, typed: typed), signIn: signIn,
            exportSwitch: nil)
    }

    /// Turn sync on (rule 7): the account's vault made under the library's pair — the NEW passphrase and the typed words,
    /// never new words; the record names the account and follows its sync key; the sync keys held the Standard way; the
    /// library's key unchanged. The session was composed SIGNED OUT: the sign-in now is adopted under the act (R-2).
    @Test func turningSyncOnHandsThePairUpAndBindsTheRecord() async throws {
        let world = try await world()
        let before = world.session.library
        #expect(world.session.executor.configuration.session == .signedOut, "the open's sign-in")
        let outcome = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: world.words, newPassphrase: Account.passphrase))
        #expect(outcome == .made(receipt: ProtectionWords.turnOnSyncReceipt))
        let made = try #require(world.vault.snapshot(Account.account))
        #expect(made.mode == .standard, "the account takes the library's posture")
        let kdf = made.vault.kdf
        #expect(VaultModel.master(of: made.vault, passphrase: try PassphraseKey.derive(Account.passphrase, kdf: kdf),
                                  words: nil) != nil, "the passphrase she typed opens the account")
        #expect(VaultModel.master(of: made.vault, passphrase: nil, words: try WordsKey.derive(world.words)) != nil,
                "the library's own words open the account — never new ones")
        let after = world.session.library
        #expect(after.record?.account == Account.account && after.record?.accountRowKeyID == made.rowKeyID)
        #expect(after.fingerprint == before.fingerprint, "the key unchanged")
        #expect(world.keys.items.keys.contains(SyncKeysItemFact(accountID: Account.account, itemClass: .silent)))
        #expect(after.keyFile?.passphrase != nil, "the passphrase is the library's now too (rule 3)")
        // The next read: in sync.
        let faces = try #require(ProtectionPaneRead.accountFaces(try await Account.read(world.session, Account.signedIn)))
        #expect(faces.situation == .inSync(email: Account.email))
    }

    /// A wrong word: refused in words, nothing written — no vault, no binding, no sync keys.
    @Test func aWrongWordWritesNothing() async throws {
        let world = try await world()
        let outcome = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: try RecoveryPhrase.generate(), newPassphrase: Account.passphrase))
        #expect(outcome == .refused(ProtectionWords.wordsDoNotOpen))
        #expect(world.vault.accounts.isEmpty && !world.vault.calls.contains { $0.hasPrefix("create") })
        #expect(world.session.library.record?.account == nil && world.keys.items.isEmpty)
        #expect(world.session.library.section.actInFlight == nil)
    }

    /// VX-108 — the door re-read at the press: another device turned sync on for the account meanwhile, so turning it on
    /// here is now a join (U2's) — the press refuses, nothing written; with no one signed in it refuses too.
    @Test func theDoorIsReReadAtThePress() async throws {
        let world = try await world()
        let shown = try await shown(world, .turnOnSync, Account.signedIn)
        try world.vault.plant(accountID: Account.account, passphrase: "another device's", words: try RecoveryPhrase.generate(),
                              mode: .standard)
        let typed = TypedSecrets(words: world.words, newPassphrase: Account.passphrase)
        #expect(try await press(world, .turnOnSync, Account.signedIn, typed: typed, shown: shown)
            == .refused(ProtectionWords.crossingDoorClosed))
        #expect(try await press(world, .turnOnSync, .signedOut, typed: typed, shown: shown)
            == .refused(ProtectionWords.accountSignInToTurnOnSync))
        #expect(world.session.library.record?.account == nil && world.vault.accounts.count == 1)
    }

    /// The door CHANGED but still open (VX-108): re-shown, nothing written.
    @Test func aChangedDoorIsReShown() async throws {
        let world = try await world()
        let shown = try await shown(world, .turnOnSync, Account.signedIn)
        #expect(shown.newPassphrase)
        guard case .set = await ProtectionOpenRoad.setFirstPassphrase(session: world.session, new: Account.passphrase) else {
            Issue.record("the first passphrase is set")
            return
        }
        guard case .changed(let now) = try await press(
            world, .turnOnSync, Account.signedIn, typed: TypedSecrets(words: world.words, newPassphrase: "x"), shown: shown)
        else {
            Issue.record("the door changed — re-shown")
            return
        }
        #expect(!now.newPassphrase, "the passphrase is the current one now")
        #expect(world.vault.accounts.isEmpty)
    }

    /// The three LOCAL leaves (rule 16): each unbinds the record and forgets this Mac's sync keys for the account — the
    /// key, the key file and its locks, and the server's vault stay exactly as they were.
    @Test(arguments: [RoadAccountDoor.stopSyncingHere, .deleteAccountHere, .thisMacOnly])
    func eachLocalLeaveChangesNoKeyAndTouchesNoServerData(_ door: RoadAccountDoor) async throws {
        let world = try await world()
        _ = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: world.words, newPassphrase: Account.passphrase))
        let bound = world.session.library
        let vaultBefore = try #require(world.vault.snapshot(Account.account))
        #expect(!world.keys.accountsHeld.isEmpty)
        // This Mac Only is the signed-out road; the other two are the signed-in ones.
        let signIn = door == .thisMacOnly ? SessionFact.signedOut : Account.signedIn
        let outcome = try await press(world, door, signIn)
        #expect(outcome == .made(receipt: door.receipt))
        let after = world.session.library
        #expect(after.record?.account == nil && after.record?.accountRowKeyID == nil, "the record stops naming it")
        #expect(world.keys.accountsHeld.isEmpty, "this Mac forgets the account's sync keys")
        #expect(after.fingerprint == bound.fingerprint && after.keyFile == bound.keyFile, "no key, lock or secret changes")
        #expect(world.vault.snapshot(Account.account) == vaultBefore, "the server keeps what you pushed")
        #expect(!world.vault.calls.contains { $0.hasPrefix("update") })
    }

    /// P-VX308-U1-F1 — the Account sheet's deletion landed: the protection half runs for THIS library's account only.
    @Test func theDeletionsHookRunsTheProtectionHalfForThisLibrarysAccountOnly() async throws {
        let world = try await world()
        _ = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: world.words, newPassphrase: Account.passphrase))
        let keyFile = world.session.library.keyFile
        #expect(world.session.beginAct())
        let other = await ProtectionAccountRoad.accountDeleted(world.session, accountID: Account.other, signIn: Account.signedIn)
        #expect(!other && world.session.library.record?.account == Account.account, "another account's deletion: nothing")
        let ran = await ProtectionAccountRoad.accountDeleted(world.session, accountID: Account.account, signIn: Account.signedIn)
        world.session.endAct()
        #expect(ran)
        #expect(world.session.library.record?.account == nil && world.keys.accountsHeld.isEmpty)
        #expect(world.session.library.keyFile == keyFile)
    }

    /// THE SIGNED-OUT ROAD's Continue (VX-264 as amended): signed out of the library's account, This Mac Only runs and
    /// the crossings then read Use Castle OPEN on the now-local library; signed in meanwhile, it refuses — nothing written.
    @Test func theSignedOutRoadsLeaveRunsThisMacOnlyThenUseCastleIsOpen() async throws {
        let world = try await world()
        _ = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: world.words, newPassphrase: Account.passphrase))
        let exports = PlantedExportSwitch().road
        let signedOut = try await Account.read(world.session, .signedOut)
        let before = try #require(ProtectionCrossings.readCrossings(world.session, exportSwitch: exports, read: signedOut))
        #expect(before.useCastle == .signedOutRoad)
        let stillSignedIn = await ProtectionAccountRoad.leaveForUseCastle(
            world.session, signIn: Account.signedIn, exportSwitch: exports)
        #expect(stillSignedIn == ProtectionWords.crossingDoorClosed && world.session.library.record?.account == Account.account)
        let left = await ProtectionAccountRoad.leaveForUseCastle(world.session, signIn: .signedOut, exportSwitch: exports)
        #expect(left == nil && world.session.library.record?.account == nil && world.keys.accountsHeld.isEmpty)
        let after = try #require(ProtectionCrossings.readCrossings(
            world.session, exportSwitch: exports, read: try await Account.read(world.session, .signedOut)))
        let open = try #require(after.useCastle.openDoor)
        #expect(!open.synced && open.ask == .passphraseAndWords, "Use Castle on this library on this Mac only")
    }

    /// One act at a time: a press while another act holds the session refuses, nothing written.
    @Test func aPressWhileAnotherActRunsRefuses() async throws {
        let world = try await world()
        #expect(world.session.beginAct())
        let outcome = try await press(
            world, .turnOnSync, Account.signedIn,
            typed: TypedSecrets(words: world.words, newPassphrase: Account.passphrase),
            shown: try await shown(world, .turnOnSync, Account.signedIn))
        world.session.endAct()
        #expect(outcome == .refused(ProtectionWords.copyDoorBusy) && world.vault.accounts.isEmpty)
    }
}
