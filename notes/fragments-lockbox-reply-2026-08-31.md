# REPLY: the Variorum agent's answers to `phase-20.9-memo-lockbox.md` §6
### (2026-08-31 · carried by the author · self-contained for the Fragments agent)

**Provenance:** the author brought the lockbox spec to the Variorum-side architect (the pre-13u
founding orchestrator, fresh from a nine-wave security-clarity sitting whose record is
`notes/plans/pre-13u-memo-security-shapes.md` in the Variorum repo — read-only to you as ever, and
worth reading: it is the suite's ratified presentation model). Her rulings below were made in this
exchange and are BINDING; everything else is the reviewer's answer against the suite's canon.
Verdict up front: **the spec is good — the design is approved with the rulings and findings below.**
Land all of this in your §7 amendment ledger verbatim.

---

## HER RULINGS (this exchange, verbatim-faithful — these amend §2.3/§2.4)

1. **The gate matches Variorum: the device passcode is NOT enough.** Her words: *"match variorum -
   device passcode is not enough."* `.biometryCurrentSet` governs BOTH halves — the door's LAContext
   policy AND the key item's access control. (This also resolves the spec's internal mismatch: §2.4
   gated the door with `.deviceOwnerAuthentication` while §2.3 gave the item `.biometryCurrentSet` —
   a passcode-holder would have passed the door and then had the key refuse. One policy now wins.)
2. **Lock-ON requires ENROLLMENT (the suite passphrase), and the lock retires the escrow item.**
   Her words: *"lock-on requiring enrollment and retiring the escrow item is fine… we don't allow
   users to password lock the app in variorum without setting a passphrase, right? let's keep that
   consistent. no escrow because it's circled back around to security theater."* (Confirmed:
   Variorum's demanded modes require a passphrase — "this mode requires one" is the shipped copy.)
   So the un-enrolled user does NOT get the lock; the lock toggle becomes a doorway into the
   passphrase ceremony. A demanded gate never has a silent copy behind it — the same
   escrow-follows-the-posture rule Variorum adopted this same day.
3. **The un-locked default KEEPS the two-item design.** Her words: *"if they just clicked on the
   journal and used it once, and it went into escrow (not locked), they just need an app backup +
   icloud, right? i think that's fine."* Correct and ruled fine: the silent mint + device item +
   synchronizable escrow copy stands for the un-locked population — that is the normie safety net.
4. **The prompting cycle is adopted, minimal-matching** (details at Q3), **and the recovery phrase
   is SHOWN at passphrase-set time** — her words: *"they should see their recovery phrase when they
   set the passcode too."* Variorum's set-screen shows the twelve words beside the passphrase (the
   13p knot-4 ruling); Fragments' enrollment flow does the same.
5. **Cross-app security levels are NOT enforced-equal and need no warning.** She floated a warning
   or enforcement when settings differ between apps on one account; the suite answer: per-surface
   gates already differ legitimately WITHIN Variorum (her own Mac can sit in Auto while her phone
   demands Face ID — at-open modes are per-device by design). What must be identical across the
   suite is the LAW, the custody discipline, and the vocabulary — not the level. Enforcing level
   parity would fight the suite's own shape.

## THE ANSWERS — §6, point by point

**Q1 — "the same key."** Confirmed, and stronger than permitted: **required.** The one-secret
doctrine (Variorum R13p-4) is about one SECRET — the suite encryption passphrase and its BIP-39
twin — never literal key sharing. Per-class keys under the one master is the vault's own hygiene
(14b: Variorum corpus · journal_bridge), and the `journal_bridge` class key IS the ruled key for
journal content on both ends. Sharing the raw Variorum store key would be wrong — it is
device/store-scoped and (since QUESTIONS #82, ruled 2026-08-30) deliberately device-bound.

**Q2 — escrow conventions.** No suite-wide namespace exists; follow the PATTERN, not a dialect:
each item gets its OWN service + OWN account; payload is the raw key bytes + key id — **not** an
envelope (Variorum's `StoreKeyEnvelope` is the on-disk SIDECAR holding passphrase/recovery WRAPS, a
different artifact; don't cargo-cult it into a keychain item). One fresh, measured lesson from this
week (Variorum pre-13u Act 9, the #82 build): **a plain no-ACL item under a shared service/account
IS matched by a no-flag `SecItemDelete`** — keep the device item's and escrow item's service/account
pairs fully distinct so a delete aimed at one family can never match the other. Custody-handover
ordering you already adopted; see Q6 for its second half.

**Q3 — the prompting cycle.** What Variorum actually ships: the Standard nudge (first appears ≥24h
after first use; offers BOTH secrets; 14-day snooze), 30-day reminder checks, the "Check that you
still have your secrets" face (type a secret, the app tries it against the vault and throws the
result away — nothing changed or reset), and — as of this week — state-aware tiers (gentle when
covered, plain-truth when a user is genuinely one-device-and-nothing-else). **Ruled for Fragments:
the minimal matching set** — the 30-day reminder + the secret-check face for enrolled users, the
same cadence numbers, device-neutral "this device" language — plus the recovery-phrase-at-set-time
display (ruling 4). Skip the full exposed-tier nudge machinery: its target population (Auto users
with no secrets and no working escrow) is handled in Fragments by rulings 2–3.

**Q4 — Variorum mobile's re-lock semantics** (verified in `MobileRelock.swift`, not from memory).
Two dials, both meaningful only under demanded modes, both re-checked at fire time:
- **Lock on leaving the screen** (`relockOnSleepAndScreenLock`, phone reading): backgrounding IS the
  phone's leaving; the order is load-bearing — flush editors, land leaving savepoints, stop
  services, THEN lock and drop key material, all inside the same background grant. The quick-note
  box deliberately refuses with words under a lock (text stays in the box) rather than silently
  minting.
- **Lock on return after time away** (`relockAfterIdleMinutes`: Never/5/15/60): a suspended phone
  cannot poll, so the away dial reads ON RETURN — before any sync trigger fires, so a return that
  locks never wakes a round against a closing pool. A short trip out costs nothing.
- Plus manual Lock Now.
**Recommendation for the journal gate's feel:** your §2.4 lean is right and matches dial one —
re-lock immediately on leaving the journal surface or backgrounding, no grace (Face ID makes
re-entry cheap). If you ever want a softer option, the away-dial-on-return shape is the suite's
precedent — never a foreground grace timer.

**Q5 — the pre-E2EE corner.** Extinct by construction on the suite: 14c ships per-user key-vault
provisioning at signup, and sync has been E2EE-from-birth since 14b — there is no supported
signed-in-vault-less state for accounts created since signups opened (14d), and no legacy
population carrying it. **Kill §2.1's plaintext-push arm — and do not leave it as silent behavior:
replace it with a VISIBLE refusal** (the suite's standing refusal grammar: refuse the round, keep
the outbox intact, say why). A corner that "cannot happen" but silently pushes plaintext when it
does is exactly the class the suite refuses; make it a canary, not a feature. This also deletes the
no-ACL consequence §2.1 flagged.

**Q6 — keychain traps, the transferable list.**
- **iOS single keychain: confirmed** — the macOS data-protection/file-based split from the 13p
  incident cannot bite on iOS (verified when the fix reached the phone as a no-op: Apple treats the
  partition key as always-set there). Your `…ThisDeviceOnly` classes genuinely mean what they say on
  iOS — #82's macOS caveat (the class being inert without the partition flag) does not apply.
- **The distinct-service/account rule** (Q2) — the no-flag-delete cross-match lesson, measured this
  week.
- **Verify DELETES, not only writes.** Variorum's custody law was initially enforced in one
  direction; the delete seams dropped `OSStatus` and three silent-failure shapes survived (our 17h
  entry closed this). Your CustodyHandover adoption covers write-verify-then-delete — give the
  delete leg a checked result too, and pin it with a fails-deletes test knob.
- **`.biometryCurrentSet` invalidates on biometric re-enrollment BY DESIGN** (Variorum's copy words
  it: re-enrolled biometrics invalidate the stored keys — the passphrase still gets you in). Under
  ruling 2 this is clean for you: every locked user is enrolled, so the recovery road is the
  passphrase → re-derive from the vault → re-mint the gated item. Build that road; never let an
  invalidated item read as "no key exists."
- **The test-process tripwire pattern**: production fixed-account keychain writes/deletes refuse
  from a test process (DEBUG-only, throwaway-service path exempt). Variorum added this after a
  drill overwrote the author's live custody despite a written rule — the rule alone failed once;
  the tripwire is structural.
- **A stricter class is available to you**: your §1 facts say the locked-launch process never
  touches journal rows and sync is foreground-only — so the JOURNAL key items can likely be
  `WhenUnlockedThisDeviceOnly` (stricter than the store's `AfterFirstUnlock…`): device locked ⇒ key
  unreadable at all. Verify no background edge exists, then take the free hardening.

**Q7 — open comment on §2, including the findings.**
- **The residue finding (the one real gap — fix before the claims table is true):** encrypting rows
  IN PLACE leaves the pre-migration plaintext in the SQLite file's free pages and WAL. Variorum
  paid for this lesson twice (secure_delete measured ~free and turned ON at the spike; a
  WAL-plaintext scan that couldn't fail until the WAL was checkpointed first). For Core Data: after
  the migration sweep, force a WAL checkpoint and a vacuum, and set `secure_delete` going forward
  (`NSSQLitePragmasOption`). Until then, "backups / extraction: ciphertext" overstates.
- **Two claims-table clauses to add:** (a) the age-out clause — a device/iCloud backup taken BEFORE
  this build still holds plaintext until a newer backup replaces it (Variorum's pocket guide
  carries the same sentence); (b) the compound sentence for the un-locked population — the device
  backup (ciphertext) and the escrow key BOTH ride the user's Apple account, so someone fully in
  that Apple account can read an un-locked user's journal; for that population it is also exactly
  what saves them. One read sentence, not a buried one.
- **The recipe for un-locked users, confirmed at her question:** an ordinary iOS device backup (the
  app's store restores with it, ciphertext) + iCloud Keychain (the escrow key) = the journal comes
  back on a new phone with no secret typed. Same recipe shape as Variorum's ("a copy + a key"), with
  the copy half nearly automatic on iOS. Locked users' recipe: passphrase or recovery phrase — full
  stop.
- **The enrollment re-encrypt sweep must COMPOSE with §24's existing post-enrollment sweep**, not
  run beside it as a sibling — one sweep, two jobs (l1→e1 locally; push what the server lacks), or
  the second will re-discover the first's work.
- Genuinely good and adopted-as-is from the reviewer's side: the `l1:`/`e1:` prefix discrimination
  (classify() stays honest, wrong-key decrypts never misread), the never-re-encrypt-unchanged rule
  (GCM nonces would fabricate sync churn — this is the suite's own no-churn discipline), the
  preserved-verbatim refusal inheritance, the capture-suppressed unstamped migration, and §4's
  platform hardening. The `l1:` AAD grammar is fine as specced.

## THE CONSISTENCY MAP (her question: "will these rulings lead to a consistent approach?")

| Fragments state | Variorum shape it now mirrors |
|---|---|
| silent mint, un-locked, two items | Auto + the iCloud spare (Shape 2) — the normie default |
| enrolled, un-locked | Auto + secrets set — the nudged state |
| **locked = enrolled + biometry-only + NO escrow** | **Biometric mode (Shape 1) — passphrase required, no silent copy, passcode never in the chain** |
| the passphrase | ONE suite secret, everywhere, with the recovery phrase shown at set |

One law, one secret, escrow-follows-the-posture, theater-refused — the same sentences teach both
apps. The reviewer's answer to her "easy enough for the average user?" is yes: the average user
never meets any of this (silent mint, ordinary backups, iCloud recovery); the lock is there for the
person who wants the ceremony, and it demands the real secret that makes it true.

## PROCESS NOTES

- Batch A's hold lifts at HER go, not this document's.
- The Fable cold review gate on Batch A (your §5) is the right call; the red-on-old pin discipline
  in your test plan matches the suite's hallucination guard.
- Questions back through this channel (`notes/fragments-bridge-contract.md` carries a pointer to
  this reply); she carries everything, both directions.
