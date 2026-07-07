//
//  AppServices.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8: the session-scoped background services both apps start after a
//  successful store open — sync lifecycle (Step 6), the idle auto-commit
//  sweep (Step 5), and (where enabled) rotating store backups (A1).
//  Composition-root property, injected downward; no globals.
//

import Foundation
import VariorumCore

@MainActor
final class AppServices {
    let sync: SyncSession
    let idleCommits: IdleCommitScheduler
    /// Rotating cold copies (A1). Wired on the Mac; nil on iOS — the
    /// phone's store is re-derivable from the mirror.
    let backup: StoreBackup?

    init(session: AppSession, storeVariant: AppDatabase.StoreVariant, backupEnabled: Bool) {
        // THE A4 FENCE, SYNC SEAM (review round 1, BLOCKER): only the REAL
        // store may pair with the one production mirror. Debug and release
        // builds share a bundle identity and Keychain, so a dev-store
        // session must never adopt (or accept) the pasted credentials — a
        // dev bug's writes would push to the mirror and replicate to her
        // real devices.
        sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)
        // The sweep's low-water mark is per-store bookkeeping: scoped by
        // variant so a dev-store sweep can never advance the real store's
        // mark (review round 1, MINOR).
        idleCommits = IdleCommitScheduler(
            database: session.database, runner: session.runner, storeVariant: storeVariant)
        if backupEnabled,
           let storeURL = try? AppDatabase.defaultStoreURL(variant: storeVariant) {
            // Backups live beside the store they copy — a dev store backs
            // up into the dev home (A4's separation holds here too).
            backup = StoreBackup(
                database: session.database,
                directory: storeURL.deletingLastPathComponent()
                    .appendingPathComponent("Backups", isDirectory: true))
        } else {
            backup = nil
        }
    }

    /// Launch: credentials from the Keychain (if pasted before; refused
    /// wholesale for dev-store sessions), a first sync round, the sweep,
    /// the backup clock.
    func start() async {
        if await sync.loadPersistedCredentials() {
            sync.triggerSync()
        }
        idleCommits.start()
        backup?.start()
    }

    func stop() {
        sync.stop()
        idleCommits.stop()
        backup?.stop()
    }
}
