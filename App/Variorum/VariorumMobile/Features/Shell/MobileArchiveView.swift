//
//  MobileArchiveView.swift
//  VariorumMobile
//
//  **THE ARCHIVE ROOM — a room you browse** (round 2, batch 6c; her
//  QUESTIONS #84 ruling, verbatim: *"Two rooms — The Mac's own asymmetry,
//  translated literally. Archive becomes a room you browse; the Trash
//  becomes a utility you visit. Two doors, two destinations, nothing
//  shared."*).
//
//  Batch 4's archived SECTION, moved whole. Its door is the Library
//  listing's trailing row — **narrowed**: it used to say *"Archived &
//  Deleted"* and open a screen holding both, and now it says **Archived**
//  and opens only this. That retirement is the point of the split: one door
//  claiming both states is the very claim her B2 ruling separated on the Mac.
//
//  **What this room is NOT, said structurally rather than remembered:**
//  there is no clock anywhere on it (archive is kept, forever — her own
//  words, *"archive is available forever and maybe still valuable even if
//  you don't want it in your current library"*), and there is **no purge
//  door** — `MobileArchiveModel` carries no `requestPurge` road at all, so
//  the round-3 rider holds by construction here rather than by a view body
//  happening not to render one.
//
//  Rows stay OPEN-able: an archived note is a *work*, not a deletion, and
//  it stays editable — the Library row's own grammar, one filter over.
//
//  **THE FILTER ROW LANDED** (the filter batch, 2026-08-31 — her #85:
//  *"Archived … needs the same filters that the regular library has"*). 6c
//  left the gap for it deliberately — a plain `ScrollView`/`LazyVStack` under
//  a two-line masthead with nothing between them — and the Library's row drops
//  into it as ONE brain (`MobileFilterRow`) rather than a second copy.
//
//  **Its door set is NARROWER than the Library's — TODAY by an OWED FACE,
//  no longer by a model fact:** the old reason here ("`reading` carries no
//  `archived_at`") was falsified by 13i-e (`Reading.archivedAt`,
//  `Operations+ReadingArchive`; the shelf long-press archives the daily
//  Journal) — the VM-5 whole-round pass's MINOR 1 corrected this header.
//  THIS FILE is where the owed archived-BOOKS group lands (MobileSoul
//  13i-e row / VM-6 (4d) — her 2026-10-04 walk mistook the hidden state
//  for a sync bug). `bookless` and `scraps` stay absent for their own
//  reasons (no core read exists for archived-and-bookless; the only
//  archived-block read is per-NOTE). The fuller trace:
//  `MobileListingFilter.archiveDoors`.
//

import SwiftUI
import VariorumCore

struct MobileArchiveView: View {
    @Bindable var model: MobileArchiveModel
    let tokens: VoiceTokens
    /// An archived note opens like any other — the see-your-data road
    /// (MobileSoul §4.3), and the reason a row here is not a dead end.
    let onOpen: (String) -> Void

    static let emptyLine = "Nothing archived."
    static let unarchiveVerb = "Unarchive"

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                // **HER #85's OWN SENTENCE, MADE REAL** — the Library's filter
                // row, same brain, in the gap 6c left for it. The door set is
                // narrowed to what CAN exist here, and the narrowing is a
                // model fact rather than a face call
                // (`MobileListingFilter.archiveDoors` carries the trace).
                MobileFilterRow(
                    doors: MobileListingFilter.archiveDoors,
                    selection: model.filter,
                    tokens: tokens,
                    select: { model.filter = $0 })
                if model.visible.isEmpty {
                    line(Self.emptyLine)
                } else {
                    ForEach(model.visible, id: \.postID) { item in
                        row(item)
                    }
                }
                // The filterless rooms' one sentence — and this room keeps it
                // (rather than the Trash's "narrow the filter to see more")
                // because its filter cannot narrow: both of its doors name
                // every row it holds. See `MobileListingFilter.archiveDoors`.
                if model.truncated {
                    line(MobileRoomListing.truncationMarker(shown: model.visible.count))
                }
            }
            .padding(.horizontal, 8)
        }
        .background(tokens.room.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { reportLine }
        .task { await model.start() }
    }

    /// The room's name and its one promise — **no clock**, which is the
    /// whole difference between this room and the other one.
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.path([RecoveryCopy.archivedSection]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Text(tokens.chromeLabel(RecoveryCopy.archivedForever))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }

    /// **The plain sentence rides as the accessibility label** — the standing
    /// rule (`MobileWriteScreen`'s own note: *labels stay plain; VoiceOver
    /// reads words, not chrome styling*), which the Terminal voice's
    /// lowercasing makes load-bearing rather than tidy. Added at the 6c fix
    /// wave with n9's marker pin, since a marker VoiceOver reads as
    /// *"showing the first 200."* is chrome leaking into speech.
    private func line(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .accessibilityLabel(text)
    }

    /// Receipts and refusals, pinned to the bottom so an act's answer is
    /// readable wherever she is scrolled (the Trash room's own shape).
    @ViewBuilder
    private var reportLine: some View {
        if model.receipt != nil || model.lastError != nil {
            VStack(alignment: .leading, spacing: 2) {
                if let receipt = model.receipt {
                    Text(tokens.chromeLabel(receipt))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                if let error = model.lastError {
                    Text(error).font(tokens.small).foregroundStyle(tokens.alarm)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(tokens.room)
        }
    }

    private func row(_ item: Queries.TimelineItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(MobileLibraryViewModel.rowTitle(item))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            HStack(spacing: 18) {
                Button {
                    let model = model
                    Task { await model.unarchive(item) }
                } label: {
                    Text(tokens.chromeLabel(Self.unarchiveVerb))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Self.unarchiveVerb)
                Button {
                    onOpen(item.postID)
                } label: {
                    Text(tokens.chromeLabel("Open note"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open note")
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
    }
}
