//
//  NotePagesView.swift
//  Variorum
//
//  **READ's `read ▸ pages` face — the note as real pages** (the Act 10
//  correction round, row 5; her words: *"I want the mode where you can
//  scroll horizontally through the pages that the other one has"*). The
//  BOOK's paged engine, reused whole and never re-implemented (R-cor-5:
//  "the book's paged view reused"): `PagedReadModel` owns the estimated
//  page domain, the exact paginators and the reader's (post, page-in-post)
//  address for a book of ONE entry — this note — and the leaves are the
//  book's own `PageLeafView` (hoisted to `Core/Views/` at this touch).
//
//  Read is NOT editable (13c's A43 ruling, restated by R-cor-7 for the
//  note): a page is a `CTFrame` drawn into a view — no NSTextView, no
//  ring, no canary, no TK2 geometry. The arrow keys turn leaves, as on the
//  book's spread: nothing on this face wants them for anything else.
//

import AppKit
import SwiftUI
import VariorumCore

struct NotePagesView: View {
    let session: AppSession
    let postID: String

    @State private var pages: PagedReadModel
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
        _pages = State(initialValue: PagedReadModel(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    private var page: ReadingPageTokens { scheme == .dark ? .dark : .light }
    private var appearance: PagedReadModel.PageAppearance {
        PagedReadModel.PageAppearance(
            ink: NSColor(page.ink), chapterInk: NSColor(page.chapterInk),
            meta: NSColor(page.pageMeta), codeTint: NSColor(page.codeTint))
    }

    var body: some View {
        VStack(spacing: 0) {
            if pages.entries.isEmpty {
                Spacer()
                Text(tokens.chromeLabel("nothing to read yet"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
            } else {
                spread
            }
        }
        .background(tokens.room)
        .safeAreaInset(edge: .bottom) { flipBar }
        .task(id: postID) {
            pages.appearance = appearance
            // A book of one: the note under its own display name (the ONE
            // display brain — a dated journal entry pages under its day).
            let title = try? await session.database.read { [postID] db in
                try Queries.noteDisplayTitle(db, id: postID)
            }
            let entry = Queries.ReadingEntry(
                postID: postID, title: title ?? DisplayTitle.placeholder,
                entryDate: nil, sectionPath: nil)
            await pages.adopt(entries: [entry], chapterOpeners: [:])
        }
        .onChange(of: scheme) { _, _ in pages.appearance = appearance }
        .overlay(alignment: .bottom) {
            if let error = pages.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    // MARK: - The spread (two leaves of paper — the book's own)

    private var spread: some View {
        GeometryReader { proxy in
            let scale = pages.geometry.spreadScale(
                in: CGSize(width: proxy.size.width - 48, height: proxy.size.height - 32),
                spine: 18)
            HStack(spacing: 18) {
                ForEach(Array(pages.leaves.enumerated()), id: \.offset) { _, leaf in
                    PageLeafView(
                        leaf: leaf, geometry: pages.geometry, scale: scale,
                        page: page, appearance: appearance,
                        dark: scheme == .dark)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - The flip bar (the book's, for the same reasons)

    @ViewBuilder
    private var flipBar: some View {
        if !pages.entries.isEmpty {
            HStack(spacing: 10) {
                Button("◀") { pages.turn(by: -2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.leftArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: -2))
                    .help("Turn the leaf back — two pages (←)")
                Slider(
                    value: Binding(
                        get: { pages.scrubFraction },
                        set: { pages.scrub(fraction: $0) }),
                    in: 0...1)
                    .frame(minWidth: 120, maxWidth: 460)
                    .help("Scrub through the note — the page count is estimated "
                        + "until a page has been read")
                Button("▶") { pages.turn(by: 2) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.rightArrow, modifiers: [])
                    .disabled(!pages.canTurn(by: 2))
                    .help("Turn the leaf on — two pages (→)")
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(pages.pageLine))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(.bar)
        }
    }
}
