//
//  AppBootstrap.swift
//  Variorum (shared: Mac + Mobile)
//
//  The recoverable database open (resolves the KnownIssues
//  "AppDatabase.liveValue failure UX" entry): open explicitly through the
//  typed path, render failure as a recovery surface, and only wire the live
//  dependency on success. The package's fatalError fallback is never reached
//  from the app.
//
//  Phase 8, A4 (dev-store separation): the bootstrap opens the variant
//  `StoreLocation.resolve()` picks — debug builds default to the SEPARATE
//  dev store; the author's real corpus is opened from a debug build only
//  via the explicit opt-in. Both paths flow through the same recoverable
//  `openStore(at:)`.
//

import Foundation
import Observation
import VariorumCore

@Observable
@MainActor
final class AppBootstrap {
    enum State {
        case ready(AppSession)
        case failed(AppDatabase.StoreOpenError)
    }

    private(set) var state: State
    /// Which store home this process resolved to (A4) — surfaced so a dev
    /// build is visibly a dev build.
    let storeVariant: AppDatabase.StoreVariant
    /// `install` (prepareDependencies) must run exactly once per process;
    /// a retry after a failed first attempt still installs, a second success
    /// cannot happen (retry is only reachable from `.failed`).
    private var installed = false

    init(variant: AppDatabase.StoreVariant = StoreLocation.resolve()) {
        storeVariant = variant
        state = .failed(AppDatabase.StoreOpenError(storePath: "", reason: "not yet opened"))
        state = open()
    }

    func retry() {
        state = open()
    }

    private func open() -> State {
        do {
            let url = try AppDatabase.defaultStoreURL(variant: storeVariant)
            let database = try AppDatabase.openStore(at: url)
            if !installed {
                AppDatabase.install(database)
                installed = true
            }
            return .ready(AppSession(database: database))
        } catch let error as AppDatabase.StoreOpenError {
            return .failed(error)
        } catch {
            // openStore/defaultStoreURL only throw StoreOpenError; this arm
            // keeps the compiler honest without a force-cast.
            return .failed(AppDatabase.StoreOpenError(
                storePath: "", reason: String(describing: error)))
        }
    }
}
