//
//  TakesLensFilterTests.swift
//  VariorumTests
//
//  VX-170 — LENS-AWARE TAKES (the VX-168 run's Unit 4): the board's `show ▾`
//  filter over REAL projections. The ruled shape is
//  `notes/plans/vx-170-lens-aware-takes.md` (R-VX170-1…5, P-VX170-1): the four
//  forms, collapsed one-line rows for the blocks a filter does not name, the
//  expand set (named + chosen) for the ones it does, the masthead popover
//  resting on "all takes" with a quiet chip while active, and a session-only
//  per-note memory. The core's rule itself is pinned headless
//  (`LensTakeFilterTests`); these pin the BOARD's half.
//

import Dependencies
import Foundation
import GRDB
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 170))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// Four blocks, three lenses (her readme-review shape):
///   B1: c1 (chosen) · a1 · blank1 (BLANK) — X (“claude's cut”) picks blank1, Y (“mine”) a1
///   B2: c2 (chosen) · a2                  — X and Y both pick a2
///   B3: c3 (chosen) only                  — Y picks c3 (the chosen take)
///   B4: c4 (chosen) · a4                  — X picks a4
/// and Z (“empty”), a lens with no picks.
@MainActor
private struct LensWorld {
    let postID: String
    let b1, b2, b3, b4: String
    let c1, a1, blank1, c2, a2, c3, c4, a4: String
    let x, y, z: String

    static func make(_ session: AppSession) async throws -> LensWorld {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "readme review", profile: .blog)
            let m1 = try ops.newBlock(in: post.id, text: "Block one.", at: .end)
            let m2 = try ops.newBlock(in: post.id, text: "Block two.", at: .end)
            let m3 = try ops.newBlock(in: post.id, text: "\n  Block three, after a blank line.", at: .end)
            let m4 = try ops.newBlock(in: post.id, text: "Block four.", at: .end)
            let a1 = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.autosave(a1.id, text: "Block one, rewritten.", charDelta: 11)
            let blank1 = try ops.newBlankVariant(m1.block.id)
            let a2 = try ops.branchVariant(m2.block.id, from: m2.variant.id)
            try ops.autosave(a2.id, text: "Block two, tightened.", charDelta: 10)
            let a4 = try ops.branchVariant(m4.block.id, from: m4.variant.id)
            try ops.autosave(a4.id, text: "Block four, cut.", charDelta: 4)
            let x = try ops.createLens(post: post.id, name: "claude's cut")
            try ops.setLensChoice(lens: x.id, block: m1.block.id, variant: blank1.id)
            try ops.setLensChoice(lens: x.id, block: m2.block.id, variant: a2.id)
            try ops.setLensChoice(lens: x.id, block: m4.block.id, variant: a4.id)
            let y = try ops.createLens(post: post.id, name: "mine")
            try ops.setLensChoice(lens: y.id, block: m1.block.id, variant: a1.id)
            try ops.setLensChoice(lens: y.id, block: m2.block.id, variant: a2.id)
            try ops.setLensChoice(lens: y.id, block: m3.block.id, variant: m3.variant.id)
            let z = try ops.createLens(post: post.id, name: "empty")
            return LensWorld(
                postID: post.id,
                b1: m1.block.id, b2: m2.block.id, b3: m3.block.id, b4: m4.block.id,
                c1: m1.variant.id, a1: a1.id, blank1: blank1.id, c2: m2.variant.id,
                a2: a2.id, c3: m3.variant.id, c4: m4.variant.id, a4: a4.id,
                x: x.id, y: y.id, z: z.id)
        }
    }
}

@MainActor
private func freshDefaults(_ name: String) -> UserDefaults {
    let suite = "TakesLensFilterTests-\(name)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

/// THE takes board's model (what `TakesBoardView.init` makes it), with the
/// note's projection adopted.
@MainActor
private func board(
    _ session: AppSession, _ db: AppDatabase, _ postID: String, _ name: String
) async throws -> TakesViewModel {
    let model = TakesViewModel(session: session, postID: postID, defaults: freshDefaults(name))
    model.landingEnabled = true
    model.host = .takes
    model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
    return model
}

@MainActor
private func fresh(_ db: AppDatabase, _ postID: String) async throws -> Queries.TakesProjection {
    try await db.read { try Queries.takesProjection($0, post: postID) }
}

@MainActor
private func slot(_ model: TakesViewModel, _ blockID: String) -> Queries.RenderedBlock {
    model.projection.slots.first { $0.blockID == blockID }!
}

@Suite("Lens-aware Takes — the board's show ▾ (VX-170)")
@MainActor
struct TakesLensFilterTests {
    // MARK: - The door at rest (R-VX170-4)

    @Test func theDoorRestsOnAllTakesWithNoChipAndEveryRowItsOwn() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "rest")
            #expect(model.lensFilter.offered)
            #expect(model.lensFilter.filter == nil)
            #expect(model.lensFilter.label == [.words("all takes")])
            #expect(TakesShowCopy.plain(model.lensFilter.label) == "all takes")
            #expect(model.lensFilter.chip == nil, "the chip marks only a FILTERED state")
            #expect(model.lensFilter.zeroLine == nil)
            for blockID in [w.b1, w.b2, w.b3, w.b4] {
                #expect(model.rowShape(slot(model, blockID)) == .ordinary)
                #expect(model.bloomTakes(slot(model, blockID)).map(\.id)
                        == (model.projection.fans[blockID] ?? []).map(\.id),
                        "no filter: a bloom draws the whole fan")
            }
            // The popover's first row is the clear, selected at rest.
            let rows = model.lensFilter.menuRows
            #expect(rows.first?.form == nil)
            #expect(rows.first?.selected == true)
            #expect(rows.dropFirst().map(\.form) == LensTakeFilter.Form.allCases)
            #expect(rows.dropFirst().allSatisfy { !$0.selected })
        }
    }

    @Test func aNoteWithoutALensOffersNoDoor() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops in
                let post = try ops.createPost(title: "plain", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Only prose.", at: .end)
                return post.id
            }
            let model = try await board(session, db, postID, "nolens")
            #expect(!model.lensFilter.offered,
                    "PROVISIONAL P-VX168-U4-1: every form would match nothing")
        }
    }

    // MARK: - The shapes (R-VX170-2/3, P-VX170-1)

    @Test func disagreeWithChosenCollapsesTheRestAndExpandsTheNamedPlusChosen() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "dwc")
            model.lensFilter.set(.disagreeWithChosen(w.x))

            #expect(model.rowShape(slot(model, w.b1)) == .filtered([w.c1, w.blank1]),
                    "the blank IS a disagreement (P-VX170-1), chosen beside it")
            #expect(model.rowShape(slot(model, w.b2)) == .filtered([w.c2, w.a2]))
            #expect(model.rowShape(slot(model, w.b3)) == .collapsed, "X names nothing on B3")
            #expect(model.rowShape(slot(model, w.b4)) == .filtered([w.c4, w.a4]))

            #expect(model.isBloomed(slot(model, w.b1)))
            #expect(!model.isBloomed(slot(model, w.b3)), "a collapsed row never blooms")
            #expect(model.bloomTakes(slot(model, w.b1)).map(\.id) == [w.c1, w.blank1],
                    "the rest of the fan (a1) stays behind its usual control")
            #expect(model.bloomTakes(slot(model, w.b1)).last?.workingText == "",
                    "fixture: the blank take is really blank")

            #expect(model.lensFilter.label == [.name("claude's cut"), .words(" disagrees with chosen")])
            #expect(TakesShowCopy.plain(model.lensFilter.label)
                    == "claude's cut disagrees with chosen", "her example, verbatim")
            #expect(model.lensFilter.chip == "3 of 4 blocks")
            #expect(model.lensFilter.zeroLine == nil)
        }
    }

    @Test func everyFormShapesTheNoteAsTheRuleSays() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "forms")
            @MainActor func shapes() -> [TakesRowShape] {
                [w.b1, w.b2, w.b3, w.b4].map { model.rowShape(slot(model, $0)) }
            }
            model.lensFilter.set(.inLens(w.x))
            #expect(shapes() == [
                .filtered([w.c1, w.blank1]), .filtered([w.c2, w.a2]), .collapsed,
                .filtered([w.c4, w.a4]),
            ], "in X: the blanked block IS in X")
            model.lensFilter.set(.inLensNotIn(w.x, w.y))
            #expect(shapes() == [.collapsed, .collapsed, .collapsed, .filtered([w.c4, w.a4])])
            model.lensFilter.set(.disagree(w.x, w.y))
            #expect(shapes() == [.filtered([w.c1, w.a1, w.blank1]), .collapsed, .collapsed, .collapsed])
            #expect(model.bloomTakes(slot(model, w.b1)).count == 3,
                    "both named takes and the chosen one")
            model.lensFilter.set(.inLens(w.y))
            #expect(shapes() == [
                .filtered([w.c1, w.a1]), .filtered([w.c2, w.a2]), .filtered([w.c3]), .collapsed,
            ])
        }
    }

    @Test func aLensNamingTheShownTakeIsAMatchThatDoesNotBloom() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "lone")
            model.lensFilter.set(.inLens(w.y))
            let b3 = slot(model, w.b3)
            #expect(model.rowShape(b3) == .filtered([w.c3]))
            #expect(!model.isBloomed(b3),
                    "a lone shown take IS the article cell — nothing to contrast")
            #expect(model.lensFilter.paneIsShown(.init(
                columnID: TakesViewModel.takesMainColumnID, blockID: w.b3, variantID: w.c3)))
        }
    }

    @Test func aDanglingPickNamesNothingOnTheBoard() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "dangle")
            model.lensFilter.set(.inLens(w.x))
            #expect(model.rowShape(slot(model, w.b4)) == .filtered([w.c4, w.a4]))
            try await session.runner.run { [a4 = w.a4] ops in try ops.archiveVariant(a4) }
            model.adopt(try await fresh(db, w.postID))
            #expect(model.projection.lensDangles[w.x]?[w.b4] != nil, "fixture: the pick dangles")
            // PROVISIONAL P-VX168-U4-2 — the wire's `via: chosen`, the board's
            // fall-through: the dangle names nothing, so B4 folds to its line.
            #expect(model.rowShape(slot(model, w.b4)) == .collapsed)
            #expect(model.lensFilter.chip == "2 of 4 blocks", "the count follows")
        }
    }

    // MARK: - The badge, the usual control

    @Test func theBadgeIsTheBlocksWholeFanDoorAndFoldsBack() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "badge")
            model.lensFilter.set(.disagreeWithChosen(w.x))
            let b1 = slot(model, w.b1)
            #expect(model.lensFilter.badgeHelp(b1)
                    == "Show all 3 takes — the filter shows the ones it names, beside the chosen one")

            model.toggleExpanded(w.b1)  // the badge's act
            #expect(model.rowShape(slot(model, w.b1)) == .ordinary)
            #expect(model.isBloomed(slot(model, w.b1)))
            #expect(model.bloomTakes(slot(model, w.b1)).map(\.id) == [w.c1, w.a1, w.blank1],
                    "the whole fan, a1 included")
            #expect(model.lensFilter.badgeHelp(slot(model, w.b1)) == "Back to the takes the filter names")
            model.toggleExpanded(w.b1)
            #expect(model.rowShape(slot(model, w.b1)) == .filtered([w.c1, w.blank1]))

            // A collapsed row's badge opens it whole, and folds it back.
            #expect(model.lensFilter.badgeHelp(slot(model, w.b3))
                    == "Open this block whole — its text and its takes (the filter doesn't name it)")
            model.toggleExpanded(w.b3)
            #expect(model.rowShape(slot(model, w.b3)) == .ordinary)
            #expect(model.lensFilter.badgeHelp(slot(model, w.b3)) == "Fold this block back to its one line")
            model.toggleExpanded(w.b3)
            #expect(model.rowShape(slot(model, w.b3)) == .collapsed)
        }
    }

    @Test func applyingAFilterStartsFromThePlainPage() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "plain")
            model.expandAllFans()
            #expect(!model.expandedBlocks.isEmpty, "fixture: fans open before")
            model.lensFilter.set(.disagreeWithChosen(w.x))
            #expect(model.expandedBlocks.isEmpty,
                    "a fan opened before would show a block whole whatever the filter says")
            #expect(model.rowShape(slot(model, w.b3)) == .collapsed)
        }
    }

    @Test func followTheScrollNeverOpensACollapsedRow() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "follow")
            model.followTheScroll = true
            for blockID in [w.b1, w.b2, w.b3, w.b4] { model.rowAppeared(blockID) }
            #expect(model.isBloomed(slot(model, w.b4)), "fixture: follow-the-scroll blooms B4")
            model.lensFilter.set(.inLens(w.y))
            #expect(model.rowShape(slot(model, w.b4)) == .collapsed)
            #expect(!model.isBloomed(slot(model, w.b4)), "the filter's map is not a place fans open")
        }
    }

    // MARK: - Zero matches, said in place

    @Test func aFilterThatNamesNothingSaysSoInPlace() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "zero")
            model.lensFilter.set(.inLens(w.z))
            #expect(model.lensFilter.chip == "0 of 4 blocks")
            #expect(model.lensFilter.zeroLine == [
                .words("No blocks match — "), .name("\u{201C}empty\u{201D}"),
                .words(" picks no take in this note."),
            ])
            for blockID in [w.b1, w.b2, w.b3, w.b4] {
                #expect(model.rowShape(slot(model, blockID)) == .collapsed,
                        "the map stays whole — every row a line, none removed")
            }
            #expect(model.projection.slots.count == 4)

            // Two lenses that agree everywhere — the shape's own words.
            try await session.runner.run { [y = w.y] ops in _ = try ops.duplicateLens(y, name: "mine again") }
            model.adopt(try await fresh(db, w.postID))
            let copy = try #require(model.projection.lenses.first { $0.name == "mine again" })
            model.lensFilter.set(.disagree(w.y, copy.id))
            #expect(TakesShowCopy.plain(try #require(model.lensFilter.zeroLine))
                    == "No blocks match — \u{201C}mine\u{201D} and \u{201C}mine again\u{201D} agree everywhere.")
        }
    }

    // MARK: - The session memory (R-VX170-5)

    @Test func theFilterIsSessionMemoryPerNoteAndGoneOnRelaunch() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let other = try await LensWorld.make(session)
            let first = try await board(session, db, w.postID, "mem-1")
            first.lensFilter.set(.disagreeWithChosen(w.x))
            first.teardown()

            // A mode flip / a note switch and back: a NEW board, the same session.
            let again = try await board(session, db, w.postID, "mem-2")
            #expect(again.lensFilter.filter == .disagreeWithChosen(w.x), "survives the mount")
            #expect(again.rowShape(slot(again, w.b3)) == .collapsed)

            // Per NOTE: the other note rests on all takes.
            let elsewhere = try await board(session, db, other.postID, "mem-3")
            #expect(elsewhere.lensFilter.filter == nil)

            // Clearing is remembered too.
            again.lensFilter.set(nil)
            #expect(session.editorRouter.takesShowFilters[w.postID] == nil)
            again.lensFilter.set(.inLens(w.y))

            // A relaunch is a new session: every note starts at all takes.
            let relaunched = AppSession(database: db)
            let cold = try await board(relaunched, db, w.postID, "mem-4")
            #expect(cold.lensFilter.filter == nil, "never persisted, never a setting")
        }
    }

    @Test func onlyTheTakesBoardReadsOrWritesTheMemory() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            session.editorRouter.takesShowFilters[w.postID] = .inLens(w.x)
            // The Write panel's embedded model (never `landingEnabled`) and the
            // Lenses board (`host == .lenses`) never filter a row.
            let panel = TakesViewModel(session: session, postID: w.postID, defaults: freshDefaults("panel"))
            panel.adopt(try await fresh(db, w.postID))
            #expect(panel.lensFilter.filter == nil)
            #expect(panel.rowShape(slot(panel, w.b3)) == .ordinary)
            panel.lensFilter.set(nil)
            #expect(session.editorRouter.takesShowFilters[w.postID] == .inLens(w.x),
                    "a model that does not apply never writes the slot")
            let lenses = TakesViewModel(session: session, postID: w.postID, defaults: freshDefaults("lenses"))
            lenses.landingEnabled = true
            lenses.host = .lenses
            lenses.adopt(try await fresh(db, w.postID))
            #expect(lenses.lensFilter.filter == nil)
            #expect(!lenses.lensFilter.offered)
        }
    }

    @Test func aDeletedLensResetsTheFilterToAllTakes() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "deleted")
            model.lensFilter.set(.disagree(w.x, w.y))
            try await session.runner.run { [y = w.y] ops in try ops.deleteLens(y) }
            model.adopt(try await fresh(db, w.postID))
            #expect(model.lensFilter.filter == nil)
            #expect(session.editorRouter.takesShowFilters[w.postID] == nil)
            #expect(model.rowShape(slot(model, w.b3)) == .ordinary)
        }
    }

    // MARK: - The ring (the R112 class)

    @Test func theRingNeverLandsOnAHiddenPane() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "ring")
            model.lensFilter.set(.disagreeWithChosen(w.x))
            // A collapsed block's article pane (a landing, a find step…).
            let b3 = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: w.b3, variantID: w.c3)
            #expect(!model.lensFilter.paneIsShown(b3))
            model.focus(b3)
            #expect(model.focusedPane == b3)
            #expect(model.rowShape(slot(model, w.b3)) == .ordinary, "its block opened")
            #expect(model.lensFilter.paneIsShown(b3))
            // A fan card the filtered subset hides (a1 on B1).
            let a1 = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID, blockID: w.b1, variantID: w.a1)
            #expect(!model.lensFilter.paneIsShown(a1))
            model.focus(a1)
            #expect(model.rowShape(slot(model, w.b1)) == .ordinary)
            #expect(model.bloomTakes(slot(model, w.b1)).contains { $0.id == w.a1 })
            // The entry ring's door too (`landAuthorityFocus`).
            let b4card = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: w.b4, variantID: w.c4)
            #expect(model.lensFilter.paneIsShown(b4card), "fixture: B4 matches")
            model.closeAllFans()
            model.lensFilter.set(.inLens(w.y))
            #expect(!model.lensFilter.paneIsShown(b4card))
            model.landAuthorityFocus(b4card)
            #expect(model.focusedPane == b4card)
            #expect(model.rowShape(slot(model, w.b4)) == .ordinary)
        }
    }

    @Test func herFilterChangeBlursAPaneItHidesAndKeepsOneItShows() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "blur")
            let b1 = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: w.b1, variantID: w.c1)
            model.focus(b1)
            model.lensFilter.set(.disagreeWithChosen(w.x))
            #expect(model.focusedPane == b1, "B1 matches: its article cell is still on the page")

            let b3 = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID, blockID: w.b3, variantID: w.c3)
            model.lensFilter.set(nil)
            model.focus(b3)
            model.lensFilter.set(.disagreeWithChosen(w.x))
            #expect(model.focusedPane == nil,
                    "the view she asked for is exactly the filter's — the hidden pane lets go")
            #expect(model.rowShape(slot(model, w.b3)) == .collapsed)
        }
    }

    @Test func aStoreChangeNeverHidesTheLivePane() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "store")
            model.lensFilter.set(.disagreeWithChosen(w.x))
            let card = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID, blockID: w.b2, variantID: w.a2)
            model.focus(card)
            // She ✓s X's take: X now AGREES with the chosen take on B2.
            try await session.runner.run { [b2 = w.b2, a2 = w.a2] ops in
                try ops.chooseVariant(b2, variantID: a2)
            }
            model.adopt(try await fresh(db, w.postID))
            #expect(!model.lensFilter.evaluation!.matches(w.b2), "B2 left the filter's set")
            #expect(model.focusedPane == card)
            #expect(model.rowShape(slot(model, w.b2)) == .ordinary,
                    "the block she is in stays open — nothing vanishes from under the ring")
            #expect(model.lensFilter.paneIsShown(card))
            // A block she is NOT in simply folds when it stops matching.
            try await session.runner.run { [b4 = w.b4, a4 = w.a4] ops in
                try ops.chooseVariant(b4, variantID: a4)
            }
            model.adopt(try await fresh(db, w.postID))
            #expect(model.rowShape(slot(model, w.b4)) == .collapsed)
        }
    }

    // MARK: - The popover's rows

    @Test func theRowsCarryTheActiveLensesAndApplyAsRuled() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "rows")
            let lenses = model.projection.lenses.map(\.id)
            #expect(lenses == [w.x, w.y, w.z], "fixture: the note's stable lens order")

            // At rest every form carries the note's first lenses.
            let rest = model.lensFilter.menuRows
            #expect(rest.map(\.operands) == [[], [w.x], [w.x, w.y], [w.x, w.y], [w.x]])
            #expect(rest.allSatisfy { $0.enabled })

            // A row's WORDS apply it and close the popover.
            model.lensFilter.menuOpen = true
            model.lensFilter.choose(rest[3])
            #expect(model.lensFilter.filter == .disagree(w.x, w.y))
            #expect(!model.lensFilter.menuOpen)

            // An operand pick applies at once and the popover stays open.
            model.lensFilter.menuOpen = true
            let disagreeRow = try #require(model.lensFilter.menuRows.first { $0.form == .disagree })
            #expect(disagreeRow.selected)
            #expect(model.lensFilter.pickerLenses(disagreeRow, at: 1).map(\.id) == [w.y, w.z],
                    "the second picker never offers the first operand")
            model.lensFilter.pick(w.z, at: 1, in: disagreeRow)
            #expect(model.lensFilter.filter == .disagree(w.x, w.z))
            #expect(model.lensFilter.menuOpen)

            // Switching forms keeps the lenses she was looking through.
            let carried = model.lensFilter.menuRows
            #expect(carried.first { $0.form == .inLensNotIn }?.operands == [w.x, w.z])
            #expect(carried.first { $0.form == .inLens }?.operands == [w.x])

            // "all takes" clears.
            model.lensFilter.choose(carried[0])
            #expect(model.lensFilter.filter == nil)
        }
    }

    @Test func aTwoLensFormOnAOneLensNoteIsInert() async throws {
        let rows = TakesShowMenuRow.rows(active: nil, lenses: ["only"])
        #expect(rows.map(\.enabled) == [true, true, false, false, true])
        #expect(rows[2].filter == nil, "an inert row applies nothing")
        let active = TakesShowMenuRow.rows(active: .inLens("only"), lenses: ["only"])
        #expect(active.map(\.selected) == [false, true, false, false, false])
    }

    // MARK: - Paging follows what the bloom draws

    @Test func theKeyboardPagerPagesTheExpandSet() async throws {
        try await withWorld { session, db in
            let w = try await LensWorld.make(session)
            let model = try await board(session, db, w.postID, "pager")
            await model.setFanStyle(.carousel)
            model.adopt(try await fresh(db, w.postID))
            model.beneathCount = 1
            model.focus(.init(columnID: TakesViewModel.takesMainColumnID, blockID: w.b1, variantID: w.c1))
            #expect(model.pageTarget()?.limit == 2, "fixture: the whole fan of 3, one beside")
            model.lensFilter.set(.disagreeWithChosen(w.x))
            #expect(model.focusedPane != nil, "fixture: B1's cell survives the filter (carousel)")
            #expect(model.pageTarget()?.limit == 1, "the expand set of 2, one beside")
        }
    }

    // MARK: - The words

    @Test func theWordsOfEveryForm() {
        let names = ["X": "claude's cut", "Y": "mine"]
        #expect(TakesShowCopy.plain(TakesShowCopy.label(.inLens("X"), names: names)) == "in claude's cut")
        #expect(TakesShowCopy.plain(TakesShowCopy.label(.inLensNotIn("X", "Y"), names: names))
                == "in claude's cut, not in mine")
        #expect(TakesShowCopy.plain(TakesShowCopy.label(.disagree("X", "Y"), names: names))
                == "claude's cut disagrees with mine")
        #expect(TakesShowCopy.plain(TakesShowCopy.label(.disagreeWithChosen("X"), names: names))
                == "claude's cut disagrees with chosen")
        #expect(TakesShowCopy.label(.inLens("X"), names: names).contains(.name("claude's cut")),
                "a lens name rides as HER words — never case-folded by the voice")
        #expect(TakesShowCopy.plain(TakesShowCopy.zeroLine(.inLensNotIn("X", "Y"), names: names))
                == "No blocks match — wherever \u{201C}claude's cut\u{201D} picks a take, "
                    + "\u{201C}mine\u{201D} picks one too.")
        #expect(TakesShowCopy.plain(TakesShowCopy.zeroLine(.disagreeWithChosen("X"), names: names))
                == "No blocks match — \u{201C}claude's cut\u{201D} agrees with the chosen takes everywhere.")
        #expect(TakesShowCopy.chip(matches: 1, blocks: 1) == "1 of 1 block")
        #expect(TakesShowCopy.chip(matches: 0, blocks: 12) == "0 of 12 blocks")
        #expect(TakesShowCopy.rowWords(.disagreeWithChosen) == [nil, " disagrees with the chosen takes"],
                "the last form's fixed operand is the chosen takes")
    }

    @Test func aCollapsedRowReadsItsFirstLineThatSaysAnything() {
        #expect(TakesShowCopy.firstLine("First line.\nSecond line.") == "First line.")
        #expect(TakesShowCopy.firstLine("\n  Block three, after a blank line.")
                == "Block three, after a blank line.")
        #expect(TakesShowCopy.firstLine("") == nil, "a blank take reads as an empty block")
        #expect(TakesShowCopy.firstLine("   \n\t") == nil)
    }
}
