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
            #expect(back.key != reopened.key)
            var said: [String] = []
            bootstrap.roadStanding?.speak = { said.append($0) }
            #expect(said == [ProtectionWords.leftCastleReceipt])
        }
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
