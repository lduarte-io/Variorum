# Privacy-policy brief for the stargazing.tech agent — the pre-13x update (RE-ISSUES the 13p brief)

**Dated 2026-09-06, authored inside pre-13x (Postures & recovery — Standard and Castle), batch 5b, item 4 — the
phase's ruled outbound deliverable (design §8: "the stargazing privacy-policy brief re-issued — two postures; the
plaintext export; the disclosure envelope SHRINKS").** This brief keeps the 13p brief's structure
(`notes/stargazing-privacy-policy-brief-13p.md`, 2026-08-30, which it SUPERSEDES where they differ) and states
FACTS the code keeps and nothing else; every fact names its section of `notes/plans/pre-13x-postures-design.md`
(the settled design). **Carried by the author to the site agent** — the Variorum repo's agents never work in the
stargazing repo. The policy is a LEGAL/TRUST document: factual and plain; the marketing claims live in launch
material, never in the policy. The plain words for users are copy §10's: *two postures; the plaintext export is the
one deliberate escape; the server holds ciphertext and sealed keys it cannot open; a signed-in session without the
encryption keys can neither read nor write the sync copy; the disclosure envelope: ids, dates, positions, kinds,
sizes, write cadence, and — new — nothing at all to a session that lacks the keys.*

## What changed since the 13p brief (the deltas, so the policy's editor knows what moved)

- **Two postures replace the 13p presets and the optional iCloud Keychain "dial."** Every library is in **Standard**
  (the default) or **Castle**; both are end-to-end encrypted; they differ only in WHO HOLDS A KEY (design §1.1–§1.3,
  §2). The 13p brief's "OPTIONAL iCloud Keychain copy (a user-visible dial…)" paragraph is superseded by the
  Standard/Castle paragraph below.
- **The journal bridge is retired** (2026-09-04, pre-13x batch 0b) — the 13p brief's DELTA note stands: no user
  writing crosses from Variorum to Fragments; the ONE Stargazing account line is unchanged (design §10).
- **A signed-in account without the encryption keys can neither read nor write the sync copy** — a new, stronger
  boundary than 13p's (the key proof, design §3.10). The disclosure envelope SHRINKS accordingly (below).
- **The Mac's biometric caution in the 13p brief is CLOSED** (the signing prerequisite landed 2026-08-30; Touch ID
  on the Mac works and is what Castle offers) — drop that caution.
- **Per-note locks remain deliberately unbuilt** (R13p-16) — that caution stands.

## The suite's privacy story, in three honest tiers (the 13p structure, re-stated)

**Tier 1 — end-to-end encrypted (the server cannot read it, ever):**
- Variorum's synced writing. Every text-bearing column is encrypted on the device before it leaves (AES-256-GCM,
  per-value nonce; Phase 14b); the server stores ciphertext and was live-dump-verified zero-plaintext. Unchanged by
  pre-13x in mechanism (design §1.2 — "the postures differ only in who holds a key").
- **In BOTH postures the server holds only WRAPPED copies of keys it cannot open** (design §3.1 — the account's key
  record: the master key wrapped under the passphrase, under the twelve words and — Standard only — under the
  Apple-held iCloud key; the corpus key wrapped under the master key). No raw key is ever on the server.
- Key custody is the user's, not ours. **Standard:** the user's Apple account (iCloud Keychain, and Apple's own
  account-recovery paths) holds ONE key that opens a wrapped copy — Apple's key, never ours; the operator never sees
  it (design §1.3, §3.1: "read by the app, never by us"). **Castle:** only the user — the passphrase, the twelve
  words and the user's enrolled devices; there is NO copy under the Apple key. **We cannot read your writing, and in
  Castle we cannot recover it for you if you lose your keys** — the policy should say both halves (design §1.21: the
  two floors, stated).
- The journal bridge's tier is HISTORY (retired 2026-09-04).

**Tier 2 — encrypted on your device:**
- The local library is encrypted at rest as one unit, on every device, for every user, in both postures — not
  optional, not per-note (13p, unchanged). Local backups the app makes are ciphertext too, and each backup carries its
  own NON-SECRET key file beside it (wrapped copies of the library key; holding it grants nothing — design §3.1,
  §6). A copy of the library file carries NO sync key and NO device identity (design §1.3, §3.3).
- **Exactly TWO deliberate plaintext escapes exist, both user-initiated, never scheduled by default:** the
  Markdown export (13l; the scheduled weekly plain-text insurance is OFF by default and is turned OFF with a notice
  when a user enters Castle — design §1.6) and, new at pre-13x, the **decrypted `.sqlite` export** (design §1.15,
  §5): re-authenticated, warned in plain words, to a user-chosen destination, never into the app's own backup folders,
  never scheduled; it carries the writing and none of the local sync bookkeeping. The policy can say: "the app never
  writes an unencrypted copy of your library on its own."
- The honest boundary, stated plainly (unchanged): encryption at rest protects the FILES — a stolen laptop, a copied
  backup. It does not protect an app that is open and unlocked in front of someone; Castle's gate (Touch ID / Face ID
  with the passphrase as fallback, or the passphrase every time; re-lock on sleep, screen lock and time away) exists
  for that (design §1.18–§1.19; keystone 4: "While Variorum is open and unlocked, everything in it is readable").
- Castle, in one policy sentence (design §8's marketing line, true of the build): the file itself is ciphertext,
  and in Castle the key that opens it is not on the Mac in any form the login password can release.

**Tier 3 — server-readable by design, and why:** Fragments' non-journal content, as the 13p brief states — its own
project, its own policy paragraph; nothing of Variorum's is in this tier. (The bridge boundary sentence is history.)

## Operator-visible metadata (disclose, in plain words) — THE ENVELOPE AS AMENDED

Even for Tier 1 content, the service necessarily sees:
- **Account identity** (email), **entitlement/subscription state** (14c).
- **Content-free write metadata:** row counts, sizes, timing, write cadence; ids, dates, positions, kinds (14b's
  disclosure list, unchanged).
- **The shared change-sequence's aggregate activity timing** across accounts (14c's I-1 — accepted and recorded;
  scheduled to narrow at Phase 13y pre-release).
- **Per-device sync-cursor timestamps** (`device_cursor.seen_at` — 13j's purge design): when each device of an
  account last synced. Pre-13x precision: a device identity is minted per library on a machine; a copy of a library
  opened on another machine gets a FRESH identity (design §1.13), so the operator sees "a device joined," never which
  file it came from.
- **NEW at pre-13x — the posture is visible to the operator:** the account's key record either carries an Apple-held
  wrapped copy (Standard) or does not (Castle). The operator can tell WHICH posture an account is in, never open
  either copy (design §3.1, §3.10).
- **NEW — the key record's non-secret bookkeeping:** a hash of the key proof (the server keeps `SHA-256` of a value
  only key-holders can compute; it authorizes writes and reads nothing — design §3.10); a rotation marker while a key
  replacement is in progress (which rows are under the previous key is told by a server sequence number — design
  §1.31); and **the NAME of the device that last changed the account's keys** (`updated_by_device` — SELF-REPORTED by
  the client, so it is what an honest client says, design §1.34 / ledger 49), beside the day. So the operator can
  see: that a passphrase change, a words regeneration, a key replacement or a posture change happened, on which named
  device, on which day — never the secret, never the keys.
- **What the operator NO LONGER sees (the envelope shrinks):** a session that lacks the encryption keys gets NOTHING
  from the sync copy — not the structure, not a sequence number, not the purge ledger (design §3.10: every mutating
  RPC and the read RPCs take the key proof; a bare session can fetch the account's wrapped key copies and delete the
  whole account, and nothing else). 14b's "a bare session reads the structure" is history.
- No content, no titles, no words — unchanged.

## What the account password can and cannot do (say it in the policy — the user's own keystone line)

*Your account password signs you in and can delete your account. It never touches your keys.* (keystone 3, rendered
in-app). Its powers, exactly (design §5): **sign in** (a session); **sign out everywhere** (revoke every session);
**delete the account** (the server copy, the account's key record and the login — every local copy survives, and the
user can set sync up again under a new account); and, on an account that has NEVER turned on sync, **create the
account's key record before the owner does** — loud and survivable (the owner's passphrase never opens it; the Turn
On Sync door says so; the remedy is deleting the account). It can NEVER open a library, read or write the sync copy,
purge, change a passphrase, change a posture, or export. A stolen or cloned session is inert against the corpus.
(Server-side: the account-password minimum is 12 characters and leaked-password protection is on — design §1.25,
ledger 45, executed 2026-09-06.)

## Standing postures the policy keeps saying out loud (unchanged from 13p)

- **No analytics** — the app phones home for nothing; stated explicitly.
- **Export is always free** — local-first; a lapsed subscription pauses sync and nothing else; your data is never
  held hostage. (Pre-13x adds the second deliberate export — the decrypted `.sqlite` — under the same rule.)
- Crash reporting, when it ships (13r), will be opt-in.

## Cautions for the drafting agent

- Do not describe per-note locks — deliberately NOT built (R13p-16).
- Do not describe a "reset" or an operator recovery road: in Castle nobody holds a key but the user; in Standard the
  user's Apple account is the recovery, through Apple's paths — never ours (design §1.4, §1.21; the FAQ's *Why is
  there no "reset"?*).
- Do not say the Standard posture keeps the writing "in iCloud": Apple holds a KEY to a wrapped copy, never the copy
  and never the writing (design §1.28's second law); Standard sync users' writing still reaches Apple's servers only
  as the same ciphertext every device pushes.
- Do not describe a remaining-rows count for a key replacement in progress — the app names the device and the day
  only (ledger 65).
- The site's FAQ is briefed separately (`notes/stargazing-help-faq-brief-pre13x.md`); the policy states boundaries,
  the FAQ explains mechanisms. Fragments' half of the story remains the Fragments agent's to confirm.
- The final policy text lands after pre-13x closes (the acceptance walk may still adjust in-app wording; the FACTS
  above are the design's and do not move); this brief is the content authority until then.
