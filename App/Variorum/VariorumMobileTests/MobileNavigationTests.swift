//
//  MobileNavigationTests.swift
//  VariorumMobileTests
//
//  Round 2, batch 10 — NAVIGATION. Her three asks (2026-08-23,
//  `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`):
//  the shelf↔library swipe (*"it's killing me"*), a starred page instead
//  of the section *"above the shelf"* she dislikes, and the two doors
//  inside a book the Mac already has.
//
//  **ONE suite in this file, deliberately** — the harness trap the round
//  records (`MobileTakesBrowserTests.swift` declares two, and filtering by
//  the first name silently runs a subset).
//
//  **What the harness honestly reaches, said plainly.** A real pan cannot
//  be synthesized in process: `accessibilityActivate()` is UIKit's
//  activation dispatch, not a touch stream, and there is no in-process road
//  to a `DragGesture`'s recognizer (the driver's header records the same
//  limitation for `Menu` rows and `UIAlertController` buttons). So the
//  swipe is pinned at **both ends and not in the middle**: its ARITHMETIC —
//  the latch, the walls, where a drag lands — is pinned as a pure brain,
//  and the SEAM the gesture calls (`selectPage`, reached through the tab
//  bar's own doors on the real mounted shell) is driven for real. **The
//  gesture RECOGNITION itself — that a finger on the shelf reaches this
//  brain, and that a vertical scroll does not — rides the device queue.**
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
@Suite("Mobile navigation — the band, the starred page, the book's doors (batch 10)")
struct MobileNavigationTests {

    // MARK: - Deliverable 1 · the band's arithmetic

    /// **THE ARRANGEMENT** (PROVISIONAL — the ruled shape): Starred ‹ Shelf ›
    /// Library, with the shelf at home. At rest each neighbour sits EXACTLY
    /// one screen away, which is what makes "nothing but the current page is
    /// visible" a fact about the offsets rather than about the clip.
    @Test func theBandPutsTheShelfAtHomeBetweenStarredAndLibrary() {
        #expect(MobileShellBand.pages == [.starred, .shelf, .library])
        #expect(MobileShellBand.home == .shelf)

        let width: CGFloat = 393
        #expect(MobileShellBand.offset(
            for: .shelf, current: .shelf, drag: 0, width: width) == 0)
        #expect(MobileShellBand.offset(
            for: .starred, current: .shelf, drag: 0, width: width) == -width,
                "starred waits one screen to the LEFT of home")
        #expect(MobileShellBand.offset(
            for: .library, current: .shelf, drag: 0, width: width) == width,
                "library waits one screen to the RIGHT of home")
        // And from an end page, home is one screen away in the other
        // direction — the band is a line, not a carousel.
        #expect(MobileShellBand.offset(
            for: .shelf, current: .library, drag: 0, width: width) == -width)
        #expect(MobileShellBand.offset(
            for: .starred, current: .library, drag: 0, width: width) == -2 * width)

        // **A ZERO-WIDTH LAYOUT PASS PARKS EVERYTHING AT HOME** (the cold
        // review's NIT 2 — the guard `clampedDrag` already carried and this
        // one did not). Without it every page's offset collapses to the live
        // drag, drawing all three roots stacked for that frame. The drag can
        // be non-zero here precisely because it was clamped against the
        // PREVIOUS pass's real width.
        // RED-ON-OLD: drop the guard and both return -120.
        #expect(MobileShellBand.offset(
            for: .library, current: .shelf, drag: -120, width: 0) == 0)
        #expect(MobileShellBand.offset(
            for: .starred, current: .shelf, drag: -120, width: 0) == 0)
    }

    /// **THE DIRECTION LATCH — why a vertical scroll never pages.**
    ///
    /// The band rides `.simultaneousGesture` over roots that are vertical
    /// `ScrollView`s, so both recognizers see every drag. `engages` is the
    /// whole defence: a drag must be meaningfully horizontal AND
    /// meaningfully more horizontal than vertical.
    ///
    /// RED-ON-OLD: drop the ratio clause (`abs(width) > engageDistance`
    /// alone) and the scroll cases below go red — a finger travelling 200 pt
    /// down and 20 pt sideways would page.
    @Test func aVerticalScrollNeverEngagesTheBand() {
        // A scroll: mostly vertical, with the sideways wobble a real thumb has.
        #expect(!MobileShellBand.engages(CGSize(width: 20, height: 200)))
        #expect(!MobileShellBand.engages(CGSize(width: -30, height: -150)))
        // A diagonal that is not decisively horizontal stays the scroll's.
        #expect(!MobileShellBand.engages(CGSize(width: 40, height: 40)))
        // Too small to be anything yet — the band waits.
        #expect(!MobileShellBand.engages(CGSize(width: 8, height: 0)))
        // A page swipe, in both directions.
        #expect(MobileShellBand.engages(CGSize(width: 80, height: 10)))
        #expect(MobileShellBand.engages(CGSize(width: -80, height: -12)))
    }

    /// **THE ENDS ARE WALLS.** At `Starred` a rightward pull and at
    /// `Library` a leftward one have nowhere to go, so the band does not
    /// move: a surface that slides toward nothing promises a page that
    /// isn't there.
    ///
    /// RED-ON-OLD: return `raw` unclamped and both wall cases go red.
    @Test func theBandsEndsAreWallsNotRubber() {
        let width: CGFloat = 393
        #expect(MobileShellBand.clampedDrag(120, current: .starred, width: width) == 0,
                "nothing lives left of Starred")
        #expect(MobileShellBand.clampedDrag(-120, current: .library, width: width) == 0,
                "nothing lives right of Library")
        // Inward from an end, and either way from the middle, it tracks.
        #expect(MobileShellBand.clampedDrag(-120, current: .starred, width: width) == -120)
        #expect(MobileShellBand.clampedDrag(120, current: .shelf, width: width) == 120)
        #expect(MobileShellBand.clampedDrag(-120, current: .shelf, width: width) == -120)
        // Never further than one screen, whatever the finger did.
        #expect(MobileShellBand.clampedDrag(9_000, current: .shelf, width: width) == width)
    }

    /// **WHERE A DRAG LANDS.** A short drag snaps back; one that crosses the
    /// distance lands; a fast FLICK lands without travelling — and a flick
    /// whose projection disagrees with the finger's own direction lands
    /// nothing, so a spring-back can never page forward.
    @Test func aDragLandsOnlyWhenItCrossesOrIsFlicked() {
        let width: CGFloat = 393
        let far = MobileShellBand.landingDistance(width: width)
        #expect(far == width * MobileShellBand.landingShare)

        // Short of the distance, with no flick: home stays home.
        #expect(MobileShellBand.landing(
            current: .shelf, drag: -(far - 1), predictedEnd: -(far - 1),
            width: width) == .shelf)
        // Across it: the next page.
        #expect(MobileShellBand.landing(
            current: .shelf, drag: -(far + 1), predictedEnd: -(far + 1),
            width: width) == .library)
        #expect(MobileShellBand.landing(
            current: .shelf, drag: far + 1, predictedEnd: far + 1,
            width: width) == .starred)
        // A FLICK: barely moved, but going somewhere.
        #expect(MobileShellBand.landing(
            current: .shelf, drag: -20, predictedEnd: -400, width: width) == .library)
        // A flick whose projection contradicts the finger lands nothing.
        #expect(MobileShellBand.landing(
            current: .shelf, drag: -20, predictedEnd: 400, width: width) == .shelf)
        // The ends refuse to step off the band even on a big drag.
        #expect(MobileShellBand.landing(
            current: .library, drag: -(far * 3), predictedEnd: -(far * 3),
            width: width) == .library)
        #expect(MobileShellBand.landing(
            current: .starred, drag: far * 3, predictedEnd: far * 3,
            width: width) == .starred)
        // A narrow screen keeps a real distance rather than a hair trigger.
        #expect(MobileShellBand.landingDistance(width: 100)
                == MobileShellBand.minimumLandingDistance)
    }

    /// **THE TAB BAR IS THE BAND'S INDEX, ON THE REAL MOUNTED SHELL** — three
    /// doors in band order, each one really moving the band, driven through
    /// `accessibilityActivate()`.
    ///
    /// **WHAT IS OBSERVED, and why it is the selection rather than the page**
    /// (measured while writing this pin, and recorded because it is a fact
    /// about the HARNESS that every shell-mounted absence pin inherits):
    /// `MobileSurfaceDriver`'s walk descends raw `UIView.subviews` and does
    /// not honour `accessibilityElementsHidden`, so **all three roots stay in
    /// the walked tree** even though the product marks the two offscreen ones
    /// hidden and untouchable. Assistive technology sees one page; this
    /// walker sees three. So "which page is showing" is NOT answerable from
    /// the label list, and a pin that read it that way would be measuring the
    /// walker rather than the app.
    ///
    /// What IS answerable, and is exactly the brief's requirement — *"the tab
    /// bar stays authoritative and stays in sync"* — is the SELECTION: the
    /// bar renders `tab`, so the `.isSelected` trait moving is the shell's
    /// own state moving. That state is the single input to
    /// `MobileShellBand.offset`, whose arithmetic is pinned above, so the
    /// chain from a door to a moved band is covered end to end without any
    /// step being asserted twice.
    ///
    /// RED-ON-OLD: with the pre-batch two-door bar the `Starred` activation
    /// returns false and the door is absent.
    @Test func theTabBarCarriesThreeDoorsAndEachOneMovesTheBand() async throws {
        /// Every rendered copy of one door (each root wears its own tab bar,
        /// and they all render the same `tab`), and whether they are selected.
        func selection(
            _ surface: HostedSurface<MobileShellView>, _ label: String
        ) -> (copies: Int, allSelected: Bool, noneSelected: Bool) {
            let doors = surface.visibleElements.filter { $0.accessibilityLabel == label }
            let selected = doors.filter { $0.accessibilityTraits.contains(.selected) }
            return (doors.count, !doors.isEmpty && selected.count == doors.count,
                    selected.isEmpty)
        }

        try await withEditorWorld { session, _ in
            let router = MobileShellRouter()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(30)
                // The three doors exist, and the band's own page is on screen.
                for door in ["Starred", "Shelf", "Library"] {
                    #expect(surface.element(labeled: door) != nil,
                            "labels were \(surface.visibleLabels)")
                }
                #expect(surface.visibleLabels.contains(MobileStarsModel.emptyLine),
                        "the starred page's root really rendered; labels were \(surface.visibleLabels)")

                // HOME.
                #expect(selection(surface, "Shelf").allSelected, "the shelf is home")
                #expect(selection(surface, "Starred").noneSelected)
                #expect(selection(surface, "Library").noneSelected)

                // LEFT, to the page this batch added.
                #expect(surface.activate("Starred"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(30)
                #expect(selection(surface, "Starred").allSelected,
                        "the door moved the band")
                #expect(selection(surface, "Shelf").noneSelected)

                // And all the way RIGHT, across home.
                #expect(surface.activate("Library"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(30)
                #expect(selection(surface, "Library").allSelected)
                #expect(selection(surface, "Starred").noneSelected)

                // Every root wears the bar, so the doors come in threes —
                // stated rather than left as a surprise for the next reader.
                #expect(selection(surface, "Shelf").copies == MobileShellBand.pages.count)
            }
        }
    }

    /// **A PAGE CHANGE IS A LEAVING, AND THE BOX REALLY FILES — MEASURED ON
    /// THE MOUNTED SHELL** (the batch-10 cold review, MINOR 3).
    ///
    /// `selectPage` is the pre-batch tab door's body, moved, so a swipe and a
    /// tap file the quick-note box through the SAME line; the record claimed
    /// A5-8 (*leaving mints and clears*) on that ground and pinned nothing at
    /// the shell. **This lands the reviewer's probe as coverage** — and it
    /// pins BOTH halves of the contract, because the reviewer's own reading
    /// turned out to be the first half:
    ///
    /// · **Navigation never waits on the write.** `selectPage` spawns the
    ///   filing in a `Task`, so in the ACTIVATION'S OWN TURN — before any
    ///   `await` — nothing has filed: `handOffCount` is 0 and the words are
    ///   still in the box. That is the shipped doctrine, deliberately, and it
    ///   is exactly what a probe reading the box in that turn sees.
    /// · **And then it completes.** Once the turn yields, the leaving mints
    ///   (already minted here), flushes, savepoints, clears the box and
    ///   announces the hand-off. **Measured at ~40 ms** — 5 runs, 5 the
    ///   same: `handOffCount 0 → 1`, box `"a thought left in the box"` → `""`.
    ///
    /// The state driven is the one no existing quick-note pin reaches: every
    /// leaving pin in `MobileQuickNoteTests` uses `quietBox` (mint clock
    /// stilled, `postID == nil`), whereas here the REAL clock has already
    /// minted a real note before the page changes.
    ///
    /// Inherited behaviour, now pinned — not batch 10's fix.
    @Test func aPageChangeFilesTheQuickNoteBoxAndThisIsWhatItDoes() async throws {
        try await withEditorWorld { session, db in
            let router = MobileShellRouter()
            let typed = "a thought left in the box"
            func containers() async throws -> Int {
                try await db.read { db in
                    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container") ?? -1
                }
            }
            let before = try await containers()
            try await withHostedSurface(
                MobileShellView(session: session, services: nil, router: router)
            ) { surface in
                await surface.settle(20)
                router.quickNote.text = typed
                // The REAL mint clock (~1 s) — this pin is about the state
                // after it has fired.
                for _ in 0..<200 where router.quickNote.postID == nil {
                    await surface.settle(1)
                }
                #expect(router.quickNote.postID != nil, "the box minted its note")
                #expect(router.quickNote.lastError == nil,
                        "\(router.quickNote.lastError ?? "")")
                let minted = try await containers()
                #expect(minted == before + 1, "a real note exists in the store")

                // THE LEAVING, through the real tab door — the one road a
                // swipe also takes.
                #expect(surface.activate("Library"),
                        "labels were \(surface.visibleLabels)")
                // Same turn, no await: the filing cannot have run yet.
                #expect(router.quickNote.handOffCount == 0,
                        "navigation never waits on the write")
                #expect(router.quickNote.text == typed,
                        "her words are still in the box while the page moves")

                for _ in 0..<200 where router.quickNote.handOffCount == 0 {
                    await surface.settle(1)
                }
                #expect(surface.visibleElements.contains {
                    $0.accessibilityLabel == "Library"
                        && $0.accessibilityTraits.contains(.selected)
                }, "the page really changed")
                #expect(router.quickNote.handOffCount == 1,
                        "the leaving completed and said so")
                #expect(router.quickNote.text.isEmpty, "the box came back empty")
                #expect(router.quickNote.postID == nil, "and owns nothing now")
                let after = try await containers()
                #expect(after == before + 1,
                        "the leaving minted nothing further — the note was already there")
            }
        }
    }

    // MARK: - Deliverable 2 · the starred page

    /// **THE STARRED LIST MOVED — it is on its own page, and it is GONE from
    /// above the shelf** (her words: *"I don't like where it appears above
    /// the shelf, I think it's awkward placing"*).
    ///
    /// Both halves are asserted on REAL MOUNTED SURFACES, and the absence
    /// half is taken over a POPULATED shelf: the shelf still renders its book
    /// row and its own doors in the same walk, so "the starred rows are not
    /// here" cannot be a dead tree reading as an absent door.
    ///
    /// RED-ON-OLD: restore the shelf's `starredSection` and the absence
    /// assertion goes red (the row's composed label carries the note's name).
    @Test func theStarredListLivesOnItsOwnPageAndNotAboveTheShelf() async throws {
        try await withEditorWorld { session, _ in
            let (noteID, bookID) = try await session.runner.run { ops -> (String, String) in
                (try ops.createPost(title: "Harbor").id,
                 try ops.createReading(name: "Poems", kind: .curated).id)
            }
            let stars = MobileStarsModel(session: session)
            await stars.toggle(.post(noteID), from: .library)
            await stars.toggle(.reading(bookID), from: .shelf)
            #expect(stars.items.count == 2)

            // 1 · THE PAGE lists both kinds, each saying what it is.
            let opened = LockIsolatedBox<MobileRoute?>(nil)
            try await withHostedSurface(
                MobileStarredView(
                    stars: stars, tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpen: { opened.value = $0 })
            ) { surface in
                await surface.settle(25)
                let note = MobileStarsModel.spokenRow(name: "Harbor", kind: .post)
                let book = MobileStarsModel.spokenRow(name: "Poems", kind: .reading)
                #expect(surface.visibleLabels.contains(note),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.visibleLabels.contains(book),
                        "a starred BOOK has a home too; labels were \(surface.visibleLabels)")
                // A row opens what it names, through the model's route brain.
                #expect(surface.activate(note))
                await surface.settle(10)
                #expect(opened.value == .note(noteID, focus: false))
            }

            // 2 · THE SHELF no longer lists them — over a populated surface.
            let shelf = MobileShelfViewModel(session: session)
            let observation = Task { await shelf.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where shelf.books.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            try await withHostedSurface(
                MobileShelfView(
                    model: shelf, stars: stars, quickNote: MobileQuickNoteModel(),
                    tokens: .terminalLight, tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in },
                    onSettings: {})
            ) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                // PROOF OF LIFE first: the shelf really rendered.
                #expect(labels.contains("New Book"), "labels were \(labels)")
                // (Voice-cased at render — the Terminal voice lowercases
                // chrome, so the comparison is too.)
                #expect(labels.contains { $0.lowercased().contains("poems") },
                        "the starred BOOK still rows here — as a book, which is what the shelf lists; labels were \(labels)")
                // THE ABSENCE: the starred NOTE has no business on the shelf.
                #expect(!labels.contains { $0.lowercased().contains("harbor") },
                        "the starred list left the shelf; labels were \(labels)")
            }
        }
    }

    /// **THE CAP REFUSAL STOPS NAMING A ROAD THAT NO LONGER EXISTS.**
    ///
    /// It said *"un-star one in the starred list at the top of the shelf"* —
    /// and this batch retired that list from the shelf, so the sentence would
    /// have sent her somewhere that is not there. A bug-class fix, pinned as
    /// one. RED-ON-OLD: restore the old sentence and both assertions go red.
    @Test func theCapRefusalNamesTheListThatActuallyExists() {
        let refusal = MobileStarsModel.capRefusal(limit: Operations.starLimit)
        #expect(!refusal.contains("shelf"),
                "the shelf no longer holds the starred list: \(refusal)")
        #expect(refusal.contains(MobileStarsModel.pageName),
                "it names the page that does: \(refusal)")
    }

    /// **A REFUSAL FIRED FROM THE STARRED PAGE SPEAKS THERE, AND ONLY
    /// THERE** — D2's rule, extended to the third root by giving it its own
    /// `DoorHome`. Without the new case the page's refusals would have had to
    /// borrow another root's home, which is the exact defect D2 closed: a
    /// refusal waiting on a surface that did not fire it.
    @Test func aStarRefusalFromTheStarredPageSpeaksOnlyThere() async throws {
        try await withEditorWorld { session, _ in
            let ids = try await session.runner.run { ops -> [String] in
                try (0..<(Operations.starLimit + 1)).map { try ops.createPost(title: "n\($0)").id }
            }
            let stars = MobileStarsModel(session: session)
            for id in ids.prefix(Operations.starLimit) {
                await stars.toggle(.post(id), from: .shelf)
            }
            #expect(stars.items.count == Operations.starLimit)
            #expect(stars.error(on: .shelf) == nil, "a full list is not a refusal")

            // The one that does not fit, fired from the starred page.
            await stars.toggle(.post(ids[Operations.starLimit]), from: .starred)
            #expect(stars.error(on: .starred)
                    == MobileStarsModel.capRefusal(limit: Operations.starLimit))
            #expect(stars.error(on: .shelf) == nil,
                    "it does not wait on a root that did not fire it")
            #expect(stars.error(on: .library) == nil)
            #expect(stars.items.count == Operations.starLimit,
                    "the cap refuses honestly rather than evicting")
        }
    }

    // MARK: - Deliverable 3 · the two doors inside a book

    /// **+ NEW NOTE MINTS INSIDE THE BOOK, AND THE NOTE OPENS FOR WRITING.**
    /// The real door on the real contents screen, activated through UIKit's
    /// own dispatch; the note it makes is a member of that book.
    @Test func theBooksNewNoteDoorMintsInsideItAndOpensForWriting() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                try ops.createReading(name: "Essays", kind: .curated).id
            }
            let written = LockIsolatedBox<String?>(nil)
            try await withHostedSurface(
                MobileBookView(
                    session: session, readingID: bookID, tokens: .terminalLight,
                    onOpen: { _ in }, onRead: {},
                    onOpenForWriting: { written.value = $0 })
            ) { surface in
                await surface.settle(30)
                #expect(surface.activate(MobileBookView.newNoteDoorTitle),
                        "labels were \(surface.visibleLabels)")
                for _ in 0..<2000 where written.value == nil {
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(1))
                }
            }
            let postID = try #require(written.value, "the door opens what it minted")
            let member = try await db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: """
                        SELECT EXISTS(SELECT 1 FROM reading_post
                                      WHERE reading_id = ? AND post_id = ?
                                        AND deleted_at IS NULL)
                        """,
                    arguments: [bookID, postID])
            }
            #expect(member == true, "born INSIDE the book, not dragged into it")
        }
    }

    /// **THE MINT GATE: A REFUSAL MINTS NOTHING.**
    ///
    /// A finished book refuses the note — and the refusal happens BEFORE and
    /// INSIDE the same transaction as the mint (`newPostInReading` checks the
    /// reading's state before `insertPost`), so no stray note is left behind.
    /// The pin counts containers across the refused act, which is the assert
    /// the brief names, and reads the sentence, which is the family's own
    /// (`MobileMembershipModel.refusal` — never a second copy of it).
    @Test func aRefusedBookDoorMintsNothingAndSpeaksTheFamilysVoice() async throws {
        try await withEditorWorld { session, db in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Poems", kind: .curated)
                try ops.lockReading(book.id)
                return book.id
            }
            let model = MobileBookViewModel(session: session, readingID: bookID)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.reading == nil {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.showsBookDoors,
                    "a FINISHED book keeps its doors — finished is reversible, and a door that vanished would teach nothing")

            func counts() async throws -> (containers: Int, sections: Int) {
                try await db.read { db in
                    (try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM container") ?? -1,
                     try Int.fetchOne(
                        db, sql: "SELECT COUNT(*) FROM reading_section") ?? -1)
                }
            }
            let before = try await counts()

            #expect(await model.newNote() == nil, "the note door refuses")
            // The DOOR's slot, not the screen's (the cold review's MAJOR 2 —
            // the two are held apart so each speaks where its speaker is).
            #expect(model.doorRefusal
                    == MobileMembershipModel.refusal(
                        OperationError.lockedReading(id: bookID), bookName: "Poems"))
            #expect(model.doorRefusal?.contains("finished") == true, "\(model.doorRefusal ?? "")")
            #expect(model.lastError == nil, "the screen read fine; only the door refused")

            await model.newChapter(named: "Openings")
            #expect(model.doorRefusal
                    == MobileMembershipModel.refusal(
                        OperationError.lockedReading(id: bookID), bookName: "Poems"))

            let after = try await counts()
            #expect(after.containers == before.containers,
                    "NO STRAY NOTE: refused before the mint, in the mint's own transaction")
            #expect(after.sections == before.sections, "and no stray chapter")
        }
    }

    /// **THE REFUSAL SPEAKS WHERE THE TAP WAS** (the batch-10 cold review,
    /// MAJOR 2 — the one finding that undermined the batch's own deliberate
    /// divergence from the Mac).
    ///
    /// The Mac HIDES both doors on a finished book; this phone keeps them so
    /// they can EXPLAIN. That is only defensible while the explanation is
    /// where she is standing — and the doors trail the contents list, so a
    /// sentence rendered in the HEADER spoke off the top of the viewport on
    /// any book longer than a screen. From the bottom of a long book, the tap
    /// did nothing observable at all.
    ///
    /// Driven on a REAL mounted finished book with a screenful of notes: the
    /// real door is activated through UIKit's own dispatch, and the sentence
    /// is measured against the door's own frame.
    ///
    /// RED-ON-OLD: render the refusal only in `header` (the shipped shape)
    /// and the sentence lands ~500 pt ABOVE the door instead of beneath it.
    @Test func aRefusedBookDoorSpeaksBesideTheDoorSheTapped() async throws {
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "Poems", kind: .curated)
                // A SCREENFUL — the whole point of the finding is a list
                // long enough to put the header and the doors far apart.
                for i in 0..<12 {
                    let post = try ops.createPost(title: "Note \(i)")
                    _ = try ops.addPostToReading(post.id, to: book.id)
                }
                try ops.lockReading(book.id)
                return book.id
            }
            let sentence = MobileMembershipModel.refusal(
                OperationError.lockedReading(id: bookID), bookName: "Poems")
            try await withHostedSurface(
                MobileBookView(
                    session: session, readingID: bookID, tokens: .terminalLight,
                    onOpen: { _ in }, onRead: {})
            ) { surface in
                await surface.settle(30)
                // PROOF OF LIFE: the long book really rendered its rows.
                #expect(surface.visibleLabels.contains { $0.contains("Note 11") },
                        "labels were \(surface.visibleLabels)")
                #expect(surface.activate(MobileBookView.newNoteDoorTitle),
                        "labels were \(surface.visibleLabels)")
                for _ in 0..<200 where !surface.visibleLabels.contains(sentence) {
                    await surface.settle(1)
                }
                let door = try #require(
                    surface.element(labeled: MobileBookView.newNoteDoorTitle))
                let voice = try #require(
                    surface.element(labeled: sentence),
                    "the refusal must be ON SCREEN; labels were \(surface.visibleLabels)")
                let doorFrame = door.accessibilityFrame
                let voiceFrame = voice.accessibilityFrame
                #expect(voiceFrame.height > 0, "the sentence has a real frame: \(voiceFrame)")
                #expect(voiceFrame.minY >= doorFrame.minY,
                        "the refusal renders BENEATH the door that fired it — door \(doorFrame), refusal \(voiceFrame)")
                #expect(voiceFrame.minY - doorFrame.maxY < 80,
                        "and immediately beneath it, not a screen away — door \(doorFrame), refusal \(voiceFrame)")
            }
        }
    }

    /// **A SMART BOOK'S DOORS ARE ABSENT, NOT DISABLED-AND-SILENT** (P-2).
    /// Derived membership has no row to mint and chapters are refused by
    /// model rule, so neither door could ever mean what it says there.
    ///
    /// An ABSENCE pin over a POPULATED surface: the smart book renders its
    /// collected note and its own chrome doors in the same walk, so the tree
    /// is provably alive.
    @Test func aSmartBooksContentsCarriesNeitherDoor() async throws {
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let tag = try ops.createTag(name: "essays")
                let post = try ops.createPost(title: "Collected")
                try ops.applyTag(tag.id, toPost: post.id)
                return try ops.createReading(
                    name: "Everything essays", kind: .smart,
                    querySpec: #"{"tags":["essays"]}"#).id
            }
            try await withHostedSurface(
                MobileBookView(
                    session: session, readingID: bookID, tokens: .terminalLight,
                    onOpen: { _ in }, onRead: {})
            ) { surface in
                await surface.settle(30)
                let labels = surface.visibleLabels
                // PROOF OF LIFE: the smart book really rendered its contents.
                #expect(labels.contains { $0.contains("Collected") },
                        "the smart book's collected note is on screen; labels were \(labels)")
                #expect(!labels.contains(MobileBookView.newNoteDoorTitle),
                        "labels were \(labels)")
                #expect(!labels.contains(MobileBookView.newChapterDoorTitle),
                        "labels were \(labels)")
            }
        }
    }

    /// **A NEW CHAPTER IS VISIBLE THE MOMENT IT EXISTS — even empty.**
    ///
    /// The phone's contents list is the book's only chapter surface (there is
    /// no navigator to put an empty chapter in), so a grouping that could
    /// only render chapters WITH notes would have made the New Chapter door a
    /// door that visibly does nothing — fire-and-DO (R115) dressed as a
    /// success. RED-ON-OLD: restore the run-clustering-only `grouped` and the
    /// empty chapter disappears from `groupedRows`.
    ///
    /// It also pins the resolution by **ID**: chapter names have no
    /// uniqueness (AppSpec §7), and a name-keyed merge would fold two
    /// chapters called "Openings" into one.
    @Test func aNewChapterShowsInTheContentsEvenBeforeItHoldsAnything() async throws {
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "The Book", kind: .curated)
                let first = try ops.createSection(in: book.id, name: "Openings")
                let post = try ops.createPost(title: "One")
                _ = try ops.addPostToReading(post.id, to: book.id)
                try ops.assignPostToSection(post.id, in: book.id, section: first.id)
                return book.id
            }
            let model = MobileBookViewModel(session: session, readingID: bookID)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            for _ in 0..<2000 where model.entries.isEmpty {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.groupedRows.map(\.section) == ["Openings"])

            // A SECOND chapter with the SAME NAME, and an empty third.
            await model.newChapter(named: "Openings")
            await model.newChapter(named: "Endings")
            for _ in 0..<3000 where model.chapters.count < 3 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.doorRefusal == nil)
            let groups = model.groupedRows
            #expect(groups.map(\.section) == ["Openings", "Openings", "Endings"],
                    "empty chapters render, and same-named ones stay TWO (resolved by id — names have no uniqueness)")
            #expect(groups.map { $0.entries.count } == [1, 0, 0])

            // A blank name never fires a silent no-op (the face gate's rule).
            #expect(!MobileBookViewModel.canName("   "))
            await model.newChapter(named: "   ")
            #expect(model.chapters.count == 3, "nothing was created")
        }
    }

    /// **A CHAPTER PAST THE WINDOW IS NOT AN EMPTY CHAPTER** (the batch-10
    /// cold review, MINOR 4).
    ///
    /// This batch taught the contents list to render a chapter header with
    /// nothing under it, and made that MEAN "this chapter is empty" — which
    /// the bounded window then turned into a lie: `grouped` fills a chapter
    /// from the WINDOWED entries, so on a truncated book every chapter whose
    /// notes lie past the cut rendered as empty too.
    ///
    /// The fix distinguishes the two by the one fact that separates them —
    /// whether the chapter holds a member ANYWHERE — and folds the
    /// past-the-cut chapter under the listing's own truncation marker, which
    /// already says the rest of the book isn't loaded. The genuinely empty
    /// chapter still renders, because that is D3's whole point.
    ///
    /// Driven over a REAL truncated book (`window: 1`), not the pure brain
    /// alone, so the extra read and the grouping are pinned together.
    ///
    /// RED-ON-OLD: drop the `populated` clause from `grouped` and the folded
    /// chapter comes back as a third, empty-looking group.
    @Test func aChapterWhoseNotesFellPastTheWindowIsNotShownAsEmpty() async throws {
        try await withEditorWorld { session, _ in
            let bookID = try await session.runner.run { ops -> String in
                let book = try ops.createReading(name: "The Book", kind: .curated)
                let one = try ops.createSection(in: book.id, name: "One")
                _ = try ops.createSection(in: book.id, name: "Two")
                let three = try ops.createSection(in: book.id, name: "Three")
                let first = try ops.createPost(title: "First")
                _ = try ops.addPostToReading(first.id, to: book.id)
                try ops.assignPostToSection(first.id, in: book.id, section: one.id)
                let last = try ops.createPost(title: "Last")
                _ = try ops.addPostToReading(last.id, to: book.id)
                try ops.assignPostToSection(last.id, in: book.id, section: three.id)
                return book.id
            }
            // A window of ONE: "First" fits, "Last" is past the cut.
            let model = MobileBookViewModel(session: session, readingID: bookID, window: 1)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            for _ in 0..<3000 where model.chapters.count < 3 || !model.truncated {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(model.truncated, "the window really cut the book")
            #expect(model.entries.map(\.title) == ["First"])
            #expect(model.populatedChapters.count == 2,
                    "two chapters hold a member somewhere: \(model.populatedChapters)")

            let groups = model.groupedRows
            #expect(groups.map(\.section) == ["One", "Two"],
                    "the EMPTY chapter renders; the one whose note fell past the cut folds under the truncation marker instead of lying")
            #expect(groups.map { $0.entries.count } == [1, 0])

            // And the marker that carries the folded chapter's story is the
            // standing one — never a second sentence for this case.
            #expect(MobileBookViewModel.truncationMarker(shown: model.entries.count)
                    == "Showing the first 1 notes — the rest of this book isn't loaded yet.")
        }
    }

    /// The two door words, pinned — and the note door is the phone's ONE
    /// new-note word, so the shelf, the Library and a book cannot come to
    /// spell it three ways.
    @Test func theBookDoorsSpeakThePhonesOwnWords() {
        #expect(MobileBookView.newNoteDoorTitle == MobileNewNoteDoor.doorTitle)
        #expect(MobileBookView.newChapterDoorTitle == "+ New Chapter")
        // The Mac's alert, word for word (`BookView`'s own).
        #expect(MobileBookView.newChapterAlertTitle == "New Chapter")
        #expect(MobileBookView.newChapterFieldTitle == "Name")
        #expect(MobileBookView.newChapterConfirmTitle == "Create")
        #expect(VoiceTokens.terminalLight.chromeLabel(MobileBookView.newChapterDoorTitle)
                == "+ new chapter", "voice-cased at render — the Mac's own casing")
    }
}
