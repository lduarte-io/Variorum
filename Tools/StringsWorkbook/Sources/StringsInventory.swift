// BRANCH-ONLY tool code (`tools/strings-workbook`; never merges). The record:
// notes/plans/strings-workbook-record.md.

import Foundation

/// `notes/copy-pass/all-user-facing-strings.md`, parsed — every SURFACE (a `##`
/// group, or a `###` sub-group under a container heading such as "Settings
/// panes") with its bullets in document order, and the footer count the doc
/// declares for it.
///
/// The grammar the sweep wrote (its header, lines 5–6, confirmed against every
/// bullet in the 2026-10-04 compile):
/// - a LITERAL bullet: `` - `"…"` — `path:line`, `path:line` (tags) ``, where the
///   literal is one CommonMark code span (two backticks when the literal itself
///   holds a backtick) and the tags are any of `(templated)`, `(tooltip)`,
///   `⚠RULED`, `⚠RULED (§11 provisional)`;
/// - a DOCUMENT bullet (Seeded content only): `- **Title** — description…`,
///   possibly followed by indented `  - …` sub-bullets that belong to it;
/// - a footer `— N strings` / `— N documents (…)` closing each surface;
/// - the `## Totals` table, whose `**All groups**` row is the doc's own total.
///
/// Strict on purpose: anything the grammar does not name REFUSES (`ParseError`)
/// rather than being skipped — the workbook must hold every string or say why not.
public struct StringsInventory: Equatable, Sendable {
    public var surfaces: [Surface]
    /// The `## Totals` table's `**All groups**` value (nil = no such row).
    public var declaredTotal: Int?

    public var bulletCount: Int { surfaces.reduce(0) { $0 + $1.bullets.count } }

    public struct Surface: Equatable, Sendable {
        /// The heading text exactly (`##` or `###`, marker stripped).
        public var name: String
        public var headingLine: Int
        public var bullets: [Bullet]
        /// The `— N strings|documents` footer (nil = the doc wrote none).
        public var footerCount: Int?
    }

    public enum Ruled: Equatable, Sendable {
        /// `⚠RULED` — matches the ruled copy word-by-word.
        case ruled
        /// `⚠RULED (§11 provisional)` — listed in §11 of the copy file only.
        case provisional
    }

    public struct Bullet: Equatable, Sendable {
        public enum Kind: Equatable, Sendable { case literal, document }
        public var kind: Kind
        /// 1-based line in the inventory.
        public var line: Int
        /// literal: the text between the quotes as the doc writes it (escapes
        /// kept); document: the bullet's text (sub-bullets on their own lines).
        public var docBody: String
        /// `path:line` sites in the doc's order (a document bullet also lists
        /// bare paths and resolves `:N` shorthand against the path before it).
        public var sites: [String]
        /// `(templated)` / `(tooltip)` in the doc's order; a document carries
        /// `(seeded document)`.
        public var tags: [String]
        public var ruled: Ruled?
        /// True when the body came from `ReturnGlyphCorrections` (finding F-1).
        public var correctedFromSource: Bool
        /// The rendered take-1 text — what the screen shows.
        public var current: String
    }

    public enum ParseError: Error, Equatable, CustomStringConvertible {
        case malformedBullet(line: Int, reason: String)
        case bulletOutsideSurface(line: Int)
        case unresolvedReturnGlyph(line: Int, site: String)
        case returnGlyphCorrectionMismatch(line: Int, site: String)
        case render(line: Int, reason: String)

        public var description: String {
            switch self {
            case .malformedBullet(let line, let reason):
                return "line \(line): malformed bullet — \(reason)"
            case .bulletOutsideSurface(let line):
                return "line \(line): a bullet before any surface heading"
            case .unresolvedReturnGlyph(let line, let site):
                return "line \(line): a ⏎ with no verified source correction (first site \(site)) — "
                    + "the tool will not guess whether it is a line break or the Return glyph"
            case .returnGlyphCorrectionMismatch(let line, let site):
                return "line \(line): the ⏎ correction for \(site) no longer reproduces the inventory's text"
            case .render(let line, let reason):
                return "line \(line): \(reason)"
            }
        }
    }

    // MARK: - Parsing

    public static func parse(_ markdown: String) throws -> StringsInventory {
        let lines = markdown.components(separatedBy: "\n")
        var surfaces: [Surface] = []
        var declaredTotal: Int?
        var inTotals = false

        func closeEmptyContainer() {
            // A heading that only CONTAINS sub-surfaces ("Settings panes") has
            // no bullets and no footer of its own — it is not a surface.
            if let last = surfaces.last, last.bullets.isEmpty, last.footerCount == nil {
                surfaces.removeLast()
            }
        }

        for (index, line) in lines.enumerated() {
            let number = index + 1
            if line.hasPrefix("## ") {
                closeEmptyContainer()
                let name = String(line.dropFirst(3))
                if name == "Totals" { inTotals = true; continue }
                if inTotals { inTotals = false }
                if name == "Sweep notes" { break }
                surfaces.append(Surface(name: name, headingLine: number, bullets: [], footerCount: nil))
                continue
            }
            if inTotals {
                if line.hasPrefix("| **All groups** |") {
                    let digits = line.filter(\.isNumber)
                    declaredTotal = Int(digits)
                }
                continue
            }
            if line.hasPrefix("### ") {
                closeEmptyContainer()
                surfaces.append(Surface(
                    name: String(line.dropFirst(4)), headingLine: number, bullets: [], footerCount: nil))
                continue
            }
            guard !surfaces.isEmpty else { continue }  // the doc's header prose
            if let footer = footerCount(line) {
                surfaces[surfaces.count - 1].footerCount = footer
                continue
            }
            if line.hasPrefix("- ") {
                let bullet = try parseBullet(line, number: number)
                surfaces[surfaces.count - 1].bullets.append(bullet)
                continue
            }
            if line.hasPrefix("  - ") {
                // A document bullet's sub-bullet: it belongs to the bullet above.
                guard var last = surfaces[surfaces.count - 1].bullets.popLast(), last.kind == .document else {
                    throw ParseError.malformedBullet(line: number, reason: "a sub-bullet under a non-document bullet")
                }
                last = try extendDocument(last, with: String(line.dropFirst(2)), number: number)
                surfaces[surfaces.count - 1].bullets.append(last)
                continue
            }
            // Anything else inside a surface is intro prose (the Settings and
            // Seeded-content paragraphs) — not a string.
        }
        closeEmptyContainer()
        return StringsInventory(surfaces: surfaces, declaredTotal: declaredTotal)
    }

    static func footerCount(_ line: String) -> Int? {
        guard line.hasPrefix("— ") else { return nil }
        let rest = line.dropFirst(2)
        let digits = rest.prefix(while: \.isNumber)
        guard !digits.isEmpty else { return nil }
        let tail = rest.dropFirst(digits.count)
        guard tail.hasPrefix(" strings") || tail.hasPrefix(" documents") else { return nil }
        return Int(digits)
    }

    // MARK: - One bullet

    static func parseBullet(_ line: String, number: Int) throws -> Bullet {
        let chars = Array(line)
        if line.hasPrefix("- **") {
            return try documentBullet(text: String(line.dropFirst(2)), number: number)
        }
        guard line.hasPrefix("- `"), let (literal, afterLiteral) = codeSpan(chars, at: 2) else {
            throw ParseError.malformedBullet(line: number, reason: "no leading code span")
        }
        guard literal.count >= 2, literal.first == "\"", literal.last == "\"" else {
            throw ParseError.malformedBullet(line: number, reason: "the code span is not a quoted literal")
        }
        let docBody = String(literal.dropFirst().dropLast())

        var i = afterLiteral
        let dash = Array(" — ")
        guard Array(chars[i..<min(chars.count, i + dash.count)]) == dash else {
            throw ParseError.malformedBullet(line: number, reason: "no ' — ' after the literal")
        }
        i += dash.count
        var sites: [String] = []
        while i < chars.count, chars[i] == "`" {
            guard let (site, end) = codeSpan(chars, at: i) else {
                throw ParseError.malformedBullet(line: number, reason: "unterminated site code span")
            }
            guard isSite(site) else {
                throw ParseError.malformedBullet(line: number, reason: "not a path:line site: \(site)")
            }
            sites.append(site)
            i = end
            if Array(chars[i..<min(chars.count, i + 2)]) == Array(", ") { i += 2 } else { break }
        }
        guard !sites.isEmpty else {
            throw ParseError.malformedBullet(line: number, reason: "no sites")
        }

        // The tag tail — every token must be one the grammar names.
        var tail = String(chars[i...]).trimmingCharacters(in: .whitespaces)
        var tags: [String] = []
        var ruled: Ruled?
        while !tail.isEmpty {
            if tail.hasPrefix("(templated)") || tail.hasPrefix("(tooltip)") {
                let token = tail.hasPrefix("(templated)") ? "(templated)" : "(tooltip)"
                tags.append(token)
                tail = String(tail.dropFirst(token.count))
            } else if tail.hasPrefix("⚠RULED (§11 provisional)") {
                ruled = .provisional
                tail = String(tail.dropFirst("⚠RULED (§11 provisional)".count))
            } else if tail.hasPrefix("⚠RULED") {
                ruled = .ruled
                tail = String(tail.dropFirst("⚠RULED".count))
            } else {
                throw ParseError.malformedBullet(line: number, reason: "unknown tag tail: \(tail)")
            }
            tail = tail.trimmingCharacters(in: .whitespaces)
        }

        // The ⏎ rule (finding F-1): never guess; a ⏎ body takes its verified
        // source correction or the parse refuses.
        var corrected = false
        let current: String
        do {
            if docBody.contains("⏎") {
                guard let entry = ReturnGlyphCorrections.entry(forSite: sites[0]) else {
                    throw ParseError.unresolvedReturnGlyph(line: number, site: sites[0])
                }
                guard ReturnGlyphCorrections.inventoryForm(of: entry) == docBody else {
                    throw ParseError.returnGlyphCorrectionMismatch(line: number, site: sites[0])
                }
                current = try ReturnGlyphCorrections.render(entry)
                corrected = true
            } else {
                current = try SwiftLiteralText.render(docBody)
            }
        } catch let error as SwiftLiteralText.RenderError {
            throw ParseError.render(line: number, reason: error.description)
        }

        return Bullet(
            kind: .literal, line: number, docBody: docBody, sites: sites, tags: tags,
            ruled: ruled, correctedFromSource: corrected, current: current)
    }

    /// A Seeded-content bullet: the whole description is its text.
    static func documentBullet(text: String, number: Int) throws -> Bullet {
        var bullet = Bullet(
            kind: .document, line: number, docBody: text, sites: [], tags: ["(seeded document)"],
            ruled: nil, correctedFromSource: false, current: "")
        try refreshDocument(&bullet, number: number)
        return bullet
    }

    static func extendDocument(_ bullet: Bullet, with subBullet: String, number: Int) throws -> Bullet {
        var extended = bullet
        extended.docBody += "\n" + subBullet
        try refreshDocument(&extended, number: number)
        return extended
    }

    /// Re-derives a document bullet's sites, ruled mark and rendered text from
    /// its (possibly extended) body.
    static func refreshDocument(_ bullet: inout Bullet, number: Int) throws {
        let chars = Array(bullet.docBody)
        var sites: [String] = []
        var lastPath: String?
        var i = 0
        while i < chars.count {
            guard chars[i] == "`", let (span, end) = codeSpan(chars, at: i) else { i += 1; continue }
            if isSite(span) || isBarePath(span) {
                lastPath = String(span.split(separator: ":").first ?? Substring(span))
                if !sites.contains(span) { sites.append(span) }
            } else if span.hasPrefix(":"), span.dropFirst().allSatisfy(\.isNumber), !span.dropFirst().isEmpty,
                      let lastPath {
                let resolved = lastPath + span
                if !sites.contains(resolved) { sites.append(resolved) }
            }
            i = end
        }
        bullet.sites = sites
        bullet.ruled = bullet.docBody.contains("⚠RULED") ? .ruled : nil
        do {
            bullet.current = try SwiftLiteralText.render(bullet.docBody)
        } catch let error as SwiftLiteralText.RenderError {
            throw ParseError.render(line: number, reason: error.description)
        }
    }

    // MARK: - Lexing helpers

    /// A CommonMark code span opening at `start` (a run of N backticks, closed
    /// by the next run of EXACTLY N). Returns the content (one padding space
    /// stripped from each end of a multi-backtick span) and the index after it.
    static func codeSpan(_ chars: [Character], at start: Int) -> (String, Int)? {
        guard start < chars.count, chars[start] == "`" else { return nil }
        var n = 0
        while start + n < chars.count, chars[start + n] == "`" { n += 1 }
        var j = start + n
        while j < chars.count {
            guard chars[j] == "`" else { j += 1; continue }
            var m = 0
            while j + m < chars.count, chars[j + m] == "`" { m += 1 }
            if m == n {
                var content = String(chars[(start + n)..<j])
                if n > 1, content.count > 2, content.hasPrefix(" "), content.hasSuffix(" ") {
                    content = String(content.dropFirst().dropLast())
                }
                return (content, j + n)
            }
            j += m
        }
        return nil
    }

    static let fileExtensions = [".swift", ".txt", ".md"]

    /// `path/to/File.swift:123`.
    static func isSite(_ s: String) -> Bool {
        guard let colon = s.lastIndex(of: ":") else { return false }
        let path = s[..<colon]
        let line = s[s.index(after: colon)...]
        return !line.isEmpty && line.allSatisfy(\.isNumber) && isBarePath(String(path))
    }

    /// `path/to/File.swift` — a path with a known extension and no spaces.
    static func isBarePath(_ s: String) -> Bool {
        !s.contains(" ") && s.contains("/") && fileExtensions.contains { s.hasSuffix($0) }
    }
}
