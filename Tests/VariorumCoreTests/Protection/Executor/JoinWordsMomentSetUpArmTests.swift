//
//  JoinWordsMomentSetUpArmTests.swift
//  VariorumCoreTests — VX-309 walk finding W-VX309-5: VX-456's quiet re-join, from a library that SET UP the account (rule
//  7's hand-up) rather than joined one. The walk set up sync on a library with no passphrase yet (rule 3's arm: the set-up
//  sheet chose the passphrase), stopped syncing here, and re-joined by that same passphrase — and the words moment spoke.
//  `JoinWordsMomentTests` pins join → leave → re-join; these pin set-up → leave → re-join, both arms. VX-462 (VX-329 R1): set-up
//  re-made the library's OWN words lock from the typed words beside the master's twelve-words copy, and the leave (rule 16)
//  changes no lock, so `wordsAreTheAccountsAlready` (no own words lock — P-VX309-U2-1) could never hold at the re-join and the
//  moment spoke. Where the master's words copy is written it holds the very words typed, so the own lock is not kept (the
//  copy is the words' road) — the `withKnownIssue` wrappers these pins carried until then are DROPPED: they were the
//  red-on-old. The same mechanism reached the join by the WORDS (its own lock re-made from the account's words): pinned below.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 walk W-VX309-5 — VX-456's quiet re-join after SET-UP")
struct JoinWordsMomentSetUpArmTests {
    private func replaced(_ outcome: ActOutcome) -> Bool { outcome.notices.contains(.wordsReplacedByAccount) }

    /// A library WITH a passphrase sets up the account (its pair handed up), stops syncing here, re-joins by the same
    /// passphrase: its words were the account's all along — quiet.
    @Test func aRejoinAfterSetUpByThePassphraseIsQuiet() async throws {
        let fixture = try EX(.standard)
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: fixture.passphrase))
        #expect(!replaced(rejoined), "set up from this library's own pair — nothing was replaced")
        let file = try #require(fixture.world.liveFormat3)
        #expect(file.words == nil && file.masterWordsCopy != nil, "the words open it through the account's copy alone")
        #expect(try file.open(.words(fixture.words), floor: PF.floor) == library.key, "the library's words open it still")
        #expect(try file.open(.passphrase(fixture.passphrase), floor: PF.floor) == library.key)
    }

    /// The walk's exact arm: a library with NO passphrase (its words only) sets up the account choosing its passphrase
    /// there (rule 3), stops syncing here, re-joins by that passphrase — quiet.
    @Test func aRejoinAfterSetUpThatChoseThePassphraseIsQuiet() async throws {
        let fixture = try EX(.standard)
        fixture.world.liveKeyFile = try KeyFile.building(
            libraryID: fixture.libraryID, key: fixture.key, epoch: 1,
            locks: NewKeyLocks(words: fixture.w, apple: fixture.ownApple))
        let account = PF.id()
        let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
        var library = try fixture.unlocked(executor)
        let chosen = "a passphrase chosen at set-up"
        _ = try await executor.setUpSync(&library, typed: TypedSecrets(words: fixture.words, newPassphrase: chosen))
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: chosen))
        #expect(!replaced(rejoined), "set up from this library's own words — nothing was replaced")
        let file = try #require(fixture.world.liveFormat3)
        #expect(try file.open(.words(fixture.words), floor: PF.floor) == library.key, "the library's words open it still")
        #expect(try file.open(.passphrase(chosen), floor: PF.floor) == library.key, "the passphrase chosen at set-up")
    }

    /// THE SAME MECHANISM ON THE JOIN BY THE WORDS: another device made the account; this library joins by the account's
    /// WORDS (its own words lock was re-made from them beside the account's copy), stops syncing here, and comes back by
    /// the account's PASSPHRASE — its words were the account's all along: quiet, exactly as the passphrase join's re-join.
    @Test func aRejoinByThePassphraseAfterAJoinByTheWordsIsQuiet() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        let joined = try await executor.enroll(&library, typed: TypedSecrets(words: mac.words))
        #expect(replaced(joined), "the laptop's own words were replaced by the account's — said")
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        let rejoined = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect(!replaced(rejoined), "the words were the account's already — nothing to say")
        let file = try #require(laptop.world.liveFormat3)
        #expect(try file.open(.words(mac.words), floor: PF.floor) == library.key, "the account's words open it")
        #expect((try? file.open(.words(laptop.words), floor: PF.floor)) == nil, "the laptop's old words do not")
    }
}
