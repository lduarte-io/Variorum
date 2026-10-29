//
//  ShortcutsTabFaceTests.swift
//  VariorumTests
//
//  VX-572 (the VX-677 run, batch 4) — the ⌘/ helper's Shortcuts tab, its
//  FACE. Her 10-28 pass (the ticket): correct the spacing; the description
//  column in the voice's face (Study's face in Study; the chord column may
//  stay mono); no mid-name breaks in the chord column (today "Format ▸
//  Strikethrough" breaks mid-name); long descriptions must not wrap into the
//  neighbouring rhythm; collapsible headers, collapsed by default.
//
//  RED on `rev572` (the revert restores the old face over the same catalog:
//  `sections` every group open with every row, the chord cell the old
//  130-pt wrapping column in the system mono, the description in the system
//  face): `atRestEveryGroupIsFoldedAndComposesNoRow`,
//  `aSearchHitComposesOnlyItsRowInAnOpenGroup`,
//  `everyChordCellFitsItsColumnOnOneLine`,
//  `theDescriptionReadsInTheVoicesFaceAndTheChordsInItsMono`. GUARD (green on
//  both): `theLongestDescriptionFitsItsLineBoundAtTheMinimumWidth`.
//
//  How the face is read: the composition (`SurfaceComposition`'s road — an
//  untaken branch is ABSENT from a body's reflection) plus a real hosting
//  window, and AppKit's own `sizeThatFits` for geometry. VX-692 (F-B3-1): no
//  closure-bearing expression inside `#expect` / `#require`.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-572 — the shortcuts tab's face", .serialized)
struct ShortcutsTabFaceTests {
    private static let voices: [VoiceTokens] = [.studyLight, .terminalLight, .studyDark, .terminalDark]

    /// Every value of type `T` reachable in `subject`'s stored structure, not
    /// descending into `VoiceTokens` (`CommitsPageLedgerTests`' walk).
    private static func values<T>(_ type: T.Type, in subject: Any, depth: Int = 0) -> [T] {
        guard depth < 80 else { return [] }
        if subject is VoiceTokens { return [] }
        var found: [T] = []
        if let hit = subject as? T { found.append(hit) }
        for child in Mirror(reflecting: subject).children {
            found += values(type, in: child.value, depth: depth + 1)
        }
        return found
    }

    private static func signature(_ value: Any) -> String {
        var out = ""
        dump(value, to: &out)
        return out
    }

    private static func fitted(_ view: some View, width: CGFloat) -> NSSize {
        let host = NSHostingController(rootView: view)
        return host.sizeThatFits(in: NSSize(width: width, height: 10_000))
    }

    // MARK: - Folded at rest; a search opens what it finds (RED on rev572)

    /// **At rest every group is FOLDED and composes no row** — each heading
    /// alone (▸), in every voice; and the whole tab builds and lays out in a
    /// real window at the helper's default size.
    @Test func atRestEveryGroupIsFoldedAndComposesNoRow() async {
        let model = ShortcutsTabModel()
        let sections = model.sections
        #expect(sections.count == ShortcutCatalog.Group.allCases.count)
        for tokens in Self.voices {
            for section in sections {
                let face = ShortcutGroupSection(section: section, tokens: tokens, toggle: {})
                let composed = Self.values(ShortcutCatalog.Row.self, in: face.body).count
                #expect(composed == 0, "\(tokens.voice) \(section.group.title): folded — no row composed")
                let headers = Self.values(ShortcutGroupHeader.self, in: face.body)
                let folded = headers.first?.isExpanded == false
                #expect(headers.count == 1 && folded, "\(tokens.voice) \(section.group.title): its heading, folded")
            }
        }
        await SurfaceComposition.host(
            ShortcutsTab(tokens: .studyLight, model: model), size: NSSize(width: 760, height: 620))
    }

    /// **A search composes ONLY its hit, in an OPEN group** — her own word
    /// "unindent" finds the one Formatting row, and no other group shows.
    @Test func aSearchHitComposesOnlyItsRowInAnOpenGroup() async {
        let model = ShortcutsTabModel()
        model.setQuery("unindent")
        let sections = model.sections
        let groups = sections.map(\.group)
        #expect(groups == [.formatting], "\(groups)")
        for tokens in Self.voices {
            for section in sections {
                let face = ShortcutGroupSection(section: section, tokens: tokens, toggle: {})
                let composed = Self.values(ShortcutCatalog.Row.self, in: face.body).map(\.keysText)
                #expect(composed == ["\u{2318}] / \u{2318}["], "\(tokens.voice): \(composed)")
                let headers = Self.values(ShortcutGroupHeader.self, in: face.body)
                let open = headers.first?.isExpanded == true
                let count = headers.first?.count
                #expect(open, "\(tokens.voice): the search opens the group")
                #expect(count == "1 of \(ShortcutCatalog.rows(in: .formatting).count)")
            }
        }
        await SurfaceComposition.host(
            ShortcutsTab(tokens: .terminalLight, model: model), size: NSSize(width: 760, height: 620))
    }

    // MARK: - The chord column never breaks a name (RED on rev572)

    /// **Every row's chord cell fits the column on ONE line, both voices** —
    /// the geometry oracle for "no mid-name breaks": each cell's fitted width
    /// is inside `chordColumn` and its height is one line's (the "⌘S"
    /// cell's). On the old face "Format ▸ Strikethrough" took two lines in its
    /// 130-pt column.
    @Test func everyChordCellFitsItsColumnOnOneLine() {
        let column = ShortcutsTabMetrics.chordColumn
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            let oneLine = Self.fitted(ShortcutChordCell(chords: ["\u{2318}S"], tokens: tokens), width: column)
            var widest: (String, CGFloat) = ("", 0)
            for row in ShortcutCatalog.rows {
                let size = Self.fitted(ShortcutChordCell(chords: row.tokens, tokens: tokens), width: column)
                if size.width > widest.1 { widest = (row.keysText, size.width) }
                #expect(size.width <= column, "\(tokens.voice) \(row.keysText): \(size.width) pt wide")
                // +1 pt: a fallback glyph (⎋ draws from Menlo) may move a
                // line's metrics by a fraction; a second line is ~15 pt.
                #expect(size.height <= oneLine.height + 1,
                        "\(tokens.voice) \(row.keysText): one line (\(size.height) vs \(oneLine.height))")
            }
            print("[VX-572] \(tokens.voice) widest chord cell: \(widest.0) \(widest.1) pt of \(column); one line \(oneLine.height) pt")
        }
    }

    // MARK: - The voice's face (RED on rev572)

    /// **The description reads in the voice's own face** (`tokens.body` —
    /// Iowan Old Style in Study, the mono in Terminal) and the chords in the
    /// voice's mono, every voice; in Study the two are different faces.
    @Test func theDescriptionReadsInTheVoicesFaceAndTheChordsInItsMono() throws {
        let row = try #require(ShortcutCatalog.rows.first)
        for tokens in Self.voices {
            let rowFonts = Self.values(Font.self, in: ShortcutRowView(row: row, tokens: tokens).body)
                .map(Self.signature)
            #expect(rowFonts.contains(Self.signature(tokens.body)), "\(tokens.voice): the description's face")
            let cellFonts = Self.values(Font.self, in: ShortcutChordCell(chords: row.tokens, tokens: tokens).body)
                .map(Self.signature)
            #expect(cellFonts.contains(Self.signature(tokens.mono)), "\(tokens.voice): the chords' mono")
            if tokens.voice == .study {
                #expect(Self.signature(tokens.body) != Self.signature(tokens.mono),
                        "Study's description face is not the chord column's mono")
            }
        }
    }

    // MARK: - Guard

    /// **No description is ever cut** — the longest reads whole inside its
    /// line bound at the helper's MINIMUM width (P-8's bound is a guard, never
    /// a truncation): its height under `descriptionLines` equals its height
    /// unbounded, both voices.
    @Test func theLongestDescriptionFitsItsLineBoundAtTheMinimumWidth() {
        // 640 − the outer padding − the rows' indent − the column − the gap − a scroller.
        let width: CGFloat = 640 - 2 * ShortcutsTabMetrics.outerPadding - ShortcutsTabMetrics.rowIndent
            - ShortcutsTabMetrics.chordColumn - ShortcutsTabMetrics.columnGap - 16
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            for row in ShortcutCatalog.rows {
                let bounded = Self.fitted(
                    Text(row.words).font(tokens.body)
                        .lineLimit(ShortcutsTabMetrics.descriptionLines)
                        .fixedSize(horizontal: false, vertical: true), width: width)
                let whole = Self.fitted(
                    Text(row.words).font(tokens.body)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true), width: width)
                #expect(abs(bounded.height - whole.height) < 0.5,
                        "\(tokens.voice) \(row.keysText): \(bounded.height) vs \(whole.height) at \(width) pt")
            }
        }
    }
}
