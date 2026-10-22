# Variorum 0.10

*Drafted at VX-329 for her rewrite before publicising (the 0.9.8 precedent). One line per bullet.*

## Your library's protection, rebuilt

- Every library is encrypted with its own key, and your twelve words and passphrase always open it — the new
  protection system is on for everyone in this release.
- Your library's twelve words live one click above the quick entry until you record them; the tutorial's last card
  asks for a passphrase beside them.
- Standard and Castle: Standard keeps quiet conveniences (your Apple account, this Mac), Castle is one promise — no
  road through Apple, ever — and Settings ▸ Protection carries the crossing doors.
- Backups are a pair — the library and its key file — kept beside your library and, when you pick one, in your
  folder; a backup always opens with the passphrase and words you had when you made it.
- Restore from Backup, Look inside and Make this my library: any copy opens read-only with its own secrets, and
  making one yours lands a fresh library with your previous one kept whole in Previous Libraries.
- The account's key doors: change your passphrase, reset a forgotten one, make new words — and a synced library's
  account follows in the same act.
- Lock Library Now: ⌃⌘L, the File menu, and an idle-lock dial in Castle.
- Sign-in sessions no longer trip over themselves: the "refresh token already used" sync stall after some sign-ins
  is fixed.
- The twelve-words fields now conceal what you type, with a reveal eye.
- Data Safety's "Export an unencrypted copy" writes the whole file again.
- Smaller fixes: the hold banner no longer mentions your account on a library that doesn't sync; a wrong account
  passphrase at the join names the account, not the library; the what's-new card waits politely after a restore.

## Under the hood

- The server's vault speaks the new shape (one schema step); your devices update together and the phone follows
  with its next build.
- Libraries from versions before 0.10 aren't opened by 0.10 — the app says so itself ("This library is from an
  older version of Variorum.") and offers Start fresh, which sets the old library aside whole in Previous
  Libraries; sign into sync or copy out first and your writing comes back.
