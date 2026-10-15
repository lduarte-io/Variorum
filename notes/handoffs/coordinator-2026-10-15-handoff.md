# Coordinator handoff, 2026-10-14 → 15 overnight (oct13coordinator)

The same coordinator session, kept past compaction at your word. This covers the window from the resume (13:08 on the
14th) to this morning. Your overnight word (~00:35): *"I am going to sleep, rule provisionally overnight in my absence
and leave me a handoff in the morning. 283 or 336 can merge last (order doesn't matter, whoever is done first), whoever
does should have a release build ready, write notes on what was updated (I don't have to review those notes, it's
fine), and push a release to the website so I can try the new things out tomorrow morning."*

## Your checklist

1. **No release happened overnight, and nothing merged.** Both runs' orchestrators hit their weekly API limits partway
   through the night and stalled until this morning.
   - **VX-336** (MCP wire tools & AI docs) finished its closeout window at 03:14. The whole Mac target passed on the
     merged tree apart from the standing reds:
     - VX-115;
     - VX-245/283's six `.fixedSize` sites;
     - VX-167;
     - one load flake that passed alone.
     It is now writing its ledgers and PR, then asks to merge. **It cuts 0.9.7** right after its merge (with the
     `/Applications` refresh), under the provisional rule below.
   - **VX-283** (Sidebar & Library polish) still has work before its merge ask:
     - U3's controls-row fix + window + re-walk;
     - U2 + its window and walk;
     - its Fable ladder;
     - its closeout window.
   - **Your Pro's app:** `/Applications` is still **0.9.5 (7503)**. 0.9.6 is on the website, so Sparkle will offer it.
2. **Rulings I made provisionally overnight.** Confirm or change:
   1. **The /Applications refresh runs at the release's end**, under the full rule card (A1 first, zero-instance
      checks that abort and never quit anything, install the build matching the website's). vx-283 had read your word
      as "the release replaces the refresh"; I ruled for the refresh, per CLAUDE.md's standing rule.
   2. **Who releases:** the night's last merger, per your word. VX-283 was nowhere near its closeout when VX-336 would
      merge, so VX-336 cuts 0.9.7 and you get something either way. If VX-283 merges later, it cuts 0.9.8 on top.
   3. **Main freeze** from the version-bump commit until `release.sh` stamps, because the build number is main's
      commit count.
   4. **The stargazing gate (R-VX184-4).** VX-336's branch puts the `https://stargazing.tech/variorum/mcp` link in
      `MCPSession.instructions`. That page returned 404 at 00:40, so I ruled that no build with the link could ship
      until the page was live. **vx-336 then reported your word to it (~00:15):** *"honestly - just go ahead and do
      the stargazing MCP link yourself. the stargazing agent doesn't have to do that part, you can do that part rather
      than the brief."* I heard that only through vx-336's relay. It built and deployed the page itself (site commit
      `2896a7f`). My own cache-busted probe at 00:44: `/variorum/mcp` → 307 → `/variorum/mcp/` → **200**, titled
      "Variorum and AI — stargazing.tech". I re-probe at the release GO.
   5. **Release notes unreviewed**, at your waiver, with each bullet on one line (the What's New parser trap until
      VX-343).
3. **Your rulings that came through the runs:**
   - **VX-287:** keep ⇧⌘W and live with macOS's Close Window in tabbed windows.
   - **VX-283's U1 design pass:** your two rulings, "follow only on her next act" and the reshaped fade.
4. **`default.profraw` is back** at `~/dev/variorum`'s root, untracked, from 10-14 20:36. It fails `release.sh`'s
   clean-tree preflight, so the releaser moves it to `/tmp`, never deletes it.
5. **Disk is at 40 GiB**, down from 76 at the resume. The runs' DerivedData trees are the main consumers; each run
   prunes its own as it closes.

## What merged

| PR | What | Merge commit |
|---|---|---|
| #164 | My 10-13 coordinator handoff + the amended stage-coordinator skill | `8a0b766f` |

Nothing else merged in this window. The 0.9.6 release (vx-246, 12:56–13:08 on the 14th) finished before it.

## The stage (from `~/.variorum/stage.log`, 13:08 on the 14th → 10:40 on the 15th)

- **21 working windows:**
  - **vx-283 ×15:** U1 and its fix legs, U1d, U3, plus four walks.
  - **vx-336 ×6:** U5, U6, U7, U8, U9 and the closeout window.
  Each U5–U9 window was a Mac batch plus a real-client MCP live round on the dev store.
- **No collisions.** Every dev-store window ended restored, byte-identical to its safety copy, and I re-checked each
  myself and pruned the spent copy. The dev store's safety-copies folder holds only your `castle-W1-20261013` repro.
  The dev store is Standard/unlocked.
- **Your real store and `/Applications` were not touched** in this window.
- **Your user-scope MCP registrations** fingerprinted the same before and after every live round
  (`bc64543e2f4e8e58`).

## The calls I made

1. **SEAMs:** each long window ran its tests first and paused before its dev-store copy, so a merge-gating run could
   slot in. None needed to, so I answered "continue" each time.
2. **Folds:** vx-283 folded test windows and walks into single claims, with a SEAM between them.
3. **Merge-gating first:** VX-336's closeout window went ahead of vx-283's unit windows.
4. **The three overnight rulings above,** plus the release-order rule.

## What went wrong

1. **The stage sat unheld twice.** Both times the log shows nobody used it.
   - 22:42–22:57: vx283-u1c released without pinging me.
   - **03:14 → 10:40:** vx336-close's runner released and then hit its API limit before reporting.
   The cause is the same both times: I only act when a message arrives, so a release with no message leaves the stage
   unheld until someone writes. The fix is a watcher on `stage.log` that wakes me on every RELEASED line; I'm adding
   it for the rest of this window.
2. **The overnight release didn't happen.** API limits stopped both orchestrators (vx-283's Fable reviewer hit its
   weekly cap, and vx-336's runner paused at its limit), so the plan "the last merger releases by morning" had no
   merger.
3. **vx-336's runner ran `claude mcp list` once (U6).** Its health check briefly spawned your user-scope `variorum`
   connector. Your app wasn't running, so it failed to connect and exited, and nothing changed. The command is now
   banned in every live-round and walker brief.

## Process notes

- **A runner that stalls after releasing** leaves the coordinator blind. A stage-log watcher closes that gap; it
  belongs in the skill.
- **Load:** at 02:27 the machine read load 114, mostly macOS's own overnight `mediaanalysisd` and Spotlight indexing
  (`mds_stores`, `corespotlightd`). Under that load the whole-target run produced one timing flake, which passed when
  run alone. Excluding the runs' DerivedData folders from Spotlight would cut some of that, but that's your system
  setting.
