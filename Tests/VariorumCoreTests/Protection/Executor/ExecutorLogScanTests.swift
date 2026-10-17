//
//  ExecutorLogScanTests.swift
//  VariorumCoreTests — VX-305 U3: "a log scan: no log line or Diagnostics
//  entry the executor writes carries key material, a hardware marker or the
//  record's salt" (the phase plan §5; design §3.2). Every act family runs; the
//  world records every secret it minted or held, every marker and every salt;
//  the scan looks for each as raw bytes, base64 and hex in everything the
//  executor wrote to the log and to Diagnostics.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U3 — the log scan: no key material, marker or salt in any log line or Diagnostics entry")
struct ExecutorLogScanTests {
    @Test func nothingTheExecutorLogsCarriesASecretAMarkerOrTheSalt() async throws {
        var fixtures: [EX] = []
        // Use Castle (synced), then a planted plan settled; Use Standard
        // (synced); a follow; a leave; the key doors; repairs; the migration
        // of today's shape. (The landing left with rule 17 — VX-378 U1.)
        let a = try EX(.standard, synced: true, scheduledExport: true)
        let ae = a.executor()
        var al = try a.unlocked(ae)
        _ = try await ae.useCastle(&al, typed: a.typed, gate: .touchID)
        a.key = al.key
        a.world.plan = try ProtectionPlan(
            libraryID: a.libraryID, deviceID: a.deviceID, sequence: 99, act: .follow, steps: [], createdAt: PF.t0
        ).sealed(under: StoreKey.mint())
        _ = try await a.relaunchAndSettle()
        fixtures.append(a)

        let b = try EX(.castle, synced: true)
        let phone = try EX(.castle, synced: true, joining: b)
        let be = b.executor()
        var bl = try b.unlocked(be)
        _ = try await be.useStandard(&bl, typed: b.typed)
        let pe = phone.executor()
        var pl = try phone.unlocked(pe)
        _ = try await pe.follow(&pl, kind: .intoStandard, typed: TypedSecrets(words: phone.words))
        _ = try await pe.changePassphrase(&pl, current: phone.passphrase, new: "a later one")
        fixtures += [b, phone]

        let c = try EX(.castle, synced: true, gate: .alwaysAsk)
        let ce = c.executor()
        var cl = try c.unlocked(ce)
        _ = try await ce.leaveAccount(.stopSyncingHere, &cl)
        try ce.runRepairs([.refreshMemory, .makeTouchIDItem(fingerprint: PF.fp(cl.key))], on: &cl)
        fixtures.append(c)

        for fixture in fixtures {
            let world = fixture.world
            let written = Data((world.logLines + world.diagnosticEntries.map { "\($0)" }).joined(separator: "\n").utf8)
            var needles: [(String, Data)] = world.minted.enumerated().map { ("minted secret \($0.offset)", $0.element) }
            needles += world.custody.values.map { ("a custody item's key", $0.data) }
            needles += world.syncItems.values.flatMap { [("a master", $0.master), ("a sync key", $0.rowKey)] }
            needles += world.icloud.keys.values.map { ("an Apple key", PF.bytes($0.key)) }
            needles += [
                ("the passphrase", Data(fixture.passphrase.utf8)), ("the words", Data(fixture.words.joined(separator: " ").utf8)),
                ("the passphrase key", PF.bytes(fixture.p.key)), ("the words key", PF.bytes(fixture.w.key)),
            ]
            #expect(!world.logLines.isEmpty)
            for (name, needle) in needles where needle.count >= 8 {
                #expect(!SecretScan.carries(written, needle), "the executor's log carries \(name)")
            }
        }
    }
}
