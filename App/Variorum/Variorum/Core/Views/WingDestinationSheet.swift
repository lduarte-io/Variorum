//
//  WingDestinationSheet.swift
//  Variorum (MAC ONLY) — Core/Views (composed by the window — `RootView` — for
//  ⌘K's Move/Copy to Wing; beside ⌘L's switcher, whose brain and keys it shares)
//
//  VX-377 (the VX-620 run, batch 4) — MOVE / COPY TO WING FROM THE KEYBOARD.
//  Her words (2026-10-21): "The keyboard shortcut for moving something to a
//  wing I also basically need NOW for my own use - it should pull up a
//  selector that I can also operate via keyboard to make it truly fast."
//
//  The acts' doors were a right-click or note ▾ SUBMENU of the other wings
//  (`WingNoteDoors`, the Bookcase row's) — a menu only pointing can open, so ⌘K
//  had nothing to show. The app's one keyboard wing selector is ⌘L's switcher;
//  this is its DESTINATION-PICKING TWIN, never a second picker:
//
//  · the rows are exactly the submenu's (`WingsModel.destinations(from:)` —
//    every wing but the one the note or book lives in, Home first);
//  · the filtering, the highlight, ↑/↓ and ⏎ are the switcher's pure brain
//    (`WingSwitcherBrain` — the one picker brain's sameness), its current row
//    the note's OWN wing, which is never listed, so every choice is a commit;
//  · Esc closes through the switcher's window-scoped monitor
//    (`WingSwitcherKeyCatcher`); ⌘L inside it steps like ↓ and is consumed (the
//    menu's ⌘L never stacks the switcher underneath), and NOTHING commits on a
//    key's release — a move is never a held-⌘ release;
//  · the choice runs the EXISTING acts and their confirms (`moveAsk` →
//    `wingMoveConfirm`, `copy`, `bookMoveAsk` → `wingBookMoveConfirm`), hosted
//    over this sheet (the switcher's nested-ask precedent): never a second road.
//
//  Which acts ⌘K lists, and where, is `WingPaletteDoors` below — the registry's
//  availability (DATA, P-1) and the book door's own drawing rule, shared.
//  Every word is PROVISIONAL (RB-15, her copy pass).
//

import AppKit
import Observation
import SwiftUI
import VariorumCore

// MARK: - Which wing rows ⌘K lists (pure, pinned)

/// **⌘K's context-listed rows** — the three wing acts list only where they can
/// act (P-2: a door that can never act in its context isn't rendered). Every
/// OTHER palette row keeps the palette's standing grammar: listed always,
/// speaking its honest note where it cannot act.
nonisolated enum WingPaletteDoors {
    static let contextListed: Set<CapabilityID> = [.moveNoteToWing, .copyNoteToWing, .moveBookToWing]

    /// What the FOCUSED pane shows at ⌘K's press, and how many wings exist —
    /// the facts the listing reads (once per open).
    nonisolated struct Facts: Equatable, Sendable {
        nonisolated enum Focus: Equatable, Sendable {
            /// A note (`.post`) — its two rows.
            case note(String)
            /// A book or a gathering (`.reading`), read whole for the daily
            /// Journal's marker — the book's row.
            case book(Reading)
            /// A place, a scraps container, nothing — none of the three.
            case other
        }
        var focus: Focus
        /// Home included (`WingState.wingCount`).
        var wingCount: Int

        /// The registry's context for these facts — the target-less door's
        /// gate (`CapabilityRegistry`'s availability for the three acts).
        var context: CapabilityContext {
            switch focus {
            case .note(let postID): WingPaletteDoors.context(showing: .post(postID), wingCount: wingCount)
            case .book(let reading): WingPaletteDoors.context(showing: .reading(reading.id), wingCount: wingCount)
            case .other: WingPaletteDoors.context(showing: nil, wingCount: wingCount)
            }
        }
    }

    /// **The registry's context for a pane showing `selection`** — a `.post`
    /// is a note, a `.reading` a book (or a gathering): the two facts the
    /// command router wires from the key window the same way
    /// (`focusedPaneShowsNote` — `closeNoteTarget`; `focusedPaneShowsBook`).
    static func context(showing selection: SidebarSelection?, wingCount: Int) -> CapabilityContext {
        var showsNote = false
        var showsBook = false
        switch selection {
        case .post?: showsNote = true
        case .reading?: showsBook = true
        default: break
        }
        return CapabilityContext(
            focusedPaneShowsNote: showsNote, focusedPaneShowsBook: showsBook, wingCount: wingCount)
    }

    /// Whether ⌘K lists `id` for these facts: any act outside the three,
    /// always; the three, where the registry says they act — and the book's
    /// row, where the Bookcase row's own door would draw (never the daily
    /// Journal: `WingBookMoveDoor.drawn`, the ONE rule, shared).
    static func lists(_ id: CapabilityID, _ facts: Facts) -> Bool {
        guard contextListed.contains(id) else { return true }
        guard CapabilityRegistry.isEnabled(id, in: facts.context) else { return false }
        if id == .moveBookToWing, case .book(let reading) = facts.focus {
            return WingBookMoveDoor.drawn(reading: reading, destinations: facts.wingCount - 1)
        }
        return true
    }
}

// MARK: - The selector's model

/// One open selector (per window, per ⌘K choice) — the brain over the act's
/// own destination rows, and the act its choice runs.
@MainActor
@Observable
final class WingDestinationModel: Identifiable {
    /// What the chosen wing receives — the three acts ⌘K reaches.
    enum Act: Equatable {
        case moveNote(postID: String, title: String)
        case copyNote(postID: String, title: String)
        case moveBook(Reading)
    }

    let id = UUID()
    let act: Act
    /// The wing the note or book lives in now — its name, for the foot.
    let fromWingName: String
    private(set) var brain: WingSwitcherBrain
    /// A choice is landing: a second ⏎ or click does nothing until it has.
    private(set) var choosing = false
    /// The act's confirms, presented over the selector.
    var pendingMove: WingsModel.MoveAsk?
    var pendingBookMove: WingsModel.BookMoveAsk?
    @ObservationIgnored let wings: WingsModel

    init(act: Act, fromWing: String, wings: WingsModel) {
        self.act = act
        self.wings = wings
        fromWingName = wings.name(of: fromWing)
        // The submenu's rows exactly; the note's own wing is the brain's
        // "current" and is never among them, so ⏎ and a click always commit.
        brain = WingSwitcherBrain(
            rows: wings.destinations(from: fromWing).map { WingSwitcherBrain.Row(id: $0.id, name: $0.name) },
            currentID: fromWing)
    }

    var prompt: String {
        if case .copyNote = act { return WingCopy.copyDestinationPrompt }
        return WingCopy.moveDestinationPrompt
    }

    var subject: String {
        switch act {
        case .moveNote(_, let title), .copyNote(_, let title): title
        case .moveBook(let reading): reading.name
        }
    }

    var foot: String { WingCopy.destinationFoot(subject: subject, in: fromWingName) }

    func type(_ text: String) { brain.type(text) }
    func move(by delta: Int) { brain.move(by: delta) }

    /// Run the brain's answer. Returns whether the selector should close: a
    /// landed act (its receipt said on the status line) or a refusal the act
    /// spoke closes it; a confirm opens OVER it (its Move closes both, its
    /// Cancel returns here); `.stay` (nothing visible) keeps it.
    func choose(_ outcome: WingSwitcherBrain.Outcome) async -> Bool {
        switch outcome {
        case .stay:
            return false
        case .close:
            return true
        case .commit(let wingID):
            guard !choosing else { return false }
            choosing = true
            defer { choosing = false }
            switch act {
            case .moveNote(let postID, let title):
                // A bookless note moves at once; a note in books asks (the
                // books it leaves listed); a note in a finished book refuses,
                // naming it — `moveAsk`, the submenu's own road.
                if let ask = await wings.moveAsk(postID: postID, title: title, to: wingID) {
                    pendingMove = ask
                    return false
                }
                return true
            case .copyNote(let postID, let title):
                await wings.copy(postID: postID, title: title, to: wingID)
                return true
            case .moveBook(let reading):
                // It always asks (P-13id-U5b-4 — no undo; the confirm is the
                // net); a frozen stay-behind refuses at the door, naming it.
                if let ask = await wings.bookMoveAsk(reading: reading, to: wingID) {
                    pendingBookMove = ask
                    return false
                }
                return true
            }
        }
    }
}

extension WingDestinationModel {
    /// Resolve ⌘K's request into a selector — or SAY why not. ⌘K lists the
    /// rows only where they can act, so each refusal here is the belt for a
    /// race between the press and the read (the note or book went, the last
    /// other wing went, the book became the daily Journal). nil = it spoke.
    static func open(
        _ request: ShellRouter.WingDestinationRequest, wings: WingsModel, session: AppSession
    ) async -> WingDestinationModel? {
        switch request.act {
        case .moveNote(let postID), .copyNote(let postID):
            let isCopy: Bool
            if case .copyNote = request.act { isCopy = true } else { isCopy = false }
            let capability: CapabilityID = isCopy ? .copyNoteToWing : .moveNoteToWing
            // The note's OWN wing (an open note can be another wing's — the
            // note ▾ menu's own read), and its display title for the words.
            guard let context = await NoteMenuWingContext.load(session, postID: postID) else {
                session.status.refuse(CapabilityRegistry.capability(capability).unavailableNote)
                return nil
            }
            guard !wings.destinations(from: context.wingID).isEmpty else {
                session.status.refuse(WingCopy.switchWingUnavailable)
                return nil
            }
            let act: Act = isCopy
                ? .copyNote(postID: postID, title: context.title)
                : .moveNote(postID: postID, title: context.title)
            return WingDestinationModel(act: act, fromWing: context.wingID, wings: wings)
        case .moveBook(let readingID):
            guard let reading = try? await session.database.read({ db in
                try Queries.reading(db, id: readingID)
            }) else {
                session.status.refuse(OpsRefusalCopy.message(
                    for: OperationError.readingNotFound(id: readingID)))
                return nil
            }
            if Queries.isDailyJournalMintShape(reading) {
                // The op's own words (`bookMoveAsk`'s arm for a stale face).
                session.status.refuse(OpsRefusalCopy.message(
                    for: OperationError.dailyJournalIsHomeOnly(id: readingID)))
                return nil
            }
            guard WingBookMoveDoor.drawn(
                reading: reading, destinations: wings.destinations(from: reading.wingId).count)
            else {
                session.status.refuse(WingCopy.switchWingUnavailable)
                return nil
            }
            return WingDestinationModel(act: .moveBook(reading), fromWing: reading.wingId, wings: wings)
        }
    }
}

// MARK: - The selector's face

struct WingDestinationSheet: View {
    @Bindable var model: WingDestinationModel
    let tokens: VoiceTokens
    let close: () -> Void
    @FocusState private var fieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField(tokens.chromeLabel(model.prompt), text: Binding(
                get: { model.brain.query }, set: { model.type($0) }))
                .textFieldStyle(.plain)
                .font(tokens.body)
                .padding(12)
                .focused($fieldFocused)
                // The palette's and the switcher's one-line list navigator:
                // ↓/↑ step the highlight while the field keeps the keyboard.
                .onKeyPress(.downArrow) {
                    model.move(by: 1)
                    return .handled
                }
                .onKeyPress(.upArrow) {
                    model.move(by: -1)
                    return .handled
                }
                .onSubmit { choose(model.brain.returnPressed()) }
            Divider().overlay(tokens.line)
            rows
                // The book move's confirm (it always asks) — over the selector.
                .wingBookMoveConfirm($model.pendingBookMove, wings: model.wings, onDone: close)
            Divider().overlay(tokens.line)
            Text(tokens.chromeLabel(model.foot))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
        }
        .frame(width: 440)
        .background(tokens.card)
        // A note's move confirm (when it leaves books) — over the selector.
        .wingMoveConfirm($model.pendingMove, wings: model.wings, onDone: close)
        // Arrive with the keyboard in the field (her "operate via keyboard").
        .task { askForTheKeyboard() }
        // The keys the field cannot see — Esc, and ⌘L — this sheet's window's
        // only (a confirm over it is another window and keeps its own Esc).
        .background(WingSwitcherKeyCatcher { key in
            switch key {
            case .escape:
                close()
                return true
            case .tapL:
                // ⌘L steps, like ↓ — consumed, so the menu's ⌘L never opens
                // the switcher underneath. No release commits a move.
                model.move(by: 1)
                return true
            case .commandUp:
                return false
            }
        })
    }

    private func choose(_ outcome: WingSwitcherBrain.Outcome) {
        Task { @MainActor in
            if await model.choose(outcome) { close() }
        }
    }

    /// **The arrival's ask for the keyboard** — the field's own `@FocusState`,
    /// once per arrival (the palette's and the switcher's idiom). VX-620 fix
    /// leg 4-F2: the test host's windows never become key, so a mounted pin can
    /// see this REQUEST (recorded in DEBUG) but not its landing; the landing —
    /// the keyboard in the field with no click — is the final window's walk
    /// evidence (both voices, captured).
    private func askForTheKeyboard() {
        fieldFocused = true
        #if DEBUG
        WingDestinationOracle.keyboardAsks[model.id, default: 0] += 1
        #endif
    }

    private var rows: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 1) {
                let visible = model.brain.visible
                if visible.isEmpty {
                    Text(tokens.chromeLabel(WingCopy.noWingMatches))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                ForEach(visible) { row in
                    rowView(row, highlighted: row.id == model.brain.highlight)
                }
            }
            .padding(.vertical, 4)
        }
        .frame(minHeight: 80, maxHeight: 300)
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
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(highlighted ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear))
        .contentShape(Rectangle())
        .onTapGesture { choose(model.brain.pick(row.id)) }
    }
}

#if DEBUG
/// **VX-620 fix leg 4-F2 — the mounted pin's seam:** how many times each open
/// selector (by its model's id) asked for the keyboard. One per arrival; never
/// per render.
@MainActor
enum WingDestinationOracle {
    static var keyboardAsks: [UUID: Int] = [:]
}
#endif

// MARK: - The words (PROVISIONAL — RB-15, her copy pass)

nonisolated extension WingCopy {
    /// The selector's field — what typing does (the switcher's "Switch to a
    /// wing" in kind).
    static let moveDestinationPrompt = "Move to a wing"
    static let copyDestinationPrompt = "Copy to a wing"

    /// The selector's foot: what is moving and from where, and its keys (the
    /// switcher's foot in kind). "Chooses", never "moves": a note in books and
    /// every book ask first.
    static func destinationFoot(subject: String, in wing: String) -> String {
        "\u{201C}\(subject)\u{201D} is in \(wing) \u{00B7} \u{23CE} chooses \u{00B7} esc closes"
    }
}
