//
//  OpsRefusalTableIntegrityTests.swift
//  VariorumTests
//
//  18m U3 — **the shared refusal table names no platform's doors** (MobileSoul
//  §4 item 4, read from the other side: a shared home must not hold words
//  naming a platform's own doors).
//
//  The table moved to `Shared/OpsRefusalTable.swift` so both apps speak it.
//  The Mac's chords and the phone's menu rows reach it only as ROAD values
//  each platform supplies from its own target — which the compiler already
//  enforces for the road CONSTANTS. It cannot enforce the STRINGS: a chord or
//  a door word typed into a shared sentence compiles fine and then tells the
//  other platform's user to press a key she does not have. This pin is that
//  ban, as a source walk over the shared file's string literals (the
//  `StatusSeamVocabularyTests` / `MobileNoRedirectSweepTests` house form),
//  naming BOTH platforms' door and chord vocabularies — and a second test
//  proves the ban bites on each platform's real vocabulary, so it can never
//  pass vacuously.
//

import Foundation
import Testing

@Suite("The shared refusal table names no platform's doors (18m U3 — MobileSoul §4 item 4)")
struct OpsRefusalTableIntegrityTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The Mac's doors and chords — glyphs AND their `\u{…}` spellings (the
    /// literal extractor keeps an escape's text), its surfaces, its ⌘-click
    /// pick vocabulary, its ceremony, and its note-seal door words (which
    /// arrive as a platform's `SealedNoteCopy.Words`, never as a literal).
    static let macVocabulary = [
        "⌘", "⌥", "⇧", "⌃", "⏎", "⌫", "⎋",
        "u{2318}", "u{2325}", "u{21e7}", "u{2303}", "u{23ce}", "u{232b}", "u{238b}",
        "sidebar", "bottom bar", "menu bar", "picked", "pick again", "choosing takes",
        "sealed", "unseal",
    ]

    /// The phone's doors: the ⋯ menu, the takes sheet's ⑂ road, its note-lock
    /// door.
    static let phoneVocabulary = [
        "⋯", "u{22ef}", "⑂", "u{2442}", "takes sheet", "Lock Note", "Unlock Note",
    ]

    /// Either platform named outright.
    private static var platformName: Regex<Substring> {
        /\b(?:Mac|iPhone)\b/.wordBoundaryKind(.simple)
    }

    private func literals(of relativePath: String) throws -> [String] {
        let url = Self.appRoot.appendingPathComponent(relativePath)
        #expect(FileManager.default.fileExists(atPath: url.path), "missing: \(relativePath)")
        let source = try String(contentsOf: url, encoding: .utf8)
        return CopyRegisterPinTests.stringLiteralContents(of: source)
    }

    private func hits(_ literal: String, _ vocabulary: [String]) -> [String] {
        let lowered = literal.lowercased()
        return vocabulary.filter { lowered.contains($0.lowercased()) }
    }

    @Test func theSharedTableHoldsNoPlatformsDoorOrChord() throws {
        let literals = try literals(of: "Shared/OpsRefusalTable.swift")
        #expect(literals.count > 20, "the walk read the real table (\(literals.count) literals)")
        var offenders: [String] = []
        for literal in literals {
            let found = hits(literal, Self.macVocabulary) + hits(literal, Self.phoneVocabulary)
            if !found.isEmpty || literal.contains(Self.platformName) {
                offenders.append("\"\(literal.prefix(90))\" — \(found)")
            }
        }
        #expect(offenders.isEmpty,
                "a shared refusal names one platform's door — make it a road: \(offenders)")
    }

    /// The ban must bite: each platform's own refusal home DOES carry its
    /// vocabulary, and the same walk finds it there.
    @Test func theBanBitesOnEachPlatformsRealVocabulary() throws {
        let macHalf = try literals(of: "Variorum/Registry/OpsRefusalCopy.swift")
        #expect(macHalf.contains { !hits($0, Self.macVocabulary).isEmpty },
                "the Mac half's chords are what the ban names")
        let phoneModel = try literals(of: "VariorumMobile/Features/Write/MobileEditorViewModel.swift")
        #expect(phoneModel.contains { !hits($0, Self.phoneVocabulary).isEmpty },
                "the phone's ⋯ / ⑂ roads are what the ban names")
    }
}
