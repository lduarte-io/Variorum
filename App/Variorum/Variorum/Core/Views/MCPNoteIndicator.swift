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
//  Its MCP legs, each only when true:
//  - THE SHARED ICON (VX-271's one glyph) when an approved client reaches the
//    note now — hover names who and how far; click shows the permission and
//    the WHY ("through the Home wing grant"). **VX-900 — the icon twins' one
//    rule (her ruling, the #264 sitting):** drawn while a client is APPROVED
//    (the window's `canShare` — the rows' exact gate), the server on or off;
//    while the server's switch is OFF it wears the dimmed face and its hover
//    says so (`MCPServerOffFace`), exactly as the eye beside it. It waited for
//    the server here alone (VX-164's `indicatorOn`) — no row ever did; that
//    nuance (#264) is superseded. Its reach is read through the ROWS' own
//    gated batched read (`Queries.mcpNoteReaches` over this one id), so the
//    gate rides the read: with no approved client nothing past the grants
//    store is read even if the window's gate lags;
//  - 13n-c U4's PENDING-ASK leg: the pending-ask mark (`MCPAskGlyph`) while a
//    client's ask waits on this note — her press opens it. Still behind
//    `indicatorOn` (the server ON and a client approved): an ask lives only
//    while its client is connected.
//  **VX-831 — THE PRIVATE MARK took the lock's place**, and it is the note's
//  masthead face of the mark every shared-icon host draws (`PrivateMarkView`,
//  the closed eye): shown on a Private note only while a client is approved
//  (her R-878-K3 — the shared icon's exact gate, superseding N-2), under the
//  badge family's one switch (D-831-3); its own mark's press un-privates, a Private book's says
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
    /// stamp, or the live Private books holding it — `Queries.privateMarksDrawn`,
    /// the rows' own GATED read); nil when it is not Private, and — R-878-K3 —
    /// nil while no client is approved (nothing read past the grants store).
    /// It replaced the lock's two fields (`isNotePrivate` +
    /// `privateBooksHolding`), which are derived below.
    let mark: Queries.PrivateMark?
    /// Who reaches it now, how far and why — the ONE rule, read since VX-900
    /// through the rows' own GATED batched read (`Queries.mcpNoteReaches`
    /// over this one id; pinned id-for-id equal to the singular
    /// `mcpNoteReach`), so with no approved client the read stops at the
    /// grants store whatever the caller asks. Read only while the window says
    /// a client is approved (`includingReach`, the road's `canShare`) — the
    /// server on or off (VX-900; it was VX-164's `indicatorOn`).
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
            mark: try Queries.privateMarksDrawn(db, noteIDs: [postID])[postID],
            reach: includingReach ? (try Queries.mcpNoteReaches(db, noteIDs: [postID])[postID] ?? []) : [])
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

    /// The pending-ask leg's gate (VX-164): the server on and a client
    /// approved — an ask lives only while its client is connected.
    private var indicatorOn: Bool { road?.indicatorOn == true }
    /// **VX-900 — the shared icon's gate here is the rows'**: a client
    /// approved (the window's `canShare`), the server on or off — the switch
    /// only dims the icon (`MCPSharedIcon` reads it off the same road). No
    /// road (a harness mount): no icon and no reach read, as before.
    private var drawsReach: Bool { road?.canShare == true }

    var body: some View {
        let state = MCPNoteIndicatorState.matching(state, postID: postID)
        // VX-831: the masthead's mark — drawn on anything marked while a
        // client is approved (R-878-K3 — the gate rides the read), under the
        // badge family's one switch (D-831-3). VX-900: dimmed while the
        // server's switch is off (`PrivateMarkView` reads the road).
        let mark = PrivateMarkFace.note(state?.mark, badgesOn: themeStore?.settings.ownershipBadges ?? true)
        // Always present, even empty: it carries the held read (`.task` below) — a conditional here strands the server-off mark's read (R-878-K3; VX-878 ladder F3).
        HStack(spacing: 4) {
            if drawsReach, let state, !state.reach.isEmpty {
                // W-UX-12: at the window's trailing edge — open leftward.
                // VX-900: drawn with the server off too, in the dimmed face.
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
        // a client is approved (VX-900 — `drawsReach`; the shared icon's law,
        // and the read itself is gated too), so the read restarts when the
        // first client is approved or the last one goes — never on the
        // server's switch, which changes the face alone.
        .task(id: WatchKey(postID: postID, includingReach: drawsReach)) {
            await watch(includingReach: drawsReach)
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
