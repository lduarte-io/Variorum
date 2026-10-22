//
//  RoadAccountFacesTests.swift
//  VariorumTests — VX-308 U1 piece 3: THE PANE'S ONE READ and THE ACCOUNT SECTION'S FACES over the new road's PLANTED
//  leaves (a real library on the planted road; the planted vault and sync keys — no network, no keychain; also runs
//  headless in the implementer's SwiftPM harness). The read takes the CURRENT sign-in and a FRESH vault read (R-2); every
//  door reads `assess` (a door that cannot act is not rendered — P-2); one road per situation (P-VX308-U1-2); the join
//  arms are U2's (the not-yet line — R-4); the crossings read through the same read, so a synced library's crossings are
//  no longer stuck on "couldn't reach your account". The record-binding states are planted facts of the real library,
//  mutated per state (U2a's idiom); the acts that bind for real are piece 4's.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U1 — the pane's one read and the account section's faces (planted, no network)")
@MainActor
struct RoadAccountFacesTests {
    typealias Account = PlantedAccount

    /// A library created on the planted road (Standard, no passphrase yet).
    private func library() async throws -> (road: PlantedRoad, vault: PlantedVaultLeaf, session: ProtectionRoadSession) {
        let (road, vault, _) = Account.road()
        let (session, _) = try await road.created()
        return (road, vault, session)
    }

    /// The read, its record bound to `account` (following the vault's current sync key unless told otherwise).
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

    @Test func aLocalLibraryWithNoOneSignedInAsksASignInAndReadsNoVault() async throws {
        let (_, vault, session) = try await library()
        let read = try await Account.read(session, .signedOut)
        #expect(read.vault == .notAsked && vault.calls.isEmpty, "no one signed in — nothing asked")
        let faces = try faces(read)
        #expect(faces.situation == .localOnly)
        #expect(faces.turnOnSync == .refused(ProtectionWords.accountSignInToTurnOnSync))
        #expect(faces.signIn && !faces.signOut)
        #expect([faces.stopSyncingHere, faces.deleteAccountHere, faces.thisMacOnly, faces.move].allSatisfy { $0 == .hidden })
    }

    /// Signed in, the account with NO vault yet: the set-up confirm (rule 7's hand-up) — both typed, a NEW passphrase
    /// twice (none yet), the lead, rule 7's sentence and the posture the account takes.
    @Test func signedInWithNoVaultTheSetUpConfirmHandsThePairUp() async throws {
        let (_, vault, session) = try await library()
        let read = try await Account.read(session, Account.signedIn)
        #expect(read.vault == .read(exists: false) && vault.calls == ["fetch \(Account.account)"], "a FRESH read, now")
        let faces = try faces(read)
        let open = try #require(faces.turnOnSync.openDoor)
        #expect(open.door == .turnOnSync && open.ask == .passphraseAndWords && open.newPassphrase)
        #expect(open.spec.join == .setsUpInLibrarysMode && open.spec.requires == .passphraseAndWords(wordsMayBeNew: false))
        #expect(open.sentences == [ProtectionWords.turnOnSyncLead, ProtectionWords.onePairAtATime,
                                   ProtectionWords.turnOnSyncPosture(.standard)])
        #expect(faces.signOut && !faces.signIn)
    }

    /// The account already has its vault: turning sync on is a JOIN. FLIPPED DELIBERATELY at VX-308 U2 (U1's honest
    /// not-yet line — R-4 — was U2's target): the join's own confirm now, ONE of the account's secrets (rule 14).
    @Test func signedInWithAVaultTurningSyncOnIsTheJoin() async throws {
        let (_, vault, session) = try await library()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase,
                        words: try RecoveryPhrase.generate(), mode: .castle)
        let faces = try faces(try await Account.read(session, Account.signedIn))
        let join = try #require(faces.turnOnSync.openDoor)
        #expect(join.door == .turnOnSync && join.ask == .oneSecret && join.spec.join == .entersCastle && join.rekeys)
    }

    /// The vault could not be read: said, never guessed as "no vault yet" (decision 35).
    @Test func anUnreadableVaultIsSaidNeverGuessed() async throws {
        let (_, vault, session) = try await library()
        vault.reachable = false
        let read = try await Account.read(session, Account.signedIn)
        #expect(read.vault == .unreachable && read.facts.vault == nil)
        #expect(try faces(read).turnOnSync == .refused(ProtectionWords.doorRefusedNeedsVault))
    }

    /// In sync: the two local leaves of a signed-in library — Stop syncing here and Delete the account from this Mac (the
    /// local leave with its one pointer) — each saying rule 16; This Mac Only is the same act, not rendered beside them.
    @Test func inSyncTheTwoLocalLeavesSayRule16() async throws {
        let (_, vault, session) = try await library()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase,
                        words: try RecoveryPhrase.generate(), mode: .standard)
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault)
        let faces = try faces(read)
        #expect(faces.situation == .inSync(email: Account.email))
        let stop = try #require(faces.stopSyncingHere.openDoor)
        #expect(stop.ask == .nothing && stop.sentences == [
            ProtectionWords.stopSyncingLead, ProtectionWords.ruleSixteen, ProtectionWords.signingBackInIsAJoin])
        let delete = try #require(faces.deleteAccountHere.openDoor)
        #expect(delete.ask == .nothing && delete.sentences == [
            ProtectionWords.deleteHereLead, ProtectionWords.ruleSixteen, ProtectionWords.signingBackInIsAJoin,
            ProtectionWords.deleteHerePointer])
        #expect(faces.thisMacOnly == .hidden && faces.turnOnSync == .hidden && faces.signOut && !faces.vaultUnreachable)
    }

    /// The account's keys moved elsewhere (a follow owed — U2's face): Stop syncing here says so in its place; the third
    /// leave still stands (`assess` keeps it open — the account may be going away).
    @Test func aFollowOwedRefusesStopSyncingInPlace() async throws {
        let (_, vault, session) = try await library()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase,
                        words: try RecoveryPhrase.generate(), mode: .standard)
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault,
                         followsCurrentKey: false)
        let faces = try faces(read)
        #expect(faces.stopSyncingHere == .refused(ProtectionWords.doorRefusedFollowOwed))
        #expect(faces.deleteAccountHere.openDoor != nil)
    }

    /// In sync and the vault unreadable: the leaves still stand (they need no vault); the line says it once.
    @Test func inSyncAnUnreadableVaultIsSaidOnce() async throws {
        let (_, vault, session) = try await library()
        vault.reachable = false
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault)
        let faces = try faces(read)
        #expect(faces.vaultUnreachable && faces.stopSyncingHere.openDoor != nil)
    }

    /// Signed out of the library's account: ONE road — This Mac Only (Continue) — and Sign in; Stop syncing here (the
    /// same act) is not rendered beside it, and the third leave needs the account signed in.
    @Test func signedOutOneRoadPlain() async throws {
        let (_, vault, session) = try await library()
        let read = bound(try await Account.read(session, .signedOut), to: Account.account, vault: vault)
        let faces = try faces(read)
        #expect(faces.situation == .signedOut)
        let road = try #require(faces.thisMacOnly.openDoor)
        #expect(road.ask == .nothing && road.door.button == ProtectionWords.accountContinue)
        #expect(road.sentences == [ProtectionWords.thisMacOnlyLead, ProtectionWords.ruleSixteen,
                                   ProtectionWords.signingBackInIsAJoin])
        #expect(faces.stopSyncingHere == .hidden && faces.deleteAccountHere == .hidden)
        #expect(faces.signIn && !faces.signOut)
    }

    /// Another account signed in: the situation once, Move (U2's join — not yet), Sign out; no leave rendered.
    @Test func anotherAccountMoveOrSignOut() async throws {
        let (_, vault, session) = try await library()
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.other, vault: vault)
        let faces = try faces(read)
        #expect(faces.situation == .otherAccount(signedInEmail: Account.email, sameEmail: false))
        #expect(faces.move == .notYet(ProtectionWords.moveNotYet) && faces.signOut && !faces.signIn)
        #expect([faces.stopSyncingHere, faces.deleteAccountHere, faces.thisMacOnly, faces.turnOnSync]
            .allSatisfy { $0 == .hidden })
    }

    /// R-2 — the crossings read through the SAME read: a synced library's crossings open (the fresh vault reading is in
    /// the facts), where the open's own read (no vault) leaves them at "couldn't reach your account".
    @Test func theCrossingsReadThroughTheOneRead() async throws {
        let (_, vault, session) = try await library()
        try vault.plant(accountID: Account.account, passphrase: Account.passphrase,
                        words: try RecoveryPhrase.generate(), mode: .standard)
        let read = bound(try await Account.read(session, Account.signedIn), to: Account.account, vault: vault)
        let exports = PlantedExportSwitch().road
        let withRead = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: exports, read: read))
        #expect(withRead.useCastle.openDoor?.synced == true, "Use Castle open — account-wide")
        var noVault = read
        noVault.facts.vault = nil
        let without = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: exports, read: noVault))
        #expect(without.useCastle == .refused(ProtectionWords.doorRefusedNeedsVault))
    }
}

// VX-329 U3 — VX-423: `FollowingSessionProviderTests` (R-3 — the vault leaf's session follows the sign-in) was deleted
// with its subject; the claim is pinned on the new shape — the leaf handed the process's one authority — by
// `OneRefreshAuthorityTests.theVaultLeafFollowsASignOutAndASignInToAnotherAccount`.
