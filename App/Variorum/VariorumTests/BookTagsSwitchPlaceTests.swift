//
//  BookTagsSwitchPlaceTests.swift
//  VariorumTests
//
//  **The VX-1036 ladder, round 2 — R2-2 (MINOR, SPECULATIVE in magnitude; this
//  pin decides).** A move of the book's tags switch re-stands the Outline's
//  heights (R1-1 — the position rides `BookOutlineHeights`' stamp), but the
//  book did not RE-LAND her row: `.onChange(of: cardTags.position)` dropped
//  `stand`'s "anything moved" answer, while the width road re-lands the row at
//  the top exactly because a re-stand without one "silently relocates the page
//  mid-story" (QUESTIONS #115, the 13u2b trace). Showing tags puts each card's
//  pills in its header — on their own row under a title that fills the line —
//  so every card drawn above the page's top grows, and ⌘⇧I's flip to all tags
//  (P-1036-B2-5) fires wherever she is, usually deep in a book.
//
//  The claim, where she sees it: settled on a far note at the top of the page,
//  a switch move (the one road the switch's face and ⌘⇧I share —
//  `BookCardTagsModel.setPosition`) leaves that note at the top. The oracle is
//  `BookOutlineGeometry.anchorTops` (the landing suite's), read after every
//  landing the move could start has ended.
//
//  **HOW IT IS JUDGED (the hallucination guard):** committed ALONE first — a
//  pins-only tree — so the stage runs it before the fix exists. RED there
//  confirms the finding and the fix commit stands; GREEN there means the
//  finding is HOLLOW, and the fix commit is reverted (`git revert`) and
//  recorded record-only.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The landing rig's window (`BookOutlineLandingTests`' numbers).
private let placeWindowWidth: CGFloat = 1200
private let placeWindowHeight: CGFloat = 760

/// A book of cards whose titles fill the header line (so shown pills take
/// their own row under each title), every note wearing two tags.
@MainActor
private func withTaggedBook<T>(
    posts: Int,
    _ body: @MainActor (AppSession, AppDatabase, _ readingID: String, _ postIDs: [String]) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 1036))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let ops = session.operations
        let reading = try ops.createReading(name: "the allotment year", kind: .book)
        let week = try ops.createTag(name: "week")
        let plumber = try ops.createTag(name: "plumber")
        var postIDs: [String] = []
        for p in 0..<posts {
            // A title that fills the card's header line at the rig's width —
            // so the pills, once shown, sit on their own row under it.
            let post = try ops.createPost(
                title: "note \(p) — the long account of the spring we spent digging the "
                    + "allotment by hand, bed after bed, while the rain came in sideways")
            _ = try ops.newBlock(
                in: post.id,
                text: "Prose of note \(p). It was a cold morning of the early spring, and we "
                    + "sat after breakfast on either side of a cheery fire in the old room at "
                    + "Baker Street, with a thick fog rolling down between the lines of "
                    + "dun-coloured houses opposite.")
            try ops.applyTag(week.id, toPost: post.id)
            try ops.applyTag(plumber.id, toPost: post.id)
            try ops.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        return try await body(session, db, reading.id, postIDs)
    }
}

@MainActor
@Suite("VX-1036 ladder R2-2 — a tags switch move keeps her place in the Outline", .serialized)
struct BookTagsSwitchPlaceTests {
    /// The landing suite's pump (a synchronous hop: `run(until:)` is
    /// unavailable from an async context).
    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool, maxTurns: Int = 80
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// Turns for at least `seconds` of wall time (a landing's hold is wall
    /// time, so a turn count alone would not cover it).
    private func hold(_ window: NSWindow, _ hosting: NSView, seconds: TimeInterval) async {
        let until = Date().addingTimeInterval(seconds)
        await settle(window, hosting, until: { Date() >= until }, maxTurns: 400)
    }

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return structure
    }

    /// Every landing this book started since `mark` has ended (each `LAND`
    /// line has a `DONE:` after it) — the authority's own storyboard.
    private func landingsQuiet(since mark: Int, anchors: Set<String>) -> Bool {
        let lines = BookOutlineGeometry.trace.count > mark
            ? Array(BookOutlineGeometry.trace[mark...]) : []
        var open: Set<String> = []
        for line in lines {
            if line.hasSuffix(" LAND") {
                let anchor = String(line.dropLast(" LAND".count))
                if anchors.contains(anchor) { open.insert(anchor) }
            } else if let range = line.range(of: " DONE:") {
                open.remove(String(line[..<range.lowerBound]))
            }
        }
        return open.isEmpty
    }

    /// The row at the top of the page, by the oracle: the realized anchor
    /// nearest the top edge at or below it (the book's own `topRow` rule —
    /// `outlineAnchorMoved` — read off the same reports).
    private func topRow(of anchors: [String]) -> (id: String, top: CGFloat)? {
        let tops = BookOutlineGeometry.anchorTops
        return anchors
            .compactMap { id in tops[id].map { (id: id, top: $0) } }
            .filter { $0.top >= -BookView.landingTolerance }
            .min { $0.top < $1.top }
    }

    /// **RED ON OLD — R2-2's confirm.** Settled on a far note at the top, the
    /// switch moved to all tags (every card's pills on their own row) and back
    /// to hidden: each move leaves the note at the top of the page, within
    /// the suite's 4-pt landing reading (the policy's tolerance is 2).
    @Test func aTagsSwitchMoveLeavesTheRowAtTheTopOfThePageWhereItWas() async throws {
        try await withTaggedBook(posts: 40) { session, db, readingID, postIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            let suite = "BookTagsSwitchPlaceTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let tags = BookCardTagsModel(readingID: readingID, defaults: defaults)
            try #require(tags.position == .hidden, "the default: hidden")

            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: placeWindowWidth, height: placeWindowHeight),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: BookView(
                    session: session, readingID: readingID, model: model,
                    structure: structure, cardTags: tags))
            hosting.frame = NSRect(x: 0, y: 0, width: placeWindowWidth, height: placeWindowHeight)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            let anchors = postIDs.map(BookOutlineRows.Row.noteAnchor)
            await settle(window, hosting, until: { BookOutlineGeometry.anchorTops[anchors[0]] != nil })

            // Where she is: deep in the book, a far note at the top of the page.
            let target = anchors[28]
            let above = anchors[27]
            try #require((BookOutlineGeometry.anchorTops[target] ?? 0) > placeWindowHeight,
                         "the premise: the note starts far below the fold")
            model.requestReveal(postIDs[28])
            await settle(window, hosting, until: {
                BookOutlineGeometry.trace.contains { $0.hasPrefix("\(target) DONE:") }
                    && abs(BookOutlineGeometry.anchorTops[target] ?? .infinity) <= BookView.landingTolerance
            })
            let settled = try #require(BookOutlineGeometry.anchorTops[target], "the note realized")
            try #require(abs(settled) <= BookView.landingTolerance,
                         "the premise: the reveal settled the note at the top (\(settled))")
            try #require(topRow(of: anchors)?.id == target, "the premise: it IS the row at the top")

            for (position, grows) in [(BookTagsShown.allTags, true), (.hidden, false)] {
                let before = try #require(
                    BookOutlineGeometry.rowHeights[above], "the card above the top is drawn")
                let mark = BookOutlineGeometry.trace.count
                // THE SWITCH'S ROAD — the face's choice and ⌘⇧I's flip alike.
                tags.setPosition(position)
                // The pills' read, by hand (the held read's own delivery, if
                // the host runs its task, lands the same rows).
                let snapshot = try await db.read { [postIDs] in
                    try BookCardTagsModel.fetch($0, postIDs: postIDs, wingID: "", ruleTagIDs: [])
                }
                tags.adopt(snapshot)

                // The premise: the move reached the cards — the one above the
                // top grew by its pill row (or gave it back).
                await settle(window, hosting, until: {
                    let now = BookOutlineGeometry.rowHeights[above] ?? before
                    return grows ? now > before + 4 : now < before - 4
                })
                let now = BookOutlineGeometry.rowHeights[above] ?? before
                try #require(grows ? now > before + 4 : now < before - 4,
                             "\(position): the card above the top changed height (\(before) → \(now))")
                #expect(model.outlineHeights.tagsShown == position, "R1-1: the heights stand at it")

                // Every landing the move could start has had its hold and
                // ended; then where is the page?
                await hold(window, hosting, seconds: BookView.landingMinimumHold + 0.75)
                await settle(window, hosting, until: { landingsQuiet(since: mark, anchors: Set(anchors)) },
                             maxTurns: 200)
                let top = BookOutlineGeometry.anchorTops[target]
                let row = topRow(of: anchors)
                print("R2-2 PLACE (\(position)):", "target top=\(String(describing: top))",
                      "top row=\(String(describing: row))",
                      BookOutlineGeometry.trace[min(mark, BookOutlineGeometry.trace.count)...]
                        .suffix(12).joined(separator: " | "))
                #expect(row?.id == target,
                        "\(position): the note she was at is still the row at the top, not \(String(describing: row))")
                #expect(abs(top ?? .infinity) <= 4,
                        "\(position): …and still AT the top, not \(String(describing: top)) pt away")
            }
        }
    }
}
