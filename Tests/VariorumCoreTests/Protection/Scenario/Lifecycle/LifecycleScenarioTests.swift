//
//  LifecycleScenarioTests.swift
//  VariorumCoreTests — VX-378 U3: THE LIFECYCLE PROOF (gate item 6 of
//  `notes/plans/vx-378-castle-simplified.md`). One fixed scenario walks the
//  fourteen stages of `notes/plans/vx-266/castle-lifecycle.html` through the
//  executor's real acts and asserts at every stage against THE FIXTURE
//  (`Lifecycle.stages`) — red on any tree whose model doesn't produce the
//  page's facts, by construction, since nothing here reads what the model
//  says about itself. The page's two "or"s before stage 6 (an Apple ID change
//  or an iCloud Keychain reset; Touch ID or Always ask) are each walked.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U3 — the lifecycle: the page's fourteen stages against the fixture")
struct LifecycleScenarioTests {
    @Test(
        "one person, one library, fourteen stages — every road and every written fact as the page states it",
        arguments: LStage5Event.allCases, [GateStyle.touchID, .alwaysAsk])
    func theLifecycle(event: LStage5Event, gate: GateStyle) async throws {
        let walk = LifecycleWalk(event: event, gate: gate)
        let checks = LifecycleChecks(walk: walk)
        for stage in Lifecycle.stages {
            let ctx = walk.begin(stage.number)
            do {
                try await walk.run(stage, ctx)
            } catch {
                Issue.record("\(event) · \(gate) · stage \(stage.number): the road refused — \(error)\n\(walk.world.log)")
                return
            }
            walk.timePasses()
            for failure in checks.verify(stage, ctx) {
                Issue.record("\(event) · \(gate) · \(failure)")
            }
            walk.noteLivePlace()
            if stage.number == 11 { await walk.stage11After() }
        }
    }

    /// The fixture is the authority, not the model: every road chip DISCRIMINATES
    /// — the same world, asked to show the opposite of what the fixture says,
    /// fails it. (A check that passed either way would bless whatever the model
    /// did; none does.)
    @Test(arguments: [(LStage5Event.appleIDChanged, GateStyle.touchID), (.iCloudKeychainReset, .alwaysAsk)])
    func everyChipDiscriminates(event: LStage5Event, gate: GateStyle) async throws {
        let walk = LifecycleWalk(event: event, gate: gate)
        let checks = LifecycleChecks(walk: walk)
        var chips = 0, discriminating = 0
        for stage in Lifecycle.stages {
            let ctx = walk.begin(stage.number)
            try await walk.run(stage, ctx)
            walk.timePasses()
            for (subject, chip) in Lifecycle.chips(of: stage) {
                chips += 1
                let opposite = LChip(
                    road: chip.road, state: checks.expectedState(chip) == .opens ? .gone : .opens, label: chip.label,
                    everywhere: chip.everywhere)
                if checks.check(opposite, subject, ctx).isEmpty {
                    Issue.record("stage \(stage.number) · \(subject.rawValue) · “\(chip.label)” passes either way")
                } else {
                    discriminating += 1
                }
            }
            walk.noteLivePlace()
            if stage.number == 11 { await walk.stage11After() }
        }
        #expect(chips > 0 && discriminating == chips)
    }

    /// The fixture is whole: fourteen stages in order, each "asserted at" a
    /// later stage pointing forward at a stage that asserts the same fact, and
    /// every FACTS DIFF listed once with its reason.
    @Test func theFixtureIsWhole() {
        #expect(Lifecycle.stages.map(\.number) == Array(1...14))
        for stage in Lifecycle.stages {
            for entry in stage.facts {
                switch entry.status {
                case .assertedAt(let later):
                    #expect(later > stage.number, "stage \(stage.number): “\(entry.quote)” points backward")
                    guard let target = Lifecycle.stages.first(where: { $0.number == later }) else {
                        Issue.record("stage \(stage.number): “\(entry.quote)” points at no stage")
                        continue
                    }
                    if case .notTypedHere = entry.fact { continue }
                    let same = target.facts.contains { other in
                        if case .asserted = other.status { return "\(other.fact)" == "\(entry.fact)" }
                        return false
                    }
                    #expect(same, "stage \(stage.number): “\(entry.quote)” — stage \(later) asserts no such fact")
                case .diff(let id, _), .diffWhen(_, let id, _):
                    #expect(Lifecycle.factsDiff.filter { $0.id == id && $0.stage == stage.number }.count == 1,
                            "stage \(stage.number): \(id) isn't listed once for this stage")
                case .asserted:
                    if case .notTypedHere = entry.fact { Issue.record("stage \(stage.number): “\(entry.quote)” asserts nothing") }
                case .branch, .notAModelFact:
                    continue
                }
            }
            for row in stage.rows {
                if case .chips(_, let chips) = row.content {
                    for chip in chips where chip.diff != nil {
                        #expect(Lifecycle.factsDiff.contains { $0.id == chip.diff }, "stage \(stage.number): \(chip.diff!) isn't listed")
                    }
                }
            }
        }
    }
}
