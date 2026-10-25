//
//  SecretCheckRoadTests.swift
//  VariorumTests — VX-510 D-B7 (VX-513, her R-510-15): THE READ-ONLY CHECK's road (`ProtectionSecretCheck`) over the new
//  road's PLANTED leaves — a real library on a temp slot, planted custody, memory, Apple keys, vault and sync keys; no
//  keychain, no network (headless in the implementer's SwiftPM harness too). One typed secret, read as Look inside reads it,
//  against the OPEN library's live key file (the unlock's own derivation, compared with the open key) and — synced — the
//  account's vault (`AccountVault.master` non-nil), saying: they open this library (and the account) · the library but not
//  the account (the honest split; a passphrase changed elsewhere names the change — VX-113) · not this library (and,
//  synced, whether the account instead — PROVISIONAL P-VX510-B3-2) · the account not checked (signed out, another account,
//  out of reach, a slow server past the bound). THE PROOF across EVERY arm: nothing written anywhere — every keychain leaf's
//  write log and items, the container's every byte, the vault (fetches only), the sync keys and their session memory, the
//  executor's session vault cache, the library's record and key file in hand.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum SecretCheckPlant {
    typealias Account = PlantedAccount

    /// Everything a check must leave as it found it.
    struct Untouched: Equatable {
        var custody: [CustodyItemFact: StoreKey]
        var memory: Set<String>
        var apple: [String: String]
        var container: [String: Data]
        var vault: VaultSnapshot?
        var syncKeyItems: [SyncKeysItemFact: AccountKeys]
        var syncSession: [String: AccountKeys]
        var freshVaults: [String: VaultSnapshot]
        var record: ProtectionRecord?
        var keyFile: KeyFile?
    }

    static func untouched(
        _ road: PlantedRoad, _ session: ProtectionRoadSession, vault: PlantedVaultLeaf, keys: PlantedSyncKeysLeaf
    ) throws -> Untouched {
        Untouched(
            custody: road.custody.items, memory: Set(road.memory.items.keys), apple: road.apple.stamps,
            container: try CopyDoorsPlant.tree(road.slot.places.container), vault: vault.snapshot(Account.account),
            syncKeyItems: keys.items, syncSession: keys.session, freshVaults: session.executor.freshVaults,
            record: session.library.record, keyFile: session.library.keyFile)
    }

    /// Every write any leaf logged (the vault's non-fetch calls among them).
    static func writeLogs(_ road: PlantedRoad, vault: PlantedVaultLeaf) -> [String] {
        road.custody.writes + road.memory.writes + road.apple.writes + vault.calls.filter { !$0.hasPrefix("fetch ") }
    }

    static func fetches(_ vault: PlantedVaultLeaf) -> Int {
        vault.calls.filter { $0 == "fetch \(Account.account)" }.count
    }

    /// An unsynced Standard library — with a passphrase when asked — on a road carrying the planted vault and sync keys.
    static func unsynced(passphrase: Bool) async throws
        -> (road: PlantedRoad, vault: PlantedVaultLeaf, keys: PlantedSyncKeysLeaf, session: ProtectionRoadSession,
            words: [String]) {
        let (road, vault, keys) = Account.road()
        let (session, words) = try await road.created()
        if passphrase {
            #expect(await ProtectionOpenRoad.setFirstPassphrase(session: session, new: RoadKeyDoorRoadTests.passphrase) == .set)
        }
        return (road, vault, keys, session, words)
    }

    /// A synced Standard library (turning sync on handed its pair up — `PlantedAccount.passphrase` and its words).
    static func synced() async throws
        -> (road: PlantedRoad, vault: PlantedVaultLeaf, keys: PlantedSyncKeysLeaf, session: ProtectionRoadSession,
            words: [String]) {
        let (road, vault, keys) = Account.road()
        let (session, words) = try await road.created()
        let shown = try #require(ProtectionPaneRead.accountFaces(
            try await Account.read(session, Account.signedIn))?.turnOnSync.openDoor)
        let turned = await ProtectionAccountRoad.press(
            session, request: RoadAccountRequest(
                door: .turnOnSync, shown: shown, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(turned == .made(receipt: ProtectionWords.turnOnSyncReceipt), "the library syncs")
        road.session = Account.signedIn
        return (road, vault, keys, session, words)
    }

    /// Another device changed the ACCOUNT's passphrase (a key door there — a fresh descriptor), this library unfollowed.
    static func passphraseChangedElsewhere(_ vault: PlantedVaultLeaf, words: [String], to new: String) throws {
        let current = try #require(vault.accounts[Account.account])
        let master = try #require(current.vault.master(passphrase: nil, words: try WordsKey.derive(words)))
        let fresh = try PassphraseKey.derive(new, kdf: FastIDsLeaf().mintPassphraseKDF())
        vault.accounts[Account.account]?.vault = try VaultModel.rewrappingPassphrase(
            current.vault, master: master, passphrase: fresh, device: "Another Mac")
        vault.accounts[Account.account]?.revision += 1
        vault.accounts[Account.account]?.updatedAt = Date(timeIntervalSinceReferenceDate: 790_100_000)
    }

    /// Another device made NEW WORDS for the account (the words' lock re-wrapped there), this library unfollowed.
    static func wordsChangedElsewhere(_ vault: PlantedVaultLeaf, words: [String], to new: [String]) throws {
        let current = try #require(vault.accounts[Account.account])
        let master = try #require(current.vault.master(passphrase: nil, words: try WordsKey.derive(words)))
        vault.accounts[Account.account]?.vault = try VaultModel.rewrappingWords(
            current.vault, master: master, words: try WordsKey.derive(new), device: "Another Mac")
        vault.accounts[Account.account]?.revision += 1
    }

    /// Twelve valid words whose checksum fails (the right words with the last one swapped until it does).
    static func checksumBroken(_ words: [String]) throws -> [String] {
        let pool = try RecoveryPhrase.generate() + RecoveryPhrase.generate() + RecoveryPhrase.generate()
        for candidate in pool where candidate != words[11] {
            let broken = Array(words.prefix(11)) + [candidate]
            if (try? RecoveryPhrase.validate(broken)) == nil { return broken }
        }
        throw RoadWorld.RoadWorldError.notCreated
    }
}

@Suite("VX-510 D-B7 — the read-only check's road (planted, no keychain, no network)", .serialized)
@MainActor
struct SecretCheckRoadTests {
    typealias Account = PlantedAccount
    typealias Plant = SecretCheckPlant

    static func check(
        _ session: ProtectionRoadSession, _ typed: String, _ signIn: SessionFact = .signedOut,
        within bound: Duration = ProtectionSecretCheck.vaultBound
    ) async -> SecretCheckOutcome {
        await ProtectionSecretCheck.check(session, typed: typed, signIn: signIn, within: bound)
    }

    // MARK: - An unsynced library

    /// The right passphrase and the right words each open the library; a wrong one of each says the lobby's own sentence;
    /// no vault is read (the library doesn't sync); NOTHING is written by any of the four.
    @Test func rightAndWrongPassphraseAndWordsOnALibraryThatDoesntSync() async throws {
        let (road, vault, keys, session, words) = try await Plant.unsynced(passphrase: true)
        let before = try Plant.untouched(road, session, vault: vault, keys: keys)
        let logs = Plant.writeLogs(road, vault: vault)

        let right = await Self.check(session, RoadKeyDoorRoadTests.passphrase, Account.signedIn)
        #expect(right == .opens(.passphrase, account: .notSynced))
        #expect(right.lines == ["That passphrase opens this library."] && !right.warns)
        let rightWords = await Self.check(session, words.joined(separator: " "), Account.signedIn)
        #expect(rightWords == .opens(.words, account: .notSynced))
        #expect(rightWords.lines == ["Those twelve words open this library."] && !rightWords.warns)
        let wrong = await Self.check(session, "not the passphrase at all", Account.signedIn)
        #expect(wrong == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(wrong.lines == [ProtectionWords.passphraseDoesNotOpen] && wrong.warns)
        let wrongWords = await Self.check(session, try RecoveryPhrase.generate().joined(separator: " "), Account.signedIn)
        #expect(wrongWords == .doesNotOpen(.words, opensAccount: false))
        #expect(wrongWords.lines == [ProtectionWords.wordsDoNotOpen])
        // VX-510 ladder F-R1-4 (a guard — unreachable through the sheet, whose `canSubmit` refuses an empty field): nothing
        // typed is nothing checked — a refusal in the sheet's own ask, never "That passphrase doesn't open this library."
        let nothing = await Self.check(session, "", Account.signedIn)
        #expect(nothing == .refused(ProtectionWords.checkSecretsLead) && nothing.warns)

        #expect(Plant.fetches(vault) == 0, "a library that doesn't sync reads no vault")
        #expect(Plant.writeLogs(road, vault: vault) == logs, "no keychain write, no memory write, no Apple key, no vault write")
        #expect(try Plant.untouched(road, session, vault: vault, keys: keys) == before, "every item and every byte unchanged")
    }

    /// Twelve tokens that are not the words (an unknown word; a broken checksum) say the words' own sentence; a passphrase
    /// that happens to be of other words (another count) is just a passphrase. A library with NO passphrase yet: its words
    /// open it, any passphrase does not. Nothing written.
    @Test func twelveTokensThatAreNotTheWordsSayTheWordsOwnSentence() async throws {
        let (road, vault, keys, session, words) = try await Plant.unsynced(passphrase: false)
        let before = try Plant.untouched(road, session, vault: vault, keys: keys)
        let logs = Plant.writeLogs(road, vault: vault)
        let unknown = Array(words.prefix(11)) + ["notaword"]
        let saidUnknown = await Self.check(session, unknown.joined(separator: " "))
        #expect(saidUnknown == .refused(ProtectionWords.wordsUnknownWord("notaword")) && saidUnknown.warns)
        let broken = try Plant.checksumBroken(words)
        #expect(await Self.check(session, broken.joined(separator: " ")) == .refused(ProtectionWords.wordsChecksum))
        #expect(await Self.check(session, "one two three") == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(await Self.check(session, words.joined(separator: "  ")) == .opens(.words, account: .notSynced),
                "the words, however spaced")
        #expect(await Self.check(session, "a passphrase it never had") == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(Plant.writeLogs(road, vault: vault) == logs && Plant.fetches(vault) == 0)
        #expect(try Plant.untouched(road, session, vault: vault, keys: keys) == before)
    }

    // MARK: - A synced library

    /// Synced: the right passphrase and the right words open the library AND the account (one vault read each, through
    /// the leaf — never the executor's cache); a wrong passphrase opens neither. Nothing written.
    @Test func syncedTheRightSecretsOpenTheLibraryAndTheAccount() async throws {
        let (road, vault, keys, session, words) = try await Plant.synced()
        let before = try Plant.untouched(road, session, vault: vault, keys: keys)
        let logs = Plant.writeLogs(road, vault: vault)
        let fetchesBefore = Plant.fetches(vault)

        let right = await Self.check(session, Account.passphrase, Account.signedIn)
        #expect(right == .opens(.passphrase, account: .opens))
        #expect(right.lines == ["That passphrase opens this library and your account."] && !right.warns)
        let rightWords = await Self.check(session, words.joined(separator: " "), Account.signedIn)
        #expect(rightWords == .opens(.words, account: .opens))
        #expect(rightWords.lines == ["Those twelve words open this library and your account."])
        #expect(await Self.check(session, "not hers", Account.signedIn) == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(Plant.fetches(vault) == fetchesBefore + 3, "one fresh vault read per check")

        #expect(Plant.writeLogs(road, vault: vault) == logs)
        #expect(try Plant.untouched(road, session, vault: vault, keys: keys) == before,
                "nothing written — and the executor's session vault cache untouched")
    }

    /// THE HONEST SPLIT (D-B7 — VX-113's class): the account's passphrase changed on another device. The library's own
    /// (old) passphrase opens the library but not the account — and names the change; the account's NEW passphrase opens the
    /// account but not this library (PROVISIONAL P-VX510-B3-2). The words' split the same, with no device named. Nothing
    /// written.
    @Test func theHonestSplitWhenTheAccountsSecretsChangedElsewhere() async throws {
        let (road, vault, keys, session, words) = try await Plant.synced()
        try Plant.passphraseChangedElsewhere(vault, words: words, to: "the account's new passphrase")
        let before = try Plant.untouched(road, session, vault: vault, keys: keys)
        let logs = Plant.writeLogs(road, vault: vault)
        let day = ProtectionWords.day(Date(timeIntervalSinceReferenceDate: 790_100_000))
        let named = ProtectionWords.passphraseChangedElsewhere(device: "Another Mac", day: day)

        let old = await Self.check(session, Account.passphrase, Account.signedIn)
        #expect(old == .opens(.passphrase, account: .doesNotOpen(changedElsewhere: named)))
        #expect(old.lines == ["That passphrase opens this library, but not your account.", named] && old.warns)
        // VX-529 unit 2 (scope 4) — FLIPPED DELIBERATELY: in the catch-up's state (the account's pair changed elsewhere,
        // this library unfollowed) the fourth answer gains the road's pointer.
        let new = await Self.check(session, "the account's new passphrase", Account.signedIn)
        #expect(new == .doesNotOpen(.passphrase, opensAccount: true, because: .catchUpOwed))
        #expect(new.lines == ["That passphrase doesn't open this library, but it opens your account.",
                              ProtectionWords.checkSecretsCatchUpPointer] && new.warns)
        #expect(await Self.check(session, words.joined(separator: " "), Account.signedIn) == .opens(.words, account: .opens),
                "the words still open both")

        let newWords = try RecoveryPhrase.generate()
        try Plant.wordsChangedElsewhere(vault, words: words, to: newWords)
        let oldWords = await Self.check(session, words.joined(separator: " "), Account.signedIn)
        #expect(oldWords == .opens(.words, account: .doesNotOpen(changedElsewhere: nil)))
        #expect(oldWords.lines == ["Those twelve words open this library, but not your account."])
        let freshWords = await Self.check(session, newWords.joined(separator: " "), Account.signedIn)
        #expect(freshWords == .doesNotOpen(.words, opensAccount: true, because: .catchUpOwed))  // VX-529 — FLIPPED DELIBERATELY
        #expect(freshWords.lines == ["Those twelve words don't open this library, but they open your account.",
                                     ProtectionWords.checkSecretsCatchUpPointer])

        #expect(Plant.writeLogs(road, vault: vault) == logs)
        var after = try Plant.untouched(road, session, vault: vault, keys: keys)
        after.vault = before.vault  // the words' change above is the test's own plant, not the check's
        #expect(after == before)
    }

    /// The account NOT CHECKED, said with the pane's own sentence — offline (out of reach), signed out and signed into
    /// another account (no vault read at all), and a server slower than the bound (the check comes back on time, a late
    /// answer dropped) — while the library's half is still said. Nothing written.
    @Test func theAccountUncheckedSaysWhyAndTheLibrarysHalfStands() async throws {
        let (road, vault, keys, session, _) = try await Plant.synced()
        let before = try Plant.untouched(road, session, vault: vault, keys: keys)
        let logs = Plant.writeLogs(road, vault: vault)

        vault.reachable = false
        let offline = await Self.check(session, Account.passphrase, Account.signedIn)
        #expect(offline == .opens(.passphrase, account: .unchecked(ProtectionWords.doorRefusedNeedsVault)))
        #expect(offline.lines == ["That passphrase opens this library.", ProtectionWords.doorRefusedNeedsVault]
                && !offline.warns)
        vault.reachable = true
        let fetches = Plant.fetches(vault)
        #expect(await Self.check(session, Account.passphrase, .signedOut)
                == .opens(.passphrase, account: .unchecked(ProtectionWords.doorRefusedSignedOut)))
        #expect(await Self.check(session, Account.passphrase, .signedIn(accountID: Account.other, email: nil))
                == .opens(.passphrase, account: .unchecked(ProtectionWords.doorRefusedOtherAccount)))
        #expect(Plant.fetches(vault) == fetches, "signed out or into another account: no vault read")
        #expect(await Self.check(session, "not hers", .signedOut) == .doesNotOpen(.passphrase, opensAccount: false))

        vault.fetchDelay = .seconds(2)
        let started = ContinuousClock.now
        let slow = await Self.check(session, Account.passphrase, Account.signedIn, within: .milliseconds(300))
        #expect(ContinuousClock.now - started < .milliseconds(1_500), "the check never waits past its bound")
        #expect(slow == .opens(.passphrase, account: .unchecked(ProtectionWords.doorRefusedNeedsVault)))
        try await Task.sleep(for: .milliseconds(2_200))  // the late answer lands — and is dropped
        vault.fetchDelay = nil

        #expect(Plant.writeLogs(road, vault: vault) == logs)
        #expect(try Plant.untouched(road, session, vault: vault, keys: keys) == before)
    }

    /// CASTLE (Always ask — no quiet road, no item): the same check, the same answers; nothing written, no keychain read.
    @Test func inCastleTheCheckReadsTheSameAndWritesNothing() async throws {
        let world = try await TypedUnlockSyncKeysTests.castleAlwaysAskSynced()
        let before = try Plant.untouched(world.road, world.session, vault: world.vault, keys: world.keys)
        let logs = Plant.writeLogs(world.road, vault: world.vault)
        let custodyReads = world.road.custody.reads.count
        let touchIDReads = world.keys.touchIDReads
        #expect(await Self.check(world.session, Account.passphrase, Account.signedIn) == .opens(.passphrase, account: .opens))
        #expect(await Self.check(world.session, world.words.joined(separator: " "), Account.signedIn)
                == .opens(.words, account: .opens))
        #expect(await Self.check(world.session, "not hers", Account.signedIn) == .doesNotOpen(.passphrase, opensAccount: false))
        #expect(world.road.custody.reads.count == custodyReads && world.keys.touchIDReads == touchIDReads,
                "no custody read, no sync-keys Touch ID read — never a prompt")
        #expect(Plant.writeLogs(world.road, vault: world.vault) == logs)
        #expect(try Plant.untouched(world.road, world.session, vault: world.vault, keys: world.keys) == before)
    }

    /// No key file of the open key beside the library (rule 27's state): nothing to check the library against — the door is
    /// not rendered (`RoadKeyDoorFaces.checkStands`), and a check that still arrives refuses, reading nothing.
    @Test func withNoKeyFileOfTheOpenKeyNothingIsChecked() async throws {
        let road = PlantedRoad()
        _ = try await RoadKeyDoorRoadTests.withPassphrase(road)
        let session = try await NoKeyFileDoorTests.openedWithNoKeyFileAnywhere(road)
        let faces = try #require(await ProtectionKeyDoorRoad.read(session, signIn: .signedOut, exportSwitch: nil))
        #expect(!faces.checkStands, "the door is not rendered")
        #expect(await Self.check(session, RoadKeyDoorRoadTests.passphrase) == .refused(ProtectionWords.crossingDoorClosed))
        let standing = try await Plant.unsynced(passphrase: true)  // (the road kept: its temp slot lives with it)
        let open = try #require(await ProtectionKeyDoorRoad.read(standing.session, signIn: .signedOut, exportSwitch: nil))
        #expect(open.checkStands, "with the key file of the key beside it, the door stands")
        withExtendedLifetime((road, standing.road)) {}
    }
}
