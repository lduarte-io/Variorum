//
//  BookcaseOutsideWriteTests.swift
//  VariorumTests
//
//  VX-231 (Run VX-246, U4) — THE BOOKCASE ROW'S WORDS FOLLOW A NOTE THAT
//  JOINS FROM OUTSIDE THE BOARD. VX-184 U1's live round: right after a
//  32,347-word MCP-written note joined "o ladrão de raios", the row read
//  "7 notes · 3 ch · 120w" — the held note count fresh, the one-shot word
//  figure from before the join.
//
//  The traced mechanism (the run record's U4 trace): the board holds two
//  tiers — the HELD snapshot (`ShelfViewModel.start`, blind to autosave by
//  contract) and the ONE-SHOT aggregates (`refreshAggregates`: word counts,
//  tags, archived and gathering counts, last edited), re-read only on
//  appearance and after the board's OWN acts. A join from anywhere else (an
//  MCP write, a sync apply, the Book Panel, another window) moves the held
//  half and leaves the one-shot as it was.
//
//  `aNoteJoiningFromOutsideTheBoardReReadsItsWords` is red on the pre-fix
//  tree on its designed line (W1 runs it against `DerivedData/vx246-u4-red`);
//  `typingInAMemberNoteNeverReReadsTheOneShot` guards the fix's P1 letter and
//  is green on both trees by nature (the old board never re-read at all).
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withBookcaseWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase, UserDefaults) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    // Never the Debug app's `.standard` — a scratch suite (R1-7's lesson).
    let suite = "bookcase-outside-write-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db, defaults)
    }
}

@MainActor
@Suite("Bookcase one-shot after an outside write (VX-231)", .serialized)
struct BookcaseOutsideWriteTests {
    private func settle(_ until: () -> Bool) async {
        for _ in 0..<300 where !until() { try? await Task.sleep(for: .milliseconds(10)) }
    }

    /// A note of `blocks` blocks of `words` words each, made through the
    /// operations a client's `create_note` lands on (no board door anywhere).
    private func makeNote(
        _ session: AppSession, title: String, blocks: Int, words: Int
    ) throws -> String {
        let post = try session.operations.createPost(title: title)
        for b in 0..<blocks {
            let text = (0..<words).map { "palavra\(($0 &+ b) % 50)" }.joined(separator: " ")
            _ = try session.operations.newBlock(in: post.id, text: text, registeringUndo: false)
        }
        return post.id
    }

    /// **U1's sighting, the shape exactly.** The board is up (its held
    /// snapshot running, its one-shot read on appearance); a large note then
    /// joins the book through the operations alone — what an MCP client's
    /// `add_note_to_book` does. The held count moves ("2 notes"); the WORD
    /// figure must follow it. RED on the pre-fix tree: the words stay at the
    /// small note's 3.
    @Test func aNoteJoiningFromOutsideTheBoardReReadsItsWords() async throws {
        try await withBookcaseWorld { session, db, defaults in
            let bookID = try session.operations.createReading(name: "o ladrão de raios", kind: .book).id
            let small = try makeNote(session, title: "small", blocks: 1, words: 3)
            _ = try session.operations.addPostToReading(small, to: bookID)

            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            await model.refreshAggregates()  // the board's appearance (`ShelfView`'s .task)
            await settle { model.books.first { $0.reading.id == bookID }?.postCount == 1 }
            #expect(model.wordCounts[bookID] == 3, "premise: the board read the book's words on appearance")

            // THE OUTSIDE JOIN — no board door, no `refreshAggregates` call.
            let large = try makeNote(session, title: "large write", blocks: 300, words: 40)
            _ = try session.operations.addPostToReading(large, to: bookID)
            let expected = try #require(try await db.read { try Queries.bookWordCounts($0)[bookID] })
            #expect(expected == 3 + 300 * 40, "premise: the store's own count of the book")

            await settle { model.books.first { $0.reading.id == bookID }?.postCount == 2 }
            await settle { model.wordCounts[bookID] == expected }
            let book = try #require(model.books.first { $0.reading.id == bookID })
            #expect(book.postCount == 2, "premise: the held snapshot moved — the row says 2 notes")
            #expect(model.wordCounts[bookID] == expected,
                    "the row's word figure follows the join — \(model.wordCounts[bookID] ?? -1) read, \(expected) stored")
            #expect(BookcaseRowMeta.facts(
                        book, words: model.wordCounts[bookID], progress: model.progress(for: book),
                        gatheringCount: nil, archived: model.archivedCounts[bookID] ?? 0)
                    == "2 notes \u{00B7} \(expected.formatted())w",
                    "the row as drawn pairs the fresh count with the fresh words")
        }
    }

    /// **The fix's P1 letter.** The one-shot is a store-wide read; it may
    /// follow the HELD snapshot (membership, shelves, rules), never autosave.
    /// Typing in a member note — many autosaves — re-reads nothing. Green on
    /// both trees by nature (the old board never re-read); it guards the fix.
    @Test func typingInAMemberNoteNeverReReadsTheOneShot() async throws {
        try await withBookcaseWorld { session, db, defaults in
            let bookID = try session.operations.createReading(name: "book", kind: .book).id
            let note = try makeNote(session, title: "note", blocks: 1, words: 3)
            _ = try session.operations.addPostToReading(note, to: bookID)
            let variantID = try #require(try await db.read {
                try Queries.renderPost($0, containerID: note).first?.variantID
            })

            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            await model.refreshAggregates()
            await settle { model.books.first { $0.reading.id == bookID }?.postCount == 1 }
            try? await Task.sleep(for: .milliseconds(150))
            let reads = model.oneShotReads

            var text = "palavra0 palavra1 palavra2"
            for i in 0..<40 {
                text += " typed\(i)"
                try session.operations.autosave(variantID, text: text, charDelta: 7)
            }
            try? await Task.sleep(for: .milliseconds(400))
            #expect(model.oneShotReads == reads,
                    "autosave never re-reads the store-wide one-shot (\(model.oneShotReads - reads) re-reads)")
        }
    }
}
