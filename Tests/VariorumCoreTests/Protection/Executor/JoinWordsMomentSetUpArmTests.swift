//
//  JoinWordsMomentSetUpArmTests.swift
//  VariorumCoreTests — VX-309 walk finding W-VX309-5: VX-456's quiet re-join, from a library that SET UP the account (rule
//  7's hand-up) rather than joined one. The walk set up sync on a library with no passphrase yet (rule 3's arm: the set-up
//  sheet chose the passphrase), stopped syncing here, and re-joined by that same passphrase — and the words moment spoke.
//  `JoinWordsMomentTests` pins join → leave → re-join; these pin set-up → leave → re-join, both arms. KNOWN ISSUES today: set-up
//  keeps the library's own words lock beside the master's twelve-words copy, and `wordsAreTheAccountsAlready` answers false for
//  any file with an own words lock (P-VX309-U2-1 — it cannot prove the two are the same words). When the arm is fixed these
//  flip: drop the `withKnownIssue` wrappers.
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
        withKnownIssue("W-VX309-5: set-up keeps the library's own words lock beside the account's copy, so the quiet check (P-VX309-U2-1) can't prove them equal and speaks") {
            #expect(!replaced(rejoined), "set up from this library's own pair — nothing was replaced")
        }
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
        withKnownIssue("W-VX309-5: set-up keeps the library's own words lock beside the account's copy, so the quiet check (P-VX309-U2-1) can't prove them equal and speaks") {
            #expect(!replaced(rejoined), "set up from this library's own words — nothing was replaced")
        }
    }
}
