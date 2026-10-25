//
//  PairCatchUpTests.swift
//  VariorumCoreTests — VX-529 unit 1, scope 2: THE PAIR CATCH-UP at the
//  executor (`notes/plans/fixes/vx-529-pair-catchup.md`, design §2; the
//  architect's ruling, Shape A): the follow's third kind RE-LOCKS this library's
//  key to the account's pair and never re-keys it — the passphrase lock under
//  the account's current passphrase on the vault's descriptor, the master's
//  twelve-words copy the vault's, a stale own words lock dropped; nothing
//  written to the server; the sync keys held per posture; a crash at any write
//  leaves the old state or the new one (rule 20).
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

/// The shapes a lagging device can be in: Standard, Castle with Touch ID, Castle Always ask.
let pairPostures: [(ProtectionMode, GateStyle?)] = [(.standard, nil), (.castle, .touchID), (.castle, .alwaysAsk)]

/// What a re-lock leaves: the library's key, epoch and record as they were; the key file carrying the account's pair
/// (`pairFollow` nil against the vault as it stands); the history, the master lock's bytes and the Apple wrap as they
/// were; nothing written to the server; what this Mac remembers mirroring the re-locked file; the act ended.
func expectCaughtUp(
    _ air: EX, _ library: UnlockedLibrary, before: (key: StoreKey, record: ProtectionRecord, file: KeyFile, revision: Int),
    sourceLocation: SourceLocation = #_sourceLocation
) throws {
    let account = try #require(air.account, sourceLocation: sourceLocation)
    let vault = try #require(air.world.server.snapshot(account), sourceLocation: sourceLocation)
    let live = try #require(air.world.liveFormat3, sourceLocation: sourceLocation)
    #expect(library.key == before.key && air.world.live?.fingerprint == PF.fp(before.key), "the library was re-keyed",
            sourceLocation: sourceLocation)
    let record = try #require(air.liveRecord, sourceLocation: sourceLocation)
    #expect(record.mode == before.record.mode && record.keyEpoch == before.record.keyEpoch
            && record.currentFingerprint == before.record.currentFingerprint && record.account == before.record.account
            && record.accountRowKeyID == before.record.accountRowKeyID, "the record's library facts moved",
            sourceLocation: sourceLocation)
    #expect(AssessRules.pairFollow(live, vault.reading) == nil, "the key file still owes the pair",
            sourceLocation: sourceLocation)
    #expect(live.fingerprint == before.file.fingerprint && live.epoch == before.file.epoch, sourceLocation: sourceLocation)
    #expect(live.history == before.file.history, "the history changed", sourceLocation: sourceLocation)
    #expect(live.master == before.file.master, "the master lock was re-made", sourceLocation: sourceLocation)
    #expect(live.apple == before.file.apple, "the Apple wrap changed", sourceLocation: sourceLocation)
    #expect(vault.revision == before.revision, "the catch-up wrote the vault", sourceLocation: sourceLocation)
    #expect(!air.world.writes.contains { if case .vaultUpdate = $0 { return true } else { return false } },
            sourceLocation: sourceLocation)
    #expect(!air.world.writes.contains { write in
        switch write {
        case .custody, .custodyDelete, .appleAdd, .appleDelete, .stage, .stagedRecord, .swap, .backup: return true
        default: return false
        }
    }, "a re-lock wrote a key's item, an Apple key, a staged file or a backup: \(air.world.writeLog())",
            sourceLocation: sourceLocation)
    #expect(library.memory?.keyFileMirror == live, "rule 1: the sealed copy didn't follow", sourceLocation: sourceLocation)
    expectSettled(air, library, sourceLocation: sourceLocation)
}

/// The account's sync keys held per posture after the act: Standard in its silent item; Castle in session memory (the
/// engine never reads the Touch ID item — VX-487 (a)).
func expectTheKeysHeld(_ air: EX, sourceLocation: SourceLocation = #_sourceLocation) throws {
    let account = try #require(air.account, sourceLocation: sourceLocation)
    let vault = try #require(air.world.server.snapshot(account), sourceLocation: sourceLocation)
    if air.mode == .standard {
        #expect(air.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)]?.rowKeyID == vault.rowKeyID,
                sourceLocation: sourceLocation)
    } else {
        #expect(air.world.session[account]?.rowKeyID == vault.rowKeyID, "the session holds no sync keys",
                sourceLocation: sourceLocation)
        #expect(air.world.syncItems[SyncKeysItemFact(accountID: account, itemClass: .silent)] == nil,
                "a silent sync-keys item in Castle", sourceLocation: sourceLocation)
    }
}

func pairBefore(_ air: EX) throws -> (key: StoreKey, record: ProtectionRecord, file: KeyFile, revision: Int) {
    let account = try #require(air.account)
    let vault = try #require(air.world.server.snapshot(account))
    return (air.key, try #require(air.liveRecord), try #require(air.world.liveFormat3), vault.revision)
}

/// The vault as it stands for `air`'s account.
func pairVault(_ air: EX) throws -> VaultSnapshot {
    let account = try #require(air.account)
    return try #require(air.world.server.snapshot(account))
}

@Suite("VX-529 scope 2 — the pair catch-up: a re-lock, never a re-key, nothing to the server")
struct PairCatchUpTests {
    @Test(arguments: pairPostures)
    func thePassphraseHalfReLocksUnderTheAccountsCurrentPassphrase(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(mode, gate: gate)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        let outcome = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        #expect(outcome.act == .follow && outcome.fingerprint == PF.fp(before.key))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(try live.open(passphrase: .passphrase(try #require(newPassphrase)), floor: PF.floor) == air.key)
        #expect((try? live.open(passphrase: .passphrase(air.passphrase), floor: PF.floor)) == nil,
                "rule 7's one pair: the old passphrase still opens the live library")
        #expect(live.words == before.file.words, "the words did not move — their lock stays")
        try expectTheKeysHeld(air)
    }

    /// R-529-2: the words-only change is quiet — nothing typed; the master from what this device already holds.
    @Test(arguments: pairPostures)
    func theWordsHalfIsQuietAndDropsTheStaleOwnWordsLock(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, _, newWords) = try await pairMovedElsewhere(mode, gate: gate, passphrase: false, words: true)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(&library, kind: .pairChanged(passphrase: false, words: true), typed: .none)
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(live.words == nil, "E8: the stale own words lock stays")
        #expect(try live.open(.words(try #require(newWords)), floor: PF.floor) == air.key)
        #expect((try? live.open(.words(air.words), floor: PF.floor)) == nil, "E8: the old words open the live library")
        #expect(live.passphrase == before.file.passphrase, "the passphrase did not move — its lock stays")
        try expectTheKeysHeld(air)
    }

    /// E5: both halves — one typed passphrase; the words ride the vault's copy.
    @Test(arguments: pairPostures)
    func bothHalvesTakeOnePassphrase(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, newPassphrase, newWords) = try await pairMovedElsewhere(mode, gate: gate, passphrase: true, words: true)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: true), typed: TypedSecrets(passphrase: newPassphrase))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        for secret in [ProtectionSecret.passphrase(try #require(newPassphrase)), .words(try #require(newWords))] {
            #expect(try live.open(secret, floor: PF.floor) == air.key)
        }
        for old in [ProtectionSecret.passphrase(air.passphrase), .words(air.words)] {
            #expect((try? live.open(old, floor: PF.floor)) == nil)
        }
    }

    /// E7: a backup made before the catch-up keeps its own key file and opens with the secrets of its day (rules 4–5).
    @Test func aBackupFromBeforeKeepsItsDaysSecrets() async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(.standard)
        let live = try #require(air.world.liveFormat3)
        air.world.backups.append(.init(fingerprint: PF.fp(air.key), keyFile: live, record: air.liveRecord, deviceID: "d"))
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        #expect(air.world.backups.count == 1 && air.world.backups[0].keyFile == live, "a backup was rewritten or added")
        #expect(try air.world.backups[0].keyFile.open(passphrase: .passphrase(air.passphrase), floor: PF.floor) == air.key)
    }

    /// The act owes nothing once it landed: a second press finds nothing to catch up.
    @Test func onceCaughtUpThereIsNothingToDo() async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        air.world.writes = []
        await #expect(throws: ExecutorRefusal.nothingToDo) {
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        }
        #expect(air.world.writes.isEmpty)
    }
}

@Suite("VX-529 scope 2 — the pair catch-up's entry checks: each refuses with nothing begun")
struct PairCatchUpEntryTests {
    static func refused(
        _ air: EX, _ refusal: ExecutorRefusal, halves: (Bool, Bool), typed: TypedSecrets,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async throws {
        let executor = air.executor()
        var library = try air.unlocked(executor)
        let before = air.world.liveFormat3
        air.world.writes = []
        await #expect(throws: refusal, sourceLocation: sourceLocation) {
            _ = try await executor.follow(&library, kind: .pairChanged(passphrase: halves.0, words: halves.1), typed: typed)
        }
        #expect(air.world.writes.isEmpty, "the refused door wrote \(air.world.writeLog())", sourceLocation: sourceLocation)
        #expect(air.world.liveFormat3 == before && library.section.actInFlight == nil && air.world.plan == nil,
                sourceLocation: sourceLocation)
    }

    /// Nothing moved (or the follow already landed): nothing to catch up.
    @Test func nothingMovedIsNothingToDo() async throws {
        let mac = try EX(.standard, synced: true)
        let air = try EX(.standard, synced: true, joining: mac)
        try await Self.refused(air, .nothingToDo, halves: (true, false), typed: TypedSecrets(passphrase: air.passphrase))
    }

    /// The passphrase half types the account's current passphrase — nothing typed refuses; the old one names the change
    /// elsewhere (P1's split); one that opens neither is the plain refusal.
    @Test func thePassphraseHalfAsksTheAccountsCurrentPassphrase() async throws {
        let (mac, air, _, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk)
        let vault = try pairVault(mac)
        try await Self.refused(air, .secretMissing, halves: (true, false), typed: .none)
        try await Self.refused(
            air, .passphraseChangedElsewhere(device: "Mac A", day: vault.updatedAt), halves: (true, false),
            typed: TypedSecrets(passphrase: air.passphrase))
        try await Self.refused(
            air, .passphraseDoesNotOpen, halves: (true, false), typed: TypedSecrets(passphrase: "not any passphrase of hers"))
    }

    /// E14 (S-1): a words-only catch-up with no master in hand — Castle Always ask, its session empty (unlocked by the
    /// OLD words) — refuses `secretMissing`; the account's passphrase typed there lands it.
    @Test func theWordsHalfWithNoMasterInHandAsksOneAccountSecret() async throws {
        let (_, air, _, _) = try await pairMovedElsewhere(.castle, gate: .alwaysAsk, passphrase: false, words: true)
        air.world.session = [:]
        try await Self.refused(air, .secretMissing, halves: (false, true), typed: .none)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: false, words: true), typed: TypedSecrets(passphrase: air.passphrase))
        let live = try #require(air.world.liveFormat3)
        #expect(AssessRules.pairFollow(live, try pairVault(air).reading) == nil)
        try expectTheKeysHeld(air)
    }

    /// E2 at the press: the account moved posture since the door — this follow no longer fits; the one now owed does.
    @Test func theAccountMovedPostureSinceTheDoor() async throws {
        let (mac, air, newPassphrase, _) = try await pairMovedElsewhere(.castle)
        let macExecutor = mac.executor()
        var macLibrary = try mac.unlocked(macExecutor)
        _ = try await macExecutor.useStandard(
            &macLibrary, typed: TypedSecrets(passphrase: try #require(newPassphrase), words: mac.words))
        try await Self.refused(air, .accountMoved, halves: (true, false), typed: TypedSecrets(passphrase: newPassphrase))
    }
}

@Suite("VX-529 scope 2 — the pair catch-up is crash safe: a crash after any write leaves the old state or the new (rule 20)")
struct PairCatchUpCrashTests {
    static func caughtUp(_ fixture: EX) -> Bool {
        guard let live = fixture.world.liveFormat3, let account = fixture.account,
              let vault = fixture.world.server.snapshot(account) else { return false }
        return AssessRules.pairFollow(live, vault.reading) == nil
    }

    @Test(arguments: pairPostures)
    func aCrashAfterEveryWriteFinishes(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(mode, gate: gate)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in library.key == k0 && Self.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !Self.caughtUp(fixture) },
            // The relaunch's lobby: the account's current passphrase, and the words (unchanged) for Always ask's road.
            typed: { fixture in TypedSecrets(passphrase: newPassphrase, words: fixture.words) })
    }

    @Test func withThePlanGoneItRollsBackOrFinishes() async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(.standard)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in library.key == k0 && Self.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !Self.caughtUp(fixture) },
            dropPlan: true, typed: { _ in TypedSecrets(passphrase: newPassphrase) })
    }
}

/// S-3 (the architect's ruling): a resume whose lobby took the OLD passphrase — the library opened by a quiet road, its
/// words, or (before the re-lock) that old lock — must never strand the open. A no-re-key act is always past its commit
/// point, so a passphrase that opens no lock under the plan's descriptor, or opens no vault under it, was thrown OUT OF
/// THE SETTLE (`PlanRunner.resume`) — the act left in flight, every door refused. Never a third state: the old one
/// (rolled back — the old passphrase is no secret of this act's) or the new one (landed).
@Suite("VX-529 S-3 — a resume whose lobby typed the old passphrase never strands the open")
struct PairCatchUpStrandedOpenTests {
    @Test(arguments: [(ProtectionMode.standard, GateStyle?.none), (.castle, .alwaysAsk)])
    func theOldPassphraseAtTheLobbyRollsBackOrFinishesNeverStrands(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(mode, gate: gate)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in library.key == k0 && PairCatchUpCrashTests.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !PairCatchUpCrashTests.caughtUp(fixture) },
            // The lobby: the OLD passphrase (and, for Always ask's road once the lock is re-made, the unchanged words).
            typed: { fixture in TypedSecrets(passphrase: fixture.passphrase, words: mode == .castle ? fixture.words : nil) },
            resumeMayRollBack: true)
    }
}

/// R-arch-3 (the architect's ruling): a pair plan interrupted mid-act and resumed by an OLDER build. A build before
/// VX-529 reads `follow = "pairChanged"` as `.keysReplaced` (`FollowProgram.kind`'s default arm) and resumes the plan by
/// its step names: a name it doesn't know throws `nothingToDo` out of its settle — the act left in flight at every open
/// until the next upgrade. THE STAND-IN: the plan's `follow` name cleared — exactly that reading — then this build
/// resumes it; this build's non-pair `FollowProgram` paths, `PlanRunner.resume` and `CommonSteps` are the older build's
/// byte for byte (`git diff main` adds only the pair arm, `perform`'s `material`, and `ActContext.typedPassphrase`), so
/// the resume runs the older build's steps. Every crash point must settle — the old state or the new, never in flight.
@Suite("VX-529 R-arch-3 — an older build resuming a pair plan runs only steps it runs harmlessly")
struct PairCatchUpOlderBuildTests {
    static func readAsAnOlderBuildWould(_ fixture: EX) throws {
        guard let sealed = fixture.world.plan, let id = fixture.liveRecord?.libraryID else { return }
        var plan = try sealed.open(purpose: .plan, libraryID: id, key: fixture.key)
        plan.parameters?.follow = nil
        fixture.world.plan = try plan.sealed(under: fixture.key)
    }

    @Test(arguments: pairPostures)
    func everyStepAnOlderBuildWouldResumeIsHarmless(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        func press(_ air: EX, _ newPassphrase: String?) async throws {
            let executor = air.executor()
            var library = try air.unlocked(executor)
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
        }
        let clean = try await pairMovedElsewhere(mode, gate: gate)
        try await press(clean.air, clean.newPassphrase)
        let count = clean.air.world.writes.count
        #expect(count > 3)
        for crashAt in 1...count {
            let made = try await pairMovedElsewhere(mode, gate: gate)
            let air = made.air, k0 = made.air.key
            air.world.crashAfterWrites = crashAt
            do {
                try await press(air, made.newPassphrase)
                Issue.record("write \(crashAt): no crash")
            } catch is SimulatedCrash {}
            let context = "crash after write \(crashAt) (\(clean.air.world.writes[crashAt - 1])):"
            try Self.readAsAnOlderBuildWould(air)
            let settled: UnlockedLibrary
            do {
                // The lobby: the account's current passphrase, and the (unchanged) words for Always ask's road.
                (_, settled, _) = try await air.relaunchAndSettle(TypedSecrets(passphrase: made.newPassphrase, words: air.words))
            } catch {
                Issue.record("\(context) an older build's settle threw \(error) — the act would stay in flight")
                continue
            }
            expectSettled(air, settled, context)
            #expect(settled.key == k0, "\(context) an older build re-keyed the library")
        }
    }

    /// THE STATED RESIDUAL (R-arch-3, in the run record): Castle Always ask, an older build, the act interrupted before its
    /// `pickUpKeys` finished, and a lobby that took only a passphrase — that build derives none (the plan carries no
    /// descriptor) and its session is empty, so ITS OWN `pickUpKeys` cannot reach the account's keys: `secretsRequired`
    /// out of its settle, the act in flight at that open (the library open, every door refusing). Data-safe — the key never
    /// changed, every road opens the library — and it heals at the first open whose lobby takes the twelve words (or the
    /// next upgrade): the same as that build's own follows resumed without a usable secret.
    @Test func theResidualCastleAlwaysAskWithOnlyAPassphraseAtTheLobbyHealsAtTheWords() async throws {
        let made = try await pairMovedElsewhere(.castle, gate: .alwaysAsk)
        let air = made.air, k0 = made.air.key
        air.world.crashAfterWrites = 3  // after the plan's first write: `pickUpKeys` not done
        do {
            let executor = air.executor()
            var library = try air.unlocked(executor)
            _ = try await executor.follow(
                &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: made.newPassphrase))
            Issue.record("no crash")
        } catch is SimulatedCrash {}
        try Self.readAsAnOlderBuildWould(air)
        await withKnownIssue("an older build's settle needs a usable secret it can derive — the words") {
            _ = try await air.relaunchAndSettle(TypedSecrets(passphrase: air.passphrase))
        }
        let (_, settled, _) = try await air.relaunchAndSettle(TypedSecrets(words: air.words))
        expectSettled(air, settled, "healed at the words")
        #expect(settled.key == k0)
    }
}


/// R-529-5 (her ratify): the catch-up accepts EITHER of the account's CURRENT secrets. Where the passphrase moved and the
/// account's current WORDS are typed — the forgot-the-new-passphrase road — the stale passphrase lock DROPS: the old
/// passphrase stops opening this library at once (the passphrase change arriving here); the words open it; the lock is
/// re-made the next time a passphrase is typed here (E6's window, P-VX529-4 — unit 2's consumers).
@Suite("VX-529 R-529-5 — the words arm: the account's current words catch the passphrase half up by dropping the stale lock")
struct PairCatchUpWordsArmTests {
    @Test(arguments: pairPostures)
    func theAccountsWordsDropTheStalePassphraseLock(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, newPassphrase, _) = try await pairMovedElsewhere(mode, gate: gate)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        // Only the passphrase moved: the words this library knows ARE the account's current words.
        _ = try await executor.follow(&library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(words: air.words))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(live.passphrase == nil, "the stale passphrase lock stays")
        #expect((try? live.open(passphrase: .passphrase(air.passphrase), floor: PF.floor)) == nil,
                "the old passphrase still opens the live library")
        #expect((try? live.open(passphrase: .passphrase(try #require(newPassphrase)), floor: PF.floor)) == nil,
                "E6: no passphrase lock of its own until one is typed here")
        #expect(try live.open(.words(air.words), floor: PF.floor) == air.key, "the account's words open it")
        #expect(live.words == before.file.words, "the words did not move — their lock stays")
        try expectTheKeysHeld(air)
    }

    /// E5 by the words: both halves moved; the account's NEW words typed — both stale locks drop, the copy is the vault's.
    @Test(arguments: pairPostures)
    func bothHalvesByTheAccountsNewWords(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        let (_, air, _, newWords) = try await pairMovedElsewhere(mode, gate: gate, passphrase: true, words: true)
        let before = try pairBefore(air)
        let executor = air.executor()
        var library = try air.unlocked(executor)
        _ = try await executor.follow(
            &library, kind: .pairChanged(passphrase: true, words: true), typed: TypedSecrets(words: try #require(newWords)))
        try expectCaughtUp(air, library, before: before)
        let live = try #require(air.world.liveFormat3)
        #expect(live.passphrase == nil && live.words == nil, "a stale lock stays")
        #expect(try live.open(.words(try #require(newWords)), floor: PF.floor) == air.key)
        for old in [ProtectionSecret.passphrase(air.passphrase), .words(air.words)] {
            #expect((try? live.open(old, floor: PF.floor)) == nil)
        }
    }

    /// Rule 20 for the words arm: a crash after every write, the relaunch's lobby typing the words — the act finishes.
    @Test(arguments: pairPostures)
    func aCrashAfterEveryWriteFinishesByTheWords(_ mode: ProtectionMode, _ gate: GateStyle?) async throws {
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(mode, gate: gate)
                k0 = made.air.key
                return made.air
            },
            act: { fixture, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(words: fixture.words))
            },
            finished: { fixture, library in library.key == k0 && PairCatchUpCrashTests.caughtUp(fixture) },
            neverHappened: { fixture, library in library.key == k0 && !PairCatchUpCrashTests.caughtUp(fixture) },
            typed: { fixture in TypedSecrets(words: fixture.words) })
    }

    /// A press by the PASSPHRASE resumed by a lobby that took only the words: the words arm is not the press's choice —
    /// the act rolls back (the old state) or, landed, finishes; it never strands the open, and never trades the press's
    /// re-made lock for a dropped one.
    @Test func aPassphrasePressResumedByTheWordsRollsBackOrFinishes() async throws {
        var newPassphrase: String?
        var k0: StoreKey!
        try await CrashHarness.everywhere(
            {
                let made = try await pairMovedElsewhere(.standard)
                newPassphrase = made.newPassphrase
                k0 = made.air.key
                return made.air
            },
            act: { _, executor, library in
                _ = try await executor.follow(
                    &library, kind: .pairChanged(passphrase: true, words: false), typed: TypedSecrets(passphrase: newPassphrase))
            },
            finished: { fixture, library in
                library.key == k0 && PairCatchUpCrashTests.caughtUp(fixture) && fixture.world.liveFormat3?.passphrase != nil
            },
            neverHappened: { fixture, library in library.key == k0 && !PairCatchUpCrashTests.caughtUp(fixture) },
            typed: { fixture in TypedSecrets(words: fixture.words) }, resumeMayRollBack: true)
    }
}
