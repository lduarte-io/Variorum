# Coordinator handoff — 2026-11-08 → 11-09 (nov7, wave 3)

## Plain English first (for you, with no context)

**What happened.** You ran the third wave of work on the Pro: eight pieces of work from seven sessions, with
everything after midnight ruled provisionally while you slept. All eight are merged to `main`. I was the stage
coordinator: I decided who used the Mac's screen and test machinery and when, so nobody's tests collided, and
I checked every branch before it merged. I didn't write or review anyone's code.

**What merged, and what each one changes in the app** (in merge order):
1. **VX-912, open-source gating** (PR #234). Readies the code for going public: a security re-check, a way for
   an outsider to build the app, a test host that can no longer report a false pass, and two sync corner cases
   around moving notes between wings.
2. **VX-914, walkthrough follow-ups** (PR #235). Fifteen fixes from your walkthrough. The MCP settings pane is
   back in one piece, the sidebar's AI section and the book masthead are tidied, ⌘⏎ files a quick note without
   opening it, and a round of wording.
3. **VX-931, `/Applications` holds releases only** (PR #236). A rule change, docs only: your installed app is
   only ever a real release, unless you name an in-between build yourself.
4. **VX-940, pre-open-source follow-ups** (PR #237). Your letter at the repo root, Settings ▸ Acknowledgments
   crediting every library the app ships, the lineage view naming Home, and three MCP sturdiness fixes.
5. **VX-913, fixes before the freeze** (PR #238). Search's header now follows the facet you click. Make a
   Gathering from Settings ▸ Tags lands in the wing you're looking at. An AI tool whose change really landed is
   no longer told it failed. The MCP server's start button can't race itself.
6. **VX-926, the test flakes** (PR #239). No visible app change. It fixed the test failures that kept
   interrupting everyone (MCP tests starving themselves, the test app crashing, a five-minute wait, tests
   writing into the dev app's settings). A six-run soak saw none of them come back, and no crash reports.
7. **VX-915, the recents sweep** (PR #240). Fourteen quick follow-ups. The quick-note pad can aim at another
   wing, and a double ⏎ no longer files twice. Compare's columns breathe and can start a comment thread.
   Callouts line up with plain text, History's lineage wording is fixed, the badge switch is split in two, AI
   tools can remove a version link, and the guide gained the compromise-recovery recipe.
8. **VX-849, typed-over rescue and offline unlock** (PR #241). The trust fix. A sync change or an AI edit that
   lands while you're typing in the same take can no longer overwrite your words, and your words can't
   overwrite it either: both survive, one as a "conflict" take. Unlocking while offline no longer leaves sync
   stuck for the whole session; it heals by itself once the network is back. Restoring a saved moment now
   keeps a copy of what it replaces.

**The release: what's ready, and what you do.**
**Variorum 1.4 (build 12299) is BUILT, signed, notarized by Apple, stapled, and accepted by Gatekeeper. It is
NOT published.** Nothing went to stargazing.tech, no appcast was made, nothing was deployed, and your
installed app wasn't touched.
- **The DMG:** `~/dev/variorum/App/Variorum/DerivedData/release/release-1.4-20261109T195120Z.noindex/Variorum-1.4.dmg`
  (sha256 `7079a347…`). Don't clean that DerivedData folder before you publish. The durable records (notary
  logs, dSYMs, pin check, RELEASE-INFO) are in `~/Library/Developer/Variorum/Releases/1.4/`.
- **It's built from main 3667835ba,** the merged wave, which passed the whole Mac suite and the phone suite.
  The first-run checks passed just before the build: the 11-test drill, plus the scripted first-run walk,
  both arms, on the vxtest test account. The new package-pin check, run for the first time, found all 16
  pins matching.
- **It deliberately stopped before the last step, the appcast** (the update feed). That step asks your
  Keychain for the signing key and writes 1.4 and its notes into the feed. After that, the notes can't be
  changed without a manual fix, so it waits for your approval.

**Your morning steps, in order:**
1. **Read the release notes,** `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.4.md`, which were
   drafted for you as public copy.
   - **If you edit anything:** a session lands your edit as a commit, then re-runs the first-run checks and
     `Tools/Release/release.sh --version 1.4 --stop-before-appcast` on the new commit. You get a new build
     number. The notes are built into the app, so the DMG must be rebuilt.
   - **If you approve them as they are:** go straight to step 2.
2. **Make the appcast** with the one command the build printed. It asks your Keychain password (Allow):
   `Tools/Release/make-appcast.sh --release --dmg <home>/dev/variorum/App/Variorum/DerivedData/release/release-1.4-20261109T195120Z.noindex/Variorum-1.4.dmg --version 1.4 --build 12299 --notes App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.4.md`
   (from `~/dev/variorum`).
3. **Publish on the site** in its publish-and-leave order:
   1. upload the DMG and verify it's reachable;
   2. copy in the new `appcast.xml`;
   3. bump the version;
   4. deploy, and verify.

   The site repo's `notes/variorum-releases.md` is the runbook; a site session runs it at your word.
4. **Install 1.4 in `/Applications`.** This is now the normal road (VX-931): quit nothing, take the A1 safety
   copy first, then install the release.

**Decisions waiting on you** (one line each; the file named holds the detail):
1. **The release notes:** approve or edit `App/Variorum/Variorum/Features/WhatsNew/ReleaseNotes-1.4.md`. The
   number 1.4 is provisional too. Any change means a rebuild (steps above).
2. **Publishing 1.4:** only at your word (steps above).
3. **The seven provisional bundles:** QUESTIONS #268 (VX-912), #269 (VX-914), #270 (VX-940, plus its
   cold-build addendum), #271 (VX-913), #272 (VX-926), #273 (VX-915) and #274 (VX-849), in `notes/QUESTIONS.md`.
   Worth your eye first:
   - P-849-6, which changes a ratified measure (#167's book-ownership tiebreak), in `notes/handoffs/vx-849-handoff.md`;
   - P-915-B6-1, the unlink rung;
   - VX-913's toast wording for VX-775 (#271a).
4. **VX-951** (Needs Lillian): a real MCP wire-order race, returned unfixed on purpose. See `notes/handoffs/vx-940-handoff.md`.
5. **VX-919** (Needs Lillian): the device-cursor cap is a production database script, written and reviewed but
   never run. Yours to deploy (`Server/supabase/maintenance/vx919-device-cursor-cap.sql`, with its rollback beside it).
6. **VX-956** (pre-oss): your ruling deletes the cold-build CI check. It isn't in any run yet; route it before the open-source flip.
7. **The Apple Feedback** for the test-app crash: the draft is in VX-926's record, and the five attachments are in `~/.variorum/vx661-feedback-ips/`.
8. **The field-guide re-seed in your real store** (Help ▸ Restore Field Guide…, A1 first): owed since VX-827,
   and grown by VX-914 (lesson 7), VX-915 (four lessons) and VX-940.
9. **Your Air drill** for VX-849, after 1.4 reaches the Air: lock it, go offline, unlock, come back online,
   and watch sync heal by itself. See `notes/handoffs/vx-849-handoff.md`.
10. **VX-691:** vx-849 recommends closing it, but its permission check refused the Linear change, so it's yours to flip.
11. **VX-912's open-source drafts:** your editorial pass on README, CONTRIBUTING, SECURITY, BUILDING and
    LICENSE; the ship-or-trim calls; and the GRDB fork's notice and tag ruleset. All in `notes/handoffs/vx-912-handoff.md`.
12. **Homeless pre-OSS items** from VX-913's kickoff: VX-773 and VX-854 never got your word.
13. **One unwalked check:** switching wings while the Make a Gathering sheet is open. Tests cover it, but the
    macOS 27.0.1 screenshot guard blocked the walk. See `notes/handoffs/vx-913-handoff.md`.
14. **The Air's own `~/.claude/settings.json`** still needs the attribution-off line. The Pro is covered.
15. **Linear auto-assigns tickets on close** (seen on VX-931 and VX-915's closures). Clear them if you mind;
    sessions never set an assignee.
16. **Housekeeping:** two old A1 store copies are in your `~/.Trash`, and VX-695 (the Debug settings bloat) stays open on purpose.

**What went wrong, honestly.**
- **Usage limits.** Your account's five-hour limits stopped me and the sessions twice on the 8th (~07:00 and
  ~10:30). One claim expired mid-run (vx-912, 08:03), and my own idle hold lapsed for seven minutes
  (13:31–13:38). Nobody used the stage in those gaps, and nothing was lost.
- **Load-induced failures.** Three times, a session ran heavy tests in the background while another session's
  window was live, so unrelated tests failed under load. Each was disclosed, and the failures came back green
  when re-run alone. After the third I set a rule against it (03:05), and it held.
- **A real regression,** caught at the last moment. vx-849's final full test run on the release code found
  that Compare had stopped saving a note's "leaving" moment correctly. The bug came from vx-849's own batch 1,
  and earlier gates never ran those tests on the combined code. vx-849 traced and fixed it with a pin that
  fails on the old code. A fresh Fable reviewer read the fix (it touches the editor's core), and the whole Mac
  suite re-ran green. That cost about two hours.
- **A check I missed.** I verified vx-926's branch, but its last closeout commit then edited the
  stage-coordinator skill file, which is outside `notes/`, and my check didn't cover it. It's a documentation
  correction with no effect on tests.
- **Small slips, all caught before harm:**
  - one watcher false alarm (armed after the go-ahead instead of before);
  - two fake test names that would have silently skipped tests;
  - vx-849's first deliberate-failure script that never actually applied its edits, which it caught itself;
  - vx-915's handoff left marked "draft", fixed at 10:4x.

---

## Your checklist
- [ ] **Release 1.4:** approve or edit the notes → make the appcast (one command, your Keychain) → publish on
      the site → install. The steps and exact paths are in "The release" above. Build 12299 is from main
      3667835ba; the DMG is under `~/dev/variorum/App/Variorum/DerivedData/release/…1.4…`.
- [ ] **Leftovers for after the release:**
  - the first-run walk's Debug build, `~/dev/variorum/App/Variorum/DerivedData/vx849-step0` (1.9 GB, kept warm in case your notes edit means re-running step 0);
  - the older release build folders (1.1–1.3) in `…/DerivedData/release/`, whose durable records are in `~/Library/Developer/Variorum/Releases/`;
  - the two walk libraries' items in the Debug keychain, from the step-0 walk.
  None of them is mine to delete.
- [ ] Decisions 1–16 above.
- [ ] Real store: `/Applications` = build **11840**. That's NOT the published 1.3 (11707); "1.3" is only a
      provisional label, from main fc0adff5a. It stays until you install 1.4 (VX-931). The A1 kept is
      `A1-20261108-pre-vx914-refresh`, in the container's `Backups/safety-copies/`.
- [ ] Tickets born this wave, for your triage pass:
  - VX-912 → VX-917–925
  - VX-914 → VX-927–930
  - VX-926 → VX-941, 942, 963–965
  - VX-940 → VX-944, 951, 952, 953
  - VX-913 → VX-959–962
  - VX-915 → VX-943 (built), 945, 947–950, 954, 955, 957, 958 (VX-970 cancelled as a duplicate; VX-701 reopened)
  - VX-849 → VX-966–969, 971, 972
  - yours → VX-931 (Done), VX-956 (pre-oss)

## Merges
| # | Effort (session) | PR | Merge | Tested tree → evidence | Time |
|---|---|---|---|---|---|
| 1 | VX-912 open-source gating (variorum-91; held the Sync slot) | #234 | f22ac20ee | e8d96c4d2 code: whole Mac 6,139/0 failed; phone 852 (standing caret red only) | 11-08 16:05 |
| 2 | VX-914 walkthrough follow-ups (variorum-a7 → vx-914) | #235 | cc6c8f188 | c2f21d856: whole Mac 6,231 (VX-701 green alone); phone 852 green; walk green | 18:10 |
| 3 | VX-931 releases-only rule (me, at your word; docs only) | #236 | 66d6f33cf | — | 22:24 |
| 4 | VX-940 pre-OSS follow-ups (variorum-d5) | #237 | e6b88acb1 | 7131d81c1: whole Mac 6,203 (2 load reds green alone); phone 852; core and MCP headless | 11-09 02:09 |
| 5 | VX-913 fixes before the freeze (variorum-fd) | #238 | 22dc8b28f | 333e87508: whole Mac 6,249/0; core 4,013 + 32 + 687 (1 socket-timing red green alone) | 04:47 |
| 6 | VX-926 test flakes (vx-926) | #239 | 598866e4a | 9d81917e6: M1/M2/M3 whole Mac (6,207 / 6,222 / 6,222; one VX-953 red green alone); core ×2 under load; MCP 691; 0 crash reports | 07:40 |
| 7 | VX-915 recents sweep (vx-915) | #240 | 961790b13 | 675c31453: whole Mac 6,294 (VX-701 green alone); phone 852; gate36 + 36b, all 73 types | 09:24 |
| 8 | VX-849 typed-over rescue (vx-849; Sync slot; LAST merger) | #241 | 70f88a926 | 7c3d7300a: whole Mac 6,367 (VX-701 green alone) + targeted 126; phone 857 at 861767f4d (the fix after it was Mac-only); core 4,070, MCP 703 | 12:3x |

Main after the wave: **3667835ba**. Canon size: 141,121 of 150,000, no crossing.

## The stage, in numbers
- **Span:** from my first hold (2026-11-08 05:22:52) to the release build's release (11-09 12:59:59), ~31.6 h.
  That includes the 10:31–13:38 usage-limit stop on the 8th and long stretches while efforts built and
  reviewed without the stage.
- **Use:** 36 session windows; ~17.7 h busy (1,063 min); 36 bridge claims, so no GO ever left a gap; 17 idle
  holds of mine.
- **Renewals and expiries:** 3 renewals. 2 claims expired: vx-912-b1-verify at 08:03 (the usage limit, held
  for it and then resumed) and my own hold, 13:31–13:38.
- **Disk:**
  - started at 91 GiB, and fell to ~40 GiB at its lowest (01:58), with cleanup asks to the sessions each time;
  - after my close cleanup, 77 GiB: I removed four orphaned DerivedData folders of closed efforts (vx-849,
    vx-940, vx-926, vx-915, ~14 GB) and eleven small no-plist test-result folders from tonight;
  - at your word earlier, the VX-808/VX-828 leftovers (~6 GB) were removed.
- **Crash reports:** zero Variorum `.ips` since 06:34 on the 8th. The three at 06:34 were vx-912's designed
  red-on-old. Problem Reporter never stayed up.
- **The Sync/-custody slot:** vx-912 (05:29–16:08), then vx-849 (22:16 → released at its "nothing further
  owed", 13:00). Never two at once.

## Calls I made
- **Merge order.** vx-912 and vx-914 merged first (her pair). Then vx-940 went before vx-926's soak, so one
  soak covered both. vx-913 went before vx-926's remaining soak legs, so the soak read the merged tree. vx-915
  merged third and vx-849 last.
- **Heavy background runs.** None during another session's window (from 03:05, after three load incidents).
  Soak legs each got their own claim.
- **The tested tree is the last whole-target window's tree.** After it, only `notes/` may change. A product
  fix after it means another whole-target run, which is why vx-849 re-ran the whole Mac suite after its fix.
- **Seams.** I split long windows at their seams so short merge-gating runs could slot in: vx-849's batch-3/4
  tests released at their seam for vx-915's merge gate.
- **Reorders to keep the stage busy.**
  - vx-849's batch 2 went ahead of vx-926's fold, which had to wait for vx-913's merge anyway.
  - vx-926's fold was split: the git half ran off the stage, and its build went at the head of its next claim.
- **Recurrences go back to their ticket.** vx-915's merge-gate red was VX-701 recurring, so VX-701 was
  reopened instead of a new ticket being filed. vx-926's spelling red was VX-953's family.
- **Release prep went to the wave's last merger** (vx-849), on my go-ahead:
  1. the version bump and the drafted notes landed BEFORE its closing sweep, so the sweep tested the exact release tree;
  2. then the first-run checks;
  3. then `release.sh --version 1.4 --stop-before-appcast`.
- **Stopping before the appcast was deliberate.** The appcast step reads your Keychain and writes 1.4 and
  its notes into the local feed. After that, an edit to the notes is refused and the version can't be rebuilt.
  With your notes approval pending, stopping first keeps them editable.
- **Editor-seam rule.** vx-849's late fix touched the editor's core (`PaneTextAuthority`), so I required its
  review disposition before the merge go-ahead. A fresh Fable reviewer read it cold: 0 blockers, 0 majors.

## Lessons
- **Re-verify at the merge moment.** Check the tip when the merge happens, not when the merge ask arrives;
  closeout commits can add non-notes files in between (vx-926's skill-file edit).
- **Arm a watcher before sending the go-ahead.** A session can claim within seconds, before the watcher has
  read its starting point in the log.
- **Verify test names against the tree.** `-only-testing` silently drops names that aren't type names: a
  file name like `MobileProtectionScreenTests` or `MobileEditorTests` reads as 0 executed for that type, and
  the run still reports green. Verify each name with a single-declaration grep in the checked-out tree.
  (`git grep` at a commit needs a different pattern: its `path:` prefix breaks `^` anchors.)
- **Deliberate-failure scripts must prove the edit applied.** vx-849's first scripted run used broken relative
  paths, so the "red" runs came back green with "Can't open file". Use absolute paths, and check the applied
  diff before each run.
- **The MCP rebind ask.** A pane-copied setup key no longer silently rebinds an approved name (the vx-620
  precedent is stale); this build asks. Walkers must refuse that ask and use a fresh client, or they'd move
  variorum-de's grants.
- **A whole-target run's own load can redden known flakes** with no second session running (VX-953 in M2,
  VX-701 at vx-915's gate). Re-run alone, and name both runs.
- **Release prep before the sweep.** Putting the version bump and the notes on the last merger's branch before
  its closing sweep means the sweep tests the exact release tree, and no non-notes change follows it.
- From the 8th: deleting a DerivedData directory breaks an APFS-cloned sibling that still references it; zsh
  doesn't word-split `-derivedDataPath`; and a simulator destination given by name can exit 70, so give it by
  device ID.
