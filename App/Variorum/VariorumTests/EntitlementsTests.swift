//
//  EntitlementsTests.swift
//  VariorumTests
//
//  Phase 11b review round 1 (BLOCKER + MAJOR 1): the app's first-ever
//  user-selected WRITES (B1's save panels + bulk export) and app-scoped
//  bookmarks (B3's references) need entitlements the target never carried —
//  the 9c-finding-3 class (a capability's first use is where its missing
//  entitlement surfaces). These pins read the TEST HOST's (the app's) real
//  signed entitlements via SecTask, so a build-setting regression fails the
//  suite instead of silently killing every export door in the author's
//  install. RED on the pre-fix settings (readonly, no bookmarks
//  entitlement) — the review's required red state, confirmed by run.
//

import Foundation
import Security
import Testing

@Suite("App entitlements (Phase 11b, review round 1)")
struct EntitlementsTests {
    private func entitlement(_ name: String) -> Bool {
        guard let task = SecTaskCreateFromSelf(nil) else { return false }
        let value = SecTaskCopyValueForEntitlement(task, name as CFString, nil)
        return (value as? Bool) ?? false
    }

    /// BLOCKER: without user-selected READ-WRITE, macOS refuses to display
    /// NSSavePanel at all (documented powerbox behavior) and a chosen
    /// folder's grant is read-only — every export door dead in the
    /// sandboxed install.
    @Test func userSelectedFilesAreReadWrite() {
        #expect(entitlement("com.apple.security.files.user-selected.read-write"))
    }

    /// MAJOR 1: app-SCOPED bookmarks (the reference panel's cross-launch
    /// access) require this entitlement per Apple's written docs; the
    /// sandbox itself must still be on (the entitlements file must MERGE
    /// with the synthesized settings, never replace them).
    @Test func appScopedBookmarksAreDeclaredAndTheSandboxHolds() {
        #expect(entitlement("com.apple.security.files.bookmarks.app-scope"))
        #expect(entitlement("com.apple.security.app-sandbox"))
        // The 9c network entitlement must survive the merge too.
        #expect(entitlement("com.apple.security.network.client"))
    }

    /// pre-13x batch 0 (design §3.7, review P8): the SHARED keychain access
    /// group rides SECOND behind the target's own — the order is
    /// load-bearing (an item written with no group lands in the FIRST
    /// group, so the default must stay first or every existing custody
    /// item strands), and the shared string is what makes an iCloud item
    /// visible from the phone. RED before the entitlements change (one
    /// group); a Developer ID build that drops either goes red here too.
    @Test func theSharedKeychainAccessGroupRidesSecondBehindTheTargetsOwn() {
        guard let task = SecTaskCreateFromSelf(nil) else {
            Issue.record("SecTaskCreateFromSelf returned nil")
            return
        }
        let groups = SecTaskCopyValueForEntitlement(task, "keychain-access-groups" as CFString, nil)
            as? [String] ?? []
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        #expect(groups.count == 2, "two groups, got \(groups)")
        #expect(groups.first?.hasSuffix("." + bundleID) == true,
                "the FIRST group is the target's own (\(bundleID)), got \(groups)")
        #expect(groups.last?.hasSuffix(".io.lduarte.Variorum.shared") == true,
                "the SECOND group is the shared one, got \(groups)")
    }

    /// 13r U2: Sparkle's XPC installer road for a sandboxed app. The two
    /// mach-lookup exceptions are named after the build's OWN bundle id (the
    /// variable form), so this Debug host reads `….debug-spks` / `-spki`
    /// while the Release export reads `io.lduarte.Variorum-spks` / `-spki`
    /// (the release pipeline's export check pins that side EXACTLY).
    ///
    /// MEASURED at 13r U2: when Xcode signs a test host it APPENDS its own
    /// names to this array (`com.apple.testmanagerd`,
    /// `com.apple.dt.testmanagerd.runner`, `com.apple.coresymbolicationd`). So
    /// this asserts OUR two names LEAD, in order, and that neither appears
    /// twice; the injected extras are Xcode's, not the app's.
    @Test func sparklesInstallerMachServicesFollowTheBuildsOwnBundleID() {
        guard let task = SecTaskCreateFromSelf(nil) else {
            Issue.record("SecTaskCreateFromSelf returned nil")
            return
        }
        let names = SecTaskCopyValueForEntitlement(
            task, "com.apple.security.temporary-exception.mach-lookup.global-name" as CFString, nil)
            as? [String] ?? []
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let ours = [bundleID + "-spks", bundleID + "-spki"]
        #expect(!bundleID.isEmpty)
        #expect(Array(names.prefix(2)) == ours, "got \(names)")
        #expect(names.filter { $0.hasSuffix("-spks") || $0.hasSuffix("-spki") } == ours,
                "exactly our two Sparkle names, got \(names)")
    }
}
