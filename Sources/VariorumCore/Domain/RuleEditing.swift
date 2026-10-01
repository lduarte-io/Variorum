import Foundation

/// **THE RULE EDITOR'S BRAIN** (13i-b U3 — the plan §4 item 1; the sitting
/// record §3 + §19): path-addressed edits over the stored grammar ITSELF.
///
/// The editor's state is a `RuleTerm?` — never a second, smaller vocabulary
/// (the retired v1 draft vehicle was exactly that, and a v2 shape it could
/// not spell would have been silently dropped on save: the "undraftable"
/// hazard). Here every stored shape IS a state of the editor, so there is
/// nothing it cannot express and nothing a save could lose: the hazard is
/// gone by construction rather than relocated. Concretely:
///
/// - `.not` is a WRAPPER NODE (a node with one child), never a flag on its
///   child, so even `not(not x)` round-trips byte-for-byte;
/// - an edit touches exactly the node it addresses; every other node of the
///   tree survives untouched (pinned over a corpus of shapes);
/// - GRANDFATHERED legacy terms (profile, entry-date bounds — #166(d)) are
///   rows the face draws READ-ONLY; nothing here mints one, so no face can
///   offer one;
/// - the editor NEVER MINTS AN EMPTY GROUP: a group is born seeded with its
///   first term, and removing a group's last term removes the group (and any
///   `not` wrapping it), up to the root — whose last removal clears the rule
///   (nil). An empty group that was STORED that way stays exactly as stored
///   (no edit of hers emptied it). This matters beyond tidiness: `and([])`
///   matches every note, so a book carrying one would catch up the whole
///   wing into Arrivals.
public enum RuleEditing {
    /// A node's address: child indices from the root (`[]` is the root). A
    /// `not` node's only child is index 0.
    public typealias Path = [Int]

    /// A group's combinator, in the face's words ("all of" / "any of").
    public enum Combinator: Equatable, Sendable {
        case all, any
    }

    /// One row the editor draws, depth-first.
    public struct Row: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            /// A group header ("all of" / "any of").
            case group(Combinator, childCount: Int)
            /// A tag term — the tag's ID (`""` is the deliberate dead term).
            case tag(String)
            /// The star term.
            case star
            /// A grandfathered term — drawn read-only, never offered.
            case legacy(RuleTerm)
            /// The add doors of a group. `target` is the group NODE's path,
            /// or nil for the ROOT-LEVEL door beside a lone root term (adding
            /// there wraps the root and the new term into an "all of").
            case adder(target: Path?)
        }

        /// The row's address for remove / negate — the OUTERMOST `not`
        /// wrapping the node, so removing a negated term removes its `not`
        /// with it. For an adder, the group it adds into (or `[]`).
        public let path: Path
        /// The node itself, after unwrapping its `not`s — what a group's
        /// combinator flip addresses.
        public let nodePath: Path
        public let depth: Int
        public let kind: Kind
        /// How many `not`s wrap the node ("not not #x" stays honest).
        public let negations: Int

        public init(path: Path, nodePath: Path, depth: Int, kind: Kind, negations: Int) {
            self.path = path
            self.nodePath = nodePath
            self.depth = depth
            self.kind = kind
            self.negations = negations
        }

        /// Whether the row carries the NOT door. Legacy terms and adders
        /// carry none.
        public var isEditable: Bool {
            switch kind {
            case .group, .tag, .star: true
            case .legacy, .adder: false
            }
        }

        /// Whether the row carries the REMOVE door: an editable row whose
        /// subtree holds no grandfathered term. "Read-only" must not leak
        /// through a parent — removing a group would take the old term with
        /// it, which no door may do (#166(d): kept exactly as it is).
        public var isRemovable: Bool { isEditable && !holdsLegacy }

        /// Set by the walk: the node's subtree carries a legacy term.
        public var holdsLegacy = false
    }

    // MARK: - The projection the face draws

    /// The rows of a rule, depth-first, with each group's add door after its
    /// children. `nil` (no rule) draws no rows — the face says so and offers
    /// the root's add door itself.
    public static func rows(of root: RuleTerm?) -> [Row] {
        guard let root else { return [] }
        var rows: [Row] = []
        walk(root, path: [], depth: 0, into: &rows)
        // A lone root term (a leaf, or anything negated at the root) has no
        // group of its own to append to: the root-level door wraps.
        if !isGroup(root) {
            rows.append(Row(path: [], nodePath: [], depth: 0, kind: .adder(target: nil), negations: 0))
        }
        return rows
    }

    private static func walk(_ term: RuleTerm, path: Path, depth: Int, into rows: inout [Row]) {
        var node = term
        var nodePath = path
        var negations = 0
        while case .not(let inner) = node {
            node = inner
            nodePath.append(0)
            negations += 1
        }
        switch node {
        case .and(let children), .or(let children):
            let combinator: Combinator = if case .and = node { .all } else { .any }
            var header = Row(
                path: path, nodePath: nodePath, depth: depth,
                kind: .group(combinator, childCount: children.count), negations: negations)
            header.holdsLegacy = carriesLegacy(node)
            rows.append(header)
            for (index, child) in children.enumerated() {
                walk(child, path: nodePath + [index], depth: depth + 1, into: &rows)
            }
            rows.append(Row(
                path: nodePath, nodePath: nodePath, depth: depth + 1,
                kind: .adder(target: nodePath), negations: 0))
        case .tag(let id):
            rows.append(Row(path: path, nodePath: nodePath, depth: depth, kind: .tag(id), negations: negations))
        case .star:
            rows.append(Row(path: path, nodePath: nodePath, depth: depth, kind: .star, negations: negations))
        case .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
            var row = Row(
                path: path, nodePath: nodePath, depth: depth, kind: .legacy(node), negations: negations)
            row.holdsLegacy = true
            rows.append(row)
        case .not:
            break  // unreachable — unwrapped above
        }
    }

    // MARK: - The edits (each touches exactly the node it addresses)

    /// Adds `term` to the group at `target` (a group NODE's path — a row's
    /// `nodePath`), or — `target` nil — at the ROOT: appended when the root
    /// is an un-negated group, else the root and the term become an
    /// "all of". On no rule at all, the term IS the rule.
    public static func add(_ term: RuleTerm, into target: Path?, of root: RuleTerm?) -> RuleTerm {
        guard let root else { return term }
        guard let target else {
            switch root {
            case .and(let children): return .and(children + [term])
            case .or(let children): return .or(children + [term])
            default: return .and([root, term])
            }
        }
        return update(root, at: target[...]) { node in
            switch node {
            case .and(let children): .and(children + [term])
            case .or(let children): .or(children + [term])
            default: node  // not a group — an invalid address changes nothing
            }
        } ?? root
    }

    /// Adds a NEW GROUP, born seeded with its first term — the editor never
    /// mints an empty group.
    public static func addGroup(
        _ combinator: Combinator, seededWith first: RuleTerm,
        into target: Path?, of root: RuleTerm?
    ) -> RuleTerm {
        let group: RuleTerm = combinator == .all ? .and([first]) : .or([first])
        return add(group, into: target, of: root)
    }

    /// Removes the node at `path` (a row's `path` — its outermost `not`).
    /// A group THIS removal empties goes with it (and any `not` wrapping
    /// it), upward; the root's last term clears the rule (nil).
    public static func remove(at path: Path, of root: RuleTerm?) -> RuleTerm? {
        guard let root else { return nil }
        return update(root, at: path[...]) { _ in nil }
    }

    /// Wraps the node at `path` in a `not`, or — when it IS a `not` (the
    /// row's outermost) — unwraps exactly one.
    public static func toggleNegation(at path: Path, of root: RuleTerm?) -> RuleTerm? {
        guard let root else { return nil }
        return update(root, at: path[...]) { node in
            if case .not(let inner) = node { return inner }
            return .not(node)
        }
    }

    /// Flips the group at `nodePath` between "all of" and "any of", its
    /// children untouched.
    public static func setCombinator(
        _ combinator: Combinator, at nodePath: Path, of root: RuleTerm?
    ) -> RuleTerm? {
        guard let root else { return nil }
        return update(root, at: nodePath[...]) { node in
            switch node {
            case .and(let children), .or(let children):
                combinator == .all ? .and(children) : .or(children)
            default: node
            }
        }
    }

    // MARK: - Facts the face asks

    /// Whether the rule carries a grandfathered term anywhere (the face's
    /// one read-only notice).
    public static func carriesLegacy(_ term: RuleTerm?) -> Bool {
        guard let term else { return false }
        switch term {
        case .and(let children), .or(let children): return children.contains { carriesLegacy($0) }
        case .not(let inner): return carriesLegacy(inner)
        case .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo: return true
        case .tag, .star: return false
        }
    }

    /// Whether saving `draft` over the STORED value would change the rule.
    /// Structural equality, never bytes: a stored value in a non-canonical
    /// spelling re-encodes to different bytes, and on a BOOK a changed rule
    /// is an intake occasion (the catch-up rings the gap into Arrivals) — an
    /// unedited save must write nothing at all. A MALFORMED stored value is
    /// never overwritten by this face (it refuses to edit what it cannot
    /// read — a newer client's rule is not this build's to destroy).
    public static func needsWrite(draft: RuleTerm?, stored: String?) -> Bool {
        switch RuleGrammar.read(stored) {
        case .malformed: return false
        case .none: return draft != nil
        case .rule(let term): return draft != term
        }
    }

    // MARK: - The one tree walk under every edit

    private static func isGroup(_ term: RuleTerm) -> Bool {
        switch term {
        case .and, .or: true
        default: false
        }
    }

    /// Rewrites the node at `path` with `transform`; a nil answer REMOVES it
    /// from its parent. A removal that empties a group removes that group
    /// too, and a `not` whose child is removed goes with it — so pruning
    /// climbs exactly as far as THIS removal emptied things, and a group
    /// that was already empty is never touched. An invalid address returns
    /// the tree unchanged.
    private static func update(
        _ term: RuleTerm, at path: ArraySlice<Int>, _ transform: (RuleTerm) -> RuleTerm?
    ) -> RuleTerm? {
        guard let index = path.first else { return transform(term) }
        let rest = path.dropFirst()
        switch term {
        case .and(var children):
            guard children.indices.contains(index) else { return term }
            if let rewritten = update(children[index], at: rest, transform) {
                children[index] = rewritten
                return .and(children)
            }
            children.remove(at: index)
            return children.isEmpty ? nil : .and(children)
        case .or(var children):
            guard children.indices.contains(index) else { return term }
            if let rewritten = update(children[index], at: rest, transform) {
                children[index] = rewritten
                return .or(children)
            }
            children.remove(at: index)
            return children.isEmpty ? nil : .or(children)
        case .not(let inner):
            guard index == 0 else { return term }
            return update(inner, at: rest, transform).map { .not($0) }
        case .tag, .star, .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
            return term
        }
    }
}
