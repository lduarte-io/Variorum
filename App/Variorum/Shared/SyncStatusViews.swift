//
//  SyncStatusViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the one-row functional sync status surface (SyncSpec
//  §10's "sync status indicator" scope, nothing more). Phase 9c, Step 5:
//  the paste-in form is DELETED — the row's door is the
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
//  Phase 13r U3-A — R-13r-13 (her refinement at the U3 kickoff, verbatim:
//  *"if sync doesn't work because your version is out of date, a calm
//  message should say so as well."*). The engine's §12 lockstep refusal
//  (`SyncError.schemaLockstepMismatch` — outbox kept, cursor unmoved, by
//  design) used to reach this row as the GENERIC error face, so a friend
//  would read the engine's sentence, written for the author ("Finish the
//  schema update on the lagging side…"). It is classified HERE, face-side,
//  on the `isKeysLockedError` pattern — the engine and its text are
//  untouched (zero `Sync/` lines). Only the direction a friend can reach
//  is re-faced: the SERVER's marker AHEAD of the app's — this version is
//  older than the account's sync format, so the fix is an update. The door
//  is Check for Updates…, rendered only where an updater can act (P-2: the
//  Mac's live Sparkle channel injects `checkForUpdatesDoor`; a Debug build
//  and the phone inject nothing and show the plain sentence alone). The
//  other direction (the app AHEAD of the server — the author's own
//  pre-deploy state, R-13r-7) keeps the generic face: no friend can reach
//  it, because the §12 choreography deploys the mirror before any release.
//
//  VX-486 (her live finding at the 0.10 window): the LOCKED state's line and
//  door follow the road — the line names the state in the road's words, and
//  the one door opens Settings ▸ Protection (`ProtectionPaneDoor`, injected
//  only where that pane exists; the phone says the sentence alone — P-2).
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
        /// VX-510 D-A3 (VX-506): the keys refusal over a library whose record names NO account — it has not joined, so
        /// there is nothing locked, only a not-yet (her line: "sync shouldn't seem like you're restarting it"). The calm
        /// quiet voice; the locked face's own door (Settings ▸ Protection, where Turn on sync stands).
        case notOnYet
        /// VX-314: the signed-in account is not this library's — the engine
        /// refuses rounds (outbox intact, cursor unmoved). Calm paused
        /// voice; the door reaches the Account tab, where sign-in and the
        /// Move road live.
        case accountMismatch
        /// R-13r-13 (13r U3-A): the §12 refusal with the SERVER ahead —
        /// this app is older than the account's sync format. Calm, never
        /// the error red; its door (where an updater can act) is
        /// Check for Updates….
        case appOutOfDate
        /// RUN B B2 row 12 (17d P31): a CLEAN round whose pull is held at
        /// a row whose referents have not arrived — the round succeeded,
        /// but "Synced <time>" would be saying "fine" while nothing new
        /// can come in. Same doors as idle; an honest line instead.
        case stalled
        #if DEBUG
        /// VX-510 D-B3 — the prod test road refused the signed-in account (it is not a listed test account): no chain,
        /// and the row says why — never "Sync off (dev store)" alone, never silent. DEBUG walk machinery only.
        case notOnTheProdTestRoad
        #endif
    }

    struct Door: Equatable, Identifiable {
        enum Act: Equatable {
            /// Trigger a round (serves "Sync now" and "Retry" alike).
            case syncNow
            /// Open the tabbed Account sheet at the named tab (CF-14).
            case openAccount(AccountTab)
            /// R-13r-13: the update channel's own act (the Mac's Sparkle
            /// channel, injected as `checkForUpdatesDoor`). Minted only when
            /// the face was told a live updater exists (P-2).
            case checkForUpdates
            /// VX-486: Settings ▸ Protection, through the one programmatic
            /// open-at-pane road (`ProtectionController.settingsRequest`,
            /// injected as `protectionPaneDoor`) — where the road's doors
            /// live. Minted only when the face was told a door can act
            /// there (P-2: the Mac's main window; the phone's Settings,
            /// whose door pushes its Protection screen — VM-8).
            case openProtection
        }
        var label: String
        var act: Act
        var enabled: Bool = true
        var id: String { label }
    }

    var kind: Kind
    var doors: [Door]

    /// `stalled` (row 12 — 17d P31) is `Status.pullStalled`, defaulted so
    /// every existing state pin reads unmodified: it decorates only the
    /// CLEAN branch (an error face already says something is wrong, and a
    /// syncing row is mid-answer). `canOpenProtection` (VX-486) is the
    /// `canCheckForUpdates` idiom: true only where a Protection pane door
    /// was injected (P-2).
    ///
    /// `libraryJoined` (VX-510 D-A3 — VX-506): whether the OPEN library's record names an account (the bootstrap's
    /// `RoadStandingModel.syncsWithAnAccount`, re-read at every account landing — VX-473). It splits ONLY the keys refusal:
    /// false — the library has not joined, so the row says a not-yet, never "locked"; true or nil (not known — a
    /// composition that injects no fact, every existing pin) — the shipped locked face, unchanged.
    static func face(
        allowsSync: Bool,
        isConfigured: Bool,
        signedIn: Bool,
        isSyncing: Bool,
        lastError: String?,
        lastErrorIsOffline: Bool,
        stalled: Bool = false,
        canCheckForUpdates: Bool = false,
        canOpenProtection: Bool = false,
        libraryJoined: Bool? = nil
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
            if Self.isKeysLockedError(error) {
                // Phase 14b (L9): the keys-refusal presents as a paused
                // state naming its fix. VX-486 (her live finding — P-VX329-U1-4's
                // Account sheet had nowhere to take what the state needs): the
                // door lands in Settings ▸ Protection, where the road's doors
                // live (a Touch ID unlock or a key-door act loads the keys —
                // VX-487), and only where that pane exists (P-2): with no
                // door the row says the sentence alone, as `.appOutOfDate`.
                // VX-510 D-A3 (VX-506): a library that has not joined is not locked — the not-yet face, the same door.
                return SyncRowFace(
                    kind: libraryJoined == false ? .notOnYet : .keysLocked,
                    doors: canOpenProtection
                        ? [Door(label: Self.openProtectionLabel, act: .openProtection)]
                        : [])
            }
            if Self.isAccountMismatchError(error) {
                // VX-314: the library belongs to another account than the
                // one signed in — a paused state naming its fix (sign into
                // the library's account, or Move it); never a generic error.
                return SyncRowFace(kind: .accountMismatch, doors: [
                    Door(label: "Account…", act: .openAccount(.account)),
                ])
            }
            if Self.isPayloadCryptoError(error)
                || Self.isKeysReplacedError(error)
                || Self.isKeyProofRefusedError(error) {
                // pre-13x 2c: the un-followed state (§7) — the fence's
                // refusal and the proof's alike; the door reaches the
                // Encryption tab, where the follow's door stands.
                // CF-16: after a re-key, a stale device's rounds fail —
                // since Phase 14c at the server's vault-key-id fence
                // (BEFORE any poison push), and as payload-crypto
                // refusals on anything that slipped past — both present
                // as the replaced-keys line naming the real fix instead
                // of a generic error face.
                // VX-329 U1 — P-VX329-U1-4: the door opened today's Encryption
                // tab (deleted); the Account sheet, as above.
                return SyncRowFace(kind: .keysReplaced, doors: [
                    Door(label: "Account…", act: .openAccount(.account)),
                ])
            }
            if Self.isAppBehindServerError(error) {
                // R-13r-13 (13r U3-A): this version is older than the
                // account's sync format. Calm and plain; the door is the
                // update channel's, and only where it can act (P-2) — a
                // Debug build and the phone say the sentence alone.
                return SyncRowFace(
                    kind: .appOutOfDate,
                    doors: canCheckForUpdates
                        ? [Door(label: Self.checkForUpdatesLabel, act: .checkForUpdates)]
                        : [])
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
        if stalled {
            // Row 12 (17d P31): the honest line under a held pull cursor —
            // the idle row's own doors ("Sync now" retries, which is also
            // how a transient straggler's heal is felt).
            return SyncRowFace(kind: .stalled, doors: [
                Door(label: "Sync now", act: .syncNow),
                Door(label: "Account…", act: .openAccount(.account)),
            ])
        }
        return SyncRowFace(kind: .idle, doors: [
            Door(label: "Sync now", act: .syncNow),
            Door(label: "Account…", act: .openAccount(.account)),
        ])
    }

    /// **R-13r-13's classifier (13r U3-A) — face-side, the engine
    /// untouched.** True exactly for the engine's §12 lockstep refusal AS
    /// THE SCHEDULER SURFACES IT (`String(describing:)` — its `description`)
    /// when the SERVER's marker is AHEAD of the app's. The text carries the
    /// two markers, so this reads them back out and then demands the WHOLE
    /// string equal the engine's own rendering of that pair — the
    /// `isKeysLockedError` exactness rule (a substring match would swallow
    /// unrelated errors into a calm face). The app-ahead direction answers
    /// false and keeps the generic face (the header says why).
    static func isAppBehindServerError(_ text: String) -> Bool {
        guard let markers = lockstepMarkers(in: text) else { return false }
        return markers.server > markers.client
    }

    /// VX-314: the EXACT account-mismatch refusal (the `isKeysLockedError`
    /// exactness rule — the two ids are read back out and the WHOLE string
    /// must equal the engine's own rendering of that pair; a substring match
    /// would swallow unrelated errors into this face).
    static func isAccountMismatchError(_ text: String) -> Bool {
        guard let open = text.range(of: "(library "),
              let comma = text.range(of: ", signed in ", range: open.upperBound..<text.endIndex),
              let close = text.range(of: ")", range: comma.upperBound..<text.endIndex)
        else { return false }
        let bound = String(text[open.upperBound..<comma.lowerBound])
        let signedIn = String(text[comma.upperBound..<close.lowerBound])
        return String(describing: SyncError.accountMismatch(bound: bound, signedIn: signedIn)) == text
    }

    /// The (client, server) pair of an EXACT lockstep refusal, or nil.
    static func lockstepMarkers(in text: String) -> (client: Int, server: Int)? {
        guard let open = text.range(of: "(app "),
              let comma = text.range(of: ", server ", range: open.upperBound..<text.endIndex),
              let close = text.range(of: ")", range: comma.upperBound..<text.endIndex),
              let client = Int(text[open.upperBound..<comma.lowerBound]),
              let server = Int(text[comma.upperBound..<close.lowerBound])
        else { return nil }
        let rendered = String(describing: SyncError.schemaLockstepMismatch(client: client, server: server))
        return rendered == text ? (client, server) : nil
    }

    // MARK: - The engine's refusals, classified (moved from today's `EncryptionSession` at VX-329 U1, byte-for-byte)

    /// The locked-state classifier: true exactly for the engine's keys-refusal (`SyncError.encryptionKeysUnavailable`,
    /// which the scheduler surfaces verbatim via `String(describing:)`).
    nonisolated static func isKeysLockedError(_ text: String) -> Bool {
        text == SyncError.encryptionKeysUnavailable.description
    }

    /// CF-16's classifier arm: true for the engine's payload-crypto refusal (`SyncError.payloadCryptoFailure`) as the
    /// scheduler surfaces it. The case's description carries row coordinates, so this anchors on the description's two
    /// invariant segments; the conjunction excludes the other "Sync refused:"-family case
    /// (`unencryptedValueInEncryptedColumn`), which never means stale keys.
    nonisolated static func isPayloadCryptoError(_ text: String) -> Bool {
        text.hasPrefix("Sync refused: '")
            && text.contains("failed to encrypt/decrypt (")
    }

    /// Phase 14c — the fence's classifier arm: true exactly for the server's vault-key-id fence refusal
    /// (`SyncError.encryptionKeysReplaced`).
    nonisolated static func isKeysReplacedError(_ text: String) -> Bool {
        text == SyncError.encryptionKeysReplaced.description
    }

    /// pre-13x 2c — the key proof's refusal (`SyncError.keyProofRefused`): the same replaced-keys row.
    nonisolated static func isKeyProofRefusedError(_ text: String) -> Bool {
        text == SyncError.keyProofRefused.description
    }

    /// The door's words — the platform's own, identical to the Mac menu's
    /// Variorum ▸ Check for Updates… (`UpdateChannel.checkForUpdatesTitle`;
    /// a Mac pin holds the two equal — `Shared/` cannot see the channel).
    static let checkForUpdatesLabel = "Check for Updates\u{2026}"

    /// VX-486 — the locked row's door: the pane's own name (`ProtectionCopy.protectionPaneTitle`) in the row's
    /// `Account…` idiom. PROVISIONAL (P-VX486-1), hers to reword.
    static let openProtectionLabel = "\(ProtectionCopy.protectionPaneTitle)\u{2026}"

    #if DEBUG
    /// **VX-510 D-B3 — the prod test road's refusal face** (pure, pinned): when the road refused the signed-in account at
    /// connect (`AccountState.notOnTheProdTestRoad`), the row says so — its door the Account sheet, where she signs out or
    /// in as a listed test account; nil otherwise (the row's ordinary face).
    static func prodTestRoadRefusal(refused: Bool) -> SyncRowFace? {
        guard refused else { return nil }
        return SyncRowFace(kind: .notOnTheProdTestRoad, doors: [Door(label: "Account…", act: .openAccount(.account))])
    }
    #endif

    /// The row's line (calm: the quiet caption, never the error red).
    static let appOutOfDateLabel = "Sync paused \u{2014} this version of Variorum needs an update"

    /// The sentence under it — her R-13r-13 letter: older than the
    /// account's sync format; update to continue; nothing lost meanwhile.
    static let appOutOfDateDetail =
        "This version of Variorum is older than your account\u{2019}s sync format. "
        + "Update Variorum to continue syncing \u{2014} nothing is lost while sync is paused."
}

/// R-13r-13 (13r U3-A): the update channel's act, handed to the sync row
/// from where it lives. The Mac's composition injects it ONLY from a LIVE
/// channel (`UpdateChannel.isLive` — never in a Debug build, R-13r-7); the
/// phone never injects it (its updates are the App Store's). nil ⇒ the row
/// renders no Check for Updates… door (P-2).
struct CheckForUpdatesDoor {
    let perform: @MainActor () -> Void
}

private struct CheckForUpdatesDoorKey: EnvironmentKey {
    static let defaultValue: CheckForUpdatesDoor? = nil
}

extension EnvironmentValues {
    var checkForUpdatesDoor: CheckForUpdatesDoor? {
        get { self[CheckForUpdatesDoorKey.self] }
        set { self[CheckForUpdatesDoorKey.self] = newValue }
    }
}

/// VX-486: the locked row's door to Settings ▸ Protection, handed to the row from where the pane request lives (the
/// `CheckForUpdatesDoor` precedent). The Mac's main window injects it from the bootstrap's one `ProtectionController`
/// (`settings(_:)`); the phone's Settings injects the shell's push of its Protection screen, only where that screen can
/// act (VM-8 unit 1); nil ⇒ the row renders no door (P-2).
/// The ask re-points a Settings window; the row's press brings the window up beside it (`openSettings()`, the Mac's
/// environment action — ⌥⌘,'s own two lines: `mcp.requestSettings(); openSettings()`).
struct ProtectionPaneDoor {
    let request: @MainActor () -> Void

    /// The production door: the controller's pane ask (adopted by `AppSettingsView.adoptProtectionRequest`).
    static func settings(_ protection: ProtectionController) -> ProtectionPaneDoor {
        ProtectionPaneDoor { [weak protection] in protection?.requestProtectionPane() }
    }
}

private struct ProtectionPaneDoorKey: EnvironmentKey {
    static let defaultValue: ProtectionPaneDoor? = nil
}

extension EnvironmentValues {
    var protectionPaneDoor: ProtectionPaneDoor? {
        get { self[ProtectionPaneDoorKey.self] }
        set { self[ProtectionPaneDoorKey.self] = newValue }
    }
}

/// VX-510 D-A3 (VX-506): whether the OPEN library's record names an account — the bootstrap's
/// `RoadStandingModel.syncsWithAnAccount`, injected by each platform's root beside its library (observable, re-read when an
/// account act lands). nil (not known — no injection): the row keeps the shipped locked face.
private struct LibrarySyncsWithAnAccountKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var librarySyncsWithAnAccount: Bool? {
        get { self[LibrarySyncsWithAnAccountKey.self] }
        set { self[LibrarySyncsWithAnAccountKey.self] = newValue }
    }
}

/// One row: signed-in + configured → last sync / pending / error;
/// signed out → the sign-in door.
struct SyncStatusRow: View {
    let services: AppServices
    /// D1: the phone's styling seam (nil on the Mac ALWAYS — the
    /// environment accessor compiles to nil there). The mobile Settings
    /// sheet injects it here; the Account sheet presented below inherits
    /// it through the environment.
    @Environment(\.sharedPageStyle) private var pageStyle
    /// R-13r-13: the update channel's act where one can run (the Mac's
    /// live channel); nil everywhere else, and then no door renders.
    @Environment(\.checkForUpdatesDoor) private var checkForUpdatesDoor
    /// VX-486: the locked row's door to Settings ▸ Protection where the
    /// pane exists (the Mac's main window); nil everywhere else, and then
    /// the locked row renders no door.
    @Environment(\.protectionPaneDoor) private var protectionPaneDoor
    /// VX-510 D-A3: the open library's record names an account (nil: not known — the shipped locked face).
    @Environment(\.librarySyncsWithAnAccount) private var libraryJoined
    #if os(macOS)
    /// VX-486: the Protection door brings the Settings window up beside
    /// its pane ask (the ask alone only re-points a window already open).
    @Environment(\.openSettings) private var openSettings
    #endif
    /// CF-14: the ONE sheet, opened at the tab the pressed door names
    /// (nil = not presented).
    @State private var accountSheetTab: AccountTab?

    private var sync: SyncSession { services.sync }

    private var face: SyncRowFace {
        #if DEBUG
        // VX-510 D-B3: the prod test road refused the signed-in account — the row says why, before anything else.
        if let refusal = SyncRowFace.prodTestRoadRefusal(refused: services.account.notOnTheProdTestRoad) { return refusal }
        #endif
        return SyncRowFace.face(
            allowsSync: sync.allowsSync,
            isConfigured: sync.isConfigured,
            signedIn: services.account.variorum != nil,
            isSyncing: sync.status.isSyncing,
            lastError: sync.status.lastError,
            lastErrorIsOffline: sync.status.lastErrorIsOffline,
            stalled: sync.status.pullStalled,
            canCheckForUpdates: checkForUpdatesDoor != nil,
            canOpenProtection: protectionPaneDoor != nil,
            libraryJoined: libraryJoined)
    }

    var body: some View {
        row
            .sheet(item: $accountSheetTab) { tab in
                AccountView(services: services, initialTab: tab)
            }
    }

    /// The row itself. nil arm: the pre-D1 construction exactly (one
    /// caption line, label + doors inline). Styled arm (the phone): the
    /// voice's register — the label line first, the doors on their own
    /// row beneath it (long paused-state labels + doors never fight for
    /// one line: the D1 unaligned-row fix), plain accent doors, the
    /// Settings sheet's own type scale.
    @ViewBuilder
    private var row: some View {
        let face = self.face
        if let style = pageStyle {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    rowLabel(for: face.kind)
                }
                if !face.doors.isEmpty {
                    HStack(spacing: 14) {
                        ForEach(face.doors) { door in
                            Button {
                                perform(door.act)
                            } label: {
                                Text(style.chrome(door.label))
                                    .font(style.tokens.small)
                                    .foregroundStyle(style.tokens.accent)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(door.label)
                            .disabled(!door.enabled)
                            .opacity(door.enabled ? 1 : 0.35)
                        }
                    }
                }
                if face.kind == .error, let error = sync.status.lastError {
                    ErrorCauseNote(error: error)
                }
                if face.kind == .appOutOfDate {
                    Text(SyncRowFace.appOutOfDateDetail)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(style.tokens.small)
            .foregroundStyle(style.tokens.ink)
            .padding(.vertical, 6)
        } else {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    rowLabel(for: face.kind)
                    ForEach(face.doors) { door in
                        Button(door.label) { perform(door.act) }
                            .disabled(!door.enabled)
                    }
                }
                // Sitting 9 (R94): the cause inline, classified — an
                // auth-shaped failure names its fix and the Account door is
                // right there. The keys-locked and keys-replaced states
                // carry their own lines above instead (the cause IS the
                // line).
                if face.kind == .error, let error = sync.status.lastError {
                    ErrorCauseNote(error: error)
                }
                // R-13r-13: the calm sentence under the line — the cause
                // IS the line's subject, said plainly (never the engine's
                // author-facing text, which stays in the hover).
                if face.kind == .appOutOfDate {
                    Text(SyncRowFace.appOutOfDateDetail)
                        .pageCaption(pageStyle)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.caption)
            // VX-218 (her words: "signed out has no spacing in the bottom
            // left - doesn't look premium on first login"): on the Mac this
            // arm's only host is the sidebar's bottom family, and the 6 pt
            // all round put its words 6 pt from the window's edge, inside
            // the rounded corner. The HOST owns the horizontal inset now
            // (`RootView.statusRows` — the column's own content edge); the
            // vertical 6 stays (it shares the bottom bars' baseline).
            #if os(macOS)
            .padding(.vertical, 6)
            #else
            .padding(6)
            #endif
        }
    }

    /// The label arms. The quiet/warning/error colors are shared; the
    /// styled arm's font rides the row container (`tokens.small`), and
    /// the quiet `.secondary` maps to the voice's muted ink. In the nil
    /// arm every helper's output is render-identical to the pre-D1 lines
    /// (an explicit `.font(.caption)` under the row's own `.caption`
    /// container changes nothing).
    @ViewBuilder
    private func rowLabel(for kind: SyncRowFace.Kind) -> some View {
        // VX-510 D-A2: every line is `line(for:)`'s — the one presentation source the account act's first-round sheet
        // says too.
        let line = Self.line(for: kind, lastSuccessAt: sync.status.lastSuccessAt)
        switch kind {
        case .devStore, .signedOut, .syncOff:
            Text(line)
                .pageCaption(pageStyle)
        case .syncing:
            // CF-15: the indicator rides BESIDE the label; the doors stay.
            ProgressView().controlSize(.small)
            Text(line)
        case .offline:
            Text(line)
                .pageCaption(pageStyle)
                .help(sync.status.lastError ?? "")
            pendingNote
        case .keysLocked:
            // Phase 14b (L9): nothing is lost while paused; the outbox
            // keeps everything.
            Text(line)
                .pageCaptionWarning(pageStyle)
                .help(sync.status.lastError ?? "")
        case .notOnYet:
            // VX-510 D-A3 (VX-506): a not-yet, never a lock — the quiet caption (the sync-off register), the engine's
            // refusal in the hover as every paused state's.
            Text(line)
                .pageCaption(pageStyle)
                .help(sync.status.lastError ?? "")
        case .keysReplaced:
            Text(line)
                .pageCaptionWarning(pageStyle)
                .help(sync.status.lastError ?? "")
        case .accountMismatch:
            // VX-314 (PROVISIONAL words): paused, naming the fix; the
            // engine's full sentence rides the hover.
            Text(line)
                .pageCaptionWarning(pageStyle)
                .help(sync.status.lastError ?? "")
        case .notEntitled:
            // Phase 14c (L7): SECONDARY styling, deliberately — the same
            // quiet voice as signed-out/offline, never the error red or
            // the keys orange (reads as normal).
            Text(line)
                .pageCaption(pageStyle)
                .help(sync.status.lastError ?? "")
        case .stalled:
            // Row 12 (17d P31): warning-styled, never the error red — the
            // round itself was clean; what's honest is that new changes
            // are held up.
            Text(line)
                .pageCaptionWarning(pageStyle)
            pendingNote
        case .appOutOfDate:
            // R-13r-13: calm — the quiet caption (the notEntitled register),
            // never the error red or the keys orange. The engine's own
            // sentence rides the hover, as every paused state's does.
            Text(line)
                .pageCaption(pageStyle)
                .help(sync.status.lastError ?? "")
        case .error:
            Text(line)
                .pageCaptionError(pageStyle)
        case .idle:
            Text(line)
                .pageCaption(pageStyle)
            pendingNote
        #if DEBUG
        case .notOnTheProdTestRoad:
            // VX-510 D-B3: a refusal, warning-styled (the paused register) — the walker must not miss it.
            Text(line)
                .pageCaptionWarning(pageStyle)
        #endif
        }
    }

    /// **VX-510 D-A2 — THE ROW'S LINE, in words: ONE presentation source.** The row renders exactly this for each face,
    /// and an account act's first-round sheet says it for what blocks the round (never re-typed there). `lastSuccessAt`
    /// is the idle line's stamp.
    static func line(for kind: SyncRowFace.Kind, lastSuccessAt: Date?) -> String {
        switch kind {
        case .devStore: return "Sync off (dev store)"
        case .signedOut: return "Signed out"
        case .syncOff: return "Sync is off"
        case .syncing: return "Syncing\u{2026}"
        case .offline: return offlineLabel
        case .keysLocked: return lockedLabel
        case .notOnYet: return notOnYetLabel
        case .keysReplaced: return keysReplacedLabel
        case .accountMismatch: return accountMismatchLabel
        case .notEntitled: return HostedSyncTier.rowLabel
        case .stalled: return stalledLabel
        case .appOutOfDate: return SyncRowFace.appOutOfDateLabel
        case .error: return "Sync error"
        case .idle:
            guard let lastSuccessAt else { return "Not synced yet" }
            return "Synced \(lastSuccessAt.formatted(date: .omitted, time: .shortened))"
        #if DEBUG
        case .notOnTheProdTestRoad: return notOnTheProdTestRoadLabel
        #endif
        }
    }

    @ViewBuilder
    private var pendingNote: some View {
        if sync.status.pendingPushCount > 0 {
            Text("· \(sync.status.pendingPushCount) pending")
                .pageCaption(pageStyle)
        }
    }

    private func perform(_ act: SyncRowFace.Door.Act) {
        switch act {
        case .syncNow:
            // 13x F1 (ladder R1-N1): a door that did nothing speaks a
            // refusal (§12's rule) — under a standing restore hold
            // `triggerSync` returns on the gate, so the door says why
            // instead of going quiet; the banner's Resume is the act.
            // Mac-only: the restore hold exists only where the adoption
            // doors do (P-F1-2 — the phone's gate is nil, never held), and
            // the session's StatusCenter is a Mac member.
            #if os(macOS)
            if sync.roundsHeld?() == true {
                services.session.status.refuse(LibraryOpenCopy.syncNowHeldRefusal)
                return
            }
            #endif
            sync.triggerSync()
        case .openAccount(let tab):
            accountSheetTab = tab
        case .checkForUpdates:
            checkForUpdatesDoor?.perform()
        case .openProtection:
            // VX-486: the pane ask first (a Settings window adopts it on
            // appear or on change), then the window itself.
            protectionPaneDoor?.request()
            #if os(macOS)
            openSettings()
            #endif
        }
    }

    /// The locked-state line's one string (Phase 14b, L9 — the SyncSpec
    /// §12-grammar presentation of `SyncError.encryptionKeysUnavailable`),
    /// exposed for the presented-state pin like `offlineLabel`. VX-486: off
    /// the deleted road's words ("enter your encryption passphrase" — the
    /// Encryption tab it pointed at is gone, and the row cannot take one);
    /// it names the state — the account's sync keys not unlocked on this
    /// device — and the door beside it lands where the road's doors live.
    /// PROVISIONAL (P-VX486-2), hers to reword.
    static let lockedLabel = "Sync locked — this \(ProtectionCopy.deviceName) hasn't unlocked your account's sync keys"

    /// VX-510 D-A3 (VX-506) — the unjoined library's line: the keys refusal over a library whose record names no account
    /// is a not-yet, never a lock. PROVISIONAL (P-VX510-2 (a)), hers to reword.
    static let notOnYetLabel = "Sync isn't on for this library yet"

    #if DEBUG
    /// VX-510 D-B3 — the prod test road's refusal line (the dev store syncs with production only for a listed test
    /// account). PROVISIONAL P-VX510-B1-2, the implementer's draft, hers to reword.
    static let notOnTheProdTestRoadLabel = "Sync off (dev store) \u{2014} this account isn't a listed test account"
    #endif

    /// CF-16's row line: the replaced-keys presentation of the engine's
    /// payload-crypto refusal (wording derived from the ruled surface
    /// copy; the door beside it opens the Encryption tab, whose headline
    /// IS the ruled sentence).
    static let keysReplacedLabel = "Sync paused — this account's encryption keys were replaced"

    /// VX-314's row line (PROVISIONAL words): the library belongs to a
    /// different account than the signed-in one; the door beside it opens
    /// the Account tab (sign in, or the Move road).
    static let accountMismatchLabel = "Sync paused — this library belongs to a different account"

    /// The offline presentation's one string (Step A0's row letter),
    /// exposed for the presented-state pin.
    static let offlineLabel = "Waiting to sync (offline)"

    /// Row 12's one string (17d P31): the stalled-pull line — a clean
    /// round whose cursor is held at rows the server cannot complete yet,
    /// so "Synced <time>" would be false comfort. Exposed for the
    /// presented-state pin like its siblings.
    static let stalledLabel = "Sync incomplete — some changes haven't arrived yet"
}
