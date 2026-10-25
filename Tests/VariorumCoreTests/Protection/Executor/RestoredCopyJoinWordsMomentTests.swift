//
//  RestoredCopyJoinWordsMomentTests.swift
//  VariorumCoreTests — VX-529 unit 3, the rider VX-523 (the VX-510 walk's W-6): A JOIN FROM A RESTORED COPY WHOSE WORDS
//  ALREADY ARE THE ACCOUNT'S. On a synced Mac, Make this my library lands the copy as a NEW library "under your current
//  pair" (rule 17) — the account's pair, since the device was synced (rule 7) — and binds no account (P-VX378-U2-4 (a),
//  whose own text says "a later join is rule 7's — and since it already holds the current pair, which is the account's
//  when the device was synced, no words are replaced"). Joining it by the account's PASSPHRASE still owes the words
//  moment (`ActNotice.wordsReplacedByAccount`): the one quiet rule (`ProtectionExecutor.wordsAreTheAccountsAlready`,
//  VX-456/VX-462) proves sameness by wrap identity — no own words lock, the master's twelve-words copy byte-equal to the
//  vault's recovery wrap, a master lock the account's master opens — and Make this my library's new key file is built
//  with an OWN words lock and no master lock or copy (`makeMineKeyFile` → `newLocks(words: true, master: false)`), so the
//  rule's first clause fails and nothing else can prove the words from the files alone. A join by the WORDS stays quiet
//  (they open the own lock — the rule's other arm).
//  NOT FIXED HERE — returned to the orchestrator (the run record's UNIT 3 — LIVE STATUS, VX-523): the one rule cannot reach
//  this path without changing what Make this my library WRITES (a custody act's key file — the master lock and its words
//  copy, P-VX378-U2-4's option (b) territory), and a looser proof (the passphrase lock's descriptor) would go quiet over a
//  real replacement. The red row is held as a KNOWN ISSUE so the suite stays green and the fix must flip it.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-529 unit 3 — VX-523: a join from a restored copy whose words are the account's")
struct RestoredCopyJoinWordsMomentTests {
    private func replaced(_ outcome: ActOutcome) -> Bool { outcome.notices.contains(.wordsReplacedByAccount) }

    /// The account (another device turned sync on first), a laptop that JOINED it by the passphrase (the VX-462 shape: no
    /// own words lock, the master and its words copy), and the laptop's own backup made its library by Make this my
    /// library under the CURRENT pair — the account's.
    private func aRestoredCopyOnASyncedMac() async throws -> (mac: EX, laptop: EX, executor: ProtectionExecutor,
                                                              library: UnlockedLibrary) {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        let synced = try #require(laptop.world.liveFormat3)
        #expect(synced.words == nil && synced.masterWordsCopy != nil, "the joined laptop holds the account's pair")
        let (copy, catalog) = try plantCopy(
            laptop, libraryID: laptop.libraryID, key: library.key, keyFile: synced, record: laptop.liveRecord)
        _ = try await executor.makeThisMyLibrary(
            &library, copy: copy, in: catalog, currentPair: TypedSecrets(passphrase: mac.passphrase, words: mac.words))
        #expect(library.record?.account == nil, "the new library binds no account (P-VX378-U2-4 (a))")
        let restored = try #require(laptop.world.liveFormat3)
        #expect(try restored.open(words: mac.words) == library.key, "it holds the account's words")
        return (mac, laptop, executor, library)
    }

    /// **W-6 — the walk's road (red on the tree as it stands; held as a KNOWN ISSUE — un-fixed, returned):** the restored
    /// copy joins by the account's PASSPHRASE. Its words already are the account's — nothing is replaced, so the moment is
    /// owed nothing.
    @Test func aRestoredCopyJoiningByThePassphraseHearsNoReplacement() async throws {
        let restored = try await aRestoredCopyOnASyncedMac()
        var library = restored.library
        let joined = try await restored.executor.enroll(&library, typed: TypedSecrets(passphrase: restored.mac.passphrase))
        #expect(restored.laptop.liveRecord?.account == restored.mac.account)
        withKnownIssue("VX-523: Make this my library's key file carries its own words lock and no master copy, so the quiet rule cannot prove the words (un-fixed — returned)") {
            #expect(!replaced(joined), "the restored copy's words were the account's already — nothing to say")
        }
    }

    /// The other arm, a guard (green on both sides): by the WORDS, they open the restored copy's own lock — quiet.
    @Test func aRestoredCopyJoiningByTheWordsIsQuiet() async throws {
        let restored = try await aRestoredCopyOnASyncedMac()
        var library = restored.library
        let joined = try await restored.executor.enroll(&library, typed: TypedSecrets(words: restored.mac.words))
        #expect(!replaced(joined))
    }
}
