//
//  ReadmeStartHerePlanTests.swift
//  VariorumTests — VX-306: the readme's Start Here passages are the plan's, byte for byte. VX-307 U2c (F-U2b-1): the
//  source RE-ANCHORED — the passages are VX-307's plan's U2c words block now (its passage 2 reworded to the amended
//  rules 2, 3 and 7; passages 1, 3, 4 byte-identical to VX-306's §7c (5), which keeps its drafts as history).
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-306/VX-307 — the Start Here passages seeded into the readme are the plan's (VX-307 U2c's words block)")
struct ReadmeStartHerePlanTests {
    /// The plan file, read from the repo beside the test target — VX-307's since U2c (F-U2b-1, the re-anchor).
    private func planText() throws -> String {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("notes/plans/vx-307-castle-crossings.md")
        return try String(contentsOf: url, encoding: .utf8)
    }

    /// The U2c words block's four passages: each blockquote paragraph, its `**` lead markers dropped and its
    /// line breaks reflowed to single spaces — exactly the seeded block.
    private func planPassages() throws -> [String] {
        let text = try planText()
        guard let start = text.range(of: "**F-U2b-1 — the readme's Start Here passages, as amended**"),
              let end = text.range(of: "## 7. LIVE STATUS", range: start.upperBound..<text.endIndex)
        else { return [] }
        let section = text[start.upperBound..<end.lowerBound]
        // Only the blockquote lines are the passages (the header's tail and the later (6)/(7) blocks are not);
        // a bare ">" line separates two passages.
        let quoted = section.split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init).filter { $0.hasPrefix(">") }
        return quoted.joined(separator: "\n").components(separatedBy: "\n>\n")
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
        #expect(drafted.count == 4, "the plan's U2c words block carries four passages")
        #expect(seeded == drafted, "the seeded passages are the plan's, byte for byte")
    }

    @Test func noShoutyCapsAndNoMarkdownRideIntoTheSeed() {
        for passage in ReadmeSeeder.paragraphs[5...] {
            #expect(!passage.contains("**"))
            #expect(!passage.contains("  "))
        }
    }

    // MARK: - Ladder round 2, m2 → VX-329 U1: the passages seed in EVERY store (the road is the only road)

    /// The passages speak the road's truths (the key file and its copies, the words shown once at the creation, a
    /// new-words door). Until VX-329 they seeded only where a store opened on the new road (the dev store in a Debug
    /// build); with the switch flipped and today's road gone, every store's readme is her five blocks and the four.
    @Test func theFourPassagesSeedInEveryStore() {
        #expect(ReadmeSeeder.herBlocks.count == 5 && ReadmeSeeder.startHerePassages.count == 4)
        #expect(ReadmeSeeder.paragraphs == ReadmeSeeder.herBlocks + ReadmeSeeder.startHerePassages)
        #expect(ProtectionRoad.newRoadIsLive && ProtectionRoad.live(debug: false), "every build, every store")
    }

    /// The SOURCE: the four passages live only in `startHerePassages` (never among her blocks), joined once after them,
    /// and the launch seeds that one list (no road parameter is left to choose another) — so no later edit can splice
    /// them among her blocks unseen.
    @Test func theFourPassagesAreJoinedOnceAfterHerBlocksInTheSource() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        func code(_ relative: String) throws -> String {
            try String(contentsOf: app.appendingPathComponent(relative), encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("///") }
                .joined(separator: "\n")
        }
        let seeder = try code("Variorum/Features/Onboarding/BirthFurnitureSeeders.swift")
        let herStart = try #require(seeder.range(of: "nonisolated static let herBlocks: [String] = ["))
        let passagesStart = try #require(seeder.range(of: "nonisolated static let startHerePassages: [String] = ["))
        let herBody = seeder[herStart.upperBound..<passagesStart.lowerBound]
        for lead in ["Your work is encrypted", "Write down your twelve words", "Set a passphrase. A passphrase",
                     "The Apple road is a convenience"] {
            #expect(!herBody.contains(lead), "a Start Here passage sits among her blocks: \(lead)")
            #expect(seeder.components(separatedBy: lead).count == 2, "the passage is spelled once: \(lead)")
        }
        #expect(seeder.contains("nonisolated static var paragraphs: [String] { herBlocks + startHerePassages }"))
        #expect(seeder.components(separatedBy: "startHerePassages").count == 3,
                "startHerePassages is declared once and joined once")
        let launch = try code("Variorum/LaunchFurniture.swift")
        #expect(launch.contains("ReadmeSeeder.seedAtBirth(session: session)"))
        #expect(!launch.contains("onTheNewRoad"), "no road parameter is left")
        let bootstrap = try code("Shared/AppBootstrap.swift")
        #expect(!bootstrap.contains("opensOnTheNewRoad"), "the dev-store fence is gone")
    }
}
