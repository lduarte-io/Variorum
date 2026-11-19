//
//  MobilePhoneControlsTests.swift
//  VariorumMobileTests
//
//  VM-50 (the VM-47 run, batch 2) — **the phone's one set of controls,
//  measured on a real surface.** Each control is hosted in a real window and
//  read back the way `MobileFilterRowGeometryTests` reads the filter row: a
//  control's ACCESSIBILITY FRAME is its hit area (a SwiftUI button's frame is
//  its label's laid-out frame, which is the region that answers a touch), and
//  a drawing is measured with `onGeometryChange` where the pin needs the
//  drawn size as well.
//
//  The numbers are the sizing sheet's §B and §E (P-47-1, PROVISIONAL as a
//  set): text button 64 × 44 · inline act and icon button 44 × 44 · chip 44
//  tall around a 32 pt capsule · field 44 · calm button 64 × 44 · sheet
//  header 56, Done 8 from the edge · segmented choice 44, its selection
//  contract · section header 24 + 18 + 8 · menu row 44 / 52 / 64.
//
//  NEW COVERAGE (a design row — the controls are new), not red-on-old pins:
//  each would fail against the build it replaces (an 11.5 pt plain word's
//  frame is ~14 tall — audit G §2), and the source pin
//  (`MobilePhoneControlsSourceTests`) holds that the replaced builds stay
//  gone.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private final class Probe {
    var size: CGSize = .zero
    var frames: [String: CGRect] = [:]
    var picks: [String] = []
}

@MainActor
@Suite("Phone controls — geometry and contracts (VM-50)", .serialized)
struct MobilePhoneControlsTests {
    private let width: CGFloat = 402

    private func hosted<V: View>(
        _ view: V, size: CGSize? = nil, _ body: (HostedSurface<AnyView>) async throws -> Void
    ) async rethrows {
        let root = AnyView(VStack(alignment: .leading, spacing: 0) {
            view
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading))
        try await withHostedSurface(root, size: size ?? CGSize(width: width, height: 600)) { surface in
            await surface.settle(12)
            #expect(surface.host.view.bounds.width == (size?.width ?? width))
            try await body(surface)
        }
    }

    private func frame(_ surface: HostedSurface<AnyView>, _ label: String) throws -> CGRect {
        let element = try #require(
            surface.element(labeled: label), "no element labelled \(label): \(surface.visibleLabels)")
        return element.accessibilityFrame
    }

    // MARK: Text button

    @Test func theTextButtonAnswersAcrossAtLeastSixtyFourByFortyFour() async throws {
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            try await hosted(
                HStack {
                    Button("Done") {}.buttonStyle(PhoneTextButtonStyle(tokens: tokens, closing: true))
                    Button("Put back") {}.buttonStyle(PhoneTextButtonStyle(tokens: tokens))
                    Button("Show the long label") {}.buttonStyle(PhoneTextButtonStyle(tokens: tokens))
                }
            ) { surface in
                let done = try frame(surface, "Done")
                #expect(done.width >= 63.5 && done.height >= 43.5, "Done \(done) in \(tokens.voice)")
                let putBack = try frame(surface, "Put back")
                #expect(putBack.width >= 63.5 && putBack.height >= 43.5, "Put back \(putBack)")
                // A long label is wider than the minimum and keeps 12 each side.
                let long = try frame(surface, "Show the long label")
                #expect(long.width > 64 && long.height >= 43.5)
            }
        }
    }

    @Test func theTextButtonGrowsWithTheTextSizeAndHoldsAtXXXLarge() async throws {
        var heights: [DynamicTypeSize: CGFloat] = [:]
        for size in [DynamicTypeSize.large, .xxxLarge, .accessibility5] {
            try await hosted(
                Button("A label long enough to measure") {}
                    .buttonStyle(PhoneTextButtonStyle(tokens: .studyLight))
                    .dynamicTypeSize(size)
            ) { surface in
                heights[size] = try frame(surface, "A label long enough to measure").width
            }
        }
        let large = try #require(heights[.large])
        let hold = try #require(heights[.xxxLarge])
        #expect(hold > large + 4, "the label grows to xxxLarge: \(heights)")
        #expect(heights[.accessibility5] == hold, "chrome holds at xxxLarge: \(heights)")
    }

    // MARK: Inline act

    @Test func theInlineActAnswersAcrossFortyFourWithoutMovingItsWord() async throws {
        let probe = Probe()
        try await hosted(
            HStack(spacing: 0) {
                Button {} label: {
                    Text("Edit")
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                }
                .buttonStyle(PhoneInlineActStyle(tokens: .studyLight))
                Button("Put back") {}.buttonStyle(PhoneInlineActStyle(tokens: .studyLight, alignment: .leading))
            }
        ) { surface in
            let edit = try frame(surface, "Edit")
            #expect(edit.width >= 43.5 && edit.height >= 43.5, "Edit \(edit)")
            // The word draws at its own size (15 pt, ~20 tall), inside the 44.
            #expect(probe.size.height < 30 && probe.size.height > 15, "drawn \(probe.size)")
            #expect(probe.size.width < 44, "the word is narrower than its hit area: \(probe.size)")
            let putBack = try frame(surface, "Put back")
            #expect(putBack.height >= 43.5 && putBack.width >= 43.5)
        }
    }

    // MARK: Icon button

    @Test func theIconButtonIsAFortyFourSquareAroundATwentyTwoPointGlyph() async throws {
        let probe = Probe()
        try await hosted(
            HStack(spacing: 0) {
                Button {} label: {
                    Image(systemName: "magnifyingglass")
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                }
                .buttonStyle(PhoneIconButtonStyle(tokens: .studyLight))
                .accessibilityLabel("Find")
                Button {} label: { Image(systemName: "ellipsis") }
                    .buttonStyle(PhoneIconButtonStyle(tokens: .studyLight))
                    .accessibilityLabel("More")
            }
        ) { surface in
            let find = try frame(surface, "Find")
            let more = try frame(surface, "More")
            #expect(abs(find.width - 44) <= 0.5 && abs(find.height - 44) <= 0.5, "Find \(find)")
            // Neighbours may touch — centres 44 apart.
            #expect(abs(more.midX - find.midX - 44) <= 0.5, "centres \(find.midX) \(more.midX)")
            // The glyph is drawn at the 22 pt size, well inside its 44.
            #expect(probe.size.height > 16 && probe.size.height < 30, "glyph \(probe.size)")
        }
        #expect(PhoneControlGlyph.pointSize(22, at: .large) == 22)
        #expect(PhoneControlGlyph.pointSize(22, at: .accessibility5)
                == PhoneControlGlyph.pointSize(22, at: .xxxLarge), "the glyph is chrome: it holds")
    }

    // MARK: Chip

    @Test func theChipIsAThirtyTwoCapsuleInAFortyFourHitArea() async throws {
        let probe = Probe()
        try await hosted(
            HStack(spacing: 0) {
                Button {} label: {
                    Text("Essays")
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                }
                .buttonStyle(PhoneChipStyle(tokens: .studyLight))
                Button("✎") {}.buttonStyle(PhoneChipStyle(tokens: .studyLight))
            }
        ) { surface in
            let chip = try frame(surface, "Essays")
            #expect(chip.height >= 43.5, "the hit area is 44 tall: \(chip)")
            // 12 inside each side of the word.
            #expect(chip.width >= probe.size.width + 24 - 0.5, "chip \(chip) word \(probe.size)")
            let narrow = try frame(surface, "✎")
            #expect(narrow.width >= 43.5 && narrow.height >= 43.5, "a one-glyph chip still answers across 44: \(narrow)")
        }
        #expect(PhoneControlMetrics.chipHeight == 32)
    }

    // MARK: Field

    @Test func theFieldIsAtLeastFortyFourTallAndGrowsWithItsText() async throws {
        let probe = Probe()
        try await hosted(
            TextField("Search", text: .constant(""))
                .phoneField(.studyLight)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                .padding(.horizontal, 20)
        ) { _ in
            #expect(probe.size.height >= 43.5, "field \(probe.size)")
            #expect(abs(probe.size.width - (402 - 40)) <= 0.5, "the field spans its row: \(probe.size)")
        }
        try await hosted(
            TextField("Search", text: .constant(""))
                .phoneField(.studyLight)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                .dynamicTypeSize(.xxxLarge)
        ) { _ in
            #expect(probe.size.height > 44, "the field grows with the text size: \(probe.size)")
        }
    }

    // MARK: The calm button

    @Test func theCalmButtonIsAtLeastSixtyFourByFortyFourAndSpansWhenAsked() async throws {
        for tokens in [VoiceTokens.studyLight, .terminalDark] {
            try await hosted(
                VStack(alignment: .leading, spacing: 8) {
                    Button("Open") {}.buttonStyle(PhoneCalmButtonStyle(tokens: tokens))
                    Button("Create Book") {}.buttonStyle(PhoneCalmButtonStyle(tokens: tokens, fullWidth: true))
                }
                .padding(.horizontal, 20)
            ) { surface in
                let open = try frame(surface, "Open")
                #expect(open.width >= 63.5 && open.height >= 43.5, "Open \(open)")
                let create = try frame(surface, "Create Book")
                #expect(abs(create.width - (402 - 40)) <= 0.5 && create.height >= 43.5, "Create \(create)")
            }
        }
    }

    // MARK: Sheet header

    @Test func theSheetHeaderPutsDoneEightFromTheEdgeOnAFiftySixRow() async throws {
        for tokens in [VoiceTokens.studyLight, .terminalLight] {
            let probe = Probe()
            try await hosted(
                VStack(alignment: .leading, spacing: 0) {
                    // The title voiced as every site hands it (`chromeLabel`
                    // or `path`): the header draws and speaks its title
                    // exactly as given, so a path title passes through
                    // un-re-voiced. (This case first built it raw — "Tags" —
                    // and looked for the voiced "tags", which Terminal
                    // could never draw: the batch-2 window's red.)
                    PhoneSheetHeader(tokens.chromeLabel("Tags"), tokens: tokens, done: {})
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
                    Text("content")
                }
                .padding(20)
            ) { surface in
                let doneWord = tokens.chromeLabel("Done")
                let done = try frame(surface, doneWord)
                #expect(done.width >= 63.5 && done.height >= 43.5, "Done \(done)")
                #expect(abs(done.maxX - (402 - 8)) <= 0.5, "Done's hit area ends 8 from the edge: \(done.maxX)")
                #expect(probe.size.height >= 55.5, "the header row is at least 56: \(probe.size)")
                let title = try frame(surface, tokens.chromeLabel("Tags"))
                #expect(abs(title.minX - 20) <= 0.5, "the title sits on the gutter: \(title.minX)")
            }
        }
    }

    @Test func theSheetHeadersDoneDismisses() async throws {
        let probe = Probe()
        try await hosted(
            VStack {
                PhoneSheetHeader("Blocks", tokens: .terminalLight, done: { probe.picks.append("done") })
            }
            .padding(20)
        ) { surface in
            // The label is the voiced word the site always drew (Terminal
            // lowercases) — a pin that drives Done by its word keeps working.
            #expect(surface.activate("done"), "labels were \(surface.visibleLabels)")
            #expect(probe.picks == ["done"])
        }
    }

    // MARK: The segmented choice — the selection contract

    private enum Kind: String, CaseIterable { case notes = "Notes", books = "Books", tags = "Tags" }

    @Test func theSegmentedChoiceSpeaksPlainWordsMarksTheSelectionAndSelectsOnce() async throws {
        for tokens in [VoiceTokens.terminalLight, .studyLight] {
            let probe = Probe()
            try await hosted(
                PhoneSegmentedChoice(
                    Kind.allCases, selection: .books, tokens: tokens, word: \.rawValue,
                    select: { probe.picks.append($0.rawValue) })
                    .padding(.horizontal, 20)
            ) { surface in
                for kind in Kind.allCases {
                    let element = try #require(
                        surface.element(labeled: kind.rawValue),
                        "the \(kind.rawValue) segment speaks its plain word in \(tokens.voice): \(surface.visibleLabels)")
                    let selected = element.accessibilityTraits.contains(.selected)
                    #expect(selected == (kind == .books), "\(kind) selected=\(selected)")
                    #expect(element.accessibilityFrame.height >= 43.5,
                            "\(kind) answers 44 tall: \(element.accessibilityFrame)")
                }
                // Choosing the shown selection again does nothing.
                #expect(surface.activate(Kind.books.rawValue))
                #expect(probe.picks.isEmpty, "re-choosing the selection calls nothing: \(probe.picks)")
                // Choosing another calls select once, with that value.
                #expect(surface.activate(Kind.tags.rawValue))
                #expect(probe.picks == ["Tags"])
                // The segments are laid side by side, inside the gutters.
                let frames = try Kind.allCases.map { try frame(surface, $0.rawValue) }
                #expect(frames.map(\.minX) == frames.map(\.minX).sorted())
                #expect((frames.first?.minX ?? 0) >= 19.5 && (frames.last?.maxX ?? 999) <= 402 - 19.5)
            }
        }
    }

    // MARK: Section header

    @Test func theSectionHeaderHasTwentyFourAboveAndEightBelow() async throws {
        let probe = Probe()
        try await hosted(
            PhoneSectionHeader("Add to a book", tokens: .studyLight)
                .onGeometryChange(for: CGSize.self) { $0.size } action: { probe.size = $0 }
        ) { _ in
            // 24 + one 13 pt line (~16–18) + 8.
            #expect(probe.size.height >= 24 + 15 + 8 && probe.size.height <= 24 + 20 + 8,
                    "section header \(probe.size)")
        }
    }

    // MARK: Menu row

    @Test func theMenuRowsFloorsAreFortyFourFiftyTwoAndSixtyFour() async throws {
        try await hosted(
            VStack(spacing: 0) {
                PhoneMenuRow("Undo", tokens: .studyLight, action: {})
                PhoneMenuRow("Versions", glyph: "clock", tokens: .studyLight, action: {})
                PhoneMenuRow(
                    "Save a version", detail: "Keeps a moment of the note to come back to",
                    glyph: "bookmark", tokens: .studyLight, action: {})
                PhoneMenuRow("Delete note…", tone: .alarm, tokens: .studyLight, action: {})
            }
            .padding(.horizontal, 20)
        ) { surface in
            let plain = try frame(surface, "Undo")
            let glyph = try frame(surface, "Versions")
            let detail = try #require(surface.visibleElements.first {
                ($0.accessibilityLabel ?? "").hasPrefix("Save a version")
            }?.accessibilityFrame, "labels: \(surface.visibleLabels)")
            #expect(plain.height >= 43.5, "a one-line row is at least 44: \(plain)")
            #expect(glyph.height >= 51.5, "a row with a glyph is at least 52: \(glyph)")
            #expect(detail.height >= 63.5, "a row with a detail line is at least 64: \(detail)")
            // The whole row is one target.
            for row in [plain, glyph, detail] {
                #expect(abs(row.width - (402 - 40)) <= 0.5, "the row spans its width: \(row)")
            }
        }
    }

    // MARK: The overlays' UIKit hit area

    @Test func theOverlayButtonAnswersAcrossFortyFourWithoutMoving() {
        let button = PhoneHitAreaButton(type: .system)
        button.frame = CGRect(x: 100, y: 100, width: 30, height: 24)
        // Its drawing and frame are untouched…
        #expect(button.frame.size == CGSize(width: 30, height: 24))
        // …and its touch region reaches 7 past each side and 10 above and below.
        #expect(button.point(inside: CGPoint(x: -6.5, y: 12), with: nil))
        #expect(button.point(inside: CGPoint(x: 36.5, y: 12), with: nil))
        #expect(button.point(inside: CGPoint(x: 15, y: -9.5), with: nil))
        #expect(button.point(inside: CGPoint(x: 15, y: 33.5), with: nil))
        #expect(!button.point(inside: CGPoint(x: -7.5, y: 12), with: nil))
        #expect(!button.point(inside: CGPoint(x: 15, y: 34.5), with: nil))
        // A control already 44 or more keeps its own bounds.
        let big = PhoneHitAreaButton(type: .system)
        big.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        #expect(!big.point(inside: CGPoint(x: -0.5, y: 10), with: nil))
        #expect(big.point(inside: CGPoint(x: 0.5, y: 0.5), with: nil))
    }
}
