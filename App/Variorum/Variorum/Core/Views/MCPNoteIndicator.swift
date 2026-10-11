//
//  MCPNoteIndicator.swift
//  Variorum (MAC ONLY) — Core/Views (composed by `PaneHost` into every pane's
//  `ContextBar`, both window kinds)
//
//  13n-c U3 — VX-164, THE IN-NOTE INDICATOR (R-AIR-7, hers: "with MCP on, a
//  note's upper right shows at a glance what an AI can reach … Never
//  surprised, from within a note."). It sits at the TRAILING end of the pane's
//  context bar — the note's upper right in every note mode (the bar is the
//  pane's, so Write, Takes, Read, Lenses, Compare and Blocks share it) and in
//  a note-only window. CHROME ONLY: it never touches the editor seam.
//
//  It renders ONLY while the server is ON and at least one client is
//  APPROVED (the window's road — `indicatorOn`), and then says exactly two
//  things, each only when true:
//  - THE SHARED ICON (R-AIR-6's one glyph) when an approved client reaches the
//    note now — hover names who and how far; click shows the permission and
//    the WHY ("through the Home wing grant");
//  - THE LOCK when the note is Private — its own mark (click → the Private
//    toggle) or a Private book's (click → the book's name; the mark is changed
//    in that book's settings).
//  Neither ⇒ NOTHING (calm — "an empty state that says nothing"). The
//  pending-ask leg is U4's (its glyph is `MCPSharedIcon.pendingSymbol`).
//

import GRDB
import SwiftUI
import VariorumCore

/// What the indicator draws for one note — read in ONE observed read.
nonisolated struct MCPNoteIndicatorState: Equatable, Sendable {
    let postID: String
    /// Its OWN Private mark.
    let ownPrivate: Bool
    /// Live Private books holding it, by name.
    let privateBooks: [String]
    /// Who reaches it now, how far and why (`Queries.mcpNoteReach` — the ONE
    /// rule).
    let reach: [MCPPlaceReach]

    var isPrivate: Bool { ownPrivate || !privateBooks.isEmpty }
    /// Nothing to say — the calm state.
    var isEmpty: Bool { reach.isEmpty && !isPrivate }

    static func read(_ db: Database, postID: String) throws -> MCPNoteIndicatorState {
        MCPNoteIndicatorState(
            postID: postID,
            ownPrivate: try Queries.isNotePrivate(db, postID: postID),
            privateBooks: try Queries.privateBooksHolding(db, postID: postID),
            reach: try Queries.mcpNoteReach(db, noteID: postID))
    }

    /// Only a state read for THIS note draws (a stale read never draws
    /// another note's mark — `NotePrivacyState.matching`'s rule).
    static func matching(_ state: MCPNoteIndicatorState?, postID: String) -> MCPNoteIndicatorState? {
        state?.postID == postID ? state : nil
    }
}

struct MCPNoteIndicator: View {
    /// P-1's walk: the shared icon (`.mcpShowSharing`, its popover's Change… /
    /// Revoke) and the lock's Private toggle (`.markNotePrivate`'s `.surface`
    /// door).
    static let surfaceCapabilities: [CapabilityID] =
        MCPSharedIcon.surfaceCapabilities + [.markNotePrivate]

    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    @Environment(\.mcpShareRoad) private var road
    @State private var state: MCPNoteIndicatorState?
    @State private var lockShown = false

    var body: some View {
        if road?.indicatorOn == true {
            HStack(spacing: 4) {
                if let state = MCPNoteIndicatorState.matching(state, postID: postID) {
                    if !state.reach.isEmpty {
                        MCPSharedIcon(reaches: state.reach, tokens: tokens)
                    }
                    if state.isPrivate { lock(state) }
                }
            }
            // Held while the indicator is ON (the read touches `container`'s
            // mark and membership columns, never the buffer's — the note ▾
            // menu's own privacy read, `NotePrivacyState`, has this shape).
            .task(id: postID) { await watch() }
        }
    }

    private func lock(_ state: MCPNoteIndicatorState) -> some View {
        Button {
            lockShown.toggle()
        } label: {
            Image(systemName: "lock")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.horizontal, 2)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(MCPShareCopy.lockHelp)
        .accessibilityLabel(MCPShareCopy.lockHelp)
        .popover(isPresented: $lockShown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(CapabilityRegistry.capability(.markNotePrivate).verb, isOn: Binding(
                    get: { state.ownPrivate },
                    set: { on in
                        let session = session
                        let postID = postID
                        Task { await NotePrivacyAct.set(on, postID: postID, session: session) }
                    }))
                if !state.privateBooks.isEmpty {
                    Text(MCPShareCopy.privateThrough(state.privateBooks))
                        .font(.caption)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(MCPShareCopy.privateThroughNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(minWidth: 220, maxWidth: 320, alignment: .leading)
        }
    }

    private func watch() async {
        let database = session.database
        let postID = postID
        do {
            for try await value in database.observe({ db in try MCPNoteIndicatorState.read(db, postID: postID) }) {
                guard !Task.isCancelled else { return }
                if state != value { state = value }
            }
        } catch {}
    }
}
