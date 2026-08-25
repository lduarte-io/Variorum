//
//  TimelineView.swift
//  Variorum
//
//  The timeline view (Phase 10 Step 6 — AppSpec §12): the Phase 4 keyset
//  pages rendered under their RATIFIED strict-stamp semantics — a timeline
//  keyed on a stamp lists ONLY rows carrying it (an undated post is not on
//  the entry-date timeline); the `library` lens is the show-everything
//  total surface (missing stamps COALESCE to created_at). Pagination is
//  keyset: a page costs the page, wherever it sits (P1) — "Load more"
//  continues from the cursor. Item affordance: open-in-editor only
//  (interpretation 2, PROVISIONAL). Functional, unstyled.
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class TimelineViewModel {
    enum Lens: String, CaseIterable, Identifiable {
        case entryDate = "Entry date"
        case lastTouched = "Last touched"
        case lastMajorRevision = "Major revision"
        case library = "All notes"
        var id: String { rawValue }
    }

    @ObservationIgnored private let session: AppSession
    let pageSize = 50

    private(set) var lens: Lens = .lastTouched
    private(set) var items: [Queries.TimelineItem] = []
    private(set) var exhausted = false
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    func setLens(_ new: Lens) async {
        lens = new
        await reload()
    }

    func reload() async {
        items = []
        exhausted = false
        await loadMore()
    }

    /// One page per call — keyset for the stamp lenses (the cursor is the
    /// last item), a growing top-N for the total surface (a deliberate
    /// user action, cost ∝ post count, never corpus text).
    func loadMore() async {
        guard !exhausted else { return }
        do {
            switch lens {
            case .library:
                let limit = items.count + pageSize
                let page = try await session.database.read { [limit] db in
                    try Queries.library(db, sort: .lastTouched, direction: .desc, limit: limit)
                }
                exhausted = page.count < limit
                items = page
            case .entryDate, .lastTouched, .lastMajorRevision:
                let order: Queries.TimelineOrder = switch lens {
                case .entryDate: .entryDate
                case .lastMajorRevision: .lastMajorRevision
                default: .lastTouched
                }
                let cursor = items.last
                let page = try await session.database.read { [pageSize] db in
                    try Queries.timelinePage(
                        db, order: order, direction: .desc, after: cursor, limit: pageSize)
                }
                exhausted = page.count < pageSize
                items += page
            }
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }
}

struct TimelineView: View {
    let session: AppSession
    var openPost: (String) -> Void
    @State private var model: TimelineViewModel

    init(session: AppSession, openPost: @escaping (String) -> Void) {
        self.session = session
        self.openPost = openPost
        _model = State(initialValue: TimelineViewModel(session: session))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Picker("Timeline", selection: Binding(
                get: { model.lens },
                set: { new in Task { await model.setLens(new) } })
            ) {
                ForEach(TimelineViewModel.Lens.allCases) { lens in
                    Text(lens.rawValue).tag(lens)
                }
            }
            .pickerStyle(.segmented)
            .padding(8)
            List {
                ForEach(model.items, id: \.postID) { item in
                    Button {
                        openPost(item.postID)
                    } label: {
                        HStack {
                            Text(item.displayTitle)
                            if let date = item.entryDate {
                                Text(date).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(item.stamp)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if !model.exhausted {
                    Button("Load More") {
                        Task { await model.loadMore() }
                    }
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(.caption)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.reload() }
    }
}
