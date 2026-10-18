import Dependencies
import Foundation
import GRDB
import MCP
import Testing

@testable import VariorumCore
@testable import VariorumMCP
@testable import VariorumMCPSocket

// VX-371 (VX-383 U2 — the run record `notes/plans/fixes/vx-383-duplicate-note.md`, D-C-4 and
// the U2 UNIT RECORD): `duplicate_note` FILES ITS COPY INTO A BOOK, as `create_note` can. Her
// words (QUESTIONS #227, 2026-10-15): *"it seems weird to me that if an AI creates a note it can
// put it in a book with write new but it can't do that for a note it duplicated."* And the wire's
// edge of VX-372: `with_tags` (default true — her door's default; false copies no tags).
//
// - `book_id` (+ optional `section_id`): READ on the source (+ the fence, unchanged) and WRITE NEW
//   on the destination BOOK through the decision `create_note` uses; a book of another wing
//   answers the ONE not-shared shape (no oracle); a chapter that isn't the book's answers
//   `add_note_to_book`'s ONE chapter sentence; finished and full books refuse in her doors' words
//   through the one refusal chain (VX-362); an archived book takes an explicit add (AppSpec §9).
// - ORDER inside the act: the copy, then the membership (the outflow fires as on a hand-add), then
//   the `with_tags` applications — so a destination that collects one of the copy's tags takes it
//   ONCE, filed, and an owned destination's copy BELLS at another collecting book.
// - ONE client-named undo over the copy, its membership and its seats; the once grants of both
//   sides spend as one union inside the act; `scopes` grows to [book, wing].
// - The answer gains `tag_ids` + `tags` (every tag the copy wears once it lands — the applied
//   tags, then the outflow, each once: P-VX361-1's shape), `book_id`/`section_id` echoed, and
//   `landed` saying where the copy is (a collecting book that took it in included).
//
// Wire only (the SDK's own client over a real socket), so every pin compiles on the tree before
// the fix — and runs RED there: the tool ignored `book_id`, `section_id` and `with_tags` (a
// wing-level client's copy landed in the Pool, wearing its tags; a book-level client heard the
// wing's refusal), was never listed to a book grant, and answered no `tag_ids`.

private func spec(
    _ rung: MCPGrantRule.Rung, _ kind: MCPGrantRule.ScopeKind, _ id: String,
    _ duration: MCPGrantRule.Duration = .always
) -> Operations.MCPGrantSpec {
    .init(rung: rung, scopeKind: kind, scopeID: id, duration: duration)
}

private func call(
    _ connection: HarnessConnection, _ name: String, _ arguments: [String: Value]
) async throws -> (content: [Tool.Content], isError: Bool?) {
    try await connection.client.callTool(name: name, arguments: arguments)
}

private func rule(_ term: RuleTerm) throws -> String {
    try #require(try RuleGrammar.encode(term))
}

/// One `reading_post` row of a pair, as the store holds it (tombstones included).
private struct PairRow: Equatable {
    let id: String
    let status: String
    let sectionID: String?
    let deletedAt: String?
}

/// `add_note_to_book`'s ONE chapter sentence (`MCPWireRefusalCopy`).
private let chapterWords = "section_id isn't a chapter of this book (list_notes or create_section gives chapter ids)."

@Suite("VX-371 — duplicate_note files its copy into a book; with_tags", .serialized)
struct MCPDuplicateNoteFilingServerTests {
    private func liveNotes(_ h: ServerHarness) async throws -> Int {
        try await h.database.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
        }
    }

    private func consumed(_ h: ServerHarness, _ grantID: String?) async throws -> Bool {
        try await h.database.read { db in
            try String.fetchOne(db, sql: "SELECT consumed_at FROM mcp_grant WHERE id = ?", arguments: [grantID]) != nil
        }
    }

    /// Every row of the (book, note) pair, in insertion order.
    private func pairRows(_ h: ServerHarness, book: String, note: String) async throws -> [PairRow] {
        try await h.database.read { db in
            try Row.fetchAll(
                db,
                sql: """
                    SELECT id, status, section_id, deleted_at FROM reading_post
                    WHERE reading_id = ? AND post_id = ? ORDER BY rowid
                    """,
                arguments: [book, note]
            ).map { PairRow(id: $0["id"], status: $0["status"], sectionID: $0["section_id"], deletedAt: $0["deleted_at"]) }
        }
    }

    /// A book's live MEMBERS, in its order.
    private func members(_ h: ServerHarness, _ book: String) async throws -> [String] {
        try await h.database.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT post_id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member' ORDER BY position, id
                    """,
                arguments: [book])
        }
    }

    private func wornTags(_ h: ServerHarness, _ note: String) async throws -> Set<String> {
        try await h.database.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", arguments: [note]))
        }
    }

    /// A one-block note in Home wearing `tags`, applied in order (each her ordinary act).
    private func taggedNote(_ h: ServerHarness, _ title: String, tags: [VariorumCore.Tag]) throws -> Container {
        let note = try h.operations.createPost(title: title)
        _ = try h.operations.newBlock(in: note.id, text: "Some prose for \(title).", registeringUndo: false)
        for tag in tags { _ = try h.operations.applyTag(tag.id, toPost: note.id) }
        return note
    }

    // MARK: - The book road: filed in the same act, the same undo

    /// READ on the note + WRITE NEW on a BOOK files the copy at that book's END — the client's
    /// write new is the book alone (VX-371's point). The answer echoes the book and says where;
    /// ONE client-named undo takes the copy AND its membership, the redo brings the same row
    /// back; the receipt names the book and opens the copy; Activity logs the act on the book.
    /// **RED on old:** the wing's refusal (a book grant never reached the landing).
    @Test func aBookLevelWriteNewFilesTheCopyAtTheBooksEndInOneActAndOneUndo() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let earlier = try taggedNote(h, "an earlier draft", tags: [])
            _ = try h.operations.addPostToReading(earlier.id, to: book.id)
            let source = try taggedNote(h, "the essay", tags: [])
            _ = try h.operations.newBlock(in: source.id, text: "A second paragraph.", registeringUndo: false)
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, book.id))
            let depth = h.undoStack.depth

            let duplicated = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id),
            ])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(answer["source_note_id"] as? String == source.id)
            #expect(answer["book_id"] as? String == book.id, "the book echoed")
            #expect(answer["section_id"] == nil, "no chapter asked, none echoed")
            #expect(answer["landed"] as? String == "the end of \u{201C}drafts\u{201D}", "where it is, in create_note's words")
            #expect(answer["tag_ids"] as? [String] == [] && answer["tags"] as? [String] == [], "a tagless source")
            #expect((answer["blocks"] as? [[String: Any]])?.count == 2, "VX-252's records, as before")

            #expect(try await members(h, book.id) == [earlier.id, copyID], "at the book's END")
            let rows = try await pairRows(h, book: book.id, note: copyID)
            try #require(rows.count == 1)
            #expect(rows[0].status == "member" && rows[0].sectionID == nil && rows[0].deletedAt == nil)

            // ONE entry, the receipt, the log.
            #expect(h.undoStack.depth == depth + 1 && h.undoStack.topLabel == "claude-code's duplicate")
            let receipt = try #require(h.receipts.value.last)
            #expect(receipt.act == .duplicate && receipt.targetID == copyID && receipt.targetTitle == "the essay")
            #expect(receipt.detail == "drafts", "the receipt names the book")
            #expect(receipt.show == .note(noteID: copyID, blockID: nil, select: nil), "Open › opens the copy")
            let logged = try #require(try await h.database.read { try Queries.mcpActivity($0) }
                .first { $0.act == "duplicate_note" })
            #expect(logged.allowed && logged.targetKind == "book" && logged.targetID == book.id
                    && logged.targetTitle == "drafts", "Activity names the book: \(logged)")

            // ⌥⌘Z: the book is left without the copy; ⇧⌥⌘Z: the same row back.
            #expect(try h.undoStack.undo(with: h.writeOperations) == "claude-code's duplicate")
            #expect(try await members(h, book.id) == [earlier.id])
            let undone = try await pairRows(h, book: book.id, note: copyID)
            let copyStamp = try await h.database.read { try Container.fetchOne($0, key: copyID)?.deletedAt }
            #expect(undone.count == 1 && undone[0].deletedAt != nil, "the membership went with the copy")
            #expect(copyStamp != nil)
            #expect(try h.undoStack.redo(with: h.writeOperations) == "claude-code's duplicate")
            #expect(try await members(h, book.id) == [earlier.id, copyID])
            #expect(try await pairRows(h, book: book.id, note: copyID).map(\.id) == [rows[0].id], "the same row")
            await h.hangUp(connection)
        }
    }

    /// `section_id` (with `book_id`) files the copy under that chapter in the same act; the answer
    /// echoes it and `landed` names it. **RED on old:** the wing's refusal.
    @Test func aChapterFilesTheCopyUnderItAndLandedNamesIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "o ladr\u{00E3}o de raios", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "um")
            let source = try taggedNote(h, "ch 1", tags: [])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .book, book.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.read, .note, source.id))

            let duplicated = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(answer["section_id"] as? String == chapter.id, "the chapter echoed")
            #expect(answer["landed"] as? String
                    == "the end of \u{201C}o ladr\u{00E3}o de raios\u{201D}, in its chapter \u{201C}um\u{201D}")
            #expect(try await pairRows(h, book: book.id, note: copyID).map(\.sectionID) == [chapter.id])
            await h.hangUp(connection)
        }
    }

    /// Every `section_id` that isn't a live chapter of THIS book answers `add_note_to_book`'s ONE
    /// sentence and mints nothing; `section_id` without `book_id` is refused at the parse in
    /// `create_note`'s sentence. **RED on old:** the arguments were ignored — every call landed.
    @Test func everySectionIDThatIsntTheBooksChapterAnswersOneSentenceAndMintsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let gone = try h.operations.createSection(in: book.id, name: "deleted")
            try h.operations.deleteSection(gone.id)
            let other = try h.operations.createReading(name: "another book", kind: .book)
            let othersChapter = try h.operations.createSection(in: other.id, name: "theirs")
            let source = try taggedNote(h, "the essay", tags: [])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth

            for sectionID in ["no-such-chapter", gone.id, othersChapter.id] {
                let refused = try await call(connection, "duplicate_note", [
                    "note_id": .string(source.id), "book_id": .string(book.id), "section_id": .string(sectionID),
                ])
                #expect(refused.isError == true && text(refused) == chapterWords, "\(sectionID): \(text(refused))")
            }
            let refused = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "section_id": .string(othersChapter.id),
            ])
            #expect(refused.isError == true)
            #expect(text(refused) == "section_id goes with book_id: it files the note under a chapter of the book the note joins.")
            let notesAfter = try await liveNotes(h)
            #expect(notesAfter == notes && h.undoStack.depth == depth, "a refusal mints nothing")
            await h.hangUp(connection)
        }
    }

    // MARK: - No oracle: a book of another wing, a missing one, an unreached one

    /// Books never span wings, and the copy is born in the source's wing: a book of ANOTHER wing —
    /// even one the client may write new in — answers byte-identically to an id naming nothing,
    /// raises no ask and mints nothing; so does an unreached book with any `section_id`.
    /// **RED on old:** `book_id` was ignored — the copy landed in the Pool of Home.
    @Test func aBookOfAnotherWingAnswersTheOneNotSharedShapeAndRaisesNoAsk() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let elsewhere = try h.operations.createWing(name: "elsewhere")
            let theirs = try h.operations.createReading(name: "their book", kind: .book, wingId: elsewhere.id)
            let theirChapter = try h.operations.createSection(in: theirs.id, name: "theirs")
            let third = try h.operations.createWing(name: "third")
            let unreached = try h.operations.createReading(name: "unreached", kind: .book, wingId: third.id)
            let source = try taggedNote(h, "the essay", tags: [])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .wing, elsewhere.id))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth
            let asks = h.asks.value.count

            let nothing = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string("no-such-book"),
            ])
            #expect(nothing.isError == true && text(nothing) == MCPRefusalCopy.words(.notShared, .book))
            let arguments: [[String: Value]] = [
                ["book_id": .string(theirs.id)],
                ["book_id": .string(theirs.id), "section_id": .string(theirChapter.id)],
                ["book_id": .string(unreached.id)],
                ["book_id": .string("no-such-book"), "section_id": .string(theirChapter.id)],
            ]
            for extra in arguments {
                var given: [String: Value] = ["note_id": .string(source.id)]
                given.merge(extra) { _, new in new }
                let refused = try await call(connection, "duplicate_note", given)
                #expect(refused.isError == true && text(refused) == text(nothing),
                        "\(extra) answers byte-identically to an id naming nothing: \(text(refused))")
            }
            let notesAfter = try await liveNotes(h)
            #expect(notesAfter == notes && h.undoStack.depth == depth, "nothing minted, no entry")
            #expect(h.asks.value.count == asks, "no ask — no grant could ever make another wing's book the landing")
            await h.hangUp(connection)
        }
    }

    /// A client that reads the note but holds nothing on the book hears the BOOK's refusal and
    /// her ask is for the book at write new; the refused row is logged on the book, and
    /// `list_my_activity` keeps the book id the client sent. **RED on old:** the WING's refusal
    /// and the wing's ask (`book_id` ignored).
    @Test func theBooksSideOfARefusalSpeaksAsksAndIsLoggedOnTheBook() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let source = try taggedNote(h, "the essay", tags: [])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))

            let refused = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id),
            ])
            #expect(refused.isError == true && text(refused) == MCPRefusalCopy.words(.notShared, .book))
            let ask = try #require(h.asks.value.last)
            #expect(ask.scopeKind == .book && ask.scopeID == book.id && ask.rung == .writeNew && ask.title == "drafts",
                    "her ask is for the book the copy would join")
            let logged = try #require(try await h.database.read { try Queries.mcpActivity($0) }
                .first { $0.act == "duplicate_note" })
            #expect(!logged.allowed && logged.targetKind == "book" && logged.targetID == book.id)
            let listed = try json(try await call(connection, "list_my_activity", [:]))
            let entry = try #require((listed["acts"] as? [[String: Any]])?.first)
            #expect(entry["target_kind"] as? String == "book" && entry["target_id"] as? String == book.id,
                    "the id the client sent stays: \(entry)")
            await h.hangUp(connection)
        }
    }

    // MARK: - with_tags

    /// `with_tags: false` copies NO tags, so no book that collects by them hears the copy; it lands
    /// in the Pool, and the answer lists no tag. A non-boolean is refused at the parse.
    /// **RED on old:** the argument was ignored — the copy wore the tag and the book seated it.
    @Test func withTagsFalseCopiesNoTagsSoNoBookHearsTheCopy() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let essay = try h.operations.createTag(name: "essay")
            let living = try h.operations.createReading(name: "living", kind: .book, querySpec: try rule(.tag(essay.id)))
            let source = try taggedNote(h, "the essay", tags: [essay])
            #expect(try await members(h, living.id) == [source.id], "the premise: her tag seated the source")
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let notes = try await liveNotes(h)

            let malformed = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "with_tags": .string("no"),
            ])
            #expect(malformed.isError == true && text(malformed) == "with_tags must be true or false.")
            #expect(try await liveNotes(h) == notes)

            let duplicated = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "with_tags": .bool(false),
            ])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(try await wornTags(h, copyID).isEmpty, "no tag copied")
            #expect(try await pairRows(h, book: living.id, note: copyID).isEmpty, "no book heard it")
            #expect(answer["tag_ids"] as? [String] == [] && answer["tags"] as? [String] == [])
            #expect(answer["landed"] as? String == "the Pool of Home")
            await h.hangUp(connection)
        }
    }

    /// By DEFAULT the tags are applied (her door's default, P-C-3), so a book collecting one of
    /// them takes the copy in — and `landed` says so instead of "the Pool"; a book whose dial says
    /// Arrivals rings for it (an arrival is no membership, so `landed` doesn't name it); the answer
    /// lists the tags. **RED on old:** `landed` said "the Pool of Home" and no `tag_ids` came.
    @Test func byDefaultTheTagsApplySoACollectingBookTakesTheCopyInAndLandedSaysWhere() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let essay = try h.operations.createTag(name: "essay")
            let living = try h.operations.createReading(name: "living", kind: .book, querySpec: try rule(.tag(essay.id)))
            let ringing = try h.operations.createReading(
                name: "ringing", kind: .book, querySpec: try rule(.tag(essay.id)), intakeSeating: .arrivals)
            let source = try taggedNote(h, "the essay", tags: [essay])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))

            let duplicated = try await call(connection, "duplicate_note", ["note_id": .string(source.id)])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(answer["tag_ids"] as? [String] == [essay.id] && answer["tags"] as? [String] == ["essay"])
            #expect(try await members(h, living.id).contains(copyID), "the collecting book took the copy in")
            #expect(try await pairRows(h, book: ringing.id, note: copyID).map(\.status) == ["arrival"])
            #expect(answer["landed"] as? String == "\u{201C}living\u{201D}, which collects one of its tags",
                    "\(answer["landed"] ?? "-")")
            #expect(answer["book_id"] == nil, "no book asked, none echoed")
            await h.hangUp(connection)
        }
    }

    // MARK: - THE ORDER: the copy, the membership, then the tags

    /// The destination COLLECTS one of the copy's tags: the membership comes first, so the copy
    /// is ONE member, filed in its chapter, never an arrival — and the applications are then
    /// heard by the OTHER books (one the client can't read is said without its name).
    /// **RED on old:** the wing's refusal. (The ORDER's own red is the U2 record's revert check.)
    @Test func aDestinationThatCollectsItsTagTakesTheCopyOnceFiledInItsChapter() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let essay = try h.operations.createTag(name: "essay")
            let destination = try h.operations.createReading(
                name: "drafts", kind: .book, querySpec: try rule(.tag(essay.id)))
            let chapter = try h.operations.createSection(in: destination.id, name: "second drafts")
            let hidden = try h.operations.createReading(
                name: "not shared", kind: .book, querySpec: try rule(.tag(essay.id)))
            let source = try taggedNote(h, "the essay", tags: [essay])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .book, destination.id))

            let duplicated = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(destination.id), "section_id": .string(chapter.id),
            ])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            let rows = try await pairRows(h, book: destination.id, note: copyID)
            #expect(rows.count == 1 && rows.first?.status == "member" && rows.first?.sectionID == chapter.id,
                    "ONE row, a member, filed — never an arrival: \(rows)")
            #expect(try await members(h, hidden.id).contains(copyID), "the other collecting book heard the tag")
            #expect(answer["tag_ids"] as? [String] == [essay.id])
            #expect(answer["landed"] as? String
                    == "the end of \u{201C}drafts\u{201D}, in its chapter \u{201C}second drafts\u{201D}, "
                    + "and a book not shared with you, which collects one of its tags", "\(answer["landed"] ?? "-")")
            await h.hangUp(connection)
        }
    }

    /// An OWNED destination is a plain add (the copy is membered nowhere yet); a plain book that
    /// collects the copy's tag then BELLS it — the ownership table, as when she tags.
    /// **RED on old:** the wing's refusal.
    @Test func anOwnedDestinationTakesTheCopyAndAnotherCollectingBookBellsIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let essay = try h.operations.createTag(name: "essay")
            let owned = try h.operations.createReading(name: "the owned one", kind: .book)
            _ = try h.operations.setReadingOwned(owned.id, owned: true)
            let plain = try h.operations.createReading(name: "plain", kind: .book, querySpec: try rule(.tag(essay.id)))
            let source = try taggedNote(h, "the essay", tags: [essay])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, owned.id))

            let duplicated = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(owned.id),
            ])
            #expect(duplicated.isError != true, "\(text(duplicated))")
            let answer = try json(duplicated)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(try await members(h, owned.id) == [copyID])
            #expect(try await pairRows(h, book: plain.id, note: copyID).map(\.status) == ["arrival"],
                    "owned elsewhere: the plain book rings, never seats")
            #expect(answer["landed"] as? String == "the end of \u{201C}the owned one\u{201D}")
            await h.hangUp(connection)
        }
    }

    // MARK: - The destination's own refusals, in her doors' words

    /// A FINISHED book and a FULL one refuse through the one refusal chain (the app's table — the
    /// harness's `Refused: …`); a GATHERING's id is no book's (the not-shared shape, as for
    /// `create_note`); each mints nothing. An ARCHIVED book takes the explicit add (AppSpec §9's
    /// 13i-e family: no `readingArchived` refusal exists). **RED on old:** `book_id` was ignored —
    /// every call landed in the Pool.
    @Test func aFinishedOrFullBookRefusesInHerWordsAGatheringIsNoBookAndAnArchivedOneTakesIt() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let essay = try h.operations.createTag(name: "essay")
            let finished = try h.operations.createReading(name: "finished", kind: .book)
            try h.operations.lockReading(finished.id)
            let full = try h.operations.createReading(name: "full", kind: .book, maxPosts: 1)
            let occupant = try taggedNote(h, "the occupant", tags: [])
            _ = try h.operations.addPostToReading(occupant.id, to: full.id)
            let gathering = try h.operations.createReading(
                name: "gathering", kind: .gathering, querySpec: try rule(.tag(essay.id)))
            let archived = try h.operations.createReading(name: "archived", kind: .book)
            try h.operations.archiveReading(archived.id)
            let source = try taggedNote(h, "the essay", tags: [])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.writeNew, .wing, ""))
            let notes = try await liveNotes(h)
            let depth = h.undoStack.depth

            let expected: [(String, String)] = [
                (finished.id, "Refused: \(OperationError.lockedReading(id: finished.id))"),
                (full.id, "Refused: \(OperationError.readingAtCapacity(id: full.id))"),
                (gathering.id, MCPRefusalCopy.words(.notShared, .book)),
            ]
            for (bookID, words) in expected {
                let refused = try await call(connection, "duplicate_note", [
                    "note_id": .string(source.id), "book_id": .string(bookID),
                ])
                #expect(refused.isError == true && text(refused) == words, "\(bookID): \(text(refused))")
            }
            let notesAfter = try await liveNotes(h)
            #expect(notesAfter == notes && h.undoStack.depth == depth, "a refusal mints nothing")

            let landed = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(archived.id),
            ])
            #expect(landed.isError != true, "\(text(landed))")
            let copyID = try #require(try json(landed)["note_id"] as? String)
            #expect(try await members(h, archived.id) == [copyID], "an explicit add lands in an archived book")
            await h.hangUp(connection)
        }
    }

    // MARK: - Once grants: the note's and the book's, as one

    /// A refused act spends nothing (its transaction rolled back — the guard's spend with it);
    /// a landed one spends the note's once READ and the book's once WRITE NEW together.
    /// **RED on old:** the wing's refusal, not the chapter's.
    @Test func onceGrantsOnTheNoteAndTheBookSpendAsOneAndARefusedActSpendsNothing() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let chapter = try h.operations.createSection(in: book.id, name: "one")
            let source = try taggedNote(h, "once", tags: [])
            let connection = try await h.connect(as: "claude-code")
            let noteGrant = try h.approve("claude-code", spec(.read, .note, source.id, .once))
            let bookGrant = try h.operations.grantMCPAccess(
                try h.client("claude-code").id, spec(.writeNew, .book, book.id, .once))

            let refused = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id), "section_id": .string("no-such-chapter"),
            ])
            #expect(refused.isError == true && text(refused) == chapterWords, "\(text(refused))")
            let noteSpentByRefusal = try await consumed(h, noteGrant)
            let bookSpentByRefusal = try await consumed(h, bookGrant)
            #expect(!noteSpentByRefusal && !bookSpentByRefusal, "a refused act spends nothing")

            let landed = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id), "section_id": .string(chapter.id),
            ])
            #expect(landed.isError != true, "\(text(landed))")
            let noteSpent = try await consumed(h, noteGrant)
            let bookSpent = try await consumed(h, bookGrant)
            #expect(noteSpent && bookSpent, "both sides spent, as one")
            let notes = try await liveNotes(h)
            let again = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id),
            ])
            let notesAfter = try await liveNotes(h)
            #expect(again.isError == true && notesAfter == notes, "spent is spent")
            await h.hangUp(connection)
        }
    }

    // MARK: - The listing (the W-UX-14 truth pin's sense: it can land a copy now)

    /// Listed to a BOOK-level write new (it can file a copy there); never to a NOTE-level one,
    /// which can name no landing. **RED on old:** `scopes: [.wing]` — not listed to the book.
    @Test func itIsListedToABookLevelWriteNewAndNeverToANoteLevelOne() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            let note = try taggedNote(h, "the essay", tags: [])
            let connection = try await h.connect(as: "claude-code")
            let bookGrant = try #require(try h.approve("claude-code", spec(.writeNew, .book, book.id)))
            #expect(try await connection.client.listTools().tools.map(\.name).contains("duplicate_note"))
            try h.operations.revokeMCPGrant(bookGrant)
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .note, note.id))
            #expect(!(try await connection.client.listTools().tools.map(\.name)).contains("duplicate_note"))
            await h.hangUp(connection)
        }
    }

    // MARK: - The answer's tags (P-VX361-1's shape)

    /// `tag_ids` + `tags` list EVERY tag the copy wears once it lands: the applied tags in the
    /// source's application order, then the destination's OUTFLOW, each listed once (a tag both
    /// carry sits at its applied place); without tags, the outflow alone.
    /// **RED on old:** the wing's refusal (and no `tag_ids` anywhere).
    @Test func theAnswerListsEveryTagTheCopyWearsTheAppliedThenTheOutflowEachOnce() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let first = try h.operations.createTag(name: "first")
            let second = try h.operations.createTag(name: "second")
            let third = try h.operations.createTag(name: "third")
            let book = try h.operations.createReading(name: "drafts", kind: .book)
            try h.operations.setReadingOutflow(book.id, tagIDs: [third.id, first.id])
            let source = try taggedNote(h, "the essay", tags: [first, second])
            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", spec(.read, .note, source.id))
            _ = try h.operations.grantMCPAccess(try h.client("claude-code").id, spec(.writeNew, .book, book.id))

            let withTags = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id),
            ])
            #expect(withTags.isError != true, "\(text(withTags))")
            let answer = try json(withTags)
            let copyID = try #require(answer["note_id"] as? String)
            #expect(answer["tag_ids"] as? [String] == [first.id, second.id, third.id])
            #expect(answer["tags"] as? [String] == ["first", "second", "third"])
            #expect(try await wornTags(h, copyID) == [first.id, second.id, third.id], "the answer IS the store")

            let withoutTags = try await call(connection, "duplicate_note", [
                "note_id": .string(source.id), "book_id": .string(book.id), "with_tags": .bool(false),
            ])
            #expect(withoutTags.isError != true, "\(text(withoutTags))")
            let bare = try json(withoutTags)
            #expect(bare["tag_ids"] as? [String] == [third.id, first.id], "the book's outflow alone, in its order")
            #expect(bare["tags"] as? [String] == ["third", "first"])
            await h.hangUp(connection)
        }
    }
}
