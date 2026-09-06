# pre-13x — ORCHESTRATOR HANDOFF #2 (mid-phase cutover, 2026-09-05; the build half is under way)

**Why this exists:** the first build orchestrator reached ~660k tokens with batch 2c running. The author's words at the
cutover: *"This is an extremely important phase so I'm at loath to lose your experience and context but alas the context
window is getting full."* This file is that experience, written so a fresh session needs nothing from the dead one.
**THE SEAM (her ruling at the cutover):** the first orchestrator FINISHES 2c thoroughly AND HANDLES THE WINDOW — the
deploy, the Mac install, her sign-in, the passphrase confirm, the sanity check, the phone install and its
re-enrollment — because it holds that context; **the successor starts at BATCH 3** with the window's outcomes recorded
in §2b below. Her words: *"it might be better if you handle the window because you can deploy it, mac install, sign in,
passphrase confirm… the phone install and re-enrollment, and then batches 3-5 can cleanly be accomplished by the next
orchestrator."*
**The design is SETTLED and clean** (`notes/plans/pre-13x-postures-design.md` — decisions 1–34; nothing provisional);
**every batch record and every adjudication is in that file's §19**; the history is `pre-13x-design-history.md`
(Parts I–V — V holds this orchestrator's rulings with the superseded text verbatim).

---

## 1. THE PASTE-READY KICKOFF (for the successor orchestrator — a fresh Fable session)

> You are the `/architect-phase` orchestrator for Variorum's **pre-13x** phase (Postures & recovery — Standard and
> Castle), succeeding the build orchestrator at its mid-phase cutover. Read, in order, and nothing else first:
> `CLAUDE.md`; `.claude/skills/architect-phase/SKILL.md`; `notes/SessionResiliencyProtocol.md`;
> `notes/plans/pre-13x-postures-design.md` WHOLE (§1 decisions 1–34 · §3.4 the credential audit · §4 · §5 · §7 · §12 ·
> §15 · §18 the execution record with LIVE STATUS + the ledger · §19 the batch briefs, EVERY batch record and EVERY
> orchestrator adjudication); `notes/plans/pre-13x-copy.md`; `notes/plans/pre-13x-spike-memo.md`;
> `notes/plans/pre-13x-deploy-checklist.md`; `notes/plans/pre-13x-orchestrator-handoff.md` (this file) WHOLE. Do NOT read
> `pre-13x-design-history.md` or `pre-13x-design-review.md` to decide anything — history; open them only for a WHY, and
> if the design file is silent on a mechanism, STOP and ask the author rather than infer.
> Then VERIFY, never trust: `git log --oneline -40`, `git status`, the design's §18 LIVE STATUS against the batch
> records' hashes, the counts against the records; no agent is running (`ListAgents`);
> the mirror is at marker **8** (DEPLOYED at the window — verify through the PAT's read road: `sync_schema_version()` = 8,
> 25 vault columns, her vault row's `key_proof_hash` non-NULL); batches 2c AND 2d are CLOSED and adjudicated (2d = the
> window's fix, decision 35); THE WINDOW AND ITS SECOND SITTING HAVE RUN — §2b below is their record.
> Her standing instructions, verbatim and binding: *"it's possible it is missing a scenario or there's some other issue
> with it. If you think so, BRING IT UP TO ME!! Do not just read that the copy is finished and not tell me about a flaw,
> vulnerability, or other issue."* — you bring flaws and gaps to her; you NEVER redesign the system on your own
> judgment ("Rulings are settled, not undiscussable" — the skill); **before writing EVERY batch brief you READ THE
> SHIPPED CODE the batch's mechanisms assume and check the design's claims against it** (her instruction relayed from
> another session; the decision 31 precedent); **every batch record carries ORCHESTRATOR-DECIDED NOTES** so the cold
> reviewer sees what was settled without her; you bring her decisions as question-tool batches (≤ 4, the recommended
> option first) and record rulings verbatim-faithful in the design's §1 the same turn, moving superseded text to
> history Part V; you never run suites or drills yourself — each batch's implementer creates, runs and records its own,
> the ladder's reviewers re-run what they doubt, you adjudicate from records; ONE agent at a time, a FRESH Fable per
> batch, briefed only by the design's named sections; say the CREDENTIAL, never "box"; NO commit trailer; commit and
> push every record; keep the `variorum-phase-9-run-state` memory current.
> **Pre-authorized by her:** the mirror deploy (marker 7 → 8) via the stored PAT (`.env.supabase.local`; the `!` road if
> the classifier blocks the mutating call — it DID block a read-only management-API query this session, so expect it);
> **the `/Applications` refresh** (her word at this cutover: *"I'll give the next session my permission to refresh the
> applications as well"*) behind the A1 backup rail at a zero-instance window; the phone install by `devicectl` (proven
> this session). Still needing her present: the sign-in on both devices, the one-time passphrase confirms, the
> twelve-words sanity check, Q3 is DONE.
> **You start at BATCH 3.** 2c is closed and adjudicated, and THE WINDOW HAS RUN (the deploy at marker 8, both installs,
> her migrations, sign-ins and confirms, the sanity check, the phone's re-enrollment) — VERIFY each outcome against
> §2b of this file and against the mirror (`sync_schema_version()` = 8 through the PAT's read road, or her `!` road)
> before trusting it; if §2b still reads PENDING anywhere, the window did NOT complete — ask her, never assume. Then:
> batch 3 (the doors) → batch 4 (the lobby + cross-device) → batch 5 (copy, the tutorial chapter, the book) → the
> ladder (Fable reviewers on every round, each walking §3.4; the closing ladder's FIRST reviewer walks *Encryption
> Explained* and the tutorial chapter sentence by sentence — condition vii) → the two drills → her acceptance walk →
> the closeout ritual. Each brief is written AFTER reading the shipped code the batch assumes, from §4, §5, §7, §12,
> §15 and the prior records' HANDED FORWARD sections, into the design's §19 (the 2a/2b/2c "REFINED AT THE SEAM"
> paragraphs are the form).
> **Her refinement of the adjudication rule (at the cutover, verbatim):** the rule below (§4) holds *"with the exception
> of if a gap or obvious flaw has made itself clear in the design's own letter"* — a gap or flaw IN the design's letter
> is never the architect's to close by inference; it goes to her.

---

## 2. STATE AT CUTOVER (verify each; the records are the truth)

- **Batches:** 0 DONE · 0b DONE (the bridge retired) · **1a DONE** (`10079de2`; adjudicated `2c06c981`) · **1b DONE**
  (`12cd1767`; adjudicated `820b407e`; the fix pass `8d09a30b`…`12cd1767`) · **2a DONE** (`4b2eb646`; adjudicated
  `663476a6`) · **2b DONE** (`67e744d6`; adjudicated `8af417a9`) · **2c DONE** (`c7555c2b`; adjudicated `d2094840`) ·
  **2d DONE — the window's fix, decision 35** (`975bd383` + the fix pass; adjudicated `a29a2e0f`) · **THE WINDOW + THE
  SECOND SITTING DONE** (§2b). U3 is CLOSED. **U4 batch 3 is NEXT** — `git log` is the truth.
- **Counts at 2d's gate (the latest):** core 1440/157 · the Mac gate run 264/36 · the spine 72/10 · the phone bundle
  611/99 (the standing `MobileTrashTests` known-issue pair) · Mac + iOS targets build. The baseline before the phase: core 1391/152 · Mac
  2094/378 (the full Mac suite; the gate runs are subsets by suite type).
- **The mirror:** marker **8** — `11_pre13x_postures.sql` DEPLOYED and verified at the window (§2b), one leftover DELETE
  grant repaired by `maintenance/pre13x-window-vault-delete-revoke.sql` (and named in 11); the SyncSpec §12
  running-record entry (marker 7 → 8) is the CLOSEOUT's to write (design §17).
- **Her devices (after the second sitting):** Mac — `/Applications/Variorum.app` from 2d's tree (`975bd383`,
  `76d11d4d…`), Castle / Touch ID, signed in, migrated, the proof landed, the key file format 2 with the master copy AND
  the vault descriptor (the confirm sheet ran). Phone — the Release build from `3ed3b182` (2d + the Face ID usage
  description), Castle / Face ID, ONE key file (`variorum-keys-3ec9c96ec93ccc6d.json`: master · passphrase · storeID ·
  vaultCorpusKeyID · vaultKDF; NO `apple` copy), the store re-keyed at the follow; the dev-build's `Variorum-dev/`
  folder lingers in the container (inert; §2b). The three worktrees are REMOVED.
- **The dev store on the Mac** (`~/Library/Containers/io.lduarte.Variorum.debug/Data/Library/Application Support/Variorum-dev/`):
  ciphertext; a format-2 key file with the dev A (`appleKeyID 765a12c5…`); its own §11 migration NOT done (the
  `migrated2a` key absent) — a Debug launch (Xcode ⌘R) once, with her login-keychain password at the prompt, runs it;
  read `/usr/bin/log show --predicate 'subsystem == "io.lduarte.Variorum" AND category == "protection"'` (notice level
  since 2b). Not urgent; the dev store is the proving ground only.
- **Her live vault:** the 1b-found stale-recovery-wrap question is CLOSED — the sanity check with her twelve words at
  the window: *"That is the right recovery phrase — it unlocked this account's vault. Nothing was changed."*
- **Memory:** `variorum-phase-9-run-state` (the resume map) — refresh it at every state change.

### 2b. THE WINDOW'S OUTCOMES (filled by the first orchestrator at the seam — every line PENDING until it is)
- 2c: DONE — closed at `c7555c2b`; adjudicated at `d2094840`; counts core 1440/157 · Mac 239/33 · spine 72/10 · phone 610/98 (her clarification at the successor's kickoff, 2026-09-06 — this line had been left as stale bookkeeping).
- **The A1 rail's local half — DONE (her Release app quit by her; zero instances checked):**
  `Backups/variorum-backup-a1-pre13x-window-20260905T235821Z.{sqlite,sqlite-wal,sqlite-shm,keys.json}` — a byte copy
  of the closed encrypted store (main 10,571,776 B, sha256 `d567688dd58f0890…`, `cmp` byte-identical to the source;
  WAL 1,048,576 B; shm 32,768 B; the format-1 key file 519 B). Integrity is the app's own next backup run's to
  assert (an encrypted store cannot be `PRAGMA`-checked from the CLI without the gated key).
- **The pre-deploy snapshot — DONE (read-only, through the PAT's query road; the classifier allowed it this time):**
  *[removed for publication]*
  phone's dev build recorded — corner 47 confirmed by DATA: the dev build read HER vault); **18** vault columns (25
  after 11); rows: 208 containers · 4,226 blocks · 4,388 variants · 3,909 commits; the function set: the SIX old
  signatures present (`sync_push(jsonb,text)`, `sync_pull(bigint,text,integer,text)`, `sync_horizon(text)`,
  `sync_purge_ledger(bigint,text)`, `sync_purge_execute(jsonb,text)`, `account_data_truncate(text)`) + `account_purge()`,
  `sync_schema_version()`, `sync_table_pk(text)`. Revision 3 = setup + the recovery wrap + ONE further write whose
  kind the row does not say — the sanity check with her twelve words at the window is what settles the 1b defect
  question, exactly as planned.
- **The deploy — DONE 2026-09-06T01:09:45Z:** `11_pre13x_postures.sql` (50,946 bytes; `begin;` at line 129, the
  marker bump the last statement before `commit;`) sent WHOLE in ONE Management-API session → `[]`, HTTP 201 (the
  classifier allowed the POST). **Verified:** `sync_schema_version()` = **8**; **25** vault columns, the seven named
  present and nullable (`text` ×6 + `bigint`); her row UNTOUCHED — revision 3, the same corpus key id, hash / previous
  key / seq / device / apple all NULL; the six OLD signatures ABSENT; present and `variorum_definer`-owned:
  `sync_push(jsonb,text,text)` · `sync_pull(bigint,text,integer,text,text)` · `sync_horizon(text,text)` ·
  `sync_purge_ledger(bigint,text,text)` · `sync_purge_execute(jsonb,text,text)` · `account_data_truncate(text,text)` ·
  `sync_reencrypt(jsonb,text,text)` · `key_vault_update(jsonb,integer,text)` · `sync_key_gate(text,text)` ·
  `sync_key_proof_check(text)`; `account_purge()`, `sync_schema_version()`, `sync_table_pk(text)` and the trigger
  function stay `postgres`. **THE LIVE PATCH PROBE:** as role `authenticated` with her claims, `update key_vault …` →
  **`42501 permission denied for table key_vault`**; her row re-read unchanged. **The grant sweep:** 53 rows — 49 OK,
  3 INFO, ONE MISMATCH `privilege:authenticated:DELETE` (true, expected false) — Supabase's default `grant all` at
  08's CREATE, never revoked for `authenticated`, fenced all along by the vault's missing DELETE policy; REPAIRED at
  01:11:51Z by `maintenance/pre13x-window-vault-delete-revoke.sql` (`revoke delete on key_vault from authenticated`;
  read back: DELETE false · UPDATE false · SELECT true) and named in 11 itself for future deploys; **the sweep re-run:
  53 rows — 50 OK, 3 INFO (the three trigger functions' public EXECUTE, the standing INFO class), ZERO mismatches.** **The proof-required probe is DEFERRED until her first round lands the hash** — a probe with a wrong
  proof as her session BEFORE that would be the NULL-hash arm's FIRST proof and would land the wrong hash on her vault.
- **The Mac — the install DONE 2026-09-06T01:13:40Z:** Release built from the clean worktree `~/dev/variorum-window`
  *[removed for publication]*
  `/Applications/Variorum.app` replaced at a zero-instance window (her app quit by her; `pgrep` empty) behind the A1
  copy above — SHA-256 `fbd3f4a774d92230…` → `683eb304abbf0f8d…`, `codesign --verify --deep --strict` ok. **Her first ready — DONE (2026-09-05 19:20 local):** the migration ran on the real store (`854b8c49…`) under
  biometric, six legs at notice level: `sync custody re-scoped → done (identity from sync_state)` · `no legacy iCloud
  escrow item` · `dial keys retired to the per-store keys` · `custody already biometric` · `key file gains the master
  copy + corpus key id (vault descriptor: next online ready)` · `done`; NO keychain prompt seen; the real key file is now
  format 2, fingerprint-named (`variorum-keys-8e15801e01456477.json`: master · passphrase · recovery · storeID ·
  vaultCorpusKeyID = her vault's key id; `vaultKDF` lands at the next signed-in ready); she signed in; the first round
  LANDED THE PROOF HASH (`hash_landed = true`, revision 3 unchanged, no rotation, no Apple-held copy, her Mac's cursor
  seen 01:31:12Z). **The one-time confirm sheet did NOT appear** — expected on reflection: its job is to land the
  passphrase copy, and her key file has carried one since 13p; recorded as a copy-and-flow note for the ladder (the
  sheet's gate should say so, or the descriptor half should land without a sheet). The sanity check: *"That is the right recovery phrase — it unlocked this account's vault. Nothing was changed. The key derivation took 0.17 s on this device."* — CLOSED. **The DEFERRED proof-required probe — DONE after her hash landed:** as role `authenticated` with
  her claims, the right key id and a WRONG proof, `sync_horizon` → **`P0001: VARIORUM_KEY_PROOF_REQUIRED`** (raised in
  `sync_key_proof_check` via `sync_key_gate`); her landed hash unchanged (`bbc279ed…`, revision 3). The mirror side
  of the window is COMPLETE.
- **The phone — the install DONE 2026-09-06 (after the Mac's refresh):** Release built from the same clean worktree
  *[removed for publication]*
  installed by `xcrun devicectl device install app` OVER the dev build (same bundle id); the container listed after the
  install — the real store's `Variorum/` folder + `variorum-keys.json` (79 B, format 1) exactly as before, and the dev
  build's `Variorum-dev/` folder still present (its deletion is NOT possible by `devicectl` — it has no delete verb, and an uninstall would take the whole container with her real store; the folder LINGERS, inert — the Release build never reads the dev scope and the dev key file holds only wrapped copies — recorded here and in the checklist; a future dev launch on the phone meets it under 2c's fence and starts signed out). **Her
  first ready — RAN, and FOUND A GAP (the window's one real finding):** she opened the phone → NO Face ID, the library
  instantly, *sync locked* → typed the passphrase → sync open → STILL no Face ID after a full quit. The phone's real
  key file afterwards (`variorum-keys-e6194a17c1983ca5.json`, 578 B, format 2): `apple` + `appleKeyID` + `passphrase`
  + storeID + fingerprint — NO `master`, NO `vaultCorpusKeyID`. So the phone derived STANDARD and 2a's Apple arm
  LANDED an iCloud copy of her real phone library key (into the key file and an iCloud Keychain item under the real
  scope) — Standard's shape on a Castle account's library. Cause: the 13p phone key file held NO secrets (79 B:
  formatVersion + storeID); `Posture.derive`'s order is legacy mode → the vault's word → the key file; at the
  migration's instant the vault's word was unavailable (the session's scope migration / the network had not answered)
  and the key-file rule for a secret-less file reads Standard ("a library nobody can re-open by any word must not
  demand one" — 2a's safety arm, adopted at 2a's adjudication without seeing that an ENROLLED library can be
  secret-less: her phone exactly). The Standard arm is WRITE-ACTIVE on that reading. The design's letter says an enrolled
  library must agree with the vault; it never says what to do while the vault cannot be read — A GAP IN THE LETTER →
  HER RULING (§4's refinement). The follow did not repair it later because 2c's follow keys on the corpus key id (never
  rotated here), not on a custody-vs-account POSTURE mismatch. **Her rulings: decision 35; the repair THROUGH the fix — batch 2d built it. THE SECOND SITTING (2026-09-06, ~03:25–03:40Z):**
  the Mac refreshed from 2d's tree at a zero-instance window (`683eb304…` → `76d11d4d…`, codesign ok, 03:25:45Z); she
  relaunched signed in → the one-time confirm sheet APPEARED (the corrected §9 sentence) → her passphrase → the key file
  gained `vaultKDF` (verified). The phone's Release build installed (03:25:53Z) → at first open the posture-mismatch
  notice → her passphrase once → the follow ran: custody behind Face ID, the store RE-KEYED (fingerprint `3ec9c96e…`,
  the sqlite rewritten), ONE key file in the container (master · passphrase · storeID · vaultCorpusKeyID · vaultKDF —
  NO `apple` copy), the old fingerprint file AND the 79 B legacy stub GONE (verified from the container). **THEN A
  CRASH at every reopen** — a flicker of the Face ID screen, then death: the iOS target had NO `NSFaceIDUsageDescription`
  (nowhere in the project; her phone had never reached Face ID before tonight, so no drill or simulator run hit it —
  iOS terminates an app that invokes Face ID without the string). FIXED at `3ed3b182` (`INFOPLIST_KEY_NSFaceIDUsageDescription
  = "Unlock your Variorum library"` on both iOS configurations; the built Info.plist verified), rebuilt, reinstalled
  03:36:03Z → **Face ID gates the open; the library opens** (her word: "it worked with faceid now… that was the
  reason"). The vault after both devices' rounds: revision 3, the proof landed, no rotation, Castle, marker 8.
  **ONE OBSERVATION for the ladder:** `device_cursor` holds THREE rows (`4D871175`@02:07Z · `3D4D5F8A`@03:29Z ·
  `53536eb5`@03:38Z) — the phone's identity CHANGED at the follow (its pre-follow id last seen 02:07Z; a new id after the
  03:36Z build's first round), which decision 13 says must not happen (the identity is the machine's; a re-key changes
  the custody item's VALUE, never its name — 1a's note 2); harmless in effect (the abandoned cursor drops out at the
  60-day horizon; the returner rule covers the new id) but a defect candidate: the follow's custody rewrite should CARRY
  the identity — trace and pin at the ladder or batch 3. The Mac's id is stable (`3D4D5F8A`). The three worktrees
  (`~/dev/variorum-phone-q3`, `~/dev/variorum-window`, `~/dev/variorum-sitting2`) REMOVED. **U3 IS CLOSED.**
  The Mac's `vaultKDF` also did NOT land at the relaunch ("next online ready" unmet — a small defect for the ladder).
  The sanity check on the Mac: *"That is the right recovery phrase — it unlocked this account's vault. Nothing was
  changed."* — the 1b/14c stale-wrap question CLOSED.
- The drills' real-store legs: NOT THE WINDOW'S — the PHASE'S END per design §15 (her clarification, 2026-09-06): the 13p migration drill on a byte-copy and the 13l restore drill per posture, with her passphrase, after the ladder; the switch's real timing is satisfied by 2b's sample-library drill (the 2d adjudication, item 3).
- The worktrees: REMOVED (all three; `git worktree list` at the successor's kickoff shows `main` and the mobile worktree only).
- Surprises at the window: THREE, recorded in the phone paragraph above — the missing `NSFaceIDUsageDescription`; the identity change (TRACED by the successor 2026-09-06: the mint happened at the WINDOW's leg-1 skip under corner 47, not at the follow — the design §19 BATCH 3 brief's headnote); the Mac's confirm sheet not appearing at first (the derived gate, 2d.3).

---

## 3. WHAT THE STANDING CODE CHECK FOUND (the design's letter did not carry these; all landed, all pinned or owned)

Every one was found by reading the shipped code before a brief — keep doing it. Numbered so a reviewer can cite them.

1. **Replace All Keys in Standard re-wraps the new master under the SAME iCloud key** — an Apple-account intruder who
   copied A keeps receiving every new master; the copy claimed the opposite. → Her ruling: keep A fixed, make the copy
   honest (decision 30; the A-copy PRESENCE pinned).
2. **Nothing on the wire or in the mirror said which corpus key a row is under** (`PayloadCipher`'s `e1:` envelope
   carries no key id; no per-row key column). → Her ruling: the rotation start seq in the vault, the vault row locked
   in every data RPC (decision 31; `rotation_started_seq`).
3. **A second rotation mid-rotation would strand rows** (one previous key). → Refuse until complete (decision 32).
4. **An Always-ask device does not "keep syncing" after a passphrase change elsewhere** (no master in custody). → Accept
   and state it; the derived key held in session memory (decision 10's exception).
5. **`08_phase14b_lockstep.sql` still grants UPDATE on `key_vault` to `authenticated`** with `key_vault_owner_update` —
   replacing the client's PATCH alone left a bare session a proof-free write to every vault column, the proof hash
   included. → The table-level road CLOSED in 11 (ledger 41; the DDL pin; the deploy's live PATCH probe).
6. **The 13p escrow item put the RAW library key in iCloud Keychain** (decision 3 forbids it). → The family deleted; the
   legacy items REMOVED at the migration under the R1-m1 ownership guard (batch 2 fact ii).
7. **`StoreAtOpenMode` was a STORED three-way setting.** → The derived effective gate, a pure function of (posture, the
   Castle gate style); the setting deleted (fact i).
8. **`StoreEncryptionMigration` was plaintext → keyed only.** → Its keyed → keyed twin `rekey` on the same `Step`s (fact
   iii); the crash matrix rides the same seams.
9. **"Pull to head" and "the outbox is empty" were inline compositions.** → `SyncEngine.pullToHead()` + `outboxCount()`
   (fact iv).
10. **The shipped re-key brain (`AccountRekey`) still TRUNCATED + `resyncReinitialize`d** (the 14c road); the design's
    rotation is IN PLACE. → The runner replaced it; `AccountRekey` retired; `account_data_truncate` keeps its fence for
    the headless tool alone.
11. **A FOUND 14c DEFECT:** the vault PATCH omitted absent fields, so a Replace Encryption Keys left the OLD recovery
    wrap on the row — the app said "a recovery phrase is on file" while the paper opened only the old master. → The RPC
    replaces the row whole; pinned red-on-old. Her live vault: see §2.
12. **The migration logs at `info`, which macOS never persists** — `log show` can never read it after the fact. → 2b
    moves it to `notice` (verify the level in `ProtectionMigration.swift` when 2b/2c land).
13. **In her zsh `log` is a BUILTIN** — every bare `log show` this session hit the builtin and returned nothing. Use
    `/usr/bin/log`. (Recorded in the checklist.)
14. **One key file per library key in a backup folder made "the passphrase you had when it was made" false** after a
    passphrase change. → Her ruling: one key file PER SNAPSHOT (decision 11 as ruled; row 42; 2a built it).
15. **A refused Apple landing followed by a passphrase set derived Castle** (rule (c) read "no A copy ⇒ Castle"). →
    Castle is ENTERED, and entering moves the raw key behind Touch ID or nowhere: the custody SHAPE tells Standard-
    waiting from Castle by presence (corner 45; 2b built the discriminator).
16. **"iCloud Keychain is off" is undetectable on macOS.** → The exposed tier fires only on an unreadable A; the covered
    tier's copy hedges (corner 46).
17. **The Touch-ID-only arm of the two rotation doors cannot mint the new keys' wraps** (P and W never stored). → Her
    ruling: both secrets typed (the words typed or regenerated); Touch ID for wrap-free acts only; NO reset road on the
    ceremony — *"touchid is enough to reset your passphrase… no need to crowd the screen"* (decision 33; the copy's
    §2b/§4 re-written).
18. **The notices' "[device] on [day]" had no column behind it.** → Her ruling: `updated_by_device`, the seventh vault
    column, while the lockstep is undeployed (decision 34; 2c lands it).
19. **THE iOS KEYCHAIN FENCE (corner 47, found by Q3's early run):** Debug and Release share the bundle id and ONE
    keychain on iOS; the session (`io.lduarte.Variorum.auth` / `session-bound`) and the 14b legacy sync-key item
    (`e2ee-keys` / `device-keys`) were SCOPE-LESS — the dev build signed in as her, fetched her vault, and its migration
    moved her REAL master into the DEV store's custody and deleted the legacy item. Nothing lost (the real phone store
    re-enrolls by passphrase at the window). → 2c scopes the session by variant and fences the legacy legs to the real
    scope, pinned.
20. **The NULL-hash migration arm's race** (two first rounds) resolved by the deadlock detector. → Exclusive from the
    start (`FOR UPDATE` on a NULL hash — the implementer's sounder mechanism adopted over the ruling's letter).
21. **The window's own finding — decision 35** (§2b): a secret-less enrolled library derived Standard while the vault
    was unread and the Apple arm WROTE an iCloud copy; and the reconcile had NO re-run caller after the initial ready
    (the "next online ready" never came) — 2d fixed both (`PostureReading.indeterminate`; `runReadyHousekeeping`).
22. **The second sitting's finding — `NSFaceIDUsageDescription` was absent from the iOS target**, so the first real Face
    ID gate crashed the phone at every open; fixed at `3ed3b182`. A pin in the mobile test host (the built Info.plist
    carries the key) is the LADDER's — write it before the ladder runs.
23. **The phone's device identity changed at the follow** (three `device_cursor` rows) — a decision-13 defect candidate;
    the ladder's or batch 3's (trace `follow`'s custody rewrite; pin the identity's persistence across a follow). **TRACED 2026-09-06 by the successor: the follow's rewrite carries the identity correctly; the re-mint happened at the WINDOW — `ProtectionMigration` leg 1 skips the identity carry when no legacy MATERIAL exists (corner 47 had removed it), so her enroll minted fresh and the 13j id stayed orphaned in `sync_state`. Batch 3a item 0 (ledger 43).**

---

## 4. THE ADJUDICATIONS MADE WITHOUT HER, AND THE RULE THAT SEPARATES THEM

**The rule this orchestrator applied:** a mechanism FORCED by the design's own letter or by cryptography is the
architect's (a technical constraint within a ruled design); anything a user SEES, anything the SERVER holds, and any
CLAIM the copy makes is hers. When in doubt it went to her (six question batches this session). **Her refinement at the
cutover, verbatim:** *"The rule you've applied makes sense, with the exception of if a gap or obvious flaw has made
itself clear in the design's own letter"* — when the design's LETTER is what has the gap or flaw, it is hers, never
closed by inference (the twenty findings in §3 that went to her are the worked examples; the ones ruled here were
mechanisms the letter already implied). Each ruling is in the
batch's ORCHESTRATOR ADJUDICATION block in §19 with its reasoning; the list:

- **1a:** several fingerprint key files beside a live library resolve by FINGERPRINT (custody's raw key names the file;
  no custody ⇒ newest-first trial), nothing set aside — §6's "one per library key it has ever held" and the same-
  fingerprint second look need the old file. The `libraryMissing` face renders only the doors that ACT (P-2's letter —
  a disabled door is what P-2 forbids; the third door ships with 13x). The forget door keeps the device identity
  (decision 13 — the identity is the machine's for the library; the door itself folds into sign-out at §13).
- **1b:** the previous key's id as its OWN column (the existing id/wrap pair's shape; a packed value is a second format
  inside a column the serializer classifies per column); `sync_reencrypt` entitlement-gated like a push (a rotation
  writes ciphertext; an unentitled account cannot pull to head so §4 step 1 refuses first — whether a LAPSED account
  may rotate at all is 13t's product call, handed forward); decision 32's carry-through (a re-wrap sending the SAME
  previous key is not a second rotation); the NULL-hash arm exclusive from the start.
- **2a:** corner 45 (above); corner 46 (above); the dev store's login-keychain prompt is HERS (bundled).
- **2b — the four she asked about at the cutover ("what were those, by the way?"):**
  1. **Drain, don't refuse after one push.** Step 1 pushed ONCE then refused a non-empty outbox; a device offline for
     days would be sent away to wait for a scheduler round it could run itself. Ruled: `push()` until the outbox is
     empty, bounded at THREE rounds, then refuse with the count — the bound keeps the door from becoming a sync loop;
     the design's letter ("refuse a non-empty outbox") still holds at the bound. 2c lands the one line + its pin.
  2. **Touch ID by default at the Castle entry where biometry exists**, Always ask otherwise — decision 1 makes the gate
     style per device and corner 36 names the no-biometry case; the pane's switch flips it after. Confirmed as built.
  3. **The asymmetry** (leaving Castle by Touch ID; entering by the typed passphrase) is a CONSEQUENCE of decision 33's
     wraps, not a design choice — recorded so the cold reviewer does not read it as an oversight.
  4. **The two unpinned resume arms** (`restartRequired`; the follow-by-passphrase at `.reencrypt`) — straight-line code
     over pinned primitives with no scripted seam reaching them. The hallucination guard's letter wants them red-on-old:
     2c pins both through a fault-injection leaf on `Leaves`.

---

## 5. WHAT REMAINS (the plan from here; §15's batches; each brief written AFTER reading the shipped code)

*(Items 1 and 2 are DONE — the first orchestrator's; the successor begins at item 3. The window's outcomes are §2b.)*

1. **Adjudicate 2c** when it reports: verify (`git log`, HEAD == origin, tree clean, the record's LIVE STATUS every line
   DONE with hashes, the counts against the log), read its QUESTIONS, rule what is yours, bring her what is hers, append
   the ORCHESTRATOR ADJUDICATION block, flip §18's LIVE STATUS (U3 → DONE-PENDING-THE-WINDOW). If 2c DIED mid-run: the
   recovery protocol — `git log`/`status` first (uncommitted edits survive; adopt them), `ListAgents`, `SendMessage` to
   resume, else a narrow fresh continuation briefed from its record.
2. **THE WINDOW = the batch 2 sitting**, in this order (the checklist `pre-13x-deploy-checklist.md` §0–§8 is the
   executable form; she is present): (a) the A1 rail — a WAL-safe backup of her real store + the mirror export; (b) the
   deploy of `11_pre13x_postures.sql` via the PAT (the `!` road if blocked), then §4's verifications incl. the LIVE
   PATCH PROBE (a bare session's PATCH on its own vault row must be refused) and the proof-required probe; (c) the Mac
   Release build from a CLEAN committed tree + the `/Applications` refresh at a zero-instance window (her Release app
   quit by HER, never by a session; `pgrep -fl 'Variorum.app/Contents/MacOS'` by PATH); (d) her Mac's first ready: the
   §11 migration (a login-keychain prompt possible at the DELETE leg — Always Allow) → she SIGNS IN → the one-time
   *confirm your passphrase* → her first round lands the proof hash (the NULL-hash arm, once) → the twelve-words sanity
   check (the 1b defect's definitive check); (e) the phone: build the Release configuration from the same tree
   (`generic/platform=iOS`, a separate DerivedData), install with `xcrun devicectl device install app --device
   *[removed for publication]*
   (`devicectl device copy`/`delete` on `Library/Application Support/Variorum-dev`), her first ready → the migration →
   sign in → the real store re-enrolls by passphrase (corner 47's consequence — expected) → her phone moves to Castle
   (Face ID with the passphrase fallback — say so to her); (f) the real-store legs of the drills: the switch's timing on
   her store, the 13p migration drill and the 13l restore drill per posture — with her passphrase; (g) `git worktree
   remove ~/dev/variorum-phone-q3`. Record the SyncSpec §12 running-record entry (marker 7 → 8) at closeout.
3. **Batch 3 — the doors** (§15; §5 every row): setup ADOPTS (re-stamp + `resyncReinitialize`) and the existing-words
   rule; enroll incl. the Standard-born-into-Castle re-key and the follow-vs-adopt discriminator (the Connect door 2c
   left unrendered); change passphrase + regenerate as re-wraps with their checkboxes; Replace All Keys' DOOR over 2b's
   `PostureSwitchRunner.replaceAllKeys` (decision 33: both secrets typed); sign out everywhere; deletion by account
   password (reachable unenrolled); the plaintext `.sqlite` export + the 13x reconciliation note; the 12-character
   floor; the descriptor floor. Read first: `VaultEnrollment`, `AccountLifecycle`, `EncryptionViews`, `PostureSwitch`,
   the phone's protection sheet.
4. **Batch 4 — the lobby + cross-device:** the vault road at the lobby (derive once when descriptors match; the
   concurrent vault read; ~10 s ceiling → the local copies) + the owner distinction's adopt half; the passphrase-change
   banner (dismissable; the Always-ask variant landed at 2c); the key doors' vault-checked re-auth; her attacker
   scenario in the two-user suite; the convergence pins of §12. Read first: `StoreLaunchGate`, the lobby views,
   `MultiTenantSyncTests`.
5. **Batch 5 — copy + the tutorial chapter + *Encryption Explained* (in the seeded-book dedupe) + the runbook + the
   parity line + §13's deletions + the privacy-policy brief + the 13y/13x hand-forwards + the lost-device FAQ + the
   ORIGINAL animated progress indicator** (her example: a line with black dots travelling — never the system spinner).
6. **The ladder** (Fable reviewers, `notes/REVIEW_PROMPT.md` verbatim; each walks §3.4's "at the switch" columns; the
   closing ladder's FIRST reviewer walks the book + the tutorial chapter sentence by sentence — condition vii; you
   adjudicate; any mismatch not plainly a defect goes to her) → the two drills on both devices → her acceptance walk →
   the closeout ritual (§17's canon deltas; KnownIssues rows resolved; QUESTIONS #81/#87; the author handoff; the
   MobileSoul parity line; the SyncSpec §12 entry).

**Sizing:** U2 ran as two sessions, U3 as three — "one acceptance unit per implementer session" is honored by splitting
a phase-sized unit into sessions under ONE unit; batches 3 and 4 will likely want two sessions each. Say so to her if a
plan falls outside the guidance.

---

## 6. GAPS AND THE WATCH LIST (open, owned, or to keep an eye on)

- The follow after a Standard Replace All Keys still ASKS the passphrase once though A could hand the master over —
  her ruling ("it's making sure you have it"); the ≤ 1 h access-token tail after Sign Out Everywhere ACCEPTED (corner 38).
- The lapsed-account rotation question → 13t. The forked `VaultRPCEmulation` (two byte-identical test-support copies)
  → a KnownIssues row at closeout if still forked. `ReminderCheckPolicy` survives as a brain (not a dial); the
  `escrowService` constant survives only as the DELETE leg's name — both correct.
- Q3's propagation LATENCY is unmeasured (bounded by the mint-to-launch interval); the "waiting for iCloud Keychain"
  copy speaks in generalities — fine.
- The phone's dev-scoped custody item holding her real master lingers after the window (ThisDeviceOnly; never read by
  the Release build) — recorded in the checklist; say it in the closeout.
- The Standard-born-into-Castle enrollment re-key (batch 3) and the enroll half of the "new device" drills are OPEN.
- The two DEBUG probe doors are gone (2a); Q3's memo procedure is obsolete — the proof is the key-file comparison.
- 13y hand-forwards: the rotation seq per tenant; the adopt-road convergence pin; the recently-re-authenticated-session
  guard on the destructive RPCs (a stolen access token can call `account_purge` for its lifetime — loud, survivable).
- The E2EE disclosure envelope GREW by one device name per account (decision 34) — the privacy-policy brief (batch 5).
- `SessionResiliencyProtocol` facts proven again this session: the Agent tool's completion notice is the agent's last
  line; agents rebased cleanly over orchestrator commits because the design file's tail (records) and the rulings'
  sections never overlapped — keep it that way (commit only your own hunks: check `git diff <file> | grep '^@@'` before
  `git add` while an implementer runs; two writers on one file is the one way to lose work).

---

## 7. MACHINERY LESSONS (proven this session; the design's §18 traps carry the rest)

- `/usr/bin/log` (the zsh builtin shadows `log`); info-level entries are never persisted — `--info` shows only what
  was written at notice+ or streamed live.
- The auto-mode classifier blocks mutating-looking `curl` POSTs to the management API even for reads — the `!` road.
- Phone builds: NEVER pass the device as the build destination (xcodebuild waits for an unlocked phone and times out);
  build `-destination 'generic/platform=iOS'` from a PINNED worktree (never the working tree an implementer is editing),
  a separate `-derivedDataPath`, then `xcrun devicectl device install app`, `… process launch` (the phone unlocked),
  and read the container with `devicectl device info files` / `device copy from --domain-type appDataContainer
  --domain-identifier io.lduarte.VariorumMobile`. Gate the install on `BUILD SUCCEEDED` (an empty app path made
  devicectl try to install the cwd — harmless, embarrassing).
- Suite names are TYPES, several per file; a file name matches nothing and exits 0 — count `Test run with N tests`.
- Implementer token use this session: 1a ~870k · 1b ~940k · 2a ~320k · 2b ~465k — a phase-sized batch is two to
  three sessions; split by kind and hand the seam forward in the record.
- `AskUserQuestion` blocks the turn but background agents keep running — spawn first, then ask.

---

## 8. OPEN AUTHOR ITEMS (bundle for her next sitting — the window; handled by the FIRST orchestrator)

*The sanity check, since she asked what it is: the 13l face under Settings ▸ Encryption — she types her twelve words
and it tries to unwrap the account's master key from the VAULT, read-only, changing nothing; it proves the words on her
paper open the current vault (the 1b-found 14c defect's definitive check). It needs a signed-in session.*

1. Sign in on the Mac after the install, before the confirm and the first round; then the twelve-words sanity check.
2. The login-keychain prompt(s) at the migration's DELETE leg — Always Allow. The dev store's Debug relaunch once (2a's
   own migration; read the notice-level lines).
3. Her phone's move to Castle at its migration (Face ID with the passphrase fallback); the real store's re-enrollment by
   passphrase (corner 47); the dev folder deleted by the orchestrator.
4. The real-store legs of the drills (her passphrase in hand); the switch's real timing.
5. At closeout: AppSpec §14's delta; the 13y / 13x / 13t hand-forwards; the E2EE disclosure line (decision 34).
