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
//  (interpretation 2, PROVISIONAL).
//
//  **13u4 UNIT S2 — it wears the VOICE now** (`KnownIssuesAndTechDebt`
//  row 54, found by 18j's dark sweep and re-seen in Study at its ladder:
//  *"the same dates are monospaced in List and sans in Timeline"*). It was
//  the last "functional, unstyled" listing in the Library — system fonts,
//  system ink tiers, and the RAW stored stamp column printed beside the
//  other modes' worded ones. Now: `VoiceTokens` for every size and ink, and
//  `TimeStampFace` for every stamp, which is the 18h ladder's R3-2 rule
//  (one note's time, one grammar) met a third time, one mode over.
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

        /// **Which Library sort this lens IS** (13u4 UNIT S2 — row 54).
        /// The rows' stamps are worded by the one brain, and *which* stamp
        /// a row is showing is a rule the Library already owns
        /// (`LibrarySortFace.stampSubject`) — so this lens says which sort
        /// it is rather than repeating that rule, which would be the drift
        /// class. `.library` is the total surface ordered by last-touched.
        nonisolated var sort: Queries.LibrarySort {
            switch self {
            case .entryDate: .entryDate
            case .lastTouched, .library: .lastTouched
            case .lastMajorRevision: .lastMajorRevision
            }
        }

        /// What the row's trailing stamp is ABOUT under this lens.
        nonisolated var stampSubject: TimeStampFace.Subject {
            LibrarySortFace.stampSubject(sort)
        }
    }

    @ObservationIgnored private let session: AppSession
    let pageSize = 50

    private(set) var lens: Lens = .lastTouched
    private(set) var items: [Queries.TimelineItem] = []
    private(set) var exhausted = false
    private(set) var lastError: String?
    /// **VX-268 — who reaches each LOADED row's note now** (the ONE icon on the
    /// Timeline's rows — the ticket names Timeline): `Queries.mcpNoteReaches`
    /// over the loaded rows — ∝ the pages she loaded (each "Load More" is her
    /// act), the order of the Timeline's own reads; held while it shows.
    private(set) var reach: [String: [MCPPlaceReach]] = [:]

    init(session: AppSession) {
        self.session = session
    }

    /// VX-268 — hold the loaded rows' reach (the view's `.task(id:)` on their
    /// ids — a page loaded or a lens switched restarts it).
    func holdReach(_ ids: [String]) async {
        await MCPRowReach.hold(session, { try Queries.mcpNoteReaches($0, noteIDs: ids) }) { [weak self] value in
            guard let self, self.reach != value else { return }
            self.reach = value
        }
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
                let wing = session.wing.currentID  // 13i-d U5: this library's
                let page = try await session.database.read { [limit] db in
                    try Queries.library(
                        db, sort: .lastTouched, direction: .desc, limit: limit, wingID: wing)
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
    /// VX-268 (P-1's declared ⇔ rendered walk): a row's ONE shared icon and
    /// its popover's Change… / Revoke.
    static let surfaceCapabilities: [CapabilityID] = MCPSharedIcon.surfaceCapabilities

    let session: AppSession
    var openPost: (String) -> Void
    /// "now", for the relative rule (the `CatalogRowStamp` convention: a
    /// default here, injected by a pin so the pin holds the rule and not
    /// the machine's clock).
    var now: Date = Date()
    @State private var model: TimelineViewModel

    /// The voice (13u4 UNIT S2 — `KnownIssuesAndTechDebt` row 54). The
    /// `LibraryCatalogView` shape: optional environment, the leading
    /// voice's tokens as the fallback, so a test host without a store still
    /// renders.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    init(session: AppSession, now: Date = Date(), openPost: @escaping (String) -> Void) {
        self.session = session
        self.now = now
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
                    Text(tokens.chromeLabel(lens.rawValue)).tag(lens)
                }
            }
            .pickerStyle(.segmented)
            .font(tokens.small)
            .padding(8)
            List {
                ForEach(model.items, id: \.postID) { item in
                    Button {
                        openPost(item.postID)
                    } label: {
                        row(item)
                    }
                    .buttonStyle(.plain)
                }
                if !model.exhausted {
                    Button(tokens.chromeLabel("Load More")) {
                        Task { await model.loadMore() }
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                }
            }
            .scrollContentBackground(.hidden)
            .background(tokens.surface)
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .background(tokens.surface)
        .task { await model.reload() }
        // VX-268: who reaches the loaded rows — held, re-aimed per page.
        .task(id: model.items.map(\.postID)) { await model.holdReach(model.items.map(\.postID)) }
    }

    /// **A timeline row, in the voice's own type** (row 54): the same
    /// monospace the List mode's rows wear in Terminal and the same serif
    /// they wear in Study, where this list used the system sans and read as
    /// a different app.
    ///
    /// …and the same WORDS: the stamps go through `TimeStampFace`, the one
    /// brain, where this list printed the RAW stored column — a
    /// `2026-09-20T05:11:42.318Z` beside the Library's *"edited today 1:33
    /// PM"*. That is the 18h ladder's own R3-2 finding (one note's time in
    /// two grammars), met a third time, one mode over.
    @ViewBuilder private func row(_ item: Queries.TimelineItem) -> some View {
        let subject = model.lens.stampSubject
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(item.displayTitle)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            // VX-268: the ONE shared icon (nothing when nobody reaches the
            // note) — its own button: the row's open never fires for it.
            MCPSharedIcon(reaches: model.reach[item.postID] ?? [], tokens: tokens)
            // R3-2's rule, applied by hand because this row holds one hit
            // and not a catalog's: under the entry-date lens the trailing
            // stamp already SAYS the stated day, so the row never prints
            // one day twice.
            if subject != .dated,
               let day = TimeStampFace.stamp(.dated, day: item.entryDate, now: now) {
                Text(tokens.chromeLabel(day))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            if let stamp = TimeStampFace.stamp(subject, iso: item.stamp, now: now) {
                Text(tokens.chromeLabel(stamp))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .help(TimeStampFace.tooltip(subject, iso: item.stamp) ?? stamp)
            }
        }
        .contentShape(Rectangle())
    }
}
