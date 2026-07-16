//
//  ReferencesViewModel.swift
//  Variorum
//
//  Phase 11b, Step B3 — the reference panel's model (AppSpec §7
//  `reference`): per-post source material beside the draft, a VIEWING AID
//  and never a knowledge object. Rows sync; the security-scoped bookmark
//  bytes stay local-only (the serializer exclusion, core-pinned). All
//  mutations are the Phase 2 reference operations — nothing new is decided
//  here.
//

import AppKit
import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

/// The remembered view position (AppSpec §7 `view_state`, JSON): today the
/// PDF page; the shape is extensible (unknown keys survive decoding by
/// being ignored, and re-encoding writes the current vocabulary).
struct ReferenceViewState: Codable, Equatable {
    var pdfPage: Int?

    static func decode(_ json: String?) -> ReferenceViewState {
        guard let json, let data = json.data(using: .utf8),
              let state = try? JSONDecoder().decode(ReferenceViewState.self, from: data)
        else { return ReferenceViewState() }
        return state
    }

    func encoded() -> String? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return String(decoding: data, as: UTF8.self)
    }
}

@MainActor
@Observable
final class ReferencesViewModel {
    @ObservationIgnored private let session: AppSession
    let postID: String

    private(set) var references: [Reference] = []
    private(set) var lastError: String?
    /// URLs holding an OPEN security scope. Bounded by construction
    /// (review round 1, MAJOR 2): `preparePreview` claims at most one URL
    /// per preview and RELEASES the previous claim when the selection
    /// moves; `claimAccess` is claim-once per URL; `stopAllAccess` sweeps
    /// at panel teardown. Internal get so the pins can count claims.
    @ObservationIgnored private(set) var accessedURLs: [URL] = []
    /// The selected reference's prepared preview — resolved OUTSIDE any
    /// view body (the panel's `.task(id:)` drives `preparePreview`; the
    /// preview views render this state and perform no side effects).
    private(set) var preview: PreparedPreview?
    /// The bookmark mint, injectable so the degraded (unscoped) path is
    /// testable; the default mints app-scoped read-only bookmarks.
    @ObservationIgnored var mintBookmark: (URL) throws -> BookmarkMint
        = ReferencesViewModel.defaultMintBookmark

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    /// The live listing (runs for the panel's lifetime via `.task`).
    func start() async {
        do {
            for try await value in session.database.observeReferences(postID) {
                references = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// One-shot refresh — tests drive the model by hand (`.task` doesn't
    /// fire under the test host).
    func refresh() async {
        do {
            references = try await session.database.read { [postID] db in
                try Queries.references(db, containerID: postID)
            }
        } catch {
            lastError = String(describing: error)
        }
    }

    // MARK: - The add doors

    /// A URL reference: scheme-normalized (bare "example.com" reads as
    /// https), named by its host unless the author renames later.
    func addURL(_ string: String) async {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalized = trimmed.contains("://") ? trimmed : "https://\(trimmed)"
        guard let url = URL(string: normalized), url.host() != nil else {
            lastError = "Not a loadable URL: \(string)"
            return
        }
        await run { ops in
            _ = try ops.addReference(
                to: self.postID, kind: .url,
                name: url.host(), url: normalized)
        }
    }

    /// A file reference: the row stores an APP-SCOPED, READ-ONLY security
    /// bookmark so the sandbox re-grants access across launches (LOCAL-ONLY
    /// under sync; read-only because a reference is a §7 VIEWING AID —
    /// never written; page memory lives in `view_state` rows, never the
    /// file. Build-time call, coordinator-approved: if a future phase ever
    /// wants to annotate reference files, the mint option is the line to
    /// revisit — a product-call moment anyway). When scoping is refused
    /// the plain-bookmark fallback is VISIBLY degraded (review round 1,
    /// MAJOR 1): a plain bookmark grants zero sandbox access after
    /// relaunch, so silence here would be a delayed silent failure.
    func addFile(_ url: URL) async {
        await addFiles([url])
    }

    /// A multi-select add is ONE batch: per-file degraded-mint notes and
    /// failures ACCUMULATE (round 2 — `run()` clears `lastError` on each
    /// success, so a later clean add would have erased an earlier file's
    /// "without cross-launch access" warning: last-writer-wins inside one
    /// gesture broke MAJOR 1's never-silent guarantee for mixed batches).
    func addFiles(_ urls: [URL]) async {
        var notes: [String] = []
        for url in urls {
            do {
                let mint = try mintBookmark(url)
                await run { ops in
                    _ = try ops.addReference(
                        to: self.postID, kind: .file,
                        name: url.lastPathComponent, fileBookmark: mint.data)
                }
                if let failure = lastError {
                    notes.append(failure)
                } else if !mint.scoped {
                    notes.append(
                        "“\(url.lastPathComponent)” was added without cross-launch access "
                        + "(the sandbox refused a security-scoped bookmark) — its preview may "
                        + "stop working after the app relaunches; re-add it if so.")
                }
            } catch {
                notes.append("\(url.lastPathComponent): \(String(describing: error))")
            }
        }
        lastError = notes.isEmpty ? nil : notes.joined(separator: " ")
    }

    func remove(_ id: String) async {
        await run { ops in try ops.removeReference(id) }
    }

    /// Panel reorder: one fractional-index move against the neighbor
    /// (the Phase 2 operation; anchors are sibling reference ids).
    func moveUp(_ id: String) async {
        guard let index = references.firstIndex(where: { $0.id == id }), index > 0 else { return }
        let anchor = references[index - 1].id
        await run { ops in try ops.reorderReference(id, to: .before(anchor)) }
    }

    func moveDown(_ id: String) async {
        guard let index = references.firstIndex(where: { $0.id == id }),
              index < references.count - 1 else { return }
        let anchor = references[index + 1].id
        await run { ops in try ops.reorderReference(id, to: .after(anchor)) }
    }

    // MARK: - View state (page memory)

    func saveViewState(_ id: String, _ state: ReferenceViewState) async {
        let encoded = state.encoded()
        await run { ops in try ops.updateReferenceViewState(id, viewState: encoded) }
    }

    func viewState(_ reference: Reference) -> ReferenceViewState {
        ReferenceViewState.decode(reference.viewState)
    }

    // MARK: - Bookmarks & security scope

    /// What a mint produced: the bookmark bytes and whether the security
    /// scope rode along. An unscoped (plain) bookmark is DEAD across
    /// relaunch in a sandboxed app — documented sandbox design — so
    /// `scoped: false` is surfaced by `addFile`, never silent.
    struct BookmarkMint {
        let data: Data
        let scoped: Bool
    }

    nonisolated static func defaultMintBookmark(_ url: URL) throws -> BookmarkMint {
        do {
            return BookmarkMint(
                data: try url.bookmarkData(
                    options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess],
                    includingResourceValuesForKeys: nil, relativeTo: nil),
                scoped: true)
        } catch {
            return BookmarkMint(
                data: try url.bookmarkData(
                    options: [], includingResourceValuesForKeys: nil, relativeTo: nil),
                scoped: false)
        }
    }

    // MARK: - The prepared preview (review round 1, MAJOR 2)

    /// The selected reference's resolved preview state. Pure data — the
    /// preview views render it; resolution/claiming happened here, in a
    /// lifecycle context, never in a view body.
    struct PreparedPreview: Equatable {
        let referenceID: String
        /// Resolved, scope-claimed file URL (file kind; URL-kind rows
        /// render straight from their `url` column).
        let fileURL: URL?
        let failure: String?
    }

    /// Resolves and scope-claims the selection's file, releasing the
    /// PREVIOUS preview's claim first — outstanding claims are bounded by
    /// one preview regardless of session length or render count. Driven by
    /// the panel's `.task(id:)` on selection change; failures land here as
    /// preview state (never as a mutation inside a view body).
    func preparePreview(for reference: Reference?) {
        if let previous = preview?.fileURL {
            releaseClaim(previous)
        }
        guard let reference else {
            preview = nil
            return
        }
        guard reference.kind == .file else {
            preview = PreparedPreview(referenceID: reference.id, fileURL: nil, failure: nil)
            return
        }
        let display = reference.name ?? "reference"
        guard let data = reference.fileBookmark else {
            preview = PreparedPreview(
                referenceID: reference.id, fileURL: nil,
                failure: "“\(display)” has no file bookmark — remove and re-add it.")
            return
        }
        var stale = false
        let url = (try? URL(
            resolvingBookmarkData: data, options: [.withSecurityScope],
            relativeTo: nil, bookmarkDataIsStale: &stale))
            ?? (try? URL(
                resolvingBookmarkData: data, options: [],
                relativeTo: nil, bookmarkDataIsStale: &stale))
        guard let url else {
            preview = PreparedPreview(
                referenceID: reference.id, fileURL: nil,
                failure: "The file for “\(display)” can't be found — it may have moved.")
            return
        }
        claimAccess(url)
        preview = PreparedPreview(referenceID: reference.id, fileURL: url, failure: nil)
    }

    /// Claim-once per URL: a re-prepare of the same reference never stacks
    /// a second kernel claim (the accrual half of MAJOR 2).
    private func claimAccess(_ url: URL) {
        guard !accessedURLs.contains(url) else { return }
        if url.startAccessingSecurityScopedResource() {
            accessedURLs.append(url)
        }
    }

    private func releaseClaim(_ url: URL) {
        guard let index = accessedURLs.firstIndex(of: url) else { return }
        url.stopAccessingSecurityScopedResource()
        accessedURLs.remove(at: index)
    }

    func stopAllAccess() {
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        accessedURLs.removeAll()
        preview = nil
    }

    // MARK: - Internals

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
        await refresh()
    }
}
