# Variorum — data safety and restore

*Written by the app. The same text is in the repo at `notes/DataSafetyRunbook.md`, and a copy is dropped beside your
library and into every backup folder as `RESTORE.md`, so it is beside the copies it describes.*

---

## 1. What protects your writing, in order

Two words first, because everything below depends on them. Your library is in one of two modes, chosen in
Settings ▸ Protection: **Standard** (the default) or **Castle**. In both, the library file on this Mac is encrypted
and sync is end-to-end encrypted — the Variorum server can never read your writing in either mode. The difference is
who holds a key. **In Standard the app keeps quiet conveniences:** a key in your iCloud Keychain (it travels with
your Apple account, Apple's account recovery can reach it, and any Mac signed into your iCloud can use it) and one
in this Mac's own keychain — so your library opens silently after login. **In Castle only you hold the keys:** your
passphrase and your twelve words, with Touch ID on this Mac if you chose it — and nothing reachable through your
Apple account or this Mac's login password opens anything, by design. Your twelve words have existed since the
moment the library was created, and your passphrase and words each can reset the other.

1. **The store on this Mac.** `variorum.sqlite`, in the app's container — encrypted. This is the truth; everything
   else is a copy of it. The key that opens it sits in this Mac's keychain (Standard: silently, after login;
   Castle: behind Touch ID — or nowhere at all if you chose *Always ask*) and, wrapped under your locks, in the
   small key file beside the library (`variorum-library-keys.json`): a copy under your passphrase, one under your
   twelve words, and — in Standard — one under your Apple account's key. The key file is not secret; holding it
   opens nothing. It also carries every earlier key the library has had, sealed under the current one — which is
   why your current passphrase and words open your older backups too.
2. **Backups — frozen copies of that file.** Each backup is a **pair**: the library's copy and its own key file,
   written together and never rewritten. Two destinations: beside the store, and in a folder you pick (the first
   time Variorum backs up, it offers to use iCloud Drive for that folder — a copy there survives the Mac). They are
   frozen, which is the whole point: they do not follow a mistake. A backup opens with the passphrase and twelve
   words you had the day it was made, with your current ones (the key file's carried list), or through this Mac's
   quiet road while it still holds that backup's key.
3. **Plain-text copies.** Every note as Markdown, into the folder you picked — **off unless you turn it on**: your
   library is encrypted, and a scheduled plain-text copy re-opens the door the encryption closed, so it is an
   opt-in. It is turned off again, with a notice, when you enter Castle. When on, these are not a restore road —
   each note rides with its takes (the "Alternates" sections) and its tags, plus one file per book, but not the
   saved-moment history, comments or book settings — and they are the one copy that stays readable if the library
   file itself is the problem, and they need no Variorum to open.
4. **The mirror (sync).** A **peer**, not a backup. It converges — which means it replicates a deletion or a bad
   edit at sync speed. It protects you from losing a **device**, not from losing writing. It holds ciphertext under keys
   only your devices hold; the server never has a key, and an account that signs in without the keys can neither
   read nor write it.
5. **The platform's own backups.** The sync provider keeps 7 days of server backups. They hold ciphertext; without
   your passphrase or twelve words they are unreadable, including by them. This is the net under everything and it
   is meant to die unused.

The one sentence worth keeping: **backups protect against loss; the Trash protects against regret; sync protects
against losing a device.** Reaching for the wrong one is how people lose things.

## 2. Where the backups are

- **Beside the store** (always):
  `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/Backups/`
  — inside it, one folder per library, and inside that one per Mac, so copies from different libraries and
  machines never mix. In Finder: Go ▸ Go to Folder… and paste that path.
- **In your folder** (once you pick one in Settings ▸ Data Safety, or take the iCloud Drive offer at the first
  backup): `<the folder you picked>/Variorum/Backups/`, the same library-and-Mac folders inside. One copy a day
  lands there; the ones beside the store run more often.
- **The plain-text copies**, in that same picked folder: `<the folder you picked>/Variorum/md-exports/` — one dated
  folder per export, holding every note as a `.md` file; written weekly while the plain-text option is on, the 4
  most recent kept. **These are readable by anything that can read the folder** — you, any program, and whatever
  syncs it if you picked a cloud folder. That is the trade this copy exists to make, and it is worth knowing you
  are making it.

Files are named `variorum-backup-YYYY-MM-DD-HHMMSS-XXXXXXXX.sqlite`, stamped **UTC**, so they sort
oldest-to-newest by name; the last eight characters name the key the copy is under. Each is a complete database,
and each has its key file beside it, `variorum-backup-YYYY-MM-DD-HHMMSS-XXXXXXXX.keys.json` — keep the pair
together: the copy is the writing, the key file is what opens it anywhere but this Mac.

**Retention.** Beside the store: this Mac's newest 14 pairs of this library. In your folder: the 14 most recent
days that have a copy, plus one from each of the 4 weeks before those — about six weeks of reach. Copies that are
not this Mac's, or not this library's, are never touched. Note what that window really is: it is how far back you
can undo a mistake you did not notice, and it is also how long a permanently deleted thing stays readable inside
these files (see §5).

**Backups only happen while the app is running and your library is unlocked.** A week the app was closed is a week
with no copies. That is why Settings ▸ Data Safety leads with the date of the newest copy rather than with a
promise.

## 3. Restoring a backup

**Read §4 first if anything has been deleted since the copy was made.** Then use the app's own door — nothing is
moved by hand:

1. **Settings ▸ Data Safety ▸ Restore from Backup** lists your copies, newest first, and each row says what opens
   it. (A copy somewhere else — AirDropped, on a drive — goes through **File ▸ Open Library…** instead; same
   doors.)
2. **Look inside first** if you only want to check what a copy holds — it opens read-only with its own secrets,
   the app writes nothing, and closing it forgets it (see §6).
3. **Make this my library** is the restore. The copy becomes a **new library** — a fresh identity and a fresh key,
   in the mode you are in now, under your current passphrase and words — and your current library steps aside
   **whole** into `Previous Libraries/`, beside your backups, where you can look inside it or make it your library
   again. Nothing is deleted by restoring, and the copy itself is never changed.
4. **With sync on**, the restored library lands held: no sync runs until you press **Resume Sync** in the banner,
   so you can look around first. Resuming catches up with your account — notes you deleted since the copy will
   leave again; edits made since will come back.

If you put a backup pair into the live place by hand instead, the app still opens it — and says once that it is an
older copy of your library — but the doors above are the honest road: they keep your current library whole and
aside, automatically.

**Two things that look wrong and are not.** An older backup is brought up to the current version the first time it
is opened — that is normal and takes a moment. And if Variorum opens with no window at all, choose **File ▸ New
Window**: nothing is wrong with your library, the app just did not open one.

## 4. What restoring does to things you deleted

If this Mac syncs, restoring an older copy does not undo your deletions. Your account tells this Mac what you deleted since: ordinary deletions re-apply and the writing lands in the Trash, recoverable for the rest of its 30 days — and anything you deleted permanently stays permanently deleted.

If this Mac is not syncing, restoring is time travel: anything deleted after this copy was made comes back — including things deleted permanently.

Either way, the deleted writing is still inside the backups themselves — that is what they are for. To bring a
piece back out, don't restore the copy or let it sync: **Look inside and copy it out (§6).**

## 5. What deletion means

Deleting happens in three stages, and only the third one is final.

1. **Delete.** The writing leaves your library and goes to the Trash. Nothing is gone; Put back returns it where it
   was.
2. **Thirty days.** It leaves the Trash and every other surface. At this point no door in the app offers it back —
   but its rows are still on the disk until the next stage runs.
3. **Permanent deletion.** Either you asked (Delete Now, Empty Trash) or the 30 days passed. The rows are
   physically removed here and on every device on your account. What makes this survive a restore is a small
   record of *which ids were removed* — no words, no titles — so a device that comes back with an old copy is told
   "that one is gone" instead of putting it back.

Permanent deletion removes writing from your library and your synced devices — not from backup files. If you restore a backup made before a permanent delete, the deleted writing does not come back into your library; but it is still inside that backup file, and stays there until the backup is rotated away or you delete the file.

The same is true of any backup outside this app — Time Machine, a cloned drive, a folder in the cloud. And it cuts
the other way too: a backup that was rotated or overwritten AFTER you deleted something no longer contains it. The
retention window in §2 is the real horizon for both.

## 6. Reading one backup without restoring it

Most of the time you do not want a restore. You want one note back — and you want everything written since to stay
where it is. **Look inside** is that door:

1. Settings ▸ Data Safety ▸ Restore from Backup ▸ **Look inside** on the copy (or File ▸ Open Library… for a copy
   from somewhere else). It opens read-only, with the secrets it had the day it was made — the app writes nothing,
   to it or to your library.
2. Find what you want and **copy the text out** (a note page offers Copy full text).
3. Close it — the app forgets the copy — and **paste into a new note.**

**Always copy out as new.** Never try to re-insert an old note "as itself". Anything that comes back this way is a
fresh note with a new identity, which is what you want: it cannot fight with the record of what was deleted, and it
cannot be removed again by a rule that was about the old one.

## 7. If the mirror is lost, or a device is

- **The mirror is lost or wrong.** Your Mac's store is the truth. The mirror is rebuilt by pushing this store back
  up to it. Nothing about your keys changes.
- **A device is lost or stolen.** In this order: Settings ▸ Account ▸ **Sign Out Everywhere**, so the device can no
  longer sync; Settings ▸ Protection ▸ **Replace All Keys**, so nothing it holds opens anything new — your library
  gets a new key carrying the old ones, and the account's locks change in the same act, so each of your other
  devices types your passphrase once; then change your account password. What the lost device can still read: in
  Castle, nothing — its copy is behind its own gate. In Standard, whoever can unlock that device can read what was
  already on it — that is Standard's trade — and that device is signed into your Apple account, which holds a quiet
  key, so also remove it from your Apple account (your Apple ID's device list, or Find My).
- **Someone was inside your Apple account, and you're in Standard.** Replace All Keys does not shut them out on its
  own: in Standard your Apple account keeps a quiet key to the new keys too. Secure the Apple account with Apple's
  tools, or **enter Castle** — entering deletes the library's Apple keys everywhere, so your library, your sync and
  every backup Variorum made stop opening through the Apple account (two narrow exceptions, named in the app: a
  backup locked under an Apple account you have since left, and a key file someone kept outside Variorum's own
  folders — neither reaches your current writing).
- **Your account itself is in someone's hands.** Delete it (Settings ▸ Account — your account password, a typed
  phrase, and a fresh sign-in) and set sync up again under a new one: every library on your devices stays and
  uploads to the new account.

The rule behind all four, once:

- a passphrase or twelve words merely **seen**: change or make new ones. Your devices keep syncing, and the old
  secret stops working on each once you have used the new one there.
- a leaked account password: Sign Out Everywhere, then change it.
- someone who may **hold** your keys: Replace All Keys.
- in Standard, someone inside your Apple account: Apple's tools, or Castle.
- the account itself: delete it and set sync up again.

None of this is a backup story. If what you lost is *writing*, the answer is §3 or §6, not the mirror.

## 8. If you forget the passphrase

Your passphrase and your twelve words do not encrypt anything themselves — they are ways to hand the key back to
you when this Mac's own keychain cannot. What forgetting costs depends on your mode:

- **In Standard**, nothing today: the quiet roads still open your library on this Mac and on any Mac signed into
  your iCloud, and every backup they hold the key for. Set a new passphrase whenever you like — Settings ▸
  Protection ▸ **Reset forgotten passphrase**.
- **In Castle**, the same door resets it with Touch ID (on a Mac set to always ask, with your twelve words). If no
  device of yours still opens the library, your twelve words open it, and your sync: type them wherever the
  passphrase is asked. Nothing else opens it, by design — not Apple, not us.

And the floor, the same one the app's own pages state: **your passphrase or your twelve words — together with any
copy of your library — always open it.** A library whose every key-file copy and every backup are gone is gone;
synced libraries are the exception — your account's passphrase or twelve words recover them from the account.
