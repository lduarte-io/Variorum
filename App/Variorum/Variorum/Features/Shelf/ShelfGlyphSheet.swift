//
//  ShelfGlyphSheet.swift
//  Variorum (Mac)
//
//  13i-d U1 — **SET GLYPH…** (the sitting record §7: *"optional, ONE
//  GRAPHEME, monochrome, inheriting the text's ink — the callout frame's
//  ruled precedent reused. The curated case: FEW and visually distinct at
//  strip size, NO cross, hieroglyphs and the moon IN … free Unicode entry
//  beyond it. No emoji, no color. Final set gets a legibility pass at
//  build."*).
//
//  The curated set is core's `ShelfGlyph.curated` (one list); the live check
//  is `ShelfGlyph.normalize` — the very rule the operation refuses by, so the
//  sheet can never offer Save on a value the op would refuse. Each glyph
//  previews AT STRIP SIZE in the strip's own font (the legibility pass is a
//  question about that size, not a bigger one).
//

import SwiftUI
import VariorumCore

struct ShelfGlyphSheet: View {
    let shelf: Shelf
    let onSave: (String?) -> Void

    @State private var field: String
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(shelf: Shelf, onSave: @escaping (String?) -> Void) {
        self.shelf = shelf
        self.onSave = onSave
        _field = State(initialValue: shelf.glyph ?? "")
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var normalized: (glyph: String?, valid: Bool) { ShelfGlyph.normalize(field) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set Glyph \u{2014} \u{201C}\(shelf.name)\u{201D}").font(.headline)
            Text("One character, set in the strip's own ink \u{2014} no emoji, no colour.")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 6) {
                ForEach(ShelfGlyph.curated, id: \.self) { glyph in
                    let picked = normalized.glyph == glyph
                    Button {
                        field = glyph
                    } label: {
                        Text(glyph)
                            .font(tokens.navigation)
                            .foregroundStyle(picked ? tokens.ink : tokens.muted)
                            .frame(width: 30, height: 26)
                            .background(
                                picked ? tokens.wash : Color.clear,
                                in: RoundedRectangle(cornerRadius: 4))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                TextField("or type one", text: $field)
                    .frame(width: 110)
                // The preview, exactly as the strip will draw the name.
                Text(tokens.chromeLabel(normalized.valid
                    ? ShelfFace.label(Shelf(
                        id: shelf.id, name: shelf.name, glyph: normalized.glyph,
                        position: shelf.position, createdAt: shelf.createdAt,
                        updatedAt: shelf.updatedAt))
                    : shelf.name))
                    .font(tokens.navigation)
                    .fontWeight(.semibold)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
            }
            if !normalized.valid {
                Text("A glyph is one character, and never an emoji.")
                    .font(.caption)
                    .alarmVoice()
            }
            HStack {
                Button("No Glyph") {
                    onSave(nil)
                    dismiss()
                }
                .disabled(shelf.glyph == nil)
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Save") {
                    onSave(normalized.glyph)
                    dismiss()
                }
                .disabled(!normalized.valid)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
    }
}

/// 13i-d U1: the shelf prompts present by item (`.sheet(item:)`,
/// `.alert(presenting:)`) — the `Reading` conformance's precedent
/// (`ReadingViews.swift`), retroactive for the same reason: the record is
/// core's, the presentation need is the app's.
extension Shelf: @retroactive Identifiable {}
