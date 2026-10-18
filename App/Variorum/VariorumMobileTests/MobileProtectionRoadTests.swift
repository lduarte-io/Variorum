//
//  MobileProtectionRoadTests.swift
//  VariorumMobileTests
//
//  VX-306 U3 piece 5 — THE PHONE OPENS ON THE NEW ROAD (`notes/plans/vx-306-castle-open-road.md` §2 U3 + its
//  addendum): the model pins the phone's compiled copy of the shared brains can run (a hoist is only real if both
//  sides run it). No keychain, no store: the one switch reads ON in the phone's Debug build (P-VX306-U1b-1
//  superseded); the biometry and device are named as the phone's own in the shared words (P-VX306-U3-8); the
//  once-shown words card's two columns and one button; the lobby model with an unlistable keychain (no facts — the
//  typed field and its reason, no biometry claimed) and its presses; the interlude's notice said once; rule 27's
//  after-open sheet condition read from the open's report.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@Suite("VX-306 U3 — the phone opens on the new road (the shared brains, the phone's copy)")
@MainActor
struct MobileProtectionRoadTests {
    /// The switch is compile-time and reads `debug` alone: this test bundle is the phone's Debug build.
    @Test func theOneSwitchIsOnInThePhonesDebugBuild() {
        #expect(ProtectionRoad.isDebugBuild && !ProtectionRoad.isMac)
        #expect(ProtectionRoad.newRoadIsLive == ProtectionRoad.live(debug: ProtectionRoad.isDebugBuild))
        #expect(ProtectionRoad.newRoadIsLive)
        #expect(!ProtectionRoad.live(debug: false), "a Release build runs today's road")
    }

    /// The shared words name the phone's biometry and the phone itself (the Mac's read "Touch ID" / "Mac" unchanged).
    @Test func theBiometryWordsAreThePhonesOwn() {
        #expect(ProtectionWords.touchIDButton == "Unlock with \(ProtectionCopy.biometryName)")
        #expect(ProtectionWords.touchIDNotSetUpOnThisMac
                == "\(ProtectionCopy.biometryName) isn't set up on this \(ProtectionCopy.deviceName).")
        #expect(ProtectionWords.touchIDNotSetUpForThisLibrary == "\(ProtectionCopy.biometryName) isn't set up for this library.")
        #expect(ProtectionCopy.deviceName == "iPhone" && ProtectionCopy.biometryName == "Face ID")
        #expect(!ProtectionWords.touchIDNotSetUpOnThisMac.contains("Mac") && !ProtectionWords.touchIDButton.contains("Touch ID"))
    }

    /// Rule 2's card: twelve words in two numbered columns, one button that forgets them and opens once.
    @Test func theWordsCardShowsTwoColumnsAndOneButton() throws {
        let words = try RecoveryPhrase.generate()
        var opened = 0
        let card = LibraryWordsCardModel(words: words) { opened += 1 }
        #expect(card.columns.map(\.count) == [6, 6])
        #expect(card.columns[1].first?.number == 7)
        card.iveWrittenThemDown()
        card.iveWrittenThemDown()
        #expect(opened == 1 && card.words.isEmpty, "said once, then forgotten")
    }

    /// A keychain that could not be listed: the typed field and its one-line reason, no biometry claimed; a typed
    /// press that opens nothing says why, and one that opens hands the session on.
    @Test func theLobbyWithNoFactsOffersBothTypedRoadsAndSaysWhy() async {
        var answers: [RoadAttempt] = [.refused(ProtectionWords.wordsDoNotOpen)]
        var openedSessions = 0
        let lobby = ProtectionLobbyModel(
            standing: RoadLobbyFacts(facts: nil, offeredTyped: []),
            typedRoad: { _ in answers.removeFirst() },
            touchIDRoad: { _ in .refused("never pressed") },
            refreshRoad: { RoadLobbyFacts(facts: nil, offeredTyped: []) },
            opened: { _ in openedSessions += 1 },
            recordMissing: {})
        #expect(lobby.face.keychainUnreadable && lobby.face.passphraseField && lobby.face.wordsRoad == .disclosure)
        #expect(!lobby.face.touchIDButton && lobby.face.touchIDLineWords == nil)
        await lobby.unlock(wordsText: "some words typed")
        #expect(lobby.message == ProtectionWords.wordsDoNotOpen)
        #expect(openedSessions == 0)
    }

    /// Rule 21's notice on the phone: said once, its one button, then the open goes on exactly once.
    @Test func theNoticeIsSaidOnceThenTheOpenGoesOn() {
        var finished = 0
        let interlude = RoadInterludeModel(
            cards: [.notice(LibraryNotice(kind: .differentLibrary))],
            useOffer: { _ in .failed }, receipt: { _ in }, finished: { finished += 1 })
        #expect(interlude.sentence == LibraryNotice.differentLibraryWords)
        interlude.ok()
        interlude.ok()
        #expect(finished == 1 && interlude.current == nil)
    }

    /// Rule 27 after a quiet open: the standing faces carry it (the phone's sheet reads them), the account road said
    /// only when named.
    @Test func ruleTwentySevenAfterAQuietOpenIsReadFromTheReport() {
        var report = RoadOpenReport()
        #expect(RoadStandingFaces.derive(report).noKeyFileAnywhere == nil)
        report.faults = [.noKeyFileAnywhere(NoKeyFileAnywhere(accountRoad: true))]
        let faces = RoadStandingFaces.derive(report)
        #expect(faces.noKeyFileAnywhere?.accountRoad == true)
    }
}
