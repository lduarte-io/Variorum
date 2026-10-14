import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE EDIT RUNG's tool projections** (13n-b U3 — R-13n-4's edit rung; the
/// mockup §9's `edit_take · divide_block · merge_blocks · move_block ·
/// delete_block`, plus R-13nb-8's `set_block_name`) and the write-new rung's
/// `create_section` (R-13nb-11 G-1). Thin projections of `Operations+MCPEdits`
/// — her doors' own acts, each one client-named undo entry.
///
/// **THE GUARD — the decide/act gap closed rung-wide (AF-10 (a); the U2
/// ladder's F2):** every act here is decided TWICE. The snapshot decision
/// (`onNote`/`onBlock`/`into`, `spendsAfter: false`) speaks the refusal and
/// raises the just-in-time ask, exactly as the lower rungs do. Then the act
/// runs with a `WriteGuard` that RE-DECIDES through the same pure rule on
/// facts read INSIDE the act's own write transaction — the target's note
/// re-resolved from its block or take, every note the act touches decided —
/// and stamps any once grant it spends right there, atomic with the act (so
/// the edit rung has no crash corner either, P-13nb-U2-8's class). A note
/// fenced, or a block moved, by a sync apply landing between the two can
/// never be written past; the act refuses whole and rolls back.
extension MCPWriteTools {
    enum EditJob: Sendable {
        case editTake(takeID: String, text: String, expectedText: String)
        case divide(blockID: String, secondHalfStartsWith: String)
        case merge(firstBlockID: String, secondBlockID: String)
        case move(blockID: String, target: MoveTarget)
        case delete(blockID: String)
        case name(blockID: String, name: String?)
        case createSection(bookID: String, name: String)
        /// 13n-c U6 — the per-item note move across wings (`MCPWriteTools+WingMove`).
        case moveToWing(noteID: String, wingID: String)

        var tool: String {
            switch self {
            case .editTake: MCPToolCatalog.editTake.name
            case .divide: MCPToolCatalog.divideBlock.name
            case .merge: MCPToolCatalog.mergeBlocks.name
            case .move: MCPToolCatalog.moveBlock.name
            case .delete: MCPToolCatalog.deleteBlock.name
            case .name: MCPToolCatalog.setBlockName.name
            case .createSection: MCPToolCatalog.createSection.name
            case .moveToWing: MCPToolCatalog.moveNoteToWing.name
            }
        }

        /// VX-275 (`Job.flushesHerEditorFirst`): the edit rung's text acts.
        var flushesHerEditorFirst: Bool {
            switch self {
            // REWRITE: `expected_text` is checked against the STORED row.
            case .editTake: true
            // STRUCTURE: the cut and the join read the STORED takes; a divide
            // keeps her block's identity as its first half (her old buffer
            // would land there whole), a merge releases her block.
            case .divide, .merge: true
            // TOMBSTONE: her take dies with the block.
            case .delete: true
            // A place, a name, a chapter, a wing: her take's text untouched,
            // her flush lands in the take she typed in.
            case .move, .name, .createSection, .moveToWing: false
            }
        }
    }

    /// `edit_take`'s one refusal of a blank text (VX-168 U3, P-VX171-2 —
    /// PROVISIONAL words, P-VX168-U3-2): says the road that IS open.
    static let editTakeBlankRefusal =
        "edit_take never empties a take. For a blank take, use add_take with an empty text."

    /// Where `move_block` puts the block.
    enum MoveTarget: Sendable, Equatable {
        case after(blockID: String)
        case before(blockID: String)
        case note(id: String, atStart: Bool)
    }

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseEdit(_ name: String, _ args: [String: Value]) throws -> EditJob? {
        switch name {
        case MCPToolCatalog.editTake.name:
            guard let text = try optionalString(args, "text") else {
                throw ArgumentFailure(message: "text is required (the take's whole new text).")
            }
            // VX-168 U3 (P-VX171-2, QUESTIONS #211): clearing a take is not
            // this door's act — blanking a block in a lens is a BLANK TAKE
            // (`add_take` with an empty text, R-VX171-2), never an edit that
            // empties her text. The provisional's "stays refused" had no
            // standing refusal under it (the probe pin landed the clear and
            // both brackets on the pre-unit tree); this line makes it true.
            // Whitespace alone is blank too (PROVISIONAL P-VX168-U3-2).
            guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ArgumentFailure(message: Self.editTakeBlankRefusal)
            }
            guard let expected = try optionalString(args, "expected_text") else {
                throw ArgumentFailure(message: "expected_text is required: the take's text exactly as you read it.")
            }
            return .editTake(takeID: try requiredString(args, "take_id"), text: text, expectedText: expected)
        case MCPToolCatalog.divideBlock.name:
            return .divide(
                blockID: try requiredString(args, "block_id"),
                secondHalfStartsWith: try requiredText(args, "second_half_starts_with"))
        case MCPToolCatalog.mergeBlocks.name:
            let first = try requiredString(args, "first_block_id")
            let second = try requiredString(args, "second_block_id")
            guard first != second else { throw ArgumentFailure(message: "A block can't merge with itself.") }
            return .merge(firstBlockID: first, secondBlockID: second)
        case MCPToolCatalog.moveBlock.name:
            let blockID = try requiredString(args, "block_id")
            let after = try optionalString(args, "after_block_id")
            let before = try optionalString(args, "before_block_id")
            let note = try optionalString(args, "note_id")
            let at = try optionalString(args, "at")
            let target: MoveTarget
            switch (after, before, note) {
            case (let anchor?, nil, nil): target = .after(blockID: anchor)
            case (nil, let anchor?, nil): target = .before(blockID: anchor)
            case (nil, nil, let note?):
                guard at == nil || at == "start" || at == "end" else {
                    throw ArgumentFailure(message: "at must be \"start\" or \"end\".")
                }
                target = .note(id: note, atStart: at == "start")
            default:
                throw ArgumentFailure(message: "Pass exactly one of after_block_id, before_block_id or note_id.")
            }
            if at != nil, note == nil {
                throw ArgumentFailure(message: "at goes with note_id.")
            }
            if case .after(let anchor) = target, anchor == blockID {
                throw ArgumentFailure(message: "A block can't move next to itself.")
            }
            if case .before(let anchor) = target, anchor == blockID {
                throw ArgumentFailure(message: "A block can't move next to itself.")
            }
            return .move(blockID: blockID, target: target)
        case MCPToolCatalog.deleteBlock.name:
            return .delete(blockID: try requiredString(args, "block_id"))
        case MCPToolCatalog.setBlockName.name:
            return .name(blockID: try requiredString(args, "block_id"), name: try optionalString(args, "name"))
        case MCPToolCatalog.createSection.name:
            return .createSection(bookID: try requiredString(args, "book_id"), name: try requiredText(args, "name"))
        case MCPToolCatalog.moveNoteToWing.name:
            // "" is Home — present but empty is the one legal empty id.
            guard let wingID = try optionalString(args, "wing_id") else {
                throw ArgumentFailure(message: "wing_id is required (\"\" is Home).")
            }
            return .moveToWing(noteID: try requiredString(args, "note_id"), wingID: wingID)
        default:
            return nil
        }
    }

    // MARK: - The serial body

    func performEdit(_ edit: EditJob, job: Job, ops: Operations, clientName: String) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch edit {
        case .editTake(let takeID, let text, let expected):
            let noteID = try database.read { try Queries.mcpContainerOf(take: takeID, $0) } ?? ""
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName,
                              logged: ("take", takeID), spendsAfter: false) { title in
                let edit = try ops.editTakeUnderInsurance(
                    takeID, text: text, expectedText: expected, client: clientName,
                    undoLabel: label(.edit),
                    guardedBy: guardEdit(clientName) { db in [try Queries.mcpContainerOf(take: takeID, db)] })
                var answer: [String: Any] = [
                    "take_id": takeID, "block_id": edit.take.blockId, "note_id": noteID, "changed": edit.changed,
                ]
                if let before = edit.before { answer["before_commit_id"] = before.id }
                if let after = edit.after { answer["after_commit_id"] = after.id }
                return (answer, edit.changed
                        ? MCPWriteReceipt(clientName: clientName, act: .edit, targetID: noteID, targetTitle: title,
                                          show: .note(noteID: noteID, blockID: edit.take.blockId, select: nil))
                        : nil)
            }

        case .divide(let blockID, let anchor):
            return try onBlock(blockID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { noteID, title in
                guard let shown = try database.read({ try Queries.mcpShownTake($0, blockID: blockID) }) else {
                    throw Refused(outcome: Outcome(text: MCPRefusalCopy.words(.notShared, .note), isError: true))
                }
                let cut = try Self.cut(in: shown.workingText, before: anchor)
                let result = try ops.divideBlock(
                    blockID, cut: cut, shownTakeID: shown.id, expectedText: shown.workingText,
                    undoLabel: label(.divide), guardedBy: guardEdit(clientName) { db in
                        [try Queries.mcpContainerOf(block: blockID, db)]
                    })
                return ([
                    "note_id": noteID, "first_block_id": result.firstBlockID,
                    "second_block_id": result.secondBlockID, "kept_on_top": result.keptOnTop,
                    "stayed_behind": result.stayedBehind,
                ], MCPWriteReceipt(clientName: clientName, act: .divide, targetID: noteID, targetTitle: title,
                                   show: .note(noteID: noteID, blockID: result.firstBlockID, select: nil)))
            }

        case .merge(let first, let second):
            return try onBlock(first, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { noteID, title in
                let result = try ops.mergeBlocks(
                    first, second, undoLabel: label(.merge), guardedBy: guardEdit(clientName) { db in
                        [try Queries.mcpContainerOf(block: first, db), try Queries.mcpContainerOf(block: second, db)]
                    })
                return (["note_id": noteID, "block_id": result.blockID, "carried": result.carried],
                        MCPWriteReceipt(clientName: clientName, act: .merge, targetID: noteID, targetTitle: title,
                                        show: .note(noteID: noteID, blockID: result.blockID, select: nil)))
            }

        case .move(let blockID, let target):
            return try onBlock(blockID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { noteID, title in
                // The destination, read now and RE-read inside the act's
                // transaction by the guard (an anchor block moved since
                // re-decides on where it is now).
                let destinationOf: (Database) throws -> String? = { db in
                    switch target {
                    case .after(let anchor), .before(let anchor): try Queries.mcpContainerOf(block: anchor, db)
                    case .note(let id, _): id
                    }
                }
                guard let destination = try database.read(destinationOf) else {
                    throw Refused(outcome: Outcome(text: MCPRefusalCopy.words(.notShared, .note), isError: true))
                }
                let insert: Operations.InsertPosition = switch target {
                case .after(let anchor): .after(anchor)
                case .before(let anchor): .before(anchor)
                case .note(_, let atStart): atStart ? .start : .end
                }
                let decided = guardEdit(clientName) { db in
                    [try Queries.mcpContainerOf(block: blockID, db), try destinationOf(db)]
                }
                // Wings isolate TOTALLY (the sitting record §9): the only
                // crossings are the explicit wing move/copy doors, never a
                // block walking between libraries here (its block tags would
                // name the source wing's vocabulary). PROVISIONAL P-13nb-U3-5.
                let checks: Operations.WriteGuard = { db in
                    try decided(db)
                    let ends = [try Queries.mcpContainerOf(block: blockID, db), try destinationOf(db)]
                        .compactMap { $0 }
                    let wings = try Queries.mcpNoteFacts(db, noteIDs: ends)
                    if Set(ends.map { wings[$0]?.wingID }).count > 1 {
                        throw Refused(outcome: Outcome(text: Self.otherWingWords, isError: true))
                    }
                }
                try ops.registeringUndo(as: label(.move)) {
                    if destination == noteID {
                        try ops.reorder(blockID, to: insert, guardedBy: checks)
                    } else {
                        try ops.moveBlock(blockID, to: destination, at: insert, guardedBy: checks)
                    }
                }
                return (["block_id": blockID, "note_id": destination, "from_note_id": noteID],
                        MCPWriteReceipt(clientName: clientName, act: .move, targetID: noteID, targetTitle: title,
                                        show: .note(noteID: destination, blockID: blockID, select: nil)))
            }

        case .delete(let blockID):
            return try onBlock(blockID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { noteID, title in
                try ops.registeringUndo(as: label(.delete)) {
                    try ops.deleteBlock(blockID, guardedBy: guardEdit(clientName) { db in
                        [try Queries.mcpContainerOf(block: blockID, db)]
                    })
                }
                return (["block_id": blockID, "note_id": noteID, "deleted": true],
                        MCPWriteReceipt(clientName: clientName, act: .delete, targetID: noteID, targetTitle: title,
                                        show: .note(noteID: noteID, blockID: nil, select: nil)))
            }

        case .name(let blockID, let name):
            return try onBlock(blockID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { noteID, title in
                let changed = try ops.setBlockName(
                    blockID, name: name, undoLabel: label(.blockName), guardedBy: guardEdit(clientName) { db in
                        [try Queries.mcpContainerOf(block: blockID, db)]
                    })
                let current = try database.read { db in
                    try String.fetchOne(db, sql: "SELECT name FROM block WHERE id = ?", arguments: [blockID])
                }
                return (["block_id": blockID, "note_id": noteID, "name": current ?? NSNull(), "changed": changed],
                        changed
                        ? MCPWriteReceipt(clientName: clientName, act: .blockName, targetID: noteID,
                                          targetTitle: title, detail: current,
                                          show: .note(noteID: noteID, blockID: blockID, select: nil))
                        : nil)
            }

        case .createSection(let bookID, let name):
            return try into(.book(bookID), job: job, clientName: clientName, spendsAfter: false) { _ in
                let section = try ops.createSection(
                    in: bookID, name: name, undoLabel: label(.chapter), guardedBy: guardBook(clientName, bookID))
                return (["section_id": section.id, "book_id": bookID, "name": section.name],
                        MCPWriteReceipt(clientName: clientName, act: .chapter, targetID: bookID,
                                        targetTitle: nil, detail: section.name,
                                        show: .book(bookID: bookID, sectionID: section.id)))
            }

        case .moveToWing(let noteID, let wingID):
            return try performWingMove(noteID: noteID, wingID: wingID, job: job, ops: ops, clientName: clientName)
        }
    }

    // MARK: - THE GUARDS (decided again, inside the act's transaction)

    /// Every note the act touches, re-resolved on the act's own rows and
    /// decided at EDIT through the pure rule; any once grant the decisions
    /// spend is stamped here, atomic with the act. A note that is gone, or
    /// a block or take that lives in none, answers the one `notShared`.
    func guardEdit(
        _ clientName: String, notes: @escaping (Database) throws -> [String?]
    ) -> Operations.WriteGuard {
        guardNotes(clientName, rung: .edit, notes: notes)
    }

    /// `guardEdit` at any rung (13n-b U4: `save_version` is write new — the
    /// same seam, carried to the new acts of this unit).
    func guardNotes(
        _ clientName: String, rung: MCPGrantRule.Rung, notes: @escaping (Database) throws -> [String?]
    ) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            var spend = Set<String>()
            for noteID in try notes(db) {
                let facts = try Queries.mcpNoteFacts(db, noteID: noteID ?? "")
                let decision = MCPGrantAuthority.decide(standing, note: facts, rung: rung, consumes: true)
                guard case .allow(let grantID, let consumesOnce) = decision else {
                    throw Self.refused(decision, .note)
                }
                if consumesOnce, let grantID { spend.insert(grantID) }
            }
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }

    /// A write-new act in a BOOK (`create_section`), decided again inside the
    /// act's transaction (the same seam, applied to the one new write-new act
    /// of this unit — the U2 ops keep their recorded shape, P-13nb-U2-8).
    func guardBook(_ clientName: String, _ bookID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let decision = MCPGrantAuthority.decide(
                standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .writeNew, consumes: true)
            guard case .allow(let grantID, let consumesOnce) = decision else { throw Self.refused(decision, .book) }
            if consumesOnce, let grantID { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }

    /// `move_block` toward a note in another wing (P-13nb-U3-5).
    static let otherWingWords =
        "That note is in another wing — each wing is a separate library, so a block can't move between them."

    static func refused(_ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target) -> Refused {
        let reason = MCPRefusalCopy.reason(of: decision) ?? .notShared
        return Refused(outcome: Outcome(text: MCPRefusalCopy.words(reason, target), isError: true))
    }

    // MARK: - The cut, addressed by text (AF-10 (c))

    /// The UTF-16 offset where `anchor` begins in `text` — it must occur
    /// EXACTLY ONCE (an LLM names the words, never counts the units), and
    /// not at the very start (a divide needs text on both sides).
    static func cut(in text: String, before anchor: String) throws -> Int {
        var found: [Range<String.Index>] = []
        var from = text.startIndex
        while from < text.endIndex, found.count < 2,
              let range = text.range(of: anchor, options: .literal, range: from..<text.endIndex) {
            found.append(range)
            from = text.index(after: range.lowerBound)
        }
        guard let first = found.first else {
            throw ArgumentFailure(message:
                "second_half_starts_with isn't in the block's shown take (read_note with with_ids: true gives its text).")
        }
        guard found.count == 1 else {
            throw ArgumentFailure(message:
                "second_half_starts_with appears more than once in the block's shown take — give more of it.")
        }
        let offset = first.lowerBound.utf16Offset(in: text)
        guard offset > 0 else {
            throw ArgumentFailure(message: "The block already begins there — a divide needs text before the cut.")
        }
        return offset
    }
}
