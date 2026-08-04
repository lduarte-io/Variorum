# Phase 14b — Author Handoff (Suite E2EE; closed 2026-08-04)

> Self-contained per the standing rule: if a question about this phase
> could only be answered by a session's context, the docs are wrong —
> fix the docs. The BINDING record is
> `notes/plans/phase-14b-suite-e2ee.md` (rulings R-1…R-8 · THE DESIGN ·
> batch records · the ladder · the gate/wipe/repush executions · the CF
> ledger CF-1…CF-16 · the copy/flow + crossover round records · the
> cold pass C-1…C-7 · your executed re-key drill). The master plan's
> closeout log has the one-paragraph summary.

## YOUR CHECKLIST (everything left that is yours)

1. **Destroy the two dead phrase papers** (you said this is underway —
   nothing else confirms it, so it lives here): the pre-drill original
   set and the drill's step-4 set are both dead; **the LIVE phrase is
   the set from your landed regenerate** (vault revision 3), which you
   confirmed is written down. One live paper, zero look-alikes.
2. **Optional, no gate:** flip "Require Touch ID to unlock sync" on the
   Mac or Face ID on the phone and feel the once-per-launch unlock. The
   setting shipped fully pinned but your drill's roads were passphrase +
   phrase, so it has never been toggled live. Any day, or never.
3. **Open 14c at your word** — the paste-ready draft is
   `notes/plans/phase-14c-multi-tenant.md` (kickoff message at top; it
   opens with its own design sitting). It carries everything this phase
   pinned for it, including the re-key fence constraint and the
   admin-link-bypasses-signups fact.
4. **Your Variorum-usage pause is yours to end or keep** — your 0v
   ruling ran "until Phase 14 completes" and 14c remains; but your
   corpus now syncs E2EE under your keys, so the pause's original
   grounds have narrowed. Entirely your call; nothing technical waits
   on it either way.
5. **The mobile parity round's Stage A** starts at your word to that
   session (separately planned; its trigger fired at 14a and 14b added
   no debt — PL-6 closed clean).

## What shipped, in one breath

Everything user-authored syncs as AEAD ciphertext under keys only you
hold: master + per-class keys in an RLS'd account vault, wrapped by your
Argon2id-stretched encryption passphrase AND your 12-word BIP-39
recovery phrase; the serializer seam seals/opens at the engine's wire
boundary so the sync engine (CAS, merges, repairs) never noticed; the
convergence suites run green OVER ciphertext; your mirror was wiped and
repushed twice (gate + your drill), both proven zero-plaintext across
all eighteen encrypted columns with row counts exact. The settings UX is
the stepped setup you rebuilt with your CF rulings (mandatory phrase,
your checkbox sentence byte-pinned, the forget door, the biometric
gate that never accepts the device passcode, the Account-tab fold, the
stable sync row, and the honest "keys were replaced" state your drill
validated live on the phone). The Fragments bridge carries journal-class
encryption capability but stays structurally paused until the 14c-end
one-batch handoff.

## Counts at close (the merged tree, mobile's PL-6 half in)

core **1158/124** · Mac **1218/213** (the standing TakePane tripwire
the one allowed red, confirmed by identity) · mobile **175/26** · spine
**51/7**. `/Applications/Variorum.app` refreshed from final `main`.

## Findings + dispositions, in brief

- **Ladder (rounds 1–2, closed):** R1-1 the missing truncate artifact
  (authored + registry-pinned) · R1-2 vault revision CAS (the race your
  regenerate would have lost — fixed pre-deploy) · R1-3 integration-test
  opt-in fence · R1-4 the bridge's future-version ciphertext guard ·
  R1-5…R1-9 NITs (all fixed or carried to this closeout, all landed).
- **Cold pass (post-gate rounds; no BLOCKER/MAJOR):** C-1 MainActor
  Keychain hops → 13e's securityd row · C-2 the doc-staleness manifest
  (landed at this closeout: SyncSpec's E2EE seam delta + BOTH missing
  §12 lockstep entries incl. 13b's) · C-3 the re-key stale-writer fence
  → 14c constraint, pinned · C-4 ASCII-only version-prefix scan (fixed,
  revert-verified) · C-5 dead code removed · C-6 the KDF off-main
  tripwire test · C-7 record hygiene.
- **Every PROVISIONAL is dispositioned** in the plan file; the ones that
  were "hers to reverse" (the one-Close sheet, the replaced-row wording,
  the locked-line wording) were **ratified by your walk**; the mobile
  snapshot cover was **accepted by your walk**.

## Standing facts a future session must not re-derive

- The vault lives on the Variorum project (R-1; the free re-open is
  SPENT — the one look-back left is 14a's "re-decide before the first
  stranger account").
- `key_vault` has NO delete policy by design — removal is
  account-deletion-scale work, 14c's.
- Sign-out never clears key custody; CF-11's forget door is the ONLY
  path that does, on both platforms.
- The passphrase is changeable cheaply (master re-wrap); the recovery
  phrase replaces only through the passphrase-gated regenerate; a
  re-key (new vault) strands other devices' custody — which now speaks
  (CF-16) instead of failing silently.
- Admin `generate_link` BYPASSES signups-off and will mint a user for
  *[removed for publication]*
  14c, the intended user) before trusting a minted session.
- The bridge is paused STRUCTURALLY (no real journal-bridge key
  provider is wired); resumption is the 14c-end Fragments batch's act.
