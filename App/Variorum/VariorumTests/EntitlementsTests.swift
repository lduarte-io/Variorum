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
}
