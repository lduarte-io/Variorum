# Privacy-policy brief for the stargazing.tech agent — the 13p update

> **DELTA 2026-09-04 — THE JOURNAL BRIDGE IS RETIRED.** Variorum removed its half of the
> Fragments journal bridge from `main` on 2026-09-04 (pre-13x batch 0b, the author's ruling;
> archived at tag `archive/fragments-bridge-2026-09-04`). For the policy: **Variorum's disclosure
> DROPS the journal-bridge tier** — no user writing crosses from Variorum to Fragments any
> more, so Tier 1's "journal bridge" bullet and Tier 3's "the journal class from Variorum's
> bridge" boundary sentence below are HISTORY; **the ONE Stargazing account line is UNCHANGED**
> (this retires the bridge, not the account); the "sanity-check against the Fragments agent's
> read" ask below is moot for the bridge's sake. Everything else in this brief stands. **She
> carries the amended brief to the stargazing.tech agent.**

**Dated 2026-08-30, authored inside Phase 13p (whole-store encryption) as
one of its two ruled outbound deliverables** (the author's instruction,
2026-08-25: *"the phase for encryption needs to both write a brief for the
fragments agent and update the brief for the stargazing.tech agent's
privacy policy"*). The RUNNING ORDER's row 1 says the policy's FINAL text
follows this brief. **Carried by the author to the site agent** — the
Variorum repo's agents never work in the stargazing repo. The policy is a
LEGAL/TRUST document: keep it factual and plain; the marketing claims
(who else doesn't encrypt) live in launch material, never in the policy.

## The suite's privacy story, in three honest tiers

**Tier 1 — end-to-end encrypted (the server cannot read it, ever):**
- Variorum's synced writing corpus. Every text-bearing column seals
  client-side before it travels (AES-256-GCM; Phase 14b); the server
  stores ciphertext and was twice live-dump-verified zero-plaintext.
- The journal bridge between Variorum and Fragments (the journal class),
  sealed on both ends since 14d.
- Key custody is the user's, not ours: one encryption passphrase and one
  12-word recovery phrase. **We cannot read your writing, and we cannot
  recover it for you if you lose your keys** — the policy should say both
  halves, because the second is the honest price of the first.

**Tier 2 — encrypted on your device (new at 13p):**
- Variorum's local store is encrypted at rest as one unit, on every
  device, for every user — not optional, not per-note. Local backups the
  app makes are ciphertext too.
- Exactly ONE deliberate plaintext escape exists: the Markdown export,
  OFF by default, opt-in (worded in-app with a warning under the
  hardened preset).
- The store key never leaves the user's devices except as their chosen
  recovery legs: the passphrase wrap, the recovery-phrase wrap, and an
  OPTIONAL iCloud Keychain copy (a user-visible dial, on by default in
  the Standard preset, off in Locked-down; the in-app copy states the
  trust each way — the policy can reference that mechanism in one
  sentence).
- The honest boundary, stated plainly (the author's honesty doctrine —
  and her marketing depends on the policy never overclaiming): encryption
  at rest protects the files — a stolen laptop, a copied backup. It does
  not protect an app that is open and unlocked in front of someone; the
  at-open lock modes (biometric/passphrase) exist for that, as access
  control.

**Tier 3 — server-readable by design, and why:**
- Fragments' non-journal content is readable by the service BY DESIGN:
  its insights features are computed from it — that is the product. The
  policy states this plainly and states the boundary (the journal class
  from Variorum's bridge is NOT in this tier — it is Tier 1).

## Operator-visible metadata (disclose, in plain words)

Even for Tier 1 content, the service necessarily sees: account identity
(email), entitlement/subscription state, and content-free write metadata
— row counts, sizes, timing (including the shared change-sequence's
aggregate activity timing, an accepted disclosure recorded at 14c and
scheduled to narrow at Phase 13y pre-release, and per-device sync-cursor
timestamps from the purge design). No content, no titles, no words.

## Standing postures the policy keeps saying out loud

- **No analytics** — the app phones home for nothing; stated explicitly
  (the standing "the absence is a trust asset only if stated" ruling).
- **Export is always free** — local-first; a lapsed subscription pauses
  sync and nothing else; your data is never held hostage.
- Crash reporting, when it ships (13r), will be opt-in — the policy can
  pre-state the posture or wait for 13r; the author's call.

## Cautions for the drafting agent

- Do not describe per-note locks — they were deliberately NOT built
  (curtain-not-boundary; the author's R13p-16 ruling).
- Do not overclaim biometric unlock on the Mac in any near-term copy — a
  signing prerequisite is pending on that platform (the app refuses
  honestly meanwhile); iOS is unaffected. Feature copy, not policy copy,
  but worth knowing.
- Fragments' half of the story should be sanity-checked against the
  Fragments agent's read (the 13p carry-item in
  `notes/fragments-bridge-contract.md` invites corrections through that
  channel before the policy finalizes).
- The final policy text lands AFTER 13p closes (its acceptance may still
  adjust wording details); this brief is the content authority until
  then.
