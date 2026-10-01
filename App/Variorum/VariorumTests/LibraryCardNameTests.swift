//
//  LibraryCardNameTests.swift
//  VariorumTests
//
//  **13u3 UNIT B — note-list skimmability (her item 4, RULED 2026-08-21).**
//  Her words: *"that's exactly the right suggestion. I think that's what
//  should show on the library - a little snippet of what the post starts
//  with"*, and the caveat that shapes it: *"it can't be the whole first
//  sentence if that sentence is super long."*
//
//  The RULE is core's and is pinned there (`NoteCardFaceTests`). These cells
//  are about the Library's side of it: that the shipped hit carries the facts
//  the rule needs, that BOTH note renderers ask the one composition, that a
//  mode pays only for what it draws (P1), and — the rule the whole item rests
//  on — that a derived name is a PROJECTION: nothing is written, nothing is
//  renamed, and the rename door still seeds from the stored title.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("What a Library row leads with (13u3 UNIT B — her item 4)")
struct LibraryCardNameTests {

    // MARK: - Harness

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "13u3B-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func withLibrary<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 4))
        } operation: { @MainActor in
            try await body(AppSession(database: db), db)
        }
    }

    private func hit(
        _ model: LibraryCatalogModel, _ id: String
    ) throws -> Queries.CatalogHit {
        try #require(model.hits.first { $0.id == id })
    }

    // MARK: - The composition

    /// **The Library asks the one rule, with the facts its own row carries.**
    /// A name she typed leads; a daily entry leads with its day; everything
    /// else leads with the note's own first words.
    @Test func theRowLeadsWithHerNameElseTheDayElseItsOwnWords() async throws {
        try await withLibrary { session, _ in
            let named = try session.operations.createPost(title: "three ways of working")
            _ = try session.operations.newBlock(in: named.id, text: "The first words.")
            let bare = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(
                in: bare.id, text: "The lighthouse keeper counted the storms.")
            let entry = try session.operations.createOrOpenJournalEntry(entryDate: "2026-01-15")
            _ = try session.operations.newBlock(in: entry.container.id, text: "Frost, and a fox.")

            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("lead"))
            model.mode = .notes
            await model.search()

            let namedCard = LibraryCardName.card(
                for: try self.hit(model, named.id),
                leadingTexts: model.noteCards[named.id]?.leadingTexts ?? [])
            #expect(namedCard.lead == .title("three ways of working"))
            #expect(namedCard.preview == "The first words.")

            let bareCard = LibraryCardName.card(
                for: try self.hit(model, bare.id),
                leadingTexts: model.noteCards[bare.id]?.leadingTexts ?? [])
            #expect(bareCard.lead == .words("The lighthouse keeper counted the storms."),
                    "the wall of bare dates is what item 4 is about")

            let entryCard = LibraryCardName.card(
                for: try self.hit(model, entry.container.id),
                leadingTexts: model.noteCards[entry.container.id]?.leadingTexts ?? [])
            #expect(entryCard.lead == .day("2026-01-15"),
                    "a daily entry's date IS its identity — her rule, riding with item 4")
            #expect(entryCard.preview == "Frost, and a fox.")
        }
    }

    /// **13u3 UNIT G (UNIT B's hand-up) — RED ON `25638746`.** The card's read
    /// resolved its opening through a bare
    /// `COALESCE(cb.chosen_variant_id, b.default_variant_id)`, which agrees
    /// with the note only while the chosen take is live, active and this
    /// block's. It isn't `renderPost`'s rule, and the three shapes where it
    /// parts company are all reachable: an ARCHIVED chosen take previewed the
    /// archived text (the note shows the default), a TOMBSTONED one previewed
    /// a BLANK card (the note shows the default), and a FOREIGN chosen pointer
    /// — the sync-race class the operations layer guards with "a foreign
    /// chosen must never let an op rewrite another block's text" — previewed
    /// another block's prose. The read is `renderPost`'s rule verbatim now.
    @Test func aCardPreviewsTheTakeTheNoteShows() async throws {
        try await withLibrary { session, db in
            let ops = session.operations

            // Archived chosen → the note falls back to the default.
            let archived = try ops.createPost(title: "archived chosen")
            let a = try ops.newBlock(in: archived.id, text: "The default take.")
            let aSpare = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(aSpare.id, text: "The archived take.", charDelta: 0)
            try ops.chooseVariant(a.block.id, variantID: aSpare.id)
            try ops.archiveVariant(aSpare.id)

            // Tombstoned chosen → the note falls back; the card went blank.
            let dead = try ops.createPost(title: "dead chosen")
            let d = try ops.newBlock(in: dead.id, text: "The surviving take.")
            let dSpare = try ops.branchVariant(d.block.id, from: d.variant.id)
            try ops.autosave(dSpare.id, text: "The doomed take.", charDelta: 0)
            try ops.chooseVariant(d.block.id, variantID: dSpare.id)
            try await db.write { database in
                try database.execute(
                    sql: "UPDATE variant SET deleted_at = ? WHERE id = ?",
                    arguments: ["2026-09-19T00:00:00Z", dSpare.id])
            }

            // A FOREIGN chosen pointer (the sync-race shape).
            let foreign = try ops.createPost(title: "foreign chosen")
            let f = try ops.newBlock(in: foreign.id, text: "My own words.")
            let elsewhere = try ops.newBlock(in: foreign.id, text: "Another block's words.")
            try await db.write { database in
                try database.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = ? WHERE block_id = ?",
                    arguments: [elsewhere.variant.id, f.block.id])
            }

            // What each note actually SHOWS — the rule the card owes.
            let shown = try await db.read { database in
                [archived.id: try Queries.renderPost(database, containerID: archived.id),
                 dead.id: try Queries.renderPost(database, containerID: dead.id),
                 foreign.id: try Queries.renderPost(database, containerID: foreign.id)]
            }
            #expect(shown[archived.id]?.first?.text == "The default take.",
                    "non-vacuity: the note falls back past the archived take")
            #expect(shown[dead.id]?.first?.text == "The surviving take.")
            #expect(shown[foreign.id]?.first?.text == "My own words.")

            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("take"))
            model.mode = .notes
            await model.search()
            #expect(model.noteCards[archived.id]?.snippet == "The default take.",
                    "on old: the archived take's own words")
            #expect(model.noteCards[dead.id]?.snippet == "The surviving take.",
                    "on old: a blank card")
            #expect(model.noteCards[foreign.id]?.snippet == "My own words.",
                    "on old: another block's words")
        }
    }

    /// **A card that leads with a HEADING has the prose under it to preview**
    /// — the reason the read stopped throwing every block but the first away.
    @Test func aHeadingLedCardStillHasSomethingToPreview() async throws {
        try await withLibrary { session, _ in
            let post = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(in: post.id, text: "# Garden plans")
            _ = try session.operations.newBlock(in: post.id, text: "Beds first, then the fence.")

            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("head"))
            model.mode = .notes
            await model.search()
            let card = try #require(model.noteCards[post.id])
            #expect(card.leadingTexts.count == 2, "the window's blocks, in order")
            #expect(card.snippet == "# Garden plans",
                    "…and the 13g answer is still the first block with text in it")

            let name = LibraryCardName.card(
                for: try self.hit(model, post.id), leadingTexts: card.leadingTexts)
            #expect(name.lead == .words("Garden plans"), "rendered, not printed")
            #expect(LibraryCardName.previewLine(name) == "Beds first, then the fence.")
        }
    }

    /// **The card's second line never repeats the lead and never lies.**
    @Test func theSecondLineCarriesOnOrStandsDown() {
        let whole = NoteCardFace.card(storedTitle: nil, leadingTexts: ["A short one."])
        #expect(LibraryCardName.previewLine(whole) == nil,
                "the card has already said the whole note")

        let long = NoteCardFace.card(
            storedTitle: nil,
            leadingTexts: [
                "The lighthouse keeper counted the storms and wrote none of them down, ever."
            ])
        #expect(LibraryCardName.previewLine(long)?.hasPrefix("wrote") == true)

        let empty = NoteCardFace.card(storedTitle: "Named", leadingTexts: [])
        #expect(LibraryCardName.previewLine(empty) == LibraryCopy.noTextYet)

        let emptyDay = NoteCardFace.card(storedTitle: nil, leadingTexts: [], entryDate: "2026-01-15")
        #expect(LibraryCardName.previewLine(emptyDay) == LibraryCopy.noTextYet)
    }

    // MARK: - What each mode pays for (P1)

    /// **A mode reads what it DRAWS, and nothing else.** Notes draws the
    /// whole card, so every listed note is read, books included; List draws
    /// one line, so it reads the words only for the rows that would otherwise
    /// be a bare date and never the memberships; Timeline draws neither.
    @Test func eachModeReadsWhatItDraws() async throws {
        try await withLibrary { session, _ in
            let named = try session.operations.createPost(title: "named")
            _ = try session.operations.newBlock(in: named.id, text: "words")
            let bare = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(in: bare.id, text: "bare words")
            let entry = try session.operations.createOrOpenJournalEntry(entryDate: "2026-01-15")
            _ = try session.operations.newBlock(in: entry.container.id, text: "diary")
            let book = try session.operations.createReading(name: "Orbit", kind: .book)
            _ = try session.operations.addPostToReading(named.id, to: book.id)

            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("plan"))
            model.mode = .notes
            await model.search()

            let notes = LibraryCardRead.plan(mode: .notes, hits: model.hits)
            #expect(Set(notes.ids) == [named.id, bare.id, entry.container.id])
            #expect(notes.books)
            #expect(model.noteCards[named.id]?.books == ["Orbit"])

            let list = LibraryCardRead.plan(mode: .list, hits: model.hits)
            #expect(list.ids == [bare.id],
                    "the named note says what it is; the daily entry is its day")
            #expect(!list.books, "the List row has no book-names slot to fill")

            #expect(LibraryCardRead.plan(mode: .timeline, hits: model.hits)
                    == LibraryCardRead(ids: [], books: false))

            // …and the model obeys the plan: switching to List drops the
            // books it no longer draws and keeps the one row's words.
            model.mode = .list
            await model.refreshNoteCards()
            #expect(model.noteCards.keys.sorted() == [bare.id])
            #expect(model.noteCards[bare.id]?.books.isEmpty == true)
            #expect(model.noteCards[bare.id]?.snippet == "bare words")

            // Timeline pays nothing at all.
            model.mode = .timeline
            await model.refreshNoteCards()
            #expect(model.noteCards.isEmpty)
        }
    }

    /// The words-only read is exactly that: no membership rows, no smart
    /// walk — and the words are unchanged by leaving them out.
    @Test func theWordsOnlyReadLeavesTheBooksAlone() async throws {
        try await withLibrary { session, db in
            let post = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(in: post.id, text: "Only the words.")
            let book = try session.operations.createReading(name: "Orbit", kind: .book)
            _ = try session.operations.addPostToReading(post.id, to: book.id)

            let withBooks = try await db.read { try NoteCards.load($0, postIDs: [post.id]) }
            #expect(withBooks[post.id]?.books == ["Orbit"])

            let wordsOnly = try await db.read {
                try NoteCards.load($0, postIDs: [post.id], includingBooks: false)
            }
            #expect(wordsOnly[post.id]?.books.isEmpty == true)
            #expect(wordsOnly[post.id]?.leadingTexts == withBooks[post.id]?.leadingTexts)
        }
    }

    // MARK: - The rule the whole item rests on

    /// **A DERIVED NAME IS A PROJECTION — nothing is written, ever.** Her
    /// words: *"what I hate is battling the apple notes title."* So: the
    /// stored title stays nil, the note's own row is untouched (its
    /// `updated_at` does not move), the SYNC OUTBOX gains nothing — which is
    /// the strongest available statement that no row was written by drawing a
    /// card — and the rename door still seeds from the stored title, never
    /// from the words on screen (13g batch 7's lesson).
    @Test func drawingACardWritesNothingAndRenamesNothing() async throws {
        try await withLibrary { session, db in
            let post = try session.operations.createPost(title: nil)
            _ = try session.operations.newBlock(in: post.id, text: "The first words of it.")

            func snapshot() async throws -> (title: String?, updated: String, outbox: Int) {
                try await db.read { db in
                    let row = try Row.fetchOne(
                        db, sql: "SELECT title, updated_at FROM container WHERE id = ?",
                        arguments: [post.id])!
                    let outbox = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
                    return (row["title"], row["updated_at"], outbox)
                }
            }
            let before = try await snapshot()

            let model = LibraryCatalogModel(session: session, defaults: try self.scrubbed("write"))
            for mode in [LibraryCatalogModel.Mode.notes, .list] {
                model.mode = mode
                await model.search()
                let hit = try self.hit(model, post.id)
                let name = LibraryCardName.card(
                    for: hit, leadingTexts: model.noteCards[post.id]?.leadingTexts ?? [])
                #expect(name.lead == .words("The first words of it."), "\(mode)")
                #expect(name.lead.isDerived, "\(mode): and it KNOWS it is derived")
                #expect(hit.storedTitle == nil,
                        "\(mode): the rename door's seed is still the stored title")
            }

            let after = try await snapshot()
            #expect(after.title == nil, "no title was ever written")
            #expect(before.title == nil)
            #expect(after.updated == before.updated, "the note's row did not move")
            #expect(after.outbox == before.outbox, "nothing was queued for sync")
        }
    }
}
