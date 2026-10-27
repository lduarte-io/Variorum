import Foundation
import GRDB

// Export projections (Phase 11b, Step B1 — the shapes ratified 2026-07-06,
// AppSpec §14's forward-planning delta; bulk export added 2026-07-07, the
// no-lock-in principle: "their work is always theirs to download").
//
// Exports are ONE-WAY projections of the rendered text — never a second
// source of truth, never re-imported as truth, and NO export path writes a
// row (review focus 2; pinned). Everything here reads through the one join
// brain, `joinRenderedTexts` (the 2026-07-12 conditional join): a spaced
// post exports its stored spacing; blank takes skip; unspaced posts export
// byte-identical to the Phase 4 `"\n\n"` ratification.
extension Queries {
    // MARK: - The fan section (the ratified shape)

    /// One alternate take for the "Alternates for this block" section:
    /// `take: "<label>"` where a label exists, else `take: N` (unlabeled
    /// ones numbered — N is the take's 1-based ordinal within the block's
    /// alternates enumeration, fan order).
    ///
    /// **13n-a: the section's ONE spelling lives in `VariorumDocument`** —
    /// the Variorum document format's parser reads the same markers this
    /// writes, so they live beside each other. This forwards (callers pass
    /// the export's already-filtered, non-blank alternates, so the
    /// numbering is unchanged).
    static func alternatesSection(_ alternates: [(label: String?, text: String)]) -> String {
        VariorumDocument.alternatesSection(alternates.map { .init(label: $0.label, text: $0.text) })
    }

    /// A block's exportable alternates: live ACTIVE takes in fan order,
    /// minus the rendered one, minus blank takes (blank takes contribute
    /// nothing to any projection — the ratified skip, applied to the fan
    /// section too; archived takes are out of the fan and out of the
    /// export — the "variorum edition" bundle at Phase 14 is the
    /// full-fidelity tier).
    private static func exportAlternates(
        _ db: Database, blockID: String, renderedVariantID: String?
    ) throws -> [(label: String?, text: String)] {
        try blockFan(db, blockID: blockID)
            .filter { $0.status == .active && $0.id != renderedVariantID && !$0.workingText.isEmpty }
            .map { ($0.label, $0.workingText) }
    }

    // MARK: - The callout → blockquote mapping (Phase 13 C1, R16/R27)

    /// A callout block EXPORTS as a Markdown blockquote (the execution
    /// plan's letter: "export maps to blockquote") — `> ` per line, the
    /// frame's emoji leading the first line. EXPORT-ONLY by design: this
    /// mapper is called by the export projections and NEVER by
    /// `renderedText` — the one join brain (once the Fragments bridge's;
    /// retired 2026-09-04) stays plain prose (pinned). Non-callout kinds pass through
    /// unchanged (a future frame family exports as prose until it earns
    /// its own mapping).
    static func exportMapped(_ text: String, presentation: BlockPresentation?) -> String {
        guard let presentation, presentation.kind == BlockPresentation.calloutKind
        else { return text }
        var lines = text.components(separatedBy: "\n")
        if let emoji = presentation.emoji, !emoji.isEmpty, !lines.isEmpty {
            lines[0] = lines[0].isEmpty ? emoji : "\(emoji) \(lines[0])"
        }
        return lines
            .map { $0.isEmpty ? ">" : "> \($0)" }
            .joined(separator: "\n")
    }

    // MARK: - Post export

    /// A post (or pool) as Markdown. Without variants (and without
    /// callouts) this IS `renderedText` — one brain, pinned equal; callout
    /// blocks map to blockquotes (export-only — the rendering projection
    /// never maps). With `includeVariants`, each fanned block's
    /// alternates section follows the block IN PLACE (the chosen take
    /// renders in the document flow; the section trails it — the
    /// single-block export shape, repeated), joined through the same
    /// conditional join so stored spacing stays byte-exact. A fanned
    /// block whose chosen take is blank still contributes its section
    /// (the takes are the author's work; the blank chosen skips as ever).
    ///
    /// **13n-a — the export is the Variorum document format's client.** The
    /// slots become `VariorumDocument.Block`s here (`exportBlocks`) and the
    /// ONE body serializer (`VariorumDocument.serializeBody`) writes them, so
    /// the format the import door parses and the text this projection
    /// produces cannot drift (the round-trip pins,
    /// `DocumentFormatRoundTripTests`; this projection's own suites pin the
    /// bytes unchanged).
    public static func exportPost(
        _ db: Database, postID: String, includeVariants: Bool = false
    ) throws -> String {
        let frames = try blockPresentations(db, containerID: postID)
        guard includeVariants || !frames.isEmpty else {
            return try renderedText(db, containerID: postID)
        }
        let blocks = try exportBlocks(db, postID: postID, includeVariants: includeVariants, frames: frames)
        // 13n-b U3 (R-13nb-26 (a) + her refinement): the TAKES-carrying
        // export speaks the format — in marker mode when a block holds a
        // blank line (`{v:2}` + the boundary marker), else v1 byte for byte;
        // the PLAIN export never carries a marker, a brace or a section.
        return includeVariants
            ? VariorumDocument.serializeTakesExport(blocks)
            : VariorumDocument.serializeBody(blocks)
    }

    /// The post's slots as document blocks, by the export's rules: the
    /// rendered take in place (callouts mapped to blockquotes — export-only;
    /// a blank or gap slot carries no text), and, with `includeVariants`, a
    /// fanned block's live ACTIVE non-blank alternates in fan order.
    ///
    /// `lensID` (VX-168 U3 — VX-172, `read_note` through a lens): the slots
    /// are `renderPost(…, throughLens:)`'s — the Lenses read's own sparse
    /// override over the lens's EFFECTIVE picks — so the in-place take is the
    /// lens's where it names one, else the chosen take, and the alternates
    /// are every other active non-blank take (the chosen one among them where
    /// the lens moved it aside). nil is `renderPost`'s plain traversal, byte
    /// for byte (that function's own transparent-lens guard).
    static func exportBlocks(
        _ db: Database, postID: String, includeVariants: Bool,
        frames: [String: BlockPresentation], throughLens lensID: String? = nil
    ) throws -> [VariorumDocument.Block] {
        try renderPost(db, containerID: postID, throughLens: lensID).map { slot in
            var text = ""
            if let rendered = slot.text, !rendered.isEmpty {
                text = exportMapped(rendered, presentation: frames[slot.blockID])
            }
            var alternates: [VariorumDocument.Take] = []
            if includeVariants, slot.hasFan {
                alternates = try exportAlternates(
                    db, blockID: slot.blockID, renderedVariantID: slot.variantID
                ).map { .init(label: $0.label, text: $0.text) }
            }
            return VariorumDocument.Block(text: text, alternates: alternates)
        }
    }

    // MARK: - The note as a Variorum document (13n-a — Copy for AI)

    /// **A NOTE AS A VARIORUM DOCUMENT** (13n-a; R-13n-11's push gesture,
    /// "Copy for AI"): the fan export's blocks (`exportBlocks`, variants
    /// included) under a header naming the note's STORED title — a name she
    /// typed; a note she never named carries none, and the importer names it
    /// by its file (PROVISIONAL, the unit record) — and its live tags by
    /// path. Reads only; writes no row (the export pin). A missing or
    /// tombstoned note reads as an empty document (tolerant read).
    ///
    /// `lensID` (VX-168 U3 — VX-172): the same document READ THROUGH a lens —
    /// each block's in-place take the lens's where it names one, else the
    /// chosen (`exportBlocks`' lens road). Exactly the document the note
    /// would read as were the lens made the note (pinned). nil = the note's
    /// own document, byte for byte.
    public static func variorumDocument(
        _ db: Database, postID: String, throughLens lensID: String? = nil
    ) throws -> VariorumDocument.Document {
        guard let post = try Container.fetchOne(db, key: postID), post.deletedAt == nil
        else { return VariorumDocument.Document(blocks: []) }
        let frames = try blockPresentations(db, containerID: postID)
        return VariorumDocument.Document(
            title: DisplayTitle.isAbsent(post.title) ? nil : post.title,
            tagPaths: try postTags(db, postID: postID).map(\.path),
            blocks: try exportBlocks(
                db, postID: postID, includeVariants: true, frames: frames, throughLens: lensID))
    }

    /// The text Copy for AI puts on the clipboard: the document, through the
    /// ONE serializer — the header line, then exactly
    /// `exportPost(…, includeVariants: true)` (pinned). In MARKER MODE
    /// (13n-b U3 — a block holding a blank line) both lead with the `{v:2}`
    /// token and share the marked body; this one's header adds the title and
    /// tags after the token.
    ///
    /// `lensID` (VX-168 U3 — VX-172): the text through a lens
    /// (`variorumDocument(…, throughLens:)`); nil = byte-unchanged.
    public static func variorumDocumentText(
        _ db: Database, postID: String, throughLens lensID: String? = nil
    ) throws -> String {
        VariorumDocument.serialize(try variorumDocument(db, postID: postID, throughLens: lensID))
    }

    // MARK: - Single-block export

    /// One block as Markdown: the rendered take in place (the read-time
    /// rule — the live placement's chosen while live/active/on this block,
    /// else the block default while live; an unplaced lineage block renders
    /// its default), and, when the block is fanned, the labeled alternates
    /// section. A dead/missing block exports as the empty string (tolerant
    /// read, the Queries doctrine).
    public static func exportBlock(_ db: Database, blockID: String) throws -> String {
        try blockTakes(db, blockID: blockID).markdown
    }

    /// **13e E6 (her A21, the clipboard half: *"copying all takes together to
    /// clipboard"*)** — `exportBlock`'s projection PLUS how many takes it
    /// represents, from the one walk that builds it. The count exists so the
    /// door's confirmation cannot claim a different number than the text
    /// holds: "all takes" means exactly what the ratified export shape means
    /// (the shown take when it has text, then its live ACTIVE non-blank
    /// alternates — archived takes are out of the fan and out of the export).
    /// A second implementation of that rule app-side would be the drift class.
    public static func blockTakes(
        _ db: Database, blockID: String
    ) throws -> (markdown: String, takeCount: Int) {
        let row = try Row.fetchOne(
            db,
            sql: """
                SELECT COALESCE(chosen.id, dflt.id)                     AS variant_id,
                       COALESCE(chosen.working_text, dflt.working_text) AS text,
                       b.presentation                                   AS presentation
                FROM block b
                LEFT JOIN container_block cb
                  ON cb.block_id = b.id AND cb.deleted_at IS NULL
                LEFT JOIN variant chosen
                  ON chosen.id = cb.chosen_variant_id
                 AND chosen.block_id = b.id
                 AND chosen.deleted_at IS NULL
                 AND chosen.status = 'active'
                LEFT JOIN variant dflt
                  ON dflt.id = b.default_variant_id
                 AND dflt.deleted_at IS NULL
                WHERE b.id = ? AND b.deleted_at IS NULL
                """,
            arguments: [blockID])
        guard let row else { return ("", 0) }
        let renderedID: String? = row["variant_id"]
        let renderedText: String? = row["text"]
        var pieces: [String] = []
        var takeCount = 0
        if let renderedText, !renderedText.isEmpty {
            pieces.append(exportMapped(
                renderedText,
                presentation: BlockPresentation.decode(row["presentation"])))
            takeCount += 1
        }
        let alternates = try exportAlternates(
            db, blockID: blockID, renderedVariantID: renderedID)
        if !alternates.isEmpty {
            pieces.append(alternatesSection(alternates))
        }
        takeCount += alternates.count
        return (joinRenderedTexts(pieces), takeCount)
    }

    // MARK: - Reading export

    /// A reading as ONE Markdown document: `# <name>`, then the assembled
    /// posts in reading order — each under a heading, which is the ONE
    /// display brain's answer since 13g batch 7 (her R6-3 export
    /// refinement): the note's title, else its date, else "Untitled".
    /// When the book has live CHAPTERS (curated
    /// only — Phase 13b 3B, N13) or groups by a tag root, a section
    /// heading precedes each section's posts (posts drop one heading level
    /// so the hierarchy reads). The chapter path renders EXACTLY the book
    /// view's grouped presentation (`BookStructureModel.grouped`, mirrored
    /// by the assembly): chapters in `(position, id)` order — EMPTY
    /// chapters included, same-named chapters each under their own
    /// heading — with unfiled entries trailing under the book view's own
    /// "unfiled" label. Bodies are the plain post projection; the pieces
    /// join through the one join brain. A missing/tombstoned reading
    /// exports empty (tolerant read).
    public static func exportReading(_ db: Database, readingID: String) throws -> String {
        guard let reading = try reading(db, id: readingID) else { return "" }
        let entries = try assembleReading(db, readingID: readingID)
        let chapters = reading.kind == .book
            ? try readingSections(db, readingID: readingID) : []

        // One grouped shape, two resolutions: chapter groups (by id — the
        // assembly's `sectionID`), or the Phase 11b run clustering over
        // the tag-grouping `sectionPath` (byte-identical output — runs of
        // an equal path share one heading; nil paths head "Ungrouped").
        var groups: [(heading: String?, entries: [ReadingEntry])] = []
        let grouped: Bool
        if chapters.isEmpty {
            grouped = entries.contains { $0.sectionPath != nil }
            for entry in entries {
                if groups.isEmpty || groups[groups.count - 1].heading != entry.sectionPath {
                    groups.append((entry.sectionPath, [entry]))
                } else {
                    groups[groups.count - 1].entries.append(entry)
                }
            }
        } else {
            grouped = true
            for chapter in chapters {
                groups.append((chapter.name, entries.filter { $0.sectionID == chapter.id }))
            }
            let unfiled = entries.filter { $0.sectionID == nil }
            if !unfiled.isEmpty {
                groups.append(("unfiled", unfiled))
            }
        }

        var pieces: [String] = ["# \(reading.name)"]
        for group in groups {
            if grouped {
                pieces.append("## \(group.heading ?? "Ungrouped")")
            }
            for entry in group.entries {
                // 13g batch 7 (R6-3, her export refinement verbatim: *"maybe
                // it should be preserved on export? someone might be
                // frustrated exporting a note with a date they see as a
                // title and then their exported note says 'Untitled'"*) —
                // the ONE display brain, the same answer the masthead gives.
                let title = entry.displayTitle
                pieces.append(grouped ? "### \(title)" : "## \(title)")
                let body = try exportPost(db, postID: entry.postID)
                if !body.isEmpty {
                    pieces.append(body)
                }
            }
        }
        return joinRenderedTexts(pieces)
    }


    // MARK: - Bulk export (the whole library, ONE gesture)

    /// One file of a bulk export: a folder-relative path and its contents.
    /// The manifest is pure data — the app face writes it wherever the
    /// author pointed the panel; tests assert totality and layout here.
    public struct ExportFile: Equatable, Sendable {
        public let relativePath: String
        public let contents: String

        public init(relativePath: String, contents: String) {
            self.relativePath = relativePath
            self.contents = contents
        }
    }

    /// The whole library as a folder of plain `.md` (author 2026-07-07 —
    /// the gesture and its totality are ratified; the layout is this
    /// projection's recorded call):
    ///
    /// - **Every live post lands exactly once** — one file per post, named
    ///   `<date> <title>.md` (the user-set `entry_date` where present, else
    ///   the creation date; untitled posts use the date alone). Name
    ///   collisions disambiguate with a short id suffix, deterministically.
    /// - **Archived posts are included**, under `Archived/` — archive is
    ///   kept-out-of-view, not gone, and freezing them out of "their work
    ///   is always theirs to download" would be silent loss (the Phase 9b
    ///   archived-entries-stay-push-eligible doctrine). Tombstoned posts do
    ///   not export (deleted is deleted; the SQLite file stays the lossless
    ///   archive).
    /// - **Pool scraps are included**, under `Pools/` (author ruling
    ///   2026-07-16, QUESTIONS #22c — scraps are her work; the round-1
    ///   MINOR's first shape): one `Pools/<title>.md` per live pool, its
    ///   scraps rendered in the pool's own listing order through the same
    ///   join semantics (a pool is a container — one traversal, no bespoke
    ///   shape). Every live pool lands exactly once; tombstoned pools do
    ///   not export.
    /// - **Readings as optional folder views** (`includeReadings`): one
    ///   `Readings/<name>.md` per live reading — the reading projection
    ///   above, a VIEW over the same posts (never a second copy of truth).
    ///
    /// **A NOTE'S FILE IS COPY FULL TEXT'S TEXT, byte for byte** (VX-126 —
    /// her option A, 2026-10-27: "each per-note file in the bulk export is
    /// byte-identical to Copy full text"): `variorumDocumentText`, the ONE
    /// serializer — the `{t:"…"} {#tag}` header line, then the takes-carrying
    /// body (Alternates sections where a block has a fan; the plain prose
    /// wherever it has none). So every note file re-imports whole through
    /// File ▸ Import… — title, tags and takes — and the bulk export is a
    /// round-trippable set of plain Markdown files (the no-lock-in story;
    /// `DocumentFormatRoundTripTests`' library pin). The `Pools/` files (a
    /// scraps area is never a note — Copy full text has no door on one) and
    /// the `Readings/` views (a per-post `exportPost` consumer that predates
    /// the header) keep the PLAIN projection, byte-unchanged (C-126-1). Cost ∝
    /// the corpus — this is the one deliberately corpus-shaped projection, a
    /// one-shot gesture, never a held observation.
    public static func bulkExportManifest(
        _ db: Database, includeReadings: Bool = true
    ) throws -> [ExportFile] {
        var files: [ExportFile] = []
        var usedPaths = Set<String>()

        let posts = try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date, created_at,
                       archived_at
                FROM container
                WHERE kind = 'post' AND deleted_at IS NULL
                ORDER BY COALESCE(entry_date, substr(created_at, 1, 10)), id
                """)
        for post in posts {
            let id: String = post["id"]
            let entryDate: String? = post["entry_date"]
            let stamp: String? = post["created_at"]
            // 13g batch 7 (R6-3): the date half is the display brain's own
            // date — same precedence this filename convention has had since
            // 11b, now derived in ONE place, on the LOCAL calendar day (the
            // kind of day `entry_date` beside it always was). The listing's
            // ORDER BY keeps its UTC slice: it decides sequence, not names.
            let date = (entryDate?.isEmpty == false ? entryDate : nil)
                ?? DisplayTitle.day(fromStamp: stamp)
                ?? String((stamp ?? "").prefix(10))
            let rawTitle: String? = post["title"]
            // Only a BLANK title counts as no title (`DisplayTitle.isAbsent`
            // — 13k K1's letter, her ruling: a name she typed is a name). So
            // a note she never named is named by its date alone, exactly as
            // the ratified 11b shape always did for a NULL title — while a
            // legacy note whose stored title IS the literal "Untitled"
            // exports as "<date> Untitled.md" again (#53(k), stated rather
            // than smuggled; no sweep rewrites those rows).
            let title = DisplayTitle.isAbsent(rawTitle)
                ? "" : sanitizedFilename(rawTitle ?? "")
            let base = title.isEmpty ? date : "\(date) \(title)"
            let archivedAt: String? = post["archived_at"]
            let folder = archivedAt != nil ? "Archived/" : ""
            let path = uniquePath(base: "\(folder)\(base)", id: id, used: &usedPaths)
            // VX-126 (option A): the note's file is Copy full text's text.
            files.append(ExportFile(
                relativePath: path,
                contents: try variorumDocumentText(db, postID: id)))
        }

        // Pools (author ruling 2026-07-16, #22c): through the ONE pools
        // listing (`Queries.pools`, created_at order); contents are the
        // ordinary container projection — scraps in pool order.
        for pool in try pools(db) {
            // 13k K2 (her ruling): a nameless pool is named by the day it
            // was created, in the app AND here — the display brain serves
            // both, which is why it lives in core (13g R6-3's reason,
            // applied to the surface #52(c) had left out).
            let base = sanitizedFilename(
                DisplayTitle.pool(title: pool.title, createdAt: pool.createdAt))
            let path = uniquePath(
                base: "Pools/\(base.isEmpty ? DisplayTitle.placeholder : base)",
                id: pool.id, used: &usedPaths)
            files.append(ExportFile(
                relativePath: path,
                contents: try exportPost(db, postID: pool.id)))
        }

        if includeReadings {
            for reading in try readings(db) {
                let base = sanitizedFilename(reading.name)
                let path = uniquePath(
                    base: "Readings/\(base.isEmpty ? "Untitled" : base)",
                    id: reading.id, used: &usedPaths)
                files.append(ExportFile(
                    relativePath: path,
                    contents: try exportReading(db, readingID: reading.id)))
            }
        }
        return files
    }

    /// Filesystem-safe name: path separators and control characters go,
    /// whitespace collapses, length is capped (APFS names are byte-limited;
    /// 80 characters leaves room for the date prefix and a collision
    /// suffix). Pure string work — tested directly; public so the app's
    /// save panels derive their default filenames from the same rule.
    public static func sanitizedFilename(_ name: String) -> String {
        let cleaned = name.map { char -> Character in
            if char == "/" || char == ":" || char.isNewline { return "-" }
            return char
        }
        var collapsed = ""
        var lastWasSpace = false
        for char in cleaned {
            let isSpace = char.isWhitespace
            if isSpace && lastWasSpace { continue }
            collapsed.append(isSpace ? " " : char)
            lastWasSpace = isSpace
        }
        var trimmed = collapsed.trimmingCharacters(in: .whitespaces)
        // A leading dot would hide the file; trailing dots confuse Finder.
        while trimmed.hasPrefix(".") { trimmed.removeFirst() }
        while trimmed.hasSuffix(".") { trimmed.removeLast() }
        return String(trimmed.prefix(80)).trimmingCharacters(in: .whitespaces)
    }

    /// Collision handling: first taker keeps the plain name; later
    /// same-named files append a short id prefix (stable — ids are
    /// permanent), then the full id (unreachable in practice). Tracking is
    /// case-insensitive (APFS default).
    private static func uniquePath(
        base: String, id: String, used: inout Set<String>
    ) -> String {
        for candidate in [base, "\(base) \(id.prefix(8))", "\(base) \(id)"] {
            let path = "\(candidate).md"
            if used.insert(path.lowercased()).inserted {
                return path
            }
        }
        // Ids are unique, so the full-id candidate always inserts; this
        // line is for the compiler.
        return "\(base) \(id).md"
    }
}
