//
//  PDFExportFaceTests.swift
//  VariorumTests
//
//  Phase 13u3, UNIT F (master-plan item 16 — her words: *"the export as pdf
//  is not rendering the markdown formatting you just see the markdown in the
//  text and that should be fixed at some point pre v1 release"*).
//
//  Two halves, deliberately kept in one file so the fence is read beside the
//  face it fences:
//
//  1. **The FACE** — the exported document is built through the app's OWN
//     reading transform (`MarkdownRendering`, core) and the attributed face
//     the paged reader already draws with (`MarkdownReadingFace`). The
//     defect-shaped cell here is `theExportedDocumentShowsNoRawMarkdownSyntax`,
//     which is RED on the shipped exporter (the 11b `attributedDocument`
//     wrapped the body in one system font and drew the characters verbatim).
//  2. **The BYTE-FENCES** — `renderedText`, the `.md` export projections, the
//     callout→blockquote mapping and the fan "Alternates" shape are pinned
//     against GOLDEN strings, because the whole unit is a PROJECTION change
//     on one medium: if a byte of the markdown road moved, these fail.
//

import Dependencies
import Foundation
import PDFKit
import Testing
import VariorumCore
@testable import Variorum

/// A session over a fresh in-memory store with deterministic dependencies
/// (the `ExportFacesTests` world — copied rather than shared so this suite
/// stands on its own).
@MainActor
private func withExportSession<T>(
    _ body: @MainActor (AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 16))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

/// One note's worth of every vocabulary item F-3 names (plus row 84's
/// `_italic_`), as it is STORED — markdown-as-content.
private let vocabularyBody = """
# Chapter One

A paragraph with **bold words**, *italic ones*, _underscored ones_, \
~~a struck phrase~~ and `let code = 1` inline.

## A smaller heading

- first item
- second item
  - a nested one

- [ ] an unchecked task
- [x] a checked task

A [link to somewhere](https://example.com/page) at the end.
"""

/// The attributes at the first character of `needle` in `string` — nil when
/// the needle is absent (which the cells assert about separately, so a miss
/// reads as a clear failure rather than a crash).
private func attributes(
    for needle: String, in string: NSAttributedString
) -> [NSAttributedString.Key: Any]? {
    let range = (string.string as NSString).range(of: needle)
    guard range.location != NSNotFound else { return nil }
    return string.attributes(at: range.location, effectiveRange: nil)
}

private func font(for needle: String, in string: NSAttributedString) -> NSFont? {
    attributes(for: needle, in: string)?[.font] as? NSFont
}

@MainActor
@Suite("PDF export renders formatting (13u3 UNIT F, item 16)")
struct PDFExportFaceTests {
    // MARK: - The face

    /// **THE RED-ON-OLD CELL.** The shipped exporter appended the body
    /// verbatim under one system font, so every marker she typed was drawn
    /// on the page. Nothing in the exported document's own string may be
    /// syntax any more.
    @Test func theExportedDocumentShowsNoRawMarkdownSyntax() {
        let document = PDFExporter.attributedDocument(
            title: "My Note", body: vocabularyBody)
        let text = document.string

        // The words survive, all of them.
        for word in [
            "My Note", "Chapter One", "bold words", "italic ones", "underscored ones",
            "a struck phrase", "let code = 1", "A smaller heading", "first item",
            "a nested one", "an unchecked task", "a checked task", "link to somewhere",
        ] {
            #expect(text.contains(word), "the words must survive: \(word)")
        }

        // The syntax does not.
        for syntax in ["**", "~~", "`", "](", "# ", "## ", "- ", "[ ]", "[x]", "_underscored"] {
            #expect(!text.contains(syntax), "raw markdown leaked into the PDF: \(syntax)")
        }
        // A link's target is the affordance's, never the page's words.
        #expect(!text.contains("https://example.com/page"))

        // The substituted leads the ONE transform decides (never a second
        // vocabulary here): a bullet glyph and the two boxes.
        #expect(text.contains("\(MarkdownRendering.bulletLead)first item"))
        #expect(text.contains(MarkdownRendering.uncheckedBox))
        #expect(text.contains(MarkdownRendering.checkedBox))
    }

    /// The runs carry the app's own face: headings are SIZES (F-3), bold and
    /// italic are traits, code is monospaced, a struck phrase is struck, a
    /// link's text is underlined.
    @Test func theExportedRunsCarryTheAppsOwnFace() throws {
        let document = PDFExporter.attributedDocument(title: nil, body: vocabularyBody)
        let body = PDFExporter.bodyFont

        let heading = try #require(font(for: "Chapter One", in: document))
        #expect(heading.pointSize > body.pointSize)
        #expect(heading.fontDescriptor.symbolicTraits.contains(.bold))

        let smaller = try #require(font(for: "A smaller heading", in: document))
        #expect(smaller.pointSize > body.pointSize)
        #expect(smaller.pointSize < heading.pointSize)

        let bold = try #require(font(for: "bold words", in: document))
        #expect(bold.fontDescriptor.symbolicTraits.contains(.bold))
        let italic = try #require(font(for: "italic ones", in: document))
        #expect(italic.fontDescriptor.symbolicTraits.contains(.italic))
        let underscored = try #require(font(for: "underscored ones", in: document))
        #expect(underscored.fontDescriptor.symbolicTraits.contains(.italic))
        let code = try #require(font(for: "let code = 1", in: document))
        #expect(code.fontDescriptor.symbolicTraits.contains(.monoSpace))

        let struck = try #require(attributes(for: "a struck phrase", in: document))
        #expect(struck[.strikethroughStyle] as? Int == NSUnderlineStyle.single.rawValue)

        let link = try #require(attributes(for: "link to somewhere", in: document))
        #expect(link[.underlineStyle] as? Int == NSUnderlineStyle.single.rawValue)

        // An ordinary paragraph stays the body font — the face writes only
        // what the transform named.
        #expect(font(for: "A paragraph with", in: document) == body)
    }

    /// A list line is a HANGING INDENT (the paged reader's own rule), and a
    /// nested item sits one step further in. Paragraph facts, not glyphs.
    @Test func listLinesIndentAndNestExactlyAsTheReadingPageDoes() throws {
        let document = PDFExporter.attributedDocument(title: nil, body: vocabularyBody)
        let flat = try #require(
            attributes(for: "first item", in: document)?[.paragraphStyle] as? NSParagraphStyle)
        let nested = try #require(
            attributes(for: "a nested one", in: document)?[.paragraphStyle] as? NSParagraphStyle)
        let prose = try #require(attributes(for: "A paragraph with", in: document))

        #expect(flat.firstLineHeadIndent > 0)
        #expect(flat.headIndent > flat.firstLineHeadIndent)
        #expect(nested.firstLineHeadIndent > flat.firstLineHeadIndent)
        // Prose is untouched: no paragraph style was written for it.
        #expect(prose[.paragraphStyle] == nil)
    }

    /// **Paper, not a screen — and the pin is an ABSENCE.** The exported
    /// document carries no colour attribute anywhere, which is the strongest
    /// form of appearance-independence there is: nothing in it can resolve
    /// against whatever appearance the app wore when the panel was dismissed,
    /// so a PDF exported in dark mode cannot arrive white on white paper.
    /// (A literal black would dodge that too — and trip 18j's grep pin,
    /// correctly. The answer is no colour, not a different literal.)
    ///
    /// A link therefore prints as that ink under a RULE, and an inline-code
    /// run is monospaced with no chip: a colour on paper is 13m's
    /// typographic call, not this unit's.
    @Test func theExportedDocumentIsPaperAndNotAScreen() throws {
        let document = PDFExporter.attributedDocument(title: "My Note", body: vocabularyBody)
        var colourful: [String] = []
        document.enumerateAttributes(
            in: NSRange(location: 0, length: document.length), options: []
        ) { attributes, range, _ in
            for key in [
                NSAttributedString.Key.foregroundColor, .backgroundColor,
                .underlineColor, .strikethroughColor,
            ] where attributes[key] != nil {
                colourful.append("\(key.rawValue) at \(range)")
            }
        }
        #expect(colourful.isEmpty, "the page must write no colour: \(colourful)")

        // The affordances that do NOT need a colour are still written.
        let link = try #require(attributes(for: "link to somewhere", in: document))
        #expect(link[.underlineStyle] as? Int == NSUnderlineStyle.single.rawValue)
        let struck = try #require(attributes(for: "a struck phrase", in: document))
        #expect(struck[.strikethroughStyle] as? Int == NSUnderlineStyle.single.rawValue)
    }

    /// The whole road end to end: real PDF bytes whose extracted text carries
    /// the words and none of the syntax.
    @Test func theRenderedPDFItselfCarriesTheWordsAndNoneOfTheSyntax() throws {
        let data = PDFExporter.pdfData(title: "My Note", body: vocabularyBody)
        #expect(data.starts(with: Array("%PDF".utf8)))
        let pdf = try #require(PDFDocument(data: data))
        let text = pdf.string ?? ""
        #expect(text.contains("Chapter One"))
        #expect(text.contains("bold words"))
        #expect(!text.contains("**"))
        #expect(!text.contains("~~"))
        #expect(!text.contains("]("))
    }

    /// The fan's ratified "Alternates" section is prose, not markdown — so it
    /// reaches the page exactly as it reaches the `.md` file (the shape is
    /// untouched; this cell says so on the PDF's own side).
    @Test func theAlternatesSectionReachesThePageUnchanged() {
        // The ratified 11b shape, verbatim (core's `alternatesSection` builds
        // it; the byte-fence cell below drives that builder for real through
        // `exportPost(includeVariants:)`).
        let section = """
            --- Alternates for this block ---

            take: "morning"

            The morning take.

            take: 2

            The unlabeled one.

            --- end alternates ---
            """
        let document = PDFExporter.attributedDocument(title: nil, body: section)
        let text = document.string
        #expect(text.contains("--- Alternates for this block ---"))
        #expect(text.contains("take: \"morning\""))
        #expect(text.contains("take: 2"))
        #expect(text.contains("The morning take."))
        #expect(text.contains("--- end alternates ---"))
    }

    // MARK: - ONE face, not two (the hoist's own drift guards)

    /// **The anti-drift pin on the collapse.** A heading's size was written
    /// out twice in this app — once in the editing face, once privately
    /// inside `PageComposer` — with the same 1.6/1.35/1.15 scales by
    /// coincidence. The reading face now CALLS the editing face's function,
    /// and this holds the two equal at every level and both base fonts.
    @Test func theReadingFacesHeadingIsTheEditingFacesHeading() throws {
        for base in [PDFExporter.bodyFont, PageTypography.standard.body] {
            let style = MarkdownReadingFace.Style(
                body: base, lineSpacing: 0, ink: .black, link: .black, codeTint: nil)
            for level in 1...3 {
                let hashes = String(repeating: "#", count: level)
                let document = MarkdownReadingFace.attributed("\(hashes) Title", style: style)
                let drawn = try #require(font(for: "Title", in: document))
                #expect(drawn == MarkdownFace.headingFont(level: level, base: base))
            }
        }
    }

    /// **The hoist's own guard.** The page and the PDF must make the SAME
    /// face decisions over the same text — different fonts and colours, one
    /// set of rules. Compared by trait/size RELATION rather than by identity,
    /// because the two media genuinely differ in base font and ink.
    @Test func thePageAndThePDFMakeTheSameFaceDecisions() throws {
        let source = "# Heading\n\nA **bold** and `code` line.\n\n- an item"
        let page = PageComposer.compose(
            slots: [Queries.RenderedBlock(
                blockID: "a", placementID: "pa", position: "a", variantID: "va",
                text: source, activeVariantCount: 1, liveVariantCount: 1,
                commentCount: 0, variantLocked: false)],
            presentations: [:], title: nil, chapter: nil,
            typography: .standard, ink: .black, chapterInk: .gray).attributed
        let paper = MarkdownReadingFace.attributed(source, style: PDFExporter.paperStyle)

        // The same display string — the ONE transform decides it.
        #expect(page.string == paper.string)
        for (document, base) in [
            (page, PageTypography.standard.body), (paper, PDFExporter.bodyFont),
        ] {
            let heading = try #require(font(for: "Heading", in: document))
            #expect(heading.pointSize > base.pointSize)
            #expect(heading.fontDescriptor.symbolicTraits.contains(.bold))
            let bold = try #require(font(for: "bold", in: document))
            #expect(bold.fontDescriptor.symbolicTraits.contains(.bold))
            let code = try #require(font(for: "code", in: document))
            #expect(code.fontDescriptor.symbolicTraits.contains(.monoSpace))
            let item = try #require(
                attributes(for: "an item", in: document)?[.paragraphStyle] as? NSParagraphStyle)
            #expect(item.firstLineHeadIndent > 0)
        }
    }

    // MARK: - The byte-fences (the unit's whole promise: ONE medium changed)

    /// **THE `.md` FENCE.** Every markdown projection the export doors reach,
    /// over a fixture corpus carrying markdown, a callout and a fan, pinned
    /// byte-for-byte. The PDF is a second READING of these strings and may
    /// never become a second writing of them.
    @Test func everyMarkdownProjectionIsByteIdentical() async throws {
        try await withExportSession { session in
            let post = try session.operations.createPost(title: "Fixture")
            _ = try session.operations.newBlock(
                in: post.id, text: "# Heading\n\nSome **bold** prose.")
            let callout = try session.operations.newBlock(
                in: post.id, text: "A framed line.\n\nAnd a second.")
            try session.operations.setBlockPresentation(
                callout.block.id, BlockPresentation(color: "blue", emoji: "💡"))
            let fanned = try session.operations.newBlock(in: post.id, text: "The shown take.")
            _ = try session.operations.branchVariant(
                fanned.block.id, from: fanned.variant.id)

            let rendered = try await session.database.read {
                try Queries.renderedText($0, containerID: post.id)
            }
            let plain = try await session.database.read {
                try Queries.exportPost($0, postID: post.id)
            }
            let withTakes = try await session.database.read {
                try Queries.exportPost($0, postID: post.id, includeVariants: true)
            }

            // `renderedText` — the ONE join brain, plain prose, no mapping.
            #expect(rendered == """
                # Heading

                Some **bold** prose.

                A framed line.

                And a second.

                The shown take.
                """)
            // The `.md` export — the callout's blockquote mapping, markers
            // and all, exactly as it has shipped since Phase 13 C1.
            #expect(plain == """
                # Heading

                Some **bold** prose.

                > 💡 A framed line.
                >
                > And a second.

                The shown take.
                """)
            // With takes — the ratified Alternates section in place.
            // 13n-b U3 (justified edit, the ruled flip — R-13nb-26 (a) and
            // AF-10's export map): this fixture's first block holds a blank
            // line, so the TAKES-carrying export speaks format v2 — `{v:2}`
            // leads and `--- next block ---` joins the blocks, so the file
            // re-imports whole. The plain export above, and therefore the
            // PDF (which reads the plain projection), are byte-unchanged:
            // her refinement — the marker never reaches plain markdown.
            #expect(withTakes == """
                {v:2}

                # Heading

                Some **bold** prose.

                --- next block ---

                > 💡 A framed line.
                >
                > And a second.

                --- next block ---

                The shown take.

                --- Alternates for this block ---

                take: 1

                The shown take.

                --- end alternates ---
                """)
        }
    }

    /// The PDF door hands the exporter EXACTLY the `.md` projection — the
    /// same string the Markdown door writes, read once more for a different
    /// medium. (The fence's other end: nothing app-side pre-chews the body.)
    @Test func thePDFDoorExportsTheSameProjectionTheMarkdownDoorWrites() async throws {
        try await withExportSession { session in
            let post = try session.operations.createPost(title: "Same Body")
            _ = try session.operations.newBlock(
                in: post.id, text: "## A heading\n\nWith **emphasis**.")
            let exporter = ExportModel(session: session)
            let markdown = try #require(await exporter.markdown(forPost: post.id))
            let pdf = try #require(await exporter.pdfData(forPost: post.id))

            // The markdown file still carries the syntax…
            #expect(markdown.contains("## A heading"))
            #expect(markdown.contains("**emphasis**"))
            // …and the PDF built from that same string carries none of it.
            let document = try #require(PDFDocument(data: pdf))
            let text = document.string ?? ""
            #expect(text.contains("A heading"))
            #expect(text.contains("emphasis"))
            #expect(!text.contains("**"))
        }
    }
}
