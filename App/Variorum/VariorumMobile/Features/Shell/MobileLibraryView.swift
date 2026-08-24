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
    /// The scraps area's model (parity C3 — the third filter's listing;
    /// constructed by the shell beside this view's own model).
    @Bindable var scraps: MobileScrapsModel
    /// The starred set (parity C3): the note rows' star door — the ONE
    /// model the shell threads to every surface with the door.
    @Bindable var stars: MobileStarsModel
    let tokens: VoiceTokens
    @ViewBuilder let tabBar: () -> TabBar
    let onOpen: (MobileRoute) -> Void
    /// The recovery surface's door (round 2 batch 4 — PR2). nil in
    /// harness/preview use.
    var onOpenRecovery: (() -> Void)?

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
                    } else if model.filter == .scraps {
                        // The scraps area (parity C3): standalone blocks
                        // with their tags, and the mint door.
                        MobileScrapsSection(model: scraps, tokens: tokens)
                    } else {
                        listingRows
                        recoveryRow
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
            if let receipt = model.receipt {
                // A landed act's own words, in the muted slot — never the
                // red one (the Mac recovery model's split).
                Text(tokens.chromeLabel(receipt))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            if let starsError = stars.error(on: .library) {
                // A star refusal fired HERE (D2 — one home per refusal,
                // clearing after a beat; "spoken where the door fired"
                // is now structurally true, not hoped).
                Text(tokens.chromeLabel(starsError))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
            }
            tabBar()
        }
        .background(tokens.room.ignoresSafeArea())
        // The listing observation restarts when the sort flips (parity
        // C3 — a way of looking; nothing is written).
        .task(id: model.sort) { await model.startAll() }
        .task { await model.startBookless() }
        // The scraps observation's lifecycle lives HERE (FIX-C3c): the
        // section's body is flat lazy-row content now, so its task
        // moved to stable chrome — it runs while the Scraps filter
        // shows and cancels when the filter leaves, exactly the old
        // section-task lifecycle.
        .task(id: model.filter) {
            if model.filter == .scraps { await scraps.start() }
        }
        .task(id: query) { await model.search(query) }
        // PR1's confirm — a real `@Bindable` projection (§15's trap (a))
        // AND `presenting:`, which is the half batch 4 was missing: without
        // it the note to delete was read back AFTER SwiftUI's dismissal had
        // cleared it, so this door confirmed and deleted NOTHING (batch
        // 4.5b's BLOCKER; the rule is at
        // `MobileLibraryViewModel.deleteNotePresented`).
        .alert(
            MobileEditorViewModel.deleteNoteConfirmTitle,
            isPresented: $model.deleteNotePresented,
            presenting: model.pendingDeleteNote
        ) { item in
            Button(tokens.chromeLabel("Delete"), role: .destructive) {
                let model = model
                Task { await model.confirmDeleteNote(item) }
            }
            Button(tokens.chromeLabel("Cancel"), role: .cancel) {}
        } message: { _ in
            Text(MobileEditorViewModel.deleteNoteConfirmDetail)
        }
    }

    /// **The recovery surface's door** (round 2 batch 4 — PR2). It is the
    /// listing's own trailing row, the `+ new book` precedent: a list of
    /// notes ends with the way to the notes that left. The path line stays
    /// two doors wide (P38's crowding lesson), and a row is a real Button —
    /// a door a pin can drive (§15's trap (b)), which a `Menu` item is not.
    @ViewBuilder
    private var recoveryRow: some View {
        if let onOpenRecovery {
            Button(action: onOpenRecovery) {
                HStack {
                    Text(tokens.chromeLabel(RecoveryCopy.surfaceName))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    Spacer()
                }
                .padding(.vertical, 11)
                .padding(.horizontal, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(RecoveryCopy.surfaceName)
        }
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
                // The ONE door word (P33: the shelf's twin reads it too).
                Text(tokens.chromeLabel(MobileNewNoteDoor.doorTitle))
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

    /// all · bookless · scraps — the filter's doors (text chrome, no
    /// icons; scraps joined at parity C3 — the Pool's phone home grew
    /// its standalone-blocks neighbor).
    private var filterRow: some View {
        HStack(spacing: 18) {
            filterDoor("All", .all)
            filterDoor("Bookless", .bookless)
            filterDoor("Scraps", .scraps)
            Spacer()
            // The sort picker (parity C3 — her ruling 9), on the ALL
            // filter only: bookless keeps the core query's own order and
            // scraps are pointer-ordered, so a sort door there could
            // never mean what it says (P-2 — it isn't rendered).
            if model.filter == .all {
                sortMenu
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 6)
    }

    /// "sort: last touched" — the four standing stamps (entry date ·
    /// created · last touched · last meaningful edit), newest first.
    private var sortMenu: some View {
        Menu {
            ForEach(MobileLibraryViewModel.sortOptions, id: \.self) { option in
                Button {
                    model.setSort(option)
                } label: {
                    if option == model.sort {
                        Label(MobileLibraryViewModel.sortWord(option),
                              systemImage: "checkmark")
                    } else {
                        Text(MobileLibraryViewModel.sortWord(option))
                    }
                }
            }
        } label: {
            Text(tokens.chromeLabel("sort: \(MobileLibraryViewModel.sortWord(model.sort))"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
        }
        .accessibilityLabel("Sort")
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
            // Star (parity C3, her ruling 10): the note row's long-press
            // — the Mac's own row-menu placement, the phone's grammar.
            .contextMenu {
                let target = StarTarget.post(item.postID)
                Button(tokens.chromeLabel(
                    MobileStarsModel.doorTitle(starred: stars.isStarred(target)))) {
                    let stars = stars
                    Task { await stars.toggle(target, from: .library) }
                }
                // Delete the note (round 2 batch 4 — PR1): the row's
                // long-press, beside Star, the phone's established
                // row-menu grammar. Move to Trash; the model confirms.
                Button(
                    tokens.chromeLabel(MobileEditorViewModel.deleteNoteTitle),
                    role: .destructive
                ) {
                    model.requestDeleteNote(item)
                }
            }
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
