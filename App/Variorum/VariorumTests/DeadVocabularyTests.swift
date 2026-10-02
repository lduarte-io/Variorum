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
}
