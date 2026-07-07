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
        sync = SyncSession(database: session.database)
        idleCommits = IdleCommitScheduler(database: session.database, runner: session.runner)
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

    /// Launch: credentials from the Keychain (if pasted before), a first
    /// sync round, the sweep, the backup clock.
    func start() {
        if sync.loadPersistedCredentials() {
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
