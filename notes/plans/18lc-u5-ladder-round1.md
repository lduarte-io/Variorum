# 18l-c U5 (base + #154 rider) — Fable cold review, ladder round 1 (2026-09-28)

**Reviewer:** `fable-reviewer` (cold, zero implementation context; `notes/REVIEW_PROMPT.md` run
verbatim). **Diff under review:** `5a54c148..6b7170d4` — the ONE ladder over U5 base + rider (the
plan's ledger rows 1/1b). Code = 11 production files under `App/`, 3 test files, 3 harness files
(1,296 insertions / 94 deletions by `git diff --stat`); zero `Sources/`, zero `Sync/`, zero schema,
zero mobile files (the one `Shared/` file, `FlowParagraph.swift`, is a defaulted-parameter change —
verified below). **Anchor docs read whole in this session:** the 18l-c plan file (her kickoff
verbatim, the architecture answer, both U5 briefs, the U5 RECORD + RIDER + both orchestrator
acceptances), `TEXTKIT2_NOTES.md` whole, KnownIssues rows 89/90/95/96/99, QUESTIONS #153/#154,
the master plan row 18, and the code itself end to end: `IndexProseColumn` (whole),
`ProseLineMetrics`, `FlowParagraph` (whole), `FlowParagraphFace.drawnText`, `ReadTierClickPlace`
(whole), `ProseHeightModel` (whole), `PaneSurface` (`makeNSView`/`updateNSView`/the re-font gate/
`proseTrailingInset`/`proseBottomInset` + `EditorDocument.baseParagraphStyle`/`baseAttributes`),
both hosts (`BookIndexPaneNote`, `ReadEditBlock`), both height models, `VisualWalkProbe`, the three
test files, `scenarios.zsh` + `read-tier-assertions.zsh` + the README.

**No "Review foci" section exists** in the plan or a brief file; the two briefs' named checks
(trace both shapes · consolidation scope · U0 pins ride · red-on-old by revert · the harness flip ·
the height-model consumers · the no-op proof) were each verified and stand in the clean bill.

**Verification runs made by this reviewer** (machine author-free — HID idle 785 s, zero app
instances by pgrep; no GUI driven beyond the suites' own windows):
- `IndexProseColumnTests` + `PaneLineMetricsScopeTests` run first-hand: **12 tests / 2 suites
  PASSED** on the shipped tree — including both source-walk scope pins (exactly two `lineMetrics:`
  callers; exactly five readers of `IndexProseColumn.blankLines`; no hand-passed `.shown`; the
  phone never names the rule) and the height-model arithmetic pin.
- `IndexTierMetricsTests` (the real-click pin) run first-hand: **green with EXACTLY the 4 named
  known-issue cases** — `.overTwoBlankLines` × both hosts, −10.0 pt Terminal / −20.0 pt Study —
  byte-matching the record, the KnownIssues row and TEXTKIT2_NOTES §3's new line; every other case
  0.0. The residual reproduces today and `isIntermittent: false` means a TK2 fix reds loudly.
- Evidence logs read from disk, not trusted from the record: `18lc-u5-pin-red.log` (**104 issues /
  12 cases** on the pre-fix tree), `18lc-u5-pin-green1.log` (12/12 pass), `18lc-u5-R{1,2,3}.log`
  (**80 / 24 / 12** issues — each revert red in its predicted shape), `18lc-u5r-pin-red.log`
  (**26 issues** on the base-without-rider tree), `18lc-u5r-R{1,2,3}.log` (**49+4 / 51+4 / 3+4**),
  `18lc-u5r-closing1.log` (`Test run with 345 tests in 51 suites passed`, 4 known issues = the TK2
  residual's four, 0 skipped, `** TEST SUCCEEDED **`), `18lc-u5r-ios.log` (BUILD SUCCEEDED),
  `18lc-u5r-mobile.log` (`MobileReadTests` **7/7 passed, unmodified**).
- Mechanism checks made by hand: no TK1 API anywhere in the diff (grep for bare `layoutManager` —
  clean); all ten `FlowParagraph.paragraphs*` call sites enumerated (only the two hosts + the
  replica pass the rule; Library panel, Read page, the flow, `MobileReadPage` keep `.folded`);
  `vw_top_of`'s missing-value "-" fails `vw_expect_near` rather than reading 0 (lib.zsh:426–431).
- Commit hygiene: 21 commits `5a54c148..HEAD`, **zero trailers**, tree clean, `main` ==
  `origin/main` at `6b7170d4`.

---

## FINDINGS (severity-ranked; format: [severity] · where · what · evidence · fix)

**F1 · MINOR · `App/Variorum/VariorumTests/IndexClickCaretTests.swift:493` (and the twin naming
slip at `IndexTierMetricsTests.swift:441/443`) · the U0 pin's Read ▸ edit column keeps a hand-copied
FOOT — the drift-seam class this very unit exists to close, left standing inside the pin family.**
The Read ▸ edit host now pads its read tier's bottom with
`IndexProseColumn.readTierBottom(resting:paneInset:)` (`ReadEditPane.swift:252–255`, applied at
:367/:390), and the new pin computes its column through that same function
(`IndexTierMetricsTests.swift:442–443`) — but `IndexClickCaretTests.swift:493` still computes the
same column as `row.height - top - IndexProseColumn.readEditRestingTop`, a hand copy of the OLD
arithmetic. Today the two are numerically identical (`readTierBottom(6, 6) = max(6,6) = 6 =
readEditRestingTop`), so **no red-on-old pin is possible — green on both sides on today's values;
this is a cleanliness/hazard finding by the prompt's own classification, not a bug**, and I say so.
Traced degradation (the written justification a non-pin finding owes): if `readEditRestingTop` ever
drops below the pane's 6-pt bottom inset, the product's tier pads `max(resting, 6)` while this copy
subtracts `resting` — the U0 pin's click target mis-frames by the difference and the suite's
last-line click aims into the blank run while the product is correct, i.e. the pin decays silently
in exactly the "two copies of one number" way the U5 header names as the whackamole cause. Beside
it, `IndexTierMetricsTests.swift:441/443` passes `paneInset: PaneTextView.proseTopInset` where the
semantic name for the bottom edge is `proseBottomInset` (same constant by definition,
`PaneSurface.swift:877` — value-identical, name-misleading). Fix: one line each — read
`readTierBottom(resting: IndexProseColumn.readEditRestingTop, paneInset:
PaneTextView.proseBottomInset)` at IndexClickCaretTests:493, and swap the two `proseTopInset`
spellings at IndexTierMetricsTests:441/443 to their edge's names.

**F2 · NIT · `App/Variorum/VariorumTests/IndexTierMetricsTests.swift:242–247` · a garbled, doubled
comment left by the rider re-arm.** The block reads "*…the paragraph // gap it follows, then one
line of the voice) — REPORTED, since the // rider's (b) it is no longer an allowance…*" immediately
followed by the stale pre-rider duplicate "*// gap it follows, then one line of the voice (the
replica's own // one-line height).*" — the first sentence closes a parenthesis it never opened and
the second is the base-era clause the re-arm superseded. Comment-only; the code beneath (`blankLine`
feeds the trace print only) is correct. Fix: delete lines 246–247 and mend the first sentence.

**F3 · NIT · `App/Variorum/Variorum/Surface/ProseHeightModel.swift:105–107` + the RIDER's HONEST
BOUNDARY 3 · the boundary sentence under-describes the estimate's ≥2-trailing-blanks direction.**
`shownBlankLines` caps at ONE for any newline count, so under `.shown` a block stored over N ≥ 2
trailing blanks reserves N−1 drawn lines short (~30 pt each), and a no-trailing-newline
multi-paragraph block ("A\nB") reserves ~one line long (the newline is modelled as the blank instead
of the break — net ≈ +half a line, which IS the boundary's stated case). The record's boundary
names only the half-line case; the ≥2-blanks under-count is undocumented there (though the shape has
**zero instances in the sample library** — the rider measured all twelve stories — and the model's
own contract heals it: "a measured row replaces the estimate as soon as it draws"). **No pin could
hold a number the code declares an estimate — hollow as a bug and labelled so; recorded for the
boundary's completeness only.** Fix (doc-only, either home): one clause in the RIDER boundary or the
`shownBlankLines` doc naming the ≥2-trailing under-count beside the half-line case.

No BLOCKER. No MAJOR. I traced no wrong behavior anywhere in the diff.

---

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **The consolidation is real, not narrated.** ONE home (`IndexProseColumn.lines` / `.blankLines` /
   the six edge functions) consumed by both read tiers, the click replica, both host height models
   and the live pane — verified by my own grep of every consumer AND the two source-walk pins run
   first-hand. `BookIndexPaneHeights.paragraphLineSpacing` is now a read of the home (the third copy
   of the 4 is gone).
2. **The pane's style adoption is sound end to end.** `ProseLineMetrics.paragraphStyle` sets exactly
   {lineSpacing, paragraphSpacing}; `EditorDocument.baseParagraphStyle` sets ONLY paragraphSpacing
   (read at `EditorDocument.swift:42–50`), so no style property is silently dropped for index-hosted
   panes. `makeNSView` writes the host style + typing attributes BEFORE `view.string = text`
   (`PaneSurface.swift:1229–1232` vs :1271), so the installed text carries it; the read-pane
   re-adopt road (:1380) inherits the same typing attributes; the re-font gate compares against the
   pane's OWN intended style and for every nil-metrics host both sides read lineSpacing 0 — the
   byte-same decision as before U5 (:1318–1325). The `gap − lineSpacing` TK2 mapping is measured in
   both voices and pinned as a §5 tripwire (`theVocabularysStyleDrawsTheReadTiersSpacing`).
3. **Scope holds, three ways.** Exactly two `lineMetrics:` callers; exactly five
   `IndexProseColumn.blankLines` readers; no hand-passed `.shown`; the phone never names the rule
   and `MobileReadTests` rides 7/7 unmodified; every other `FlowParagraph` caller keeps `.folded`
   (all ten call sites enumerated). Her ratification's "Write and Takes untouched" is pinned, and
   `ParagraphGap`/inline-comments no longer reaching an INDEX-hosted pane is her ratified goal,
   recorded reversible (judgment call 3).
4. **The blank-rule mechanics are coherent.** `.shown` keeps every rendered display line;
   `drawnText` draws a blank as one space (one line tall — an empty `Text` stands at no height);
   the replica lays a blank as that space, contributes no TEXT line, and maps a blank-line click to
   the stored end (`sourceOffset` → `MarkdownRendering.sourceOffset`), pinned by
   `expectCaretOnTheBlankLine` on both hosts; whitespace-only lines draw as their spaces on both
   tiers alike (display == stored, the ruling's letter — boundary 4).
5. **The height-model arithmetic checks out by hand.** The blanks term adds exactly
   `linePitch − lineSpacing + paragraphGap` per flagged block = lineHeight + gap = the drawn
   +25/+30; `.folded` callers are byte-unchanged (blanks = 0, the formula reduces to the old one);
   the two index builders set `.shown`, the Outline/flow/page keep `.folded` — pinned, and
   R-U5r-3's red (U1's Sherlock calibration at 0.75/0.76 out of band) proves the term is
   load-bearing, not decorative.
6. **Red-on-old is real, six ways.** Both pin reds (104 base, 26 rider) and all six behavioural
   reverts read from disk in their predicted shapes; the harness's three new block-below rows red
   +25.0 on a rider-reverted scratch build; the closing run 345/51 green with exactly the 4 named
   known issues; and my own re-run of the pin reproduces the residual at −10.0/−20.0 today.
7. **TK2 discipline held.** No TK1 API in the diff; the replica and pins are
   `NSTextContentStorage`/`NSTextLayoutManager`; the host style is an ordinary string attribute
   (no rendering attributes; the §3 clamp rule is about identity stamps and none moved —
   `BlockRangeIndex`, `EditorTextView`, `PanePublisher`, `PaneMeasurement`, the landing/liveness/
   caret machinery are not in the diff); TEXTKIT2_NOTES §3 carries both new measured lines with the
   27.1 re-measure note.
8. **The U0 pins ride honestly.** `IndexClickCaretTests`' assertions are byte-unchanged — only the
   click point steps over the blank run the tier now draws, which is the RIGHT re-arm (the old
   point would land on the now-drawn blank line, and a click there landing ON it is the new truth,
   pinned separately); `IndexLandingCaretTests` untouched.
9. **The bleed is safe.** Only the LIVE pane's frame extends past its row (−5/−1 pt trailing,
   `livePaneTrailing` = resting − inset), the prose ends at the tier's measure
   (`bothTiersEndTheProseAtTheSameColumnAndFoot` proves resting == live + inset for the whole inset
   range), the read tier's paddings are unchanged, her look-change ratification covers the ring/wash
   widening, and the only hit-target consequence is a 5-pt strip of the live pane's own row catching
   clicks into that same live pane — no harm mechanism.
10. **The harness additions have teeth and guards.** Frames carry block ids (fifth field), the
    block-below rows re-find by id, `blankH` comes from the vocabulary, the fixture's shape is a
    checked precondition (`nl == 1`), a missing frame fails rather than reading 0, and the headless
    pin now REDS a risen line (the S3 label retired everywhere — README, scenarios, pins,
    consistent).
11. **P1/product law.** Every new cost is bounded by the clicked block or the viewport (one
    off-screen block layout per click; the taller resting index rides the lazy column; the height
    models stay SQL length extents). Nothing tracks word-level change; no text copies across
    entities; no schema, no `Sync/`, no defaults' meaning changed — the one setting-like surface
    (`IndexProseColumn.blankLines`) is a compile-time host rule, not a stored default.
12. **Canon and process wiring.** KnownIssues row 89 CLOSED ladder-gated with an explicit re-open
    clause; the ≥2-blanks TK2 exception filed as its own row (owner 12, 27.1 re-measure); row 99
    carries sightings 4–5 + the late-landing mutation fact; QUESTIONS #154 RULED (b) → BUILT with
    the residual named; #153 (a′) correctly fenced OUT of this diff and still owed at ledger row 8
    (the phase is open — tracked, not dropped); master plan row 18 current; no trailers; pushed.

**Round-1 verdict: three findings (1 MINOR, 2 NIT — none bug-class, each honestly labelled
un-pinnable per the hallucination guard), no BLOCKER/MAJOR. The fix, the rider, the pins and the
evidence are solid; per the ladder this round's findings go to the implementer verbatim, its
agree/dispute returns to this reviewer for the final call and the fixes.**
