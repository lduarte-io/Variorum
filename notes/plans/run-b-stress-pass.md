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

**The answer in plain words.** The proof value transits eight RPCs as the base64 body parameter
`key_proof` (`sync_push` · `sync_pull` · `sync_horizon` · `sync_purge_ledger` ·
`sync_purge_execute` · `account_data_truncate` · `sync_reencrypt` · `key_vault_update`) and is
consumed in exactly one place, `sync_key_proof_check` (`11_pre13x_postures.sql:257–310`): the
value is hashed (`sha256`, line 284) and compared against `key_vault.key_proof_hash` in a
constant-time XOR loop (lines 301–305). **The raw value is never written to any table** — the
only write is the hash (the migration arm's UPDATE at line 297; `key_vault_update`'s
`coalesce(payload->>'key_proof_hash', …)` at line 949 lands a hash the CLIENT computed, not the
presented value). Consequence, verified by reading: **the durable data plane — the `key_vault`
row, WAL, replicas, and every Postgres backup — retains only `SHA-256(kp)`,** which is not
invertible into the proof and yields nothing (the server compares against it; presenting the
hash itself fails the compare, since the hash of the hash is not the hash).

**Where the VALUE could be retained server-side (the enumeration the question asks for):** all
of them are transit/observability layers, none of them the data plane —
1. **HTTP body capture at the API edge** (the gateway / PostgREST in front of Postgres). The
   design placed the proof in the body precisely because URL/query and header logging is routine
   and body logging is not (§3.10's closing paragraph says this in as many words); an operator
   who turns on body logging retains it.
2. **Postgres statement/parameter logging** (`log_statement = 'all'`, slow-query logging with
   parameters, `auto_explain` with bound values, pgAudit-class extensions): the RPC's arguments
   would appear in the server log. `pg_stat_statements` normalizes constants and does not retain
   the value.
3. **Process memory / crash dumps** during a call — ephemeral, listed for completeness.
4. NOT retention surfaces, verified: the vault row (hash only) · WAL/backups (hash only) · the
   error path (`sync_key_proof_check`'s exceptions never echo the presented value) · the RPC
   return payloads (none carries the proof back).

**What an operator (or log-capture holder) of the value can do — the design's own disclosed
class, confirmed:** nothing without a SESSION for the account (`auth.uid()` gates every RPC —
lines 269–272, 338–341; `KeyProofGateTests` exercises the gate order). Holding the proof AND a
session, they hold **mutating access — integrity/availability, never confidentiality**: push
rows (which land as their own bytes in the partition), truncate the partition
(`account_data_truncate`), purge, and — the sharpest arm — `key_vault_update` under the current
proof may replace `key_proof_hash` and the wrapped copies wholesale, which locks the real
devices' rounds out (`VARIORUM_KEY_PROOF_REQUIRED` everywhere; the devices cannot re-write the
vault either, since their proof is now stale). That worst case is the account-password class the
design names: loud, survivable — every local library keeps working (M/C sit raw in device
custody; nothing local needs the server), and the recovery road is delete-and-set-up-again
(§3.4's third act), after which every take/savepoint re-uploads (corner 31).

**What they can NOT do, confirmed:** read anything — `sync_pull` returns `e1:` ciphertext under
the corpus key, which the proof neither is nor yields (kp is an HMAC output of M; M is not
derivable from it, and the vault's copies of M are wrapped under P/W/A); open any library or
backup (no library key is reachable from kp); pass any key door on a device (those verify the
typed word against the vault's wrapped copy, a decrypt the proof cannot perform); or read the
horizon/ledger WITHOUT the proof (the two read RPCs took the gate at 1b — ledger 38).

**Evidence:** `11_pre13x_postures.sql` lines cited above; `KeyProofGateTests` —
`aSessionWithoutTheProofGetsNothingFromTheMirrorButCanFetchTheVaultAndDeleteTheAccount` (:46),
`aBareSessionsDirectVaultPatchIsRefused` (:114 — the table-level write road closed, ledger 41),
`theNullHashArmLandsTheFirstProofOnceAndANullHashInsertIsRefused` (:141 — the migration arm is
closed; her vault's hash landed at the window, verified in §18's mirror acts),
`theRightKeyIDWithoutTheProofDeletesNothing` (:229),
`theOldProofIsRefusedAfterARotationAndTheNewOneAccepted` (:252). NIT-4 (the one defaulted
`key_proof` parameter, on `sync_pull`) is verified harmless — a NULL proof fails
`presented_hash` derivation and refuses — and is already owned (13y's row, reorder at the next
lockstep event).

**VERDICT: HOLDS — with the design's own recorded residual.** The design answers the question
in its own text: §3.10's bearer-token paragraph and closeout consideration 1 disclose exactly
this surface, and the mitigation (a per-request challenge instead of a static bearer secret) is
already owned by **13y** (its row carries it). Nothing new found beyond the disclosed class; the
one precision this pass adds is the verified fact that the durable data plane holds only the
hash, so backups/WAL/replicas are NOT part of the retention surface — only transit-layer
logging is.

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
