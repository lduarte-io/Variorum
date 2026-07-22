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

    /// 13b 4D (N34 — S4-14/S4-21): the one_block FACE over the Phase-1
    /// machinery, both halves. The mapping is the pin: OFF ⇒ per-post
    /// `.oneBlock` (entry-wide by the model's standing meaning — typing
    /// AND paste; S4-21), ON ⇒ per-post NIL (inherit the global default);
    /// the honest consequence speaks; the Takes model's chip truth
    /// follows its refresh. NO semantics change is under test — the
    /// segmentation machinery's own pins are Phase 1/2's.
    @Test func theNewlinesFaceMapsOnToInheritAndOffToOneBlock() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            // Write half: OFF ⇒ one_block.
            await h.model.setNewlinesMintBlocks(false)
            var stored = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.segmentationDefault
            }
            #expect(stored == .oneBlock)
            #expect(h.model.statusMessage?.contains("won't make new blocks") == true,
                    "the consequence speaks — future entry only")

            // ON ⇒ nil (inherit the global default, paragraph).
            await h.model.setNewlinesMintBlocks(true)
            stored = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.segmentationDefault
            }
            #expect(stored == nil)

            // Takes half: the chip truth follows the effective state.
            let takes = TakesViewModel(session: h.session, postID: h.postID)
            await takes.refreshSegmentation()
            #expect(takes.newlinesMintBlocks == true)
            await takes.setNewlinesMintBlocks(false)
            #expect(takes.newlinesMintBlocks == false, "the setter refreshes its own truth")
            stored = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.segmentationDefault
            }
            #expect(stored == .oneBlock)
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

    /// 13b 4F (N37 — S4-28.2): the deleted-books recovery door — the
    /// surface-local restore emits exactly `restoreReading`, and the book
    /// comes back whole (chapters + memberships + assignments; the core
    /// suite owns the exact-stamp semantics — this pins the FACE's road).
    @Test func theDeletedBooksDoorRestoresThroughTheModel() async throws {
        try await withWorld { session, db in
            let book = try session.operations.createReading(name: "orbit", kind: .curated)
            let post = try session.operations.createPost(title: "p", profile: .generic)
            _ = try session.operations.newBlock(in: post.id, text: "Prose.", at: .end)
            _ = try session.operations.addPostToReading(post.id, to: book.id)
            let chapter = try session.operations.createSection(in: book.id, name: "I")
            try session.operations.assignPostToSection(post.id, in: book.id, section: chapter.id)
            try session.operations.deleteReading(book.id)

            let listed = try await db.read { try Queries.deletedReadings($0) }
            #expect(listed.map(\.id) == [book.id], "the recovery surface's feed")

            let model = RecoveryViewModel(session: session)
            await model.restoreReading(book.id)
            #expect(model.lastError == nil)
            let (live, sections, assignments) = try await db.read { [bookID = book.id] db in
                (try Queries.reading(db, id: bookID) != nil,
                 try Queries.readingSections(db, readingID: bookID).map(\.id),
                 try Queries.sectionAssignments(db, readingID: bookID))
            }
            #expect(live)
            #expect(sections == [chapter.id])
            #expect(assignments == [post.id: chapter.id], "the book is back WHOLE")

            // The door speaks on a refused restore (fire-and-speak) — IN
            // APP WORDS (13b Stage 4 ladder round 1, MINOR-2; pin
            // STRENGTHENED in place, justified: the old expectation
            // accepted the raw enum dump "Refused: readingNotDeleted(id:
            // …)", which is exactly the class the finding ends — the
            // double-click path must speak plainly).
            await model.restoreReading(book.id)
            let refusal = try #require(model.lastError)
            #expect(!refusal.contains("readingNotDeleted"),
                    "no enum dump on the double-click path: \(refusal)")
            #expect(refusal.contains("already restored"),
                    "the refusal says the true state in app words: \(refusal)")
        }
    }

    /// 13b Stage 4 ladder round 1, MINOR-2 — the copy-level pin (red on
    /// old: all three fell to the default "Refused: <enum dump>" case):
    /// the two Stage 4 recovery-door errors and the extent belt speak app
    /// words, never a raw enum dump. `readingNotFound` is NOT reachable
    /// through the restore door today (no hard-delete path exists — GC is
    /// Phase 12's), but `liveReading` throws it from every reading op, so
    /// the copy serves as the shared belt.
    @Test func stage4RefusalCopyCarriesNoEnumDump() {
        let cases: [(OperationError, String)] = [
            (.readingNotDeleted(id: "r1"), "readingNotDeleted"),
            (.readingNotFound(id: "r1"), "readingNotFound"),
            (.invalidExtent(value: 0), "invalidExtent"),
        ]
        for (error, dump) in cases {
            let copy = OpsRefusalCopy.message(for: error)
            #expect(!copy.contains(dump), "app words, not an enum dump: \(copy)")
            #expect(!copy.hasPrefix("Refused:"), "the default-case prefix is the dump's marker: \(copy)")
        }
    }

    /// 13b 4F (N36 — S4-28.1): the per-post word-target face's model
    /// halves share ONE op; the Write half's truth is the observed header,
    /// the Takes half refreshes at its chip's cadence; the sealed refusal
    /// (the recorded PROVISIONAL) speaks.
    @Test func theWordTargetFaceHalvesShareOneOpAndSpeak() async throws {
        try await withEditor(seedBlocks: ["alpha words here"]) { h in
            await h.model.setPostWordTarget(5_000)
            let stored = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.wordTarget
            }
            #expect(stored == 5_000)
            #expect(h.model.statusMessage?.contains("never a wall") == true)
            try h.reload()
            #expect(h.model.header?.wordTarget == 5_000,
                    "the bar's face reads the observed header")

            // The Takes half: same op, chip-cadence refresh.
            let takes = TakesViewModel(session: h.session, postID: h.postID)
            await takes.refreshSegmentation()
            #expect(takes.postWordTarget == 5_000)
            await takes.setPostWordTarget(nil)
            #expect(takes.postWordTarget == nil, "the setter refreshes its own truth")

            // The sealed refusal (PROVISIONAL — the 4F seal-posture call)
            // reaches the surface as speech, never silence.
            await h.model.setPostWordTarget(1_000)
            try await h.session.runner.run { [postID = h.postID] ops in
                try ops.lockPost(postID)
            }
            await h.model.setPostWordTarget(2_000)
            #expect(h.model.statusMessage?.contains("sealed") == true)
            let sealedStored = try await h.database.read { [postID = h.postID] db in
                try Container.fetchOne(db, key: postID)?.wordTarget
            }
            #expect(sealedStored == 1_000, "the sealed post's target never moved")

            // The label's progress arithmetic (the face's one formula).
            #expect(WordTargetFaceCopy.progressSegment(words: 1_250, target: 5_000)
                    == "25% of 5,000w target")
        }
    }
}
