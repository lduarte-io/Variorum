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
    /// URLs whose security scope this panel is holding open (previews);
    /// released per-reference on selection change and wholesale at
    /// teardown.
    @ObservationIgnored private var accessedURLs: [URL] = []

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

    /// A file reference: the row stores a security-scoped bookmark so the
    /// sandbox re-grants access across launches (LOCAL-ONLY under sync).
    /// Falls back to a plain bookmark where security scoping is
    /// unavailable (non-sandboxed contexts mint plain bookmarks).
    func addFile(_ url: URL) async {
        do {
            let bookmark = try Self.makeBookmark(url)
            await run { ops in
                _ = try ops.addReference(
                    to: self.postID, kind: .file,
                    name: url.lastPathComponent, fileBookmark: bookmark)
            }
        } catch {
            lastError = String(describing: error)
        }
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

    nonisolated static func makeBookmark(_ url: URL) throws -> Data {
        do {
            return try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            // Outside a sandbox grant, security scoping refuses — a plain
            // bookmark still tracks the file across renames/moves.
            return try url.bookmarkData(
                options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        }
    }

    /// Resolves a file reference for preview, opening its security scope;
    /// the panel releases everything at teardown (`stopAllAccess`).
    func resolveFileURL(_ reference: Reference) -> URL? {
        guard let data = reference.fileBookmark else { return nil }
        var stale = false
        let url = (try? URL(
            resolvingBookmarkData: data, options: [.withSecurityScope],
            relativeTo: nil, bookmarkDataIsStale: &stale))
            ?? (try? URL(
                resolvingBookmarkData: data, options: [],
                relativeTo: nil, bookmarkDataIsStale: &stale))
        guard let url else {
            lastError = "The file for “\(reference.name ?? "reference")” can't be found."
            return nil
        }
        if url.startAccessingSecurityScopedResource() {
            accessedURLs.append(url)
        }
        return url
    }

    func stopAllAccess() {
        for url in accessedURLs {
            url.stopAccessingSecurityScopedResource()
        }
        accessedURLs.removeAll()
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
