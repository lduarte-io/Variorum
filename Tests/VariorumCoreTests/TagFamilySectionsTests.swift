import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-d U3 — **the tag-family section rule, one fragment, two readers** (the
/// sitting record §3: a gathering's tag-family grouped DISPLAY, never real
/// chapters; §17(f): the book Index's grouped-by control). `assembleReading`'s
/// stored grouping tag and `Queries.tagFamilySections` (the Index's VIEW-LOCAL
/// grouped-by) read the SAME SQL fragment, so where a note sits can never
/// differ between them; `Queries.tagsWorn` lists the tags the shown notes
/// wear (the families menu, the filter bar's tag menu). Both reads are
/// `post_tag` + `tag` only — a held observation never wakes on autosave.
@Suite("13i-d U3 — the tag-family sections + the worn tags (the grouped-by control's reads)")
struct TagFamilySectionsTests {
    private struct World {
        let status: VariorumCore.Tag
        let draft: VariorumCore.Tag
        let done: VariorumCore.Tag
        let final: VariorumCore.Tag  // status/done/final — a grandchild
        let other: VariorumCore.Tag
        let a: Container  // #status/draft
        let b: Container  // #status/done/final (under the child "done")
        let c: Container  // #status/draft AND #status/done → the smaller child
        let d: Container  // #other only
        let e: Container  // untagged
    }

    private func world(_ ops: Operations) throws -> World {
        let status = try ops.createTag(name: "status")
        let draft = try ops.createTag(parent: status.id, name: "draft")
        let done = try ops.createTag(parent: status.id, name: "done")
        let final = try ops.createTag(parent: done.id, name: "final")
        let other = try ops.createTag(name: "other")
        let a = try ops.createPost(title: "a")
        let b = try ops.createPost(title: "b")
        let c = try ops.createPost(title: "c")
        let d = try ops.createPost(title: "d")
        let e = try ops.createPost(title: "e")
        _ = try ops.applyTag(draft.id, toPost: a.id)
        _ = try ops.applyTag(final.id, toPost: b.id)
        _ = try ops.applyTag(draft.id, toPost: c.id)
        _ = try ops.applyTag(done.id, toPost: c.id)
        _ = try ops.applyTag(other.id, toPost: d.id)
        return World(
            status: status, draft: draft, done: done, final: final, other: other,
            a: a, b: b, c: c, d: d, e: e)
    }

    /// THE ONE RULE: the view-local read files every note exactly where the
    /// stored grouping tag's assembly does — the immediate child, the
    /// smallest when several match, absent when none.
    @Test func theViewLocalSectionsAgreeWithTheAssemblysGroupingTag() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let ids = [w.a.id, w.b.id, w.c.id, w.d.id, w.e.id]
            let grouped = try ops.createReading(
                name: "grouped", kind: .book, groupingTagId: w.status.id)
            for id in ids { try ops.addPostToReading(id, to: grouped.id) }
            let assembly = try db.read { try Queries.assembleReading($0, readingID: grouped.id) }
            let sections = try db.read {
                try Queries.tagFamilySections($0, rootID: w.status.id, postIDs: ids)
            }
            #expect(sections == [
                w.a.id: "status/draft",
                w.b.id: "status/done",
                w.c.id: "status/done",  // "status/done" < "status/draft"
            ])
            for entry in assembly {
                #expect(sections[entry.postID] == entry.sectionPath, "\(entry.title ?? "")")
            }
            #expect(try db.read { try Queries.tagFamilySections($0, rootID: w.status.id, postIDs: []) }
                .isEmpty)
        }
    }

    /// The worn tags: distinct, live, by path — an application removed or a
    /// tag deleted leaves the list.
    @Test func theWornTagsAreTheLiveOnesTheNotesCarry() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let ids = [w.a.id, w.b.id, w.c.id, w.d.id, w.e.id]
            #expect(try db.read { try Queries.tagsWorn($0, postIDs: ids) }.map(\.path)
                    == ["other", "status/done", "status/done/final", "status/draft"])
            try ops.removeTag(w.other.id, fromPost: w.d.id)
            try ops.deleteTag(w.final.id)
            #expect(try db.read { try Queries.tagsWorn($0, postIDs: ids) }.map(\.path)
                    == ["status/done", "status/draft"])
            #expect(try db.read { try Queries.tagsWorn($0, postIDs: []) }.isEmpty)
        }
    }

    /// P1: neither read's REGION includes `container` or `variant` — a
    /// keystroke's autosave never wakes the Index's held grouping read — while
    /// a tagging act does.
    @Test func bothReadsAreBlindToAutosave() async throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue)
        let fetches: [@Sendable (Database) throws -> Int] = [
            { try Queries.tagFamilySections($0, rootID: "r", postIDs: ["p"]).count },
            { try Queries.tagsWorn($0, postIDs: ["p"]).count },
        ]
        for fetch in fetches {
            let region = LockIsolated<DatabaseRegion?>(nil)
            let observation = ValueObservation
                .tracking(fetch)
                .handleEvents(willTrackRegion: { tracked in region.setValue(tracked) })
            var values = observation.values(in: queue).makeAsyncIterator()
            _ = try await values.next()
            let tracked = try #require(region.value)
            #expect(!tracked.isModified(byEventsOfKind: .update(
                tableName: "container",
                columnNames: ["last_touched_at", "updated_at", "churn_accumulator", "title"])))
            #expect(!tracked.isModified(byEventsOfKind: .update(
                tableName: "variant", columnNames: ["working_text", "updated_at"])))
            #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "post_tag")))
            #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "tag")))
        }
    }
}
