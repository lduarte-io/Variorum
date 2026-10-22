//
//  WhatsNewWaitsAfterAdoptionTests.swift
//  VariorumTests — VX-329 R1: VX-468 (VX-309's walk, row 3: the 0.9.8 What's New card greeted the adopted library's first
//  open). Her ruling at the 2026-10-22 sitting (QUESTIONS #237): "wait." The ledger is decided once per process and
//  claimed by the first ready window's appearance; a launch that opens on the missing face or rule 27's lobby has no ready
//  window until a copy door lands, so the adopted library's first open WAS the first window — and the card greeted it. A
//  copy door that lands a library in this process (Make this my library, the empty slot's landing, a plain-text copy
//  brought in) now makes this process's automatic show wait; the version stays UNRECORDED, so the next ordinary launch
//  shows it (the calm-first-open rule's idiom). Help ▸ What's New is untouched. Also runs headless in the implementer's
//  SwiftPM harness (the ledger alone — `WhatsNewLedger.swift`).
//

import Foundation
import Testing

@testable import Variorum

@Suite("VX-468 — What's New waits after a library is adopted (her \"wait\")")
@MainActor
struct WhatsNewWaitsAfterAdoptionTests {
    private static func withSuite(_ body: (UserDefaults) throws -> Void) rethrows {
        let name = "variorum.tests.whatsnew.vx468.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        try body(defaults)
    }

    /// A version change is due; this process adopted a library before its first ready window: no card at that open, none
    /// in any later window of this process, the version left unrecorded — and the next ordinary launch shows it once.
    @Test func aDueShowWaitsForTheNextLaunchWhenThisProcessAdoptedALibrary() {
        Self.withSuite { defaults in
            defaults.set("0.9.8", forKey: WhatsNewLedger.recordKey)
            let ledger = WhatsNewLedger(currentVersion: "0.10", defaults: defaults)
            #expect(ledger.isDue)
            #expect(ledger.claimAutoShow(afterAdoption: true) == false, "the adopted library's first open is calm")
            #expect(ledger.claimAutoShow() == false, "nor a later window of this process")
            #expect(defaults.string(forKey: WhatsNewLedger.recordKey) == "0.9.8", "the version stays unrecorded")
            let next = WhatsNewLedger(currentVersion: "0.10", defaults: defaults)
            #expect(next.claimAutoShow() == true, "the next ordinary launch shows it")
            next.markShown()
            #expect(WhatsNewLedger(currentVersion: "0.10", defaults: defaults).claimAutoShow() == false, "once")
        }
    }

    /// Unchanged: an ordinary first window claims the show once; a fresh install stays silent either way.
    @Test func anOrdinaryLaunchStillShowsOnceAndAFreshInstallStaysSilent() {
        Self.withSuite { defaults in
            defaults.set("0.9.8", forKey: WhatsNewLedger.recordKey)
            let ledger = WhatsNewLedger(currentVersion: "0.10", defaults: defaults)
            #expect(ledger.claimAutoShow(afterAdoption: false) == true)
            #expect(ledger.claimAutoShow(afterAdoption: false) == false, "one automatic show per process")
        }
        Self.withSuite { defaults in
            let fresh = WhatsNewLedger(currentVersion: "0.10", defaults: defaults)
            #expect(fresh.claimAutoShow(afterAdoption: true) == false && fresh.claimAutoShow() == false)
        }
    }
}

/// THE COMPOSITION, read from the product's sources: every copy door's landing in the bootstrap marks the process, the
/// Mac root hands the mark to the ready window, and the window's one claim reads it. Red on the pre-fix tree (no mark).
@Suite("VX-468 — the wait's composition (source)")
struct WhatsNewWaitsCompositionTests {
    /// `App/Variorum/` — through the symlink a headless harness reads this file by, when there is one.
    static let appRoot = URL(fileURLWithPath: #filePath).resolvingSymlinksInPath()
        .deletingLastPathComponent()  // VariorumTests
        .deletingLastPathComponent()  // App/Variorum

    /// A source's CODE — every line with its `//` comment cut off (only code counts).
    static func code(_ relative: String) throws -> String {
        try String(contentsOf: appRoot.appendingPathComponent(relative), encoding: .utf8)
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line in line.range(of: "//").map { String(line[..<$0.lowerBound]) } ?? String(line) }
            .joined(separator: "\n")
    }

    /// The body of `func <name>(` up to the next `    func ` at the type's indentation.
    static func body(of name: String, in text: String) throws -> String {
        let start = try #require(text.range(of: "    func \(name)("), "\(name) is in the bootstrap")
        let rest = text[start.upperBound...]
        let end = rest.range(of: "\n    func ")?.lowerBound ?? rest.endIndex
        return String(rest[..<end])
    }

    @Test func everyCopyDoorLandingMarksTheProcessAndTheReadyWindowReadsIt() throws {
        let bootstrap = try Self.code("Shared/AppBootstrap.swift")
        for landing in ["makeThisMyLibrary", "makeThisMyLibraryInTheEmptySlot", "bringInPlaintextExport"] {
            #expect(try Self.body(of: landing, in: bootstrap).contains("adoptedALibraryThisProcess = true"),
                    "\(landing) marks the process when it lands a library")
        }
        let root = try Self.code("Variorum/VariorumApp.swift")
        let rootView = try #require(root.range(of: "RootView("))
        #expect(root[rootView.lowerBound...].prefix(900).contains("whatsNewWaits: bootstrap.adoptedALibraryThisProcess"),
                "the root hands the mark to the ready window")
        let shell = try Self.code("Variorum/RootView.swift")
        #expect(shell.contains("claimAutoShow(afterAdoption: whatsNewWaits)"), "the window's one claim reads it")
    }
}
