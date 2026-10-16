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
            "sync+ touchid", "sync- silent", "plan",                 // the new master, the Castle way; one item per account
            "plan",                                                  // the corpus key it took, stamped (VX-305 U4)
            "plan",                                                  // no rotation left to help
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan",
            "swap K1", "plan", "memory K1", "plan",
            "custody- silent K0", "plan",                            // no silent item for any key the library has had
            "plan",                                                  // the export was off
            "apple- OWN", "record K1", "memory K1", "plan",          // its own key deleted, recorded retired
            "record K1", "memory K1", "plan",                        // the account's recorded retired
            "backup K1", "plan", "record K1", "memory K1", "plan-",
        ])
    }

    @Test func aLeaveInCastle() async throws {
        let fixture = try EX(.castle, synced: true)
        let k0 = fixture.key
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.leaveAccount(.stopSyncingHere, &library, typed: fixture.typed)
        #expect(fixture.world.writeLog(naming: [PF.fp(k0): "K0", PF.fp(library.key): "K1"]) == [
            "record K0", "memory K0", "plan",
            "custody+ touchid K1", "plan", "keyfile K1", "plan", "stage K1", "plan", "staged-record K1", "plan",
            "swap K1", "plan", "memory K1", "plan", "custody- touchid K0", "plan",
            "sync- touchid", "plan",                                 // this Mac stops using the account — after the swap
            "backup K1", "plan", "record K1", "memory K1", "plan-",
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

@Suite("VX-305 U3 — Resume Sync after a landing; the losing device's account key; the file swap's road keys")
struct ExecutorEdgeTests {
    @Test func theDeviceWhoseLeaveLostTheRaceDeletesTheAccountKeyItMinted() async throws {
        let mac = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: mac)
        // The phone starts its leave and stops right after minting its account key.
        let clean = try EX(.castle, synced: true)
        let ce = clean.executor()
        var cl = try clean.unlocked(ce)
        _ = try await ce.useStandard(&cl, typed: clean.typed)
        phone.world.crashAfterWrites = try #require(clean.world.writes.firstIndex { $0.description.hasPrefix("apple+") }) + 1
        let pe = phone.executor()
        var pl = try phone.unlocked(pe)
        await #expect(throws: SimulatedCrash.self) { _ = try await pe.useStandard(&pl, typed: phone.typed) }
        // A Castle account holds no Apple key: the one in iCloud Keychain now is
        // the phone's fresh account key (added before its record — the crash
        // came between).
        #expect(phone.world.icloud.keys.count == 1)
        let phoneMinted = try #require(phone.world.icloud.keys.keys.first)
        // The Mac's leave lands meanwhile.
        let me = mac.executor()
        var ml = try mac.unlocked(me)
        _ = try await me.useStandard(&ml, typed: mac.typed)
        // The phone's resume finds the account moved: it rolls back, and the
        // key it minted — which the vault doesn't name — goes, recorded retired.
        let (outcome, library, _) = try await phone.relaunchAndSettle()
        #expect(outcome == .rolledBack(.leaveCastle))
        #expect(phone.world.icloud.keys[phoneMinted] == nil)
        #expect(library.section.retiredAppleKeyIDs.contains(phoneMinted))
        #expect(phone.world.server.snapshot(phone.account!)!.format.appleKeyID != phoneMinted)
    }

    @Test func aLibraryFileSwappedForAnOlderOneLosesToTheNewerMemoryWithTheRoadsKeys() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key, own = fixture.ownApple!.id
        let older = fixture.world.live!
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        // A login-password holder swaps the library file back for the older one.
        fixture.world.live = older
        // The lobby's road: the passphrase opens the live key file (K1); its
        // history opens the swapped-in file (K0).
        let swapped = try fixture.executor().unlock(with: k0, alsoInHand: [k1])
        #expect(swapped.memory != nil)
        #expect(swapped.section.retiredAppleKeyIDs.contains(own))  // delete on sight survives the replay
        // With the road's keys dropped, the newer memory could not verify.
        let blind = try fixture.executor().unlock(with: k0)
        #expect(blind.memory == nil && !blind.section.retiredAppleKeyIDs.contains(own))
    }
}
