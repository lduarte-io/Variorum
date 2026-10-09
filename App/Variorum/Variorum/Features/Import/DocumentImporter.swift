//
//  DocumentImporter.swift
//  Variorum (Mac)
//
//  13n-a — THE IMPORT DOOR's face half (the sitting record's R-13n-6/8;
//  `notes/plans/phase-13n-a-document-format.md`). Two doors run it:
//  File ▸ Import… (a file or a folder, several at once) and a drop onto the
//  Bookcase. Both hand it URLs; it
//
//  1. READS them off the main thread under their security scope — a folder is
//     walked whole (hidden entries skipped), a file read alone — decoding
//     UTF-8, else lossily (one stray byte should not cost her the import);
//  2. PLANS them through the pure core rule (`VariorumDocumentFolder` — a
//     folder IS a book, subfolders its chapters; a file IS a note), so every
//     document is parsed BEFORE anything is minted: the first malformed line
//     anywhere refuses the WHOLE gesture, naming the file and the line —
//     never a silent partial import;
//  3. RUNS every item in ONE runner turn inside ONE compound undo entry
//     (R-13n-6: "an imported book undoes in one press" — and a gesture that
//     picked three things is one press too); an op refusing mid-gesture (a
//     folder named like a live book) rolls the gesture's earlier items back,
//     so it is all-or-nothing as well;
//  4. SPEAKS what landed (a receipt) or why nothing did (a refusal), on the
//     one status seam, its kind decided here (18i).
//
//  The files are ONE-WAY sources: read, never written, never linked (the
//  import is bulk entry, never reconciled truth — the export pin, R-13n-8).
//

import AppKit
import Foundation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

/// One thing a gesture picked, read and planned.
nonisolated enum DocumentImportItem: Equatable, Sendable {
    case note(VariorumDocument.NamedDocument)
    case book(VariorumDocument.Book)
}

/// Why a gesture imported nothing — before any op ran.
nonisolated enum DocumentImportFailure: Error, Equatable, Sendable {
    /// A document refused (its file and line inside), or a folder held
    /// nothing importable. `folder` names the picked folder when the file
    /// was read inside one.
    case document(VariorumDocument.Failure, folder: String?)
    /// A picked FILE the door does not read (by its extension).
    case notADocument(String)
    /// A file that could not be read off the disk.
    case unreadable(String)
}

/// What the door says, and where it goes after.
nonisolated struct DocumentImportSpeech: Equatable, Sendable {
    enum Kind: Equatable, Sendable { case receipt, refusal }
    let kind: Kind
    let text: String
    /// Fire-and-DO for a lone item: the book or note it made.
    let opens: SidebarSelection?
}

/// What one item of a gesture minted — the receipt's facts and the landing.
nonisolated enum DocumentImportLanded: Equatable, Sendable {
    /// `collectedBy`: the books holding the note as a MEMBER once its tags
    /// were applied (a living book whose rule hears an imported tag seats it
    /// — IC-8), earliest first; EMPTY means it is bookless, in the Pool
    /// (ladder F3 — the receipt says "to the Pool" only then).
    case note(postID: String, title: String, collectedBy: [String])
    case book(readingID: String, name: String, notes: Int, chapters: Int)

    var selection: SidebarSelection {
        switch self {
        case .note(let postID, _, _): .post(postID)
        case .book(let readingID, _, _, _): .reading(readingID)
        }
    }
}

@MainActor
enum DocumentImporter {
    // MARK: - The whole door

    /// Read, plan, run, and say — the act both doors fire. `shelfID` is the
    /// Bookcase drop's CONTEXT MINT (ladder F2 — the shelf the board is
    /// solo'd on, where a dropped folder's book lands); File ▸ Import…
    /// passes nil and the book lands unshelved.
    static func importURLs(
        _ urls: [URL], session: AppSession, shelfID: String? = nil
    ) async -> DocumentImportSpeech {
        let planned = await Task.detached { plan(urls) }.value
        let items: [DocumentImportItem]
        switch planned {
        case .failure(let failure):
            return DocumentImportSpeech(
                kind: .refusal, text: DocumentImportCopy.refusal(failure), opens: nil)
        case .success(let read):
            items = read
        }
        guard !items.isEmpty else {
            return DocumentImportSpeech(
                kind: .refusal, text: DocumentImportCopy.nothingToImport, opens: nil)
        }
        do {
            let landed = try await run(items, session: session, shelfID: shelfID)
            return DocumentImportSpeech(
                kind: .receipt, text: DocumentImportCopy.receipt(landed),
                opens: landed.count == 1 ? landed[0].selection : nil)
        } catch {
            return DocumentImportSpeech(
                kind: .refusal, text: DocumentImportCopy.refusal(operation: error), opens: nil)
        }
    }

    // MARK: - Run (one gesture, one undo entry)

    static func run(
        _ items: [DocumentImportItem], session: AppSession, shelfID: String? = nil
    ) async throws -> [DocumentImportLanded] {
        let stack = session.undoStack
        let wing = session.wing.currentID
        let database = session.database
        return try await session.runner.run { ops in
            // THE NAME PREFLIGHT (E13, before anything is minted): every
            // folder's book name must be free in the store AND distinct
            // within this gesture — so the one refusal a gesture can
            // realistically meet lands before item one, and a refused
            // gesture leaves nothing behind (not even a rolled-back book in
            // the Trash). `importBook` keeps its own in-transaction guard.
            var names = Set<String>()
            for case .book(let book) in items {
                let name = book.name.trimmingCharacters(in: .whitespacesAndNewlines)
                try ops.assertBookNameIsFree(name)
                guard names.insert(BookNaming.key(name)).inserted else {
                    throw OperationError.duplicateBookName(name: name)
                }
            }
            return try stack.withCompound(label: Operations.importUndoLabel, operations: ops) {
                try items.map { item -> DocumentImportLanded in
                    switch item {
                    case .note(let named):
                        let result = try ops.importDocument(named, wingId: wing)
                        // Ladder F3: where the note IS once the tag road has
                        // run, read in this same runner turn — the membership
                        // truth the Pool itself reads (a live member row of a
                        // live BOOK), so the receipt never says "to the Pool"
                        // about a note a living book has seated.
                        let books = try database.read { db in
                            try Queries.noteMemberships(db, postID: result.post.id).map(\.book.name)
                        }
                        return .note(
                            postID: result.post.id,
                            title: result.post.title ?? named.fallbackTitle,
                            collectedBy: books)
                    case .book(let book):
                        let result = try ops.importBook(book, wingId: wing, shelfId: shelfID)
                        return .book(
                            readingID: result.reading.id, name: result.reading.name,
                            notes: result.postIDs.count, chapters: result.sectionIDs.count)
                    }
                }
            }
        }
    }

    // MARK: - Read + plan (off the main thread; pure past the disk)

    nonisolated static func plan(_ urls: [URL]) -> Result<[DocumentImportItem], DocumentImportFailure> {
        var items: [DocumentImportItem] = []
        for url in urls {
            let scoped = url.startAccessingSecurityScopedResource()
            defer { if scoped { url.stopAccessingSecurityScopedResource() } }
            let isFolder = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
            do {
                items.append(isFolder ? try readFolder(url) : try readFile(url))
            } catch let failure as DocumentImportFailure {
                return .failure(failure)
            } catch {
                return .failure(.unreadable(url.lastPathComponent))
            }
        }
        return .success(items)
    }

    nonisolated private static func readFile(_ url: URL) throws -> DocumentImportItem {
        let name = url.lastPathComponent
        guard VariorumDocumentFolder.isImportable(name) else {
            throw DocumentImportFailure.notADocument(name)
        }
        guard let text = decoded(url) else { throw DocumentImportFailure.unreadable(name) }
        do throws(VariorumDocument.Failure) {
            return .note(try VariorumDocumentFolder.note(named: name, contents: text))
        } catch {
            throw DocumentImportFailure.document(error, folder: nil)
        }
    }

    nonisolated private static func readFolder(_ url: URL) throws -> DocumentImportItem {
        let folderName = url.lastPathComponent
        let base = url.resolvingSymlinksInPath().standardizedFileURL.pathComponents
        var files: [VariorumDocumentFolder.File] = []
        var subfolders: [String] = []
        let walker = FileManager.default.enumerator(
            at: url, includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants])
        while let item = walker?.nextObject() as? URL {
            let components = item.resolvingSymlinksInPath().standardizedFileURL.pathComponents
            guard components.count > base.count, Array(components.prefix(base.count)) == base
            else { continue }
            let relative = components.dropFirst(base.count).joined(separator: "/")
            if (try? item.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
                subfolders.append(relative)
                continue
            }
            // Only what the door reads is read off the disk at all.
            guard VariorumDocumentFolder.isImportable(relative) else { continue }
            guard let text = decoded(item) else {
                throw DocumentImportFailure.unreadable("\(folderName)/\(relative)")
            }
            files.append(.init(relativePath: relative, contents: text))
        }
        do throws(VariorumDocument.Failure) {
            return .book(try VariorumDocumentFolder.plan(
                folderName: folderName, files: files, subfolders: subfolders))
        } catch {
            throw DocumentImportFailure.document(error, folder: folderName)
        }
    }

    /// UTF-8, else lossy — the shipped import's forgiving decode.
    nonisolated private static func decoded(_ url: URL) -> String? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return String(data: data, encoding: .utf8) ?? String(decoding: data, as: UTF8.self)
    }
}

// MARK: - The File-menu door's panel

@MainActor
enum DocumentImportPanel {
    /// A file or a FOLDER (a folder is a book), several at once.
    static func choose() -> [URL] {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = true
        var types: [UTType] = [.plainText, .folder]
        for ext in VariorumDocumentFolder.importableExtensions {
            if let type = UTType(filenameExtension: ext) { types.append(type) }
        }
        panel.allowedContentTypes = types
        panel.prompt = "Import"
        panel.message = DocumentImportCopy.panelMessage
        return panel.runModal() == .OK ? panel.urls : []
    }
}

// MARK: - The Bookcase's drop (folder = book, file = note)

/// The Bookcase's file drop: it lights ONLY while the drag carries files
/// (§12's false-offer rule — a book row or a note dragged over the board is
/// the board's own business and never lights this), and fires the one door.
struct BookcaseImportDrop: DropDelegate {
    let session: AppSession
    /// The shelf the board is solo'd on (`ShelfViewModel.mintShelfID`), nil
    /// from All.
    let shelfID: String?
    @Binding var targeted: Bool
    let speak: @MainActor (DocumentImportSpeech) -> Void

    static let types: [UTType] = [.fileURL]

    func validateDrop(info: DropInfo) -> Bool {
        info.hasItemsConforming(to: Self.types)
    }

    func dropEntered(info: DropInfo) {
        targeted = validateDrop(info: info)
    }

    func dropExited(info: DropInfo) {
        targeted = false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: validateDrop(info: info) ? .copy : .forbidden)
    }

    func performDrop(info: DropInfo) -> Bool {
        targeted = false
        let providers = info.itemProviders(for: Self.types)
        guard !providers.isEmpty else { return false }
        let drop = self
        Task { @MainActor in
            var urls: [URL] = []
            for provider in providers {
                if let url = await Self.loadFileURL(provider) { urls.append(url) }
            }
            guard !urls.isEmpty else {
                drop.speak(DocumentImportSpeech(
                    kind: .refusal, text: DocumentImportCopy.nothingToImport, opens: nil))
                return
            }
            drop.speak(await drop.land(urls))
        }
        return true
    }

    /// What the drop does with the files it carried — the import door, as a
    /// CONTEXT MINT (ladder F2; AppSpec §12): a folder's book lands on the
    /// shelf the board is solo'd on, so it appears where she dropped it.
    func land(_ urls: [URL]) async -> DocumentImportSpeech {
        await DocumentImporter.importURLs(urls, session: session, shelfID: shelfID)
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
}

// MARK: - Copy for AI (R-13n-11 — the push gesture)

/// The note in the Variorum document format, onto the clipboard
/// (`Queries.variorumDocumentText` — the ONE serializer the round-trip pins
/// hold). Flushes the note's pending typing first, so what is copied is what
/// she sees. Reads only; writes no row.
@MainActor
enum CopyForAI {
    /// `pasteboard` is the tests' seam (a private named board) — every door
    /// passes nothing and writes the general one.
    static func copy(
        postID: String, session: AppSession, pasteboard: NSPasteboard = .general
    ) async {
        _ = await session.flushExistingAutosave(forPost: postID)
        do {
            let text = try await session.database.read { db in
                try Queries.variorumDocumentText(db, postID: postID)
            }
            guard !text.isEmpty else {
                session.status.refuse(DocumentImportCopy.copyForAIEmpty)
                return
            }
            pasteboard.clearContents()
            pasteboard.setString(text, forType: .string)
            session.status.receipt(DocumentImportCopy.copiedForAI)
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}
