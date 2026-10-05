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

        /// `"notes=600,long=2000"`; either part optional; nil when unset.
        static func parse(_ raw: String?) -> Request? {
            guard let raw, !raw.isEmpty else { return nil }
            var request = Request()
            for part in raw.split(separator: ",") {
                let pair = part.split(separator: "=", maxSplits: 1).map(String.init)
                guard pair.count == 2, let value = Int(pair[1]), value >= 0 else { continue }
                switch pair[0] {
                case "notes": request.notes = value
                case "long": request.longBlocks = value
                default: continue
                }
            }
            return request
        }
    }

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
                NSLog("ScaleFixture: %@", minted ? "minted \(request.notes) notes + a \(request.longBlocks)-block note"
                    : "already present — nothing minted")
            } catch {
                NSLog("ScaleFixture: failed — %@", String(describing: error))
            }
        }
    }

    /// Mints the fixture into the session's store; false when the marker
    /// note already stands.
    static func seed(session: AppSession, request: Request) async throws -> Bool {
        let present = try await session.database.read { db in
            try Int.fetchOne(db, sql: """
                SELECT COUNT(*) FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND title = ?
                """, arguments: [longNoteTitle]) ?? 0
        }
        guard present == 0 else { return false }
        let base = Date().addingTimeInterval(-2 * 365 * 86_400)
        let notes = request.notes, longBlocks = request.longBlocks
        try await session.runner.run { _ in
            let tagID = try Operations(undoStack: nil).createTag(parent: nil, name: tagName).id
            for index in 0..<notes {
                try mintNote(index: index, base: base, tagID: tagID)
            }
            try mintLongNote(blocks: longBlocks, tagID: tagID)
        }
        return true
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
