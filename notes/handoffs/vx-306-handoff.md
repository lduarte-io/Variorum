# VX-306 — Castle rebuild phase 2, the open road: the author handoff (2026-10-18)

**For:** the author, the morning after her overnight mandate. **Written by:** the VX-306 orchestrator (Fable), at the closeout.
**Self-contained:** everything here points at a repo file; nothing needs this session. **The PR:**
https://github.com/lduarte-io/Variorum/pull/174 (`VX-306: Castle rebuild phase 2 — the open road`) — merged as a merge
commit at the stage coordinator's word (the merge commit is on `main`'s history; if the PR still reads OPEN, the merge ask
is with `oct18coordinator`). **The record:** `notes/plans/vx-306-castle-open-road.md` (§7 your rulings verbatim, §7b the
provisional ones, §7c the words, §8 the environment traps, §9 the unit records and walks, §10 the ladder). **The contract:**
`notes/CastleRules.md`. **The bundle:** `notes/QUESTIONS.md` #234 (renumbered from #233, which VX-348's bundle holds).
**Scope, exactly:** `Sources/VariorumCore/Protection/` + `Persistence/`, `App/Variorum/Shared/Protection/` (new), the faces, the
mobile target's new-road faces, the tests, the notes — and ONE `Sync/` line, `protection_record` added to
`SyncSchema.localOnlyTables` (a local-only registration: no payload, no lockstep, marker 13 untouched; P-VX306-K6 — the
kickoff's "zero `Sync/` lines" is corrected here; the ladder was Fable's, so the line was cold-read). Zero `Server/` lines.

## Your checklist (in order)

1. **YOUR HANDS — Look inside on a byte-copy of your real store.** Not done by any session (your kickoff word). HONEST
   NOTE FIRST: your real store is a PRE-DESIGN store (rule 26). The Debug build's classifier refuses it as "This file
   couldn't be read as a library" (today's envelope is not a format-3 key file; P-VX306-U3-6), so this item is NOT
   possible until your real store lives on the new road (VX-329's switch). Nothing to do this morning. The walk proved
   Look inside on new-road copies (the plan's §9 U3 BATCH + WALK RECORD). When the day comes, the road is: zero instances
   of `/Applications/Variorum.app`, an A1 safety copy of the real store, then the DEBUG product
   (`App/Variorum/DerivedData/vx306-u3/Build/Products/Debug/Variorum.app` — the dev scope; never your installed app) →
   File ▸ Open Library… → the copy's folder → *Look inside…* → your credentials typed by you.
2. **The PROVISIONAL bundle — `notes/QUESTIONS.md` #234.** Every entry was built as its option (a). The ones worth a real
   look: **K1** (the dev store took rule 26's own road — set aside whole, recreated fresh; no conversion machinery exists),
   **K7** (the words card: one button, no Copy, no "show me later"), **U1b-3 / U2-5** (*Start a New Library* moves the
   unopenable library whole into Previous Libraries first), **U2-1** (the notice and the offer are a card in the lobby's
   room, the library opens either way, an offer put off is asked again next open), **U2-3** (the reminder's cadence —
   third launch, then weekly, *Don't show again* after three *Not now*s), **U2-6** (a finding: the split-pair line is built
   but no state reaches it), **U2-7** (two of your sentences read oddly in two states — a variant is yours), **U3-5** (a
   plain-text export picked on the new road says "isn't ready in this build yet" instead of today's road, on a trace),
   **U3-9** (Make this my library gives the new library a fresh store identity — sync settings and dials start fresh),
   **U3-15** (Look inside as a read-only FACTS sheet, not a window), **W-1** (the Start Here passages reach only a store
   that opens on the new road; your real store's readme is yours to update or not). Your kickoff of VX-307 counts as
   accepting the bundle.
3. **The words (§7c of the plan)** — the card, the offer, rule 27's two faces, the restore receipt, the reminder and the
   Set a passphrase sheet, Make this my library's confirm and receipt, Look inside's frame line, the Start Here passages —
   built as drafted; your taste on each. The lines marked *words for you* in #234 (U1b-4, U2-2, U3-2, U3-3, U3-16) were
   never drafted by you; they are the orchestrator's. Two phone-side taste calls: the phone's lowercase chrome lowercases
   the drafted titles and buttons (W-14); the card says "on this Mac" on the phone (W-15).
4. **The dev store is the new road's.** Library `86a82b4f` (Standard, under the dev pair — `~/.variorum/dev-castle.env`:
   `VARIORUM_DEV_NEWROAD_WORDS` + your dev passphrase; the file's backup `dev-castle.env.bak-vx306-20261018144230`), the
   restore hold standing (dev sync off; press Resume Sync only on purpose), library `818912e0` whole in
   `Previous Libraries/2026-10-18-173517/`, the pre-design store whole in
   `Backups/safety-copies/variorum-vx306-predesign-2026-10-18-144152/`. A Debug build from a branch without VX-306
   cannot open it (`notes/plans/vx-306-castle-open-road.md` §8). The field guide is NOT seeded in it (the welcome mark
   survives a reset — W-5). Two of its previous libraries carry the pre-renumber migration name
   (`v1_30_protection_record`) and refuse as "newer Variorum" (W-11; VX-307's plan §3) — expected, not a fault.
5. **Release note — 0.9.8 shipped WITHOUT Castle phase 2.** The 0.9.8 (build 8503) that VX-348 released on 2026-10-18
   was cut before this merge. Any later release carrying this merge is safe by construction: the new road is Debug-only;
   Release runs today's road byte-unchanged (the Release build check passed on every tree of this branch; the gate item
   of your RELEASE ruling). No `/Applications` refresh was made (your word).
6. **Next:** `/architect-phase vx-307` — its plan is written (`notes/plans/vx-307-castle-crossings.md`, commit
   `17a9cd98f`, the kickoff message at its top) with the `key_vault` change as a SyncSpec §12 lockstep whose mirror deploy
   runs only at your explicit go. ONE call waits at its kickoff: a marker-14 mirror with a marker-13 Release client means
   the RELEASE app visibly refuses to sync until VX-329 ships — the bump WAITS for VX-329 unless you rule otherwise.

## What this phase did (one paragraph)

The headless protection core VX-378 left under `Sources/VariorumCore/Protection/` is LIVE in Debug builds, behind one
compile-time switch (`ProtectionRoad.newRoadIsLive`; `opensOnTheNewRoad(devStore:)` narrows it to the dev store), so
Release runs 13x's road byte-unchanged. At kickoff no production leaf existed, so U1 split: U1a built the thirteen leaves
under `App/Variorum/Shared/Protection/` (the data-protection keychain through one builder, Touch ID items found by name,
VX-390's library-ID stamp in the label, iCloud Keychain Apple keys, SQLCipher over the library and its copies, the files
beside the slot, the catalogue), the LOCAL-ONLY `protection_record` table (marker 13 untouched, zero lockstep, one
`Sync/` registration line), VX-386's three residues as the first commit, and a tripwire that refuses every real-scope
keychain write from the test process. U1b put the lobby on `assess`'s roads (the quiet roads first, then the typed ones;
VX-310's Touch ID button and line), the once-shown words card, the Release check, and recreated the dev store through the
new road on rule 26's own road. U2 built the honest faces: rule 21's notice and key-file offer, rule 27's lobby and
banner, rule 1's restore receipt, rule 3's reminder on the calm-asks idiom with the Set a passphrase sheet. U3 built the
two copy doors — Look inside (ruled (b): a read-only facts sheet over a private byte copy) and Make this my library (the
new library under the current pair, the previous whole in Previous Libraries, the restore hold kept) — behind Settings ▸
Data Safety's Restore list and File ▸ Open Library… (a picked pair filed first), and switched the phone's Debug build onto
the same road. The words pass appended the Start Here passages to the readme seed on the new road only. Every unit was
proven by red-on-old pins, a Mac batch under the stage and the orchestrator's own walk on the dev store; the phone's suites
ran green on the iOS 26.2 simulator; the core suite is green in both configurations.

## The ladder

Two Fable rounds, 0 BLOCKER / 0 MAJOR throughout. Round 1 4m/4N: m1 the missing face's Start over a record-less store
now sets it aside whole (the old road also overwrote its key file and left orphan items); m2 the copy doors' automatic
probe never presses Touch ID; m4 the Restore list refreshes on a landed run; the NITs; m3 = VX-411 (pair retention).
Round 2 3m/3N over the fixes: every round-1 fix confirmed; m2 the Start Here passages gated on the new road so Release
never seeds them; m3 the core creation's no-clobber preflight before its first write; NIT 3 a filed pick refreshes the
list; NITs 1–2 hand-forwarded to VX-307's plan §3 by name. No round 3 (no BLOCKER/MAJOR); the round-2 fixes got the
orchestrator's line-by-line check (the plan's §10). The reports: `notes/plans/vx-306-ladder-round-1.md`, `-round-2.md`.
The final batch: Mac 244/47 with VX-310's three known witnesses, both red legs red and restored, the phone 20/5.

## The rulings

Yours — the kickoff, verbatim in the plan's §7 (the cast, the five-round cap, the overnight mandate, the three-unit shape,
the words from the rules, VX-386 first and VX-390 in U1, the dev store's conversion, the slot, your hands for the real
store, no `/Applications` refresh). The orchestrator's provisional ones — §7b K1–K7 and each unit's record in §9, all in
#234. The one orchestrator design ruling: Look inside as the facts sheet (§9 U3's ORCHESTRATOR RULING; P-VX306-U3-15).

## Filed tickets, by priority (each labeled at filing)

- **Medium — VX-411** (Debt, Castle & sync): retention of this Mac's own backup pairs, rule-22-aware (round 1's m3; the
  leaf writes pairs, nothing prunes them yet).
- **Low — VX-406** (Debt, Tests & tooling): the full core suite's release-floor reds under `-c release` — pre-existing,
  not this phase's; the protection suites are green there.
- **Low — VX-409** (Bug, Suspected, App shell): the receipt line's overlap with the bottom-bar reminder when both show.
- **Standing:** VX-379 stays open with its rows (the posture box's sentence, the Data Safety restoring paragraph, the
  protection pane's today's rows); VX-310 holds a comment — the lobby half shipped here, the Touch ID re-arm question is
  VX-307's plan §2 U2. Closed at the merge: VX-306, VX-386, VX-390.

## MOBILE PARITY

`notes/MobileSoul.md` PL-42: the phone opens on the new road in Debug builds (its words card, lobby and rule-27 sheet;
Face ID named as the device's own biometry); owed to the phone — Look inside and an Open Library door (P-VX306-U3-18,
VX-307's plan §3), the reminder bar and receipts (P-VX306-U3-13), the two taste calls W-14/W-15.

## Machinery notes (for the next orchestrator)

- The plan's §8 ENVIRONMENT TRAPS is the list; the ones that cost the most time: the unified log shows NONE of the app's
  os_log lines — launch the Debug binary directly with `OS_ACTIVITY_DT_MODE=YES` and capture stderr; `Simulator.app` is
  not at Xcode's usual path — run the simulator headless (`simctl boot/install/launch/screenshot`); the Settings pane does
  not scroll by synthetic wheel events; `KeychainTestTripwire` refuses real scopes under tests (throwaway scopes
  `vx306-<uuid>`); the Debug-only `VARIORUM_WALK_FORGET=silent|apple|memory` switch is the only road to a forgotten
  quiet road (no command-line tool reaches these keychain items). `Tools/WalkKit/README.md` carries the walker facts.
- The migration renumber (`v1_30` → `v1_31_protection_record` at the fold of VX-348) left two dev previous libraries on
  the old applied name (W-11); a fresh library C proved the adoption door instead.
- Cleanup owed after the merge (this session's, if it is still alive; else the coordinator's): the worktree
  `~/dev/variorum-vx-306` and the branch; `App/Variorum/DerivedData/vx306` and `vx306-u3`; `~/vx306-walk` (libraries B
  and C), `~/Downloads/vx306-airdrop`; the scratchpad's walk captures and harnesses.
