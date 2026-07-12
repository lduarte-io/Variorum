//
//  LifecycleFacesTests.swift
//  VariorumTests
//
//  Phase 10 Step 8 — the library-affordance faces: lifecycle ops through
//  the UI paths emit exactly the Phase 2 ops (row-level assertions), the
//  seal toggle insures the buffer before freezing, and entry-date editing
//  round-trips the picker through JournalDay validation.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("Lifecycle faces (Phase 10 Step 8)")
struct LifecycleFacesTests {
    @Test func archiveDeleteRestoreThroughTheUIPathEmitExactOps() async throws {
        try await withWorld { session, db in
            let model = LibraryViewModel(session: session)
            let post = try session.operations.createPost(title: "p")

            func container() async throws -> Row {
                try await db.read { [id = post.id] in
                    try Row.fetchOne(
                        $0, sql: "SELECT * FROM container WHERE id = ?", arguments: [id])!
                }
            }

            await model.archive(postID: post.id)
            var row = try await container()
            #expect(row["archived_at"] != nil)
            #expect(row["deleted_at"] == nil)

            await model.unarchive(postID: post.id)
            row = try await container()
            #expect(row["archived_at"] == nil)

            await model.delete(postID: post.id)
            row = try await container()
            #expect(row["deleted_at"] != nil)
            // The recovery listings see it; the library doesn't.
            let (deleted, library) = try await db.read {
                (try Queries.deletedPosts($0), try Queries.library($0))
            }
            #expect(deleted.map(\.postID) == [post.id])
            #expect(library.isEmpty)

            await model.restore(postID: post.id)
            row = try await container()
            #expect(row["deleted_at"] == nil)
            #expect(model.lastError == nil)
        }
    }

    @Test func theSealToggleFlushesInsuresAndFreezes() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            h.type(" typed", at: 5)  // dirty buffer at seal time
            h.model.toggleSeal()
            await h.settle()
            for _ in 0..<200 {
                let locked = try? await h.database.read { [postID = h.postID] db in
                    try Container.fetchOne(db, key: postID)?.locked
                }
                if locked == true { break }
                await Task.yield()
            }
            let (locked, texts, commits) = try await h.database.read { [postID = h.postID] db in
                (try Container.fetchOne(db, key: postID)?.locked ?? false,
                 try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" },
                 try Row.fetchAll(db, sql: "SELECT * FROM commit_point"))
            }
            #expect(locked, "the seal landed")
            #expect(texts == ["alpha typed"], "the buffer flushed BEFORE the freeze — nothing lost")
            #expect(commits.count == 1, "lockPost's quiet auto-commit insured the dirty buffer")
            #expect(commits[0]["kind"] == "auto")
            #expect(commits[0]["text"] == "alpha typed")

            // The header renders the seal; typing refuses and speaks.
            try h.reload()
            #expect(h.textView.isEditable == false)
            h.type("X", at: 0)
            #expect(h.model.statusMessage?.contains("sealed") == true)
            #expect(h.documentText == "alpha typed")

            // And the toggle unseals.
            h.model.toggleSeal()
            for _ in 0..<200 {
                let locked = try? await h.database.read { [postID = h.postID] db in
                    try Container.fetchOne(db, key: postID)?.locked
                }
                if locked == false { break }
                await Task.yield()
            }
            let unlocked = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.locked ?? true
            }
            #expect(!unlocked)
        }
    }

    /// Review round 1, MAJOR 1 (red-on-old): sealing from the CommitBar
    /// runs the FULL teardown contract first — "type the last line, click
    /// Seal" must never leave the open tail surface-only and permanently
    /// unmintable under the seal (the lock doctrine: the guard insures
    /// exactly what it protects).
    @Test func sealingMintsTheOpenTailBeforeTheFreeze() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            h.type("\n", at: 5)   // open the tail
            h.type("last line before sealing")
            #expect(h.model.hasOpenTail)
            h.model.toggleSeal()
            await h.settle()
            var locked = false
            for _ in 0..<400 {
                locked = (try? await h.database.read { [postID = h.postID] db in
                    try Container.fetchOne(db, key: postID)?.locked
                }) == true
                if locked { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(2))
            }
            #expect(locked, "the seal landed")
            let texts = try await h.database.read { [postID = h.postID] db in
                try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" }
            }
            #expect(texts == ["alpha", "last line before sealing"],
                    "the tail minted BEFORE the freeze — nothing is surface-only under the seal")
        }
    }

    @Test func entryDateEditingRoundTripsThroughJournalDayValidation() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            await h.model.updateEntryDate("2026-07-12")
            var entryDate = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.entryDate
            }
            #expect(entryDate == "2026-07-12")

            // A malformed day refuses at the ops boundary and speaks.
            await h.model.updateEntryDate("2026-7-12")
            entryDate = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.entryDate
            }
            #expect(entryDate == "2026-07-12", "the malformed key never landed")
            #expect(h.model.statusMessage?.isEmpty == false)

            // Clearing works.
            await h.model.updateEntryDate(nil)
            entryDate = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.entryDate
            }
            #expect(entryDate == nil)
        }
    }

    @Test func thePickerConversionRoundTripsTheDayString() {
        // The picker's Date seed and the stored day agree in both
        // directions (the local calendar, midday-anchored against DST).
        for day in ["2026-07-12", "2026-01-01", "2026-12-31", "2024-02-29"] {
            let date = CommitBar.date(fromDay: day)
            #expect(date != nil)
            #expect(JournalDay.dayString(from: date!) == day)
        }
        #expect(CommitBar.date(fromDay: "2026-7-12") == nil)
        #expect(CommitBar.date(fromDay: nil) == nil)
    }

    @Test func recoveryModelAdoptsTheQueriesVerbatim() async throws {
        try await withWorld { session, db in
            let archived = try session.operations.createPost(title: "a")
            let deleted = try session.operations.createPost(title: "d")
            try session.operations.archiveContainer(archived.id)
            try session.operations.deleteContainer(deleted.id)
            let (archivedItems, deletedItems) = try await db.read {
                (try Queries.archivedPosts($0), try Queries.deletedPosts($0))
            }
            let model = RecoveryViewModel(session: session)
            model.adopt(archived: archivedItems, deleted: deletedItems)
            #expect(model.archived.map(\.postID) == [archived.id])
            #expect(model.deleted.map(\.postID) == [deleted.id])
        }
    }
}
