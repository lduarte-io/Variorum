//
//  MobileShelfView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home (M7), the ratified mockup
//  §1's shape: the voiced path line ("~/shelf · 6 books" / "Shelf · 6
//  books"), the book rows with LK5's faces (note count + tags lead; ✓
//  finished a STATE on the name), the Today's Entry button (terminal's
//  blinking block cursor riding it — the quick-entry idiom), the tab bar
//  below. The settings door rides the path line's trailing edge
//  (PROVISIONAL placement, recorded).
//
//  Reading is cheap: no live editor exists here at all (P3); the list is
//  author-scale (a shelf holds books, not corpus).
//

import SwiftUI
import VariorumCore

struct MobileShelfView<TabBar: View>: View {
    @Bindable var model: MobileShelfViewModel
    let tokens: VoiceTokens
    @ViewBuilder let tabBar: () -> TabBar
    let onOpenBook: (String) -> Void
    /// Open a note straight into typing — the Today button's landing AND
    /// the + New Note door's (P33: "the note opens for writing").
    let onOpenForWriting: (String) -> Void
    let onSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(model.orderedBooks, id: \.reading.id) { book in
                        bookRow(book)
                    }
                    if model.orderedBooks.isEmpty {
                        Text(tokens.chromeLabel("No books yet — Today's Entry starts your journal."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 24)
                    }
                }
                .padding(.horizontal, 8)
                todayButton
            }
            if let report = model.lastReport {
                Text(tokens.chromeLabel(report))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        .task { await model.start() }
        .task { await model.refreshTags() }
    }

    /// "~/shelf · 6 books" (terminal) / "Shelf · 6 books" (study); the
    /// + New Note door (P33 — Library's twin, same path-line placement)
    /// and the settings door trailing.
    private var pathLine: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(tokens.path(["Shelf"]) + tokens.chromeLabel("  ·  \(model.books.count) book\(model.books.count == 1 ? "" : "s")"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            Button {
                Task {
                    if let postID = await model.newNote() {
                        onOpenForWriting(postID)
                    }
                }
            } label: {
                Text(tokens.chromeLabel(MobileNewNoteDoor.doorTitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New Note")
            Button {
                onSettings()
            } label: {
                Text(tokens.chromeLabel("Settings"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private func bookRow(_ book: Queries.ShelfBook) -> some View {
        Button {
            onOpenBook(book.reading.id)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                // Terminal reserves the selection-marker column (the
                // mockup's alignment); the marker itself marks nothing at
                // rest — rows are doors, not a selection.
                if !tokens.selectionMarker.isEmpty {
                    Text(tokens.selectionMarker)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .opacity(0)
                }
                Text(tokens.chromeLabel(model.rowName(for: book)))
                    .font(tokens.body.weight(.semibold))
                    .foregroundStyle(book.reading.locked ? tokens.accent : tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                Text(tokens.chromeLabel(model.rowMeta(for: book)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// "✎ today's entry ▊" — create-or-open, straight into the editor.
    private var todayButton: some View {
        Button {
            Task {
                if let postID = await model.openToday() {
                    onOpenForWriting(postID)
                }
            }
        } label: {
            HStack(spacing: 2) {
                Text(tokens.chromeLabel("✎ Today's Entry"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                if tokens.showsBlockCursor {
                    BlinkingCursorBlock(color: tokens.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(tokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(tokens.line, lineWidth: 1)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 10)
        .accessibilityLabel("Today's Entry")
    }
}

/// The terminal quick-entry idiom: a blinking block cursor
/// (`VoiceTokens.showsBlockCursor` — R1's "special little ways").
struct BlinkingCursorBlock: View {
    let color: Color
    @State private var on = true

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 7, height: 14)
            .opacity(on ? 1 : 0)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(550))
                    on.toggle()
                }
            }
            .accessibilityHidden(true)
    }
}
