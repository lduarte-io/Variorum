//
//  MobileBookView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — a book's note list (scope item 1: chapters
//  honored; the Read flow itself is S4's). Pushed under the system back
//  door (minimal inline nav — the nav chrome's voice is look-track,
//  recorded); rows are read-cheap doors into THE editor.
//

import SwiftUI
import VariorumCore

struct MobileBookView: View {
    @State private var model: MobileBookViewModel
    let tokens: VoiceTokens
    let onOpen: (String) -> Void

    init(
        session: AppSession, readingID: String, tokens: VoiceTokens,
        onOpen: @escaping (String) -> Void
    ) {
        _model = State(initialValue: MobileBookViewModel(session: session, readingID: readingID))
        self.tokens = tokens
        self.onOpen = onOpen
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                ForEach(Array(model.groupedRows.enumerated()), id: \.offset) { _, group in
                    if let section = group.section {
                        Text(tokens.chromeLabel(MobileBookViewModel.sectionLabel(section)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                    }
                    ForEach(group.entries, id: \.postID) { entry in
                        noteRow(entry)
                    }
                }
                if model.entries.isEmpty {
                    Text(tokens.chromeLabel("No notes in this book yet."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(20)
                }
                if model.truncated {
                    // The bounded-window marker (never a silent cut).
                    Text(tokens.chromeLabel("Showing the first \(model.entries.count) notes — the full book lives on the Mac."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(20)
                }
            }
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.start() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let reading = model.reading {
                // ONE finished-state grammar (S3 ladder, NIT 2): the name
                // brain speaks; this header stops respelling it.
                Text(tokens.chromeLabel(MobileShelfFaces.name(for: reading)))
                    .font(tokens.title)
                    .foregroundStyle(reading.locked ? tokens.accent : tokens.ink)
            }
            if let error = model.lastError {
                Text(error).font(tokens.small).foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 6)
    }

    private func noteRow(_ entry: Queries.ReadingEntry) -> some View {
        Button {
            onOpen(entry.postID)
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(MobileBookViewModel.rowTitle(entry))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer(minLength: 12)
                if let day = entry.entryDate {
                    Text(day)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
