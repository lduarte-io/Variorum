# Auth pairing spike (Phase 9c, Step 0 — THROWAWAY)

One delegated sign-in: the author's **Fragments** Supabase account signs into the
**Variorum** Supabase project via the custom-OIDC pairing (route A), and the resulting
session is inspected (Step 0(b)/(c)). Author-executed; nothing here touches the repo's
product code. Kept in-repo as evidence, like `Spikes/TK2Spike`.

Background facts (2026-07-10 lookup; details in the phase plan's Step 0 memo):
Supabase's OAuth 2.1 Server ships **no hosted login/consent UI** — the project's
Site URL app must implement it (`consent.html` here is the throwaway stand-in;
production's page lands on the author's own site). The Variorum side signs in through
`GET /auth/v1/authorize?provider=custom:<slug>` like any provider.

## One-time setup (author, dashboards — public values only)

1. **Register Variorum as an OAuth client of the Fragments project** (coordinator
   carries the exact curl/dashboard steps; outcome = a `client_id` + `client_secret`).
2. **Variorum project → Authentication → Custom Auth Providers → create:**
   slug `fragments` (the code will use provider `custom:fragments`), display name
   `Fragments`, auto-discovery from issuer
   `https://<supabase-project-ref>.supabase.co/auth/v1` (Discovery URL empty), the
   client id/secret from step 1, scopes `openid, email, profile`,
   allow-users-without-email OFF.
3. **Variorum project → Authentication → URL Configuration:** add
   `http://localhost:3000/callback.html` to the Redirect URLs (spike-only; remove after).
4. **Fragments project → Auth → OAuth Server:** Site URL stays
   `http://localhost:3000`; set **Authorization Path** to `/consent.html`.
5. Edit `consent.html`'s CONFIG block: the Fragments **publishable** key
   (never a secret key, never the PAT).

## Run

```bash
cd Spikes/AuthPairingSpike
python3 -m http.server 3000
```

Then open (one line, in a browser):

```
https://<supabase-project-ref>.supabase.co/auth/v1/authorize?provider=custom:fragments&redirect_to=http%3A%2F%2Flocalhost%3A3000%2Fcallback.html
```

Expected hops: Variorum `/authorize` → Fragments `/oauth/authorize` →
`consent.html` (sign in with the Fragments account, Approve) → back through both
projects → `callback.html` shows a **redacted** session summary.

## Record in the Step 0 memo

- `sub` + `iss` from the summary (the Variorum-project `auth.uid()` — the exact
  value class `owner_id` will carry), `email`, `amr`/provider metadata.
- `provider_token_present` / `provider_refresh_token_present` — Step 5's
  bridge-session question. If present: the decoded `provider_token_claims`
  (is it a Fragments-project user JWT — `iss`, `sub`, `role`?).
- Any refusal at any hop, verbatim.

Copy the redacted summary (button on the page) — raw tokens never leave the browser.

## Cleanup

Remove the localhost redirect URL from Variorum's URL configuration; point the
Fragments Authorization Path at the production consent page when it exists.
