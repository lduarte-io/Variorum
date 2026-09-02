//
//  SideColumn.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch G — **row 74: a side column of our
//  own beside a host's content.** Batch E retired the Library's `.inspector`
//  because the system inspector draws its divider in a KEY window only —
//  tabbed out, the boundary between the list and the panel vanished (her
//  words: "the line between the 'note info' and the library disappears when
//  you're tabbed out"). The orchestrator's window-id probe then CONFIRMED
//  the same class at the note's side (`orchestrator-e/r74-*`): the tray,
//  Block History, Versions, references and scraps all hung off ONE
//  `.inspector` host in `PostDetailView`, and the scraps area's tray off
//  another — active, a faint line at the boundary; inactive, none.
//
//  So this is the Library's column, hoisted to the shared home (CLAUDE.md's
//  hoist-at-next-touch rule — two hosts consume it now): an `HStack` of the
//  host's content and, while `shown`, OUR 1-pt divider in the voice's
//  `line` and the panel at a remembered, clamped width — both drawn by us,
//  in every window state; `controlActiveState` cannot take them. The
//  divider carries the pane row's own drag grammar (a 9-pt grip, the
//  resize cursor — `WorkbenchSeam`'s, batch C), so the room the inspector
//  used to let her drag is still hers; the width she chooses is
//  remembered per host. The column's presence slides + fades (E's
//  precedent), which needs the HOST to change `shown` inside an animated
//  transaction (E's burst lesson: a container-level `.animation(value:)`
//  does not carry a transition through an `@Observable`/`@State` change).
//

import SwiftUI

/// The width rule, pure (pinned): the remembered width when she has
/// dragged one, else the ideal — clamped to the minimum, the maximum, and
/// the room that leaves the host's content its own floor.
nonisolated enum SideColumnLayout {
    /// What the host's content keeps beside the panel, whatever is dragged.
    static let contentMinimum: CGFloat = 320
    static let maximum: CGFloat = 640

    static func width(
        remembered: Double, ideal: CGFloat, minimum: CGFloat, total: CGFloat
    ) -> CGFloat {
        let wanted = remembered > 0 ? CGFloat(remembered) : ideal
        // Unmeasured (the first pass): what was asked for.
        guard total > 0 else { return wanted }
        let room = max(minimum, total - contentMinimum)
        return min(max(wanted, minimum), min(maximum, room))
    }

    /// Ladder R1-7 — what a DRAG remembers: the width the pointer asks for
    /// (the room right of it), clamped by the rule above — and never a
    /// proposal at or below zero. A pointer past the window's trailing
    /// edge used to write a proposal ≤ 0, which `width` read as "nothing
    /// remembered" and answered the IDEAL, so a panel being dragged narrow
    /// snapped to 420 the moment the pointer crossed the edge; a drag is
    /// never "nothing remembered" — past the edge it means the minimum.
    static func draggedWidth(
        pointerX: CGFloat, total: CGFloat, ideal: CGFloat, minimum: CGFloat
    ) -> CGFloat {
        width(remembered: Double(max(minimum, total - pointerX)),
              ideal: ideal, minimum: minimum, total: total)
    }
}

struct SideColumn<Content: View, Panel: View>: View {
    let tokens: VoiceTokens
    /// Whether the panel stands. The host changes this INSIDE an animated
    /// transaction so the column's presence slides + fades.
    let shown: Bool
    /// The `@AppStorage` key the dragged width is remembered under — one
    /// per host; it doubles as the column's coordinate-space name.
    let widthKey: String
    var ideal: CGFloat = 420
    var minimum: CGFloat = 280
    /// A pin's own frame reporter for the divider (the `WorkbenchSeam`
    /// pattern): nil in the app; the DEBUG oracle's seam in a host that
    /// has one. Called with nil when the column closes.
    var onDividerFrame: ((CGRect?) -> Void)? = nil
    @ViewBuilder let content: () -> Content
    @ViewBuilder let panel: () -> Panel

    @AppStorage private var remembered: Double
    @State private var totalWidth: CGFloat = 0

    init(
        tokens: VoiceTokens, shown: Bool, widthKey: String,
        ideal: CGFloat = 420, minimum: CGFloat = 280,
        onDividerFrame: ((CGRect?) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder panel: @escaping () -> Panel
    ) {
        self.tokens = tokens
        self.shown = shown
        self.widthKey = widthKey
        self.ideal = ideal
        self.minimum = minimum
        self.onDividerFrame = onDividerFrame
        self.content = content
        self.panel = panel
        _remembered = AppStorage(wrappedValue: 0, widthKey)
    }

    private var panelWidth: CGFloat {
        SideColumnLayout.width(
            remembered: remembered, ideal: ideal, minimum: minimum, total: totalWidth)
    }

    var body: some View {
        HStack(spacing: 0) {
            content()
                .frame(maxWidth: .infinity)
            if shown {
                divider
                panel()
                    .frame(width: panelWidth)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .coordinateSpace(name: widthKey)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { totalWidth = $0 }
        .onChange(of: shown) { _, now in
            if !now { onDividerFrame?(nil) }
        }
    }

    /// OUR boundary: a 1-pt line in the voice's `line`, drawn in every
    /// window state, carrying the pane row's drag grammar.
    private var divider: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(width: 1)
            .overlay {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 9)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(coordinateSpace: .named(widthKey))
                            .onChanged { value in
                                guard totalWidth > 0 else { return }
                                remembered = Double(SideColumnLayout.draggedWidth(
                                    pointerX: value.location.x, total: totalWidth,
                                    ideal: ideal, minimum: minimum))
                            })
                    .onHover { inside in
                        if inside { NSCursor.resizeLeftRight.push() } else { NSCursor.pop() }
                    }
            }
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(widthKey))
            } action: { frame in
                onDividerFrame?(frame)
            }
            .help("Drag to give the panel more or less room")
    }
}
