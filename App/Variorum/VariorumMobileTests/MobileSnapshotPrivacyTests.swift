//
//  MobileSnapshotPrivacyTests.swift
//  VariorumMobileTests
//
//  Pre-Stage-A (2026-08-04) — the app-switcher snapshot cover's rule
//  pins (the 14b mobile flow notes' flagged consideration, built
//  PROVISIONAL). The view renders FROM the rule (the doors-as-data
//  pattern at the shell's scale), so pinning the rule pins the shipped
//  behavior: an inactive or backgrounded scene redacts exactly the
//  privacySensitive spans — the 12 recovery words and the phrase entry
//  fields — and an active scene redacts nothing.
//

import SwiftUI
import Testing
@testable import VariorumMobile

@Suite("Snapshot privacy — the app-switcher cover rule (pre-Stage-A)")
struct MobileSnapshotPrivacyTests {
    /// Active = no redaction: the running app never covers the words the
    /// user is in the middle of writing down.
    @Test func anActiveSceneRedactsNothing() {
        #expect(SnapshotPrivacy.redactionReasons(for: .active).isEmpty)
    }

    /// Inactive fires BEFORE the system snapshots (the app switcher
    /// opening deactivates the scene) — this is the arm the cover exists
    /// for. Background rides the same rule: a backgrounded scene must
    /// never re-expose the spans either.
    @Test func inactiveAndBackgroundScenesRedactPrivacySensitiveSpans() {
        #expect(SnapshotPrivacy.redactionReasons(for: .inactive).contains(.privacy))
        #expect(SnapshotPrivacy.redactionReasons(for: .background).contains(.privacy))
    }
}
