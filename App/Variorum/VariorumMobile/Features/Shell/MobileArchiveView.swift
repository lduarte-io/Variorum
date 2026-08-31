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
//  **Structured for the NEXT batch** (her #85, which she ruled OUTRANKS
//  this work): the Library is to grow KIND filters, and *"Archive inherits
//  the same set"*. The listing here is deliberately a plain
//  `ScrollView`/`LazyVStack` under a two-line masthead with nothing between
//  them, so the Library's filter-row component drops into that gap on both
//  surfaces as ONE brain rather than a second copy.
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

    /// The Trash room's own marker, worded for a room with no filter yet
    /// (her #85 gives this room the Library's kind filters next batch, and
    /// the sentence gains its "narrow the filter" half then).
    static func truncationMarker(shown: Int) -> String {
        "Showing the first \(shown)."
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                if model.archived.isEmpty {
                    line(Self.emptyLine)
                } else {
                    ForEach(model.archived, id: \.postID) { item in
                        row(item)
                    }
                }
                if model.truncated {
                    line(Self.truncationMarker(shown: model.archived.count))
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

    private func line(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
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
