//
//  ReadmeStartHerePlanTests.swift
//  VariorumTests — VX-306: the readme's Start Here passages are the plan's §7c (5), byte for byte
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-306 — the Start Here passages seeded into the readme are the plan's §7c (5)")
struct ReadmeStartHerePlanTests {
    /// The plan file, read from the repo beside the test target.
    private func planText() throws -> String {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("notes/plans/vx-306-castle-open-road.md")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// §7c (5)'s four passages: each blockquote paragraph, its `**` lead markers dropped and its
    /// line breaks reflowed to single spaces — exactly the seeded block.
    private func planPassages() throws -> [String] {
        let text = try planText()
        guard let start = text.range(of: "**(5) The Start Here chapter**"),
              let end = text.range(of: "## 8. ENVIRONMENT TRAPS", range: start.upperBound..<text.endIndex)
        else { return [] }
        let section = text[start.upperBound..<end.lowerBound]
        return section.components(separatedBy: "\n>\n")
            .map { chunk in
                chunk.split(separator: "\n").map { line -> String in
                    var l = String(line)
                    if l.hasPrefix("> ") { l.removeFirst(2) } else if l.hasPrefix(">") { l.removeFirst() }
                    return l.replacingOccurrences(of: "**", with: "")
                }.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { $0.hasPrefix("Your work is encrypted") || $0.hasPrefix("Write down your twelve words")
                || $0.hasPrefix("Set a passphrase") || $0.hasPrefix("The Apple road is a convenience") }
    }

    @Test func herFiveBlocksStandAndTheFourPassagesFollowThemByteForByte() throws {
        #expect(ReadmeSeeder.paragraphs.count == 9, "her five blocks + the four Start Here passages")
        #expect(ReadmeSeeder.paragraphs[0].hasPrefix("Welcome to Variorum!"))
        let seeded = Array(ReadmeSeeder.paragraphs[5...])
        let drafted = try planPassages()
        #expect(drafted.count == 4, "the plan's §7c (5) carries four passages")
        #expect(seeded == drafted, "the seeded passages are the plan's, byte for byte")
    }

    @Test func noShoutyCapsAndNoMarkdownRideIntoTheSeed() {
        for passage in ReadmeSeeder.paragraphs[5...] {
            #expect(!passage.contains("**"))
            #expect(!passage.contains("  "))
        }
    }
}
