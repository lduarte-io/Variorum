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

**The nine arms, walked and confirmed against the code** (`MultiTenantSyncAttackerTests.swift`,
`herAttackerScenarioTheNineArmsAfterTheSwitchToCastle` + `noOwnershipChangeInstructionExistsOnTheWire`).
The attacker's holdings are the strongest the design names: the snapshot pair (a Standard-era
iCloud-Drive backup + its key file), A's iCloud key, a session for A (the account password), AND
the OLD master + old corpus key unwrapped from the vault's Apple-held copy while Standard stood.
Then A enters Castle and writes.
1. **The old snapshot opens through the Apple key — expected, and it holds ONLY pre-switch
   writing** (:306–321); the same Standard-era key file + A opens NO page of the re-keyed live
   library (§12).
2. **Cannot enroll:** the post-switch vault carries NO Apple-held copy (the ABSENCE is pinned,
   :323–325); a guessed passphrase and guessed words refuse; the old master unwraps none of the
   vault's NEW class keys (:337).
3. **Push/pull with old custody:** the FENCE refuses the old key id first; with the CURRENT id
   (readable by any session) the PROOF refuses; nothing moves, and a refused pull records no
   device cursor (:341–372).
4. **Replace All Keys** refuses at the front check (`staleMaster`) AND at the server
   (`key_vault_update` under the old proof) (:374–391).
5. **A passphrase-change vault write** refuses (`masterKeyMismatch` at the format verify; the
   hand-built re-wrap refused by the proof) (:393–404).
6. **Purge / truncate refuse; the read RPCs give nothing** (`sync_purge_execute` ·
   `account_data_truncate` · `sync_horizon` · `sync_purge_ledger`, all `keyProofRefused`)
   (:406–422). Between 6 and 8 the confidentiality arm: the old corpus key opens NOTHING sealed
   on the server after the walk, while C′ opens every row (:424–433).
7. **The attacker CAN purge the whole account** — the disclosed loud-and-survivable
   account-password class; every local copy survives and A's re-setup ADOPTS into a fresh
   partition (:475–518).
8. **An upload under the attacker's OWN account** (Connect to B): rows stamped A are refused
   WHOLE by the owner guard; the adopt road re-stamps LOCALLY and lands under B; A's partition is
   byte-identical on the wire (:435–473).
9. **No ownership-change instruction exists on the wire** — the client RPC set, the transport
   protocols and the deployed function set are asserted BY NAME; none names or takes an owner /
   transfer / move / adopt parameter; the owner is `auth.uid()` (:531–600).

**The tenth arm — the strongest genuinely-un-fired attacker action: `sync_reencrypt` under the
old proof (or a bare session).** Of the eight mutating/read RPCs the proof gates, the arms fire
seven as attacker actions — push, pull, purge_execute, truncate, horizon, purge_ledger,
key_vault_update. **The ONE data RPC no arm fires as the attacker is `sync_reencrypt`** — the
rotation's write. It is exactly the RPC an attacker holding the old master would reach for: it
overwrites row payloads in place (version-neutral, no CAS bump), so a successful call could
replace A's ciphertext with attacker-chosen or old-C bytes, a targeted corruption of the corpus.
I traced it: `sync_reencrypt(rows, active_key_id, key_proof)` takes `sync_key_gate(active_key_id,
key_proof)` as its FIRST act (`11_pre13x_postures.sql:794`), the identical fence+proof gate as
`sync_push`/`sync_pull`; after the switch the old proof hashes to a value distinct from M′'s
stored hash, so the constant-time compare in `sync_key_proof_check` refuses
(`VARIORUM_KEY_PROOF_REQUIRED`), and a bare session (no proof) refuses the same way. **The design
answers the tenth arm** — the shared gate makes `sync_reencrypt` refuse under the old/absent proof
byte-for-byte as push and pull do (the entitlement gate at :801 is a further wall behind it).

Two adversarial angles I also chased and found closed by the design: **(a) horizon-DoS** — a
stale attacker device_cursor pinning the purge horizon forever is impossible, because
`sync_pull` (the only cursor writer) and `sync_horizon` both sit behind the proof gate, so a
proofless/stale attacker never registers or reads a cursor (arm 3 pins `deviceCursor == nil`
after a refused pull), and 13j's 60-day drop-out bounds even a legitimately-registered stale
cursor; **(b) replay/downgrade** — pushing old-C ciphertext back to overwrite C′ rows is refused
at the gate before any byte lands (arm 3), and even a hypothetically-authorized push would carry
old-id AAD that a legitimate device fails to open (not silent acceptance).

**Evidence:** the suite lines above; `11_pre13x_postures.sql:794` (the reencrypt gate),
:257–362 (the gate + proof check the tenth arm hits). No behavioural revert run (read-only slot);
the nine arms' red-on-old reverts are the batch-4b record's (the fake's four gates reverted one
at a time).

**VERDICT: HOLDS — with a NIT-level SUITE-COMPLETENESS recommendation, not a design gap.** No
tenth arm breaks the design: the shared gate refuses `sync_reencrypt` under the old proof exactly
as it refuses the seven fired RPCs. The honest finding is that the suite never FIRES
`sync_reencrypt` as an explicit attacker action, so the one data-corruption RPC's refusal rests
on the shared-gate argument rather than a dedicated pin. **Owner candidate: a one-line pin
addition** (a `sync_reencrypt` call under the old proof asserting `keyProofRefused`, beside arm
6) — naturally a B2 test-add or RECORDED for the run's harness-realism deliverable (B4). Severity
NIT: the mechanism holds; only the explicit coverage is absent.

## Q3 — the pre-rotation straggler vs the horizon and the completion guard

*A row pushed under the old proof one second before a rotation: trace it through `sync_pull`'s
2-second horizon, the walk and the deployed completion guard. Where would a second horizon, or a
clock skew, reopen it? (THE LADDER, BLOCKER-1; `CorpusRotationTests`)*

**The trace, confirmed against the code.** The straggler is a push that passed the OLD gate one
second before the rotation, holding the vault row FOR SHARE. The rotation's begin
(`key_vault_update`) takes FOR UPDATE, which WAITS for that push to commit
(`pre13x-ladder-rotation-clearing-guard.sql:127–129`; `11:346–348` the gate's FOR SHARE);
`rotation_started_seq` is `nextval('sync_server_seq')` taken INSIDE the vault write's transaction
(:174), so the straggler's rows land BELOW the seq — but `sync_pull`'s A5 horizon
(`server_written_at <= clock_timestamp() - interval '2 seconds'`, `11:587/599`;
`03_visibility_horizon.sql:85`) HIDES them for up to 2 s. On a small corpus the client walk's two
passes could both finish inside that window and miss the straggler (BLOCKER-1's traced
catastrophe: pre-fix `complete` NULLed the previous key, sealing the row under a key that exists
NOWHERE, wedging every later pull's decrypt forever — availability, not confidentiality).

**The two-half fix, both live on the production mirror** (F1 built the client half; the server
half was deployed by the orchestrator at her word and verified — the ladder's F1 ADOPTED note +
the closeout):
- **CLIENT** (`CorpusRotation.reencryptRemainder:477–488`): at the FIRST empty window the walk
  `horizonWait()`s (production `Task.sleep(2.5 s)`, `:285`) then pulls once more — 0.5 s of margin
  over the server's 2 s — so the straggler becomes visible and is re-encrypted (re-stamped ABOVE
  the seq by `sync_reencrypt`).
- **SERVER** (the maintenance guard, `:141–168`): the clearing arm refuses
  `VARIORUM_ROTATION_ROWS_REMAIN` while any ciphertext-carrying row of the caller's partition
  still sits `server_seq < rotation_started_seq`. **This count is SEQ-based, read under FOR
  UPDATE** — every in-flight old-proof push (FOR SHARE) has committed by then — so it reads every
  committed straggler REGARDLESS of the visibility horizon. The runner re-walks on the refusal up
  to `maxCompletionTries` (3), then the honest `completionRefused` still-finishing state.

**Where a SECOND horizon reopens it — the precise answer:** the SERVER guard is horizon- and
clock-INDEPENDENT by construction (a `server_seq` comparison, never a time comparison), so as
long as it is deployed, a client/server horizon DRIFT cannot reopen the CATASTROPHE — it only
degrades completion. If a future change lengthened the server's 2 s past the client's 2.5 s (or
shortened the client wait), the walk's single re-pull would miss, the guard would refuse
`VARIORUM_ROTATION_ROWS_REMAIN`, and the runner would re-walk until real time exceeds the
effective server horizon — the honest "still finishing," never a wedge. **The catastrophe
reopens ONLY if the server guard is ABSENT** (a mirror that never ran the maintenance overlay, or
a redeploy of bare `11_pre13x_postures.sql` OVER it — the maintenance file is a body change to
the same signature, so re-running 11 silently reverts the guard; its own re-run guard protects
11's redeploy but nothing forces the overlay to be re-applied after an 11 redeploy) AND the
client wait drifts below the server horizon. That two-constants exposure is **exactly closeout
consideration 2's scope** — "the A5 visibility horizon lives in two constants … a drift reopens
BLOCKER-1's class → 13y (one source of truth)." I confirmed both halves are the only guards:
`aRowHiddenByTheVisibilityWindowIsReencryptedBeforeCompletionAndEveryLaterPullOpens` (:385) and
`completionIsRefusedWhileACiphertextRowStillSitsBelowTheSeq` (:489) are the pins; the reverts R1
(client wait removed) and the fake's guard removed both redden them (the F1 record).

**Where a CLOCK SKEW reopens it — it does not.** The horizon compares two SERVER-side values:
`clock_timestamp()` and `server_written_at`, itself stamped by the server's own trigger
(`03:47`) — no client clock is trusted (SyncSpec §9). A client clock skew is inert. A server
replica-clock skew (a changefeed read off a lagging replica) could serve a straggler EARLIER than
the primary intended, but the completion guard runs on the primary under FOR UPDATE and is
seq-based, so it still refuses; and the client `Task.sleep` is monotonic, so a backward NTP step
under load can only make the single re-pull early — again caught by the guard. Skew degrades
completion latency; it never reopens the wedge while the guard stands.

**The one recorded residual, NOT a Q3 reopening: the poison row** — a row sealed under a key the
account never held makes the walk THROW, completion refused forever, the account honestly
still-finishing (`aPoisonRowLeavesTheRotationStillFinishingWithThePreviousKeyRetainedUntilItIsPurged`,
:659). That is SAFE (nothing cleared, everything readable, the second rotation refused) and is
already owned by **Phase 12** (park-and-heal; closeout consideration 7).

**VERDICT: HOLDS — with the disclosed 13y and Phase 12 residuals, both already owned.** The
seq-based server guard is the structural backstop that makes BLOCKER-1's class immune to horizon
drift and clock skew; the client wait is the latency optimization in front of it. The single
reopening path (guard absent + horizon drift) is precisely closeout consideration 2's
two-constants risk (owner 13y, one source of truth) plus the operational caveat this pass adds:
**an 11 redeploy must be followed by re-applying the maintenance overlay** — worth stating on the
deploy checklist so a future mirror rebuild cannot silently drop the guard.

## Q4 — same-second passphrase changes; same-second Castle entries

*Two devices change the passphrase within the same second; two devices enter Castle within the
same second. Which device's words are the account's, and does every device's Done say so? (§7;
`PostureSwitchTests`' choreography pins; ledger 61/67/69)*

**Same-second PASSPHRASE change (§7 step 5) — the LAST change wins; a re-wrap, nothing lost.**
`bothDevicesChangeThePassphraseAtOnceTheCASRefusesTheSecondAndTheLastChangeWins` (:3110) confirms:
device 1's change lands INSIDE device 2's write; device 2's CAS refuses
(`vaultRevisionConflict` — "nothing was overwritten"); the vault is under device 1's word (p1).
Device 2 then RE-READS, finds its own typed old word now RETIRED at the door
(`retiredPassphraseAtDoor`, :3161), and retries by the road needing no current word (Touch ID /
held material) — landing ON TOP, so the vault ends under device 2's word (p2), revision +2. **The
answer: whichever change commits LAST is the account's** (order-determined by the CAS; both are
legitimate — a passphrase change re-wraps the SAME keys, so no key rotates and nothing is lost).
**Does every device's Done say so? For a passphrase change there is NO Done line — the say-so is
the NOTICE, by design.** Device 1 learns at its next open via `changeNotice ==
.passphraseChangedElsewhere` (:3184) + a dismissable banner; its own word still opens it locally,
the winning word opens it online through the vault road and re-wraps its copy (:3188–3191). This
is 4a's ruling recorded at closeout item 60 ("the change door has no done line — the notice's
disappearance is the feedback"). Transient stale belief (device 1 believing p1 is current until
it reconciles) causes no lockout and no loss — the notice + vault road resolve it. HOLDS.

**Same-second CASTLE entry (§7 step 7) — the FIRST rotation wins; every device's Done says so
EXACTLY.** `twoDevicesSwitchingPostureAtOnceTheSecondsCASRefuseBecomesTheFollow` (:3208): device
B's WHOLE `enterCastle` lands inside device A's vault write. A's attempt is refused (the PROOF's
refusal — B's rotation replaced the hash, checked before the CAS); A RE-READS, the account has
already moved to Castle under B's keys, and A's road becomes THE FOLLOW with the passphrase it
typed — no second rotation, no vault write of A's own, the corpus key id advanced exactly ONCE
(B's, :3239), `updateCount == +3` (B's begin, B's completion, A's ONE refused attempt), A
re-keys its own library under B's M′ and holds B's material (:3244), A's Standard-era key file
retired. **The account's words are B's (the winner — the first rotation to land).** The critical
safety property: A's ceremony SHOWED A a fresh set of twelve words that are NOT the account's, so
**A's Done must not be the ordinary one** — it renders `enteredCastleAfterAnotherDevice(device:
"test device")` naming the device the vault records (`updated_by_device`), NEVER
`enteredCastleDone` (:3257–3260); B's Done IS the ordinary one (:3261). This is ledger 61 — the
vacuous-promise this phase exists to end.

**The two resume-road corners, resolved EXACTLY by F1's discriminator (ledger 67/69).** The
danger is telling A the wrong story after a crash: the discriminator is the vault's current
corpus key id vs the id A's marker STAMPED (`CorpusRotation.prepare` mints the id BEFORE the
marker's write — F1, ledger 69), and `updated_by_device` is ONLY the sentence's name, never the
discriminator.
- **67** (`aCeremonyKilledBeforeItsVaultWriteResumesIntoAnotherDevicesSwitchAsTheFollowAndSaysSo`,
  :3294): A crashed BEFORE its vault write; B enters Castle whole; A resumes → the vault's id is
  B's (≠ A's marker's id) ⇒ the FOLLOW with the flag + B's name ⇒ the conflict Done. Right.
- **69** (`aCeremonyWhoseOwnWriteLandedResumesAsItselfAfterAFollowerFinishedAndSpeaksTheOrdinaryDone`,
  :3355): A's write LANDED (its marker's id == the vault's), custody failed, a FOLLOWER (B)
  finished the rotation and stamped ITS name on `updated_by_device`; A resumes → the vault's id
  IS the one A minted ⇒ A's OWN switch ⇒ the ORDINARY Done, A's words LANDED (they ARE the
  account's — B followed under them). Without F1's id discriminator the old device-name reading
  would have told A the conflict sentence over words that WERE the account's — a false alarm F1
  closed (the red-on-old revert R3 in the F1 record reddens exactly this).

**VERDICT: HOLDS — with ledger 61's conflict-follow Done wording PROVISIONAL (hers to ratify).**
Both same-second cases are comprehensively pinned and safe: the passphrase change's say-so is the
notice (no Done line, by design); the Castle entry's say-so is a Done on every device, with the
loser's conflict-follow Done and the two crash-resume corners resolved EXACTLY by the
mint-id-vs-marker-id discriminator so neither a vacuous promise (67) nor a false alarm (69)
survives. The one open item is not a defect: ledger 61's `enteredCastleAfterAnotherDevice`
sentence is a PROVISIONAL copy string awaiting her ratification (already a QUESTIONS candidate) —
**owner: her ratify bundle**, not a fix.

## Q5 — the recovery-wrap digest as a non-secret; a forged digest

*The recovery-wrap digest is a non-secret in the key file. What does it reveal, and can a forged
digest make a device land the wrong words or skip a notice? (ledger 53;
`StoreKeyEnvelope.vaultRecoveryWrapDigest`)*

**What it is, confirmed.** `recoveryWrapDigest = SHA-256(masterWrappedByRecovery)` hex — a hash
of the VAULT's recovery wrap, which is M wrapped under the twelve-words' key by RFC 3394
`AES.KeyWrap` (`KeyVaultFormat.swift:379`, `RecoveryWrapDigest.hex` :440–445). RFC 3394 is
DETERMINISTIC (a fixed IV, no nonce), so two wraps of the same M under the same words are
byte-identical and the digest changes EXACTLY when the words or the master change. It is recorded
in the key file (`vaultRecoveryWrapDigest`, `StoreKeyEnvelope.swift:96–102`) at every
reconciliation — a non-secret, in a file the design already treats as public (§3.5 "holding it
grants nothing").

**What it reveals.** It is a hash of CIPHERTEXT (M under the words' key), so it reveals nothing
about M, the words, or the new words — no plaintext, no brute-force handle (unwrapping still
needs the words' key). It is an EQUALITY tag: it discloses (1) the FACT that a regeneration
happened (the digest moved) and (2) LINKABILITY — two key files carrying the same digest were
reconciled against the same (M, words) pairing. Both are already implied by the public key file's
existence, and the digest leaks strictly less than the wrap bytes it hashes (which live
server-side, not in the key file). No confidentiality loss.

**What it DRIVES — only an advisory notice, never a key act.** Its sole consumer is
`ProtectionController.changeElsewhere` (:783–797): if the key file's recorded digest ≠ the
vault's current digest, emit the `wordsRegeneratedElsewhere` NOTICE — a nudge to type the new
words when convenient. It is checked SECOND, behind the passphrase-KDF branch, and only in the
convenience-act domain (a same-corpus-key-id change — a rotation takes the FOLLOW path instead),
where M is invariant, so within its domain the digest moves exactly when the WORDS move and the
label is correct. The actual LANDING of a new recovery wrap
(`landRecoveryWrap(words:recoveryWrapDigest:)`, :1158–1171) sets the wrap FROM THE WORDS
(`setRecoveryWrap(key:words:)`) and records the digest only as an advisory AFTERWARD — **the
digest never participates in an unwrap, a verify, or any authorization.**

**Can a forged digest land the wrong words or skip a notice?** Traced both directions:
- **The VAULT-side digest is not forgeable without the proof.** `reading.recoveryWrapDigest` is
  computed locally from the session-gated fetched vault bytes; changing it means writing the
  vault, which needs `key_vault_update` under the current proof (Q1/Q2). So a cross-device forge
  is exactly as hard as writing the vault.
- **The LOCAL key-file digest is forgeable** (the file is a non-secret the device owns), but the
  only reachable effects are UX-level: forge it to EQUAL the vault's → SKIP the nudge (the user
  isn't reminded to update their local words copy — but the old words still open locally and the
  new words still open online through the vault road, which verifies against the vault's REAL
  wrap, not the digest); forge it to DIFFER → a SPURIOUS nudge (annoying, harmless — typing the
  current words succeeds and re-records the true digest). Neither lands wrong words nor locks
  anyone out, because landing verifies the WORDS against the vault's actual wrap. And forging the
  local key file requires write access to the file beside the library — the open-device attacker,
  out of scope by decision 19.

**One correctness dependency, verified as holding:** the notice's honesty rests on RFC 3394
determinism (a non-deterministic wrap would move the digest on every re-wrap and fire the notice
spuriously). `AES.KeyWrap` is deterministic, so this holds; worth naming so a future switch of
the wrap primitive to a nonce-carrying AEAD would have to revisit the digest's meaning.

**VERDICT: HOLDS.** The digest is a non-secret equality tag that reveals only the fact and
linkability of a (M, words) pairing — no plaintext, no brute-force handle. A forged digest can
only suppress or spuriously fire the device's OWN advisory nudge (a UX nuisance needing
out-of-scope key-file write access); it can never land wrong words, skip a security-relevant act,
or lock a device out, because every landing verifies the actual words against the vault's real
wrap and the vault-side digest is proof-gated. Nothing found beyond the disclosed non-secret
class; the one thing worth recording is the RFC-3394-determinism dependency (a NIT for any future
wrap-primitive change — no owner needed unless that change is contemplated).

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
