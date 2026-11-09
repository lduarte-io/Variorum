//
//  QuickNoteWingLandingTests.swift
//  VariorumTests (Mac)
//
//  VX-841 (the VX-915 run, batch 3 — her ask, 2026-11-04: *"in quicknote it
//  would be nice to optionally be able to select what wing your quicknote lands
//  in"*). The seat and face ruled at the batch's fork (PROVISIONAL P-915-B3-1,
//  the record `notes/plans/fixes/vx-915-recents-sweep.md`, BATCH 3): a quiet
//  landing word at the pad's header's trailing end — Home by default, drawn
//  only while a second wing exists — redirects ONE capture, which lands
//  BOOKLESS in that wing wearing the wing's own `quicknote` tag (the operation's
//  half is core-pinned in `QuicknoteWingTests`); the pick resets with a
//  successful filing, survives a refusal, rides the park, and a wing that has
//  died reads and files as Home.
//
//  An IMPROVEMENT (her ask): these pin the NEW contract — and THE FAST PATH
//  UNCHANGED: summon · type · ⏎ still files in Home's quicknotes with nothing
//  else pressed.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withLandingWorld<T>(
    seed: UInt64, _ body: @MainActor (AppSession, AppDatabase, Wing) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let work = try await session.runner.run { try $0.createWing(name: "Work") }
        return try await body(session, db, work)
    }
}

/// Where a filed note stands: its wing, its tags' wings by path, the books
/// that show it.
private struct Landing {
    let wing: String
    let tags: [String: String]
    let books: [String]
}

private func landing(_ db: AppDatabase, _ postID: String) async throws -> Landing {
    try await db.read { db in
        Landing(
            wing: try String.fetchOne(
                db, sql: "SELECT wing_id FROM container WHERE id = ?", arguments: [postID]) ?? "?",
            tags: Dictionary(uniqueKeysWithValues: try Queries.postTags(db, postID: postID)
                .map { ($0.path, $0.wingId) }),
            books: try Queries.readingsContaining(db, postID: postID).map(\.name))
    }
}

/// The Mac app's source tree (`App/Variorum/`), for the face's source pins.
private func appSource(_ relative: String) throws -> String {
    let root = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent().deletingLastPathComponent()
    return try String(contentsOf: root.appendingPathComponent(relative), encoding: .utf8)
}

@MainActor
@Suite("VX-841 — the quick note's landing word", .serialized)
struct QuickNoteWingLandingTests {
    /// THE FAST PATH UNCHANGED: with a second wing standing, a fresh pad aims at
    /// Home, and summon · type · ⏎ files exactly as before — Home's note, Home's
    /// tag, Home's quicknotes gathering, the same receipt.
    @Test func theFastPathStillLandsInHomesQuicknotes() async throws {
        try await withLandingWorld(seed: 841) { session, db, _ in
            let pad = QuickNotePad(session: session)
            #expect(pad.landingWingID == "", "a fresh pad aims at Home")
            pad.text = "A thought worth keeping."
            let postID = try #require(await pad.fileExplicitly().postID)
            let where_ = try await landing(db, postID)
            #expect(where_.wing == "")
            #expect(where_.tags == [Operations.quicknoteTagPath: ""])
            #expect(where_.books == [Operations.defaultQuicknoteBookName])
            #expect(session.status.spoken?.text == QuickNoteCopy.filedNote)
        }
    }

    /// THE REDIRECT: a capture aimed at W lands BOOKLESS in W, wearing W's own
    /// `quicknote` tag, no gathering showing it (so W's Pool lists it), and the
    /// receipt names W's Pool. The pick was that capture's: the pad is back on
    /// Home after the filing, and the next capture lands there.
    @Test func aPickedWingLandsTheCaptureBooklessThereAndThePickResets() async throws {
        try await withLandingWorld(seed: 842) { session, db, work in
            let pad = QuickNotePad(session: session)
            pad.landingWingID = work.id
            pad.text = "Away."
            let away = try #require(await pad.fileExplicitly().postID)
            let there = try await landing(db, away)
            #expect(there.wing == work.id)
            #expect(there.tags == [Operations.quicknoteTagPath: work.id], "W's own tag")
            #expect(there.books.isEmpty, "no gathering grows in W")
            let pool = try await db.read { try Queries.poolPosts($0, limit: 50, wingID: work.id).map(\.postID) }
            #expect(pool.contains(away))
            #expect(session.status.spoken?.text == QuickNoteCopy.filedInWing("Work", books: []))
            #expect(pad.landingWingID == "", "the pick was one capture's")

            pad.text = "Home again."
            let home = try #require(await pad.fileExplicitly().postID)
            #expect(try await landing(db, home).wing == "")
            #expect(try await landing(db, home).books == [Operations.defaultQuicknoteBookName])
        }
    }

    /// **VX-915 ladder round 1, F-1 (RED ON OLD — pinned before the fix):** the
    /// filing applies W's own `quicknote` tag through the one application road,
    /// so a living BOOK in W whose rule is that tag SEATS the capture (the core
    /// guard `QuicknoteWingTests.aLivingBookInThatWingHearsTheCapture`). The
    /// note is then a book member, not a Pool note — so the receipt must name
    /// the book, never "the Pool of “W”". ON THE OLD TREE: `fileAsQuicknote`
    /// answers `.taggedOnly` for every non-Home wing and the receipt's W arm
    /// spoke `filedInWing(W)` — "Filed in the Pool of “Work” — tagged
    /// #quicknote." — whatever seated it, so the last two expectations fail
    /// (the premise lines above them hold on both trees).
    @Test func aCaptureABookInThatWingSeatsNamesTheBookNotThePool() async throws {
        try await withLandingWorld(seed: 845) { session, db, work in
            let tag = try await session.runner.run {
                try $0.createTag(name: Operations.quicknoteTagPath, wingID: work.id)
            }
            _ = try await session.runner.run { ops in
                try ops.createReading(
                    name: "jots", kind: .book, querySpec: try RuleGrammar.encode(.tag(tag.id)),
                    wingId: work.id)
            }
            let pad = QuickNotePad(session: session)
            pad.landingWingID = work.id
            pad.text = "Seated."
            let postID = try #require(await pad.fileExplicitly().postID)
            let there = try await landing(db, postID)
            // The premise (green on both trees): it landed in W, wearing W's
            // tag, and W's book seated it.
            #expect(there.wing == work.id)
            #expect(there.tags == [Operations.quicknoteTagPath: work.id], "W's own tag, adopted")
            #expect(there.books == ["jots"], "the applying act seated it in W's book")
            // The receipt (RED ON OLD): it names the book, and never the Pool.
            let said = session.status.spoken?.text ?? ""
            #expect(!said.contains("Pool"), "a seated capture is no Pool note: \(said)")
            #expect(said.contains("\u{201C}jots\u{201D}"), "the receipt names the book that holds it: \(said)")
        }
    }

    /// A REFUSAL keeps her decision about where it lands (like her words and
    /// her name); a refused close PARKS the pick with the words, and the next
    /// summon restores both.
    @Test func aRefusalKeepsThePickAndTheParkCarriesItToTheNextSummon() async throws {
        try await withLandingWorld(seed: 843) { session, _, work in
            let pad = QuickNotePad(session: session)
            pad.mint = { _, _ in .refused("nope") }
            pad.landingWingID = work.id
            pad.text = "Kept words."
            #expect(await pad.fileExplicitly() == .refused("nope"))
            #expect(pad.landingWingID == work.id, "a refusal keeps the pick")
            #expect(await pad.close() == .refused("nope"))
            #expect(session.quickNotePark.held?.landingWingID == work.id, "the park carries it")

            let next = QuickNotePad(session: session)
            next.restoreParkedCapture()
            #expect(next.text == "Kept words.")
            #expect(next.landingWingID == work.id, "the next summon restores where it was aimed")
        }
    }

    /// A pick whose wing has died reads and files as Home (R-13ia-2 — a
    /// dangling wing is Home's), with Home's receipt.
    @Test func aPickWhoseWingDiedFilesInHome() async throws {
        try await withLandingWorld(seed: 844) { session, db, _ in
            let pad = QuickNotePad(session: session)
            pad.landingWingID = "a-wing-that-is-gone"
            pad.text = "Still kept."
            let postID = try #require(await pad.fileExplicitly().postID)
            let where_ = try await landing(db, postID)
            #expect(where_.wing == "")
            #expect(where_.books == [Operations.defaultQuicknoteBookName])
            #expect(session.status.spoken?.text == QuickNoteCopy.filedNote)
        }
    }

    /// The words (PROVISIONAL, her bundle) and the ink: Home's placeholder is
    /// byte-unchanged; the redirected lines name the wing; the word is quiet at
    /// Home and in the accent elsewhere — both from the token layer's roles.
    @Test func theWordsAndTheInk() {
        #expect(QuickNoteCopy.placeholder == "jot it down — it lands in \(Operations.defaultQuicknoteBookName)")
        #expect(QuickNoteCopy.placeholder(landingIn: "Work") == "jot it down — it lands in Work")
        #expect(QuickNoteCopy.filedInWing("Work", books: [])
                == "Filed in the Pool of \u{201C}Work\u{201D} \u{2014} tagged #quicknote.")
        // VX-915 ladder round 1, F-1: the landing named from the band's read
        // (`CaptureLanding.place` — one rule): no book is the wing's Pool
        // (byte-unchanged — the line above), a book is named, several are
        // counted, an unread landing says only that it filed (PROVISIONAL words,
        // her bundle). Ladder round 2, R2-4: `books:` has no default, so every
        // call says what it read (the old default-vs-empty line went with it).
        #expect(QuickNoteCopy.filedInWing("Work", books: ["jots"])
                == "Filed in \u{201C}jots\u{201D} \u{2014} tagged #quicknote.")
        #expect(QuickNoteCopy.filedInWing("Work", books: ["a", "b"]) == "Filed in 2 books \u{2014} tagged #quicknote.")
        #expect(QuickNoteCopy.filedInWing("Work", books: nil) == "Filed \u{2014} tagged #quicknote.")
        #expect(QuickNoteCopy.landingHelp.hasPrefix("Where this quick note lands"))
        #expect(QuickNoteCopy.landingAccessibility("Home") == "Quick note lands in Home")
        #expect(QuickNoteLandingFace.role(landing: "") == .quiet)
        #expect(QuickNoteLandingFace.role(landing: "w-1") == .primary)
    }

    /// The face, by source (a SwiftUI menu has no AppKit view to find): the
    /// word sits in the pad's header, drawn only while a second wing exists,
    /// is the chrome vocabulary's quiet menu, never a key-view stop, and hands
    /// the caret back on a pick; the pad still opens with the caret in the box
    /// (the fast path); the BANDS carry no landing word (VX-738 stands — their
    /// wing is the sidebar label's); and no registry act was added (the P-1
    /// call: the pick is a capture's option, not an act).
    @Test func theFaceSitsInThePadsHeaderAndTheBandsStayLabelFree() throws {
        let pad = try appSource("Variorum/Features/QuickNote/QuickNoteView.swift")
        #expect(pad.contains("if wings.rows.count > 1 { landingWord(tokens) }"),
                "drawn only while a second wing exists")
        let word = try #require(pad.range(of: "private func landingWord(_ tokens: VoiceTokens) -> some View {"))
        let body = String(pad[word.upperBound...].prefix(1_200))
        #expect(body.contains("VoicedMenu("), "the chrome vocabulary's quiet word with its ▾")
        #expect(body.contains("QuickNoteLandingFace.role(landing: landing)"))
        #expect(body.contains(".focusable(false)"), "never a key-view stop — the box keeps the keyboard")
        #expect(body.contains("focusRequest += 1"), "a pick hands the caret back to the words")
        #expect(pad.contains("@State private var focusRequest = 1"), "the pad still opens with the caret in the box")
        #expect(!pad.contains("surfaceCapabilities"), "no new registry door on the pad")

        let bar = try appSource("Variorum/Features/Shelf/QuickEntryBar.swift")
        #expect(!bar.contains("landingWingID") && !bar.contains("VoicedMenu("),
                "the bands carry no landing word (VX-738)")
    }
}
