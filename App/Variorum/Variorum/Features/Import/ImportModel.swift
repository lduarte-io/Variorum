//
//  ImportModel.swift
//  Variorum
//
//  Phase 11b, Step B2 — the drop-in import faces (the KnownIssues row):
//  `.md`/plain text dropped on the library mints a new post; dropped on the
//  pool it lands as scraps in that pool. Everything flows through the
//  import OPERATIONS (one transaction per gesture, `bulkSegments` inside —
//  the same pipeline as paste, so the spacing ruling rides). The dropped
//  file is a ONE-WAY SOURCE: this model only ever READS the URL — never
//  writes, never links, never re-opens it (in-place file editing is the
//  rejected diff-recovered-blob model, OverallModel §8).
//

import AppKit
import Foundation
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

@MainActor
@Observable
final class ImportModel {
    /// Where a drop lands: the library mints a post per file/drop; a pool
    /// appends scraps to itself.
    enum Destination: Equatable, Sendable {
        case library
        case pool(String)
    }

    @ObservationIgnored private let session: AppSession
    private(set) var lastError: String?
    private(set) var lastReport: String?

    /// Plain-prose files only — the pipeline treats contents verbatim
    /// (headings stay Markdown in block text, AppSpec §14.8; nothing is
    /// parsed). Anything else is skipped with a visible note.
    static let importableExtensions: Set<String> = ["md", "markdown", "txt", "text"]

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - The gestures

    /// One new post per readable file (library) or one scrap batch per file
    /// (pool). Reads under the drag's security scope; reports per-file
    /// skips instead of failing the whole drop.
    func importFiles(_ urls: [URL], into destination: Destination) async {
        var imported = 0
        var skipped: [String] = []
        for url in urls {
            guard Self.importableExtensions.contains(url.pathExtension.lowercased()) else {
                skipped.append("\(url.lastPathComponent) (not plain text)")
                continue
            }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else {
                skipped.append("\(url.lastPathComponent) (unreadable)")
                continue
            }
            // Forgiving decode: UTF-8, else lossy (an import should not die
            // on one stray byte; the author sees the result immediately).
            let text = String(data: data, encoding: .utf8)
                ?? String(decoding: data, as: UTF8.self)
            let title = url.deletingPathExtension().lastPathComponent
            if await run(text: text, title: title, into: destination) {
                imported += 1
            } else {
                skipped.append("\(url.lastPathComponent) (\(lastError ?? "empty"))")
            }
        }
        report(imported: imported, skipped: skipped, into: destination)
    }

    /// Dropped text (a dragged selection, not a file).
    func importText(_ text: String, into destination: Destination) async {
        if await run(text: text, title: nil, into: destination) {
            report(imported: 1, skipped: [], into: destination)
        }
    }

    /// The drop entry point: file URLs and plain text, the declared types.
    /// Returns whether anything was accepted; the loads complete async and
    /// the report lands on this observable.
    func handleDrop(_ providers: [NSItemProvider], into destination: Destination) -> Bool {
        var urls: [NSItemProvider] = []
        var texts: [NSItemProvider] = []
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                urls.append(provider)
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                texts.append(provider)
            }
        }
        guard !urls.isEmpty || !texts.isEmpty else { return false }

        for provider in urls {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                let url: URL? = switch item {
                case let data as Data: URL(dataRepresentation: data, relativeTo: nil)
                case let url as URL: url
                default: nil
                }
                guard let url else { return }
                Task { @MainActor in await self.importFiles([url], into: destination) }
            }
        }
        for provider in texts {
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                let text: String? = switch item {
                case let data as Data: String(data: data, encoding: .utf8)
                case let string as String: string
                case let string as NSString: string as String
                default: nil
                }
                guard let text else { return }
                Task { @MainActor in await self.importText(text, into: destination) }
            }
        }
        return true
    }

    // MARK: - Internals

    private func run(text: String, title: String?, into destination: Destination) async -> Bool {
        do {
            switch destination {
            case .library:
                _ = try await session.runner.run { ops in
                    try ops.importPost(title: title, text: text)
                }
            case .pool(let poolID):
                _ = try await session.runner.run { ops in
                    try ops.importBlocks(into: poolID, text: text)
                }
            }
            lastError = nil
            return true
        } catch {
            lastError = describeImportError(error)
            return false
        }
    }

    private func describeImportError(_ error: any Error) -> String {
        if let operationError = error as? OperationError, operationError == .emptyImport {
            return "nothing to import"
        }
        return String(describing: error)
    }

    private func report(imported: Int, skipped: [String], into destination: Destination) {
        var parts: [String] = []
        if imported > 0 {
            switch destination {
            case .library:
                parts.append("Imported \(imported) post\(imported == 1 ? "" : "s").")
            case .pool:
                parts.append("Added to the pool.")
            }
        }
        if !skipped.isEmpty {
            parts.append("Skipped: \(skipped.joined(separator: ", ")).")
        }
        lastReport = parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}

// MARK: - The File-menu door's panel (author-visible moment; thin UI)

@MainActor
enum ImportPanels {
    static func chooseFiles() -> [URL] {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        var types: [UTType] = [.plainText]
        if let markdown = UTType(filenameExtension: "md") { types.append(markdown) }
        panel.allowedContentTypes = types
        panel.prompt = "Import"
        return panel.runModal() == .OK ? panel.urls : []
    }
}
