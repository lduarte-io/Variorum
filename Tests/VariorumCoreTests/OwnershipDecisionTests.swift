import Testing

@testable import VariorumCore

/// 13i-c U2 — THE OWNERSHIP DECISION, every cell of the table (the 13i-c plan
/// §3; the sitting record §6, §18.4). Pure: no database. The wiring — which
/// roads consult it and what each does with the verdict — is
/// `OwnershipDoorTests`' (the §4 enumeration, one test per row).
@Suite("13i-c U2 — the ownership decision table (pure)")
struct OwnershipDecisionTests {
    typealias D = OwnershipDecision

    private func note(membered: Bool = false, owned: Bool = false) -> D.NoteFacts {
        // Owned elsewhere IS membered elsewhere (an owned book's member row is
        // a member row) — the facts the store can actually produce.
        D.NoteFacts(memberedElsewhere: membered || owned, ownedElsewhere: owned)
    }

    @Test func aBooklessNoteMovesInCleanToAnyBook() {
        // §6: "bookless → move in clean".
        #expect(D.verdict(targetOwned: true, note: note()) == .add)
        #expect(D.verdict(targetOwned: false, note: note()) == .add)
    }

    @Test func aPlainBookTakesAnOrdinaryNoteAsAPointerBesideItsOtherBooks() {
        // §2: "Adding never copies" — multi-membership is legal.
        #expect(D.verdict(targetOwned: false, note: note(membered: true)) == .add)
    }

    @Test func anOwnedBookMeetingANoteThatLivesElsewhereOffersCopyOrMove() {
        // §6: "membered elsewhere → explicit choice, copy in or move in".
        #expect(D.verdict(targetOwned: true, note: note(membered: true))
            == .needsChoice(.copyOrMove))
        // §18.4 — a COMPETING owned book is a second place it lives too.
        #expect(D.verdict(targetOwned: true, note: note(owned: true))
            == .needsChoice(.copyOrMove))
    }

    @Test func aPlainBookMeetingANoteAnotherBookOwnsOffersOnlyACopy() {
        // §4/§6: the owned book's promise forbids a second pointer.
        #expect(D.verdict(targetOwned: false, note: note(owned: true))
            == .needsChoice(.copyOnly))
    }

    @Test func theTableAgreesWithIntakesOwnedArmsCellForCell() {
        // The intake table is this table answered with a BELL (§4): every
        // cell where ownership needs a choice is a cell where intake bells,
        // and every plain add is a cell where intake would seat.
        typealias I = IntakeDecision
        let book = { (owned: Bool) in
            I.BookFacts(isLive: true, isBook: true, rule: .readable, locked: false,
                        seating: nil, maxPosts: nil, memberCount: 0, owned: owned)
        }
        for owned in [false, true] {
            for (membered, ownedElsewhere) in [(false, false), (true, false), (true, true)] {
                let facts = note(membered: membered, owned: ownedElsewhere)
                let intake = I.verdict(
                    book: book(owned),
                    note: I.NoteFacts(
                        matchesRule: true, pair: .fresh,
                        memberedElsewhere: facts.memberedElsewhere,
                        ownedElsewhere: facts.ownedElsewhere),
                    occasion: .event)
                switch D.verdict(targetOwned: owned, note: facts) {
                case .add: #expect(intake == .seat)
                case .needsChoice: #expect(intake == .arrival)
                }
            }
        }
    }
}
