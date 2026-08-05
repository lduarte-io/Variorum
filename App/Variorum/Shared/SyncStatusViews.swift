//
//  SyncStatusViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the one-row functional sync status surface (SyncSpec
//  §10's "sync status indicator" scope, nothing more). Phase 9c, Step 5:
//  the paste-in form (SyncSetupView) is DELETED — the row's door is the
//  sign-in surface (AccountView), and an unconfigured row means signed
//  out, not credential-less. Views render state and send actions only;
//  functional and unstyled (Phase 13 owns beauty).
//
//  Phase 14b CROSSOVER ROUND (CF-14/15/16): the row's doors are now PURE
//  DATA (`SyncRowFace`) and the view renders exactly what the face says —
//  so the pins assert door presence, enablement, and targets at the state
//  level, and none of the ruled shapes can drift from what ships:
//   - CF-15 (her ruling: "the sync row's buttons must not move"): the
//     syncing state KEEPS "Sync now" (disabled) and "Account…" in place;
//     the progress indicator rides beside the label — the old
//     replace-the-content branch is retired.
//   - CF-14: the separate "Encryption…" door retires into the Account
//     sheet's Encryption tab; the LOCKED state's "Unlock…" stays in place
//     and opens that tab DIRECTLY (one act — the refusal's own
//     affordance).
//   - CF-16 (the classifier arm): the engine's payload-crypto refusal —
//     stale keys after a re-key are its everyday cause — presents as the
//     replaced-keys line naming its fix, with the same one-act door.
//

import SwiftUI
import VariorumCore

/// CF-14/15/16: the sync row's face as pure data — which state family the
/// row is in, and exactly which doors it offers. The view renders FROM
/// this (doors are never minted view-side), so the state-level pins and
/// the shipped row cannot diverge.
nonisolated struct SyncRowFace: Equatable {
    enum Kind: Equatable {
        case devStore, signedOut, syncOff, syncing, offline
        case keysLocked, keysReplaced, notEntitled, error, idle
    }

    struct Door: Equatable, Identifiable {
        enum Act: Equatable {
            /// Trigger a round (serves "Sync now" and "Retry" alike).
            case syncNow
            /// Open the tabbed Account sheet at the named tab (CF-14).
            case openAccount(AccountTab)
        }
        var label: String
        var act: Act
        var enabled: Bool = true
        var id: String { label }
    }

    var kind: Kind
    var doors: [Door]

    static func face(
        allowsSync: Bool,
        isConfigured: Bool,
        signedIn: Bool,
        isSyncing: Bool,
        lastError: String?,
        lastErrorIsOffline: Bool
    ) -> SyncRowFace {
        // The A4 fence: a dev-store session never syncs — no sign-in door
        // either (the one mirror belongs to the real store; signing in
        // belongs to real-store sessions).
        guard allowsSync else { return SyncRowFace(kind: .devStore, doors: []) }
        guard isConfigured else {
            return SyncRowFace(
                kind: signedIn ? .syncOff : .signedOut,
                doors: [Door(label: "Sign in…", act: .openAccount(.account))])
        }
        if isSyncing {
            // CF-15 (her ruling): the doors DO NOT move while a round runs
            // — "Sync now" stays present and merely disables.
            return SyncRowFace(kind: .syncing, doors: [
                Door(label: "Sync now", act: .syncNow, enabled: false),
                Door(label: "Account…", act: .openAccount(.account)),
            ])
        }
        if let error = lastError {
            if lastErrorIsOffline {
                // Phase 11, Step A0: offline is a designed-for state
                // (outbox kept, next trigger retries) — waiting, never an
                // error face.
                return SyncRowFace(kind: .offline, doors: [
                    Door(label: "Sync now", act: .syncNow),
                ])
            }
            if EncryptionSession.isKeysLockedError(error) {
                // Phase 14b (L9): the keys-refusal presents as a paused
                // state naming its fix; CF-14 keeps its door IN PLACE,
                // opening the Encryption tab directly.
                return SyncRowFace(kind: .keysLocked, doors: [
                    Door(label: "Unlock…", act: .openAccount(.encryption)),
                ])
            }
            if EncryptionSession.isPayloadCryptoError(error)
                || EncryptionSession.isKeysReplacedError(error) {
                // CF-16: after a re-key, a stale device's rounds fail —
                // since Phase 14c at the server's vault-key-id fence
                // (BEFORE any poison push), and as payload-crypto
                // refusals on anything that slipped past — both present
                // as the replaced-keys line naming the real fix instead
                // of a generic error face.
                return SyncRowFace(kind: .keysReplaced, doors: [
                    Door(label: "Re-enroll…", act: .openAccount(.encryption)),
                ])
            }
            if HostedSyncTier.isNotEntitledError(error) {
                // Phase 14c batch 3 (L7): the tier refusal is NOT an error
                // — the app is whole without the tier (the v1 principle:
                // an unentitled state reads as NORMAL, never degraded).
                // The doors are the IDLE row's own — "Sync now" retries
                // once the plan is active (the heal needs no relaunch),
                // and "Account…" opens the tab whose tier section says
                // what the tier is and where it lives.
                return SyncRowFace(kind: .notEntitled, doors: [
                    Door(label: "Sync now", act: .syncNow),
                    Door(label: "Account…", act: .openAccount(.account)),
                ])
            }
            return SyncRowFace(kind: .error, doors: [
                Door(label: "Retry", act: .syncNow),
                Door(label: "Account…", act: .openAccount(.account)),
            ])
        }
        return SyncRowFace(kind: .idle, doors: [
            Door(label: "Sync now", act: .syncNow),
            Door(label: "Account…", act: .openAccount(.account)),
        ])
    }
}

/// One row: signed-in + configured → last sync / pending / error;
/// signed out → the sign-in door.
struct SyncStatusRow: View {
    let services: AppServices
    /// CF-14: the ONE sheet, opened at the tab the pressed door names
    /// (nil = not presented).
    @State private var accountSheetTab: AccountTab?

    private var sync: SyncSession { services.sync }

    private var face: SyncRowFace {
        SyncRowFace.face(
            allowsSync: sync.allowsSync,
            isConfigured: sync.isConfigured,
            signedIn: services.account.variorum != nil,
            isSyncing: sync.status.isSyncing,
            lastError: sync.status.lastError,
            lastErrorIsOffline: sync.status.lastErrorIsOffline)
    }

    var body: some View {
        let face = self.face
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                rowLabel(for: face.kind)
                ForEach(face.doors) { door in
                    Button(door.label) { perform(door.act) }
                        .disabled(!door.enabled)
                }
            }
            // Sitting 9 (R94): the cause inline, classified — an auth-shaped
            // failure names its fix and the Account door is right there. The
            // keys-locked and keys-replaced states carry their own lines
            // above instead (the cause IS the line).
            if face.kind == .error, let error = sync.status.lastError {
                ErrorCauseNote(error: error)
            }
        }
        .font(.caption)
        .padding(6)
        .sheet(item: $accountSheetTab) { tab in
            AccountView(services: services, initialTab: tab)
        }
    }

    @ViewBuilder
    private func rowLabel(for kind: SyncRowFace.Kind) -> some View {
        switch kind {
        case .devStore:
            Text("Sync off (dev store)")
                .foregroundStyle(.secondary)
        case .signedOut:
            Text("Signed out")
                .foregroundStyle(.secondary)
        case .syncOff:
            Text("Sync is off")
                .foregroundStyle(.secondary)
        case .syncing:
            // CF-15: the indicator rides BESIDE the label; the doors stay.
            ProgressView().controlSize(.small)
            Text("Syncing…")
        case .offline:
            Text(Self.offlineLabel)
                .foregroundStyle(.secondary)
                .help(sync.status.lastError ?? "")
            pendingNote
        case .keysLocked:
            // Phase 14b (L9): nothing is lost while paused; the outbox
            // keeps everything.
            Text(Self.lockedLabel)
                .foregroundStyle(.orange)
                .help(sync.status.lastError ?? "")
        case .keysReplaced:
            Text(Self.keysReplacedLabel)
                .foregroundStyle(.orange)
                .help(sync.status.lastError ?? "")
        case .notEntitled:
            // Phase 14c (L7): SECONDARY styling, deliberately — the same
            // quiet voice as signed-out/offline, never the error red or
            // the keys orange (reads as normal).
            Text(HostedSyncTier.rowLabel)
                .foregroundStyle(.secondary)
                .help(sync.status.lastError ?? "")
        case .error:
            Text("Sync error")
                .foregroundStyle(.red)
        case .idle:
            Text(lastSyncLabel)
                .foregroundStyle(.secondary)
            pendingNote
        }
    }

    @ViewBuilder
    private var pendingNote: some View {
        if sync.status.pendingPushCount > 0 {
            Text("· \(sync.status.pendingPushCount) pending")
                .foregroundStyle(.secondary)
        }
    }

    private func perform(_ act: SyncRowFace.Door.Act) {
        switch act {
        case .syncNow:
            sync.triggerSync()
        case .openAccount(let tab):
            accountSheetTab = tab
        }
    }

    /// The locked-state line's one string (Phase 14b, L9 — the SyncSpec
    /// §12-grammar presentation of `SyncError.encryptionKeysUnavailable`),
    /// exposed for the presented-state pin like `offlineLabel`.
    static let lockedLabel = "Sync locked — enter your encryption passphrase"

    /// CF-16's row line: the replaced-keys presentation of the engine's
    /// payload-crypto refusal (wording derived from the ruled surface
    /// copy; the door beside it opens the Encryption tab, whose headline
    /// IS the ruled sentence).
    static let keysReplacedLabel = "Sync paused — this account's encryption keys were replaced"

    private var lastSyncLabel: String {
        guard let last = sync.status.lastSuccessAt else { return "Not synced yet" }
        return "Synced \(last.formatted(date: .omitted, time: .shortened))"
    }

    /// The offline presentation's one string (Step A0's row letter),
    /// exposed for the presented-state pin.
    static let offlineLabel = "Waiting to sync (offline)"
}
