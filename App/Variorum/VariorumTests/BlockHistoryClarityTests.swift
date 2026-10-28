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

    func history(_ session: AppSession, _ blockID: String) async throws -> Queries.BlockHistory {
        let now = session.now
        return try await session.database.read { db in
            try Queries.blockHistory(db, blockID: blockID, now: now)
        }
    }

    // MARK: - Item 3: explainers behind (i), headers with counts

    /// **Each region's header carries its COUNT, and its meaning is ONE line
    /// with the whole sentence behind an (i)** — the `ExplainerLine` idiom
    /// (the MCP pane's precedent). The whole sentences are the shipped ones,
    /// still on the page verbatim (behind the (i)); empty regions stay hidden.
    @Test func theRegionHeadersCarryCountsAndOneLineEachWithTheWholeBehindAnI() async throws {
        try await withNote(["First half.", "Second half."]) { session, postID, blocks in
            let ops = session.operations
            let merge = try ops.merge(blocks[0], blocks[1])
            let mergedID = merge.block.id
            _ = try ops.commit(merge.variant.id)
            try ops.autosave(merge.variant.id, text: "First half, again.", charDelta: 7)
            _ = try ops.commit(merge.variant.id, kind: .auto)
            let shelved = try ops.branchVariant(mergedID, from: merge.variant.id)
            try ops.archiveVariant(shelved.id)
            let doomed = try ops.branchVariant(mergedID, from: merge.variant.id)
            try ops.deleteVariant(doomed.id)

            let model = BlockHistoryModel(session: session, postID: postID, blockID: mergedID)
            model.adopt(try await history(session, mergedID))
            #expect(model.commitCount == 2, "every moment of every live take, quiet ones included")

            let pane = BlockHistoryPane(
                session: session,
                request: BlockHistoryRequest(postID: postID, blockID: mergedID),
                model: model)
            await SurfaceComposition.host(pane, size: NSSize(width: 420, height: 700))

            let headers = Self.values(HistoryRegionHeader.self, in: pane.body)
            #expect(headers.map(\.title) == [
                BlockHistoryPath.savepointsSection, BlockHistoryPath.archivedSection,
                BlockHistoryPath.deletedSection, BlockHistoryPath.cameFromSection,
            ], "the four regions, in her ruled order")
            #expect(headers.map(\.count) == [2, 1, 1, 2],
                    "commits · archived takes · deleted takes · the merge's two originals")
            let pairs: [(String, String)] = [
                (BlockHistoryPath.savepointsLine, BlockHistoryPath.savepointsExplainer),
                (BlockHistoryPath.archivedLine, BlockHistoryCopy.archivedExplainer),
                (BlockHistoryPath.deletedLine, BlockHistoryCopy.deletedExplainer),
                (BlockHistoryPath.cameFromLine, OriginPeekCopy.explainer),
            ]
            #expect(headers.map(\.line) == pairs.map(\.0))
            #expect(headers.map(\.detail) == pairs.map(\.1), "the whole sentences, verbatim")
            for (line, whole) in pairs {
                #expect(ExplainerLine.opens(line: line, detail: whole),
                        "a cut line carries the (i): \(line)")
            }
            // (A header's own body is where its line is built — a reflection
            // of the pane's body holds the header VALUES, not their bodies.)
            let lines = headers.flatMap { Self.values(ExplainerLine.self, in: $0.body) }
            #expect(lines.count == 4 && lines.allSatisfy { $0.tokens != nil },
                    "each line is an ExplainerLine in the pane's voice")
            #expect(lines.map(\.detail) == pairs.map(\.1))
            #expect(Self.values(CalmSectionHeader.self, in: pane.body).isEmpty,
                    "the wrapping meaning lines are gone from this pane")
        }
    }

    // MARK: - Item 2: read in full (R-440-3)

    /// **"Read in full" opens the moment WHOLE** — every paragraph, past
    /// anything the open row's capped preview can show — in a read-cheap
    /// sheet titled by the moment's name, with Restore and Bring back as a
    /// take at its foot. Nothing in it is an editor (P3).
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
            #expect(long.count > CommitRowFace.expandedCap, "fixture: past the open row's cap")

            let model = BlockHistoryModel(session: session, postID: postID, blockID: blocks[0])
            let history = try await history(session, blocks[0])
            model.adopt(history)
            let take = try #require(history.activeTakes.first)
            model.readInFull(commit, of: take, heading: "this take")
            let reading = try #require(model.reading, "the door names the moment")
            #expect(reading.commit.id == commit.id && reading.variantID == chosen)

            let sheet = CommitReadingSheet(
                reading: reading, tokens: .studyLight, now: session.now,
                predatesSplit: false, onRestore: { _ in }, onBringBack: {})
            var dumped = ""
            dump(sheet.body, to: &dumped, maxDepth: 160)
            #expect(dumped.contains("Paragraph 12 of a long moment"), "the WHOLE moment")
            #expect(BlockHistoryPath.readingTitle(commit, now: session.now) == "the long one",
                    "titled by its name")
            #expect(Self.values(VoicedButtonStyle.self, in: sheet.body).count == 2,
                    "Bring back as a take and Restore, voiced words at the foot")
            #expect(Self.values(TextField<Text>.self, in: sheet.body).isEmpty
                    && !dumped.contains("TextEditor"),
                    "a saved moment is read, never typed into (P3, I5)")
            await SurfaceComposition.host(sheet, size: NSSize(width: 560, height: 520))
        }
    }

    /// An unnamed moment's sheet is titled "Commit · ‹when›" (R-440-3).
    @Test func anUnnamedMomentIsTitledByWhen() {
        let now = Date(timeIntervalSince1970: 1_791_331_200)
        let commit = CommitPoint(
            id: "c", variantId: "v", text: "words", kind: .manual, createdAt: now)
        #expect(BlockHistoryPath.readingTitle(commit, now: now)
            == "Commit \u{B7} \(CommitRowFace.stamp(now, now: now))")
    }

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

            let model = BlockHistoryModel(session: session, postID: postID, blockID: blocks[0])
            await model.bringBackAsTake(commit)
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

            let model = BlockHistoryModel(session: session, postID: postID, blockID: blocks[0])
            await model.bringBackAsTake(commit)
            #expect(model.status?.isRefusal == true)
            #expect(model.status?.text
                == TrayRefusalCopy.message(for: OperationError.lockedPost(id: postID)))
            #expect(try await history(session, blocks[0]).activeTakes.count == 1, "nothing minted")
        }
    }

    /// Empty regions stay hidden, as before: a block with one take and one
    /// commit draws the Commits header alone.
    @Test func anEmptyRegionDrawsNoHeader() async throws {
        try await withNote(["An ordinary block."]) { session, postID, blocks in
            let chosen = try #require(try await session.database.read {
                try Queries.renderPost($0, containerID: postID)
            }.first?.variantID)
            _ = try session.operations.commit(chosen)
            let model = BlockHistoryModel(session: session, postID: postID, blockID: blocks[0])
            model.adopt(try await history(session, blocks[0]))
            let pane = BlockHistoryPane(
                session: session,
                request: BlockHistoryRequest(postID: postID, blockID: blocks[0]),
                model: model)
            let headers = Self.values(HistoryRegionHeader.self, in: pane.body)
            #expect(headers.map(\.title) == [BlockHistoryPath.savepointsSection])
            #expect(headers.first?.count == 1)
        }
    }
}
