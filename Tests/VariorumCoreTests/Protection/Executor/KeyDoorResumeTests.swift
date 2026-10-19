//
//  KeyDoorResumeTests.swift
//  VariorumCoreTests — VX-309 U1a piece 4: VX-450, the stuck-act class's remainder (F-U3-2's option (a), MAJOR-1's fix
//  extended — `notes/plans/vx-308-accounts-key-doors.md` §6 ROUND-1 FIX LEG). RULE 20: "a crash at any point leaves either
//  the old state or the new one. The next open finishes the act or rolls it back from what is on disk." A CHANGE or RESET
//  passphrase act stopped mid-plan could do neither: its resume holds no NEW passphrase (a plan never holds a secret; a
//  quiet open types nothing, a lobby typing the words types none), so the resume threw `secretsRequired` out of the settle
//  at the vault or key-file step and the act stayed in flight FOREVER — every later act refused `actInFlight`, the key
//  doors included. Now a RESUMED Change or Reset that cannot finish ROLLS BACK before writing anything (the act cleared,
//  the plan gone, the library as it stood), and the doors work at once. A resume HOLDING the new passphrase still finishes.
//  MAJOR-1's residue (1) stands for these acts as for the words act (a stop after the key-file write and before its plan
//  record rolls back with the live file keeping the NEW passphrase lock — the one she typed): pinned here as the second of
//  the two legal states, never a third.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U1a — VX-450: a Change or Reset passphrase act stopped mid-plan rolls back at the next open, never wedging")
struct KeyDoorResumeTests {
    enum Door: String, CustomStringConvertible, Sendable {
        case change, resetPlain, resetByWords, resetByTouchID
        var description: String { rawValue }
        var act: ProtectionAct { self == .change ? .changePassphrase : .resetPassphrase }
    }

    struct Shape: CustomStringConvertible, Sendable {
        var door: Door
        var mode: ProtectionMode
        var synced: Bool
        var gate: GateStyle? = nil
        /// The relaunch types the WORDS (Castle under Always ask — no quiet road); else nothing (the quiet road).
        var typesWords = false
        var description: String {
            "\(door) \(mode)\(gate.map { "/\($0)" } ?? "")\(synced ? " synced" : "")\(typesWords ? " (words typed)" : "")"
        }
    }

    static let shapes: [Shape] = [
        Shape(door: .change, mode: .standard, synced: false),
        Shape(door: .change, mode: .standard, synced: true),
        Shape(door: .change, mode: .castle, synced: false, gate: .touchID),
        Shape(door: .change, mode: .castle, synced: true, gate: .touchID),
        Shape(door: .change, mode: .castle, synced: false, gate: .alwaysAsk, typesWords: true),
        Shape(door: .change, mode: .castle, synced: true, gate: .alwaysAsk, typesWords: true),
        Shape(door: .resetPlain, mode: .standard, synced: false),
        Shape(door: .resetPlain, mode: .standard, synced: true),
        Shape(door: .resetByWords, mode: .castle, synced: true, gate: .touchID),
        Shape(door: .resetByWords, mode: .castle, synced: false, gate: .alwaysAsk, typesWords: true),
        Shape(door: .resetByTouchID, mode: .castle, synced: false, gate: .touchID),
    ]

    static func fixture(_ shape: Shape) throws -> EX { try EX(shape.mode, synced: shape.synced, gate: shape.gate) }

    static func typedAtRelaunch(_ shape: Shape, _ fixture: EX) -> TypedSecrets {
        shape.typesWords ? TypedSecrets(words: fixture.words) : .none
    }

    /// Does `passphrase` open the live key file?
    static func fileOpens(_ fixture: EX, _ passphrase: String) -> Bool {
        guard let live = fixture.world.liveFormat3 else { return false }
        return (try? live.open(passphrase: .passphrase(passphrase), floor: PF.floor)) != nil
    }

    /// Does `passphrase` open the account's vault (its master)?
    static func vaultOpens(_ fixture: EX, _ passphrase: String) -> Bool {
        guard let account = fixture.account, let vault = fixture.world.server.snapshot(account)?.vault,
              let key = try? PassphraseKey.derive(passphrase, kdf: vault.kdf) else { return false }
        return VaultModel.master(of: vault, passphrase: key, words: nil) != nil
    }

    /// The door's press. Change verifies `current` (against the vault when synced, else the live key file).
    static func press(
        _ shape: Shape, _ fixture: EX, _ executor: ProtectionExecutor, _ library: inout UnlockedLibrary,
        current: String, new: String
    ) async throws {
        switch shape.door {
        case .change: _ = try await executor.changePassphrase(&library, current: current, new: new)
        case .resetPlain: _ = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: new)
        case .resetByWords: _ = try await executor.resetPassphrase(&library, authorization: .words(fixture.words), new: new)
        case .resetByTouchID: _ = try await executor.resetPassphrase(&library, authorization: .touchID, new: new)
        }
    }

    /// The settled world's first four checks (`expectSettled`'s, the key file present — these acts never remove it).
    static func expectNothingHalfDone(_ fixture: EX, _ library: UnlockedLibrary, _ context: String,
                                      sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(library.section.actInFlight == nil, "\(context) an act is still in flight", sourceLocation: sourceLocation)
        #expect(fixture.world.plan == nil, "\(context) a plan is left on disk", sourceLocation: sourceLocation)
        #expect(fixture.world.staged == nil, "\(context) a staged file is left", sourceLocation: sourceLocation)
        #expect(!fixture.world.paused, "\(context) copies are still paused", sourceLocation: sourceLocation)
    }

    /// WHEREVER IT STOPS (a crash after EVERY write of the door's clean run), in every shape: the next open — quiet, or
    /// typing the words where no quiet road is — settles WITHOUT THROWING, leaves nothing half-done, the live key file opens
    /// with exactly one of the two passphrases (the old state, or the new one — never a third), and the door then LANDS: a
    /// key file (and, synced, a vault) opened by the passphrase it set. RED ON OLD at every stop between the begin and the
    /// key-file step's plan record (the settle threw `secretsRequired` — the act in flight for good).
    @Test(arguments: shapes)
    func aStoppedKeyDoorNeverWedgesWhereverItStopped(_ shape: Shape) async throws {
        let fresh = "a new passphrase", again = "chosen again after the crash"
        let clean = try Self.fixture(shape)
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        try await Self.press(shape, clean, cleanExecutor, &cleanLibrary, current: clean.passphrase, new: fresh)
        #expect(Self.fileOpens(clean, fresh) && !Self.fileOpens(clean, clean.passphrase), "\(shape): the clean run lands")
        let count = clean.world.writes.count
        #expect(count > 5, "\(shape)")
        for crashAt in 1...count {
            let context = "\(shape), crash after write \(crashAt) (\(clean.world.writes[crashAt - 1])):"
            let fixture = try Self.fixture(shape)
            let executor = fixture.executor()
            var library = try fixture.unlocked(executor)
            fixture.world.crashAfterWrites = crashAt
            do {
                try await Self.press(shape, fixture, executor, &library, current: fixture.passphrase, new: fresh)
                Issue.record("\(context) no crash")
            } catch is SimulatedCrash {}
            let settled: UnlockedLibrary, relaunched: ProtectionExecutor
            do {
                (_, settled, relaunched) = try await fixture.relaunchAndSettle(Self.typedAtRelaunch(shape, fixture))
            } catch {
                Issue.record("\(context) the settle threw \(error) — the act stays in flight and the doors are wedged. LOG: \(fixture.world.logLines.suffix(6))")
                continue
            }
            Self.expectNothingHalfDone(fixture, settled, context)
            let old = Self.fileOpens(fixture, fixture.passphrase), new = Self.fileOpens(fixture, fresh)
            #expect(old != new, "\(context) the live key file opens with \(old && new ? "both" : "neither") — a third state")
            // The door again, with the passphrase that is current now (the vault's when synced, else the file's).
            let current = shape.synced
                ? (Self.vaultOpens(fixture, fresh) ? fresh : fixture.passphrase)
                : (new ? fresh : fixture.passphrase)
            var reopened = settled
            do {
                try await Self.press(shape, fixture, relaunched, &reopened, current: current, new: again)
            } catch {
                Issue.record("\(context) the door refused \(error)")
                continue
            }
            #expect(Self.fileOpens(fixture, again), "\(context) the door's key file opens with the passphrase it set")
            if shape.synced { #expect(Self.vaultOpens(fixture, again), "\(context) and the account's lock with it (rule 7)") }
            #expect(reopened.section.actInFlight == nil && fixture.world.plan == nil, "\(context) the door's act ended")
        }
    }

    /// THE PLAINEST CASE, said: Standard, unsynced — a Change stopped right after its begin rolls back at the next quiet
    /// open (rule 20: "and says which"), the old passphrase still opens, and Change works at once. RED ON OLD: `secretsRequired`.
    @Test func aChangeStoppedRightAfterItsBeginRollsBackAndTheDoorWorksAgain() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        let before = try #require(fixture.world.liveFormat3)
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "never set")
        }
        #expect(fixture.world.writes.suffix(1) == [.plan], "stopped right after its begin")
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.changePassphrase))
        expectSettled(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == before, "the live key file as it stood")
        var again = settled
        _ = try await relaunched.changePassphrase(&again, current: fixture.passphrase, new: "set at last")
        #expect(Self.fileOpens(fixture, "set at last"))
    }

    /// The same for Reset (Standard's plain confirm). RED ON OLD: `secretsRequired`.
    @Test func aResetStoppedRightAfterItsBeginRollsBackAndTheDoorWorksAgain() async throws {
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.resetPassphrase(&library, authorization: .plainConfirm, new: "never set")
        }
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.resetPassphrase))
        expectSettled(fixture, settled, "after the settle:")
        #expect(Self.fileOpens(fixture, fixture.passphrase))
        var again = settled
        _ = try await relaunched.resetPassphrase(&again, authorization: .plainConfirm, new: "set at last")
        #expect(Self.fileOpens(fixture, "set at last"))
    }

    /// THE ACCEPTED CONSEQUENCE (MAJOR-1's, carried): a SYNCED Change stopped after its one vault write LANDED and before
    /// the key file — the next quiet open rolls the act back (the key file keeps the old passphrase), while the landed CAS
    /// write stands (the account opens with the new one — the passphrase she typed); the door then changes both together
    /// (rule 7), verified against the vault as it stands. RED ON OLD: `secretsRequired` out of the settle.
    @Test func aSyncedChangeStoppedAfterItsVaultWriteRollsBackAndTheLandedWriteStands() async throws {
        let clean = try EX(.standard, synced: true)
        let cleanExecutor = clean.executor()
        var cleanLibrary = try clean.unlocked(cleanExecutor)
        _ = try await cleanExecutor.changePassphrase(&cleanLibrary, current: clean.passphrase, new: "landed")
        let vaultWrite = try #require(clean.world.writes.firstIndex { if case .vaultUpdate = $0 { true } else { false } })
        #expect(clean.world.writes[vaultWrite + 1] == .plan)

        let fixture = try EX(.standard, synced: true)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = vaultWrite + 2  // the vault write and its plan record landed
        await #expect(throws: SimulatedCrash.self) {
            _ = try await executor.changePassphrase(&library, current: fixture.passphrase, new: "landed")
        }
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(TypedSecrets.none)
        #expect(outcome == .rolledBack(.changePassphrase))
        expectSettled(fixture, settled, "after the settle:")
        #expect(Self.fileOpens(fixture, fixture.passphrase) && !Self.fileOpens(fixture, "landed"), "the library's lock: old")
        #expect(Self.vaultOpens(fixture, "landed") && !Self.vaultOpens(fixture, fixture.passphrase),
                "the landed vault write stands, as any landed CAS write does")
        var again = settled
        _ = try await relaunched.changePassphrase(&again, current: "landed", new: "together again")
        #expect(Self.fileOpens(fixture, "together again") && Self.vaultOpens(fixture, "together again"))
    }

    /// A resume HOLDING the new passphrase but finding NO live key file of the key (the file gone since the stop — rule 27's
    /// state reached mid-act) rolls back too, before any write — never `noLiveKeyFile` out of the settle — and the next act
    /// is judged on the library as it stands (Change: nothing to verify the passphrase against; Reset: no key file to
    /// re-lock — never `actInFlight`). (Red with the
    /// shared key-file arm narrowed to the words act — the pre-fix behaviour for these doors.)
    @Test(arguments: [Door.change, .resetPlain])
    func aResumeHoldingTheNewPassphraseButNoKeyFileRollsBackToo(_ door: Door) async throws {
        let shape = Shape(door: door, mode: .standard, synced: false)
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            try await Self.press(shape, fixture, executor, &library, current: fixture.passphrase, new: "typed at the lobby")
        }
        fixture.world.liveKeyFile = nil
        let (outcome, settled, relaunched) = try await fixture.relaunchAndSettle(
            TypedSecrets(passphrase: fixture.passphrase, newPassphrase: "typed at the lobby"))
        #expect(outcome == .rolledBack(door.act))
        Self.expectNothingHalfDone(fixture, settled, "after the settle:")
        #expect(fixture.world.liveFormat3 == nil, "nothing written")
        var again = settled
        do {
            try await Self.press(shape, fixture, relaunched, &again, current: fixture.passphrase, new: "x")
            Issue.record("a key door with no key file to re-lock should refuse")
        } catch let refusal as ExecutorRefusal {
            #expect(refusal != .actInFlight(door.act), "the door is judged on the library, never wedged — \(refusal)")
        }
    }

    /// A resume HOLDING the act's new passphrase (typed at a lobby — the scenario world's model of her, and the crash
    /// harness's) still FINISHES, exactly as before: the rollback is only for a resume that cannot finish. (Green on both
    /// trees — the arm's guard.)
    @Test(arguments: [Door.change, .resetPlain])
    func aResumeHoldingTheNewPassphraseStillFinishes(_ door: Door) async throws {
        let shape = Shape(door: door, mode: .standard, synced: false)
        let fixture = try EX(.standard)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.crashAfterWrites = 3
        await #expect(throws: SimulatedCrash.self) {
            try await Self.press(shape, fixture, executor, &library, current: fixture.passphrase, new: "typed at the lobby")
        }
        let (outcome, settled, _) = try await fixture.relaunchAndSettle(
            TypedSecrets(passphrase: fixture.passphrase, newPassphrase: "typed at the lobby"))
        guard case .resumed = outcome else {
            Issue.record("the resume holding its new passphrase should finish — \(outcome)")
            return
        }
        expectSettled(fixture, settled, "after the settle:")
        #expect(Self.fileOpens(fixture, "typed at the lobby"))
    }
}
