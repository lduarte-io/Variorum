//
//  QuickNoteTests.swift
//  VariorumTests
//
//  Phase 13f, batch 6 — W5's pins (her round-3 ruling and her round-14
//  edges, built to the architect's gate ruling).
//
//  The sticky is a CAPTURE surface, so what there is to pin is exactly:
//  what a summon BECOMES (the standing `importPost` grammar, bookless, in
//  the Pool, never empty, saying "Quick Note" in the undo menu), WHEN it
//  mints (⌘⏎, close, and quit — never ⏎, which is a newline), the doors'
//  declaration, and the two window-level facts the pad is subject to (it
//  registers, and while it is key the app has ZERO live surfaces).
//
//  What is deliberately NOT claimed: how the floating pad LOOKS or FEELS,
//  and that the menu-bar glyph really summons it under a real hand — the
//  batch record's visual-verification list carries those (this host cannot
//  make a window key, batch 5b's measurement).
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - What a summon becomes

@MainActor
@Suite("The quick note's mint (13f W5)")
struct QuickNoteMintTests {
    /// Her ruling's whole promise in one pin: *"typing mints an ordinary
    /// bookless note (the Pool lists it)"*.
    @Test func aFiledPadIsAnOrdinaryBooklessNoteThePoolLists() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let id = await QuickNoteMint.file(
                "A thought worth keeping.", session: session)
            let noteID = try #require(id.postID)

            let (header, pool, books, curated) = try await db.read { db in
                (try Queries.containerHeader(db, containerID: noteID),
                 try Queries.poolPosts(db, limit: 50).map(\.postID),
                 try Queries.readingsContaining(db, postID: noteID),
                 try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ?",
                    arguments: [noteID]))
            }
            #expect(header?.title == nil, "untitled — the app's one brain names it")
            // 13g batch 7 (R6-4) — THIS EXPECTATION LEGITIMATELY CHANGED, and
            // the change is recorded in the batch record rather than made
            // quietly. Her ruling put every quick note under the `quicknote`
            // tag and gave that tag a SMART book, and the Pool has excluded
            // smart-collected posts since Stage B's MAJOR 3 (promote-tags-to-
            // book must DRAIN the pool — derived membership counts as being
            // in a book). So a filed pad is now in Quicknotes and NOT in the
            // Pool. It is still bookless in the CURATED sense — no membership
            // row exists — which is what keeps it one untag away from the
            // Pool again.
            #expect(!pool.contains(noteID), "a quick note is collected, so the Pool lets it go")
            #expect(books.map(\.name) == [Operations.defaultQuicknoteBookName])
            #expect(curated == 0, "collected by a predicate, never by a row")
            // And it stays QUIET beyond one line naming where it went.
            // 18i: these words are a RECEIPT now, and her default puts a
            // receipt in the bar's quiet line rather than the toast.
            // `spoken` is the kind-agnostic read — this pin is about
            // WHAT was said; `StatusCenterTests` owns WHICH SLOT.
            #expect(session.status.spoken?.text == QuickNoteCopy.filedNote)
        }
    }

    /// **13i-b U4 (§20 — Quicknotes is ordinary; P-13ib-U4-2):** once she has
    /// deleted the Quicknotes gathering, a filed pad is tagged and lands in
    /// the Pool — no gathering comes back, and the receipt names where the note
    /// IS rather than claiming the Quicknotes landing that did not happen.
    @Test func afterSheDeletesQuicknotesTheReceiptSaysThePool() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let first = try #require(
                await QuickNoteMint.file("First.", session: session).postID)
            let book = try #require(try await db.read { db in
                try Queries.readingsContaining(db, postID: first).first?.id
            })
            try await session.runner.run { ops in try ops.deleteReading(book) }

            let second = try #require(
                await QuickNoteMint.file("Second.", session: session).postID)
            let (live, pool, tags) = try await db.read { db in
                (try Queries.readings(db),
                 try Queries.poolPosts(db, limit: 50).map(\.postID),
                 try Queries.postTags(db, postID: second).map(\.path))
            }
            #expect(live.isEmpty, "her deletion stands — nothing re-minted")
            #expect(pool.contains(second))
            #expect(tags == [Operations.quicknoteTagPath])
            #expect(session.status.spoken?.text == QuickNoteCopy.filedTaggedOnly)
            #expect(!QuickNoteCopy.filedTaggedOnly.localizedCaseInsensitiveContains(Operations.defaultQuicknoteBookName))
        }
    }

    /// The typed text is CONTENT, segmented by the standing rule — so the
    /// sticky needs no segmentation rule of its own and the 2026-07-12
    /// spacing ruling rides free.
    @Test func theTypedTextSegmentsByTheStandingRuleAndKeepsItsSpacing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // The pad holds MANY paragraphs (her round-14.2, and R-13u-4's
            // own half of the ruling — only the KEY that makes one moved),
            // so a multi-paragraph pad is the ordinary case.
            let typed = "First thought.\n\nSecond thought."
            let noteID = try #require(
                await QuickNoteMint.file(typed, session: session).postID)
            let rendered = try await db.read { db in
                try Queries.renderedText(db, containerID: noteID)
            }
            #expect(rendered == typed, "what she typed is what the note says")
        }
    }

    /// One summon = one note, and an empty pad mints NOTHING (her
    /// round-14.2) — so an abandoned summon cannot litter the Pool.
    @Test func anEmptyPadMintsNothingAtAnyDoor() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for pad in ["", "   ", "\n\n", " \n \t "] {
                #expect(!QuickNoteMint.mints(pad), "the button is grey for \(pad.debugDescription)")
                #expect(await QuickNoteMint.file(pad, session: session) == .nothingToFile)
            }
            let posts = try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1
            }
            #expect(posts == 0, "not one note was minted")
            #expect(session.status.spoken == nil, "and nothing was said about it")
        }
    }

    /// The undo entry says what she DID (the approved label widening) —
    /// "Undo Quick Note", never "Undo Import".
    @Test func theUndoEntrySaysQuickNoteAndStillUndoesTheWholeMint() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let noteID = try #require(
                await QuickNoteMint.file("Jotted.", session: session).postID)
            #expect(session.undoStack.topLabel == QuickNoteCopy.undoLabel)
            #expect(EditorCommands.undoMenuTitle(for: session.undoStack.topLabel)
                    == "Undo Quick Note")

            // The label is the ONLY thing that changed: the entry still
            // undoes the whole mint, and redo still puts it back.
            let undoStack = session.undoStack
            _ = try await session.runner.run { ops in try undoStack.undo(with: ops) }
            #expect(try await db.read { db in
                try Queries.containerHeader(db, containerID: noteID)
            } == nil, "undo tombstones the minted note")
            _ = try await session.runner.run { ops in try undoStack.redo(with: ops) }
            #expect(try await db.read { db in
                try Queries.containerHeader(db, containerID: noteID)
            } != nil, "and redo brings it back")
        }
    }

    /// **THE THREE MINT TRIGGERS, each driven directly** (her round-14.2 as
    /// R-13u-4 amended it: ⏎ AND ⌘⏎ file it; closing files it) — and the
    /// property that makes them compose: ONE SUMMON = ONE NOTE.
    ///
    /// This pin exists because revert W5-B passed green without it: with
    /// the triggers inside the view's lifecycle hooks, deleting the close
    /// path broke nothing a test could see. The pad is its own type for
    /// exactly that reason.
    @Test func closingAndCommandReturnEachFileExactlyOneNotePerSummon() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // 13g batch 7 (R6-4): these counts mean "how many notes did the
            // pad mint", and the Pool stopped being a proxy for that when
            // quick notes joined the smart Quicknotes book (see
            // `aFiledPadIsAnOrdinaryBooklessNoteThePoolLists`). Counting live
            // posts says exactly what the pin always meant.
            func noteCount() async throws -> Int {
                try await db.read { db in
                    try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM container
                            WHERE kind = 'post' AND deleted_at IS NULL
                            """) ?? -1
                }
            }

            // CLOSING FILES IT.
            let closed = QuickNotePad(session: session)
            closed.text = "Closed without filing."
            #expect(await closed.close().postID != nil)
            var count = try await noteCount()
            #expect(count == 1)

            // ⌘⏎ FILES IT — and the close that FOLLOWS mints nothing, which
            // is what "one summon = one note" means in practice.
            let filed = QuickNotePad(session: session)
            filed.text = "Filed on purpose."
            #expect(await filed.fileExplicitly().postID != nil)
            count = try await noteCount()
            #expect(count == 2)
            #expect(!filed.mints, "the pad cleared itself")
            #expect(await filed.close() == .nothingToFile,
                    "closing after ⏎/⌘⏎ mints no second note")
            count = try await noteCount()
            #expect(count == 2)

            // An abandoned EMPTY summon leaves nothing behind at any door.
            let empty = QuickNotePad(session: session)
            #expect(await empty.close() == .nothingToFile)
            #expect(await empty.fileExplicitly() == .nothingToFile)
            count = try await noteCount()
            #expect(count == 2, "an abandoned empty summon leaves nothing behind")
        }
    }

    /// THE QUIT PATH (the architect's ruling (c)): a non-empty pad at app
    /// quit files itself through the standing quit-finalize family — the
    /// capture-scale analog of the open tail's teardown backstop.
    @Test func aNonEmptyPadFilesItselfAtQuit() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // The registration the view makes on appear, driven directly —
            // the same closure body, over the same pad type.
            let pad = QuickNotePad(session: session)
            pad.text = "Something I would have lost."
            let token = session.quitFinalize.register { @MainActor in
                await pad.finalizeAtQuit()
            }
            // Premise: nothing is in the store yet, so this cannot pass
            // vacuously.
            #expect(try await db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1
            } == 0)

            await session.quitFinalize.finalizeAll()
            // 13g batch 7 (R6-4): counted as notes, not as Pool rows — a
            // filed pad is now collected by the smart Quicknotes book, and
            // the Pool lists only what no book holds.
            func notes() async throws -> Int {
                try await db.read { db in
                    try Int.fetchOne(
                        db,
                        sql: """
                            SELECT COUNT(*) FROM container
                            WHERE kind = 'post' AND deleted_at IS NULL
                            """) ?? -1
                }
            }
            let minted = try await notes()
            #expect(minted == 1, "the pad she never filed became a note")
            #expect(!pad.mints, "and the pad cleared, so a second quit hop mints nothing")
            await session.quitFinalize.finalizeAll()
            let afterTwice = try await notes()
            #expect(afterTwice == 1, "finalizing twice still mints exactly one note")

            session.quitFinalize.unregister(token)
            #expect(session.quitFinalize.isEmpty)
        }
    }
}

// MARK: - The doors (P-1)

@MainActor
@Suite("The quick note's doors (13f W5)")
struct QuickNoteDoorTests {
    /// A JUSTIFIED EDIT (13e E14, the E2/E8 convention — called out here
    /// rather than made quietly): the act gained a FOURTH door, the system
    /// hot key ⌃⌥⌘N (her kickoff-sitting Round 5). The exact-set expectation
    /// encoded the pre-E14 declaration, so naming the fourth element IS the
    /// red-on-old for the declaration — the pre-13e registry has no
    /// `.systemHotKey` case at all. The door's own pins live in
    /// `SystemHotKeyTests`.
    @Test func oneDeclarationCarriesAllFourDoors() {
        let capability = CapabilityRegistry.capability(.quickNote)
        #expect(capability.doors == [.menuBar, .menuBarExtra, .palette, .systemHotKey],
                "round-14.1's three doors, joined at 13e E14 by the system chord")
        #expect(capability.scope == .app)
        // `always`, and honestly: a pad can be summoned from anywhere at
        // any time — it takes no target and reads no context.
        for context in [CapabilityContext(mode: nil), CapabilityContext(mode: .write)] {
            #expect(capability.availability(context) == .act)
        }
        // The three renderers.
        #expect(EditorCommands.menuRendered.contains(.quickNote))
        #expect(QuickNoteMenuBarContent.menuBarExtraCapabilities == [.quickNote])
        #expect(ShellActions.paletteActs.contains(.quickNote))
    }

    /// THE COLLISION SWEEP, re-run with ⌘⇧N in the table (the standing pin
    /// walks the whole table; this states the batch's own result).
    @Test func theQuickNoteChordIsOursAndTheTableStaysCollisionFree() {
        var seen: [String: CapabilityID] = [:]
        for capability in CapabilityRegistry.all {
            guard let (key, modifiers) = EditorCommands.keyEquivalent(for: capability.id)
            else { continue }
            let chord = "\(key.character)-\(modifiers.rawValue)"
            #expect(seen[chord] == nil,
                    "\(capability.id) collides with \(seen[chord]?.rawValue ?? "") on \(chord)")
            seen[chord] = capability.id
        }
        let chord = EditorCommands.keyEquivalent(for: .quickNote)
        #expect(chord != nil)
        #expect(chord?.0 == "n")
        #expect(chord?.1 == [.command, .shift])
        // Its neighbour is untouched: ⌘N still makes a note.
        #expect(EditorCommands.keyEquivalent(for: .newPost)?.1 == .command)
    }

    /// ⌘K's row asks the SHELL for the window (P-4: the door names what it
    /// wants; the shell decides what that means), because `ShellActions`
    /// holds no `openWindow`.
    @Test func thePaletteRowRequestsTheWindowThroughTheShell() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            #expect(!shell.quickNoteRequested)

            let row = try #require(
                actions.paletteEntries().first { $0.title == QuickNoteCopy.verb })
            row.action()
            #expect(shell.quickNoteRequested, "the shell was asked for the pad")
        }
    }
}

// MARK: - The pad as a WINDOW

@MainActor
@Suite("The quick note's window (13f W5)")
struct QuickNoteWindowTests {
    /// The gate's registration ruling, as arithmetic: while the pad is key
    /// the app mounts ZERO live surfaces — which is what makes ⌘S and the
    /// whole editing family go honestly grey through the gates that
    /// already exist, and what keeps a menu act from reaching a window she
    /// is not looking at (the 5b defect, refused re-entry).
    @Test func whileThePadIsKeyTheAppHasNoLiveSurface() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            // Minting blocks means fractional-index jitter (the standing
            // harness idiom for any test that writes through Operations).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            _ = session
            let windows = WindowRegistry()
            let main = UUID()
            let pad = UUID()
            windows.register(main, router: ShellRouter(), kind: .full)
            windows.noteKey(main)

            // Before the pad: the main window mounts exactly one.
            let mainWindow = { (key: Bool) in
                PaneMount.WindowState(panes: [.primary], focused: .primary, isKey: key)
            }
            #expect(PaneMount.liveCount(across: [mainWindow(windows.isKey(main))]) == 1)

            // The pad opens and takes key. It has NO panes at all — it
            // mounts no text surface — so the app's live count is ZERO.
            windows.register(pad, router: ShellRouter(), kind: .quickNote)
            windows.noteKey(pad)
            #expect(windows.isKey(pad))
            #expect(!windows.isKey(main))
            #expect(PaneMount.liveCount(across: [mainWindow(windows.isKey(main))]) == 0,
                    "the main window's pane is read-cheap while the pad is key")

            // Closing the pad hands the live surface straight back — the
            // sticky key's own behaviour, no new rule.
            windows.unregister(pad)
            #expect(windows.isKey(main))
            #expect(PaneMount.liveCount(across: [mainWindow(windows.isKey(main))]) == 1)
        }
    }

    /// The pad navigates nowhere, so an app-wide navigation broadcast must
    /// never land in it — the `.noteOnly` rule, inherited by construction.
    @Test func thePadIsNeverANavigationTarget() {
        let windows = WindowRegistry()
        let main = UUID()
        let pad = UUID()
        windows.register(main, router: ShellRouter(), kind: .full)
        windows.register(pad, router: ShellRouter(), kind: .quickNote)
        windows.noteKey(main)
        windows.noteKey(pad)
        #expect(windows.isKey(pad), "it IS key…")
        #expect(windows.navigationTargetID == main, "…and still never the target")
        #expect(!windows.isNavigationTarget(pad))
    }
}

// MARK: - The words stay true (13g cold review, round 1)

/// 13g cold review R1-2/R1-3: batch 7 (R6-4) moved the quick note's landing
/// — tagged, into the smart Quicknotes book, OUT of the Pool — and three
/// word surfaces did not move with it. Two taught the old landing (the
/// helper's "quick note" dictionary entry; the field guide's workspace
/// lesson — the WT-1 drift class, in prose the shortcut guard cannot see),
/// and the filing-REFUSAL toast spoke the SUCCESS wording ("Filed in
/// Quicknotes … (reason)") precisely when the filing had not happened.
@MainActor
@Suite("The quick note's words stay true (13g cold review)")
struct QuickNoteWordTests {
    /// DISCRIMINATING REVERT (verified): return the pre-fix composition
    /// (`"\(QuickNoteCopy.filedNote) (\(reason))"`) from
    /// `refusedFilingLine` — the first two expectations fail; the helper
    /// pin below stays green. Restored, checksum-matched.
    @Test func aFilingRefusalNeverClaimsTheQuicknotesLanding() {
        let line = QuickNoteCopy.refusedFilingLine("the quicknotes shelf could not be reached")
        #expect(!line.contains(QuickNoteCopy.filedNote),
                "the refusal must not wrap the success claim")
        #expect(!line.contains("Filed in Quicknotes"))
        #expect(line.contains("Pool"),
                "where the note actually is — untagged and bookless")
        #expect(line.contains("the quicknotes shelf could not be reached"),
                "the reason rides along")
        // …and the success line still claims exactly what it always did.
        #expect(QuickNoteCopy.filedNote.contains(Operations.defaultQuicknoteBookName))  // 13s-b U1b: the one name constant
    }


    /// **13u3 UNIT C (her R-13u-4):** the same entry taught the capture
    /// model the ruling replaced. RED ON OLD: the new-line sentence.
    @Test func theHelperDictionaryTeachesTheCaptureKeys() throws {
        let entry = try #require(
            HelperView.entries.first { $0.term == "quick note" })
        #expect(entry.definition.contains("\u{23CE} files what you wrote"))
        #expect(entry.definition.contains("\u{21E7}\u{23CE} adds another paragraph"))
        #expect(!entry.definition.contains("makes a new line"),
                "the retired model is no longer taught")
        // …and the KEY list carries the pair too, since that tab is where
        // someone looks for a key rather than for a word.
        #expect(HelperView.groups.flatMap(\.items).contains {
            $0.keys.contains("\u{21E7}\u{23CE}") && $0.does.contains("paragraph")
        }, "the shortcuts tab names ⇧⏎ in a capture box")
    }

    /// DISCRIMINATING REVERT (verified): restore the pre-fix entry text
    /// ("…keeps what you wrote as a new note in the Pool.") — this fails on
    /// the "Quicknotes" expectation. Restored, checksum-matched.
    @Test func theHelperDictionaryTeachesTheQuicknotesLanding() throws {
        let entry = try #require(
            HelperView.entries.first { $0.term == "quick note" },
            "the dictionary keeps its quick-note entry")
        #expect(entry.definition.contains(Operations.defaultQuicknoteBookName),
                "the entry names where the note actually lands (R6-4; 13s-b U1b — the one name constant)")
        #expect(entry.definition.contains("Pool"),
                "…and the one-untag road back — the Pool is the consequence, not the landing")
        #expect(!entry.definition.contains("as a new note in the Pool"),
                "the pre-R6-4 claim is gone")
    }
}
