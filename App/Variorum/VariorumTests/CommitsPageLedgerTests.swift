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

    // MARK: - Precisions 1–2 — what the row SAYS (the Mac-local face)

    private static let now = Self.date(2026, 10, 10, 9, 0)

    private static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
        Calendar.current.date(from: DateComponents(
            year: y, month: m, day: d, hour: h, minute: min))!
    }

    private static func commit(
        _ text: String = "The kettle again.", kind: CommitKind = .manual,
        message: String? = nil, at when: Date = date(2026, 10, 9, 22, 48)
    ) -> CommitPoint {
        CommitPoint(
            id: UUID().uuidString, variantId: "v1", text: text, kind: kind,
            message: message, createdAt: when)
    }

    /// "saved by hand" goes (deliberate is the default and earns no words);
    /// "quiet" stays on automatic commits; "predates a split" stays (it is
    /// Restore's warning); the year shows only when it is not this year.
    @Test func theDetailsLineSaysOnlyWhatTellsCommitsApart() {
        let deliberate = CommitRowFace.details(Self.commit(), predatesSplit: false, now: Self.now)
        #expect(deliberate.count == 1, "a deliberate commit's line is its stamp alone: \(deliberate)")
        #expect(!deliberate.joined().contains("saved by hand"))
        #expect(!deliberate.joined().contains("2026"), "no year in this year: \(deliberate)")
        #expect(deliberate[0].contains("Oct") && deliberate[0].contains("9"),
                "…but the month, the day and the time: \(deliberate)")

        let quiet = CommitRowFace.details(
            Self.commit(kind: .auto), predatesSplit: false, now: Self.now)
        #expect(quiet.last == "quiet", "an automatic commit keeps its word: \(quiet)")

        let old = CommitRowFace.details(
            Self.commit(), predatesSplit: true, now: Self.now)
        #expect(old.last == BlockHistoryCopy.predatesSplitMark, "Restore's warning stays: \(old)")

        let lastYear = CommitRowFace.details(
            Self.commit(at: Self.date(2025, 12, 30, 8, 5)), predatesSplit: false, now: Self.now)
        #expect(lastYear[0].contains("2025"), "another year names itself: \(lastYear)")
        // The phone's face is untouched (precision 7): it still says it.
        #expect(SavepointRowFace.details(Self.commit(), predatesSplit: false)
            .contains("saved by hand"))
    }

    /// ONE line of the first non-blank paragraph, and no ellipsis of the
    /// face's own — the "…had.…" artifact (a two-line cut at a newline, an
    /// ellipsis after the period) cannot be produced.
    @Test func thePreviewIsTheFirstParagraphAndNeverADotEllipsis() {
        let twoParagraphs = "The keeper climbed the stairs at dusk, counting them as he always had."
            + "\nBelow, the sea rearranged itself around the rocks, patient and loud."
        let preview = CommitRowFace.preview(twoParagraphs)
        #expect(preview == "The keeper climbed the stairs at dusk, counting them as he always had.")
        #expect(!preview.hasSuffix(".\u{2026}") && !preview.contains("\n"))
        #expect(CommitRowFace.preview("\n  \nSecond line leads.") == "Second line leads.")
        #expect(CommitRowFace.preview("") == BlockPastCopy.emptyTake)
        let long = CommitRowFace.preview(String(repeating: "word. ", count: 80))
        #expect(long.count <= CommitRowFace.previewCap && !long.hasSuffix("\u{2026}"))
    }

    // MARK: - Precisions 1 + 3 — the row's anatomy and height

    private static func rowHeight(
        _ commit: CommitPoint, tokens: VoiceTokens, width: CGFloat = 396
    ) -> CGFloat {
        let host = NSHostingController(rootView: CommitRowView(
            commit: commit, tokens: tokens, predatesSplit: false, now: Self.now,
            renameOpensField: true, renameAsk: .constant(nil),
            onName: {}, onRename: { _ in }, onRestore: {}))
        return host.sizeThatFits(in: NSSize(width: width, height: 10_000)).height
    }

    /// The two acts are quiet voiced WORDS, and the row is compact at the
    /// column's default width (420 − the pane's 24 pt of padding) in both
    /// voices: before the ledger a commit row measured ≈ 90 pt (the
    /// before-captures — seven commits in an 820-pt pane).
    @Test func theRowIsCompactAndItsActsAreWords() {
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            let named = Self.commit(
                "The keeper climbed the stairs at dusk, unhurried, a hand on the cold rail.",
                message: "before the AI edit")
            let row = CommitRowView(
                commit: named, tokens: tokens, predatesSplit: false, now: Self.now,
                renameOpensField: true, renameAsk: .constant(nil),
                onName: {}, onRename: { _ in }, onRestore: {})
            #expect(Self.values(VoicedButtonStyle.self, in: row.body).count == 2,
                    "Name/Rename and Restore are voiced words")
            let namedHeight = Self.rowHeight(named, tokens: tokens)
            let bare = Self.rowHeight(Self.commit(
                "The keeper climbed the stairs at dusk, unhurried, a hand on the cold rail."),
                tokens: tokens)
            print("[VX-144] row heights: named \(namedHeight) · bare \(bare)")
            // Measured on the Air at the build: 68 / 49 pt in BOTH voices; the
            // bounds leave 4 pt of OS line-height drift and nothing more.
            #expect(namedHeight <= 72, "a named commit is three short lines: \(namedHeight)")
            #expect(bare <= 52, "an unnamed commit is two: \(bare)")
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
