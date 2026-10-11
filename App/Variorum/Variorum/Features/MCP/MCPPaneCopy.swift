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
    /// The toggle's sentence — mockup §1's words, kept TRUE to what the
    /// server serves (P-13nb-U1-12's rule: U1 trimmed it to the read rung,
    /// U2 restored the mockup once the write rungs made it true). U3 walk
    /// finding W-2: "no client can overwrite your text" stopped being true
    /// the moment edit could be granted, so the clause says when it can —
    /// and what guards it (R-13n-7's brackets). PROVISIONAL P-13nb-U3-17,
    /// her words to re-voice at 13s-a. 13n-c U2 (R-AIR-8 — no "AI" in
    /// settings-class wording): "AI work" → "a client's work".
    static let enableBlurb =
        "Runs a local MCP server while Variorum is open, so clients like Claude Code can read "
        + "and write here through Variorum's own operations. Nothing is readable until you grant "
        + "it, every grant is revocable, and a client's work lands as takes beside your own \u{2014} a "
        + "client changes your text only where you grant it edit, with a commit before and after "
        + "every change."

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

    /// 13n-c U2 (the U1 ladder's R2-3; P-13nb-U2-3): the client row counts
    /// only grants that REACH as shared; an inert one is said as inert.
    static func reads(_ count: Int, inert: Int) -> String {
        guard inert > 0 else { return reads(count) }
        let shared = count == 0 ? "nothing shared" : reads(count)
        return "\(shared) \u{00B7} \(inert) inert"
    }

    /// **L1 — the A-4 boundary, said where clients are listed** (13n-c U2;
    /// the VX-156 brief §12's words verbatim, mockup §11 — the line the canon
    /// says the pane carries and no rendered string did). Direct and
    /// technical (R-13n-5).
    static let clientBoundary =
        "A client names itself when it connects. Variorum can't verify the name: a grant lets "
        + "whatever connects under that name do what you granted."

    // MARK: - Shared with AI

    /// 13n-c U2 (R-AIR-8 — no "AI" in settings-class wording; PROVISIONAL
    /// P-13nc-U2-2, her words at the copy pass): was "Shared with AI". The
    /// client row's own "N shared places" and the Revoke door's note
    /// already said "shared places".
    static let sharedSection = "Shared places"
    static let nothingShared = "Nothing is shared."

    /// 13n-c U2 (R2-3): a live grant whose target is fenced since reaches
    /// NOTHING — the row says so instead of calling it shared, and why.
    static func inertDetail(_ fence: MCPGrantRule.Fence, kind: MCPGrantRule.ScopeKind) -> String {
        let place = kind == .note ? "note" : "book"
        switch fence {
        case .privateMark: return "inert \u{2014} the \(place) is marked Private, which always asks"
        case .journal:
            return kind == .note
                ? "inert \u{2014} a daily Journal entry always asks"
                : "inert \u{2014} it's your daily Journal now, which always asks"
        }
    }
    static func sharedDetail(client: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration) -> String {
        "\(client) \u{00B7} \(rungWord(rung)) \u{00B7} \(durationWord(duration))"
    }
    static let missingTarget = "(gone)"

    // MARK: - One act's row (13n-c U3 — VX-156 item 2; mockup §2)

    static func groupTitle(_ count: Int) -> String { "\(count) notes" }
    static let groupChip = "notes"
    /// The act's members, named — the titles read (at most three), then "and
    /// N more" for the rest; a member gone since reads "(gone)".
    static func groupMembers(_ titles: [String?], total: Int) -> String {
        let named = titles.map { $0 ?? missingTarget }.joined(separator: " \u{00B7} ")
        let rest = total - titles.count
        return rest > 0 ? "\(named) and \(rest) more" : named
    }
    /// R2-3's rule on an act: its members fenced since reach nothing.
    static func groupInert(_ count: Int) -> String {
        count == 1
            ? "1 inert \u{2014} a note fenced since (Private or your daily Journal), which always asks"
            : "\(count) inert \u{2014} notes fenced since (Private or your daily Journal), which always ask"
    }

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
    /// 13n-c U1 (R-AIR-1, J8 — the VX-156 mockup §8's recommended words):
    /// only THE daily Journal and anything Private still ask.
    static let openBookDetail = "your daily Journal and anything Private still ask every time"

    // MARK: - Activity (13n-b U3 — the coarse log's face; R-13n-10's caps)

    static let activitySection = "Activity"
    static let noActivity = "Nothing yet \u{2014} every call a client makes is listed here."

    /// One line of the ACTIVITY list (the mockup §2's "claude code added 3
    /// takes to “…”"): who, what, where — the MCP room's register, direct;
    /// a refused call says so with the tool's own name.
    static func activityLine(_ line: MCPActivityFace.Line) -> String {
        let target = line.targetTitle.map { "\u{201C}\($0)\u{201D}" }
        guard line.allowed else {
            let on = target.map { " on \($0)" } ?? ""
            let times = line.count > 1 ? " (\(line.count) times)" : ""
            return "\(line.clientName) was refused \(line.act)\(on)\(times)"
        }
        return "\(line.clientName) \(activityPhrase(line.act, count: line.count, target: target, kind: line.targetKind))"
    }

    private static func activityPhrase(_ act: String, count n: Int, target: String?, kind: String?) -> String {
        let at = target ?? "a note"
        let times = n > 1 ? " (\(n) times)" : ""
        switch act {
        case "list_books": return "listed books" + times
        case "list_notes":
            switch kind {
            case "book": return "listed a book\u{2019}s notes" + times
            case "wing": return "listed a wing\u{2019}s notes" + times
            default: return "listed its shared notes" + times
            }
        case "read_note": return "read \(at)" + times
        case "export_note": return "exported \(at)" + times
        case "search": return "searched" + times
        case "add_take": return n == 1 ? "added a take to \(at)" : "added \(n) takes to \(at)"
        case "add_comment": return n == 1 ? "commented in \(at)" : "left \(n) comments in \(at)"
        case "save_lens": return "saved a lens on \(at)" + times
        // U3 ladder round 1, F4: a coalesced CREATION run spans different
        // creations (the log's target is the PLACE, its title the newest
        // creation's), so a count never rides one creation's title — the
        // line speaks the count plainly (J8's copy truth; 13s-a-sweepable).
        case "create_note": return n == 1 ? "made the note \(at)" : "made \(n) notes"
        case "import_document": return n == 1 ? "imported \(at)" : "imported \(n) documents"
        case "apply_tag": return "tagged \(at)" + times
        case "create_book": return n == 1 ? "made the book \(at)" : "made \(n) books"
        case "add_note_to_book": return "added \(at) to a book" + times
        case "create_section": return n == 1 ? "added a chapter to \(at)" : "added \(n) chapters to \(at)"
        case "edit_take": return n == 1 ? "edited \(at)" : "made \(n) edits in \(at)"
        case "divide_block": return "divided a block in \(at)" + times
        case "merge_blocks": return "merged blocks in \(at)" + times
        case "move_block": return "moved a block in \(at)" + times
        case "delete_block": return "deleted a block in \(at)" + times
        case "set_block_name": return "named a block in \(at)" + times
        default: return "used \(act)" + times
        }
    }

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
    /// 13n-c U2 — the sheet opened from a place (U3's doors), its client
    /// chosen in WHO.
    static let sheetTitleChoosing = "Grant access"
    /// 13n-c U3: the one title rule — a client named or chosen, and Change…
    /// (R-AIR-4 — the sheet replaces what it was opened on) says so.
    static func sheetTitle(client: String?, changing: Bool) -> String {
        guard changing else { return client.map(sheetTitle) ?? sheetTitleChoosing }
        return client.map { "Change access \u{2014} \($0)" } ?? "Change access"
    }

    // MARK: - Several notes (13n-c U3 — the Library's "Share N notes…"; mockup §2)

    static func theseNotes(_ count: Int) -> String {
        count == 1 ? "This note" : "These \(count) notes"
    }
    /// The pick, named — at most three, then "and N more".
    static func notesList(_ titles: [String]) -> String {
        let named = titles.prefix(3).joined(separator: " \u{00B7} ")
        return titles.count > 3 ? "\(named) and \(titles.count - 3) more" : named
    }
    /// **Why "always" is not offered** when ANY picked note is fenced (mockup
    /// §2, verbatim shape: "Always isn't offered: 1 of these notes is a daily
    /// Journal entry, which is only ever shared one ask at a time.").
    static func alwaysWithheldAmong(_ fences: [MCPGrantRule.Fence]) -> String {
        let count = fences.count
        let journal = fences.allSatisfy { $0 == .journal }
        let privateOnly = fences.allSatisfy { $0 == .privateMark }
        let what: String = switch (count == 1, journal, privateOnly) {
        case (true, true, _): "is a daily Journal entry"
        case (true, _, true): "is marked Private"
        case (false, true, _): "are daily Journal entries"
        case (false, _, true): "are marked Private"
        default: "are Private or daily Journal entries"
        }
        return "Always isn't offered: \(count) of these notes \(what), which "
            + (count == 1 ? "is" : "are") + " only ever shared one ask at a time."
    }
    /// The confirm for several notes: "Grant read on 3 notes while connected"
    /// (mockup §2) — no quotes (the count is not a name), no clause (notes,
    /// not a place that grows).
    static func confirmPartsForNotes(
        verb: String, rung: MCPGrantRule.Rung, count: Int, duration: MCPGrantRule.Duration
    ) -> (lead: String, place: String, tail: String) {
        ("\(verb) \(rungName(rung).lowercased()) on ", count == 1 ? "1 note" : "\(count) notes",
         " \(durationWord(duration))")
    }
    static let sheetLead =
        "The client sees what you grant and nothing else. Refusals speak to it exactly as they "
        + "speak to you."
    static let whereSection = "Where"
    static let howMuchSection = "How much"
    static let howLongSection = "How long"
    /// 13n-c U2 — WHO (mockup §1/§2): shown whenever the sheet's opener did
    /// not name a client.
    static let whoSection = "Who"
    static let noApprovedClient =
        "No client is approved yet \u{2014} approve a connection request first."
    static let aNote = "A note"
    static let aBook = "A book"
    static func aBookDetail(_ name: String?) -> String {
        name.map { "\u{201C}\($0)\u{201D} \u{2014} its notes, takes and tags" } ?? "choose a book"
    }
    static let thisWing = "A wing"
    /// 13n-c U1 (R-AIR-1, J8 — mockup §8's words): a journal-style book is
    /// in the wing like any book; only the daily Journal and anything
    /// Private ask.
    static func wingDetail(_ name: String) -> String {
        "everything in \(name) except your daily Journal and anything Private, which always ask"
    }
    static let noBooks =
        "No book can be shared yet (your daily Journal and Private books are shared one ask at a time)."

    // MARK: - The pickers (13n-c U2 — VX-156 items 1 + 6; mockup §1)

    static let bookPrompt = "Find a book"
    static let notePrompt = "Find a note"
    static let wingPrompt = "Find a wing"
    static let clientPrompt = "Find a client"
    static let chooseBook = "Choose a book"
    static let chooseNote = "Choose a note"
    static let chooseClient = "Choose a client"
    static let noNotes = "No notes in this wing yet."
    /// The picker's foot line (mockup §1, verbatim): why some books are
    /// never in the list.
    static let fencedBooksNote =
        "Your daily Journal and Private books aren't listed \u{2014} they're shared one ask at a time."
    /// The sections (her kickoff: "sort by shelf … favorites"; round 2:
    /// "recently edited … that's often what I want").
    static let recentlyEdited = "Recently edited"
    static let starred = "Starred"
    static let unshelved = "Unshelved"
    /// The a–z layout's one list (its header — without one it read as
    /// Starred's continuation in the U2 capture).
    static let allBooks = "All books"
    /// A shelf section in a wing other than Home names its wing first.
    static func shelfSection(_ shelf: String, glyph: String?, wing: String?) -> String {
        let name = [glyph, shelf].compactMap { $0 }.joined(separator: " ")
        return wing.map { "\($0) \u{00B7} \(name)" } ?? name
    }
    static func unshelvedSection(wing: String?) -> String {
        wing.map { "\($0) \u{00B7} unshelved" } ?? unshelved
    }
    /// The picker's two layouts (PROVISIONAL P-13nc-U2-3).
    static let byShelf = "by shelf"
    static let alphabetical = "a\u{2013}z"
    /// A note row's fence word (the mockup §1 note leg's "daily Journal entry").
    static func noteFenceWord(_ fence: MCPGrantRule.Fence) -> String {
        switch fence {
        case .journal: "daily Journal entry"
        case .privateMark: "Private"
        }
    }
    /// The note leg's wing row, when the library has more than one wing.
    static let noteWingLabel = "Notes in"
    static func aNoteDetail(_ title: String?) -> String {
        title.map { "\u{201C}\($0)\u{201D} \u{2014} its takes, comments and tags" } ?? "choose a note"
    }
    /// **Why "always" is not offered** (mockup §1's note leg, verbatim shape):
    /// a fenced note is only ever shared one ask at a time.
    static func alwaysWithheld(_ title: String, _ fence: MCPGrantRule.Fence) -> String {
        switch fence {
        case .journal:
            "\u{201C}\(title)\u{201D} is a daily Journal entry \u{2014} it's only ever shared one ask at "
                + "a time, so always isn't offered."
        case .privateMark:
            "\u{201C}\(title)\u{201D} is marked Private \u{2014} it's only ever shared one ask at a "
                + "time, so always isn't offered."
        }
    }
    /// HOW MUCH — the rungs the server can serve, each with the mockup §3
    /// sentence (U2: read · suggest · write new; U3: edit, now that the
    /// server serves it — a rung it couldn't serve was never offered, P-2).
    static let offeredRungs: [MCPGrantRule.Rung] = [.read, .suggest, .writeNew, .edit]

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
    static let cancel = "Cancel"
    static let whileConnectedNote = "While connected is offered while this client is connected."

    /// "Grant suggest in “the lightning thief” while connected" (mockup §3) —
    /// and, since 13n-c's R-AIR-3, the clause that says membership is LIVE:
    /// her sentence, *"Grant read in “dream journal” always, including to
    /// future entries."*, on EVERY book grant ("notes added later become
    /// visible"); D-3 (PROVISIONAL P-13nc-3) gives a wing grant the parallel
    /// clause and keeps both on every duration (a once or while-connected
    /// grant's reach grows the same way while it lives). A note grant names
    /// one note — no clause. The `scope` is required so no grant door can
    /// forget it. A button label, so no closing period (PROVISIONAL
    /// P-13nc-U1-1 — her sentence carries one).
    static func confirm(
        verb: String, rung: MCPGrantRule.Rung = .read, scope: MCPGrantRule.ScopeKind, place: String,
        distinguisher: String? = nil, duration: MCPGrantRule.Duration
    ) -> String {
        let parts = confirmParts(
            verb: verb, rung: rung, scope: scope, place: place, distinguisher: distinguisher,
            duration: duration)
        return parts.lead + parts.place + parts.tail
    }

    /// The confirm in its three parts, so the sheet can let ONLY the place
    /// compress (13n-c U1, the geometry oracle in the U1 record: a voiced
    /// button is one line and tail-truncates, which in Terminal's mono cut
    /// R-AIR-3's clause off — the very words the ruling exists for). The verb,
    /// rung, duration and clause never truncate; the place, shown whole in
    /// WHERE just above, takes what room is left.
    ///
    /// 13n-c U2: the place wears its DISTINGUISHER after its closing quote
    /// (`PlaceLabels` — "“the adventures of sherlock holmes” (made Oct 9)"),
    /// in the tail, so it never compresses away — it is the very fact that
    /// names the right book; and a NOTE grant reads "on" (the VX-156 mockup
    /// §1's "Grant read on “morning pages — oct 9” once").
    static func confirmParts(
        verb: String, rung: MCPGrantRule.Rung = .read, scope: MCPGrantRule.ScopeKind, place: String,
        distinguisher: String? = nil, duration: MCPGrantRule.Duration
    ) -> (lead: String, place: String, tail: String) {
        let preposition = scope == .note ? "on" : "in"
        let distinct = distinguisher.map { $0.isEmpty ? "" : " (\($0))" } ?? ""
        return ("\(verb) \(rungName(rung).lowercased()) \(preposition) \u{201C}", place,
                "\u{201D}\(distinct) \(durationWord(duration))" + liveReachClause(scope))
    }

    /// The confirm's TWO-LINE form (13n-c U2 — the row's final design, the
    /// geometry oracle in the U2 record): when one line cannot hold the whole
    /// sentence (in Terminal's mono even her own example with a day
    /// distinguisher is 554 pt against 489 pt of room), the label takes two
    /// lines, and a place longer than this many characters is middle-
    /// shortened so the verb, rung, distinguisher, duration and clause always
    /// read whole. The place shows whole in WHERE just above.
    static let confirmPlaceLimit = 40

    static func shortPlace(_ place: String) -> String {
        guard place.count > confirmPlaceLimit else { return place }
        let keep = confirmPlaceLimit - 1
        let head = place.prefix((keep + 1) / 2)
        let tail = place.suffix(keep / 2)
        return "\(head)\u{2026}\(tail)"
    }

    /// R-AIR-3's clause (book) and D-3's twin (wing), with its leading comma.
    static func liveReachClause(_ scope: MCPGrantRule.ScopeKind) -> String {
        switch scope {
        case .book: ", including to future entries"
        case .wing: ", including notes added later"
        case .note: ""
        }
    }

    // MARK: - Refusals in the pane (the operations layer's own errors)

    static func refusal(_ error: Error) -> String {
        switch error as? OperationError {
        case .mcpClientNotApproved?: "Approve the client before granting it access."
        case .mcpGrantScopeFenced?:
            // 13n-c U1 (R-AIR-1, J8 — mockup §8's words).
            "Your daily Journal and Private notes are shared one ask at a time, never by a standing grant."
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
    /// "claude-code asks to read “morning pages — oct 9”". 13n-c U2: a book
    /// (or wing) that shares its name with another offered place wears its
    /// distinguisher (`PlaceLabels`, the one rule — mockup §1b's "claude-code
    /// asks to suggest in “the adventures of sherlock holmes” (made 11 Oct)").
    static func title(_ ask: MCPAsk, distinguisher: String? = nil) -> String {
        let verb: String = switch ask.rung {
        case .read: "read"
        case .suggest: "suggest in"
        case .writeNew: "write new in"
        case .edit: "edit in"
        }
        let distinct = distinguisher.map { $0.isEmpty ? "" : " (\($0))" } ?? ""
        let target = ask.scopeKind == .wing
            ? "the \(ask.title) wing\(distinct)" : "\u{201C}\(ask.title)\u{201D}\(distinct)"
        return "\(ask.clientName) asks to \(verb) \(target)"
    }

    /// **R-AIR-3 on the ask road** (13n-c U2 — the U1 ladder's F2: every
    /// book grant says its live reach, and an answer here MINTS one): her
    /// clause under a BOOK ask, D-3's twin under a WING ask, nothing for a
    /// note (one note). Every duration carries it (P-13nc-3) — so one line
    /// above the buttons, never a word per button. PROVISIONAL wording
    /// (P-13nc-U2-4), her copy pass.
    static func reachLine(_ ask: MCPAsk, distinguisher: String? = nil) -> String? {
        switch ask.scopeKind {
        case .note: nil
        case .book:
            "Any answer below grants it in \(PlaceLabels.quoted(ask.title, distinguisher: distinguisher)), "
                + "including to future entries."
        case .wing: "Any answer below grants it in the \(ask.title) wing, including notes added later."
        }
    }

    /// The sentence under it: the fence's reason (mockup §4's journal line,
    /// re-keyed by 13n-c's R-AIR-1 to THE daily Journal — VX-156 mockup §8's
    /// words; the Private twin), else what the rung would let it do.
    static func lead(_ ask: MCPAsk) -> String {
        switch ask.fence {
        case .journal?: "A daily Journal entry. Your daily Journal is only ever shared one ask at a time."
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
    /// 13n-b U4 (R-13nb-23 (a)): the receipt's one-press door — her "… —
    /// Open ›". App voice (P-13n-1), 13s-a sweepable.
    static let openDoor = "Open \u{203A}"

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
        // 13n-b U4 — the carriage's acts (P-13nb-U4-2's words, 13s-a sweepable).
        case .putBack: return n == 1 ? "put back \(receipts[0].detail ?? "a block")" : "put back \(n) things"
        case .version: return n == 1 ? "saved a version" : "saved \(n) versions"
        case .entryDate:
            return n == 1
                ? (receipts[0].detail.map { "dated the note \($0)" } ?? "cleared the note's date")
                : "changed \(n) dates"
        case .filing:
            return n == 1
                ? (receipts[0].detail.map { "filed a note under \(quoted($0))" } ?? "unfiled a note")
                : "filed \(n) notes"
        case .bookRule:
            return n == 1 ? "changed what \(quoted(receipts[0].targetTitle)) collects" : "changed \(n) books' rules"
        }
    }

    private static func joined(_ parts: [String]) -> String {
        guard parts.count > 1 else { return parts.first ?? "" }
        return parts.dropLast().joined(separator: ", ") + " and " + (parts.last ?? "")
    }
}


/// **THE ACTIVITY FACE's coalescing** (13n-b U3 — R-13n-10: the list stays
/// legible at length): consecutive log rows by one client, of one act, on one
/// target, with one outcome, read as ONE line with a count — the mockup's
/// "added 3 takes to …". Pure: the rows in, newest first; the lines out.
nonisolated enum MCPActivityFace {
    struct Line: Equatable, Identifiable, Sendable {
        /// The newest row's id (stable while the run grows older).
        let id: Int64
        let clientName: String
        let act: String
        let targetKind: String?
        let targetID: String?
        let targetTitle: String?
        let allowed: Bool
        let count: Int
        /// The newest row's stamp.
        let at: String
    }

    static func lines(_ rows: [MCPActivityRow]) -> [Line] {
        var lines: [Line] = []
        for row in rows {
            if let last = lines.last, last.clientName == row.clientName, last.act == row.act,
               last.targetID == row.targetID, last.targetKind == row.targetKind, last.allowed == row.allowed {
                lines[lines.count - 1] = Line(
                    id: last.id, clientName: last.clientName, act: last.act, targetKind: last.targetKind,
                    targetID: last.targetID, targetTitle: last.targetTitle ?? row.targetTitle,
                    allowed: last.allowed, count: last.count + 1, at: last.at)
            } else {
                lines.append(Line(
                    id: row.id, clientName: row.clientName, act: row.act, targetKind: row.targetKind,
                    targetID: row.targetID, targetTitle: row.targetTitle, allowed: row.allowed,
                    count: 1, at: row.at))
            }
        }
        return lines
    }
}
