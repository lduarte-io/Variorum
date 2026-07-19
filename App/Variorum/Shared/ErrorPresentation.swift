//
//  ErrorPresentation.swift
//  Variorum (shared: Mac + Mobile)
//
//  Taste-checkpoint fix round (Sitting 9, R94): her bridge outage showed
//  "Bridge error" with the cause hidden in a hover tooltip — and the cause
//  was auth-shaped (fixed by sign-out/sign-in after Fragments changed
//  their sync). Errors CLASSIFY and SPEAK: an auth-shaped failure says
//  "sign in again" and the row offers the door; the detail renders inline,
//  never hover-only.
//

import Foundation
import SwiftUI

/// The R94 inline-cause block, ONE component for every status row: the
/// auth guidance (when the failure is auth-shaped) + the verbatim error —
/// wrapping, selectable, never hover-only.
///
/// The line limits are LOAD-BEARING, not cosmetic. This block lives in
/// non-scrolling window chrome (the sidebar footer), and the window's
/// minimum-size probe proposes near-zero width — an UNLIMITED
/// `fixedSize(vertical: true)` text measures one-character-per-line there
/// (~140 lines ≈ 1693 pt for the guidance string alone), and that number
/// becomes the WINDOW's minimum height. That was the Sitting 9 wedged
/// window: pinned taller than the screen, undraggable, every bottom bar
/// invisible. `ChromeMinHeightTests` pins the probed height.
struct ErrorCauseNote: View {
    let error: String

    @ViewBuilder
    var body: some View {
        if ErrorPresentation.isAuthShaped(error) {
            Text(ErrorPresentation.authGuidance)
                .foregroundStyle(.orange)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        Text(error)
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }
}

enum ErrorPresentation {
    /// True when the failure smells like a dead/stale session — the class
    /// her outage was in (a wedged refresh path after a server-side auth
    /// change; HTTP 401/403s, token/JWT vocabulary, expiry).
    static func isAuthShaped(_ text: String) -> Bool {
        let lowered = text.lowercased()
        return ["401", "403", "unauthorized", "forbidden", "jwt", "token",
                "invalid_grant", "expired", "refresh", "session", "signed out",
                "sign in", "auth"]
            .contains { lowered.contains($0) }
    }

    /// The row's guidance line for an auth-shaped failure.
    static let authGuidance =
        "This looks like a sign-in problem — Account… → sign out and back in usually clears it "
        + "(server-side auth changes can strand the old session)."
}
