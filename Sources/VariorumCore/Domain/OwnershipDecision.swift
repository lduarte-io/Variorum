import Foundation

/// THE OWNERSHIP DECISION (13i-c U2 — the sitting record §1, §2, §6, §18.4,
/// §20; the 13i-c plan §3). Pure: given whether the TARGET book owns its
/// notes and what is true of the NOTE elsewhere, say what a membership-
/// creating road may do with the pair — a plain pointer, or a choice the door
/// must offer because a plain pointer would break the ownership promise.
///
/// The ladder (§1): a GATHERING shows, a BOOK holds members, an OWNED book
/// holds them EXCLUSIVELY — "there is no second place it lives". So:
///
/// - **Owned target, note membered in another book** → the door offers
///   `copyOrMove`: COPY IN (the original keeps its lives) or MOVE IN (its
///   other memberships severed, listed) — §6's "Add doors into an owned book".
/// - **Plain target, note owned elsewhere** → `copyOnly`: the owning book's
///   promise forbids a second pointer, so the only way in is a copy (§4's
///   "copy in / dismiss" for the bell).
/// - Everything else → `add`, a plain pointer: a bookless note moves in clean
///   to any book, and an ordinary note joins a plain book beside its other
///   books (multi-membership is legal; "adding never copies", §2).
///
/// ONE table read by every road that creates a membership (the plan §4's
/// enumeration — `addPostToReading`, the arrival seat, the daily Journal's
/// shelving, the bind). Intake's own table (`IntakeDecision`) carries the
/// same semantics for the EVENT occasions: its owned arms are this table's
/// two choices, answered there with a bell instead of a refusal.
public enum OwnershipDecision {
    /// The choice a door must offer instead of a plain add.
    public enum Choice: Equatable, Sendable {
        /// An owned book meets a note that lives in other books: copy it in,
        /// or move it in and sever the other memberships.
        case copyOrMove
        /// A plain book meets a note another book owns: only a copy can come in.
        case copyOnly
    }

    public enum Verdict: Equatable, Sendable {
        /// A plain pointer is legal — insert the membership.
        case add
        /// A plain pointer would break an ownership promise — the door offers
        /// the choice (the operation refuses with the words that name it).
        case needsChoice(Choice)
    }

    /// What the store says about the note, OUTSIDE the target book. Both
    /// facts read live `status='member'` rows of live BOOKS only — an arrival
    /// is never membership, and a gathering holds nothing (the three readers'
    /// `kind='book'` ruling, 13i-b ladder F-R1-7).
    public struct NoteFacts: Equatable, Sendable {
        /// A live member row in some OTHER live book.
        public var memberedElsewhere: Bool
        /// A live member row in some OTHER live OWNED book.
        public var ownedElsewhere: Bool

        public init(memberedElsewhere: Bool, ownedElsewhere: Bool) {
            self.memberedElsewhere = memberedElsewhere
            self.ownedElsewhere = ownedElsewhere
        }
    }

    /// The one verdict.
    public static func verdict(targetOwned: Bool, note: NoteFacts) -> Verdict {
        if targetOwned {
            // Owned elsewhere implies membered elsewhere — a competing owned
            // book is "a second place it lives" like any other (§18.4: both
            // see it; the first claim stands; this door offers the choice).
            return note.memberedElsewhere || note.ownedElsewhere
                ? .needsChoice(.copyOrMove) : .add
        }
        return note.ownedElsewhere ? .needsChoice(.copyOnly) : .add
    }
}
