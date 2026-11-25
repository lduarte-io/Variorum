//
//  PhoneControls.swift
//  Variorum (Shared — the phone layer's one set of controls)
//
//  VM-50 (the VM-47 run, batch 2) — the ticket: "The phone has five
//  separately built 'calm buttons', three field builds, ten hand-rolled
//  sheet headers, and rows of plain words standing in for segmented choices;
//  the bare 11.5 pt text buttons are the tiny affordances she named. One
//  shared set of controls replaces them." And VM-49's application: every
//  control answers a touch across at least 44 × 44 pt (the drawn shape may be
//  smaller; the hit area may not).
//
//  THE NUMBERS are the sizing sheet's §B ("The touch rule") and §E ("The core
//  components"), on batch 1's layer — the type roles (`PhoneType`), the two
//  corrected inks (`PhoneInks`) and the metrics (`PhoneMetrics`) — PROVISIONAL
//  as a set (P-47-1), and since VM-273 (the VM-260 run, batch 2) STEPPED DOWN
//  inside the same targets: her "ridiculously oversized icons" were wave 1
//  drawing its controls at or near the size of their targets (a 22 pt glyph,
//  a 32 pt capsule, boxes the full 44). Now every drawing sits well inside
//  its target, the chrome words one notch under her words, the corners the
//  Mac's two (P-260-2a, PROVISIONAL as a set). EVERY TARGET IS AS IT WAS:
//
//  · text button — label `control` 15 in the accent, the closing act (Done)
//    semibold; 12 inside each side; at least 64 × 44.
//  · inline act — `controlInline` 13 inside a row; hit area 44 × 44 at least,
//    the word drawn at its own size.
//  · icon button — a 17 pt glyph in its tone (was 22 — P-47-12's road (b));
//    hit area 44 × 44; neighbours may touch (centres 44 apart).
//  · chip — `chip` 13 medium in the accent on the wash, a near-square 24 pt
//    shape (corner `Radius.small`, 8 to each side — it was a 32 pt capsule),
//    inside a 44 × 44 hit area.
//  · field — paper on the room, the palette's take line as its edge, corner
//    `Radius.standard`, 12 inside; its box drawn 36 (it was the full 44)
//    inside a frame at least 44 tall.
//  · calm button — THE one button with a shape: paper fill, take-line edge,
//    corner `Radius.standard`, 12 inside, label `control` 15; its box drawn
//    36 (it was the full 44) inside a target at least 64 × 44.
//  · sheet header — the title `screenTitle` 20 at the gutter, Done `control`
//    15 semibold in the accent with a 64 × 44 hit area 8 from the edge; the
//    header row at least 56.
//  · segmented choice — the SYSTEM control (`UISegmentedControl`), styled by
//    the layer: `chip` words, at least 44 tall (its track is the system's own
//    drawing — a remainder of the step-down, recorded in the run record).
//  · section header — `sectionHeader` 13 semibold in the corrected muted,
//    24 above and 8 below.
//  · menu row — at least 52 (64 with a detail line, 44 with neither a glyph
//    nor a detail — sheet §C's one-line menu row): an optional 17 pt glyph in
//    the accent, 12, the label `control` 15 in ink, the detail `meta` 13 in
//    the corrected muted; a removing act wears the alarm ink.
//
//  WHERE IT LIVES. `Shared/` because a shared page's phone arm
//  (`SharedPageStyle.PageDoor`) wears the calm button, and the Mac compiles
//  every file here — so the SwiftUI controls are platform-neutral (the Mac
//  compiles them and never renders one; its own pages keep their nil arms,
//  byte-identical), and the two UIKit pieces (the segmented choice and the
//  overlays' hit-area button) sit behind `os(iOS)`, the folder's own check.
//
//  ACCESSIBILITY. A control's label is the words it draws, exactly as the
//  site wrote them (a voiced chrome word stays voiced) — the styles wrap the
//  label and never re-label it, so every pin that drives a door by its label
//  keeps driving it. The segmented choice speaks each segment's PLAIN word
//  (the A3 rule: VoiceOver reads words, never a register).
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

// MARK: - Tones

/// Which ink an act wears. Words are found by their size, their accent and
/// their shape (sheet §D); a removing act is the one that differs.
enum PhoneActTone {
    /// The app's act colour — every text button, inline act and calm button.
    case accent
    /// A removing act (Delete, Empty Trash) — the voice's alarm.
    case alarm
    /// Her words' ink — a menu row's label, an icon's glyph.
    case ink
    /// A quiet act that must still read (the corrected muted ink).
    case muted

    func color(_ tokens: VoiceTokens) -> Color {
        switch self {
        case .accent: tokens.accent
        case .alarm: tokens.alarm
        case .ink: tokens.ink
        case .muted: tokens.phone.muted
        }
    }
}

// MARK: - The controls' own geometry (one place, so the pins read it)

nonisolated enum PhoneControlMetrics {
    /// A text button's minimum hit area: 64 wide, 44 tall (sheet §B).
    static let textButtonMinWidth: CGFloat = 64
    /// Padding inside a button or a field, each side (sheet §C: 12).
    static let insidePadding: CGFloat = PhoneMetrics.Space.s12
    /// The chip's drawn shape — 24 tall, near-square (VM-273: it was a 32 pt
    /// capsule), inside its 44 × 44 hit area.
    static let chipHeight: CGFloat = PhoneMetrics.Space.s24
    /// The chip's side padding — the scale's 8 (the Mac strip's chip is 9;
    /// it was 12).
    static let chipSidePadding: CGFloat = PhoneMetrics.Space.s8
    /// An icon button's glyph at the default text size — 17 (VM-273, P-47-12's
    /// road (b): it was 22, half its target).
    static let iconGlyph: CGFloat = 17
    /// **A box's drawn height** — the field's and the calm button's shape
    /// (VM-273): at least 36, growing with its words, inside a target at
    /// least 44 tall. It was the full 44, the target and the drawing one size.
    static let boxHeight: CGFloat = 36
    /// The sheet header's row (sheet §E: "header row 56").
    static let sheetHeaderHeight: CGFloat = 56
    /// Done sits 8 from the sheet's edge, so its word lines up at the gutter.
    static let sheetHeaderTrailing: CGFloat = PhoneMetrics.Space.s8
    /// A section header's air: 24 above, 8 below (sheet §E).
    static let sectionAbove: CGFloat = PhoneMetrics.Space.s24
    static let sectionBelow: CGFloat = PhoneMetrics.Space.s8
    /// A menu row's floors (sheet §E; §C's one-line menu row is 44).
    static let menuRowWithGlyph: CGFloat = PhoneMetrics.RowHeight.accessory
    static let menuRowWithDetail: CGFloat = PhoneMetrics.RowHeight.titleAndMeta
    static let menuRowPlain: CGFloat = PhoneMetrics.RowHeight.menu

    /// How a pressed control and a disabled one read (the shared pages'
    /// precedent, `PageDoorLabel`): `.plain`-class styles do not dim on their
    /// own.
    static func opacity(enabled: Bool, pressed: Bool) -> Double {
        enabled ? (pressed ? 0.55 : 1) : 0.35
    }
}

/// The press and disabled read every style shares — a View so `isEnabled` is
/// a live environment read.
private struct PhoneControlFeedback<Label: View>: View {
    let label: Label
    let pressed: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        label.opacity(PhoneControlMetrics.opacity(enabled: isEnabled, pressed: pressed))
    }
}

// MARK: - Text button

/// **The text button** — Done, Cancel, Put back, + new note: a word with no
/// shape, 15 pt in the accent (`control` — the sheet's 17, stepped down by
/// VM-273), answering across at least 64 × 44 (sheet §B: "hit area 44 tall,
/// at least 64 wide (12 padding each side inside the button)"). The closing
/// act (Done) is semibold.
struct PhoneTextButtonStyle: ButtonStyle {
    let tokens: VoiceTokens
    var tone: PhoneActTone = .accent
    /// The closing act — Done — reads semibold (sheet §B and §E).
    var closing = false

    func makeBody(configuration: Configuration) -> some View {
        PhoneControlFeedback(
            label: label(configuration.label),
            pressed: configuration.isPressed)
    }

    @ViewBuilder
    private func label(_ label: Configuration.Label) -> some View {
        Group {
            if closing {
                label.phoneType(.control, tokens, weight: .semibold)
            } else {
                label.phoneType(.control, tokens)
            }
        }
        .foregroundStyle(tone.color(tokens))
        .lineLimit(1)
        .padding(.horizontal, PhoneControlMetrics.insidePadding)
        .frame(
            minWidth: PhoneControlMetrics.textButtonMinWidth,
            minHeight: PhoneMetrics.touchMinimum)
        .contentShape(Rectangle())
    }
}

// MARK: - Inline act

/// **The inline act** — an act inside a row (Put back, Edit, Delete, Open
/// note): the word at 13 (`controlInline` — the sheet's "Inline acts inside a
/// row: 15", stepped down by VM-273), answering across at least 44 × 44
/// without moving the word — the batch-1 hit-area helper, so a row's acts
/// keep their places and their drawn sizes. `alignment` keeps a word on its row's edge when the word is
/// narrower than 44.
struct PhoneInlineActStyle: ButtonStyle {
    let tokens: VoiceTokens
    var tone: PhoneActTone = .accent
    var role: PhoneTypeRole = .controlInline
    var alignment: Alignment = .center
    /// A site's own weight for its word, the size and scaling staying the
    /// role's — the receipt line's act is the role's size SEMIBOLD (sheet §E; the one
    /// message line, VM-61, at the VM-55 re-land). nil keeps the role's.
    var weight: PhoneTypeSpec.Weight? = nil

    func makeBody(configuration: Configuration) -> some View {
        PhoneControlFeedback(
            label: word(configuration.label)
                .foregroundStyle(tone.color(tokens))
                .phoneHitArea(alignment: alignment),
            pressed: configuration.isPressed)
    }

    @ViewBuilder
    private func word(_ label: Configuration.Label) -> some View {
        if let weight {
            label.phoneType(role, tokens, weight: weight)
        } else {
            label.phoneType(role, tokens)
        }
    }
}

// MARK: - Icon button

/// **The icon button** — a 17 pt glyph in its tone, answering across 44 × 44
/// (sheet §B's touch rule: "hit area 44 × 44; neighbours may touch (centres
/// 44 apart)"; the glyph stepped down from the sheet's 22 — VM-273, P-47-12's
/// road (b)). The glyph is chrome: it follows the text size to xxxLarge and
/// holds.
struct PhoneIconButtonStyle: ButtonStyle {
    let tokens: VoiceTokens
    var tone: PhoneActTone = .ink

    func makeBody(configuration: Configuration) -> some View {
        PhoneControlFeedback(
            label: configuration.label
                .modifier(PhoneGlyphModifier(size: PhoneControlMetrics.iconGlyph))
                .foregroundStyle(tone.color(tokens))
                .phoneHitArea(),
            pressed: configuration.isPressed)
    }
}

/// A glyph at a chrome size: its point size follows the text size to
/// xxxLarge and holds there (the chrome class), anchored to `.body`.
struct PhoneGlyphModifier: ViewModifier {
    let size: CGFloat
    @Environment(\.dynamicTypeSize) private var typeSize

    func body(content: Content) -> some View {
        content.font(.system(size: PhoneControlGlyph.pointSize(size, at: typeSize)))
    }
}

enum PhoneControlGlyph {
    /// A glyph's size at a text size — the chrome class's rule (follows
    /// `.body` to xxxLarge, then holds; the Mac, which never renders a phone
    /// control, takes the size as drawn).
    static func pointSize(_ size: CGFloat, at typeSize: DynamicTypeSize) -> CGFloat {
        #if os(iOS)
        let spec = PhoneTypeSpec(
            family: .chrome, weight: .regular, size: size, lineHeight: size,
            anchor: .body, scaling: .holdsAtXXXLarge)
        return PhoneType.pointSize(spec, at: typeSize.phoneCategory)
        #else
        return size
        #endif
    }
}

// MARK: - Chip

/// **The chip** — a fact or a filter on a near-square 24 pt shape: `chip` 13
/// medium in the accent on the wash, 8 to each side, the Mac's chip corner
/// (`Radius.small`), inside a hit area at least 44 × 44 (VM-273: it was a
/// 32 pt capsule of 15 pt words with 12 to each side — the sheet's §B).
///
/// A FILTER chip says whether it is chosen (`selected` non-nil): the chosen
/// one on the wash in her ink, the others with no fill, the take line as
/// their edge, in the corrected muted — the same shape either way, so a row
/// of filters never moves when the choice does (PROVISIONAL P-47-11).
struct PhoneChipStyle: ButtonStyle {
    let tokens: VoiceTokens
    /// nil for a fact chip; true / false for a filter chip.
    var selected: Bool?

    func makeBody(configuration: Configuration) -> some View {
        let shape = RoundedRectangle(cornerRadius: PhoneMetrics.Radius.small)
        return PhoneControlFeedback(
            label: configuration.label
                .phoneType(.chip, tokens)
                .foregroundStyle(ink)
                .lineLimit(1)
                .padding(.horizontal, PhoneControlMetrics.chipSidePadding)
                .frame(minHeight: PhoneControlMetrics.chipHeight)
                .background(
                    shape
                        .fill(selected == false ? Color.clear : tokens.wash)
                        .overlay(
                            shape.stroke(
                                selected == false ? tokens.takeLine : Color.clear,
                                lineWidth: 1)))
                .phoneHitArea(),
            pressed: configuration.isPressed)
    }

    private var ink: Color {
        switch selected {
        case nil: tokens.accent
        case true?: tokens.ink
        case false?: tokens.phone.muted
        }
    }
}

// MARK: - Field

extension View {
    /// **The field** — the one text field on the phone: paper on the room
    /// (`tokens.surface`), the palette's take line as its edge (sheet §D:
    /// "field and card edges use the palette's existing takeLine"), the Mac's
    /// box corner (`Radius.standard`), 12 inside; the typed text is a
    /// control's (`control` 15) unless the site holds her prose.
    ///
    /// **Its box is drawn at least 36 tall inside a frame at least 44**
    /// (VM-273: the box was the full 44 — the frame and the drawing one size).
    /// The box grows with its text (her words at the accessibility sizes, or
    /// a field that wraps), and the frame with it; what answers a touch is
    /// the text field's own, untouched by the drawing.
    ///
    /// **Its placeholder is the corrected faint** (VM-47, the walk's W-A10 —
    /// sheet §D: placeholders take the corrected faint and need 3:1; iOS's own
    /// placeholder grey reads 1.72:1 on the paper). A field the site builds
    /// takes the words as `TextField(phonePlaceholder:text:tokens:)`; a field
    /// a shared view builds inside itself (`PeekableSecretField`) reads the
    /// ink this modifier hands down, `phoneFieldPrompt`.
    func phoneField(_ tokens: VoiceTokens, role: PhoneTypeRole = .control) -> some View {
        self
            .phoneType(role, tokens)
            .foregroundStyle(tokens.ink)
            .environment(\.phoneFieldPrompt, tokens.phone.faint)
            .padding(.horizontal, PhoneControlMetrics.insidePadding)
            .padding(.vertical, PhoneMetrics.Space.s8)
            .frame(minHeight: PhoneControlMetrics.boxHeight)
            .background(
                RoundedRectangle(cornerRadius: PhoneMetrics.Radius.standard)
                    .fill(tokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: PhoneMetrics.Radius.standard)
                            .stroke(tokens.takeLine, lineWidth: 1)))
            .frame(minHeight: PhoneMetrics.touchMinimum)
    }
}

extension EnvironmentValues {
    /// The placeholder ink of the phone field around a view (`phoneField`):
    /// the corrected faint. nil outside one — the Mac's fields, and any field
    /// not in a phone field, keep the system's own placeholder.
    @Entry var phoneFieldPrompt: Color? = nil
}

extension TextField where Label == Text {
    /// **The phone's field, its placeholder in the corrected faint** (VM-47,
    /// the walk's W-A10). The words are both the field's label — what
    /// VoiceOver reads, exactly as `TextField(_:text:)` — and its prompt, the
    /// placeholder iOS draws while it is empty, which a bare title leaves in
    /// the system's grey. Chain `.phoneField(tokens)` as ever.
    init(phonePlaceholder words: String, text: Binding<String>, tokens: VoiceTokens) {
        self.init(words, text: text, prompt: Text(words).foregroundStyle(tokens.phone.faint))
    }
}

// MARK: - The calm button

/// **The calm button** — the ONE button with a shape (it replaces the five
/// separately built ones of audit G §4.4 item 3): paper fill, the take line
/// as its edge (or the edge alone, `filled: false`, for a door that must
/// look like a button without weighing like one), the Mac's box corner
/// (`Radius.standard`), 12 inside, the label `control` 15 in its tone;
/// `fullWidth` spans its container (a sheet's primary act).
///
/// **Its box is drawn at least 36 tall inside a target at least 64 × 44**
/// (VM-273: the box was the full 44, the target and the drawing one size) —
/// the whole target answers, the box sitting centred in it.
struct PhoneCalmButtonStyle: ButtonStyle {
    let tokens: VoiceTokens
    var tone: PhoneActTone = .accent
    var fullWidth = false
    var filled = true

    func makeBody(configuration: Configuration) -> some View {
        PhoneControlFeedback(
            label: configuration.label
                .phoneType(.control, tokens)
                .foregroundStyle(tone.color(tokens))
                .multilineTextAlignment(fullWidth ? .center : .leading)
                .padding(.horizontal, PhoneControlMetrics.insidePadding)
                .padding(.vertical, PhoneMetrics.Space.s8)
                .frame(
                    minWidth: PhoneControlMetrics.textButtonMinWidth,
                    maxWidth: fullWidth ? .infinity : nil,
                    minHeight: PhoneControlMetrics.boxHeight)
                .background(
                    RoundedRectangle(cornerRadius: PhoneMetrics.Radius.standard)
                        .fill(filled ? tokens.surface : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: PhoneMetrics.Radius.standard)
                                .stroke(tokens.takeLine, lineWidth: 1)))
                .frame(minHeight: PhoneMetrics.touchMinimum)
                .contentShape(Rectangle()),
            pressed: configuration.isPressed)
    }
}

// MARK: - Sheet header

/// **The sheet header** — one header for every SwiftUI sheet (the ten
/// hand-rolled copies of audit G T72): the title `screenTitle` 20 at the
/// gutter, then Done — `control` 15 semibold in the accent, a 64 × 44 hit
/// area 8 from the sheet's edge — on a row at least 56 tall (sheet §E).
///
/// **It sits INSIDE the sheet's 20 pt gutter** (every sheet pads its content
/// 20), so the title lands on the gutter and Done reaches 12 into it: its
/// hit area ends 8 from the edge and its word 20 from it, as the sheet draws.
/// Done's label is the site's own word, voiced (`chromeLabel`), with no
/// re-label — the pins that drive a sheet's Done by its word keep driving it.
struct PhoneSheetHeader<Trailing: View>: View {
    let title: String
    let tokens: VoiceTokens
    /// The title's ink — her ink by default; a path-style title (Settings,
    /// Acknowledgments) keeps the muted it was drawn in.
    var titleInk: Color?
    /// The closing act's word (Done by default; Cancel on a sheet that files
    /// nothing).
    var doneWord = "Done"
    let done: () -> Void
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: PhoneMetrics.Space.s8) {
            Text(title)
                .phoneType(.screenTitle, tokens)
                .foregroundStyle(titleInk ?? tokens.ink)
                .lineLimit(2)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: PhoneMetrics.Space.s8)
            trailing()
            Button(tokens.chromeLabel(doneWord), action: done)
                .buttonStyle(PhoneTextButtonStyle(tokens: tokens, closing: true))
        }
        .frame(minHeight: PhoneControlMetrics.sheetHeaderHeight)
        // Done's 12 pt inside padding reaches into the sheet's 20 pt gutter,
        // so its hit area ends 8 from the edge and its word at the gutter.
        .padding(
            .trailing,
            PhoneControlMetrics.sheetHeaderTrailing - PhoneMetrics.gutter)
    }
}

extension PhoneSheetHeader where Trailing == EmptyView {
    init(
        _ title: String, tokens: VoiceTokens, titleInk: Color? = nil,
        doneWord: String = "Done", done: @escaping () -> Void
    ) {
        self.init(
            title: title, tokens: tokens, titleInk: titleInk, doneWord: doneWord,
            done: done, trailing: { EmptyView() })
    }
}

// MARK: - Section header

/// **The section header** — "Add to a book", "Apply a tag", "Commits":
/// `sectionHeader` 13 semibold in the corrected muted, sentence case (the
/// site's own words, voiced), 24 above and 8 below (sheet §E).
struct PhoneSectionHeader: View {
    let title: String
    let tokens: VoiceTokens

    init(_ title: String, tokens: VoiceTokens) {
        self.title = title
        self.tokens = tokens
    }

    var body: some View {
        Text(title)
            .phoneType(.sectionHeader, tokens)
            .foregroundStyle(tokens.phone.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, PhoneControlMetrics.sectionAbove)
            .padding(.bottom, PhoneControlMetrics.sectionBelow)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Menu row

/// **The menu row's style** — a whole row is one target: the label fills the
/// row's width, left-aligned, at least `minHeight` tall (sheet §C/§E).
/// Used by `PhoneMenuRow`, and by a site whose row content is its own (a
/// note-actions row's title and detail) at the same floors.
struct PhoneMenuRowStyle: ButtonStyle {
    var minHeight: CGFloat = PhoneControlMetrics.menuRowPlain

    func makeBody(configuration: Configuration) -> some View {
        PhoneControlFeedback(
            label: configuration.label
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
                .contentShape(Rectangle()),
            pressed: configuration.isPressed)
    }
}

/// **The menu row** — an optional 17 pt glyph in the accent, 12, the label
/// `control` 15 in ink (a removing act in the alarm ink), an optional detail
/// line `meta` 13 in the corrected muted; at least 52 tall with a glyph, 64
/// with a detail line, 44 with neither (sheet §E; §C's one-line menu row).
struct PhoneMenuRow: View {
    let title: String
    var detail: String?
    /// An SF Symbol name.
    var glyph: String?
    var tone: PhoneActTone = .ink
    let tokens: VoiceTokens
    /// The row's side inset, INSIDE its target (VM-53): a full-width list row
    /// (Settings) passes the gutter, so the whole row answers edge to edge
    /// while its words sit at the gutter. 0 — a row inside a padded sheet.
    var inset: CGFloat = 0
    let action: () -> Void

    init(
        _ title: String, detail: String? = nil, glyph: String? = nil,
        tone: PhoneActTone = .ink, tokens: VoiceTokens, inset: CGFloat = 0,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.detail = detail
        self.glyph = glyph
        self.tone = tone
        self.tokens = tokens
        self.inset = inset
        self.action = action
    }

    static func minHeight(hasGlyph: Bool, hasDetail: Bool) -> CGFloat {
        if hasDetail { return PhoneControlMetrics.menuRowWithDetail }
        return hasGlyph ? PhoneControlMetrics.menuRowWithGlyph : PhoneControlMetrics.menuRowPlain
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: PhoneMetrics.Space.s12) {
                if let glyph {
                    Image(systemName: glyph)
                        .modifier(PhoneGlyphModifier(size: PhoneControlMetrics.iconGlyph))
                        .foregroundStyle(tone == .alarm ? tokens.alarm : tokens.accent)
                        .frame(width: PhoneControlMetrics.iconGlyph)
                        .accessibilityHidden(true)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .phoneType(.control, tokens)
                        .foregroundStyle(tone == .alarm ? tokens.alarm : tokens.ink)
                    if let detail {
                        Text(detail)
                            .phoneType(.meta, tokens)
                            .foregroundStyle(tokens.phone.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, PhoneMetrics.Space.s4)
            .padding(.horizontal, inset)
        }
        .buttonStyle(PhoneMenuRowStyle(
            minHeight: Self.minHeight(hasGlyph: glyph != nil, hasDetail: detail != nil)))
    }
}

// MARK: - The segmented choice's widths (pure)

/// **How the segmented choice shares its width** — each word gets its own
/// width plus the inside padding on each side; what is left over is shared
/// equally; when the words do not fit (Display Zoom, a long word in mono),
/// every segment gives up the same share of its width (the system then
/// truncates the word it cannot draw — recorded per site in the run record).
nonisolated enum PhoneSegmentWidths {
    /// Inside a segment, each side (sheet §C's 12 inside buttons).
    static let insidePadding: CGFloat = PhoneControlMetrics.insidePadding

    static func widths(naturals: [CGFloat], available: CGFloat) -> [CGFloat] {
        let wanted = naturals.map { $0 + 2 * insidePadding }
        let total = wanted.reduce(0, +)
        guard available > 0, total > 0 else { return wanted }
        if total <= available {
            let extra = (available - total) / CGFloat(wanted.count)
            return wanted.map { $0 + extra }
        }
        return wanted.map { $0 * available / total }
    }
}

// MARK: - The segmented choice (the system control, styled) — iOS

#if os(iOS)
/// **The segmented choice** — the system's `UISegmentedControl`, styled by the
/// layer: each word in the `chip` role (13 medium), the selected word in her
/// ink, the others in the corrected muted, the selected segment on the paper;
/// at least 44 tall. It replaces the rows of plain words that stood in for
/// segmented choices (audit G §4.4 item 7).
///
/// **Its selection contract:** `selection` is the segment shown selected
/// (re-applied on every update, so a change the site makes shows); a tap —
/// or VoiceOver's activate — on another segment selects it and calls
/// `select` with that value once; re-choosing the shown selection calls
/// nothing. A site whose `select` can REFUSE a change must force an update:
/// the system control has already moved its own selection to the tapped
/// segment, and only an update re-applies `selection` (every site today
/// assigns unconditionally — the VM-47 midway review's m-2). Each segment
/// speaks its PLAIN word with the button trait, and `.isSelected` on the
/// selected one.
struct PhoneSegmentedChoice<Value: Hashable>: View {
    let options: [Value]
    let word: (Value) -> String
    let selection: Value
    let tokens: VoiceTokens
    let select: (Value) -> Void
    @Environment(\.dynamicTypeSize) private var typeSize

    init(
        _ options: [Value], selection: Value, tokens: VoiceTokens,
        word: @escaping (Value) -> String, select: @escaping (Value) -> Void
    ) {
        self.options = options
        self.selection = selection
        self.tokens = tokens
        self.word = word
        self.select = select
    }

    var body: some View {
        PhoneSegmentedControlBridge(
            titles: options.map { tokens.chromeLabel(word($0)) },
            spoken: options.map(word),
            selectedIndex: options.firstIndex(of: selection),
            tokens: tokens,
            category: typeSize.phoneCategory,
            onSelect: { index in
                guard options.indices.contains(index) else { return }
                let value = options[index]
                if value != selection { select(value) }
            })
            .frame(minHeight: PhoneMetrics.touchMinimum)
    }
}

/// The bridge to the system control. Rebuilds its segments only when the
/// words change; re-styles on every update (voice, appearance, text size).
private struct PhoneSegmentedControlBridge: UIViewRepresentable {
    let titles: [String]
    let spoken: [String]
    let selectedIndex: Int?
    let tokens: VoiceTokens
    let category: UIContentSizeCategory
    let onSelect: (Int) -> Void

    final class Coordinator: NSObject {
        var onSelect: (Int) -> Void = { _ in }
        @objc func changed(_ control: UISegmentedControl) {
            onSelect(control.selectedSegmentIndex)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> PhoneSegmentedControl {
        let control = PhoneSegmentedControl()
        control.addTarget(
            context.coordinator, action: #selector(Coordinator.changed(_:)),
            for: .valueChanged)
        control.setContentHuggingPriority(.defaultLow, for: .horizontal)
        control.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return control
    }

    func updateUIView(_ control: PhoneSegmentedControl, context: Context) {
        context.coordinator.onSelect = onSelect
        if control.titles != titles {
            control.removeAllSegments()
            for (index, title) in titles.enumerated() {
                control.insertSegment(withTitle: title, at: index, animated: false)
            }
            control.titles = titles
        }
        control.spokenWords = spoken
        control.selectedSegmentIndex = selectedIndex ?? UISegmentedControl.noSegment
        let font = PhoneType.uiFont(
            .chip, voice: tokens.voice,
            compatibleWith: UITraitCollection(preferredContentSizeCategory: category))
        control.setTitleTextAttributes(
            [.font: font, .foregroundColor: UIColor(tokens.phone.muted)], for: .normal)
        control.setTitleTextAttributes(
            [.font: font, .foregroundColor: UIColor(tokens.ink)], for: .selected)
        control.selectedSegmentTintColor = UIColor(tokens.surface)
        control.titleFont = font
        control.setNeedsLayout()
    }

    func sizeThatFits(
        _ proposal: ProposedViewSize, uiView: PhoneSegmentedControl, context: Context
    ) -> CGSize? {
        let fit = uiView.intrinsicContentSize
        return CGSize(
            width: proposal.width ?? fit.width,
            height: max(fit.height, PhoneMetrics.touchMinimum))
    }
}

/// The system control with its segments spoken as plain words — one
/// accessibility element per segment (label = the plain word, the button
/// trait, `.isSelected` when chosen), so VoiceOver and the surface pins both
/// drive a segment by its word.
final class PhoneSegmentedControl: UISegmentedControl {
    var titles: [String] = []
    var spokenWords: [String] = [] {
        didSet { if spokenWords != oldValue { segmentElements = [] } }
    }
    /// The words' font — the segments are sized from it.
    var titleFont: UIFont = .systemFont(ofSize: 15)
    private var segmentElements: [PhoneSegmentElement] = []
    /// The widths the segments were last given (also the spoken elements'
    /// frames), so a long word gets its room and a short one shares the
    /// rest.
    private(set) var segmentWidths: [CGFloat] = []

    override func layoutSubviews() {
        let widths = PhoneSegmentWidths.widths(
            naturals: titles.map {
                ceil(($0 as NSString).size(withAttributes: [.font: titleFont]).width)
            },
            available: bounds.width)
        if widths != segmentWidths, widths.count == numberOfSegments {
            segmentWidths = widths
            for (index, width) in widths.enumerated() {
                setWidth(width, forSegmentAt: index)
            }
        }
        super.layoutSubviews()
    }

    override var isAccessibilityElement: Bool {
        get { false }
        set {}
    }

    override var accessibilityElements: [Any]? {
        get {
            if segmentElements.count != numberOfSegments {
                segmentElements = (0..<numberOfSegments).map {
                    PhoneSegmentElement(control: self, index: $0)
                }
            }
            for element in segmentElements { element.place() }
            return segmentElements
        }
        set {}
    }

    /// Select a segment as a tap would: the control's value changes and its
    /// value-changed action fires.
    func choose(_ index: Int) {
        guard (0..<numberOfSegments).contains(index) else { return }
        selectedSegmentIndex = index
        sendActions(for: .valueChanged)
    }

    func spokenWord(at index: Int) -> String {
        spokenWords.indices.contains(index) ? spokenWords[index] : (titleForSegment(at: index) ?? "")
    }
}

final class PhoneSegmentElement: UIAccessibilityElement {
    private weak var control: PhoneSegmentedControl?
    let index: Int

    init(control: PhoneSegmentedControl, index: Int) {
        self.control = control
        self.index = index
        super.init(accessibilityContainer: control)
    }

    /// The segment's frame in the control — the widths the control gave its
    /// segments (`PhoneSegmentWidths`), or equal shares before its first
    /// layout.
    func place() {
        guard let control, control.numberOfSegments > 0 else { return }
        let widths = control.segmentWidths.count == control.numberOfSegments
            ? control.segmentWidths
            : Array(
                repeating: control.bounds.width / CGFloat(control.numberOfSegments),
                count: control.numberOfSegments)
        let x = widths.prefix(index).reduce(0, +)
        accessibilityFrameInContainerSpace = CGRect(
            x: x, y: 0, width: widths[index], height: control.bounds.height)
    }

    override var accessibilityLabel: String? {
        get { control?.spokenWord(at: index) }
        set {}
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            guard let control else { return .button }
            return control.selectedSegmentIndex == index ? [.button, .selected] : .button
        }
        set {}
    }

    override func accessibilityActivate() -> Bool {
        guard let control else { return false }
        control.choose(index)
        return true
    }
}

// MARK: - The overlays' hit area (UIKit)

/// **A UIKit button that answers across at least 44 × 44** without changing
/// what it draws or where it sits — the hit-area helper's UIKit form, for the
/// three hand-built overlays (takes, comments, block history), which keep
/// their structure (native sheets are VM-152's): the button's own frame is
/// untouched and its touch region reaches `PhoneMetrics.hitOutset` past it.
/// (A touch must still land inside the button's superview to reach it.)
class PhoneHitAreaButton: UIButton {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else {
            return super.point(inside: point, with: event)
        }
        let outset = PhoneMetrics.hitOutset(for: bounds.size)
        return bounds.insetBy(dx: -outset.horizontal, dy: -outset.vertical).contains(point)
    }
}
#endif
