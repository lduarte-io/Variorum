//
//  ScaleFixture.swift
//  Variorum (Mac) — DEBUG ONLY, and inside DEBUG only when asked for
//
//  17y B1 — THE LARGE FIXTURE for the two performance items: (k) the
//  Library's infinite scroll ("hundreds+ of notes") and (j) the in-note
//  Index's scroll (one LONG note). Her bar for (k), verbatim: it "needs to be
//  SMOOTH like the rest of the app — no performance losses are acceptable for
//  it!" — and smoothness at corpus scale can only be walked on a corpus.
//
//  GATED TWICE (the `VisualWalkProbe` / `SyntheticCrashReport` precedent):
//  `#if DEBUG` (a Release build compiles this file to nothing), and inside
//  DEBUG only when the process was launched with `VARIORUM_SCALE_FIXTURE`
//  set. The Debug build opens the fenced DEV store (`Variorum-dev`), so this
//  can only ever write there; `Tools/ScaleFixture/stage.sh` takes the A1
//  safety copy of the dev store BEFORE the launch that seeds, and
//  `restore.sh` puts that copy back afterwards (the fixture is staging, not
//  content).
//
//  WHAT IT MINTS (once — a live note titled `longNoteTitle` is the marker,
//  so a second launch with the key set does nothing):
//  - `notes` ordinary notes, all tagged `#scale-fixture`, their `created_at`
//    spread over ~2 years and their last edit later than their birth (so the
//    four Library sorts each order the corpus differently); every 7th is
//    UNTITLED (it reads as its date), every 5th carries an `entry_date`,
//    every 13th has NO block at all (never touched — its `last_touched_at`
//    stays NULL, the edited sort's COALESCE fallback), 1–6 blocks otherwise.
//  - ONE long note of `long` blocks in the shape that defeats a lazy column's
//    height estimate: a long-paragraph opening, then mostly short dialogue
//    lines, a `# Part N` heading every 100 blocks (the ▸ 01 column's
//    sections), a long paragraph every 25th block.
//
//  Writes go through the operations API only, on a QUIET `Operations` (no
//  undo stack — the seeders' MINOR-D1 rule), each note under its own fixed
//  clock (`withDependencies`), inside the session's serialized runner.
//
//  13n-c U2 — THE GRANT ROAD's SCALE (her "a user might have hundreds of
//  books and notes"): with `books=N,shelves=M` the fixture also mints N books
//  across M shelves of Home (every 13th left unshelved), the fixture's notes
//  filed into them round-robin, a few starred (the star cap tolerated), every
//  17th finished, every 23rd owned, one archived, one journal-TRAIT book, one
//  Private book and one Private note — and TWO books called "the adventures
//  of sherlock holmes" on the first shelf, made two days apart (her
//  screenshot's case), plus a pair "notes toward a chapter" on two shelves.
//  Its own marker (a live book named `grantMarkerBook`), so a relaunch mints
//  nothing twice. For the grant-sheet walk:
//  `Tools/ScaleFixture/stage.sh notes=520,long=40,books=160,shelves=9`.
//
//  13n-c U6 — THE WING ON THE WIRE's live round (her sweep's shape): with
//  `wing=1` the fixture also mints the wing "variorum" holding the gathering
//  "parser things" (rule: #parser) and three #parser notes, the third marked
//  Private (the fenced member a wing grant must never list or count), and —
//  when an APPROVED client named "claude-code" already stands — her sweep's
//  two grants: edit · Home · always and write new · variorum · always
//  (STAGING, said plainly: the grant road's faces were walked at W-3…W-6).
//  Its marker is the live wing of that name. For the live round:
//  `Tools/ScaleFixture/stage.sh notes=30,long=1,books=20,shelves=3,wing=1`.
//

#if DEBUG
import Dependencies
import GRDB
import Foundation
import VariorumCore

@MainActor
enum ScaleFixture {
    static let environmentKey = "VARIORUM_SCALE_FIXTURE"
    nonisolated static let longNoteTitle = "scale fixture · long note"
    nonisolated static let tagName = "scale-fixture"

    struct Request: Equatable {
        var notes = 600
        var longBlocks = 2000
        /// 13n-c U2 — the grant road's books (0 = none, the shipped fixture).
        var books = 0
        var shelves = 8
        /// 13n-c U6 — the wing on the wire's live round (0 = none).
        var wing = 0

        /// `"notes=600,long=2000[,books=160,shelves=9]"`; every part optional;
        /// nil when unset.
        static func parse(_ raw: String?) -> Request? {
            guard let raw, !raw.isEmpty else { return nil }
            var request = Request()
            for part in raw.split(separator: ",") {
                let pair = part.split(separator: "=", maxSplits: 1).map(String.init)
                guard pair.count == 2, let value = Int(pair[1]), value >= 0 else { continue }
                switch pair[0] {
                case "notes": request.notes = value
                case "long": request.longBlocks = value
                case "books": request.books = value
                case "shelves": request.shelves = max(1, value)
                case "wing": request.wing = value
                default: continue
                }
            }
            return request
        }
    }

    /// The books part's marker (13n-c U2).
    nonisolated static let grantMarkerBook = "Fixture book 001 \u{2014} on the river at dusk"
    /// The wing part's marker and its gathering (13n-c U6).
    nonisolated static let wingName = "variorum"
    nonisolated static let gatheringName = "parser things"

    private static var started = false

    /// Called from the window's appearance once the session exists. A no-op
    /// unless the walk launched this process with the key set.
    static func seedIfRequested(
        session: AppSession,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        guard let request = Request.parse(environment[environmentKey]), !started else { return }
        started = true
        Task {
            do {
                let minted = try await seed(session: session, request: request)
                NSLog("ScaleFixture: %@", minted
                    ? "minted \(request.notes) notes + a \(request.longBlocks)-block note"
                        + (request.books > 0 ? " + \(request.books) books on \(request.shelves) shelves" : "")
                        + (request.wing > 0 ? " + the wing \(wingName)" : "")
                    : "already present — nothing minted")
            } catch {
                NSLog("ScaleFixture: failed — %@", String(describing: error))
            }
        }
    }

    /// Mints the fixture into the session's store; false when every
    /// requested part's marker already stands.
    static func seed(session: AppSession, request: Request) async throws -> Bool {
        let (notesPresent, booksPresent, wingPresent) = try await session.database.read { db in
            (try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND title = ?
                """, arguments: [longNoteTitle]) ?? 0,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM reading WHERE deleted_at IS NULL AND name = ?",
                              arguments: [grantMarkerBook]) ?? 0,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM wing WHERE deleted_at IS NULL AND name = ?",
                              arguments: [wingName]) ?? 0)
        }
        let mintNotes = notesPresent == 0
        let mintBooks = request.books > 0 && booksPresent == 0
        let mintWing = request.wing > 0 && wingPresent == 0
        guard mintNotes || mintBooks || mintWing else { return false }
        let base = Date().addingTimeInterval(-2 * 365 * 86_400)
        let notes = request.notes, longBlocks = request.longBlocks
        let books = request.books, shelves = request.shelves
        try await session.runner.run { _ in
            if mintNotes {
                let tagID = try Operations(undoStack: nil).createTag(parent: nil, name: tagName).id
                for index in 0..<notes {
                    try mintNote(index: index, base: base, tagID: tagID)
                }
                try mintLongNote(blocks: longBlocks, tagID: tagID)
            }
            if mintBooks {
                try mintBooksPart(books: books, shelves: shelves, base: base)
            }
            if mintWing {
                try mintWingPart()
            }
        }
        return true
    }

    // MARK: - The wing on the wire's live round (13n-c U6)

    nonisolated private static func mintWingPart() throws {
        let ops = Operations(undoStack: nil)
        let wing = try ops.createWing(name: wingName)
        let parser = try ops.createTag(parent: nil, name: "parser", wingID: wing.id)
        _ = try ops.createReading(
            name: gatheringName, kind: .gathering, querySpec: try RuleGrammar.encode(.tag(parser.id)),
            wingId: wing.id)
        for (index, title) in ["the lexer", "the grammar", "a private parser note"].enumerated() {
            let note = try ops.createPost(title: title, wingId: wing.id)
            _ = try ops.newBlock(in: note.id, text: paragraph(seed: 90 + index, long: false), registeringUndo: false)
            _ = try ops.applyTag(parser.id, toPost: note.id)
            if index == 2 { _ = try ops.setNotePrivate(note.id, true) }
        }
        @Dependency(\.database) var database
        guard let client = try database.read({ try Queries.mcpClient($0, name: "claude-code") }),
              client.state == .approved
        else { return }
        _ = try ops.grantMCPAccess(client.id, .init(rung: .edit, scopeKind: .wing, scopeID: "", duration: .always))
        _ = try ops.grantMCPAccess(
            client.id, .init(rung: .writeNew, scopeKind: .wing, scopeID: wing.id, duration: .always))
    }

    // MARK: - The grant road's books (13n-c U2)

    nonisolated private static let shelfThemes = [
        "essays", "research", "letters", "translations", "drafts", "poetry", "reading",
        "workshop", "notebooks", "archive", "travel", "lectures",
    ]

    nonisolated private static func mintBooksPart(books: Int, shelves: Int, base: Date) throws {
        let ops = Operations(undoStack: nil)
        var shelfIDs: [String] = []
        for index in 0..<shelves {
            let theme = shelfThemes[index % shelfThemes.count]
            let name = index < shelfThemes.count ? theme : "\(theme) \(index / shelfThemes.count + 1)"
            shelfIDs.append(try ops.createShelf(name: name).id)
        }
        // The fixture's own notes (tagged), oldest first — filed round-robin.
        @Dependency(\.database) var database
        let noteIDs = try database.read { db in
            try String.fetchAll(db, sql: """
                SELECT c.id FROM container c
                JOIN post_tag pt ON pt.post_id = c.id AND pt.deleted_at IS NULL
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL AND t.name = ?
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL
                ORDER BY c.created_at, c.id
                """, arguments: [tagName])
        }
        var bookIDs: [String] = []
        for index in 0..<books {
            let made = base.addingTimeInterval(Double(index) * 3 * 86_400 + Double((index * 7_919) % 40_000))
            let name: String
            switch index {
            case 0: name = grantMarkerBook
            case 1, 2: name = "the adventures of sherlock holmes"
            case 3, 4: name = "notes toward a chapter"
            case 5: name = "dream journal"
            default:
                name = "Fixture book \(String(format: "%03d", index + 1)) \u{2014} \(phrases[index % phrases.count])"
            }
            let book = try withDependencies { $0.date = .constant(made) } operation: {
                try Operations(undoStack: nil).createReading(
                    name: name, kind: .book, profile: index == 5 ? "journal" : nil)
            }
            bookIDs.append(book.id)
            // The sherlocks share the FIRST shelf (so the ladder falls to the
            // made day); the chapter pair sits on two shelves (the shelf rung).
            let shelf: String? = switch index {
            case 1, 2: shelfIDs[0]
            case 3: shelfIDs[1 % shelfIDs.count]
            case 4: shelfIDs[2 % shelfIDs.count]
            default: index % 13 == 7 ? nil : shelfIDs[index % shelfIDs.count]
            }
            if let shelf { try ops.setReadingShelf(book.id, shelf: shelf) }
        }
        for (position, noteID) in noteIDs.enumerated() where !bookIDs.isEmpty {
            _ = try? ops.addPostToReading(noteID, to: bookIDs[position % bookIDs.count])
        }
        for (index, id) in bookIDs.enumerated() {
            if index % 29 == 9 { try? ops.setStarred(.reading(id), starred: true) }
            if index % 17 == 11 { try? ops.lockReading(id) }
            if index % 23 == 13 { _ = try? ops.setReadingOwned(id, owned: true) }
        }
        if bookIDs.count > 40 {
            try? ops.archiveReading(bookIDs[40])
            _ = try? ops.setBookPrivate(bookIDs[39], true)
        }
        if let first = noteIDs.first { _ = try? ops.setNotePrivate(first, true) }
    }

    // MARK: - The ordinary notes

    nonisolated private static func mintNote(index: Int, base: Date, tagID: String) throws {
        // Spread over two years, with a deterministic jitter.
        let born = base.addingTimeInterval(Double(index) * 105_000 + Double((index * 7_919) % 40_000))
        let edited = born.addingTimeInterval(Double((index * 104_729) % (90 * 86_400)))
        let title: String? = index % 7 == 3 ? nil
            : "Fixture \(String(format: "%04d", index)) — \(phrases[index % phrases.count])"
        let entryDate: String? = index % 5 == 0 ? JournalDay.dayString(from: born) : nil
        let post = try withDependencies { $0.date = .constant(born) } operation: {
            try Operations(undoStack: nil).createPost(title: title, entryDate: entryDate)
        }
        try withDependencies { $0.date = .constant(born) } operation: {
            _ = try Operations(undoStack: nil).applyTag(tagID, toPost: post.id)
        }
        guard index % 13 != 6 else { return }  // never touched: last_touched_at stays NULL
        let blocks = 1 + (index % 6)
        try withDependencies { $0.date = .constant(edited) } operation: {
            let ops = Operations(undoStack: nil)
            for b in 0..<blocks {
                _ = try ops.newBlock(
                    in: post.id, text: paragraph(seed: index * 31 + b, long: b == 0 && index % 3 == 0),
                    registeringUndo: false)
            }
        }
    }

    // MARK: - The long note

    nonisolated private static func mintLongNote(blocks: Int, tagID: String) throws {
        guard blocks > 0 else { return }
        let ops = Operations(undoStack: nil)
        let post = try ops.createPost(title: longNoteTitle)
        _ = try ops.applyTag(tagID, toPost: post.id)
        for b in 0..<blocks {
            let text: String
            if b % 100 == 0 {
                text = "# Part \(b / 100 + 1)"
            } else if b < 12 || b % 25 == 0 {
                text = paragraph(seed: b, long: true)
            } else {
                text = dialogue[(b * 7) % dialogue.count]
            }
            _ = try ops.newBlock(in: post.id, text: text, registeringUndo: false)
        }
    }

    // MARK: - The words (deterministic, prose-shaped)

    nonisolated private static func paragraph(seed: Int, long: Bool) -> String {
        let count = long ? 6 + seed % 5 : 1 + seed % 3
        return (0..<count).map { sentences[(seed + $0 * 3) % sentences.count] }.joined(separator: " ")
    }

    nonisolated private static let phrases = [
        "on the river at dusk", "a letter never sent", "notes toward a chapter",
        "the second draft", "what the garden knew", "morning pages", "a list of small things",
        "the long way home", "an argument with myself", "field notes, late",
        "the kitchen in winter", "questions for later",
    ]

    nonisolated private static let sentences = [
        "The light came in low across the table and caught the edge of every page.",
        "I had meant to write this down weeks ago, before the details began to blur.",
        "She said the house sounded different at night, and I believed her.",
        "There is a version of this paragraph that says everything plainly.",
        "We walked the long way round, past the shuttered bakery and the empty lot.",
        "Nothing about the plan survived the first hour, which was almost a relief.",
        "The river was higher than anyone remembered, brown and fast and quiet.",
        "I keep returning to the same three sentences, rearranging them like furniture.",
        "By evening the argument had worn itself smooth and neither of us could find its edges.",
        "It is strange how a single word can hold a whole afternoon inside it.",
        "The draft is longer than it needs to be, and that is fine for now.",
        "Somewhere under all of this is the thing I actually want to say.",
    ]

    nonisolated private static let dialogue = [
        "“Is that all?”", "“Quite so.”", "“I cannot say.”", "“Then we are agreed.”",
        "He nodded, and said nothing more.", "“Not yet — but soon.”", "“Why now?”",
        "She laughed at that, briefly.", "“You may be right.”", "“And the letter?”",
        "“Gone,” he said. “Burned, or worse.”", "A long pause followed.",
        "“Tell me everything, from the beginning.”", "“I will try.”",
    ]
}
#endif
