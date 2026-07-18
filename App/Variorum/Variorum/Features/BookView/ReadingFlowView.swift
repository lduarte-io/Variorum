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

    @State private var paragraphs: [String] = []

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
                Text(paragraph)
                    .font(page.serif)
                    .foregroundStyle(page.ink)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if paragraphs.isEmpty {
                Text(" ")
                    .font(page.serif)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onWake() }
        .help(entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? ""))
        .task(id: entry.postID) {
            // The rendered projection, split for display at paragraph
            // boundaries (renderedText semantics — chosen takes, blank
            // takes skip; nothing here re-decides joins).
            let text: String? = try? await session.database.read { [id = entry.postID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            paragraphs = (text ?? "")
                .components(separatedBy: "\n")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
    }
}
