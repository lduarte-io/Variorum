//
//  SignInFlow.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 1 — the browser half of the delegated PKCE sign-in
//  (route A, Step 0 memo): ASWebAuthenticationSession opens the Variorum
//  project's `/auth/v1/authorize?provider=custom:fragments` URL and captures
//  the `variorum://auth-callback?code=…` redirect (no Info.plist scheme
//  registration needed — the session intercepts its own callback). The
//  testable machinery — PKCE, URL composition, the code exchange — lives in
//  `AuthSession`; this file is the thin presentation face (untested by
//  design, the Phase 8/9d convention for thin faces; the author's sign-in
//  at the Step 6 gate exercises it for real).
//
//  Review round 1 (MAJOR — three stacked lifecycle hazards, each traced):
//   1. the session object must be RETAINED for the flow's duration
//      (ASWebAuthenticationSession's documented requirement; a local let
//      inside the continuation closure could deallocate mid-presentation);
//   2. `start()` returning false means the completion handler will NEVER
//      run — the continuation must be resumed (throwing) or the caller
//      awaits forever with the sign-in surface wedged busy;
//   3. the presentation anchor must be a REAL window — a bare
//      `ASPresentationAnchor()` is scene-less on iOS and a known
//      failure-to-present cause; Gate 3 runs this exact flow on the phone.
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
            let session = ASWebAuthenticationSession(
                url: authorizeURL,
                callbackURLScheme: callbackScheme
            ) { callbackURL, error in
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
