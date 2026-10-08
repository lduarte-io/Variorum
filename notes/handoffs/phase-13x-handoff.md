# Phase 13x — Library portability: the handoff (2026-10-08)

## Your checklist

*Status at 2026-10-08 ~02:30, her word: the twelve-words door told (VX-99); the Trash being emptied; /Applications refreshed to 0.9.2 (5589); PL-47 renumbered; #202 "fine for now"; the site brief is hers to carry next.*

1. **Hand the FAQ brief to the site agent** — the CURRENT edition is `notes/stargazing-help-faq-brief-2026-10-04.md` (updated 2026-10-08: its three 13x entries BUILT and verified; publish with the first public release carrying 13x). The product page `notes/brand/site/variorum-product-page.md` carries two fact corrections for your wording before its AirDrop lines publish. (The older pre-13x edition below was updated too, for the record.) The three held entries
   (*Moving to a new Mac* · *Restoring a backup* · *Can my library live in iCloud Drive?*) are un-flagged as built,
   each with a "✔ BUILT in 13x" note and the one new fact the drafts predate: after opening a copy, sync waits until
   **Resume Sync** is pressed. Facts are binding; 13s re-voices the words.
2. **Look over four wordings made after your ratification** — QUESTIONS **#202 (a)–(d)**: the staged read's temp
   copy, the fresh-slot failure sentence, the account-less banner variant, and the Castle/Apple-wrap notice's
   "from before Castle". Each is one line to change.
3. **VX-99 — your Pro's Castle/Apple-wrap anomaly (HIGH).** Its investigation session is running from the kickoff
   prompt you carried. **Wait for its answer on which door safely lands your twelve words** before typing them anywhere;
   avoid anything that says "regenerate" or "new words". The evidence is preserved at
   `~/dev/variorum-fixtures/pro-castle-apple-wrap-2026-10-08/` and in the A1 copy below.
4. **Empty the Trash** if you haven't — the deleted pre-follow hand-off folder (Apple-wrapped key file) sits there.
5. **The post-merge /Applications refresh** runs through the stage coordinator together with vx-82andmore's. Your Pro
   is at **0.9.2 (5544) from 0787f028** now; the refresh brings four small wording fixes made after that build (the
   lowercase "whole", the "from before Castle" notice, the fresh-slot failure sentence, the account-aware banner).
6. ✔ **Done at your word (2026-10-08):** 13o's duplicate became **PL-47b** (13r keeps PL-47). Was: renumber MobileSoul's duplicated **PL-47** (minted for both 13r and 13o) whenever you like — 13x took
   PL-48 and left the others alone.

## What 13x is (for a fresh session)

The AirDrop-your-library promise, made true by built doors and verified on real devices (the Pro → Air leg,
2026-10-08, real store, library whole):
- **File ▸ Send Library to Another Mac…** (also in Settings ▸ Data Safety) writes a folder: a sealed copy of the
  library plus its key file. Send the whole folder.
- **File ▸ Open Library…** (also on the welcome and waiting faces) classifies what was picked, unlocks it by the
  lobby's roads, confirms, then adopts: the current library and its key files step aside into
  `Previous Libraries/<stamp>/` beside it, after a safety copy; the copy lands; custody adopts the key that opens it.
  The picked file is never written (every read runs on a private staged copy).
- **Restore from Backup** (Data Safety) lists the backup folder's copies, each saying which credential opens it.
- **The restore hold:** an adopted library lands held; nothing syncs until the one **Resume Sync** press, which then
  catches up to the account. A Mac new to a library enrolls (Castle: the passphrase once — VX-100 makes it one ask
  instead of two).

## The record

- The plan file, whole: `notes/plans/phase-13x-library-portability.md` (THE PHASE CLOSEOUT is its last section).
- The four ladder reports: `notes/plans/13x-ladder-round1.md` … `round4.md`; your round-4 foci:
  `notes/plans/phase-13x-review-foci.md`.
- The Air brief: `notes/plans/13x-air-leg-prompt.md`; VX-80's record: `notes/plans/fixes/vx-80-castle-follow-recovery-door.md`.
- Safety copies: the Pro's A1 `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/Backups/safety-copies/13x-refresh-20261008T061038Z/`;
  the Air's `…/Backups/safety-copies/2026-10-08T064709Z-air-13x-leg-a1/` (on the Air).

## Open tickets born here

VX-95 (P-8 scan blind spot, Medium) · VX-99 (the Pro anomaly, High) · VX-100 (one passphrase ask, Medium) ·
VX-101 (Open Library offers the backup locations, Low) · VX-102 (landing residuals, Low). VX-81 stays open with the
Pro's no-crash follow as its data point.

## Process notes

- One commit (d2ca39f9) carries a Co-Authored-By trailer against your rule — recorded, never rewritten.
- The Air's agent amended a pushed main commit (f8ee5bb2, a board snapshot) to drop a stray trailer — against the
  never-rewrite-pushed-history rule; harmless here (a snapshot), but worth a word to that session's road.
- The Air can now build and run signed: an Apple Development cert lives on it and its UDID is registered, so the
  provisioning profile covers both Macs.
- The orchestrator switched from Fable to Opus mid-phase at your word (the Fable safeguards kept interrupting);
  every custody-touching subagent and reviewer stayed Fable.


## Overnight addendum — VX-106, 13x's last change (2026-10-08, her mandate)

**Done while you slept; nothing needs you except one wording question.**
- **VX-106 merged.** The two `PostureSwitchTests` that went red at 13x's merge were already fixed by VX-99's harness
  change by the time VX-106 started — so VX-106 delivered the guard instead: a new test that **locks the rule that a
  pending "passphrase changed elsewhere" notice can never delay the follow that removes an Apple-openable key
  file under Castle**. It turns red if anyone reorders those checks. PostureSwitchTests 70/70, Phase13pControllerTests
  50/50, a Fable cold review with 0 BLOCKER / 0 MAJOR.
- **No /Applications refresh:** the stage coordinator ruled it unneeded — VX-106 changed a test file only, and your
  5740 (from VX-99's merge) already runs the identical app code. 13s's end-of-run refresh installs main next.
- **One question for you — QUESTIONS #205:** in that rare world, typing your OLD passphrase into the follow says
  "That isn't your library's passphrase", which isn't quite true (it's the account's word that changed). Lean:
  say the passphrase was changed on [device] on [day]. A wording call for you and 13s.
- **Process lessons now in both phase skills:** the closeout Mac run covers suites for every changed SOURCE file
  (this is how the two reds slipped past 13x's close); a phase plan's STATUS banner is flipped at close (13o/13r/
  13y had stale OPEN banners — fixed); merged branches are deleted; run evidence is deleted at merge.
- **The Sync/-custody slot** passed to 13s's U1b at VX-106's merge, by the coordinator.
