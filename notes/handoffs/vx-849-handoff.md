# VX-849 — your morning handoff (the sync-custody run: the typed-over rescue and the offline unlock retry)

**CLOSED overnight under your mandate — PR #241, merge `70f88a926`. The record (FOR A LATER READER at its top): `notes/plans/fixes/vx-849-typed-over-rescue.md`. The wave is now WHOLE: vx-913, vx-926, vx-915 and this run are all on main, and this run (the last merger) staged the 1.4 release — BUILT AND READY, NOTHING PUBLISHED. Your word releases it.**

## Your checklist

- [ ] **Approve (or edit) `ReleaseNotes-1.4.md`** — drafted as public copy covering everything since 1.3; it renders in the What's New sheet and the update alert verbatim. An edit means a rebuild (say the word and it happens before publish).
- [ ] **Say the release word** — `release.sh --version 1.4` runs right after the merge on nov7's GO, stopping at its HANDOFF (this line is updated when it has run); the publish steps — site upload, appcast, /Applications — stay untouched, yours in the morning.
- [ ] **Read QUESTIONS #274** — this run's seven provisionals (P-849-1…7), each built-as-described with alternatives. The two worth your eye first: **P-849-6** changes a ratified measure (#167's book-ownership tiebreak — an offline earlier act now outranks an online later one; the alternative was two devices that could each tombstone the other's filing and converge on NOTHING, which is what the bug was); **P-849-4** deletes a stale key file at open (fenced five ways; the alternatives were set-aside or leave-it).
- [ ] **Your Air drill (VX-544's steps 8–9)** — AFTER this release reaches the Air via Sparkle: lock the Air, turn its network off, unlock with your passphrase (sync says locked), turn the network back on, and watch it heal by itself within a round. That is the one live confirmation only your hands can give.
- [ ] **VX-919's deploy window (yours)** — the device-cursor cap script is authored, reviewed and NEVER run. When you want it: `Server/supabase/maintenance/vx919-device-cursor-cap.sql`, then its VERIFY reads; `vx919-rollback.sql` is the exact road back.
- [ ] **The Apple Feedback** from vx-926's handoff is still yours to file (unrelated to this run; noted so it doesn't slip).
- [ ] **Skim the tickets this run filed** (bottom of this page, also the session's last chat message).

## The most important items, in plain English

**1. Your words can no longer be silently overwritten by sync — and sync's words can no longer be silently overwritten by you.** The bug this run existed for: if another device's change arrived in the exact window while you were typing in the same take, your Mac wrote your version over it and the other words survived NOWHERE — not in history, not anywhere. Two belts now close it. First, just before every sync round, your pending typing is saved properly (so the round compares real against real). Second — the belt that works whatever the timing — the save itself now carries a photo of the text it was built on; if the take changed underneath it, the save keeps YOUR words on the take and puts the displaced words on the same block as a new take labelled "conflict", so both survive and both sync. The same protection covers an AI editing mid-keystroke, a second window, everything. Proven by two-device convergence tests and walked live.

**2. Unlocking offline no longer leaves sync stuck.** Before: if you unlocked with your passphrase while offline, the app couldn't fetch your sync keys, shrugged, and sync stayed "locked" until you unlocked AGAIN online. Now the unlock's derived key material (never the passphrase itself, never written anywhere) is kept in memory, and the app quietly retries before each sync round until the server answers — plus the network coming back triggers a round on its own. It heals with zero presses, on the Mac and the phone. The one thing only you can confirm live is the two-Mac drill on your Air (checklist above).

**3. Editing collisions end cleanly now.** When an AI (or sync, or another window) rewrites the very take you're editing, your editing ring ends and the pane shows the new words — that part existed. This run found and closed two real holes in it: the ring could end WRONGLY while your own save was still in flight (dropping your buffer), and a keystroke landing in the one-beat gap between the outside write and the ring ending could overwrite the outside words with no trace. Both are fixed and pinned; the second one was genuine data loss nobody had seen.

**4. A restore can't cost you what you just typed.** Restoring a saved moment now files one quiet automatic moment of the words it replaces, and the restore doors land your pending typing first. Walked live: restore after typing → the take shows the moment, the rail holds your typed words as a quiet ◦ moment, no conflict card. (P-849-1 — the shape is yours to ratify.)

**5. An old spare key file is tidied away.** Libraries from an earlier design-era carried a leftover `variorum-keys-…` file beside the store. It held a long-retired key AND its name is exactly what the app uses to recognize pre-design stores — so if your real key file ever went missing, the leftover would make your library look like an ancient store instead of showing the right doors. At a successful open, that leftover is now deleted — by name, never read, only on the live library, and only if the live key file vouches for its fingerprint (so nothing openable can ever be lost). (P-849-4.)

**6. Book ownership settles the same on every device.** The repair that decides which book keeps a note (when two devices disagree about an owned book) ranked by a per-device bookkeeping number, so two devices could pick DIFFERENT winners and tombstone each other's filings — the note could end up a member of nothing. It now ranks by the membership's creation time, identical bytes on every device. (P-849-6 — this slightly changes a measure you ratified at #167; the bundle explains.)

**7. Two members turned out to be already fixed — and were NOT re-fixed.** The double-lock race (VX-152) was closed by an earlier run's one-act seam; the teardown crash (VX-855) was the test host's exit-time race, closed by the inert-test-host and quit-quiesce work. Both got regression guard pins and honest closing comments instead of redundant code. (Your VX-152 condition — "investigate, and if it balloons, ticket it and leave it out" — was honored on its third branch: no live bug.)

**8. The release is staged, not sent.** Version 1.4 on both configurations, notes drafted and guard-clean, the whole Mac and phone suites green on the exact release tree; the step-0 drill, first-run walk and `release.sh` run right after the merge (nov7's GO) and this file says so when they have. Nothing touched stargazing.tech, the appcast, or /Applications.

## The evidence (one line each)

- Six batches, each with red-on-old pins verified by behavioral revert (every revert bit exactly its named pins — ten reverts re-proven live in the stage windows, plus the headless ones).
- The ladder closed at round 1: 0 blockers, 0 majors, 3 minors (all resolved by ticket/closeout act/evidence gate), 2 nits.
- The b34 windows: 15/3 + 25/4 Mac green; leg D 87/7 phone green, no type dropped; the walk's three rows right in both voices (130 shots).
- The closing sweep on the release tree: whole Mac 6,367 tests in 1,101 suites (13 knowns + one named flake proven green alone) · whole phone 857 in 141 at its named baseline · whole core package 4,070 in 563 · whole MCP target 703 in 130 wholly green — plus the sweep CATCHING one real regression (a fabricated empty snapshot) and fixing it before the merge, with its own cold review.
- Canon-size at close: 141,121 of 150,000 (headroom 8,879) — reports only, nothing slimmed.
- MOBILE PARITY: the phone heals the offline unlock exactly as the Mac does (the keep, the retry, the trigger, the flush — one shared closure), carries the guarded autosave on every record site, and shows the shared credits; the phone's restore flushes but does not yet insure (one argument, P-849-1's rider).

## Tickets filed by this run

- [ ] VX-966 (Medium, Bug): the structural undo/redo doors don't flush pending typing — your own ⌥⌘Z under typing can mint a 'conflict' card (nothing lost; the fix shape is on the ticket).
- [ ] VX-971 (Low, Bug): Write's take panel's bottom-bar "history" button does nothing while the panel is open (a dead door — found live at the walk).
- [ ] VX-967 (Low, Bug): margin grid with follow-the-scroll — a note's first fan re-centres the column.
- [ ] VX-968 (Low, Bug): a narrow face-only race in the outside-write ring-end confirmation (no data at risk).
- [ ] VX-969 (Low, Debt): the three sibling seq-ranked §7 repairs carry VX-921's determinism gap — waits on your P-849-6 ruling.
