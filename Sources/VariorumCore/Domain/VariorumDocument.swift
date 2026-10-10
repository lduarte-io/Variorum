import Foundation

/// **THE VARIORUM DOCUMENT FORMAT — Level 0 of the MCP door** (13n-a; the
/// sitting record's R-13n-8, her pick: *"the import format IS the export
/// format; full fidelity lives at 13m"*).
///
/// A document is prose + fan + tags, and nothing else:
///
/// ```
/// {t:"o ladrão de raios — ch 1"} {#percy/pt-en}
///
/// Eu não pedi para herdar o observatório.
///
/// --- Alternates for this block ---
///
/// take: "english"
///
/// Honestly, I never asked for the observatory.
///
/// --- end alternates ---
///
/// Cuidar de um observatório dá trabalho.
/// ```
///
/// - **The body is the shipped fan export** (`Queries.exportPost(…,
///   includeVariants: true)` — the 2026-07-25 intake was one): each block's
///   chosen take in place, its other live takes in the `Alternates` section
///   that follows it (`take: "label"`, unlabeled ones numbered `take: N`),
///   everything joined by the ONE join brain (`Queries.joinRenderedTexts`).
///   The export IS this file's client since 13n-a — `serializeBody` is the
///   one serializer, so the format and the export cannot drift.
/// - **The header line** is the capture microsyntax (`CaptureTokens`, the
///   app's capture rule moved into core): `{t:"…"}` the title, `{#tag/path}`
///   each tag. It is read on the document's FIRST NON-BLANK LINE only, and
///   only when that line is TOKENS ALONE (ladder F9); tokens anywhere else —
///   prose beside them on that line included — are text.
/// - **The body parses as the exact inverse of the join** (R-ARCH-13na-1,
///   the architect's ruling on FORK-A/B — superseding the plan's "standing
///   bulk rule" letter FOR THE FORMAT ONLY; paste and every other entry road
///   keep `SegmentationRules.bulkSegments`): a BLANK line separates blocks;
///   a SINGLE newline is content inside its block (so a hard-wrapped
///   paragraph is one block, as Markdown reads it); k ≥ 3 newlines between
///   two pieces store k − 1 on the first as trailing spacing, and k = 2 is
///   the separator alone (an Alternates section counts as a piece). The
///   document's leading and trailing blank runs are edges and drop. A take's
///   own text is kept EXACTLY, internal newlines and blank lines included
///   (only the one blank line the serializer puts on each side of a take's
///   text is the section's).
/// - **What round-trips, exactly (ladder round 1, F5 — the claim stated to
///   its domain):** export → re-import mints the SAME block texts (each
///   block's chosen take), the same fan MEMBERSHIP, the ALTERNATES' texts in
///   fan order with their labels, and the same stored spacing. The v1 format
///   does NOT carry the CHOSEN take's label, its place in the fan, or a
///   chosen ≠ default split: a re-imported block's chosen take is always
///   FIRST in its fan, UNLABELED, and its default — so a block whose chosen
///   take was labeled, or not first, comes back with that label dropped and
///   the chosen take moved to the front (her picked-language PT/EN notes are
///   exactly this). Nor do locked or archived states ride (archived takes
///   are not exported at all). And three byte-level corners: the join's one
///   undecidable spacing (a block storing exactly ONE trailing newline
///   exports like an unspaced one) reads unspaced; a blank line INSIDE a
///   surface block reads as a boundary (P-13n-4); and a blank-chosen fanned
///   block right after a FANLESS paragraph exports the very bytes of that
///   paragraph's own fan, so its takes re-import onto the paragraph above.
///   And BLANK content does not ride (ladder round 2, R2-2): a blank
///   alternate take and an empty block are neither exported nor re-imported
///   — a fan [A, ""] comes back [A], an empty block between two others
///   leaves only its spacing. Within that domain rows round-trip
///   (`DocumentImportOperationTests`'s row pins); the full-fidelity form is
///   13m's edition.
/// - **Parsing is fail-honest:** a malformed Alternates section refuses the
///   whole document with the line it found the problem on — never a silent
///   partial import (`Failure`). **Any export re-imports** — never refused,
///   every NON-BLANK take arriving (R-ARCH-13na-2; R2-2 above): a section with no paragraph above
///   it is what the export writes for a fanned block whose chosen take is
///   blank, and reads as that block — an empty chosen take with the
///   section's takes (except after a fanless paragraph, the corner above);
///   a header line alone is a stub, an empty note (ladder F4).
///
/// What does NOT ride the format, by her ruling: commits, book settings,
/// block names, comments, callout frames (an export maps a callout to a
/// blockquote; a blockquote imports as text), archived takes, the chosen
/// take's label and fan place (above). The full-fidelity form is 13m's.
///
/// **FORMAT v2 — THE BOUNDARY MARKER** (13n-b U3; her R-13nb-26 (a) —
/// *"separator line, both forms"* — and its refinement that the PLAIN export
/// never carries it; the design AF-10's): P-13n-4's limit, closed. A note
/// holding a MULTI-PARAGRAPH block — a block whose in-place text carries a
/// blank line with text after it — serializes in MARKER MODE: a `{v:2}`
/// version token leads the header line, and every block boundary is the
/// line `--- next block ---` with one blank line on each side, so a blank
/// line inside a block is CONTENT. Every other note serializes exactly as
/// v1 did, byte for byte — no token, no marker (`needsBoundaryMarkers`).
/// Parsing keys on the token: absent (or `{v:1}`) reads v1 exactly as
/// before; `{v:2}` reads marker mode; any other number refuses, naming its
/// line. In marker mode a block's text rides VERBATIM (its internal and
/// leading blank lines, its stored spacing; the document's trailing blank
/// run is the edge, as in v1), the Alternates section is unchanged, a block
/// text line that IS the marker gains one backslash on the way out and
/// loses one on the way in (`\--- next block ---` stacks exactly), and the
/// reading is lenient for hand-authoring (markers without blank lines
/// around them, text after a section before the next marker starting a new
/// block, an empty piece making no block). The marker lives ONLY in the
/// takes-carrying forms: `serialize` (Copy full text, `read_note`) and
/// `serializeTakesExport` (the "Markdown with takes" export, led by
/// `{v:2}` alone so the file re-imports whole); the plain export never
/// passes through here in marker mode. Recorded, unchanged from v1: a block
/// text line that IS an Alternates marker is still read as one.
public enum VariorumDocument {
    // MARK: - The model

    /// One take in a block's Alternates section.
    public struct Take: Equatable, Sendable {
        /// `take: "label"` — nil for a numbered (`take: N`) take.
        public var label: String?
        public var text: String

        public init(label: String? = nil, text: String) {
            self.label = label
            self.text = text
        }
    }

    /// One block: its in-place text (the chosen take) and the rest of its
    /// fan, in fan order.
    public struct Block: Equatable, Sendable {
        public var text: String
        public var alternates: [Take]

        public init(text: String, alternates: [Take] = []) {
            self.text = text
            self.alternates = alternates
        }
    }

    /// One note.
    public struct Document: Equatable, Sendable {
        /// The header's `{t:"…"}` (nil: the importer names it by its file).
        public var title: String?
        /// The header's `{#…}` paths, in the order they appeared.
        public var tagPaths: [String]
        public var blocks: [Block]

        public init(title: String? = nil, tagPaths: [String] = [], blocks: [Block]) {
            self.title = title
            self.tagPaths = tagPaths
            self.blocks = blocks
        }

        /// How many takes ride the Alternates sections (the chosen takes
        /// not counted).
        public var alternateCount: Int {
            blocks.reduce(0) { $0 + $1.alternates.count }
        }
    }

    /// A document with the name a FILE gives it — what a folder import and a
    /// single-file import hand the operations layer.
    public struct NamedDocument: Equatable, Sendable {
        /// The filename without its extension — the title when the header
        /// names none.
        public var fallbackTitle: String
        public var document: Document

        public init(fallbackTitle: String, document: Document) {
            self.fallbackTitle = fallbackTitle
            self.document = document
        }
    }

    /// A FOLDER read as a book (`VariorumDocumentFolder.plan`): subfolders
    /// are chapters, filename order is book order, folder names are names.
    public struct Book: Equatable, Sendable {
        public struct Chapter: Equatable, Sendable {
            public var name: String
            public var notes: [NamedDocument]

            public init(name: String, notes: [NamedDocument]) {
                self.name = name
                self.notes = notes
            }
        }

        public var name: String
        /// In chapter order (digit-aware a–z by folder name).
        public var chapters: [Chapter]
        /// The folder's own top-level files — members with no chapter.
        public var unfiled: [NamedDocument]

        public init(name: String, chapters: [Chapter], unfiled: [NamedDocument]) {
            self.name = name
            self.chapters = chapters
            self.unfiled = unfiled
        }

        public var noteCount: Int {
            unfiled.count + chapters.reduce(0) { $0 + $1.notes.count }
        }
    }

    // MARK: - The markers (ONE spelling, read by the serializer AND the parser)

    public static let alternatesHeader = "--- Alternates for this block ---"
    public static let alternatesFooter = "--- end alternates ---"
    /// v2's block boundary (AF-10 — the format's own marker idiom; CommonMark
    /// renders it as a plain line, never a rule or a heading).
    public static let blockMarker = "--- next block ---"
    /// The marker-mode format version, and its header token (parser-only —
    /// never a capture token).
    public static let markedVersion = 2
    public static let versionToken = "{v:\(markedVersion)}"

    /// A take's marker line: `take: "label"` where a label exists, else
    /// `take: N` — N the take's 1-based ordinal within the section.
    public static func takeMarker(label: String?, ordinal: Int) -> String {
        if let label, !label.isEmpty {
            return "take: \"\(label)\""
        }
        return "take: \(ordinal)"
    }

    // MARK: - Serialize

    /// THE Alternates section (the ratified 11b shape): the header, each
    /// take's marker then its text, the footer — every line joined by one
    /// blank line. Blank takes contribute nothing (the export's skip);
    /// unlabeled takes number by their place among the takes that DO print.
    public static func alternatesSection(_ takes: [Take]) -> String {
        var lines: [String] = [alternatesHeader]
        for (index, take) in takes.filter({ !$0.text.isEmpty }).enumerated() {
            lines.append(takeMarker(label: take.label, ordinal: index + 1))
            lines.append(take.text)
        }
        lines.append(alternatesFooter)
        return lines.joined(separator: "\n\n")
    }

    /// The header line: `{t:"title"}` then each `{#path}`, space-separated;
    /// nil when there is nothing to say. Only tokens the grammar READS BACK
    /// are written (ladder round 2, R2-3): a title or path carrying the
    /// grammar's own bytes (a `}`, or `"}` inside a title) would turn the
    /// whole line into body on re-import — losing every other token with it
    /// under the F9 tokens-alone rule. Such a value is omitted (the format
    /// cannot carry it — a recorded limit; the full-fidelity road is 13m's
    /// edition) and the rest of the header survives.
    public static func headerLine(title: String?, tagPaths: [String]) -> String? {
        var tokens: [String] = []
        if let title, !title.isEmpty {
            let token = "{t:\"\(title)\"}"
            let read = CaptureTokens.readLine(token)
            if read.title == title, read.tagPaths.isEmpty,
                read.text.allSatisfy(CaptureTokens.isHorizontal) {
                tokens.append(token)
            }
        }
        for path in tagPaths where !path.isEmpty {
            let token = "{#\(path)}"
            let read = CaptureTokens.readLine(token)
            if read.tagPaths == [path], read.title == nil,
                read.text.allSatisfy(CaptureTokens.isHorizontal) {
                tokens.append(token)
            }
        }
        guard !tokens.isEmpty else { return nil }
        // The JOINED line must read back whole too (tokens alone) — a guard
        // against token interaction; a line that would read as body is no
        // header at all.
        let line = tokens.joined(separator: " ")
        let read = CaptureTokens.readLine(line)
        guard read.foundToken, read.text.allSatisfy(CaptureTokens.isHorizontal) else { return nil }
        return line
    }

    /// **THE ONE v1 SERIALIZER of a body** — `Queries.exportPost`'s, too
    /// (the plain export's callout road always; the takes export through
    /// `serializeTakesExport` when no block needs marker mode). Each
    /// block contributes its in-place text when it has any (a blank chosen
    /// take skips, as ever) and then its Alternates section when it carries
    /// a non-blank take; the pieces join through the one join brain.
    public static func serializeBody(_ blocks: [Block]) -> String {
        var pieces: [String] = []
        for block in blocks {
            if !block.text.isEmpty {
                pieces.append(block.text)
            }
            if block.alternates.contains(where: { !$0.text.isEmpty }) {
                pieces.append(alternatesSection(block.alternates))
            }
        }
        return Queries.joinRenderedTexts(pieces)
    }

    /// A whole document: the header line (when it has anything to say), one
    /// blank line, the body — in MARKER MODE when a block needs it (v2: the
    /// `{v:2}` token leads the header, the boundary marker joins the
    /// blocks), else v1 byte for byte.
    public static func serialize(_ document: Document) -> String {
        if needsBoundaryMarkers(document.blocks) {
            return markedHeaderLine(title: document.title, tagPaths: document.tagPaths)
                + "\n\n" + serializeMarkedBody(document.blocks)
        }
        let body = serializeBody(document.blocks)
        guard let header = headerLine(title: document.title, tagPaths: document.tagPaths)
        else { return body }
        return body.isEmpty ? header : header + "\n\n" + body
    }

    // MARK: - Format v2: the boundary marker (13n-b U3 — AF-10)

    /// **Does this note need marker mode?** True iff some block's in-place
    /// text carries a BLANK (whitespace-only) line with non-blank text after
    /// it — an internal paragraph break, or a leading blank line: every shape
    /// v1's reading would split or shift. Trailing spacing alone does not
    /// (v1 carries it); takes' texts never do (the section keeps them).
    public static func needsBoundaryMarkers(_ blocks: [Block]) -> Bool {
        blocks.contains { block in
            var sawBlank = false
            for line in block.text.split(separator: "\n", omittingEmptySubsequences: false) {
                if line.allSatisfy(\.isWhitespace) {
                    sawBlank = true
                } else if sawBlank {
                    return true
                }
            }
            return false
        }
    }

    /// The marker-mode header: the version token first, then v1's tokens.
    public static func markedHeaderLine(title: String?, tagPaths: [String]) -> String {
        ([versionToken] + [headerLine(title: title, tagPaths: tagPaths)].compactMap { $0 })
            .joined(separator: " ")
    }

    /// **The marker-mode body.** Each block is one piece — its text verbatim
    /// (marker lines escaped), then, when it carries a non-blank take, one
    /// blank line and today's Alternates section (a blank text contributes
    /// only its section; a blank block with no take contributes nothing, v1's
    /// skip) — and the pieces join through the boundary marker.
    public static func serializeMarkedBody(_ blocks: [Block]) -> String {
        var pieces: [String] = []
        for block in blocks {
            let hasTakes = block.alternates.contains { !$0.text.isEmpty }
            switch (block.text.isEmpty, hasTakes) {
            case (true, false): continue
            case (true, true): pieces.append(alternatesSection(block.alternates))
            case (false, false): pieces.append(escapedBlockText(block.text))
            case (false, true):
                pieces.append(escapedBlockText(block.text) + "\n\n" + alternatesSection(block.alternates))
            }
        }
        return pieces.joined(separator: "\n\n" + blockMarker + "\n\n")
    }

    /// **The takes-carrying export's text** (`Queries.exportPost(…,
    /// includeVariants: true)` — "Markdown with takes"): v1's body exactly,
    /// or, in marker mode, the whole v2 form led by `{v:2}` alone (the export
    /// never carried a title or tags) so the file re-imports whole. The PLAIN
    /// export never comes here (her R-13nb-26 (a) refinement).
    public static func serializeTakesExport(_ blocks: [Block]) -> String {
        guard needsBoundaryMarkers(blocks) else { return serializeBody(blocks) }
        return serialize(Document(title: nil, tagPaths: [], blocks: blocks))
    }

    /// A block text line that IS the marker (after any backslashes) gains one
    /// backslash before its first non-blank character — exact, never a
    /// refusal: `\\--- next block ---` → `\\\--- next block ---`.
    static func escapedBlockText(_ text: String) -> String {
        text.split(separator: "\n", omittingEmptySubsequences: false)
            .map { stackBackslash(String($0), by: +1) }
            .joined(separator: "\n")
    }

    /// One backslash more (+1) or fewer (−1) before a marker line's first
    /// non-blank character; any other line passes through untouched.
    static func stackBackslash(_ line: String, by step: Int) -> String {
        let body = trimmed(line)
        let slashes = body.prefix { $0 == "\\" }.count
        guard body.dropFirst(slashes) == blockMarker, step > 0 || slashes > 0,
              let start = line.firstIndex(where: { !$0.isWhitespace })
        else { return line }
        var out = line
        if step > 0 {
            out.insert("\\", at: start)
        } else {
            out.remove(at: start)
        }
        return out
    }

    // MARK: - Parse

    /// Why a document refused — and WHERE. Every refusal names its line
    /// (1-based) where one exists, and the file when a folder import read it.
    public struct Failure: Error, Equatable, Sendable {
        public enum Reason: Equatable, Sendable {
            /// A BLANK document — no header line and no block. (A header line
            /// alone is a stub, an empty note — ladder F4; and inside a
            /// folder a blank file is a stub too, `VariorumDocumentFolder`.)
            case empty
            /// An Alternates section with no paragraph of its own above it —
            /// at the document's start, or right after another section — AND
            /// no take in it either: nothing to make a block of. (WITH a take
            /// it is the export of a blank chosen take and reads as one —
            /// R-ARCH-13na-2.)
            case alternatesWithoutParagraph
            /// An Alternates section that never reaches its end marker (the
            /// line is the section's header).
            case unterminatedAlternates
            /// Text inside a section before its first `take:` line.
            case textBeforeFirstTake
            /// A second section opened before the one at `openedAt` ended.
            case alternatesInsideAlternates(openedAt: Int)
            /// An end marker with no section open.
            case endWithoutAlternates
            /// A folder with nothing importable in it (folder imports only).
            case noImportableFiles
            /// A chapter folder (a first-level subfolder) whose name is blank
            /// once trimmed — a chapter needs a name (folder imports only;
            /// ladder F6: refused in the plan, before anything is minted).
            case blankChapterName
            /// A `{v:N}` header naming a format version this build cannot
            /// read (13n-b U3 — written by a newer Variorum).
            case unsupportedVersion(Int)
        }

        public var reason: Reason
        /// 1-based, in the file as read (line endings normalized — a CRLF
        /// file numbers its lines exactly as an editor shows them).
        public var line: Int?
        /// The folder-relative path, for a folder import.
        public var file: String?

        public init(_ reason: Reason, line: Int? = nil, file: String? = nil) {
            self.reason = reason
            self.line = line
            self.file = file
        }
    }

    /// Reads a document. Throws `Failure` — never a partial document.
    public static func parse(_ raw: String) throws(Failure) -> Document {
        var text = SegmentationRules.normalizedLineEndings(raw)
        // A byte-order mark from a Windows editor is not her first letter.
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        // THE HEADER LINE — the first non-blank line, read by the capture
        // grammar, and a header ONLY when it is TOKENS ALONE (ladder F9):
        // token removal must leave nothing but whitespace. A first line
        // carrying prose beside a literal brace token is BODY, untouched — a
        // note she never named or tagged copies with no header, so its first
        // paragraph is this line, and a note about the capture syntax must
        // come back as written. The header line's place stays as a blank
        // line so every later line keeps its number.
        var title: String?
        var tagPaths: [String] = []
        if let first = lines.firstIndex(where: { !isBlank($0) }),
           let header = try readHeader(lines[first], lineNumber: first + 1) {
            title = header.title
            tagPaths = header.tagPaths
            lines[first] = ""
            // v2 (13n-b U3): the version token is the parser's key.
            if header.version == markedVersion {
                return try parseMarked(lines, from: first + 1, title: title, tagPaths: tagPaths)
            }
        }

        var blocks: [Block] = []
        var chunk: [String] = []
        var index = 0
        while index < lines.count {
            let line = lines[index]
            let marker = trimmed(line)
            if marker == alternatesFooter {
                throw Failure(.endWithoutAlternates, line: index + 1)
            }
            guard marker == alternatesHeader else {
                chunk.append(line)
                index += 1
                continue
            }

            // A section: the paragraphs above it become blocks first, and the
            // section belongs to the LAST of them. The blank lines between
            // that paragraph and the header are spacing exactly as between
            // two blocks — the section stands as the join's next piece. With
            // NO paragraph above it, the section is its own block's (below).
            let headerLine = index + 1
            let above = paragraphs(chunk, beforeSection: true)
            blocks.append(contentsOf: above.map { Block(text: $0) })
            chunk = []

            let section = try readSection(lines, from: index + 1, headerLine: headerLine)
            index = section.next
            // Empty takes skip — the export's own rule, mirrored.
            let kept = section.takes.filter { !$0.text.isEmpty }
            if above.isEmpty {
                // NO PARAGRAPH ABOVE (R-ARCH-13na-2, the architect's ruling on
                // FORK-C): exactly what the export writes for a fanned block
                // whose CHOSEN take is blank (the blank chosen skips, its
                // takes are her work) — so it is that block: an empty chosen
                // take, the section's takes at the fan's end. So any export
                // re-imports (never refused, every take arriving — the exact
                // round-trip domain is the type's doc comment, ladder F5). A
                // section with no paragraph AND no take is nothing the export
                // writes — it still refuses.
                guard !kept.isEmpty else {
                    throw Failure(.alternatesWithoutParagraph, line: headerLine)
                }
                blocks.append(Block(text: "", alternates: kept))
            } else {
                blocks[blocks.count - 1].alternates.append(contentsOf: kept)
            }
        }
        // The tail's trailing blank lines are an edge run: they drop.
        blocks.append(contentsOf: paragraphs(chunk, beforeSection: false).map { Block(text: $0) })

        // A HEADER with no body is a stub — an empty note (ladder F4, option
        // (b), PROVISIONAL): exactly what Copy for AI writes for a named or
        // tagged note with no text yet, so it re-imports as that note. Only a
        // BLANK document — no header, no block — has nothing to import.
        guard !blocks.isEmpty || title != nil || !tagPaths.isEmpty else { throw Failure(.empty) }
        return Document(title: title, tagPaths: tagPaths, blocks: blocks)
    }

    // MARK: - Internals

    /// **The header line, read** — a header ONLY when it is tokens alone
    /// (ladder F9). v2 (13n-b U3): `{v:N}` tokens are taken out FIRST (the
    /// version is the parser's own token, never a capture token); what
    /// remains must be tokens alone, or nothing at all (a version-only
    /// header). A line with no version token reads exactly as v1 read it. A
    /// version this build cannot read refuses, naming the line — but only on
    /// a line that IS a header (prose beside a `{v:…}` is body, untouched).
    private static func readHeader(
        _ line: String, lineNumber: Int
    ) throws(Failure) -> (title: String?, tagPaths: [String], version: Int)? {
        let (remainder, versions) = takingVersionTokens(line)
        let read = CaptureTokens.readLine(remainder)
        guard let version = versions.first else {
            guard read.foundToken, read.text.allSatisfy(CaptureTokens.isHorizontal) else { return nil }
            return (read.title, read.tagPaths, 1)
        }
        let tokensAlone = read.foundToken
            ? read.text.allSatisfy(CaptureTokens.isHorizontal)
            : remainder.allSatisfy(CaptureTokens.isHorizontal)
        guard tokensAlone else { return nil }
        guard version == 1 || version == markedVersion else {
            throw Failure(.unsupportedVersion(version), line: lineNumber)
        }
        return (read.title, read.tagPaths, version)
    }

    /// The `{v:N}` tokens out of a line (each replaced by a space), and
    /// their numbers in order. Digits only, at most six.
    private static func takingVersionTokens(_ line: String) -> (String, [Int]) {
        guard line.contains("{v:") else { return (line, []) }
        var out = ""
        var versions: [Int] = []
        var rest = Substring(line)
        while let open = rest.range(of: "{v:") {
            let digits = rest[open.upperBound...].prefix { $0.isASCIIDigit }
            let afterDigits = rest.index(open.upperBound, offsetBy: digits.count)
            guard !digits.isEmpty, digits.count <= 6, afterDigits < rest.endIndex,
                  rest[afterDigits] == "}", let number = Int(digits)
            else {
                out += rest[..<open.upperBound]
                rest = rest[open.upperBound...]
                continue
            }
            out += rest[..<open.lowerBound] + " "
            versions.append(number)
            rest = rest[rest.index(after: afterDigits)...]
        }
        return (out + rest, versions)
    }

    /// One Alternates section from the line after its header: its takes and
    /// the index just past its footer (shared by both readings — v1's loop
    /// moved here byte-for-byte at 13n-b U3).
    private static func readSection(
        _ lines: [String], from start: Int, headerLine: Int
    ) throws(Failure) -> (takes: [Take], next: Int) {
        var takes: [Take] = []
        var open: (label: String?, content: [String])?
        var index = start
        while index < lines.count {
            let sectionLine = lines[index]
            let sectionMarker = trimmed(sectionLine)
            if sectionMarker == alternatesFooter {
                if let open { takes.append(Take(label: open.label, text: takeText(open.content))) }
                return (takes, index + 1)
            }
            if sectionMarker == alternatesHeader {
                throw Failure(.alternatesInsideAlternates(openedAt: headerLine), line: index + 1)
            }
            if let label = takeLabel(sectionMarker) {
                if let open { takes.append(Take(label: open.label, text: takeText(open.content))) }
                open = (label, [])
            } else if open == nil {
                guard isBlank(sectionLine) else {
                    throw Failure(.textBeforeFirstTake, line: index + 1)
                }
            } else {
                open?.content.append(sectionLine)
            }
            index += 1
        }
        throw Failure(.unterminatedAlternates, line: headerLine)
    }

    /// Where a run of block-text lines starts and ends, for `markedText`.
    private enum RunStart { case afterBoundary, afterSection }
    private enum RunEnd { case boundary, section, document }

    /// **THE MARKER-MODE READING** (v2) from the line after the header: a
    /// marker line (outside a section) ends a block; a section closes the
    /// block above it (or is a blank-chosen block's, v1's rule); the block
    /// text between them rides verbatim (`markedText`).
    private static func parseMarked(
        _ lines: [String], from start: Int, title: String?, tagPaths: [String]
    ) throws(Failure) -> Document {
        var blocks: [Block] = []
        var chunk: [String] = []
        var runStart = RunStart.afterBoundary
        var index = start
        while index < lines.count {
            let line = lines[index]
            let marker = trimmed(line)
            if marker == alternatesFooter {
                throw Failure(.endWithoutAlternates, line: index + 1)
            }
            if marker == blockMarker {
                if let text = markedText(chunk, start: runStart, end: .boundary) {
                    blocks.append(Block(text: text))
                }
                chunk = []
                runStart = .afterBoundary
                index += 1
                continue
            }
            guard marker == alternatesHeader else {
                chunk.append(line)
                index += 1
                continue
            }
            let headerLine = index + 1
            let text = markedText(chunk, start: runStart, end: .section) ?? ""
            chunk = []
            let section = try readSection(lines, from: index + 1, headerLine: headerLine)
            index = section.next
            let kept = section.takes.filter { !$0.text.isEmpty }
            if text.isEmpty, kept.isEmpty {
                throw Failure(.alternatesWithoutParagraph, line: headerLine)
            }
            blocks.append(Block(text: text, alternates: kept))
            runStart = .afterSection
        }
        if let text = markedText(chunk, start: runStart, end: .document) {
            blocks.append(Block(text: text))
        }
        guard !blocks.isEmpty || title != nil || !tagPaths.isEmpty else { throw Failure(.empty) }
        return Document(title: title, tagPaths: tagPaths, blocks: blocks)
    }

    /// A marker-mode block text from its run of lines: the ONE blank line the
    /// serializer writes after a boundary (the header or a marker) and before
    /// a boundary or a section drops; after a section every blank line before
    /// the text drops, and at the document's end its trailing blank run is
    /// the edge (v1's fence). Marker lines unescape. Nil when nothing is left.
    private static func markedText(_ chunk: [String], start: RunStart, end: RunEnd) -> String? {
        var lines = chunk[...]
        switch start {
        case .afterBoundary:
            if let first = lines.first, isBlank(first) { lines = lines.dropFirst() }
        case .afterSection:
            while let first = lines.first, isBlank(first) { lines = lines.dropFirst() }
        }
        switch end {
        case .boundary, .section:
            if let last = lines.last, isBlank(last) { lines = lines.dropLast() }
        case .document:
            while let last = lines.last, isBlank(last) { lines = lines.dropLast() }
        }
        guard !lines.isEmpty else { return nil }
        return lines.map { stackBackslash($0, by: -1) }.joined(separator: "\n")
    }

    /// **THE BODY READING — the exact inverse of the join** (R-ARCH-13na-1)
    /// over a run of body lines: a BLANK line separates blocks; a single
    /// newline is CONTENT, so a block's lines join back with `"\n"` exactly
    /// as written (no trim — the join never trims either); and a run of
    /// b blank lines between two pieces — k = b + 1 newlines — stores
    /// `storedSpacing(blankLines:)` on the preceding one. `beforeSection`
    /// says the run ends at an Alternates header (the join's next piece, so
    /// the last paragraph's run is spacing too); otherwise it ends the
    /// document and its trailing run is an edge. Leading runs are edges.
    private static func paragraphs(_ lines: [String], beforeSection: Bool) -> [String] {
        var runs: [(text: String, blankLinesAfter: Int)] = []
        var open: [String] = []
        for line in lines {
            if isBlank(line) {
                if !open.isEmpty {
                    runs.append((open.joined(separator: "\n"), 0))
                    open = []
                }
                // A blank line counts only after a paragraph (a leading run
                // has no preceding piece).
                if !runs.isEmpty { runs[runs.count - 1].blankLinesAfter += 1 }
                continue
            }
            open.append(line)
        }
        if !open.isEmpty { runs.append((open.joined(separator: "\n"), 0)) }
        return runs.enumerated().map { offset, run in
            let isLast = offset == runs.count - 1
            guard !isLast || beforeSection else { return run.text }
            return run.text + String(repeating: "\n", count: storedSpacing(blankLines: run.blankLinesAfter))
        }
    }

    /// The trailing newlines a block stores for the b blank lines (k = b + 1
    /// newlines) that follow it — `Queries.joinRenderedTexts` inverted. The
    /// join writes `"\n\n"` after a piece with no trailing newline and
    /// `"\n"` after one that has m ≥ 1, so k = 2 when m ≤ 1 and k = m + 1
    /// when m ≥ 2. Hence k ≥ 3 ⇒ m = k − 1 = b, and k = 2 ⇒ m = 0 — the
    /// separator alone. m = 1 is the join's one undecidable value: it writes
    /// the same bytes as m = 0, and the reading takes the unspaced one
    /// (recorded, `VariorumDocumentTests.theJoinsOneUndecidableSpacingReadsUnspaced`).
    private static func storedSpacing(blankLines: Int) -> Int {
        blankLines >= 2 ? blankLines : 0
    }

    /// A take's text: its lines exactly, less the ONE blank line the
    /// serializer puts on each side of it (`marker\n\ntext\n\nnext`). A
    /// compact hand-written section (`take: "x"` directly over its text)
    /// has none to drop.
    private static func takeText(_ content: [String]) -> String {
        var lines = content[...]
        if let first = lines.first, isBlank(first) { lines = lines.dropFirst() }
        if let last = lines.last, isBlank(last) { lines = lines.dropLast() }
        return lines.joined(separator: "\n")
    }

    /// A `take:` line's label: `.some(nil)` for a numbered take, `.some(label)`
    /// for a quoted (straight or curly) or bare one, nil when the line is not
    /// a take marker at all. Lower-case `take:` only — the canonical spelling
    /// — so a line of prose that happens to open with "Take:" stays prose.
    private static func takeLabel(_ marker: String) -> String?? {
        guard marker.hasPrefix("take:") else { return nil }
        let rest = marker.dropFirst("take:".count)
            .trimmingCharacters(in: .whitespaces)
        guard !rest.isEmpty else { return nil }
        if rest.allSatisfy(\.isASCIIDigit) { return .some(nil) }
        if rest.count >= 2, let first = rest.first, let last = rest.last,
           CaptureTokens.isQuote(first), CaptureTokens.isQuote(last) {
            let inner = String(rest.dropFirst().dropLast())
            return .some(inner.isEmpty ? nil : inner)
        }
        return .some(rest)
    }

    private static func trimmed(_ line: String) -> String {
        line.trimmingCharacters(in: .whitespaces)
    }

    private static func isBlank(_ line: String) -> Bool {
        line.allSatisfy(\.isWhitespace)
    }
}

private extension Character {
    var isASCIIDigit: Bool { ("0"..."9").contains(self) }
}
