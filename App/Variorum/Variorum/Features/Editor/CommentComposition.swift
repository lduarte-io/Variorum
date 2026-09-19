//
//  CommentComposition.swift
//  Variorum
//
//  13u3 UNIT A2 — **the comments panel's writing semantics, as ONE pure
//  rule** (the gutter memo's §2 D; her item 3, verbatim: *"the comment add
//  box is so small and it doesn't make sense given how big the overall
//  comment box is that the whole thing isn't more of the text editor that
//  you can write and click on"*).
//
//  The panel becomes one writing surface: every comment is an editable text
//  area in place and the add area owns the space they leave. That means the
//  panel now holds DRAFTS — one per comment plus the add draft — and four
//  questions the old bordered-field swap never had to answer: what does a
//  commit write, what does an emptied comment mean, what does ⎋ undo, and
//  which drafts survive a projection arrival.
//
//  They live HERE, pure and unit-tested, for the reason every brain in this
//  codebase does: a view that answers them inline answers them differently
//  at the next touch, and the answers are the FACE (what she loses, what she
//  keeps) rather than pixels. The panel's view renders; this decides.
//
//  **Placement:** Mac-side deliberately. The phone's comments sheet
//  (`MobileComments`) mirrors the Mac panel's semantics and owes a version of
//  this face — when it builds one, this brain hoists to `App/Variorum/Shared/`
//  under the standing hoist-at-next-touch rule rather than being copied.
//

import Foundation

/// The panel's edit/file/escape decisions. Pure, no types from the store, so
/// every cell below is a table test.
///
/// `nonisolated` for the reason `RecoveryStatus` is: the app target's default
/// isolation is the main actor, and a pure rule that answers a question about
/// two strings has no business demanding one.
nonisolated enum CommentComposition {
    /// What the Add door (⌘⏎ in the add area, or the button) does.
    enum Filing: Equatable {
        /// Nothing typed — the door is silent, never a scold. (P-2's letter:
        /// a door that cannot act in its context is not rendered, and the
        /// Add button is disabled in exactly this state; ⌘⏎ has no button to
        /// grey, so it simply does nothing.)
        case nothing
        /// File this text as a new comment.
        case file(String)
    }

    /// What a comment's own commit (⌘⏎, or moving focus away) writes.
    enum Commit: Equatable {
        /// The draft says what the store already says — no write, no
        /// receipt, no touch. (The op has this guard too; deciding it here
        /// means the panel never even opens a transaction.)
        case unchanged
        /// She emptied it. A comment with no text is not a comment, and
        /// "empty it to delete it" is a gesture nobody ruled — so this
        /// refuses and the draft goes back to what is stored. Delete is the
        /// door that removes a comment, and it is one click away.
        case emptied
        /// Save this text.
        case save(String)
    }

    /// What ⎋ undoes — a ladder, most local first.
    enum Escape: Equatable {
        /// Throw away the add draft.
        case clearDraft
        /// Put this comment back to what is stored.
        case revert(String)
        /// Nothing is being written — close the panel.
        case close
    }

    /// What the panel is currently writing (the view's focus, as a value).
    enum Writing: Equatable {
        case addDraft(String)
        case comment(id: String, draft: String, stored: String)
        case nothing
    }

    /// **THE ONE TRIM RULE.** Ends only: a comment's own paragraphs are
    /// content (`text` is free prose — ⏎ inside the draft is a newline), and
    /// the whitespace she leaves hanging off either end is not.
    ///
    /// It applies to the EDIT road as well as the add road, which is the one
    /// place the shipped panel had two rules for one thing: `addDraft`
    /// trimmed and the edit field did not, so the same keystrokes stored
    /// different text depending on which box they were typed in (and a
    /// trailing newline then rendered as a dangling blank line in the margin
    /// card). One rule, both roads.
    static func trimmed(_ draft: String) -> String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func filing(_ draft: String) -> Filing {
        let text = trimmed(draft)
        return text.isEmpty ? .nothing : .file(text)
    }

    static func commit(draft: String, stored: String) -> Commit {
        let text = trimmed(draft)
        if text.isEmpty { return .emptied }
        if text == stored { return .unchanged }
        return .save(text)
    }

    /// Dirty means exactly "committing would do something" — so a draft that
    /// differs from the store only by the whitespace the trim rule eats is
    /// CLEAN, and the row does not claim unsaved changes it would not write.
    static func isDirty(draft: String, stored: String) -> Bool {
        commit(draft: draft, stored: stored) != .unchanged
    }

    static func escape(writing: Writing) -> Escape {
        switch writing {
        case .addDraft(let draft):
            // Anything typed is cleared, whitespace included; a second ⎋
            // closes. (The empty test is on the RAW draft on purpose: ⎋
            // should visibly do something whenever the box is not empty.)
            return draft.isEmpty ? .close : .clearDraft
        case .comment(let id, let draft, let stored):
            return isDirty(draft: draft, stored: stored) ? .revert(id) : .close
        case .nothing:
            return .close
        }
    }

    /// **WHICH DRAFTS SURVIVE A PROJECTION ARRIVAL.** The panel observes the
    /// store, so a snapshot can land mid-sentence — her own save echoing
    /// back, another surface's edit, a sync apply. The rule:
    ///
    ///  · a draft whose comment is GONE (deleted, tombstoned elsewhere) is
    ///    dropped — there is no row left to save it into;
    ///  · a draft that would write nothing (the trim rule) is dropped — that
    ///    is the shape her own successful save takes when it echoes back, and
    ///    a kept one would mark a saved row "unsaved" forever;
    ///  · anything else is KEPT, because it is prose she has typed and
    ///    nothing in this app throws that away quietly.
    ///
    /// `stored` is id → the comment's current text.
    static func survivingDrafts(
        _ drafts: [String: String], stored: [String: String]
    ) -> [String: String] {
        drafts.filter { id, draft in
            guard let text = stored[id] else { return false }
            return isDirty(draft: draft, stored: text)
        }
    }
}
