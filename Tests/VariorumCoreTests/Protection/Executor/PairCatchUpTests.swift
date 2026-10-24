//
//  PairCatchUpTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 2: THE PAIR CATCH-UP at the
//  executor (`notes/plans/fixes/vx-529-pair-catchup.md`, design §2). Until the
//  act's program lands (the shape is the architect's ruling — the run record's
//  P6), the core's follow REFUSES the third kind before anything begins (F-2):
//  `FollowProgram.kind` reads a follow name it doesn't know as `keysReplaced`,
//  and a plan begun for it would re-key the library.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// Two devices of one account; the first re-makes the account's passphrase and/or words through its own key doors.
func pairMovedElsewhere(
    _ mode: ProtectionMode, gate: GateStyle? = nil, passphrase: Bool = true, words: Bool = false
) async throws -> (mac: EX, air: EX, newPassphrase: String?, newWords: [String]?) {
    let mac = try EX(mode, synced: true, gate: gate)
    let air = try EX(mode, synced: true, gate: gate, joining: mac)
    let executor = mac.executor()
    var library = try mac.unlocked(executor)
    var newWords: [String]?
    if words {
        let fresh = try PF.words()
        _ = try await executor.regenerateWords(&library, passphrase: mac.passphrase, newWords: fresh)
        newWords = fresh
    }
    var newPassphrase: String?
    if passphrase {
        let fresh = "a passphrase made on the other Mac"
        _ = try await executor.changePassphrase(&library, current: mac.passphrase, new: fresh)
        newPassphrase = fresh
    }
    air.world.writes = []
    return (mac, air, newPassphrase, newWords)
}

@Suite("VX-529 scope 2 — before the act's program lands, the third kind refuses with nothing begun (F-2)")
struct PairCatchUpGuardTests {
    @Test(arguments: [(true, false), (false, true), (true, true)])
    func theThirdKindRefusesBeforeAnythingBegins(_ halves: (Bool, Bool)) async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(.castle, passphrase: halves.0, words: halves.1)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        let before = air.world.liveFormat3
        await #expect(throws: ExecutorRefusal.nothingToDo) {
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: halves.0, words: halves.1),
                typed: TypedSecrets(passphrase: newPassphrase))
        }
        #expect(air.world.writes.isEmpty, "the refused follow wrote \(air.world.writeLog())")
        #expect(library.key == air.key && air.world.liveFormat3 == before, "the library was re-keyed or re-locked")
        #expect(library.section.actInFlight == nil && air.world.plan == nil)
    }
}
