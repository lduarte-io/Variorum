//
//  JoinWordsMomentTests.swift
//  VariorumCoreTests — VX-309 U2 piece 1: VX-456 — THE JOIN'S WORDS MOMENT IS OWED ONLY WHEN THE WORDS WERE REALLY REPLACED
//  (rule 7; her ruling at the VX-308 handoff sitting, 2026-10-19: the moment fires only on a real replacement). The join
//  adopts the account's pair (rule 7: "a device holds one pair of secrets at a time"); `ActNotice.wordsReplacedByAccount`
//  tells the face to say so. Before VX-456 the core said it for EVERY passphrase-typed join (`sameWords` was false whenever
//  no words were typed) — so a library whose words already WERE the account's (signed out, then back in: rule 16's
//  "signing back in is a join") heard that its words had been replaced by the same words. The rule is decided by the key
//  file and the vault alone — by wrap identity, never by deriving or storing words:
//    - the words typed open the library's OWN words lock (they were its words all along) — quiet (unchanged); or
//    - the library has NO words lock of its own, and its key file's twelve-words copy of the master IS the account's
//      recovery wrap byte for byte (RFC 3394 is deterministic — the same words over the same master make the same bytes),
//      beside a master lock the account's master opens — so the only words that open it are the account's — quiet.
//  Anything else speaks (the sentence is true either way; silence over a real replacement would hide a lost road): a
//  library with its own words lock beside a matching copy cannot be PROVEN to hold the account's words (a New Words made
//  after a leave rewrites the own lock and leaves the copy stale), so it speaks — PROVISIONAL P-VX309-U2-1.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U2 — VX-456: the join's words moment only on a real replacement")
struct JoinWordsMomentTests {
    /// The account (another device turned sync on first — its own pair is the account's) and a local library on this Mac
    /// (its own pair), sharing the server and iCloud Keychain; the laptop's executor signed in as the account.
    private func accountAndLaptop() throws -> (mac: EX, laptop: EX, executor: ProtectionExecutor) {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        return (mac, laptop, laptop.executor(session: mac.session))
    }

    private func replaced(_ outcome: ActOutcome) -> Bool { outcome.notices.contains(.wordsReplacedByAccount) }

    /// THE GUARD: a library with words of its own joining by the account's passphrase — its words ARE replaced (its own
    /// lock goes; the account's open it now). The moment speaks, as before.
    @Test func aLibraryWithWordsOfItsOwnHearsThemReplaced() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        let joined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(replaced(joined), "its own words were replaced by the account's")
        let live = try #require(laptop.world.liveFormat3)
        #expect(live.words == nil && (try? live.open(.words(laptop.words), floor: PF.floor)) == nil)
        #expect(try live.open(.words(mac.words), floor: PF.floor) == library.key)
    }

    /// RED ON OLD — VX-456's arm: joined once by the passphrase (the library's own words lock gone; only the account's
    /// words open it, through the master's twelve-words copy), then Stop syncing here (rule 16: no key, lock or secret
    /// changes), then signing back in is a join — by the passphrase again. Nothing was replaced: the moment stays QUIET,
    /// and the library opens with exactly what it opened with before.
    @Test func aRejoinByThePassphraseWhoseWordsAreAlreadyTheAccountsIsQuiet() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let before = try #require(laptop.world.liveFormat3)
        #expect(before.words == nil && before.masterWordsCopy != nil, "the account's words open it — and only they")
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(!replaced(rejoined), "the words were the account's already — nothing to say")
        #expect(laptop.liveRecord?.account == mac.account)
        let after = try #require(laptop.world.liveFormat3)
        #expect(try after.open(.words(mac.words), floor: PF.floor) == library.key, "the account's words open it still")
        expectSettled(laptop, library)
    }

    /// RED ON OLD — the same arm with the WORDS typed: the library has no words lock of its own (they went at the first
    /// passphrase join), so the typed words open nothing of its own — but its copy of the master IS the account's recovery
    /// wrap: quiet.
    @Test func aRejoinByTheWordsWhoseWordsAreAlreadyTheAccountsIsQuiet() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words))
        #expect(!replaced(rejoined), "the words typed are the account's, which already were the library's")
        expectSettled(laptop, library)
    }

    /// Unchanged: the words typed open the library's OWN words lock (joined by the words, left, back by the words) — quiet.
    @Test func aRejoinTypingWordsThatOpenItsOwnLockIsQuiet() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words))
        #expect(!replaced(rejoined))
    }

    /// THE HONEST LIMIT (P-VX309-U2-1): the first device of the account (it handed its own pair up — its own words lock
    /// stands beside the account's copy), Stop syncing here, back by the PASSPHRASE: its own words lock can't be proven to
    /// be the account's words from the files alone, so the moment speaks — a true sentence (they are the account's now).
    @Test func theFirstDevicesOwnWordsLockBesideTheCopyStillSpeaks() async throws {
        let mac = try EX(.standard, synced: true)
        let executor = mac.executor()
        var library = try mac.unlocked(executor)
        let file = try #require(mac.world.liveFormat3)
        #expect(file.words != nil && file.masterWordsCopy == mac.world.server.snapshot(mac.account!)?.vault.masterByWords)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(replaced(rejoined), "an own words lock beside the copy is not proof — said")
    }

    /// THE GUARD AGAINST THE OTHER ARM: joined by the passphrase, Stop syncing here, then NEW WORDS here while local (the
    /// own words lock re-made; the master's copy left as the account's), back by the passphrase — the words she recorded at
    /// the look ARE replaced by the account's. It must speak (a quiet join would hide it).
    @Test func newWordsMadeAfterALeaveAreReplacedAndSaid() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let fresh = try RecoveryPhrase.generate()
        _ = try await executor.regenerateWords(&library, passphrase: mac.passphrase, newWords: fresh)
        let local = try #require(laptop.world.liveFormat3)
        #expect(try local.open(words: fresh) == library.key, "the new words lock stands")
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(replaced(rejoined), "the words recorded at the look no longer open it — said")
        #expect((try? laptop.world.liveFormat3?.open(.words(fresh), floor: PF.floor)) == nil)
    }

    /// THE GUARD: the account's words changed on another device since the leave (its recovery wrap re-made under new
    /// words) — the library's copy is the OLD wrap, so its words are replaced by the account's new ones: said.
    @Test func theAccountsWordsChangedElsewhereSinceTheLeaveIsSaid() async throws {
        let (mac, laptop, executor) = try accountAndLaptop()
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let account = try #require(mac.account)
        let held = try #require(mac.world.server.accounts[account])
        let master = try #require(held.vault.master(passphrase: mac.p, words: nil))
        let newWords = try WordsKey.derive(try RecoveryPhrase.generate())
        mac.world.server.accounts[account] = ExecutorVault.Account(
            revision: held.revision + 1,
            vault: try VaultModel.rewrappingWords(held.vault, master: master, words: newWords, device: "Studio Mac"),
            updatedAt: nil)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(replaced(rejoined), "the copy the library carries is the account's OLD wrap — the words were replaced")
    }

    /// THE PURE RULE (`ProtectionExecutor.wordsAreTheAccountsAlready`), arm by arm, over files built by hand: true only with
    /// no own words lock, the copy byte-identical to the vault's recovery wrap, and a master lock the account's master opens.
    @Test func thePureRuleReadsTheFilesAlone() throws {
        let world = ExecutorWorld()
        let words = try PF.words()
        let (vault, keys) = try VaultModel.creating(
            passphrase: try PF.passphraseKey("an account passphrase"), words: try PF.wordsKey(words), mode: .standard,
            device: "Mac A", ids: world)
        let (otherVault, otherKeys) = try VaultModel.creating(
            passphrase: try PF.passphraseKey("another passphrase"), words: try PF.wordsKey(words), mode: .standard,
            device: "Mac B", ids: world)
        let key = StoreKey.mint()
        let bare = KeyFile(libraryID: PF.id(), key: key, epoch: 1)
        let accounts = try bare.settingMaster(keys.masterKey, wordsCopy: vault.masterByWords, for: key)
        let rule = ProtectionExecutor.wordsAreTheAccountsAlready
        #expect(rule(accounts, vault, keys.masterKey), "no own lock, the copy the vault's, the master lock the account's")
        #expect(!rule(nil, vault, keys.masterKey), "no key file")
        #expect(!rule(accounts, vault, nil), "no master reached")
        #expect(!rule(bare, vault, keys.masterKey), "no copy at all")
        #expect(!rule(try accounts.settingWords(try PF.wordsKey(words), for: key), vault, keys.masterKey),
                "an own words lock beside the copy proves nothing")
        // The SAME words over ANOTHER master make other bytes (the copy is the account's, not merely the same words').
        #expect(!rule(accounts, otherVault, otherKeys.masterKey), "another account's recovery wrap")
        // A matching copy beside a master lock the account's master does NOT open (a stray assembled by hand).
        let mismatched = try bare.settingMaster(otherKeys.masterKey, wordsCopy: vault.masterByWords, for: key)
        #expect(!rule(mismatched, vault, keys.masterKey), "the master lock is another master's")
    }
}
