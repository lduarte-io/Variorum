//
//  MCPGatheringIconTests.swift
//  VariorumTests (Mac)
//
//  VX-185 (RUN VX-184, U2) — THE GATHERINGS ICON, on the Bookcase. Her report:
//  "gatherings don't show as being shared with AI right now (the icon doesn't
//  appear on them) even when you've shared the whole wing with AI … if they're
//  shared as part of the wing, that needs to be clear." Her ruling R-VX185-1:
//  only a wing grant or the open book icons a gathering — never note or book
//  grants, "even if each individual note is marked shared".
//
//  The face's road, end to end: the Bookcase's held observation
//  (`ShelfViewModel.watchSharing` → `Queries.mcpBookReaches`) holds the
//  gathering's reach; its row draws the ONE icon from that map (`shelfRow`,
//  one row view for books and gatherings); the popover (`MCPReachPopover`,
//  kind-blind) says the wing in the why, and its Change… / Revoke act on the
//  WING grant — the Revoke says which grant, Change… opens THE sheet on the
//  wing's own place, replacing that grant.
//
//  RED-ON-OLD, stated: the Bookcase model and the popover are unchanged by the
//  fix — the cause and the fix are the core read (`MCPGatheringReachTests`,
//  red on the pre-fix tree and again by revert). This suite is the face's
//  guard: the model holds what the core map says, and the popover's words for
//  a gathering's reach are the wing's. It uses only API that stood before the
//  fix, so on the pre-fix tree its settles time out (the map never held the
//  gathering).
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
@Suite("VX-185 — the Bookcase icon on a gathering: the wing grant, the open book, never a note or book grant", .serialized)
struct MCPGatheringIconTests {
    private func withSession<T>(_ body: @MainActor (AppSession, AppDatabase) async throws -> T) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 185))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func defaults() throws -> UserDefaults {
        let suite = "vx185-gathering-icon-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Wait (bounded) for a condition a held observation settles.
    private func settle(_ condition: @MainActor () -> Bool) async throws -> Bool {
        for _ in 0..<300 {
            if condition() { return true }
            try await Task.sleep(for: .milliseconds(10))
        }
        return condition()
    }

    private func approved(_ ops: Operations, _ name: String = "claude-code") throws -> MCPClient {
        let client = try ops.recordMCPContact(name: name, version: "2")
        try ops.approveMCPClient(client.id, granting: nil)
        return MCPClient(
            id: client.id, name: client.name, version: client.version, state: .approved,
            firstSeenAt: client.firstSeenAt, lastSeenAt: client.lastSeenAt, decidedAt: nil)
    }

    /// A Bookcase model on `wing` with both held halves running.
    private func board(_ session: AppSession, wing: String = "") throws -> (ShelfViewModel, [Task<Void, Never>]) {
        let model = ShelfViewModel(session: session, wingID: wing, defaults: try defaults())
        return (model, [Task { await model.start() }, Task { await model.watchSharing() }])
    }

    // MARK: - A wing grant: the icon, the wing named, Change… and Revoke on the wing grant

    @Test func aWingGrantIconsTheGatheringRowAndItsPopoverSaysTheWingGrant() async throws {
        try await withSession { session, db in
            let ops = session.operations
            let client = try approved(ops)
            let gathering = try ops.createReading(
                name: "every star", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let book = try ops.createReading(name: "the lightning thief", kind: .book)
            let wingGrant = try ops.grantMCPAccess(
                client.id, .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
            let (model, tasks) = try board(session)
            defer { tasks.forEach { $0.cancel() } }

            #expect(try await settle { model.books.contains { $0.reading.id == gathering.id } },
                    "the gathering is a row on the Bookcase")
            #expect(try await settle { model.aiReach[gathering.id] != nil },
                    "its row's map holds it — the row draws the icon")
            #expect(model.aiReach[book.id] != nil, "beside the book the same grant reaches")
            let reach = try #require(model.aiReach[gathering.id]?.first)
            #expect(reach.clientName == "claude-code" && reach.grant?.id == wingGrant)

            // The popover's words — the why names the wing; the rung is the
            // gathering's own (read), whatever the wing grant's.
            #expect(MCPShareCopy.iconHelp([reach]) == "Shared with claude-code (read) \u{2014} click for details")
            #expect(MCPShareCopy.reachLine(reach) == "read \u{00B7} always")
            #expect(MCPShareCopy.why(reach) == "through the Home wing grant")
            // Revoke says WHICH grant it takes (W-UX-5's words) …
            #expect(MCPShareCopy.revokeLabel(reach) == "Revoke the Home wing grant")
            // … and Change… opens THE sheet on the wing's own place, replacing
            // exactly that grant, at its own rung and duration (T-U3-8).
            let change = MCPReachPopover.changeOpening(client, try #require(reach.grant))
            #expect(change.place == .wing("") && change.replacing == [wingGrant])
            #expect(change.rung == .edit && change.duration == .always && change.client?.id == client.id)

            // Revoking the wing grant takes the icon off the gathering's row.
            try ops.revokeMCPGrant(wingGrant)
            #expect(try await settle { model.aiReach[gathering.id] == nil })
            _ = db
        }
    }

    // MARK: - R-VX185-1: note and book grants leave the gathering's row bare

    @Test func noteAndBookGrantsLeaveTheGatheringRowBareTheOpenBookIconsIt() async throws {
        try await withSession { session, db in
            let ops = session.operations
            let client = try approved(ops)
            let draft = try ops.createTag(name: "draft")
            let gathering = try ops.createReading(
                name: "every draft", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(draft.id)))
            let book = try ops.createReading(name: "the drafts book", kind: .book)
            for title in ["a draft about rivers", "a draft about doors"] {
                let note = try ops.createPost(title: title)
                _ = try ops.newBlock(in: note.id, text: title, registeringUndo: false)
                _ = try ops.applyTag(draft.id, toPost: note.id)
                _ = try ops.addPostToReading(note.id, to: book.id)
                _ = try ops.grantMCPAccess(
                    client.id, .init(rung: .read, scopeKind: .note, scopeID: note.id, duration: .always))
            }
            _ = try ops.grantMCPAccess(client.id, .init(rung: .edit, scopeKind: .book, scopeID: book.id, duration: .always))
            let (model, tasks) = try board(session)
            defer { tasks.forEach { $0.cancel() } }

            #expect(try await settle { model.aiReach[book.id] != nil }, "the book wears its own grant's icon")
            #expect(model.aiReach[gathering.id] == nil, "R-VX185-1: every note shared, the gathering bare")

            try ops.setMCPSwitch(.openBook, on: true)
            #expect(try await settle { model.aiReach[gathering.id] != nil }, "the open book icons it")
            let reach = try #require(model.aiReach[gathering.id]?.first)
            #expect(reach.viaOpenBook && MCPShareCopy.why(reach) == "through the open book")
            #expect(MCPShareCopy.revokeLabel(reach) == MCPShareCopy.revoke && reach.grant == nil,
                    "the open book has no grant to revoke — the popover says where its switch lives")
            try ops.setMCPSwitch(.openBook, on: false)
            #expect(try await settle { model.aiReach[gathering.id] == nil })
            _ = db
        }
    }

    // MARK: - Archived: off the Bookcase, like an archived book

    @Test func anArchivedGatheringLeavesTheBookcaseLikeAnArchivedBook() async throws {
        try await withSession { session, db in
            let ops = session.operations
            let client = try approved(ops)
            let gathering = try ops.createReading(
                name: "kept gathering", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let book = try ops.createReading(name: "kept book", kind: .book)
            _ = try ops.grantMCPAccess(client.id, .init(rung: .read, scopeKind: .wing, scopeID: "", duration: .always))
            let (model, tasks) = try board(session)
            defer { tasks.forEach { $0.cancel() } }
            #expect(try await settle { model.aiReach[gathering.id] != nil && model.aiReach[book.id] != nil })

            try ops.archiveReading(gathering.id)
            try ops.archiveReading(book.id)
            #expect(try await settle {
                !model.books.contains { $0.reading.id == gathering.id || $0.reading.id == book.id }
            }, "neither row is on the Bookcase — so neither draws an icon")
            #expect((model.aiReach[gathering.id] != nil) == (model.aiReach[book.id] != nil),
                    "the map treats the archived gathering as it treats the archived book")

            _ = try ops.unarchiveReading(gathering.id)
            #expect(try await settle {
                model.books.contains { $0.reading.id == gathering.id } && model.aiReach[gathering.id] != nil
            }, "back on the Bookcase, iconed")
            _ = db
        }
    }
}
