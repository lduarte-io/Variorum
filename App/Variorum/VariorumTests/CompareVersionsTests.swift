//
//  CompareVersionsTests.swift
//  VariorumTests
//
//  **VX-440 batch 1 — saved versions in Compare** (VX-130 · VX-437 · VX-432;
//  the record is `notes/plans/fixes/vx-440-sheets-history-clarity.md`, LIVE
//  STATUS → Batch 1).
//
//  Her VX-437 redirect (2026-10-28): *"doesn't it seem wrong for the older
//  version of a note to NOT show up in compare?? … you should be allowed to
//  stop counting it as a version but i think that should mean that it is
//  automatically promoted."*
//
//  The board model is driven headless-in-host (the `CompareViewModelTests`
//  pattern: `CompareViewModel.read` + `adopt`, no `.task`), so every pin here
//  is about the board's own decisions, never a mounted view's timing.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withVersionsWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
private func settle(
    _ predicate: @MainActor () -> Bool, timeout: TimeInterval = 5
) async {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate(), Date() < deadline {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(10))
    }
}

@MainActor
@Suite("VX-440 batch 1 — saved versions in Compare", .serialized)
struct CompareVersionsTests {
    /// A note with one block and ONE saved moment of it — the world in which
    /// the moment is the note's only `version_of` peer.
    private func noteWithAMoment(_ session: AppSession) async throws
        -> (note: String, version: String)
    {
        try await session.runner.run { ops in
            let note = try ops.createPost(title: "the piece")
            _ = try ops.newBlock(in: note.id, text: "First block of the piece.", at: .end)
            let version = try ops.saveNoteVersion(note.id).post
            return (note.id, version.id)
        }
    }

    private func adoptFresh(
        _ model: CompareViewModel, _ db: AppDatabase, anchor: String, peers: [String]
    ) async throws {
        model.adopt(try await db.read { db in
            try CompareViewModel.read(db, anchor: anchor, peers: peers)
        })
    }

    // MARK: - VX-437: the live check's red-on-old pin (the declassify leak)

    /// **UNMARK ON A SAVED VERSION NEVER DECLASSIFIES IT** — the VX-437 live
    /// check's defect, pinned at the door that reached it.
    ///
    /// The traced mechanism (pre-fix): Compare's auto-fill seats the note's
    /// first `version_of` peer (`versionPeerSplit(…).sameWing`, no
    /// version-history fence), so a saved moment arrives in the first column
    /// wearing "unmark" (`isVersionPeer`). The button ran
    /// `unmarkPostsAsVersions(anchor, moment)`: every cross edge tombstoned on
    /// a fresh stamp no endpoint block shares, so the classifier stops naming
    /// the moment — it leaves Note ▸ Versions, rows onto the Archived surface
    /// as a sealed stranger, and Restore/Promote then refuse it
    /// (`notVersionHistory`). Her ruling: stopping counting a moment as a
    /// version PROMOTES it, after a confirm — never a bare unlink.
    ///
    /// RED on the pre-fix tree (the commit that lands this pin, before the
    /// fix): the moment is gone from Versions and listed among the archived
    /// works. GREEN once the door asks before it acts (the press itself writes
    /// nothing).
    @Test func unmarkOnASavedVersionNeverDeclassifiesIt() async throws {
        try await withVersionsWorld { session, db in
            let world = try await noteWithAMoment(session)
            let model = CompareViewModel(session: session, anchorPostID: world.note)
            // The auto-fill, as the board's first projection runs it.
            try await adoptFresh(model, db, anchor: world.note, peers: [])
            #expect(model.peerSlots.first?.postID == world.version,
                    "her VX-437 ruling: a saved version is seated by auto-fill")
            try await adoptFresh(model, db, anchor: world.note, peers: [world.version])
            #expect(model.isVersionPeer(world.version), "its column wears the unmark door")

            model.unmarkVersions(world.version)
            await settle({ model.statusMessage != nil }, timeout: 1)

            let (listed, archived) = try await db.read { db in
                (try Queries.noteVersions(db, of: world.note).map(\.postID),
                 try Queries.archivedPosts(db).map(\.postID))
            }
            #expect(listed.contains(world.version),
                    "the press took the moment out of Note ▸ Versions by a bare unlink")
            #expect(!archived.contains(world.version),
                    "…and leaked it onto the Archived surface as a sealed stranger")
            model.teardown()
        }
    }

    // MARK: - B1-3: the moment as a Compare peer

    /// **ORDINARY PEERS FIRST, THEN THE MOMENTS NEWEST FIRST** (PROVISIONAL
    /// P-440-2): the live pair is the comparison she asked for, so auto-fill
    /// seats an ordinary `version_of` peer before any moment; with only moments,
    /// the newest. Before, the order was `c.id` — a UUID coin flip.
    @Test func autoFillSeatsTheOrdinaryPeerFirstThenTheNewestMoment() async throws {
        try await withVersionsWorld { session, db in
            let (note, older, newer, twin) = try await session.runner.run { ops in
                let note = try ops.createPost(title: "the piece")
                _ = try ops.newBlock(in: note.id, text: "First block.", at: .end)
                let older = try ops.saveNoteVersion(note.id).post
                let newer = try ops.saveNoteVersion(note.id).post
                let twin = try ops.duplicateAsVersion(note.id).post
                return (note.id, older.id, newer.id, twin.id)
            }
            let model = CompareViewModel(session: session, anchorPostID: note)
            try await adoptFresh(model, db, anchor: note, peers: [])
            #expect(model.projection.versionPeers == [twin, newer, older],
                    "the duplicate first, then the moments newest-first")
            #expect(model.peerSlots.first?.postID == twin, "auto-fill takes the live pair")
            model.teardown()

            let onlyMoments = try await session.runner.run { ops in
                let other = try ops.createPost(title: "another piece")
                _ = try ops.newBlock(in: other.id, text: "Its block.", at: .end)
                _ = try ops.saveNoteVersion(other.id)
                let latest = try ops.saveNoteVersion(other.id).post
                return (other.id, latest.id)
            }
            let second = CompareViewModel(session: session, anchorPostID: onlyMoments.0)
            try await adoptFresh(second, db, anchor: onlyMoments.0, peers: [])
            #expect(second.peerSlots.first?.postID == onlyMoments.1,
                    "with only moments, the newest is seated")
            second.teardown()
        }
    }

    /// **A MOMENT'S COLUMN IS NAMED BY ITS DATE** (V6 — derived, never a title
    /// written) and says what it is; an ordinary peer is untouched.
    @Test func aMomentsColumnIsNamedByItsDateAndSaysWhatItIs() async throws {
        try await withVersionsWorld { session, db in
            let world = try await noteWithAMoment(session)
            let twin = try await session.runner.run { ops in
                try ops.duplicateAsVersion(world.note).post.id
            }
            let model = CompareViewModel(session: session, anchorPostID: world.note)
            model.peerSlots = [.init(postID: world.version), .init(postID: twin)]
            try await adoptFresh(model, db, anchor: world.note, peers: [world.version, twin])
            let born = try #require(try await db.read {
                try Container.fetchOne($0, key: world.version)
            }?.createdAt)
            #expect(model.savedVersionDate(world.version) == born)
            #expect(model.savedVersionDate(twin) == nil, "a duplicate is not a moment")
            #expect(VersionsPath.momentTitle(born) == born.formatted(date: .abbreviated, time: .shortened),
                    "the listing's own format — the moment she picked is the one named")
            #expect(model.face(for: world.version)?.sealed == true,
                    "a moment arrives sealed: its column is read-only")
            #expect(model.face(for: world.version)?.title == "the piece",
                    "and its own title is never touched (V6)")
            model.teardown()
        }
    }

    /// **UNMARK ON A MOMENT ASKS, AND THE ANSWER PROMOTES** (her VX-437 ruling;
    /// P-440-5's copy). The press writes nothing; confirming runs the shared
    /// promote — the moment leaves Versions for the Library as a regular note,
    /// unarchived and unsealed, and stays beside the note as an ordinary
    /// version (its link is kept), never on the Archived surface.
    @Test func unmarkOnAMomentAsksAndTheAnswerPromotes() async throws {
        try await withVersionsWorld { session, db in
            let world = try await noteWithAMoment(session)
            let model = CompareViewModel(session: session, anchorPostID: world.note)
            model.peerSlots = [.init(postID: world.version)]
            try await adoptFresh(model, db, anchor: world.note, peers: [world.version])

            model.unmarkVersions(world.version)
            #expect(model.pendingVersionPromote == world.version, "the door asks first")
            #expect(try await db.read { try Queries.noteVersions($0, of: world.note) }
                .map(\.postID) == [world.version], "and the press itself wrote nothing")

            await model.promoteSavedVersion(world.version)
            #expect(model.pendingVersionPromote == nil)
            #expect(model.statusMessage == VersionsPath.promoted, "the family's own receipt")
            let (listed, library, archived, row) = try await db.read { db in
                (try Queries.noteVersions(db, of: world.note).map(\.postID),
                 try Queries.library(db).map(\.postID),
                 try Queries.archivedPosts(db).map(\.postID),
                 try Container.fetchOne(db, key: world.version))
            }
            #expect(!listed.contains(world.version), "it stopped counting as a version")
            #expect(library.contains(world.version), "…and became a regular note")
            #expect(!archived.contains(world.version), "never the sealed stranger")
            #expect(row?.archivedAt == nil && row?.locked == false)

            try await adoptFresh(model, db, anchor: world.note, peers: [world.version])
            #expect(model.savedVersionDate(world.version) == nil)
            #expect(model.isVersionPeer(world.version),
                    "it stays beside the note as an ordinary version (the link is kept)")
            model.teardown()
        }
    }

    /// The ordinary road is untouched: unmark on a duplicate unlinks at once,
    /// with no ask.
    @Test func unmarkOnAnOrdinaryVersionPeerStillUnlinks() async throws {
        try await withVersionsWorld { session, db in
            let (note, twin) = try await session.runner.run { ops in
                let note = try ops.createPost(title: "the piece")
                _ = try ops.newBlock(in: note.id, text: "First block.", at: .end)
                return (note.id, try ops.duplicateAsVersion(note.id).post.id)
            }
            let model = CompareViewModel(session: session, anchorPostID: note)
            model.peerSlots = [.init(postID: twin)]
            try await adoptFresh(model, db, anchor: note, peers: [twin])
            model.unmarkVersions(twin)
            #expect(model.pendingVersionPromote == nil, "no ask on an ordinary pair")
            await settle({ model.statusMessage != nil })
            #expect(try await db.read { try Queries.versionPeerPosts($0, of: note) }.isEmpty,
                    "Sitting 9's unlink, unchanged")
            model.teardown()
        }
    }

    /// P-440-5's words, exactly (sentence case, no shouty caps — her copy rule).
    @Test func thePromoteConfirmSaysWhatTheNoteBecomes() {
        #expect(VersionsPath.stopCountingTitle == "Stop counting this as a version?")
        #expect(VersionsPath.stopCountingDetail
            == "It becomes a regular note \u{2014} unarchived, unsealed, wearing the note's current tags.")
        #expect(VersionsPath.stopCountingVerb == "Promote")
    }
}
