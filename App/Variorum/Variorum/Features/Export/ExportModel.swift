//
//  ExportModel.swift
//  Variorum
//
//  Phase 11b, Step B1 — the export faces' model: one-shot projections read
//  off-main through Queries (the core owns every shape; this file never
//  re-implements a join or a section), written wherever the author's panel
//  pointed. Exports are ONE-WAY projections — nothing here writes a row.
//

import AppKit
import Foundation
import GRDB // Database in the reader-pool projections
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

// `ExportWriter` — the manifest-to-disk writer this model uses — moved to
// `Shared/ExportWriter.swift` at 13l Act 5 (row 16), unchanged: the
// automated plain-text insurance needs the same writer, and this file's
// `import AppKit` made it Mac-only by compilation. Call sites below are
// untouched.

@MainActor
@Observable
final class ExportModel {
    @ObservationIgnored private let session: AppSession
    private(set) var lastError: String?
    /// Human-readable result of the last export ("Exported 42 files.") —
    /// surfaced beside the gesture that ran it.
    private(set) var lastReport: String?

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - Projections (read-only, off-main via the reader pool)

    func markdown(forPost postID: String, includeVariants: Bool = false) async -> String? {
        await projection { try Queries.exportPost($0, postID: postID, includeVariants: includeVariants) }
    }

    func markdown(forReading readingID: String) async -> String? {
        await projection { try Queries.exportReading($0, readingID: readingID) }
    }

    func markdown(forBlock blockID: String) async -> String? {
        await projection { try Queries.exportBlock($0, blockID: blockID) }
    }

    /// Basic PDF: the plain post projection through the attributed-string
    /// path (PROVISIONAL, the plan's answered interpretation 5 — Phase 13
    /// owns typography). The post title rides as the document title.
    func pdfData(forPost postID: String) async -> Data? {
        guard let pieces = await projection({ db -> (String?, String) in
            let header = try Queries.containerHeader(db, containerID: postID)
            return (header?.title, try Queries.exportPost(db, postID: postID))
        }) else { return nil }
        return PDFExporter.pdfData(title: pieces.0, body: pieces.1)
    }

    func pdfData(forReading readingID: String) async -> Data? {
        guard let body = await projection({ try Queries.exportReading($0, readingID: readingID) })
        else { return nil }
        // The reading projection already opens with "# <name>"; the PDF
        // carries the body verbatim rather than doubling the title line.
        return PDFExporter.pdfData(title: nil, body: body)
    }

    // MARK: - Writing (the author's panel picked the destination)

    func writeMarkdown(_ contents: String, to url: URL) {
        write(to: url, data: Data(contents.utf8), what: "Markdown")
    }

    func writePDF(_ data: Data, to url: URL) {
        write(to: url, data: data, what: "PDF")
    }

    /// The ONE-gesture bulk export: the whole library as a folder of plain
    /// `.md` (totality is the core projection's, pinned there). The file
    /// I/O runs DETACHED (review round 1, NIT 3): the projection already
    /// read off-main via the reader pool, but N file writes on the
    /// MainActor would hitch the UI for the gesture's duration.
    func writeBulkExport(to root: URL, includeReadings: Bool = true) async {
        do {
            let manifest = try await session.database.read { db in
                try Queries.bulkExportManifest(db, includeReadings: includeReadings)
            }
            let count = try await Task.detached {
                try ExportWriter.write(manifest, to: root)
            }.value
            lastReport = "Exported \(count) file\(count == 1 ? "" : "s")."
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The caret-block door's default filename: the block's read-time
    /// handle through the one sanitize rule, "Block" when empty.
    nonisolated static func blockExportFileName(handle: String?) -> String {
        let base = Queries.sanitizedFilename(handle ?? "")
        return "\(base.isEmpty ? "Block" : base).md"
    }

    // MARK: - Internals

    private func projection<T: Sendable>(
        _ read: @Sendable @escaping (GRDB.Database) throws -> T
    ) async -> T? {
        do {
            let value = try await session.database.read(read)
            lastError = nil
            return value
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    private func write(to url: URL, data: Data, what: String) {
        do {
            try data.write(to: url, options: .atomic)
            lastReport = "Exported \(what) to \(url.lastPathComponent)."
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }
}

extension UTType {
    /// Markdown for the save panels (declared by extension — the SDK
    /// carries no first-class markdown type; plain text is the fallback).
    static var markdownFile: UTType {
        UTType(filenameExtension: "md") ?? .plainText
    }
}

// MARK: - Panels (author-visible moments; thin, untested UI)

@MainActor
enum ExportPanels {
    /// Save panel for a single `.md`/`.pdf` file. Blocking modal — a menu
    /// gesture's synchronous companion (the sandbox grants write access to
    /// whatever the author picks).
    static func saveFile(defaultName: String, type: UTType) -> URL? {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [type]
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = defaultName
        return panel.runModal() == .OK ? panel.url : nil
    }

    /// Folder chooser for the bulk export.
    /// `directoryURL` (pre-13x 5b): where the panel OPENS — the iCloud Drive
    /// offer points it at iCloud Drive's root; the powerbox honors the hint
    /// and the pick is the sandbox-legal road to a folder outside the
    /// container. nil = the panel's own default.
    static func chooseFolder(prompt: String, directoryURL: URL? = nil) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = prompt
        if let directoryURL { panel.directoryURL = directoryURL }
        return panel.runModal() == .OK ? panel.url : nil
    }
}
