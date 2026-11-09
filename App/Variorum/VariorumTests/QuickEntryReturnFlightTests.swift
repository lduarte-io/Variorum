//
//  QuickEntryReturnFlightTests.swift
//  VariorumTests (Mac)
//
//  VX-928 (the VX-915 run, batch 3 — a rider): the quick-entry band's ⏎ had
//  no in-flight guard. Every ⏎ spawns `Task { await box.submit() … }`, and
//  `QuickEntryModel.submit()` clears the box only AFTER the mint returns (the
//  mint is a database write off the main actor — a real suspension), so two
//  presses inside one mint read the SAME words and minted them twice, each
//  Task opening its note. VX-911's ⌘⏎ road carried the one guard
//  (`filingWithoutOpening`), and it guarded only itself: a ⏎ during a ⌘⏎
//  flight, or a ⌘⏎ during a ⏎ flight, minted again too.
//
//  THE FIX (the record: `notes/plans/fixes/vx-915-recents-sweep.md`, BATCH 3):
//  the ONE guard moves to where both roads meet — one in-flight flag, one
//  helper each road enters — so a press on either road during either road's
//  flight lands on that filing. Never a second copy of the rule.
//
//  A BUG: these are RED ON OLD (committed before the fix; the red leg is the
//  gate's — the recipe is in the record).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Rig

@MainActor
private enum FlightRig {
    static func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    /// Main-queue turns PASS (`QuickEntryFileWithoutOpeningTests`' rig).
    static func settle(
        _ window: NSWindow, turns: Int = 12, until predicate: () -> Bool = { false }
    ) async {
        for _ in 0..<turns {
            window.contentView?.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    static func box(in view: NSView) -> CaptureNSTextView? {
        if let found = view as? CaptureNSTextView { return found }
        for sub in view.subviews {
            if let found = box(in: sub) { return found }
        }
        return nil
    }

    static func window(hosting: NSView, size: NSSize) -> NSWindow {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: size.width, height: size.height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return window
    }

    static func close(_ window: NSWindow) {
        window.orderOut(nil)
        window.contentView = nil
        window.close()
    }

    static func returnKey(windowNumber: Int) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: 0, windowNumber: windowNumber, context: nil,
            characters: "\r", charactersIgnoringModifiers: "\r",
            isARepeat: false, keyCode: 36)!
    }

    static func livePostIDs(_ db: AppDatabase) async throws -> [String] {
        try await db.read {
            try String.fetchAll(
                $0, sql: "SELECT id FROM container WHERE kind = 'post' AND deleted_at IS NULL")
        }
    }
}

@MainActor
private final class Mints {
    var texts: [String] = []
    var opened: [String] = []
}

@MainActor
private func withFlightWorld<T>(
    seed: UInt64, _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// A mint that holds the flight open long enough for a second press to land
/// inside it, and records what each mint was asked to file.
@MainActor
private func slowMint(_ mints: Mints) -> (String, String?) async throws -> String {
    { text, _ in
        mints.texts.append(text)
        try await Task.sleep(for: .milliseconds(60))
        return "p-\(mints.texts.count)"
    }
}

// MARK: - The model's roads

/// Wait (bounded) until the first press's mint is in the air — the second
/// press is then made INSIDE that flight, deterministically.
@MainActor
private func untilInFlight(_ mints: Mints) async {
    for _ in 0..<500 {
        if !mints.texts.isEmpty { return }
        await Task.yield()
    }
}

@MainActor
@Suite("VX-928 — one filing per flight, on both of the band's roads", .serialized)
struct QuickEntryReturnFlightModelTests {
    /// THE BUG: two ⏎ presses inside one mint file ONCE — the second lands on
    /// the first's filing. RED ON OLD: `submit()` had no guard, so the second
    /// read the same words and minted them again.
    @Test func twoReturnsInOneFlightFileOnce() async throws {
        try await withFlightWorld(seed: 928) { session, _ in
            let box = QuickEntryModel(session: session)
            let mints = Mints()
            box.mint = slowMint(mints)
            box.text = "once"
            let first = Task { await box.submit() }
            await untilInFlight(mints)
            #expect(mints.texts == ["once"], "premise: the first press is in the air")
            let second = await box.submit()
            let landed = await first.value
            #expect(mints.texts == ["once"], "one mint for one capture")
            #expect(landed != nil, "the first press is the filing")
            #expect(second == nil, "the second press inside it files nothing more")
            #expect(box.text.isEmpty, "the filed words left the box")
        }
    }

    /// The cross-flight arm, one way: a ⌘⏎ (or the button) pressed while a ⏎
    /// is filing lands on that filing. RED ON OLD: the ⌘⏎ road's guard read
    /// only its own flag, which ⏎'s road never set.
    @Test func aCommandReturnDuringAReturnFlightFilesNothingMore() async throws {
        try await withFlightWorld(seed: 929) { session, _ in
            let box = QuickEntryModel(session: session)
            let mints = Mints()
            box.mint = slowMint(mints)
            box.text = "once"
            let opening = Task { await box.submit() }
            await untilInFlight(mints)
            let staying = await box.fileWithoutOpening { _ in }
            let landed = await opening.value
            #expect(mints.texts == ["once"], "one mint for one capture")
            #expect(landed != nil, "the ⏎ that started the flight is the filing")
            #expect(staying == nil, "the ⌘⏎ inside it files nothing more")
        }
    }

    /// …and the other way: a ⏎ pressed while a ⌘⏎ is filing lands on that
    /// filing. RED ON OLD: `submit()` had no guard at all.
    @Test func aReturnDuringACommandReturnFlightFilesNothingMore() async throws {
        try await withFlightWorld(seed: 930) { session, _ in
            let box = QuickEntryModel(session: session)
            let mints = Mints()
            box.mint = slowMint(mints)
            box.text = "once"
            let staying = Task { await box.fileWithoutOpening { _ in } }
            await untilInFlight(mints)
            let opening = await box.submit()
            let landed = await staying.value
            #expect(mints.texts == ["once"], "one mint for one capture")
            #expect(landed != nil, "the ⌘⏎ that started the flight is the filing")
            #expect(opening == nil, "the ⏎ inside it files nothing more")
        }
    }

    /// The guard is a FLIGHT, never a latch: the button is grey while a filing
    /// of EITHER road is in the air (RED ON OLD: `canFile` read only the ⌘⏎
    /// road's flag), and once a filing lands the next press files again, on
    /// either road.
    @Test func theGuardLiftsWhenTheFlightLandsAndTheButtonGreysThroughEither() async throws {
        try await withFlightWorld(seed: 931) { session, _ in
            let box = QuickEntryModel(session: session)
            let mints = Mints()
            box.mint = slowMint(mints)
            box.text = "first"
            let flight = Task { await box.submit() }
            await untilInFlight(mints)
            #expect(!box.canFile, "grey while a ⏎ filing is in flight")
            #expect(await flight.value != nil)
            box.text = "second"
            #expect(box.canFile)
            #expect(await box.fileWithoutOpening { _ in } != nil)
            box.text = "third"
            #expect(await box.submit() != nil)
            #expect(mints.texts == ["first", "second", "third"])
        }
    }
}

// MARK: - The band, mounted

@MainActor
@Suite("VX-928 — two ⏎ presses in the mounted band", .serialized)
struct QuickEntryReturnFlightKeyTests {
    /// THE USER-FACING CLASS: two ⏎ key-downs delivered into the band's box
    /// inside one mint (the real store road — its write suspends off the main
    /// actor) make ONE note and open it ONCE. RED ON OLD: two notes, both
    /// opened.
    @Test func twoReturnKeysInsideOneMintFileAndOpenOnce() async throws {
        try await withFlightWorld(seed: 932) { session, db in
            let mints = Mints()
            let hosting = NSHostingView(rootView: QuickEntryBar(
                session: session,
                onOpen: { selection in
                    if case .post(let id) = selection { mints.opened.append(id) }
                }))
            let window = FlightRig.window(hosting: hosting, size: NSSize(width: 640, height: 160))
            defer { FlightRig.close(window) }
            await FlightRig.settle(window, turns: 15) { FlightRig.box(in: hosting) != nil }
            let box = try #require(FlightRig.box(in: hosting), "the box mounted")
            window.makeFirstResponder(box)
            box.insertText("pressed twice", replacementRange: box.selectedRange())
            await FlightRig.settle(window, turns: 3)

            // Both presses in ONE main-actor turn: the second lands while the
            // first's mint is still in the air.
            let key = FlightRig.returnKey(windowNumber: window.windowNumber)
            box.keyDown(with: key)
            box.keyDown(with: key)
            await FlightRig.settle(window, turns: 100) { !mints.opened.isEmpty && box.string.isEmpty }
            await FlightRig.settle(window, turns: 10)

            let posts = try await FlightRig.livePostIDs(db)
            #expect(posts.count == 1, "one note from one capture")
            #expect(mints.opened.count == 1, "opened once")
            #expect(mints.opened == posts)
        }
    }
}
