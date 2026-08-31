//
//  MobileBlockHistoryTests.swift
//  VariorumMobileTests
//
//  **THE BLOCK HISTORY TWIN** (mobile round 2, batch 6a) — the phone's
//  edition of the post-13l polish round's ledger row 17, and the end of the
//  round's **deleted-take dark window** (LR1-3): before this batch a deleted
//  take was invisible AND un-restorable on the phone, because `TrashScope`
//  had correctly stopped rowing takes in the global Trash while only the Mac
//  gained the take's new homes.
//
//  Grown out of `MobileTakeHistoryTests` (parity C4a), whose commit/restore
//  pins ride here unchanged in substance — the face they exercise widened
//  from one take's savepoints to the whole block's time.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

@MainActor
private func seedPost(
    _ session: AppSession
) async throws -> (postID: String, blockID: String, variantID: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "history", profile: .blog)
        let a = try ops.newBlock(
            in: post.id, text: "First sentence stays. Second sentence leaves.", at: .end)
        return (post.id, a.block.id, a.variant.id)
    }
}

@MainActor
private func storedTakeText(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT working_text FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID])
    }
}

@MainActor
private func commitRows(
    _ db: AppDatabase, variantID: String
) async throws -> [(kind: String, text: String)] {
    try await db.read { db in
        try Row.fetchAll(
            db,
            sql: """
                SELECT kind, text FROM commit_point WHERE variant_id = ?
                ORDER BY created_at, id
                """,
            arguments: [variantID]
        ).map { ($0["kind"], $0["text"]) }
    }
}

/// The savepoint rows the face is showing, for one take.
private func savepoints(
    _ rows: [MobileBlockHistoryController.Row], of variantID: String
) -> [CommitPoint] {
    rows.compactMap {
        if case .savepoint(let id, let commit, _) = $0, id == variantID { return commit }
        return nil
    }
}

private func sectionTitles(_ rows: [MobileBlockHistoryController.Row]) -> [String] {
    rows.compactMap {
        if case .sectionHeader(let title, _) = $0 { return title }
        return nil
    }
}

// MARK: - The suite

@MainActor
@Suite("Mobile Block History — the block's whole time, in one face")
struct MobileBlockHistoryTests {
    // MARK: Commit — history's pair

    /// The commit door is FLUSH-FIRST: the savepoint holds exactly the
    /// bytes she sees (pending surface text included), kind manual, with
    /// the success spoken.
    @Test func commitKeepsASavepointOfTheDisplayedTakeFlushFirst() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let typed = "First sentence stays. Second sentence leaves. Typed."
            model.recordTakeEdit(variantID: seed.variantID, text: typed, charDelta: 7)
            #expect(model.autosave.isDirty)

            await model.blockHistory.commitNow(blockID: seed.blockID)

            #expect(model.statusMessage == MobileBlockHistoryController.committedStatus)
            let commits = try await commitRows(db, variantID: seed.variantID)
            #expect(commits.map(\.kind) == ["manual"])
            #expect(commits.first?.text == typed,
                    "the savepoint holds the TYPED bytes — the flush rode in front")
            #expect(!model.autosave.isDirty)
        }
    }

    /// The seal and the take lock both refuse in phone words (the ops'
    /// own guards — commit is forbidden under both).
    @Test func commitUnderSealAndOnALockedTakeRefuseInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            try await session.runner.run { ops in try ops.lockVariant(seed.variantID) }
            await model.refreshTakesFromStore()
            await model.blockHistory.commitNow(blockID: seed.blockID)
            #expect(model.statusMessage == MobileEditorViewModel.lockedTakeRefusal)

            try await session.runner.run { ops in try ops.unlockVariant(seed.variantID) }
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.refreshTakesFromStore()
            await model.blockHistory.commitNow(blockID: seed.blockID)
            #expect(model.statusMessage == "This note is locked — unlock it to commit this take.")
            // The one row is the SEAL's own auto-commit insurance
            // (lockPost insures dirty buffers — its designed behavior);
            // the refused door added no manual savepoint.
            #expect(try await commitRows(db, variantID: seed.variantID).map(\.kind) == ["auto"])
        }
    }

    // MARK: Region 1 — every live take's savepoint run

    /// **Her ruling, as the face's own content**: ALL live takes are
    /// sectioned, and the take she is in is the one that opens expanded —
    /// through the SHARED rule (`BlockHistoryExpansion`), so the phone can
    /// never open a different take than the Mac would.
    @Test func everyLiveTakesRunIsSectionedAndTheFocusedOneOpensExpanded() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            let second = try await session.runner.run { ops -> Variant in
                let take = try ops.branchVariant(seed.blockID, from: seed.variantID)
                _ = try ops.commit(take.id, kind: .manual)
                _ = try ops.commit(seed.variantID, kind: .manual)
                return take
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            #expect(history.focusedVariantID == seed.variantID)
            let headers = history.rows().compactMap { row -> (String, Bool)? in
                if case .takeHeader(let id, _, let focused, _, let expanded) = row {
                    return (id, expanded && focused)
                }
                return nil
            }
            #expect(headers.count == 2, "BOTH live takes are sectioned")
            #expect(Set(headers.map(\.0)) == [seed.variantID, second.id])
            #expect(history.expandedTakes == [seed.variantID],
                    "the take you're in is the one that opens")

            // The chosen take's run is drawn; the other take's is folded.
            #expect(savepoints(history.rows(), of: seed.variantID).count == 1)
            #expect(savepoints(history.rows(), of: second.id).isEmpty)
            history.toggleTake(second.id)
            #expect(savepoints(history.rows(), of: second.id).count == 1,
                    "opening the other take's section draws its own run")
        }
    }

    /// Savepoint rows are newest-first with kinds marked, and commits older
    /// than the newest divide/extract wear the pre-split flag — through the
    /// ONE core predicate (`Queries.commitPredatesSplit`).
    @Test func theRunReadsNewestFirstWithKindsAndThePreSplitFlag() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)
                try ops.autosave(
                    seed.variantID,
                    text: "First sentence stays! Second sentence leaves.", charDelta: 1)
                _ = try ops.commit(seed.variantID, kind: .auto)
                _ = try ops.divide(seed.blockID, cut: 22)
                _ = try ops.commit(seed.variantID, kind: .manual)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            let commits = savepoints(history.rows(), of: seed.variantID)
            #expect(commits.count == 3)
            #expect(commits.map(\.kind) == [.manual, .auto, .manual], "newest first")
            let flags = history.rows().compactMap { row -> Bool? in
                if case .savepoint(_, _, let predates) = row { return predates }
                return nil
            }
            #expect(flags == [false, true, true],
                    "commits older than the newest split wear the flag; the post-split one doesn't")
        }
    }

    /// Restore loads the savepoint back into the buffer and the surface
    /// heals; a PRE-SPLIT row gates on the confirm first, and confirming
    /// resurrects the full pre-split text (AppSpec §9's documented
    /// behavior, warned exactly as the spec asks).
    @Test func restoreLoadsTheSavepointAndThePreSplitRoadGatesOnConfirm() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let full = "First sentence stays. Second sentence leaves."
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)   // pre-split: the full text
                _ = try ops.divide(seed.blockID, cut: 22)
                _ = try ops.commit(seed.variantID, kind: .manual)   // post-split: the first half
                try ops.autosave(seed.variantID, text: "First sentence, reworked.", charDelta: 8)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            let rows = history.rows()
            let postSplit = try #require(rows.compactMap { row -> CommitPoint? in
                if case .savepoint(_, let c, let p) = row, !p { return c }
                return nil
            }.first)
            let preSplit = try #require(rows.compactMap { row -> CommitPoint? in
                if case .savepoint(_, let c, let p) = row, p { return c }
                return nil
            }.first)

            // The clean restore: buffer + surface read as the savepoint, and
            // the RECEIPT is classed as one (never guessed from its words).
            await history.restore(postSplit, of: seed.variantID)
            #expect(history.status == .receipt(BlockHistoryCopy.restoredSavepoint))
            #expect(history.status?.isRefusal == false)
            #expect(try await storedTakeText(db, variantID: seed.variantID) == postSplit.text)
            #expect(storage.string.contains(postSplit.text))

            // The pre-split road GATES: nothing moves until the confirm.
            await history.restore(preSplit, of: seed.variantID)
            #expect(history.pendingRestore?.commit == preSplit)
            #expect(try await storedTakeText(db, variantID: seed.variantID) == postSplit.text,
                    "unconfirmed — the buffer is untouched")

            history.cancelPendingRestore()
            #expect(history.pendingRestore == nil)

            await history.restore(preSplit, of: seed.variantID)
            await history.confirmPendingRestore()
            #expect(history.status == .receipt(BlockHistoryCopy.restoredSavepoint))
            #expect(try await storedTakeText(db, variantID: seed.variantID) == full)
            #expect(storage.string.contains(full))
        }
    }

    /// Restore refuses under the seal, in phone words, and the refusal is
    /// CLASSED as one so the face can wear its alarm token; the buffer stays.
    @Test func restoreUnderASealedNoteRefusesInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)
                try ops.autosave(seed.variantID, text: "Edited past the savepoint.", charDelta: 5)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()
            let commit = try #require(
                savepoints(model.blockHistory.rows(), of: seed.variantID).first)

            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.blockHistory.restore(commit, of: seed.variantID)
            #expect(model.blockHistory.status
                    == .refusal("This note is locked — unlock it to restore this savepoint."))
            #expect(model.blockHistory.status?.isRefusal == true)
            #expect(try await storedTakeText(db, variantID: seed.variantID)
                    == "Edited past the savepoint.")
        }
    }

    // MARK: Region 2 — archived takes

    /// An archived take is listed with its no-clock promise and comes back
    /// through the face's own Unarchive.
    @Test func anArchivedTakeIsListedAndUnarchiveBringsItBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let extra = try await session.runner.run { ops -> Variant in
                let take = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.archiveVariant(take.id)
                return take
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            #expect(sectionTitles(history.rows()).contains(BlockHistoryPath.archivedSection))
            #expect(history.rows().contains {
                if case .archivedTake(let take) = $0 { return take.id == extra.id }
                return false
            }, "the archived take is her information and it is on screen")

            await history.unarchive(extra.id)
            #expect(history.status == .receipt(BlockHistoryCopy.unarchivedTake))
            let status = try await db.read { [id = extra.id] db in
                try Variant.fetchOne(db, key: id)?.status
            }
            #expect(status == .active, "back in the fan")
            #expect(!history.rows().contains {
                if case .archivedTake = $0 { return true }
                return false
            }, "and out of the archived region")
        }
    }

    // MARK: Region 3 — deleted takes (THE DARK WINDOW, closed)

    /// **The hole this batch exists to close.** A deleted take rows nowhere
    /// global by design (`TrashScope`), so before this face the phone could
    /// neither SEE it nor GET IT BACK. Here it is listed with its clock, and
    /// Put back really restores it.
    @Test func aDeletedTakeIsVisibleAndPutBackRestoresIt() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let extra = try await session.runner.run { ops -> Variant in
                let take = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.deleteVariant(take.id)
                return take
            }
            // The global Trash is NOT the take's home — that is the rule
            // this face makes safe (the phone reads the shared TrashScope).
            #expect(!TrashScope.listedKinds.contains(.take))

            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            #expect(sectionTitles(history.rows()).contains(BlockHistoryPath.deletedSection))
            let row = try #require(history.rows().compactMap { row -> String? in
                if case .deletedTake(let take, let meta) = row, take.id == extra.id {
                    return meta
                }
                return nil
            }.first)
            #expect(row.contains("deleted"), "the row says when it went — \(row)")
            #expect(row.contains("days left") || row.contains("leaves today"),
                    "and how long it has — \(row)")

            await history.putBackTake(extra.id)
            #expect(history.status == .receipt(BlockPastCopy.takeRestored))
            let alive = try await db.read { [id = extra.id] db in
                try Variant.fetchOne(db, key: id)?.deletedAt
            }
            #expect(alive == nil, "the take is live again")
        }
    }

    /// A take ARCHIVED when it was deleted comes back archived — the exact
    /// flip (#68(b)) — and the receipt reads the op's OWN answer rather than
    /// promising the fan.
    @Test func aTakeArchivedWhenDeletedComesBackArchivedAndSaysSo() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let extra = try await session.runner.run { ops -> Variant in
                let take = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.archiveVariant(take.id)
                try ops.deleteVariant(take.id)
                return take
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            await model.blockHistory.putBackTake(extra.id)
            #expect(model.blockHistory.status == .receipt(BlockPastCopy.takeRestoredArchived))
            let status = try await db.read { [id = extra.id] db in
                try Variant.fetchOne(db, key: id)?.status
            }
            #expect(status == .archived, "the exact flip stands — nothing un-archived")
        }
    }

    /// **NO PURGE DOOR ON THIS FACE** — her evolved rule (purge doors live
    /// on TRASH SURFACES only). Asserted over the face's own rows, which is
    /// where a stray Delete Now would have to appear, and over the phone's
    /// explainer, which must not promise a road the phone lacks.
    @Test func theDeletedRegionCarriesNoPurgeDoorAndPromisesNoneEither() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            _ = try await session.runner.run { ops -> Variant in
                let take = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.deleteVariant(take.id)
                return take
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            // The face names what it renders, and `deleteNow` is absent.
            #expect(!MobileBlockHistorySheetView.surfaceCapabilities.contains("deleteNow"))
            let words = model.blockHistory.rows().flatMap { row -> [String] in
                switch row {
                case .sectionHeader(let a, let b): return [a, b]
                case .quiet(let a): return [a]
                case .deletedTake(_, let meta): return [meta]
                default: return []
                }
            }
            // **BATCH 6b — the sanctioned flip, and what it does NOT change.**
            // The region still renders NO purge door of its own (her evolved
            // rule: Delete Now lives on trash surfaces, never in the writing
            // flow), and this face is not one. What changed is the
            // EXPLAINER: the phone now HAS a trash surface for takes — the
            // per-note tray's Leaving section — so the sentence names it
            // instead of ending after Put back. The distinction the pin now
            // holds is exactly the one that matters: naming a road ≠ being
            // one.
            for line in words where line != MobileBlockHistoryController.deletedExplainer {
                #expect(!line.contains(RecoveryCopy.deleteNowVerb),
                        "no purge door, and no promise of one: \(line)")
                #expect(!line.contains("Mac"), "no redirect anywhere: \(line)")
            }
            #expect(!MobileBlockHistorySheetView.surfaceCapabilities.contains("deleteNow"),
                    "the face still renders no purge door of its own")
            #expect(MobileBlockHistoryController.deletedExplainer
                    == "On the \(TrashWindow.days)-day clock. Put one back here; "
                        + "to end a take's remaining days early, "
                        + "\(MobileNoteTrayModel.purgeRoadPhrase).")
            #expect(!MobileBlockHistoryController.deletedExplainer.contains("Mac"))
        }
    }

    // MARK: Region 4 — came from

    /// **ALL of a merge's originals, never the first** (the 13l walk's P-3,
    /// which is exactly the defect this region was designed against), each
    /// with a one-button way back that really places the block.
    @Test func cameFromShowsEveryOriginAndBringBackReallyPlacesOne() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops -> Container in
                let post = try ops.createPost(title: "merged", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "The first half.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "The second half.", at: .end)
                return post
            }
            let (before, merged) = try await session.database.read { db -> ([String], String?) in
                let ids = try String.fetchAll(
                    db,
                    sql: """
                        SELECT block_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position
                        """,
                    arguments: [post.id])
                return (ids, nil)
            }
            #expect(before.count == 2)
            let mergedBlock = try await session.runner.run { ops -> String in
                try ops.merge(before[0], before[1]).block.id
            }
            _ = merged

            let (model, _) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            model.blockHistory.open(blockID: mergedBlock)
            await model.blockHistory.refresh()

            let history = model.blockHistory
            #expect(sectionTitles(history.rows()).contains(BlockHistoryPath.cameFromSection))
            let origins = history.rows().compactMap { row -> String? in
                if case .origin(let blockID, _, _) = row { return blockID }
                return nil
            }
            #expect(Set(origins) == Set(before),
                    "BOTH parents — the door that showed one of two is the defect this closes")

            await history.bringBack(before[0])
            #expect(history.status?.isRefusal == false)
            let placed = try await db.read { [id = before[0]] db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT container_id FROM container_block
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [id])
            }
            #expect(placed == post.id, "the original is back in the note")
        }
    }

    // MARK: The fix round — batch 6a's cold review

    /// **A FANNED BLOCK IS NOT A BLOCK WITH ONE TAKE** (M2). The face used
    /// to route on `Queries.BlockHistory.isEmpty`, which is about
    /// savepoints, archived takes, deleted takes and origins and says
    /// NOTHING about how many live takes there are — so the everyday state
    /// after `branchVariant` (fanned, nothing committed yet) was answered
    /// with *"This block has no past yet: one take…"* and every take
    /// section was hidden. A false count, on the one surface whose whole
    /// thesis is honest reporting.
    ///
    /// The Mac has always drawn its take sections unconditionally
    /// (`BlockHistoryPane.swift:475`); this is the phone catching up.
    @Test func aFannedBlockShowsItsTakesInsteadOfClaimingItHasOne() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            // Fan it and commit NOTHING — her ordinary "let me try another
            // way of saying this" moment.
            try await session.runner.run { ops in
                _ = try ops.branchVariant(seed.blockID, from: seed.variantID)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            let rows = model.blockHistory.rows()
            #expect(!rows.contains(.quiet(BlockHistoryPath.nothingHere)),
                    "the sentence asserts ONE take; this block has two")
            #expect(sectionTitles(rows) == [BlockHistoryPath.savepointsSection],
                    "region 1 draws — the other three are genuinely empty")
            let takeHeaders = rows.filter {
                if case .takeHeader = $0 { return true }
                return false
            }
            #expect(takeHeaders.count == 2, "one header per live take, as on the Mac")
        }
    }

    /// **BOTH LONG EXPLAINERS SAY THEIR WHOLE SENTENCE** (M1), measured on
    /// the REAL mounted sheet at the real width, through the real delegate
    /// height and the real cell layout.
    ///
    /// What was lost was not decoration: the Savepoints explainer's dropped
    /// tail names the fourth region, and the Came-from explainer's dropped
    /// tail is the sentence explaining the **Bring back** button rendered
    /// inches away. The cap and the fixed 52pt row were JOINTLY wrong, so
    /// this holds both halves — the label is unbounded AND the row it is
    /// given is tall enough for it.
    ///
    /// The cell is deliberately configured as a `.takeHeader` FIRST: that
    /// row kind sets a one-line title and a right-aligned meta, so a cell
    /// arriving from the recycle pool proves the reset too.
    @Test func bothLongExplainersFitTheRowsTheSheetGivesThem() async throws {
        try await withEditorWorld { session, _ in
            // A merge, so the came-from region really renders.
            let post = try await session.runner.run { ops -> Container in
                let post = try ops.createPost(title: "merged", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "The first half.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "The second half.", at: .end)
                return post
            }
            let parents = try await session.database.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT block_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL ORDER BY position
                        """,
                    arguments: [post.id])
            }
            let mergedBlock = try await session.runner.run { ops -> String in
                try ops.merge(parents[0], parents[1]).block.id
            }

            let (model, surface) = await makeSurfaceEditor(session, postID: post.id)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 402, height: 800))
            let host = UIViewController()
            host.view.addSubview(surface)
            surface.frame = host.view.bounds
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            window.layoutIfNeeded()

            model.blockHistory.open(blockID: mergedBlock)
            await settle { !model.blockHistory.rows().isEmpty }
            let sheet = try #require(surface.textView.blockHistorySheetView)
            window.layoutIfNeeded()

            let table = sheet.tableForTesting
            let rows = sheet.renderedRows
            let headerIndices = rows.indices.filter {
                if case .sectionHeader = rows[$0] { return true }
                return false
            }
            #expect(headerIndices.count >= 2,
                    "savepoints AND came-from — the two long explainers")

            for index in headerIndices {
                guard case .sectionHeader(let title, _) = rows[index] else { continue }
                let height = sheet.tableView(
                    table, heightForRowAt: IndexPath(row: index, section: 0))
                let cell = MobileBlockHistoryCell(
                    style: .default, reuseIdentifier: MobileBlockHistoryCell.reuseID)
                // Out of the recycle pool wearing another row's caps.
                cell.configure(
                    .takeHeader(
                        variantID: "v", title: "take 1 of 2", focused: true,
                        savepoints: 3, expanded: false),
                    face: MobileEditorStyle.face) { _ in }
                cell.configure(rows[index], face: MobileEditorStyle.face) { _ in }
                cell.frame = CGRect(
                    x: 0, y: 0, width: table.bounds.width, height: height)
                cell.layoutIfNeeded()

                // The UNBOUNDED height, measured independently of the
                // label — `sizeThatFits` honours `numberOfLines`, so asking
                // the label how tall it wants to be answers with its own
                // cap and pins nothing. (That mistake was made here once
                // and the pin passed on the pre-fix code; this is the
                // corrected form.)
                let explainerText = cell.metaLabel.text ?? ""
                let needed = (explainerText as NSString).boundingRect(
                    with: CGSize(width: cell.metaLabel.bounds.width,
                                 height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: [.font: cell.metaLabel.font as Any],
                    context: nil).height
                #expect(cell.metaLabel.numberOfLines == 0,
                        "\(title): a section header's explainer is prose — never capped")
                #expect(
                    cell.metaLabel.bounds.height >= needed - 0.5,
                    "\(title): drawn in \(cell.metaLabel.bounds.height)pt, needs \(needed)pt — it stops mid-thought")
                #expect(
                    cell.metaLabel.frame.maxY <= cell.contentView.bounds.height + 0.5,
                    "\(title): the explainer runs past the bottom of its own row")
                #expect(
                    cell.titleLabel.frame.minY >= -0.5,
                    "\(title): the header's title is pushed off the top")
            }

            model.blockHistory.close()
        }
    }

    // MARK: The empty case

    /// An ordinary block has no past, and the face says exactly that rather
    /// than drawing four empty regions.
    @Test func anOrdinaryBlockHasNoPastAndTheCopySaysWhat() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.blockHistory.open(blockID: seed.blockID)
            await model.blockHistory.refresh()

            #expect(model.blockHistory.rows() == [.quiet(BlockHistoryPath.nothingHere)])
        }
    }

    // MARK: The mounted face

    /// **The real sheet, mounted over the real page**, showing all four
    /// regions — and lazy BY CONSTRUCTION: a table never builds the rows
    /// that are not near the viewport (P3's read-cheap tier; the hand-rolled
    /// band this replaces proved the same thing with more machinery).
    @Test func theMountedSheetDrawsTheFourRegionsAndStaysLazy() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedPost(session)
            try await session.runner.run { ops in
                // A deep run, an archived take, a deleted take.
                for _ in 0..<40 { _ = try ops.commit(seed.variantID, kind: .manual) }
                let archived = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.archiveVariant(archived.id)
                let deleted = try ops.branchVariant(seed.blockID, from: seed.variantID)
                try ops.deleteVariant(deleted.id)
            }
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            // **IN A REAL KEY WINDOW.** A `UITableView` asked to lay out
            // outside the view hierarchy warns and reads unreliably — and a
            // lazy claim measured on an unhosted table is exactly the
            // vacuous pin §15's trap (b) is about. UIKit says so out loud;
            // this listens.
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            let host = UIViewController()
            host.view.addSubview(surface)
            surface.frame = host.view.bounds
            window.rootViewController = host
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            window.layoutIfNeeded()

            model.blockHistory.open(blockID: seed.blockID)
            await settle { model.blockHistory.rows().count > 40 }
            let sheet = try #require(surface.textView.blockHistorySheetView)
            window.layoutIfNeeded()
            #expect(!sheet.isHidden, "the sheet really mounted over the page")
            #expect(!surface.textView.isEditable,
                    "the page editor stands down while the face is up — one live editor, ever")

            let titles = sectionTitles(sheet.renderedRows)
            #expect(titles == [
                BlockHistoryPath.savepointsSection,
                BlockHistoryPath.archivedSection,
                BlockHistoryPath.deletedSection,
            ], "her regions, in her order — came-from is absent because this block has no origin")

            let table = sheet.tableForTesting
            window.layoutIfNeeded()
            #expect(table.window != nil, "the table is really in the hierarchy")
            #expect(table.numberOfRows(inSection: 0) == sheet.renderedRows.count,
                    "the table knows the WHOLE face — every row reachable")
            #expect(table.visibleCells.count < sheet.renderedRows.count,
                    "only the near-viewport band is BUILT")
            #expect(!table.visibleCells.isEmpty)

            // **NO PURGE DOOR, ON THE REAL DRAWN ROW.** The deleted take's
            // cell is configured and its buttons read: exactly one act, and
            // it is Put back. A stray Delete Now would have to appear here.
            let deletedRow = try #require(sheet.renderedRows.first {
                if case .deletedTake = $0 { return true }
                return false
            })
            let cell = MobileBlockHistoryCell(
                style: .default, reuseIdentifier: MobileBlockHistoryCell.reuseID)
            cell.configure(deletedRow, face: MobileEditorStyle.face) { _ in }
            let buttons = cell.contentView.subviews.compactMap { $0 as? UIButton }
                .filter { !$0.isHidden }
            #expect(buttons.count == 1, "one act on a deleted take's row")
            #expect(buttons.first?.accessibilityIdentifier == "blockHistory.putBack")
            #expect(buttons.first?.accessibilityLabel
                    == "\(BlockPastCopy.putBackVerb) this take")

            model.blockHistory.close()
            #expect(sheet.isHidden)
            #expect(surface.textView.isEditable, "and the page comes back")
        }
    }

    // MARK: Copy

    /// The copy statics — the promises the face and the ⋯ make, pinned; no
    /// platform name anywhere in the family, and the door NAMES THE BLOCK
    /// (her F2 report, one noun over).
    @Test func theHistoryCopyIsPinnedAndPlatformFree() async throws {
        #expect(MobileBlockHistoryController.committedStatus
                == "Committed — a savepoint of this take is kept.")
        #expect(MobileBlockHistoryController.restoredStatus
                == BlockHistoryCopy.restoredSavepoint)
        #expect(MobileBlockHistoryController.predatesSplitRowFlag == "predates a split")
        #expect(MobileBlockMenuController.commitTitle == "Commit Take")

        // **SANCTIONED FLIP (batch 9) — HER MOVE, held from both sides.**
        // This assertion used to read `MobileBlockMenuController.historyTitle
        // == "Block History…"` plus `rowTitles.contains(…)` plus her G2
        // adjacency (`history == commit + 1`). Her letter moved the door:
        // *"take history should move into the three ... menu on each take
        // rather than the main three dot menu."*
        //
        // So the pin holds the NEW fact and the precondition that still
        // constrains it: the word is the SHARED face's own name — not a
        // second literal minted on the way over — and it is nowhere in the
        // block ⋯'s vocabulary any more.
        #expect(MobileTakesBrowserController.historyTitle == "Block History…")
        #expect(MobileTakesBrowserController.historyTitle
                == "\(BlockHistoryPath.name)…",
                "the row's word is composed from the shared name, never rewritten")
        #expect(!MobileBlockMenuController.rowTitles.contains { $0.contains("History") },
                "the block ⋯ carries no history row: \(MobileBlockMenuController.rowTitles)")
        // Commit STAYS on the block ⋯ (she moved the listing, not the act),
        // so her G2 commit/history adjacency is deliberately over — recorded
        // here rather than silently dropped with the assertion.
        #expect(MobileBlockMenuController.rowTitles
                .contains(MobileBlockMenuController.commitTitle))

        for copy in [
            MobileBlockHistoryController.committedStatus,
            MobileBlockHistoryController.restoredStatus,
            MobileBlockHistoryController.predatesSplitWarning,
            MobileBlockHistoryController.deletedExplainer,
            MobileBlockHistoryController.noSavepoints,
            BlockHistoryPath.explainer,
            BlockHistoryPath.nothingHere,
        ] {
            #expect(!copy.contains("Mac"))
            #expect(!copy.contains("⌘"), "no Mac chords in the phone's words: \(copy)")
        }
    }

    /// **The words are SHARED, not copied** (MobileSoul §3): the phone reads
    /// the same vocabulary the Mac's pane does, so the two faces cannot tell
    /// different stories about one block.
    @Test func theBlockHistoryVocabularyIsShared() async throws {
        #expect(BlockHistoryPath.name == "Block History")
        #expect(BlockHistoryPath.savepointsSection == "Savepoints")
        #expect(BlockHistoryPath.archivedSection == "Archived takes")
        #expect(BlockHistoryPath.deletedSection == "Deleted takes")
        #expect(BlockHistoryPath.cameFromSection == "Came from")
        #expect(BlockHistoryPath.bringBackVerb == "Bring back")
        #expect(BlockPastCopy.putBackVerb == RecoveryCopy.putBackVerb)
        // The lead half of the deleted explainer is one sentence with two
        // endings — the Mac names its tray, the phone names nothing yet.
        #expect(BlockHistoryCopy.deletedRegionExplainer(purgeRoad: "open the tray")
                == "On the \(TrashWindow.days)-day clock. Put one back here; to end a "
                + "take's remaining days early, open the tray.")
    }

    /// **THE DELETED REGION PROMISES NO PURGE ROAD THE APP DOES NOT HAVE**
    /// — §70's handed-forward hook, re-examined at batch 6c and answered
    /// with the fact that decides it.
    ///
    /// 6c gave the phone a **Trash room** with both purge doors in it, which
    /// looks like the second half of this sentence arriving. It is not:
    /// **this region lists deleted TAKES, and takes do not row in the global
    /// Trash** — `TrashScope.listedKinds` excludes `.take` by her D1 ruling
    /// (*a deleted take on a living block is not a note leaving the
    /// library*), and `TrashScope.kinds(filter:)` cannot widen past it. So
    /// naming the Trash room here would point her at a room where the take
    /// she is reading about does not appear: a door that cannot act (P-2)
    /// wearing a true sentence's clothes.
    ///
    /// The road that WILL make it true is the per-note tray's Leaving
    /// section (batch 6b), where a deleted take carries Put back and Delete
    /// Now with confirm-every-time (§69.3). **This pin holds the
    /// precondition**, so the flip is one argument and the reason is not
    /// re-derived: if a later batch makes takes reachable from a purge road,
    /// the first two expectations here change with it.
    /// **THE FLIP, AND ITS PRECONDITION, HELD BOTH WAYS** (batch 6b's
    /// deliverable 4 — 6c declined this flip on a traced fact and left this
    /// pin holding the precondition; the tray's Leaving section is the road
    /// that makes it true, and it exists now).
    ///
    /// It was `theDeletedRegionPromisesNoPurgeRoadTheAppDoesNotHave`. The two
    /// halves it holds:
    ///
    /// - the sentence NAMES a road that really carries a take — the tray's
    ///   Leaving section, where a deleted take wears Put back and Delete Now
    ///   — and it names it through the door's own composed phrase, so a
    ///   re-word of the chip or the segment cannot leave this sentence
    ///   pointing at a door that no longer exists;
    /// - it still never names the GLOBAL Trash, and the global Trash still
    ///   does not list takes (her D1 ruling). That was the whole of 6c's
    ///   trace and it has not changed — what changed is that the phone grew
    ///   the OTHER road.
    @Test func theDeletedRegionNamesTheTrayAsItsPurgeRoad() async throws {
        // The precondition 6c pinned, still true — takes are NOT in the
        // global Trash, so the sentence must never send her there.
        #expect(!TrashScope.listedKinds.contains(.take))
        #expect(!MobileTrashView.filterKinds.contains(.take))

        let phone = MobileBlockHistoryController.deletedExplainer
        #expect(phone == BlockHistoryCopy.deletedRegionExplainer(
            purgeRoad: MobileNoteTrayModel.purgeRoadPhrase))
        #expect(phone.contains(MobileNoteTrayModel.purgeRoadPhrase),
                "it names the road that really carries the take: \(phone)")
        #expect(phone.contains(MobileBlocksSegment.leaving.word))
        #expect(!phone.contains(RecoveryCopy.trashSection),
                "it must not name a room the take is not in")
        // And the road it names is a REAL door: the tray's Leaving section
        // renders Delete Now on a take row (the pin that drives it is
        // `MobileNoteTrayTests.aTakeCanBeEndedEarlyHereAndItAsksEveryTime`).
        #expect(MobileBlocksSegment.allCases.contains(.leaving))
    }
}
