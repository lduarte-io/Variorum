//
//  PaletteSettingsRow.swift
//  Variorum (Mac)
//
//  18g — the palette's ONE door: a swatch strip under "Theme" (the control
//  "Design voice" was renamed at her 2026-10-13 General ruling) in
//  Settings ▸ General, and, when she picks Custom, the hex field (plus
//  the optional second — her R-Q13). Its own file because `AppSettingsView`
//  is already 560 lines and a feature that arrives as fifty lines inside a
//  pane is how a pane becomes a god file (P-9); the pane composes it in
//  three lines.
//
//  **Every swatch shows the app's OWN colours, not a preview of them:** the
//  fill comes from `VoiceTokens.resolve` at the current voice and
//  appearance, which is the same call the whole app makes. There is no
//  second derivation here to drift from the first.
//

import SwiftUI
import VariorumCore

struct PaletteSettingsRow: View {
    let session: AppSession
    let theme: ThemeStore
    @Environment(\.colorScheme) private var scheme

    /// What she is typing, held locally so a keystroke is never a write.
    /// Seeded from the LANDED settings, and never re-seeded under her
    /// cursor or over text she has typed and not yet committed (the
    /// dirty-field rule below — 18g ladder R1-2).
    @State private var roomField = ""
    @State private var accentField = ""
    @State private var note: String?
    /// ONE identity per field (R1-2): a shared Bool could not tell "left
    /// the room field for the accent field" from "left the fields", and
    /// the rule that follows needs to know WHICH field she left.
    @FocusState private var focusedField: PaletteSeedField?

    private var settings: Queries.ThemeSettings { theme.settings }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(PaletteCopy.title)
                Spacer()
                Text(PaletteCopy.label(settings.palette))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            ForEach(PaletteCopy.Group.allCases, id: \.self) { group in
                HStack(spacing: 6) {
                    Text(group.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 64, alignment: .leading)
                        .lineLimit(1)
                    ForEach(group.palettes, id: \.self) { palette in
                        swatch(palette)
                    }
                    Spacer(minLength: 0)
                }
            }
            // The fields and whatever the pane has to SAY sit directly
            // under the strip that summons them (the walk's fold lesson —
            // a refusal she cannot see is the P-2 failure in layout's
            // clothes). The two long help paragraphs that used to follow
            // are GONE — her 2026-10-13 General ruling: no explanation
            // under the palette. The conditional custom-field notes stay:
            // they are refusals and state notes, not explanation.
            if settings.palette == .custom { customFields }
            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .task(id: landedKey) { adoptLandedSeeds() }
        // **A field she leaves is a field she is done with** (R1-2): what
        // she typed COMMITS on the way out — the act or the refusal, never
        // a silent discard — exactly as a Return would; an untouched field
        // takes the landed value's canonical form.
        .onChange(of: focusedField) { old, _ in
            if let old { fieldLostFocus(old) }
        }
    }

    // MARK: The strip

    private func swatch(_ palette: ThemePalette) -> some View {
        let tokens = VoiceTokens.resolve(
            voice: settings.voice, palette: palette, tint: tint(for: palette),
            dark: scheme == .dark)
        let chosen = settings.palette == palette
        let unseeded = palette == .custom && ThemeTint.normalize(settings.customRoom) == nil
        return Button {
            choose(palette)
        } label: {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(unseeded ? Color.clear : tokens.room)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(
                                unseeded ? Color.secondary : tokens.line,
                                style: StrokeStyle(
                                    lineWidth: 1, dash: unseeded ? [2, 2] : []))
                    )
                if !unseeded {
                    Circle()
                        .fill(tokens.accent)
                        .frame(width: 9, height: 9)
                        .padding(3)
                }
            }
            .frame(width: 30, height: 22)
            // **Found on the walk:** an UNSEEDED Custom swatch fills with
            // `Color.clear`, and SwiftUI does not hit-test a clear fill —
            // so the one swatch she has to click FIRST (before there is a
            // colour to show) was the one that could not be clicked; only
            // its 1-pt dashed border was live. The content shape makes the
            // whole rectangle the button, which is what every other swatch
            // gets for free from its opaque fill.
            .contentShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .strokeBorder(chosen ? Color.accentColor : .clear, lineWidth: 2)
                    .padding(-2)
            )
        }
        .buttonStyle(.plain)
        .help(PaletteCopy.label(palette))
        .accessibilityLabel(PaletteCopy.label(palette))
        .accessibilityAddTraits(chosen ? [.isSelected] : [])
    }

    /// A swatch shows what THAT palette would look like — so the custom one
    /// shows her seeds (through the one `PaletteTint(settings)` mapping,
    /// never a second spelling of the pair — 18g ladder R1-1) and every
    /// other one shows its own (none).
    private func tint(for palette: ThemePalette) -> PaletteTint {
        palette == .custom ? PaletteTint(settings) : .none
    }

    // MARK: Her own hex

    @ViewBuilder private var customFields: some View {
        // The labels sit ABOVE their fields, not beside them: the pane is
        // 560 pt wide and a `TextField`'s inline label wrapped mid-phrase
        // ("Your / colour") at that width — seen on the walk.
        HStack(alignment: .bottom, spacing: 14) {
            hexField(.room, PaletteCopy.roomFieldLabel, text: $roomField)
            hexField(.accent, PaletteCopy.accentFieldLabel, text: $accentField)
            Spacer(minLength: 0)
        }
        Text(PaletteCopy.customHelp)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        if ThemeTint.normalize(settings.customRoom) == nil {
            Text(PaletteCopy.needsASeedNote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func hexField(
        _ field: PaletteSeedField, _ label: String, text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .fixedSize()
            TextField(label, text: text, prompt: Text(PaletteCopy.hexPrompt))
                .labelsHidden()
                .textFieldStyle(.roundedBorder)
                .frame(width: 120)
                .focused($focusedField, equals: field)
                .onSubmit { commitSeeds() }
                .accessibilityLabel(label)
        }
    }

    // MARK: Acts

    private func choose(_ palette: ThemePalette) {
        note = nil
        guard palette != settings.palette else { return }
        theme.setThemePalette(palette)
    }

    /// The write goes through the runner and shows the operations layer's
    /// REAL refusal inline — the three other refusable settings on this
    /// pane's exact shape (`setDefaultSegmentation` and its two
    /// neighbours), and the reason `ThemeStore` deliberately has no setter
    /// for the seeds: its `run` swallows errors into a `lastError` nothing
    /// renders.
    ///
    /// The fields exist only under Custom (`customFields` renders when the
    /// landed palette is `.custom`), so the gesture is click-Custom-then-
    /// type and a landed colour never has to SELECT Custom — the branch
    /// that did was reachable only through a race (18g ladder, R1-6).
    private func commitSeeds() {
        let room = roomField.trimmingCharacters(in: .whitespacesAndNewlines)
        let accent = accentField.trimmingCharacters(in: .whitespacesAndNewlines)
        note = nil
        Task {
            do {
                try await session.runner.run {
                    try $0.setThemeTints(
                        room: room.isEmpty ? nil : room,
                        accent: accent.isEmpty ? nil : accent)
                }
                note = ThemeTint.normalize(room).map {
                    PaletteCopy.landed($0, accent: ThemeTint.normalize(accent))
                }
            } catch {
                note = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// The landed value is the truth; the fields follow it WHEN IT MOVES —
    /// never on a focus change (R1-2: keying the adoption on focus was what
    /// discarded a typed, unsubmitted colour the moment she clicked away).
    private var landedKey: String {
        "\(settings.customRoom ?? "")|\(settings.customAccent ?? "")"
    }

    /// Each field takes the landed value unless her cursor is in it. A
    /// field that held a REFUSED value and is now overwritten by a landed
    /// one takes the refusal's words down with it — they named text that
    /// is no longer there.
    private func adoptLandedSeeds() {
        if focusedField != .room {
            if PaletteSeedField.isDirty(roomField, landed: settings.customRoom) { note = nil }
            roomField = settings.customRoom ?? ""
        }
        if focusedField != .accent {
            if PaletteSeedField.isDirty(accentField, landed: settings.customAccent) { note = nil }
            accentField = settings.customAccent ?? ""
        }
    }

    /// Leaving a field: dirty → commit (the act or the refusal, inline);
    /// clean → show the landed value's canonical form.
    private func fieldLostFocus(_ field: PaletteSeedField) {
        switch field {
        case .room:
            if PaletteSeedField.isDirty(roomField, landed: settings.customRoom) {
                commitSeeds()
            } else {
                roomField = settings.customRoom ?? ""
            }
        case .accent:
            if PaletteSeedField.isDirty(accentField, landed: settings.customAccent) {
                commitSeeds()
            } else {
                accentField = settings.customAccent ?? ""
            }
        }
    }
}

// MARK: - The two seed fields, and the one rule about leaving one

/// The custom palette's two hex fields, and the PURE rule the row consults
/// when she leaves one (18g ladder R1-2): a field is DIRTY when what it
/// holds says something the landed value does not — so a dirty field
/// commits on the way out (the act or the refusal, never a silent discard),
/// and a clean one is merely shown in canonical form. Pinned in
/// `PaletteDerivationTests`.
nonisolated enum PaletteSeedField: Hashable, Sendable {
    case room
    case accent

    /// Dirty iff the text is neither the landed value's stored form nor a
    /// spelling that normalizes TO it — `#e07a5f` over a landed `E07A5F` is
    /// clean; `nope` over nothing is dirty (it wants its refusal); an
    /// emptied field over a landed colour is dirty (it wants to clear).
    static func isDirty(_ text: String, landed: String?) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == (landed ?? "") { return false }
        if let normalized = ThemeTint.normalize(trimmed), normalized == landed { return false }
        return true
    }
}
