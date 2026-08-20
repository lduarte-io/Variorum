# Stargazing.tech — Variorum website brief (App Store readiness)

**Written 2026-08-20 by the Variorum-repo session, for the stargazing.tech
site agent.** This document is SELF-CONTAINED — the site agent needs no
Variorum-repo access (and stays hands-off that repo as always). Goal: the
pages needed so the author can **submit Variorum for iPhone to the App
Store tomorrow**, plus a stand-in product page.

Every fact below was verified against Variorum's canonical records (the
E2EE disclosure list from the Phase 14b gate record; the 14c account
machinery; the 14d email/signup state). Items marked **[HER CALL]** need
the author's answer before publishing — everything else is ready copy.

The site already hosts the suite's auth pages (sign-in/consent, the
`/auth/confirm` verifyOtp handler from the branded-email work) — the new
pages join that nav; nothing existing is rebuilt.

---

## 1. What the App Store needs tomorrow (the hard requirements)

App Store Connect requires, per app:

1. **Privacy Policy URL** (required, public before review) → `stargazing.tech/variorum/privacy`
2. **Support URL** (required) → `stargazing.tech/variorum/support`
3. **Marketing URL** (optional but wanted) → `stargazing.tech/variorum`

Those three URLs live means she can submit. Terms of Service are NOT
required tomorrow (Apple's standard EULA applies by default; a custom ToS
arrives with the paid sync tier — a later phase owns it).

## 2. URL map

| URL | Page | Status |
|---|---|---|
| `/variorum` | Product page (STAND-IN copy — she rewrites in her voice later) | draft below |
| `/variorum/privacy` | Privacy policy | draft below |
| `/variorum/support` | Support & FAQ | draft below |
| `/variorum/terms` | NOT NOW — placeholder decision recorded; arrives with the paid tier | skip |

## 3. Facts sheet (what the pages may claim — verified)

- **Variorum** is a native writing app for Mac and iPhone: journaling,
  notes, blog drafts, books. Its signature idea: a piece of text (a
  "block") can hold **several takes side by side** — alternate versions
  kept open next to each other instead of overwritten — plus permanent
  savepoints. Nothing is ever destroyed by editing.
- **Local-first.** All writing lives in a local database on the device.
  The app is fully functional with no account and no network, forever.
- **Account (optional)** — one "Stargazing" account across the author's
  apps (Variorum and Fragments). Email + password. Used only for sync.
- **Sync is end-to-end encrypted, mandatorily, from birth.** Content is
  encrypted ON DEVICE before upload (AES-256-GCM). Keys derive from a
  separate **encryption passphrase** via Argon2id — the passphrase never
  leaves the user's devices — with a 12-word recovery phrase as backup.
  **The server cannot read anyone's writing.** If a user loses both the
  passphrase and recovery phrase, the server copy is unrecoverable BY
  DESIGN (their local copy remains readable on enrolled devices).
- **Exactly what the server CAN see** (the ratified disclosure list —
  quote it faithfully, never wider or narrower): which days carry journal
  entries · timestamps · ordering keys · type/status flags · the
  structural graph (random identifiers and their relationships) · payload
  sizes and write cadence · settings flags · canvas positions. **Every
  user-authored word is ciphertext — including note titles, take labels,
  tag names, and book names.**
- **No analytics. No tracking. No ads. No crash reporting** (if crash
  reporting is ever added it will be opt-in, and the policy updates).
- **Processors:** Supabase (database/auth/hosting infrastructure); an
  email delivery provider (transactional auth emails only — sign-in
  confirmations, recovery). No data is sold or shared for advertising.
- **Account deletion is in-app** and removes the user's server-side data.
- **Export is always free**: markdown and PDF, whole-library export in
  one gesture. Local data is always the user's.
- **Fragments bridge:** journal entries can flow between Variorum and
  Fragments under the one account; journal content is end-to-end
  encrypted on both ends.
- **Sync pricing:** currently free; a paid plan will eventually cover
  hosting costs. The ratified framing (use it verbatim wherever pricing
  comes up): *"If you don't subscribe, nothing is lost or held hostage —
  sync pauses, the app keeps working fully, and export is always free."*

## 4. Page draft — `/variorum` (product page; STAND-IN)

> Mark internally as stand-in: the author will rewrite this in her own
> voice. Keep the layout ready for her copy swap.

**Variorum**
*The writing app that keeps your choices open.*

A **variorum** is an edition of a text that preserves its variant
readings. That's this app.

In every other writing app, editing means destroying — the sentence you
rewrote is gone. Variorum is built the other way: any paragraph can hold
**several takes, side by side**, kept open as long as you want. Try a
bolder opening next to the safe one. Keep the honest version of a journal
entry beside the kind one. Deliberately save the versions that matter.
Nothing you write is ever lost to editing.

Around that one idea, a full writing home:

- **Journals** — daily entries, on your Mac and your iPhone, in sync.
- **Notes and drafts** — with takes, savepoints, side-by-side compare,
  and a lineage of how every piece came to be.
- **Books** — collect entries and chapters into curated or
  self-collecting books, reorder freely, watch them fill.
- **Fast, always** — built so that a decade of writing scrolls and types
  like an empty page. No lag at ten thousand words. Ever.
- **Yours, always** — everything lives on your device. Optional sync is
  end-to-end encrypted: your words are unreadable to everyone but you,
  including us. Export everything, any time, free.

**Variorum for Mac** — download from this page. *(Direct download;
notarized. Not on the Mac App Store.)*
**Variorum for iPhone** — on the App Store.

*(Footer links: Privacy · Support)*

## 5. Page draft — `/variorum/privacy` (Privacy Policy)

> Publish as written, filling the two [HER CALL] blanks. Plain page,
> dated. This is deliberately short because the true story is short.

**Variorum Privacy Policy**
*Effective: [HER CALL — date of publish]*

**The short version:** your writing lives on your device. If you turn on
sync, it's encrypted on your device before it ever leaves, and we cannot
read it. We run no analytics, no ads, and no trackers — in the app or on
this site.

**What lives on your device.** Everything you write in Variorum is
stored in a local database on your Mac or iPhone. Without an account,
nothing leaves your device, and the app is fully functional offline,
forever.

**Your account (optional).** To sync between devices you create a
Stargazing account with an email address and password. We use your email
only to operate the account (sign-in, confirmation, and recovery emails).
One account works across our apps (Variorum and Fragments).

**Sync and end-to-end encryption.** Sync is always end-to-end encrypted.
Your writing — including note titles, take labels, tag names, and book
names — is encrypted on your device (AES-256-GCM) with keys derived from
your encryption passphrase, which never leaves your devices. A 12-word
recovery phrase is your backup. **We cannot read your writing, and we
cannot recover it for you if you lose both your passphrase and recovery
phrase** — that is the design, not a limitation we apologize for. What
our server necessarily stores alongside the encrypted content is
structural metadata: which days carry journal entries, timestamps,
ordering, type flags, anonymous identifiers and their relationships,
payload sizes, and settings flags. Never your words.

**What we don't do.** No analytics. No tracking. No advertising. No
sale or sharing of data. No crash reports are collected today; if we add
crash reporting it will be strictly opt-in and this policy will say so.

**Service providers.** Our sync infrastructure and account system run on
Supabase (database, authentication, hosting). Transactional emails
(sign-in and recovery only) are delivered by our email provider. These
providers process data only to run the service.

**Your rights and controls.** Export your entire library any time, free
(Markdown and PDF), from inside the app. Delete your account from inside
the app — this removes your data from our servers. Your local copy is
always yours.

**Children.** Variorum is not directed at children under 13.

**Changes.** Updates to this policy are posted on this page with a new
effective date.

**Contact.** [HER CALL — support email address], or the support page.

## 6. Page draft — `/variorum/support`

**Variorum Support**

Questions, problems, ideas — email **[HER CALL — support email]**. A
human (the person who makes the app) reads everything.

**Common questions**

- **Where is my writing stored?** On your device, in a local database.
  With sync on, an end-to-end-encrypted copy lives on our servers — we
  cannot read it.
- **How do I get my writing out?** File ▸ Export, any time: Markdown or
  PDF, a single note or the whole library. Free forever.
- **I forgot my encryption passphrase.** Use your 12-word recovery
  phrase (Settings ▸ Encryption). If both are lost, the server copy
  cannot be recovered by anyone — including us; your writing remains
  readable on devices already signed in, so export from one of them.
- **How do I delete my account?** In the app: Settings ▸ Account ▸
  Delete Account. This removes your data from our servers.
- **Does sync cost money?** It's free right now. A paid plan will
  eventually cover hosting costs — and if you don't subscribe, nothing
  is lost or held hostage: sync pauses, the app keeps working fully, and
  export is always free.

## 7. App Store Connect crib sheet (for HER, tomorrow — not a website item)

- **URLs:** Privacy Policy `https://stargazing.tech/variorum/privacy` ·
  Support `https://stargazing.tech/variorum/support` · Marketing
  `https://stargazing.tech/variorum`.
- **Privacy nutrition labels** (suggested answers — verify in the form's
  own wording): Data collected, linked to identity: **Contact Info →
  Email Address** (app functionality/account) · **User Content → Other
  User Content** (notes; end-to-end encrypted; app functionality) ·
  **Identifiers → User ID** (account). Data used to track you: **none**.
  Third-party advertising: **none**. Analytics: **none**.
- **Export compliance:** the app uses encryption (HTTPS + end-to-end
  content encryption). Answer YES to "uses encryption"; standard/
  mass-market crypto normally qualifies for exemption — answer the
  exemption questions accordingly and note the possible **annual
  self-classification report**; verify the current form's wording at
  submission.
- **Account deletion rule 5.1.1(v):** satisfied — deletion is in-app.
- **Listing draft:** Name **Variorum** · Subtitle (≤30 chars) —
  candidates: *"Journals, notes & every take"* / *"Writing that keeps
  every version"* (trim to fit) · Category **Productivity** · Age **4+** ·
  Keywords: `writing, journal, notes, drafts, versions, takes, diary,
  book, markdown, sync` · Description: open with the product page's first
  three paragraphs (§4), then the bullet list, then the privacy line ("End-to-end
  encrypted sync — your words are unreadable to everyone but you,
  including us"). Screenshots are hers to capture on-device.

## 8. [HER CALL] summary — the blanks to fill

1. **Support email address** (a `variorum@` or `support@` on the
  stargazing.tech domain beats a personal address — her pick).
2. **Privacy policy effective date** (publish date).
3. Whether the sync-pricing sentence appears on the product page now or
  only in support (drafted in both; trivially removable).
4. Subtitle pick for the App Store listing.

## 9. Provenance (for the Variorum side; the site agent can ignore)

Encrypted-vs-plain wording verified against the Phase 14b gate record's
ratified disclosure list (the eighteen sealed columns; the server-visible
set quoted faithfully). Account deletion: 14c's verified door. Signups
open + SMTP + branded links: 14d's close. No-analytics/no-crash-reporting:
current factual state (opt-in crash reporting is a future phase, 13r).
Pricing framing: the author's ratified 13t wording, 2026-08-20.
