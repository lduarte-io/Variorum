//
//  ArrivalsDoorPlacementTests.swift
//  VariorumTests
//
//  17y B3 item (h) — THE ARRIVALS DOOR LIVES ON THE MODE-ROW ICON (R-17y-1)
//  AND THE ONE WORD IS "Arrivals" (R-17y-2). Her walk: "I also have no idea
//  where arrivals are… I don't see it anywhere" and, of the line atop the
//  Index, "I don't like it being there". What these hold:
//
//  · the line LEFT the content: no content host (Index pane, Outline, the
//    Book spread) renders an arrivals face; the book's masthead renders the
//    door — a grep-form pin over the hosts;
//  · a GATHERING has no door (it holds nothing — P-2), mounted;
//  · a waiting row's NAME opens the note through the ordinary note-open
//    broadcast and writes nothing — opening never seats;
//  · the one word wins on the retired "door" sentences (the finish confirm,
//    the refusal, the membership sheet's note).
//
//  A ruled BUILD (no red-on-old owed); the walk captures the face.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y (h) — the Arrivals door on the masthead; the one word", .serialized)
struct ArrivalsDoorPlacementTests {
    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
    }

    private static func code(_ file: String) throws -> String {
        let text = try String(
            contentsOf: appRoot.appending(path: "Variorum/Features/BookView/\(file)"), encoding: .utf8)
        return text.split(separator: "\n", omittingEmptySubsequences: false)
            .filter { !$0.trimmingCharacters(in: .whitespaces).hasPrefix("//") }
            .joined(separator: "\n")
    }

    @Test func theLineLeftTheContentAndTheDoorIsTheMastheads() throws {
        #expect(!(try Self.code("BookIndexView.swift")).contains("BookArrivals"),
                "the Index pane carries no arrivals face")
        #expect(!(try Self.code("SpreadBookView.swift")).contains("BookArrivals"),
                "the Book spread carries none")
        let bookView = try Self.code("BookView.swift")
        #expect(bookView.components(separatedBy: "BookArrivalsDoor(").count == 2,
                "the masthead renders the door, once (the masthead is shared by both hosts)")
        #expect(!bookView.contains("BookArrivalsList("), "Outline carries no rows of its own")
    }

    /// A row's NAME opens the note through the ordinary note-open broadcast
    /// (`.variorumOpenPost`, the book view's "open ↗" road) and writes
    /// nothing. The broadcast is CAPTURED at its seam, never posted app-wide:
    /// a test's global broadcast reaches whatever shell the test host has
    /// standing (the B3 RECORD's F-B3-3 — this batch's first END run met it).
    @Test func aRowsNameOpensTheNoteAndNeverSeatsIt() {
        var posted: [(Notification.Name, String?)] = []
        BookArrivalsList.openNote("waiting-note") { name, info in
            posted.append((name, info["postID"] as? String))
        }
        #expect(posted.count == 1)
        #expect(posted.first?.0 == .variorumOpenPost, "the ordinary note-open road, read-normal")
        #expect(posted.first?.1 == "waiting-note")
    }

    @Test func theRetiredDoorSentencesSayTheOneWord() {
        #expect(BookStateCopy.waitingLine(2) == "2 waiting at Arrivals will be dismissed.")
        let judged = ArrivalsCopy.refusal(
            for: OperationError.arrivalNotFound(id: "r"), book: "Poems", cap: nil)
        #expect(judged.contains("waiting at Arrivals"), "\(judged)")
        #expect(MembershipChoiceCopy.unavailableNote.contains("Arrivals"))
        #expect(!MembershipChoiceCopy.unavailableNote.contains("door"))
        #expect(ArrivalsCopy.unavailableNote.hasPrefix("Arrivals"))
        // The dial already said it (13i-b) — the word it lent everyone else.
        #expect(RuleEditorCopy.joinArrivals == "wait at Arrivals")
    }

    /// A GATHERING has no door (it holds nothing — P-2); a book's door is
    /// drawn, calm or present. The masthead's one condition, pinned at its
    /// seam (mounting whole book views here leaked their teardown past the
    /// test's dependency scope — F-B3-3).
    @Test func aGatheringHasNoDoor() {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        let gathering = Reading(id: "g", name: "seen", kind: .gathering, createdAt: now, updatedAt: now)
        let book = Reading(id: "b", name: "kept", kind: .book, createdAt: now, updatedAt: now)
        #expect(!BookArrivalsDoor.isDrawn(for: gathering), "a gathering has no door")
        #expect(BookArrivalsDoor.isDrawn(for: book), "a book's door is drawn")
        #expect(!BookArrivalsDoor.isDrawn(for: nil), "an unread book draws nothing yet")
    }
}
