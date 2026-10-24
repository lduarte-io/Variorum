//
//  AssessPairTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 1: DETECTION — a pair changed
//  elsewhere (`notes/plans/fixes/vx-529-pair-catchup.md`, design §1). With a
//  fresh vault read for the library's account, the same posture and the same
//  sync key, the key file's passphrase lock under another descriptor than the
//  vault's, or its master's twelve-words copy other than the vault's recovery
//  wrap, owes the follow's third kind — and the `followOwed` gate then closes
//  every key and mode door (the repro's false Change-passphrase refusal class,
//  closed structurally).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced library as `assess` reads it: its key file carries the account's pair as this library last knew it — the
/// passphrase lock and the master with its twelve-words copy — and the vault's reading carries both halves as they stand
/// (`VaultSnapshot.reading`'s `kdf` and `recoveryWrap`). With nothing moved, they agree.
func pairWorld(_ mode: ProtectionMode) throws -> (AWorld, String) {
    let x = PF.id()
    var world = try AWorld(mode, account: x)
    world.session = .signedIn(accountID: x, email: nil)
    let copy = try world.world.masterWordsCopy
    world.liveFile = try world.liveFile.settingMaster(world.world.master, wordsCopy: copy, for: world.key)
    world.vault = VaultReading(
        accountID: x, mode: mode, rowKeyID: "c1", kdf: try #require(world.liveFile.passphrase).kdf, recoveryWrap: copy,
        updatedByDevice: "Lillian's Air", updatedAt: CF.stamp(9))
    return (world, x)
}

/// The account's passphrase re-made elsewhere: the vault's lock under a fresh descriptor (a new passphrase always takes
/// one — U2's hand-forward).
func passphraseMovedElsewhere(_ world: inout AWorld) { world.vault?.kdf = PF.fastKDF() }

/// The account's words re-made elsewhere: the vault's recovery wrap is the master under other words.
func wordsMovedElsewhere(_ world: inout AWorld) throws {
    let other = try AES.KeyWrap.wrap(world.world.master, using: try PF.wordsKey(try PF.words()).key)
    world.vault?.recoveryWrap = other
}

func owesAFollow(_ assessed: Assessment) -> Bool {
    assessed.acts.contains { if case .follow = $0 { return true } else { return false } }
}

@Suite("VX-529 scope 1 — RED ON OLD: a pair changed elsewhere owes a follow, and the key doors refuse until it lands")
struct AssessPairRedPins {
    /// The no-follow-offered class (the VX-510 repro: "Settings ▸ Sync offers NO follow") and the false-refusal class
    /// ("Change passphrase old → new refuses 'That passphrase doesn't open this library.'") — closed by detection.
    @Test(arguments: ProtectionMode.allCases)
    func aPassphraseChangedElsewhereOwesAFollowAndTheKeyDoorsRefuse(_ mode: ProtectionMode) throws {
        var (world, _) = try pairWorld(mode)
        passphraseMovedElsewhere(&world)
        let assessed = try world.assessed()
        #expect(owesAFollow(assessed), "no follow offered for a passphrase changed elsewhere (\(mode))")
        #expect(assessed.door(.followNow).isOpen)
        #expect(assessed.door(.changePassphrase).refusal == .followOwed, "Change passphrase stays open (\(mode))")
    }

    @Test(arguments: ProtectionMode.allCases)
    func wordsChangedElsewhereOweAFollowAndTheKeyDoorsRefuse(_ mode: ProtectionMode) throws {
        var (world, _) = try pairWorld(mode)
        try wordsMovedElsewhere(&world)
        let assessed = try world.assessed()
        #expect(owesAFollow(assessed), "no follow offered for words changed elsewhere (\(mode))")
        #expect(assessed.door(.followNow).isOpen)
        #expect(assessed.door(.newWords).refusal == .followOwed, "New words stays open (\(mode))")
    }

    /// The guard row, green on both trees: with nothing moved, nothing is owed and the key doors stand open.
    @Test(arguments: ProtectionMode.allCases)
    func withNothingMovedNothingIsOwed(_ mode: ProtectionMode) throws {
        let (world, _) = try pairWorld(mode)
        let assessed = try world.assessed()
        #expect(!owesAFollow(assessed))
        #expect(assessed.door(.changePassphrase).isOpen && assessed.door(.newWords).isOpen)
        #expect(assessed.door(.followNow).refusal == .nothingToDo)
    }
}

@Suite("VX-529 scope 1 — the third follow kind: which half moved, its door, its gates and its edges (E1–E3, E6)")
struct AssessPairKindTests {
    @Test(arguments: ProtectionMode.allCases)
    func theThirdKindNamesWhichHalfMovedAndTypesOnlyWhereThePassphraseDid(_ mode: ProtectionMode) throws {
        var passphrase = try pairWorld(mode).0
        passphraseMovedElsewhere(&passphrase)
        #expect(try passphrase.assessed().acts.contains(.follow(.pairChanged(passphrase: true, words: false), typesOneSecret: true)))
        var words = try pairWorld(mode).0
        try wordsMovedElsewhere(&words)
        #expect(try words.assessed().acts.contains(.follow(.pairChanged(passphrase: false, words: true), typesOneSecret: false)))
        var both = try pairWorld(mode).0
        passphraseMovedElsewhere(&both)
        try wordsMovedElsewhere(&both)
        // E5: both halves — one typed passphrase; the words ride the vault's copy.
        #expect(try both.assessed().acts.contains(.follow(.pairChanged(passphrase: true, words: true), typesOneSecret: true)))
        // Exactly one follow is owed.
        #expect(try both.assessed().acts.filter { if case .follow = $0 { return true } else { return false } }.count == 1)
    }

    /// Design §2: the catch-up re-locks, never re-keys — no new key, no Apple key retired, no rule-5 sentence. Where the
    /// passphrase moved it types ONE of the account's current secrets (R-529-5: the passphrase re-makes the lock, the
    /// words drop the stale one); nothing where only the words did (R-529-2).
    @Test(arguments: ProtectionMode.allCases)
    func theFollowDoorReLocksAndTypesExactlyTheHalfThatMoved(_ mode: ProtectionMode) throws {
        var passphrase = try pairWorld(mode).0
        passphraseMovedElsewhere(&passphrase)
        let typed = try #require(try passphrase.assessed().door(.followNow).spec)
        #expect(typed == DoorSpec(requires: .oneSecret, synced: true))
        #expect(!typed.rekeys && typed.retiresOwnAppleKeys.isEmpty && typed.words.isEmpty)
        var words = try pairWorld(mode).0
        try wordsMovedElsewhere(&words)
        #expect(try words.assessed().door(.followNow).spec == DoorSpec(requires: .none, synced: true))
    }

    /// The `followOwed` gate, unchanged, covers every key and mode door while the pair follow is owed (R-529-3: Change
    /// passphrase refuses, pointing at the follow) — and, as for every follow, two of the three leaves (rule 16's third,
    /// deleting the account here, stays open).
    @Test(arguments: ProtectionMode.allCases)
    func everyKeyAndModeDoorWaitsForTheCatchUp(_ mode: ProtectionMode) throws {
        var world = try pairWorld(mode).0
        passphraseMovedElsewhere(&world)
        let assessed = try world.assessed()
        for door in [Door.useCastle, .useStandard, .replaceAllKeys, .changePassphrase, .newWords, .resetForgottenPassphrase,
                     .thisMacOnly, .stopSyncingHere] {
            #expect(assessed.door(door).refusal == .followOwed, "\(mode) \(door)")
        }
        #expect(assessed.door(.deleteAccountHere).isOpen)
    }

    /// E2: the posture and key-replacement follows OUTRANK the pair kind — they adopt the account's pair anyway.
    @Test func thePostureAndKeyFollowsOutrankIt() throws {
        var intoCastle = try pairWorld(.standard).0
        intoCastle.vault?.mode = .castle
        passphraseMovedElsewhere(&intoCastle)
        try wordsMovedElsewhere(&intoCastle)
        let entered = try intoCastle.assessed().acts.filter { if case .follow = $0 { return true } else { return false } }
        #expect(entered == [.follow(.intoCastle, typesOneSecret: true)])
        for mode in ProtectionMode.allCases {
            var lagging = try pairWorld(mode).0
            lagging.vault?.rowKeyID = "c2"
            passphraseMovedElsewhere(&lagging)
            let caughtUp = try lagging.assessed().acts.filter { if case .follow = $0 { return true } else { return false } }
            #expect(caughtUp == [.follow(.keysReplaced, typesOneSecret: true)], "\(mode)")
        }
    }

    /// E3: this device's own act in flight is its plan's to finish — never read as the pair moving elsewhere.
    @Test func thisDevicesOwnActInFlightIsNotAPairChangeElsewhere() throws {
        var world = try pairWorld(.castle).0
        passphraseMovedElsewhere(&world)
        world.section = world.section.beginningAct(.changePassphrase, from: PF.fp(world.key), to: nil, at: PF.t0).section
        #expect(!owesAFollow(try world.assessed()))
    }

    /// E1: no fresh vault read for the library's account — offline, signed out, signed into another account, or read for
    /// another account — no detection, nothing rendered.
    @Test func withNoFreshVaultReadThereIsNoDetection() throws {
        var signedOut = try pairWorld(.castle).0
        passphraseMovedElsewhere(&signedOut)
        signedOut.session = .signedOut
        #expect(!owesAFollow(try signedOut.assessed()))
        var unread = try pairWorld(.castle).0
        unread.vault = nil
        #expect(!owesAFollow(try unread.assessed()))
        var anotherAccounts = try pairWorld(.standard).0
        passphraseMovedElsewhere(&anotherAccounts)
        anotherAccounts.vault?.accountID = PF.id()
        #expect(!owesAFollow(try anotherAccounts.assessed()))
    }

    /// Both-present legs only (E6 among them): a key file with no passphrase lock (joined by the words) has no
    /// descriptor to compare — its words leg still reads; a file with no words copy has no words leg; a reading without a
    /// half says nothing of it.
    @Test func eachLegReadsOnlyWhenBothHalvesArePresent() throws {
        var joinedByWords = try pairWorld(.castle).0
        joinedByWords.liveFile.passphrase = nil
        passphraseMovedElsewhere(&joinedByWords)
        #expect(!owesAFollow(try joinedByWords.assessed()), "E6: no lock, no passphrase leg")
        try wordsMovedElsewhere(&joinedByWords)
        #expect(try joinedByWords.assessed().acts.contains(.follow(.pairChanged(passphrase: false, words: true), typesOneSecret: false)))
        var noCopy = try pairWorld(.standard).0
        noCopy.liveFile.masterWordsCopy = nil
        try wordsMovedElsewhere(&noCopy)
        #expect(!owesAFollow(try noCopy.assessed()), "no copy, no words leg")
        var halfRead = try pairWorld(.standard).0
        passphraseMovedElsewhere(&halfRead)
        try wordsMovedElsewhere(&halfRead)
        halfRead.vault?.kdf = nil
        halfRead.vault?.recoveryWrap = nil
        #expect(!owesAFollow(try halfRead.assessed()), "a reading without the halves")
    }

    /// Another key's file in the live place is rule 21's own fault and offer — never read for the account's pair.
    @Test func anotherKeysFileInTheLivePlaceSaysNothingOfThePair() throws {
        var world = try pairWorld(.standard).0
        passphraseMovedElsewhere(&world)
        let stray = StoreKey.mint()
        world.liveFile = try KeyFile.building(
            libraryID: world.world.library, key: stray, epoch: 1,
            locks: NewKeyLocks(passphrase: try PF.passphraseKey("a stray"), words: world.world.w))
        let assessed = try world.assessed()
        #expect(!owesAFollow(assessed))
        #expect(assessed.faults.contains(.liveKeyFileIsAnotherKeys(keyFileID: AWorld.liveKeyFileID)))
    }

    /// The pure reading itself, table by table.
    @Test func thePureReadingIsTheTwoComparisons() throws {
        let world = try KeyWorld()
        let key = StoreKey.mint()
        let copy = try world.masterWordsCopy
        let file = try KeyFile.building(libraryID: world.library, key: key, epoch: 1, locks: world.castleLocks())
        let same = VaultReading(accountID: "a", mode: .castle, rowKeyID: "c1", kdf: world.p.kdf, recoveryWrap: copy)
        #expect(AssessRules.pairFollow(file, same) == nil)
        var moved = same
        moved.kdf = PF.fastKDF()
        #expect(AssessRules.pairFollow(file, moved) == .pairChanged(passphrase: true, words: false))
        moved.recoveryWrap = Data(copy.reversed())
        #expect(AssessRules.pairFollow(file, moved) == .pairChanged(passphrase: true, words: true))
        moved.kdf = world.p.kdf
        #expect(AssessRules.pairFollow(file, moved) == .pairChanged(passphrase: false, words: true))
        #expect(AssessRules.pairFollow(nil, moved) == nil)
        let local = try world.castleFile(key, synced: false)
        #expect(AssessRules.pairFollow(local, moved) == nil, "an unsynced file has no words copy to compare")
    }
}
