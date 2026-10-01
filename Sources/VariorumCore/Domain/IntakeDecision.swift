import Foundation

/// THE INTAKE DECISION (13i-b U1 — the sitting record §4, §6, §14.1–6, §19,
/// §24; the 13i-b plan §2.1). Pure: given what is true of ONE book and ONE
/// note at the moment an occasion fires, say what intake does with the pair —
/// seat it as a member, ring the bell (an arrival), or nothing.
///
/// Intake is EVENT-DRIVEN (her ruling closing the brief's sharpest knot):
/// it fires on the applying ACT — a tagging, a starring — never on tag
/// state, and it only ever INSERTS. Untagging never evicts; removing a member
/// never deletes a tag. The three occasions differ only where the rulings
/// make them differ:
///
/// - `event` — a tagging or starring act just happened to this note.
/// - `backfill` — a book was BORN with its rule (or a rule was set on a
///   rule-less book): its current matches are seated directly — "birth =
///   intent" (§4).
/// - `catchUp` — a book RESUMED (restored from the Trash, un-finished, its
///   rule edited): the gap's matches route through Arrivals — "gap =
///   judgment" (§4).
///
/// The owned arms (§6) are part of the table now and pinned headlessly; no
/// door can mint an owned book until 13i-c, so nothing user-visible reaches
/// them yet.
public enum IntakeDecision {
    public enum Occasion: Equatable, Sendable {
        case event
        case backfill
        case catchUp
    }

    /// What the book's stored rule reads as (`RuleGrammar.ReadResult`'s
    /// three states, without the term itself — the table needs only which).
    public enum RuleState: Equatable, Sendable {
        case none
        case malformed
        case readable
    }

    /// What the store says about this (book, note) pair BEFORE the occasion.
    /// Tombstone-means-decided (§4: "a live OR tombstoned membership row
    /// means the pair is decided") — with the ONE distinction the rulings
    /// themselves draw between kinds of decision (see `verdict`).
    public enum PairState: Equatable, Sendable {
        /// No `reading_post` row of any kind — the pair is fresh.
        case fresh
        /// A LIVE row exists: already a member, or already waiting.
        case live
        /// No live row, and at least one TOMBSTONED MEMBER row — the note
        /// was a member and left (`removePostFromReading`, a divergence, a
        /// cascade). Decided against every occasion (§20: "tombstone-means-
        /// decided keeps intake from re-adding").
        case leftAsMember
        /// No live row and no tombstoned member row — only DISMISSAL records
        /// (tombstoned arrival rows: a judged "no", or finishing's sweep).
        case dismissed
    }

    public struct BookFacts: Equatable, Sendable {
        public var isLive: Bool
        /// `kind == .book` — a gathering assembles at read and never
        /// materializes (§3: "matches simply SHOW").
        public var isBook: Bool
        public var rule: RuleState
        /// FINISHED — intake pauses (§5).
        public var locked: Bool
        /// The join dial (§4). nil reads AUTO — join quietly (P-13ib-5).
        public var seating: IntakeSeating?
        public var maxPosts: Int?
        /// Live `status='member'` rows — arrivals are never counted.
        public var memberCount: Int
        public var owned: Bool

        public init(
            isLive: Bool, isBook: Bool, rule: RuleState, locked: Bool,
            seating: IntakeSeating?, maxPosts: Int?, memberCount: Int, owned: Bool
        ) {
            self.isLive = isLive
            self.isBook = isBook
            self.rule = rule
            self.locked = locked
            self.seating = seating
            self.maxPosts = maxPosts
            self.memberCount = memberCount
            self.owned = owned
        }
    }

    public struct NoteFacts: Equatable, Sendable {
        /// The book's rule matches this note now (the assembly's own
        /// predicate, `ruleMatchSQL`, probed for one post).
        public var matchesRule: Bool
        public var pair: PairState
        /// A live MEMBER row in some OTHER live book.
        public var memberedElsewhere: Bool
        /// A live MEMBER row in some OTHER live OWNED book.
        public var ownedElsewhere: Bool

        public init(
            matchesRule: Bool, pair: PairState,
            memberedElsewhere: Bool, ownedElsewhere: Bool
        ) {
            self.matchesRule = matchesRule
            self.pair = pair
            self.memberedElsewhere = memberedElsewhere
            self.ownedElsewhere = ownedElsewhere
        }
    }

    public enum Verdict: Equatable, Sendable {
        /// Insert `status='member'` at the END, unsectioned (§4, §14.2).
        case seat
        /// Insert `status='arrival'` — the bell, waiting for judgment.
        case arrival
        case nothing
    }

    /// Does this book's intake run at all (P-13ib-5)? A live row, a BOOK, a
    /// READABLE rule, not finished. A malformed rule runs nothing (fails
    /// closed — the standing per-consumer letter); a dead or paused book's
    /// intake runs nothing (§4, ruled).
    public static func intakeRuns(_ book: BookFacts) -> Bool {
        book.isLive && book.isBook && book.rule == .readable && !book.locked
    }

    /// The one verdict. Order is the table's (the 13i-b plan §2.1):
    ///
    /// 1. A book whose intake does not run → nothing.
    /// 2. A note the rule does not match → nothing.
    /// 3. The pair is decided → nothing — EXCEPT that a dismissal yields to
    ///    a fresh EVENT and comes back as an ARRIVAL (PROVISIONAL P-13ib-U1-1,
    ///    the record's reconciliation of §4 with §24's "a dismissed arrival
    ///    returns only on a FRESH tagging act"; never auto-seated over her
    ///    "no", never resurrected by a backfill or a catch-up).
    /// 4. Ownership (§6): a plain book bells an owned-elsewhere note; an
    ///    owned book claims a FREE note and bells a membered one.
    /// 5. A would-be seat waits at Arrivals when the book is at capacity
    ///    (§14.3), when the join dial says "wait at Arrivals" (§4), or when
    ///    the occasion is a catch-up (gap = judgment).
    /// 6. Otherwise: seat (multi-membership is legal).
    public static func verdict(
        book: BookFacts, note: NoteFacts, occasion: Occasion
    ) -> Verdict {
        guard intakeRuns(book), note.matchesRule else { return .nothing }
        switch note.pair {
        case .live, .leftAsMember:
            return .nothing
        case .dismissed:
            return occasion == .event ? .arrival : .nothing
        case .fresh:
            break
        }
        let wouldSeat: Bool = book.owned
            ? !note.memberedElsewhere   // claim a FREE note; bell a membered one
            : !note.ownedElsewhere      // seat ordinary notes; bell an owned one
        guard wouldSeat else { return .arrival }
        if let cap = book.maxPosts, book.memberCount >= cap { return .arrival }
        if book.seating == .arrivals { return .arrival }
        if occasion == .catchUp { return .arrival }
        return .seat
    }
}
