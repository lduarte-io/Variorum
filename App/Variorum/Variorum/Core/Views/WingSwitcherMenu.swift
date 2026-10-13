//
//  WingSwitcherMenu.swift
//  Variorum — Core/Views (since 13n-c U4: the Bookcase AND the Library
//  mastheads render it — a view two features consume lives in the shared
//  home, CLAUDE.md)
//
//  13i-d U5 — THE WING SWITCHER (the sitting record §21: Direction C, "the
//  right shape for the WING switcher" — her sketch, 2026-08-25: "what library
//  you're in … right above the shelf, with a drop down selector"). The
//  masthead reads "Bookcase · Home ▾"; the menu lists the wings — Home first,
//  then the switcher order — the current one CHECKED (an inline picker: the
//  native checkmark, U3's W-1 lesson), then New Wing…, and for an additional
//  wing Rename Wing… / Delete Wing… (Home is virtual — never renamed, never
//  deleted, R-13ia-2). Drawn ALWAYS so New Wing… has a home (PROVISIONAL
//  P-13id-U5-6 — the alternative hides the switcher until a second wing
//  exists and moves New Wing… to the menu bar).
//
//  13n-c U4 — FAST TO CLICK (her VX-157: "type to filter; click-without-typing
//  CYCLES; fast to click — fast navigation is important"; VX-157: "the
//  masthead switcher clicked without typing also cycles"; round 5: "the wing
//  switcher must be reachable from the LIBRARY pane"):
//  · with TWO OR MORE wings the masthead's wing WORD is a button that CYCLES
//    to the next wing (wrapping) and says so ("Now in …"); the ▾ beside it is
//    the menu — the list and every wing act (New / Rename / Move Everything /
//    Delete), so nothing that was reachable stopped being reachable;
//  · with ONE wing there is nothing to cycle to, so the word is no cycle door
//    (P-2) — the whole "· Home ▾" opens the menu, exactly as before;
//  · ⌘L is the typed road (`WingSwitcherSheet`); the cycling word's hover
//    names it (a greyed "Switch Wing… ⌘L" row in the menu read as a dead
//    door, so the menu carries none);
//  · the menu carries ONE quiet line: Snippets is the one room every wing
//    shares (round 5 — the wing-isolation UI says so);
//  · a waiting WING ask shows its pending glyph beside the word (every wing's
//    — the word is the door to them all) and on that wing's row in the list.
//
//  §22's caution binds: the SHAPE is the mockup's, the type, ink and spacing
//  are the voice's own.
//

import SwiftUI
import VariorumCore

struct WingSwitcherMenu: View {
    let tokens: VoiceTokens
    let wings: WingsModel

    /// P-1: the switcher's acts (the in-menu PICK stays a view choice —
    /// undeclared, the Library `sort ▾` precedent — while the word's cycling
    /// click is `.switchWing`'s `.surface` door, 13n-c U4), and the wing asks'
    /// pending glyph.
    static let surfaceCapabilities: [CapabilityID] = [
        .newWing, .renameWing, .deleteWing,
        // 13i-d U5b — her R-13id-4 backdoor (R-13id-6 item 9): additional
        // wings only, so the daily Journal's Home is never its source.
        .moveWingContents,
        // 13n-c U4: the word's cycling click (VX-157).
        .switchWing,
    ] + MCPAskGlyph.surfaceCapabilities

    /// 13i-d U5b — which of the CURRENT wing's acts the menu draws (DATA,
    /// P-1/P-2, pinned): none on Home — virtual, never renamed or deleted,
    /// and never the bulk move's source (it holds the daily Journal, R-13id-6
    /// item 7) — and all three on an additional wing.
    static func currentWingActs(_ currentID: String) -> [CapabilityID] {
        currentID.isEmpty ? [] : [.renameWing, .moveWingContents, .deleteWing]
    }

    @Environment(\.mcpAskBoard) private var asks
    @State private var newPresented = false
    @State private var renamePresented = false
    @State private var deletePresented = false
    @State private var field = ""
    /// 13i-d U5b — the bulk move's confirm (its item IS the act's preview).
    @State private var contentsAsk: WingsModel.ContentsMoveAsk?

    var body: some View {
        let current = wings.currentID
        let name = wings.currentName
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            if let next = wings.nextWing {
                // TWO OR MORE wings: the word CYCLES, the ▾ is the menu.
                Text("\u{00B7}")
                    .font(tokens.heading)
                    .foregroundStyle(tokens.faint)
                Button {
                    wings.cycle()
                } label: {
                    Text(tokens.chromeLabel(name))
                        .font(tokens.heading)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help(WingCopy.cycleHelp(next: next.name))
                .accessibilityHint(WingCopy.cycleHelp(next: next.name))
                MCPAskGlyph(.anyWing, tokens: tokens)
                menu(current: current, name: name) {
                    Text("\u{25BE}")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        // A real target to hit, not a 7 pt glyph (her "fast
                        // to click").
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .contentShape(Rectangle())
                }
                .help(WingCopy.menuDoorHelp)
            } else {
                // ONE wing: nothing to cycle to — the whole label is the menu.
                menu(current: current, name: name) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\u{00B7}")
                            .foregroundStyle(tokens.faint)
                        Text(tokens.chromeLabel(name))
                            .foregroundStyle(tokens.ink)
                        Text("\u{25BE}")
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                    }
                    .font(tokens.heading)
                    .lineLimit(1)
                }
                .help("Which library you're in \u{2014} each wing is a separate library")
                MCPAskGlyph(.anyWing, tokens: tokens)
            }
        }
        // P-8: a `fixedSize` chrome label states its line policy.
        .lineLimit(1)
        .fixedSize()
        .alert(WingCopy.newWingTitle, isPresented: $newPresented) {
            TextField("Name", text: $field)
            Button("Make Wing") {
                let typed = field
                Task { await wings.mint(named: typed) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(WingWords.lesson)
        }
        .alert(WingCopy.renameWingTitle, isPresented: $renamePresented) {
            TextField("Name", text: $field)
            Button("Rename") {
                let typed = field
                Task { await wings.rename(current, to: typed) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .wingContentsMoveConfirm($contentsAsk, wings: wings)
        .alert(WingCopy.deleteTitle(name), isPresented: $deletePresented) {
            Button("Delete Wing", role: .destructive) {
                Task { await wings.delete(current) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(WingCopy.deleteMessage)
        }
    }

    /// The menu — the list and every wing act — behind whichever label the
    /// masthead draws.
    private func menu<MenuLabel: View>(
        current: String, name: String, @ViewBuilder label: () -> MenuLabel
    ) -> some View {
        Menu {
            Picker(selection: Binding(
                get: { wings.currentID },
                set: { wings.switchTo($0) })
            ) {
                ForEach(wings.rows) { row in
                    // 13n-c U4: a wing an ask waits on wears its pending glyph
                    // here too (the glyph's press road is the masthead word's,
                    // ⌘L's row and Settings ▸ MCP ▸ Waiting — a menu row's
                    // press switches the wing, as it always has).
                    if asks.asks(.wing(row.id)).isEmpty {
                        Text(row.name).tag(row.id)
                    } else {
                        Label(row.name, systemImage: MCPSharedIcon.pendingSymbol).tag(row.id)
                    }
                }
            } label: {
                // 13i-d U6 (b): the list's own header says what a wing is.
                Text(WingCopy.switcherHeader)
            }
            .pickerStyle(.inline)
            // Round 5: the one shared room, said where she switches.
            Text(WingCopy.snippetsShared)
            Divider()
            Button(CapabilityRegistry.capability(.newWing).verb) {
                field = ""
                newPresented = true
            }
            let acts = Self.currentWingActs(current)
            if acts.contains(.renameWing) {
                Button(CapabilityRegistry.capability(.renameWing).verb) {
                    field = name
                    renamePresented = true
                }
            }
            if acts.contains(.moveWingContents) {
                // 13i-d U5b — MOVE EVERYTHING TO ANOTHER WING ▸ (her R-13id-4
                // backdoor: empty the wing in one act, then Delete succeeds).
                // Any other live wing, Home first; the confirm counts.
                Menu(CapabilityRegistry.capability(.moveWingContents).verb) {
                    ForEach(wings.destinations(from: current)) { row in
                        Button(row.name) {
                            Task { contentsAsk = await wings.contentsMoveAsk(to: row.id) }
                        }
                    }
                }
            }
            if acts.contains(.deleteWing) {
                Button(CapabilityRegistry.capability(.deleteWing).verb) {
                    Task { if await wings.deleteAsk(current) { deletePresented = true } }
                }
            }
        } label: {
            label()
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
    }
}
