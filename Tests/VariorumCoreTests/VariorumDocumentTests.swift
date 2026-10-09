import Foundation
import Testing
@testable import VariorumCore

/// 13n-a — THE VARIORUM DOCUMENT FORMAT (Level 0; R-13n-8): the pure half.
/// The format is the shipped fan export plus the capture microsyntax's
/// header line; parsing is the standing bulk rule for the body and keeps a
/// take's own text exactly; every malformed Alternates section refuses with
/// its line. The store-side round-trip pins (export → parse → serialize) are
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
        // The bulk rule's spacing: the blank line between a paragraph and the
        // section that follows it is the paragraph's stored k−1.
        #expect(document.blocks == [
            .init(text: "Eu não pedi para herdar o observatório.\n",
                  alternates: [.init(label: "english", text: "Honestly, I never asked for the observatory.")]),
            .init(text: "Cuidar de um observatório dá trabalho.\n",
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
        #expect(mixed.blocks.map(\.text) == ["Hello\n", "World"])

        // A token anywhere else is her text.
        let later = try VariorumDocument.parse("Hello\n\n{#x} world")
        #expect(later.tagPaths.isEmpty)
        #expect(later.blocks.map(\.text) == ["Hello\n", "{#x} world"])
    }

    @Test func foreignLineEndingsAndAByteOrderMarkReadAsTheirLFTwin() throws {
        let lf = "{t:\"T\"}\n\nA\n\n\(header)\n\ntake: \"en\"\n\nB\n\n\(footer)"
        let crlf = "\u{FEFF}" + lf.replacingOccurrences(of: "\n", with: "\r\n")
        #expect(try VariorumDocument.parse(crlf) == VariorumDocument.parse(lf))
    }

    @Test func theBodyIsTheStandingBulkRule() throws {
        // Paragraph = block, spacing stored as k−1 — `bulkSegments` exactly.
        let body = "One.\n\nTwo.\n\n\nThree.\nFour."
        let document = try VariorumDocument.parse(body)
        #expect(document.blocks.map(\.text)
            == SegmentationRules.bulkSegments(body, mode: .paragraph))
    }

    @Test func aSurfaceBlocksInternalNewlineImportsAsABlockBoundary() throws {
        // P-13n-4, RECORDED (not a defect): multi-line SURFACE blocks are not
        // expressible in v1 — the body is the bulk rule, every line a block.
        // A take keeps its newlines (pinned above); the surface does not.
        let document = try VariorumDocument.parse("a line\nanother line")
        #expect(document.blocks.map(\.text) == ["a line", "another line"])
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
        // A section at the very start has no paragraph of its own.
        #expect(failure("\(header)\n\ntake: 2\n\nx\n\n\(footer)")
            == .init(.alternatesWithoutParagraph, line: 1))
        // …nor does one right after another section.
        #expect(failure("A\n\n\(header)\n\ntake: 2\n\nx\n\n\(footer)\n\n\(header)\n\ntake: 3\n\ny\n\n\(footer)")
            == .init(.alternatesWithoutParagraph, line: 11))
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
        // Nothing to import: blank, or a header line alone.
        #expect(failure("") == .init(.empty))
        #expect(failure("  \n\n\t\n") == .init(.empty))
        #expect(failure("{t:\"Only a title\"} {#a}") == .init(.empty))
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
