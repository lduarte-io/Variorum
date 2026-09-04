# pre-13x — THE ARCHITECT'S FINAL REVIEW OF THE SETTLED DESIGN (2026-09-04 night, after the clean rewrite)

**Read as:** a review of `notes/plans/pre-13x-postures-design.md` as it stands, by the architect who sat through every
sitting, asked to broaden — holistic first, then scenario by scenario, then a verdict. Its purpose is confidence, not
change: every recommendation below is a completeness or robustness refinement of a ruled shape, never a reversal. Nothing
here is applied to the design file; the author rules, and what she rules is folded in clean.

---

## PART A — THE SYSTEM AS A WHOLE

**What it is, in one paragraph.** Every library file has its own key, raw in one device-bound Keychain item and wrapped
in a public key file under the passphrase, the twelve words, the account's master key, and — Standard only — an iCloud
key that lives in iCloud Keychain and wraps nothing else. The account has one master key and one corpus key, raw inside
every enrolled library, and wrapped on the server under the same secrets (plus the iCloud key in Standard). Proof of the
master gates every write the server accepts except whole-account deletion. Posture is not stored anywhere but the shape
of the server's key record, so it cannot drift. Entering Castle rotates every key a Standard-era copy could hold; leaving
it adds one wrapped copy under the iCloud key and rotates nothing. Users get three acts: re-wrap a secret, replace all
keys, or start the account over. Backups are sealed copies that are never rewritten, and the ceremony says exactly what
they still open.

**Why it holds together.**
- Every credential has ONE place it is raw and a known set of places it is wrapped (§3.2, §3.4). There is no
  "somewhere else" — which is exactly what the 09-03 design lacked and what the master-in-every-backup finding punished.
- The posture law gives every future change a mechanical check: walk the "at the switch" column. A design that can be
  audited by a table is a design that survives its authors.
- The server is provably dumb and now provably inert to a bare session. The proof turns "we can't verify your
  passphrase" from a weakness into a boundary.
- The three-act bundle separates the everyday act (forgot my word) from the compromise act (someone may hold my keys)
  and names the difference honestly. This is where most consumer E2EE products are vague, and Castle's credibility
  depends on not being vague there.
- Backups never rewritten + per-fingerprint key files + the live key file pairing with same-key snapshots = the
  simplest possible backup story that is also true.
- Derived posture + the follow = no per-device posture state to reconcile, no "my phone thinks it's Standard" class.

**Where it is weak (real weaknesses, ranked).**
1. **The rotation's robustness across DEVICE DEATH and OFFLINE EDITS is under-specified.** The switch and Replace All
   Keys are the heaviest acts in the app and the design only says "a persisted marker re-runs a crash to completion."
   Two holes: (a) if the acting device dies for good mid-re-push, rows still under the old corpus key sit on the server
   and no follower can read them — followers replaced their old corpus key at follow, and a NEW device never had it; (b)
   "re-push every row as an ordinary CAS update" bumps every row's `sync_version`, so a device that edited offline
   during the window has EVERY such edit rejected and turned into a "conflict" take — a spray of spurious conflict
   variants after every rotation for any two-active-device user. Neither is a security hole; both are correctness holes
   that would surface in the first month of real use. → R1, R2.
2. **A passphrase change is not enforced on other devices.** A Touch ID device learns of the change online, is prompted,
   may press Later, and its key file keeps the library key wrapped under the OLD passphrase — which still opens that
   device OFFLINE, indefinitely. The copy promises "the old passphrase stops opening anything for anyone who never used
   it." That is false for a deferring Touch ID device with the network unplugged. → R3.
3. **A copied library (AirDrop, manual placement, a restore on a new Mac) carries the original's `device_id`.** Two
   machines then share one per-device pull cursor; the purge horizon reads whichever pulled last; the lagging copy can
   have tombstones purged under it before it saw them. The purged-row ledger fences the worst outcome, but it is a
   self-inflicted returner. → R4.
4. **Entering Castle can leave the user briefly backup-less and leaves a plaintext leak running.** The delete offer
   removes the app's own snapshots; the next post-switch snapshot is not made first. And the 13l scheduled plaintext
   `.md` insurance, if the user opted in while Standard, keeps writing plaintext to disk weekly under Castle — a
   standing violation of "your login password can't read it," self-inflicted but silent. → R5.
5. **Complexity.** Six-step switch, four-entrance Replace All Keys, follow vs adopt, two vocabulary registers. It is the
   minimum the promises need, but every piece must land with its pin or the whole is only as strong as the weakest
   implementer session. The batches are sized right; the review cadence should match (Part D).

---

## PART B — ADVERSARY BY ADVERSARY (what each can reach, in each posture, after every act)

| adversary | Standard | Castle (from birth) | Castle (a switcher) |
|---|---|---|---|
| the server (curious / breached / compelled) | ciphertext + wrapped master copies; the passphrase copy is an offline brute-force target (Argon2id 64 MiB, 12-char floor); structure/timing | same | same — post-switch rows are under a corpus key no old copy holds |
| someone fully in your iCloud | the iCloud key → any copy of the library + the vault (with a session) = everything | nothing | pre-switch copies (their key files carry the old library key under the iCloud key; their insides hold the DEAD master and corpus key) — disclosed as a limit and a way back |
| your Mac's login password | opens Variorum (silent open) — disclosed | nothing: the raw key is biometric-gated or absent; the key file holds P/W/M copies | pre-switch Time Machine copies IF the login password can reveal the iCloud key on that Mac (verify; copy consequence only) — never the live library |
| the account password / a stolen session | sign in; fetch wrapped copies (brute-force target); delete the account; sign out everywhere; change the password — nothing else (the proof) | same | same |
| an old backup alone | nothing (ciphertext + wrapped copies) | nothing | nothing |
| an old backup + iCloud | that backup's contents | n/a | that backup's contents; its keys are dead |
| an old backup + iCloud + the account password | that backup + the loud acts | n/a | that backup + the loud acts; no sync, no key rotation from it (§14.29–30) |
| a leaked passphrase or words alone | nothing without a copy of a library or a session | same | same |
| a leaked secret + any copy of a library or backup | that copy's raw master and corpus key → sync until Replace All Keys | same | same |
| a stolen UNLOCKED enrolled device | everything on it; sync until Sign Out Everywhere + Replace All Keys; can set a new passphrase (Standard, disclosed) | everything on it; the re-auth stops Replace All Keys / posture change / passphrase change | same as Castle |
| a walk-up at an unlocked Standard Mac | read; set a passphrase; enter Castle in your name (recoverable from any enrolled device or by delete + re-setup) — Standard's disclosed class | n/a | n/a |
| any finger enrolled on the Mac account (Castle, Touch ID mode) | n/a | open; set a new passphrase; Replace All Keys — keystone 2; Always ask is the answer (§14.22) | same |

**The Day One test.** Every promise the copy prints was checked against the mechanism under it: the server never reads
(true); Castle's login-password line (true for the live library; pre-switch copies disclosed); Castle's iCloud line (true
post-switch; disclosed pre-switch); "nothing can be reset" (true — the only key anyone else holds is none); "your
account password never touches your keys" (true; its two loud powers disclosed); "an unlocked enrolled device is as
powerful as your passphrase" (true, and it cuts both ways); the backup sentence (true in every case); Replace All Keys
(true including against a breach, because the corpus key rotates); "locking forgets the key" (true). **The one place a
Day One-class gap could reappear is the user's own opt-in scheduled plaintext export under Castle — R5.**

---

## PART C — SCENARIOS (covered / not covered / refinement)

| # | scenario | what happens | verdict |
|---|---|---|---|
| 1 | **Standard → Castle, Mac acts, phone follows** | Mac: pull to head → M′/C′ + vault rewrite under the old proof → re-encrypt every row → re-key its library → gated custody → the offer. Phone at next open: notice; sync refused; types P or W → M′/C′ from the vault → re-keys its own library → pulls | covered — with R1/R2 the re-encryption is robust and quiet |
| 2 | **the acting device dies for good mid-re-encryption** | rows under the old corpus key remain; followers replaced the old key; a new device never had it | **not covered → R1** |
| 3 | **the phone edited offline during the switch** | its pushes CAS-reject against re-pushed rows → every edit becomes a "conflict" take | **not covered → R2** |
| 4 | **two devices enter Castle at once** | both pull to head; both mint; the first vault write wins (CAS); the loser's write refuses BEFORE its re-push, it re-reads → follows | covered (the vault write precedes the re-push — keep that order) |
| 5 | **a device turned off for a year (Standard, enrolled) wakes after the switch** | opens silently (its own Standard custody, pre-switch content); reads the vault → Castle → the notice; syncs only after P/W; its old keys are dead on the server | covered; stated ("until then it opens and reads, does not sync") |
| 6 | **change passphrase on the Mac; the phone next opens by Face ID** | keeps syncing; the post-unlock prompt; Later keeps the OLD copy in its key file — the old passphrase opens the phone offline until the prompt is accepted | **partly → R3** (delete the stale copy on learning; Later defers only landing the new one) |
| 7 | **change passphrase; the phone next opens by passphrase, online** | Rule 1: old refused, new opens via the vault road, local copy re-wrapped | covered |
| 8 | **change passphrase; the phone is offline for weeks** | old opens (it never learned); catches up at the next connection | covered (grace covers ignorance) |
| 9 | **is the change ENFORCED on the other device?** | sync: never blocked (it holds the master, by design); the lobby: enforced online when a passphrase is typed; Touch ID devices: prompted, deferrable | R3 makes the old word physically dead on every device that has learned; the new word is landed when typed |
| 10 | **AirDrop library + key file to a new Mac; type the passphrase (Castle)** | the lobby unwraps the library key from the key file's P copy; the library holds M/C → the device is enrolled by content; signs in → syncs; the raw key is saved to THIS Mac's gated item; the reconcile finds the same owner and key id (or a stale key id → the follow). No new library key is needed — the passphrase IS the credential (keystone 2) | covered for keys; **`device_id` → R4** |
| 11 | **AirDrop the library WITHOUT the key file** | the lobby's dead end (no Touch ID item, no copies on file) — nothing opens; the raw key exists only in the old Mac's Keychain | covered, stated |
| 12 | **AirDrop a Standard library to a Mac on the SAME iCloud** | opens silently (the key file's iCloud copy) | covered |
| 13 | **…to a Mac on a DIFFERENT iCloud** | waiting state → passphrase; opens; this Mac's iCloud key ≠ the account's single Apple copy | covered functionally; **disclosure → R6** |
| 14 | **restore a backup on the SAME Mac** | custody exists → opens (Touch ID / silent); same device id — it IS that device | covered (the 13l drill) |
| 15 | **restore a PRE-switch backup after entering Castle** | opens through iCloud (Standard-era key file) or P/W of the day; its master and corpus key are dead; the reconcile says "keys don't match / your account is in Castle" → follow needs P/W; without them the only road is delete + set up again | covered — her narrative, now true |
| 16 | **her attacker: old iCloud-Drive backups + the iCloud key + the account password** | reads pre-switch writing; push/pull/purge/truncate/vault writes refused; can delete the whole account, sign out everywhere, change the password; an upload under a new account lands in its own partition | covered (§14.29) |
| 17 | **a stolen unlocked Castle Mac** | reads what is open; the re-auth blocks Replace All Keys / posture / passphrase; owner: Sign Out Everywhere + Replace All Keys + change the account password | covered; **the recipe belongs in copy → R8** |
| 18 | **a stolen unlocked Standard Mac with no passphrase set** | the thief can set a passphrase, enter Castle, or Replace All Keys with a plain confirm — the owner recovers from any enrolled device or by delete + re-setup | covered by Standard's disclosure ("anyone at your unlocked Mac … can set a new passphrase") |
| 19 | **iCloud Keychain compromised (Standard)** | the iCloud key → with a copy of the library, the library; with a session, sync — Standard's own sentence | covered |
| 20 | **the account email is the iCloud email (Standard)** | someone in iCloud can reset the password → a session → the compound | covered, disclosed |
| 21 | **Castle → Standard, then other devices** | one vault write adds the iCloud copy; each device adds its own from its own iCloud Keychain, silently; nothing rotated | covered |
| 22 | **Castle → Standard by an enrolled finger (a family member)** | allowed (keystone 2); Always ask is the answer | covered, disclosed (§14.22) |
| 23 | **a local-only Castle library turns on sync** | setup mints M/C fresh; the passphrase verified against the library's own copy; the words: the library already HAS words — type them or generate new? | **ambiguous → R7** |
| 24 | **a Standard-born phone enrolls into a Castle account** | consent; re-keys its library; the account's passphrase becomes the library's; pre-sign-in rows ride | covered |
| 25 | **a NEW device enrolls DURING a rotation** | gets M′/C′ from the vault; rows still under the old key unreadable until re-encrypted | **→ R1** (the previous corpus key wrapped under M′ in the vault for the window) |
| 26 | **delete the account; another device is offline** | it wakes → "keys don't match" (a different owner) → adopt into whatever new account it signs into | covered |
| 27 | **a re-opened plaintext export (13x) under the same account** | enrolls; pulls from 0; rows purged on the server since the export would stay as local zombies unless reconciled against the purge ledger before the first push | hand-forward to 13x (note it) |
| 28 | **the scheduled plaintext `.md` insurance was ON in Standard; the user enters Castle** | it keeps writing plaintext weekly | **not covered → R5** |
| 29 | **the delete-backups offer accepted** | the app's own snapshots go; no fresh post-switch snapshot exists until the next run | **→ R5** (snapshot first) |
| 30 | **Time Machine local snapshots on the switched Mac** | pre-switch key file + ciphertext exist locally for a day or more; readable by the login password only if Keychain Access reveals the iCloud key — pre-switch writing at most | covered by the ceremony's sentence; verify the Keychain fact once (copy consequence only) |
| 31 | **quick capture / hotkey / extensions under Castle before unlock** | demand unlock; on iOS a share extension cannot reach a biometric-gated item — it must say "open Variorum" | covered (pinned); mobile copy note |
| 32 | **the vault's NULL-hash arm between the deploy and each owner's first round** | a session in that window could install a foreign proof and grief the owner (recovery: delete + re-setup) | pre-launch only; note in the deploy checklist |

---

## PART D — RECOMMENDATIONS (refinements of ruled shapes; none reverses a ruling)

**MUST — protocol and switch; land in 1b/2 before anything builds on them:**
- **R1 — Any enrolled device can finish a rotation.** During a rotation the vault carries the PREVIOUS corpus key
  wrapped under the NEW master (`corpus_previous_wrapped_by_master`, one more nullable column in the same lockstep
  event); the serializer opens a payload by the key id in its AAD (current or previous); a follower keeps the previous
  key until the rotation completes; whichever device pulls to head and sees no row under the previous key clears it
  (a proof-authorized vault write). Exposure: the old corpus key to new-master holders — legitimate devices, and old
  snapshots already hold it. Closes scenarios 2 and 25.
- **R2 — Re-encryption is version-neutral.** A dedicated `sync_reencrypt(rows, active_key_id, key_proof)`: replace
  the payload where the row's `sync_version` matches, stamp a new `server_seq`, do NOT bump the version. The server
  stays dumb (bytes it is handed, own partition, CAS on version). Followers pull the re-encrypted rows and apply nothing
  (version ≤ local); their offline edits CAS cleanly. Closes scenario 3; also makes "any device can finish" cheap.
- **R3 — A retired secret dies on every device that has learned of the change.** On learning (online; descriptor
  changed, same key id), a device DELETES its stale passphrase (or words) copy from its key file at once — no secret
  needed to delete; the prompt's Later defers only landing the NEW copy. Offline grace covers ignorance, not deferral.
  Touch ID and the words keep opening; the new passphrase opens online via the vault road. Closes scenario 6/9 and
  makes the Change Passphrase sentence true everywhere.
- **R4 — A library opened on a machine with no custody for its store ID mints a fresh `device_id`** (and 13x's open
  door does the same). The cursor carries over; only the identity changes. Closes scenario 10's second half.
- **R5 — Entering Castle leaves nothing behind:** make a fresh snapshot under the new key BEFORE offering to delete the
  old ones; turn the scheduled plaintext `.md` insurance OFF with one notice (re-enabling shows the Castle warning; the
  manual export stays ungated per ruling (h)). Closes scenarios 28/29.

**SHOULD — clarity and disclosure; land with their batches:**
- **R6 — One Apple-held copy per account.** A device on a different iCloud account enrolls by passphrase and opens
  silently thereafter from its own device item; Standard's nothing-typed new-device road is for devices on the iCloud
  that turned on sync. One sentence in the book and in the waiting state.
- **R7 — Sync setup from a library that already has twelve words:** type the existing words (one pair everywhere) or
  generate new ones (the key file's copy replaced); the copy says which is happening.
- **R8 — Copy:** the lost/stolen-device recipe (Sign Out Everywhere · Replace All Keys · change the account password),
  named as such in the FAQ; the Castle ceremony shows re-encryption progress; "Time Machine local snapshots" beside
  Time Machine in the backups sentence; the three-line rule gains "an unlocked device of yours lost or stolen".
- **R9 — Batch 5:** *Encryption Explained* joins the seeded-book dedupe facts, or two devices seed two of it.

**NOTES for the batch briefs (no ruling needed):** session tokens at `AfterFirstUnlockThisDeviceOnly` (device-bound
is the goal; screen-lock availability is not a gate — Castle's re-lock is); the gated item is `.biometryCurrentSet`
WITHOUT a passcode fallback — pin it; no key material in the launch log — pin it; the NULL-hash arm's window in the
deploy checklist (each vault closes at its owner's first round; count vaults at deploy); verify once whether Keychain
Access reveals the shared-group item to the login password (a copy consequence only); iOS extensions under Castle say
"open Variorum to capture"; an optional passphrase strength hint at creation (four random words).

**PROCESS:** two cold-review ladders — one after U3 (substrate + protocol + the switch, the riskiest half) and one at the
end — instead of one at the end; two drills added to §12: the acting device killed mid-re-encryption and a follower
completing it; a device with offline edits across a rotation converging with zero conflict variants.

---

## PART E — WHAT PASSED INSPECTION (explicitly)

The two-posture model and its derivation from the vault's shape · the sync keys inside the library · one iCloud key with
wrapped copies in Standard and none in Castle · the proof on every mutating RPC and the bare session's two loud powers ·
the rotations at the switch (master, corpus key, each device's library key) and the non-silent follow · Castle → Standard
as one added copy · the three acts and their authorizations · backups never rewritten, per-fingerprint, the live key
file pairing · follow vs adopt by owner · the absent-store route · deletion by account password + typed phrase + fresh
re-auth · the plaintext export's strip rule and kept sync columns · the credential audit as a standing artifact · the
copy's honesty on every promise · the enrolled-finger and open-app boundaries said once · mobile inside the phase.

**Verdict.** The design is sound and, with R1–R5, complete. R1 and R2 are the two I would not build without: they are
the difference between a rotation that is correct on a demo and one that is correct in a household with a phone in a
pocket and a Mac asleep on a desk. R3 is the difference between the Change Passphrase sentence being true and being
mostly true. R4 and R5 are cheap and close self-inflicted holes. R6–R9 are words. Nothing in this review reopens a
ruling; everything in it makes a ruled thing hold under failure.
