# 18l U0 — COLD REVIEW, ladder round 1 (Fable, 2026-09-26)

**Reviewer:** `fable-reviewer` (Fable 5, xhigh), zero implementation context, running
`notes/REVIEW_PROMPT.md` verbatim. **Diff under review:** `06fe339d..3fd62455`, code =
`App/`, `Sources/`, `Tests/` (12 files, +1372/−53). **Anchors read in full, myself:**
the phase plan (`phase-18l-navigation-feel.md`, whole, U0 RECORD included), the charter
(`post-13u-health-rounds.md` KICKOFF 2 / U0), `TEXTKIT2_NOTES.md` whole, KnownIssues rows
69/75/85/86/87/88/89/92, the canon (CLAUDE.md auto-set), and every touched file end to end
plus its surrounding unchanged code (`ReadTierClickPlace.swift`, `MarkdownRendering.swift`,
`FlowParagraph.swift`, `BookIndexView.swift` §blockView + geometry oracle,
`BookIndexEditModel.swift`, `ReadEditPane.swift`, `BlockTOCView.swift` §makeLive/arm,
`EditorView.swift` §InlineEditorSurface whole, `EditorTextView.swift` §setFrameSize/doors,
`PaneSurface.swift` §PaneMeasurement + PaneCaretLanding + the going-live consumption,
`EditorTypography.swift`, `VoiceTokens.swift`, all four test files). No `Sync/`, no schema,
no `Server/` in the diff — confirmed by stat; `EditorTextView`, `BlockRangeIndex`,
`PaneTextAuthority`, `PaneSurface`/`PaneMeasurement` bodies untouched — confirmed against
the seam table's claims by reading the diff, not the table.

**Verification runs made by this review (targeted, per the prompt's rule):**
- `swift test --filter MarkdownRenderingSourceOffsetTests` → 6/1 passed.
- `swift test --filter MarkdownRenderingTests` → 11/1 passed (the "11 render pins ride
  unmodified" claim — the suite is byte-untouched in the range and green).
- `xcodebuild test -only-testing` the three touched Mac suites
  (`IndexClickCaretTests`, `InlineEditorWidthReflowTests`, `InlineHeightReportTests`)
  → **8 tests / 3 suites passed** on this tree (the settle pin's own log shows 2 reports
  per width step — inside the adapted arm's 1...3 — and the 520-pt step reproduces the
  recorded layout-history fact: settled 14718 vs fresh-view 14380).
- Full core `swift test` at review end → **1729 tests / 181 suites passed** — exactly the
  record's number.
- The closing-run log exists and carries the recorded line
  (`App/Variorum/DerivedData/18l-u0-closing1.log`: "341 tests in 59 suites passed");
  the walk captures exist under `notes/plans/18l-screens/u0/` (gitignored, as ruled).
- Commit-trailer check over the range: clean (no `Co-Authored-By`/`Claude-Session`).
- No "Review foci" section exists in the plan or charter (checked; none owed).

---

## FINDINGS (severity-ranked)

### MINOR-1 · `Sources/VariorumCore/Domain/MarkdownRendering.swift:7–14` vs `:175–190` — the ruled SURFACE RULE's restatement is now contradicted by the file's own new function

**What's wrong:** the file-header restatement of the 13g surface rule (F-5 + her
clarifying question) still reads: *"EDITING surfaces — and the read-cheap tier, whose
click seeds a caret offset — render the DIMMED-MARKER face (`MarkdownStyling`), where
display == stored byte for byte and no offset ever needs translating. READ-ONLY surfaces
with NO editing gestures may render FULLY FORMATTED, markers hidden: display ≠ stored is
safe exactly where no gesture maps a click to a text offset."* After this diff, the two
`Text` read tiers (book Index, Read ▸ edit) render FULLY FORMATTED **and** their clicks
seed caret offsets — the exact combination the rule's letter forbids. The new
`sourceOffset(forDisplayOffset:in:)` doc glosses this as *"exactly the case the surface
rule above names as needing a translation"* — but the rule names no translation; it names
the dimmed face as the way the case never arises. **Evidence (traced):** the header is
byte-identical at `06fe339d` (unedited by this diff — verified by `git show`);
`BookIndexPaneNote.blockView` (BookIndexView.swift:1427–1476) and `ReadEditBlock`
(ReadEditPane.swift:219–263) draw `FlowParagraph.paragraphs(of:)` — the markers-hidden
face — and now hand `ReadTierClickTarget`'s stored-text offset to the pane's
`caretOnGoingLive`. So the same file now gives a reader two contradictory rules about
which face an offset-seeding tier must render — on a RULED rule, which is exactly how the
next read surface gets built wrong. The **behavior** is right (her 2026-09-25 report and
the U0 charter rule it; the translation is pure, read off `render`'s own walk, and pinned
at every layer), so this is doc/architecture-clarity drift, not a bug — no pin applies.
**Fix:** rewrite the header's surface-rule paragraph to record the 18l U0 carve-out — a
formatted read-cheap tier's click is legal exactly when it routes through
`sourceOffset(forDisplayOffset:in:)` (the pinned translation), with a pointer to the U0
record — and drop the "names as needing a translation" gloss from the new function's doc
(say instead that it EXTENDS the rule for the tier flavor whose display cannot equal the
stored text). The orchestrator should also decide whether the archive's surface-rule entry
wants the same one-line delta recorded (canon hygiene; her ruled behavior is not in
question).

### MINOR-2 · `App/Variorum/Variorum/Surface/ReadTierClickPlace.swift:79–81` + `App/Variorum/Shared/FlowParagraph.swift:97–101` — three renders of the block per click; two entry points that must stay in lockstep

**What's risky:** `sourceOffset(at:...)` calls `FlowParagraph.paragraphs(of:)` (one full
`MarkdownRendering.render`), then `FlowParagraph.displayStarts(of:)` (a second full
render), and finally `MarkdownRendering.sourceOffset(...)` (a third tokenizer scan +
walk). All three are bounded by the clicked block and run at click rate, so P1 is clean —
this is efficiency/cleanliness, not a bug. The sharper edge is the coupling:
`paragraphs(of:)` and `displayStarts(of:)` are two public entry points whose agreement
about WHICH lines are paragraphs rests on the shared private `isShown` — today guaranteed,
but a future filter added to one and not the other silently mis-maps every click by one
paragraph. **Evidence:** the guard `paragraphs.count == starts.count` at
ReadTierClickPlace.swift:81 returns offset 0 (block start) on divergence — a silent
degrade, not a crash. **Fix (optional, cleanliness):** one API returning the paragraphs
WITH their display starts (e.g. `FlowParagraph.paragraphsWithStarts(of:)` built from one
render), which removes both the duplicate render and the lockstep obligation. No pin
possible today (no divergence exists) — labeled honestly: not a bug-class finding.

### NIT-1 · `ReadTierClickPlace.swift:170–179` + `App/Variorum/Shared/Theme/VoiceTokens.swift:366` — Study's tier font is Dynamic-Type-relative; the replica's NSFont is fixed

Study's read tier draws `Font.custom("Iowan Old Style", size: 16, relativeTo: .body)`
(scales with the system text size) while the replica measures with the fixed
`EditorTypography.current.font` (16 pt). On a machine with a non-default system text size
the two layouts drift and clicks land lines off. **SPECULATIVE on this machine** (dev =
acceptance, default size — the two faces agree, so no red-on-old pin can exist here), and
the replica-fidelity pin (`IndexClickCaretTests`, ±0.5 pt both voices) is a live tripwire
that would go red on such a system. **Fix:** one line in the file's "known approximation"
paragraph naming the Dynamic Type assumption, or drop `relativeTo:` from the tier fonts if
fixed metrics are the intent (a look decision — the author's, if ever).

### NIT-2 · `App/Variorum/VariorumTests/IndexClickCaretTests.swift:461–463` — the Read ▸ edit pin hardcodes the column's horizontal insets

The case derives the text column as `row.minX + 11` / `width − 21` where the production
inset is the computed `ReadEditBlock.readTierLeading` (the vertical inset two lines above
IS computed properly via `IndexProseColumn.readTierTop`). If `readTierLeading` ever moves,
the pin clicks slightly off-column while production stays right — test fidelity only, and
the first-line ±1-character arm would likely catch a real drift. **Fix:** use the computed
constants for x exactly as the y already does.

---

## DISPOSITIONS OF THE RECORD'S OWN FLAGS (the reviewer's calls)

- **The adapted C2 pin** (`anUpdatePassReportsOnTheTurnAfterItNeverInsideIt`, count arm
  `== 1` → `(1...3)`) — **ACCEPTED.** The loosening is bounded and keeps its teeth: (a)
  the kept first-report arm (narrow side of the midpoint) still catches the stranded-wide
  class the pin was born for; (b) the NEW last-report-equals-settled arm is red-on-old at
  631 pt (the recorded revert); (c) my re-run shows exactly 2 reports per width step, well
  inside the bound. The pin's own prior note had recorded the 631-pt gap as "not an
  equality" — the adaptation closes that recorded hole rather than papering over a
  failure.
- **The settle net's budget (8 per occasion, re-armed by width/mount/storage-edit only)**
  — **ACCEPTED as designed.** The un-re-armed axis (a pure scroll-driven TK2 re-layout
  burning all 8 with no width change or edit, then a ninth genuine settle going
  unreported) is theoretical: each settle report runs `PaneMeasurement`'s full
  `.ensuresLayout`, which converges the layout it just measured, and the next edit or
  width change re-arms. A pin for that shape would need TK2 to produce nine spontaneous
  settles between occasions — not stably constructible; flagging it as a bug would be
  hollow. The bound is the anti-spin protection and is documented in code and record.
- **The two compositions assume `attach` runs before `install`** (record's NOTICED 4) —
  **ACCEPTED.** True in `makeNSView` (the only road: EditorView.swift:563→569); a future
  re-attach of the same textView would silently drop the coordinator's two doors — the
  in-code comment names the assumption, which is the right cost for a road that does not
  exist.

## CLEAN BILL (load-bearing things specifically checked and found solid)

1. **`MarkdownRendering.sourceOffset(forDisplayOffset:in:)` traced end to end** against
   `renderLine`'s `landed` table (which PRE-EXISTS this diff — verified at `06fe339d`; the
   diff only stops discarding it, so `render` gained zero cost): the last-boundary-≤ rule
   gives `**bold**` display 0 → source 2, boundary walks are per-grapheme (`offsets`
   accumulates per Character — no surrogate split possible), a bullet's substituted lead
   maps display 0/1 → line start and display 2 → after `- `, blank lines answer their own
   start, a multi-unit terminator clamps to its line's end, past-the-end answers the
   text's end, and the early-stop `guard target < next || terminator == nil` hands every
   non-last line through correctly. The 6 new core pins cover each shape class; the walk
   factoring is byte-equivalent to the old loop (same span slicing, same terminator
   append; `theSharedWalkStillTilesTheDisplay` + the 11 untouched render pins hold it).
2. **The replica's geometry contract**: `ReadTierClickPlace` shares its two metrics with
   both tiers as single named constants (drift now impossible by construction), subtracts
   the per-paragraph list indent from both x and width exactly as the tiers pad it, maps
   the inter-paragraph gap by nearest-half, clamps y into the paragraph, and its height
   agreement with what SwiftUI actually drew is PINNED (±0.5 pt, both voices) rather than
   assumed — the right epistemics for a second layout. The host insets passed to
   `ReadTierClickTarget` match the tier paddings byte-for-byte on both hosts (checked
   against BookIndexView:1454–1470 and ReadEditPane:239–263). Terminal/Study body fonts:
   `tokens.body` and `EditorDocument.baseFont` resolve to the same faces and sizes (14 pt
   system-mono / 16 pt Iowan) — one source per voice (NIT-1's Dynamic Type caveat aside).
3. **The caret-landing arm**: armed per `makeLive`, reset on every subsequent `makeLive`
   (nil `clickOffset` clears it via `.map`), consumed only on the read→live transition
   (`guard live, !was`), `.offset` clamped at application
   (`min(max(0, landing), length)` — PaneSurface.swift:1466 — so a stale offset can never
   throw), and `.leave` byte-preserved for every landing road (S4's `requestLanding`
   stays END — correctly OWNED to U4, ledger row 11). The only replay road (a live pane's
   view recreation) lands the old click's offset where the shipped code landed the END —
   the same artifact class, no regression. The Read ▸ edit override order (entry rule
   armed first, click offset over it) is right, and "a click outranks the entry rule"
   matches `PaneCaretLanding`'s own ruled doc (17o R1-2/R1-3: a click keeps the place it
   brought) — now made true for the `Text` tier flavor too.
4. **The width door**: `onWidthReflow` fires from `setFrameSize` only on a real width
   change (both `applyFrameHeight` branches guard on `widthChanged`), the composed closure
   preserves the model's overlay handler, a height-only reframe cannot re-enter it, and
   the report hop coalesces per turn (newest-wins generation untouched). Termination
   argument verified: a report changes only the frame's height; the door needs a width
   change. The fix lives in the inline coordinator with `PaneMeasurement`'s fence intact.
5. **The settle net**: O(1) per display pass (one reverse fragment read, no
   `ensureLayout`), edge-triggered on a MOVED bottom (a stable disagreement between the
   last-fragment read and the full measure returns at the first guard — no spin), its
   height formula matches `PaneMeasurement.height`'s (`maxY + textContainerInset.height ×
   2`, symmetric inset at `makeInlineEditor`; the max-fragment vs last-fragment difference
   cannot oscillate because it only ever fires on movement), the empty document falls out
   at `bottom == nil` (no fragment ⇒ nothing to heal — `PaneMeasurement`'s fallback owns
   that shape), and `remeasure` records every report so the comparison base is the real
   last report, binding-gate (0.5 pt) aligned on both sides. P1: the per-report cost is
   the pre-existing whole-post `ensureLayout` class already measured and documented in
   `PaneMeasurement`'s doc — no new scaling class.
6. **Red-on-old and revert hygiene**: pin commits precede fix commits for all three
   mechanisms (`51824a08`→`7553dd93`, `54fb5d47`/`f46ceac8`→`0d9ac91d`,
   `08aa8d0c`→`8b86232a`); the behavioural-revert commits record the red counts
   (`653877ce` R-U0-1 26; `5004003c` R-U0-2; `17e07015` R-U0-3 red 4 → green); the pins
   are REAL clicks through `NSApp.sendEvent` on real windows, both voices, on her note's
   shape (trailing-newline blocks + the no-newline last block), with the replica's
   fidelity arm and the pane's own hit-test as an independent ground truth on first lines.
   I re-ran all three suites green on this tree.
7. **Scope and fences**: zero `Sync/`, zero schema, zero triggers, zero operations-layer
   writes — the whole diff is read-side + caret placement + a height report; S1–S5
   untouched by construction. No TK1 API anywhere in the diff (the replica is
   `NSTextContentStorage`+`NSTextLayoutManager`; the net reads
   `enumerateTextLayoutFragments` — TEXTKIT2 §4.2 honored). DEBUG oracles stay
   DEBUG-gated. `FlowParagraph.displayStarts` is pure and cross-platform (mobile compiles;
   no phone caller). Process-global typography saved/restored in both new suites (the S5
   harness class deliberately not inherited). The `.gitignore` addition is the ruled
   screens folder.
8. **Record honesty**: the U0 RECORD's NOT-DONE list is accurate (U0b/U0c untouched, U3
   rider untouched — `PaneSurface` genuinely unmodified in the diff; row 85 untaken —
   nothing in the diff touches the ring's refresh); the sweep's attribution constraints
   (no old-tree harness bisect — the C7 dev-store trap) are stated rather than papered
   over; S3/S4/S5 are owned, not silently fixed; the item-1 attribution (pre-existing)
   is mechanism-consistent (a point-less tap + `.leave` cannot be a macOS delta) and its
   line-history evidence names commits outside the window. KnownIssues rows: 75 closed
   with pins named (verified the pins exist and are red-on-old per the revert commits);
   86 correctly still open pending this review; 88/89 filed with honest attributions.
   Closing-run numbers verified: core 1729/181 (re-run by me, exact), Mac 341/59 (the log
   line read), the three touched suites re-run green.

## VERDICT

No BLOCKER, no MAJOR. Two MINOR (both documentation/cleanliness — the ruled surface-rule
restatement now contradicted in-file, and the three-render/two-entry-point coupling), two
NIT. The three fixes are mechanically sound, correctly fenced, pinned red-on-old with
verified reverts, and match the charter's unit shape. Per the cross-model flow these
findings go to the implementer verbatim; MINOR-1's doc rewrite and any fixes I confirm
after its response are mine to implement in this session on the orchestrator's word.

---

## IMPLEMENTER RESPONSES (round 1)

*(`opus-implementer`, 2026-09-26. Each claim re-read at the code before answering; no fix
implemented — per the cross-model flow the reviewer makes the final call and implements.)*

### MINOR-1 — AGREE, with one addendum the fix's wording should carry

Verified: the header (`MarkdownRendering.swift:7–14`) is byte-unchanged by U0, and my
`sourceOffset` doc's "exactly the case the surface rule above names as needing a translation"
is wrong — the rule names no translation; it names the dimmed face as the way the case never
arises. The rewrite as proposed is right, and the gloss should go.

**Addendum — the drift is older than U0, and the rule is DESIGN LAW, not only a header.** The
binding text is the 13g plan's F-5 record (`notes/plans/phase-13g-formatting-lists-checkboxes.md`
~line 406: *"The surface rule her question pinned (record it as design law): EDITING surfaces
(and the read-cheap tier, whose click seeds a caret offset) render the dimmed-marker styled
face — display == stored, always."*). The two `Text` tiers in question already rendered the
FORMATTED face (`FlowParagraph`) with a click that made the block live from the Act 10
correction round (`c768c08e`, 2026-09-01) — after 13g — so the header's closing sentence ("this
is where the second face lives, and it lives NOWHERE else") was already stale before U0. U0 made
those clicks seed an offset (her report requires the click to land where she clicked), which is
where the letter of the law is now crossed. Two ways to square it, and they differ in what she
SEES, so I would not settle it by a doc edit alone:
- **(a)** the Index / Read ▸ edit read tiers render the DIMMED-MARKER face (display == stored;
  no translation needed; the law holds as written) — a visible look change on two surfaces;
- **(b)** keep the formatted face and record the carve-out: a formatted read-cheap tier may seed
  an offset ONLY through the pinned translation (`sourceOffset(forDisplayOffset:in:)`) — what U0
  built and what she sees today.

I recommend (b) as the PROVISIONAL reading under R-18l-4 (it preserves today's look and her
ruled click behaviour), with the header rewritten as proposed, the 13g plan's design-law entry
given the same one-line delta, and **a QUESTIONS row (a)/(b) for her morning bundle** — flagged
here, not filed by me (the orchestrator/reviewer's call where it lands).

### MINOR-2 — AGREE

Verified: one click runs `render` twice (`paragraphs(of:)`, then `displayStarts(of:)`) plus a
third tokenizer scan + walk in `sourceOffset`; the only thing keeping the two public entry points
agreeing is the shared private `isShown`, and a divergence degrades silently to offset 0 at the
`count ==` guard. A single `paragraphsWithStarts(of:)` built from one render removes both the
duplicate render and the lockstep obligation; `ReadTierClickPlace` is its only caller, so the
change is local. (If the reviewer wants it tighter still, that API could also hand back the one
`Rendered` so the display→source step reuses it — optional; the per-click cost is block-bounded
either way.) Correctly labelled not bug-class: no divergence exists today, no pin possible.

### NIT-1 — AGREE (the doc line, not the look change)

Verified: Study's tier fonts are `.custom("Iowan Old Style", size: 16, relativeTo: .body)`
(`VoiceTokens.swift:366–368`, `:403`), the replica measures the fixed
`EditorTypography.current.font`. At this machine's default size the two agree — the
replica-fidelity arm (±0.5 pt, both voices) measures it — and that arm is the tripwire if a
system text size ever makes them diverge. The one-line caveat in the file's "known
approximation" paragraph is the right fix; dropping `relativeTo:` is a look decision (hers), not
this unit's. Terminal's `.system(size: 14, design: .monospaced)` has no such term.

### NIT-2 — AGREE

Verified: `IndexClickCaretTests.swift:461–463` hardcodes `+ 11` / `− 21` (= today's
`readTierLeading` 11 + trailing `readEditResting` 10) while the y two lines above is derived.
Note for the fix: `ReadEditBlock` is `private`, so the pin must derive x the way y already is —
`IndexProseColumn.readTierLeading(resting: IndexProseColumn.readEditResting, paneInset:
PaneTextView.proseLeadingInset)` for the leading edge and `IndexProseColumn.readEditResting` for
the trailing.

**Summary: 4 AGREE, 0 DISPUTE.** One flag for the orchestrator: MINOR-1's rewrite amends a
RULED design law (13g F-5's surface rule) — recommend (b) PROVISIONAL + a QUESTIONS row (a)/(b)
for her morning bundle.
