//
//  ReferencePanelTests.swift
//  VariorumTests
//
//  Phase 11b, Step B3 — the reference panel's model: every gesture is one
//  of the Phase 2 reference operations (add/remove/reorder/view-state),
//  bookmarks round-trip through resolution, and the page memory rides
//  `view_state` JSON. Views are thin (PDFKit/QuickLook/WKWebView panes);
//  the real-file TCC moments are the author's — the handoff carries them.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withReferences<T>(
    _ body: @MainActor (AppSession, ReferencesViewModel, String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let post = try session.operations.createPost(title: "Sourced")
        let model = ReferencesViewModel(session: session, postID: post.id)
        return try await body(session, model, post.id)
    }
}

@MainActor
@Suite("Reference panel (Phase 11b, B3)")
struct ReferencePanelTests {
    @Test func viewStateJSONRoundTrips() {
        let state = ReferenceViewState(pdfPage: 12)
        let decoded = ReferenceViewState.decode(state.encoded())
        #expect(decoded == state)
        // Tolerant decoding: garbage and nil read as the empty state.
        #expect(ReferenceViewState.decode(nil) == ReferenceViewState())
        #expect(ReferenceViewState.decode("not json") == ReferenceViewState())
        // Unknown keys survive by being ignored (extensible vocabulary).
        #expect(ReferenceViewState.decode(#"{"pdfPage":3,"future":"x"}"#).pdfPage == 3)
    }

    @Test func addURLNormalizesTheSchemeAndNamesTheHost() async throws {
        try await withReferences { _, model, _ in
            await model.addURL("example.com/article")
            #expect(model.lastError == nil)
            #expect(model.references.count == 1)
            #expect(model.references[0].kind == .url)
            #expect(model.references[0].url == "https://example.com/article")
            #expect(model.references[0].name == "example.com")

            await model.addURL("not a url at all")
            #expect(model.lastError != nil)
            #expect(model.references.count == 1)
        }
    }

    @Test func addFileMintsAResolvableBookmark() async throws {
        try await withReferences { _, model, _ in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-ref-\(UUID().uuidString).pdf")
            try Data("pdf-ish".utf8).write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }

            await model.addFile(url)
            #expect(model.lastError == nil)
            let reference = try #require(model.references.first)
            #expect(reference.kind == .file)
            #expect(reference.name == url.lastPathComponent)
            #expect(reference.fileBookmark != nil)

            // The panel's resolution path finds the same file again.
            model.preparePreview(for: reference)
            let preview = try #require(model.preview)
            #expect(preview.failure == nil)
            let resolved = try #require(preview.fileURL)
            #expect(resolved.standardizedFileURL.path == url.standardizedFileURL.path)
            model.stopAllAccess()
        }
    }

    // MARK: - Review round 1, MAJOR 2 (scope-claim lifecycle)

    @Test func preparingTheSameReferenceTwiceClaimsOnce() async throws {
        try await withReferences { _, model, _ in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-ref-\(UUID().uuidString).pdf")
            try Data("pdf-ish".utf8).write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }
            await model.addFile(url)
            let reference = try #require(model.references.first)

            // The pre-fix panel resolved + claimed on EVERY body render;
            // the lifecycle shape claims once per URL no matter how often
            // the preview re-prepares.
            model.preparePreview(for: reference)
            model.preparePreview(for: reference)
            model.preparePreview(for: reference)
            #expect(model.accessedURLs.count <= 1)
            #expect(model.preview?.fileURL != nil)
            model.stopAllAccess()
        }
    }

    @Test func movingTheSelectionReleasesThePreviousClaim() async throws {
        try await withReferences { _, model, _ in
            let first = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-ref-a-\(UUID().uuidString).pdf")
            let second = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-ref-b-\(UUID().uuidString).pdf")
            try Data("a".utf8).write(to: first)
            try Data("b".utf8).write(to: second)
            defer {
                try? FileManager.default.removeItem(at: first)
                try? FileManager.default.removeItem(at: second)
            }
            await model.addFile(first)
            await model.addFile(second)
            let refA = try #require(model.references.first { $0.name == first.lastPathComponent })
            let refB = try #require(model.references.first { $0.name == second.lastPathComponent })

            model.preparePreview(for: refA)
            model.preparePreview(for: refB)
            // Outstanding claims are bounded by ONE preview: A's claim was
            // released when the selection moved to B.
            #expect(model.accessedURLs.count <= 1)
            #expect(!model.accessedURLs.contains {
                $0.standardizedFileURL.path == first.standardizedFileURL.path
            })
            model.stopAllAccess()
            #expect(model.accessedURLs.isEmpty)
        }
    }

    // MARK: - Review round 1, MAJOR 1 (the degraded fallback is visible)

    @Test func anUnscopedMintIsVisiblyDegraded() async throws {
        try await withReferences { _, model, _ in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-ref-\(UUID().uuidString).pdf")
            try Data("pdf-ish".utf8).write(to: url)
            defer { try? FileManager.default.removeItem(at: url) }

            // Force the degraded path: the sandbox refused scoping, the
            // mint fell back to a PLAIN bookmark (dead across relaunch).
            model.mintBookmark = { url in
                ReferencesViewModel.BookmarkMint(
                    data: try url.bookmarkData(
                        options: [], includingResourceValuesForKeys: nil, relativeTo: nil),
                    scoped: false)
            }
            await model.addFile(url)
            // The reference still lands — but NEVER silently.
            #expect(model.references.count == 1)
            #expect(model.lastError?.contains("without cross-launch access") == true)
        }
    }

    @Test func removeAndReorderRunTheOperations() async throws {
        try await withReferences { session, model, postID in
            await model.addURL("https://a.example")
            await model.addURL("https://b.example")
            await model.addURL("https://c.example")
            #expect(model.references.map(\.url) == [
                "https://a.example", "https://b.example", "https://c.example",
            ])

            // Reorder = one fractional-index move on the same row.
            let last = model.references[2]
            await model.moveUp(last.id)
            #expect(model.references.map(\.url) == [
                "https://a.example", "https://c.example", "https://b.example",
            ])
            await model.moveUp(model.references[1].id)
            #expect(model.references[0].url == "https://c.example")

            // Remove tombstones (recoverable class), never deletes the row.
            let removed = model.references[0]
            await model.remove(removed.id)
            #expect(model.references.count == 2)
            let tombstone = try await session.database.read {
                [id = removed.id] db in
                try String.fetchOne(
                    db, sql: "SELECT deleted_at FROM reference WHERE id = ?", arguments: [id])
            }
            #expect(tombstone != nil)
        }
    }

    @Test func pageMemoryPersistsThroughViewState() async throws {
        try await withReferences { _, model, _ in
            await model.addURL("https://a.example")
            let reference = try #require(model.references.first)
            await model.saveViewState(reference.id, ReferenceViewState(pdfPage: 7))
            let reloaded = try #require(model.references.first)
            #expect(model.viewState(reloaded).pdfPage == 7)
        }
    }
}
