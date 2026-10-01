import Foundation

/// The 13i rule grammar (sitting record §3 + §19, QUESTIONS #166(d)) — the
/// ONE predicate language stored in `reading.query_spec` since v1_18, read
/// by a GATHERING's assembly and (from 13i-b) by a living book's intake.
///
/// v2 is a boolean tree: AND / OR / NOT over TAG and STAR terms.
/// - A tag term holds the tag's ID, never its path (§19's ruling —
///   `renameTag` can never break a rule); matching is SUBTREE by the live
///   tag's path (`video/` matches `video/ideas`); a term whose tag is dead
///   or missing matches NOTHING and displays "(deleted tag)".
/// - LEGACY terms (profile, entry-date bounds) exist solely because v1
///   specs carried them: the v1_18 migration grandfathers them so no
///   existing gathering changes its assembly. No editing face ever offers
///   them (#166(d): time-shaped predicates stay views, not gatherings).
///
/// Encoding: one-key JSON objects, so the stored value reads itself —
/// `{"and":[…]}` · `{"or":[…]}` · `{"not":…}` · `{"tag":"<id>"}` ·
/// `{"star":true}` · `{"profile":"…"}` · `{"entryDateFrom":"…"}` ·
/// `{"entryDateTo":"…"}`. A NULL column is "no rule" (a gathering with no
/// rule assembles every post — the standing NULL-spec rule); a malformed
/// value reads as no rule (today's tolerance, kept).
public indirect enum RuleTerm: Equatable, Sendable {
    case and([RuleTerm])
    case or([RuleTerm])
    case not(RuleTerm)
    /// The tag's ID. `""` is the deliberate dead term (a v1 path that
    /// resolved to no tag row at migration) — matches nothing, forever.
    case tag(String)
    /// The note is starred.
    case star
    case legacyProfile(String)
    case legacyEntryDateFrom(String)
    case legacyEntryDateTo(String)
}

extension RuleTerm: Codable {
    private enum Key: String, CodingKey, CaseIterable {
        case and, or, not, tag, star, profile, entryDateFrom, entryDateTo
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Key.self)
        // Exactly one key names the term; several (or none) is malformed.
        let present = Key.allCases.filter { c.contains($0) }
        guard present.count == 1, let key = present.first else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "a rule term is exactly one key; got \(present.map(\.rawValue))"))
        }
        switch key {
        case .and: self = .and(try c.decode([RuleTerm].self, forKey: .and))
        case .or: self = .or(try c.decode([RuleTerm].self, forKey: .or))
        case .not: self = .not(try c.decode(RuleTerm.self, forKey: .not))
        case .tag: self = .tag(try c.decode(String.self, forKey: .tag))
        case .star:
            guard try c.decode(Bool.self, forKey: .star) else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: decoder.codingPath,
                    debugDescription: "{\"star\":false} is not a term — use {\"not\":{\"star\":true}}"))
            }
            self = .star
        case .profile: self = .legacyProfile(try c.decode(String.self, forKey: .profile))
        case .entryDateFrom: self = .legacyEntryDateFrom(try c.decode(String.self, forKey: .entryDateFrom))
        case .entryDateTo: self = .legacyEntryDateTo(try c.decode(String.self, forKey: .entryDateTo))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: Key.self)
        switch self {
        case .and(let ts): try c.encode(ts, forKey: .and)
        case .or(let ts): try c.encode(ts, forKey: .or)
        case .not(let t): try c.encode(t, forKey: .not)
        case .tag(let id): try c.encode(id, forKey: .tag)
        case .star: try c.encode(true, forKey: .star)
        case .legacyProfile(let p): try c.encode(p, forKey: .profile)
        case .legacyEntryDateFrom(let d): try c.encode(d, forKey: .entryDateFrom)
        case .legacyEntryDateTo(let d): try c.encode(d, forKey: .entryDateTo)
        }
    }
}

public enum RuleGrammar {
    /// What a stored `query_spec` value says — THREE states, because the
    /// standing v1 tolerance treats them differently and every consumer
    /// keeps its own letter: a NULL column is NO RULE (a gathering with no
    /// rule assembles every post); a MALFORMED value fails CLOSED at the
    /// assembly (the gathering shows nothing; the Pool excludes nothing;
    /// the collect door refuses "unreadable") — never silently match-all.
    public enum ReadResult: Equatable, Sendable {
        case none
        case rule(RuleTerm)
        case malformed
    }

    public static func read(_ json: String?) -> ReadResult {
        guard let json, !json.isEmpty else { return .none }
        guard let term = try? JSONDecoder().decode(RuleTerm.self, from: Data(json.utf8)) else {
            return .malformed
        }
        return .rule(term)
    }

    /// The two-state convenience where malformed and none coincide (the
    /// write-path sniff; counts). Assembly-side consumers use `read`.
    public static func decode(_ json: String?) -> RuleTerm? {
        if case .rule(let term) = read(json) { return term }
        return nil
    }

    /// The canonical stored encoding (sorted keys, stable bytes).
    public static func encode(_ term: RuleTerm?) throws -> String? {
        guard let term else { return nil }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return String(decoding: try encoder.encode(term), as: UTF8.self)
    }

    /// The v1 → v2 conversion (the v1_18 migration's brain, also the
    /// bridge under every door that still COLLECTS a rule as the v1 draft
    /// shape until 13i-b's grammar faces land). `resolvePath` answers a v1
    /// tag PATH with the tag ID to reference — the caller resolves against
    /// LIVE tags first, then tombstoned (the dead term still displays
    /// "(deleted tag)"), and answers nil for a path no row ever carried
    /// (which becomes the deliberate dead term `""`).
    ///
    /// Shape preserved exactly: `tags` was OR-of-subtrees, `tagsAll` was
    /// AND-of-subtrees, profile/date bounds were conjuncts. An empty draft
    /// converts to NO RULE (nil — matches every post, the v1 empty-spec
    /// behavior).
    public static func fromLegacy(
        tags: [String]?, tagsAll: [String]?, profile: String?,
        entryDateFrom: String?, entryDateTo: String?,
        resolvePath: (String) -> String?
    ) -> RuleTerm? {
        var conjuncts: [RuleTerm] = []
        if let profile { conjuncts.append(.legacyProfile(profile)) }
        if let entryDateFrom { conjuncts.append(.legacyEntryDateFrom(entryDateFrom)) }
        if let entryDateTo { conjuncts.append(.legacyEntryDateTo(entryDateTo)) }
        if let tags, !tags.isEmpty {
            let terms = tags.map { RuleTerm.tag(resolvePath($0) ?? "") }
            conjuncts.append(terms.count == 1 ? terms[0] : .or(terms))
        }
        if let tagsAll {
            conjuncts.append(contentsOf: tagsAll.map { RuleTerm.tag(resolvePath($0) ?? "") })
        }
        guard !conjuncts.isEmpty else { return nil }
        return conjuncts.count == 1 ? conjuncts[0] : .and(conjuncts)
    }

    /// Every tag ID the tree references (the rule editor's draft reader and
    /// 13i-b's intake listener both need the set).
    public static func tagIDs(of term: RuleTerm?) -> Set<String> {
        guard let term else { return [] }
        switch term {
        case .and(let ts), .or(let ts): return ts.reduce(into: []) { $0.formUnion(tagIDs(of: $1)) }
        case .not(let t): return tagIDs(of: t)
        case .tag(let id): return id.isEmpty ? [] : [id]
        case .star, .legacyProfile, .legacyEntryDateFrom, .legacyEntryDateTo: return []
        }
    }
}
