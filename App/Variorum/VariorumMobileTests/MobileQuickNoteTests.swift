//
//  MobileQuickNoteTests.swift
//  VariorumMobileTests
//
//  Mobile Round 2, batch 3b — the home-screen quick note (M5, her ruling
//  R5). The architect's A5-1…A5-8 are the spec; the pins below are named
//  for the sentence each one protects.
//
//  **What the KILL pins prove, exactly.** Her requirement is *"if the user
//  just closes the app, their note should still be saved!"* — so the
//  load-bearing pins drive the app's REAL background routine
//  (`performBackgroundFlush`, and above it `mobileScenePhaseChanged`,
//  which is the function the scene's `.onChange` calls) and then read the
//  STORE, not the model. What they cannot reach is the platform half: that
//  iOS really delivers `.background` before a swipe-kill, and that the
//  `beginBackgroundTask` grant buys enough wall clock on real hardware.
//  Those are device facts and are recorded as such in the batch report.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile quick note — the home-screen box (round 2, M5)")
struct MobileQuickNoteTests {

    // MARK: - Harness

    /// A box whose two clocks are OFF: the mint clock never fires on its
    /// own (tests mint explicitly, or through a leaving), and the autosave
    /// debounce never fires (tests flush explicitly). Exactly the state a
    /// finger is in mid-typing.
    private func quietBox(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in throw CancellationError() }
        model.autosaveSleep = { _ in throw CancellationError() }
        return model
    }

    /// A box whose MINT CLOCK fires immediately (the "~1 s later" arm,
    /// without the second).
    private func tickingBox(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in }
        model.autosaveSleep = { _ in throw CancellationError() }
        return model
    }

    private func settle(
        _ condition: () -> Bool, _ label: Comment, limit: Int = 2000
    ) async {
        for _ in 0..<limit where !condition() {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
        #expect(condition(), label)
    }

    private func livePosts(_ db: AppDatabase) async throws -> [String] {
        try await db.read { db in
            try String.fetchAll(
                db, sql: "SELECT id FROM container WHERE deleted_at IS NULL ORDER BY created_at")
        }
    }

    // MARK: - THE KILL TESTS (her sentence, pinned)

    /// **THE ONE THAT MATTERS.** She has typed into the box and the mint
    /// clock has NOT fired — the text lives in the box and nowhere else,
    /// which is the only window in which anything could be lost. The app
    /// goes to the background. The store must hold her words.
    ///
    /// Red-on-old: delete `await quickNote?.fileOnLeaving()` from
    /// `performBackgroundFlush` and this fails with zero posts.
    @Test func theSubMintWindowSurvivesTheAppClosing() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "the thought I had on the bus"
            #expect(box.postID == nil, "the mint clock has not fired — nothing exists yet")
            let before = try await livePosts(db)
            #expect(before.isEmpty)

            await performBackgroundFlush(
                editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: .none)

            let posts = try await livePosts(db)
            #expect(posts.count == 1, "backgrounding minted the note she was typing")
            let stored = try await storedBlockTexts(db, postID: posts[0])
            #expect(stored == ["the thought I had on the bus"],
                    "every character she typed reached SQLite")
            #expect(box.text.isEmpty, "A5-8: leaving mints AND clears")
        }
    }

    /// The other half of the window: the note exists, and the keystrokes
    /// AFTER the mint are sitting in the autosave debounce. Backgrounding
    /// must land those too.
    ///
    /// Red-on-old: delete the `await session.flushEveryOpenPost()` line
    /// from `MobileQuickNoteModel.file()` and the store keeps only the
    /// minted snapshot.
    @Test func typingAfterTheMintSurvivesTheAppClosing() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "milk"
            let postID = try #require(await box.mintNow())
            box.text = "milk, eggs, and the thing I keep forgetting"
            #expect(try await storedBlockTexts(db, postID: postID) == ["milk"],
                    "the debounce is holding the rest — this is the state a kill finds")

            await performBackgroundFlush(
                editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: .none)

            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["milk, eggs, and the thing I keep forgetting"])
        }
    }

    /// **A5-4's grant.** The survey found NOTHING in this app had ever
    /// called `beginBackgroundTask`, so the `.background` flush was a bare
    /// `Task` racing suspension. The grant must be taken AND ended — an
    /// unbalanced grant is a watchdog kill, which is worse than the bug it
    /// fixes.
    ///
    /// Red-on-old: remove the `grant.begin` / `defer { grant.end }` pair
    /// from `performBackgroundFlush`.
    @Test func theBackgroundFlushTakesAnIOSGrantAndEndsIt() async throws {
        try await withEditorWorld { session, _ in
            let taken = LockIsolated<[String]>([])
            let ended = LockIsolated(0)
            let grant = BackgroundTaskGrant(
                begin: { name in
                    taken.withValue { $0.append(name) }
                    return UIBackgroundTaskIdentifier(rawValue: 7)
                },
                end: { _ in ended.withValue { $0 += 1 } })
            let box = quietBox(session)
            box.text = "covered"

            await performBackgroundFlush(
                editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: grant)

            #expect(taken.value.count == 1, "the flush asks iOS for time")
            #expect(ended.value == 1, "and gives it back — never a watchdog kill")
        }
    }

    /// The ROUTING, not only the routine: the function the scene's
    /// `.onChange(of: scenePhase)` calls must send `.background` to the
    /// flush. (This round's own lesson — a pin over a configured property
    /// proves nothing about what runs.)
    @Test func theScenePhaseHandlerRoutesBackgroundToTheFlush() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "routed"

            #expect(mobileScenePhaseChanged(
                .inactive, editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: .none) == nil,
                    "a switcher peek is not a leaving")
            let untouched = try await livePosts(db)
            #expect(untouched.isEmpty)

            let work = try #require(mobileScenePhaseChanged(
                .background, editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: .none))
            await work.value

            let posts = try await livePosts(db)
            #expect(posts.count == 1)
            #expect(try await storedBlockTexts(db, postID: posts[0]) == ["routed"])
        }
    }

    // MARK: - The mint (A5-2, A5-3)

    /// A5-3: whitespace alone never arms anything (`importPost` refuses it
    /// anyway — the box must never fire into that refusal), and the first
    /// NON-WHITESPACE character starts the clock that mints on its own.
    @Test func whitespaceAloneNeverMintsAndTheFirstRealCharacterArmsTheClock() async throws {
        try await withEditorWorld { session, db in
            let box = tickingBox(session)
            box.text = "   "
            #expect(box.saveState == .idle, "nothing to be honest about yet")
            await settle({ true }, "let any stray clock run")
            var posts = try await livePosts(db)
            #expect(posts.isEmpty, "whitespace is not a note")

            box.text = "   a"
            await settle({ box.postID != nil }, "the clock mints without her doing anything")
            posts = try await livePosts(db)
            #expect(posts.count == 1)
            #expect(box.saveState == .saved)
        }
    }

    /// A5-2: the mint is `importPost` (not `newBlock`), it produces ONE
    /// block for ordinary typing, and its undo entry says what she did.
    @Test func typedTextMintsExactlyOneBlockThroughImportPost() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "one paragraph, no returns, because ⏎ opens the note"
            let postID = try #require(await box.mintNow())

            #expect(try await storedBlockTexts(db, postID: postID).count == 1)
            #expect(session.undoStack.topLabel == "Quick Note",
                    "the undo entry says what she did, not \"Undo Import\"")
            let membership = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM reading_post
                    WHERE post_id = ? AND deleted_at IS NULL
                    """, arguments: [postID])
            }
            #expect(membership == 0,
                    "BOOKLESS — the Mac bar's grammar (the Pool lists what no book holds)")
        }
    }

    /// A5-2's stated benefit: a PASTE that arrives before the mint
    /// segments correctly for free, and the box then owns the LAST block —
    /// so continued typing grows that block and never touches the ones
    /// ahead of it.
    @Test func aPreMintPasteSegmentsAndTheBoxThenOwnsTheLastBlock() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "First paragraph.\n\nSecond paragraph."
            let postID = try #require(await box.mintNow())
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["First paragraph.\n", "Second paragraph."],
                    "bulk entry segments on entry (AppSpec §7)")

            box.text = "First paragraph.\n\nSecond paragraph. And more."
            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["First paragraph.\n", "Second paragraph. And more."],
                    "the box owns the LAST block; the ones ahead of it are untouched")
        }
    }

    /// The box holds at the boundary of paragraphs that are already real
    /// blocks of a real note: deleting those is a structural operation, and
    /// a capture box does not perform structural operations. Only reachable
    /// after a multi-paragraph paste was minted — the ordinary capture's
    /// frozen prefix is empty, which the second half asserts.
    @Test func theBoxHoldsAtTheBoundaryOfAlreadyMintedParagraphs() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "Kept.\n\nEditable."
            let postID = try #require(await box.mintNow())
            #expect(box.frozenPrefix == "Kept.\n\n")

            box.text = "Kept."          // deleted back through the whole tail
            #expect(box.text == "Kept.\n\n", "the box holds at the boundary")
            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID) == ["Kept.\n", ""],
                    "and the STORE hears the emptied tail — the box and the note never diverge")

            let plain = quietBox(session)
            plain.text = "no paragraph breaks here"
            _ = await plain.mintNow()
            #expect(plain.frozenPrefix.isEmpty,
                    "the ordinary capture owns its whole text exactly")
        }
    }

    /// Keystrokes that land while the mint is in flight are not lost: the
    /// store holds the snapshot, the box holds more, and the difference
    /// goes to the coordinator the moment ownership is taken.
    @Test func keystrokesLandingDuringTheMintAreNotLost() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "start"
            let mint = Task { await box.mintNow() }
            // Get a keystroke in while the mint is off the main actor.
            await Task.yield()
            box.text = "start and then some"
            let postID = try #require(await mint.value)

            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID) == ["start and then some"])
        }
    }

    // MARK: - ⏎ and the door (A5-1)

    /// A5-1: ⏎ opens the note in the editor, which makes a typed newline
    /// impossible in the box. The newline never reaches the store, the box
    /// clears, and the shell is handed the note to open.
    ///
    /// Red-on-old: remove the `isTypedReturn` branch from
    /// `handleTextChange` and the newline lands in the note's text while
    /// nothing is handed off.
    @Test func returnOpensTheNoteAndNeverTypesANewline() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "a whole thought"
            box.text = "a whole thought\n"        // the return key

            await settle({ box.pendingOpen != nil }, "⏎ hands the note off")
            let postID = try #require(box.takePendingOpen())
            #expect(box.takePendingOpen() == nil, "the shell takes it exactly once")
            #expect(box.text.isEmpty, "one capture opens one note")
            #expect(try await storedBlockTexts(db, postID: postID) == ["a whole thought"],
                    "the newline never reached the store")
        }
    }

    /// The visible door her sentence also names (*"press a button to go
    /// into the particular note for it"*) does exactly what ⏎ does.
    @Test func theOpenDoorFilesTheNoteAndHandsItOff() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "opened by the button"
            box.open()

            await settle({ box.pendingOpen != nil }, "the door hands the note off")
            let postID = try #require(box.takePendingOpen())
            #expect(try await storedBlockTexts(db, postID: postID) == ["opened by the button"])
            #expect(box.saveState == .idle, "the box is empty again")
        }
    }

    /// The paste half of the same rule: newlines that arrive in BULK are
    /// content and must survive, or A5-2's whole benefit is deleted by
    /// A5-1's implementation.
    @Test func aBulkPasteKeepsItsNewlines() async throws {
        try await withEditorWorld { session, _ in
            #expect(MobileQuickNoteModel.isTypedReturn(from: "ab", to: "ab\n"))
            #expect(MobileQuickNoteModel.isTypedReturn(from: "ab", to: "a\nb"),
                    "a return typed with the cursor in the middle is still a return")
            #expect(!MobileQuickNoteModel.isTypedReturn(from: "", to: "one\n\ntwo"),
                    "a paste is not a return")
            #expect(!MobileQuickNoteModel.isTypedReturn(from: "ab", to: "abc"))

            let box = quietBox(session)
            box.text = "one\n\ntwo"
            #expect(box.text == "one\n\ntwo", "the paste is kept whole")
            #expect(box.pendingOpen == nil, "and it did not hand anything off")
        }
    }

    // MARK: - Leaving (A5-8) and the savepoint (A5-5)

    /// A5-8 + A5-5: a leaving mints, flushes, leaves ONE quiet savepoint
    /// (the shared `closeAutoCommit` road — a captured thought whose note
    /// no pane ever opened would otherwise carry no history at all), and
    /// returns the box empty.
    @Test func leavingMintsClearsAndLeavesASavepoint() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "filed on the way out"

            await box.fileOnLeaving()

            let posts = try await livePosts(db)
            #expect(posts.count == 1)
            #expect(try await storedBlockTexts(db, postID: posts[0]) == ["filed on the way out"])
            let commits = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM commit_point cp
                    JOIN variant v ON v.id = cp.variant_id
                    JOIN container_block cb ON cb.block_id = v.block_id
                    WHERE cb.container_id = ? AND cp.kind = 'auto'
                    """, arguments: [posts[0]])
            }
            #expect(commits == 1, "one quiet savepoint per leaving (the cadence default)")
            #expect(box.text.isEmpty)
            #expect(box.postID == nil, "the box owns nothing once it has let go")
            #expect(box.saveState == .idle)
        }
    }

    /// A leaving with an empty box costs nothing and mints nothing — the
    /// hook fires on every tab switch and every push, so it has to be free.
    @Test func leavingAnEmptyBoxMintsNothing() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            await box.fileOnLeaving()
            box.text = "   \n  "
            await box.fileOnLeaving()
            let posts = try await livePosts(db)
            #expect(posts.isEmpty)
            #expect(box.handOffCount == 0, "nothing was handed off, so nothing announces one")
        }
    }

    /// Found by driving the real surface: a tab switch files the box, but
    /// the field stays first responder on a shelf that is now behind the
    /// Library — so the keyboard hung over a box nobody could see. The box
    /// announces every hand-off and the face drops the keyboard on it.
    /// Deleting back to an empty box is NOT a hand-off (dropping the
    /// keyboard mid-typing would be worse than the bug), which the second
    /// half asserts.
    ///
    /// Red-on-old: remove the `handOffCount += 1` and the announcement
    /// never arrives.
    @Test func everyHandOffIsAnnouncedButAnEmptiedBoxIsNot() async throws {
        try await withEditorWorld { session, _ in
            let box = quietBox(session)
            box.text = "a"
            box.text = ""
            #expect(box.saveState == .idle)
            #expect(box.handOffCount == 0, "she is still typing — the keyboard stays")

            box.text = "filed"
            await box.fileOnLeaving()
            #expect(box.handOffCount == 1)
            box.text = "filed again"
            await box.fileOnLeaving()
            #expect(box.handOffCount == 2)
        }
    }

    // MARK: - The indicator (A5-7)

    /// A5-7: three states, present from the first non-whitespace
    /// character, spoken for VoiceOver, and never a word about sync — this
    /// indicator can honestly claim only "on this iPhone", because offline
    /// is the phone's normal and the sync row owns that fact.
    @Test func theIndicatorIsHonestFromTheFirstCharacterAndNeverMentionsSync() async throws {
        try await withEditorWorld { session, db in
            #expect(MobileQuickNoteCopy.indicator(.idle) == nil,
                    "nothing renders before there is something to be honest about")
            #expect(MobileQuickNoteCopy.spokenIndicator(.idle) == nil)
            for state in [MobileQuickNoteModel.SaveState.typing, .saving, .saved] {
                let face = try #require(MobileQuickNoteCopy.indicator(state))
                let spoken = try #require(MobileQuickNoteCopy.spokenIndicator(state))
                #expect(!face.isEmpty)
                #expect(!spoken.isEmpty, "a custom indicator has no spoken form without one")
                for word in ["sync", "synced", "cloud", "backed up"] {
                    #expect(!face.lowercased().contains(word))
                    #expect(!spoken.lowercased().contains(word))
                }
            }
            #expect(MobileQuickNoteCopy.spokenIndicator(.saved) == "Saved on this iPhone.",
                    "the honest scope, spoken")

            let box = quietBox(session)
            #expect(box.saveState == .idle)
            box.text = "t"
            #expect(box.saveState == .typing, "typed, not durable, nothing in flight")
            let postID = try #require(await box.mintNow())
            #expect(box.saveState == .saved, "…and now it is in SQLite on this phone")
            box.text = "tt"
            #expect(box.saveState == .saving, "a write is scheduled")
            await session.flushEveryOpenPost()
            #expect(box.saveState == .saved)
            #expect(try await storedBlockTexts(db, postID: postID) == ["tt"])
        }
    }

    /// The survey's honesty trap, pinned: a refused autosave puts its entry
    /// BACK into `pending`, so the indicator must read the same source
    /// `isDirty` reads and stay un-saved rather than settle optimistically
    /// on "we called flush".
    @Test func aRefusedSaveNeverReadsAsSaved() async throws {
        try await withEditorWorld { session, _ in
            let box = quietBox(session)
            box.text = "before the seal"
            let postID = try #require(await box.mintNow())
            #expect(box.saveState == .saved)

            // The seal refuses everything under the post (AppSpec §9).
            try await session.runner.run { ops in try ops.lockPost(postID) }
            box.text = "after the seal"
            await session.flushEveryOpenPost()

            #expect(box.saveState == .typing, "a refusal never reads as saved")
            #expect(box.lastError != nil, "and it says so")
        }
    }

    // MARK: - The pure brains

    /// Churn is characters removed + characters inserted, equal weight
    /// (AppSpec §10). A plain field reports no ranges, so the cost is
    /// recovered from the common prefix/suffix — which a length diff alone
    /// gets wrong for an autocorrect replacement.
    @Test func charDeltaCountsBothSidesOfAReplacement() {
        #expect(MobileQuickNoteModel.charDelta(from: "", to: "abc") == 3)
        #expect(MobileQuickNoteModel.charDelta(from: "abc", to: "") == 3)
        #expect(MobileQuickNoteModel.charDelta(from: "abc", to: "abcd") == 1)
        #expect(MobileQuickNoteModel.charDelta(from: "abcd", to: "abc") == 1)
        #expect(MobileQuickNoteModel.charDelta(from: "abc", to: "abc") == 0)
        #expect(MobileQuickNoteModel.charDelta(from: "teh cat", to: "the cat") == 4,
                "an autocorrect swap costs both sides, never zero")
    }

    /// The anchor rule: nothing is frozen for a single-block mint (the
    /// ordinary capture owns its whole text), and a multi-block mint
    /// freezes exactly what sits ahead of the block the box owns.
    @Test func theFrozenPrefixIsEmptyForTheOrdinaryCaptureAndAnchorsOtherwise() {
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "just this", ownedText: "just this", blockCount: 1).isEmpty)
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "one\n\ntwo", ownedText: "two", blockCount: 2) == "one\n\n")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "a\nb\na", ownedText: "a", blockCount: 3) == "a\nb\n",
                "the LAST occurrence anchors — a repeated piece must not rewind the box")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "one\n\ntwo", ownedText: "", blockCount: 2).isEmpty,
                "an unnameable anchor freezes nothing rather than guessing")
    }

    /// `mints` mirrors `importPost`'s own `emptyImport` refusal, so the box
    /// can never fire into it (the door's grey reads the same predicate).
    @Test func theMintPredicateMirrorsTheOperationsRefusal() {
        #expect(!MobileQuickNoteModel.mints(""))
        #expect(!MobileQuickNoteModel.mints("   \n\t "))
        #expect(MobileQuickNoteModel.mints(" a "))
    }
}
