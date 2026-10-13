//
//  NoteIndexColumn.swift
//  Variorum
//
//  **The `▸ 01` column** — the Index tab's outline navigator, kept whole
//  when the Index tab retired INTO Read (the Act 10 correction round, her
//  rulings R-cor-5/7; verbatim: *"I actually really like how the index tab
//  looks with its > 01, I think it looks nice. the text is a bit too small
//  on the dropdown but it's better with the outline as what the current
//  index has."*). Markdown headings become SECTIONS (`NoteIndexOutline`,
//  the pure brain), everything else nests under the most recent heading, a
//  heading-less note reads honestly FLAT; the filter, the fold-all door, the
//  hover-waking ↑ ↓ ⋯ controls and the whole TOC ⋯ menu ride unchanged.
//
//  Two things changed with the ruling: the block rows' handles are a step
//  larger (`tokens.body`, her "too small" line), and the rows' expanding
//  EDITING CARD is RETIRED — the editable surface is the pane beside this
//  column (`ReadEditPane`), never a small card inside the navigator. The
//  `▸` stays as the row's glyph, in the accent on the selected row.
//
//  The column is the HOST's: `ReadModeView` shows it beside either face
//  (`edit` and `read` alike) behind the outline toggle she loves.
//

import AppKit
import SwiftUI
import VariorumCore

/// The retired tab's name survives as a forward (the 3C parity shape) so
/// the registry walk and the pins that union its declared acts read on.
typealias IndexModeView = NoteIndexColumn

struct NoteIndexColumn: View {
    /// The row menu's declared acts — the TOC's pair, carried (the listing
    /// menu's archive/delete family; declared ⇔ rendered).
    static let surfaceCapabilities: [CapabilityID] = [.archiveBlock, .deleteBlock]

    /// The column's measure — the Index tab's own. Since 18d batch 3 (her
    /// U-13) it is where the column STARTS, not where it stays: the host
    /// mounts it in the leading `SideColumn`, so this is the ideal a note
    /// with nothing remembered opens at, and nothing moves for her until she
    /// drags the boundary.
    static let width: CGFloat = 340
    /// How narrow she may drag it before the handles and the first lines
    /// stop being a contents list at all.
    static let minimumWidth: CGFloat = 240

    let session: AppSession
    let model: BlockTOCViewModel
    let tokens: VoiceTokens
    let selectedBlockID: String?
    /// Whether the footer carries the note's shape line (`N blocks · N
    /// words`). The `edit` face shows it here; the `read` face's page header
    /// already says the words — the merged tab keeps exactly ONE count line
    /// (row 36, batch A's table: KEEP-ONE).
    let showsCount: Bool
    /// The ONE-shot scroll request — the host sets it on a landing or a
    /// seed; the column lands on its row and clears it.
    @Binding var columnTarget: String?
    /// A row was clicked: the host selects it and scrolls its face there.
    let onSelect: (String) -> Void
    /// "Jump to block in Write" — the detail switches to Write with the
    /// caret seeded (the standing hybrid primitive).
    var onJump: ((String) -> Void)?

    /// Section heads whose kids are folded away (session-only view state).
    @State private var collapsedSections: Set<String> = []
    @State private var filter = ""
    @State private var renameTarget: Queries.TOCRow?
    @State private var renameText = ""
    @State private var moveTarget: Queries.TOCRow?
    @State private var moveOrdinalText = ""
    @State private var trayShown = false
    /// Whether the column is moving under her hand (17y B1 (j)): a row the
    /// scroll carries under a resting pointer must not wake its controls.
    @State private var scrollPhase = NoteIndexScrollPhase()

    // MARK: - Derived structure

    private var outline: NoteIndexOutline.Outline {
        NoteIndexOutline.outline(of: model.rows.map { ($0.blockID, $0.text) })
    }

    /// The note's rows by id — a WHOLE-NOTE build, so it is taken ONCE per
    /// body (by `columnRows`), never per row (**17y B1 (j)** — her "laggy"
    /// index scroll: the row builders called this computed property, so every
    /// row a scroll realized rebuilt a dictionary over the whole note — 626 µs
    /// at 2,000 blocks, several times per row; the record's § THE TRACE).
    private var rowsByID: [String: Queries.TOCRow] {
        #if DEBUG
        NoteIndexColumnProbe.wholeNoteLookups += 1
        #endif
        return Dictionary(uniqueKeysWithValues: model.rows.map { ($0.blockID, $0) })
    }

    private var totalWords: Int {
        model.rows.reduce(0) { $0 + Queries.wordCount($1.text ?? "") }
    }

    /// One flattened column row (sections and kids interleaved, collapse
    /// and filter applied) — so the LazyVStack virtualizes a long note.
    /// **It carries its own TOC row** (17y B1 (j)): a row the scroll realizes
    /// draws from what it holds and looks nothing up — its cost is what it
    /// shows, never the note's size (P1).
    private struct ColumnRow: Identifiable {
        let row: NoteIndexOutline.Row
        let toc: Queries.TOCRow
        let isSection: Bool
        let headingLevel: Int?
        let kidCount: Int
        let nested: Bool
        var id: String { row.blockID }
    }

    private func columnRows(_ outline: NoteIndexOutline.Outline) -> [ColumnRow] {
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
                guard headMatches || !kidMatches.isEmpty, let headRow = byID[head.blockID]
                else { continue }
                result.append(ColumnRow(
                    row: head, toc: headRow, isSection: true,
                    headingLevel: group.headingLevel,
                    kidCount: group.rows.count, nested: false))
                if !collapsedSections.contains(head.blockID) {
                    let kids = needle.isEmpty ? group.rows : kidMatches
                    result.append(contentsOf: kids.compactMap { kid in
                        byID[kid.blockID].map {
                            ColumnRow(row: kid, toc: $0, isSection: false, headingLevel: nil,
                                      kidCount: 0, nested: true)
                        }
                    })
                }
            } else {
                result.append(contentsOf: kidMatches.compactMap { kid in
                    byID[kid.blockID].map {
                        ColumnRow(row: kid, toc: $0, isSection: false, headingLevel: nil,
                                  kidCount: 0, nested: false)
                    }
                })
            }
        }
        return result
    }

    var body: some View {
        // ONE outline and ONE row list per body (17y B1 (j)) — the header and
        // the rows read the same walk; the rows carry what they draw.
        let outline = self.outline
        VStack(alignment: .leading, spacing: 0) {
            columnHeader(outline)
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(columnRows(outline)) { entry in
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
                .onScrollPhaseChange { _, phase in
                    let moving = phase != .idle
                    if scrollPhase.moving != moving { scrollPhase.moving = moving }
                }
                .onChange(of: columnTarget) { _, target in
                    // A landing or a seed lands the COLUMN on its row (a
                    // long note's landing must be visible on both sides).
                    // Ladder R1-3: on the row's ForEach IDENTITY (its block
                    // id — `ColumnRow.id`), never an explicit `.id`.
                    guard let target else { return }
                    proxy.scrollTo(target, anchor: .center)
                    columnTarget = nil
                }
                .task {
                    // A request parked before the column mounted (the
                    // outline toggled back on after a landing).
                    await Task.yield()
                    guard let target = columnTarget else { return }
                    proxy.scrollTo(target, anchor: .center)
                    columnTarget = nil
                }
            }
            columnFooter
        }
        .background(tokens.surface)
        .sheet(isPresented: $trayShown) {
            TrayPanel(session: session, postID: model.postID)
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

    // MARK: - The header (filter + fold-all)

    private func columnHeader(_ outline: NoteIndexOutline.Outline) -> some View {
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

    // MARK: - Rows

    /// A section head: fold chevron + ordinal + the heading's own words +
    /// its kid count. Selecting it syncs the face like any row.
    private func sectionRow(_ entry: ColumnRow) -> some View {
        #if DEBUG
        NoteIndexColumnProbe.rowsBuilt += 1
        #endif
        let row = entry.toc
        let folded = collapsedSections.contains(entry.row.blockID)
        let heading = NoteIndexOutline.headingTitle(of: row.text)
        let title = heading.isEmpty ? Queries.tocHandle(name: row.name, text: row.text) : heading
        return IndexColumnRow(
            tokens: tokens,
            selected: selectedBlockID == entry.row.blockID,
            scrollPhase: scrollPhase,
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
            trailing: { live in rowControls(for: row, ordinal: entry.row.ordinal, live: live) },
            onSelect: { onSelect(entry.row.blockID) })
    }

    /// An ordinary row: the `▸` glyph (accent when selected) + ordinal +
    /// the read-time handle + fan/lock marks; controls wake on hover (the
    /// mockup's calm). No editing card — the pane beside the column edits.
    @ViewBuilder
    private func blockRow(_ entry: ColumnRow) -> some View {
        #if DEBUG
        let _ = NoteIndexColumnProbe.rowsBuilt += 1
        #endif
        let row = entry.toc
        let selected = selectedBlockID == row.blockID
        IndexColumnRow(
            tokens: tokens,
            selected: selected,
            scrollPhase: scrollPhase,
            content: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("▸")
                        .font(tokens.small)
                        .foregroundStyle(selected ? tokens.accent : tokens.faint)
                    Text(String(format: "%02d", entry.row.ordinal))
                        .font(tokens.mono)
                        .foregroundStyle(tokens.faint)
                    Text(Queries.tocHandle(name: row.name, text: row.text))
                        .font(row.name != nil ? tokens.body.weight(.semibold) : tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    if row.hasFan {
                        Text("⑂").font(tokens.small).foregroundStyle(tokens.ring)
                    }
                    if row.variantLocked {
                        Text(tokens.chromeLabel("locked"))
                            .font(tokens.small)
                            // 18j — the same token as the Blocks
                            // workbench's lock mark, for the same reason.
                            .foregroundStyle(tokens.alarm)
                    }
                    Spacer(minLength: 4)
                }
                .padding(.vertical, 5)
                .padding(.leading, entry.nested ? 14 : 0)
            },
            trailing: { live in rowControls(for: row, ordinal: entry.row.ordinal, live: live) },
            onSelect: { onSelect(row.blockID) })
    }

    /// ↑ ↓ ⋯ — the TOC's whole door set, waking on hover. `ordinal` rides
    /// in from the outline walk (never a per-row `firstIndex` — the O(N²)
    /// render class the KnownIssues row names).
    ///
    /// **17y B1 (j) — only the row she is AT builds the live controls**
    /// (P3: only the focused thing is heavy). Three AppKit-backed controls on
    /// EVERY realized row were the other half of her "laggy" scroll (the
    /// record's § THE TRACE: with the lookup gone the column still ran at
    /// ~120 ms a frame; with resting rows drawing no controls, 11 ms). A
    /// RESTING row draws the same hint as ONE cached image
    /// (`RestingRowControls.hint`, the live set's measured footprint), and
    /// the selected row — or the hovered one while the column is still —
    /// draws the live controls in that same footprint, so waking a row never
    /// moves its layout. (Measured on the 2,000-block note: drawing the hint
    /// as views cost ~20 ms a frame; waking each row the scroll carried under
    /// the pointer cost ~20 more — the record's after-measurement.)
    @ViewBuilder
    private func rowControls(for row: Queries.TOCRow, ordinal: Int, live: Bool) -> some View {
        if live {
            liveRowControls(for: row, ordinal: ordinal)
                // At its OWN size inside the hint's footprint — the pin
                // measures this, and the two are one size by construction.
                .lineLimit(1)  // P-8 (19g class): a fixedSize chrome site states its line policy
                .fixedSize()
                #if DEBUG
                .onGeometryChange(for: CGSize.self) { $0.size } action: {
                    NoteIndexColumnProbe.liveSize = $0
                }
                #endif
                .frame(
                    width: RestingRowControls.footprint.width,
                    height: RestingRowControls.footprint.height, alignment: .trailing)
        } else {
            RestingRowControls.hint(tokens: tokens)
        }
    }

    private func liveRowControls(for row: Queries.TOCRow, ordinal: Int) -> some View {
        #if DEBUG
        NoteIndexColumnProbe.liveControlRows += 1
        #endif
        let blockID = row.blockID
        return HStack(spacing: 2) {
            Button("↑") { Task { await model.move(blockID: blockID, up: true) } }
                .disabled(ordinal <= 1)
            Button("↓") { Task { await model.move(blockID: blockID, up: false) } }
                .disabled(ordinal >= model.rows.count)
            // VX-223: the chrome pull-down pins its own control size, so the
            // row's mini (the ↑ ↓ keys') never reaches the popped rows — they
            // read at menu size; the ⋯ keeps its mini frame (the resting
            // hint's footprint is unchanged).
            ChromePullDown("⋯") {
                rowMenu(row, ordinal: ordinal)
            }
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

    /// The footer: the tray door (the ONE panel) + the note's shape line
    /// where the face has no other count (row 36's KEEP-ONE).
    private var columnFooter: some View {
        HStack(spacing: 10) {
            if !model.tray.isEmpty {
                Button {
                    let request = TrayRequest(postID: model.postID)
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
            if showsCount {
                Text(tokens.chromeLabel("\(model.rows.count) blocks · \(totalWords) words"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .top) { Divider().overlay(tokens.line) }
    }
}

#if DEBUG
/// **17y B1 (j) — the column's P1 probes** (the `ReadNoteHeights.extentTakes`
/// precedent: a count a pin can read, behaviour-free). How many WHOLE-NOTE
/// lookups were built, how many column rows were built, and how many rows
/// built their LIVE (AppKit-backed) controls — the two per-row costs the
/// trace measured as her scroll lag (the 17y B1 RECORD's § THE TRACE).
@MainActor
enum NoteIndexColumnProbe {
    static var wholeNoteLookups = 0
    static var rowsBuilt = 0
    static var liveControlRows = 0
    /// What the live set drew at its own size (the hint's footprint is held
    /// to it by the geometry pin).
    static var liveSize: CGSize?

    static func reset() {
        wholeNoteLookups = 0
        rowsBuilt = 0
        liveControlRows = 0
        liveSize = nil
    }
}
#endif

// MARK: - The resting rows' hint (17y B1 (j))

/// **What a resting row shows where the `↑ ↓ ⋯` doors wake** — two small
/// rounded keys and the menu's dots, in the voice's ink, at the row's own 25 %
/// rest. Drawn ONCE per ink into an image (`hint(tokens:)`), so a resting row
/// costs one image view however fast she scrolls; nothing here can be clicked,
/// because nothing here is awake (a click on a resting row selects it, and its
/// hover wakes the doors first).
struct RestingRowControls: View {
    let tokens: VoiceTokens

    /// The live mini controls' footprint, measured (79 × 13 pt on macOS 27.0:
    /// two 25.5-pt keys, the 24-pt menu, 2-pt gaps) — the geometry pin holds
    /// the live set to it, so a row's title truncates exactly where it always
    /// did and a waking row never moves.
    static let footprint = CGSize(width: 79, height: 13)
    static let keyFrame = CGSize(width: 25.5, height: 13)
    static let menuWidth: CGFloat = 24
    static let spacing: CGFloat = 2

    var body: some View {
        HStack(spacing: Self.spacing) {
            key("↑")
            key("↓")
            HStack(spacing: 2) {
                Text("⋯")
                Image(systemName: "chevron.down")
                    .font(.system(size: 7, weight: .semibold))
            }
            .font(.system(size: 10))
            .foregroundStyle(tokens.ink)
            .frame(width: Self.menuWidth, height: Self.keyFrame.height)
        }
        .frame(width: Self.footprint.width, height: Self.footprint.height, alignment: .trailing)
        .accessibilityHidden(true)
    }

    /// A key: the bezel drawn one point inside its frame (the mini button's
    /// own inset), the glyph centred.
    private func key(_ glyph: String) -> some View {
        Text(glyph)
            .font(.system(size: 9))
            .foregroundStyle(tokens.ink)
            .frame(width: Self.keyFrame.width - 2, height: Self.keyFrame.height - 1)
            .background(tokens.ink.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
            .frame(width: Self.keyFrame.width, height: Self.keyFrame.height)
    }

    // MARK: The one image a resting row shows

    /// Rendered once per ink (a voice or appearance change is a new ink),
    /// at the Retina scale. Bounded: one entry per ink the app has shown.
    @MainActor private static var images: [String: Image] = [:]

    @MainActor
    static func hint(tokens: VoiceTokens) -> some View {
        let key = inkKey(tokens.ink)
        let image: Image
        if let cached = images[key] {
            image = cached
        } else {
            let renderer = ImageRenderer(content: RestingRowControls(tokens: tokens))
            renderer.scale = 2
            image = renderer.cgImage.map { Image(decorative: $0, scale: 2) }
                ?? Image(nsImage: NSImage())
            images[key] = image
        }
        return image
            .resizable()
            .frame(width: footprint.width, height: footprint.height)
            .accessibilityHidden(true)
    }

    /// The ink's identity as its sRGB components (a `Color`'s description is
    /// not a promise).
    @MainActor
    static func inkKey(_ ink: Color) -> String {
        guard let rgb = NSColor(ink).usingColorSpace(.sRGB) else { return "\(ink)" }
        return String(format: "%.4f,%.4f,%.4f,%.4f",
                      rgb.redComponent, rgb.greenComponent, rgb.blueComponent, rgb.alphaComponent)
    }
}

/// **Whether a column row's doors are awake** (17y B1 (j)) — pure, so the
/// rule is pinned without a pointer: the SELECTED row always; a HOVERED row
/// only while the column is still. A row the scroll carries under a resting
/// pointer passes by without building its AppKit controls (measured: that
/// churn alone cost ~20 ms a frame on the 2,000-block note).
enum NoteIndexRowWake {
    static func isLive(selected: Bool, hovering: Bool, scrolling: Bool) -> Bool {
        selected || (hovering && !scrolling)
    }
}

/// The column's scroll phase, observed by its rows (never by the column's own
/// body — a phase change re-draws the rows' doors, not the whole note's list).
@MainActor
@Observable
final class NoteIndexScrollPhase {
    var moving = false
}

// MARK: - One column row (selection wash, hover-waking controls)

private struct IndexColumnRow<Content: View, Trailing: View>: View {
    let tokens: VoiceTokens
    let selected: Bool
    /// 17y B1 (j): a hovered row wakes its doors only while the column is
    /// still (`NoteIndexRowWake`).
    let scrollPhase: NoteIndexScrollPhase
    @ViewBuilder var content: () -> Content
    /// The trailing controls, told whether the row is LIVE (hovered or
    /// selected) — 17y B1 (j): only a live row builds the AppKit controls.
    @ViewBuilder var trailing: (_ live: Bool) -> Trailing
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
            trailing(NoteIndexRowWake.isLive(
                selected: selected, hovering: hovering, scrolling: scrollPhase.moving))
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
