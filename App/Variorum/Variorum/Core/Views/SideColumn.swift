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
//  divider carries the app's ONE seam grammar (`SeamGrip`, `Core/Views`:
//  a 14-pt grip centred on the line, `.pointerStyle(.columnResize)` —
//  ledger row 9's shape; it was born as a copy of `WorkbenchSeam`'s 9-pt
//  overlay at batch C, which the round-end Fable pass converted last), so
//  the room the inspector used to let her drag is still hers; the width
//  she chooses is remembered per host. The column's presence slides + fades (E's
//  precedent), which needs the HOST to change `shown` inside an animated
//  transaction (E's burst lesson: a container-level `.animation(value:)`
//  does not carry a transition through an `@Observable`/`@State` change).
//
//  **THE LEADING EDGE (18d batch 3, her U-13** — *"the chapters feel too
//  tightly clustered and the panel with the chapter names should also be
//  draggable to be a bit bigger"* · *"table of contents in read mode for a
//  note is horizontally limited and not changable, should be adjustable"*).
//  Two more hosts wanted this column on the OTHER side — the book's
//  navigator and the note Read tab's contents column, both fixed-width
//  slabs until now. It is ONE component with an `edge`, not a second
//  struct: everything that makes this column what it is (our own divider in
//  every window state, `SeamGrip`'s 14-pt grip and resize pointer, the
//  remembered width, the geometry read, the transition) is edge-independent, and a
//  copy of it would be two things to keep in step for the sake of one
//  `if`. What DOES mirror is the DRAG ARITHMETIC, and it mirrors inside the
//  one width brain (`SideColumnLayout.draggedWidthFromLeading`) where the
//  pin can hold the two halves against each other.
//

import SwiftUI

/// The width rule, pure (pinned): the remembered width when she has
/// dragged one, else the ideal — clamped to the minimum, the maximum, and
/// the room that leaves the host's content its own floor.
nonisolated enum SideColumnLayout {
    /// What the host's content keeps beside the panel, whatever is dragged.
    static let contentMinimum: CGFloat = 320
    static let maximum: CGFloat = 640

    /// The ceiling a host may LOWER (18d batch 3): the note's panels want
    /// the 640 above; the book's navigator wants ~360, because a chapter
    /// list dragged half the window wide is not a chapter list. The default
    /// is the shared ceiling, so every caller written before this reads
    /// exactly as it did.
    static func width(
        remembered: Double, ideal: CGFloat, minimum: CGFloat, total: CGFloat,
        maximum: CGFloat = SideColumnLayout.maximum
    ) -> CGFloat {
        let wanted = remembered > 0 ? CGFloat(remembered) : ideal
        // Unmeasured (the first pass): what was asked for — inside the
        // host's own floor and ceiling. Only the ROOM is unknown before the
        // first geometry read, and a column whose remembered width is wider
        // than its host allows should not be that width even for one frame
        // (the navigator's ceiling is 280 pt below the shared one, so the
        // flash would be visible). The four measured cases are unchanged,
        // and so are the two unmeasured ones the shipped pin asserts —
        // 420 is inside [280, 640] whichever way it is clamped.
        guard total > 0 else { return min(max(wanted, minimum), maximum) }
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
        pointerX: CGFloat, total: CGFloat, ideal: CGFloat, minimum: CGFloat,
        maximum: CGFloat = SideColumnLayout.maximum
    ) -> CGFloat {
        width(remembered: Double(max(minimum, total - pointerX)),
              ideal: ideal, minimum: minimum, total: total, maximum: maximum)
    }

    /// **THE MIRROR (18d batch 3, her U-13).** A LEADING-edge panel's drag:
    /// the pointer's x IS the panel's width — the room LEFT of it — where
    /// the trailing column takes the room right of it. Everything else is
    /// the same rule, R1-7's floor included: a pointer dragged past the
    /// window's LEADING edge proposes ≤ 0, which `width` would read as
    /// "nothing remembered" and answer with the IDEAL, so a column being
    /// dragged narrow would snap WIDE the moment the pointer crossed the
    /// edge — the exact defect R1-7 fixed on the other side, and the reason
    /// the mirror lives in this brain rather than at a call site.
    ///
    /// The pin holds the two halves against each other
    /// (`OutlineRoomTests.theLeadingDragMirrorsTheTrailingOneAboutTheColumn`):
    /// for every pointer x, leading(x) == trailing(total − x).
    static func draggedWidthFromLeading(
        pointerX: CGFloat, total: CGFloat, ideal: CGFloat, minimum: CGFloat,
        maximum: CGFloat = SideColumnLayout.maximum
    ) -> CGFloat {
        width(remembered: Double(max(minimum, pointerX)),
              ideal: ideal, minimum: minimum, total: total, maximum: maximum)
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
    /// **WHAT this column is showing** — the book's or note's id. It is not
    /// storage and not layout: it is the DEBUG seam oracle's key, and it is
    /// required rather than defaulted so a new host has to name its subject
    /// instead of silently shipping the hole round 2's MINOR-2 found
    /// (`widthKey` alone is a per-host constant, so every navigator in every
    /// parallel suite wrote the same entry). A host that genuinely has one
    /// instance passes a stable name of its own.
    let subjectKey: String
    /// Which side the panel stands on. `.trailing` is the note's and the
    /// scraps area's (row 74's original); `.leading` is the book navigator's
    /// and the note Read tab's contents column (18d batch 3, U-13). The
    /// content slot is always the host's own body, whichever side it is on.
    var edge: HorizontalEdge = .trailing
    var ideal: CGFloat = 420
    var minimum: CGFloat = 280
    /// The ceiling — the width brain's shared 640 unless a host lowers it.
    var maximum: CGFloat = SideColumnLayout.maximum
    /// A pin's own frame reporter for the divider (the `WorkbenchSeam`
    /// pattern): nil in the app; the DEBUG oracle's seam in a host that
    /// has one. Called with nil when the column closes.
    var onDividerFrame: ((CGRect?) -> Void)? = nil
    @ViewBuilder let content: () -> Content
    @ViewBuilder let panel: () -> Panel

    @AppStorage private var remembered: Double
    @State private var totalWidth: CGFloat = 0
    #if DEBUG
    /// **This column's own name in the DEBUG seam oracle** (18k UNIT C4 —
    /// the `MastheadStamp.oracleOwner` shape): the same note or book open in
    /// two windows is two columns on ONE `SeamGeometry` key, so each seam
    /// registers as itself and takes only its own rectangles with it.
    @State private var oracleOwner = UUID()
    #endif

    init(
        tokens: VoiceTokens, shown: Bool, widthKey: String, subjectKey: String,
        edge: HorizontalEdge = .trailing,
        ideal: CGFloat = 420, minimum: CGFloat = 280,
        maximum: CGFloat = SideColumnLayout.maximum,
        onDividerFrame: ((CGRect?) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder panel: @escaping () -> Panel
    ) {
        self.tokens = tokens
        self.shown = shown
        self.widthKey = widthKey
        self.subjectKey = subjectKey
        self.edge = edge
        self.ideal = ideal
        self.minimum = minimum
        self.maximum = maximum
        self.onDividerFrame = onDividerFrame
        self.content = content
        self.panel = panel
        _remembered = AppStorage(wrappedValue: 0, widthKey)
    }

    private var panelWidth: CGFloat {
        SideColumnLayout.width(
            remembered: remembered, ideal: ideal, minimum: minimum,
            total: totalWidth, maximum: maximum)
    }

    var body: some View {
        HStack(spacing: 0) {
            if edge == .leading, shown {
                sidePanel
                // Row 9's part (2), and it is not optional on this edge: in
                // an HStack later siblings sit above earlier ones, so
                // without this the CONTENT (the prose column in Outline, the
                // page in Read) wins every point right of the line and the
                // half of the grip that overhangs into it is dead — the
                // exact half that made a press "miss the grip" in 18d batch
                // 3's own walk.
                divider.zIndex(1)
            }
            // 18d batch 1's lesson, restated because the leading edge makes
            // it easy to lose: a host whose content claims a MEASURE by
            // `layoutPriority` does so INSIDE its own body (Outline's prose
            // column beside its click-out margins). This slot only says
            // "take the rest"; it never re-wraps the host's content in a
            // container of its own, so the priority inside still decides.
            content()
                .frame(maxWidth: .infinity)
            if edge == .trailing, shown {
                // The mirror: here it is the PANEL that is drawn after the
                // seam and would take the grip's right half.
                divider.zIndex(1)
                sidePanel
            }
        }
        .coordinateSpace(name: widthKey)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { totalWidth = $0 }
        #if DEBUG
        .onDisappear { SeamGeometry.release(owner: oracleOwner) }
        #endif
        .onChange(of: shown) { _, now in
            if !now { onDividerFrame?(nil) }
        }
    }

    /// The panel at its remembered, clamped width — sliding in from its own
    /// side (E's precedent; the host animates the `shown` change).
    private var sidePanel: some View {
        panel()
            .frame(width: panelWidth)
            .transition(
                .move(edge: edge == .leading ? .leading : .trailing)
                    .combined(with: .opacity))
    }

    /// OUR boundary: the shared seam (`SeamGrip`, `Core/Views`) — a 1-pt
    /// line in the voice's `line`, drawn in every window state, with row
    /// 9's 14-pt grip and its `.pointerStyle` cursor over it.
    ///
    /// **18d's ladder, MAJOR-2.** This used to be a 9-pt `Rectangle` in an
    /// `.overlay` with `NSCursor.push()` on `.onHover` — ledger row 9's
    /// exact shape, which 17o batch d had already fixed for the shell's seam
    /// and which batch 3 then put on three more boundaries (the book
    /// navigator, the book Index's chapter panel, the note Read contents
    /// column) at the moment her U-13 asked for those boundaries to be
    /// draggable. The fix is not copied here: the seam is ONE component both
    /// hosts consume, so no future seam can be born with the old defect.
    private var divider: some View {
        SeamGrip(
            tokens: tokens,
            space: widthKey,
            onDrag: { location in
                guard totalWidth > 0 else { return }
                // The one width brain, either side (18d batch 3).
                remembered = Double(
                    edge == .leading
                        ? SideColumnLayout.draggedWidthFromLeading(
                            pointerX: location.x, total: totalWidth,
                            ideal: ideal, minimum: minimum, maximum: maximum)
                        : SideColumnLayout.draggedWidth(
                            pointerX: location.x, total: totalWidth,
                            ideal: ideal, minimum: minimum, maximum: maximum))
            },
            help: "Drag to give the panel more or less room",
            frameSpace: .named(widthKey),
            onLineFrame: { frame in
                onDividerFrame?(frame)
                #if DEBUG
                SeamGeometry.recordLine(
                    SeamGeometry.key(widthKey, subject: subjectKey), frame, owner: oracleOwner)
                #endif
            },
            onGripFrame: { frame in
                #if DEBUG
                SeamGeometry.recordGrip(
                    SeamGeometry.key(widthKey, subject: subjectKey), frame, owner: oracleOwner)
                #endif
            })
    }
}
