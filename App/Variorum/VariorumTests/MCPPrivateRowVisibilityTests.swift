//
//  MCPPrivateRowVisibilityTests.swift
//  VariorumTests
//
//  VX-641 — the Private row waits for the library's first AI client (the VX-648
//  run, batch 2; her ruling 2026-10-28, QUESTIONS #245 RB-10: "i think it should be
//  hidden if there's no AI to share with - otherwise it might be confusing", and her
//  third pass — the fact is VX-590's "the library has ever had a client", ONE rule
//  across the pane and the row; a note or book ALREADY marked Private always shows
//  it, because the mark syncs and clients don't). The note's row (its ▾ menu, both
//  bars — `NotePrivacyState.showsPrivateRow`) and the book's (Book Settings —
//  `BookSettingsModel.showsPrivateRow`, latched for the sheet's life) read the same
//  store fact the pane reads (`MCPLibraryClients`). Red on old by construction: the
//  rows rendered in every library.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 641))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-641 — the Private row waits for the library's first AI client", .serialized)
struct MCPPrivateRowVisibilityTests {
    @Test func theNotesRowWaitsForTheFirstClientAndNeverGoesBack() async throws {
        try await withSession { (_: AppSession, db: AppDatabase) async throws in
            let ops = Operations()
            let note = try ops.createPost(title: "a page")
            func shows() async throws -> Bool {
                try await db.read { try NotePrivacyState.read($0, postID: note.id) }.showsPrivateRow
            }
            #expect(try await shows() == false, "no AI to share with: hidden")
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            #expect(try await shows(), "a first connection request brings it")
            try ops.denyMCPClient(client.id)
            #expect(try await shows(), "ever: a Deny never takes it back")
        }
    }

    @Test func aMarkedNoteOrOneInAPrivateBookAlwaysShowsIt() async throws {
        try await withSession { (_: AppSession, db: AppDatabase) async throws in
            let ops = Operations()
            let marked = try ops.createPost(title: "marked elsewhere")
            try ops.setNotePrivate(marked.id, true)
            let book = try ops.createReading(name: "private shelf", kind: .book)
            let held = try ops.createPost(title: "held")
            _ = try ops.addPostToReading(held.id, to: book.id)
            try ops.setBookPrivate(book.id, true)
            #expect(try await db.read { try Queries.mcpLibraryHasHadClient($0) } == false, "still clientless")
            for id in [marked.id, held.id] {
                let state = try await db.read { try NotePrivacyState.read($0, postID: id) }
                #expect(state.showsPrivateRow, "a mark is never invisible: \(id)")
            }
            try ops.setNotePrivate(marked.id, false)
            #expect(try await db.read { try NotePrivacyState.read($0, postID: marked.id) }.showsPrivateRow == false,
                    "cleared in a clientless library: the menu's next open has no row")
        }
    }

    @Test func bookSettingsWaitsTooAndKeepsTheRowForTheSheet() async throws {
        try await withSession { (session: AppSession, db: AppDatabase) async throws in
            let ops = Operations()
            let book = try ops.createReading(name: "plain", kind: .book)
            let reading = try #require(try await db.read { try Reading.fetchOne($0, key: book.id) })
            let model = BookSettingsModel(session: session, readingID: book.id)
            await model.load(for: reading)
            #expect(model.showsPrivateRow == false, "clientless, unmarked: hidden")

            try ops.setBookPrivate(book.id, true)
            let marked = BookSettingsModel(session: session, readingID: book.id)
            await marked.load(for: reading)
            #expect(marked.showsPrivateRow && marked.isPrivate, "marked (synced from another Mac): shown")
            await marked.setPrivate(false, name: "plain")
            #expect(marked.isPrivate == false && marked.showsPrivateRow,
                    "cleared: the row stays where her cursor is for the sheet's life (latched)")
            let reopened = BookSettingsModel(session: session, readingID: book.id)
            await reopened.load(for: reading)
            #expect(reopened.showsPrivateRow == false, "a fresh sheet reads the rule again")

            _ = try ops.recordMCPContact(name: "claude-code", version: "1")
            let withClient = BookSettingsModel(session: session, readingID: book.id)
            await withClient.load(for: reading)
            #expect(withClient.showsPrivateRow, "once the library has had a client")
        }
    }

    /// ONE fact: the pane's sharing face and the rows read the same store
    /// answer in every client state.
    @Test func thePaneAndTheRowReadOneFact() async throws {
        try await withSession { (_: AppSession, db: AppDatabase) async throws in
            let ops = Operations()
            func agree() async throws -> Bool {
                try await db.read { db in
                    MCPPane.showsSharingFace(try MCPDoor.read(db)) == (try Queries.mcpLibraryHasHadClient(db))
                }
            }
            #expect(try await agree())
            let client = try ops.recordMCPContact(name: "claude-code", version: "1")
            #expect(try await agree())
            _ = try ops.approveMCPClient(client.id, granting: nil)
            #expect(try await agree())
            try ops.denyMCPClient(client.id)
            #expect(try await agree())
        }
    }
}
