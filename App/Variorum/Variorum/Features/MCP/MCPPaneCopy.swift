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

nonisolated enum MCPPaneCopy {
    // MARK: - The server

    /// The toggle (mockup §1, verbatim).
    static let enableTitle = "Enable the MCP server"
    /// The toggle's sentence (mockup §1). U1 adaptation: "can read and write
    /// here" reads "can read here", and the clause about AI work landing as
    /// takes waits for the write rungs (U2) — the read rung is all U1 ships,
    /// so the sentence promises only what is true today.
    static let enableBlurb =
        "Runs a local MCP server while Variorum is open, so clients like Claude Code can read "
        + "here through Variorum's own operations. Nothing is readable until you grant it, every "
        + "grant is revocable, and no client can overwrite your text."

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
    static let noClients = "No clients yet. A client appears here the first time it connects."
    static let connectedNow = "connected now"
    static func lastSeen(_ when: String) -> String { "last seen \(when)" }
    static let deniedState = "denied"
    static let noAccess = "approved \u{00B7} nothing shared"
    static func reads(_ count: Int) -> String {
        count == 1 ? "reads 1 shared place" : "reads \(count) shared places"
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

    static func rungWord(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "read"
        case .suggest: "read and suggest"
        case .writeNew: "write new"
        case .edit: "edit"
        }
    }

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
    static let readRung = "Read"
    static let readRungDetail = "it can read and search what you shared"
    /// U1: read is the only rung that exists; the other three arrive with
    /// U2/U3 on this same sheet (A-9).
    static let laterRungsNote = "Suggest, write new and edit arrive in a later update."
    static let cancel = "Cancel"

    static func confirm(verb: String, place: String, duration: MCPGrantRule.Duration) -> String {
        "\(verb) read in \u{201C}\(place)\u{201D} \(durationWord(duration))"
    }

    // MARK: - Refusals in the pane (the operations layer's own errors)

    static func refusal(_ error: Error) -> String {
        switch error as? OperationError {
        case .mcpClientNotApproved?: "Approve the client before granting it access."
        case .mcpGrantScopeFenced?: "Journals are shared one ask at a time, never by a standing grant."
        case .mcpGrantScopeNotFound?: "That place no longer exists."
        case .mcpClientNotFound?: "That client no longer exists."
        case .mcpGrantNotFound?: "That grant no longer exists."
        default: "Couldn't do that: \(error)"
        }
    }
}
