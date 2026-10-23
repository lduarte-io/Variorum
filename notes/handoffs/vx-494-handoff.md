# VX-494 — the morning handoff: finishing the 0.10 window (written 2026-10-23 ~04:40 MDT; FINALIZED ~09:25 MDT —
VX-494 merged and installed; nothing below is pending)

## THE PASTE-READY KICKOFF PROMPT (for her, in the morning)

```
/architect-phase vx-494 — finish the 0.10 window. The overnight session (Opus 5.5, at my word) fixed and closed the
first-catch-up bug; my Pro crossing already LANDED at 04:12. You take the window's remaining steps with me, in the
order the handoff gives. READ FIRST, IN FULL, YOURSELF: notes/handoffs/vx-494-handoff.md (this file — the night's
result, my checklist, the paste-ready Air and VM-8 prompts), then notes/plans/fixes/vx-494-catchup-hang.md WHOLE (the
record), then notes/handoffs/vx-488-kickoff.md (the window's held steps + appendices), then the standard preflight
(CLAUDE.md + canon, SyncSpec WHOLE, CastleRules WHOLE, SessionResiliencyProtocol). VX-494 is merged (see the night's
result for the PR and merge commit). Opus orchestrates and reviews (my ruling R-494-1 — Fable hit safeguards). I'm present: walk me through the checklist one step at a time, my hands where it
says so.
```

## HER CHECKLIST (in order — each step says whose hands)

1. **Read the night's result** (the section below). If anything there says HELD, start with that.
2. **Your Pro acceptance (yours):** open Variorum on the Pro and look your library over — it came back whole at 04:12
   on 0.10 (9093). The known per-Mac redo list after a fresh library: MCP client setups re-run when you want them
   (Settings ▸ MCP), the search index rebuilds itself, per-note mode/place memory and this Mac's store-scoped
   defaults start fresh. If you set the idle lock to Never for the crossing, set it back (Settings ▸ Protection).
   **The fixed build is INSTALLED on the Pro: 0.10 (9162)** (2026-10-23 ~09:20, from main at the VX-494 merge; A1
   `Backups/safety-copies/variorum-vx494-a1-20261023T150419Z`, 6 files cmp-verified; codesign OK; sha256 identical;
   NOT launched — its first launch migrates your library to v1_32, a local-only empty table). Check: About Variorum
   says 9162, and the sync row says Synced (the round is incremental now — your Pro is caught up). Rollback, only if
   you ever need it: the 9093 bundle is kept at `/Users/Shared/vx494-rollback/Variorum-0.10-9093.app` — but after
   9162 has opened your library, going back also needs that A1 (9093 refuses a store migrated past it).
3. **The Air (a Claude session ON the Air, then your hands):** paste APPENDIX A below into a Claude session running
   in the Air's own GUI login (ssh builds fail codesign). It installs the fixed build — it refuses to build from a
   main that doesn't contain the VX-494 merge. Then your Air crossing by hand: open Variorum → the pre-design face →
   Start fresh → sign in → Turn on sync → JOIN (type your account passphrase; a system Touch ID prompt may appear
   during the join — your finger) → the first catch-up. With the fix the DOWNLOAD takes about a minute (2,000-row
   pages; the live proof pulled ~110k rows in ~70 s) and a lock, quit or crash during it RESUMES; the SAVE then runs a
   few minutes at full CPU with the Library empty until it lands — a lock during the save waits for it (it is never
   thrown away). Leave it alone, on power, until the row says Synced. The
   Air's A1 is already taken (`variorum-vx329-air-a1-20261022T2330Z` + your Desktop copy).
4. **The release publish (at your standing word — already given):** the DMG + appcast road (memory
   `variorum-release-publishing`; the worked example `notes/handoffs/vx-348-handoff.md`). `ReleaseNotes-0.10.md` is
   approved as written; whether tonight's fix earns a bullet is your call (a draft line, yours to keep or cut:
   "A new Mac's first sync downloads far faster, and picks up where it left off if it's interrupted."). You send
   the testers' message yourself — the paste-ready block is in `notes/plans/vx-329-switch-day.md`.
   NOTE: the release build must be built from a main that CONTAINS the VX-494 merge.
5. **The site delta (you authorized either road):** hand `notes/stargazing-castle-rebuild-delta-brief.md` to your
   site agent, or have the session edit the site directly.
6. **The window close-out on main (the session's):** the vx307 deploy checklist flipped to RUN with the window's
   numbers; SyncSpec §12's HELD marker-14 entry gains its result; the master plan's closeout paragraph (the window's —
   VX-488 and VX-494 both merged without one, at the window's word); the VX-488 canon deltas in the two-file shape (the
   locked-row line in SurfaceContracts; VX-488's dated narrative into AppSpecRecord); `Tools/canon-size` reported;
   board snapshot; memory run-states. **VX-494's own canon already landed:** its contract lines at its merge
   (AppSpec §7's local-only block — `sync_pull_stage` + the `pull_stage` key; SyncSpec §3 + §5), its dated entry in
   AppSpecRecord and its question bundle QUESTIONS #239 on main at the merge; canon-size 125,087 / 150,000.
7. **VM-8 last (your kickoff):** APPENDIX B below — the phone's Castle catch-up, now naming VX-494's fix (the phone's
   first pull is the same class at the same scale, and it inherits the resumable download). **AMENDED at the window
   sitting (2026-10-23, her re-ruling R-494-12): VM-8 is DEFERRED behind VX-510 ("Run: the first-run sync failures" —
   the kickoff `notes/handoffs/vx-510-kickoff.md`); Appendix B stays paste-ready for after that run.**

## THE SITTING'S ADDENDUM (2026-10-23, the window's close — the day's tickets by priority)

- **Urgent:** VX-510 (Run: the first-run sync failures — NEXT, a fresh orchestrator; members VX-498 · VX-506 ·
  VX-507 · VX-509).
*[removed for publication]*
  keys — Pre-launch), VX-507 (the act confirms its first round — Pre-launch), VX-508 (the dormant Apple-wrapped
  *[removed for publication]*
  umbrella: VX-495/496/497/502/503/504/505/508).
- **Medium:** VX-502 (exports across local-only migrations — Pre-launch), VX-503 (the Standard join's Touch ID
  prompt), VX-506 (the pre-join wording; raised from Low on field evidence).
- **Low:** VX-504 (the store's free-page slack), VX-505 (the belt's words).
- **Closed at her word:** VX-492 (resolved by VX-494), VX-493 (fixed-by-VX-494, re-traced).
- The sitting's full narrative: `notes/plans/fixes/vx-494-catchup-hang.md` R-494-4…R-494-13; the release and site
  records in the same file (R-494-10) and `notes/AppSpecRecord.md`'s 2026-10-23 window entry.

**Your calls owed (bundle them at step 1 or as they come up):**
- **QUESTIONS #239 — the VX-494 bundle** (each item there in full): (a) F6 — v1_32 makes plain-text exports written by
  0.10 (9093) un-importable by the fixed build (T-8's `applied == known`); should LOCAL-ONLY migrations count?
  (b) R2-3 — does an actively resuming device count as "seen" by the purge horizon? (c) O-2 — the stage leaves free
  pages about the library's size on a fresh device's first catch-up (79 → 150 MB in the proof), and its backups carry
  them: accept for 0.10 + a compaction-design ticket, or hold the Air? (d) O-1 — the Standard join raised a system
  Touch ID prompt that, cancelled, still let the join complete: intended, and what does it guard? (e) VX-492/VX-493's
  closures (below); (f) Pre-launch on VX-495/496/497; (g) the one-writer belt's words, if it ever fires; (h) R3-1 — a
  lock during a first catch-up's SAVE waits for the save (as before this branch): keep, or pre-empt and redo? (i)
  VX-498.
- **VX-492** (Castle's idle lock fires during a first catch-up): a lock during the DOWNLOAD now costs a pause (the
  download resumes at the next unlock), and a lock during the SAVE waits for it to land — close VX-492 as resolved by
  VX-494, or hold the lock while a first catch-up runs?
- **VX-493** (a lock strands "Syncing…"): RE-TRACED — the lock replaces the whole services object, so the row can't
  strand; the real defect was the retired round downloading on in the background, fixed by VX-494's D3. Close it as
  fixed-by-VX-494 (re-traced)?
- **VX-495** (the faster server query, High), **VX-496** (the progress line, High), **VX-497** (the save's duration —
  one all-or-nothing transaction holding the writer minutes; the phone's risk, Medium): Pre-launch or not — your call
  per ticket.
- The VX-488 carry-overs still open: M1 (c) (a typed unlock in Castle loads no sync keys), P-VX486-1/-2 (the locked
  row's door label and line), VX-490 / VX-491 (Low).
- Filed from the night, for triage: **VX-498** (after turning on sync in Standard, the row kept "Sync locked" until a
  relaunch — Bug, Suspected, Low) · **VX-499** (a masthead layout test fails under the full Mac suite but passes alone
  — Test-only, Low).

*[removed for publication]*
you're done with it; with it, delete `~/.variorum/bin/type-throwaway-passphrase`,
`~/.variorum/dev-vault-throwaway-passphrase` and `~/.variorum/dev-vault-throwaway-words`, and remove the five allow
rules this night added to `.claude/settings.local.json` (the helper, `cliclick`, and the three WalkKit scripts).

## THE NIGHT'S RESULT (the overnight session fills this in)

- **The bug, settled:** there was no hang. A from-zero first catch-up of your ~108k rows needed ~16 silent,
  all-or-nothing minutes (11.6 downloading in 200-row windows, 4.3 saving in one transaction); every morning attempt
  was cut off before its save (the 10-minute Castle idle lock, then two quits) and restarted from zero. Left alone,
  your Pro's crossing landed at 04:12.
- **The fix (three parts, each with a pin that fails on the old code):** D1 — the pull window gets its own size,
  2,000 rows (~55 requests instead of ~550; the server's per-call cost barely depends on page size — measured
  read-only: 8 s timeout, ~1.5–3 s per call at the start); D2 — the download is staged in a local-only table
  (`sync_pull_stage`, migration v1_32), so an interrupted round resumes where it stopped; D3 — retiring a sync chain
  (a lock, a chain replacement) cancels its round instead of leaving it downloading in the background.
- **The fix as finally built:** D1 as above; D2's stage resumes only for the round identity that fetched it — the
  committed cursor, corpus key, device, stage format, lockstep marker and purge-ledger scan point — as one contiguous
  run, and an undecodable row discards it (one re-download, never a wedge); D3 — a retired round stops its DOWNLOAD
  between pages but never its SAVE (the save runs shielded; a lock waits for it, as before this branch).
- **The live proof (05:07, the throwaway, a generated ~110k-row book):** the fixed build's first catch-up downloaded
  the whole feed in 56 pages / ~70 s; the app was KILLED during the save; the relaunch re-downloaded nothing, saved
  from the stage, and committed at the head (the device cursor 110,424 = the head; "Synced 5:07 AM"; the Bookcase
  showed the 1,200-note book).
- **The ladder (three fresh Opus reviewers — the cap):** r1 1 MAJOR (a staged row that won't decode wedged sync) + 5
  MINOR + 4 NIT; r2 1 MAJOR (a staged row could escape the purge ledger and resurrect a purged note) + 3 MINOR + 2 NIT;
  r3 1 MAJOR (the retire's cancel reached the save) + 1 MINOR + 3 NIT. Every finding fixed by a fresh implementer with
  red-on-old pins and behavioral reverts, or dispositioned in the record; the final round checked line by line.
- **Evidence:** the 18 VX-494 pins green; the sync sweep 344/80; the core debug 3326/434 + release 3297/429 (the one
  red each, the known MCP timing load-flake, passes alone on this branch AND main); the full Mac suite 5118/898 (the
  one red a masthead layout test, green alone → VX-499); the full phone suite 808/126 green.
- **Merge + install:** PR #185 merged (merge `44226636b`; the merge-moment ledgers `ec94f64b8` — AppSpecRecord's dated
  entry, QUESTIONS #239, the in-flight row retired); VX-494 Done; the worktree and branch removed. The Pro runs **0.10
  (9162)** (step 2 above). The dev slot was restored whole at 06:03 (your dev library opened quietly with the
  October-20 hold standing). The throwaway still holds test user A's generated 110k-row book and a Standard vault under
  the throwaway passphrase — yours to delete with the project.
- **The dev slot:** RESTORED WHOLE at 06:03 (the walk libraries and their backups removed, your 9 dev files back by
  `mv` — same inodes, the plain relaunch's rule-21 notice once; the October-20 hold banner standing). Nothing remains.

## APPENDIX A — the Air install prompt (paste-ready FOR HER, for a Claude session ON the Air)

```
Install Variorum 0.10 on this Mac (the Air) — the VX-329/VX-488/VX-494 release window is live, at Lillian's
explicit say-so. The marker-14 mirror deploy is DONE; the Pro session handles everything else. Your one job is the
Air's /Applications refresh, nothing more.

Repo ~/dev/variorum, branch main: git pull --ff-only and verify the tip CONTAINS BOTH the VX-488 merge (e63602bac)
and the VX-494 merge (44226636b) — `git merge-base --is-ancestor <sha> HEAD` for each; refuse to build from
anything older. Variorum is QUIT on this Mac and must stay quit (pgrep -fl 'Variorum.app/Contents/MacOS' prints
nothing; if an instance appears, STOP and tell her — never quit or kill it yourself). The A1 safety copy is ALREADY
taken (Backups/safety-copies/variorum-vx329-air-a1-20261022T2330Z) plus her Desktop copy — do NOT touch the store,
do not launch the app.

1. Claim this Mac's own stage lock: Tools/stage claim --who air-0.10-install --reason "the window's Air install"
   --minutes 60.
2. cd ~/dev/variorum/App/Variorum && xcodebuild -scheme Variorum -configuration Release -destination
   'platform=macOS' -derivedDataPath DerivedData/release-0.10 build
   (a FAILED DerivedData from an ssh attempt may sit there — building over it is fine; "CoreSimulator is out of
   date" is noise; the ssh failure was codesign errSecInternalComponent, which your GUI-session keychain fixes).
3. On BUILD SUCCEEDED: rm -rf /Applications/Variorum.app && ditto
   DerivedData/release-0.10/Build/Products/Release/Variorum.app /Applications/Variorum.app
4. Verify: codesign --verify --deep --strict /Applications/Variorum.app (silence = good); the version reads 0.10;
   sha256 of the installed binary == the fresh product's.
5. Do NOT launch Variorum — her crossing is hers, by hand, after.
6. Tools/stage release --who air-0.10-install; report the tip SHA, BUILD SUCCEEDED, codesign output, version,
   sha256 match. Nothing else: no suites, no walks, no store reads — this Mac runs those only at her explicit
   say-so, which covers exactly this install.
```

## APPENDIX B — the VM-8 kickoff prompt (paste-ready FOR HER, after the whole window closes)

```
/architect-phase vm-8 — the phone's Castle catch-up. The Macs crossed to 0.10 (VX-329 PR #183, the VX-488 window
hotfixes PR #184, and the VX-494 first-catch-up fix PR #185; marker 14 deployed); my phone's build deliberately
refuses to sync until this lands — speed matters. Workspace: a main-based worktree (~/dev/variorum-vm-8); VM-5
retired the mobile branch, my phone runs main-built installs. Read first, in full: notes/MobileSoul.md (PL-47..PL-51
— PL-51 is this run's charter), the VM-8 ticket + its comments, notes/CastleRules.md WHOLE, notes/SurfaceContracts.md
(Doors — protection + portability), the vx-329 plan's phone records (the U1 F-U1-3 flag, the PHONE FIX LEG record
with F-PH-1/F-PH-2, the U4 record's F-U4-2/F-U4-3), notes/plans/fixes/vx-488-window-hotfixes.md (the Castle sync-keys
fix is core/shared — the phone INHERITS it, and this run's acceptance must prove the phone's own Castle first round,
Face ID gate — the same class the Mac just fixed), notes/plans/fixes/vx-494-catchup-hang.md (the phone's first pull
is the same ~108k-row catch-up: it inherits the 2,000-row windows and the resumable stage; iOS suspends background
apps, so a resumed download across an app switch is the phone's acceptance case — and the save still runs minutes
at full CPU, so the phone's save time is a number to measure and report — VX-497 is deferred to this run at my word:
once the build is on my phone I'll sign in and VX-497's investigation runs against the measured save; keep the VM-8
ticket current as you go so it can always get my phone back online), and MobileStructuralTests'
MobileNoRedirectSweepTests exemption list (every `why` names which face makes it reachable). The scope: the phone's
road faces — the Protection screen, the crossings (Face ID gate choice), the account doors + join, the words-card
band (VM-23), and HER PRE-DESIGN FACE with Start fresh (the shared fact and whole set-aside already compile for iOS —
only the face is missing). My wording calls (F-PH-1's Mac-naming model sentences, F-PH-2's leave sentence) are MINE —
bundle them, don't invent. Evidence: the phone suites green, a simulator walk, and the DEVICE INSTALL at the end (the
devicectl road) so my phone syncs against marker 14 — acceptance is my phone pulling my library whole, INCLUDING its
first round under my account's Castle mode. The diff touches custody-adjacent words and Shared/ protection code: a
fresh cold reviewer (Opus, at my word — Fable hits safeguards).
```
