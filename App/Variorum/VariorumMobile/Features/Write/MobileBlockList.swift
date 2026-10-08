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

    // MARK: - Multi-select (round 2, batch 7 — PR20, the 13e E2 twin)

    /// True while the list is picking blocks instead of jumping to them.
    private(set) var isSelecting = false
    /// The picks — ids only (`MobileBlockSelection`; P1).
    private(set) var selection = MobileBlockSelection()
    /// The bulk delete's confirm, presented by the sheet.
    var deleteConfirmPresented = false

    /// **THE ENTRY DOOR IS A CHROME BUTTON, and the call is recorded.** The
    /// brief offered a block ⋯ row or a long-press; a long-press is
    /// **undrivable in process** (`MobileSurfaceDriver`'s measured finding —
    /// a `.contextMenu` row's tree comes back empty), which alone decides it
    /// against a destructive gesture's only entrance. And a ⋯ row would be a
    /// SECOND door onto this surface, one inch from the first — the shape
    /// batch 9 retired when it removed `Takes…` from the block ⋯ (*"a second
    /// door onto one surface"*). This sheet's subject already IS this note's
    /// blocks; the door belongs in its chrome. **PROVISIONAL.**
    func enterSelection() {
        guard !isSelecting else { return }
        isSelecting = true
        selection.clear()
    }

    /// Leaves picking mode and drops the picks. A selection that outlived
    /// its surface would offer acts on blocks she is no longer looking at.
    func exitSelection() {
        isSelecting = false
        selection.clear()
    }

    func toggle(_ blockID: String) {
        guard isSelecting else { return }
        selection.toggle(blockID)
    }

    /// The picked blocks in the NOTE's order — what the act addresses.
    var pickedInOrder: [String] { selection.inOrder(rows.map(\.blockID)) }

    /// Adopts a fresh listing and PRUNES picks it no longer holds (the Mac's
    /// own rule: a selection that outlives its blocks offers acts on ghosts,
    /// and the banner's count would be a lie). The held observation delivers
    /// here, so a remote delete or a sync arrival reaches the picks.
    private func adopt(_ value: [Queries.TOCRow]) {
        rows = value
        status = nil
        if isSelecting { selection.prune(to: Set(value.map(\.blockID))) }
    }

    func refresh() async {
        do {
            let postID = postID
            let value = try await session.database.read { db in
                try Queries.blockTOC(db, post: postID)
            }
            adopt(value)
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
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = String(describing: error)
        }
    }
}

/// **WHAT THE BLOCK SELECTION SAYS** (round 2, batch 7 — PR20).
///
/// ONE home, for the Mac `BlockSelectionCopy`'s own reason: the banner, the
/// act's verb and the confirm are one promise, and a promise written twice
/// is one no test can keep. **A recorded FORK of that enum** — it lives in
/// the Mac target this batch is fenced out of (#94) — and, like every fork
/// this app carries, it differs only where the phone's truth differs:
///
/// · the Mac's banner TEACHES ⌘⇧-click ("pick a whole run"); this phone has
///   no chord to teach, so the banner states the count and stops.
/// · the Mac's receipt ends "⌥⌘Z brings them all back at once"; the phone's
///   undo road is the receipt's own Undo BUTTON — so the DELETE itself is
///   composed from `MobileStructuralController`, whose receipt already says
///   the true thing (`blocksDeletedStatus` + `action: .undo`) and is not
///   rewritten here.
nonisolated enum MobileBlockSelectionCopy {
    static let selectTitle = "Select"
    static let doneSelectingTitle = "Done"
    /// The VoiceOver names. They are DISTINCT from the rendered words on
    /// purpose: while picking, this button and the sheet's dismiss both read
    /// "Done", and two identically-named doors in one tree is the shape a
    /// walk cannot tell apart.
    static let selectLabel = "Select blocks"
    static let doneSelectingLabel = "Done picking"

    /// The banner's line — the count, and nothing it cannot deliver.
    static func bannerLabel(picked: Int) -> String {
        picked == 0
            ? "Tap blocks to pick them."
            : (picked == 1 ? "1 block picked" : "\(picked) blocks picked")
    }

    /// The act's verb. The ellipsis is load-bearing — it promises the
    /// confirm below.
    static func deleteVerb(picked: Int) -> String {
        picked <= 1 ? "Delete Block…" : "Delete \(picked) Blocks…"
    }

    static let confirmActionTitle = "Delete"

    /// **A CONFIRM, and it is IN-DOCTRINE rather than a divergence from
    /// #59(i).** The Mac ruled NO prompt for its multi-delete; her R13
    /// ruling on THIS phone drew the line that governs here, and drew it
    /// explicitly: *the ⋯ menu's single-block door still asks, because that
    /// is a menu row and asking there costs a tap she already spent; this
    /// road is a keystroke.* The Mac's road IS a keystroke (⌘-click then
    /// ⌫ in the editor). **This road is a deliberate button press in a
    /// sheet** — the menu-row class, where this phone already confirms
    /// (`MobileBlockMenuController.confirmDelete`). Same line, other side.
    ///
    /// The detail composes the single-block confirm's own promise, so the
    /// two doors cannot promise different roads back.
    /// `@MainActor` because it COMPOSES the tray's road phrase rather than
    /// re-typing it, and `MobileNoteTrayModel` is main-actor isolated —
    /// which is the right trade: the two delete confirms promising different
    /// roads back is the drift this composition exists to prevent.
    @MainActor
    static func confirmDetail(picked: Int) -> String {
        let subject = picked == 1 ? "The block leaves" : "\(picked) blocks leave"
        return "\(subject) this note, with their takes. "
            + "\(MobileNoteTrayModel.putBackRoadPhrase.prefix(1).uppercased())"
            + "\(MobileNoteTrayModel.putBackRoadPhrase.dropFirst()) for "
            + "\(TrashWindow.days) days; Undo is on the receipt afterwards, "
            + "and in the note's ⋯."
    }

    static func confirmTitle(picked: Int) -> String {
        picked <= 1 ? "Delete Block" : "Delete \(picked) Blocks"
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
    /// **PR20's act, injected by the HOST** — `MobileWriteView` composes the
    /// block list and the structural controller; a call from here into
    /// another feature would be the feature-to-feature road CLAUDE.md
    /// forbids. nil = a host with no delete road, and then the Select door
    /// does not render at all (P-2).
    ///
    /// **It ANSWERS whether the act landed** (the fix wave, MINOR 3): the
    /// sheet's success/refusal roads differ (#59(k) keeps her picks on a
    /// refusal), and reading that difference back out of a re-read listing
    /// made it depend on the read succeeding. The act knows; it says.
    var onDeleteBlocks: (([String]) async -> Bool)?
    let onJump: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var segment: MobileBlocksSegment = .inTheNote

    init(
        model: MobileBlockListModel, tokens: VoiceTokens,
        tray: MobileNoteTrayModel? = nil,
        onDeleteBlocks: (([String]) async -> Bool)? = nil,
        onJump: @escaping (String) -> Void
    ) {
        self.model = model
        self.tokens = tokens
        self.tray = tray
        self.onDeleteBlocks = onDeleteBlocks
        self.onJump = onJump
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("Blocks"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                // PR20's entry door: chrome, and only where there is a
                // delete road to reach and blocks to pick (P-2). It swaps
                // to "Done" while picking, which is also how she leaves.
                // `|| model.isSelecting` is the missing-exit half (the fix
                // wave, MINOR 1's rider): if every row leaves the note WHILE
                // she is picking — a remote delete of the whole note's
                // blocks — the door she leaves picking mode by must not
                // leave with them.
                if onDeleteBlocks != nil, segment == .inTheNote,
                   !model.rows.isEmpty || model.isSelecting {
                    Button(tokens.chromeLabel(
                        model.isSelecting
                            ? MobileBlockSelectionCopy.doneSelectingTitle
                            : MobileBlockSelectionCopy.selectTitle)
                    ) {
                        if model.isSelecting { model.exitSelection() }
                        else { model.enterSelection() }
                    }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    // An EXPLICIT label, because while picking this button
                    // and the sheet's dismiss both render the word "Done".
                    // The dismiss keeps its implicit label untouched — a
                    // shipped door's VoiceOver name is not this batch's to
                    // move (and pins ride it).
                    .accessibilityLabel(
                        model.isSelecting
                            ? MobileBlockSelectionCopy.doneSelectingLabel
                            : MobileBlockSelectionCopy.selectLabel)
                }
                // **THE SHEET'S OWN DISMISS LEAVES PICKING MODE TOO** (the
                // fix wave, MINOR 1). `exitSelection`'s doc states the rule
                // — *"a selection that outlived its surface would offer acts
                // on blocks she is no longer looking at"* — and this is the
                // sheet's PRIMARY exit; without it, picking survived the
                // dismissal and the sheet reopened armed, with the picks and
                // the delete verb still on the banner.
                Button(tokens.chromeLabel("Done")) {
                    model.exitSelection()
                    dismiss()
                }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            if tray != nil { segmentStrip }
            if model.isSelecting, segment == .inTheNote { selectionBanner }
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
        // …and SWIPE-TO-DISMISS is the same exit (the fix wave, MINOR 1).
        // The Done button above covers the tapped road; this covers the
        // one the system performs, so the rule holds however she leaves.
        .onDisappear { model.exitSelection() }
        // PR20's confirm. Its PRESENTATION is pinnable end to end (a real
        // `UIAlertController` in the window); its EFFECT is driven through
        // the model, because a `UIAlertController`'s own buttons measurably
        // do not activate in process — the harness's recorded split.
        .alert(
            MobileBlockSelectionCopy.confirmTitle(picked: model.selection.count),
            isPresented: $model.deleteConfirmPresented
        ) {
            Button(MobileBlockSelectionCopy.confirmActionTitle, role: .destructive) {
                Task { await deletePicked() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(MobileBlockSelectionCopy.confirmDetail(picked: model.selection.count))
        }
    }

    /// The act. **It composes `MobileStructuralController.deleteWholeBlockRun`
    /// through the host** (`onDeleteBlocks`) rather than opening a second
    /// delete road: that door already carries the ONE compound undo entry
    /// (`UndoStack.withCompound(label: "Delete Blocks")`), the flight latch,
    /// the flush-first contract, the caret landing, the stranded-originals
    /// note and the receipt with its Undo action. A second road would be a
    /// second promise.
    ///
    /// The picks are read **in the NOTE's order** and the selection is left
    /// alone until the act returns — a refusal KEEPS her picks (#59(k)),
    /// because there is nothing to re-tap; a success finds them pruned away
    /// by the held observation's own delivery.
    private func deletePicked() async {
        guard let onDeleteBlocks else { return }
        let picked = model.pickedInOrder
        guard !picked.isEmpty else { return }
        let landed = await onDeleteBlocks(picked)
        // A DETERMINISTIC prune, not a hope: the held observation's delivery
        // is asynchronous, so the listing is re-read through the one door
        // (the takes browser's own "verbs end in a fresh read" discipline —
        // correct with or without the observation running, and its delivery
        // is then an echo).
        await model.refresh()
        // **THE OUTCOME DECIDES, NOT THE RE-READ** (the fix wave, MINOR 3).
        // This used to infer "landed" from an emptied selection, which made
        // the discrimination ride on `refresh()` reaching `adopt` — and
        // `refresh()` SWALLOWS a read failure, leaving the rows (and so the
        // picks) stale. A read that threw right after a successful delete
        // therefore made the app read its own success as a refusal and keep
        // `Delete N Blocks…` armed over blocks that were already gone. The
        // act's own answer cannot be stale. A refusal still KEEPS her picks
        // — there is nothing to re-tap (#59(k)).
        if landed { model.exitSelection() }
    }

    /// **PR20's banner.** It states the count and offers the one act; it
    /// renders only while picking, so at rest the sheet is exactly as calm
    /// as the one that shipped (#59(l)'s rule, which is batch 2's applied).
    ///
    /// The delete door is a plain `Button` — drivable — and it is absent
    /// with nothing picked (P-2: never an inert act).
    private var selectionBanner: some View {
        HStack(spacing: 14) {
            Text(tokens.chromeLabel(
                MobileBlockSelectionCopy.bannerLabel(picked: model.selection.count)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer(minLength: 0)
            if !model.selection.isEmpty {
                Button(tokens.chromeLabel(
                    MobileBlockSelectionCopy.deleteVerb(picked: model.selection.count))
                ) {
                    model.deleteConfirmPresented = true
                }
                .font(tokens.small)
                .foregroundStyle(tokens.alarm)
                .buttonStyle(.plain)
                .accessibilityLabel(
                    MobileBlockSelectionCopy.deleteVerb(picked: model.selection.count))
            }
        }
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
                    let picked = model.selection.contains(row.blockID)
                    Button {
                        // PR20: while picking, a tap TOGGLES instead of
                        // jumping. One row, two meanings — and the mode is
                        // visible in the chrome, the banner and the row's
                        // own mark, so which meaning is in force is never
                        // invisible state.
                        if model.isSelecting { model.toggle(row.blockID) }
                        else { onJump(row.blockID) }
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            if model.isSelecting {
                                // The pick's mark. The Mac's wash-plus-border
                                // (#59(e)) is a full-width editor band; a
                                // list row's phone-native equivalent is a
                                // leading mark plus the same soft wash, and
                                // the mark is what a walk can read.
                                Text(picked ? "◉" : "○")
                                    .font(tokens.small)
                                    .foregroundStyle(picked ? tokens.accent : tokens.faint)
                            }
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
                        .padding(.vertical, model.isSelecting ? 2 : 0)
                        .background(picked ? tokens.accent.opacity(0.12) : .clear)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(MobileBlockListModel.handle(row))
                    .accessibilityAddTraits(picked ? .isSelected : [])
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
