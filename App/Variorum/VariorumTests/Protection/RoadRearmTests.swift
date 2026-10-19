//
//  RoadRearmTests.swift
//  VariorumTests — VX-307 U2a piece 6: VX-310's RE-ARM QUESTION (the design's §3.10) — the interlude owes its card only
//  when the open's report owes `.touchIDRearmQuestion` (assess's word: a press failed on an item that exists, then a
//  typed secret opened the library); the card's two answers run `answerTouchIDRearm` through the session (yes → a new
//  item at this press; no → Always ask, the stale item gone either way; no item → nothing written); an answer that could
//  not be written never strands her in the lobby's room. And the walk switch that plants one failed press for stage 11.
//  Planted leaves, no keychain — also runs headless in the implementer's SwiftPM harness. (The chain over a REAL failed
//  press — the lobby's press, the typed open, the card — is the walk's: no test can press Touch ID.)
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2a — VX-310's re-arm question (the interlude's card, planted)")
@MainActor
struct RoadRearmTests {
    /// The card is owed exactly when assess owes the question — after the notice and the offer, once per open.
    @Test func theCardIsOwedOnlyWhenTheOpenOwesTheQuestion() async throws {
        let road = PlantedRoad()
        let (session, _) = try await road.created()
        #expect(RoadInterlude.cards(session.report).isEmpty)
        var report = session.report
        report.acts = [.touchIDRearmQuestion]
        #expect(RoadInterlude.cards(report) == [.rearm])
        #expect(RoadInterlude.sentence(.rearm, day: { _ in "" }) == ProtectionWords.rearmQuestion)
        session.report = report
        #expect(session.owesInterlude, "a writing open owes the card")
        session.markInterludeShown()
        #expect(!session.owesInterlude, "once per open")
        // With rule 21's notice and offer, the question comes last.
        report.notice = LibraryNotice(kind: .differentLibrary)
        #expect(RoadInterlude.cards(report).last == .rearm && RoadInterlude.cards(report).count == 2)
    }

    /// The answers through the model: yes / no reach the road and the open goes on; an answer that could not be
    /// written says so and offers OK — the open goes on with nothing decided (the question returns after the next
    /// failed press).
    @Test func theCardsAnswersReachTheRoadAndNeverStrandHer() async {
        var answers: [Bool] = []
        var finished = 0
        var written = true
        let model = RoadInterludeModel(
            cards: [.rearm], useOffer: { _ in .failed },
            answerRearm: { yes in
                answers.append(yes)
                return written
            },
            receipt: { _ in }, finished: { finished += 1 })
        model.ok()
        #expect(finished == 0, "OK is no answer to the question")
        await model.rearm(yes: true)
        #expect(answers == [true] && finished == 1 && model.current == nil)

        written = false
        let failing = RoadInterludeModel(
            cards: [.rearm], useOffer: { _ in .failed },
            answerRearm: { yes in
                answers.append(yes)
                return written
            },
            receipt: { _ in }, finished: { finished += 1 })
        await failing.rearm(yes: false)
        #expect(failing.rearmFailed && failing.message == ProtectionWords.rearmFailed && failing.current == .rearm)
        await failing.rearm(yes: true)
        #expect(answers == [true, false], "no second answer once it failed")
        failing.ok()
        #expect(finished == 2 && failing.current == nil && !failing.rearmFailed)
    }

    /// `answerTouchIDRearm` through the session (Castle, a Touch ID item on this Mac): yes re-makes the item at this
    /// press; no deletes it and records Always ask; with no item there is no question — nothing written.
    @Test func theAnswersRunTheCoresReArmThroughTheSession() async throws {
        let road = PlantedRoad()
        road.biometry = .ready
        let (session, _) = try await Crossing.inCastle(road)
        #expect(await ProtectionCrossings.changeGate(session, to: .touchID, passphrase: Crossing.passphrase) == .changed)
        #expect(Crossing.items(road, .touchid) == [session.library.fingerprint])
        let writesBefore = road.custody.writes.count
        #expect(await ProtectionCrossings.answerRearm(session, yes: true))
        #expect(Array(road.custody.writes.dropFirst(writesBefore)) == ["delete touchid", "write touchid"],
                "the stale item goes and a new one is made at this press")
        #expect(Crossing.items(road, .touchid) == [session.library.fingerprint])
        #expect(session.library.section.settings.gateStyle == .touchID)
        #expect(await ProtectionCrossings.answerRearm(session, yes: false))
        #expect(Crossing.items(road, .touchid).isEmpty, "no — the item goes")
        #expect(session.library.section.settings.gateStyle == .alwaysAsk)
        let writesAfter = road.custody.writes.count
        #expect(await ProtectionCrossings.answerRearm(session, yes: true) == false, "no item — no question")
        #expect(road.custody.writes.count == writesAfter)
    }

    /// THE WALK SWITCH (DEBUG walk machinery, P-VX306-U1b-9's fences): it parses only its word, and never arms on a
    /// read-only road or a custody leaf that is not the production one.
    @Test func theTouchIDWalkSwitchParsesItsWordAndKeepsItsFences() async throws {
        #expect(ProtectionWalkSwitch.parseTouchID("fail") && ProtectionWalkSwitch.parseTouchID(" FAIL "))
        #expect(!ProtectionWalkSwitch.parseTouchID("silent") && !ProtectionWalkSwitch.parseTouchID(nil))
        let road = PlantedRoad()
        _ = try await road.created()
        let env = [ProtectionWalkSwitch.touchIDKey: "fail"]
        #expect(!ProtectionWalkSwitch.failTouchIDOnceIfAsked(road.context(writes: false), environment: env))
        #expect(!ProtectionWalkSwitch.failTouchIDOnceIfAsked(road.context(), environment: env),
                "a planted custody leaf has no press to fail")
    }
}
