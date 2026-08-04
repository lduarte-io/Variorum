# Stargazing suite login pages — brief for the stargazing.tech agent (Phase 14a)

**What this is:** the small set of web pages the stargazing suite's single
sign-in needs. Supabase's OAuth 2.1 Server hosts NO login/consent UI — it 302s
the browser to `{Site URL}{Authorization Path}?authorization_id=<uuid>` and
expects a page to do sign-in + approve/deny + the redirect back. These pages are
the suite's front door for EVERY app (Fragments first; future apps arrive as new
OAuth clients with zero page changes).

**Home: stargazing.tech** (the author's call, 2026-08-03 — it's currently up).
Style and layout are the site agent's discretion — the author's priority is that
the wiring is complete and reliable (sign-in working from phones, the apps'
flows landing here), not any particular look. **Build the COMPLETE set below in
one pass** — the site rebuilds on push and the author wants a limited number of
deploys, so this brief deliberately includes everything, including the sign-up
form that will refuse until sign-ups open.

**This SUPERSEDES `notes/fragments-consent-page-spec.md`** (9c's version
targeted the Fragments project as issuer; that arrangement is retired at Phase
14a). A working throwaway reference implementation lives in the Variorum repo at
`Spikes/SuiteAccountSpike/` (`consent.html` + `index.html`), including the two
traps that cost 9c live failures.

## Shared plumbing (all pages)

*[removed for publication]*
  using its **publishable API key** (public by design):
  `sb_publishable_X-TQvz2RDj4cnCABZao4ww_WWGdSTwp`. Every REST call carries the
  `apikey` header; authenticated calls add `Authorization: Bearer <access token>`.
  Plain `fetch` or supabase-js — the agent's choice.
- **Paths:** suggested below; any paths work — whatever ships gets configured in
  the Supabase dashboard (Site URL = the origin, Authorization Path = the consent
  page's path). One recommendation, the author's call: prefer a **suite-neutral
  path** (`/oauth/…` or `/account/…`) over an app-named one — Fragments users
  land on these pages too, and future apps will as well.
- **Security posture:** no secret keys, no PAT, no server-side code required —
  static pages talking to the Supabase REST API from the browser. Never log
  bearers or passwords; no analytics on any of it. Persisting the signed-in
  session (supabase-js does via localStorage) is the ONE recommended piece of
  state — it makes repeat authorizations password-free.

## Page 1 — sign-in + consent (`/oauth/consent`) — the load-bearing one

Query parameter on arrival: `?authorization_id=<uuid>`.

1. Read `authorization_id`. Missing → render an error.
2. If no session: sign-in form → `POST /auth/v1/token?grant_type=password` with
   `{"email": …, "password": …}`.
3. `GET /auth/v1/oauth/authorizations/{authorization_id}` (user bearer) —
   **check the response for `redirect_url` FIRST**: for a previously-granted
   user+client+scope the server auto-approves at this fetch and the response IS
   the final redirect — send the browser there immediately and stop (a consent
   POST at that point 400s with "authorization request is no longer pending").
   Only when no `redirect_url` is present is the authorization still pending:
   render the requesting client + scopes from the JSON.
   **TRAP (cost a live failure 2026-07-11): the PENDING response also carries a
   field named `redirect_uri` — the client's REGISTERED callback base, no
   code/state. It is metadata, never a navigation target. Match the key
   `redirect_url` exactly; never fall back to `redirect_uri`.**
4. Approve/Deny → `POST /auth/v1/oauth/authorizations/{authorization_id}/consent`
   with `{"action": "approve"}` (or `"deny"`).
5. The response carries `redirect_url` — `location.href` there. Done.
6. Expired/consumed `authorization_id`s error at step 3 — render plainly with a
   "start over from the app" hint.

**Steady-state behavior to preserve:** consent auto-skips on repeat
client+scope — but THROUGH this page, not around it. Arrive → already signed in
(persisted session) → step-3 auto-approves → redirect, no visible prompt. A page
that unconditionally renders Approve/Deny hits the step-3 400 — the 9c spike
shipped exactly this bug; follow the redirect first.

## Page 2 — sign-up (on the consent page or its own route)

Build the form NOW, fully wired: email + password →
`POST /auth/v1/signup` with `{"email": …, "password": …}`.

- **Sign-ups are deliberately CLOSED on the account project for now** — the
  endpoint refuses (4xx). Render that refusal as *"Sign-ups aren't open yet"* —
  it is correct behavior, not an outage. When sign-ups open (a later Variorum
  phase), this form starts working with **zero page changes** — that's why it
  ships wired now.
- On a success response (later): if it returns a session, continue into the
  pending authorization exactly like a sign-in; if it returns
  confirmation-required, say "check your email."
- Nothing beyond email+password here — account-level encryption setup happens
  in the apps, never on the web.

## Page 3 — password reset catcher (`/oauth/reset`)

Password-recovery emails link through the project and land the browser at the
Site URL with `#access_token=…&type=recovery` in the URL fragment.

1. Read the fragment. `type=recovery` + `access_token` present → show a
   new-password form; otherwise a plain "use the reset link from your email"
   message.
2. Submit → `PUT /auth/v1/user` with `{"password": …}`, `Authorization: Bearer
   <the recovery access_token>` + `apikey`.
3. Confirm success plainly.
- A small "forgot password?" link on the consent page can trigger
  `POST /auth/v1/recover` with `{"email": …}` — include it.
- Note for the author's dashboard pass (not the site agent's): the project's
  Site URL / Redirect URLs config must point at this origin so the email links
  land here — that flip happens on the Variorum side once these pages deploy.

## After deploy (the author's dashboard flip — recorded here for completeness)

Supabase dashboard → Authentication → OAuth Server: **Site URL** =
`https://stargazing.tech`, **Authorization Path** = the consent page's path
(e.g. `/oauth/consent`). The dashboard has silently discarded values before —
save, reload, verify.

## Non-goals

No app depends on these pages' markup — only on the OAuth hop completing and
the reset catcher working. No EPUB-of-scope-creep: three small pages, complete
wiring, one deploy.
