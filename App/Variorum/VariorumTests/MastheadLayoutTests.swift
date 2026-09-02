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
@Suite("The masthead title centers in every mode (correction round, rows 4/19)", .serialized)
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

    @Test func theTitleBlockCentersOnTheMastheadInEveryMode() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 4))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a centered title")
            _ = try session.operations.newBlock(in: post.id, text: "a block, so every mode can host.")
            _ = try session.operations.newBlock(in: post.id, text: "and a second one.")
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")

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
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                session.commandRouter.activePostID == post.id
            })

            // The oracle is STICKY across modes deliberately: a geometry
            // report fires only when the geometry CHANGES, and a masthead
            // that stays put across a mode switch reports nothing new —
            // which is itself the claim (one layout for every mode). A mode
            // that moved the title would re-report, and the read below
            // would see it.
            for mode in PostMode.allCases {
                #expect(session.commandRouter.requestMode(mode, postID: post.id))
                await settle(window, hosting, until: {
                    session.commandRouter.activeMode == mode
                })
                await settle(window, hosting, until: { false }, maxTurns: 6)
                #if DEBUG
                let title = try #require(MastheadGeometry.titleMidX, "the masthead reported its title in \(mode.rawValue)")
                let content = try #require(MastheadGeometry.contentMidX, "…and its own width")
                #expect(abs(title - content) <= 1,
                        "in \(mode.rawValue) the title block's midX (\(title)) sits on the masthead's midX (\(content)) within 1 pt")
                #endif
            }
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
            let store = ThemeStore(session: session)
            let watching = Task { await store.start() }
            defer { watching.cancel() }
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
            await settle(window, hosting, until: { false }, maxTurns: 6)
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
            let titleClosed = try #require(MastheadGeometry.titleMidX)
            #expect(abs(titleClosed - width / 2) <= 1,
                    "(\(voice)) the title stays centered with five tags (closed): \(titleClosed) vs \(width / 2)")

            // ⌘⇧I's road opens the field.
            #expect(session.commandRouter.requestTagField(), "the router reaches this masthead's field")
            await settle(window, hosting, until: { MastheadGeometry.fieldFrame != nil })
            await settle(window, hosting, until: { false }, maxTurns: 8)
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
            let titleOpen = try #require(MastheadGeometry.titleMidX)
            #expect(abs(titleOpen - width / 2) <= 1,
                    "(\(voice)) the title stays centered with the field open: \(titleOpen) vs \(width / 2)")
            #endif
        }
    }

    // MARK: - The Act 10 correction round, batch G — rows 80 and 59

    /// **Row 80's rule, pure.** F's walk at a ~950-pt window with an
    /// inspector open (the masthead ~270 pt) found the title TOUCHING the
    /// tray icon: the symmetric inset was capped by the 240-pt floor on
    /// both sides, so the trailing inset shrank under the icon row's width.
    /// Now the trailing inset always keeps the icons clear and the floor is
    /// spent on the leading side; below floor + icons the title yields.
    @Test func theTitleInsetsKeepTheIconsClearAndSpendTheFloorOnTheLeadingSide() {
        let icons: CGFloat = 100
        let wide = MastheadTitleInsets.insets(mastheadWidth: 680, iconRowWidth: icons, floor: 240)
        #expect(wide.leading == 112 && wide.trailing == 112, "the standing widths: symmetric, as before")
        let narrow = MastheadTitleInsets.insets(mastheadWidth: 400, iconRowWidth: icons, floor: 240)
        #expect(narrow.trailing == 112, "the trailing inset never shrinks under the icons")
        #expect(narrow.leading == 48, "the floor is spent on the leading side (400 − 240 − 112)")
        #expect(400 - narrow.leading - narrow.trailing == 240, "the title keeps its floor while it can")
        let tight = MastheadTitleInsets.insets(mastheadWidth: 270, iconRowWidth: icons, floor: 240)
        #expect(tight.leading == 0 && tight.trailing == 112, "narrower than floor + icons: the title yields, the icons stay clear")
        let unmeasured = MastheadTitleInsets.insets(mastheadWidth: 0, iconRowWidth: icons, floor: 240)
        #expect(unmeasured.leading == 112 && unmeasured.trailing == 112, "the first pass: symmetric")
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
        ) { _, _ in
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
        try await withMountedDetail(width: 1100, title: "a note with a tag", tags: ["walked"]) { _, _ in
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

    /// Mounts the real detail at `width` with a titled note carrying `tags`,
    /// the oracles reset first (the rows-58 rig, factored for G's pins).
    private func withMountedDetail(
        width: CGFloat, title: String, tags: [String],
        _ body: @MainActor (NSWindow, NSView) async throws -> Void
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
            for name in tags {
                let tag = try session.operations.createTag(name: name)
                _ = try session.operations.applyTag(tag.id, toPost: post.id)
            }
            UserDefaults.standard.set(PostMode.write.rawValue, forKey: "postMode.\(post.id)")
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
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                session.commandRouter.activePostID == post.id
            })
            try await body(window, hosting)
        }
    }
}
