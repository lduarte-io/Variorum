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
//  · (the walk's fixes, batch 2 — W-B1, W-C3) the SIBLING RULE: the faint
//    carries no word under 17 pt anywhere — sentences, section headers, paths,
//    meta lines, status words — only its own uses (edges, glyphs, placeholders,
//    a 17 pt disabled door); red on old by its patterns (19 sites), none now;
//    and the rendered ink of the Trash's promise sentence ≥ 4.5:1.
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
    /// "under 17 pt"; a disabled 17 pt door may wear the faint). **Read from
    /// the table, never listed** (MOVED with VM-273's step-down, the VM-260
    /// run's batch 2: the list named `control` when it was 17; at 15 its words
    /// are inside the rule — the table is the one place a size is decided).
    private static let fullSizeRoles: Set<String> = Set(
        PhoneTypeRole.allCases
            .filter { PhoneType.spec($0, voice: .study).size >= 17 }
            .map(\.rawValue))

    /// **The quick-entry box's hint is the box's PLACEHOLDER** — the faint's own
    /// use at any size (sheet §D: "glyphs, 17 pt semibold words and placeholders
    /// need 3:1"; the faint clears 3:1 on every shipped ground, `PhoneInks`),
    /// drawn as the empty box's overlay rather than a field's `prompt:`, so the
    /// rule's two placeholder forms do not name it. It rode the full-size
    /// exemption while her words' body was 17; VM-254 (the VM-260 run, batch 3 —
    /// her R-260-2) took the body to 16 — MOVED with the ruling: the one site,
    /// named by its one function, keeps the faint as the placeholder it is.
    static func isTheBoxsHint(_ relative: String, _ lines: [String], at index: Int) -> Bool {
        relative == "VariorumMobile/Features/Shell/MobileQuickNote.swift"
            && (max(index - 6, 0)...index).contains { lines[$0].contains("func hintLine(") }
    }

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
            if MobileSourceRuleScope.exempts(relative) { continue }  // the debug harnesses (7b.7)
            // A phone view's faint is the phone's; a shared page's styled arm
            // reads `style.tokens` (the Mac's own arms never read the phone).
            let faint = phone ? ["phone.faint", "tokens.faint"] : ["phone.faint", "style.tokens.faint"]
            if relative.hasSuffix("Theme/PhoneInks.swift") { continue }
            scanned += 1
            let lines = try code(file)
            for (index, line) in lines.enumerated() where faint.contains(where: { line.contains($0) }) {
                if line.contains(".stroke(") || line.contains(".fill(") { continue }  // edges and fills
                // A field's placeholder is the faint's own use (sheet §D), never a door's
                // word — the sibling rule's exemption, by its two exact forms: a `prompt:`
                // argument, or the `\.phoneFieldPrompt` key path (case-sensitive — an
                // identifier or a word that merely holds "prompt" is not exempt; ladder
                // round 3, R3-n1). (The walk's fixes, batch 2: the Account sheet's
                // `pagePlainField` was read as a door because its signature
                // `_ label: String` holds "label:".)
                if line.contains("prompt:") || line.contains("\\.phoneFieldPrompt") { continue }
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

// MARK: - The sibling rule: the faint carries no words under 17 pt (W-B1, W-C3)

extension MobileFaintOnDoorsSourceTests {
    /// The role named nearest a faint read — above it first (the modifier
    /// chain of the same `Text`), else just below it (a group's role applied
    /// after its children's inks, as the empty states draw it).
    private static func nearestRole(_ lines: [String], at index: Int) -> String? {
        if let above = role(lines, at: index) { return above }
        for k in index ..< min(index + 5, lines.count) {
            let line = lines[k]
            if let match = roleRead.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line) {
                return String(line[range])
            }
        }
        return nil
    }

    /// **Every faint read that is not one of the faint's own uses** — sheet
    /// §D: the corrected faint is for "glyphs, placeholders, disabled words
    /// only; never a sentence", and "words under 17 pt need 4.5:1". What may
    /// keep the faint, each by its own pattern: an edge or a fill (`.stroke(`
    /// / `.fill(` — the box's dashed edge), a glyph-only mark (a `Text` whose
    /// literals hold no letter — the block list's ○), a field's placeholder
    /// (a line holding a `prompt:` argument or the `\.phoneFieldPrompt` key
    /// path, case-sensitive — ladder round 3, R3-n1), the box's hint (the
    /// box's placeholder, `isTheBoxsHint` — VM-254 took its 17 pt to 16), and a
    /// word at 17 pt or more. Anything else — a sentence, a section header, a path, a
    /// row's meta line, a status word, a door's word — is the class. A read
    /// whose role cannot be found counts (the conservative side).
    static func wordOffenders() throws -> (sites: [String], scanned: Int) {
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
            if MobileSourceRuleScope.exempts(relative) { continue }  // the debug harnesses (7b.7)
            let faint = phone ? ["phone.faint", "tokens.faint"] : ["phone.faint", "style.tokens.faint"]
            if relative.hasSuffix("Theme/PhoneInks.swift") { continue }
            scanned += 1
            let lines = try code(file)
            for (index, line) in lines.enumerated() where faint.contains(where: { line.contains($0) }) {
                if line.contains(".stroke(") || line.contains(".fill(") { continue }  // edges and fills
                if line.contains("prompt:") || line.contains("\\.phoneFieldPrompt") { continue }  // a field's placeholder
                if isTheBoxsHint(relative, lines, at: index) { continue }  // the box's placeholder (VM-254)
                if (max(index - 4, 0)...index).contains(where: { isGlyph(lines[$0]) }) { continue }
                if let found = nearestRole(lines, at: index), fullSizeRoles.contains(found) { continue }
                sites.append("\(relative):\(index + 1)")
            }
        }
        return (sites, scanned)
    }
}

@MainActor
@Suite("VM-47 W-B1/W-C3 — the faint carries no sentence, header or label under 17 pt (source rule)")
struct MobileFaintCarriesNoWordsSourceTests {
    /// **The faint is the faint's own uses, nowhere else** (the walk's W-B1:
    /// the Trash's promise at 3.93:1; W-C3: "Apply a tag", "Add to a book",
    /// the tray's and Versions' explainers, the reader's meta). Red on old by
    /// its own patterns: the nineteen sites on the tree before the sweep
    /// (`c72e65201`), none after.
    @Test func theFaintCarriesNoWordsUnderSeventeenPoints() throws {
        let found = try MobileFaintOnDoorsSourceTests.wordOffenders()
        #expect(found.scanned > 60, "the walk must reach the phone's views and the shared pages (\(found.scanned) files)")
        #expect(found.sites.isEmpty, """
            Words under 17 pt wear the corrected FAINT (sheet §D: "faint never carries a \
            sentence she has to read"; it is for glyphs, placeholders and disabled words only, \
            and words under 17 pt need 4.5:1). Give them the corrected muted \
            (`tokens.phone.muted`) — sheet §A draws meta lines, explainers and section \
            headers in it:
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

    /// **The Trash's promise** (the walk's W-B1): "Deleted things wait here
    /// for 30 days, then they're gone." is a sentence she has to read, at
    /// 13 pt, so it clears 4.5:1 on the Trash's paper in both voices, light
    /// and dark — red on old (the faint: 3.93:1 Study light, ≈ 3.6:1 dark).
    @Test(arguments: [ThemeVoice.study, .terminal], [false, true])
    func theTrashsPromiseClearsTheFloor(voice: ThemeVoice, dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            let trash = MobileTrashView(
                model: MobileTrashModel(session: session), tokens: tokens(voice, dark: dark),
                onOpen: { _ in })
            try await withSceneSurface(trash, dark: dark) { surface in
                await surface.settle(30)
                let promise = try #require(
                    surface.elements.first {
                        ($0.accessibilityLabel ?? "").range(of: "wait here", options: .caseInsensitive) != nil
                            && !$0.accessibilityFrame.isEmpty
                    },
                    "the Trash's promise line: \(surface.labels)")
                let pixels = try surface.render()
                let read = try #require(pixels.inkAndGround(in: promise.accessibilityFrame),
                                        "no words drawn in the promise line")
                let ratio = read.ink.contrast(with: read.ground)
                print("PERF[sim] VM-47 W-B1 Trash promise \(voice) dark \(dark): \(read.ink) on \(read.ground) = \(ratio)")
                #expect(ratio >= Self.floor,
                        "\(voice) dark \(dark): the Trash's promise reads \(String(format: "%.2f", ratio)):1 (\(read.ink) on \(read.ground))")
            }
        }
    }

    /// **The note's top's marks clear their floors** — on a fresh day's entry,
    /// through the real shell: each of the one row's six glyphs reads at the
    /// glyph floor (3:1) at least, the book door — the Journal holds the entry —
    /// in ink; the open tag strip's add door, a word, at the words' 4.5:1; and
    /// the Note sheet's date door, which shows the entry's day, at 4.5:1 too.
    ///
    /// MOVED WITH R-260-13 (the VM-260 run, batch 4b): this held "the
    /// masthead's empty chips" — the tags, more info and lens WORDS at 4.5:1 on
    /// a fresh entry, and the set date chip a step above them. Her pick takes
    /// those words off the top: tags is the # glyph (its strip's words when
    /// open), more info and lens are rows behind the stack door, the date is the
    /// Note sheet's head. So every mark the top still draws keeps its floor (the
    /// glyphs the glyph floor, every word the words'), and the relative clause
    /// retires with the empty chips it compared against — there are none left.
    @Test(arguments: [false, true])
    func theNoteTopsMarksClearTheirFloors(dark: Bool) async throws {
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
                var pixels = try surface.render()
                @MainActor func ratio(_ label: String, in elements: [NSObject]) throws -> Double {
                    let bounds = surface.window.bounds.insetBy(dx: 1, dy: 1)
                    let found = elements.first {
                        $0.accessibilityLabel == label && bounds.intersects($0.accessibilityFrame)
                    }
                    let names = elements.compactMap { $0.accessibilityLabel }
                    let element = try #require(found, "\(label): \(names)")
                    let read = try #require(pixels.inkAndGround(in: element.accessibilityFrame),
                                            "nothing drawn in \(label)")
                    return read.ink.contrast(with: read.ground)
                }
                let glyphs = ["Copy Note", "Find in Note", "Books holding this note", "Tags",
                              "Blocks, Lenses and More Info", MobileNoteActionsSheet.doorLabel]
                for glyph in glyphs {
                    let read = try ratio(glyph, in: surface.elements)
                    #expect(read >= 3.0,
                            "dark \(dark): the \(glyph) glyph reads \(String(format: "%.2f", read)):1")
                }
                let book = try ratio("Books holding this note", in: surface.elements)
                #expect(book >= Self.floor,
                        "dark \(dark): the Journal holds the entry, so its book door reads in ink (\(book):1)")

                let hash = try #require(surface.onScreen("Tags"), "the # door: \(surface.labels)")
                #expect(hash.accessibilityActivate())
                await surface.settle(30)
                pixels = try surface.render()
                let add = try ratio("Add Tag", in: surface.elements)
                #expect(add >= Self.floor, "dark \(dark): the strip's add door reads \(add):1")

                let actions = try #require(surface.onScreen(MobileNoteActionsSheet.doorLabel))
                #expect(actions.accessibilityActivate())
                await surface.settle(50)
                let sheet = try #require(surface.host.presentedViewController, "the Note sheet is up")
                pixels = try surface.render()
                let date = try ratio("Entry Date", in: HostedSurface<EmptyView>.elements(of: sheet.view))
                #expect(date >= Self.floor, "dark \(dark): the Note sheet's date door reads \(date):1")
            }
        }
    }
}
