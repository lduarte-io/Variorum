//
//  CopyRegisterPinTests.swift
//  VariorumTests
//
//  pre-13x 5a — THE TWO-REGISTER RULE, pinned (the postures design §1.22;
//  `notes/plans/pre-13x-copy.md`'s vocabulary head): everyday surfaces
//  name no key-family internal — *box · vault · escrow · KDF · token ·
//  session · RLS* appear in NO user-facing string. ONE forbidden list,
//  both platforms (the phone's twin in `MobileStructuralTests` reads the
//  same words over its own shipped roots). The walk is over STRING
//  LITERALS (comments narrate the internals legitimately — only what a
//  user can read is policed; the `MobileNoRedirectSweepTests` extractor's
//  shape) of the copy HOMES and the faces that render inline literals,
//  plus the seeded book's own text. Known violators outside the copy
//  homes are EXEMPTED by exact literal and listed in copy §11 for 13s — a
//  re-voice that keeps a word here reds this pin.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The two-register rule (pre-13x 5a — no key-family internal in user copy)")
struct CopyRegisterPinTests {
    static var forbidden: Regex<Substring> {
        /\b(?:box|boxes|vault|vaults|escrow|escrowed|kdf|token|tokens|session|sessions|rls)\b/
            .ignoresCase().wordBoundaryKind(.simple)
    }

    /// The copy homes and the faces with inline literals, relative to `App/Variorum`.
    static let copyHomes: [String] = [
        "Shared/StoreProtection.swift", "Shared/PostureCopy.swift", "Shared/KeyDoorCopy.swift",
        "Shared/SampleLibrary/SampleLibraryEncryptionBook.swift",
        "Shared/EncryptionViews.swift", "Shared/KeyDoorView.swift", "Shared/KeyDoorModel.swift",
        "Shared/PostureSwitchModel.swift", "Shared/PostureFollowModel.swift",
        "Shared/SyncEnrollmentView.swift", "Shared/SyncEnrollmentModel.swift",
        "Shared/EncryptionSession.swift",
        "Variorum/StoreLockView.swift", "Variorum/LibraryMissingView.swift",
        "Variorum/ProtectionStatusRow.swift",
        "Variorum/Features/Settings/ProtectionPane.swift",
        "Variorum/Features/Settings/DataSafetyPane.swift",
        // VX-306 U2: the rebuilt protection core's words, in ONE file (§7c — the faces read them from here).
        "Shared/Protection/ProtectionWords.swift",
    ]

    /// The known violators OUTSIDE the copy homes proper — 14b-era
    /// sentences the brief routes to 13s (copy §11's table). Exact literal
    /// contents; a re-voice that drops one of these must drop its line.
    static let exemptLiterals: Set<String> = [
        "That recovery phrase doesn't unlock this account's vault.",
        "No encryption vault exists for this account yet — run setup first.",
        "This account already has an encryption vault — enroll with its passphrase instead.",
        "The vault just changed on another device — nothing was overwritten. Try again from the current state.",
        "Passphrase KDF derivation: (seconds, format: .fixed(precision: 3)) s on this device",  // a logger line, never a face
    ]

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    @Test func noUserFacingStringInTheCopyHomesNamesAKeyFamilyInternal() throws {
        var offenders: [String] = []
        var literals = 0
        for home in Self.copyHomes {
            let url = Self.appRoot.appendingPathComponent(home)
            #expect(FileManager.default.fileExists(atPath: url.path), "copy home missing: \(home)")
            let source = try String(contentsOf: url, encoding: .utf8)
            for literal in Self.stringLiteralContents(of: source) {
                literals += 1
                guard literal.contains(Self.forbidden), !Self.exemptLiterals.contains(literal) else { continue }
                offenders.append("\(home): \"\(literal.prefix(90))\"")
            }
        }
        #expect(literals > 300, "the walk must actually reach the copy homes' strings")
        #expect(offenders.isEmpty, "the two-register rule: \(offenders)")
    }

    /// The seeded book (copy §7b verbatim) — every paragraph, with the ONE
    /// exemption the copy itself carries: Chapter 5's *"Signing in with your
    /// account password gets you a session, not a key."* (copy §7b's own
    /// text against copy §7b's own rule — recorded in the 5a record's
    /// QUESTIONS; 13s's).
    @MainActor
    @Test func theEncryptionBookNamesNoKeyFamilyInternalButItsOneRecordedSentence() throws {
        let chapters = try SampleLibrarySeeder.loadStories(for: .encryptionExplained)
        #expect(chapters.count == 8)
        var offenders: [String] = []
        for chapter in chapters {
            for paragraph in chapter.text.split(separator: "\n").map(String.init) where paragraph.contains(Self.forbidden) {
                if paragraph.contains("gets you a session, not a key.") { continue }
                offenders.append("\(chapter.title): \(paragraph.prefix(80))")
            }
        }
        #expect(offenders.isEmpty, "the book's register: \(offenders)")
        #expect(!SampleLibraryEncryptionBook.aboutThisBook.contains(Self.forbidden),
                "the front-matter note carries the definitions, never the writers' forbidden list")
    }

    /// Swift string-literal CONTENTS (`"…"` and `"""…"""`), comments
    /// skipped — the `MobileNoRedirectSweepTests` extractor, verbatim.
    static func stringLiteralContents(of source: String) -> [String] {
        var literals: [String] = []
        var current = ""
        let chars = Array(source)
        var i = 0
        enum State { case code, lineComment, blockComment, string, multiline }
        var state = State.code
        var blockDepth = 0
        func has(_ pattern: String) -> Bool {
            i + pattern.count <= chars.count
                && String(chars[i..<i + pattern.count]) == pattern
        }
        while i < chars.count {
            switch state {
            case .code:
                if has("\"\"\"") { state = .multiline; current = ""; i += 3 }
                else if has("//") { state = .lineComment; i += 2 }
                else if has("/*") { state = .blockComment; blockDepth = 1; i += 2 }
                else if chars[i] == "\"" { state = .string; current = ""; i += 1 }
                else { i += 1 }
            case .lineComment:
                if chars[i] == "\n" { state = .code }
                i += 1
            case .blockComment:
                if has("/*") { blockDepth += 1; i += 2 }
                else if has("*/") { blockDepth -= 1; i += 2; if blockDepth == 0 { state = .code } }
                else { i += 1 }
            case .string:
                if chars[i] == "\\", i + 1 < chars.count { current.append(chars[i + 1]); i += 2 }
                else if chars[i] == "\"" { literals.append(current); state = .code; i += 1 }
                else if chars[i] == "\n" { state = .code; i += 1 }
                else { current.append(chars[i]); i += 1 }
            case .multiline:
                if has("\"\"\"") { literals.append(current); state = .code; i += 3 }
                else if chars[i] == "\\", i + 1 < chars.count { current.append(chars[i + 1]); i += 2 }
                else { current.append(chars[i]); i += 1 }
            }
        }
        return literals
    }
}
