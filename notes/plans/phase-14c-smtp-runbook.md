# Auth email (SMTP) + rate/abuse limits — the runbook

**Status: EXECUTED AT 14D (2026-08-16) — §2–§7 all done live:** Resend
chosen and domain-verified (her DNS hand), SMTP config + 30/hr rate
limit + 60 s resend window set via the Management API, her RATIFIED
(humanized) template copy pasted and then FLIPPED to the branded
`token_hash` form once the stargazing.tech `/auth/confirm` handler
shipped, delivery + branded-signup probes both live-verified. The
deployed config is the copy's source of truth; the 14d plan's Step 0 +
Part B records are the execution record. DMARC deliberately deferred
(her residual). *(Original status, for history: authored at Phase 14c
batch 3 (L10, 2026-08-05) as runbook-only, nothing configured, drafts
staged for her ratify.)*

Facts marked *(source-verified)* were pulled 2026-08-05 by the batch's one
Sonnet lookup — primary sources: the `supabase/auth` (GoTrue) source code
on GitHub and the live Supabase docs (`/guides/auth/auth-smtp`,
`/guides/auth/rate-limits`, `/guides/auth/auth-email-templates`,
`/guides/deployment/going-into-prod`). Provider pricing figures are
flagged where they were third-party-sourced.

---

## 1. Where things stand today (and why this runbook exists)

- **The built-in mailer delivers ONLY to the project team's addresses**
  *(source-verified — docs verbatim: "Supabase Auth will refuse to deliver
  messages to addresses that are not part of the project's team… All other
  addresses will fail with the error message Email address not
  authorized")*, and is capped at **2 messages/hour** (a value Supabase
  says can change without notice). Error code:
  `email_address_not_authorized`.
- **Consequence for the 14c GATE (flagged for the architect — a gate
  consideration, not this runbook's decision):** with the signups toggle
  ON but no custom SMTP, a STRANGER's signup cannot receive its
  confirmation email (her own addresses can, if they're org team
  members). The stranger-onboarding validation therefore needs ONE of:
  (a) the probe address added to the org's team for the window,
  (b) email confirmations toggled OFF (autoconfirm) for the window —
  signups then sign straight in, which is also a legitimate launch
  posture to rule on,
  (c) admin provisioning via `generate_link` (the standing uid-checked
  road — it bypasses signups-off AND the mailer, *source-verified*:
  neither `adminGenerateLink` nor `adminUserCreate` checks
  `DisableSignup`).
  The app-side face for arm-failure is already honest: the
  `email_address_not_authorized` refusal classifies into its own
  spoken line (batch 3's `signUpFailureMessage`).
- **The moment custom SMTP is enabled, delivery opens to all addresses**
  and the email rate limit resets to a **default 30 messages/hour**,
  adjustable on the Rate Limits page *(source-verified)*.

## 2. Provider choice (recommendation, hers to overrule at 14d)

Auth-only volume (confirmations, resets, email changes) at
TestFlight-and-early scale is tiny — tens of emails a day at most. All
four commonly-paired providers work; the DNS and ergonomic differences
matter more than price at this volume.

| Provider | Free tier (⚠ third-party-sourced — re-check the vendor page at 14d) | SMTP | DNS on stargazing.tech |
|---|---|---|---|
| **Resend** | 3,000/mo, 100/day | `smtp.resend.com` :587 (or 465); user literally `resend`, password = API key | **TXT-only** (SPF-style TXT + 1 DKIM TXT + 1 MX for bounce feedback) — no CNAME, so no Cloudflare proxy trap |
| **Postmark** | 100/mo free permanently | `smtp.postmarkapp.com` :587 (25/2525; **no 465**); user = pass = Server API Token | 1 DKIM TXT + 1 Return-Path **CNAME** (`pm.mtasv.net`) — CNAME must be DNS-only |
| **Amazon SES** | 3,000/mo for 12 months, then $0.10/1,000 | `email-smtp.<region>.amazonaws.com` :587/465 | SPF TXT include + **3 Easy-DKIM CNAMEs** — all must be DNS-only |
| **Brevo** | 300/day forever-free | `smtp-relay.brevo.com` :587 (465/2525); user = account email, password = a dedicated SMTP key | SPF TXT include + ~2 DKIM records |

**Recommendation: Resend**, on three grounds: (1) its records are all
TXT-shaped, which sidesteps the Cloudflare CNAME-proxy failure mode
entirely (see §4); (2) the free tier comfortably covers auth volume
through and past TestFlight; (3) SMTP setup is two fields (user
`resend`, password = API key). Postmark is the runner-up on
deliverability reputation if she prefers it — its 100/mo free tier still
covers pure auth volume. This is a recommendation with reasons, not a
decision; the processor-changeability answer applies here too (swapping
SMTP providers later is a ~30-minute re-run of this runbook — nothing
persists in the mirror).

## 3. The Supabase dashboard act (14d, step by step)

Dashboard home: **Authentication → Emails → SMTP Settings**
*(source-verified breadcrumb from the production checklist)*.

Fields to fill *(source-verified against the Management API's mirror of
the form)*:

| Field | Value |
|---|---|
| Sender email (`smtp_admin_email`) | `no-reply@stargazing.tech` (candidate — hers to name; must match the verified sending domain) |
| Sender name (`smtp_sender_name`) | e.g. `Stargazing` / `Variorum` — hers (the brand is provisionally stargazing) |
| Host (`smtp_host`) | per provider table above |
| Port (`smtp_port`) | **587** (STARTTLS — the industry-default choice; Supabase itself states no 587-vs-465 preference, *source-verified absence*) |
| Username (`smtp_user`) | per provider |
| Password (`smtp_pass`) | the provider API key / SMTP key |

There is **no** "minimum interval" field in the SMTP panel — pacing lives
on the Rate Limits page (§5) and in the built-in 60-second per-user
resend windows *(source-verified)*.

After saving: send a test (the cheapest real probe is a password-recovery
email to her own non-team address), then check the received headers show
`spf=pass` and `dkim=pass`.

## 4. DNS on Cloudflare (her hand — exact records handed over at 14d
## once the provider is chosen)

- **SPF:** ONE `TXT` record on the sending domain, merging the provider's
  include into any existing SPF value (e.g.
  `v=spf1 include:<provider-spf> ~all`). Never publish two SPF TXT
  records on one host — receivers treat that as a permanent SPF failure.
- **DKIM:** the provider's generated record(s), copied exactly.
  **THE CLOUDFLARE TRAP *(source-verified as standard guidance)*: any
  DKIM/Return-Path record that is CNAME-shaped (Postmark's Return-Path,
  SES's three Easy-DKIM CNAMEs) MUST be set to "DNS only" (grey cloud),
  never "Proxied" (orange cloud)** — a proxied CNAME answers with
  Cloudflare's edge instead of the provider's DKIM target and
  verification fails silently. TXT records (Resend/Brevo's shape) are
  never proxied, which is part of the Resend recommendation.
- **DMARC (recommended, not required):** one `TXT` at
  `_dmarc.stargazing.tech`, monitoring mode to start:
  `v=DMARC1; p=none; rua=mailto:<her-choice>@stargazing.tech` —
  universally-recommended deliverability/anti-spoofing hygiene once
  SPF+DKIM pass; tighten to `p=quarantine` later if wanted.
- ~~The auth-email links themselves point at the ISSUER
  (`auth.stargazing.tech` once the domain attaches — the Round-7
  ruling)~~ **SUPERSEDED at the 14c gate (2026-08-11; amendment dated
  2026-08-14): the custom domain was DECLINED — the issuer stays the
  raw project URL, and the links brand via the TEMPLATE road instead:
  `{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=…` +
  a `/auth/confirm` `verifyOtp` handler on stargazing.tech (the
  site agent builds it; the paste-ready brief lives in the 14d plan).**
  The SENDING domain records above are independent of the link
  hostname and can be done in the same Cloudflare sitting.

## 5. Rate/abuse limits (dashboard: Authentication → Rate Limits)

Current defaults *(source-verified from the rate-limits reference; the
buckets burst to 30 and refill at the configured rate; exceeding → 429)*:

| Limit | Default | Customizable | Recommendation (with reasons) |
|---|---|---|---|
| Emails sent (signup/recover/user) | 2/hr built-in; **30/hr once custom SMTP** | custom SMTP only | **Keep 30/hr through TestFlight.** Auth-only volume never approaches it, and a low cap is the abuse guard for the open signup door (each signup = one send). Raise only on observed 429s. |
| Per-user resend window (signup confirm, recover, OTP to same user) | 60 s | yes | **Keep 60 s** — the standing anti-hammer default; the app's own 429 arm speaks it. |
| OTP sends | 30/hr (the reference page; the older production checklist says 360/hr — a genuine docs discrepancy, flagged; read the dashboard's shown value at 14d) | yes | Not currently used (password sign-in; no magic links). Leave as-shipped. |
| Verification requests (`/verify`) | 360/hr per IP | **no** | Nothing to do; noted so nobody hunts for it. |
| Token refresh | 1800/hr per IP | **no** | Nothing to do — far above the apps' single-flight refresh cadence. |
| Anonymous sign-ins | 30/hr per IP | no | Unused (no anonymous auth). |
| MFA | 15/hr per IP | no | Unused today. |

Abuse posture beyond rate limits: the signups toggle stays the corpus
guard until the gate's ruled flip; after the flip, the entitlement gate
means a fresh stranger account can WRITE nothing to the mirror until a
plan activates (sync refuses at `VARIORUM_NO_ENTITLEMENT`) — so the
open door's server-side write surface is the auth tables plus one
`key_vault` row per account, which is the designed shape. CAPTCHA
(Supabase supports hCaptcha/Turnstile on auth endpoints) is the
escalation if signup abuse ever appears — recorded as the future knob,
not configured now.

> **⚠️ SUPERSEDED 2026-09-24 (signup auto-entitlement — her word at the
> 13y window's tail; the record rides 13t's row; caught stale by the
> act's Opus cold review, F-3):** a fresh signup is now ENTITLED ON
> ARRIVAL (`maintenance/beta-signup-auto-entitle.sql` — her ruled
> open-at-v1 posture's signup end, landed early for the friends beta),
> so the paragraph above's "can WRITE nothing" no longer holds. **The
> successor fence is 13y's minimal abuse guard** (500k-row lifetime
> pool · 50k/rolling-24h · 2,000/call, live at marker 9) plus the §5
> rate limits, required email confirmation, and the per-account
> kill-switch (`entitlement_set(...,false)`). The CAPTCHA knob above is
> unchanged and unconfigured — whether it arms BEFORE the beta is hers:
> QUESTIONS #145(a).

## 6. Auth email templates — DRAFT COPY FOR HER RATIFY
## *(SUPERSEDED 2026-08-16 at the 14d Step 0 act: she ratified a
## humanized revision — her own confirm-signup rewrite + plainer
## phrasing throughout — and it is PASTED LIVE; the deployed config is
## the copy's source of truth, recorded in the 14d plan's Step 0
## record. The drafts below stand as history.)*

Edited at **Authentication → Emails (Templates)**. Template variables
available *(source-verified)*: `{{ .ConfirmationURL }}`, `{{ .Token }}`,
`{{ .TokenHash }}`, `{{ .SiteURL }}`, `{{ .RedirectTo }}`, `{{ .Email }}`,
`{{ .NewEmail }}` (change-email only), `{{ .Data }}`.

**Template-form sequencing (added 2026-08-14, the 14d kickoff — the
gate's template-road ruling applied):** the drafts below use
`{{ .ConfirmationURL }}` (stock Supabase links). That is the CORRECT
form to paste at Step 0 — the branded form
(`{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=…`)
must NOT be pasted until stargazing.tech's `/auth/confirm` handler is
live and on the redirect allowlist, or every confirm/reset link
dead-ends at a 404. The flip to the branded form is a config-only act
once the site agent reports the deployed route (requirements at flip
time: Site URL set to the brand domain, handler routes allowlisted,
PKCE flow, autoconfirm OFF).

Drafting principles (the CF-10 spirit, applied): plain words, no
marketing voice, say what the email is and what clicking does, name the
suite once, and never imply the server can read writing. "Stargazing" is
the provisional brand — if she renames the brand, only the sender name
and the one brand mention change. The subject lines are part of the
draft. Emails not in use today (Magic Link, Invite, Reauthentication)
get no draft — their Supabase defaults stand until a feature uses them;
drafting copy for doors that don't exist would go stale unratified.

### 6a. Confirm signup

- **Subject:** `Confirm your email`
- **Body (draft):**

  > **Confirm your email**
  >
  > You (or someone using this address) created a Stargazing account —
  > one login for Variorum and Fragments.
  >
  > [Confirm email address]({{ .ConfirmationURL }})
  >
  > If you didn't create this account, you can ignore this email — the
  > account can't be used until the address is confirmed.

### 6b. Reset password

- **Subject:** `Reset your password`
- **Body (draft):**

  > **Reset your password**
  >
  > A password reset was requested for {{ .Email }}.
  >
  > [Choose a new password]({{ .ConfirmationURL }})
  >
  > If you didn't ask for this, ignore this email — your password is
  > unchanged.
  >
  > Note: this resets your account password (sign-in). It never touches
  > your encryption passphrase or your recovery phrase — those protect
  > your writing and only you hold them.

  *(The last paragraph is deliberate and load-bearing: the 14b secrets
  model means an account-password reset must never be mistaken for a
  crypto event — the two-vocabulary confusion is exactly the CF-10
  first-experience risk.)*

### 6c. Change email address

- **Subject:** `Confirm your new email address`
- **Body (draft):**

  > **Confirm your new email address**
  >
  > Your account asked to change its sign-in email to {{ .NewEmail }}.
  >
  > [Confirm the change]({{ .ConfirmationURL }})
  >
  > If you didn't ask for this, don't click — and consider changing your
  > password.

## 7. The 14d act, as a checklist (the whole ~30 minutes)

1. Choose/confirm the provider (§2) and create its account — hers,
   author-assist; verify the free-tier figures on the vendor's own page.
2. Verify the sending domain with the provider; add its DNS records in
   Cloudflare (§4 — CNAMEs grey-cloud), plus the DMARC record.
3. Wait for the provider's domain verification to pass.
4. Fill **Authentication → Emails → SMTP Settings** (§3); save.
5. Confirm the Rate Limits page shows the §5 values; adjust only if it
   doesn't.
6. Paste HER RATIFIED template copy (§6 — ratify happens before or at
   the 14d sitting).
7. Test: trigger a recovery email to a non-team address she controls
   *[removed for publication]*
   delivery + `spf=pass`/`dkim=pass` headers.
8. Record the act in the 14d plan (provider, sender, records added,
   limits confirmed).
