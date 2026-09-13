//
//  PaletteDerivation.swift
//  Variorum (Shared — both platforms' token layer)
//
//  18g, the 2026-09-12 use-report round — her rulings R-Q6 · R-Q11 · R-Q13.
//  ONE pure rule that turns one or two SEED hues into the family of colours
//  a palette replaces under a voice, and the fifteen named seed pairs the
//  round ships. `VoiceTokens` keeps its four static sets byte-identical and
//  gains parameters; this file is the only place a palette's colours are
//  computed, and it holds no view, no store and no per-preset special case.
//
//  Where the numbers came from: the sitting's mockup
//  (`notes/plans/use-report-2026-09-12-mockups/palettes.html`), read as HSL.
//  Every two-tone and bold card's room, wash and accent is reproduced
//  BYTE-EXACT by the tables below from its seed pair alone — which is what
//  proved the mockup really was one rule with two intensity levels rather
//  than 32 hand-picked cards. (The four PASTEL cards were drawn a hair
//  lighter than the two-tone ones — room L .965 vs .955, accent L .420 vs
//  .400; they collapse into the soft table here, a difference of 2–3 values
//  out of 255. The batch record says so.)
//

import Foundation
import VariorumCore

// MARK: - What a palette replaces

/// The colours a palette computes. Everything NOT here stays the voice's:
/// its type, its idioms, `ink`/`muted`/`faint`, `chosen`, `ring`, `star`,
/// `alarm`, `positive`, the comment pair, the code chip and the block seam.
/// Her ruling names the room, the wash, the accent, the take tints and the
/// hairline; `surface`/`card` join them in DARK ONLY, where the room is
/// black (R51) and the paper must carry the hue instead.
///
/// Values are 24-bit sRGB, not `Color`, so the whole rule is pure
/// arithmetic a unit pin can measure — the contrast floor below is computed
/// from these numbers, not eyeballed from a screenshot.
nonisolated struct PaletteFamily: Equatable, Sendable {
    let room: UInt32
    /// Dark only. Nil in light: the voice keeps its own paper, which is
    /// what the mockup shows (every light card's page stays the voice's).
    let surface: UInt32?
    /// Dark only, for the same reason — elevated cards sit on the paper.
    let card: UInt32?
    let wash: UInt32
    let accent: UInt32
    let takeTint: UInt32
    let takeLine: UInt32
    let line: UInt32
}

// MARK: - The two intensity tables

/// How deep a palette sits. TWO levels, because that is what her three
/// batches are: the pastels and the two-tone builds share one (soft), and
/// the bold builds — *"the color themes don't also have to be so pastel,
/// you can add a little more personality to them"* — share the other.
nonisolated enum PaletteIntensity: Sendable {
    case soft
    case bold

    var tones: PaletteTones { self == .soft ? .soft : .bold }
}

/// One token's recipe: the lightness it takes in each appearance, and the
/// ceiling on how saturated it may be. The HUE is always the seed's — a
/// palette never changes what colour something is, only how deep.
///
/// The saturation ceiling is what keeps a screaming seed from producing a
/// screaming room: `#FF0000` and `#B9A7E6` land on rooms of the same
/// gentleness, in their own hues.
nonisolated struct PaletteTone: Sendable {
    /// Nil means "this token does not exist in light" (surface, card).
    let light: Double?
    let dark: Double
    let saturation: Double
}

nonisolated struct PaletteTones: Sendable {
    let room: PaletteTone
    let surface: PaletteTone
    let card: PaletteTone
    let wash: PaletteTone
    let accent: PaletteTone
    let takeTint: PaletteTone
    let takeLine: PaletteTone
    let line: PaletteTone

    /// The pastels and the two-tone builds. Fitted to the mockup's
    /// two-tone cards, which it reproduces exactly.
    ///
    /// **R51 falls out of the table, it is not special-cased:** the room's
    /// dark lightness is 0, and any hue at lightness 0 is black. A palette
    /// therefore cannot accidentally tint the dark room.
    static let soft = PaletteTones(
        room: PaletteTone(light: 0.955, dark: 0.000, saturation: 0.55),
        surface: PaletteTone(light: nil, dark: 0.070, saturation: 0.32),
        card: PaletteTone(light: nil, dark: 0.105, saturation: 0.32),
        wash: PaletteTone(light: 0.890, dark: 0.150, saturation: 0.56),
        accent: PaletteTone(light: 0.400, dark: 0.680, saturation: 0.70),
        takeTint: PaletteTone(light: 0.949, dark: 0.060, saturation: 0.48),
        takeLine: PaletteTone(light: 0.840, dark: 0.190, saturation: 0.45),
        line: PaletteTone(light: 0.880, dark: 0.145, saturation: 0.35))

    /// The bold builds: a room tinted deeper and an accent allowed to be
    /// far more saturated. Fitted to the mockup's third batch, which it
    /// reproduces exactly.
    static let bold = PaletteTones(
        room: PaletteTone(light: 0.920, dark: 0.000, saturation: 0.75),
        surface: PaletteTone(light: nil, dark: 0.080, saturation: 0.42),
        card: PaletteTone(light: nil, dark: 0.115, saturation: 0.42),
        wash: PaletteTone(light: 0.841, dark: 0.170, saturation: 0.70),
        accent: PaletteTone(light: 0.420, dark: 0.660, saturation: 0.90),
        takeTint: PaletteTone(light: 0.929, dark: 0.070, saturation: 0.60),
        takeLine: PaletteTone(light: 0.780, dark: 0.200, saturation: 0.55),
        line: PaletteTone(light: 0.841, dark: 0.155, saturation: 0.50))
}

// MARK: - A preset, and the fifteen the round ships

/// A palette's data: one or two seeds and how deep they sit. A preset is
/// EXACTLY this — which is why her *"names and seeds hers to change later"*
/// (R-Q13) costs one constant edit and nothing else.
nonisolated struct PalettePreset: Equatable, Sendable {
    let roomSeed: UInt32
    /// Nil = the pastel case: the accent is the ROOM's hue, deepened. Her
    /// R-Q13: *"With one hex it does exactly what the pastels do."*
    let accentSeed: UInt32?
    let intensity: PaletteIntensity

    init(room: UInt32, accent: UInt32? = nil, intensity: PaletteIntensity) {
        self.roomSeed = room
        self.accentSeed = accent
        self.intensity = intensity
    }
}

extension PalettePreset {
    /// **The fifteen named seed pairs** (her R-Q11 · R-Q13; the seeds are
    /// the mockup's, which she approved — *"nice I like it, we'll start
    /// with that and I'll change them later if I feel like it"*).
    ///
    /// `.default` and `.custom` are deliberately absent: the first means
    /// "no palette" and the second reads her own hex.
    static let all: [ThemePalette: PalettePreset] = [
        // The four pastels — ONE seed each.
        .lavender: PalettePreset(room: 0xB9A7E6, intensity: .soft),
        .mint: PalettePreset(room: 0x9ED9BE, intensity: .soft),
        .pink: PalettePreset(room: 0xF2B3C9, intensity: .soft),
        .blue: PalettePreset(room: 0xA7C4EB, intensity: .soft),
        // The six two-tone builds — a room hue and an accent hue.
        .goldAndBlack: PalettePreset(room: 0x8A7A3A, accent: 0xD4A72C, intensity: .soft),
        .sageAndTerracotta: PalettePreset(room: 0x9BB59A, accent: 0xC4623A, intensity: .soft),
        .slateAndAmber: PalettePreset(room: 0x7F8EA3, accent: 0xE0A030, intensity: .soft),
        .plumAndCream: PalettePreset(room: 0xE9DDC8, accent: 0x7A3B69, intensity: .soft),
        .inkAndCoral: PalettePreset(room: 0x8FA3B8, accent: 0xE8735A, intensity: .soft),
        .greyAndGreen: PalettePreset(room: 0x9AA0A6, accent: 0x2E8B57, intensity: .soft),
        // The five bold builds — the same rule, deeper.
        .cobaltAndTangerine: PalettePreset(room: 0x5B8DEF, accent: 0xF26B1D, intensity: .bold),
        .peachAndIndigo: PalettePreset(room: 0xF5B48A, accent: 0x3F3FBF, intensity: .bold),
        .butterAndCobalt: PalettePreset(room: 0xF2D45C, accent: 0x1F4FCF, intensity: .bold),
        .roseAndMoss: PalettePreset(room: 0xF08CA0, accent: 0x4F7A2E, intensity: .bold),
        .tealAndRust: PalettePreset(room: 0x3FB5A8, accent: 0xB5432A, intensity: .bold),
    ]

    /// The preset a stored setting names, or **nil for "no palette"** —
    /// which is `.default`, and also a `custom` whose room seed is absent
    /// or not a colour. Nil is what makes the fallback honest: the resolver
    /// hands back the voice's own set byte-identically rather than guessing
    /// at half a palette.
    static func resolved(_ palette: ThemePalette, tint: PaletteTint) -> PalettePreset? {
        switch palette {
        case .default:
            return nil
        case .custom:
            guard let room = ThemeTint.value(tint.room) else { return nil }
            return PalettePreset(
                room: room, accent: ThemeTint.value(tint.accent), intensity: .soft)
        default:
            return all[palette]
        }
    }
}

/// The `custom` palette's two seeds as they are stored — six hex digits
/// each, already validated by core's ONE rule (`ThemeTint`) on the way out
/// of the database. A second seed is optional: absent means derived.
nonisolated struct PaletteTint: Equatable, Sendable {
    var room: String?
    var accent: String?

    init(room: String? = nil, accent: String? = nil) {
        self.room = room
        self.accent = accent
    }

    static let none = PaletteTint()

    /// **The ONE mapping from the landed settings to the custom seeds**
    /// (18g ladder, R1-1). Every host that holds a `Queries.ThemeSettings`
    /// and needs tokens goes through this — the store, the Settings
    /// pane's swatches, the AppKit surfaces' chrome and decor appearance —
    /// so the pair can never be spelled twice. Shared, so the phone's
    /// palette road (a synced palette beside its LOCAL voice) reads the
    /// seeds through the same line and calls the four-parameter resolver.
    init(_ settings: Queries.ThemeSettings) {
        self.init(room: settings.customRoom, accent: settings.customAccent)
    }
}

// MARK: - The rule

nonisolated enum PaletteDerivation {
    /// **The contrast floor — WCAG AA for body text.** Her R-Q13 asks for
    /// an accent *"deep and saturated enough to read as ink on the room"*;
    /// this is that sentence as a number, and the pins compute it.
    static let contrastFloor = 4.5

    /// Seeds → the family, for one appearance.
    ///
    /// ── THE RULE, IN ONE PARAGRAPH ──────────────────────────────────────
    ///
    /// Every token keeps the seed's HUE and its saturation (capped by the
    /// intensity table) and takes the table's LIGHTNESS for this
    /// appearance. The accent uses the accent seed's hue where there is one
    /// and the room's where there is not. Then one correction, and only
    /// one: **the accent is moved further from the backdrop until it clears
    /// the contrast floor** — darker in light, lighter in dark.
    ///
    /// ── WHY THAT CORRECTION EXISTS ──────────────────────────────────────
    ///
    /// HSL lightness is not luminance. A gold at lightness .40 is nearly
    /// twice as bright as a blue at .40, so a fixed number makes some
    /// accents read as ink and others as a smudge: measured against the
    /// mockup's own cards, six of the fifteen (mint, gold & black, slate &
    /// amber, grey & green, cobalt & tangerine, rose & moss) came out
    /// between 2.6:1 and 3.5:1 — below AA — while the other nine sat
    /// comfortably above 5:1. Lowering the table's number for everyone
    /// would have darkened the nine that were right. Correcting per colour
    /// is one rule, no per-preset constants, and — the part that actually
    /// matters — it is what makes **her own hex** safe: any seed she types,
    /// including `#FFFF00`, produces an accent that reads.
    ///
    /// The backdrop checked is BOTH the room and the wash, because the
    /// accent is chrome ink on the room ("this note", "commit ⌘S") and
    /// selected-row ink on the wash. In light the wash is the harder of
    /// the two; in dark it is the wash again, the room being black.
    static func derive(_ preset: PalettePreset, dark: Bool) -> PaletteFamily {
        let tones = preset.intensity.tones
        let room = HSL(preset.roomSeed)
        let accentHue = HSL(preset.accentSeed ?? preset.roomSeed)

        func tinted(_ tone: PaletteTone, _ base: HSL) -> UInt32? {
            guard let lightness = dark ? tone.dark : tone.light else { return nil }
            return base.at(lightness: lightness, saturationCap: tone.saturation)
        }

        // The two backdrops the accent has to read on. Both exist in both
        // appearances, so the correction below always has something to
        // measure against.
        let roomValue = tinted(tones.room, room) ?? 0
        let washValue = tinted(tones.wash, room) ?? 0

        return PaletteFamily(
            room: roomValue,
            surface: tinted(tones.surface, room),
            card: tinted(tones.card, room),
            wash: washValue,
            accent: readableAccent(
                accentHue, tone: tones.accent, dark: dark,
                against: [roomValue, washValue]),
            takeTint: tinted(tones.takeTint, room) ?? roomValue,
            takeLine: tinted(tones.takeLine, room) ?? roomValue,
            line: tinted(tones.line, room) ?? roomValue)
    }

    /// The correction above, as code: start at the table's lightness and
    /// step away from the backdrops until the floor is cleared. Bounded at
    /// both ends so an impossible seed settles on near-black or near-white
    /// rather than looping; deterministic, so two devices agree.
    private static func readableAccent(
        _ base: HSL, tone: PaletteTone, dark: Bool, against backdrops: [UInt32]
    ) -> UInt32 {
        let step = dark ? 0.005 : -0.005
        var lightness = dark ? tone.dark : (tone.light ?? tone.dark)
        var candidate = base.at(lightness: lightness, saturationCap: tone.saturation)
        for _ in 0..<200 {
            let worst = backdrops.map { contrast(candidate, $0) }.min() ?? 0
            if worst >= contrastFloor { return candidate }
            lightness += step
            if lightness <= 0.06 || lightness >= 0.94 {
                return base.at(
                    lightness: min(max(lightness, 0.06), 0.94),
                    saturationCap: tone.saturation)
            }
            candidate = base.at(lightness: lightness, saturationCap: tone.saturation)
        }
        return candidate
    }

    // MARK: Colour arithmetic (WCAG + HSL), the only maths in the layer

    /// The WCAG 2 contrast ratio between two opaque sRGB colours, 1…21.
    /// Public to the module so the pins measure the SAME function the rule
    /// does — a second copy in a test would pin a different promise.
    static func contrast(_ a: UInt32, _ b: UInt32) -> Double {
        let (first, second) = (relativeLuminance(a), relativeLuminance(b))
        let hi = max(first, second), lo = min(first, second)
        return (hi + 0.05) / (lo + 0.05)
    }

    static func relativeLuminance(_ value: UInt32) -> Double {
        func channel(_ shift: UInt32) -> Double {
            let raw = Double((value >> shift) & 0xFF) / 255
            return raw <= 0.03928 ? raw / 12.92 : pow((raw + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(16) + 0.7152 * channel(8) + 0.0722 * channel(0)
    }
}

/// A seed in hue/saturation/lightness — the space the tables are written
/// in, because "the same colour, deeper" is one number there and three
/// here otherwise.
nonisolated struct HSL: Equatable, Sendable {
    var hue: Double
    var saturation: Double
    var lightness: Double

    init(_ value: UInt32) {
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        let high = max(red, green, blue), low = min(red, green, blue)
        lightness = (high + low) / 2
        let span = high - low
        guard span > 0 else {
            hue = 0
            saturation = 0
            return
        }
        saturation = span / (1 - abs(2 * lightness - 1))
        switch high {
        case red: hue = (green - blue) / span + (green < blue ? 6 : 0)
        case green: hue = (blue - red) / span + 2
        default: hue = (red - green) / span + 4
        }
        hue /= 6
    }

    /// This hue at a given lightness, its saturation held under a ceiling.
    func at(lightness target: Double, saturationCap: Double) -> UInt32 {
        let sat = min(saturation, saturationCap)
        let chroma = (1 - abs(2 * target - 1)) * sat
        let secondary = chroma * (1 - abs((hue * 6).truncatingRemainder(dividingBy: 2) - 1))
        let base = target - chroma / 2
        let (red, green, blue): (Double, Double, Double)
        switch Int(hue * 6) % 6 {
        case 0: (red, green, blue) = (chroma, secondary, 0)
        case 1: (red, green, blue) = (secondary, chroma, 0)
        case 2: (red, green, blue) = (0, chroma, secondary)
        case 3: (red, green, blue) = (0, secondary, chroma)
        case 4: (red, green, blue) = (secondary, 0, chroma)
        default: (red, green, blue) = (chroma, 0, secondary)
        }
        func byte(_ component: Double) -> UInt32 {
            UInt32(min(max((component + base) * 255, 0), 255).rounded())
        }
        return (byte(red) << 16) | (byte(green) << 8) | byte(blue)
    }
}
