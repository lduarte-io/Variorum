# VX-913 — morning handoff (Umbrella: fixes before the freeze)

**Run CLOSED overnight at your word. Merged to main at `22dc8b28f` (PR #238, merge commit) — the FIRST merger of the last pre-OSS wave; vx-926 folds that SHA. No release was published and no release file was touched: per nov7's wave rule the wave's LAST merger does release prep on nov7's GO, and the release itself waits for your word in the morning.**

## Your checklist (everything that waits on you)

- [ ] **The toast wording for VX-775** (QUESTIONS #271a). When an AI's change lands but the activity log can't record it, you now see one refusal-style toast. Drafted wording, yours to trim: *"‹client›'s change landed, but the activity log couldn't record it — ‹the store's own words›."* Also yours: the edge where the act itself was a no-op — the draft still says "change landed"; want a different word for "nothing changed, and the log also failed"?
- [ ] **One line per call, no retry** (#271b, #271c): a call that fails several item-writes coalesces into ONE toast; the app never retries the log write. Confirm or redirect.
- [ ] **VX-608 relabel** (done, your confirm owed): the "redo after destructive undo" ticket's tests pass 7/7 when run alone on this tree — a test-ordering flake, not a product bug. Commented and relabeled Test-only · Tests & tooling; fold it into vx-926's flake family if you agree.
- [ ] **One thing never visually walked** (#271e): switching wings while the Settings ▸ Tags "Make a Gathering" sheet is open should dismiss the sheet. The logic is pinned by tests; the macOS 27.0.1 screenshot guard blocked every Settings capture, so the dismissal was never SEEN. Say the word if you want it walked at a sitting.
- [ ] **Four small tickets filed** (list at the bottom: VX-959 · VX-960 · VX-961 · VX-962, all Low) — confirm the triage.
- [ ] **Two pre-OSS code items from kickoff that never got your word**: VX-773 (I had recommended folding it into vx-940, which has since merged — it needs a new home) and VX-854 (recommended as a vx-915/vx-940 rider). Both still open; your call.
- [ ] **The Air still owes its own user-level attribution-off line** (`~/.claude/settings.json` there) — this Mac is covered ("off everyone"); the Air isn't until that's added.
- [ ] **Release**: the wave is release-ready once its last merger finishes prep under nov7. Your word publishes it.

## What was fixed, in plain English

**Library search header following your click (VX-895).** When you searched and clicked between the facets (Notes, Blocks…), the header above the results — "Notes, with their passages" / "Blocks & scraps" — often didn't follow, so it felt random which one was up. Cause: the header read a value the UI was told to ignore changes to, so clicking never redrew it. Now it follows every click. The band's counts were checked too and were never actually wrong — that half was a false alarm, proven by a test that stayed green on the old code.

**Make a Gathering from Settings ▸ Tags lands in the wing you're looking at (VX-889).** Before: the sheet always minted the gathering in Home, even when the pane showed another wing — and its rule's tags resolved against Home's vocabulary, so the gathering could be born matching nothing. Now the sheet snapshots the wing the pane SHOWS and uses it for everything: where the gathering lands, which wing's tags its rule reads, and the duplicate-name check. Switching wings while the sheet is open dismisses it (the one unwalked visual, above).

**An AI client is no longer told its landed change failed (VX-775 — your ruling: "the error goes to her, the truth goes to the client").** Before: if the write landed but the activity-log line after it failed, the client heard "error" for a change that was really in your store — and the activity list could even show a false "refused" row. Now the client hears the truthful answer, byte-identical to normal, and the failure comes to YOU as one toast (wording above, yours to trim). The review ladder additionally made the toast provably arrive AFTER the act's own receipts, by construction.

**The MCP server's start button races (VX-613).** Two confirmed races: a stale, cancelled start could clear the "starting" flag out from under a healthy server, and could falsely report "another Variorum is already serving" beside your own live server. Both fixed with a generation token — a stopped start now unbinds and publishes nothing, and only a start's own completion clears its flag.

**What's New sheet bullet wrapping (VX-343).** A long bullet that wrapped onto an indented second line used to show the second line as its own stray paragraph. The parser now joins continuations onto their bullet; the 0.9.5 notes file that showed the fragments is the test fixture.

**VX-890 (internal only):** a duplicated search-SQL template folded into one; provably zero behavior change (every existing test green, none edited).

**VX-81 closed obsolete (your ruling: "I choose a — close as obsolete").** The 0.9.2 re-key reopen crash: the history memo established the crashing code path was deleted whole across VX-80 → VX-329 (the whole protection road replaced) → VX-529. No crash of that shape in 34 recent crash reports; clean 27.0.1 crossings on record. One residue became VX-962 below.

## The night's one saga, in plain English: the commit-trailer guard

You asked why the attribution-trailer mistake wasn't "caught by the hook" — there was no hook, only a rule in prose. There are now three layers: (1) the repo's `.claude/settings.json` turns attribution off and DENIES any commit/PR command carrying a trailer form (tightened twice at your word — narrowed to stop false alarms on commits that merely mention the words, then strengthened at your "catch MORE" push); (2) your user-level settings turn attribution off everywhere on this Mac ("off everyone" — the Air still owed, see checklist); (3) the per-clone git hook that has silently stripped trailers since Oct 28 — which is also why my "I committed a trailer" confession turned out WRONG: forensics showed that commit landed clean, retracted with evidence. History holds 2,130 old trailer commits (July–Sep mostly, 0 in Nov) — that's VX-748/VX-749 territory, yours: "I will talk to vx-749 about this."

## Evidence and bookkeeping (one line each)

- Merge gate (claim vx913-merge-gate, SHA 333e87508): Mac whole target **6249 tests / 1083 suites, zero failures** (14 known issues); headless whole package 4013/549 + 32/4 green, 687/128 with ONE socket-timing false red (`aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, a 15s bound at 46s under load) **re-run alone 3/3 green in 2.2s** — both runs named to nov7. `VX775ActivityLogFailureDoorTests` 3/3 executed by name (the ladder's carried condition).
- Earlier windows: B1 gate 262/48 green + Study walk W1–W5 exact (Terminal withheld by the 27.0.1 words-guard, evidence = voice-parameterized pins); b2b3 window head gate 538/78 green, four revert-reds exact, VX-608 alone 7/7.
- Ladder: round 1 (0 blocker / 0 major / 2 minor / 3 nit + a clean bill) → one fix → round 2 clean, closed. The one disputed finding was settled by two independent C-probe measurements; the reviewer withdrew its shape.
- Rulings reconciled: the "EVERY write tool takes the same split" wording is satisfied through the write family's one choke point; the one sibling road outside it (`show_in_app`) is VX-961. All other rulings shipped as worded; VX-81's close and the riders match your words verbatim (the record's SITTING RECORD).
- Canon: the MCPSpec VX-775 line + the SurfaceContracts VX-889 clause applied as ruled; AppSpecRecord dated entry; QUESTIONS #271. `Tools/canon-size`: **139,814 of 150,000 (headroom 10,186) — no crossing.**
- MOBILE PARITY: nothing mobile-visible.
- The record (mechanisms, briefs, both windows, the B4 history memo, the ladder files): `notes/plans/fixes/vx-913-freeze-fixes.md`, FOR A LATER READER at its top.

## Tickets filed (by priority — all Low)

1. **VX-961** — `show_in_app` answers isError when only its activity line fails — Bug · Confirmed · MCP. The same split as VX-775, one more door; confirmed in the trace.
2. **VX-959** — the socket path's identity across hosts — Bug · Suspected · MCP. The ladder's residual unlink/identity edges; the first piece (stat-after-bind identity vs per-directory serialization) is chosen there, never fstat (measured twice).
3. **VX-960** — `TagsViewModel.createTag` reads the app's current wing, not the pane's shown wing — Bug · Suspected · Settings & onboarding. VX-889's sibling, spotted in passing; unconfirmed.
4. **VX-962** — Make this my library from the main window rebuilds RootView under its sheet — Improvement · Suspected · Castle & sync. VX-81's residue; never walked on 27.0.1.

Plus: VX-608 relabeled Test-only · Tests & tooling with the diagnostic comment (your vx-926-fold confirm above).
