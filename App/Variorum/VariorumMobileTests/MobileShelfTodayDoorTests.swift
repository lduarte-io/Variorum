//
//  MobileShelfTodayDoorTests.swift
//  VariorumMobileTests
//
//  Mobile Round 2, batch 5 — R26.2/R26.3: TODAY'S ENTRY IS A BADGE.
//
//  Her words: *"make today's entry just a little button next to journal -
//  like a clickable badge next to journal, with no blinking cursor."*
//
//  Three things are pinned, and the third is the one §40 flagged as an
//  open consequence rather than a ruling:
//
//  1. the badge renders on the DAILY journal's row and nowhere else;
//  2. it really opens (or mints) the day's entry — driven through the
//     real control, not the model's method;
//  3. **the door survives when no shelf row can carry it** — a fresh
//     account with no Journal, or one she deleted. The implementer's
//     proposal, built: the badge falls back to its own row at the end of
//     the books list, so the road is never absent.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func todayShelf(
    _ session: AppSession, opened: @escaping (String) -> Void = { _ in }
) -> HostedSurface<MobileShelfView<EmptyView>> {
    let shelf = MobileShelfViewModel(session: session)
    let stars = MobileStarsModel(session: session)
    let quickNote = MobileQuickNoteModel(session: session)
    return HostedSurface(
        MobileShelfView(
            model: shelf, stars: stars, quickNote: quickNote,
            tokens: .terminalLight, tabBar: { EmptyView() },
            onOpenBook: { _ in }, onOpenForWriting: opened,
            onSettings: {}),
        size: CGSize(width: 430, height: 932))
}

@Suite("Shelf — Today's Entry as a badge (R26)")
struct MobileShelfTodayDoorTests {

    /// The badge is on the shelf, and it opens the day — driven through
    /// the REAL control by its accessibility label.
    @Test func theBadgeOpensTheDaysEntry() async throws {
        try await withEditorWorld { session, db in
            _ = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Journal", kind: .book, profile: "journal",
                    sortField: .entryDate, sortDir: .asc)
                try ops.setDailyJournalBook(book.id)
                return book.id
            }
            let landed = LockIsolatedBox<String?>(nil)
            let surface = todayShelf(session) { id in landed.value = id }
            defer { surface.tearDown() }
            await surface.settle(50)

            #expect(surface.activate(MobileShelfFaces.todayDoorSpoken),
                    "labels were \(surface.visibleLabels)")
            await surface.settle(50)

            let postID = try #require(landed.value, "the door must open the entry")
            let header = try await db.read { db in
                try Queries.containerHeader(db, containerID: postID)
            }
            #expect(header?.entryDate != nil,
                    "the day's entry carries its day")
        }
    }

    /// R26.2's letter: the badge belongs to the DAILY book's row. A shelf
    /// with books but no designated daily journal has no badge to hang —
    /// which is exactly the state §40 flagged.
    @Test func theBadgeRidesOnlyTheDailyBooksRow() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops in
                try ops.createReading(name: "Essays", kind: .book).id
            }
            let surface = todayShelf(session)
            defer { surface.tearDown() }
            await surface.settle(50)

            // The door is present exactly once — as the fallback row,
            // since no row can carry a badge.
            let doors = surface.visibleElements.filter {
                $0.accessibilityLabel == MobileShelfFaces.todayDoorSpoken
            }
            #expect(doors.count == 1,
                    "labels were \(surface.visibleLabels)")
        }
    }

    /// **The open consequence, answered.** No books at all — the state a
    /// fresh account or a cleared shelf shows — and the door is still
    /// there and still works. (`shelveInDailyJournalBook` creates and pins
    /// the Journal when none is designated, AppSpec §9, so pressing it is
    /// also how a shelf gets its Journal back — by her asking, never by
    /// the app putting furniture back.)
    @Test func theDoorSurvivesAnEmptyShelf() async throws {
        try await withEditorWorld { session, db in
            let landed = LockIsolatedBox<String?>(nil)
            let surface = todayShelf(session) { id in landed.value = id }
            defer { surface.tearDown() }
            await surface.settle(50)

            #expect(surface.activate(MobileShelfFaces.todayDoorSpoken),
                    "labels were \(surface.visibleLabels)")
            await surface.settle(60)

            #expect(landed.value != nil, "an empty shelf must still open today")
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1, "the core's own first-press creation ran")
            #expect(books.first?.name == Operations.defaultDailyJournalBookName)
        }
    }

    /// **R26.2, MEASURED — and the second red-on-old of the batch.** She
    /// asked for *"just a little button next to journal - like a clickable
    /// badge"*. The pre-batch door carried `.frame(maxWidth: .infinity)`,
    /// so on old code this element measures the full shelf width; a badge
    /// measures its own words. The pin runs on either tree.
    @Test func theDoorIsABadgeAndNotAFullWidthButton() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops -> String in
                let book = try ops.createReading(
                    name: "Journal", kind: .book, profile: "journal")
                try ops.setDailyJournalBook(book.id)
                return book.id
            }
            let surface = todayShelf(session)
            defer { surface.tearDown() }
            await surface.settle(50)

            let badge = try #require(
                shelfFrame(surface, labeled: MobileShelfFaces.todayDoorSpoken),
                "labels were \(surface.visibleLabels)")
            print("PERF[sim] today badge frame — \(badge) (shelf width 430)")
            #expect(badge.width < 200,
                    "a badge, not a full-width button — measured \(badge.width) pt")

            // And it really is BESIDE the Journal row, not under the list.
            let journalRow = try #require(
                surface.visibleElements
                    .filter { ($0.accessibilityLabel ?? "").contains("journal") }
                    .map(\.accessibilityFrame)
                    .filter({ !$0.isEmpty })
                    .max(by: { $0.width < $1.width }),
                "labels were \(surface.visibleLabels)")
            #expect(abs(badge.midY - journalRow.midY) < 40,
                    "badge \(badge) vs journal row \(journalRow)")
        }
    }

    // R26.3 — *"with no blinking cursor"* — is deliberately NOT pinned
    // here, and the reason is the hallucination guard rather than
    // laziness: `BlinkingCursorBlock` is `accessibilityHidden(true)`, so
    // the harness's tree cannot see it in either direction, and a pin
    // that greps the source is a lint dressed as a test — it would pass
    // on both sides of any change that mattered. The ruling is satisfied
    // structurally (the shelf constructs no cursor; the box is the only
    // remaining site) and visibly in the diff, and the badge-width pin
    // above is what holds the door's SHAPE.
}
