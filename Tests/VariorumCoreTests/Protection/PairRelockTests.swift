//
//  PairRelockTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 2's pure pieces: the key file
//  RE-LOCKED to the account's pair (`KeyFile.relockedToTheAccountsPair`,
//  `droppingWords`) — rule 6's verb, never a re-key; rule 7's one pair; rule
//  22's verify-before-replace; rules 4–5's floor untouched.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced library's key file as a lagging device holds it: the old passphrase (descriptor A), its own words lock (the
/// old words — a New Words once made HERE), the master with the vault's copy of the old words, an older key in its history
/// and (Standard) this Mac's Apple wrap — and the account's pair as the other device re-made it.
struct LaggingFile {
    let world: KeyWorld
    let key = StoreKey.mint()
    let older = StoreKey.mint()
    let apple = AppleKeyMaterial.mint()
    let file: KeyFile
    let newPassphrase = "a passphrase made on the other Mac"
    let newP: PassphraseKey
    let newWords: [String]
    /// The vault's recovery wrap now: the SAME master under the new words.
    let newCopy: Data

    init() throws {
        world = try KeyWorld()
        let first = try KeyFile.building(
            libraryID: world.library, key: older, epoch: 1, locks: NewKeyLocks(passphrase: world.p, words: world.w))
        file = try first.rekeyed(
            from: older, to: key, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: world.master,
                               masterWordsCopy: try world.masterWordsCopy, apple: apple),
            at: PF.day(1))
        newP = try PF.passphraseKey(newPassphrase)
        newWords = try PF.words()
        newCopy = try AES.KeyWrap.wrap(world.master, using: try PF.wordsKey(newWords).key)
    }

    func reading(passphrase: Bool, words: Bool) throws -> VaultReading {
        VaultReading(accountID: "a", mode: .standard, rowKeyID: "c1", kdf: passphrase ? newP.kdf : world.p.kdf,
                     recoveryWrap: words ? newCopy : try world.masterWordsCopy)
    }
}

@Suite("VX-529 — the key file re-locked to the account's pair: a re-lock, never a re-key (rules 6, 7, 22, 4–5)")
struct PairRelockTests {
    /// What a re-lock never touches: the key, its epoch and library, the history, the master lock's bytes, the Apple wrap.
    func expectNothingButTheLocksMoved(_ before: KeyFile, _ after: KeyFile, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(after.fingerprint == before.fingerprint && after.epoch == before.epoch && after.libraryID == before.libraryID,
                sourceLocation: sourceLocation)
        #expect(after.history == before.history, "the history changed", sourceLocation: sourceLocation)
        #expect(after.master == before.master, "the master lock was re-made", sourceLocation: sourceLocation)
        #expect(after.apple == before.apple, "the Apple wrap changed", sourceLocation: sourceLocation)
        #expect(after.formatVersion == before.formatVersion, sourceLocation: sourceLocation)
    }

    @Test func thePassphraseHalfReMakesTheLockUnderTheAccountsDescriptorAndNothingElse() throws {
        let lag = try LaggingFile()
        let relocked = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: try lag.world.masterWordsCopy,
            passphraseLock: .remake(lag.newP), dropsOwnWordsLock: false)
        expectNothingButTheLocksMoved(lag.file, relocked)
        #expect(relocked.passphrase?.kdf == lag.newP.kdf, "fact 1: the lock under the vault's descriptor")
        #expect(try relocked.open(passphrase: .passphrase(lag.newPassphrase), floor: PF.floor) == lag.key)
        #expect((try? relocked.open(passphrase: .passphrase(lag.world.passphrase), floor: PF.floor)) == nil,
                "rule 7's one pair: the old passphrase still opens the live library")
        #expect(relocked.words == lag.file.words, "the words did not move — their lock stays")
        #expect(try relocked.open(words: lag.world.words) == lag.key)
        #expect(AssessRules.pairFollow(relocked, try lag.reading(passphrase: true, words: false)) == nil, "still owed")
    }

    @Test func theWordsHalfTakesTheVaultsCopyAndDropsTheStaleOwnLock() throws {
        let lag = try LaggingFile()
        let relocked = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .keep,
            dropsOwnWordsLock: true)
        expectNothingButTheLocksMoved(lag.file, relocked)
        #expect(relocked.masterWordsCopy == lag.newCopy, "§3.5a: the vault's recovery wrap, byte for byte")
        #expect(relocked.words == nil, "the stale own words lock stays")
        #expect(try relocked.open(.words(lag.newWords), floor: PF.floor) == lag.key, "the account's words open it")
        #expect((try? relocked.open(.words(lag.world.words), floor: PF.floor)) == nil,
                "E8: the old words still open the live library")
        #expect(relocked.passphrase == lag.file.passphrase, "the passphrase did not move — its lock stays")
        #expect(AssessRules.pairFollow(relocked, try lag.reading(passphrase: false, words: true)) == nil, "still owed")
    }

    /// E5: both halves at once — one typed passphrase; the words ride the vault's copy.
    @Test func bothHalvesAtOnce() throws {
        let lag = try LaggingFile()
        let relocked = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .remake(lag.newP),
            dropsOwnWordsLock: true)
        expectNothingButTheLocksMoved(lag.file, relocked)
        #expect(try relocked.open(passphrase: .passphrase(lag.newPassphrase), floor: PF.floor) == lag.key)
        #expect(try relocked.open(.words(lag.newWords), floor: PF.floor) == lag.key)
        for old in [ProtectionSecret.passphrase(lag.world.passphrase), .words(lag.world.words)] {
            #expect((try? relocked.open(old, floor: PF.floor)) == nil)
        }
        #expect(AssessRules.pairFollow(relocked, try lag.reading(passphrase: true, words: true)) == nil)
    }

    /// Rules 4–6: the key did not change, so the history is the one it was — the account's current secrets reach every
    /// older key through it, and a backup frozen before the re-lock keeps opening with the secrets of its day.
    @Test func theFloorHoldsOlderKeysThroughTheHistoryAndTheOldBackupWithItsDaysSecrets() throws {
        let lag = try LaggingFile()
        let backup = lag.file  // a copy frozen before the re-lock (the act rewrites no backup — E7)
        let relocked = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .remake(lag.newP),
            dropsOwnWordsLock: true)
        for secret in [ProtectionSecret.passphrase(lag.newPassphrase), .words(lag.newWords)] {
            let current = try relocked.open(secret, floor: PF.floor)
            #expect(try relocked.historyKey(PF.fp(lag.older), currentKey: current) == lag.older)
        }
        for secret in [ProtectionSecret.passphrase(lag.world.passphrase), .words(lag.world.words)] {
            #expect(try backup.open(secret, floor: PF.floor) == lag.key, "the backup's own secrets")
        }
    }

    /// Rule 22, verified before anything is replaced: a master that does not open this file's key through its master
    /// lock (another account's, a master changed since) refuses, and so does a file with no master lock at all.
    @Test func aMasterThatDoesNotReachThisKeyRefusesBeforeAnythingIsReplaced() throws {
        let lag = try LaggingFile()
        #expect(throws: KeyFileError.doesNotOpen(.master)) {
            _ = try lag.file.relockedToTheAccountsPair(
                key: lag.key, master: SymmetricKey(size: .bits256), accountsWordsCopy: lag.newCopy, passphraseLock: .keep,
                dropsOwnWordsLock: true)
        }
        let local = try lag.world.castleFile(lag.key, synced: false)
        #expect(throws: KeyFileError.noSuchWrap(.master)) {
            _ = try local.relockedToTheAccountsPair(
                key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .keep,
                dropsOwnWordsLock: true)
        }
        #expect(throws: KeyFileError.keyIsNotThisFilesKey) {
            _ = try lag.file.relockedToTheAccountsPair(
                key: lag.older, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .keep,
                dropsOwnWordsLock: false)
        }
    }

    /// A resume re-running the write lands the same file (AES key wrap is deterministic): idempotent.
    @Test func reLockingTwiceIsReLockingOnce() throws {
        let lag = try LaggingFile()
        let once = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .remake(lag.newP),
            dropsOwnWordsLock: true)
        let twice = try once.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: lag.newCopy, passphraseLock: .remake(lag.newP),
            dropsOwnWordsLock: true)
        #expect(twice == once)
    }

    /// R-529-5's words arm at the value level: `.drop` takes ONLY the passphrase lock — the master lock's bytes, the
    /// history, the Apple wrap untouched; the words open it through the account's copy; rule 22's check still first.
    @Test func theWordsArmDropsOnlyTheStalePassphraseLock() throws {
        let lag = try LaggingFile()
        let relocked = try lag.file.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: try lag.world.masterWordsCopy, passphraseLock: .drop,
            dropsOwnWordsLock: false)
        expectNothingButTheLocksMoved(lag.file, relocked)
        #expect(relocked.passphrase == nil && relocked.words == lag.file.words)
        #expect((try? relocked.open(passphrase: .passphrase(lag.world.passphrase), floor: PF.floor)) == nil)
        #expect(try relocked.open(.words(lag.world.words), floor: PF.floor) == lag.key)
        #expect(throws: KeyFileError.doesNotOpen(.master)) {
            _ = try lag.file.relockedToTheAccountsPair(
                key: lag.key, master: SymmetricKey(size: .bits256), accountsWordsCopy: lag.newCopy, passphraseLock: .drop,
                dropsOwnWordsLock: false)
        }
        #expect(lag.file.droppingPassphrase().passphrase == nil && lag.file.droppingPassphrase().words == lag.file.words)
    }

    /// The brief's P7-3 premise, corrected and pinned: `.remake` LANDS a passphrase lock where none exists (the setter
    /// sets or replaces) — E6's state re-locked by a typed current passphrase.
    @Test func reMakeLandsALockWhereNoneExists() throws {
        let lag = try LaggingFile()
        let e6 = lag.file.droppingPassphrase()
        let healed = try e6.relockedToTheAccountsPair(
            key: lag.key, master: lag.world.master, accountsWordsCopy: try lag.world.masterWordsCopy,
            passphraseLock: .remake(lag.newP), dropsOwnWordsLock: false)
        #expect(healed.passphrase?.kdf == lag.newP.kdf)
        #expect(try healed.open(passphrase: .passphrase(lag.newPassphrase), floor: PF.floor) == lag.key)
    }

    /// The value setter (a dropper on the VALUE — no shape change): only the own words lock goes.
    @Test func droppingWordsDropsOnlyTheOwnWordsLock() throws {
        let lag = try LaggingFile()
        var expected = lag.file
        expected.words = nil
        #expect(lag.file.droppingWords() == expected)
        #expect(lag.file.droppingWords().opensWithTheWords, "the master's copy keeps the words' road")
    }
}

/// P-VX529-4 (PROVISIONAL), the E6 heal's primitive — pinned with no consumer (unit 2 wires it).
@Suite("VX-529 P7-3 — the E6 heal: a passphrase lock landed where none exists, nothing else touched")
struct E6HealPrimitiveTests {
    @Test func itLandsTheAccountsPassphraseWhereNoLockExists() throws {
        let lag = try LaggingFile()
        let e6 = lag.file.droppingPassphrase()
        let healed = try e6.landingTheAccountsPassphraseLock(lag.newP, key: lag.key, master: lag.world.master)
        #expect(healed.passphrase?.kdf == lag.newP.kdf)
        #expect(try healed.open(passphrase: .passphrase(lag.newPassphrase), floor: PF.floor) == lag.key)
        var rest = healed
        rest.passphrase = nil
        #expect(rest == e6, "the heal touched more than the passphrase lock")
        #expect(try healed.landingTheAccountsPassphraseLock(lag.newP, key: lag.key, master: lag.world.master) == healed,
                "landing twice changed it")
    }

    /// Land-where-missing ONLY: a lock already there — the account's, or a stale one that owes the catch-up — is never
    /// replaced here (that is the catch-up's and the key doors' business).
    @Test func itNeverReplacesALockThatIsThere() throws {
        let lag = try LaggingFile()
        #expect(try lag.file.landingTheAccountsPassphraseLock(lag.newP, key: lag.key, master: lag.world.master) == lag.file)
    }

    /// The file must be the account's: the master must reach its key through its master lock; an unsynced file (no
    /// master lock) and another key refuse.
    @Test func itRefusesAFileThatIsNotTheAccounts() throws {
        let lag = try LaggingFile()
        let e6 = lag.file.droppingPassphrase()
        #expect(throws: KeyFileError.doesNotOpen(.master)) {
            _ = try e6.landingTheAccountsPassphraseLock(lag.newP, key: lag.key, master: SymmetricKey(size: .bits256))
        }
        let local = try lag.world.castleFile(lag.key, synced: false).droppingPassphrase()
        #expect(throws: KeyFileError.noSuchWrap(.master)) {
            _ = try local.landingTheAccountsPassphraseLock(lag.newP, key: lag.key, master: lag.world.master)
        }
        #expect(throws: KeyFileError.keyIsNotThisFilesKey) {
            _ = try e6.landingTheAccountsPassphraseLock(lag.newP, key: lag.older, master: lag.world.master)
        }
    }
}
