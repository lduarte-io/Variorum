//
//  GatheringNoteDoor.swift
//  Variorum
//
//  VX-217 (2026-10-13) — "make sure that new note button exists on gatherings
//  … the bottom of a book and the bottom of a gathering should look the same"
//  (her words). Option (A) as ruled + her R-VX214-3 (greyed, never hidden,
//  with the reason on hover) and R-VX214-4 (a star term is satisfiable at
//  mint); the run record `notes/plans/fixes/vx-214-settings-launch-polish.md`.
//
//  A gathering holds nothing, so a note made "in" one is a note born wearing
//  what its rule matches — `Operations.newPostInGathering`. The door is drawn
//  exactly as the book's "+ new note" is (the navigator's foot, and the
//  Outline flow's end), and it is ALWAYS drawn: where the act can't land it
//  greys and its hover says why, in the same words the op would refuse with
//  (`GatheringMint.Blocker.reason` — one home for them).
//

import GRDB
import SwiftUI
import VariorumCore

/// What the door knows: the ONE planner's outcome for this gathering (the
/// read the op re-checks inside its own transaction — rider 2) and, when a
/// mint can land, the tags it will apply by path (for the hover).
nonisolated struct GatheringMintFace: Equatable, Sendable {
    let outcome: GatheringMint.Outcome
    let tagPaths: [String]

    var blocker: GatheringMint.Blocker? {
        if case .blocked(let blocker) = outcome { return blocker }
        return nil
    }

    var star: Bool {
        if case .plan(let plan) = outcome { return plan.star }
        return false
    }

    /// Read inside the book view's tracked observation.
    static func read(_ db: Database, gathering: Reading) throws -> GatheringMintFace {
        let outcome = try Queries.gatheringMintOutcome(db, reading: gathering)
        guard case .plan(let plan) = outcome else { return .init(outcome: outcome, tagPaths: []) }
        let paths = try Queries.tagPaths(db, ids: plan.tagIDs)
        return .init(outcome: outcome, tagPaths: plan.tagIDs.compactMap { paths[$0] })
    }
}

/// The door's words (sentence case — her no-caps rule).
nonisolated enum GatheringNoteDoorCopy {
    /// The registry's verb (`.newNoteInGathering`).
    static let verb = "New Note in This Gathering"
    static let unavailableNote =
        "A note is made inside a gathering from the foot of its contents or the end of its outline."
    /// The navigator foot's word — the book's own ("+ new note").
    static let navigatorWord = "+ new note"
    /// The Outline flow's word — the book's twin says "in this book".
    static let flowWord = "+ new note in this gathering"

    /// The hover — what a new note here will wear, or why there can't be one.
    /// The enabled-state hovers stay as drafted (her #217 answer). A greyed
    /// door's hover — and the door's refusal (`BookStructureModel.
    /// newPostInGathering`) — is the op's own reason as the whole sentence
    /// (`GatheringMint.Blocker.reason`, the one home): VX-250 (2) made her
    /// shorter hovers complete sentences ("Archived — unarchive it to add
    /// notes."), retiring the old "This gathering can't take a new note: …"
    /// frame (and, ladder r1 F-8, the identity wrapper that outlived it).
    static func help(_ face: GatheringMintFace?) -> String {
        guard let face else { return "A new note made inside this gathering" }
        if let blocker = face.blocker { return blocker.reason }
        let tags = face.tagPaths.map { "#\($0)" }.joined(separator: " ")
        switch (face.tagPaths.isEmpty, face.star) {
        case (false, false): return "A new note tagged \(tags), so this gathering shows it"
        case (false, true): return "A new note tagged \(tags) and starred, so this gathering shows it"
        case (true, true): return "A new note, starred, so this gathering shows it"
        case (true, false): return "A new note this gathering shows"
        }
    }
}

/// The door itself — drawn as the book's "+ new note" is (`.borderless`,
/// the small chrome font, the accent ink), with an HONEST disabled face: the
/// accent gives way to the faint ink, so the grey is visible whatever the
/// button style does with `disabled` (her R-VX214-3). This door was never a
/// `CalmButtonStyle` button — it wears the book foot's own `.borderless`
/// style so the two feet look the same (her VX-217 ruling) — so VX-194's
/// style fix does not reach it, and its local face STAYS (R-VX381-A1: the
/// ticket's "fold it into the style" step is not applicable; moving it onto
/// the calm style would put a bordered button beside the book's borderless
/// ones).
struct GatheringNoteDoor: View {
    let tokens: VoiceTokens
    let word: String
    let face: GatheringMintFace?
    let act: () -> Void

    var body: some View {
        let ready = face != nil && face?.blocker == nil
        Button(tokens.chromeLabel(word), action: act)
            .buttonStyle(.borderless)
            .font(tokens.small)
            .foregroundStyle(ready ? tokens.accent : tokens.faint)
            .disabled(!ready)
            .help(GatheringNoteDoorCopy.help(face))
    }
}
