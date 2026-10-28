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
        // The launch gate (batch A's rig diagnosis): never pump the run loop
        // into the test host's own launch.
        await HostLaunchSettle.wait()
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
    /// (VX-594, a JUSTIFIED EDIT: the list grew its branch row — R-601-4's
    /// "New branched take" — at its head; the lock row's index moved with it.)
    @Test func theCardMenuIsOneListWithTheRegistrysOwnWords() throws {
        var pressed: [String] = []
        let unlocked = TakeCardMenu.rows(TakeCardActs(
            locked: false, branch: { pressed.append("branch") },
            archive: { pressed.append("archive") }, label: { pressed.append("label") },
            toggleLock: { pressed.append("lock") }, delete: { pressed.append("delete") }))
        #expect(unlocked.map(\.id) == TakeCardMenu.capabilities,
                "the rendered list and the declared list are the same list")
        #expect(unlocked.map(\.title) == [
            TakeCardMenuCopy.newBranchedTake,
            TakeCardMenuCopy.archiveTake, TakeCardMenuCopy.labelTake,
            TakeCardMenuCopy.lockVerb(locked: false), TakeCardMenuCopy.deleteTake,
        ])
        #expect(unlocked.last?.destructive == true, "delete is the destructive row")
        // Which way the lock points is the TAKE's fact, not the menu's.
        let locked = TakeCardMenu.rows(TakeCardActs(
            locked: true, branch: {}, archive: {}, label: {}, toggleLock: {}, delete: {}))
        let lockRow = try #require(TakeCardMenu.capabilities.firstIndex(of: .lockTake))
        #expect(locked[lockRow].title.contains("Unlock"), "a locked take offers Unlock")
        #expect(unlocked[lockRow].title.contains("Lock")
                && !unlocked[lockRow].title.contains("Unlock"))
        // The rows are the acts, not a label list (P-2: fire-and-DO).
        for row in unlocked { row.act() }
        #expect(pressed == ["branch", "archive", "label", "lock", "delete"])
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

            // Exactly what the card builds — the row's own act (VX-594: the
            // card's wiring is the model's ONE copy now, so the pin presses it).
            let spareTake = try #require(
                model.projection.fans[fixture.blockID]?.first { $0.id == spare })
            let rows = TakeCardMenu.rows(
                model.cardActs(for: spareTake, columnID: TakesViewModel.takesFanColumnID))
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

    // MARK: - VX-594 (R-601-4) — "New branched take" on the card, and ⌘T
    //         follows the caret
    //
    // THE PROBE (the batch B record): on the pre-fix tree the card ⌄ menu
    // carried Archive · Label · Lock · Delete and NO branch row, and a fan
    // card's pane carries no Variorum context menu (only the ARTICLE cell's
    // right-click offers "＋ New take — branch of this one", and the article
    // shows the CHOSEN take) — so a not-chosen take had no door that branched
    // from IT without first clicking into it. The ⌘T family's target was
    // traced to ALREADY follow the caret on every surface that hosts it (the
    // board's and the Lenses board's `.branch` arms branch `focusedPane`'s
    // take, Write's panel the ring's take else the shown one, the Takes bar's
    // "+ take" and block ▾ row the focused pane's take) — the ⌘T guards below
    // pin her confirmed semantics and are predicted GREEN on the pre-fix
    // tree: that half of the member is HOLLOW (recorded, nothing built).

    /// **RED ON OLD (the row removed): a live card offers the branch door**,
    /// on both live-card shapes (the two door pins above assert the whole
    /// grammar, which now includes it; this one names the row).
    @Test(arguments: [FanStyle.stack, .carousel])
    func aLiveCardsMenuOffersNewBranchedTake(style: FanStyle) async throws {
        try await withBloomedBoard(style: style) { _, _, doors, hosting in
            #expect(panes(in: hosting).count >= 2,
                    "non-vacuity: the fan really bloomed (\(panes(in: hosting).count) panes)")
            #expect(doors.rendered.contains(.newTake),
                    "the card's ⌄ menu offers \"New branched take\" (rendered: \(doors.rendered))")
        }
        #expect(TakeCardMenuCopy.newBranchedTake.hasPrefix("New branched take"),
                "her ruled words (R-601-4): \(TakeCardMenuCopy.newBranchedTake)")
    }

    /// **RED ON OLD (the row removed): the row BRANCHES FROM THE CARD'S OWN
    /// TAKE** — a not-chosen take is the parent, its words the new take's, the
    /// note's chosen take untouched (minting never chooses — R90), and the
    /// ring lands on the new card where the host renders it. Both hosts: the
    /// board's fan cards and Write's take panel (its own column).
    @Test(arguments: [TakesViewModel.takesFanColumnID, "write-panel-main"])
    func theBranchRowBranchesFromTheCardsOwnNotChosenTake(columnID: String) async throws {
        try await world { session, db, fixture in
            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshTakeCardDefaults())
            defer { model.teardown() }
            if columnID != TakesViewModel.takesFanColumnID {
                model.writePanelBlockID = fixture.blockID  // the panel's one-block scope
            }
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            let chosen = fixture.variantIDs[0]
            let spare = try #require(
                model.projection.fans[fixture.blockID]?.first { $0.id == fixture.variantIDs[1] })
            #expect(model.projection.slots.first?.variantID == chosen,
                    "non-vacuity: the spare is NOT the take the note shows")

            let rows = TakeCardMenu.rows(model.cardActs(for: spare, columnID: columnID))
            let branch = try #require(
                rows.first { $0.id == .newTake },
                "the card's menu carries the branch row (rows: \(rows.map(\.title)))")
            branch.act()
            await pollUntil {
                ((try? await db.read { try Queries.blockFan($0, blockID: fixture.blockID) })?
                    .count ?? 2) == 3
            }

            let fan = try await db.read { try Queries.blockFan($0, blockID: fixture.blockID) }
            let minted = try #require(
                fan.first { !fixture.variantIDs.contains($0.id) }, "a third take was minted")
            #expect(minted.parentVariantId == spare.id,
                    "the parent is the card's own take — the not-chosen spare (\(String(describing: minted.parentVariantId)))")
            #expect(minted.workingText == spare.workingText,
                    "…and it starts as a copy of THAT take's words")
            let shown = try await db.read { try Queries.takesProjection($0, post: fixture.postID) }
            #expect(shown.slots.first?.variantID == chosen, "minting never chooses (R90)")
            await pollUntil { model.authority.livePane?.variantID == minted.id }
            #expect(model.authority.livePane == TakesViewModel.PaneKey(
                columnID: columnID, blockID: fixture.blockID, variantID: minted.id),
                    "the ring lands on the new take's card in this host's own namespace")
        }
    }

    /// **GUARD (predicted green on BOTH trees — the HOLLOW half of R-601-4):
    /// ⌘T follows the caret.** The caret in the not-chosen take's card → the
    /// routed ⌘T branches THAT take; no pane holding the ring → the board's
    /// own refusal speaks and nothing is minted (today's behavior with no
    /// focus — her R-601-4 fallback, unchanged).
    @Test func commandTBranchesTheTakeTheCaretIsInElseRefuses() async throws {
        try await withBloomedBoard(style: .stack) { model, fixture, _, _ in
            let session = model.session
            await pollUntil { session.commandRouter.handlerCount > 0 }
            let spare = fixture.variantIDs[1]
            model.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: fixture.blockID, variantID: spare))
            #expect(model.focusedPane?.variantID == spare, "non-vacuity: the caret is in the spare")

            let db = session.database
            @MainActor func fan() async -> [Variant] {
                (try? await db.read { try Queries.blockFan($0, blockID: fixture.blockID) }) ?? []
            }
            #expect(session.commandRouter.dispatch(.takes(.branch)), "the board handles ⌘T")
            await pollUntil { await fan().count == 3 }
            let minted = try #require(
                await fan().first { !fixture.variantIDs.contains($0.id) }, "⌘T minted a take")
            #expect(minted.parentVariantId == spare,
                    "⌘T with the caret in a not-chosen take branches THAT take")

            // The guard: no ring, no guess — the refusal, nothing minted.
            model.blur()
            #expect(model.focusedPane == nil)
            #expect(session.commandRouter.dispatch(.takes(.branch)))
            await pollUntil { model.status != nil }
            let status = try #require(model.status)
            #expect(status.isRefusal, "with no take holding the caret ⌘T refuses (\(status.text))")
            try? await Task.sleep(for: .milliseconds(200))
            #expect(await fan().count == 3, "and nothing was minted")
        }
    }

    /// **GUARD (predicted green on BOTH trees): Write's take panel's ⌘T follows
    /// the ring** — the caret in the panel's not-chosen card branches THAT
    /// take (the panel's own handler, the LIFO top while it is up).
    @Test func theWritePanelsCommandTBranchesTheTakeTheRingIsIn() async throws {
        await HostLaunchSettle.wait()
        try await world { session, db, fixture in
            let model = TakesViewModel(
                session: session, postID: fixture.postID,
                defaults: freshTakeCardDefaults())
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: WriteTakesPanel(
                session: session, postID: fixture.postID, blockID: fixture.blockID,
                model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 700, height: 500)
            window.contentView = hosting
            defer {
                window.orderOut(nil)
                window.close()
                model.teardown()
            }
            await settle(window, hosting, until: {
                session.commandRouter.handlerCount > 0 && !model.projection.slots.isEmpty
            })
            #expect(session.commandRouter.handlerCount > 0, "non-vacuity: the panel registered")
            let spare = fixture.variantIDs[1]
            model.focus(TakesViewModel.PaneKey(
                columnID: "write-panel-main", blockID: fixture.blockID, variantID: spare))
            #expect(model.focusedPane?.variantID == spare, "non-vacuity: the ring is in the spare")

            #expect(session.commandRouter.dispatch(.takes(.branch)))
            await pollUntil {
                ((try? await db.read { try Queries.blockFan($0, blockID: fixture.blockID) })?
                    .count ?? 2) == 3
            }
            let fan = try await db.read { try Queries.blockFan($0, blockID: fixture.blockID) }
            let minted = try #require(fan.first { !fixture.variantIDs.contains($0.id) })
            #expect(minted.parentVariantId == spare,
                    "the panel's ⌘T branches the take the ring is in, not the shown one")
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

    // MARK: - VX-155 — the popped menu's rows read at menu size, never mini

    /// **RED ON OLD (VX-155, her 2026-10-11 report with a screenshot):** the
    /// component sized its ⋯ chrome with `.controlSize(.mini)` ON THE MENU,
    /// and on macOS the popped `NSMenu` inherits the control's size — so all
    /// four rows (Archive · Label · Lock · Delete) rendered in mini type in
    /// Write's panel and on the board's cards. The fix moves the mini metric
    /// onto the LABEL's font alone; no control size may ride the `Menu`
    /// again, or the rows shrink with it. A source lint, because a SwiftUI
    /// `Menu` is not an `NSView` a pin can find (this suite's own header);
    /// the rows' readable size is walked.
    @Test func thePoppedMenuNeverInheritsAControlSize() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()  // VariorumTests
                .deletingLastPathComponent()  // App/Variorum
                .appendingPathComponent("Variorum/Features/Takes/TakesShared.swift"),
            encoding: .utf8)
        let sized = source.components(separatedBy: ".controlSize(").count - 1
        #expect(sized == 0,
                "the card menu carries no control size — the popped rows would inherit it (\(sized) left)")
        // Control: the mark's label still carries the chrome's own small
        // metric, so the chrome the cards lay out around did not grow with
        // the fix. (A JUSTIFIED EDIT at VX-223: the class's fix moved into ONE
        // chrome component, `ChromePullDown`, whose metrics live in
        // `ChromePullDownMetric` — the card names its metric now, the
        // indicator-sized chevron of P-VX223-a, rather than spelling
        // `systemFontSize(for: .mini)` itself.)
        #expect(source.contains("ChromePullDownMetric."),
                "the mark keeps the chrome's small metric on its own font")
    }

    /// The lint above holds the SOURCE shape; this holds the BEHAVIOUR the
    /// Pro review measured (MINOR-3): the card menu is an `NSPopUpButton`
    /// underneath, and the font that drives its popped rows is the standard
    /// menu size — never the mini control's 9 pt (her screenshot's bug).
    /// RED ON OLD by the mechanism itself: with `.controlSize(.mini)` on
    /// the Menu the control's font was 9 pt.
    @Test func thePoppedRowsReadAtMenuSizeNotMini() async throws {
        let hosting = NSHostingView(rootView: TakeCardMenu(acts: TakeCardActs(
            locked: false, branch: {}, archive: {}, label: {}, toggleLock: {}, delete: {})))
        hosting.frame = NSRect(x: 0, y: 0, width: 120, height: 40)
        let window = NSWindow(
            contentRect: hosting.frame, styleMask: [.borderless],
            backing: .buffered, defer: false)
        window.contentView = hosting
        hosting.layoutSubtreeIfNeeded()
        var found: NSPopUpButton?
        for _ in 0..<100 {
            if let popUp = Self.popUp(in: hosting) { found = popUp; break }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
        let popUp = try #require(found, "the card menu is an NSPopUpButton underneath")
        let size = popUp.font?.pointSize ?? 0
        #expect(size >= NSFont.systemFontSize(for: .regular),
                "the popped rows' font is menu-sized, not mini (read \(size) pt)")
    }

    private static func popUp(in view: NSView) -> NSPopUpButton? {
        if let popUp = view as? NSPopUpButton { return popUp }
        for sub in view.subviews {
            if let popUp = popUp(in: sub) { return popUp }
        }
        return nil
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
