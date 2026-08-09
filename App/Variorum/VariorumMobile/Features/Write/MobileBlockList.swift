//
//  MobileBlockList.swift
//  VariorumMobile
//
//  Parity C4b item 5 — the BLOCK-TOC in-note list (her mid-chain ruling
//  11: "an in-note block list — YES, v1; names get their phone face").
//  AppSpec §12's letter, phone-sheeted: one row per block — the block's
//  explicit NAME where set, else its first sentence DERIVED AT READ TIME
//  (never stored; `Queries.tocHandle`, the one core brain the Mac's TOC
//  reads) — and a tap jumps the editor there. This is also where block
//  names finally RENDER on the phone (the ⋯ menu has set them since S4;
//  nothing showed them — the [B1] record's "Stage C's call", called).
//
//  The Mac's TOC is a PANE (expand-into-read-tier, block management);
//  the phone's is deliberately the summoned-list HALF of it — a
//  navigation surface on the masthead-sheet grammar, machinery summoned
//  and put away (the calm-default reading; the row's ⑂ marker is the
//  Mac row's own fan signal). Rows render in a LAZY stack (P3 — only
//  near-viewport rows materialize; handles derive in the row's own body,
//  so a 1,000-block note derives only what it shows), and the READ is
//  one `blockTOC` pass — cost ∝ the post, the open-a-note class
//  (AppSpec §4's "reading a post is one indexed query"), never the
//  corpus. Deliberately NO window: a jump list that cannot reach the
//  note's far blocks fails its whole purpose, and laziness — not
//  truncation — is what P3 asks of a bounded-by-one-post surface.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileBlockListModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String

    private(set) var rows: [Queries.TOCRow] = []
    private(set) var status: String?

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    /// The masthead chip's word — deliberately COUNTLESS (recorded
    /// judgment): the chip refreshes at sheet cadence, not keystroke
    /// cadence, and a stale census on the masthead would be worse than
    /// none; the list itself is the census.
    nonisolated static let chipWord = "blocks"

    /// The sheet's empty state — the structural doors' own standing
    /// sentence (one vocabulary for "no blocks yet").
    nonisolated static let emptyNote =
        "No blocks yet — type on the page and each finished paragraph becomes one."

    /// One row's display handle, derived AT READ TIME through the one
    /// core brain (name where set, else the first sentence — never
    /// stored anywhere; the no-denormalization rule).
    nonisolated static func handle(_ row: Queries.TOCRow) -> String {
        Queries.tocHandle(name: row.name, text: row.text)
    }

    func refresh() async {
        do {
            let postID = postID
            rows = try await session.database.read { db in
                try Queries.blockTOC(db, post: postID)
            }
            status = nil
        } catch {
            status = String(describing: error)
        }
    }

    /// The presented sheet's HELD observation (parity D2 — the routed
    /// C4 NIT: the list loaded once per presentation, so a remote
    /// divide or block arrival landing WHILE the sheet was open left it
    /// one delivery stale; MobileSoul §5.3 — offline/sync races are the
    /// phone's normal). The observation delivers the initial read too,
    /// so the sheet's task is this one call; it cancels with the task
    /// when the sheet dismisses — cost ∝ the post, only while
    /// presented. `refresh()` stays the headless one-shot.
    func start() async {
        do {
            let postID = postID
            for try await value in session.database.observe({ db in
                try Queries.blockTOC(db, post: postID)
            }) {
                rows = value
                status = nil
            }
        } catch is CancellationError {
        } catch {
            status = String(describing: error)
        }
    }
}

/// The list's face — the masthead-sheet grammar (the references sheet's
/// shape) with a LAZY row stack (P3: this list can be as long as the
/// note). A row's tap hands its block to `onJump` (the view dismisses
/// and the editor scrolls + places the caret — the VM's `jumpToBlock`).
struct MobileBlockListSheet: View {
    @Bindable var model: MobileBlockListModel
    let tokens: VoiceTokens
    let onJump: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("Blocks"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if model.rows.isEmpty {
                        Text(tokens.chromeLabel(MobileBlockListModel.emptyNote))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ForEach(model.rows, id: \.placementID) { row in
                        Button {
                            onJump(row.blockID)
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                // The handle derives IN the row body —
                                // lazy rows derive only what they show.
                                Text(MobileBlockListModel.handle(row))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.ink)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                                if row.hasFan {
                                    Text("⑂")
                                        .font(tokens.small)
                                        .foregroundStyle(tokens.muted)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(MobileBlockListModel.handle(row))
                    }
                    if let status = model.status {
                        Text(status)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        // The held observation (D2): the open list re-reads on every
        // delivery — a remote divide landing mid-read appears; the task
        // cancels the observation at dismissal.
        .task { await model.start() }
    }
}
