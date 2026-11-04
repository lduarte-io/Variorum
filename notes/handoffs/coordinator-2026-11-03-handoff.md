# Coordinator handoff — 2026-11-03 (the night of Nov 3 → 4)

Session `nov3coordinator` ran the Pro's stage queue from 00:41 to 11:14 MST. You were off the Pro all night
with your app quit. Your rulings for the window: "merging a PR is allowed when the effort is done, making a
release is *not* allowed", and later "yes, you can refresh my applications". Three efforts ran and **all
three merged**. No release was run.

## Your checklist

**Your real store and `/Applications`**
- [ ] **The `/Applications` refresh was held for you, not run.** A Release build from merged main reports
      itself as **0.10.4 (build 10856)**, while your installed app is **1.0.1 (10682)**. Two of the
      project's twelve build configurations, the app's own Release among them, still carry
      `MARKETING_VERSION = 0.10.4`; they were missed at the 1.0 bump. And 1.0.1's number came from the
      release script, not the project. So any refresh from main between releases currently reports a
      lower version than your installed release. Ticket **VX-779**.
      My recommendation: no refresh between releases; your next release installs a correctly stamped
      build. The alternative is to fix the pair through VX-779, then refresh at your word.
- [ ] Your daily drive is untouched: **1.0.1 (10682)**, codesign undisturbed, no safety copy taken
      tonight. The one existing safety copy is kept:
      `~/Library/Containers/io.lduarte.Variorum/Data/Library/Application Support/Variorum/Backups/safety-copies/A1-20261102T150020Z`
      (from the 1.0.1 refresh). `~/dev/variorum-store-backups/` is empty. Nothing to prune.
- [ ] **When you do refresh:** the new build adds the `v1_36` indexes to your real store at first launch.
      After that, the installed 1.0.1 refuses the store, so rolling back means restoring the safety copy.
      An export from the Pro also won't open on the Air's 1.0.1 until the Air updates (the vx-502 rule).
- [ ] The held Release build (reads 0.10.4 / 10856) is at
      `~/Library/Developer/Xcode/DerivedData/Variorum-dnpxwqhpxdqrdjbunktnzoahckpd/Build/Products/Release`.
      Look at it or bin it.

**A minute or two at your hands**
- [ ] **VX-762's live lock-road check, on your Air.** Its library is in Castle, which is the original
      field case; the Pro's dev store is in Standard, so tonight's walk couldn't run it. Connect an MCP
      client, choose Lock Library Now, and confirm the connection drops and Activity says it was
      disconnected when the library locked.
- [ ] **VX-652:** VX-770 re-owned it (Todo, self-contained description), but unlinking it from its old
      parent needs one click from you; the API refused.

**Waiting on you**
- [ ] **VX-497**: the chunking question, re-owned by VX-500 for a sitting with you.
- [ ] **VX-504 / VX-508**: untouched, held as before.
- [ ] **VX-76**: VX-500 proposed closing it as a duplicate, by comment.
- [ ] **VX-775**: Needs Lillian (from VX-771).
- [ ] **QUESTIONS #257 (VX-500), #258 (VX-771), #259 (VX-770)**: each run's PROVISIONAL bundle.
- [ ] The three runs' own handoffs: `notes/handoffs/vx-500-handoff.md` · `vx-771-handoff.md` · `vx-770-handoff.md`.

**Tickets born tonight, for your triage** (Pre-launch left off every one; that's your call)

| Priority | Tickets |
|---|---|
| **High** | **VX-781**: xcodebuild intermittently rewrites `Package.resolved` upward and later builds adopt it; committed pins not enforced (see hazard 2) |
| **Medium** | **VX-779**: the stale `MARKETING_VERSION` pair · **VX-780**: test hosts migrate the shared dev store (hazard 1; filed by me, project yours to place) · **VX-773**: the release-config test target doesn't compile on main · **VX-782**: Takes' callout frame pads the row by 5 pt (a decoration moves the prose) · **VX-788**: every fresh `PaneSurfaceView` is born at the 24-pt seed (the flicker class root) · **VM-38**: a phone test red on main |
| **Low** | VX-772 · VX-775 (Needs Lillian) · VX-776 · VX-777 · VX-778 · VX-783 · VX-784 · VX-785 · VX-786 · VX-787 · VX-789 · VX-790 (Wording) · VX-791 · VX-792 · VX-793 · VX-794 · VX-795 |

**Things to know**
- **Main's phone suite is red on VM-38**, independently of tonight: identical red on main and on the branch.
- **Your Xcode Run (Debug) opens the dev store fine.** `v1_36` is on main now (see hazard 1).
- **The dev store tonight was Standard, not Castle**, and held by a restore marker, with the MCP switch
  off. Every walk restored it exactly; I checked the marker's inode and the Debug defaults against my
  own snapshots.
- **Your duplicate-rows report was the already-fixed VX-393.** VX-763's trace found it was your 10-18
  report re-pasted, the third filing. The one real bug it found, a dead book's MCP grant listed as live
  after a bind/un-bind, is fixed.
- **VX-652** (a Low rider) was deliberately not built: a new AppKit control at the night's edge was the
  wrong trade. Its design is recorded.
- Your open PRs **#211** and **#212** were left alone.

## Merges

| Effort | PR | Merge commit | Shipped | Gate evidence |
|---|---|---|---|---|
| VX-500, Run: the 0.10 window sync follow-ups | #215 | `e30cdf3b2` | 39 non-notes files: sync follow-ups, the protection faces, `Shared/AppBootstrap`, `v1_36` (two local-only FK indexes) | Mac whole: 5,804 tests / 1,006 suites passed. Phone whole: 852 / 139, one real red = VM-38, identical on main. Fable whole-diff ladder, 2 rounds, clean. |
| VX-771, Run: MCP agent ergonomics | #216 | `c2205da02` | 57 non-notes files: the MCP door, wire tools, Settings ▸ MCP | Walk: the switch-off road, live. Close: 287 tests / 42 suites passed (42 of 42 executed). Fable ladder closed at round 1. |
| VX-770, Run: takes & compare after 1.0 | #217 | `4be6bd7c5` | 29 non-notes files: Takes, Compare, the note views, VX-758's book date sort, VX-739's word count | Walk 16/17, then the W2 fix, then a re-walk 6/6. Mac whole on the merged tree: 5,846 / 1,019 passed **on the committed pins**. Phone: 18 of 18 types (86 tests). Fable ladder, 3 rounds, closed. |

## The stage

| Claimed | Released | Holder | Minutes |
|---|---|---|---|
| 01:37:07 | 01:53:08 | VX-500 (U2 suites) | 16.0 |
| 02:36:46 | 02:46:20 | VX-770 (batch 1) | 9.6 |
| 03:24:35 | 03:36:05 | VX-770 (batch 2) | 11.5 |
| 03:36:42 | 04:50:43 | VX-500 (closing: Mac whole, then the trace) | 74.0 |
| 04:51:35 | 05:03:40 | VX-770 (batches 3 + 4, at VX-500's seam) | 12.1 |
| 05:04:30 | 06:03:01 | VX-500 (closing resumed: Mac re-run + phone) | 58.5 |
| 06:03:46 | 06:47:58 | VX-770 (batch 5 + pre-ladder whole) | 44.2 |
| 06:48:58 | 07:18:03 | VX-771 (walk + close) | 29.1 |
| 07:40:10 | 10:59:23 | VX-770 (walk, W2 fix cycle, merge gate) | 199.2 |

Nine windows held 454 minutes of stage across the 562 minutes from the first GO to the last release
(81%). The remaining time was stretches when nobody was ready. Every hand-over went through a bridge claim
(gaps of seconds); no claim expired and no window was preempted. My own gaps without a hold: about one
minute at 01:53, and about five minutes at 02:46 while I traced the GitHub incident. Times are from
`~/.variorum/stage.log`: every session's clock ran ahead tonight, mine included.

## The calls I made

- **VX-500's merge gate widened to the whole Mac and phone targets** (from your sweep ask). Its diff had
  grown into `Shared/AppBootstrap`, the test init every host builds, which is the coordinator rule's
  whole-target trigger. The widened run then found `redoNeverAsks` red. It turned out to be a
  **pre-existing test race** (21/30 on the branch, 27/30 on main), not a branch regression, and it's now
  fixed test-only. I first told you it was a regression; that was wrong, and I corrected it.
- **No preempting a just-granted window** for a merge-gating one: VX-770's 30-second-old grant ran its
  course, and VX-500 went next.
- **One insert per seam**, and asking VX-500 whether a headless gap existed. That moved VX-770's window up
  by a whole 42-minute re-run.
- **Merges held through GitHub's incident** (02:50 to 05:47, "Incident with Pull Requests, Git Operations
  and Issues"). Pushes were rejected with the right key offered, so the fault was server-side, and I
  verified it before broadcasting.
- **VX-771 not allowed to run its closing window before VX-500's merge.** VX-500's merge brought non-notes
  code into main, which would have voided an earlier run.
- **Two merges held until their PR bodies were bare** (your word tonight), plus VX-771's duplicate
  **QUESTIONS #257** renumbered to **#258**.
- **The `/Applications` refresh held** (above).
- **Walk roads around the dev-store hazard:** VX-771 waited for VX-500's merge (Road A); VX-770 had a
  set-aside road ready and in the end walked the real store after merging main in.
- **Cleanup:** VX-500's build cache plus three orphaned caches of merged efforts (VX-724, VX-736) removed,
  freeing **10 GiB**. The older two weren't strictly inside this window; I removed them because their
  workspaces are gone and your 13x ruling deletes merged efforts' run evidence. I also asked VX-770 to
  drop superseded build trees when disk fell to 37 GiB. The window ends at **60 GiB free**.

## Hazards found tonight

**1. Test hosts migrate the shared dev store (VX-780).** `VariorumApp` always builds the live
`AppBootstrap()`, with no test-host gate at the entry. So every `xcodebuild test` launches the Debug app,
which opens the real dev store and migrates it to that branch's schema. `LibraryClassifier` then refuses
that store to any build that doesn't know the newer migration. Tonight VX-500's hosts put the dev store on
`v1_36` hours before its merge, and both walks had to be planned around it. VX-500's merge resolved it for
now. Nothing recorded this before.

**2. Fresh builds sometimes resolve packages upward, ignoring the lockfile (VX-781).** Builds in fresh
`-derivedDataPath` caches intermittently resolved **SQLCipher 4.20.0, swift-dependencies 1.17.2 and
swift-syntax 604.0.0** (plus swift-issue-reporting) instead of main's committed **4.18.0 / 1.14.1 /
602.0.0**. This happened even with a clean lockfile in the worktree, and the lockfile went dirty again
under a build that used `-disableAutomaticPackageResolution`. Nothing upgraded was ever committed, all
worktrees ended clean, and main's own build cache is on the committed pins. **The guard that worked:**
`xcodebuild … -disableAutomaticPackageResolution`, with the resolved pins read from
`SourcePackages/workspace-state.json` at build end. **Evidence gap, then closed:** which pins VX-500's and
VX-771's gate runs used can't be proven (I deleted VX-500's cache before reading its pins, and VX-771's
worktree was removed). But VX-770's whole-target gate ran the merged tree, all three efforts' code, on the
committed pins, and recorded them. Until VX-781 is understood, every session's `xcodebuild` should carry
`-disableAutomaticPackageResolution`.

**3. The release-config test target doesn't compile on main (VX-773).** A Release-config test run is
impossible on main today. The Release *app* build is unaffected, as tonight's build showed.

## What went wrong — mine

- **I reported a check that never ran.** My 02:10 probe was `timeout 60 log show … 2>/dev/null`. There's
  no `timeout` on this Mac, and zsh's builtin `log` shadows `/usr/bin/log`. With errors hidden, an empty
  pipe read as "nothing found". I re-ran it properly with `/usr/bin/log`, and the conclusion held: a system
  wake, no session drove the screen. Rule for me: never hide errors on a probe whose silence is the verdict.
- **I handed VX-770 a phone list containing two file names** (`MobileBooksTests`,
  `MobileTutorialWalkTests`: 13 suites that `-only-testing` would silently skip), after catching exactly
  that trap in VX-771's list the same night. Caught before it ran, and corrected to 18 types.
- **I told you VX-500's red was a branch regression** before the trace showed a pre-existing race.
- **I deleted VX-500's build cache before reading its package pins**, which is why hazard 2 had an
  evidence gap.
- **My first theory of hazard 2 was incomplete.** I said the upgrade came from a stray dirty lockfile; it
  also happens with a clean one.
- **I left the stage unheld for about five minutes** at 02:46.
- **My clock labels ran ahead** several times. I also gave you clock-time estimates early in the night,
  against your rule, then switched to order and dependencies.
- **My first `rm -rf` was blocked** by the harness's safety check (variable-built paths). I re-ran it with
  literal absolute paths, as the check prescribes.

## Process notes

- **Type-check every closing set's names at READY.** The file-name trap appeared three times tonight:
  VX-500's own verification, VX-771's list, and my list for VX-770.
- **Read PR bodies back at every merge ask.** Two of three PRs carried the attribution footer while their
  sessions believed them bare; the PR-creation path appends it.
- **Ledger numbers collide when two efforts close back to back.** The second merger renumbers after
  merging main in.
- **Re-derive a closing set from the diff at the merge ask**, not from when it was agreed; diffs grow.
- **Read a closed effort's `workspace-state.json` pins before deleting its DerivedData.**
- **All sessions on the Pro share one local memory repo.** One session's push carries the others'
  commits, so use pathspec adds there, never `git add -A`.
- **Main took several redundant "board snapshot" commits** in the first hour, from each session's bout
  start in the shared `~/dev/variorum`.
- **Your bare-PR word reached sessions unevenly.** Memory loaded before tonight's update didn't carry it.
