//
//  RoadRestoreHoldGateTests.swift
//  VariorumTests — VX-308 U4 piece 1: F-4 — THE RESTORE HOLD'S GATE ON THE SYNCED CROSSINGS (the 13x F1 R1-M1 rule,
//  carried onto the new road now that the account arms make a synced crossing reachable). While the hold's marker stands
//  beside the store (`LibraryRestoreHold` — the gates' one source, 13x R3-2), a SYNCED Use Castle and Replace All Keys say
//  their refusal IN PLACE of the door (P-VX307-U2a-2's idiom) and the press's re-read refuses with it before anything
//  closes (VX-108 — the preflight reads the crossings the same way). A LOCAL Use Castle stays open (the hold is about sync).
//  Over the new road's PLANTED leaves (`PlantedRoad` + the planted vault — no keychain, no network; also runs headless in
//  the implementer's SwiftPM harness).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U4 — F-4: a standing restore hold refuses the synced crossings (planted, no network)")
@MainActor
struct RoadRestoreHoldGateTests {
    typealias Account = PlantedAccount

    struct Synced {
        let road: PlantedRoad
        let vault: PlantedVaultLeaf
        let session: ProtectionRoadSession
        let words: [String]
    }

    /// A library on the planted road, turned on to sync with the planted account (rule 7's hand-up — U1's road).
    static func synced() async throws -> Synced {
        let (road, vault, _) = Account.road()
        let (session, words) = try await road.created()
        let read = try await Account.read(session, Account.signedIn)
        let shown = try #require(ProtectionPaneRead.accountFaces(read)?.face(.turnOnSync).openDoor)
        let press = await ProtectionAccountRoad.press(
            session,
            request: RoadAccountRequest(
                door: .turnOnSync, shown: shown, typed: TypedSecrets(words: words, newPassphrase: Account.passphrase)),
            signIn: Account.signedIn, exportSwitch: nil)
        #expect(press == .made(receipt: ProtectionWords.turnOnSyncReceipt), "the library syncs")
        return Synced(road: road, vault: vault, session: session, words: words)
    }

    /// The crossings as the pane reads them now (its one read — the sign-in now, a fresh vault read).
    static func faces(_ session: ProtectionRoadSession, _ signIn: SessionFact = Account.signedIn) async throws -> RoadCrossingFaces {
        let read = try await Account.read(session, signIn)
        return try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road, read: read))
    }

    static func hold(_ road: PlantedRoad) throws {
        try LibraryRestoreHold.set(besideStore: road.slot.places.slot, asOf: nil, now: Date())
    }

    /// THE GATE: a synced library's Use Castle and Replace All Keys are open — then the hold lands beside the store and
    /// each says its refusal in place, naming Resume Sync; a press whose confirm opened before the hold refuses at its
    /// re-read with the same sentence, nothing written (no vault write, the key and the posture as they were); Resume's
    /// clear lifts the gate. RED on the pre-fix tree: the doors stayed open and the preflight answered `.ready`.
    @Test func aStandingHoldRefusesTheSyncedCrossingsInPlaceAndAtThePress() async throws {
        let world = try await Self.synced()
        let before = try await Self.faces(world.session)
        let castle = try #require(before.useCastle.openDoor, "\(before.useCastle)")
        let replace = try #require(before.replaceAllKeys.openDoor, "\(before.replaceAllKeys)")
        #expect(castle.synced && replace.synced, "account-wide crossings")
        let key = world.session.key
        let calls = world.vault.calls.count

        try Self.hold(world.road)
        let held = try await Self.faces(world.session)
        for (door, face) in [(RoadCrossingDoor.useCastle, held.useCastle), (.replaceAllKeys, held.replaceAllKeys)] {
            guard case .refused(let sentence) = face else {
                Issue.record("\(door) refuses in place while the hold stands: \(face)")
                continue
            }
            #expect(sentence.contains("Resume Sync"), "the refusal names Resume Sync: \(sentence)")
        }
        #expect(held.useStandard == before.useStandard, "Use Standard is not the gate's (no round — today's own exemption)")

        // The press — its confirm opened before the hold: the re-read refuses, before anything closes.
        let typed = TypedSecrets(passphrase: Account.passphrase, words: world.words)
        for (door, shown) in [(RoadCrossingDoor.useCastle, castle), (.replaceAllKeys, replace)] {
            let read = try await Account.read(world.session, Account.signedIn)
            let preflight = ProtectionCrossings.preflight(
                world.session, door: door, shown: shown, typed: typed, exportSwitch: PlantedExportSwitch().road, read: read)
            guard case .refused(let sentence) = preflight else {
                Issue.record("\(door)'s press refuses at its re-read while the hold stands: \(preflight)")
                continue
            }
            #expect(sentence.contains("Resume Sync"), "\(sentence)")
        }
        #expect(!world.vault.calls.dropFirst(calls).contains { $0.hasPrefix("update") }, "no vault write")
        #expect(world.session.key == key && world.session.library.record?.mode == .standard, "nothing moved")

        // Resume's clear (the one press) lifts the gate.
        #expect(LibraryRestoreHold.clear(besideStore: world.road.slot.places.slot))
        let resumed = try await Self.faces(world.session)
        #expect(resumed.useCastle.openDoor == castle && resumed.replaceAllKeys.openDoor == replace)
    }

    /// The gate is SYNC's: a LOCAL library's Use Castle stays open under the hold and its press passes the preflight (a
    /// local crossing writes no vault and runs no round — and the dev store's local walks stay walkable).
    @Test func aLocalLibrarysUseCastleStaysOpenUnderTheHold() async throws {
        let road = PlantedRoad()
        let (session, words) = try await road.created()
        try Self.hold(road)
        let faces = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: PlantedExportSwitch().road))
        let castle = try #require(faces.useCastle.openDoor, "\(faces.useCastle)")
        #expect(!castle.synced)
        #expect(faces.replaceAllKeys == .hidden, "no account — not rendered (P-2)")
        let typed = TypedSecrets(words: words, newPassphrase: Crossing.passphrase)
        #expect(ProtectionCrossings.preflight(
            session, door: .useCastle, shown: castle, typed: typed, exportSwitch: PlantedExportSwitch().road) == .ready)
    }
}
