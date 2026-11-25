//
//  BookTagChordTests.swift
//  VariorumTests
//
//  **VX-1038 (T-4) — the tagging act reaches a book** (her pick at the
//  2026-11-25 check-in, "Keep ⌘⇧I": T-4's act already existed as `.tagNote`
//  on ⌘⇧I, so the act grows a book road and keeps its chord; no taught word
//  moves). In a book the act opens the card "+" field on the note she is on
//  (P-1036-B1-1's rule);
//  another mode turns to the Outline first; a book hiding its tags shows all
//  of them. Write's road is unchanged. A FEATURE, so its pins are the
//  declaration, the routing and the pure choreography.
//

import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-1038 — the tagging act reaches a book (T-4, ⌘⇧I kept)", .serialized)
struct BookTagChordTests {
    @Test func theActKeepsItsOneDeclarationAndItsChord() {
        let act = CapabilityRegistry.capability(.tagNote)
        #expect(act.shortcutLabel == "\u{2318}\u{21e7}I", "her pick: the standing chord, kept")
        let key = EditorCommands.keyEquivalent(for: .tagNote)
        #expect(key?.0 == "i" && key?.1 == [.command, .shift])
        #expect(act.doors == [.menuBar, .palette, .surface])
    }

    @Test func theActNowActsWhereTheFocusedPaneShowsABook() {
        #expect(CapabilityRegistry.availability(.tagNote, in: CapabilityContext(focusedPaneShowsBook: true)) == .act)
        #expect(CapabilityRegistry.availability(.tagNote, in: CapabilityContext(mode: .write)) == .act,
                "Write's road stands")
        #expect(CapabilityRegistry.availability(.tagNote, in: CapabilityContext()) == .unavailable,
                "nothing to tag: honestly grey")
    }

    @Test func inABookTheActIsAskedOfThatBookAndInWriteOfTheMasthead() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "a book", kind: .book)
            let shell = ShellRouter()
            shell.workspace.select(.reading(book.id))
            ShellActions(session: session, shell: shell).tagNote()
            #expect(shell.bookTagRequest?.bookID == book.id)
            let first = shell.bookTagRequest?.token
            ShellActions(session: session, shell: shell).tagNote()
            #expect(shell.bookTagRequest?.token != first, "a second press is a second request")
            #expect(session.status.spoken == nil, "the book takes it — nothing refused")

            // No book focused and no note mounted: the registry's honest note.
            let elsewhere = ShellRouter()
            elsewhere.workspace.select(.library)
            ShellActions(session: session, shell: elsewhere).tagNote()
            #expect(elsewhere.bookTagRequest == nil)
            #expect(session.status.spoken?.text == CapabilityRegistry.capability(.tagNote).unavailableNote)
            #expect(session.status.spoken?.kind == .refusal)
        }
    }

    @Test func theChoreographyTurnsToTheOutlineAndShowsTagsOnlyWhenHidden() {
        #expect(BookTagChord.act(mode: .outline, position: .otherTags)
                == .init(switchesToOutline: false, showsTags: nil), "in place: her position stands")
        #expect(BookTagChord.act(mode: .outline, position: .hidden)
                == .init(switchesToOutline: false, showsTags: .allTags),
                "hidden: all tags, so the + is there and a placing tag she adds stays seen")
        for mode in [BookStructureModel.ViewMode.index, .spread, .read] {
            #expect(BookTagChord.act(mode: mode, position: .allTags)
                    == .init(switchesToOutline: true, showsTags: nil),
                    "\(mode): the field lives on the Outline's cards — fire-and-DO (P-2)")
        }
    }

    @Test func theRefusalNamesNoChord() {
        #expect(!BookTagChordCopy.noNote.contains("\u{2318}"), "true whichever key the act carries")
        #expect(BookTagChordCopy.noNote.hasPrefix("No note to tag"))
    }
}
