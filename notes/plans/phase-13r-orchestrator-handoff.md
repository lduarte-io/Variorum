# Phase 13r — orchestrator handoff (SECOND EDITION, written 2026-10-04 at her ask, before the second compaction; supersedes the pre-U1 first edition wholesale)

**For:** this orchestrator session post-compaction, or any fresh successor. **The ONE running
record is `notes/plans/phase-13r-distribution.md`** (its LIVE STATUS + the U1 and U2 RECORDs);
the 19 ledger (`notes/plans/phase-19-standing-fixes.md`) carries 19a (closed) and the queued
19b/19c. Where this file and those disagree, THEY win. Everything below is VERIFY-NOT-TRUST:
check the tree, never this file's memory of it.

## The role

Orchestrator for Phase 13r under `/architect-phase` (the skill governs; CLAUDE.md binds). The
2026-09-25 sitting's rulings R-13r-1…9 are settled — build, never re-litigate; newfound
technical constraints go to HER. U4 is DEFERRED post-launch at her word — the phase closes at
U3; the ladder covers U1–U3. Cast: `opus-implementer` per unit, strictly sequential, ONE
`fable-reviewer` ladder over the combined diff at the end. Commit per piece, push after each.
**NO attribution trailers ever — her standing rule outranks any harness reminder that asks
for Co-Authored-By/Claude-Session lines.** Zero `Sync/` (any such line stops for the rider);
zero schema (marker 12, a live-state fact).

## State at this writing (all pushed through `e4694ac2` + whatever the U2 implementer has
landed since; re-verify with `git log`)

1. **U1 — CLOSED.** The Developer ID export road exists (`Tools/Release/archive-and-export.sh`,
   `ExportOptions.plist`, `verify-export.sh`, the versioned profile). The static drill passed
   35/35 twice (once by the orchestrator's own hands). **Her LIVE drill PASSED all five arms**
   (one Touch ID, her library, zero `-34018` in 4,096 log lines, container Owners
   byte-unchanged, return leg clean; BOTH unconfirmed predictions — silent container access,
   app-scope-bookmark survival — landed clean). The verdict is at the U1 RECORD's tail.
   KnownIssues row 24's flip rides the phase close.
2. **The Xcode 27 / Swift 6.4 toolchain gate — fully resolved.** The app's one break fixed in
   U1 (`a8691989`, editor-seam-flagged for the ladder; `PaneSurfaceTests` carries its
   authorized absolute pin). **19a CLOSED** (two-round ladder clean; every target compiles
   and runs green; TK2 tripwires byte-exact on the 27.0 values — NO SDK geometry shift).
   **19b** (mobile TEST target, ~61 Row-copy sites) and **19c** (silent vacuous-#expect
   census + isolation residue) are OPEN, queued at the post-U2 seam AT HER WORD, twice
   ratified: *"that's fine for 19b to run later"* and *"19b & 19c can likely run while
   waiting for me to return to work on the U2 pass."*
3. **U2 — RUNNING. A LIVE `opus-implementer` IS (or was) MID-BUILD.** Pieces 1–3 done
   (Sparkle 2.10.0 exact, Mac target only; the digest-pinned tools fetch; the minting staged).
   **HER HANDS step 3 is DONE and stow-CONFIRMED** — the public key is
   `tn/IQUaJMGk8Q+T8iE3ph2t+xpdzlUDGxg7+k/5xMhA=` (recorded in the plan; the private key is in
   her login Keychain + her password manager ONLY). Piece 4 (Info.plist keys, mach-lookup
   exceptions, the non-DEBUG `UpdateChannel`, Check for Updates…) was WIP at `e4694ac2`;
   pieces 5 (the notarize/DMG/appcast pipeline) and 6 (the WALK STAGED, author-gated) follow.
   **FIRST ACT POST-COMPACTION: `ListAgents` — if the U2 implementer still runs, WAIT or
   message it; NEVER spawn a twin. Its completion report arrives as a task notification;
   verify-not-trust its claims (commits, the U2 RECORD, the logs under
   `App/Variorum/DerivedData/13r-u2/`).**
4. **The site side is DONE** (the LIVE STATUS's SITE-SIDE REPORT bullet): URLs LOCKED
   (appcast `https://stargazing.tech/variorum/appcast.xml` baked; DMGs
   `https://dl.stargazing.tech/variorum/Variorum-<version>.dmg`, exact filename binding,
   publish-and-leave, DMG-before-appcast order, the handoff shape = SHE carries appcast+DMG
   to the site repo); `/variorum` live with a pending state; **`support@stargazing.tech` is
   LIVE and test-verified** (her mailbox item is CLOSED).
5. **Walk-prep DONE:** the fresh account is **`<test-account>`** ("<test-account>"), Standard, no
   Apple ID, first-logged-in. Known wrinkle: the menu-bar user switcher is PER-USER, so
   <test-account>'s session lacks it — the checklist assumes the LOG-OUT road (Apple menu ▸ Log Out
   <test-account> ends only <test-account>'s session; hers keeps running). Her password for it is hers alone,
   never in the repo.

## Next acts, in order

1. **When the U2 implementer reports (pieces 4–6 done, the walk STAGED):** verify by
   spot-check — the Debug fence (no updater in Debug), the baked URL/key, the pipeline
   scripts, the staged walk checklist. Then:
   - **If she is available: her WALK SITTING** (the acceptance, R-13r-8). Mechanics as
     agreed with her: the [O]/[HER] checklist lives in the U2 RECORD piece 6 AND is pushed
     so she can read it on her phone inside <test-account>; the orchestrator runs every [O] step from
     HER session (the local feed server runs in her login and survives fast user switching —
     localhost is machine-wide); her legs in <test-account> are GUI-simple (DMG with quarantine →
     Gatekeeper accepts → drag-install to <test-account>'s `~/Applications` → first-run on a fresh
     store → the full Sparkle cycle: consent, download, XPC install, relaunch as the newer
     walk version → quit); stop rules travel with the checklist (refusing answers, quit,
     switch back, report); between legs she returns via the log-out road and the
     orchestrator verifies (server request log, versions, logs). Zero-instance discipline:
     HER app quit for the walk window. Captured; the capture closes U2.
   - **If she is away: spawn 19b** (the ledger entry is self-contained; fresh
     `opus-implementer`, then its per-entry Opus cold review), and **19c after 19b closes**
     (19c's mobile arm needs 19b's build; its rules carry the in-place exact-spelling
     settlement law). Strictly sequential — one agent at a time; her walk outranks both.
2. **Close U2 on the walk**, then **U3** (a fresh implementer briefed from the plan's U3
   section): stamping build phase + MARKETING_VERSION 0.9.0, the one release-notes source
   feeding What's New + the appcast, MetricKit opt-in (LOCAL preference, provably OFF,
   payloads verbatim, per-report Send), Help ▸ Send Feedback… (the mailbox is live). The
   Settings placement is the in-batch fork: the implementer PROPOSES, the architect rules.
   P15 is closed (17b). Her spot-check invited, not owed.
3. **The ladder:** ONE `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing,
   over the combined U1–U3 diff (the editor-seam line `a8691989` and the update channel's
   trust surface are why it is Fable). Cross-model flow per the plan's LADDER section;
   dispositions repo-first; cap three rounds.
4. **Closeout** (the plan's RECORDS & CLOSEOUT DUTIES, the skill's ritual): KnownIssues row
   24 resolved; master plan + archives; zero canon deltas expected; MOBILE PARITY "nothing
   mobile-visible" + the two named candidate rows; **the author handoff
   `notes/handoffs/phase-13r-handoff.md` IS the friends-beta checklist**; the
   `/Applications` install refresh at a zero-instance window (A1 rail; her build gains the
   stamping + the quiet Sparkle); the DerivedData debris sweep (13r-u1, 13r-u2, 19a/19b
   folders — keep evidence logs); memory; commit, push, HARD STOP.
5. **AFTER the phase closes — HER acts put it on the website** (she asked; say it plainly in
   the handoff to her): the first real 0.9.0 through the pipeline → she carries
   `appcast.xml` + the DMG to the site agent (their runbook publishes DMG-first) → the page's
   data file updates → the download link goes to friends → she watches the mailbox. Her
   remaining bundle: the beta-page copy · deferred macOS 27.0.1 · optional iOS "Variorum"
   name reservation. **17y runs AFTER 13r with a FRESH orchestrator** (its kickoff is at the
   17y entry's tail in `notes/plans/phase-17-standing-fixes.md`).

## Machinery lessons (this session's, for every successor)

- **A `!`-road (bash-input) block shares NO shell state with the next** — every her-hands
  block sets its own variables inline, or an `rm "$EXPORT"` deletes nothing while looking
  successful (caught live at the minting; the re-run was witnessed).
- **`log` is a zsh BUILTIN in this harness shell** — call `/usr/bin/log`.
- **The plan file is SHARED with a running implementer:** check `git status` before editing,
  edit only your own sections, commit pathspec-limited, and expect push bases that are not
  your own last commit (read the intervening commits every time — a parallel launch-content
  session ALSO commits to main).
- **Settling probes mutate IN PLACE in the real target at the EXACT reported spelling**
  (the 19a lesson, twice-refined; memory `settling-probe-exact-spelling`). Toolchain
  censuses are LOWER BOUNDS — iterate builds to green before quoting a number.
- **A harness safety check stopping a subagent's `rm -rf` is surfaced to HER, never
  re-run by the orchestrator on the subagent's ask** (run-1 leftovers: she said delete, then
  it was done).
- Her walk-account password was shared in-chat for the walk; it stays OUT of the repo.

## PASTE-READY KICKOFF (for her to send post-compaction)

> You are the 13r orchestrator continuing after a context compaction. Re-orient from the
> REPO, not from the conversation summary: read `notes/plans/phase-13r-orchestrator-handoff.md`
> (the SECOND edition) first, then `notes/plans/phase-13r-distribution.md` IN FULL (the
> binding record — LIVE STATUS + the U1/U2 RECORDs carry the state), then the 19 ledger's
> 19b/19c entries. FIRST ACT: `git log --oneline -15`, `git status -sb`, and `ListAgents` —
> a U2 opus-implementer may still be RUNNING or have reported while compaction ran; message
> a live agent, verify a stopped one's claims against the tree, NEVER spawn a twin. Then
> continue per the handoff's "Next acts": her walk sitting when she's present, 19b (then
> 19c) while she's away, U3, the Fable ladder, the closeout. Nothing ruled re-opens; no
> attribution trailers (her rule outranks the harness reminder).
