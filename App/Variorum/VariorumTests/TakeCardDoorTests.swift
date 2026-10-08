//
//  TakeCardDoorTests.swift
//  VariorumTests
//
//  13u3 UNIT H — **the Takes board's live-card delete door, and the words
//  that send a reader to it** (the UNIT E hand-up, adjudicated after E).
//
//  THE TRACED MECHANISM, measured on `4f069b1b` before a production line
//  changed: on the Takes board a LIVE take card is
//  `TakeCardFrame` → `TakeChooseHeader` (a choose band, the take's label, the
//  ◀ ▶ reorder arrows) + `PaneSurfaceView` with `menuItems: nil` — so the
//  card carried NO act menu and its pane carried no Variorum context menu
//  either. The board's ARCHIVED cards have had Unarchive + Delete since 13b
//  3D, and Write's panel has carried Archive · Label · Lock · Delete on every
//  card since Phase 7. A spare take SEEN on the board therefore could not be
//  deleted where it was seen; the only roads were to leave for Write (⌘⇧T) or
//  to right-click the ARTICLE cell, which acts on the take the note shows
//  rather than the card you pointed at. Her F1 ruling — *"Write's panel ⋯
//  carries Archive · Label · Lock · Delete — Takes mode's card grammar must
//  match"* — reached the board's article cell at the post-13l polish round
//  and never reached its cards.
//
//  RED ON THE PRE-FIX TREE:
//  · the two door cells — the oracle records NOTHING from a live card,
//    because no live card renders a menu;
//  · the refusal cell — `OpsRefusalCopy.message` has no case for
//    `variantIsChosen`, so the most likely press on this new door printed
//    `Refused: variantIsChosen(id: "…")`, a raw enum dump with a UUID in it,
//    on a door Write's panel has offered since Phase 7;
//  · the words cell — the lesson said "⋯ menu ▸ Delete" without naming the
//    row or the place, and the surface a reader is most likely to be standing
//    on had no ⋯ at all.
//
//  Why a DEBUG door oracle rather than a click: a SwiftUI `Menu` on a whole
//  board is not an `NSView` a pin can find, and a hosted board builds no
//  accessibility tree in the test host (measured at 17p batch a — the
//  `TakesEmptyStateDoors` precedent). The menu reports the list it actually
//  built, on the real board, in the real mount; the press itself is walked.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@MainActor
@Suite("The take card's act menu, and the words that name it (13u3 UNIT H)", .serialized)
struct TakeCardDoorTests {
    // MARK: - Harness

    private struct Fixture {
        let postID: String
        let blockID: String
        /// The block's takes in fan order: [0] is chosen, [1] is the spare.
        let variantIDs: [String]
    }

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func world<T>(
        _ body: @MainActor (AppSession, AppDatabase, Fixture) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a fanned note")
            let minted = try session.operations.newBlock(
                in: post.id, text: "The rain came in from the sea without an opinion.")
            let spare = try session.operations.branchVariant(
                minted.block.id, from: minted.variant.id)
            try session.operations.autosave(
                spare.id, text: "The spare take, here to be deleted.", charDelta: 36)
            return try await body(
                session, db,
                Fixture(
                    postID: post.id, blockID: minted.block.id,
                    variantIDs: [minted.variant.id, spare.id]))
        }
    }

    /// Mount the REAL Takes board on the fixture in `style`, bloom the fanned
    /// block, and hand the body the oracle reader for this mount's own scope.
    private func withBloomedBoard(
        style: FanStyle,
        _ body: @MainActor (
            _ model: TakesViewModel, _ fixture: Fixture,
            _ doors: TakeCardDoors.Reader, _ hosting: NSView
        ) async throws -> Void
    ) async throws {
        try await world { session, db, fixture in
            try session.operations.setFanStyle(style)
            // Row 50: this mount's OWN reports, cleared BEFORE the mount so a
            // stale one cannot satisfy a pin and a fresh one is never wiped.
            let doors = TakeCardDoors.reader(session.debugProbeScope)
            doors.reset()

            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshTakeCardDefaults())
            defer { model.teardown() }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            #expect(model.projection.fanStyle == style, "the store carries the style under test")

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1200, height: 900),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(
                rootView: TakesBoardView(
                    session: session, postID: fixture.postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 900)
            window.contentView = hosting
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
            model.toggleExpanded(fixture.blockID)
            await settle(window, hosting, until: { !doors.rendered.isEmpty }, maxTurns: 20)
            try await body(model, fixture, doors, hosting)
        }
    }

    // MARK: - The door (RED on the pre-fix board: nothing is recorded)

    /// **The STACK style** — `CollapsibleTakeCard`, the card shape whose
    /// header is built directly.
    @Test func theBoardsLiveTakeCardCarriesTheFourActs() async throws {
        try await withBloomedBoard(style: .stack) { _, _, doors, hosting in
            #expect(panes(in: hosting).count >= 2,
                    "non-vacuity: the fan really bloomed (\(panes(in: hosting).count) panes)")
            #expect(doors.rendered.contains(.deleteTake),
                    "a LIVE take card offers Delete where the take is seen (rendered: \(doors.rendered))")
            #expect(Set(TakeCardMenu.capabilities).isSubset(of: doors.rendered),
                    "…and the whole F1 card grammar with it (rendered: \(doors.rendered))")
        }
    }

    /// **The CAROUSEL style** — `takeMiniPane`, the OTHER card shape, which
    /// slot split and the margin-grid rail also compose. Two shapes is the
    /// whole set of live-card compositions on this board.
    @Test func theOtherLiveCardShapeCarriesThemToo() async throws {
        try await withBloomedBoard(style: .carousel) { _, _, doors, hosting in
            #expect(panes(in: hosting).count >= 2,
                    "non-vacuity: the fan really bloomed (\(panes(in: hosting).count) panes)")
            #expect(Set(TakeCardMenu.capabilities).isSubset(of: doors.rendered),
                    "the mini-pane card wears the same menu (rendered: \(doors.rendered))")
        }
    }

    // MARK: - Declared ⇔ rendered, PER SURFACE (the 18f ladder's R3-3 shape)

    /// The union walk (`theSurfacesRenderExactlyTheDeclaredSurfaceActs`)
    /// could never have caught this: `WriteTakesPanel` alone satisfied all
    /// four ids, so the board's cards could render none of them and the
    /// registry stayed green. The guard that bites is PER SURFACE.
    @Test func bothTakesSurfacesDeclareTheOneCardGrammar() {
        let grammar = Set(TakeCardMenu.capabilities)
        #expect(grammar.isSubset(of: Set(WriteTakesPanel.surfaceCapabilities)),
                "Write's panel: \(WriteTakesPanel.surfaceCapabilities)")
        #expect(grammar.isSubset(of: Set(TakesBoardView.surfaceCapabilities)),
                "the Takes board: \(TakesBoardView.surfaceCapabilities)")
        // Each act is declared with the `.surface` door it is rendered
        // through, and is take-scoped (R118: never a Write privilege).
        for id in TakeCardMenu.capabilities {
            let act = CapabilityRegistry.capability(id)
            #expect(act.scope == .take, "\(id) is take-scoped")
            #expect(act.doors.contains(.surface), "\(id) declares the .surface door")
            #expect(act.takesAccess == .native, "\(id) — R118: not a Write privilege")
        }
    }

    /// ONE list, built once: the rows the menu renders carry the registry's
    /// own titles, in the F1 order, and the lock row says which way it points.
    @Test func theCardMenuIsOneListWithTheRegistrysOwnWords() {
        var pressed: [String] = []
        let unlocked = TakeCardMenu.rows(TakeCardActs(
            locked: false,
            archive: { pressed.append("archive") }, label: { pressed.append("label") },
            toggleLock: { pressed.append("lock") }, delete: { pressed.append("delete") }))
        #expect(unlocked.map(\.id) == TakeCardMenu.capabilities,
                "the rendered list and the declared list are the same list")
        #expect(unlocked.map(\.title) == [
            TakeCardMenuCopy.archiveTake, TakeCardMenuCopy.labelTake,
            TakeCardMenuCopy.lockVerb(locked: false), TakeCardMenuCopy.deleteTake,
        ])
        #expect(unlocked.last?.destructive == true, "delete is the destructive row")
        // Which way the lock points is the TAKE's fact, not the menu's.
        let locked = TakeCardMenu.rows(TakeCardActs(
            locked: true, archive: {}, label: {}, toggleLock: {}, delete: {}))
        #expect(locked[2].title.contains("Unlock"), "a locked take offers Unlock")
        #expect(unlocked[2].title.contains("Lock") && !unlocked[2].title.contains("Unlock"))
        // The rows are the acts, not a label list (P-2: fire-and-DO).
        for row in unlocked { row.act() }
        #expect(pressed == ["archive", "label", "lock", "delete"])
    }

    /// **Fire-and-DO, through the board's own acts.** The row does not merely
    /// exist: pressing it runs the model door, the take is tombstoned, and
    /// the block keeps the take the note shows (I10 untouched).
    @Test func theDeleteRowRunsTheModelDoorAndTheSpareTakeGoes() async throws {
        try await world { session, db, fixture in
            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshTakeCardDefaults())
            defer { model.teardown() }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            let spare = fixture.variantIDs[1]
            #expect(model.projection.fans[fixture.blockID]?.count == 2, "non-vacuity: two takes")

            // Exactly what the card builds — the row's own act.
            let rows = TakeCardMenu.rows(TakeCardActs(
                locked: false,
                archive: {}, label: {},
                toggleLock: {},
                delete: { Task { await model.deleteTake(spare) } }))
            let delete = try #require(rows.first { $0.id == .deleteTake })
            delete.act()
            await pollUntil {
                ((try? await db.read { try Queries.blockFan($0, blockID: fixture.blockID) })?
                    .count ?? 2) == 1
            }

            let fan = try await db.read { try Queries.blockFan($0, blockID: fixture.blockID) }
            #expect(fan.map(\.id) == [fixture.variantIDs[0]],
                    "the spare is gone; the take the note shows stays (I10)")
            let deleted = try await db.read { try Variant.fetchOne($0, key: spare) }
            #expect(deleted?.deletedAt != nil, "a tombstone — Put back is real")
        }
    }

    // MARK: - The refusal this door meets most (RED: a raw enum dump)

    /// **`variantIsChosen` had no words.** `deleteVariant` checks the chosen
    /// pointer BEFORE the last-active guard, so the commonest press on a take
    /// card's Delete — the take the note is showing, and on a one-take block
    /// the ONLY take — raised this, and `OpsRefusalCopy.message` fell through
    /// to `default: "Refused: \(error)"`. She met a raw enum with a UUID in
    /// it, on a door Write's panel has offered since Phase 7.
    @Test func theChosenTakesRefusalSpeaksInsteadOfDumpingTheEnum() {
        let words = OpsRefusalCopy.message(
            for: OperationError.variantIsChosen(id: "8C4A1E32-DEAD-BEEF-0000-000000000001"))
        #expect(!words.hasPrefix("Refused:"), "a sentence, not the raw enum (\(words))")
        #expect(!words.contains("8C4A1E32"), "and never a UUID in her face (\(words))")
        #expect(words.lowercased().contains("choose"),
                "it names the road — choose another take first (\(words))")
        // The one-take block is the same refusal (the chosen check fires
        // first), so the words must answer that reader too.
        #expect(words.lowercased().contains("block"),
                "…and the road for a block with only this take (\(words))")
    }

    /// **The rename door's two race refusals speak too** (13u3 ladder round
    /// 1, R1-4 — the same enum-dump class, the two stragglers
    /// `renameCommitPoint` can reach when the take dies or the moment is
    /// purged under the open ask): a sentence, never `Refused: …(id: "…")`.
    @Test func theRenameDoorsRaceRefusalsSpeakInsteadOfDumpingTheEnum() {
        let deadTake = OpsRefusalCopy.message(
            for: OperationError.variantNotFound(id: "8C4A1E32-DEAD-BEEF-0000-000000000002"))
        #expect(!deadTake.hasPrefix("Refused:"), "a sentence, not the raw enum (\(deadTake))")
        #expect(!deadTake.contains("8C4A1E32"), "never a UUID in her face (\(deadTake))")
        #expect(deadTake.lowercased().contains("take"), "it names what went (\(deadTake))")

        let deadMoment = OpsRefusalCopy.message(
            for: OperationError.commitNotFound(id: "8C4A1E32-DEAD-BEEF-0000-000000000003"))
        #expect(!deadMoment.hasPrefix("Refused:"),
                "a sentence, not the raw enum (\(deadMoment))")
        #expect(!deadMoment.contains("8C4A1E32"), "never a UUID in her face (\(deadMoment))")
        #expect(deadMoment.lowercased().contains("moment"),
                "it names what went in the savepoint family's own word (\(deadMoment))")
    }

    /// The refusal reaches the surface through the model's own door, worded —
    /// not just in the copy table.
    @Test func theBoardSpeaksThatRefusalWhenTheShownTakeIsDeleted() async throws {
        try await world { session, db, fixture in
            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshTakeCardDefaults())
            defer { model.teardown() }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            await model.deleteTake(fixture.variantIDs[0])   // the take the note shows
            let status = try #require(model.status)
            #expect(status.isRefusal, "a refusal, classed as one")
            #expect(!status.text.hasPrefix("Refused:"), "in words (\(status.text))")
            let fan = try await db.read { try Queries.blockFan($0, blockID: fixture.blockID) }
            #expect(fan.count == 2, "and nothing was deleted")
        }
    }

    // MARK: - The words (RED: the lesson named neither the row nor the place)

    /// **The pin that holds the words to a door that exists.** The takes-delete
    /// lesson interpolates the ROW's own title and the menu's own glyph, so a
    /// rename of the row moves the lesson with it — and it names WHERE the ⋯
    /// lives, which is what the shipped sentence never did.
    @Test func theLessonNamesTheRowByItsOwnTitleAndSaysWhereTheMenuLives() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_950_400)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let bookID = try await TutorialSeeder.restore(session: session)
            let lesson = try #require(try await db.read { db -> String? in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT c.id FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                        """,
                    arguments: [bookID, "what a block leaves behind"])
            })
            let slots = try await db.read { try Queries.renderPost($0, containerID: lesson) }
            let prose = try #require(slots.first {
                $0.text?.hasPrefix("Deleted takes wait") == true  // 13s-b triage landing: sentence case
            }).text ?? ""

            #expect(prose.contains(TakeCardMenuCopy.menuGlyph),
                    "the glyph is the menu's own constant")
            #expect(prose.contains(TakeCardMenuCopy.deleteTake),
                    "the row is named by the row's OWN title — \(TakeCardMenuCopy.deleteTake)")
            #expect(prose.contains("Takes"),
                    "…and the lesson names the board, where a reader of the takes chapter is standing")

            // The practice take says where its own ⋯ is, because it is read
            // on whichever surface she opened.
            let host = try #require(slots.first {
                $0.text?.hasPrefix("Deleted takes wait") == true  // 13s-b triage landing: sentence case
            })
            let fan = try await db.read { try Queries.blockFan($0, blockID: host.blockID) }
            let spare = try #require(fan.first { $0.workingText.hasPrefix("the spare take") })
            #expect(spare.workingText.contains(TakeCardMenuCopy.menuGlyph))
            #expect(spare.workingText.contains("card"),
                    "the practice take names the CARD's menu, not a menu somewhere (\(spare.workingText))")
        }
    }

    /// **THE ⋯ SWEEP'S OTHER FIND** (the brief's R3-2 rule: no single-string
    /// grep finds prose variants — walk the chapter's cards). Four sentences
    /// in the seeder name a ⋯ menu; three were true, and this one named its
    /// row *"Move out to a pool"*, the name it carried before the Snippets
    /// vocabulary ruling. Both renderers of that row hand-typed the title, so
    /// there was nothing for a lesson to quote; it quotes the one constant
    /// now, and the conceptual sentence above it says the same word.
    @Test func theTrioLessonNamesTheMoveOutRowTheMenuActuallyHas() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_950_400)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let bookID = try await TutorialSeeder.restore(session: session)
            let lesson = try #require(try await db.read { db -> String? in
                try String.fetchOne(
                    db,
                    sql: """
                        SELECT c.id FROM reading_post rp
                        JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                        WHERE rp.reading_id = ? AND rp.deleted_at IS NULL AND c.title = ?
                        """,
                    arguments: [bookID, "archive \u{B7} delete \u{B7} scraps"])
            })
            let prose = (try await db.read { try Queries.renderPost($0, containerID: lesson) })
                .compactMap(\.text).joined(separator: "\n")
            #expect(prose.contains(SnippetsCopy.moveOutRow),
                    "the row is quoted from its own constant")
            #expect(!prose.contains("Move out to a pool"),
                    "and the name the menu dropped is gone from the lesson")
            #expect(!prose.contains("MOVE OUT TO A POOL"),
                    "…including the sentence that sets the act up")
        }
    }

    // MARK: - Small helpers

    private func pollUntil(_ condition: @MainActor () async -> Bool, turns: Int = 200) async {
        for _ in 0..<turns {
            if await condition() { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }
}

/// A PRIVATE defaults domain per model: the board's per-block memories
/// persist, and `$0.uuid = .incrementing` gives every test world the same
/// post id (the `TakesCardHeightTests` finding, and UNIT G's hand-up about
/// the 178 shared `surfaceSize.*` keys).
private func freshTakeCardDefaults() -> UserDefaults {
    let suite = "TakeCardDoorTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}
