//
//  MobileLookSourceTests.swift
//  VariorumMobileTests
//
//  VM-51 (the VM-47 run, batch 3) — source pins for the look, in the style of
//  the Mac's `NoLiteralColourTests` and the phone's `MobilePhoneTypeSourceTests`:
//
//  1. **The grounds** (her R-47-1, "prose should not be on the tint"): where
//     her words are listed or read — the three roots' lists, a book's notes,
//     Archived, the Trash, Versions — the ground is the paper
//     (`tokens.surface`); bars, sheets and bands stay on the room. Read's
//     cream page sits on the VOICE's own room (`ReadingPageTokens.room` — the
//     Mac's R-13u-10 road), never the palette's. The note in Write is on the
//     paper — the screen, the masthead and the editor's own ground (piece
//     3.10, P-47-16; the Mac's editor and note masthead read the paper).
//  2. **The star** reads its own token (`tokens.star` — blue in every voice),
//     never the accent.
//  3. **No literal colour in a phone view** — the Mac's pin covers its own
//     views and `Shared/`, and no phone twin existed until now. The same
//     forms, over `VariorumMobile/` outside `Spike/` and `Features/Perf/`, with
//     ONE allowed form: the editor's TK2 fallback canary line (white-on-red's
//     phone cousin — TEXTKIT2_NOTES §4's defensive practice, the Mac pin's
//     own first allowance).
//
//  Each pattern was measured over the pre-batch tree (`ea738c49f`) and the
//  fixed one; the counts are in the run record §6.
//

import Foundation
import Testing

@Suite("VM-51 — grounds, the star and literal colours on the phone (source pins)")
struct MobileLookSourceTests {
    private static var phoneRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("VariorumMobile")
    }

    /// The file's code lines (comment and doc lines dropped).
    private func code(_ relative: String) throws -> [String] {
        let url = Self.phoneRoot.appendingPathComponent(relative)
        let source = try String(contentsOf: url, encoding: .utf8)
        return source.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("*")
            }
    }

    // MARK: - 1. The grounds

    /// The lists and pages her words are read in sit on the paper.
    @Test func herListsAndPagesSitOnThePaper() throws {
        let roots = [
            "Features/Shell/MobileStarredView.swift",
            "Features/Shell/MobileShelfView.swift",
            "Features/Shell/MobileLibraryView.swift",
        ]
        for file in roots {
            #expect(try code(file).contains { $0.contains(".background(tokens.surface)") },
                    "\(file): her list's region is on the paper")
        }
        let pushed = [
            "Features/Shell/MobileBookView.swift",
            "Features/Shell/MobileArchiveView.swift",
            "Features/Shell/MobileTrashView.swift",
            "Features/Write/MobileVersions.swift",
        ]
        for file in pushed {
            let lines = try code(file)
            #expect(lines.contains { $0.contains(".background(tokens.surface.ignoresSafeArea())") },
                    "\(file): the screen's ground is the paper")
            #expect(!lines.contains { $0.contains(".background(tokens.room.ignoresSafeArea())") },
                    "\(file): no screen ground on the room")
        }
    }

    /// Read's cream page never sits on the palette's room: the room around it
    /// is the voice's own (`ReadingPageTokens.room`).
    @Test func theReadPageNeverSitsOnThePalettesRoom() throws {
        let lines = try code("Features/Read/MobileReadView.swift")
        #expect(lines.contains { $0.contains("ReadingPageTokens.room(") },
                "MobileReadView: the voice's own room")
        #expect(!lines.contains { $0.contains(".background(tokens.room") },
                "MobileReadView: never the palette's room under her words")
    }

    /// **The note in Write is on the paper** (the VM-47 run, piece 3.10): the
    /// screen's ground and her title's masthead read `tokens.surface`, and the
    /// editor's own ground — its one line in the fenced text view — reads the
    /// face's paper. Nothing in Write sits on a room under her words.
    @Test func theNoteInWriteIsOnThePaper() throws {
        let write = try code("Features/Write/MobileWriteView.swift")
        #expect(write.contains { $0.contains(".background(tokens.surface.ignoresSafeArea())") },
                "MobileWriteView: the screen's ground is the paper")
        #expect(write.contains { $0.contains(".background(tokens.surface)") },
                "MobileWriteView: her title's masthead is on the paper")
        #expect(!write.contains { $0.contains(".background(tokens.room") || $0.contains("ReadingPageTokens.room(") },
                "MobileWriteView: no room under her words")
        let editor = try code("Features/Write/MobileEditorTextView.swift")
        #expect(editor.contains { $0.contains("backgroundColor = face.paper") },
                "MobileEditorTextView: the editor's ground is the face's paper")
        #expect(!editor.contains { $0.contains("backgroundColor = face.room") },
                "MobileEditorTextView: never the face's room")
    }

    // MARK: - 2. The star

    /// Every ★ the phone draws reads the star's own token.
    @Test func everyStarReadsTheStarToken() throws {
        let walker = try #require(FileManager.default.enumerator(
            at: Self.phoneRoot, includingPropertiesForKeys: nil))
        var stars = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: Self.phoneRoot.path + "/", with: "")
            let lines = try code(relative)
            for (index, line) in lines.enumerated() where line.contains("Text(\"★\")") {
                stars += 1
                let window = lines[index ..< min(index + 6, lines.count)]
                if !window.contains(where: { $0.contains(".foregroundStyle(tokens.star)") })
                    || window.contains(where: { $0.contains(".foregroundStyle(tokens.accent)") }) {
                    offenders.append(relative)
                }
            }
        }
        #expect(stars >= 1, "the walk must find the starred rows' ★")
        #expect(offenders.isEmpty, "a ★ not in the star token: \(offenders)")
    }

    // MARK: - 3. No literal colour

    /// The allowed forms, each with its decision (see the header):
    /// · the editor's TK2 fallback canary — deliberately not the voice's alarm;
    /// · (VM-47, the walk's fixes batch 2) the store's opening frame — it is
    ///   drawn before any library is open, so no library's tokens exist yet
    ///   (the failure face beside it is the deliberately unstyled recovery
    ///   surface);
    /// · the callout swatch's hairline edge — the image sits in the SYSTEM's
    ///   menu, and its edge matches that menu's own ground (the Mac's note).
    private static let allowedForms: [String: Set<String>] = [
        "Features/Write/MobileWriteView.swift": [".foregroundStyle(.red)"],
        "MobileStoreFailureView.swift": ["Color(.system"],
        "Features/Write/MobileCallout.swift": ["UIColor.separator"],
    ]

    /// **A system colour standing where a token belongs** (VM-47, the walk's
    /// W-B3 — "Delete Note…" was `tint: .red`, the system red at 3.43:1 on the
    /// room, where the sheet names the alarm). The forms the modifier list
    /// below never saw: a hue handed to a parameter (`tint: .red`,
    /// `? .red :`, `= .red`), and the UIKit/semantic system colours.
    private static let systemColourForms = [
        "UIColor.system", "Color(.system", "Color(uiColor: .system", "UIColor.label",
        "UIColor.secondaryLabel", "UIColor.tertiaryLabel", "UIColor.quaternaryLabel",
        "UIColor.placeholderText", "UIColor.separator", "UIColor.opaqueSeparator",
        "UIColor.link", "Color.accentColor", ".tint(.accentColor)",
    ]

    /// A hue handed to a parameter, ending at an identifier edge.
    private static func passesBare(_ hue: String, in text: String) -> String? {
        for lead in [": .", "? .", "= ."] {
            var searchStart = text.startIndex
            while let range = text.range(of: lead + hue, range: searchStart ..< text.endIndex) {
                let next = range.upperBound < text.endIndex ? text[range.upperBound] : " "
                if !(next.isLetter || next.isNumber || next == "_") { return lead + hue }
                searchStart = range.upperBound
            }
        }
        return nil
    }

    private static let hues = [
        "white", "black", "red", "orange", "yellow", "green",
        "blue", "gray", "grey", "purple", "pink", "brown", "mint", "teal",
    ]

    /// The Mac pin's bare-return test: the hue must END at an identifier edge.
    private static func returnsBare(_ hue: String, in text: String) -> Bool {
        guard let range = text.range(of: "return .\(hue)") else { return false }
        guard range.upperBound < text.endIndex else { return true }
        let next = text[range.upperBound]
        return !(next.isLetter || next.isNumber || next == "_")
    }

    @Test func noPhoneViewPaintsALiteralColour() throws {
        let walker = try #require(FileManager.default.enumerator(
            at: Self.phoneRoot, includingPropertiesForKeys: nil))
        var scanned = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: Self.phoneRoot.path + "/", with: "")
            if relative.hasPrefix("Spike/") || relative.hasPrefix("Features/Perf/") { continue }
            scanned += 1
            let allowed = Self.allowedForms[relative] ?? []
            for (index, text) in try code(relative).enumerated() {
                var found: [String] = []
                if text.contains("Color(hex:") { found.append("Color(hex:") }
                for form in ["srgbRed:", "calibratedRed:", "calibratedWhite:",
                             "UIColor(white:", "UIColor(red:", "Color(hue:", "Color(white:",
                             "Color(red:", "Color(.sRGB", "Color(.displayP3"]
                where text.contains(form) { found.append(form) }
                for hue in Self.hues {
                    if text.contains("Color.\(hue)") { found.append("Color.\(hue)") }
                    for modifier in ["foregroundStyle", "foregroundColor", "fill",
                                     "background", "stroke", "tint"]
                    where text.contains(".\(modifier)(.\(hue))") {
                        found.append(".\(modifier)(.\(hue))")
                    }
                    if Self.returnsBare(hue, in: text) {
                        found.append("return .\(hue)")
                    } else if text.contains(".\(hue).opacity("), !text.contains("shadow(color:") {
                        found.append(".\(hue).opacity(")
                    }
                    if let passed = Self.passesBare(hue, in: text) { found.append(passed) }
                }
                for form in Self.systemColourForms where text.contains(form) { found.append(form) }
                for form in found where !allowed.contains(form) {
                    offenders.append("\(relative) (code line \(index + 1)) — \(form)")
                }
            }
        }
        #expect(scanned > 50, "the walk must reach the phone's views (\(scanned) files)")
        #expect(offenders.isEmpty, """
            A literal colour cannot follow an appearance, a voice or a palette (P-8). \
            Use a `VoiceTokens` slot or the phone layer; if the literal is genuinely \
            right, allow its FORM here with the decision that allows it.
            \(offenders.joined(separator: "\n"))
            """)
    }

    // MARK: - 4. The hairline

    /// Whether the block that encloses `index` is opened by a menu — a
    /// `.contextMenu {` or a `Menu {` / `Menu(` — whose separator the system
    /// draws in its own material.
    private static func insideAMenu(_ lines: [String], at index: Int) -> Bool {
        var depth = 0
        for j in stride(from: index - 1, through: 0, by: -1) {
            for character in lines[j].reversed() {
                if character == "}" { depth += 1 }
                if character == "{" {
                    depth -= 1
                    if depth < 0 {
                        let line = lines[j]
                        return line.contains(".contextMenu") || line.contains("Menu {") || line.contains("Menu(")
                    }
                }
            }
        }
        return false
    }

    /// **Every hairline is the palette's line** (VM-47, the walk's W-C7 — the
    /// Lenses sheet's bare `Divider()` drew the system separator, #B4BCBB on
    /// the room, where every other sheet's divider wears the line; sheet §D:
    /// "the hairline 1.17:1"). A phone `Divider()` wears `.overlay(tokens.line)`
    /// (or a shared page's `style.tokens.line`) in its own chain — EXEMPT: a
    /// divider inside a menu (`.contextMenu` / `Menu`), which the system draws
    /// as its own separator. Red on old: the Lenses sheet's (`fb649d6a8`).
    @Test func everyPhoneDividerWearsTheLine() throws {
        let walker = try #require(FileManager.default.enumerator(
            at: Self.phoneRoot, includingPropertiesForKeys: nil))
        var dividers = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            let relative = file.path.replacingOccurrences(of: Self.phoneRoot.path + "/", with: "")
            if relative.hasPrefix("Spike/") || relative.hasPrefix("Features/Perf/") { continue }
            let lines = try code(relative)
            for (index, line) in lines.enumerated() where line.contains("Divider()") {
                dividers += 1
                let chain = lines[index ..< min(index + 3, lines.count)].joined(separator: "\n")
                if chain.contains(".overlay(tokens.line)") || chain.contains(".overlay(style.tokens.line)") { continue }
                if Self.insideAMenu(lines, at: index) { continue }
                offenders.append("\(relative) (code line \(index + 1))")
            }
        }
        #expect(dividers >= 8, "the walk must find the phone's dividers (\(dividers))")
        #expect(offenders.isEmpty, """
            A bare Divider() draws the system's separator grey, not the palette's line \
            (sheet §D). Chain `.overlay(tokens.line)`:
            \(offenders.joined(separator: "\n"))
            """)
    }
}
