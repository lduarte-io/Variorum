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
//  ── THE SHEET GREW SEGMENTS (round 2, batch 6b — THE TRAY'S DOOR) ────────
//  `in the note | archived | leaving` — **one subject in three states**, and
//  it is the design record's own candidate for where the per-note tray's
//  door should sit (`mobile-archive-trash-design/README.md` §7, Q8, which
//  flagged that *"batch 6b may place this door before she reads the page; if
//  it does, this question is already answered and that answer stands"*).
//
//  **Why here and not a row in the note ⋯** (the recorded fallback): the
//  subject of all three segments is THIS NOTE'S BLOCKS. The chip already
//  says "blocks"; a tray reached from the ⋯ would put one subject behind two
//  unrelated doors, and the ⋯ is the note-ACTS menu (Save a Version ·
//  Versions… · Undo · Redo · Delete Note…) — a listing is not an act. The
//  segments also make the five-places map legible in one glance: a block she
//  cannot find is in the note, kept aside, or leaving.
//
//  **PROVISIONAL, logged for her sitting** — the answer Q8 says will stand
//  if this batch places the door, recorded so it is a decision and not an
//  accident.
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

/// **THE SHEET'S THREE STATES OF ONE SUBJECT** (batch 6b — the Q8 door).
/// Declared once, so the segment's word, the pin's handle and the sentence
/// that POINTS at the segment (`MobileNoteTrayModel.purgeRoadPhrase`, the
/// Block History explainer's second half) can never drift apart.
///
/// The words are short forms on purpose: the tray's full section headers —
/// `Archived — kept, no clock` and `Leaving — on the 30-day clock`, the
/// SHARED sentences — render inside the segment they name, where the promise
/// belongs. A segment strip is a place to stand, not a place to explain.
nonisolated enum MobileBlocksSegment: String, CaseIterable, Identifiable {
    case inTheNote
    case archived
    case leaving

    var id: String { rawValue }

    var word: String {
        switch self {
        case .inTheNote: return "in the note"
        case .archived: return "archived"
        case .leaving: return "leaving"
        }
    }
}

/// The list's face — the masthead-sheet grammar (the references sheet's
/// shape) with a LAZY row stack (P3: this list can be as long as the
/// note). A row's tap hands its block to `onJump` (the view dismisses
/// and the editor scrolls + places the caret — the VM's `jumpToBlock`).
///
/// **Since batch 6b it carries the per-note TRAY** in two further segments
/// (see the header). `tray` is optional so every harness that mounts the
/// plain list rides unmodified and so a host with no tray to show renders
/// exactly the sheet that shipped — the segment strip appears only when
/// there is somewhere for it to go (P-2).
struct MobileBlockListSheet: View {
    @Bindable var model: MobileBlockListModel
    let tokens: VoiceTokens
    /// The per-note tray's model (batch 6b). nil = the pre-6b sheet.
    var tray: MobileNoteTrayModel?
    let onJump: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var segment: MobileBlocksSegment = .inTheNote

    init(
        model: MobileBlockListModel, tokens: VoiceTokens,
        tray: MobileNoteTrayModel? = nil, onJump: @escaping (String) -> Void
    ) {
        self.model = model
        self.tokens = tokens
        self.tray = tray
        self.onJump = onJump
    }

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
            if tray != nil { segmentStrip }
            if let tray, segment != .inTheNote {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        MobileNoteTraySection(
                            model: tray, tokens: tokens,
                            section: segment == .archived ? .archived : .leaving)
                    }
                }
            } else {
                inTheNoteList
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        // The held observation (D2): the open list re-reads on every
        // delivery — a remote divide landing mid-read appears; the task
        // cancels the observation at dismissal.
        .task { await model.start() }
    }

    /// Plain doors in a row — the Library/Trash filter row's grammar, never a
    /// `Menu` or a `Picker`: a door a pin can drive (§15's trap (b), and the
    /// measured reason — a `Menu`'s rows come back as an EMPTY accessibility
    /// tree).
    private var segmentStrip: some View {
        HStack(spacing: 16) {
            ForEach(MobileBlocksSegment.allCases) { option in
                Button {
                    segment = option
                } label: {
                    Text(tokens.chromeLabel(option.word))
                        .font(tokens.small)
                        .foregroundStyle(segment == option ? tokens.ink : tokens.faint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(option.word)
                .accessibilityAddTraits(segment == option ? .isSelected : [])
            }
            Spacer(minLength: 0)
        }
    }

    private var inTheNoteList: some View {
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
}
