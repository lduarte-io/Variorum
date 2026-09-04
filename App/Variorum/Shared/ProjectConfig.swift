//
//  ProjectConfig.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 9c, Step 5 — the Supabase project's PUBLIC coordinates,
//  hardcoded: after the 04_auth_rls.sql flip the Variorum API key
//  identifies the project and grants NOTHING (RPC execution requires an
//  authenticated user; RLS fences the tables). No credential entry ever —
//  the session is the identity. (The Fragments project's coordinates
//  stood beside these for the journal bridge until its 2026-09-04
//  retirement — pre-13x batch 0b.)
//
//  Phase 14a (sitting round 0h): the VARIORUM project is the suite's
//  account home and OAuth 2.1 issuer — the app signs in DIRECTLY to it
//  with the suite email+password. Other apps (Fragments) ride the
//  delegated OAuth flow against it.
//
//  THE "GRANTS NOTHING" CLAIM, RULED STATE AS OF 14D (2026-08-16 —
//  supersedes the 9c-era signups-OFF banner that stood here): signups
//  are deliberately OPEN (the release posture; her go at the 14d
//  sitting). The bare key can mint an authenticated session — and that
//  session reaches NOTHING of anyone else's: the guard is 14c's
//  born-multi-tenant isolation (composite (owner_id, id) PKs, forced
//  RLS + tenant-scoped RPC guards, proven by 13 live obligations
//  against a real stranger) plus the entitlement gate (a fresh account
//  cannot write to the mirror until a plan activates). Do NOT re-close
//  the signup toggle on this banner's old wording — the OFF era ended
//  when the isolation shipped and the door's opening was the 14d
//  deliberate act. (History: 9c review round 1's BLOCKER made the OFF
//  toggle the SOLE guard of the single-user era — correct then, ended
//  now.)
//

import Foundation
import VariorumCore

nonisolated enum ProjectConfig {
    // MARK: Variorum (the mirror + the sign-in — the suite account home)

    static let variorumProjectURL = URL(string: "https://qpzmroxogeufzizcuunl.supabase.co")!
    /// The Variorum project's PUBLISHABLE API key — author-filled at the
    /// 9c Step 6 gate; empty = the sign-in surface stays dormant.
    static let variorumPublishableKey = "sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp"

    static var variorumConfigured: Bool { !variorumPublishableKey.isEmpty }

    /// The Variorum sign-in — the DIRECT suite email+password against the
    /// project itself (Phase 14a, round 0h).
    static var variorumAuth: AuthConfiguration {
        AuthConfiguration(
            projectURL: variorumProjectURL,
            apiKey: variorumPublishableKey)
    }

    static var variorumTransport: SupabaseTransport.Configuration {
        SupabaseTransport.Configuration(
            projectURL: variorumProjectURL, apiKey: variorumPublishableKey)
    }
}
