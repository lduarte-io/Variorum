//
//  TierViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14c, batch 3 (L7) — the hosted-sync TIER's one home: the
//  classifier that names the server's entitlement refusal, the copy the
//  gate UX speaks, and the Account tab's tier section. Everything here is
//  PRICE-AGNOSTIC (the Round-1 ruling: she names the number at launch,
//  with real cost data) and governed by the v1 principle: an unentitled
//  or signed-out state reads as NORMAL, never degraded — sync is the
//  tier; the app is not.
//
//  B2-3 PROMOTED (batch 2's provisional, resolved here): the entitlement
//  read lives in this home now — `AppServices.refreshHostedSyncStatus`
//  feeds `AccountState.hostedSync`, and the deletion door's subscription
//  note derives from the same read instead of its own.
//

import Foundation
import SwiftUI
import VariorumCore

/// The account's tier standing as the app projects it. `.unknown` is the
/// unread/unreadable state and renders NOTHING — a failed read must never
/// wear an error face (the reads-as-normal principle; when the server
/// actually refuses a sync round, the sync row's own tier line narrates).
nonisolated enum HostedSyncStatus: Equatable {
    case unknown
    /// An active `hosted_sync` entitlement; `expiresAt` is the row's ISO
    /// text (nil = non-expiring).
    case active(expiresAt: String?)
    case inactive
}

/// The tier's names, rules, and copy — one nonisolated home so the sync
/// row's pure face model and the tests consult it directly.
nonisolated enum HostedSyncTier {
    /// The entitlement row's one feature name (09's letter).
    static let feature = "hosted_sync"

    /// The sync row's tier line — SECONDARY styling at the render site,
    /// deliberately: the tier refusal is a normal state, never an error
    /// face (the v1 principle).
    static let rowLabel = "Sync off — hosted sync isn't active on this account"

    /// The Account tab's tier section, active arm.
    static let activeLine = "Hosted sync is active on this account."

    /// What the tier IS — every claim true today, nothing promised early.
    static let whatItIs =
        "Hosted sync keeps an end-to-end encrypted copy of your writing on the server "
        + "and syncs it across your devices. The server can never read what it stores."

    /// The v1 principle's own sentence: the app is whole without the tier.
    static let worksWithoutIt =
        "Variorum works fully without it — everything you write lives on this device, "
        + "and nothing in the app is reduced."

    /// Where the tier is sold (the web-first ruling; the checkout is the
    /// stargazing.tech site's build). Price-agnostic: no number until she
    /// names one at launch.
    static let whereToGetIt = "Plans are available at stargazing.tech."

    /// The sync row's tier classifier: true exactly for the server's
    /// entitlement refusal (`SyncError.syncNotEntitled`, which the
    /// transport classifies out of the VARIORUM_NO_ENTITLEMENT marker and
    /// the scheduler surfaces verbatim). Disjoint from every keys
    /// classifier — the tier is commerce state, never a keys state.
    static func isNotEntitledError(_ text: String) -> Bool {
        text == SyncError.syncNotEntitled.description
    }

    /// Is this entitlement row current? NULL expiry = non-expiring (09's
    /// letter); otherwise the ISO timestamp must lie ahead of `now`. An
    /// unparseable expiry counts as current — the server's own gates parse
    /// authoritatively, and refusing sync locally on a client-side parse
    /// quirk would manufacture a refusal the server never made.
    static func isCurrent(_ entitlement: AccountEntitlement, now: Date = Date()) -> Bool {
        guard let expires = entitlement.expiresAt else { return true }
        let parsed = DateFormatter.variorumISO8601.date(from: expires)
            ?? ISO8601DateFormatter().date(from: expires)
        guard let parsed else { return true }
        return parsed > now
    }

    /// The active arm's expiry footnote (nil = non-expiring or unparseable
    /// — both stay quiet). "Renews or ends": the app cannot know which —
    /// renewal is the processor's world, honestly named.
    static func expiryLine(_ expiresAt: String?) -> String? {
        guard let expiresAt else { return nil }
        let parsed = DateFormatter.variorumISO8601.date(from: expiresAt)
            ?? ISO8601DateFormatter().date(from: expiresAt)
        guard let parsed else { return nil }
        return "Renews or ends \(parsed.formatted(date: .abbreviated, time: .omitted))."
    }
}

/// The Account tab's tier section (the tier UX's real home — CF-14's own
/// words: "account will one day show payment"; this is that day's first
/// honest form). Renders from `AccountState.hostedSync`; refreshes on
/// appearance; `.unknown` renders nothing at all.
struct HostedSyncSection: View {
    let services: AppServices

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch services.account.hostedSync {
            case .unknown:
                EmptyView()
            case .active(let expiresAt):
                Text("Hosted Sync").fontWeight(.semibold)
                Text(HostedSyncTier.activeLine)
                if let line = HostedSyncTier.expiryLine(expiresAt) {
                    Text(line)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            case .inactive:
                Text("Hosted Sync").fontWeight(.semibold)
                Text(HostedSyncTier.whatItIs)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(HostedSyncTier.worksWithoutIt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(HostedSyncTier.whereToGetIt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .task { await services.refreshHostedSyncStatus() }
    }
}
