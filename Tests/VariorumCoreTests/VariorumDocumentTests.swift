import Foundation
import Testing
@testable import VariorumCore

/// 13n-a — THE VARIORUM DOCUMENT FORMAT (Level 0; R-13n-8): the pure half.
/// The format is the shipped fan export plus the capture microsyntax's
/// header line; the body parses as the exact inverse of the join
/// (R-ARCH-13na-1) and a take's own text is kept exactly; every malformed
/// Alternates section refuses with its line. The store-side round-trip pins (export → parse → serialize) are
/// `DocumentFormatRoundTripTests`; the import operations are
/// `DocumentImportOperationTests`.
@Suite("Variorum document format (13n-a)")
struct VariorumDocumentTests {
    private let header = VariorumDocument.alternatesHeader
    private let footer = VariorumDocument.alternatesFooter

    // MARK: - The capture grammar, moved into core

    @Test func theCoreGrammarReadsTheCaptureRulesExactly() {
        // The app's capture suites pin the move end to end (the app parse
        // delegates here); these are the rules the document header leans on.
        let both = CaptureTokens.parse("{t:\u{201C}Ocean dream\u{201D}} {#dream}\nHad a dream")
        #expect(both.title == "Ocean dream")
        #expect(both.tagPaths == ["dream"])
        #expect(both.text == "Had a dream")

        // Malformed braces pass through byte-intact; a bare #hashtag is text.
        #expect(CaptureTokens.parse("{#} {t:\"\"} #bare").text == "{#} {t:\"\"} #bare")
        // A token takes its own seam whitespace.
        #expect(CaptureTokens.parse("Had a dream {#dream}").text == "Had a dream")
        // `{#a{#b}` is the text "{#a" and the tag "b".
        let nested = CaptureTokens.readLine("{#a{#b}")
        #expect(nested.text == "{#a")
        #expect(nested.tagPaths == ["b"])
        // A title may carry quotes of its own.
        #expect(CaptureTokens.readLine("{t:\"say \"hi\"\"}").title == "say \"hi\"")
    }

    @Test func aTypedTagPathCollapsesItsSlashNoise() {
        #expect(TagPath.segments("/life//goals/ 2026 /") == ["life", "goals", "2026"])
        #expect(TagPath.segments("///").isEmpty)
    }

    // MARK: - Parse: the sample her sitting approved (mockups §8)

    @Test func theSittingSampleParsesIntoTitleTagsBlocksAndTakes() throws {
        let sample = """
            {t:"o ladrão de raios — ch 1"} {#percy/pt-en}

            Eu não pedi para herdar o observatório.

            \(header)

            take: "english"

            Honestly, I never asked for the observatory.

            \(footer)

            Cuidar de um observatório dá trabalho.

            \(header)

            take: "english"

            Running an observatory is hard work.

            \(footer)
            """
        let document = try VariorumDocument.parse(sample)
        #expect(document.title == "o ladrão de raios — ch 1")
        #expect(document.tagPaths == ["percy/pt-en"])
        // The inverse of the join (R-ARCH-13na-1): the one blank line between
        // a paragraph and its section is the separator, never stored text.
        #expect(document.blocks == [
            .init(text: "Eu não pedi para herdar o observatório.",
                  alternates: [.init(label: "english", text: "Honestly, I never asked for the observatory.")]),
            .init(text: "Cuidar de um observatório dá trabalho.",
                  alternates: [.init(label: "english", text: "Running an observatory is hard work.")]),
        ])
        #expect(document.alternateCount == 2)
        // …and it serializes back byte-for-byte.
        #expect(VariorumDocument.serialize(document) == sample)
    }

    @Test func numberedTakesAreUnlabeledAndQuotedLabelsMayBeCurlyOrBare() throws {
        let text = """
            A

            \(header)

            take: 1

            one

            take: \u{201C}curly\u{201D}

            two

            take: bare words

            three

            take: ""

            four

            \(footer)
            """
        let block = try #require(try VariorumDocument.parse(text).blocks.first)
        #expect(block.alternates == [
            .init(label: nil, text: "one"),
            .init(label: "curly", text: "two"),
            .init(label: "bare words", text: "three"),
            .init(label: nil, text: "four"),
        ])
    }

    @Test func aTakeKeepsItsInternalNewlinesAndBlankLinesExactly() throws {
        let take = "line one\nline two\n\nline three\n"
        let text = "A\n\n" + VariorumDocument.alternatesSection([.init(label: "x", text: take)])
        let block = try #require(try VariorumDocument.parse(text).blocks.first)
        #expect(block.alternates == [.init(label: "x", text: take)])
    }

    @Test func aCompactHandWrittenSectionReadsToo() throws {
        let text = "Para\n\(header)\ntake: \"en\"\nHello\ntake: 2\nWorld\n\(footer)\nNext"
        let document = try VariorumDocument.parse(text)
        #expect(document.blocks == [
            .init(text: "Para", alternates: [
                .init(label: "en", text: "Hello"), .init(label: nil, text: "World"),
            ]),
            .init(text: "Next"),
        ])
    }

    @Test func emptyTakesSkipAndAnEmptySectionAddsNothing() throws {
        let text = "A\n\n\(header)\n\ntake: 1\n\ntake: \"kept\"\n\nk\n\n\(footer)\n\nB\n\n\(header)\n\n\(footer)"
        let document = try VariorumDocument.parse(text)
        #expect(document.blocks.map(\.alternates) == [[.init(label: "kept", text: "k")], []])
    }

    @Test func theHeaderIsReadOnTheFirstNonBlankLineOnly() throws {
        // Tokens beside prose: the tokens go, the prose is the first block.
        let mixed = try VariorumDocument.parse("\n{t:\"T\"} Hello {#a}\n\nWorld")
        #expect(mixed.title == "T")
        #expect(mixed.tagPaths == ["a"])
        #expect(mixed.blocks.map(\.text) == ["Hello", "World"])

        // A token anywhere else is her text.
        let later = try VariorumDocument.parse("Hello\n\n{#x} world")
        #expect(later.tagPaths.isEmpty)
        #expect(later.blocks.map(\.text) == ["Hello", "{#x} world"])
    }

    @Test func foreignLineEndingsAndAByteOrderMarkReadAsTheirLFTwin() throws {
        let lf = "{t:\"T\"}\n\nA\n\n\(header)\n\ntake: \"en\"\n\nB\n\n\(footer)"
        let crlf = "\u{FEFF}" + lf.replacingOccurrences(of: "\n", with: "\r\n")
        #expect(try VariorumDocument.parse(crlf) == VariorumDocument.parse(lf))
    }

    @Test func theFormatsReadingIsItsOwnAndPasteKeepsTheBulkRule() throws {
        // R-ARCH-13na-1 supersedes the bulk rule for the FORMAT only: the same
        // text pasted still segments by `bulkSegments` (a single newline is a
        // boundary, k newlines store k − 1), untouched by this reading.
        let body = "One.\n\nTwo.\n\n\nThree.\nFour."
        #expect(try VariorumDocument.parse(body).blocks.map(\.text)
            == ["One.", "Two.\n\n", "Three.\nFour."])
        #expect(SegmentationRules.bulkSegments(body, mode: .paragraph)
            == ["One.\n", "Two.\n\n", "Three.", "Four."])
    }

    // MARK: - R-ARCH-13na-1: the body is the exact inverse of the join

    /// Every block shape the join writes distinguishably — unspaced, stored
    /// spacing of 2, 3 and 4 newlines, a single newline inside the text, an
    /// indent and trailing spaces kept — with and without a fan, in every
    /// sequence of one to three. The one domain fence: a fanless LAST block
    /// carries no trailing newline (the document's trailing edge drops — a
    /// file's final newline is not her spacing).
    private static let surfaces = [
        "Plain.", "Spaced.\n\n", "Wider.\n\n\n\n", "Two\nlines.",
        "Wrapped\nand spaced.\n\n\n", "  an indent kept, and trailing spaces  ",
    ]
    private static let fans: [[VariorumDocument.Take]] = [
        [], [.init(label: "en", text: "Alt."), .init(label: nil, text: "two\n\nlines\n")],
    ]

    private static func sequences(of shapes: [VariorumDocument.Block]) -> [[VariorumDocument.Block]] {
        var all: [[VariorumDocument.Block]] = shapes.map { [$0] }
        var frontier = all
        for _ in 2...3 {
            frontier = frontier.flatMap { prefix in shapes.map { prefix + [$0] } }
            all += frontier
        }
        return all
    }

    @Test func theBodyIsTheExactInverseOfTheJoin() throws {
        // R-ARCH-13na-2 joins the family: a fanned block whose chosen take is
        // BLANK, wherever its section has no paragraph above it — the
        // document's start, or right after another section. (After a FANLESS
        // paragraph the join writes the very bytes of that paragraph's own
        // fan — recorded in the operations suite.)
        let blankChosen = VariorumDocument.Block(text: "", alternates: Self.fans[1])
        let shapes = Self.surfaces.flatMap { text in Self.fans.map { VariorumDocument.Block(text: text, alternates: $0) } }
            + [blankChosen]
        let domain = Self.sequences(of: shapes).filter { blocks in
            guard let last = blocks.last else { return false }
            let sectionsHaveNoParagraphAbove = blocks.indices.allSatisfy { index in
                blocks[index] != blankChosen || index == 0 || !blocks[index - 1].alternates.isEmpty
            }
            return sectionsHaveNoParagraphAbove && (!last.alternates.isEmpty || !last.text.hasSuffix("\n"))
        }
        var misread: [[VariorumDocument.Block]] = []
        for blocks in domain {
            let body = VariorumDocument.serializeBody(blocks)
            if (try? VariorumDocument.parse(body))?.blocks != blocks { misread.append(blocks) }
        }
        #expect(misread.isEmpty,
                "\(misread.count) of \(domain.count) block lists misread; the first: \(String(describing: misread.first))")
    }

    @Test func theJoinsOneUndecidableSpacingReadsUnspaced() throws {
        // RECORDED — the boundary of R-ARCH-13na-1, a property of the JOIN,
        // not a choice of the parse: a block storing exactly ONE trailing
        // newline and an unspaced one export the same bytes ("\n\n" either
        // way — `joinRenderedTexts`), so no reading can tell them apart; the
        // inverse reads the unspaced one (one blank line = the separator).
        let one = [VariorumDocument.Block(text: "A\n"), .init(text: "B")]
        let none = [VariorumDocument.Block(text: "A"), .init(text: "B")]
        #expect(VariorumDocument.serializeBody(one) == VariorumDocument.serializeBody(none))
        #expect(try VariorumDocument.parse(VariorumDocument.serializeBody(one)).blocks == none)
        // The edges are not spacing: leading and trailing blank runs drop.
        #expect(try VariorumDocument.parse("\n\nA\n\nB\n\n\n").blocks == none)
    }

    @Test func aSingleNewlineIsContentAndABlankLineIsTheBoundary() throws {
        // P-13n-4, narrowed by the ruling: a surface block's single newline
        // now rides INSIDE it; only a blank line inside a surface block (a
        // multi-paragraph surface block) still reads as a block boundary.
        #expect(try VariorumDocument.parse("a line\nanother line").blocks
            == [.init(text: "a line\nanother line")])
        #expect(try VariorumDocument.parse("one paragraph\n\nanother").blocks
            == [.init(text: "one paragraph"), .init(text: "another")])
        // Markdown's soft-wrap semantics, the way an LLM writes: a list is
        // one block, its lines content.
        #expect(try VariorumDocument.parse("Intro.\n\n- one\n- two\n\nAfter.").blocks
            == [.init(text: "Intro."), .init(text: "- one\n- two"), .init(text: "After.")])
    }

    // MARK: - R-ARCH-13na-2: a paragraph-less section is a blank chosen take

    @Test func aParagraphLessSectionIsAFannedBlockWithABlankChosenTake() throws {
        // The exact shape the export writes for a fanned block whose chosen
        // take is blank (the blank chosen skips; its takes are her work).
        // At the document's start — after the header line, too:
        let opening = try VariorumDocument.parse(
            "{t:\"T\"}\n\n\(header)\n\ntake: \"en\"\n\nx\n\n\(footer)\n\nNext")
        #expect(opening.title == "T")
        #expect(opening.blocks == [
            .init(text: "", alternates: [.init(label: "en", text: "x")]),
            .init(text: "Next"),
        ])
        // …and right after another section.
        let following = try VariorumDocument.parse(
            "A\n\n\(header)\n\ntake: 2\n\nx\n\n\(footer)\n\n\(header)\n\ntake: 3\n\ny\n\n\(footer)")
        #expect(following.blocks == [
            .init(text: "A", alternates: [.init(label: nil, text: "x")]),
            .init(text: "", alternates: [.init(label: nil, text: "y")]),
        ])
        // A document that is nothing but such a block is not empty.
        #expect(try VariorumDocument.parse("\(header)\n\ntake: 1\n\nz\n\n\(footer)").blocks
            == [.init(text: "", alternates: [.init(label: nil, text: "z")])])
    }

    // MARK: - Parse: fail-honest, with the line

    @Test func everyMalformedSectionRefusesNamingItsLine() {
        func failure(_ text: String) -> VariorumDocument.Failure? {
            do throws(VariorumDocument.Failure) {
                _ = try VariorumDocument.parse(text)
                return nil
            } catch {
                return error
            }
        }
        // A section with no paragraph above it AND no take of its own — at
        // the very start — has nothing to make a block of (with a take it is
        // a blank chosen take's export, R-ARCH-13na-2, pinned above).
        #expect(failure("\(header)\n\n\(footer)")
            == .init(.alternatesWithoutParagraph, line: 1))
        // …nor does one right after another section whose only take is empty.
        #expect(failure("A\n\n\(header)\n\ntake: 2\n\nx\n\n\(footer)\n\n\(header)\n\ntake: 3\n\n\(footer)")
            == .init(.alternatesWithoutParagraph, line: 11))
        // Never ends, even with no paragraph above it: named at its header.
        #expect(failure("\(header)\n\ntake: 2\n\nx")
            == .init(.unterminatedAlternates, line: 1))
        // Never ends: named at the section's header.
        #expect(failure("A\n\n\(header)\n\ntake: 2\n\nB")
            == .init(.unterminatedAlternates, line: 3))
        // Text before the first take marker.
        #expect(failure("A\n\n\(header)\n\nstray\n\ntake: 2\n\nx\n\n\(footer)")
            == .init(.textBeforeFirstTake, line: 5))
        // A second section opened inside the first.
        #expect(failure("A\n\n\(header)\n\ntake: 2\n\nx\n\n\(header)\n\n\(footer)")
            == .init(.alternatesInsideAlternates(openedAt: 3), line: 9))
        // An end marker with nothing open.
        #expect(failure("A\n\n\(footer)") == .init(.endWithoutAlternates, line: 3))
        // Line numbers count a CRLF file's lines as an editor shows them.
        #expect(failure("A\r\n\r\n\(footer)") == .init(.endWithoutAlternates, line: 3))
        // Nothing to import: a BLANK document (no header, no block). A header
        // line alone is an empty note now (ladder F4 — pinned below).
        #expect(failure("") == .init(.empty))
        #expect(failure("  \n\n\t\n") == .init(.empty))
    }

    // MARK: - Ladder F4 (option (b)): a stub is an empty note

    @Test func aHeaderOnlyDocumentIsAnEmptyNoteAndABlankOneStillRefuses() throws {
        // Copy for AI of a titled note with no text yet writes its header
        // line alone — that file re-imports as the empty note it was.
        let titled = try VariorumDocument.parse("{t:\"Chapter 3\"}")
        #expect(titled == .init(title: "Chapter 3", tagPaths: [], blocks: []))
        let tagged = try VariorumDocument.parse("{t:\"Only a title\"} {#a}\n\n")
        #expect(tagged == .init(title: "Only a title", tagPaths: ["a"], blocks: []))
        #expect(try VariorumDocument.parse("\n{#x/y}\n").tagPaths == ["x/y"])
        // A truly blank document still refuses (the single-file door's
        // "nothing in it to import").
        #expect(throws: VariorumDocument.Failure(.empty)) { try VariorumDocument.parse("") }
        #expect(throws: VariorumDocument.Failure(.empty)) { try VariorumDocument.parse(" \n\t\n") }
    }

    @Test func aStubInsideAFolderIsAnEmptyNote() throws {
        // A blank, whitespace-only or header-only file in a folder — what an
        // outline leaves, what an LLM scaffolding a book writes — is an EMPTY
        // note in its place, named by its header or else its file; the rest
        // of the folder imports as ever.
        let book = try VariorumDocumentFolder.plan(
            folderName: "Outline",
            files: [
                file("ch/1 blank.md", ""),
                file("ch/2 newline.md", "\n"),
                file("ch/3 titled.md", "{t:\"Chapter 3\"}"),
                file("ch/4 written.md", "Real text."),
                file("afterword.txt", "  \n\t\n"),
            ])
        let notes = book.chapters[0].notes
        #expect(notes.map(\.fallbackTitle) == ["1 blank", "2 newline", "3 titled", "4 written"])
        #expect(notes.map(\.document.blocks.count) == [0, 0, 0, 1])
        #expect(notes[2].document.title == "Chapter 3")
        #expect(book.unfiled.map(\.document) == [.init(blocks: [])])
        // A malformed file still refuses the whole folder.
        #expect(throws: VariorumDocument.Failure(.unterminatedAlternates, line: 1, file: "ch/5.md")) {
            try VariorumDocumentFolder.plan(
                folderName: "Outline",
                files: [file("ch/1.md", ""), file("ch/5.md", "\(header)\n\ntake: 1\n\nx")])
        }
    }

    // MARK: - Serialize

    @Test func theHeaderLineCarriesTheTitleThenEachTag() {
        #expect(VariorumDocument.headerLine(title: "T", tagPaths: ["a/b", "c"])
            == "{t:\"T\"} {#a/b} {#c}")
        #expect(VariorumDocument.headerLine(title: nil, tagPaths: []) == nil)
        let document = VariorumDocument.Document(title: nil, tagPaths: ["x"], blocks: [.init(text: "A")])
        #expect(VariorumDocument.serialize(document) == "{#x}\n\nA")
        #expect(VariorumDocument.serialize(.init(blocks: [.init(text: "A")])) == "A")
    }

    @Test func serializeThenParseThenSerializeIsByteStable() throws {
        let document = VariorumDocument.Document(
            title: "Round", tagPaths: ["a/b"],
            blocks: [
                .init(text: "First", alternates: [
                    .init(label: "en", text: "One\n\nwith a blank line"),
                    .init(label: nil, text: "two"),
                ]),
                .init(text: "Second"),
                .init(text: "Third\n\n", alternates: [.init(label: nil, text: "x\n")]),
                .init(text: "Last"),
            ])
        let text = VariorumDocument.serialize(document)
        #expect(VariorumDocument.serialize(try VariorumDocument.parse(text)) == text)
    }

    // MARK: - A folder, read as a book

    private func file(_ path: String, _ contents: String = "Body.") -> VariorumDocumentFolder.File {
        .init(relativePath: path, contents: contents)
    }

    @Test func subfoldersAreChaptersInDigitAwareOrderAndFilesAreBookOrder() throws {
        let book = try VariorumDocumentFolder.plan(
            folderName: "o ladrão de raios",
            files: [
                file("10 the end.md"),
                file("2 middle.txt"),
                file("Chapter 10/1 a.md"),
                file("Chapter 2/10 late.md"),
                file("Chapter 2/9 early.variorum"),
                file("Chapter 2/deeper/zz nested.md"),
                file(".hidden.md"),
                file("Chapter 2/.DS_Store"),
                file("cover.png"),
                file(".git/HEAD.md"),
            ],
            subfolders: ["Chapter 2", "Chapter 10", "Empty chapter", "Chapter 2/deeper", ".git"])
        #expect(book.name == "o ladrão de raios")
        #expect(book.chapters.map(\.name) == ["Chapter 2", "Chapter 10", "Empty chapter"])
        #expect(book.chapters[0].notes.map(\.fallbackTitle) == ["9 early", "10 late", "zz nested"])
        #expect(book.chapters[1].notes.map(\.fallbackTitle) == ["1 a"])
        #expect(book.chapters[2].notes.isEmpty)
        #expect(book.unfiled.map(\.fallbackTitle) == ["2 middle", "10 the end"])
        #expect(book.noteCount == 6)
    }

    @Test func aFolderRefusesWholeNamingTheFileAndLine() {
        do throws(VariorumDocument.Failure) {
            _ = try VariorumDocumentFolder.plan(
                folderName: "Book",
                files: [file("a.md"), file("Ch/b.md", "A\n\n\(header)\n\ntake: 2\n\nx")])
            Issue.record("a malformed file must refuse the whole folder")
        } catch {
            #expect(error == .init(.unterminatedAlternates, line: 3, file: "Ch/b.md"))
        }
        do throws(VariorumDocument.Failure) {
            _ = try VariorumDocumentFolder.plan(
                folderName: "Nothing here", files: [file("cover.png")], subfolders: ["Empty"])
            Issue.record("a folder with nothing importable refuses")
        } catch {
            #expect(error == .init(.noImportableFiles, file: "Nothing here"))
        }
    }

    @Test func namesTakenFromThePathArePrecomposedButTextIsNot() throws {
        // macOS hands paths back DECOMPOSED ("a" + U+0303); a name she would
        // type is precomposed ("ã"). Swift compares the two equal, SQLite does
        // not — so every name the IMPORT derives from a path (the book, its
        // chapters, a note's fallback title) is stored precomposed (NFC),
        // while a document's own text is hers, byte for byte.
        let nfd = "ladra\u{0303}o"
        let nfc = "ladr\u{00E3}o"
        let book = try VariorumDocumentFolder.plan(
            folderName: "o \(nfd)",
            files: [.init(relativePath: "cap \(nfd)/\(nfd).md", contents: "um \(nfd)")])
        #expect(Array(book.name.unicodeScalars) == Array("o \(nfc)".unicodeScalars))
        #expect(Array(book.chapters[0].name.unicodeScalars) == Array("cap \(nfc)".unicodeScalars))
        let note = book.chapters[0].notes[0]
        #expect(Array(note.fallbackTitle.unicodeScalars) == Array(nfc.unicodeScalars))
        #expect(Array(note.document.blocks[0].text.unicodeScalars) == Array("um \(nfd)".unicodeScalars))
    }

    @Test func aSingleFileIsNamedByItsFilename() throws {
        let note = try VariorumDocumentFolder.note(named: "03 notes.md", contents: "Hi")
        #expect(note.fallbackTitle == "03 notes")
        #expect(note.document.blocks == [.init(text: "Hi")])
        #expect(VariorumDocumentFolder.isImportable("a/b.MARKDOWN"))
        #expect(!VariorumDocumentFolder.isImportable("a/.b.md"))
        #expect(!VariorumDocumentFolder.isImportable("photo.jpg"))
    }
}
