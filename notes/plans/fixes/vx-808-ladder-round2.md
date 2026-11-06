# VX-808 — Ladder round 2 (Opus cold review, fixes-only re-check, 2026-11-06)

**Reviewer:** fresh `opus-reviewer`, `notes/REVIEW_PROMPT.md` run verbatim over the round's scope.
**Scope (the brief's):** commits `d4e39796b` (F-4) and `94afb3e34` (F-2), plus the record commit `ad3e7e281`. The anchor is round 1's F-2 and F-4 entries in `notes/plans/fixes/vx-808-ladder-round1.md`. I reviewed only whether these fixes satisfy their findings and introduce nothing new.
**Scope check:** none of the three commits touches the editor seam, custody or keychain code, `Sources/VariorumCore/Sync/`, Protection, or a default's meaning (checked with `git show --stat`). The Opus-reviewer class is correct for this round.
**Verified headless on this tree:** `xcodebuild -scheme Variorum -configuration Debug build-for-testing` reported **TEST BUILD SUCCEEDED**. The pin's numeric expectations, extracted verbatim from `BookArrivalsReviewTests.swift` and run in a scratch harness against the verbatim `ArrivalMetaFit` from `ArrivalsReviewRules.swift`, gave **0 failures**. I traced the words' expectations by hand. No `xcodebuild test`: the app-side pin runs at the orchestrator's window.

---

## Findings (severity-ranked; `[severity] · file:line · what · evidence · fix`)

**No BLOCKER, MAJOR or MINOR.** Four NITs follow. None is a bug-class finding with a red pin through the real view, and each says so.

- **[NIT] R2-1 · App/Variorum/Variorum/Features/BookView/BookArrivals.swift (`ArrivalMetaLayout.placeSubviews`, `plan(width: bounds.width, …)`) · placement re-derives a DISCRETE choice at exactly its own threshold (latent; not reachable today).**
  - **Mechanism:** `sizeThatFits` reports `plan.width` = `why + 2·gap + dot + since` for the chosen form. The parent then hands that width back as `bounds.width`. `placeSubviews` re-plans from it, so the comparison `since.whole <= room − why − 2·gap − dot` (or the short form's) sits exactly on the boundary. It holds only if that floating-point round trip is exact.
  - **Why it holds today:** SwiftUI pixel-rounds `Text` ideal widths. I measured 94.0 · 3.5 · 134.0 · 91.5 at 11.5 pt, and with half-point inputs the arithmetic is exact.
  - **Evidence:**
    - A scratch sweep of the verbatim rule with arbitrary non-dyadic widths re-planned a different form at its own width in 117,689 of 400,000 cases. Example: why 240.85…, dot 3.64…, whole 127.40…, short 95.75… plans `.whole`, but re-plans `.short` at its own width.
    - With half-point widths the sweep gave 0 of 200,000.
    - A live offscreen `NSHostingView` sweep gave 0 form mismatches between the proposal's plan and the bounds' plan over 7,520 placements. It covered sans and mono at 11.5 pt, 4 whys × 4 stamps, and widths 80–420 pt, which exercises whole, short, dropped and a truncated why.
  - **Why not `TakeLabelLayout`:** that precedent also reads `bounds.width`, but its allocation is continuous, so an ulp of difference cannot flip anything. This rule's choice is discrete.
  - **Pin:** none is reachable through the real view, because real `Text` ideals are never non-dyadic. A pure pin with non-dyadic widths would be red on today's rule, but it would test an input the row never produces.
  - **Fix (optional hardening, the orchestrator's call):** re-plan from `proposal.width` in `placeSubviews`. Layout's contract says this is the proposal from which the bounds' size was generated, so it reproduces `sizeThatFits`'s plan exactly. Alternatively, compare with a half-pixel tolerance. Otherwise record only.
- **[NIT] R2-2 · App/Variorum/VariorumTests/BookArrivalsReviewTests.swift (`theWhyWinsTheLineAndTheSinceGivesWayFirst`) · the pin holds the rule, and nothing pins that the row reads it.**
  - **Mechanism:** revert the row's second line in `BookArrivals.swift` to the old `HStack` with `.fixedSize()` on the since, and keep `ArrivalMetaFit`. The pin stays green and the walk's "Ta…" comes back.
  - **Not hollow:** for what it claims, the pin is red on old by construction. `ArrivalMetaFit`, `sinceShort` and `whyHelp` don't exist pre-fix. Round 1 asked for exactly a pure pin.
  - **Coverage today:** the wiring is held only by the walk's narrow re-look, which is owed to the window.
  - **Fix (optional):** add one code-scan line in the form of `theReviewIsTheOneHomeAndThePopoverRetired`. It would check that the code of `BookArrivals.swift` contains `ArrivalMetaLayout {` and `.arrivalMetaRole(.sinceShort)`. The heavier road is the `TakeLabelLayoutProbe` pattern.
- **[NIT · SPECULATIVE] R2-3 · BookArrivals.swift (the row's line: the undrawn whole form placed at `.zero`; the short form `.accessibilityHidden(true)`) · at a narrow pane, the stamp's only spoken words sit on a zero-frame element.**
  - **Mechanism:** when the plan picks short or dropped, the whole-form `Text` is placed 0×0 and still carries the stamp's accessibility words. I verified that it draws nothing: 0 ink pixels in an `ImageRenderer` render, and `sizeThatFits(.zero)` returns 0×0.
  - **Unverified:** whether VoiceOver still reads a zero-frame SwiftUI element. An offscreen probe exposes no accessibility children without an accessibility client, so I could not check it here. If such elements are pruned, the line speaks no stamp at narrow widths. The why's help would still carry it.
  - **Fix:** a VoiceOver or Accessibility Inspector glance at a narrow pane during the window's walk re-look. If it is pruned, use the `TakeLabelLine` precedent: one accessibility element with an explicit combined label, which does not depend on width. No code is owed before that check.
- **[NIT] R2-4 · notes/plans/fixes/vx-808-arrivals-books.md (the ROUND-1 FIXES LIVE STATUS, F-4 row) · "the source pins that read `BookView.swift` filter `//` lines" is not quite true, but its conclusion holds.**
  - `VocabularySweepTests.swift:114` and `TutorialCurrencyTests.swift:643` read the file raw.
  - I checked every negative `contains` in the eight suites that read `BookView.swift`. None can match the new comment's words, so F-4 trips no pin.
  - **Fix:** a one-word correction to the record, if wanted.

## Clean bill (checked specifically, found solid)

1. **F-4 satisfies its finding.** The new comment ("a press opens the review area over the book's content and a second press closes it … the popover retired") matches the code: the door's action is `model.setReviewOpen(!model.reviewOpen)`, and the area is drawn through `contentOverlay` and Index's `searchAnswer` slot (BookView.swift ~333, ~659). The change is comment-only. No code-scan pin is affected: `BookArrivalsDoor(` count and `BookArrivalsReview(` count are unchanged, and nothing gained `.popover(`.
2. **F-2 satisfies its finding as ruled in round 1** ("the why wins; the since yields first … the whole fact stays on hover either way").
   - The why gets its whole ideal width before the since gets anything.
   - The since steps down from whole to short to dropped, and is never cut mid-word beside a why.
   - The why truncates only past its own width.
   - A since with no why beside it never drops.
   - The why's hover carries the since's whole fact (`whyHelp` = why + "\n" + `sinceHelp`, and the why alone byte for byte with no stamp).
   - It is built as a pure rule beside `ArrivalRowFit` with a pure pin.
   - The words and forms are PROVISIONAL **P-808-B3-8**, recorded in the B3 PROVISIONALs block for her bundle, as round 1 asked.
3. **The pin is real.** Every threshold is to the point: 276 gives whole, 275 short, 230 short, 229 dropped, 92 gives the why whole and 91 a truncated why. It also checks the walk's shape, the never-wider and why-first sweep over 0…400, the since-alone and no-stamp arms, and the words (`since == "waiting " + sinceShort`, and an unreadable stamp gives nil). It is red on old by construction. It runs green against the verbatim rule.
4. **The layout matches the plan.**
   - `sizeThatFits` and `placeSubviews` share one `plan`.
   - Each undrawn part is placed at `.zero` and draws nothing (verified as in R2-3).
   - Re-planning at the reported width is idempotent for pixel-rounded inputs. The live sweep showed this, and so did my hand trace of the whole, short, dropped, truncated-why, since-alone and no-stamp cases.
   - All parts share `tokens.small`, so aligning their tops aligns their baselines, which replaces the old `.firstTextBaseline`.
   - The dot is drawn only between a drawn why and a drawn since.
5. **The row's shape is unaffected.** `ArrivalRowLayout` reads the text column only at its ideal size (`.unspecified`) and at a fixed `textWidth` proposal. The meta line's ideal is unchanged: why + 6 + dot + 6 + since, as the old `HStack`'s was. The line's minimum width fell when the old fixed since went away, and that value feeds no rule. The W-2/W-3 stable-width law stands.
6. **Accessibility double-announcement is avoided.** The short form is `.accessibilityHidden(true)`, and the whole form keeps the words (see R2-3 for the zero-frame caveat).
7. **The neighbouring pins are untouched in substance.**
   - `ChromeLineLimitTests`: 125 bare `.fixedSize()` code sites remain (more than 30), and the removed site raises no policy question.
   - `VX351HoverWordsTests`: the `sinceHelp` words are unchanged.
   - `BookArrivalsTests`: the `since` words are unchanged.
   - `theReviewIsTheOneHomeAndThePopoverRetired`: still no `.popover(` in the code of `BookArrivals.swift`.
8. **Cost:** the line measures four `Text`s and only in realized rows (the list is lazy), so cost stays in proportion to the viewport (P1 holds).
9. **Discipline:**
   - Comment and words live in their one homes (`ArrivalsReviewCopy`).
   - No canon file is edited, and `notes/QUESTIONS.md` is untouched (the bundle waits for the merge).
   - No commit trailers on the three commits (checked).
   - The record's LIVE STATUS names exactly what is owed to the window: this suite, `BookArrivalsTests`, `VX351HoverWordsTests`, `ChromeLineLimitTests`, and the narrow re-look in both voices.

**Ladder shape:** no new BLOCKER or MAJOR, so round 3 is not earned. R2-1 and R2-2 are optional hardening for the orchestrator to rule on. R2-3 folds into the window's walk re-look. R2-4 is a one-word record correction.
