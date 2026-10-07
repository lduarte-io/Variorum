//
//  LibraryDayFilterTests.swift
//  VariorumTests
//
//  **18h batch 2 — the Library's day filter** (the 2026-09-12 use-report
//  round, her ledger row 11; ruling R-Q8). Her words: *"how difficult it
//  would be to implement being able to search for any note edited on a
//  particular day."*
//
//  RED ON OLD — a PRODUCT row, so these pins do not COMPILE on the
//  pre-change tree: `LibraryCatalogModel` had no `editedOn`/`setEditedOn`,
//  there was no `LibraryDayField` to drive and no `LibraryDayFace` to say
//  the words. The recorded compile errors are in the batch record.
//
//  ── WHAT THESE PINS DRIVE (never hand-feed — the round's own lesson) ─────
//  The value reaches the query through the CONTROL'S OWN closures: the pins
//  build the real `LibraryDayField` and drive `dateBinding` (what the
//  `DatePicker` sets) and its `onPick`/`onClear` (what the door and the ✕
//  call), then run the model's own `search()` and read the hits the model
//  landed. Nothing constructs a `DayBounds` by hand on the way in.
//
//  Every model gets its own scrubbed `UserDefaults(suiteName:)` — suites and
//  hand walks share the dev-store app's `.standard` (KnownIssues R1-7).
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
@Suite("The Library's 'on day…' filter (18h batch 2, row 11)", .serialized)
struct LibraryDayFilterTests {
    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "18h-2-day-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// A clock she can move, so "the day before" is a day the OPERATIONS
    /// stamped, not a row edited by hand.
    private final class TravellingClock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 0))
        var current: Date { state.value }
        func set(_ date: Date) { state.setValue(date) }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(0.001) }
                return value
            }
        }
    }

    private func withTravellingLibrary<T>(
        _ body: @MainActor (AppSession, TravellingClock) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        // Noon UTC, so "this day" and "two days earlier" are unambiguous in
        // any machine timezone the suite happens to run in. (Every pin here
        // names its days through `day(of:)`, never by literal, so the exact
        // date is arbitrary — it is 2026-09-17.)
        clock.set(Date(timeIntervalSince1970: 1_789_646_400))  // 2026-09-17T12:00:00Z
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 31))
        } operation: { @MainActor in
            try await body(AppSession(database: db), clock)
        }
    }

    /// The day an instant falls in, in HER calendar — the same conversion
    /// the field performs.
    private func day(of date: Date) -> String { JournalDay.dayString(from: date) }

    private func noteIDs(_ model: LibraryCatalogModel) -> [String] {
        model.hits.filter { $0.kind == .post }.map(\.id)
    }

    // MARK: - The value reaches the query

    /// THE FACE PIN the brief names — driven through the date control's own
    /// binding, which is the closure the `DatePicker` sets.
    @Test func theFieldsValueReachesTheQuery() async throws {
        try await withTravellingLibrary { session, clock in
            let earlier = clock.current.addingTimeInterval(-2 * 86_400)
            clock.set(earlier)
            let old = try session.operations.createPost(title: "two days ago")
            _ = try session.operations.newBlock(in: old.id, text: "old words")

            clock.set(clock.current.addingTimeInterval(2 * 86_400))
            let today = clock.current
            let fresh = try session.operations.createPost(title: "today")
            _ = try session.operations.newBlock(in: fresh.id, text: "new words")

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("reaches"))
            await model.search()
            #expect(Set(noteIDs(model)) == [old.id, fresh.id], "both notes, unfiltered")

            // The REAL control, driven the way the DatePicker drives it.
            var picked: String?
            let field = LibraryDayField(
                tokens: VoiceTokens.resolve(voice: .terminal, dark: false),
                day: model.editedOn, now: today,
                onPick: { picked = $0 }, onClear: {})
            field.dateBinding.wrappedValue = today
            let firstPick = try #require(picked)
            model.setEditedOn(firstPick)
            await model.search()
            #expect(noteIDs(model) == [fresh.id], "the day she picked, and only it")

            picked = nil
            let armed = LibraryDayField(
                tokens: VoiceTokens.resolve(voice: .terminal, dark: false),
                day: model.editedOn, now: today,
                onPick: { picked = $0 }, onClear: {})
            armed.dateBinding.wrappedValue = earlier
            let secondPick = try #require(picked)
            model.setEditedOn(secondPick)
            await model.search()
            #expect(noteIDs(model) == [old.id], "moved back two days, the older note answers")
        }
    }

    /// The closed door opens on TODAY — a date field's own convention, and
    /// the answer she most often wants.
    ///
    /// **Driven through the door's OWN action** (the ladder's R1-9): this
    /// used to set `dateBinding` and passed only because the pin fed it the
    /// value the Button would have computed, so changing the door to open on
    /// yesterday left it green. `openOnToday()` is the closure the Button
    /// runs, and nothing else here reproduces it.
    @Test func openingTheClosedDoorPicksToday() async throws {
        try await withTravellingLibrary { _, clock in
            var picked: String?
            let field = LibraryDayField(
                tokens: VoiceTokens.resolve(voice: .study, dark: false),
                day: nil, now: clock.current,
                onPick: { picked = $0 }, onClear: {})
            field.openOnToday()
            #expect(picked == day(of: clock.current))
        }
    }

    /// ✕ puts the whole Library back — books and blocks included, which is
    /// the visible half of "a day names notes".
    @Test func theClearDoorReturnsTheWholeLibrary() async throws {
        try await withTravellingLibrary { session, clock in
            let note = try session.operations.createPost(title: "shelf note")
            let block = try session.operations.newBlock(in: note.id, text: "shelf words")
            try session.operations.setBlockName(block.block.id, name: "shelf")
            _ = try session.operations.createReading(name: "shelf", kind: .book)

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("clear"))
            model.query = "shelf"
            model.setEditedOn(day(of: clock.current))
            await model.search()
            #expect(model.hits.map(\.kind) == [.post], "a day names notes")

            var cleared = false
            let field = LibraryDayField(
                tokens: VoiceTokens.resolve(voice: .terminal, dark: false),
                day: model.editedOn, now: clock.current,
                onPick: { _ in }, onClear: { cleared = true })
            field.onClear()
            #expect(cleared)
            model.setEditedOn(nil)
            await model.search()
            // JUSTIFIED EDIT (13o U2 — R-13o-7 the field is the one finder,
            // R-13o-9 the block cap died): a named block is no longer a
            // capped row of its own kind; it is a PASSAGE of its note's group
            // on the answer sheet, found and reachable there. The subject —
            // ✕ puts every kind back — is unchanged.
            #expect(Set(model.hits.map(\.kind)) == [.book, .post],
                    "the book and the note are back")
            #expect(model.searchState.groups.first { $0.homeID == note.id }?.lines
                        .contains { $0.kind == .blockName && $0.blockID == block.block.id } == true,
                    "…and the named block, in its note's group")
        }
    }

    /// A note edited on two days, through the app's own doors: the day
    /// filter finds it by the later day always, and by the earlier one once
    /// a savepoint has landed there.
    @Test func aNoteEditedOnTwoDaysIsFoundByBothOnceASavepointLanded() async throws {
        try await withTravellingLibrary { session, clock in
            let monday = clock.current.addingTimeInterval(-86_400)
            clock.set(monday)
            let note = try session.operations.createPost(title: "the long one")
            let block = try session.operations.newBlock(in: note.id, text: "monday")

            clock.set(clock.current.addingTimeInterval(86_400))
            let tuesday = clock.current
            try session.operations.autosave(block.variant.id, text: "monday tuesday", charDelta: 8)

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("twodays"))
            model.setEditedOn(day(of: tuesday))
            await model.search()
            #expect(noteIDs(model) == [note.id])

            model.setEditedOn(day(of: monday))
            await model.search()
            #expect(noteIDs(model) == [], "one stamp per note — the caveat, on the real surface")

            // Now the savepoint that leaving the note on Monday would have
            // left (13j's `closeAutoCommit`), written at Monday's clock.
            clock.set(monday)
            _ = try session.operations.commit(block.variant.id, kind: .auto)
            clock.set(tuesday)
            await model.search()
            #expect(noteIDs(model) == [note.id], "Monday answers through its savepoint")
        }
    }

    /// A day the calendar does not have never reaches the query — the model
    /// keeps what it had rather than filtering by a guess.
    @Test func aKeyThatIsNotADayIsRefusedRatherThanGuessed() async throws {
        try await withTravellingLibrary { session, clock in
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("bad"))
            model.setEditedOn("2026-02-30")
            #expect(model.editedOn == nil)
            model.setEditedOn(day(of: clock.current))
            model.setEditedOn("tomorrow")
            #expect(model.editedOn == day(of: clock.current), "the armed day is untouched")
            model.setEditedOn(nil)
            #expect(model.editedOn == nil, "nil is the clear")
        }
    }

    // MARK: - What the day may and may not say (the ladder's R1-3)

    /// **A day names NOTES, so arming one moves a books/blocks scope to
    /// Notes** (R1-3(b)). Before the fix the picker was merely DISABLED with
    /// its value intact, so the listing was empty — `searchCatalog` returns
    /// posts only while a day is armed, and `filtered` then kept none of
    /// them — under a control she could not change, with ✕ the only escape.
    ///
    /// Red on old: `scope` stayed `.books` and the day's own notes were not
    /// listed.
    @Test func armingADayMovesABooksScopeToNotes() async throws {
        try await withTravellingLibrary { session, clock in
            let note = try session.operations.createPost(title: "today's note")
            _ = try session.operations.newBlock(in: note.id, text: "words")
            _ = try session.operations.createReading(name: "a book", kind: .book)

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("scope"))
            model.scope = .books
            await model.search()
            #expect(model.hits.map(\.kind) == [.book], "books, as she asked")

            model.setEditedOn(day(of: clock.current))
            #expect(model.scope == .posts,
                    "the day moved the scope to the kind it can answer")
            await model.search()
            #expect(noteIDs(model) == [note.id],
                    "and the day's notes are listed, not an empty page")
        }
    }

    /// **The day's sentence is only spoken when the day is what emptied the
    /// listing** (R1-3(a), the scope half). A scope the day cannot answer is
    /// unreachable after the fix above — this is the guard that keeps it
    /// unreachable, and it is the one the empty-answer site reads.
    ///
    /// Red on old: `dayForEmptyAnswer` did not exist (the site read
    /// `editedOn`, which is set under every scope).
    @Test func theDaysSentenceIsNotSpokenForAScopeItCannotDescribe() async throws {
        try await withTravellingLibrary { session, clock in
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("guard"))
            model.setEditedOn(day(of: clock.current))
            #expect(model.dayForEmptyAnswer == day(of: clock.current))
            model.scope = .blocks
            #expect(model.dayForEmptyAnswer == nil,
                    "the plain sentence is honest where the day's would not be")
            model.scope = .all
            #expect(model.dayForEmptyAnswer == day(of: clock.current))
        }
    }

    /// **A typed query narrows too, so the headline names it** (R1-3(a), the
    /// query half). The unqualified sentence asserts a fact about the DAY,
    /// and with a query beside it that fact can be flatly false — notes WERE
    /// edited that day, they just did not match the words. The caveat rides
    /// either way: it is still why a note she remembers can be missing.
    ///
    /// Red on old: `emptyAnswer` took no query and said the same thing.
    @Test func theEmptyAnswerNamesTheTypedQueryWhenOneIsNarrowingToo() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-12T12:00:00.000Z"))

        let alone = LibraryDayFace.emptyAnswer(
            day: "2026-09-09", query: "", now: now, calendar: calendar)
        #expect(alone.headline == "No note's last edit or savepoint falls on Sep 9.")

        let narrowed = LibraryDayFace.emptyAnswer(
            day: "2026-09-09", query: "  zzz ", now: now, calendar: calendar)
        #expect(narrowed.headline == "No note matching \u{201C}zzz\u{201D} was edited on Sep 9.",
                "the query is named, and trimmed")
        #expect(narrowed.caveat == LibraryDayFace.caveat,
                "the caveat rides either way")
    }

    /// **THE PICK LEAVES IN THE SAME UPDATE THE MODE DOES** (the 18h
    /// ladder's R3-1, built at 17q). R2-1's fix made `modeChanged()` async so
    /// it could fold in the re-read — and a `Task {}` body cannot run before
    /// the current synchronous update completes, so `clearSelection()` was
    /// deferred off the very update in which the mode changed. Neither the
    /// bulk bar (`if selectedPosts.count > 1`, carrying a destructive
    /// `Delete N notes…`) nor the info panel is mode-gated, so both could
    /// draw for a frame in a mode that shows no selection: the
    /// invisible-selection hazard `clearSelection`'s own doc forbids.
    ///
    /// **Red on old: this pin does not compile** — `modeChanged()` was
    /// `async`, so there was no way to read the selection in the same turn
    /// that changed the mode. That IS the finding, stated as a type: the fix
    /// is the signature, and the signature is what the pin holds. (The frame
    /// itself is not reachable from a headless pin — the rig cannot mount the
    /// whole catalog, KnownIssues — so the walk carries the face: pick two
    /// notes in List, switch to Notes, no bulk bar.)
    @Test func theModeChangeClearsThePickInItsOwnUpdate() async throws {
        try await withTravellingLibrary { session, clock in
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("sync"))
            let one = try session.operations.createPost(title: "one")
            _ = try session.operations.newBlock(in: one.id, text: "1")
            let two = try session.operations.createPost(title: "two")
            _ = try session.operations.newBlock(in: two.id, text: "2")
            await model.search()
            model.selectedPosts = [one.id, two.id]
            model.infoHit = model.hits.first { $0.id == one.id }
            #expect(model.selectedPosts.count > 1, "non-vacuity: the bulk bar's own condition")

            model.mode = .notes
            // NO `await` between these two lines — that is the whole claim.
            let owesARead = model.modeChanged()
            #expect(model.selectedPosts.isEmpty,
                    "the pick is gone in the same turn the mode changed")
            #expect(model.infoHit == nil, "…and so is the info panel's subject")
            #expect(owesARead == false, "no day was armed, so no re-read is owed")

            // …and with a day armed the answer flips, so the caller re-reads
            // exactly when the listing's inputs moved (R2-1's half, kept).
            model.setEditedOn(day(of: clock.current))
            model.mode = .timeline
            #expect(model.modeChanged(), "the day was cleared: a re-read is owed")
            #expect(model.editedOn == nil)
        }
    }

    /// **Leaving the catalog clears the day** (the ladder's R1-11). The
    /// Timeline mode runs its own listing, so the day field is not drawn
    /// there — and an armed day left behind meant the scope picker stayed
    /// disabled with the only control that could clear it off screen. The
    /// `clearSelection`-on-mode-switch precedent, one screen away, applied to
    /// the other piece of listing state.
    ///
    /// Red on old: `editedOn` survived the mode change — the view's
    /// `.onChange(of: model.mode)` called `clearSelection()`, which owns the
    /// PICK and nothing else.
    @Test func leavingTheCatalogClearsTheDay() async throws {
        try await withTravellingLibrary { session, clock in
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("leave"))
            model.setEditedOn(day(of: clock.current))
            #expect(model.editedOn != nil)

            model.mode = .notes
            #expect(model.modeChanged() == false, "nothing to re-read: the day stayed")
            #expect(model.editedOn != nil, "the Notes mode is the same listing")

            model.mode = .timeline
            #expect(model.modeChanged(), "the day was cleared, so a re-read is owed")
            #expect(model.editedOn == nil,
                    "the Timeline runs its own listing — the day goes with the door")
        }
    }

    /// **…and the LISTING goes with it** (the ladder's R2-1 — a regression of
    /// the fix above, caught by the fresh reviewer).
    ///
    /// Clearing the day changed the model's inputs and nothing re-read, so
    /// coming back to List showed the DAY's notes under a header saying
    /// `on day…` with the scope picker live again: the invisible-state hazard
    /// the R1-11 fix's own doc names, moved one step down. Any later
    /// keystroke repaired it silently, which is what would have made it read
    /// as "notes went missing" rather than as a filter.
    ///
    /// Red on old: `hits` unchanged across the round trip — the excluded note
    /// stayed excluded.
    @Test func returningToTheCatalogListsTheWholeLibraryAgain() async throws {
        try await withTravellingLibrary { session, clock in
            let today = clock.current
            let fresh = try session.operations.createPost(title: "today")
            _ = try session.operations.newBlock(in: fresh.id, text: "new")
            clock.set(today.addingTimeInterval(-3 * 86_400))
            let old = try session.operations.createPost(title: "three days ago")
            _ = try session.operations.newBlock(in: old.id, text: "old")
            clock.set(today)

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("roundtrip"))
            model.setEditedOn(day(of: today))
            await model.search()
            #expect(noteIDs(model) == [fresh.id], "the day's answer")

            // Exactly what the view's `.onChange` does since 17q (R3-1):
            // the clear is synchronous, and only the READ is spawned.
            model.mode = .timeline
            if model.modeChanged() { await model.search() }
            model.mode = .list
            if model.modeChanged() { await model.search() }

            #expect(model.editedOn == nil, "no filter is shown…")
            #expect(Set(noteIDs(model)) == [fresh.id, old.id],
                    "…so none may be applied: the whole library is listed")
        }
    }

    /// **The truncation line belongs to the body that draws it** (the
    /// ladder's R2-2). `capped` counts per kind and collapsed to ONE
    /// boolean, and the Notes body — which draws notes only — read it: with
    /// more books than a page and every note drawn, it said "showing the
    /// first 40" over a complete list of notes.
    ///
    /// Red on old: one flag, true for both bodies.
    ///
    /// **JUSTIFIED EDIT (17y B1 (k)):** books are no longer a page — every
    /// book of the wing is listed (her launch blocker's "ALL of their notes",
    /// and the books region scrolls on its own) — so 81 books are all drawn
    /// and nothing is truncated; the subject (truncation is per kind and
    /// never spoken over a complete listing) is unchanged.
    @Test func theNotesBodysTruncationIsAboutNotes() async throws {
        try await withTravellingLibrary { session, _ in
            for index in 0..<(LibraryCatalogModel.pageSize + 1) {
                _ = try session.operations.createReading(
                    name: String(format: "book %03d", index), kind: .book)
            }
            for index in 0..<3 {
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words")
            }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("kinds"))
            await model.search()

            #expect(model.hits.filter { $0.kind == .book }.count == LibraryCatalogModel.pageSize + 1,
                    "every book is listed — books are not a page")
            // JUSTIFIED EDIT (13o U2, R-13o-9): `listingIsTruncated` died with
            // the block cap — no Library listing is capped, so there is no
            // truncation flag left to be false. The subject stands on the two
            // facts that remain: every book drawn, every note drawn.
            #expect(!model.notesHaveMore, "every note is drawn: no further page")
            #expect(model.hits.filter { $0.kind == .post }.count == 3)
        }
    }

    // MARK: - The filter's calendar (the ladder's R1-8)

    /// **The day filter's calendar is GREGORIAN, carrying HER time zone** —
    /// one construction site, and this is the pin that says why.
    ///
    /// `JournalDay.dayString` emits the CURRENT calendar's components while
    /// `JournalDay.isValid` validates proleptic Gregorian. Those agree only
    /// while `Calendar.current` IS Gregorian. Under a Hebrew calendar — which
    /// macOS Language & Region offers — a leap year's month 13 makes a key
    /// like `"5786-13-05"`, `isValid` refuses it, and every door in this
    /// filter that takes a day key silently does nothing: `setEditedOn`
    /// refuses the pick, so the filter would never arm at all.
    ///
    /// The store's day grammar is Gregorian ISO by `JournalDay`'s own
    /// definition (`entry_date` everywhere), so the filter names its calendar
    /// instead of inheriting one — and keeps her TIME ZONE, which is what
    /// makes the day HERS. Red on old: `LibraryDayFace.calendar` did not
    /// exist; every site took `Calendar.current` whole.
    @Test func theFiltersCalendarIsGregorianAndKeepsHerTimeZone() throws {
        #expect(LibraryDayFace.calendar.identifier == .gregorian)
        #expect(LibraryDayFace.calendar.timeZone == Calendar.current.timeZone,
                "her day boundaries are her zone's")

        let instant = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-09T18:00:00.000Z"))

        // The trap, demonstrated on the road the filter no longer takes.
        var hebrew = Calendar(identifier: .hebrew)
        hebrew.timeZone = Calendar.current.timeZone
        let hebrewKey = JournalDay.dayString(from: instant, calendar: hebrew)
        #expect(!JournalDay.isValid(hebrewKey),
                "\(hebrewKey) is not a day this store can name")
        #expect(DayBounds(day: hebrewKey, calendar: hebrew) == nil)

        // The road it takes.
        let key = JournalDay.dayString(from: instant, calendar: LibraryDayFace.calendar)
        #expect(JournalDay.isValid(key))
        #expect(DayBounds(day: key, calendar: LibraryDayFace.calendar) != nil)
    }

    // MARK: - The cap, and the day's answer (the ladder's R1-4)

    /// **The day's answer is whole; every other listing is PAGED.**
    /// Red on old: `truncated` did not exist and the day's answer stopped at
    /// 40 with nothing said.
    ///
    /// **JUSTIFIED EDIT (17y B1 (k)):** the ordinary listing used to be a
    /// capped page that SAID so ("showing the first 40"); her launch blocker
    /// retired the cap — it is now the first PAGE of an infinite scroll, and
    /// what it says is that another page follows (`notesHaveMore`). The
    /// subject (the day's answer is the whole set; the ordinary listing is
    /// bounded per read) is unchanged.
    @Test func theDaysAnswerIsWholeAndACappedListingSaysSo() async throws {
        try await withTravellingLibrary { session, clock in
            let total = LibraryCatalogModel.pageSize + 5
            for index in 0..<total {
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words")
            }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("cap"))

            await model.search()
            #expect(noteIDs(model).count == LibraryCatalogModel.pageSize,
                    "the ordinary listing's first read is a page")
            #expect(model.notesHaveMore, "…and another page follows")

            model.setEditedOn(day(of: clock.current))
            await model.search()
            #expect(noteIDs(model).count == total, "the day's answer is the whole set")
            #expect(!model.notesHaveMore, "so no page follows it")

            model.setEditedOn(nil)
            await model.search()
            #expect(model.notesHaveMore)
        }
    }

    /// The `+ 1` probe is exact at the boundary: a page's worth of notes is a
    /// full page with NOTHING after it; one more is a second page.
    /// **JUSTIFIED EDIT (17y B1 (k)):** the probe now answers "does another
    /// page follow" (`notesHaveMore`) where it answered "is this truncated".
    @Test func theProbeIsExactAtThePagesEdge() async throws {
        try await withTravellingLibrary { session, _ in
            for index in 0..<LibraryCatalogModel.pageSize {
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words")
            }
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("edge"))
            await model.search()
            #expect(noteIDs(model).count == LibraryCatalogModel.pageSize)
            #expect(!model.notesHaveMore, "exactly a page has nothing after it")

            let extra = try session.operations.createPost(title: "one more")
            _ = try session.operations.newBlock(in: extra.id, text: "words")
            await model.search()
            #expect(noteIDs(model).count == LibraryCatalogModel.pageSize)
            #expect(model.notesHaveMore, "one over the page IS a second page")
        }
    }

    // MARK: - The words

    /// The empty answer says the FACT and then the REASON — the product's
    /// honesty about its own one-stamp design, worded in ONE place
    /// (`LibraryDayFace.emptyAnswer`, which both the List mode's section and
    /// the Notes mode's column render through `LibraryDayEmptyAnswer`).
    @Test func anEmptyDaySaysWhichDayAndWhyItMightBeWrong() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-12T12:00:00.000Z"))

        let answer = LibraryDayFace.emptyAnswer(day: "2026-09-09", now: now, calendar: calendar)
        #expect(answer.headline == "No note's last edit or savepoint falls on Sep 9.")
        #expect(answer.caveat.contains("one edit stamp"))
        #expect(answer.caveat.contains("savepoint"))
        #expect(answer.caveat == LibraryDayFace.caveat,
                "the door's hover and the empty answer say the same sentence")

        // A day from another year carries it — *Sep 9* alone would be a lie
        // by omission (`TimeStampFace.day`'s own rule, inherited).
        let old = LibraryDayFace.emptyAnswer(day: "2025-09-09", now: now, calendar: calendar)
        #expect(old.headline.contains("Sep 9, 2025"))
    }

    @Test func theDoorSaysWhichDayItIsShowing() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-12T12:00:00.000Z"))
        // 13i-d U6 (c), a JUSTIFIED EDIT — her §21 note: "'on day…' wants
        // clearer wording"; the door now names what it filters by.
        #expect(LibraryDayFace.closedLabel == "edited on\u{2026}")
        #expect(LibraryDayFace.openLabel(day: "2026-09-09", now: now, calendar: calendar)
                == "edited on Sep 9")
        #expect(LibraryDayFace.dayWords(day: "not a day", now: now, calendar: calendar)
                == "not a day", "a face draws what it has")
    }

    // MARK: - Where the controls stand

    /// The Timeline mode runs its own listing, so neither catalog control is
    /// rendered there — ONE rule, with 18h batch 1's name still reading it.
    @Test func theTimelineModeOffersNeitherCatalogControl() async throws {
        try await withTravellingLibrary { session, _ in
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("timeline"))
            #expect(model.showsCatalogControls)
            model.mode = .notes
            #expect(model.showsCatalogControls)
            model.mode = .timeline
            #expect(!model.showsCatalogControls)
        }
    }

    /// The day and the sort are both parameters of the ONE listing, so they
    /// compose: the day narrows, the sort orders what is left.
    @Test func theDayAndTheSortComposeOnOneListing() async throws {
        try await withTravellingLibrary { session, clock in
            let today = clock.current
            let apple = try session.operations.createPost(title: "apple")
            _ = try session.operations.newBlock(in: apple.id, text: "a")
            let banana = try session.operations.createPost(title: "banana")
            _ = try session.operations.newBlock(in: banana.id, text: "b")
            clock.set(today.addingTimeInterval(2 * 86_400))
            let cherry = try session.operations.createPost(title: "cherry")
            _ = try session.operations.newBlock(in: cherry.id, text: "c")

            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("compose"))
            model.setEditedOn(day(of: today))
            model.setSort(.title)   // takes A–Z, batch 1's natural direction
            await model.search()
            #expect(noteIDs(model) == [apple.id, banana.id])

            model.setDirection(.desc)
            await model.search()
            #expect(noteIDs(model) == [banana.id, apple.id], "the sort still orders the day")
        }
    }
}
