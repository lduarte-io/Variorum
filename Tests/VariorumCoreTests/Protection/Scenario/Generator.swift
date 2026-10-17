//
//  Generator.swift
//  VariorumCoreTests — VX-305 U4: THE RUNNER and THE GENERATOR (the phase plan
//  §6: "seeded and reproducible: a failing seed prints its minimal sequence.
//  It runs as part of `swift test`, with a count small enough for the
//  everyday loop, plus a `PROTECTION_SOAK=1` environment switch for the
//  go/no-go run").
//
//  The runner applies a step and checks the promises after it (VX-378 U4's
//  nine, `Promises.swift`): every step's, the settle's clauses (1's retired-key
//  clause, 2, 3's convergence), the launch's and the write's findings (7, 8),
//  and the tampering steps' (9's tamper clause — the device is relaunched as
//  part of the step, the next open being when a planted or replayed thing
//  would act).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

extension SWorld {
    /// Apply one step and check the promises after it. Violations accumulate
    /// in `violations`.
    @discardableResult
    func step(_ action: Action) async -> StepResult {
        noticedThisStep.removeAll()
        // A single tamper and a group (`.tamperSequence`) are bracketed alike:
        // ONE pre-launch settle before, ONE relaunch and promise-10 check after.
        let tampered: (name: String, tampers: [Tamper])? = {
            switch action {
            case .tamper(let name, let tamper): return (name, [tamper])
            case .tamperSequence(let name, let tampers): return (name, tampers)
            default: return nil
            }
        }()
        if let name = tampered?.name, !device(name).isOpen {
            // Its true posture before the tamper is what an open reads — and a
            // resume that open ran settles what its press chose BEFORE the
            // tamper can take the lock it would be read back from (the closer's
            // soak, seed 9 sequence 312: a deleted key file left her truth
            // without the words her resumed Use Castle had made new).
            _ = try? await launch(device(name))
            syncHolders()
            adoptPending(device(name))
        }
        let before = Dictionary(uniqueKeysWithValues: devices.map { ($0.name, posture($0)) })
        // A device whose pressed act was still in flight before this step — a
        // crash's, or one named and waiting for its account's vault (her
        // ruling 2026-10-14/15) — may settle at this step: that is the
        // deliberate act finishing, never a silent change (promise 4).
        let crashedBefore = crashed.union(devices.filter { $0.library?.section.actInFlight != nil }.map(\.name))
        var inner = action
        if case .crash(let wrapped, _) = action { inner = wrapped }
        switch inner {
        case .timeMachineRollback(let name), .tamper(let name, .replayLibraryFile), .deleteContainerAndOpenOldCopy(let name):
            if let was = before[name] { truth.beforeRollback[name] = (was.mode, was.account) }
        default: break
        }
        var result = await apply(action)
        let kind = String(String(describing: action).prefix { $0 != "(" })
        let tag: String
        switch result { case .done: tag = "done"; case .crashed: tag = "crashed"; case .refused: tag = "refused" }
        stats[kind, default: [:]][tag, default: 0] += 1
        if case .crash = action, result == .crashed, let name = action.device { crashed.insert(name) }
        syncHolders()
        for device in devices { adoptPending(device) }
        var found: [Violation] = []
        var reopened: String?
        if let (name, tampers) = tampered {
            // The next open is when a planted or replayed thing would act.
            let d = device(name)
            do {
                try await launch(d)
                reopened = name
            } catch { stepLog.append("  (the tampered library didn't open: \(error))") }
            crashed.remove(name)
            found += sealed(d, before: before[name]!, tampers: tampers, opened: reopened == name,
                            noticed: noticedThisStep.contains(name))
        }
        if case .launch(let name) = action, result == .done { crashed.remove(name) }
        for device in devices { adoptPending(device) }
        if action == .settle { crashed.removeAll() }
        found += checkPromises(settled: action == .settle)
        found += noSilentChange(action, before: before, crashedBefore: crashedBefore)
        // A tamper step whose relaunch OPENED the library has had its replay's
        // effect land and be judged here, inside this deliberate step (promise
        // 10 above; promise 4 counts the step deliberate), so its
        // `beforeRollback` entry is spent. Kept when the relaunch didn't open: the later open is that
        // entry's one legitimate consumer. VX-305 ladder round 2, NIT 3 (the
        // final call §4).
        if let name = reopened { truth.beforeRollback[name] = nil }
        if !found.isEmpty {
            stepLog.append(contentsOf: found.map { "  ✗ \($0)" })
            violations.append(contentsOf: found.map { ($0, stepLog.count) })
            if result == .done { result = .done }
        }
        return result
    }

    /// Run a sequence; returns every violation, each with the step it surfaced at.
    @discardableResult
    func run(_ actions: [Action]) async -> [Violation] {
        for action in actions { await step(action) }
        return violations.map(\.0)
    }

    var log: String { stepLog.joined(separator: "\n") }
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
        if d.slot == nil { return rng.chance(70) ? .createLibrary(name, passphrase: rng.chance(70)) : .settle }
        let account = world.server.accounts.keys.sorted().first ?? "00000000-0000-4000-8000-000000000000"
        let kinds = Self.kinds
        var roll = rng.int(0..<kinds.reduce(0) { $0 + $1.weight })
        var kind = 0
        while roll >= kinds[kind].weight { roll -= kinds[kind].weight; kind += 1 }
        let action = make(kinds[kind].name, name, other, account)
        // Never `.crash`-wrapped: the settle, and the tamper group —
        // its edits are the adversary's file and item writes, not an act's,
        // so a crash "after n writes" of it means nothing; and the seed-9
        // pre-settle (kept, the final call §1(c)) settles a crashed act before
        // any group, so a group never lands inside a crash window here (the
        // fixed scenarios in LadderRound1Pins.swift hold that road).
        if kinds[kind].name != "settle", kinds[kind].name != "tamperSequence", rng.chance(12) {
            return .crash(action, afterWrites: rng.int(1..<24))
        }
        return action
    }

    /// Two or three distinct tampers for one closed window. The adversary's
    /// claims are single items "or both homes of this Mac's facts together"
    /// (design §4.1, promise 10, §3.6's stated limit) — so `.replayBothHomes`
    /// never joins a group (it carries its own stated-limit bookkeeping).
    /// (The composition rule `rollsBackBothHomes` left with `replayLibraryFile`
    /// from the pool — VX-378 U1, rule 21.)
    mutating func tamperGroup() -> [Tamper] {
        let pool = Tamper.generated.filter { $0 != .replayBothHomes }
        let size = rng.chance(70) ? 2 : 3
        var group: [Tamper] = []
        for _ in 0..<24 where group.count < size {
            let tamper = rng.pick(pool)!
            if group.contains(tamper) { continue }
            group.append(tamper)
        }
        return group
    }

    /// THE ALPHABET, by name and weight. VX-378 U1 cut the acts whose doors
    /// died with the design they served — Re-link (rule 8), the old shared
    /// key's retirement and move (rule 26), the finish of a stuck leave (rule
    /// 12), corner 45's answer and the mode confirm (rule 26), the open copy's
    /// own line, the landing and the older library's open (rule 17), the older
    /// build (rule 26). VX-378 U4 added rule 17's two doors — Look inside and
    /// Make this my library — and brought the replay tampers back as detection
    /// (`Tamper.generated`).
    static let kinds: [(name: String, weight: Int)] = [
        ("launch", 6), ("lock", 3), ("useCastle", 5), ("useStandard", 5), ("replaceAllKeys", 3), ("follow", 4),
        ("turnOnSync", 3), ("signIn", 2), ("signOut", 2), ("thisMacOnly", 2), ("stopSyncingHere", 2), ("move", 1),
        ("changePassphrase", 3), ("resetPassphrase", 2), ("regenerateWords", 2), ("backup", 6), ("sendLibrary", 2),
        ("plaintextExport", 2), ("offerDelete", 1), ("setGate", 2), ("answerRearm", 1), ("setIdleLock", 1),
        ("setScheduledExport", 2), ("finger", 2), ("lid", 2), ("macOSUpdate", 1), ("iCloudSwitch", 2), ("syncICloud", 3),
        ("wipeKeychain", 1), ("switchAppleID", 1), ("replaceMac", 1), ("online", 1), ("timeMachineSnapshot", 1),
        ("timeMachineRollback", 1), ("tamper", 2), ("plantPair", 1), ("settle", 3), ("tamperSequence", 1),
        ("lookInside", 2), ("makeMine", 1), ("useKeyFileOffer", 2),
    ]

    mutating func make(_ kind: String, _ name: String, _ other: String, _ account: String) -> Action {
        switch kind {
        case "launch": return .launch(name)
        case "lock": return .lock(name)
        case "useCastle": return .useCastle(name, rng.chance(60) ? .touchID : .alwaysAsk, newWords: rng.chance(20))
        case "useStandard": return .useStandard(name)
        case "replaceAllKeys": return .replaceAllKeys(name, newWords: rng.chance(30))
        case "follow": return .follow(name, rng.chance(60) ? .passphrase : (rng.chance(80) ? .words : .oldPassphrase))
        case "turnOnSync": return .turnOnSync(name)
        case "signIn": return .signIn(name, account: account)
        case "signOut": return .signOut(name)
        case "thisMacOnly": return .thisMacOnly(name)
        case "stopSyncingHere": return .stopSyncingHere(name)
        case "move": return .move(name)
        case "changePassphrase": return .changePassphrase(name)
        case "resetPassphrase": return .resetPassphrase(name, rng.pick(ResetVia.allCases)!)
        case "regenerateWords": return .regenerateWords(name)
        case "backup": return .backup(name)
        case "sendLibrary": return .sendLibrary(from: name, to: other)
        case "plaintextExport": return .plaintextExport(name)
        case "offerDelete": return .offerDelete(name)
        case "setGate": return .setGate(name, rng.chance(50) ? .touchID : .alwaysAsk)
        case "answerRearm": return .answerRearm(name, yes: rng.chance(50))
        case "setIdleLock": return .setIdleLock(name, minutes: rng.pick([nil, 5, 10, 30])!)
        case "setScheduledExport": return .setScheduledExport(name, rng.chance(50))
        case "finger": return rng.chance(50) ? .addFinger(name) : .removeFinger(name)
        case "lid": return rng.chance(50) ? .closeLid(name) : .openLid(name)
        case "macOSUpdate": return .macOSUpdate(name)
        case "iCloudSwitch": return rng.chance(50) ? .iCloudOff(name) : .iCloudOn(name)
        case "syncICloud": return .syncICloud(name)
        case "wipeKeychain": return .wipeKeychain(name)
        case "switchAppleID": return .switchAppleID(name, to: rng.chance(50) ? SWorld.appleB : SWorld.appleA)
        case "replaceMac": return .replaceMac(name, carriesMemory: rng.chance(50))
        case "online": return rng.chance(50) ? .goOffline(name) : .goOnline(name)
        case "timeMachineSnapshot": return .timeMachineSnapshot(name)
        case "timeMachineRollback": return .timeMachineRollback(name)
        case "tamper": return .tamper(name, rng.pick(Tamper.generated)!)
        case "plantPair": return .plantPair(name)
        case "tamperSequence": return .tamperSequence(name, tamperGroup())
        case "lookInside": return .lookInside(name, pick: rng.int(0..<8), typing: rng.pick(CopyTyping.allCases)!)
        case "makeMine": return .makeMine(name, pick: rng.int(0..<8), typing: rng.chance(70) ? .itsDay : .current)
        case "useKeyFileOffer": return .useKeyFileOffer(name)
        default: return .settle
        }
    }

    /// A whole sequence, generated against a live world so each step is
    /// chosen from the state it meets.
    mutating func sequence(seed: UInt64, maxSteps: Int) async throws -> (Generated, SWorld) {
        let start = rng.int(0..<StartingState.all.count)
        let world = SWorld(seed: seed)
        try await StartingState.all[start].build(world)
        var actions: [Action] = []
        let length = rng.int(max(1, maxSteps / 2)..<(maxSteps + 1))
        for index in 0..<length {
            let action = index == length - 1 ? Action.settle : next(world)
            actions.append(action)
            await world.step(action)
            if !world.violations.isEmpty { break }
        }
        return (Generated(seed: seed, start: start, actions: actions), world)
    }

    /// Replay a concrete sequence on a fresh world.
    static func replay(_ generated: Generated, actions: [Action]) async throws -> SWorld {
        let world = SWorld(seed: generated.seed)
        try await StartingState.all[generated.start].build(world)
        for action in actions { await world.step(action) }
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
        var stats: [String: [String: Int]] = [:]
        for seedIndex in 0..<GeneratorCounts.seeds {
            let seed = GeneratorCounts.firstSeed + UInt64(seedIndex)
            var generator = ScenarioGenerator(seed: seed)
            for sequenceIndex in 0..<GeneratorCounts.sequences {
                let sequenceSeed = seed &* 1_000_003 &+ UInt64(sequenceIndex)
                let (generated, world) = try await generator.sequence(seed: sequenceSeed, maxSteps: GeneratorCounts.maxSteps)
                sequences += 1
                steps += generated.actions.count
                for (kind, counts) in world.stats { for (tag, n) in counts { stats[kind, default: [:]][tag, default: 0] += n } }
                guard let (violation, _) = world.violations.first else { continue }
                let minimal = try await ScenarioGenerator.shrink(generated, promise: violation.promise)
                let replayed = try await ScenarioGenerator.replay(generated, actions: minimal)
                let report = """
                    seed \(seed) sequence \(sequenceIndex) (world seed \(sequenceSeed), start \(StartingState.all[generated.start])):
                    \(violation)
                    minimal sequence (\(minimal.count) steps): \(minimal)
                    \(replayed.log)
                    """
                // VX-378 U4: the soak's red written whole where asked (the
                // console can drop a long issue).
                if let out = ProcessInfo.processInfo.environment["PROTECTION_FAIL_OUT"] {
                    try? Data(report.utf8).write(to: URL(fileURLWithPath: out))
                }
                Issue.record(Comment(rawValue: report))
                return
            }
        }
        let seconds = Date().timeIntervalSince(started)
        if GeneratorCounts.soak || ProcessInfo.processInfo.environment["PROTECTION_STATS"] == "1" {
            for kind in stats.keys.sorted() {
                let c = stats[kind]!
                print("  \(kind): done \(c["done"] ?? 0), refused \(c["refused"] ?? 0), crashed \(c["crashed"] ?? 0)")
            }
        }
        print("PROTECTION GENERATOR: \(GeneratorCounts.seeds) seeds × \(GeneratorCounts.sequences) sequences, \(sequences) sequences, \(steps) steps, max \(GeneratorCounts.maxSteps) steps, \(String(format: "%.1f", seconds)) s\(GeneratorCounts.soak ? " (SOAK)" : "")")
    }
}
