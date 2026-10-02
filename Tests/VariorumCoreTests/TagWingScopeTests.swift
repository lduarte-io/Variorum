import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// A tag row in a wing, written RAW (the ids are fresh UUIDs so they never
/// collide with the harness's incrementing ones). Shared by the U5 wing pins:
/// the fixture is independent of the tag ops under test, so each pin runs —
/// and fails honestly — on the pre-fix ops.
func insertWingTag(
    _ db: AppDatabase, name: String, wing: String, parent: VariorumCore.Tag? = nil
) throws -> VariorumCore.Tag {
    let now = Date(timeIntervalSince1970: 1_782_864_000)
    let tag = VariorumCore.Tag(
        id: UUID().uuidString, parentId: parent?.id, name: name,
        path: parent.map { "\($0.path)/\(name)" } ?? name, wingId: wing,
        createdAt: now, updatedAt: now)
    try db.write { try tag.insert($0) }
    return tag
}

/// 13i-d U5 — F-U5-2's TAG half: the tag vocabulary is PER-WING (R-13ia-1 —
/// uniqueness `(wing_id, path)`), but four tag ops and three subtree reads
/// matched by PATH across every wing. Latent while Home was the only wing;
/// the switcher makes a second wing (with its own `writing`) ordinary, and
/// then renaming or deleting Home's `writing` reached into the other library
/// — the sitting record §9's "nothing should cross wings", broken by the
/// machinery itself. Each pin is RED on the pre-fix ops (the trace: the
/// subtree predicates `substr(path, 1, ?) = ?` and the uniqueness probe
/// `path = ?` carry no `wing_id`).
@Suite("13i-d U5 — the tag ops are wing-honest")
struct TagWingScopeTests {
    /// Home and a second wing each hold `writing` + `writing/draft`.
    private func twins(_ ops: Operations, _ db: AppDatabase) throws
        -> (wing: Wing, home: VariorumCore.Tag, homeDraft: VariorumCore.Tag, other: VariorumCore.Tag, otherDraft: VariorumCore.Tag)
    {
        let wing = try ops.createWing(name: "Imports")
        let home = try ops.createTag(name: "writing")
        let homeDraft = try ops.createTag(parent: home.id, name: "draft")
        let other = try insertWingTag(db, name: "writing", wing: wing.id)
        let otherDraft = try insertWingTag(db, name: "draft", wing: wing.id, parent: other)
        return (wing, home, homeDraft, other, otherDraft)
    }

    private func path(_ db: AppDatabase, _ id: String) throws -> String? {
        try db.fetchString("SELECT path FROM tag WHERE id = ?", [id])
    }

    @Test func renamingHomesTagRewritesOnlyHomesSubtree() throws {
        try withOperations { ops, db in
            let t = try twins(ops, db)
            try ops.renameTag(t.home.id, newName: "prose")
            #expect(try path(db, t.homeDraft.id) == "prose/draft")
            #expect(try path(db, t.otherDraft.id) == "writing/draft",
                    "the other wing's subtree is another library's — untouched")
        }
    }

    @Test func deletingHomesTagTombstonesOnlyHomesSubtree() throws {
        try withOperations { ops, db in
            let t = try twins(ops, db)
            try ops.deleteTag(t.home.id)
            #expect(try db.deletedAt("tag", t.homeDraft.id) != nil)
            #expect(try db.deletedAt("tag", t.otherDraft.id) == nil,
                    "the other wing's writing/draft survives")
            #expect(try db.deletedAt("tag", t.other.id) == nil)
        }
    }

    /// A path another wing wears is not a collision — the twin is legal.
    @Test func aPathIsFreeInEachWing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            _ = try insertWingTag(db, name: "writing", wing: wing.id)
            let home = try ops.createTag(name: "writing")
            #expect(home.wingId == "")
            // …and a rename into a path only ANOTHER wing wears is free too.
            let notes = try ops.createTag(name: "notes")
            _ = try insertWingTag(db, name: "journal", wing: wing.id)
            try ops.renameTag(notes.id, newName: "journal")
            #expect(try path(db, notes.id) == "journal")
        }
    }

    @Test func theSubtreeReadsStayInTheRootsWing() throws {
        try withOperations { ops, db in
            let t = try twins(ops, db)
            let subtree = try db.read { try Queries.tagSubtree($0, rootID: t.home.id) }
            #expect(Set(subtree.map(\.id)) == [t.home.id, t.homeDraft.id])
            // A note in the OTHER wing wearing its own `writing/draft` never
            // lists under Home's `writing` (the folder view / everything-tagged).
            let away = try ops.createPost(title: "away", wingId: t.wing.id)
            try db.write {
                try PostTag(
                    id: UUID().uuidString, tagId: t.otherDraft.id, postId: away.id,
                    createdAt: Date(timeIntervalSince1970: 1_782_864_000)
                ).insert($0)
            }
            let listed = try db.read { try Queries.taggedPostItems($0, tagID: t.home.id) }
            #expect(!listed.map(\.postID).contains(away.id))
            let everything = try db.read {
                try Queries.everythingTagged($0, tagID: t.home.id, includeSubtree: true)
            }
            #expect(!everything.postIDs.contains(away.id))
        }
    }

    /// A tag of another wing does not exist in this note's library — the
    /// one application road refuses it (`tagNotFound`, the outflow check's
    /// own answer for a foreign-wing tag).
    @Test func applyingAnotherWingsTagRefuses() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let foreign = try insertWingTag(db, name: "imported", wing: wing.id)
            let note = try ops.createPost(title: "home note")
            #expect(throws: OperationError.tagNotFound(id: foreign.id)) {
                try ops.applyTag(foreign.id, toPost: note.id)
            }
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ?", [note.id]) == 0)
        }
    }

    /// `createTag(wingID:)` mints in the named wing; a child is born in its
    /// parent's wing; a dead wing refuses; `allTags(wingID:)` lists one wing.
    @Test func tagsAreBornAndListedPerWing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Imports")
            let root = try ops.createTag(name: "writing", wingID: wing.id)
            let child = try ops.createTag(parent: root.id, name: "draft")
            #expect(root.wingId == wing.id && child.wingId == wing.id)
            #expect(child.path == "writing/draft")
            let home = try ops.createTag(name: "home-only")
            let inWing = try db.read { try Queries.allTags($0, wingID: wing.id) }
            #expect(inWing.map(\.id) == [root.id, child.id])
            let inHome = try db.read { try Queries.allTags($0, wingID: "") }
            #expect(inHome.map(\.id) == [home.id])
            #expect(try db.read { try Queries.allTags($0) }.count == 3, "nil = every wing")
            let dead = try ops.createWing(name: "Brief")
            try ops.deleteWing(dead.id)
            #expect(throws: OperationError.wingNotFound(id: dead.id)) {
                try ops.createTag(name: "x", wingID: dead.id)
            }
        }
    }
}
