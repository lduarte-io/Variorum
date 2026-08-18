//
//  EditorUndoHint.swift
//  Variorum
//
//  Phase 13j, batch 1 — her J7, ruled live on her first morning back after
//  finding ⌥⌘Z herself: *"if a user is spamming command z, i think it should
//  prompt them to do a structural undo if it's not doing a regular undo."*
//
//  The two undo stacks are canon-separate and stay that way (author decision
//  2026-07-04, OverallModel §3: ⌘Z is NSTextView's ordinary per-buffer undo,
//  ⌥⌘Z/⇧⌥⌘Z are the structural stack's, and the two never interleave). What
//  was missing was not a bridge but a SIGN: the moment ⌘Z has nothing left to
//  do in the text while a structural change sits one key away is exactly the
//  moment to name that key. The chord is never consumed — the sign is spoken
//  beside the keystroke, never instead of it.
//
//  Pure by construction, so the whole fire/no-fire matrix is a unit test.
//

import Foundation

nonisolated enum EditorUndoHint {
    enum Chord: Equatable, Sendable { case undo, redo }

    /// The line to speak, or nil to stay quiet.
    ///
    /// **The rule, exactly:** speak only when the text stack has nothing to
    /// offer AND the structural stack does. A quiet ⌘Z with both stacks empty
    /// says nothing — there is no change of any kind to point at, and a hint
    /// there would be noise on every fresh note.
    ///
    /// `structuralUndoLabel` / `structuralRedoLabel` are the session's live
    /// `UndoMenuState` projection — the same two values the Edit menu's own
    /// enablement reads, so the sign and the door can never disagree about
    /// whether there is anything there.
    static func message(
        for chord: Chord,
        textStackHasEntries: Bool,
        structuralUndoLabel: String?,
        structuralRedoLabel: String?
    ) -> String? {
        guard !textStackHasEntries else { return nil }
        switch chord {
        case .undo:
            guard structuralUndoLabel != nil else { return nil }
            return "Nothing to undo in the text — your last change was structural: "
                + "\u{2325}\u{2318}Z undoes it, \u{21e7}\u{2325}\u{2318}Z redoes."
        case .redo:
            guard structuralRedoLabel != nil else { return nil }
            return "Nothing to redo in the text — the change you undid was structural: "
                + "\u{21e7}\u{2325}\u{2318}Z redoes it, \u{2325}\u{2318}Z undoes again."
        }
    }
}
