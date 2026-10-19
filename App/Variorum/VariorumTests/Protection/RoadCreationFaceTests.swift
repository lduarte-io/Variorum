//
//  RoadCreationFaceTests.swift
//  VariorumTests — VX-307 U2b piece 2 (VX-412; `notes/CastleRules.md` rules 2 and 3 as amended, her words in
//  `notes/plans/vx-307-castle-crossings.md` §3a): THE CREATION-TIME WORDS CARD RETIRES ON THE MAC. "I don't want the
//  new library to show those words at creation before the bookcase and before the tour offer" — the first open is the
//  Bookcase and the quick entry with nothing in front of them. The phone keeps its card this phase (P-VX307-U2b-0).
//  Pure (runs headless in the implementer's harness); the bootstrap's flip is pinned by the Mac route suites
//  (`ProtectionRoadRouteTests.aFreshSlotCreatesAndOpensWithNothingInFrontThenReopensQuietly` and the missing face's
//  two, `ProtectionFacesRouteTests.rule27sLobbyStartsANewLibraryThroughTheBootstrap` — each red on the pre-VX-412 tree,
//  whose state there was `.newLibraryWords`).
//

import Foundation
import Testing

@testable import Variorum

@Suite("VX-307 U2b — the creation-time words card retires on the Mac")
struct RoadCreationFaceTests {
    @Test func theMacShowsNoWordsBeforeTheFirstScreenAndThePhoneKeepsItsCardThisPhase() {
        #expect(!ProtectionRoad.wordsCardAtCreation(mac: true), "the Mac: nothing in front of the first screen")
        #expect(ProtectionRoad.wordsCardAtCreation(mac: false), "the phone keeps its creation card (P-VX307-U2b-0)")
        #expect(ProtectionRoad.showsWordsAtCreation == !ProtectionRoad.isMac, "this build reads its platform's rule")
    }
}
