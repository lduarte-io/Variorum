//
//  BookFoldDisclosure.swift
//  Variorum
//
//  **VX-291 — THE BOOK'S FOLD DISCLOSURE: one control for ▸ and ▾.** Her
//  words (2026-10-13): *"when you're in a book i think the dropdown target for
//  opening the text of the book is too small right now - that one little
//  triangle could stand to just be a bit bigger."*
//
//  The trace (the ticket's, re-read on this tree): the Outline card's ▸ was
//  `Text("▸")` at the voice's 11.5-pt small size, faint ink, 2 pt of padding —
//  an ~11×14-pt target INSIDE the card's own Button, so a near miss opened the
//  note in the full editor and took her out of the book. Its twin, the
//  expanded header's ▾, was a different control (a voiced word, ~17×18), and
//  the book Index's chapter fold was the 11.5-pt glyph again.
//
//  **The shape:** a 13-pt glyph in the quiet ink, in a 22-pt square that IS
//  the target (`.contentShape` AFTER the frame) and wears the voiced hover
//  wash. The square GROWS OUTWARD: its layout footprint is pulled back to
//  `footprint` by negative padding, so the row it sits in is laid out exactly
//  as the 11.5-pt glyph laid it out — the Outline card keeps the height
//  `BookOutlineHeights` learned (the 46-pt chrome constant), and the extra
//  target reaches into the card's own padding and the row's spacing, never
//  over the title beside it (`overhang` < every host's spacing). Both states
//  are this one control, so ▸ and ▾ read as one.
//

import SwiftUI

struct BookFoldDisclosure: View {
    let tokens: VoiceTokens
    /// True draws ▸ (press to unfold); false draws ▾ (press to fold).
    let folded: Bool
    let help: String
    #if DEBUG
    /// The DEBUG oracle's key for this control (`BookFoldGeometry`) — the
    /// subject-keyed rule: "card-<postID>", "header-<postID>",
    /// "chapter-<groupID>". Nil reports nothing.
    var probeKey: String?
    #endif
    let action: () -> Void

    /// The target's side — the ticket's ~22 pt.
    nonisolated static let hitSide: CGFloat = 22
    /// The glyph — the ticket's 13–14 pt.
    nonisolated static let glyphSize: CGFloat = 13
    /// What the control CLAIMS in its row: no taller than the 11.5-pt line it
    /// replaced (so no row grows for it) and as wide as the old ▸ with its
    /// padding, rounded.
    nonisolated static let footprint = CGSize(width: 12, height: 13)
    /// How far the target overhangs its footprint on each side.
    nonisolated static var overhang: CGSize {
        CGSize(width: (hitSide - footprint.width) / 2, height: (hitSide - footprint.height) / 2)
    }

    init(
        tokens: VoiceTokens, folded: Bool, help: String, probeKey: String? = nil,
        action: @escaping () -> Void
    ) {
        self.tokens = tokens
        self.folded = folded
        self.help = help
        #if DEBUG
        self.probeKey = probeKey
        #endif
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(folded ? "\u{25B8}" : "\u{25BE}")
        }
        .buttonStyle(Style(tokens: tokens, probeKey: debugKey))
        .help(help)
    }

    private var debugKey: String? {
        #if DEBUG
        probeKey
        #else
        nil
        #endif
    }

    private struct Style: ButtonStyle {
        let tokens: VoiceTokens
        let probeKey: String?

        func makeBody(configuration: Configuration) -> some View {
            FoldBody(configuration: configuration, tokens: tokens, probeKey: probeKey)
        }

        private struct FoldBody: View {
            let configuration: Configuration
            let tokens: VoiceTokens
            let probeKey: String?
            @State private var hovering = false
            @Environment(\.isEnabled) private var enabled

            var body: some View {
                configuration.label
                    .font(.system(size: BookFoldDisclosure.glyphSize))
                    .foregroundStyle(tokens.muted)
                    // P-8: a chrome glyph is one line.
                    .lineLimit(1)
                    .frame(width: BookFoldDisclosure.hitSide, height: BookFoldDisclosure.hitSide)
                    // The voiced hover wash (`VoicedButtonStyle`'s grammar),
                    // over the whole target.
                    .background(
                        hovering && enabled ? tokens.wash : Color.clear,
                        in: RoundedRectangle(cornerRadius: 4))
                    .opacity(configuration.isPressed ? 0.6 : (enabled ? 1 : 0.4))
                    // AFTER the frame: the whole 22-pt square is the target.
                    .contentShape(Rectangle())
                    .onHover { hovering = $0 }
                    .foldProbe(probeKey, part: .hit)
                    // …and it grows OUTWARD: the row lays out the footprint.
                    .padding(.horizontal, -BookFoldDisclosure.overhang.width)
                    .padding(.vertical, -BookFoldDisclosure.overhang.height)
                    .foldProbe(probeKey, part: .layout)
            }
        }
    }
}

/// Which of a fold control's two rectangles a probe reports (DEBUG-only use;
/// declared in both builds so the modifier's signature compiles in Release).
enum BookFoldPart { case hit, layout }

private extension View {
    @ViewBuilder func foldProbe(_ key: String?, part: BookFoldPart) -> some View {
        #if DEBUG
        if let key {
            self.modifier(BookFoldProbe(key: key, part: part))
        } else {
            self
        }
        #else
        self
        #endif
    }
}

#if DEBUG
/// **VX-291's geometry oracle**: each mounted fold control's two rectangles,
/// in window space — the TARGET (the 22-pt square a click lands in) and the
/// FOOTPRINT (what its row laid out). "The target is big, and it grew
/// outward" is a claim about those two rectangles, so the pins read them.
/// Owned per the 18k C4 rule; the book's surfaces release their own
/// (`BookOutlineGeometry.release`, `BookIndexGeometry.release`).
@MainActor
enum BookFoldGeometry {
    typealias Part = BookFoldPart

    struct Frames: Equatable {
        var hit: CGRect?
        var layout: CGRect?
    }

    private static var store = OwnedRegistrations<String, Frames>()

    static var frames: [String: Frames] { store.current }

    static func record(_ key: String, _ part: Part, _ frame: CGRect, owner: UUID) {
        var frames = store.value(for: key, owner: owner) ?? Frames()
        switch part {
        case .hit: frames.hit = frame
        case .layout: frames.layout = frame
        }
        store.publish(frames, for: key, owner: owner)
    }

    static func release(owner: UUID) { store.release(owner: owner) }

    /// A pin's door (unconditional — a pin owns nothing).
    static func forgetAll() { store.forgetAll() }
}

private struct BookFoldProbe: ViewModifier {
    let key: String
    let part: BookFoldPart
    @Environment(\.debugOracleOwner) private var owner

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
            BookFoldGeometry.record(key, part, frame, owner: owner ?? DebugOracleOwner.unowned)
        }
    }
}
#endif
