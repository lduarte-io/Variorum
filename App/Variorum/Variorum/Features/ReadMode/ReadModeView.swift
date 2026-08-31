//
//  ReadModeView.swift
//  Variorum
//
//  pre-13u Act 10 wave 2c — **READ, the new read-only mode** (item 16,
//  W8-1; her ruling verbatim: "a Reading surface SHOULD be added! …the
//  Read surface that you can't edit … that's the thing that notes have
//  been missing relative to books, is the ability to read"). Direction B:
//  the calm page — boundaries gone, markdown rendered, the
//  voice-independent `ReadingPageTokens` paper (the book flow's own look,
//  deliberately, per R2) — with reading tools on a light rail and **a
//  MINIMAL companion outline** (her sharpening: "a more minimal outline
//  than 'index' for the read only mode" — the book's small TOC-pane
//  grammar, collapsible, click-to-scroll and nothing else).
//
//  THE CLICK-THROUGH (her ruling: "clicking on it brings you to that
//  sentence within index, already open"): a click on a block notes the
//  fact through the ONE mechanism (`CommandRouter.noteFocusedBlock`) and
//  requests Index — which seeds from the same fact. This is the
//  scrolled-open-door shape built ONCE here; 13u item 17's book-side jump
//  fix and 13i's Book Panel click-through reuse it (note the fact, switch
//  the surface, seed from the fact).
//
//  P-3: Read is a PROJECTION TIER — no live editor exists in this mode,
//  ever; nothing here touches `PaneTextAuthority`. P1: a LazyVStack of
//  per-block rows, each rendering its own markdown in its own task (the
//  `ReadingFlowView` precedent) — cost ∝ viewport, never note size; the
//  scroll-sync is SwiftUI anchors, zero TK2 geometry (TEXTKIT2 §2's risk
//  family deliberately not entered).
//

import SwiftUI
import VariorumCore

struct ReadModeView: View {
    let session: AppSession
    let postID: String

    @State private var model: BlockTOCViewModel
    /// The minimal outline pane — collapsible (her sharpening), remembered
    /// across notes (a reading posture, not a per-note fact).
    @AppStorage("readModeOutlineShown") private var outlineShown = true
    /// The page's type size step — a reading tool, session-persistent.
    @AppStorage("readModeTypeScale") private var typeScale = 1.0
    @State private var trayShown = false
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var page: ReadingPageTokens { scheme == .dark ? .dark : .light }

    init(session: AppSession, postID: String, model: BlockTOCViewModel? = nil) {
        self.session = session
        self.postID = postID
        _model = State(initialValue: model ?? BlockTOCViewModel(session: session, postID: postID))
    }

    private var outline: NoteIndexOutline.Outline {
        NoteIndexOutline.outline(of: model.rows.map { ($0.blockID, $0.text) })
    }

    private var totalWords: Int {
        model.rows.reduce(0) { $0 + Queries.wordCount($1.text ?? "") }
    }

    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    if outlineShown {
                        minimalOutline(proxy)
                            .frame(width: 200)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    pageColumn
                }
                metaBar
            }
        }
        .background(tokens.room)
        .overlay(alignment: .topTrailing) { toolRail }
        .task { await model.start() }
        .task { await model.startTray() }
        .onDisappear { model.teardown() }
        .sheet(isPresented: $trayShown) {
            TrayPanel(session: session, postID: postID)
        }
    }

    // MARK: - The tool rail (light, floating — the mockup's grammar)

    private var toolRail: some View {
        HStack(spacing: 4) {
            Button(tokens.chromeLabel("outline")) {
                withAnimation(.easeInOut(duration: 0.18)) { outlineShown.toggle() }
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(outlineShown ? tokens.accent : tokens.muted)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                outlineShown ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                in: RoundedRectangle(cornerRadius: 6))
            .help("The note's small outline beside the page — fold it away and back")
            Divider().frame(height: 16)
            Button("Aa −") { typeScale = max(0.85, typeScale - 0.1) }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .disabled(typeScale <= 0.86)
                .help("Smaller type")
            Button("Aa +") { typeScale = min(1.5, typeScale + 0.1) }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .disabled(typeScale >= 1.49)
                .help("Bigger type")
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 6)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tokens.line, lineWidth: 1))
        .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.05), radius: 6, y: 2)
        .padding(.top, 12)
        .padding(.trailing, 18)
    }

    // MARK: - The minimal outline (the book's small TOC-pane grammar)

    /// More minimal than Index by construction: section heads where the
    /// note has them, else the block handles — small, muted, click scrolls
    /// the page, no controls, no filter, no editing.
    private func minimalOutline(_ proxy: ScrollViewProxy) -> some View {
        // One dictionary per pass — never a per-row `first(where:)` (the
        // O(N²) render class this round's KnownIssues row names).
        let byID = Dictionary(uniqueKeysWithValues: model.rows.map { ($0.blockID, $0) })
        return ScrollView {
            VStack(alignment: .leading, spacing: 2) {
                Text(tokens.chromeLabel("contents"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.bottom, 6)
                if outline.isFlat {
                    ForEach(outline.allRows, id: \.blockID) { row in
                        outlineRow(
                            title: handle(row.blockID, in: byID), nested: false,
                            proxy: proxy, target: row.blockID)
                    }
                } else {
                    ForEach(Array(outline.groups.enumerated()), id: \.offset) { _, group in
                        if let head = group.head {
                            outlineRow(
                                title: sectionTitle(head.blockID, in: byID),
                                nested: false, emphasized: true, proxy: proxy,
                                target: head.blockID)
                        }
                        // Sections only — the kids stay off this pane
                        // (that is the "more minimal" her ruling asked
                        // for); the preamble's blocks list plainly.
                        if group.head == nil {
                            ForEach(group.rows, id: \.blockID) { row in
                                outlineRow(
                                    title: handle(row.blockID, in: byID), nested: false,
                                    proxy: proxy, target: row.blockID)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func outlineRow(
        title: String, nested: Bool, emphasized: Bool = false,
        proxy: ScrollViewProxy, target: String
    ) -> some View {
        Button {
            withAnimation { proxy.scrollTo("rd-\(target)", anchor: .top) }
        } label: {
            Text(title.isEmpty ? "· · ·" : title)
                .font(emphasized ? tokens.small.weight(.semibold) : tokens.small)
                .foregroundStyle(emphasized ? tokens.ink : tokens.muted)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 3)
                .padding(.leading, nested ? 12 : 0)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Go to \u{201C}\(title)\u{201D}")
    }

    private func handle(_ blockID: String, in byID: [String: Queries.TOCRow]) -> String {
        guard let row = byID[blockID] else { return "" }
        return Queries.tocHandle(name: row.name, text: row.text)
    }

    private func sectionTitle(_ blockID: String, in byID: [String: Queries.TOCRow]) -> String {
        guard let row = byID[blockID] else { return "" }
        let heading = NoteIndexOutline.headingTitle(of: row.text)
        return heading.isEmpty ? Queries.tocHandle(name: row.name, text: row.text) : heading
    }

    // MARK: - The page

    private var pageColumn: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 14 * typeScale) {
                ReadPageHeader(session: session, postID: postID, page: page,
                               words: totalWords)
                ForEach(Array(model.rows.enumerated()), id: \.element.placementID) { i, row in
                    ReadPageBlock(
                        page: page, tokens: tokens, typeScale: typeScale,
                        text: row.text ?? "", ordinal: i + 1,
                        onOpenInIndex: { openInIndex(row) })
                        .id("rd-\(row.blockID)")
                }
                Text("· · ·")
                    .font(page.serif)
                    .foregroundStyle(page.pageMeta)
                    .padding(.vertical, 30)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 700)
            .padding(.horizontal, 60)
            .padding(.vertical, 46)
            .background(page.paper)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.10), radius: 12, y: 3)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity)
        }
    }

    /// The ruled click-through: note the fact, switch the mode — Index
    /// seeds from the same fact (the ONE scrolled-open-door mechanism).
    private func openInIndex(_ row: Queries.TOCRow) {
        session.commandRouter.noteFocusedBlock(
            row.blockID, variantID: row.variantID, postID: postID)
        session.commandRouter.requestMode(.index, postID: postID)
    }

    // MARK: - The meta bar

    private var metaBar: some View {
        HStack(spacing: 14) {
            Text(tokens.chromeLabel(
                "\(model.rows.count) blocks · \(totalWords) words · about "
                + "\(max(1, Int((Double(totalWords) / 200).rounded(.up)))) min"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            Spacer(minLength: 8)
            if !model.tray.isEmpty {
                Button(tokens.chromeLabel("\(TrayPath.menuLabel) — \(model.tray.count) waiting")) {
                    let request = TrayRequest(postID: postID)
                    if !session.commandRouter.requestNoteTray(request) {
                        trayShown = true
                    }
                }
                .buttonStyle(.plain)
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .help("This note's tray — deleted, archived, and preserved originals")
            }
            Button(tokens.chromeLabel("edit in write")) {
                session.commandRouter.requestMode(.write, postID: postID)
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
            .help("Back to the full editor (⌘1) — or click any paragraph to land on it in Index")
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 9)
        .background(tokens.card)
        .overlay(alignment: .top) { Divider().overlay(tokens.line) }
    }
}

// MARK: - The page's header (title + kicker on the paper)

private struct ReadPageHeader: View {
    let session: AppSession
    let postID: String
    let page: ReadingPageTokens
    let words: Int

    @State private var title = DisplayTitle.placeholder

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(page.serifTitle)
                .foregroundStyle(page.ink)
            Text("\(words) words · about \(max(1, Int((Double(words) / 200).rounded(.up)))) minute\(words > 200 ? "s" : "")")
                .font(.system(size: 11.5))
                .foregroundStyle(page.pageMeta)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
        .task(id: postID) {
            let read = try? await session.database.read { [postID] db in
                try Queries.noteDisplayTitle(db, id: postID)
            }
            title = read ?? DisplayTitle.placeholder
        }
    }
}

// MARK: - One block on the page

/// One block's paragraphs on the paper: markdown via the one transform,
/// a quiet hover wash + gutter ordinal, one generous click target that
/// lands this block in Index (the ruled behavior).
private struct ReadPageBlock: View {
    let page: ReadingPageTokens
    let tokens: VoiceTokens
    let typeScale: Double
    let text: String
    let ordinal: Int
    let onOpenInIndex: () -> Void

    @State private var paragraphs: [FlowParagraph] = []
    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 11 * typeScale) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(font(paragraph))
                    .foregroundStyle(page.ink)
                    .lineSpacing(6 * typeScale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ").font(page.serif)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            hovering ? AnyShapeStyle(page.pageMeta.opacity(0.10)) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 6))
        .overlay(alignment: .topLeading) {
            if hovering {
                Text(String(format: "%02d", ordinal))
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundStyle(page.pageMeta)
                    .offset(x: -36, y: 6)
            }
        }
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
        .onTapGesture { onOpenInIndex() }
        .help("Open this paragraph in Index — the note's table of contents, "
            + "already standing at this block")
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .task(id: text) {
            paragraphs = FlowParagraph.paragraphs(of: text, codeTint: page.codeTint)
        }
    }

    /// The page's type at the rail's scale — a look decision, view-local
    /// (the `maxDrawnIndentLevel` doctrine: look lives with the look).
    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(
                size: (15 * scale * typeScale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return .system(size: (16 * typeScale).rounded(), design: .serif)
        }
    }
}
