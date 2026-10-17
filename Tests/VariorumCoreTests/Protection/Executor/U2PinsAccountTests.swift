//
//  U2PinsAccountTests.swift
//  VariorumCoreTests — VX-378 U2 piece E: the vault's account side, replaced
//  whole (`notes/CastleRules.md` rules 7, 11, 12, 14, 15). Written against the
//  API both trees share — the write log, the refusals, the settle's outcome —
//  so the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — the account's side: one write in, a flag out, no Apple lock, one secret to join")
struct U2PinsAccountTests {
    static func vaultWrites(_ fixture: EX) -> Int {
        fixture.world.writes.filter { if case .vaultUpdate = $0 { return true } else { return false } }.count
    }

    static func appleAdds(_ fixture: EX) -> Int {
        fixture.world.writes.filter { if case .appleAdd = $0 { return true } else { return false } }.count
    }

    /// Rules 11 + 15: "On the account: a new sync key, in one write."
    @Test func enteringCastleWritesTheVaultOnce() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        #expect(Self.vaultWrites(fixture) == 1, "\(fixture.world.writeLog())")
    }

    /// Rule 12: leaving flips the mode — one write, no key for the account
    /// minted (rule 14: the vault has no Apple lock); only this Mac's own
    /// Apple key for its library is new.
    @Test func leavingCastleFlipsTheFlagInOneWriteAndMintsNothingForTheAccount() async throws {
        let fixture = try EX(.castle, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        #expect(Self.vaultWrites(fixture) == 1, "\(fixture.world.writeLog())")
        #expect(Self.appleAdds(fixture) == 1, "an Apple key was minted for the account")
    }

    /// Rule 15: the sync key changes ONLY when the account enters Castle.
    @Test func replaceAllKeysLeavesTheAccountsSyncKeyAlone() async throws {
        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.replaceAllKeys(&library, typed: fixture.typed)
        #expect(Self.vaultWrites(fixture) == 0, "\(fixture.world.writeLog())")
    }

    /// Rule 14: no Apple lock in the vault — turning sync on in Standard mints
    /// no Apple key for the account.
    @Test func turningSyncOnInStandardMintsNoAppleKeyForTheAccount() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor(session: .signedIn(accountID: PF.id(), email: nil))
        var library = try fixture.unlocked(executor)
        _ = try await executor.setUpSync(&library, typed: fixture.typed)
        #expect(Self.appleAdds(fixture) == 0)
    }

    /// Rule 7: the first device hands its library's pair up — the words typed,
    /// never made new; and no crossing makes new words either (only creating a
    /// library shows fresh words).
    @Test func noDoorButCreationMakesNewWords() async throws {
        let local = try EX(.standard)
        let e1 = local.executor(session: .signedIn(accountID: PF.id(), email: nil))
        var l1 = try local.unlocked(e1)
        await #expect(throws: (any Error).self, "sync setup made new words") {
            _ = try await e1.setUpSync(&l1, typed: TypedSecrets(passphrase: local.passphrase, words: try PF.words(), wordsAreNew: true))
        }
        let other = try EX(.standard)
        let e2 = other.executor()
        var l2 = try other.unlocked(e2)
        await #expect(throws: (any Error).self, "Use Castle made new words") {
            _ = try await e2.useCastle(&l2, typed: TypedSecrets(passphrase: other.passphrase, words: try PF.words(), wordsAreNew: true), gate: .touchID)
        }
    }

    /// Rule 14: joining types ONE of the account's secrets; rule 7: the face is
    /// told the library's words are now the account's.
    @Test func joiningTypesOneSecretAndSaysTheWordsWereReplaced() async throws {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        let outcome = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        #expect("\(outcome.notices)".contains("wordsReplaced"), "\(outcome.notices)")
        #expect(laptop.liveRecord?.account == mac.account)
    }

    /// Rule 12: "other devices follow out quietly, with a notice."
    @Test func followingOutOfCastleTypesNothing() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let me = mac.executor()
        var ml = try mac.unlocked(me)
        _ = try await me.useStandard(&ml, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        let outcome = try await executor.follow(&library, kind: .intoStandard, typed: .none)
        #expect(phone.liveRecord?.mode == .standard)
        #expect("\(outcome.notices)".contains("followedOutOfCastle"), "\(outcome.notices)")
    }

    /// Rule 20 (promise 6's vault-reach qualifier gone): a synced entry crashed
    /// after its one vault write and before its swap, relaunched with the
    /// vault out of reach, ROLLS BACK — it never waits; the follow picks the
    /// write up as any device's.
    @Test func aResumeThatCantReachTheVaultBeforeItsSwapRollsBack() async throws {
        let clean = try EX(.standard, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useCastle(&cl, typed: clean.typed, gate: .touchID)
        let vaultWrite = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        let fixture = try EX(.standard, synced: true)
        fixture.world.crashAfterWrites = vaultWrite + 1
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: SimulatedCrash.self) { _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID) }
        fixture.world.server.reachable = false
        let (outcome, settled, _) = try await fixture.relaunchAndSettle()
        #expect(outcome == .rolledBack(.enterCastle), "\(outcome)")
        #expect(settled.section.actInFlight == nil)
        #expect(fixture.liveRecord?.mode == .standard)
    }
}
