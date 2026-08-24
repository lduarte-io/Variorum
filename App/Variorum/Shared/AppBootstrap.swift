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

//  13l L-c (the ruled shape, mobile round 2 §58/§62 — B45-1): the open and
//  the migration set used to run SYNCHRONOUSLY ON THE MAIN THREAD inside
//  `init`, before first paint, on every launch of both apps — a P2
//  violation (OverallModel §5). MEASURED on the simulator: 54.0 ms first
//  launch (empty store, full migration set), 5.0 ms reopen, 3.6 ms at the
//  100k proving ground — **flat in corpus size**, because the cost is
//  O(migrations), not O(corpus). On her real iPhone it read "almost
//  imperceptible" (device walk D8), so this was never a hang; what makes it
//  worth closing is the direction of travel — **the migration set only
//  grows**, every future §12 lockstep event adds to that 54 ms, and it is
//  the one main-thread store road in either app.
//
//  The shape: an `.opening` state the roots render quietly, the file work
//  on a detached task, hopping back to the MainActor for `install` and the
//  state write, `retry()` re-entering the same road. **The "UI can touch a
//  store that is not ready" window cannot open by construction** —
//  `AppSession` exists only inside `.ready`, the property the failure views
//  already rely on.

@Observable
@MainActor
final class AppBootstrap {
    enum State {
        /// The store is being opened and migrated, off the main thread.
        case opening
        case ready(AppSession)
        case failed(AppDatabase.StoreOpenError)
    }

    private(set) var state: State = .opening
    /// Which store home this process resolved to (A4) — surfaced so a dev
    /// build is visibly a dev build.
    let storeVariant: AppDatabase.StoreVariant
    /// `install` (prepareDependencies) must run exactly once per process;
    /// a retry after a failed first attempt still installs, a second success
    /// cannot happen (retry is only reachable from `.failed`).
    private var installed = false
    /// The in-flight open, so a second `retry()` cannot start a second race
    /// for the same store. Test-visible so a pin can await the road rather
    /// than poll it.
    @ObservationIgnored private(set) var opening: Task<Void, Never>?

    /// TEST-ONLY. Replaces the file work with the caller's own, **and skips
    /// the process-global `prepareDependencies` installs with it** — that
    /// coupling is the point rather than a shortcut: an injected opener
    /// means the store is a test's own, and installing a test's store as the
    /// app's ambient one would poison every other test in the process (and
    /// `prepareDependencies` may only be called before anything reads a
    /// dependency). The state machine, the off-main hop and `retry()` are
    /// otherwise exactly production's.
    @ObservationIgnored private let testOpener:
        (@Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>)?

    init(variant: AppDatabase.StoreVariant = StoreLocation.resolve()) {
        storeVariant = variant
        testOpener = nil
        beginOpening()
    }

    init(
        testOpener: @escaping @Sendable () -> Result<AppDatabase, AppDatabase.StoreOpenError>
    ) {
        storeVariant = .dev
        self.testOpener = testOpener
        beginOpening()
    }

    func retry() {
        beginOpening()
    }

    /// Awaits the in-flight open. Production never calls it (the roots
    /// render `.opening`); pins use it instead of spinning.
    func awaitOpen() async {
        await opening?.value
    }

    private func beginOpening() {
        guard opening == nil else { return }
        state = .opening
        let variant = storeVariant
        let testOpener = testOpener
        opening = Task { [weak self] in
            // OFF the main actor: `openStore` runs the migration set, which
            // is the whole point of this task existing.
            let outcome = await Task.detached(priority: .userInitiated) {
                testOpener?() ?? openStoreOffMain(variant: variant)
            }.value
            guard let self else { return }
            // …and back, for `install` (a process-global dependency
            // installation) and the state write, both of which are
            // MainActor by contract.
            self.finish(outcome)
        }
    }

    private func finish(_ outcome: Result<AppDatabase, AppDatabase.StoreOpenError>) {
        opening = nil
        switch outcome {
        case .success(let database):
            if !installed, testOpener == nil {
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
            state = .ready(AppSession(database: database))
        case .failure(let error):
            state = .failed(error)
        }
    }

}

/// The FILE work, and nothing else — resolve the URL, assert the iOS
/// protection class, open and migrate. Nonisolated on purpose: this is what
/// runs off the main actor (13l L-c), and keeping it a free function makes
/// that impossible to lose in a later refactor by accident. `install` and
/// the state write deliberately stay behind, on the MainActor.
private nonisolated func openStoreOffMain(
    variant: AppDatabase.StoreVariant
) -> Result<AppDatabase, AppDatabase.StoreOpenError> {
    do {
        let url = try AppDatabase.defaultStoreURL(variant: variant)
        #if os(iOS)
        prepareStoreDirectoryProtection(url)
        #endif
        return .success(try AppDatabase.openStore(at: url))
    } catch let error as AppDatabase.StoreOpenError {
        return .failure(error)
    } catch {
        // openStore/defaultStoreURL only throw StoreOpenError; this arm
        // keeps the compiler honest without a force-cast.
        return .failure(AppDatabase.StoreOpenError(
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
private nonisolated func prepareStoreDirectoryProtection(_ storeURL: URL) {
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
