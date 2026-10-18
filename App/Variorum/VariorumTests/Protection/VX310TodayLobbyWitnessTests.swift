//
//  VX310TodayLobbyWitnessTests.swift
//  VariorumTests — VX-306 U1b piece 3: VX-310'S TWO BUGS, WITNESSED ON TODAY'S ROAD — the RED-ON-OLD half of the
//  new road's pins (`ProtectionLobbyModelTests`, the same scenarios). Today's road is the pre-fix code: it is
//  what a Debug build ran before the one switch, and it is still what every RELEASE build runs (byte-unchanged
//  until VX-329's release switch), so each witness is a KNOWN ISSUE — and a tripwire: if today's road ever stops
//  showing the bug, `withKnownIssue` fails ("known issue was not recorded") and this file must be revisited.
//
//  THE MECHANISMS, traced (the ticket's file:line, re-read on this tree):
//    1. `AppBootstrap.routeAndOpen`'s `.lobby` arm (and `lock()`'s): `biometryOffered: demand == .biometric &&
//       guardSeam.gatedItemExists()` — a PRESENCE probe and the demand, never whether a finger is enrolled; so a
//       Mac with Touch ID hardware and no finger gets the button, the automatic ask and the prompt line
//       *"Unlock your library with Touch ID."* (`ProtectionCopy.lobbyPrompt(.biometric)`).
//    2. `StoreLobby.biometryOffered` is a `let`, fixed from ONE probe when the lobby is built, and the lobby has no
//       re-read: a lobby built while the probe answered "no" (the ticket's suspect — a re-lock just after a
//       cancelled prompt) has no button until a new lobby is built — a relaunch. The real-world cause of the
//       probe's "no" is not reproducible headless (Unknown, recorded); the scripted guard's
//       `gatedWritesAreInvisible` stands in for that one answer.
//

import Dependencies
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1b — VX-310's two bugs witnessed on TODAY'S road (Release's until VX-329): known issues", .serialized)
@MainActor
struct VX310TodayLobbyWitnessTests {
    private func castleWorld(
        backing: InMemoryStoreKeyGuardBacking
    ) throws -> (bootstrap: AppBootstrap, key: StoreKey, dir: URL) {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("vx306-vx310-witness-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let storeURL = dir.appendingPathComponent("store.sqlite")
        let key = try #require(backing.gated)
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "sesame", kdf: LobbyFixture.fastKDF)
        // Today's road: a passphrase wrap with no Apple copy derives Castle; always-ask off is the Touch ID gate.
        let gate = StoreLaunchGate.scripted(dials: ProtectionDials(alwaysAsk: false), backing: backing, envelope: envelope)
        let bootstrap = AppBootstrap(
            testOpener: {
                Result { try AppDatabase.onDisk(url: storeURL, key: key) }
                    .mapError { AppDatabase.StoreOpenError(storePath: storeURL.path, reason: String(describing: $0)) }
            },
            gate: gate)
        return (bootstrap, key, dir)
    }

    @Test func bug1_todaysLobbyOffersTouchIDOnAMacWithNoFingerEnrolled() async throws {
        let backing = InMemoryStoreKeyGuardBacking(gated: StoreKey.mint(), biometryAvailable: false, biometricSucceeds: false)
        let world = try castleWorld(backing: backing)
        defer { try? FileManager.default.removeItem(at: world.dir) }
        #expect(!world.bootstrap.newRoad, "today's road")
        await world.bootstrap.awaitOpen()
        guard case .locked(let lobby) = world.bootstrap.state else {
            Issue.record("expected today's lobby, got \(world.bootstrap.state)")
            return
        }
        withKnownIssue("VX-310 bug 1 on today's road — Release keeps it until VX-329; the new road's lobby has no button here") {
            #expect(!lobby.biometryOffered, "no finger enrolled: no Touch ID button, no automatic ask")
            #expect(!ProtectionCopy.lobbyPrompt(lobby.demand).contains("Touch ID"), "no 'unlock with Touch ID' line")
        }
    }

    @Test func bug2_todaysLobbyLosesTheButtonUntilARelaunchWhenItsOneProbeMissedTheItem() async throws {
        try await withDependencies {
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.uuid = .incrementing
        } operation: { @MainActor in
            let backing = InMemoryStoreKeyGuardBacking(gated: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: false)
            let world = try castleWorld(backing: backing)
            defer { try? FileManager.default.removeItem(at: world.dir) }
            await world.bootstrap.awaitOpen()
            guard case .locked(let first) = world.bootstrap.state else {
                Issue.record("expected today's lobby, got \(world.bootstrap.state)")
                return
            }
            #expect(first.biometryOffered)
            // She dismisses the Touch ID prompt, then opens with the passphrase.
            await first.unlockWithBiometrics()
            await first.unlock(passphrase: "sesame")
            await world.bootstrap.awaitOpen()
            guard case .ready = world.bootstrap.state else {
                Issue.record("expected ready after the passphrase, got \(world.bootstrap.state)")
                return
            }
            // A re-lock while the presence probe answers "no" (the item is there all along) …
            backing.gatedWritesAreInvisible = true
            await world.bootstrap.lock()
            backing.gatedWritesAreInvisible = false
            guard case .locked(let second) = world.bootstrap.state else {
                Issue.record("expected today's lobby after the re-lock, got \(world.bootstrap.state)")
                return
            }
            #expect(backing.gated != nil, "the Touch ID item exists the whole time")
            // … and today's lobby never reads again: the button is gone until a relaunch builds a new lobby.
            withKnownIssue("VX-310 bug 2 on today's road — Release keeps it until VX-329; the new road re-reads on her return") {
                #expect(second.biometryOffered, "a Touch ID item exists — the button must be there")
            }
        }
    }
}
