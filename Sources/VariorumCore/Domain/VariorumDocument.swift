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
///   the separator alone (an Alternates section counts as a piece). Rows
///   therefore round-trip — export, re-import, the same store shape — for
///   every block the join writes distinguishably; the join's one undecidable
///   spacing (a block storing exactly ONE trailing newline exports like an
///   unspaced one) reads unspaced, and a blank line INSIDE a surface block
///   still reads as a boundary (P-13n-4). The document's leading and
///   trailing blank runs are edges and drop. A take's own text is kept
///   EXACTLY, internal newlines and blank lines included (only the one blank
///   line the serializer puts on each side of a take's text is the
///   section's).
/// - **Parsing is fail-honest:** a malformed Alternates section refuses the
///   whole document with the line it found the problem on — never a silent
///   partial import (`Failure`). **Any export re-imports whole**
///   (R-ARCH-13na-2): a section with no paragraph above it is what the
///   export writes for a fanned block whose chosen take is blank, and reads
///   as exactly that block — an empty chosen take with the section's takes.
///
/// What does NOT ride the format, by her ruling: commits, book settings,
/// block names, comments, callout frames (an export maps a callout to a
/// blockquote; a blockquote imports as text), archived takes, and
/// multi-paragraph SURFACE blocks (P-13n-4 — takes keep their newlines, a
/// block's surface text does not). The full-fidelity form is 13m's.
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
    /// nil when there is nothing to say.
    public static func headerLine(title: String?, tagPaths: [String]) -> String? {
        var tokens: [String] = []
        if let title, !title.isEmpty { tokens.append("{t:\"\(title)\"}") }
        for path in tagPaths where !path.isEmpty { tokens.append("{#\(path)}") }
        return tokens.isEmpty ? nil : tokens.joined(separator: " ")
    }

    /// **THE ONE SERIALIZER of a body** — `Queries.exportPost`'s, too. Each
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
    /// blank line, the body.
    public static func serialize(_ document: Document) -> String {
        let body = serializeBody(document.blocks)
        guard let header = headerLine(title: document.title, tagPaths: document.tagPaths)
        else { return body }
        return body.isEmpty ? header : header + "\n\n" + body
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
        if let first = lines.firstIndex(where: { !isBlank($0) }) {
            let read = CaptureTokens.readLine(lines[first])
            if read.foundToken, read.text.allSatisfy(CaptureTokens.isHorizontal) {
                title = read.title
                tagPaths = read.tagPaths
                lines[first] = ""
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

            var takes: [Take] = []
            var open: (label: String?, content: [String])?
            var closed = false
            index += 1
            while index < lines.count {
                let sectionLine = lines[index]
                let sectionMarker = trimmed(sectionLine)
                if sectionMarker == alternatesFooter {
                    if let open { takes.append(Take(label: open.label, text: takeText(open.content))) }
                    closed = true
                    index += 1
                    break
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
            guard closed else {
                throw Failure(.unterminatedAlternates, line: headerLine)
            }
            // Empty takes skip — the export's own rule, mirrored.
            let kept = takes.filter { !$0.text.isEmpty }
            if above.isEmpty {
                // NO PARAGRAPH ABOVE (R-ARCH-13na-2, the architect's ruling on
                // FORK-C): exactly what the export writes for a fanned block
                // whose CHOSEN take is blank (the blank chosen skips, its
                // takes are her work) — so it is that block: an empty chosen
                // take, the section's takes at the fan's end. Any export
                // re-imports whole. A section with no paragraph AND no take
                // is nothing the export writes — it still refuses.
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
