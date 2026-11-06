//
//  CommitsFaceModelTests.swift
//  VariorumTests
//
//  VX-801 (VX-827 U3a — `notes/plans/fixes/vx-827-lineage.md`, U3a RECORD) —
//  **THE COMMITS FACE's brain, focused.** The rail's decisions are pinned
//  headlessly in `CommitRailTests` and the washes in `TextCompareTests`; this
//  suite holds what the MODEL does with them over a real store: where it
//  opens, the dropdown's rows, the filter, the fold and the fast swapper, the
//  four acts through the existing operations with their existing words, and
//  Compare's boxes.
//
//  A PRODUCT row: the face did not exist, so the suite does not compile on the
//  pre-U3a tree. Mac-target — written and compiled at U3a, RUN in the run's
//  closing stage window (the brief: no `xcodebuild test` in the batch).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The Commits face's model (VX-801)", .serialized)
struct CommitsFaceModelTests {
    struct World {
        let session: AppSession
        let postID: String
        let blockID: String
        let takeID: String
    }

    /// A note with one block (one take) and a ticking clock — one second per
    /// stamp, so every moment has its own place in time.
    private func withWorld(
        text: String = "A book read once is a rumor.",
        _ body: @escaping (World) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 801))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "On Rereading")
            let minted = try session.operations.newBlock(in: post.id, text: text)
            try await body(World(
                session: session, postID: post.id, blockID: minted.block.id,
                takeID: minted.variant.id))
        }
    }

    private func model(_ w: World, focused: String? = nil) -> CommitsFaceModel {
        CommitsFaceModel(session: w.session, request: BlockHistoryRequest(
            postID: w.postID, blockID: w.blockID, focusedVariantID: focused ?? w.takeID))
    }

    /// The model's own read, adopted (the `adopt` seam — the observation's
    /// value, without waiting on the observation).
    private func refresh(_ model: CommitsFaceModel, _ w: World) async throws {
        let read = try await w.session.database.read { [blockID = w.blockID, now = w.session.now] db in
            try CommitsFaceModel.read(db, blockID: blockID, now: now)
        }
        model.adopt(read)
    }

    // MARK: - Where it opens, and the rail it opens on

    @Test func itOpensOnTheNewestMomentWithAllTakesInterleaved() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            _ = try ops.commit(w.takeID, message: "first shape")
            let second = try ops.branchVariant(w.blockID, from: w.takeID)
            try ops.autosave(second.id, text: "A book read twice is a place.", charDelta: 4)
            let newest = try ops.commit(second.id, message: "the other take's moment")
            let face = model(w)
            try await refresh(face, w)
            #expect(face.loaded)
            #expect(face.filter == .all, "her ruling: all takes on one line")
            #expect(face.selection == .commit(commitID: newest.id),
                    "the newest moment, whichever take it is on (PROVISIONAL P-U3a-2)")
            let lines = face.lines
            #expect(lines.first?.moment == .now(takeID: w.takeID),
                    "one now line — the take the door was pressed in")
            let moments = CommitRail.selectable(lines)
            #expect(moments.contains(.commit(commitID: newest.id)))
            #expect(face.selectedTake?.id == second.id)
        }
    }

    @Test func aBlockWithNoMomentsOpensOnItsNowWithNoActs() async throws {
        try await withWorld { w in
            let face = model(w)
            try await refresh(face, w)
            #expect(face.selection == .now(takeID: w.takeID))
            #expect(face.text(of: face.selection) == "A book read once is a rumor.")
            #expect(face.paneActs.isEmpty, "a live take's now has nothing to restore or name")
            #expect(face.changesSince == nil)
        }
    }

    /// **"claude just changed something"** — the face opens on the AI's
    /// after-bracket, the before is one ↓ away, and against now it reads the
    /// change.
    @Test func anAIEditOpensOnItsAfterWithTheBeforeOneStepDown() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let edit = try ops.editTakeUnderInsurance(
                w.takeID, text: "A book read once is only a rumor.",
                expectedText: "A book read once is a rumor.", client: "claude-code",
                undoLabel: "claude-code's edit")
            let before = try #require(edit.before)
            let after = try #require(edit.after)
            let face = model(w)
            try await refresh(face, w)
            #expect(face.selection == .commit(commitID: after.id))
            #expect(face.changesSince == CommitsFaceCopy.changesSince(0),
                    "the after IS the take now")
            face.step(by: 1)
            #expect(face.selection == .commit(commitID: before.id), "↓ — the before, one step down")
            #expect(face.changesSince == CommitsFaceCopy.changesSince(1))
            let washed = try #require(face.paneComparison)
            let addedRuns = washed.unified.filter { $0.kind == .added }
            #expect(!addedRuns.isEmpty, "against now, the AI's words read as added")
            face.setWash(.plain)
            #expect(face.paneComparison == nil, "plain is the moment itself")
            #expect(face.changesSince == CommitsFaceCopy.changesSince(1),
                    "the count stays true whichever face shows")
            face.step(by: -2)
            #expect(face.selection == .now(takeID: w.takeID), "↑↑ — up to the take now, and it stops there")
        }
    }

    // MARK: - The dropdown and the filter

    @Test func theDropdownListsLiveTakesThenTheArchivedGroupWithTheChosenMarked() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let spare = try ops.branchVariant(w.blockID, from: w.takeID)
            let shelved = try ops.branchVariant(w.blockID, from: w.takeID)
            _ = try ops.commit(spare.id)
            try ops.archiveVariant(shelved.id)
            let face = model(w)
            try await refresh(face, w)
            let entries = face.takeEntries
            let ids = entries.map { $0.id }
            let archivedFlags = entries.map { $0.archived }
            #expect(ids == [w.takeID, spare.id, shelved.id])
            #expect(archivedFlags == [false, false, true])
            #expect(entries.first?.chosen == true, "the take this note shows")
            #expect(entries[1].commitCount == 1)
            face.setFilter(.take(shelved.id))
            #expect(face.lines.first?.moment == .now(takeID: shelved.id),
                    "one take's rail leads with its now")
            #expect(face.selection == .now(takeID: shelved.id), "no moments: it opens on its now")
            #expect(face.paneActs == [.unarchive],
                    "an archived take's now offers Unarchive (PROVISIONAL P-U3a-6)")
            await face.unarchive(shelved.id)
            #expect(face.status == .receipt(BlockHistoryCopy.unarchivedTake))
        }
    }

    // MARK: - The fold

    @Test func aQuietRunFoldsAndFoldingItAroundTheSelectionMovesThePane() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let old = try ops.commit(w.takeID, message: "kept")
            try ops.autosave(w.takeID, text: "A book read once is a rumour.", charDelta: 1)
            let q1 = try ops.commit(w.takeID, kind: .auto)
            try ops.autosave(w.takeID, text: "A book, read once, is a rumour.", charDelta: 2)
            let q2 = try ops.commit(w.takeID, kind: .auto)
            let face = model(w)
            try await refresh(face, w)
            // The newest moment is inside the run, so the run opened to show it.
            #expect(face.selection == .commit(commitID: q2.id))
            let runID = "run:" + q2.id
            #expect(face.expandedRuns.contains(runID))
            let openIDs = face.lines.map { $0.id }
            #expect(openIDs.contains(q1.id), "the open run lists its members")
            face.toggleRun(runID)
            let foldedIDs = face.lines.map { $0.id }
            #expect(!foldedIDs.contains(q1.id), "folded to one line")
            #expect(face.selection == .commit(commitID: old.id),
                    "the pane moved to the run's neighbour below — never a hidden moment")
        }
    }

    // MARK: - The acts (the panel's, exactly)

    @Test func restoreSpeaksTheReceiptAndAMomentBeforeASplitAsksFirst() async throws {
        try await withWorld(text: "Alpha one. Beta two.") { w in
            let ops = w.session.operations
            let early = try ops.commit(w.takeID, message: "before the cut")
            try ops.autosave(w.takeID, text: "Alpha one. Beta two!", charDelta: 1)
            let face = model(w)
            try await refresh(face, w)
            face.select(.commit(commitID: early.id))
            await face.restoreSelected()
            #expect(face.status == .receipt(BlockHistoryCopy.restoredSavepoint))
            try await refresh(face, w)
            #expect(face.changesSince == CommitsFaceCopy.changesSince(0), "the take now IS the moment")

            _ = try ops.divide(w.blockID, cut: 10)
            try await refresh(face, w)
            face.select(.commit(commitID: early.id))
            await face.restoreSelected()
            #expect(face.pendingRestore?.commit.id == early.id,
                    "a moment older than the split asks first (AppSpec §9's warning)")
            let pending = try #require(face.pendingRestore)
            await face.confirmPendingRestore(pending)
            #expect(face.pendingRestore == nil)
            #expect(face.status == .receipt(BlockHistoryCopy.restoredSavepoint))
        }
    }

    @Test func bringBackAsATakeMintsTheTakeAndSaysSo() async throws {
        try await withWorld { w in
            let moment = try w.session.operations.commit(w.takeID, message: "worth keeping")
            let face = model(w)
            try await refresh(face, w)
            face.select(.commit(commitID: moment.id))
            #expect(face.paneActs == [.restore, .bringBack, .compare, .rename])
            await face.bringBackSelected()
            #expect(face.status == .receipt(BlockHistoryPath.broughtBackAsTake(label: "worth keeping")))
            try await refresh(face, w)
            #expect(face.takes.count == 2, "a take of its own, at the fan's end")
            #expect(face.takeEntries.last?.chosen == false, "never chosen")
        }
    }

    @Test func renameOpensTheFieldAndUnderASealSpeaksTheStandingRefusal() async throws {
        try await withWorld { w in
            let moment = try w.session.operations.commit(w.takeID)
            let face = model(w)
            try await refresh(face, w)
            face.select(.commit(commitID: moment.id))
            face.askRenameSelected()
            #expect(face.renameAsk == .renaming(moment), "the field opens on the moment")
            await face.rename(commitID: moment.id, to: "named at last")
            #expect(face.status == .receipt(BlockHistoryCopy.savepointNamed("named at last")))

            face.renameAsk = nil
            face.adoptSeal(true)
            face.askRenameSelected()
            #expect(face.renameAsk == nil, "under a seal the field never opens")
            #expect(face.status == .refusal(TrayRefusalCopy.sealed))
        }
    }

    @Test func aDeletedTakeWaitsAtTheRailsFootAndPutBackReturnsIt() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let spare = try ops.branchVariant(w.blockID, from: w.takeID)
            try ops.deleteVariant(spare.id)
            let face = model(w)
            try await refresh(face, w)
            let waiting = face.history.deletedTakes.map { $0.id }
            #expect(waiting == [spare.id])
            await face.putBackTake(spare.id)
            #expect(face.status == .receipt(BlockPastCopy.takeRestored))
            try await refresh(face, w)
            #expect(face.history.deletedTakes.isEmpty)
            let back = face.takes.contains { $0.id == spare.id }
            #expect(back)
        }
    }

    // MARK: - Compare

    @Test func compareSetsAMomentBesideItsNowAndOffersNowOnlyAsAThirdBox() async throws {
        try await withWorld { w in
            let ops = w.session.operations
            let moment = try ops.commit(w.takeID, message: "then")
            try ops.autosave(w.takeID, text: "A book read once is a quiet rumor.", charDelta: 6)
            let face = model(w)
            try await refresh(face, w)
            face.select(.commit(commitID: moment.id))
            face.openCompare()
            #expect(face.compareBoxes == [.commit(commitID: moment.id), .now(takeID: w.takeID)])
            #expect(!face.canAddNow, "now already stands")
            let struck = face.boxRuns(0).allSatisfy { $0.kind != .added }
            let washed = face.boxRuns(1).contains { $0.kind == .added }
            #expect(struck, "the first box is the struck side")
            #expect(washed, "the second box washes what arrived")
            face.reaim(box: 1, to: .commit(commitID: moment.id))
            #expect(face.canAddNow, "with no now among them, now is offered")
            face.addNowBox()
            #expect(face.compareBoxes?.count == 3)
            #expect(face.compareBoxes?.last == .now(takeID: w.takeID))
            #expect(!face.canAddNow, "three boxes at most")
            face.removeBox(2)
            #expect(face.compareBoxes?.count == 2)
            face.removeBox(0)
            #expect(face.compareBoxes?.count == 2, "Compare is two boxes at least")
            face.closeCompare()
            #expect(face.compareBoxes == nil)
        }
    }

    @Test func compareFromAnAIHalfSetsBeforeBesideAfter() async throws {
        try await withWorld { w in
            let edit = try w.session.operations.editTakeUnderInsurance(
                w.takeID, text: "A book read twice is a place.",
                expectedText: "A book read once is a rumor.", client: "claude-code",
                undoLabel: "claude-code's edit")
            let before = try #require(edit.before)
            let after = try #require(edit.after)
            let face = model(w)
            try await refresh(face, w)
            face.select(.commit(commitID: after.id))
            face.openCompare()
            #expect(face.compareBoxes == [.commit(commitID: before.id), .commit(commitID: after.id)],
                    "before · after — her reference's two panes")
            #expect(face.canAddNow, "…with now offered as the standing third")
        }
    }
}
