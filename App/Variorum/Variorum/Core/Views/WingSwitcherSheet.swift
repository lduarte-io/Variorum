//
//  WingSwitcherSheet.swift
//  Variorum (MAC ONLY) — Core/Views (composed by the window — `RootView` — for
//  ⌘L; the Bookcase and the Library mastheads cycle through the same brain)
//
//  13n-c U4 — ⌘L, THE WING SWITCHER's face (R-AIR-15; VX-157; mockup §6's
//  option A drawn with her ratified chord). The ⌘K palette's idiom — a sheet
//  over the window with a field that has the keyboard, the rows under it —
//  because ⌘L is app-wide and must open wherever she is (a masthead popover
//  would need the masthead on screen). Fast by construction: the rows are the
//  live wings already held by the window's `WingsModel` (no read at open, no
//  counts — a per-wing note count would scale with the corpus, P1).
//
//  The keys the field cannot see — another L while ⌘ is held, ⌘'s release,
//  Esc — come through ONE local key monitor that lives exactly as long as the
//  sheet (`WingSwitcherKeys`, the `PageTurnKeys` / `CommentsPanel` shape); it
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

/// The keys only a monitor can see while the switcher is up.
@MainActor
final class WingSwitcherKeys {
    nonisolated enum Key: Equatable, Sendable {
        /// ⌘ held, L tapped (no other modifier).
        case tapL
        /// ⌘ released.
        case commandUp
        /// Esc.
        case escape
    }

    private var monitor: Any?

    /// Pure, so the pins classify synthesized keys without a window.
    nonisolated static func classify(
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

    func start(_ handle: @escaping (Key) -> Void) {
        stop()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            guard let key = Self.classify(
                type: event.type, characters: event.charactersIgnoringModifiers,
                keyCode: event.keyCode, flags: event.modifierFlags)
            else { return event }
            handle(key)
            // The held-⌘ L and Esc are the switcher's (the menu's ⌘L must not
            // fire again); ⌘'s release is only observed.
            return key == .commandUp ? event : nil
        }
    }

    func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
    }
}

struct WingSwitcherSheet: View {
    /// P-1: the rows switch (the `.switchWing` act's surface face) and carry
    /// the pending-ask glyph.
    static let surfaceCapabilities: [CapabilityID] = [.switchWing] + MCPAskGlyph.surfaceCapabilities

    let model: WingSwitcherModel
    let tokens: VoiceTokens
    let close: () -> Void
    @Environment(\.mcpShareRoad) private var road
    @Environment(\.mcpAskBoard) private var board
    @FocusState private var fieldFocused: Bool
    @State private var keys = WingSwitcherKeys()
    /// An ask opened from a row's glyph — presented OVER the switcher.
    @State private var nestedAsk: String?

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
        .environment(\.mcpShareRoad, road?.answeringAsks { nestedAsk = $0 })
        .sheet(item: Binding(
            get: { nestedAsk.flatMap { board.contains($0) ? NestedAsk(id: $0) : nil } },
            set: { if $0 == nil { nestedAsk = nil } })
        ) { ask in
            road?.askSheet(ask.id)
        }
        .task { fieldFocused = true }
        .onAppear {
            keys.start { key in
                // An ask's sheet over the switcher has the keyboard.
                guard nestedAsk == nil else { return }
                switch key {
                case .tapL: model.tapL()
                case .commandUp: act(model.brain.commandReleased())
                case .escape: close()
                }
            }
        }
        .onDisappear { keys.stop() }
    }

    private struct NestedAsk: Identifiable {
        let id: String
    }

    private var currentName: String {
        model.brain.rows.first { $0.id == model.brain.currentID }?.name ?? WingWords.home
    }

    private func act(_ outcome: WingSwitcherBrain.Outcome) {
        if model.apply(outcome) { close() }
    }

    private var rows: some View {
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
