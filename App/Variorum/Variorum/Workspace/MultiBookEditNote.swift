//
//  MultiBookEditNote.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 5 — W22: the FIRST-EDIT NOTE (her round-9 ruling,
//  "Stands + first-edit note").
//
//  Round 9 opened with her asking, verbatim: *"honestly, wait. I thought
//  that earlier we decided that editing a post SHOULD always mutate it into
//  a copy? i thought that's how the app is working right now?"* — The record
//  was pulled and R31/R35 stand exactly as decided 2026-07-17: editing a
//  post edits THE post in every book it appears in, and `duplicateAsVersion`
//  is the one deliberate divergence door. What the ruling ADDED is this: the
//  rule's UI legibility was the under-served half (the confusion had
//  surfaced three times), so the first time she edits a post that lives in
//  two or more books, the app says so once and names the door.
//
//  ── THE THREE PROPERTIES THIS TYPE EXISTS TO KEEP ────────────────────────
//  1. **ONE TIME EVER.** An app-local seen flag (the local view-memory
//     family — never synced, never schema, exactly like per-post mode
//     memory). Not once per post: she learns the rule once.
//  2. **NEVER PER-KEYSTROKE.** The flag is checked first, and the membership
//     count is read at most once per opened post — and never again in the
//     app's life after the note has been said.
//  3. **ZERO STORE BYTES.** It reads and it speaks. Pinned.
//

import Foundation

nonisolated enum MultiBookEditNote {
    /// The local flag's key (the `postMode.<id>` family's neighbour).
    static let seenKey = "variorum.multiBookEditNoteSeen"

    /// Her ruled copy grammar, verbatim from round 9: *"editing here edits
    /// it everywhere — Duplicate as Version to diverge"*, said in the app's
    /// own sentence and naming where the door is.
    static func sentence(bookCount: Int) -> String {
        "This note is in \(bookCount) books — editing here edits it everywhere. "
            + "To make a copy that can diverge, use Duplicate as Version "
            + "(the book chip under the title)."
    }

    /// Should the note be said for a post in `bookCount` books? The two
    /// conditions, in one place so the trigger site cannot drift from them.
    static func shouldSpeak(bookCount: Int, seen: Bool) -> Bool {
        !seen && bookCount >= 2
    }

    static func hasBeenSeen(_ defaults: UserDefaults = .standard) -> Bool {
        defaults.bool(forKey: seenKey)
    }

    static func markSeen(_ defaults: UserDefaults = .standard) {
        defaults.set(true, forKey: seenKey)
    }
}
