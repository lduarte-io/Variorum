//
//  BookTitleTickerTests.swift
//  VariorumTests
//
//  **VX-1080 (T-2 as amended by R-1036-35) — a long note title in a book**:
//  at rest one line cut with "…"; the radio ticker ONLY under the pointer and
//  on the live note; one title moving at a time, the pointer's first; never
//  under Reduce Motion. The ticker is the wing label's (`WingMarquee`, its
//  `.ellipsis` rest — a parameter, never a sibling: `WingToolbarLabelTests`
//  stay unmodified and green as the parity proof). These pins hold the
//  arbiter and the plan's new gate; the motion itself is a walk clip.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VX-1080 — the long title rests with …, and one moves at a time")
struct BookTitleTickerTests {
    // MARK: - The arbiter (pure)

    @Test func thePointersTitleMovesFirst() {
        #expect(BookTitleTickerRule.mover(hovered: "a", live: "b", overflowing: ["a", "b"]) == "a",
                "the title under the pointer moves; the live note's waits")
    }

    @Test func theLiveNotesTitleMovesWhenThePointerIsElsewhere() {
        #expect(BookTitleTickerRule.mover(hovered: nil, live: "b", overflowing: ["a", "b"]) == "b")
        #expect(BookTitleTickerRule.mover(hovered: "a", live: "b", overflowing: ["b"]) == "b",
                "a title that FITS never claims the pointer — the live note's keeps moving")
    }

    @Test func aTitleThatFitsNeverMoves() {
        #expect(BookTitleTickerRule.mover(hovered: "a", live: "b", overflowing: []) == nil)
        #expect(BookTitleTickerRule.mover(hovered: nil, live: nil, overflowing: ["a"]) == nil,
                "no pointer, no live note: every title rests")
    }

    @Test func theModelHoldsOneMoverAndForgetsAReleasedRow() {
        let ticker = BookTitleTickerModel()
        ticker.title("a", overflows: true)
        ticker.title("b", overflows: true)
        #expect(ticker.isMoving("b", live: "b") && !ticker.isMoving("a", live: "b"))
        ticker.pointer("a", isOn: true)
        #expect(ticker.isMoving("a", live: "b") && !ticker.isMoving("b", live: "b"), "one at a time")
        ticker.pointer("a", isOn: false)
        #expect(ticker.isMoving("b", live: "b"), "the pointer left: the live note's moves again")
        ticker.pointer("a", isOn: true)
        ticker.forget("a")
        #expect(ticker.hovered == nil && !ticker.overflowing.contains("a"), "a released row lets go")
        ticker.pointer("b", isOn: false)
        #expect(ticker.hovered == nil, "a pointer leaving a card it was not on changes nothing")
    }

    // MARK: - The ticker's plan, gated

    @Test func anInactiveTitleIsStillAndSoIsReduceMotion() {
        #expect(WingMarqueePlan.plan(words: 300, viewport: 120, reduceMotion: false, active: false) == .still,
                "at rest: no clock at all")
        #expect(WingMarqueePlan.plan(words: 300, viewport: 120, reduceMotion: true, active: true) == .still,
                "never under Reduce Motion")
        #expect(WingMarqueePlan.plan(words: 300, viewport: 120, reduceMotion: false, active: true).loops)
        #expect(WingMarqueePlan.plan(words: 300, viewport: 120, reduceMotion: false)
                == WingMarqueePlan.plan(words: 300, viewport: 120, reduceMotion: false, active: true),
                "the wing label's call (no gate) is the active plan, byte for byte")
    }

    @Test func overflowIsThePlansOwnTest() {
        #expect(WingMarqueePlan.overflows(words: 120.4, viewport: 120) == false, "sub-point noise")
        #expect(WingMarqueePlan.overflows(words: 121, viewport: 120))
        #expect(WingMarqueePlan.overflows(words: 200, viewport: 0) == false, "unmeasured")
    }

    @Test func theTitlesRestIsTheEllipsisAndTheWingLabelsTheClip() {
        let title = WingMarquee(words: "a long title", maxWidth: .infinity, resting: .ellipsis, active: false)
        #expect(title.resting == .ellipsis && !title.active)
        let wing = WingMarquee(words: "in walk wing", maxWidth: 53)
        #expect(wing.resting == .clip && wing.active, "the wing label's defaults are its shipped arm")
    }
}
