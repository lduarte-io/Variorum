//
//  UnfiledWordTests.swift
//  VariorumTests
//
//  17y item (i) — THE CHAPTERLESS WORD IS "unfiled" (R-17y-4, her pick at the
//  question tool, `notes/plans/17y-sitting-rulings-2026-10-05.md`). Her report:
//  the Outline said "unfiled" while the move menu said "No Chapter" — two
//  words for one state; she moved an already-chapterless note to "No Chapter"
//  and read the no-op as a failure. The one word wins everywhere the state
//  shows: the Outline/Index/panel headers keep it, the move menus' destination
//  re-words to it, and the receipts follow. 13s may re-voice sentences; the
//  WORD is settled.
//
//  The cheap shape the brief names: a grep-form pin over the app's sources
//  (no surface spells the retired words) plus the shared constants.
//
//  Red-on-old, stated: `BookPanelCopy.noChapter` read "No Chapter" (the three
//  move menus — Book Panel, Index column, the book view's navigator — render
//  it), and the Add receipt read "…at the end of the book, outside the
//  chapters." — so all three tests fail on the pre-fix tree.
//

import Foundation
import Testing
@testable import Variorum

@Suite("17y (i) — the chapterless word is \"unfiled\" everywhere it shows")
struct UnfiledWordTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// Every Swift source of the Mac app and the shared home, comments
    /// stripped (a comment may still tell the history).
    private static func codeLines() throws -> [(file: String, line: String)] {
        var out: [(String, String)] = []
        for folder in ["Variorum", "Shared"] {
            let root = appRoot.appending(path: folder)
            let walker = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
            while let url = walker?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let text = try String(contentsOf: url, encoding: .utf8)
                for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if trimmed.hasPrefix("//") { continue }
                    out.append((url.lastPathComponent, String(line)))
                }
            }
        }
        return out
    }

    @Test func theMoveMenusDestinationIsTheOneWord() {
        #expect(BookPanelCopy.noChapter == BookPanelCopy.unfiled,
                "the move menus' chapterless destination says the headers' word")
        #expect(BookPanelCopy.unfiled == "unfiled")
    }

    @Test func noSurfaceSpellsTheRetiredWords() throws {
        let retired = ["\"No Chapter\"", "outside the chapters", "No chapter\""]
        let offenders = try Self.codeLines().filter { entry in
            retired.contains { entry.line.contains($0) }
        }
        #expect(offenders.isEmpty, "\(offenders.map { "\($0.file): \($0.line)" })")
    }

    @Test func theAddReceiptSaysWhereInTheOneWord() {
        let receipt = ArrivalsCopy.added("a note", chaptered: true)
        #expect(receipt.contains(BookPanelCopy.unfiled), "\(receipt)")
        #expect(!receipt.contains("outside the chapters"), "\(receipt)")
    }
}
