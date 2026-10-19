//
//  LookInsideCopyDoorTests.swift
//  VariorumTests — VX-307 U2c, VX-413 (her ruling 2026-10-18: Look inside's note page gets a Copy door, "copy full text is
//  a good idea" — "the same door and name a live note has"). The Mac half of the pins: the door's name and its sentences
//  ARE a live note's Copy full text's (the registry's verb, `CopyForAI`'s receipt and refusal — one vocabulary, never a
//  re-typed copy that could drift); the Mac's road writes the clipboard by Copy full text's ONE rule (`CopyForAI.put`, on
//  a private named board here); and the sheet renders the door only where the model offers it, leaving the note's text
//  read-only and never selectable. The road itself (the document format on the clipboard, the receipt, nothing written)
//  is `LookInsideRoadTests.theNotePagesCopyFullTextCarriesTheDocumentFormatAndWritesNothing` (planted, headless too).
//

import AppKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-307 U2c — Look inside's Copy full text: the live note's door, its words and its clipboard rule")
@MainActor
struct LookInsideCopyDoorTests {
    @Test func theDoorAndItsSentencesAreALiveNotesCopyFullText() {
        #expect(ProtectionWords.lookInsideCopyFullText == CapabilityRegistry.capability(.copyForAI).verb)
        #expect(ProtectionWords.lookInsideCopied == CopyForAI.copiedForAI)
        #expect(ProtectionWords.lookInsideNothingToCopy == CopyForAI.copyForAIEmpty)
        #expect(LookInsideModel.CopyLine.copied.sentence == "Copied full text.")
        #expect(LookInsideModel.CopyLine.nothingToCopy.sentence == CopyForAI.copyForAIEmpty)
        #expect(LookInsideModel.CopyLine.failed.sentence == ProtectionWords.lookInsideCopyFailed)
    }

    /// The Mac's road is Copy full text's own clipboard rule: the board cleared, the text set as a string.
    @Test func theMacsRoadWritesTheClipboardByCopyFullTextsOneRule() throws {
        let board = NSPasteboard(name: .init("vx307-u2c-\(UUID().uuidString)"))
        defer { board.releaseGlobally() }
        board.clearContents()
        board.setString("something she copied before", forType: .string)
        let document = "{t:\"A note\"}\n\nOne.\n\nTwo."
        CopyForAI.put(document, on: board)
        #expect(board.string(forType: .string) == document)
        #expect(board.pasteboardItems?.count == 1, "cleared first — one item")
        #expect(AppBootstrap.copyFullTextRoad != nil, "the Mac's bootstrap hands the look a clipboard road")
    }

    /// BY SOURCE: the note page renders the door only where the model offers it, the receipt under it; the note's text
    /// stays read-only — no `.textSelection(.enabled)`, no raw pasteboard in the face (the road is the bootstrap's).
    @Test func theSheetRendersTheDoorOnlyWhereOfferedAndKeepsTheTextReadOnly() throws {
        let url = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features/Protection/LookInsideSheet.swift")
        let code = try String(contentsOf: url, encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
        #expect(code.contains("if model.offersCopyFullText {"))
        #expect(code.contains("Button(ProtectionWords.lookInsideCopyFullText) { Task { await model.copyFullText() } }"))
        #expect(code.contains("if let line = model.copyLine {"))
        #expect(!code.contains(".textSelection(.enabled)"))
        #expect(!code.contains("NSPasteboard"))
    }
}
