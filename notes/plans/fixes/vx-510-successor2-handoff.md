# VX-510 — the SECOND orchestrator cutover (2026-10-24, R-510-29; Fable → a fresh OPUS session)

## THE KICKOFF (paste this into a fresh session on the Pro)

```
/architect-phase vx-510

You are the THIRD orchestrator of the run VX-510 ("Run: the first-run sync failures") — an OPUS session taking over at
her ruled cutover (R-510-29: the Fable orchestrator's safeguards stalled on the GUI driving; the ladder, the closing
stage batch and the re-walk's first leg are DONE). SHE IS ASLEEP: run everything through PROVISIONALLY to the very end
— the remaining walk leg, the restore, the closeout, the PR merge, AND the 0.10.1 release (authorized in advance by
R-510-22 + R-510-29; a RED gate holds the release and the morning summary says why). Read, in this order:
  1. <home>/dev/variorum-vx-510/notes/plans/fixes/vx-510-successor2-handoff.md — this file, WHOLE
  2. <home>/dev/variorum-vx-510/notes/plans/fixes/vx-510-first-run-sync.md — the run record, WHOLE; the
     sections THE SUCCESSOR'S RE-WALK (the exact machine state + your steps), HER CLOSEOUT ANSWERS (R-510-22…29),
     THE LADDER — ROUND 1/2 and the LIVE STATUS table are your charter
  3. the rest of /architect-phase's preflight (CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE — amended today at
     R-510-28 —, SurfaceContracts' protection bullet, the resiliency protocol, the master plan, TICKETS, QUESTIONS'
     tail).
Your work, in order: verify the machine state (below) → O-RW-1's check → the Castle leg (VX-527's live presses,
VX-501/VX-513/VX-517 live, region captures only) → the dev-store restore by the recorded inodes → stage release → the
closeout exactly as the record's re-walk section enumerates it (canon deltas, the QUESTIONS bundle, the triage, the
master plan, MobileSoul, canon-size, her handoff's last PENDING slots) → the PR "VX-510: …" as a MERGE COMMIT → the
release road (below) → the morning summary. Treat everything as claims to verify. Commits carry NO trailers of any
kind. She sleeps: no sounds, no ambient, no notifications — bundle everything for the morning.
```

## Role, as amended

- **Opus orchestrates AND walks** (R-510-29; R-510-5's precedent). The LADDER IS CLOSED (two rounds, 0 BLOCKER ·
  0 MAJOR total, every fix confirmed) — no further review rounds are owed unless YOU change product code, in which
  case the standing rules bind (pin red-on-old; a custody/editor-seam/Sync change wants a Fable cold look — avoid by
  not changing product code; walk-tool and doc changes are free).
- **PROVISIONAL-and-continue everything**; anything genuinely needing her is HELD and BUNDLED into the morning summary
  (the away-run rule). Never quit or touch a real-store instance; the dev store restores EXACTLY as recorded.
- **Captures: window- or region-scoped ONLY, never full-screen** (today's recorded privacy rule — one full-screen slip
  caught her personal content; deleted; her "not a problem", but the rule stands).

## The machine state (VERIFY, don't trust — the full detail is the record's THE SUCCESSOR'S RE-WALK section)

- Stage claim `vx-510` HELD (renew with `Tools/stage renew --who vx-510 --minutes 240`). App RUNNING: the walk build,
  signed in as `castle`, fresh library, Settings open, NO act in flight (`pgrep -fl 'Variorum.app/Contents/MacOS'` —
  ONE instance, the stage checkout's path; her /Applications app must never appear and is never touched).
- Worktree `~/dev/variorum-vx-510` (branch `vx-510-first-run-sync`, clean, pushed at `213917a26`+); the detached walk
  checkout `~/dev/variorum-vx-510-stage` (the walk build in `App/Variorum/DerivedData/vx510walk`, the AX helpers in
  `App/Variorum/DerivedData/first-run-walk/bin`, the `.env.supabase.local` symlink added).
- The dev store's nine files aside in `…/Application Support/Variorum-dev-aside-vx510walk2` (INODES in the record —
  the restore must match); `…-pre` and `…-del` hold the pre-step and del-leg libraries (remove by their key files'
  `library` ids with their `Backups/<id>` folders at the close).
- Accounts: `del` re-minted TODAY (standard rev 1 — the live first-run proof); `castle` standard rev 15 under the env
  file's PASSPHRASE (your Castle leg moves it to PASSPHRASE2 at the key door — say so in the record); `std` rev 3
  untouched. Secrets ONLY via `~/.variorum/bin/type-prod-test-secret` / `stash-prod-test-words`; reads via
  `Tools/prod-read.sh`; confirms via `Tools/prod-confirm-test-user.sh` (hardened today, self-tested).
- GUI driving lessons (today's, all in the record): vis-ax matches placeholders now; FIELDS are addressed by role
  (`AXTextField`) — a bare label match can hit a HEADING; a DISABLED button answers AXPress as a success no-op, so
  verify an act by its LOG LINE (`road: …` in the launch's stderr log), never by the press; the walk's capture()
  shoots only the FIRST window — capture Settings by region; Settings' Protection pane may need the window resized
  taller for lower sections to exist in AX; O-RW-1 (check by closing/reopening Settings BEFORE the join).

## The release road (authorized — green gates only)

1. Gates already green: the ladder; the closing batch (core whole + VX-532's suite isolated ×2; Mac 5221/915 with the
   real-keychain arm RUN; phone 62/7 + 47/15, zero skips); the del leg's live first run (sheet confirmed, no relaunch,
   server-verified). Your gates: the Castle leg green + the restore clean.
2. The PR merges FIRST (merge commit, `VX-510: …`, member tickets close, the closeout ledgers done).
3. Then `Tools/Release/release.sh` (release mode) from main — version 0.10.1 — and follow its printed HANDOFF order
   verbatim (the site/R2 publish road; memory `variorum-release-publishing`). **Step 0's letter** (FirstRunDrillTests
   green + a scripted first-run-walk PASS) is satisfied for THIS release by the batch's drill run + today's live
   first-run leg (the record's evidence) — the scripted walk's set-up arm needs a VAULTLESS account and both fresh
   accounts now hold vaults; RECORD this reading in the release notes section of the record, and file one small ticket
   at the triage: the walk script wants a join arm or a scripted fresh-account pre-step (today's pre-step procedure is
   in the record).
4. The drafted release notes are in `notes/handoffs/vx-510-handoff.md` — present them in the morning summary.
5. The `/Applications` refresh to the published build: ONLY behind a fresh A1 safety copy at a ZERO-INSTANCE window
   (by path AND store — if her app is running, SKIP it and say so; never quit it). The dev store must be RESTORED
   before any Release build runs.

## The morning summary (her first read)

Lead with: the release (out or held, and why) · the Castle leg's rows (VX-527 presses, VX-501/513/517 live) · the
restore's inode check · the PR link · the canon-size line · her one remaining open item (none — all eight answered;
VX-533's trace question rides its ticket) · VX-529 is next (`notes/handoffs/vx-529-kickoff.md`).
