//
//  MobileFaintOnDoorsTests.swift
//  VariorumMobileTests
//
//  VM-47 (the run's one walk, finding W-A9) — **NO DOOR'S WORDS UNDER 17 PT
//  WEAR THE FAINT.** The walk measured the Library filter row's unchosen words
//  in the corrected faint (#8B7F6A, 3.37:1 on the sea-glass room) and the
//  masthead's empty chips in it too (3.93:1 on the paper, 3.57:1 dark). The
//  sizing sheet's §D: "Words under 17 pt need 4.5:1; glyphs, 17 pt semibold
//  words and placeholders need 3:1. Faint never carries a sentence she has to
//  read" — the phone layer's faint is "glyphs, placeholders, disabled words
//  only". A door's word is none of those.
//
//  THE MECHANISM: batch 1 moved the voice's `tokens.faint` to the phone's
//  `tokens.phone.faint` one for one, and a door whose word had worn the old
//  faint (an unchosen filter, an empty chip, a menu row's detail line) kept
//  the faint's ROLE while the sheet moved those words up a step, to the
//  corrected muted. The fix gives them the corrected muted — and the
//  masthead's chips the sheet's two chip inks (empty in the corrected muted,
//  set in ink), so set and empty still read apart.
//
//  THE PINS:
//  · a SOURCE RULE over every phone view and every shared page's phone arm:
//    a faint read inside a `Button`'s label (or any `label:` block), on a type
//    role under 17 pt, is a door's word in the faint — red on old by its own
//    patterns (13 sites on the tree before the fix: the filter row, the four
//    masthead chips, eight menu-row details and row words, and the Account
//    sheet's tab words), none now. A glyph-only mark (the block list's ◉ / ○)
//    may keep the faint, as the sheet allows glyphs 3:1.
//  · the RENDERED INK of the two surfaces the walk measured: each unchosen
//    filter word, and each empty masthead chip, clears 4.5:1 against its own
//    ground, read off the real surface's pixels — red on old (3.3–4.2:1).
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The source rule

@MainActor
@Suite("VM-47 W-A9 — no door's words under 17 pt wear the faint (source rule)")
struct MobileFaintOnDoorsSourceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The type roles at 17 pt or more — outside this rule's class (the sheet's
    /// "under 17 pt"; a disabled 17 pt door may wear the faint).
    private static let fullSizeRoles: Set<String> = [
        "control", "rowTitle", "noteBody", "noteTitle", "screenTitle", "mono", "tab",
    ]

    private static let stringLiteral = try! NSRegularExpression(pattern: #""(?:[^"\\]|\\.)*""#)
    private static let trailingComment = try! NSRegularExpression(pattern: #"(^|\s)//.*$"#)
    private static let roleRead = try! NSRegularExpression(pattern: #"\.phoneType\(\.(\w+)"#)

    private static func replacing(_ regex: NSRegularExpression, in text: String, with template: String) -> String {
        regex.stringByReplacingMatches(
            in: text, range: NSRange(text.startIndex..., in: text), withTemplate: template)
    }

    /// A file's lines with comments blanked (line numbers kept).
    private static func code(_ url: URL) throws -> [String] {
        try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
            .map { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if trimmed.hasPrefix("//") || trimmed.hasPrefix("*") || trimmed.hasPrefix("/*") { return "" }
                return replacing(trailingComment, in: line, with: "$1")
            }
    }

    /// The role named by the nearest `.phoneType(.role` at or above `index`.
    private static func role(_ lines: [String], at index: Int) -> String? {
        for k in stride(from: index, through: max(index - 6, 0), by: -1) {
            let line = lines[k]
            if let match = roleRead.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line) {
                return String(line[range])
            }
        }
        return nil
    }

    /// A `Text(…)` whose string literals hold no letter at all — a glyph mark.
    private static func isGlyph(_ line: String) -> Bool {
        guard let start = line.range(of: "Text(") else { return false }
        let tail = String(line[start.lowerBound...])
        let literals = stringLiteral.matches(in: tail, range: NSRange(tail.startIndex..., in: tail))
            .compactMap { Range($0.range, in: tail).map { String(tail[$0]) } }
        return !literals.isEmpty && literals.allSatisfy { !$0.contains(where: \.isLetter) }
    }

    /// Whether `index` sits inside a door: walking up, every block that
    /// ENCLOSES the line is opened by an unmatched `{`; a door is a block
    /// whose opening line is a `Button` or a `label:` (a Button's or a Menu's).
    private static func insideADoor(_ lines: [String], at index: Int) -> Bool {
        var depth = 0
        for j in stride(from: index - 1, through: 0, by: -1) {
            let line = replacing(stringLiteral, in: lines[j], with: "\"\"")
            for character in line.reversed() {
                if character == "}" {
                    depth += 1
                } else if character == "{" {
                    depth -= 1
                    if depth < 0 {
                        if line.contains("Button") || line.contains("label:") || line.contains("NavigationLink") {
                            return true
                        }
                        depth = 0
                    }
                }
            }
        }
        return false
    }

    /// The door words in the faint, as `file:line` — the rule itself.
    static func offenders() throws -> (sites: [String], scanned: Int) {
        var files: [URL] = []
        for folder in ["VariorumMobile", "Shared"] {
            let walker = try #require(FileManager.default.enumerator(
                at: appRoot.appendingPathComponent(folder), includingPropertiesForKeys: nil))
            for case let file as URL in walker where file.pathExtension == "swift" { files.append(file) }
        }
        var sites: [String] = []
        var scanned = 0
        for file in files {
            let relative = file.path.replacingOccurrences(of: appRoot.path + "/", with: "")
            let phone = relative.hasPrefix("VariorumMobile/")
            guard phone || relative.hasPrefix("Shared/") else { continue }
            if relative.contains("/Spike/") || relative.contains("/Features/Perf/") { continue }
            // A phone view's faint is the phone's; a shared page's styled arm
            // reads `style.tokens` (the Mac's own arms never read the phone).
            let faint = phone ? ["phone.faint", "tokens.faint"] : ["phone.faint", "style.tokens.faint"]
            if relative.hasSuffix("Theme/PhoneInks.swift") { continue }
            scanned += 1
            let lines = try code(file)
            for (index, line) in lines.enumerated() where faint.contains(where: { line.contains($0) }) {
                if line.contains(".stroke(") || line.contains(".fill(") { continue }  // edges and fills
                if let found = role(lines, at: index), fullSizeRoles.contains(found) { continue }
                if (max(index - 4, 0)...index).contains(where: { isGlyph(lines[$0]) }) { continue }
                if insideADoor(lines, at: index) { sites.append("\(relative):\(index + 1)") }
            }
        }
        return (sites, scanned)
    }

    @Test func noDoorsWordsUnderSeventeenPointsWearTheFaint() throws {
        let found = try Self.offenders()
        #expect(found.scanned > 60, "the walk must reach the phone's views and the shared pages (\(found.scanned) files)")
        #expect(found.sites.isEmpty, """
            A door's words under 17 pt wear the corrected FAINT (sheet §D: words under 17 pt \
            need 4.5:1; the faint is for glyphs, placeholders and disabled words only). Give \
            them the corrected muted (`tokens.phone.muted`), or ink where the sheet draws ink:
            \(found.sites.joined(separator: "\n"))
            """)
    }
}

// MARK: - The rendered ink

@MainActor
@Suite("VM-47 W-A9 — the filter row's and the chips' words clear 4.5:1 (rendered)", .serialized)
struct MobileFaintOnDoorsRenderedTests {
    /// Sheet §D's floor for words under 17 pt.
    static let floor = 4.5

    /// A fresh library's look in one voice — the shell's own road
    /// (`MobileShellRouter.placeholder`: the sea-glass, VX-710).
    private func tokens(_ voice: ThemeVoice, dark: Bool) -> VoiceTokens {
        var settings = MobileShellRouter.placeholder
        settings.voice = voice
        return .resolve(settings: settings, dark: dark)
    }

    /// **The Library's filter row:** every unchosen word clears 4.5:1 on the
    /// row's ground (the room), in both voices, light and dark.
    @Test(arguments: [ThemeVoice.study, .terminal], [false, true])
    func theFilterRowsUnchosenWordsClearTheFloor(voice: ThemeVoice, dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let shelf = MobileShelfViewModel(session: session)
            let observing = Task { await shelf.start() }
            defer { observing.cancel() }
            let library = MobileLibraryView(
                model: MobileLibraryViewModel(session: session),
                scraps: MobileScrapsModel(session: session),
                stars: MobileStarsModel(session: session), books: shelf,
                tokens: tokens(voice, dark: dark), tabBar: { EmptyView() },
                onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {})
            try await withSceneSurface(library, dark: dark) { surface in
                await surface.settle(30)
                let pixels = try surface.render()
                var measured: [String] = []
                for door in MobileListingFilter.libraryDoors where door != .all {
                    let element = try #require(surface.onScreen(door.word),
                                               "the \(door.word) door: \(surface.labels)")
                    let read = try #require(pixels.inkAndGround(in: element.accessibilityFrame),
                                            "no word drawn in the \(door.word) door")
                    let ratio = read.ink.contrast(with: read.ground)
                    measured.append("\(door.word) \(read.ink) on \(read.ground) = \(String(format: "%.2f", ratio))")
                    #expect(ratio >= Self.floor,
                            "\(voice) dark \(dark): the unchosen \(door.word) reads \(String(format: "%.2f", ratio)):1 (\(read.ink) on \(read.ground))")
                }
                print("PERF[sim] VM-47 W-A9 filter row \(voice) dark \(dark): \(measured)")
            }
        }
    }

    /// **The masthead's empty chips:** on a fresh day's entry the tags, more
    /// info and lens chips are empty, and each clears 4.5:1 on the paper; the
    /// set date chip reads in ink, a step above them.
    @Test(arguments: [false, true])
    func theMastheadsEmptyChipsClearTheFloor(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(50)
                let door = try #require(surface.onScreen(MobileShelfFaces.todayDoorSpoken),
                                        "the Today door: \(surface.labels)")
                #expect(door.accessibilityActivate())
                #expect(await eventually { !router.editors.registeredPostIDs.isEmpty },
                        "a note opened in Write")
                await surface.settle(60)
                let pixels = try surface.render()
                var empties: [Double] = []
                for chip in ["Tags", "More Info", "Lenses"] {
                    let element = try #require(surface.onScreen(chip), "the \(chip) chip: \(surface.labels)")
                    let read = try #require(pixels.inkAndGround(in: element.accessibilityFrame),
                                            "no word drawn in the \(chip) chip")
                    let ratio = read.ink.contrast(with: read.ground)
                    empties.append(ratio)
                    #expect(ratio >= Self.floor,
                            "dark \(dark): the empty \(chip) chip reads \(String(format: "%.2f", ratio)):1 (\(read.ink) on \(read.ground))")
                }
                let date = try #require(surface.onScreen("Entry Date"), "the date chip: \(surface.labels)")
                let set = try #require(pixels.inkAndGround(in: date.accessibilityFrame), "no word in the date chip")
                let setRatio = set.ink.contrast(with: set.ground)
                #expect(empties.allSatisfy { setRatio > $0 + 1 },
                        "dark \(dark): the set date chip (\(String(format: "%.2f", setRatio)):1) reads above the empty ones \(empties)")
            }
        }
    }
}
