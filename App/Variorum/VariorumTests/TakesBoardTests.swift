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
            await model.addWriteColumn()  // "write new takes" — mints takes, never chooses
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

    /// Sitting 9's column-slot machinery (R80/R83/R89/R90): auto-names,
    /// slot replacement, the write-column's minted picks, the ‹ › switcher
    /// clamping, adopt-swap's preservation, and the blank-take power pair.
    @Test func columnSlotsAutoNameReplaceStepAndSwap() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("slots"))
            @MainActor func refresh() async throws {
                model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            }
            try await refresh()

            // Auto-names: "Lens 1", "Lens 2" — visible unnamed lenses (R83).
            model.addScratchColumn()
            model.addScratchColumn()
            #expect(model.columns[1].name == "Lens 1")
            #expect(model.columns[2].name == "Lens 2")

            // The write column mints ONE take per renderable slot and picks
            // exactly them (R81's "write new takes").
            let fanBefore = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
            }
            await model.addWriteColumn()
            #expect(model.columns.count == 4)
            let written = model.columns[3]
            #expect(written.picks.count == 3, "a pick on every renderable slot")
            let fanAfter = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL") ?? 0
            }
            #expect(fanAfter == fanBefore + 3, "exactly the minted takes, nothing else")
            try await refresh()

            // ‹ › steps THAT column's pick only, ends clamped (R89).
            let slot1 = model.projection.slots[0]
            let scratchID = model.columns[1].id
            #expect(model.pickPosition(columnID: scratchID, slot: slot1)?.index == 1)
            await model.stepPick(columnID: scratchID, slot: slot1, by: -1)
            #expect(model.pickPosition(columnID: scratchID, slot: slot1)?.index == 1,
                    "the start clamps")
            await model.stepPick(columnID: scratchID, slot: slot1, by: 1)
            #expect(model.pickPosition(columnID: scratchID, slot: slot1)?.index == 2)
            // The pick the column now holds (fan-position order — branch
            // lands beside its source, so don't assume creation order).
            let steppedPick = model.columns.first { $0.id == scratchID }!.picks[world.blocks[0]]
            #expect(steppedPick != nil && steppedPick != world.chosen[0])
            let chosenNow = try await db.read { [postID = world.postID] db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """, arguments: [postID]).map { $0["chosen_variant_id"] as String? }
            }
            #expect(chosenNow[0] == world.chosen[0], "stepping a pick never writes chosen")

            // Slot replacement (R83): the write column becomes Chosen in place.
            model.replaceColumnWithChosen(written.id)
            #expect(model.columns[3].kind == .main)

            // Adopt-swap (R92): the scratch column's pick becomes the post;
            // the outgoing chosen survives as the auto-named lens.
            await model.adoptColumn(scratchID)
            try await refresh()
            let chosenAfter = try await db.read { [postID = world.postID] db in
                try Row.fetchAll(
                    db,
                    sql: """
                        SELECT chosen_variant_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                        """, arguments: [postID]).map { $0["chosen_variant_id"] as String? }
            }
            #expect(chosenAfter[0] == steppedPick,
                    "the adopted pick IS the post now")
            let preserved = model.projection.lenses.first { $0.name.hasPrefix("chosen until") }
            #expect(preserved != nil, "the old chosen survives as a lens (adopting swaps, never destroys)")
            #expect(model.statusMessage?.contains("chosen until") == true,
                    "the toast names the way back")

            // The blank-take pair (R90): default mints WITHOUT choosing;
            // the power variant mints AND chooses.
            await model.newBlankTake(blockID: world.blocks[2])
            try await refresh()
            let chosen3 = try await db.read { [block = world.blocks[2]] db in
                try String.fetchOne(
                    db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ?",
                    arguments: [block])
            }
            #expect(chosen3 == world.chosen[2], "default blank take never chooses")
            await model.newBlankTakeAsChosen(blockID: world.blocks[2])
            try await refresh()
            let chosen3After = try await db.read { [block = world.blocks[2]] db in
                try String.fetchOne(
                    db, sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ?",
                    arguments: [block])
            }
            #expect(chosen3After != world.chosen[2], "the power variant chooses what it minted")
        }
    }

    /// Lens round-trip: a NAMED lens survives close/reopen through the
    /// STORE; a scratch column survives through VIEW MEMORY; fan expansion
    /// does NOT survive through either — it is never persisted. (Since VX-428
    /// THE takes board remembers its open fans per note for the SESSION —
    /// `TakesExpansionMemoryTests`; these models are not that board, and no
    /// expansion ever reaches the defaults.)
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

    /// Stage 2 ladder MINOR-D2 pin (red-on-old, behavioral-revert
    /// verified): ⇧⌥⌘T's reveal is gated on the HOST. On a Lenses board a
    /// lens column keeps showing its own PICK after the mint+choose (the
    /// pick didn't change — chosen did), so the old unconditional
    /// `revealTake` parked the ring on a pane NO column renders and the
    /// live ring silently vanished. The ring must always land on a pane
    /// some column actually hosts.
    @Test func blankChooseOnALensesHostKeepsTheRingOnAHostedPane() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID,
                defaults: freshDefaults("blankChooseLens"))
            model.host = .lenses
            @MainActor func refresh() async throws {
                model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            }
            try await refresh()

            // A saved lens with an explicit pick on block 1 — its column
            // renders that pick regardless of chosen.
            let pickedTake = world.extraTakes[world.blocks[0]]![0]
            let lens = try await session.runner.run { [postID = world.postID] ops in
                try ops.createLens(post: postID, name: "the other reading")
            }
            _ = try session.operations.setLensChoice(
                lens: lens.id, block: world.blocks[0], variant: pickedTake)
            try await refresh()
            model.addLensColumn(lens.id)

            // The user's focus is the LENS column's pane on block 1 (what
            // the lens board's .blankChoose dispatch reads).
            let lensColumn = try #require(model.columns.first {
                if case .lens = $0.kind { return true } else { return false }
            })
            model.focus(TakesViewModel.PaneKey(
                columnID: lensColumn.id, blockID: world.blocks[0], variantID: pickedTake))

            await model.newBlankTakeAsChosen(blockID: world.blocks[0])
            try await refresh()

            // The rendered pane set: what the board's cells actually key.
            let rendered = Set(model.columns.flatMap { column in
                model.projection.slots.compactMap { slot -> TakesViewModel.PaneKey? in
                    guard let resolved = model.resolvedTake(column: column, slot: slot)
                    else { return nil }
                    return TakesViewModel.PaneKey(
                        columnID: column.id, blockID: slot.blockID,
                        variantID: resolved.variantID)
                }
            })
            // CONSEQUENTIAL PIN EDIT (VX-227 — her R-VX214-1, the F5/F6
            // addendum): a mint's ring re-binds through the PARKED FOLLOW, i.e.
            // when the column's cell reports it has RENDERED the mint. No cell
            // is mounted here, so the cells' render-reports are played for this
            // test's OWN independently computed hosted set (`rendered` above —
            // never a set read back from the park). The assertion is unchanged.
            for key in rendered { model.paneRendered(key) }
            let live = try #require(model.authority.livePane)
            #expect(rendered.contains(live),
                    "the live ring is on a pane a column hosts — never nowhere")
        }
    }

    /// Stage 2 ladder round-2 NIT-R2-C pin (red-on-old): blankChoose on a
    /// Lenses host with NO chosen-showing column used to be a visually
    /// SILENT success (every open column keeps its own pick) — against
    /// fire-and-speak. The no-main branch now says where the act went.
    @Test func blankChooseWithNoChosenColumnSpeaks() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID,
                defaults: freshDefaults("blankChooseSpeaks"))
            model.host = .lenses
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            // No .main column open: the one column becomes a scratch lens.
            model.replaceColumnWithNewScratch(model.columns[0].id)
            #expect(!model.columns.contains { $0.kind == .main })

            await model.newBlankTakeAsChosen(blockID: world.blocks[0])
            #expect(model.statusMessage?.contains("Chosen") == true,
                    "the act speaks — never a visually silent success")
        }
    }

    /// Stage 2 ladder round-2 R2-A pin (red-on-old, behavioral-revert
    /// verified): the D2 class ONE DOOR OVER — the bar's ＋ take (and the
    /// cell-menu twins, same body) on a LENSES host used to reveal to a
    /// pane no column renders (an un-chosen mint changes neither the
    /// column's pick nor chosen: ring vanished, take appeared nowhere).
    /// Host-gated now: the mint lands as the focused column's PICK — the
    /// board's own ⌘T semantics — and the ring follows onto the pane
    /// that now renders it.
    @Test func barMintDoorOnALensesHostLandsInTheFocusedColumn() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID,
                defaults: freshDefaults("barMintLens"))
            model.host = .lenses
            @MainActor func refresh() async throws {
                model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            }
            try await refresh()

            let pickedTake = world.extraTakes[world.blocks[0]]![0]
            let lens = try await session.runner.run { [postID = world.postID] ops in
                try ops.createLens(post: postID, name: "the bar's thread")
            }
            _ = try session.operations.setLensChoice(
                lens: lens.id, block: world.blocks[0], variant: pickedTake)
            try await refresh()
            model.addLensColumn(lens.id)
            let lensColumn = try #require(model.columns.first {
                if case .lens = $0.kind { return true } else { return false }
            })
            model.focus(TakesViewModel.PaneKey(
                columnID: lensColumn.id, blockID: world.blocks[0], variantID: pickedTake))

            // The bar's ＋ take body, exactly (no preferred column —
            // resolution falls to the focused pane's column).
            let minted = await model.branchTakeRevealed(
                blockID: world.blocks[0], from: pickedTake)
            let take = try #require(minted)
            try await refresh()

            // The mint IS the column's pick now (visible where you are)…
            let lensPick = model.projection.lensSelections[lens.id]?[world.blocks[0]]
            #expect(lensPick == take.id, "the mint lands as the focused column's pick")
            // …and the ring names a pane a column actually renders.
            let rendered = Set(model.columns.flatMap { column in
                model.projection.slots.compactMap { slot -> TakesViewModel.PaneKey? in
                    guard let resolved = model.resolvedTake(column: column, slot: slot)
                    else { return nil }
                    return TakesViewModel.PaneKey(
                        columnID: column.id, blockID: slot.blockID,
                        variantID: resolved.variantID)
                }
            })
            // CONSEQUENTIAL PIN EDIT (VX-227 — her R-VX214-1, the F6 ruling):
            // the mint's ring re-binds through the PARKED FOLLOW, when the
            // column's cell reports it has RENDERED the mint. No cell is
            // mounted here, so the render-reports are played for this test's
            // OWN independently computed hosted set (`rendered` above — never a
            // set read back from the park). The assertion is unchanged.
            for key in rendered { model.paneRendered(key) }
            let live = try #require(model.authority.livePane)
            #expect(rendered.contains(live),
                    "the live ring is on a pane a column hosts — never nowhere")
        }
    }

    /// Stage 2 ladder round-2 pin (the R2-A class-completeness sweep's
    /// own find, red-on-old): `divergeHere` from the TAKES board's cell
    /// menu was a SILENT NO-OP — the cells carry board-local column IDs
    /// ("takes-main"/"takes-fan") that never live in `columns`, so the
    /// old body's index guard returned before minting anything (the R112
    /// class). Host-gated now: on the takes host it routes through the
    /// takes reveal (mint + fan open + ring on the fan card).
    @Test func divergeHereFromTheArticleCellMintsOnTheTakesBoard() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID,
                defaults: freshDefaults("divergeArticle"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            // The single-take block — the cell menu's exact call.
            let minted = await model.divergeHere(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blocks[2], fromVariantID: world.chosen[2])
            let take = try #require(minted, "the door MINTS — never a silent no-op")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            #expect(model.projection.fans[world.blocks[2]]?.contains { $0.id == take.id } == true)
            #expect(model.expandedBlocks.contains(world.blocks[2]), "the fan opened")
            #expect(model.authority.livePane == TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: world.blocks[2], variantID: take.id),
                    "the ring keys the fan card the bloom renders")
        }
    }

    /// 13b Stage 3F pin (D2/AD-6; red-on-old, behavioral-revert verified):
    /// the margin grid AT REST measured 680+16+rail — the whole article +
    /// masthead centered around an EMPTY reserved rail and shifted ~118pt
    /// left of where Write and every other style put the prose. The
    /// measure brain now widens ONLY for an engaged rail (an open fan);
    /// at rest every style shares the one 680 prose column.
    @Test func theMarginGridAtRestSharesEveryStyleMeasure() {
        #expect(TakesBoardView.articleMeasure(engagedRailWidth: nil) == 680,
                "no open fan ⇒ the 680 prose column, margin grid included")
        #expect(TakesBoardView.articleMeasure(engagedRailWidth: 236) == CGFloat(932),
                "an engaged rail widens the composition by exactly its reserve")
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
            model.makeLive(row.blockID, variantID: row.variantID!)
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

            // 13b 1a (N3): surfaces no longer register themselves — the
            // quit entry is the POST's session-owned shared coordinator
            // (registered once at creation, weak, clean-flush no-op), so
            // nothing surface-scoped can linger by construction. Teardown
            // detaches the surface's observers; the post's entry remains
            // and a second finalize is a harmless no-op.
            model.teardown()
            #expect(!session.quitFinalize.isEmpty,
                    "the post's shared coordinator stays registered at session scope")
            await session.quitFinalize.finalizeAll()  // idempotent, clean
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

// MARK: - Phase 13, Stage C2 — the takes presentations' pins: the R24
// strip rule (pure threshold), R25 follow-the-scroll blooming (visibility
// alone blooms fanned rows, refcounted across columns, never a single-take
// row), expand-all gating (only the single-column non-slot-split article),
// and the fan-growth doors (branch/blank land through ops; chosen never
// moves — I3 rides).

@Suite("Takes presentations (Phase 13, C2)")
@MainActor
struct TakesPresentationTests {
    /// R24's short/long rule is a pure character threshold — short blocks
    /// take the one-card-high horizontal strip; longer blocks keep the
    /// vertical grid; a gap slot (nil text) reads short.
    @Test func theStripRuleIsAPureCharacterThreshold() {
        #expect(TakesViewModel.usesHorizontalStrip(text: "One short sentence."))
        #expect(TakesViewModel.usesHorizontalStrip(text: nil))
        #expect(TakesViewModel.usesHorizontalStrip(text: ""))
        let long = String(repeating: "prose ", count: 60)  // 360 chars
        #expect(!TakesViewModel.usesHorizontalStrip(text: long))
        // The threshold's edge: 199 strips, 200 grids.
        #expect(TakesViewModel.usesHorizontalStrip(text: String(repeating: "a", count: 199)))
        #expect(!TakesViewModel.usesHorizontalStrip(text: String(repeating: "a", count: 200)))
    }

    /// R25: with follow-the-scroll ON, a fanned row near the viewport
    /// blooms WITHOUT any expansion; visibility is refcounted (multi-column
    /// compositions repeat rows); single-take rows never bloom; the option
    /// off = visibility means nothing; explicit expansion works regardless.
    @Test func followTheScrollBloomsVisibleFannedRowsWithoutExpansion() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("follow"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            let fannedSlot = model.projection.slots.first { $0.blockID == world.blocks[0] }!
            let singleSlot = model.projection.slots.first { $0.blockID == world.blocks[2] }!

            // OFF: visibility alone never blooms.
            model.rowAppeared(world.blocks[0])
            #expect(!model.isBloomed(fannedSlot))

            model.followTheScroll = true
            #expect(model.isBloomed(fannedSlot),
                    "a visible fanned row blooms under follow-the-scroll")
            #expect(model.expandedBlocks.isEmpty, "no expansion was recorded")

            // A single-take row is visible but never blooms.
            model.rowAppeared(world.blocks[2])
            #expect(!model.isBloomed(singleSlot))
            #expect(model.visibleFannedBlocks == [world.blocks[0]],
                    "the visible-fanned set holds exactly the fanned visible rows")

            // REFCOUNT: a second column's copy appears; one disappears —
            // the block stays visible until the LAST copy leaves.
            model.rowAppeared(world.blocks[0])
            model.rowDisappeared(world.blocks[0])
            #expect(model.isBloomed(fannedSlot),
                    "one column scrolling away must not blind the others")
            model.rowDisappeared(world.blocks[0])
            #expect(!model.isBloomed(fannedSlot))

            // Explicit expansion blooms regardless of the option.
            model.followTheScroll = false
            model.toggleExpanded(world.blocks[0])
            #expect(model.isBloomed(fannedSlot))
        }
    }

    /// Expand-all renders wherever it means something — since VX-577 that is
    /// EVERY fan style: slot split's blocks bloom one by one like every other
    /// style's, and her word on the ticket (*"where is expand all takes when
    /// you're in slot split?? you still need it lowkey"*) supersedes R25's
    /// "slot split IS a whole-post fan presentation" half. (A JUSTIFIED EDIT —
    /// the slot-split line flipped; RED on the pre-VX-577 gate.)
    @Test func expandAllIsOfferedOnlyWhereMeaningful() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("gate"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            #expect(model.projection.fanStyle == .stack)
            #expect(model.offersExpandAll, "single column, stack: offered")

            model.adopt(Queries.TakesProjection(
                slots: model.projection.slots, fans: model.projection.fans,
                fanStyle: .slotSplit))
            #expect(model.offersExpandAll,
                    "VX-577: slot split offers expand all too — its blocks bloom one by one")
            model.adopt(Queries.TakesProjection(
                slots: model.projection.slots, fans: model.projection.fans,
                fanStyle: .carousel))
            #expect(model.offersExpandAll, "carousel: offered")

            model.adopt(Queries.TakesProjection(
                slots: model.projection.slots, fans: model.projection.fans,
                fanStyle: .marginGrid))
            #expect(model.offersExpandAll, "margin grid's expand-all is meaningful")

            // Sitting 9 (R86): columns moved to the LENSES tab — the Takes
            // board is single-column always, so columns no longer suppress
            // expand-all (the old multi-column condition is retired).
            model.addScratchColumn()
            #expect(model.offersExpandAll,
                    "columns live in Lenses now — they never gate the Takes board")
        }
    }

    /// The ＋new-take doors land through ops: branch copies the shown
    /// take's text; blank mints empty; the fan grows in order; chosen
    /// never moves (I3 rides the doors).
    @Test func theNewTakeDoorsGrowTheFanThroughOps() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID, defaults: freshDefaults("doors"))
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })

            let blockID = world.blocks[2]  // the single-take block
            await model.branchTake(blockID: blockID, from: world.chosen[2])
            #expect(model.statusMessage == nil)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            let afterBranch = model.projection.fans[blockID] ?? []
            #expect(afterBranch.count == 2, "branch grew the fan")
            #expect(afterBranch.last?.workingText == "Block three, only take.",
                    "the branch inherits the source take's text (the default gesture)")

            await model.newBlankTake(blockID: blockID)
            #expect(model.statusMessage == nil)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            let afterBlank = model.projection.fans[blockID] ?? []
            #expect(afterBlank.count == 3, "blank grew the fan again")
            #expect(afterBlank.last?.workingText == "",
                    "the blank take is the genuinely-different-take gesture")

            // Chosen never moved: the doors mint, they do not choose (I3).
            let slot = model.projection.slots.first { $0.blockID == blockID }!
            #expect(slot.variantID == world.chosen[2])
            #expect(slot.hasFan, "the once-single block now badges")
        }
    }
}

// MARK: - 13b Stage 4, Batch 4C (S4-2d) — the lenses board's block
// drag-reorder: one post, one order, every column together.

@Suite("Lenses block reorder (13b 4C)")
@MainActor
struct LensesReorderTests {
    /// The drag face lands ONE ordinary `reorder` op: the post's order
    /// changes for EVERY column at once (columns render the one slot
    /// order — no column keeps its own), picks survive untouched (they
    /// key on block IDs, not positions), and one ⌥⌘Z restores the order.
    @Test func aDropReordersThePostForEveryColumnAndUndoes() async throws {
        try await withWorld { session, db in
            let world = try await TakesWorld.make(session, db)
            let model = TakesViewModel(
                session: session, postID: world.postID,
                defaults: freshDefaults("lens-reorder"))
            model.host = .lenses
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            // A scratch column with an explicit pick — order-independent.
            model.addScratchColumn()
            await model.pick(
                columnID: model.columns[1].id, blockID: world.blocks[0],
                variantID: world.extraTakes[world.blocks[0]]![0])

            let before = model.projection.slots.map(\.blockID)
            await model.reorderBlock(world.blocks[0], before: world.blocks[2])
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            #expect(model.projection.slots.map(\.blockID)
                    == [world.blocks[1], world.blocks[0], world.blocks[2]],
                    "one ordinary reorder — the stored order moved")
            #expect(model.columns[1].picks[world.blocks[0]]
                    == world.extraTakes[world.blocks[0]]![0],
                    "picks ride the block, not the position — every column shows the new order")

            // Dropping a block before its own successor is a no-op (no
            // gratuitous op, no undo entry).
            await model.reorderBlock(world.blocks[1], before: world.blocks[0])
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            #expect(model.projection.slots.map(\.blockID)
                    == [world.blocks[1], world.blocks[0], world.blocks[2]])

            // ⌥⌘Z: the ordinary inverse restores the exact order.
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in try undoStack.undo(with: ops) }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: world.postID) })
            #expect(model.projection.slots.map(\.blockID) == before,
                    "one ⌥⌘Z restores the pre-drag order")
            model.teardown()
        }
    }

    /// The payload round-trip (the drop parses exactly what the handle
    /// wrote — a foreign string never reorders anything).
    @Test func dragPayloadRoundTripsAndRejectsForeignStrings() {
        let payload = LensesBoardView.dragPayload(blockID: "b-123")
        #expect(LensesBoardView.parseDragPayload(payload) == "b-123")
        #expect(LensesBoardView.parseDragPayload("compare-move:p:b") == nil)
        #expect(LensesBoardView.parseDragPayload("random text") == nil)
    }
}
