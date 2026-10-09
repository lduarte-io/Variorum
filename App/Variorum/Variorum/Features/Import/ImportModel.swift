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

    /// **WHETHER `lastReport` REPORTS A NO-OP** (the 18i ladder round 1, J29's
    /// second member). A report that names only SKIPS — every picked file
    /// refused, which an empty `.md` produces on its own (`importPost` throws
    /// `emptyImport`) — says that nothing happened, and a door that says
    /// nothing happened is a REFUSAL: it must reach her whatever her
    /// confirmations setting is (P-2), and the Library it fires from mounts no
    /// bottom bar, so a receipt there is invisible under her own default.
    ///
    /// ONE predicate with one home, the `SplitAtNewlinesCopy.acted` shape; the
    /// door routes on it through `StatusCenter.say(_:refusing:)`.
    private(set) var lastReportIsRefusal = false

    /// Plain-prose files only — the pipeline treats contents verbatim
    /// (headings stay Markdown in block text, AppSpec §14.8; nothing is
    /// parsed). Anything else is skipped with a visible note.
    /// Nonisolated: the detached file reader filters by it.
    nonisolated static let importableExtensions: Set<String> = ["md", "markdown", "txt", "text"]

    init(session: AppSession) {
        self.session = session
    }

    // MARK: - The gestures

    /// One new post per readable file (library) or one scrap batch per file
    /// (pool). Reads under the drag's security scope; reports per-file
    /// skips instead of failing the whole drop. **One gesture = ONE undo
    /// entry** (review round 1, NIT 4): the whole batch registers under a
    /// single `withCompound`, with per-file failures caught INSIDE the
    /// compound body so one bad file never unwinds its siblings.
    func importFiles(_ urls: [URL], into destination: Destination) async {
        // The reads run DETACHED (review round 2 — the same class as the
        // export writer's round-1 fix: the model is MainActor-isolated, so
        // N synchronous Data(contentsOf:) reads would hitch the run loop
        // for a large drop).
        let loaded = await Task.detached { Self.readFiles(urls) }.value
        let readable = loaded.readable
        var skipped = loaded.skipped

        var imported = 0
        if !readable.isEmpty {
            let stack = session.undoStack
            let files = readable
            let wing = session.wing.currentID  // 13i-d U5: this library's
            do {
                let outcome: (imported: Int, skipped: [String]) =
                    try await session.runner.run { ops in
                        var count = 0
                        var skips: [String] = []
                        try stack.withCompound(label: "Import", operations: ops) {
                            for file in files {
                                do {
                                    switch destination {
                                    case .library:
                                        // 13i-d U5: the current wing's library.
                                        _ = try ops.importPost(
                                            title: file.title, text: file.text, wingId: wing)
                                    case .pool(let poolID):
                                        _ = try ops.importBlocks(into: poolID, text: file.text)
                                    }
                                    count += 1
                                } catch {
                                    skips.append(
                                        "\(file.name) (\(Self.describeImportError(error)))")
                                }
                            }
                        }
                        return (count, skips)
                    }
                imported = outcome.imported
                skipped.append(contentsOf: outcome.skipped)
                lastError = nil
            } catch {
                lastError = String(describing: error)
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
    /// the report lands on this observable. **All provider loads are
    /// COLLECTED FIRST, then imported as one batch** (review round 2,
    /// MINOR — a Finder drag delivers one provider per file, and the
    /// round-1 per-provider tasks made an N-file drop N gestures: N undo
    /// entries, N overwritten reports; the compound and the aggregated
    /// report only exist per `importFiles` CALL, so the door must call it
    /// once).
    func handleDrop(_ providers: [NSItemProvider], into destination: Destination) -> Bool {
        var urlProviders: [NSItemProvider] = []
        var textProviders: [NSItemProvider] = []
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                urlProviders.append(provider)
            } else if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
                textProviders.append(provider)
            }
        }
        guard !urlProviders.isEmpty || !textProviders.isEmpty else { return false }

        // One task (created HERE, so the caller's task-locals ride along),
        // awaiting every load before the single batched import call.
        Task { @MainActor in
            var urls: [URL] = []
            for provider in urlProviders {
                if let url = await Self.loadFileURL(provider) {
                    urls.append(url)
                }
            }
            if !urls.isEmpty {
                await importFiles(urls, into: destination)
            }
            for provider in textProviders {
                if let text = await Self.loadPlainText(provider) {
                    await importText(text, into: destination)
                }
            }
        }
        return true
    }

    /// The file-reading half, off-main: extension filter, security-scoped
    /// read, forgiving decode (UTF-8, else lossy — an import should not
    /// die on one stray byte; the author sees the result immediately).
    nonisolated private static func readFiles(
        _ urls: [URL]
    ) -> (readable: [(name: String, title: String, text: String)], skipped: [String]) {
        var readable: [(name: String, title: String, text: String)] = []
        var skipped: [String] = []
        for url in urls {
            guard importableExtensions.contains(url.pathExtension.lowercased()) else {
                skipped.append("\(url.lastPathComponent) (not plain text)")
                continue
            }
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else {
                skipped.append("\(url.lastPathComponent) (unreadable)")
                continue
            }
            let text = String(data: data, encoding: .utf8)
                ?? String(decoding: data, as: UTF8.self)
            readable.append(
                (url.lastPathComponent, url.deletingPathExtension().lastPathComponent, text))
        }
        return (readable, skipped)
    }

    nonisolated private static func loadFileURL(_ provider: NSItemProvider) async -> URL? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { item, _ in
                let url: URL? = switch item {
                case let data as Data: URL(dataRepresentation: data, relativeTo: nil)
                case let url as URL: url
                default: nil
                }
                continuation.resume(returning: url)
            }
        }
    }

    nonisolated private static func loadPlainText(_ provider: NSItemProvider) async -> String? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { item, _ in
                let text: String? = switch item {
                case let data as Data: String(data: data, encoding: .utf8)
                case let string as String: string
                case let string as NSString: string as String
                default: nil
                }
                continuation.resume(returning: text)
            }
        }
    }

    // MARK: - Internals

    private func run(text: String, title: String?, into destination: Destination) async -> Bool {
        do {
            switch destination {
            case .library:
                let wing = session.wing.currentID  // 13i-d U5
                _ = try await session.runner.run { ops in
                    try ops.importPost(title: title, text: text, wingId: wing)
                }
            case .pool(let poolID):
                _ = try await session.runner.run { ops in
                    try ops.importBlocks(into: poolID, text: text)
                }
            }
            lastError = nil
            return true
        } catch {
            lastError = Self.describeImportError(error)
            return false
        }
    }

    /// Speaking refusal copy (round 2 — fire-and-speak wants words, not
    /// enum cases): the two refusals a drop can actually hit get prose;
    /// anything else falls back to the raw description (diagnosable).
    nonisolated private static func describeImportError(_ error: any Error) -> String {
        switch error {
        case OperationError.emptyImport:
            return "nothing to import"
        case OperationError.lockedPost:
            return "the destination is sealed — unseal it first"
        default:
            return String(describing: error)
        }
    }

    private func report(imported: Int, skipped: [String], into destination: Destination) {
        var parts: [String] = []
        if imported > 0 {
            switch destination {
            case .library:
                parts.append("Imported \(imported) note\(imported == 1 ? "" : "s").")
            case .pool:
                parts.append("Added to the pool.")
            }
        }
        if !skipped.isEmpty {
            parts.append("Skipped: \(skipped.joined(separator: ", ")).")
        }
        lastReport = parts.isEmpty ? nil : parts.joined(separator: " ")
        // J29: nothing arrived, so nothing landed — whatever the skips say.
        lastReportIsRefusal = imported == 0
    }
}

// (The File-menu door's panel LEFT this file at 13n-a: File ▸ Import… is the
// Variorum document format's door now — `DocumentImportPanel`, beside
// `DocumentImporter`. This model keeps the sidebar's Library drop and a
// pool's scraps drop, which stay plain-text imports.)
