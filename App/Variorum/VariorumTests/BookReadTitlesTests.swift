//
//  BookReadTitlesTests.swift
//  VariorumTests
//
//  VX-881 (the VX-1036 run, batch 4) — a note's title while reading (RT-1,
//  her R-1036-21 / R-1036-40): the per-book switch on Read's controls, its
//  memory on this Mac, the title line's rule, its lead in the story row's
//  height brain, and Read's controls' one-line-or-two rule. Pure — no window.
//  The line's realization against the viewport and a landing over titled
//  stories are `ReadingFlowTitleLinesTests` (hosted).
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-881 — the per-book note-titles switch and the title line's rule")
struct BookReadTitlesTests {
    private func scratch(_ name: String) -> UserDefaults {
        let suite = "BookReadTitlesTests.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func entry(_ title: String?) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: "p", title: title, entryDate: "2026-11-25", sectionPath: nil)
    }

    // MARK: - The memory (per book, this Mac)

    /// Hidden is today's page; a choice is remembered for THAT book on this
    /// Mac and read back at the next open; another book keeps its own.
    @Test func theSwitchIsHiddenUntilChosenAndRemembersPerBook() {
        let defaults = scratch("memory")
        let a = BookReadTitlesModel(readingID: "book-a", defaults: defaults)
        #expect(!a.shown, "a book opens on today's page — no title lines")

        a.setShown(true)
        #expect(a.shown)
        #expect(BookReadTitlesModel(readingID: "book-a", defaults: defaults).shown,
                "the next open of the same book reads its choice back")
        #expect(!BookReadTitlesModel(readingID: "book-b", defaults: defaults).shown,
                "another book keeps its own (hidden)")

        a.toggle()
        #expect(!a.shown, "the chip's one act turns it back")
        #expect(defaults.object(forKey: BookNoteTitlesPrefs.key("book-a")) == nil,
                "hidden is stored as no key at all")
        #expect(!BookReadTitlesModel(readingID: "book-a", defaults: defaults).shown)
    }

    /// The memory's own key family — never the tags switch's.
    @Test func theMemoryHasItsOwnKeyFamily() {
        #expect(BookNoteTitlesPrefs.key("r1") == "book.noteTitlesShown.r1")
        #expect(BookNoteTitlesPrefs.key("r1") != BookTagsShownPrefs.key("r1"))
    }

    /// A choice that changes nothing writes nothing.
    @Test func aNoOpChoiceWritesNothing() {
        let defaults = scratch("noop")
        let model = BookReadTitlesModel(readingID: "book", defaults: defaults)
        model.setShown(false)
        #expect(defaults.object(forKey: BookNoteTitlesPrefs.key("book")) == nil)
        model.setShown(true)
        defaults.removeObject(forKey: BookNoteTitlesPrefs.key("book"))
        model.setShown(true)
        #expect(defaults.object(forKey: BookNoteTitlesPrefs.key("book")) == nil,
                "already shown — the second choice wrote nothing")
    }

    // MARK: - The line's words

    /// The line names a note its author named, only while the book shows
    /// titles; an untitled (or blank-titled) note shows NO line
    /// (PROVISIONAL P-1036-B4-1); the stored title is trimmed.
    @Test func theLineNamesATitledNoteOnlyWhileTheBookShowsTitles() {
        #expect(FlowNoteTitle.line(for: entry("Seed order"), shown: true) == "Seed order")
        #expect(FlowNoteTitle.line(for: entry("  Seed order \n"), shown: true) == "Seed order")
        #expect(FlowNoteTitle.line(for: entry("Seed order"), shown: false) == nil,
                "a book hiding titles draws no line")
        #expect(FlowNoteTitle.line(for: entry(nil), shown: true) == nil,
                "an untitled note shows no line — not its day, not its first words")
        #expect(FlowNoteTitle.line(for: entry("   "), shown: true) == nil)
    }

    /// The line adds ONE constant to its story row — its box and its gap —
    /// and nothing when there is no line.
    @Test func theLineAddsOneConstantLeadToItsRow() {
        #expect(FlowNoteTitle.lead == FlowNoteTitle.lineHeight + FlowNoteTitle.gap)
        #expect(FlowNoteTitle.lead(for: entry("Seed order"), shown: true) == FlowNoteTitle.lead)
        #expect(FlowNoteTitle.lead(for: entry("Seed order"), shown: false) == 0)
        #expect(FlowNoteTitle.lead(for: entry(nil), shown: true) == 0)
    }

    // MARK: - The lead in the one height brain

    /// The row's far height and the column's manifest ask ONE brain with the
    /// same lead: the lead plus exactly what the prose alone resolves to, on
    /// every arm `resolve` can take — a remembered size at this width, one
    /// from another width, none, a degenerate remembered zero (skipped today,
    /// skipped with a lead) — and a lead of 0 is the pre-VX-881 input, field
    /// for field.
    @Test func theLeadRidesWhicheverArmTheProseResolvesTo() {
        let lead = FlowNoteTitle.lead
        let cases: [(CGSize?, CGFloat)] = [
            (CGSize(width: 600, height: 20_000), 600),   // remembered, this width
            (CGSize(width: 600, height: 20_000), 450),   // remembered, another width
            (nil, 600),                                  // nothing remembered
            (CGSize(width: 600, height: 0), 600),        // a degenerate zero
        ]
        for (remembered, width) in cases {
            let prose = FlowHeightEstimate.honestHeight(
                remembered: remembered, columnWidth: width, estimate: 26_000)
            let row = FlowHeightEstimate.honestHeight(
                remembered: remembered, columnWidth: width, estimate: 26_000, lead: lead)
            let column = BookHeightManifest.resolve(FlowHeightEstimate.storyInput(
                id: "flow-p", remembered: remembered, columnWidth: width, estimate: 26_000,
                lead: lead)).0
            #expect(row == prose + lead, "the row: the lead plus the prose (\(String(describing: remembered)) at \(width))")
            #expect(column == row, "the column aims by the row's own height")
            let unchanged = FlowHeightEstimate.storyInput(
                id: "flow-p", remembered: remembered, columnWidth: width, estimate: 26_000, lead: 0)
            let preVX881 = BookHeightManifest.Input(
                id: "flow-p",
                remembered: remembered.flatMap {
                    FlowHeightEstimate.remembered($0, appliesAt: width) ? $0.height : nil
                },
                derived: 26_000)
            #expect(unchanged == preVX881, "no lead is the pre-VX-881 input, byte for byte")
        }
    }

    // MARK: - Read's controls: one line or two

    /// The switch rides beside the picker only when the picker, the gap and
    /// the switch's stable width fit at whole points; else it goes under.
    @Test func theSwitchRidesBesideThePickerOnlyWhenBothFit() {
        let gap = BookReadControlsRule.spacing
        #expect(BookReadControlsRule.oneLine(available: 300, leading: 110, trailing: 130))
        #expect(BookReadControlsRule.oneLine(available: 110 + gap + 130, leading: 110, trailing: 130),
                "exactly enough is one line")
        #expect(!BookReadControlsRule.oneLine(available: 110 + gap + 129.5, leading: 110, trailing: 130),
                "half a point short is two")
        #expect(!BookReadControlsRule.oneLine(available: 205, leading: 110, trailing: 130),
                "the Terminal navigator's floor room: two lines")
        #expect(!BookReadControlsRule.oneLine(available: 300, leading: 110.2, trailing: 181.9),
                "widths round UP before they are compared")
        #expect(BookReadControlsRule.oneLine(available: .infinity, leading: 110, trailing: 130))
    }

    /// The switch's stable width holds BOTH of its faces in each voice, so
    /// turning it never moves the line it shares.
    @Test func theSwitchsStableWidthHoldsBothFacesInEachVoice() {
        let context = EnvironmentValues().fontResolutionContext
        for voice in [ThemeVoice.terminal, .study] {
            let tokens = VoiceTokens.resolve(voice: voice, dark: false)
            let font = tokens.small.resolve(in: context).ctFont as NSFont
            let stable = BookReadTitlesSwitch.stableWidth(tokens: tokens, in: context)
            for shown in [true, false] {
                let face = (tokens.chromeLabel(BookReadTitlesCopy.chip(shown: shown)) as NSString)
                    .size(withAttributes: [.font: font]).width
                #expect(face + 2 * BookReadTitlesSwitch.padding <= stable,
                        "\(voice) \(shown ? "shown" : "hidden") fits the stable width")
            }
        }
    }

    /// The chip says its state in the mockup's words.
    @Test func theChipSaysItsState() {
        #expect(BookReadTitlesCopy.chip(shown: true) == "note titles: shown")
        #expect(BookReadTitlesCopy.chip(shown: false) == "note titles: hidden")
    }
}
