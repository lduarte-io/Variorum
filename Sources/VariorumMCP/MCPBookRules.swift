import Foundation
import GRDB
import MCP
import VariorumCore

/// **A BOOK's Collecting facts and state, on the wire** (13n-b U4 — R-13nb-26
/// f: "book info carries rule/outflow/extents facts"; AF-11 F-1). Read for
/// READABLE books only (the caller's decision — AF-10 (f)'s letter). The rule
/// speaks the STORED grammar's own keys (`and` · `or` · `not` · `tag` ·
/// `star`, and the grandfathered `profile` / `entryDateFrom` / `entryDateTo`
/// read-only) with each tag named by its live PATH — the store holds ids; the
/// wire never does (a dead tag term reads `{"tag": null}`, the editor's
/// "(deleted tag)").
enum MCPBookFacts {
    static func facts(_ db: Database, readingID: String) throws -> [String: Any] {
        guard let reading = try Reading.fetchOne(db, key: readingID), reading.deletedAt == nil else { return [:] }
        let stored = RuleGrammar.read(reading.querySpec)
        var tagIDs = reading.autoTagIDs
        if case .rule(let term) = stored { tagIDs += RuleGrammar.tagIDs(of: term) }
        let paths = try Queries.tagPaths(db, ids: tagIDs)
        var facts: [String: Any] = [
            "outflow": reading.autoTagIDs.compactMap { paths[$0] },
            "new_matches": newMatchesWord(reading.intakeSeating ?? .auto),
            "finished": reading.locked,
            "sealed": reading.sealedAt != nil,
            "owned": reading.owned,
        ]
        switch stored {
        case .none: facts["rule"] = NSNull()
        case .malformed: facts["rule_unreadable"] = true
        case .rule(let term): facts["rule"] = encode(term, paths: paths)
        }
        if let target = reading.wordTarget { facts["word_target"] = target }
        if let cap = reading.maxPosts { facts["max_notes"] = cap }
        // Whether new matches arrive now: a readable rule on a live book
        // that is neither finished nor archived (`IntakeDecision.intakeRuns`'s
        // own facts, read the way the ops read them).
        facts["collecting"] = stored != .none && stored != .malformed && !reading.locked
            && reading.archivedAt == nil
        return facts
    }

    static func newMatchesWord(_ seating: IntakeSeating) -> String {
        switch seating {
        case .auto: "join"
        case .arrivals: "wait"
        }
    }

    /// The stored rule as the wire reads it — tag ids → live paths.
    static func encode(_ term: RuleTerm, paths: [String: String]) -> Any {
        switch term {
        case .and(let terms): return ["and": terms.map { encode($0, paths: paths) }]
        case .or(let terms): return ["or": terms.map { encode($0, paths: paths) }]
        case .not(let inner): return ["not": encode(inner, paths: paths)]
        case .tag(let id): return ["tag": paths[id].map { $0 as Any } ?? NSNull()]
        case .star: return ["star": true]
        case .legacyProfile(let profile): return ["profile": profile]
        case .legacyEntryDateFrom(let day): return ["entryDateFrom": day]
        case .legacyEntryDateTo(let day): return ["entryDateTo": day]
        }
    }

    /// The words for a rule the wire refuses to take (AF-11 F-1: her editor
    /// never offers a legacy term — #166(d) — and writes only tags and the
    /// star). 13s-a sweepable.
    static let legacyTermWords =
        "A rule is made of tags and starred — the old profile and date terms can be read here but never written."

    /// **The wire's rule → a `RuleTerm` whose TAG payloads are PATHS** (the
    /// op resolves them in the book's wing). One key per term, exactly the
    /// stored grammar's; legacy keys refuse; anything else is malformed.
    static func decodeRule(_ value: Value, at path: String = "rule") throws -> RuleTerm {
        guard let object = value.objectValue, object.count == 1, let (key, inner) = object.first else {
            throw MCPReadTools.ArgumentFailure(message:
                "\(path) must be one term: {\"tag\": \"path\"}, {\"star\": true}, {\"and\": […]}, {\"or\": […]} or {\"not\": …}.")
        }
        switch key {
        case "and", "or":
            guard let items = inner.arrayValue, !items.isEmpty else {
                throw MCPReadTools.ArgumentFailure(message: "\(path).\(key) must list at least one term.")
            }
            let terms = try items.enumerated().map { try decodeRule($1, at: "\(path).\(key)[\($0)]") }
            return key == "and" ? .and(terms) : .or(terms)
        case "not":
            return .not(try decodeRule(inner, at: "\(path).not"))
        case "tag":
            guard let tagPath = inner.stringValue,
                  !tagPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { throw MCPReadTools.ArgumentFailure(message: "\(path).tag must be a tag's path, e.g. \"percy/pt-en\".") }
            return .tag(tagPath.hasPrefix("#") ? String(tagPath.dropFirst()) : tagPath)
        case "star":
            guard inner.boolValue == true else {
                throw MCPReadTools.ArgumentFailure(message:
                    "\(path).star must be true — for not-starred write {\"not\": {\"star\": true}}.")
            }
            return .star
        case "profile", "entryDateFrom", "entryDateTo":
            throw MCPReadTools.ArgumentFailure(message: legacyTermWords)
        default:
            throw MCPReadTools.ArgumentFailure(message: "\(path) names an unknown term \"\(key)\".")
        }
    }
}
