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
//  the server consults (`Queries.mcpNoteSharing`).
//
//  13n-b U3 — "ALLOW AI HERE" (R-13n-11's connected push gesture; AF-8 made
//  it U3's; AF-10 (e) its shape): a submenu of the APPROVED clients that do
//  not already reach this note; each item shares THIS note, read, ONCE — the
//  quick path (the full grant sheet stays the pane's). A fenced note is
//  included (a once note grant is per-ask-legal — R-13n-11's letter). No
//  client to offer ⇒ the row is not rendered (P-2), and the submenu carries
//  no ellipsis (the choice the ellipsis promised IS the submenu — HIG).
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

    /// U3 — "Allow AI here" (the mockup §7's row, its ellipsis dropped for a
    /// submenu — AF-10 (e)), and what it says once it lands.
    static let allowHere = "Allow AI here"
    static let allowHereNoNote = "Allow AI here shares the note you have open \u{2014} open one first."
    static func allowedOnce(_ client: String) -> String { "\(client) may read this note once." }
    static func markedBook(_ name: String) -> String {
        "\u{201C}\(name)\u{201D} is Private \u{2014} no AI client can read its notes."
    }
    static func clearedBook(_ name: String) -> String { "\u{201C}\(name)\u{201D} is no longer Private." }

    // MARK: VX-831 — the visible mark (the closed eye) and its door

    /// "“a”" · "“a” and “b”" · "“a”, “b” and 2 more" — books named in the
    /// mark's words, alphabetical (the facts' order).
    static func booksPhrase(_ names: [String]) -> String {
        let quoted = names.prefix(2).map { "\u{201C}\($0)\u{201D}" }
        switch names.count {
        case 0: return ""
        case 1: return quoted[0]
        case 2: return "\(quoted[0]) and \(quoted[1])"
        default: return "\(quoted[0]), \(quoted[1]) and \(names.count - 2) more"
        }
    }

    /// The mark's hover (the VX-426 family — the descriptor, an em dash, what
    /// the click does). PROVISIONAL wording, her bundle (the via-book line is
    /// hers: "Private — via ‹book›").
    static let markOwnNoteHelp = "Private \u{2014} click to remove this note\u{2019}s mark"
    static func markOwnNoteAlsoViaHelp(_ books: [String]) -> String {
        "Private \u{2014} click to remove this note\u{2019}s own mark (it stays private via \(booksPhrase(books)))"
    }
    static func markViaHelp(_ books: [String]) -> String { "Private \u{2014} via \(booksPhrase(books))" }
    static let markOwnBookHelp = "Private \u{2014} click to remove this book\u{2019}s mark"

    /// The via-book click's saying — her words: "Private via ‹book› — change
    /// it on the book, or move the note" (the plural arm PROVISIONAL).
    static func viaBookSaying(_ books: [String]) -> String {
        "Private via \(booksPhrase(books)) \u{2014} change it on \(books.count > 1 ? "the books" : "the book"), "
            + "or move the note."
    }
    /// Its one door: the first-named book, opened at the note (the owned-by
    /// badge's click-through). PROVISIONAL.
    static func openBookDoor(_ name: String) -> String { "Open \u{201C}\(name)\u{201D}" }

    /// The own-arm receipt when a Private book still holds the note — the
    /// toggle's "No longer Private." would be false there. PROVISIONAL.
    static func clearedNoteStillVia(_ books: [String]) -> String {
        "This note\u{2019}s own mark is off \u{2014} it stays Private via \(booksPhrase(books))."
    }
}

// (13n-c U3 — VX-271: the Bookcase's "shared with AI" text chip and its
// copy RETIRED into the ONE shared icon, `MCPSharedIcon`, whose hover names
// who reaches the book and how far.)

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
    /// U3: every APPROVED client, by name — "Allow AI here" offers those
    /// not already reaching the note.
    var approvedClients: [String] = []
    /// VX-641: the library has EVER had an MCP client (`MCPLibraryClients` —
    /// VX-590's fact, the pane's own). Read with the rest, so the row appears
    /// the moment a first client connects.
    var libraryHasHadClient = false

    /// **VX-641 — does the note's Private row show?** Once the library has had
    /// a client (her ruling 2026-10-28: "it should be hidden if there's no AI to
    /// share with"), and ALWAYS while the note is marked — its own mark or a
    /// Private book's that holds it (the mark syncs, clients don't; a mark is
    /// never invisible and can always be removed). The rule is the one the pane
    /// reads (`MCPLibraryClients.showsPrivateRow`).
    var showsPrivateRow: Bool {
        MCPLibraryClients.showsPrivateRow(everHadClient: libraryHasHadClient, marked: own || !throughBooks.isEmpty)
    }

    /// The clients "Allow AI here" can offer: approved, and not already
    /// reaching this note (a grant that changes nothing is a door that
    /// cannot act — P-2).
    var allowable: [String] {
        let reaching = Set(sharing.map(\.clientName))
        return approvedClients.filter { !reaching.contains($0) }
    }

    static func read(_ db: Database, postID: String) throws -> NotePrivacyState {
        NotePrivacyState(
            postID: postID,
            own: try Queries.isNotePrivate(db, postID: postID),
            throughBooks: try Queries.privateBooksHolding(db, postID: postID),
            sharing: try Queries.mcpNoteSharing(db, noteID: postID),
            approvedClients: try Queries.mcpClients(db, states: [.approved]).map(\.name),
            libraryHasHadClient: try Queries.mcpLibraryHasHadClient(db))
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

/// U3 — "Allow AI here": one read · once grant on THIS note for the named
/// approved client, through the grants store's ordinary op (its refusals
/// spoken on the one status seam — a client denied since, a note gone).
@MainActor
enum NoteAllowAct {
    static func allow(_ clientName: String, postID: String, session: AppSession) async {
        do {
            let database = session.database
            try await session.runner.run { ops in
                guard let client = try database.read({ try Queries.mcpClient($0, name: clientName) }) else {
                    throw OperationError.mcpClientNotFound(id: clientName)
                }
                _ = try ops.grantMCPAccess(
                    client.id, .init(rung: .read, scopeKind: .note, scopeID: postID, duration: .once))
            }
            session.status.receipt(PrivateMarkCopy.allowedOnce(clientName))
        } catch {
            session.status.refuse(MCPPaneCopy.refusal(error))
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
            // VX-641: the row and its line wait for the library's first client,
            // unless the note is already marked (`showsPrivateRow`).
            if state.showsPrivateRow {
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
            }
            if let shared = PrivateMarkCopy.sharedLine(state.sharing) {
                Text(shared)
            }
            if !state.allowable.isEmpty {
                Menu(CapabilityRegistry.capability(.mcpAllowHere).verb) {
                    ForEach(state.allowable, id: \.self) { name in
                        Button(name) {
                            let session = session
                            let postID = postID
                            Task { await NoteAllowAct.allow(name, postID: postID, session: session) }
                        }
                    }
                }
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
