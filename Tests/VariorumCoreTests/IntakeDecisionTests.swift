import Testing

@testable import VariorumCore

/// 13i-b U1 — THE INTAKE DECISION, every arm of the table (the 13i-b plan
/// §2.1; the sitting record §4, §6, §14.3, §24). Pure: no database. The
/// owned arms are pinned HERE, headlessly — no door can mint an owned book
/// until 13i-c, so this table is the only place they can be seen today.
@Suite("13i-b U1 — the intake decision table (pure)")
struct IntakeDecisionTests {
    typealias D = IntakeDecision

    /// A living plain book with room and the dial at its default.
    private func book(
        isLive: Bool = true, isBook: Bool = true, rule: D.RuleState = .readable,
        locked: Bool = false, seating: IntakeSeating? = nil,
        maxPosts: Int? = nil, memberCount: Int = 0, owned: Bool = false
    ) -> D.BookFacts {
        D.BookFacts(
            isLive: isLive, isBook: isBook, rule: rule, locked: locked,
            seating: seating, maxPosts: maxPosts, memberCount: memberCount, owned: owned)
    }

    /// A matching, fresh, free note.
    private func note(
        matches: Bool = true, pair: D.PairState = .fresh,
        membered: Bool = false, owned: Bool = false
    ) -> D.NoteFacts {
        D.NoteFacts(
            matchesRule: matches, pair: pair,
            memberedElsewhere: membered || owned, ownedElsewhere: owned)
    }

    private let every: [D.Occasion] = [.event, .backfill, .catchUp]

    // MARK: 1. Intake runs iff live · book · readable rule · not finished (P-13ib-5)

    @Test func aBookWhoseIntakeDoesNotRunDecidesNothingOnEveryOccasion() {
        let paused: [D.BookFacts] = [
            book(isLive: false),            // a dead book's intake runs nothing (§4)
            book(isBook: false),            // a gathering assembles, never materializes (§3)
            book(rule: .none),              // no rule
            book(rule: .malformed),         // malformed fails closed (P-13ib-5)
            book(locked: true),             // finished pauses intake (§5)
        ]
        for facts in paused {
            #expect(!D.intakeRuns(facts))
            for occasion in every {
                #expect(D.verdict(book: facts, note: note(), occasion: occasion) == .nothing)
            }
        }
        #expect(D.intakeRuns(book()))
    }

    @Test func aNoteTheRuleDoesNotMatchIsNeverTouched() {
        for occasion in every {
            #expect(D.verdict(book: book(), note: note(matches: false), occasion: occasion)
                == .nothing)
        }
    }

    // MARK: 2. Tombstone-means-decided (§4) — and the one ruled exception (§24)

    @Test func aLiveRowAlreadyDecidesThePairOnEveryOccasion() {
        for occasion in every {
            #expect(D.verdict(book: book(), note: note(pair: .live), occasion: occasion)
                == .nothing)
        }
    }

    @Test func aNoteThatLeftAsAMemberIsNeverReAddedByIntake() {
        // §20: "tombstone-means-decided keeps intake from re-adding" — not
        // even a fresh act brings a removed member back.
        for occasion in every {
            #expect(D.verdict(book: book(), note: note(pair: .leftAsMember), occasion: occasion)
                == .nothing)
        }
    }

    @Test func aDismissalYieldsOnlyToAFreshActAndOnlyAsAnArrival() {
        // §24: "a dismissed arrival returns only on a FRESH tagging act …
        // the un-finish catch-up covers the gap only" (P-13ib-U1-1).
        #expect(D.verdict(book: book(), note: note(pair: .dismissed), occasion: .event)
            == .arrival)
        #expect(D.verdict(book: book(), note: note(pair: .dismissed), occasion: .backfill)
            == .nothing)
        #expect(D.verdict(book: book(), note: note(pair: .dismissed), occasion: .catchUp)
            == .nothing)
        // Never auto-seated over her "no", even with room and the dial on auto.
        #expect(D.verdict(
            book: book(seating: .auto, maxPosts: 10, memberCount: 0),
            note: note(pair: .dismissed), occasion: .event) == .arrival)
        // …and a paused book hears no act at all.
        #expect(D.verdict(book: book(locked: true), note: note(pair: .dismissed),
                          occasion: .event) == .nothing)
    }

    // MARK: 3. The plain book (§4)

    @Test func aPlainBookSeatsAnOrdinaryNoteOnAnActAndAtBirth() {
        #expect(D.verdict(book: book(), note: note(), occasion: .event) == .seat)
        #expect(D.verdict(book: book(), note: note(), occasion: .backfill) == .seat)
    }

    @Test func multiMembershipIsLegalSoANoteMemberedElsewhereStillSeats() {
        #expect(D.verdict(book: book(), note: note(membered: true), occasion: .event) == .seat)
    }

    @Test func aPlainBookBellsANoteOwnedElsewhere() {
        // §4: "BELLS an owned-elsewhere note (copy in / dismiss)" — headless
        // until 13i-c.
        for occasion: D.Occasion in [.event, .backfill, .catchUp] {
            #expect(D.verdict(book: book(), note: note(owned: true), occasion: occasion)
                == .arrival)
        }
    }

    // MARK: 4. The owned book (§4, §6 — headless until 13i-c)

    @Test func anOwnedBookClaimsAFreeNote() {
        #expect(D.verdict(book: book(owned: true), note: note(), occasion: .event) == .seat)
        #expect(D.verdict(book: book(owned: true), note: note(), occasion: .backfill) == .seat)
    }

    @Test func anOwnedBookBellsANoteMemberedAnywhereElse() {
        #expect(D.verdict(book: book(owned: true), note: note(membered: true), occasion: .event)
            == .arrival)
        #expect(D.verdict(book: book(owned: true), note: note(owned: true), occasion: .event)
            == .arrival)
    }

    // MARK: 5. Would-be seats that wait at the door

    @Test func atCapacityIntakeWaitsAtArrivals() {
        // §14.3: "membership rows counted; intake waits visibly at Arrivals."
        let full = book(maxPosts: 2, memberCount: 2)
        #expect(D.verdict(book: full, note: note(), occasion: .event) == .arrival)
        #expect(D.verdict(book: full, note: note(), occasion: .backfill) == .arrival)
        let over = book(maxPosts: 2, memberCount: 3)   // a lowered cap (legal)
        #expect(D.verdict(book: over, note: note(), occasion: .event) == .arrival)
        let room = book(maxPosts: 2, memberCount: 1)
        #expect(D.verdict(book: room, note: note(), occasion: .event) == .seat)
        // An owned book's claim waits at capacity too.
        #expect(D.verdict(book: book(maxPosts: 1, memberCount: 1, owned: true),
                          note: note(), occasion: .event) == .arrival)
    }

    @Test func theJoinDialRoutesEverythingThroughJudgment() {
        // §4: "new matches: join quietly at the end · or wait at Arrivals".
        let guarded = book(seating: .arrivals)
        #expect(D.verdict(book: guarded, note: note(), occasion: .event) == .arrival)
        #expect(D.verdict(book: guarded, note: note(), occasion: .backfill) == .arrival)
        // nil reads AUTO (P-13ib-5), exactly like an explicit .auto.
        #expect(D.verdict(book: book(seating: nil), note: note(), occasion: .event) == .seat)
        #expect(D.verdict(book: book(seating: .auto), note: note(), occasion: .event) == .seat)
    }

    @Test func aCatchUpRoutesEveryWouldBeSeatThroughArrivals() {
        // §4: "RESUME catch-up … routes the gap's matches through Arrivals —
        // gap = judgment."
        #expect(D.verdict(book: book(), note: note(), occasion: .catchUp) == .arrival)
        #expect(D.verdict(book: book(owned: true), note: note(), occasion: .catchUp)
            == .arrival)
    }
}
