# VX-548 — Run: MCP grant & pane fixes — author handoff

**STATUS: FINAL — the run is CLOSED; everything below is complete.** The run's record (everything below in full detail): `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`. Overnight run 2026-10-27 at your word; the ladder closed in two rounds (r1: 0 BLOCKER · 0 MAJOR · 2 MINOR · 2 NIT, all fixed with evidence; r2: no new BLOCKER/MAJOR). PR: PENDING(filled at the merge — see the record's banner). No release happened and none is minted — that stays your word.

## YOUR CHECKLIST (the morning bundle — QUESTIONS #243 carries the same items)

**The one her-hands trace (MB-7, decides VX-394's remaining story):** on your AIR — (a) Settings ▸ Protection: is that library in Castle? In Castle the screen lock always locks the library, and the lock stops the MCP door BY DESIGN (A-8). (b) Settings ▸ MCP ▸ Activity at the two drop times: "…locked or closed" = the lock road (by design, now fully pinned); plain "claude-code disconnected" = the client side. (c) Pick a reconnect-ergonomics option: A shim auto-reconnect (a design event — breaks the MCP-blind shim), B a why-line before closing, C docs only, D fewer locks. The 2b record's read: C now, B2 if wanted, A only if you accept the design event.

**Ratify or redirect (all built, all PROVISIONAL, all reversible):**
1. **MB-1 — the Change… rule (VX-516's fix):** Change… replaces only while the place you confirm is the place it was opened on; picking another place grants NEW and revokes nothing (the title flips to "Grant access", the named replaces line goes). Consequence to rule on: an inert grant can no longer be MOVED to another place via Change… (it stays until revoked).
2. **MB-2 — the door words:** the Clients row's "Share a place…" (was "Change…"), Shared with AI's "Share another place…".
3. **MB-3 — VX-512's line:** "Clients belong to the library they were set up in — run each one's setup here." (+ the practice note: any Start-fresh release's notes should carry the clients-don't-carry-over line.)
4. **MB-4 — VX-352's elision:** the label's own part kept whole, the client name yields, the whole label on hover (hover was dead — shadowed help — and is fixed; alternatives listed in the record).
5. **MB-5 — VX-358:** canonical no-op kept; an NFC↔NFD-re-spelled no-op answers one additive `…normalization_differs` field.
6. **MB-6 — NO App Nap guard built:** the trace found no road from throttling to a closed connection; `beginActivity` would also hold your Mac awake. Record-only.
7. **MB-12 — a quit says nothing (P-VX394-5 as ruled);** the alternative (a line from the quit road) is written up if you want it.
8. **MB-16 — a wing grant reaches a gathering place at the grant's own rung** (alternative: read-only).
9. **MB-17 — an ask on a gathering keys as its reading** (`.book(id)`; no new ask-target case).
10. **MB-19 + MB-22 — the copy pass:** every new sentence of the run (sheet lines, the star-rule refusal "Its rule needs a starred note, and only the author can star one.", the guide's two gathering cards, the gathering daily-Journal ask lead, and the inert row's "always asks" → the r2 reviewer suggests "…no grant reaches it").
11. **MB-15 — the lock-walk evidence call:** the GUI Castle-lock leg was skipped on the standing Fable safeguard; the Mac pin drives every lock road on a real Castle library. A 5-second ⌃⌘L on any Castle library shows you the drop line live if you want it.

**Offers (nothing built; say the word):** MB-8 riders (VX-565 · VX-590 · VX-566/567 · VX-367/368/369 · VX-321 — cheapest while this code is warm) · MB-18 a gathering's own place doors (Book Settings row, row menu) · MB-20 duplicate_note/add_note_to_book accepting a gathering id · MB-11 the Read-tier take label has the same tail-cut class · MB-13's two FILED: VX-612 (the dead listener) · VX-613 (the toggle races) · MB-14 the status line carrying a live client count · MB-21 the sheet's gathering rows show no note count · MB-10 the Book Panel header marks' size (taste).

**Tickets this run filed (triaged at filing):** VX-605 (Bug · Confirmed · MCP · Medium — the Clients row's "last seen" staleness on a live named connection) · VX-606 (Bug · Suspected · MCP · Low — read_note accepted an undeclared argument) · VX-607 (Bug · Test-only · Tests & tooling · Low — the second load-sensitive flake beside VX-532). VX-612 · VX-613 (MB-13's two, filed at closeout); from the final walk: VX-609 (the star-gathering ask offers write-new it can only refuse — the P-2 class, joins your copy-pass call) · VX-610 (a once-seen Bookcase row-count lag) · VX-611 (the Trash's kind word on a gathering).

## WHAT SHIPPED (one line per member)
- **VX-516 (Urgent, the gate):** two standing wing grants finally stand together — the revoke was the Change… roads passing `replacing` through any confirmed place; fixed at the sheet's one confirm via the pure `MCPGrantChange`; proven by pins on every road and live in the b1 walk.
- **VX-515:** "Share a place…" / "Share another place…" doors; the see-everything ask verified already honest (your "doesn't show both" WAS VX-516's revoke).
- **VX-512:** the zero-state explainer line on the pane.
- **VX-352:** the take-card label keeps its own words, the client name yields; the whole-label hover fixed (it was shadowed).
- **VX-354:** the Book Panel header and its gatherings wear the marks through the one rule.
- **VX-365:** add_note_to_book answers every tag the note wears (outflow included).
- **VX-358:** the re-spelled no-op says the spellings differ.
- **VX-394:** the stop-roads sweep (12 roads × the ruled line; 2 fixed red-on-old: a quit now says nothing every time, a mid-stop connection is hung up and says why; a stale start can no longer unlink the live socket — the real "running while dead" mechanism); your Air clue honored: the drops fit the by-design lock road, pending your MB-7 look.
- **VX-549 (not launch-gating — SHIPPED):** gatherings are grant places; reach = the rule's assembly at read; the Private MARK wins byte-identically; write_new mints bookless + applies the rule's tags; star rules refuse write_new honestly and present read/suggest-shaped; v1_33 local-only (marker stays 14).

## EVIDENCE OF RECORD
Headless (final tree): core 3466/463 · workbook 32/4 · MCP 412/75 (two standing flakes VX-532/VX-607, each green isolated). Mac: b1 window 141/12 green; mid window 336/39 executed (the one red became fix leg 2a-F1 — a justified pin edit, verified against the red log); final window 466 executed / 59 suites, zero skips, one deliberate pin flip (the gathering-scope parity expectation, re-run green 4/1). Walks: b1 (grant roads live), mid (take card, panel marks, the quit leg live), the final drill GREEN end to end (the Private member answers the byte-identical missing shape, verified programmatically; the star refusal in your door's words with nothing minted; both AX checks pass — the hover help leads with the whole label; the icon names the grant's own rung, MB-16). Canon-size: 125,721 / 150,000 (headroom 24,279) — no crossing. MOBILE PARITY: nothing mobile-visible (the phone has no MCP door; VariorumMobile untouched).

## FOR A FRESH SESSION (if anything needs resuming)
The record file is self-contained: batch records with LIVE STATUS, the ladder record with every finding and disposition verbatim, the canon-owed blocks per batch (drafted, applied at closeout), §MORNING BUNDLE. Worktree `~/dev/variorum-vx-548`, branch `vx-548-run-mcp-grant-pane-fixes`, origin/main merged in at `1ca1a297e`. Stage and merges through tonight's coordinator (oct26coordinator). The dev store holds VX-502's hand-returned library (e11e5233, held, signed out) — never press Resume; an approved `claude-code` client row and the walks' Trash content are known residue.
