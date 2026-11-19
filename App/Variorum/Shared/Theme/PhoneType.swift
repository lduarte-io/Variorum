//
//  PhoneType.swift
//  Variorum (Shared — the phone's type layer over the shared tokens)
//
//  VM-48 (the VM-47 run, batch 1) — her direction: "just use the mac app as
//  your visual direction. the study mode especially" — the Mac's look at
//  phone-right sizes, "aside from how everything is weirdly small and
//  spaced". The numbers are the sizing sheet's role table
//  (`notes/plans/vm-44/design/sketches/sizing-sheet.html`, "How it is
//  expressed: a phone layer over the shared tokens"), built as drawn and
//  PROVISIONAL as a set (P-47-1).
//
//  WHAT THIS IS: one table of twelve ROLES — what a piece of text IS on the
//  phone (her words in a note, a row's title, a stamp, a control's label) —
//  resolved from the voice (which face) and the text-size setting (how big).
//  The phone reads a role; it never reads `VoiceTokens.small/body/title/
//  heading/mono` again, so the Mac's six type slots and its token pins stay
//  byte-identical (`VoiceTokens.swift` is not edited by this layer).
//
//  TWO SCALING CLASSES (the sheet's rule): her words (note body, titles, row
//  titles, previews, the twelve words) scale across the whole Dynamic Type
//  range, accessibility sizes included; chrome (meta, section headers,
//  chips, controls, tabs) scales up to xxxLarge and HOLDS there, the way the
//  system's own bars behave. Nothing on the phone is set below 13 pt.
//
//  THE TERMINAL VOICE takes the same roles in SF Mono, its prose roles two
//  points under Study's as on the Mac (15 · 22 · 18 for body, note title,
//  screen title) — the "two under" applied to the line pitch as well, so a
//  Terminal line keeps Study's leading (PROVISIONAL, §5 of the run record).
//
//  The pure table is platform-neutral (the Mac compiles it and never reads
//  it); the scaling and the UIKit forms sit behind `os(iOS)`, the folder's
//  own platform check (`SharedPageStyle`).
//

import SwiftUI
import VariorumCore
#if os(iOS)
import UIKit
#endif

// MARK: - The roles

/// What a piece of text IS on the phone. The sheet's "Replaces today's"
/// column and its role descriptions decide which one a site takes.
nonisolated enum PhoneTypeRole: String, CaseIterable, Sendable {
    /// The prose she writes: Write, take cards, the peek, the quick-entry box.
    case noteBody
    /// The masthead of a note; a root screen's title.
    case noteTitle
    /// A sheet's or a pushed screen's title (Blocks, Tags, Versions, Trash…).
    case screenTitle
    /// A note or a book in any list; a tag.
    case rowTitle
    /// Her words under a row title; a block's words in the block list.
    case rowPreview
    /// Dates, counts, "in Essays", paths, explainer sentences.
    case meta
    /// "Add to a book", "Apply a tag", "Commits".
    case sectionHeader
    /// The note's facts (book, tags, date); filters; the today badge.
    case chip
    /// An act inside a row (Edit, Delete beside a comment).
    case controlInline
    /// Every text button: Done, Put back, Restore, + Add a link.
    case control
    /// The root bar's words.
    case tab
    /// The twelve words she must copy exactly.
    case mono

    /// Her words scale across the whole range; chrome holds at xxxLarge.
    var scaling: PhoneTypeSpec.Scaling {
        switch self {
        case .noteBody, .noteTitle, .screenTitle, .rowTitle, .rowPreview, .mono:
            return .fullRange
        case .meta, .sectionHeader, .chip, .controlInline, .control, .tab:
            return .holdsAtXXXLarge
        }
    }
}

/// One role's numbers in one voice.
nonisolated struct PhoneTypeSpec: Equatable, Sendable {
    /// Which of the voice's families the role draws from.
    enum Family: Equatable, Sendable {
        /// Her words' face: Iowan Old Style in Study, SF Mono in Terminal.
        case prose
        /// The chrome face: SF Pro in Study, SF Mono in Terminal.
        case chrome
        /// SF Mono in both voices.
        case mono
    }

    enum Weight: Equatable, Sendable {
        case regular, medium, semibold
    }

    /// The system text style a role's size follows when the text size
    /// changes. The phone's own names, so the table stays platform-neutral;
    /// `os(iOS)` maps them below.
    enum Anchor: Equatable, Sendable {
        case body, title2, title3, headline, subheadline, footnote
    }

    enum Scaling: Equatable, Sendable {
        /// Scales with every text size, accessibility sizes included.
        case fullRange
        /// Scales up to xxxLarge, then holds.
        case holdsAtXXXLarge
    }

    let family: Family
    let weight: Weight
    /// The point size at the default text size (Large).
    let size: CGFloat
    /// The line pitch at the default text size — the distance from one
    /// line's baseline to the next.
    let lineHeight: CGFloat
    let anchor: Anchor
    let scaling: Scaling
}

// MARK: - The table

nonisolated enum PhoneType {
    /// The floor: nothing on the phone is set below this (VM-48, the sheet's
    /// "Nothing is set below 13").
    static let floorSize: CGFloat = 13

    /// The Study voice's prose face — the same family name `VoiceTokens`
    /// gives SwiftUI on both platforms.
    static let studyProseFamily = "Iowan Old Style"

    /// **The table — Study's numbers are the sheet's, as drawn.**
    static func spec(_ role: PhoneTypeRole, voice: ThemeVoice) -> PhoneTypeSpec {
        let study = studySpec(role)
        guard voice == .terminal else { return study }
        // Terminal: every role in SF Mono; the prose roles two points under
        // Study's, size and pitch alike (the Mac's own rule for its prose).
        let isProse = study.family == .prose
        return PhoneTypeSpec(
            family: .mono,
            weight: study.weight,
            size: isProse ? study.size - 2 : study.size,
            lineHeight: isProse ? study.lineHeight - 2 : study.lineHeight,
            anchor: study.anchor,
            scaling: study.scaling)
    }

    private static func studySpec(_ role: PhoneTypeRole) -> PhoneTypeSpec {
        switch role {
        case .noteBody:
            return PhoneTypeSpec(family: .prose, weight: .regular, size: 17, lineHeight: 27,
                                 anchor: .body, scaling: role.scaling)
        case .noteTitle:
            return PhoneTypeSpec(family: .prose, weight: .semibold, size: 24, lineHeight: 30,
                                 anchor: .title2, scaling: role.scaling)
        case .screenTitle:
            return PhoneTypeSpec(family: .prose, weight: .semibold, size: 20, lineHeight: 25,
                                 anchor: .title3, scaling: role.scaling)
        case .rowTitle:
            return PhoneTypeSpec(family: .prose, weight: .semibold, size: 17, lineHeight: 22,
                                 anchor: .headline, scaling: role.scaling)
        case .rowPreview:
            return PhoneTypeSpec(family: .prose, weight: .regular, size: 15, lineHeight: 20,
                                 anchor: .subheadline, scaling: role.scaling)
        case .meta:
            return PhoneTypeSpec(family: .chrome, weight: .regular, size: 13, lineHeight: 18,
                                 anchor: .footnote, scaling: role.scaling)
        case .sectionHeader:
            return PhoneTypeSpec(family: .chrome, weight: .semibold, size: 13, lineHeight: 18,
                                 anchor: .footnote, scaling: role.scaling)
        case .chip:
            return PhoneTypeSpec(family: .chrome, weight: .medium, size: 15, lineHeight: 20,
                                 anchor: .subheadline, scaling: role.scaling)
        case .controlInline:
            return PhoneTypeSpec(family: .chrome, weight: .regular, size: 15, lineHeight: 20,
                                 anchor: .subheadline, scaling: role.scaling)
        case .control:
            return PhoneTypeSpec(family: .chrome, weight: .regular, size: 17, lineHeight: 22,
                                 anchor: .body, scaling: role.scaling)
        case .tab:
            return PhoneTypeSpec(family: .chrome, weight: .regular, size: 17, lineHeight: 22,
                                 anchor: .body, scaling: role.scaling)
        case .mono:
            return PhoneTypeSpec(family: .mono, weight: .regular, size: 17, lineHeight: 26,
                                 anchor: .body, scaling: role.scaling)
        }
    }

    // MARK: The reading page (the sheet's "Reading page" row)

    /// A book's Read page: a serif page that is voice-INDEPENDENT (R2), so
    /// its three faces are not roles of the voice. "Serif 17 · line 27;
    /// titles keep 25 and 21 and gain Dynamic Type; page meta 13" (the page
    /// meta reads the `meta` role). All three scale across the whole range.
    enum ReadingFace: CaseIterable, Sendable {
        case body, bookTitle, noteTitle

        var size: CGFloat {
            switch self {
            case .body: 17
            case .bookTitle: 25
            case .noteTitle: 21
            }
        }

        var weight: PhoneTypeSpec.Weight { self == .body ? .regular : .semibold }

        var anchor: PhoneTypeSpec.Anchor {
            switch self {
            case .body: .body
            case .bookTitle: .title2
            case .noteTitle: .title3
            }
        }
    }

    /// The reading page's line pitch at the default size.
    static let readingBodyLineHeight: CGFloat = 27

    // MARK: SwiftUI fonts at a resolved size (platform-neutral)

    /// The role's SwiftUI font at an already-resolved point size. Fixed at
    /// that size: the SCALING is the modifier's (`phoneType(_:_:)`), which
    /// resolves the size from the environment's text size and the role's
    /// class, so a chrome role can hold at xxxLarge — something a `Font`
    /// value cannot express on its own.
    static func font(_ spec: PhoneTypeSpec, voice: ThemeVoice, pointSize: CGFloat) -> Font {
        switch spec.family {
        case .prose where voice == .study:
            return Font.custom(studyProseFamily, fixedSize: pointSize).weight(spec.weight.swiftUI)
        case .chrome where voice == .study:
            return .system(size: pointSize, weight: spec.weight.swiftUI)
        default:
            return .system(size: pointSize, weight: spec.weight.swiftUI, design: .monospaced)
        }
    }
}

extension PhoneTypeSpec.Weight {
    nonisolated var swiftUI: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        }
    }
}

// MARK: - The phone's scaling and its two forms (iOS)

#if os(iOS)
extension PhoneTypeSpec.Weight {
    nonisolated var uiKit: UIFont.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        }
    }
}

extension PhoneTypeSpec.Anchor {
    nonisolated var textStyle: UIFont.TextStyle {
        switch self {
        case .body: .body
        case .title2: .title2
        case .title3: .title3
        case .headline: .headline
        case .subheadline: .subheadline
        case .footnote: .footnote
        }
    }
}

extension PhoneType {
    /// The text-size setting the chrome class holds at.
    static let chromeHold = UIContentSizeCategory.extraExtraExtraLarge

    /// **The scaling rule, as one function** — the role's point size at a
    /// text-size setting. Her words follow their anchor across the whole
    /// range; chrome follows it up to xxxLarge and then holds. At the
    /// default setting (Large) every role is exactly its table size.
    static func pointSize(
        _ spec: PhoneTypeSpec, at category: UIContentSizeCategory
    ) -> CGFloat {
        let metrics = UIFontMetrics(forTextStyle: spec.anchor.textStyle)
        func scaled(_ at: UIContentSizeCategory) -> CGFloat {
            metrics.scaledValue(
                for: spec.size,
                compatibleWith: UITraitCollection(preferredContentSizeCategory: at))
        }
        let size = scaled(category)
        switch spec.scaling {
        case .fullRange:
            return max(floorSize, size)
        case .holdsAtXXXLarge:
            return max(floorSize, min(size, scaled(chromeHold)))
        }
    }

    /// The role's UIKit font at a given size — the face's own family.
    static func baseUIFont(
        _ spec: PhoneTypeSpec, voice: ThemeVoice, pointSize: CGFloat
    ) -> UIFont {
        switch spec.family {
        case .prose where voice == .study:
            return studyProseUIFont(size: pointSize, weight: spec.weight)
        case .chrome where voice == .study:
            return .systemFont(ofSize: pointSize, weight: spec.weight.uiKit)
        default:
            return .monospacedSystemFont(ofSize: pointSize, weight: spec.weight.uiKit)
        }
    }

    /// Iowan Old Style by PostScript name (it ships on iOS as a hidden
    /// system font — `MobileVoiceTests` pins that), its Bold standing in for
    /// semibold (the family has no semibold; SwiftUI's `.weight(.semibold)`
    /// lands on the same face). The serif design is the never-reached net,
    /// the Mac resolver's exact posture (R49: nothing bundled).
    static func studyProseUIFont(size: CGFloat, weight: PhoneTypeSpec.Weight) -> UIFont {
        let name = weight == .regular ? "IowanOldStyle-Roman" : "IowanOldStyle-Bold"
        if let font = UIFont(name: name, size: size) { return font }
        let system = UIFont.systemFont(ofSize: size, weight: weight.uiKit)
        return UIFont(
            descriptor: system.fontDescriptor.withDesign(.serif) ?? system.fontDescriptor,
            size: size)
    }

    /// **The UIKit form.** A font that follows the text-size setting by the
    /// role's class: `UIFontMetrics` scaling, capped at the xxxLarge size for
    /// chrome. A label that sets `adjustsFontForContentSizeCategory` keeps it
    /// current as the setting changes; one that does not keeps the size it
    /// was made at.
    ///
    /// **The floor holds here too** (the midway review's M-1): below the
    /// default setting the anchors' curves take a role under 13 pt (Terminal
    /// `rowPreview` ≈ 10.4 at xSmall, `meta` 12.0 through xSmall–Medium), so
    /// a resolved font under `floorSize` — in either class — is replaced by
    /// the role's face at exactly 13, as the SwiftUI rule (`pointSize`)
    /// already does. That floored font is fixed at 13; the UIKit chrome
    /// re-resolves its fonts per layout or update and none of it sets
    /// `adjustsFontForContentSizeCategory`, so nothing that follows the
    /// setting today stops following it.
    static func uiFont(
        _ role: PhoneTypeRole, voice: ThemeVoice,
        compatibleWith traits: UITraitCollection? = nil
    ) -> UIFont {
        let spec = spec(role, voice: voice)
        let scaled = scaledUIFont(spec, voice: voice, compatibleWith: traits)
        guard scaled.pointSize < floorSize else { return scaled }
        return baseUIFont(spec, voice: voice, pointSize: floorSize)
    }

    /// The role's UIKit font by its class, before the floor.
    private static func scaledUIFont(
        _ spec: PhoneTypeSpec, voice: ThemeVoice, compatibleWith traits: UITraitCollection?
    ) -> UIFont {
        let base = baseUIFont(spec, voice: voice, pointSize: spec.size)
        let metrics = UIFontMetrics(forTextStyle: spec.anchor.textStyle)
        switch spec.scaling {
        case .fullRange:
            return metrics.scaledFont(for: base, compatibleWith: traits)
        case .holdsAtXXXLarge:
            // The cap is the size `scaledFont` ITSELF gives at xxxLarge, not
            // `scaledValue`'s: for the .footnote and .body anchors the two
            // differ by a third of a point, so a `scaledValue` cap let the
            // UIKit chrome keep growing that third past xxxLarge
            // (`chromeHoldsAtXXXLargeWhileHerWordsKeepGrowing`, red at the
            // batch-1 stage window).
            let hold = metrics.scaledFont(
                for: base,
                compatibleWith: UITraitCollection(preferredContentSizeCategory: chromeHold)
            ).pointSize
            return metrics.scaledFont(for: base, maximumPointSize: hold, compatibleWith: traits)
        }
    }

    /// The extra space between lines that gives the role its line pitch at
    /// a resolved size (the pitch scales with the size).
    static func lineSpacing(
        _ spec: PhoneTypeSpec, voice: ThemeVoice, pointSize: CGFloat
    ) -> CGFloat {
        let pitch = spec.lineHeight * pointSize / spec.size
        let natural = baseUIFont(spec, voice: voice, pointSize: pointSize).lineHeight
        return max(0, (pitch - natural).rounded())
    }

    /// One role resolved for SwiftUI at a text-size setting: its font and its
    /// line spacing. Cached per (role, voice, setting) — a view body asks
    /// often, and the answer never changes.
    struct Resolved: Equatable {
        let pointSize: CGFloat
        let font: Font
        let lineSpacing: CGFloat
    }

    @MainActor private static var cache: [String: Resolved] = [:]

    @MainActor
    static func resolved(
        _ role: PhoneTypeRole, voice: ThemeVoice, at category: UIContentSizeCategory
    ) -> Resolved {
        let key = "\(role.rawValue)·\(voice.rawValue)·\(category.rawValue)"
        if let hit = cache[key] { return hit }
        let spec = spec(role, voice: voice)
        let size = pointSize(spec, at: category)
        let resolved = Resolved(
            pointSize: size,
            font: font(spec, voice: voice, pointSize: size),
            lineSpacing: lineSpacing(spec, voice: voice, pointSize: size))
        cache[key] = resolved
        return resolved
    }
}

extension DynamicTypeSize {
    /// SwiftUI's setting as UIKit's category — written out rather than
    /// trusted to a bridging initialiser, so the mapping is on the page.
    nonisolated var phoneCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}

#endif

// MARK: - The SwiftUI form (both platforms compile it; only the phone renders it)

/// **The SwiftUI form**: the role's font at the environment's text size,
/// held at xxxLarge for chrome, with the role's line pitch. The shared pages'
/// phone arms (`SharedPageStyle`) read it too, so the Mac compiles it; the
/// Mac never renders a phone arm, and its arm resolves at the table size.
struct PhoneTypeModifier: ViewModifier {
    let role: PhoneTypeRole
    let voice: ThemeVoice
    /// A label that may shrink to fit (a row of doors) shrinks no further
    /// than the floor — never below 13 pt.
    var shrinksToFloor = false
    /// A site whose drawing names its own line pitch at the default size
    /// (the quick-entry box's 24 pt line — sheet §E) overrides the role's;
    /// it scales with the size like the role's own.
    var linePitch: CGFloat?
    /// A site whose drawing names its own weight for the role (the closing
    /// act's semibold Done — sheet §B, VM-50) overrides the role's weight;
    /// the size, family and scaling stay the role's.
    var weight: PhoneTypeSpec.Weight?
    @Environment(\.dynamicTypeSize) private var typeSize

    /// The role at this environment's text size: font, line spacing, size.
    private var face: (font: Font, lineSpacing: CGFloat, pointSize: CGFloat) {
        let base = rawFace
        guard let weight else { return base }
        let spec = PhoneType.spec(role, voice: voice)
        let reweighted = PhoneTypeSpec(
            family: spec.family, weight: weight, size: spec.size,
            lineHeight: spec.lineHeight, anchor: spec.anchor, scaling: spec.scaling)
        return (PhoneType.font(reweighted, voice: voice, pointSize: base.pointSize),
                base.lineSpacing, base.pointSize)
    }

    private var rawFace: (font: Font, lineSpacing: CGFloat, pointSize: CGFloat) {
        #if os(iOS)
        let resolved = PhoneType.resolved(role, voice: voice, at: typeSize.phoneCategory)
        if let linePitch {
            let spec = PhoneType.spec(role, voice: voice)
            let natural = PhoneType.baseUIFont(
                spec, voice: voice, pointSize: resolved.pointSize).lineHeight
            let pitch = linePitch * resolved.pointSize / spec.size
            return (resolved.font, max(0, (pitch - natural).rounded()), resolved.pointSize)
        }
        return (resolved.font, resolved.lineSpacing, resolved.pointSize)
        #else
        let spec = PhoneType.spec(role, voice: voice)
        return (PhoneType.font(spec, voice: voice, pointSize: spec.size), 0, spec.size)
        #endif
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        let face = face
        if shrinksToFloor {
            content
                .font(face.font)
                .lineSpacing(face.lineSpacing)
                .minimumScaleFactor(min(1, PhoneType.floorSize / face.pointSize))
        } else {
            content
                .font(face.font)
                .lineSpacing(face.lineSpacing)
        }
    }
}

extension View {
    /// The phone's type: one role, in the voice the tokens carry.
    func phoneType(_ role: PhoneTypeRole, _ tokens: VoiceTokens) -> some View {
        modifier(PhoneTypeModifier(role: role, voice: tokens.voice))
    }

    /// A role drawn on a line pitch of its site's own (at the default size).
    func phoneType(
        _ role: PhoneTypeRole, _ tokens: VoiceTokens, linePitch: CGFloat
    ) -> some View {
        modifier(PhoneTypeModifier(role: role, voice: tokens.voice, linePitch: linePitch))
    }

    /// A role whose label may shrink to fit its row — never below the floor.
    func phoneType(
        _ role: PhoneTypeRole, _ tokens: VoiceTokens, shrinkingToFloor: Bool
    ) -> some View {
        modifier(PhoneTypeModifier(
            role: role, voice: tokens.voice, shrinksToFloor: shrinkingToFloor))
    }

    /// A role at a weight of its site's own (the closing act's semibold —
    /// sheet §B); the size and scaling stay the role's.
    func phoneType(
        _ role: PhoneTypeRole, _ tokens: VoiceTokens, weight: PhoneTypeSpec.Weight
    ) -> some View {
        modifier(PhoneTypeModifier(role: role, voice: tokens.voice, weight: weight))
    }

    /// Both at once: a site's own weight, on a label that may shrink to fit —
    /// never below the floor (the bottom bar's words, VM-52: the current one
    /// semibold, and every one allowed to shrink only where its cell cannot
    /// hold it at its size).
    func phoneType(
        _ role: PhoneTypeRole, _ tokens: VoiceTokens,
        weight: PhoneTypeSpec.Weight, shrinkingToFloor: Bool
    ) -> some View {
        modifier(PhoneTypeModifier(
            role: role, voice: tokens.voice, shrinksToFloor: shrinkingToFloor, weight: weight))
    }
}

#if os(iOS)
extension View {
    /// A book's Read page face (voice-independent), scaling with every text
    /// size, with the page's line pitch on the body.
    func phoneReading(_ face: PhoneType.ReadingFace) -> some View {
        modifier(PhoneReadingModifier(
            size: face.size, weight: face.weight, anchor: face.anchor,
            pitch: face == .body ? PhoneType.readingBodyLineHeight : nil))
    }

    /// A Read page paragraph at its own size (a heading is the body scaled),
    /// following the body's text size; `pitch` is the line pitch at the
    /// default size, nil for the face's own line.
    func phoneReading(
        size: CGFloat, weight: PhoneTypeSpec.Weight, pitch: CGFloat?
    ) -> some View {
        modifier(PhoneReadingModifier(size: size, weight: weight, anchor: .body, pitch: pitch))
    }
}

struct PhoneReadingModifier: ViewModifier {
    let size: CGFloat
    let weight: PhoneTypeSpec.Weight
    let anchor: PhoneTypeSpec.Anchor
    /// The line pitch at the default size, or nil for the font's own line.
    let pitch: CGFloat?
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        let metrics = UIFontMetrics(forTextStyle: anchor.textStyle)
        let scaled = max(PhoneType.floorSize, metrics.scaledValue(
            for: size,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: typeSize.phoneCategory)))
        let font = Font.system(size: scaled, weight: weight.swiftUI, design: .serif)
        let system = UIFont.systemFont(ofSize: scaled, weight: weight.uiKit)
        let natural = UIFont(
            descriptor: system.fontDescriptor.withDesign(.serif) ?? system.fontDescriptor,
            size: scaled).lineHeight
        let line = pitch.map { $0 * scaled / size } ?? natural
        content
            .font(font)
            .lineSpacing(max(0, (line - natural).rounded()))
    }
}
#endif
