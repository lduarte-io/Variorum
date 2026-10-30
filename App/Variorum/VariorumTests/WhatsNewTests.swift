//
//  WhatsNewTests.swift
//  VariorumTests
//
//  Phase 13r U3-A — What's New, built to the architect's recorded reading:
//  a FRESH install records its version silently and shows NOTHING; the
//  sheet appears only on a version CHANGE from a recorded one — once — and
//  Help ▸ What's New shows it on demand. Pinned across a simulated run of
//  launches and version bumps (each "launch" is a fresh ledger over the same
//  defaults, exactly as each process makes its own), in a throwaway defaults
//  suite (never the dev store's own domain).
//
//  Plus the ONE source: the running build's marketing version carries its
//  notes in the bundle (so a version bump without notes is a red test here,
//  as it is a refusal in `release.sh`), and the small grammar both renderers
//  agree on.
//

import Foundation
import Testing
@testable import Variorum

@Suite("What's New (13r U3-A — silent when fresh, once per version change)")
@MainActor
struct WhatsNewTests {
    private static func withSuite(_ body: (UserDefaults) throws -> Void) rethrows {
        let name = "variorum.tests.whatsnew.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(defaults)
    }

    /// One "launch": a fresh ledger over the same defaults; true when this
    /// launch shows the sheet (claimed, and — as the sheet does when it is
    /// on screen — settled).
    private static func launch(_ version: String, _ defaults: UserDefaults) -> Bool {
        let ledger = WhatsNewLedger(currentVersion: version, defaults: defaults)
        guard ledger.claimAutoShow() else { return false }
        ledger.markShown()
        return true
    }

    /// THE ARCHITECT'S READING: nothing greets a first open.
    @Test func aFreshInstallRecordsItsVersionSilentlyAndShowsNothing() {
        Self.withSuite { defaults in
            let ledger = WhatsNewLedger(currentVersion: "0.9.0", defaults: defaults)
            #expect(ledger.isDue == false)
            #expect(ledger.claimAutoShow() == false)
            #expect(defaults.string(forKey: WhatsNewLedger.recordKey) == "0.9.0",
                    "the version is recorded at once, silently")
        }
    }

    /// THE SHOW-ONCE, across a simulated run of launches and bumps.
    @Test func theSheetShowsOncePerVersionChangeAcrossLaunches() {
        Self.withSuite { defaults in
            #expect(Self.launch("0.9.0", defaults) == false, "fresh: silent")
            #expect(Self.launch("0.9.0", defaults) == false, "same version: nothing")
            #expect(Self.launch("0.9.1", defaults) == true, "the update: shown once")
            #expect(Self.launch("0.9.1", defaults) == false, "the next launch: not again")
            #expect(Self.launch("0.9.1", defaults) == false)
            #expect(Self.launch("0.9.2", defaults) == true, "the next update: shown once")
            #expect(Self.launch("0.9.2", defaults) == false)
        }
    }

    /// One automatic show per process, however many windows ask.
    @Test func onlyTheFirstWindowClaimsTheAutomaticShow() {
        Self.withSuite { defaults in
            defaults.set("0.9.0", forKey: WhatsNewLedger.recordKey)
            let ledger = WhatsNewLedger(currentVersion: "0.9.1", defaults: defaults)
            #expect(ledger.claimAutoShow() == true)
            #expect(ledger.claimAutoShow() == false)
        }
    }

    /// A sheet that never reached the screen does not count as seen: the
    /// version is settled by the sheet's own appearance, not by the claim.
    @Test func aClaimThatNeverShowedLeavesTheVersionDueNextLaunch() {
        Self.withSuite { defaults in
            defaults.set("0.9.0", forKey: WhatsNewLedger.recordKey)
            let first = WhatsNewLedger(currentVersion: "0.9.1", defaults: defaults)
            #expect(first.claimAutoShow() == true)  // …and the sheet never appeared
            let next = WhatsNewLedger(currentVersion: "0.9.1", defaults: defaults)
            #expect(next.isDue == true)
        }
    }

    /// THE ONE SOURCE: this build's marketing version ships its notes.
    @Test func theRunningVersionCarriesItsNotesInTheBundle() throws {
        let version = WhatsNewLedger.thisAppsVersion
        let notes = try #require(ReleaseNotes.source(for: version),
                                 "no ReleaseNotes-\(version).md in the bundle")
        let blocks = ReleaseNotes.blocks(from: notes)
        #expect(!blocks.isEmpty)
        #expect(blocks.contains { if case .heading = $0 { true } else { false } })
        #expect(ReleaseNotes.source(for: "0.0.0-no-such-version") == nil)
    }

    /// VX-708 — release notes are PUBLIC COPY: every notes file ships verbatim
    /// in the What's New sheet and the appcast's update alert, so no ticket id,
    /// draft marker or process line may land in ANY of them, not just the
    /// running version's (the release scripts refuse the same shape at the
    /// release window via `Tools/Release/notes-guard.sh`; this pins it at
    /// closeout time, over the source files themselves).
    @Test func noReleaseNotesFileCarriesProcessText() throws {
        let folder = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Variorum/Features/WhatsNew")
        let files = try FileManager.default
            .contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("ReleaseNotes-") && $0.pathExtension == "md" }
        #expect(files.count >= 16, "the WhatsNew folder should hold every release's notes file")
        let ticketID = #/(?i)\b(vx|vm)-[0-9]/#
        let draftMarker = #/(?im)^\*?draft(ed)?\b|one line per bullet|her rewrite/#
        for file in files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let text = try String(contentsOf: file, encoding: .utf8)
            #expect(text.firstMatch(of: ticketID) == nil,
                    "\(file.lastPathComponent) names a ticket — public copy never does (VX-708)")
            #expect(text.firstMatch(of: draftMarker) == nil,
                    "\(file.lastPathComponent) carries a draft/process marker (VX-708)")
        }
    }

    @Test func theGrammarIsHeadingsBulletsAndJoinedParagraphs() {
        let blocks = ReleaseNotes.blocks(from: """
            First line
            continues here.

            ## New
            - one **bold** thing
            * another

            # Big
            ### Small
            Last.
            """)
        #expect(blocks == [
            .paragraph("First line continues here."),
            .heading("New"),
            .bullet("one **bold** thing"),
            .bullet("another"),
            .heading("Big"),
            .heading("Small"),
            .paragraph("Last."),
        ])
    }

    /// The Help door: rendered in the Help group, a request the window adopts.
    @Test func theHelpMenuCarriesTheWhatsNewDoor() throws {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Variorum/EditorCommands.swift")
        let file = try String(contentsOf: url, encoding: .utf8)
        #expect(file.contains(
            "Button(WhatsNewCopy.menuTitle) { windows.creationRouter()?.whatsNewRequested = true }"))
        #expect(WhatsNewCopy.menuTitle == "What\u{2019}s New")
    }
}
