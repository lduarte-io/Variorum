//
//  NoteMemoryDefaults.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  VX-97 · VX-666 · VX-695 (the VX-926 run, U4 — `notes/plans/fixes/vx-926-test-flakes.md`,
//  "## U4 record"): **THE ONE DEFAULTS DOMAIN behind every per-note view memory** — the
//  remembered surface sizes (`SurfaceSizeMemory`), the current block (`CurrentBlockMemory`),
//  the mode (`postMode.<id>`), Read's face (`readFace.<id>`), the Takes board's columns and
//  slot heights, the Canvas's view memory, and the book Index's grouping. Each of them names
//  `store` where it used to name `UserDefaults.standard`; nothing else about any of them
//  changed — the same keys, the same values, the same write cadence.
//
//  **In the app, `store` IS `UserDefaults.standard`** — the very object, so the app reads and
//  writes exactly what it always did (`resolve`'s `.app` arm returns it untouched).
//
//  **In a test runner's host it is a suite of its own, emptied when the process first asks**
//  (`hostedTestsSuiteName`). The app target's suites run INSIDE the Debug app, and these
//  memories are keyed by note id while the fixtures mint ids `.incrementing` from zero — so
//  every mounted suite used to persist its notes' memories into the dev app's REAL domain
//  (`io.lduarte.Variorum.debug`), where a later suite (in this run or any later one) minting
//  the same id could read them back: by 2026-10-28 the domain held 2,622 such keys (of its
//  2,731). VX-695's band test went red machine-wide on that accumulated domain and green
//  after the 10-28 scrub removed exactly these families — a cause shown by subtraction only;
//  the road inside the test is NOT yet traced (VX-695 is PENDING its discriminating legs
//  A/A′/B — the U4 record). The decision is the inert host's (VX-604): `AppBootstrap.Launch` —
//  IssueReporting's `isTesting`, decided once per process. A run therefore starts with no
//  memory at all and never reads an earlier run's; the dev app's domain is never written by a
//  test host; and a pin that plants a memory plants it HERE (`store`), the domain the product
//  will read.
//
//  **What the seam does not do (named, not hidden):** inside ONE run the suites still share
//  this domain, so two suites minting the same `.incrementing` id can still meet each other's
//  memories within that run — the tests that care keep their own clean slate, exactly as
//  before (VersionDoorsTests, BlockHistoryPaneTests, the band test's `enterOn`). And the
//  app's GLOBAL preferences (the grid density, the paragraph gap, the column widths, the
//  `@AppStorage` keys) are not per-note memories and stay on `UserDefaults.standard`, where
//  the tests that change them save and restore them.
//

import Foundation

enum NoteMemoryDefaults {
    /// The suite a test runner's host keeps the per-note memories in — never the app's own
    /// domain, never read by the app.
    static let hostedTestsSuiteName = "io.lduarte.Variorum.hosted-tests.note-memory"

    /// The domain this process's per-note memories live in, decided once (the first ask).
    static let store: UserDefaults = resolve(AppBootstrap.Launch.thisProcess)

    /// The rule. The app keeps its per-note memories in its own domain (`appDomain` — the
    /// `.standard` every one of these memories has always written); a test runner's host keeps
    /// them in `hostedSuiteName`, EMPTIED here, so a run begins with no memory and never reads
    /// another run's. `appDomain` and `hostedSuiteName` are parameters only so a pin can hand
    /// in scratch domains and never touch a real one.
    static func resolve(
        _ launch: AppBootstrap.Launch,
        appDomain: @autoclosure () -> UserDefaults = .standard,
        hostedSuiteName: String = hostedTestsSuiteName
    ) -> UserDefaults {
        switch launch {
        case .app:
            return appDomain()
        case .hostingTests:
            // `UserDefaults(suiteName:)` refuses only the app's own bundle identifier and the
            // global domain; a name this fixed never meets either. Falling back to the app's
            // domain would silently re-open the leak, so a refusal stops the host instead.
            guard let suite = UserDefaults(suiteName: hostedSuiteName) else {
                preconditionFailure("NoteMemoryDefaults: the hosted suite \(hostedSuiteName) was refused")
            }
            suite.removePersistentDomain(forName: hostedSuiteName)
            return suite
        }
    }
}
