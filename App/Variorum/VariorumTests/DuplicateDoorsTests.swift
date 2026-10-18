//
//  DuplicateDoorsTests.swift
//  VariorumTests
//
//  **VX-372 (VX-383 U1 — D-C-2): her two duplicate doors, declared once and
//  rendered everywhere a note is the target** (the run record
//  `notes/plans/fixes/vx-383-duplicate-note.md`). Her ticket: *"a direct
//  duplicate door, with tags / without tags; a duplicate with tags counts as
//  tagging."* The registry walk (`CapabilityRegistryTests`) proves declared ⇔
//  rendered for the union; this suite pins THIS act's doors one by one, its
//  verbs as her words from the ONE source the undo label reads (P-C-1), the
//  one act every door runs (`NoteDuplicate` — the copy, her tag choice, the
//  receipt saying where it landed with its Open ›, the refusal in the app's
//  words), the retired label gone from every Mac face, and the field guide's
//  versions lesson naming the doors from their own home (the H pattern,
//  `TutorialCurrencyTests`).
//
//  NEW API throughout (two capability ids, `Operations.DuplicateTags`,
//  `NoteDuplicate`, `DuplicateCopy`), so red-on-old is by COMPILATION — the
//  pre-fix tree declares no duplicate act and spells "Duplicate as Version"
//  in seven faces. The behavioural half (intake hearing the copy) is pinned
//  headlessly in `DuplicateAppliesTagsTests` / `DuplicateWithoutTagsTests`.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

// MARK: - The world

@MainActor
private func withDuplicateWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 372))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// The one live post other than `original` (the copy the act minted).
@MainActor
private func theCopy(besides original: String, in db: AppDatabase) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: """
                SELECT id FROM container
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL AND id <> ?
                """,
            arguments: [original])
    }
}

/// What the status centre is showing (a receipt goes to the quiet line by default).
@MainActor
private func spoken(_ session: AppSession) -> StatusCenter.Item? {
    session.status.current ?? session.status.quietLine
}

/// The Mac app's source tree (`App/Variorum/`), for the face scans.
private var appSourceRoot: URL {
    URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
}

@Suite("VX-372 — her two duplicate doors: declared once, rendered everywhere, one act", .serialized)
@MainActor
struct DuplicateDoorsTests {
    // MARK: - The declarations

    @Test func theTwoActsAreDeclaredOnceInHerWords() {
        let with = CapabilityRegistry.capability(.duplicateNoteWithTags)
        let without = CapabilityRegistry.capability(.duplicateNoteWithoutTags)
        #expect(with.verb == "Duplicate with Tags")
        #expect(without.verb == "Duplicate without Tags")
        // ONE source: the door's word is the undo entry's label.
        #expect(with.verb == Operations.DuplicateTags.applied.verb)
        #expect(without.verb == Operations.DuplicateTags.none.verb)
        for capability in [with, without] {
            #expect(capability.scope == .post)
            #expect(capability.shortcutLabel == nil, "no chord — none asked")
            #expect(capability.takesAccess == .native)
            #expect(capability.doors.isSuperset(of: [.menuBar, .contextMenu, .palette, .bottomBar]))
            #expect(capability.unavailableNote == DuplicateCopy.unavailableNote)
        }
        #expect(with.doors.contains(.surface), "the three shipped inline rows run WITH tags")
        #expect(!without.doors.contains(.surface))
    }

    /// Wherever a note is the target the doors act; with nothing open they are grey.
    @Test func theyActWhereverANoteIsShown() {
        for id in [CapabilityID.duplicateNoteWithTags, .duplicateNoteWithoutTags] {
            let capability = CapabilityRegistry.capability(id)
            for mode in PostMode.allCases {
                #expect(capability.availability(CapabilityContext(mode: mode)) == .act,
                        "\(id) acts in \(mode)")
            }
            #expect(capability.availability(CapabilityContext(mode: nil, writeEditorAttached: true))
                    == .act, "a book's inline note")
            #expect(capability.availability(CapabilityContext(mode: nil)) == .unavailable,
                    "nothing open: honestly grey")
        }
    }

    // MARK: - Every door renders the act

    @Test func everyDoorRendersBothActs() {
        let both: [CapabilityID] = [.duplicateNoteWithTags, .duplicateNoteWithoutTags]
        for id in both {
            #expect(EditorCommands.menuRendered.contains(id), "the File menu renders \(id)")
            #expect(ShellActions.paletteActs.contains(id), "⌘K renders \(id)")
            #expect(CommitBar.renderedCapabilities.contains(id), "Write's note ▾ renders \(id)")
            #expect(TakesBottomBar.renderedCapabilities.contains(id), "the boards' note ▾ renders \(id)")
            #expect(SidebarView.contextMenuCapabilities.contains(id), "the note-row grammar renders \(id)")
        }
        #expect(TakesBoardView.surfaceCapabilities.contains(.duplicateNoteWithTags))
        #expect(LensesBoardView.surfaceCapabilities.contains(.duplicateNoteWithTags))
        #expect(MembershipChip.surfaceCapabilities.contains(.duplicateNoteWithTags))
    }

    /// The row menus are read from their own bodies (a context menu cannot be mounted
    /// headlessly — `theLibraryNoteRowMenuRendersItsDeclaredDoors`' method): the Library's
    /// `postRowMenu` and the Pool row's menu each render both verbs from the registry.
    @Test func theRowMenusRenderBothVerbsFromTheRegistry() throws {
        let library = try String(
            contentsOf: appSourceRoot.appendingPathComponent(
                "Variorum/Features/Library/LibraryCatalogView.swift"),
            encoding: .utf8)
        let start = try #require(library.range(of: "private func postRowMenu("))
        let menu = String(library[start.upperBound...].prefix(8_000))
        let pool = try String(
            contentsOf: appSourceRoot.appendingPathComponent(
                "Variorum/Features/Pool/PoolPostsView.swift"),
            encoding: .utf8)
        for id in ["duplicateNoteWithTags", "duplicateNoteWithoutTags"] {
            #expect(menu.contains("CapabilityRegistry.capability(.\(id)).verb"),
                    "the Library row renders \(id)")
            #expect(pool.contains("CapabilityRegistry.capability(.\(id)).verb"),
                    "the Pool row renders \(id)")
        }
    }

    /// **P-C-1: "Duplicate as Version" retires from every face** — no Mac or shared source
    /// line outside a comment spells it (the menus, the boards, the chip, the first-edit
    /// note, the Diverge refusal, the helper, the guide's seed).
    @Test func theRetiredLabelIsOnNoFace() throws {
        var spelled: [String] = []
        for folder in ["Variorum", "Shared"] {
            let root = appSourceRoot.appendingPathComponent(folder)
            let files = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
            while let url = files?.nextObject() as? URL {
                guard url.pathExtension == "swift" else { continue }
                let source = try String(contentsOf: url, encoding: .utf8)
                for (index, line) in source.components(separatedBy: "\n").enumerated() {
                    let code = line.components(separatedBy: "//").first ?? ""
                    if code.contains("Duplicate as Version") || code.contains("DUPLICATE AS VERSION") {
                        spelled.append("\(url.lastPathComponent):\(index + 1)")
                    }
                }
            }
        }
        #expect(spelled.isEmpty, "the retired label still renders at \(spelled)")
    }

    /// The words that name the door in OTHER sentences follow it: the first-edit note and
    /// the Diverge refusal for a book that collects by tags (both read the one constant).
    @Test func theSentencesThatNameTheDoorFollowIt() {
        #expect(MultiBookEditNote.sentence(bookCount: 2).contains(DuplicateCopy.withTagsVerb))
        let smart = DivergeCopy.refusal(
            for: OperationError.wrongReadingKind(id: "r", expected: .book), book: "Dreams")
        #expect(smart.contains(DuplicateCopy.withTagsVerb))
    }

    // MARK: - The one act

    /// With tags: the copy wears the note's tag, a book whose rule hears it takes the copy
    /// in, and the receipt says so — naming the book — carrying the door to the copy.
    @Test func withTagsTheActSaysWhereTheCopyLandedAndCarriesItsDoor() async throws {
        try await withDuplicateWorld { session, db in
            let (noteID, bookID) = try await session.runner.run { ops -> (String, String) in
                let draft = try ops.createTag(name: "draft")
                let book = try ops.createReading(
                    name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
                let note = try ops.createPost(title: "the essay")
                _ = try ops.newBlock(in: note.id, text: "Some prose.", at: .end)
                try ops.applyTag(draft.id, toPost: note.id)
                return (note.id, book.id)
            }

            await NoteDuplicate.perform(postID: noteID, tags: .applied, session: session)

            // The source and the copy both sit in "drafts" now; the copy is the one besides.
            let copyID = try #require(try await db.read { db in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT post_id FROM reading_post
                        WHERE reading_id = ? AND post_id <> ? AND status = 'member' AND deleted_at IS NULL
                        """,
                    arguments: [bookID, noteID])
            }, "the living book took the copy in")
            let tags = try await db.read { db in
                try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                    arguments: [copyID])
            }
            #expect(tags == 1)
            let item = try #require(spoken(session))
            #expect(item.kind == .receipt)
            #expect(item.text == "Duplicated with tags \u{2014} the copy is in \u{201C}drafts\u{201D}.")
            #expect(item.action?.label == DuplicateCopy.openCopy)
        }
    }

    /// Without tags: the copy wears none, sits in the Pool, and the receipt says that.
    @Test func withoutTagsTheCopyWearsNoneAndTheReceiptSaysThePool() async throws {
        try await withDuplicateWorld { session, db in
            let noteID = try await session.runner.run { ops -> String in
                let draft = try ops.createTag(name: "draft")
                _ = try ops.createReading(
                    name: "drafts", kind: .book, querySpec: try RuleGrammar.encode(.tag(draft.id)))
                let note = try ops.createPost(title: "the essay")
                _ = try ops.newBlock(in: note.id, text: "Some prose.", at: .end)
                try ops.applyTag(draft.id, toPost: note.id)
                return note.id
            }

            await NoteDuplicate.perform(postID: noteID, tags: .none, session: session)

            let copyID = try #require(try await theCopy(besides: noteID, in: db))
            let rows = try await db.read { db -> [Int] in
                [try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM post_tag WHERE post_id = ?", arguments: [copyID]) ?? -1,
                 try Int.fetchOne(
                    db, sql: "SELECT COUNT(*) FROM reading_post WHERE post_id = ?", arguments: [copyID]) ?? -1]
            }
            #expect(rows == [0, 0], "no tag, and no book heard it")
            #expect(spoken(session)?.text == "Duplicated without tags \u{2014} the copy is in the Pool.")
        }
    }

    /// A door that did nothing says why, in the app's words (P-2) — never a raw dump.
    @Test func aBlocklessNoteRefusesInTheAppsWords() async throws {
        try await withDuplicateWorld { session, _ in
            let noteID = try await session.runner.run { ops in try ops.createPost(title: "empty").id }

            await NoteDuplicate.perform(postID: noteID, tags: .applied, session: session)

            let item = try #require(session.status.current)
            #expect(item.kind == .refusal)
            #expect(item.text == OpsRefusalCopy.message(for: OperationError.postHasNoBlocks(id: noteID)))
            #expect(!item.text.contains("postHasNoBlocks"))
        }
    }

    /// The File menu's and ⌘K's door with nothing open speaks the registry's honest note;
    /// with a note's detail mounted, it duplicates THAT note.
    @Test func theShellDoorActsOnTheNoteOnScreen() async throws {
        try await withDuplicateWorld { session, db in
            let actions = ShellActions(session: session, shell: ShellRouter())
            actions.duplicateNote(tags: .applied)
            #expect(session.status.current?.text == DuplicateCopy.unavailableNote)

            let noteID = try await session.runner.run { ops -> String in
                let note = try ops.createPost(title: "the essay")
                _ = try ops.newBlock(in: note.id, text: "Some prose.", at: .end)
                return note.id
            }
            let token = session.commandRouter.registerDetail(
                postID: noteID, mode: .write, applyMode: { _ in })
            defer { session.commandRouter.unregisterDetail(token) }
            actions.duplicateNote(tags: .none)
            for _ in 0..<40 {
                if try await theCopy(besides: noteID, in: db) != nil { break }
                try await Task.sleep(for: .milliseconds(25))
            }
            #expect(try await theCopy(besides: noteID, in: db) != nil, "the note on screen was duplicated")
        }
    }

    /// The words, as pure functions: the Pool, one book named, several counted.
    @Test func theLandedWordsSayWhere() {
        #expect(DuplicateCopy.landed(tags: .applied, books: [])
                == "Duplicated with tags \u{2014} the copy is in the Pool.")
        #expect(DuplicateCopy.landed(tags: .applied, books: ["drafts"])
                == "Duplicated with tags \u{2014} the copy is in \u{201C}drafts\u{201D}.")
        #expect(DuplicateCopy.landed(tags: .applied, books: ["a", "b", "c"])
                == "Duplicated with tags \u{2014} the copy is in 3 books.")
        #expect(DuplicateCopy.landed(tags: .none, books: [])
                == "Duplicated without tags \u{2014} the copy is in the Pool.")
    }

    // MARK: - The field guide (the H pattern)

    /// The versions lesson names both doors by their declared verbs, and no lesson of the
    /// guide spells the retired label (P-C-1; the seed's three sentences).
    @Test func theGuideNamesTheDoorsByTheirVerbs() async throws {
        try await withDuplicateWorld { session, db in
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            _ = try await TutorialSeeder.restore(session: session)
            let texts = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT v.working_text FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                        JOIN container c ON c.id = cb.container_id AND c.deleted_at IS NULL
                        WHERE v.deleted_at IS NULL
                        """)
            }
            let guide = texts.joined(separator: "\n")
            #expect(guide.contains(CapabilityRegistry.capability(.duplicateNoteWithTags).verb))
            #expect(guide.contains(CapabilityRegistry.capability(.duplicateNoteWithoutTags).verb))
            #expect(!guide.contains("Duplicate as Version"))
        }
    }
}
