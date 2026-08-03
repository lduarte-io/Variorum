//
//  MobileLibraryView.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the Library tab (M7): everything, newest
//  first; search over the standing catalog scope; the bookless filter
//  (the Pool's phone home); the "+ new note" minting door. Voiced chrome
//  in the mockup's register; reading is cheap (P3 — no live editor
//  here).
//

import SwiftUI
import VariorumCore

struct MobileLibraryView<TabBar: View>: View {
    @Bindable var model: MobileLibraryViewModel
    let tokens: VoiceTokens
    @ViewBuilder let tabBar: () -> TabBar
    let onOpen: (MobileRoute) -> Void

    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            pathLine
            searchField
            filterRow
            ScrollView {
                LazyVStack(spacing: 0) {
                    if let hits = model.hits {
                        hitRows(hits)
                    } else {
                        listingRows
                    }
                }
                .padding(.horizontal, 8)
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
        .task { await model.startAll() }
        .task { await model.startBookless() }
        .task(id: query) { await model.search(query) }
    }

    private var pathLine: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(tokens.path(["Library"]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            Button {
                Task {
                    if let postID = await model.newNote() {
                        onOpen(.note(postID, focus: true))
                    }
                }
            } label: {
                Text(tokens.chromeLabel("+ New Note"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("New Note")
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 6)
    }

    private var searchField: some View {
        TextField(tokens.chromeLabel("Search notes, books…"), text: $query)
            .textFieldStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.ink)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tokens.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(tokens.line, lineWidth: 1)))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
    }

    /// all · bookless — the filter's two doors (text chrome, no icons).
    private var filterRow: some View {
        HStack(spacing: 18) {
            filterDoor("All", .all)
            filterDoor("Bookless", .bookless)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    private func filterDoor(_ label: String, _ target: MobileLibraryViewModel.Filter) -> some View {
        Button {
            model.filter = target
        } label: {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(model.filter == target ? tokens.ink : tokens.faint)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(model.filter == target ? .isSelected : [])
    }

    private var listingRows: some View {
        ForEach(model.visible, id: \.postID) { item in
            Button {
                onOpen(.note(item.postID, focus: false))
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(MobileLibraryViewModel.rowTitle(item))
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    Spacer(minLength: 12)
                    if let day = item.entryDate {
                        Text(day)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func hitRows(_ hits: [Queries.CatalogHit]) -> some View {
        if hits.isEmpty {
            Text(tokens.chromeLabel("Nothing found."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 24)
        }
        ForEach(Array(hits.enumerated()), id: \.offset) { _, hit in
            if let route = MobileLibraryViewModel.destination(for: hit) {
                Button {
                    onOpen(route)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(hit.title)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        Spacer(minLength: 12)
                        Text(tokens.chromeLabel(hitDetail(hit)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func hitDetail(_ hit: Queries.CatalogHit) -> String {
        switch hit.kind {
        case .book: return hit.detail ?? "book"
        case .post: return hit.detail ?? "note"
        case .block: return hit.detail.map { "block · \($0)" } ?? "block"
        }
    }
}
