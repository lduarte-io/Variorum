import Dependencies
import Foundation
import Testing
@testable import VariorumCore

/// **18h batch 1 — TIME: the Library's sort and the two stamps it reads**
/// (the 2026-09-12 use-report round, her ledger rows 9 and 10; rulings R-Q7
/// and R-Q8's first half).
///
/// Her words: *"i need to be able to sort the library by time… the time alone
/// is a minimum"* and *"I need to be able to see the created time and last
/// edited time easily on the library and within the note itself."*
///
/// RED ON OLD — a PRODUCT row, so the pins do not COMPILE on the pre-change
/// tree, which is the honest shape of "the capability is absent":
/// `searchCatalog` had no `sort:`/`direction:` parameters (its post arm's
/// ORDER BY was the one hardwired `COALESCE(last_touched_at, created_at)
/// DESC`), `LibrarySort` had no `.title` case and no raw values, and
/// `CatalogHit` carried no stamps at all — the row's only date was
/// `detail`, the ENTRY date. The recorded compile errors are the batch
/// record's red-on-old evidence.
@Suite("The Library sorts by time, and its rows carry the stamps (18h batch 1)")
struct LibraryTimeSortTests {
    /// Three notes whose four orders are all DIFFERENT, so a pin that passes
    /// cannot be passing by luck:
    ///
    /// | note | title | entry date | created | last touched |
    /// |------|-------|-----------|---------|--------------|
    /// | A | `apple`  | 2026-03-01 | 1st | 2nd |
    /// | B | `Banana` | 2026-01-15 | 2nd | 3rd (newest) |
    /// | C | *(none)* | 2026-02-20 | 3rd | 1st (oldest) |
    ///
    /// So: created ↓ = C B A · edited ↓ = B A C · entry date ↓ = A C B ·
    /// title ↑ = C A B (C's display name is its day, `2026-02-20`, and
    /// digits sort before letters under NOCASE).
    private struct Fixture {
        let a: String
        let b: String
        let c: String
    }

    private func fixture(_ ops: Operations) throws -> Fixture {
        let a = try ops.createPost(title: "apple", entryDate: "2026-03-01")
        let b = try ops.createPost(title: "Banana", entryDate: "2026-01-15")
        let c = try ops.createPost(entryDate: "2026-02-20")
        // One block each, so a note is a real note; then TOUCH them in a
        // different order than they were minted (the whole point of the two
        // stamps — AppSpec §10).
        let blockA = try ops.newBlock(in: a.id, text: "A")
        let blockB = try ops.newBlock(in: b.id, text: "B")
        let blockC = try ops.newBlock(in: c.id, text: "C")
        try ops.autosave(blockC.variant.id, text: "C typed", charDelta: 6)
        try ops.autosave(blockA.variant.id, text: "A typed", charDelta: 6)
        try ops.autosave(blockB.variant.id, text: "B typed", charDelta: 6)
        return Fixture(a: a.id, b: b.id, c: c.id)
    }

    private func noteIDs(
        _ db: AppDatabase, sort: Queries.LibrarySort, direction: SortDirection
    ) throws -> [String] {
        try db.read { db in
            try Queries.searchCatalog(db, query: "", sort: sort, direction: direction)
                .filter { $0.kind == .post }
                .map(\.id)
        }
    }

    @Test func theCatalogSortsByEveryStampInBothDirections() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)

            #expect(try noteIDs(db, sort: .lastTouched, direction: .desc) == [f.b, f.a, f.c],
                    "edited, newest first — the shipped default's own order")
            #expect(try noteIDs(db, sort: .lastTouched, direction: .asc) == [f.c, f.a, f.b],
                    "edited, oldest first")
            #expect(try noteIDs(db, sort: .createdAt, direction: .desc) == [f.c, f.b, f.a],
                    "created, newest first — a DIFFERENT order from edited")
            #expect(try noteIDs(db, sort: .createdAt, direction: .asc) == [f.a, f.b, f.c])
            #expect(try noteIDs(db, sort: .entryDate, direction: .desc) == [f.a, f.c, f.b],
                    "the note's own stated day")
            #expect(try noteIDs(db, sort: .entryDate, direction: .asc) == [f.b, f.c, f.a])
        }
    }

    /// The added case: **the DISPLAY title's order** — what she is looking
    /// at, never the raw column (a note with no stored title shows its day,
    /// so its day is what it sorts by; `DisplayTitle`'s own fallback chain,
    /// as SQL).
    @Test func titleSortsOnTheDisplayedNameCaseInsensitively() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            #expect(try noteIDs(db, sort: .title, direction: .asc) == [f.c, f.a, f.b],
                    "A–Z on the DISPLAYED name, case-folded: 2026-02-20 · apple · Banana")
            #expect(try noteIDs(db, sort: .title, direction: .desc) == [f.b, f.a, f.c])
        }
    }

    /// Case-folding is the claim, not a coincidence of the fixture: a
    /// lowercase name that would sort AFTER an uppercase one under SQLite's
    /// default BINARY collation sorts before it here.
    @Test func titleSortIgnoresCase() throws {
        try withOperations { ops, db in
            let zebra = try ops.createPost(title: "Zebra")
            let apple = try ops.createPost(title: "apple")
            let ids = try noteIDs(db, sort: .title, direction: .asc)
            #expect(ids == [apple.id, zebra.id],
                    "NOCASE: apple before Zebra (BINARY would give Zebra first)")
        }
    }

    /// The default is the shipped behaviour, byte for byte — a caller that
    /// says nothing gets exactly the order it got before this batch.
    @Test func theDefaultIsTheShippedEditedNewestFirstOrder() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let defaulted = try db.read { db in
                try Queries.searchCatalog(db, query: "")
                    .filter { $0.kind == .post }.map(\.id)
            }
            #expect(defaulted == [f.b, f.a, f.c])
        }
    }

    /// **The sort is the POST arm's** (review focus F-5: one query, a
    /// parameter). Books stay by name and blocks by their own recency
    /// whatever the notes are sorted by — a book list that reshuffled with
    /// the note sort would be the second query this batch refuses to write.
    @Test func booksAndBlocksKeepTheirOwnOrderUnderEverySort() throws {
        try withOperations { ops, db in
            _ = try ops.createReading(name: "zebra book", kind: .curated)
            _ = try ops.createReading(name: "apple book", kind: .curated)
            let post = try ops.createPost(title: "carrier")
            let first = try ops.newBlock(in: post.id, text: "first")
            let second = try ops.newBlock(in: post.id, text: "second")
            try ops.setBlockName(first.block.id, name: "zeta block")
            try ops.setBlockName(second.block.id, name: "alpha block")

            for sort in [Queries.LibrarySort.lastTouched, .createdAt, .entryDate, .title] {
                let hits = try db.read { db in
                    try Queries.searchCatalog(db, query: "", sort: sort, direction: .desc)
                }
                #expect(hits.filter { $0.kind == .book }.map(\.title)
                        == ["apple book", "zebra book"],
                        "\(sort): books stay by name")
                let named = try db.read { db in
                    try Queries.searchCatalog(db, query: "block", sort: sort, direction: .desc)
                        .filter { $0.kind == .block }.map(\.id)
                }
                #expect(named == [second.block.id, first.block.id],
                        "\(sort): blocks stay by their own updated_at, newest first")
            }
        }
    }

    /// **Row 9's core half:** every note hit carries BOTH stamps, so a row
    /// can show the one its sort is about without a second read and without
    /// anything being stored anywhere new (the no-denormalization rule).
    @Test func everyNoteHitCarriesItsCreatedAndEditedStamps() throws {
        try withOperations { ops, db in
            let f = try fixture(ops)
            let hits = try db.read { db in try Queries.searchCatalog(db, query: "") }
            let notes = hits.filter { $0.kind == .post }
            #expect(notes.count == 3)
            for hit in notes {
                #expect(hit.createdAt != nil, "the mint's stamp rides the hit")
                #expect(hit.lastTouchedAt != nil, "…and the last keystroke's")
            }
            // …and they are the store's own values, not a re-derivation: the
            // edited stamp of the newest-edited note is the largest of the three.
            let byID = Dictionary(uniqueKeysWithValues: notes.map { ($0.id, $0) })
            let bEdited = try #require(byID[f.b]?.lastTouchedAt)
            let aEdited = try #require(byID[f.a]?.lastTouchedAt)
            let cEdited = try #require(byID[f.c]?.lastTouchedAt)
            #expect(bEdited > aEdited && aEdited > cEdited)
            let aCreated = try #require(byID[f.a]?.createdAt)
            let cCreated = try #require(byID[f.c]?.createdAt)
            #expect(cCreated > aCreated, "created runs the other way in this fixture")
            #expect(aEdited > aCreated, "a touched note's edit stamp is later than its mint")
        }
    }

    /// A note nobody has typed in since the mint still reports an edited
    /// stamp — the COALESCE the whole app shares (`Queries.noteStamps`'s own
    /// rule), so no row is ever blank where a date belongs.
    @Test func anUntouchedNotesEditedStampFallsBackToItsMint() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "never typed in")
            let hit = try #require(try db.read { db in
                try Queries.searchCatalog(db, query: "never typed").first
            })
            #expect(hit.lastTouchedAt == hit.createdAt)
        }
    }

    /// **The masthead's read** (row 9's other half): the note's stamps come
    /// as ONE read, and it now carries the MINT beside the edit — the stamp
    /// her click flips to. `editedAt` and `savedAt` are byte-unchanged (18d's
    /// own pins in `NoteStampsTests` ride untouched, which is the parity
    /// proof).
    @Test func theNotesStampsReadCarriesTheMintBesideTheEdit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "the note")
            let block = try ops.newBlock(in: post.id, text: "one")
            try ops.autosave(block.variant.id, text: "one two", charDelta: 4)
            let stamps = try #require(try db.read { try Queries.noteStamps($0, postID: post.id) })
            #expect(stamps.createdAt == post.createdAt, "the mint, exactly as stored")
            #expect(stamps.editedAt > stamps.createdAt, "the edit is later than the mint")
        }
    }
}
