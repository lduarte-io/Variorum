import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-d U3 — **the filter bar's two core seams** (the sitting record §18.1;
/// the 13i-b U4 mechanics underneath). (1) `observeReading(…, filter:)` HOLDS
/// the narrowed assembly (additive; nil byte-identical). (2) the association
/// read — "the book's tag association", extracted unchanged from
/// `saveFilterAsGathering` so the save door can say what the gathering will
/// gather from BEFORE it mints: what it previews is exactly what the op
/// conjoins.
@Suite("13i-d U3 — the filter bar's core seams: the held filtered read + the association preview")
struct FilterBarCoreTests {
    @Test func theAssociationPreviewIsWhatTheOpConjoins() throws {
        try withOperations { ops, db in
            let x = try ops.createTag(name: "x")
            let a = try ops.createTag(name: "a")
            let filter = RuleTerm.tag(x.id)
            // A book with a RULE (living), a book with an OUTFLOW only, a
            // hand-made book, a gathering.
            let living = try ops.createReading(
                name: "living", kind: .book, querySpec: try RuleGrammar.encode(.tag(a.id)))
            let outflow = try ops.createReading(name: "outflow", kind: .book, autoTagIDs: [a.id])
            let plain = try ops.createReading(name: "plain", kind: .book)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(a.id)))
            for (reading, kind) in [
                (living, Operations.FilterAssociation.rule), (outflow, .autoTag),
                (plain, .none), (gathering, .rule),
            ] {
                let preview = try db.read {
                    try Queries.filterAssociation($0, source: try #require(
                        try Queries.reading($0, id: reading.id)))
                }
                #expect(preview.kind == kind, "\(reading.name)")
                let saved = try ops.saveFilterAsGathering(
                    reading.id, filter: filter, name: "saved \(reading.name)")
                #expect(saved.association == kind, "\(reading.name)")
                #expect(saved.reading.querySpec
                        == (try RuleGrammar.encode(RuleGrammar.conjoin(preview.term, filter))),
                        "the minted rule IS association ∧ filter — \(reading.name)")
            }
        }
    }

    /// The held read narrows and FOLLOWS: a note tagged into the filter while
    /// the observation is held arrives; nothing is written by holding it.
    @Test func theHeldFilteredReadNarrowsAndFollowsAndWritesNothing() async throws {
        try await withOperationsAsync { ops, db in
            let x = try ops.createTag(name: "x")
            let book = try ops.createReading(name: "book", kind: .book)
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            for note in [a, b] { try ops.addPostToReading(note.id, to: book.id) }
            _ = try ops.applyTag(x.id, toPost: a.id)
            try db.clearOutbox()

            var iterator = db.observeReading(book.id, limit: 301, filter: .tag(x.id))
                .makeAsyncIterator()
            #expect(try await iterator.next()?.map(\.postID) == [a.id])
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0,
                    "holding a filtered view writes nothing")
            _ = try ops.applyTag(x.id, toPost: b.id)
            var latest: [String] = []
            for _ in 0..<5 {
                latest = try await iterator.next()?.map(\.postID) ?? []
                if latest.count == 2 { break }
            }
            #expect(latest == [a.id, b.id], "a note tagged in while held arrives")
            // nil filter: byte-identical to the unfiltered assembly.
            var plain = db.observeReading(book.id, limit: 301).makeAsyncIterator()
            #expect(try await plain.next()?.map(\.postID)
                    == (try db.read { try Queries.assembleReading($0, readingID: book.id, limit: 301) })
                        .map(\.postID))
        }
    }
}
