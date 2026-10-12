# 13n-c U1 — ladder round 1 (cold review, fable-reviewer, 2026-10-11)

**Reviewer model (stated per the plan's §5 rule): Fable 5 (`claude-fable-5`), xhigh.**

**Diff reviewed:** `9b1ec3dd..HEAD` (= `33bd8772`; the whole U1 arc: pins-red-first → the re-key →
T-2's one answer → copy truth → R-AIR-3 → U1-5b → the orchestrator's F-7 (a) build → adjudications).
**Anchor:** `notes/plans/phase-13n-c-mcp-launch-readiness.md` read whole (rulings, D-1…D-5, §3 U1,
the U1 unit record and traces, the FABLE-OWED ledger), `notes/plans/vx-156-grant-ux-design-kickoff.md`
(R-AIR-1/R-AIR-3 verbatim), `notes/plans/vx-156-grant-ux-brief.md` §9's recommended words, CLAUDE.md +
auto-loaded canon (AppSpec §12's MCP-door line, §7's v1_25 bullet). SyncSpec not re-read in full: the
diff touches zero `Sync/` lines, zero schema, zero custody (verified below), and D-5's trace was
re-verified by my own grep. No plan-time "Review foci" section exists (grepped the plan, the kickoff
prompt and the DRAFT); the implementer's look-first spots are each traced below.
**Verified myself:** every changed source and test file read in this session; `swift test --filter
MCPFenceRekey` → 5/5 core; `--filter MCPFenceRekeyServerTests` → 3/3 server (match the record's
counts). Headless only — no stage claim needed, no Mac re-run this round (the implementer's 107/9 run
is hours old; round 2 can demand one if fixes touch app files). Red-on-old evidence accepted from the
record's watched-red counts (U1-1) plus the five mutation checks (U1-6), which I cross-read against
the pins they name; I did not mutate the tree myself (read-only round).

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### F1 — [MAJOR] · `Sources/VariorumCore/Domain/MCPGrantRule.swift:227-231` (`decide`) · a client holding a LIVE per-ask grant on a fenced note that asks a HIGHER rung is told the note may not exist — the fence branch outranks `rungTooLow` (the recorded F-8, confirmed)

**Evidence (traced):** in `decide`, after `sufficient` filters out the under-rung grant, the order is
`if let fence { return .ask(.fenced(fence), …) }` before the `reaching.map(\.rung).max()` rungTooLow
branch. Inputs: a fenced note (daily-Journal entry or Private), a live while-connected (or unspent
once) READ grant naming that note — `reaches` returns true for it (note scope, non-always,
`MCPGrantRule.swift:278-281`) — and a `suggest`-rung call (`add_take`, via
`MCPWriteTools.onNote(rung: .suggest)`). The decision is `.ask(.fenced)`, which 13n-c U1's T-2 maps to
the ONE `notShared` answer (`MCPGrantAuthority.swift:138-143`): *"That note isn't shared with this
client, or doesn't exist…"* — said to a client that can read the note THIS SECOND on its own grant. An
agent believing its id dead drops it; the honest answer is `rungTooLow(granted: .read)` + the asked
sentence (the ask IS queued — `MCPAsking.refusal` fires `onAsk` for the note target). No oracle opens:
the branch is reachable ONLY while the client holds a live grant on that very note (a spent once grant
is not live; revocation returns it to the one answer), so `rungTooLow` discloses nothing beyond the
client's own grant — exactly AF-6's ruled posture for "targets the client legitimately knows exist",
and AppSpec §12's no-oracle letter governs *unreachable* things, which this note is not. The
implementer and orchestrator recorded this edge deliberately unbuilt (FABLE-OWED F-8, "the security
rule itself — Fable's eye first"). **My call: build it.**
**Pin (red-on-old):** `MCPGrantRule.decide(client: .approved, grants: [a live connection-duration READ
grant naming the fenced note], openBook: false, target: .note(fenced facts), rung: .suggest, consumes:
true)` expects `.ask(.rungTooLow(granted: .read), offersAlways: false)` — the current tree answers
`.ask(.fenced(.journal), offersAlways: false)` → red. Wire twin: per-ask read grant on a daily-Journal
entry, `add_take` → words == "This client may only read here. " + askedSentence (old: the one
`notShared` answer) → red.
**Fix (contained):** in `decide`, hoist the rungTooLow branch above the fence branch —
`if let highest = reaching.map(\.rung).max() { return .ask(.rungTooLow(granted: highest),
offersAlways: fence == nil) }` — keeping `offersAlways: false` whenever the target is fenced (R-13n-4:
a fenced ask never offers always; `MCPAsk.offersAlways` independently derives from `fence`, so her
sheet is safe either way). `MCPRefusalCopy` needs no change: `rungTooLow` already speaks without
naming any fence. One doc line in the `Fence` comment.

### F2 — [MINOR] · `App/Variorum/Variorum/Features/MCP/MCPAskSheet` road (per the U1 record's NOT-DONE item 4) · R-AIR-3's clause is on NO ask-road book grant — "Always" on a BOOK ask mints a standing book grant with the live-membership disclosure said nowhere

**Evidence (traced):** R-AIR-3's letter is "the including-future-entries clause shows on EVERY book
grant". A book ask reaches her sheet today via `rungTooLow` on a book target (e.g. a read-granted book
+ a `create_note` into it queues a `.book` writeNew ask); the sheet answers with bare
Once/While connected/Always buttons and no confirm sentence, and her Always press mints the standing
book grant with the clause never shown. The implementer recorded this (U1 record NOT-DONE item 4) and
the plan assigns the ask road's rebuild to U2/U4 — a legitimate in-phase deferral. The finding is the
condition: **if U2/U4 fall out of the phase (§4 names fall-out candidates), this becomes a named
ticket, not a loose end** — the ruling's "EVERY book grant" is otherwise silently narrowed to the
sheet road.
**Pin (red-on-old, when built):** the ask sheet's book-ask face carries the clause (or a confirm line)
— asserting its presence is red on today's tree. **Fix:** U2/U4 as planned; this row is the tracker.

### F3 — [MINOR, doc-class — no pin owed] · the U1 record's NOT-DONE item 5 + AppSpec §7/§12 · the closeout's owed canon deltas are under-enumerated: two shipped AppSpec sentences still assert the journal-CLASS fence

**Evidence:** AppSpec §7's v1_25 bullet reads "(R-13nb-4: **journal-class fence**, privacy wins ties,
…)" and §12's MCP-door line reads "**journal-class notes** AND anything wearing the Private mark
answer only a per-ask note grant" — both falsified by R-AIR-1's re-key (the fence is now THE
daily-Journal's marker + the ⌘J own-profile leg + Private). The unit record's merge-time list names
only AF-6's supersession ("the closeout's delta to record"); if the closeout records just that, canon
keeps asserting the trait fence the code no longer has. **Fix:** add both §7's and §12's fence
sentences to the closeout's delta checklist now (one plan-file line), alongside the AF-6 supersession
and R-AIR-1's contract line.

### F4 — [NIT] · `App/Variorum/Variorum/Features/MCP/MCPGrantSheet.swift:149` · `scope: place == .book ? .book : .wing` — a non-exhaustive mapping one U2 case away from lying

**Evidence:** the sheet's `Place` enum is exactly {book, wing} today, so the ternary is correct — but
U2's brief adds "A note" to WHERE (§3 U2 item 3), and this line would then silently stamp a NOTE grant's
confirm with the WING clause ("including notes added later" on a one-note grant). **Fix:** an
exhaustive `switch place` (U2 owns the row anyway; this is a note for its implementer).

### F5 — [NIT] · `Sources/VariorumMCP/MCPSession.swift:28-34` · "Every refusal says why." is now a diluted truth

**Evidence:** for a fenced note the stated why is deliberately not the classification (the one
`notShared` answer). The implementer dispositioned SAFE ("the one answer IS a why"); defensible, and
U5 rewrites the instructions — carry this line so U5's rewrite drops or rewords the sentence.

### F6 — [NIT] · `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift:333-336` (`MCPAskCopy.lead`) · the journal lead attributes every journal-leg fence to "your daily Journal"

**Evidence:** D-1's own-profile leg fences a ⌘J entry filed into a TRAIT book (or bookless); her ask
sheet then says "A daily Journal entry. Your daily Journal is only ever shared one ask at a time" about
a note living in "dream journal". The first sentence is true (it IS a day entry); the second names the
wrong home. Mockup §8's words verbatim, inside PROVISIONAL P-13nc-1 — a copy-pass nuance, hers.

## Adjudication verdicts (the FABLE-OWED rows this diff carries — my final word as the cross-model reviewer)

- **T-2 / F-6 / F-9 — CONCUR.** AppSpec §12's letter ("no fenced-vs-unshared oracle anywhere, down to
  the byte-identical beyond-grant lineage stub") and the 13n-b handoff's promise both bind; AF-6's
  fenced clause was the outlier, and the visible cost (a client that once read a note hears the one
  answer after she marks it Private) is the Private mark WORKING, not a price. The ask still reaching
  her (verified: `MCPAsking.refusal` queues for note targets) preserves R-13nb-1's more-asks posture.
- **F-7 (a) — CONCUR, and (b) was rightly rejected.** (b)'s premise — "a fenced book id is only ever
  known to a client that could once read it" — fails exactly where it matters: list a book, have her
  mark it Private, call `list_notes(book_id:)` — under (b) the reply confirms the mark; under (a) it is
  the one answer. The build is right: `words(.fenced, target)` → `words(.notShared, target)` for notes
  AND books, the asked sentence reserved to `rungTooLow`, the fenced-book ask still never queued
  (`MCPAsking`'s `!(scopeKind == .book && fence != nil)` guard, fence always carried from facts).
- **F-5 (the re-key itself) — SOLID.** One SQL fragment (`dailyJournalLegForBook`,
  `MCPGrantQueries.swift:406`) feeds all three sites; NULL-safe in SELECT-column position
  (`IS NOT NULL AND =`), interpolates only the static constant `dailyJournalBookProfile` ("daily");
  `NOT (…)` in `mcpGrantableBooks` admits NULL-profile books correctly; `own_journal` decoded
  `as Bool? ?? false` (NULL-safe); `member_journal` is an EXISTS (never NULL). Every reader follows by
  construction — I verified none re-derives (grep: no parallel fence SQL anywhere).
- **F-8 — CONFIRMED AS A DEFECT; finding F1 above is its disposition.**
- **D-1 — CONCUR; factual premise verified myself:** the only shipped door minting a note's own
  `profile='journal'` is `createOrOpenJournalEntry` (`Operations+Container.swift:80`); `setProfile`
  has no shipped caller; `LibraryViewModel`'s `.journal` is a read filter. Conservative direction,
  PROVISIONAL P-13nc-1 logged.
- **D-3 — CONCUR** (membership is live under any duration; wording PROVISIONAL P-13nc-3, hers).
- **D-5 — CONCUR; re-verified myself:** `git diff --stat` shows zero `Sync/` files; my grep over
  `Sources/VariorumCore/Sync/` finds profile reads only in the daily-Journal keeper repair
  (`Repairs.swift:296-298`, `isDailyJournalMintShape`) — not the MCP fence.

## Clean bill (load-bearing things specifically checked and found solid)

- **The one-answer uniformity, end to end:** every wire refusal flows through `MCPRefusalCopy.words`
  (grepped every emitter: `MCPReadTools.refusal`, `MCPShowTool.refusal`, `MCPWriteTools+Edit.refused`,
  the two hardcoded `words(.notShared, .note)` guard throws, `MCPAsking.refusal`); `.fenced` returns
  `words(.notShared, target)` verbatim and the `asked` flag alters `rungTooLow` only — so fenced =
  unshared = nonexistent byte-for-byte on every tool by construction, books included. No remaining
  fence-naming string anywhere in `Sources/VariorumMCP` (grepped "journal", "Private", "That book is").
- **The byte-identity pin's reach:** read_note, export_note, note-scoped search, set_entry_date (the
  edit road), word-search zero-passages (incl. the member-only word `quillwort`, which M3 proved
  bites), list_books exclusion + the trait book's honest zero count — all under the ruled Home-wing
  read grant; the unit-level words-equality pin covers the tools not individually wired (list_notes
  book scope, the suggest tools) by the one-site construction above.
- **The re-keyed derivation:** trait book offered/grantable/chipping/listed; daily Journal fenced on
  every road incl. archived (alive) and the stale-bearer case (conservative); the hand-filed
  non-⌘J member fenced by the member leg alone; Private wins ties inside a trait book; the ⌘J entry
  fenced in a trait book (D-1). Both new suites run green by my own hand; the red-on-old counts and
  five mutation checks (M1–M5) are recorded per-pin and cross-read as coherent.
- **R-AIR-3 in the sheet:** her sentence byte-exact for the book case ("Grant read in “dream journal”
  always, including to future entries" — pinned); every duration keeps the clause; wing twin per D-3;
  note scope clean; `confirmParts` join pinned equal to `confirm`; `ConfirmLabel` compresses ONLY the
  place (middle-truncated, lead/tail at layoutPriority 1), accessibility combined; the 520→600 width
  is documented with measured numbers and U2 owns the row's final design.
- **Copy truth (J8):** all six sentences in the brief's recommended words, pinned Mac-side
  (`theFenceSentencesNameTheDailyJournalNotEveryJournal`) and wire-side; my own independent grep for
  stale "journals are never shared"-class sentences across Sources/, App/ (incl. Shared/, the field
  guide, PrivateMark copy, the mobile target) found none the record missed.
- **Ritual hygiene:** every flipped pre-existing pin carries an in-place justification naming the
  ruling; the renamed test (`…RaisesTheAskAndTheWireStaysOneAnswer`) still asserts the ask LANDS —
  behavior narrowed on the wire only, her side intact.
- **Discipline:** zero `Sync/`, zero schema/migrations, zero editor seam, zero custody; no corpus-cost
  regression (the fence legs are per-note EXISTS; `mcpGrantableBooks` is author-scale books); no
  colour literals; sentence case throughout the new copy; commits trailer-free, per-piece, pushed; the
  capture harness gated off by env var (asserted-on snapshot caveat recorded honestly as NOT a walk);
  the screens dir gitignored (the 13n-b precedent).
- **The perf-benchmark sighting** (`timelinePageIsFlatOrUnderBudgetInCorpusSize` red once under whole-
  package load): verified unrelated to this diff — no timeline, query-page or persistence code is
  touched; the watch-item disposition stands.

**Round-1 verdict:** one MAJOR (F1 — the deliberately-parked F-8 edge, now confirmed and owed a fix
with its pin), two MINOR (one a tracked in-phase deferral, one a closeout-checklist gap), three NITs.
The fence re-key itself, the one-answer flip and the confirm clause are correct, well-pinned and
honestly recorded. Per the cross-model flow: F1's fix is mine to implement on the coordinator's
authorization, with the decide-level and wire pins above, red-on-old verified by revert.

---

## DISPOSITIONS (cross-model flow — written by the ORCHESTRATOR, Opus, because the reviewer died at her Fable limit)

**Machinery, said plainly:** the reviewer (claude-fable-5) received the authorization, BUILT F1
(`c1047097`, its own commit message records the red-on-old counts: decide-level 4 issues, the
boundary sweep's new invariant 5, the wire pin 1 issue — all green after) and then terminated at
the author's Fable usage limit (HTTP 429, `req_011CfvMuXtEEWRkKRbhywDAj`) BEFORE writing this
section. Per the resiliency protocol's budget-death addendum the remainder runs on Opus and is
recorded, never retried on Fable. The implementer's verdicts were: AGREE ×6 (with the F1 lapsed-
grant pin refinement and the F3 nuance below).

| # | Severity | Implementer | Final disposition |
|---|---|---|---|
| F1 | MAJOR | AGREE (+ lapsed-grant pin) | **FIXED by the reviewer `c1047097`** — rungTooLow answered before the fence when a LIVE grant reaches the note; offersAlways false on a fenced target; a spent/revoked grant falls through to the one answer (the lapsed-grant pin, per the implementer's refinement). Red-on-old by the reviewer's own revert. The orchestrator's whole-package rerun at `e4752ee3`: core 2,586/296 · VariorumMCPTests 69/9 · workbook 40/6, all green (one VX-132 sighting on the way: the dead reviewer's orphaned `swift test` sat 60 min inside VariorumMCPTests — killed, its output unread). FABLE-OWED F-10 (the security rule edited — written by Fable, its re-review is Opus's). |
| F2 | MINOR | AGREE | **DEFERRED, tracked:** U2 (the ask sheet's durations) / U4 (the ask road) carry R-AIR-3's clause onto every ask-road book grant; if either falls out, a named ticket at closeout — the ledger row is added. |
| F3 | MINOR (doc) | AGREE with nuance | **CLOSEOUT CHECKLIST:** AppSpec §12's "journal-class notes AND anything wearing the Private mark answer only a per-ask note grant" is rewritten to R-AIR-1's keys (the daily Journal's entries + ⌘J entries + Private); §7's v1_25 "journal-class fence" bullet REVIEWED for wording (still true of the Private mark's behaviour — the nuance adopted); beside AF-6's fenced-clause supersession (T-2/F-7). Added to the plan's closeout-delta list. |
| F4 | NIT | AGREE | **U2's brief:** the confirm's scope becomes an exhaustive switch when U2 adds "A note". |
| F5 | NIT | AGREE | **U5's brief:** the `instructions` rewrite drops/rewords "Every refusal says why". |
| F6 | NIT | AGREE | **Copy pass (hers):** the ask lead for a ⌘J entry filed elsewhere — logged under P-13nc-1. |

**Round 2** (a fresh reviewer re-reviewing the fix, `c1047097`): `opus-reviewer` (her Fable budget is
spent) — recorded in `13nc-u1-ladder-round2.md`.

**The cross-model flow's implementer sanity pass** is FOLDED INTO ROUND 2 (a fresh Opus reviewer re-reading the fix cold) — the U1 implementer sits at ~500k tokens, past the context line; a deviation from the flow's letter, recorded.
