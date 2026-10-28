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
}
