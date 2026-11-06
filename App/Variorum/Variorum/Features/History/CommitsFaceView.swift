//
//  CommitsFaceView.swift
//  Variorum (Mac)
//
//  **VX-801 (VX-827 U3a) — THE COMMITS FACE.** THE DESIGN MEMO's default face
//  of the block's History & Lineage surface, drawn to her ruled composite
//  (`<home>/shots/shot-20261105-220337.png`, the exploration
//  sitting): the reading pane on the left (the selected moment, whole and
//  scrollable; its header — name or first words, when, its take ✓, quiet,
//  "N changes since", the plain · against now toggle; its acts at the foot),
//  the rail on the right (the take dropdown, "history · …", the dot timeline,
//  the deleted takes at its foot). The pane follows the rail — a click or
//  ↑/↓ — so reading never requires opening anything.
//
//  It takes the FULL pane where a note's detail is mounted (her *"there
//  should be room in the whole pane"*; ‹ back returns), and is the same view
//  in a sheet where no detail is (the book's inline editors, the scraps
//  hosts — the panel's own two-host rule).
//
//  P3: every text here is a `Text` — the pane is a READ surface, never an
//  editor, and no liveness mechanism is added (nothing beside
//  `PaneTextAuthority` decides what is live; nothing here is). The washes are
//  attributes on read-only text — the read tier, never the live editor
//  (TEXTKIT2 §3's rendering-attribute class does not reach a SwiftUI `Text`).
//

import GRDB
import SwiftUI
import VariorumCore

struct CommitsFaceView: View {
    /// The registry ids this face renders INLINE (P-1's `.surface` door; the
    /// walk unions every renderer). `.deleteNow` is deliberately absent: this
    /// is not a trash surface (row 21's letter, kept from the panel). The
    /// crumb row's "lineage ›" is the Lineage face's `.surface` door (U3b).
    static let surfaceCapabilities: [CapabilityID] =
        CommitsFaceBody.surfaceCapabilities + [.showBlockLineage]

    /// The rail's width — B's full-column rail (330 pt drawn).
    static let railWidth: CGFloat = 330

    let session: AppSession
    /// ‹ back — the host restores exactly what was there.
    let onBack: () -> Void
    /// "lineage ›" — the host swaps this face for the Lineage face (U3b); nil
    /// renders no door (P-2).
    var onLineage: (() -> Void)?
    @State private var model: CommitsFaceModel
    @State private var crumbTitle: String?
    @State private var crumbBlock: String?
    @FocusState private var keysHeld: Bool
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, request: BlockHistoryRequest, onBack: @escaping () -> Void,
        onLineage: (() -> Void)? = nil, model: CommitsFaceModel? = nil
    ) {
        self.session = session
        self.onBack = onBack
        self.onLineage = onLineage
        _model = State(initialValue: model ?? CommitsFaceModel(session: session, request: request))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            crumbRow
            if let status = model.status {
                CommitsFaceStatusLine(status: status, tokens: tokens)
            }
            CommitsFaceBody(model: model, session: session, tokens: tokens) { keysHeld = true }
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.room)
        // The fast swapper's keys (PROVISIONAL P-U3a-4): ↑ newer, ↓ older.
        // The face holds the keyboard while it stands — there is no editor
        // under it to type into.
        .focusable()
        .focusEffectDisabled()
        .focused($keysHeld)
        .onKeyPress(.upArrow) {
            guard model.compareBoxes == nil else { return .ignored }
            model.step(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            guard model.compareBoxes == nil else { return .ignored }
            model.step(by: 1)
            return .handled
        }
        .onAppear { keysHeld = true }
        .task { await readCrumb() }
        #if DEBUG
        .onAppear { CommitsFaceOracle.publish(model, owner: oracleOwner) }
        .onDisappear { CommitsFaceOracle.release(owner: oracleOwner) }
        #endif
    }

    #if DEBUG
    @State private var oracleOwner = UUID()
    #endif

    /// The note's name and the block's place, read once — the crumb her
    /// composite draws ("On Rereading › block 2 › history").
    private func readCrumb() async {
        let read = try? await CommitsFaceCrumb.read(
            session: session, postID: model.postID, blockID: model.blockID)
        crumbTitle = read?.title ?? nil
        crumbBlock = read?.block
    }

    // MARK: - The crumb row

    private var crumbRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Button(tokens.chromeLabel(CommitsFaceCopy.back), action: onBack)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help(CommitsFaceCopy.backHelp)
            Text(tokens.chromeLabel(
                ([crumbTitle, crumbBlock].compactMap { $0 } + [
                    model.compareBoxes == nil ? CommitsFaceCopy.crumb : CommitsFaceCopy.compareCrumb,
                ]).joined(separator: " \u{203A} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
            Spacer(minLength: 0)
            // U3b: the Lineage face's one door on this face (her composite's
            // "lineage ›", top right) — the registry's `.showBlockLineage`.
            if let onLineage {
                Button(tokens.chromeLabel(CommitsFaceCopy.lineageDoor), action: onLineage)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(CommitsFaceCopy.lineageDoorHelp)
            }
        }
    }
}

/// The face's one status line — a receipt muted, a refusal in the alarm ink.
struct CommitsFaceStatusLine: View {
    let status: RecoveryStatus
    let tokens: VoiceTokens

    var body: some View {
        Text(status.text)
            .font(tokens.small)
            .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
            .textSelection(.enabled)
            .lineLimit(3)
    }
}

/// **THE PANE + RAIL COMPOSITION, ONE IMPLEMENTATION** (VX-827 U3b — THE
/// DESIGN MEMO: "selecting an ancestor swaps the SAME pane+rail composition to
/// that block"). The Commits face composes it over the block the door was
/// pressed on; the Lineage face composes it over the member she selects — the
/// model's `role` decides the acts, never this view. Compare stands in its
/// place while boxes are open.
struct CommitsFaceBody: View {
    /// The acts this composition renders inline: the four moment acts, the
    /// deleted take's Put back and Unarchive (U3a); a relative's moment brings
    /// back across lineage (U3b).
    static let surfaceCapabilities: [CapabilityID] = [
        .restoreCommit, .bringBackCommitAsTake, .compareCommits, .renameCommit,
        .restoreTake, .unarchiveTake, .bringBackLineageAsTake,
    ]

    let model: CommitsFaceModel
    let session: AppSession
    let tokens: VoiceTokens
    /// A rail press hands the keyboard back to the face (the fast swapper).
    var onRailPress: () -> Void = {}
    @State private var takesShown = false

    var body: some View {
        Group {
            if model.compareBoxes != nil {
                CommitsCompareView(model: model, tokens: tokens)
            } else {
                HStack(alignment: .top, spacing: 10) {
                    readingPane
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    rail
                        .frame(width: CommitsFaceView.railWidth)
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .task { await model.start() }
        .task { await model.watchSeal() }
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

    // MARK: - The reading pane

    private var readingPane: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text(model.headline(model.selection))
                    .font(tokens.navigation.weight(.medium))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                Text(tokens.chromeLabel(model.meta(model.selection).joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .stampHelp(model.selectedCommit.map { TimeStampFace.whole($0.createdAt) })
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 8)
            if let changes = model.changesSince {
                HStack(spacing: 8) {
                    Text(tokens.chromeLabel(changes))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    VoicedChip(
                        tokens: tokens, text: CommitsFaceCopy.plainWash,
                        on: model.wash == .plain
                    ) { model.setWash(.plain) }
                    .lineLimit(1)
                    .fixedSize()
                    VoicedChip(
                        tokens: tokens, text: CommitsFaceCopy.againstNowWash,
                        on: model.wash == .againstNow
                    ) { model.setWash(.againstNow) }
                    .lineLimit(1)
                    .fixedSize()
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 8)
            }
            Divider().overlay(tokens.line)
            ScrollView {
                Text(CommitsFaceText.attributed(
                    runs: paneRuns, tokens: tokens,
                    empty: (model.text(of: model.selection) ?? "").isEmpty))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .textSelection(.enabled)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
            }
            .id(model.selection)
            if !model.paneActs.isEmpty {
                Divider().overlay(tokens.line)
                paneActs
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
            }
        }
        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tokens.line, lineWidth: 1))
        // The take this note shows wears the chosen bar (her composite's
        // green edge; B: "no green bar on the pane: you are looking at a take
        // the note doesn't show").
        .overlay(alignment: .leading) {
            if model.selectionIsChosen {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(tokens.chosen)
                    .frame(width: 3)
                    .padding(.vertical, 12)
            }
        }
    }

    /// What the pane's text is drawn from: the unified washes against now,
    /// else the moment plain.
    private var paneRuns: [TextCompare.Run] {
        if let comparison = model.paneComparison { return comparison.unified }
        let text = model.text(of: model.selection) ?? ""
        return text.isEmpty ? [] : [.init(.same, text)]
    }

    @ViewBuilder private var paneActs: some View {
        HStack(spacing: 16) {
            ForEach(model.paneActs, id: \.self) { act in
                switch act {
                case .restore:
                    Button(tokens.chromeLabel(BlockHistoryCopy.restoreVerb)) {
                        Task { await model.restoreSelected() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(BlockHistoryPath.restoreHelp)
                case .bringBack:
                    Button(tokens.chromeLabel(BlockHistoryPath.bringBackAsTakeVerb)) {
                        Task { await model.bringBackSelected() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(model.isRelative
                        ? LineageFaceCopy.bringBackHelp : BlockHistoryPath.bringBackAsTakeHelp)
                case .compare:
                    Button(tokens.chromeLabel(
                        model.isRelative ? LineageFaceCopy.compareWithNow : CommitsFaceCopy.compareVerb)
                    ) { model.openCompare() }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .help(model.isRelative ? LineageFaceCopy.compareWithNowHelp : CommitsFaceCopy.compareHelp)
                case .rename:
                    if let commit = model.selectedCommit {
                        Button(tokens.chromeLabel(BlockHistoryCopy.nameVerb(commit))) {
                            model.askRenameSelected()
                        }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .help(model.sealed ? TrayRefusalCopy.sealed : BlockHistoryCopy.nameHelp(commit))
                        .savepointNameAsk(
                            Binding(get: { model.renameAsk }, set: { model.renameAsk = $0 }),
                            tokens: tokens
                        ) { ask, name in
                            Task { await model.rename(commitID: ask.targetID, to: name) }
                        }
                    }
                case .unarchive:
                    if case .now(let takeID)? = model.selection {
                        Button(tokens.chromeLabel(BlockHistoryCopy.unarchiveVerb)) {
                            Task { await model.unarchive(takeID) }
                        }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .help("Back into the block's fan, exactly as it was")
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - The rail

    private var rail: some View {
        VStack(alignment: .leading, spacing: 6) {
            takeSwitcher
            Text(tokens.chromeLabel(
                model.filter == .all ? CommitsFaceCopy.historyAll : CommitsFaceCopy.historyThisTake))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .padding(.horizontal, 6)
                .help(CommitsFaceCopy.swapperHelp)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(model.lines) { line in
                            railRow(line).id(line.id)
                        }
                    }
                    .padding(.bottom, 4)
                }
                .onChange(of: model.selection) { _, selection in
                    guard let id = model.lines.first(where: { $0.moment == selection })?.id
                    else { return }
                    withAnimation(.easeInOut(duration: 0.12)) { proxy.scrollTo(id) }
                }
            }
            // A deleted take is put back on its own block's face — a
            // relative's are not acted on from here (P-U3b-4).
            if !model.isRelative, !model.history.deletedTakes.isEmpty {
                Divider().overlay(tokens.line)
                ForEach(model.history.deletedTakes, id: \.id) { take in
                    deletedLine(take)
                }
            }
        }
        .padding(8)
        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(tokens.line, lineWidth: 1))
    }

    /// **The take dropdown** — "plain ✓ chosen · 5 takes ▾", the Write
    /// takes-popup family: one tinted row per take, archived takes grouped.
    private var takeSwitcher: some View {
        let entries = model.takeEntries
        let current: CommitsFaceModel.TakeEntry? = {
            if case .take(let id) = model.filter { return entries.first { $0.id == id } }
            return nil
        }()
        return Button { takesShown.toggle() } label: {
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(current?.chosen == true ? tokens.chosen : Color.clear)
                    .frame(width: 3, height: 16)
                Text(current?.title ?? CommitsFaceCopy.allTakes)
                    .font(tokens.navigation.weight(.medium))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if current?.chosen == true {
                    Text(tokens.chromeLabel(CommitsFaceCopy.chosenMark))
                        .font(tokens.small)
                        .foregroundStyle(tokens.chosen)
                        .lineLimit(1)
                        .fixedSize()
                }
                Spacer(minLength: 6)
                Text(tokens.chromeLabel(CommitsFaceCopy.takesCount(
                    entries.filter { !$0.archived }.count)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                current?.chosen == true ? tokens.wash : tokens.card,
                in: RoundedRectangle(cornerRadius: 9))
            .overlay(RoundedRectangle(cornerRadius: 9).stroke(tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $takesShown, arrowEdge: .bottom) { takePicker(entries) }
    }

    private func takePicker(_ entries: [CommitsFaceModel.TakeEntry]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                pickerRow(
                    title: CommitsFaceCopy.allTakes, chosen: false, locked: false,
                    count: entries.reduce(0) { $0 + $1.commitCount }, words: nil,
                    on: model.filter == .all
                ) {
                    model.setFilter(.all)
                    takesShown = false
                }
                ForEach(entries.filter { !$0.archived }) { entry in
                    pickerRow(entry)
                }
                let archived = entries.filter(\.archived)
                if !archived.isEmpty {
                    Text(tokens.chromeLabel(CommitsFaceCopy.archivedGroup))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(.top, 6)
                        .padding(.horizontal, 4)
                    ForEach(archived) { entry in pickerRow(entry) }
                }
            }
            .padding(9)
        }
        .frame(width: 360)
        .frame(maxHeight: 420)
        .background(tokens.surface)
    }

    private func pickerRow(_ entry: CommitsFaceModel.TakeEntry) -> some View {
        pickerRow(
            title: entry.title, chosen: entry.chosen, locked: entry.locked,
            count: entry.commitCount, words: entry.firstWords, archived: entry.archived,
            on: model.filter == .take(entry.id)
        ) {
            model.setFilter(.take(entry.id))
            takesShown = false
        }
    }

    private func pickerRow(
        title: String, chosen: Bool, locked: Bool, count: Int, words: String?,
        archived: Bool = false, on: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(chosen ? tokens.chosen : Color.clear)
                        .frame(width: 3, height: 15)
                    Text(title)
                        .font(tokens.navigation.weight(.medium))
                        .foregroundStyle(archived ? tokens.muted : tokens.ink)
                        .lineLimit(1)
                    if chosen {
                        Text(tokens.chromeLabel(CommitsFaceCopy.chosenMark))
                            .font(tokens.small).foregroundStyle(tokens.chosen)
                            .lineLimit(1).fixedSize()
                    }
                    if locked {
                        Text(tokens.chromeLabel(CommitsFaceCopy.lockedMark))
                            .font(tokens.small).foregroundStyle(tokens.muted)
                            .lineLimit(1).fixedSize()
                    }
                    Spacer(minLength: 6)
                    Text(tokens.chromeLabel(CommitsFaceCopy.commitsCount(count)))
                        .font(tokens.small).foregroundStyle(tokens.faint)
                        .lineLimit(1).fixedSize()
                }
                if let words {
                    Text(words)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .padding(.leading, 10)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(
                archived ? tokens.room : (chosen ? tokens.wash : tokens.card),
                in: RoundedRectangle(cornerRadius: 9))
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(on ? tokens.accent : tokens.line, lineWidth: on ? 1.5 : 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// One line of the dot timeline.
    private func railRow(_ line: CommitRail.Line) -> some View {
        let selected = line.moment != nil && line.moment == model.selection
        return Button {
            if case .quietRun(let id, _, _, _, _, _) = line.content {
                model.toggleRun(id)
            } else if let moment = line.moment {
                model.select(moment)
            }
            onRailPress()
        } label: {
            HStack(spacing: 7) {
                ZStack {
                    Rectangle().fill(tokens.line).frame(width: 1.5)
                    CommitsFaceDot(line: line, selected: selected, tokens: tokens)
                }
                .frame(width: 20)
                .padding(.leading, inRun(line) ? 12 : 0)
                rowWords(line)
                Spacer(minLength: 4)
                rowStamp(line)
            }
            .frame(minHeight: 28)
            .padding(.trailing, 8)
            .background(
                rowBackground(line, selected: selected),
                in: RoundedRectangle(cornerRadius: 7))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(rowHelp(line))
    }

    private func inRun(_ line: CommitRail.Line) -> Bool {
        if case .commit(_, _, true) = line.content { return true }
        return false
    }

    private func rowBackground(_ line: CommitRail.Line, selected: Bool) -> Color {
        if selected { return tokens.wash }
        // An AI's edit rides a quiet wash (PROVISIONAL face, P-U3a-7).
        if line.pairID != nil { return tokens.accent.opacity(0.08) }
        return .clear
    }

    @ViewBuilder private func rowWords(_ line: CommitRail.Line) -> some View {
        switch line.content {
        case .now:
            Text(tokens.chromeLabel(CommitsFaceCopy.theTakeNow))
                .font(tokens.small)
                .foregroundStyle(tokens.chosen)
                .lineLimit(1)
        case .commit(let commit, let takeID, _):
            HStack(spacing: 6) {
                CommitsRailWords(commit: commit, archivedTake: line.archivedTake, tokens: tokens)
                if model.filter == .all { takeChip(takeID) }
            }
        case .quietRun(_, let count, let takeIDs, _, _, let expanded):
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(
                    SavepointRuns.runLabel(count: count) + (expanded ? " \u{25BE}" : " \u{25B8}")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .fixedSize()
                if model.filter == .all {
                    ForEach(takeIDs, id: \.self) { takeChip($0) }
                }
            }
        }
    }

    private func takeChip(_ takeID: String) -> some View {
        Text(model.takeTitle(takeID))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: 96, alignment: .leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(tokens.takeTint, in: Capsule())
            .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder private func rowStamp(_ line: CommitRail.Line) -> some View {
        switch line.content {
        case .now:
            EmptyView()
        case .commit(let commit, _, _):
            Text(tokens.chromeLabel(TimeStampFace.relative(commit.createdAt, now: session.now)))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
                .fixedSize()
                .stampHelp(TimeStampFace.whole(commit.createdAt))
        case .quietRun(_, _, _, let newest, _, _):
            Text(tokens.chromeLabel(TimeStampFace.relative(newest, now: session.now)))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
                .fixedSize()
        }
    }

    private func rowHelp(_ line: CommitRail.Line) -> String {
        switch line.content {
        case .quietRun: return SavepointRuns.runHelp
        case .commit(let commit, _, _) where commit.kind == .auto && line.bracket == nil:
            return CommitRowFace.quietGlyphHelp
        default: return CommitsFaceCopy.swapperHelp
        }
    }

    /// The rail's foot: each deleted take on its clock, with Put back (the
    /// memo's "count · days left · Put back", one line per take —
    /// PROVISIONAL P-U3a-8).
    private func deletedLine(_ take: Variant) -> some View {
        HStack(spacing: 6) {
            Text(tokens.chromeLabel(
                ([CommitsFaceCopy.deletedTake, BlockPastCopy.rowLabel(take)]
                    + (DeletedTakeFace.clockSlot(take, now: session.now).map { [$0] } ?? []))
                    .joined(separator: " \u{B7} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.middle)
                .stampHelp(DeletedTakeFace.leadHelp(take))
            Spacer(minLength: 4)
            Button(tokens.chromeLabel(BlockPastCopy.putBackVerb)) {
                Task { await model.putBackTake(take.id) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(BlockPastCopy.putBackHelp(take))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
    }
}


/// **A moment's words on the rail** — its name in ink, or (VX-674, her
/// ruling) an UNNAMED moment's first words, muted; one line, the layout's
/// truncation the only ellipsis. An archived take's moment is muted either
/// way. One small view, so the resting-words pins read what the rail draws.
struct CommitsRailWords: View {
    let commit: CommitPoint
    let archivedTake: Bool
    let tokens: VoiceTokens

    var body: some View {
        if let name = SavepointRowFace.name(commit) {
            Text(name)
                .font(tokens.small)
                .foregroundStyle(archivedTake ? tokens.muted : tokens.ink)
                .lineLimit(1)
                .truncationMode(.tail)
        } else {
            Text(CommitRowFace.restingPreview(commit.text))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

/// **The face in a sheet** (the hosts with no note detail — the book's inline
/// editors, the scraps hosts, Write's take panel): a reading width for the
/// pane beside the rail.
nonisolated enum CommitsFaceSheet {
    static let minWidth: CGFloat = 760
    static let idealWidth: CGFloat = 980
    static let minHeight: CGFloat = 480
    static let idealHeight: CGFloat = 660
}

/// One dot of the timeline — the legend B drew: the take now a hollow ring;
/// a moment she made a filled dot; a quiet one a small hollow; an archived
/// take's moment hollow; a run dashed; an AI's moment in the accent; the
/// selected moment filled in ink.
struct CommitsFaceDot: View {
    let line: CommitRail.Line
    let selected: Bool
    let tokens: VoiceTokens

    var body: some View {
        switch line.content {
        case .now:
            Circle()
                .strokeBorder(selected ? tokens.ink : tokens.chosen, lineWidth: 2)
                .background(Circle().fill(tokens.surface))
                .frame(width: 10, height: 10)
        case .quietRun:
            Circle()
                .strokeBorder(tokens.faint, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                .background(Circle().fill(tokens.surface))
                .frame(width: 8, height: 8)
        case .commit(let commit, _, _):
            if selected {
                Circle()
                    .fill(tokens.ink)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(tokens.ring, lineWidth: 1.5).padding(-3))
            } else if line.bracket != nil {
                Circle().fill(tokens.accent).frame(width: 9, height: 9)
            } else if line.archivedTake || commit.kind == .auto {
                Circle()
                    .strokeBorder(tokens.faint, lineWidth: 1.5)
                    .background(Circle().fill(tokens.surface))
                    .frame(width: line.archivedTake ? 9 : 7, height: line.archivedTake ? 9 : 7)
            } else {
                Circle().fill(tokens.faint).frame(width: 9, height: 9)
            }
        }
    }
}

/// **The washes, drawn** — removed words struck on a rose wash, added words
/// on a green one (her reference's language), in the voice's own tokens.
/// Between a removal and the addition right after it, a space is drawn where
/// neither carries one, so the two phrases read apart (a drawing choice; the
/// runs themselves keep both texts byte for byte).
nonisolated enum CommitsFaceText {
    static func attributed(
        runs: [TextCompare.Run], tokens: VoiceTokens, empty: Bool
    ) -> AttributedString {
        guard !empty || !runs.isEmpty else {
            var none = AttributedString(BlockPastCopy.emptyTake)
            none.swiftUI.foregroundColor = tokens.muted
            return none
        }
        var out = AttributedString()
        for (index, run) in runs.enumerated() {
            var piece = AttributedString(run.text)
            switch run.kind {
            case .same:
                break
            case .removed:
                piece.swiftUI.strikethroughStyle = Text.LineStyle(pattern: .solid, color: tokens.alarm)
                piece.swiftUI.foregroundColor = tokens.muted
                piece.swiftUI.backgroundColor = tokens.alarm.opacity(0.14)
            case .added:
                piece.swiftUI.backgroundColor = tokens.positive.opacity(0.18)
            }
            out += piece
            if run.kind == .removed, index + 1 < runs.count, runs[index + 1].kind == .added,
               run.text.last?.isWhitespace != true,
               runs[index + 1].text.first?.isWhitespace != true {
                out += AttributedString(" ")
            }
        }
        return out
    }
}

/// **The crumb's block place** — "block 2/4" — read once per face. One
/// indexed count over this note's live placements (the bars' own "block
/// 6/23" fact), never the corpus.
nonisolated enum CommitsFaceCrumb {
    /// The note's name and the block's "block N/M", read once (both faces'
    /// crumbs).
    static func read(
        session: AppSession, postID: String, blockID: String
    ) async throws -> (title: String?, block: String?) {
        let read = try await session.database.read { db in
            (title: try Queries.noteDisplayTitle(db, id: postID),
             place: try CommitsFaceCrumb.place(db, postID: postID, blockID: blockID))
        }
        return (read.title, read.place.map { BlockLineLabel.caret(ordinal: $0.ordinal, of: $0.count) })
    }

    static func place(
        _ db: Database, postID: String, blockID: String
    ) throws -> (ordinal: Int, count: Int)? {
        guard let row = try Row.fetchOne(
            db,
            sql: """
                SELECT
                  (SELECT COUNT(*) FROM container_block cb
                    WHERE cb.container_id = me.container_id AND cb.deleted_at IS NULL
                      AND (cb.position < me.position
                           OR (cb.position = me.position AND cb.id <= me.id))) AS ordinal,
                  (SELECT COUNT(*) FROM container_block cb
                    WHERE cb.container_id = me.container_id AND cb.deleted_at IS NULL) AS total
                FROM container_block me
                WHERE me.block_id = ? AND me.container_id = ? AND me.deleted_at IS NULL
                """,
            arguments: [blockID, postID])
        else { return nil }
        return (row["ordinal"], row["total"])
    }
}

#if DEBUG
/// **The face's pin door** (the VX-668 shape): the face builds its model in
/// its own `@State`, out of a pin's reach, so the mounted face publishes it —
/// keyed by its note, owner-stamped. Read by pins only; decides nothing.
@MainActor
enum CommitsFaceOracle {
    private static var models = OwnedRegistrations<String, CommitsFaceModel>()

    static func model(forPost postID: String) -> CommitsFaceModel? { models[postID] }

    static func publish(_ model: CommitsFaceModel, owner: UUID) {
        models.publish(model, for: model.postID, owner: owner)
    }

    static func release(owner: UUID) { models.release(owner: owner) }
}
#endif
