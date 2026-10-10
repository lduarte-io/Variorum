//
//  DocumentImportCopy.swift
//  Variorum (Mac)
//
//  13n-a — what the import door SAYS (Copy for AI's own two sentences moved
//  with it to `Core/Views/CopyForAI.swift` — ladder F8). Pure and static, so
//  every sentence is pinned without a window (the `WelcomeDoorCopy` shape).
//  Sentence case everywhere (her standing rule — no emphasis capitals).
//  Receipts name what landed and that ⌥⌘Z undoes it (the plan's own words:
//  "imported “o ladrão de raios” — 12 notes in 3 chapters · ⌥⌘Z undoes");
//  refusals name the file AND the line, because a malformed document is
//  fixed by opening it at that line.
//

import Foundation
import VariorumCore

nonisolated enum DocumentImportCopy {
    // MARK: - The panel

    static let panelMessage =
        "Pick a document, or a folder — a folder becomes a book, its folders its chapters."

    // MARK: - Receipts

    static let undoHint = " \u{00B7} \u{2325}\u{2318}Z undoes"

    /// What a gesture landed. One item says its name; several say counts.
    /// A note is said to land "to the Pool" ONLY when it is bookless there
    /// (ladder F3 — a living book whose rule hears an imported tag seats the
    /// note, and then the receipt names the book that took it).
    static func receipt(_ landed: [DocumentImportLanded]) -> String {
        if landed.count == 1 {
            switch landed[0] {
            case .note(_, let title, let books) where books.isEmpty:
                return "Imported \u{201C}\(title)\u{201D} to the Pool" + undoHint
            case .note(_, let title, let books):
                return "Imported \u{201C}\(title)\u{201D} \u{2014} collected by "
                    + bookNames(books) + undoHint
            case .book(_, let name, let notes, let chapters):
                return "Imported \u{201C}\(name)\u{201D} \u{2014} "
                    + bookCounts(notes: notes, chapters: chapters) + undoHint
            }
        }
        var books = 0
        var pooled = 0
        var collected = 0
        var collectors: [String] = []
        for item in landed {
            switch item {
            case .note(_, _, let by) where by.isEmpty:
                pooled += 1
            case .note(_, _, let by):
                collected += 1
                for name in by where !collectors.contains(name) { collectors.append(name) }
            case .book:
                books += 1
            }
        }
        var parts: [String] = []
        if books > 0 { parts.append(count(books, "book")) }
        if pooled > 0 { parts.append(count(pooled, "note") + " to the Pool") }
        if collected > 0 {
            parts.append(count(collected, "note") + " collected by "
                + (collectors.count == 1 ? "\u{201C}\(collectors[0])\u{201D}" : "your books"))
        }
        return "Imported " + listed(parts) + undoHint
    }

    /// The books that collected one note: “a” · “a” and “b” · “a” and N
    /// other books (earliest membership first).
    static func bookNames(_ names: [String]) -> String {
        let quoted = names.map { "\u{201C}\($0)\u{201D}" }
        switch quoted.count {
        case 0: return ""
        case 1: return quoted[0]
        case 2: return quoted[0] + " and " + quoted[1]
        default: return quoted[0] + " and \(names.count - 1) other books"
        }
    }

    /// "12 notes in 3 chapters" · "4 notes" · "1 note in 1 chapter".
    static func bookCounts(notes: Int, chapters: Int) -> String {
        let head = count(notes, "note")
        return chapters > 0 ? "\(head) in \(count(chapters, "chapter"))" : head
    }

    // MARK: - Refusals

    static let nothingToImport =
        "Nothing to import \u{2014} a folder of .md or .txt files becomes a book, and one such file a note."

    /// A refusal raised before any op ran.
    static func refusal(_ failure: DocumentImportFailure) -> String {
        switch failure {
        case .notADocument(let name):
            return "Couldn\u{2019}t import \u{201C}\(name)\u{201D} \u{2014} only .md, .txt and "
                + ".variorum files import."
        case .unreadable(let name):
            return "Couldn\u{2019}t import \u{201C}\(name)\u{201D} \u{2014} it couldn\u{2019}t be read."
        case .document(let failure, let folder):
            return refusal(failure, folder: folder)
        }
    }

    /// A document's refusal: the folder (when one was picked), the file, the
    /// line, and what is wrong there.
    static func refusal(_ failure: VariorumDocument.Failure, folder: String?) -> String {
        if failure.reason == .noImportableFiles {
            return "Couldn\u{2019}t import \u{201C}\(folder ?? failure.file ?? "the folder")\u{201D} "
                + "\u{2014} it holds no .md, .txt or .variorum files."
        }
        let subject = folder ?? failure.file ?? "the document"
        var place: [String] = []
        if folder != nil, let file = failure.file { place.append("\u{201C}\(file)\u{201D}") }
        if let line = failure.line { place.append("line \(line)") }
        let at = place.isEmpty ? "" : place.joined(separator: ", ") + ": "
        return "Couldn\u{2019}t import \u{201C}\(subject)\u{201D} \u{2014} \(at)\(reason(failure.reason))."
    }

    /// What is wrong, in a clause (sentence-case continuation).
    static func reason(_ reason: VariorumDocument.Failure.Reason) -> String {
        let header = VariorumDocument.alternatesHeader
        let footer = VariorumDocument.alternatesFooter
        switch reason {
        case .empty:
            return "there\u{2019}s nothing in it to import"
        case .alternatesWithoutParagraph:
            return "\u{201C}\(header)\u{201D} needs a paragraph of its own just above it"
        case .unterminatedAlternates:
            return "this alternates section never ends \u{2014} it needs a \u{201C}\(footer)\u{201D} line"
        case .textBeforeFirstTake:
            return "text comes before the section\u{2019}s first \u{201C}take:\u{201D} line"
        case .alternatesInsideAlternates(let openedAt):
            return "a new alternates section starts before the one on line \(openedAt) ends"
        case .endWithoutAlternates:
            return "\u{201C}\(footer)\u{201D} closes a section that was never opened"
        case .noImportableFiles:
            return "it holds no .md, .txt or .variorum files"
        case .blankChapterName:
            return "one of its folders has a blank name, and a chapter needs one"
        case .unsupportedVersion(let version):
            // 13n-b U3: a file from a newer Variorum (format version N).
            return "it was written by a newer Variorum (format version \(version)) \u{2014} update Variorum to import it"
        }
    }

    /// An operation refused mid-gesture (nothing landed — the compound
    /// rolled the gesture back).
    static func refusal(operation error: Error) -> String {
        switch error {
        case OperationError.duplicateBookName(let existing):
            return "Couldn\u{2019}t import \u{201C}\(existing)\u{201D} \u{2014} a book with that name is "
                + "already on your Bookcase. Rename the folder or the book, then import again."
        case OperationError.emptyImport:
            return nothingToImport
        default:
            return "Couldn\u{2019}t import \u{2014} " + OpsRefusalCopy.message(for: error)
        }
    }

    // MARK: - Internals

    private static func count(_ n: Int, _ noun: String) -> String {
        "\(n) \(noun)\(n == 1 ? "" : "s")"
    }

    /// "a" · "a and b" · "a, b and c".
    private static func listed(_ parts: [String]) -> String {
        guard let last = parts.last, parts.count > 1 else { return parts.first ?? "" }
        return parts.dropLast().joined(separator: ", ") + " and " + last
    }
}
