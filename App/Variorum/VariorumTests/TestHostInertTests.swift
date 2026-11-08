//
//  TestHostInertTests.swift
//  VariorumTests
//
//  VX-604 — THE TEST HOST BOOTS INERT (`notes/plans/fixes/vx-912-open-source-gating.md`, "## B1 record").
//
//  THE MECHANISM: this target's suites run INSIDE the Debug app (the test host). Its root is `VariorumApp`'s
//  `@State bootstrap = AppBootstrap()` — the production init — which used to route, open the dev store and build the
//  whole ready shell beside the suites, OUTSIDE any test's scope. swift-dependencies keys its `.test` context on
//  `isTesting`, so every dependency read of that launch (first: `AppSession.init`'s `@Dependency(\.date)`) reported
//  "has no test implementation" with no test around it: a recursion through XCTest's fallback ↔ Swift Testing's interop
//  that crashed one-suite runs before their first test (2026-10-27 03:45), a "0 tests passed" false green (03:46), and
//  a failing pseudo-test — "Issues recorded without an associated test or suite" — in runs whose every real test passed
//  (the 2026-11-05 and 2026-11-08 result bundles).
//
//  THE FIX: under a test runner the production init opens NOTHING and lands in `State.hostingTests`
//  (`AppBootstrap.Launch`). The test bootstrap (`init(testStoreURL:protectionRoad:)`) is untouched.
//
//  These pins construct the production bootstrap exactly as both app roots do. In THIS process (a test runner) it is
//  the inert host's twin. The crash shape itself — a Swift-Testing-only one-suite run — is the stage leg in the record.
//

import AppKit
import Dependencies
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-604 — the test host boots inert: the production bootstrap opens nothing under a test runner")
struct TestHostInertTests {
    /// **RED ON OLD — no revert needed: this test names only the pre-fix API, so it compiles and runs on the old tree.**
    /// There the production init, under a test runner, began the protection road's open at once (`opening` set, the
    /// state `.opening`, the road composed over the real dev slot) — the open whose `finish` built `AppSession` outside
    /// any test's scope. Fixed: nothing is in flight, nothing is named.
    @Test func theProductionBootstrapBeginsNoOpenUnderATestRunner() {
        let bootstrap = AppBootstrap(variant: .dev)
        #expect(bootstrap.opening == nil, "no open is in flight in a test runner's host")
        if case .opening = bootstrap.state {
            Issue.record("the production bootstrap began opening under a test runner (the VX-604 launch)")
        }
        if case .ready = bootstrap.state {
            Issue.record("the production bootstrap must never be ready under a test runner")
        }
        #expect(bootstrap.liveStoreURL == nil, "the inert host names no store at all")
        #expect(bootstrap.roadSession == nil, "and holds no road session")
    }

    /// The state is its own fact, and every door into an open stays shut: `retry()` (the failure face's door), the
    /// copy doors' roads (a road that composes nothing reaches no slot), the lock (no policy — and, unlike `.opening`,
    /// nothing for the lock seam to wait on, so it returns at once).
    @Test func itLandsInHostingTestsAndEveryDoorStaysShut() async {
        let bootstrap = AppBootstrap(variant: .dev)
        guard case .hostingTests = bootstrap.state else {
            Issue.record("the inert host lands in .hostingTests (got \(bootstrap.state))")
            return
        }
        bootstrap.retry()
        #expect(bootstrap.opening == nil, "retry() opens nothing in the inert host")
        await bootstrap.awaitOpen()
        #expect(bootstrap.copyDoorsRoadsWithoutALibrary() == nil, "its road composes nothing — no door reaches a slot")
        #expect(bootstrap.copyDoorsRoads() == nil)
        #expect(bootstrap.roadRelockPolicy == nil && !bootstrap.canLock)
        let start = ContinuousClock.now
        await bootstrap.lock()
        #expect(ContinuousClock.now - start < .seconds(2), "the lock finds nothing to wait for and returns")
        guard case .hostingTests = bootstrap.state else {
            Issue.record("the inert host never leaves .hostingTests (got \(bootstrap.state))")
            return
        }
    }

    /// The decision is the dependency library's own test rule, read once for the process — so the host is inert
    /// exactly when its own dependency reads would be test-context reads (and an app launch never is).
    @Test func theDecisionIsTheDependencyLibrarysOwnTestRule() {
        #expect(AppBootstrap.Launch.decide(isTesting: true) == .hostingTests)
        #expect(AppBootstrap.Launch.decide(isTesting: false) == .app)
        #expect(isTesting, "IssueReporting reads this process as running tests")
        #expect(AppBootstrap.Launch.thisProcess == .hostingTests, "so this process's host is inert")
    }

    /// The faces: Settings never auto-closes on it (no library ever closed), and its face wears the panes' declared
    /// size, so the real Settings window a suite opens keeps the real window's geometry (`SettingsTitleClearanceTests`).
    @Test func theSettingsFaceKeepsThePanesGeometry() {
        #expect(!SettingsSceneContent.libraryClosed(.hostingTests), "nothing closed — the window stays")
        #expect(SettingsSceneContent.nonReadyFace(.hostingTests) == .hostingTests)
        let bootstrap = AppBootstrap(variant: .dev)
        let hosting = NSHostingView(rootView: SettingsSceneContent(
            bootstrap: bootstrap, services: nil,
            appearance: nil, updates: nil, crashReports: nil, mcp: nil,
            libraryOpen: LibraryOpenPresenter(), handOff: LibraryHandOffPresenter()))
        #expect(hosting.fittingSize == AppSettingsView.contentSize,
                "the inert face is the panes' size (\(hosting.fittingSize) vs \(AppSettingsView.contentSize))")
    }
}
