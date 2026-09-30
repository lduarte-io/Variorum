import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **18o U2 — 17e P23: a CRLF file imported as ONE block.**
///
/// `"\r\n"` is ONE Swift `Character`, and it is not `Character("\n")`, so
/// `bulkSegments`' `split(separator: "\n")` found no separator in a
/// Windows-authored file: `.paragraph` (the schema's default) minted the whole
/// document as one block — no per-paragraph blocks, takes, lineage or reorder,
/// and a document-sized autosave. Silent; nothing refused.
///
/// **The fix is the block-boundary family's own rule, not `isNewline`.** The
/// segmenter decides BLOCK boundaries, and that family keys on `"\n"` only
/// (`NewlineSplitting`'s doc: *"a Control-Return's U+2028 is content
/// everywhere in this app, never a block boundary"*). Its answer for foreign
/// line endings is `PlainPaste` rule 1 — *"`\r\n` and a bare `\r` normalize to
/// `\n` first"* — so `bulkSegments` now reads them as `"\n"` at its entry, in
/// every mode, and U+0085 / U+2028 / U+2029 stay content (pinned below as the
/// family's standing answer; an `isNewline` split would red them).
///
/// *Red on the old code:* every pin marked RED-ON-OLD below. The GUARDS are
/// green on both sides by design and say so.
@Suite("18o U2 — P23: foreign line endings at the segmenter's entry")
struct SegmentationLineEndingTests {

    // MARK: - The pure rule (every arm)

    /// RED-ON-OLD — the verifier's own string, the finding's exact shape.
    @Test func aCRLFDocumentSegmentsOneBlockPerParagraph() {
        let crlf = "Para one.\r\n\r\nPara two.\r\nPara three."
        #expect(SegmentationRules.bulkSegments(crlf, mode: .paragraph) == [
            "Para one.\n", "Para two.", "Para three.",
        ], "one block per paragraph; the blank line is k−1 content, as for LF")
    }

    /// RED-ON-OLD — a bare CR (classic Mac) is the same text as its LF twin,
    /// and so is a CR directly followed by a CRLF (two line endings).
    @Test func aBareCRSegmentsExactlyAsItsLFTwin() {
        for (foreign, lf) in [
            ("A\rB\r\rC", "A\nB\n\nC"),
            ("A\r\r\nB", "A\n\nB"),
            ("One.\r\nTwo.\rThree.", "One.\nTwo.\nThree."),
        ] {
            for mode in [Segmentation.paragraph, .sentence] {
                #expect(SegmentationRules.bulkSegments(foreign, mode: mode)
                        == SegmentationRules.bulkSegments(lf, mode: mode),
                        "\(foreign.debugDescription) in \(mode)")
            }
            #expect(SegmentationRules.bulkSegments(foreign, mode: .paragraph).count > 1)
        }
    }

    /// RED-ON-OLD — sentence mode degraded less (its scanner keys on
    /// `isWhitespace`), but a line with no terminator glued onto the next
    /// line's sentence, `"\r\n"` and all, and the blank-line spacing was lost.
    @Test func sentenceModeReadsACRLFLineBreakAsTheBreakItIs() {
        let crlf = "Title\r\nFirst sentence. Second.\r\n\r\nThird."
        #expect(SegmentationRules.bulkSegments(crlf, mode: .sentence) == [
            "Title", "First sentence.", "Second.\n", "Third.",
        ])
    }

    /// RED-ON-OLD — `one_block` still passes the text through whole; its
    /// line endings read as `"\n"` like every other arm's, so the block the
    /// rest of the brain sees (`NewlineSplitting`, `BlockRangeIndex`) has the
    /// line breaks it recognises. Everything else stays verbatim.
    @Test func oneBlockKeepsTheTextWholeWithItsLineEndingsReadAsLF() {
        #expect(SegmentationRules.bulkSegments("A.\r\n\r\nB.", mode: .oneBlock) == ["A.\n\nB."])
        #expect(SegmentationRules.bulkSegments("A.\rB.", mode: .oneBlock) == ["A.\nB."])
        // GUARD: nothing but CR/CRLF changes — edges, spaces and the exotic
        // newlines ride verbatim.
        let verbatim = "  Lead\u{2028}line\n\n trail  "
        #expect(SegmentationRules.bulkSegments(verbatim, mode: .oneBlock) == [verbatim])
    }

    /// GUARD (green on both sides — the FAMILY'S ANSWER, pinned so it is not
    /// "fixed" into a break): U+2028 LINE SEPARATOR (what ⌃⏎/⌥⏎ type),
    /// U+2029 PARAGRAPH SEPARATOR and U+0085 NEXT LINE are CONTENT in bulk
    /// entry exactly as they are at type-time — never block boundaries. A
    /// `Character.isNewline` split reds this pin (the design's rejected road).
    @Test func theExoticNewlinesStayContent() {
        for separator in ["\u{2028}", "\u{2029}", "\u{0085}"] {
            let text = "First half\(separator)second half"
            #expect(SegmentationRules.bulkSegments(text, mode: .paragraph) == [text],
                    "U+\(String(separator.unicodeScalars.first!.value, radix: 16, uppercase: true)) is content")
            #expect(SegmentationRules.bulkSegments(text, mode: .oneBlock) == [text])
        }
        // …and the same at TYPE-TIME, whose rule is untouched: a typed
        // Control-Return inside an open-tail paragraph stays in its block.
        let step = SegmentationRules.crystallizedBoundary(openTail: "a\u{2028}b\nc")
        #expect(step == SegmentationRules.Crystallization(blockText: "a\u{2028}b", remainingTail: "c"))
    }

    /// GUARD — whitespace-only foreign text is still nothing to mint, and
    /// the edge runs still drop.
    @Test func blankForeignTextStillMintsNothingAndEdgeRunsDrop() {
        #expect(SegmentationRules.bulkSegments("\r\n\r\n \r\n", mode: .paragraph).isEmpty)
        #expect(SegmentationRules.bulkSegments("\r\r", mode: .oneBlock).isEmpty)
        #expect(SegmentationRules.bulkSegments("\r\n\r\nBody.\r\n\r\n", mode: .paragraph) == ["Body."])
    }

    /// RED-ON-OLD — the 2026-07-12 spacing promise (segments joined by the
    /// editor's one-`"\n"` separator reproduce the paste) now holds for a
    /// foreign file too, modulo its line endings reading as `"\n"`.
    @Test func theSpacingPromiseHoldsForForeignLineEndings() {
        for (foreign, lf) in [
            ("A\r\nB", "A\nB"),
            ("A\r\n\r\nB", "A\n\nB"),
            ("One.\r\n\r\nTwo.\r\n\r\n\r\n\r\nThree.", "One.\n\nTwo.\n\n\n\nThree."),
            ("A\r\rB", "A\n\nB"),
        ] {
            let blocks = SegmentationRules.bulkSegments(foreign, mode: .paragraph)
            #expect(blocks.joined(separator: "\n") == lf, "\(foreign.debugDescription)")
            #expect(!blocks.contains { $0.unicodeScalars.contains("\r") }, "no CR survives into a block")
        }
    }

    // MARK: - Through the operations (every door rides these two)

    private func storedTexts(_ db: AppDatabase, _ containerID: String) throws -> [String] {
        try db.read { database in
            try Queries.renderPost(database, containerID: containerID).map { $0.text ?? "" }
        }
    }

    /// RED-ON-OLD — THE LIBRARY DOOR (`importPost`: file import, the Mac's
    /// quick note and quick-entry bar, the phone's capture): a Windows file
    /// under the default `.paragraph` mints one block per paragraph, stores
    /// no CR, and exports as the LF text it is.
    @Test func aCRLFFileImportsOneBlockPerParagraph() throws {
        try withOperations { ops, db in
            let result = try ops.importPost(
                title: "From Windows", text: "Para one.\r\n\r\nPara two.\r\nPara three.")
            #expect(result.blockIDs.count == 3)
            let texts = try storedTexts(db, result.container.id)
            #expect(texts == ["Para one.\n", "Para two.", "Para three."])
            #expect(!texts.joined().unicodeScalars.contains("\r"))
            let exported = try db.read { try Queries.exportPost($0, postID: result.container.id) }
            #expect(exported == "Para one.\n\nPara two.\n\nPara three.")
        }
    }

    /// RED-ON-OLD — THE POOL DOOR (`importBlocks`): the same rule.
    @Test func aCRLFDropIntoAPoolSegmentsToo() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool(title: "Pool")
            let result = try ops.importBlocks(into: pool.id, text: "New one.\r\n\r\nNew two.")
            #expect(result.blockIDs.count == 2)
            #expect(try storedTexts(db, pool.id) == ["New one.\n", "New two."])
        }
    }

    /// RED-ON-OLD — the `.sentence` and `one_block` global defaults through
    /// the op (the arms above, end to end).
    @Test func theSentenceAndOneBlockDefaultsReadCRLFThroughTheOp() throws {
        try withOperations { ops, db in
            try db.write { database in
                try database.execute(
                    sql: "UPDATE setting SET value = 'sentence' WHERE key = 'default_segmentation'")
            }
            let sentence = try ops.importPost(title: nil, text: "Heading\r\nOne. Two.")
            #expect(try storedTexts(db, sentence.container.id) == ["Heading", "One.", "Two."])

            try db.write { database in
                try database.execute(
                    sql: "UPDATE setting SET value = 'one_block' WHERE key = 'default_segmentation'")
            }
            let whole = try ops.importPost(title: nil, text: "A.\r\n\r\nB.")
            #expect(try storedTexts(db, whole.container.id) == ["A.\n\nB."])
        }
    }
}
