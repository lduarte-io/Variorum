# VX-502 unit B — the Castle-restore walk: THE SCRIPT OF RECORD

**STATUS: COMMITTED at phase 2a (2026-10-27, on the orchestrator's relayed go after the ladder closed at `776859237`);
written in phase 1 (~03:30–04:30 MDT) by the walk session, an Opus subagent of the vx-502 orchestrator; aligned to the round-2 edits of THE NEGOTIATED WALK — R2-M2's legs 9–10, R2-N4's account posture — at
`45b43fddf`) and to **THE WALK RULINGS 1–11** (the orchestrator, `88fb5ec1b` — every leg below is the ruled form).
Drafted in the gitignored `App/Variorum/DerivedData/vx502-walk-drafts/` (moved there from its named place when another
session was found writing in this worktree, so no broad `git add` could sweep it in); moved to
`notes/plans/fixes/vx-502-walk-script.md` (and the lib to `Tools/WalkKit/castle-walk-lib.zsh`) and COMMITTED FIRST —
**on the orchestrator's explicit go after the ladder closes (ruling 10: one writer on the branch at a time; pull first)** —
before any stage act (the coordinator's condition (3)). Nothing below has run. Every leg's result is PENDING until its row in the record says
otherwise.** The charter is `notes/plans/fixes/vx-502-export-across-migrations.md` — "The charter" (her overnight word:
the pair-change arm AUTHORIZED and REQUIRED, both roads proven), "The coordinator's protocol", "UNIT B" (history), **"THE
NEGOTIATED WALK" (the legs this script implements, numbered as there)**, "Environment traps". The contract the walk
exercises is `notes/CastleRules.md` (rules 4–7, 10–12, 16, 17, 21). The driving primitives are
`Tools/WalkKit/castle-walk-lib.zsh` (sourced; every primitive STOPs on a failed guard).

## The lanes, the secrets, the machine (binding on every act)

- **Two credential lanes that never cross (oct26coordinator's).** The DEV pair (`~/.variorum/dev-castle.env`: field
  `passphrase` = `VARIORUM_DEV_CASTLE_PASSPHRASE`, field `words` = `VARIORUM_DEV_NEWROAD_WORDS`, the pair the env file's own
  VX-306 U3 note names — CONFIRMED, ruling 8; `VARIORUM_DEV_CASTLE_WORDS` is never typed) is typed ONLY by `~/.variorum/bin/type-dev-castle-secret`, ONLY into a PLAIN launch (zero
  `VARIORUM_*` keys), ONLY at leg 1's read-only check door. The vxtest ACCOUNT's secrets are typed ONLY by
  `~/.variorum/bin/type-prod-test-secret castle <field>`, ONLY into a PROD-TEST-ROAD launch, ONLY on walk-owned
  libraries. Each helper refuses the other lane's launch. `dev-castle.env` takes NO value change (comment lines only);
  `prod-test-accounts.env` and `prod-test-words-castle` take ZERO edits — their sha256 fingerprints are in every state line.
- **No secret value ever** in argv, stdout, a log, a capture, a commit, this record or a report — fields are named, never
  shown. Captures pass the words guard first (`wk_capture` withholds any window with a twelve-word string or the words
  look's markers on screen). Concealed fields are never revealed (the eye is never pressed). The band card's words look,
  Record your twelve words, New Words and Replace All Keys are NEVER pressed on any library.
- **The stage:** claim `vx-502-walk`, granted only by the coordinator's GO with the exact claim line (relayed by the
  orchestrator — a subagent never messages the coordinator); renewed with `Tools/stage renew --who vx-502-walk --minutes
  240` before it lapses; released at leg 13. Instance checks: the strict forms `pgrep -lx Variorum` and
  `pgrep -lf "MacOS/Variorum$"` (`wk_instances` / `wk_zero`). Her `/Applications` app is never launched, quit or typed into
  (`guard.sh --author` before every act: her app absent, HID idle ≥ 2 s — an exit 4 ends the walk, never retried).
  `caffeinate -dims` detached for the window, killed at release.
- **Evidence:** `App/Variorum/DerivedData/vx502-walk-evidence/` (gitignored; DELETED at the effort's close — this record is
  the evidence of record): `walk.log`, `state.log`, one folder of window captures per capture, each launch's stderr
  (`app-<leg>-<time>.log` — the road's lines: `road:`, `enroll:`, `make_mine:`, `change_passphrase:`, `backup pair:`).
- **The machine-state line** (`wk_state <leg> [account]`) closes every leg: instances · the slot's files by name@inode · the
  slot library's id and key prefix · the hold marker (inode + digest) · the as-found aside · Previous Libraries · the stage ·
  the three credential files' fingerprints · (account legs) the castle account's vault mode/revision/updated_at, device
  cursors, live containers. It is copied into the record's UNIT B LIVE STATUS and COMMITTED + PUSHED per leg, so a stop
  mid-leg is followed by a verify-not-trust check against the last committed line.
- **A permission prompt or a stall in any typed or driven act is STOP-and-yield** (ruling 9 — no permission config
  changes for the window; the stop is recorded, the window yielded, the item bundled for her morning; never worked
  around). **VX-439's walk part 2 never runs inside this window** (ruling 11 — the coordinator orders it outside); the
  as-found set returns byte-whole with VX-548's client row and VX-439's walk content in it.
- **Every test RESULT line states the EXECUTED test count per run (VX-604, ruling 7):** a lone-suite run can false-green
  as "0 tests in 1 suite passed" through a test-host launch crash — 0 executed is NO VERDICT (rerun once, else stop).
- **A leg that cannot complete after 2–3 attempts STOPS** and reports — no improvisation around a Castle door. A failure of
  rule 5's floor or rule 6 is a FINDING against CastleRules: recorded verbatim with its captures and log lines, sent to the
  morning bundle, never worked around and never fixed (the Castle design is frozen — her word 2026-10-24).
- **Expected interruptions (logged, not failures):** the What's New sheet after a launch (dismissed); rule 21's "This is a
  different library than the one this Mac last had open" after a slot change (OK — the walk artifact every swap shows);
  Castle's idle lock during a wait (the lobby answers the current passphrase); a quit declined while a sheet is up (the
  sheet dismissed, one more quit — never SIGTERM while the as-found library is open); quiet receipts fading in ~6 s.

*[removed for publication]*

**Why `castle`:** her standing lifecycle pair is std = the Standard account and castle = the Castle account (R-510-23).
The last recorded state (VX-529's D7, 2026-10-24 23:16 MDT): **Castle, vault revision 23, current passphrase = the env's
`passphrase` field, words = the set stashed 22:43 in `prod-test-words-castle`**; VM-8's two simulator legs (2026-10-25)
joined it twice and wrote no vault row; nothing since names it (tonight's VX-548 and VX-439 walks stayed on the dev store).
So the join itself takes the walk library into Castle (the re-keying join) — no posture change on the account, and the
account ends where it was found. `std` (Standard, revision 3, current = `passphrase2`) would need the account to ENTER
Castle and the walk to leave it again (two extra vault writes, and the Standard test account's role bent); `del` is the
fresh-account/deletion vehicle (R-510-23) and is not used.

**P1/P2 by field name:** P1 = the account's passphrase at the window's start (expected the env's `passphrase`); P2 = the
other recorded field (expected `passphrase2`). The words never change in this walk (no New Words anywhere).

**Confirming the posture at the window's start (no server contact in phase 1):** (1) `Tools/prod-read.sh` (SELECT-only,
run from main's checkout path — the vx-502 worktree has no `.env.supabase.local`; the allow rule names that path): the auth
row by the allowlisted address (exists, confirmed — so `Tools/prod-confirm-test-user.sh`, a one-UPDATE script, is NOT run:
the account is confirmed since 2026-10-24 03:13Z, and the script is only for an unconfirmed row), then `key_vault`'s mode,
revision and updated_at, device cursors, live containers. (2) The app's own faces at leg 3: the join sheet's posture
sentence ("Your account is in Castle, so this library goes into Castle too." vs "…in Standard, like this library."), then
the join's typed passphrase (a refusal writes nothing), then the read-only check door with the passphrase and with the
words. **What each posture means for leg 3:**
- **Castle, `passphrase` current (expected):** join by `passphrase` with Always ask → the walk library enters Castle
  through the join (VX-469's line is on the join's confirm — captured). No Use Castle needed.
- **Castle, `passphrase2` current (an unrecorded flip since VX-529):** the join refuses `passphrase`; ONE try of
  `passphrase2` (a refusal writes nothing) → P1 := `passphrase2`, P2 := `passphrase` for the whole walk; leg 10 changes
  back to `passphrase2`. Recorded by field name.
- **Standard (unexpected):** join (same posture, no gate), then Use Castle… on the walk library with both account
  secrets, Always ask (the account enters Castle — a vault write; VX-469's line on Use Castle's confirm captured). Leg 10
  then follows the restored library back OUT (Use Standard, both secrets — rule 12's leave, its own evidence line), as the
  negotiated leg 10 rules (R2-N4: restored if found Standard; left in Castle if found Castle).
- **Neither passphrase opens it, or no vault (the set-up arm "Turn on sync…" shows):** STOP — the account's pair is
  unknown; never reset, never mint.
- **The words don't open it at the check door:** the stash is stale (VX-529's I-D0-2 class) — STOP before leg 4: leg 7's
  confirm REQUIRES the current words, and the remedy (New Words + stash) changes the account's pair — the orchestrator's call.

## The window's shape (a subagent hears the coordinator only through the orchestrator)

- **Phase 2a (headless, NO stage):** build
  the walk app `xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' -derivedDataPath
  <home>/dev/variorum-vx-502/App/Variorum/DerivedData/vx502-walk build` (from `App/Variorum/`) and the test
  products `xcodebuild -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  <home>/dev/variorum-vx-502/App/Variorum/DerivedData/vx502-close build-for-testing` from the SAME commit
  (recorded); `wk_setup` (helpers compiled into the evidence bin and `Tools/WalkKit/wl2` — gitignored; VX-536); both
  `type-dev-castle-secret --check` lines again; the ONE allowed server read (W0's precheck: the castle account's mode and
  revision, `Tools/prod-read.sh` from main's path) → hand back: READY-READINESS confirmed. **Then, on the orchestrator's
  explicit go after the ladder closes: `git pull --rebase`, the two drafts moved to their real paths, committed + pushed
  FIRST** (if the ladder's close changed any `App/` or `Sources/` line, both builds re-run on the pulled tree, their
  commit recorded) → the orchestrator relays READY; GO comes from the coordinator.
- **Phase 2b (on the coordinator's GO, relayed):** W0 + step 0 → hand back with the test line and "SEAM" (the only road
  by which a subagent hears a merge-gating run slotting in). The claim stays HELD across the seam unless the coordinator
  says yield; if a run slots in, the walk releases (the dev store exactly as found plus the batch's ordinary open) and
  re-takes W0's baselines at the next GO (E0′, reported beside E0).
- **Phase 2c (on the orchestrator's continue):** legs 1–13; RELEASE's one line handed back for the orchestrator to relay.

## W0 — the window opens (the claim line run exactly as the coordinator's GO gives it)

1. `Tools/stage status` → `STAGE HELD by 'vx-502-walk'`. `nohup caffeinate -dims >/dev/null 2>&1 &` (its pid recorded).
2. `source Tools/WalkKit/castle-walk-lib.zsh; wk_setup` (grants AX/SCREEN/System Events checked — never prompted; a
   missing grant HOLDS the walk for her); `wk_zero`; `Tools/WalkKit/guard.sh --author`.
3. **Baselines BEFORE step 0** (the test host IS the dev-store app — it opens the store and moves prefs; the
   walk-restores-dev-store-posture lesson): `defaults export io.lduarte.Variorum.debug $WK_EV/prefs-E0.plist` ·
   `wk_inventory "$WK_SLOT" > $WK_EV/slot-E0.txt` (the nine top-level files: name@inode, size, digest) · a names-only
   listing of `Previous Libraries/`, `Backups/` and `~/Documents/Variorum/Backups/` → `$WK_EV/places-E0.txt` ·
   **the W0 SAFE COPY (ruling 2 — her lockout concern made mechanical):** at zero instances, the nine as-found files
   `cp -p` into `…/Variorum-dev/Backups/safety-copies/vx502-walk-asfound-<UTC stamp>/` (a WAL-safe copy — the store with
   its WAL/SHM, all at rest), every file's digest compared to its source; kept for the closeout's tidy. **The prefs
   baseline is E0 — this one, before step 0 (ruling 3).**
4. `wk_castle_uid; wk_state W0 account` → the castle account's line (expected: mode castle, revision 23).
5. Commit + push the W0 line into the record's UNIT B LIVE STATUS.

**Expected W0 facts (read in phase 1, 2026-10-27 ~03:30 MDT — verify, don't trust):** the slot's key file names library
**`e11e5233`**, key **`77f4a14d`**, locks apple + passphrase + words, two earlier keys; the hold marker present
(`heldAt 2026-10-20T08:53:29Z`, `asOf 08:41:03Z`, inode 191598619); the seven persistent files on inodes
191598614–191598620 (the VX-510/VX-529 list), the WAL/SHM on 197668900/197668901 (re-made by tonight's opens); Previous
Libraries = `2026-10-08-035453` (pre-design), `2026-10-18-173517` (`818912e0`), `2026-10-20-085330` (`86a82b4f`); the newest
backup of the as-found = `Backups/e11e5233/e5276ad5/variorum-backup-2026-10-27-085100-77f4a14d` (VX-548's launch, 02:51
MDT). Tonight's other walks left content in it: VX-548 a `claude-code` client row (no grants) + an empty "Walk Wing";
VX-439 "Walk Book" + a tagged note, "left in place for walk part 2". This walk records them and touches none of it.

## STEP 0 — the Mac test batch (the window's first act)

- From `App/Variorum/`: `xcodebuild test-without-building -scheme Variorum -destination 'platform=macOS' -derivedDataPath
  <home>/dev/variorum-vx-502/App/Variorum/DerivedData/vx502-close
  <one -only-testing:VariorumTests/<Type> flag PER suite in the DERIVED SET below — never one packed flag (VX-439's
  slip)>` `> $WK_EV/step0-tests.log 2>&1`, its status read by zsh `pipestatus`. Foreground waits only: a run past the Bash
  limit is polled (`grep -q '\*\* TEST \(SUCCEEDED\|FAILED\) \*\*' log && break; sleep 10`). (The record's command named
  `-derivedDataPath App/Variorum/DerivedData/vx502-close` relative to the repo root while `xcodebuild` runs in
  `App/Variorum/` — the absolute path keeps the products where unit A's and the walk's sit.)
- **THE DERIVED SET (ruling 7 — not guessed):** every suite TYPE in a `VariorumTests` file naming `ProtectionCopyDoors`,
  `ProtectionWords` or `PlaintextExportReading` (`grep -rlE` over `App/Variorum/VariorumTests` → 92 files → **109 suite
  types**, each a column-0 type holding `@Test`, none duplicated; `PlaintextExportBringInRoadTests` and `U2WordsTests`
  among them). The list is generated at 2a into `$WK_EV/step0-suites.txt` and its flags into `$WK_EV/step0-flags.txt`;
  the window runs exactly that file, re-derived on the committed tree if the ladder's close changed a test file.
- **Evidence:** the "Test run with N tests in M suites" line — **N EXECUTED stated in the result line (VX-604): 0
  executed = NO VERDICT** — `** TEST SUCCEEDED **`, every `skipped:` line read (Swift Testing counts skipped tests), the
  named suites present in the log.
- **After:** `wk_zero` (the host gone) · `wk_inventory "$WK_SLOT" > slot-E1.txt` diffed against E0: only the store's
  WAL/SHM (and possibly `variorum.sqlite`) may differ; **the hold marker, the key file, the lived-here marker and the
  older-named key files must be byte-identical** · `defaults export … prefs-E1.plist` (the batch's own footprint, reported)
  · `wk_state S0`.
- **STOP:** a slot file other than the store's changed (a hosted test wrote the real slot — a finding, said at once);
  instances left behind. A RED batch is reported at the SEAM with its failing lines — the walk does not depend on unit A's
  change, so whether the legs proceed is the orchestrator's call.
- **SEAM:** hand back: the test line + the S0 state line + "SEAM — the as-found set aside is next".

## LEG 1 — AS-FOUND RECORD (the DEV lane; the as-found library's ONLY live use of the dev pair)

- **Acts:** `WK_LEG=L1; wk_launch_plain` (zero `VARIORUM_*` keys proven by `ps eww`) → What's New dismissed if shown → rule
  21's notice recorded and OK'd if shown → read, never act: the log's `road: opened — library <id8> key <fp8>`; the main
  window's banner sentence (expected VX-522's "This is your library as of October 20, 2026. This library doesn't sync, so
  Resume changes nothing in it."); the sync row (expected "Sync off (dev store)"); Settings (⌘, by `wk_keys`) ▸ Protection:
  the posture line (expected Standard) and the Sync section (expected signed out: "Sign in to turn on sync.").
- **The check door (writes nothing):** "Check my passphrase or twelve words…" → focus "Passphrase or twelve words" →
  `wk_dev_secret passphrase` → "Check" → expected "That passphrase opens this library." (log `road: a secret check
  (read-only, nothing written) — the library: opens …`) → capture → ⌘A + ⌫ (the answer clears on edit) →
  `wk_dev_secret words` → "Check" → expected "Those twelve words open this library." → capture → Close.
  NOTHING-WRITTEN proof: the slot key file's digest and mtime identical before and after.
- **Never pressed here:** the band card, Resume Sync, any key, Castle, account or copy door.
- **Close:** `wk_quit` → `wk_zero` (its own step) → `wk_state L1` → the env file's FOUND posture note filled (no values):
  library id, key prefix, posture, hold, sign-in, "the dev pair opens it (read-only check)".
- **STOP to the coordinator:** either dev secret does not open it (never mint new values); the posture is not Standard;
  her own account shows signed in (never touched — said at once). A library id other than `e11e5233` is RECORDED as found
  (the record calls every id unverified) and the walk continues only if it is Standard and the dev pair opens it.

## LEG 2 — THE WALK LIBRARY

### B′ — RULED (THE WALK RULINGS 1): the as-found set aside WHOLE by a same-volume move; a fresh walk library on the empty slot

- **Acts:** `wk_zero` (its own step) → `wk_aside_asfound`: every top-level file of the slot (all nine: the store and its
  WAL/SHM, `variorum-library-keys.json`, `variorum-restore-hold.json`, `variorum-library-lived-here`, the older-named
  `variorum-keys-1787a29ea0d545b9.json` and the two `.stale-*` files) `mv -n` into the sibling
  `Variorum-dev-aside-vx502-asfound/` (same volume), inodes proven identical (the seven persistent files ALSO checked
  against W0's list; the WAL/SHM rebuilt by leg 1's open, recorded as of the aside), the slot holding no top-level file
  (`Backups/` and `Previous Libraries/` stay) → `WK_LEG=L2; wk_launch_road` (the road ARMED; the handed allowlist; no walk
  project) → with no store and no lived-here marker the road assesses START-FRESH (`Assess.swift:87`) → a fresh library
  **L1** (log `road: created`), Standard, signed out, its band card offering words and passphrase (never pressed) →
  `wk_state L2`.
- **STOP:** the missing-library face instead of a fresh library (a marker or key file stayed behind — never Start fresh by
  hand); any `mv` fails (the set is PARTIAL — nothing launches on a partial set: a slot holding only the older-named key file
  would show her pre-design face).
- **Why:** "LEG 2 — why B′" at the end (CONFIRMED at ruling 1). The fresh library's own minted words are never looked
  at; it adopts the account's pair at leg 3's join (rule 7).

### A′ — RULED OUT (ruling 1)

The negotiated make-mine-on-the-as-found leg is not walked: `ProtectionCopyDoors.makeMine` overwrites the slot's hold
marker before anything moves, so it could never return the hold; it would also need a second, writing use of the dev pair
and would push the as-found's content into the account.

## LEG 3 — THE JOIN (the ACCOUNT lane, on L1)

- **The account's as-found posture RECORDED FIRST (R2-N4), by place, never value:** W0's prod read (`key_vault.mode`,
  revision) and, below, the join sheet's own posture sentence — both in this leg's state line.
- **Sign in:** the row's "Sign in…" → the Account sheet → focus "Email" → `wk_prod_secret email` → focus "Password" →
  `wk_prod_secret password` → "Sign In" → wait for "Sign out" → capture → "Close" → the row "Sync isn't on for this
  library yet" (VX-506) → capture.
- **The join:** Settings ▸ Protection ▸ Sync → "Sync this library…" (the join arm — the account holds a vault) → the sheet
  "Sync this library": its posture sentence read and captured WITH VX-469's line ("The libraries in Previous Libraries keep
  their own quiet roads on this Mac — Castle protects the library you have open") → **"Always ask"** pressed (no Touch ID —
  her finger is never needed) → focus "Your account's passphrase" → `wk_prod_secret passphrase` (P1) → the sheet's button →
  *[removed for publication]*
  (the re-keying join through the reopen) → the words moment (the passphrase arm names the account and shows NO words —
  rule 7) → OK → **"Synced. Your account's writing is in this library now."** → Done → the row "Synced ‹time›" → the cards
  band EMPTY (VX-511's retirement) → capture. Branches per "What each posture means" above.
- **The pair against the files (the read-only check door):** `passphrase` (P1) → "That passphrase opens this library and
  your account." · `words` → "Those twelve words open this library and your account." → captures.
- **Note A:** the Bookcase's quick entry → `wk_type_text "VX-502 walk note A - written before the backup, under P1"` →
  `wk_enter` → the settle round → the row "Synced ‹time›".
- **Evidence:** prod — cursors +1 (L1's device), containers +1 (note A), the vault revision UNCHANGED (a join writes no
  vault row) → `wk_state L3 account`.
- **STOP:** sign-in refused; the set-up arm shows; a system Touch ID sheet appears (a foreign window — STOP, never pressed);
  "Sync hasn't run yet: …" (its sentence recorded); the check door refuses either secret (see the posture branches).

## LEG 4 — THE CASTLE BACKUP under P1

- Settings ▸ Data Safety ▸ "Back Up Now…" → log `backup pair: written under <k1>` → the pair listed by place
  (`Backups/<L1-8>/<mac8>/variorum-backup-<UTC stamp>-<k1>.{sqlite,keys.json}` + its picked-folder twin if one is written:
  names, inodes, digests) → the Restore list's new row captured.
- **The pair noted by place, never value:** P1 = `prod-test-accounts.env`'s `VARIORUM_PRODTEST_CASTLE_PASSPHRASE` (helper
  field `passphrase`) + `prod-test-words-castle` (field `words`) — or the swapped fields if leg 3 swapped them.
- `wk_state L4`. **STOP:** no pair written, or written under a key other than L1's current.

## LEG 5 — THE PAIR CHANGE (P1 → P2)

- Settings ▸ Protection ▸ "Change passphrase…" → the sheet's synced line ("This library syncs with your account, so your
  account's passphrase changes with it, on every device.") captured → "Current passphrase" ← `passphrase` (P1) → "New
  passphrase" ← `passphrase2` (P2) → "Again" ← `passphrase2` → the sheet's button → expected `change_passphrase: done …` ·
  `road: changePassphrase — the current key re-locked (<k1>), the account's lock with it`.
- **Rule 6 and rule 7 seen:** L1's key-file fingerprint identical before and after (the key unchanged — re-locked only);
  prod vault revision +1, mode castle, updated_at at the press (the account's lock re-wrapped in the same act). The
  prod-test files unchanged (fingerprints) — `passphrase2` is a recorded field.
- **Note B:** the quick entry → "VX-502 walk note B - written after the backup and the pair change (P2)" → ⏎ → the round →
  prod containers +1. (It is on the server and NOT in the P1-era backup — leg 9's download proof.)
- `wk_state L5 account`. **STOP:** the change refuses; the key fingerprint moves (a FINDING — rule 6); the vault revision
  does not move (a FINDING — rule 7).

## LEG 6 — THE PROBES on the P1-era backup (Look inside — nothing written)

- Settings ▸ Data Safety ▸ the leg-4 row ▸ "Look inside…" → expected "This copy doesn't open by itself on this Mac. Enter
  its passphrase or twelve words." (Castle + Always ask: no quiet road — rule 5's quiet clause honestly absent) → capture.
- **Negative control:** focus "The copy's passphrase or twelve words" → `wk_type_text "not-the-passphrase-0000"` (a junk
  literal, never anyone's secret) → "Open" → expected "That doesn't open this copy. …" → capture → field cleared.
- **P1 (rule 5's floor):** `wk_prod_secret passphrase` → "Open" → expected the facts sheet, log `road itsOwnSecrets —
  read-only, nothing written`; **note A listed, note B absent** (the backup predates it) → capture → "Close" (forgets).
- **P2 (rule 6 — same key, re-locked only):** Look inside again → `wk_prod_secret passphrase2` → "Open" → expected it
  opens, log `road currentSecretsThroughTheHistory` → capture → "Close".
- **The words (unchanged, both old and current):** Look inside again → `wk_prod_secret words` → "Open" → opens → capture →
  "Close".
- **Nothing written:** L1's key file digest and mtime, the Backups listing and the vault revision all unchanged across the
  probes → `wk_state L6 account`.
- **STOP — a FINDING against CastleRules:** P1 does not open it (rule 5's floor) or P2 does not open it (rule 6) — or the
  junk opens it. Recorded verbatim, captures and log lines, to the morning bundle; never worked around.

## LEG 7 — THE RESTORE (Make this my library on the P1-era backup, opened by the OLD pair)

- Settings ▸ Data Safety ▸ the leg-4 row ▸ "Make this my library…" → the confirm's lead captured (Castle: "…under your
  current twelve words and passphrase…") → "The copy's passphrase or twelve words" ← `wk_prod_secret passphrase` (**P1 — the
  old pair opens the copy**) → "Your twelve words" ← `wk_prod_secret words` → "Your passphrase" ← `wk_prod_secret
  passphrase2` (**P2 — the current pair the new library lands under**) → capture (all three concealed) → "Make this my
  library" → expected: `make_mine: … the new library's key file written (<k2>) — with the join's two proof fields`
  (R-529-7: signed in, online) · `swapped` · `done` · `road: made a copy this Mac's library — library <L2> key <k2>; the
  previous one in Previous Libraries; held` → L2 opens through the reopen.
- **Rule 17 seen:** L2 ≠ L1 (fresh identity) · k2 ≠ k1 (fresh key) · Settings ▸ Protection reads Castle (the posture of now)
  · the hold banner standing (its sentence captured — whether it names the account (VX-473) picks leg 9's branch) ·
  `Previous Libraries/<stamp>/` holds L1 (its key file's `libraryID`) — reported.
- `wk_state L7 account` (vault revision unchanged — the restore writes no vault row).
- **STOP — a FINDING:** the copy refuses P1; the act refuses the current pair; L2 lands un-held, or Standard.
- (The hold banner here is expected ACCOUNT-LESS — the restored library binds no account; leg 9 resumes it first.)

## LEG 8 — UNLOCK END TO END

- ⌃⌘L (`wk_keys 'keystroke "l" using {control down, command down}'`) → `road: locked …` → the lobby ("Open your library —
  Enter your passphrase or your twelve words…"; "Touch ID isn't set up for this library.") → capture.
- **8a — INCLUDED (ruling 5; rule 17's "carries no keys" made visible):** `wk_prod_secret passphrase` (P1) → "Open" →
  expected a REFUSAL (the restored library carries no keys and is locked under P2 + the words; P1 is not the account's
  current passphrase, so R-529-1's vault road does not apply) → capture. P1 opening L2 is a FINDING → STOP and record.
- **The current passphrase:** `wk_prod_secret passphrase2` (P2) → "Open" → `road: opened — library <L2> key <k2>` → capture.
- **8b — the words:** ⌃⌘L → "Use your twelve words instead" (its label opens it — VX-527) → "Your twelve words, separated
  by spaces" ← `wk_prod_secret words` → "Open" → opens → capture.
- `wk_state L8`. **STOP:** P2 or the words refused.

## LEG 9 — SYNC END TO END (as rewritten at R2-M2: the restored library BINDS NO ACCOUNT — P-VX378-U2-4)

- **Resume first, with NO round:** the banner's account-less sentence captured as its own evidence line (VX-522: "This is
  your library as of October 27, 2026. This library doesn't sync, so Resume changes nothing in it.") → "Resume Sync" → the
  banner gone, the row "Sync isn't on for this library yet" (VX-506) → capture.
- **Then the JOIN:** Settings ▸ Protection ▸ "Sync this library…" → the join sheet (same posture — "Always ask" if a gate
  row shows) → "Your account's passphrase" ← `wk_prod_secret passphrase2` (P2 — the account's current) → the sheet's
  button → RECORDED: whether the words moment stays QUIET (R-529-7 — leg 7's proof fields) or speaks → the sheet's
  first-round line **"Synced. Your account's writing is in this library now."** → Done → the row **"Synced ‹time›" against
  the account under P2**. (If the banner had instead named the account, that difference is recorded and the join's
  presence decided by the face — the faces decide, never a guess.)
- **Content both directions:** the Library lists **note A** (from the backup) AND **note B** (it can only have come down
  from the server — written after the backup) → capture → **note C** through the quick entry ("VX-502 walk note C - written
  on the restored library (P2)") → the round → "Synced" → prod: live containers = leg 5's count + 1 (no duplicates — note A
  merged by id), the newest `created_at` at note C's minute, cursors +1 (L2's device).
- `wk_state L9 account`. **STOP:** Resume runs a round or leaves the banner (VX-522's account-less hold broken); the join
  refuses P2; the first round says "Sync hasn't run yet: …" (its sentence recorded); note B absent after "Synced"; the
  server holds more containers than the count says (a duplicate).

## LEG 10 — THE PAIR RESTORED, then signed out

- Settings ▸ Protection ▸ "Change passphrase…" → "Current passphrase" ← `passphrase2` (P2) → "New passphrase" ←
  `passphrase` (P1) → "Again" ← `passphrase` → the button → `…re-locked (<k2>), the account's lock with it` → prod vault
  revision +1 (expected 25 if found 23), mode castle.
- **The files TRUE with zero edits, proven:** the check door — `passphrase` → "That passphrase opens this library and your
  account." · `words` → "Those twelve words open this library and your account." (captures); the three credential files'
  fingerprints identical to W0's.
- **The account's posture restored (R2-N4):** found CASTLE (expected) → left in Castle. Found STANDARD → Settings ▸
  Protection ▸ "Use Standard…" on L2 — `wk_prod_secret passphrase` (the current, P1 again) + `wk_prod_secret words`;
  the leave sheet's rule-12 sentence captured ("…if you want Castle-era writing to stay Castle-protected, don't leave.") →
  prod `key_vault.mode` standard, revision +1 — rule 12's leave as its own evidence line.
- **Sign out (rule 16 — no key change):** Settings ▸ Protection ▸ "Sign out…" → the alert "Sign out of this Mac?" → "Sign
  Out" (an AX press by description inside the alert's window — VX-529's fact; synthetic clicks and Return don't reach it) →
  "Sign in to turn on sync." → capture.
- `wk_state L10 account`. **STOP:** the change back refuses; a check refuses — the account is then stranded on P2: the
  record and RELEASE say "castle's current passphrase is the env's `passphrase2` field" (values never written; the files
  already hold both), and the orchestrator decides any comment line in her file.

## LEG 11 — THE HAND-RETURN (the coordinator's conditions)

- `wk_quit` (identity-addressed, outcome read) → `wk_zero` as ITS OWN step (both strict forms empty).
- **B′:** `wk_aside_walklib walkL2` (whatever occupies the slot — L2's files — WHOLE into a NEW
  `Variorum-dev-aside-vx502-walkL2/`, never overwritten or merged into; reported by its key file's `libraryID`) →
  `wk_return_asfound` (every aside file back by a same-volume `mv -n`; **the inode check binds the SEVEN persistent files
  against W0's list** — `variorum-library-keys.json`, `variorum-restore-hold.json`, `variorum-library-lived-here`,
  `variorum.sqlite`, the older-named key file and the two `.stale-*` files; **the WAL/SHM by presence** (as at the aside)
  **and the store's consistency** at the relaunch below, never by inode identity — ruling 1; the empty aside folder
  removed).
- **ONE plain relaunch** (`wk_launch_plain`) → rule 21's notice (the swap's artifact) → OK → the five facts, each captured:
  the log's `road: opened — library e11e5233 key 77f4a14d` (**the as-found id active**), Settings ▸ Protection **Standard**,
  **unlocked by the quiet road** (no lobby), **signed out** ("Sync off (dev store)", "Sign in to turn on sync."), **the
  hold banner standing** (leg 1's sentence) — and the store consistent: it opened, its notes listed as at leg 1 → `wk_quit`
  → `wk_zero` → the hold marker's inode AND digest = W0's.
- The env file's LEFT posture note filled (no values).
- `wk_state L11`. **STOP — KEEP THE CLAIM, tell the coordinator, NO repairs:** any of the five facts differs.

## LEG 12 — CLEANUP (each target READ before removal)

- **Removed, each after its key file's `libraryID` ∈ {L1, L2} and every file stamped inside the window is read:**
  `Variorum-dev-aside-vx502-walkL2/` (L2) · `Previous Libraries/<leg-7 stamp>/` (L1) · the container's `Backups/<L1-8>/`
  and `Backups/<L2-8>/` · **the picked folder's** `~/Documents/Variorum/Backups/<L1-8>/` and `<L2-8>/` (VX-529's lesson:
  the cleanup names the picked folder) · any `Backups/safety-copies/variorum-adopt-safety-*` made in the window (none
  expected). A listing of every path removed goes in the record.
- **UNTOUCHED (named):** the as-found set; `Backups/e11e5233`; `Previous Libraries/2026-10-08-035453`, `2026-10-18-173517`,
  `2026-10-20-085330` (`86a82b4f`); every other `Backups/` and picked-folder entry (VX-510's walk residue there is hers);
  `RESTORE.md`; `safety-copies/` (the walk's own W0 safe copy is KEPT for the closeout's tidy — ruling 2).
- **Debug prefs:** `defaults export … prefs-END.plist` → a key-level diff against **prefs-E0** (plutil → JSON, a short
  python diff) → keys the window ADDED deleted (`defaults delete io.lduarte.Variorum.debug <key>`), keys it CHANGED written
  back to E0's typed value (`defaults import` alone merges — added keys survive it) → re-export → diff → **0 differences**,
  or only the app's own launch bookkeeping, each key named (VX-548's precedent). The batch's own footprint (E0→E1)
  reported beside it.
- `kill <caffeinate pid>` · `wk_state L12`.

## LEG 13 — RELEASE

- `Tools/stage release --who vx-502-walk` → "STAGE RELEASED".
- **The one line (handed to the orchestrator to relay):** "vx-502-walk RELEASED — active library e11e5233 (key 77f4a14d),
  Standard, opens unlocked by the quiet road, held as of Oct 20 (banner standing), signed out confirmed; Debug prefs diff
  clean vs the pre-window export (<n> restored, <m> deleted); zero instances; castle vxtest account: Castle, vault rev
  <R>, passphrase back on the env's `passphrase` field, words = the stash — prod-test-accounts.env and
  prod-test-words-castle TRUE with zero edits (fingerprints unchanged); dev-castle.env values unchanged (comment lines
  only)."
- The record's UNIT B LIVE STATUS closed (every leg's row, the findings, the residue), committed + pushed.

## Accepted residue (reported at RELEASE)

The castle account gains two device cursors (L1, L2 — the 13j horizon retires them), three containers (notes A, B, C) and
two vault revisions; the dev scope's keychain may keep L1's pre-join quiet items (retired by the join's "retired 1 own
Apple key(s)") — the VX-510 precedent; the as-found's leg-11 relaunch mints a new device identity for it on this Mac after
rule 21's notice (a new `Backups/e11e5233/<mac8>/` folder at its next backup — the VX-510/VX-529 pattern); the as-found's
WAL/SHM move with every open (legs 1, 11, the test batch).

## LEG 2 — why B′ (the walk session's phase-1 finding; CONFIRMED at THE WALK RULINGS 1)

The negotiated leg 2 makes the walk library with **Make this my library on the as-found library**. Read in source, that door
cannot keep the as-found's hold: `ProtectionCopyDoors.makeMine` writes the NEW library's hold marker over the slot's marker
BEFORE anything moves (`LibraryRestoreHold.set(besideStore: slot, …)`, `App/Variorum/Shared/Protection/ProtectionCopyDoors.swift:303`
— atomically, so a new inode), and the hold is never carried aside (the new library lands held on that marker; the dev
slot's own `2026-10-20-085330` entry — VX-309's make-mine — holds exactly the store and its key file, while that day's
lived-here marker and older-named key files are still in the slot today). The as-found's
`variorum-restore-hold.json` — "one Resume press from gone" in the coordinator's words — would be destroyed by the app's own
act, and leg 11's "hold banner standing" could then not hold. Beyond that: the confirm REQUIRES the current pair typed
(`CopyDoorsModel.swift:15–19` — "her current pair is ALWAYS typed"), a second live use of the dev pair (the negotiated walk
allows one, read-only); the slot's lived-here marker and older-named key files stay beside every walk library; and the
walk library would push the as-found's content (tonight's VX-548/VX-439 walk residue) into the castle account. **B′ is the
road VX-510 (unit C, the successor re-walk, the third orchestrator) and VX-529 (D0–D7) each walked and restored by inode
on this Mac**: the nine files move as one unit, the slot is empty (no store, no lived-here marker ⇒ `.startFresh`), the
walk library is fresh, the dev pair's only use stays leg 1's read-only check, and leg 11 returns the as-found set with every
inode — the hold marker included — exactly as found. The coverage leg 2 gave up (Make this my library from a Standard
backup) is VX-510 S14's, and leg 7 walks the same door in Castle.
