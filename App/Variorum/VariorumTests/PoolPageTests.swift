//
//  PoolPageTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2b, item 2 — the Pool page's redesign keeps every
//  act: the every-row "Add to Book ▾" dropdown retired as CHROME, and this
//  suite is the capability-survival pin on the ACT behind it — the pick
//  still fires `addPostToReading` through the same model road, drains the
//  pool (R30's flagship purpose), and the standing gate's refusals still
//  reach `lastError` in words.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("The Pool page's add-to-book act (pre-13u Act 10 wave 2b)")
@MainActor
struct PoolPageTests {
    @Test func theAddToBookActDrainsThePoolExactlyAsTheDropdownDid() async throws {
        try await withWorld { session, db in
            let (postID, bookID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "floating")
                let book = try ops.createReading(name: "shelfbound", kind: .curated)
                return (post.id, book.id)
            }
            let before = try await db.read { try Queries.poolPosts($0, limit: 10) }
            #expect(before.map(\.postID) == [postID])

            let model = PoolPostsModel(session: session)
            await model.addToBook(postID, readingID: bookID)
            #expect(model.lastError == nil)

            let after = try await db.read { try Queries.poolPosts($0, limit: 10) }
            #expect(after.isEmpty)
        }
    }

    @Test func aFinishedBookRefusalReachesHerInWords() async throws {
        try await withWorld { session, _ in
            let (postID, bookID) = try await session.runner.run { ops -> (String, String) in
                let post = try ops.createPost(title: "floating")
                let book = try ops.createReading(name: "done", kind: .curated)
                try ops.lockReading(book.id)
                return (post.id, book.id)
            }
            let model = PoolPostsModel(session: session)
            await model.addToBook(postID, readingID: bookID)
            // The gate speaks (fire-and-speak) — the picker offers finished
            // books with the honest mark, and picking one says why not.
            #expect(model.lastError != nil)
        }
    }
}
