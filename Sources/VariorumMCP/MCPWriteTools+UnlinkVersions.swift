import Foundation
import GRDB
import MCP
import VariorumCore

/// **`unlink_versions` — one version link taken back by its edge id** (VX-943,
/// the VX-915 run's batch 6; her relay: "an unlink_versions that takes the ID
/// link_versions already returns, at the same permission level"; the record
/// `notes/plans/fixes/vx-915-recents-sweep.md` BATCH 6). A thin projection of
/// `Operations.unlinkVersionForClient` (the link's tombstone through the one
/// statement link_versions' own undo writes, ONE client-named undo entry).
///
/// **THE ORDER — every answer a pure function of the client's reach (VX-825):**
/// 1. the id resolves to a `version_of` link between two notes' placed blocks
///    (`Queries.mcpVersionLinkEnds`), else the ONE not-shared shape — no ask,
///    nothing to ask about;
/// 2. **BOTH notes READABLE before any other answer** — a link to a note the
///    client cannot read answers the one shape, byte-identical to an id naming
///    nothing: a store without the hidden note has no such link at all, so a
///    readable side's rung refusal (or any of the act's own refusals) would
///    tell the client the far side exists. The unreadable side's write-new ask
///    is raised silently, as `link_versions` raises one on a named note it
///    cannot reach (the answer stays the one shape). A SAVED VERSION's link is
///    reached through its NOTE alone (`read_note`'s `version_id` posture: the
///    version rides its note's read);
/// 3. the act's own facts, before any rung — no grant could make either land,
///    so neither raises an ask: a saved version's link refuses in words
///    (PROVISIONAL P-915-B6-2 — her door promotes there, after a confirm; the
///    wire never bare-unlinks one, which would declassify the version), and a
///    link already gone refuses in words (P-915-B6-3 — `remove_tag`'s not-worn
///    precedent);
/// 4. **WRITE NEW on both notes** (the agent's ask she relayed — R-VX187-1's
///    rung, an OPEN choice for her: PROVISIONAL P-915-B6-1; the VX-915
///    ladder's F-3), in the link's stored order: the first short side speaks
///    `rungTooLow` + the asked sentence and raises ITS ask;
/// 5. the act, behind a guard that decides both notes again at write new on
///    ONE standing read inside its own transaction and spends their once
///    grants there as one union — both spend or neither.
///
/// No wing rule (her own unmark has none). The Activity row names the note
/// that refused (else the link's first note); `list_my_activity` answers every
/// refused row of this act with no target (`MCPOwnActivity.hidesTarget` — the
/// logged note is resolved, not sent).
extension MCPWriteTools {
    /// P-915-B6-2's sentence (PROVISIONAL — her words pass).
    static let savedVersionLinkWords =
        "That link ties a note to one of its saved versions, so only the author can remove it: in Compare, "
        + "unmarking a saved version promotes it to a regular note."

    /// P-915-B6-3's sentence (PROVISIONAL — her words pass).
    static let linkAlreadyGoneWords = "That link is already gone \u{2014} nothing was unlinked."

    // MARK: - The serial body

    func performUnlinkVersions(
        edgeID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, ends, facts, titles, versionNote) = try database.read { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            guard let ends = try Queries.mcpVersionLinkEnds(db, edgeID: edgeID) else {
                return (standing, Queries.MCPVersionLinkEnds?.none, [String: MCPGrantRule.NoteFacts](),
                        [String: String](), String?.none)
            }
            let facts = try Queries.mcpNoteFacts(db, noteIDs: ends.noteIDs)
            var titles: [String: String] = [:]
            for noteID in Set(ends.noteIDs) where facts[noteID] != nil {
                titles[noteID] = try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
            }
            return (standing, ends, facts, titles, try Queries.mcpSavedVersionNote(db, of: ends))
        }
        let asking = MCPAsking(onAsk: hooks.onAsk)
        func refuse(_ noteID: String?, _ outcome: Outcome) throws -> Result<Landed, Refused> {
            try log(clientName, job.tool, "note", noteID, noteID.flatMap { titles[$0] }, allowed: false)
            return .failure(Refused(outcome: outcome))
        }
        func ask(_ noteID: String) -> MCPAsk? {
            facts[noteID].map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                       title: titles[noteID] ?? "", rung: .writeNew, fence: $0.fence) }
        }
        // 1. An id naming no link between two notes' placed blocks.
        guard let ends else {
            let missing = MCPGrantAuthority.decide(standing, note: nil, rung: .writeNew, consumes: true)
            return try refuse(nil, asking.refusal(missing, .note, standing: standing, ask: nil))
        }
        // The notes the link reaches: its two ends (once, for a link inside
        // one note) — or a saved version's link: its NOTE alone.
        let reached: [String] = versionNote.map { [$0] }
            ?? (ends.noteIDs[0] == ends.noteIDs[1] ? [ends.noteIDs[0]] : ends.noteIDs)
        // 2. Both readable before anything else is said. READ is the lowest
        // rung, so its refusal is never `rungTooLow` — the words are the one
        // shape (or the client's own pending/denied state); the ask, raised
        // silently, is the act's (write new).
        for noteID in reached {
            let read = MCPGrantAuthority.decide(standing, note: facts[noteID], rung: .read, consumes: false)
            guard read.isAllowed else {
                return try refuse(noteID, asking.refusal(
                    read, .note, standing: standing, ask: versionNote == nil ? ask(noteID) : nil))
            }
        }
        // 3. The act's own facts — no grant could make either land.
        if let versionNote { return try refuse(versionNote, Outcome(text: Self.savedVersionLinkWords, isError: true)) }
        guard ends.live else { return try refuse(ends.noteIDs[0], Outcome(text: Self.linkAlreadyGoneWords, isError: true)) }
        // 4. Write new on each note, the first short side speaking.
        for noteID in reached {
            let decision = MCPGrantAuthority.decide(standing, note: facts[noteID], rung: .writeNew, consumes: true)
            guard decision.isAllowed else {
                return try refuse(noteID, asking.refusal(decision, .note, standing: standing, ask: ask(noteID)))
            }
        }
        // 5. The act.
        let first = ends.noteIDs[0]
        return try land(job, clientName: clientName, kind: "note", id: first, title: titles[first]) {
            let unlink: Operations.MCPVersionUnlink
            do {
                unlink = try ops.unlinkVersionForClient(
                    edgeID, undoLabel: Operations.MCPWriteAct.versionUnlink.undoLabel(client: clientName),
                    guardedBy: guardNotes(clientName, rung: .writeNew) { db in
                        try Queries.mcpVersionLinkEnds(db, edgeID: edgeID)?.noteIDs.map(Optional.some) ?? [nil]
                    })
            } catch let refusal as Operations.MCPVersionUnlinkRefusal {
                throw Refused(outcome: Outcome(text: Self.words(refusal), isError: true))
            }
            let notes = unlink.ends.noteIDs
            // Her receipt's Open › opens the two in Compare — link_versions'
            // own landing, so she sees them apart (a link inside one note
            // opens the note at the link's first block).
            let oneNote = notes[0] == notes[1]
            let show: MCPShowTarget = oneNote
                ? .note(noteID: notes[0], blockID: unlink.ends.blockIDs[0], select: nil)
                : .compare(noteID: notes[0], peerIDs: [notes[1]])
            // The receipt names the far note as `detail` — and, for a link inside
            // one note, carries the note ONCE (`detail` nil), so her line says
            // "inside “A”", never "between “A” and “A”" (the VX-915 ladder's F-7).
            return (["edge_id": edgeID, "note_ids": notes, "block_ids": unlink.ends.blockIDs, "unlinked": true,
                     "still_versions": unlink.stillVersions],
                    MCPWriteReceipt(clientName: clientName, act: .versionUnlink, targetID: notes[0],
                                    targetTitle: titles[notes[0]], detail: oneNote ? nil : titles[notes[1]],
                                    show: show))
        }
    }

    /// The act's own refusals, worded (VX-362: never a raw case). `noSuchLink`
    /// is the one not-shared shape — the guard decides first, so it is reached
    /// only when the link vanished between the snapshot and the act.
    static func words(_ refusal: Operations.MCPVersionUnlinkRefusal) -> String {
        switch refusal {
        case .noSuchLink: MCPRefusalCopy.words(.notShared, .note)
        case .savedVersion: savedVersionLinkWords
        case .alreadyUnlinked: linkAlreadyGoneWords
        }
    }
}
