//
//  NewBookSheetTests.swift
//  VariorumTests
//
//  VX-561 (the VX-805 run, Unit A) — the New Book dialog's way out. The stage
//  walk (2026-11-05) and her own Esc confirmed it: the Bookcase's "+ New Book"
//  presented `.alert("New Book")` with four buttons, and the declared
//  cancel-role fourth button never rendered in macOS's stacked alert — so no
//  Escape key equivalent existed and the only way out was to create a book.
//  The fix is `NewBookSheet`: a sheet whose Cancel is drawn and rides
//  `.cancelAction`.
//
//  A dialog cannot be mounted headlessly, so the pins read the presenters' own
//  source (the `GatheringKindWordTests` / registry-walk precedent); the
//  keystroke-level confirm is the stage window's (one Esc on the real panel).
//  RED ON OLD by construction: `ShelfView.swift` presented `.alert("New Book"`
//  and no `NewBookSheet.swift` existed.
//

import Foundation
import Testing
@testable import Variorum

@Suite("VX-561 — the New Book dialog has a way out")
struct NewBookSheetTests {
    private func source(_ path: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("Variorum")
        return try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
    }

    /// The Bookcase presents the SHEET, never the alert that dropped Cancel.
    @Test func theBookcasePresentsTheSheetNotTheAlert() throws {
        let shelf = try source("Features/Shelf/ShelfView.swift")
        #expect(!shelf.contains(".alert(\"New Book\""), "the four-button alert is gone")
        #expect(shelf.contains("NewBookSheet("), "the + New Book door presents the sheet")
        #expect(shelf.contains("onDismiss: runNewBookChoice"),
                "the choice runs once the sheet has gone (Cancel leaves none)")
    }

    /// The sheet draws its Cancel and gives it Esc; ⏎ is Create Book.
    @Test func theSheetDeclaresItsCancelRoadAndItsDefault() throws {
        let sheet = try source("Features/Shelf/NewBookSheet.swift")
        #expect(sheet.contains("Button(tokens.chromeLabel(NewBookCopy.cancel)) { dismiss() }"),
                "Cancel is a drawn button that only dismisses")
        let cancelLine = try #require(sheet.range(of: "NewBookCopy.cancel)) { dismiss() }"))
        let afterCancel = sheet[cancelLine.upperBound...].prefix(260)
        #expect(afterCancel.contains(".keyboardShortcut(.cancelAction)"), "Esc is Cancel's key")
        #expect(sheet.contains(".keyboardShortcut(.defaultAction)"), "⏎ creates the book")
    }

    /// The gathering mint the dialog opens keeps its own Esc road.
    @Test func theGatheringMintReachedFromItClosesOnEsc() throws {
        let mint = try source("Features/Readings/MintGatheringSheet.swift")
        #expect(mint.contains(".keyboardShortcut(.cancelAction)"))
    }

    /// The dialog keeps the alert's words, byte for byte.
    @Test func theWordsAreTheAlerts() {
        #expect(NewBookCopy.title == "New Book")
        #expect(NewBookCopy.createBook == "Create Book")
        #expect(NewBookCopy.createGathering == "Create Gathering\u{2026}")
        #expect(NewBookCopy.createJournalBook == "Create Journal Book")
        #expect(NewBookCopy.cancel == "Cancel")
    }
}
