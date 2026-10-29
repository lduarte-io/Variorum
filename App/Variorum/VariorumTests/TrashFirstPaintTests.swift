//
//  TrashFirstPaintTests.swift
//  VariorumTests
//
//  VX-670 (the VX-678 run) — the acceptance walk's FINDING 1: on opening the
//  Trash the page read "The Trash is empty." for ~0.4 s before the first rows
//  painted (3/3, both wings). The mechanism: `RecoveryViewModel.trash` starts
//  as `[]`, and `RecoveryView` drew the empty sentence whenever it was empty —
//  including before `observeTrash` had answered at all. The model now says
//  which (`trashListingLoaded`, `trashTotalLoaded`) and the face draws only
//  `trashEmptyStateLine`, which is nil until there is something true to say.
//
//  RED ON OLD by construction of the old face: its draw decision was
//  `model.trash.isEmpty`, which is true for a fresh model — the first pin's
//  opening expectation is exactly that decision answered honestly.
//
//  WRITTEN at the walk-findings fix and compiled (`build-for-testing`); run
//  at the next stage claim.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-670 walk finding 1 — the Trash never says it is empty before it has answered", .serialized)
struct TrashFirstPaintTests {

    /// A Trash that HOLDS something: before the listing's first value the
    /// model has nothing true to say (the old face said "The Trash is
    /// empty."); after it, rows and still no empty sentence.
    @Test func aNonEmptyTrashNeverReadsEmptyBeforeItsRowsArrive() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
            }
            let model = RecoveryViewModel(session: editor.session)
            #expect(model.trash.isEmpty, "the listing has not answered — the old face's whole condition")
            #expect(!model.trashListingLoaded)
            #expect(model.trashEmptyStateLine == nil, "no sentence before the first value — never the false one")

            let listing = Task { await model.startTrash() }
            let total = Task { await model.startTrashTotal() }
            defer { listing.cancel(); total.cancel() }
            for _ in 0..<400 {
                if model.trashListingLoaded, model.trashTotalLoaded { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(model.trashListingLoaded && model.trashTotalLoaded)
            #expect(model.trash.map(\.id) == [blockID])
            #expect(model.trashEmptyStateLine == nil, "rows, so no empty sentence")
        }
    }

    /// A GENUINELY empty Trash: withheld before the first value, then the
    /// true sentence the moment the listing answers.
    @Test func aGenuinelyEmptyTrashSaysSoOnceTheListingAnswers() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            #expect(model.trashEmptyStateLine == nil)
            let listing = Task { await model.startTrash() }
            let total = Task { await model.startTrashTotal() }
            defer { listing.cancel(); total.cancel() }
            for _ in 0..<400 {
                if model.trashListingLoaded { break }
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(model.trashListingLoaded)
            #expect(model.trashEmptyStateLine == "The Trash is empty.")
        }
    }

    /// Under a kind filter the empty sentence reads the UNFILTERED truth, so
    /// it waits for that too: a filtered listing that answered empty says
    /// nothing until the total has answered, then the two-facts sentence.
    @Test func aFilteredEmptyListingWaitsForTheTotalBeforeItSpeaks() async throws {
        try await withEditor { editor in
            let model = RecoveryViewModel(session: editor.session)
            model.kindFilter = .book
            model.adopt(archived: [], trash: [])
            #expect(model.trashListingLoaded)
            #expect(model.trashEmptyStateLine == nil, "whether other kinds wait is not known yet")
            model.adoptTrashTotalIsEmpty(false)
            #expect(model.trashEmptyStateLine == RecoveryCopy.trashEmptyLine(
                filteredBy: .book, holdsOtherKinds: true))
            #expect(model.trashEmptyStateLine?.contains("filter is on") == true)
            model.adoptTrashTotalIsEmpty(true)
            #expect(model.trashEmptyStateLine == "The Trash is empty.")
        }
    }
}
