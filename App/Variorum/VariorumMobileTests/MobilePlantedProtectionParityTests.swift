//
//  MobilePlantedProtectionParityTests.swift
//  VariorumMobileTests
//
//  VM-8 ladder L1 — round 1's NIT-5 GUARD (`notes/plans/vm-8-ladder-round1.md`): `MobilePlantedProtection.swift` is a
//  verbatim copy of the Mac test target's planted protection support (the two test bundles are separate modules, so the
//  phone's posture pins need their own copy — the copy's own header says "keep the two in step; the Mac's copy is the
//  reference"). Nothing enforced that. This suite does: every top-level declaration the copy carries — its `///` doc
//  comment and its whole body — is BYTE-IDENTICAL to the same-named declaration in the Mac's
//  `VariorumTests/Protection/ProtectionTestSupport.swift` or `ProtectionAccountSupport.swift`. The files' headers and
//  imports differ BY DESIGN (each bundle `@testable`-imports its own app) and are not compared; the Mac's support declares
//  more than the copy needs (those are not the copy's to carry). A drift on either side trips it, naming the first line.
//

import Foundation
import Testing

@Suite("VM-8 ladder L1 — the phone's copy of the planted protection support stays the Mac's (NIT-5's guard)")
struct MobilePlantedProtectionParityTests {
    static let appRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumMobileTests
        .deletingLastPathComponent()  // App/Variorum

    static let copy = "VariorumMobileTests/MobilePlantedProtection.swift"
    static let references = [
        "VariorumTests/Protection/ProtectionTestSupport.swift",
        "VariorumTests/Protection/ProtectionAccountSupport.swift",
    ]

    /// The top-level declarations of a Swift source, by name: each one's `///` doc comment and its whole body, from its
    /// opening line to the first closing brace at column zero (the support's declarations are all brace-bodied).
    static func declarations(_ source: String) -> [(name: String, text: String)] {
        let lines = source.components(separatedBy: "\n")
        var found: [(name: String, text: String)] = []
        var index = 0
        while index < lines.count {
            guard let name = declaredName(lines[index]) else {
                index += 1
                continue
            }
            var start = index
            while start > 0, lines[start - 1].hasPrefix("///") { start -= 1 }
            var end = index
            while end < lines.count - 1, lines[end] != "}" { end += 1 }
            found.append((name, lines[start...end].joined(separator: "\n")))
            index = end + 1
        }
        return found
    }

    /// The name a top-level line declares (nil: not a declaration's opening line — indented, a comment, a brace, an import).
    static func declaredName(_ line: String) -> String? {
        guard let first = line.first, first != " ", first != "/", first != "}" else { return nil }
        let words = line.split(separator: " ")
        for (offset, word) in words.enumerated() where ["class", "struct", "enum", "extension", "actor"].contains(word) {
            guard offset + 1 < words.count else { return nil }
            let name = words[offset + 1].prefix { $0.isLetter || $0.isNumber || $0 == "_" }
            return name.isEmpty ? nil : String(name)
        }
        return nil
    }

    /// The first line where two declarations part, said for the failure.
    static func firstDifference(_ copy: String, _ reference: String) -> String {
        let a = copy.components(separatedBy: "\n")
        let b = reference.components(separatedBy: "\n")
        for line in 0..<max(a.count, b.count) {
            let left = line < a.count ? a[line] : "(nothing)"
            let right = line < b.count ? b[line] : "(nothing)"
            if left != right { return "line \(line + 1) of the declaration — the copy: \(left) · the Mac's: \(right)" }
        }
        return "(none)"
    }

    @Test func everyCopiedDeclarationIsTheMacsByteForByte() throws {
        let copied = Self.declarations(
            try String(contentsOf: Self.appRoot.appendingPathComponent(Self.copy), encoding: .utf8))
        var reference: [String: String] = [:]
        for file in Self.references {
            let source = try String(contentsOf: Self.appRoot.appendingPathComponent(file), encoding: .utf8)
            for declaration in Self.declarations(source) where reference[declaration.name] == nil {
                reference[declaration.name] = declaration.text
            }
        }
        let names = copied.map(\.name)
        #expect(names.count >= 8, "the copy's declarations were read (not hollow) — \(names)")
        #expect(Set(names).count == names.count, "each name copied once — \(names)")
        for declaration in copied {
            guard let mac = reference[declaration.name] else {
                Issue.record("\(declaration.name) is in the copy but in neither Mac support file — the copy grew its own")
                continue
            }
            #expect(declaration.text == mac,
                    "\(declaration.name) drifted from the Mac's support: \(Self.firstDifference(declaration.text, mac))")
        }
    }
}
