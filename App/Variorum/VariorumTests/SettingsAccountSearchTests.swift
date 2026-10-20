//
//  SettingsAccountSearchTests.swift
//  VariorumTests
//
//  VX-309 U2 piece 10 — RIDER VX-453: Settings search surfaces the account section. The search self-describes as covering
//  the app's own words (its empty line: "Try a word from the thing itself"), yet "account" answered NOTHING: the new road's
//  Settings ▸ Protection ▸ Sync section (`RoadAccountSection` — sign in and out, turn on sync, the leaves, the follow) had no
//  catalog row, so the search's one index (`SettingsSearch.wholeIndex`, built from `SettingsCatalog` + the ⌘/ helper's
//  lists) never named it. The row joins through the existing seam — declared in the catalog, rendered by its pane — and
//  only where the section renders (the new road).
//
//  RED ON OLD: these pins use only the search's standing API (`findings(matching:in:)` over `wholeIndex`), so they compile
//  on the pre-piece tree and fail there — "account" finds nothing; "sync" leads with a row that merely mentions syncing.
//  Pure (no view mounted): runs on the Mac in a Debug test host, where the new road is live, and headless in the
//  implementer's scratch settings harness. The road gate, the rendered half and the faces are `SettingsAccountSurfaceTests`.
//

import Foundation
import Testing

@testable import Variorum

@MainActor
@Suite("VX-453 — Settings search surfaces the account section")
struct SettingsAccountSearchTests {
    private static func isAccountSection(_ finding: SettingsFinding) -> Bool {
        finding.kind == .setting && finding.pane == .protection && finding.lead == ProtectionWords.accountSectionTitle
    }

    /// "account" finds the Sync section — first, and the only setting it names — and so do the words she'd type for the
    /// section's doors (found among the answers: "sign in" also matches the Theme row's own search words, ranked by order).
    @Test func typingAccountFindsTheSyncSection() {
        for query in ["account", "Account", "ACCOUNT"] {
            let found = SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
            #expect(found.first.map(Self.isAccountSection) == true, "\(query) → \(found.map(\.lead))")
        }
        for query in ["sign in", "sign out", "log in", "email", "turn on sync", "stop syncing", "other device"] {
            let found = SettingsSearch.findings(matching: query, in: SettingsSearch.wholeIndex)
            #expect(found.contains(where: Self.isAccountSection), "\(query) → \(found.map(\.lead))")
        }
    }

    /// "sync" still finds everything it found — in the same order — with the section it names now first (its title IS the
    /// word: the thing she named comes first, the search's own ranking rule).
    @Test func typingSyncStillFindsWhatItFoundWithTheSectionFirst() {
        let found = SettingsSearch.findings(matching: "sync", in: SettingsSearch.wholeIndex)
        let before = SettingsSearch.findings(
            matching: "sync", in: SettingsSearch.wholeIndex.filter { !Self.isAccountSection($0.finding) })
        #expect(found.filter { !Self.isAccountSection($0) } == before, "nothing it found is lost or reordered")
        #expect(!before.isEmpty, "the bound is real: \"sync\" found rows before the section joined")
        #expect(found.first.map(Self.isAccountSection) == true, "\(found.map(\.lead))")
    }
}
