//
//  PaletteDerivationTests.swift
//  VariorumTests
//
//  18g (the 2026-09-12 use-report round — her R-Q6 · R-Q11 · R-Q13): the
//  palette brain's pins. The batch's rows are TASTE rows, so the evidence
//  is the walk; what a pin can hold is the part taste cannot check by eye —
//  that every preset AND every hex she might type produces chrome that
//  READS (F-8's contrast floor), that R51 survives a palette, that the rule
//  is one rule over a table rather than fifteen special cases, and that the
//  shipped numbers are the ones recorded in the batch's record.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Palette derivation (18g)")
struct PaletteDerivationTests {
    /// Every palette that names a preset, in `ThemePalette`'s own order.
    private var presets: [(ThemePalette, PalettePreset)] {
        ThemePalette.allCases.compactMap { palette in
            PalettePreset.all[palette].map { (palette, $0) }
        }
    }

    // MARK: F-8 — the contrast floor

    /// **THE FLOOR, FOR ALL FIFTEEN, BOTH APPEARANCES.** Her R-Q13 asks for
    /// an accent *"deep and saturated enough to read as ink on the room"*.
    /// The accent is chrome ink on the ROOM ("this note", "commit ⌘S"), it
    /// is selected-row ink on the WASH, and it labels take cards on the
    /// TAKE TINT — so all three backdrops are measured, not just the one
    /// the ruling names.
    ///
    /// This is the pin the brief asks for so *"a future seed edit cannot
    /// ship unreadable chrome"*: change a seed to something luminous and
    /// this fails before it reaches her.
    @Test func everyPresetsAccentReadsAsInkOnItsOwnSurfaces() {
        for (palette, preset) in presets {
            for dark in [false, true] {
                let family = PaletteDerivation.derive(preset, dark: dark)
                for (name, backdrop) in [
                    ("room", family.room), ("wash", family.wash),
                    ("take tint", family.takeTint),
                ] {
                    let ratio = PaletteDerivation.contrast(family.accent, backdrop)
                    #expect(
                        ratio >= PaletteDerivation.contrastFloor,
                        """
                        \(palette.rawValue) \(dark ? "dark" : "light"): the accent \
                        #\(String(format: "%06X", family.accent)) reads at \
                        \(String(format: "%.2f", ratio)):1 on the \(name) \
                        #\(String(format: "%06X", backdrop)) — below AA
                        """)
                }
            }
        }
    }

    /// **The same floor for HER OWN HEX** — the reason the rule corrects
    /// per colour instead of trusting one lightness number. These seeds are
    /// deliberately hostile: pure yellow and pure cyan are the two a fixed
    /// lightness fails hardest, black and white have no hue at all, and the
    /// last pair is a two-hex custom whose accent is far brighter than its
    /// room.
    @Test func anyHexSheCouldTypeStillReads() {
        let seeds: [(String, String?)] = [
            ("FFFF00", nil), ("00FF00", nil), ("00FFFF", nil), ("FF0000", nil),
            ("000000", nil), ("FFFFFF", nil), ("808080", nil), ("B9A7E6", nil),
            ("8A7A3A", "D4A72C"), ("1F4FCF", "FFFF00"), ("F08CA0", "4F7A2E"),
        ]
        for (room, accent) in seeds {
            let tint = PaletteTint(room: room, accent: accent)
            guard let preset = PalettePreset.resolved(.custom, tint: tint) else {
                Issue.record("a valid hex must resolve to a preset: \(room)")
                continue
            }
            for dark in [false, true] {
                let family = PaletteDerivation.derive(preset, dark: dark)
                let worst = [family.room, family.wash, family.takeTint]
                    .map { PaletteDerivation.contrast(family.accent, $0) }
                    .min() ?? 0
                let ratio = String(format: "%.2f", worst)
                #expect(
                    worst >= PaletteDerivation.contrastFloor,
                    """
                    custom #\(room)/\(accent ?? "—") \(dark ? "dark" : "light") \
                    reads at \(ratio):1
                    """)
            }
        }
    }

    // MARK: R51 — dark is a fully black room, palette or no palette

    /// R51 is not special-cased anywhere in the rule: the room's dark
    /// lightness is 0 in both tables, and any hue at lightness 0 is black.
    /// This pin is what stops a future table edit from tinting the dark
    /// room by accident.
    @Test func theDarkRoomStaysFullyBlackUnderEveryPalette() {
        for (palette, preset) in presets {
            #expect(PaletteDerivation.derive(preset, dark: true).room == 0x000000,
                    "R51: \(palette.rawValue)'s dark room must be black")
        }
        let custom = PalettePreset.resolved(.custom, tint: PaletteTint(room: "FFFFFF"))
        #expect(PaletteDerivation.derive(custom!, dark: true).room == 0x000000,
                "R51 holds for her own hex too — even a white seed")
    }

    // MARK: The rule is a rule

    /// The fifteen presets are exactly the fifteen named palettes — no
    /// sixteenth hiding in the table, and no named palette without one.
    /// (`default` means no palette; `custom` reads her hex.)
    @Test func theTableNamesExactlyTheFifteenBuilds() {
        let named = Set(ThemePalette.allCases).subtracting([.default, .custom])
        #expect(Set(PalettePreset.all.keys) == named)
        #expect(named.count == 15)
        // Her three batches, by the shape that distinguishes them: a pastel
        // has ONE seed; a two-tone build has two at the soft level; a bold
        // build has two at the bold level.
        let pastels = PalettePreset.all.values.filter { $0.accentSeed == nil }
        let twoTone = PalettePreset.all.values.filter {
            $0.accentSeed != nil && $0.intensity == .soft
        }
        let bold = PalettePreset.all.values.filter { $0.intensity == .bold }
        #expect(pastels.count == 4)
        #expect(twoTone.count == 6)
        #expect(bold.count == 5)
        #expect(bold.allSatisfy { $0.accentSeed != nil })
    }

    /// A pastel's accent is the ROOM's own hue, deepened — her R-Q13's
    /// *"With one hex it does exactly what the pastels do"*, asserted as
    /// the property it is rather than as four hex constants.
    @Test func anAbsentAccentSeedDeepensTheRoomsOwnHue() {
        for (palette, preset) in presets where preset.accentSeed == nil {
            let family = PaletteDerivation.derive(preset, dark: false)
            let seedHue = HSL(preset.roomSeed).hue
            let accentHue = HSL(family.accent).hue
            #expect(abs(seedHue - accentHue) < 0.02,
                    "\(palette.rawValue): the accent keeps the seed's hue")
            #expect(HSL(family.accent).lightness < HSL(family.room).lightness,
                    "\(palette.rawValue): …and is deeper than the room")
        }
    }

    /// Deterministic: the same seeds give the same family every time, and
    /// two devices therefore agree about what her setting looks like. (The
    /// rule has a loop in it; this is the pin that says the loop settles.)
    @Test func theRuleIsDeterministic() {
        for (_, preset) in presets {
            for dark in [false, true] {
                #expect(PaletteDerivation.derive(preset, dark: dark)
                    == PaletteDerivation.derive(preset, dark: dark))
            }
        }
    }

    /// "No palette" is nil, and it is nil for exactly two reasons: the
    /// default, and a custom whose room seed is absent or not a colour.
    /// The resolver turns nil into the voice's own set byte-identically —
    /// the app is never left half-coloured.
    @Test func noPaletteIsNilForTheDefaultAndForASeedThatIsNotAColour() {
        #expect(PalettePreset.resolved(.default, tint: .none) == nil)
        #expect(PalettePreset.resolved(.custom, tint: .none) == nil)
        #expect(PalettePreset.resolved(.custom, tint: PaletteTint(room: "nope")) == nil)
        #expect(PalettePreset.resolved(.custom, tint: PaletteTint(room: "12345")) == nil)
        // An accent alone is not a palette — the ROOM is the seed.
        #expect(PalettePreset.resolved(.custom, tint: PaletteTint(accent: "D4A72C")) == nil)
        // A valid room with a garbage accent is a ONE-SEED custom, not a
        // refusal: the setter already refused the garbage, so anything that
        // reached the row here is treated as absent (the read-side rule).
        let oneSeed = PalettePreset.resolved(
            .custom, tint: PaletteTint(room: "B9A7E6", accent: "octarine"))
        #expect(oneSeed?.accentSeed == nil)
        #expect(oneSeed?.roomSeed == 0xB9A7E6)
    }

    /// **THE MOCKUP IS THE SHAPE.** Two cards she approved, reproduced
    /// BYTE-EXACT from their seed pairs alone — one from each intensity
    /// table. This is the evidence that the tables were fitted to the
    /// mockup rather than invented beside it.
    @Test func theTablesReproduceTheApprovedMockupsRoomAndWash() {
        let gold = PaletteDerivation.derive(PalettePreset.all[.goldAndBlack]!, dark: false)
        #expect(gold.room == 0xF8F6EF, "the mockup's gold & black room")
        #expect(gold.wash == 0xEEEAD8, "…and its wash")
        let cobalt = PaletteDerivation.derive(
            PalettePreset.all[.cobaltAndTangerine]!, dark: false)
        #expect(cobalt.room == 0xDBE6FA, "the mockup's cobalt & tangerine room")
        #expect(cobalt.wash == 0xBACDF3, "…and its wash")
    }

    /// **THE FINALS.** Every shipped palette's room, wash and accent, in
    /// both appearances — the table recorded in the batch record, so a
    /// change to a seed, a tone or the floor shows up here as an exact
    /// diff rather than as a colour nobody noticed moving.
    @Test func theShippedFamiliesAreTheRecordedOnes() {
        let expected: [(ThemePalette, Bool, UInt32, UInt32, UInt32)] = [
            // LIGHT
            (.lavender, false, 0xF1EDFA, 0xDCD3F3, 0x4E2D9F),
            (.mint, false, 0xEFF9F4, 0xD7EFE4, 0x2E7555),
            (.pink, false, 0xFAEDF2, 0xF3D3DE, 0xAD1F50),
            (.blue, false, 0xEDF3FA, 0xD3E1F3, 0x265DA6),
            (.goldAndBlack, false, 0xF8F6EF, 0xEEEAD8, 0x81661A),
            (.sageAndTerracotta, false, 0xF2F5F2, 0xDFE7DF, 0x9D4F2F),
            (.slateAndAmber, false, 0xF2F3F5, 0xDEE2E8, 0x845D17),
            (.plumAndCream, false, 0xF8F5EF, 0xEFE6D7, 0x8A4276),
            (.inkAndCoral, false, 0xF1F3F6, 0xDDE3E9, 0xAD381F),
            (.greyAndGreen, false, 0xF3F4F4, 0xE1E3E5, 0x257147),
            (.cobaltAndTangerine, false, 0xDBE6FA, 0xBACDF3, 0x933B08),
            (.peachAndIndigo, false, 0xFAE7DB, 0xF3D0BA, 0x3535A1),
            (.butterAndCobalt, false, 0xFAF4DB, 0xF3E7BA, 0x1C47BA),
            (.roseAndMoss, false, 0xFADBE1, 0xF3BAC5, 0x3C5D23),
            (.tealAndRust, false, 0xE1F4F2, 0xC3EAE6, 0xAE4028),
            // DARK (the room is black in every row — R51, pinned above too)
            (.lavender, true, 0x000000, 0x1D113C, 0x9A80DB),
            (.mint, true, 0x000000, 0x163728, 0x8AD1B0),
            (.pink, true, 0x000000, 0x3C1120, 0xE7749C),
            (.blue, true, 0x000000, 0x11233C, 0x7AA6E1),
            (.goldAndBlack, true, 0x000000, 0x363017, 0xE3C677),
            (.sageAndTerracotta, true, 0x000000, 0x212C20, 0xDA9B81),
            (.slateAndAmber, true, 0x000000, 0x20252D, 0xE7BD74),
            (.plumAndCream, true, 0x000000, 0x372B16, 0xCA91BA),
            (.inkAndCoral, true, 0x000000, 0x1E262F, 0xE78874),
            (.greyAndGreen, true, 0x000000, 0x242629, 0x84D6A9),
            (.cobaltAndTangerine, true, 0x000000, 0x0D224A, 0xF6945B),
            (.peachAndIndigo, true, 0x000000, 0x4A250D, 0x8E8EDA),
            (.butterAndCobalt, true, 0x000000, 0x4A3E0D, 0x8EA8EE),
            (.roseAndMoss, true, 0x000000, 0x4A0D19, 0xA3D081),
            (.tealAndRust, true, 0x000000, 0x16403C, 0xE08D7B),
        ]
        for (palette, dark, room, wash, accent) in expected {
            let family = PaletteDerivation.derive(PalettePreset.all[palette]!, dark: dark)
            let where_ = "\(palette.rawValue) \(dark ? "dark" : "light")"
            #expect(family.room == room,
                    "\(where_) room: #\(String(format: "%06X", family.room))")
            #expect(family.wash == wash,
                    "\(where_) wash: #\(String(format: "%06X", family.wash))")
            #expect(family.accent == accent,
                    "\(where_) accent: #\(String(format: "%06X", family.accent))")
        }
    }

    /// The FACE's grouping covers every palette exactly once — her three
    /// batches plus the two that are not builds. A sixteenth preset added
    /// to the enum without a home in the strip would be invisible in
    /// Settings; this is what says so.
    @Test func theSwatchStripShowsEveryPaletteExactlyOnce() {
        let shown = PaletteCopy.Group.allCases.flatMap(\.palettes)
        #expect(Set(shown) == Set(ThemePalette.allCases))
        #expect(shown.count == ThemePalette.allCases.count, "no palette in two groups")
        #expect(PaletteCopy.Group.pastels.palettes.count == 4)
        #expect(PaletteCopy.Group.twoTone.palettes.count == 6)
        #expect(PaletteCopy.Group.bold.palettes.count == 5)
        // Every one has words of its own — no raw enum name reaches her.
        for palette in ThemePalette.allCases {
            let label = PaletteCopy.label(palette)
            #expect(!label.isEmpty)
            #expect(label != palette.rawValue || palette == .custom || palette == .default,
                    "a build's label is app words, not its stored token")
        }
    }

    /// **The dirty-field rule** (18g ladder R1-2): what the row consults
    /// when she leaves a hex field — a dirty field commits on the way out,
    /// a clean one only takes the canonical form. Pinned here as the pure
    /// rule it is; the discard it ends is a mounted-pane behaviour the walk
    /// verifies (no suite mounts the Appearance pane).
    @Test func aSeedFieldIsDirtyOnlyWhenItSaysSomethingTheLandedValueDoesNot() {
        // Clean: the stored form, any spelling of it, and empty over nothing.
        #expect(!PaletteSeedField.isDirty("E07A5F", landed: "E07A5F"))
        #expect(!PaletteSeedField.isDirty("#e07a5f", landed: "E07A5F"))
        #expect(!PaletteSeedField.isDirty("  e07a5f\n", landed: "E07A5F"))
        #expect(!PaletteSeedField.isDirty("", landed: nil))
        #expect(!PaletteSeedField.isDirty("   ", landed: nil))
        // Dirty: a new colour, a not-a-colour (it wants its refusal), and
        // an emptied field over a landed colour (it wants to clear).
        #expect(PaletteSeedField.isDirty("3D5A80", landed: "E07A5F"))
        #expect(PaletteSeedField.isDirty("e07a5f", landed: nil))
        #expect(PaletteSeedField.isDirty("nope", landed: nil))
        #expect(PaletteSeedField.isDirty("nope", landed: "E07A5F"))
        #expect(PaletteSeedField.isDirty("", landed: "E07A5F"))
    }

    /// The seed refusal speaks app words and shows back what she typed —
    /// never the raw enum dump (the `invalidExtent` belt's class).
    @Test func aSeedThatIsNotAColourRefusesInWords() {
        let copy = OpsRefusalCopy.message(for: OperationError.invalidTint(value: "octarine"))
        #expect(!copy.contains("invalidTint"))
        #expect(!copy.hasPrefix("Refused:"))
        #expect(copy.contains("octarine"), "it shows back what she typed")
        #expect(copy.contains("six hex digits"))
    }

    /// The arithmetic itself, so the two pieces the rule rests on are
    /// checkable without a palette: WCAG's own worst and best pairs, and
    /// an HSL round trip.
    @Test func theColourArithmeticIsTheOneEverybodyElseUses() {
        #expect(abs(PaletteDerivation.contrast(0x000000, 0xFFFFFF) - 21) < 0.01)
        #expect(abs(PaletteDerivation.contrast(0x808080, 0x808080) - 1) < 0.01)
        // A known WCAG pair: #767676 on white is exactly AA (4.54:1).
        #expect(abs(PaletteDerivation.contrast(0x767676, 0xFFFFFF) - 4.54) < 0.02)
        for value: UInt32 in [0xB9A7E6, 0x2F7D5F, 0x000000, 0xFFFFFF, 0x123456] {
            let hsl = HSL(value)
            #expect(hsl.at(lightness: hsl.lightness, saturationCap: 1) == value,
                    "HSL round trip for #\(String(format: "%06X", value))")
        }
    }
}
