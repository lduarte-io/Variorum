# Phase 13r — orchestrator handoff (pre-compaction insurance, written 2026-10-04 ~04:00 at the author's ask)

**For:** this orchestrator session post-compaction, or any fresh successor. **The ONE running
record is `notes/plans/phase-13r-distribution.md`** — this file adds only the orchestrator-role
specifics; where they disagree, the plan file wins. Everything below is VERIFY-NOT-TRUST: check
the tree, never this file's memory of it.

## The role

Orchestrator for Phase 13r under `/architect-phase` (the skill file governs; CLAUDE.md binds).
The 2026-09-25 kickoff sitting ruled everything product-flavored (R-13r-1…9 in the plan) —
BUILD TO THE RULINGS, never re-litigate; a newfound technical constraint goes to HER. Cast:
`opus-implementer` per unit, strictly sequential; ONE `fable-reviewer` ladder over the combined
diff at the end. **U4 is DEFERRED post-launch at her word (2026-10-04) — the phase runs
U1 → U2 → U3 and closes at U3; the ladder covers U1–U3.** Commit per piece, push after each,
NO attribution trailers. Zero `Sync/` expected (any `Sync/` line stops for the rider); zero
schema (marker 12 at resume — a live-state fact, not a ruling).

## State at the handoff's writing (all pushed through `5082cdc6`; re-verify with git)

1. **Preflight + resume: DONE** (the plan's LIVE STATUS → THE RESUME RECORD).
2. **Her step-3 answers + the URL correction: ADJUDICATED AND RECORDED** — appcast (the baked
   URL) `https://stargazing.tech/variorum/appcast.xml`; DMGs `https://dl.stargazing.tech/
   variorum/Variorum-<version>.dmg` (approved; immutable-once-published rider); download page
   `/variorum` unlisted; the site brief is carried; **the mailbox support@stargazing.tech does
   NOT exist yet** (open author item, beta checklist).
3. **Toolchain: macOS 27.0 (26A428) / Xcode 27.0 (27A266a)** — a new Xcode major installed
   mid-sitting (her hands; CLAUDE.md's environment line updated). macOS 27.0.1 offered but
   DEFERRED at her word. Any odd build failure: check the toolchain first (her instruction).
4. **HER HANDS steps 1–2: COMPLETE AND VERIFIED** (the plan's LIVE STATUS carries the decoded
   facts): the Developer ID Application cert (SHA-1 `<signing-cert-sha1>…`, team <apple-team-id>) in her login
   Keychain; the App ID `io.lduarte.Variorum` registered (none existed before); the profile
   `~/Downloads/Variorum_Developer_ID.provisionprofile` installed + decoded (keychain groups
   `<apple-team-id>.*`, the right app identifier, the right cert, exp 2044); the notarytool
   credential **`VariorumNotary`** validated into her Keychain (Team Key `<notary-key-id>`,
   Developer role). Step 3 (EdDSA minting) deliberately NOT done — it opens U2.
5. **U1: OPEN, an `opus-implementer` RUNNING** (spawned ~04:00 2026-10-04 at a verified
   zero-instance window, her app quit by her). Its brief is the plan's U1 section + ENVIRONMENT
   TRAPS + LIVE STATUS; its deliverable: the `Tools/Release/archive-and-export` road, the
   STATIC drill leg (a) with recorded evidence, and the LIVE drill leg (b) STAGED-not-run
   (author-gated); it writes a **U1 RECORD** section into the plan file, commits and pushes per
   piece. **Verify its state by: `git log --oneline -15`, the U1 RECORD in the plan,
   `ListAgents` (is it still running?) — a "completed" frame is not proof of completion and a
   death notification's text is not its endpoint (the resiliency protocol's recovery rules).**

## Next acts, in order

1. **When U1's implementer reports (or dies):** verify claims by spot-check (commits, the drill
   evidence lines, the staged checklist). Then coordinate the LIVE drill WITH HER: the A1 rail
   (byte backup of the closed store + all key files into `Backups/safety-copies/`,
   zero-instance window), SHE launches the Developer-ID export once — custody reads land, the
   store opens, quit — then the record closes U1. The ladder's Fable reviewer attends U1's diff
   at the end (custody-adjacent).
2. **U2** (the phase-sized unit): opens with HER HANDS step 3 — she runs Sparkle's
   `generate_keys`, then `generate_keys -x` into her password manager (R-13r-1). Then a fresh
   `opus-implementer` briefed from the plan's U2 section: Sparkle 2.10.0 SPM (Mac target ONLY),
   `SUPublicEDKey` + the settled `SUFeedURL` + `SUEnableInstallerLauncherService` in the
   partial Info.plist, the `-spks`/`-spki` mach-lookup exceptions, the DEBUG fence, the full
   release pipeline, dSYM retention. Acceptance: the fresh-user-account install→update walk
   (R-13r-8) — scratch installs only, NEVER /Applications, NEVER the real store.
3. **U3:** stamping build phase + MARKETING_VERSION 0.9.0, What's New (one release-notes
   source), MetricKit opt-in (LOCAL preference, provably OFF, payloads shown verbatim), Help ▸
   Send Feedback… (support@stargazing.tech). The Settings placement of the opt-in/Diagnostics
   is an IN-BATCH FORK: the implementer proposes, the architect rules. Note: P15
   (key-in-error-description) is FIXED at 17b — the crash path starts closed; the 2026-10-04
   privacy brief already promises the opt-in line.
4. **The ladder:** ONE `fable-reviewer`, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over
   the combined U1–U3 diff; cross-model flow per the plan's LADDER section.
5. **Closeout** (the plan's RECORDS & CLOSEOUT DUTIES): the KnownIssues keychain row resolved;
   master plan + archives; zero canon deltas expected; MOBILE PARITY "nothing mobile-visible"
   + the two named candidate rows; **the author handoff IS the friends-beta checklist** (site
   pages live · 0.9.0 through the pipeline · the download link · the mailbox watched — plus
   the optional iOS name-reservation item, facts in the LIVE STATUS); the install refresh at
   the end; memory updated; hard stop. **17y runs AFTER 13r closes** (a FRESH orchestrator;
   its kickoff message is at the 17y entry's tail in `notes/plans/phase-17-standing-fixes.md`).

## Open author items (bundle, don't drip)

The LIVE drill launch (U1's close) · EdDSA minting (U2's open) · the mailbox creation (before
the beta's first install) · the deferred macOS 27.0.1 · optional: the iOS "Variorum" app-record
reservation (verified: record-creation reserves, no submission needed, no confirmable dormancy
rule — the LIVE STATUS bullet has the recipe).

## Machinery lessons from this session

- **A parallel launch-content session commits to main mid-sitting.** One of its commits
  (`47d23955`) materially changed THIS phase (the U4 deferral). Check intervening commits on
  every push whose base isn't your own last commit.
- The portal offered NO Keychain Sharing capability on the new App ID — moot, because
  provisioning profiles carry the team-wildcard keychain groups by default (measured on this
  profile AND the old Mac Development one). The static drill re-proves it on the export.
- Her Apple ID email changed (<signing-email> → <her-email>); the old email in
  the Apple Development cert's CN is cosmetic; everything verified working post-change.

## PASTE-READY KICKOFF (for her to send post-compaction)

> You are the 13r orchestrator continuing after a context compaction. Re-orient from the REPO,
> not from the conversation summary: read `notes/plans/phase-13r-orchestrator-handoff.md`
> first, then `notes/plans/phase-13r-distribution.md` IN FULL (the binding record — its LIVE
> STATUS and U1 RECORD carry the current state). VERIFY-NOT-TRUST the U1 implementer's state
> before acting: `git log --oneline -15`, `git status -sb`, the U1 RECORD's statuses, and
> ListAgents for a still-running implementer (message a live agent; never spawn a twin). Then
> continue per the handoff's "Next acts" — nothing of the sitting's rulings re-opens.
