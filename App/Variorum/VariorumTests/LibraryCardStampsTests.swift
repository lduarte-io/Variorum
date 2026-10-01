//
//  LibraryCardStampsTests.swift
//  VariorumTests
//
//  **17q — HER RULING R-Q17** (2026-09-13, on QUESTIONS #103): *"what
//  surface is this? in the library / pool there's enough room to show both.
//  if the area is small, the same UI i mentioned earlier of clicking on the
//  time should switch to show you the date created or the date associated
//  with the note."*
//
//  …and with it the 18h ladder's **R3-2**: the List row still printed the
//  RAW stored `entry_date` beside worded stamps, so the Library's two modes
//  spoke one note's time in two grammars — and under the `date` sort the row
//  printed the same day twice, once raw and once worded.
//
//  ── WHAT THESE PINS DRIVE ───────────────────────────────────────────────
//  The RULE (`LibrarySortFace.rowStamps`) is pure and pinned directly. The
//  FACES are mounted in a real window at a WIDE and a NARROW width and read
//  through the DEBUG words oracle the two stamp renderers feed
//  (`CatalogStampOracle`, keyed by the note — KnownIssues row 53) — because
//  "does the card have room for both" is a question only a laid-out view can
//  answer, and the accessibility road is measured shut for hosted SwiftUI
//  (17p batch a's record).
//
//  Every asserted word is compared against `TimeStampFace`'s OWN output for
//  the same fact, never against a literal: the claim is that the row says
//  what the one brain says, and a literal would pin the machine's locale
//  instead (the brain's own doc: the narrow no-break space is the locale's).
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
@Suite("The note rows' two time facts (17q — her R-Q17, and R3-2)", .serialized)
struct LibraryCardStampsTests {

    // MARK: - Harness

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "17q-card-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func mount<V: View>(_ content: V, width: CGFloat) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: width, height: 90),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: content
                .frame(width: width, height: 90, alignment: .leading))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: 90)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        for _ in 0..<14 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
        }
        return window
    }

    private func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
    }

    /// A world whose clock TICKS, so the created and edited stamps differ
    /// (`LibrarySortMenuTests`' own harness).
    private func withTickingLibrary<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    /// ONE note with BOTH facts: a stated day AND stamps the clock moved.
    private func statedNote(_ session: AppSession) throws -> String {
        let post = try session.operations.createPost(
            title: "three ways of working", entryDate: "2026-01-15")
        let block = try session.operations.newBlock(in: post.id, text: "one")
        try session.operations.autosave(block.variant.id, text: "one typed", charDelta: 6)
        return post.id
    }

    /// A week after the fixture's world, so every stamp is a plain day
    /// rather than "today" — the words the rule owes, not the machine's.
    private var now: Date { Date(timeIntervalSince1970: 1_782_864_000 + 7 * 86_400) }

    private func words(_ face: LibrarySortFace.RowStamp) -> String? {
        TimeStampFace.stamp(face.subject, iso: face.stamp, now: now)
    }

    // MARK: - The rule (pure)

    /// **R-Q17's letter, and R3-2's, as ONE rule.** The trailing stamp is the
    /// SORT's own and is unchanged by 17q; beside it stands the OTHER fact —
    /// the day she stated, or the EDIT stamp when the sort already IS that
    /// day, so one fact is never printed twice.
    @Test func theTwoFactsARowShowsAreTheStatedDayAndTheSortsOwnStamp() async throws {
        try await withTickingLibrary { session, _ in
            let postID = try self.statedNote(session)
            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("rule"))
            await model.search()
            let hit = try #require(model.hits.first { $0.id == postID })

            for sort in [Queries.LibrarySort.lastTouched, .createdAt, .title] {
                let pair = LibrarySortFace.rowStamps(sort, for: hit)
                #expect(pair.stated.subject == .dated)
                #expect(pair.stated.stamp == hit.detail, "\(sort): the day SHE stated")
                #expect(pair.other == LibrarySortFace.rowStamp(sort, for: hit),
                        "\(sort): the other fact is the sort's own stamp, byte-identical")
                #expect(!pair.sortIsTheStatedDay)
                #expect(pair.sorted == pair.other, "a small card opens on the sort's own")
                #expect(pair.unsorted == pair.stated)
                #expect(pair.listDay == hit.detail,
                        "\(sort): the List row carries the stated day beside the title")
            }

            // Under the DATE sort the two would be ONE fact — so the other
            // becomes the EDIT stamp, and the List row's beside-the-title
            // slot stands down (its trailing stamp already says the day).
            let dated = LibrarySortFace.rowStamps(.entryDate, for: hit)
            #expect(dated.sortIsTheStatedDay)
            #expect(dated.stated.stamp == hit.detail)
            #expect(dated.other.subject == .edited)
            #expect(dated.other.stamp == hit.lastTouchedAt)
            #expect(dated.sorted == dated.stated, "a small card opens on the day it is ordered by")
            #expect(dated.unsorted == dated.other)
            #expect(dated.listDay == nil, "R3-2: never the same day twice on one row")
            #expect(self.words(dated.stated) != self.words(dated.other),
                    "the card's pair is two different facts, not one said twice")

            // A note with NO stated day: only the sort's own stamp, in both
            // arrangements — a face draws nothing rather than a lie.
            let bare = try session.operations.createPost(title: "no day")
            _ = try session.operations.newBlock(in: bare.id, text: "x")
            await model.search()
            let bareHit = try #require(model.hits.first { $0.id == bare.id })
            let barePair = LibrarySortFace.rowStamps(.lastTouched, for: bareHit)
            #expect(barePair.stated.stamp == nil)
            #expect(barePair.other.stamp == bareHit.lastTouchedAt)
            #expect(barePair.listDay == nil)

            // A BOOK row carries neither (`detail` there is the word "book").
            let book = try session.operations.createReading(name: "the field guide", kind: .book)
            await model.search()
            let bookHit = try #require(model.hits.first { $0.kind == .book && $0.id == book.id })
            for sort in LibrarySortFace.offered {
                let pair = LibrarySortFace.rowStamps(sort, for: bookHit)
                #expect(pair.stated.stamp == nil && pair.other.stamp == nil, "\(sort): a book row")
                #expect(pair.listDay == nil)
            }
        }
    }

    // MARK: - The card, mounted: both where there is room

    /// **A WIDE card shows BOTH facts** (her R-Q17: *"there's enough room to
    /// show both"*), beside the title — reading (i) of #103's R1-17 clause,
    /// the shape she pointed at.
    @Test func aWideCardShowsTheStatedDayAndTheSortsStamp() async throws {
        try await withTickingLibrary { session, _ in
            let postID = try self.statedNote(session)
            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("wide"))
            await model.search()
            let hit = try #require(model.hits.first { $0.id == postID })
            let pair = LibrarySortFace.rowStamps(.lastTouched, for: hit)

            #if DEBUG
            CatalogStampOracle.reset(postID)
            #endif
            let window = self.mount(
                CatalogCardStamps(
                    tokens: .terminalLight, postID: postID, stamps: pair, now: self.now),
                width: 520)
            defer { self.close(window) }

            #if DEBUG
            let drew = CatalogStampOracle.shown[postID] ?? [:]
            #expect(drew["card.wide.stated"] == self.words(pair.stated),
                    "the day she stated, in the one brain's words (drew \(drew))")
            #expect(drew["card.wide.other"] == self.words(pair.other),
                    "…beside the sort's own stamp (drew \(drew))")
            #expect(drew["card.small"] == nil,
                    "the wide arrangement won, so the flipping stamp never drew")
            #expect(CatalogStampOracle.flip[postID] == nil,
                    "…and no flip door is wired where both facts are on screen")
            #endif
        }
    }

    /// **A SMALL card shows ONE stamp — the SORT's own — and a click flips
    /// it** (her R-Q17: *"if the area is small, the same UI i mentioned
    /// earlier of clicking on the time should switch to show you the date
    /// created or the date associated with the note"*).
    @Test func aSmallCardShowsOneStampAndAClickFlipsIt() async throws {
        try await withTickingLibrary { session, _ in
            let postID = try self.statedNote(session)
            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("small"))
            await model.search()
            let hit = try #require(model.hits.first { $0.id == postID })
            let pair = LibrarySortFace.rowStamps(.lastTouched, for: hit)

            #if DEBUG
            CatalogStampOracle.reset(postID)
            #endif
            let window = self.mount(
                CatalogCardStamps(
                    tokens: .terminalLight, postID: postID, stamps: pair, now: self.now),
                width: 120)
            defer { self.close(window) }

            #if DEBUG
            var drew = CatalogStampOracle.shown[postID] ?? [:]
            #expect(drew["card.wide.stated"] == nil && drew["card.wide.other"] == nil,
                    "there is no room for two, so the pair did not draw (drew \(drew))")
            #expect(drew["card.small"] == self.words(pair.sorted),
                    "…and the one stamp is the SORT's own (drew \(drew))")

            let flip = try #require(CatalogStampOracle.flip[postID], "the flip door is wired")
            flip()
            for _ in 0..<12 {
                window.contentView?.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                self.pump()
            }
            drew = CatalogStampOracle.shown[postID] ?? [:]
            #expect(drew["card.small"] == self.words(pair.unsorted),
                    "her click shows the other fact — the day she stated (drew \(drew))")

            flip()
            for _ in 0..<12 {
                window.contentView?.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                self.pump()
            }
            drew = CatalogStampOracle.shown[postID] ?? [:]
            #expect(drew["card.small"] == self.words(pair.sorted),
                    "…and a click again returns (drew \(drew))")
            #endif
        }
    }

    /// **A note with only ONE fact gets no flip door** — a door that could
    /// not act is not rendered (P-2), at either width.
    @Test func aNoteWithNoStatedDayShowsItsOneStampAndNoFlipDoor() async throws {
        try await withTickingLibrary { session, _ in
            let bare = try session.operations.createPost(title: "no day")
            _ = try session.operations.newBlock(in: bare.id, text: "x")
            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("bare"))
            await model.search()
            let hit = try #require(model.hits.first { $0.id == bare.id })
            let pair = LibrarySortFace.rowStamps(.lastTouched, for: hit)

            for width in [CGFloat(520), 120] {
                #if DEBUG
                CatalogStampOracle.reset(bare.id)
                #endif
                let window = self.mount(
                    CatalogCardStamps(
                        tokens: .studyLight, postID: bare.id, stamps: pair, now: self.now),
                    width: width)
                defer { self.close(window) }
                #if DEBUG
                let drew = CatalogStampOracle.shown[bare.id] ?? [:]
                #expect(drew["card.only"] == self.words(pair.other),
                        "width \(width): the one stamp it has (drew \(drew))")
                #expect(CatalogStampOracle.flip[bare.id] == nil,
                        "width \(width): no flip door for a flip that would do nothing")
                #endif
            }
        }
    }

    // MARK: - The List row (R3-2)

    /// **R3-2 — RED ON OLD (measured by behavioral revert; the numbers are in
    /// the 17q record).** The List row's beside-the-title day is the one
    /// brain's words, never the raw stored `2026-01-15`; and under the `date`
    /// sort the row draws that day exactly ONCE, because the trailing stamp
    /// is already saying it.
    ///
    /// The line is built exactly as the shipped call site builds it — the
    /// day through `RowStamps.listDay`, the trailing stamp through
    /// `rowStamp` — so the pin holds the COMPOSITION and not a hand-made
    /// pair.
    @Test func theListRowSpeaksTheOneBrainAndNeverPrintsOneDayTwice() async throws {
        try await withTickingLibrary { session, _ in
            let postID = try self.statedNote(session)
            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("row"))
            await model.search()
            let hit = try #require(model.hits.first { $0.id == postID })

            for sort in LibrarySortFace.offered {
                let pair = LibrarySortFace.rowStamps(sort, for: hit)
                #if DEBUG
                CatalogStampOracle.reset(postID)
                #endif
                let window = self.mount(
                    CatalogNoteLine(
                        tokens: .terminalLight, title: "three ways of working",
                        date: pair.listDay, tags: [], allTags: [],
                        onTitleTap: {}, onApply: { _ in }, onRemove: { _ in },
                        stamp: LibrarySortFace.rowStamp(sort, for: hit), now: self.now,
                        oracleKey: postID),
                    width: 700)
                defer { self.close(window) }

                #if DEBUG
                let drew = CatalogStampOracle.shown[postID] ?? [:]
                let day = drew["row.date"]
                let trailing = try #require(drew["row.stamp"], "\(sort): the trailing stamp drew")
                #expect(trailing == self.words(LibrarySortFace.rowStamp(sort, for: hit)),
                        "\(sort): the trailing stamp is unchanged by 17q")
                if sort == .entryDate {
                    #expect(day == nil,
                            """
                            \(sort): the row prints the day ONCE — before 17q it \
                            printed the raw `\(hit.detail ?? "")` beside the \
                            worded `\(trailing)` (drew \(drew))
                            """)
                } else {
                    #expect(day == self.words(pair.stated),
                            "\(sort): the stated day, in the one brain's words (drew \(drew))")
                    #expect(day != hit.detail,
                            "\(sort): …never the raw stored day (drew \(drew))")
                    #expect(day != trailing, "\(sort): two facts, not one said twice")
                }
                #endif
            }
        }
    }
}
