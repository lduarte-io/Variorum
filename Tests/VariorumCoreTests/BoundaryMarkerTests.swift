import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U3 R7 — FORMAT v2: THE BOUNDARY MARKER (her R-13nb-26 (a) — "separator
// line, both forms" — with her refinement that the PLAIN export never
// carries it; the design AF-10's). Marker mode engages only when a block
// holds a blank line with text after it; every other note serializes v1 byte
// for byte (the 13n-a pins stand untouched — they run green beside this
// suite); the parser keys on `{v:2}`; marker mode is the exact inverse of its
// serializer; a prose line that IS the marker escapes exactly.

private let header = VariorumDocument.alternatesHeader
private let footer = VariorumDocument.alternatesFooter
private let marker = VariorumDocument.blockMarker

private func failure(_ text: String) -> VariorumDocument.Failure? {
    do throws(VariorumDocument.Failure) {
        _ = try VariorumDocument.parse(text)
        return nil
    } catch {
        return error
    }
}

@Suite("13n-b U3 — format v2, the boundary marker")
struct BoundaryMarkerTests {
    // MARK: - Engaged only when needed

    @Test func markerModeEngagesOnlyForABlankLineWithTextAfterIt() {
        func needs(_ texts: [String]) -> Bool {
            VariorumDocument.needsBoundaryMarkers(texts.map { VariorumDocument.Block(text: $0) })
        }
        #expect(needs(["One.", "Two paragraphs.\n\nIn one block."]))
        #expect(needs(["\nA leading blank line."]))
        #expect(needs(["A whitespace-only line\n   \ninside."]))
        #expect(!needs(["Plain.", "Two\nlines.", "Spaced.\n\n", "Wider.\n\n\n\n", ""]),
                "single newlines, stored trailing spacing and empty blocks are v1's")
        let fanned = VariorumDocument.Block(text: "Plain.", alternates: [.init(label: nil, text: "a take\n\nwith a blank line")])
        #expect(!VariorumDocument.needsBoundaryMarkers([fanned]), "a take's own blank lines ride the section in v1")
    }

    @Test func aNoteWithoutAMultiParagraphBlockSerializesExactlyAsV1() {
        let document = VariorumDocument.Document(
            title: "T", tagPaths: ["a/b"],
            blocks: [
                .init(text: "First", alternates: [.init(label: "en", text: "One\n\nwith a blank line")]),
                .init(text: "Second\nline"), .init(text: "Third\n\n"), .init(text: "Last"),
            ])
        let v1 = "{t:\"T\"} {#a/b}\n\n" + VariorumDocument.serializeBody(document.blocks)
        #expect(VariorumDocument.serialize(document) == v1)
        #expect(VariorumDocument.serializeTakesExport(document.blocks) == VariorumDocument.serializeBody(document.blocks))
        #expect(!VariorumDocument.serialize(document).contains("{v:") && !v1.contains(marker))
    }

    // MARK: - Marker mode: the exact inverse

    @Test func aMultiParagraphBlockSerializesInMarkerModeAndComesBackAsOneBlock() throws {
        let document = VariorumDocument.Document(
            title: "ch 1", tagPaths: ["percy"],
            blocks: [
                .init(text: "Para one.\n\nPara two, same block."),
                .init(text: "Next block.", alternates: [.init(label: "en", text: "Bloco seguinte.")]),
            ])
        let text = VariorumDocument.serialize(document)
        #expect(text == """
            {v:2} {t:"ch 1"} {#percy}

            Para one.

            Para two, same block.

            \(marker)

            Next block.

            \(header)

            take: "en"

            Bloco seguinte.

            \(footer)
            """)
        let parsed = try VariorumDocument.parse(text)
        #expect(parsed == document, "the multi-paragraph block returns ONE block")
        #expect(VariorumDocument.serialize(parsed) == text, "export → parse → serialize is byte-identical")
    }

    /// Every block shape marker mode must carry exactly — paragraphs inside,
    /// leading and whitespace-only lines, stored spacing, single newlines, a
    /// marker line and a stacked one in her prose, blank-chosen sections —
    /// with and without a fan, in every sequence of one to three that NEEDS
    /// marker mode. The one domain fence, v1's own: a fanless LAST block's
    /// trailing newlines are the document's edge.
    @Test func markerModeIsTheExactInverseOfItsSerializerOverEveryShape() throws {
        let surfaces = [
            "Para one.\n\nPara two.", "\nLeading blank.", "Inner\n   \nwhitespace line.", "Plain.",
            "Spaced multi\n\nparagraph.\n\n\n", "Two\nlines.", "Her prose:\n\(marker)\nas a line.",
            "Stacked:\n  \\\(marker)", "  an indent kept, and trailing spaces  ",
        ]
        let fans: [[VariorumDocument.Take]] = [
            [], [.init(label: "en", text: "Alt.\n\nTwo paragraphs."), .init(label: nil, text: "plain take\n")],
        ]
        let shapes = surfaces.flatMap { text in fans.map { VariorumDocument.Block(text: text, alternates: $0) } }
            + [VariorumDocument.Block(text: "", alternates: fans[1])]
        var all: [[VariorumDocument.Block]] = shapes.map { [$0] }
        var frontier = all
        for _ in 2...3 {
            frontier = frontier.flatMap { prefix in shapes.map { prefix + [$0] } }
            all += frontier
        }
        let domain = all.filter { blocks in
            guard let last = blocks.last, VariorumDocument.needsBoundaryMarkers(blocks) else { return false }
            return !last.alternates.isEmpty || !last.text.hasSuffix("\n")
        }
        var misread: [[VariorumDocument.Block]] = []
        for blocks in domain {
            let document = VariorumDocument.Document(title: "T", tagPaths: ["x"], blocks: blocks)
            let text = VariorumDocument.serialize(document)
            let parsed = try? VariorumDocument.parse(text)
            if parsed != document || parsed.map(VariorumDocument.serialize) != text { misread.append(blocks) }
        }
        #expect(domain.count > 1000)
        #expect(misread.isEmpty,
                "\(misread.count) of \(domain.count) marker-mode notes misread; the first: \(String(describing: misread.first))")
    }

    @Test func aProseLineThatIsTheMarkerEscapesExactlyAndStacks() throws {
        let blocks = [
            VariorumDocument.Block(text: "First.\n\nThen her line:\n\(marker)\nand on."),
            VariorumDocument.Block(text: "Already escaped:\n\\\(marker)\n\\\\\(marker)"),
        ]
        let text = VariorumDocument.serialize(.init(blocks: blocks))
        #expect(text.contains("\n\\\(marker)\n"), "her marker line gains one backslash")
        #expect(text.contains("\n\\\\\(marker)\n\\\\\\\(marker)"), "and backslashes stack, one more each")
        #expect(try VariorumDocument.parse(text).blocks == blocks)
    }

    // MARK: - The version token is the parser's key

    @Test func theVersionTokenIsTheParsersKey() throws {
        // Absent: v1 exactly — a blank line is a boundary.
        #expect(try VariorumDocument.parse("A\n\nB").blocks.count == 2)
        // {v:1}: v1, said out loud.
        #expect(try VariorumDocument.parse("{v:1} {t:\"T\"}\n\nA\n\nB").blocks.map(\.text) == ["A", "B"])
        // {v:2} alone, or after the other tokens: marker mode.
        #expect(try VariorumDocument.parse("{v:2}\n\nA\n\nB").blocks.map(\.text) == ["A\n\nB"])
        let late = try VariorumDocument.parse("{t:\"T\"} {v:2} {#a}\n\nA\n\nB")
        #expect(late.title == "T" && late.tagPaths == ["a"] && late.blocks.map(\.text) == ["A\n\nB"])
        // A version this build cannot read refuses, naming its line.
        #expect(failure("\n{v:3} {t:\"T\"}\n\nA") == .init(.unsupportedVersion(3), line: 2))
        // Prose beside a token is body — the version is not read from it.
        #expect(try VariorumDocument.parse("{v:2} is how the header begins.\n\nNext.").blocks.map(\.text)
                == ["{v:2} is how the header begins.", "Next."])
        // A version-only header with nothing after it has nothing to import.
        #expect(failure("{v:2}") == .init(.empty))
        // Capture keeps its grammar: {v:2} is never a capture token.
        #expect(CaptureTokens.parse("{v:2} a thought").text == "{v:2} a thought")
    }

    @Test func handWrittenMarkerModeReadsLeniently() throws {
        // Markers without blank lines around them; doubled and leading
        // markers make no empty block; text after a section starts a block.
        let text = """
            {v:2}
            \(marker)
            One.

            Still one.
            \(marker)
            \(marker)
            Two.
            \(header)
            take: "x"
            two, again
            \(footer)

            Three, after the section.
            """
        let blocks = try VariorumDocument.parse(text).blocks
        #expect(blocks == [
            .init(text: "One.\n\nStill one."),
            .init(text: "Two.", alternates: [.init(label: "x", text: "two, again")]),
            .init(text: "Three, after the section."),
        ])
        // The section's own refusals keep their lines in marker mode.
        #expect(failure("{v:2}\n\nA\n\n\(header)\n\ntake: 1\n\nx") == .init(.unterminatedAlternates, line: 5))
        #expect(failure("{v:2}\n\nA\n\n\(footer)") == .init(.endWithoutAlternates, line: 5))
        #expect(failure("{v:2}\n\n\(header)\n\n\(footer)") == .init(.alternatesWithoutParagraph, line: 3))
    }

    // MARK: - The exports, and the import door, over the store

    @Test func thePlainExportNeverCarriesTheMarkerAndTheTakesFormsReimportWhole() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "letters")
            let multi = try ops.seedBlock(in: post.id, text: "Dear K,\n\nIt has been a year.")
            try ops.seedBlock(in: post.id, text: "Yours.")
            let take = try ops.branchVariant(multi.block.id, from: multi.variant.id)
            try ops.autosave(take.id, text: "Querida K,\n\nJá faz um ano.", charDelta: 4)
            try ops.setTakeLabel(take.id, label: "pt")

            let (plain, takes, full) = try db.read { db in
                (try Queries.exportPost(db, postID: post.id),
                 try Queries.exportPost(db, postID: post.id, includeVariants: true),
                 try Queries.variorumDocumentText(db, postID: post.id))
            }
            // Her refinement: the plain export is the markdown, whatever the blocks.
            #expect(plain == "Dear K,\n\nIt has been a year.\n\nYours.")
            #expect(!plain.contains(marker) && !plain.contains("{") && !plain.contains(header))
            #expect(plain == (try db.read { try Queries.renderedText($0, containerID: post.id) }))
            // The takes-carrying forms speak v2 and re-import whole.
            #expect(takes.hasPrefix("{v:2}\n\nDear K,\n\nIt has been a year.\n\n\(header)"))
            #expect(full.hasPrefix("{v:2} {t:\"letters\"}\n\n"))
            for text in [takes, full] {
                let imported = try ops.importDocument(.init(fallbackTitle: "re", document: try VariorumDocument.parse(text)))
                #expect(imported.blockIDs.count == 2, "the multi-paragraph block comes back ONE block")
                #expect(try db.read { try Queries.renderedText($0, containerID: imported.post.id) }
                        == "Dear K,\n\nIt has been a year.\n\nYours.")
                let fan = try db.read { db in
                    try String.fetchAll(
                        db, sql: "SELECT working_text FROM variant WHERE block_id = ? ORDER BY fan_position",
                        arguments: [imported.blockIDs[0]])
                }
                #expect(fan == ["Dear K,\n\nIt has been a year.", "Querida K,\n\nJá faz um ano."])
            }
            // The export pin: reading for any export wrote nothing.
            try db.clearOutbox()
            _ = try db.read { db in
                (try Queries.exportPost(db, postID: post.id, includeVariants: true),
                 try Queries.variorumDocumentText(db, postID: post.id))
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
        }
    }

    @Test func aFolderOfV2FilesImportsAsABookThroughTheOneParser() throws {
        let book = try VariorumDocumentFolder.plan(
            folderName: "letters",
            files: [
                .init(relativePath: "1 first.md", contents: "{v:2}\n\nDear K,\n\nOne block.\n\n\(marker)\n\nTwo."),
                .init(relativePath: "2 plain.md", contents: "A\n\nB"),
            ])
        #expect(book.unfiled.map { $0.document.blocks.map(\.text) } == [["Dear K,\n\nOne block.", "Two."], ["A", "B"]])
    }
}
