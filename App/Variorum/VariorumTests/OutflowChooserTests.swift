//
//  OutflowChooserTests.swift
//  VariorumTests
//
//  13i-c U3 — THE OUTFLOW CHOOSER (R-13ic-1; F-U1-1): the rule editor's
//  single auto-tag row rebuilt as a chosen, ordered, optional SET. What is
//  pinned: the draft's order/dedupe/removal and its dead-id drop (pure); the
//  mounted editor DRAWS the set in her order, with "(deleted tag)" for a dead
//  one; a save round-trips order and removal through `setReadingOutflow`;
//  "none" is legal (NULL stored, no offer); the offer's N is
//  `membersMissingAnyOutflowTag` and its act tags EVERY outflow tag
//  (`tagAllMembers(nil)`), the receipt counting notes.
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
private func withChooserWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

private func pump(_ seconds: TimeInterval = 0.1) {
    RunLoop.main.run(until: Date().addingTimeInterval(seconds))
}

@MainActor
private func settle(until condition: () -> Bool = { false }) async {
    for _ in 0..<20 where !condition() {
        pump(0.05)
        for _ in 0..<10 { await Task.yield() }
    }
}

@MainActor
private func mounted(_ model: RuleEditorModel, _ run: () async throws -> Void) async throws {
    let window = NSWindow(
        contentRect: NSRect(x: 60, y: 60, width: 640, height: 640),
        styleMask: [.titled, .resizable], backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    defer {
        window.orderOut(nil)
        window.close()
    }
    window.contentView = NSHostingView(rootView: RuleEditorSheet(model: model))
    window.orderFrontRegardless()
    await settle()
    try await run()
}

@MainActor
private func editor(_ session: AppSession, _ readingID: String) async -> RuleEditorModel {
    let model = RuleEditorModel(session: session, readingID: readingID)
    await model.load()
    return model
}

@MainActor
private func storedOutflow(_ db: AppDatabase, _ id: String) async throws -> [String] {
    try await db.read { try Queries.reading($0, id: id) }?.autoTagIDs ?? []
}

@MainActor
@Suite("The outflow chooser (13i-c U3)", .serialized)
struct OutflowChooserTests {
    @Test func theDraftKeepsHerOrderDedupesAndDropsTheDeadAtTheWrite() {
        var draft = OutflowDraft(["b", "a", "b"])
        #expect(draft.ids == ["b", "a"], "order kept, duplicates dropped")
        draft.add("c")
        draft.add("a")
        #expect(draft.ids == ["b", "a", "c"], "append order; a chosen tag stays put")
        draft.remove("b")
        #expect(draft.ids == ["a", "c"])
        #expect(draft.written(live: ["c", "a"]) == ["a", "c"], "the write keeps HER order")
        #expect(draft.written(live: ["c"]) == ["c"], "a dead id drops at the write")
        draft.remove("a")
        draft.remove("c")
        #expect(draft.isEmpty, "none is legal")
    }

    /// The mounted editor draws the set IN HER ORDER; editing it (remove one,
    /// add one) redraws; Save writes exactly that order.
    @Test func theChooserDrawsTheSetAndASaveRoundTripsOrderAndRemoval() async throws {
        try await withChooserWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "alpha")
            let b = try ops.createTag(name: "beta")
            let c = try ops.createTag(name: "gamma")
            let book = try ops.createReading(name: "b", kind: .book, autoTagIDs: [b.id, a.id])
            RuleEditorProbe.reset()
            let model = await editor(session, book.id)

            try await mounted(model) {
                #expect(RuleEditorProbe.drawn[book.id]?.outflow == ["#beta", "#alpha"])
                #expect(RuleEditorProbe.drawn[book.id]?.saveEnabled == false)
                model.outflow.remove(b.id)
                model.outflow.add(c.id)
                await settle(until: { RuleEditorProbe.drawn[book.id]?.outflow == ["#alpha", "#gamma"] })
                #expect(RuleEditorProbe.drawn[book.id]?.outflow == ["#alpha", "#gamma"])
                #expect(RuleEditorProbe.drawn[book.id]?.saveEnabled == true)
                #expect(await model.save())
            }
            #expect(try await storedOutflow(db, book.id) == [a.id, c.id])
            #expect(session.status.current?.kind != .offer, "no members — nothing to offer")
        }
    }

    /// A dead stored id reads "(deleted tag)" and drops on the next save —
    /// even a save that changed something else (her row said it was dead).
    @Test func aDeadTagReadsAsDeletedAndDropsOnTheNextSave() async throws {
        try await withChooserWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "alpha")
            let gone = try ops.createTag(name: "gone")
            let book = try ops.createReading(name: "b", kind: .book, autoTagIDs: [a.id, gone.id])
            try ops.deleteTag(gone.id)
            RuleEditorProbe.reset()
            let model = await editor(session, book.id)

            try await mounted(model) {
                #expect(RuleEditorProbe.drawn[book.id]?.outflow == ["#alpha", RuleEditorCopy.deadTag])
                model.seating = .arrivals
                #expect(model.isDirty)
                #expect(await model.save())
            }
            #expect(try await storedOutflow(db, book.id) == [a.id], "the dead id dropped")
            #expect(try await db.read { try Queries.reading($0, id: book.id) }?.intakeSeating == .arrivals)
        }
    }

    /// "None" is legal: removing every tag stores NULL — and never untags
    /// (ruled), and asks nothing.
    @Test func clearingTheSetStoresNothingAndNeverUntags() async throws {
        try await withChooserWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "alpha")
            let book = try ops.createReading(name: "b", kind: .book, autoTagIDs: [a.id])
            let minted = try ops.newPostInReading(book.id, title: "minted")
            let model = await editor(session, book.id)
            model.outflow.remove(a.id)
            #expect(await model.save())
            #expect(try await db.read {
                try String.fetchOne($0, sql: "SELECT auto_tag_ids FROM reading WHERE id = ?",
                                    arguments: [book.id])
            } == nil, "[] stores NULL — one spelling of no outflow")
            #expect(try await db.read {
                try Int.fetchOne($0, sql: """
                    SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL
                    """, arguments: [minted.id, a.id])
            } == 1, "clearing never untags")
            #expect(session.status.current?.kind != .offer)
        }
    }

    /// The offer over the SET: N = members missing ANY outflow tag; its act
    /// tags every outflow tag (`tagAllMembers(nil)`), and the receipt counts
    /// NOTES (P-13ic-11).
    @Test func theOfferCountsMembersMissingAnyTagAndTagsEveryOne() async throws {
        try await withChooserWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "alpha")
            let b = try ops.createTag(name: "beta")
            let book = try ops.createReading(name: "b", kind: .book)
            var members: [Container] = []
            for i in 0..<3 {
                let post = try ops.createPost(title: "m\(i)")
                try ops.addPostToReading(post.id, to: book.id)
                members.append(post)
            }
            // m0 already wears both; m1 wears one; m2 wears none → N = 2.
            _ = try ops.applyTag(a.id, toPost: members[0].id)
            _ = try ops.applyTag(b.id, toPost: members[0].id)
            _ = try ops.applyTag(a.id, toPost: members[1].id)
            let model = await editor(session, book.id)
            model.outflow.add(a.id)
            model.outflow.add(b.id)
            #expect(await model.save())

            let said = try #require(session.status.current)
            #expect(said.kind == .offer)
            #expect(said.text == "Also tag the 2 current members with #alpha #beta now?")
            said.action?.perform()
            await settle(until: { session.status.spoken?.text != said.text })
            #expect(try await db.read {
                try Queries.membersMissingAnyOutflowTag($0, readingID: book.id)
            } == 0, "every member wears every outflow tag")
            #expect(session.status.spoken?.text == "Tagged 2 members with #alpha #beta.")
        }
    }

    /// A RULE change re-asks when an outflow is in place and members miss it
    /// (the offer rides "the outflow set or the rule changed").
    @Test func aRuleChangeWithAnOutflowInPlaceAsksAgain() async throws {
        try await withChooserWorld { session, db in
            let ops = session.operations
            let a = try ops.createTag(name: "alpha")
            let topic = try ops.createTag(name: "topic")
            let book = try ops.createReading(name: "b", kind: .book)
            let member = try ops.createPost(title: "m")
            // Joined BEFORE the outflow existed (a hand-add rides the outflow,
            // so a member added after it would already wear it).
            try ops.addPostToReading(member.id, to: book.id)
            try ops.setReadingOutflow(book.id, tagIDs: [a.id])
            let model = await editor(session, book.id)
            model.add(.tag(topic.id), into: nil)
            #expect(await model.save())
            #expect(session.status.current?.kind == .offer)
            #expect(session.status.current?.text == "Also tag the 1 current member with #alpha now?")
            _ = db
        }
    }
}
