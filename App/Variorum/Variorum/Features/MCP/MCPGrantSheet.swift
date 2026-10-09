//
//  MCPGrantSheet.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — THE GRANT SHEET, born with the read rung only (A-9; mockup §3).
//  Three questions, each a sentence: WHERE (a book · a wing), HOW MUCH (U2:
//  read · suggest · write new, each with the mockup's sentence — edit arrives
//  with U3, and a rung the server can't serve isn't offered, P-2), HOW LONG
//  (once · while connected · always). Its confirm says the whole grant in
//  words ("Grant suggest in “the lightning thief” while connected").
//  Opened by Approve… (a connection request — approve and first grant in one
//  act) and Change… (an approved client — one more grant).
//
//  The note scope's face is the note ⋯ menu's (R-13n-4's faces; U2/U3):
//  Settings has no note in hand, so this sheet offers the two scopes it can
//  name honestly.
//

import SwiftUI
import VariorumCore

struct MCPGrantSheet: View {
    let door: MCPDoor
    let target: MCPPane.GrantTarget
    let done: () -> Void

    enum Place: Hashable {
        case book
        case wing
    }

    @State private var place: Place = .book
    @State private var bookID: String?
    @State private var wingID: String = ""
    @State private var duration: MCPGrantRule.Duration = .always
    @State private var rung: MCPGrantRule.Rung = .read
    @State private var choices = MCPDoor.Choices()
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    private var chosenBook: Queries.MCPGrantableBook? {
        choices.books.first { $0.id == bookID }
    }

    private var wingName: String {
        choices.wings.first { $0.id == wingID }?.name ?? Queries.mcpHomeWingName
    }

    /// The grant as chosen, or nil while it is incomplete.
    private var spec: Operations.MCPGrantSpec? {
        switch place {
        case .book:
            guard let book = chosenBook else { return nil }
            return .init(rung: rung, scopeKind: .book, scopeID: book.id, duration: duration)
        case .wing:
            return .init(rung: rung, scopeKind: .wing, scopeID: wingID, duration: duration)
        }
    }

    private var placeName: String {
        switch place {
        case .book: chosenBook?.name ?? ""
        case .wing: wingName
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(MCPPaneCopy.sheetTitle(target.client.name))
                .font(.headline)
                .lineLimit(1)
            Text(MCPPaneCopy.sheetLead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            section(MCPPaneCopy.whereSection)
            Picker(MCPPaneCopy.whereSection, selection: $place) {
                Text(MCPPaneCopy.aBook).tag(Place.book)
                Text(MCPPaneCopy.thisWing).tag(Place.wing)
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
            switch place {
            case .book:
                if choices.books.isEmpty {
                    quiet(MCPPaneCopy.noBooks)
                } else {
                    Picker(MCPPaneCopy.aBook, selection: $bookID) {
                        ForEach(choices.books) { book in
                            Text(bookLabel(book)).tag(Optional(book.id))
                        }
                    }
                    .labelsHidden()
                    quiet(MCPPaneCopy.aBookDetail(chosenBook?.name))
                }
            case .wing:
                Picker(MCPPaneCopy.thisWing, selection: $wingID) {
                    ForEach(choices.wings, id: \.id) { wing in
                        Text(wing.name).tag(wing.id)
                    }
                }
                .labelsHidden()
                quiet(MCPPaneCopy.wingDetail(wingName))
            }

            section(MCPPaneCopy.howMuchSection)
            Picker(MCPPaneCopy.howMuchSection, selection: $rung) {
                ForEach(MCPPaneCopy.offeredRungs, id: \.self) { rung in
                    Text(MCPPaneCopy.rungName(rung)).tag(rung)
                }
            }
            .pickerStyle(.radioGroup)
            .labelsHidden()
            quiet(MCPPaneCopy.rungDetail(rung))
            quiet(MCPPaneCopy.laterRungsNote)

            section(MCPPaneCopy.howLongSection)
            Picker(MCPPaneCopy.howLongSection, selection: $duration) {
                ForEach(Self.durations(connected: target.connected), id: \.self) { duration in
                    Text(MCPPaneCopy.durationWord(duration).capitalizedFirst).tag(duration)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            if !target.connected {
                quiet(MCPPaneCopy.whileConnectedNote)
            }

            HStack {
                Spacer()
                Button(MCPPaneCopy.cancel, action: done)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .keyboardShortcut(.cancelAction)
                Button(MCPPaneCopy.confirm(
                    verb: CapabilityRegistry.capability(.mcpGrantAccess).verb,
                    rung: rung, place: placeName, duration: duration)) {
                    guard let spec else { return }
                    if target.approving {
                        door.approve(target.client.id, granting: spec)
                    } else {
                        door.grant(target.client.id, spec)
                    }
                    done()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(spec == nil)
            }
        }
        .padding(20)
        .frame(width: 520)
        .task {
            choices = await door.choices()
            if bookID == nil { bookID = choices.books.first?.id }
        }
    }

    /// **The durations this sheet may offer** (the U1 walk's fourth
    /// finding — P-2): "while connected" ends when the client's last
    /// connection closes, so it is offered only while the client IS
    /// connected; to a client that is not, it would be a door that cannot
    /// act as named.
    static func durations(connected: Bool) -> [MCPGrantRule.Duration] {
        connected ? MCPGrantRule.Duration.allCases : [.once, .always]
    }

    private func bookLabel(_ book: Queries.MCPGrantableBook) -> String {
        guard !book.wingID.isEmpty,
              let wing = choices.wings.first(where: { $0.id == book.wingID }) else { return book.name }
        return "\(book.name) \u{2014} \(wing.name)"
    }

    private func section(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.top, 4)
    }

    private func quiet(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private extension String {
    /// "while connected" → "While connected" (a segmented control's label;
    /// sentence case — her rule).
    var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
