//
//  MCPCreateNotePlacementServerTests.swift
//  VariorumMCPTests
//
//  VX-1039 (the VX-1036 run, batch 1) — THE WIRE'S MINT PLACEMENT, PINNED AS
//  UNCHANGED. Her book doors learn where a new note is born (N-2: a chapter's
//  own "+" at that chapter's end; the general doors after the note she is on),
//  and `Operations.newPostInReading` gains a placement for them. The wire's
//  `create_note` with `book_id` is NOT one of those doors: MCPSpec says it files
//  the note under the book's order — at the END of the book, or with
//  `section_id` under that chapter — and it mints through `mintNoteEntry` →
//  `addPostToReading(…, at: .end)` + the section write, never through
//  `newPostInReading`. This suite is the belt that keeps it so: GREEN on the
//  pre-batch tree and green after (an unchanged-behavior pin, not a
//  red-on-old one — nothing about the wire is meant to move).
//

import Foundation
import GRDB
import MCP
import Testing
@testable import VariorumCore
@testable import VariorumMCP

@Suite("VX-1039 — create_note with book_id still files at the book's end (or its chapter's end)", .serialized)
struct MCPCreateNotePlacementServerTests {
    private func writeNew(_ bookID: String) -> Operations.MCPGrantSpec {
        .init(rung: .writeNew, scopeKind: .book, scopeID: bookID, duration: .always)
    }

    /// Every live row of the book (members and arrivals alike — the one list
    /// a position is minted in), as (post, position, section).
    private func rows(
        _ h: ServerHarness, _ bookID: String
    ) async throws -> [(post: String, position: String, section: String?)] {
        try await h.database.read { db in
            try Row.fetchAll(db, sql: """
                SELECT post_id, position, section_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL
                ORDER BY position, id
                """, arguments: [bookID])
                .map { (post: $0["post_id"], position: $0["position"], section: $0["section_id"]) }
        }
    }

    private func assembled(_ h: ServerHarness, _ bookID: String) async throws -> [Queries.ReadingEntry] {
        try await h.database.read { try Queries.assembleReading($0, readingID: bookID) }
    }

    @Test func aWireMintLandsAtTheBooksEndAndUnderItsChapterAtTheChaptersEnd() async throws {
        let h = try ServerHarness()
        defer { h.tearDown() }
        try await h.within {
            let ops = h.operations
            // A chaptered book: A and B in "one", C in "two", D unfiled — and
            // a note waiting at the door (an arrival holds a position too).
            let book = try ops.createReading(name: "the allotment year", kind: .book)
            let one = try ops.createSection(in: book.id, name: "one")
            let two = try ops.createSection(in: book.id, name: "two")
            var members: [String] = []
            for name in ["A", "B", "C", "D"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: book.id)
                members.append(post.id)
            }
            try ops.assignPostToSection(members[0], in: book.id, section: one.id)
            try ops.assignPostToSection(members[1], in: book.id, section: one.id)
            try ops.assignPostToSection(members[2], in: book.id, section: two.id)
            // A plain book beside it, unchaptered.
            let plain = try ops.createReading(name: "a plain book", kind: .book)
            var plainMembers: [String] = []
            for name in ["P", "Q", "R"] {
                let post = try ops.createPost(title: name)
                try ops.addPostToReading(post.id, to: plain.id)
                plainMembers.append(post.id)
            }

            let connection = try await h.connect(as: "claude-code")
            _ = try h.approve("claude-code", writeNew(book.id))
            let client = try h.client("claude-code").id
            _ = try ops.grantMCPAccess(client, writeNew(plain.id))

            // 1. book_id alone: the END of the book, in no chapter.
            let before = try await rows(h, book.id)
            let bare = try await connection.client.callTool(name: "create_note", arguments: [
                "book_id": .string(book.id), "text": .string("Seed order."),
            ])
            #expect(bare.isError != true, "\(text(bare))")
            let bareID = try #require(try json(bare)["note_id"] as? String)
            let afterBare = try await rows(h, book.id)
            let bareRow = try #require(afterBare.first { $0.post == bareID })
            #expect(bareRow.section == nil, "no chapter named, no chapter written")
            #expect(before.allSatisfy { $0.position < bareRow.position },
                    "born after every live row of the book — its end")
            #expect(try await assembled(h, book.id).last?.postID == bareID,
                    "the book's order shows it last (the unfiled group trails)")

            // 2. book_id + section_id: under that chapter, at the chapter's end
            //    (still the end of the book's one position list).
            let beforeFiled = try await rows(h, book.id)
            let filed = try await connection.client.callTool(name: "create_note", arguments: [
                "book_id": .string(book.id), "section_id": .string(one.id), "text": .string("Couch grass."),
            ])
            #expect(filed.isError != true, "\(text(filed))")
            let filedID = try #require(try json(filed)["note_id"] as? String)
            let filedRow = try #require(try await rows(h, book.id).first { $0.post == filedID })
            #expect(filedRow.section == one.id, "filed under the chapter it named")
            #expect(beforeFiled.allSatisfy { $0.position < filedRow.position },
                    "born at the end of the book's position list, as before this batch")
            let order = try await assembled(h, book.id)
            let inOne = order.filter { $0.sectionID == one.id }.map(\.postID)
            #expect(inOne == [members[0], members[1], filedID], "the chapter's last note")

            // 3. A plain book: the end.
            let plainMint = try await connection.client.callTool(name: "create_note", arguments: [
                "book_id": .string(plain.id), "text": .string("The shed door."),
            ])
            #expect(plainMint.isError != true, "\(text(plainMint))")
            let plainID = try #require(try json(plainMint)["note_id"] as? String)
            #expect(try await assembled(h, plain.id).map(\.postID) == plainMembers + [plainID])
            await h.hangUp(connection)
        }
    }
}
