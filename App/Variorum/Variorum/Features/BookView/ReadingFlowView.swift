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
    /// Wake this post for editing — with the BLOCK under the click when a
    /// paragraph was clicked (the correction round, row 38: the scrolled-
    /// open door lands at THAT block; nil = the note as a whole).
    let onWake: (_ postID: String, _ blockID: String?) -> Void
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
                                onWake: { blockID in onWake(entry.postID, blockID) })
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

/// One post on the page: lazy text, serif paragraphs; each BLOCK's
/// paragraphs are a click target that wakes editing AT that block (row 38);
/// the note's empty state wakes the note as a whole.
private struct FlowPostView: View {
    let session: AppSession
    let entry: Queries.ReadingEntry
    let page: ReadingPageTokens
    let onWake: (String?) -> Void

    /// 13g batch 4 (L11): rendered paragraphs — the display text with its
    /// markdown applied, plus the line's own style — kept PER BLOCK since
    /// the correction round, so a click knows which block it fell in. Read
    /// is a reading surface (her A43 ruling), so the F-5 surface rule
    /// applies: markers hidden; the click maps to a block, never to a
    /// text offset (a SwiftUI `Text` cannot say where inside itself).
    @State private var blocks: [(blockID: String, paragraphs: [FlowParagraph])] = []

    init(
        session: AppSession, entry: Queries.ReadingEntry,
        page: ReadingPageTokens, onWake: @escaping (String?) -> Void
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
            ForEach(blocks, id: \.blockID) { block in
                VStack(alignment: .leading, spacing: 13) {
                    ForEach(Array(block.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                        Text(paragraph.text)
                            .font(paragraph.font(page))
                            .foregroundStyle(page.ink)
                            .lineSpacing(6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, paragraph.indent)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { onWake(block.blockID) }
            }
            if blocks.isEmpty {
                Text(" ")
                    .font(page.serif)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture { onWake(nil) }
            }
        }
        // A link's plain click opens it (F-5); the scheme guard is the same
        // one every other surface asks, so an inert address does nothing
        // rather than something surprising.
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        // 13g cold review R1-4: the ONE note-naming surface batch 7's sweep
        // missed (it rendered "" rather than "Untitled", so the grep never
        // saw it) — the display brain answers here like everywhere else.
        .help(entry.displayTitle)
        .task(id: entry.postID) {
            // The rendered projection per BLOCK (renderedText semantics —
            // chosen takes; blank takes and gaps contribute nothing), each
            // RENDERED for reading (13g L11 — one transform per block of a
            // realized row, so the cost stays ∝ what the LazyVStack
            // materialized). 13k K10: the page's own code chip rides in.
            let slots: [(String, String)] = (try? await session.database.read { [id = entry.postID] db in
                try Queries.renderPost(db, containerID: id).compactMap { slot in
                    guard let text = slot.text, !text.isEmpty else { return nil }
                    return (slot.blockID, text)
                }
            }) ?? []
            blocks = slots.map { blockID, text in
                (blockID, FlowParagraph.paragraphs(of: text, codeTint: page.codeTint))
            }
        }
    }
}
