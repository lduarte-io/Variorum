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

    @Test func fannedCrossBlockMakeBlockRefusesAndSpeaks() async throws {
        try await withEditor(seedBlocks: ["Aa one. Aa two.", "Zz one. Zz two."]) { harness in
            // Fan the second block: the cross-block gesture must refuse
            // with the OPEN-question copy (#10/#11 — never guessed).
            let second = try await harness.database.read { [postID = harness.postID] db in
                try Queries.renderPost(db, containerID: postID)[1]
            }
            try await harness.session.runner.run { ops in
                _ = try ops.branchVariant(second.blockID, from: second.variantID!)
            }
            try harness.reload()

            let plan = StructuralGesturePlanner.plan(
                .makeBlockFromSelection, selection: NSRange(location: 10, length: 14),
                world: harness.model.gestureWorld())
            #expect(plan == .refusal(.fannedCrossBlockSpan))
            #expect(RefusalCopy.message(for: .fannedCrossBlockSpan).contains("open design"),
                    "the refusal names the open call instead of guessing")

            // And the raw EDIT path is equally ineligible: the refusal
            // speaks; the store stays untouched.
            harness.replace(NSRange(location: 10, length: 14), with: "")
            #expect(harness.model.statusMessage?.contains("open design") == true)
            let texts = try await harness.database.read { db in
                try Queries.renderPost(db, containerID: harness.postID).compactMap(\.text)
            }
            #expect(texts == ["Aa one. Aa two.", "Zz one. Zz two."])
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
