//
//  SealedBookMemberDoorTests.swift
//  VariorumTests
//
//  13i-c U3 — THE NOTE'S OWN UNSEAL INSIDE A SEALED BOOK (the architect's
//  adjudication after U2: F-U2-1 RULED — `unlockPost` refuses
//  `noteInSealedBook` while a LIVE sealed book holds the note; "U3's faces:
//  the note's Unseal door inside a sealed book shows the refusal (P-2 — or
//  hides, the implementer's call with the registry's availability rule)").
//
//  THE CALL, recorded in the U3 RECORD: the door stays RENDERED and SPEAKS
//  the operation's refusal, which names the road out ("…unseal the book to
//  change it."). Every road to the note seal's toggle — Write's bar, the
//  Takes board, and the shell's fallback (⌘K "Seal / Unseal Note" where no
//  surface handles it) — is pinned to speak it, and the note stays sealed.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

/// The shared table's words for the refusal, on the Mac's roads.
private let refusalWords = "This note is in a book that is sealed \u{2014} unseal the book to change it."

@MainActor
private func withSealWorld<T>(
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

private func pump(_ seconds: TimeInterval = 0.01) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func poll(_ condition: () -> Bool) async {
    for _ in 0..<400 where !condition() {
        pump()
        await Task.yield()
    }
}

@MainActor
private func isSealed(_ db: AppDatabase, _ postID: String) async throws -> Bool {
    try await db.read { try Queries.containerHeader($0, containerID: postID)?.locked } ?? false
}

@MainActor
@Suite("A sealed book's member — its own Unseal speaks the book's refusal (13i-c U3)", .serialized)
struct SealedBookMemberDoorTests {
    @Test func theSharedWordsNameTheBooksDoor() {
        #expect(OpsRefusalCopy.message(for: OperationError.noteInSealedBook(
            postID: "n", readingID: "b")) == refusalWords)
    }

    /// Write's own seal toggle (the bar's door).
    @Test func writesSealDoorSpeaksTheRefusalAndTheNoteStaysSealed() async throws {
        try await withEditor(seedBlocks: ["alpha"]) { h in
            let book = try h.session.operations.createReading(name: "Edition", kind: .book)
            _ = try h.session.operations.addPostToReading(h.postID, to: book.id)
            try h.session.operations.sealReading(book.id)
            try h.reload()
            h.model.toggleSeal()
            await poll { h.model.statusMessage == refusalWords }
            #expect(h.model.statusMessage == refusalWords)
            #expect(try await isSealed(h.database, h.postID), "the book's promise held")
        }
    }

    /// The Takes board's seal toggle (the board's bar door).
    @Test func theTakesBoardsSealDoorSpeaksTheRefusal() async throws {
        try await withSealWorld { session, db in
            let ops = session.operations
            let post = try ops.createPost(title: "member")
            _ = try ops.newBlock(in: post.id, text: "a block.")
            let book = try ops.createReading(name: "Edition", kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)
            try ops.sealReading(book.id)
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            #expect(model.projection.sealed)
            await model.toggleSeal()
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text == refusalWords)
            #expect(try await isSealed(db, post.id))
        }
    }

    /// The shell's fallback (⌘K's "Seal / Unseal Note" where no surface
    /// handles the dispatch).
    @Test func theShellsSealFallbackSpeaksTheRefusal() async throws {
        try await withSealWorld { session, db in
            let ops = session.operations
            let post = try ops.createPost(title: "member")
            _ = try ops.newBlock(in: post.id, text: "a block.")
            let book = try ops.createReading(name: "Edition", kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)
            try ops.sealReading(book.id)
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .compare) { _ in }
            ShellActions(session: session, shell: ShellRouter()).toggleSeal()
            await poll { session.status.current?.text == refusalWords }
            #expect(session.status.current?.text == refusalWords)
            #expect(try await isSealed(db, post.id))
        }
    }

    /// Control: once the BOOK is unsealed (which reopens it, R-13ic-3), the
    /// note's own seal door is the note's again — an independently sealed
    /// note unseals by its own door.
    @Test func outsideASealedBookTheNotesOwnDoorActs() async throws {
        try await withSealWorld { session, db in
            let ops = session.operations
            let post = try ops.createPost(title: "member")
            _ = try ops.newBlock(in: post.id, text: "a block.")
            let book = try ops.createReading(name: "Edition", kind: .book)
            _ = try ops.addPostToReading(post.id, to: book.id)
            try ops.sealReading(book.id)
            try ops.unsealReading(book.id)
            try ops.lockPost(post.id)   // sealed on its own now
            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            await model.toggleSeal()
            #expect(try await isSealed(db, post.id) == false)
        }
    }
}
