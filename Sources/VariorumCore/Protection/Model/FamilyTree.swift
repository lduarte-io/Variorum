import Foundation

// VX-305 U1 — THE FAMILY TREE (design §3.2, §3.4, §3.7, §3.13): the
// non-secret list of every key the library has ever had — its fingerprint,
// its kind (Castle or Standard, for life), which Mac made it, when it was made
// and retired. It has two homes (the record, and its sealed mirror in what
// this Mac remembers), unioned at open, because a tree only grows: a rolled-
// back or replayed library file can't make this library's own copies look
// foreign. "Is this copy ours?" reads the tree, never the history (§3.7).

public struct FamilyTree: Codable, Equatable, Sendable {
    public struct Entry: Codable, Equatable, Sendable {
        /// The key's fingerprint (`StoreKeyEnvelope.fingerprint(of:)`).
        public var fingerprint: String
        /// The key's kind for life. A key the migration could not attribute
        /// counts as Castle's — the safe side (§3.13 step 3).
        public var kind: ProtectionMode
        /// The device identity of the Mac that made it; nil when unknown (a
        /// key seeded or folded at the migration).
        public var madeBy: String?
        public var madeAt: Date?
        public var retiredAt: Date?
        /// false: seeded from a fingerprint a key file names that the fold
        /// could NOT reach (§3.13 step 3 — "reached or not").
        public var reached: Bool

        public init(
            fingerprint: String, kind: ProtectionMode, madeBy: String? = nil,
            madeAt: Date? = nil, retiredAt: Date? = nil, reached: Bool = true
        ) {
            self.fingerprint = fingerprint
            self.kind = kind
            self.madeBy = madeBy
            self.madeAt = madeAt
            self.retiredAt = retiredAt
            self.reached = reached
        }
    }

    /// Sorted by fingerprint, one entry per fingerprint — a normal form, so
    /// two trees with the same facts are equal however they were built.
    public private(set) var entries: [Entry]

    public init(entries: [Entry] = []) {
        self.entries = []
        for entry in entries { insert(entry) }
    }

    public var fingerprints: [String] { entries.map(\.fingerprint) }

    public func contains(_ fingerprint: String) -> Bool { entry(fingerprint) != nil }

    public func entry(_ fingerprint: String) -> Entry? {
        entries.first { $0.fingerprint == fingerprint }
    }

    // MARK: - Growing (a tree only grows: nothing here removes an entry)

    /// A key a re-key, a landing or a creation minted: born `kind`, on
    /// `madeBy`, at `madeAt`.
    public func recordingBirth(
        fingerprint: String, kind: ProtectionMode, madeBy: String, madeAt: Date
    ) -> FamilyTree {
        var next = self
        next.insert(Entry(fingerprint: fingerprint, kind: kind, madeBy: madeBy, madeAt: madeAt))
        return next
    }

    /// A key replaced — its retirement date (the earliest one wins on a merge).
    public func retiring(_ fingerprint: String, at: Date) -> FamilyTree {
        guard let existing = entry(fingerprint) else { return self }
        var retired = existing
        retired.retiredAt = existing.retiredAt.map { min($0, at) } ?? at
        var next = self
        next.insert(retired)
        return next
    }

    /// The migration's seed (§3.13 step 3): fingerprints the catalog's key
    /// files name for this library, reached or not, so this library's own
    /// copies read as its own. An unknown kind counts as Castle's.
    public func seeding(
        _ fingerprints: [String], kind: ProtectionMode = .castle, reached: Bool = false
    ) -> FamilyTree {
        var next = self
        for fingerprint in fingerprints {
            next.insert(Entry(fingerprint: fingerprint, kind: kind, reached: reached))
        }
        return next
    }

    /// THE UNION (§3.6): every fingerprint either home knows; a fingerprint
    /// both know merges field by field (`merge`). Commutative, associative
    /// and idempotent — pinned.
    public func union(_ other: FamilyTree) -> FamilyTree {
        var next = self
        for entry in other.entries { next.insert(entry) }
        return next
    }

    /// The tree at open: the record's and the memory's mirror, unioned
    /// (§3.6). With the guard off (DEBUG mutation pins only) the record's
    /// alone.
    public static func atOpen(
        record: FamilyTree, memory: FamilyTree?, guards: ProtectionGuards = .all
    ) -> FamilyTree {
        guard guards.familyTreeTwoHomesOn, let memory else { return record }
        return record.union(memory)
    }

    /// Merging two homes' facts about ONE key. A key's kind is for life, so two
    /// homes disagreeing is a fault; the merge takes Castle — the safe side
    /// the migration's unknown-kind rule already takes (PROVISIONAL, the U1
    /// record). The earliest dates win; a known Mac beats an unknown one;
    /// "reached" is either's.
    static func merge(_ a: Entry, _ b: Entry) -> Entry {
        Entry(
            fingerprint: a.fingerprint,
            kind: (a.kind == .castle || b.kind == .castle) ? .castle : .standard,
            madeBy: [a.madeBy, b.madeBy].compactMap { $0 }.min(),
            madeAt: [a.madeAt, b.madeAt].compactMap { $0 }.min(),
            retiredAt: [a.retiredAt, b.retiredAt].compactMap { $0 }.min(),
            reached: a.reached || b.reached)
    }

    private mutating func insert(_ entry: Entry) {
        if let index = entries.firstIndex(where: { $0.fingerprint == entry.fingerprint }) {
            entries[index] = Self.merge(entries[index], entry)
        } else {
            entries.append(entry)
            entries.sort { $0.fingerprint < $1.fingerprint }
        }
    }

    // Decoding normalizes too (a stored tree out of order, or with a
    // duplicate, reads as its normal form).
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(entries: try container.decode([Entry].self, forKey: .entries))
    }

    private enum CodingKeys: String, CodingKey { case entries }
}
