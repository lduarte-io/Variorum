# RUN B — S1: THE STRESS-TEST PASS (findings file)

> **✔ DONE 2026-09-21** — all ten questions answered, every one HOLDS (`## VERDICT SUMMARY`); the routed items were delivered: Q1 + Q3 by 13y (closed 2026-09-24), Q8 by 13x (closed 2026-10-08). *(Banner added 2026-10-08: the OPEN status line below is history.)*

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

**The setup.** An iCloud Keychain reset wipes the SYNCHRONIZABLE items — and `A` (the iCloud key)
is the ONLY synchronizable item this design writes (§3.9). Each device's silent library-key
custody item is device-local (never synchronizable), so it SURVIVES the reset.

**Which devices still open silently — all three.** Standard's auto-open reads the library key
from the device-local silent item (§3.8), which the reset does not touch; and the master M sits
in each enrolled device's local custody. So all three existing devices keep opening silently AND
keep syncing — nothing about their own operation depends on `A` (confirmed against
`reconcileAppleKey`: the Apple arm is a background reconcile, never on the open path).

**Which fall to the passphrase — none of the three; only a NEW or wiped device.** A device that
must enroll via the Apple road (a fourth device, or one whose device-local item was also lost)
reads `A` as nil (`appleKeys.read()` nil after the reset), holds no master, so
`readAppleKeyForReconcile` sets `waiting: apple == nil && !mintAllowed`
(`ProtectionController.swift:1556–1559`) → `appleKeyWaiting = true` (:1479) → the "waiting for
iCloud Keychain" state with its passphrase / twelve-words doors (§3.8). The vault's Apple-held
copy is orphaned under the wiped `A`, so silent enroll cannot serve it until re-landed.

**Does any device ever write the vault without consent — NO, confirmed at the code.** For each of
the three existing devices the reconcile computes `holdsMaster = syncCustodyPresentAtReady` (true)
and `mintAllowed = vaultAppleKeyID == nil || holdsMaster` (true), so `read()` (nil) falls to
`readOrMint()` which MINTS a fresh `A′` with `minted: true` and a NEW id (:1555–1558). The HEAL —
the ONLY path that writes the vault (`healAppleHeldCopy`, :1499) — is gated `!read.minted &&
read.envelope.appleKeyID == vaultAppleKeyID && apple.id != vaultAppleKeyID` (:1496–1497), so a
MINT never heals (`read.minted` is true), and after the reset the device's key file no longer
records the vault's id anyway (it records its own minted `A′`). Instead the mint lands into the
device's OWN key file only (`landAppleCopyOffMain` saves the envelope, :1510–1513; the log line at
:1493 states "the vault's Apple-held copy stays under the recorded id"). This is MINOR-N1's fix
(F3 item 1, pin `aMintNeverHealsTheVaultEvenWhenTheFileRecordsTheVaultsId`), which corrected the
pre-F3 bug where a nil-read mint silently re-homed the account's vault copy under whatever Apple
account the device now held. The heal fires ONLY on a genuine READ of a different id — proof of a
same-account duplicate (`read()` returns an id ≠ the recorded/vault id, which only the same Apple
account can produce) — the exact scenario an iCloud Keychain reset does NOT create for the vault's
copy (the vault's id was the wiped one, not a live read).

**The recorded consequence, already owned:** the account's Apple-held copy in the VAULT is
ORPHANED under the wiped `A`, so Standard's silent enroll for NEW devices stops until it is
re-landed; the only road today is the Castle → Standard round trip (heavy). This is exactly
closeout consideration 6 — "the orphaned Apple-held copy after an iCloud Keychain reset or an
Apple-ID switch → 17m (the Re-link door, pre-release)" — and MINOR-N1's disposition names the
deliberate *Re-link your Apple account* door (with a consent sentence) as the honest fix,
AUTHOR-CLASS at QUESTIONS #90.

**VERDICT: HOLDS — with the orphaned-vault-copy consequence owned by 17m + QUESTIONS #90.** All
three existing devices open silently and sync; only a new/wiped device falls to the passphrase;
and no device ever writes the vault without consent — the heal that writes the vault is gated to
fire only on a genuine read proving a same-account duplicate, never on a nil-read mint (MINOR-N1's
`!read.minted` guard). The one owned residual is the recorded consequence (silent enroll for new
devices needs the vault's copy re-landed via a deliberate act), whose owner is **17m** (the
Re-link door) with its product shape at **QUESTIONS #90** — not a new finding.

## Q7 — the fresh library on a Castle Mac cannot sync without a typed secret

*Move the library file aside on a Castle Mac while signed in. Prove the fresh library cannot sync
without a typed secret. (§3.7; the KnownIssues row resolved at 1a/2a/3a)*

**The proof, step by step against the code.** This is the same-machine-bypass class — the design's
claim (§3.3): "the same-machine bypass stays closed by per-store custody + the absent-store
route."
1. **Move the library aside → the lock STAYS.** `StoreLaunchRoute.resolve` returns
   `.libraryMissing(demand:)` on `presence == .absent` (`StoreLaunchGate.swift:308`); the mode is
   "your library file is missing — restore, open, or start new" and `openResettingModeToAuto` is
   DELETED (§3.7), so the absence NEVER silently clears the lock. Restore / Open / Start New are
   the only doors.
2. **Start New → a NEW store id, empty custody.** `LibraryMissingLobby.startNewLibrary`
   (`AppBootstrap.swift:931`) mints under a NEW store id via `StoreIdentity.establish` (the id +
   fingerprint written BEFORE any custody exists); the old key file beside the absent store is SET
   ASIDE, never deleted, and "per-store naming makes [the old library's items] unreachable, never
   gone" (:886–896). So the fresh library has NO library key, NO master, NO device identity for
   its new store id.
3. **The fresh library's sync engine REFUSES before any network contact.** `SyncKeyProviding`
   reads custody; empty custody makes `currentKeys()` THROW, and "the engine maps every throw to
   `SyncError.encryptionKeysUnavailable` and refuses the round before any network contact"
   (`SyncEncryption.swift:75–79`; the `UnenrolledKeyProvider` default, :97–105). `deviceIdentity()`
   throws the same way (:81–90) — "a copy of the library on another machine has no custody for its
   store id and therefore no identity — it is writing, never a device." So a fresh library holds
   no master ⇒ no key proof ⇒ the engine never even reaches the mirror.
4. **To sync it must ENROLL, and on a Castle account enroll needs a TYPED secret.** Posture is the
   ACCOUNT's once a vault exists (decision 8), and a Castle vault carries NO iCloud-held copy of M
   (only P and W wraps) — so the enroll road is the passphrase or the twelve words typed once
   (§5). The still-signed-in SESSION can fetch the vault's WRAPPED copies (a session-only vault
   read) but cannot unwrap M without P or W, so it holds no master, computes no proof, and the key
   proof gate refuses every mutating and read RPC (Q1). **There is no silent road: a typed secret
   is mandatory.**

**The bypass is closed on both legs, confirmed:** the fresh library cannot read the OLD store's
custody (per-store naming — a different store id), and the absent-store route never resets the
lock (`openResettingModeToAuto` deleted). Adjacent variant, also closed: dropping a
DIFFERENT/attacker-supplied library file at the path is corner 33 (a library arriving with its
key file) — opening it on Castle needs its key file's Castle roads and syncing it still needs
enroll → a typed secret.

**VERDICT: HOLDS.** The fresh library provably cannot sync without a typed secret: its sync engine
refuses at `currentKeys()`/`deviceIdentity()` (no custody for the new store id) before any network
contact, and joining the Castle account requires the passphrase or words typed once — the session
alone reaches only the vault's wrapped copies, which it cannot unwrap. Both legs of §3.3's claim
(per-store custody + the absent-store route) are enforced in code. No finding; the KnownIssues
same-machine-bypass row is genuinely resolved (1a/2a/3a).

## Q8 — a pre-Replace-All-Keys backup restored on the same Mac

*Restore a backup taken before a Replace All Keys on the same Mac. Which credential opens it, and
does the custody item for the current key ever get used on the older file? (§6; 5b's question 6;
13x's row)*

**The shapes.** A Replace All Keys rotates M→M′, C→C′ and (device by device as each follows) the
library key L→L′; the live library and its LIVE key file move to L′ under P, W, M′. A backup made
BEFORE the RAK is under the OLD library key L, and it carries ITS OWN key file (written with it,
NEVER rewritten — §6, decision 11) holding L wrapped under the day's P, under W, under the OLD
master M, and — if Standard-era — under A. The snapshot's filename and its key file are named by
L's fingerprint (`variorum-backup-<stamp>-<fp8>` + `<...>.keys.json`).

**Which credential opens it.** The day's PASSPHRASE (if unchanged across the RAK, that IS the
current passphrase — P wraps L in the snapshot's own key file), the TWELVE WORDS (unless
regenerated), and — for a Standard-era snapshot — the Apple account (A). **NOT the old master:**
after a RAK the old master is dead on every device, so the master-wrapped-copy road to a
pre-rotation backup CLOSES (ledger 50(a): "the MASTER-copy road to pre-rotation backups closes —
the old master is gone from every device; the day's passphrase, the words … and Standard's Apple
account still open them"). This is exactly §6's one user sentence.

**Does the custody item for the current key ever get used on the older file — NO.** The key file
for a KEY is chosen by FINGERPRINT (§3.5: "custody's raw key names it directly (zero
derivations)"). The current custody holds L′; the older file is under L; L′ ≠ L, so the current
custody's raw key names the L′-fingerprint file and NOT the older L-fingerprint one
(`preferredURL`/`locate` route by fingerprint, `StoreKeyEnvelope.swift:455–497`;
`matchesFingerprint` at :155–159 refuses a mismatch). The current key is therefore never
successfully applied to the older file, and P1 guarantees it is never WRITTEN over it either ("an
unreadable sidecar SKIPS the arm whole — nothing is ever written over a file that may hold intact
wraps"). §6's own words: "custody and the LIVE key file pair with every snapshot of the SAME
library key" — a pre-RAK snapshot is a DIFFERENT library key, so it pairs with its own key file,
not the current custody.

**The recorded caveat, owned by 13x (5b's question 6).** On the SAME Mac the store id names a
custody item holding the CURRENT key, and the runbook's restore recipe is deliberately SCOPED to a
copy under the library's CURRENT key (the everyday 13l drill). Restoring an OLDER-key copy on the
same Mac — where the gate finds custody's L′ does not open the restored older-L file and must fall
to that file's own passphrase/words road — is 13x's open-door territory ("Open a library file…",
the "second look" for a matching-fingerprint key file), which is UNBUILT today. So the CREDENTIAL
answer holds unconditionally (the day's P / W / Standard's A open the snapshot by its own key
file), but the same-Mac RESTORE-and-open ROUTING for an older-key copy is 13x's, named on its row
(5b.6, CONFIRMED at 5b's adjudication; re-stated on the master plan's 13x hand-forward).

**VERDICT: HOLDS — with the 13x same-Mac older-key open-door caveat, already owned.** The
credential that opens a pre-RAK backup is the day's passphrase (= the current one if unchanged),
the twelve words (unless regenerated), or Standard's Apple account — never the old master (dead
after the RAK, ledger 50(a)); and the current key's custody item is NEVER used on the older file
(fingerprint mismatch, and P1 forbids any write). The one open item is not a defect: the same-Mac
restore ROUTING for an older-key copy is 13x's unbuilt open-a-copy door (owner **13x**), with the
runbook honestly scoped to current-key copies until then.

## Q9 — a device wiped and restored from Time Machine

*A device wiped and restored from Time Machine: what custody survives, what identity does it
present, and can it be mistaken for the old device? (§3.3 decision 13; `ThisDeviceOnly`)*

**What custody survives — nothing usable.** Both custody items are
`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`: the silent bound item
(`EncryptionKeychain.swift:595`) and the biometric gated item (:643, wrapped by
`.biometryCurrentSet` in the Secure Enclave). `ThisDeviceOnly` items are device-bound — excluded
from backups that migrate to another device, and unreadable after an erase (the class keys that
protected them are gone). So a wipe-and-restore leaves NEITHER the silent nor the gated custody
item usable. What DOES survive is the ordinary files Time Machine copies: the library FILE (with
its `sync_state` cursor) and the key FILE beside it — but "the library file carries writing and
local bookkeeping only — never a key and never an identity" (§3.3). This is decision 13 / corner
21 verbatim: "Time Machine / Migration Assistant of a Castle Mac carries nothing usable (no key in
the file; custody items device-bound; tokens bound; the gated item hardware-wrapped)."

**What identity it presents — a FRESH one.** The device identity RIDES the custody item
(`deviceIdentity()` → `store.deviceID()`, :877). With no bound custody item surviving, the mint
falls through `session.record?.deviceID ?? leaves.loadPlain()?.deviceID ?? UUID().uuidString`
(:405–407) to a FRESH UUID — §3.3's "a machine with no custody for a store id has never opened
that library, so a copy gets a fresh device id by construction; a wiped Keychain mints a new one —
harmless." To rejoin sync the restored device must ENROLL (it holds no keys): Castle → the
passphrase or words once (the Touch ID gated item is gone); Standard → the iCloud key once it
re-syncs, else the passphrase.

**Can it be mistaken for the old device — NO.** The device_id is the discriminator for the
`device_cursor` and the purge horizon, and it rides custody, which is device-bound and does not
survive the restore — so a restored device ALWAYS presents a fresh id, never the old device's.
The subtle interaction is that the restored library holds the OLD cursor value in `sync_state`
(Time Machine copied it), so the restored device is a (new id, non-zero cursor) pair — which is
EXACTLY corner 37: "A re-minted device identity with a non-zero cursor is a RETURNER to the purge
ledger (13j's fence) — reconciled at its first round, never stranded." It reconciles any purges it
missed while gone and is tracked as its own `device_cursor` row; the old device's cursor is a
SEPARATE row that self-heals via 13j's 60-day drop-out (or an explicit sign-out). The two are
never conflated.

**VERDICT: HOLDS.** No usable custody survives (both items are `ThisDeviceOnly`, hardware-bound);
the restored device presents a FRESH device identity minted by construction; and it cannot be
mistaken for the old device — the id discriminator is always fresh, and a restored non-zero cursor
makes it a well-defined RETURNER (corner 37), reconciled at its first round, tracked as its own
`device_cursor` row. Corner 9 ("same-Mac erase-and-restore proven in the drill") is the live
evidence. No finding.

## Q10 — brute-forcing the passphrase at the shipped KDF floor

*Brute-force the encryption passphrase against a stolen key file at the shipped KDF floor. At
what passphrase length is the cost real? (`PassphraseKDF.Floor`; 17n)*

**The parameters, confirmed.** The passphrase wrap is the ONLY brute-forceable wrap (the recovery
wrap is 128-bit by construction, R-5 — `PassphraseKDF.swift:8–9`). Devices MINT the v1 default:
Argon2id m=64 MiB, t=3, p=1, 32-byte output (:73–83) — RFC 9106's second recommended option's
memory/time class. The read-time FLOOR (`Floor.production`, :106) is m=19 MiB, t=2, 16-byte salt
(the OWASP Argon2id floor); `validateFloor` (:194–207) is called at every READ site, so a
DOWNGRADED descriptor (a compromised server or tampered key file declaring cheaper parameters) is
refused BEFORE any derivation. The passphrase is NFKD-normalized before hashing (:165). **Note the
offline attacker cannot USE the floor to cheapen the attack** — a stolen key file's wrap was made
with the wrap's OWN descriptor (the default m=64 MiB, t=3), and a candidate key derived under
cheaper parameters simply won't unwrap; so the attacker is stuck at m=64 MiB / t=3 per guess. The
floor's job is to stop a downgrade on the honest client, not to bound the attacker's per-guess
cost (which is the higher default).

**The cost is entropy-driven — length alone is a poor proxy.** Argon2id at m=64 MiB / t=3 is
memory-hard: each guess needs 64 MiB of fast memory for its duration, which caps parallelism (a
24 GB GPU holds ~375 concurrent instances; a large GPU farm reaches on the order of ~10^6–10^7
guesses/s — an ASSUMPTION for scale, not a precise figure; exact attacker economics would sharpen
the dollars, not the conclusion). Against that, a well-funded adversary can exhaust roughly ~2^47
guesses in a year. So, for a RANDOM passphrase:
- ~8 random alphanumeric chars (~48 bits) — BORDERLINE (about a year at the assumed farm scale;
  a bigger adversary breaks it sooner).
- ~10 random alphanumeric chars (~60 bits) — real (~10^5 years at that scale).
- ~12 random alphanumeric chars (~71 bits), or 5+ Diceware words (~65 bits) — comfortably real.

**The residual this exposes — a LENGTH floor is not an ENTROPY floor.** Closeout consideration 4
already discloses the class ("The encryption passphrase has no strength floor … a stolen backup +
key file is an offline target at a modest KDF cost → 17n") and 17n owns the fix ("a 12-character
floor at every setting door"). The stress-test refinement worth recording is that **17n's 12-*char*
floor is a partial mitigation, not a strength guarantee**: a HUMAN-CHOSEN 12-character passphrase
(a common word + digits, a familiar phrase) can carry ~30–40 bits of real entropy — which the
memory-hard KDF slows but does NOT save against a funded offline attacker — while a RANDOM
12-character passphrase (~71 bits) is safe. So the honest answer to "at what length is the cost
real": ~10–12 characters IF random (or 5+ Diceware words); for human-chosen strings, length does
not guarantee it. The high-security anchor is the twelve WORDS (128 bits, always real) — a user
who fears the offline attack should trust the words, or set a high-entropy passphrase.

**VERDICT: HOLDS — with the disclosed residual owned by 17n, plus a refinement on 17n's scope.**
The KDF itself is sound: memory-hard Argon2id at m=64 MiB / t=3 by default, a downgrade-proof
read-time floor, a versioned descriptor honored on unwrap, the recovery wrap high-entropy by
construction. No design defect. The one thing to carry to **17n**: a 12-character LENGTH floor
does not equal an entropy floor — consider pairing it with a strength/entropy check (a zxcvbn-style
meter or a Diceware suggestion) or explicitly documenting that the strong-security path is the
twelve words, so the length floor is not mistaken for a guarantee against a weak human-chosen
passphrase. Severity: low (an offline attacker needs BOTH the stolen key file AND a weak
user-chosen passphrase; the words remain the strong anchor), and the class is already disclosed
and owned.

---

## VERDICT SUMMARY

| Q | Topic | Verdict | Owner (where a residual) |
|---|---|---|---|
| 1 | key proof's server-side retention surface | **HOLDS** | disclosed; 13y (per-request challenge) |
| 2 | attacker nine arms + a tenth | **HOLDS** | NIT: add a `sync_reencrypt`-under-old-proof pin (B2 / B4) |
| 3 | pre-rotation straggler vs horizon + guard | **HOLDS** | 13y (one horizon source of truth); Phase 12 (poison row); + a deploy-checklist caveat (re-apply the overlay after an 11 redeploy) |
| 4 | same-second passphrase + Castle entries | **HOLDS** | her ratify bundle (ledger 61's Done wording, PROVISIONAL) |
| 5 | recovery-wrap digest; forged digest | **HOLDS** | NIT: RFC-3394-determinism dependency (only if the wrap primitive changes) |
| 6 | iCloud Keychain reset, three devices | **HOLDS** | 17m (Re-link door) + QUESTIONS #90 |
| 7 | fresh library cannot sync without a typed secret | **HOLDS** | — |
| 8 | pre-Replace-All-Keys backup restore | **HOLDS** | 13x (same-Mac older-key open-a-copy door) |
| 9 | Time Machine wipe-and-restore | **HOLDS** | — |
| 10 | brute-force passphrase at the KDF floor | **HOLDS** | 17n — with the refinement that a 12-char LENGTH floor ≠ an entropy floor |

**Ten HOLDS, zero FINDINGs, zero OPEN.** Every question the design answered was traced to the
code, the pin, or the SQL; no invented findings. The pass surfaced three things worth the
orchestrator's routing, none of them a design hole: (a) a NIT suite-completeness pin for Q2's
tenth arm (`sync_reencrypt` under the old proof — the one data RPC no attacker arm fires; it holds
by the shared gate); (b) an operational caveat for Q3's deploy checklist (re-applying the
maintenance completion-guard overlay after any `11_pre13x_postures.sql` redeploy, since the guard
is a body change to the same signature that an 11 redeploy silently reverts); (c) a scope
refinement for Q10's owner 17n (a 12-character LENGTH floor is not an ENTROPY floor — a
human-chosen 12-char passphrase can still be brute-forceable; pair it with a strength check or
lean on the twelve-words guarantee). Everything else is a HOLDS with its disclosed, already-owned
residual (13y · Phase 12 · 17m/#90 · 13x · 17n · her ratify bundle).
