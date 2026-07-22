//
//  PagedBookView.swift
//  Variorum
//
//  13b Stage 4, Batch 4F (S4-9(2), ledger N31) — the Kindle-style PAGED
//  view, her words: "flip through the pages and scroll on the bottom
//  horizontal bar, but each page is a post with a verticle scroll that
//  could be as long as a post can be. so i could flip through the 'book'
//  of my journal." Page = a POST (the Phase 6 memo's model-driven ruling:
//  the post list is the page domain — never live text geometry); vertical
//  scroll within the page (any length); ◀ ▶ flips + a bottom horizontal
//  scrub bar over the SAME `scrubIndex` brain as the scroll view's
//  scrubber. P3 by construction: exactly ONE page mounts — read-cheap
//  (ReadPostView) until a click upgrades it to the one live editor
//  (`BookViewModel.focus`, the standing focus machinery); flipping
//  releases focus (pages open calm; the unmounting editor's teardown
//  flushes pending text through the per-post coordinator).
//

import SwiftUI
import VariorumCore

struct PagedBookView: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            if let entry = model.currentPage {
                pageHeader(entry)
                Divider().overlay(tokens.line)
                ScrollView {
                    pageBody(entry)
                        .frame(maxWidth: 760, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                }
                // A new page is a new scroll — never the old page's offset.
                .id("paged-scroll-\(entry.postID)")
            } else {
                Spacer()
                Text("This book has no posts yet.")
                    .foregroundStyle(tokens.muted)
                Spacer()
            }
        }
        .safeAreaInset(edge: .bottom) { scrubBar }
        .onAppear { model.seedPageFromFocus() }
    }

    // MARK: - The page

    @ViewBuilder
    private func pageHeader(_ entry: Queries.ReadingEntry) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 1) {
                if let chapter = chapterName(entry) {
                    Text(tokens.chromeLabel(chapter))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                HStack(spacing: 6) {
                    Text(entryTitle(entry))
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    if let date = entry.entryDate {
                        Text(date)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
            Button(tokens.chromeLabel("open ↗")) {
                NotificationCenter.default.post(
                    name: .variorumOpenPost, object: nil,
                    userInfo: ["postID": entry.postID])
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help("Open this post in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 10)
        .background(tokens.surface)
    }

    /// The read-cheap page, upgrading to THE one live editor on click —
    /// exactly the book body's tier split (P3), one page at a time.
    @ViewBuilder
    private func pageBody(_ entry: Queries.ReadingEntry) -> some View {
        if model.focusedPostID == entry.postID {
            EditorView(
                session: session, postID: entry.postID, inline: true,
                caretSeed: model.caretSeed, fanSeed: model.fanSeed)
                .id(entry.postID)
        } else {
            ReadPostView(
                session: session, postID: entry.postID,
                onFocusRequest: { offset in
                    model.focus(entry.postID, caret: offset)
                },
                onBadgeTap: { blockID in
                    model.focus(entry.postID, fanBlock: blockID)
                })
                .id("paged-read-\(entry.postID)")
        }
    }

    // MARK: - The bottom horizontal scrub bar (her letter; the one
    // model-driven brain — `BookViewModel.scrubIndex` over the post list)

    @ViewBuilder
    private var scrubBar: some View {
        if !model.entries.isEmpty {
            VStack(spacing: 2) {
                HStack(spacing: 10) {
                    Button("◀") { model.flipPage(by: -1) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(model.pagedIndex == 0)
                        .help("The previous page (each page is a post)")
                    if model.entries.count > 1 {
                        Slider(
                            value: Binding(
                                get: {
                                    Double(model.pagedIndex)
                                        / Double(max(model.entries.count - 1, 1))
                                },
                                set: { fraction in
                                    if let index = BookViewModel.scrubIndex(
                                        fraction: fraction, count: model.entries.count) {
                                        model.openPage(index)
                                    }
                                }),
                            in: 0...1)
                    } else {
                        Spacer()
                    }
                    Button("▶") { model.flipPage(by: 1) }
                        .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        .disabled(model.pagedIndex >= model.entries.count - 1)
                        .help("The next page")
                }
                if let entry = model.currentPage {
                    Text(tokens.chromeLabel(
                        "page \(model.pagedIndex + 1) of \(model.entries.count) — \(entryTitle(entry))"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }

    // MARK: - Small reads

    private func entryTitle(_ entry: Queries.ReadingEntry) -> String {
        entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
    }

    /// The page's chapter context (curated books with chapters): the
    /// membership's live section name, read from the structure model's
    /// observed assignments — a dangling pointer reads as unsectioned,
    /// exactly like everywhere else.
    private func chapterName(_ entry: Queries.ReadingEntry) -> String? {
        guard structure.chaptersActive,
              let sectionID = structure.assignments[entry.postID]
        else { return nil }
        return structure.sections.first { $0.id == sectionID }?.name
    }
}
