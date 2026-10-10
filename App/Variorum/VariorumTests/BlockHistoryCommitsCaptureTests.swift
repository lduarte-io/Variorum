//
//  BlockHistoryCommitsCaptureTests.swift
//  VariorumTests
//
//  VX-144 (the VX-143 run, batch 2) — THE CAPTURE HARNESS behind her report:
//  *"the commits page is very messy with crowded & cluttered UI - I'm sure if
//  you take a screenshot of it you'll see the issue. i want that UI improved +
//  cleaned up."*
//
//  The surface is the Block History pane (`BlockHistoryPane`), whose first and
//  main region is headed "Commits" since 13s-b U4. It is captured with SEEDED
//  REALISTIC data — dates spread across days, named and bare commits, quiet
//  runs, a split the older commits predate, several takes, archived and
//  deleted takes, a merge's two originals — in both voices, light and dark, at
//  the inspector column's default width (420 pt, `PostDetailView`'s one width
//  rule), and once IN CONTEXT beside the note.
//
//  The PNGs ride out through the log as chunked base64 lines
//  (`[VX-144-PNG <name> <part>] …`) for `TakesMarginGridCaptureTests`'
//  recorded reason: the test host's container is TCC-protected from the shell
//  on the Air. The run record names the decode.
//
//  DISABLED BY DEFAULT: it asserts nothing, and the base64 would bloat every
//  whole-target log. To re-shoot, drop the `.disabled` trait and run it alone
//  (`-only-testing:VariorumTests/BlockHistoryCommitsCaptureTests`).
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
@Suite(
    "Commits page captures (VX-144)", .serialized,
    .disabled("a capture harness — drop this trait to re-shoot VX-144's evidence"))
struct BlockHistoryCommitsCaptureTests {
    static let outputDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("variorum-vx144-screens")

    // MARK: - Plumbing

    private func pump(_ seconds: TimeInterval = 0.03) {
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
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func capture(_ view: NSView, _ name: String) {
        try? FileManager.default.createDirectory(
            at: Self.outputDirectory, withIntermediateDirectories: true)
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
            print("[VX-144] no bitmap rep for \(name)")
            return
        }
        view.cacheDisplay(in: view.bounds, to: rep)
        guard let png = rep.representation(using: .png, properties: [:]) else { return }
        let url = Self.outputDirectory.appendingPathComponent(name)
        try? png.write(to: url)
        print("[VX-144] wrote \(url.path) \(rep.pixelsWide)x\(rep.pixelsHigh)")
        let encoded = png.base64EncodedString()
        var index = encoded.startIndex
        var part = 0
        while index < encoded.endIndex {
            let end = encoded.index(index, offsetBy: 8_000, limitedBy: encoded.endIndex)
                ?? encoded.endIndex
            print("[VX-144-PNG \(name) \(part)] \(encoded[index..<end])")
            index = end
            part += 1
        }
    }

    /// A wall-clock moment in the host's own calendar, so the rows read the
    /// way her stamps do.
    private nonisolated static func at(_ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var parts = DateComponents()
        parts.year = 2026
        parts.month = month
        parts.day = day
        parts.hour = hour
        parts.minute = minute
        return Calendar.current.date(from: parts)!
    }

    // MARK: - The seeded histories

    private struct Seeded {
        let postID: String
        let blockID: String
        let focusedVariantID: String
    }

    /// A morning-pages paragraph: one take with SIX commits — two named, one
    /// bare deliberate, three quiet (two of them a run) — and a second take
    /// with one. The everyday shape.
    private static func seedTypical(_ ops: Operations, clock: LockIsolated<Date>) throws -> Seeded {
        clock.setValue(at(10, 6, 7, 2))
        let post = try ops.createPost(title: "Morning pages")
        let minted = try ops.newBlock(
            in: post.id,
            text: "The kettle again. I keep meaning to write before the day starts talking.")
        let take = minted.variant.id
        let beats: [(Date, String, CommitKind, String?)] = [
            (at(10, 6, 7, 12),
             "The kettle again. I keep meaning to write before the day starts talking.",
             .manual, "first draft"),
            (at(10, 6, 19, 40),
             "The kettle again. I keep meaning to write before the day starts talking over me.",
             .auto, nil),
            (at(10, 7, 8, 5),
             "The kettle, again. I keep meaning to write before the day starts talking over me.",
             .auto, nil),
            (at(10, 7, 21, 30),
             "The kettle, again. I mean to write before the day starts talking over me.",
             .manual, nil),
            (at(10, 8, 10, 12),
             "The kettle, again. I mean to write before the day starts talking over me — and then I don't.",
             .manual, "before the AI edit"),
            (at(10, 9, 14, 55),
             "Kettle. I mean to write before the day starts talking over me, and then I don't.",
             .auto, nil),
        ]
        for (when, text, kind, name) in beats {
            clock.setValue(when)
            try ops.autosave(take, text: text, charDelta: 4)
            _ = try ops.commit(take, kind: kind, message: name)
        }
        clock.setValue(at(10, 9, 15, 20))
        let second = try ops.branchVariant(minted.block.id, from: take)
        try ops.autosave(second.id, text: "Kettle. Write first. The day can wait.", charDelta: 9)
        _ = try ops.commit(second.id, kind: .manual, message: "shorter")
        return Seeded(postID: post.id, blockID: minted.block.id, focusedVariantID: take)
    }

    /// The crowded case: a merged block (two originals behind it) worked over
    /// two weeks — fourteen commits on the take she is in, LONG names among
    /// them, quiet runs, a divide the older commits predate; a labelled second
    /// take with three of its own, an unlabelled third, one archived take and
    /// one deleted take.
    private static func seedCrowded(_ ops: Operations, clock: LockIsolated<Date>) throws -> Seeded {
        clock.setValue(at(9, 27, 21, 0))
        let post = try ops.createPost(title: "The lighthouse keeper")
        let first = try ops.newBlock(
            in: post.id,
            text: "The keeper climbed the stairs at dusk, counting them as he always had.")
        let second = try ops.newBlock(
            in: post.id,
            text: "Below, the sea rearranged itself around the rocks, patient and loud.")
        clock.setValue(at(9, 28, 20, 10))
        let merged = try ops.merge(first.block.id, second.block.id)
        let blockID = merged.block.id
        let take = merged.variant.id

        var text = "The keeper climbed the stairs at dusk, counting them as he always had.\n"
            + "Below, the sea rearranged itself around the rocks, patient and loud."
        func beat(_ when: Date, _ edit: String, _ kind: CommitKind, _ name: String?,
                  on variant: String) throws {
            clock.setValue(when)
            try ops.autosave(variant, text: edit, charDelta: 6)
            _ = try ops.commit(variant, kind: kind, message: name)
        }
        text = text.replacingOccurrences(of: "at dusk", with: "at dusk, slowly")
        try beat(at(9, 29, 9, 2), text, .manual, "first pass — just get it down", on: take)
        text += " The lamp was already lit."
        try beat(at(9, 29, 18, 30), text, .auto, nil, on: take)
        text = text.replacingOccurrences(of: "slowly", with: "unhurried")
        try beat(at(9, 30, 7, 45), text, .auto, nil, on: take)
        text = text.replacingOccurrences(of: "already lit", with: "lit before him")
        try beat(at(9, 30, 22, 10), text, .auto, nil, on: take)
        text = text.replacingOccurrences(of: "patient and loud", with: "loud and patient")
        try beat(at(10, 1, 11, 20), text, .manual, nil, on: take)
        text = text.replacingOccurrences(of: ", counting them as he always had", with: "")
        try beat(
            at(10, 2, 16, 5), text, .manual,
            "tightened the second sentence and moved the sea image to the end so the "
                + "paragraph lands on it instead of the stairs",
            on: take)

        // A divide: everything older now predates a split of this block.
        clock.setValue(at(10, 3, 10, 0))
        let cut = (text.firstIndex(of: "\n").map { text.distance(from: text.startIndex, to: $0) }
            ?? text.count / 2) + 1
        _ = try ops.divide(blockID, cut: cut)
        text = String(text.prefix(cut))
        text = text.trimmingCharacters(in: .whitespacesAndNewlines) + " He did not look down."
        try beat(at(10, 3, 10, 30), text, .manual, "after the split", on: take)

        // A labelled second take with three commits of its own.
        clock.setValue(at(10, 4, 9, 0))
        let colder = try ops.branchVariant(blockID, from: take)
        try ops.setTakeLabel(colder.id, label: "the colder version")
        try beat(at(10, 4, 9, 15), "The keeper climbed. The lamp was lit.", .manual,
                 "colder: no adjectives at all", on: colder.id)
        try beat(at(10, 4, 17, 40), "The keeper climbed. The lamp was lit. He did not look.",
                 .auto, nil, on: colder.id)
        try beat(at(10, 5, 8, 20), "The keeper climbed. The lamp was lit. He did not look down.",
                 .manual, nil, on: colder.id)

        text = text.replacingOccurrences(of: "He did not look down.", with: "He did not look down; he never did.")
        try beat(at(10, 5, 12, 0), text, .auto, nil, on: take)
        text = text.replacingOccurrences(of: "; he never did.", with: "; he never had.")
        try beat(at(10, 5, 23, 15), text, .auto, nil, on: take)
        try beat(at(10, 6, 9, 40), text, .manual, "her version — kept the semicolons, cut 'patient'",
                 on: take)
        text = text.replacingOccurrences(of: "unhurried", with: "unhurried, one hand on the rail")
        try beat(at(10, 7, 20, 5), text, .auto, nil, on: take)
        try beat(at(10, 8, 10, 12), text, .manual, "before the AI edit", on: take)
        text = text.replacingOccurrences(of: "one hand on the rail", with: "a hand on the cold rail")
        try beat(
            at(10, 9, 22, 48), text, .manual,
            "Final? Read it aloud twice; the rhythm of the last clause still trips, but "
                + "it's the version I'd send today if I had to",
            on: take)

        // An unlabelled third take, an archived one, a deleted one.
        clock.setValue(at(10, 9, 23, 0))
        let third = try ops.branchVariant(blockID, from: take)
        try beat(at(10, 9, 23, 5), "He climbed. Below him the sea.", .auto, nil, on: third.id)
        let shelved = try ops.branchVariant(blockID, from: take)
        try ops.autosave(shelved.id, text: "A version where the keeper is a woman.", charDelta: 4)
        try ops.archiveVariant(shelved.id)
        clock.setValue(at(10, 9, 23, 30))
        let dropped = try ops.branchVariant(blockID, from: take)
        try ops.autosave(dropped.id, text: "Too much. Way too much sea.", charDelta: 4)
        try ops.deleteVariant(dropped.id)
        return Seeded(postID: post.id, blockID: blockID, focusedVariantID: take)
    }

    // MARK: - The worlds

    private func withWorld(
        seed: UInt64,
        _ body: (AppSession, LockIsolated<Date>) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let clock = LockIsolated(Self.at(10, 1, 9, 0))
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.value }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            try await body(session, clock)
        }
    }

    private func startedTheme(
        _ session: AppSession, voice: ThemeVoice
    ) async throws -> (ThemeStore, Task<Void, Never>) {
        try session.operations.setThemeVoice(voice)
        let theme = ThemeStore(session: session)
        let task = Task { await theme.start() }
        for _ in 0..<100 where theme.settings.voice != voice {
            pump(0.02)
            await Task.yield()
        }
        print("[VX-144] theme voice=\(theme.settings.voice)")
        return (theme, task)
    }

    /// Mounts the REAL pane (no model handed in, so its own `.task` loads the
    /// history and seeds her "the take you're in is expanded" ruling exactly
    /// as the app does) and captures it.
    private func capturePane(
        _ session: AppSession, _ seeded: Seeded, theme: ThemeStore,
        dark: Bool, size: NSSize, name: String
    ) async {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: dark ? .darkAqua : .aqua)
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(
            rootView: BlockHistoryPane(
                session: session,
                request: BlockHistoryRequest(
                    postID: seeded.postID, blockID: seeded.blockID,
                    focusedVariantID: seeded.focusedVariantID),
                onClose: {}, onOpenTray: { _ in }, onJump: { _ in })
                .environment(theme)
                .environment(\.colorScheme, dark ? .dark : .light))
        hosting.appearance = window.appearance
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: { false }, maxTurns: 30)
        capture(hosting, name)
    }

    // MARK: - The captures

    @Test func captureTheCommitsPaneInBothVoicesTypicalAndCrowded() async throws {
        for voice in [ThemeVoice.study, .terminal] {
            try await withWorld(seed: 144) { session, clock in
                let typical = try Self.seedTypical(session.operations, clock: clock)
                let crowded = try Self.seedCrowded(session.operations, clock: clock)
                clock.setValue(Self.at(10, 10, 9, 0))
                let (theme, task) = try await startedTheme(session, voice: voice)
                defer { task.cancel() }
                let tag = voice == .study ? "study" : "terminal"
                // What she sees at the column's default width and an ordinary
                // window height…
                await capturePane(
                    session, typical, theme: theme, dark: false,
                    size: NSSize(width: 420, height: 820),
                    name: "vx144-typical-\(tag)-light.png")
                await capturePane(
                    session, crowded, theme: theme, dark: false,
                    size: NSSize(width: 420, height: 820),
                    name: "vx144-crowded-\(tag)-light.png")
                // …and the crowded page whole (tall, so nothing scrolls away).
                await capturePane(
                    session, crowded, theme: theme, dark: false,
                    size: NSSize(width: 420, height: 1900),
                    name: "vx144-crowded-\(tag)-light-whole.png")
                await capturePane(
                    session, crowded, theme: theme, dark: true,
                    size: NSSize(width: 420, height: 820),
                    name: "vx144-crowded-\(tag)-dark.png")
                if voice == .study {
                    // The column dragged narrower (its floor is 280; the
                    // pane's own minWidth is 300).
                    await capturePane(
                        session, crowded, theme: theme, dark: false,
                        size: NSSize(width: 320, height: 820),
                        name: "vx144-crowded-study-light-narrow.png")
                }
            }
        }
    }

    /// The pane where she meets it: the post detail's side column, opened by
    /// the history door's own request, beside the note.
    @Test func captureTheCommitsPaneInContextBesideTheNote() async throws {
        try await withWorld(seed: 145) { session, clock in
            let crowded = try Self.seedCrowded(session.operations, clock: clock)
            clock.setValue(Self.at(10, 10, 9, 0))
            let (theme, task) = try await startedTheme(session, voice: .study)
            defer { task.cancel() }
            let size = NSSize(width: 1280, height: 820)
            let window = NSWindow(
                contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: .aqua)
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(crowded.postID)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: crowded.postID)
                    .environment(theme))
            hosting.frame = NSRect(origin: .zero, size: size)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting) {
                session.commandRouter.activePostID == crowded.postID
            }
            let opened = session.commandRouter.requestBlockHistory(
                BlockHistoryRequest(
                    postID: crowded.postID, blockID: crowded.blockID,
                    focusedVariantID: crowded.focusedVariantID))
            print("[VX-144] in-context request acted=\(opened)")
            await settle(window, hosting, until: { false }, maxTurns: 40)
            capture(hosting, "vx144-in-context-study-light.png")
        }
    }
}
