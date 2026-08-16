//
//  SignInFlow.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14d — the browser half of the delegated PKCE sign-in, REBUILT
//  from the 9c machinery (retired at 14a batch 1; round 0x moved the
//  rebuild "wholesale to the Fragments-batch era", which is this phase)
//  and pointed the other way: at 14d the flow signs the BRIDGE into the
//  FRAGMENTS project via `custom:stargazing` (the suite issuer's provider
//  entry, touchpoint #1) — the road back in after her Fragments password
//  retires. ASWebAuthenticationSession opens the authorize URL and
//  captures the `variorum://auth-callback?code=…` redirect (no Info.plist
//  scheme registration needed — the session intercepts its own callback).
//  The testable machinery — PKCE, URL composition, the code exchange —
//  lives in `AuthSession`; this file is the thin presentation face
//  (untested by design, the Phase 8/9d convention for thin faces; the
//  author's sign-in at the batch exercises it for real).
//
//  The 9c lifecycle lessons, preserved verbatim (review round 1 MAJOR —
//  three stacked hazards — plus the Step 6 sitting's live SIGTRAP):
//   1. the session object must be RETAINED for the flow's duration
//      (ASWebAuthenticationSession's documented requirement; a local let
//      inside the continuation closure could deallocate mid-presentation);
//   2. `start()` returning false means the completion handler will NEVER
//      run — the continuation must be resumed (throwing) or the caller
//      awaits forever with the sign-in surface wedged busy;
//   3. the presentation anchor must be a REAL window — a bare
//      `ASPresentationAnchor()` is scene-less on iOS and a known
//      failure-to-present cause.
//

import AuthenticationServices
import Foundation

@MainActor
final class SignInFlow: NSObject, ASWebAuthenticationPresentationContextProviding {
    enum FlowError: Error {
        case cancelled
        case failed(String)
        case alreadyRunning
        case couldNotPresent
    }

    /// The strong reference ASWebAuthenticationSession requires for the
    /// flow's duration (hazard 1); doubles as the one-flight guard.
    private var activeSession: ASWebAuthenticationSession?

    /// Runs one browser sign-in and returns the captured callback URL.
    func run(authorizeURL: URL, callbackScheme: String) async throws -> URL {
        guard activeSession == nil else { throw FlowError.alreadyRunning }
        defer { activeSession = nil }
        return try await withCheckedThrowingContinuation { continuation in
            // The completion handler MUST be nonisolated (@Sendable): the
            // framework delivers it on a background XPC reply queue (observed
            // live at the 9c Step 6 sitting, 2026-07-11 — a @MainActor-
            // inherited closure traps Swift 6's isolation check there,
            // SIGTRAP in dispatch_assert_queue). Resuming a continuation is
            // thread-safe; nothing else may be touched in here.
            let session = ASWebAuthenticationSession(
                url: authorizeURL,
                callbackURLScheme: callbackScheme
            ) { @Sendable callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else if let authError = error as? ASWebAuthenticationSessionError,
                          authError.code == .canceledLogin {
                    continuation.resume(throwing: FlowError.cancelled)
                } else {
                    continuation.resume(throwing: FlowError.failed(
                        error.map(String.init(describing:)) ?? "no callback URL"))
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            activeSession = session
            // Hazard 2: a false return means the completion handler never
            // fires — resume the continuation ourselves or leak it (and
            // wedge the sign-in surface busy forever).
            if !session.start() {
                activeSession = nil
                continuation.resume(throwing: FlowError.couldNotPresent)
            }
        }
    }

    // Hazard 3: hand back a real, attached window. The provider method is
    // documented to run on the main thread.
    nonisolated func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            #if os(macOS)
            return NSApplication.shared.keyWindow
                ?? NSApplication.shared.mainWindow
                ?? NSApplication.shared.windows.first
                ?? ASPresentationAnchor()
            #else
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            let active = scenes.first { $0.activationState == .foregroundActive }
            return active?.keyWindow
                ?? active?.windows.first
                ?? scenes.first?.windows.first
                ?? ASPresentationAnchor()
            #endif
        }
    }
}
