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
            #if os(iOS)
            prepareStoreDirectoryProtection(url)
            #endif
            let database = try AppDatabase.openStore(at: url)
            if !installed {
                AppDatabase.install(database)
                // Phase 9c, Step 4/5: the live owner identity reads the
                // persisted Variorum session per call — the Keychain is the
                // truth AuthSession.adopt/signOut writes, so sign-in state
                // reaches Operations' owner_id stamping with no mutable
                // global and no re-installation.
                OwnerIdentity.install(OwnerIdentity {
                    KeychainAuthStorage.load(
                        service: KeychainAuthStorage.variorumService)?.userID
                })
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

    #if os(iOS)
    /// The deliberate protection-class pick (Phase 8 plan risk note),
    /// applied BEFORE the first open — iOS data protection is inherited at
    /// CREATION time, so the directory's class must be set while the store
    /// files don't exist yet (review round 1: a post-open attribute set
    /// protected nothing; files created earlier keep their class).
    ///
    /// `.completeUntilFirstUserAuthentication` — the same value as the
    /// platform default for third-party app data, chosen EXPLICITLY (not
    /// relied on): the store stays readable after the first unlock, so the
    /// background-transition sync round can usually finish; a complete-lock
    /// race still lands on the scheduler's offline posture. Recording the
    /// choice here means a future entitlement or OS-default change cannot
    /// silently unmake it.
    private func prepareStoreDirectoryProtection(_ storeURL: URL) {
        let directory = storeURL.deletingLastPathComponent()
        let protection: [FileAttributeKey: Any] =
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
        try? FileManager.default.createDirectory(
            at: directory, withIntermediateDirectories: true, attributes: protection)
        // Existing directory (later launches): keep the class asserted so
        // files created from now on (-wal/-shm rebuilds, backups) inherit it.
        try? FileManager.default.setAttributes(protection, ofItemAtPath: directory.path)
    }
    #endif
}
