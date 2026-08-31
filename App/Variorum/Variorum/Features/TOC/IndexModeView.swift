//
//  IndexModeView.swift
//  Variorum
//
//  pre-13u Act 10 wave 2c — **INDEX, the new mode** (item 16, W8-1; her
//  ruling verbatim: "index page - obviously a need, seems more fundamental,
//  let's put it in under Takes", confirmed as a NEW MODE TAB). The
//  block-TOC idea grown up to the mockup's direction A: a standing index
//  column — markdown headings become SECTIONS (`NoteIndexOutline`, the
//  pure brain), everything else nests under the most recent heading, a
//  heading-less note reads honestly FLAT — beside a rendered reading pane
//  that scroll-syncs to the selected block.
//
//  Position tracking (her "index tracks position with take / write /
//  probably block too"): the EXISTING mechanism, extended, never a new
//  one — `CommandRouter.focusedBlock` is the fact Write and Takes already
//  report; Index SEEDS its selection from it on arrival and REPORTS its
//  own selection back through the same door. The Read mode's click-through
//  lands here the same way (note the fact, switch the mode, seed from the
//  fact) — the scrolled-open-door shape 13u item 17's book-side jump and
//  13i's Book Panel click-through will reuse.
//
//  Liveness: the ONE `PaneTextAuthority` via the shared
//  `BlockTOCViewModel` — an expanded row's editing card is the same
//  read-cheap→live upgrade the TOC always had (P-3; no second mechanism).
//  The reading pane is a PROJECTION TIER: SwiftUI `Text` over
//  `FlowParagraph`, virtualized per block (P1) — no TK2 geometry anywhere
//  in the scroll-sync (TEXTKIT2 §2's risk family deliberately avoided).
//

import SwiftUI
import VariorumCore

struct IndexModeView: View {
    /// The row menu's declared acts — the TOC's pair, carried (the listing
    /// menu's archive/delete family; declared ⇔ rendered).
    static let surfaceCapabilities: [CapabilityID] = [.archiveBlock, .deleteBlock]

    let session: AppSession
    let postID: String
    /// "Jump to block in write" — the detail switches to Write with the
    /// caret seeded (the standing hybrid primitive).
    var onJump: ((String) -> Void)?

    @State private var model: BlockTOCViewModel
    @State private var selectedBlockID: String?
    /// Section heads whose kids are folded away (session-only view state).
    @State private var collapsedSections: Set<String> = []
    @State private var filter = ""
    /// The pane's scroll request — set on COLUMN selection and on the
    /// arrival seed, never on a pane click (clicking what you can see must
    /// not move it under you).
    @State private var paneTarget: String?
    @State private var seeded = false
    @State private var totalWords = 0
    @State private var renameTarget: Queries.TOCRow?
    @State private var renameText = ""
    @State private var moveTarget: Queries.TOCRow?
    @State private var moveOrdinalText = ""
    @State private var trayShown = false
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

    // MARK: - Derived structure

    private var outline: NoteIndexOutline.Outline {
        NoteIndexOutline.outline(of: model.rows.map { ($0.blockID, $0.text) })
    }

    private var rowsByID: [String: Queries.TOCRow] {
        Dictionary(uniqueKeysWithValues: model.rows.map { ($0.blockID, $0) })
    }

    /// One flattened column row (sections and kids interleaved, collapse
    /// and filter applied) — so the LazyVStack virtualizes a long note.
    private struct ColumnRow: Identifiable {
        let row: NoteIndexOutline.Row
        let isSection: Bool
        let headingLevel: Int?
        let kidCount: Int
        let nested: Bool
        var id: String { row.blockID }
    }

    private func columnRows() -> [ColumnRow] {
        let needle = filter.trimmingCharacters(in: .whitespaces)
        let byID = rowsByID
        func matches(_ blockID: String) -> Bool {
            guard !needle.isEmpty else { return true }
            guard let row = byID[blockID] else { return false }
            let handle = Queries.tocHandle(name: row.name, text: row.text)
            return handle.localizedCaseInsensitiveContains(needle)
                || (row.text?.localizedCaseInsensitiveContains(needle) ?? false)
        }
        var result: [ColumnRow] = []
        for group in outline.groups {
            let kidMatches = group.rows.filter { matches($0.blockID) }
            if let head = group.head {
                let headMatches = matches(head.blockID)
                guard headMatches || !kidMatches.isEmpty else { continue }
                result.append(ColumnRow(
                    row: head, isSection: true, headingLevel: group.headingLevel,
                    kidCount: group.rows.count, nested: false))
                if !collapsedSections.contains(head.blockID) {
                    let kids = needle.isEmpty ? group.rows : kidMatches
                    result.append(contentsOf: kids.map {
                        ColumnRow(row: $0, isSection: false, headingLevel: nil,
                                  kidCount: 0, nested: true)
                    })
                }
            } else {
                result.append(contentsOf: kidMatches.map {
                    ColumnRow(row: $0, isSection: false, headingLevel: nil,
                              kidCount: 0, nested: false)
                })
            }
        }
        return result
    }

    var body: some View {
        HStack(spacing: 0) {
            indexColumn
                .frame(width: 360)
            Divider().overlay(tokens.line)
            IndexReadingPane(
                model: model, tokens: tokens,
                selectedBlockID: selectedBlockID,
                paneTarget: $paneTarget,
                onSelect: { blockID in select(blockID, scrollPane: false) })
        }
        .background(tokens.surface)
        .task { await model.start() }
        .task { await model.startTray() }
        .task { await model.startPools() }
        .onDisappear { model.teardown() }
        .onChange(of: model.rows) { _, rows in
            totalWords = rows.reduce(0) { $0 + Queries.wordCount($1.text ?? "") }
            guard !seeded, !rows.isEmpty else { return }
            seeded = true
            // Arrive where she was (the router's fact — Write's caret,
            // Takes' live pane, Read's clicked sentence).
            let fact = session.commandRouter.focusedBlock
            let landing = (fact?.postID == postID ? fact?.blockID : nil)
                .flatMap { id in rows.contains { $0.blockID == id } ? id : nil }
            select(landing ?? rows[0].blockID, scrollPane: true, report: false)
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
                        model.speak("\u{201C}\(raw)\u{201D} isn't a position number — type 1 to \(model.rows.count).")
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func select(_ blockID: String, scrollPane: Bool, report: Bool = true) {
        selectedBlockID = blockID
        if scrollPane { paneTarget = blockID }
        if report {
            session.commandRouter.noteFocusedBlock(
                blockID, variantID: rowsByID[blockID]?.variantID, postID: postID)
        }
    }

    // MARK: - The index column

    private var indexColumn: some View {
        VStack(alignment: .leading, spacing: 0) {
            columnHeader
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(columnRows()) { entry in
                            if entry.isSection {
                                sectionRow(entry)
                            } else {
                                blockRow(entry)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .onChange(of: paneTarget) { _, target in
                    // The seed also lands the COLUMN on its row (a long
                    // note's landing must be visible on both sides).
                    guard let target else { return }
                    proxy.scrollTo("ixr-\(target)", anchor: .center)
                }
            }
            columnFooter
        }
        .background(tokens.surface)
    }

    private var columnHeader: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Text("⌕")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                TextField(tokens.chromeLabel("filter this note"), text: $filter)
                    .textFieldStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            if !outline.isFlat {
                Button(tokens.chromeLabel(
                    collapsedSections.isEmpty ? "collapse all" : "expand all")
                ) {
                    if collapsedSections.isEmpty {
                        collapsedSections = Set(
                            outline.groups.compactMap { $0.head?.blockID })
                    } else {
                        collapsedSections = []
                    }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Fold every section down to its heading — and back")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }

    /// A section head: fold chevron + ordinal + the heading's own words +
    /// its kid count. Selecting it syncs the pane like any row.
    private func sectionRow(_ entry: ColumnRow) -> some View {
        let row = rowsByID[entry.row.blockID]
        let folded = collapsedSections.contains(entry.row.blockID)
        let title = row.flatMap { r -> String? in
            let heading = NoteIndexOutline.headingTitle(of: r.text)
            return heading.isEmpty ? nil : heading
        } ?? Queries.tocHandle(name: row?.name, text: row?.text)
        return IndexColumnRow(
            tokens: tokens,
            selected: selectedBlockID == entry.row.blockID,
            content: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Button(folded ? "▸" : "▾") {
                        if folded {
                            collapsedSections.remove(entry.row.blockID)
                        } else {
                            collapsedSections.insert(entry.row.blockID)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .help(folded ? "Unfold this section" : "Fold this section to its heading")
                    Text(String(format: "%02d", entry.row.ordinal))
                        .font(tokens.mono)
                        .foregroundStyle(tokens.faint)
                    Text(title)
                        .font(tokens.heading)
                        .fontWeight(.semibold)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Text("\(entry.kidCount)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                }
                .padding(.top, 10)
                .padding(.bottom, 3)
            },
            trailing: { rowControls(for: entry.row.blockID, ordinal: entry.row.ordinal) },
            onSelect: { select(entry.row.blockID, scrollPane: true) })
            .id("ixr-\(entry.row.blockID)")
    }

    /// An ordinary row: expand-to-edit chevron + ordinal + the read-time
    /// handle + fan/lock marks; controls wake on hover (the mockup's calm).
    @ViewBuilder
    private func blockRow(_ entry: ColumnRow) -> some View {
        if let row = rowsByID[entry.row.blockID] {
            let isExpanded = model.expanded.contains(row.blockID)
            VStack(alignment: .leading, spacing: 3) {
                IndexColumnRow(
                    tokens: tokens,
                    selected: selectedBlockID == row.blockID,
                    content: {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Button(isExpanded ? "▾" : "▸") {
                                model.toggleExpanded(row.blockID)
                            }
                            .buttonStyle(.plain)
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .help(isExpanded
                                ? "Close this block's editing card"
                                : "Open this block right here — one block is live at a time")
                            Text(String(format: "%02d", entry.row.ordinal))
                                .font(tokens.mono)
                                .foregroundStyle(tokens.faint)
                            Text(Queries.tocHandle(name: row.name, text: row.text))
                                .font(row.name != nil ? tokens.small.weight(.semibold) : tokens.small)
                                .foregroundStyle(tokens.ink)
                                .lineLimit(1)
                            if row.hasFan {
                                Text("⑂").font(tokens.small).foregroundStyle(tokens.ring)
                            }
                            if row.variantLocked {
                                Text(tokens.chromeLabel("locked"))
                                    .font(tokens.small)
                                    .foregroundStyle(Color.orange)
                            }
                            Spacer(minLength: 4)
                        }
                        .padding(.vertical, 4)
                        .padding(.leading, entry.nested ? 14 : 0)
                    },
                    trailing: { rowControls(for: row.blockID, ordinal: entry.row.ordinal) },
                    onSelect: { select(row.blockID, scrollPane: true) })
                    .id("ixr-\(row.blockID)")
                if isExpanded {
                    editingCard(row)
                        .padding(.leading, entry.nested ? 34 : 20)
                }
            }
        }
    }

    /// The expanded editing card — the TOC's read-cheap→live upgrade,
    /// voice-styled (W8-2's calm card grammar around the one pane surface).
    @ViewBuilder
    private func editingCard(_ row: Queries.TOCRow) -> some View {
        if let variantID = row.variantID {
            PaneSurfaceView(
                text: model.displayText(variantID: variantID, storeText: row.text),
                isLive: model.liveBlockID == row.blockID && !row.variantLocked,
                tokens: tokens,
                role: "index", variantID: variantID,
                onFocusRequest: { model.makeLive(row.blockID, variantID: variantID) },
                onEdit: { newText in
                    model.paneEdited(
                        variantID: variantID,
                        oldText: row.text ?? "", newText: newText)
                })
                .padding(8)
                .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            model.liveBlockID == row.blockID ? tokens.ring : tokens.takeLine,
                            lineWidth: 1))
        } else {
            Text("· · ·").foregroundStyle(tokens.faint).padding(.leading, 20)
        }
    }

    /// ↑ ↓ ⋯ — the TOC's whole door set, waking on hover. `ordinal` rides
    /// in from the outline walk (never a per-row `firstIndex` — the O(N²)
    /// render class this round's own KnownIssues row names).
    private func rowControls(for blockID: String, ordinal: Int) -> some View {
        HStack(spacing: 2) {
            Button("↑") { Task { await model.move(blockID: blockID, up: true) } }
                .disabled(ordinal <= 1)
            Button("↓") { Task { await model.move(blockID: blockID, up: false) } }
                .disabled(ordinal >= model.rows.count)
            Menu("⋯") {
                if let row = rowsByID[blockID] { rowMenu(row, ordinal: ordinal) }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
        }
        .controlSize(.mini)
    }

    /// The ⋯ menu — every TOC door survives (name · jump · moves · move
    /// out to snippets · archive · delete), the ruled SNIPPETS vocabulary.
    @ViewBuilder
    private func rowMenu(_ row: Queries.TOCRow, ordinal: Int) -> some View {
        Button("Name…") {
            renameText = row.name ?? ""
            renameTarget = row
        }
        Button("Jump to block in Write") { onJump?(row.blockID) }
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

    /// The footer: the tray door (the ONE panel) + the note's shape.
    private var columnFooter: some View {
        HStack(spacing: 10) {
            if !model.tray.isEmpty {
                Button {
                    let request = TrayRequest(postID: postID)
                    if !session.commandRouter.requestNoteTray(request) {
                        trayShown = true
                    }
                } label: {
                    Text(tokens.chromeLabel("\(TrayPath.menuLabel) — \(model.tray.count) waiting"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .lineLimit(1)
                }
                .buttonStyle(.plain)
                .help("Opens this note's tray: what it deleted, what it archived, "
                    + "and any originals a divide or merge preserved")
            }
            Spacer(minLength: 4)
            Text(tokens.chromeLabel("\(model.rows.count) blocks · \(totalWords) words"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .top) { Divider().overlay(tokens.line) }
    }
}

// MARK: - One column row (selection wash, hover-waking controls)

private struct IndexColumnRow<Content: View, Trailing: View>: View {
    let tokens: VoiceTokens
    let selected: Bool
    @ViewBuilder var content: () -> Content
    @ViewBuilder var trailing: () -> Trailing
    let onSelect: () -> Void

    @State private var hovering = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if selected, !tokens.selectionMarker.isEmpty {
                Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            content()
            trailing()
                .opacity(hovering || selected ? 1 : 0.25)
        }
        .padding(.horizontal, 8)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { hovering = $0 }
    }
}

// MARK: - The reading pane (projection tier — P3, zero TK2 geometry)

private struct IndexReadingPane: View {
    let model: BlockTOCViewModel
    let tokens: VoiceTokens
    let selectedBlockID: String?
    @Binding var paneTarget: String?
    let onSelect: (String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(
                        Array(model.rows.enumerated()), id: \.element.placementID
                    ) { i, row in
                        IndexPaneBlock(
                            tokens: tokens,
                            text: paneText(row),
                            ordinal: i + 1,
                            selected: selectedBlockID == row.blockID,
                            onTap: { onSelect(row.blockID) })
                            .id("ixp-\(row.blockID)")
                    }
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(.horizontal, 34)
                .padding(.vertical, 26)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(tokens.surface)
            .onChange(of: paneTarget) { _, target in
                guard let target else { return }
                withAnimation { proxy.scrollTo("ixp-\(target)", anchor: .center) }
                paneTarget = nil
            }
        }
    }

    /// The block's DISPLAY text — the authority's overlay over the store
    /// row, so a live edit in the column is never staler here.
    private func paneText(_ row: Queries.TOCRow) -> String {
        guard let variantID = row.variantID else { return "" }
        return model.displayText(variantID: variantID, storeText: row.text)
    }
}

/// One rendered block of the pane: markdown via the one transform
/// (`FlowParagraph`), washed when selected, one generous click target.
private struct IndexPaneBlock: View {
    let tokens: VoiceTokens
    let text: String
    let ordinal: Int
    let selected: Bool
    let onTap: () -> Void

    @State private var paragraphs: [FlowParagraph] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(font(paragraph))
                    .foregroundStyle(tokens.ink)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ").font(tokens.body)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topLeading) {
            if selected {
                Text(String(format: "%02d", ordinal))
                    .font(tokens.mono)
                    .foregroundStyle(tokens.faint)
                    .offset(x: -26, y: 6)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .task(id: text) {
            paragraphs = FlowParagraph.paragraphs(of: text, codeTint: tokens.codeTint)
        }
    }

    /// The pane reads in the VOICE (direction A's pane is the surface, not
    /// the paper — Read owns the paper look). A view-local font map over
    /// the one transform's line styles, never a second markdown brain.
    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            level == 1 ? tokens.title : tokens.heading
        case .body, .bullet, .checkbox:
            tokens.body
        }
    }
}
