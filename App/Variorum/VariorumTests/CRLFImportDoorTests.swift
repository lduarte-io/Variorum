//
//  CRLFImportDoorTests.swift
//  VariorumTests
//
//  18o U2 — 17e P23 at the Mac's DOORS. The rule is core's
//  (`SegmentationRules.bulkSegments` reads `"\r\n"` and a bare `"\r"` as
//  `"\n"` at its entry — `SegmentationLineEndingTests` pins it in every arm);
//  these pin that every Mac door that lands bulk text actually rides it:
//
//    · THE FINDING'S OWN ROAD — a Windows-authored `.md` dropped on the
//      library: `ImportModel.readFiles` reads the bytes as-is (no line-ending
//      normalisation) and hands them to `importPost`;
//    · the two capture doors that mint through `importPost` — the quick-note
//      pad (`QuickNoteMint.file`) and the shelf's quick-entry bar
//      (`QuickEntryModel.submit`);
//    · the editor's OPEN-TAIL PASTE — `EditorTextView.paste` is
//      `pasteAsPlainText` (no normalisation), and a paste into the tail is
//      BULK ENTRY (`CrystallizationPlanner.Kind.bulk`, which runs
//      `bulkSegments`), AppSpec §7's own list.
//
//  **And what must NOT move (the GUARDS):** the editor's TYPED road. The
//  type-time plan (`crystallizedBoundary`) is untouched, and the idle mint's
//  `bulkSegments` over TYPED text can never see a CR — the keyboard types
//  `"\n"` for Return and U+2028 for ⌃⏎/⌥⏎ — so a typed Control-Return stays
//  CONTENT at both (the block-boundary family's answer, `NewlineSplitting`'s
//  doc). An `isNewline` segmenter would have red these.
//
//  *Red on the old code:* every pin marked RED-ON-OLD. Verified by reverting
//  `SegmentationRules.swift` (the U2 record carries the counts).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("18o U2 — P23: a CRLF text at the Mac's bulk doors")
struct CRLFImportDoorTests {
    private func withWorld<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func storedTexts(_ db: AppDatabase, _ postID: String) async throws -> [String] {
        try await db.read { db in
            try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" }
        }
    }

    /// The Windows document every pin files: three paragraphs, CRLF line
    /// endings, one blank line between the first two.
    private static let windowsText = "Para one.\r\n\r\nPara two.\r\nPara three."
    private static let segmented = ["Para one.\n", "Para two.", "Para three."]

    // MARK: - The finding's own road

    /// RED-ON-OLD — a CRLF `.md` dropped on the library becomes a note of
    /// three blocks, not one.
    @Test func aWindowsFileDroppedOnTheLibraryImportsOneBlockPerParagraph() async throws {
        try await withWorld { session, db in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-18o-u2-\(UUID().uuidString)-Windows.md")
            try Data(Self.windowsText.utf8).write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }
            #expect(try Data(contentsOf: url).contains(13), "the fixture really carries CR bytes")

            let importer = ImportModel(session: session)
            await importer.importFiles([url], into: .library)
            #expect(importer.lastError == nil)
            let posts = try await db.read { try Queries.library($0) }
            #expect(posts.count == 1)
            let postID = try #require(posts.first).postID
            #expect(try await storedTexts(db, postID) == Self.segmented)
        }
    }

    // MARK: - The two capture doors

    /// RED-ON-OLD — the quick-note pad files a CRLF text (a paste into the
    /// pad keeps the clipboard's line endings) one block per paragraph.
    @Test func theQuickNotePadFilesACRLFTextOneBlockPerParagraph() async throws {
        try await withWorld { session, db in
            let noteID = try #require(
                await QuickNoteMint.file(Self.windowsText, session: session).postID)
            #expect(try await storedTexts(db, noteID) == Self.segmented)
        }
    }

    /// RED-ON-OLD — the shelf's quick-entry bar, the same op.
    @Test func theShelfQuickEntryBarFilesACRLFTextOneBlockPerParagraph() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = Self.windowsText
            let noteID = try #require(await box.submit())
            #expect(try await storedTexts(db, noteID) == Self.segmented)
        }
    }

    // MARK: - The editor's open tail: the paste is bulk entry, typing is not

    /// RED-ON-OLD — a CRLF paste into the open tail plans one mint per
    /// paragraph (and closes the tail), exactly as its LF twin does.
    @Test func aCRLFPasteIntoTheOpenTailSegmentsLikeItsLFTwin() {
        let plan = CrystallizationPlanner.plan(.bulk(.paragraph), tail: "One.\r\n\r\nTwo.")
        #expect(plan?.mints == ["One.\n", "Two."])
        #expect(plan?.remainingTail == nil)
        #expect(plan?.mints == CrystallizationPlanner.plan(.bulk(.paragraph), tail: "One.\n\nTwo.")?.mints)
        // A one-block post's paste stays whole, its line endings read as LF.
        #expect(CrystallizationPlanner.plan(.bulk(.oneBlock), tail: "One.\r\n\r\nTwo.")?.mints
                == ["One.\n\nTwo."])
    }

    /// GUARD (green on both sides) — the TYPED road is untouched: a typed
    /// Control-Return (U+2028) is content at type-time AND at the idle
    /// durability mint (the one editor plan that runs `bulkSegments` over
    /// typed text), and the ordinary typed tail plans exactly as before.
    @Test func theTypedRoadKeepsAControlReturnAsContent() {
        let typing = CrystallizationPlanner.plan(.typing, tail: "a\u{2028}b\nc")
        #expect(typing?.mints == ["a\u{2028}b"])
        #expect(typing?.remainingTail == "c")
        let idle = CrystallizationPlanner.plan(.idle(.paragraph), tail: "a\u{2028}b")
        #expect(idle?.mints == ["a\u{2028}b"], "one block — a Control-Return is never a boundary")
        #expect(CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\n\nB going")?.mints
                == ["A\n", "B going"])
    }
}
