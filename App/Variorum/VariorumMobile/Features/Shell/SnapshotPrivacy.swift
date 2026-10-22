//
//  SnapshotPrivacy.swift
//  VariorumMobile
//
//  Pre-Stage-A (2026-08-04) — the app-switcher snapshot cover, the 14b
//  mobile flow notes' flagged consideration (weighed, built, PROVISIONAL
//  for her walk): iOS snapshots the window when the app deactivates, and
//  that snapshot lives in the app switcher. If the 12 recovery words (or
//  a typed phrase entry) are on screen, the snapshot holds them. The
//  shared faces that show them mark exactly those spans `privacySensitive`
//  (today's EncryptionView did first; it left with today's road at VX-329 U1);
//  this rule turns the marking into redaction whenever the scene is not
//  active, so the words never ride into a snapshot. Everything unmarked
//  renders normally — the switcher keeps its ordinary preview.
//
//  The Mac applies no redaction reasons, so the shared marking is inert
//  there by construction.
//

import SwiftUI

nonisolated enum SnapshotPrivacy {
    /// The one rule: an inactive or backgrounded scene redacts
    /// privacy-sensitive content; an active one redacts nothing.
    static func redactionReasons(for phase: ScenePhase) -> RedactionReasons {
        phase == .active ? [] : .privacy
    }
}
