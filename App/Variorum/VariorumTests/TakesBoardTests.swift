//
//  TakesBoardTests.swift
//  VariorumTests
//
//  Phase 11, Step A3 — the takes/lens view family's pins (the plan's test
//  list): exactly-one-live-editor across a randomized pane walk; pane
//  handoff mid-dirty-buffer; take edits land in the RIGHT variant
//  (row-level); ✓/adopt are the ONLY writers of chosen_variant_id from
//  this family (the I3 pin); lens round-trip (named survives the store,
//  scratch survives via view memory, expansion is session-only); sameness
//  correctness (quiet ⇔ byte-identical); alignment rows keyed by lineage
//  (a divide's span, an orphan's blank, a reorder's honest marking).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withWorld<T>(
    seed: UInt64 = 7,
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A three-block post; block 1 fanned (3 takes), block 2 fanned (2 takes),
/// block 3 single. Returns everything the walks need.
@MainActor
private struct TakesWorld {
    let postID: String
    let blocks: [String]
    let chosen: [String]
    let extraTakes: [String: [String]]

    static func make(_ session: AppSession, _ db: AppDatabase) async throws -> TakesWorld {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "board post", profile: .blog)
            let m1 = try ops.newBlock(in: post.id, text: "Block one, take one.", at: .end)
            let m2 = try ops.newBlock(in: post.id, text: "Block two, take one.", at: .end)
            let m3 = try ops.newBlock(in: post.id, text: "Block three, only take.", at: .end)
            let t1b = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.autosave(t1b.id, text: "Block one, take two.", charDelta: 4)
            let t1c = try ops.branchVariant(m1.block.id, from: m1.variant.id)
            try ops.autosave(t1c.id, text: "Block one, take three.", charDelta: 4)
            let t2b = try ops.branchVariant(m2.block.id, from: m2.variant.id)
            try ops.autosave(t2b.id, text: "Block two, take two.", charDelta: 4)
            return TakesWorld(
                postID: post.id,
                blocks: [m1.block.id, m2.block.id, m3.block.id],
                chosen: [m1.variant.id, m2.variant.id, m3.variant.id],
                extraTakes: [m1.block.id: [t1b.id, t1c.id], m2.block.id: [t2b.id]])
        }
    }
}

@MainActor
private func freshDefaults(_ name: String) -> UserDefaults {
    let defaults = UserDefaults(suiteName: "TakesBoardTests-\(name)")!
    defaults.removePersistentDomain(forName: "TakesBoardTests-\(name)")
    return defaults
}

@Suite("Takes board (Phase 11, A3)")
@MainActor
struct TakesBoardTests {
    /// THE PANE WALK: a randomized sequence of focus migrations and edits
    /// across columns × blocks × takes — at every step exactly ONE pane is
    /// focused (P3: the live editor migrates), and every edit lands in
    /// exactly the take it was typed into, never a sibling (row-level).
    @Test func randomizedPaneWalkKeepsOneLiveEditorAndRoutesEveryEdit() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("walk"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            model.addScratchColumn()

            var generator = SeededGenerator(seed: 99)
            var expectedTexts: [String: String] = [:]
            var editCount = 0
            for step in 0..<40 {
                let column = model.columns.randomElement(using: &generator)!
                let blockID = world.blocks.randomElement(using: &generator)!
                let candidates = [world.chosen[world.blocks.firstIndex(of: blockID)!]]
                    + (world.extraTakes[blockID] ?? [])
                let variantID = candidates.randomElement(using: &generator)!
                let key = TakesViewModel.PaneKey(
                    columnID: column.id, blockID: blockID, variantID: variantID)
                model.focus(key)
                #expect(model.focusedPane == key,
                        "the live editor migrated to the clicked pane")
                if Bool.random(using: &generator) {
                    editCount += 1
                    let text = "step \(step) landed in \(variantID.suffix(4))"
                    model.paneEdited(variantID: variantID, newText: text)
                    expectedTexts[variantID] = text
                }
            }
            await model.autosave.flushNow()

            for (variantID, text) in expectedTexts {
                let stored = try await db.read { db in
                    try String.fetchOne(
                        db, sql: "SELECT working_text FROM variant WHERE id = ?",
                        arguments: [variantID])
                }
                #expect(stored == text, "the edit landed in exactly the take it was typed into")
            }
            #expect(editCount > 0, "non-vacuity: the walk edited")

            // And the walk never moved a chosen pointer (the I3 half rides
            // the walk too — focusing and editing are never choosing).
            let chosenNow = try await db.read { db in
                try Queries.renderPost(db, containerID: world.postID).map(\.variantID)
            }
            #expect(chosenNow == world.chosen.map { Optional($0) },
                    "clicking/editing never re-points a slot")
        }
    }

    /// Pane handoff mid-dirty-buffer: typed text in the leaving pane lands
    /// in ITS variant when focus migrates; the arriving pane's variant is
    /// untouched by the flush.
    @Test func paneHandoffMidDirtyBufferLandsTheLeavingText() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("handoff"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            let take1 = world.extraTakes[world.blocks[0]]![0]
            let key1 = TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[0], variantID: take1)
            model.focus(key1)
            model.paneEdited(variantID: take1, newText: "typed mid-flight, never lost")

            // Migrate BEFORE any flush settles — the handoff's dirty case.
            let key2 = TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[1],
                variantID: world.chosen[1])
            model.focus(key2)
            await model.autosave.flushNow()

            #expect(model.focusedPane == key2)
            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [take1])
            }
            #expect(stored == "typed mid-flight, never lost")
            let untouched = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [world.chosen[1]])
            }
            #expect(untouched == "Block two, take one.")
        }
    }

    /// THE I3 PIN: across every gesture this family offers EXCEPT ✓ and
    /// adopt — picks, diverge, save-as-lens, branch-all, focus, edits —
    /// `chosen_variant_id` never moves; ✓ and adopt move exactly it.
    @Test func checkAndAdoptAreTheOnlyWritersOfChosen() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("i3"))
            @MainActor func refresh() async throws {
                model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            }
            try await refresh()

            func chosenPointers() async throws -> [String?] {
                try await db.read { db in
                    try Row.fetchAll(db, sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        ORDER BY position, id
                        """, arguments: [world.postID]).map { $0["chosen_variant_id"] }
                }
            }
            let before = try await chosenPointers()

            // Every non-choosing gesture in the family:
            model.addScratchColumn()
            let scratch = model.columns[1]
            await model.pick(
                columnID: scratch.id, blockID: world.blocks[0],
                variantID: world.extraTakes[world.blocks[0]]![0])
            try await refresh()
            await model.divergeHere(
                columnID: scratch.id, blockID: world.blocks[1],
                fromVariantID: world.chosen[1])
            try await refresh()
            let lens = await model.saveScratchAsLens(columnID: scratch.id, name: "thread")
            try await refresh()
            await model.branchAllFans(lensName: "eager thread")
            try await refresh()
            model.focus(TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[0],
                variantID: world.chosen[0]))
            model.paneEdited(variantID: world.chosen[0], newText: "edited chosen text")
            await model.autosave.flushNow()
            model.expandAllFans()
            model.closeAllFans()

            #expect(try await chosenPointers() == before,
                    "no gesture but ✓/adopt may write chosen_variant_id (I3)")
            #expect(model.statusMessage == nil, "the walk's gestures all succeeded")

            // ✓ writes exactly one slot.
            let altTake = world.extraTakes[world.blocks[0]]![1]
            await model.choose(blockID: world.blocks[0], variantID: altTake)
            var after = try await chosenPointers()
            #expect(after[0] == altTake)
            #expect(Array(after.dropFirst()) == Array(before.dropFirst()))

            // Adopt writes the lens's picks — and nothing else.
            if let lens {
                await model.adoptLens(lens.id)
                after = try await chosenPointers()
                #expect(after[0] == world.extraTakes[world.blocks[0]]![0],
                        "adopt landed the lens's pick on block 1")
            } else {
                Issue.record("saveScratchAsLens returned nil")
            }
        }
    }

    /// Lens round-trip: a NAMED lens survives close/reopen through the
    /// STORE; a scratch column survives through VIEW MEMORY; fan expansion
    /// does NOT survive (session-only, the plan's letter).
    @Test func lensAndScratchRoundTripWhileExpansionIsSessionOnly() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let defaults = freshDefaults("roundtrip")
            let first = TakesViewModel(
                session: session, postID: world.postID, defaults: defaults)
            first.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            first.addScratchColumn()
            let scratchID = first.columns[1].id
            await first.pick(
                columnID: scratchID, blockID: world.blocks[0],
                variantID: world.extraTakes[world.blocks[0]]![0])
            await first.saveScratchAsLens(columnID: scratchID, name: "kept thread")
            first.addScratchColumn()
            let scratch2 = first.columns[2].id
            await first.pick(
                columnID: scratch2, blockID: world.blocks[1],
                variantID: world.extraTakes[world.blocks[1]]![0])
            first.expandAllFans()
            #expect(!first.expandedBlocks.isEmpty)

            // "Close and reopen": a FRESH model over the same defaults.
            let second = TakesViewModel(
                session: session, postID: world.postID, defaults: defaults)
            second.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            #expect(second.columns.count == 3, "the arrangement survived via view memory")
            guard case .lens(let lensID) = second.columns[1].kind else {
                Issue.record("the saved lens column did not survive"); return
            }
            let picks = try await db.read { try Queries.effectiveLensSelection($0, lens: lensID) }
            #expect(picks == [world.blocks[0]: world.extraTakes[world.blocks[0]]![0]],
                    "the named lens's picks survived in the STORE")
            #expect(second.columns[2].picks == [world.blocks[1]: world.extraTakes[world.blocks[1]]![0]],
                    "the scratch column's picks survived via view memory")
            #expect(second.expandedBlocks.isEmpty,
                    "fan expansion is session-only — never persisted")
        }
    }

    /// Sameness: quiet ⇔ byte-identical (pure).
    @Test func samenessTintsExactlyTheDivergentCells() {
        #expect(Sameness.tints(["a", "a", "a"]) == [false, false, false],
                "a byte-identical row stays quiet")
        #expect(Sameness.tints(["a", "b", "a"]) == [false, true, false])
        #expect(Sameness.tints(["a", nil, "a"]) == [false, false, false],
                "blanks never tint")
        #expect(Sameness.tints(["a", nil, "b"]) == [false, false, true])
        #expect(Sameness.tints([]) == [])
        // Whitespace is bytes: a trailing newline IS divergence (stored
        // spacing is content — the 2026-07-12 ruling).
        #expect(Sameness.tints(["a\n", "a"]) == [false, true])
    }

    /// Alignment rows are keyed by lineage: a divide's pieces span ONE row;
    /// an orphan gets a blank; a reorder marks moved instead of guessing.
    @Test func alignmentRowsSpanDividesAndBlankOrphansAndMarkMoves() {
        // anchor: A B C — other: A' (kin A), B1' B2' (kin B — a divide's
        // span), D' (no kin — orphan), C' (kin C).
        let rows = PostAlignment.rows(
            anchorBlocks: ["A", "B", "C"],
            otherBlocks: ["A'", "B1'", "B2'", "D'", "C'"],
            kinship: ["A'": "A", "B1'": "B", "B2'": "B", "C'": "C"])
        #expect(rows.map(\.anchorBlockID) == ["A", "B", nil, "C"])
        #expect(rows[1].otherBlockIDs == ["B1'", "B2'"], "the divide's span shares B's row")
        #expect(rows[2].otherBlockIDs == ["D'"], "the orphan's blank row follows its neighbor")
        #expect(rows[3].otherBlockIDs == ["C'"])
        #expect(rows.allSatisfy { !$0.moved })

        // A cross-version reorder: other visits C's kin BEFORE B's.
        let reordered = PostAlignment.rows(
            anchorBlocks: ["A", "B", "C"],
            otherBlocks: ["A'", "C'", "B'"],
            kinship: ["A'": "A", "B'": "B", "C'": "C"])
        let bRow = reordered.first { $0.anchorBlockID == "B" }
        #expect(bRow?.moved == true, "the moved kin is MARKED (anchored order, honest degradation)")
        // An anchor block with no kin keeps a blank other side.
        let sparse = PostAlignment.rows(
            anchorBlocks: ["A", "B"], otherBlocks: ["A'"], kinship: ["A'": "A"])
        #expect(sparse.last?.anchorBlockID == "B")
        #expect(sparse.last?.otherBlockIDs.isEmpty == true)
    }

    /// The aligned view's kinship is the real lineage: a version copy's
    /// blocks map to their sources; a DIVIDED copy's pieces both map to the
    /// one source block (the span); an unrelated block maps to nothing.
    @Test func kinshipTraversalFollowsRealLineage() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let copy = try await session.runner.run { ops in
                try ops.duplicateAsVersion(world.postID)
            }
            // Divide the copy's (single-variant) third block so the aligned
            // rows must span.
            let copyBlock3 = copy.blockCopies[2].copy
            _ = try await session.runner.run { ops in
                try ops.divide(copyBlock3, cut: 12)
            }
            // An unrelated fresh block in the copy — an orphan.
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: copy.post.id, text: "Brand new in the version.", at: .end)
            }

            let kinship = try await db.read {
                try Queries.blockKinship($0, anchor: world.postID, other: copy.post.id)
            }
            let sourcesMapped = Set(kinship.values)
            #expect(sourcesMapped == Set(world.blocks),
                    "every source block has kin in the copy")
            let spanKin = kinship.filter { $0.value == world.blocks[2] }
            #expect(spanKin.count == 2,
                    "the divided copy's BOTH pieces map to the one source (the span)")
            let orphans = try await db.read { db in
                try Queries.renderPost(db, containerID: copy.post.id)
                    .map(\.blockID).filter { kinship[$0] == nil }
            }
            #expect(orphans.count == 1, "the unrelated block is an orphan")
        }
    }
}

// MARK: - Review round 1, MINOR 2: the quit door awaits EVERY live
// editing surface's debounced buffer (the Phase 10 quit-door class,
// reintroduced by the new surfaces). Red-on-old verified by behavioral
// revert (registration commented ⇒ the typed text is absent post-quit).

@Suite("Quit-time finalize covers the new surfaces (Phase 11, round 1 MINOR 2)")
@MainActor
struct QuitFinalizeSurfacesTests {
    @Test func aTakesPaneEditInsideTheDebounceSurvivesTheQuitPath() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("quit"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            let take = world.extraTakes[world.blocks[0]]![0]
            model.focus(TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[0], variantID: take))
            model.paneEdited(variantID: take, newText: "typed, then ⌘Q inside the debounce")

            // The delegate's composed quit path: finalize EVERY registered
            // surface (no editor is focused in Takes mode).
            await session.quitFinalize.finalizeAll()

            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?", arguments: [take])
            }
            #expect(stored == "typed, then ⌘Q inside the debounce",
                    "nothing typed is ever lost to ⌘Q — the takes pane included")
        }
    }

    @Test func aTOCPaneEditInsideTheDebounceSurvivesTheQuitPath() async throws {
        try await withWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "post", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "Original text.", at: .end)
                return post.id
            }
            let model = BlockTOCViewModel(session: session, postID: postID)
            let row = try await db.read { try Queries.blockTOC($0, post: postID) }[0]
            model.makeLive(row.blockID)
            model.paneEdited(
                variantID: row.variantID!, oldText: row.text ?? "",
                newText: "TOC-typed, then ⌘Q")

            await session.quitFinalize.finalizeAll()

            let stored = try await db.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [row.variantID!])
            }
            #expect(stored == "TOC-typed, then ⌘Q")

            // Teardown unregisters — a closed surface never lingers in
            // the quit path (this session's registry is now empty: the
            // takes test's model above lives in a DIFFERENT session).
            model.teardown()
            #expect(session.quitFinalize.isEmpty)
        }
    }
}

// MARK: - Review round 2, MAJOR: liveBuffers must CONVERGE at settle-time
// adoption — the buffer-authoritative discipline's other half. Red-on-
// current: before the fix, resolvedTake returned the frozen local buffer
// forever, hiding external (sync/repair/sibling-surface) edits and letting
// resumed typing clobber them with no conflict variant.

@Suite("Takes buffers converge at adoption (Phase 11, round 2 MAJOR)")
@MainActor
struct TakesBufferConvergenceTests {
    @Test func aSettledAdoptionDropsTheBufferAndShowsExternalEdits() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("converge"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            let take = world.extraTakes[world.blocks[0]]![0]
            let key = TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[0], variantID: take)
            model.focus(key)
            model.paneEdited(variantID: take, newText: "local typing")
            await model.autosave.flushNow()

            // An EXTERNAL edit lands (a phone edit via sync, an engine
            // repair, a sibling surface) and its projection arrives clean.
            try await session.runner.run { ops in
                try ops.autosave(take, text: "remote edit landed", charDelta: 8)
            }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // Pick the take into a scratch column so resolvedTake reads it.
            model.addScratchColumn()
            await model.pick(columnID: model.columns[1].id, blockID: world.blocks[0], variantID: take)
            let slot = model.projection.slots.first { $0.blockID == world.blocks[0] }!
            let shown = model.resolvedTake(column: model.columns[1], slot: slot)
            #expect(shown?.text == "remote edit landed",
                    "visible IS what the take is — a settled adoption converges the pane")
            #expect(model.liveBuffers[take] == nil,
                    "the buffer cleared once the projection caught up")
        }
    }

    @Test func aDirtyBufferStaysAuthoritativeUntilSettle() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("dirty"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            let take = world.extraTakes[world.blocks[0]]![0]
            model.focus(TakesViewModel.PaneKey(
                columnID: model.columns[0].id, blockID: world.blocks[0], variantID: take))
            model.paneEdited(variantID: take, newText: "unsaved typing")

            // A projection adopted WHILE the edit is pending must not
            // clobber the buffer (the dirty half of the discipline).
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            #expect(model.liveBuffers[take] == "unsaved typing",
                    "the buffer stays authoritative while its autosave is pending")
            await model.autosave.flushNow()
        }
    }
}
