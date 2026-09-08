//
//  NoteBoxFactsModel.swift
//  Variorum (Mac)
//
//  18d batch 1 — the note box's FACTS, fetched once per selection.
//
//  ── THE CADENCE, AND WHY IT IS NOT AN OBSERVATION ────────────────────────
//  The retired details gutter read its one fact per REALIZED ROW; this reads
//  the note's facts per SELECTION — one note at a time, when the box's
//  subject changes. It is deliberately NOT a `ValueObservation`: the facts
//  read `variant`, which is the table autosave writes, so a standing
//  observation would re-run the whole read on every keystroke of every take
//  in the note (the `trayCounts` finding's class, and P1's own rule). The
//  accepted consequence, recorded rather than hidden: while a note is LIVE
//  its facts are as of the moment it went live — the counts she is watching
//  change are the bar's, which are incremental and live. Leaving the live
//  state re-reads.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class NoteBoxFactsModel {
    /// The note the facts in hand are about — read by the view so a stale
    /// note's numbers never appear under a new note's title.
    private(set) var subject: String?
    private(set) var facts: NoteBoxFacts?

    /// The facts, but only if they are THIS note's.
    func facts(for postID: String?) -> NoteBoxFacts? {
        guard let postID, subject == postID else { return nil }
        return facts
    }

    func clear() {
        subject = nil
        facts = nil
    }

    /// One read: the note's rendered slots (blocks · words · fanned blocks)
    /// and its two stamps. Cost ∝ this note's own blocks, never the corpus.
    func load(session: AppSession, postID: String?) async {
        guard let postID else {
            clear()
            return
        }
        let read = try? await session.database.read { db -> NoteBoxFacts? in
            let slots = try Queries.renderPost(db, containerID: postID)
            guard let stamps = try Queries.noteStamps(db, postID: postID) else { return nil }
            return NoteBoxFacts(
                words: slots.compactMap(\.text).reduce(0) { $0 + Queries.wordCount($1) },
                blocks: slots.count,
                fannedBlocks: slots.filter(\.hasFan).count,
                editedAt: stamps.editedAt,
                savedAt: stamps.savedAt)
        }
        // A SUPERSEDED read leaves both to the newer task (the round-end
        // Fable pass, NIT-4): `.task(id:)` cancels this task on a key change,
        // but the database read is not cancellation-aware mid-flight, and an
        // old note's read finishing last would otherwise claim `subject` and
        // leave the new note factless until the next selection. This guard
        // sits ABOVE both assignments and is a different question from the
        // `read == nil` case below, which deliberately claims the subject.
        guard !Task.isCancelled else { return }
        // A note that vanished between the ask and the read (a tombstone, a
        // sync arrival) leaves the box factless rather than wrong.
        subject = postID
        facts = read ?? nil
    }
}
