//
//  ExportFacesTests.swift
//  VariorumTests
//
//  Phase 11b, Step B1 — the app-side export faces: the PDF path
//  (attributed-string → CTFramesetter pages), the bulk-export writer, and
//  the ExportModel's projection plumbing. The SHAPES are core-pinned in
//  ExportProjectionTests; here the faces are pinned to deliver them
//  unchanged and to write exactly where pointed.
//

import Dependencies
import Foundation
import PDFKit
import Testing
import VariorumCore
@testable import Variorum

/// A session over a fresh in-memory store with deterministic dependencies —
/// the EditorTestSupport world without the editor pipeline.
@MainActor
private func withSession<T>(
    _ body: @MainActor (AppSession) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db))
    }
}

@MainActor
@Suite("Export faces (Phase 11b, B1)")
struct ExportFacesTests {
    // MARK: - PDF (the attributed-string path)

    @Test func pdfDataIsARealDocumentCarryingTheText() throws {
        let data = PDFExporter.pdfData(title: "My Post", body: "Alpha body.\n\nBeta body.")
        #expect(data.starts(with: Array("%PDF".utf8)))
        let document = try #require(PDFDocument(data: data))
        #expect(document.pageCount == 1)
        let text = document.string ?? ""
        #expect(text.contains("My Post"))
        #expect(text.contains("Alpha body."))
        #expect(text.contains("Beta body."))
    }

    @Test func longBodiesPaginateAndEmptyBodiesStillMakeOnePage() throws {
        let long = PDFExporter.pdfData(
            title: nil,
            body: Array(repeating: "A paragraph of reasonable length for pagination.",
                        count: 400).joined(separator: "\n\n"))
        let longDocument = try #require(PDFDocument(data: long))
        #expect(longDocument.pageCount > 1)

        let empty = PDFExporter.pdfData(title: nil, body: "")
        let emptyDocument = try #require(PDFDocument(data: empty))
        #expect(emptyDocument.pageCount == 1)
    }

    // MARK: - The bulk writer

    @Test func bulkWriterCreatesSubfoldersAndWritesEveryFile() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-export-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: root) }
        let files = [
            Queries.ExportFile(relativePath: "2026-07-10 Kept.md", contents: "Kept body."),
            Queries.ExportFile(relativePath: "Archived/2026-07-12 Shelved.md", contents: "Shelved."),
            Queries.ExportFile(relativePath: "Readings/Shelf.md", contents: "# Shelf"),
        ]
        let count = try ExportWriter.write(files, to: root)
        #expect(count == 3)
        for file in files {
            let written = try String(
                contentsOf: root.appendingPathComponent(file.relativePath), encoding: .utf8)
            #expect(written == file.contents)
        }
    }

    // MARK: - The block door's default filename (review round 1, NIT 2)

    @Test func blockExportFileNameDerivesFromTheHandle() {
        #expect(ExportModel.blockExportFileName(handle: "The first sentence.")
            == "The first sentence.md")
        #expect(ExportModel.blockExportFileName(handle: "a/b:c") == "a-b-c.md")
        #expect(ExportModel.blockExportFileName(handle: nil) == "Block.md")
        #expect(ExportModel.blockExportFileName(handle: "  ") == "Block.md")
    }

    // MARK: - The model delivers the core projections unchanged

    @Test func exportModelDeliversTheCoreProjectionsAndWritesFiles() async throws {
        try await withSession { session in
            let post = try session.operations.createPost(title: "Faces")
            _ = try session.operations.newBlock(in: post.id, text: "One.\n\n")
            _ = try session.operations.newBlock(in: post.id, text: "Two.")
            let exporter = ExportModel(session: session)

            let markdown = await exporter.markdown(forPost: post.id)
            #expect(markdown == "One.\n\n\nTwo.")

            let pdf = try #require(await exporter.pdfData(forPost: post.id))
            let document = try #require(PDFDocument(data: pdf))
            #expect((document.string ?? "").contains("Faces"))

            // Write where pointed, report, never error.
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-export-\(UUID().uuidString).md")
            defer { try? FileManager.default.removeItem(at: url) }
            exporter.writeMarkdown(try #require(markdown), to: url)
            #expect(try String(contentsOf: url, encoding: .utf8) == "One.\n\n\nTwo.")
            #expect(exporter.lastError == nil)
            #expect(exporter.lastReport?.contains(url.lastPathComponent) == true)
        }
    }

    @Test func bulkExportGestureWritesTheWholeLibrary() async throws {
        try await withSession { session in
            let a = try session.operations.createPost(title: "A", entryDate: "2026-07-10")
            _ = try session.operations.newBlock(in: a.id, text: "A body.")
            let b = try session.operations.createPost(title: "B", entryDate: "2026-07-11")
            _ = try session.operations.newBlock(in: b.id, text: "B body.")

            let root = FileManager.default.temporaryDirectory
                .appendingPathComponent("variorum-bulk-\(UUID().uuidString)")
            defer { try? FileManager.default.removeItem(at: root) }

            let exporter = ExportModel(session: session)
            await exporter.writeBulkExport(to: root)
            #expect(exporter.lastError == nil)
            #expect(exporter.lastReport == "Exported 2 files.")
            // VX-126 (her option A, 2026-10-27) — a DELIBERATE byte-pin update:
            // a note's file is Copy full text's text, so a titled note's file
            // leads with its `{t:"…"}` header line.
            #expect(try String(
                contentsOf: root.appendingPathComponent("2026-07-10 A.md"),
                encoding: .utf8) == "{t:\"A\"}\n\nA body.")
            #expect(try String(
                contentsOf: root.appendingPathComponent("2026-07-11 B.md"),
                encoding: .utf8) == "{t:\"B\"}\n\nB body.")
        }
    }
}
