import Foundation
import Testing

@testable import VariorumCore

// 13n-b U1 P4 — THE GRANT RULE (A-7): the MCP door's security boundary,
// tested exhaustively headless. These pins are the verification bar's floor:
// reads never exceed the grant; journals (and Private notes — R-13nb-4) never
// match a standing grant or the open book; revocation is immediate; a once
// grant is consumed; a non-approved client gets nothing.

private typealias Rule = MCPGrantRule

private func grant(
    _ id: String = "g1", _ rung: Rule.Rung = .read, _ kind: Rule.ScopeKind = .book,
    _ scope: String = "book-A", _ duration: Rule.Duration = .always,
    consumed: String? = nil, revoked: String? = nil
) -> Rule.Grant {
    Rule.Grant(id: id, rung: rung, scopeKind: kind, scopeID: scope, duration: duration,
               consumedAt: consumed, revokedAt: revoked)
}

private let plainNote = Rule.NoteFacts(id: "note-1", wingID: "", bookIDs: ["book-A"])
private func note(fence: Rule.Fence?) -> Rule.Target {
    .note(Rule.NoteFacts(id: "note-1", wingID: "", bookIDs: ["book-A"], fence: fence))
}

@Suite("13n-b U1 — the grant rule (A-7, the security boundary)")
struct MCPGrantRuleTests {
    // MARK: - The client gate

    @Test func aClientThatIsNotApprovedGetsNothingWhateverItHolds() {
        let everything = [grant("g1", .edit, .wing, "", .always), grant("g2", .edit, .note, "note-1", .always)]
        for state in [Rule.ClientState.pending, .denied, nil] {
            for openBook in [false, true] {
                let decision = Rule.decide(
                    client: state, grants: everything, openBook: openBook,
                    target: .note(plainNote), rung: .read, consumes: true)
                #expect(!decision.isAllowed, "\(String(describing: state)) open=\(openBook)")
                if case .refuse = decision {} else {
                    Issue.record("a non-approved client is REFUSED, never asked: \(decision)")
                }
            }
        }
        #expect(Rule.decide(client: .denied, grants: [], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: false) == .refuse(.clientDenied))
        #expect(Rule.decide(client: .pending, grants: [], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: false) == .refuse(.clientPending))
        #expect(Rule.decide(client: nil, grants: [], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: false) == .refuse(.clientPending))
    }

    // MARK: - Scope reach

    @Test func eachScopeReachesExactlyItsOwn() {
        let n = plainNote  // wing '', member of book-A
        let cases: [(Rule.Grant, Bool)] = [
            (grant("g", .read, .note, "note-1"), true),
            (grant("g", .read, .note, "note-2"), false),
            (grant("g", .read, .book, "book-A"), true),
            (grant("g", .read, .book, "book-B"), false),
            (grant("g", .read, .wing, ""), true),
            (grant("g", .read, .wing, "wing-X"), false),
        ]
        for (g, reaches) in cases {
            #expect(Rule.reaches(g, .note(n)) == reaches, "\(g.scopeKind) \(g.scopeID)")
            let decision = Rule.decide(client: .approved, grants: [g], openBook: false,
                                       target: .note(n), rung: .read, consumes: false)
            #expect(decision.isAllowed == reaches)
            if !reaches { #expect(decision == .ask(.notShared, offersAlways: true)) }
        }
        let book = Rule.BookFacts(id: "book-A", wingID: "wing-X")
        #expect(Rule.reaches(grant("g", .read, .book, "book-A"), .book(book)))
        #expect(!Rule.reaches(grant("g", .read, .book, "book-B"), .book(book)))
        #expect(Rule.reaches(grant("g", .read, .wing, "wing-X"), .book(book)))
        #expect(!Rule.reaches(grant("g", .read, .wing, ""), .book(book)), "another wing's book is out")
        #expect(!Rule.reaches(grant("g", .read, .note, "book-A"), .book(book)),
                "a note grant never reaches a book, even by a colliding id")
    }

    @Test func aNoteThatLeftTheGrantedBookIsRefusedToday() {
        let g = grant("g", .read, .book, "book-A")
        let then = Rule.NoteFacts(id: "note-1", wingID: "", bookIDs: ["book-A"])
        let now = Rule.NoteFacts(id: "note-1", wingID: "", bookIDs: ["book-B"])
        #expect(Rule.decide(client: .approved, grants: [g], openBook: false, target: .note(then),
                            rung: .read, consumes: true).isAllowed)
        #expect(Rule.decide(client: .approved, grants: [g], openBook: false, target: .note(now),
                            rung: .read, consumes: true) == .ask(.notShared, offersAlways: true))
    }

    // MARK: - Rungs (cumulative)

    @Test func aGrantCoversItsRungAndEveryRungBelowItAndNothingAbove() {
        for granted in Rule.Rung.allCases {
            for requested in Rule.Rung.allCases {
                let decision = Rule.decide(
                    client: .approved, grants: [grant("g", granted, .note, "note-1")], openBook: false,
                    target: .note(plainNote), rung: requested, consumes: false)
                if granted >= requested {
                    #expect(decision == .allow(grantID: "g", consumesOnce: false), "\(granted) ⊇ \(requested)")
                } else {
                    #expect(decision == .ask(.rungTooLow(granted: granted), offersAlways: true),
                            "\(granted) ⊉ \(requested)")
                }
            }
        }
        #expect(Rule.Rung.allCases == [.read, .suggest, .writeNew, .edit])
        #expect(Rule.Rung.allCases.map(\.rawValue) == ["read", "suggest", "write_new", "edit"],
                "the stored spelling is the schema's CHECK list")
    }

    // MARK: - Durations, consumption, revocation

    @Test func revocationIsImmediate() {
        let live = grant("g", .read, .note, "note-1")
        var revoked = live
        revoked.revokedAt = "2026-10-09T12:00:00.000Z"
        #expect(Rule.decide(client: .approved, grants: [live], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: true).isAllowed)
        #expect(Rule.decide(client: .approved, grants: [revoked], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: true) == .ask(.notShared, offersAlways: true))
    }

    @Test func aOnceGrantIsSpentByItsFirstContentReadOnly() {
        let once = grant("g", .read, .note, "note-1", .once)
        // A listing reaches it without spending it.
        #expect(Rule.decide(client: .approved, grants: [once], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: false) == .allow(grantID: "g", consumesOnce: false))
        // The first content read spends it.
        #expect(Rule.decide(client: .approved, grants: [once], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: true) == .allow(grantID: "g", consumesOnce: true))
        // Spent, it reaches nothing.
        var spent = once
        spent.consumedAt = "2026-10-09T12:00:00.000Z"
        #expect(!spent.isLive)
        #expect(Rule.decide(client: .approved, grants: [spent], openBook: false, target: .note(plainNote),
                            rung: .read, consumes: true) == .ask(.notShared, offersAlways: true))
    }

    @Test func aStandingGrantCoversFirstSoAOnceGrantIsNotWasted() {
        let once = grant("g-once", .read, .note, "note-1", .once)
        let standing = grant("g-book", .read, .book, "book-A", .always)
        #expect(Rule.decide(client: .approved, grants: [once, standing], openBook: false,
                            target: .note(plainNote), rung: .read, consumes: true)
                == .allow(grantID: "g-book", consumesOnce: false))
        let connected = grant("g-conn", .read, .wing, "", .connection)
        #expect(Rule.decide(client: .approved, grants: [once, connected], openBook: false,
                            target: .note(plainNote), rung: .read, consumes: true)
                == .allow(grantID: "g-conn", consumesOnce: false))
        // The open book covers too — the once grant stays unspent.
        #expect(Rule.decide(client: .approved, grants: [once], openBook: true,
                            target: .note(plainNote), rung: .read, consumes: true)
                == .allow(grantID: nil, consumesOnce: false))
    }

    // MARK: - The fence (R-13nb-1 journals + R-13nb-4 Private)

    @Test func aFencedNoteMatchesNoStandingGrantAndNotTheOpenBook() {
        for fence in [Rule.Fence.journal, .privateMark] {
            let standing: [Rule.Grant] = [
                grant("g1", .edit, .book, "book-A", .always),
                grant("g2", .edit, .wing, "", .always),
                grant("g3", .edit, .book, "book-A", .connection),
                grant("g4", .edit, .wing, "", .once),
                grant("g5", .edit, .note, "note-1", .always),
            ]
            for openBook in [false, true] {
                let decision = Rule.decide(client: .approved, grants: standing, openBook: openBook,
                                           target: note(fence: fence), rung: .read, consumes: true)
                #expect(decision == .ask(.fenced(fence), offersAlways: false),
                        "\(fence) open=\(openBook): \(decision)")
            }
        }
    }

    @Test func aFencedNoteIsReachedOnlyByAPerAskGrantNamingIt() {
        for fence in [Rule.Fence.journal, .privateMark] {
            let once = grant("g-once", .read, .note, "note-1", .once)
            let connected = grant("g-conn", .read, .note, "note-1", .connection)
            let otherNote = grant("g-other", .read, .note, "note-2", .connection)
            #expect(Rule.decide(client: .approved, grants: [once], openBook: false,
                                target: note(fence: fence), rung: .read, consumes: true)
                    == .allow(grantID: "g-once", consumesOnce: true))
            #expect(Rule.decide(client: .approved, grants: [connected], openBook: false,
                                target: note(fence: fence), rung: .read, consumes: true)
                    == .allow(grantID: "g-conn", consumesOnce: false))
            #expect(Rule.decide(client: .approved, grants: [otherNote], openBook: false,
                                target: note(fence: fence), rung: .read, consumes: true)
                    == .ask(.fenced(fence), offersAlways: false))
        }
    }

    @Test func aFencedBookIsReachedByNothing() {
        let book = Rule.Target.book(Rule.BookFacts(id: "book-J", wingID: "", fence: .journal))
        let grants = [grant("g1", .edit, .book, "book-J", .always), grant("g2", .edit, .wing, "", .always)]
        for openBook in [false, true] {
            #expect(Rule.decide(client: .approved, grants: grants, openBook: openBook, target: book,
                                rung: .read, consumes: false) == .ask(.fenced(.journal), offersAlways: false))
        }
    }

    // MARK: - The open book

    @Test func theOpenBookIsReadOnlyForApprovedClients() {
        #expect(Rule.decide(client: .approved, grants: [], openBook: true, target: .note(plainNote),
                            rung: .read, consumes: true) == .allow(grantID: nil, consumesOnce: false))
        #expect(Rule.decide(client: .approved, grants: [], openBook: true,
                            target: .book(Rule.BookFacts(id: "b", wingID: "w")),
                            rung: .read, consumes: false).isAllowed,
                "every wing — 'everything is readable'")
        for rung in [Rule.Rung.suggest, .writeNew, .edit] {
            #expect(Rule.decide(client: .approved, grants: [], openBook: true, target: .note(plainNote),
                                rung: rung, consumes: false) == .ask(.notShared, offersAlways: true),
                    "the open book never grants \(rung)")
        }
        #expect(Rule.decide(client: .pending, grants: [], openBook: true, target: .note(plainNote),
                            rung: .read, consumes: false) == .refuse(.clientPending))
    }

    // MARK: - AF-7 as amended: a once write grant is spent by its FIRST
    // WRITE of ANY rung it authorizes; ride-free covers READS only (the
    // amendment at the U2 ladder's F4 — "one write means one write")

    @Test func aOnceWriteGrantLetsTheReadsItNeedRideFreeAndIsSpentByItsFirstWrite() {
        let onceSuggest = grant("g-s", .suggest, .note, "note-1", .once)
        func decide(_ g: Rule.Grant, _ rung: Rule.Rung, consumes: Bool = true) -> Rule.Decision {
            Rule.decide(client: .approved, grants: [g], openBook: false, target: .note(plainNote),
                        rung: rung, consumes: consumes)
        }
        #expect(decide(onceSuggest, .read) == .allow(grantID: "g-s", consumesOnce: false),
                "the read a suggestion needs rides free")
        #expect(decide(onceSuggest, .suggest) == .allow(grantID: "g-s", consumesOnce: true),
                "the first write spends it")
        var spent = onceSuggest
        spent.consumedAt = "t"
        #expect(decide(spent, .suggest) == .ask(.notShared, offersAlways: true), "the second write refuses")
        #expect(decide(spent, .read) == .ask(.notShared, offersAlways: true), "spent is spent for every rung")

        let onceWriteNew = grant("g-w", .writeNew, .note, "note-1", .once)
        #expect(decide(onceWriteNew, .read) == .allow(grantID: "g-w", consumesOnce: false),
                "a content read under a once write grant still rides free")
        #expect(decide(onceWriteNew, .suggest) == .allow(grantID: "g-w", consumesOnce: true),
                "AF-7 AMENDED: a suggest-rung write under a once write-new grant IS its one write")
        #expect(decide(onceWriteNew, .writeNew) == .allow(grantID: "g-w", consumesOnce: true))
        let onceRead = grant("g-r", .read, .note, "note-1", .once)
        #expect(decide(onceRead, .read) == .allow(grantID: "g-r", consumesOnce: true),
                "a read grant: P-13nb-U1-2's letter, unchanged")

        let onceWing = grant("g-wing", .writeNew, .wing, "", .once)
        #expect(Rule.decideWing(client: .approved, grants: [onceWing], openBook: false, wingID: "",
                                rung: .writeNew, consumes: true) == .allow(grantID: "g-wing", consumesOnce: true),
                "a wing-scoped write spends a once wing grant")
        #expect(Rule.decideWing(client: .approved, grants: [onceWing], openBook: false, wingID: "",
                                rung: .read) == .allow(grantID: "g-wing", consumesOnce: false),
                "a wing listing never spends")
    }

    // MARK: - A wing-level listing

    @Test func aWingListingNeedsWingLevelReach() {
        let wingGrant = grant("g-w", .read, .wing, "wing-X", .always)
        #expect(Rule.decideWing(client: .approved, grants: [wingGrant], openBook: false, wingID: "wing-X", rung: .read)
                == .allow(grantID: "g-w", consumesOnce: false))
        #expect(Rule.decideWing(client: .approved, grants: [wingGrant], openBook: false, wingID: "", rung: .read)
                == .ask(.notShared, offersAlways: true), "another wing's grant reaches nothing here")
        let bookGrant = grant("g-b", .read, .book, "book-A", .always)
        let noteGrant = grant("g-n", .read, .note, "note-1", .always)
        #expect(Rule.decideWing(client: .approved, grants: [bookGrant, noteGrant], openBook: false, wingID: "", rung: .read)
                == .ask(.notShared, offersAlways: true), "a book or note grant never lists a whole wing")
        #expect(Rule.decideWing(client: .approved, grants: [], openBook: true, wingID: "wing-X", rung: .read)
                == .allow(grantID: nil, consumesOnce: false))
        var revoked = wingGrant
        revoked.revokedAt = "t"
        #expect(Rule.decideWing(client: .approved, grants: [revoked], openBook: false, wingID: "wing-X", rung: .read)
                == .ask(.notShared, offersAlways: true))
        #expect(Rule.decideWing(client: .pending, grants: [wingGrant], openBook: true, wingID: "wing-X", rung: .read)
                == .refuse(.clientPending))
        #expect(Rule.decideWing(client: .denied, grants: [wingGrant], openBook: true, wingID: "wing-X", rung: .read)
                == .refuse(.clientDenied))
    }

    // MARK: - The exhaustive sweep — the boundary's invariants over every grant shape

    /// Every single-grant world (rung × scope kind × matching or not ×
    /// duration × consumed × revoked) × the target's fence × the open book
    /// × the asked rung × consuming or not, against every note shape. The
    /// invariants are the boundary itself, stated once:
    /// 1. ALLOW ⇒ the authorizing grant is live, reaches the target, and
    ///    covers the asked rung — or it is the open book on a read of an
    ///    unfenced target;
    /// 2. a FENCED allow ⇒ a live note-scoped, non-always grant naming it;
    /// 3. consumesOnce ⇒ the call consumes and the grant is a live once grant;
    /// 4. an ask on a fenced target never offers "always";
    /// 5. (13n-c U1 ladder F1 — the recorded F-8, built) a fenced ask is
    ///    `rungTooLow` exactly when a LIVE grant reaches the note (its own
    ///    per-ask grant, under the asked rung — the client's grant IS its
    ///    knowledge), and the fence's one answer otherwise.
    @Test func theBoundaryHoldsOverEveryGrantShape() {
        var worlds = 0
        let fences: [Rule.Fence?] = [nil, .journal, .privateMark]
        // VX-549 (A JUSTIFIED EDIT — the sweep grows with the grammar): the
        // GATHERING scope joins every grant shape, the target assembled by one
        // of the two (`gatheringIDs`), so the five invariants hold over it too.
        let scopeIDs: [Rule.ScopeKind: [String]] = [
            .note: ["note-1", "note-2"], .book: ["book-A", "book-B"], .wing: ["", "wing-X"],
            .gathering: ["gathering-G", "gathering-H"],
        ]
        for fence in fences {
            let target = Rule.NoteFacts(
                id: "note-1", wingID: "", bookIDs: ["book-A"], fence: fence, gatheringIDs: ["gathering-G"])
            for kind in Rule.ScopeKind.allCases {
                for scope in scopeIDs[kind]! {
                    for gRung in Rule.Rung.allCases {
                        for duration in Rule.Duration.allCases {
                            for consumed in [nil, "t"] as [String?] {
                                for revoked in [nil, "t"] as [String?] {
                                    let g = grant("g", gRung, kind, scope, duration,
                                                  consumed: consumed, revoked: revoked)
                                    for openBook in [false, true] {
                                        for asked in Rule.Rung.allCases {
                                            for consumes in [false, true] {
                                                worlds += 1
                                                let d = Rule.decide(
                                                    client: .approved, grants: [g], openBook: openBook,
                                                    target: .note(target), rung: asked, consumes: consumes)
                                                check(d, g, target, openBook, asked, consumes)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        #expect(worlds == 3 * 8 * 4 * 3 * 2 * 2 * 2 * 4 * 2)
    }

    private func check(
        _ d: Rule.Decision, _ g: Rule.Grant, _ target: Rule.NoteFacts,
        _ openBook: Bool, _ asked: Rule.Rung, _ consumes: Bool
    ) {
        let reachesNow: Bool = {
            guard g.isLive else { return false }
            if target.fence != nil {
                return g.scopeKind == .note && g.scopeID == target.id && g.duration != .always
            }
            switch g.scopeKind {
            case .note: return g.scopeID == target.id
            case .book: return target.bookIDs.contains(g.scopeID)
            case .wing: return g.scopeID == target.wingID
            case .gathering: return target.gatheringIDs.contains(g.scopeID)
            }
        }()
        switch d {
        case .allow(let grantID, let consumesOnce):
            if let grantID {
                #expect(grantID == g.id)
                #expect(reachesNow && g.rung >= asked, "invariant 1: \(g) asked \(asked) fence \(String(describing: target.fence))")
            } else {
                #expect(openBook && target.fence == nil && asked == .read, "invariant 1 (open book)")
            }
            if target.fence != nil {
                #expect(grantID != nil && g.scopeKind == .note && g.scopeID == target.id
                        && g.duration != .always, "invariant 2: a fenced allow is per-ask only")
            }
            // Invariant 3, AF-7 AS AMENDED (the U2 ladder's F4): a once READ
            // grant is spent exactly by a content read; a once WRITE grant
            // (suggest/write new) by a content-bearing WRITE of ANY rung it
            // authorizes — reads ride free under it, writes never do. The
            // biconditional, both directions.
            let spendsHere = g.rung == .read ? asked == .read : asked >= .suggest
            if consumesOnce {
                #expect(consumes && g.duration == .once && g.isLive && spendsHere, "invariant 3")
            }
            if grantID == g.id, g.duration == .once, consumes, spendsHere {
                #expect(consumesOnce, "invariant 3: one write means one write, whatever its rung")
            }
        case .ask(let reason, let offersAlways):
            if target.fence != nil {
                #expect(!offersAlways, "invariant 4")
                // Invariant 5 (13n-c U1 ladder F1): a live per-ask grant
                // holder hears the honest rung; everyone else the fence.
                if reachesNow {
                    #expect(reason == .rungTooLow(granted: g.rung), "invariant 5: \(g) asked \(asked)")
                } else {
                    #expect(reason == .fenced(target.fence!))
                }
            }
            // An ask is right exactly when nothing covers the call.
            #expect(!(reachesNow && g.rung >= asked))
            #expect(!(openBook && target.fence == nil && asked == .read))
        case .refuse:
            Issue.record("an approved client is never refused outright: \(d)")
        }
    }
}

// 13n-b U2 ladder, the sanity pass's O2 → AF-9 (the plan's sitting record):
// among sufficient grants of EQUAL duration class, the call spends the LEAST
// capability that suffices — the lowest rung first, then the narrowest scope
// (note < book < wing), then the smaller id as pure determinism. Before this,
// a duration tie fell to smallest-id alone, so WHICH once grant a write
// consumed was arbitrary: a once-write-new grant could be spent by a
// suggest-level write while a once-suggest grant sat unspent.
@Suite("13n-b U2 — AF-9: the least sufficient capability is spent")
struct MCPGrantSpendChoiceTests {
    @Test func aSuggestWriteSpendsTheOnceSuggestGrantNeverTheOnceWriteNewOne() {
        // The id order is the trap: 'a-writenew' sorts BEFORE 'b-suggest', so
        // the pre-AF-9 smallest-id tiebreak picked the write-new grant. Red
        // on the old comparator by construction.
        let grants = [
            grant("a-writenew", .writeNew, .book, "book-A", .once),
            grant("b-suggest", .suggest, .note, "note-1", .once),
        ]
        let d = Rule.decide(client: .approved, grants: grants, openBook: false,
                            target: .note(plainNote), rung: .suggest, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = d else {
            Issue.record("expected allow, got \(d)"); return
        }
        #expect(grantID == "b-suggest", "the lower sufficient rung is spent")
        #expect(consumesOnce)

        // Swapped ids: the answer must not move with the UUIDs.
        let swapped = [
            grant("a-suggest", .suggest, .note, "note-1", .once),
            grant("b-writenew", .writeNew, .book, "book-A", .once),
        ]
        let d2 = Rule.decide(client: .approved, grants: swapped, openBook: false,
                             target: .note(plainNote), rung: .suggest, consumes: true)
        guard case .allow(let grantID2, _) = d2 else {
            Issue.record("expected allow, got \(d2)"); return
        }
        #expect(grantID2 == "a-suggest")
    }

    @Test func equalRungsSpendTheNarrowerScopeThenTheSmallerID() {
        // Same rung, different scopes: the note-scoped grant is consumed, the
        // wing-wide one survives — whatever the id order says.
        let grants = [
            grant("a-wing", .suggest, .wing, "", .once),
            grant("b-note", .suggest, .note, "note-1", .once),
        ]
        let d = Rule.decide(client: .approved, grants: grants, openBook: false,
                            target: .note(plainNote), rung: .suggest, consumes: true)
        guard case .allow(let grantID, _) = d else {
            Issue.record("expected allow, got \(d)"); return
        }
        #expect(grantID == "b-note", "the narrower scope is spent")

        // Full tie (rung and scope): the smaller id, pure determinism.
        let tied = [
            grant("g2", .suggest, .note, "note-1", .once),
            grant("g1", .suggest, .note, "note-1", .once),
        ]
        let d2 = Rule.decide(client: .approved, grants: tied, openBook: false,
                             target: .note(plainNote), rung: .suggest, consumes: true)
        guard case .allow(let grantID2, _) = d2 else {
            Issue.record("expected allow, got \(d2)"); return
        }
        #expect(grantID2 == "g1")
    }

    @Test func aStandingGrantStillOutranksEveryOnceGrantWhateverTheRungs() {
        // Duration primacy untouched: a wide standing grant covers the call
        // and no once grant is spent — the U1 pin's letter, re-asserted here
        // beside the new comparator so the two rules are read together.
        let grants = [
            grant("a-once-suggest", .suggest, .note, "note-1", .once),
            grant("b-standing-wing", .writeNew, .wing, "", .always),
        ]
        let d = Rule.decide(client: .approved, grants: grants, openBook: false,
                            target: .note(plainNote), rung: .suggest, consumes: true)
        guard case .allow(let grantID, let consumesOnce) = d else {
            Issue.record("expected allow, got \(d)"); return
        }
        #expect(grantID == "b-standing-wing")
        #expect(!consumesOnce)
    }
}
