//
//  MCPPaneCopy.swift
//  Variorum (MAC ONLY)
//
//  13n-b U1 — Settings ▸ MCP's words, ONE home. The register is DIRECT AND
//  TECHNICAL inside this pane and its sheets (R-13n-5, her words: "it's only
//  for technical people anyway"; P-13n-1 — the app-wide faces an AI act
//  produces keep the app's own voice). A pending client is a CONNECTION
//  REQUEST (Approve… / Deny), never the Arrivals door idiom. Sentence case
//  everywhere (her standing rule). The approved mockup's words
//  (`notes/plans/13n-sitting-mockups/mcp-door-mockups.html` §1–§3) are used
//  verbatim except where U1 cannot yet make them true — each such line says
//  so beside it.
//

import Foundation
import VariorumCore
import VariorumMCP

nonisolated enum MCPPaneCopy {
    // MARK: - The server

    /// The toggle (mockup §1, verbatim).
    static let enableTitle = "Enable the MCP server"
    /// The toggle's sentence — mockup §1 VERBATIM since U2 (P-13nb-U1-12's
    /// U1-true form retired): the write rungs exist, and AI work lands as
    /// takes beside her own.
    static let enableBlurb =
        "Runs a local MCP server while Variorum is open, so clients like Claude Code can read "
        + "and write here through Variorum's own operations. Nothing is readable until you grant "
        + "it, every grant is revocable, and no client can overwrite your text \u{2014} AI work "
        + "lands as takes beside your own."

    /// The status line beside the toggle (mockup §2).
    static func status(_ state: MCPDoor.ServerState) -> String {
        switch state {
        case .off: "off"
        case .running: "running \u{00B7} socket in the app container \u{00B7} serves while Variorum is open"
        case .waitingForLibrary: "on \u{00B7} starts when the library is open"
        case .failed(let reason): "couldn't start: \(reason)"
        }
    }

    // MARK: - Connection requests

    static let requestsSection = "Connection requests"
    static func requestTitle(_ name: String) -> String { "Connection request \u{2014} \(name)" }
    static func requestDetail(firstSeen: String) -> String {
        "First seen \(firstSeen). No access until approved."
    }

    // MARK: - Clients

    static let clientsSection = "Clients"
    /// The walk's third finding: "no clients yet" read wrong beside a
    /// waiting request — a client is LISTED here once decided.
    static let noClients = "None yet \u{2014} a client is listed here once you approve or deny its connection request."
    static let connectedNow = "connected now"
    static func lastSeen(_ when: String) -> String { "last seen \(when)" }
    static let deniedState = "denied"
    static let noAccess = "approved \u{00B7} nothing shared"
    /// U2 walk W-1: rung-agnostic since the write rungs — "reads" was
    /// false of a suggest or write-new grant.
    static func reads(_ count: Int) -> String {
        count == 1 ? "1 shared place" : "\(count) shared places"
    }

    // MARK: - Shared with AI

    static let sharedSection = "Shared with AI"
    static let nothingShared = "Nothing is shared."
    static func sharedDetail(client: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration) -> String {
        "\(client) \u{00B7} \(rungWord(rung)) \u{00B7} \(durationWord(duration))"
    }
    static let missingTarget = "(gone)"

    static func kindChip(_ kind: MCPGrantRule.ScopeKind) -> String {
        switch kind {
        case .note: "note"
        case .book: "book"
        case .wing: "wing"
        }
    }

    /// The shared rows' rung (mockup §2 — "read and suggest"); one table
    /// with the note's line (`MCPRungWords`).
    static func rungWord(_ rung: MCPGrantRule.Rung) -> String { MCPRungWords.reach(rung) }

    static func durationWord(_ duration: MCPGrantRule.Duration) -> String {
        switch duration {
        case .once: "once"
        case .connection: "while connected"
        case .always: "always"
        }
    }

    // MARK: - The open book (mockup §2, verbatim)

    static let openBookSection = "Open book"
    static let openBookTitle = "Everything is readable, always"
    static let openBookDetail = "journals still ask every time"

    // MARK: - Connect a client (R-13nb-5 — "Copy setup command")

    static let connectSection = "Connect a client"
    static let connectSentence =
        "Claude Code registers Variorum with one command. Copy it, run it in a terminal, then "
        + "start a new Claude Code session \u{2014} it adds Variorum for every folder (user scope)."
    static let copiedReceipt = "Copied. Run it in a terminal, then start a new Claude Code session."

    /// The name the client registers the server under: the Debug build's is
    /// its own, so a dev setup never replaces the real one in Claude Code's
    /// config (the A4 fence, extended to the client's registration).
    static func serverName(isDebugBuild: Bool) -> String {
        isDebugBuild ? "variorum-dev" : "variorum"
    }

    /// The command (R-13nb-5): user scope (the CLI's default `local` would
    /// register only the folder she ran it in), the shim's absolute path
    /// quoted for a POSIX shell.
    static func setupCommand(shimPath: String, isDebugBuild: Bool) -> String {
        "claude mcp add -s user \(serverName(isDebugBuild: isDebugBuild)) -- \(shellQuoted(shimPath))"
    }

    static func shellQuoted(_ path: String) -> String {
        var escaped = ""
        for character in path {
            if "\"\\$`".contains(character) { escaped.append("\\") }
            escaped.append(character)
        }
        return "\"\(escaped)\""
    }

    // MARK: - The "all N" road (R-13n-10)

    static func allRoad(_ count: Int) -> String { "all \(count) \u{203A}" }
    static let doneButton = "Done"

    // MARK: - The grant sheet (mockup §3, the U1 form — A-9)

    static func sheetTitle(_ client: String) -> String { "Grant access \u{2014} \(client)" }
    static let sheetLead =
        "The client sees what you grant and nothing else. Refusals speak to it exactly as they "
        + "speak to you."
    static let whereSection = "Where"
    static let howMuchSection = "How much"
    static let howLongSection = "How long"
    static let aBook = "A book"
    static func aBookDetail(_ name: String?) -> String {
        name.map { "\u{201C}\($0)\u{201D} \u{2014} its notes, takes and tags" } ?? "choose a book"
    }
    static let thisWing = "A wing"
    static func wingDetail(_ name: String) -> String {
        "everything in \(name) except journals, which always ask"
    }
    static let noBooks = "No book can be shared yet (journals are shared one ask at a time)."
    /// HOW MUCH — the rungs the server can serve, each with the mockup §3
    /// sentence (U2: read · suggest · write new; edit arrives with U3 — a
    /// rung the server can't serve isn't offered, P-2).
    static let offeredRungs: [MCPGrantRule.Rung] = [.read, .suggest, .writeNew]

    static func rungName(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "Read"
        case .suggest: "Suggest"
        case .writeNew: "Write new"
        case .edit: "Edit"
        }
    }

    /// The mockup §3 sentences, verbatim.
    static func rungDetail(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "it can read and search what you shared"
        case .suggest:
            "it can add new takes and comments beside your text, and save a lens of its takes "
                + "\u{2014} it cannot touch a word you wrote"
        case .writeNew: "it can also make new notes, apply tags and build books"
        case .edit:
            "it can also edit takes \u{2014} with a commit before and after every change, so you "
                + "can always compare and come back"
        }
    }

    static let readRung = "Read"
    static let readRungDetail = rungDetail(.read)
    /// U2: edit is the one rung still to come (U3).
    static let laterRungsNote = "Edit arrives in a later update."
    static let cancel = "Cancel"
    static let whileConnectedNote = "While connected is offered while this client is connected."

    /// "Grant suggest in “the lightning thief” while connected" (mockup §3).
    static func confirm(
        verb: String, rung: MCPGrantRule.Rung = .read, place: String, duration: MCPGrantRule.Duration
    ) -> String {
        "\(verb) \(rungName(rung).lowercased()) in \u{201C}\(place)\u{201D} \(durationWord(duration))"
    }

    // MARK: - Refusals in the pane (the operations layer's own errors)

    static func refusal(_ error: Error) -> String {
        switch error as? OperationError {
        case .mcpClientNotApproved?: "Approve the client before granting it access."
        case .mcpGrantScopeFenced?:
            "Journals and Private notes are shared one ask at a time, never by a standing grant."
        case .mcpGrantScopeNotFound?: "That place no longer exists."
        case .mcpClientNotFound?: "That client no longer exists."
        case .mcpGrantNotFound?: "That grant no longer exists."
        default: "Couldn't do that: \(error)"
        }
    }
}

/// **THE JUST-IN-TIME ASK's words** (13n-b U2 — AF-6; mockup §4). The MCP
/// room's register (direct and technical — R-13n-5; P-13n-1's boundary keeps
/// the grant and ask sheets inside it); sentence case.
nonisolated enum MCPAskCopy {
    /// "claude-code asks to read “morning pages — oct 9”".
    static func title(_ ask: MCPAsk) -> String {
        let verb: String = switch ask.rung {
        case .read: "read"
        case .suggest: "suggest in"
        case .writeNew: "write new in"
        case .edit: "edit in"
        }
        let target = ask.scopeKind == .wing
            ? "the \(ask.title) wing" : "\u{201C}\(ask.title)\u{201D}"
        return "\(ask.clientName) asks to \(verb) \(target)"
    }

    /// The sentence under it: the fence's reason (mockup §4's journal line
    /// verbatim; the Private twin), else what the rung would let it do.
    static func lead(_ ask: MCPAsk) -> String {
        switch ask.fence {
        case .journal?: "A journal entry. Journals are only ever shared one ask at a time."
        case .privateMark?: "Marked Private. Private notes are only ever shared one ask at a time."
        case nil: "If you allow it, " + MCPPaneCopy.rungDetail(ask.rung) + "."
        }
    }

    static func button(_ duration: MCPGrantRule.Duration) -> String {
        switch duration {
        case .once: "Once"
        case .connection: "While connected"
        case .always: "Always"
        }
    }

    static let dontAllow = "Don't allow"

    /// The receipt once her answer lands.
    static func granted(_ ask: MCPAsk, duration: MCPGrantRule.Duration) -> String {
        "Allowed \(ask.clientName): \(MCPPaneCopy.rungName(ask.rung).lowercased()) in "
            + "\u{201C}\(ask.title)\u{201D} \(MCPPaneCopy.durationWord(duration))."
    }
}

/// **AN AI ACT's RECEIPT** (13n-b U2 — the mockup §5 line: "claude added 2
/// takes and saved the lens “english readings” · ⌥⌘Z undoes"). An APP-WIDE
/// face, so the app's voice (P-13n-1), sentence case; the client's own name
/// verbatim. A RUN of acts by one client on one target speaks as one line.
nonisolated enum MCPReceiptCopy {
    static let undoes = "\u{2325}\u{2318}Z undoes"

    static func line(_ run: [MCPWriteReceipt]) -> String {
        guard let first = run.first else { return "" }
        var order: [Operations.MCPWriteAct] = []
        var byAct: [Operations.MCPWriteAct: [MCPWriteReceipt]] = [:]
        for receipt in run {
            if byAct[receipt.act] == nil { order.append(receipt.act) }
            byAct[receipt.act, default: []].append(receipt)
        }
        let parts = order.map { phrase($0, byAct[$0] ?? []) }
        // U2 walk W-2: the mockup's line, no "in “title”" clause, and never
        // so long that the bar's truncation eats the undo — past the budget
        // the run speaks as a count.
        let line = "\(first.clientName) \(joined(parts)) \u{00B7} \(undoes)"
        guard line.count > budget else { return line }
        return "\(first.clientName) made \(run.count) changes \u{00B7} \(undoes)"
    }

    /// The longest line the bottom bar's quiet slot shows whole at the
    /// default window width (measured at the U2 walk — W-2).
    static let budget = 72

    private static func phrase(_ act: Operations.MCPWriteAct, _ receipts: [MCPWriteReceipt]) -> String {
        let n = receipts.count
        let quoted = { (text: String?) in text.map { "\u{201C}\($0)\u{201D}" } ?? "" }
        switch act {
        case .take: return n == 1 ? "added a take" : "added \(n) takes"
        case .comment: return n == 1 ? "left a comment" : "left \(n) comments"
        case .lens: return n == 1 ? "saved the lens \(quoted(receipts[0].detail))" : "saved \(n) lenses"
        case .tag: return n == 1 ? "added the tag #\(receipts[0].detail ?? "")" : "added \(n) tags"
        case .note: return n == 1 ? "made the note \(quoted(receipts[0].targetTitle))" : "made \(n) notes"
        case .importNote: return n == 1 ? "imported \(quoted(receipts[0].targetTitle))" : "imported \(n) notes"
        case .importBook:
            let notes = receipts[0].count
            return "imported the book \(quoted(receipts[0].targetTitle)) (\(notes) \(notes == 1 ? "note" : "notes"))"
        case .book: return "made the book \(quoted(receipts[0].targetTitle))"
        case .bookAdd:
            return n == 1
                ? "added \(quoted(receipts[0].targetTitle)) to \(quoted(receipts[0].detail))"
                : "added \(n) notes to books"
        // 13n-b U3 — the chapter (write new) and the edit rung's acts.
        case .chapter:
            return n == 1 ? "made the chapter \(quoted(receipts[0].detail))" : "made \(n) chapters"
        case .edit: return n == 1 ? "edited a take" : "edited \(n) takes"
        case .divide: return n == 1 ? "divided a block" : "divided \(n) blocks"
        case .merge: return n == 1 ? "merged two blocks" : "merged blocks \(n) times"
        case .move: return n == 1 ? "moved a block" : "moved \(n) blocks"
        case .delete: return n == 1 ? "deleted a block" : "deleted \(n) blocks"
        case .blockName:
            return n == 1
                ? (receipts[0].detail.map { "named a block \(quoted($0))" } ?? "cleared a block's name")
                : "named \(n) blocks"
        }
    }

    private static func joined(_ parts: [String]) -> String {
        guard parts.count > 1 else { return parts.first ?? "" }
        return parts.dropLast().joined(separator: ", ") + " and " + (parts.last ?? "")
    }
}
