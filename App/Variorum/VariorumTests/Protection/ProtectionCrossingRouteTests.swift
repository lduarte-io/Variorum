//
//  ProtectionCrossingRouteTests.swift
//  VariorumTests — VX-307 U2a piece 4: THE CROSSINGS end to end through `AppBootstrap` (the one switch turned on by a
//  test harness) on a temp slot and a THROWAWAY keychain scope (the real custody and memory leaves; an in-memory Apple
//  leaf; no biometry): the bootstrap's own seam — the `.ready` tree down and the app's pool CLOSED through the binding
//  before the core's act — then the reopen THROUGH THE NEW ROAD under the new key, the act's receipt owed once to the
//  reopened session's status seam, Settings asked back to Protection, rule 11's notice with this test bootstrap's own
//  scheduled-export suite (never the app's domain); Use Standard back; and a typo that never tears the window down.
//  Mac only (the keychain); the same roads over planted leaves are `ProtectionCrossingRoadTests`'.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2a — the crossings through AppBootstrap (throwaway scope, temp slot)", .serialized)
@MainActor
struct ProtectionCrossingRouteTests {
    static let passphrase = "a castle passphrase"

    /// This test bootstrap's scheduled-export switch — its own suite (`AppBootstrap.crossingTestExportSuiteName`).
    static var exports: ScheduledExportSwitch {
        AppBootstrap.markdownInsuranceSwitch(suiteName: AppBootstrap.crossingTestExportSuiteName)
    }

    static func clearExports() {
        UserDefaults().removePersistentDomain(forName: AppBootstrap.crossingTestExportSuiteName)
    }

    @Test func useCastleClosesThePoolCrossesAndReopensOnTheNewRoadThenUseStandardHandsItBack() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            Self.clearExports()
            defer {
                world.scope.purge()
                Self.clearExports()
            }
            let (created, words) = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            let crossings = try #require(bootstrap.roadCrossings, "the crossings exist on the new road at ready")
            #expect(bootstrap.roadStanding?.crossings === crossings, "the faces carry them to the pane")
            Self.exports.set(true)
            await crossings.refresh()
            let door = try #require(crossings.faces?.useCastle.openDoor)
            #expect(door.newPassphrase && door.sentences.last == ProtectionWords.scheduledExportTurnsOff)
            #expect(crossings.faces?.useStandard == .hidden && crossings.faces?.replaceAllKeys == .hidden)
            let requestsBefore = bootstrap.protection.settingsRequest
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            await confirm.submit(passphrase: Self.passphrase, again: Self.passphrase, words: words.joined(separator: " "))
            #expect(crossings.confirm == nil, "the crossing landed: \(confirm.refusal ?? "-")")
            #expect(crossings.exportNotice, "rule 11's notice is owed")
            #expect(!Self.exports.isOn(), "the weekly copy's switch followed the act")
            guard case .ready = bootstrap.state, let reopened = bootstrap.roadSession else {
                Issue.record("the reopen lands ready on the new road: \(bootstrap.state)")
                return
            }
            #expect(reopened !== session, "a fresh open's session")
            #expect(reopened.library.record?.mode == .castle)
            #expect(reopened.key != created.key)
            // The Castle key, captured NOW: a session is the open library's one holder — the NEXT crossing runs on this
            // same session and writes the act's library into it (`ProtectionCrossings.cross`: `session.library =
            // library`), so a later read of `reopened.key` (computed from its held library) answers the key after THAT
            // act. (The ladder's batch run: comparing `back.key` with a late `reopened.key` read the same Standard key
            // twice — a test-side read, not a product aliasing.)
            let castleKey = reopened.key
            #expect(bootstrap.protection.settingsRequest == requestsBefore + 1, "Settings asked back to Protection")
            #expect(bootstrap.roadStanding?.crossings === crossings, "the same crossings across the reopen")
            let standing = try #require(bootstrap.roadStanding)
            var spoken: [String] = []
            standing.speak = { spoken.append($0) }
            #expect(spoken.filter { $0 == ProtectionWords.enteredCastleReceipt }.count == 1, "\(spoken)")
            standing.speakOwedReceipts()
            #expect(spoken.filter { $0 == ProtectionWords.enteredCastleReceipt }.count == 1, "said once")
            // Rule 11's reversal — her call.
            await crossings.turnExportBackOn()
            #expect(!crossings.exportNotice && Self.exports.isOn())
            #expect(bootstrap.roadSession?.library.section.settings.scheduledExport == true)

            // Use Standard — both secrets; rule 12's sentence at the door; the library hands everything out.
            await crossings.refresh()
            let leave = try #require(crossings.faces?.useStandard.openDoor)
            #expect(leave.sentences.contains(ProtectionWords.leaveSentence) && !leave.newPassphrase)
            crossings.open(.useStandard)
            try await #require(crossings.confirm).submit(
                passphrase: Self.passphrase, again: "", words: words.joined(separator: " "))
            #expect(crossings.confirm == nil)
            guard case .ready = bootstrap.state, let back = bootstrap.roadSession else {
                Issue.record("the reopen lands ready: \(bootstrap.state)")
                return
            }
            #expect(back.library.record?.mode == .standard)
            #expect(back.key != castleKey, "a new Standard key — the Castle one is carried in its history (rule 12)")
            #expect(back.key != created.key)
            #expect(back !== reopened, "a fresh open's session")
            var said: [String] = []
            bootstrap.roadStanding?.speak = { said.append($0) }
            #expect(said == [ProtectionWords.leftCastleReceipt])
        }
    }

    /// LADDER ROUND 1, MAJOR-1 — through the bootstrap: a Use Castle whose act STOPS PAST ITS SWAP (a step after the swap
    /// fails — a planted custody leaf in place of the keychain's), the reopen's settle finishes it — and THE READY follows
    /// the weekly switch off, owes rule 11's notice durably (the pane re-reads it) and says it once on the status seam.
    /// RED on the pre-fix tree (the switch stayed on; no notice); GREEN after.
    @Test func major1_anEntryStoppingPastItsSwapHasItsSwitchFollowedAtTheReopensReady() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            let custody = PlantedCustodyLeaf()
            world.custody = custody
            Self.clearExports()
            defer {
                world.scope.purge()
                Self.clearExports()
            }
            let (created, words) = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            let crossings = try #require(bootstrap.roadCrossings)
            Self.exports.set(true)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            confirm.gate = .alwaysAsk
            custody.failingDeletes = 1  // `retireOldCustody` — past the swap, before `exportOff`
            await confirm.submit(passphrase: Self.passphrase, again: Self.passphrase, words: words.joined(separator: " "))
            #expect(crossings.confirm == nil, "landed: \(confirm.refusal ?? "-")")
            guard case .ready = bootstrap.state, let reopened = bootstrap.roadSession else {
                Issue.record("the reopen lands ready: \(bootstrap.state)")
                return
            }
            #expect(reopened.library.record?.mode == .castle && reopened.key != created.key)
            #expect(reopened.library.section.settings.scheduledExport == false, "the settle's resume ran the export step")
            #expect(!Self.exports.isOn(), "rule 11: the weekly export is off in Castle (the ready followed it)")
            await crossings.refresh()
            #expect(crossings.exportNotice, "rule 11's notice owed — durably")
            var spoken: [String] = []
            bootstrap.roadStanding?.speak = { spoken.append($0) }
            #expect(spoken.filter { $0 == ProtectionWords.exportTurnedOffNotice }.count == 1, "\(spoken)")
        }
    }

    /// LADDER ROUND 1, MINOR-3 — THE ARMED AND THE PRESSED LEAF ARE ONE INSTANCE within a composed road, and the planted
    /// failure answers the FIRST press with no prompt: a library in Castle under Touch ID (the item made at the press —
    /// a write never prompts); the next launch's ONE context arms its production custody leaf; the lobby's press (the
    /// auto-ask's road) is answered by the plant (`.failedOnExistingItem`, the leaf's `lastPress` too); the typed open on
    /// the same context carries that press to `assess`, which owes the re-arm — the interlude's card. Enabled where a
    /// finger is enrolled (a `.biometryCurrentSet` item needs one — `KeychainLeavesTests`' gate).
    @Test(.enabled(if: LAEnvironmentBiometryLeaf().biometry().enrolled, "needs a Touch ID finger enrolled on this Mac"))
    func minor3_thePlantedFailedPressOwesTheReArmThroughTheTypedOpen() async throws {
        let world = RoadWorld()
        world.biometry = FixedBiometryLeaf(.ready)
        defer { world.scope.purge() }
        let (session, words) = try await world.created()
        let exports = PlantedExportSwitch().road
        let shown = try #require(ProtectionCrossings.readCrossings(session, exportSwitch: exports)?.useCastle.openDoor)
        let typed = TypedSecrets(words: words, newPassphrase: Self.passphrase)
        #expect(ProtectionCrossings.preflight(session, door: .useCastle, shown: shown, typed: typed, exportSwitch: exports)
            == .ready)
        let crossed = await ProtectionCrossings.cross(
            session, door: .useCastle, typed: typed, gate: .touchID, exportSwitch: exports)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        // The next launch's one composed road: the plant armed on ITS custody leaf.
        let ctx = world.context()
        let leaf = try #require(ctx.system.custody as? KeychainCustodyLeaf)
        leaf.walkFailNextTouchIDPress()
        guard case .lobby(let lobby) = await ProtectionOpenRoad.route(ctx) else {
            Issue.record("Castle, no quiet road — the lobby")
            return
        }
        guard case .touchIDNotOpened(let press, _, let gone) = await ProtectionOpenRoad.pressTouchID(ctx, facts: lobby.facts)
        else {
            Issue.record("the plant answers the first press")
            return
        }
        #expect(press == .failedOnExistingItem && !gone && leaf.lastPress == .failedOnExistingItem)
        guard case .opened(let opened) = await ProtectionOpenRoad.openTyped(ctx, secret: .passphrase(Self.passphrase)) else {
            Issue.record("the passphrase opens the library")
            return
        }
        #expect(opened.report.acts.contains(.touchIDRearmQuestion), "\(opened.report.acts)")
        #expect(RoadInterlude.cards(opened.report) == [.rearm])
    }

    /// THE TOUCH ID WALK SWITCH (P-VX307-U2a-6) arms the PRODUCTION custody leaf — once per process, on a writing road
    /// only (the press it plants is the walk's: no test can press Touch ID).
    @Test func theTouchIDWalkSwitchArmsTheProductionLeafOncePerProcess() async throws {
        let world = RoadWorld()
        defer { world.scope.purge() }
        let env = [ProtectionWalkSwitch.touchIDKey: "fail"]
        #expect(!ProtectionWalkSwitch.failTouchIDOnceIfAsked(world.context(writes: false), environment: env))
        #expect(world.context().system.custody is KeychainCustodyLeaf)
        #expect(ProtectionWalkSwitch.failTouchIDOnceIfAsked(world.context(), environment: env))
        #expect(!ProtectionWalkSwitch.failTouchIDOnceIfAsked(world.context(), environment: env), "once per process")
    }

    /// A wrong word is refused BEFORE anything closes: the library stays open on the same session, nothing crossed.
    @Test func aWrongWordNeverTearsTheWindowDown() async throws {
        try await withRoadDependencies {
            let world = RoadWorld()
            Self.clearExports()
            defer {
                world.scope.purge()
                Self.clearExports()
            }
            let (created, _) = try await world.created()
            let bootstrap = world.bootstrap()
            await bootstrap.awaitOpen()
            guard case .ready = bootstrap.state, let session = bootstrap.roadSession else {
                Issue.record("the library opens: \(bootstrap.state)")
                return
            }
            let crossings = try #require(bootstrap.roadCrossings)
            await crossings.refresh()
            crossings.open(.useCastle)
            let confirm = try #require(crossings.confirm)
            let wrong = try RecoveryPhrase.generate().joined(separator: " ")
            await confirm.submit(passphrase: Self.passphrase, again: Self.passphrase, words: wrong)
            #expect(confirm.refusal == ProtectionWords.wordsDoNotOpen)
            #expect(crossings.confirm === confirm, "the confirm stays with its refusal")
            guard case .ready = bootstrap.state else {
                Issue.record("still ready: \(bootstrap.state)")
                return
            }
            #expect(bootstrap.roadSession === session, "never torn down")
            #expect(session.key == created.key && session.library.record?.mode == .standard)
        }
    }
}
