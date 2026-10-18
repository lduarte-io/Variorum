//
//  PoolTuckFaceTests.swift
//  VariorumTests
//
//  13i-b U4 — THE POOL TUCK, mounted (the sitting record §8; §25 lesson 10:
//  "The Pool is every note with no book. Notes that show in gatherings tuck
//  behind the count in its masthead — one click shows them."). The core split
//  is pinned in `PoolTuckTests`; these pin the FACE: her masthead shape, the
//  one click, the empty-but-gathered sentence. Mounted pins read
//  `PoolTuckProbe` (DEBUG — the `ArrivalsLineProbe` pattern); the model is fed
//  the split by hand (a hosted `.task` does not fire under the test host).
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
private func withPoolWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 41))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13i-b U4 — the Pool tuck's face (lesson 10)", .serialized)
struct PoolTuckFaceTests {
    // MARK: - The words (pure)

    @Test func herMastheadShapeAndTheCountWordsAgree() {
        // Her shape, verbatim, as the page composes it: the heading, the
        // muted count run, the one click.
        let composed = "Pool " + PoolTuckCopy.masthead(loose: 2, tucked: 14)
            + " " + PoolTuckCopy.toggle(showing: false)
        #expect(composed == "Pool \u{B7} 2 notes \u{B7} 14 in gatherings \u{B7} show")
        #expect(PoolTuckCopy.masthead(loose: 1, tucked: 1)
                == "\u{B7} 1 note \u{B7} 1 in a gathering \u{B7}")
        // Nothing tucked: the tuck says nothing.
        #expect(PoolTuckCopy.masthead(loose: 3, tucked: 0) == "\u{B7} 3 notes")
        #expect(PoolTuckCopy.toggle(showing: true) == "hide")
        // Empty states: plain-empty, and empty-but-gathered (one / many).
        #expect(PoolTuckCopy.empty(loose: 0, tucked: 0)
                == "Every note lives in a book. The pool is empty.")
        #expect(PoolTuckCopy.empty(loose: 0, tucked: 1)
                == "No loose notes \u{2014} the one bookless note shows in a gathering.")
        #expect(PoolTuckCopy.empty(loose: 0, tucked: 14)
                == "No loose notes \u{2014} all 14 bookless notes show in gatherings.")
        #expect(PoolTuckCopy.empty(loose: 2, tucked: 14) == nil)
    }

    // MARK: - Mounted

    private func pump(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool = { false }
    ) async {
        for _ in 0..<10 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func mounted(
        _ session: AppSession, _ db: AppDatabase
    ) async throws -> (window: NSWindow, hosting: NSView, model: PoolPostsModel) {
        let model = PoolPostsModel(session: session)
        try await refresh(model, db)
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1000, height: 900),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: PoolPostsView(
                session: session, model: model,
                onDuplicateAsVersion: { _, _ in }, onArchive: { _ in },
                readings: ReadingsViewModel(session: session),
                tags: TagsViewModel(session: session),
                onOpen: { _ in }))
        hosting.frame = NSRect(x: 0, y: 0, width: 1000, height: 900)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting, model)
    }

    /// What the observation would deliver now, adopted by hand.
    private func refresh(_ model: PoolPostsModel, _ db: AppDatabase) async throws {
        await model.adopt(try await db.read {
            try Queries.notePoolListing($0, window: PoolPostsModel.window)
        })
    }

    @Test func theGatheredNotesTuckBehindTheCountAndOneClickShowsThem() async throws {
        PoolTuckProbe.reset()
        try await withPoolWorld { session, db in
            let (loose, tucked) = try await session.runner.run { ops -> ([String], [String]) in
                let tag = try ops.createTag(name: "ideas")
                _ = try ops.createReading(
                    name: "ideas", kind: .gathering,
                    querySpec: try RuleGrammar.encode(.tag(tag.id)))
                let loose = try (0..<2).map { try ops.createPost(title: "loose \($0)").id }
                let tucked = try (0..<3).map { i -> String in
                    let note = try ops.createPost(title: "gathered \(i)")
                    _ = try ops.applyTag(tag.id, toPost: note.id)
                    return note.id
                }
                return (loose, tucked)
            }
            let hosted = try await mounted(session, db)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.looseRows.count == 2
            }
            var drawn = PoolTuckProbe.drawn
            #expect(drawn.masthead == "\u{B7} 2 notes \u{B7} 3 in gatherings \u{B7}")
            #expect(drawn.toggle == "show")
            #expect(drawn.looseRows == Set(loose))
            #expect(drawn.tuckedRows.isEmpty, "tucked — behind the count")
            #expect(drawn.tuckedSection == false)
            #expect(drawn.looseSection == false, "no labels while nothing is revealed")
            #expect(drawn.empty == nil)

            // The one click.
            await hosted.model.toggleTucked()
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.tuckedRows.count == 3
            }
            drawn = PoolTuckProbe.drawn
            #expect(drawn.tuckedRows == Set(tucked))
            #expect(drawn.looseRows == Set(loose), "the loose notes stay where they were")
            #expect(drawn.tuckedSection)
            // F-U4-5: the revealed run stands at the TOP, so the loose run
            // below it wears its own label.
            #expect(drawn.looseSection)
            #expect(drawn.toggle == "hide")

            // …and back.
            await hosted.model.toggleTucked()
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.tuckedRows.isEmpty
            }
            #expect(PoolTuckProbe.drawn.tuckedRows.isEmpty)
            #expect(PoolTuckProbe.drawn.toggle == "show")
        }
    }

    /// **F-U4-3 (walk-found):** the show state is VIEW state — off on every
    /// visit (P-13ib-U4-4, the Arrivals expansion's rule). The model is
    /// RootView's and outlives the page, so leaving the Pool must tuck the run
    /// away again. RED on the pre-fix build: the remounted page still read
    /// "hide" and drew the tucked run.
    @Test func leavingThePoolTucksTheRunAwayAgain() async throws {
        PoolTuckProbe.reset()
        try await withPoolWorld { session, db in
            _ = try await session.runner.run { ops -> String in
                let tag = try ops.createTag(name: "ideas")
                _ = try ops.createReading(
                    name: "ideas", kind: .gathering,
                    querySpec: try RuleGrammar.encode(.tag(tag.id)))
                let note = try ops.createPost(title: "gathered")
                _ = try ops.applyTag(tag.id, toPost: note.id)
                return note.id
            }
            let hosted = try await mounted(session, db)
            await settle(hosted.window, hosted.hosting) { PoolTuckProbe.drawn.masthead != nil }
            await hosted.model.toggleTucked()
            await settle(hosted.window, hosted.hosting) { PoolTuckProbe.drawn.toggle == "hide" }
            #expect(PoolTuckProbe.drawn.toggle == "hide")

            // Leave the page (another destination replaces it)…
            hosted.window.contentView = NSView()
            await settle(hosted.window, hosted.window.contentView!)
            // …and come back to the SAME model (RootView keeps it).
            let again = NSHostingView(
                rootView: PoolPostsView(
                    session: session, model: hosted.model,
                    onDuplicateAsVersion: { _, _ in }, onArchive: { _ in },
                    readings: ReadingsViewModel(session: session),
                    tags: TagsViewModel(session: session),
                    onOpen: { _ in }))
            again.frame = NSRect(x: 0, y: 0, width: 1000, height: 900)
            hosted.window.contentView = again
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, again) { PoolTuckProbe.drawn.masthead != nil }
            #expect(hosted.model.showsTucked == false, "a fresh visit opens tucked")
            #expect(PoolTuckProbe.drawn.toggle == "show")
            #expect(PoolTuckProbe.drawn.tuckedRows.isEmpty)
        }
    }

    @Test func anEmptyButGatheredPoolSaysSo() async throws {
        PoolTuckProbe.reset()
        try await withPoolWorld { session, db in
            let gathered = try await session.runner.run { ops -> [String] in
                let tag = try ops.createTag(name: "ideas")
                _ = try ops.createReading(
                    name: "ideas", kind: .gathering,
                    querySpec: try RuleGrammar.encode(.tag(tag.id)))
                return try (0..<2).map { i -> String in
                    let note = try ops.createPost(title: "gathered \(i)")
                    _ = try ops.applyTag(tag.id, toPost: note.id)
                    return note.id
                }
            }
            let hosted = try await mounted(session, db)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) { PoolTuckProbe.drawn.masthead != nil }
            let drawn = PoolTuckProbe.drawn
            #expect(drawn.masthead == "\u{B7} 0 notes \u{B7} 2 in gatherings \u{B7}")
            #expect(drawn.empty == "No loose notes \u{2014} all 2 bookless notes show in gatherings.")
            #expect(drawn.empty?.contains("empty") == false, "never 'the pool is empty' over tucked notes")
            #expect(drawn.looseRows.isEmpty)
            await hosted.model.toggleTucked()
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.tuckedRows.count == 2
            }
            #expect(PoolTuckProbe.drawn.tuckedRows == Set(gathered))
            #expect(PoolTuckProbe.drawn.looseSection == false, "no loose run to label")
        }
    }

    @Test func aTrulyEmptyPoolSaysItIsEmptyAndOffersNoToggle() async throws {
        PoolTuckProbe.reset()
        try await withPoolWorld { session, db in
            let hosted = try await mounted(session, db)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) { PoolTuckProbe.drawn.masthead != nil }
            #expect(PoolTuckProbe.drawn.masthead == "\u{B7} 0 notes")
            #expect(PoolTuckProbe.drawn.toggle == nil, "nothing tucked, nothing to show")
            #expect(PoolTuckProbe.drawn.empty == "Every note lives in a book. The pool is empty.")
        }
    }

    /// Lesson 10 as a sequence: a note she STARS (the starred-notes gathering
    /// present) tucks behind the count; un-starring brings it back out.
    @Test func starringTucksANoteAndUnstarringBringsItBack() async throws {
        PoolTuckProbe.reset()
        try await withPoolWorld { session, db in
            let noteID = try await session.runner.run { ops -> String in
                _ = ops.ensureStarredNotesGathering()
                return try ops.createPost(title: "a thought").id
            }
            let hosted = try await mounted(session, db)
            defer {
                hosted.window.orderOut(nil)
                hosted.window.close()
            }
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.looseRows.contains(noteID)
            }
            #expect(PoolTuckProbe.drawn.looseRows == [noteID])

            try await session.runner.run { ops in try ops.setStarred(.post(noteID), starred: true) }
            try await refresh(hosted.model, db)
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.looseRows.isEmpty
            }
            #expect(PoolTuckProbe.drawn.looseRows.isEmpty)
            #expect(PoolTuckProbe.drawn.masthead == "\u{B7} 0 notes \u{B7} 1 in a gathering \u{B7}")

            try await session.runner.run { ops in try ops.setStarred(.post(noteID), starred: false) }
            try await refresh(hosted.model, db)
            await settle(hosted.window, hosted.hosting) {
                PoolTuckProbe.drawn.looseRows.contains(noteID)
            }
            #expect(PoolTuckProbe.drawn.looseRows == [noteID])
            #expect(PoolTuckProbe.drawn.masthead == "\u{B7} 1 note")
        }
    }
}
