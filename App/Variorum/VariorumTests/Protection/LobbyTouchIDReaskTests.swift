//
//  LobbyTouchIDReaskTests.swift
//  VariorumTests — VX-529 unit 3, the rider VX-533 (her report on her Air, 2026-10-24: "i just didn't answer the prompt
//  fast enough. i wanted to be able to re trigger it." — the SYSTEM sheet's own fade, "it gets pale and then
//  disappears"): A PRESS THE SYSTEM ENDED MUST LEAVE THE BUTTON STANDING, AND A RE-PRESS MUST GENUINELY RE-ASK.
//  THE TRACE (the run record's UNIT 3 — LIVE STATUS, VX-533):
//    - every press reads through a FRESH `LAContext` (`KeychainCustodyLeaf.readTouchID` builds one per read, line 156 as
//      traced) — no press ever reuses a dead context, so a standing button's re-press always reaches a new prompt
//      (pinned here by source, and by the planted leaf's read count);
//    - the button falls only when the press reports `itemGone` — and `ProtectionOpenRoad.pressTouchID` inferred "gone"
//      from "no press recorded" (`lastPress == nil`), which is ALSO what a press whose keychain read THREW leaves behind
//      (any status the leaf's arms don't name: the read propagates, `lastPress` is never set). The existence probe had
//      found the item an instant before, so the button fell over an item that is there — the only way back was a
//      relaunch or a lock (her workaround).
//  RED on the pre-fix tree (the button gone after the failed press; the re-press reaches no road). The model wired to the
//  REAL press road over the planted leaves (no keychain, no biometry hardware); also runs headless in the harness.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-529 unit 3 — VX-533: the lobby's Touch ID button stands after a press the system ended (planted, no keychain)")
@MainActor
struct LobbyTouchIDReaskTests {
    /// A Castle library with Touch ID on a Mac with a finger enrolled, at its lobby, the model wired to the real roads.
    static func castleTouchIDLobby() async throws -> (road: PlantedRoad, model: ProtectionLobbyModel,
                                                     opened: () -> ProtectionRoadSession?, fingerprint: String) {
        let road = PlantedRoad()
        road.biometry = .ready
        let (created, words) = try await road.created()
        let crossed = try await Crossing.press(
            created, .useCastle, typed: TypedSecrets(words: words, newPassphrase: Crossing.passphrase), gate: .touchID)
        #expect(crossed.outcome == .made(.useCastle, exportTurnedOff: false))
        let fingerprint = try #require(Crossing.items(road, .touchid).first, "the Touch ID item made at the press")
        let ctx = road.context()
        let lobby = ProtectionRoadLock.lobby(ctx)
        #expect(ProtectionLobbyFace.derive(lobby).touchIDButton, "the lobby offers Touch ID")
        final class Box { var session: ProtectionRoadSession? }
        let box = Box()
        let model = ProtectionLobbyModel(
            standing: lobby,
            typedRoad: { await ProtectionOpenRoad.openTyped(ctx, secret: $0) },
            touchIDRoad: { await ProtectionOpenRoad.pressTouchID(ctx, facts: $0) },
            refreshRoad: { ProtectionOpenRoad.lobbyFacts(ctx) },
            opened: { box.session = $0 },
            recordMissing: {})
        return (road, model, { box.session }, fingerprint)
    }

    /// **Her report (red on old).** The automatic ask's read ends without the item read (the planted twin of the system
    /// sheet's own ending — the read throws a status no arm names): the library stays locked, NOTHING is written, and the
    /// button STANDS. Her re-press reaches the road again, reads the item afresh, and opens the library.
    @Test func aPressTheSystemEndedLeavesTheButtonAndARePressReasks() async throws {
        let (road, model, opened, fingerprint) = try await Self.castleTouchIDLobby()
        road.custody.unreadable.insert(fingerprint)
        let writesBefore = road.custody.writes
        let readsBefore = road.custody.reads.filter { $0 == .touchid }.count
        await model.autoAskIfDue(appIsActive: true)
        #expect(model.pressesRun == 1 && opened() == nil, "the automatic ask ran and opened nothing")
        #expect(road.custody.writes == writesBefore, "a failed press writes nothing")
        #expect(model.face.touchIDButton, "the button stands — the item is there; only a press that found it gone drops it")

        road.custody.unreadable.remove(fingerprint)  // she answers the second prompt
        await model.pressTouchID()
        #expect(model.pressesRun == 2, "her re-press reached the road")
        #expect(road.custody.reads.filter { $0 == .touchid }.count == readsBefore + 2, "each press its own read")
        #expect(opened()?.library.record?.mode == .castle, "the re-press opened the library")
    }

    /// A guard (green on both sides): a press whose read finds NO item — the one road that drops the button — still drops
    /// it (the face then says Touch ID isn't set up for this library).
    @Test func aPressThatFindsTheItemGoneStillDropsTheButton() async throws {
        let (road, model, opened, fingerprint) = try await Self.castleTouchIDLobby()
        for fact in road.custody.items.keys where fact.fingerprint == fingerprint && fact.itemClass == .touchid {
            road.custody.items[fact] = nil
        }
        await model.pressTouchID()
        #expect(opened() == nil && !model.face.touchIDButton, "the item is gone — the button with it")
    }

    /// A guard (green on both sides) — the trace's other half, by source: every Touch ID read builds its OWN `LAContext`
    /// (a re-press never lands on a dead context).
    @Test func everyTouchIDReadBuildsAFreshContext() throws {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Shared/Protection/KeychainCustodyLeaf.swift")
        let source = try String(contentsOf: url, encoding: .utf8)
        let start = try #require(source.range(of: "private func readTouchID(fingerprint: String)"))
        let end = try #require(source.range(of: "func writeCustody(", range: start.upperBound..<source.endIndex))
        let body = String(source[start.upperBound..<end.lowerBound])
        #expect(body.contains("let context = LAContext()"), "the press's context is minted inside the read")
    }
}
