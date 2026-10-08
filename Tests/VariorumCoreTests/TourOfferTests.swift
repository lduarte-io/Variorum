import Testing
@testable import VariorumCore

/// 13s-b U1a, piece 2 — the first-open tour offer's lifecycle (her rulings
/// R-13s-2/6/13; the U2 brief's "completing or ending the tour retires the
/// offer line"). The rule is pure (`Domain/TourOffer`), so its whole table is
/// pinned here, headless.
@Suite("13s-b U1a — the tour offer's lifecycle")
struct TourOfferTests {
    private static let events: [TourOffer.Event] = [
        .notNow, .tourStarted, .helpRoadElapsed,
        .tourEnded(completed: true), .tourEnded(completed: false),
    ]
    private static let phases: [TourOffer.Phase] = [.offering, .helpRoad, .touring, .retired]

    @Test func aDeviceThatNeverAnsweredIsOfferedAndAnAnswerRetiresTheLine() {
        #expect(TourOffer.phase(atLaunch: nil) == .offering)
        for record in TourOffer.Record.allCases {
            #expect(TourOffer.phase(atLaunch: record.rawValue) == .retired,
                    "\(record) retires the offer at every later launch")
        }
    }

    /// R-13s-13 is absolute: a stored value this build cannot read is a
    /// device that ANSWERED, never one to offer again.
    @Test func anUnrecognizedRecordFailsTowardQuiet() {
        #expect(TourOffer.phase(atLaunch: "") == .retired)
        #expect(TourOffer.phase(atLaunch: "something-a-newer-build-wrote") == .retired)
    }

    /// "not now" → the help-road sentence → gone; and the answer is written
    /// AT the press, so a quit during the sentence cannot bring the offer back.
    @Test func notNowShowsTheHelpRoadThenRetiresAndIsRememberedAtThePress() {
        let pressed = TourOffer.next(.offering, on: .notNow)
        #expect(pressed == .init(phase: .helpRoad, record: .declined))
        #expect(TourOffer.phase(atLaunch: pressed.record?.rawValue) == .retired,
                "a quit while the sentence shows still never re-offers")
        #expect(TourOffer.next(.helpRoad, on: .helpRoadElapsed) == .init(phase: .retired))
    }

    /// "yes": the line steps aside while the tour runs and nothing is written
    /// — a tour abandoned by quitting offers again next launch (Q12: no resume
    /// state, the tour restarts from step 1). Its END retires the line, and
    /// says how it ended.
    @Test func yesStepsAsideAndOnlyTheToursEndRetires() {
        let started = TourOffer.next(.offering, on: .tourStarted)
        #expect(started == .init(phase: .touring))
        #expect(started.record == nil, "nothing remembered while the tour runs")
        #expect(TourOffer.next(.touring, on: .tourEnded(completed: true))
                == .init(phase: .retired, record: .completed))
        #expect(TourOffer.next(.touring, on: .tourEnded(completed: false))
                == .init(phase: .retired, record: .ended))
    }

    /// The Help menu's door during the help-road sentence: the sentence has
    /// done its work, and the line goes at once (the answer is already kept).
    @Test func helpDuringTheHelpRoadRetiresAtOnce() {
        #expect(TourOffer.next(.helpRoad, on: .tourStarted) == .init(phase: .retired))
    }

    /// Retired stays retired under EVERY event — the property R-13s-13 rests on.
    @Test func retiredIsAbsorbing() {
        for event in Self.events {
            #expect(TourOffer.next(.retired, on: event) == .init(phase: .retired),
                    "\(event) never revives a retired offer")
        }
    }

    /// Every (phase, event) pair is answered, and no road leads from a
    /// written record back to an offer.
    @Test func noSequenceThatWritesARecordEverOffersAgain() {
        for start in Self.phases {
            for first in Self.events {
                let a = TourOffer.next(start, on: first)
                for second in Self.events {
                    let b = TourOffer.next(a.phase, on: second)
                    if a.record != nil || b.record != nil {
                        #expect(b.phase != .offering,
                                "\(start) → \(first) → \(second): an answered offer never returns")
                    }
                }
            }
        }
    }

    @Test func theLineSaysTheOfferTheHelpRoadOrNothing() {
        #expect(TourOffer.line(in: .offering) == .offer)
        #expect(TourOffer.line(in: .helpRoad) == .helpRoad)
        #expect(TourOffer.line(in: .touring) == nil)
        #expect(TourOffer.line(in: .retired) == nil)
    }
}
