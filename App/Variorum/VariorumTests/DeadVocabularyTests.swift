//
//  DeadVocabularyTests.swift
//  VariorumTests
//
//  13i-d U6 — **the grep pin the vocabulary sweep earns** (the 18j
//  literal-colour pin's form). The sitting record retired words app-wide:
//  "smart" (§1 — her pet peeve; a gathering is a GATHERING, §14's "smart-book
//  vocabulary: retired app-wide at 13i-d"), the sidebar area's old name SHELF
//  (§7 — the area is the BOOKCASE; a SHELF is now one of its groupings, so the
//  noun itself stays and only the area's phrasings are banned), the Library's
//  "Posts" (§21 — "must say Notes"), and the doors and sentences this sweep
//  rewrote. A sweep closes BY CONSTRUCTION only if the next spelling cannot
//  ship: this walks the source.
//
//  THE RULE: no banned spelling on a CODE line (comments may keep history) of
//  the Mac app, the shared code both platforms compile, or the core package —
//  with a NAMED allow-list, each entry carrying the decision that put it
//  there. An entry is cheap to add and impossible to add silently.
//

import Foundation
import Testing

@Suite("No dead vocabulary in the shipped words (13i-d U6)")
struct DeadVocabularyTests {
    /// `…/App/Variorum` (this file's folder's parent).
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The repo root (`…/App/Variorum/../..`).
    private static var repoRoot: URL {
        appRoot.deletingLastPathComponent().deletingLastPathComponent()
    }

    /// The scanned roots, relative to the repo.
    private static let scannedRoots = [
        "App/Variorum/Variorum", "App/Variorum/Shared", "Sources/VariorumCore",
    ]

    /// Files or folders (repo-relative prefixes) that may hold a dead spelling,
    /// each with the decision that allows it. Nothing else may.
    ///
    /// 1. **The schema's history** — the migrations name the retired
    ///    `kind = 'smart'` value in their SQL (the v1_18 recast moved it to
    ///    `'gathering'`); a migration is never rewritten and never shown.
    ///
    /// *(13i-d U7: the tutorial seeder's entry is GONE — U7 rewrote the books
    /// chapter and swept the guide's remaining SHELF/"smart" prose (F-U1-5,
    /// F-U6-3), so the pin now closes over the field guide too.)*
    private static let allowed: [String] = [
        "Sources/VariorumCore/Persistence/",
    ]

    /// The banned spellings, matched case-insensitively. "smart" is a WHOLE
    /// WORD (identifiers like `smartBookMembership` stay — code names are not
    /// the product's words); the rest are phrases.
    private static let bannedWords = ["smart"]
    private static let bannedPhrases = [
        // The AREA's old name (§7): the Bookcase. "shelf" alone stays — it
        // names a shelf (U1's ruled noun).
        "on the shelf", "on your shelf", "shelf menu", "shelf row",
        "shelf right-click", "pin to shelf top",
        // The door that mints a gathering was "Promote to Book…" (U6 (a)).
        "promote to book", "promote tags to a book",
        // The Library's segment (§21) and its day door (U6 (c)).
        "\"posts\"", "on day\\u{2026}",
        // The generic book refusal's dead road (KnownIssues row 106).
        "this book is locked",
    ]

    private func swiftFiles(under root: URL) -> [URL] {
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        return walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    /// A line is code (not a comment or a doc line) for this pin's purpose.
    private func isCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("*")
    }

    /// `word` appears in `text` as a whole word (letters/digits/_ never touch it).
    static func containsWord(_ word: String, in text: String) -> Bool {
        var search = text.startIndex..<text.endIndex
        while let range = text.range(of: word, options: .caseInsensitive, range: search) {
            let before = range.lowerBound > text.startIndex
                ? text[text.index(before: range.lowerBound)] : " "
            let after = range.upperBound < text.endIndex ? text[range.upperBound] : " "
            let boundary: (Character) -> Bool = { !($0.isLetter || $0.isNumber || $0 == "_") }
            if boundary(before) && boundary(after) { return true }
            search = range.upperBound..<text.endIndex
        }
        return false
    }

    @Test func noShippedWordSpeaksTheRetiredVocabulary() throws {
        var offenders: [String] = []
        var scanned = 0
        for rootName in Self.scannedRoots {
            let root = Self.repoRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            for file in swiftFiles(under: root) {
                let relative = file.path.replacingOccurrences(
                    of: Self.repoRoot.path + "/", with: "")
                if Self.allowed.contains(where: { relative.hasPrefix($0) }) { continue }
                scanned += 1
                let source = try String(contentsOf: file, encoding: .utf8)
                for (index, line) in source.split(
                    separator: "\n", omittingEmptySubsequences: false).enumerated()
                where isCode(String(line)) {
                    let text = String(line)
                    for word in Self.bannedWords where Self.containsWord(word, in: text) {
                        offenders.append("\(relative):\(index + 1) — \"\(word)\"")
                    }
                    for phrase in Self.bannedPhrases
                    where text.range(of: phrase, options: .caseInsensitive) != nil {
                        offenders.append("\(relative):\(index + 1) — \(phrase)")
                    }
                }
            }
        }
        #expect(scanned > 400, "the walk must actually reach the app, shared and core code (\(scanned) files)")
        #expect(offenders.isEmpty, """
            A retired word is back in the shipped vocabulary (the sitting record §1/§7/§14/§21 — \
            "smart" is a GATHERING; the area is the BOOKCASE; the Library says NOTES). Use the \
            ruled noun, or — if the spelling is genuinely right — add the file to this pin's \
            allow-list WITH the decision that allows it.
            \(offenders.joined(separator: "\n"))
            """)
    }

    /// The matcher is the pin's own load-bearing part — a control that it
    /// FIRES on the forms it bans and stays quiet on code names (the 18j
    /// ladder's lesson: a pin that cannot fail pins nothing).
    @Test func theMatcherFiresOnTheBannedFormsOnly() {
        #expect(Self.containsWord("smart", in: "Text(\"a Smart book\")"))
        #expect(Self.containsWord("smart", in: "\"smart\""))
        #expect(!Self.containsWord("smart", in: "Queries.smartBookMembership(db)"))
        #expect(!Self.containsWord("smart", in: "let isSmart = true"))
        #expect("Pick it from the book's shelf menu".range(
            of: "shelf menu", options: .caseInsensitive) != nil)
    }

    // MARK: - "savepoint" (13s-b U4 — R-13s-31/32/34, VX-103)
    //
    // Her R-13s-31, verbatim: *"renaming savepoints to commits is a new task
    // for 13s that is being noted - but I want that changed everywhere."*
    // Then R-13s-32, on the tour's step 4: *"that's fine to say keeps a
    // savepoint during the tour - commit twice would just read as weird
    // there, and it's an explanation of the word commit to a non technical
    // audience. keep it"* — whose recorded shape is the reason this fence is
    // NARROWER than the rule above, by design: **commit is the LABEL
    // everywhere; savepoint survives only as the explanatory common noun that
    // defines commit.** So the fence bans the word in LABELS AND HEADERS — a
    // LABEL-SHAPED string literal (`isLabelShaped`) — and leaves explanatory
    // PROSE alone. Whole word, either number, any case; identifiers and keys
    // (`savepoint_cadence`, `SavepointRuns`, `savepointsSection`) never match.
    //
    // It walks the PHONE too (one vocabulary, both platforms — the U4 brief's
    // parity line). The rule above never did, and stays exactly as it was.

    private static let savepointRoots = scannedRoots + ["App/Variorum/VariorumMobile"]

    /// Files whose label-shaped "savepoint" literals are KEYS, never words —
    /// each with the decision that allows it.
    ///
    /// 1. **The schema and the derived search index** name the index's KIND
    ///    key `'savepoint'` (v1_22/v1_23 — local-only, never shown), and a
    ///    migration is never rewritten.
    /// 2. **The one search SQL composer and its count reader**: `'savepoint'`
    ///    is that kind's key and `savepoints` a column alias, inside SQL.
    ///    Neither file renders a word — the search surface's words live in
    ///    `LibrarySearchCopy`/`SearchAnswerCopy` and already say commit
    ///    (R-VX83-10).
    private static let savepointAllowedFiles: [String] = [
        "Sources/VariorumCore/Persistence/",
        "Sources/VariorumCore/Domain/SearchComposer.swift",
        "Sources/VariorumCore/Queries/SearchQueries.swift",
    ]

    /// Single literals that are KEYS inside a file that also holds labels —
    /// named EXACTLY (their scanned text, `#` for an interpolation), so a
    /// label written beside them still trips. Each must still exist: a
    /// stale entry fails the walk.
    private static let savepointAllowedLiterals: [(file: String, literal: String, why: String)] = [
        ("App/Variorum/Variorum/Features/Settings/SettingsShape.swift", "savepoint",
         "a Settings-search KEYWORD on the cadence row — matched, never rendered "
            + "(`SettingsSearch` only ranks by it); the old word still finds the pane"),
        ("App/Variorum/Variorum/Features/Settings/SettingsShape.swift", "savepoints",
         "the pruning row's keyword, the same"),
        ("App/Variorum/VariorumMobile/Features/Takes/MobileBlockHistorySheetView.swift",
         "blockHistory.savepoint.#",
         "an accessibility IDENTIFIER — a UI-test key, never spoken or shown"),
    ]

    @Test func noLabelOrHeaderSaysSavepoint() throws {
        var offenders: [String] = []
        var seenAllowed = Set<String>()
        var scanned = 0
        for rootName in Self.savepointRoots {
            let root = Self.repoRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            for file in swiftFiles(under: root) {
                let relative = file.path.replacingOccurrences(
                    of: Self.repoRoot.path + "/", with: "")
                if Self.savepointAllowedFiles.contains(where: { relative.hasPrefix($0) }) { continue }
                scanned += 1
                let source = try String(contentsOf: file, encoding: .utf8)
                for literal in Self.literals(in: source) where Self.isRetiredLabel(literal.text) {
                    if Self.savepointAllowedLiterals.contains(where: {
                        $0.file == relative && $0.literal == literal.text
                    }) {
                        seenAllowed.insert(relative + "|" + literal.text)
                        continue
                    }
                    offenders.append("\(relative):\(literal.line) — \"\(literal.text)\"")
                }
            }
        }
        #expect(scanned > 600, "the walk must reach the app, shared, core AND phone code (\(scanned) files)")
        #expect(offenders.isEmpty, """
            "Savepoint" is back on a label or a header (R-13s-31 — the word is COMMIT \
            everywhere; R-13s-32 keeps "savepoint" only as explanatory prose that defines \
            commit, which this fence never reads). Say commit, or — if the literal is a KEY, \
            never shown — name it in `savepointAllowedLiterals` WITH the decision.
            \(offenders.joined(separator: "\n"))
            """)
        let stale = Self.savepointAllowedLiterals
            .map { $0.file + "|" + $0.literal }
            .filter { !seenAllowed.contains($0) }
        #expect(stale.isEmpty, "an allow-list entry names a literal that is gone — delete it: \(stale)")
    }

    /// The fence's three load-bearing parts, each made to fail on purpose:
    /// it FIRES on the label forms (a header, a count, a fold line whose
    /// plural is interpolated, a VoiceOver label), and is QUIET on the
    /// tour's frozen sentence (R-13s-32's exemplar), on explanatory prose,
    /// on keys, on identifiers and on comments — and the extractor decodes
    /// escapes and counts lines.
    @Test func theSavepointFenceFiresOnLabelsAndSparesExplanationsAndKeys() {
        func retired(_ source: String) -> [String] {
            Self.literals(in: source).map(\.text).filter(Self.isRetiredLabel)
        }
        #expect(retired(#"static let savepointsSection = "Savepoints""#) == ["Savepoints"])
        #expect(retired(#"factRow("saved", n == 1 ? "1 savepoint" : "\(n) savepoints")"#)
                == ["1 savepoint", "# savepoints"])
        #expect(retired(#"{ "\(count) quiet savepoint\(count == 1 ? "" : "s")" }"#)
                == ["# quiet savepoint#"],
                "the interpolated plural keeps the word whole (`#` is not a letter)")
        #expect(retired(#"label: "\(BlockHistoryCopy.restoreVerb) this savepoint","#)
                == ["# this savepoint"])
        #expect(retired(#"static let title = "Savepoints Variorum takes for you""#)
                == ["Savepoints Variorum takes for you"])

        #expect(retired(#"body: "Notes open in Write. Everything autosaves as you type; commit \u{2318}S in the bottom bar keeps a savepoint of a moment worth keeping. Scroll to the middle of the note and click into a paragraph there.")"#)
                .isEmpty, "the tour's step-4 sentence is explanation (R-13s-32), never a label")
        #expect(retired(#"static let help = "Include your commits \u{2014} the words every savepoint of your takes kept""#)
                .isEmpty, "a long explanatory fragment is prose")
        #expect(retired(#"return "That's a savepoint.""#).isEmpty, "a sentence is prose")
        #expect(retired(#"try upsertSetting(db, key: "savepoint_cadence", value: v)"#).isEmpty)
        #expect(retired(#"let savepoints = SavepointRuns.rows(items)"#).isEmpty)
        #expect(retired(#"// the "Savepoints" header retired at U4"#).isEmpty)
        #expect(retired(#"x = 1 /* "Savepoints" */"#).isEmpty)

        #expect(Self.literals(in: "let a = \"x\"\n\nlet b = \"\\u{2014}\\(y)\"")
                == [Literal(line: 1, text: "x"), Literal(line: 3, text: "\u{2014}#")])
        #expect(Self.isLabelShaped("Old quiet savepoints"))
        #expect(!Self.isLabelShaped("one two three four five six seven"),
                "past the word limit a fragment is explanation")
        #expect(!Self.isLabelShaped("She said \u{201C}saved.\u{201D}"), "a sentence end, inside a closing quote")
    }

    /// A literal is the retired LABEL when it carries the word (either
    /// number) and is label-shaped.
    static func isRetiredLabel(_ text: String) -> Bool {
        (containsWord("savepoint", in: text) || containsWord("savepoints", in: text))
            && isLabelShaped(text)
    }

    /// **The mechanical reading of "a label or a header"**: a string literal
    /// of at most `labelWordLimit` words that does not end a sentence. A
    /// header ("Savepoints"), a count ("1 savepoint"), a picker title, a
    /// menu row, a VoiceOver label — all short and unpunctuated. Explanatory
    /// prose — a sentence, or a fragment of one long enough to explain — is
    /// out of the fence's reach by construction, which is R-13s-32's shape.
    static let labelWordLimit = 6

    static func isLabelShaped(_ text: String) -> Bool {
        let words = text.split { !($0.isLetter || $0.isNumber) }.count
        var end = text.trimmingCharacters(in: .whitespacesAndNewlines)
        while let last = end.last, "\u{201D}\u{2019}\"')".contains(last) { end.removeLast() }
        let endsASentence = end.hasSuffix(".") || end.hasSuffix("?") || end.hasSuffix("!")
        return words <= labelWordLimit && !endsASentence
    }

    /// One string literal's CONTENT and the line it opens on.
    struct Literal: Equatable {
        let line: Int
        let text: String
    }

    /// Every string literal in `source` — `"…"` and `"""…"""`, comments
    /// skipped — with each `\(…)` interpolation replaced by `#` (a non-word
    /// mark, so `savepoint\(…)` still reads as the word it renders) and each
    /// escape DECODED (`\u{2014}` is one dash, not the words "u" and "2014").
    ///
    /// Not `CopyRegisterPinTests.stringLiteralContents`, and on purpose:
    /// that house extractor keeps an escape's text (pins beside it rely on
    /// that), ends a literal at an interpolation's nested quote, and carries
    /// no line — and the label shape COUNTS WORDS and reads the ENDING, so
    /// all three matter here.
    static func literals(in source: String) -> [Literal] {
        let chars = Array(source)
        var found: [Literal] = []
        var i = 0
        var line = 1
        func has(_ pattern: String, at index: Int) -> Bool {
            var k = index
            for expected in pattern {
                guard k < chars.count, chars[k] == expected else { return false }
                k += 1
            }
            return true
        }
        while i < chars.count {
            if chars[i] == "\n" { line += 1; i += 1; continue }
            if has("//", at: i) {
                while i < chars.count, chars[i] != "\n" { i += 1 }
                continue
            }
            if has("/*", at: i) {
                i += 2
                while i < chars.count, !has("*/", at: i) {
                    if chars[i] == "\n" { line += 1 }
                    i += 1
                }
                i += 2
                continue
            }
            guard chars[i] == "\"" else { i += 1; continue }
            let multiline = has("\"\"\"", at: i)
            let opensOn = line
            i += multiline ? 3 : 1
            var text = ""
            while i < chars.count {
                if multiline ? has("\"\"\"", at: i) : (chars[i] == "\"" || chars[i] == "\n") { break }
                if chars[i] == "\\", i + 1 < chars.count {
                    let next = chars[i + 1]
                    if next == "(" {
                        i = Self.afterInterpolation(chars, from: i + 2, line: &line)
                        text.append("#")
                        continue
                    }
                    if next == "u", i + 2 < chars.count, chars[i + 2] == "{",
                       let close = chars[(i + 3)...].firstIndex(of: "}"),
                       let value = UInt32(String(chars[(i + 3)..<close]), radix: 16),
                       let scalar = Unicode.Scalar(value) {
                        text.unicodeScalars.append(scalar)
                        i = close + 1
                        continue
                    }
                    if next == "\n" { line += 1; i += 2; continue }  // a `"""` line continuation
                    text.append(next == "n" || next == "t" ? " " : next)
                    i += 2
                    continue
                }
                if chars[i] == "\n" { line += 1 }
                text.append(chars[i])
                i += 1
            }
            if i < chars.count, chars[i] == "\"" { i += multiline ? 3 : 1 }
            found.append(Literal(line: opensOn, text: text))
        }
        return found
    }

    /// Past an interpolation's closing parenthesis — nested parentheses and
    /// nested string literals (with their own escapes) stepped over.
    private static func afterInterpolation(
        _ chars: [Character], from start: Int, line: inout Int
    ) -> Int {
        var i = start
        var depth = 1
        while i < chars.count, depth > 0 {
            switch chars[i] {
            case "\"":
                i += 1
                while i < chars.count, chars[i] != "\"", chars[i] != "\n" {
                    if chars[i] == "\\" { i += 1 }
                    i += 1
                }
            case "(": depth += 1
            case ")": depth -= 1
            case "\n": line += 1
            default: break
            }
            i += 1
        }
        return i
    }
}
