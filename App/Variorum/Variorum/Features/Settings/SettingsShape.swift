//
//  SettingsShape.swift
//  Variorum (Mac)
//
//  **13u4 UNIT S1 — her items 4 and 6.**
//
//  Item 6, verbatim: *"the settings menu could probably be broken up a
//  little more - an overall one, then maybe tabs on text editing shortcuts,
//  window / reshaping shortcuts, etc."*
//  Item 4, verbatim: *"simple text search within the settings menu - it's
//  too hard to find how to make a callout."*
//
//  **Read those two together and they are one ask.** "How do I make a
//  callout" is not a setting — it is an ACT (Block ▸ Callout, ⌥⌘C) — and
//  her own sketch names SHORTCUTS as the things the tabs should hold. So
//  Settings is where she looks for *what the app can do*, and this file is
//  that: a pane list she can scan, and a search that reaches the settings
//  rows, the keyboard map AND the dictionary in one field.
//
//  Three pure pieces, so the answer is testable without mounting anything:
//
//   · `SettingsPane` — the panes, in order. Her "overall one" is General.
//   · `SettingsCatalog` — every settings ROW as data: its pane, the words
//     the pane renders as its label, a one-line blurb for a result, and the
//     words she might type instead. **The pane renders `title` from here**,
//     so the search can never name a row the pane does not show.
//   · `SettingsSearch` — the filter. One pure function over an index; the
//     index is assembled from the catalog + the ⌘/ helper's OWN two lists
//     (`HelperView.groups`, `HelperView.entries`), never a second copy of
//     them, so a shortcut is findable here exactly when it is findable
//     there — and `everyDeclaredShortcutIsFindableInTheHelper` already
//     holds that list to the registry.
//
//  NO new storage: nothing here is written, read from the store, or synced.
//  The query lives for as long as the window is open.
//

import Foundation

// MARK: - The panes (her item 6's sketch)

/// The Settings window's panes, in the order the sidebar lists them.
///
/// **PROVISIONAL — QUESTIONS #131.** Her sketch named "an overall one, then
/// maybe tabs on text editing shortcuts, window / reshaping shortcuts,
/// etc."; the exact set is shaped from what the panes actually hold, which
/// is what the brief asked for. The shape of the argument, pane by pane, is
/// in the unit record's tab-set rationale.
nonisolated enum SettingsPane: String, CaseIterable, Identifiable, Sendable {
    /// Her "overall one": the three appearance dials and how the app talks
    /// back. Everything here is about the WHOLE app, not one surface.
    case general
    /// The writing surface's look and feel.
    case editor
    /// Takes, which are a first-class idea and deserve a name she can find.
    case takes
    /// The DOCUMENT's own habits — the synced three.
    case writing
    /// The keyboard map: her sketch's "text editing shortcuts, window /
    /// reshaping shortcuts" — one pane holding the same grouped list the
    /// ⌘/ helper shows, because two copies of a list is two lists.
    case shortcuts
    case tags
    /// 13n-b U1: the MCP door (R-13n-5 named it "MCP"). Beside Tags and
    /// before Protection — who may reach the library sits next to how it is
    /// locked; PROVISIONAL P-13nb-U1-9 (13r's ruled Diagnostics placement,
    /// between Data Safety and Acknowledgments, is untouched).
    case mcp
    case protection
    case dataSafety
    /// 13r U3-B (the architect's ruling — Option A): crash reports, opt-in,
    /// shown verbatim, never sent without her hand. Its own pane because the
    /// surface's own name is where she looks, and the verbatim evidence
    /// wants a pane's height.
    case diagnostics
    case acknowledgments

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .editor: "Editor"
        case .takes: "Takes"
        case .writing: "Writing"
        case .shortcuts: "Shortcuts"
        case .tags: "Tags"
        case .mcp: "MCP"
        case .protection: "Protection"
        case .dataSafety: "Data Safety"
        case .diagnostics: "Diagnostics"
        case .acknowledgments: "Acknowledgments"
        }
    }

    /// One line under the pane's title — what this pane is for, so the
    /// right pane can be picked without opening three.
    var blurb: String {
        switch self {
        // Her ruling 2026-10-13 (the VX-214 sitting record): General is the
        // ONE pane with no subtitle; the header renders nothing for "".
        case .general: ""
        case .editor: "How the writing surface looks and behaves while you are in it."
        case .takes: "How a block's alternative takes open and follow you."
        case .writing: "What typing does to the note — and the commits Variorum keeps for you."
        case .shortcuts: "Every keyboard shortcut and menu door, grouped. Search above reaches it."
        // 13i-d U6 (a) — found on the walk: the door this names mints a
        // GATHERING (its words are "Make a Gathering…").
        case .tags: "The whole tag hierarchy: create, rename, re-parent, and make a gathering from tags."
        // 13n-b U3 walk finding W-1: "what they can read" stopped being
        // true when the write rungs landed (U2) — a client may change what
        // it is granted now, up to edit.
        // 13n-c U4: + the asks waiting for an answer (arrival X).
        // 13n-c Stage B R1 B7: the setup menu (U5, VX-274) sets up Claude
        // Code, Codex or any MCP client — the description says so. 13n-c O-4
        // (her ask — no provider hardwired outside the setup): it says "any MCP
        // client", naming none (PROVISIONAL, her copy pass).
        // 13n-c UX walk W-UX-18 (T-16): SHORTENED, not wrapped — at two lines
        // Terminal's mono cut "…how to set up any…", losing "any MCP client";
        // the header's two-line rule holds every pane (the oracle pin measures
        // it). "The local MCP server" lives on in the switch's own sentence.
        case .mcp: "Which clients may connect, what each may read and change, the asks waiting for "
            + "you, and how to set up any MCP client."
        case .protection: "The passphrase, how the library locks, and the ways back in."
        case .dataSafety: "Backups, how fresh they are, and what restoring one does."
        case .diagnostics: "Crash reports \u{2014} off unless you turn them on, and never sent without you."
        case .acknowledgments: "The open-source notices Variorum is built on."
        }
    }

    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .editor: "text.alignleft"
        case .takes: "rectangle.stack"
        case .writing: "pencil.line"
        case .shortcuts: "keyboard"
        case .tags: "tag"
        case .mcp: "point.3.connected.trianglepath.dotted"
        case .protection: "lock.shield"
        case .dataSafety: "externaldrive.badge.timemachine"
        case .diagnostics: "stethoscope"
        case .acknowledgments: "text.book.closed"
        }
    }
}

// MARK: - The catalog (every settings row, as data)

/// ONE settings control, described. The pane renders `title`; the search
/// shows `title` + `blurb`; `keywords` are the words she might type that
/// are not in either.
nonisolated struct SettingsRow: Identifiable, Sendable, Equatable {
    let id: String
    let pane: SettingsPane
    let title: String
    let blurb: String
    var keywords: [String] = []
}

nonisolated enum SettingsCatalog {
    /// **The pane's label comes from here, not from a literal at the
    /// control.** That is the whole reason this exists as data: a search
    /// result that names a row the pane does not show is the same defect
    /// class as her item 7 one menu over — a face and its description
    /// drifting because nothing tied them together.
    ///
    /// VX-309 U2 — VX-453: the BUILD's catalog. On the new road (a Debug
    /// build — `ProtectionRoad.newRoadIsLive`) the account section's row
    /// joins beside the Protection pane's; Release — today's road — keeps
    /// `everyRoadsRows` byte for byte.
    static let rows: [SettingsRow] = rows(newRoad: ProtectionRoad.newRoadIsLive)

    /// The catalog for a road: the rows every road renders, plus — on the
    /// new road — the account section's (after the Protection pane's own
    /// row, so it reads beside it).
    static func rows(newRoad: Bool) -> [SettingsRow] {
        guard newRoad, let protection = everyRoadsRows.firstIndex(where: { $0.id == "protection" }) else {
            return everyRoadsRows
        }
        var rows = everyRoadsRows
        rows.insert(accountRow, at: protection + 1)
        return rows
    }

    /// **VX-309 U2 — RIDER VX-453 — the new road's Settings ▸ Protection ▸
    /// Sync section** (`RoadAccountSection`: the library's sync situation,
    /// who's signed in, and its doors — turn on sync, sign in or out, stop
    /// syncing here, use this Mac only, move or follow). Its title IS the
    /// section's (`ProtectionWords.accountSectionTitle` — one text, the
    /// face's and the search's); "account" — the word the search answered
    /// nothing to — leads its keywords. The blurb and the keywords are
    /// PROVISIONAL P-VX309-U2-11.
    static let accountRow = SettingsRow(
        id: "account", pane: .protection, title: ProtectionWords.accountSectionTitle,
        blurb: "Whether this library syncs with your account and who's signed in \u{2014} with "
            + "the doors to turn on sync, sign in or out, stop syncing here, or use this "
            + "library on this \(ProtectionCopy.deviceName) only.",
        keywords: ["account", "sign in", "sign out", "signed in", "log in", "login", "log out",
                   "email", "turn on sync", "stop syncing", "other device", "iphone", "follow",
                   "move", "server", "cloud"])

    /// The rows every road renders.
    static let everyRoadsRows: [SettingsRow] = [
        // MARK: General
        SettingsRow(
            // Her ruling 2026-10-13: "Design voice" reads "Theme". The old
            // name stays a search word (the "promote" precedent above).
            id: "voice", pane: .general, title: "Theme",
            blurb: "Terminal (mono, airy, its own idioms) or Study (warm paper and serif).",
            keywords: ["voice", "design voice", "terminal", "study", "serif", "mono",
                       "monospace", "font", "typeface", "look", "style"]),
        SettingsRow(
            id: "palette", pane: .general, title: PaletteCopy.title,
            blurb: "Sixteen palettes plus your own hex — the room, the wash, the accent and "
                + "the take tints, under either voice.",
            keywords: ["colour", "color", "palette", "tint", "accent", "hex", "pastel",
                       "custom", "background"]),
        SettingsRow(
            id: "appearance", pane: .general, title: "Appearance",
            blurb: "Follow system, light, or dark. Dark is a fully black room in both voices. "
                + "This Mac only.",
            keywords: ["dark", "light", "dark mode", "night", "black", "bright", "system"]),
        // 13r U3-A: the update ask's Settings answer (the calm-asks rule 4).
        SettingsRow(
            id: "updates", pane: .general, title: UpdateSettingsCopy.title,
            blurb: "Whether Variorum looks for a newer version about once a day. "
                + "Check for Updates\u{2026} in the Variorum menu works either way.",
            keywords: ["update", "updates", "upgrade", "new version", "sparkle", "automatic",
                       "check", "version", "release"]),
        SettingsRow(
            id: "receipts", pane: .general, title: ReceiptStyleCopy.title,
            blurb: "Whether an act that landed says so as a toast, a quiet line, or nothing. "
                + "Refusals always show.",
            keywords: ["toast", "receipt", "message", "quiet", "notification", "banner",
                       "confirmation", "status"]),
        // VX-139: the Open strip across launches ("tabs" is her own word
        // for the rows, so search answers it).
        SettingsRow(
            id: "keepOpenNotes", pane: .general, title: "Keep open notes across launches",
            blurb: "The sidebar's Open section returns as you left it when Variorum next "
                + "opens. This Mac only.",
            keywords: ["tabs", "tab", "open notes", "strip", "remember", "restore",
                       "relaunch", "launch", "startup", "reopen", "session"]),

        // MARK: Editor
        SettingsRow(
            id: "seams", pane: .editor, title: "Show block seams (dotted lines between blocks)",
            blurb: "The dotted line between blocks. Off by default — at rest a note reads as "
                + "seamless prose. ⌘⇧B toggles it too.",
            keywords: ["seam", "dotted", "boundary", "boundaries", "divider", "block lines"]),
        SettingsRow(
            id: "indicator", pane: .editor, title: "Mark the block being edited",
            blurb: "Off, an outline ring, or a background wash on the block you are in.",
            keywords: ["ring", "outline", "highlight", "background", "indicator", "focus"]),
        SettingsRow(
            id: "inlineComments", pane: .editor,
            title: "Show comments inline (tinted, under the block)",
            blurb: "Comments as tinted strips under the block instead of cards in the margin.",
            keywords: ["comment", "margin", "gutter", "note", "remark", "annotation"]),
        SettingsRow(
            id: "hoverHandles", pane: .editor,
            title: "Show the block drag handle on hover (Write)",
            blurb: "Pointing at a block reveals its ⠿ drag handle. This Mac only.",
            keywords: ["drag", "handle", "move", "reorder", "hover", "grip"]),
        SettingsRow(
            id: "longBlocks", pane: .editor, title: "Lay out very long blocks as you reach them",
            blurb: "Removes the empty space the text system guesses at under a very long "
                + "block. This Mac only.",
            keywords: ["phantom", "space", "gap", "layout", "long", "scroll", "performance"]),
        SettingsRow(
            id: "paragraphGap", pane: .editor, title: "Space between paragraphs",
            blurb: "Standard, or a blank line's worth of air after every paragraph. "
                + "Nothing is stored; exports are identical either way.",
            keywords: ["gap", "spacing", "blank line", "air", "leading", "paragraph"]),
        SettingsRow(
            id: "arrivalFlash", pane: .editor, title: ArrivalFlashCopy.title,
            blurb: "A brief highlight on your place after you switch between Write, Takes "
                + "and Read, fading in about a second. On by default; synced.",
            keywords: ["flash", "highlight", "cursor", "caret", "mode", "switch", "find my place",
                       "blink", "pulse", "where am i"]),
        // 13i-c U4 (the sitting record §6): the two ownership settings.
        SettingsRow(
            id: "ownershipBadges", pane: .editor, title: OwnershipSettingsCopy.badgesTitle,
            blurb: "Marks on notes that live in several books, and \u{201C}owned by\u{201D} on notes "
                + "an owned book holds. On by default; synced.",
            keywords: ["badge", "owned", "owner", "shared", "mark", "book", "membership"]),
        SettingsRow(
            id: "hideOwnedDefault", pane: .editor, title: OwnershipSettingsCopy.hideOwnedTitle,
            blurb: "Leave notes an owned book holds out of gatherings and tag listings. Off by "
                + "default; each gathering can choose; the Library shows everything. Synced.",
            keywords: ["hide", "owned", "gathering", "tag", "listing", "book", "filter"]),
        SettingsRow(
            id: "spellcheck", pane: .editor, title: "Spellchecking",
            blurb: "Off, check while typing, or check and correct. Applies to every writing "
                + "surface. This Mac only.",
            keywords: ["spelling", "spell check", "autocorrect", "typo", "underline",
                       "grammar"]),

        // MARK: Takes
        SettingsRow(
            id: "fanStyle", pane: .takes, title: "Takes open as",
            blurb: "Stack, carousel, margin grid, or slot split — the four ways a block's fan "
                + "lays out.",
            keywords: ["fan", "bloom", "stack", "carousel", "grid", "slot", "alternates",
                       "cards"]),
        SettingsRow(
            id: "followScroll", pane: .takes, title: "Takes follow the scroll",
            blurb: "Open takes track the block you scroll to instead of staying where they "
                + "were opened.",
            keywords: ["follow", "scroll", "track", "fan"]),

        // MARK: Writing
        SettingsRow(
            id: "segmentation", pane: .writing, title: SegmentationFaceCopy.globalTitle,
            blurb: "Whether a new paragraph becomes its own block as you type past it. "
                + "Synced; a note's own chip still wins where it is set.",
            keywords: ["newline", "return", "enter", "paragraph", "block", "one block",
                       "segmentation", "split"]),
        SettingsRow(
            id: "cadence", pane: .writing, title: SavepointCadenceCopy.title,
            blurb: "How often Variorum makes a quiet commit for you. The insurance "
                + "occasions stay on in every mode.",
            keywords: ["savepoint", "commit", "autosave", "history", "backup", "version",
                       "cadence"]),
        SettingsRow(
            id: "pruning", pane: .writing, title: HistoryPruningCopy.title,
            blurb: "Whether old quiet commits are trimmed, and after how long. "
                + "Never means never, on every device.",
            keywords: ["prune", "trim", "clean", "history", "old", "savepoints"]),

        // MARK: The panes that are their own thing
        SettingsRow(
            id: "tagManager", pane: .tags, title: "Tag manager",
            blurb: "The whole hierarchy: new tags, child tags, rename, delete with the "
                + "subtree — and Make a Gathering, which shows every note with those tags.",
            // 13i-d U6 (a): "promote" stays a search word (the door's old
            // name finds it); "smart" is retired (§14).
            keywords: ["tag", "tags", "hierarchy", "rename", "promote", "gathering",
                       "label", "folder"]),
        // VX-281 ladder R1-4 (R-VX184-6: the setup lives on the Connect tab):
        // the Connect tab's own row — its title IS the section's words, so a
        // search for the setup's words opens the pane ON Connect
        // (`MCPPaneTab.holding`), never behind another tab.
        // VX-281 ladder R2-3: listed AHEAD of the server switch's row, so a
        // search tied between them (her client's name — "claude" — the
        // switch's keyword and Connect's "claude code") goes to the setup
        // (R1-4's rule; ties break by this order, `SettingsSearch.findings`).
        SettingsRow(
            id: "mcpConnect", pane: .mcp, title: MCPPaneCopy.connectSection,
            blurb: "The setup for your MCP client, ready to copy: a command for a terminal, "
                + "or settings to paste into the client.",
            keywords: ["connect", "setup", "set up", "install", "command", "copy", "claude code",
                       "codex", "json", "stdio"]),
        // VX-281 ladder R2-3 — PROVISIONAL P-VX281-R2-1 (b): the Clients
        // tab's own row (its title IS the tab's label), so a search for
        // "client"/"clients" opens the pane ON Clients, where the client list
        // lives (`MCPPaneTab.holding`) — its lead "Clients" outranks
        // "Connect a client" for "client" (a prefix against a contains). No
        // setup word among its keywords: every setup word still lands on
        // Connect. Its blurb is new words (FOR VX-234).
        SettingsRow(
            id: "mcpClients", pane: .mcp, title: MCPPaneCopy.clientsSection,
            blurb: "Every client you've approved or denied: whether it's connected now, how many "
                + "grants it holds, and Change\u{2026} or Deny\u{2026} for each.",
            keywords: ["approved", "denied", "deny"]),
        // 13n-b U1 (R-13n-5 — the pane speaks direct and technical): the
        // server toggle and the one open-book switch.
        SettingsRow(
            id: "mcpServer", pane: .mcp, title: MCPPaneCopy.enableTitle,
            // 13n-c U5 (VX-274): the setup menu names Codex and any MCP
            // client's JSON, so the search finds the pane by those words too.
            // 13n-c O-4 (her ask): the blurb names no provider ("any MCP
            // client", PROVISIONAL), and the search finds the pane by whatever
            // she or a user calls their AI — the keywords are search
            // vocabulary, never copy (her (e)).
            blurb: "A local server for any MCP client. Off by default; "
                + "nothing is readable until you grant it. This Mac only.",
            // VX-281 ladder R1-4: the setup menu's own words moved to
            // `mcpConnect` (the setup lives on the Connect tab, so a search
            // for them lands there); the provider names stay here (O-4).
            keywords: ["mcp", "ai", "claude", "agent", "llm", "model context protocol",
                       "server", "client", "share", "grant", "socket",
                       "anthropic", "openai", "chatgpt", "gpt", "cursor", "gemini", "copilot",
                       "windsurf", "ollama"]),
        // 13n-c U4 — WAITING (arrival X): where a client's ask waits besides
        // its icon; ⌥⌘, opens the pane there.
        SettingsRow(
            id: "mcpWaiting", pane: .mcp, title: MCPPaneCopy.waitingSection,
            blurb: "A client's ask past what you shared waits here, newest first, and at its icon on "
                + "the note, book or wing it names \u{2014} nothing pops up by itself. \u{2325}\u{2318}, "
                + "opens it.",
            keywords: ["waiting", "ask", "asks", "pending", "answer", "request", "mcp", "ai",
                       "client", "permission"]),
        SettingsRow(
            id: "mcpOpenBook", pane: .mcp, title: MCPPaneCopy.openBookTitle,
            // 13n-c U1 (VX-163, J8): only THE daily Journal and anything
            // Private still ask — a journal-style book reads like any book.
            blurb: "The open book: every approved MCP client may read everything, always \u{2014} "
                + "your daily Journal and anything Private still ask every time.",
            keywords: ["open book", "mcp", "ai", "read everything", "share all", "always"]),
        SettingsRow(
            id: "protection", pane: .protection, title: "Protection",
            blurb: "The passphrase, when the library locks, escrow and the recovery key.",
            keywords: ["passphrase", "password", "lock", "encryption", "escrow", "recovery",
                       "touch id", "security", "castle"]),
        SettingsRow(
            id: "backups", pane: .dataSafety, title: "Backups",
            blurb: "Where copies go, how fresh the last one is, and what restoring one does — "
                + "including to things that were deleted.",
            keywords: ["backup", "restore", "copy", "folder", "safety", "icloud", "export"]),
        // 13r U3-B (R-13r-5): the crash-report opt-in, on its own pane.
        SettingsRow(
            id: "crashReports", pane: .diagnostics, title: DiagnosticsCopy.toggleTitle,
            blurb: "Off unless you turn it on. Reports stay on this Mac, shown exactly as they "
                + "arrived; Send Report\u{2026} offers an email draft for you to read first. "
                + "This Mac only.",
            keywords: ["crash", "crashes", "crashed", "report", "diagnostics", "diagnostic",
                       "privacy", "metrickit", "support", "bug", "problem", "send", "feedback",
                       "telemetry", "analytics"]),
        SettingsRow(
            id: "acknowledgments", pane: .acknowledgments, title: "Open-source notices",
            blurb: "The licences and copyright notices for what Variorum is built on.",
            keywords: ["licence", "license", "sqlcipher", "zetetic", "grdb", "credits",
                       "acknowledgments", "legal"]),
    ]

    static func rows(in pane: SettingsPane) -> [SettingsRow] {
        rows.filter { $0.pane == pane }
    }

    /// The label a control renders — by id, so a pane never types its own.
    static func title(_ id: String) -> String {
        rows.first { $0.id == id }?.title ?? id
    }
}

// MARK: - The search (her item 4)

/// One answer the search can give. `pane` is where clicking it goes.
nonisolated struct SettingsFinding: Identifiable, Sendable, Equatable {
    enum Kind: String, Sendable { case setting, shortcut, word }

    let kind: Kind
    let pane: SettingsPane
    /// The bold half: the row's label, the chord, or the word.
    let lead: String
    let detail: String
    var id: String { "\(kind.rawValue)|\(lead)" }
}

nonisolated enum SettingsSearch {
    /// An entry in the searchable index — deliberately the same shape as a
    /// finding, plus the extra words that are not in either visible half.
    struct Entry: Sendable, Equatable {
        let finding: SettingsFinding
        let keywords: [String]
    }

    /// **The filter.** Case- and diacritic-insensitive; a query matches on
    /// the lead, on a keyword, or in the detail, and the three rank in that
    /// order so the row she named comes first and the row that merely
    /// mentions the word comes last. Whitespace-only ⇒ no findings at all
    /// (the detail keeps showing the pane).
    ///
    /// Multi-word queries are ANDed across the whole entry, so "dark mode"
    /// finds the appearance row through its keyword while "block seam"
    /// finds the seams row through its title — neither needs the words
    /// adjacent, which is what makes typing half-remembered names work.
    static func findings(matching query: String, in index: [Entry]) -> [SettingsFinding] {
        let terms = query
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
        guard !terms.isEmpty else { return [] }

        var ranked: [(rank: Int, order: Int, finding: SettingsFinding)] = []
        for (order, entry) in index.enumerated() {
            let lead = fold(entry.finding.lead)
            let detail = fold(entry.finding.detail)
            let keywords = entry.keywords.map(fold)
            var worst = 0
            var matchedAll = true
            for term in terms {
                let rank: Int
                if lead == term { rank = 0 }
                else if lead.hasPrefix(term) { rank = 1 }
                else if lead.contains(term) { rank = 2 }
                else if keywords.contains(where: { $0.contains(term) }) { rank = 3 }
                else if detail.contains(term) { rank = 4 }
                else { matchedAll = false; break }
                worst = max(worst, rank)
            }
            if matchedAll { ranked.append((worst, order, entry.finding)) }
        }
        return ranked
            .sorted { $0.rank == $1.rank ? $0.order < $1.order : $0.rank < $1.rank }
            .map(\.finding)
    }

    private static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// The settings half of the index — pure, so a pin can build it without
    /// the helper's `@MainActor` lists.
    static var settingsEntries: [Entry] { settingsEntries(newRoad: ProtectionRoad.newRoadIsLive) }

    /// VX-309 U2 — VX-453: the settings half for a road (the account
    /// section's row only where the section renders).
    static func settingsEntries(newRoad: Bool) -> [Entry] {
        SettingsCatalog.rows(newRoad: newRoad).map { row in
            Entry(
                finding: SettingsFinding(
                    kind: .setting, pane: row.pane, lead: row.title, detail: row.blurb),
                keywords: row.keywords + [row.pane.title])
        }
    }
}

extension SettingsSearch {
    /// **The whole index: the settings rows, the ⌘/ helper's shortcut list,
    /// and its dictionary.**
    ///
    /// The last two are read from `HelperView`'s OWN statics, never copied:
    /// the shortcut list is hand-maintained prose in her voice and is held
    /// to the registry by `everyDeclaredShortcutIsFindableInTheHelper`, so
    /// every DECLARED chord is in this index by construction — and a
    /// keyless door named only in prose (Format ▸ Outdent, Tab in a list)
    /// is findable here for exactly the same reason.
    ///
    /// This is what makes her acceptance case literal: "callout" is not a
    /// setting, so a catalog-only search could never answer it. It is a
    /// chord (⌥⌘C) and a word (the dictionary's entry naming Block ▸
    /// Callout), and both are here.
    @MainActor static var wholeIndex: [Entry] { wholeIndex(newRoad: ProtectionRoad.newRoadIsLive) }

    /// VX-309 U2 — VX-453: the whole index for the road the window is on —
    /// the results pane asks with the account section's presence, so a
    /// search never names the section where the pane does not render it.
    @MainActor static func wholeIndex(newRoad: Bool) -> [Entry] {
        settingsEntries(newRoad: newRoad) + shortcutEntries + dictionaryEntries
    }

    @MainActor static var shortcutEntries: [Entry] {
        HelperView.groups.flatMap { group in
            group.items.map { item in
                Entry(
                    finding: SettingsFinding(
                        kind: .shortcut, pane: .shortcuts,
                        lead: item.keys, detail: item.does),
                    keywords: [group.title])
            }
        }
    }

    @MainActor static var dictionaryEntries: [Entry] {
        HelperView.entries.map { entry in
            Entry(
                finding: SettingsFinding(
                    kind: .word, pane: .shortcuts,
                    lead: entry.term, detail: entry.definition),
                keywords: [])
        }
    }
}
