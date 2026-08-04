# Stargazing suite login/consent page — brief for the stargazing.tech agent (Phase 14a)

**What this is:** the ONE web page the stargazing suite's single sign-in needs.
Supabase's OAuth 2.1 Server hosts NO login/consent UI — it 302s the browser to
`{Site URL}{Authorization Path}?authorization_id=<uuid>` and expects this page to
do sign-in + approve/deny + the redirect back. This page is the suite's front
door for EVERY app (Fragments first; future apps arrive as new OAuth clients
with zero page changes). The author's instruction on polish, verbatim: *"it
really just has to be done, not pretty."*

**This SUPERSEDES `notes/fragments-consent-page-spec.md`** (9c's version targeted
the Fragments project as issuer; that arrangement is retired at Phase 14a). Same
contract, different backend — a working throwaway reference implementation lives
at `Spikes/SuiteAccountSpike/consent.html` in the Variorum repo, including the
two traps that cost live failures in 9c.

## Contract

- **Route:** `https://stargazing.tech/oauth/consent` (any path works — the final
  URL is the author's call, incl. the stargazing.tech vs planetlillian.com
  question; whatever ships gets configured in the Supabase dashboard as
  Site URL = the origin, Authorization Path = the path). Query parameter on
  arrival: `?authorization_id=<uuid>`.
- **Backend it talks to:** the suite account project,
  `https://<supabase-project-ref>.supabase.co`, using its **publishable API key**
  (public by design): `sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp`.
  Every REST call carries the `apikey` header; authenticated calls add
  `Authorization: Bearer <user access token>`. Plain `fetch` or supabase-js —
  the site agent's choice.
- **Flow:**
  1. Read `authorization_id` from the query. Missing → render an error.
  2. Sign the user in: `POST /auth/v1/token?grant_type=password` with
     `{"email": …, "password": …}` (suite accounts are email+password).
  3. `GET /auth/v1/oauth/authorizations/{authorization_id}` (user bearer) —
     **check the response for `redirect_url` FIRST**: for a previously-granted
     user+client+scope the server auto-approves at this fetch and the response
     IS the final redirect — send the browser there immediately and stop (a
     consent POST at that point 400s with "authorization request is no longer
     pending"). Only when no `redirect_url` is present is the authorization
     still pending: render the requesting client + scopes from the JSON.
     **TRAP (cost a live failure 2026-07-11): the PENDING response also carries
     a field named `redirect_uri` — the client's REGISTERED callback base, no
     code/state. It is metadata, never a navigation target. Match the key
     `redirect_url` exactly; never fall back to `redirect_uri`.**
  4. Approve/Deny buttons →
     `POST /auth/v1/oauth/authorizations/{authorization_id}/consent` with body
     `{"action": "approve"}` (or `"deny"`).
  5. The response carries a `redirect_url` — `location.href` there. Done.
- **NO create-account door yet.** Sign-ups are deliberately OFF on the account
  project until a later phase (a signup attempt 403s — that is correct
  behavior, not an outage). Optionally render one line: "Sign-ups aren't open
  yet." A sign-up form will be ADDED to this same page at that phase — leave
  room, build nothing.

## Behavior notes (carried from the 9c page, all observed live)

- **Consent auto-skips on repeat client+scope — but THROUGH this page, not
  around it:** the browser always lands here; the auto-approval surfaces as
  `redirect_url` on the step-3 fetch. Steady state: arrive → already signed
  in → auto-approved → redirect, no visible prompt. A page that unconditionally
  renders Approve/Deny hits the step-3 400 — the 9c spike shipped exactly this
  bug; follow the redirect first.
- **Persist the session** (supabase-js does via localStorage; hand-rolled =
  store/refresh it yourself) so repeat authorizations are password-free. The
  apps open this page inside non-ephemeral `ASWebAuthenticationSession`
  contexts, so persistence carries across runs. Sign-ins are rare (~once per
  device) — a nicety, not a requirement.
- Expired/consumed `authorization_id`s error at step 3 — render plainly with a
  "start over from the app" hint.
- Keep it minimal: the persisted session is the ONE recommended piece of
  state. No analytics on any of it; never log the bearer or the password.

## Non-goals

No app depends on this page's markup — only on the OAuth hop completing. Style
is entirely the site agent's call ("done, not pretty"). No secret key, no PAT,
no server-side code required — this is a static page talking to the Supabase
REST API from the browser.
