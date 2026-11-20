//
//  MobileLibraryRowActsTests.swift
//  VariorumMobileTests
//
//  VM-64 ladder round 2, finding 1 (Part of VM-68) — AN ACT ON THE LIBRARY'S
//  OWN ROWS RE-ASKS THE LISTING IN PLACE, past its first page. The record is
//  `notes/plans/fixes/vm-64-timing-and-lags.md` §7 ▸ "Ladder round 2 — fix
//  pass"; the finding and the responses are `vm-64-ladder-round2.md`.
//
//  This file names the new door (`rowStarLanded`), so it is NOT part of the
//  red-on-old build (it could not compile against the code before it); the
//  red-on-old build moves it aside. The road it drives is the delete's
//  (`reaskAfterRowAct`), whose red-on-old pin is
//  `MobileLibraryPagingRulesTests.aRowDeletedPastTheFirstPageLeavesTheListing`
//  — so this is a DESIGN pin of the ★ leg: it shows a ★ really does move a
//  deep Bookless row (the premise) and that the door re-asks for it.
//

import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

/// Polls the main actor until `condition` holds (or a generous bound).
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async {
    for _ in 0..<2_000 where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

@MainActor
@Suite("VM-64 ladder round 2 — a row's act re-asks the listing past its first page")
struct MobileLibraryRowActsTests {
    /// **A ★ that takes a deep row out of the loose class re-asks Bookless.**
    /// A ★ gathering in Home; twelve loose notes; Bookless held on screen, two
    /// pages listed; the seventh row starred (the stars model's own op), then
    /// the door told, as the row's star button tells it: the starred note leaves
    /// Bookless (a ★ gathering shows it now), and the listing keeps its depth.
    /// Without the door's re-ask the held first page does not change, nothing is
    /// delivered and the note stays listed (the delete pin's mechanism).
    @Test func aStarThatTakesADeepRowOutOfTheLooseClassReAsksBookless() async throws {
        try await withEditorWorld { session, db in
            try await session.runner.run { ops in
                _ = try ops.createReading(
                    name: "stars", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
                for index in 0..<12 {
                    let post = try ops.createPost(title: String(format: "loose %03d", index))
                    _ = try ops.newBlock(in: post.id, text: "Words \(index).", at: .end)
                }
            }
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            model.filter = .bookless
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.bookless.count == 4 }
            await model.loadMore(.bookless)
            #expect(model.bookless.count == 8, "the premise: two pages listed")

            let starred = model.bookless[6]
            try await session.runner.run { ops in
                try ops.setStarred(.post(starred.postID), starred: true)
            }
            // The premise, on the store: the ★ gathering shows the note now.
            let question = model.question(.bookless)
            let loose = try await db.read { db in
                try MobileLibraryViewModel.read(db, question, after: nil, limit: 50)
            }
            #expect(!loose.items.contains { $0.postID == starred.postID },
                    "the premise: a starred note is no longer loose")

            model.rowStarLanded()
            await settle { !model.bookless.contains { $0.postID == starred.postID } }
            #expect(!model.bookless.contains { $0.postID == starred.postID },
                    "the starred note left Bookless")
            #expect(model.bookless.map(\.postID) == Array(loose.items.prefix(8)).map(\.postID),
                    "the listed depth is kept, in the loose class's own order")
        }
    }
}
