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

import AuthenticationServices
import Foundation

@MainActor
final class SignInFlow: NSObject, ASWebAuthenticationPresentationContextProviding {
    enum FlowError: Error {
        case cancelled
        case failed(String)
    }

    /// Runs one browser sign-in and returns the captured callback URL.
    func run(authorizeURL: URL, callbackScheme: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
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
            session.start()
        }
    }

    nonisolated func presentationAnchor(
        for session: ASWebAuthenticationSession
    ) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
