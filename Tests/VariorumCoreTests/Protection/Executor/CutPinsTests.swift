//
//  CutPinsTests.swift
//  VariorumCoreTests — VX-378 U1: THE CUT'S BEHAVIOUR PINS. Each was written
//  BEFORE its cut and seen red on the pre-cut tree (the record in the plan's
//  §8 U1 RECORD names the red run), then green after. A pure deletion needs no
//  pin; these are the deletions that change what an act does.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U1 — the cut's behaviour pins (red on the pre-cut tree)")
struct CutPinsTests {
    /// RULE 4 (`notes/CastleRules.md`): "every key change carries that list
    /// forward — no exceptions". Leaving Castle (Use Standard) mints a new
    /// Standard key whose key file's history holds the outgoing Castle key —
    /// so the current passphrase or words open the Castle-era copies (rule
    /// 12). The anchor and the leave's empty history were the exception.
    @Test func leavingCastleCarriesTheHistory() async throws {
        let fixture = try EX(.castle)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useStandard(&library, typed: fixture.typed)
        let k1 = library.key
        #expect(k1 != k0 && fixture.liveRecord?.mode == .standard)
        #expect(try fixture.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0,
                "the leave's new key file must carry the outgoing Castle key in its history (rule 4)")
    }

    /// RULE 4 again, on a follower: a device following its account out of
    /// Castle carries its outgoing Castle key into the new Standard key's
    /// history (rule 12: "a new Standard key carrying every earlier key").
    @Test func aFollowOutOfCastleCarriesTheHistory() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let k0 = phone.key
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(&macLibrary, typed: mac.typed)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        _ = try await executor.follow(&library, kind: .intoStandard, typed: TypedSecrets(passphrase: phone.passphrase))
        let k1 = library.key
        #expect(k1 != k0 && phone.liveRecord?.mode == .standard)
        #expect(try phone.world.liveFormat3?.historyKey(PF.fp(k0), currentKey: k1) == k0,
                "the follow's new key file must carry the outgoing Castle key in its history (rule 4)")
    }

    /// RULE 12 (the stuck leave cut): the leave's account write never leaves
    /// the vault in the id-with-no-wrap window that only a device reading the
    /// named key could close. Crashed right after its first vault write, a
    /// synced Use Standard leaves the vault reading Standard already.
    @Test func aCrashedLeaveNeverLeavesTheVaultWaitingForANamedKey() async throws {
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        let firstVaultWrite = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        let fixture = try EX(.castle, synced: true)
        fixture.world.crashAfterWrites = firstVaultWrite + 1
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        await #expect(throws: SimulatedCrash.self) { _ = try await executor.useStandard(&library, typed: fixture.typed) }
        let vault = try #require(fixture.world.server.snapshot(fixture.account!))
        #expect(vault.format.masterWrappedByAppleHeld != nil,
                "a leave's first vault write left an Apple key id with no wrap — the stuck leave's window (rule 12)")
    }
}
