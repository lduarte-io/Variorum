# 13n-b U3 — ladder round 2 (cold review, fable-reviewer, 2026-10-10)

**Diff reviewed:** `7c835cfb..HEAD` (`282997af`) — the round-1 fix set whole: F2's composition
guards (`a87fc8ec`), the F1/F3 record edits (`6104d4e9`), F4's activity copy (`ff1da3f7`), plus the
round-1 record commits (`9788f17b`, `282997af`). Exactly six files in the range (my own
`git log --name-only`): `Operations+MCPEdits.swift`, `MCPEditActsTests.swift`, `MCPPaneCopy.swift`,
`MCPEditFacesTests.swift`, the plan file, the round-1 record.
**Anchor:** round 1's record (`13nb-u3-ladder-round1.md`) — its four findings, dispositions, and
round-2 look-first list, each item traced below; the plan's U3 sections re-read at the amended
sites; CLAUDE.md + auto-loaded canon. The unit's surrounding range (`cbfdab8a..127c7726`) consulted
where the fixes compose with U3-main code (the wire layer, the structural ops' guard threading).

**Verified myself, in this session (not taken from any record):**
- `Operations+MCPEdits.swift` read WHOLE at HEAD — both new guards in full context, plus
  `liveActiveFan` (deterministic `ORDER BY fan_position, id`), `renderedVariant` (read at
  `Operations+Structural.swift:23-45`), and the wire call sites (`MCPWriteTools+Edit.swift:136-162`
  — `guardEdit` threads into `measured` via `guardian?(db)` first, unchanged).
- **The F2 pin red-on-old by MY OWN revert run:** `Operations+MCPEdits.swift` swapped to the
  `7c835cfb` version → `aCompositionStaleAtTheActRefusesInsteadOfMisShaping` red with **6 issues**
  matching the record exactly — leg 1 the bystander divide LANDED (`keptOnTop: 1`) with the
  guardian's write persisted, leg 2 the single-take divide landed cutting the swapped-in take,
  leg 3 the plain merge landed (`carried: 0`, the arrived take stranded) and an undo entry
  registered. Green on HEAD after `git checkout --`; tree clean (`git status`: only the
  pre-existing untracked `default.profraw`).
- **Guard placement re-verified by reading:** `divide` (197-198), `divideW` (357-358), `merge`
  (909-910), `mergeCeremony` (1092-1093) in `Operations+Structural.swift` each run
  `try guardian?(db)` FIRST inside their own `database.write` — so a composition-guard throw rolls
  back the whole act including the guardian's (played sync apply's) write, on every path the fix
  routes through.
- **Only the MCP wrappers changed:** grep over `Sources/` + `App/` — `divideBlock`/`mergeBlocks`
  (the Operations extensions) are called ONLY from `MCPWriteTools+Edit.swift`; the app's
  `EditorViewModel.mergeBlocks()` is the view-model gesture routing to her doors
  (divide/divideW/merge/mergeCeremony, nil guards), byte-untouched in this range.
- **Suites, my own runs:** `MCPEditActsTests` 14/14 · `MCPEditServerTests` +
  `MCPWriteServerTests` + `MCPReadCarriageTests` 22/3 · **the whole headless package: core
  2,564/294 · VariorumMCPTests 45/6 · workbook 40/6**, all green, only the long-standing gated
  skips (skip lines read, not inferred); no VX-132 hang this run. **Mac focused suites under a
  HELD stage claim** (claimed `fable-reviewer-u3r2`, released after): `MCPEditFacesTests` +
  `MCPAskAndReceiptTests` + `MCPPaneTests` **23/3, 0 skipped** — matching the F4 fix record (the
  fix pass touched Mac files, so round 2 owed this run per round 1's note).
- **Hygiene:** zero `Sync/`/`Server/`/custody/editor-seam/migration/lockstep files in the range;
  zero attribution trailers on all five commits; branch in sync with origin.

## The round-1 look-first list, each item traced

(1) **F2's guards — any window case still mis-shapable?** Worked the premise set systematically.
Divide: the guard pins fan ids, fan order (array equality over the deterministic sort), every
take's text (parked cuts are positional), the shown take still this block's RENDERED take, and its
text still `expectedText` — so text growth/shrink on any take, archive/arrival (membership),
chosen-variant flips, and fan reorders all refuse; a seal, a cut's validity, and adjacency remain
the ops' own in-transaction refusals; the note's fence/placement is `guardEdit`'s in-transaction
re-decision (runs first, wrapped). A `locked` flip in the window passes the guard — correct: lock
guards the BUFFER, and divideW/merge mint fresh rows and preserve sources whole, never rewriting a
locked buffer (her own doors have identical semantics). The two PRE-transaction reads
(`mcpShownTake` in the wire, then the op's own fan read) cannot disagree past the guard: a change
between them fails either the `expectedText` check or the rendered-id check. Merge: membership +
both rendered ids pinned; texts deliberately unchecked because `merge`/`mergeCeremony` read texts
inside the same transaction and the composition is id-based — a text change in the window merges
the CURRENT text, which is her ⌘⇧M's own semantics (the tool takes no expected_text). **No
mis-shapable window case found.** The `try? renderedVariant` nil-handling is RIGHT and load-bearing,
not just honest: for a block tombstoned ALONE in the window (its variants' cascade rows not yet
applied — row sync applies out of order), `liveActiveFan` still returns the stale-matching fan, and
the nil rendered read is what refuses; the refusal copy (`OpsRefusalTable.swift:272-274`) never
surfaces the id, so the `leadingShown ?? firstBlockID` payload (a block id in the variantID slot,
the pre-existing compose-failure idiom reused) is internal-only — no client-visible artifact.
(2) **The pin's three legs isolate the interleave:** each guardian is the leg's only writer (raw
SQL inside the act's transaction); red-on-old 6 issues reproduced under my own hands with each
leg's mis-shape visible in the failure output; legs 1–2 assert the guardian's own write rolled
back; leg 3 does not (N-1 below) but the mechanism is proven by the guard-placement reading above.
(3) **The record edits:** P-13nb-U3-11's corrected clause matches `MCPNoteStructure.swift:189-197`
exactly (the first too-large unasked commit zeroes the budget — a contiguous newest-first prefix;
`asked` ids always ride and never touch the budget); the F3 constraint note is factually right —
`"length": text.count` at line 186 is computed on every row INCLUDING omitted ones, so the
Characters-unit `length` field genuinely forces today's full fetch; the mandate-decisions
amendment describes the shipped guard accurately, with the correction marked honestly in place.
(4) **F4's words:** the four creation lines speak counts plainly and never one creation's title
across a run; `create_section`'s `at` IS the book so it keeps its place; `add_note_to_book`
coalesces on the NOTE's id (read at `MCPWriteTools.swift:347-355`), so no F4-class residue hides
there; all-lowercase sentence case; the mockup §2 idiom ("added 3 takes to …") untouched; the face
pin extended with the justified-edit annotation and running green in my Mac run.

## Findings

### N-1 — [NIT, test completeness + a record sentence's precision] · `Tests/VariorumCoreTests/MCPEditActsTests.swift` (leg 3 of `aCompositionStaleAtTheActRefusesInsteadOfMisShaping`) · leg 3 never asserts the guardian's own write rolled back; the sanity-pass sentence "the three-leg pin asserts whole rollbacks including the guardian's own write" is exact for legs 1–2 only

**Evidence (traced):** leg 1 asserts the bystander's text back to "short" and leg 2 asserts
`sync-arrived-take`'s divide-twin count 0, but leg 3 asserts only nothing-merged + depth 0 — the
`'sync-arrived-take'` row's rollback is unasserted. Today the behaviour is correct (merge's guard
runs inside its own transaction, read by me at `Operations+Structural.swift:909-910`/`1092-1093`),
so NO red-on-old pin exists for this — it is hardening, not a bug: if a future refactor ever moved
merge's guard outside its transaction, leg 3 would stay green while the played sync-apply write
persisted; one `COUNT(*) WHERE id = 'sync-arrived-take'` == 0 line would make the leg
self-sufficient, as legs 1–2 already are. **No fix made this round** (round 2 is a re-review; the
line is one assert whenever the suite is next touched). Record-only; earns no round 3.

## Clean bill (load-bearing things specifically checked and found solid)

- **F2's fix is the disposition built exactly, and the window is closed:** every direction round 1
  traced — the bystander mid-split (i), the shrink refusal (ii), the arrival left-on-A (iii), the
  single-take wrong-rendered cut (iv) — now lands as ONE honest `bufferChangedSinceGesture`; the
  plain merge road guarded too (an arrived take refuses instead of silent stranding); the
  empty-side pass-through keeps the op's own typed refusal speaking. Red-on-old re-verified by my
  own revert run (6 issues, matching); green on HEAD; tree clean after.
- **No over-refusal on the happy path:** the guard's premises are exactly the composition's inputs;
  nothing else (labels, lock flips, default-variant changes behind a live chosen) refuses; her
  doors never route through these wrappers (grep-verified), so her divide/merge behaviour is
  byte-untouched.
- **The refused act registers nothing and spends nothing:** the guard throws before `register`
  (depth-0 pinned in all three legs), and the edit acts' `spendsAfter: false` snapshot means a
  refusal never spends the once grant (unchanged, re-read at the wire).
- **F1's corrected record now matches code, pin, and catalog three ways** (prefix stop; omitted
  texts reachable by `commit_ids`; the correction marked in place, not silently rewritten).
- **F3's constraint note is factually load-bearing** (the omitted rows' Characters-unit `length`
  is what forces the full fetch — verified at the line).
- **F4's copy is scoped right and pinned** (coalesced creations speak counts plainly; the one
  neighbouring act that coalesces across a place, `add_note_to_book`, keys on the note and has no
  residue; 23/3 Mac run 0-skipped under my own held claim).
- **The counts reproduce on the final tree:** core 2,564/294 · VariorumMCPTests 45/6 · workbook
  40/6 headless (my own run, gated skips only, no VX-132 hang observed) + Mac focused 23/3.
- **Hygiene held:** six files only; zero `Sync/`/`Server/`/custody/editor-seam/migration/lockstep
  lines; zero trailers; the stage claimed and released around the one Mac run.

**VERDICT: 0 BLOCKER · 0 MAJOR · 0 MINOR · 1 NIT (N-1, record-only hardening note). No new
BLOCKER or MAJOR — per the round-2 rule, THIS LADDER CLOSES.** The round-1 fix set is the
dispositions built exactly: the composition guard closes F2's window whole (re-verified red-on-old
under my own hands), the records now tell the truth the code and pins tell, and the activity face
speaks counts honestly.
