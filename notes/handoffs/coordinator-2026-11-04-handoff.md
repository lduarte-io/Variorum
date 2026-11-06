# Coordinator handoff — 2026-11-04/05 (nov4coordinator)

The window ran from 2026-11-04 21:14 to 2026-11-05 ~16:45 MST, on the Pro. It covered two releases (1.1 and 1.2), seven merges plus two small fix PRs, the whole of wave 1 (VX-805, VX-809, VX-828), and the VX-781 pin belt.

## 1. Her checklist

- **Your real store.** `/Applications` is **Variorum 1.2 (build 11323)**, codesign strict OK. The one kept safety copy is **`Backups/safety-copies/A1-20261105-pre-1.2-refresh`**, cmp-verified identical to your live store at 16:4x. The older two A1s were pruned. Your live store hasn't been opened since 2026-11-04 19:38, so you haven't launched 1.1 or 1.2 yet. **Your first launch of 1.2 migrates the store to v1_36** (the migration 1.1 introduced). The Air is already on 1.1 (her word, 2026-11-05), so both Macs read v1_36 and no export rule applies.
- **The field guide in your real store is STALE** (VX-809's P-809-6). Re-seed it via Help ▸ Restore Field Guide… when you like. It's yours; nobody re-seeded it.
- **VX-855 (High, Todo)** is the crash at quit or teardown: the launch-time purge sweep reads while the pool closes. It was seen twice tonight in test hosts. It's the same class as **VX-657, which is marked Done**, so that fix didn't fully hold. A comment and a relation are on the ticket.
- **The calm-ask debris in the Debug defaults domain is CLEARED** at her word (2026-11-05, "you can clear the debug app thing"). 67 per-library `variorum.calmAsks.*` marks belonging to walk-minted libraries were deleted at zero instances. The current dev library's mark (`e11e5233…`) and the global counters were kept. The backup is `~/.variorum/debug-defaults-before-calmasks-clear-20261105T170157.plist`.
- **VX-808's mirror deploy** (the lockstep, the first marker bump with real users behind it) runs only at your go, after VX-808 merges. VX-805 shipped no DDL and owes no deploy.
- **Bundles:** #260, #262 and #263 were closed by the sessions with you. **#261 (VX-805) is recorded RESOLVED in this PR** from your walkthrough with me: `daily_deleted` kept; all wording kept, with VX-867 and VX-868 for the two nits; behavior calls kept; VX-857 ruled.
- **Tickets born this window:**
  - **High:** VX-855.
  - **Medium:** VX-857 (books never span wings, under VX-808), VX-869 (alert-Cancel sweep), VX-878 (new umbrella: Book doors & faces).
  - **Low:** VX-867, VX-868, VX-870, VX-872 (live two-device Journal round, Backlog).
  - **From the runs:** VX-850/851/852/854, VX-858/859, VM-39/40.
  - **Pending from vx-828:** an openNotes.remembered-clobber ticket (walks with empty libraries clear the per-Mac open-notes list).
- **Umbrellas re-cut at your word:** VX-808 = 811+821 · 803 · 857 · riders 775/776/777/859, keeping the sync slot and the lockstep. **VX-878** = 802 · 804 · 816 · 829 · 831, with no sync slot. They can run at the same time.
- **Still live and not under me:** VX-861, VX-877 and VX-882 (site-repo efforts on the Air), and vx-828's off-stage tail (its ledger writes landed; walk debris and its ticket remain).

## 2. Merges

| What | PR | Merge / commit | Notes |
|---|---|---|---|
| VX-779 marketing version → 1.1 pair | #219 | `1482cbd04` | last-gate pins 17/2 |
| **Release 1.1** (build 11006) | — | `f3771c146` | published + live 22:20; A1 pre-v1_36 |
| VX-781 pin belt | #220 | `af012aa67` | core 3649/492; no app window (my call) |
| VX-853 verify-pins versions-equal | #221 | `2f68875e3` | at her word, tonight |
| VX-805 journal cluster | #222 | `f1137c88b` | first wave-1 merger; Sync/ slot released after |
| VX-809 MCP door ergonomics | #223 | `fc82c88a8` | second; reconciled 805's seam |
| VX-828 editor & shell QoL | #224 | `8b9ced515` | last merger; owned the release-ready window |
| VX-871 sweep refusal wording | #225 | `c5de790ca` | her review waiver |
| VX-871 pin literal (test-only) | #226 | `fddbb72a5` | merged WITHOUT a coordinator GO (see §5) |
| **Release 1.2** (build 11323) | — | `d7b2b7c35` | published + live 16:3x; site `343ed99`; pins ✓ |

## 3. Stage numbers and timeline (`~/.variorum/stage.log`)

There were 17 session windows plus bridges.

| Window | Time | Minutes |
|---|---|---|
| vx-779 last gate | 11-04 21:42–21:46 | 3 |
| vx-779 1.1 release | 21:49–22:20 | 31 |
| vx-828 batch A | 11-05 01:49–02:12 | 22 |
| vx-805 Unit A | 02:13–02:53 | 40 |
| vx-828 batch D | 03:04–03:27 | 22 |
| vx-828 batch C | 04:15–04:40 | 24 |
| vx-805 Unit B | 04:40–04:52 | 11 |
| vx-828 batch C2 | 04:56–05:08 | 12 |
| vx-809 batch 4 (Castle walk) | 05:09–05:37 | 28 |
| vx-805 Unit C | 05:38–05:49 | 11 |
| vx-828 batch B | 05:55–05:59 | 4 (released at my ask for the merge gate) |
| **vx-805 merge gate** | 06:01–06:58 | 57 |
| vx-828 B+E | 06:59–(08:29 expiry) | 90 claimed; credits ran out at ~07:11 |
| vx-828 B+E walks | 10:38–10:52 | 14 |
| **vx-809 closing** | 10:53–12:11 | 77 |
| **vx-828 merge gate** | 12:30–13:42 | 71 |
| **vx-828 1.2 release-ready** | 16:01–16:34 | 32 |

The overnight stall ran from ~07:30 to 10:30, when every session ran out of credits.

MCP socket-harness turns (not stage claims) went to vx-809 three times, with holds on 805 and 828. Every red-on-old in them was on asserted content.

## 4. The calls I made

- **VX-781's merge was fenced behind the 1.1 release** (her word). The release GO carried VX-781's lockfile belt: a clean tree, a fresh DD, and a post-archive four-pin readout.
- **The main fence during both release.sh runs.** No commits or pulls in the release tree, because the build number is the commit count. For 1.2 it ran in `~/dev/variorum` itself.
- **VX-781 needed no app test window:** its app graph was identical to the shipped one.
- **The Sync/-custody slot went to VX-805** (explicit), and VX-805 released it at "nothing further owed".
- **F-14 (PROVISIONAL, in VX-809's bundle).** VX-818's read-only `willLockRoad` discriminator in `Shared/AppBootstrap.swift` was cleared without the slot, under six conditions. Later it was widened from `.lock` to `.reKey` on her R-818 text. The Fable ladder independently classed the lines as composition plumbing.
- **The MCP socket harness is cross-worktree shared.** A socket red under concurrency is no verdict. Merge-gating and red-on-old socket runs take an announced turn.
- **The shared unused-tags query was VX-809's to mint.** VX-828 vendored it byte-identical.
- **Ordering.** vx-828's walks went before vx-809's closing, so 828's ladder overlapped 809's window. vx-828 batch B released for vx-805's merge gate, because merge-gating outranks a batch walk.
- **Gates.** I accepted 805's gate with VM-34's standing phone red. I approved 809's test-only fix for main's stale Journal pin. I accepted 828's 11-line tree move after its whole-target run on filtered re-runs. I shrank the release-ready window's (a) to filtered suites, since merged main was code-identical to 828's gate tip.
- **The 1.2 bump was held** until her VX-805 answers were in (they changed no shipped bytes). It was published at her explicit word: "yes, publish it ot the website".
- **The VX-808 split → VX-878, and VX-857 → VX-808**, at her word.

## 5. What went wrong

- **I missed vx-828-batchBE's expiry for ~2 hours** (08:29 → found at 10:31). Every session had run out of credits around 07:11–07:30, and I had armed watchers only for bridge handovers, never for a live claim's expiry. So a silent holder plus an idle coordinator meant a dead stage. **Fix applied:** from 10:38 every GO arms a watcher that wakes me before the claim's expiry.
- **vx-805's gate report missed a red.** It named only TakesFindBoardTests, but BookRowMenuTests.theDailyJournalOffersArchiveNeverDelete was red on its tree by construction (VX-435 made the Journal deletable). Main carried that red from 07:00 until vx-809's merge. I accepted the line without the full failing list. From vx-828's gate on, I required every failing test by name.
- **My memory commits used `git commit -am`** and swept vx-828's uncommitted run-state file into my commit. Nothing was lost. Pathspec-only since then.
- **PR #226 merged without a GO** (test-only, harmless). vx-828 acknowledged it.
- **I described VX-857 wrongly to her** ("should books span wings?") before reading the ticket. It's a sync race that CAN leave a book spanning wings. I corrected it in the next turn.
- **My own idle HOLD lapsed at 15:43** unnoticed, with nobody waiting.
- **Problem Reporter dialogs were left up twice by sessions** that reported clean (03:27, 10:31). I closed both.
- **Session clocks ran fast in release lines** ("~11:17", "~14:35" against stage.log's 10:52 and 13:42). I recorded stage.log times.
- **The memory repo rejected pushes** with "fatal error in commit_refs_rules" for ~2 min around 16:23. A retry cleared it.

## 6. Process notes

- **FILE-vs-TYPE names** were caught in six requests tonight: BookStructureTests, WalkBuildRoundTests, MobileEditorTests, BookArchiveFacesTests, TutorialBooksChapterTests and MobileTakeStructureTests. A small `Tools` helper that resolves a name list to TYPE names would end the class.
- **Red-on-old runs with many issues** reliably trip swift-testing's encoder stack overflow at host teardown (VX-661's class): 7+ .ips tonight, none of them product. VX-855's class looks different: SQLCipher frames on a pool reader, no test frames.
- **release.sh can run in the main checkout,** so the main checkout itself must be fenced while it runs.
- **The cross-wing merge-order belt worked.** vx-809 pinned the Journal refusal at the TOOL level before vx-805 merged, so either order would have gone red if the wiring were missed.
- **Cleanup done.** Every effort's worktree and branch is gone (only `~/dev/variorum` remains). Five closed efforts' DerivedData were removed, +15 GiB, leaving 107 GiB free. The stray VX-781 DD was removed. The A1s were pruned to the newest after a cmp-verify.
