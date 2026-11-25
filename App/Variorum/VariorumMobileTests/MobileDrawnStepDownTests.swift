//
//  MobileDrawnStepDownTests.swift
//  VariorumMobileTests
//
//  VM-273 (the VM-260 run, batch 2) — **THE DRAWINGS STEP DOWN; THE TARGETS DO
//  NOT.** Her words: "everything being too big and somethings not matching the
//  mac's app of having more squares", "ridiculously oversized icons". The traced
//  mechanism (the run record, batch 2): wave 1 drew its controls at or near the
//  size of their targets — a 22 pt glyph in a 44 pt icon button, a 32 pt capsule
//  in a 44 pt chip, the calm button's and the field's boxes the full 44 — its
//  chrome words at the sizes of her own words (17, 15), and every corner 12 or a
//  capsule where the Mac's chips are 4 and its boxes 8.
//
//  THE PINS (red on old where they say so; the pre-fix tree is this file's own
//  commit, built into its own DerivedData):
//  · the chrome roles sit one notch under her words — RED ON OLD;
//  · the Mac's two corners, and the bar's chip on the chips' corner — RED ON OLD;
//  · what each control DRAWS, read as pixels off a real window: the icon
//    button's glyph at a 17 pt symbol's size, the chip 24 tall and near-square,
//    the calm button's and the field's boxes 36 inside their 44 — RED ON OLD;
//  · every control still answers across its whole target — a GUARD, green on
//    both trees (the review's focus: a smaller drawing never a smaller target).
//
//  Only symbols both trees declare, so the red-on-old run drops this file into
//  the pre-fix tree unchanged.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The chrome roles and the corners (pure)

@MainActor
@Suite("VM-273 — chrome one notch under her words; the Mac's two corners")
struct MobileDrawnStepDownTableTests {
    /// **RED ON OLD** (control 17, controlInline 15, chip 15, the note title 24).
    /// Chrome reads one notch under the her-words role it sits beside: a
    /// control's word (15) under her body (17), a chip and an inline act (13)
    /// under her previews (15) — the five-size scale and the 13 pt floor kept.
    /// The bar's words stay 17: LK-5 is her ruling ("three words at 17 pt").
    @Test func theChromeSitsOneNotchUnderHerWords() {
        let study = { (role: PhoneTypeRole) in PhoneType.spec(role, voice: .study) }
        let control = study(.control)
        #expect(control.size == 15 && control.lineHeight == 20 && control.anchor == .subheadline,
                "control: \(control)")
        let inline = study(.controlInline)
        #expect(inline.size == 13 && inline.lineHeight == 18 && inline.anchor == .footnote,
                "controlInline: \(inline)")
        #expect(study(.chip) == PhoneTypeSpec(
            family: .chrome, weight: .medium, size: 13, lineHeight: 18,
            anchor: .footnote, scaling: .holdsAtXXXLarge), "chip: \(study(.chip))")
        // Untouched: the bar's ruled words, the floor's two roles.
        #expect(study(.tab).size == 17, "LK-5 — the bar's words stay 17")
        #expect(study(.meta).size == 13 && study(.sectionHeader).size == 13)
        // Her words are batch 3's (R-260-2) — unchanged here, but the note's title
        // (VM-272): Study 20 / 25 on `.title3`, Terminal two under (18 / 23).
        let title = study(.noteTitle)
        #expect(title.size == 20 && title.lineHeight == 25 && title.anchor == .title3, "noteTitle: \(title)")
        let terminalTitle = PhoneType.spec(.noteTitle, voice: .terminal)
        #expect(terminalTitle.size == 18 && terminalTitle.lineHeight == 23, "Terminal noteTitle: \(terminalTitle)")
        #expect(study(.noteBody).size == 17 && study(.rowTitle).size == 17
                && study(.rowPreview).size == 15 && study(.screenTitle).size == 20
                && study(.mono).size == 17, "her other words are batch 3's to move")
        // The principle, as an order.
        #expect(control.size < study(.noteBody).size)
        #expect(study(.chip).size < study(.rowPreview).size && inline.size < study(.rowPreview).size)
        // Chrome is never "two under" in Terminal: the same numbers in SF Mono.
        for role in [PhoneTypeRole.control, .controlInline, .chip] {
            let terminal = PhoneType.spec(role, voice: .terminal)
            #expect(terminal.size == study(role).size && terminal.family == .mono, "\(role) in Terminal")
        }
    }

    /// The floor holds under the new 13s at the smallest settings, in both forms
    /// (a GUARD — the floor's own pins cover every role; these two are the roles
    /// this pass brought down to it).
    @Test func theNewThirteensNeverDipUnderTheFloor() {
        for voice in ThemeVoice.allCases {
            for role in [PhoneTypeRole.chip, .controlInline] {
                let spec = PhoneType.spec(role, voice: voice)
                for setting in [UIContentSizeCategory.extraSmall, .small, .medium, .large] {
                    #expect(PhoneType.pointSize(spec, at: setting) >= PhoneType.floorSize,
                            "\(role) \(voice) at \(setting.rawValue)")
                    let font = PhoneType.uiFont(
                        role, voice: voice,
                        compatibleWith: UITraitCollection(preferredContentSizeCategory: setting))
                    #expect(font.pointSize >= PhoneType.floorSize, "\(role) \(voice) UIKit at \(setting.rawValue)")
                }
            }
        }
    }

    /// **RED ON OLD** (6 and 12; the bar's chip on 12). The Mac's own two
    /// corners: 4 for a chip (`QuietFill.corner`, her "very subtle and square")
    /// and 8 for a box (its toast, cards and fields).
    @Test func theCornersAreTheMacsTwo() {
        #expect(PhoneMetrics.Radius.small == 4, "a chip's corner: \(PhoneMetrics.Radius.small)")
        #expect(PhoneMetrics.Radius.standard == 8, "a box's corner: \(PhoneMetrics.Radius.standard)")
        #expect(MobileTabBarMetrics.chipRadius == PhoneMetrics.Radius.small,
                "the bar's chip is the chips' near-square: \(MobileTabBarMetrics.chipRadius)")
    }
}

// MARK: - What the controls draw (pixels)

private extension RenderedPixels {
    /// The bounding box, in points, of every pixel inside `rect` that differs
    /// from `ground` by more than `threshold` — what is drawn there.
    func drawnBox(in rect: CGRect, ground: PixelColor, threshold: Double = 0.025) -> CGRect? {
        let x0 = max(Int(rect.minX * scale), 0), x1 = min(Int(rect.maxX * scale), width)
        let y0 = max(Int(rect.minY * scale), 0), y1 = min(Int(rect.maxY * scale), height)
        guard x0 < x1, y0 < y1 else { return nil }
        var top = Int.max, bottom = Int.min, left = Int.max, right = Int.min
        for y in y0..<y1 {
            for x in x0..<x1 where pixel(x, y).distance(to: ground) > threshold {
                top = min(top, y); bottom = max(bottom, y)
                left = min(left, x); right = max(right, x)
            }
        }
        guard top <= bottom else { return nil }
        return CGRect(
            x: CGFloat(left) / scale, y: CGFloat(top) / scale,
            width: CGFloat(right - left + 1) / scale, height: CGFloat(bottom - top + 1) / scale)
    }
}

@MainActor
@Suite("VM-273 — the controls draw well inside their targets (rendered)", .serialized)
struct MobileDrawnStepDownRenderedTests {
    /// The probe: each control once, apart, on the paper; and a bare 17 pt
    /// symbol — the size the icon button's glyph must draw at.
    private func probe(_ tokens: VoiceTokens) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Button {} label: { Image(systemName: "magnifyingglass") }
                .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
                .accessibilityLabel("Find")
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(tokens.ink)
                .frame(width: 44, height: 44)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Reference glyph")
            Button("Essays") {}.buttonStyle(PhoneChipStyle(tokens: tokens))
            Button("Open") {}.buttonStyle(PhoneCalmButtonStyle(tokens: tokens))
            TextField("Search", text: .constant(""))
                .textFieldStyle(.plain)
                .phoneField(tokens)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Field probe")
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.surface.ignoresSafeArea())
    }

    /// **RED ON OLD — "ridiculously oversized icons".** Read off a real window:
    /// the icon button's glyph draws at a 17 pt symbol's size (it drew 22); the
    /// chip's shape is 24 tall (32) and near-square — its corner pixel filled,
    /// where a capsule leaves it bare; the calm button's box and the field's box
    /// are 36 (they filled their 44). Each still sits in a 44 pt target.
    @Test(arguments: [ThemeVoice.study, .terminal])
    func theDrawingsSitWellInsideTheirTargets(voice: ThemeVoice) async throws {
        let tokens: VoiceTokens = voice == .study ? .studyLight : .terminalLight
        try await withSceneSurface(probe(tokens), dark: false) { surface in
            await surface.settle(30)
            let pixels = try surface.render()
            let ground = PixelColor(UIColor(tokens.surface), traits: surface.traits)
            func frame(_ label: String) throws -> CGRect {
                try #require(surface.onScreen(label), "\(label): \(surface.labels)").accessibilityFrame
            }
            func drawn(_ label: String) throws -> (frame: CGRect, box: CGRect) {
                let target = try frame(label)
                let box = try #require(pixels.drawnBox(in: target, ground: ground),
                                       "nothing drawn in \(label) (\(target))")
                return (target, box)
            }
            let icon = try drawn("Find")
            let reference = try drawn("Reference glyph")
            let chip = try drawn("Essays")
            let calm = try drawn("Open")
            let field = try drawn("Field probe")
            print("PERF[sim] VM-273 drawn \(tokens.voice): glyph \(icon.box.size) vs 17 pt \(reference.box.size) "
                  + "in \(icon.frame.size) · chip \(chip.box.size) in \(chip.frame.size) · calm \(calm.box.size) "
                  + "in \(calm.frame.size) · field \(field.box.size) in \(field.frame.size)")

            // The icon button: a 17 pt glyph inside its 44 × 44.
            #expect(abs(icon.box.height - reference.box.height) <= 1
                    && abs(icon.box.width - reference.box.width) <= 1,
                    "the glyph draws at 17 pt: \(icon.box.size) vs \(reference.box.size)")
            #expect(icon.frame.width >= 43.5 && icon.frame.height >= 43.5, "its target: \(icon.frame)")

            // The chip: 24 tall, near-square, in a 44 pt target.
            #expect(chip.box.height <= 26 && chip.box.height >= 20, "the chip draws 24 tall: \(chip.box)")
            #expect(chip.frame.height >= 43.5 && chip.frame.width >= 43.5, "its target: \(chip.frame)")
            let corner = pixels.color(at: CGPoint(x: chip.box.minX + 2.5, y: chip.box.minY + 2.5))
            #expect(corner.distance(to: ground) > 0.02,
                    "the chip's corner is filled — near-square, not a capsule: \(corner) on \(ground)")

            // The calm button: a 36 pt box inside its 64 × 44.
            #expect(calm.box.height <= 38.5 && calm.box.height >= 32, "the box draws 36: \(calm.box)")
            #expect(calm.frame.width >= 63.5 && calm.frame.height >= 43.5, "its target: \(calm.frame)")

            // The field: a 36 pt box inside its 44 pt frame.
            #expect(field.box.height <= 38.5 && field.box.height >= 32, "the box draws 36: \(field.box)")
            #expect(field.frame.height >= 43.5, "its frame keeps 44: \(field.frame)")
        }
    }
}

// MARK: - Every control still answers across its target (the guard)

@MainActor
@Suite("VM-273 — every control answers across its whole target (guard)", .serialized)
struct MobileDrawnStepDownTargetTests {
    /// **A GUARD — green on both trees, and the review's focus:** a smaller
    /// drawing is never a smaller target. Every control in the set, both voices,
    /// at the default text size and at the smallest (where the floor holds):
    /// the text button and the calm button at least 64 × 44, the inline act, the
    /// icon button and both chips at least 44 × 44, a menu row with a glyph at
    /// least 52 tall across its width, the sheet header's Done 64 × 44.
    @Test(arguments: [ThemeVoice.study, .terminal], [DynamicTypeSize.large, .xSmall])
    func everyControlAnswersAcrossItsWholeTarget(voice: ThemeVoice, size: DynamicTypeSize) async throws {
        let tokens: VoiceTokens = voice == .study ? .studyLight : .terminalLight
        let done = tokens.chromeLabel("Done")
        let view = VStack(alignment: .leading, spacing: 8) {
            PhoneSheetHeader(tokens.chromeLabel("Tags"), tokens: tokens, done: {})
            HStack(spacing: 0) {
                Button("Put back") {}.buttonStyle(PhoneTextButtonStyle(tokens: tokens))
                Button("Edit") {}.buttonStyle(PhoneInlineActStyle(tokens: tokens))
                Button {} label: { Image(systemName: "gearshape") }
                    .buttonStyle(PhoneIconButtonStyle(tokens: tokens))
                    .accessibilityLabel("Gear")
                Button("✎") {}.buttonStyle(PhoneChipStyle(tokens: tokens))
                Button("All") {}.buttonStyle(PhoneChipStyle(tokens: tokens, selected: false))
            }
            Button("Open") {}.buttonStyle(PhoneCalmButtonStyle(tokens: tokens))
            PhoneMenuRow("Versions", glyph: "clock", tokens: tokens, action: {})
            Spacer(minLength: 0)
        }
        .padding(20)
        .dynamicTypeSize(size)
        try await withHostedSurface(view, size: CGSize(width: 402, height: 700)) { surface in
            await surface.settle(12)
            func frame(_ label: String) throws -> CGRect {
                try #require(surface.element(labeled: label), "\(label): \(surface.visibleLabels)")
                    .accessibilityFrame
            }
            let wide = [done, "Put back", "Open"]
            for label in wide {
                let target = try frame(label)
                #expect(target.width >= 63.5 && target.height >= 43.5, "\(label) \(tokens.voice) \(size): \(target)")
            }
            for label in ["Edit", "Gear", "✎", "All"] {
                let target = try frame(label)
                #expect(target.width >= 43.5 && target.height >= 43.5, "\(label) \(tokens.voice) \(size): \(target)")
            }
            let row = try frame("Versions")
            #expect(row.height >= 51.5 && abs(row.width - (402 - 40)) <= 0.5,
                    "a menu row with a glyph \(tokens.voice) \(size): \(row)")
        }
    }
}
