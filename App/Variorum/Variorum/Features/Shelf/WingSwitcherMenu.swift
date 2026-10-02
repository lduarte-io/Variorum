//
//  WingSwitcherMenu.swift
//  Variorum
//
//  13i-d U5 — THE WING SWITCHER (the sitting record §21: Direction C, "the
//  right shape for the WING switcher" — her sketch, 2026-08-25: "what library
//  you're in … right above the shelf, with a drop down selector"). The
//  Bookcase masthead reads "Bookcase · Home ▾"; the menu lists the wings —
//  Home first, then the switcher order — the current one CHECKED (an inline
//  picker: the native checkmark, U3's W-1 lesson), then New Wing…, and for an
//  additional wing Rename Wing… / Delete Wing… (Home is virtual — never
//  renamed, never deleted, R-13ia-2). Drawn ALWAYS so New Wing… has a home
//  (PROVISIONAL P-13id-U5-6 — the alternative hides the switcher until a
//  second wing exists and moves New Wing… to the menu bar).
//
//  §22's caution binds: the SHAPE is the mockup's, the type, ink and spacing
//  are the voice's own.
//

import SwiftUI
import VariorumCore

struct WingSwitcherMenu: View {
    let tokens: VoiceTokens
    let wings: WingsModel

    /// P-1: the switcher's three acts (the switch itself is a view choice —
    /// undeclared, the Library `sort ▾` precedent).
    static let surfaceCapabilities: [CapabilityID] = [.newWing, .renameWing, .deleteWing]

    @State private var newPresented = false
    @State private var renamePresented = false
    @State private var deletePresented = false
    @State private var field = ""

    var body: some View {
        let current = wings.currentID
        let name = wings.currentName
        Menu {
            Picker(selection: Binding(
                get: { wings.currentID },
                set: { wings.switchTo($0) })
            ) {
                ForEach(wings.rows) { row in
                    Text(row.name).tag(row.id)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.inline)
            Divider()
            Button(CapabilityRegistry.capability(.newWing).verb) {
                field = ""
                newPresented = true
            }
            if !current.isEmpty {
                Button(CapabilityRegistry.capability(.renameWing).verb) {
                    field = name
                    renamePresented = true
                }
                Button(CapabilityRegistry.capability(.deleteWing).verb) {
                    Task { if await wings.deleteAsk(current) { deletePresented = true } }
                }
            }
        } label: {
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
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        // P-8: a `fixedSize` chrome label states its line policy.
        .lineLimit(1)
        .fixedSize()
        .help("Which library you're in \u{2014} each wing is a separate library")
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
        .alert(WingCopy.deleteTitle(name), isPresented: $deletePresented) {
            Button("Delete Wing", role: .destructive) {
                Task { await wings.delete(current) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(WingCopy.deleteMessage)
        }
    }
}
