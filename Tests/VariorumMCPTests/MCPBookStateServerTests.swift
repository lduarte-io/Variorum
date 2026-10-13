import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-184 U5 — VX-196, THE BOOK's STATE at EDIT (R-VX184-1, her picks):
// `rename_book` (her rename doors — the E13 name guard first), `finish_book` /
// `reopen_book` (her `lockReading` / `unlockReading`), `archive_book` /
// `unarchive_book` (her `archiveReading` / `unarchiveReading`) and `delete_book`
// (her `deleteReading` — the daily Journal never deletes; an OWNED book's plain
// delete is her confirm's "book only"). ONE client-named undo entry each. A
// GATHERING is read, never changed (R-AIR-12); Private, Seal and Own stay hers
// (R-VX184-2). Written BEFORE the fix: on the pre-fix tree every tool answers
// "Unknown tool".

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

/// VX-184 ladder round 1 (the `hersAlone` overclaim): every wire call in this
/// suite expects the hers-alone columns byte-identical across it.
private func call(
    _ h: ServerHarness, _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value],
    sourceLocation: SourceLocation = #_sourceLocation
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await callKeepingHersAlone(h, connection, name, arguments, sourceLocation: sourceLocation)
}

@Suite("VX-196 — the book's state at edit: name, finish, archive, delete", .serialized)
struct MCPBookStateServerTests {
    private func reading(_ h: ServerHarness, _ id: String) throws -> Reading {
        try #require(try h.database.read { try Reading.fetchOne($0, key: id) })
    }

    private func pending(_ h: ServerHarness, _ bookID: String) throws -> Int {
        try h.database.read { try Queries.pendingArrivalCount($0, readingID: bookID) }
    }

    // (The hers-alone columns' reader moved to `ServerHarness.hersAlone()` —
    // `MCPHersAloneSupport.swift` — VX-184 ladder round 1: every suite's wire
    // calls now read it.)

    // MARK: - rename_book

    @Test func renameBookIsHerRenameWithTheNameGuardAsOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            _ = try h.operations.createReading(name: "letters", kind: .book)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))
            let before = try h.hersAlone()

            let renamed = try await call(h, connection, "rename_book", [
                "book_id": .string(book.id), "name": .string("  Drafts, second pass  "),
            ])
            #expect(renamed.isError != true, "\(text(renamed))")
            #expect(try json(renamed)["name"] as? String == "Drafts, second pass")
            #expect(try json(renamed)["changed"] as? Bool == true)
            #expect(try reading(h, book.id).name == "Drafts, second pass", "trimmed")
            #expect(h.undoStack.topLabel == "claude-code's book name")
            #expect(h.receipts.value.last?.act.rawValue == "book name")

            let same = try json(try await call(h, connection, "rename_book", [
                "book_id": .string(book.id), "name": .string("Drafts, second pass"),
            ]))
            #expect(same["changed"] as? Bool == false && h.undoStack.depth == 1, "the same name writes nothing")

            // E13 — her rename doors' guard, inside the act: a name a live book
            // wears (case-folded) refuses, nothing written.
            let taken = try await call(h, connection, "rename_book", [
                "book_id": .string(book.id), "name": .string("LETTERS"),
            ])
            #expect(taken.isError == true && text(taken).contains("duplicateBookName"), "\(text(taken))")
            let blank = try await call(h, connection, "rename_book", ["book_id": .string(book.id), "name": .string("  ")])
            #expect(blank.isError == true, "a book needs a name")

            // A finished book renames freely (her op's posture).
            try h.operations.lockReading(book.id)
            let finished = try await call(h, connection, "rename_book", [
                "book_id": .string(book.id), "name": .string("Drafts, done"),
            ])
            #expect(finished.isError != true, "\(text(finished))")
            #expect(try h.hersAlone() == before, "Private, Seal and Own untouched")

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book name")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book name")
            #expect(try reading(h, book.id).name == "drafts", "her name, back")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's book name")
            #expect(try reading(h, book.id).name == "Drafts, second pass")
            await h.hangUp(connection)
        }
    }

    // MARK: - finish_book / reopen_book

    @Test func finishAndReopenAreHerDoorsAndAFinishsUndoBringsBackWhatWaited() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let travel = try h.operations.createTag(name: "travel")
            let book = try h.operations.createReading(
                name: "travel", kind: .book, querySpec: try RuleGrammar.encode(.tag(travel.id)),
                intakeSeating: .arrivals)
            let waiting = try h.operations.createPost(title: "a trip")
            _ = try h.operations.applyTag(travel.id, toPost: waiting.id)
            #expect(try pending(h, book.id) == 1, "the applying act rang the bell")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .book, book.id))

            let finished = try await call(h, connection, "finish_book", ["book_id": .string(book.id)])
            #expect(finished.isError != true, "\(text(finished))")
            #expect(try json(finished)["finished"] as? Bool == true && json(finished)["changed"] as? Bool == true)
            #expect(try reading(h, book.id).locked)
            #expect(try pending(h, book.id) == 0, "finishing dismisses what waits at the door (§24)")
            #expect(h.undoStack.topLabel == "claude-code's finish")
            #expect(h.receipts.value.last?.act.rawValue == "finish")
            let again = try json(try await call(h, connection, "finish_book", ["book_id": .string(book.id)]))
            #expect(again["changed"] as? Bool == false && h.undoStack.depth == 1)

            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's finish")
            #expect(try !reading(h, book.id).locked)
            #expect(try pending(h, book.id) == 1, "the undo brings back exactly what the finish dismissed")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's finish")
            #expect(try reading(h, book.id).locked && pending(h, book.id) == 0)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's finish")
            #expect(try pending(h, book.id) == 1, "and again, on the redo's own stamp")

            // reopen_book — her Reopen; its undo is her Finish again.
            try h.operations.lockReading(book.id)
            let reopened = try await call(h, connection, "reopen_book", ["book_id": .string(book.id)])
            #expect(reopened.isError != true, "\(text(reopened))")
            #expect(try json(reopened)["finished"] as? Bool == false)
            #expect(try !reading(h, book.id).locked)
            #expect(h.undoStack.topLabel == "claude-code's reopen")
            let open = try json(try await call(h, connection, "reopen_book", ["book_id": .string(book.id)]))
            #expect(open["changed"] as? Bool == false)
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's reopen")
            #expect(try reading(h, book.id).locked)

            // A SEALED book: finished already (her no-op); Reopen is Unseal's,
            // and Seal is hers alone — refused in her words.
            try h.operations.unlockReading(book.id)
            _ = try h.operations.sealReading(book.id)
            let sealedFinish = try json(try await call(h, connection, "finish_book", ["book_id": .string(book.id)]))
            #expect(sealedFinish["changed"] as? Bool == false)
            let sealedReopen = try await call(h, connection, "reopen_book", ["book_id": .string(book.id)])
            #expect(sealedReopen.isError == true && text(sealedReopen).contains("readingSealed"), "\(text(sealedReopen))")
            #expect(try reading(h, book.id).sealedAt != nil, "the seal is hers")
            await h.hangUp(connection)
        }
    }

    // MARK: - archive_book / unarchive_book

    @Test func archiveAndUnarchiveAreHerDoorsAndTheUndoKeepsTheExactStamp() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let owned = try h.operations.createReading(name: "the novel", kind: .book)
            let member = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(member.id, to: owned.id)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let archived = try await call(h, connection, "archive_book", ["book_id": .string(book.id)])
            #expect(archived.isError != true, "\(text(archived))")
            #expect(try json(archived)["archived"] as? Bool == true)
            #expect(try reading(h, book.id).archivedAt != nil)
            #expect(h.undoStack.topLabel == "claude-code's book archiving")
            let twice = try await call(h, connection, "archive_book", ["book_id": .string(book.id)])
            #expect(twice.isError == true && text(twice).contains("readingAlreadyArchived"), "her op's own refusal")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book archiving")
            #expect(try reading(h, book.id).archivedAt == nil)
            let notArchived = try await call(h, connection, "unarchive_book", ["book_id": .string(book.id)])
            #expect(notArchived.isError == true && text(notArchived).contains("readingNotArchived"))

            // HER archive-with-notes on the owned book: the client's unarchive
            // brings the book AND that note back; its undo re-archives BOTH on
            // her ORIGINAL stamp (so her later unarchive returns the note too).
            _ = try h.operations.archiveReadingWithNotes(owned.id)
            let stamp = try #require(try reading(h, owned.id).archivedAt)
            let unarchived = try await call(h, connection, "unarchive_book", ["book_id": .string(owned.id)])
            #expect(unarchived.isError != true, "\(text(unarchived))")
            #expect(try reading(h, owned.id).archivedAt == nil)
            let noteArchivedAt = { try h.database.read { try Container.fetchOne($0, key: member.id)?.archivedAt } }
            #expect(try noteArchivedAt() == nil, "her unarchive's exact-stamp return")
            #expect(h.undoStack.topLabel == "claude-code's book unarchiving")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book unarchiving")
            #expect(try reading(h, owned.id).archivedAt == stamp && noteArchivedAt() == stamp,
                    "the book and its note, archived again on her own stamp")
            #expect(try reading(h, owned.id).owned, "Own is hers — untouched")
            await h.hangUp(connection)
        }
    }

    // MARK: - delete_book

    @Test func deleteBookIsHerDeleteAndTheDailyJournalNeverDeletes() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "one")
            let note = try h.operations.createPost(title: "ch 1")
            _ = try h.operations.addPostToReading(note.id, to: book.id)
            try h.operations.assignPostToSection(note.id, in: book.id, section: chapter.id)
            let owned = try h.operations.createReading(name: "the novel", kind: .book)
            let ownedNote = try h.operations.createPost(title: "its own")
            _ = try h.operations.addPostToReading(ownedNote.id, to: owned.id)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            // THE daily Journal (its own door) and a Private book.
            let entry = try h.operations.createOrOpenJournalEntry(entryDate: "2026-07-01").container
            guard case .shelved(let dailyID) = h.operations.shelveInDailyJournalBook(entry.id) else {
                Issue.record("the daily door did not file the entry")
                return
            }
            let privateBook = try h.operations.createReading(name: "mine", kind: .book)
            _ = try h.operations.setBookPrivate(privateBook.id, true)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))

            let deleted = try await call(h, connection, "delete_book", ["book_id": .string(book.id)])
            #expect(deleted.isError != true, "\(text(deleted))")
            #expect(try json(deleted)["deleted"] as? Bool == true && json(deleted)["notes_released"] as? Bool == false)
            let stamp = try #require(try reading(h, book.id).deletedAt)
            #expect(try await h.database.read { try ReadingSection.fetchOne($0, key: chapter.id)?.deletedAt } == stamp,
                    "its chapter rides the cascade")
            #expect(try await h.database.read { try Container.fetchOne($0, key: note.id)?.deletedAt } == nil,
                    "a plain book's delete never touches a note")
            #expect(h.undoStack.topLabel == "claude-code's book deletion")
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's book deletion")
            #expect(try reading(h, book.id).deletedAt == nil)
            #expect(try await h.database.read { try ReadingSection.fetchOne($0, key: chapter.id)?.deletedAt } == nil)
            let membershipBack = try await h.database.read { db in
                try Queries.noteMemberships(db, postID: note.id).map(\.book.id)
            }
            #expect(membershipBack == [book.id], "the note is back in its book")
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's book deletion")
            #expect(try reading(h, book.id).deletedAt != nil)

            // An OWNED book's plain delete is her confirm's "book only": the
            // notes go back to the Pool, whole.
            let ownedDeleted = try await call(h, connection, "delete_book", ["book_id": .string(owned.id)])
            #expect(ownedDeleted.isError != true, "\(text(ownedDeleted))")
            #expect(try json(ownedDeleted)["notes_released"] as? Bool == true)
            #expect(try await h.database.read { try Container.fetchOne($0, key: ownedNote.id)?.deletedAt } == nil)
            #expect(try await h.database.read { try Queries.noteMemberships($0, postID: ownedNote.id) }.isEmpty,
                    "bookless — the Pool")

            // THE daily Journal and a Private book are fenced AS BOOKS: the one
            // answer, nothing written.
            let unshared = MCPRefusalCopy.words(.notShared, .book)
            for (tool, id) in [("delete_book", dailyID), ("archive_book", dailyID), ("delete_book", privateBook.id),
                               ("rename_book", privateBook.id), ("delete_book", "no-such-book")] {
                var arguments: [String: Value] = ["book_id": .string(id)]
                if tool == "rename_book" { arguments["name"] = .string("x") }
                let refused = try await call(h, connection, tool, arguments)
                #expect(refused.isError == true && text(refused) == unshared, "\(tool) \(id): \(text(refused))")
            }
            #expect(try reading(h, dailyID).deletedAt == nil && reading(h, dailyID).archivedAt == nil)
            #expect(try reading(h, privateBook.id).deletedAt == nil && reading(h, privateBook.id).name == "mine")
            await h.hangUp(connection)
        }
    }

    // MARK: - A gathering is read, never changed; the rung; the one answer

    @Test func aGatheringIsReadNeverChangedAndBelowEditTheRungRefuses() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let percy = try h.operations.createTag(name: "percy")
            let gathering = try h.operations.createReading(
                name: "gathered", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(percy.id)))
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let gatheringBefore = try reading(h, gathering.id)

            // A wing EDIT grant READS the gathering (R-AIR-12) — so every write
            // aimed at it hears what it is, never "doesn't exist".
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.edit, .wing, ""))
            for (tool, extra): (String, [String: Value]) in [
                ("rename_book", ["name": .string("x")]), ("finish_book", [:]), ("reopen_book", [:]),
                ("archive_book", [:]), ("unarchive_book", [:]), ("delete_book", [:]),
            ] {
                let refused = try await call(h, connection, tool, ["book_id": .string(gathering.id)].merging(extra) { $1 })
                #expect(refused.isError == true && text(refused).contains("is a gathering"), "\(tool): \(text(refused))")
                #expect(!text(refused).contains("doesn't exist"))
            }
            #expect(try reading(h, gathering.id) == gatheringBefore, "the gathering untouched")
            #expect(h.undoStack.depth == 0 && h.receipts.value.isEmpty)
            await h.hangUp(connection)

            // A BOOK grant never reaches a gathering: the one answer.
            let bookOnly = try await h.connect(as: "booker")
            _ = try h.approve("booker", spec(.edit, .book, book.id))
            let notReached = try await call(h, bookOnly, "delete_book", ["book_id": .string(gathering.id)])
            #expect(notReached.isError == true && text(notReached) == MCPRefusalCopy.words(.notShared, .book))
            await h.hangUp(bookOnly)

            // Below edit: the rung, and the ask for edit on the book.
            let maker = try await h.connect(as: "maker")
            _ = try h.approve("maker", spec(.writeNew, .book, book.id))
            for (tool, extra): (String, [String: Value]) in [
                ("rename_book", ["name": .string("x")]), ("finish_book", [:]), ("archive_book", [:]),
                ("delete_book", [:]),
            ] {
                let refused = try await call(h, maker, tool, ["book_id": .string(book.id)].merging(extra) { $1 })
                #expect(refused.isError == true
                        && text(refused).hasPrefix("This client may only read, suggest and write new here."),
                        "\(tool): \(text(refused))")
            }
            #expect(h.asks.value.last?.clientName == "maker" && h.asks.value.last?.rung == .edit
                    && h.asks.value.last?.scopeKind == .book)
            #expect(try reading(h, book.id).name == "drafts" && reading(h, book.id).deletedAt == nil)
            await h.hangUp(maker)
        }
    }
}
