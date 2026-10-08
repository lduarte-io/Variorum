import Foundation

/// **THE FIRST-OPEN TOUR OFFER'S LIFECYCLE** (13s-b U1a — her rulings
/// R-13s-2, R-13s-6 and R-13s-13; mockup v5's "first open" and "not now"
/// frames, `notes/plans/13s-mockups/onboarding-tour.html`).
///
/// One quiet line on the Bookcase, above the bottom bar: *"Welcome to
/// Variorum. Take the tour?  yes · not now"*. "not now" swaps it, for a few
/// seconds, to the sentence naming the Help menu's standing door, and then it
/// is gone — **and it never comes back** (R-13s-13, her words: *"i think the
/// tour offer just shouldn't come back - they can find it under help."*).
/// "yes" starts the tour; COMPLETING or ENDING the tour retires the line too
/// (the U2 brief). A tour abandoned by quitting mid-way retires nothing: the
/// next launch offers again, and the tour starts from step 1 (Q12 — no resume
/// state).
///
/// Pure, so the rule is pinned headlessly; the app holds the one record and
/// draws the line. The record is a LOCAL, per-device preference and never
/// the store's: the offer is chrome, not document state, so it does not sync
/// (PROVISIONAL — the U1a RECORD carries the alternative).
public enum TourOffer {
    /// What the device remembers once the offer has been answered. Absent
    /// means never answered; ANY present value retires the line.
    public enum Record: String, Sendable, CaseIterable {
        /// "not now".
        case declined
        /// The tour ran to its end (U2's engine reports it).
        case completed
        /// The tour's End tour, pressed before its end (U2's engine).
        case ended
    }

    /// Where the line is in its life.
    public enum Phase: Equatable, Sendable {
        /// The offer itself: "Welcome to Variorum. Take the tour?  yes · not now".
        case offering
        /// The few seconds after "not now": the sentence naming Help's door.
        case helpRoad
        /// A tour is running: the line steps aside (it is not offered to
        /// someone already taking it), and nothing is remembered yet.
        case touring
        /// Gone for good (R-13s-13 — absolute).
        case retired
    }

    /// What can happen to it.
    public enum Event: Equatable, Sendable {
        /// The line's "not now".
        case notNow
        /// The tour began — the line's "yes", or the Help menu's door.
        case tourStarted
        /// The help-road sentence has had its few seconds.
        case helpRoadElapsed
        /// The tour finished (`completed: true`) or was ended part-way.
        case tourEnded(completed: Bool)
    }

    /// One step of the rule: the phase to show, and the record to WRITE
    /// (nil = write nothing — the stored record is never cleared).
    public struct Step: Equatable, Sendable {
        public let phase: Phase
        public let record: Record?

        public init(phase: Phase, record: Record? = nil) {
            self.phase = phase
            self.record = record
        }
    }

    /// The phase at launch, from the stored value. Nothing stored offers;
    /// ANYTHING stored retires — a value this build does not recognize (a
    /// newer build's, a hand edit) fails toward QUIET, never toward a second
    /// offer, because R-13s-13 is absolute and a re-offer is the one outcome
    /// her ruling forbids.
    public static func phase(atLaunch stored: String?) -> Phase {
        stored == nil ? .offering : .retired
    }

    /// The rule. Every (phase, event) pair is answered; an event that cannot
    /// apply in a phase leaves it where it is and writes nothing.
    public static func next(_ phase: Phase, on event: Event) -> Step {
        switch (phase, event) {
        // The offer.
        case (.offering, .notNow):
            // Remembered AT the press, not when the sentence fades: a quit in
            // the next few seconds must not bring the offer back.
            return Step(phase: .helpRoad, record: .declined)
        case (.offering, .tourStarted):
            return Step(phase: .touring)
        case (.offering, .helpRoadElapsed):
            return Step(phase: .offering)

        // The help-road sentence (the record is already written).
        case (.helpRoad, .helpRoadElapsed):
            return Step(phase: .retired)
        case (.helpRoad, .tourStarted):
            // She went straight to Help: the sentence has done its work.
            return Step(phase: .retired)
        case (.helpRoad, .notNow):
            return Step(phase: .helpRoad)

        // A tour in progress.
        case (.touring, .notNow), (.touring, .tourStarted), (.touring, .helpRoadElapsed):
            return Step(phase: .touring)

        // A tour's end retires the line from wherever it stood, and says how.
        case (.offering, .tourEnded(let completed)),
             (.helpRoad, .tourEnded(let completed)),
             (.touring, .tourEnded(let completed)):
            return Step(phase: .retired, record: completed ? .completed : .ended)

        // Retired stays retired, whatever happens (R-13s-13).
        case (.retired, _):
            return Step(phase: .retired)
        }
    }

    /// What the line SAYS in a phase: the offer, the help-road sentence, or
    /// nothing at all.
    public enum Line: Equatable, Sendable {
        case offer
        case helpRoad
    }

    public static func line(in phase: Phase) -> Line? {
        switch phase {
        case .offering: .offer
        case .helpRoad: .helpRoad
        case .touring, .retired: nil
        }
    }
}
