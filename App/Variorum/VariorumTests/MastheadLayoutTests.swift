//
//  MastheadLayoutTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — rows 4 + 19: **the masthead title
//  is centered on the masthead's full width in EVERY mode.** Her words: Read
//  "doesn't have a centered title above the read"; Lenses "the title is once
//  again weirdly aligned". The mechanism (walk-confirmed in both voices):
//  the trailing cluster took its natural width and the title centered in the
//  REMAINDER, landing about a third of the way across.
//
//  The pin mounts the real detail, switches it through every mode by the
//  router (⌘1–⌘8's own road), and reads the DEBUG oracle the masthead
//  writes — the title block's midX against the masthead's midX, in the
//  masthead's own coordinate space. RED ON OLD: the old HStack put the title
//  block's midX well left of center (its layer was the leading VStack, which
//  hugged its content; the block's midX sat near a third of the width).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The masthead title LEADS in every mode (17o batch d, row 11 — her U-8)", .serialized)
struct MastheadLayoutTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 80
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

    /// **U-8, in every mode** (17o batch d, ledger row 11) — the REWRITE of
    /// `theTitleBlockCentersOnTheMastheadInEveryMode`. Her ruling, verbatim:
    /// *"it should be aligned to the left again so it starts where 'in no
    /// book' is, and it should be able to extend at least as far as the
    /// middle centered title can extend right now to support longer
    /// titles."* This SUPERSEDES the Act 10 correction round's rows 4/19,
    /// whose claim (the title's midX on the masthead's midX) was the thing
    /// she asked to undo — so the claim is replaced, not merely relaxed:
    ///
    /// 1. the title's band STARTS at row two's leading edge (the path chip's
    ///    — "where 'in no book' is"), in every mode;
    /// 2. it REACHES at least as far right as the centered title could
    ///    (the old measure was 380 centered on the masthead, so `centre +
    ///    190`), in every mode;
    /// 3. and row 80's rule survives its parent: it still ends clear of the
    ///    icon row.
    ///
    /// RED ON OLD: the title band was centered behind the two insets, so its
    /// minX sat ~112 pt right of the chip's 0 in every mode.
    @Test func theTitleLeadsWithRowTwoAndReachesPastTheOldCenteredMeasure() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withMountedDetail(
                width: 1100,
                title: "The Boscombe Valley Mystery",
                tags: [], voice: voice
            ) { session, post, _, _ in
                #if DEBUG
                for mode in PostMode.allCases {
                    #expect(session.commandRouter.requestMode(mode, postID: post))
                    await settle(until: { session.commandRouter.activeMode == mode })
                    await settle(until: { false }, maxTurns: 6)
                    let title = try #require(MastheadGeometry.titleFrame,
                                             "the masthead reported its title in \(mode.rawValue)")
                    let chip = try #require(MastheadGeometry.pathChipFrame,
                                            "…and row two reported its leading chip")
                    let icons = try #require(MastheadGeometry.iconRowFrame)
                    let centre = try #require(MastheadGeometry.contentMidX)
                    #expect(abs(title.minX - chip.minX) <= 1,
                            "\(voice) \(mode.rawValue): title starts at \(title.minX), chip at \(chip.minX)")
                    #expect(title.maxX >= centre + 190 - 1,
                            "\(voice) \(mode.rawValue): reach \(title.maxX) vs centre \(centre) + 190")
                    #expect(title.maxX + MastheadTitleInsets.gap <= icons.minX + 0.5,
                            "\(voice) \(mode.rawValue): title ends \(title.maxX), icons begin \(icons.minX)")
                }
                #endif
            }
        }
    }

    /// **Row 12 — the placeholder no longer shifts when she clicks.** The two
    /// faces (`Text` and `TextField`) shared a max WIDTH and nothing else, so
    /// the field's taller intrinsic height moved the words the moment the
    /// title went editable. They now share ONE BOX. RED ON OLD: the field's
    /// frame sat above the label's by the difference in their heights.
    @Test func bothTitleFacesShareOneBoxSoNothingShiftsOnClick() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withMountedDetail(
                width: 1100, title: "", tags: [], voice: voice
            ) { session, _, _, _ in
                #if DEBUG
                await settle(until: { MastheadGeometry.titleFrame != nil })
                await settle(until: { false }, maxTurns: 6)
                let resting = try #require(MastheadGeometry.titleFrame)
                _ = session

                MastheadGeometry.titleFrame = nil
                MastheadGeometry.titleFieldFrame = nil
                PostDetailOracle.beginTitleEditing?()
                await settle(until: { MastheadGeometry.titleFieldFrame != nil })
                await settle(until: { false }, maxTurns: 8)
                let editing = try #require(MastheadGeometry.titleFieldFrame,
                                           "(\(voice)) the editing face reported its frame")
                #expect(abs(editing.midY - resting.midY) <= 0.5,
                        "(\(voice)) one baseline: field \(editing) vs label \(resting)")
                #expect(abs(editing.minX - resting.minX) <= 0.5,
                        "(\(voice)) and one leading edge")
                #expect(abs(editing.height - resting.height) <= 0.5,
                        "(\(voice)) and one height")
                #endif
            }
        }
    }

    /// **13u2 UNIT D — item 13's SECOND half, Act 10 ledger row 93.** The
    /// correction round's walk recorded an observation rather than a defect:
    /// on a note named by its DAY, clicking the title opens the rename field
    /// whose PROMPT is that same day, in the same font, in the same place —
    /// so the click reads as *"nothing happened"* although the door worked.
    /// Its own nit named the remedy: *"a visible open state (a field border,
    /// or the caret placed)"*. The caret is already placed; this is the
    /// border.
    ///
    /// RED ON OLD: `titleOpenMarkFrame` had nothing to publish — the open
    /// field drew no mark of any kind, which is the whole observation.
    @Test func theOpenRenameFieldIsVisiblyOpenOnANamelessNote() async throws {
        for voice in [ThemeVoice.terminal, .study] {
            try await withMountedDetail(
                width: 1100, title: "", tags: [], voice: voice
            ) { _, _, _, _ in
                #if DEBUG
                await settle(until: { MastheadGeometry.titleFrame != nil })
                await settle(until: { false }, maxTurns: 6)
                #expect(MastheadGeometry.titleOpenMarkAppearances == 0,
                        "(\(voice)) nothing is marked while the title rests")

                PostDetailOracle.beginTitleEditing?()
                await settle(until: { MastheadGeometry.titleOpenMarkAppearances > 0 })
                #expect(MastheadGeometry.titleOpenMarkAppearances > 0,
                        "(\(voice)) the open field carried a visible mark")
                #endif
            }
        }
    }

    /// **13u2 UNIT D — item 13's FIRST half, MEASURED rather than assumed.**
    /// Her report (2026-08-23): *"the title is way too cut off for no reason?
    /// it cuts off at 30 characters but it should go to the right at least
    /// until close to the scraps button."* The master plan already records
    /// that NO literal 30-character cap exists; this pin records what the
    /// real constraint is, in points, so the next reader does not re-derive
    /// it: the band runs from the masthead's leading edge to the icon row's
    /// gap, and the icon row is where the SCRAPS door lives — so "close to
    /// the scraps button" is exactly where it ends.
    ///
    /// It is a MEASUREMENT pin, not a new claim: `theTitleLeadsWith…` above
    /// already holds the two edges. What this adds is the ROOM the two
    /// edges leave, and the fact that the room is bounded by the ARTICLE's
    /// measure (680 — her sacred margins, R9) rather than by the window.
    @Test func theTitlesRoomIsTheArticleMeasureLessTheIconRow() async throws {
        for width in [1100.0, 1600.0] {
            try await withMountedDetail(
                width: width,
                title: "A title long enough to need every point of room the masthead has",
                tags: []
            ) { _, _, _, _ in
                #if DEBUG
                await settle(until: {
                    MastheadGeometry.titleFrame != nil && MastheadGeometry.iconRowFrame != nil
                })
                await settle(until: { false }, maxTurns: 6)
                let band = try #require(MastheadGeometry.titleFrame)
                let icons = try #require(MastheadGeometry.iconRowFrame)
                print(String(
                    format: "ITEM13 window=%.0f band=[%.1f…%.1f] room=%.1f icons=[%.1f…%.1f]",
                    width, band.minX, band.maxX, band.width, icons.minX, icons.maxX))
                let chip = try #require(MastheadGeometry.pathChipFrame)
                #expect(abs(band.minX - chip.minX) <= 1,
                        "the band starts where row two's path chip does")
                #expect(band.maxX + MastheadTitleInsets.gap <= icons.minX + 0.5,
                        "…and ends at the icon row, where the scraps door is")
                // The room is real, not a 30-character stub: well past the
                // ~380-pt centered measure item 13 was written against.
                #expect(band.width > 380, "room \(band.width) at a \(width)-pt window")
                #endif
            }
        }
    }

    // **RETIRED (17o batch d, row 11): `theTitleBlockCentersOnTheMastheadIn
    // EveryMode`.** Its claim — the title block's midX on the masthead's
    // midX in all eight modes — is precisely what her ruling U-8 undid
    // (*"it should be aligned to the left again"*), so it is REPLACED, not
    // relaxed: `theTitleLeadsWithRowTwoAndReachesPastTheOldCenteredMeasure`
    // above holds the same eight modes to the new rule, in both voices, and
    // carries the same "never under the icons" clause the old pin's sibling
    // (row 80) contributed. Deleting rather than loosening is the point: a
    // pin kept alive with its assertion weakened would have gone on claiming
    // the masthead was inspected when nothing was being asserted.

    /// **Row 19 — "changing the date of a note doesn't change its auto
    /// display name."** `PostTitleLabel.refresh()` was a one-shot
    /// `.task(id: postID)`: it read the stored title and the derived display
    /// name once per note and never again, so `setEntryDate` — which is what
    /// the derived name is built FROM — moved the store and left the words
    /// alone until the note was re-opened. Same fix as row 18, one note wide.
    ///
    /// RED ON OLD: the masthead keeps showing the created-at date after the
    /// entry date moves.
    @Test func aDateChangeMovesTheMastheadsDerivedTitleWithNoReopen() async throws {
        try await withMountedDetail(width: 1100, title: "", tags: []) { session, post, _, _ in
            #if DEBUG
            await settle(until: { PostDetailOracle.titleShown != nil })
            let before = try #require(PostDetailOracle.titleShown)
            #expect(!before.isEmpty, "an untitled note shows its date")

            try await session.runner.run { ops in
                try ops.setEntryDate(post, entryDate: "2026-03-04")
            }
            let owed = try await session.database.read {
                try Queries.noteDisplayTitle($0, id: post)
            }
            let wanted = try #require(owed)
            #expect(wanted != before, "the store really moved")
            await settle(until: { PostDetailOracle.titleShown == wanted })
            #expect(PostDetailOracle.titleShown == wanted,
                    "the masthead followed with no re-open: showing \(PostDetailOracle.titleShown ?? "nil")")

            // …and a rename lands on the same read, so the two doors that
            // write this note's name share one observation.
            try await session.runner.run { ops in
                try ops.renameContainer(post, title: "A Study in Scarlet")
            }
            await settle(until: { PostDetailOracle.titleShown == "A Study in Scarlet" })
            #expect(PostDetailOracle.titleShown == "A Study in Scarlet")
            #endif
        }
    }

    // MARK: - Row 58: the second row never collides

    /// Row 58 (the orchestrator's walk of batch A): on a note with several
    /// tags the masthead's SECOND row collided — the centered `~/book` chip
    /// was drawn under the first tag cards, and under the open tag field it
    /// vanished. The pin mounts the real detail with a titled note in a
    /// book and FIVE tags, reads the DEBUG oracle's frames in the
    /// masthead's own space, and holds: no card touches the chip, every
    /// card sits right of the chip by at least the row's gap, no card
    /// leaves the masthead; then ⌘⇧I's road opens the field and the field
    /// touches neither the chip nor a card, and the chip did not move. The
    /// title stays centered throughout (rows 4/19 + 55's promise held with
    /// five tags). RED ON OLD: the old row centered the chip behind an
    /// inset the 240-pt floor capped, so the chip's frame intersected the
    /// first cards, and the open field's frame intersected the chip.
    @Test func thePathChipAndTheTagClusterNeverIntersectInTerminal() async throws {
        try await assertRowTwoNeverCollides(voice: .terminal)
    }

    @Test func thePathChipAndTheTagClusterNeverIntersectInStudy() async throws {
        try await assertRowTwoNeverCollides(voice: .study)
    }

    private func settle(until predicate: () -> Bool, maxTurns: Int = 80) async {
        for _ in 0..<maxTurns {
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    /// **THE MASTHEAD'S GEOMETRY HAS STOPPED MOVING** (13u2 UNIT E —
    /// KnownIssues row 59's fix; DEBUG-only, like the oracle it reads).
    ///
    /// The flake this replaces: the pin pumped a FIXED number of run-loop
    /// turns (`maxTurns: 6` at rest, `8` after ⌘⇧I opened the tag field) and
    /// then read row two's rectangles. Under full-suite load that budget did
    /// not reach the row's final layout, so the frames it compared came from
    /// DIFFERENT layout passes — ~1.5 pt phantom grazes, twice in a row at
    /// the 18j close, 3/3 green isolated. The app was right in both voices;
    /// the pin was reading a row mid-flight.
    ///
    /// *(Measured while building this, and recorded because row 59's own
    /// sentence guessed at the mechanism: on a quiet machine the field's
    /// arrival moves NO card — the open produces exactly one report, the
    /// field's own, and `cardsMoved` reads 0 of 5 in both voices. So the
    /// staleness is not "the cards lag the field"; it is that neither side is
    /// guaranteed final when a fixed budget expires. The fix is the same
    /// either way, and it is the true statement that belongs at the code.)*
    ///
    /// **Why an until-clause on the REPORTS and not on the outcome:** a
    /// clause like "until nothing overlaps" would mask exactly the defect
    /// this pin exists to catch. Quiescence does not: a REAL overlap survives
    /// it and fails loudly, and a masthead that never settles returns `false`
    /// here and fails with its own sentence rather than silently handing over
    /// stale frames. `quietTurns` is how many consecutive turns must pass
    /// with no report at all; `maxTurns` is the ceiling that keeps a wedged
    /// layout from hanging the suite.
    private func settleMastheadGeometry(
        _ window: NSWindow, _ hosting: NSView,
        quietTurns: Int = 4, maxTurns: Int = 200
    ) async -> Bool {
        #if DEBUG
        var last = MastheadGeometry.reports
        var quiet = 0
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            let now = MastheadGeometry.reports
            if now == last {
                quiet += 1
                if quiet >= quietTurns { return true }
            } else {
                last = now
                quiet = 0
            }
        }
        return false
        #else
        return true
        #endif
    }

    private func assertRowTwoNeverCollides(voice: ThemeVoice) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 58))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "three ways of working")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so the mode can host.")
            // In a book, so the chip wears its widest face (`~/the field guide`).
            let book = try session.operations.createReading(name: "the field guide", kind: .curated)
            _ = try session.operations.addPostToReading(post.id, to: book.id)
            // FIVE tags — the walk's own case.
            for name in ["again", "final", "once", "tutorial", "walked"] {
                let tag = try session.operations.createTag(name: name)
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")

            // The voice: the live store, switched through its own setter.
            // …started and RESTORED by the one helper (round 2's NIT-2): the
            // Study arms used to leave the adoption — and, through the write
            // mode's real editor, the markdown palette — standing process-wide,
            // with only a `cancel()` that never joined the store's own task.
            try await withAdoptedTheme(session: session) { store in
                if voice == .study {
                    store.setVoice(.study)
                    await settle(until: { store.settings.voice == .study })
                    #expect(store.settings.voice == .study, "the Study voice took")
                }

                #if DEBUG
                MastheadGeometry.resetRowTwo()
                #endif
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                    UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                }
                let hosting = NSHostingView(
                    rootView: PostDetailView(session: session, postID: post.id)
                        .environment(store))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                await settle(window, hosting, until: {
                    session.commandRouter.activePostID == post.id
                })

                #if DEBUG
                await settle(window, hosting, until: {
                    MastheadGeometry.pathChipFrame != nil && MastheadGeometry.cardFrames.count == 5
                })
                #expect(await settleMastheadGeometry(window, hosting),
                        "(\(voice)) the masthead's geometry went quiet at rest, so every rectangle below is from ONE layout state")
                let gap = PostDetailView.rowTwoGap
                let chip = try #require(MastheadGeometry.pathChipFrame, "the path chip reported its frame (\(voice))")
                let width = try #require(MastheadGeometry.contentMidX).magnitude * 2
                let cards = MastheadGeometry.cardFrames
                #expect(cards.count == 5, "five cards reported (\(voice)), got \(cards.count)")
                for (id, card) in cards {
                    #expect(!chip.intersects(card),
                            "(\(voice)) the path chip \(chip) is drawn clear of card \(id) \(card)")
                    #expect(card.minX - chip.maxX >= gap - 0.5,
                            "(\(voice)) card \(id) sits right of the chip by the row's gap (\(gap)): \(card.minX - chip.maxX)")
                    #expect(card.minX >= -0.5 && card.maxX <= width + 0.5,
                            "(\(voice)) card \(id) \(card) stays inside the masthead (0…\(width))")
                }
                let titleClosed = try #require(MastheadGeometry.titleFrame)
                #expect(abs(titleClosed.minX - chip.minX) <= 1,
                        "\(voice), five tags: title \(titleClosed.minX) vs chip \(chip.minX)")

                // ⌘⇧I's road opens the field.
                #expect(session.commandRouter.requestTagField(), "the router reaches this masthead's field")
                await settle(window, hosting, until: { MastheadGeometry.fieldFrame != nil })
                // Row 59: NOT a blind pump. The field's arrival is the START
                // of the row's re-layout, not the end of it — the cards move
                // to make room, and under load their reports land after the
                // field's. Wait for the whole masthead to stop moving.
                #expect(await settleMastheadGeometry(window, hosting),
                        "(\(voice)) the masthead's geometry went quiet after the field opened — the field and the cards below are from ONE layout state")
                let field = try #require(MastheadGeometry.fieldFrame, "the open field reported its frame (\(voice))")
                #expect(!chip.intersects(field),
                        "(\(voice)) the open field \(field) is drawn clear of the path chip \(chip)")
                #expect(field.minX - chip.maxX >= gap - 0.5,
                        "(\(voice)) the field sits right of the chip by the row's gap: \(field.minX - chip.maxX)")
                for (id, card) in MastheadGeometry.cardFrames {
                    #expect(!field.intersects(card), "(\(voice)) the field \(field) covers no card (\(id) \(card))")
                }
                let chipOpen = try #require(MastheadGeometry.pathChipFrame)
                #expect(abs(chipOpen.minX - chip.minX) <= 0.5 && abs(chipOpen.minY - chip.minY) <= 0.5,
                        "(\(voice)) opening the field moved nothing: the chip stayed at \(chip.origin), now \(chipOpen.origin)")
                let titleOpen = try #require(MastheadGeometry.titleFrame)
                #expect(abs(titleOpen.minX - chip.minX) <= 1,
                        "(\(voice)) …and with the tag field open: \(titleOpen.minX) vs \(chip.minX)")
                #endif
            }
        }
    }

    // MARK: - The Act 10 correction round, batch G — rows 80 and 59

    /// **Row 80's rule, pure — REWRITTEN to U-8** (17o batch d, row 11).
    /// F's walk at a ~950-pt window with an inspector open (the masthead
    /// ~270 pt) found the CENTERED title touching the tray icon, because the
    /// symmetric inset was capped by the 240-pt line floor on both sides.
    /// Her ruling retires the centering, and the floor retires with it: a
    /// leading title has no second inset to be squeezed by. What survives is
    /// the half that was never about centering — **the trailing inset always
    /// keeps the icon row clear, gap included**, at every width, and below
    /// that the title truncates rather than run under the icons.
    @Test func theTitlesTrailingInsetAlwaysKeepsTheIconRowClear() {
        #expect(MastheadTitleInsets.trailingInset(iconRowWidth: 100) == 112)
        #expect(MastheadTitleInsets.trailingInset(iconRowWidth: 0) == MastheadTitleInsets.gap,
                "no icons still means the row's gap, so the words never touch the edge")
        // It cannot depend on the masthead's width — that dependence WAS the
        // floor, and the floor is what the ruling retired.
        #expect(MastheadTitleInsets.trailingInset(iconRowWidth: 240) == 252)
    }

    /// **Row 80 in geometry.** The real detail mounted at 340 pt (the
    /// masthead 292 — F's inspector-open measure), a title long enough to
    /// fill whatever band it is given: the title TEXT's frame ends the
    /// row's gap before the icon row begins, and starts inside the
    /// masthead. RED ON OLD: the symmetric cap gave the title the band
    /// [26, 266] against an icon row starting near 192 — the words under
    /// the icons.
    @Test func theTitleNeverRunsUnderTheIconsAtANarrowMasthead() async throws {
        try await withMountedDetail(
            width: 340, title: "The Boscombe Valley Mystery — a title long enough to truncate here",
            tags: []
        ) { _, _, _, _ in
            #if DEBUG
            await settle(until: {
                MastheadGeometry.titleFrame != nil && MastheadGeometry.iconRowFrame != nil
            })
            await settle(until: { false }, maxTurns: 6)
            let title = try #require(MastheadGeometry.titleFrame, "the title reported its frame")
            let icons = try #require(MastheadGeometry.iconRowFrame, "the icon row reported its frame")
            let width = try #require(MastheadGeometry.contentMidX).magnitude * 2
            #expect(title.width > 0 && icons.width > 0)
            #expect(title.maxX + MastheadTitleInsets.gap <= icons.minX + 0.5,
                    "the title's words end the gap before the icons begin: title \(title) vs icons \(icons) (masthead \(width))")
            #expect(title.minX >= -0.5, "the title starts inside the masthead: \(title)")
            #endif
        }
    }

    /// **Row 59.** The ＃ door's hit target is the row's height, not the
    /// glyph's — the orchestrator's walk removed a tag by hitting a card's ×
    /// two points from the ＃. RED ON OLD: the door's frame was the ~10-pt
    /// symbol plus 3 × 2 pt of padding.
    @Test func theTagDoorsHitTargetIsTheRowsHeightNotTheGlyphs() async throws {
        try await withMountedDetail(width: 1100, title: "a note with a tag", tags: ["walked"]) { _, _, _, _ in
            #if DEBUG
            await settle(until: { MastheadGeometry.doorFrame != nil })
            await settle(until: { false }, maxTurns: 6)
            let door = try #require(MastheadGeometry.doorFrame, "the ＃ door reported its frame")
            let target = MastheadTagCluster.doorTarget
            #expect(door.width >= target - 0.5 && door.height >= target - 0.5,
                    "the door's target is at least \(target) × \(target): \(door)")
            #endif
        }
    }

    // MARK: - Row 80b (her live find): the cluster moves BELOW the chip when the row cannot hold both

    /// **Row 80b.** With the tray open in a ~1740-pt window the detail is
    /// ≈ 590 pt: the `sherlock holmes ×` card was drawn OVER the path chip's
    /// words and the ＃ orphaned on a line of its own. Now row 2 is
    /// width-aware: the chip never covered, the door on the last card's
    /// line — with one tag and with five, in both voices, at her width and
    /// at the tighter inspector-minimum one. RED ON OLD: the card's frame
    /// intersects the chip's; the door's line is below the card's.
    @Test func theClusterNeverCoversTheChipAndTheDoorNeverOrphansInTerminal() async throws {
        try await assertRowTwoHoldsAtNarrowWidths(voice: .terminal)
    }

    @Test func theClusterNeverCoversTheChipAndTheDoorNeverOrphansInStudy() async throws {
        try await assertRowTwoHoldsAtNarrowWidths(voice: .study)
    }

    /// The decisions, pure: the row's one-line/two-lines rule and the
    /// flow's minimum line (the widest card + the door beside it + the
    /// reserve).
    @Test func theRowTwoAndTheFlowMinimumRulesArePure() {
        #expect(MastheadRowTwo.arrangement(width: 680, chipWidth: 125, clusterMinimum: 286, gap: 16) == .oneLine)
        #expect(MastheadRowTwo.arrangement(width: 542, chipWidth: 230, clusterMinimum: 326, gap: 16) == .twoLines,
                "her width: the chip and one card + the door + the reserve do not share 542")
        #expect(MastheadRowTwo.arrangement(width: .infinity, chipWidth: 230, clusterMinimum: 326, gap: 16) == .oneLine,
                "unmeasured: one line")
        let minimum = TrailingFlow.minimumLineWidth(
            widths: [80, 130, 24], keepWithPrevious: [2], spacing: 4, leadingReserve: 196)
        #expect(abs(minimum - 354) < 0.001, "the widest card, the door beside it, the reserve: \(minimum)")
        let bare = TrailingFlow.minimumLineWidth(widths: [50], keepWithPrevious: [], spacing: 4, leadingReserve: 0)
        #expect(abs(bare - 50) < 0.001)
    }

    private func assertRowTwoHoldsAtNarrowWidths(voice: ThemeVoice) async throws {
        for (width, tags) in [
            (CGFloat(590), ["sherlock holmes"]),
            (CGFloat(590), ["again", "final", "once", "tutorial", "walked"]),
            (CGFloat(340), ["sherlock holmes"]),
        ] {
            try await withMountedDetail(
                width: width, title: "The Boscombe Valley Mystery", tags: tags,
                book: "the adventures of sherlock holmes", voice: voice
            ) { _, _, _, _ in
                #if DEBUG
                await settle(until: {
                    MastheadGeometry.pathChipFrame != nil
                        && MastheadGeometry.cardFrames.count == tags.count
                        && MastheadGeometry.doorFrame != nil
                        && MastheadGeometry.stampFrame != nil
                })
                await settle(until: { false }, maxTurns: 6)
                let chip = try #require(MastheadGeometry.pathChipFrame, "(\(voice) \(width) \(tags.count) tags) the chip reported")
                let door = try #require(MastheadGeometry.doorFrame, "(\(voice) \(width)) the door reported")
                let cards = MastheadGeometry.cardFrames
                #expect(cards.count == tags.count, "(\(voice) \(width)) every card reported")
                let masthead = try #require(MastheadGeometry.contentMidX).magnitude * 2
                for (id, card) in cards {
                    #expect(!chip.intersects(card),
                            "(\(voice) \(width) \(tags.count) tags) the chip \(chip) is never covered by card \(id) \(card)")
                    #expect(card.minX >= -0.5 && card.maxX <= masthead + 0.5,
                            "(\(voice) \(width)) card \(id) \(card) stays inside the masthead (\(masthead))")
                }
                #expect(chip.maxX <= masthead + 0.5, "(\(voice) \(width)) the chip stays inside the masthead: \(chip)")
                // The door sits on the LAST card's line — never a line alone.
                let lastLineY = cards.values.map(\.midY).max() ?? 0
                #expect(abs(door.midY - lastLineY) <= 4,
                        "(\(voice) \(width) \(tags.count) tags) the door (\(door)) sits on the last card's line (midY \(lastLineY)), never orphaned below it")
                #expect(!chip.intersects(door), "(\(voice) \(width)) the door never covers the chip")
                // 18h batch 1: row two now carries a THIRD thing — the time
                // stamp at its trailing end — and the claim this pin makes is
                // that row two HOLDS at narrow widths, so the stamp is held to
                // it too. (The chip yields a little room to it and ellipsizes
                // sooner; that is row 80b's own ruled yield, not a collision.)
                let stamp = try #require(MastheadGeometry.stampFrame, "(\(voice) \(width)) the stamp reported")
                #expect(stamp.maxX <= masthead + 0.5,
                        "(\(voice) \(width)) the stamp stays inside the masthead: \(stamp)")
                #expect(!stamp.intersects(chip), "(\(voice) \(width)) the stamp never covers the chip")
                #expect(!stamp.intersects(door), "(\(voice) \(width)) …nor the ＃ door")
                for (id, card) in cards {
                    #expect(!stamp.intersects(card), "(\(voice) \(width)) …nor card \(id) \(card)")
                }
                #endif
            }
        }
    }

    /// Mounts the real detail at `width` with a titled note carrying `tags`,
    /// the oracles reset first (the rows-58 rig, factored for G's pins).
    private func withMountedDetail(
        width: CGFloat, title: String, tags: [String], book: String? = nil,
        voice: ThemeVoice = .terminal,
        _ body: @MainActor (AppSession, String, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 80))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: title)
            _ = try session.operations.newBlock(in: post.id, text: "a block, so the mode can host.")
            if let book {
                let reading = try session.operations.createReading(name: book, kind: .curated)
                _ = try session.operations.addPostToReading(post.id, to: reading.id)
            }
            for name in tags {
                let tag = try session.operations.createTag(name: name)
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
            // The voice: the live store, switched through its own setter
            // (the rows-58 rig's road).
            // …started and RESTORED by the one helper (round 2's NIT-2): the
            // Study arms used to leave the adoption — and, through the write
            // mode's real editor, the markdown palette — standing process-wide,
            // with only a `cancel()` that never joined the store's own task.
            try await withAdoptedTheme(session: session) { store in
                if voice == .study {
                    store.setVoice(.study)
                    await settle(until: { store.settings.voice == .study })
                    #expect(store.settings.voice == .study, "the Study voice took")
                }
                #if DEBUG
                MastheadGeometry.resetRowTwo()
                MastheadGeometry.resetTitleRow()
                #endif
                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: width, height: 750),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                    UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
                }
                let hosting = NSHostingView(
                    rootView: PostDetailView(session: session, postID: post.id)
                        .environment(store))
                hosting.frame = NSRect(x: 0, y: 0, width: width, height: 750)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                await settle(window, hosting, until: {
                    session.commandRouter.activePostID == post.id
                })
                try await body(session, post.id, window, hosting)
            }
        }
    }
}
