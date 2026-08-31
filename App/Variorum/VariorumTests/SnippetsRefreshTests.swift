//
//  SnippetsRefreshTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2b, item 17 — the Snippets refresh's pins: the
//  ruled vocabulary (SNIPPETS in every UI string — the "pool: Pool" chip's
//  words dead), the pure filter/sort and card-face brains, the group
//  management acts (create · rename · delete-to-Trash · move-between),
//  and the belt that stays: note-shaped doors still refuse pools.
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 37))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

// MARK: - The vocabulary (her fifth-wave ruling, the K5 precedent)

@Suite("Snippets — the ruled vocabulary (item 17)")
@MainActor
struct SnippetsVocabularyTests {
    @Test func noSurfaceStringSaysPoolOrScrap() {
        for string in SnippetsCopy.allStrings {
            #expect(
                !string.localizedCaseInsensitiveContains("pool"),
                "\u{201C}\(string)\u{201D} says the model term")
            #expect(
                !string.localizedCaseInsensitiveContains("scrap"),
                "\u{201C}\(string)\u{201D} says the retired word")
        }
        // And the container noun is the RULED one (W8-4: "group is also fine").
        #expect(SnippetsCopy.groupsHeader == "groups")
    }

    @Test func theSeededDefaultDisplaysAsSnippetsStorageUntouched() {
        let day = Date(timeIntervalSince1970: 1_782_864_000)
        func pool(_ title: String?) -> Container {
            Container(
                id: "p", kind: .pool, title: title, createdAt: day, updatedAt: day)
        }
        // The app's own seeded literal reads as the surface's name…
        #expect(PoolNaming.title(pool("Pool")) == "Snippets")
        // …a name she typed reads as typed, and a nameless group reads as
        // its created day (the 13k K2 rule, untouched).
        #expect(PoolNaming.title(pool("field guide")) == "field guide")
        #expect(PoolNaming.title(pool(nil))
            == DisplayTitle.pool(title: nil, createdAt: day))
    }
}

// MARK: - The pure brains

@Suite("Snippets — filter, sort & card face (item 17)")
@MainActor
struct SnippetFilterTests {
    private func item(
        _ id: String, pool: String, text: String, tags: [String] = [],
        takes: Int = 1, updated: String? = nil
    ) -> Queries.PoolItem {
        Queries.PoolItem(
            block: Queries.RenderedBlock(
                blockID: id, placementID: "pl-\(id)", position: "a",
                variantID: "v-\(id)", text: text, activeVariantCount: takes,
                liveVariantCount: takes, commentCount: 0, variantLocked: false),
            tagPaths: tags, poolID: pool, updatedAt: updated)
    }

    @Test func scopeQueryAndTagFilterCompose() {
        let items = [
            item("1", pool: "a", text: "the opening line", tags: ["voice"]),
            item("2", pool: "a", text: "an epigraph"),
            item("3", pool: "b", text: "the opening idea", tags: ["ideas"]),
        ]
        // The rail scopes…
        #expect(SnippetFilter.apply(
            items, groupID: "a", query: "", tagPath: nil, sort: .recent
        ).map(\.block.blockID).sorted() == ["1", "2"])
        // …all-groups searches across every group (text OR tag path)…
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "opening", tagPath: nil, sort: .oldest
        ).map(\.block.blockID) == ["1", "3"])
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "ideas", tagPath: nil, sort: .recent
        ).map(\.block.blockID) == ["3"])
        // …and the tag filter is exact.
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "", tagPath: "voice", sort: .recent
        ).map(\.block.blockID) == ["1"])
    }

    @Test func theThreeSortsOrderHonestly() {
        let items = [
            item("1", pool: "a", text: "one two three", updated: "2026-08-01T00:00:00Z"),
            item("2", pool: "a", text: "one", updated: "2026-08-20T00:00:00Z"),
            item("3", pool: "a", text: "one two", updated: "2026-08-10T00:00:00Z"),
        ]
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "", tagPath: nil, sort: .recent
        ).map(\.block.blockID) == ["2", "3", "1"])
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "", tagPath: nil, sort: .oldest
        ).map(\.block.blockID) == ["1", "3", "2"])
        #expect(SnippetFilter.apply(
            items, groupID: nil, query: "", tagPath: nil, sort: .longest
        ).map(\.block.blockID) == ["1", "3", "2"])
    }

    @Test func theCardFaceBadgesOnlyRealFans() {
        // W8-4: "can we show how many takes they're in?" — the badge shows
        // a FAN (more than one live active take), never a bare block.
        let fanned = SnippetCardFace.metadata(
            activeTakes: 2, text: "twelve words here", updatedAt: nil)
        #expect(fanned.first == SnippetsCopy.takesBadge(2))
        let plain = SnippetCardFace.metadata(
            activeTakes: 1, text: "twelve words here", updatedAt: nil)
        #expect(!plain.contains { $0.hasPrefix("⑂") })
        #expect(plain.contains(SnippetsCopy.words(3)))
    }
}

// MARK: - The management acts

@Suite("Snippets — the group management doors (item 17)")
@MainActor
struct SnippetsGroupDoorsTests {
    @Test func moveSnippetsBetweenGroupsLandsAndSpeaks() async throws {
        try await withWorld { session, db in
            let (from, to, blockID) = try await session.runner.run {
                ops -> (String, String, String) in
                let from = try ops.createPool(title: "drafting")
                let to = try ops.createPool(title: "keepers")
                let block = try ops.newBlock(in: from.id, text: "moving line").block
                return (from.id, to.id, block.id)
            }
            let area = SnippetsAreaModel(session: session)
            area.adopt(
                pools: try await db.read { try Queries.pools($0) }, items: [])
            await area.moveSnippets([blockID], to: to)
            #expect(area.lastError == nil)
            #expect(area.receipt == SnippetsCopy.movedSnippets(1, to: "keepers"))
            let listing = try await db.read { try Queries.allPoolsListing($0) }
            #expect(listing.first { $0.block.blockID == blockID }?.poolID == to)
            _ = from
        }
    }

    @Test func deleteGroupTakesTheTrashRoadAndTheNoteFenceStays() async throws {
        try await withWorld { session, db in
            let poolID = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "drafting")
                _ = try ops.newBlock(in: pool.id, text: "rides along")
                return pool.id
            }
            // THE BELT STAYS: the note-shaped act still refuses pools —
            // the deliberate group door is a different act, not a fence cut.
            let refused = try await NoteDeletion.run(session: session, postIDs: [poolID])
            #expect(refused == RecoveryCopy.notADeletableNote)
            let stillLive = try await db.read { try Queries.pools($0) }
            #expect(stillLive.map(\.id) == [poolID])

            // The ruled door: to the Trash, spoken, snippets riding.
            let area = SnippetsAreaModel(session: session)
            await area.deleteGroup(poolID)
            #expect(area.lastError == nil)
            #expect(area.receipt == RecoveryCopy.movedToTrashReceipt(.snippetGroup))
            let now = Date(timeIntervalSince1970: 1_782_864_200)
            let rows = try await db.read { try Queries.trash($0, now: now) }
            #expect(rows.contains { $0.kind == .snippetGroup && $0.id == poolID })
        }
    }

    @Test func createAndRenameGroupsThroughTheOrdinaryOps() async throws {
        try await withWorld { session, db in
            let area = SnippetsAreaModel(session: session)
            let id = await area.createGroup(named: "field notes")
            #expect(id != nil)
            #expect(area.receipt == SnippetsCopy.groupCreated("field notes"))
            await area.renameGroup(try #require(id), to: "expedition notes")
            let pools = try await db.read { try Queries.pools($0) }
            #expect(pools.first?.title == "expedition notes")
        }
    }

    @Test func bulkDeleteAndArchiveSpeakTheStandingReceipts() async throws {
        try await withWorld { session, db in
            let (a, b, c) = try await session.runner.run { ops -> (String, String, String) in
                let pool = try ops.createPool(title: "drafting")
                let a = try ops.newBlock(in: pool.id, text: "one").block.id
                let b = try ops.newBlock(in: pool.id, text: "two").block.id
                let c = try ops.newBlock(in: pool.id, text: "three").block.id
                return (a, b, c)
            }
            let area = SnippetsAreaModel(session: session)
            await area.deleteSnippets([a, b])
            #expect(area.receipt == BlockSelectionCopy.deletedNote(2, home: .pool))
            await area.archiveSnippets([c])
            #expect(area.receipt == BlockSelectionCopy.archivedNote(home: .pool))
            let listing = try await db.read { try Queries.allPoolsListing($0) }
            #expect(listing.isEmpty)
        }
    }
}
