//
//  MobileRefusalSeamTests.swift
//  VariorumMobileTests
//
//  VM-277 (the VM-260 run, batch 1b; A-260-4 (a) and (d)) — **THE SEAM'S TWO
//  NEW LINES, under the phone's placement.** A refusal may carry its composer's
//  short form (`refuse(headline:sentence:)` → `Item.refusalHeadline`), the
//  item's `text` staying the whole sentence for every reader; and an item may be
//  HELD while she reads its reason (`holdForReading(_:)`) — a lifetime door, not
//  a kind: the slot rule and the kinds are untouched (the routing table pins in
//  `MobileMessageLineTests` hold). The Mac takes neither
//  (`VM61MacStatusSeamPinTests`' scan). Both doors are new, so these pins are
//  the fix's own (not part of a red-on-old run).
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
private func eventually(_ turns: Int = 100, _ condition: @MainActor () -> Bool) async -> Bool {
    for _ in 0..<turns {
        if condition() { return true }
        try? await Task.sleep(for: .milliseconds(10))
    }
    return condition()
}

@MainActor
@Suite("VM-277 — the seam's short form and reading hold")
struct MobileRefusalSeamTests {
    @Test func aRefusalCarriesItsHeadlineBesideTheWholeSentence() throws {
        let status = StatusCenter()
        status.refuse(headline: "  Can't join these blocks.  ", sentence: "  The whole sentence, with its road.  ")
        let line = try #require(status.current)
        #expect(line.kind == .refusal, "a refusal's class — always drawn")
        #expect(line.text == "The whole sentence, with its road.", "text is the whole sentence, trimmed")
        #expect(line.refusalHeadline == "Can't join these blocks.")
        #expect(!line.isDirection)

        status.refuse(headline: "   ", sentence: "Words.")
        #expect(status.current?.refusalHeadline == nil, "a blank headline is none")
        status.refuse(headline: nil, sentence: "More words.")
        #expect(status.current?.refusalHeadline == nil)
        let before = status.current?.id
        status.refuse(headline: "Short.", sentence: "   ")
        #expect(status.current?.id == before, "no sentence says nothing — a headline alone never speaks")

        // Every other door's item carries none.
        status.refuse("Plain.")
        #expect(status.current?.refusalHeadline == nil)
        status.direct("A direction.")
        #expect(status.current?.refusalHeadline == nil)
    }

    @Test func holdingKeepsTheItemShowingPastItsClock() async {
        let status = StatusCenter()
        status.dismissAfter = .milliseconds(40)
        status.refuse(headline: "Can't.", sentence: "Can't, and here is why.")
        let held = status.current?.id
        status.holdForReading(held ?? UUID())
        try? await Task.sleep(for: .milliseconds(200))
        #expect(status.current?.id == held, "held while she reads — past its clock")
        status.clear()
        #expect(status.current == nil, "her close (or leaving the note) still takes it")
    }

    @Test func onlyTheShowingItemIsHeldAndANewerMessageKeepsItsOwnClock() async {
        let status = StatusCenter()
        status.dismissAfter = .milliseconds(40)
        status.refuse("First.")
        let first = status.current?.id
        status.refuse("Second.")
        status.holdForReading(first ?? UUID())
        #expect(await eventually { status.current == nil }, "an older id holds nothing — the newer one fades")

        status.refuse("Held.")
        status.holdForReading(status.current?.id ?? UUID())
        status.refuse("Newer.")
        #expect(status.current?.text == "Newer.", "a newer message replaces a held one")
        #expect(await eventually { status.current == nil }, "and keeps its own clock")
    }
}
