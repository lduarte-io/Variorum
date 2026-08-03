//
//  MobileReadView.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M8/LK9) — the Read flow: a book opens into
//  the calm continuous reading column. The ratified page (LK9, shape A —
//  mockup v1 §4): the voice-independent `ReadingPageTokens` paper (only
//  the ROOM around it follows the voice — R2's rule; dark is the token
//  layer's own), the chapter caption over each chapter's first note, the
//  centered page meta under every note. Tapping into a note opens it in
//  Write (M8's letter: "tapping into a note edits it in Write").
//
//  READ-CHEAP ONLY (P3): nothing in this column is ever a live editor —
//  rows are SwiftUI text, virtualized by the LazyVStack with per-row
//  lazy `.task` text loads (the Mac ReadingFlowView's exact shape,
//  including its round-3 laziness lesson: rows materialize near the
//  viewport only, so cost ∝ what is on screen, never the book).
//
//  COMPOSITION, not new machinery: the book's observation + grouping is
//  `MobileBookViewModel` (S3's brain, reused whole); the per-line
//  transform + LK9 strings are `MobileReadPage` (pure); the per-note
//  text read is the Mac flow's own (`renderPost` → `joinRenderedTexts`).
//  The note LIST stays reachable — the "contents" chrome door pushes it
//  (`MobileRoute.bookList`); both roads open notes in Write.
//

import SwiftUI
import VariorumCore

struct MobileReadView: View {
    let session: AppSession
    @State private var model: MobileBookViewModel
    let tokens: VoiceTokens
    /// Open a note in Write.
    let onOpen: (String) -> Void
    /// The contents door — the book's note list (S3's screen).
    let onList: () -> Void

    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, readingID: String, tokens: VoiceTokens,
        onOpen: @escaping (String) -> Void, onList: @escaping () -> Void
    ) {
        self.session = session
        _model = State(initialValue: MobileBookViewModel(session: session, readingID: readingID))
        self.tokens = tokens
        self.onOpen = onOpen
        self.onList = onList
    }

    private var page: ReadingPageTokens {
        scheme == .dark ? .dark : .light
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVStack(spacing: 26) {
                    if let reading = model.reading {
                        Text(MobileShelfFaces.name(for: reading))
                            .font(page.serifTitle)
                            .foregroundStyle(page.ink)
                            .padding(.top, 40)
                    }
                    if let error = model.lastError {
                        Text(error).font(tokens.small).foregroundStyle(.red)
                    }
                    ForEach(
                        Array(MobileReadPage.assemble(model.groupedRows).enumerated()),
                        id: \.offset
                    ) { _, chapter in
                        if let caption = chapter.caption {
                            Text(caption)
                                .font(.system(size: 11.5, weight: .medium))
                                .tracking(2.5)
                                .foregroundStyle(page.chapterInk)
                                .padding(.top, 18)
                        }
                        ForEach(chapter.notes, id: \.entry.postID) { slot in
                            MobileReadNoteView(
                                session: session, slot: slot,
                                total: model.entries.count,
                                truncated: model.truncated, page: page,
                                onOpen: { onOpen(slot.entry.postID) })
                        }
                    }
                    if model.entries.isEmpty {
                        Text("Nothing to read yet — this book has no notes.")
                            .font(page.serif)
                            .foregroundStyle(page.pageMeta)
                            .padding(.vertical, 40)
                    }
                    if model.truncated {
                        // The bounded-window marker (never a silent cut).
                        Text("Showing the first \(model.entries.count) notes — the full book lives on the Mac.")
                            .font(.system(size: 11.5))
                            .foregroundStyle(page.pageMeta)
                            .padding(.vertical, 12)
                    }
                    Text("· · ·")
                        .font(page.serif)
                        .foregroundStyle(page.pageMeta)
                        .padding(.vertical, 32)
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 24)
                .background(page.paper)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 10)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // The contents door: the note list (scanning, dates, the
                // S3 screen) — the calm column stays the book's front.
                Button(tokens.chromeLabel("contents")) { onList() }
                    .font(tokens.small)
            }
        }
        .task { await model.start() }
    }
}

/// One note on the page: lazy text, serif paragraphs, the LK9 meta; the
/// whole body is a tap target into Write (M8).
private struct MobileReadNoteView: View {
    let session: AppSession
    let slot: MobileReadPage.NoteSlot
    let total: Int
    /// The window truncated the book — the meta's "of N" is a floor and
    /// says so (S4 ladder NIT 2).
    let truncated: Bool
    let page: ReadingPageTokens
    let onOpen: () -> Void

    @State private var paragraphs: [MobileReadPage.Paragraph] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(slot.entry.displayTitle)
                .font(.system(size: 21, weight: .semibold, design: .serif))
                .foregroundStyle(page.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(paragraph.font(page))
                    .foregroundStyle(page.ink)
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ").font(page.serif)
            }
            Text(MobileReadPage.pageMeta(
                ordinal: slot.ordinal, total: total,
                chapterIndex: slot.chapterIndex, truncated: truncated))
                .font(.system(size: 11))
                .foregroundStyle(page.pageMeta)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 4)
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpen() }
        .task(id: slot.entry.postID) {
            // The rendered projection, the Mac flow's exact read: chosen
            // takes, blank takes skip, nothing re-decides joins — one
            // transform per realized row (P3's letter).
            let text: String? = try? await session.database.read {
                [id = slot.entry.postID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            paragraphs = MobileReadPage.paragraphs(of: text ?? "", codeTint: page.codeTint)
        }
    }
}
