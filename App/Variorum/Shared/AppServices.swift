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
    /// The Fragments journal bridge (Phase 9b). Mac-side only this phase;
    /// stays UNCONFIGURED until Phase 9c's sign-in wires an engine — the
    /// wiring below (fence, after-sync triggering, status row) is the
    /// shape 9c drops into.
    let bridge: BridgeSession
    let idleCommits: IdleCommitScheduler
    /// Rotating cold copies (A1). Wired on the Mac; nil on iOS — the
    /// phone's store is re-derivable from the mirror.
    let backup: StoreBackup?

    init(
        session: AppSession, storeVariant: AppDatabase.StoreVariant,
        backupEnabled: Bool, bridgeEnabled: Bool = false
    ) {
        // THE A4 FENCE, SYNC SEAM (review round 1, BLOCKER): only the REAL
        // store may pair with the one production mirror. Debug and release
        // builds share a bundle identity and Keychain, so a dev-store
        // session must never adopt (or accept) the pasted credentials — a
        // dev bug's writes would push to the mirror and replicate to her
        // real devices.
        sync = SyncSession(database: session.database, allowsSync: storeVariant == .real)
        // THE A4 FENCE EXTENDS TO THE BRIDGE (Phase 9b): the author's live
        // Fragments journal pairs with the REAL store only — a dev-store
        // session must never land or push against it.
        bridge = BridgeSession(allowsBridge: bridgeEnabled && storeVariant == .real)
        // Bridge rounds ride the sync cadence: AFTER each sync round, never
        // interleaved with one (a landing sees the store the mirror sync
        // just settled). Unconfigured sessions no-op.
        sync.onRoundCompleted = { [weak bridge = bridge] in
            bridge?.trigger()
        }
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
        } else {
            // No sync round will complete to carry the bridge trigger —
            // give a (configured) bridge its launch round directly.
            bridge.trigger()
        }
        idleCommits.start()
        backup?.start()
    }

    func stop() {
        sync.stop()
        bridge.stop()
        idleCommits.stop()
        backup?.stop()
    }
}
