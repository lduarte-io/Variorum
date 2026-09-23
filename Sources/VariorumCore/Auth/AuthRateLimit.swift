import Foundation

/// 13y UNIT B (the ruled memo §5; the plan's Step 4b — the ADDENDUM's
/// "state the numbers… and make the app's refusal wording honest") — the
/// AUTH RATE LIMIT's client-side truth: one pure classifier and ONE honest
/// sentence, adopted by the app's sign-in presentation (the re-auth doors'
/// password verification rides the same token endpoint).
///
/// THE NUMBERS, STATED AS FACTS (the kickoff's Sonnet lookup, memo §5;
/// re-verified at 13t with pricing): Supabase's token endpoint — the
/// password grant every sign-in and every re-auth door's `verifyPassword`
/// hits — defaults to **150 requests per 5 minutes per IP, with bursts to
/// 30, configurable** (supabase.com/docs/guides/auth/rate-limits). The
/// recorded caveats, honestly: the limit is IP-SCOPED (a distributed
/// brute-force is not capped per account) and the tracker holds
/// under-enforcement reports — so these limits are a stated fact and a
/// SPEED BUMP, never the wall. The walls are the password itself, the
/// per-request key proof, and the E2EE design (the account password alone
/// sees nothing — the postures design §3.10's consequence).
public enum AuthRateLimit {
    /// Whether an auth-endpoint refusal is the rate limiter's. GoTrue
    /// answers HTTP 429; its modern bodies carry the
    /// `over_request_rate_limit` error code (the two-vocabulary precedent
    /// — status first, token as the belt).
    public static func isRateLimited(status: Int, body: String) -> Bool {
        status == 429 || body.lowercased().contains("over_request_rate_limit")
    }

    /// The app's honest refusal (the memo's wording): never "wrong
    /// password" — nothing about the CREDENTIAL was judged.
    public static let refusalWording =
        "Too many attempts — wait a few minutes and try again."
}
