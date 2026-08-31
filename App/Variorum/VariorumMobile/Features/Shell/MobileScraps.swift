//
//  MobileScraps.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C3 — the SCRAPS AREA on the phone (her
//  precision #1, verbatim: "you should be able to view your pool of
//  scraps if you want on mobile" + "and maybe add to it"). The phone
//  home is a third Library filter — All · Bookless · Scraps — beside
//  the bookless filter that is already the Pool's phone home: the
//  Library is everything, and standalone blocks are part of everything.
//
//  · VIEW — the scraps in pointer order with their block tags shown
//    leaf-first (see-your-data; the Mac's Snippets area semantics:
//    several pools are all REACHABLE — the N19 lesson — through a
//    picker that renders only when several exist, oldest the default).
//  · MINT — "+ new scrap" mints ONE standalone block in the scraps
//    container (`newBlock`), creating the container first when none
//    exists (the Mac entry bar's exact composition, byte-mirrored:
//    `createPool(title: "Pool")`).
//  · The drag-into-note door stays NOT-OWED (her ruled exclusion);
//    block-tag EDITING stays Mac-side (her ruling 3) — the tags are
//    displayed, never editable here.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileScrapsModel {
    @ObservationIgnored private let session: AppSession
    /// The bounded window (FIX-C3c — MobileSoul §2's "every list
    /// windowed"; the Library filter neighbor's own 200 mirrored). The
    /// standing pool read delivers whole (core's pool shape carries no
    /// limit — bounding the FETCH is a core seam, not a view-model's),
    /// so the window bounds what the surface BUILDS, and `count >
    /// window` is exact truth: an exact-window pool can never
    /// false-positive the marker — the probe discipline's contract,
    /// held by construction.
    @ObservationIgnored private let window: Int

    private(set) var pools: [Container] = []
    /// The WINDOWED listing (never more than `window` rows).
    private(set) var items: [Queries.PoolItem] = []
    /// True when the pool holds more than the window shows — the
    /// truncation marker's trigger (never a silent cut, P32's grammar).
    private(set) var truncated = false
    /// The pool's whole count (the delivery is whole — core's standing
    /// pool read carries no limit), so the marker can say how much of
    /// the head is unloaded.
    private(set) var totalCount = 0
    private(set) var lastError: String?
    private(set) var selectedPoolID: String?
    @ObservationIgnored private var itemsTask: Task<Void, Never>?
    @ObservationIgnored private var observedPoolID: String?

    init(session: AppSession, window: Int = 200) {
        self.session = session
        self.window = window
    }

    /// The bounded-window truncation marker (P32's neutral grammar —
    /// never a silent cut, never a platform). It renders at the list's
    /// TOP since D2: the window shows the pool's END, so what is
    /// missing is the list's head.
    nonisolated static func truncationMarker(shown: Int, of total: Int) -> String {
        let unloaded = total - shown
        return unloaded == 1
            ? "The first scrap isn't loaded — showing the latest \(shown)."
            : "The first \(unloaded) scraps aren't loaded — showing the latest \(shown)."
    }

    /// ONE window rule for both delivery roads (the observation and the
    /// headless refresh). The window keeps the pool's END — the SUFFIX
    /// (D2, the routed C3 R2-2 mechanism: a mint lands at pointer-order
    /// end, and the old first-`window` prefix made a mint past the
    /// window succeed INVISIBLY — the field cleared and no row
    /// appeared, with the mint door sitting right under the marker
    /// saying "the rest aren't loaded". The suffix window is the
    /// honest generalization of the window-bump: it slides to where
    /// mints land, so a mint is ALWAYS visible — and it matches the
    /// Library neighbor's own spirit, whose newest-first window keeps
    /// the newest visible). `count > window` stays exact truth, so an
    /// exact-window pool can never false-positive the marker.
    private func adopt(_ value: [Queries.PoolItem]) {
        truncated = value.count > window
        totalCount = value.count
        items = Array(value.suffix(window))
    }

    /// The pool the area shows — the selection, falling back to the
    /// OLDEST (the Mac `PoolViewModel.activePool`'s exact rule; a dead
    /// selection falls back the same way).
    var activePool: Container? {
        pools.first { $0.id == selectedPoolID } ?? pools.first
    }

    // MARK: - Pure brains (pinned)

    /// What a pool is called — the ONE display brain (13k K2: a
    /// nameless pool shows its created day).
    nonisolated static func poolTitle(_ pool: Container?) -> String {
        guard let pool else { return "no pool" }
        return DisplayTitle.pool(title: pool.title, createdAt: pool.createdAt)
    }

    /// A scrap row's preview text.
    nonisolated static func preview(_ item: Queries.PoolItem) -> String {
        let text = item.block.text ?? ""
        return text.isEmpty ? "(empty block)" : text
    }

    /// A scrap row's tag line — LEAF-first (the K3 chip grammar; block
    /// tags are DISPLAYED here, never editable — her ruling 3). nil
    /// when bare.
    nonisolated static func tagLine(_ paths: [String]) -> String? {
        guard !paths.isEmpty else { return nil }
        return paths.map { "#\(MobileShelfFaces.leaf($0))" }.joined(separator: " ")
    }

    // MARK: - Observation (the Mac PoolViewModel's shape)

    func start() async {
        do {
            for try await value in session.database.observePools() {
                pools = value
                let active = activePool?.id
                if active != observedPoolID {
                    restartItems(active)
                }
            }
        } catch is CancellationError {
            itemsTask?.cancel()
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The picker's door (rendered only when several pools exist —
    /// every pool REACHABLE, the N19 lesson).
    func select(poolID: String) {
        guard selectedPoolID != poolID else { return }
        selectedPoolID = poolID
        let active = activePool?.id
        if active != observedPoolID {
            restartItems(active)
        }
    }

    private func restartItems(_ poolID: String?) {
        itemsTask?.cancel()
        observedPoolID = poolID
        items = []
        truncated = false
        totalCount = 0
        guard let poolID else { return }
        itemsTask = Task { [session, weak self] in
            do {
                for try await value in session.database.observePool(poolID) {
                    self?.adopt(value)
                }
            } catch is CancellationError {
            } catch {
                self?.lastError = String(describing: error)
            }
        }
    }

    /// One-shot for headless determinism (tests drive this; the
    /// observation echoes it in production).
    func refresh() async {
        do {
            let selected = selectedPoolID
            let (pools, items) = try await session.database.read { db -> ([Container], [Queries.PoolItem]) in
                let pools = try Queries.pools(db)
                let active = pools.first { $0.id == selected } ?? pools.first
                let items = try active.map { try Queries.poolListing(db, poolID: $0.id) } ?? []
                return (pools, items)
            }
            self.pools = pools
            adopt(items)
        } catch {
            lastError = String(describing: error)
        }
    }

    // MARK: - The mint (her "maybe add to it")

    /// Mints ONE standalone block in the scraps container — the Mac
    /// entry bar's composition byte-mirrored: the active pool, created
    /// as `createPool(title: "Pool")` when none exists, then
    /// `newBlock`. Blank text is a quiet no-op (the alert's empty
    /// field). Returns true when a scrap landed.
    @discardableResult
    func mintScrap(_ text: String) async -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        do {
            var poolID = activePool?.id
            if poolID == nil {
                poolID = try await session.runner.run { ops in
                    try ops.createPool(title: "Pool")
                }.id
            }
            guard let poolID else { return false }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: poolID, text: text)
            }
            lastError = nil
            // Act 0 (R-pre13u-1): the first-write signal. Announce, move on.
            session.noteFirstWrite()
            await refresh()
            return true
        } catch {
            lastError = String(describing: error)
            await refresh()
            return false
        }
    }
}

/// The scraps section the Library's third filter shows: the picker row
/// (several pools only), the scrap rows, the truncation marker, the
/// mint door.
///
/// FIX-C3c: the body is FLAT builder content — no wrapping VStack — so
/// the rows land in the Library's own LazyVStack context and
/// materialize lazily (the round-1 mechanism: a plain VStack made the
/// whole interior ONE lazy child, built the moment the filter showed).
/// The observation's lifecycle is hosted by the Library view's
/// `.task(id: filter)` (tasks live on stable chrome, never on a lazy
/// row that can scroll away); the mint alert rides its own door.
struct MobileScrapsSection: View {
    @Bindable var model: MobileScrapsModel
    let tokens: VoiceTokens

    @State private var mintPresented = false
    @State private var mintField = ""

    @ViewBuilder
    var body: some View {
        if model.pools.count > 1 {
            poolPicker
        }
        if model.truncated {
            // The bounded window's honest marker (P32's grammar — never
            // a silent cut). At the TOP since D2: the window keeps the
            // pool's END (where a mint lands, so a mint is always
            // visible), so the unloaded rows are the list's head.
            Text(tokens.chromeLabel(
                MobileScrapsModel.truncationMarker(
                    shown: model.items.count, of: model.totalCount)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
        }
        ForEach(model.items, id: \.block.blockID) { item in
            scrapRow(item)
        }
        if model.items.isEmpty {
            Text(tokens.chromeLabel(
                "No scraps yet — loose blocks live here, outside any note."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .padding(.vertical, 20)
                .padding(.horizontal, 12)
        }
        mintRow
        if let error = model.lastError {
            Text(error)
                .font(tokens.small)
                .foregroundStyle(tokens.alarm)
                .padding(.horizontal, 12)
        }
    }

    /// Which scraps container the section shows (several pools only —
    /// every pool reachable, the N19 lesson; oldest is the default).
    private var poolPicker: some View {
        Menu {
            ForEach(model.pools, id: \.id) { pool in
                Button(MobileScrapsModel.poolTitle(pool)) {
                    model.select(poolID: pool.id)
                }
            }
        } label: {
            Text(tokens.chromeLabel("pool: \(MobileScrapsModel.poolTitle(model.activePool))"))
                .font(tokens.small)
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .accessibilityLabel("Which scraps container is shown")
    }

    private func scrapRow(_ item: Queries.PoolItem) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(MobileScrapsModel.preview(item))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            if let tags = MobileScrapsModel.tagLine(item.tagPaths) {
                Text(tokens.chromeLabel(tags))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mintRow: some View {
        Button {
            mintField = ""
            mintPresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel("+ new scrap"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New Scrap")
        // The mint alert rides its own door (the flat body has no
        // container to carry it; an alert presents modally, so its
        // attachment point only governs lifetime).
        .alert("New Scrap", isPresented: $mintPresented) {
            TextField("A loose line…", text: $mintField)
            Button("Keep") {
                let text = mintField
                let model = model
                Task {
                    if await model.mintScrap(text) { mintField = "" }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("A scrap is a standalone block — it lives here, in no note.")
        }
    }
}
