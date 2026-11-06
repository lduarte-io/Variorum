//
//  CommitsPageLedgerTests.swift
//  VariorumTests
//
//  VX-144 (the VX-143 run, batch 2) — her report: *"the commits page is very
//  messy with crowded & cluttered UI … i want that UI improved + cleaned up."*
//  The architect ruled DIRECTION A, the quiet ledger, with eight precisions
//  (the run record's "ARCHITECT RULING — VX-144 direction"). These pins hold
//  the ruled shape of the Block History pane's Commits region:
//
//  · the quiet-run line ("N quiet commits · show") speaks in the VOICE —
//    `tokens.small` + `tokens.muted`, never the system caption/secondary
//    (precision 6; RED ON OLD);
//  · the pane draws no stock bezels — every row act is a voiced word
//    (precision 3; RED ON OLD);
//  · the section's commit-DEFINING sentence survives verbatim and the
//    pane-level blurb is gone (precision 5, P-VX144-2; the blurb half RED ON
//    OLD);
//  · the row's face — the name leads, one quiet line of preview, a short
//    stamp with no "saved by hand" and no current year, "quiet" and
//    "predates a split" kept (precisions 1–2);
//  · the row's height at the column's default width, both voices
//    (precision 1's "compact").
//
//  **VX-827 U3b — the panel retired whole** (`notes/plans/fixes/
//  vx-827-lineage.md`, U3b RECORD), and the ledger's pins with it, each named
//  below: what VX-144 ruled for the Commits region either holds on the
//  surface that succeeds it (no bezels and no system caption type anywhere in
//  the History feature — re-pointed as one source pin; the moment's details
//  line says no "saved by hand" and keeps "quiet" — re-pointed onto the
//  Commits face's own meta line) or retired with the row and region it
//  shaped.
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
@Suite("The commits page as a quiet ledger (VX-144)", .serialized)
struct CommitsPageLedgerTests {
    // MARK: - A tiny reflection walk

    /// Every value of type `T` reachable in `subject`'s stored structure —
    /// NOT descending into `VoiceTokens`, whose whole palette and type ramp
    /// ride every voiced control and would make any token "present".
    private static func values<T>(_ type: T.Type, in subject: Any, depth: Int = 0) -> [T] {
        guard depth < 80 else { return [] }
        if subject is VoiceTokens { return [] }
        var found: [T] = []
        if let hit = subject as? T { found.append(hit) }
        for child in Mirror(reflecting: subject).children {
            found += values(type, in: child.value, depth: depth + 1)
        }
        return found
    }

    /// A font's identity as SwiftUI reflects it (`Font`'s own `==` compares
    /// its provider BOXES, so two `.caption`s built apart are not equal —
    /// measured on this pin's first run).
    private static func signature(_ value: Any) -> String {
        var out = ""
        dump(value, to: &out)
        return out
    }

    // **RETIRED at VX-827 U3b — A JUSTIFIED EDIT, four pins:**
    // · `theQuietRunLineSpeaksInTheVoice` (the panel's `QuietRunRow`, retired
    //   with it — the Commits face draws its quiet runs in the voice's small
    //   type and muted ink; the source pin below keeps the class out of the
    //   whole History feature);
    // · `theDefiningSentenceSurvivesAndThePaneBlurbIsGone` (the Commits
    //   REGION's meaning line; the face carries no region lines — THE DESIGN
    //   MEMO's composition, her composite — and "saved moment" defines commit
    //   in its Restore and Bring back hover words; flagged for her eye,
    //   P-U3b-9);
    // · `theOpenPreviewKeepsParagraphsCapsAndAddsNoEllipsisOfItsOwn` (the open
    //   ROW's capped preview — the face's reading pane is the whole moment);
    // · `theRowIsCompactAndItsActsAreWords` and `theRestingLineSaysWhenThe
    //   NameAndTheQuietGlyphOnly` (the panel ROW's anatomy and its ◦ glyph —
    //   the face's rail line is one line, its quiet mark the rail's hollow
    //   dot; a named moment rests on its name alone —
    //   `CommitRestingPreviewTests.aNamedCommitKeepsItsNameAlone`).

    // MARK: - Precisions 3 + 6 — no bezels, no system caption (re-pointed)

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// **The History feature draws its chrome in the VOICE** — no stock
    /// `.controlSize(` bezel and no system caption type or secondary ink,
    /// in any file of the surface that succeeds the panel (VX-144 precisions
    /// 3 and 6, re-pointed at VX-827 U3b from the retired panel's file).
    @Test func theHistoryFeatureDrawsNoBezelsAndNoSystemCaption() throws {
        let folder = Self.appRoot.appendingPathComponent("Variorum/Features/History")
        let files = try FileManager.default.contentsOfDirectory(atPath: folder.path)
            .filter { $0.hasSuffix(".swift") }
        #expect(files.count >= 5, "the surface's files are read: \(files)")
        for file in files {
            let source = try String(contentsOf: folder.appendingPathComponent(file), encoding: .utf8)
            for banned in [".controlSize(", ".font(.caption", ".foregroundStyle(.secondary"] {
                #expect(!source.contains(banned), "\(file) carries \(banned)")
            }
        }
    }

    // MARK: - Precisions 1–2 — what a moment's line SAYS (re-pointed)

    /// "saved by hand" goes (deliberate is the default and earns no words);
    /// "quiet" stays on automatic commits — on the Commits face's own meta
    /// line under the moment (VX-827 U3b — A JUSTIFIED EDIT: the panel row's
    /// `CommitRowFace.details` retired with it; the face says when in its
    /// relative words, `TimeStampFace`, so the year rule is the stamp face's).
    @Test func theDetailsLineSaysOnlyWhatTellsCommitsApart() async throws {
        try await withWorld { session, seeded in
            let model = CommitsFaceModel(session: session, request: BlockHistoryRequest(
                postID: seeded.postID, blockID: seeded.blockID, focusedVariantID: seeded.takeID))
            model.adopt(try await session.database.read { [blockID = seeded.blockID] db in
                try CommitsFaceModel.read(db, blockID: blockID, now: Date(timeIntervalSince1970: 1_791_331_200))
            })
            let moments = model.history.savepoints[seeded.takeID] ?? []
            let deliberate = try #require(moments.first { $0.kind == .manual })
            let quiet = try #require(moments.first { $0.kind == .auto })
            let deliberateMeta = model.meta(.commit(commitID: deliberate.id))
            #expect(!deliberateMeta.joined().contains("saved by hand"))
            #expect(!deliberateMeta.contains(CommitRowFace.quietMark))
            #expect(model.meta(.commit(commitID: quiet.id)).contains(CommitRowFace.quietMark),
                    "an automatic commit keeps its word")
            // The phone's face is untouched (precision 7): it still says it.
            let commit = CommitPoint(
                id: "c", variantId: "v", text: "x", kind: .manual, createdAt: Date())
            #expect(SavepointRowFace.details(commit, predatesSplit: false).contains("saved by hand"))
        }
    }

    // MARK: - Harness

    private struct Seeded {
        let postID: String
        let blockID: String
        let takeID: String
    }

    private func withWorld(
        _ body: (AppSession, Seeded) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_791_331_200))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 144))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let post = try ops.createPost(title: "the ledger")
            let minted = try ops.newBlock(in: post.id, text: "The kettle again.")
            _ = try ops.commit(minted.variant.id, kind: .manual, message: "first draft")
            _ = try ops.commit(minted.variant.id, kind: .auto)
            try await body(
                session,
                Seeded(postID: post.id, blockID: minted.block.id, takeID: minted.variant.id))
        }
    }
}
