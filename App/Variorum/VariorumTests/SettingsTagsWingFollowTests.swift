//
//  SettingsTagsWingFollowTests.swift
//  VariorumTests (Mac)
//
//  VX-838 (Bug; the VX-828 run, batch E — her pick R-828-2): Settings ▸ Tags
//  NAMES its wing in its header ("Tags — in ‹wing›") and FOLLOWS the app's
//  wing live. Her report (2026-11-04): *"if I open 'settings -> tags' and i'm
//  in one wing, and then i switch wings, my settings tab stays stale on the
//  tags for the previous wing."* The run record:
//  `notes/plans/fixes/vx-828-editor-shell-qol.md`, "Batch E".
//
//  THE MECHANISM (traced at the code): `AppSettingsView` started the pane's
//  model with a plain `.task { await tags.start() }` — once per window — and
//  `start()` pins its observation to the wing current at subscription. A
//  switch restarted nothing. RootView's twin model was always keyed
//  `.task(id: session.wing.currentID)`.
//
//  RED ON OLD — `thePaneFollowsTheAppsWingLive`, by the record's revert R-E2:
//  `AppSettingsView`'s `.task(id: session.wing.currentID) { await
//  tags.start() }` back to `.task { await tags.start() }` (the pre-fix line)
//  — the mounted window keeps Home's vocabulary after the switch.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// An in-memory library with deterministic ids and clock.
@MainActor
private func withTagsWorld<T>(
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 838))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-838 — Settings ▸ Tags names its wing and follows the app's wing", .serialized)
struct SettingsTagsWingFollowTests {
    // MARK: - Mounting (the MCP pane pins' road)

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func mount<V: View>(_ view: V, size: NSSize) -> (NSWindow, NSView) {
        let window = NSWindow(
            contentRect: NSRect(origin: NSPoint(x: 40, y: 40), size: size),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(rootView: view)
        hosting.frame = NSRect(origin: .zero, size: size)
        window.contentView = hosting
        window.orderFrontRegardless()
        return (window, hosting)
    }

    private func unmount(_ window: NSWindow) {
        window.orderOut(nil)
        window.close()
        pump()
    }

    /// Lets tasks and observations deliver until `condition` holds.
    private func settle(_ host: NSView?, until condition: () -> Bool, turns: Int = 150) async {
        for _ in 0..<turns {
            host?.layoutSubtreeIfNeeded()
            host?.window?.displayIfNeeded()
            if condition() { return }
            pump()
            await Task.yield()
        }
    }

    private func paths(_ model: TagsViewModel) -> [String] { model.tags.map(\.path) }

    // MARK: - The follow (RED ON OLD — R-E2)

    /// The window open on Home lists Home's vocabulary; a switch to another
    /// wing re-lists that wing's — no stale vocabulary — and the name the
    /// header reads moves with it. A root tag made there appears there; the
    /// switch back lists Home's again.
    @Test func thePaneFollowsTheAppsWingLive() async throws {
        try await withTagsWorld { session, _ in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            try ops.createTag(name: "alpha")
            try ops.createTag(name: "beta", wingID: garden.id)

            let model = TagsViewModel(session: session)
            let (window, host) = mount(
                AppSettingsView(session: session, tags: model), size: AppSettingsView.contentSize)
            defer { unmount(window) }

            await settle(host, until: { paths(model) == ["alpha"] })
            #expect(paths(model) == ["alpha"], "opened in Home: Home's vocabulary")
            #expect(model.shownWing == .init(id: "", name: "Home"))

            session.wing.switchTo(garden.id)
            await settle(host, until: { paths(model) == ["beta"] })
            #expect(paths(model) == ["beta"], "the switch re-lists Garden's vocabulary — no stale list")
            #expect(model.shownWing == .init(id: garden.id, name: "Garden"),
                    "the header's wing moved with the list")

            // The stale pane's second symptom: a root tag minted from it lands
            // in the CURRENT wing — and now it shows where it landed.
            await model.createTag(parentID: nil, name: "gamma")
            await settle(host, until: { paths(model) == ["beta", "gamma"] })
            #expect(paths(model) == ["beta", "gamma"])

            session.wing.switchTo("")
            await settle(host, until: { paths(model) == ["alpha"] })
            #expect(paths(model) == ["alpha"], "and back: Home's again")
            #expect(model.shownWing == .init(id: "", name: "Home"))
        }
    }

    // MARK: - The name rides the list's own read

    /// The model reads its wing's NAME in the same read as the list, so a
    /// rename of the wing it shows re-titles it live — the header can never
    /// name a wing other than the one listed.
    @Test func theNameIsReadWithTheListAndFollowsARename() async throws {
        try await withTagsWorld { session, _ in
            let ops = session.operations
            let garden = try ops.createWing(name: "Garden")
            try ops.createTag(name: "beta", wingID: garden.id)
            session.wing.switchTo(garden.id)

            let model = TagsViewModel(session: session)
            let run = Task { await model.start() }
            defer { run.cancel() }
            await settle(nil, until: { model.shownWing.name == "Garden" })
            #expect(model.shownWing == .init(id: garden.id, name: "Garden"))
            #expect(paths(model) == ["beta"])

            try ops.renameWing(garden.id, to: "Orchard")
            await settle(nil, until: { model.shownWing.name == "Orchard" })
            #expect(model.shownWing.name == "Orchard", "a rename re-titles the pane live")
            #expect(paths(model) == ["beta"])
        }
    }

    // MARK: - The header's words (R-828-2)

    @Test func theTagsHeaderNamesItsWingAndNoOtherPaneChanges() {
        #expect(AppSettingsView.title(of: .tags, tagsWingName: "Home") == "Tags \u{2014} in Home")
        #expect(AppSettingsView.title(of: .tags, tagsWingName: "Garden") == "Tags \u{2014} in Garden")
        for pane in SettingsPane.allCases where pane != .tags {
            #expect(AppSettingsView.title(of: pane, tagsWingName: "Garden") == pane.title,
                    "\(pane) keeps its own title")
        }
        // The pane LIST still says "Tags" — only the header names the wing.
        #expect(SettingsPane.tags.title == "Tags")
    }
}
