//
//  WingDestinationModel.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-377 (the VX-620 run, batch 4) — MOVE / COPY TO WING, THE DESTINATION
//  SELECTOR's BRAIN: one open selector over the act's own destination rows
//  (`WingsModel.destinations(from:)` — every wing but the one the note or book
//  lives in, Home first), the switcher's pure brain filtering and
//  highlighting them (`WingSwitcherBrain`), and the act its choice runs — the
//  EXISTING acts and their asks (`moveAsk`, `copy`, `bookMoveAsk`), never a
//  second road.
//
//  VM-63 (the VM-55 run, "Wings underneath", batch 3) — moved here byte for
//  byte from the Mac's `Core/Views/WingDestinationSheet.swift`, with the words
//  it says (the prompt and the foot). That file keeps the Mac's: ⌘K's listing
//  (`WingPaletteDoors`), the chords (`WingChords`), the resolution of a ⌘K or
//  chord request into a selector (`WingDestinationModel.open` — the Mac's
//  router, registry and note ▾ context), and the sheet itself.
//

import Foundation
import Observation
import VariorumCore

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
