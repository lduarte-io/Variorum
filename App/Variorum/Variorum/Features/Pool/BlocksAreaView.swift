//
//  BlocksAreaView.swift
//  Variorum
//
//  THE SNIPPETS AREA (the type name predates the vocabulary: batch 12
//  minted it as the "Blocks area"; item 17's fifth-wave ruling made every
//  UI string say SNIPPETS, and the identifier stays per the K5 precedent —
//  strings only, code and model terms untouched).
//
//  pre-13u Act 10 wave 2b — the ruled refresh (her fourth-wave widening +
//  W8-4, the mockup's Snippets tab as the style reference):
//  · the OWNERSHIP ANSWER lives in the structure — the GROUPS RAIL lists
//    snippet groups as flat siblings (no book or note owns one; the field
//    guide's group sits beside the default as an equal);
//  · the four management doors — new group · rename · delete (the
//    ordinary deleteContainer/Trash road, its snippets riding the 30-day
//    clock with it) · move snippets between groups;
//  · search + tag/sort filters over the calm-card listing, with the W8-4
//    takes-count badge, word counts, and edited days;
//  · multi-select with a bulk bar (move / tag / archive / delete);
//  · every pre-existing door survives: open-as-editor, drag-into-note
//    (⌥ carries the fan), the drop-in import target, the footer
//    new-snippet entry with its blinking cursor, the per-row tag door.
//
//  Click model (the item-10 ruling's grammar, judged in place): a card
//  click SELECTS (the bulk bar appears); a DOUBLE-CLICK opens the
//  Snippets editor; the header's "open as editor" stays the big door.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

struct BlocksAreaView: View {
    let session: AppSession
    /// The panel/drag model — kept for `createPool` + the drag payload;
    /// the page's own listing lives on `SnippetsAreaModel`.
    let model: PoolViewModel
    /// Opens a snippet group in the detail editor — and, when the door
    /// pointed at ONE snippet, lands the caret in it (17o batch e, row 38).
    /// `SnippetOpenTarget` is the whole decision; this closure only carries
    /// it out (RootView composes it onto the pane's own navigation).
    var openSnippet: (SnippetOpenTarget) -> Void

    /// 13b 4D (N32(c) — S4-15): the snippet rows' TAG door + the archive/
    /// delete pair (the post-13l polish round, 4(b)/F1), registry-walked.
    static let surfaceCapabilities: [CapabilityID] = [
        .tagBlock, .archiveScrap, .deleteScrap,
    ]

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var area: SnippetsAreaModel
    @State private var importer: ImportModel?

    init(
        session: AppSession, model: PoolViewModel,
        openSnippet: @escaping (SnippetOpenTarget) -> Void
    ) {
        self.session = session
        self.model = model
        self.openSnippet = openSnippet
        _area = State(initialValue: SnippetsAreaModel(session: session))
    }
    @State private var entryText = ""
    @State private var cursorOn = true
    @FocusState private var entryFocused: Bool
    @State private var lastError: String?
    /// The tag sheet's target (the canvas card's exact idiom).
    @State private var tagSheetBlock: CanvasView.TagSheetBlock?

    // The listing's filters (view state — projections, never truth).
    @State private var searchText = ""
    @State private var tagFilter: String?
    @State private var sort: SnippetSort = .recent
    /// The picked snippets (block ids) — session UI state.
    @State private var selection: Set<String> = []
    /// The bulk tag menu's rows, loaded when the bar appears.
    @State private var bulkTags: [Tag] = []

    // The group doors' state.
    @State private var renameGroupTarget: Container?
    @State private var groupNameField = ""
    @State private var newGroupAsk = false
    @State private var deleteGroupAsk: GroupDeleteConfirm?

    /// What the delete-group confirm presents — the count read at ask time.
    struct GroupDeleteConfirm: Identifiable, Equatable {
        let groupID: String
        let name: String
        let snippets: Int
        var id: String { groupID }
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var filtered: [Queries.PoolItem] {
        SnippetFilter.apply(
            area.items, groupID: area.selectedGroupID, query: searchText,
            tagPath: tagFilter, sort: sort)
    }

    var body: some View {
        let area = self.area
        VStack(spacing: 0) {
            masthead(area)
            toolrow(area)
            Divider().overlay(tokens.line)
            HStack(spacing: 0) {
                rail(area)
                Divider().overlay(tokens.line)
                listing(area)
            }
        }
        .background(tokens.surface)
        .task { await area.start() }
        .sheet(item: $tagSheetBlock) { target in
            BlockTagAssignmentSheet(
                session: session, blockID: target.id, preview: target.preview,
                // Row 45's second half: this surface speaks SNIPPETS (K5).
                noun: BlockTagCopy.snippetNoun)
        }
        .alert(
            "Rename Group",
            isPresented: Binding(
                get: { renameGroupTarget != nil },
                set: { if !$0 { renameGroupTarget = nil } }),
            presenting: renameGroupTarget
        ) { group in
            TextField("Name", text: $groupNameField)
            Button("Rename") {
                let name = groupNameField
                Task { await area.renameGroup(group.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("New Group", isPresented: $newGroupAsk) {
            TextField("Name", text: $groupNameField)
            Button("Create") {
                let name = groupNameField
                Task {
                    if let id = await area.createGroup(named: name) {
                        area.select(groupID: id)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            deleteGroupAsk.map { "Delete the group \u{201C}\($0.name)\u{201D}?" } ?? "",
            isPresented: Binding(
                get: { deleteGroupAsk != nil },
                set: { if !$0 { deleteGroupAsk = nil } }),
            titleVisibility: .visible,
            presenting: deleteGroupAsk
        ) { confirm in
            Button("Delete", role: .destructive) {
                deleteGroupAsk = nil
                Task { await area.deleteGroup(confirm.groupID) }
            }
            Button("Cancel", role: .cancel) { deleteGroupAsk = nil }
        } message: { confirm in
            Text(confirm.snippets == 0
                ? "The group is empty."
                : "Its \(confirm.snippets == 1 ? "1 snippet goes" : "\(confirm.snippets) snippets go") "
                    + "to the Trash with it — \(TrashWindow.days) days to put it back.")
        }
    }

    // MARK: - Masthead + toolrow

    private func masthead(_ area: SnippetsAreaModel) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(tokens.path([SnippetsCopy.pageTitle]))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
            Text(tokens.chromeLabel(SnippetsCopy.whereLine(
                snippets: area.items.count, groups: area.pools.count)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    private func toolrow(_ area: SnippetsAreaModel) -> some View {
        HStack(spacing: 8) {
            // The mockup's squarish-rounded search field (W8-2).
            HStack(spacing: 6) {
                Text("⌕")
                    .font(tokens.body)
                    .foregroundStyle(tokens.muted)
                TextField(SnippetsCopy.searchPrompt, text: $searchText)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: 340)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            VoicedMenu(
                tokens: tokens,
                label: tagFilter.map(SnippetsCopy.tagFilter) ?? SnippetsCopy.tagAny,
                role: tagFilter == nil ? .quiet : .primary
            ) {
                Button(SnippetsCopy.tagAny) { tagFilter = nil }
                let paths = SnippetFilter.tagPaths(area.items)
                // Row 39's other half (the walk's finding): with nothing
                // tagged, this menu was one dead row — a tag-shaped control
                // on a page with no visible way to tag. It names the door
                // now, exactly as the bulk tag menu's empty case does.
                if paths.isEmpty {
                    Button(SnippetsCopy.tagNoneYet) {}.disabled(true)
                }
                ForEach(paths, id: \.self) { path in
                    Button("#\(path)") { tagFilter = path }
                }
            }
            VoicedMenu(
                tokens: tokens, label: SnippetsCopy.sortLabel(sort), role: .quiet
            ) {
                ForEach(SnippetSort.allCases, id: \.self) { option in
                    Button(option.rawValue) { sort = option }
                }
            }
            Spacer()
            if let pool = area.activePool {
                // The SCOPE door: the group she is browsing, whole, landing
                // nowhere in particular (row 38's other half — this one was
                // always right, and stays exactly as it was).
                Button(tokens.chromeLabel(SnippetsCopy.openAsEditor)) {
                    openSnippet(.group(pool))
                }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                    .help("This group in the full editor — type, split, fan takes")
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }

    // MARK: - The groups rail (the ownership answer, structurally)

    private func rail(_ area: SnippetsAreaModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            CalmSectionHeader(tokens: tokens, title: SnippetsCopy.groupsHeader)
                .help("Groups are free-standing — no book or note owns one. "
                    + "A snippet lives in exactly one group; tags are labels it can wear many of.")
            railRow(
                name: SnippetsCopy.allGroups,
                count: area.items.count,
                selected: area.selectedGroupID == nil
            ) {
                area.select(groupID: nil)
                selection = []
            }
            ForEach(area.pools, id: \.id) { pool in
                groupRow(area, pool: pool)
            }
            Spacer(minLength: 8)
            Button(tokens.chromeLabel(SnippetsCopy.newGroup)) {
                groupNameField = ""
                newGroupAsk = true
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(width: 196)
    }

    private func groupRow(_ area: SnippetsAreaModel, pool: Container) -> some View {
        railRow(
            name: PoolNaming.title(pool),
            count: area.counts[pool.id] ?? 0,
            selected: area.selectedGroupID == pool.id
        ) {
            area.select(groupID: pool.id)
            selection = []
        }
        .contextMenu { groupMenu(area, pool: pool) }
        .overlay(alignment: .trailing) {
            Menu {
                groupMenu(area, pool: pool)
            } label: {
                Text("⋯")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
            // states its own line policy, so its IDEAL width can never be a
            // wrapped one (the b6dae25 class's window-sizing hazard).
            .lineLimit(1)
            .fixedSize()
            .padding(.trailing, 4)
        }
    }

    @ViewBuilder
    private func groupMenu(_ area: SnippetsAreaModel, pool: Container) -> some View {
        Button(SnippetsCopy.renameGroupRow) {
            groupNameField = pool.title == "Pool" ? "" : (pool.title ?? "")
            renameGroupTarget = pool
        }
        Button(SnippetsCopy.newGroupRow) {
            groupNameField = ""
            newGroupAsk = true
        }
        Divider()
        // The ruled delete door — the menu line says where its snippets go
        // (the mockup's caption, held to what is TRUE: the Trash road; no
        // ⌥⌘Z claim, deleteContainer registers no structural undo).
        Button("\(SnippetsCopy.deleteGroupRow) \u{2014} \(SnippetsCopy.deleteGroupCaption)",
               role: .destructive)
        {
            let name = PoolNaming.title(pool)
            Task {
                let count = await area.snippetCount(in: pool.id)
                deleteGroupAsk = GroupDeleteConfirm(
                    groupID: pool.id, name: name, snippets: count)
            }
        }
    }

    private func railRow(
        name: String, count: Int, selected: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(name))
                    .font(tokens.small)
                    .foregroundStyle(selected ? tokens.accent : tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text("\(count)")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .padding(.trailing, 14)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear),
                in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - The listing

    private func listing(_ area: SnippetsAreaModel) -> some View {
        VStack(spacing: 0) {
            if !selection.isEmpty {
                bulkBar(area)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(filtered, id: \.block.blockID) { item in
                        card(area, item)
                            // 13s-b U2: the leg's last stop points at the
                            // first snippet the area shows.
                            .tourAnchor(
                                item.block.blockID == filtered.first?.block.blockID
                                    ? .firstSnippetCard : nil,
                                cornerRadius: 9)
                    }
                    if filtered.isEmpty {
                        // An empty SCOPE with no filters typed is an empty
                        // listing, not a failed search (caught in the wave's
                        // own dev walk: a fresh group read "Nothing matches.").
                        Text(tokens.chromeLabel(
                            searchText.isEmpty && tagFilter == nil
                                ? SnippetsCopy.emptyListing : SnippetsCopy.emptySearch))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
            }
            .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
                dropIn(area, providers)
            }
            if let line = area.receipt ?? area.lastError ?? model.receipt ?? model.lastError {
                Text(tokens.chromeLabel(line))
                    .font(tokens.small)
                    .foregroundStyle(
                        (area.receipt ?? model.receipt) != nil ? tokens.muted : tokens.alarm)
                    // lineLimit beside fixedSize in chrome (the b6dae25 class).
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 6)
                    .textSelection(.enabled)
            }
            dropzone(area)
            entryBar(area)
        }
    }

    private func bulkBar(_ area: SnippetsAreaModel) -> some View {
        HStack(spacing: 8) {
            Text(tokens.chromeLabel(SnippetsCopy.selectedLine(selection.count)))
                .font(tokens.small)
                .fontWeight(.semibold)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            VoicedMenu(tokens: tokens, label: SnippetsCopy.bulkMove) {
                ForEach(area.pools, id: \.id) { pool in
                    Button(PoolNaming.title(pool)) {
                        let picked = orderedSelection()
                        selection = []
                        Task { await area.moveSnippets(picked, to: pool.id) }
                    }
                }
            }
            VoicedMenu(tokens: tokens, label: SnippetsCopy.bulkTag) {
                if bulkTags.isEmpty {
                    Button("No tags yet — create one in Settings") {}.disabled(true)
                }
                ForEach(bulkTags, id: \.id) { tag in
                    Button(tag.path) {
                        let picked = orderedSelection()
                        Task { await area.applyTag(tag.id, to: picked) }
                    }
                }
            }
            Spacer()
            Button(tokens.chromeLabel(SnippetsCopy.bulkArchive)) {
                let picked = orderedSelection()
                selection = []
                Task { await area.archiveSnippets(picked) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            Button(tokens.chromeLabel(SnippetsCopy.bulkDelete)) {
                let picked = orderedSelection()
                selection = []
                Task { await area.deleteSnippets(picked) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
            Button(tokens.chromeLabel(SnippetsCopy.bulkClear)) { selection = [] }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(tokens.card)
        .task { bulkTags = await area.allTags() }
    }

    /// The selection in LISTING order — bulk acts land in the order she
    /// sees, not set order.
    private func orderedSelection() -> [String] {
        filtered.map(\.block.blockID).filter(selection.contains)
    }

    private func card(_ area: SnippetsAreaModel, _ item: Queries.PoolItem) -> some View {
        let picked = selection.contains(item.block.blockID)
        return CalmCard(tokens: tokens, selected: picked) {
            HStack(alignment: .top, spacing: 10) {
                Text(picked ? "✓" : "○")
                    .font(tokens.small)
                    .foregroundStyle(picked ? tokens.accent : tokens.faint)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 4) {
                    Text(preview(item))
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                    HStack(spacing: 6) {
                        // 17o batch e (row 39) — THE CHIP IS THE DOOR. Her
                        // words: *"you can't tag snippets but there's a tag
                        // on there. so not sure what the deal with that
                        // is."* Tagging a snippet has always been possible
                        // (block tags are the model's, and "block-level tags
                        // primarily serve the pool" — AppSpec §7); the ONE
                        // door was buried in the right-click menu, so a tag
                        // she could SEE read as decoration. Same act, same
                        // sheet, one more face — where the tag already is.
                        ForEach(item.tagPaths, id: \.self) { path in
                            Button {
                                tagSheetBlock = CanvasView.TagSheetBlock(
                                    id: item.block.blockID, preview: item.block.text)
                            } label: {
                                Text("#\(path)")
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.accent.opacity(0.85))
                                    .lineLimit(1)
                            }
                            .buttonStyle(.plain)
                            .help(SnippetsCopy.tagChipHelp)
                        }
                        let edited = SnippetCardFace.editedPart(updatedAt: item.updatedAt)
                        ForEach(
                            SnippetCardFace.metadata(
                                activeTakes: item.block.activeVariantCount,
                                text: item.block.text,
                                updatedAt: item.updatedAt),
                            id: \.self
                        ) { part in
                            Text(tokens.chromeLabel(part))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                                // VX-351: the edited part hovers its whole fact.
                                .stampHelp(part == edited
                                    ? SnippetCardFace.editedHelp(updatedAt: item.updatedAt) : nil)
                        }
                        // The all-groups view says which group each row
                        // lives in — context only where it adds anything.
                        if area.selectedGroupID == nil, area.pools.count > 1,
                           let home = area.pools.first(where: { $0.id == item.poolID })
                        {
                            Text(tokens.chromeLabel("in \(PoolNaming.title(home))"))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                        }
                    }
                }
                Spacer(minLength: 6)
                Text("⣿")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .help("Drag into an open editor — a copy with lineage; ⌥ carries the whole fan")
            }
        }
        .contentShape(Rectangle())
        .onDrag { PoolViewModel.dragProvider(blockID: item.block.blockID) }
        .onTapGesture(count: 2) {
            openSnippet(.card(item))
        }
        .onTapGesture { toggle(item.block.blockID) }
        .contextMenu { cardMenu(area, item) }
    }

    @ViewBuilder
    private func cardMenu(_ area: SnippetsAreaModel, _ item: Queries.PoolItem) -> some View {
        Button(SnippetsCopy.openRow) {
            openSnippet(.card(item))
        }
        Button(SnippetsCopy.tagsRow) {
            tagSheetBlock = CanvasView.TagSheetBlock(
                id: item.block.blockID, preview: item.block.text)
        }
        if area.pools.count > 1 {
            Menu(SnippetsCopy.moveRow) {
                ForEach(area.pools.filter { $0.id != item.poolID }, id: \.id) { pool in
                    Button(PoolNaming.title(pool)) {
                        Task { await area.moveSnippets([item.block.blockID], to: pool.id) }
                    }
                }
            }
        }
        Divider()
        // Ledger row 14 (F1): archive rides beside delete, kept road first.
        Button(CapabilityRegistry.capability(.archiveScrap).menuTitle()) {
            Task { await model.archiveScrap(item.block.blockID) }
        }
        // Ledger row 4(b): ordinary move-to-Trash, no confirm (13j's rule:
        // notes confirm, blocks and takes do not).
        Button(
            CapabilityRegistry.capability(.deleteScrap).menuTitle(),
            role: .destructive
        ) {
            Task { await model.deleteScrap(item.block.blockID) }
        }
    }

    private func toggle(_ blockID: String) {
        if selection.contains(blockID) {
            selection.remove(blockID)
        } else {
            selection.insert(blockID)
        }
    }

    private func dropIn(_ area: SnippetsAreaModel, _ providers: [NSItemProvider]) -> Bool {
        guard let pool = area.activePool ?? model.activePool else { return false }
        let importModel = importer ?? ImportModel(session: session)
        importer = importModel
        return importModel.handleDrop(providers, into: .pool(pool.id))
    }

    private func dropzone(_ area: SnippetsAreaModel) -> some View {
        Text(tokens.chromeLabel(SnippetsCopy.dropTarget))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        tokens.line, style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
            .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
                dropIn(area, providers)
            }
    }

    /// The standalone-snippet entry (the quick-entry idiom): ⏎ mints ONE
    /// block in the selected group — born standalone, never appended to a
    /// note.
    private func entryBar(_ area: SnippetsAreaModel) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Divider().overlay(tokens.line)
            Text(tokens.chromeLabel(SnippetsCopy.entryCue))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.top, 10)
            HStack(spacing: 2) {
                TextField("", text: $entryText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .focused($entryFocused)
                    .lineLimit(1...4)
                    .onSubmit { submit(area) }
                if tokens.showsBlockCursor && entryText.isEmpty && !entryFocused {
                    Rectangle()
                        .fill(tokens.accent)
                        .frame(width: 8, height: 16)
                        .opacity(cursorOn ? 1 : 0)
                        .task {
                            while !Task.isCancelled {
                                try? await Task.sleep(for: .milliseconds(550))
                                cursorOn.toggle()
                            }
                        }
                }
                Spacer()
            }
            .padding(.bottom, lastError == nil ? 12 : 2)
            if let lastError {
                // lineLimit is LOAD-BEARING beside fixedSize in bottom
                // chrome (the wedged-window class rule).
                Text(lastError)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 8)
            }
        }
        .padding(.horizontal, 18)
        .background(tokens.card)
        .onTapGesture { entryFocused = true }
    }

    private func preview(_ item: Queries.PoolItem) -> String {
        let text = item.block.text ?? ""
        return text.isEmpty ? "(empty snippet)" : text
    }

    private func submit(_ area: SnippetsAreaModel) {
        let text = entryText
        entryText = ""
        lastError = nil
        Task {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            var poolID = area.activePool?.id ?? model.activePool?.id
            if poolID == nil { poolID = await model.createPool() }
            guard let poolID else {
                lastError = "No snippets group could be created."
                return
            }
            do {
                _ = try await session.runner.run { ops in
                    try ops.newBlock(in: poolID, text: text)
                }
            } catch {
                lastError = "New snippet refused: \(error)"
            }
        }
    }
}
