//
//  Generator.swift
//  VariorumCoreTests — VX-305 U4: THE RUNNER and THE GENERATOR (the phase plan
//  §6: "seeded and reproducible: a failing seed prints its minimal sequence.
//  It runs as part of `swift test`, with a count small enough for the
//  everyday loop, plus a `PROTECTION_SOAK=1` environment switch for the
//  go/no-go run").
//
//  The runner applies a step and checks the promises after it: every step's
//  (1, 2, 4, 5, 6, 8, 11, 13 and the vault's §3.9 invariant), the settle's
//  (2's retired-key clause, 3, 7), the tampering steps' (10 — the device is
//  relaunched as part of the step, the next open being when a planted or
//  replayed thing would act), the move's (12), and — every few steps and at
//  every settle — the words (9).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

extension SWorld {
    /// Apply one step and check the promises after it. Violations accumulate
    /// in `violations`.
    @discardableResult
    func step(_ action: Action, words: Bool = false) async -> StepResult {
        let before = Dictionary(uniqueKeysWithValues: devices.map { ($0.name, posture($0)) })
        let crashedBefore = crashed
        var moveBefore: (SDevice, Set<String>)?
        if case .moveOffSharedKey(let name) = action {
            let d = device(name)
            if !d.isOpen { _ = try? await launch(d) }
            moveBefore = (d, openableCopies(d))
        }
        var result = await apply(action)
        if case .crash = action, result == .crashed, let name = action.device { crashed.insert(name) }
        var found: [Violation] = []
        if case .tamper(let name, let tamper) = action {
            // The next open is when a planted or replayed thing would act.
            let d = device(name)
            if d.build == .new {
                do { try await launch(d) } catch { stepLog.append("  (the tampered library didn't open: \(error))") }
                crashed.remove(name)
                found += sealed(d, before: before[name]!, tamper: tamper)
            }
        }
        if case .launch(let name) = action, result == .done { crashed.remove(name) }
        if action == .settle { crashed.removeAll() }
        found += checkPromises(settled: action == .settle)
        found += noSilentChange(action, before: before, crashedBefore: crashedBefore)
        if let (d, openable) = moveBefore {
            for id in openable.subtracting(openableCopies(d)).sorted() {
                found.append(Violation(promise: 12, device: d.name, detail: "the move stranded \(id)"))
            }
        }
        if words || action == .settle {
            for device in devices where device.build == .new { found += honestWords(device) }
        }
        if !found.isEmpty {
            stepLog.append(contentsOf: found.map { "  ✗ \($0)" })
            violations.append(contentsOf: found.map { ($0, stepLog.count) })
            if result == .done { result = .done }
        }
        return result
    }

    /// Run a sequence; returns every violation, each with the step it surfaced at.
    @discardableResult
    func run(_ actions: [Action], words: Bool = true) async -> [Violation] {
        for action in actions { await step(action, words: words) }
        return violations.map(\.0)
    }

    var log: String { stepLog.joined(separator: "\n") }
}

// MARK: - The starting states (the phase plan §6's list, from the old formats)

/// A starting state: a name and how the world is built.
struct StartingState: CustomStringConvertible, Sendable {
    var name: String
    var build: @Sendable (SWorld) throws -> Void
    var description: String { name }

    /// Every shape today's builds leave (the plan's §6 list).
    static let all: [StartingState] = [
        StartingState(name: "exposed") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, passphrase: false, words: false, appleLanded: false))
        },
        StartingState(name: "Standard-waiting") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, appleLanded: false))
        },
        StartingState(name: "VX-202's victim (Castle, the raw key in the silent item)") { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .alwaysAsk, silentInCastle: true))
        },
        StartingState(name: "VX-209's victim (a Castle library dropped to Standard by a copy)") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, olderKeys: [.castle]))
        },
        StartingState(name: "Castle with no Touch ID") { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .alwaysAsk))
        },
        StartingState(name: "Castle with Touch ID, the old shared key with pre-Castle copies") { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, olderKeys: [.standard]))
            w.ensureOldShared(SWorld.appleA)
        },
        StartingState(name: "signed out with keys (Standard, synced)") { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macA, TodaySpec(mode: .standard, account: account))
            w.macA.session = .signedOut
        },
        StartingState(name: "a deleted account") { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macA, TodaySpec(mode: .standard, account: account))
            w.server.delete(accountID: account)
        },
        StartingState(name: "a stuck VX-235 marker") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, marker: LegacyRotationMarker(
                step: .rekeyLibrary, entersCastle: true, oldKeyFingerprint: nil, newKeyFingerprint: nil,
                newCorpusKeyID: nil, startedAt: "2026-09-01T00:00:00Z", follow: nil)))
        },
        StartingState(name: "older libraries of other libraries, and backups only") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.todayOtherLibrary(on: w.macA, mode: .standard, passphrase: false, words: false)
            try w.todayOtherLibrary(on: w.macA, mode: .castle, passphrase: true, words: true)
            try w.todayOtherLibrary(on: w.macA, mode: .standard, passphrase: true, words: false, asOlderLibrary: false)
        },
        StartingState(name: "a synced Castle account on two Macs and the phone") { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .castle)
            for d in w.devices { try w.today(on: d, TodaySpec(mode: .castle, gate: d.isPhone ? .touchID : .alwaysAsk, account: account)) }
        },
        StartingState(name: "a synced Standard account, a device that joined without a secret") { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macA, TodaySpec(mode: .standard, account: account))
            try w.today(on: w.phone, TodaySpec(mode: .standard, account: account, joinedWithoutSecret: true))
        },
        StartingState(name: "13p escrow items") { w in
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, escrow: true))
        },
        StartingState(name: "one library on two Macs from a hand-off before this change") { w in
            let lib = try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .standard, sameAs: lib))
        },
        StartingState(name: "two Macs sharing an iCloud Drive backup folder") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard))
            try w.today(on: w.macB, TodaySpec(mode: .castle, gate: .touchID))
            w.macA.farFolderAccount = SWorld.appleA
            w.macB.farFolderAccount = SWorld.appleA
        },
        StartingState(name: "Standard libraries with no passphrase and no words, on two Macs") { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, passphrase: false, words: false))
            try w.today(on: w.macB, TodaySpec(mode: .standard, passphrase: false, words: false))
        },
        StartingState(name: "a phone on an older build beside a synced Castle Mac") { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .castle)
            try w.today(on: w.macA, TodaySpec(mode: .castle, gate: .touchID, account: account))
            try w.today(on: w.phone, TodaySpec(mode: .castle, gate: .touchID, account: account))
            w.phone.build = .older
        },
    ]
}

// MARK: - The generator

struct Generated {
    var seed: UInt64
    var start: Int
    var actions: [Action]
}

struct ScenarioGenerator {
    var rng: SeededRandom

    init(seed: UInt64) { rng = SeededRandom(seed: seed &* 2_654_435_761) }

    /// One step, chosen among what this world makes sensible (a refusal is a
    /// legal step too — it must change nothing).
    mutating func next(_ world: SWorld) -> Action {
        let names = world.devices.map(\.name)
        let name = rng.pick(names)!
        let d = world.device(name)
        let other = rng.pick(names.filter { $0 != name })!
        if d.build == .older {
            switch rng.int(0..<6) {
            case 0: return .olderBuild(name, .follow, typing: rng.chance(50) ? .passphrase : .words)
            case 1: return .olderBuild(name, .leaveCastle, typing: nil)
            case 2: return .olderBuild(name, .relink, typing: nil)
            case 3: return .updateToNewBuild(name)
            default: return .olderBuild(name, .backup, typing: nil)
            }
        }
        if d.slot == nil { return rng.chance(70) ? .createLibrary(name, secrets: rng.chance(70)) : .settle }
        let account = world.server.accounts.keys.sorted().first ?? "00000000-0000-4000-8000-000000000000"
        let weights = [6, 3, 5, 5, 3, 4, 2, 3, 2, 2, 2, 2, 1, 3, 2, 2, 6, 3, 1, 2, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 1, 1, 2, 2, 1, 2,
                       3, 1, 1, 1, 1, 1, 1, 2, 1, 3]
        var roll = rng.int(0..<weights.reduce(0, +))
        var kind = 0
        while roll >= weights[kind] { roll -= weights[kind]; kind += 1 }
        let action = make(kind, name, other, account)
        if kind != 45, rng.chance(12) { return .crash(action, afterWrites: rng.int(1..<24)) }
        return action
    }

    mutating func make(_ kind: Int, _ name: String, _ other: String, _ account: String) -> Action {
        switch kind {
        case 0: return .launch(name)
        case 1: return .lock(name)
        case 2: return .useCastle(name, rng.chance(60) ? .touchID : .alwaysAsk, newWords: rng.chance(20))
        case 3: return .useStandard(name)
        case 4: return .replaceAllKeys(name, newWords: rng.chance(30))
        case 5: return .follow(name, rng.chance(60) ? .passphrase : (rng.chance(80) ? .words : .oldPassphrase))
        case 6: return .finishLeave(name, mint: rng.chance(30))
        case 7: return .turnOnSync(name)
        case 8: return .signIn(name, account: account)
        case 9: return .signOut(name)
        case 10: return .thisMacOnly(name, rng.pick([nil, ProtectionMode.castle, .standard])!)
        case 11: return .stopSyncingHere(name, forgotPassphrase: rng.chance(30))
        case 12: return .move(name)
        case 13: return .changePassphrase(name)
        case 14: return .resetPassphrase(name, rng.pick(ResetVia.allCases)!)
        case 15: return .regenerateWords(name)
        case 16: return .backup(name)
        case 17: return .restoreBackup(name, newest: rng.int(0..<4))
        case 18: return .openOlderLibrary(name)
        case 19: return .sendLibrary(from: name, to: other)
        case 20: return .land(name, rng.pick(LandTyping.allCases)!)
        case 21: return .plaintextExport(name)
        case 22: return .offerDelete(name)
        case 23: return .setGate(name, rng.chance(50) ? .touchID : .alwaysAsk)
        case 24: return .answerRearm(name, yes: rng.chance(50))
        case 25: return .setIdleLock(name, minutes: rng.pick([nil, 5, 10, 30])!)
        case 26: return .setScheduledExport(name, rng.chance(50))
        case 27: return .answerCorner45(name, rng.chance(50) ? .castle : .standard)
        case 28: return .relinkLibraryArm(name)
        case 29: return .relinkAccount(name)
        case 30: return .retireOldSharedKey(name)
        case 31: return .moveOffSharedKey(name)
        case 32: return rng.chance(50) ? .addFinger(name) : .removeFinger(name)
        case 33: return rng.chance(50) ? .closeLid(name) : .openLid(name)
        case 34: return .macOSUpdate(name)
        case 35: return rng.chance(50) ? .iCloudOff(name) : .iCloudOn(name)
        case 36: return .syncICloud(name)
        case 37: return .wipeKeychain(name)
        case 38: return .switchAppleID(name, to: rng.chance(50) ? SWorld.appleB : SWorld.appleA)
        case 39: return .replaceMac(name, carriesMemory: rng.chance(50))
        case 40: return rng.chance(50) ? .goOffline(name) : .goOnline(name)
        case 41: return .timeMachineSnapshot(name)
        case 42: return .timeMachineRollback(name)
        case 43: return .tamper(name, rng.pick(Tamper.allCases)!)
        case 44: return .plantPair(name)
        default: return .settle
        }
    }

    /// A whole sequence, generated against a live world so each step is
    /// chosen from the state it meets.
    mutating func sequence(seed: UInt64, maxSteps: Int) async throws -> (Generated, SWorld) {
        let start = rng.int(0..<StartingState.all.count)
        let world = SWorld(seed: seed)
        try StartingState.all[start].build(world)
        var actions: [Action] = []
        let length = rng.int(max(1, maxSteps / 2)..<(maxSteps + 1))
        for index in 0..<length {
            let action = index == length - 1 ? Action.settle : next(world)
            actions.append(action)
            await world.step(action, words: index % 10 == 9)
            if !world.violations.isEmpty { break }
        }
        return (Generated(seed: seed, start: start, actions: actions), world)
    }

    /// Replay a concrete sequence on a fresh world.
    static func replay(_ generated: Generated, actions: [Action]) async throws -> SWorld {
        let world = SWorld(seed: generated.seed)
        try StartingState.all[generated.start].build(world)
        for (index, action) in actions.enumerated() { await world.step(action, words: index % 10 == 9 || index == actions.count - 1) }
        return world
    }

    /// The minimal sequence that still fails the same promise (delta debugging
    /// by single-step removal, to a fixpoint).
    static func shrink(_ generated: Generated, promise: Int) async throws -> [Action] {
        var actions = generated.actions
        var progress = true
        while progress {
            progress = false
            var index = 0
            while index < actions.count {
                var candidate = actions
                candidate.remove(at: index)
                if !candidate.isEmpty,
                   try await replay(generated, actions: candidate).violations.contains(where: { $0.0.promise == promise }) {
                    actions = candidate
                    progress = true
                } else {
                    index += 1
                }
            }
        }
        return actions
    }
}

/// The everyday counts, and the soak's (the go/no-go: ≥ 20 seeds × ≥ 1,000
/// sequences × up to 60 steps).
enum GeneratorCounts {
    static var soak: Bool { ProcessInfo.processInfo.environment["PROTECTION_SOAK"] == "1" }
    static var seeds: Int { soak ? (envInt("PROTECTION_SOAK_SEEDS") ?? 20) : 2 }
    static var sequences: Int { soak ? (envInt("PROTECTION_SOAK_SEQUENCES") ?? 1000) : 8 }
    static var maxSteps: Int { soak ? 60 : 30 }
    static var firstSeed: UInt64 { UInt64(envInt("PROTECTION_SEED") ?? 1) }

    static func envInt(_ name: String) -> Int? { ProcessInfo.processInfo.environment[name].flatMap(Int.init) }
}

@Suite("VX-305 U4 — the generator: seeded sequences over every starting state, the promises after every step")
struct GeneratorTests {
    @Test func seededSequencesKeepEveryPromise() async throws {
        let started = Date()
        var steps = 0, sequences = 0
        for seedIndex in 0..<GeneratorCounts.seeds {
            let seed = GeneratorCounts.firstSeed + UInt64(seedIndex)
            var generator = ScenarioGenerator(seed: seed)
            for sequenceIndex in 0..<GeneratorCounts.sequences {
                let sequenceSeed = seed &* 1_000_003 &+ UInt64(sequenceIndex)
                let (generated, world) = try await generator.sequence(seed: sequenceSeed, maxSteps: GeneratorCounts.maxSteps)
                sequences += 1
                steps += generated.actions.count
                guard let (violation, _) = world.violations.first else { continue }
                let minimal = try await ScenarioGenerator.shrink(generated, promise: violation.promise)
                let replayed = try await ScenarioGenerator.replay(generated, actions: minimal)
                Issue.record("""
                    seed \(seed) sequence \(sequenceIndex) (world seed \(sequenceSeed), start \(StartingState.all[generated.start])):
                    \(violation)
                    minimal sequence (\(minimal.count) steps): \(minimal)
                    \(replayed.log)
                    """)
                return
            }
        }
        let seconds = Date().timeIntervalSince(started)
        print("PROTECTION GENERATOR: \(GeneratorCounts.seeds) seeds × \(GeneratorCounts.sequences) sequences, \(sequences) sequences, \(steps) steps, max \(GeneratorCounts.maxSteps) steps, \(String(format: "%.1f", seconds)) s\(GeneratorCounts.soak ? " (SOAK)" : "")")
    }
}
