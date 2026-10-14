//
//  MCPShareRoad.swift
//  Variorum (MAC ONLY) — Core/Views (the shared home: every share face reads it)
//
//  13n-c U3 — GRANT FROM WHERE YOU ARE (VX-156 items 2/3; VX-270 · VX-271 · VX-164 · VX-272). The
//  faces outside Settings ▸ MCP — the Library's bulk bar and note rows, every
//  book row menu, Book Settings, the Bookcase's shared icon, the in-note
//  indicator, ⌥⌘A's receipt — reach the MCP door through THIS road, built by
//  each WINDOW (composition: `RootView`, `NoteWindowView`) from the door's
//  narrow observables. A feature never holds `MCPDoor` (the MCP feature's) or
//  names `MCPGrantSheet`: it reads what the road says and calls what it opens
//  (CLAUDE.md — state and ownership route through the parent; the
//  `checkForUpdatesDoor` / `.environment(wings)` precedent).
//
//  VX-272: every share face renders ONLY when at least one APPROVED client
//  exists (`canShare`) — with none, no door; the zero-state lives in Settings ▸
//  MCP. VX-164: the in-note indicator also needs the server ON (`indicatorOn`).
//

import SwiftUI
import VariorumCore

/// **WHERE a grant sheet opens pre-filled** (13n-c U2 built `.note`/`.book`/
/// `.wing`; U3 adds `.notes` — the Library's "Share N notes…").
enum MCPGrantPrefill: Equatable, Sendable {
    case note(String)
    /// Several notes, granted in ONE act (`grantMCPAccess(_:notes:…)`). One id
    /// reads exactly as `.note`.
    case notes([String])
    case book(String)
    case wing(String)
}

/// **What opens the grant sheet** (13n-c U2 — the opener; U3 moved it to the
/// road's home and grew it for its doors).
struct MCPGrantOpening: Identifiable, Equatable {
    let id = UUID().uuidString
    /// Who the grant is for; nil = the sheet asks (WHO).
    var client: MCPClient?
    /// A first approval (Approve… on a connection request). W-UX-2 (her
    /// ruling — approve alone, grant separate): the approval stands on its
    /// own; a grant rides it, in one act, only when she picks one.
    var approving = false
    /// WHERE, pre-filled; nil = the sheet's own start (`MCPGrantSheet.start`
    /// — nothing picked on the approval road, else the most recent book).
    var place: MCPGrantPrefill?
    /// 13n-c U3 (VX-270): the rung and duration pre-filled — Change… opens
    /// on exactly what was shared, to change it fast.
    var rung: MCPGrantRule.Rung? = nil
    var duration: MCPGrantRule.Duration? = nil
    /// 13n-c U3 (T-U3-8 — Change… REPLACES): the grants the confirm revokes in
    /// the same act (`grantMCPAccess(_:_:replacing:)`). Empty = a new grant.
    var replacing: [String] = []
    /// Where the sheet was opened: the pane speaks in its own caption; a
    /// place-door's sheet speaks on the window's status seam (a receipt with
    /// its Change… · Revoke › doors, or the refusal).
    var origin: Origin = .pane

    enum Origin: Equatable, Sendable {
        case pane
        case place
    }

    static func == (lhs: MCPGrantOpening, rhs: MCPGrantOpening) -> Bool { lhs.id == rhs.id }
}

/// **The faces' one road to the MCP door** (built per window).
///
/// EQUATABLE ON ITS TWO GATES ONLY: a window rebuilds the road on every pass of
/// its body, and an environment value SwiftUI cannot compare reads as CHANGED
/// every time — which would re-render every surface reading it (the Library,
/// the Bookcase, each pane's bar) on each of the window's own re-renders. The
/// closures are the window's own and stable in what they do, so two roads
/// with the same gates ARE the same road.
@MainActor
struct MCPShareRoad: Equatable {
    /// At least one APPROVED client (VX-272) — every share face's gate.
    let canShare: Bool
    /// The server ON and at least one approved client (VX-164) — the in-note
    /// indicator's gate.
    let indicatorOn: Bool
    /// Open THE grant sheet in this window, pre-filled. (A `var` since VX-268:
    /// a host already in a sheet — ⌘L's switcher — keeps it HERE, the
    /// `answeringAsks` shape: `openingHere`.)
    var open: (MCPGrantOpening) -> Void
    /// THE grant sheet as a view, for a host that must present it ITSELF — a
    /// sheet already up (Book Settings, T-U3-7). `done` dismisses it.
    let sheet: (MCPGrantOpening, @escaping () -> Void) -> AnyView
    /// Revoke these grants in one act (a popover's Revoke) — awaited, so the
    /// face that asked re-reads after it lands.
    let revoke: ([String]) async -> Void
    /// 13n-c U4 — ARRIVAL X: open THIS ask's sheet in this window (a pending
    /// glyph's press — hers, so the etiquette is untouched). An ask answered
    /// elsewhere meanwhile opens nothing (the sheet reads the queue).
    var answerAsk: (String) -> Void = { _ in }
    /// 13n-c U4 — THE ASK'S SHEET as a view, for a host that must present it
    /// ITSELF because a sheet is already up (⌘L's switcher — the T-U3-7
    /// precedent `sheet` set for Book Settings). Nil content once the ask no
    /// longer waits.
    var askSheet: (MCPAskOpening) -> AnyView = { _ in AnyView(EmptyView()) }

    /// This road with its ask presses kept HERE — a nested host (a sheet
    /// already up) opens the ask over itself instead of asking the window.
    func answeringAsks(_ open: @escaping (String) -> Void) -> MCPShareRoad {
        var road = self
        road.answerAsk = open
        return road
    }

    /// **VX-268 — this road with its grant sheet kept HERE**: a nested host
    /// (⌘L's switcher — a sheet already up) presents THE grant sheet over
    /// itself (`sheet`) when a row's popover asks Change…, instead of asking
    /// the window to present one under it (T-U3-7's precedent, Book Settings).
    func openingHere(_ open: @escaping (MCPGrantOpening) -> Void) -> MCPShareRoad {
        var road = self
        road.open = open
        return road
    }

    nonisolated static func == (lhs: MCPShareRoad, rhs: MCPShareRoad) -> Bool {
        lhs.canShare == rhs.canShare && lhs.indicatorOn == rhs.indicatorOn
    }
}

private struct MCPShareRoadKey: EnvironmentKey {
    static let defaultValue: MCPShareRoad? = nil
}

extension EnvironmentValues {
    /// nil in harness mounts and wherever no window built one — every share
    /// face is then simply not drawn.
    var mcpShareRoad: MCPShareRoad? {
        get { self[MCPShareRoadKey.self] }
        set { self[MCPShareRoadKey.self] = newValue }
    }
}

/// **The share faces' words** (13n-c U3). The APP's voice where the face is
/// app-wide (P-13n-1 — menus, the bulk bar, receipts: "Share with AI…", the
/// mockup §2/§3 words); the settings-class faces (Book Settings' row, the
/// permission popovers) carry no "AI" (VX-272 — "Shared with", the client's
/// own name says who). Sentence case in every sentence; Title Case only where
/// the menu bar and context menus already use it. PROVISIONAL P-13nc-U3-2 —
/// her copy pass; every string here is 13s-a sweepable.
nonisolated enum MCPShareCopy {
    // MARK: - The doors (app voice)

    /// A note or book row's menu (mockup §2).
    static let shareVerb = "Share with AI\u{2026}"
    /// The Library bulk bar (mockup §2, sentence case like its neighbours).
    static func shareNotes(_ count: Int) -> String { "Share \(count) notes with AI\u{2026}" }
    /// The Edit menu's ⌥⌘A (mockup §3; the menu bar keeps Title Case —
    /// P-13nb-U4-15's "Show the AI's Last Change").
    static let shareThisNote = "Share This Note with AI"
    static let shareThisNoteUnavailable =
        "Share This Note with AI acts on the note you have open \u{2014} open one first."
    /// The zero-state's one sentence (VX-272 — a share face renders only
    /// with an approved client; this is the registry's refusal copy).
    static let zeroState = "Sharing starts in Settings \u{25B8} MCP, once a client is approved."
    /// The icon's registry verb (its hover says who and how far).
    static let showSharingVerb = "Who Can Reach This"

    // MARK: - Book Settings (settings-class — no "AI")

    static let sharedWithLabel = "Shared with"
    static let notShared = "No client reaches this book."
    static let shareButton = "Share\u{2026}"

    /// "claude-code (read and suggest), codex (read)" — at most two, then
    /// "and N more".
    static func clients(_ reaches: [MCPPlaceReach]) -> String {
        let named = reaches.prefix(2).map { "\($0.clientName) (\(MCPRungWords.reach($0.rung)))" }
        let more = reaches.count > 2 ? " and \(reaches.count - 2) more" : ""
        return named.joined(separator: ", ") + more
    }

    // MARK: - The icon and its popover (settings-class)

    /// The icon's hover: who reaches it and how far (VX-271).
    static func iconHelp(_ reaches: [MCPPlaceReach]) -> String {
        "Shared with " + clients(reaches) + " \u{2014} click for details"
    }
    static let popoverTitle = "Shared with"
    /// One reach's line: "read and suggest · while connected".
    static func reachLine(_ reach: MCPPlaceReach) -> String {
        "\(MCPRungWords.reach(reach.rung)) \u{00B7} \(MCPPaneCopy.durationWord(reach.duration))"
    }
    /// The WHY, when the reach comes from somewhere wider than the place
    /// itself (VX-164's "readable through the Home wing grant").
    static func why(_ reach: MCPPlaceReach) -> String? {
        guard let grant = reach.grant else { return "through the open book" }
        guard let through = reach.throughTitle else { return nil }
        switch grant.scopeKind {
        case .wing: return "through the \(through) wing grant"
        case .book: return "through \u{201C}\(through)\u{201D}"
        case .note: return nil
        }
    }
    static let change = "Change\u{2026}"
    static let revoke = "Revoke"
    /// **13n-c UX walk W-UX-5** (T-17's FACE — its design, P-13nc-U3-6, is
    /// ruled and untouched): on a row whose reach comes THROUGH a wider grant,
    /// Revoke takes back that wider grant — so the button says which ("Revoke
    /// the Home wing grant", "Revoke the grant on “the lightning thief”"),
    /// never a bare "Revoke" that looks like the place's own. The place's own
    /// grant keeps the plain verb. PROVISIONAL words, her copy pass.
    static func revokeLabel(_ reach: MCPPlaceReach) -> String {
        guard let grant = reach.grant, let through = reach.throughTitle else { return revoke }
        switch grant.scopeKind {
        case .wing: return "Revoke the \(through) wing grant"
        case .book: return "Revoke the grant on \u{201C}\(through)\u{201D}"
        case .note: return revoke
        }
    }
    static let openBookNote = "The open book is switched in Settings \u{25B8} MCP."

    // MARK: - The in-note indicator (VX-164)

    static let lockHelp = "Private \u{2014} click to change"
    static func privateThrough(_ names: [String]) -> String { PrivateMarkCopy.throughBooks(names) }
    static let privateThroughNote = "A book's Private mark is changed in its Book Settings."

    // MARK: - Receipts (app voice — P-13n-1)

    /// "Shared “parser notes” with claude-code — read and suggest, while
    /// connected." (mockup §3, verbatim shape). `place` is already said
    /// ("“parser notes”", "3 notes", "the Home wing").
    static func shared(
        place: String, client: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration
    ) -> String {
        "Shared \(place) with \(client) \u{2014} \(MCPRungWords.reach(rung)), "
            + "\(MCPPaneCopy.durationWord(duration))."
    }
    /// Change…'s receipt: the same sentence, the verb its own.
    static func changed(
        place: String, client: String, rung: MCPGrantRule.Rung, duration: MCPGrantRule.Duration
    ) -> String {
        "Changed \(place) for \(client) \u{2014} \(MCPRungWords.reach(rung)), "
            + "\(MCPPaneCopy.durationWord(duration))."
    }
    /// ⌥⌘A's refusal when the client already reaches the note (mockup §3).
    static func alreadyReaches(_ client: String, _ rung: MCPGrantRule.Rung) -> String {
        "\(client) already reaches this note (\(MCPRungWords.reach(rung)))."
    }
    static let revokeDoor = "Revoke \u{203A}"
    static let changeDoor = "Change\u{2026}"
    static let revoked = "Revoked."

    /// How a place reads inside a receipt.
    static func quoted(_ title: String) -> String { "\u{201C}\(title)\u{201D}" }
    static func notesCount(_ count: Int) -> String { count == 1 ? "1 note" : "\(count) notes" }
    static func wingPlace(_ name: String) -> String { "the \(name) wing" }
}
