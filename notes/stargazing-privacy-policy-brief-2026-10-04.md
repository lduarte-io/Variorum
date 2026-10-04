# Privacy-policy brief for the stargazing.tech agent — the 2026-10-04 edition (RE-ISSUES the pre-13x brief)

**Dated 2026-10-04, authored at the author's direct ask (launch-content round), outside any phase.** It RE-ISSUES
`notes/stargazing-privacy-policy-brief-pre13x.md` (2026-09-06) and supersedes it where they differ; that brief's
structure (which came from the 13p brief) is kept, and this edition is SELF-CONTAINED — the site agent needs no
earlier brief. Facts here are what the code and the deployed mirror keep as of schema marker 12 (13i-e, deployed
2026-10-03); the deltas since pre-13x cite SyncSpec §12's lockstep record (events 13y, 13i-a, 13i-c, 13i-e).
**Carried by the author to the site agent** — the Variorum repo's agents never work in the stargazing repo. The
policy is a LEGAL/TRUST document: factual and plain; marketing claims live in launch material, never in the policy.

The plain words for users, as amended: *two postures; the plaintext export is the one deliberate escape; the server
holds ciphertext and sealed keys it cannot open; a signed-in session without the encryption keys can neither read
nor write the sync copy; your sync activity is visible only to your own account, not inferable by other customers;
the disclosure envelope: ids, dates, positions, kinds, sizes, write cadence — and nothing at all to a session that
lacks the keys.*

## What changed since the pre-13x brief (the deltas, so the policy's editor knows what moved)

- **The cross-account activity disclosure is CLOSED (13y, 2026-09-24).** The pre-13x envelope carried: "the shared
  change-sequence's aggregate activity timing across accounts… scheduled to narrow at Phase 13y." 13y executed it:
  the change sequence is now per-account, and **one account's sync feed reveals only its own writes** — another
  customer can no longer infer aggregate write volume or timing. The policy may now state the stronger line and
  must DROP the old disclosure.
- **The key proof became a challenge protocol (13y).** Pre-13x said the server keeps a hash of a value key-holders
  can compute. Now: write/read authorization runs on per-request, single-use challenges over a **per-account
  integrity secret the server keeps in its managed vault**. Plain words for the policy: *the server keeps a
  per-account secret that lets it verify a device holds your encryption keys; it authorizes writes and can decrypt
  nothing.* Honest footnote for the drafting agent (not necessarily policy text): a server-side actor holding that
  secret could authorize writes — power the operator of a server inherently has anyway — and gains zero read
  power; the net-new disclosure was assessed ≈ none and recorded.
- **Abuse-guard counters exist (13y):** the server tracks per-account push volume (lifetime and daily budgets).
  Content-free; covered by the envelope's "row counts, sizes, write cadence" line — listed here so the enumeration
  is complete. Normal use never meets the guard.
- **New organizational structure syncs (13i-a/c/e, 2026-10-01/02/03) — unchanged in KIND:** wings (in-store
  libraries), shelves, and new book states (starred, owned, finished/sealed, archived, intake settings, a count of
  outflow tags). The structural skeleton (ids, flags, positions, timestamps) travels plain like all structure;
  **the user-named text — wing names, shelf names, the shelf glyph — travels encrypted** like all text. The
  operator can see that an account's books/wings/shelves exist, their counts, flags and arrangement — never any
  name or word. The policy's existing "ids, dates, positions, kinds" line already covers this; no new policy
  sentence is required.
- **A historical note, likely NOT policy material:** accounts that existed before 2026-09-24 had a bounded
  enrollment window during that day's upgrade in which previously-captured static credentials retained write (not
  read) power until the account's first sync round; the author's own account closed its window within minutes of
  the deploy, and accounts created after 2026-09-24 never have one. Recorded so the drafting agent knows the full
  story; new-user policy text is unaffected.
- Everything else in the pre-13x brief STANDS and is restated in full below.

## The suite's privacy story, in three honest tiers

**Tier 1 — end-to-end encrypted (the server cannot read it, ever):**
- Variorum's synced writing. Every text-bearing column is encrypted on the device before it leaves (AES-256-GCM,
  per-value nonce; Phase 14b — the sealed set has only GROWN since, most recently with wing/shelf names); the
  server stores ciphertext and was live-dump-verified zero-plaintext.
- **In BOTH postures the server holds only WRAPPED copies of keys it cannot open:** the master key wrapped under
  the passphrase, under the twelve recovery words and — Standard only — under the Apple-held iCloud key; the
  corpus key wrapped under the master key. No raw key is ever on the server.
- Key custody is the user's, not ours. **Standard** (the default): the user's Apple account (iCloud Keychain, and
  Apple's own account-recovery paths) holds ONE key that opens a wrapped copy — Apple's key, never ours; the
  operator never sees it. **Castle:** only the user — the passphrase, the twelve words and the user's enrolled
  devices; there is NO copy under the Apple key. **We cannot read your writing, and in Castle we cannot recover it
  for you if you lose your keys** — the policy says both halves.
- The journal bridge's tier is HISTORY (retired 2026-09-04; no user writing crosses from Variorum to Fragments).

**Tier 2 — encrypted on your device:**
- The local library is encrypted at rest as one unit, on every device, for every user, in both postures — not
  optional, not per-note. Local backups the app makes are ciphertext too, and each backup carries its own
  NON-SECRET key file beside it (wrapped copies of the library key; holding it grants nothing). A copy of the
  library file carries NO sync key and NO device identity.
- **Exactly TWO deliberate plaintext escapes exist, both user-initiated, never scheduled by default:** the
  Markdown export (the scheduled weekly plain-text insurance is OFF by default and is turned OFF with a notice
  when a user enters Castle) and the **decrypted `.sqlite` export** (re-authenticated, warned in plain words, to a
  user-chosen destination, never into the app's own backup folders, never scheduled; it carries the writing and
  none of the sync bookkeeping). The policy can say: "the app never writes an unencrypted copy of your library on
  its own."
- The honest boundary, stated plainly: encryption at rest protects the FILES — a stolen laptop, a copied backup.
  It does not protect an app that is open and unlocked in front of someone; Castle's gate (Touch ID / Face ID with
  the passphrase as fallback, or the passphrase every time; re-lock on sleep, screen lock and time away) exists
  for that. While Variorum is open and unlocked, everything in it is readable.
- Castle, in one policy sentence (true of the build): the file itself is ciphertext, and in Castle the key that
  opens it is not on the Mac in any form the login password can release.

**Tier 3 — server-readable by design, and why:** Fragments' non-journal content — its own project, its own policy
paragraph; nothing of Variorum's is in this tier. (The bridge boundary sentence is history.)

## Operator-visible metadata (disclose, in plain words) — THE ENVELOPE AS AMENDED 2026-10-04

Even for Tier 1 content, the service necessarily sees:
- **Account identity** (email), **entitlement/subscription state**.
- **Content-free write metadata:** row counts, sizes, timing, write cadence; ids, dates, positions, kinds — now
  including content-free organizational structure (how many books/wings/shelves, flags like starred or finished,
  arrangement), with every NAME in that structure encrypted. Also the abuse-guard push-volume counters.
- **Per-device sync-cursor timestamps:** when each device of an account last synced. A device identity is minted
  per library on a machine; a copy of a library opened on another machine gets a FRESH identity — so the operator
  sees "a device joined," never which file it came from.
- **The posture is visible:** the account's key record either carries an Apple-held wrapped copy (Standard) or
  does not (Castle). The operator can tell WHICH posture an account is in, never open either copy.
- **The key record's non-secret bookkeeping:** the per-account integrity secret described above (verifies
  key-holding, decrypts nothing); a rotation marker while a key replacement is in progress; and the NAME of the
  device that last changed the account's keys (self-reported by the client), beside the day. So the operator can
  see THAT a passphrase change, a words regeneration, a key replacement or a posture change happened, on which
  named device, on which day — never the secret, never the keys.
- **What the operator does NOT see — say both of these:** **(1)** a session that lacks the encryption keys gets
  NOTHING from the sync copy — not the structure, not a sequence number; it can fetch the account's wrapped key
  copies and delete the whole account, nothing else. **(2 — NEW, the 13y closure):** an account's sync activity
  is visible only within that account — other customers cannot observe or infer it.
- No content, no titles, no words — unchanged, ever.

## What the account password can and cannot do (the user's own keystone line — render it in the policy)

*Your account password signs you in and can delete your account. It never touches your keys.* Its powers,
exactly: **sign in** (a session); **sign out everywhere** (revoke every session); **delete the account** (the
server copy, the account's key record and the login — every local copy survives, and the user can set sync up
again under a new account); and, on an account that has NEVER turned on sync, **create the account's key record
before the owner does** — loud and survivable (the owner's passphrase never opens it; the Turn On Sync door says
so; the remedy is deleting the account). It can NEVER open a library, read or write the sync copy, purge, change
a passphrase, change a posture, or export. A stolen or cloned session is inert against the corpus. (Server-side:
the account-password minimum is 12 characters and leaked-password protection is on.)

## Standing postures the policy keeps saying out loud

- **No analytics** — the app phones home for nothing; stated explicitly.
- **Export is always free** — local-first; a lapsed subscription pauses sync and nothing else; your data is never
  held hostage. (Both deliberate exports — Markdown and the decrypted `.sqlite` — fall under this rule.)
- Crash reporting, when it ships (13r), will be opt-in.

## Cautions for the drafting agent

- Do not describe per-note locks — deliberately NOT built (R13p-16); the store itself is the protection.
- Do not describe a "reset" or an operator recovery road: in Castle nobody holds a key but the user; in Standard
  the user's Apple account is the recovery, through Apple's paths — never ours.
- Do not say the Standard posture keeps the writing "in iCloud": Apple holds a KEY to a wrapped copy, never the
  copy and never the writing; Standard users' writing reaches any server only as the same ciphertext every device
  pushes.
- Do not describe a remaining-rows count for a key replacement in progress — the app names the device and the day
  only.
- Do not carry the old cross-account aggregate-activity disclosure forward — it is closed (13y); the policy now
  states the per-account line instead.
- The site's FAQ is briefed separately — the CURRENT edition is
  `notes/stargazing-help-faq-brief-2026-10-04.md` (same date as this brief; they agree by construction). The
  policy states boundaries; the FAQ explains mechanisms. Fragments' half of the story remains the Fragments
  agent's to confirm.
- Launch timing: 13o (search — fully client-side, changes nothing in this brief), 13r (distribution; the crash-
  reporting line lands then), 13x and 13s remain before release. None is expected to move these facts; if a future
  schema event amends the envelope, a re-issue of this brief will say so explicitly.
