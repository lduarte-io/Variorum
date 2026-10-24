//
//  WordsFieldsConcealTests.swift
//  VariorumTests — VX-329 R1: VX-463 (VX-309's walk: the twelve-words fields rendered typed words in CLEAR TEXT where the
//  passphrase field beside them concealed — two captures holding the dev words were deleted uncommitted). Her ruling at the
//  2026-10-22 sitting (QUESTIONS #237): "conceal with a reveal eye." Every field a person types the twelve words into —
//  the lobby's (both platforms), Make this my library's, the crossings', the join's / Move's / the follow's, set-up's, and
//  the reset door's — renders through `PeekableSecretField`, the passphrase's ONE shared concealing field with its reveal
//  eye (hidden until toggled; back to hidden when the field clears; `privacySensitive` over the pair). A ruled design row:
//  its evidence is the stage batch's walk capture — this STRUCTURAL pin, read from the product's sources, keeps a plain
//  text field from coming back. Also runs headless in the implementer's SwiftPM harness (it reads files).
//

import Foundation
import Testing

@Suite("VX-463 — every typed-words field conceals like the passphrase, with its reveal eye (source)")
struct WordsFieldsConcealTests {
    /// `App/Variorum/` — through the symlink a headless harness reads this file by, when there is one.
    static let appRoot = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // Protection
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum

    /// Every product source of both apps — never a test's.
    static func productSources() -> [URL] {
        ["Shared", "Variorum", "VariorumMobile"].flatMap { folder -> [URL] in
            let root = appRoot.appendingPathComponent(folder, isDirectory: true)
            guard let walk = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) else { return [] }
            return walk.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
        }
    }

    /// A source's CODE — every line with its `//` comment cut off.
    static func code(_ url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    /// Each `name(…)` call's argument text, to its matching parenthesis (`name` not preceded by a letter or digit).
    static func calls(of name: String, in text: String) -> [String] {
        var found: [String] = []
        var search = text.startIndex..<text.endIndex
        while let hit = text.range(of: name + "(", range: search) {
            search = hit.upperBound..<text.endIndex
            if hit.lowerBound > text.startIndex {
                let before = text[text.index(before: hit.lowerBound)]
                if before.isLetter || before.isNumber || before == "_" { continue }
            }
            var depth = 1
            var index = hit.upperBound
            while index < text.endIndex, depth > 0 {
                if text[index] == "(" { depth += 1 } else if text[index] == ")" { depth -= 1 }
                index = text.index(after: index)
            }
            found.append(String(text[hit.upperBound..<index]))
        }
        return found
    }

    /// The labels of the fields a person types the twelve words into.
    static let wordsLabels = [
        "ProtectionWords.wordsPlaceholder", "ProtectionWords.makeMineWordsField", "ProtectionWords.crossingWordsField",
        "ProtectionWords.joinWordsField", "ProtectionWords.followWordsField", "ProtectionWords.resetPassphraseWordsField",
        // VX-510 D-B7 — VX-513: the read-only check's one field takes the passphrase OR the twelve words.
        "ProtectionWords.checkSecretsField",
    ]

    @Test func noWordsFieldIsAPlainTextField() throws {
        let sources = Self.productSources()
        #expect(sources.count > 100, "the walk reads the product's sources (\(sources.count) found)")
        var plain: [String] = []
        for url in sources {
            for call in Self.calls(of: "TextField", in: try Self.code(url)) {
                let typesWords = Self.wordsLabels.contains { call.contains($0) }
                    || call.contains("$words") || call.contains("$wordsText")
                if typesWords { plain.append("\(url.lastPathComponent): TextField(\(call.prefix(80))") }
            }
        }
        #expect(plain.isEmpty, "a twelve-words field in clear text: \(plain)")
    }

    @Test func everyWordsFieldIsThePasswordsSharedConcealingField() throws {
        let sites: [(file: String, label: String)] = [
            ("Variorum/StoreLockView.swift", "ProtectionWords.wordsPlaceholder"),
            ("VariorumMobile/Features/Protection/MobileRoadFaces.swift", "ProtectionWords.wordsPlaceholder"),
            ("Variorum/Features/Protection/CopyDoorsSheet.swift", "ProtectionWords.makeMineWordsField"),
            ("Variorum/Features/Protection/RoadCrossingSheet.swift", "ProtectionWords.crossingWordsField"),
            ("Variorum/Features/Protection/RoadAccountSheet.swift", "ProtectionWords.joinWordsField"),
            ("Variorum/Features/Protection/RoadAccountSheet.swift", "ProtectionWords.followWordsField"),
            ("Variorum/Features/Protection/RoadAccountSheet.swift", "ProtectionWords.crossingWordsField"),
            ("Variorum/Features/Protection/RoadKeyDoorSheet.swift", "ProtectionWords.resetPassphraseWordsField"),
            ("Variorum/Features/Protection/RoadSecretCheckSheet.swift", "ProtectionWords.checkSecretsField"),
        ]
        for site in sites {
            let text = try Self.code(Self.appRoot.appendingPathComponent(site.file))
            let concealed = Self.calls(of: "PeekableSecretField", in: text).contains { $0.contains(site.label) }
            #expect(concealed, "\(site.file): the \(site.label) field is the shared concealing field")
        }
        // The shared field: hidden until the eye is pressed, hidden again when the field clears.
        let shared = try Self.code(Self.appRoot.appendingPathComponent("Shared/PeekableSecretField.swift"))
        #expect(shared.contains("SecureField(label, text: $text)") && shared.contains("@State private var revealed = false")
                && shared.contains("if newValue.isEmpty { revealed = false }") && shared.contains(".privacySensitive()"))
    }
}
