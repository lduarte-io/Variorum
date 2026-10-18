//
//  U2CrashHarnessTests.swift
//  VariorumCoreTests — VX-378 U2: the executor's crash-after-every-write harness
//  over the acts piece E changed and no earlier harness run covered — sync setup
//  handing the pair up, a same-posture join adopting the account's pair, a synced
//  key door re-locking the vault's master, a follow into Castle. Every crash
//  finishes or never happened (rule 20), never a third state.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — the crash harness over the account acts the new vault changed (rule 20)")
struct U2CrashHarnessTests {
    @Test func syncSetup() async throws {
        let account = PF.id()
        try await CrashHarness.everywhere(
            { let f = try EX(.standard); f.account = account; return f },
            act: { fixture, _, library in
                let executor = fixture.executor(session: .signedIn(accountID: account, email: nil))
                _ = try await executor.setUpSync(&library, typed: fixture.typed)
            },
            finished: { fixture, _ in fixture.liveRecord?.account == account && fixture.world.server.snapshot(account) != nil },
            neverHappened: { fixture, _ in fixture.liveRecord?.account == nil && fixture.world.server.snapshot(account) == nil })
    }

    @Test func aSamePostureJoinTypingOneSecret() async throws {
        var mac: EX!
        try await CrashHarness.everywhere(
            {
                mac = try EX(.standard, synced: true)
                let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
                laptop.account = mac.account
                return laptop
            },
            act: { _, executor, library in _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase)) },
            finished: { fixture, _ in fixture.liveRecord?.account == mac.account },
            neverHappened: { fixture, _ in fixture.liveRecord?.account == nil },
            typed: { _ in TypedSecrets(passphrase: mac.passphrase) })
    }

    @Test func aSyncedKeyDoor() async throws {
        let fresh = "a passphrase changed on the Mac"
        func opens(_ fixture: EX, _ passphrase: String) -> Bool {
            guard let live = fixture.world.liveFormat3, let vault = fixture.world.server.snapshot(fixture.account!)?.vault,
                  let key = try? PassphraseKey.derive(passphrase, kdf: vault.kdf) else { return false }
            return (try? live.open(passphrase: .passphrase(passphrase), floor: PF.floor)) != nil
                && vault.master(passphrase: key, words: nil) != nil
        }
        try await CrashHarness.everywhere(
            { try EX(.standard, synced: true) },
            act: { fixture, executor, library in
                _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: fresh)
            },
            finished: { fixture, _ in opens(fixture, fresh) },
            neverHappened: { fixture, _ in opens(fixture, fixture.passphrase) },
            typed: { TypedSecrets(passphrase: $0.passphrase, words: $0.words, newPassphrase: fresh) })
    }

    @Test func aFollowIntoCastle_AlwaysAsk() async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let mac = try EX(.standard, synced: true)
                let phone = try EX(.standard, synced: true, gate: .alwaysAsk, joining: mac)
                k0 = phone.key
                let e = mac.executor()
                var l = try mac.unlocked(e)
                _ = try await e.useCastle(&l, typed: mac.typed, gate: .touchID)
                return phone
            },
            act: { fixture, executor, library in
                _ = try await executor.follow(&library, kind: .intoCastle, typed: TypedSecrets(words: fixture.words), gate: .alwaysAsk)
            },
            finished: { fixture, _ in fixture.liveRecord?.mode == .castle && fixture.world.live!.fingerprint != PF.fp(k0) },
            neverHappened: { fixture, _ in fixture.liveRecord?.mode == .standard && fixture.world.live!.fingerprint == PF.fp(k0) },
            typed: { TypedSecrets(words: $0.words) })
    }
}
