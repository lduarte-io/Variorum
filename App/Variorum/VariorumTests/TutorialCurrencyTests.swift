//
//  TutorialCurrencyTests.swift
//  VariorumTests
//
//  librarywalkpolish VR-122 — THE FIELD GUIDE'S FULL CURRENCY PASS (a
//  PRE-0.9.2 GATE; her instruction: "make sure … the field guide is up to
//  date fully from all of these changes + the 13i changes … so any new users
//  get a good guide during the beta phase"). The audit read every lesson
//  against the surface 0.9.2 ships and found eleven lessons' worth of claims
//  FALSE of it (the record: `notes/plans/librarywalkpolish-vr122-guide-pass.md`,
//  F-1…F-12). Each claim-class below had NO pin — which is how each drifted —
//  so each fix lands with one, committed AHEAD of the seed edit and red on
//  the shipped seed.
//
//  The H pattern, as the guide's suites practise it: the prose is written
//  PLAINLY in the seed and every door it names is asserted here from that
//  door's OWN home (a registry label, a copy constant, the area table — or,
//  where a surface spells its word inline, a source scan of that surface),
//  so the next rename turns the lesson RED rather than merely wrong.
//  (F-11, the starred shelf, extends `lessonSevenTheBookcase` and R5 in
//  `TutorialBooksChapterTests` — JUSTIFIED EDITS, labeled there.)
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore

@testable import Variorum

// MARK: - The world

@MainActor
private func withGuide<T>(
    _ body: @MainActor (AppSession, AppDatabase, _ guideID: String) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 122))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        let guideID = try await TutorialSeeder.restore(session: session)
        return try await body(session, db, guideID)
    }
}

private enum CurrencyError: Error { case missing(String) }

/// One lesson's whole stored text, by its exact title.
private func prose(_ db: AppDatabase, _ guideID: String, _ title: String) async throws -> String {
    try await db.read { db in
        guard let id = try String.fetchOne(
            db,
            sql: """
                SELECT c.id FROM reading_post rp
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                """,
            arguments: [guideID, title])
        else { throw CurrencyError.missing(title) }
        return try Queries.renderedText(db, containerID: id)
    }
}

/// Every lesson of the WHOLE guide, (title, text).
private func everyLesson(_ db: AppDatabase, _ guideID: String) async throws -> [(String, String)] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT post_id FROM reading_post
                WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                ORDER BY position, id
                """,
            arguments: [guideID]
        ).map { id in
            (try Container.fetchOne(db, key: id)?.title ?? id,
             try Queries.renderedText(db, containerID: id))
        }
    }
}

/// The app's own sources, for the surfaces that spell their words inline
/// (the `LibraryCardsWordTests` road).
private enum AppSource {
    static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    static func read(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appending(path: relative), encoding: .utf8)
    }
}

/// A count as the lessons spell it.
private func countWord(_ n: Int) -> String {
    let words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    return n < words.count ? words[n] : "\(n)"
}

// MARK: - The pins

@MainActor
@Suite("Tutorial currency — the guide against the 0.9.2 surface (librarywalkpolish VR-122)")
struct TutorialCurrencyTests {

    /// **F-1 + F-2 — getting around's inventory of the sidebar and the
    /// Library.** It said "The sidebar has four places" — five since the
    /// post-13l polish round added ARCHIVED (`SidebarView.areas`, the ONE
    /// table the column iterates) — and a Library "with a List and a Timeline
    /// view", where the views are List · Cards · Timeline (17y (d)'s word,
    /// `LibraryCatalogModel.Mode.label`). RED ON OLD: "four places", no
    /// ARCHIVED, no Cards.
    @Test func gettingAroundNamesEverySidebarPlaceAndEveryLibraryView() async throws {
        try await withGuide { _, db, guideID in
            let text = try await prose(db, guideID, "getting around")
            let areas = SidebarView.areas
            #expect(text.contains("The sidebar has \(countWord(areas.count)) places."),
                    "the count is the area table's own")
            // 13s-b triage landing — A JUSTIFIED EDIT (her R-13s-30 caps ban):
            // the lesson names each place in its REAL casing now, each opening
            // its own one-sentence description; the arm read the retired
            // caps-for-emphasis form (`title.uppercased()`).
            for area in areas {
                #expect(text.contains(". \(area.title) "),
                        "the lesson names the sidebar's \(area.title), its own sentence")
            }
            for mode in LibraryCatalogModel.Mode.allCases {
                #expect(text.contains(mode.label), "the Library's \(mode.label) view, by its own word")
            }
        }
    }

    /// **F-3 — back and forward are ⌥⌘[ / ⌥⌘].** 13u4 UNIT S1 moved the
    /// chords (PROVISIONAL #130 — Apple Notes' own pair) and gave ⌘[ / ⌘] to
    /// Outdent / Indent; "the workspace" went on teaching "⌘[ and ⌘] walk back
    /// and forward" twice. The chords are read from the REGISTRY, and no lesson
    /// anywhere may pair the indent chords as a road. RED ON OLD: both
    /// sentences.
    @Test func theWorkspaceLessonTeachesTheRegistrysBackAndForwardChords() async throws {
        try await withGuide { _, db, guideID in
            let back = try #require(CapabilityRegistry.capability(.navigateBack).shortcutLabel)
            let forward = try #require(CapabilityRegistry.capability(.navigateForward).shortcutLabel)
            let outdent = try #require(CapabilityRegistry.capability(.formatOutdent).shortcutLabel)
            let indent = try #require(CapabilityRegistry.capability(.formatIndent).shortcutLabel)
            let text = try await prose(db, guideID, "the workspace")
            #expect(text.contains("\(back) and \(forward) walk back and forward"),
                    "the Open list's paragraph names the registry's chords")
            #expect(text.contains("(\(back) and \(forward) are the same doors)"),
                    "…and so does the context bar's")
            for (title, lesson) in try await everyLesson(db, guideID) {
                #expect(!lesson.contains("\(outdent) and \(indent)"),
                        "\u{201C}\(title)\u{201D} teaches the INDENT pair as navigation")
            }
        }
    }

    /// **F-4 — the star row reads Star.** The right-click rows say Star /
    /// Unstar (`StarDoor.title` → `StarCopy.rowTitle`); "Toggle Star" is the
    /// ⌘K act's verb only, and "the workspace" quoted it as the row. RED ON
    /// OLD: "▸ “Toggle Star”".
    @Test func theStarRowIsNamedByTheRowsOwnWord() async throws {
        try await withGuide { _, db, guideID in
            let text = try await prose(db, guideID, "the workspace")
            #expect(text.contains("Right-click any note or book \u{25B8} \u{201C}\(StarCopy.starRow)\u{201D}"))
            for (title, lesson) in try await everyLesson(db, guideID) {
                #expect(!lesson.contains("\u{25B8} \u{201C}\(StarCopy.verb)\u{201D}"),
                        "\u{201C}\(title)\u{201D} names a right-click row the menu doesn't have")
            }
        }
    }

    /// **F-5 — the end-of-note block door lives on TAKES' block ▾.** "shaping
    /// blocks" said "Write and Takes alike; the block ▾ menu in the bottom bar
    /// also has ＋ New block at the end of the note" — Write's block ▾
    /// (`CommitBar.blockMenu`) has New block BELOW only. The bars spell the row
    /// inline, so the truth arm scans them. RED ON OLD: the unscoped sentence.
    @Test func theEndOfNoteBlockDoorIsTaughtWhereItLives() async throws {
        try await withGuide { _, db, guideID in
            let row = "\u{FF0B} New block at the end of the note"
            let text = try await prose(db, guideID, "shaping blocks")
            // 13s-b triage landing — A JUSTIFIED EDIT: the scoped sentence now
            // opens its own sentence ("…Write and Takes alike. In Takes, …").
            #expect(text.contains("In Takes, the block \u{25BE} menu in the bottom bar also has \(row)"))
            #expect(try AppSource.read("Variorum/Features/Takes/TakesBottomBar.swift").contains(row),
                    "the row is Takes' block ▾'s")
            #expect(!(try AppSource.read("Variorum/Features/Editor/CommitBar.swift").contains(row)),
                    "…and Write's block ▾ has no such row (if it gains one, relax the lesson)")
        }
    }

    /// **F-6 — the heading path is the menu's own.** "Format ▸ Heading ▸ 2"
    /// — the submenu's rows read "Heading 1/2/3" (`MarkdownActs.headingRows`,
    /// the ONE table the menu bar and the context submenu render). RED ON
    /// OLD: "▸ 2".
    @Test func theHeadingPathIsTheMenusOwn() async throws {
        try await withGuide { _, db, guideID in
            let text = try await prose(db, guideID, "formatting")
            let second = try #require(MarkdownActs.headingRows.dropFirst().first?.title)
            #expect(text.contains("Format \u{25B8} Heading \u{25B8} \(second)"))
        }
    }

    /// **F-7 + F-8 — the takes lessons send her to Takes first.** A note
    /// opens in WRITE the first time (`PostDetailView`'s default, S4-20 — the
    /// guide's own getting-around sentence), and in Write ⌘T only mints the
    /// take behind a receipt, ⌘⏎ and ⌃⌘←/→ only open the takes panel, and the
    /// bottom bar has no "+ take" — so "a second take appears beside it" and
    /// "step through them" could not happen where the guide puts her. The
    /// mode's key is derived from the ONE row (`PostMode`); the bars' "+ take"
    /// is scanned. RED ON OLD: neither lesson names Takes' key.
    @Test func theTakesLessonsSendHerToTakesFirst() async throws {
        try await withGuide { _, db, guideID in
            let ordinal = try #require(PostMode.allCases.firstIndex(of: .takes)) + 1
            let key = "\u{2318}\(ordinal)"
            let first = try await prose(db, guideID, "your first take")
            let choosing = try await prose(db, guideID, "choosing & the board")
            #expect(first.contains("Press \(key) for Takes"), "the first take is made on the board")
            #expect(choosing.contains("In Takes (\(key))"), "…and chosen there")
            #expect(first.contains("\u{FF0B} take in the bottom bar"))
            #expect(try AppSource.read("Variorum/Features/Takes/TakesBottomBar.swift")
                .contains("chromeLabel(\"+ take\")"), "the + take door is Takes' bar's")
            #expect(!(try AppSource.read("Variorum/Features/Editor/CommitBar.swift").contains("+ take")),
                    "…and Write's bar has none")
        }
    }

    /// **F-9 — Canvas is taught only through the build's flavour seam.**
    /// Canvas is Debug-only since 17y (p) — the note row AND the Snippets
    /// area's Canvas face (`PoolDetailView.Mode.faces`) — and the B-DEDUPE
    /// MAJOR-2 fix routed the mode sentence and the looking lesson through
    /// `PostMode.buildKeepsCanvas`; "pool & scraps" still sent her to "a
    /// canvas card" in every flavour. Every lesson OUTSIDE the seam must not
    /// say canvas (the seam's own text — the mode sentence and the looking
    /// lesson — carries Canvas only in Debug, pinned by
    /// `TutorialBuildFlavorTests`). RED ON OLD: "pool & scraps".
    @Test func noLessonTeachesCanvasOutsideTheFlavourSeam() async throws {
        try await withGuide { _, db, guideID in
            #expect(PoolDetailView.Mode.faces(keepingCanvas: false) == [.scraps],
                    "Release's Snippets area has no Canvas face")
            let seamLesson = TutorialSeeder.lookingLessonContent().title
            let seamSentence = TutorialSeeder.modeRowSentence()
            var read = 0
            for (title, text) in try await everyLesson(db, guideID) where title != seamLesson {
                let outsideTheSeam = text.replacingOccurrences(of: seamSentence, with: "")
                #expect(!outsideTheSeam.localizedCaseInsensitiveContains("canvas"),
                        "\u{201C}\(title)\u{201D} teaches Canvas outside the build's seam")
                read += 1
            }
            #expect(read > 30, "the whole guide is read")
        }
    }

    /// **F-10 — a book's toggle has four views.** "a book from the inside"
    /// said "Three views of a book share the toggle at the top" and taught
    /// Outline · Book · Read; the toggle is Outline · Index · Book · Read
    /// (`BookView.bookMasthead` — the book INDEX since pre-13u Act 10 wave
    /// 2c, editable in place since the correction round). The tabs are inline
    /// literals, so the count and the names are scanned from the masthead.
    /// RED ON OLD: "Three views", no INDEX.
    @Test func theBookLessonCountsEveryViewTheToggleHas() async throws {
        try await withGuide { _, db, guideID in
            let view = try AppSource.read("Variorum/Features/BookView/BookView.swift")
            let tab = try Regex(#"modeTab\("([A-Za-z]+)", \."#)
            let labels = view.matches(of: tab).compactMap { $0.output[1].substring.map(String.init) }
            #expect(labels == ["Outline", "Index", "Book", "Read"], "the masthead's own tabs")
            let text = try await prose(db, guideID, "a book from the inside")
            let count = countWord(labels.count)
            let capitalized = count.prefix(1).uppercased() + String(count.dropFirst())
            #expect(text.contains("\(capitalized) views of a book share the toggle at the top."))
            // 13s-b triage landing — A JUSTIFIED EDIT (her R-13s-30 caps ban):
            // each view is named in its REAL casing, opening its own sentence;
            // the arm read the retired caps form (`label.uppercased()`).
            for label in labels {
                #expect(text.contains(". \(label) "), "the lesson teaches \(label), its own sentence")
            }
        }
    }

    // MARK: - VX-89 — the finder's lesson (R-VX83-3)
    //
    // Her question at the 13o follow-up report — *"were search details added
    // to the field guide?"* — they were not (`TutorialSeeder` said "search"
    // three times in passing); R-VX83-3: *"add the content to the field guide
    // now, with whatever information a user needs for it."* The lesson is new,
    // so every pin below is RED on the pre-VX-89 seed (`prose` throws
    // `missing("search")`; the plan has no such title). The H pattern: the
    // prose is plain, each door it names is read from its own home here.

    /// The lesson sits in the Library's chapter, right after the lesson that
    /// teaches the tags it leans on (`#tag` alone narrows to the tagged notes).
    @Test func theSearchLessonFollowsTheTagsItLeansOn() {
        let chapter = TutorialSeeder.plan.first { $0.chapter == "the library of things" }?.lessons ?? []
        let tags = chapter.firstIndex(of: "comments & tags")
        #expect(tags != nil)
        #expect(chapter.firstIndex(of: TutorialSeeder.searchLessonTitle) == tags.map { $0 + 1 })
    }

    /// **Every finder door the lesson names, by its own home's word** — the
    /// answer sheet's road, the wing chip, the other-take badge, the find
    /// chords (the registry's), the tag offer (VX-84b), the `when ▾` door's
    /// words and its sentence (VX-87 — the mode row's words lost their menu
    /// ellipses with the menu), `+ archived`, the book's 🔍 (the masthead
    /// door's glyph, scanned — it is an inline symbol name) and ⌘K's road row.
    @Test func theSearchLessonNamesEveryFinderDoorByItsOwnWord() async throws {
        try await withGuide { _, db, guideID in
            let text = try await prose(db, guideID, TutorialSeeder.searchLessonTitle)
            func quoted(_ word: String) -> String { "\u{201C}\(word)\u{201D}" }

            #expect(try AppSource.read("Variorum/Features/Library/LibraryCatalogView.swift")
                .contains("Search books, notes, blocks"), "the field the lesson calls the search field")
            #expect(LibrarySearchCopy.allLines(7) == "all 7 \u{203A}")
            #expect(text.contains(quoted("all N \u{203A}")), "the answer sheet's road, in its own shape")
            #expect(text.contains(quoted(LibrarySearchCopy.wingChip(WingWords.home))))
            #expect(text.contains(quoted(LibrarySearchCopy.inAnotherTake)))

            let next = try #require(CapabilityRegistry.capability(.findNext).shortcutLabel)
            let previous = try #require(CapabilityRegistry.capability(.findPrevious).shortcutLabel)
            #expect(text.contains("\(next) steps to the next match, \(previous) back"),
                    "the find chords are the registry's")

            #expect(text.contains(quoted(LibrarySearchCopy.tagOffer("name"))), "the band's tag offer")

            #expect(text.contains("\(LibraryDayFace.closedLabel) \u{25BE}"), "the when door at rest")
            for word in [LibraryDayFace.onADay, LibraryDayFace.betweenDays, LibraryDayFace.anyDay] {
                #expect(text.contains(quoted(word)), "the when door's \(word)")
            }
            var utc = Calendar(identifier: .gregorian)
            utc.timeZone = TimeZone(identifier: "UTC")!
            let now = try #require(DateFormatter.variorumISO8601.date(from: "2026-10-07T12:00:00.000Z"))
            let sentence = LibraryDayFace.sentence(
                range: LibraryDayRange(day: "2026-10-06"), now: now, calendar: utc,
                locale: Locale(identifier: "en_US"))
            #expect(text.contains(quoted(sentence.plain)), "the popover's own sentence")

            #expect(text.contains(quoted(LibrarySearchCopy.archivedOff)))
            // VX-72 (U-C — U-B's rider): the commits facet's chip, her word
            // (R-VX83-9), and the word its lines wear.
            #expect(text.contains(quoted(LibrarySearchCopy.commitsOff)), "the + commits chip")
            #expect(text.contains(quoted(try #require(SearchAnswerCopy.kindWord(.savepoint)))),
                    "the savepoint line's word")
            #expect(try AppSource.read("Variorum/Features/BookView/BookSearchViews.swift")
                .contains("Image(systemName: \"magnifyingglass\")"), "the book masthead's door is a 🔍")
            #expect(text.contains("\u{1F50D} at the right of the book's masthead"))
            #expect(text.contains(quoted(CommandPaletteCopy.allMatches)), "⌘K's road row")
        }
    }

    /// **The lesson's two practice acts hold on the guide itself** (P-6 — the
    /// tutorial is the executable spec): the practice word answers with the
    /// lesson's own paragraph ALONE, whose line lands with the word armed and
    /// stepping, and the paragraph holds it twice so ⌘G has somewhere to go;
    /// `#tutorial` typed alone narrows the Library to the guide (VX-84a's
    /// listing), every lesson listed and nothing listed that lacks the tag.
    @Test func theSearchLessonsPracticeHoldsOnTheGuideItself() async throws {
        try await withGuide { session, db, guideID in
            let suite = "vx89-search-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            let word = TutorialSeeder.searchPracticeWord

            let lessonIDs: [String: String] = try await db.read { db in
                Dictionary(try Row.fetchAll(
                    db,
                    sql: """
                        SELECT c.id AS id, c.title AS title FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                        """,
                    arguments: [guideID]
                ).map { ($0["title"] as String, $0["id"] as String) },
                uniquingKeysWith: { first, _ in first })
            }
            let searchLesson = try #require(lessonIDs[TutorialSeeder.searchLessonTitle])

            model.query = word
            await model.search()
            #expect(model.isSearching)
            #expect(model.searchState.groups.map(\.homeID) == [searchLesson],
                    "the practice word answers with this lesson alone")
            let line = try #require(model.searchState.groups.first?.lines.first)
            #expect(SearchLanding.findSeed(
                kind: line.kind, rendered: line.isRenderedTake, snippet: line.snippet)
                == EditorFindSeed(needle: word, steps: true),
                "the line lands with the word selected and the bar armed")
            let blockText = try await db.read { db in
                try Queries.renderPost(db, containerID: searchLesson)
                    .first { $0.blockID == line.blockID }?.text ?? ""
            }
            #expect(blockText.components(separatedBy: word).count - 1 == 2,
                    "the paragraph holds the word twice — ⌘G has a next one")

            model.query = "#\(TutorialSeeder.tagName)"
            await model.search()
            #expect(!model.isSearching, "a tag alone is the Library's own listing")
            var listed = model.noteHits.map(\.id)
            while model.notesHaveMore {
                let before = listed.count
                await model.loadMoreNotes()
                listed = model.noteHits.map(\.id)
                if listed.count == before { break }
            }
            for title in TutorialSeeder.plan.flatMap(\.lessons) {
                #expect(listed.contains(try #require(lessonIDs[title])), "\u{201C}\(title)\u{201D} is listed")
            }
            let listedJSON = String(data: try JSONEncoder().encode(listed), encoding: .utf8)
            let untagged = try await db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT c.id FROM container c
                        WHERE c.id IN (SELECT value FROM json_each(?))
                          AND NOT EXISTS (
                            SELECT 1 FROM post_tag pt JOIN tag t ON t.id = pt.tag_id
                            WHERE pt.post_id = c.id AND pt.deleted_at IS NULL
                              AND t.deleted_at IS NULL AND t.path = ?)
                        """,
                    arguments: [listedJSON, TutorialSeeder.tagName])
            }
            #expect(untagged.isEmpty, "nothing listed lacks the tag")
        }
    }

    /// **F-12 — no lesson promises the retired hover ＋.** 13l retired 13e
    /// E7's add-a-comment chip on an uncommented block (her 8c rider: "I need
    /// the comment + on the left removed … it's too crowded"; `BlockDecor`
    /// says so in place), and "comments & tags" kept promising it. The other
    /// doors the paragraph names stay. RED ON OLD: the retired clause.
    @Test func theCommentsLessonPromisesNoRetiredHoverPlus() async throws {
        try await withGuide { _, db, guideID in
            let text = try await prose(db, guideID, "comments & tags")
            #expect(!text.contains("pointing at an uncommented block"),
                    "the hover ＋ was retired at 13l")
            #expect(!text.contains("in the left margin"))
            #expect(text.contains("The comments button sits in the bottom bar in Write and Takes alike."))
            #expect(text.contains("\u{2318}\u{21E7}'"), "the panel's key, unchanged")
        }
    }

    /// **VX-292 U1 (R-292-9, amended at the vx-105 resolution) — the guide
    /// names the restore door by the menu's own title.** The Help menu has
    /// said "Restore Field Guide…" since VX-602, and two lessons still sent
    /// her to "Help ▸ Restore Tutorial…", a door that is not there. RED ON
    /// OLD: both lessons said the old name. The first lesson ("start here")
    /// rode vx-105's rewrite (Option B); both branches have landed, so the
    /// second merger tightened this pin to EVERY lesson, as U1's record asked.
    @Test func theLessonsNameTheRestoreDoorByItsMenuTitle() async throws {
        let door = "Help \u{25B8} \(CapabilityRegistry.capability(.restoreTutorial).verb)"
        #expect(CapabilityRegistry.capability(.restoreTutorial).doors.contains(.menuBar),
                "the door the lessons name is on the menu bar")
        try await withGuide { _, db, guideID in
            for title in ["the tray & the Trash", "comments & tags"] {
                let text = try await prose(db, guideID, title)
                #expect(text.contains(door), "\(title) names \(door)")
            }
            let lessons = try await everyLesson(db, guideID)
            #expect(lessons.count > 30, "the whole guide is read")
            for (title, text) in lessons {
                #expect(!text.contains("Restore Tutorial"), "\(title) names a door the menu no longer has")
            }
        }
    }
    // MARK: - VX-105 — the first chapter's "start here", woven (R-105-5 · R-105-7)

    /// The lesson's blocks in page order, each as its live active takes in fan
    /// order (the chosen original first — the seed never chooses a take).
    private func fans(_ db: AppDatabase, _ guideID: String, _ title: String) async throws -> [[String]] {
        try await db.read { db in
            guard let id = try String.fetchOne(
                db,
                sql: """
                    SELECT c.id FROM reading_post rp
                    JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                    WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                    """,
                arguments: [guideID, title])
            else { throw CurrencyError.missing(title) }
            let blocks = try String.fetchAll(
                db,
                sql: """
                    SELECT block_id FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL ORDER BY position, id
                    """,
                arguments: [id])
            return try blocks.map { blockID in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT working_text FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                        ORDER BY fan_position, id
                        """,
                    arguments: [blockID])
            }
        }
    }

    /// **The woven "start here" (VX-105 — R-105-5, her word: "interweave the
    /// relevant parts of 'Lillian's Start Here' … into the first chapter of the
    /// field guide"; R-105-7, her word: "…the four Castle passages are still in
    /// the first thing that someone reads"; R-105-10, her word: "the first
    /// thing it should direct you to do is probably to open the note
    /// itself").** The FIRST lesson of the FIRST chapter, fourteen blocks in
    /// this order: her welcome · the beliefs (its "Welcome." gone to hers) ·
    /// the book teaching itself · the lesson's FIRST ask, the move from the
    /// book into this note through the book's own open door (R-105-10) · the
    /// safety promise, naming the field guide's Help door by the registry's own
    /// verb (boundary ruling 1) · her take-icon block, VERBATIM, with her two
    /// takes · her Write/Takes block · her "so what?" block with her two takes
    /// · the companions · the four Start Here passages from the ONE constant,
    /// in order · the closer, naming where the chapter list is and the book
    /// glyph's way back (F-3). Every block but the two fanned ones holds exactly
    /// one take. RED ON OLD: the old lesson opened "Welcome. Variorum is
    /// built…", five blocks, no fan, no passages, no road into the note, and
    /// named "Restore Tutorial…".
    @Test func theStartHereLessonWeavesHerWelcomeHerTakesAndTheFourPassages() async throws {
        #expect(TutorialSeeder.plan.first?.chapter == "welcome")
        #expect(TutorialSeeder.plan.first?.lessons.first == "start here", "the first thing someone reads")
        try await withGuide { _, db, guideID in
            let lesson = try await fans(db, guideID, "start here")
            #expect(lesson.count == 14, "fourteen blocks: nine, the four passages, the closer")
            guard lesson.count == 14 else { return }
            let shown = lesson.map { $0.first ?? "" }
            #expect(shown[0] == "Welcome to Variorum! I'm Lillian, the developer behind this app, "
                    + "and I'm excited that you've downloaded it.", "her welcome, verbatim")
            #expect(shown[1].hasPrefix("Variorum is built on a few beliefs about writing. A paragraph "),
                    "the beliefs, its own \u{201C}Welcome.\u{201D} handed to hers")
            #expect(shown[2].hasPrefix("This book is Variorum teaching itself with itself."))
            // R-105-10 (ladder round 1, MAJOR-1 reshaped): the lesson's first ask
            // is the move from the book into this note, through the book's own
            // open door (RED ON OLD: no lesson block named a road into the note).
            #expect(NoteBoxCopy.openDoor == "open \u{2197}")
            #expect(shown[3] == "The first move to learn is the one from a book into a note. In the book's "
                    + "Outline each note is a card, and clicking it, or \(NoteBoxCopy.openDoor) beside its "
                    + "title, opens the note itself in the full editor. Open this lesson that way now if it "
                    + "isn't open already: the rest of it happens inside the note.",
                    "the first ask: open this note from the book (R-105-10)")
            let restoreDoor = CapabilityRegistry.capability(.restoreTutorial).verb
            #expect(restoreDoor == "Restore Field Guide\u{2026}", "the Help menu's real label (VX-602)")
            #expect(shown[4] == "Everything in this book is safe to play with. Cut it up, rewrite it, "
                    + "delete it. Help \u{25B8} \(restoreDoor) replaces the whole book with a pristine copy "
                    + "whenever you want one. Nothing you do here can touch your own writing.",
                    "the safety promise names the door she will find")
            #expect(lesson[5] == [
                "I built Variorum with a simple goal: to be able to create multiple different versions of "
                    + "a block of text. I call these versions takes, borrowing from the film world. The icon "
                    + "to the right of this block is the take icon - click on it.",
                "You found it! :D",
                "Now click on Open Takes mode in the top bar of this modal.",
            ], "her take-icon block, verbatim, and her two takes, in her order")
            #expect(shown[6] == "While Write is meant to behave like a simple and elegant editor, Takes is "
                    + "where complexity thrives. Click on \u{201C}expand all\u{201D} at the top of Takes.")
            let takesOrdinal = try #require(PostMode.allCases.firstIndex(of: .takes)) + 1
            let takesKey = "\u{2318}\(takesOrdinal)"
            let helperKey = try #require(CapabilityRegistry.capability(.helper).shortcutLabel)
            #expect(lesson[7] == [
                "This is the point at which you might be thinking \"cool, but so what?\", unless you're a "
                    + "writer that understands the pain of reworking a particular paragraph to the point of "
                    + "madness. If that isn't you, some of the best use cases I've found for it are in the "
                    + "takes of this paragraph.",
                "This is where things get really fun! You can expand or collapse any take block with the "
                    + "button to the right of it, or use the button at the top. Navigation is fully supported "
                    + "by keyboard shortcuts\u{2014}you can also get to Takes with \(takesKey). Check out all "
                    + "the shortcuts at \(helperKey).",
                "There are four different ways to see your takes and work with them. Test each of them out "
                    + "now by changing \u{201C}style\u{201D} at the top bar of this note. While each is useful "
                    + "for something different, I\u{2019}m particularly fond of margin grid for quick notes.",
            ], "her \u{201C}so what?\u{201D} block and her two takes, the chords the registry's")
            #expect(shown[8].hasPrefix("Two companions to know from the start."))
            #expect(Array(shown[9...12]) == TutorialSeeder.startHerePassages,
                    "the four Start Here passages, byte for byte and in order (R-105-7)")
            #expect(shown[13] == "In the book itself, the chapters are listed on the left, each an interactive "
                    + "guide, and from inside a note the book glyph above the page takes you back there, at "
                    + "that very note. Read in order, or jump to what itches. When something in a lesson "
                    + "doesn't behave as the words promise, that is a bug in the app, not in you.",
                    "the closer reads true from inside the note too (F-3)")
            for (index, fan) in lesson.enumerated() where index != 5 && index != 7 {
                #expect(fan.count == 1, "block \(index + 1) holds one take")
            }
            // The protection chapter's lesson still LEADS with the same four (unchanged — they read twice).
            let key = try await prose(db, guideID, ProtectionWords.guideKeyLessonTitle)
            #expect(key.hasPrefix(TutorialSeeder.startHerePassages.joined(separator: "\n\n")))
        }
    }

    /// **The chrome her draft names, from each door's own home** (the H
    /// pattern — so a rename turns the lesson RED): Write's take icon opens the
    /// take panel, whose top bar holds "Open Takes mode"; Takes' header holds
    /// "expand all" in every style and the "style:" menu of FOUR styles, one of
    /// them "Margin grid"; the per-block ⑂ button sits at each block's right.
    /// RED ON OLD only if a door moves or is renamed — a currency net.
    @Test func theStartHereLessonsChromeWordsAreTheBuildsOwn() throws {
        let panel = try AppSource.read("Variorum/Features/Takes/WriteTakesPanel.swift")
        #expect(panel.contains("Button(\"Open Takes mode\")"), "the take panel's top-bar door")
        let board = try AppSource.read("Variorum/Features/Takes/TakesBoardView.swift")
        #expect(board.contains("Button(tokens.chromeLabel(\"expand all\"))"), "Takes' expand all")
        #expect(board.contains("VoicedMenu(tokens: tokens, label: \"style: \\(styleName)\")"), "the style menu")
        #expect(board.contains("styleOption(\"Margin grid\", .marginGrid)"), "margin grid is a style")
        #expect(FanStyle.allCases.count == 4, "four different ways to see your takes")
        let editor = try AppSource.read("Variorum/Features/Editor/EditorView.swift")
        #expect(editor.contains("model.openFan(blockID: blockID)"), "Write's take icon opens the take panel")
        #expect(editor.contains("WriteTakesPanel("), "…which is the panel with the Takes door")
    }

    /// **The road from the book into the note, from each door's own home**
    /// (ladder round 1, MAJOR-1, reshaped by R-105-10 — the BUILD-VERIFY done
    /// from the Outline). The guide opens on its OUTLINE (a working book's
    /// default mode), where each note is a card whose body and "open ↗" open it
    /// (the expanded header carries the same "open ↗" beside the title); the
    /// door lands in Write, on the note's own page — the lesson's first ask.
    /// Why the takes moment wants the note: in the book no note detail is
    /// mounted, so the take panel's "Open Takes mode" and ⌘2 refuse ("the
    /// modes live inside a note" — `requestMode`'s arm with no `applyMode`),
    /// and the panel offers neither "expand all" nor "style". The closer's way
    /// back: a note's context bar wears the book glyph, which opens its one
    /// book at that note. A currency net — RED if a door is renamed or moved,
    /// if the guide stops opening on its Outline, or if `requestMode` stops
    /// refusing without a mounted note (then revisit the lesson's first ask).
    @Test func theStartHereLessonsRoadOutOfTheOutlineIsTheBuildsOwn() async throws {
        try await withGuide { _, db, guideID in
            let guide = try #require(try await db.read { try Reading.fetchOne($0, key: guideID) })
            #expect(BookStructureModel.defaultMode(for: guide) == .outline,
                    "the guide opens on its Outline (a working book)")
        }
        #expect(NoteBoxCopy.openDoor == "open \u{2197}", "the book's word for its open door")
        let book = try AppSource.read("Variorum/Features/BookView/BookView.swift")
        #expect(book.contains("Button(tokens.chromeLabel(\"open \u{2197}\")) { onOpenInWrite(entry.postID) }"),
                "the open door stands beside each note's title in the Outline")
        #expect(book.contains("road(BookOpenDoor.Landing(postID: postID, mode: .write))"),
                "…and lands in Write, on the note's own page")
        #expect(book.contains("Open this note in the full editor"), "the door's own help says \u{201C}full editor\u{201D}")
        let router = try AppSource.read("Variorum/Registry/CommandRouter.swift")
        #expect(router.contains("guard let applyMode else {\n            refuse?(CapabilityRegistry.capability(.switchMode).unavailableNote)"),
                "without a mounted note a mode request refuses — why the road is needed")
        let panel = try AppSource.read("Variorum/Features/Takes/WriteTakesPanel.swift")
        #expect(!panel.contains("expand all") && !panel.contains("label: \"style:"),
                "the in-place take panel offers neither expand all nor the style menu")
        #expect(book.contains("Button {\n            onOpenInWrite(entry.postID)\n        } label: {"),
                "the collapsed card's body is the open door too (\u{201C}clicking it\u{201D})")
        #expect(ContextBarDoors.iconRow(isNote: true).contains(.book), "a note's context bar wears the book glyph")
        #expect(ContextBarDoors.bookClick(bookCount: 1, commandHeld: false) == .open,
                "…which opens its one book, at that note (the closer's way back)")
    }
}
