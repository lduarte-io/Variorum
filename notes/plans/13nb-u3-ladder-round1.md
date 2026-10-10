# 13n-b U3 — ladder round 1 (cold review, fable-reviewer, 2026-10-10)

**Diff reviewed:** `cbfdab8a..HEAD` (`127c7726`) — everything since the U2 ladder closed: the U3 unit
whole (the in-transaction WriteGuard seam on the edit-rung ops, `Operations+MCPEdits` with
`editTakeUnderInsurance`/the eighth occasion, the CarryAllMerge move app → core, the six edit tools +
`create_section` on the wire, `with_commits`/`commit_ids` on read_note, `include_commits` on search,
chapters on list_notes and the wire document, either-payload `create_note` + `entry_date`, FORMAT v2
(the boundary marker), "Allow AI here", the activity face, the two walk fixes, the two self-review
fixes) plus the unit record, the live-round record, and the orchestrator handoff file.
**Anchor:** `notes/plans/phase-13n-b-mcp-door.md` read whole (the sitting record R-13nb-1…26 — the
U3 rulings R-13n-6/7, R-13nb-7/10/11, R-13nb-26 a/b/e; AF-1…AF-10; the U3 brief, unit record and
LIVE ROUND), all four prior ladder records (U2's F2 is the guard line this unit answers), the
wire-document memo, CLAUDE.md + auto-loaded canon. The plan carries no plan-time "Review foci"
section; the implementer's look-first list (a)–(f) was each traced (results below). SyncSpec not
re-read in full this round: the diff touches ZERO `Sync/`/`Server/` lines, no migration, no
lockstep (verified below); S1–S5 checked from OverallModel §6 against every new write.

**Verified myself, in this session (not taken from any record):**
- Every changed/new source and test file read whole or at the changed sites in context:
  `Operations+MCPEdits` (whole), `Operations.swift` (the WriteGuard seam), `Operations+Structural`
  / `+Placement` / `+Deletion` / `+Sections` diffs (guard threading; redo paths carry no guard),
  `Operations+MCPWrites` diff (either payload, `stampEntryDate`, `addNoteToBook`'s section arg),
  `Domain/CarryAllMerge.swift` diffed against the removed app copy (public + header comment only —
  byte-equivalent behaviour; no duplicate remains, grep-verified), `Domain/VariorumDocument.swift`
  (whole — the v2 grammar, escape, version token, both parsers), `Queries/MCPEditQueries` (whole;
  `mcpShownTake` compared line-by-line against `Operations.renderedVariant` — exact),
  `Queries/Export.swift` diff (the plain export never routes through marker mode),
  `MCPWriteTools.swift` (whole — Refused/ArgumentFailure thrown inside a guard IS caught by `land`'s
  mapping; the edit acts' `spendsAfter: false` snapshot never double-spends),
  `MCPWriteTools+Edit.swift` (whole), `MCPReadTools` diff, `MCPNoteStructure` diff (the commit
  budget, the readable-books filter), `MCPToolCatalog` diff, `Operations+MCPGrants`'
  `insertMCPGrant` (once-on-a-fenced-NOTE is legal — "Allow AI here" on a journal is not a lying
  door), `JournalDay.isValid`, the app faces (`PrivateMark`, `MCPDoor`, `MCPPane(+Copy)`,
  `MCPGrantSheet`, registry, both bars, `SettingsShape`, `DocumentImportCopy`), and all six
  new/changed test files incl. the ritual updates (each annotated as a justified edit).
- `swift build` green; the new suites green (`MCPEditActsTests` 11 + `BoundaryMarkerTests` 9 +
  `MCPEditServerTests` 9 + `MCPReadCarriageTests` 3, my own runs); **the whole headless package
  reproduces the record's finals exactly: core 2,563/294 · VariorumMCPTests 45/6 · workbook 40/6**,
  only the long-standing gated skips. (One full-package run recorded a single transient issue that
  did not reproduce on two immediate re-runs, both fully green with identical counts; the test's
  name was not captured — noted below, not a finding against the diff.)
- **Both self-review red-on-old pins re-verified by MY OWN revert runs** (`git show <fix>^:<file> >`
  swap → targeted run → `git checkout --`, tree clean after each):
  - `2328f26c` (the wing crossing): `MCPWriteTools+Edit.swift` at the pre-fix version →
    `moveBlockNeverCarriesABlockIntoAnotherWing` red with **5 issues** (the block landed in the
    other wing, an undo entry registered) — matching the record. Green on HEAD.
  - `45f06ec9` (entry_date at the op): `Operations+MCPWrites.swift` at the pre-fix version →
    `aMalformedEntryDateRefusesAtTheOpAndMintsNothing` red with **4 issues** (both mints landed) —
    matching the record. Green on HEAD.
- **My own mutation run on the guard seam:** `editTakeUnderInsurance`'s `try guardian?(db)` replaced
  by a no-op → `theGuardRunsInsideTheActsTransactionAndItsThrowRollsTheWholeActBack` red (5 issues)
  AND the e2e `aFenceLandingAfterTheDecisionIsCaughtInsideTheActsTransaction` red (4 issues — the
  edit landed past the fence). Restored; green on HEAD. The guard pins are not hollow.
- **Hygiene:** ZERO files under `Sources/VariorumCore/Sync/` or `Server/` in the whole range
  (`git log --name-only` over the range — empty); zero migrations/`Persistence` files, zero
  `lockstepVersion` touch; zero custody; zero editor seam (`EditorTextView`/`BlockRangeIndex`/
  `PaneSurface` untouched); zero attribution trailers across the range; branch in sync with origin;
  worktree clean (one untracked `default.profraw`, pre-existing noise). No Mac-suite re-run this
  round (the U2-R1 precedent: no stage claim owed — the implementer's R9 run 151/12 + post-fix 67/5
  is recent and 0-skipped, the Mac surfaces walk-covered with 16 captures, and the orchestrator's
  live round ran on a real build at `146cb7ba`; round 2 can demand one if the fix pass touches Mac
  files).

## The implementer's look-first list, each item traced

(a) **Guard ordering:** every edit act's writing op receives the guard (editTake, divide/divideW via
`measured`, merge/mergeCeremony, moveBlock, reorder, deleteBlock via `performDeleteBlock` forward
path only, setBlockName, createSection via `guardBook`) and every guard runs FIRST inside the op's
own `database.write`; a `Refused` thrown inside the guard propagates out of the op into `land`'s
`catch let refused as Refused` — logged `allowed: false`, the one refusal answer, transaction rolled
back. No escape path found. (b) **The fanned compositions' outside-transaction reads:** traced
fully — finding F2 below; the record's "one take short" is the benign direction only.
(c) **`editTakeUnderInsurance`'s dedupe and insurance:** `isDirty` is the house rule exactly (last
commit's text, `(created_at, id)` newest); the before-bracket dedupes correctly, the after-bracket
always lands on a change (+1 ms), the undo entry's `insuring:` carries the exact pre-image, I5 kept
across undo (pinned). (d) **Format v2's escape and run boundaries:** the stacking escape is exact
both ways (incl. indented and trailing-space marker lines); `markedText`'s one-blank-at-boundary /
all-blanks-after-section / edge-at-document rules are the serializer's exact inverse — verified by
reading AND by the >1000-shape sweep running green; the version token is read on the header line
only, prose beside it is body, capture untouched (pinned). (e) **The greedy commit budget:**
finding F1 — the record and the code disagree. (f) **U2's eight ops still decide-then-act:**
confirmed unchanged; P-13nb-U2-8 + its sync twin stand for them, as the brief allowed.

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### F1 — [MINOR, record-vs-code] · `notes/plans/phase-13n-b-mcp-door.md` P-13nb-U3-11 vs `Sources/VariorumMCP/MCPNoteStructure.swift:192-196` · the provisional her ratification will read describes a GREEDY budget fill; the built and PINNED behaviour is a prefix stop

**Evidence (traced):** P-13nb-U3-11 says the 100k budget "fills GREEDILY newest-first (**a commit
too large for what remains is omitted while a later, smaller one may still ride**)". The code reads
`else { entry["text_omitted"] = true; budget = 0 }` — the FIRST commit that exceeds the remaining
budget zeroes it, so every older commit is omitted too, however small. The pin asserts exactly the
prefix behaviour (`MCPReadCarriageTests.swift:67`: commits[2], the tiny "first draft", is
`text_omitted` — "texts ride newest-first: older ones wait too"), and the catalog description
matches the code ("past about 100,000 characters of commit text, older ones say text_omitted").
So the record misdescribes the shipped rule in the exact sentence that goes to her QUESTIONS
bundle. **Fix (either):** (a) correct P-13nb-U3-11's parenthetical to the pinned prefix rule — my
lean: a hole-free newest-first prefix is the more predictable contract, the omitted ones are
reachable by `commit_ids`, and AF-10 (d) ruled only "the 100k-char bound + the fetch"; record-class,
no pin owed. (b) Make the fill greedy as recorded and flip the pin — bug-class with an obvious
red-on-old pin (two commits, first over budget, second small → assert the second carries text; red
on the current code).

### F2 — [MINOR, architectural — traced; deterministically pinnable via the guardian seam] · `Sources/VariorumCore/Operations/Operations+MCPEdits.swift:254, 302-304` · the divide/merge compositions read the fan and shown take OUTSIDE the act's transaction; the in-transaction `measured` guard re-verifies only the shown take's TEXT, so a sync apply in the window can mis-shape the composition — and the unit record states only the benign direction

**Evidence (traced):** `divideBlock` reads `liveActiveFan` in its own `database.read`, composes
`KeepOnTopDivide` cuts from it (every other take "parked" POSITIONALLY at its then-current UTF-16
length), and only then opens the act's transaction; `measured` re-checks the shown take's
`workingText == expectedText` but not its active status, not that it is still the block's rendered
take, and nothing about the other takes. `mergeBlocks` reads both fans and both rendered ids the
same way. The whole wire body is one serial unit on the session's runner, so only the sync-apply
transaction can interleave (U2 F2's established fact) — but when it does: (i) a bystander take whose
text GREW since the read gets its stale "park at end" cut mid-text, so `divideWRows`'
`seamTrimmedHalves` SPLITS a take she synced from the other Mac at a position nobody chose (both
halves preserved on B and C, A preserved whole, one ⌥⌘Z recovers — no text is lost); (ii) one that
SHRANK refuses `invalidCut`, honest; (iii) a take ADDED stays on A in lineage — the only direction
the unit record's look-first (b) states ("the composition can be one take short"); (iv) the shown
take ARCHIVED refuses in the fanned path (`divideWRows` checks active) but in the single-take path
`measured` still passes (it checks `deletedAt`/text only) and plain `divide` then cuts the CURRENT
rendered take at an offset measured against the stale one — bounded by divideRows' own guards, but
a wrong-place cut in a take the client never read. Unlike U2's F2 (two transactions, no seam), this
window IS deterministically pinnable: a `guardian` closure that mutates the fan inside the act's
transaction reproduces the interleave exactly (my guard-mutation run demonstrates the injection
point works). **Severity bounded** by: sync-apply-race only; no disclosure (the fence/scope guard
is in-transaction and I verified it); no text loss (divide-W preserves A whole and both halves);
one undo recovers. **Fix (any of):** (1) compose inside the act's transaction (read the fan in the
same `database.write` — the clean close); (2) extend `measured` to re-verify the composition's
premises (shown take active AND still the rendered take; each composed take's id + UTF-16 length
unchanged) and refuse `bufferChangedSinceGesture` otherwise — small, same pattern as today; (3) at
minimum, restate the record (the sync twin's edit-rung extension) with the full direction set so
the recorded consequence is not understated. If (1)/(2) is taken it carries a red-on-old pin
through the guardian seam (guardian grows a bystander take's text → old code mid-splits it, fixed
code refuses/parks correctly).

### F3 — [NIT] · `Sources/VariorumMCP/MCPNoteStructure.swift:168-178` · `commits` fetches EVERY commit's full text though only ~100k characters ride the answer

**Evidence (traced):** the one SQL selects `c.text` for every commit of every take of the note;
the budget then bounds the ANSWER, not the fetch — a long-lived note's whole commit history is
materialized in memory inside the write transaction `readNote` holds. P1 holds by the letter (cost
∝ the note + its history, never the corpus), so this is shape, not a violation. **Fix shape:**
select `length(text)` in the listing pass and fetch texts only for the rows that ride (the asked
ids + the budget prefix). No pin owed (no wrong output).

### F4 — [NIT, copy] · `App/Variorum/Variorum/Features/MCP/MCPPaneCopy.swift` (`activityPhrase`) + `MCPActivityFace.lines` · a coalesced run of `create_note`/`import_document` lines reads one note's title with a count that spans different notes

**Evidence (traced):** `create_note` logs kind "book"/"wing" with the NOTE's title
(`land`'s `landed.receipt?.targetTitle ?? title`); coalescing keys on client·act·targetID(the
book)·kind·outcome, so two consecutive creates into one book read "claude-code made the note
“<newest title>” (2 times)" — one title, two different notes. The J8 copy-truth doctrine is why the
receipts count from the op's own result; the activity line should not imply both creations made the
titled note. **Fix:** pluralize the phrase when `count > 1` ("made 2 notes in …" / "imported 2
documents"), or coalesce `create_note`/`import_document` by a key that includes the title. Copy
only, 13s-a-sweepable; no pin owed.

**Observation, record-only (no finding):** one whole-package core run in this session failed with
exactly 1 issue (counts 2,563/294 matching) and did not reproduce on two immediate full re-runs;
the failing test's name was not captured by my output filter. The core suite appears to carry at
least one timing-sensitive test — worth an eye at the closeout's whole-target run; nothing in this
diff is implicated (the failure did not recur, and every targeted U3 suite is green across runs).

## Clean bill (load-bearing things specifically checked and found solid)

- **The guard seam is the U2 F2 disposition built exactly:** `WriteGuard` runs FIRST inside each
  op's own write transaction; `nil` on every door of hers (grep: zero `guardedBy` callers in the
  app); no structural REDO carries one (deleteBlock's redo path takes the default nil; divide/
  merge/move redos are exact-row replays with no guard parameter). The fence/scope re-decision is
  real and spends atomically: `guardEdit` re-resolves EVERY touched note from the act's own rows
  (source + destination for move; both sides for merge), decides each at EDIT through the one pure
  rule, dedupes shared once grants via a Set, and stamps inside the same transaction. My mutation
  run proves both the core and e2e pins catch a dropped guard.
- **The edit-half PROOF is real:** the proof pin's calls set is asserted complete against the edit
  tool roster; under suggest AND write-new wing grants every edit door refuses at the rung with the
  tools not even listed, and variant/container_block/block/commit_point are byte-identical after
  (snapshot compare). The live round confirmed the listing fence with a real Claude Code client.
- **The eighth occasion is the house auto-commit exactly:** kind 'auto', the client's name verbatim,
  the standing `isDirty` dedupe (before skipped when her commit already holds the text — pinned,
  and the live round saw the dedupe on a real take), the after-bracket +1 ms so `(created_at, id)`
  reads before → after (pinned newest-first), `expectedText` refusing as
  `bufferChangedSinceGesture` with nothing written, touch + churn as any text edit (`churnCost` =
  common-ends delta, pinned), ONE undo entry with exact pre-image and the fourth-occasion insurance
  riding `insuring:`, commits kept across undo (I5, pinned). Locked take / archived take / sealed
  post each refuse (pinned); `editableVariant` + `ensurePlacementUnlocked` are the enforcing
  helpers, read by me.
- **The structural tools are her doors' compositions, relabeled, never re-implemented:**
  `KeepOnTopDivide` / `CarryAllMerge` over `divideW` / `mergeCeremony`, plain ops when fanless;
  `registeringUndo(as:)` is `withCompound` over the act's own registration (inverse/redo/insurance
  the act's own). The merge join is applied to texts read INSIDE the ceremony's transaction
  (`pairing.join.joined(head.workingText, tail.workingText)` — the join rule rides, never stale
  text). CarryAllMerge moved byte-equivalent (public + comments only; single copy; the parity
  suites ran unmodified in my full-package run).
- **The cut addressed by text (AF-10 (c)):** exactly-once literal match, overlapping occurrences
  counted, offset > 0, computed against the same `mcpShownTake` text the `measured` guard re-checks
  in-transaction — the LLM-miscounts class is closed for the shown take (F2 is about the OTHER
  takes).
- **Once on the edit rung:** spent inside the act's transaction, atomic; a refused act (stale read)
  rolls the stamp back with it; one write means one write (e2e pinned, and the no-op-spends edge is
  recorded as P-13nb-U3-3 with its alternative).
- **The wing fence (P-13nb-U3-5):** re-verified red-on-old by my own revert run (5 issues — the
  block and its undo entry landed across wings on the old guard); the check runs inside the act's
  transaction beside the grant decision; merge/divide/edit cannot cross wings by construction
  (adjacency / single-note scope).
- **entry_date is a Phase 9b day key at BOTH boundaries:** wire (`DateFormatter` strict round-trip)
  and op (`JournalDay.isValid` — read by me: zero-padded, real proleptic-Gregorian day); the op
  refusal rolls the whole mint back (re-verified red-on-old, 4 issues). `stampEntryDate` and the
  block-name writes land inside the mint's transaction, before the book's hand-add gates run.
- **The structured payload cannot misalign names:** `mintDocument` mints one block per document
  block unconditionally (read by me), so `zip(minted.blockIDs, blocks)` is 1:1; empty-text TAKES
  drop (the export's own rule), `blocks: []` mints ⌘N's empty note.
- **FORMAT v2 is the ruled grammar whole:** marker mode iff a blank line with non-blank after
  (leading blanks included; trailing spacing and take-internal blanks stay v1 — pinned); v1
  byte-identity otherwise (pinned, and every 13n-a byte pin ran green in my full-package run); the
  exact-inverse sweep covers >1000 marker-mode shapes incl. marker-as-prose, stacked escapes,
  indentation, whitespace-only lines, blank-chosen sections, stored spacing; the version token is
  read on the header line only (prose beside it is body; unknown versions refuse naming the line;
  `{v:1}` reads v1; capture grammar untouched — all pinned); the PLAIN export never routes through
  marker mode (`Export.swift`'s `includeVariants` split, read by me; pinned down to the PDF
  projection and the no-row-writes outbox pin); the wire round-trips v2 byte-for-byte over a real
  socket (pinned); the folder door reads v2 through the one parser (pinned); the app words
  `unsupportedVersion` honestly.
- **The read carriage honors its rulings:** `with_commits`/`commit_ids` reachable at READ
  (R-13nb-7's letter), never ambient, never the Level 0 text (pinned); a stranger commit id gets
  one answer with no oracle (ids of other notes' commits indistinguishable from nonexistent);
  `include_commits` default false, the never-lists-without-the-facet fence pinned, savepoint
  passages scope-checked per note and carrying commit_id/saved_at; chapters ride list_notes and
  the wire document for READABLE books only (AF-10 (f) pinned, incl. the unshared book's name
  withheld and the dangling-pointer-reads-unsectioned rule).
- **The app faces:** the grant sheet offers edit with the mockup §3 sentence (U2's rung pin updated
  as the ritual, annotated); W-1/W-2's amended copy pinned true under the edit rung; "Allow AI
  here" renders only approved-not-already-reaching clients (P-2), grants THAT note read·once
  through the ordinary op — and the op genuinely allows once-on-a-fenced-note (read by me:
  `insertMCPGrant` refuses only `always` on a fenced note), so the journal/Private case is not a
  lying door (pinned); registry-declared, both bars render it, walk-covered. The activity face is
  pure coalescing over the existing log (newest-first, run = client·act·target·outcome, newest
  stamp/id kept), capped with a real "all N ›" road on the same sheet as U1's three (no gap —
  verified in `MCPFullListSheet`).
- **Scope and fences held:** zero `Sync/`/`Server/`/custody/editor-seam/migration/lockstep lines in
  the whole range (my own `git log --name-only` over the range); the export pin intact (re-pinned
  in `BoundaryMarkerTests`); R-13n-1 holds (nothing assumes the client is external); sentence case
  throughout the new copy; MOBILE: nothing mobile-visible in this unit.
- **The counts reproduce:** core 2,563/294 · VariorumMCPTests 45/6 · workbook 40/6, gated skips
  only — my own whole-package runs (twice green; the one transient issue noted above).

**VERDICT: 0 BLOCKER · 0 MAJOR · 2 MINOR (F1 record-vs-code on the commit budget; F2 the
compositions' outside-transaction fan reads — bounded, pinnable, understated in the record) ·
2 NIT (F3 commit-text fetch shape; F4 activity-line coalescing copy).** The edit rung's security
boundary itself — the rung fence, the in-transaction re-decision, the atomic once spend, the
insurance brackets, the wing isolation, the format's byte discipline — is solid and pinned from the
pure rule through the ops to a real socket session, and every load-bearing red-on-old claim I
tested reproduced under my own hands.

## ROUND 1 — IMPLEMENTER RESPONSES (opus-implementer, 2026-10-10, traced at `7c835cfb`)

**Four AGREE, zero disputes.** The implementer re-traced each finding against the code, confirmed
F1's record was its own misremembering (the code and pin were always a prefix stop), confirmed
F2's full direction set line by line (the fan read sites, `measured`'s exact checks, the bystander
mid-split, the single-take wrong-rendered cut, the merge left-behind), preferred F2's option 2
(the expectedText precondition class widened to the composition's premises — the composition stays
pure and outside the op), added the F3 caution that SQLite `length()` counts code points so a
two-pass fetch must not silently change P-13nb-U3-11's Characters unit, and preferred F4's
pluralize-the-count shape. No edits were made in its pass. (The verbatim response is the
coordinator's relay in this session; this paragraph is its faithful record.)

## FINAL DISPOSITIONS (the reviewer's calls — fable-reviewer, 2026-10-10, the fix pass its own; 4/4 AGREE received, zero disputes. Every bug-class fix carries a red-on-old pin verified BEFORE the fix AND by revert after the commit; one commit per piece, pushed; suites green after.)

| # | Severity | Response | FINAL disposition |
|---|---|---|---|
| F1 | MINOR (record) | AGREE — correct the record | **FIXED (`6104d4e9`, record)** — P-13nb-U3-11 corrected to the PINNED PREFIX rule with the correction marked honestly in place (the "greedily … a later, smaller one may still ride" clause the code never did and the pin contradicts); the prefix rule kept as the contract (contiguous newest-first, omitted texts by `commit_ids` — the catalog's own sentence; AF-10 (d) ruled only the bound and the fetch). No code change. |
| F2 | MINOR (arch) | AGREE — option 2 preferred | **FIXED (`a87fc8ec`)** — the implementer's preferred shape, which I concur is right (the composition stays pure and outside the op; every window case becomes ONE honest refusal): `divideBlock`'s `measured` now re-verifies, inside the act's transaction, the fan's ids AND texts (a parked cut is positional) plus the shown take still this block's RENDERED take; `mergeBlocks` gains the equivalent guard (both fans' membership + both shown takes still rendered; texts deliberately unchecked — the ops read them in-transaction) on BOTH roads, the plain path included, so an arrived take refuses instead of being stranded in silence. **Pin `aCompositionStaleAtTheActRefusesInsteadOfMisShaping`** — three legs, each guardian playing the sync apply deterministically inside the act's transaction: RED on old (**6 issues**: the bystander mid-split landed with `keptOnTop: 1`, the wrong-rendered-take cut landed, the plain merge landed with the arrived take left behind), green after; **revert-verified after the commit** (source at `a87fc8ec^` + the committed pin → the same 6 issues; tree restored clean). The plan's mandate-decisions bullet amended (`6104d4e9`). The empty-side pass-through preserved (the chain's rule: the op's own typed refusal speaks there). |
| F3 | NIT | AGREE (+ the unit caution) | **RECORDED** — record-only, my final call: no wrong output, P1 holds (the fetch ∝ the note's own history), and the honest fix is blocked by the `length` field itself — OMITTED commits carry a Characters-count `length`, which requires the text; a two-pass fetch would have to re-unit `length` (SQLite `length()` counts code points) — a deliberate record change, never a silent one. The constraint is written into P-13nb-U3-11 (`6104d4e9`) so any future fix starts from it. |
| F4 | NIT (copy) | AGREE — pluralize preferred | **FIXED (`ff1da3f7`)** — a coalesced CREATION run's line speaks the count plainly: "made 2 notes" · "imported N documents" · "made N books" · "added N chapters to “book”" (create_section's title IS the book, so it keeps its place); never one creation's title with a count spanning different creations. Copy only (J8's copy truth), 13s-a-sweepable, said in the code; the coalescing pin extended as a justified edit. Mac focused suites under a HELD stage claim (claimed and released): MCPEditFacesTests + MCPAskAndReceiptTests + MCPPaneTests **23/3, 0 skipped**. |

**Fix-pass verification (2026-10-10):** whole headless package at the end of the pass —
**core 2,564/294** (the pre-pass 2,563 + the F2 pin) · **VariorumMCPTests 45/6** ·
**workbook 40/6**, all green, only the long-standing gated skips. Zero lines in
`Sources/VariorumCore/Sync/`/`Server/`, zero custody, zero editor seam, zero migrations in the
pass; zero trailers; every commit pushed (`a87fc8ec` F2 · `6104d4e9` F1/F3 records ·
`ff1da3f7` F4 · this records commit).

**For round 2, look first at:** (1) F2's guards — `divideBlock`'s `measured` (ids + texts +
rendered-ness; the single-take and fanned paths both route through it) and `mergeBlocks`' guard
(ids + rendered-ness on BOTH roads; the empty-side pass-through deliberately kept so the op's own
refusal speaks); whether any window case can still land mis-shaped, and whether the guard's
`try? renderedVariant` nil-handling is right for a block that died in the window
(`bufferChangedSinceGesture` speaks instead of `blockNotFound` — judged honest, worth a fresh
eye); (2) the F2 pin's three legs really isolate the interleave (each guardian is the only
writer; the rolled-back guardian write is asserted); (3) the record edits — P-13nb-U3-11's
corrected prefix clause + the F3 note, the mandate-decisions amendment; (4) F4's words beside the
mockup §2 idiom and the sentence-case rule.
