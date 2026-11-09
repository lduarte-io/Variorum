import Foundation
import Testing

/// **VX-939 (A-940-1) — the letter's drift pin.** Her letter lives in three copies that must stay
/// byte-equal: `ReadmeSeeder.paragraphs` (the compiled literals the app seeds,
/// `App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift`),
/// `notes/plans/vx-105-letter-content/read-me.txt` (her capture artifact and the app pins' answer
/// key: `LaunchFurnitureTests` asserts the literals ARE its paragraphs), and `LETTER.md` at the
/// repo root (the repo's face, which nothing in the app reads). This suite closes the loop
/// headlessly: LETTER.md's paragraphs ARE read-me.txt's, by the answer key's own split rule, so the
/// three copies agree mechanically rather than by comments kept by hand.
///
/// The two files differ only where they must. read-me.txt opens on its capture-token header and a
/// blank line; LETTER.md opens on one HTML comment (hidden on GitHub's render) saying what the file
/// is. Each is skipped exactly; everything after it is her words. Record:
/// `notes/plans/fixes/vx-940-pre-oss-followups.md` (the W1 and W2 records).
@Suite("VX-939 — LETTER.md is her letter, paragraph for paragraph (the answer key's split rule)")
struct LetterDriftTests {
    static let repo = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // Tests/VariorumCoreTests
        .deletingLastPathComponent()  // Tests
        .deletingLastPathComponent()  // repo root

    static func text(_ path: String) throws -> String {
        try String(contentsOf: repo.appendingPathComponent(path), encoding: .utf8)
    }

    /// The answer key's rule (`LaunchFurnitureTests.herReadmeFileParagraphs`): her text trimmed of
    /// the newlines at its ends, split at blank lines.
    static func paragraphs(_ body: String) -> [String] {
        body.trimmingCharacters(in: .newlines).components(separatedBy: "\n\n")
    }

    @Test func letterMarkdownCarriesTheAnswerKeysParagraphsExactly() throws {
        // read-me.txt: line 1 is the capture-token header, line 2 is blank, her words from line 3.
        var lines = try Self.text("notes/plans/vx-105-letter-content/read-me.txt")
            .components(separatedBy: "\n")
        let header = lines.removeFirst()
        #expect(header.hasPrefix("{t:\""), "line 1 is the capture-token header, never her words")
        #expect(lines.first == "", "a blank line follows the header")
        let answerKey = Self.paragraphs(lines.joined(separator: "\n"))

        // LETTER.md: one leading HTML comment, then her words.
        let letter = try Self.text("LETTER.md")
        #expect(letter.hasPrefix("<!--\n"), "LETTER.md opens on its comment")
        let close = try #require(letter.range(of: "\n-->\n"), "the comment closes")
        let body = String(letter[close.upperBound...])
        #expect(!body.contains("<!--"), "no second comment inside her words")
        let face = Self.paragraphs(body)

        #expect(answerKey.count > 1, "the answer key read as her letter, not as nothing")
        #expect(face.count == answerKey.count, "as many paragraphs in LETTER.md as in read-me.txt")
        for (index, (key, mine)) in zip(answerKey, face).enumerated() {
            #expect(mine == key, """
                paragraph \(index + 1) of LETTER.md differs from read-me.txt's — her text changes in all \
                three copies (LETTER.md, read-me.txt, ReadmeSeeder.paragraphs) in one commit
                """)
        }
    }
}
