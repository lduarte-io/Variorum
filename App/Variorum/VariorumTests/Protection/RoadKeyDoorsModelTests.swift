//
//  RoadKeyDoorsModelTests.swift
//  VariorumTests — VX-308 U3 piece 5: THE KEY DOORS' BRAIN (`RoadKeyDoorsModel`, `RoadKeyDoorConfirmModel`) over planted
//  roads — no keychain, no disk, no window (headless in the implementer's harness too). Each passphrase door's confirm
//  asks exactly its fields (Change: the current passphrase; both a new one typed twice; Castle's forgot road the words, or
//  Touch ID where its item stands), checks the words' shape before the road is asked, re-shows a changed door (VX-108),
//  presents through THE ONE PRESENTER (one protection sheet at a time — the crossings' and the account's share it), speaks
//  a landed act's receipt ONCE and re-reads; New Words has no confirm (its door is the look).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U3 — the key doors' models over planted roads")
@MainActor
struct RoadKeyDoorsModelTests {
    static func open(_ door: RoadKeyDoor, reset: RoadResetRoad? = nil, sentences: [String]? = nil) -> RoadKeyDoorOpen {
        RoadKeyDoorOpen(
            door: door, sentences: sentences ?? [ProtectionWords.keyDoorsLine], reset: reset, synced: false,
            spec: DoorSpec(requires: reset == nil ? .currentPassphrase : .plainConfirm))
    }

    static func faces(change: RoadKeyDoorFace = .open(open(.changePassphrase)),
                      reset: RoadKeyDoorFace = .open(open(.resetForgottenPassphrase, reset: .plainConfirm))) -> RoadKeyDoorFaces {
        RoadKeyDoorFaces(
            changePassphrase: change, newWords: .open(open(.newWords)), resetForgottenPassphrase: reset)
    }

    /// A planted world: the faces it reads, the presses it was handed, the receipts and re-reads.
    @MainActor
    final class World {
        var faces: RoadKeyDoorFaces? = RoadKeyDoorsModelTests.faces()
        var answer: RoadKeyDoorPress = .made(ProtectionWords.changePassphraseReceipt)
        var requests: [RoadKeyDoorRequest] = []
        var receipts: [String] = []
        var reads = 0
        var landings = 0
        let presenter = ProtectionSheetPresenter()

        lazy var model = RoadKeyDoorsModel(
            roads: RoadKeyDoorRoads(
                read: { [unowned self] in self.reads += 1; return self.faces },
                press: { [unowned self] request in self.requests.append(request); return self.answer },
                receipt: { [unowned self] in self.receipts.append($0) },
                landed: { [unowned self] in self.landings += 1 }),
            presenter: presenter)
    }

    /// Change: the current passphrase and a new one typed twice; a mismatch is refused before the road is asked; the
    /// landed act's receipt spoken ONCE, the sheet gone, the doors re-read.
    @Test func changeAsksTheCurrentAndANewOneTwiceAndSpeaksItsReceiptOnce() async throws {
        let world = World()
        await world.model.refresh()
        world.model.open(.changePassphrase)
        let confirm = try #require(world.model.confirm)
        #expect(confirm.asksCurrent && !confirm.asksWords && !confirm.offersTouchID)
        #expect(!confirm.canSubmit(current: "", new: "n", again: "n", words: ""), "the current passphrase is asked")
        #expect(confirm.canSubmit(current: "c", new: "n", again: "n", words: ""))
        await confirm.submit(current: "c", new: "a new passphrase", again: "a new passphrase!")
        #expect(confirm.refusal == ProtectionWords.setPassphraseMismatch && world.requests.isEmpty)
        await confirm.submit(current: " c", new: "a new passphrase ", again: "a new passphrase ")
        #expect(world.requests.count == 1)
        #expect(world.requests.first?.current == " c" && world.requests.first?.new == "a new passphrase ", "never trimmed")
        #expect(world.model.confirm == nil && world.presenter.sheet == nil, "landed: the sheet goes")
        #expect(world.receipts == [ProtectionWords.changePassphraseReceipt], "said once")
        for _ in 0..<50 where world.landings == 0 { await Task.yield() }
        #expect(world.reads >= 2 && world.landings == 1, "re-read after the landing")
    }

    /// Castle's forgot road: the words checked for shape first; Touch ID offered only where its item stands, a request
    /// marked as the press; a refusal stays in the sheet; a changed door is re-shown.
    @Test func castlesResetTakesTheWordsOrTouchIDAndAChangedDoorIsReShown() async throws {
        let world = World()
        world.faces = Self.faces(reset: .open(Self.open(.resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: true))))
        await world.model.refresh()
        world.model.open(.resetForgottenPassphrase)
        let confirm = try #require(world.model.confirm)
        #expect(!confirm.asksCurrent && confirm.asksWords && confirm.offersTouchID)
        #expect(!confirm.canSubmit(current: "", new: "n", again: "n", words: ""), "the words are asked")
        await confirm.submit(new: "n", again: "n", words: "one two")
        #expect(confirm.refusal == "There are twelve words — you entered 2." && world.requests.isEmpty)
        world.answer = .refused(ProtectionWords.resetPassphraseTouchIDNotConfirmed)
        await confirm.submitWithTouchID(new: "a new passphrase", again: "a new passphrase")
        #expect(world.requests.last?.touchID == true && world.requests.last?.words == nil)
        #expect(confirm.refusal == ProtectionWords.resetPassphraseTouchIDNotConfirmed && world.model.confirm != nil)
        let fresh = Self.open(.resetForgottenPassphrase, reset: .wordsOrTouchID(touchID: false))
        world.answer = .changed(fresh)
        let words = try RecoveryPhrase.generate()
        await confirm.submit(new: "a new passphrase", again: "a new passphrase", words: words.joined(separator: " "))
        #expect(world.requests.last?.words == words)
        #expect(confirm.door == fresh && confirm.refusal == ProtectionWords.crossingDoorChanged && !confirm.offersTouchID)
        confirm.cancel()
        #expect(world.model.confirm == nil && world.receipts.isEmpty, "Cancel: nothing written, nothing said")
    }

    /// THE ONE PRESENTER: a key door's confirm and another protection sheet never both stand; New Words opens no confirm;
    /// a hidden or refused door opens nothing.
    @Test func oneSheetAtATimeAndNewWordsHasNoConfirm() async throws {
        let world = World()
        await world.model.refresh()
        world.model.open(.newWords)
        #expect(world.presenter.sheet == nil, "New Words' door is the look")
        world.model.open(.changePassphrase)
        let first = try #require(world.model.confirm)
        world.model.open(.resetForgottenPassphrase)
        #expect(world.model.confirm === first, "one sheet at a time")
        first.cancel()
        world.faces = Self.faces(change: .hidden, reset: .refused(ProtectionWords.doorRefusedFollowOwed))
        await world.model.refresh()
        world.model.open(.changePassphrase)
        world.model.open(.resetForgottenPassphrase)
        #expect(world.presenter.sheet == nil)
        // A crossing's or an account sheet standing on the shared presenter holds the key doors back too.
        world.faces = Self.faces()
        await world.model.refresh()
        world.presenter.present(.signIn(ProtectionSignInRequest(closed: {})), on: .settings)
        world.model.open(.changePassphrase)
        #expect(world.model.confirm == nil)
    }
}
