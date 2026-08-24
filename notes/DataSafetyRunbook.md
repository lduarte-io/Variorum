# Variorum — data safety and restore

*Written by the app. The same text is in the repo at
`notes/DataSafetyRunbook.md`, and a copy is dropped into every backup
folder as `RESTORE.md` so it is beside the copies it describes.*

---

## 1. What protects your writing, in order

1. **The store on this Mac.** `variorum.sqlite`, in the app's
   container. This is the truth; everything else is a copy of it.
2. **Backups — frozen copies of that file.** Two destinations: one
   beside the store, one in a folder you pick. They are frozen, which
   is the whole point: they do not follow a mistake.
3. **The mirror (sync).** A PEER, not a backup. It converges — which
   means it replicates a deletion or a bad edit at sync speed. It
   protects you from losing a DEVICE, not from losing writing.
4. **The platform's own backups.** The sync provider keeps 7 days of
   server backups. They hold ciphertext; without your encryption
   passphrase they are unreadable, including by them. This is the
   net under everything and it is meant to die unused.

The one sentence worth keeping: **backups protect against LOSS; the
Trash protects against REGRET; sync protects against losing a
device.** Reaching for the wrong one is how people lose things.

## 2. Where the backups are

- **Beside the store** (always):
  `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application
  Support/Variorum/Backups/`
  In Finder: Go ▸ Go to Folder… and paste that path.
- **In your folder** (once you pick one in Settings ▸ Data Safety):
  `<the folder you picked>/Variorum/Backups/`

Files are named `variorum-backup-YYYY-MM-DD-HHMMSS.sqlite`, stamped
**UTC**, so they sort oldest-to-newest by name. Each is a complete,
self-contained database — no companion files are needed.

**Retention.** Beside the store: the newest 14. In your folder: the
14 most recent days that have a copy, plus one copy from each of the
4 weeks before those — about six weeks of reach. Note what that
window really is: it is how far back you can undo a mistake you did
not notice, and it is also how long a permanently deleted thing
stays readable inside these files (see §5).

**Backups only happen while the app is running.** A week the app was
closed is a week with no copies. That is why Settings ▸ Data Safety
leads with the date of the newest copy rather than with a promise.

## 3. Restoring a backup

**Read §4 first if anything has been deleted since the copy was
made.** Then:

1. **Quit Variorum.** Completely — the store must not be open.
2. **Copy the backup you want OUT of its folder**, to the Desktop.
   Take only the `.sqlite` file. You may see files ending `-wal` or
   `-shm` beside it: those appear whenever something opens a copy to
   read it, they carry nothing, and they are not part of the snapshot.
   Leave them where they are.
3. **Move the current store aside — do not delete it.** In
   `…/Application Support/Variorum/`, rename `variorum.sqlite` to
   `variorum-before-restore.sqlite`, and move any `variorum.sqlite-wal`
   and `variorum.sqlite-shm` out with it. Those two files belong to
   the OLD store; leaving them beside a restored file is the one way
   to corrupt this.
4. **Put the backup in place.** Copy your Desktop copy into that
   folder and name it exactly `variorum.sqlite`.
5. **Open Variorum.** It opens the restored store. Look for something
   you know should be there before you do anything else.
6. **Keep the file you moved aside** until you are sure. It is the
   only copy of everything written after the backup.

If the app does not open, quit it, put `variorum-before-restore.sqlite`
back as `variorum.sqlite`, and you are exactly where you started.

**Two things that look wrong and are not.** An older backup is brought
up to the current version the first time it is opened — that is normal
and takes a moment. And if Variorum opens with no window at all,
choose **File ▸ New Window**: nothing is wrong with your library, the
app just did not open one.

## 4. What restoring does to things you deleted

If this Mac syncs, restoring an older copy does not undo your deletions. Your account tells this Mac what you deleted since: ordinary deletions re-apply and the writing lands in the Trash, recoverable for the rest of its 30 days — and anything you deleted permanently stays permanently deleted.

If this Mac is not syncing, restoring is time travel: anything deleted after this copy was made comes back — including things deleted permanently.

## 5. What deletion means

Deleting happens in three stages, and only the third one is final.

1. **Delete.** The writing leaves your library and goes to the Trash.
   Nothing is gone; Put back returns it where it was.
2. **Thirty days.** It leaves the Trash and every other surface. At
   this point no door in the app offers it back — but its rows are
   still on the disk until the next stage runs.
3. **Permanent deletion.** Either you asked (Delete Now, Empty Trash)
   or the 30 days passed. The rows are physically removed here and on
   every device on your account. What makes this survive a restore is
   a small record of *which ids were removed* — no words, no titles —
   so a device that comes back with an old copy is told "that one is
   gone" instead of putting it back.

Permanent deletion removes writing from your library and your synced devices — not from backup files. If you restore a backup made before a permanent delete, the deleted writing does not come back into your library; but it is still inside that backup file, and stays there until the backup is rotated away or you delete the file.

The same is true of any backup outside this app — Time Machine, a
cloned drive, a folder in the cloud. And it cuts the other way too: a
backup that was rotated or overwritten AFTER you deleted something no
longer contains it. The retention window in §2 is the real horizon
for both.

## 6. Reading one backup without restoring it

Most of the time you do not want a restore. You want one note back —
and you want everything written since to stay where it is. Do §3
twice:

1. Follow §3 steps 1–5 to open the backup. Your real store is safely
   aside as `variorum-before-restore.sqlite`; nothing is lost.
2. Find what you want and **select and copy the text**.
3. Quit Variorum. Put `variorum-before-restore.sqlite` back as
   `variorum.sqlite` (moving its `-wal`/`-shm` back with it), and move
   the backup copy out.
4. Open Variorum — you are exactly where you started — and **paste
   into a new note.**

**Always copy out as new.** Never try to re-insert an old note "as
itself". Anything that comes back this way is a fresh note with a new
identity, which is what you want: it cannot fight with the record of
what was deleted, and it cannot be removed again by a rule that was
about the old one.

## 7. If the mirror is lost, or a device is

These are the two directions, and both have been done for real:

- **The mirror is lost or wrong.** Your Mac's store is the truth. The
  mirror is rebuilt by pushing this store back up to it. This has been
  executed live three times (twice at the encryption cutover, once at
  the multi-tenant rebuild).
- **A device is lost.** Sign in on a new one and it fills itself from
  the mirror; you will need your encryption passphrase, or the 12-word
  recovery phrase, because the mirror holds ciphertext. This is how the
  phone was set up.

Neither of these is a backup story. If what you lost is *writing*, the
answer is §3 or §6, not the mirror.

## 8. If you forget the passphrase

The mirror is encrypted with a key wrapped by your encryption
passphrase, with the 12-word recovery phrase as the second door. If
both are gone, the mirror's contents are unrecoverable — by anyone.
Your local store and these backups are NOT encrypted by that key, so
your writing is still here. Keep the recovery phrase somewhere you
would find it in a year.