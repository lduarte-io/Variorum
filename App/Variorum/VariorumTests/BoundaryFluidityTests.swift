//
//  BoundaryFluidityTests.swift
//  VariorumTests
//
//  Phase 11, Step A9 — the boundary-fluidity package's RATIFIED halves
//  (author 2026-07-09, committed scope): the guided cross-boundary Make
//  Block (the v1 refusal becomes CONFIRM → adjust neighbor edges →
//  compound divide/divide/merge under ONE undo entry) and single×single
//  cross-block EDITS as merge-then-edit compounds ("a cross-seam delete
//  just works"). The FANNED cases stay speaking refusals — QUESTIONS
//  #10/#11 are deliberately OPEN and settle only at the author's sitting;
//  the CutPropagation auto-proceed DEMO for that sitting lives at the
//  bottom, wired to NO gesture.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Boundary fluidity (Phase 11, A9 — the ratified halves)")
@MainActor
struct BoundaryFluidityTests {
    // MARK: - Merge-then-edit (single×single, ratified)

    /// THE RATIFIED DIRECTION, end to end: a delete spanning two
    /// single-variant blocks becomes ONE merge-then-edit compound — the
    /// selection's surface bytes vanish, the halves join as one block, and
    /// nothing is typed twice or lost.
    @Test func aCrossSeamDeleteJustWorksOnSingleVariantBlocks() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            // Surface: "Alpha one.\nBeta two." — select "one.\nBeta " (6..16).
            let range = NSRange(location: 6, length: 10)
            let compound = try #require(
                harness.model.planCrossBlockEdit(range: range, replacement: ""),
                "two clean single-variant blocks are eligible")
            await harness.model.runCrossBlockEdit(compound)

            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Alpha two."],
                    "the cross-seam delete left EXACTLY the unselected text, one block")
            #expect(harness.documentText == "Alpha two.",
                    "the surface re-rendered to the compound's outcome")

            // ONE undo entry restores the pre-compound world; the edited
            // merged mint lands in the tray (the divergence insurance —
            // nothing typed becomes unreachable).
            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            let restored = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(restored == ["Alpha one.", "Beta two."],
                    "one ⌥⌘Z restores both blocks byte-identically")
            let trayed = try await harness.database.read { db in
                try Queries.trayBlocks(db, postID: harness.postID)
            }
            #expect(trayed.count == 1,
                    "the edited merged mint trays instead of vanishing (insurance doctrine)")
        }
    }

    /// The routing pin: the raw keystroke path (shouldChangeText) refuses
    /// the storage edit and schedules the compound — the storage never
    /// half-applies a cross-block replacement.
    @Test func theKeystrokePathRoutesCrossBlockDeletesIntoTheCompound() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            harness.replace(NSRange(location: 6, length: 10), with: "")
            // The keystroke itself was refused (surface unchanged, for now).
            #expect(harness.documentText == "Alpha one.\nBeta two.")
            // The compound lands asynchronously — pump with real awaits.
            for _ in 0..<200 {
                let count = try await harness.database.read { db in
                    try Queries.renderPost(db, containerID: harness.postID).count
                }
                if count == 1 { break }
                try await Task.sleep(for: .milliseconds(10))
            }
            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Alpha two."])
            #expect(harness.model.statusMessage == nil,
                    "eligible cross-block edits never show the refusal")
        }
    }

    // MARK: - The guided cross-boundary Make Block (ratified flow)

    @Test func guidedMakeBlockPlansConfirmFirstThenCompounds() async throws {
        try await withEditor(seedBlocks: [
            "Aa one. Aa two.", "Middle block.", "Zz one. Zz two.",
        ]) { harness in
            // Document: [0..15) sep [16..29) sep [30..45). Select from
            // inside sentence 2 of block 1 to the end of sentence 1 of
            // block 3 (offset 38 = the last block's interior boundary).
            let selection = NSRange(location: 10, length: 28)
            let plan = StructuralGesturePlanner.plan(
                .makeBlockFromSelection, selection: selection,
                world: harness.model.gestureWorld())
            guard case .makeBlockAcrossBlocks(_, let blockIDs, let startCut, let endCut) = plan
            else {
                Issue.record("expected the guided plan, got \(plan)")
                return
            }
            #expect(blockIDs.count == 3)
            #expect(startCut == 8, "the start snapped to the sentence boundary")
            #expect(endCut == 8, "the end snapped to the sentence boundary")

            // The plan opens a CONFIRM — no rows are touched by planning.
            await harness.model.applyStructural(plan)
            #expect(harness.model.crossBlockMakeConfirm != nil, "the guided flow confirms first")
            let untouched = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(untouched == ["Aa one. Aa two.", "Middle block.", "Zz one. Zz two."])

            // Confirm: divide/divide/merge as ONE compound.
            let state = try #require(harness.model.crossBlockMakeConfirm)
            await harness.model.confirmCrossBlockMakeBlock(state)
            let after = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(after == ["Aa one.", "Aa two. Middle block. Zz one.", "Zz two."],
                    "the in-span pieces became ONE block; the out-of-span edges survive")

            // ONE undo restores the original three blocks byte-identically
            // (untouched mints vanish as if never made).
            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            let restored = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(restored == ["Aa one. Aa two.", "Middle block.", "Zz one. Zz two."])
        }
    }

    // `fannedCrossBlockMakeBlockRefusesAndSpeaks` SUPERSEDED 2026-07-13
    // (the #10/#11 sitting rulings): the gesture path now auto-proceeds on
    // unique matches or opens the W ceremony; the edit path performs the
    // VISIBLE-TAKE delete. The tests below pin the ruled behaviors.

    /// #10: a fanned edge whose cut maps UNIQUELY into every take
    /// auto-proceeds — NO ceremony sheet; the out-of-span half keeps its
    /// per-take fan; the middle mints single-variant; ONE undo restores.
    @Test func aFannedEdgeWithUniqueMatchesAutoProceedsWithNoCeremony() async throws {
        let visible = "One prefix here. COMMON MIDDLE IS LONG. COMMON END HERE."
        let other = "Two other start. COMMON MIDDLE IS LONG. COMMON END HERE."
        try await withEditor(seedBlocks: [visible, "Second block text goes on."]) { harness in
            let firstSlot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[0]
            }
            try await harness.session.runner.run { ops in
                let take = try ops.branchVariant(firstSlot.blockID, from: firstSlot.variantID!)
                try ops.autosave(take.id, text: other, charDelta: 6)
            }
            try harness.reload()

            // Select from inside the shared region of block 1 to the end
            // of block 2: startCut snaps to 40 (inside COMMON text — both
            // context windows shared), endCut = the whole second block.
            let selection = NSRange(location: 42, length: 41)
            let plan = StructuralGesturePlanner.plan(
                .makeBlockFromSelection, selection: selection,
                world: harness.model.gestureWorld())
            guard case .makeBlockAcrossBlocks(_, _, let startCut, let endCut) = plan else {
                Issue.record("fanned cross-block Make Block plans the guided flow, got \(plan)")
                return
            }
            #expect(startCut == 40)
            #expect(endCut == 26)

            await harness.model.applyStructural(plan)
            let state = try #require(harness.model.crossBlockMakeConfirm)
            await harness.model.confirmCrossBlockMakeBlock(state)

            #expect(harness.model.divideWCeremony == nil,
                    "unique matches everywhere — the ceremony never appears")
            let slots = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
            #expect(slots.count == 2)
            #expect(slots[0].activeVariantCount == 2,
                    "the out-of-span half keeps its per-take fan (W-style)")
            #expect(slots[0].text == "One prefix here. COMMON MIDDLE IS LONG.")
            #expect(slots[1].activeVariantCount == 1,
                    "the middle mints single-variant (merge's standing semantics)")
            #expect(slots[1].text == "COMMON END HERE. Second block text goes on.")
            // The other take's out-of-span half rode the fan too.
            let outFan = try await harness.database.read { db in
                try Queries.blockFan(db, blockID: slots[0].blockID)
            }
            #expect(outFan.map(\.workingText).contains("Two other start. COMMON MIDDLE IS LONG."))

            // ONE undo restores the original world byte-identically.
            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            let restored = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
            #expect(restored.compactMap(\.text) == [visible, "Second block text goes on."])
            #expect(restored[0].activeVariantCount == 2)
        }
    }

    /// #10's other half: a take that does NOT map uniquely opens the W
    /// ceremony — the sheet survives exactly where a genuine per-take
    /// decision exists; the store is untouched until it confirms.
    @Test func aNonMatchingTakeOpensTheCeremonyInstead() async throws {
        let visible = "One prefix here. COMMON MIDDLE IS LONG. COMMON END HERE."
        try await withEditor(seedBlocks: [visible, "Second block text goes on."]) { harness in
            let firstSlot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[0]
            }
            try await harness.session.runner.run { ops in
                let take = try ops.branchVariant(firstSlot.blockID, from: firstSlot.variantID!)
                try ops.autosave(
                    take.id, text: "Entirely different words with nothing shared at all.",
                    charDelta: 6)
            }
            try harness.reload()

            let plan = StructuralGesturePlanner.plan(
                .makeBlockFromSelection, selection: NSRange(location: 42, length: 41),
                world: harness.model.gestureWorld())
            await harness.model.applyStructural(plan)
            let state = try #require(harness.model.crossBlockMakeConfirm)
            await harness.model.confirmCrossBlockMakeBlock(state)

            #expect(harness.model.divideWCeremony != nil,
                    "the ceremony OPENS for the non-matching take — never a guess, never a refusal")
            let slots = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
            #expect(slots.count == 2, "opening the ceremony touched no rows")
            #expect(slots.compactMap(\.text)[0] == visible)
        }
    }

    /// #11a: the plain cross-block delete on a FANNED span edits the
    /// VISIBLE takes only — fan, seam, and block structure untouched; the
    /// result is two blocks, NOT a join (the ruled deviation); unseen
    /// takes never change; one undo compound restores.
    @Test func aFannedCrossBlockDeleteEditsTheVisibleTakesOnly() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two.", "Beta words here."]) { harness in
            let firstSlot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[0]
            }
            let otherText = "A different take entirely."
            let otherTakeID = try await harness.session.runner.run { ops -> String in
                let take = try ops.branchVariant(firstSlot.blockID, from: firstSlot.variantID!)
                try ops.autosave(take.id, text: otherText, charDelta: 6)
                return take.id
            }
            try harness.reload()

            // Surface: "Alpha one. Alpha two.\nBeta words here." — select
            // "Alpha two.\nBeta " (11..27) and delete via the keystroke path.
            harness.replace(NSRange(location: 11, length: 16), with: "")
            for _ in 0..<200 {
                let text = try await harness.database.read { [postID = harness.postID] db in
                    try Queries.renderedText(db, containerID: postID)
                }
                if text != "Alpha one. Alpha two.\n\nBeta words here." { break }
                try await Task.sleep(for: .milliseconds(10))
            }

            let slots = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
            #expect(slots.count == 2, "NOT a join — the fan hangs on the seam (the ruled deviation)")
            #expect(slots[0].text == "Alpha one. ", "the visible take lost exactly its piece")
            #expect(slots[1].text == "words here.")
            #expect(slots[0].activeVariantCount == 2, "the fan is untouched")
            let unseen = try await harness.database.read { db in
                try String.fetchOne(
                    db, sql: "SELECT working_text FROM variant WHERE id = ?",
                    arguments: [otherTakeID])
            }
            #expect(unseen == otherText, "the unseen take NEVER changes — no guessing")

            // ONE undo compound restores both visible takes.
            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            let restored = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID).compactMap(\.text)
            }
            #expect(restored == ["Alpha one. Alpha two.", "Beta words here."])
        }
    }

    /// #11b: "Delete in Every Take" applies where the span matches
    /// UNIQUELY, skips-and-REPORTS where it doesn't, and undoes as one
    /// compound.
    @Test func deleteInEveryTakeAppliesWhereUniqueAndReportsSkips() async throws {
        let visible = "Keep this. REMOVE EXACTLY THIS. Keep that."
        try await withEditor(seedBlocks: [visible]) { harness in
            let slot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[0]
            }
            let (matchID, noMatchID) = try await harness.session.runner.run { ops -> (String, String) in
                let match = try ops.branchVariant(slot.blockID, from: slot.variantID!)
                try ops.autosave(
                    match.id, text: "Other opening. REMOVE EXACTLY THIS. Other closing.",
                    charDelta: 6)
                let noMatch = try ops.branchVariant(slot.blockID, from: slot.variantID!)
                try ops.autosave(
                    noMatch.id, text: "This take shares none of the doomed text.", charDelta: 6)
                return (match.id, noMatch.id)
            }
            try harness.reload()

            // Select " REMOVE EXACTLY THIS." (10..31) in the visible take.
            harness.textView.setSelectedRange(NSRange(location: 10, length: 21))
            await harness.model.deleteInEveryTake()

            let texts = try await harness.database.read { db -> [String: String] in
                let fan = try Queries.blockFan(db, blockID: slot.blockID)
                return Dictionary(uniqueKeysWithValues: fan.map { ($0.id, $0.workingText) })
            }
            #expect(texts[slot.variantID!] == "Keep this. Keep that.")
            #expect(texts[matchID] == "Other opening. Other closing.",
                    "the unique match applied — located per take, never by offset")
            #expect(texts[noMatchID] == "This take shares none of the doomed text.",
                    "no unique match ⇒ untouched")
            let report = try #require(harness.model.statusMessage)
            #expect(report.contains("Deleted in 2 takes"), "the report: \(report)")
            #expect(report.contains("Skipped 1"), "skips are REPORTED, visibly — her explicit call")

            // ONE undo compound restores every edited take.
            let stack = harness.session.undoStack
            try await harness.session.runner.run { ops in
                _ = try stack.undo(with: ops)
            }
            let restored = try await harness.database.read { db -> [String: String] in
                let fan = try Queries.blockFan(db, blockID: slot.blockID)
                return Dictionary(uniqueKeysWithValues: fan.map { ($0.id, $0.workingText) })
            }
            #expect(restored[slot.variantID!] == visible)
            #expect(restored[matchID] == "Other opening. REMOVE EXACTLY THIS. Other closing.")
        }
    }

    /// #11c: merge stays the explicit seam-removal gesture — and on fanned
    /// blocks it SPEAKS about what it does to the fan.
    @Test func mergeOnFannedBlocksSpeaksAboutTheFan() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            let secondSlot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[1]
            }
            try await harness.session.runner.run { ops in
                _ = try ops.branchVariant(secondSlot.blockID, from: secondSlot.variantID!)
            }
            try harness.reload()

            harness.textView.setSelectedRange(NSRange(location: 4, length: 10))
            await harness.model.invokeGesture(.mergeBlocks)

            let slots = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)
            }
            #expect(slots.count == 1, "merge merged")
            let status = try #require(harness.model.statusMessage)
            #expect(status.contains("other take"),
                    "the gesture SPEAKS about the fan it folded away: \(status)")
        }
    }

    /// THE CAS FENCE's direct pin (red-on-old: without expectedText the
    /// stale compound clobbers the newer typing — the soak surfaced this
    /// class with 102 issues on the pre-fix code): a compound planned
    /// against one surface REFUSES, visibly and wholly, when any target
    /// buffer moved before it landed. Nothing is altered; the gesture is
    /// simply re-tryable on the current text.
    @Test func aCompoundPlannedAgainstAStaleBufferRefusesInsteadOfClobbering() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Alpha two.", "Beta words here."]) { harness in
            let firstSlot = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[0]
            }
            try await harness.session.runner.run { ops in
                _ = try ops.branchVariant(firstSlot.blockID, from: firstSlot.variantID!)
            }
            try harness.reload()

            let visible = try #require(harness.model.planVisibleTakeEdit(
                range: NSRange(location: 11, length: 16), replacement: ""))
            // The world moves inside the scheduling window (the soak's
            // exact interleaving, made deterministic).
            harness.type("INTERLOPER ", at: 0)
            await harness.model.autosave.flushNow()

            await harness.model.runVisibleTakeEdit(visible)

            #expect(harness.model.statusMessage?.contains("changed while") == true,
                    "the refusal speaks: \(harness.model.statusMessage ?? "nil")")
            let texts = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID).compactMap(\.text)
            }
            #expect(texts == ["INTERLOPER Alpha one. Alpha two.", "Beta words here."],
                    "NOTHING was altered — the newer typing survives whole")
        }
    }

    // MARK: - THE DEMO for QUESTIONS #10 (prepared, wired to NOTHING)

    /// CutPropagation's unique-match condition, demonstrated for the
    /// author's sitting: when the span's context matches UNIQUELY in EVERY
    /// take of a fanned block, per-take cuts are computable with no human
    /// marking — the auto-proceed W the OPEN question weighs. This test IS
    /// the demo (plus the ops outcome it would produce); no gesture calls
    /// it — building past #10 without her answer is the forbidden move.
    @Test func demoAutoProceedCutsAreComputableWhenEveryTakeMatchesUniquely() async throws {
        let activeText =
            "AAA intro. SHARED ONE IS HERE. SHARED TWO IS HERE. SHARED THREE DONE. AAA outro."
        let targetText =
            "BBB start line. SHARED ONE IS HERE. SHARED TWO IS HERE. SHARED THREE DONE. BBB finish."
        try await withEditor(seedBlocks: [activeText]) { harness in
            let (blockID, activeID) = try await harness.database.read {
                [postID = harness.postID] db -> (String, String) in
                let slot = try Queries.renderPost(db, containerID: postID)[0]
                return (slot.blockID, slot.variantID!)
            }
            try await harness.session.runner.run { ops in
                let take = try ops.branchVariant(blockID, from: activeID)
                try ops.autosave(take.id, text: targetText, charDelta: 10)
            }

            // The demo's question: can the active take's cuts carry into
            // every take without marking? Here: YES — the cuts sit inside
            // a long shared region, so the ±16-unit context windows match
            // UNIQUELY (CutPropagation's condition; at cuts whose context
            // differs across takes it proposes NOTHING — a seed, never a
            // guess).
            let startCut = try #require(CutPropagation.propose(
                activeCut: 31, activeText: activeText, targetText: targetText))
            #expect(startCut == 36, "the span's start maps uniquely into the other take")
            let endCut = try #require(CutPropagation.propose(
                activeCut: 51, activeText: activeText, targetText: targetText))
            #expect(endCut == 56, "the span's end maps uniquely too")

            // What auto-proceed WOULD mint (shown with the real op): a
            // divideW carrying the mapped cuts through every take — no
            // human marking left to do.
            let cuts = try await harness.database.read { db -> [String: Int] in
                let fan = try Variant
                    .filter(Column("block_id") == blockID && Column("deleted_at") == nil)
                    .order(Column("fan_position"), Column("id"))
                    .fetchAll(db)
                return Dictionary(uniqueKeysWithValues: fan.map {
                    ($0.id, $0.workingText.hasPrefix("AAA") ? 31 : 36)
                })
            }
            _ = try await harness.session.runner.run { ops in
                try ops.divideW(blockID, cuts: cuts)
            }
            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts.count == 2, "W-style: first-half fan + second-half fan")
        }
    }
}
