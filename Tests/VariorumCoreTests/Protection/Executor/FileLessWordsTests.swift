//
//  FileLessWordsTests.swift
//  VariorumCoreTests — VX-308 U3, VX-447 (her ruling, QUESTIONS #235's HER RULINGS block: the no-key-file banner BECOMES
//  THE DOOR — "we should fix it so that the act can proceed": record the words → a fresh key file → the backup follows).
//  RULE 27's after-open state: the library OPENED (by a quiet road — this Mac's silent item) and NO copy of its key file
//  is left anywhere this Mac keeps one — nothing in the live place, no sealed mirror of the current key, no catalogued key
//  file OF the current key (`Fault.noKeyFileAnywhere`'s first arm). The new-words act (`regenerateWords`) refused there
//  (`.noLiveKeyFile` / `.secretMissing`): its one key-file step re-locks a file that must exist. The arm is widened
//  EXACTLY for that state — the act MINTS the file it then locks — each authorization a twin of one the core already
//  has: Standard + unsynced, nothing asked (the reset door's plain confirm, P-VX307-U2b-1's twin); synced, the account's
//  passphrase verified against the vault (the synced arm as it stands). Castle + unsynced keeps refusing, and so does
//  every state where ANY copy of the key file still stands (the mirror's restore and rule 21's offer are its roads, and
//  a fresh file would throw away the history that copy carries) or where a stray stands in the live place (minting
//  would write over it — rule 21: never a repair by guessing).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-308 U3 — VX-447: new words on a library whose key file is gone everywhere mint the file they lock")
struct FileLessWordsTests {
    /// `fixture`'s library with rule 27's state planted: no key file in the live place, and nothing this Mac remembers
    /// (so no sealed mirror) — then opened with the key in hand (the silent item's road).
    private func fileLess(_ fixture: EX) throws -> (ProtectionExecutor, UnlockedLibrary) {
        fixture.world.liveKeyFile = nil
        fixture.world.memories = [:]
        let executor = fixture.executor()
        let library = try fixture.unlocked(executor)
        #expect(library.keyFile == nil && library.memory == nil, "the state as planted")
        fixture.world.writes = []
        return (executor, library)
    }

    /// The words scanned for in everything the act wrote (the key file, what this Mac remembers, the record).
    private func storedAnywhere(_ fixture: EX, _ words: [String]) throws -> Bool {
        let text = words.joined(separator: " ")
        var stored: [Data] = []
        if let live = fixture.world.liveFormat3 { stored.append(try ProtectionCoding.canonical(live)) }
        stored += fixture.world.memories.values.map(\.payload)
        if let record = fixture.liveRecord { stored.append(try ProtectionCoding.canonical(record)) }
        return stored.contains { SecretScan.carries($0, text: text) }
    }

    /// STANDARD, UNSYNCED — the banner's everyday state: nothing asked; a FRESH key file of the current key is written,
    /// locked by the new words alone (no lock survived to carry — the passphrase's lived in the lost file), the key
    /// unchanged, this Mac's sealed copy following it (rule 1's second home back), rule 3's fact now "no passphrase",
    /// the act ended, the words stored nowhere. RED ON OLD: the act refused (`secretMissing` — no live file to read).
    @Test func aStandardLibraryWithNoKeyFileAnywhereMintsOneLockedByTheNewWords() async throws {
        let fixture = try EX(.standard)
        var (executor, library) = try fileLess(fixture)
        let key = library.key
        let record = try #require(library.record)
        let fresh = try PF.words()
        let outcome = try await executor.regenerateWords(&library, passphrase: nil, newWords: fresh)
        #expect(outcome.done.isEmpty)
        let minted = try #require(fixture.world.liveFormat3, "a fresh key file beside the library")
        #expect(library.key == key, "rule 6: the key does not change")
        #expect(minted.fingerprint == PF.fp(key) && minted.libraryID == record.libraryID && minted.epoch == record.keyEpoch)
        #expect(try minted.open(words: fresh) == key, "the words she records open the library")
        #expect((try? minted.open(words: fixture.words)) == nil, "the old words (their lock went with the file) do not")
        #expect(minted.passphrase == nil && minted.master == nil && minted.apple == nil && minted.history.isEmpty,
                "only what the act can vouch for: the new words' lock")
        #expect(library.keyFile == minted)
        #expect(library.memory?.keyFileMirror == minted, "rule 1: this Mac's sealed copy follows the fresh file")
        #expect(fixture.liveRecord?.passphraseSet == false, "rule 3's fact: no passphrase lock exists now")
        #expect(library.section.actInFlight == nil && fixture.world.plan == nil, "the act ended")
        #expect(try !storedAnywhere(fixture, fresh), "the words are stored")
        #expect(fixture.world.writes.contains(.keyFile(f8(key))))
    }

    /// SYNCED (either posture) — the account's passphrase, verified against the vault as the synced arm always is; the
    /// vault's words re-wrapped by the act's one CAS write (rule 7: the key doors change the library's and the account's
    /// locks together); the fresh file carries the account's passphrase lock, the new words' lock and the master with its
    /// twelve-words copy (a synced library's file, as setting up sync made it). RED ON OLD: `noLiveKeyFile`.
    @Test(arguments: [ProtectionMode.standard, .castle])
    func aSyncedLibraryWithNoKeyFileAnywhereMintsTheFileAndTheAccountsWordsChangeTogether(_ mode: ProtectionMode)
        async throws {
        let fixture = try EX(mode, synced: true)
        var (executor, library) = try fileLess(fixture)
        let key = library.key
        let account = try #require(fixture.account)
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: fresh)
        let vault = try #require(fixture.world.server.snapshot(account))
        #expect(VaultModel.master(of: vault.vault, passphrase: nil, words: try WordsKey.derive(fresh)) != nil,
                "the account's words are the new words")
        #expect(VaultModel.master(of: vault.vault, passphrase: nil, words: try WordsKey.derive(fixture.words)) == nil,
                "the old words no longer open the account")
        let minted = try #require(fixture.world.liveFormat3)
        #expect(minted.fingerprint == PF.fp(key) && library.key == key)
        #expect(try minted.open(words: fresh) == key)
        #expect(try minted.open(passphrase: .passphrase(fixture.passphrase), floor: PF.floor) == key,
                "the account's passphrase lock, re-made")
        #expect(minted.passphrase?.kdf == vault.vault.kdf, "one descriptor names one passphrase — the vault's")
        #expect(minted.masterWordsCopy == vault.vault.masterByWords && minted.master != nil)
        #expect(try minted.open(wordsThroughMaster: fresh) == key, "the words open it through the master too (§3.5a)")
        #expect(minted.apple == nil && minted.history.isEmpty)
        #expect(library.memory?.keyFileMirror == minted)
        #expect(fixture.liveRecord?.passphraseSet == true, "rule 3's fact: bound, the account's passphrase")
        #expect(library.section.actInFlight == nil && fixture.world.plan == nil)
        #expect(try !storedAnywhere(fixture, fresh))
    }

    /// Synced, the passphrase is always asked (the vault's lock is re-made under the account's master); a wrong one
    /// refuses — nothing written either way.
    @Test func aSyncedFileLessLibraryIsStillAskedTheAccountsPassphrase() async throws {
        let fixture = try EX(.standard, synced: true)
        var (executor, library) = try fileLess(fixture)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.regenerateWords(&library, passphrase: "not it", newWords: try PF.words())
        }
        #expect(fixture.world.liveFormat3 == nil && fixture.world.writes.isEmpty, "nothing written")
    }

    /// CASTLE, UNSYNCED keeps refusing: no lock survives to verify a passphrase and Castle has no plain confirm (its
    /// forgot road types the words or presses Touch ID — neither reaches a file that is gone). Nothing written.
    @Test func castleUnsyncedFileLessStillRefuses() async throws {
        let fixture = try EX(.castle)
        var (executor, library) = try fileLess(fixture)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        await #expect(throws: ExecutorRefusal.passphraseDoesNotOpen) {
            _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: try PF.words())
        }
        #expect(fixture.world.liveFormat3 == nil && fixture.world.writes.isEmpty, "nothing written")
    }

    /// AS NARROW AS THE STATE: any copy of the current key's file still standing — this Mac's sealed mirror (rule 1's
    /// restore is its road), a backup's (rule 21's offer is its road) — or a STRAY in the live place (another key's file:
    /// minting would write over it) means NO mint: the act refuses exactly as before, nothing written. (Green on the old
    /// tree too — these are the arm's guards; the record's mutations drop each guard to watch it red.)
    @Test func anyCopyOfTheKeyFileStandingMeansNoMint() async throws {
        // (a) The mirror holds the current key's file (what this Mac remembers kept).
        let mirrored = try EX(.standard)
        mirrored.world.liveKeyFile = nil
        let mirroredExecutor = mirrored.executor()
        var mirroredLibrary = try mirrored.unlocked(mirroredExecutor)
        #expect(mirroredLibrary.memory?.keyFileMirror?.fingerprint == PF.fp(mirrored.key))
        mirrored.world.writes = []
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await mirroredExecutor.regenerateWords(&mirroredLibrary, passphrase: nil, newWords: try PF.words())
        }
        #expect(mirrored.world.liveFormat3 == nil && mirrored.world.writes.isEmpty, "(a) nothing written")

        // (b) A backup pair holds the current key's file (the catalogue's copy).
        let backedUp = try EX(.standard)
        let own = try #require(backedUp.world.liveFormat3)
        backedUp.world.backups = [ExecutorWorld.Backup(
            fingerprint: own.fingerprint, keyFile: own, record: backedUp.liveRecord, deviceID: backedUp.deviceID)]
        var (backedUpExecutor, backedUpLibrary) = try fileLess(backedUp)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await backedUpExecutor.regenerateWords(&backedUpLibrary, passphrase: nil, newWords: try PF.words())
        }
        #expect(backedUp.world.liveFormat3 == nil && backedUp.world.writes.isEmpty, "(b) nothing written")

        // (c) A stray in the live place (another library's key file), nothing else holding the current key.
        let strayed = try EX(.standard)
        var (strayExecutor, strayLibrary) = try fileLess(strayed)
        let stray = try KeyFile.building(
            libraryID: "another-library", key: StoreKey.mint(), epoch: 1,
            locks: NewKeyLocks(words: try WordsKey.derive(try PF.words())))
        strayed.world.liveKeyFile = stray
        strayLibrary.keyFile = stray
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await strayExecutor.regenerateWords(&strayLibrary, passphrase: nil, newWords: try PF.words())
        }
        #expect(strayed.world.liveFormat3 == stray && strayed.world.writes.isEmpty, "(c) the stray untouched")
    }

    /// The everyday arms are byte-unchanged: a library WITH its key file mints nothing new — the look re-locks the file
    /// it has (its history and every other lock kept), and a library with a passphrase lock is still asked it.
    @Test func aLibraryWithItsKeyFileIsUntouchedByTheArm() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = try #require(fixture.world.liveFormat3)
        await #expect(throws: ExecutorRefusal.secretMissing) {
            _ = try await executor.regenerateWords(&library, passphrase: nil, newWords: try PF.words())
        }
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: fixture.passphrase, newWords: fresh)
        let after = try #require(fixture.world.liveFormat3)
        #expect(after.passphrase == before.passphrase && after.apple == before.apple && after.history == before.history)
        #expect(try after.open(words: fresh) == library.key)
    }
}
