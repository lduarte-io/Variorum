//
//  VM56MacWingScopePinTests.swift
//  VariorumTests
//
//  VM-56 (the VM-55 run, batch 1) — THE MAC IS UNCHANGED. `WingState`'s
//  read scope lost its platform fork (the phone now reads the current wing
//  too); on the Mac it answers exactly what it always did — the current
//  wing, following every switch and the dead-wing return. And VM-60 moved
//  Settings ▸ Tags' header sentence to `Shared/WingWords`; the Mac's
//  `TagManagerCopy.title` forwards byte-identically.
//

import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VM-56 — the Mac's wing read scope and tag header are unchanged")
struct VM56MacWingScopePinTests {
    @Test func theMacsReadScopeIsStillTheCurrentWing() {
        let state = WingState()
        #expect(state.readScope == "")
        state.switchTo("w1")
        #expect(state.readScope == "w1")
        state.revalidate { $0.isEmpty }
        #expect(state.readScope == "", "a dead wing reads Home")
        #expect(WingState(currentID: "w2").readScope == "w2")
    }

    @Test func theTagHeaderForwardsByteIdentically() {
        #expect(TagManagerCopy.title(wingName: "Home") == "Tags \u{2014} in Home")
        #expect(TagManagerCopy.title(wingName: "Garden") == WingWords.tagsTitle(wingName: "Garden"))
    }
}
