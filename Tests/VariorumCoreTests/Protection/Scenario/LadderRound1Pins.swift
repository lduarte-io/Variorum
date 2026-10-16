//
//  LadderRound1Pins.swift
//  VariorumCoreTests — VX-305 ladder round 1, the MAJOR (the stray-file
//  wedge): the reviewer's proposed fixed scenario and its neighbours, built
//  by the implementer's answer and watched RED on the tree before the fix
//  (every case refused `noLiveKeyFile` — the record:
//  `notes/plans/vx-305-ladder-round-1-fixes.md`), now asserting the fixed
//  behaviour (`notes/plans/vx-305-ladder-round-1-final-call.md` §1(d)).
//
//  The mechanism: a roll back with no plan to trust (a replayed, planted or
//  missing plan) and the memory item gone restored nothing, so ANOTHER key's
//  file stayed in the live place with no repair able to bring the current
//  key's own file back — every act needing the live key file refused forever
//  (§3.3's "Always: the record, what this Mac remembers and the key file
//  agree" broken). The fix: `restoreKeyFileFromCopy` widened in assess AND
//  the executor, the stray file set ASIDE (never deleted).
//
//  The tampers are applied with `apply`, not `step`: `step` brackets a
//  single tamper with launches (the seed-9 pre-settle), so a tamper never
//  lands inside a crash window there — these scenarios need it. The
//  generator reaches the same wedge by its other road (the earlier key's
//  file replayed with the memory gone) through `.tamperSequence`.
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 ladder round 1 — the MAJOR: the stray-file wedge, fixed")
struct LadderRound1MajorPin {
    /// A Castle library on macA, opened (the migration — which leaves its own
    /// fresh pair of the current key), with or without one more backup pair.
    static func castle(_ gate: GateStyle, backup: Bool) async throws -> SWorld {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: gate)) }
        await world.done([.launch("macA")])
        if backup { await world.done([.backup("macA")]) }
        return world
    }

    /// Use Standard crashed after its new key file landed in the live place
    /// (the library still under the current key, the plan on disk) — the
    /// first such write count, each try on a fresh replay of `prefix`.
    static func leaveCrashedWithItsNewFileLive(
        _ prefix: () async throws -> SWorld
    ) async throws -> (world: SWorld, current: String, stray: String, writes: Int)? {
        for m in 1...60 {
            let w = try await prefix()
            let current = try #require(w.macA.slot?.fingerprint)
            let r = await w.step(.crash(.useStandard("macA"), afterWrites: m))
            guard r == .crashed else { return nil }
            if let live = w.liveKeyFile(w.macA), live.fingerprint != current, w.macA.slot?.fingerprint == current,
               w.macA.container.files[SPath.plan] != nil {
                return (w, current, live.fingerprint, m)
            }
        }
        return nil
    }

    /// After the relaunch: the current key's own file is back in the live
    /// place (no Apple wrap re-added), the stray file catalogued SET ASIDE,
    /// no fault left, and nothing more owed.
    static func expectWedgeRepaired(_ w: SWorld, current: String, stray: String, _ context: String) {
        #expect(w.liveKeyFile(w.macA)?.fingerprint == current, "\(context): the current key's file didn't come back")
        // The restore strips Apple wraps (never re-added by a restore): in
        // Castle none stays; in Standard only the one `landAppleWrap` lands
        // afterwards, under this Mac's own unretired key (promise 3's road).
        if w.macA.slot?.record?.mode == .castle {
            #expect(w.liveKeyFile(w.macA)?.apple == nil, "\(context): an Apple wrap on a Castle key")
        } else if let wrap = w.liveKeyFile(w.macA)?.apple {
            let own = w.macA.library?.section.appleKeys.filter { $0.isOwnLibraryKey && $0.retiredAt == nil }.map(\.id) ?? []
            #expect(own.contains(wrap.keyID), "\(context): an Apple wrap under a key not this Mac's own")
            #expect(w.macA.logLines.contains { $0.contains("repair landAppleWrap: done") })
        }
        let aside = w.catalog(w.macA).keyFiles.filter { $0.role == .setAside && $0.fingerprint == stray }
        #expect(aside.count == 1, "\(context): the stray file isn't catalogued set aside: \(w.catalog(w.macA).keyFiles.map { "\($0.name) \($0.role)" })")
        #expect(w.macA.logLines.contains { $0.contains("repair restoreKeyFileFromCopy: done") }, "\(context): the repair never ran")
        let assessment = w.assessed(w.macA)
        #expect(!assessment.faults.contains { if case .liveKeyFileIsAnotherKeys = $0 { return true }; return false })
        #expect(!assessment.repairs.contains { if case .restoreKeyFileFromCopy = $0 { return true }; return false })
    }

    /// THE REVIEWER'S SCENARIO: act A crashed with its genuine plan on disk
    /// (captured), then settled at the relaunch; a leave (Use Standard)
    /// crashed after its new key file landed live; the memory item deleted;
    /// A's plan replayed over the leave's; the relaunch rolls the leave back
    /// with no plan to trust and no mirror — the repair brings the current
    /// key's file back from its newest catalogued pair, the stray file goes
    /// aside, and Use Standard runs. Red on the tree before the fix in all
    /// four cases: `Use Standard → .refused("noLiveKeyFile")`.
    @Test(arguments: [GateStyle.touchID, .alwaysAsk], [false, true])
    func aPlanlessRollBackWithNoMirrorGetsTheCurrentKeysFileBack(gate: GateStyle, backup: Bool) async throws {
        // 1. Act A's crash point: the first write count that leaves its plan on disk.
        var crashA: Int?
        for n in 1...20 {
            let world = try await Self.castle(gate, backup: backup)
            let r = await world.step(.crash(.setScheduledExport("macA", true), afterWrites: n))
            guard r == .crashed else { break }
            if world.macA.container.files[SPath.plan] != nil { crashA = n; break }
        }
        let nA = try #require(crashA, "no crash point left act A's plan on disk")
        var capturedA: SFile?
        let found = try await Self.leaveCrashedWithItsNewFileLive {
            let w = try await Self.castle(gate, backup: backup)
            _ = await w.step(.crash(.setScheduledExport("macA", true), afterWrites: nA))
            capturedA = w.macA.container.files[SPath.plan]
            await w.done([.launch("macA")])  // A settles at the relaunch
            return w
        }
        let (w, current, stray, m) = try #require(found, "no crash point of Use Standard left another key's file live")
        let context = "gate \(gate), backup \(backup), A after write \(nA), the leave after write \(m)"

        // 2. The two tampers, inside the crash window.
        w.macA.captures = [DeviceCapture(slot: nil, liveKeyFile: nil, memory: nil, memoryName: nil, plan: try #require(capturedA))]
        #expect(await w.apply(.tamper("macA", .deleteMemoryItem)) == .done)
        #expect(await w.apply(.tamper("macA", .replayPlan)) == .done)

        // 3. The relaunch: not the named plan → plan-less → rolled back → repaired.
        await w.done([.launch("macA")])
        #expect(w.macA.lastSettle == .rolledBack(.leaveCastle), "\(context): settle \(String(describing: w.macA.lastSettle))")
        #expect(w.macA.diagnostics.contains(.planIgnored(.notNamed)))
        #expect(w.macA.library?.section.actInFlight == nil)
        Self.expectWedgeRepaired(w, current: current, stray: stray, context)

        // 4. The next act runs.
        await w.done([.useStandard("macA"), .settle])
        #expect(w.macA.slot?.record?.mode == .standard, "\(context)")
        expectPromisesKept(w, context)
    }

    /// The same crash window with a PLANTED plan (no captured genuine plan
    /// needed): it fails its seal, so settle takes the `.unsealed` arm into
    /// the same plan-less roll back — repaired the same way.
    @Test func aPlantedPlanInsteadOfAReplayedOne() async throws {
        let found = try await Self.leaveCrashedWithItsNewFileLive { try await Self.castle(.touchID, backup: false) }
        let (w, current, stray, m) = try #require(found)
        #expect(await w.apply(.tamper("macA", .deleteMemoryItem)) == .done)
        #expect(await w.apply(.tamper("macA", .plantPlan)) == .done)
        await w.done([.launch("macA")])
        #expect(w.macA.diagnostics.contains(.planIgnored(.unsealed)))
        #expect(w.macA.lastSettle == .rolledBack(.leaveCastle), "settle: \(String(describing: w.macA.lastSettle))")
        Self.expectWedgeRepaired(w, current: current, stray: stray, "the leave after write \(m)")
        await w.done([.useStandard("macA"), .settle])
        expectPromisesKept(w)
    }

    /// A SECOND ROAD with NO crash: the memory item deleted and an earlier
    /// key's genuine key file replayed into the live place (two tampers, the
    /// app closed) — repaired the same way.
    @Test(arguments: [false, true])
    func anEarlierKeysFileReplayedWithTheMemoryGone(backup: Bool) async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA")])
        let earlier = try #require(world.macA.container.files[SPath.liveKeyFile])
        let stray = try #require(world.liveKeyFile(world.macA)?.fingerprint)
        // Two crossings (Replace All Keys refuses a local library: notSynced).
        await world.done([.useStandard("macA"), .useCastle("macA", .touchID, newWords: false)])
        if backup { await world.done([.backup("macA")]) }
        let current = try #require(world.macA.slot?.fingerprint)
        #expect(current != stray)
        world.lock(world.macA)
        world.macA.captures = [DeviceCapture(slot: nil, liveKeyFile: earlier, memory: nil, memoryName: nil, plan: nil)]
        #expect(await world.apply(.tamper("macA", .deleteMemoryItem)) == .done)
        #expect(await world.apply(.tamper("macA", .replayKeyFile)) == .done)
        await world.done([.launch("macA")])
        Self.expectWedgeRepaired(world, current: current, stray: stray, "backup \(backup)")
        await world.done([.useStandard("macA"), .settle])
        expectPromisesKept(world, "backup \(backup)")
    }

    /// The Use-Castle variant (a Standard library; the stray file a Castle
    /// key's, no Apple wrap): before the fix assess owed only a `landAppleWrap`
    /// the executor skipped forever and said nothing else; now the repair runs
    /// and Use Castle succeeds.
    @Test func theUseCastleVariant() async throws {
        let built: () async throws -> SWorld = {
            let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .settle])
            return world
        }
        var crashA: Int?
        for n in 1...20 {
            let world = try await built()
            let r = await world.step(.crash(.setScheduledExport("macA", true), afterWrites: n))
            guard r == .crashed else { break }
            if world.macA.container.files[SPath.plan] != nil { crashA = n; break }
        }
        let nA = try #require(crashA)
        var found: (world: SWorld, capturedA: SFile, current: String, stray: String)?
        for m in 1...60 {
            let w = try await built()
            _ = await w.step(.crash(.setScheduledExport("macA", true), afterWrites: nA))
            let capturedA = try #require(w.macA.container.files[SPath.plan])
            await w.done([.launch("macA")])
            let current = try #require(w.macA.slot?.fingerprint)
            let r = await w.step(.crash(.useCastle("macA", .alwaysAsk, newWords: false), afterWrites: m))
            guard r == .crashed else { break }
            if let live = w.liveKeyFile(w.macA), live.fingerprint != current, w.macA.slot?.fingerprint == current,
               w.macA.container.files[SPath.plan] != nil {
                found = (w, capturedA, current, live.fingerprint)
                break
            }
        }
        let (w, capturedA, current, stray) = try #require(found, "no crash point of Use Castle left another key's file live")
        w.macA.captures = [DeviceCapture(slot: nil, liveKeyFile: nil, memory: nil, memoryName: nil, plan: capturedA)]
        #expect(await w.apply(.tamper("macA", .deleteMemoryItem)) == .done)
        #expect(await w.apply(.tamper("macA", .replayPlan)) == .done)
        await w.done([.launch("macA")])
        #expect(w.macA.lastSettle == .rolledBack(.enterCastle), "settle: \(String(describing: w.macA.lastSettle))")
        Self.expectWedgeRepaired(w, current: current, stray: stray, "the Use-Castle variant")
        #expect(!w.assessed(w.macA).repairs.contains { if case .landAppleWrap = $0 { return true }; return false })
        await w.done([.useCastle("macA", .alwaysAsk, newWords: false), .settle])
        #expect(w.macA.slot?.record?.mode == .castle)
        expectPromisesKept(w)
    }

    /// THE STALE-COPY CASE, asserted honestly (the final call §1(d) and point
    /// 3): a key door between the backup pair and the tampers. The restored
    /// file keeps the locks of ITS day (the pair froze before the passphrase
    /// changed): a door typed with the CURRENT passphrase refuses
    /// `passphraseDoesNotOpen`, the copy-day passphrase opens, and the library
    /// stays open throughout. Pre-existing (U3's both-deleted repair restores
    /// the same way); re-locking under current secrets is P-R1-1's door.
    @Test func aRestoredFileKeepsTheLocksOfItsDay() async throws {
        var copyDay: (passphrase: String?, words: [String]?)?
        let found = try await Self.leaveCrashedWithItsNewFileLive {
            let w = try await Self.castle(.touchID, backup: true)
            let holder = try #require(w.slotHolder(w.macA))
            copyDay = (w.known(holder).passphrase, w.known(holder).words)
            await w.done([.changePassphrase("macA")])
            return w
        }
        let (w, current, stray, _) = try #require(found)
        let (copyPassphrase, copyWords) = try #require(copyDay)
        let holder = try #require(w.slotHolder(w.macA))
        #expect(w.known(holder).passphrase != copyPassphrase, "the key door didn't change the passphrase")
        #expect(await w.apply(.tamper("macA", .deleteMemoryItem)) == .done)
        #expect(await w.apply(.tamper("macA", .plantPlan)) == .done)
        await w.done([.launch("macA")])
        Self.expectWedgeRepaired(w, current: current, stray: stray, "the stale copy")
        #expect(w.macA.isOpen)
        // The door, typed with the passphrase she has now: refused, honestly.
        let now = await w.step(.useStandard("macA"))
        #expect(now == .refused("passphraseDoesNotOpen"), "Use Standard with the current passphrase → \(now)")
        #expect(w.macA.isOpen, "the library closed on the refusal")
        // The copy-day passphrase opens the restored file's lock: the door runs.
        try await w.act(w.macA) { executor, library in
            try await executor.useStandard(&library, typed: TypedSecrets(passphrase: copyPassphrase, words: copyWords))
        }
        w.setKnown(holder, passphrase: copyPassphrase, words: copyWords)
        #expect(w.macA.isOpen)
        #expect(w.macA.slot?.record?.mode == .standard)
        await w.done([.settle])
        expectPromisesKept(w)
    }

    /// THE COPY-LESS CASE — PROVISIONAL P-R1-1, the honest refusal stands
    /// (not gating, the final call point 2): the key file and the memory item
    /// both deleted on a Touch ID Castle library with NO catalogued copy of its
    /// key file (her backups deleted too). The lobby opens it through the Touch
    /// ID item; nothing can bring the key file back, so the next act refuses
    /// `noLiveKeyFile` — the hand-forward's door (a rebuild under secrets typed
    /// and set at it) is the author's call.
    /// THE GENERATOR'S COMPOUND ROAD (the final call §1(c)): with promise 1's
    /// live-key-file clause and `.tamperSequence`, a seeded run on the tree
    /// before the fix reached the wedge — seed 1, sequence 96 (world seed
    /// 1000099, after 97 sequences / 4,515 steps, 51 tamper groups), shrunk to
    /// these three steps: the group (an Apple wrap planted, an earlier key's
    /// file replayed, an earlier memory item replayed) leaves the pre-Castle
    /// key's file live with no mirror of the current one. Before the fix:
    /// `promise 1 on macB: the live key file is d30d1b73, the record's key
    /// e79f11e3 — and no repair brings its own file back`.
    @Test func aTamperGroupReachesTheWedge() async throws {
        let world = try GeneratorFoundScenarios.start("VX-209's victim", seed: 1_000_099)
        for action in [Action.createLibrary("macB", secrets: false), .useCastle("macB", .touchID, newWords: false),
                       .tamperSequence("macB", [.plantAppleWrap, .replayKeyFile, .replayMemory])] {
            await world.step(action)
        }
        #expect(world.liveKeyFile(world.macB)?.fingerprint == world.macB.slot?.record?.currentFingerprint)
        expectPromisesKept(world)
    }

    /// …and the wedge was reachable by ONE tamper (the generator, seed 1
    /// sequence 37 on the tree before the fix): a library file replayed after
    /// a leave. The leave's new key takes no history (the anchor holds the old
    /// one), so `libraryFileLosesToMemory` can't verify and the replayed record
    /// stays — P-U4-6's "a file only the ANCHOR reaches stays the replayed
    /// record" (her P-U4-10 ruling) — while the newer key's file stayed live
    /// with nothing owed. Now its own key file comes back and the newer one goes
    /// aside. Before the fix: `promise 1 on macA: the live key file is 1546fc58,
    /// the record's key 06a3e65a — and no repair brings its own file back`.
    @Test func aLibraryFileReplayedAfterALeave() async throws {
        let world = try GeneratorFoundScenarios.start("13p escrow items", seed: 1_000_040)
        for action in [Action.useStandard("macA"), .tamper("macA", .replayLibraryFile)] { await world.step(action) }
        #expect(world.liveKeyFile(world.macA)?.fingerprint == world.macA.slot?.record?.currentFingerprint)
        #expect(world.catalog(world.macA).keyFiles.contains { $0.role == .setAside })
        expectPromisesKept(world)
    }

    @Test func theCopyLessCaseIsP_R1_1sHonestRefusal() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA")])
        for path in world.macA.container.paths(under: "Backups/") { world.macA.container.files[path] = nil }
        if let far = world.farFolder(of: world.macA) { far.files = [:] }
        #expect(world.catalog(world.macA).keyFiles.allSatisfy { $0.role == .live }, "a copy remains")
        await world.done([.tamper("macA", .deleteKeyFileAndMemory)])
        #expect(world.macA.isOpen)
        #expect(!world.assessed(world.macA).repairs.contains { if case .restoreKeyFileFromCopy = $0 { return true }; return false })
        let result = await world.step(.useStandard("macA"))
        #expect(result == .refused("noLiveKeyFile"), "Use Standard → \(result)")
        #expect(world.macA.isOpen)
        expectPromisesKept(world)
    }
}
