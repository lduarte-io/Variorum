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

    // MARK: - Precision 6 — the quiet-run line, in the voice (RED ON OLD)

    /// **RED ON OLD:** the line drew in `.font(.caption)` with
    /// `.foregroundStyle(.secondary)` — a system sans line between mono rows
    /// in the Terminal voice (the before-capture `crowded-terminal-light`).
    @Test func theQuietRunLineSpeaksInTheVoice() {
        for tokens in [VoiceTokens.studyLight, .terminalLight, .studyDark, .terminalDark] {
            let row = QuietRunRow(count: 3, expanded: false, tokens: tokens, onToggle: {})
            let fonts = Self.values(Font.self, in: row.body).map(Self.signature)
            let inks = Self.values(Color.self, in: row.body).map(Self.signature)
            #expect(!fonts.contains { $0.contains("TextStyle.caption") },
                    "no system caption type on the run line")
            #expect(fonts.contains(Self.signature(tokens.small)),
                    "the run line wears the voice's small type")
            #expect(inks.contains(Self.signature(tokens.muted)),
                    "…in the voice's muted ink (inks: \(inks))")
        }
    }

    // MARK: - Precision 3 — no bezels anywhere in the pane (RED ON OLD)

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// **RED ON OLD:** every act in the pane — Name/Rename, Restore,
    /// Unarchive, Put back, Bring back, Open this note's tray — was a stock
    /// `.controlSize(.small)` bezel, against `VoiceControls.swift`'s own
    /// rule ("chrome is quiet text, never bezels"). The pane's Close stays
    /// the inspector family's stock button (TrayPanel's twin) and is not a
    /// row act.
    @Test func theCommitsPageDrawsNoBezels() throws {
        let source = try String(
            contentsOf: Self.appRoot.appendingPathComponent(
                "Variorum/Features/Tray/BlockHistoryPane.swift"),
            encoding: .utf8)
        let bezels = source.components(separatedBy: ".controlSize(").count - 1
        #expect(bezels == 0, "the pane's acts are voiced words, never bezels (\(bezels) left)")
    }

    // MARK: - Precision 5 — the defining sentence survives; the blurb goes

    /// The Commits section's meaning line DEFINES a commit, and says "saved
    /// moments" by 13s-b's P-U4-1 — it survives VERBATIM (the literal is
    /// spelled here on purpose: a rewording must break this pin). The
    /// pane-level blurb is dropped on this pane (P-VX144-2) — **RED ON OLD**
    /// for that half.
    @Test func theDefiningSentenceSurvivesAndThePaneBlurbIsGone() async throws {
        #expect(BlockHistoryPath.savepointsExplainer
            == "Each take's saved moments \u{2014} Restore loads one back into its buffer.")
        try await withWorld { session, seeded in
            let pane = BlockHistoryPane(
                session: session,
                request: BlockHistoryRequest(postID: seeded.postID, blockID: seeded.blockID))
            await SurfaceComposition.host(pane, size: NSSize(width: 420, height: 700))
            let shown = SurfaceComposition.text(of: pane.body)
            #expect(SurfaceComposition.carries(BlockHistoryPath.savepointsSection, in: shown))
            #expect(SurfaceComposition.carries(BlockHistoryPath.savepointsExplainer, in: shown),
                    "the commit-defining sentence is on the page")
            // The fallback voice (no store here) is Terminal, which LOWERCASES
            // chrome — so the blurb is looked for case-blind, by its opening.
            #expect(shown.lowercased().contains("everything this block has been") == false,
                    "the pane-level blurb is gone (P-VX144-2)")
            // (No apostrophe in the control: `dump` escapes it as `\'`.)
            #expect(shown.lowercased().contains("restore loads one back into its buffer"),
                    "control: the case-blind search does see the pane's text")
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
