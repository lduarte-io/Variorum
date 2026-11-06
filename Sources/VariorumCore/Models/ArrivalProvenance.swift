import Foundation

/// **WHY AN ARRIVAL WAITS** (VX-808 — the run record
/// `notes/plans/fixes/vx-808-arrivals-books.md` §5 + Unit B2; her VX-821
/// ruling: "every row says WHY it waits and since when", and VX-811's optional
/// per-note reason). Stored as canonical JSON in `reading_post.arrival_provenance`
/// (nullable TEXT, ENCRYPTED under E2EE) — `block.presentation`'s one-JSON-column
/// precedent, and its doctrine: `kind` is an OPEN string (a future client's
/// kind decodes and survives a round trip here), malformed JSON reads as absent
/// (a reader never throws on it), and NULL means an arrival older than the
/// column (the face shows since-when only).
///
/// The field is the ARRIVAL's fact: readers read it only on a LIVE
/// `status='arrival'` row. Every road that mints or re-poses an arrival WRITES
/// it (overwriting whatever the row carried), so a row that was a member and is
/// demoted again speaks its new cause, never its old one.
public struct ArrivalProvenance: Codable, Equatable, Sendable {
    /// The causes this build stamps (the run's B2 vocabulary ruling, A-808-6):
    /// every road that mints, re-poses or DEMOTES-TO an arrival writes one.
    public enum Kind: String, CaseIterable, Sendable {
        /// An MCP client proposed the note (`propose_notes_to_book`) —
        /// `client` always, `reason` when it gave one.
        case proposed
        /// A rule write's sweep belled it — her rule editor's Save or the wire's
        /// `set_book_rule` (a rule set on a rule-less book included).
        case ruleEdit = "rule_edit"
        /// A book born with its rule, whose birth sweep's seat waited (the
        /// dial, a birth cap, an ownership conflict).
        case backfill
        /// A resumed book's catch-up belled it — `after` says which resume.
        case catchup
        /// A tagging act matched the book's rule and the note waits (the dial,
        /// capacity, ownership, a dismissed pair re-posed, or A-809-11's
        /// wire-actor fence) — `tag` is the applied tag's id.
        case tagged
        /// A starring act matched the book's rule and the note waits.
        case starred
        /// ⌘J filed the day's note while another book owns it — the daily
        /// door's bell (`bellAtDailyDoor`).
        case journalFiling = "journal_filing"
        /// A revival or a sync repair met an ownership claim and DEMOTED a
        /// later membership to an arrival (a demotion: `at` rides).
        case ownedElsewhere = "owned_elsewhere"
        /// The general book wing mend's displaced filing (Unit B1, A-808-5 —
        /// a demotion: `at` rides).
        case wingMend = "wing_mend"
    }

    /// Which resume a `catchup` followed.
    public enum CatchUpCause: String, CaseIterable, Sendable {
        /// Restored from the Trash (`restoreReading`).
        case restore
        /// Reopened after being finished (`unlockReading` / `reopen_book`).
        case reopen
        /// Un-archived (`unarchiveReading`).
        case unarchive
        /// Unsealed (`unsealReading` — the book reopens with its catch-up).
        case unseal
    }

    public var kind: String
    /// The MCP client whose act made the arrival (its name as it connected) —
    /// on any stamp whose act was heard as a wire client's.
    public var client: String?
    /// The client's own words for why (VX-811's per-note reason) — prose.
    public var reason: String?
    /// `tagged`: the applied tag's id.
    public var tag: String?
    /// `catchup`: which resume (`CatchUpCause`'s raw value).
    public var after: String?
    /// A DEMOTION's moment (A-808-7 (ii)) — ISO-8601, written where the stamp
    /// is: a demoted row's `created_at` is its ORIGINAL filing's, and would
    /// mis-say since when (the face reads `at ?? created_at`). Fresh rows carry
    /// none: their `created_at` IS the bell.
    public var at: String?

    public init(
        kind: Kind, client: String? = nil, reason: String? = nil, tag: String? = nil,
        after: CatchUpCause? = nil, at: Date? = nil
    ) {
        self.kind = kind.rawValue
        self.client = client
        self.reason = reason
        self.tag = tag
        self.after = after?.rawValue
        self.at = at.map { DateFormatter.variorumISO8601.string(from: $0) }
    }

    /// The kind as this build knows it (nil: a newer client's kind).
    public var knownKind: Kind? { Kind(rawValue: kind) }

    /// **A proposal's provenance** — the reason normalized by `normalizedReason`.
    public static func proposed(client: String, reason: String?) -> ArrivalProvenance {
        ArrivalProvenance(kind: .proposed, client: client, reason: normalizedReason(reason))
    }

    /// The most a reason may hold, in characters (PROVISIONAL — the run's B2
    /// bundle): a reason is a line on a row of her Arrivals, never a document.
    /// The wire refuses a longer one at its call door; the op refuses it too.
    public static let reasonCap = 500

    /// A reason as stored: U+0000 removed (`StoredText` — the store's rule for
    /// every text a door writes), then trimmed; a blank one is none.
    public static func normalizedReason(_ raw: String?) -> String? {
        guard let stripped = StoredText.stripped(raw)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !stripped.isEmpty
        else { return nil }
        return stripped
    }

    /// The canonical encoding — sorted keys, absent fields omitted, slashes
    /// unescaped — so equal provenances are byte-equal.
    public func encodedJSON() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return String(decoding: try encoder.encode(self), as: UTF8.self)
    }

    /// A stored provenance; malformed JSON (or none) reads as nil.
    public static func decode(_ json: String?) -> ArrivalProvenance? {
        guard let json else { return nil }
        return try? JSONDecoder().decode(ArrivalProvenance.self, from: Data(json.utf8))
    }
}

extension ReadingPost {
    /// The typed view of `arrivalProvenance` — meaningful only on a live arrival.
    public var provenance: ArrivalProvenance? { ArrivalProvenance.decode(arrivalProvenance) }
}
