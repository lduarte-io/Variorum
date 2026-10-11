//
//  MCPGrantSheet.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — THE GRANT SHEET, born with the read rung only (A-9; mockup §3).
//  Three questions, each a sentence: WHERE, HOW MUCH (read · suggest · write
//  new · edit — each with the mockup's sentence; a rung the server couldn't
//  serve was never offered, P-2), HOW LONG (once · while connected · always).
//  Its confirm says the whole grant in words ("Grant suggest in “the
//  lightning thief” while connected, including to future entries").
//
//  13n-c U2 — REBUILT FOR A LIBRARY OF HUNDREDS (VX-156 items 1 + 6; her
//  kickoff; the approved mockup §1/§1b; the brief §1/§2):
//  - WHERE is "A note · A book · A wing", every place chosen with the ONE
//    picker control (`SearchPicker`, R-17y-3 — `createLabel: nil`: a grant
//    never makes a place). A book: Recently edited → Starred → each shelf in
//    the Bookcase's strip order → Unshelved (or a–z), every row with its
//    context line and, when its name collides, its distinguisher
//    (`PlaceLabels`). A note: the bounded note feed (`corpusNotes`), one wing
//    at a time (a wing row appears only when the library has more than one);
//    a daily-Journal entry or a Private note stays pickable (a per-ask grant
//    is legal) and the sheet then offers once and while connected only, with
//    the one-line why. A wing: the wings, Home first.
//  - WHO appears whenever the opener names no client (U3's place-doors open
//    this sheet pre-filled with WHERE — `MCPGrantOpening`): the approved
//    clients, most recently granted first.
//  - The confirm names the place WITH its distinguisher and carries R-AIR-3's
//    clause (U1) — one line when it fits, else two (the U2 geometry oracle).
//

import SwiftUI
import VariorumCore

/// **What opens the grant sheet** (13n-c U2 — the opener U3's doors call:
/// the Library bulk bar, the note and book row menus, Book Settings).
struct MCPGrantOpening: Identifiable {
    let id = UUID().uuidString
    /// Who the grant is for; nil = the sheet asks (WHO).
    var client: MCPClient?
    /// A first approval (Approve… on a connection request): the grant rides
    /// the approve, in one act.
    var approving = false
    /// WHERE, pre-filled; nil = the sheet's own default (a book).
    var place: MCPGrantSheet.Prefill?
}

struct MCPGrantSheet: View {
    let door: MCPDoor
    let opening: MCPGrantOpening
    let done: () -> Void

    enum Place: Hashable {
        case note
        case book
        case wing
    }

    /// A pre-filled WHERE (U3's doors).
    enum Prefill: Equatable {
        case note(String)
        case book(String)
        case wing(String)
    }

    @State private var place: Place = .book
    @State private var note: MCPGrantPicker.NoteRow?
    @State private var bookID: String?
    @State private var wingID: String = ""
    /// The note leg's wing (the window's current one by default).
    @State private var noteWingID: String = ""
    @State private var duration: MCPGrantRule.Duration = .always
    @State private var rung: MCPGrantRule.Rung = .read
    @State private var places = MCPGrantPlaces()
    /// Derived ONCE per load (never per render — a rung click must not
    /// rebuild a few hundred rows): the book layouts, the wing rows, and the
    /// distinguishers the field, the rows and the confirm wear.
    @State private var bookLayouts: [SearchPickerArrangement] = []
    @State private var wingRows: [SearchPickerOption] = []
    @State private var bookDistinguishers: [String: String] = [:]
    @State private var wingDistinguishers: [String: String] = [:]
    @State private var clients: [MCPClient] = []
    @State private var chosenClientID: String?
    @State private var now = Date()
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    // MARK: - What is chosen

    private var client: MCPClient? {
        opening.client ?? clients.first { $0.id == chosenClientID }
    }

    private var connected: Bool { client.map { door.connected.contains($0.name) } ?? false }

    private var chosenBook: Queries.MCPGrantableBook? {
        places.books.first { $0.id == bookID }
    }

    /// The fence of the chosen NOTE (a book or wing grant is never fenced —
    /// the offer leaves fenced books out).
    private var noteFence: MCPGrantRule.Fence? { place == .note ? note?.fence : nil }

    private var offeredDurations: [MCPGrantRule.Duration] {
        MCPGrantPicker.durations(connected: connected, noteFence: noteFence)
    }

    /// The grant as chosen, or nil while it is incomplete.
    private var spec: Operations.MCPGrantSpec? {
        guard client != nil, offeredDurations.contains(duration) else { return nil }
        switch place {
        case .note:
            guard let note else { return nil }
            return .init(rung: rung, scopeKind: .note, scopeID: note.id, duration: duration)
        case .book:
            guard let book = chosenBook else { return nil }
            return .init(rung: rung, scopeKind: .book, scopeID: book.id, duration: duration)
        case .wing:
            return .init(rung: rung, scopeKind: .wing, scopeID: wingID, duration: duration)
        }
    }

    /// F4 (the U1 ladder): EXHAUSTIVE — a note grant never wears the wing's
    /// clause, a book grant always wears hers.
    private var scope: MCPGrantRule.ScopeKind {
        switch place {
        case .note: .note
        case .book: .book
        case .wing: .wing
        }
    }

    private var placeName: String {
        switch place {
        case .note: note?.title ?? ""
        case .book: chosenBook?.name ?? ""
        case .wing: places.wingName(wingID)
        }
    }

    private var placeDistinguisher: String? {
        switch place {
        case .note: nil
        case .book: bookID.flatMap { bookDistinguishers[$0] }
        case .wing: wingDistinguishers[wingID]
        }
    }

    // MARK: - The face

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(opening.client.map { MCPPaneCopy.sheetTitle($0.name) } ?? MCPPaneCopy.sheetTitleChoosing)
                .font(.headline)
                .lineLimit(1)
            Text(MCPPaneCopy.sheetLead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            if opening.client == nil {
                section(MCPPaneCopy.whoSection)
                whoRow
            }

            section(MCPPaneCopy.whereSection)
            Picker(MCPPaneCopy.whereSection, selection: $place) {
                Text(MCPPaneCopy.aNote).tag(Place.note)
                Text(MCPPaneCopy.aBook).tag(Place.book)
                Text(MCPPaneCopy.thisWing).tag(Place.wing)
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()
            .labelsHidden()
            whereRow

            section(MCPPaneCopy.howMuchSection)
            Picker(MCPPaneCopy.howMuchSection, selection: $rung) {
                ForEach(MCPPaneCopy.offeredRungs, id: \.self) { rung in
                    Text(MCPPaneCopy.rungName(rung)).tag(rung)
                }
            }
            .pickerStyle(.radioGroup)
            .horizontalRadioGroupLayout()
            .labelsHidden()
            quiet(MCPPaneCopy.rungDetail(rung))

            section(MCPPaneCopy.howLongSection)
            Picker(MCPPaneCopy.howLongSection, selection: $duration) {
                ForEach(offeredDurations, id: \.self) { duration in
                    Text(MCPPaneCopy.durationWord(duration).capitalizedFirst).tag(duration)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            ForEach(MCPGrantPicker.durationWhys(
                connected: connected, clientChosen: client != nil,
                note: noteFence.flatMap { fence in note.map { ($0.title, fence) } }), id: \.self) { why in
                quiet(why)
            }

            HStack(alignment: .bottom) {
                Button(MCPPaneCopy.cancel, action: done)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
                    .keyboardShortcut(.cancelAction)
                Spacer(minLength: 8)
                Button {
                    guard let spec, let client else { return }
                    if opening.approving {
                        door.approve(client.id, granting: spec)
                    } else {
                        door.grant(client.id, spec)
                    }
                    done()
                } label: {
                    ConfirmLabel(parts: MCPPaneCopy.confirmParts(
                        verb: CapabilityRegistry.capability(.mcpGrantAccess).verb,
                        rung: rung, scope: scope, place: placeName, distinguisher: placeDistinguisher,
                        duration: duration))
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(spec == nil)
            }
            .padding(.top, 4)
        }
        .padding(20)
        // 13n-c U1 made it 600 (R-AIR-3's clause); U2 keeps 600 — the confirm
        // takes a second line rather than the sheet growing past Settings'
        // window (the U2 geometry oracle, in the record).
        .frame(width: 600)
        .task { await load() }
        .onChange(of: offeredDurations) { _, offered in
            if !offered.contains(duration) { duration = offered.first ?? .once }
        }
    }

    // MARK: - The rows

    @ViewBuilder
    private var whoRow: some View {
        if clients.isEmpty {
            quiet(MCPPaneCopy.noApprovedClient)
        } else {
            SearchPicker(
                tokens: tokens, label: MCPPaneCopy.chooseClient, prompt: MCPPaneCopy.clientPrompt,
                options: MCPGrantPicker.clientOptions(clients, connected: door.connected),
                emptyText: MCPPaneCopy.noApprovedClient,
                onPick: { chosenClientID = $0 },
                field: .init(
                    value: client?.name,
                    annotation: connected ? MCPPaneCopy.connectedNow : nil,
                    placeholder: MCPPaneCopy.chooseClient),
                panelWidth: 360)
        }
    }

    @ViewBuilder
    private var whereRow: some View {
        switch place {
        case .note:
            if places.wings.count > 0 {
                HStack(spacing: 8) {
                    Text(MCPPaneCopy.noteWingLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    wingPicker(selection: noteWingID) { id in
                        if id != noteWingID { note = nil }
                        noteWingID = id
                    }
                    .frame(maxWidth: 220)
                }
            }
            SearchPicker(
                tokens: tokens, label: MCPPaneCopy.chooseNote, prompt: MCPPaneCopy.notePrompt,
                options: [], emptyText: MCPPaneCopy.noNotes,
                onPick: { id in pickNote(id) },
                source: { [door, noteWingID] query in
                    MCPGrantPicker.noteSections(
                        await door.grantNotes(query: query, wingID: noteWingID), query: query)
                },
                field: .init(
                    value: note?.title,
                    annotation: note?.fence.map(MCPPaneCopy.noteFenceWord),
                    emphasized: note?.fence != nil,
                    placeholder: MCPPaneCopy.chooseNote),
                panelWidth: 480)
                .id("note-\(noteWingID)")
            quiet(MCPPaneCopy.aNoteDetail(note?.title))
        case .book:
            if places.books.isEmpty {
                quiet(MCPPaneCopy.noBooks)
            } else {
                SearchPicker(
                    tokens: tokens, label: MCPPaneCopy.chooseBook, prompt: MCPPaneCopy.bookPrompt,
                    options: [], emptyText: MCPPaneCopy.noBooks,
                    onPick: { bookID = $0 },
                    arrangements: bookLayouts,
                    field: .init(
                        value: chosenBook?.name,
                        annotation: placeDistinguisher,
                        emphasized: placeDistinguisher != nil,
                        placeholder: MCPPaneCopy.chooseBook),
                    panelWidth: 480)
                quiet(MCPPaneCopy.aBookDetail(chosenBook?.name))
            }
            quiet(MCPPaneCopy.fencedBooksNote)
        case .wing:
            wingPicker(selection: wingID) { wingID = $0 }
            quiet(MCPPaneCopy.wingDetail(places.wingName(wingID)))
        }
    }

    private func wingPicker(selection: String, pick: @escaping (String) -> Void) -> some View {
        SearchPicker(
            tokens: tokens, label: places.wingName(selection), prompt: MCPPaneCopy.wingPrompt,
            options: wingRows, emptyText: "",
            onPick: pick,
            field: .init(
                value: places.wingName(selection), annotation: wingDistinguishers[selection],
                emphasized: wingDistinguishers[selection] != nil, placeholder: ""),
            panelWidth: 320)
    }

    private func pickNote(_ id: String) {
        Task {
            if let row = await door.grantNote(id) { note = row }
        }
    }

    private func load() async {
        now = Date()
        async let loadedPlaces = door.grantPlaces()
        async let loadedClients = door.clientsByRecentGrant()
        places = await loadedPlaces
        bookLayouts = MCPGrantPicker.bookArrangements(places, now: now)
        wingRows = MCPGrantPicker.wingOptions(places, now: now)
        bookDistinguishers = places.bookDistinguishers(now: now)
        wingDistinguishers = places.wingDistinguishers(now: now)
        clients = opening.client == nil ? await loadedClients : []
        if chosenClientID == nil { chosenClientID = clients.first?.id }
        noteWingID = door.currentWingID
        switch opening.place {
        case .note(let id)?:
            place = .note
            if let row = await door.grantNote(id) {
                note = row
                noteWingID = row.wingID ?? noteWingID
            }
        case .book(let id)?:
            place = .book
            bookID = id
        case .wing(let id)?:
            place = .wing
            wingID = id
        case nil:
            // The default a book: the most recently edited one (her "that's
            // often what I want") — a–z's first was arbitrary at scale.
            bookID = places.recentlyEdited(limit: 1).first?.id
        }
        if !offeredDurations.contains(duration) { duration = offeredDurations.first ?? .once }
    }

    /// **The durations this sheet may offer** (the U1 walk's fourth
    /// finding — P-2): "while connected" ends when the client's last
    /// connection closes, so it is offered only while the client IS
    /// connected; to a client that is not, it would be a door that cannot
    /// act as named. (13n-c U2: the fence's never-always rides on top —
    /// `MCPGrantPicker.durations`.)
    static func durations(connected: Bool) -> [MCPGrantRule.Duration] {
        connected ? MCPGrantRule.Duration.allCases : [.once, .always]
    }

    private func section(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.top, 2)
    }

    private func quiet(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// **The confirm's label** (13n-c U1, re-designed at U2 — the geometry oracle
/// in the U2 record): the grant sentence on ONE line when it fits; otherwise
/// on TWO, with only the place middle-shortened (`MCPPaneCopy.shortPlace` —
/// it shows whole in WHERE just above), so the verb, rung, distinguisher,
/// duration and R-AIR-3's clause always read whole. In Terminal's mono even
/// her own example with a day distinguisher is past one line's room at 600.
/// The parts are `MCPPaneCopy.confirmParts`; joined they are exactly
/// `MCPPaneCopy.confirm` (pinned).
struct ConfirmLabel: View {
    let parts: (lead: String, place: String, tail: String)

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Text(parts.lead + parts.place + parts.tail)
                .lineLimit(1)
                .fixedSize()
            Text(parts.lead + MCPPaneCopy.shortPlace(parts.place) + parts.tail)
                .lineLimit(2)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(parts.lead + parts.place + parts.tail)
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
