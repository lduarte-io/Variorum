//
//  BlockHistoryPane.swift
//  Variorum (Mac)
//
//  **THE POST-13L POLISH ROUND, BATCH 4 — LEDGER ROW 17 (G2): THE ONE BLOCK
//  HISTORY PANE.**
//
//  Her second-sitting ruling, verbatim: *"I know I just ruled that history
//  should go in the block menu, but I think I'm changing my mind and it should
//  be in the bottom chrome — my reasoning is that history is quite similar to
//  commit, it's the natural pair to commit."* So the door sits beside Commit
//  on BOTH bars (write a moment · see the moments — the bar becomes the
//  block's time controls) and opens THIS: one cohesive side panel with four
//  regions, in order —
//
//    1. **Savepoint runs** — ALL of the block's live takes, sectioned, the
//       take you're in expanded (her ruling). Restore per row.
//    2. **Archived takes** — set aside, never gone, with Unarchive.
//    3. **Deleted takes** — on the 30-day clock, with Put back. **NO purge
//       door here** (row 21's letter: Delete Now lives on TRASH SURFACES —
//       the global Trash and the note's leaving section — never here).
//    4. **Came from** — the lineage region: ALL of a merge's originals (the
//       13l walk's P-3 fix — the old door showed one of two), each with its
//       text and a ONE-BUTTON way back into the note.
//
//  ── WHAT THIS ABSORBS, AND WHY IT IS ONE SURFACE AND NOT FOUR ────────────
//  Three faces used to answer parts of "what has this block been?" — Write's
//  inline `CommitHistoryView` strip, the Takes bar's history sheet, and the
//  J3 lineage peek with its own nested tray sheet — and none of them answered
//  all of it. Her F2 report is the proof it mattered: she FOUND the deleted
//  take, in the History face, and still could not tell whose history she was
//  reading (*"it's unclear that history is under Note, that makes it seem
//  like the Note's history"*). One pane, one door, one name. Her stated
//  teaching intent binds the design: *"the 'Block history' pane will be a
//  strong memory and the expectations are clear."*
//
//  ── READ-CHEAP TIER ONLY (P3) ────────────────────────────────────────────
//  Every take in here is a `Text`. Nothing in a history pane is ever a live
//  editor — this is a look at what a block has been, not a place to write.
//
//  ── THE HELD OBSERVATION (adjudication 2, RECORD-ONLY) ───────────────────
//  As a side panel this can stand open while she types, and its projection
//  reads `variant` and `commit_point` — so GRDB re-runs it when a buffer is
//  autosaved. P1 is not breached: the re-read's cost is ∝ this block's own
//  fan and savepoint history, never the note's length or the corpus. What
//  changed is the FREQUENCY, which is the tray panel's own class one surface
//  over; the architect's adjudication is record-only for both, and no
//  debounce machinery is built here.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **THE MAC'S OWN WORDS FOR THE BLOCK HISTORY DOOR.**
///
/// The vocabulary itself moved to `Shared/BlockHistoryFace.swift` at mobile
/// round 2 batch 6a, when the phone grew its own Block History face. What
/// stayed is exactly what names a MAC door or a MAC chord — a shared home is
/// the wrong place for a sentence that points at one platform's bottom bar
/// (MobileSoul §4.4's no-redirect rule, read from the other side).
nonisolated extension BlockHistoryPath {
    /// The bar's door label. Lowercased by the voice like its neighbour
    /// ("commit ⌘S"); the pairing IS the teaching moment (her G4 chapter:
    /// write a moment · see the moments).
    static let doorLabel = "history"

    /// How copy elsewhere points at the door.
    static let doorPhrase = "the history door in the note's bottom bar"

    static var cameFromPathWithDoor: String { "\(cameFromPath) (\(doorPhrase))" }

    static let noSavepoints = "No saved moments yet \u{2014} \u{2318}S saves one."

    /// **THE CURRENT-BLOCK JUMP** (the post-13l polish round, ledger row 33 —
    /// her 2026-08-25 refinement on the ratified request scoping): *"i think
    /// the history pane staying on the block you asked about is fine, but if
    /// you've changed blocks there should be a small button or something to
    /// show current block's history, so you don't have to close it and reopen
    /// it."*
    ///
    /// The pane stays scoped to the block the REQUEST named — following the
    /// caret would mean a panel that jumps while she types — so the door is
    /// the way out of that scoping, and it renders ONLY while the two really
    /// differ (a button that could not move the pane is a door that cannot
    /// act, which P-2 says is not rendered at all).
    ///
    /// **Mac-only by construction**: the phone's Block History is a sheet
    /// that covers the page and stands its editor down, so its caret cannot
    /// move while the face is open — there is no jump to offer.
    static let jumpVerb = "Show the block you're in"
    static let jumpHelp =
        "Your cursor has moved to a different block — this points the panel at "
        + "that block's history instead, without closing it"

    /// **Row 28 (the Act 10 correction round): the savepoints region's one
    /// meaning line** — her ask nearly verbatim ("Savepoints: this take's
    /// saved moments"); the other three regions already carried theirs.
    static let savepointsExplainer =
        "Each take's saved moments \u{2014} Restore loads one back into its buffer."
}

/// A surface's pending request to open the pane — the `TrayRequest` shape,
/// and for its reason: the doors that raise it live on view models and bars
/// while the panel lives in the post detail's inspector.
///
/// It carries the FOCUSED take because her ruling is that all the block's
/// takes are sectioned with *"the focused take's expanded"* — a pane that
/// forgot which take she was in would have to guess, and guessing is what
/// the request exists to prevent.
nonisolated struct BlockHistoryRequest: Identifiable, Hashable, Sendable {
    let postID: String
    let blockID: String
    var focusedVariantID: String?
    var id: String { "\(postID)#\(blockID)#\(focusedVariantID ?? "")" }
}

/// **WHERE THE WRITING SURFACE'S CARET IS** (ledger row 33) — a FACT the
/// mounted surface reports, never a request.
///
/// It is the `BlockHistoryRequest`'s shape without being one, deliberately:
/// the two are different kinds of thing (one is "open this", the other is
/// "this is where I am"), and a fact that could be mistaken for a request
/// would invite a surface to open a panel by reporting a caret move.
///
/// Reported only when the block CHANGES, which is what keeps it cheap: a
/// caret walking within one paragraph writes nothing, so nothing observing it
/// re-renders at keystroke rate. **`utf16Offset` is the exception, and it is
/// deliberately not a signal** (the 2026-09-06 use-report round, 17o batch b —
/// her ruling U-20): the caret's place INSIDE the block is data a landing
/// READS at the moment it lands, never something a view watches, so the
/// router keeps it beside the observed identity rather than in it
/// (`CommandRouter.focusedBlock` has the whole argument).
nonisolated struct FocusedBlock: Hashable, Sendable {
    let postID: String
    let blockID: String
    var variantID: String?
    /// **Where the caret was inside the block, UTF-16** — nil means UNKNOWN
    /// (a surface that holds no caret: Blocks' row, the outline's card, an
    /// old two-field memory), which every landing spells "the block's start".
    /// Zero is a real place, not unknown. `LandingTarget.utf16Offset` is the
    /// same idea one door over — the name is shared on purpose.
    var utf16Offset: Int?
}

@MainActor
@Observable
final class BlockHistoryModel {
    @ObservationIgnored private let session: AppSession
    let postID: String
    let blockID: String
    let focusedVariantID: String?

    private(set) var history = Queries.BlockHistory()
    private(set) var loaded = false

    /// **A receipt is not a refusal** — the tray's own split (ledger row 6),
    /// classed where the message is produced and never guessed from its text.
    private(set) var status: TrayViewModel.Status?

    /// The pre-split confirm (AppSpec §9's documented behaviour): a commit
    /// older than the newest live divide/extract on this block still holds
    /// the pre-split text, so restoring it resurrects both halves.
    var pendingRestore: PendingRestore?

    nonisolated struct PendingRestore: Identifiable, Equatable, Sendable {
        let variantID: String
        let commit: CommitPoint
        var id: String { commit.id }
    }

    init(
        session: AppSession, postID: String, blockID: String,
        focusedVariantID: String? = nil
    ) {
        self.session = session
        self.postID = postID
        self.blockID = blockID
        self.focusedVariantID = focusedVariantID
    }

    /// Held only while the pane is on screen — the view's `.task` owns the
    /// lifetime, so the observation of `variant`/`commit_point` never stands
    /// over a typing burst on a pane nobody is looking at.
    func start() async {
        do {
            for try await value in session.database.observeBlockHistory(
                blockID, now: session.now
            ) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(String(describing: error))
        }
    }

    /// Internal so tests drive the pane deterministically (the
    /// `TrayViewModel.adopt` seam).
    func adopt(_ value: Queries.BlockHistory) {
        history = value
        loaded = true
    }

    var isEmpty: Bool { history.isEmpty }

    /// Which savepoint run this pane opens with (her ruling: every take is
    /// sectioned, the one she is in is expanded).
    ///
    /// **The rule itself moved to `Shared/BlockHistoryExpansion` at mobile
    /// round 2 batch 6a** — a phone that opened a different take than the Mac
    /// would be answering one ruling twice. This is the forwarder, kept so
    /// every shipped pin rides unmodified (the 3C parity pattern).
    static func initiallyExpanded(
        _ history: Queries.BlockHistory, focused: String?
    ) -> Set<String> {
        BlockHistoryExpansion.initiallyExpanded(history, focused: focused)
    }

    /// **Where the jump door would go, or nil** (ledger row 33). A pure rule,
    /// so the DECISION is pinned without rendering anything: the caret's block
    /// must be in the SAME note as this pane and a DIFFERENT block from the one
    /// it is showing. Anything else — an unknown caret, a caret in another
    /// note's pane, a caret in the very block on screen — is no jump, and the
    /// door does not render (P-2).
    ///
    /// It returns a ready-made request rather than an id, so the take she is
    /// standing in rides along and her *"the focused take's expanded"* ruling
    /// survives the jump.
    static func jumpTarget(
        _ focused: FocusedBlock?, postID: String, blockID: String
    ) -> BlockHistoryRequest? {
        guard let focused, focused.postID == postID, focused.blockID != blockID
        else { return nil }
        return BlockHistoryRequest(
            postID: postID, blockID: focused.blockID,
            focusedVariantID: focused.variantID)
    }

    func predatesSplit(_ commit: CommitPoint) -> Bool {
        CommitRules.predatesSplit(
            commitDate: commit.createdAt, splitDates: history.splitDates)
    }

    // MARK: - Region 1: restore a savepoint

    /// Restore a saved moment into its take's buffer.
    ///
    /// **It flushes the post's pending buffer FIRST**, and that is not
    /// optional: the editor debounces autosaves, so a restore landing while a
    /// keystroke is still pending would be overwritten by that flush moments
    /// later. `EditorViewModel.restore` has always done this for the strip
    /// this pane replaces; the pane reaches the same coordinator through the
    /// session's existing-only road (`flushExistingAutosave`), which never
    /// mints one for a post no surface has opened.
    func restore(_ commit: CommitPoint, of variantID: String, confirmed: Bool = false)
        async
    {
        if !confirmed, predatesSplit(commit) {
            pendingRestore = PendingRestore(variantID: variantID, commit: commit)
            return
        }
        pendingRestore = nil
        status = nil
        await session.flushExistingAutosave(forPost: postID)
        do {
            try await session.runner.run { ops in
                try ops.restoreCommit(variantID, commitID: commit.id)
            }
            status = .receipt(BlockHistoryCopy.restoredSavepoint)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    func confirmPendingRestore(_ pending: PendingRestore) async {
        await restore(pending.commit, of: pending.variantID, confirmed: true)
    }

    // MARK: - Region 2: unarchive

    func unarchive(_ variantID: String) async {
        status = nil
        do {
            try await session.runner.run { ops in try ops.unarchiveVariant(variantID) }
            status = .receipt(BlockHistoryCopy.unarchivedTake)
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 3: put a deleted take back

    /// `restoreVariant` — the recovery-door class (no undo entry: the door IS
    /// the recovery). The receipt reads the op's OWN answer, because the
    /// restore is an exact flip (#68(b)) and a take archived when it was
    /// deleted comes back archived.
    func putBackTake(_ variantID: String) async {
        status = nil
        do {
            let restored = try await session.runner.run { ops in
                try ops.restoreVariant(variantID)
            }
            status = .receipt(BlockPastCopy.restored(restored))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    // MARK: - Region 4: bring an original back

    /// The one-button `placeBlock` road her fourth sitting asked for, through
    /// the ONE shared composition the tray's own door calls — so two doors
    /// onto one act cannot drift on where the block lands or what the receipt
    /// says.
    func bringBack(_ originBlockID: String) async {
        status = nil
        do {
            status = .receipt(try await PreservedOriginPutBack.run(
                session: session, postID: postID, blockID: originBlockID))
        } catch let error as OperationError {
            status = .refusal(TrayRefusalCopy.message(for: error))
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }
}

/// **THE MAC'S DELETED-REGION EXPLAINER.** The rest of `BlockHistoryCopy`
/// moved to `Shared/BlockHistoryFace.swift` at batch 6a; this half stayed
/// because it names *This Note's Tray*, which is a Mac surface (the phone's
/// note-level trash section is its own batch).
nonisolated extension BlockHistoryCopy {
    /// The deleted region's own explainer: **no purge door here**, and the
    /// honest place it does live (row 21's letter).
    static let deletedExplainer = deletedRegionExplainer(
        purgeRoad: "open \(TrayPath.menuLabel) and use its leaving section")
}

/// **THE BLOCK HISTORY PANE.** One occupant of the post detail's inspector
/// column (the seam batch 3 opened), and the same view the bars present as a
/// sheet where no inspector exists (the book spread's inline form, the scraps
/// hosts) — one component, so the two hosts cannot tell different stories
/// about one block.
struct BlockHistoryPane: View {
    /// The registry ids this pane renders INLINE (P-1's `.surface` door; the
    /// walk unions every renderer). Put back and Unarchive are acts pointed
    /// at directly on their own rows. **`.deleteNow` is deliberately absent**
    /// — row 21's letter: this is not a trash surface.
    static let surfaceCapabilities: [CapabilityID] = [.restoreTake, .unarchiveTake]

    let session: AppSession
    /// How this pane closes. In a sheet the environment's `dismiss` answers;
    /// in the inspector the host hands the closing act down (the `TrayPanel`
    /// precedent, same reason).
    var onClose: (() -> Void)?
    /// Raised by the came-from region's second door. The HOST decides where
    /// the tray opens — the inspector swaps panels, a sheet host swaps
    /// sheets — which is what dissolves the peek's nested sheet
    /// (adjudication 3) instead of moving it.
    var onOpenTray: ((String) -> Void)?
    /// **Where the current-block jump lands** (ledger row 33). The HOST
    /// re-points its own occupant — the inspector swaps the panel's case, a
    /// sheet host swaps its pending request — for `onOpenTray`'s reason: the
    /// pane is scoped by its request, so re-scoping is the host's act and not
    /// a second lifetime inside this view.
    var onJump: ((BlockHistoryRequest) -> Void)?
    @State private var model: BlockHistoryModel
    /// Which take's savepoint run is open. Session UI state, like every other
    /// expansion in the app; seeded from her ruling by
    /// `initiallyExpanded` on the first loaded snapshot.
    @State private var expandedTakes: Set<String> = []
    @State private var seededExpansion = false
    /// Which quiet savepoint runs are open (13j J11's collapse, per take).
    @State private var expandedRuns: Set<String> = []
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, request: BlockHistoryRequest,
        onClose: (() -> Void)? = nil, onOpenTray: ((String) -> Void)? = nil,
        onJump: ((BlockHistoryRequest) -> Void)? = nil,
        model: BlockHistoryModel? = nil
    ) {
        self.session = session
        self.onClose = onClose
        self.onOpenTray = onOpenTray
        self.onJump = onJump
        _model = State(initialValue: model
            ?? BlockHistoryModel(
                session: session, postID: request.postID, blockID: request.blockID,
                focusedVariantID: request.focusedVariantID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(BlockHistoryPath.name))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer()
                Button("Close") { close() }
            }
            // Row 89: the pane's explainer wraps whole, never truncates.
            // (Ladder R1-6 asked whether this unlimited `fixedSize` text in
            // non-scrolling chrome is the b6dae25 wedged-window class; it is
            // NOT — the pane pins `minWidth: 300` below, so the window's
            // near-zero-width probe measures it at 300 wide: 280 pt with the
            // text here and 280 pt with it inside the scroll, pinned in
            // `ChromeMinHeightTests`. Hollow; left where it reads.)
            Text(tokens.chromeLabel(BlockHistoryPath.explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            // Ledger row 33 — the current-block jump. It renders only while
            // the caret really is somewhere else (the pure rule decides), and
            // only where a host can act on it, so pressing it always moves
            // the pane (P-2).
            if let jump = jumpTarget, let onJump {
                Button(tokens.chromeLabel(BlockHistoryPath.jumpVerb)) { onJump(jump) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .controlSize(.small)
                    .help(BlockHistoryPath.jumpHelp)
            }
            if let status = model.status {
                Text(status.text)
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            // Rows 28 + 65 (the Act 10 correction round): the pane was a
            // `List`, and a plain macOS List measures section headers at a
            // fixed height — so the taller region headers (a title AND a
            // meaning line) drew as struck-through slivers, the EXACT
            // mechanism Act 10 item 1 traced and killed in the tray one file
            // over. Same rebuild, same reason: a ScrollView of ordinary
            // stacked views cannot clip a header by measuring it elsewhere,
            // and the four regions now READ as sections — a CalmSectionHeader
            // with air and one meaning line each (the calm-card grammar).
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    savepointRegion
                    archivedRegion
                    deletedRegion
                    cameFromRegion
                }
                .padding(.bottom, 8)
            }
        }
        .padding(12)
        .frame(minWidth: 300, minHeight: 280)
        .background(tokens.surface)
        .task { await model.start() }
        .onChange(of: model.loaded) { _, loaded in
            guard loaded, !seededExpansion else { return }
            seededExpansion = true
            expandedTakes = BlockHistoryModel.initiallyExpanded(
                model.history, focused: model.focusedVariantID)
        }
        .alert(
            BlockHistoryCopy.predatesSplitTitle,
            isPresented: Binding(
                get: { model.pendingRestore != nil },
                set: { if !$0 { model.pendingRestore = nil } }),
            presenting: model.pendingRestore
        ) { pending in
            Button(BlockHistoryCopy.restoreAnyway, role: .destructive) {
                Task { await model.confirmPendingRestore(pending) }
            }
            Button("Cancel", role: .cancel) { model.pendingRestore = nil }
        } message: { _ in
            Text(BlockHistoryCopy.predatesSplitDetail)
        }
    }

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    /// Reading the router's observable fact HERE is what makes the door appear
    /// the moment she clicks into another block: the dependency is registered
    /// by `body`, and the fact only changes when the caret changes BLOCKS.
    private var jumpTarget: BlockHistoryRequest? {
        BlockHistoryModel.jumpTarget(
            session.commandRouter.focusedBlock,
            postID: model.postID, blockID: model.blockID)
    }

    // MARK: - Region 1 — every live take's saved moments

    @ViewBuilder private var savepointRegion: some View {
        // Row 28: a real section — a header with air and one meaning line.
        CalmSectionHeader(
            tokens: tokens, title: BlockHistoryPath.savepointsSection,
            detail: BlockHistoryPath.savepointsExplainer)
        if model.loaded, model.history.activeTakes.isEmpty {
            quiet(BlockHistoryPath.nothingHere)
        }
        let takes = model.history.activeTakes
        ForEach(Array(takes.enumerated()), id: \.element.id) { index, take in
            takeRun(take, ordinal: index + 1, of: takes.count)
        }
    }

    @ViewBuilder private func takeRun(
        _ take: Variant, ordinal: Int, of total: Int
    ) -> some View {
        let commits = model.history.savepoints[take.id] ?? []
        let open = expandedTakes.contains(take.id)
        // Row 64's generous-target rule, here too: the WHOLE line toggles the
        // run (the DisclosureGroup it replaces toggled only on its chevron).
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if open { expandedTakes.remove(take.id) }
                else { expandedTakes.insert(take.id) }
            }
        } label: {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(open ? "\u{25BE}" : "\u{25B8}"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Text(tokens.chromeLabel(
                    BlockHistoryPath.takeHeading(take, ordinal: ordinal, of: total)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                if take.id == model.focusedVariantID {
                    Text(tokens.chromeLabel(BlockHistoryPath.focusedMark))
                        .font(tokens.small)
                        .foregroundStyle(tokens.chosen)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(tokens.chromeLabel("\(commits.count)"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        if open {
            if commits.isEmpty {
                quiet(BlockHistoryPath.noSavepoints)
            }
            ForEach(SavepointRuns.rows(
                commits, isQuiet: { $0.kind == .auto }, id: { $0.id })
            ) { row in
                let rendered = SavepointHistoryFace.rendered(row, expanded: expandedRuns)
                if let count = rendered.runCount {
                    QuietRunRow(count: count, expanded: rendered.expanded, tokens: tokens) {
                        expandedRuns = SavepointHistoryFace.toggling(row.id, in: expandedRuns)
                    }
                }
                ForEach(rendered.items, id: \.id) { commit in
                    savepointRow(commit, of: take)
                }
            }
        }
    }

    private func savepointRow(_ commit: CommitPoint, of take: Variant) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(commit.text.prefix(120)))
                .font(tokens.body)
                .foregroundStyle(commit.text.isEmpty ? tokens.muted : tokens.ink)
                .lineLimit(2)
            HStack(spacing: 8) {
                // Row 63's neighbour: a savepoint's stamp keeps its TIME (two
                // moments can share a day), so instead of a second slot the
                // line may WRAP once — "saved by hand" was truncating to
                // "saved by h…" beside the Restore button at the pane's width.
                Text(tokens.chromeLabel(SavepointRowFace.meta(
                    commit, predatesSplit: model.predatesSplit(commit))
                    .joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Button(BlockHistoryCopy.restoreVerb) {
                    Task { await model.restore(commit, of: take.id) }
                }
                .controlSize(.small)
                .help("Loads this saved moment back into the take's buffer — "
                    + "the moment itself stays, and saving again appends")
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Region 2 — archived takes

    @ViewBuilder private var archivedRegion: some View {
        if !model.history.archivedTakes.isEmpty {
            // Row 28: the region reads as a section (header + meaning line),
            // its rows as calm cards — never a List header that can clip.
            CalmSectionHeader(
                tokens: tokens, title: BlockHistoryPath.archivedSection,
                detail: BlockHistoryCopy.archivedExplainer)
                .padding(.top, 8)
            ForEach(model.history.archivedTakes, id: \.id) { take in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.body)
                            .foregroundStyle(
                                take.workingText.isEmpty ? tokens.muted : tokens.ink)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(TrayPath.archivedForever))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                                .fixedSize()
                            Spacer(minLength: 8)
                            Button(BlockHistoryCopy.unarchiveVerb) {
                                Task { await model.unarchive(take.id) }
                            }
                            .controlSize(.small)
                            .help("Back into the block's fan, exactly as it was")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Region 3 — deleted takes (NO purge door: row 21's letter)

    @ViewBuilder private var deletedRegion: some View {
        if !model.history.deletedTakes.isEmpty {
            CalmSectionHeader(
                tokens: tokens, title: BlockHistoryPath.deletedSection,
                detail: BlockHistoryCopy.deletedExplainer)
                .padding(.top, 8)
            ForEach(model.history.deletedTakes, id: \.id) { take in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.body)
                            .foregroundStyle(
                                take.workingText.isEmpty ? tokens.muted : tokens.ink)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            // Row 63: the lead truncates; the CLOCK never does.
                            Text(tokens.chromeLabel(DeletedTakeFace.lead(take)
                                .joined(separator: " \u{B7} ")))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                            if let slot = DeletedTakeFace.clockSlot(take, now: session.now) {
                                Text(tokens.chromeLabel(slot))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.faint)
                                    .lineLimit(1)
                                    .fixedSize()
                                    .layoutPriority(1)
                            }
                            Spacer(minLength: 8)
                            Button(BlockPastCopy.putBackVerb) {
                                Task { await model.putBackTake(take.id) }
                            }
                            .controlSize(.small)
                            .help(BlockPastCopy.putBackHelp(take))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Region 4 — came from (the 13l walk's P-3, fixed)

    @ViewBuilder private var cameFromRegion: some View {
        if !model.history.origins.isEmpty {
            CalmSectionHeader(
                tokens: tokens, title: BlockHistoryPath.cameFromSection,
                detail: OriginPeekCopy.explainer)
                .padding(.top, 8)
            ForEach(model.history.origins) { row in
                CalmCard(tokens: tokens) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(TrayRowPreview.line(row.text))
                            .font(tokens.body)
                            .foregroundStyle(
                                row.text?.isEmpty == false ? tokens.ink : tokens.muted)
                            .lineLimit(3)
                        Text(tokens.chromeLabel(OriginPeekCopy.lineageRow(
                            op: row.origin.originOp, at: row.origin.at)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            Spacer(minLength: 0)
                            Button(BlockHistoryPath.bringBackVerb) {
                                Task { await model.bringBack(row.origin.blockID) }
                            }
                            .controlSize(.small)
                            .help(BlockHistoryPath.bringBackHelp)
                            Button(BlockHistoryPath.openTrayVerb) {
                                onOpenTray?(row.origin.blockID)
                            }
                            .controlSize(.small)
                            .disabled(onOpenTray == nil)
                            .help("The whole list: what this note has set aside, and "
                                + "everything of its own that is on the clock")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pieces

    private func quiet(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

