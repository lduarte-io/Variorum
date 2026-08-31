//
//  SnippetGroupTrashTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2b (item 17) — the delete-group door's face half:
//  a deleted snippet group must be LISTABLE (TrashScope), PUT-BACKABLE
//  (TrashPutBack → restoreContainer, snippets riding the exact-stamp
//  cascade), and PURGEABLE (the kind → table mapping) exactly like every
//  other deleted thing. #77's lesson is the reason this suite exists: the
//  old road tombstoned a pool the Trash could not list — 28 scraps gone
//  with no door back — and the act-level kind fence in `NoteDeletion.run`
//  (which this wave deliberately does NOT touch) was the stopgap. The
//  ruled door is a deliberate, pool-shaped act whose road the Trash can
//  now speak for.
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@Suite("The snippet group's Trash story (pre-13u Act 10 wave 2b)")
@MainActor
struct SnippetGroupTrashTests {
    @Test func theTrashScopeListsFiltersAndBulkPurgesGroups() {
        // The surface brains: listable, filterable, taken by Empty Trash
        // (a rowed container, family-complete), purge-rooted at container.
        #expect(TrashScope.listedKinds.contains(.snippetGroup))
        #expect(TrashScope.filterKinds.contains(.snippetGroup))
        #expect(TrashScope.emptyTrashTakes(.snippetGroup))
        #expect(Queries.TrashItem.Kind.snippetGroup.purgeTable == "container")
        // And the vocabulary is the ruled one — "snippet"/"group", never
        // the model term (the K5 precedent).
        #expect(RecoveryCopy.kindLabel(.snippetGroup) == "Snippet groups")
        #expect(RecoveryCopy.rowKind(.snippetGroup) == "snippet group")
        #expect(!RecoveryCopy.rowKind(.snippetGroup).localizedCaseInsensitiveContains("pool"))
    }

    @Test func putBackRevivesTheGroupWithItsSnippetsAndSaysSo() async throws {
        try await withWorld { session, db in
            let poolID = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "drafting")
                _ = try ops.newBlock(in: pool.id, text: "kept line")
                try ops.deleteContainer(pool.id)
                return pool.id
            }
            let now = Date(timeIntervalSince1970: 1_782_864_100)
            let row = try await db.read { try Queries.trash($0, now: now) }
                .first { $0.kind == .snippetGroup }
            let item = try #require(row)
            #expect(item.id == poolID)

            let receipt = try await TrashPutBack.run(session: session, item: item)
            #expect(receipt == RecoveryCopy.putBackReceipt(.snippetGroup))
            #expect(receipt.localizedCaseInsensitiveContains("snippet group"))

            let listing = try await db.read { try Queries.poolListing($0, poolID: poolID) }
            #expect(listing.map(\.block.text) == ["kept line"])
        }
    }
}
