//
//  WhatsNewLedger.swift
//  Variorum (MAC ONLY)
//
//  Phase 13r U3-A — What's New's LEDGER (moved byte-for-byte out of
//  `WhatsNew.swift` at VX-329 R1 — its header carries the feature's reading):
//  a LOCAL preference of this app on this Mac, the last marketing version
//  What's New was settled for; decided ONCE per process at launch; a FRESH
//  install records silently and shows nothing.
//

import Foundation

@MainActor
final class WhatsNewLedger {
    /// The local preference: the marketing version last settled.
    nonisolated static let recordKey = "variorum.whatsNew.lastVersion"

    let currentVersion: String
    private let defaults: UserDefaults
    /// Decided ONCE at launch: true only when a RECORDED version differs.
    private(set) var isDue: Bool
    /// One automatic presentation per process, whichever window asks first.
    private var claimed = false

    init(currentVersion: String, defaults: UserDefaults) {
        self.currentVersion = currentVersion
        self.defaults = defaults
        if let recorded = defaults.string(forKey: Self.recordKey) {
            isDue = recorded != currentVersion
        } else {
            // FRESH: record silently; nothing greets a first open.
            defaults.set(currentVersion, forKey: Self.recordKey)
            isDue = false
        }
    }

    /// The app's own ledger (the app delegate holds the one instance).
    static func forThisApp() -> WhatsNewLedger {
        WhatsNewLedger(currentVersion: thisAppsVersion, defaults: .standard)
    }

    /// The running app's marketing version.
    nonisolated static var thisAppsVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    /// The automatic show's ticket: true exactly once, and only when due.
    /// VX-468 (her "wait", QUESTIONS #237): `adopted` — this process landed a library through a copy door (Make this my
    /// library, the empty slot's landing, a plain-text copy brought in) before this first claim. The adopted library's
    /// first open is calm: the ticket is spent for this process and the version stays UNRECORDED (no sheet appears, so
    /// `markShown` never runs), so the next ordinary launch shows it.
    func claimAutoShow(afterAdoption adopted: Bool = false) -> Bool {
        guard isDue, !claimed else { return false }
        claimed = true
        return !adopted
    }

    /// The sheet appeared: this version is settled; the next launch is quiet.
    func markShown() {
        defaults.set(currentVersion, forKey: Self.recordKey)
        isDue = false
    }
}
