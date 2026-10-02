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
