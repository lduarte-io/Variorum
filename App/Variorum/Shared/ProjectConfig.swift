//
//  ProjectConfig.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 5 — the two Supabase projects' PUBLIC coordinates,
//  hardcoded exactly the way Fragments hardcodes its own key: after the
//  04_auth_rls.sql flip the Variorum API key identifies the project and
//  grants NOTHING (RPC execution requires an authenticated user; RLS
//  fences the tables), and Fragments' key has been publishable all along
//  (their RLS is the guard). This is the paste-in's retirement: no
//  credential entry ever again — the session is the identity.
//
//  THE AUTHOR FILLS THE TWO KEY CONSTANTS at the Step 6 gate (from her
//  untracked env files; they are publishable and committable by design —
//  the phase's whole point). Until filled, the sign-in surface shows the
//  unconfigured hint and nothing attempts a request.
//

import Foundation
import VariorumCore

nonisolated enum ProjectConfig {
    // MARK: Variorum (the mirror + the sign-in — Step 0 memo, route A)

    static let variorumProjectURL = URL(string: "https://qpzmroxogeufzizcuunl.supabase.co")!
    /// The Variorum project's PUBLISHABLE API key — author-filled at the
    /// Step 6 gate; empty = the sign-in surface stays dormant.
    static let variorumPublishableKey = ""

    // MARK: Fragments (the 9b bridge's backend; QUESTIONS #16 shape (c))

    static let fragmentsProjectURL = URL(string: "https://sqpaqelorlxgmraynyam.supabase.co")!
    /// The Fragments project's PUBLISHABLE API key (their key has always
    /// been publishable — their RLS is the guard) — author-filled.
    static let fragmentsPublishableKey = ""

    static var variorumConfigured: Bool { !variorumPublishableKey.isEmpty }
    static var fragmentsConfigured: Bool { !fragmentsPublishableKey.isEmpty }

    /// The Variorum sign-in (route A: the `custom:fragments` provider —
    /// Step 0 memo; slug + callback as deployed at the spike).
    static var variorumAuth: AuthConfiguration {
        AuthConfiguration(
            projectURL: variorumProjectURL,
            apiKey: variorumPublishableKey)
    }

    /// The bridge's direct Fragments-project session (QUESTIONS #16,
    /// PROVISIONAL (c)). The provider slug is irrelevant here — this
    /// session signs in with the password door, never PKCE.
    static var fragmentsAuth: AuthConfiguration {
        AuthConfiguration(
            projectURL: fragmentsProjectURL,
            apiKey: fragmentsPublishableKey)
    }

    static var variorumTransport: SupabaseTransport.Configuration {
        SupabaseTransport.Configuration(
            projectURL: variorumProjectURL, apiKey: variorumPublishableKey)
    }
}
