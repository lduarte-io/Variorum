//
//  BlocksWorkbenchView.swift
//  Variorum
//
//  pre-13u Act 10 wave 2c — **BLOCKS, kept and earned** (item 16, W8-1;
//  her ruling verbatim: "keep Blocks as the poweruser center for someone
//  who wants to really work with their block, without the side menu even.
//  make sure it has high quality doors to the trays, every operation
//  blocks have, etc. this is a useful powerhouse for something complex").
//
//  Direction C: blocks as OBJECTS — real facts per row (takes · comments
//  · lock · words · edited · tags, from `Queries.blockWorkbench`),
//  multi-select with a bulk bar (13e's `BlockSelection` brain and its
//  ⌘-click merge, given the management face), and a right-hand context
//  panel for the focused block (its facts, its text — editable through the
//  ONE `PaneTextAuthority` — its takes, and the doors onward: Write, Takes,
//  the Block History pane, the tray). The name "Blocks" stays, as ruled.
//
//  Every door of the retired TOC page survives here: expand-to-edit (the
//  panel's body), ↑↓, the whole ⋯ menu (name · jump · move to
//  top/bottom/# · move out to snippets · archive · delete), the tray
//  door. The bulk acts are the standing ops under the standing compound
//  shapes (delete = ONE ⌥⌘Z entry; merge = the carry-all chain — the
//  shared brains, the third door of the same act).
//
//  THE ACT 10 CORRECTION ROUND, batch C (her report on this page):
//  - **row 25 ("weird and laggy — it takes a second after selecting it")**,
//    MEASURED first on the dev build: a row click landed 0.26–0.49 s late
//    because the row shell stacked a count-2 tap gesture before the plain
//    one, so every single click waited out the 0.5 s double-click interval;
//    and the mode arrived with an EMPTY list for ~0.25 s because the rows
//    waited on the joined facts query. Now ONE tap handler reads the
//    event's own click count (a single click acts at once; the second
//    click of a double still opens in Write), and the list renders from the
//    TOC rows the moment they land — the facts arrive onto the rows.
//  - **row 18**: the seam between the list and the panel is DRAGGABLE
//    (the pane row's grammar), its width remembered.
//  - **row 26 (PROVISIONAL)**: the panel leads with the block's FACTS; the
//    text card follows ("the text is also above the details").
//  - **row 27**: while an inspector column (history, the tray, versions)
//    stands beside this mode, the context panel YIELDS — ONE right region
//    at a time, never a third column past the window's edge.
//

import GRDB  // the panel's savepoint count (one bounded read)
import SwiftUI
import VariorumCore

/// The workbench's LIST BRAIN, pure (row 25): the display rows are built
/// from the TOC rows — which land first, being the same cheap query every
/// note mode reads — and the joined FACTS are laid onto them when they
/// arrive. Filtering by a fact (a tag, a comment) and sorting by one
/// (edited, longest) honestly wait for the facts; note order never does.
nonisolated enum WorkbenchRows {
    struct Display: Identifiable, Equatable {
        let row: Queries.TOCRow
        let facts: Queries.WorkbenchRow?
        /// The 1-based NOTE ordinal (derived once per pass — never a
        /// per-row index walk).
        let ordinal: Int
        var id: String { row.placementID }
    }

    static func display(
        rows: [Queries.TOCRow], facts: [Queries.WorkbenchRow],
        filter: String, show: BlocksWorkbenchView.ShowFilter,
        sort: BlocksWorkbenchView.SortOrder
    ) -> [Display] {
        let factsByBlock = Dictionary(facts.map { ($0.blockID, $0) }, uniquingKeysWith: { a, _ in a })
        var result = rows.enumerated().map { i, row in
            Display(row: row, facts: factsByBlock[row.blockID], ordinal: i + 1)
        }
        let needle = filter.trimmingCharacters(in: .whitespaces)
        if !needle.isEmpty {
            result = result.filter { entry in
                let handle = Queries.tocHandle(name: entry.row.name, text: entry.row.text)
                return handle.localizedCaseInsensitiveContains(needle)
                    || (entry.row.text?.localizedCaseInsensitiveContains(needle) ?? false)
                    || (entry.facts?.tagPaths.contains {
                        $0.localizedCaseInsensitiveContains(needle)
                    } ?? false)
            }
        }
        result = result.filter { show.admits($0) }
        switch sort {
        case .noteOrder:
            break
        case .recentlyEdited:
            guard !facts.isEmpty else { break }
            result.sort { ($0.facts?.editedAt ?? "") > ($1.facts?.editedAt ?? "") }
        case .longest:
            guard !facts.isEmpty else { break }
            result.sort { ($0.facts?.wordCount ?? 0) > ($1.facts?.wordCount ?? 0) }
        }
        return result
    }
}

/// The split's arithmetic (row 18), pure: the panel keeps a readable
/// measure, the list keeps room to be a list, and a drag can never swallow
/// either.
nonisolated enum BlocksWorkbenchLayout {
    static let defaultPanelWidth: Double = 320
    static let minimumPanelWidth: Double = 260
    static let maximumPanelWidth: Double = 640
    static let minimumListWidth: Double = 320

    static func panelWidth(proposed: Double, total: Double) -> Double {
        let roomForPanel = max(minimumPanelWidth, total - minimumListWidth)
        return min(max(proposed, minimumPanelWidth), min(maximumPanelWidth, roomForPanel))
    }
}

struct BlocksWorkbenchView: View {
    /// The declared row-menu acts (P-1's declared ⇔ rendered walk) — the
    /// TOC pair plus the bulk bar's compound pair (the Takes board's own
    /// declared ids, rendered here as the workbench's bulk doors).
    static let surfaceCapabilities: [CapabilityID] = [
        .archiveBlock, .deleteBlock, .mergeSelectedBlocks, .deleteSelectedBlocks,
        // 18f batch 1 (her U-4/U-16): the picked run's two roads, beside Merge.
        .mergeWithCeremony,
        // 18c batch 3 (her U-6): the bulk bar's newline repair.
        .splitSelectedBlocksAtNewlines,
    ]

    /// The remembered split (row 18) — a workbench posture, not a per-note
    /// fact.
    static let panelWidthKey = "blocksWorkbenchPanelWidth"
    /// The workbench's own coordinate space — the divider's drag and the
    /// DEBUG oracle read frames in it.
    nonisolated static let space = "variorum-blocks-workbench"

    let session: AppSession
    let postID: String
    var onJump: ((String) -> Void)?
    /// Row 27: an inspector column stands beside this mode — the context
    /// panel yields (one right region at a time).
    var inspectorOpen = false

    @State private var model: BlockTOCViewModel
    /// The context panel's subject — a plain click names it (item 10's
    /// click model applied in place: body click focuses, ⌘-click picks).
    @State private var focusedBlockID: String?
    @State private var filter = ""
    @State private var showFilter: ShowFilter = .all
    @State private var sortOrder: SortOrder = .noteOrder
    @State private var seeded = false
    @State private var renameTarget: Queries.TOCRow?
    @State private var renameText = ""
    @State private var moveTarget: Queries.TOCRow?
    @State private var moveOrdinalText = ""
    @State private var trayShown = false
    @State private var allTags: [Tag] = []
    @AppStorage(BlocksWorkbenchView.panelWidthKey) private var panelWidth: Double
        = BlocksWorkbenchLayout.defaultPanelWidth
    @State private var totalWidth: CGFloat = 0
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
    }

    init(
        session: AppSession, postID: String,
        onJump: ((String) -> Void)? = nil, inspectorOpen: Bool = false,
        model: BlockTOCViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.onJump = onJump
        self.inspectorOpen = inspectorOpen
        _model = State(initialValue: model ?? BlockTOCViewModel(session: session, postID: postID))
    }

    // MARK: - Ways of looking (view-local postures, never persisted)

    enum ShowFilter: String, CaseIterable, Sendable {
        case all = "all"
        case withTakes = "with takes"
        case withComments = "with comments"
        case locked = "locked"
        case tagged = "tagged"

        /// The TOC row answers takes and lock at once; comments and tags
        /// are facts and honestly wait for them.
        nonisolated func admits(_ entry: WorkbenchRows.Display) -> Bool {
            switch self {
            case .all: true
            case .withTakes: entry.row.hasFan
            case .withComments: (entry.facts?.commentCount ?? 0) > 0
            case .locked: entry.row.variantLocked
            case .tagged: !(entry.facts?.tagPaths.isEmpty ?? true)
            }
        }
    }

    enum SortOrder: String, CaseIterable, Sendable {
        case noteOrder = "note order"
        case recentlyEdited = "recently edited"
        case longest = "longest"

        /// Only note order can honestly host the reorder doors — a sorted
        /// listing is a way of looking, and ↑↓ there would lie.
        var isNoteOrder: Bool { self == .noteOrder }
    }

    private func displayRows() -> [WorkbenchRows.Display] {
        WorkbenchRows.display(
            rows: model.rows, facts: model.facts,
            filter: filter, show: showFilter, sort: sortOrder)
    }

    private var totalWords: Int {
        model.facts.reduce(0) { $0 + $1.wordCount }
    }

    /// The focused block's FACTS — the panel's subject once the joined row
    /// is in hand (the list shows the row before that).
    private var focusedFacts: Queries.WorkbenchRow? {
        guard let focusedBlockID else { return nil }
        return model.facts.first { $0.blockID == focusedBlockID }
    }

    private var panelShown: Bool { focusedFacts != nil && !inspectorOpen }

    var body: some View {
        VStack(spacing: 0) {
            toolRow
            HStack(spacing: 0) {
                listColumn
                if let row = focusedFacts, !inspectorOpen {
                    // Row 9's part the HOST owns (the round-end Fable pass,
                    // MINOR-3): the panel is the divider's later HStack
                    // sibling and hit-tests above it, which is why the grip's
                    // panel-side half was dead here — the fifth copy of the
                    // shape the shell, `SideColumn` and the pane row had shed.
                    divider
                        .zIndex(1)
                    WorkbenchInfoPanel(
                        session: session, model: model, tokens: tokens,
                        indicator: indicator,
                        row: row, ordinal: ordinal(of: row.blockID),
                        onJump: { onJump?(row.blockID) },
                        onRename: {
                            renameText = row.name ?? ""
                            renameTarget = tocRow(row.blockID)
                        },
                        onClose: { self.focusedBlockID = nil })
                        .frame(width: BlocksWorkbenchLayout.panelWidth(
                            proposed: panelWidth, total: Double(totalWidth)))
                        .id("wb-panel-\(row.blockID)")
                }
            }
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { totalWidth = $0 }
        }
        .coordinateSpace(name: Self.space)
        .debugProbeScope(session)
        .background(tokens.surface)
        // Row 83: the rows are PRIMED by one bounded read before the
        // observation starts, and the four sibling observations wait for
        // that read — the first paint carries the note.
        .task { await model.primeRows(); await model.start() }
        .task { await model.awaitPrimed(); await model.startFacts() }
        .task { await model.awaitPrimed(); await model.startTray() }
        .task { await model.awaitPrimed(); await model.startPools() }
        .task {
            await model.awaitPrimed()
            allTags = (try? await session.database.read { try Queries.allTags($0) }) ?? []
        }
        .onDisappear { model.teardown() }
        .onChange(of: focusedBlockID) { _, new in
            #if DEBUG
            BlocksWorkbenchOracle.recordFocus(new, in: session.debugProbeScope)
            #endif
        }
        .onChange(of: panelShown, initial: true) { _, shown in
            #if DEBUG
            BlocksWorkbenchOracle.recordPanel(shown, in: session.debugProbeScope)
            #endif
        }
        .onChange(of: model.rows) { _, rows in
            guard !seeded, !rows.isEmpty else {
                // The panel's subject can die under it (deleted in another
                // window) — close rather than showing a ghost.
                if let focusedBlockID, !rows.isEmpty,
                   !rows.contains(where: { $0.blockID == focusedBlockID }) {
                    self.focusedBlockID = nil
                }
                return
            }
            seeded = true
            // Arrive where she was (row 39: the ONE current block).
            let fact = session.commandRouter.focusedBlock
            if fact?.postID == postID,
               let id = fact?.blockID, rows.contains(where: { $0.blockID == id }) {
                focusedBlockID = id
            }
        }
        .sheet(isPresented: $trayShown) {
            TrayPanel(session: session, postID: postID)
        }
        .alert(
            "Name this block",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { row in
            TextField("Name (blank clears)", text: $renameText)
            Button("Save") {
                let name = renameText
                Task { await model.rename(blockID: row.blockID, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Move to block # (of \(model.rows.count))",
            isPresented: Binding(
                get: { moveTarget != nil },
                set: { if !$0 { moveTarget = nil } }),
            presenting: moveTarget
        ) { row in
            TextField("Position (1–\(model.rows.count))", text: $moveOrdinalText)
            Button("Move") {
                let raw = moveOrdinalText.trimmingCharacters(in: .whitespaces)
                Task {
                    if let target = Int(raw) {
                        await model.move(blockID: row.blockID, toOrdinal: target)
                    } else {
                        model.refuse("\u{201C}\(raw)\u{201D} isn't a position number — type 1 to \(model.rows.count).")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func tocRow(_ blockID: String) -> Queries.TOCRow? {
        model.rows.first { $0.blockID == blockID }
    }

    private func ordinal(of blockID: String) -> Int {
        (model.rows.firstIndex { $0.blockID == blockID } ?? 0) + 1
    }

    // MARK: - The draggable seam (row 18 — the pane row's grammar)

    private var divider: some View {
        WorkbenchSeam(
            tokens: tokens, spaceName: Self.space, totalWidth: totalWidth,
            panelWidth: $panelWidth)
    }

    // MARK: - The tool row

    private var toolRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Text("⌕").font(tokens.small).foregroundStyle(tokens.faint)
                TextField(tokens.chromeLabel("filter blocks"), text: $filter)
                    .textFieldStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: 260)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            VoicedMenu(tokens: tokens, label: "sort: \(sortOrder.rawValue)", role: .quiet) {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Button(order.rawValue) { sortOrder = order }
                }
            }
            .help("A way of looking — nothing moves; ↑ ↓ and drags wake only in note order")
            VoicedMenu(tokens: tokens, label: "show: \(showFilter.rawValue)", role: .quiet) {
                ForEach(ShowFilter.allCases, id: \.self) { filter in
                    Button(filter.rawValue) { showFilter = filter }
                }
            }
            .help("Show only the blocks that carry the thing you're working on")
            Spacer(minLength: 8)
            // The mockup's toolrow anchor (row 36: KEEP) — the words arrive
            // with the facts; the block count is the rows'.
            Text(tokens.chromeLabel(
                model.facts.isEmpty
                    ? "\(model.rows.count) blocks"
                    : "\(model.rows.count) blocks · \(totalWords) words"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .bottom) { Divider().overlay(tokens.line) }
    }

    // MARK: - The list

    private var listColumn: some View {
        VStack(spacing: 0) {
            if !model.picked.isEmpty {
                bulkBar
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 3) {
                    ForEach(Array(displayRows().enumerated()), id: \.element.id) { i, entry in
                        workbenchRow(entry, whisper: i.isMultiple(of: 2) == false)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
            footer
        }
        .frame(minWidth: BlocksWorkbenchLayout.minimumListWidth)
    }

    /// The bulk bar — appears with the first pick (the mockup's tinted
    /// band): every act names the standing op it lands.
    private var bulkBar: some View {
        HStack(spacing: 8) {
            Text(tokens.chromeLabel(BlockSelectionCopy.bannerLabel(picked: model.picked.count)))
                .font(tokens.small)
                .fontWeight(.semibold)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
            Spacer(minLength: 6)
            Button(tokens.chromeLabel("move to top")) {
                Task { await model.movePicked(toTop: true) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            Button(tokens.chromeLabel("move to bottom")) {
                Task { await model.movePicked(toTop: false) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            Button(tokens.chromeLabel(CapabilityRegistry.capability(.mergeSelectedBlocks).verb)) {
                Task { await model.mergePicked() }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            .disabled(model.picked.count < 2)
            .help("Join the picked blocks into one, left to right — every take rides "
                + "along (the carry-all chain); the originals wait in lineage")
            // 18f batch 1 (U-4/U-16): the same two roads, in this bar's own
            // `VoicedMenu` idiom (its neighbours "tag ▾" and "move out ▾").
            VoicedMenu(
                tokens: tokens,
                label: CapabilityRegistry.capability(.mergeWithCeremony).verb,
                role: .quiet
            ) {
                ForEach(MergeArrangement.offered(blocks: max(3, model.picked.count))) { option in
                    Button(option.title(blocks: max(3, model.picked.count))) {
                        Task {
                            await model.mergePicked(
                                bringEveryTake: option == .bringEveryTake)
                        }
                    }
                }
            }
            .help(MergeArrangementCopy.bannerHelp(blocks: max(3, model.picked.count)))
            // One enablement rule for the pair of merge doors (18f ladder R1-7).
            .disabled(model.picked.count < 2)
            // 18c batch 3 (her U-6): the newline repair over the picked
            // blocks — the bulk half of the note ▾ button.
            Button(tokens.chromeLabel(SplitAtNewlinesCopy.bulkDoor)) {
                Task { await model.splitPickedAtNewlines() }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            .help(SplitAtNewlinesCopy.blockHelp)
            VoicedMenu(tokens: tokens, label: "tag ▾", role: .quiet) {
                ForEach(allTags, id: \.id) { tag in
                    Button(tag.path) { Task { await model.tagPicked(tag.id) } }
                }
                if allTags.isEmpty {
                    Text("No tags yet — make one in Settings ▸ Tags")
                }
            }
            VoicedMenu(tokens: tokens, label: "move out ▾", role: .quiet) {
                ForEach(model.pools, id: \.id) { pool in
                    Button(PoolNaming.title(pool)) {
                        Task {
                            await model.movePickedToPool(pool.id, poolTitle: pool.title)
                        }
                    }
                }
            }
            .help("Move the picked blocks out to a snippet group — they LEAVE this "
                + "note (a block lives in one place; takes go along)")
            Button(tokens.chromeLabel("archive")) {
                Task { await model.archivePicked() }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            .help("Set the picked blocks aside — kept, no clock; they wait in "
                + "\(TrayPath.menuLabel)")
            Button(tokens.chromeLabel(BlockSelectionCopy.deleteVerb(picked: model.picked.count))) {
                Task { await model.deletePicked() }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
            .help(BlockSelectionCopy.deleteHelp)
            Button(tokens.chromeLabel("clear")) { model.picked.clear() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tokens.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(tokens.accent.opacity(0.26), lineWidth: 1))
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    /// One block as an object: pick box · ordinal · two-line text · the
    /// facts line · hover-waking ↑↓⋯. Click focuses (the panel);
    /// ⌘-click picks; ⇧-click extends; double-click opens in Write.
    private func workbenchRow(_ entry: WorkbenchRows.Display, whisper: Bool) -> some View {
        let row = entry.row
        let isPicked = model.picked.contains(row.blockID)
        let isFocused = focusedBlockID == row.blockID
        return WorkbenchRowShell(
            tokens: tokens, picked: isPicked, focused: isFocused, whisper: whisper,
            onClick: { modifiers in
                if modifiers.contains(.shift) {
                    model.picked.extend(to: row.blockID, in: model.rows.map(\.blockID))
                } else if modifiers.contains(.command) {
                    model.picked.toggle(row.blockID)
                } else {
                    focusedBlockID = row.blockID
                    session.commandRouter.noteFocusedBlock(
                        row.blockID, variantID: row.variantID, postID: postID)
                }
            },
            onDoubleClick: { onJump?(row.blockID) }
        ) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    model.picked.toggle(row.blockID)
                } label: {
                    Image(systemName: isPicked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 13))
                        .foregroundStyle(isPicked ? tokens.accent : tokens.faint)
                }
                .buttonStyle(.plain)
                .padding(.top, 2)
                .help("Pick this block for a bulk act — ⌘-click the row does the "
                    + "same; ⌘⇧-click picks a whole run")
                Text(String(format: "%02d", entry.ordinal))
                    .font(tokens.mono)
                    .foregroundStyle(tokens.faint)
                    .padding(.top, 2)
                VStack(alignment: .leading, spacing: 5) {
                    Text(Queries.tocHandle(name: row.name, text: row.text))
                        .font(row.name != nil ? tokens.small.weight(.semibold) : tokens.small)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    factsLine(entry)
                }
                Spacer(minLength: 4)
                rowControls(row, ordinal: entry.ordinal)
            }
        }
        .blocksWorkbenchProbe(.row(row.blockID))
    }

    /// The facts line — real information per row (the mockup's `met` run).
    /// The TOC row's own facts show at once; the joined ones as they land.
    private func factsLine(_ entry: WorkbenchRows.Display) -> some View {
        let row = entry.row
        let facts = entry.facts
        return HStack(spacing: 8) {
            if row.hasFan {
                Text("⑂ \(facts.map { "\($0.activeVariantCount) " } ?? "")takes")
                    .foregroundStyle(tokens.ring)
            }
            if row.name != nil {
                Text(tokens.chromeLabel("named block")).foregroundStyle(tokens.faint)
            }
            if let facts {
                Text("\(facts.wordCount)w").foregroundStyle(tokens.faint)
                if facts.commentCount > 0 {
                    Text("💬 \(facts.commentCount)").foregroundStyle(tokens.commentInk)
                }
            }
            if row.variantLocked {
                // 18j: the voice's own "this one is different" slot, never a
                // literal hue. A lock is the guard that refuses edits, and
                // `alarm` is deliberately quiet rather than a stoplight (its
                // own doc) — which is exactly a lock's register. The literal
                // was an alien orange in Terminal and Study's ring hue in
                // Study, saying two different things in one app.
                Text(tokens.chromeLabel("locked")).foregroundStyle(tokens.alarm)
            }
            if let facts {
                ForEach(facts.tagPaths.prefix(3), id: \.self) { path in
                    Text("#\(path)")
                        .foregroundStyle(tokens.accent)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(
                            tokens.accent.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 4))
                }
                if let day = DisplayTitle.day(fromStamp: facts.editedAt) {
                    Text(tokens.chromeLabel("edited \(day)")).foregroundStyle(tokens.faint)
                }
            }
        }
        .font(tokens.small)
        .lineLimit(1)
    }

    private func rowControls(_ row: Queries.TOCRow, ordinal: Int) -> some View {
        HStack(spacing: 2) {
            if sortOrder.isNoteOrder {
                Button("↑") { Task { await model.move(blockID: row.blockID, up: true) } }
                    .disabled(ordinal <= 1)
                Button("↓") { Task { await model.move(blockID: row.blockID, up: false) } }
                    .disabled(ordinal >= model.rows.count)
            }
            // VX-223: the chrome pull-down — its popped rows read at menu
            // size whatever the row's mini; its frame is the mini one.
            ChromePullDown("⋯") {
                rowMenu(row, ordinal: ordinal)
            }
        }
        .controlSize(.mini)
    }

    /// The whole TOC ⋯ menu, carried — plus the workbench's own doors.
    @ViewBuilder
    private func rowMenu(_ row: Queries.TOCRow, ordinal: Int) -> some View {
        Button("Name…") {
            renameText = row.name ?? ""
            renameTarget = row
        }
        Button("Jump to block in Write") { onJump?(row.blockID) }
        Button("Block History…") {
            _ = session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(
                    postID: postID, blockID: row.blockID,
                    focusedVariantID: row.variantID))
        }
        Divider()
        Button("Move to top") { Task { await model.moveToTop(row.blockID) } }
            .disabled(ordinal == 1)
        Button("Move to bottom") { Task { await model.moveToBottom(row.blockID) } }
            .disabled(ordinal == model.rows.count)
        Button("Move to block #…") {
            moveOrdinalText = "\(ordinal)"
            moveTarget = row
        }
        Divider()
        Menu(SnippetsCopy.moveOutRow) {
            ForEach(model.pools, id: \.id) { pool in
                Button(PoolNaming.title(pool)) {
                    Task {
                        await model.moveToPool(
                            row.blockID, poolID: pool.id, poolTitle: pool.title)
                    }
                }
            }
        }
        Divider()
        Button(CapabilityRegistry.capability(.archiveBlock).verb) {
            Task { await model.archiveBlock(row.blockID) }
        }
        Button("Delete block", role: .destructive) {
            Task { await model.deleteBlock(row.blockID) }
        }
    }

    /// The footer: the tray door and the pick hint (the mockup's foot).
    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                let request = TrayRequest(postID: postID)
                if !session.commandRouter.requestNoteTray(request) {
                    trayShown = true
                }
            } label: {
                Text(tokens.chromeLabel(
                    model.tray.isEmpty
                        ? TrayPath.menuLabel
                        : "\(TrayPath.menuLabel) — \(model.tray.count) waiting"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
            .buttonStyle(.plain)
            .help("High-quality door to the tray: what this note deleted (with its "
                + "clock), what it archived, and the originals a divide or merge "
                + "preserved")
            Spacer(minLength: 4)
            Text(tokens.chromeLabel("⌘-click picks several · double-click opens in write"))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .top) { Divider().overlay(tokens.line) }
    }
}

// MARK: - The seam (row 18 — the pane row's grammar)

/// One honest line, and the grip over it — **the shared seam** (`SeamGrip`,
/// `Core/Views`: a 1-pt line, a 14-pt grip centred on it, the resize pointer
/// inside it). The drag proposes `total − x` as the panel's width, clamped
/// by `BlocksWorkbenchLayout`; the binding is the workbench's remembered
/// width. Internal so the pin can mount it alone in a real window and drag
/// it for real.
///
/// **The FIFTH copy of ledger row 9's shape, converted at the round-end
/// Fable pass (MINOR-3).** It was a 9-pt `.overlay` with `NSCursor.push()`
/// on `.onHover` and no `zIndex` — born at batch C, the very grammar
/// `SideColumn` then copied — and it survived the shell's fix (17o batch d),
/// `SideColumn`'s (18d's ladder) and the pane row's (18d round 2) because
/// every sweep searched for the FIX's vocabulary rather than the defect's
/// shape (`frame(width: 9)` found it in one grep). The host puts
/// `.zIndex(1)` on it; the arithmetic stays here.
struct WorkbenchSeam: View {
    let tokens: VoiceTokens
    let spaceName: String
    let totalWidth: CGFloat
    @Binding var panelWidth: Double
    /// A pin's own frame reporter (the GRIP's frame in `spaceName`) — nil in
    /// the app. Its own closure rather than the shared static oracle, because
    /// suites run in parallel and a workbench mounted by another suite writes
    /// the static too (the full-suite run caught a stale frame — the lesson
    /// `SeamGeometry` later learned as its subject key).
    var onFrame: ((CGRect) -> Void)? = nil

    var body: some View {
        SeamGrip(
            tokens: tokens,
            space: spaceName,
            onDrag: { location in
                guard totalWidth > 0 else { return }
                panelWidth = BlocksWorkbenchLayout.panelWidth(
                    proposed: Double(totalWidth - location.x),
                    total: Double(totalWidth))
            },
            help: "Drag to give the block panel more or less room",
            frameSpace: .named(spaceName),
            onGripFrame: { frame in onFrame?(frame) })
    }
}

// MARK: - The row shell (click modifiers + the whisper/selection washes)

/// Internal so the pin can mount one row alone in a real window and click
/// it for real (row 25's measure).
struct WorkbenchRowShell<Content: View>: View {
    let tokens: VoiceTokens
    let picked: Bool
    let focused: Bool
    let whisper: Bool
    let onClick: (EventModifiers) -> Void
    let onDoubleClick: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var hovering = false

    var body: some View {
        content()
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background, in: RoundedRectangle(cornerRadius: 9))
            .overlay(alignment: .leading) {
                if focused {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(tokens.accent)
                        .frame(width: 2)
                }
            }
            .contentShape(Rectangle())
            .onHover { hovering = $0 }
            // ONE tap handler (row 25 — the lag she felt): a count-2 gesture
            // stacked before the plain one made every single click wait out
            // the double-click interval (0.5 s on her Mac) before it was
            // delivered. The plain tap acts at ONCE; a second click on the
            // same row inside the system's interval is the double and opens
            // in Write (the first already focused the row — harmless). The
            // brain is the shared `rowClick` (`Core/Views/RowClick.swift` —
            // ladder R1-2 hoisted it here from this shell so the Library's
            // rows could stop holding their clicks too); the interval is the
            // row's own clock, never `NSApp.currentEvent.clickCount`.
            .rowClick(onClick: onClick, onDoubleClick: onDoubleClick)
    }

    private var background: AnyShapeStyle {
        if picked || focused {
            AnyShapeStyle(tokens.wash)
        } else if whisper {
            AnyShapeStyle(tokens.wash.opacity(0.45))
        } else {
            AnyShapeStyle(.clear)
        }
    }
}

// MARK: - The context panel (the focused block as an object)

private struct WorkbenchInfoPanel: View {
    let session: AppSession
    let model: BlockTOCViewModel
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): carried to the panel's live pane and to the
    /// row card's own frame, decided nowhere here.
    let indicator: EditingIndicatorStyle
    let row: Queries.WorkbenchRow
    let ordinal: Int
    let onJump: () -> Void
    let onRename: () -> Void
    let onClose: () -> Void

    @State private var takes: [Variant] = []
    @State private var savepoints = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(tokens.chromeLabel("block \(String(format: "%02d", ordinal))"))
                        .font(tokens.heading)
                        .fontWeight(.semibold)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    Spacer()
                    Button("✕") { onClose() }
                        .buttonStyle(.plain)
                        .foregroundStyle(tokens.muted)
                        .help("Close the block panel")
                }
                Text(tokens.chromeLabel(subtitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)

                // Row 26 (PROVISIONAL — her "the text is also above the
                // details"): the FACTS lead — they are what the panel adds
                // to the row; the text follows.
                Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                    factRow("words", "\(row.wordCount)")
                    if let day = DisplayTitle.day(fromStamp: row.editedAt) {
                        factRow("edited", day)
                    }
                    factRow("saved", savepoints == 1 ? "1 commit" : "\(savepoints) commits")
                    if !row.tagPaths.isEmpty {
                        factRow("tags", row.tagPaths.map { "#\($0)" }.joined(separator: " "))
                    }
                    if row.commentCount > 0 {
                        factRow("comments", "\(row.commentCount)")
                    }
                }

                // The BODY — the one editable surface of this mode (the
                // TOC's expand-to-edit, re-homed; the ONE authority).
                if let variantID = row.variantID {
                    PaneSurfaceView(
                        text: model.displayText(variantID: variantID, storeText: row.text),
                        isLive: model.liveBlockID == row.blockID && !row.variantLocked,
                        tokens: tokens,
                        indicator: indicator,
                        role: "workbench", variantID: variantID,
                        onFocusRequest: { model.makeLive(row.blockID, variantID: variantID) },
                        onEdit: { newText in
                            model.paneEdited(
                                variantID: variantID,
                                oldText: row.text ?? "", newText: newText)
                        },
                        // 17o batch b's ladder, R1-3 (the record's note (a)),
                        // scoped at RAISE-2/J20 and said exactly at round 2
                        // (R2-2): the panel's pane follows the models' entry
                        // rule (`PaneCaretLanding.entering`) — the note's
                        // CURRENT block enters where she was, else at its
                        // start; any other block keeps the shipped END
                        // (`.leave`, QUESTIONS #97). It still reports no caret
                        // (no `onSelectionChange`): a fourth reporter is a
                        // design act, not a ladder fix.
                        caretOnGoingLive: model.caretLanding(forVariant: variantID))
                        .padding(8)
                        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 8))
                        // 17o batch c (row 6): this card draws its own
                        // frame, so it CONSUMES the pane's decision rather
                        // than keeping a second rule — under `.off` and
                        // `.background` the live row wears the resting line
                        // and the pane itself carries the wash.
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    model.liveBlockID == row.blockID
                                        ? (PaneDecoration.hostRing(
                                            indicator: indicator, tokens: tokens)
                                            ?? tokens.line)
                                        : tokens.line,
                                    lineWidth: 1))
                }

                // The takes, previewed (choosing stays Takes' deliberate ✓).
                if takes.count > 1 {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(takes, id: \.id) { take in
                            HStack(alignment: .top, spacing: 8) {
                                Text(tokens.chromeLabel(
                                    take.id == row.variantID
                                        ? "✓ chosen"
                                        : (take.label ?? "take")))
                                    .font(tokens.small)
                                    .foregroundStyle(
                                        take.id == row.variantID ? tokens.chosen : tokens.faint)
                                    .lineLimit(1)
                                Text(model.displayText(
                                    variantID: take.id, storeText: take.workingText))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.ink)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(tokens.takeTint, in: RoundedRectangle(cornerRadius: 7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(tokens.takeLine, lineWidth: 1))
                        }
                    }
                }

                // The doors onward — generous, calm (W8-2).
                FlowLayoutLite(spacing: 6) {
                    Button(tokens.chromeLabel("open in write")) { onJump() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                    Button(tokens.chromeLabel("see takes")) {
                        session.commandRouter.pendingTakesLanding =
                            .bloom(postID: model.postID, blockID: row.blockID)
                        if !session.commandRouter.requestMode(.takes, postID: model.postID) {
                            session.commandRouter.pendingTakesLanding = nil
                        }
                    }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                    Button(tokens.chromeLabel("name…")) { onRename() }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                    Button(tokens.chromeLabel("history")) {
                        _ = session.commandRouter.requestBlockHistory(
                            BlockHistoryRequest(
                                postID: model.postID, blockID: row.blockID,
                                focusedVariantID: row.variantID))
                    }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                }
            }
            .padding(18)
        }
        .background(tokens.card)
        .task(id: row.blockID) {
            let read = try? await session.database.read { [blockID = row.blockID] db in
                (takes: try Queries.blockFan(db, blockID: blockID)
                    .filter { $0.deletedAt == nil && $0.status == .active },
                 saves: try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM commit_point c
                        JOIN variant v ON v.id = c.variant_id
                        WHERE v.block_id = ? AND v.deleted_at IS NULL
                        """,
                    arguments: [blockID]) ?? 0)
            }
            takes = read?.takes ?? []
            savepoints = read?.saves ?? 0
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        parts.append(row.activeVariantCount == 1 ? "1 take" : "\(row.activeVariantCount) takes")
        parts.append(row.commentCount == 1 ? "1 comment" : "\(row.commentCount) comments")
        if row.variantLocked { parts.append("locked") }
        return parts.joined(separator: " · ")
    }

    private func factRow(_ name: String, _ value: String) -> some View {
        GridRow {
            Text(tokens.chromeLabel(name))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
            Text(value)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
        }
    }
}

/// A tiny wrapping row for the panel's door buttons (four calm buttons at
/// 320pt need two lines; HStack would clip — the b6dae25 class). Leading-
/// aligned; `TrailingFlow` (Core/Views) is its right-aligned twin — a hoist
/// into one flow with an alignment parameter is the next touch's (recorded
/// at batch A's row 58 and in batch C's record).
private struct FlowLayoutLite: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let width = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(
                at: CGPoint(x: bounds.minX + x, y: bounds.minY + y),
                proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - The DEBUG oracle (rows 18/25/27/39)

/// What a workbench geometry probe reports — the slot a frame belongs to.
/// Always compiled (the modifier's signature names it); the oracle that
/// stores the frames is DEBUG-only.
enum BlocksWorkbenchProbeSlot: Hashable {
    case row(String)
    // (`.divider` RETIRED at the round-end Fable pass, MINOR-3: it wrote
    //  `BlocksWorkbenchOracle.dividerFrame`, which nothing read; the seam's
    //  frame reaches a pin through `WorkbenchSeam.onFrame`, its own closure.)
}

#if DEBUG
/// The probe, as a modifier rather than a bare `onGeometryChange`, because it
/// must READ the environment for its scope (13u2 UNIT E — row 50).
private struct BlocksWorkbenchProbe: ViewModifier {
    let slot: BlocksWorkbenchProbeSlot
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(BlocksWorkbenchView.space))
        } action: { frame in
            switch slot {
            case .row(let id):
                BlocksWorkbenchOracle.recordRow(id, frame, in: scope)
            }
        }
    }
}
#endif

extension View {
    /// The workbench oracle's DEBUG frame write, in the workbench's own
    /// named space (a `.global` read inside a macOS `ScrollView` answers in
    /// the scroll view's own space — the Read pins' measured lesson).
    @ViewBuilder
    func blocksWorkbenchProbe(_ slot: BlocksWorkbenchProbeSlot) -> some View {
        #if DEBUG
        self.modifier(BlocksWorkbenchProbe(slot: slot))
        #else
        self
        #endif
    }
}

#if DEBUG
/// The correction round's Blocks oracle (the `MastheadGeometry` pattern):
/// the mounted workbench's focused row (row 39), whether its context panel
/// stands (row 27), and its rows' and divider's frames (rows 18/25 — so a
/// pin can click and drag them for real).
///
/// **SCOPED BY THE MOUNTING SESSION** (13u2 UNIT E — KnownIssues row 50):
/// Swift Testing runs SUITES IN PARALLEL, and `rowFrames` was keyed by block
/// id, which `.incrementing` uuids make identical in every test world at
/// once. The scope travels by environment (`DebugProbeScope.swift`); a pin
/// reads its own session's.
@MainActor
enum BlocksWorkbenchOracle {
    private struct World {
        var focusedBlockID: String?
        var panelMounted = false
        var rowFrames: [String: CGRect] = [:]
        /// Row 83: when the list's first row was laid out (the arrival's
        /// first painted row) — nil until then.
        var firstRowPaintedAt: Date?
    }

    private static var worlds: [String: World] = [:]

    static func recordFocus(_ blockID: String?, in scope: String) {
        worlds[scope, default: World()].focusedBlockID = blockID
    }

    static func recordPanel(_ shown: Bool, in scope: String) {
        worlds[scope, default: World()].panelMounted = shown
    }

    static func recordRow(_ blockID: String, _ frame: CGRect, in scope: String) {
        worlds[scope, default: World()].rowFrames[blockID] = frame
        if worlds[scope]?.firstRowPaintedAt == nil {
            worlds[scope]?.firstRowPaintedAt = Date()
        }
    }

    /// A pin's OWN workbench — every read below is this session's mount.
    @MainActor
    struct Reader {
        let scope: String

        var focusedBlockID: String? { BlocksWorkbenchOracle.worlds[scope]?.focusedBlockID }
        var panelMounted: Bool { BlocksWorkbenchOracle.worlds[scope]?.panelMounted ?? false }
        var rowFrames: [String: CGRect] { BlocksWorkbenchOracle.worlds[scope]?.rowFrames ?? [:] }
        var firstRowPaintedAt: Date? { BlocksWorkbenchOracle.worlds[scope]?.firstRowPaintedAt }

        /// A pin resets before its mount — its OWN scope and no other.
        func reset() { BlocksWorkbenchOracle.worlds[scope] = nil }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}
#endif
