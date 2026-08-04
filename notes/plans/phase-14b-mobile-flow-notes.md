# Phase 14b → mobile: the E2EE flow notes (the author's coordination deliverable)

> **What this is:** the list the 14b architect owes the waiting
> variorum-mobile session — what to consider when the phone adapts the
> E2EE setup/enrollment flow. The author set the sequence herself
> (2026-08-04): the Mac's copy/flow + crossover rounds land on `main` →
> she tells the mobile session to pull → mobile adapts the flow for the
> phone → merge back. **This file is the handover's source of truth**;
> the design record behind it is `notes/plans/phase-14b-suite-e2ee.md`
> (rulings R-1…R-8, the CF ledger CF-1…CF-16, the copy/flow round
> record). Frame, stated because it governs how these notes read: this
> is the author's own app's end-to-end-encryption settings UX for her
> own users, and every ruling below is hers, recorded in that file.

## 0. The one structural fact that shrinks this job

**The E2EE surface is ONE SHARED VIEW already** —
`App/Variorum/Shared/EncryptionViews.swift` (+ `EncryptionSession`,
`EncryptionKeychain`) render on BOTH form factors through the same seam
(the 14a AccountView precedent; PL-6's both-form-factors mandate,
honored at design time). The phone already runs this code: her gate
enrollment (0.16 s KDF) went through it. So the mobile session's work is
NOT a rewrite — it is (a) presentation/navigation fit in the phone
shell, (b) the mobile-world lifecycle care below, and (c) verification
under real iOS conditions. Where a shape must diverge, the capability
stays and the shape may compromise (the MobileSoul decision grammar).

## 1. ★ THE HEADLINE CONSTRAINT (hers, verbatim-faithful)

*"If a user switches apps to save their passphrase or 12 words somewhere,
the flow shouldn't just disappear."*

This is MobileSoul platform truth #1 (the app dies without warning)
meeting the one screen where losing state is unrecoverable. The binding
behavior:

- **Background → foreground (process survives): the SAME step with the
  SAME words.** A user who backgrounds mid-step-4 to paste the 12 words
  into a password manager MUST return to the identical phrase. Any flow
  that re-mints or restarts on foreground is a defect.
- **Kill mid-flow (process dies): the honest restart, never a
  half-state.** The Mac architecture already gives the right answer —
  trace it before porting: the VAULT is written at step 3 ("Create
  Encrypted Vault"); the RECOVERY WRAP lands only at the confirm. Step 4
  is not a screen but a STATE (`.enrolled(hasRecoveryWrap: false)`), so
  a kill mid-step-4 relaunches INTO step 4 — with FRESH words (the
  un-confirmed ones died with the process, and nothing referencing them
  was ever written). That is correct and safe: no half-created vault, no
  orphaned wrap. The port must preserve exactly this: the mandatory
  phrase step is driven by the projected state, never by view-local
  navigation position.
- **What lives only in view @State (typed passphrases, the confirm
  entry) may die with the process** — retyping is cheap and
  secret-hygienic. What must NOT be lost to a background→foreground hop
  is the current STEP and the displayed WORDS; keep the hosting
  view/scene alive-friendly (don't tear the sheet down on scenePhase
  changes).

**A consideration to weigh (not a ruling — flag it to her):** iOS
snapshots the app for the app switcher at backgrounding. If the 12 words
are on screen, the snapshot holds them. The standard pattern is a
privacy cover on `scenePhase != .active` over the sensitive screen.
Weigh it against her hygiene note in the plan file (an exposed phrase is
fixed by regenerating); recommend building the cover, cheap and honest.

## 2. The rulings that bind BOTH platforms (no phone deviation)

- **The recovery phrase is MANDATORY at setup** (CF-5). Step 4 cannot be
  skipped; there is no declinable "Generate" offer (it auto-generates on
  appear); no ambient "Done" beside an act (CF-1 — dismissal is a plain
  Close).
- **Her checkbox sentence, BYTE-EXACT and pinned by test** (CF-7):
  "I understand that if I lose my recovery phrase and my passphrase,
  that I will not be able to recover anything from sync or add new
  devices". iOS renders the native switch (the platform's checkbox —
  recorded deviation, accepted).
- **The warning carries the local-copy-survives clarification** (CF-6)
  and the storage advice (CF-9: paper or a password manager, two copies
  of each, stored separately) and the whole-phrase-is-the-secret copy
  (CF-13).
- **Biometric OR the encryption passphrase — NEVER the device passcode**
  (CF-12, her ruling). The gated Keychain item is `.biometryCurrentSet`
  ALONE; biometric failure falls back to TYPING THE PASSPHRASE; the
  system prompt's fallback button is suppressed (falling back is our
  passphrase road, never a system credential). Per-platform naming:
  "Face ID or Touch ID" on iOS. Biometry re-enrollment invalidates the
  item BY DESIGN; the passphrase recovers.
- **Nothing is ever called by the WebAuthn credential word** (her
  terminology ruling) — `TerminologyPinTests` walks all three shipped
  source roots including `VariorumMobile/`, comments included. It will
  catch you; don't test it.
- **The copy strings are shared statics on `EncryptionView`** — both
  platforms speak identically BY CONSTRUCTION. Do not fork them; if a
  phone screen needs different copy, that is a question for her, not a
  local edit. (Her walk's final ratify may still adjust wording — the
  statics are the single place it lands.)

## 3. What the crossover round adds (landing with the same pull)

- **CF-14 — Encryption folds UNDER Account as a TAB** (her call:
  "account will one day show payment"). The phone reaches it Settings →
  Account → the Encryption tab; the sync row's separate "Encryption…"
  button retires. The LOCKED state's "Unlock…" door stays reachable in
  place — it is the refusal's own affordance; never bury it.
- **CF-15 — the sync row's buttons stop vanishing during rounds** ("Sync
  now" merely disables while syncing). The row is the SHARED
  `SyncStatusRow` — `MobileSettingsView` inherits the fix for free, but
  VERIFY the phone's own chrome doesn't reflow (rounds are frequent;
  this was her mobile observation too).
- **CF-16 — the stale-key honesty state.** If the account is ever
  RE-KEYED (her CF-8 road: fresh vault, re-encrypted corpus), a device
  holding old keys now projects a distinct REPLACED state — copy shape:
  "This account's encryption keys were replaced. Enter your passphrase
  to re-enroll." — instead of claiming healthy enrollment while rounds
  fail. The phone gets this through the shared seam; verify it renders
  and that re-enrollment from it overwrites custody cleanly.

## 4. The phone's half of the re-key drill (her acceptance exercises it)

Her live drill (the plan file's runbook) ends on the phone. The flow to
verify, in order — all through the shared doors:

1. **Forget:** Settings → Account → Encryption tab (post-CF-14) →
   "Forget Encryption Keys on This Device…" → confirm. Custody + launch
   cache + biometric gate all clear; the vault is untouched; the sync
   face returns to its locked line immediately (never a stale reading).
2. **After her Mac re-keys the account:** the phone sits in CF-16's
   replaced state (or, if she forgot keys first, plain enrollment).
3. **Re-enroll with the NEW passphrase** → pull over ciphertext → her
   corpus readable.
4. **The phrase road, proven properly:** forget again → "Use my recovery
   phrase instead" → her NEW 12 written words → enrolled. (Sign-out
   deliberately keeps custody, and iOS Keychain items survive app
   deletion — CF-11's door is the ONLY path that clears a phone's keys;
   that is why this drill goes through it.)

## 5. Mobile-world specifics worth deliberate care

- **BIP-39 entry ergonomics:** the phrase fields ship
  `.autocorrectionDisabled()`; keep auto-capitalization off too. Word
  autocomplete against the 2048-word list is a genuine phone nicety —
  FUTURE, not owed now; note it if the typing feels bad in practice.
- **The KDF moment (~0.16 s Release on-device, surfaced on the flow):**
  fine — but the derivation is synchronous work at enroll/unlock;
  keep the busy indicator honest on the phone (it exists in the shared
  view).
- **The biometric launch cache is process-lifetime.** iOS kills freely:
  a killed app re-locks (that IS "once per launch"). Verify the
  locked-state face + Face ID re-unlock feel right under real kills,
  and that sync visibly waits (the stated cost, in the toggle's copy).
- **Keychain accessibility:** the plain custody item is
  `AfterFirstUnlock` (background rounds after reboot must find keys);
  the gated item is `WhenUnlockedThisDeviceOnly` + biometry —
  background-before-first-unlock refusal is that mode's designed cost.
  Nothing to change; know it when a background round refuses.
- **The phone may be the ENROLLER** (her words: "remember that the phone
  might be the enroller"). A user may meet E2EE for the first time ON
  iOS: the FULL stepped setup (intro → warning+checkbox → create →
  mandatory phrase) must work and read well on the phone, not just the
  enrollment short-path. Walk it as the first-run experience it is
  (CF-10: many users' first real E2EE — the flow must make sense FOR
  THEM).
- **Sheet vs push:** the Mac presents Encryption as a sheet off the sync
  row; the phone should present whatever the shell's grammar prefers —
  shape may flex, capability and step ORDER may not.

## 6. Merge mechanics

Pull `main` only at her word (she coordinates the timing herself). The
Mac side lands: the copy/flow round (`969ff83`…`a9b00fd`), the crossover
round (CF-14/15/16), and the cold-review pass's fixes if any. The mobile
suite baseline at handover: 173/25 (the KDF latency suite included).
After adapting, the parity ledger row is PL-6 in `notes/MobileSoul.md` —
mark what shipped there.
