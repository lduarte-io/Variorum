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
