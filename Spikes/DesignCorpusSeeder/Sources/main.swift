// DesignCorpusSeeder — Phase 13, Step A0(ii) (the deferred-12 pull-forward).
//
// Seeds the DEV STORE with a realistic shelf: several books (a daily
// journal, a bounded dream journal, a chaptered book, a finished book, a
// smart book, a blog series), hundreds of posts, fans, comments, callouts,
// chapters, scraps, tags, lenses, canvas positions, a 10k-word post — so
// every Stage B/C design decision is made against volume (density vs calm)
// and the taste checkpoint has a real library to walk.
//
// SAFETY (the A4 fence, by construction):
//  - writes ONLY `…/Variorum-dev/variorum.sqlite` (the container path a
//    sandboxed debug build resolves); the REAL store path is refused by a
//    hard guard;
//  - an existing dev store is MOVED ASIDE (timestamped), never deleted;
//    without `--replace` an existing non-empty store aborts the run;
//  - every row goes through the operations layer (invariants enforced);
//    rows are born unowned (signed-out identity) and the dev store never
//    pairs with the production mirror (the Phase 8 A4 sync seam).
//
// The run ends with the A0(iii) ON-DISK RESTORE DRILL REHEARSAL: a cold
// copy of the freshly seeded store via the A1 backup API into
// `Variorum-dev/Backups/`, re-opened through the recoverable-open path and
// verified. Numbers print for the phase plan's closeout.

import Dependencies
import Foundation
import GRDB
import VariorumCore

// MARK: - Deterministic prose

struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

var rng = SplitMix64(seed: 13)

let openers = [
    "The morning held", "It turns out", "Nobody warned me that", "I keep returning to",
    "There is a version of this where", "The notebook says", "Halfway through the week",
    "What strikes me first is", "The lighthouse keeper would say", "In the margin I wrote",
    "By dusk it was clear that", "The draft insists", "A quieter reading is that",
    "Some days the work is", "The sea took", "We measured the crossing by",
]
let middles = [
    "the smaller habit outlasted the grand plan", "the sentence wanted a plainer verb",
    "the light on the water refused metaphor", "the argument folds back on itself",
    "a list is a kind of mercy", "the second draft knew more than I did",
    "restraint reads as feeling once you trust it", "the day repeated with small variations",
    "the chapter turned out to be two chapters", "the log lied less than the letter",
    "an idea kept whole is an idea kept open", "the paragraph earned its keep",
    "the wind backed south and the mood with it", "every fan collapses into one choice eventually",
    "the pages take turns being true", "the take I abandoned was braver",
]
let closers = [
    "and that was enough for one day.", "which is why I am writing it down.",
    "so I let the line stand.", "and the rest is revision.",
    "— a thing worth keeping open.", "though the morning may disagree.",
    "and the book is better for it.", "so the day goes down as progress.",
    "which the next draft can argue about.", "and I closed the notebook satisfied.",
]

func sentence() -> String {
    "\(openers.randomElement(using: &rng)!) \(middles.randomElement(using: &rng)!), \(closers.randomElement(using: &rng)!)"
}

func paragraph(sentences: ClosedRange<Int> = 2...5) -> String {
    (0..<Int.random(in: sentences, using: &rng)).map { _ in sentence() }
        .joined(separator: " ")
}

// MARK: - Clock (authored-over-months timestamps)

final class SeedClock: @unchecked Sendable {
    private var current: Date
    private let lock = NSLock()
    init(start: Date) { current = start }
    func set(_ date: Date) { lock.lock(); current = date; lock.unlock() }
    func tick() -> Date {
        lock.lock(); defer { lock.unlock() }
        current = current.addingTimeInterval(Double(Int.random(in: 2...40, using: &rng)))
        return current
    }
}

func date(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.date(from: string)!
}

func dayKey(_ base: Date, plusDays days: Int) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: base.addingTimeInterval(Double(days) * 86_400))
}

// MARK: - Store resolution + the fence

let arguments = CommandLine.arguments
let replace = arguments.contains("--replace")

let container = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent("Library/Containers/io.lduarte.Variorum/Data/Library/Application Support")
let devDirectory = container.appendingPathComponent(
    AppDatabase.StoreVariant.dev.rawValue, isDirectory: true)
let storeURL = devDirectory.appendingPathComponent("variorum.sqlite")

// THE FENCE: the path must be the dev variant; anything else aborts.
precondition(
    storeURL.path.contains("/Variorum-dev/"),
    "SEEDER FENCE: refusing a non-dev store path: \(storeURL.path)")
precondition(
    !storeURL.path.contains("/Variorum/variorum.sqlite"),
    "SEEDER FENCE: the real store is untouchable")

let stamp = ISO8601DateFormatter().string(from: Date())
    .replacingOccurrences(of: ":", with: "")
if FileManager.default.fileExists(atPath: storeURL.path) {
    guard replace else {
        print("A dev store already exists at\n  \(storeURL.path)")
        print("Re-run with --replace to move it aside (never deleted) and seed fresh.")
        exit(1)
    }
    // Move aside, never delete — the pre-seed store stays recoverable.
    for suffix in ["", "-wal", "-shm"] {
        let source = URL(fileURLWithPath: storeURL.path + suffix)
        guard FileManager.default.fileExists(atPath: source.path) else { continue }
        let target = URL(fileURLWithPath: storeURL.path + ".pre-seed-\(stamp)" + suffix)
        try FileManager.default.moveItem(at: source, to: target)
    }
    print("moved the existing dev store aside → variorum.sqlite.pre-seed-\(stamp)")
}

let db = try AppDatabase.openStore(at: storeURL)
print("seeding dev store at \(storeURL.path)")

let clock = SeedClock(start: date("2026-02-01 09:00"))

// MARK: - The seed itself

struct Summary {
    var posts = 0, blocks = 0, takes = 0, comments = 0, callouts = 0
    var books = 0, chapters = 0, scraps = 0, tags = 0
}
var summary = Summary()

try withDependencies {
    $0.database = db
    $0.date = DateGenerator { clock.tick() }
} operation: {
    let ops = Operations()

    // -- Tags: a hierarchical taxonomy with real use (R45: hierarchy
    // surfaced, given its chance).
    let life = try ops.createTag(parent: nil, name: "life")
    let goals = try ops.createTag(parent: life.id, name: "goals")
    let dreams = try ops.createTag(parent: life.id, name: "dreams")
    let writing = try ops.createTag(parent: nil, name: "writing")
    let blog = try ops.createTag(parent: writing.id, name: "blog")
    let attention = try ops.createTag(parent: blog.id, name: "attention")
    let stars = try ops.createTag(parent: nil, name: "stars")
    let letters = try ops.createTag(parent: nil, name: "letters")
    let sailing = try ops.createTag(parent: nil, name: "sailing")
    summary.tags = 9

    func makePost(
        title: String?, profile: Profile?, entryDate: String? = nil,
        paragraphs: Int, wordsPerSentence: ClosedRange<Int> = 2...5,
        fanEvery: Int = 0, commentEvery: Int = 0, calloutEvery: Int = 0
    ) throws -> (id: String, blockIDs: [String]) {
        let post = try ops.createPost(title: title, profile: profile, entryDate: entryDate)
        summary.posts += 1
        var blockIDs: [String] = []
        for index in 0..<paragraphs {
            let made = try ops.newBlock(in: post.id, text: paragraph(), at: .end)
            blockIDs.append(made.block.id)
            summary.blocks += 1
            if fanEvery > 0, index % fanEvery == fanEvery - 1 {
                let takeCount = Int.random(in: 2...4, using: &rng)
                var parent = made.variant.id
                for _ in 1..<takeCount {
                    let branched = try ops.branchVariant(made.block.id, from: parent)
                    try ops.autosave(
                        branched.id, text: paragraph(),
                        charDelta: 40)
                    parent = branched.id
                    summary.takes += 1
                }
                _ = try ops.commit(made.variant.id, message: "checkpoint")
            }
            if commentEvery > 0, index % commentEvery == commentEvery - 1 {
                _ = try ops.addBlockComment(
                    to: made.block.id,
                    text: ["take 1 preferred; the ending might belong in ch. III",
                           "verify this date against the log",
                           "this is the paragraph the whole piece hangs on",
                           "too polite — try the blunter take tomorrow"]
                        .randomElement(using: &rng)!)
                summary.comments += 1
            }
            if calloutEvery > 0, index % calloutEvery == calloutEvery - 1 {
                try ops.setBlockPresentation(
                    made.block.id,
                    BlockPresentation(
                        color: ["blue", "sand", "sage"].randomElement(using: &rng)!,
                        emoji: Bool.random(using: &rng) ? "💡" : nil))
                summary.callouts += 1
            }
        }
        return (post.id, blockIDs)
    }

    // -- The daily journal: ~100 dated entries over 4.5 months, one block
    // each; a curated journal BOOK holds them (R50: ordinary membership).
    let journalBook = try ops.createReading(
        name: "Journal 2026", kind: .curated, profile: "journal",
        sortField: .entryDate, sortDir: .asc)
    summary.books += 1
    let journalStart = date("2026-03-01 20:00")
    for day in 0..<138 {
        guard Int.random(in: 0..<10, using: &rng) < 7 else { continue }  // ~70% of days
        let key = dayKey(journalStart, plusDays: day)
        clock.set(journalStart.addingTimeInterval(Double(day) * 86_400))
        let entry = try ops.createOrOpenJournalEntry(entryDate: key)
        _ = try ops.newBlock(in: entry.container.id, text: paragraph(sentences: 2...6), at: .end)
        summary.posts += 1
        summary.blocks += 1
        _ = try? ops.addPostToReading(entry.container.id, to: journalBook.id)
        if Int.random(in: 0..<10, using: &rng) < 2 {
            try ops.applyTag(dreams.id, toPost: entry.container.id)
        }
    }

    // -- The dream journal: a BOUNDED notebook (word_target's first real
    // face material), 14 dated entries, tagged life/dreams.
    let dreamBook = try ops.createReading(
        name: "Dream Journal", kind: .curated, profile: "journal",
        sortField: .entryDate, sortDir: .asc, wordTarget: 10_000)
    summary.books += 1
    let dreamStart = date("2026-05-02 07:15")
    for day in stride(from: 0, to: 70, by: 5) {
        clock.set(dreamStart.addingTimeInterval(Double(day) * 86_400))
        // Stage B round 2, BLOCKER: dream entries are .generic + dated —
        // container profile='journal' is the DAILY journal's shape (the
        // canonical-entry query and the bridge sweep key on it); journal-
        // BOOK identity lives on reading.profile. One-block segmentation
        // keeps the notebook feel.
        let (postID, _) = try makePost(
            title: "the \(["lighthouse", "orchard", "flooded library", "slow train", "glass city"].randomElement(using: &rng)!) dream",
            profile: .generic, entryDate: dayKey(dreamStart, plusDays: day),
            paragraphs: Int.random(in: 1...3, using: &rng))
        try ops.setSegmentationDefault(postID, segmentation: .oneBlock)
        try ops.applyTag(dreams.id, toPost: postID)
        _ = try ops.addPostToReading(postID, to: dreamBook.id)
    }

    // -- ORBIT: the chaptered book — 18 posts in 4 real chapters, fans,
    // comments, callouts (the Stage B/C showcase).
    clock.set(date("2026-02-10 10:00"))
    let orbit = try ops.createReading(
        name: "Orbit", kind: .curated, profile: "book", sortField: .manual)
    summary.books += 1
    let chapterNames = ["I / leaving", "II / the long middle", "III / the storm", "IV / arrival"]
    var orbitChapters: [ReadingSection] = []
    for name in chapterNames {
        orbitChapters.append(try ops.createSection(in: orbit.id, name: name))
        summary.chapters += 1
    }
    let orbitTitles = [
        "the night we decided", "provisions", "casting off", "first watch",
        "weeks like water", "the argument about the chart", "small repairs",
        "what the log refuses", "the storm found us", "three ways of telling it",
        "afterward the boat was smaller", "the island that wasn't",
        "letters home, unsent", "the keeper's hand", "trading the compass",
        "last day of the middle", "landfall", "what we kept",
    ]
    for (index, title) in orbitTitles.enumerated() {
        clock.set(date("2026-02-10 10:00").addingTimeInterval(Double(index) * 6.3 * 86_400))
        let (postID, _) = try makePost(
            title: title, profile: .bookChapter,
            paragraphs: Int.random(in: 5...11, using: &rng),
            fanEvery: 4, commentEvery: 5, calloutEvery: 9)
        try ops.applyTag(sailing.id, toPost: postID)
        _ = try ops.addPostToReading(postID, to: orbit.id)
        try ops.assignPostToSection(
            postID, in: orbit.id, section: orbitChapters[index * 4 / orbitTitles.count].id)
    }

    // -- LETTERS 2025: the finished book (28 short posts, then locked).
    clock.set(date("2026-02-02 08:00"))
    let lettersBook = try ops.createReading(
        name: "Letters, 2025", kind: .curated, profile: "collection", sortField: .createdAt)
    summary.books += 1
    for index in 0..<28 {
        let (postID, _) = try makePost(
            title: "letter \(index + 1)", profile: .blog,
            paragraphs: Int.random(in: 1...3, using: &rng))
        try ops.applyTag(letters.id, toPost: postID)
        _ = try ops.addPostToReading(postID, to: lettersBook.id)
    }
    try ops.lockReading(lettersBook.id)

    // -- The ATTENTION series: 3 researched blog posts with URL references.
    clock.set(date("2026-05-20 14:00"))
    for index in 0..<3 {
        let (postID, _) = try makePost(
            title: "attention, part \(index + 1)", profile: .blog,
            paragraphs: Int.random(in: 6...9, using: &rng),
            fanEvery: 5, commentEvery: 6)
        try ops.applyTag(attention.id, toPost: postID)
        _ = try ops.addReference(
            to: postID, kind: .url,
            name: "source \(index + 1)", url: "https://example.org/attention/\(index + 1)")
    }

    // -- STAR NOTES: a smart book from a tag (R30's family), finished.
    clock.set(date("2026-04-05 21:30"))
    for index in 0..<6 {
        let (postID, _) = try makePost(
            title: "star note \(index + 1)", profile: .generic,
            paragraphs: Int.random(in: 1...2, using: &rng))
        try ops.applyTag(stars.id, toPost: postID)
        try ops.applyTag(goals.id, toPost: postID)
    }
    let starBook = try ops.createReading(
        name: "star-notes", kind: .smart, profile: "collection",
        querySpec: try Queries.SmartQuerySpec(tags: ["stars"]).encodedJSON())
    summary.books += 1
    try ops.lockReading(starBook.id)

    // -- The 10k-word LONG post (scroll-feel material; P1's test subject).
    clock.set(date("2026-06-01 09:00"))
    let (longPost, _) = try makePost(
        title: "the keeper's hand — long draft", profile: .blog,
        paragraphs: 220, fanEvery: 18, commentEvery: 25)
    try ops.applyTag(blog.id, toPost: longPost)

    // -- Standalone quick posts (the POOL population — bookless by design).
    clock.set(date("2026-06-20 12:00"))
    for index in 0..<25 {
        _ = try makePost(
            title: index % 3 == 0 ? nil : "quick note \(index + 1)",
            profile: .generic, paragraphs: Int.random(in: 1...2, using: &rng))
    }

    // -- SCRAPS: the pool ("Blocks"), some fanned, some tagged, some
    // canvas-positioned.
    clock.set(date("2026-07-01 15:00"))
    let pool = try ops.createPool(title: "scraps")
    var scrapIDs: [String] = []
    for index in 0..<30 {
        let made = try ops.newBlock(in: pool.id, text: sentence(), at: .end)
        scrapIDs.append(made.block.id)
        summary.scraps += 1
        if index % 6 == 5 {
            let branched = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(branched.id, text: sentence(), charDelta: 20)
        }
        if index % 4 == 3 {
            try ops.applyTag([stars.id, dreams.id, goals.id].randomElement(using: &rng)!,
                             toBlock: made.block.id)
        }
    }
    for (index, scrapID) in scrapIDs.prefix(8).enumerated() {
        _ = try ops.setCanvasPosition(
            container: pool.id, block: scrapID,
            x: Double(80 + (index % 4) * 260), y: Double(60 + (index / 4) * 180))
    }

    // -- A lens on an Orbit post; an archived post; recovery material
    // (deleted post, deleted block, deleted comment) so every surface has
    // something to show.
    let orbitEntries = try db.read { try Queries.assembleReading($0, readingID: orbit.id, limit: 1) }
    if let showcase = orbitEntries.first {
        let lens = try ops.createLens(post: showcase.postID, name: "reader's cut")
        let placements = try db.read { database in
            try Row.fetchAll(database, sql: """
                SELECT block_id, chosen_variant_id FROM container_block
                WHERE container_id = ? AND deleted_at IS NULL ORDER BY position LIMIT 2
                """, arguments: [showcase.postID])
        }
        for placement in placements {
            if let chosen: String = placement["chosen_variant_id"] {
                _ = try ops.setLensChoice(
                    lens: lens.id, block: placement["block_id"], variant: chosen)
            }
        }
    }
    let (archivedPost, _) = try makePost(
        title: "an archived draft", profile: .generic, paragraphs: 2)
    try ops.archiveContainer(archivedPost)
    let (doomedPost, _) = try makePost(
        title: "a deleted draft (tray material)", profile: .generic, paragraphs: 2)
    try ops.deleteContainer(doomedPost)
    let (trayPost, trayBlocks) = try makePost(
        title: "post with a deleted block", profile: .generic, paragraphs: 3)
    try ops.deleteBlock(trayBlocks[1])
    _ = trayPost
    if let commented = scrapIDs.first {
        let comment = try ops.addBlockComment(to: commented, text: "a deleted note (recovery material)")
        try ops.deleteBlockComment(comment.id)
        summary.comments += 1
    }
}

// MARK: - Report + the A0(iii) on-disk drill rehearsal

let counts = try db.read { database -> [String: Int] in
    var result: [String: Int] = [:]
    for table in ["container", "block", "variant", "block_comment", "reading",
                  "reading_section", "reading_post", "tag", "canvas_layout", "lens"] {
        result[table] = try Int.fetchOne(
            database, sql: "SELECT COUNT(*) FROM \(table) WHERE deleted_at IS NULL") ?? 0
    }
    result["words"] = try Int.fetchOne(database, sql: """
        SELECT SUM(LENGTH(working_text) - LENGTH(REPLACE(working_text, ' ', '')) + 1)
        FROM variant WHERE deleted_at IS NULL
        """) ?? 0
    return result
}
print("\nDESIGN CORPUS SEEDED — live rows:")
for (table, count) in counts.sorted(by: { $0.key < $1.key }) {
    print(String(format: "  %-16s %d", (table as NSString).utf8String!, count))
}

// The restore drill, rehearsed against THIS real on-disk store: cold copy
// via the A1 backup API → recoverable open → verify.
let drillURL = devDirectory.appendingPathComponent(
    "Backups/variorum-backup-seed-drill-\(stamp).sqlite")
try db.backup(to: drillURL)
let restored = try AppDatabase.openStore(at: drillURL)
let drill = try restored.read { database -> (integrity: String?, posts: Int?) in
    (try String.fetchOne(database, sql: "PRAGMA integrity_check"),
     try Int.fetchOne(database, sql: "SELECT COUNT(*) FROM container WHERE deleted_at IS NULL"))
}
print("\nRESTORE DRILL (on-disk rehearsal):")
print("  cold copy:        \(drillURL.lastPathComponent)")
print("  integrity_check:  \(drill.integrity ?? "FAILED")")
print("  containers match: \(drill.posts == counts["container"]) (\(drill.posts ?? -1) vs \(counts["container"] ?? -1))")
print("  recoverable-open: OK (openStore path)")
print("\ndone.")
