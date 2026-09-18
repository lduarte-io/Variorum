//
//  LandingAuthorityTests.swift
//  VariorumTests
//
//  **Phase 13u2b UNIT 2 — the landing discipline, pinned WITHOUT A WINDOW.**
//
//  This is the hoist's own dividend. Until this unit the aim/hold/quiet/
//  correct loop existed only inside two SwiftUI view bodies, so the only way
//  to ask it a question was to mount a book, pump a run loop and read a
//  geometry oracle — which is why every one of its rules was argued from
//  traces rather than asserted. `LandingSettle.decide` is a pure function
//  now, and these are its truth tables.
//
//  The second half pins the SIGNPOST's one promise: the line that ships in
//  Release carries numbers and a closed vocabulary, and NOTHING a person
//  wrote. It is asserted against a column whose every row id is prose.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The one landing authority (13u2b UNIT 2)")
struct LandingAuthorityTests {
    private let outline = LandingPolicy.bookOutline
    private let flow = LandingPolicy.readingFlow

    /// A decision's wait, in seconds — compared with a tolerance, because
    /// every one of them is a subtraction of two doubles and `1.0 - 0.3` is
    /// not the literal `0.7`.
    private func waited(_ decision: LandingDecision) -> TimeInterval? {
        if case .wait(let delay) = decision { return delay }
        return nil
    }
    private func isNear(_ value: TimeInterval?, _ expected: TimeInterval) -> Bool {
        guard let value else { return false }
        return abs(value - expected) < 1e-9
    }

    /// The two shipped policies are the two surfaces' shipped numbers — the
    /// hoist moved their address, not their value. (Stated as a pin because
    /// "byte-identical" is this unit's own promise, and a promise nothing
    /// asserts is a comment.)
    @Test func theTwoPoliciesCarryTheSurfacesShippedNumbers() {
        #expect(outline.tolerance == 2)
        #expect(flow.tolerance == 4)
        #expect(outline.settleInterval == 0.25 && flow.settleInterval == 0.25)
        #expect(outline.minimumHold == 1.0 && flow.minimumHold == 1.0)
        #expect(outline.maxWait == 0.6 && flow.maxWait == 0.6)
        #expect(outline.timeBudget == 4 && flow.timeBudget == 4)
        #expect(outline.correctionBudget == 40, "the Outline's fence is generous — the watchdog is the real one")
        #expect(flow.correctionBudget == 6, "the flow's is small, so each correction must be issued from quiet")
        #expect(BookView.landingTolerance == outline.tolerance)
        #expect(BookView.landingTimeBudget == outline.timeBudget)
        #expect(BookView.landingMinimumHold == outline.minimumHold)
        #expect(BookView.landingMaxWait == outline.maxWait)
        #expect(BookView.landingSettleInterval == outline.settleInterval)
        #expect(ReadingFlowView.landingTolerance == flow.tolerance)
    }

    /// **At the top, past the hold ⇒ DONE.** Inside the hold it waits out
    /// exactly the remainder — the rows around a landing load their heights
    /// asynchronously, and a quiet interval alone races that load.
    @Test func atTheTopItFinishesOnlyOnceTheHoldIsOver() {
        #expect(LandingSettle.decide(
            top: 0, corrections: 0, elapsed: 1.2, mayFinish: true, policy: outline)
            == .done(top: 0))
        #expect(LandingSettle.decide(
            top: 1.5, corrections: 3, elapsed: 4.5, mayFinish: true, policy: outline)
            == .done(top: 1.5), "within tolerance, and the watchdog never overrules a landing that ARRIVED")
        #expect(isNear(waited(LandingSettle.decide(
            top: 0, corrections: 0, elapsed: 0.3, mayFinish: true, policy: outline)), 0.7),
            "the rest of the hold, to the millisecond")
        #expect(LandingSettle.decide(
            top: -3, corrections: 0, elapsed: 1.2, mayFinish: true, policy: outline)
            != .done(top: -3), "3 pt is outside the Outline's 2-pt tolerance…")
        #expect(LandingSettle.decide(
            top: -3, corrections: 0, elapsed: 1.2, mayFinish: true, policy: flow)
            == .done(top: -3), "…and inside the flow's 4-pt one (ladder R2-7)")
    }

    /// **The surface's veto is geometry, never a clock** (the flow's "every
    /// near story above the target has SAID it settled"): at the top, past the
    /// hold, and still blocked ⇒ it looks again after the quiet interval, for
    /// as long as the surface says so.
    @Test func aSurfaceThatSaysItIsNotReadyHoldsTheLandingOpen() {
        #expect(isNear(waited(LandingSettle.decide(
            top: 0, corrections: 0, elapsed: 2.0, mayFinish: false, policy: flow)),
            flow.settleInterval))
        #expect(isNear(waited(LandingSettle.decide(
            top: 0, corrections: 0, elapsed: 0.4, mayFinish: false, policy: flow)), 0.6),
            "inside the hold it is the hold that is being waited out")
        // …and the watchdog still ends it, veto or no veto: a target AT the
        // top is done, so the only way past the budget is to be off it.
        #expect(LandingSettle.decide(
            top: 900, corrections: 0, elapsed: 4.5, mayFinish: false, policy: flow)
            == .giveUp(top: 900))
    }

    /// **Off the top ⇒ ONE correction, then a pause whose length is the
    /// surface's own policy.** The Outline's corrections are cheap and many,
    /// so it looks again after the quiet interval; the flow's are few and each
    /// must be issued from quiet (row 100: a correction made during a content
    /// storm is undone by the ScrollView's own offset restore), so it waits
    /// out the hold.
    @Test func offTheTopItCorrectsAndThenPausesByItsOwnPace() {
        #expect(LandingSettle.decide(
            top: -73, corrections: 0, elapsed: 0.3, mayFinish: true, policy: outline) == .correct)
        #expect(outline.pause(elapsed: 0.3) == 0.25, "the quiet interval, whatever the elapsed time")
        #expect(outline.pause(elapsed: 3.0) == 0.25)
        #expect(isNear(flow.pause(elapsed: 0.3), 0.7), "the rest of the hold…")
        #expect(flow.pause(elapsed: 3.0) == 0.25, "…floored at the quiet interval once it is over")
    }

    /// **An UNREPORTED target: the two surfaces answer differently, and both
    /// answers are measured.** The Outline corrects (that is how it reached a
    /// row a lazy container had never built); the flow does not (every row
    /// there is a direct child whose position is known, so an unreported
    /// target means the page did not move — and row 100 measured that blind
    /// corrections are the instability rather than the cure).
    @Test func anUnreportedTargetIsTheOneRuleTheTwoSurfacesDisagreeOn() {
        #expect(LandingSettle.decide(
            top: nil, corrections: 0, elapsed: 0.3, mayFinish: true, policy: outline) == .correct)
        #expect(isNear(waited(LandingSettle.decide(
            top: nil, corrections: 0, elapsed: 0.3, mayFinish: true, policy: flow)), 0.7),
            "the flow waits; the SEED is what saves it from waiting out the watchdog")
        #expect(LandingSettle.decide(
            top: nil, corrections: 0, elapsed: 4.5, mayFinish: true, policy: flow)
            == .giveUp(top: nil))
    }

    /// The budget stops CORRECTING; the watchdog stops the landing. (On the
    /// Outline the two can never meet: at a 0.25-s pause its 40 corrections
    /// need 10 s and its watchdog fires at 4 — which is why the shipped loop's
    /// `hops >= budget` fence was unreachable and its retirement here changes
    /// nothing that can happen. The pin states the arithmetic.)
    @Test func theBudgetStopsCorrectingAndTheWatchdogStopsTheLanding() {
        #expect(isNear(waited(LandingSettle.decide(
            top: 500, corrections: 6, elapsed: 2.0, mayFinish: true, policy: flow)), 0.25),
            "out of corrections: it watches, it does not scroll")
        #expect(LandingSettle.decide(
            top: 500, corrections: 6, elapsed: 4.5, mayFinish: true, policy: flow)
            == .giveUp(top: 500))
        #expect(Double(outline.correctionBudget) * outline.settleInterval > outline.timeBudget,
                "the Outline's correction fence cannot be reached inside its watchdog")
    }

    /// The event re-arm: the quiet interval, capped by the ceiling measured
    /// from the last decision — so a column that re-reports forever cannot
    /// starve the look (the second cut of the row-53 fix, which sat inside the
    /// wrong story with a landing still pending and nothing ever logged).
    @Test func anEventReArmsTheQuietIntervalUnderACeiling() {
        #expect(isNear(LandingSettle.eventDelay(sinceDecision: 0, policy: outline), 0.25))
        #expect(isNear(LandingSettle.eventDelay(sinceDecision: 0.5, policy: outline), 0.1))
        #expect(isNear(LandingSettle.eventDelay(sinceDecision: 5, policy: outline), 0.01),
                "starved: the look runs at once rather than never")
    }
}

// MARK: - The SIGNPOST

@Suite("The Release landing signpost is content-free (13u2b UNIT 2)")
struct LandingSignpostTests {
    /// A column whose every row id is PROSE — a book's chapters and notes
    /// named the way hers are — so the pin asks the question that matters:
    /// can anything a person wrote reach the line that ships?
    private func proseColumn() -> BookHeightManifest {
        BookHeightManifest(
            width: 696, spacing: 10, leading: 0,
            inputs: [
                .init(id: "chapter-A Scandal in Bohemia", measured: 51, derived: 51),
                .init(id: "page-The Red-Headed League", remembered: 20_000, derived: 19_000),
                .init(id: "chapter-The Man with the Twisted Lip", derived: 51),
                .init(id: "page-The Adventure of the Blue Carbuncle", derived: 22_400),
            ])
    }

    /// **The promise, asserted rather than described.** Every value in the
    /// line is an integer except two words from closed types, and the
    /// prose-named rows above cannot appear in it — the line is built from
    /// `LandingFacts`, which has no string field at all.
    @Test func theLineCarriesNumbersAndAClosedVocabularyAndNothingElse() {
        let manifest = proseColumn()
        // The LAST row: a derived chapter heading stands above it, so this
        // landing is one the compensator may still have to catch.
        let facts = LandingFacts(manifest: manifest, anchor: "page-The Adventure of the Blue Carbuncle")
        let line = LandingSignpost.line(
            surface: .bookOutline, facts: facts, corrections: 1, contentMoves: 3,
            elapsed: 1.014, outcome: .settled, top: 0)
        #expect(LandingSignpost.isContentFree(line), "\(line)")
        for word in ["Twisted", "Scandal", "Bohemia", "Red-Headed", "Carbuncle", "chapter-", "page-"] {
            #expect(!line.contains(word), "\(word) reached the shipping line: \(line)")
        }
        // The facts it DOES carry — the ones her report needs.
        #expect(line.contains("surface=BookOutline"))
        #expect(line.contains("rows=4"))
        #expect(line.contains("target=3"), "the target is named by its INDEX, never by its id")
        #expect(line.contains("derived=2"), "two of the four rows are still arithmetic")
        #expect(line.contains("exact=0"), "…and one of them is ABOVE the target, so nothing is exact")
        #expect(line.contains("offset=20132"), "51 + 10 + 20000 + 10 + 51 + 10")
        #expect(line.contains("hops=1") && line.contains("content=3"))
        #expect(line.contains("ms=1014") && line.contains("end=settled") && line.contains("top=0"))
    }

    /// The manifest's own arithmetic, read through the facts: the target's
    /// offset is the sum of what stands above it plus the spacing between
    /// them, and `exact` is true only when NOTHING above it is arithmetic.
    @Test func theFactsAreTheManifestsOwnArithmetic() {
        let manifest = proseColumn()
        let second = LandingFacts(manifest: manifest, anchor: "page-The Red-Headed League")
        #expect(second.targetIndex == 1)
        #expect(second.offset == 61, "51 pt of heading + the column's 10-pt gap")
        #expect(second.exactAbove,
                "the one row above it is MEASURED, so nothing above this target can move")
        let first = LandingFacts(manifest: manifest, anchor: "chapter-A Scandal in Bohemia")
        #expect(first.exactAbove, "and nothing at all stands above the first row")
        let last = LandingFacts(manifest: manifest, anchor: "page-The Adventure of the Blue Carbuncle")
        #expect(!last.exactAbove,
                "a DERIVED heading stands above this one — the one thing that can still shift it")
        #expect(first.total == manifest.totalHeight)
        // A row the manifest does not know answers honestly rather than
        // guessing: index −1, offset −1.
        let stranger = LandingFacts(manifest: manifest, anchor: "page-a note from another book")
        #expect(stranger.targetIndex == -1 && stranger.offset == -1 && !stranger.exactAbove)
        #expect(LandingSignpost.isContentFree(LandingSignpost.line(
            surface: .readingFlow, facts: stranger, corrections: 0, contentMoves: 0,
            elapsed: 0.4, outcome: .gaveup, top: nil)))
    }

    /// The guard itself has teeth: a line carrying a title, an unknown word or
    /// a malformed pair is NOT content-free.
    @Test func theGuardRefusesALineThatCarriesAnything() {
        #expect(!LandingSignpost.isContentFree("landing surface=BookOutline title=The Red-Headed League"))
        #expect(!LandingSignpost.isContentFree("landing surface=Somewhere rows=4"))
        #expect(!LandingSignpost.isContentFree("landing rows=4 end=finished"))
        #expect(!LandingSignpost.isContentFree("landing rows"))
        #expect(!LandingSignpost.isContentFree("BookOutline landed at the top"))
        #expect(LandingSurface.allCases.count == 2,
                "two surfaces have adopted the authority; a third adds its case here")
    }
}
