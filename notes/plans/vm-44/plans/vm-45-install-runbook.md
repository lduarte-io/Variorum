# VM-45 — the install runbook: today's `main` onto her iPhone (working draft, not canon)

Prepared 2026-11-12 on the Pro, before the cable. Nothing has been installed. Every step marked **[HER HANDS]**
needs her at the phone; everything else runs from this Mac in Terminal. No step needs a `Tools/stage` claim (no
simulator, no Mac app, no test run).

**The one sentence.** Her phone runs a build that speaks sync marker 14; production moved to 15 on 2026-11-07/08,
so every round on the phone has refused since then, keeping its unsent changes. Installing today's build in place
(same app, same signing, the library untouched) brings it to 15, and the next round sends what it held and pulls
what it missed.

Secrets never go in this file or in a command: no passphrase, no twelve words, no email, no device identifier.
The device identifier lives only in the shell variable `DEV` below.

---

## 0. The facts this runbook stands on (checked 2026-11-12)

| Fact | Value | How known |
|---|---|---|
| The build | `~/Library/Developer/Xcode/DerivedData/vm45-device/Build/Products/Release-iphoneos/VariorumMobile.app` | Built from `main` @ `5dde1bcf9` (= `origin/main`), Release, `generic/platform=iOS`; BUILD SUCCEEDED; `codesign --verify --deep --strict` OK |
| Bundle id, version, build | `io.lduarte.VariorumMobile` · 1.0 · 1 | The built Info.plist. The phone target has no build-number stamping; the phone's installed build is also 1.0 (1), as every install since September has been |
| Signing | Apple Development, automatic, the wildcard "iOS Team Provisioning Profile: *" (expires 2027-07-09, lists her phone), `get-task-allow` true | The embedded profile and `codesign -d`; the profile was already on this Mac, nothing was minted or refreshed |
| Entitlements | `application-identifier` = the team + bundle id; keychain groups: the app's own group first, then the shared `io.lduarte.Variorum.shared` group. No app group, no iCloud | `codesign -d --entitlements`; `App/Variorum/VariorumMobile.entitlements` has had zero changes since her phone's build |
| Marker on `main` | 15 | `Sources/VariorumCore/Sync/SyncSchema.swift:170` |
| Marker on production | 15 | `Tools/prod-read.sh 'select sync_schema_version()'` → 15 (the documented read, `notes/plans/vx495-deploy-checklist.md`) |
| Marker on her phone | 14 (inferred) | Her phone's last recorded install is VM-8's, from the tree `8cba51e28` (pre-flip id `54e867074`), where `lockstepVersion = 14`. No later install is recorded. Her phone's own sync row confirms it at step b |
| Package versions | GRDB fork 7.11.1+sqlcipher.1, SQLCipher 4.18.0 | The app's `Package.resolved` is byte-identical to the one her phone's build used, so the store opens with the same SQLCipher |

**What the first open runs on her library (5 migrations, all additive, all already run on her Macs' real libraries
by the 1.x releases):**

| Migration | What it does | Weight |
|---|---|---|
| `v1_33_mcp_gathering_grants` | Rebuilds the local-only MCP grant table to allow a gathering scope. It copies the rows, which are almost certainly zero on the phone | trivial |
| `v1_34_placement_by_block` | Adds one partial index over deleted placements | under a second |
| `v1_35_sweep_kill_verdict_markers` | Deletes orphaned local `sync_state` markers | trivial |
| `v1_36_fk_child_indexes` | Adds two indexes: `block(default_variant_id)` and `container_block(chosen_variant_id)` | the only real work: one index build over each table, about a second |
| `v1_37_arrival_provenance_and_pin` | Adds two nullable columns on `reading_post`, with no backfill and no outbox rows | trivial |

None of these rewrites a row of her writing. The only one-way part is that once they run, the store carries them
(see g5 on rollback). Source: `Sources/VariorumCore/Persistence/Migrations.swift:1071–1221`.

**What the phone has been doing since the marker moved:** every round refuses at its start, before it reads the
outbox and before it calls the server (`SyncEngine.verifySchemaLockstep` in the old tree). The outbox stays whole,
the cursor doesn't move, and the sync row reads **"Sync paused — Variorum needs an update"**. Anything she wrote on
the phone since then exists only on the phone until the new build's first round (SyncSpec §12).

---

## Before the cable — two answers from her

1. **Did she write anything on the phone since about 2026-11-07?** If yes, it exists only on the phone right now.
   That makes the safety copy (step c) a must. If no, the copy is insurance.
2. **Safety copy: yes or no?** (Recommended: yes. It takes a few minutes and a few hundred MB on this Mac.)

---

## a. Identify the device

**[HER HANDS]** Phone on the cable, **unlocked**, screen on. Answer "Trust This Computer" if it asks. Developer
Mode must still be on (Settings ▸ Privacy & Security ▸ Developer Mode).

```zsh
cd ~/dev/variorum
xcrun devicectl list devices | grep -v simulated      # her phone: Model iPhone18,1, an empty Reality column
# Pick the real iPhone's identifier into a variable, without printing it:
DEV=$(xcrun devicectl list devices 2>/dev/null | awk '/iPhone18,1/ && !/simulated/ {for(i=1;i<=NF;i++) if ($i ~ /^[0-9A-F]{8}-[0-9A-F]{16}$/) print $i}')
[ -n "$DEV" ] && echo "device picked" || echo "NO DEVICE — check the State column"
BUNDLE=io.lduarte.VariorumMobile
APP="$HOME/Library/Developer/Xcode/DerivedData/vm45-device/Build/Products/Release-iphoneos/VariorumMobile.app"
```

The State column must read `available (paired)` or `connected`. **`unavailable` means the phone is locked, asleep,
or not reachable**: unlock it and re-run. On 2026-11-12, before the cable, it read `unavailable`.

## b. Read what is installed now

```zsh
xcrun devicectl device info apps --device "$DEV" --bundle-id "$BUNDLE"
```

Expect Variorum, version 1.0, bundle version 1. That matches the new build, so the version string can't tell old
from new. **The discriminator is the phone itself.** **[HER HANDS]** Before quitting, she opens Variorum ▸ Settings
(on the Bookcase) ▸ the Sync row and reads it aloud. Expect "Sync paused — Variorum needs an update".

Optional baseline, read-only (from `~/dev/variorum`). Her account's devices and when each last pulled:

```zsh
Tools/prod-read.sh "select device_id, last_seq, seen_at from device_cursor where owner_id = '<her-account-uuid>' order by seen_at desc"
```

The phone's row is the one whose `seen_at` stopped around the marker-15 deploy (2026-11-07/08) while the Macs' rows
are recent. Note its `last_seq` and `seen_at`. If you don't have `<her-account-uuid>` to hand:
`select owner_id, count(*), max(seen_at) from device_cursor group by owner_id order by 3 desc` lists the accounts.
Hers is the one with the Pro, the Air and the phone. Don't paste ids into any file.

## c. The safety copy (before anything is installed)

**[HER HANDS]** **Fully quit Variorum** (app switcher, swipe it away) so nothing is mid-write. Keep the phone
**unlocked with the screen on** through the copy, because protected files are unreadable while the phone is locked.

```zsh
SAFE="$HOME/.variorum/phone-safety-copies/$(date -u +%Y-%m-%dT%H%M%SZ)"
mkdir -p "$SAFE" && chmod 700 "$HOME/.variorum/phone-safety-copies"
df -h "$HOME" | tail -1                                   # 71 GB free on 2026-11-12; the copy is far smaller

# 1. The listing (names and sizes only; nothing is opened)
xcrun devicectl device info files --device "$DEV" --domain-type appDataContainer \
  --domain-identifier "$BUNDLE" --subdirectory "Library/Application Support" > "$SAFE/listing-before.txt"
cat "$SAFE/listing-before.txt"

# 2. The copy: the whole Application Support tree (the live library, its key file, Previous Libraries, any Backups)
xcrun devicectl device copy from --device "$DEV" --domain-type appDataContainer \
  --domain-identifier "$BUNDLE" --source "Library/Application Support" \
  --destination "$SAFE/Application Support"
```

**Check it copied** (names and sizes only; never open the store):

```zsh
du -sh "$SAFE"
find "$SAFE/Application Support" -type f | wc -l          # equals the listing's file count
ls -la "$SAFE/Application Support/Variorum/"              # must hold variorum.sqlite AND variorum-library-keys.json
                                                          # (plus -wal/-shm if present); compare sizes to the listing
```

- **Expected size: a few hundred MB, well under 1 GB.** Her library's store was about 79 MB, and about 150 MB after a
  first catch-up's free pages. Add a WAL of up to a similar size, and her pre-VM-8 phone library, which sits whole
  in `Variorum/Previous Libraries/`.
- **A store without its key file is unopenable** (CastleRules rule 5: a backup is the library plus its key file).
  If `variorum-library-keys.json` is missing from the copy, the copy is not done.
- The copy is as sensitive as her library: encrypted, with its key file wrapped under her secrets. It stays in
  `~/.variorum/phone-safety-copies/`, outside iCloud and outside every repo. Never commit it and never open it.
- **Whether this works on her phone's app:** a container can be copied off an app installed with a development
  profile and `get-task-allow`. Her app is signed that way, and the new build is too. The road is proven for a
  single file: on 2026-10-08 a key file was read off her phone with `devicectl device copy from`
  (`notes/plans/fixes/vx-99-pro-castle-apple-wrap.md`). A whole directory as `--source` is expected to work but
  hasn't been tried on her phone. If it refuses:
  - Copy the two essential files by name, `Library/Application Support/Variorum/variorum.sqlite` (with its `-wal`
    and `-shm` if the listing shows them) and `Library/Application Support/Variorum/variorum-library-keys.json`.
    Use the same command with each file as `--source` and a file path as `--destination`.
  - Or, **[HER HANDS]** in Xcode: Window ▸ Devices and Simulators ▸ her phone ▸ Installed Apps ▸ Variorum ▸ ⋯ ▸
    Download Container…, saved into `$SAFE`.
  - **If no copy can be taken:** the install itself never touches the data container (see d). The one thing a copy
    protects that nothing else does is the phone's unsent writing since 2026-11-07. If she has any, the next-best
    protection is her own hands: before installing, open each such note on the phone and copy its text out (share it
    to herself or to Notes). Everything else is already on the server and her Macs, and the account's passphrase or
    words recover a synced library (rule 27).

## d. Install in place

**Never uninstall first.** Never use `devicectl device uninstall app`, and never delete the app on the phone to
"start clean". Deleting the app deletes the library, its key file and its keychain items. The phone would have to
re-join and pull everything from scratch, and anything unsent would be lost.

```zsh
test -d "$APP" && codesign --verify --deep --strict "$APP" && echo "build OK"   # gate: never install an empty path
xcrun devicectl device install app --device "$DEV" "$APP"
xcrun devicectl device info apps --device "$DEV" --bundle-id "$BUNDLE"           # still 1.0 (1), as expected
```

**[HER HANDS]** The phone must be **unlocked** at the install moment. A locked phone fails with a disconnect (4000)
or a disk-image mount refusal; unlock it and run the install again. On any failed install the old app stays as it was.

What an in-place install keeps: the same bundle id, team and keychain groups, so iOS upgrades the app over its
existing data container and keychain items. That covers the library, `variorum-library-keys.json`, the Face ID item,
the sign-in, and this device's remembered library ID, device ID and fingerprint (CastleRules rule 21). The keychain
code (`KeychainCustodyLeaf`, `KeychainSyncKeysLeaf`, `KeychainMemoryLeaf`, `ProtectionKeychain`, `AuthSession`) and
the key-file format have zero changes since her phone's build. VM-8's own reinstall kept her sign-in standing
("the keychain session survived the reinstall").

## e. Her first launch — what healthy looks like

**[HER HANDS]**

1. Tap Variorum. **The lock screen, then Face ID**, as every day. If Face ID declines, she types her **passphrase**
   (the words also open it). Nothing else should be asked.
2. The library opens. The five migrations run inside that open, invisibly, in a second or two.
   - One new act may run at this open and is silent: VX-443's sweep deletes an old fingerprint-named
     `variorum-keys-<fp>.json` at the library folder's root, and only when the live key file already holds that key.
     It almost certainly finds nothing on her phone. The safety copy holds whatever was there.
3. Within seconds the round starts. Settings (on the Bookcase) ▸ the Sync row reads **"Syncing…"** (on a long round,
   "Syncing — N of M"), then **"Synced ‹time›"**. "Needs an update" is gone.
   - This is an incremental round from the phone's cursor, not a first catch-up. Expect seconds to a couple of
     minutes on wifi. Only if the phone's cursor is weeks old does it look like VM-8's 6-minute catch-up.
   - "Another change landed mid-sync — retrying" is normal: the one-writer belt.
4. **The two-way proof:**
   - On the phone, write a one-line note ("phone sync check").
   - On her Mac, in the /Applications Variorum (1.4, already marker 15; nothing on the Mac changes today), it appears
     after the Mac's next round.
   - Something written on a Mac since 2026-11-07 is now on the phone.
5. **If she edited the same paragraph on the phone (while paused) and on a Mac,** nothing is lost. The phone's text
   arrives as an extra take labeled "conflict" on that block (S5, SyncSpec §6). That is the design, not an error.

**Not healthy: stop, press nothing, go to g.** Any of these:

- a "from before this design" face
- a **Start fresh** offer
- "This is a different library than the one this iPhone last had open"
- "This is an older copy…"
- a key-file offer

## f. Confirm from this Mac (read-only)

```zsh
cd ~/dev/variorum
Tools/prod-read.sh "select device_id, last_seq, seen_at from device_cursor where owner_id = '<her-account-uuid>' order by seen_at desc"
```

The phone's row now has `seen_at` within minutes, and `last_seq` near the account's newest seq. Writes the phone
sent since the install (the Mac also writes, so this only supports her eye):

```zsh
Tools/prod-read.sh "select count(*) from container where owner_id = '<her-account-uuid>' and server_written_at > '<install-time-utc>'"
```

Her eye on the two-way proof (e4) is the acceptance. The reads only corroborate it.

## g. If something goes wrong

1. **The install refuses.**
   - Locked phone: unlock it and retry.
   - Developer Mode off: **[HER HANDS]** turn it on (the phone restarts) and retry.
   - **A signing or provisioning message** ("no valid provisioning profile", "profile not valid", "could not be
     verified"): **STOP.** Copy the exact message. Do not touch certificates or profiles; that is hers.
   - In every case the old app and its library are untouched.
2. **The app won't open, or crashes at launch.** Don't reinstall and don't uninstall. Pull the crash logs:
   `xcrun devicectl device info files --device "$DEV" --domain-type systemCrashLogs | grep -i variorum`, then copy
   the newest one with `copy from` (`--domain-type systemCrashLogs`). Stop and report. The library on disk and the
   safety copy both stand.
3. **The library won't unlock.**
   - Face ID fails: passphrase. Passphrase refused: the twelve words.
   - **Never** Start fresh, Make this my library, reset, or a key-file offer without the orchestrator reading the
     screen first.
   - Report the screen's words verbatim, never a secret.
4. **Sync refuses after the update.**
   - "Sync locked — this iPhone hasn't unlocked your account's sync keys": Settings ▸ Protection… ▸ type the
     passphrase once. VX-544's retry then loads the keys.
   - Still "needs an update": the old app is still running. Swipe it away and reopen, then check the install output.
   - "different schema versions": check `select sync_schema_version()` still reads 15.
   - "belongs to a different account": stop and report.
   - "Sync incomplete — some changes haven't arrived yet": wait one more round.
   - Anything else: read its words and stop.
5. **Rollback, honestly.**
   - **There is no old build on disk.** VM-8's build products are gone, and the install replaces the phone's app
     bundle. It could be rebuilt from the VM-8 tree (`8cba51e28`), but that build speaks marker 14 and refuses to
     sync against today's server: an app that opens and never syncs, which is where she is now. *(Inferred from
     GRDB 7's `DatabaseMigrator.runMigrations`, which ignores applied migrations it doesn't know, and from that
     tree's open path, which calls a plain `migrate`. It would still open the migrated store. Untested.)*
   - **The rollback for data is the safety copy.** Putting it back into the live place (`devicectl device copy to`)
     overwrites whatever the new build wrote, and the open then says "This is an older copy…" (rule 21). Last
     resort, at her word only.
   - For everything except the phone's unsent writing, the cleaner road is the account itself: the library is
     synced, and her passphrase or words recover it on a fresh join (rule 27).

---

## Open decisions (hers)

1. **The safety copy:** take it (recommended), and her answer to "anything written on the phone since ~Nov 7?".
2. **The version label.** The phone's build says 1.0 (1), like every phone install so far; her Mac says 1.4.
   - If she wants the phone to carry a label, it's a rebuild with command-line overrides: `MARKETING_VERSION=<her
     label>` and optionally `CURRENT_PROJECT_VERSION=<n>`.
   - That is neither a new build configuration nor a code change.
   - Without it, this build ships as 1.0 (1).
