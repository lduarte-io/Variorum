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

/// A main-actor box for the grant's expiration handler. `LockIsolated` is
/// the wrong tool for a closure that is deliberately main-actor-isolated.
@MainActor
private final class ExpirationHandlerBox {
    var installed: [@MainActor () -> Void] = []
}

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

    /// **The REAL text input behind SwiftUI's `TextField`** — found by
    /// walking the mounted hierarchy, never assumed from a class name. Every
    /// caller `#require`s it, so a pin that cannot reach the field it names
    /// fails loudly instead of passing over nothing (§0's green-over-nothing
    /// rule, which this round hit five times).
    private func textInput<C: View>(in surface: HostedSurface<C>) -> (UIView & UITextInput)? {
        func walk(_ view: UIView) -> (UIView & UITextInput)? {
            if let input = view as? (UIView & UITextInput) { return input }
            for sub in view.subviews {
                if let found = walk(sub) { return found }
            }
            return nil
        }
        return walk(surface.host.view)
    }

    /// The whole text a real field is holding, read through `UITextInput`.
    private func fieldText(_ field: UIView & UITextInput) -> String {
        guard let whole = field.textRange(
            from: field.beginningOfDocument, to: field.endOfDocument)
        else { return "" }
        return field.text(in: whole) ?? ""
    }

    /// Where the caret sits, as an offset from the start.
    private func caretOffset(_ field: UIView & UITextInput) -> Int? {
        guard let selection = field.selectedTextRange else { return nil }
        return field.offset(from: field.beginningOfDocument, to: selection.start)
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
    /// Red-on-old: delete BOTH `flushEveryOpenPost()` **and** the
    /// `savepointOnLeaving` call from `MobileQuickNoteModel.file()`.
    ///
    /// *(4.5a, Q5 — the recipe this comment used to state named the flush
    /// line ALONE, and it is false: `savepointOnLeaving` flushes the post's
    /// own coordinator first by design — `AppSession`'s flush-first rule,
    /// which exists precisely so a leaving's savepoint cannot capture stale
    /// text. Either line alone therefore still lands the keystrokes, so
    /// removing one would leave this pin green and prove nothing. A recipe
    /// nobody has run is a claim, not a pin.)*
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

    /// **A5-4's grant, taken the way Apple says to take it** (4.5a, Q4).
    ///
    /// Apple's own Discussion: *"Call this method as early as possible
    /// before starting your task… If you call this method shortly before
    /// your app is due to be suspended, there's a chance that the system
    /// might suspend your app before that task assertion is granted. For
    /// example, don't call this method at the very end of your
    /// `applicationDidEnterBackground(_:)` method and expect your app to
    /// continue running."*
    ///
    /// The shipped code took the grant INSIDE the `Task` the phase handler
    /// returns — asynchronously, one hop after the phase change. An
    /// ungranted assertion means this flush writes SQLite unprotected,
    /// which Apple documents as `0xdead10cc`: *"terminated the app because
    /// it held on to a file lock or SQLite database lock during
    /// suspension"* — naming this very API, called *"well before starting
    /// to write to the file"*, as the mitigation. Before this round there
    /// was no grant at all and iOS simply suspended us, so taking it late
    /// CREATED a termination class rather than closing one.
    ///
    /// **Red-on-old:** move `BackgroundAssertion(...)` back inside the
    /// returned `Task` — the first expectation fails, because the grant has
    /// not been taken by the time the handler returns.
    @Test func theGrantIsTakenSynchronouslyInsideThePhaseHandler() async throws {
        try await withEditorWorld { session, db in
            let taken = LockIsolated<[String]>([])
            let ended = LockIsolated(0)
            let grant = BackgroundTaskGrant(
                begin: { name, _ in
                    taken.withValue { $0.append(name) }
                    return UIBackgroundTaskIdentifier(rawValue: 7)
                },
                end: { _ in ended.withValue { $0 += 1 } })
            let box = quietBox(session)
            box.text = "covered"

            let work = try #require(mobileScenePhaseChanged(
                .background, editors: MobileLivenessAuthority(), sync: nil,
                quickNote: box, grant: grant))

            // THE ASSERTION IS ABOUT ORDER, and nothing has awaited yet:
            // the returned `Task` inherits this actor, so it cannot have
            // run a line. A grant taken inside it would read zero here.
            #expect(taken.value == ["Variorum flush before suspension"],
                    "the grant is taken in the phase-change handler itself")
            #expect(ended.value == 0, "and held for the whole flush")

            await work.value
            #expect(ended.value == 1,
                    "given back exactly once — an unbalanced grant is a watchdog kill")
            let posts = try await livePosts(db)
            #expect(posts.count == 1, "and the flush it protects still ran")
        }
    }

    /// **The expiration handler — the half that did not exist at all**
    /// (Q4). The shipped grant used the SINGLE-ARGUMENT
    /// `beginBackgroundTask(withName:)`. Apple: *"A handler to be called
    /// shortly before the app's remaining background time reaches 0…
    /// Failure to end the task explicitly will result in the termination of
    /// the app"* (documented code `0x2182bad2`, *"a background task failing
    /// to complete in time"*) — on a routine whose last leg is a network
    /// round.
    ///
    /// The handler STOPS the work and hands the time back; the two legs
    /// that protect her text have already run by then, and only the
    /// droppable ones read cancellation.
    ///
    /// **Red-on-old:** the old `begin` took no handler at all — there was
    /// nothing to capture and nothing to fire, so this pin cannot even be
    /// written against it.
    @Test func theGrantsExpirationHandlerStopsTheWorkAndGivesTheTimeBack() async throws {
        try await withEditorWorld { session, _ in
            let handlers = ExpirationHandlerBox()
            let ended = LockIsolated(0)
            let grant = BackgroundTaskGrant(
                begin: { _, handler in
                    handlers.installed.append(handler)
                    return UIBackgroundTaskIdentifier(rawValue: 9)
                },
                end: { _ in ended.withValue { $0 += 1 } })

            let work = try #require(mobileScenePhaseChanged(
                .background, editors: MobileLivenessAuthority(), sync: nil,
                quickNote: nil, grant: grant))
            let expire = try #require(handlers.installed.first,
                                      "an expiration handler is installed at begin time")

            expire()        // iOS: your time is nearly up.

            #expect(work.isCancelled, "the work stops rather than being killed inside")
            #expect(ended.value == 1, "the time is handed back immediately")
            await work.value
            #expect(ended.value == 1, "…and exactly once — end() is idempotent")
        }
    }

    /// **THE TEETH EXIST ON BOTH CONSTRUCTION ROADS** (4.5a fix round,
    /// MAJOR 4). `BackgroundAssertion.onExpire` was set only by
    /// `mobileScenePhaseChanged`; the self-minting road inside
    /// `performBackgroundFlush` — the one its own doc advertises as keeping
    /// *"every existing call site honest"* — left it nil forever. So on that
    /// road iOS saying *"time is up"* fired `expire()`, `onExpire` was a
    /// no-op, `end()` handed the token back, **and the flush carried on**:
    /// more savepoints, then a network round, under an assertion that had
    /// already been returned. That is the exact inverse of Apple's
    /// `0xdead10cc` guidance, and it is why `isGranted` gating the network
    /// leg could never have saved it — it read `true` after `end()` too.
    ///
    /// **Red-on-old:** delete `mine.onExpire = { work.cancel() }` (or
    /// restore the old `let held = assertion ?? BackgroundAssertion(...)`
    /// shape, which never set it) — both posts get savepointed and the
    /// first expectation fails at 2.
    @Test func theSelfMintedGrantHasTeethToo() async throws {
        try await withEditorWorld { session, _ in
            let a = try await makePost(session, blocks: ["A."])
            let b = try await makePost(session, blocks: ["B."])
            let (modelA, _) = await makeSurfaceEditor(session, postID: a)
            let (modelB, _) = await makeSurfaceEditor(session, postID: b)
            let editors = MobileLivenessAuthority()
            await editors.register(modelA, tab: .shelf)
            await editors.register(modelB, tab: .library)

            let handlers = ExpirationHandlerBox()
            let ended = LockIsolated(0)
            let grant = BackgroundTaskGrant(
                begin: { _, handler in
                    handlers.installed.append(handler)
                    return UIBackgroundTaskIdentifier(rawValue: 11)
                },
                end: { _ in ended.withValue { $0 += 1 } })

            let seen = LockIsolatedBox<[String]>([])
            // NO `holding:` — this is the self-minting road.
            await performBackgroundFlush(
                editors: editors, sync: nil,
                savepoint: { postID in
                    seen.value.append(postID)
                    // iOS, mid-flush: your time is nearly up.
                    if seen.value.count == 1 { handlers.installed.first?() }
                },
                grant: grant)

            #expect(seen.value.count == 1,
                    "the work STOPPED — it did not carry on under a returned assertion")
            #expect(ended.value == 1, "and the time was handed back exactly once")
        }
    }

    // MARK: - A leaving that FAILS (Q2 — the other BLOCKER)

    /// **THE SECOND BLOCKER, pinned.** `file()` reached `reset()` on every
    /// road, and `reset()` does `write("")` *and* `lastError = nil` — so a
    /// refused mint discarded her text and erased the reason for it in the
    /// same breath.
    ///
    /// The reachable input is the one this app's own scene handler names:
    /// *"If the device locks mid-round, file protection may cut the store
    /// off."* The MECHANISM is injected here (a trigger that refuses the
    /// insert); the STATE — the store refusing a write at a leaving — is
    /// the product's own, and the same road runs on an ordinary tab switch
    /// where the app is not going away at all.
    ///
    /// **Red-on-old:** restore the unconditional `reset()` — the box comes
    /// back empty with no error, and her sentence is gone.
    @Test func aRefusedMintAtALeavingKeepsHerTextAndItsReason() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "the thought I had on the bus"

            try await session.database.write { db in
                try db.execute(sql: """
                    CREATE TRIGGER quicknote_store_unavailable
                    BEFORE INSERT ON container
                    BEGIN SELECT RAISE(ABORT, 'the store is unavailable'); END
                    """)
            }
            await box.fileOnLeaving()

            #expect(try await livePosts(db).isEmpty, "nothing minted, as the refusal says")
            #expect(box.text == "the thought I had on the bus",
                    "her text is still in the box")
            #expect(box.lastError != nil, "and the reason is still on screen")
            #expect(box.lastError?.contains("still here") == true,
                    "…in her words, not the enum's (Q7)")
            #expect(box.saveState == .typing, "nothing reads as saved")
            #expect(box.handOffCount == 0, "and the box never announced a hand-off")

            // With the store back, the very same box files exactly as it
            // always did — nothing was lost by the refusal.
            try await session.database.write { db in
                try db.execute(sql: "DROP TRIGGER quicknote_store_unavailable")
            }
            await box.fileOnLeaving()

            let posts = try await livePosts(db)
            #expect(posts.count == 1)
            #expect(try await storedBlockTexts(db, postID: posts[0])
                    == ["the thought I had on the bus"])
            #expect(box.text.isEmpty)
            #expect(box.handOffCount == 1)
        }
    }

    /// Q2's other half, same class and the same one-line guard: the note
    /// exists, but the store REFUSED the keystrokes that followed the mint
    /// (the seal `aRefusedSaveNeverReadsAsSaved` uses). `flushNow` puts a
    /// refused entry BACK into `pending`, so those characters live only in
    /// this box — and the box must keep them.
    ///
    /// **Red-on-old:** drop the `autosave?.isDirty` guard from `file()` and
    /// the post-seal keystrokes are wiped along with the refusal.
    @Test func aLeavingWhoseKeystrokesWereRefusedKeepsThemToo() async throws {
        try await withEditorWorld { session, _ in
            let box = quietBox(session)
            box.text = "before the seal"
            let postID = try #require(await box.mintNow())
            try await session.runner.run { ops in try ops.lockPost(postID) }
            box.text = "before the seal, and after it"

            await box.fileOnLeaving()

            #expect(box.text == "before the seal, and after it",
                    "the refused keystrokes are still hers to see")
            #expect(box.lastError != nil)
            #expect(box.handOffCount == 0, "the box has not let go")
        }
    }

    /// **"TRY AGAIN IN A MOMENT" HAS TO BE TRUE** (4.5a fix round,
    /// MINOR 9). The refusal copy promises it and nothing kept the promise:
    /// `file()` cancels the mint clock on its way in, so text refused
    /// because the device locked mid-round sat in an in-memory box with
    /// **nothing scheduled to try again** — and a suspended app can be
    /// terminated. Only her next keystroke re-armed anything, and the whole
    /// point of the state is that she has stopped typing and left.
    ///
    /// The refusal is the product's own reachable one (this app's scene
    /// handler names it: file protection cutting the store off), injected
    /// here as a trigger that refuses the insert, then withdrawn — the way
    /// the device coming back unlocked withdraws it.
    ///
    /// **Red-on-old:** delete `armMintClock()` from `file()`'s refused-mint
    /// arm — nothing ever mints and the `#require` fails.
    @Test func aRefusedLeavingTriesAgainWithoutHerTypingAnotherCharacter() async throws {
        try await withEditorWorld { session, db in
            // A clock she controls: it holds until the store is back, so
            // the retry is deterministic rather than raced.
            let storeIsBack = LockIsolated(false)
            let box = MobileQuickNoteModel(session: session)
            box.autosaveSleep = { _ in throw CancellationError() }
            box.sleep = { _ in
                while !storeIsBack.value { try await Task.sleep(for: .milliseconds(1)) }
            }
            box.text = "the thought I had on the bus"

            try await session.database.write { db in
                try db.execute(sql: """
                    CREATE TRIGGER quicknote_store_unavailable
                    BEFORE INSERT ON container
                    BEGIN SELECT RAISE(ABORT, 'the store is unavailable'); END
                    """)
            }
            await box.fileOnLeaving()
            #expect(try await livePosts(db).isEmpty, "refused, as the copy says")
            #expect(box.lastError?.contains("try again in a moment") == true,
                    "…and this is the sentence that has to become true")

            // The device comes back. SHE TYPES NOTHING.
            try await session.database.write { db in
                try db.execute(sql: "DROP TRIGGER quicknote_store_unavailable")
            }
            storeIsBack.setValue(true)

            await settle({ box.postID != nil }, "the refused text minted itself on the retry")
            let posts = try await livePosts(db)
            #expect(posts.count == 1)
            // `#require`, never `posts[0]` — under the red-on-old revert this
            // array is EMPTY, and an index crash takes the whole runner down
            // with it (measured: the reverted pass died at `Index out of
            // range` and reported 25 of 33 tests). A pin has to fail; it must
            // not detonate.
            let minted = try #require(posts.first)
            #expect(try await storedBlockTexts(db, postID: minted)
                    == ["the thought I had on the bus"])
        }
    }

    // MARK: - The emptied box (Q3)

    /// **Q3.** She typed one character — which mints a real note — deleted
    /// it, and left. Nothing tombstoned the note, so a blank, date-titled
    /// row sat in her library permanently. A5-3 disclosed *"an abandoned
    /// one-word note"*; it never sanctioned a note with no content at all,
    /// which is exactly the case where she withdrew everything she typed.
    ///
    /// It goes the note's OWN way — `deleteContainer`, the door batch 4
    /// shipped — so it is in the Trash on the ordinary clock, never a
    /// second deletion rule.
    ///
    /// **Red-on-old:** remove `file()`'s emptied-box arm and a live,
    /// empty, untitled container survives the leaving.
    @Test func anEmptiedBoxLeavesNoBlankNoteBehind() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "a"
            let postID = try #require(await box.mintNow())
            #expect(try await livePosts(db) == [postID])

            box.text = ""                       // she withdrew all of it
            await box.fileOnLeaving()

            #expect(try await livePosts(db).isEmpty,
                    "no blank, date-titled note is left in her library")
            #expect(box.text.isEmpty)
            #expect(box.postID == nil, "the box owns nothing")
            let tombstoned = try await db.read { db in
                try Int.fetchOne(db, sql: """
                    SELECT COUNT(*) FROM container
                    WHERE id = ? AND deleted_at IS NOT NULL
                    """, arguments: [postID])
            }
            #expect(tombstoned == 1,
                    "moved to the Trash on the ordinary clock — the shared delete road")
        }
    }

    /// **A WITHDRAWAL IS STILL THE BOX LETTING GO** (4.5a fix round,
    /// MAJOR 3 — a regression Q3 introduced). At HEAD an emptied box still
    /// returned `minted`, so `handOffCount` bumped and the face dropped
    /// focus. Q3's new arm resets and returns `nil`, bumping nothing: type
    /// `a`, delete it, tap the Library tab — the note is withdrawn, the box
    /// resets, and **the keyboard sits over the Library**, on a shelf
    /// nobody can see. That is the exact bug `handOffCount`'s own comment
    /// says *"was found by driving the real surface"*.
    ///
    /// **Red-on-old:** drop the `handOffCount += 1` from `file()`'s
    /// emptied-box arm and the announcement never arrives.
    @Test func aWithdrawnNoteStillAnnouncesThatTheBoxLetGo() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "a"
            _ = try #require(await box.mintNow())
            box.text = ""
            #expect(box.handOffCount == 0, "still just typing — the keyboard stays")

            await box.fileOnLeaving()

            #expect(box.handOffCount == 1,
                    "the box let go, so it says so and the face drops the keyboard")
            #expect(try await livePosts(db).isEmpty, "…and the withdrawal still happened")
        }
    }

    /// **THE NOTE THE BOX NEVER OWNED IS NEVER WITHDRAWN** (4.5a fix round,
    /// MAJOR 1 — the inverse of the fix A1-19 had just made).
    ///
    /// `adopt` sets `postID` BEFORE the `frozenPrefix` guard, so A1-19's
    /// refusal arm exits with `postID` set, `variantID` nil, and a note
    /// holding several real paragraphs the box owns not one character of.
    /// The withdrawal's `postID != nil && !mints` gate then read that state
    /// as *"the blank note I just minted"* and tombstoned her prose.
    ///
    /// **This is COVERAGE, NOT A PIN, and deliberately so** (§0's fiction
    /// rule): the state is reachable only through A1-19's own unconstructible
    /// input — `SegmentationRules.bulkSegments` never mints a blank piece
    /// and always leaves the last segment findable in what was minted — so
    /// a behavioural red would have to be manufactured. What is asserted is
    /// the CONTRACT: ownership, not the mere existence of a note, is what
    /// authorises the withdrawal. The same call the architect ratified for
    /// A1-19 itself.
    @Test func theWithdrawalIsAuthorisedByOwnershipNotByThereBeingANote() async throws {
        try await withEditorWorld { session, db in
            // What ownership MEANS, at the two states the product reaches.
            let owned = quietBox(session)
            owned.text = "one paragraph"
            _ = try #require(await owned.mintNow())
            #expect(owned.variantID != nil && owned.frozenPrefix.isEmpty,
                    "the ordinary capture owns its whole note — the withdrawal's one legal state")

            let partial = quietBox(session)
            partial.text = "Kept.\n\nEditable."
            let partialID = try #require(await partial.mintNow())
            #expect(partial.variantID != nil && !partial.frozenPrefix.isEmpty,
                    "a multi-paragraph capture owns only its LAST block")
            // And the note it does not wholly own survives a leaving whole,
            // whatever the box is showing.
            await partial.fileOnLeaving()
            #expect(try await livePosts(db).contains(partialID))
            #expect(try await storedBlockTexts(db, postID: partialID)
                    == ["Kept.\n", "Editable."])
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
    /// a capture box does not perform structural operations.
    ///
    /// **The empty trailing block is the TRUTH here, not collateral** — and
    /// the distinction is the whole of Q1. This case really did empty the
    /// owned tail (she deleted every character of it), so the store hearing
    /// `""` is the box and the note agreeing. The BLOCKER's case is the
    /// opposite: nothing touched the tail, and the shipped code wrote `""`
    /// over prose she never deleted. `editingTheFirstParagraphNever
    /// DestroysTheSecond` above is that case, and the two expectations are
    /// deliberately different.
    ///
    /// The second half asserts the ordinary (single-block) capture's
    /// prefix is empty; the third that an emptied TAIL is not an emptied
    /// NOTE — Q3's delete must not reach a note that still has paragraphs.
    @Test func theBoxHoldsAtTheBoundaryOfAlreadyMintedParagraphs() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "Kept.\n\nEditable."
            let postID = try #require(await box.mintNow())
            #expect(box.frozenPrefix == "Kept.\n\n")

            box.text = "Kept."          // deleted back through the whole tail
            // The restore lands on the NEXT main-actor turn, and that is
            // the fix rather than a delay: a same-turn write never reaches
            // SwiftUI's field at all (`MobileQuickNoteModel.restore`).
            await settle({ box.text == "Kept.\n\n" }, "the box holds at the boundary")
            #expect(box.boundaryNote != nil, "and says where that edit lives")
            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID) == ["Kept.\n", ""],
                    "and the STORE hears the emptied tail — the box and the note never diverge")

            // Q3's fence: leaving with a box that still holds a paragraph
            // files a real note; only a WHOLLY emptied box is withdrawn.
            await box.fileOnLeaving()
            #expect(try await livePosts(db) == [postID],
                    "an emptied TAIL is not an emptied note")
            #expect(try await storedBlockTexts(db, postID: postID) == ["Kept.\n", ""])

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

    /// **⏎ OVER A SELECTION IS STILL ⏎** (4.5a, Q6). The shipped test was
    /// `new.count == old.count + 1`, so a return pressed with text selected
    /// — which replaces the selection with one newline and usually SHRINKS
    /// the text — was not recognised at all, and a literal newline landed
    /// in the box where A5-1 says one can never exist. From there it
    /// reached the mint and segmented the capture into blocks she never
    /// asked for.
    ///
    /// **Red-on-old:** restore the length-delta guard — the newline stays
    /// in the box, nothing is handed off, and the stored note splits.
    @Test func returnOverASelectionIsStillReturnAndNeverALiteralNewline() async throws {
        try await withEditorWorld { session, db in
            #expect(MobileQuickNoteModel.isTypedReturn(
                from: "one two three", to: "one \n three"),
                    "a selection replaced by ⏎ is a return, whatever the length delta")
            #expect(!MobileQuickNoteModel.isTypedReturn(from: "abc", to: "a\n\nc"),
                    "two newlines is a paste, not a keypress")

            let box = quietBox(session)
            box.text = "one two three"
            box.text = "one \n three"        // ⏎ with "two" selected

            await settle({ box.pendingOpen != nil }, "⏎ hands the note off")
            let postID = try #require(box.takePendingOpen())
            #expect(box.text.isEmpty, "one capture opens one note")
            #expect(try await storedBlockTexts(db, postID: postID) == ["one two three"],
                    "the newline never reached the store, and neither did a second block")
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

    /// **13l L-d — the box hands its coordinator back.** It took one per
    /// CAPTURE and the session had no way to let go, so a day of jotting
    /// left a coordinator per jot for `flushEveryOpenPost` to walk at every
    /// filing and every background flush. RED ON THE PRE-L-d TREE: the count
    /// climbs to three and stays there (there was no release path to call).
    @Test func eachCaptureHandsItsCoordinatorBack() async throws {
        try await withEditorWorld { session, db in
            for i in 0..<3 {
                let box = quietBox(session)
                box.text = "jot \(i)"
                await box.fileOnLeaving()
                #expect(box.postID == nil)
            }

            let minted = try await livePosts(db)
            #expect(minted.count == 3, "three real notes were minted")
            #expect(session.openAutosaveCount == 0,
                    "and the session is holding nothing for any of them")
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

    // MARK: - The REAL surface (Q9), and the faces it shows (Q8)

    /// **Nothing mounted this view** (Q9). Every pin above reads a model,
    /// and §0's rule is that a pin over a view model's number proves
    /// nothing about what renders — which is exactly how batch 4's dead
    /// confirm doors shipped. This one hosts `MobileQuickNoteBox` in a real
    /// key window, reads the real accessibility tree, and ACTIVATES the
    /// real door through UIKit's own dispatch.
    ///
    /// It also pins **Q8**: an emptied box used to render three
    /// contradictory faces at once — the *"just start typing"* placeholder,
    /// a `✓ saved` indicator, and an `open ↵` door which (since Q3) would
    /// withdraw the note rather than open it.
    ///
    /// **Red-on-old for Q8:** point the row back at `model.saveState` and
    /// the emptied box's `✓ saved` + open door reappear over the
    /// placeholder.
    @Test func theBoxMountsAndItsFacesGoWithTheText() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            let opened = LockIsolated<[String]>([])
            let surface = HostedSurface(MobileQuickNoteBox(
                model: box, tokens: VoiceTokens.terminalLight,
                onOpen: { id in opened.withValue { $0.append(id) } }))
            await surface.settle()

            // The tree is alive, and this is the POSITIVE assertion that
            // says so — an unarmed accessibility server fails here rather
            // than in one of the absences below (Act 1's MAJOR 4).
            #expect(surface.element(labeled: "Quick note") != nil,
                    "the real field is on screen")
            #expect(surface.element(labeled: MobileQuickNoteCopy.openDoorSpoken) == nil,
                    "no door over an empty box — there is nothing to open")

            box.text = "a thought on the way home"
            await surface.settle()
            #expect(surface.visibleLabels.contains("Typing. Not saved yet."),
                    "the indicator is present from the first real character")

            // Q8: minted, then emptied back to nothing.
            _ = await box.mintNow()
            box.text = ""
            await surface.settle()
            #expect(surface.element(labeled: MobileQuickNoteCopy.openDoorSpoken) == nil,
                    "the open door goes with the text")
            for spoken in ["Typing. Not saved yet.", "Saving.", "Saved on this iPhone."] {
                #expect(!surface.visibleLabels.contains(spoken),
                        "an emptied box claims nothing — found “\(spoken)”")
            }

            // And the door, DRIVEN: UIKit's own activation dispatch, the
            // road VoiceOver takes.
            box.text = "filed by the real button"
            await surface.settle()
            #expect(surface.activate(MobileQuickNoteCopy.openDoorSpoken),
                    "the door activates")
            await surface.settle()
            let postID = try #require(opened.value.first)
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["filed by the real button"])
        }
    }

    /// **AN EMPTY, FOCUSED BOX LEAVING DROPS THE KEYBOARD WITH IT** — the
    /// Fable sweep's finding 6, which is §62 item 3's fresh-eyes verdict.
    ///
    /// The state: she taps the box, types nothing, and taps Library. The
    /// never-minted empty box takes `file()`'s FIRST guard — `reset()` and
    /// out — so no hand-off is announced, and `handOffCount` was the only
    /// signal the face dropped the keyboard on. The keyboard therefore stood
    /// over the Library, on a shelf now behind it: the same visible symptom
    /// as §59's MAJOR 3, from a different state. (The tab bar IS reachable
    /// with the keyboard up — batch 5's own keyboard-avoidance finding lifts
    /// it onto the keyboard — so this is an ordinary gesture.)
    ///
    /// **The contract that must NOT flip rides in this same pin:**
    /// `handOffCount` stays 0. Nothing was handed off, and a counter that
    /// claimed otherwise would make the box lie about a filing it never
    /// made. The fix belongs at the focus seam, and this asserts both halves
    /// together so a later change cannot trade one for the other.
    ///
    /// Driven on the REAL mounted field through UIKit's own responder API,
    /// because the whole finding is about first-responder state — a model
    /// flag alone would prove nothing about the keyboard (§0's rule).
    ///
    /// **Red-on-old:** drop `setFocused(false)` from `reset()` (or the
    /// `onChange(of: model.isFocused)` release from the face) and the field
    /// is still first responder after the leaving.
    @Test func anEmptyFocusedBoxLeavingLetsGoOfTheKeyboard() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            // Hosted WITH a ruled writing height — the shelf's real shape,
            // where the box's two states (collapsed / open) are live.
            let surface = HostedSurface(MobileQuickNoteBox(
                model: box, tokens: VoiceTokens.terminalLight,
                writingHeight: 320, onOpen: { _ in }))
            await surface.settle()

            let field = try #require(textInput(in: surface),
                                     "the REAL field is mounted — this pin is worthless without it")
            #expect(field.becomeFirstResponder(), "she taps into the box")
            await surface.settle()
            #expect(field.isFirstResponder, "the caret really is in the box")
            #expect(box.isFocused, "…and the face told the model so")

            // …types nothing, and taps Library. A tab switch is a leaving.
            await box.fileOnLeaving()
            await surface.settle()

            #expect(!field.isFirstResponder,
                    "the box let go, so the keyboard let go — no keyboard over the Library")
            #expect(!box.isFocused)
            #expect(box.handOffCount == 0,
                    "and NOTHING was handed off — the shipped contract, unflipped")
            let posts = try await livePosts(db)
            #expect(posts.isEmpty, "an empty box mints nothing, as ever")
        }
    }

    /// **A REFUSED MINT AT A LEAVING LETS GO OF THE KEYBOARD TOO** — the
    /// fix diff's own cold review, R2-2.
    ///
    /// Finding 6's fix put the focus drop in `reset()`, which covers the
    /// three roads that CLEAR the box. The two REFUSAL roads deliberately do
    /// not clear it (Q2 keeps her text and its reason), so they never reach
    /// `reset()` — and a tab switch assigns `tab` synchronously with both
    /// stacks alive, so the keyboard stood over the Library above an
    /// invisible box holding un-filed text and an error she could not see.
    /// Same symptom, third state.
    ///
    /// **The Q2 contracts ride in this pin unmoved**, so a later change
    /// cannot buy the focus drop with her text: the box still holds every
    /// character, `lastError` still says why, and `handOffCount` is still 0
    /// because nothing was handed off.
    ///
    /// **Red-on-old:** drop `setFocused(false)` from `file()`'s refused-mint
    /// arm and the field is still first responder after the leaving.
    @Test func aRefusedMintAtALeavingLetsGoOfTheKeyboardToo() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            let surface = HostedSurface(MobileQuickNoteBox(
                model: box, tokens: VoiceTokens.terminalLight,
                writingHeight: 320, onOpen: { _ in }))
            await surface.settle()
            let field = try #require(textInput(in: surface),
                                     "the REAL field is mounted — this pin is worthless without it")
            #expect(field.becomeFirstResponder(), "she taps into the box")
            box.text = "the thought I had on the bus"
            await surface.settle()
            #expect(field.isFirstResponder, "…and types, with the caret in the box")

            // The store goes away mid-round — this app's scene handler's own
            // named case, injected as the refusal it produces.
            try await session.database.write { db in
                try db.execute(sql: """
                    CREATE TRIGGER quicknote_store_unavailable
                    BEFORE INSERT ON container
                    BEGIN SELECT RAISE(ABORT, 'the store is unavailable'); END
                    """)
            }
            await box.fileOnLeaving()
            await surface.settle()

            #expect(!field.isFirstResponder,
                    "the shelf was left, so the keyboard was left — no keyboard over the Library")
            #expect(!box.isFocused)
            #expect(try await livePosts(db).isEmpty, "nothing minted, as the refusal says")
            #expect(box.text == "the thought I had on the bus",
                    "and Q2 is untouched — her text is still in the box")
            #expect(box.lastError != nil, "…with the reason still on it")
            #expect(box.handOffCount == 0, "nothing was handed off — the shipped contract")
        }
    }

    /// Q2's other half, same seam: the note exists, the store REFUSED the
    /// keystrokes that followed the mint (a seal landing mid-typing), so
    /// `file()` returns without resetting — and used to return without
    /// letting go of the caret.
    ///
    /// Pinned SEPARATELY from the road above rather than folded into it:
    /// the two arms are two lines in two places, and one pin would leave
    /// whichever arm it did not drive green over nothing.
    ///
    /// **Red-on-old:** drop `setFocused(false)` from `file()`'s
    /// `autosave?.isDirty` arm and the field is still first responder.
    @Test func aLeavingWhoseKeystrokesWereRefusedLetsGoOfTheKeyboardToo() async throws {
        try await withEditorWorld { session, _ in
            let box = quietBox(session)
            let surface = HostedSurface(MobileQuickNoteBox(
                model: box, tokens: VoiceTokens.terminalLight,
                writingHeight: 320, onOpen: { _ in }))
            await surface.settle()
            let field = try #require(textInput(in: surface))

            box.text = "before the seal"
            let postID = try #require(await box.mintNow())
            try await session.runner.run { ops in try ops.lockPost(postID) }
            box.text = "before the seal, and after it"
            #expect(field.becomeFirstResponder(), "she is still typing in the box")
            await surface.settle()

            await box.fileOnLeaving()
            await surface.settle()

            #expect(!field.isFirstResponder,
                    "the keyboard does not stand over an error she cannot see")
            #expect(!box.isFocused)
            #expect(box.text == "before the seal, and after it",
                    "the refused keystrokes are still hers to see")
            #expect(box.lastError != nil)
            #expect(box.handOffCount == 0, "the box has not let go of the note")
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
    ///
    /// **`nil` is a THIRD answer, and its arrival is the A1-19 shape fix**
    /// (4.5a). The function used to return `""` both for *"the box owns
    /// everything"* and for *"the boundary cannot be named"* — and its own
    /// pin encoded the second as intended. One value for two opposite
    /// meanings is what let an unfound anchor make the box own text it does
    /// not own; the caller now refuses ownership on `nil`. Act 1 could
    /// construct no reachable input for that state and said so, so this
    /// asserts the CONTRACT and no behavioural pin is manufactured for it.
    @Test func theFrozenPrefixIsEmptyForTheOrdinaryCaptureAndAnchorsOtherwise() {
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "just this", ownedText: "just this", blockCount: 1) == "")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "one\n\ntwo", ownedText: "two", blockCount: 2) == "one\n\n")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "a\nb\na", ownedText: "a", blockCount: 3) == "a\nb\n",
                "the LAST occurrence anchors — a repeated piece must not rewind the box")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "one\n\ntwo", ownedText: "", blockCount: 2) == nil,
                "an unnameable anchor refuses ownership — it never claims everything")
        #expect(MobileQuickNoteModel.frozenPrefix(
            of: "one\n\ntwo", ownedText: "not in there", blockCount: 2) == nil,
                "…and so does an anchor that cannot be found in what was minted")
    }

    // MARK: - THE BOUNDARY (Q1 — the defect that destroyed her prose)

    /// **THE BLOCKER, pinned on the TEXT.** She pastes two paragraphs, the
    /// mint segments them, and then she fixes a typo in the FIRST one.
    ///
    /// The shipped clamp fired on `!hasPrefix`, wrote back the frozen
    /// prefix ALONE, and then derived the tail from that just-clamped
    /// text — getting `""`. The next flush wrote that empty string into the
    /// owned variant. **"Editable." was gone from the box and from
    /// SQLite**, unrecoverably: `autosave` registers no undo entry and no
    /// `commit_point` exists yet.
    ///
    /// The shipped comment and the shipped pin both asserted the road was
    /// only reachable *"after she has deleted back through the whole owned
    /// tail"*. Any edit inside the frozen prefix falsifies `hasPrefix` just
    /// as well — which is what makes this the one case nothing covered.
    ///
    /// **Red-on-old:** restore `applyOwnedChange`'s
    /// `write(frozenPrefix); recordTail()` clamp — the box reads
    /// `"Kept.\n\n"` and the store reads `["Kept.\n", ""]`.
    @Test func editingTheFirstParagraphNeverDestroysTheSecond() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            box.text = "Kept.\n\nEditable."
            let postID = try #require(await box.mintNow())
            #expect(box.frozenPrefix == "Kept.\n\n")
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["Kept.\n", "Editable."])

            // One backspace inside the FIRST paragraph.
            box.text = "Kep.\n\nEditable."

            await settle({ box.text == "Kept.\n\nEditable." },
                         "the box holds at the boundary — holding the WHOLE text, not the prefix")
            #expect(box.boundaryNote != nil,
                    "and it SAYS so: a silent revert of her keystrokes is its own defect")
            await session.flushEveryOpenPost()
            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["Kept.\n", "Editable."],
                    "her second paragraph is still in SQLite")
        }
    }

    /// **THE HOLD HAS TO REACH THE FIELD — and on the shipped 4.5a code it
    /// never did, so her prose was destroyed one keystroke later.**
    ///
    /// Found while building 4.5a MAJOR 5's confirm pin, which is the only
    /// reason it was found at all: every other boundary pin reads the
    /// MODEL, and the model was right the whole time. The FIELD was not.
    ///
    /// The mechanism, measured rather than reasoned about (iOS 26.2
    /// simulator): SwiftUI pushes a binding into `TextField` only when the
    /// value differs from the one it last rendered. `applyOwnedChange` wrote
    /// the restore back inside `text`'s own `didSet`, so the turn ended at
    /// the value SwiftUI had already rendered — no render, no push, and
    /// UIKit kept the rejected characters. From there the box showed
    /// `"Kep.\n\nEditable."` while the model and the store held
    /// `"Kept."` + `"Editable."`.
    ///
    /// **And the very next edit — anywhere, including inside the paragraph
    /// the box really owns — emptied the owned block.** The change SwiftUI
    /// reports is field-old → field-new, while `applyingChange` decomposes
    /// it against the MODEL's old text; with the two diverged the common
    /// edges collapse, the surviving tail comes back `""`, and the flush
    /// writes that into the variant. Unrecoverably: no undo entry, no
    /// commit_point. **That is Q1's BLOCKER, arriving through Q1's own
    /// fix.**
    ///
    /// **Red-on-old:** put `applyOwnedChange`'s hold back to
    /// `write(decision.text)` (the same-turn write) — the field stays on
    /// `"Kep.\n\nEditable."` and the store ends `["Kept.\n", ""]`.
    ///
    /// **This pin is also 4.5a MAJOR 5's verdict, and it asserts it rather
    /// than leaving it to be rediscovered:** once the restore lands, UIKit
    /// collapses the selection to the END of the new text. MAJOR 5 was
    /// right about the mechanism and it is live the moment the hold works
    /// at all. Nothing is misattributed — her next characters append to the
    /// block the box owns — but the caret moved without being asked, and
    /// putting it back needs caret control `TextField` does not offer. The
    /// expectation below is deliberately exact so that a later fix has to
    /// come here and change it on purpose.
    @Test func aHeldEditNeverStrandsTheFieldOnTextTheNoteDoesNotHold() async throws {
        try await withEditorWorld { session, db in
            let box = quietBox(session)
            let surface = HostedSurface(MobileQuickNoteBox(
                model: box, tokens: VoiceTokens.terminalLight, onOpen: { _ in }))
            await surface.settle()
            box.text = "Kept.\n\nEditable."
            let postID = try #require(await box.mintNow())
            #expect(box.frozenPrefix == "Kept.\n\n")
            await surface.settle()

            let field = try #require(textInput(in: surface),
                                     "the REAL field is mounted — this pin is worthless without it")
            #expect(field.becomeFirstResponder())
            #expect(fieldText(field) == "Kept.\n\nEditable.",
                    "…and it is showing her capture")

            // She puts the caret inside the FIRST paragraph and backspaces —
            // Q1's exact case, driven through UIKit's own input path.
            let caret = try #require(field.position(from: field.beginningOfDocument, offset: 4))
            field.selectedTextRange = field.textRange(from: caret, to: caret)
            (field as? UIKeyInput)?.deleteBackward()
            await surface.settle()

            // The path really was the one this pin names.
            #expect(box.boundaryNote != nil, "the hold fired")
            #expect(box.text == "Kept.\n\nEditable.", "and the model held")
            // THE FINDING: the field must hold too.
            #expect(fieldText(field) == "Kept.\n\nEditable.",
                    "the box shows what the note holds — never a character more or less")
            // MAJOR 5, measured and recorded (see the doc comment).
            #expect(caretOffset(field) == 16,
                    "MAJOR 5 confirmed: the caret collapses to the end once the restore lands")

            // She carries on typing at the end of the paragraph she owns.
            let end = field.endOfDocument
            field.selectedTextRange = field.textRange(from: end, to: end)
            (field as? UIKeyInput)?.insertText("!")
            await surface.settle()
            await session.flushEveryOpenPost()

            #expect(try await storedBlockTexts(db, postID: postID)
                    == ["Kept.\n", "Editable.!"],
                    "her paragraph is intact and her keystroke landed in it")
        }
    }

    /// The rule itself, as a pure function — the four shapes a change can
    /// have relative to the boundary. Settled on the TEXT in every arm: the
    /// bug this replaces was *"the totals agree while the content is
    /// wrong"*, so no oracle derived from lengths could witness it.
    @Test func theBoundaryRuleAppliesTheTailAndRefusesThePrefix() {
        typealias Note = MobileQuickNoteModel
        // The ordinary capture: no frozen prefix, every change is the
        // box's own, byte-for-byte the shipped behaviour.
        #expect(Note.applyingChange(frozenPrefix: "", from: "abc", to: "abd")
                == Note.BoundaryDecision(text: "abd", tail: "abd", heldAtBoundary: false))
        // Inside the owned tail: taken whole.
        #expect(Note.applyingChange(
            frozenPrefix: "Kept.\n\n", from: "Kept.\n\nEditable.", to: "Kept.\n\nEditable!")
            == Note.BoundaryDecision(
                text: "Kept.\n\nEditable!", tail: "Editable!", heldAtBoundary: false))
        // THE BLOCKER'S CASE: a typo fixed inside the prefix never touched
        // the tail, so the tail survives WHOLE.
        #expect(Note.applyingChange(
            frozenPrefix: "Kept.\n\n", from: "Kept.\n\nEditable.", to: "Kep.\n\nEditable.")
            == Note.BoundaryDecision(
                text: "Kept.\n\nEditable.", tail: "Editable.", heldAtBoundary: true))
        // Deleting back THROUGH the whole tail and into the prefix: the
        // tail really is emptied, so the store must hear `""`.
        #expect(Note.applyingChange(
            frozenPrefix: "Kept.\n\n", from: "Kept.\n\nEditable.", to: "Kept.")
            == Note.BoundaryDecision(
                text: "Kept.\n\n", tail: "", heldAtBoundary: true))
        // A change spanning the boundary: the tail's untouched remainder
        // survives, the prefix is restored, and the insertion is dropped —
        // there is no honest answer to which side of the boundary it
        // belongs on.
        #expect(Note.applyingChange(
            frozenPrefix: "Kept.\n\n", from: "Kept.\n\nEditable.", to: "Kepxable.")
            == Note.BoundaryDecision(
                text: "Kept.\n\nable.", tail: "able.", heldAtBoundary: true))
    }

    /// `mints` mirrors `importPost`'s own `emptyImport` refusal, so the box
    /// can never fire into it (the door's grey reads the same predicate).
    @Test func theMintPredicateMirrorsTheOperationsRefusal() {
        #expect(!MobileQuickNoteModel.mints(""))
        #expect(!MobileQuickNoteModel.mints("   \n\t "))
        #expect(MobileQuickNoteModel.mints(" a "))
    }
}
