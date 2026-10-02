import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13i-d U6 (a) — F-U3-4's second half: ⌘K and the Library's search listed a
/// gathering as "smart book" (seen live in 13i-d U3's walk). The search
/// catalog's book arm speaks the ruled nouns (the sitting record §1 — "smart"
/// retired app-wide, §14): a gathering is a GATHERING, and a sealed book says
/// SEALED (Finished = the table of contents is done; Sealed = the book is
/// done — §5).
@Suite("13i-d U6 — the search catalog's book nouns")
struct CatalogDetailWordsTests {
    @Test func theCatalogNamesEachKindOfBookTruthfully() throws {
        try withOperations { ops, db in
            let gathering = try ops.createReading(
                name: "odes gathered", kind: .gathering,
                querySpec: try RuleGrammar.encode(.star))
            let plain = try ops.createReading(name: "odes plain", kind: .book)
            let finished = try ops.createReading(name: "odes finished", kind: .book)
            try ops.lockReading(finished.id)
            let sealed = try ops.createReading(name: "odes sealed", kind: .book)
            try ops.sealReading(sealed.id)

            let hits = try db.read { try Queries.searchCatalog($0, query: "odes", limitPerKind: 12) }
            let detail = Dictionary(
                uniqueKeysWithValues: hits.filter { $0.kind == .book }.map { ($0.id, $0.detail ?? "") })
            #expect(detail[gathering.id] == "gathering", "never \"smart book\"")
            #expect(detail[plain.id] == "book")
            #expect(detail[finished.id] == "finished book")
            #expect(detail[sealed.id] == "sealed book", "sealed is more than finished (§5)")
        }
    }
}

/// 13i-d U6 (e) — KnownIssues row 111's third item: the doors' "keeps
/// collecting" promise is true exactly when an APPLYING ACT can reach the
/// rule — intake hears a tagging act on a rule naming the tag's subtree and a
/// starring act on a rule with a star term (`intakeAfterTagging` /
/// `intakeAfterStarring`); a rule of LEGACY terms only (or dead tag terms
/// only) hears neither and collects only at catch-ups.
@Suite("13i-d U6 — which rules hear an applying act")
struct RuleHearsActsTests {
    @Test func onlyTagAndStarTermsHearAnAct() {
        #expect(RuleGrammar.hearsApplyingActs(.tag("t1")))
        #expect(RuleGrammar.hearsApplyingActs(.star))
        #expect(RuleGrammar.hearsApplyingActs(.and([.legacyProfile("journal"), .tag("t1")])))
        #expect(RuleGrammar.hearsApplyingActs(.not(.star)), "a NOT still hears the act it negates")
        #expect(!RuleGrammar.hearsApplyingActs(.legacyProfile("journal")))
        #expect(!RuleGrammar.hearsApplyingActs(
            .and([.legacyProfile("journal"), .legacyEntryDateFrom("2026-01-01")])))
        #expect(RuleGrammar.hearsApplyingActs(RuleTerm.tag("")) == false, "a dead term hears nothing")
        #expect(!RuleGrammar.hearsApplyingActs(nil))
    }

    /// The predicate is the listener's own: a legacy-only living book is NOT
    /// reached by a tagging act, so the words that say so are true.
    @Test func aLegacyOnlyLivingBookIsNotReachedByATaggingAct() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "work")
            let book = try ops.createReading(
                name: "legacy", kind: .book,
                querySpec: try RuleGrammar.encode(.legacyProfile("journal")))
            let note = try ops.createPost(title: "n", profile: .journal)
            _ = try ops.applyTag(tag.id, toPost: note.id)
            let rows = try db.fetchInt(
                "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND post_id = ?",
                [book.id, note.id]) ?? 0
            #expect(rows == 0, "no act reaches a legacy-only rule — it collects only at catch-ups")
        }
    }
}
