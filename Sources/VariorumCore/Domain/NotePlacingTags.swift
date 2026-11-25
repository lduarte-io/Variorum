import Foundation

/// **The per-book tags switch** (VX-1038 — her R-1036-39: *"Third position on
/// the switch"*; R-1036-34: *"I like showing the tags that aren't part of the
/// rule of where it is as an option, to minimize visual clutter"*). Three
/// positions, hidden by default (T-5): a way of LOOKING, never stored in the
/// book — the Mac remembers it per book on this device (PROVISIONAL, the Index
/// `group ▾` memory's class). Pure and in core so the phone's twin (VM-120)
/// reads the same three positions and the same rule.
public enum BookTagsShown: String, CaseIterable, Equatable, Sendable {
    /// No pills, no "+" — the book's cards are today's (the default).
    case hidden
    /// Every tag a note wears EXCEPT the ones that place it here
    /// (`NotePlacingTags`) — in a plain book, everything.
    case otherTags = "other"
    /// Every tag a note wears.
    case allTags = "all"

    /// The default — tags hidden (T-5, "hidden by default").
    public static let initial: BookTagsShown = .hidden

    /// The local store's spelling, read back; an unknown spelling is the
    /// default (a way of looking never refuses).
    public init(stored: String?) {
        self = stored.flatMap(BookTagsShown.init(rawValue:)) ?? .initial
    }

    /// The pills a note wears in this position — nil when the book hides
    /// tags (no pills AND no "+"; T-3: "only while the book shows tags"), else
    /// the worn tags in their own order minus, under `otherTags`, the ones
    /// that place the note (`placing`, ids). An empty answer is "the + alone".
    public func pills<T>(worn: [T], placing: Set<String>, id: (T) -> String) -> [T]? {
        switch self {
        case .hidden: return nil
        case .allTags: return worn
        case .otherTags: return worn.filter { !placing.contains(id($0)) }
        }
    }
}

/// **The tags that PLACE a note** (VX-1038, R-1036-34/-39 — "other tags"
/// leaves off the tags that place a note: TODAY a gathering's rule-matched
/// tags; VX-1085's lanes add each lane's rule beside the gathering's). Pure,
/// over `RuleGrammar`'s tree and the note's own tags.
///
/// **Which tags place it** — the WITNESSES of the rule's truth: walk the tree
/// for the value the note gives it, and collect the worn tags that make a
/// satisfied tag term true, through satisfied branches only. Concretely:
/// - a TAG term the note satisfies is witnessed by every worn tag in its
///   subtree (a rule naming `video` is placed by a worn `video/ideas`) — of
///   the term tag's own wing, as the assembly matches (R-13ia-1);
/// - an AND that holds is witnessed by all its terms' witnesses; an OR that
///   holds by the witnesses of the terms that hold (`#a OR #b` wearing both:
///   both place it);
/// - a NOT is witnessed by the falsity of what it negates, which a worn tag
///   never witnesses — except under an even number of NOTs, where the walk
///   comes back to truth (`NOT NOT #a` is `#a`);
/// - a branch that does NOT hold places nothing (`(#a AND #x) OR #b` wearing
///   `a` and `b` but not `x`: only `b` places it);
/// - star and legacy terms witness no tag. A legacy term's value is the
///   caller's (`legacy`); unknown (nil, the default) is three-valued — it
///   neither holds nor fails, so it never blocks a witness the rest supports.
/// A dead or missing term tag (absent from `ruleTags`) matches nothing.
public enum NotePlacingTags {
    /// The ids of the worn tags that place the note under ANY of `rules`
    /// (the gathering's own rule now; a lane's rule joins it later).
    public static func placing(
        rules: [RuleTerm],
        worn: [Tag],
        ruleTags: [String: Tag],
        starred: Bool = false,
        legacy: (RuleTerm) -> Bool? = { _ in nil }
    ) -> Set<String> {
        var witnesses: Set<String> = []
        for rule in rules {
            witnesses.formUnion(
                walk(rule, want: true, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy))
        }
        return witnesses
    }

    /// The worn tags under a rule tag's subtree, of its own wing — the
    /// assembly's own match (`ReadingAssembly.ruleSQL`'s `.tag` arm).
    static func matching(_ termTagID: String, worn: [Tag], ruleTags: [String: Tag]) -> [Tag] {
        guard !termTagID.isEmpty, let root = ruleTags[termTagID], root.deletedAt == nil else { return [] }
        return worn.filter { tag in
            tag.deletedAt == nil && tag.wingId == root.wingId
                && (tag.path == root.path || tag.path.hasPrefix(root.path + "/"))
        }
    }

    /// The term's value for the note — Kleene's three values (nil unknown).
    static func value(
        _ term: RuleTerm, worn: [Tag], ruleTags: [String: Tag], starred: Bool,
        legacy: (RuleTerm) -> Bool?
    ) -> Bool? {
        switch term {
        case .tag(let id):
            return !matching(id, worn: worn, ruleTags: ruleTags).isEmpty
        case .star:
            return starred
        case .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
            return legacy(term)
        case .not(let inner):
            return value(inner, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy).map { !$0 }
        case .and(let terms):
            var result: Bool? = true
            for t in terms {
                switch value(t, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy) {
                case false?: return false
                case nil: result = nil
                case true?: break
                }
            }
            return result
        case .or(let terms):
            var result: Bool? = false
            for t in terms {
                switch value(t, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy) {
                case true?: return true
                case nil: result = nil
                case false?: break
                }
            }
            return result
        }
    }

    /// The witnesses of `term` taking the value `want` — empty when the term
    /// is known to take the other value. Unknown (nil) is let through: it
    /// never blocks a witness the rest of the tree supports.
    static func walk(
        _ term: RuleTerm, want: Bool, worn: [Tag], ruleTags: [String: Tag], starred: Bool,
        legacy: (RuleTerm) -> Bool?
    ) -> Set<String> {
        let v = value(term, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy)
        if v == !want { return [] }
        switch term {
        case .tag(let id):
            // Only TRUTH is witnessed by a worn tag; a false tag term's
            // falsity is the absence of one.
            return want ? Set(matching(id, worn: worn, ruleTags: ruleTags).map(\.id)) : []
        case .star, .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo:
            return []
        case .not(let inner):
            return walk(inner, want: !want, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy)
        case .and(let terms), .or(let terms):
            // AND wanted true / OR wanted false: every term must take the
            // wanted value — all witness. AND wanted false / OR wanted true:
            // the terms that take it witness (`walk` drops the others).
            return terms.reduce(into: Set<String>()) { result, t in
                result.formUnion(walk(t, want: want, worn: worn, ruleTags: ruleTags, starred: starred, legacy: legacy))
            }
        }
    }
}
