//
//  MobileScrapsTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C3 — the scraps area (her precision #1:
//  "you should be able to view your pool of scraps if you want on
//  mobile … and maybe add to it"). State-transition tests through the
//  view model against a real in-memory store; the mint routes through
//  the existing core ops (`createPool` + `newBlock` — the Mac entry
//  bar's composition, byte-mirrored).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile scraps — view + mint (parity C3)")
struct MobileScrapsTests {
    /// The view half (see-your-data): scraps list in pointer order with
    /// their block tags shown leaf-first; the pool-title and preview
    /// brains are pinned beside them (block-tag EDITING stays Mac-side —
    /// her ruling 3 — so the tags here are display only).
    @Test func theScrapsAreaListsThePoolWithLeafTags() async throws {
        try await withEditorWorld { session, db in
            try await session.runner.run { ops in
                let pool = try ops.createPool(title: "Gleanings")
                let first = try ops.newBlock(in: pool.id, text: "A line worth keeping")
                _ = try ops.newBlock(in: pool.id, text: "Another loose thought")
                let tag = try ops.createTag(name: "life")
                let goals = try ops.createTag(parent: tag.id, name: "goals")
                _ = try ops.applyTag(goals.id, toBlock: first.block.id)
            }
            let model = MobileScrapsModel(session: session)
            await model.refresh()

            #expect(model.pools.count == 1)
            #expect(MobileScrapsModel.poolTitle(model.activePool) == "Gleanings")
            #expect(model.items.map { $0.block.text } ==
                    ["A line worth keeping", "Another loose thought"],
                    "pointer order — the pool renders as a container")
            #expect(model.items[0].tagPaths == ["life/goals"])
            #expect(MobileScrapsModel.tagLine(model.items[0].tagPaths) == "#goals",
                    "block tags display leaf-first (K3's grammar)")
            #expect(MobileScrapsModel.tagLine(model.items[1].tagPaths) == nil)
            #expect(MobileScrapsModel.preview(model.items[0]) == "A line worth keeping")
            #expect(MobileScrapsModel.poolTitle(nil) == "no pool")
        }
    }

    /// The mint half (her "maybe add to it"): on an empty store the
    /// first scrap CREATES the pool (the Mac entry bar's composition —
    /// `createPool(title: "Pool")`), the second reuses it; the rows are
    /// exact (a standalone block, placed in the pool, one variant);
    /// blank text mints nothing.
    @Test func mintingAScrapCreatesThePoolOnceAndLandsExactRows() async throws {
        try await withEditorWorld { session, db in
            let model = MobileScrapsModel(session: session)
            await model.refresh()
            #expect(model.pools.isEmpty)

            #expect(await model.mintScrap("The first loose line"))
            #expect(model.pools.count == 1, "the pool was created for the mint")
            #expect(model.pools[0].kind == .pool)
            #expect(model.pools[0].title == "Pool", "the Mac door's own title, byte-mirrored")
            #expect(model.items.map { $0.block.text } == ["The first loose line"])

            #expect(await model.mintScrap("The second"))
            #expect(model.pools.count == 1, "the SAME pool takes the second scrap")
            #expect(model.items.map { $0.block.text } ==
                    ["The first loose line", "The second"])

            // The rows, exact: each scrap is one block placed in the
            // pool with one live variant (I10 at birth).
            let (placements, variants) = try await db.read { db -> (Int, Int) in
                (try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container_block cb
                        JOIN container c ON c.id = cb.container_id
                        WHERE c.kind = 'pool' AND cb.deleted_at IS NULL
                        """) ?? 0,
                 try Int.fetchOne(
                    db,
                    sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0)
            }
            #expect(placements == 2)
            #expect(variants == 2)

            // Blank text is a quiet no-op (the alert's empty field).
            #expect(await model.mintScrap("   ") == false)
            #expect(model.items.count == 2)
            #expect(model.lastError == nil)
        }
    }

    /// FIX-C3c (the C3 ladder): the scraps listing is WINDOWED like
    /// every mobile listing (MobileSoul §2's bar; the Library filter
    /// neighbor's own 200 is the default, narrowed here to exercise the
    /// seam) with the P32 truncation grammar — past the window the model
    /// shows exactly the window and the neutral marker; an EXACT-window
    /// pool shows no marker (the probe discipline's no-false-positive
    /// contract — exact by construction here, since the standing pool
    /// read delivers whole and the count is truth); the marker names no
    /// platform. Both delivery roads (refresh and the observation's
    /// adopt) share the one window rule. The row-level laziness half is
    /// the view-structure change (flat builder content into the
    /// Library's LazyVStack) — the recorded not-headless-testable
    /// class; this pin is the window's.
    @Test func theScrapsListingWindowsWithTheTruncationMarker() async throws {
        try await withEditorWorld { session, db in
            let exactID = try await session.runner.run { ops -> String in
                let over = try ops.createPool(title: "Overfull")
                for i in 1...5 {
                    _ = try ops.newBlock(in: over.id, text: "scrap \(i)")
                }
                let exact = try ops.createPool(title: "Exact")
                for i in 1...4 {
                    _ = try ops.newBlock(in: exact.id, text: "kept \(i)")
                }
                return exact.id
            }
            let model = MobileScrapsModel(session: session, window: 4)
            await model.refresh()

            // Past the window: exactly the window shows — the pool's
            // END since D2 (the suffix window: a mint lands at
            // pointer-order end, so the window keeps the end visible) —
            // the marker fires, and the sentence is neutral.
            #expect(model.items.map { $0.block.text } ==
                    ["scrap 2", "scrap 3", "scrap 4", "scrap 5"],
                    "the window bounds what the surface builds — the pool's END")
            #expect(model.truncated, "never a silent cut")
            let marker = MobileScrapsModel.truncationMarker(
                shown: model.items.count, of: model.totalCount)
            #expect(marker == "The first scrap isn't loaded — showing the latest 4.")
            #expect(MobileScrapsModel.truncationMarker(shown: 4, of: 7)
                == "The first 3 scraps aren't loaded — showing the latest 4.")
            #expect(!marker.contains("Mac"), "P32's grammar is neutral")

            // An exact-window pool shows everything and NO marker (the
            // probe contract).
            model.select(poolID: exactID)
            await model.refresh()
            #expect(model.items.count == 4)
            #expect(model.truncated == false,
                    "an exact-window pool never false-positives the marker")
        }
    }

    /// A mint past the window LANDS VISIBLY (parity D2 — the routed C3
    /// R2-2 mechanism): the old prefix window showed the first
    /// `window` rows while the mint landed at pointer-order END, so
    /// past the window a successful mint showed NOTHING — the field
    /// cleared, no row appeared, and the mint door sat right under the
    /// marker. The suffix window slides to where mints land: the new
    /// scrap is the visible last row, every time.
    @Test func aMintPastTheWindowLandsVisibly() async throws {
        try await withEditorWorld { session, db in
            _ = try await session.runner.run { ops -> String in
                let pool = try ops.createPool(title: "Overfull")
                for i in 1...5 {
                    _ = try ops.newBlock(in: pool.id, text: "scrap \(i)")
                }
                return pool.id
            }
            let model = MobileScrapsModel(session: session, window: 4)
            await model.refresh()
            #expect(model.truncated)

            #expect(await model.mintScrap("the fresh thought"))
            #expect(model.items.last?.block.text == "the fresh thought",
                    "the mint is the visible last row — never an invisible success")
            #expect(model.items.count == 4, "the window still bounds the build")
            #expect(model.truncated, "the marker still tells the truth about the head")
            #expect(model.totalCount == 6)
        }
    }

    /// Several pools are all REACHABLE (the Mac N19 lesson, carried):
    /// the oldest is the default; selecting another re-reads its
    /// listing; a mint lands in the ACTIVE pool.
    @Test func selectingAmongPoolsReReadsAndMintsIntoTheActiveOne() async throws {
        try await withEditorWorld { session, db in
            let (_, laterID) = try await session.runner.run { ops -> (String, String) in
                let old = try ops.createPool(title: "Older")
                _ = try ops.newBlock(in: old.id, text: "old scrap")
                let later = try ops.createPool(title: "Later")
                _ = try ops.newBlock(in: later.id, text: "later scrap")
                return (old.id, later.id)
            }
            let model = MobileScrapsModel(session: session)
            await model.refresh()
            #expect(model.pools.map(\.title) == ["Older", "Later"], "oldest first")
            #expect(MobileScrapsModel.poolTitle(model.activePool) == "Older",
                    "the oldest is the default")
            #expect(model.items.map { $0.block.text } == ["old scrap"])

            model.select(poolID: laterID)
            await model.refresh()
            #expect(model.items.map { $0.block.text } == ["later scrap"],
                    "the selected pool's listing")

            #expect(await model.mintScrap("into the later pool"))
            #expect(model.items.map { $0.block.text } ==
                    ["later scrap", "into the later pool"],
                    "the mint lands in the ACTIVE pool")
        }
    }
}
