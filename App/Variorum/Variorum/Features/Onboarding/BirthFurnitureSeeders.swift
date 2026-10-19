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
//    · **The readme placeholder** (piece 2 — R-13s-39): her welcome note,
//      verbatim from `notes/plans/13s-start-here-reference.md` through the
//      second end-alternates marker, the alternates built as REAL takes,
//      her dictated closer as the final block; seeded LAST so it tops the
//      Library by recency (R-13s-29 with the letter absent). Her finished
//      text and the letter are VX-105's, post-merge.
//
//  Both follow `TutorialSeeder.seedAtBirth`'s grammar exactly: they run
//  ONLY on the Welcome arrangement's arrange-now road (a fresh store's
//  birth under the sync gate, or the `pending` resume of one — never an
//  existing store), on the QUIET facade (nothing on ⌥⌘Z), silently
//  (R-13r-11 — furniture never speaks; one log line each), and one read
//  decides: a live copy wins, then her deletion (a tombstoned container of
//  the reserved title — the `pending`-resume window is the only road a
//  deletion can precede this seed on), else the mint. No door latch: these
//  objects have no doors to race.
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
/// containers this unit seeded, so EVERY seeded object of the final set
/// folds on sign-in (R-13s-5's release constraint; the 17y B-DEDUPE rules
/// bind each grain).
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

/// **The readme placeholder** (R-13s-39 — her exact content ruling; the
/// order R-13s-29 with the letter absent). A standalone BOOKLESS note
/// titled "readme" (lowercase, her word — R-13s-27), seeded LAST of the
/// birth furniture so it tops the Library by recency. The content is her
/// reference's first half VERBATIM — everything from "Welcome to
/// Variorum!" through the SECOND "--- end alternates ---" ("Ok, enough fun
/// with takes" is the first excluded sentence) — with the alternates built
/// as REAL takes on their blocks (displayed text chosen), then her
/// dictated closer as the final block. NOTHING else; NO letter note
/// (VX-105 carries her finished text post-merge).
///
/// Block boundaries follow the reference's paragraph lines (the recorded
/// reading): five blocks — the welcome line · the take-icon paragraph
/// (takes: "You found it! :D" and the Open-Takes line) · the Write/Takes
/// line · the "This is the point…" paragraph (takes: the shortcuts
/// alternate and the style alternate) · her closer. Interior bytes are
/// byte-exact from the reference (curly quotes, the em dash, ":D"); each
/// paragraph's trailing whitespace is trimmed, which is also exactly what
/// `SegmentationRules.bulkSegments` does to every imported piece.
@MainActor
enum ReadmeSeeder {
    nonisolated static let title = "readme"

    /// The furniture fold's identity for the readme (13s-b U1b piece 5):
    /// a reserved-titled BOOKLESS note — two fresh devices' seeds fold at
    /// the container grain, content-identical and unengaged only (any tag,
    /// membership, savepoint or edit of hers keeps both — the standing
    /// B-DEDUPE rules). No seed-authored tag paths: a tag on the readme is
    /// always her hand.
    nonisolated static var furnitureFact: SeededFurnitureDedupeFacts.ReservedContainer {
        .init(title: title, kind: "post")
    }

    /// The blocks a fresh store's readme is born with: her five ALWAYS, then — only where the store opened on the
    /// NEW road — the four Start Here passages (VX-306 ladder round 2, m2: they speak the new road's truths — the key
    /// file and its copies, the twelve words shown when she asks, the new-words door in Settings ▸ Protection — which are
    /// false on TODAY's road, so Release and a Debug build pointed at the real store seed her five alone until the
    /// road switches, VX-329; the same rule every other VX-379 row follows).
    nonisolated static func paragraphs(onTheNewRoad newRoad: Bool) -> [String] {
        newRoad ? herBlocks + startHerePassages : herBlocks
    }

    /// The DEV store's seed in this build (the new road's in a Debug build, today's in Release) — what a launch over
    /// the dev store seeds (`LaunchFurniture`), read by the pins.
    nonisolated static var paragraphs: [String] {
        Self.paragraphs(onTheNewRoad: ProtectionRoad.opensOnTheNewRoad(devStore: true))
    }

    /// Her five blocks, in order (her reference's bytes) — seeded on every road.
    nonisolated static let herBlocks: [String] = [
        "Welcome to Variorum! I'm Lillian, the developer behind this app, and I'm excited "
        + "that you've downloaded it.",

        "I built Variorum with a simple goal: to be able to create multiple different "
        + "versions of a block of text. I call these versions takes, borrowing from the "
        + "film world. The icon to the right of this block is the take icon - click on it.",

        "While Write is meant to behave like a simple and elegant editor, Takes is where "
        + "complexity thrives. Click on \u{201C}expand all\u{201D} at the top of Takes.",

        "This is the point at which you might be thinking \"cool, but so what?\", unless "
        + "you're a writer that understands the pain of reworking a particular paragraph "
        + "to the point of madness. If that isn't you, some of the best use cases I've "
        + "found for it are in the takes of this paragraph.",

        "This book is a full guide to all the features of variorum and how to use them. "
        + "Move through the chapters, which are interactive guides, to discover them all.",
    ]

    /// VX-306 (2026-10-18, her kickoff word: the Start Here chapter drafted from `notes/CastleRules.md`, built as
    /// drafted, PROVISIONAL — P-VX306-W-1): the four passages of the plan's §7c (5), appended after her five blocks
    /// (untouched) — and ONLY on the new road (`paragraphs(onTheNewRoad:)`, ladder round 2 m2). VX-307 U2c (F-U2b-1):
    /// the second passage follows the amended rules 2, 3 and 7; all four are byte-pinned by `ReadmeStartHerePlanTests`
    /// to the VX-307 plan's U2c words block (the re-anchored source).
    nonisolated static let startHerePassages: [String] = [
        "Your work is encrypted. Every library is locked with its own random key, kept "
        + "in a small key file beside it. Variorum keeps copies of that key file for you "
        + "\u{2014} beside the library, inside every backup, and sealed in this Mac's "
        + "keychain \u{2014} so you never have to think about it.",

        // VX-307 U2c (F-U2b-1): the amended rules 2, 3 and 7 — the words shown only when she asks (the card above
        // the quick entry, the tour's end, Settings ▸ Protection), each look minting new ones, the key unchanged;
        // byte-pinned to the VX-307 plan's U2c words block (PROVISIONAL P-VX307-U2c-5).
        "Write down your twelve words. Every library has twelve words from the moment "
        + "it is made, and they open it for as long as they are its words. Variorum never "
        + "keeps them, so it shows them only when you ask \u{2014} from the card above the "
        + "quick entry, at the end of the tour, or any time in Settings \u{25B8} Protection "
        + "\u{2014} and each look makes new ones for you to write down. Your library's key "
        + "doesn't change.",

        "Set a passphrase. A passphrase is a convenience over the words: easier to type, "
        + "and either one can reset the other. Until you set one, Variorum reminds you "
        + "now and then.",

        "The Apple road is a convenience. In Standard, Variorum also keeps quiet roads to "
        + "your key \u{2014} through your iCloud Keychain and this Mac's login \u{2014} so "
        + "most people never type anything, and for most people that simply works "
        + "forever. If it ever stops, your passphrase or your words open the library, and "
        + "nothing was ever at risk. Castle is the one promise that there is no quiet road "
        + "through Apple, ever; it is a choice you can make in Settings.",
    ]

    /// The alternates, as REAL takes: block index → the take texts, in fan
    /// order after the displayed (chosen) original.
    nonisolated static let takes: [Int: [String]] = [
        1: ["You found it! :D",
            "Now click on Open Takes mode in the top bar of this modal"],
        3: ["This is where things get really fun! You can expand or collapse any take "
            + "block with the button to the right of it, or use the button at the top. "
            + "Navigation is fully supported by keyboard shortcuts\u{2014}you can also get "
            + "to Takes with Command 2. Check out all the shortcuts at Command /.",
            "There are four different ways to see your takes and work with them. Test "
            + "each of them out now by changing \u{201C}style\u{201D} at the top bar of "
            + "this note. While each is useful for something different, I\u{2019}m "
            + "particularly fond of margin grid for quick notes."],
    ]

    enum BirthSeed: Equatable {
        case seeded(postID: String)
        case alreadyPresent
        case deletedByTheReader
        case refused(String)
    }

    private static let log = Logger(
        subsystem: "io.lduarte.Variorum", category: "birth-furniture")

    /// `onTheNewRoad`: whether the store opened on the new road (`LaunchFurniture` passes the road's own rule for its
    /// store variant); the default is the dev store's road in this build (`paragraphs`) — the direct callers are pins.
    @discardableResult
    static func seedAtBirth(
        session: AppSession,
        onTheNewRoad: Bool = ProtectionRoad.opensOnTheNewRoad(devStore: true)
    ) async -> BirthSeed {
        let outcome = await perform(session: session, blocks: Self.paragraphs(onTheNewRoad: onTheNewRoad))
        log.notice(
            "readme at a fresh store's birth: \(String(describing: outcome), privacy: .public)")
        return outcome
    }

    private static func perform(session: AppSession, blocks: [String]) async -> BirthSeed {
        do {
            let (liveID, tombstoned) = try await session.database.read { db in
                (try String.fetchOne(
                    db,
                    sql: """
                        SELECT id FROM container
                        WHERE kind = 'post' AND title = ? AND deleted_at IS NULL
                        ORDER BY id LIMIT 1
                        """,
                    arguments: [title]),
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
            if tombstoned { return .deletedByTheReader }
            let postID = try await session.runner.run { _ -> String in
                let ops = Operations(undoStack: nil)
                @Dependency(\.database) var database
                let note = try ops.importPost(
                    title: title, text: blocks.joined(separator: "\n"),
                    undoLabel: "readme", segmentation: .paragraph, wingId: "")
                for (index, texts) in takes.sorted(by: { $0.key < $1.key }) {
                    guard note.blockIDs.indices.contains(index) else { continue }
                    let blockID = note.blockIDs[index]
                    guard let original = try database.read({ db in
                        try String.fetchOne(
                            db, sql: "SELECT default_variant_id FROM block WHERE id = ?",
                            arguments: [blockID])
                    }) else { continue }
                    // REVERSED on purpose (the window's first-run find):
                    // `branchVariant` seats a branch right AFTER its
                    // parent, so two branches of the one original land in
                    // reverse mint order — minting take 2 first leaves the
                    // stored fan [original, take 1, take 2], the
                    // reference's own faithful order (R-13s-39).
                    for text in texts.reversed() {
                        let minted = try ops.branchVariant(blockID, from: original)
                        try ops.autosave(minted.id, text: text, charDelta: text.count)
                    }
                }
                return note.container.id
            }
            return .seeded(postID: postID)
        } catch {
            return .refused(String(describing: error))
        }
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
