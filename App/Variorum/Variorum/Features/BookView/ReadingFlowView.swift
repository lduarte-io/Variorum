//
//  ReadingFlowView.swift
//  Variorum
//
//  Phase 13, B3 — direction C as a VIEW MODE (R2/R56: "iBooks as an
//  editing surface… an option for a view", reachable from any book in
//  either voice; a FINISHED book opens here and shows nothing but the
//  text). One continuous page column; chapter breaks are typographic;
//  posts flow together. Clicking a post opens it for editing in the book
//  view (in-place waking is Stage C's v2-canon surface). Text loads
//  lazily per post (`.task` per row inside the LazyVStack — viewport-
//  shaped, P3). Round 3 MAJOR: the column WAS a plain VStack — every row
//  materialized and fetched on open, cost ∝ book size, exactly the shape
//  this header already claimed not to have; now genuinely lazy, pinned by
//  the DEBUG materialization counter below.
//

import SwiftUI
import VariorumCore

struct ReadingFlowView: View {
    let session: AppSession
    let readingName: String?
    let grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    /// Wake this post for editing (back in the book view).
    let onWake: (String) -> Void
    /// 13f W21: the post a mode switch (or W20's ascent) asked this surface
    /// to land on. Defaults nil, so every pre-existing call site is unchanged.
    var reveal: String?
    /// …and the acknowledgement, so the request is consumed exactly once.
    var onRevealLanded: (() -> Void)?

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var page: ReadingPageTokens {
        scheme == .dark ? .dark : .light
    }
    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        ScrollViewReader { proxy in
            column
                // 13f W21 — the flow's LANDING half. (Its reporting half
                // does not exist: this surface tracks no scroll position,
                // and per-row visibility reporting is the machinery 13c 2A
                // deleted on her A6 ruling. Leaving the scroll therefore
                // carries the book's standing anchor — `BookAnchor`'s header
                // states it, and the batch record lists it for her walk.)
                .onAppear { land(proxy) }
                .onChange(of: reveal) { _, _ in land(proxy) }
        }
    }

    private func land(_ proxy: ScrollViewProxy) {
        guard let reveal else { return }
        onRevealLanded?()
        withAnimation { proxy.scrollTo("flow-\(reveal)", anchor: .top) }
    }

    private var column: some View {
        ScrollView {
            VStack(spacing: 0) {
                // LAZY (P3 — round 3 MAJOR): rows materialize near the
                // viewport only; the page paper/shadow wrap the column,
                // so laziness costs the styling nothing.
                LazyVStack(spacing: 28) {
                    if let readingName {
                        Text(readingName)
                            .font(page.serifTitle)
                            .foregroundStyle(page.ink)
                            .padding(.top, 56)
                    }
                    ForEach(Array(grouped.enumerated()), id: \.offset) { _, group in
                        if let section = group.section {
                            Text(section.name.uppercased())
                                .font(.system(size: 12, weight: .medium, design: .serif))
                                .tracking(3)
                                .foregroundStyle(page.chapterInk)
                                .padding(.top, 22)
                        }
                        ForEach(group.entries, id: \.postID) { entry in
                            FlowPostView(
                                session: session, entry: entry, page: page,
                                onWake: { onWake(entry.postID) })
                                .id("flow-\(entry.postID)")  // W21's landing anchor
                        }
                    }
                    Text("· · ·")
                        .font(page.serif)
                        .foregroundStyle(page.pageMeta)
                        .padding(.vertical, 40)
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 56)
                .background(page.paper)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: .black.opacity(scheme == .dark ? 0 : 0.10), radius: 12, y: 3)
                .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room)
    }
}

#if DEBUG
/// Round 3 (MAJOR) pin support: counts FlowPostView materializations so
/// the virtualization pin can assert the LazyVStack defers off-viewport
/// rows (a plain VStack materializes the whole book at once — red on the
/// pre-fix code by behavioral revert).
@MainActor
enum ReadingFlowMaterialization {
    static var count = 0
}
#endif

/// One post on the page: lazy text, serif paragraphs; the whole body is a
/// click target to wake editing.
private struct FlowPostView: View {
    let session: AppSession
    let entry: Queries.ReadingEntry
    let page: ReadingPageTokens
    let onWake: () -> Void

    /// 13g batch 4 (L11): a rendered paragraph — the display text with its
    /// markdown applied, plus the line's own style. Read is a reading
    /// surface (her A43 ruling), so the F-5 surface rule applies: markers
    /// hidden, nothing here maps a click to a text offset.
    @State private var paragraphs: [FlowParagraph] = []

    init(
        session: AppSession, entry: Queries.ReadingEntry,
        page: ReadingPageTokens, onWake: @escaping () -> Void
    ) {
        self.session = session
        self.entry = entry
        self.page = page
        self.onWake = onWake
        #if DEBUG
        ReadingFlowMaterialization.count += 1
        #endif
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(paragraph.font(page))
                    .foregroundStyle(page.ink)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ")
                    .font(page.serif)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onWake() }
        // A link's plain click opens it (F-5); the scheme guard is the same
        // one every other surface asks, so an inert address does nothing
        // rather than something surprising.
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .help(entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? ""))
        .task(id: entry.postID) {
            // The rendered projection, split for display at paragraph
            // boundaries (renderedText semantics — chosen takes, blank
            // takes skip; nothing here re-decides joins), then RENDERED for
            // reading (13g L11 — one transform call per realized row, so the
            // cost stays ∝ what the LazyVStack materialized).
            let text: String? = try? await session.database.read { [id = entry.postID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            paragraphs = FlowParagraph.paragraphs(of: text ?? "")
        }
    }
}

/// One display line of a post, ready for `Text`. Built from the pure
/// transform, so nothing about markdown is decided here.
struct FlowParagraph: Equatable {
    var text: AttributedString
    var style: MarkdownRendering.LineStyle

    /// The flow's own paragraph rule, unchanged from before this batch:
    /// blank display lines are DROPPED (the surface has its own spacing —
    /// the paged reader is the face that keeps stored spacing byte for
    /// byte). What is new is that each surviving line arrives rendered.
    static func paragraphs(of source: String) -> [FlowParagraph] {
        let rendered = MarkdownRendering.render(source)
        let ns = rendered.text as NSString
        var result: [FlowParagraph] = []
        for line in rendered.lines {
            let raw = ns.substring(
                with: NSRange(location: line.range.lowerBound, length: line.range.count))
            guard !raw.trimmingCharacters(in: .whitespaces).isEmpty else { continue }
            // Built by CONCATENATION rather than by indexing into an
            // existing string: the runs are ascending and disjoint (the
            // transform's pinned property), so walking them is exact, and no
            // `AttributedString.Index` arithmetic can drift against UTF-16
            // offsets that came from somewhere else.
            var attributed = AttributedString()
            var cursor = line.range.lowerBound
            for run in rendered.runs
            where run.range.lowerBound >= line.range.lowerBound
                && run.range.upperBound <= line.range.upperBound {
                if run.range.lowerBound > cursor {
                    attributed += AttributedString(ns.substring(with: NSRange(
                        location: cursor, length: run.range.lowerBound - cursor)))
                }
                attributed += AttributedString(
                    ns.substring(with: NSRange(
                        location: run.range.lowerBound, length: run.range.count)),
                    attributes: container(for: run))
                cursor = run.range.upperBound
            }
            if cursor < line.range.upperBound {
                attributed += AttributedString(ns.substring(with: NSRange(
                    location: cursor, length: line.range.upperBound - cursor)))
            }
            result.append(FlowParagraph(text: attributed, style: line.style))
        }
        return result
    }

    private static func container(for run: MarkdownRendering.Run) -> AttributeContainer {
        var attributes = AttributeContainer()
        var intent: InlinePresentationIntent = []
        if run.emphasis.contains(.bold) { intent.insert(.stronglyEmphasized) }
        if run.emphasis.contains(.italic) { intent.insert(.emphasized) }
        if run.emphasis.contains(.strikethrough) { intent.insert(.strikethrough) }
        if run.emphasis.contains(.code) { intent.insert(.code) }
        if !intent.isEmpty { attributes.inlinePresentationIntent = intent }
        // SwiftUI renders a `.link` attribute as a clickable link and routes
        // the click through the environment's `OpenURLAction` — which is
        // where the scheme guard sits. An address the guard refuses simply
        // carries no link attribute at all, so it reads (and behaves) as
        // ordinary text.
        if let raw = run.url, let url = MarkdownLink.openable(raw) { attributes.link = url }
        return attributes
    }

    func font(_ page: ReadingPageTokens) -> Font {
        switch style {
        case .heading(let level):
            let scale: CGFloat = level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15)
            return .system(size: (15 * scale).rounded(), weight: .semibold, design: .serif)
        case .body, .bullet, .checkbox:
            return page.serif
        }
    }

    /// A list line sits in a little, so a list reads as a list.
    var indent: CGFloat {
        switch style {
        case .bullet, .checkbox: 16
        case .body, .heading: 0
        }
    }
}
