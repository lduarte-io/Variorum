//
//  ImportFacesTests.swift
//  VariorumTests
//
//  Phase 11b, Step B2 — the drop-in import faces: files/text through
//  ImportModel land via the import OPERATIONS (segmentation and undo are
//  core-pinned in ImportOperationTests); the dropped file is a ONE-WAY
//  source — bytes and mtime untouched, pinned here.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import UniformTypeIdentifiers
import VariorumCore
@testable import Variorum

@MainActor
private func withImportSession<T>(
    _ body: @MainActor (AppSession, ImportModel) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        return try await body(session, ImportModel(session: session))
    }
}

@MainActor
@Suite("Import faces (Phase 11b, B2)")
struct ImportFacesTests {
    private func tempFile(_ name: String, _ contents: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-import-\(UUID().uuidString)-\(name)")
        try Data(contents.utf8).write(to: url)
        return url
    }

    @Test func aDroppedFileBecomesAPostAndTheSourceIsUntouched() async throws {
        try await withImportSession { session, importer in
            let url = try tempFile("My Note.md", "Alpha.\n\nBeta.")
            defer { try? FileManager.default.removeItem(at: url) }
            let bytesBefore = try Data(contentsOf: url)
            let mtimeBefore = try FileManager.default
                .attributesOfItem(atPath: url.path)[.modificationDate] as? Date

            await importer.importFiles([url], into: .library)
            #expect(importer.lastError == nil)
            #expect(importer.lastReport == "Imported 1 post.")

            let posts = try await session.database.read { try Queries.library($0) }
            #expect(posts.count == 1)
            // Title from the filename (extension stripped); contents
            // segmented by the effective default and re-exportable.
            #expect(posts[0].title?.hasSuffix("My Note") == true)
            let exported = try await session.database.read {
                [postID = posts[0].postID] db in
                try Queries.exportPost(db, postID: postID)
            }
            #expect(exported == "Alpha.\n\nBeta.")

            // ONE-WAY source: bytes and mtime byte-identical after import.
            #expect(try Data(contentsOf: url) == bytesBefore)
            let mtimeAfter = try FileManager.default
                .attributesOfItem(atPath: url.path)[.modificationDate] as? Date
            #expect(mtimeAfter == mtimeBefore)
        }
    }

    @Test func multipleFilesMintOnePostEachAndNonTextSkipsVisibly() async throws {
        try await withImportSession { session, importer in
            let first = try tempFile("One.md", "First body.")
            let second = try tempFile("Two.txt", "Second body.")
            let binary = try tempFile("Photo.png", "not really text")
            defer {
                for url in [first, second, binary] {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            await importer.importFiles([first, second, binary], into: .library)
            let report = importer.lastReport ?? ""
            #expect(report.contains("Imported 2 posts."))
            #expect(report.contains("(not plain text)"))
            let count = try await session.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'")
            }
            #expect(count == 2)
        }
    }

    @Test func droppedTextLandsInThePoolAsScraps() async throws {
        try await withImportSession { session, importer in
            let pool = try session.operations.createPool(title: "Pool")
            await importer.importText("Scrap one.\n\nScrap two.", into: .pool(pool.id))
            #expect(importer.lastError == nil)
            #expect(importer.lastReport == "Added to the pool.")
            let texts = try await session.database.read { [poolID = pool.id] db in
                try Queries.renderPost(db, containerID: poolID).map { $0.text ?? "" }
            }
            #expect(texts == ["Scrap one.\n", "Scrap two."])
        }
    }

    // MARK: - Review round 1, NIT 4 (one gesture, one undo entry)

    @Test func aMultiFileDropUnwindsWithOneUndo() async throws {
        try await withImportSession { session, importer in
            let urls = try (1...3).map { index in
                try tempFile("File \(index).md", "Body \(index).")
            }
            defer {
                for url in urls { try? FileManager.default.removeItem(at: url) }
            }
            await importer.importFiles(urls, into: .library)
            #expect(importer.lastReport == "Imported 3 posts.")

            // ONE drop gesture = ONE compound entry: a single undo unwinds
            // every imported post, and nothing is left on the stack.
            let stack = session.undoStack
            let label = try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            #expect(label == "Import")
            let live = try await session.database.read {
                try Int.fetchOne(
                    $0,
                    sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            #expect(live == 0)
            let second = try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            #expect(second == nil)
        }
    }

    // Round 2, MINOR: the pin must drive the DROP DOOR itself — a Finder
    // drag delivers one NSItemProvider per file, and round 1's fix only
    // batched the array path the File-menu door uses.
    @Test func aMultiProviderDropRegistersOneCompoundAndOneReport() async throws {
        try await withImportSession { session, importer in
            let urls = try (1...3).map { index in
                try tempFile("Drop \(index).md", "Body \(index).")
            }
            defer {
                for url in urls { try? FileManager.default.removeItem(at: url) }
            }
            // One provider per file, carrying public.file-url exactly as a
            // Finder drag does (the same registration shape the pool's own
            // drag provider uses).
            let providers = urls.map { url in
                let provider = NSItemProvider()
                provider.registerDataRepresentation(
                    forTypeIdentifier: UTType.fileURL.identifier, visibility: .all
                ) { completion in
                    completion(url.dataRepresentation, nil)
                    return nil
                }
                return provider
            }
            #expect(importer.handleDrop(providers, into: .library))

            // Quiescence: all three posts landed (bounded wait — the
            // provider loads complete async).
            var live = 0
            for _ in 0..<2000 {
                live = try await session.database.read {
                    try Int.fetchOne(
                        $0,
                        sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
                } ?? 0
                if live == 3 { break }
                try? await Task.sleep(for: .milliseconds(2))
            }
            #expect(live == 3)

            // ONE drop = ONE aggregated report and ONE undo entry.
            #expect(importer.lastReport == "Imported 3 posts.")
            let stack = session.undoStack
            let label = try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            #expect(label == "Import")
            let after = try await session.database.read {
                try Int.fetchOne(
                    $0,
                    sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            }
            #expect(after == 0)
            let second = try await session.runner.run { ops in
                try stack.undo(with: ops)
            }
            #expect(second == nil)
        }
    }

    @Test func anEmptyDropReportsInsteadOfMinting() async throws {
        try await withImportSession { session, importer in
            let blank = try tempFile("Blank.md", " \n \n")
            defer { try? FileManager.default.removeItem(at: blank) }
            await importer.importFiles([blank], into: .library)
            #expect(importer.lastReport?.contains("Skipped") == true)
            let count = try await session.database.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post'")
            }
            #expect(count == 0)
        }
    }
}
