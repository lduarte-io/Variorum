//
//  AppBootstrap.swift
//  Variorum
//
//  The recoverable database open (resolves the KnownIssues
//  "AppDatabase.liveValue failure UX" entry): open explicitly through the
//  typed path, render failure as a recovery surface, and only wire the live
//  dependency on success. The package's fatalError fallback is never reached
//  from the app.
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
    /// `install` (prepareDependencies) must run exactly once per process;
    /// a retry after a failed first attempt still installs, a second success
    /// cannot happen (retry is only reachable from `.failed`).
    private var installed = false

    init() {
        state = .failed(AppDatabase.StoreOpenError(storePath: "", reason: "not yet opened"))
        state = open()
    }

    func retry() {
        state = open()
    }

    private func open() -> State {
        do {
            let url = try AppDatabase.defaultStoreURL()
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
