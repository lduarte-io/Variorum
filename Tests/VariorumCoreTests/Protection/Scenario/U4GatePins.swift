//
//  U4GatePins.swift
//  VariorumCoreTests — VX-378 U4: the GATE's finds on the final tree `4a4af3164`
//  (the soak's seeds 2 and 3, Debug), each replayed as its minimal sequence from
//  its world seed, so the pin is RED on the pre-fix tree by the generator's own
//  verdict and green after. The fixes are the orchestrator's (the Opus pool was
//  out on its session limit — the resiliency protocol's budget-death road), each
//  traced in the plan's §10 and §8.
//

import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — the gate's finds, replayed (red on the pre-fix tree)")
struct U4GatePins {
    /// GATE SEED 2, sequence 585 (promise 6 — rule 20): a crashed Make this my
    /// library had written the NEW library's key file beside the OLD library
    /// file and staged the copy (no swap); a keychain wipe took both memory
    /// items; the next open reached the library through the backup's key file
    /// with the pair of ITS day (rule 21's offer road) — not the press's pair,
    /// so the resume's new-key check refused with `passphraseDoesNotOpen` and the
    /// act stayed in flight with copies paused. Now: a pre-commit resume whose
    /// secrets are not the press's ROLLS BACK from what is on disk (no new key
    /// needed), and says so.
    @Test func aCrashedMakeMineThenAWipedKeychainRollsBackAtTheNextOpen() async throws {
        let world = SWorld(seed: 2 &* 1_000_003 &+ 585)
        try await StartingState.all[2].build(world)
        for action in [Action.crash(.useCastle("macA", .alwaysAsk, newWords: false), afterWrites: 16),
                       .crash(.regenerateWords("macA"), afterWrites: 3),
                       .changePassphrase("macA"),
                       .crash(.makeMine("macA", pick: 2, typing: .itsDay), afterWrites: 11),
                       .wipeKeychain("macA"),
                       .plaintextExport("macA")] {
            await world.step(action)
        }
        #expect(world.macA.library?.section.actInFlight == nil, "the act stayed in flight")
        #expect(!world.macA.paused, "copies stayed paused")
        expectPromisesKept(world)
    }

    /// GATE SEED 3, sequence 310 (promise 1 — rules 9, 11): a Time Machine
    /// rollback put an older library file back but not the keychain, so a SILENT
    /// item for a key the rolled-back stretch minted survived; the live key
    /// file's history no longer knew that key, so Castle entry's sweep skipped
    /// it — yet that key's backup in the shared iCloud folder carries THIS
    /// library's earlier keys in its own history, and a login-password holder
    /// reached a Castle-era backup through it. Now: entering Castle also sweeps
    /// the keys named by every catalogued key file OF THIS LIBRARY (its own
    /// libraryID vouches) — their silent items and their Apple keys (rule 11).
    @Test func aRolledBackStretchsSilentItemAndAppleKeyGoAtCastleEntry() async throws {
        let world = SWorld(seed: 3 &* 1_000_003 &+ 310)
        let shared = StartingState.all.firstIndex { $0.name.contains("iCloud Drive") }!
        try await StartingState.all[shared].build(world)
        for action in [Action.crash(.timeMachineSnapshot("macB"), afterWrites: 12),
                       .useStandard("macB"),
                       .timeMachineRollback("macB"),
                       .useStandard("macB"),
                       .crash(.useCastle("macB", .touchID, newWords: false), afterWrites: 13),
                       .changePassphrase("macB")] {
            await world.step(action)
        }
        expectPromisesKept(world)
    }
}
