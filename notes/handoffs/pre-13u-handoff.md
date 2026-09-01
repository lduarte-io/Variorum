# pre-13u round — author handoff (2026-08-31/09-01)

**Self-contained by rule:** if a question about this round could only be answered by a session's
context, the docs are incomplete. The ONE record is `notes/plans/pre-13u-round.md`; the ratify list
is QUESTIONS **#85 + #86**; the three design memos are `notes/plans/pre-13u-memo-security-shapes.md`
(canon), `pre-13u-memo-daily-journal-identity.md` (13y), `pre-13u-memo-sync-disagreements.md` (17i).

## YOUR CHECKLIST (top, as always)

1. **Open the refreshed app** (`/Applications/Variorum.app`, refreshed at the round's close from
   the accepted tree — see "The install" below for the exact commit + hash). First launch: ONE
   Touch ID (the one-prompt world); Sherlock seeds in the background after the window is up
   (~4.5 s, off the launch path) and lands at the BOTTOM of recency views (the back-dated stamps,
   #86(a)).
2. **Press Help ▸ Restore Tutorial…** — the field guide gained the privacy chapter aligned to the
   memo, the eight-mode "getting around", the new "index · read" lesson, and the workbench lesson;
   the re-seed is an in-app act (the 13p precedent). Then Help ▸ Restore the Sample Library exists
   too — you won't need it.
3. **Walk the new faces in this order** (the morning bundle's "look for" column is the table in
   the round's chat summary, mirrored below): the mode row (⌘3 Index · ⌘4 Read · ⌘7 Blocks), a
   book (Outline · Index · Book · Read), Settings ▸ Protection (the checklist leads) and the "How
   Protection Works" tab, Snippets, the Pool, the note picker (right-click a library row ▸ Mark as
   Versions with), the tray, the tags at the right edge, the tabs strip, a checkbox tick, `->`.
4. **Ratify QUESTIONS #85 and #86** — the two PROVISIONALs (#86(a) back-dated seed stamps; #86(b)
   dangling-designation adoption), the near-empty re-key WARN-or-REFUSE question (#86(c)), the
   taste forks (#86(e)), the up/down arrows (#86(f)); and #85's Act 0 judgments.
5. **Carry the Fragments enrollment brief** (`notes/fragments-enrollment-brief-2026-08-31.md`) and
   rule the (a)/(b) road with the Fragments agent (#86(d)).
6. **Revoke the Screen Recording grant** whenever (#86(g)) — nothing in the product needs it.
7. **Kick off 13u1 when ready** — its plan's kickoff message now opens with a pointer to the
   round's inheritance addendum (`notes/plans/phase-13u-feel-and-polish.md`, the dated section at
   the end). 17i (the sync hunt) and the daily-Journal identity (13y) wait at your word.
8. **The two pre-migration plaintext backups from 13p (#81(g)) still sit in `~/dev/scratch-13p-spike/`** —
   still yours to release; this round's own backups are ciphertext under
   `~/dev/variorum-store-backups/` (`pre-act9-refresh-…`, `pre-closeout-refresh-…`).

## What shipped (the plain-English table)

| Area | What changed |
|---|---|
| Unlocking | One Touch ID — the separate sync unlock is an opt-in setting, off for everyone (R-pre13u-2) |
| The store key | Device-bound (#82) — no longer rides login-keychain migration/backups |
| Custody (17a + 17h) | Ten fixes, all pinned red-on-old; the keychain test tripwire; the escrow round-trip proven |
| Sherlock | *The Adventures of Sherlock Holmes* in every store — 12 stories, 13 chapters, tagged, Pool blank, off the launch path, back-dated; a restore door; the phone seeds it at first write |
| Read layer (17c) | trayTakes flat; Trash peers 551→15 ms; the classifier index (`v1_15`, local); fans 40→1 |
| Hygiene (17f) | Dead code out; AppSpec's stale 24 h corrected; honest P1 gates; rendering pins; trigger introspection |
| Phone first-run (B1) | Seed-on-first-write (the 20 s wait gone); the Journal-keeper repair; empty-state copy |
| Act 10 wave 1 | The tray · tags at the right edge · the bottom bar · the lobby · tabs strip + 20-cap · the click model + info panel · the checkbox jump · typed arrows · the Starred row · `CalmGrammar` |
| Act 10 wave 2a | The protection pane leads with the live checklist · "How Protection Works" · escrow follows posture · the three-value tier · eye/peek · the ceremonies · the tutorial aligned · T1's re-key guard · Archived/Account sweep |
| Act 10 wave 2b | The note picker · the Pool cards · Snippets with groups + the Trash kind |
| Act 10 wave 2c | The eight-mode row (Index · Read) · the Blocks workbench · Compare+Lenses rebuilt · the Book redesign (Outline · Index · Book · Read; the details gutter) · the field guide |
| Reviews | The Opus midpoint (1 MAJOR — the seed's segmentation; fixed) · the Fable ladder R1 (1 BLOCKER, 2 MAJOR — the Journal keeper's predicate + arrival order; the dedupe's engagement rule; fixed) · R2 (2 MAJOR — the harness-vs-production gap; fixed) · R3 (see below) |
| Docs | The security-shapes memo (canon) · the daily-Journal identity memo (13y) · the sync-disagreements memo + 17i · the Fragments enrollment brief · the resiliency protocol · the mockup style guide |

## Findings + dispositions in brief

Every review finding has a written disposition in the round record's four review tables (MIDPOINT,
LADDER R1/R2/R3). Nothing was dismissed without a trace; two hollow claims were dismissed by
measurement (17f's P50; the m1 "throws at 40k ids" pin claim). **Open after the ladder's cap
(recorded, owned, never looped):** the dedupe's late-registry engagement leg (KnownIssues, 13y);
the daily Journal's identity (the memo, 13y); the sync probes (17i). **Round 3 (the cap): 0 BLOCKER · 0 MAJOR · 4 MINOR · 1 NIT, all seven round-2 fixes HOLD, "ship with all five."** R3-1 (canon lagging the R2-2 predicate) FIXED at the record; R3-2 (the seed-shape guard mirrors the classifier instead of invoking it) → 17i; R3-3/R3-5 (six of your invisible acts still unread by the dedupe — stars, word target, segmentation default, canvas layouts, lenses, edges — and the chapter-rename leg) + R3-4 (a bounded re-hash loop in one indeterminate state) → 13y's widened KnownIssues row; **P5(a) re-calibrated: a PRE-EXISTING Phase 5 defect — the general tag-collision repair loses applications that arrive after the duplicate tag died (MAJOR-class spec drift, silent) — promoted to 17i's FIRST fix item with a KnownIssues row.** Not fixed in-round at the cap and your word to finish the phase.

## The install

*[removed for publication]*

## Counts at close

**core 1524/165 · Mac 1985/343 · mobile 607/97 + the 2 standing known issues · tutorial spine green** (the ladder's round-2 fix close, 6150f7e; round 3 changed no code). Against 13p's finals (core 1453/154 · Mac 1843/312 · mobile 513/86): +71/+11 · +142/+31 · +94/+11. Lockstep marker 7; the one schema change a LOCAL index (`v1_15`); every `Sync/` line Fable's under the rider.

## The mobile update note

`notes/plans/pre-13u-mobile-update-note.md` — self-contained for the mobile session's resumption
(your sign-off instruction); MobileSoul PL-18 is the parity row.

## Machinery honesty

Four agent deaths (one auth, three session-limit), a harness restart, and a system crash — zero
commits lost, every batch continued from its record; the discipline is now
`notes/SessionResiliencyProtocol.md` (+ the mobile and Fragments seats' addenda). Two agents hit
the background-wait trap; both recovered. Your plan upgrade mid-run ended the limit deaths.
