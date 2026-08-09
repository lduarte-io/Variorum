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
    /// D1: the phone's styling seam (nil on the Mac ALWAYS). The nil
    /// arms below are render-identical to the pre-D1 lines (the note
    /// lives in caption-font containers; the explicit `.font(.caption)`
    /// the helpers add changes nothing there).
    @Environment(\.sharedPageStyle) private var pageStyle

    @ViewBuilder
    var body: some View {
        if ErrorPresentation.isAuthShaped(error) {
            Text(ErrorPresentation.authGuidance)
                .pageCaptionWarning(pageStyle)
                .lineLimit(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        Text(error)
            .pageCaption(pageStyle)
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

    /// Phase 14c batch 3 (L8) — the SIGN-UP form's classify-and-speak,
    /// the R94 doctrine at the account-creation door. The COMMON refusal
    /// through the whole pre-gate era is the signups-off toggle (the
    /// corpus guard, flipped only as the gate's deliberate act): it must
    /// speak honestly as a CLOSED DOOR, never as a generic failure — the
    /// server is refusing all new accounts, not this user's input.
    static let signUpClosedMessage =
        "Account creation isn't open yet — this server isn't accepting new accounts."

    static let signUpExistsMessage =
        "An account with this email already exists — sign in instead."

    static func signUpFailureMessage(_ error: any Error) -> String {
        if let authError = error as? AuthSessionError {
            switch authError {
            case .endpointFailure(let status, let body):
                let lowered = body.lowercased()
                // GoTrue's modern refusals carry `error_code` tokens; the
                // message-text arms cover older bodies (the sign-in
                // classifier's two-vocabulary precedent, R1-1).
                if lowered.contains("signup_disabled")
                    || lowered.contains("signups not allowed") {
                    return signUpClosedMessage
                }
                if lowered.contains("user_already_exists")
                    || lowered.contains("email_exists")
                    || lowered.contains("already registered") {
                    return signUpExistsMessage
                }
                if lowered.contains("email_address_not_authorized")
                    || lowered.contains("not authorized") {
                    // The pre-SMTP era's real refusal: the built-in mailer
                    // delivers only to the project team's addresses, so a
                    // stranger's confirmation email refuses even with
                    // signups ON. Honest: the server's email delivery, not
                    // the user's input.
                    return "The server couldn't send a confirmation email to that address — "
                        + "email delivery isn't fully set up yet. Try again later."
                }
                if lowered.contains("weak_password")
                    || lowered.contains("password should be") {
                    return "That password is too short or too weak for the server — try a longer one."
                }
                if status == 429 || lowered.contains("rate limit")
                    || lowered.contains("rate_limit") {
                    return "Too many attempts right now — wait a minute and try again."
                }
                if lowered.contains("validation_failed")
                    || lowered.contains("invalid format")
                    || lowered.contains("is invalid") {
                    return "That doesn't look like a valid email address — check it and try again."
                }
                return "Account creation failed — the server refused (HTTP \(status)). Try again in a moment."
            case .notHTTP, .malformedResponse:
                return "Account creation failed — the server's response couldn't be read. Try again in a moment."
            }
        }
        if error is URLError || (error as NSError).domain == NSURLErrorDomain {
            return "Couldn't reach the server — check your connection and try again."
        }
        return "Account creation failed: \(error.localizedDescription)"
    }

    /// Phase 14a review round 1 (R1-1) — the SIGN-IN FORM's classify-and-
    /// speak: the account form's failures surface as human lines, never a
    /// raw enum dump (`String(describing:)` of `endpointFailure` was the
    /// pre-fix face of a wrong password — the direct form's COMMON refusal).
    ///
    /// The credentials class (the password grant's HTTP 400 / `invalid_grant`
    /// refusal) gets the ruled wording — "Wrong email or password."
    /// (PROVISIONAL, riding the gate checklist). Deliberately NOT routed
    /// through `ErrorCauseNote`: its "sign out and back in" guidance is for
    /// ESTABLISHED sessions and is exactly wrong on the sign-in form itself.
    /// (Moved home 2026-08-05, ladder R1-5 — the 14c sign-up block had been
    /// inserted between this comment and its function, re-attaching it to
    /// `signUpClosedMessage`.)
    static func signInFailureMessage(_ error: any Error) -> String {
        if let authError = error as? AuthSessionError {
            switch authError {
            case .endpointFailure(let status, let body):
                let lowered = body.lowercased()
                if status == 400,
                   lowered.contains("invalid_grant")
                       || lowered.contains("invalid_credentials")
                       || lowered.contains("invalid login credentials") {
                    return "Wrong email or password."
                }
                return "Sign-in failed — the server refused (HTTP \(status)). Try again in a moment."
            case .notHTTP, .malformedResponse:
                return "Sign-in failed — the server's response couldn't be read. Try again in a moment."
            }
        }
        if error is URLError || (error as NSError).domain == NSURLErrorDomain {
            return "Couldn't reach the server — check your connection and try again."
        }
        return "Sign-in failed: \(error.localizedDescription)"
    }
}
