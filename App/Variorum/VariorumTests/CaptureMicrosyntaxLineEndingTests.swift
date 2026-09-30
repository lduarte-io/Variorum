//
//  CaptureMicrosyntaxLineEndingTests.swift
//  VariorumTests
//
//  18o U3 — ledger row 12b (adopted from 18o U2's NOTICED 1): the capture
//  microsyntax reads CRLF / CR line endings as the line breaks they are.
//
//  THE DEFECT (17e P23's class, at a sibling brain): `CaptureMicrosyntax.parse`
//  walked its lines on the literal `"\n"`, and `"\r\n"` is ONE Swift
//  `Character` that is not `Character("\n")` (a bare `"\r"` is not either). So
//  a capture pasted from a Windows or classic-Mac source was ONE "line" to the
//  parse, and the two rules that are about lines misread it:
//
//  · RULE 5 (a line that held nothing but tokens goes with it, its newline
//    included) never fired — the token line's breaks stayed, and downstream
//    `bulkSegments` (which reads CRLF since U2) stored the doubled break as an
//    invented BLANK PARAGRAPH (the 2026-07-12 spacing ruling keeps it).
//  · RULE 2 (a token lives on ONE line — an unclosed `{#` cannot swallow the
//    rest of the capture) did not hold: the scan for `}` crossed the CRLF, so
//    an unclosed `{#` took everything up to a later `}` as its TAG PATH — the
//    text vanished from the note, and when the token opened the capture the
//    door found nothing left to file and cleared the box: the capture LOST.
//
//  THE FIX: `parse` reads its input through `SegmentationRules.
//  normalizedLineEndings` at entry (U2's one reading of foreign line endings,
//  `PlainPaste` rule 1's two steps). The existing `CaptureMicrosyntaxTests`
//  and `CaptureMicrosyntaxDoorTests` ride UNMODIFIED — LF behaviour is
//  byte-identical (the 3C proof).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The brain

@Suite("The capture microsyntax reads CRLF and CR (18o U3 — row 12b)")
struct CaptureMicrosyntaxLineEndingTests {

    /// **RULE 5 — RED ON OLD.** A token-only line leaves WITH its line break
    /// when the break is CRLF or a bare CR, exactly as when it is LF.
    @Test func aTokenOnlyCRLFLineLeavesWithItsLineBreak() {
        // A title on its own first line (the existing LF pin's fixture, CRLF).
        let top = CaptureMicrosyntax.parse(
            "{t:\"Ocean dream\"}\r\nHad a weird dream about the ocean.\r\n\r\nIt was blue.")
        #expect(top.title == "Ocean dream")
        #expect(top.text == "Had a weird dream about the ocean.\n\nIt was blue.",
                "the token line and ITS break are gone; her own blank line stays")

        // A tag line between two paragraphs leaves them adjacent.
        for raw in ["Paragraph one.\r\n{#dream}\r\nParagraph two.",
                    "Paragraph one.\r{#dream}\rParagraph two."] {
            let middle = CaptureMicrosyntax.parse(raw)
            #expect(middle.tagPaths == ["dream"])
            #expect(middle.text == "Paragraph one.\nParagraph two.",
                    "no blank paragraph invented between them: \(raw.debugDescription)")
        }
    }

    /// **RULE 2 — RED ON OLD.** An unclosed opener never scans across a CRLF
    /// (or a bare CR): it stays her text, visibly, and swallows nothing.
    @Test func anUnclosedTokenNeverScansAcrossACRLF() {
        for raw in ["{#dream\r\nand more}", "{#dream\rand more}"] {
            let parsed = CaptureMicrosyntax.parse(raw)
            #expect(parsed.tagPaths.isEmpty, "nothing parsed: \(raw.debugDescription)")
            #expect(parsed.title == nil)
            #expect(parsed.text == "{#dream\nand more}",
                    "her text, intact but for the line ending it is read as")
        }
        // The title's shape keeps the same one-line promise.
        let title = CaptureMicrosyntax.parse("{t:\"Ocean\r\ndream\"} the sea")
        #expect(title.title == nil, "a title never spans a line")
        #expect(title.text == "{t:\"Ocean\ndream\"} the sea")
    }

    /// The whole reading, stated once: a CRLF or CR capture parses EXACTLY
    /// as its LF twin — text, tags and title — tokens or none.
    @Test func aForeignLineEndingCaptureParsesExactlyAsItsLFTwin() {
        let twins = [
            "{t:\"Leg day\"}\nsquats\n{#health/workout}\na long walk",
            "Had a dream {#dream}\n\nabout the ocean {#sea}",
            "a thought {#unclosed\nand more}",
            "Garden plans\nthe roses need water",  // no brace at all
            "{#dream}",
        ]
        for lf in twins {
            let want = CaptureMicrosyntax.parse(lf)
            for foreign in [lf.replacingOccurrences(of: "\n", with: "\r\n"),
                            lf.replacingOccurrences(of: "\n", with: "\r")] {
                #expect(CaptureMicrosyntax.parse(foreign) == want,
                        "\(foreign.debugDescription) reads as \(lf.debugDescription)")
            }
        }
    }

    /// The guard (green on both sides): only CR and CRLF are read. U+2028,
    /// U+2029 and U+0085 stay CONTENT, as everywhere in the block-boundary
    /// family (`NewlineSplitting`'s doc; U2's `theExoticNewlinesStayContent`) —
    /// so a token beside one is mid-line, and nothing about it moved.
    @Test func theExoticSeparatorsStayContent() {
        #expect(CaptureMicrosyntax.parse("{#dream}\u{2028}Had a dream").text
                == "\u{2028}Had a dream",
                "the token opened a line that goes on past a U+2028 — rule 5 does not fire")
        #expect(CaptureMicrosyntax.parse("{#dream}\u{2029}Had a dream").text
                == "\u{2029}Had a dream")
        #expect(CaptureMicrosyntax.parse("{#dream}\u{0085}Had a dream").text
                == "\u{0085}Had a dream")
    }
}

// MARK: - The two Mac doors

@MainActor
@Suite("CRLF captures at both Mac capture doors (18o U3 — row 12b)")
struct CaptureLineEndingDoorTests {
    private func withWorld<T>(
        _ body: @MainActor (AppSession, AppDatabase) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// The note's blocks EXACTLY as stored — no trimming, so an invented
    /// blank paragraph (a trailing `"\n"` of content) is visible.
    private func facts(
        _ db: AppDatabase, _ postID: String
    ) async throws -> (title: String?, tags: [String], blocks: [String]) {
        try await db.read { db in
            (try Queries.containerHeader(db, containerID: postID)?.title,
             try Queries.postTags(db, postID: postID).map(\.path).sorted(),
             try Queries.renderPost(db, containerID: postID).compactMap(\.text))
        }
    }

    /// **RULE 5 at the shelf's box — RED ON OLD:** a Windows-pasted capture
    /// whose tag sits on its own line files as two ADJACENT paragraphs, with
    /// no blank paragraph invented where the token line stood.
    @Test func theShelfBoxInventsNoBlankParagraphWhereACRLFTokenLineStood() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "Paragraph one.\r\n{#dream}\r\nParagraph two."
            let noteID = try #require(await box.submit())

            let (_, tags, blocks) = try await facts(db, noteID)
            #expect(tags == ["dream"])
            #expect(blocks == ["Paragraph one.", "Paragraph two."],
                    "on old: [\"Paragraph one.\\n\", …] — a blank paragraph she never typed")
        }
    }

    /// **RULE 2 at the shelf's box — RED ON OLD, and the worst outcome:** an
    /// unclosed `{#` that opens a CRLF capture used to swallow EVERYTHING up
    /// to a later `}` into a tag path, leave no text, and send the box down
    /// its empty branch — cleared, nothing filed. Now it files, visibly.
    @Test func anUnclosedTagAtACRLFNeverCostsHerTheCapture() async throws {
        try await withWorld { session, db in
            let box = QuickEntryModel(session: session)
            box.text = "{#dream\r\nHad a weird dream about the ocean}"
            let noteID = try #require(await box.submit(), "the capture FILES — on old, nil")

            let (_, tags, blocks) = try await facts(db, noteID)
            #expect(tags.isEmpty, "no tag was invented from a swallowed line")
            #expect(blocks == ["{#dream", "Had a weird dream about the ocean}"],
                    "every word she typed, one block per line")
            #expect(try await db.read { try Queries.allTags($0) }.isEmpty)
        }
    }

    /// **The quick-note pad, the other door — RED ON OLD:** title on its own
    /// line, a tag line mid-capture, CRLF throughout.
    @Test func thePadFilesACRLFCaptureLikeItsLFTwin() async throws {
        try await withWorld { session, db in
            let pad = QuickNotePad(session: session)
            pad.text = "{t:\"Leg day\"}\r\nsquats\r\n{#health/workout}\r\na long walk"
            let noteID = try #require(await pad.fileExplicitly().postID)

            let (title, tags, blocks) = try await facts(db, noteID)
            #expect(title == "Leg day")
            #expect(tags == ["health/workout", "quicknote"])
            #expect(blocks == ["squats", "a long walk"],
                    "on old: [\"squats\\n\", …] — the token line's breaks left a blank paragraph")
            #expect(pad.text.isEmpty)
        }
    }

    /// **The same reading reaches the door's first-words title — RED ON OLD.**
    /// The hand-off derives the offered name from the PARSED text
    /// (`NoteCardFace.suggestedTitle`, whose "first line" is `"\n"`-split), so
    /// a CRLF capture used to store a NAME running on across the line break,
    /// the break inside it. With a token and without one.
    @Test func theOfferedTitleIsTheFirstLineOfACRLFCapture() async throws {
        try await withWorld { session, db in
            for raw in ["Garden plans\r\nthe roses need water {#garden}",
                        "Garden plans\r\nthe roses need water"] {
                let box = QuickEntryModel(session: session)
                box.titleFromFirstWords = true
                box.text = raw
                let noteID = try #require(await box.submit())
                let (title, _, _) = try await facts(db, noteID)
                #expect(title == "Garden plans", "\(raw.debugDescription)")
            }
        }
    }
}
