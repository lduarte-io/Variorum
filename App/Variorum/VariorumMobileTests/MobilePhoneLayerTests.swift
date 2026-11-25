//
//  MobilePhoneLayerTests.swift
//  VariorumMobileTests
//
//  VM-48 / VM-49 (the VM-47 run, batch 1) — the phone layer's pins: the
//  role table as the sizing sheet draws it (sizes, line pitches, anchors,
//  the two scaling classes, both voices), the 13 pt floor at every text
//  size, the two corrected inks' contrast floors COMPUTED over every
//  palette and both voices, and the metrics constants with the one
//  hit-area helper. New brains, so these are Swift Testing coverage rather
//  than red-on-old pins; the type sites' migration is pinned by
//  `MobilePhoneTypeSourceTests`.
//

import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The role table

@MainActor
@Suite("Phone layer — the type roles (VM-48)")
struct MobilePhoneTypeTests {
    /// The sheet's table, row by row ("How it is expressed: a phone layer
    /// over the shared tokens"): family, weight, size / line, anchor, cap —
    /// MOVED with VM-273 · VM-272 (the VM-260 run, batch 2, P-260-2a): the
    /// chrome one notch under her words (`chip` and `controlInline` 13 /
    /// 18 `.footnote`, `control` 15 / 20 `.subheadline`) and the note's title
    /// 20 / 25 `.title3`; the bar's 17 (LK-5). MOVED again with VM-254 (batch 3,
    /// her R-260-2, P-260-3a): her words one notch under wave 1's set — the
    /// note's body 16 / 25, a screen's title 19 / 24, a row's title 16 / 21, its
    /// preview 14 / 19, the anchors kept.
    @Test func theStudyTableIsTheSheetsAsDrawn() {
        typealias S = PhoneTypeSpec
        let expected: [PhoneTypeRole: S] = [
            .noteBody: S(family: .prose, weight: .regular, size: 16, lineHeight: 25, anchor: .body, scaling: .fullRange),
            .noteTitle: S(family: .prose, weight: .semibold, size: 20, lineHeight: 25, anchor: .title3, scaling: .fullRange),
            .screenTitle: S(family: .prose, weight: .semibold, size: 19, lineHeight: 24, anchor: .title3, scaling: .fullRange),
            .rowTitle: S(family: .prose, weight: .semibold, size: 16, lineHeight: 21, anchor: .headline, scaling: .fullRange),
            .rowPreview: S(family: .prose, weight: .regular, size: 14, lineHeight: 19, anchor: .subheadline, scaling: .fullRange),
            .meta: S(family: .chrome, weight: .regular, size: 13, lineHeight: 18, anchor: .footnote, scaling: .holdsAtXXXLarge),
            .sectionHeader: S(family: .chrome, weight: .semibold, size: 13, lineHeight: 18, anchor: .footnote, scaling: .holdsAtXXXLarge),
            .chip: S(family: .chrome, weight: .medium, size: 13, lineHeight: 18, anchor: .footnote, scaling: .holdsAtXXXLarge),
            .controlInline: S(family: .chrome, weight: .regular, size: 13, lineHeight: 18, anchor: .footnote, scaling: .holdsAtXXXLarge),
            .control: S(family: .chrome, weight: .regular, size: 15, lineHeight: 20, anchor: .subheadline, scaling: .holdsAtXXXLarge),
            .tab: S(family: .chrome, weight: .regular, size: 17, lineHeight: 22, anchor: .body, scaling: .holdsAtXXXLarge),
            .mono: S(family: .mono, weight: .regular, size: 17, lineHeight: 26, anchor: .body, scaling: .fullRange),
        ]
        #expect(expected.count == PhoneTypeRole.allCases.count, "every role is in the sheet's table")
        for role in PhoneTypeRole.allCases {
            #expect(PhoneType.spec(role, voice: .study) == expected[role], "\(role)")
        }
    }

    /// Terminal: the same roles in SF Mono; its prose roles two points under
    /// Study's (14 · 18 · 17 for body, note title, screen title — the note
    /// title MOVED 22 → 18 with VM-272, the others with VM-254), pitch included,
    /// and NEVER UNDER THE FLOOR (VM-254, MOVED: a row's preview, 14 in Study,
    /// holds 13 / 18 here — two under would be 12); chrome and the twelve words
    /// keep Study's sizes.
    @Test func terminalIsTheSameRolesInMonoWithItsProseTwoUnder() {
        #expect(PhoneType.spec(.noteBody, voice: .terminal).size == 14)
        #expect(PhoneType.spec(.noteTitle, voice: .terminal).size == 18)
        #expect(PhoneType.spec(.screenTitle, voice: .terminal).size == 17)
        #expect(PhoneType.spec(.rowPreview, voice: .terminal).size == 13
                && PhoneType.spec(.rowPreview, voice: .terminal).lineHeight == 18)
        for role in PhoneTypeRole.allCases {
            let study = PhoneType.spec(role, voice: .study)
            let terminal = PhoneType.spec(role, voice: .terminal)
            #expect(terminal.family == .mono, "\(role) is SF Mono in Terminal")
            let under: CGFloat = study.family == .prose
                ? min(2, study.size - PhoneType.floorSize) : 0
            #expect(terminal.size == study.size - under, "\(role) size")
            #expect(terminal.lineHeight == study.lineHeight - under, "\(role) pitch")
            #expect(terminal.anchor == study.anchor && terminal.scaling == study.scaling
                    && terminal.weight == study.weight, "\(role)")
        }
    }

    /// The two scaling classes: her words scale across the whole range,
    /// chrome holds at xxxLarge.
    @Test func herWordsScaleTheWholeRangeAndChromeHolds() {
        let full: Set<PhoneTypeRole> = [.noteBody, .noteTitle, .screenTitle, .rowTitle, .rowPreview, .mono]
        for role in PhoneTypeRole.allCases {
            #expect(role.scaling == (full.contains(role) ? .fullRange : .holdsAtXXXLarge), "\(role)")
        }
    }

    private static let everySetting: [UIContentSizeCategory] = [
        .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge,
        .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge,
        .accessibilityExtraLarge, .accessibilityExtraExtraLarge,
        .accessibilityExtraExtraExtraLarge,
    ]

    /// **Nothing on the phone is set below 13 pt** — at any text size, in
    /// either voice, for any role (the smallest settings shrink the anchors
    /// below their Large sizes; the floor holds them).
    @Test func nothingIsEverBelowThirteenPoints() {
        for voice in ThemeVoice.allCases {
            for role in PhoneTypeRole.allCases {
                let spec = PhoneType.spec(role, voice: voice)
                #expect(spec.size >= PhoneType.floorSize, "\(role) \(voice) table size")
                for setting in Self.everySetting {
                    #expect(PhoneType.pointSize(spec, at: setting) >= 13,
                            "\(role) \(voice) at \(setting.rawValue)")
                }
            }
        }
    }

    /// **…and in the UIKit form too** (the midway review's M-1): the
    /// overlays, the takes chrome and the segmented choice read
    /// `PhoneType.uiFont`, and below the default setting the anchors' curves
    /// took it under the floor (Terminal `rowPreview` ≈ 10.4 at xSmall,
    /// `meta` 12.0 through xSmall–Medium) while the SwiftUI form held 13 —
    /// one role, two sizes on one screen. RED ON OLD by reverting `uiFont`
    /// alone. A floored font keeps the role's own face.
    @Test func theUIKitFormIsNeverBelowThirteenPointsEither() {
        for voice in ThemeVoice.allCases {
            for role in PhoneTypeRole.allCases {
                for setting in Self.everySetting {
                    let font = PhoneType.uiFont(
                        role, voice: voice,
                        compatibleWith: UITraitCollection(preferredContentSizeCategory: setting))
                    #expect(font.pointSize >= PhoneType.floorSize,
                            "\(role) \(voice) UIKit at \(setting.rawValue): \(font.pointSize)")
                }
            }
        }
        let smallest = UITraitCollection(preferredContentSizeCategory: .extraSmall)
        #expect(PhoneType.uiFont(.rowPreview, voice: .study, compatibleWith: smallest)
                    .familyName == "Iowan Old Style")
        #expect(PhoneType.uiFont(.rowPreview, voice: .terminal, compatibleWith: smallest)
                    .fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
    }

    /// At the default setting every role is exactly its table size, in both
    /// forms (identity at Large, so a hosted surface measures the sheet).
    @Test func atTheDefaultSizeEveryRoleIsItsTableSize() {
        let large = UITraitCollection(preferredContentSizeCategory: .large)
        for voice in ThemeVoice.allCases {
            for role in PhoneTypeRole.allCases {
                let spec = PhoneType.spec(role, voice: voice)
                #expect(PhoneType.pointSize(spec, at: .large) == spec.size, "\(role) \(voice)")
                let font = PhoneType.uiFont(role, voice: voice, compatibleWith: large)
                #expect(abs(font.pointSize - spec.size) < 0.01, "\(role) \(voice) UIKit \(font.pointSize)")
            }
        }
    }

    /// The classes, measured: from xxxLarge to the largest accessibility
    /// size her words keep growing and chrome stands still — in the SwiftUI
    /// rule and in the UIKit font alike.
    @Test func chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing() {
        let hold = UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge)
        let largest = UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraExtraLarge)
        for voice in ThemeVoice.allCases {
            for role in PhoneTypeRole.allCases {
                let spec = PhoneType.spec(role, voice: voice)
                let atHold = PhoneType.pointSize(spec, at: .extraExtraExtraLarge)
                let atLargest = PhoneType.pointSize(spec, at: .accessibilityExtraExtraExtraLarge)
                #expect(atHold > spec.size, "\(role) grows up to xxxLarge")
                let uiHold = PhoneType.uiFont(role, voice: voice, compatibleWith: hold).pointSize
                let uiLargest = PhoneType.uiFont(role, voice: voice, compatibleWith: largest).pointSize
                switch role.scaling {
                case .fullRange:
                    #expect(atLargest > atHold, "\(role) keeps growing")
                    #expect(uiLargest > uiHold, "\(role) UIKit keeps growing")
                case .holdsAtXXXLarge:
                    #expect(atLargest == atHold, "\(role) holds")
                    #expect(abs(uiLargest - uiHold) < 0.01, "\(role) UIKit holds")
                }
            }
        }
    }

    /// The faces are the voice's: Iowan Old Style for Study's prose (her
    /// words in her face), SF Pro for Study's chrome, SF Mono for every
    /// Terminal role and for the twelve words in both voices.
    @Test func theFacesAreTheVoicesOwn() {
        let study = PhoneType.uiFont(.noteBody, voice: .study)
        #expect(study.familyName == "Iowan Old Style")
        #expect(PhoneType.uiFont(.rowTitle, voice: .study).familyName == "Iowan Old Style")
        let chrome = PhoneType.uiFont(.meta, voice: .study)
        #expect(!chrome.fontDescriptor.symbolicTraits.contains(.traitMonoSpace))
        #expect(chrome.familyName != "Iowan Old Style")
        for role in PhoneTypeRole.allCases {
            let terminal = PhoneType.uiFont(role, voice: .terminal)
            #expect(terminal.fontDescriptor.symbolicTraits.contains(.traitMonoSpace), "\(role)")
        }
        #expect(PhoneType.uiFont(.mono, voice: .study).fontDescriptor
                    .symbolicTraits.contains(.traitMonoSpace))
    }

    /// The SwiftUI form resolves the same size the rule names, and the line
    /// pitch rides with it (the role's pitch, never less than the font's own
    /// line).
    @Test func theSwiftUIFormCarriesTheRulesSizeAndPitch() {
        for voice in ThemeVoice.allCases {
            for role in PhoneTypeRole.allCases {
                let spec = PhoneType.spec(role, voice: voice)
                for setting in [UIContentSizeCategory.large, .extraExtraExtraLarge,
                                .accessibilityExtraExtraExtraLarge] {
                    let resolved = PhoneType.resolved(role, voice: voice, at: setting)
                    #expect(resolved.pointSize == PhoneType.pointSize(spec, at: setting))
                    let natural = PhoneType.baseUIFont(
                        spec, voice: voice, pointSize: resolved.pointSize).lineHeight
                    let pitch = natural + resolved.lineSpacing
                    let wanted = spec.lineHeight * resolved.pointSize / spec.size
                    #expect(resolved.lineSpacing >= 0)
                    #expect(abs(pitch - max(wanted, natural)) <= 0.5 + 0.01,
                            "\(role) \(voice) \(setting.rawValue): pitch \(pitch) wanted \(wanted)")
                }
            }
        }
    }

    /// SwiftUI's setting maps onto UIKit's category one for one.
    @Test func everyDynamicTypeSizeMapsToItsCategory() {
        let pairs: [(DynamicTypeSize, UIContentSizeCategory)] = [
            (.xSmall, .extraSmall), (.small, .small), (.medium, .medium), (.large, .large),
            (.xLarge, .extraLarge), (.xxLarge, .extraExtraLarge), (.xxxLarge, .extraExtraExtraLarge),
            (.accessibility1, .accessibilityMedium), (.accessibility2, .accessibilityLarge),
            (.accessibility3, .accessibilityExtraLarge), (.accessibility4, .accessibilityExtraExtraLarge),
            (.accessibility5, .accessibilityExtraExtraExtraLarge),
        ]
        #expect(pairs.count == DynamicTypeSize.allCases.count)
        for (size, category) in pairs {
            #expect(size.phoneCategory == category, "\(size)")
        }
    }
}

// MARK: - The two corrected inks

@MainActor
@Suite("Phone layer — the two corrected inks (VM-48, sheet §D)")
struct MobilePhoneInkTests {
    /// **THE FLOORS, COMPUTED over every ground the app ships** — the
    /// sixteen palettes' rooms, papers and cards and the Classic grounds,
    /// in both voices and both appearances: `muted` ≥ 4.5:1, `faint` ≥ 3:1.
    @Test func theInksClearTheirFloorsOnEveryGroundInEveryVoice() {
        var checked = 0
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                let grounds = PhoneInks.grounds(voice, dark: dark)
                for ink in PhoneInks.Ink.allCases {
                    let value = PhoneInks.value(ink, voice: voice, dark: dark)
                    for ground in grounds {
                        let ratio = PaletteDerivation.contrast(value, ground)
                        checked += 1
                        #expect(ratio >= ink.floor,
                                "\(ink) \(voice) \(dark ? "dark" : "light"): \(String(format: "#%06X", value)) on \(String(format: "#%06X", ground)) = \(ratio)")
                    }
                }
            }
        }
        // 2 voices × 2 appearances × 2 inks × (two Classic rooms + own paper
        // and card + 16 palettes × room, paper, card).
        #expect(checked == 2 * 2 * 2 * (2 + 2 + 16 * 3))
    }

    /// The grounds really are every shipped palette — a seventeenth palette
    /// joins the floor by construction, and this count says so.
    @Test func theGroundsSpanEveryShippedPalette() {
        #expect(PalettePreset.all.count == 16)
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                let grounds = PhoneInks.grounds(voice, dark: dark)
                #expect(grounds.count == 2 + 2 + PalettePreset.all.count * 3)
                for preset in PalettePreset.all.values {
                    #expect(grounds.contains(PaletteDerivation.derive(preset, dark: dark).room))
                }
            }
        }
    }

    /// **The rule IS the sheet's:** it reproduces the sheet's Study light
    /// inks exactly (#6A6359 / #8B7F6A, binding on rose & moss's room).
    @Test func theRuleReproducesTheSheetsStudyInks() {
        #expect(PhoneInks.derive(.muted, voice: .study, dark: false) == 0x6A6359)
        #expect(PhoneInks.derive(.faint, voice: .study, dark: false) == 0x8B7F6A)
    }

    /// **The shipped eight ARE the rule's output.** The phone wears
    /// constants (its UIKit face is built off the main actor); this pin
    /// recomputes every one over today's palettes and voices, so a palette
    /// or voice change that would move an ink turns red here instead of
    /// shifting it silently.
    @Test func theShippedInksAreTheRulesOutput() {
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                for ink in PhoneInks.Ink.allCases {
                    let rule = PhoneInks.derive(ink, voice: voice, dark: dark)
                    let shipped = PhoneInks.value(ink, voice: voice, dark: dark)
                    #expect(rule == shipped,
                            "\(ink) \(voice) dark=\(dark): the rule says \(String(format: "#%06X", rule)), the phone ships \(String(format: "#%06X", shipped))")
                }
            }
        }
    }

    /// Dark needs only faint lifted: dark `muted` stays the voice's own in
    /// both voices; dark `faint` moves, lighter.
    @Test func inDarkOnlyFaintIsLifted() {
        for voice in ThemeVoice.allCases {
            let own = PhoneInks.source(voice, dark: true)
            #expect(PhoneInks.value(.muted, voice: voice, dark: true) == own.muted, "\(voice)")
            let faint = PhoneInks.value(.faint, voice: voice, dark: true)
            #expect(faint != own.faint)
            #expect(PaletteDerivation.relativeLuminance(faint)
                    > PaletteDerivation.relativeLuminance(own.faint), "\(voice) faint is lifted")
        }
    }

    /// "The same hue taken darker": every corrected ink keeps the voice's
    /// own hue (HSL hue within rounding of the source's).
    @Test func eachInkKeepsTheVoicesOwnHue() {
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                let own = PhoneInks.source(voice, dark: dark)
                for ink in PhoneInks.Ink.allCases {
                    let source = HSL(ink == .muted ? own.muted : own.faint)
                    let value = HSL(PhoneInks.value(ink, voice: voice, dark: dark))
                    var delta = abs(value.hue - source.hue)
                    delta = min(delta, 1 - delta)
                    #expect(delta < 0.03, "\(ink) \(voice) dark=\(dark): hue \(value.hue) vs \(source.hue)")
                }
            }
        }
    }

    private func hex(_ color: Color) -> UInt32 {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        func byte(_ value: CGFloat) -> UInt32 { UInt32((value * 255).rounded()) }
        return (byte(red) << 16) | (byte(green) << 8) | byte(blue)
    }

    /// **The rule's source numbers ARE the token layer's** — so the Mac's
    /// `muted`/`faint` (and rooms) stay the voice's own and the phone's copy
    /// cannot drift from them silently.
    @Test func theSourceIsTheTokenLayersOwnValues() {
        let sets: [(ThemeVoice, Bool, VoiceTokens)] = [
            (.terminal, false, .terminalLight), (.terminal, true, .terminalDark),
            (.study, false, .studyLight), (.study, true, .studyDark),
        ]
        for (voice, dark, tokens) in sets {
            let source = PhoneInks.source(voice, dark: dark)
            #expect(hex(tokens.muted) == source.muted, "\(voice) dark=\(dark) muted")
            #expect(hex(tokens.faint) == source.faint, "\(voice) dark=\(dark) faint")
            #expect(hex(tokens.room) == source.room, "\(voice) dark=\(dark) room")
            #expect(hex(tokens.surface) == source.surface, "\(voice) dark=\(dark) surface")
            #expect(hex(tokens.card) == source.card, "\(voice) dark=\(dark) card")
        }
    }

    /// The phone's colours resolve per appearance to the rule's values, and
    /// repeated reads are the same objects (the attribute-equality bar).
    @Test func thePhoneColoursAreDynamicAndStable() {
        let light = UITraitCollection(userInterfaceStyle: .light)
        let dark = UITraitCollection(userInterfaceStyle: .dark)
        for voice in ThemeVoice.allCases {
            for ink in PhoneInks.Ink.allCases {
                let color = PhoneInks.uiColor(ink, voice: voice)
                #expect(color === PhoneInks.uiColor(ink, voice: voice))
                #expect(hex(Color(uiColor: color.resolvedColor(with: light)))
                        == PhoneInks.value(ink, voice: voice, dark: false))
                #expect(hex(Color(uiColor: color.resolvedColor(with: dark)))
                        == PhoneInks.value(ink, voice: voice, dark: true))
            }
        }
        #expect(VoiceTokens.terminalLight.phone.muted == VoiceTokens.terminalDark.phone.muted,
                "one dynamic colour per voice")
        #expect(VoiceTokens.terminalLight.phone.muted != VoiceTokens.studyLight.phone.muted)
    }
}

// MARK: - The metrics (VM-49's constants)

@Suite("Phone layer — the metrics (VM-49's constants)")
struct MobilePhoneMetricsTests {
    @Test func theConstantsAreTheSheets() {
        #expect(PhoneMetrics.spacingScale == [4, 8, 12, 16, 20, 24, 32, 48])
        #expect(PhoneMetrics.gutter == 20)
        // MOVED with VM-273 (the VM-260 run, batch 2): the Mac's two corners.
        #expect(PhoneMetrics.Radius.small == 4 && PhoneMetrics.Radius.standard == 8)
        #expect(PhoneMetrics.RowHeight.menu == 44)
        #expect(PhoneMetrics.RowHeight.accessory == 52)
        #expect(PhoneMetrics.RowHeight.titleAndMeta == 64)
        #expect(PhoneMetrics.RowHeight.titleAndPreview == 88)
        #expect(PhoneMetrics.touchMinimum == 44)
    }

    @Test func theHitAreaIsAtLeastFortyFourAndNeverSmallerThanTheControl() {
        #expect(PhoneMetrics.hitArea(for: CGSize(width: 14, height: 14)) == CGSize(width: 44, height: 44))
        #expect(PhoneMetrics.hitArea(for: CGSize(width: 120, height: 20)) == CGSize(width: 120, height: 44))
        #expect(PhoneMetrics.hitArea(for: CGSize(width: 64, height: 60)) == CGSize(width: 64, height: 60))
        let outset = PhoneMetrics.hitOutset(for: CGSize(width: 14, height: 20))
        #expect(outset.horizontal == 15 && outset.vertical == 12)
    }

    @MainActor
    private final class DrawnSize {
        var size: CGSize = .zero
    }

    /// **The helper, measured on a real surface:** a 14 × 14 glyph button
    /// answers across 44 × 44 while the glyph still draws at 14 × 14.
    @Test @MainActor func theHelperGivesAFortyFourHitAreaWithoutChangingTheDrawing() async throws {
        let drawn = DrawnSize()
        let surface = HostedSurface(
            VStack {
                Button {} label: {
                    Rectangle()
                        .frame(width: 14, height: 14)
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { drawn.size = $0 }
                        .phoneHitArea()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("hit area probe")
                Spacer()
            },
            size: CGSize(width: 200, height: 200))
        defer { surface.tearDown() }
        await surface.settle(10)
        let element = try #require(surface.element(labeled: "hit area probe"))
        let frame = element.accessibilityFrame
        #expect(abs(frame.width - 44) <= 0.5 && abs(frame.height - 44) <= 0.5, "hit area \(frame)")
        #expect(drawn.size == CGSize(width: 14, height: 14), "the drawing kept its size: \(drawn.size)")
    }
}
