//
//  BirthFurnitureSeeders.swift
//  Variorum (Mac)
//
//  13s-b U1b — the two small pieces of BIRTH furniture the seed reshape
//  added beside the field guide (R-13s-5/26/27/39):
//
//    · **The example snippet** — ONE snippet in its own small group in the
//      Snippets area, carrying the standard disclaimer line (her Q17
//      disposition, R-13s-26: *"snippet ex seed - your call, yes, make it
//      that standard any resemblance to real ppl is unintentional movie
//      book etc. line"*). The tour's keep-going leg points at the first
//      snippet card; this is the card it finds on a fresh store.
//    · **The readme** (VX-105 — her finished text, R-13s-28): ONE
//      letter-shaped note, her seventeen blocks byte-exact as
//      `notes/plans/vx-105-letter-content/read-me.txt` carries them, one
//      take each; seeded LAST so it tops the Library by recency (R-13s-29). It
//      replaced the 13s placeholder (her unfinished "Lillian's Start Here"
//      draft and the four Start Here passages) whole.
//
//  Both follow `TutorialSeeder.seedAtBirth`'s grammar exactly: they run
//  ONLY on the Welcome arrangement's arrange-now road (a fresh store's
//  birth under the sync gate, or the `pending` resume of one — never an
//  existing store), on the QUIET facade (nothing on ⌥⌘Z), silently
//  (R-13r-11 — furniture never speaks; one log line each), and one read
//  decides: a live copy wins, then her deletion (a tombstoned container of
//  the reserved title — the `pending`-resume window is the only road a
//  deletion can precede this seed on), else the mint. No door latch is
//  needed, for two different reasons: the example snippet has no door at
//  all; the readme HAS one (Help ▸ Restore “readme”, VX-105 R-105-8), so its
//  birth seed decides INSIDE its mint's serialized runner turn — the door's
//  own shape — and a press queued ahead of the birth's turn is seen by it
//  (ladder round 1, MINOR-2). The tutorial's latch exists because its
//  doors' confirm road spans several turns; the readme's door is one turn.
//
//  MOBILE PARITY: the phone seeds neither (its onboarding furniture is the
//  mobile project's own) — recorded, never built here. Like the guide's,
//  their fold facts ride the MAC half only (`MacFurnitureFacts`): the
//  phone's engine stays inert on these titles and converges by receiving
//  the outcome rows (the nil-inert posture), and a pair met during a
//  posture-ceremony DRAIN folds at the regular engine's next pull — the
//  B-DEDUPE guide corner, unchanged.
//

import Dependencies
import Foundation
import GRDB
import OSLog
import VariorumCore

/// **The MAC's furniture-fold facts, composed in ONE named place** (13s-b
/// U1b piece 5 — pinnable, where the old composition lived inline in
/// `VariorumApp`'s closure): the SHARED half (the three seeded gatherings
/// and the reserved quicknote — KEPT for the installed base and the
/// still-mintable objects: Quicknotes mints at every store's first capture,
/// the classics gathering behind its door, and stores born before this
/// build carry the rest) + the GUIDE half + the two birth-furniture
/// containers this unit seeded, so every seeded object of the final set is
/// KNOWN to the fold (R-13s-5's release constraint; the 17y B-DEDUPE rules
/// bind each grain). One known exception to "folds on sign-in", ruled: the
/// readme is born STARRED (VX-105), and the note grain reads a star as her
/// engagement, so a fresh pair keeps both readmes; it folds only once
/// neither copy is starred (S-1 option B — the Prince's precedent; teaching
/// the fold a born star is VX-711).
@MainActor
enum MacFurnitureFacts {
    nonisolated static func compose() -> SeededFurnitureDedupeFacts {
        let guide = TutorialSeeder.furnitureFactsHalf()
        return SampleLibrarySeeder.furnitureDedupeFacts(
            guideBookName: guide.guideBookName,
            guideTagPath: guide.guideTagPath,
            guideContainers: guide.containers + [
                ExampleSnippetSeeder.furnitureFact,
                ReadmeSeeder.furnitureFact,
            ])
    }
}

/// **The readme** (VX-105 — her finished text; R-13s-28 binds absolutely:
/// never edited, reworded, re-punctuated or whitespace-cleaned). A standalone
/// BOOKLESS note titled "readme" (lowercase, her word — R-13s-27 and her
/// 2026-10-30 "i will change the name to readme"), in Home, untagged, seeded
/// LAST of the birth furniture so it tops the Library by recency (R-13s-29).
/// The content is her seventeen blocks, one take each — the letter IS the
/// readme (the content package's README records the convergence); the sign-off
/// is the last two blocks of the text itself.
///
/// It replaced the 13s placeholder WHOLE: her unfinished "Lillian's Start
/// Here" draft (five blocks and their takes) stopped seeding here — its
/// welcome and takes moment now open the field guide's "start here" lesson
/// (R-105-5) — and the four Start Here passages left with it: they live on as
/// the guide's protection chapter's lead (`TutorialSeeder.startHerePassages`,
/// one home now).
@MainActor
enum ReadmeSeeder {
    nonisolated static let title = "readme"

    /// The furniture fold's identity for the readme (13s-b U1b piece 5):
    /// a reserved-titled BOOKLESS note — two devices' copies fold at the
    /// container grain, content-identical and unengaged only (any tag,
    /// membership, savepoint or edit of hers keeps both — the standing
    /// B-DEDUPE rules). VX-105: the readme is born STARRED and a star is
    /// engagement on the note grain, so two FRESH seeds both keep; the pair
    /// folds only once neither copy is starred (S-1 option B, ruled; a born
    /// star read as identity is VX-711). No seed-authored tag paths: a tag on
    /// the readme is always her hand.
    nonisolated static var furnitureFact: SeededFurnitureDedupeFacts.ReservedContainer {
        .init(title: title, kind: "post")
    }

    /// Her seventeen blocks, in order, BYTE-EXACT as `read-me.txt` carries
    /// them (`notes/plans/vx-105-letter-content/`): the blank-line splits of
    /// her text are the block boundaries, the file's working header line
    /// (`{t:"readmev5"} {#readme}`) is not content. TRIMMED by her ruling
    /// (R-105-6, *"i don't think that it needs trailing spaces
    /// necessarily"*): her store's blocks carried one trailing space on all
    /// but blocks 2, 12, 16 and 17, and the seed does not restore it — so the
    /// package README's SHA-256 manifest (taken WITH those spaces) is
    /// interior-fidelity evidence only, never a drift alarm: each block below,
    /// plus the one space her store carried where it carried one, hashes to
    /// its manifest value. `LaunchFurnitureTests` pins both: byte equality
    /// against the in-repo file, and the manifest's interior fidelity.
    ///
    /// Minted block by block through `newBlock` (every byte stored as given),
    /// AFTER the note's own mint: the split stamp (`writtenAt`) needs the note
    /// created apart from its words, which `importPost`'s one clock cannot
    /// give — and her text's shape is the file's paragraphs, never a reading
    /// of the reader's segmentation setting.
    nonisolated static let paragraphs: [String] = [
        // 1
        "Variorum was built by one person and thousands of AI agents over the course of four months. I'm "
        + "Lillian, the human behind this project. I want to take the chance to introduce myself and share "
        + "a bit about the app, technology, and what it all means to me.",

        // 2
        "I created Variorum because I'm a software developer, I love writing, and I wanted to build my "
        + "own perfect writing app. It was only once the whole picture came together that I realized the "
        + "app philosophy I had designed for my own writing enabled a new way of working with AI.",

        // 3
        "Let me be clear: providing a new surface for AI to write for you is not the purpose of this "
        + "app. I do all of my own writing because writing is an invaluable way to refine and develop my "
        + "thoughts, to push them further than they can go in the limited context window of my own mind. I "
        + "also enjoy it. Every word you read here was typed by human fingers *and* I had an AI read over "
        + "my draft and leave comments. I used an \"and\" instead of a \"but\" because I believe that "
        + "collaboration instead of replacement is not only possible but tragically underserved by current "
        + "structures and workflows.",

        // 4
        "Software itself can and should provide features that increase the capacity of people to control "
        + "how they work with AI. Variorum carves out territory in the no man's land between \"used AI for "
        + "this\" and \"didn't use AI for this\", binary labels that unhelpfully collapse a spectrum of "
        + "different uses. There are real differences between having an AI leave comments on your original "
        + "writing, edit it directly, draft text for you to edit, and pull together sources for you. "
        + "Variorum lets you set your own boundaries with tools instead of writing prompts requesting that "
        + "they be honored.",

        // 5
        "There are three key features in Variorum, each built first for my own writing, that together "
        + "make working with AI more like spinning a dial than flipping a switch. Each addresses a core "
        + "challenge that the AI world's ubiquitous default \u{2014} a folder of markdown files \u{2014} "
        + "struggles with: managing what AI can change, reviewing those changes, and controlling what it "
        + "can see.",

        // 6
        "The namesake feature of this app is the ability to make different versions of a paragraph "
        + "\u{2014} a variorum is defined as a scholarly edition of a text that compiles variant readings. "
        + "Where most writing apps resemble an improved typewriter, Variorum allows for a new way of "
        + "organizing information by giving each text block a durable identity. The smooth viewing, "
        + "editing, and switching between versions of a block (\"takes\") seemed obviously useful for "
        + "drafting, but I soon found it was a more fundamental abstraction. Use takes to make a bilingual "
        + "book, an architecture document enriched with code snippets, and whatever else you can dream up. "
        + "Takes allow for fine-tuned control of what an AI can change by enabling a \"write new\" tier of "
        + "AI permissions. They maintain a structural moat between you and the AI \u{2014} its words are "
        + "not above and below yours, but beside them, intrinsically linked without bloating your "
        + "document. Sometimes the worst part of working with AI is being drowned out by an ocean of words "
        + "that are in English, but only technically. Variorum allows lengthy AI comments on a design "
        + "document to be tucked away and revealed at will.",

        // 7
        "Version control, purpose-built for writing, is the second guardrail. I took some of the best "
        + "parts of git, like commits and traceable lineage, and used block identity to sidestep the "
        + "line-based diffs that make git itself unsuitable for my work. The result is an app where each "
        + "version of each paragraph has its own complete history, saving a version preserves the full "
        + "note, and it is easy to compare a particular paragraph to what it used to be. The ease of "
        + "seeing what changed in the compare view makes it like reviewing a pull request of prose. "
        + "Variorum automatically commits before and after any AI changes on every take, allowing for easy "
        + "reversion. My favorite feature is that \u{2325}\u{2318}Z can always undo the latest AI change.",

        // 8
        "The final ingredient of the defining trinity is privacy. Each Variorum library is encrypted "
        + "locally and you can choose between Standard and Castle mode. Standard mode exists because I "
        + "wanted to be able to give this app to my mom without making it feel like opening a crypto "
        + "wallet every time \u{2014} it stores convenience copies of your library key, so Variorum opens "
        + "on your unlocked Mac. Castle mode exists because I'm disturbed by the fact that simply flying "
        + "to another country gives the government where I live the right to search all of my personal "
        + "devices, including forcing the use of biometrics. In Castle, Variorum doesn't open even on an "
        + "unlocked Mac without your passphrase or twelve words, with Touch ID optional. Conveniently, "
        + "being stored in ciphertext on disk prevents a rogue AI with filesystem access from reading your "
        + "work, unlike a folder of unencrypted markdown files.",

        // 9
        "Variorum is also built with the principle that AI should always be opt-in, rather than opt-out. "
        + "I hope that even those who don't want to use AI at all reach for Variorum for its capabilities "
        + "as a writing editor, with full confidence that their work is private not because of terms and "
        + "conditions but because of keys and encryptions. For those who do connect an MCP client, it "
        + "makes every access grant visual, clear, and easy to revoke. Unlike the obfuscated reality of "
        + "the command line, where you can't easily tell if you've allowed an AI agent into a particular "
        + "folder and it's hard to know what a motivated agent could access, Variorum shows an icon on "
        + "every item that has been shared with AI. You can also make notes and books private, which "
        + "supersedes any general access grant and conceals their existence. Work with confidence knowing "
        + "that AI access is visible always, impossible when not granted, and absent entirely when it is "
        + "unwanted.",

        // 10
        "There are some other elements of Variorum that I hope will bring delight. I've always thought "
        + "that notes apps should allow for book views to be composed from different notes at will, so I "
        + "built that. With Variorum, the days where each note is its own file and there's no way to read "
        + "through them together have ended. Build books and gatherings by hand, by tag inclusion, by tag "
        + "exclusion, or by whatever combination pleases you. The full-text search is fast: its cost "
        + "scales with the number of matches, not the size of your library. Notes still edit smoothly at "
        + "more than 10k words, while books can have more than a hundred thousand words without "
        + "stuttering. Test it out by restoring \"The Adventures of Sherlock Holmes\" under the Help menu "
        + "and scrolling through. Paragraphs you delete automatically move whole into the trash, so you "
        + "can easily see what you got rid of. I love keyboard shortcuts, so almost everything has one. "
        + "I'm grateful that an amazing writing editor was my first goal and that I achieved it before "
        + "connecting it to AI because of the focus on quality it gave me.",

        // 11
        "I made Variorum 100% free to use locally because I don't believe in renting possession of your "
        + "own writing and because I wanted to give something back to the world. I really mean that you "
        + "own your work \u{2014} it is locally stored in an open format and you can easily AirDrop your "
        + "library to another computer if you'd like to. When I release the mobile version there will be a "
        + "paid sync option only because syncing is itself an ongoing cost. I'm deeply grateful to the "
        + "open source coding community \u{2014} Variorum only came into existence by standing on the "
        + "shoulders of giants. I'm also grateful to the fanfiction community for having brought me so "
        + "much joy and entertainment over the years. At a time when it feels like the whole world has "
        + "been commoditized, people who share their creativity and passion freely online make the "
        + "internet somewhere I want to spend time. In that spirit, I want Variorum to not only be the "
        + "free option but the best one.",

        // 12
        "Being able to build and offer an app like Variorum \u{2014} opinionated, personal, and creative "
        + "\u{2014} is one of the best parts of living in our AI era. That a single individual could make "
        + "this app is also what lets me offer it for free. I'm a single human being, not a corporation, "
        + "and my expenses are the same as everyone's: shelter, food, and fun. I can support myself and "
        + "all of my agents with my job \u{2014} frontier AI isn't cheap, but it is still a fraction of "
        + "what it would've cost to hire software developers to build this app. Equally, knowing myself, I "
        + "would not have taken the years that it would've required before AI to build this native macOS "
        + "app in my spare time. I can't measure the productivity gain in a percentage because the app "
        + "simply wouldn't have existed. In only four months, I'm amazed at how far this app has come, and "
        + "it's been fun to make. That's what working with AI is like in 2026 \u{2014} if you can dream it "
        + "and you know what you're doing, you can build it.",

        // 13
        "\"If you know what you're doing\" is carrying a lot of weight in the previous paragraph, but I "
        + "passionately believe that AI doesn't have to be synonymous with slop and low-effort projects. "
        + "Variorum is an ambitious effort that feels like a real accomplishment for both me and AI "
        + "\u{2014} it's amazing what a single developer and a stochastic parrot can accomplish together. "
        + "I want to work towards a version of the future where instead of AI replacing people, people are "
        + "accomplishing more with AI.",

        // 14
        "As I developed this app I found that it was an immensely joyful experience to not just build "
        + "but invent, to see something new solve real problems of mine. Variorum has become a facet of my "
        + "daily life that encourages me to write, an editor that works with how I think. I can't put a "
        + "price on how I find myself journaling and writing more; I just know that life feels richer now. "
        + "On a more personal note, I lost my beloved dog Chai in June. Even when the sun had gone cold in "
        + "my life, focusing on building this app kept me excited for new days. Variorum is dedicated to "
        + "her, even though she couldn't read.",

        // 15
        "Now, finally releasing Variorum into the world, I can proudly say that what I consider the best "
        + "feature isn't a feature at all but instead the sense that there's a single person who really "
        + "cares behind the app's design, execution, and experience. I hope that you like it. I would love "
        + "to hear any of your thoughts, issues (yes, really, I want to fix them), and feature requests.",

        // 16
        "Thank you for trying Variorum,",

        // 17
        "Lillian",
    ]

    /// **Her moment: October 29, 2026, 4:44 am** (her words: *"maybe 4:44am
    /// on Oct 29th?"* … *"i agree on the date / time."*; R-105-3, "created
    /// 4:44, edited at birth"). The note's `created_at` — the day and time
    /// every created face reads (the Library's `created` stamp and sort, the
    /// masthead's created face — `Queries.noteStamps.createdAt`). READ IN
    /// THE SEEDING DEVICE'S LOCAL CALENDAR (PROVISIONAL, recorded): every
    /// reader sees 4:44 am on her own clock, whatever her zone — so the stored
    /// UTC instant differs by zone. Gregorian always, never `Calendar.current`
    /// (a device on another calendar would read year 2026 in its own era).
    nonisolated static let writtenAtLocal = DateComponents(
        year: 2026, month: 10, day: 29, hour: 4, minute: 44, second: 0)

    nonisolated static func writtenAt(in timeZone: TimeZone = .current) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        // The fallback (4:44 in UTC) is reachable only if the calendar
        // refused a date it has always made; it keeps her day.
        return calendar.date(from: writtenAtLocal) ?? Date(timeIntervalSince1970: 1_793_249_040)
    }

    enum BirthSeed: Equatable {
        case seeded(postID: String)
        case alreadyPresent
        case deletedByTheReader
        case refused(String)
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "birth-furniture")

    @discardableResult
    static func seedAtBirth(session: AppSession) async -> BirthSeed {
        let outcome = await performBirthSeed(session: session)
        log.notice(
            "readme at a fresh store's birth: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    /// The live readme — a live post wearing the reserved title, in any wing,
    /// archived or not (the smallest id when several stand). The birth seed
    /// and the door ask the same question.
    ///
    /// **A saved VERSION is never the readme** (ladder round 1, MINOR-1): a
    /// version keeps its note's title (V6) and is a live post, born archived
    /// and sealed, whose one home is Note ▸ Versions — so a title read alone
    /// counted her saved moment of the readme as "a live readme" (the door
    /// refused and opened the hidden moment). Each candidate is asked the
    /// Library's own question through the one core classifier
    /// (`Queries.isVersionOfAnyLiveNote`), never a hand-copied one. Candidates
    /// are the posts titled "readme" — a handful at most.
    nonisolated static func liveReadmeID(_ db: Database) throws -> String? {
        let candidates = try String.fetchAll(
            db,
            sql: """
                SELECT id FROM container
                WHERE kind = 'post' AND title = ? AND deleted_at IS NULL
                ORDER BY id
                """,
            arguments: [title])
        return try candidates.first { try !Queries.isVersionOfAnyLiveNote(db, $0) }
    }

    /// **The decision and the mint share ONE runner turn** (ladder round 1,
    /// MINOR-2 — the door's shape, `restore`). The reads used to run on
    /// `session.database.read` with the mint queued as a LATER turn: a Help ▸
    /// Restore “readme” press queued between the two (a first launch, the
    /// runner busy with the guide's seed turns) minted one readme and the
    /// birth's mint a second. Inside one serialized turn nothing can land
    /// between the reads and the mint.
    private static func performBirthSeed(session: AppSession) async -> BirthSeed {
        let writtenAt = Self.writtenAt()
        do {
            return try await session.runner.run { _ -> BirthSeed in
                @Dependency(\.database) var database
                let (liveID, tombstoned) = try database.read { db in
                    (try liveReadmeID(db),
                     try Bool.fetchOne(
                        db,
                        sql: """
                            SELECT EXISTS (SELECT 1 FROM container
                                           WHERE kind = 'post' AND title = ?
                                             AND deleted_at IS NOT NULL)
                            """,
                        arguments: [title]) ?? false)
                }
                if liveID != nil { return .alreadyPresent }
                // The birth road honours her deletion quietly (the
                // `pending`-resume window); the DOOR does not — a press is her
                // word (`restore`).
                if tombstoned { return .deletedByTheReader }
                return .seeded(postID: try mint(ops: Operations(undoStack: nil), writtenAt: writtenAt))
            }
        } catch {
            return .refused(String(describing: error))
        }
    }

    /// **THE ONE MINT** (VX-105 — R-105-8: "ONE shared mint body between
    /// seedAtBirth and the door"): the readme's exact seed shape, run INSIDE a
    /// serialized runner turn on the QUIET facade (nothing on her ⌥⌘Z — the
    /// caller passes `Operations(undoStack: nil)`).
    ///
    /// R-105-3, "created 4:44, edited at birth" — the split stamp, through
    /// operations alone (no row is ever re-stamped): the NOTE is created at her
    /// moment, under the operations layer's own time seam (the Sherlock/Prince
    /// fixed-clock precedent, scoped to this one mint); its words are then set
    /// down on the AMBIENT clock — one block per paragraph, in order, each
    /// stored exactly as given (`newBlock` keeps every byte but U+0000), whose
    /// touch and churn stamp `last_touched_at`, `last_major_revision_at` and
    /// `updated_at`, so a readme seeded LAST tops the Library's edited-newest
    /// sort (R-13s-29). Born STARRED (her ruling: "yeah make it born starred"),
    /// through the ONE star write, in the same act: starring a note is an
    /// applying act, and the seeded starred-notes GATHERING assembles it at read
    /// (a gathering holds nothing — the readme stays bookless). Home wing,
    /// untagged, undated.
    nonisolated static func mint(ops: Operations, writtenAt: Date) throws -> String {
        let note = try withDependencies {
            $0.date = .constant(writtenAt)
        } operation: {
            try ops.createPost(title: title, wingId: "")
        }
        for text in paragraphs {
            _ = try ops.newBlock(in: note.id, text: text, at: .end, registeringUndo: false)
        }
        try ops.setStarred(.post(note.id), starred: true)
        return note.id
    }

    // MARK: - Help ▸ Restore “readme” (VX-105 — R-105-8)

    /// What the door did.
    enum DoorOutcome: Equatable, Sendable {
        /// Minted fresh — the exact seed shape (`mint`).
        case restored(postID: String)
        /// A live readme already stands; nothing was minted.
        case alreadyPresent(postID: String)
    }

    /// **The door's brain** (R-105-8, her words: *"just tell the readme session
    /// to add a 'restore readme' door. why not just do that and match
    /// everything else"*). The seeded-book doors' rule: a LIVE readme (any
    /// wing, archived included — `liveReadmeID`) means the door has nothing
    /// to do; otherwise it MINTS the exact seed shape, and a TOMBSTONE is
    /// IGNORED — a deliberate press is her word ("a deleted chapter comes back
    /// fresh"), unlike the birth road's quiet deletion-respect. Its Trash copy
    /// stays where it is (PROVISIONAL P-105-7). The read and the mint share ONE
    /// runner turn, so two quick presses can never mint two.
    static func restore(session: AppSession) async throws -> DoorOutcome {
        let writtenAt = Self.writtenAt()
        return try await session.runner.run { _ -> DoorOutcome in
            @Dependency(\.database) var database
            if let live = try database.read({ db in try liveReadmeID(db) }) {
                return .alreadyPresent(postID: live)
            }
            return .restored(postID: try mint(ops: Operations(undoStack: nil), writtenAt: writtenAt))
        }
    }
}

/// **The readme door's words** (VX-105 — R-105-8; the seeded-book doors'
/// voice, without their dashes — PROVISIONAL wording, P-105-6). A mint is a
/// receipt; a door that did nothing is a refusal (the status seam's rule).
nonisolated enum ReadmeDoorCopy {
    static func restored(title: String = ReadmeSeeder.title) -> String {
        "Restored \u{201C}\(title)\u{201D} to your Library."
    }

    static func alreadyPresent(title: String = ReadmeSeeder.title) -> String {
        "You already have \u{201C}\(title)\u{201D}, so nothing was restored."
    }

    static func failed(_ line: String, title: String = ReadmeSeeder.title) -> String {
        "Restoring \u{201C}\(title)\u{201D} failed: " + line
    }
}

/// **The Snippets example scrap** (R-13s-5/26 — Q17's disposition; the
/// shape is the implementer's call, logged PROVISIONAL in the U1b record).
@MainActor
enum ExampleSnippetSeeder {
    /// The group's reserved title — the fold's identity (lowercase, the
    /// seed's casing style). A snippet always lives in a group
    /// (`container.kind='pool'`), so the example scrap gets its own small
    /// one; seeded BEFORE the guide's "tutorial scraps", it is the oldest
    /// group and therefore the Snippets rail's first.
    nonisolated static let groupTitle = "example snippets"
    /// Her ruled text, EXACTLY (R-13s-26): the standard disclaimer line.
    nonisolated static let snippetText =
        "Any resemblance to actual persons, living or dead, is purely coincidental."

    /// The furniture fold's identity for the example group (piece 5): the
    /// pool grain, the "tutorial scraps" precedent exactly.
    nonisolated static var furnitureFact: SeededFurnitureDedupeFacts.ReservedContainer {
        .init(title: groupTitle, kind: "pool")
    }

    enum BirthSeed: Equatable {
        case seeded(poolID: String)
        case alreadyPresent
        case deletedByTheReader
        case refused(String)
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "birth-furniture")

    @discardableResult
    static func seedAtBirth(session: AppSession) async -> BirthSeed {
        let outcome = await perform(session: session)
        log.notice(
            "example snippet at a fresh store's birth: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(session: AppSession) async -> BirthSeed {
        do {
            let (liveID, tombstoned) = try await session.database.read { db in
                (try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM container
                        WHERE kind = 'pool' AND title = ? AND deleted_at IS NULL
                        ORDER BY id LIMIT 1
                        """,
                    arguments: [groupTitle]),
                 try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS (SELECT 1 FROM container
                                       WHERE kind = 'pool' AND title = ?
                                         AND deleted_at IS NOT NULL)
                        """,
                    arguments: [groupTitle]) ?? false)
            }
            if liveID != nil { return .alreadyPresent }
            if tombstoned { return .deletedByTheReader }
            let poolID = try await session.runner.run { _ -> String in
                let ops = Operations(undoStack: nil)
                let pool = try ops.createPool(title: groupTitle)
                _ = try ops.newBlock(in: pool.id, text: snippetText, at: .end)
                return pool.id
            }
            return .seeded(poolID: poolID)
        } catch {
            return .refused(String(describing: error))
        }
    }
}
