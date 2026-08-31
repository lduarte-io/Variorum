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
//  panel for the focused block (its text — editable through the ONE
//  `PaneTextAuthority` — its facts, its takes, and the doors onward:
//  Write, Takes, the Block History pane, the tray). The name "Blocks"
//  stays, as ruled.
//
//  Every door of the retired TOC page survives here: expand-to-edit (the
//  panel's body), ↑↓, the whole ⋯ menu (name · jump · move to
//  top/bottom/# · move out to snippets · archive · delete), the tray
//  door. The bulk acts are the standing ops under the standing compound
//  shapes (delete = ONE ⌥⌘Z entry; merge = the carry-all chain — the
//  shared brains, the third door of the same act).
//

import GRDB  // the panel's savepoint count (one bounded read)
import SwiftUI
import VariorumCore

struct BlocksWorkbenchView: View {
    /// The declared row-menu acts (P-1's declared ⇔ rendered walk) — the
    /// TOC pair plus the bulk bar's compound pair (the Takes board's own
    /// declared ids, rendered here as the workbench's bulk doors).
    static let surfaceCapabilities: [CapabilityID] = [
        .archiveBlock, .deleteBlock, .mergeSelectedBlocks, .deleteSelectedBlocks,
    ]

    let session: AppSession
    let postID: String
    var onJump: ((String) -> Void)?

    @State private var model: BlockTOCViewModel
    /// The context panel's subject — a plain click names it (item 10's
    /// click model applied in place: body click focuses, ⌘-click picks).
    @State private var focusedBlockID: String?
    @State private var filter = ""
    @State private var showFilter: ShowFilter = .all
    @State private var sortOrder: SortOrder = .noteOrder
    @State private var seeded = false
    @State private var renameTarget: Queries.WorkbenchRow?
    @State private var renameText = ""
    @State private var moveTarget: Queries.WorkbenchRow?
    @State private var moveOrdinalText = ""
    @State private var trayShown = false
    @State private var allTags: [Tag] = []
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    init(
        session: AppSession, postID: String,
        onJump: ((String) -> Void)? = nil, model: BlockTOCViewModel? = nil
    ) {
        self.session = session
        self.postID = postID
        self.onJump = onJump
        _model = State(initialValue: model ?? BlockTOCViewModel(session: session, postID: postID))
    }

    // MARK: - Ways of looking (view-local postures, never persisted)

    enum ShowFilter: String, CaseIterable {
        case all = "all"
        case withTakes = "with takes"
        case withComments = "with comments"
        case locked = "locked"
        case tagged = "tagged"

        func admits(_ row: Queries.WorkbenchRow) -> Bool {
            switch self {
            case .all: true
            case .withTakes: row.hasFan
            case .withComments: row.commentCount > 0
            case .locked: row.variantLocked
            case .tagged: !row.tagPaths.isEmpty
            }
        }
    }

    enum SortOrder: String, CaseIterable {
        case noteOrder = "note order"
        case recentlyEdited = "recently edited"
        case longest = "longest"

        /// Only note order can honestly host the reorder doors — a sorted
        /// listing is a way of looking, and ↑↓ there would lie.
        var isNoteOrder: Bool { self == .noteOrder }
    }

    /// One display row: the fact row + its 1-based note ordinal (derived
    /// once per pass — never a per-row index walk).
    private struct DisplayRow: Identifiable {
        let row: Queries.WorkbenchRow
        let ordinal: Int
        var id: String { row.placementID }
    }

    private func displayRows() -> [DisplayRow] {
        let needle = filter.trimmingCharacters(in: .whitespaces)
        var rows = model.facts.enumerated().map { i, row in
            DisplayRow(row: row, ordinal: i + 1)
        }
        if !needle.isEmpty {
            rows = rows.filter { entry in
                let handle = Queries.tocHandle(name: entry.row.name, text: entry.row.text)
                return handle.localizedCaseInsensitiveContains(needle)
                    || (entry.row.text?.localizedCaseInsensitiveContains(needle) ?? false)
                    || entry.row.tagPaths.contains {
                        $0.localizedCaseInsensitiveContains(needle)
                    }
            }
        }
        rows = rows.filter { showFilter.admits($0.row) }
        switch sortOrder {
        case .noteOrder:
            break
        case .recentlyEdited:
            rows.sort { ($0.row.editedAt ?? "") > ($1.row.editedAt ?? "") }
        case .longest:
            rows.sort { $0.row.wordCount > $1.row.wordCount }
        }
        return rows
    }

    private var totalWords: Int {
        model.facts.reduce(0) { $0 + $1.wordCount }
    }

    var body: some View {
        VStack(spacing: 0) {
            toolRow
            HStack(spacing: 0) {
                listColumn
                if let focusedBlockID,
                   let row = model.facts.first(where: { $0.blockID == focusedBlockID }) {
                    Divider().overlay(tokens.line)
                    WorkbenchInfoPanel(
                        session: session, model: model, tokens: tokens,
                        row: row,
                        onJump: { onJump?(row.blockID) },
                        onRename: {
                            renameText = row.name ?? ""
                            renameTarget = row
                        },
                        onClose: { self.focusedBlockID = nil })
                        .frame(width: 320)
                        .id("wb-panel-\(row.blockID)")
                }
            }
        }
        .background(tokens.surface)
        .task { await model.start() }
        .task { await model.startFacts() }
        .task { await model.startTray() }
        .task { await model.startPools() }
        .task { allTags = (try? await session.database.read { try Queries.allTags($0) }) ?? [] }
        .onDisappear { model.teardown() }
        .onChange(of: model.facts) { _, facts in
            guard !seeded, !facts.isEmpty else {
                // The panel's subject can die under it (deleted in another
                // window) — close rather than showing a ghost.
                if let focusedBlockID,
                   !facts.contains(where: { $0.blockID == focusedBlockID }) {
                    self.focusedBlockID = nil
                }
                return
            }
            seeded = true
            let fact = session.commandRouter.focusedBlock
            if fact?.postID == postID,
               let id = fact?.blockID, facts.contains(where: { $0.blockID == id }) {
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
            "Move to block # (of \(model.facts.count))",
            isPresented: Binding(
                get: { moveTarget != nil },
                set: { if !$0 { moveTarget = nil } }),
            presenting: moveTarget
        ) { row in
            TextField("Position (1–\(model.facts.count))", text: $moveOrdinalText)
            Button("Move") {
                let raw = moveOrdinalText.trimmingCharacters(in: .whitespaces)
                Task {
                    if let target = Int(raw) {
                        await model.move(blockID: row.blockID, toOrdinal: target)
                    } else {
                        model.speak("\u{201C}\(raw)\u{201D} isn't a position number — type 1 to \(model.facts.count).")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
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
            Text(tokens.chromeLabel("\(model.facts.count) blocks · \(totalWords) words"))
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
    private func workbenchRow(_ entry: DisplayRow, whisper: Bool) -> some View {
        let row = entry.row
        let isPicked = model.picked.contains(row.blockID)
        let isFocused = focusedBlockID == row.blockID
        return WorkbenchRowShell(
            tokens: tokens, picked: isPicked, focused: isFocused, whisper: whisper,
            onClick: { modifiers in
                if modifiers.contains(.shift) {
                    model.picked.extend(to: row.blockID, in: model.facts.map(\.blockID))
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
                    factsLine(row)
                }
                Spacer(minLength: 4)
                rowControls(row, ordinal: entry.ordinal)
            }
        }
    }

    /// The facts line — real information per row (the mockup's `met` run).
    private func factsLine(_ row: Queries.WorkbenchRow) -> some View {
        HStack(spacing: 8) {
            if row.hasFan {
                Text("⑂ \(row.activeVariantCount) takes")
                    .foregroundStyle(tokens.ring)
            }
            if row.name != nil {
                Text(tokens.chromeLabel("named block")).foregroundStyle(tokens.faint)
            }
            Text("\(row.wordCount)w").foregroundStyle(tokens.faint)
            if row.commentCount > 0 {
                Text("💬 \(row.commentCount)").foregroundStyle(tokens.commentInk)
            }
            if row.variantLocked {
                Text(tokens.chromeLabel("locked")).foregroundStyle(Color.orange)
            }
            ForEach(row.tagPaths.prefix(3), id: \.self) { path in
                Text("#\(path)")
                    .foregroundStyle(tokens.accent)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(
                        tokens.accent.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 4))
            }
            if let day = DisplayTitle.day(fromStamp: row.editedAt) {
                Text(tokens.chromeLabel("edited \(day)")).foregroundStyle(tokens.faint)
            }
        }
        .font(tokens.small)
        .lineLimit(1)
    }

    private func rowControls(_ row: Queries.WorkbenchRow, ordinal: Int) -> some View {
        HStack(spacing: 2) {
            if sortOrder.isNoteOrder {
                Button("↑") { Task { await model.move(blockID: row.blockID, up: true) } }
                    .disabled(ordinal <= 1)
                Button("↓") { Task { await model.move(blockID: row.blockID, up: false) } }
                    .disabled(ordinal >= model.facts.count)
            }
            Menu("⋯") {
                rowMenu(row, ordinal: ordinal)
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .controlSize(.mini)
    }

    /// The whole TOC ⋯ menu, carried — plus the workbench's own doors.
    @ViewBuilder
    private func rowMenu(_ row: Queries.WorkbenchRow, ordinal: Int) -> some View {
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
            .disabled(ordinal == model.facts.count)
        Button("Move to block #…") {
            moveOrdinalText = "\(ordinal)"
            moveTarget = row
        }
        Divider()
        Menu("Move out to snippets (leaves this note)") {
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

// MARK: - The row shell (click modifiers + the whisper/selection washes)

private struct WorkbenchRowShell<Content: View>: View {
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
            // ONE tap handler reading the keyboard's live modifier state
            // (the walk caught the stacked `.modifiers(...)` TapGestures
            // dead-stalling every click on the row — the gesture graph
            // waits on the unmet modifier requirements instead of failing
            // them; the codebase idiom is count-2 + plain, chords read at
            // the event).
            .onTapGesture(count: 2) { onDoubleClick() }
            .onTapGesture {
                let flags = NSEvent.modifierFlags
                var mods: EventModifiers = []
                if flags.contains(.command) { mods.insert(.command) }
                if flags.contains(.shift) { mods.insert(.shift) }
                onClick(mods)
            }
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
    let row: Queries.WorkbenchRow
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

                // The BODY — the one editable surface of this mode (the
                // TOC's expand-to-edit, re-homed; the ONE authority).
                if let variantID = row.variantID {
                    PaneSurfaceView(
                        text: model.displayText(variantID: variantID, storeText: row.text),
                        isLive: model.liveBlockID == row.blockID && !row.variantLocked,
                        tokens: tokens,
                        role: "workbench", variantID: variantID,
                        onFocusRequest: { model.makeLive(row.blockID, variantID: variantID) },
                        onEdit: { newText in
                            model.paneEdited(
                                variantID: variantID,
                                oldText: row.text ?? "", newText: newText)
                        })
                        .padding(8)
                        .background(tokens.surface, in: RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    model.liveBlockID == row.blockID
                                        ? tokens.ring : tokens.line,
                                    lineWidth: 1))
                }

                // The facts grid.
                Grid(alignment: .leading, horizontalSpacing: 14, verticalSpacing: 6) {
                    factRow("words", "\(row.wordCount)")
                    if let day = DisplayTitle.day(fromStamp: row.editedAt) {
                        factRow("edited", day)
                    }
                    factRow("saved", savepoints == 1 ? "1 savepoint" : "\(savepoints) savepoints")
                    if !row.tagPaths.isEmpty {
                        factRow("tags", row.tagPaths.map { "#\($0)" }.joined(separator: " "))
                    }
                    if row.commentCount > 0 {
                        factRow("comments", "\(row.commentCount)")
                    }
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

    private var ordinal: Int {
        (model.facts.firstIndex { $0.blockID == row.blockID } ?? 0) + 1
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
/// 320pt need two lines; HStack would clip — the b6dae25 class).
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
