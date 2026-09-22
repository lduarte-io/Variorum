# RUN B — S1: THE STRESS-TEST PASS (findings file)

**STATUS: OPEN — 2026-09-21.** The hosted read-only stress pass over pre-13x's ten closeout
questions (`notes/plans/pre-13x-postures-design.md`, CONSIDERATIONS AT THE CLOSEOUT, line ~2481),
slotted S1 between B1 and B2 per her kickoff answer. **This session is READ-ONLY on the product:**
it answers by citing code, pins and suite runs; it fixes nothing, edits no source or test file,
deploys nothing, and never touches the mirror, `/Applications`, or her real store. The only
writes are this file and its commits.

**Verdict grammar (the brief's):** **HOLDS** — the design answers it, with the citation ·
**FINDING** — a concrete mechanism the design does not answer (inputs → wrong state, severity
read, natural owner from the standing set: a 17 entry, 13y's row, 13r's signing checklist,
Phase 12, or "needs the author"; this session never fixes and never files — the orchestrator
adjudicates owners) · **OPEN** — not settled by reading; what would settle it is stated.

---

## Q1 — the key proof's server-side retention surface

*The key proof rides every RPC body. Enumerate everything server-side that could retain it. What
can an operator holding it do, and what can't they? (§3.10; `11_pre13x_postures.sql`;
`KeyProofGateTests`)*

**PENDING**

## Q2 — her attacker scenario: the nine arms, and a tenth

*An attacker holds a Standard-era snapshot pair, the Apple-held key, the account password and the
old master; the owner then enters Castle. Walk the nine arms in `MultiTenantSyncAttackerTests`
and find a tenth. (§14.29)*

**PENDING**

## Q3 — the pre-rotation straggler vs the horizon and the completion guard

*A row pushed under the old proof one second before a rotation: trace it through `sync_pull`'s
2-second horizon, the walk and the deployed completion guard. Where would a second horizon, or a
clock skew, reopen it? (THE LADDER, BLOCKER-1; `CorpusRotationTests`)*

**PENDING**

## Q4 — same-second passphrase changes; same-second Castle entries

*Two devices change the passphrase within the same second; two devices enter Castle within the
same second. Which device's words are the account's, and does every device's Done say so? (§7;
`PostureSwitchTests`' choreography pins; ledger 61/67/69)*

**PENDING**

## Q5 — the recovery-wrap digest as a non-secret; a forged digest

*The recovery-wrap digest is a non-secret in the key file. What does it reveal, and can a forged
digest make a device land the wrong words or skip a notice? (ledger 53;
`StoreKeyEnvelope.vaultRecoveryWrapDigest`)*

**PENDING**

## Q6 — iCloud Keychain reset on a three-device Standard account

*Reset iCloud Keychain on a Standard account with three devices. Which devices still open
silently, which fall to the passphrase, and does any device ever write the vault without consent?
(MAJOR-3 REFINED; MINOR-N1; 17m)*

**PENDING**

## Q7 — the fresh library on a Castle Mac cannot sync without a typed secret

*Move the library file aside on a Castle Mac while signed in. Prove the fresh library cannot sync
without a typed secret. (§3.7; the KnownIssues row resolved at 1a/2a/3a)*

**PENDING**

## Q8 — a pre-Replace-All-Keys backup restored on the same Mac

*Restore a backup taken before a Replace All Keys on the same Mac. Which credential opens it, and
does the custody item for the current key ever get used on the older file? (§6; 5b's question 6;
13x's row)*

**PENDING**

## Q9 — a device wiped and restored from Time Machine

*A device wiped and restored from Time Machine: what custody survives, what identity does it
present, and can it be mistaken for the old device? (§3.3 decision 13; `ThisDeviceOnly`)*

**PENDING**

## Q10 — brute-forcing the passphrase at the shipped KDF floor

*Brute-force the encryption passphrase against a stolen key file at the shipped KDF floor. At
what passphrase length is the cost real? (`PassphraseKDF.Floor`; 17n)*

**PENDING**

---

## VERDICT SUMMARY (filled at the close)

**PENDING**
