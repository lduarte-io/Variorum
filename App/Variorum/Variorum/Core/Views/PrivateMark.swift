//
//  PrivateMark.swift
//  Variorum (MAC ONLY)
//
//  13n-b U2 — THE PRIVATE MARK's faces (R-13nb-4, hers: "should we add a
//  designation or book setting like 'Private', so that people can have books
//  that are not shared with AI without them having to be journal type?").
//  The note's row lives in the note ▾ menu of BOTH bottom bars (Write's and
//  Takes'), so its pieces live here, in the shared home (CLAUDE.md: a view two
//  features render moves to Core/Views): the words, the open note's small
//  projection, the bar-level observation, and the menu items. The book's row
//  is the Book Settings sheet's (`BookSettingsSheet`).
//
//  The register is the APP's voice (P-13n-1's boundary — these are app-wide
//  faces, not the MCP room's), sentence case, and sweepable at 13s-a. The
//  row's own sub-sentence does the semantic work (R-13nb-4 (iv)).
//
//  The note ▾ menu's line "Shared with AI: …" is the note's face of the
//  grants that reach it (P-13n-3's word) — read through the same pure rule
//  the server consults (`Queries.mcpNoteSharing`). Its revoke and the "Allow
//  AI here…" door are U3's (AF-8).
//

import GRDB
import SwiftUI
import VariorumCore

nonisolated enum PrivateMarkCopy {
    /// The row, both surfaces (R-13nb-4 (iv): the word is "Private").
    static let rowWords = "Private \u{2014} never shared with AI"
    static let noNoteNote = "Private marks the note you have open \u{2014} open one first."
    static let bookSheetNote = "A book is marked Private in its Book Settings."

    /// The book sheet's caption under the row: what the mark DOES.
    static let bookCaption =
        "No AI client can read this book's notes \u{2014} or any note filed here later \u{2014} unless "
        + "you share one for a single ask. A note in a Private book stays private everywhere."

    /// The note ▾ menu's quiet line when a PRIVATE BOOK holds the note (the
    /// mark it cannot clear from here).
    static func throughBooks(_ names: [String]) -> String {
        let quoted = names.prefix(2).map { "\u{201C}\($0)\u{201D}" }.joined(separator: ", ")
        let more = names.count > 2 ? " and \(names.count - 2) more" : ""
        return "Private through \(quoted)\(more)"
    }

    /// The note's grant-in-context line (P-13n-3's "shared with AI").
    static func sharedLine(_ sharing: [MCPNoteSharing]) -> String? {
        guard !sharing.isEmpty else { return nil }
        let clients = sharing.prefix(2).map { "\($0.clientName) (\(MCPRungWords.reach($0.rung)))" }
        let more = sharing.count > 2 ? " and \(sharing.count - 2) more" : ""
        return "Shared with AI: " + clients.joined(separator: ", ") + more
    }

    static let markedNote = "Marked Private \u{2014} no AI client can read this note."
    static let clearedNote = "No longer Private."
    static func markedBook(_ name: String) -> String {
        "\u{201C}\(name)\u{201D} is Private \u{2014} no AI client can read its notes."
    }
    static func clearedBook(_ name: String) -> String { "\u{201C}\(name)\u{201D} is no longer Private." }
}

/// **The "shared with AI" chip** (P-13n-3's word, hers to re-voice at
/// 13s-a): on a Bookcase row whose book an approved client can reach now.
nonisolated enum SharedWithAICopy {
    static let chip = "shared with AI"
    static let chipHelp = "An MCP client can read this book now \u{2014} see Settings \u{25B8} MCP."
}

/// How far a client reaches, in the app's words.
nonisolated enum MCPRungWords {
    static func reach(_ rung: MCPGrantRule.Rung) -> String {
        switch rung {
        case .read: "read"
        case .suggest: "read and suggest"
        case .writeNew: "read, suggest and write new"
        case .edit: "read, suggest, write new and edit"
        }
    }
}

/// The open note's privacy, as the note ▾ menu draws it.
nonisolated struct NotePrivacyState: Equatable, Sendable {
    let postID: String
    /// Its OWN mark (the toggle).
    let own: Bool
    /// Live Private books holding it (by name).
    let throughBooks: [String]
    /// Approved clients reaching it now.
    let sharing: [MCPNoteSharing]

    static func read(_ db: Database, postID: String) throws -> NotePrivacyState {
        NotePrivacyState(
            postID: postID,
            own: try Queries.isNotePrivate(db, postID: postID),
            throughBooks: try Queries.privateBooksHolding(db, postID: postID),
            sharing: try Queries.mcpNoteSharing(db, noteID: postID))
    }

    /// Only a state loaded for THIS note draws (the wing doors' subject rule).
    static func matching(_ state: NotePrivacyState?, postID: String) -> NotePrivacyState? {
        state?.postID == postID ? state : nil
    }
}

/// The act behind the note's row — through the session's runner (P2), the
/// receipt or the operation's own refusal on the one status seam.
@MainActor
enum NotePrivacyAct {
    static func set(_ on: Bool, postID: String, session: AppSession) async {
        do {
            let wrote = try await session.runner.run { try $0.setNotePrivate(postID, on) }
            if wrote { session.status.receipt(on ? PrivateMarkCopy.markedNote : PrivateMarkCopy.clearedNote) }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

/// The note ▾ menu's rows: the toggle, and the quiet lines under it. Renders
/// nothing until a state for THIS note has loaded (a stale load never draws
/// another note's mark).
struct NotePrivacyMenuItems: View {
    let session: AppSession
    let postID: String
    let state: NotePrivacyState?

    var body: some View {
        if let state = NotePrivacyState.matching(state, postID: postID) {
            Toggle(CapabilityRegistry.capability(.markNotePrivate).verb, isOn: Binding(
                get: { state.own },
                set: { on in
                    let session = session
                    let postID = postID
                    Task { await NotePrivacyAct.set(on, postID: postID, session: session) }
                }))
            if !state.own, !state.throughBooks.isEmpty {
                Text(PrivateMarkCopy.throughBooks(state.throughBooks))
            }
            if let shared = PrivateMarkCopy.sharedLine(state.sharing) {
                Text(shared)
            }
        }
    }
}

extension View {
    /// The bar's half of the note's Private row: observes the open note's
    /// privacy (its own mark, the Private books holding it, the clients
    /// reaching it) — a small read, off the main thread, re-run as the rows
    /// it reads change, so a mark set anywhere (another window, a sync)
    /// shows at once. Cancelled with the note.
    func notePrivacyDoor(session: AppSession, postID: String, state: Binding<NotePrivacyState?>) -> some View {
        task(id: postID) {
            let database = session.database
            do {
                for try await value in database.observe({ db in try NotePrivacyState.read(db, postID: postID) }) {
                    guard !Task.isCancelled else { return }
                    state.wrappedValue = value
                }
            } catch {}
        }
    }
}
