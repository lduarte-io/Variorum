//
//  CopyDoorsQuietProbeTests.swift
//  VariorumTests — VX-306 ladder round 1, m2: THE COPY DOORS' AUTOMATIC QUIET PROBE NEVER PRESSES TOUCH ID. Each door
//  tries the copy's own quiet road the moment its sheet opens — Make this my library's confirm (`MakeMineModel.begin` →
//  `ProtectionCopyDoors.opensQuietly`) and Look inside (`LookInsideModel.begin` → `ProtectionCopyDoors.lookInside` with
//  nothing typed). Before the fix both reached the core's `openCopy`, whose quiet arm READ every `.touchid` item it
//  found — a read that, in production, IS the system Touch ID prompt nobody asked for. The automatic probe now reads
//  the silent item and the Apple wrap only (`CopyQuietRoads.withoutAPress`); Touch ID only at a deliberate press.
//  Planted leaves (no keychain — a read of a planted `.touchid` item is counted as the press it would be); this file
//  runs headless in the implementer's harness and calls only roads that exist on both sides of the fix, so it ran
//  RED on the pre-fix tree.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum QuietProbePlant {
    /// A library on `road` with one backup pair whose key — the library's — only a TOUCH ID item holds on this Mac now:
    /// no silent item, no Apple key (the copy's only quiet road is the one a press reads).
    static func backupOnlyTouchIDOpens(_ road: PlantedRoad) async throws -> (ProtectionRoadSession, CopyDoorRow) {
        let (session, _, row) = try await CopyDoorsPlant.libraryWithABackup(road)
        road.custody.items = [CustodyItemFact(fingerprint: session.library.fingerprint, itemClass: .touchid): session.key]
        road.apple.keys = [:]
        return (session, row)
    }

    static func touchIDReads(_ road: PlantedRoad) -> Int { road.custody.reads.filter { $0 == .touchid }.count }
}

@Suite("VX-306 ladder r1 m2 — the copy doors' automatic quiet probe never presses Touch ID (planted)", .serialized)
@MainActor
struct CopyDoorsQuietProbeTests {
    /// Make this my library's confirm opens: its quiet probe reads no Touch ID item — the copy's own field is asked.
    @Test func theConfirmsOpeningPressesNothing() async throws {
        let road = PlantedRoad()
        let (session, row) = try await QuietProbePlant.backupOnlyTouchIDOpens(road)
        let before = QuietProbePlant.touchIDReads(road)
        let model = MakeMineModel(
            row: row, passphraseSet: false,
            opensQuietly: { await Task.detached { ProtectionCopyDoors.opensQuietly(session, row.copy) }.value },
            act: { _, _ in .refused(.failed) }, finished: { _ in })
        await model.begin()
        #expect(QuietProbePlant.touchIDReads(road) == before, "the confirm's opening pressed Touch ID")
        #expect(model.needsCopySecret, "no quiet road that never prompts opens it — the copy's own secret is asked")
    }

    /// Look inside opens (its first try — nothing typed): no Touch ID item read; the copy's secret is asked.
    @Test func theLooksOpeningPressesNothing() async throws {
        let road = PlantedRoad()
        let (session, row) = try await QuietProbePlant.backupOnlyTouchIDOpens(road)
        let before = QuietProbePlant.touchIDReads(road)
        let opening = await Task.detached {
            ProtectionCopyDoors.lookInside(CopyDoorsContext(session), copy: row.copy, typed: .none)
        }.value
        #expect(QuietProbePlant.touchIDReads(road) == before, "the look's opening pressed Touch ID")
        guard case .refused(.copyDoesNotOpen) = opening else {
            if case .opened(let reader) = opening { reader.close() }
            Issue.record("with nothing typed and no quiet road that never prompts, the look asks the copy's secret")
            return
        }
    }
}
