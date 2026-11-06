//
//  MCPNoteIndicator.swift
//  Variorum (MAC ONLY) — Core/Views (composed by `PaneHost` into every pane's
//  `ContextBar`, both window kinds)
//
//  13n-c U3 — VX-164, THE IN-NOTE INDICATOR (VX-164, hers: "with MCP on, a
//  note's upper right shows at a glance what an AI can reach … Never
//  surprised, from within a note."). It sits at the TRAILING end of the pane's
//  context bar — the note's upper right in every note mode (the bar is the
//  pane's, so Write, Takes, Read, Lenses, Compare and Blocks share it) and in
//  a note-only window. CHROME ONLY: it never touches the editor seam.
//
//  Its MCP legs render ONLY while the server is ON and at least one client is
//  APPROVED (the window's road — `indicatorOn`), each only when true:
//  - THE SHARED ICON (VX-271's one glyph) when an approved client reaches the
//    note now — hover names who and how far; click shows the permission and
//    the WHY ("through the Home wing grant");
//  - 13n-c U4's PENDING-ASK leg: the pending-ask mark (`MCPAskGlyph`) while a
//    client's ask waits on this note — her press opens it.
//  **VX-831 — THE PRIVATE MARK took the lock's place**, and it is the note's
//  masthead face of the mark every shared-icon host draws (`PrivateMarkView`,
//  the closed eye): shown on a Private note whatever the clients (N-2), under
//  the badge family's switch and also wherever the indicator is on (the lock's
//  old gate, D-831-3); its own mark's press un-privates, a Private book's says
//  so and offers the book. Nothing true ⇒ NOTHING (calm — "an empty state that
//  says nothing").
//

import GRDB
import SwiftUI
import VariorumCore

/// What the indicator draws for one note — read in ONE observed read.
nonisolated struct MCPNoteIndicatorState: Equatable, Sendable {
    let postID: String
    /// **VX-831 — the note's Private mark** (the closed eye's fact: its own
    /// stamp, or the live Private books holding it — `Queries.privateMarks`,
    /// the rows' own read); nil when it is not Private. It replaced the lock's
    /// two fields (`isNotePrivate` + `privateBooksHolding`), which are derived
    /// below, unchanged in meaning.
    let mark: Queries.PrivateMark?
    /// Who reaches it now, how far and why (`Queries.mcpNoteReach` — the ONE
    /// rule). Read only while the indicator is ON (`includingReach`) — the
    /// shared icon's law: nothing read while no client is approved.
    let reach: [MCPPlaceReach]

    /// Its OWN Private mark.
    var ownPrivate: Bool { mark?.own ?? false }
    /// Live Private books holding it, by name.
    var privateBooks: [String] { mark?.viaBooks.map(\.name) ?? [] }
    var isPrivate: Bool { mark?.isPrivate ?? false }
    /// Nothing to say — the calm state.
    var isEmpty: Bool { reach.isEmpty && !isPrivate }

    static func read(
        _ db: Database, postID: String, includingReach: Bool = true
    ) throws -> MCPNoteIndicatorState {
        MCPNoteIndicatorState(
            postID: postID,
            mark: try Queries.privateMarks(db, noteIDs: [postID])[postID],
            reach: includingReach ? try Queries.mcpNoteReach(db, noteID: postID) : [])
    }

    /// Only a state read for THIS note draws (a stale read never draws
    /// another note's mark — `NotePrivacyState.matching`'s rule).
    static func matching(_ state: MCPNoteIndicatorState?, postID: String) -> MCPNoteIndicatorState? {
        state?.postID == postID ? state : nil
    }
}

struct MCPNoteIndicator: View {
    /// P-1's walk: the shared icon (`.mcpShowSharing`, its popover's Change… /
    /// Revoke) and — VX-831 — the Private mark, the closed eye that replaced
    /// the lock (`.markNotePrivate`'s `.surface` door, and its via-book arm's
    /// door, the ascent).
    static let surfaceCapabilities: [CapabilityID] =
        MCPSharedIcon.surfaceCapabilities + PrivateMarkView.noteSurfaceCapabilities
        // 13n-c U4 — the pending-ask leg (VX-164's third mark).
        + MCPAskGlyph.surfaceCapabilities

    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    @Environment(\.mcpShareRoad) private var road
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @State private var state: MCPNoteIndicatorState?

    /// The indicator's own gate (VX-164): the server on and a client approved.
    private var indicatorOn: Bool { road?.indicatorOn == true }

    var body: some View {
        let state = MCPNoteIndicatorState.matching(state, postID: postID)
        // VX-831: the masthead's mark — drawn on anything marked, whatever
        // the clients (N-2), under the badge family's switch, and also
        // wherever the indicator shows (the lock's old gate — D-831-3).
        let mark = PrivateMarkFace.masthead(
            state?.mark, badgesOn: themeStore?.settings.ownershipBadges ?? true, indicatorOn: indicatorOn)
        HStack(spacing: 4) {
            if indicatorOn, let state, !state.reach.isEmpty {
                // W-UX-12: at the window's trailing edge — open leftward.
                MCPSharedIcon(reaches: state.reach, tokens: tokens, arrowEdge: .leading)
            }
            // VX-831 — THE PRIVATE MARK (the closed eye), where the lock was:
            // its own mark's press un-privates; a Private book's says so and
            // offers the book. Nothing when the note is not Private.
            PrivateMarkView(
                door: mark.map { PrivateMarkDoor(mark: $0, subjectID: postID, session: session) },
                tokens: tokens)
            if indicatorOn {
                // 13n-c U4 — VX-164's PENDING-ASK leg: an ask waiting on this
                // note (the door's projection, not this read — nothing when
                // none, so the calm state still says nothing).
                MCPAskGlyph(.note(postID), tokens: tokens)
            }
        }
        // Held for the note (the read touches `container`'s mark and the
        // membership rows, never the buffer's — the note ▾ menu's own privacy
        // read, `NotePrivacyState`, has this shape); its reach half only while
        // the indicator is ON (the shared icon's law), so the read restarts
        // when the indicator turns on or off.
        .task(id: WatchKey(postID: postID, includingReach: indicatorOn)) {
            await watch(includingReach: indicatorOn)
        }
    }

    private struct WatchKey: Hashable {
        let postID: String
        let includingReach: Bool
    }

    private func watch(includingReach: Bool) async {
        let database = session.database
        let postID = postID
        do {
            for try await value in database.observe({ db in
                try MCPNoteIndicatorState.read(db, postID: postID, includingReach: includingReach)
            }) {
                guard !Task.isCancelled else { return }
                if state != value { state = value }
            }
        } catch {}
    }
}
