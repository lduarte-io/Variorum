//
//  LibraryListFace.swift
//  Variorum (Mac)
//
//  **librarywalkpolish VR-113 (17y B-WALK W-1) — THE LIST'S FACE, ON THE LAZY
//  COLUMN.** Her answer at the walk to #187(i): "the scroll itself is not
//  fine. it's noticeable how laggy it is… the hit is too big - there's
//  glitching and lags on the way down. ew!! not in our app." The mechanism
//  (17y B1, F-B1-5): SwiftUI's `List` on macOS is an `NSTableView` whose
//  automatic row heights host and size a SwiftUI view per NEW row, so a fast
//  scroll through rows not yet built runs below the display's pace — while
//  the Cards view, on a `LazyVStack`, keeps it. The ruled road: the List
//  mode's rows ride the SAME lazy-column engine, wearing EXACTLY the List's
//  face.
//
//  THE FACE, MEASURED off the shipped List (the B-WALK record's § THE W-1
//  FACE — `NSTableView` style `.inset` read through the mounted rig, both
//  voices, and its drawn pixels): a 10-pt top inset · section headers 28 pt
//  tall, the system's semibold subheadline in the secondary ink, 16 pt in,
//  a hairline at their foot, floating over the rows when pinned on the
//  header material · rows inset 16 pt each side and 4 pt top and bottom
//  around their own content (so a row is its content + 8 — 25/26 pt in
//  Terminal, 30 in Study), each with a 1-pt separator at its foot from 16 pt
//  to 16 pt short of the edge, in the system separator ink · 20 pt between a
//  section's last row and the next header. Everything else on a row (the
//  title, the day, the chips and their ＋, the badge, the right-aligned
//  stamp, the pick's wash and border) is the row's own content, unchanged.
//

import AppKit
import SwiftUI

enum LibraryListFace {
    static let topInset: CGFloat = 10
    static let bottomInset: CGFloat = 10
    static let headerHeight: CGFloat = 28
    static let sectionGap: CGFloat = 20
    static let rowInsets = EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16)
    static let separatorInset: CGFloat = 16
    /// The List's own separator ink — the system's, appearance-adaptive
    /// (what the table drew; never a literal).
    static var separator: Color { Color(nsColor: .separatorColor) }
}

/// One row of the List's face: its content inset as the table inset it, its
/// background (the pick) under the whole row, the separator at its foot.
struct LibraryListRow<Content: View, Background: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let background: () -> Background

    var body: some View {
        content()
            .padding(LibraryListFace.rowInsets)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { background() }
            .overlay(alignment: .bottom) { LibraryListSeparator() }
    }
}

extension LibraryListRow where Background == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.background = { EmptyView() }
    }
}

/// **The table's 10-pt top inset, measured where it really sits:** the
/// first header FLOATS at the very top (the table drew its first group row
/// pinned over its own inset — the before capture's header hairline at the
/// list's 27 pt, its rows at 38), so the inset is the air between that header
/// and its first row, never above the header.
struct LibraryListLead: View {
    var body: some View {
        Color.clear.frame(height: LibraryListFace.topInset)
    }
}

/// The 1-pt separator at a row's (or a header's) foot.
struct LibraryListSeparator: View {
    var body: some View {
        LibraryListFace.separator
            .frame(height: 1)
            .padding(.horizontal, LibraryListFace.separatorInset)
            .allowsHitTesting(false)
    }
}

/// A section header of the List's face — pinned (floating) over the rows on
/// the header material, as the table's group rows floated (in LIGHT; in dark,
/// on the voice's own colours — VX-20, below).
struct LibraryListHeader: View {
    /// The words, already voiced (`tokens.chromeLabel`).
    let title: String
    @State private var pinned = false
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The system's shadow ink (appearance-adaptive — never a literal).
    private static var shade: Color { Color(nsColor: .shadowColor) }

    /// **What the PINNED header draws on** (VX-20 — her #188(m) ruling, "the
    /// bands match"; the record `notes/plans/librarywalkpolish-ladder-round1.md`
    /// § THE ONE FINDING). The header material reads #FFFEFF in light — the
    /// native table's own floating header, the batch-1 parity, true there —
    /// but in DARK it drew a warm grey band (#2F2D29) across the black room
    /// in both voices, where the old List's heading sits almost on the room.
    /// So in dark the header draws from the VOICE: the paper the List itself
    /// draws on (`surface` — under a palette it carries the palette's paper,
    /// so the header can never be a band of another colour) and the voice's
    /// hairline at its foot. Light keeps the material, unchanged.
    enum PinnedFace: Equatable {
        /// Light: the table's floating-header material, its soft shade and
        /// hairline shadow (the measured face).
        case material
        /// Dark: the voice's own paper, and its hairline.
        case voice(fill: Color, hairline: Color)
    }

    static func pinnedFace(tokens: VoiceTokens, dark: Bool) -> PinnedFace {
        dark ? .voice(fill: tokens.surface, hairline: tokens.line) : .material
    }

    private var face: PinnedFace {
        Self.pinnedFace(
            tokens: themeStore?.tokens(for: scheme) ?? .fallback(for: scheme),
            dark: scheme == .dark)
    }

    var body: some View {
        let face = face
        return Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.leading, LibraryListFace.rowInsets.leading)
            .frame(
                maxWidth: .infinity, minHeight: LibraryListFace.headerHeight,
                maxHeight: LibraryListFace.headerHeight, alignment: .leading)
            .background {
                if pinned {
                    switch face {
                    case .material:
                        // The floating group row's face (measured): the header
                        // material, a soft shade over its last 4 pt, and a
                        // full-width hairline shadow under it.
                        ZStack(alignment: .bottom) {
                            LibraryListHeaderMaterial()
                            LinearGradient(
                                colors: [Self.shade.opacity(0), Self.shade.opacity(0.025)],
                                startPoint: .top, endPoint: .bottom)
                                .frame(height: 4)
                        }
                    case .voice(let fill, _):
                        fill
                    }
                }
            }
            .overlay(alignment: .bottom) { LibraryListSeparator() }
            .overlay(alignment: .bottom) {
                if pinned {
                    switch face {
                    case .material:
                        VStack(spacing: 0) {
                            // The floating separator reads darker (measured 209–223
                            // against a resting 230) …
                            Self.shade.opacity(0.07)
                                .frame(height: 1)
                                .padding(.horizontal, LibraryListFace.separatorInset)
                            // … over a full-width hairline shadow beneath it.
                            Self.shade.opacity(0.09).frame(height: 1)
                        }
                        .offset(y: 1)
                        .allowsHitTesting(false)
                    case .voice(_, let hairline):
                        // The voice's hairline across the header's foot, over
                        // the resting separator (one line, edge to edge).
                        hairline
                            .frame(height: 1)
                            .allowsHitTesting(false)
                    }
                }
            }
            .onGeometryChange(for: Bool.self) { $0.frame(in: .scrollView).minY <= 0.5 } action: {
                pinned = $0
            }
            .accessibilityAddTraits(.isHeader)
    }
}

/// The table's floating-header material.
private struct LibraryListHeaderMaterial: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .headerView
        view.blendingMode = .withinWindow
        view.state = .followsWindowActiveState
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}
