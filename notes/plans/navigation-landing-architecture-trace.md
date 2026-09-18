# Navigation & Landing — the architectural trace (2026-09-18)

**What this is.** Her post-13u2 report, verbatim: *"there's still some issues with the navigation
to far chapters - I clicked a far away chapter, that was fine, then I clicked one that was much
higher and I watched it stutter ~10 times, every time I did it. I managed this by clicking on the
last chapter and then The Man with the Twisted... in sherlock."* And her mandate: *"I want you to
do an architectural trace / deepdive into the issue. I want to know how we've been solving it, if
there's different architecture that we need, or if this really is just a bug fix. I'm wary of the
whackamole issue - by my own rule, an issue that keeps coming up warrants deeper investigation."*
Secondary report, same message: switching tabs/modes lands the same text at different heights —
works, but unpolished; she pre-accepted "that's fine" if it is hard for visual-delta reasons.

Investigation only — no product code was changed. One session, dev-store Debug build
(`io.lduarte.Variorum.debug`, the 13u2-walk build at `348ef8aa`-adjacent), WalkKit + cliclick,
landing stories read from stderr. Her store and `/Applications/Variorum.app` untouched (her
instance, pid 21755 that night, was left alone). One dev-only state change, recorded: the Debug
domain's 263 `surfaceSize.*` keys were deleted to stage a cold-heights run; they regenerate on use.

---

## 1. The verdict, first

**This is NOT "just a bug fix," and it is also not a broken architecture — it is a missing
architectural piece, plus a compensator that has been re-implemented per surface.** Her
whack-a-mole instinct is correct and the file history proves it: this is at least the **eighth**
dated engagement with the same class (§2), each fix real, each narrowing the class, none removing
its cause.

The cause, stated once: **every long lazy column in the app discovers its row heights AFTER it has
aimed.** SwiftUI's lazy containers estimate unrealized rows (an average of realized ones — the
measured "card:heading scale mix", ±70 pt per pass, KnownIssues row 64); expanded stories load
their real heights asynchronously (a placeholder that grows by ~20,000 pt); and `scrollTo(id:)`
resolves an anchor against whatever the estimate says at that instant. So each surface grew a
**compensator** — aim, hold, watch the column, hop again — and there are now **four** hand-tuned
copies of that loop (§3). A hop IS a visible jump. **Her ~10 stutters are the compensator loop
running ~10 corrections against a column whose height truth keeps changing under it** — the exact
signature the suite already pins deterministically: the wrapped far-below arm oscillates, hops 13
times over 4.2 s, and gives up (13u2 UNIT A2, "THE GATE, MEASURED BOTH WAYS"). ~10 observed ≈ 13
hops; "every time" ≈ its 3/3 determinism.

The fix direction that follows from the trace (not from taste): **make heights KNOWN before the
aim** — a book-level height manifest (§5) so a landing computes its offset arithmetically and
scrolls ONCE — and **hoist the four compensators into one landing authority** kept only as the
safety net. This is AppSpec §4's own designed fallback ("drive the scrubber off stored per-block
length estimates, not live geometry") promoted from the scrubber to the landings, which is why it
needs no new canon.

## 2. How we have been solving it — the dated history, each fix's assumption, and what broke it

| date · owner | what was built | what it assumed | what broke the assumption next |
|---|---|---|---|
| 13f W21 (2026-08) | the flow's landing half (aim + report) | reports can drive corrections | reports arrive DURING content churn; corrections got undone by ScrollView's own offset restore (row 100's log: a RE-LAND's offset move is reverted by the next report) |
| Act 10 / R-cor-5..17 (2026-09-01) | `LandingTarget` — ONE scrolled-open door for Read→edit click-throughs (`Shared/LandingTarget.swift`) | unifying the AIM message suffices | the aim was never the hard half; the SETTLE after the aim is, and that stayed per-surface |
| 17o batch c (2026-09-08) | `PaneMeasurement` — `usageBoundsForTextContainer` is a ratchet; read fragment bottoms | pane heights were the lying reading | true for panes; the BOOK columns lie a different way (the lazy estimate) |
| 17p/17q (2026-09-12/13) | the Takes article memory + landing (R-Q20/R-Q21): absolute idempotent aim that HOLDS until her hand; the 24-aim budget with decay | a bounded re-aim loop converges | the 17q ladder found the restore had never run before 17q; residues remain (row 49: the non-scroll-hand hold, the decay shape, the page-tall straddler — owner 12) |
| 18d U-12 (2026-09-08) | `SurfaceSizeMemory` + `StableSurface` — remembered note lengths per (note × surface × WIDTH), refused at another width; `SideColumn` remembered widths | a note's settled size, once seen, is right from the first frame | exactly right — and it is why tonight's dev store converges; but it covers only EXPANDED stories, only at a width already seen, and nothing covers the estimate for unrealized rows |
| 13u2 row 53 / UNIT A (2026-09-15) | the Outline discipline: the REPORT never re-lands; the quiet interval decides; hold 1.0 s, quiet 0.25 s, ceiling 0.6 s, hop budget 40, watchdog 4 s (`BookView.swift` ~960–1162) | a well-tuned compensator can absorb the churn | it can — when the churn is bounded. The fixture's mixed-scale estimate OSCILLATES (±70 pt limit cycle), and the loop spends hops forever: 13 hops / 4.2 s / gave up |
| 13u2 UNIT A (same night) | row 100: the flow adopts the Outline discipline (`ReadingFlowView.swift`) — 6 re-lands → 0 | same | same residual class; the flow column is 306k pt, so the estimate error's absolute size is largest there |
| 13u2 UNIT A2 (same night) | **preview priming** (`Queries.leadingBlockTexts` + `BookViewModel.adopt`): a card's words in hand before its first frame — cards never change height again | the cards were the last mover above a target | the cards WERE fixed (re-verified tonight: not one `h=46` in any run). What remains is the ESTIMATE for unrealized rows — which priming made honestly mixed (103 vs 51) and therefore WORSE in the synthetic extreme: the wrapped arm's stable −73 pt, and the fixture's old green shown to have depended on the defect's timing |
| 13u2 UNIT E (same night) | the Takes structural arm (#113): any content change ends a pending landing by construction | — | closes the "who ends a landing" completeness argument for Takes; does nothing for the book columns |

Also in the family: row 58 (the book Index's landing is load-flaky in harness — the pane sometimes
never realizes; product road walked clean), row 48 (the shadow double realization), and the 1,989
`Modifying state during view update` warnings nobody has swept (the likeliest common root of the
harness races — owner 12). The 13l "TK2 hang" lead was traced at UNIT A and **TK2 was exonerated
by sample** (zero TK2 frames; the hang was one SwiftUI `GraphHost.flushTransactions` storm) — the
landing problem is a SwiftUI-lazy-layout problem, not a TextKit one.

**Count: 2026-08 → 2026-09-15, eight dated engagements, five surfaces touched, and the class is
still filing reports.** That is the whack-a-mole pattern her rule names, and it recurs because
each fix removed one HEIGHT LIAR (the cards, the flow's re-lands, the pane ratchet, the unremembered
stories) while the architecture kept the property that makes any remaining liar visible: the
landing aims before the heights are true.

## 3. The four compensators (what consolidation would collect)

1. **Book Outline** — `BookView.swift`: `landOutline` / `outlineAnchorMoved` /
   `outlineContentResized` / `checkLanding`; hold 1.0 s · quiet 0.25 s · ceiling 0.6 s · 40 hops ·
   4 s watchdog; DEBUG story `BookOutline landing`.
2. **Reading flow (Read ▸ Scroll)** — `ReadingFlowView.swift`: the same discipline hand-copied at
   UNIT A (it cites `BookView`'s constants); DEBUG story `ReadingFlow landing`.
3. **Takes article** — `TakesArticleScroll.swift`: aim/hold with a decaying trip budget (row 49's
   residues), the structural arm, ~15 timing pins.
4. **Book Index** — `BookIndexView.swift`: `landOrSeed` → select + pane scroll +
   `requestLiveBlock`; no DEBUG story; row 58's harness flake lives here.

Supporting mechanisms the compensators lean on: `StableSurface`/`SurfaceSizeMemory` (18d),
priming (`BookViewModel.adopt`), `LandingTarget` (the aim message), `CurrentBlockMemory` (the
cross-mode block carry). The spread's paged Read is a different class (pagination, not scroll).

## 4. Tonight's hands-on — what reproduced, what did not, and the honest reconciliation

**Protocol:** her exact gesture — open Sherlock (13 notes, ~105k words, the sample-library copy),
click the LAST chapter, then "the man with the twisted lip" (6th of 13; upward, far) — staged in
Outline, Read ▸ Scroll and Index; at 950 pt and 1500 pt window widths; cold-mounted and warmed;
clicks 1.5–8 s apart; with three and with ALL stories expanded; and once with every
`surfaceSize.*` memory deleted (the cold-heights state). Visible motion was measured by burst
strip-captures (0.5 s cadence) beside the DEBUG landing stories.

**Result: every stageable shape converged — 0–2 hops, ~1.0–1.1 s, then pixel-stable.** The worst
was the cold-heights expand-all run: first aim off by **20,848 pt**, two visible hops, settled at
1146 ms. The landing machinery, on this store, is doing its job; A2's card fix held everywhere
(not one `h=46` in any run tonight).

**What I could NOT stage is her store's geometry** — and this is the reconciliation rather than a
doubt about her report: the oscillating regime is a function of WHICH rows are realized at which
scales when the loop runs (the fixture reaches it deterministically with three 215-block stories
expanded + realistic cards + a far target: 13 hops / 4.2 s / gave up — and its pre-fix "green"
was proven to depend on the defect's timing, so the regime is real, reachable, and now honestly
exposed by priming). Her window and sidebar widths, her expansion set, her Sherlock's edits/takes,
and her `surfaceSize` memory at those widths select the regime; the dev store tonight kept falling
into the convergent one. Two store-side facts make her state colder than mine: a width she has not
used before REFUSES every remembered height at once (18d's own rule — and the sidebar columns are
draggable, so a sidebar drag changes the content width too); and any story never expanded at the
current width re-measures from the ~800-pt placeholder to ~20–25k DURING her landing.

**One more measured fact worth having:** after a settled landing, a WIDTH change alone silently
relocated the page mid-story (observed directly tonight). That is the mode-switch/resize half of
her report showing up in the same mechanism.

## 5. The recommendation — (b) a missing piece, plus (c) consolidation; explicitly NOT (a)

**(a) "a sound architecture with a local bug" — rejected.** There is no single wrong line: every
loop is doing what it says; the fixture shows the system's honest failure mode with no bug to
name. Tuning the compensator (longer hold, more hops, bigger tolerance) trades stutter count
against give-up distance and has been re-tuned three times already.

**(b) The missing piece: a BOOK HEIGHT MANIFEST — heights known before the aim.** The Outline
already knows, for every row, one of: a constant (chapter heading 51; collapsed card 103 — primed,
byte-stable since A2), a remembered size (`SurfaceSizeMemory`, per width), or a note it has never
measured at this width. Collect that into one per-book, per-width answer — `entries × (collapsed
height | expanded height | estimate)` — with the last arm derived from stored block counts/lengths
(AppSpec §4's designed fallback, P1-shaped: ∝ entries, never ∝ text; the 18h/`leadingBlockTexts`
pattern shows the read shape). Then a landing **computes the target's offset arithmetically and
scrolls ONCE** (offset-addressed, not estimate-resolved), the compensator surviving only as the
net under the estimate arm. Where every height is known — the common case after a book's first
day at a width — a far landing is exact on the first frame and there is nothing to stutter.
The same manifest gives the flow its offsets (largest absolute win: 306k-pt column) and makes the
width-change relocation fixable (recompute the offset from the manifest at the new width instead
of letting the ScrollView keep a now-meaningless offset).

**(c) The consolidation: ONE landing authority.** The Outline's discipline was hand-copied into
the flow and half-exists in Takes and Index. Hoist the aim/hold/quiet/hop brain to one home
(`App/Variorum/Shared/` or `Core/Views/` per the hoist-at-next-touch rule — it is now at its
SECOND consumer and past it), parameterized per surface, with the DEBUG story built in — so the
next surface cannot fork the discipline, and a Release-safe, content-free signpost variant of the
landing story ships with it (numbers only: tops, hops, content sizes). **That signpost is also the
answer to "her store reproduces what mine cannot": the next report she files carries the trace.**

**Phase shape / cost:** one 13u-family measure-first phase (or two units inside one): U1 the
manifest + the Outline consuming it (red-on-old on the fixture's far-below arm — the wrapped
`withKnownIssue` arm coming right and being UNWRAPPED is the built-in acceptance gate, exactly as
row 64's unlock instruction anticipates) · U2 the flow + the hoisted authority + the signpost.
Takes/Index adopt at their next touch. No schema, no canon change, no `Sync/`. The fix is
evidence-gated end to end: the pins exist already (the landing suites, the wrapped arm, the
three-expanded gate), and her field walk is the acceptance evidence of its kind.

**What NOT to do, recorded so it is not re-derived:** no lazy-run restructuring (one-scale-per-run
broke the live editor's mount — closed at UNIT A, evidence later downgraded but the road stays
closed until row 64's re-measure instruction is run); no per-row `.task` reads (the A2 lesson);
no `@State` writes on content reports (row 53's 7 Hz loop); no `ensureLayout` over full documents
(TEXTKIT2 §2 — and TK2 is exonerated here anyway).

## 6. The mode-switch height question (her secondary report)

Mechanism: the cross-mode carry works (`CurrentBlockMemory` carries the block; 13u1's walk item 9
praised it and pinned nothing) — but each surface has its own REVEAL POLICY: Write asks AppKit for
minimal scroll-to-visible; Takes restores its remembered article offset or reveals at the nearer
page edge (17q R-Q21, her own ruling); Read/Index land the block at the TOP through
`LandingTarget`; the flow lands the chapter. Same block, four policies ⇒ four heights — by
design, each defensible alone, never chosen as a set.

**Achievable at reasonable cost:** ONE shared reveal policy for MODE SWITCHES specifically —
"when the mode changes, place the carried block at the same viewport fraction it occupied in the
outgoing mode" (a fraction, not a pixel: the surfaces' visual deltas — take strips, callout
frames, the editing ring's ~one-character wrap difference — make pixel identity a false promise,
and P3's one-live-editor split guarantees the tiers differ). That is an aim-time change in the
shared carry, not a settle change, and it composes with (b)/(c). **Not achievable honestly:**
pixel-exact continuity across modes; recommend explicitly accepting the ≈one-line tolerance she
already offered. If she wants only one thing here, the viewport-fraction carry is the polished
feel at a unit's cost, and 13u3 (FACES) is its natural home.

## 7. For whoever runs the fix

- Read UNIT A / A2 in `notes/plans/phase-13u2-feel.md` first — the traces, the revert's 3-vs-3,
  and RULING A-1/A-2 bind the ground already tried.
- KnownIssues rows to carry: 64 (the wrapped arm + its unlock instruction — the manifest's
  acceptance gate), 49 (Takes residues), 58 (Index flake — likely the warning-sweep family), 44
  (the defaults leak, adjacent), 48 (the double realization).
- Tonight's raw landing stories: `/tmp/nav-trace-stderr.log` on this machine (ephemeral; the
  numbers that matter are quoted in §4).
- Her diagnostic, if wanted before the build: which book MODE she was in (outline · index · book ·
  read), whether stories were expanded, and whether the window/sidebar had been resized since she
  last read Sherlock — those three answers select the regime in §4. The Release signpost in (c)
  makes this question unnecessary ever after.
