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

    /// The ONE allowed form, with its decision (see the header).
    private static let allowedForms: [String: Set<String>] = [
        "Features/Write/MobileWriteView.swift": [".foregroundStyle(.red)"],
    ]

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
                }
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
}
