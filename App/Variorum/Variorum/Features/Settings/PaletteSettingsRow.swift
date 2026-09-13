//
//  PaletteSettingsRow.swift
//  Variorum (Mac)
//
//  18g — the palette's ONE door: a swatch strip under "Design voice" in
//  Settings ▸ Appearance, and, when she picks Custom, the hex field (plus
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
    /// Seeded from the landed settings, and never re-seeded under her
    /// cursor (the focus guard below).
    @State private var roomField = ""
    @State private var accentField = ""
    @State private var note: String?
    @FocusState private var editingHex: Bool

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
            // under the strip that summons them, above the two long help
            // paragraphs. Found on the walk: with the help text first, a
            // refused hex put its refusal below the window's fold in a
            // pane that is 460 pt tall and does not resize — a refusal she
            // cannot see is the P-2 failure wearing a layout's clothes.
            if settings.palette == .custom { customFields }
            if let note {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(PaletteCopy.help)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(PaletteCopy.notAVoiceNote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .task(id: seedsKey) { adoptLandedSeeds() }
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
    /// shows her seeds and every other one shows its own (none).
    private func tint(for palette: ThemePalette) -> PaletteTint {
        palette == .custom
            ? PaletteTint(room: settings.customRoom, accent: settings.customAccent)
            : .none
    }

    // MARK: Her own hex

    @ViewBuilder private var customFields: some View {
        // The labels sit ABOVE their fields, not beside them: the pane is
        // 560 pt wide and a `TextField`'s inline label wrapped mid-phrase
        // ("Your / colour") at that width — seen on the walk.
        HStack(alignment: .bottom, spacing: 14) {
            hexField(PaletteCopy.roomFieldLabel, text: $roomField)
            hexField(PaletteCopy.accentFieldLabel, text: $accentField)
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

    private func hexField(_ label: String, text: Binding<String>) -> some View {
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
                .focused($editingHex)
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
    /// A colour that LANDS also selects Custom, so typing one is the whole
    /// gesture rather than typing-then-clicking.
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
                if let landed = ThemeTint.normalize(room) {
                    note = PaletteCopy.landed(landed, accent: ThemeTint.normalize(accent))
                    if theme.settings.palette != .custom { theme.setThemePalette(.custom) }
                } else {
                    note = nil
                }
            } catch {
                note = OpsRefusalCopy.message(for: error)
            }
        }
    }

    /// The landed value is the truth; the fields follow it — except while
    /// her cursor is in one, where following it would eat what she is
    /// typing.
    private var seedsKey: String {
        "\(settings.customRoom ?? "")|\(settings.customAccent ?? "")|\(editingHex)"
    }

    private func adoptLandedSeeds() {
        guard !editingHex else { return }
        roomField = settings.customRoom ?? ""
        accentField = settings.customAccent ?? ""
    }
}
