//
//  MobilePhoneTypeSourceTests.swift
//  VariorumMobileTests
//
//  VM-48 (the VM-47 run, batch 1) — **the guard pin the type pass earns.**
//  Audit G counted 241 of the phone's 352 SwiftUI type sites at the Mac's
//  11.5 pt caption (`tokens.small`), seven UIKit sizes between 10 and 13,
//  and a filter row free to shrink its words to 8 pt. The batch moved every
//  site to a role of the phone layer (`PhoneType`); this walk of the source
//  keeps it there: a phone view that reaches for the Mac's caption, or sets
//  a size under the 13 pt floor, fails the suite.
//
//  THE RULE, over every Swift file under `VariorumMobile/` outside the two
//  debug harnesses (`Spike/`, `Features/Perf/`), code lines only:
//  · no `tokens.small` (the brief's named slot), and — since every site
//    reads a role — none of the Mac's other type slots either;
//  · no literal point size under 13 (`size:` / `ofSize:` / `withSize(`);
//  · no `.caption` / `.caption2` text style (12 and 11 pt at the default);
//  · no literal `minimumScaleFactor(` — a row that must shrink to fit says
//    `shrinkingToFloor`, which stops at 13 pt.
//
//  This is a source scan like `NoLiteralColourTests` (the Mac's): NEW
//  COVERAGE that holds the migration, not a red-on-old pin of a defect.
//  It is red on the pre-batch tree — measured with these exact patterns over
//  `fe85ea6d5`'s phone tree: 332 type-slot reads and 32 sub-13 sites (the
//  10 / 10.5 / 11 / 11.5 / 12 / 12.5 literals, two caption styles, the 0.7
//  scale factor) — and clean after it.
//

import Foundation
import Testing

@Suite("Phone type — the source guard (VM-48)")
struct MobilePhoneTypeSourceTests {
    private static var phoneRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("VariorumMobile", isDirectory: true)
    }

    /// The two debug harnesses the brief leaves out.
    private static let excludedPrefixes = ["Spike/", "Features/Perf/"]

    private func phoneFiles() -> [(relative: String, url: URL)] {
        let root = Self.phoneRoot
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        return walker.compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .map { (relative: $0.path.replacingOccurrences(of: root.path + "/", with: ""), url: $0) }
            .filter { file in !Self.excludedPrefixes.contains { file.relative.hasPrefix($0) } }
    }

    /// A line is code (not a comment or a doc line) for this pin's purpose.
    private func isCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("///") && !trimmed.hasPrefix("*")
    }

    /// Every code line of every phone file, numbered.
    private func codeLines() throws -> [(where: String, text: String)] {
        var lines: [(where: String, text: String)] = []
        for file in phoneFiles() {
            let source = try String(contentsOf: file.url, encoding: .utf8)
            for (index, line) in source.split(
                separator: "\n", omittingEmptySubsequences: false).enumerated()
            where isCode(String(line)) {
                lines.append(("\(file.relative):\(index + 1)", String(line)))
            }
        }
        return lines
    }

    @Test func theWalkReachesThePhonesViews() {
        let files = phoneFiles().map(\.relative)
        // 79 files at the batch (Spike/ and Perf/ excluded).
        #expect(files.count > 60, "the walk must reach the phone's views (\(files.count) files)")
        #expect(files.contains("Features/Shell/MobileShelfView.swift"))
        #expect(files.contains("Features/Write/MobileCommentsSheetView.swift"))
        #expect(!files.contains { $0.hasPrefix("Spike/") || $0.hasPrefix("Features/Perf/") })
    }

    /// **The brief's named pin:** no phone view reads `tokens.small` — and,
    /// since every type site now reads a role, none of the Mac's other
    /// type slots.
    @Test func noPhoneViewReadsTheMacsTypeSlots() throws {
        let slot = try Regex(#"tokens\.(small|body|title|heading|mono|navigation)\b"#)
        let offenders = try codeLines().filter { $0.text.contains(slot) }
        #expect(offenders.isEmpty, """
            The phone reads a ROLE of its own type layer (`.phoneType(_:_:)`, \
            `face.font(_:)`), never the Mac's type slots — `tokens.small` is the \
            Mac's 11.5 pt caption (VM-48).
            \(offenders.map { "\($0.where) — \($0.text.trimmingCharacters(in: .whitespaces))" }.joined(separator: "\n"))
            """)
    }

    /// **The shared pages' phone arms read the roles too** (VM-47, the walk's
    /// fixes batch 2): the Account sheet's styled header drew its tab words in
    /// `tokens.heading` and its Close in `tokens.small` (11.5 pt on the phone),
    /// because this guard walked `VariorumMobile/` only. A phone arm in
    /// `Shared/` is told from the Mac's by the styling seam it reads through —
    /// `SharedPageStyle` (`style.tokens` / `pageStyle?.tokens`), which is nil
    /// on the Mac by construction (`SharedPageStyle.swift`), so a type slot
    /// read through it is a phone read. Red on old: the header's two reads.
    @Test func noSharedPhoneArmReadsTheMacsTypeSlots() throws {
        let shared = Self.phoneRoot.deletingLastPathComponent().appendingPathComponent("Shared", isDirectory: true)
        let walker = try #require(FileManager.default.enumerator(at: shared, includingPropertiesForKeys: nil))
        let slot = try Regex(#"(?:\bstyle|\bpageStyle[?!]?)\.tokens\.(small|body|title|heading|mono|navigation)\b"#)
        var files = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: shared.path + "/", with: "")
            files += 1
            let source = try String(contentsOf: file, encoding: .utf8)
            for (index, line) in source.split(separator: "\n", omittingEmptySubsequences: false).enumerated()
            where isCode(String(line)) && String(line).contains(slot) {
                offenders.append("Shared/\(relative):\(index + 1) — \(line.trimmingCharacters(in: .whitespaces))")
            }
        }
        #expect(files > 20, "the walk must reach the shared pages (\(files) files)")
        #expect(offenders.isEmpty, """
            A shared page's PHONE arm reads the Mac's type slot (through \
            `SharedPageStyle`) — read a role (`.phoneType(_:_:)`) or the layer's \
            control instead:
            \(offenders.joined(separator: "\n"))
            """)
    }

    /// **Nothing on the phone is set below 13 pt.**
    @Test func noPhoneViewSetsASizeUnderTheFloor() throws {
        let literal = try Regex(#"(?:\bofSize|\bsize|withSize\()\s*:?\s*([0-9]+(?:\.[0-9]+)?)"#)
        let captionStyle = try Regex(
            #"\.font\(\s*(?:\.system\(\s*)?\.caption2?\b|Font\.caption2?\b|forTextStyle:\s*\.caption[12]?\b"#)
        var offenders: [String] = []
        for line in try codeLines() {
            for match in line.text.matches(of: literal) {
                guard let number = match.output[1].substring.flatMap({ Double($0) }) else { continue }
                if number < 13 { offenders.append("\(line.where) — size \(number)") }
            }
            if line.text.contains(captionStyle) {
                offenders.append("\(line.where) — a caption text style (under 13 pt)")
            }
            if line.text.contains("minimumScaleFactor(") {
                offenders.append("\(line.where) — a literal minimumScaleFactor (use shrinkingToFloor)")
            }
        }
        #expect(offenders.isEmpty, """
            Nothing on the phone is set below 13 pt (VM-48, the sizing sheet). \
            Read a role; a row that must shrink to fit uses `shrinkingToFloor`.
            \(offenders.joined(separator: "\n"))
            """)
    }
}
