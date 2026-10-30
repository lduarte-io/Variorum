//
//  ReadmeStartHerePlanTests.swift
//  VariorumTests — VX-306: the Start Here passages are the plan's, byte for byte. VX-307 U2c (F-U2b-1): the
//  source RE-ANCHORED — the passages are VX-307's plan's U2c words block now (its passage 2 reworded to the amended
//  rules 2, 3 and 7; passages 1, 3, 4 byte-identical to VX-306's §7c (5), which keeps its drafts as history).
//  VX-105: her finished readme replaced the placeholder WHOLE, so the passages left the readme; they live on in the
//  field guide alone (`TutorialSeeder.startHerePassages` — the protection chapter's key lesson leads with them, and
//  R-105-7 puts them in the first chapter too). The byte-pins stand (the GUIDE's text now); the readme-membership
//  assertions went with the readme home. The type keeps its name so stage commands and history still find it.
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-306/VX-307 — the guide's Start Here passages are the plan's (VX-307 U2c's words block); VX-105: never the readme's")
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

    /// The four passages are the plan's U2c words block, byte for byte — the guide's one copy of them.
    @Test func theFourPassagesAreThePlansByteForByte() throws {
        let seeded = TutorialSeeder.startHerePassages
        let drafted = try planPassages()
        #expect(seeded.count == 4, "four Start Here passages")
        #expect(drafted.count == 4, "the plan's U2c words block carries four passages")
        #expect(seeded == drafted, "the guide's passages are the plan's, byte for byte")
    }

    @Test func noShoutyCapsAndNoMarkdownRideIntoTheSeed() {
        for passage in TutorialSeeder.startHerePassages {
            #expect(!passage.contains("**"))
            #expect(!passage.contains("  "))
        }
    }

    // MARK: - VX-105: the readme home ended; the road is still every store's

    /// The passages speak the road's truths (the key file and its copies, the words shown when she asks, a new-words
    /// door); since VX-329 the road is every store's. VX-105: her finished readme carries NONE of them — the guide
    /// does (RED ON OLD: the old readme's `paragraphs` ended with all four).
    @Test func theReadmeCarriesNoneOfThePassagesAndTheRoadIsEveryStores() {
        #expect(ProtectionRoad.newRoadIsLive && ProtectionRoad.live(debug: false), "every build, every store")
        for passage in TutorialSeeder.startHerePassages {
            #expect(!ReadmeSeeder.paragraphs.contains(passage), "the readme no longer carries: \(passage.prefix(40))")
        }
        for lead in Self.leads {
            #expect(!ReadmeSeeder.paragraphs.contains { $0.hasPrefix(lead) }, "no readme block opens on: \(lead)")
        }
    }

    private static let leads = ["Your work is encrypted", "Write down your twelve words",
                                "Set a passphrase. A passphrase", "The Apple road is a convenience"]

    /// The SOURCE: the four passages are spelled ONCE in the whole seed — in their own file's one declaration
    /// (`TutorialStartHerePassages.swift`, the VX-105 / VX-292 boundary: never inside `TutorialSeeder.swift`); every
    /// guide lesson that carries them reads that constant (R-105-7: "byte-identical via the shared constant"), and the
    /// readme's seeder neither spells nor reads them. The launch still seeds the readme on the one road (no road
    /// parameter is left to choose another). RED ON OLD: the declaration and the join lived in the readme's seeder.
    @Test func theFourPassagesAreSpelledOnceInTheGuideAndNeverInTheReadme() throws {
        let app = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        func code(_ relative: String) throws -> String {
            try String(contentsOf: app.appendingPathComponent(relative), encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
                .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("///") }
                .joined(separator: "\n")
        }
        let passages = try code("Variorum/Features/Tutorial/TutorialStartHerePassages.swift")
        let guide = try code("Variorum/Features/Tutorial/TutorialSeeder.swift")
        let readme = try code("Variorum/Features/Onboarding/BirthFurnitureSeeders.swift")
        #expect(passages.components(separatedBy: "nonisolated static let startHerePassages: [String] = [").count == 2,
                "declared once, in its own file")
        #expect(!guide.contains("static let startHerePassages"), "never re-declared in the seeder")
        #expect(guide.contains("startHerePassages"), "the guide's lessons read the one constant")
        for lead in Self.leads {
            #expect(passages.components(separatedBy: lead).count == 2, "spelled once: \(lead)")
            #expect(!guide.contains(lead), "never re-spelled in a lesson: \(lead)")
            #expect(!readme.contains(lead), "never in the readme's seeder: \(lead)")
        }
        #expect(!readme.contains("startHerePassages"), "the readme's seeder never reads them")
        let launch = try code("Variorum/LaunchFurniture.swift")
        #expect(launch.contains("ReadmeSeeder.seedAtBirth(session: session)"))
        #expect(!launch.contains("onTheNewRoad"), "no road parameter is left")
        let bootstrap = try code("Shared/AppBootstrap.swift")
        #expect(!bootstrap.contains("opensOnTheNewRoad"), "the dev-store fence is gone")
    }
}
