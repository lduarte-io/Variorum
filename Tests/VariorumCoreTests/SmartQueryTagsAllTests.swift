import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13, Step A2 — the SmartQuerySpec `tagsAll` vocabulary (ruling R30:
/// promote one or SEVERAL tags, AND-joined or OR-joined, to a saved Book).
/// JSON vocabulary only — no migration; the v1 unknown-keys rule carries
/// old specs unchanged.
@Suite("SmartQuerySpec tagsAll (Phase 13, A2 — R30)")
struct SmartQueryTagsAllTests {
    /// Three posts: tagged `stars`, tagged `dreams`, tagged BOTH.
    private func seedTaggedWorld(
        _ ops: Operations
    ) throws -> (stars: String, dreams: String, both: String) {
        let starsTag = try ops.createTag(parent: nil, name: "stars")
        let dreamsTag = try ops.createTag(parent: nil, name: "dreams")
        let stars = try ops.createPost(title: "stars only", profile: .generic)
        let dreams = try ops.createPost(title: "dreams only", profile: .generic)
        let both = try ops.createPost(title: "both", profile: .generic)
        try ops.applyTag(starsTag.id, toPost: stars.id)
        try ops.applyTag(dreamsTag.id, toPost: dreams.id)
        try ops.applyTag(starsTag.id, toPost: both.id)
        try ops.applyTag(dreamsTag.id, toPost: both.id)
        return (stars.id, dreams.id, both.id)
    }

    private func assembled(
        _ ops: Operations, _ db: AppDatabase, spec: Queries.SmartQuerySpec
    ) throws -> Set<String> {
        let reading = try ops.createReading(
            name: "smart-\(UUID().uuidString)", kind: .smart,
            querySpec: try spec.encodedJSON())
        return Set(try db.read {
            try Queries.assembleReading($0, readingID: reading.id).map(\.postID)
        })
    }

    @Test func tagsAllRequiresEveryPathWhereTagsRequiresAny() throws {
        try withOperations { ops, db in
            let world = try seedTaggedWorld(ops)

            let andBook = try assembled(
                ops, db, spec: .init(tagsAll: ["stars", "dreams"]))
            #expect(andBook == [world.both],
                    "AND-joined promotion collects only the post carrying BOTH tags")

            let orBook = try assembled(
                ops, db, spec: .init(tags: ["stars", "dreams"]))
            #expect(orBook == [world.stars, world.dreams, world.both],
                    "OR-joined (the v1 `tags`) stays ANY-of")
        }
    }

    @Test func tagsAllUsesSubtreeSemanticsPerPath() throws {
        try withOperations { ops, db in
            let life = try ops.createTag(parent: nil, name: "life")
            let goals = try ops.createTag(parent: life.id, name: "goals")
            let dreams = try ops.createTag(parent: nil, name: "dreams")
            let post = try ops.createPost(title: "deep-tagged", profile: .generic)
            try ops.applyTag(goals.id, toPost: post.id)  // life/goals — under 'life'
            try ops.applyTag(dreams.id, toPost: post.id)

            let book = try assembled(ops, db, spec: .init(tagsAll: ["life", "dreams"]))
            #expect(book == [post.id],
                    "each AND path matches at or UNDER itself (subtree semantics)")
            let miss = try assembled(ops, db, spec: .init(tagsAll: ["life/other", "dreams"]))
            #expect(miss.isEmpty)
        }
    }

    @Test func tagsAllComposesWithTheV1FieldsByAND() throws {
        try withOperations { ops, db in
            let world = try seedTaggedWorld(ops)
            // AND across fields: tagsAll narrows what tags matched.
            let composed = try assembled(
                ops, db,
                spec: .init(tags: ["stars", "dreams"], tagsAll: ["stars"]))
            #expect(composed == [world.stars, world.both])
        }
    }

    @Test func preThirteenSpecsRoundTripByteIdentically() throws {
        // The v1 vocabulary encodes WITHOUT a tagsAll key (nil is absent,
        // not null) — stored specs from before this phase decode and
        // re-encode unchanged, and their assembly is untouched.
        let old = Queries.SmartQuerySpec(tags: ["stars"], profile: "journal")
        let json = try old.encodedJSON()
        #expect(!json.contains("tagsAll"))
        #expect(json == #"{"profile":"journal","tags":["stars"]}"#)
        let decoded = try JSONDecoder().decode(
            Queries.SmartQuerySpec.self, from: Data(json.utf8))
        #expect(decoded == old)
        #expect(try decoded.encodedJSON() == json)
    }

    @Test func emptyTagsAllIsNoConstraint() throws {
        try withOperations { ops, db in
            let world = try seedTaggedWorld(ops)
            let book = try assembled(ops, db, spec: .init(tagsAll: []))
            #expect(book.contains(world.stars) && book.contains(world.dreams)
                    && book.contains(world.both))
        }
    }
}
