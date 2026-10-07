import Foundation

/// **THE TAG-ASSOCIATION JOIN's decision** (Phase 13o U3 — the 13i sitting
/// record §12 item 1, handed to this phase as a ruled input): *"a tag's
/// results surface the books/gatherings ASSOCIATED with it (intake/auto-tag),
/// top-ranked"*, and her reason, verbatim: *"a book can have a tag
/// association already so it does not need its own tag — the tags that it
/// gives its writing is enough."* (Book tags are deferred — no `reading_tag`.)
///
/// A typed `#tag` is associated with a book or gathering two ways, each read
/// by ITS OWN MECHANISM's subtree rule, so the row's "why" is literally true:
///
/// - **it FLOWS HERE** — the reading's RULE (a living book's intake, a
///   gathering's assembly) has a POSITIVE tag term whose subtree holds the
///   typed tag: intake fires when an applied tag falls at-or-under a rule
///   tag (`Operations.intakeAfterTagging`'s reading), and a gathering
///   assembles that same subtree — so a note tagged with the typed tag
///   arrives here. Positive means under an EVEN number of `not`s
///   (`RuleGrammar.positiveTagIDs`, the outflow prefill's parity letter): a
///   `NOT #dream` rule is never where dream flows.
/// - **its writing is TAGGED with it** — an OUTFLOW tag (`auto_tag_ids`, the
///   chosen set notes written here receive) at-or-under the typed tag: the
///   typed `#path` matches its subtree everywhere in search, so the book's
///   writing is among the tag's own results.
///
/// Pure — the reads that feed it (the wing's readings, the live paths) are
/// the one composer's statements, run by `Queries.searchTagAssociations`.
public enum SearchTagAssociation {
    /// Why a reading is associated — what its row says (the mockup's
    /// "#dream flows here").
    public enum Reason: Equatable, Sendable {
        /// Notes carrying the typed tag (this stored path) flow here.
        case flowsIn(path: String)
        /// Notes written here are tagged with this outflow tag (its path).
        case taggedHere(path: String)
    }

    /// One reading the decision reads: its rule as stored and its outflow.
    public struct Candidate: Equatable, Sendable {
        public let readingID: String
        public let name: String
        /// The stored `query_spec` (a NULL or malformed rule associates
        /// nothing — the per-consumer fail-closed letter).
        public let ruleSpec: String?
        /// The decoded outflow (`Reading.decodeOutflow`).
        public let outflowTagIDs: [String]
        public let isArchived: Bool

        public init(readingID: String, name: String, ruleSpec: String?, outflowTagIDs: [String], isArchived: Bool) {
            self.readingID = readingID
            self.name = name
            self.ruleSpec = ruleSpec
            self.outflowTagIDs = outflowTagIDs
            self.isArchived = isArchived
        }
    }

    /// One associated reading, with its reason.
    public struct Association: Equatable, Sendable {
        public let readingID: String
        public let reason: Reason
        public let isArchived: Bool

        public init(readingID: String, reason: Reason, isArchived: Bool) {
            self.readingID = readingID
            self.reason = reason
            self.isArchived = isArchived
        }
    }

    /// **The typed tags a query names** — the POSITIVE `.tagPath` leaves of
    /// its filter half (under an even number of `not`s), in the order typed,
    /// de-duplicated case-insensitively (a typed path matches its tag
    /// case-insensitively — P-13o-U1-9). A tag by ID (`.tag(id:)`) is a
    /// programmatic term, not typed — it names no association here.
    public static func typedPaths(of filter: SearchFilter?) -> [String] {
        var ordered: [String] = []
        var seen: Set<String> = []
        func walk(_ filter: SearchFilter, negated: Bool) {
            switch filter {
            case .all(let children), .any(let children):
                for child in children { walk(child, negated: negated) }
            case .not(let inner):
                walk(inner, negated: !negated)
            case .tagPath(let path):
                if !negated, seen.insert(path.lowercased()).inserted { ordered.append(path) }
            case .tag, .starred, .days, .family, .docKind:
                break
            }
        }
        if let filter { walk(filter, negated: false) }
        return ordered
    }

    /// **The decision.** `typedPaths` are the typed tags RESOLVED to their
    /// stored paths (the caller's wing-scoped, case-insensitive lookup — an
    /// unresolved typed tag simply associates nothing); `tagPaths` maps a
    /// referenced tag id to its LIVE path (a dead or missing id is absent —
    /// it associates nothing, the dead-term letter).
    ///
    /// Order — the association's own rank, ahead of every name hit (the
    /// caller's "top-ranked"): the readings the typed tag FLOWS INTO first
    /// (a rule naming the typed tag itself before one naming an ancestor of
    /// it), then the readings whose writing CARRIES it; within each, by name
    /// (digit-aware, the Bookcase's a–z), then id. Each reading once, with
    /// its strongest reason.
    public static func associate(
        candidates: [Candidate], typedPaths: [String], tagPaths: [String: String]
    ) -> [Association] {
        guard !typedPaths.isEmpty else { return [] }
        var ranked: [(rank: Int, name: String, association: Association)] = []
        for candidate in candidates {
            if let flow = flowsIn(candidate, typedPaths: typedPaths, tagPaths: tagPaths) {
                ranked.append((flow.exact ? 0 : 1, candidate.name, Association(
                    readingID: candidate.readingID, reason: .flowsIn(path: flow.typed),
                    isArchived: candidate.isArchived)))
            } else if let path = taggedHere(candidate, typedPaths: typedPaths, tagPaths: tagPaths) {
                ranked.append((2, candidate.name, Association(
                    readingID: candidate.readingID, reason: .taggedHere(path: path),
                    isArchived: candidate.isArchived)))
            }
        }
        return ranked.sorted { a, b in
            if a.rank != b.rank { return a.rank < b.rank }
            let byName = a.name.localizedStandardCompare(b.name)
            if byName != .orderedSame { return byName == .orderedAscending }
            return a.association.readingID < b.association.readingID
        }.map(\.association)
    }

    /// Is `path` the root itself or inside its subtree (`ruleSQL`'s letter:
    /// equal, or prefixed by the root and a slash)?
    static func isAtOrUnder(_ path: String, _ root: String) -> Bool {
        path == root || path.hasPrefix(root + "/")
    }

    /// The first typed path a positive rule tag's subtree holds — exact
    /// matches preferred over ancestors.
    private static func flowsIn(
        _ candidate: Candidate, typedPaths: [String], tagPaths: [String: String]
    ) -> (typed: String, exact: Bool)? {
        guard case .rule(let term) = RuleGrammar.read(candidate.ruleSpec) else { return nil }
        let roots = RuleGrammar.positiveTagIDs(of: term).compactMap { tagPaths[$0] }
        guard !roots.isEmpty else { return nil }
        for typed in typedPaths where roots.contains(typed) { return (typed, true) }
        for typed in typedPaths where roots.contains(where: { isAtOrUnder(typed, $0) }) {
            return (typed, false)
        }
        return nil
    }

    /// The first outflow tag inside a typed path's subtree (its own path).
    private static func taggedHere(
        _ candidate: Candidate, typedPaths: [String], tagPaths: [String: String]
    ) -> String? {
        for id in candidate.outflowTagIDs {
            guard let path = tagPaths[id] else { continue }
            if typedPaths.contains(where: { isAtOrUnder(path, $0) }) { return path }
        }
        return nil
    }
}
