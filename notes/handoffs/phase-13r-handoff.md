# Phase 13r — Author Handoff (2026-10-04)

**Phase 13r is CLOSED. The friends beta is OPEN, and the first external user exists — your
friend's install, downloaded from stargazing.tech and self-updated over the public feed on
2026-10-04.** The binding record is `notes/plans/phase-13r-distribution.md` (the sitting record
R-13r-1…9, the in-run rulings R-13r-10…16, every unit RECORD, the ladder sections, the PHASE
CLOSEOUT). The ladder closed clean: round 1 — 0 BLOCKER · 0 MAJOR · 3 MINOR · 2 NIT, zero
disputes, all fixed; round 2 (fresh reviewer) — 0/0/0/3 record-only, every fix SOUND.

## YOUR CHECKLIST (this IS the friends-beta checklist — most of it is already true)

1. ✅ **Already done by the phase:** the site live (the `/variorum` page at 0.9.1, the two-entry
   appcast with the no-cache header verified live, the DMGs immutable on R2); 0.9.0 (build 4911)
   and 0.9.1 (build 4913) notarized, stapled, published; the first friend install + public-feed
   update PROVEN on a real second machine; the support mailbox live in your Mail.
2. **Send the link to more friends:** `https://stargazing.tech/variorum` — that's the whole act.
   Watch support@stargazing.tech. "If you've got this version, you've got my number."
3. **ONE press on your Mac: Help ▸ Restore Tutorial…** — your real store's seeded field guide
   predates R-13r-14's backups passage (and still carries the 13u4-era lesson edits' staleness).
   The refreshed install carries the new content; the press re-seeds. The A1 safety copy is
   already made (`Backups/safety-copies/13r-closeout-*`, six verified files).
4. **Your refreshed daily drive:** `/Applications/Variorum.app` now carries the stamping —
   About reads 0.9.1 with a build number above every published entry, so Check for Updates…
   runs and offers nothing (R-13r-7 by construction). Sparkle's consent ask will come calmly on
   your 3rd day of use (the cadence — no popup at open); answer it or flip Settings ▸ General's
   "Check for updates automatically" whenever.
5. ✅ **DONE at the post-close sitting (2026-10-04, the question tool):** **#180 RATIFIED AS
   BUILT** (numbers stay one tunable struct) · **#181 (a)–(h) RATIFIED; (i) RULED — the
   pre-draft choice** ("Open in Mail" / "Show the file and copy the address", both doors) —
   **built at 19f** (the active ledger; one session + its Opus cold review).
6. ✅ **DONE at the same sitting: the §12 calm-asks contract line LANDED** exactly as proposed
   (AppSpec §12 + §14's 13r head; the two oldest §14 entries rolled to the delta archive).
7. **Optional author items — each now dispositioned at the sitting (2026-10-04):** the iOS
   name reservation — HERS, before launch at a moment of her choosing · macOS 27.0.1
   (deferred at your word, unchanged) · the `/variorum` page's intro copy — rides **13s**
   (her word: she'll write it within that phase; her site's visual update runs alongside;
   **13s is SPLIT at the same sitting into 13s-a rewording / 13s-b onboarding — the ruling
   *[removed for publication]*
   site runbook's cache-busted preflight APPLIED at her word** (their `notes/
   variorum-releases.md`, commit `5649cf6` — wrangler has no `r2 object head`, so the
   verified busted-probe shape landed) · the Restore Tutorial press — noted, hers, and the
   tutorial rewording is 13s-a's anyway.
8. **The next release, whenever you have fixes to ship:** **HER RULE FIRST (2026-10-04,
   verbatim: "always ask me for release notes after presenting me with a draft and getting
   them approved pre-release") — the notes are drafted, presented to her in chat, and
   APPROVED before any release runs; no release ships notes she hasn't okayed.** Then one
   command + the site legs, under the standing R-13r-15 exemption — `Tools/Release/release.sh --version 0.9.2`, then the site
   runbook's locked order (the orchestrator of any session may run it; the pipeline refuses
   dirty trees, running instances, and published names on its own). TWO carried notes for that
   run: (a) do the back-to-back canonical-vs-busted HEAD comparison once (round 2's N2 — it
   settles the cache-key mechanism); (b) the SITE runbook's step-0 preflight still HEADs the
   canonical URL — the bucket-side `wrangler r2 object head` form is PROPOSED to their agent
   (their file; carry it or say the word and the exemption session applies it).

## State facts a fresh session needs

- **Releases:** 0.9.0 (4911) · 0.9.1 (4913), both notarized + stapled (4 Accepted submissions,
  0 issues). Durable artifacts + dSYMs: `~/Library/Developer/Variorum/Releases/<version>/`;
  the feed dir there is the appcast's one source. Site repo (`~/dev/stargazing.tech/
  stargazing-tech/`) commits `e304b43` · `dbb12a3` · `03cd4c3`; wrangler OAuth lives on this
  machine (R2/deploys); zone-level acts (cache purge) are dashboard = yours.
- **Her daily drive:** refreshed at this closeout behind the A1 rail (the exact version/build/
  codesign line is in the plan's closeout-tail record).
- **KnownIssues:** row 24 (keychain access groups) CLOSED on the U1 live drill's PASS; row 67
  (whole-app accessibility) stands post-🚀 with 13r's U4 brief kept intact.
- **19e queued** (the DataSafetyRunbook "shelf"→"Bookcase" one-line doc drift — the one named
  red in every finals line). **The 19 ledger is ACTIVE again.** **17y is NEXT at your kickoff**
  (its self-contained message at the 17y entry's tail in `notes/plans/phase-17-standing-fixes.md`).
- **MOBILE PARITY: PL-47** — the calm out-of-date sync sentence reaches the phone (`Shared/`,
  no door); the phone's crash-report opt-in face and What's-New-at-the-App-Store-road are
  named candidate rows for the mobile catch-up.
- **The marker stays 12; zero `Sync/`, zero schema, zero custody lines in the whole phase**
  (reviewer-verified both rounds). One ruled dependency added: Sparkle 2.10.0, exact-pinned.
- **Release lessons, binding:** no repo commits while a release runs (the stamp assertion
  caught it live); the preflight is cache-busted (F1); a pre-upload 404 can negative-cache at
  an edge (max-age up to 14400 observed) — the one-URL dashboard purge is the unblock;
  publish-and-leave + DMG-first held throughout and protected the feed twice.
- **R-13r-15 stands as a standing exemption:** release publishing into the site repo is the
  orchestrator's act when you have a release ready; anything needing your credentials or GUI
  still pauses for you; Fragments stays hands-off.
