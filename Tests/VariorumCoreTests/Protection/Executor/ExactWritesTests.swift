//
//  ExactWritesTests.swift
//  VariorumCoreTests — VX-305 U3: "the exact writes in order" (the phase plan
//  §5) for the acts the crossing suites don't already pin — the follow into
//  Castle, a leave, a landing, a key door, this Mac's settings, the re-arm —
//  each read against the design's own order before it was pinned (the
//  record says so). Resume Sync after a landing; the losing device's account
//  key; the file swap's road keys.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — the exact writes of the follow, a leave, a landing, a key door, the settings, the re-arm")
struct ExactWritesTests {
    @Test func theFollowIntoCastle() async throws {
        let mac = try EX(.standard, synced: true)
        let phone = try EX(.standard, synced: true, joining: mac)
        let k0 = phone.key
        let me = mac.executor()
        var ml = try mac.unlocked(me)
        _ = try await me.useCastle(&ml, typed: mac.typed, gate: .touchID)
        let executor = phone.executor()
        var library = try phone.unlocked(executor)
        phone.world.writes = []
        _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: phone.words))
        #expect(phone.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(library.key): "K1", phone.ownApple!.id: "OWN"]) == [
            "record K0", "memory K0", "plan",                        // the act named (its gate chosen at this press)
            "sync+ touchid", "sync- silent",                         // the new master, the Castle way; one item per account
            "plan", "plan",                                          // the sync key it took, stamped; the step done
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan",
            "swap K1", "plan", "memory K1", "plan",
            "custody- silent K0", "plan",                            // no silent item for any key the library has had
            "plan",                                                  // the export was off
            "apple- OWN", "record K1", "memory K1", "plan",          // its own key deleted, recorded retired
            "backup K1", "plan", "record K1", "memory K1", "plan-",
        ])
    }

    @Test func aLeaveInCastle() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library)
        #expect(library.key == k0)
        // Rule 16: the record stops naming the account, this Mac forgets its
        // sync keys — no key, lock or secret changes.
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0"]) == [
            "record K0", "memory K0", "plan",
            "record K0", "memory K0", "plan",                        // the record names no account
            "sync- touchid", "plan",                                 // this Mac stops using the account
            "backup K0", "plan", "record K0", "memory K0", "plan-",
        ])
    }

    @Test func aKeyDoorSynced() async throws {
        let fixture = try EX(.castle, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "another")
        #expect(fixture.world.writeLog(naming: [PF.fp(fixture.key): "K"]) == [
            "record K", "memory K", "plan", "vault castle", "plan", "keyfile K", "plan", "memory K", "plan",
            "record K", "memory K", "plan-",
        ])
    }

    @Test func theSettingsAndTheReArm() async throws {
        let fixture = try EX(.castle, gate: .alwaysAsk)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        var settings = library.section.settings
        settings.gateStyle = .touchID
        _ = try await executor.changeSettings(&library, to: settings, passphrase: fixture.passphrase)
        #expect(fixture.world.writeLog(naming: [PF.fp(fixture.key): "K"]) == [
            "record K", "memory K", "plan", "custody+ touchid K", "plan", "record K", "memory K", "plan", "memory K", "plan",
            "record K", "memory K", "plan-",
        ])
        fixture.world.writes = []
        _ = try await executor.answerTouchIDRearm(&library, yes: true)
        #expect(fixture.world.writeLog(naming: [PF.fp(fixture.key): "K"]) == [
            "record K", "memory K", "plan", "custody- touchid K", "custody+ touchid K", "plan", "plan", "memory K", "plan",
            "record K", "memory K", "plan-",
        ])
    }
}

@Suite("VX-305 U3 — two leaves at once; the file swap's road keys")
struct ExecutorEdgeTests {
    /// Two devices leaving Castle at once (rule 12's mode flag): the phone's
    /// leave stops just before its vault write; the Mac's lands; the phone's
    /// resume finds the flag flipped already and finishes its own library's
    /// leave with no second write — nothing on the server waited, nothing was
    /// minted for the account.
    @Test func theSecondLeaveFindsTheFlagFlippedAndWritesNothingMore() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        phone.world.crashAfterWrites = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("vault") })
        let pe = phone.executor()
        var pl = try phone.unlocked(pe)
        await #expect(throws: SimulatedCrash.self) { _ = try await pe.useStandard(&pl, typed: phone.typed) }
        #expect(phone.world.server.snapshot(phone.account!)!.mode == .castle, "the phone's write landed before the crash")
        let me = mac.executor()
        var ml = try mac.unlocked(me)
        _ = try await me.useStandard(&ml, typed: mac.typed)
        let afterMac = try #require(phone.world.server.snapshot(phone.account!))
        let (outcome, library, _) = try await phone.relaunchAndSettle()
        guard case .resumed = outcome else { Issue.record("the phone's leave did not resume: \(outcome)"); return }
        #expect(phone.liveRecord?.mode == .standard)
        #expect(phone.world.server.snapshot(phone.account!) == afterMac, "the second leave wrote the vault again")
        #expect(!phone.world.writes.contains { if case .vaultUpdate = $0 { return true } else { return false } })
        expectSettled(phone, library)
    }

}
