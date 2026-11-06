//
//  BlockHistoryClarityTests.swift
//  VariorumTests
//
//  VX-431 (the VX-440 run, batch 2) — THE BLOCK HISTORY CLARITY PASS. Her
//  report on the ticket (2026-10-18 + 2026-10-27): the screen is cluttered and
//  wordy "in the same way that the books and gathering menus are"; a long
//  commit can't be read in full; restoring a long one, "it's unclear which part
//  came back (briefly highlight at least where it starts)"; and offer "bring
//  back as a take" so a commit can be read in the regular editor. The sitting's
//  R-440-3: a commit row expands in place, and a "read in full" door opens a
//  sheet with the whole text and Restore + Bring back as a take at its foot.
//
//  Her ruled structure STAYS and is not re-pinned here (BlockHistoryPaneTests
//  holds it): every take sectioned with the focused one open, the four regions,
//  Restore per row, no purge door, the history door where it is.
//
//  **VX-827 U3b — the panel retired whole** (`notes/plans/fixes/
//  vx-827-lineage.md`, U3b RECORD). Each pin below is re-pointed at the Commits
//  face (the same acts, words and refusals) or retired by name where it held
//  the panel's own face (its region headers, its read-in-full sheet).
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
@Suite("Block History — the clarity pass (VX-431)", .serialized)
struct BlockHistoryClarityTests {
    // MARK: - Harness

    /// Every value of type `T` reachable in `subject`'s stored structure, not
    /// descending into `VoiceTokens` (`CommitsPageLedgerTests`' walk).
    static func values<T>(_ type: T.Type, in subject: Any, depth: Int = 0) -> [T] {
        guard depth < 80 else { return [] }
        if subject is VoiceTokens { return [] }
        var found: [T] = []
        if let hit = subject as? T { found.append(hit) }
        for child in Mirror(reflecting: subject).children {
            found += values(type, in: child.value, depth: depth + 1)
        }
        return found
    }

    func withNote(
        _ texts: [String],
        _ body: @escaping @MainActor (AppSession, String, [String]) async throws -> Void
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 431))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the block's time")
            var blocks: [String] = []
            for text in texts {
                blocks.append(try session.operations.newBlock(in: post.id, text: text).block.id)
            }
            // `CurrentBlockMemory` persists per note into the standard
            // defaults and every world mints the same post id — enter and
            // leave clean (`BlockHistoryPaneTests.withNote`'s reason).
            session.commandRouter.forgetCurrentBlock(for: post.id)
            defer { session.commandRouter.forgetCurrentBlock(for: post.id) }
            try await body(session, post.id, blocks)
        }
    }

    /// The Commits face over a block, and its own read (VX-827 U3b).
    func face(_ session: AppSession, _ postID: String, _ blockID: String, focused: String?) -> CommitsFaceModel {
        CommitsFaceModel(session: session, request: BlockHistoryRequest(
            postID: postID, blockID: blockID, focusedVariantID: focused))
    }

    func faceRead(_ session: AppSession, _ blockID: String) async throws -> CommitsFaceModel.Read {
        let now = session.now
        return try await session.database.read { db in
            try CommitsFaceModel.read(db, blockID: blockID, now: now)
        }
    }

    func history(_ session: AppSession, _ blockID: String) async throws -> Queries.BlockHistory {
        let now = session.now
        return try await session.database.read { db in
            try Queries.blockHistory(db, blockID: blockID, now: now)
        }
    }

    // MARK: - Item 3: explainers behind (i), headers with counts

    // **RETIRED at VX-827 U3b — A JUSTIFIED EDIT:** `theRegionHeadersCarry
    // CountsAndOneLineEachWithTheWholeBehindAnI` pinned the PANEL's four region
    // headers (counts, one-line meanings, the (i)). The regions retired with
    // the panel; the Commits face carries the counts where they now live (the
    // take dropdown's "N takes ▾" and each take's commit count —
    // `CommitsFaceModelTests.theDropdownGroupsArchivedTakesAndFiltersTheRail`).

    // MARK: - Item 2: read in full (R-440-3)

    /// **"Read in full" opens the moment WHOLE** — every paragraph, past
    /// anything the open row's capped preview can show — in a read-cheap
    /// sheet titled by the moment's name, with Restore and Bring back as a
    /// take at its foot. Nothing in it is an editor (P3).
    ///
    /// **VX-827 U3b — A JUSTIFIED EDIT:** the sheet retired with the panel;
    /// her R-440-3 need ("a long commit can't be read in full") is the
    /// Commits face's reading pane now — the selected moment WHOLE, with
    /// Restore and Bring back as a take at its foot. Driven through the face's
    /// model: the claims are the same (the whole moment, its name, the two
    /// acts); the pane is a `Text` (P3 — `CommitsFaceView`'s own note).
    @Test func readInFullShowsTheWholeMomentWithItsTwoFootDoors() async throws {
        try await withNote(["Short."]) { session, postID, blocks in
            let chosen = try #require(try await session.database.read {
                try Queries.renderPost($0, containerID: postID)
            }.first?.variantID)
            let long = (1...12).map {
                "Paragraph \($0) of a long moment, long enough that no row could show it all."
            }.joined(separator: "\n")
            try session.operations.autosave(chosen, text: long, charDelta: 900)
            let commit = try session.operations.commit(chosen, message: "the long one")
            #expect(long.count > CommitRowFace.restingCap, "fixture: past any one-line preview")

            let model = face(session, postID, blocks[0], focused: chosen)
            model.adopt(try await faceRead(session, blocks[0]))
            model.select(.commit(commitID: commit.id))
            #expect(model.text(of: model.selection) == long, "the WHOLE moment")
            #expect(model.headline(model.selection) == "the long one", "headed by its name")
            #expect(model.paneActs.contains(.restore) && model.paneActs.contains(.bringBack),
                    "Restore and Bring back as a take at its foot")
        }
    }

    // **RETIRED at VX-827 U3b — A JUSTIFIED EDIT:** `anUnnamedMomentIsTitled
    // ByWhen` pinned the read-in-full SHEET's title ("Commit · ‹when›"); the
    // sheet retired with the panel. The Commits face heads an unnamed moment
    // with its first words (VX-674's rule, `CommitRowFace.restingPreview`) and
    // says when on the line beneath.

    // MARK: - Item 5: bring back as a take (P-440-3 / P-440-4)

    /// **The door lands the take and its receipt names the act** — the take
    /// at the fan's end, labelled with the moment's name (P-440-3), the
    /// moment untouched.
    @Test func bringBackAsATakeLandsTheTakeAndSaysSo() async throws {
        try await withNote(["The words as they were."]) { session, postID, blocks in
            let ops = session.operations
            let chosen = try #require(try await session.database.read {
                try Queries.renderPost($0, containerID: postID)
            }.first?.variantID)
            let commit = try ops.commit(chosen, message: "before the rewrite")
            try ops.autosave(chosen, text: "The words as they are now.", charDelta: 8)

            // VX-827 U3b — A JUSTIFIED EDIT: the Commits face's act, the same
            // operation and receipt.
            let model = face(session, postID, blocks[0], focused: chosen)
            model.adopt(try await faceRead(session, blocks[0]))
            model.select(.commit(commitID: commit.id))
            await model.bringBackSelected()
            #expect(model.status?.isRefusal == false)
            #expect(model.status?.text == BlockHistoryPath.broughtBackAsTake(label: "before the rewrite"))

            let after = try await history(session, blocks[0])
            let brought = try #require(after.activeTakes.last)
            #expect(after.activeTakes.count == 2)
            #expect(brought.workingText == "The words as they were.")
            #expect(brought.label == "before the rewrite")
            #expect(brought.parentVariantId == chosen)
        }
    }

    /// Under a seal the door ACTS and SPEAKS — the pane's uniform grammar
    /// (Restore's, the rename door's) — in the tray family's standing words.
    @Test func bringBackUnderASealRefusesInTheStandingWords() async throws {
        try await withNote(["Sealed words."]) { session, postID, blocks in
            let ops = session.operations
            let chosen = try #require(try await session.database.read {
                try Queries.renderPost($0, containerID: postID)
            }.first?.variantID)
            let commit = try ops.commit(chosen)
            try ops.lockPost(postID)

            // VX-827 U3b — A JUSTIFIED EDIT: the Commits face's act.
            let model = face(session, postID, blocks[0], focused: chosen)
            model.adopt(try await faceRead(session, blocks[0]))
            model.select(.commit(commitID: commit.id))
            await model.bringBackSelected()
            #expect(model.status?.isRefusal == true)
            #expect(model.status?.text
                == TrayRefusalCopy.message(for: OperationError.lockedPost(id: postID)))
            #expect(try await history(session, blocks[0]).activeTakes.count == 1, "nothing minted")
        }
    }

    // **RETIRED at VX-827 U3b — A JUSTIFIED EDIT:** `anEmptyRegionDrawsNo
    // Header` pinned the PANEL's region headers; the regions retired with it.
}
