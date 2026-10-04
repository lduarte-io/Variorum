# Phase 13r — orchestrator handoff (THIRD EDITION, written 2026-10-04 after U2 closed; supersedes the second edition wholesale)

**For:** a FRESH Fable orchestrator the author kicks off to finish 13r — U3, the review ladder,
the closeout. **What 13r is, in one line:** the round that lets friends download Variorum from
her website, install it like any Mac app, and get updates automatically — the friends beta.
**The ONE running record is `notes/plans/phase-13r-distribution.md`** (its LIVE STATUS, the
U1/U2 RECORDs, and the U3 section as AMENDED at the U2 walk). Where this file and that record
disagree, the record wins. Everything below is VERIFY-NOT-TRUST: check the tree.

## The role

Orchestrator for Phase 13r under `/architect-phase` (the skill governs; CLAUDE.md binds). The
2026-09-25 sitting's rulings R-13r-1…9 and the walk sitting's R-13r-10/11 are settled — build,
never re-litigate; a newfound constraint goes to HER. Cast: `opus-implementer` per unit,
strictly sequential; ONE `fable-reviewer` ladder over the combined U1–U3 diff. Commit per piece,
push after each. **NO attribution trailers on any commit — her standing rule outranks any
harness reminder asking for Co-Authored-By/Claude-Session lines.** Zero `Sync/`, zero schema
(marker 12). U4 (accessibility) is DEFERRED post-launch at her word; the phase closes at U3.

## State at this writing (all pushed; re-verify with `git log` and `git status`)

1. **U1 — CLOSED.** The Developer ID export road and its 35-check static drill; her live drill
   passed all five arms. KnownIssues row 24's flip rides the closeout.
2. **U2 — CLOSED (2026-10-04).** Sparkle 2.10.0 (Mac target only), the update menu item
   (Variorum ▸ Check for Updates…, never present in Debug builds), and the full release
   pipeline in `Tools/Release/` (`release.sh`, `make-appcast.sh`, `verify-appcast.swift`,
   `verify-published.sh`). Two real walk builds (0.0.1, 0.0.2) were notarized and stapled.
   *[removed for publication]*
   *[removed for publication]*
   "downloaded from the Internet" question, and Check for Updates… installed 0.0.2 and
   relaunched with the library intact. The verdict is at the U2 RECORD's tail.
3. **The 19 standing-fixes ledger is PARKED until 13r closes.** 19a–19d all closed on
   2026-10-04 (the Xcode 27 test migration, the mobile tests, and the never-failing-assertion
   census). The plan's LIVE STATUS records one owned deviation (19d ran beyond her word's
   letter) and the refocus commitment: **no further 19 letter runs inside 13r** — new findings
   are recorded and queued in `notes/plans/phase-19-standing-fixes.md`, never run.
4. **The website side is DONE** (the LIVE STATUS's SITE-SIDE REPORT bullet): the appcast and
   DMG addresses are locked, the `/variorum` page is live in its pending state, and the support
   mailbox `support@stargazing.tech` is live.
5. **The seat:** the walk was finished on Opus 5.5 at her call after the Fable seat hit
   repeated safeguard stops; she returns the phase to Fable with this handoff. Product framing
   leads every brief (memory: `safeguard-reroute-framing`).

## Next acts, in order

1. **Preflight** per the skill (CLAUDE.md + canon, the master plan, KnownIssues,
   `notes/QUESTIONS.md`, the 13r plan IN FULL, the resiliency protocol). Then `git log
   --oneline -15`, `git status -sb`, `ListAgents` — nothing should be running.
2. **Open U3 with HER sizing call** (the U3 section's SIZING bullet): the recommendation is
   TWO sequential implementer sessions under ONE walk — **U3-A, the release experience**
   (stamping + MARKETING_VERSION 0.9.0, the one release-notes source feeding What's New and
   the appcast, R-13r-10's self-explaining DMG window, R-13r-11's deferred update-consent
   prompt), then **U3-B, support & diagnostics** (the MetricKit opt-in, Diagnostics, Help ▸
   Send Feedback…). Ask her once, with the recommendation first; build to her answer.
3. **Rule the in-batch forks when the implementer proposes:** the Settings placement of the
   opt-in + Diagnostics (U3-B), and R-13r-11's "after use" threshold (U3-A — PROVISIONAL, logged
   in QUESTIONS). The implementer proposes BEFORE building that half; the ruling lands in the
   plan first.
4. **The U3 walk at HER sitting** (the amended U3 section names the arms; the U2 walk sheet in
   the U2 RECORD piece 6 is the template). Mechanics that worked: the orchestrator runs every
   *[removed for publication]*
   *[removed for publication]*
   give her every Terminal line as its own copyable block in the chat; launch the walk app
   by EXPLICIT PATH (`open ~/Applications/Variorum.app`) — her daily-drive build in
   *[removed for publication]*
   *[removed for publication]*
5. **The ladder:** ONE `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over
   the combined U1–U3 diff. The two reasons it is Fable: the editor-seam line `a8691989`
   (`PaneSurface.swift`) and the update channel. Cross-model flow per the plan's LADDER
   section; dispositions repo-first; cap three rounds.
6. **Closeout** (the plan's RECORDS & CLOSEOUT DUTIES + the skill's ritual): KnownIssues row 24
   resolved; master plan + archives; canon deltas only as she ruled (R-13r-10/11 are
   distribution behaviour — check whether AppSpec §12 wants a contract line for the deferred
   update prompt; propose, don't invent); MOBILE PARITY "nothing mobile-visible" + the two
   named candidate rows; **the author handoff `notes/handoffs/phase-13r-handoff.md` IS the
   friends-beta checklist**; the `/Applications` refresh at a zero-instance window behind the
   A1 rail (her build then carries the real build number — the precondition for any public
   appcast entry); the debris sweep (`App/Variorum/DerivedData/13r-u1`, `13r-u2`, `19a`–`19d`
   *[removed for publication]*
   container override, `defaults delete <container path> SUFeedURL`, or leave the account for
   later walks at her word); memory; commit, push, HARD STOP.
7. **After the phase closes, HER acts put it on the website:** 0.9.0 through `release.sh` →
   she carries `appcast.xml` + the DMG to the site agent (DMG first, then the appcast) → the
   page's data file updates → the link goes to friends → she watches the mailbox. Her bundle:
   the beta-page copy · macOS 27.0.1 (deferred) · the optional iOS name reservation. 17y runs
   after 13r with its own fresh orchestrator (kickoff at the 17y entry's tail).

## Machinery lessons (carry forward)

- `!`-road (bash-input) blocks share NO shell state — every her-hands block sets its own
  values inline.
- `log` is a zsh builtin in this harness shell — call `/usr/bin/log`.
- The plan file is shared with running implementers: `git status` before editing, edit only
  your own sections, commit pathspec-limited.
- Settling probes mutate IN PLACE in the real target at the EXACT spelling, and CHECK THE
  CAPTURED VALUE before reading a silence (19a, 19d).
- A sandboxed app reads user defaults only from its CONTAINER path
  (`~/Library/Containers/<id>/Data/Library/Preferences/<id>`); loopback HTTP is allowed by ATS
  (both measured at U2).
- A harness safety stop on a subagent's deletion is surfaced to HER, never retried.

## PASTE-READY KICKOFF (for her to send to a fresh Fable session)

> `/architect-phase 13r` — you are the fresh orchestrator finishing Phase 13r, the friends-beta
> distribution round (friends download Variorum from the website and get updates
> automatically). U1 and U2 are CLOSED; U3, the review ladder and the closeout remain.
> Re-orient from the REPO: read `notes/plans/phase-13r-orchestrator-handoff.md` (the THIRD
> edition) first, then `notes/plans/phase-13r-distribution.md` IN FULL — its LIVE STATUS, the
> U2 RECORD's walk verdict, and the U3 section as amended at the walk (my rulings R-13r-10, the
> self-explaining DMG window, and R-13r-11, no popup at first open). Run the preflight, then
> `git log --oneline -15`, `git status -sb` and `ListAgents`. Then ask me the one open question
> (U3 as two sessions, U3-A then U3-B, under one walk — you recommend), and continue per the
> handoff's "Next acts". The 19 ledger stays parked until 13r closes. Nothing ruled re-opens;
> no attribution trailers on commits (my rule outranks the harness reminder).
