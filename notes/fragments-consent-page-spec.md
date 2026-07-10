# Fragments OAuth login/consent page — spec for the author's site agent

**What this is (Phase 9c, Step 0/5):** the one web page the Fragments↔Variorum
one-account sign-in needs permanently. Supabase's OAuth 2.1 Server hosts NO
login/consent UI — it 302s to the project's own Site URL and expects the app to
implement the screen. Fragments is iOS-only, so the page lives on the author's
web home (**stargazing.tech** — her 2026-07-10 call). This file is the handoff
spec; the author carries it to that repo's agent (Variorum's agents never work
there). A working throwaway reference implementation exists at
`Spikes/AuthPairingSpike/consent.html` in the Variorum repo — the production page
is the same logic, hosted and styled.

## Contract

- **Route:** one page, e.g. `https://stargazing.tech/fragments/consent` (any path —
  it just has to match what's configured). Query parameter on arrival:
  `?authorization_id=<uuid>`.
- **Backend it talks to:** the FRAGMENTS Supabase project,
  *[removed for publication]*
  key** only (a public value; never a secret key, never a PAT).
- **Flow (all plain `fetch`, or supabase-js if that repo prefers):**
  1. Read `authorization_id` from the query. Missing → render an error.
  2. Sign the user in against the Fragments project (ordinary Supabase Auth —
     email+password today; whatever methods the Fragments account supports).
     Every REST call carries the `apikey` header; authenticated calls add
     `Authorization: Bearer <user access token>`.
  3. `GET /auth/v1/oauth/authorizations/{authorization_id}` (user bearer) —
     returns the requesting client + scopes; render them.
  4. Approve/Deny buttons →
     `POST /auth/v1/oauth/authorizations/{authorization_id}/consent` with body
     `{"action": "approve"}` (or `"deny"`).
  5. The response carries a `redirect_url` — send the browser there
     (`location.href`). That completes the hop back to the requesting client.
- **After the page exists,** the author updates the Fragments project's dashboard
  (Auth → OAuth Server): **Site URL** = `https://stargazing.tech` (or wherever),
  **Authorization Path** = the page's path. NOTE the page's save step is easy to
  miss — it silently discarded values twice during the spike; verify by reloading.

## Behavior notes

- **Consent auto-skips on repeat client+scope** (server-side): after the first
  approval, later sign-ins for the same user+client+scope go straight through —
  in steady state this page is nearly never seen. It still must exist: first
  approvals, new scopes, and new clients land on it.
- Keep it minimal: no session persistence beyond the flow, no analytics on the
  tokens, never log the bearer. Style is the site agent's call.
- Expired/consumed `authorization_id`s return an error from step 3 — render it
  plainly with a "start over from the app" hint.

## Non-goals

No Variorum-side code depends on this page's markup — only on the OAuth server
completing the hop. No Fragments-repo changes are involved (dashboard
configuration only, author-performed).
