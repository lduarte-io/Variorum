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

/// **The ONE place the pane's name and its regions are spelled** (the
/// `TrayPath` pattern, and for its reason: receipts, tutorial lessons and
/// menu labels elsewhere promise this surface by name).
nonisolated enum BlockHistoryPath {
    /// The pane's title, the bar door's word, and the registry verb.
    static let name = "Block History"

    /// The bar's door label. Lowercased by the voice like its neighbour
    /// ("commit ⌘S"); the pairing IS the teaching moment (her G4 chapter:
    /// write a moment · see the moments).
    static let doorLabel = "history"

    /// How copy elsewhere points at the door.
    static let doorPhrase = "the history door in the note's bottom bar"

    static let savepointsSection = "Savepoints"
    static let archivedSection = "Archived takes"
    static let deletedSection = "Deleted takes"
    static let cameFromSection = "Came from"

    /// What the whole pane says about itself, once, at the top.
    static let explainer =
        "Everything this block has been: each take's saved moments, the takes "
        + "it set aside or deleted, and the block it came out of."

    /// **The came-from region's path phrase** — the destination
    /// `TrayPath.originalsPath` now names, since her G5 ruling moved unclocked
    /// originals out of the tray and into lineage (*"the tray audits what is
    /// LEAVING; lineage holds what is KEPT"*). One constant, so the eight copy
    /// sites that quoted the tray's section follow for free.
    static var cameFromPath: String { "\(name) \u{2192} \(cameFromSection)" }
    static var cameFromPathWithDoor: String { "\(cameFromPath) (\(doorPhrase))" }

    /// A live take's heading: its own label where it has one, else its place
    /// in the fan. Never the raw id (13g R5-4's rule, one surface over).
    static func takeHeading(_ take: Variant, ordinal: Int, of total: Int) -> String {
        if let label = take.label, !label.isEmpty { return label }
        return total > 1 ? "take \(ordinal) of \(total)" : "this take"
    }

    static let focusedMark = "the take you're in"
    static let noSavepoints = "No saved moments yet — \u{2318}S saves one."
    static let nothingHere =
        "This block has no past yet: one take, no saved moments, nothing set "
        + "aside, and nothing it came out of."

    /// The came-from row's one-button way back. Her fourth-sitting ask named
    /// the idea and rejected her own wording for it: *"add as block again to
    /// the note (that's too wordy, you can reword the button, but the idea is
    /// that if you just merged something then realized you actually wanted a
    /// parent block, you should just be able to pull that parent block back
    /// into existence easily)"*. Two words, the verb first, and the same
    /// grammar as the tray's own **Put back**.
    static let bringBackVerb = "Bring back"
    static let bringBackHelp =
        "Puts this original back into the note, beside the blocks it became — "
        + "it was kept whole and set aside, never deleted"
    static let openTrayVerb = "Open this note's tray"
}

/// **The words the block's past speaks about its TAKES**, in one home.
///
/// *(Kept verbatim from `BlockPastSection.swift`, which this pane replaced:
/// the file's two types were the two absorbed history faces' renderer and
/// model, and both of their hosts are gone — but the sentences are semantic
/// and every one of them is still true, so they move rather than being
/// rewritten. `KnownIssuesAndTechDebt.md` names `BlockPastCopy` as one of the
/// deletion-copy homes still Mac-local and awaiting a hoist; that row stays
/// exactly as true here.)*
nonisolated enum BlockPastCopy {
    static let deletedTakesHeader = BlockHistoryPath.deletedSection
    static let putBackVerb = "Put back"
    static let seeOriginVerb = "See original"

    /// The receipt after a deleted take comes back. It names the fan,
    /// because that is where she will look for it.
    static let takeRestored = "Take put back — it's in this block's fan again."

    /// **The archived edition** (13j ladder A round 1, finding A3): the
    /// restore is an exact flip (#68(b), ruled), so a take that was ARCHIVED
    /// when it was deleted comes back archived — into the archived listing,
    /// not the fan — and the one receipt above was lying for that row. The
    /// door reads `restoreVariant`'s own returned status and says which.
    static let takeRestoredArchived =
        "Take put back — it was archived, so it's in this block's archived "
        + "takes, not the fan. Unarchive it there to bring it back."

    static func restored(_ status: VariantStatus) -> String {
        status == .archived ? takeRestoredArchived : takeRestored
    }

    /// The Put-back button's help, worded to the ROW's status (the row is a
    /// `Variant`, so it knows): "its place in the fan" was false for an
    /// archived take.
    static func putBackHelp(_ take: Variant) -> String {
        take.status == .archived
            ? "Puts this take back among the block's archived takes, exactly "
                + "as it was — it was archived when it was deleted"
            : "Puts this take back in the block's fan, exactly as it was — "
                + "its label, its place in the fan and its savepoints all "
                + "come back with it"
    }

    /// A deleted take's row label: its own label where it has one, else the
    /// take's first line (`TrayRowPreview`'s rule, which the tray's rows
    /// already speak).
    ///
    /// The empty case says **take**, not "block" — caught by the 13j capture,
    /// where an empty deleted take rendered as "(empty block)" because
    /// `TrayRowPreview.line` was written for the tray's BLOCK rows and its
    /// fallback names that noun. A row in a fan that calls itself a block is
    /// the same small dishonesty this family of surfaces exists to end.
    static let emptyTake = "(empty take)"

    static func rowLabel(_ take: Variant) -> String {
        if let label = take.label, !label.isEmpty { return label }
        let line = TrayRowPreview.line(take.workingText)
        return line == TrayRowPreview.emptyBlock ? emptyTake : line
    }
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
    /// sectioned, the one she is in is expanded). A pure rule so a pin holds
    /// the decision without rendering: the focused take where the request
    /// named one and it is still live, else the first live take.
    static func initiallyExpanded(
        _ history: Queries.BlockHistory, focused: String?
    ) -> Set<String> {
        if let focused, history.takes.contains(where: { $0.id == focused }) {
            return [focused]
        }
        return Set(history.activeTakes.first.map { [$0.id] } ?? [])
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

/// The pane's own receipts — beside `BlockPastCopy`'s, which the deleted-take
/// region speaks.
nonisolated enum BlockHistoryCopy {
    static let restoredSavepoint =
        "Saved moment restored into this take — the moments themselves are "
        + "never overwritten, so nothing was lost."
    static let unarchivedTake = "Take unarchived — it's back in this block's fan."
    static let restoreVerb = "Restore"
    static let unarchiveVerb = "Unarchive"
    static let predatesSplitMark = "predates a split"
    static let predatesSplitTitle = "This saved moment predates a split of this block"
    static let predatesSplitDetail =
        "Restoring will resurrect the full pre-split text into this take's "
        + "buffer — the split-off half still exists next door."
    static let restoreAnyway = "Restore Anyway"

    /// The deleted region's own explainer: **no purge door here**, and the
    /// honest place it does live (row 21's letter).
    static let deletedExplainer =
        "On the \(TrashWindow.days)-day clock. Put one back here; to end a "
        + "take's remaining days early, open \(TrayPath.menuLabel) and use "
        + "its leaving section."

    static let archivedExplainer = "Set aside, out of the fan — kept, with no clock."
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
        model: BlockHistoryModel? = nil
    ) {
        self.session = session
        self.onClose = onClose
        self.onOpenTray = onOpenTray
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
            Text(tokens.chromeLabel(BlockHistoryPath.explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            if let status = model.status {
                Text(status.text)
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            List {
                savepointRegion
                archivedRegion
                deletedRegion
                cameFromRegion
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
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

    // MARK: - Region 1 — every live take's saved moments

    @ViewBuilder private var savepointRegion: some View {
        Section(tokens.chromeLabel(BlockHistoryPath.savepointsSection)) {
            if model.loaded, model.history.activeTakes.isEmpty {
                quiet(BlockHistoryPath.nothingHere)
            }
            let takes = model.history.activeTakes
            ForEach(Array(takes.enumerated()), id: \.element.id) { index, take in
                takeRun(take, ordinal: index + 1, of: takes.count)
            }
        }
    }

    @ViewBuilder private func takeRun(
        _ take: Variant, ordinal: Int, of total: Int
    ) -> some View {
        let commits = model.history.savepoints[take.id] ?? []
        DisclosureGroup(isExpanded: Binding(
            get: { expandedTakes.contains(take.id) },
            set: { open in
                if open { expandedTakes.insert(take.id) }
                else { expandedTakes.remove(take.id) }
            })
        ) {
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
        } label: {
            HStack(spacing: 6) {
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
        }
    }

    private func savepointRow(_ commit: CommitPoint, of take: Variant) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(String(commit.text.prefix(120)))
                .font(tokens.body)
                .foregroundStyle(commit.text.isEmpty ? tokens.muted : tokens.ink)
                .lineLimit(2)
            HStack(spacing: 8) {
                Text(tokens.chromeLabel(SavepointRowFace.meta(
                    commit, predatesSplit: model.predatesSplit(commit))
                    .joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
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
            Section {
                ForEach(model.history.archivedTakes, id: \.id) { take in
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
                            Spacer(minLength: 8)
                            Button(BlockHistoryCopy.unarchiveVerb) {
                                Task { await model.unarchive(take.id) }
                            }
                            .controlSize(.small)
                            .help("Back into the block's fan, exactly as it was")
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                header(BlockHistoryPath.archivedSection, BlockHistoryCopy.archivedExplainer)
            }
        }
    }

    // MARK: - Region 3 — deleted takes (NO purge door: row 21's letter)

    @ViewBuilder private var deletedRegion: some View {
        if !model.history.deletedTakes.isEmpty {
            Section {
                ForEach(model.history.deletedTakes, id: \.id) { take in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(BlockPastCopy.rowLabel(take))
                            .font(tokens.body)
                            .foregroundStyle(
                                take.workingText.isEmpty ? tokens.muted : tokens.ink)
                            .lineLimit(2)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(DeletedTakeFace.meta(
                                take, now: session.now).joined(separator: " \u{B7} ")))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                            Spacer(minLength: 8)
                            Button(BlockPastCopy.putBackVerb) {
                                Task { await model.putBackTake(take.id) }
                            }
                            .controlSize(.small)
                            .help(BlockPastCopy.putBackHelp(take))
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                header(BlockHistoryPath.deletedSection, BlockHistoryCopy.deletedExplainer)
            }
        }
    }

    // MARK: - Region 4 — came from (the 13l walk's P-3, fixed)

    @ViewBuilder private var cameFromRegion: some View {
        if !model.history.origins.isEmpty {
            Section {
                ForEach(model.history.origins) { row in
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
                    .padding(.vertical, 2)
                }
            } header: {
                header(BlockHistoryPath.cameFromSection, OriginPeekCopy.explainer)
            }
        }
    }

    // MARK: - Pieces

    private func header(_ title: String, _ explainer: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(tokens.chromeLabel(title))
            Text(tokens.chromeLabel(explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func quiet(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// **A SAVEPOINT ROW'S QUIET LINE, AS A VALUE** — when it was saved, whether
/// it was deliberate or quiet, its message, and the pre-split warning. Pure,
/// so a pin holds what the row says without rendering it (`TrayRowFace`'s
/// shape and its reason).
nonisolated enum SavepointRowFace {
    static func meta(_ commit: CommitPoint, predatesSplit: Bool) -> [String] {
        var pieces = [
            commit.createdAt.formatted(date: .abbreviated, time: .shortened),
            commit.kind == .auto ? "quiet" : "saved by hand",
        ]
        if let message = commit.message, !message.isEmpty { pieces.append(message) }
        if predatesSplit { pieces.append(BlockHistoryCopy.predatesSplitMark) }
        return pieces
    }
}

/// **A DELETED TAKE'S QUIET LINE, AS A VALUE** — when it went and how long it
/// has. The tray's `TrayTakeFace` names the take's BLOCK because the panel is
/// the note; here the pane IS the block, so the row owes the clock instead.
nonisolated enum DeletedTakeFace {
    static func meta(_ take: Variant, now: Date) -> [String] {
        guard let deletedAt = take.deletedAt else { return [] }
        var pieces = [
            "deleted " + deletedAt.formatted(date: .abbreviated, time: .shortened)
        ]
        // The window's own arithmetic, over the ONE canonical stamp shape the
        // rest of the recovery family reads (`TrashWindow.daysLeft` parses
        // what the store holds; the record hands us the decoded date, so it
        // is re-encoded through the same formatter rather than a second
        // subtraction written here).
        if let days = TrashWindow.daysLeft(
            DateFormatter.variorumISO8601.string(from: deletedAt), now: now)
        {
            pieces.append(TrayPath.daysLeftLabel(days))
        }
        return pieces
    }
}
