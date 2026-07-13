//
//  BookView.swift
//  Variorum
//
//  The continuous book view (Phase 10 Step 4 — AppSpec §12): the reading's
//  posts in ONE continuous scroll, NOT paginated. Unfocused posts render
//  through the read-cheap tier (Step 2); exactly one post upgrades to the
//  live inline editor on click (Step 3's handoff — teardown flushes the
//  leaving post, the arriving editor seeds the clicked caret). LazyVStack
//  is the virtualization: off-viewport posts never instantiate (P3).
//  Functional, unstyled (Phase 13 owns beauty).
//

import SwiftUI
import VariorumCore

struct BookView: View {
    let session: AppSession
    let readingID: String
    var readingName: String?
    @State private var model: BookViewModel
    @State private var focus = BookFocusState()

    /// `model` is injectable for tests (hosted `.task` appearance callbacks
    /// don't fire under the test host — tests drive `adopt` by hand).
    init(
        session: AppSession, readingID: String, readingName: String? = nil,
        model: BookViewModel? = nil
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        _model = State(initialValue: model ?? BookViewModel(session: session, readingID: readingID))
    }

    @State private var scrubFraction: Double = 0
    @State private var scrubLabel: String?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    if let name = readingName ?? model.readingName {
                        Text(name).font(.title2).padding(.bottom, 8)
                    }
                    if model.entries.isEmpty {
                        Text("This reading has no posts yet.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(model.entries.enumerated()), id: \.element.postID) { i, entry in
                        if let section = model.sectionHeader(at: i) {
                            Text(section)
                                .font(.headline)
                                .padding(.top, 12)
                        }
                        postHeader(entry)
                        postBody(entry)
                            .padding(.bottom, 16)
                    }
                    if model.truncated {
                        // Never a SILENT cut (round 1 NIT) — the dated home's
                        // surface says what it isn't showing.
                        Text("Showing the first \(BookViewModel.entryWindow) posts — "
                            + "the rest of this reading isn't loaded yet "
                            + "(windowing arrives with Phase 12).")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    }
                }
                .padding(12)
            }
            .safeAreaInset(edge: .bottom) {
                // BOOK-SCRUB (Phase 11, A5 — the Phase 6 memo's ruling):
                // MODEL-DRIVEN — the post list is the scrubber's domain
                // (page = a post; 50 entries = 50 pages even if one is 10k
                // words), never live text geometry. Landing is an anchor
                // scroll over the model; the hybrid jump remains the
                // WITHIN-post primitive (caret reveals after focus) —
                // reconciliation recorded in the closeout.
                if model.entries.count > 1 {
                    VStack(spacing: 2) {
                        Slider(value: Binding(
                            get: { scrubFraction },
                            set: { fraction in
                                scrubFraction = fraction
                                if let target = model.scrubTarget(fraction: fraction) {
                                    scrubLabel = scrubTitle(target)
                                    proxy.scrollTo("page-\(target.postID)", anchor: .top)
                                }
                            }), in: 0...1)
                        if let scrubLabel {
                            Text(scrubLabel)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.bar)
                }
            }
        }
        .task { await model.start() }
        .overlay(alignment: .bottom) {
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    private func scrubTitle(_ entry: Queries.ReadingEntry) -> String {
        let index = model.entries.firstIndex { $0.postID == entry.postID } ?? 0
        let title = entry.title?.isEmpty == false ? entry.title! : "Untitled"
        return "Page \(index + 1) of \(model.entries.count) — \(title)"
    }

    private func postHeader(_ entry: Queries.ReadingEntry) -> some View {
        HStack(spacing: 6) {
            Text(entry.title?.isEmpty == false ? entry.title! : "Untitled")
                .font(.subheadline.weight(.semibold))
            if let date = entry.entryDate {
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
        .id("page-\(entry.postID)")  // the scrubber's landing anchor
    }

    @ViewBuilder
    private func postBody(_ entry: Queries.ReadingEntry) -> some View {
        if focus.focusedPostID == entry.postID {
            // The ONE live editor (P3 by construction: a single focused id).
            EditorView(
                session: session, postID: entry.postID, inline: true,
                caretSeed: focus.caretSeed, fanSeed: focus.fanSeed)
                .id(entry.postID)
        } else {
            ReadPostView(
                session: session, postID: entry.postID,
                onFocusRequest: { offset in
                    focus.focus(entry.postID, caret: offset)
                },
                onBadgeTap: { blockID in
                    // Interpretation 1 (PROVISIONAL): focus FIRST, then the
                    // fan panel opens on the one live surface.
                    focus.focus(entry.postID, fanBlock: blockID)
                })
                .id("read-\(entry.postID)")
        }
    }
}
