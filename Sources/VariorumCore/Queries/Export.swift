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
    static func alternatesSection(_ alternates: [(label: String?, text: String)]) -> String {
        var lines: [String] = ["--- Alternates for this block ---"]
        for (index, take) in alternates.enumerated() {
            if let label = take.label, !label.isEmpty {
                lines.append("take: \"\(label)\"")
            } else {
                lines.append("take: \(index + 1)")
            }
            lines.append(take.text)
        }
        lines.append("--- end alternates ---")
        return lines.joined(separator: "\n\n")
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

    // MARK: - Post export

    /// A post (or pool) as Markdown. Without variants this IS
    /// `renderedText` — one brain, pinned equal. With `includeVariants`,
    /// each fanned block's alternates section follows the block IN PLACE
    /// (the chosen take renders in the document flow; the section trails
    /// it — the single-block export shape, repeated), joined through the
    /// same conditional join so stored spacing stays byte-exact. A fanned
    /// block whose chosen take is blank still contributes its section
    /// (the takes are the author's work; the blank chosen skips as ever).
    public static func exportPost(
        _ db: Database, postID: String, includeVariants: Bool = false
    ) throws -> String {
        guard includeVariants else {
            return try renderedText(db, containerID: postID)
        }
        var pieces: [String] = []
        for slot in try renderPost(db, containerID: postID) {
            if let text = slot.text, !text.isEmpty {
                pieces.append(text)
            }
            if slot.hasFan {
                let alternates = try exportAlternates(
                    db, blockID: slot.blockID, renderedVariantID: slot.variantID)
                if !alternates.isEmpty {
                    pieces.append(alternatesSection(alternates))
                }
            }
        }
        return joinRenderedTexts(pieces)
    }

    // MARK: - Single-block export

    /// One block as Markdown: the rendered take in place (the read-time
    /// rule — the live placement's chosen while live/active/on this block,
    /// else the block default while live; an unplaced lineage block renders
    /// its default), and, when the block is fanned, the labeled alternates
    /// section. A dead/missing block exports as the empty string (tolerant
    /// read, the Queries doctrine).
    public static func exportBlock(_ db: Database, blockID: String) throws -> String {
        let row = try Row.fetchOne(
            db,
            sql: """
                SELECT COALESCE(chosen.id, dflt.id)                     AS variant_id,
                       COALESCE(chosen.working_text, dflt.working_text) AS text
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
        guard let row else { return "" }
        let renderedID: String? = row["variant_id"]
        let renderedText: String? = row["text"]
        var pieces: [String] = []
        if let renderedText, !renderedText.isEmpty {
            pieces.append(renderedText)
        }
        let alternates = try exportAlternates(
            db, blockID: blockID, renderedVariantID: renderedID)
        if !alternates.isEmpty {
            pieces.append(alternatesSection(alternates))
        }
        return joinRenderedTexts(pieces)
    }

    // MARK: - Reading export

    /// A reading as ONE Markdown document: `# <name>`, then the assembled
    /// posts in reading order — each under a heading (title, else entry
    /// date, else "Untitled"). When the reading groups by a tag root, a
    /// section heading precedes each section's first post (posts drop one
    /// heading level so the hierarchy reads). Bodies are the plain post
    /// projection; the pieces join through the one join brain. A missing/
    /// tombstoned reading exports empty (tolerant read).
    public static func exportReading(_ db: Database, readingID: String) throws -> String {
        guard let reading = try reading(db, id: readingID) else { return "" }
        let entries = try assembleReading(db, readingID: readingID)
        let grouped = entries.contains { $0.sectionPath != nil }
        var pieces: [String] = ["# \(reading.name)"]
        var lastSection: String?
        var sectionEmitted = false
        for entry in entries {
            if grouped, !sectionEmitted || lastSection != entry.sectionPath {
                sectionEmitted = true
                lastSection = entry.sectionPath
                pieces.append("## \(entry.sectionPath ?? "Ungrouped")")
            }
            let title = displayTitle(entry.title, entryDate: entry.entryDate)
            pieces.append(grouped ? "### \(title)" : "## \(title)")
            let body = try renderedText(db, containerID: entry.postID)
            if !body.isEmpty {
                pieces.append(body)
            }
        }
        return joinRenderedTexts(pieces)
    }

    private static func displayTitle(_ title: String?, entryDate: String?) -> String {
        if let title, !title.isEmpty { return title }
        if let entryDate, !entryDate.isEmpty { return entryDate }
        return "Untitled"
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
    /// - **Readings as optional folder views** (`includeReadings`): one
    ///   `Readings/<name>.md` per live reading — the reading projection
    ///   above, a VIEW over the same posts (never a second copy of truth).
    ///
    /// Bodies are the plain projection (`"plain .md"` — no variants; fans
    /// stay in the app and in the Phase 14 bundle). Cost ∝ the corpus —
    /// this is the one deliberately corpus-shaped projection, a one-shot
    /// gesture, never a held observation.
    public static func bulkExportManifest(
        _ db: Database, includeReadings: Bool = true
    ) throws -> [ExportFile] {
        var files: [ExportFile] = []
        var usedPaths = Set<String>()

        let posts = try Row.fetchAll(
            db,
            sql: """
                SELECT id, title, entry_date,
                       substr(created_at, 1, 10) AS created_day,
                       archived_at
                FROM container
                WHERE kind = 'post' AND deleted_at IS NULL
                ORDER BY COALESCE(entry_date, substr(created_at, 1, 10)), id
                """)
        for post in posts {
            let id: String = post["id"]
            let entryDate: String? = post["entry_date"]
            let createdDay: String = post["created_day"]
            let date = entryDate ?? createdDay
            let rawTitle: String? = post["title"]
            let title = sanitizedFilename(rawTitle ?? "")
            let base = title.isEmpty ? date : "\(date) \(title)"
            let archivedAt: String? = post["archived_at"]
            let folder = archivedAt != nil ? "Archived/" : ""
            let path = uniquePath(base: "\(folder)\(base)", id: id, used: &usedPaths)
            files.append(ExportFile(
                relativePath: path,
                contents: try renderedText(db, containerID: id)))
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
