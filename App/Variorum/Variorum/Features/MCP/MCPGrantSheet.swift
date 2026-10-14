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
//  - The confirm names the place WITH its distinguisher and carries VX-269's
//    clause (U1) — one line when it fits, else two (the U2 geometry oracle).
//
//  13n-c UX walk W-UX-2 — APPROVE ALONE, GRANT SEPARATE (her ruling, sitting
//  round 6): the approval road (a request's Approve…) admits the client with
//  ZERO reach. The sheet still OFFERS a grant, but starts on "Nothing yet" —
//  no place, no book, never Always (`start`) — and confirms "Approve <client>"
//  until she picks a grant ("Approve and grant read in “X” once").
//

import SwiftUI
import VariorumCore

struct MCPGrantSheet: View {
    let door: MCPDoor
    let opening: MCPGrantOpening
    let done: () -> Void

    enum Place: Hashable {
        /// 13n-c UX walk W-UX-2 (her ruling, sitting round 6 — APPROVE ALONE,
        /// GRANT SEPARATE): an approval with no grant picked admits the
        /// client with zero reach. Offered only on the approval road.
        case nothing
        case note
        /// 13n-c U3: several notes, fixed by the opener (the Library's "Share
        /// N notes…") — WHERE is said, not chosen (mockup §2).
        case notes
        case book
        case wing
    }

    /// A pre-filled WHERE — `MCPGrantPrefill`, the road's own type since 13n-c
    /// U3 (`Core/Views/MCPShareRoad.swift`, beside `MCPGrantOpening`).
    typealias Prefill = MCPGrantPrefill

    @State private var place: Place = .book
    @State private var note: MCPGrantPicker.NoteRow?
    /// 13n-c U3: the several notes a `.notes` opening names, in its order.
    @State private var notes: [MCPGrantPicker.NoteRow] = []
    @State private var bookID: String?
    @State private var wingID: String = ""
    /// The note leg's wing (the window's current one by default).
    @State private var noteWingID: String = ""
    @State private var duration: MCPGrantRule.Duration = .always
    @State private var rung: MCPGrantRule.Rung = .read
    @State private var places = MCPGrantPlaces()
    /// W-UX-19: the places have been read (a prefilled book missing from the
    /// offer is then said, not left blank).
    @State private var placesLoaded = false
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
    /// 13n-c +4b — the Private books the picked note's mark comes through
    /// (display-only, for its why), read for THAT note.
    @State private var privateThrough: (noteID: String, books: [String])?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// 13n-c U3: the window's road — a place-door's receipt re-opens this
    /// sheet through it (Change…).
    @Environment(\.mcpShareRoad) private var road

    private var tokens: VoiceTokens { themeStore?.tokens(for: scheme) ?? .fallback(for: scheme) }

    init(door: MCPDoor, opening: MCPGrantOpening, done: @escaping () -> Void) {
        self.door = door
        self.opening = opening
        self.done = done
        // W-UX-2: the FIRST frame already shows the road's start (never a
        // book and Always flashing before the load on the approval road).
        let start = Self.start(approving: opening.approving, mostRecentBookID: nil)
        _place = State(initialValue: start.place)
        _duration = State(initialValue: start.duration)
    }

    // MARK: - What is chosen

    private var client: MCPClient? {
        opening.client ?? clients.first { $0.id == chosenClientID }
    }

    private var connected: Bool { client.map { door.connected.contains($0.name) } ?? false }

    private var chosenBook: Queries.MCPGrantableBook? {
        places.books.first { $0.id == bookID }
    }

    /// The fence of the chosen NOTE (a book or wing grant is never fenced —
    /// the offer leaves fenced books out). Several notes: the first fenced
    /// one's — any one withholds "always" for the whole act.
    private var noteFence: MCPGrantRule.Fence? {
        switch place {
        case .note: note?.fence
        case .notes: notes.lazy.compactMap(\.fence).first
        case .nothing, .book, .wing: nil
        }
    }

    private var offeredDurations: [MCPGrantRule.Duration] {
        MCPGrantPicker.durations(connected: connected, noteFence: noteFence)
    }

    /// Whether the confirm can act (P-2: never an enabled dead button).
    private var canConfirm: Bool {
        // W-UX-2: the approval alone is always an act (its client is named).
        if place == .nothing { return opening.approving && client != nil }
        guard client != nil, offeredDurations.contains(duration) else { return false }
        return place == .notes ? !notes.isEmpty : spec != nil
    }

    /// The grant as chosen, or nil while it is incomplete.
    private var spec: Operations.MCPGrantSpec? {
        guard client != nil else { return nil }
        return Self.spec(
            place: place, noteID: note?.id, bookID: chosenBook?.id, wingID: wingID, rung: rung,
            duration: duration, offered: offeredDurations)
    }

    /// **The grant as picked** (pure — 13n-c UX walk W-UX-2's pin drives it):
    /// nil while it is incomplete, for several notes (the bulk act), and when
    /// nothing is picked.
    static func spec(
        place: Place, noteID: String?, bookID: String?, wingID: String, rung: MCPGrantRule.Rung,
        duration: MCPGrantRule.Duration, offered: [MCPGrantRule.Duration]
    ) -> Operations.MCPGrantSpec? {
        guard offered.contains(duration) else { return nil }
        switch place {
        case .nothing:
            return nil
        case .note:
            guard let noteID else { return nil }
            return .init(rung: rung, scopeKind: .note, scopeID: noteID, duration: duration)
        case .notes:
            return nil  // several notes take the bulk act (`submit`)
        case .book:
            guard let bookID else { return nil }
            return .init(rung: rung, scopeKind: .book, scopeID: bookID, duration: duration)
        case .wing:
            return .init(rung: rung, scopeKind: .wing, scopeID: wingID, duration: duration)
        }
    }

    /// **What the sheet STARTS on when its opener names no place** (pure —
    /// 13n-c UX walk W-UX-2's pin drives it).
    struct Start: Equatable {
        var place: Place
        var bookID: String?
        var duration: MCPGrantRule.Duration
    }

    static func start(approving: Bool, mostRecentBookID: String?) -> Start {
        // 13n-c UX walk W-UX-2 (her ruling, sitting round 6 — APPROVE ALONE,
        // GRANT SEPARATE): the approval road starts on NOTHING picked — no
        // place, no book, and never Always; a grant there is hers to pick.
        if approving { return Start(place: .nothing, bookID: nil, duration: .once) }
        // The default a book: the most recently edited one (her "that's often
        // what I want") — a–z's first was arbitrary at scale.
        return Start(place: .book, bookID: mostRecentBookID, duration: .always)
    }

    /// F4 (the U1 ladder): EXHAUSTIVE — a note grant never wears the wing's
    /// clause, a book grant always wears hers.
    private var scope: MCPGrantRule.ScopeKind {
        switch place {
        case .nothing, .note, .notes: .note
        case .book: .book
        case .wing: .wing
        }
    }

    private var placeName: String {
        switch place {
        case .nothing: ""
        case .note: note?.title ?? ""
        case .notes: MCPShareCopy.notesCount(notes.count)
        case .book: chosenBook?.name ?? ""
        case .wing: places.wingName(wingID)
        }
    }

    private var placeDistinguisher: String? {
        switch place {
        case .nothing, .note, .notes: nil
        case .book: bookID.flatMap { bookDistinguishers[$0] }
        case .wing: wingDistinguishers[wingID]
        }
    }

    // MARK: - The face

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
            Text(opening.approving ? MCPPaneCopy.approvalLead : MCPPaneCopy.sheetLead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            // 13n-c U3 (T-U3-8): Change… says, before she confirms, that the
            // confirm REPLACES what it was opened on.
            if !opening.replacing.isEmpty {
                quiet(MCPPaneCopy.replacesLine)
            }

            if opening.client == nil {
                section(MCPPaneCopy.whoSection)
                whoRow
            }

            section(MCPPaneCopy.whereSection)
            // Several notes are SAID, never re-chosen (mockup §2): the act
            // they open is the bulk share of exactly these.
            if place != .notes {
                Picker(MCPPaneCopy.whereSection, selection: $place) {
                    // W-UX-2: the approval road offers a grant, never makes one.
                    if opening.approving {
                        Text(MCPPaneCopy.nothingYet).tag(Place.nothing)
                    }
                    Text(MCPPaneCopy.aNote).tag(Place.note)
                    Text(MCPPaneCopy.aBook).tag(Place.book)
                    Text(MCPPaneCopy.thisWing).tag(Place.wing)
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .labelsHidden()
            }
            whereRow

            // W-UX-2: with nothing picked there is no grant to size.
            if place != .nothing {
                section(MCPPaneCopy.howMuchSection)
                Picker(MCPPaneCopy.howMuchSection, selection: $rung) {
                    ForEach(MCPPaneCopy.offeredRungs, id: \.self) { rung in
                        Text(MCPPaneCopy.rungName(rung)).tag(rung)
                    }
                }
                .pickerStyle(.radioGroup)
                .horizontalRadioGroupLayout()
                .labelsHidden()
                // W-UX-14: the rung said for the place picked.
                quiet(MCPPaneCopy.rungDetail(rung, scope: scope))

                section(MCPPaneCopy.howLongSection)
                Picker(MCPPaneCopy.howLongSection, selection: $duration) {
                    ForEach(offeredDurations, id: \.self) { duration in
                        Text(MCPPaneCopy.durationWord(duration).capitalizedFirst).tag(duration)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                // P-8 (VX-245): a segmented control's labels are one line.
                .lineLimit(1)
                .fixedSize()
                ForEach(durationWhys, id: \.self) { why in
                    quiet(why)
                }
            }

            HStack(alignment: .bottom) {
                // 13n-c UX walk W-UX-9: ONE confirm idiom with the ask sheet —
                // the platform's FILLED default button in the voice's accent
                // (`.borderedProminent` under the sheet's `.tint`), Cancel
                // bordered. It read as a long accent sentence beside a plain
                // word. System styles because they are the closer match to the
                // disposition's "the ask sheet's filled button" and to AppKit's
                // own default/cancel keys — NOT because a custom style loses
                // them: the dead Return/Esc the verify leg first saw was its
                // test road (cliclick's keys never reach a sheet; System
                // Events' key codes do), and nine working sheets pair
                // `VoicedButtonStyle` with `.keyboardShortcut(.defaultAction)`
                // (UX-fix ladder UXR1-4). On macOS 26 a bordered button holds
                // the confirm's two lines (probed).
                Button(MCPPaneCopy.cancel, action: done)
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
                Spacer(minLength: 8)
                Button(action: submit) {
                    if place == .nothing {
                        Text(MCPPaneCopy.approveAlone(opening.client?.name ?? ""))
                            .lineLimit(1)
                    } else {
                        ConfirmLabel(parts: confirmParts)
                    }
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
                .disabled(!canConfirm)
            }
            .padding(.top, 4)
        }
        .padding(20)
        // 13n-c U1 made it 600 (VX-269's clause); U2 keeps 600 — the confirm
        // takes a second line rather than the sheet growing past Settings'
        // window (the U2 geometry oracle, in the record).
        .frame(width: 600)
        // 13n-c UX walk W-UX-11 (T-7): the radios and segments wear the
        // VOICE's accent in every host — the window-hosted sheet drew system
        // blue (only Settings' scene set the tint).
        .tint(tokens.accent)
        .task { await load() }
        // 13n-c +4b: a Private note's why names the book its mark comes
        // through — read for the note picked (display-only; the fence and the
        // durations stay `mcpNoteFacts`').
        .task(id: note?.id) {
            guard let picked = note, picked.fence == .privateMark else { return }
            privateThrough = (picked.id, await door.privateMarkBooks(noteID: picked.id))
        }
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
        case .nothing:
            quiet(MCPPaneCopy.approveAloneDetail(openBook: door.snapshot.openBook))
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
            // 13n-c UX walk W-UX-19: Change… on a grant whose book is fenced
            // since (an inert row) opens on CURRENT facts — the book is not in
            // the offer, and the sheet says why rather than showing a blank.
            if placesLoaded, let bookID, chosenBook == nil, case .book(let prefilled)? = opening.place,
               prefilled == bookID {
                quiet(MCPPaneCopy.prefilledBookNotOffered)
            }
            quiet(MCPPaneCopy.fencedBooksNote)
        case .notes:
            // 13n-c U3 (mockup §2): "These 3 notes — parser notes · grammar
            // sketch · morning pages — oct 9".
            Text(MCPPaneCopy.theseNotes(notes.count))
                .font(.callout)
                .lineLimit(1)
            quiet(MCPPaneCopy.notesList(notes.map(\.title)))
        case .wing:
            wingPicker(selection: wingID) { wingID = $0 }
            quiet(MCPPaneCopy.wingDetail(places.wingName(wingID)))
        }
    }

    // MARK: - The confirm

    /// The one-line whys under HOW LONG — a fenced note's (one, or several
    /// among the pick: mockup §2's "1 of these notes is a daily Journal
    /// entry…"), and "while connected" withheld from a client not connected.
    private var durationWhys: [String] {
        if place == .notes {
            let fences = notes.compactMap(\.fence)
            return (fences.isEmpty ? [] : [MCPPaneCopy.alwaysWithheldAmong(fences)])
                + MCPGrantPicker.durationWhys(connected: connected, clientChosen: client != nil, note: nil)
        }
        return MCPGrantPicker.durationWhys(
            connected: connected, clientChosen: client != nil,
            note: noteFence.flatMap { fence in note.map { ($0.title, fence) } },
            throughBooks: privateThrough.flatMap { $0.noteID == note?.id ? $0.books : nil } ?? [])
    }

    /// The title — W-UX-2: the approval road says it APPROVES.
    private var title: String {
        if opening.approving, let name = opening.client?.name { return MCPPaneCopy.approvalTitle(name) }
        return MCPPaneCopy.sheetTitle(client: opening.client?.name, changing: !opening.replacing.isEmpty)
    }

    private var confirmParts: (lead: String, place: String, tail: String) {
        // W-UX-2: a grant riding an approval says both acts.
        let verb = opening.approving
            ? MCPPaneCopy.approveAndGrantVerb : CapabilityRegistry.capability(.mcpGrantAccess).verb
        if place == .notes {
            return MCPPaneCopy.confirmPartsForNotes(verb: verb, rung: rung, count: notes.count, duration: duration)
        }
        return MCPPaneCopy.confirmParts(
            verb: verb, rung: rung, scope: scope, place: placeName, distinguisher: placeDistinguisher,
            duration: duration)
    }

    /// How the receipt says the place (a place-door's sheet speaks one).
    private var receiptPlace: String {
        switch place {
        case .nothing: ""
        case .note: MCPShareCopy.quoted(placeName)
        case .notes: MCPShareCopy.notesCount(notes.count)
        case .book: PlaceLabels.quoted(placeName, distinguisher: placeDistinguisher)
        case .wing: MCPShareCopy.wingPlace(placeName)
        }
    }

    /// The confirm's act: an approval (the pane's Approve… — alone, or with
    /// the grant she picked riding it, W-UX-2), the bulk
    /// share (several notes), or one grant — Change… when the opening names
    /// grants to replace (T-U3-8). A place-door's sheet speaks its receipt on
    /// the window's status seam; the pane's keeps its caption.
    private func submit() {
        guard canConfirm, let client else { return }
        let saying = opening.origin == .place ? receiptPlace : nil
        let change = road?.open
        if opening.approving {
            // W-UX-2: APPROVE ALONE unless she picked a grant — then it rides.
            door.approve(client.id, granting: place == .nothing ? nil : spec)
            done()
            return
        }
        if place == .notes {
            door.grantNotes(
                client, notes.map(\.id), rung: rung, duration: duration, replacing: opening.replacing,
                saying: saying, change: change)
        } else if let spec {
            if saying == nil, opening.replacing.isEmpty {
                door.grant(client.id, spec)
            } else {
                door.grant(client, spec, replacing: opening.replacing, saying: saying, change: change)
            }
        }
        done()
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
        placesLoaded = true
        bookLayouts = MCPGrantPicker.bookArrangements(places, now: now)
        wingRows = MCPGrantPicker.wingOptions(places, now: now)
        bookDistinguishers = places.bookDistinguishers(now: now)
        wingDistinguishers = places.wingDistinguishers(now: now)
        clients = opening.client == nil ? await loadedClients : []
        if chosenClientID == nil { chosenClientID = clients.first?.id }
        noteWingID = door.currentWingID
        // 13n-c U3 (VX-270): Change… opens on exactly what was shared.
        if let pre = opening.rung { rung = pre }
        if let pre = opening.duration { duration = pre }
        var single: String?
        switch opening.place {
        case .note(let id)?:
            single = id
        case .notes(let ids)? where ids.count == 1:
            single = ids[0]
        case .notes(let ids)?:
            place = .notes
            notes = await door.namedNotes(ids)
        default:
            break
        }
        if let single {
            place = .note
            if let row = await door.grantNote(single) {
                note = row
                noteWingID = row.wingID ?? noteWingID
            }
        }
        switch opening.place {
        case .note?, .notes?:
            break
        case .book(let id)?:
            place = .book
            bookID = id
        case .wing(let id)?:
            place = .wing
            wingID = id
        case nil:
            let start = Self.start(
                approving: opening.approving, mostRecentBookID: places.recentlyEdited(limit: 1).first?.id)
            place = start.place
            bookID = start.bookID
            duration = start.duration
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
/// duration and VX-269's clause always read whole. In Terminal's mono even
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

extension String {
    /// "until it disconnects" → "Until it disconnects" (a segmented control's
    /// label, the ask sheet's button; sentence case — her rule). Internal
    /// since 13n-c U4 (the ask's buttons read the same word).
    nonisolated var capitalizedFirst: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
