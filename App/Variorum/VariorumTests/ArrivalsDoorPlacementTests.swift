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

    @Test func aRowsNameOpensTheNoteAndNeverSeatsIt() async throws {
        let opened = LockIsolated<[String]>([])
        let token = NotificationCenter.default.addObserver(
            forName: .variorumOpenPost, object: nil, queue: nil
        ) { note in
            if let id = note.userInfo?["postID"] as? String {
                opened.withValue { $0.append(id) }
            }
        }
        defer { NotificationCenter.default.removeObserver(token) }
        BookArrivalsList.openNote("waiting-note")
        #expect(opened.value == ["waiting-note"], "the ordinary note-open road, read-normal")
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

    @Test func aGatheringHasNoDoor() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            ArrivalsDoorProbe.reset()
            let session = AppSession(database: db)
            let ops = session.operations
            let tag = try ops.createTag(name: "seen")
            let gathering = try ops.createReading(
                name: "seen", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let book = try ops.createReading(name: "kept", kind: .book)
            for readingID in [gathering.id, book.id] {
                let model = BookViewModel(session: session, readingID: readingID)
                let structure = BookStructureModel(session: session, readingID: readingID)
                structure.adopt(.init(
                    reading: try await db.read { try Queries.reading($0, id: readingID) },
                    sections: [], deletedSections: [], assignments: [:]))
                structure.mode = .outline
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(rootView: BookView(
                    session: session, readingID: readingID, model: model, structure: structure))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                for _ in 0..<20 {
                    hosting.layoutSubtreeIfNeeded()
                    window.displayIfNeeded()
                    pump()
                    await Task.yield()
                }
                window.orderOut(nil)
                window.close()
            }
            #expect(ArrivalsDoorProbe.drawn[gathering.id] == nil, "a gathering has no door")
            #expect(ArrivalsDoorProbe.drawn[book.id]?.presence == false,
                    "a book's door is drawn, calm")
        }
    }
}
