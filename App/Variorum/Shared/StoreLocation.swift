//
//  StoreLocation.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, A4 — dev-store separation (author premortem, 2026-07-07). From
//  this phase the author daily-uses the app on the same machine where
//  Phases 9–11 are developed; a dev-build editor bug must not be able to
//  touch her real writing (A1's backups are the net, not the fence).
//
//  The fence: DEBUG builds default to the separate dev store. Opening the
//  REAL store from a debug build requires an explicit opt-in — the launch
//  argument `-VariorumRealStore` or the environment variable
//  `VARIORUM_REAL_STORE=1` — so implementer agents' manual smoke launches
//  can never land in her corpus. Release builds open the real store.
//
//  How she daily-drives (a Release build, or a blessed debug run via the
//  opt-in) is HER call at the Phase 8 checkpoint — the fence is the
//  requirement; this mechanism is PROVISIONAL.
//

import Foundation
import VariorumCore

enum StoreLocation {
    nonisolated static let realStoreArgument = "-VariorumRealStore"
    nonisolated static let realStoreEnvironmentKey = "VARIORUM_REAL_STORE"

    /// Pure resolution, injectable for tests; the zero-argument call is what
    /// the bootstrap uses.
    nonisolated static func resolve(
        isDebugBuild: Bool = isDebug,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> AppDatabase.StoreVariant {
        guard isDebugBuild else { return .real }
        let optedIn = arguments.contains(realStoreArgument)
            || environment[realStoreEnvironmentKey] == "1"
        return optedIn ? .real : .dev
    }

    nonisolated static var isDebug: Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
}
