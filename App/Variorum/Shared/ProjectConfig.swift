//
//  ProjectConfig.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 5 — the two Supabase projects' PUBLIC coordinates,
//  hardcoded exactly the way Fragments hardcodes its own key: after the
//  04_auth_rls.sql flip the Variorum API key identifies the project and
//  grants NOTHING (RPC execution requires an authenticated user; RLS
//  fences the tables), and Fragments' key has been publishable all along
//  (their RLS is the guard). No credential entry ever — the session is
//  the identity.
//
//  Phase 14a (sitting round 0h): the VARIORUM project is the suite's
//  account home and OAuth 2.1 issuer — the app signs in DIRECTLY to it
//  with the suite email+password; only OTHER apps (Fragments, future)
//  ride the delegated OAuth flow, and none of that flow lives in this
//  app's code anymore.
//
//  PRECONDITION FOR THE "GRANTS NOTHING" CLAIM (9c review round 1,
//  BLOCKER — still LOAD-BEARING, ruled-state banner): the Variorum
//  project's "Allow new users to sign up" toggle must be OFF. On a
//  default project the bare key can MINT an authenticated session via
//  /auth/v1/signup — and every authenticated user reads/writes the
//  non-owner tables (the whole prose corpus) in the single-user phase.
//  The toggle is the SOLE guard until 14c's parent-join isolation;
//  existing users (the author) are unaffected.
//

import Foundation
import VariorumCore

nonisolated enum ProjectConfig {
    // MARK: Variorum (the mirror + the sign-in — the suite account home)

    static let variorumProjectURL = URL(string: "https://qpzmroxogeufzizcuunl.supabase.co")!
    /// The Variorum project's PUBLISHABLE API key — author-filled at the
    /// 9c Step 6 gate; empty = the sign-in surface stays dormant.
    static let variorumPublishableKey = "sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp"

    // MARK: Fragments (the 9b bridge's backend; QUESTIONS #16 shape (c))

    static let fragmentsProjectURL = URL(string: "https://sqpaqelorlxgmraynyam.supabase.co")!
    /// The Fragments project's PUBLISHABLE API key (their key has always
    /// been publishable — their RLS is the guard) — author-filled.
    static let fragmentsPublishableKey = "sb_publishable_3grqdR6KQSE0uYlul0kzGA_oray8M9s"

    static var variorumConfigured: Bool { !variorumPublishableKey.isEmpty }
    static var fragmentsConfigured: Bool { !fragmentsPublishableKey.isEmpty }

    /// The Variorum sign-in — the DIRECT suite email+password against the
    /// project itself (Phase 14a, round 0h).
    static var variorumAuth: AuthConfiguration {
        AuthConfiguration(
            projectURL: variorumProjectURL,
            apiKey: variorumPublishableKey)
    }

    /// The bridge's Fragments-project session configuration. Two doors
    /// mint it: the direct password grant (QUESTIONS #16 shape (c) — dies
    /// with her Fragments password at touchpoint #1) and, since 14d, the
    /// DELEGATED road below (the door that outlives the retirement).
    static var fragmentsAuth: AuthConfiguration {
        AuthConfiguration(
            projectURL: fragmentsProjectURL,
            apiKey: fragmentsPublishableKey)
    }

    /// The suite issuer's provider entry ON THE FRAGMENTS PROJECT
    /// (touchpoint #1 creates it): `custom:stargazing`. If their config
    /// lands under a different slug, this one constant follows it.
    static let fragmentsSuiteProviderSlug = "stargazing"

    /// The app's callback for the delegated bridge sign-in. Must be on
    /// the FRAGMENTS project's Redirect URLs allow-list (a touchpoint #1
    /// config item — the batch prompt carries it). No Info.plist scheme
    /// registration is needed; the browser sign-in session (SignInFlow)
    /// intercepts its own callback.
    static let fragmentsBridgeRedirectURI = "variorum://auth-callback"

    static var variorumTransport: SupabaseTransport.Configuration {
        SupabaseTransport.Configuration(
            projectURL: variorumProjectURL, apiKey: variorumPublishableKey)
    }
}
