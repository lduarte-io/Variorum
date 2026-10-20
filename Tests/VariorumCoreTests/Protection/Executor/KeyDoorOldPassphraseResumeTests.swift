//
//  KeyDoorOldPassphraseResumeTests.swift
//  VariorumCoreTests — VX-309 U1b piece 0: F-U1a-1's fix (the U1a arbitration's option (a) — VX-450's second arm). RULE 20:
//  "a crash at any point leaves either the old state or the new one." A CHANGE or RESET passphrase act stopped mid-plan whose
//  next open TYPED THE PASSPHRASE THE ACT IS REPLACING (Castle under Always ask — or Standard with its quiet roads gone — where
//  the old passphrase is the one that opens the library) resumed with that passphrase derived under the plan's FRESH descriptor:
//  with no lock under that descriptor yet, the resume's plan-level check passed and the key-file step (synced, the vault step
//  too) re-locked the library under the OLD passphrase on a new salt — the settle said `.resumed`, and the passphrase chosen at
//  the press was never set (the U1a record's transient probe: `oldOpens=true newOpens=false`). Two more shapes of the same class
//  threw `passphraseDoesNotOpen` OUT of the settle — the act in flight for good (VX-450's wedge): a synced act whose vault write
//  had landed (the resume's vault check), and an act whose key-file write had landed before its plan record (the old passphrase
//  opening the library through this Mac's sealed mirror). Now a typed passphrase that opens only the lock the act replaces is
//  NOT the act's secret: the resume drops it, and the act rolls back before any write (VX-450's arm) — the old state, or, where
//  the new lock already landed, the second legal state (MAJOR-1's residue (1)). A resume typing the NEW passphrase still
//  finishes.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U1b — F-U1a-1: a resumed Change or Reset typing the passphrase it REPLACES rolls back, never finishing under it")
struct KeyDoorOldPassphraseResumeTests {
    typealias Door = KeyDoorResumeTests.Door

    struct Shape: CustomStringConvertible, Sendable {
        var door: Door
        var mode: ProtectionMode
        var synced: Bool
        var gate: GateStyle? = nil
        var description: String {
            "\(door) \(mode)\(gate.map { "/\($0)" } ?? "")\(synced ? " synced" : "")"
        }

        var asResumeShape: KeyDoorResumeTests.Shape {
            KeyDoorResumeTests.Shape(door: door, mode: mode, synced: synced, gate: gate)
        }
    }

    /// The probe's two postures (Standard — its quiet roads gone, so the lobby takes the typed passphrase; Castle under
    /// Always ask), unsynced and synced, both doors.
    static let shapes: [Shape] = [
        Shape(door: .change, mode: .standard, synced: false),
        Shape(door: .change, mode: .castle, synced: false, gate: .alwaysAsk),
        Shape(door: .change, mode: .standard, synced: true),
        Shape(door: .change, mode: .castle, synced: true, gate: .alwaysAsk),
        Shape(door: .resetPlain, mode: .standard, synced: false),
        Shape(door: .resetByWords, mode: .castle, synced: false, gate: .alwaysAsk),
    ]

    static func fixture(_ shape: Shape) throws -> EX { try EX(shape.mode, synced: shape.synced, gate: shape.gate) }

    /// Standard's quiet roads gone (a keychain reset): the next open takes the typed passphrase (rule 8's lobby).
    static func wipeQuietRoads(_ fixture: EX) {
        fixture.world.custody.removeAll()
    }

    /// The lobby's typed passphrase — what the open road hands the settle (`ProtectionOpenRoad.openTyped`: the passphrase
    /// alone, never a "new" one).
    static func typedAtTheLobby(_ passphrase: String) -> TypedSecrets { TypedSecrets(passphrase: passphrase) }

    /// THE PROBE, PINNED (both postures, both doors, unsynced and synced): a Change or Reset stopped right after its begin,
    /// the next open typing the OLD passphrase — the act rolls back (rule 20: the old state), the live key file and the
    /// account's vault exactly as they stood (nothing written under the old passphrase on a new salt), and the door then
    /// works. RED ON THE PRE-FIX TREE: `.resumed(...)`, the key file (synced, the vault too) re-locked under the OLD
    /// passphrase with a fresh descriptor.
    @Test(arguments: shapes)
    func aResumeTypingTheReplacedPassphraseRollsBackAndWritesNothing(_ shape: Shape) async throws {
        let fixture = try Self.fixture(shape)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let fileBefore = try #require(fixture.world.liveFormat3)
        let vaultBefore = fixture.account.flatMap { fixture.world.server.snapshot($0)?.vault }
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            try await KeyDoorResumeTests.press(
                shape.asResumeShape, fixture, executor, &library, current: fixture.passphrase, new: "chosen at the press")
        }
        #expect(fixture.world.writes.suffix(1) == [.plan], "\(shape): stopped right after its begin")
        if shape.mode == .standard { Self.wipeQuietRoads(fixture) }
        let outcome: SettleOutcome, settled: UnlockedLibrary, relaunched: ProtectionExecutor
        do {
            (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(Self.typedAtTheLobby(fixture.passphrase))
        } catch {
            Issue.record("\(shape): the settle threw \(error) — the act stays in flight")
            return
        }
        #expect(outcome == .rolledBack(shape.door.act), "\(shape): \(outcome) — never a finish under the replaced passphrase")
        expectSettled(fixture, settled, "\(shape) after the settle:")
        #expect(fixture.world.liveFormat3 == fileBefore, "\(shape): the live key file exactly as it stood — nothing re-locked")
        #expect(!KeyDoorResumeTests.fileOpens(fixture, "chosen at the press"))
        if let account = fixture.account {
            #expect(fixture.world.server.snapshot(account)?.vault == vaultBefore,
                    "\(shape): the account's vault exactly as it stood — nothing re-wrapped")
        }
        var again = settled
        try await KeyDoorResumeTests.press(
            shape.asResumeShape, fixture, relaunched, &again, current: fixture.passphrase, new: "set at last")
        #expect(KeyDoorResumeTests.fileOpens(fixture, "set at last"), "\(shape): the door works again")
        if shape.synced { #expect(KeyDoorResumeTests.vaultOpens(fixture, "set at last"), "\(shape): both locks together") }
    }

    /// THE SYNCED TWIN, after its one vault write LANDED (and before the key file): the next open types the OLD passphrase
    /// (it still opens the library's key file) — the act rolls back, the key file as it stood, the landed vault write
    /// standing as any landed CAS write does (MAJOR-1's accepted consequence: the account opens with the passphrase she
    /// chose at the press), and the door then changes both together. RED ON THE PRE-FIX TREE: the resume's vault check threw
    /// `passphraseDoesNotOpen` out of the settle — the act in flight for good.
    @Test(arguments: [GateStyle.alwaysAsk, .touchID])
    func aSyncedChangeWhoseVaultWriteLandedResumedWithTheOldPassphraseRollsBack(_ gate: GateStyle) async throws {
        let clean = try EX(.castle, synced: true, gate: gate)
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        _ = try await cleanExecutor.changePassphrase(&cleanLibrary, current: clean.passphrase, new: "landed")
        let vaultWrite = try #require(clean.world.writes.firstIndex { if case .vaultUpdate = $0 { true } else { false } })

        let fixture = try EX(.castle, synced: true, gate: gate)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let fileBefore = try #require(fixture.world.liveFormat3)
        fixture.world.crashAfterWrites = vaultWrite + 2  // the vault write and its plan record landed
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "landed")
        }
        // The lobby took the OLD passphrase (a Touch ID item that fails its press leaves the same typed road).
        fixture.world.custody.removeAll()
        let outcome: SettleOutcome, settled: UnlockedLibrary, relaunched: ProtectionExecutor
        do {
            (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(Self.typedAtTheLobby(fixture.passphrase))
        } catch {
            Issue.record("\(gate): the settle threw \(error) — the act stays in flight and the doors are wedged")
            return
        }
        #expect(outcome == .rolledBack(.changePassphrase), "\(gate): \(outcome)")
        expectSettled(fixture, settled, "\(gate) after the settle:")
        #expect(fixture.world.liveFormat3 == fileBefore, "the library's key file as it stood")
        #expect(KeyDoorResumeTests.vaultOpens(fixture, "landed") && !KeyDoorResumeTests.vaultOpens(fixture, fixture.passphrase),
                "the landed vault write stands")
        var again = settled
        _ = try await relaunched.changePassphrase(&again, current: "landed", new: "together again")
        #expect(KeyDoorResumeTests.fileOpens(fixture, "together again")
                    && KeyDoorResumeTests.vaultOpens(fixture, "together again"))
    }

    /// The key-file write LANDED and the act stopped before its plan recorded it: the live key file holds the NEW lock, this
    /// Mac's sealed mirror still the outgoing file — so the OLD passphrase opens the library through the mirror (the open
    /// road's lobby reads every key file this Mac holds), and that is what the open typed. The act rolls back (never a
    /// re-lock under the old passphrase); the live file keeps the lock she chose at the press (MAJOR-1's residue (1) — the
    /// second legal state, seen at the press), and the door works from there. RED ON THE PRE-FIX TREE: `passphraseDoesNotOpen`
    /// out of the settle (a key door's plan is past its commit point, so the plan-level check threw instead of rolling back)
    /// — the act in flight for good.
    @Test(arguments: [Door.change, .resetByWords])
    func aKeyDoorWhoseKeyFileLandedResumedWithTheOldPassphraseNeverWedges(_ door: Door) async throws {
        let shape = Shape(door: door, mode: .castle, synced: false, gate: .alwaysAsk)
        let clean = try Self.fixture(shape)
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        try await KeyDoorResumeTests.press(
            shape.asResumeShape, clean, cleanExecutor, &cleanLibrary, current: clean.passphrase, new: "chosen at the press")
        let keyFileWrite = try #require(clean.world.writes.firstIndex { if case .keyFile = $0 { true } else { false } })

        let fixture = try Self.fixture(shape)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = keyFileWrite + 1  // the key file landed; its plan record did not
        await #expect(throws: SimulatedCrash.self) {
            try await KeyDoorResumeTests.press(
                shape.asResumeShape, fixture, executor, &library, current: fixture.passphrase, new: "chosen at the press")
        }
        #expect(KeyDoorResumeTests.fileOpens(fixture, "chosen at the press"), "the new lock landed")
        // The lobby opened through this Mac's sealed mirror with the OLD passphrase (the executor world's own roads read
        // the live file only, so the open is made here by the key that mirror's lock gave).
        let mirror = try #require(fixture.memoryValue()?.keyFileMirror)
        let viaMirror = try mirror.open(passphrase: .passphrase(fixture.passphrase), floor: PF.floor)
        #expect(viaMirror == fixture.key, "the old passphrase opens the library through the mirror")
        fixture.world.relaunch()
        let relaunched = fixture.executor()
        var settled = try relaunched.unlock(with: viaMirror)
        let outcome: SettleOutcome
        do {
            outcome = try await relaunched.settle(&settled, typed: Self.typedAtTheLobby(fixture.passphrase))
        } catch {
            Issue.record("\(door): the settle threw \(error) — the act stays in flight and the doors are wedged")
            return
        }
        #expect(outcome == .rolledBack(door.act), "\(door): \(outcome)")
        expectSettled(fixture, settled, "\(door) after the settle:")
        let old = KeyDoorResumeTests.fileOpens(fixture, fixture.passphrase)
        let new = KeyDoorResumeTests.fileOpens(fixture, "chosen at the press")
        #expect(new && !old, "the live file keeps the lock chosen at the press (residue (1)) — never the old one re-salted")
        var again = settled
        try await KeyDoorResumeTests.press(
            shape.asResumeShape, fixture, relaunched, &again, current: "chosen at the press", new: "set at last")
        #expect(KeyDoorResumeTests.fileOpens(fixture, "set at last"))
    }

    /// The guard (green on both trees): the key-file write landed, and the open typed the NEW passphrase (it opens the live
    /// key file now) — the resume holds the act's own secret and FINISHES.
    @Test func aResumeTypingTheNewPassphraseAfterTheKeyFileLandedStillFinishes() async throws {
        let shape = Shape(door: .change, mode: .castle, synced: false, gate: .alwaysAsk)
        let clean = try Self.fixture(shape)
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        _ = try await cleanExecutor.changePassphrase(&cleanLibrary, current: clean.passphrase, new: "chosen at the press")
        let keyFileWrite = try #require(clean.world.writes.firstIndex { if case .keyFile = $0 { true } else { false } })

        let fixture = try Self.fixture(shape)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = keyFileWrite + 1
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "chosen at the press")
        }
        let (outcome, settled, _) = try await fixture.relaunchAndSettle(Self.typedAtTheLobby("chosen at the press"))
        guard case .resumed = outcome else {
            Issue.record("a resume holding the act's own new passphrase finishes — \(outcome)")
            return
        }
        expectSettled(fixture, settled, "after the settle:")
        #expect(KeyDoorResumeTests.fileOpens(fixture, "chosen at the press")
                    && !KeyDoorResumeTests.fileOpens(fixture, fixture.passphrase))
    }
}
