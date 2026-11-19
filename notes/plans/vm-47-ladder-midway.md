# VM-47 — the midway cold review (batches 1 and 2)

**Run record: `notes/plans/vm-47-sizes-and-look.md`.** Taken at her word ("you can do a midway through review
it if you prefer"), after batch 2 and before the screens build on the layer and the controls. Reviewer: a
fresh `fable-reviewer`, `notes/REVIEW_PROMPT.md` verbatim with zero framing, 2026-11-19. Scope: the diff
`fe85ea6d5..574a9ad87` (app code through `7250b9bd8`). Tally: 0 BLOCKER · 1 MAJOR · 2 MINOR · 2 NIT.

The findings below are the reviewer's report, verbatim. Dispositions follow in §2; under the cross-model flow
the implementer answers each finding (agree or dispute), the reviewer makes the final call, and the
implementer applies the confirmed fixes. The ladder's round 1 (a fresh reviewer over the whole run's diff)
re-checks them.

## 1. The reviewer's report (verbatim)

VM-47 midway cold review — batches 1 and 2, diff `fe85ea6d5..574a9ad87` (app code through `7250b9bd8`; the merge `057c7cd87` brought only main's notes + coordinator skill, excluded from review). Reviewed in `~/dev/variorum-vm-47`. Read-only throughout; no phone suite was run (stage-gated), so the record's run counts were checked by disposition-tracing, not re-execution.

### Findings

**[MAJOR] · `App/Variorum/Shared/Theme/PhoneType.swift:337–359` (`PhoneType.uiFont`) · The 13 pt floor is absent from the UIKit form, so at the below-default text settings every UIKit-read role renders under the floor the batch's own rule and test claim.**
Evidence (traced): the SwiftUI rule `pointSize(_:at:)` (PhoneType.swift:286–302) floors both scaling classes at `max(floorSize, …)`, and `MobilePhoneLayerTests.nothingIsEverBelowThirteenPoints` (MobilePhoneLayerTests.swift:88–99) pins exactly that function over all twelve settings — its own doc comment says "the smallest settings shrink the anchors below their Large sizes; the floor holds them". `uiFont` has no lower bound in either branch: `.fullRange` returns `metrics.scaledFont(for: base, compatibleWith: traits)` raw, `.holdsAtXXXLarge` caps only the top (`maximumPointSize`). Concrete inputs → wrong output: at `.extraSmall`, Terminal `rowPreview` (base 13, subheadline anchor, 15→12 curve) resolves ≈10.4 pt; `meta` (13, footnote) → 12.0; the segmented choice's `chip` font (PhoneControls.swift:612) → 12.0; `MobileEditorStyle.Face.body` (Terminal noteBody 15, body anchor) → ≈12.4. Live call sites: `MobileCommentsSheetView.swift:351` (`face.font(.rowPreview)` — her comment words) and :212 (`.noteBody` draft), the takes/history/chrome overlays' `.meta`/`.controlInline` reads, and `PhoneSegmentedControlBridge`. So the same role renders 13 pt in the SwiftUI form and 10.4–12.4 pt in the UIKit form on the same screen, and the only test touching `uiFont`'s bottom end is the Large-identity check (MobilePhoneLayerTests.swift:103–113). `PhoneReadingModifier` (PhoneType.swift:551) DOES floor its `scaledValue` — further evidence the omission is an oversight, not a choice.
Pin (red on this tree): `#expect(PhoneType.uiFont(.rowPreview, voice: .terminal, compatibleWith: UITraitCollection(preferredContentSizeCategory: .extraSmall)).pointSize >= 13)` — and the same loop over all roles/voices/settings, mirroring `nothingIsEverBelowThirteenPoints`.
Fix shape: in `uiFont`, floor per resolved traits — when the scaled font's pointSize lands under `floorSize`, return `baseUIFont(spec, voice:, pointSize: floorSize)` (a fixed 13 pt font; the overlays and the bridge already re-resolve per layout/update, so a per-trait fixed font is their existing contract). `Face.body` (built directly in `Face.init`, MobileEditorStyle.swift:111–140) shares the gap but is the editor seam's text-size story — fix it the same way or record it explicitly for VM-137; today it is not recorded anywhere.

**[MINOR] · `App/Variorum/VariorumMobile/Features/Write/MobileEditorStyle.swift:172–174 + 199–221` · `baseParagraphStyle`'s new scale factor is launch-time, while the body font auto-adjusts mid-run.**
Evidence: `terminalFace`/`studyFace` are `static let` (one `Face.init` per process, resolving `metrics.scaledFont` at the then-current category), and `baseParagraphStyle` computes `scale = baseFont.pointSize / note.size` from that cached font — but `MobileEditorTextView.swift:933` sets `adjustsFontForContentSizeCategory = true`, so after a mid-run text-size change the drawn body font grows while `paragraphSpacing` and `lineSpacing` stay at the launch-time scale until relaunch. Launch-time sizes are correct (launching at AX5 scales the gap correctly). This is the same staleness class the pre-batch constants had (not a regression), but the new comment ("the gap and the line pitch grow with Dynamic Type as the body does") overstates what ships, and unlike the overlays' fixed frames this one is NOT in either batch's "Recorded and left" list. Disposition wanted: record it for VM-137 (one line in §6), or re-derive the style per current category. Pinnable only via trait-override gymnastics at first access — borderline; the record line is the cheap honest fix.

**[MINOR] · `App/Variorum/Shared/Theme/PhoneControls.swift:556–567 + 601–611` · The segmented bridge's shown selection can go stale if a site ever refuses a change — flagged as a HOLLOW-pin hazard, not a fix.**
Evidence: a tap moves `UISegmentedControl.selectedSegmentIndex` natively before `onSelect` fires; if the site's `select` does not write state, no SwiftUI update runs and the control keeps displaying the un-accepted choice (the contract comment itself says the selection is "re-applied on every update", which presumes an update happens). All three current sites (`MobileBlockList`, Create Book's kind, OR/AND) assign unconditionally, so no failing-on-old test exists today — do not fix; worth one sentence in the control's contract comment so a future refusing site knows to force an update.

**[NIT] · `App/Variorum/Shared/Theme/PhoneType.swift:447–456` · The `weight:` override rebuilds the font at the new weight but keeps the regular face's `lineSpacing`** (Iowan Roman vs Bold natural line heights differ by a fraction of a point). Invisible in practice; note only.

**[NIT] · `App/Variorum/Shared/Theme/PhoneType.swift:300 vs 354–358` · The SwiftUI hold (`scaledValue`) can sit 1/3 pt above the UIKit hold (`scaledFont`) at ≥xxxLarge.** Already recorded in batch 1's results; fine as recorded — listed so the ladder knows it was checked, not missed.

### Open items the record already owns (not findings — closeout evidence still owed)

- The one walk covering batches 1+2 (row 2.8e, 123 captures) is NOT-STARTED; it is the batches' named closing evidence and several batch-1 "recorded" items (the Terminal path line's confirmation, the masthead at true size) point at it.
- The `MobilePhoneControlsTests` targeted re-run of the two test-only fixes (`a37789cb9`, `7762aef3b`) is PENDING its window.

### Clean bill (checked, solid)

- **The Mac cannot have changed:** `VoiceTokens.swift` absent from the diff; `SharedPageStyle`'s nil arms byte-identical (read the full diff) and the styled arms unreachable on macOS by the compiled-always-nil environment accessor (SharedPageStyle.swift:63–73); `PageDoor`'s nil arms untouched; every other Shared addition is code the Mac compiles but never renders (UIKit pieces behind `os(iOS)`); Mac theme suites 42/7 green per the record, consistent with the diff.
- **The ink rule:** `PhoneInks.source` copies are pinned against the live token layer (`theSourceIsTheTokenLayersOwnValues`); the grounds match `VoiceTokens.applying` exactly — I verified `PaletteTone(light: nil, dark: …)` for surface/card in `PaletteDerivation`, so "palette replaces paper/card in dark only" is the code's truth, not an assumption; floors computed over all 2·2·2·(2+2+48) grounds with the count pinned; the shipped eight pinned equal to the rule; hue-held and dark-muted-unchanged pinned.
- **The role table** is the sheet's as drawn, pinned row by row in both voices; the two-under Terminal rule pinned for every role; the two scaling classes pinned at both ends for the SwiftUI rule and at the top for UIKit (the bottom gap is the MAJOR above).
- **W-024:** the shelf arithmetic honestly re-derived (`quickEntryLineHeight` 24 / `metaLineHeight` 18 / `bookRowHeight` 44 / chrome 60), the floor now in lines of the box's text at the CURRENT size with the shelf passing the scaled line into `split` (MobileShelfView.swift:95–102); the partition law, floor-wins and line-cap pins moved with the change; the hint's fit rule uses only the hint's own cuts (pinned) and `ViewThatFits` picks the longest that fits.
- **The keyboard-share pin's move** (`29f2cbd41`) is correct: the old 0.42/596 bound measured the path line's height as much as R27's share; the new assertion is the rule's own room (books+writing ≥ half). The fix `4ec664f2b` (cap at `scaledFont`'s own xxxLarge size) matches the traced 1/3 pt mechanism.
- **The path-line fix and pin:** mechanism traced and real (Terminal mono ≈437 pt > 402); the pin covers both voices × 402/430 + the Library twin; red-on-old proven in a detached snapshot (22 issues) with this worktree never reverted — the snapshot method is sound (only the two files that changed solely in `47ee432fc` were reverted).
- **The two in-run test reds' dispositions check out against the code:** the field's 44-at-every-size is the layer's own arithmetic (23 pt line + 16 ≈ 43.4 < 44; P-47-14 correctly put to her), and `PhoneSheetHeader` draws/speaks its title exactly as handed while all twelve sites hand voiced/path titles (verified by grep).
- **No copy changed anywhere:** string-literal diff over the whole phone+Shared tree shows only comments and the `gearshape` symbol; every ProtectionWords sentence byte-identical (the Castle faces changed type/ink only); no accessibility label changed except where the segmented choice's per-segment elements took over word+selected duty — pins that drive doors by label stay valid.
- **The source guards are real:** both scans walk the actual tree (reach pinned at >60 files, named files present), patterns measured red on the pre-batch trees per the record; my own grep confirms zero `tokens.small/body/title/heading/mono` and zero `tokens.muted/faint` reads remain in the phone tree; the surviving raw `.font(` sites are exactly the named exceptions (store-failure frame, the 28/30 protection glyphs).
- **The controls:** geometry/contract tests measure real hosted surfaces; the sheet header's −12 trailing trick is consistent at all twelve adopter sites (each verified inside a 20 pt gutter); `PhoneHitAreaButton` keeps frames and drawing untouched with the superview caveat documented and pinned; the segmented control's per-segment accessibility override lists every segment with plain word + button + selected and activate routes through the same guard as a tap.
- **Scope discipline held:** no `Sources/VariorumCore`, no `Sync/`, no editor seam (`MobileEditorTextView`/`MobileEditorViewModel`/`EditorBrain` absent from the diff; `MobileEditorStyle` face values only; the text inset untouched with the 15+5=20 trace recorded for VM-137); no corpus-proportional cost introduced (the resolver caches per role·voice·category); commits carry no trailers; the T1–T109 inventory spot-checked (~40 entries) against the diffs and matches, with every LEFT row naming an owner.
- **Review foci (the self-assessments' risk lists), each addressed:** filter row `meta` vs `chip` — defensible under #92(b), known issues honestly pinned with `withKnownIssue` and owned (VM-93/VM-50); overlays' fixed frames under big type — recorded, owned by VM-152, fonts verified to fit the frames at default; the masthead's geometry — PROVISIONAL P-47-12, hit-reach arithmetic verified (6+6 into the old 12 pt gaps, flow shifted back 6); PageDoor's destructive arm in the voice's alarm — phone arm only.

Recommended disposition: the MAJOR goes to the implementer (one function, its pin mirrors the existing floor test); the first MINOR wants a one-line record entry or a small re-derивation, the second MINOR a contract comment only; the NITs need no action. Under her 5-round rule this MAJOR earns a fix pass and a fresh round.

## 2. Dispositions

| # | Finding | Implementer | Reviewer's final call | What changed |
|---|---|---|---|---|
| M-1 | MAJOR — `PhoneType.uiFont` has no 13 pt floor (the UIKit form renders under the floor at the small text settings); `Face.body` shares the gap | **AGREE** (traced). `uiFont` floors neither class; at xSmall/Small/Medium the UIFontMetrics curves put Terminal `rowPreview` ≈10.4, `meta`/`chip`/`controlInline` 12.0, Terminal `rowTitle` ≈12.4 while the SwiftUI form holds 13. Fix: floor in `uiFont` (a fixed 13 pt `baseUIFont` when the scaled size lands under it); pin `uiFont` ≥ 13 over every role × voice × setting, red on old. `Face.body`: RECORD for VM-137, not fix (§2a) | PENDING | PENDING |
| m-1 | MINOR — `baseParagraphStyle`'s scale is launch-time while the body font auto-adjusts mid-run; the comment overstates; not in a "recorded and left" list | **AGREE** — take the record line (+ correct the overstating comment, `MobileEditorStyle.swift` only). A per-category re-derivation cannot be honest without the text view's trait-change road (`MobileEditorTextView`, off-limits). Not pinned: a record entry, not a fix (§2a) | PENDING | PENDING |
| m-2 | MINOR — the segmented bridge's shown selection can go stale if a site refuses a change (no site does; hollow-pin hazard) | **AGREE** — a contract-comment sentence in `PhoneSegmentedChoice` only; all three sites assign unconditionally (checked), so any fix would be hollow (§2a) | PENDING | PENDING |
| n-1 | NIT — the `weight:` override keeps the regular face's `lineSpacing` | **AGREE**, no action — at its one site (Done, `.control` semibold) the label is one line (`lineLimit(1)`), so `lineSpacing` never acts, and SF Pro/Mono keep one line height across weights (§2a) | PENDING | PENDING |
| n-2 | NIT — the SwiftUI hold can sit 1/3 pt above the UIKit hold at xxxLarge and above (already recorded in batch 1) | **AGREE**, no action — already in batch 1's results; the M-1 floor does not touch the top end | PENDING | PENDING |

### 2a. The implementer's answers (the closer, Opus, 2026-11-19 — answers only; nothing changed this turn)

**M-1 — AGREE.** Traced in `PhoneType.swift`: `pointSize(_:at:)` (the SwiftUI rule) returns `max(floorSize, …)` for
both classes; `uiFont(_:voice:compatibleWith:)` returns `metrics.scaledFont(for: base, compatibleWith: traits)` raw
for `.fullRange` and caps only the top (`maximumPointSize`) for `.holdsAtXXXLarge` — no lower bound in either arm.
Apple's text-style curves at the three below-default settings (subheadline 12 · 13 · 14 against 15 at Large;
footnote 12 · 12 · 12 against 13; headline 14 · 15 · 16 against 17) put, at xSmall, Terminal `rowPreview` (13, the
two-under rule) at ≈ 10.4, `meta` and `sectionHeader` at 12.0, `chip` and `controlInline` at 12.0, Terminal `rowTitle`
(15) at ≈ 12.4 — and `meta` stays 12.0 through Small and Medium. The rule the batch states ("nothing on the phone is
set below 13", the sizing sheet §A, the record's batch-1 item 2) and the SwiftUI form both say 13, so the same role
draws two sizes on one screen (the overlays' and the segmented choice's UIKit text beside SwiftUI chrome). The live
UIKit sites are the 34 `face.font(_:)` reads in the three overlays, the takes chrome and the block decor's mark, plus
`PhoneSegmentedControlBridge` (PhoneControls.swift:612). None of them sets `adjustsFontForContentSizeCategory` (only
the editor's text view and the emoji field do — checked by grep), and the bridge re-resolves on every update with its
category passed explicitly, so a FIXED 13 pt font at the floor costs those sites nothing they have today.
*What I would change:* in `uiFont`, after the class's own arm, `guard scaled.pointSize < floorSize else { return scaled }`
and return `baseUIFont(spec, voice: voice, pointSize: floorSize)` — the reviewer's fix shape, one function, Large and
above byte-unchanged. *The pin (red on old):* `MobilePhoneTypeTests` gains the UIKit twin of
`nothingIsEverBelowThirteenPoints` — every role × both voices × all twelve settings,
`PhoneType.uiFont(role, voice:, compatibleWith: UITraitCollection(preferredContentSizeCategory:)).pointSize >= 13`; red
on this tree (≈ 10.4 for Terminal `rowPreview` at xSmall, 12.0 for `meta`), proved by reverting `uiFont` alone on a
committed tree (or the snapshot road), green after.
*`Face.body` — the alternative I would take: RECORD for VM-137, do not fix here.* `Face.init`
(MobileEditorStyle.swift:110–135) builds the editor's body with `UIFontMetrics(.body).scaledFont(for:)` — the gap is
real but narrow: Study's 17 pt body lands at 14 at xSmall (clear); only Terminal's 15 pt body goes under, ≈ 12.4 at
xSmall (13.2 at Small clears). A floor there would have to be a fixed, non-metrics font, and the editor's text view
sets `adjustsFontForContentSizeCategory = true` (MobileEditorTextView.swift:933 — the file this run does not edit),
which re-scales only metrics-made fonts: a floored body would stop following the text size mid-run when she raises
it — trading 0.6 pt under the floor at one setting in one voice for an editor that no longer grows until relaunch.
That is the editor's text-size story, VM-137's. The fix pass would add one line to batch 1's "Recorded and left":
*Terminal's note body in the editor draws ≈ 12.4 pt at the xSmall text setting (`Face.body`, UIFontMetrics(.body),
no floor; Study clears at 14) — VM-137, with the editor's text-size road.*

**m-1 — AGREE; I would take the record line, plus correcting the comment.** Traced: `terminalFace` / `studyFace` are
`static let` (MobileEditorStyle.swift:173–174), so `Face.body` is resolved once per process at the then-current
category; `baseParagraphStyle` (:206–223) computes `scale = baseFont.pointSize / note.size` from that cached font, so
the paragraph gap and line air are launch-time, while the text view (`adjustsFontForContentSizeCategory`, :933 of the
untouched `MobileEditorTextView`) re-scales the drawn body mid-run. Launch at any size is right; a mid-run change
leaves the gap at the launch scale until relaunch — the same staleness the pre-batch constants had (they never
scaled at all), so not a regression, but the comment "the gap and the line pitch grow with Dynamic Type as the body
does" overstates it and no "Recorded and left" list carries it. Re-deriving per current category inside
`baseParagraphStyle` would not be honest on its own: the font every write uses (`baseFont`) would stay launch-size
while the style moved, and the paragraphs already in the text storage keep the style they were written with — the
real fix is the text view's trait-change road, which is VM-137's file. *What I would change:* the comment, to say
the scale is the body's at launch (mid-run changes re-scale the drawn body through the text view, not this gap —
VM-137), and one line in batch 1's "Recorded and left" naming it for VM-137. No pin: a record entry and a comment,
not a behaviour change.

**m-2 — AGREE; a contract-comment sentence only.** Traced: a tap moves `UISegmentedControl.selectedSegmentIndex`
natively, then `.valueChanged` → the coordinator → `PhoneSegmentedChoice`'s `onSelect`, which calls `select` only when
the value differs; `updateUIView` re-applies `selection` only when SwiftUI re-renders, which happens only if `select`
wrote observed state. A site that refused a change would leave the control showing the refused segment. All three
sites assign unconditionally — `MobileBlockList.swift:463` (`segment = $0`), `MobileCreateBook.swift:253`
(`model.kind = $0`) and `:285` (`model.joinAll = $0`) — so no failing-on-old test exists and a code fix would be a
hollow pin. *What I would change:* one sentence in the selection-contract comment — a site whose `select` may refuse
must force an update (or the bridge will show the refused segment). No pin.

**n-1 — AGREE, no action.** Traced: `PhoneTypeModifier.face` keeps `rawFace`'s `lineSpacing` (computed from the
role's own weight) when it re-weights the font. Its one user is `PhoneTextButtonStyle(closing: true)` — the `.control`
role at semibold, which is SF Pro (Study) or SF Mono (Terminal), never Iowan; the label is `.lineLimit(1)`, so
`lineSpacing` never acts on it, and the system faces keep one line height across weights. It would matter only if a
prose role were re-weighted on a multi-line site; none is.

**n-2 — AGREE, no action.** Batch 1's results record it (the SwiftUI hold uses `scaledValue`, the UIKit hold
`scaledFont`'s own xxxLarge size, ≤ 1/3 pt apart at xxxLarge and above). The M-1 floor touches only the bottom end,
so it neither widens nor closes that gap.

The reviewer's two "open items the record already owns": the `MobilePhoneControlsTests` re-run ran at 06:56,
after the review began — "Test run with 13 tests in 1 suite passed after 17.405 seconds", both fixed tests
green by name. The walk is still queued on the stage.
