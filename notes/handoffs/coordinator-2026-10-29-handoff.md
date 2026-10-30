# Coordinator handoff: the night of 2026-10-29 → 30 (oct29coordinator)

The window ran from 23:50 MDT on 10-29 to 12:05 on 10-30. Its job was the Pro's stage for the two launch efforts: onboarding (VX-292 + VX-559) and the VX-105 readme seed. Both merged, and **0.10.7 (build 10595) is released and live on stargazing.tech** at your overnight word. Each effort wrote its own morning handoff, and those carry the detail:
- `notes/handoffs/vx-105-handoff.md`
- `notes/handoffs/vx-292-handoff.md`

This file is the stage's view, plus the one checklist across both.

## Your checklist (both efforts, deduplicated)

**The state you wake to:**
- **Installed:** `/Applications/Variorum.app` is 0.10.7 (10595), notarized, and passes `codesign --verify --deep --strict`. I checked it myself after the release. Nothing was launched from it.
- **The release:** the live appcast leads with 0.10.7, and the DMG at `dl.stargazing.tech/variorum/Variorum-0.10.7.dmg` answers 200. The 0.10.5/0.10.6 drafting lines (VX-708) are gone from the live feed. No command was refused and nothing stopped.
- **Your real store's A1** is `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/Backups/safety-copies/variorum-a1-0.10.7-release-20261030T173601Z/`. It's the only one left (I pruned 0.10.6's after a cmp check: all six files match the live store). The Pro's store is a replica you haven't opened since 10-25 03:29. It catches up whenever you next open Variorum there.

**Yours to press, on the Air, after 0.10.7 installs:**
1. **Help ▸ Restore Field Guide…** Both efforts changed guide text: the first lesson (VX-105), the classics walk and the restore-door labels (VX-292). Existing libraries only get the new text this way.
2. **Help ▸ Restore “readme”** adds your letter to your own library. If a live note titled "readme" already exists, the door opens that one instead. In that case, delete or retitle it, then press again.

**For your eye (taste calls, nothing broken):**
3. **Sea glass is now the default** (VX-710, P-292-2), applied when the app reads your settings. So any existing library that never picked a palette, probably yours, wakes up in sea glass. Classic in Settings ▸ General brings the old look back. The release notes say so publicly. If you meant fresh libraries only, it's one small change. It does not reach the phone (the phone's colour road takes no palette; verified).
4. **P-292-4** is the sea-glass depth (built bold). **P-292-5** is the row names: "Default" holds sea glass and "Classic" your old colours.
5. **The Prince's front-note sentence** ("Restarting the tutorial will restore this book to its default state as well.") is now false as stated. The tour mends deletions, but it never resets the book. Trim, keep or rewrite it; nothing was changed.
6. **A toast over the Bookcase lands on the lowest card in the band,** which is now the words card. The welcome card above it is clear. The fix moves a toast position canon rules on, so it waited for you.
7. **Wording found live:**
   - Step 8's "It opens on edit" is wrong on a note you left in Read.
   - The tour's last card doesn't mention the Settings stop.
   - **VX-719:** in Terminal, the tag field's prompt (181.72 pt) is wider than its ~176 pt box. It visibly clips by ~4 pt on main today, and sometimes wraps onto two lines. The fix is your wording or width call. VX-714 (the same test failing in Study) is probably the same mechanism; I linked the two.
8. **VX-105's S-1:** two Macs that each seed a fresh store and then join one account keep two readmes, because the born star blocks the dedupe. The proper fix is VX-711 (Low).
9. **QUESTIONS:** #253 and #254 (VX-105) and #255 (VX-292's thirteen P-292 items plus four copy observations). All taste-sized.

**Housekeeping (one click each, when you like):**
10. **VM-36 duplicates VM-34:** the same phone test, the same arms, the same values, red on main. My "mark duplicate" was refused by the permission classifier, so it's yours to mark.
11. **VX-105 carries an assignee (you),** against the never-set-an-assignee rule. Clear it if you want.
12. **`/Users/Shared/vx677-walk-shots`** is still waiting for your review, then deletion (from 10-29).
13. **Already done for you:** vx-292's handoff item 10 (the blocked branch delete) is DONE. I deleted `vx-292-onboarding` locally and on GitHub after confirming it was merged.

**Tickets born tonight** (all triaged by their efforts):
- **Low:** VX-711 (fold the born-starred readme across a join) · VX-713 (end card's "a short welcome note", fixed at the merge) · VX-714 (the masthead flake in Study) · VX-715 (the quiet receipt line truncates in a note's bottom bar).
- **Medium:** VX-712 (the "getting around" ⌘2/⌘1 lesson, closed HOLLOW at the merge).
- **Parked with reasons:** VX-716 (the seed-provenance marker) · VX-717 (the MCP chapter landing races a Finished book's mode seed) · VX-719 (the Terminal tag-field clip).
- **Duplicates:** VX-718 → marked Duplicate of VX-661 (the swift-testing encoder crash class; VX-661 is High at your word). VM-36 → a duplicate of VM-34 (item 10).
- **Closed:** VX-635 as a Duplicate of VX-105 (your word). VX-709 is the canceled husk, unlinked from everything (your word).

## Merges and the release

| Effort | PR | Merge commit | Merged (MDT) | Gate (the last whole-target tree) |
|---|---|---|---|---|
| VX-105: the readme, the restore doors, the guide's first lesson | #209 | `00746eef3` | 10-30 05:33 | `2a42ea7de`: 5,739 Mac tests. One red, VX-714, passed solo. No phone run was owed: its one `Shared/` change is a comment, and nothing in the phone app references the moved constant. |
| VX-292 + VX-559 + VX-710: the tour, the welcome card, sea glass | #210 | `c5ed35908` | 10-30 11:33 | `86cb411dc` code: 5,770 Mac tests (one red, VX-719, a pre-existing intermittent) plus the full phone target, 852 tests (one red, VM-36/34, red on main). The only non-notes file since was `ReleaseNotes-0.10.7.md`; WhatsNewTests re-ran green and I read the file as public copy. |
| **Release 0.10.7 (10595)** | — | from main `e91a76b5f` | 10-30 11:36–11:59 | A1 → release.sh (notarized) → FirstRunDrillTests 11/11 + the first-run walk, both arms PASS → /Applications swap, codesign PASS → R2 DMG verify PASS → appcast + site → appcast verify PASS. Run by vx-292, the later merger. |

## Stage numbers (from `~/.variorum/stage.log`)

Ten grants, no collisions, no lapsed claims, no stolen claims. About 5 h 54 m of stage time inside a 12 h 15 m window.

| Claim | Window | Minutes | Outcome |
|---|---|---|---|
| vx-292-u1 | 02:15:38–02:31:57 | 16 | U1 accepted (144 tests; one stale pin fixed) |
| vx-292-utheme | 03:08:00–03:13:18 | 5 | U-THEME accepted (86 tests; red-on-old exact). Its timestamps were verified inside the claim because it ran so fast. |
| vx-105-tests | 03:59:59–04:50:52 | 51 | 125 targeted + 5,739 full; one red, VX-714, passed solo |
| vx-292-u2 | 04:52:50–05:01:59 | 9 | Paused: the baseline was red (four never-run fixture pins plus a real gate hole on Finished books) |
| vx-105-walk | 05:02:46–05:27:33 | 25 | The fresh-birth walkthrough, legs 1–4 PASS. The dev slot was md5-identical after; prefs 412 = 412. |
| vx-292-u2 (re-run) | 05:29:51–06:01:06 | 31 | U2 accepted (141 tests; the gutted-Prince mend live) |
| vx-292-u3 | 06:55:38–07:47:33 | 52 | U3 accepted (132 + 122 tests; the six merge riders green; the full tour walked in both voices) |
| vx-292-u4 | 08:21:32–08:48:46 | 27 | U4 accepted after a mid-window fix (test oracles scoped per world) |
| vx-292-closeout | 09:38:34–11:31:44 | 113 | The merge gate: full Mac + full phone |
| vx-292-release | 11:35:50–11:59:28 | 24 | 0.10.7 released and live |

Disk went 98 → 76 → 84 GiB free at close. The Debug defaults domain went 274 → 501 keys, far from VX-695's ~2,700.

## The calls I made

- **The queue order after vx-105-tests:** vx-292-u2 went ahead of vx-105's walk. vx-292 was READY first, and it was the release's critical path, since it merged last. vx-105 merging earlier couldn't move the release. When u2 paused at 9 minutes, the walk slotted straight into the gap.
- **One folded release, run by the later merger** (vx-292). vx-105's four bullets were relayed. Nobody pushed main from the release GO to the publish verify.
- **Phone suites added to vx-292's merge gate,** because its branch changed two `Shared/` files. No phone run for vx-105, whose `Shared/` change was a comment only.
- **The real-store window dissolved at your word.** The guide re-seed is yours, on the Air. The readme mint became the Help ▸ Restore “readme” door. No session touched your real store tonight beyond the release's A1 copy and the `/Applications` swap.
- **Crash reports read myself, three of them:**
  - 06:56:54 and 07:03:53: swift-testing's own encoder at a stack guard. That's VX-661's class, with zero Variorum frames.
  - 11:15:08: a GRDB reader inside `LocalPurge.sweep` → `PurgeJanitor.collectRoots`, with the SQLCipher codec on a freed context. That's the test host closing a store under an in-flight sweep, VX-691's class. I posted the evidence on VX-691.
- **Removed at variorum-46's relay of your word:** the debug container's Sep-25 `Application Support/Variorum/` relic (a tgz kept in my scratchpad).
- **Cleanup:**
  - 0.10.6's A1, after the cmp check above.
  - Both efforts' orphaned DerivedData (2.5 GB + 3.6 GB).
  - The release walk's two set-aside test libraries in the debug container (3.5 MB; a tgz in my scratchpad).
  - vx-105's leftover walk library, deleted by vx-105.
  - The merged `vx-292-onboarding` branch.
  - Both effort worktrees are removed, and no effort branches remain on GitHub.

## What went wrong, honestly

- **I relayed a wrong claim.** I told vx-292, and nearly told you, that the sea-glass default would reach the phone. vx-292 checked it by reading the phone's one colour call, and so did I. I withdrew it before it reached your handoff as fact.
- **I described the headless store mint wrongly at first.** I said a session could do it alone. It needs your passphrase typed into the tool, and that tool predates the Castle rebuild. I corrected it when you asked, and the readme door replaced the road.
- **Your VX-105 answer #1 was recorded wrong** by the 10-29 packaging session ("replace Lillian's Start Here"), and my first report repeated that framing. You caught it. The correction, in your words, is on the VX-105 thread, and the memory files are fixed.
- **Sessions' reported times ran 20–30 minutes fast** (U2, U3). I corrected every line to `stage.log`, and the GOs from U4 on asked for stage.log times.
- **One push slip of mine:** zsh read `$C:refs` as a modifier, so the first VX-105 merge-up push failed harmlessly. It went through with braces.
- **GitHub ssh auth flaked from the Pro, ~08:20–08:30.** Identical git/ssh calls randomly got "Permission denied (publickey)", even though GitHub's status page said operational and the key is fine. One vx-292 push needed a retry. Nobody changed config. It didn't recur at the release.
- **vx-292's own corrected misread** (it isn't mine, but it cost stage time): it first called the masthead red a sea-glass regression. Measurement showed a pre-existing intermittent, VX-719. No code changed, and the gate stood.

## Process notes for the next coordinator

- **The early trial merge paid off.** Both test-file conflicts were named about nine hours before the second merge, and the second merger resolved them to the combined truth without a stage window.
- **Mounted pins that only run on the stage hide reds until a window.** U2's "baseline red" was four never-run fixture pins. Expect a first window to find its own test debt, and budget a re-run.
- **A release window can be short.** 0.10.7 ran in 24 minutes because release.sh is fast once the tree is final. The merge gate (113 minutes, full Mac + phone) is the long pole.
- **The permission classifier refused one Linear write** (VM-36 "mark duplicate", an external-system write) while allowing others. Don't route around it; list it for her.
