//
//  WingSwitcherSheet.swift
//  Variorum (MAC ONLY) — Core/Views (composed by the window — `RootView` — for
//  ⌘L; the Bookcase and the Library mastheads cycle through the same brain)
//
//  13n-c U4 — ⌘L, THE WING SWITCHER's face (VX-157; VX-157; mockup §6's
//  option A drawn with her ratified chord). The ⌘K palette's idiom — a sheet
//  over the window with a field that has the keyboard, the rows under it —
//  because ⌘L is app-wide and must open wherever she is (a masthead popover
//  would need the masthead on screen). Fast by construction: the rows are the
//  live wings already held by the window's `WingsModel` (no read at open, no
//  counts — a per-wing note count would scale with the corpus, P1).
//
//  The keys the field cannot see — another L while ⌘ is held, ⌘'s release,
//  Esc — come through ONE local key monitor scoped to the sheet's own window
//  (`WingSwitcherKeyCatcher`, the `PageTurnKeys` / `CommentsPanel` shape); it
//  CONSUMES the held-⌘ L so the menu's ⌘L never fires twice, and only
//  observes ⌘'s release. Every decision is the pure brain's
//  (`WingSwitcherBrain`). A wing row carries its pending-ask glyph; pressed
//  here, the ask's sheet opens OVER the switcher (a sheet already up — the
//  T-U3-7 nested-host precedent), and the switcher stays.
//

import AppKit
import Observation
import SwiftUI

/// One open switcher (per window, per ⌘L) — the brain and the act.
@MainActor
@Observable
final class WingSwitcherModel: Identifiable {
    let id = UUID()
    private(set) var brain: WingSwitcherBrain
    @ObservationIgnored let wings: WingsModel

    init(wings: WingsModel) {
        self.wings = wings
        brain = WingSwitcherBrain(rows: wings.switcherRows, currentID: wings.currentID)
    }

    func type(_ text: String) { brain.type(text) }
    func tapL() { brain.tapL() }
    func move(by delta: Int) { brain.move(by: delta) }

    /// Act on an outcome — a commit switches and SPEAKS ("Now in …"). Returns
    /// whether the switcher should close.
    @discardableResult
    func apply(_ outcome: WingSwitcherBrain.Outcome) -> Bool {
        switch outcome {
        case .stay: return false
        case .close: return true
        case .commit(let id):
            wings.switchSaying(id)
            return true
        }
    }
}

/// The keys only a monitor can see while the switcher is up — their pure
/// classification (pinned) and the monitor that delivers them.
nonisolated enum WingSwitcherKeys {
    nonisolated enum Key: Equatable, Sendable {
        /// ⌘ held, L tapped (no other modifier).
        case tapL
        /// ⌘ released.
        case commandUp
        /// Esc.
        case escape
    }

    /// Pure, so the pins classify synthesized keys without a window.
    static func classify(
        type: NSEvent.EventType, characters: String?, keyCode: UInt16, flags: NSEvent.ModifierFlags
    ) -> Key? {
        let held = flags.intersection([.command, .option, .control, .shift])
        switch type {
        case .keyDown:
            if keyCode == 53 { return .escape }
            if held == .command, characters?.lowercased() == "l" { return .tapL }
            return nil
        case .flagsChanged:
            return held.contains(.command) ? nil : .commandUp
        default:
            return nil
        }
    }

    /// Whether a key the switcher saw is CONSUMED: only one it acted on, and
    /// never ⌘'s release (observed, always passed on).
    static func consumes(_ key: Key, acted: Bool) -> Bool {
        acted && key != .commandUp
    }

    /// **VX-281 ladder R1-2 — what Esc does while the switcher is up.**
    nonisolated enum EscapeAct: Equatable, Sendable {
        /// A row's reach popover is up: it goes, the switcher stays.
        case dismissRowPopover
        /// Nothing over the rows: the switcher closes (as it always has).
        case closeSwitcher
    }

    /// Esc takes the topmost thing first — macOS's own rule, and this
    /// sheet's precedent (an ask's sheet over it keeps its own Esc): a row's
    /// reach popover goes and the switcher stays (her typed filter with it);
    /// with nothing over the rows, Esc closes the switcher. Decided from what
    /// the sheet KNOWS is up, never from which window happens to be key (the
    /// popover holds plain buttons and the field keeps focus, so the sheet's
    /// window hears the Esc — U2's walk saw it close the switcher).
    static func escape(rowPopoverShown: Bool) -> EscapeAct {
        rowPopoverShown ? .dismissRowPopover : .closeSwitcher
    }

    /// The monitor's ONE road from a real event to a key (13n-c held walks
    /// D-W4 — pinned with real NSEvents). A flagsChanged event has NO
    /// characters: reading `charactersIgnoringModifiers` on one RAISES, and
    /// the event loop swallowed that throw — so ⌘'s release never reached the
    /// switcher and the held cycle never committed. Characters are read for a
    /// keyDown only.
    static func key(for event: NSEvent) -> Key? {
        classify(
            type: event.type,
            characters: event.type == .keyDown ? event.charactersIgnoringModifiers : nil,
            keyCode: event.keyCode, flags: event.modifierFlags)
    }
}

/// **The switcher's key catcher** — the `PageTurnKeys` / `CommentsPanel`
/// shape: a hit-test-transparent view whose local monitor lives exactly as
/// long as it is in a window and answers ONLY events of ITS window (the
/// switcher's sheet). So an ask's sheet opened over the switcher (another
/// window) keeps its own keys — its Esc is its Don't allow — and no other
/// window's keys are ever the switcher's. The handler says whether it ACTED;
/// only an acted-on ⌘L or Esc is consumed (the menu's ⌘L must not fire
/// twice), and ⌘'s release is always passed on.
struct WingSwitcherKeyCatcher: NSViewRepresentable {
    let onKey: (WingSwitcherKeys.Key) -> Bool

    func makeNSView(context: Context) -> CatcherView {
        let view = CatcherView()
        view.onKey = onKey
        return view
    }

    func updateNSView(_ view: CatcherView, context: Context) {
        view.onKey = onKey
    }

    final class CatcherView: NSView {
        var onKey: ((WingSwitcherKeys.Key) -> Bool)?
        private var monitor: Any?

        /// Never a click target — the switcher above it keeps every click.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
                guard let self, let window = self.window, event.window === window,
                      let key = WingSwitcherKeys.key(for: event)
                else { return event }
                let acted = self.onKey?(key) ?? false
                return WingSwitcherKeys.consumes(key, acted: acted) ? nil : event
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` — called then with a nil window — removes the
        // monitor; the `PageTurnKeys` note, same reason.)
    }
}

struct WingSwitcherSheet: View {
    /// P-1: the rows switch (the `.switchWing` act's surface face) and carry
    /// the pending-ask glyph.
    static let surfaceCapabilities: [CapabilityID] = [.switchWing] + MCPAskGlyph.surfaceCapabilities
        // VX-268: a wing row's ONE shared icon and its popover's doors.
        + MCPSharedIcon.surfaceCapabilities

    let model: WingSwitcherModel
    let tokens: VoiceTokens
    let close: () -> Void
    @Environment(\.mcpShareRoad) private var road
    @Environment(\.mcpAskBoard) private var board
    @FocusState private var fieldFocused: Bool
    /// An ask opened from a row's glyph — presented OVER the switcher.
    @State private var nestedAsk: MCPAskOpening?
    /// VX-268: THE grant sheet a row's shared icon opened (its popover's
    /// Change…) — presented OVER the switcher, the nested ask's twin.
    @State private var nestedGrant: MCPGrantOpening?
    /// VX-281 ladder R1-2: the row whose reach popover is up — so Esc takes
    /// the popover before the switcher (`WingSwitcherKeys.escape`).
    @State private var popoverRow: String?

    var body: some View {
        VStack(spacing: 0) {
            TextField(tokens.chromeLabel(WingCopy.switcherPrompt), text: Binding(
                get: { model.brain.query }, set: { model.type($0) }))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .padding(12)
                .focused($fieldFocused)
                .onKeyPress(.downArrow) {
                    model.move(by: 1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    model.move(by: -1)
                    return .handled
                }
                .onSubmit { act(model.brain.returnPressed()) }
            Divider().overlay(tokens.line)
            rows
            Divider().overlay(tokens.line)
            VStack(alignment: .leading, spacing: 3) {
                Text(tokens.chromeLabel(WingCopy.switcherFoot(current: currentName)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                // Round 5: wings are separate libraries — but Snippets is the
                // one room they all share, said where she switches.
                Text(tokens.chromeLabel(WingCopy.snippetsShared))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
        }
        .frame(width: 440)
        .background(tokens.card)
        // A row's ask opens HERE (the switcher is a sheet already up).
        // W-UX-1: the RAISE her press opened, never the bare id. VX-268: so
        // does a row's Change… (THE grant sheet, over the switcher).
        .environment(\.mcpShareRoad, road?
            .answeringAsks { nestedAsk = board.opening($0) }
            .openingHere { nestedGrant = $0 })
        .sheet(item: Binding(
            get: { nestedAsk.flatMap { board.waits($0) ? $0 : nil } },
            set: { if $0 == nil { nestedAsk = nil } })
        ) { opening in
            road?.askSheet(opening)
        }
        .task { fieldFocused = true }
        // The keys only a monitor sees (held-⌘ L, ⌘'s release, Esc) — this
        // sheet's window's only; an ask's sheet over it is another window.
        .background(WingSwitcherKeyCatcher { key in
            switch key {
            case .tapL:
                model.tapL()
                return true
            case .commandUp:
                act(model.brain.commandReleased())
                return false
            case .escape:
                switch WingSwitcherKeys.escape(rowPopoverShown: popoverRow != nil) {
                case .dismissRowPopover: popoverRow = nil
                case .closeSwitcher: close()
                }
                return true
            }
        })
    }

    private var currentName: String {
        model.brain.rows.first { $0.id == model.brain.currentID }?.name ?? WingWords.home
    }

    private func act(_ outcome: WingSwitcherBrain.Outcome) {
        if model.apply(outcome) { close() }
    }

    private var rows: some View {
        rowsList
            // VX-268: a row's Change… opens THE grant sheet over the switcher
            // (on the rows, beside the ask's sheet on the stack — one
            // presenter per view).
            .sheet(item: $nestedGrant) { opening in
                road?.sheet(opening) { nestedGrant = nil }
            }
    }

    private var rowsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                let visible = model.brain.visible
                if visible.isEmpty {
                    Text(tokens.chromeLabel(WingCopy.noWingMatches))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                ForEach(visible) { row in
                    rowView(row, highlighted: row.id == model.brain.highlight)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(minHeight: 120, maxHeight: 300)
    }

    private func rowView(_ row: WingSwitcherBrain.Row, highlighted: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            // The palette's › marker rides the highlight (13b 3E's grammar).
            Text(highlighted ? tokens.selectionMarker.trimmingCharacters(in: .whitespaces) : " ")
                .font(tokens.body.weight(.bold))
                .foregroundStyle(tokens.accent)
                .frame(width: 10)
            Text(row.name)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if row.id == model.brain.currentID {
                Text(tokens.chromeLabel(WingCopy.currentMark))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            // VX-268: the ONE shared icon — a wing grant on it, or the open
            // book (`WingsModel.reach`, decideWing's read) — then a waiting
            // ask. Each its own button: the row's pick never fires for them.
            // VX-281 R1-2: the sheet holds which row's popover is up (its Esc).
            MCPSharedIcon(
                reaches: model.wings.reach[row.id] ?? [], tokens: tokens,
                isPresented: Binding(
                    get: { popoverRow == row.id },
                    set: { up in
                        if up {
                            popoverRow = row.id
                        } else if popoverRow == row.id {
                            popoverRow = nil
                        }
                    }))
            MCPAskGlyph(.wing(row.id), tokens: tokens)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(highlighted ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear))
        .contentShape(Rectangle())
        .onTapGesture { act(model.brain.pick(row.id)) }
    }
}
