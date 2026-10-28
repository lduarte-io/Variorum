//
//  ShowTakeDoorTests.swift
//  VariorumTests
//
//  VX-244 (a rider on the VX-440 run, her sitting word) — "Show take ▸"
//  rendered on take cells whose column can never pick. The cell menu
//  (`TakesCellView.menuSpecs`) appended the submenu wherever the block had a
//  fan, with no look at the COLUMN it was drawn in. Two arms, traced apart:
//
//  · THE TAKES ARTICLE — its cells carry the board-local column
//    `TakesColumn(id: "takes-main", kind: .main)` (`TakesBoardView.mainColumn`),
//    an identity that never lives in the model's `columns`; every child row
//    called `pick(columnID: "takes-main", …)`, whose first line is
//    `guard let index = columns.firstIndex(where: { $0.id == columnID }) else
//    { return }` — so the door did NOTHING and said nothing (P-2's silent door).
//  · THE LENSES CHOSEN COLUMN — a real `.main` column in `columns`; every
//    child row reached `pick`'s `.main` arm, which can only refuse (J38's
//    "The main column shows the note's chosen takes — use ✓ to change them.").
//    A door that can never act in its context is not rendered (P-2).
//
//  The column's ‹ › switcher already wears exactly this guard
//  (`LensesBoardView.pickSwitcher`: `column.kind != .main`), and VX-227 made
//  the switcher and "Show take ▸" ONE road; the fix gives the menu the
//  switcher's rule. RED ON OLD: the two absence pins (the menu was private on
//  the pre-fix tree — it was made internal, behaviour unchanged, in the pins'
//  own commit). The scratch-column control is green on both sides.
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
@Suite("Show take ▸ renders only where a column can pick (VX-244)", .serialized)
struct ShowTakeDoorTests {
    private struct World {
        let postID: String
        let blockID: String
        let takeA: String
        let takeB: String
    }

    private func withWorld(
        _ name: String,
        _ body: @MainActor (AppSession, AppDatabase, World, UserDefaults) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 244))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "ShowTakeDoorTests-\(name)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let ops = session.operations
            let post = try ops.createPost(title: "the fanned note")
            let minted = try ops.newBlock(in: post.id, text: "The first take of the paragraph.")
            let second = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            try ops.autosave(second.id, text: "A second take, other words.", charDelta: 20)
            try await body(
                session, db,
                World(postID: post.id, blockID: minted.block.id,
                      takeA: minted.variant.id, takeB: second.id),
                defaults)
        }
    }

    private func adoptFresh(_ model: TakesViewModel, _ db: AppDatabase, _ postID: String) async throws {
        model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
    }

    /// The rows a cell of `column` offers for the fanned block — the menu the
    /// pane surface really mounts (`menuItems: { menuSpecs(resolved:) }`).
    private func menuTitles(
        _ model: TakesViewModel, world: World, column: TakesColumn
    ) throws -> (titles: [String], showTake: PaneTextView.MenuItemSpec?) {
        let slot = try #require(model.projection.slots.first { $0.blockID == world.blockID })
        let cell = TakesCellView(
            model: model, tokens: .studyLight, indicator: .outline,
            slot: slot, column: column, tinted: false, onDiff: { _ in })
        let resolved = try #require(model.resolvedTake(column: column, slot: slot))
        let specs = cell.menuSpecs(resolved: resolved)
        return (specs.map(\.title), specs.first { $0.title == "Show take" })
    }

    // MARK: - The Takes article (RED ON OLD)

    /// **The article arm.** The mechanism first, so the pin says why: a pick
    /// on the article's board-local column changes nothing and speaks nothing.
    /// Then the face: the article's cell offers no "Show take ▸" — the fan's
    /// own door (the ⑂ badge) is how the article's takes are seen.
    @Test func theTakesArticleCellOffersNoShowTake() async throws {
        try await withWorld("article") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.host = .takes
            try await adoptFresh(model, db, world.postID)
            let article = TakesColumn(id: TakesViewModel.takesMainColumnID, kind: .main)
            #expect(!model.columns.contains { $0.id == article.id },
                    "the trace: the article's column is board-local, never in `columns`")

            // The silent act, as it was (green on both sides — the mechanism).
            await model.pick(columnID: article.id, blockID: world.blockID, variantID: world.takeB)
            #expect(model.status == nil, "a pick there says nothing…")
            #expect(model.resolvedTake(column: article, slot: try #require(
                model.projection.slots.first { $0.blockID == world.blockID }))?.variantID
                == world.takeA, "…and moves nothing: the article still shows the chosen take")

            // RED ON OLD: the row was rendered over that silence.
            let menu = try menuTitles(model, world: world, column: article)
            #expect(menu.showTake == nil,
                    "a door that can never act is not rendered (P-2): \(menu.titles)")
            #expect(menu.titles.contains(TakeCardMenuCopy.newTake),
                    "control: the cell's menu is the real one")
        }
    }

    // MARK: - The Lenses Chosen column (RED ON OLD)

    /// **The Chosen arm.** Its column is real and its pick ALWAYS refuses
    /// (J38) — so the door is not rendered there either.
    @Test func theLensesChosenColumnOffersNoShowTake() async throws {
        try await withWorld("chosen") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.host = .lenses
            try await adoptFresh(model, db, world.postID)
            let chosen = try #require(model.columns.first { $0.kind == .main })

            // The mechanism: every press refuses (green on both sides).
            await model.pick(columnID: chosen.id, blockID: world.blockID, variantID: world.takeB)
            #expect(model.status?.isRefusal == true, "the Chosen column's pick only refuses")
            #expect(model.status?.text == TakesViewModel.chosenColumnHasNoPickNote)

            // RED ON OLD: the row was rendered over that refusal.
            let menu = try menuTitles(model, world: world, column: chosen)
            #expect(menu.showTake == nil,
                    "a door that can only refuse is not rendered (P-2): \(menu.titles)")
            #expect(menu.titles.contains(TakeCardMenuCopy.newTake),
                    "control: the cell's menu is the real one")
        }
    }

    // MARK: - Control: a column that CAN pick keeps the door

    /// **Control (green on both sides).** A scratch column picks, so its cells
    /// keep "Show take ▸" — one row per take — and a press moves the pick.
    @Test func aScratchColumnKeepsShowTakeAndItActs() async throws {
        try await withWorld("scratch") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.host = .lenses
            model.replaceColumnWithNewScratch(try #require(model.columns.first).id)
            try await adoptFresh(model, db, world.postID)
            let scratch = try #require(model.columns.first)
            #expect(scratch.kind == .scratch)

            let menu = try menuTitles(model, world: world, column: scratch)
            let showTake = try #require(menu.showTake, "a picking column keeps the door")
            #expect(showTake.children.count == 2, "one row per take")

            // The act lands: the column now shows take B.
            try #require(showTake.children.last).action()
            for _ in 0..<20 where model.columns.first?.picks[world.blockID] != world.takeB {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(10))
            }
            #expect(model.columns.first?.picks[world.blockID] == world.takeB,
                    "the scratch column picked the take the row named")
        }
    }
}
