//
//  RoadJoinFollowModelTests.swift
//  VariorumTests — VX-308 U2 piece 4: THE JOIN'S AND THE FOLLOW'S CONFIRM over PLANTED roads (pure — no keychain, no disk;
//  also runs headless in the implementer's SwiftPM harness): ONE secret (rule 14 — the passphrase, the words, or both;
//  the words' shape checked before the road is asked), the gate choice into Castle carried to the road, the follow out
//  typing nothing; and THE WORDS MOMENT (rule 7, R-U2-5): a join whose words were replaced keeps its sheet — the words she
//  TYPED shown over the one look idiom under rule 7's sentence, closed behind her warning, its Copy through the injected
//  words road; the passphrase typed, the notice alone — while the act's receipt is spoken ONCE at the landing and the pane
//  re-read; the sheet goes when the moment closes (a window closing under it closes it too).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
enum PlantedJoin {
    static func join(_ plan: JoinPlan = .sameMode, gate: RoadGateChoice? = nil) -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: .turnOnSync, ask: .oneSecret, newPassphrase: false,
            sentences: [ProtectionWords.joinLead, ProtectionWords.onePairAtATime],
            spec: DoorSpec(requires: .oneSecret, rekeys: plan != .sameMode, synced: true, join: plan), gate: gate)
    }

    static func follow(_ kind: FollowKind, gate: RoadGateChoice? = nil) -> RoadAccountDoorOpen {
        RoadAccountDoorOpen(
            door: .follow, ask: kind == .intoStandard ? .nothing : .oneSecret, newPassphrase: false,
            sentences: [ProtectionWords.followAsk(kind)],
            spec: DoorSpec(requires: kind == .intoStandard ? .none : .oneSecret, rekeys: true, synced: true), gate: gate,
            follow: kind)
    }
}

@Suite("VX-308 U2 — the join's and the follow's confirm over planted roads")
@MainActor
struct RoadJoinFollowModelTests {
    static let words = (try? RecoveryPhrase.generate()) ?? []
    static var wordsText: String { words.joined(separator: " ") }

    /// ONE secret (rule 14): either field enables the button; the passphrase alone, the words alone, or both ride exactly
    /// as typed; a mistyped word list is refused before the road is asked anything.
    @Test func oneSecretRidesExactlyAsTyped() async throws {
        let planted = PlantedAccountRoads()
        planted.press = .refused("no")
        let confirm = RoadAccountConfirmModel(door: PlantedJoin.join(), act: planted.roads.press) { _ in }
        #expect(!confirm.canSubmit(passphrase: "", again: "", words: ""))
        #expect(confirm.canSubmit(passphrase: " p ", again: "", words: "") && confirm.canSubmit(passphrase: "", again: "",
                                                                                                    words: Self.wordsText))
        await confirm.submit(passphrase: "", words: "one two three")
        #expect(confirm.refusal == ProtectionWords.wordsWrongCount(3) && planted.requests.isEmpty)
        await confirm.submit(passphrase: " p ")
        #expect(planted.requests.last?.typed.passphrase == " p " && planted.requests.last?.typed.words == nil)
        await confirm.submit(words: "  " + Self.wordsText + "\n")
        #expect(planted.requests.last?.typed.passphrase == nil && planted.requests.last?.typed.words == Self.words)
        await confirm.submit(passphrase: "p", words: Self.wordsText)
        #expect(planted.requests.last?.typed.passphrase == "p" && planted.requests.last?.typed.words == Self.words)
        #expect(planted.requests.allSatisfy { $0.typed.newPassphrase == nil && !$0.typed.wordsAreNew }, "never a new secret")
    }

    /// The gate into Castle: the door's preselection, her change carried to the road; no gate where the door has none; a
    /// door re-shown where Touch ID can't work any more falls back to Always ask.
    @Test func theGateChoiceRidesIntoCastle() async throws {
        let planted = PlantedAccountRoads()
        planted.press = .refused("no")
        let touchID = RoadGateChoice(touchIDAvailable: true, preselected: .touchID)
        let follow = RoadAccountConfirmModel(door: PlantedJoin.follow(.intoCastle, gate: touchID), act: planted.roads.press) { _ in }
        #expect(follow.gate == .touchID)
        await follow.submit(passphrase: "p")
        #expect(planted.requests.last?.gate == .touchID)
        follow.gate = .alwaysAsk
        await follow.submit(passphrase: "p")
        #expect(planted.requests.last?.gate == .alwaysAsk)
        let same = RoadAccountConfirmModel(door: PlantedJoin.join(), act: planted.roads.press) { _ in }
        await same.submit(passphrase: "p")
        #expect(planted.requests.last?.gate == nil, "no gate where the door asks none")
        planted.press = .changed(PlantedJoin.follow(.intoCastle, gate: RoadGateChoice(touchIDAvailable: false,
                                                                                         preselected: .alwaysAsk)))
        let changing = RoadAccountConfirmModel(door: PlantedJoin.follow(.intoCastle, gate: touchID), act: planted.roads.press) { _ in }
        await changing.submit(passphrase: "p")
        #expect(changing.gate == .alwaysAsk && changing.refusal == ProtectionWords.crossingDoorChanged)
    }

    /// The follow out of Castle types nothing (rule 12 — quietly).
    @Test func theFollowOutTypesNothing() async throws {
        let planted = PlantedAccountRoads()
        var finished: [RoadAccountPress?] = []
        planted.press = .made(receipt: nil)
        let out = RoadAccountConfirmModel(door: PlantedJoin.follow(.intoStandard), act: planted.roads.press) { finished.append($0) }
        #expect(out.canSubmit(passphrase: "", again: "", words: ""))
        await out.submit()
        let sent = try #require(planted.requests.last)
        #expect(sent.typed.passphrase == nil && sent.typed.words == nil && sent.gate == nil)
        #expect(finished == [.made(receipt: nil)] && out.moment == nil, "no moment for a follow")
    }

    /// THE WORDS MOMENT, the words typed (rule 7 — "here they are"): through the section's model, the act's receipt is
    /// spoken ONCE at the landing and the pane re-read while the sheet stays; the typed words show over the one look idiom
    /// (Copy through the injected road); the close behind her warning forgets them and the sheet goes.
    @Test func aJoinWhoseWordsWereReplacedShowsTheTypedWordsOnce() async throws {
        let planted = PlantedAccountRoads()
        planted.faces = PlantedAccountRoads.faces(turnOnSync: .open(PlantedJoin.join()))
        planted.press = .made(receipt: "joined", wordsReplaced: true)
        var copied: [[String]] = []
        var roads = planted.roads
        roads.copyWords = { copied.append($0) }
        let presenter = ProtectionSheetPresenter()
        let model = RoadAccountModel(roads: roads, presenter: presenter)
        await model.refresh()
        model.open(.turnOnSync)
        let confirm = try #require(model.confirm)
        await confirm.submit(words: Self.wordsText)
        guard case .shown(let look)? = confirm.moment else {
            Issue.record("the words moment stands with the typed words")
            return
        }
        #expect(look.phase == .shown && look.words == Self.words && !look.saysRuleSix)
        #expect(presenter.sheet(for: .settings)?.id == confirm.id, "the sheet stays for the moment")
        #expect(planted.spoken == ["joined"], "the receipt at the landing, once")
        for _ in 0..<10_000 where planted.landings == 0 { await Task.yield() }
        #expect(planted.landings == 1)
        look.copy()
        #expect(copied == [Self.words], "the one words road")
        look.writtenDown()
        #expect(look.phase == .warning && confirm.moment != nil, "her warning first")
        look.close()
        #expect(confirm.moment == nil && presenter.sheet == nil && look.words.isEmpty, "forgotten; the sheet goes")
        #expect(planted.spoken == ["joined"] && planted.landings == 1, "never said twice")
    }

    /// The PASSPHRASE typed (P-VX378-U2-3 (a)): the moment is the notice alone — nothing to show; OK closes it.
    @Test func aPassphraseTypedJoinSaysTheWordsWereReplacedWithoutShowingThem() async throws {
        let planted = PlantedAccountRoads()
        planted.press = .made(receipt: "joined", wordsReplaced: true)
        var finished: [RoadAccountPress?] = []
        var landed: [RoadAccountPress] = []
        let confirm = RoadAccountConfirmModel(
            door: PlantedJoin.join(.entersCastle), act: planted.roads.press, landed: { landed.append($0) }) {
            finished.append($0)
        }
        await confirm.submit(passphrase: "p")
        guard case .notShown? = confirm.moment else {
            Issue.record("the notice-only moment")
            return
        }
        #expect(landed == [.made(receipt: "joined", wordsReplaced: true)] && finished.isEmpty)
        confirm.closeMoment()
        #expect(confirm.moment == nil && finished == [.made(receipt: "joined", wordsReplaced: true)])
    }

    /// No moment where none is owed (the words were the library's already; turning sync on first — rule 7's hand-up); a
    /// window closing under a standing moment closes it (the act had landed — never a "nothing written" cancel).
    @Test func theMomentOnlyWhereOwedAndAClosingWindowClosesIt() async throws {
        let planted = PlantedAccountRoads()
        var finished: [RoadAccountPress?] = []
        planted.press = .made(receipt: "joined", wordsReplaced: false)
        let kept = RoadAccountConfirmModel(door: PlantedJoin.join(), act: planted.roads.press) { finished.append($0) }
        await kept.submit(words: Self.wordsText)
        #expect(kept.moment == nil && finished.count == 1)
        planted.press = .made(receipt: ProtectionWords.turnOnSyncReceipt, wordsReplaced: true)
        let setUp = RoadAccountConfirmModel(door: PlantedAccountRoads.setUp(), act: planted.roads.press) { finished.append($0) }
        await setUp.submit(passphrase: "p", again: "p", words: Self.wordsText)
        #expect(setUp.moment == nil && finished.count == 2, "rule 7's hand-up shows nothing")
        planted.press = .made(receipt: "joined", wordsReplaced: true)
        let closing = RoadAccountConfirmModel(door: PlantedJoin.join(), act: planted.roads.press) { finished.append($0) }
        await closing.submit(words: Self.wordsText)
        #expect(closing.moment != nil)
        closing.cancel()
        #expect(closing.moment == nil && finished.last == .made(receipt: "joined", wordsReplaced: true))
    }
}
