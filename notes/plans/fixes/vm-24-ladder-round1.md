# VM-24 — ladder round 1 (cold review, `fable-reviewer`, 2026-11-20)

**Diff reviewed:** `8ff1d08af...HEAD` (tip `55920bbaa`; code tip `106a0d2a4` — nothing under App or
Sources after it, verified by `git diff --stat 106a0d2a4..HEAD -- App Sources` = empty). Reviewer:
Fable, fresh session, `notes/REVIEW_PROMPT.md` verbatim, zero framing.

## What was read and re-run

- **Read whole, in this session:** the run record `notes/plans/vm-24-unwarned-edit-routing.md`
  (§1–§12, both batch closeouts, both window results, the kickoff); `notes/plans/vm-24-walk.md`;
  `notes/handoffs/vm-24-morning-phone-session.md`; `notes/TEXTKIT2_NOTES.md` in full;
  `notes/MobileSoul.md` §1–§5; CLAUDE.md and its loaded canon. **Code read whole:** the full
  production diff of `MobileEditorViewModel.swift` plus its surrounding routing in the file
  (`storageDidEdit` and all four arms, `fallbackVerdict`, `recordAutosave`, `restampProjection`,
  `recoverFromUnroutableEdit`/`desyncRecovery`, `attach(storage:)`, the suppressed programmatic
  replace, `MobileStorageObserver`, `MobileChangedCharactersCapture`); `MobileTypedFace.swift`
  whole; the full `MobileEditTrace.swift` diff; all five new/changed test files whole
  (`MobileUnarmedEditRoutingTests`, `MobileChangedCharactersCaptureTests`,
  `MobileTypedFaceResetTests`, `MobileTypedTextFaceTests`, the `MobileEditTraceTests` diff, the
  fence suite's comment diff); grounding reads of `MarkdownFaceCore.swift` (the clear, the marker
  and heading writes, the bullet's "item reads as prose" break), `MobileEditorStyle.swift`
  (`baseAttributes`, `palette.prose = dynamic(\.ink)`), `EditorEditRouting.swift` (`ArmedEdit`),
  `MobileEditRoutingTests` (the residual comment), `MobileKeyboardBar` (the strike glyph is chrome,
  not storage).
- **Re-ran / re-verified evidence myself** (no simulator run — the stage is not mine this round;
  every window claim was checked against its local artifact instead):
  - Red-build purity by git: `git diff` of `ea5a7a635` vs `4b0eaaacb` and of `03b06f417` vs
    `d63c1e2cd` over all production roots — both empty. Mac/Shared/Sources purity over the whole
    run — empty. The caret suite's file untouched — empty diff.
  - Every window verdict line against its log in `App/Variorum/DerivedData/logs/`: a-red 8/2
    failed, 31 issues — the reds by NAME are the three routed cases + the spent arming + the fence
    pin + the standing caret pin ("hi", "hello there" at `MobileMarkdownCaretTests.swift:215`),
    every red an OUTCOME line (desyncRecoveryCount / entries / stored text / the recorded
    assertion), no premise-line red; the control green. a-alone 13/3 passed; a-company 371/52
    passed, 0 skipped, `Restarting after unexpected exit` 0, the standing pin "with 3 test cases
    passed"; a-mac 46/7 passed. b-pin 5/1 failed with 5 issues; b-pin-company 49/6 failed with the
    same 5; b-red 6/1 failed with 7 issues at exactly `:378 :412 :444 :478 :480 :539 :541`, (e)
    green; b-alone 14/3 passed; b-company 385/55 passed, 0 skipped, 0 restarts; b-mac 46/7 passed.
  - The half-1 printed readings (`vm24-b-pin-readings.txt`): typed characters inherit the MARKER
    ink by object identity (`ink=marker #8D8578`, not `≈marker`) without the face's mark — §4.4's
    mechanism read off the storage directly.
  - The walk: `walk-run.txt` ends "VM24 WALK END", prefs restored, device deleted; and I judged
    the VM-243 rows from the captures with my own eyes — `before/f-note-end.png` shows "one" and
    "two" washed, `after/f-note-end.png` shows them in full ink with only the dash muted.
  - `swift build`/`swift test` on the core package: deliberately NOT run — the diff touches no
    `Sources/` line (verified by git), so the core suite proves nothing about it.

## Findings (severity-ranked)

**No BLOCKER. No MAJOR.**

### F1 · MINOR · `App/Variorum/VariorumMobile/Features/Write/MobileEditTrace.swift:552` · the readout's "rescued" line wraps on the phone (walk finding W-1, confirmed)

- **What:** the new headline line `"  rescued           N   (each one a snap-back that did not
  happen)"` (67 chars) is longer than the readout's column and wraps onto a second line on the
  phone; the sibling lines fit ("widened …(ran past the characters that changed)" at 63 chars,
  "gate-less …" at 59). A wrapped line in a column of numbers is a defect of the instrument —
  the readout is read by her, by Copy/paste, and by the morning script's subtraction.
- **Evidence:** capture `App/Variorum/DerivedData/vm24-walk-screens/after/z-readout-after-all.png`
  (the walk's own W-1), plus the line lengths read from the source. Traced mechanism: a fixed
  string longer than the readout's measure; nothing state-dependent.
- **Fix:** shorten the parenthetical (the words are DRAFT, hers — e.g. "(snap-backs avoided)" or
  "(snap-backs that did not happen)"), implementer's hands, DRAFT marker kept. **Pin:** this is an
  instrument-wording defect, not a bug-class behavior fix; the true verification is the capture. If
  a pin is wanted, a `MobileEditTraceTests` assertion that no headline line exceeds the longest
  fitting line's length (63) is red on the current words — an honest proxy (wrap is a font-metrics
  fact, not a character count), so I'd accept the fix with the capture-class justification alone;
  the proxy pin is optional and said so.

### F2 · MINOR · `App/Variorum/VariorumMobileTests/MobileEditRoutingTests.swift:139–142` · a doc comment the fix falsified (the implementer's own residual, left for this round to call)

- **What:** `aStaleVerdictIsNotAppliedToTheNextEdit`'s doc says "A widened gate-less report can
  already overflow its entry and take the honest recovery road" — since VM-24 that is true only
  when no changed characters were kept (the `noCapture` road); with the kept value it routes. The
  twin comment in `MobileEditTraceTests.swift` WAS updated in this diff, so the two suites now
  disagree about the same mechanism, and a later reader of this routing suite would re-learn the
  pre-VM-24 behavior as current.
- **Evidence:** the comment at `:139–142` against `fallbackVerdict`
  (`MobileEditorViewModel.swift:2421–2434`) and the updated twin
  (`MobileEditTraceTests.swift:282–291` in this diff). Clarity-class: no runtime degradation; the
  degradation is a false statement of the routing contract inside the suite that pins it.
- **Fix:** one sentence, mirroring the trace suite's updated wording ("…a widened gate-less
  report routed from the report alone — the pre-VM-24 road, now only the no-capture case — can
  overflow…"). Doc-only; no pin (nothing executable changes).

### F3 · NIT · `MobileEditTrace.swift` (the `## VM-24's three additions` header) · "widened" is measured against the pre-fixing ACCUMULATED range, not the characters alone

- **What:** the header says the widening is "now MEASURED, not inferred" — true, but the measure's
  baseline is `willProcessEditing`'s accumulated range, which includes any attribute write made
  inside the same transaction (the capture's own doc says so). A transaction that bundles an
  attribute write wider than its character change reads as NOT widened even where fixing ran past
  the characters, and its per-event `changed len` overstates the change. Instrument-only
  under-count; the routing is unaffected (the wider kept range can only move an edit TOWARD
  refusal — the documented safe direction — never away).
- **Evidence:** `MobileChangedCharactersCapture.willProcess` keeps the mask-gated accumulated
  `(range, delta)`; `MobileEditTrace.report` flags `.widened` on `editedRange.length >
  changed.length` alone. No pinnable behavior — labeled honestly: no failing-on-old test exists
  for a doc nuance, so this is a wording note for the trace header (one clause), take or leave at
  the fix pass.

## Review foci (§8), each answered

1. **The kept value's pairing — SOLID.** `take` runs FIRST inside the main-actor hop on EVERY
   `didProcessEditing`, before the mask guard, and always clears; `willProcess` REPLACES on every
   first callback (nil for an attribute-only pass — design call 2, strictly safer than the ruling's
   minimum); acceptance demands delta equality AND containment in the reported range, else dropped.
   One observer per storage, minted at `attach(storage:)` (`:664–668`); the model holds it, the
   storage's delegate points at it. A suppressed programmatic write's own pass keeps and takes its
   own value and dies at the `suppressEditProcessing` guard (`:2230`). Nested attribute-only passes
   (the VM-243 reset, the restyle, the re-stamp — all inside `storageDidEdit`) can neither read a
   value (already taken) nor leave one (attribute-only will keeps nil; attribute-only did takes and
   discards). `desyncRecovery` defers its storage rewrite to a Task (`:2493`), so no character pass
   nests inside a callback. The one residue the implementer names (a character pass nested between
   another pass's two callbacks) needs a character edit inside fixing, which nothing performs, and
   the delta+containment belts would still have to pass. Pinned pure (5 tests) and through the real
   observer/model (4), green alone and in company.
2. **No refusal loosened — SOLID.** The pre-fixing range is the pass's accumulated union, so any
   pass whose old span touches two blocks rebuilds a crossing old range (a two-sub-edit coalesced
   pass across a separator unions into a crossing range too); with nil the arithmetic is the old
   line byte for byte (`changed = changedCharacters ?? editedRange`, `:2425`). Pin 2 (the true
   cross-separator replace) green on BOTH trees, log-verified; the composed-transaction and crash
   pins green in company.
3. **The fence, row by row — SOLID.** The only flight-behavior change: a widened unarmed edit now
   REACHES VM-64's storage belt instead of desyncing mid-flight — the belt withholds
   (`withholdsSystemEdit`, `:2324`), skips `recordAutosave`, forces the re-read, and the sentence
   is said at the drop. Nothing new is written toward the store during a flight (the withheld
   branch records nothing; the gate belt and the settle are byte-untouched — the switch and
   everything after it unchanged but for the reset call). Pin 4's red-on-old showed exactly the old
   mid-flight desync WITHOUT the sentence (log-verified: `:255`, `:506`, the recorded assertion);
   the fence suite's ten pins are byte-identical to main's and green in both company runs.
4. **The store — SOLID.** Routing and churn cost now read the storage's OWN pre-fixing account
   (never a judgment); every refusing/recovering arm returns before the autosave; `recordAutosave`
   is reached only from the routed, non-withheld `.block` arm; the unbound cost is `exactCost`'s
   own rule over the changed characters (`:2277–2278`), report-derived only with neither.
5. **The face reset (VM-243) — SOLID.** `MobileTypedFace.reset` writes only font, ink,
   strikethrough-removal and background-removal; never `.paragraphStyle`, never the block-ID
   attribute, never `MarkdownFace.faceAttribute` (pinned: `aFaintRunIsResetInOnePassAndNothingElseMoves`
   asserts the paragraph-style OBJECT and the block ID at every offset, and the out-of-range lead
   keeps ink AND mark). Equality gate pinned both ways: zero storage passes base-on-base (the bare
   storage's own notifications) and `typedFaceResets == 0` for plain prose on her hosted road, with
   the non-vacuity twin above zero. Range precision: D-24-1's kept value, else a bound arming's
   landing `(range.location, replacementLength)` — correct post-edit coordinates since `ArmedEdit.range`
   is pre-edit and everything before its location is untouched — else NO reset; the widened report
   is never read by the reset. Cost ∝ changed characters: one `enumerateAttributes` over the
   clamped range plus writes on dirty runs only, one `beginEditing`/`endEditing` (P1). The caret's
   honour at a rescue point: the caret suite 4/4 with the standing pin 3/3, file unedited, green in
   both company runs. The `baseInks` list is grounded: `palette.prose = dynamic(\.ink)` is a
   distinct object drawing identically to `face.ink`, and the restyle's clear writes that very
   object — identity matches, so a cleared-face run costs no write. The no-ink-run reset (design
   call 3) is right: `baseAttributes` carries an ink, so an inkless run is not the base. Storage
   writers of background/strikethrough on the phone are only the face's chip/strike (marked,
   restyle-derived — the reset stripping them inside the changed range is self-healing because the
   restyle re-derives over those lines, which contain the changed range by the containment belt)
   and UIKit's own marked-text composition — the CJK residual, correctly recorded as a device
   check (MobileSoul §5.2) and out of these pins' reach. Find-in-note draws no storage highlight
   (no `.backgroundColor` writer outside the face/chrome), so the reset cannot strip one.
6. **TextKit — SOLID.** No TK1 API anywhere in the diff; no layout forced; the reset is an
   attribute-only write in exactly the posture the restyle and the re-stamp already hold (inside
   `storageDidEdit`, after the arms), and the canary checkpoint still follows every processed edit
   (`:2390`). The new `willProcessEditing` implementation reads and keeps; it writes nothing.
7. **The trace — SOLID, one leg owed to the gate.** Disarmed cost: `current` + one `armed` Bool
   guard, the `rescued` closure non-escaping and never called (pinned:
   `theRescueVerdictIsAskedOnlyArmedAndOnlyForAnUnboundWidenedReport` counts the asks across all
   four shapes). Zero behavior change pinned on the rescued road
   (`armingTheTraceChangesNothingOnTheRescuedRoad` compares recoveries, entries AND stored rows).
   Offsets and counts only (the per-event mark shows offsets; verified in the readout code). The
   new flags are disjoint from `.mismatch` (source + pin). The report call's move below the
   verdict is still a pure append before any arm runs; the closure's second `fallbackVerdict`
   reads the index BEFORE any arm mutates it, so the rescue verdict is computed against the same
   pre-edit index as the routing one. The 100k inert pin
   (`theEditTraceIsInertDisarmedAndQuietArmedAt100k`) was deliberately not run in the windows
   (item (v)); the gate's whole-phone-target leg (L11) runs `MobilePerfWalkTests` — NAMED here so
   the gate does not drop it. Likewise the gated `MobileHerPathsPerfTests` leg: batch B records
   that `typeEdit`-driven suites now pay one attribute pass per keystroke (a harness-only road —
   its runs carry a font and no ink), so if the gated speed leg moves, that is the first place to
   look, and it is a harness cost, not a production one (half 1's readings prove her road's keys
   inherit the identical base objects and write nothing).
8. **The Mac — SOLID.** `git diff` over `App/Variorum/Shared`, `Sources`, `App/Variorum/Variorum`
   for the whole run: empty. The Mac's seven source-reading suites green twice (46 in 7, both
   logs). The Mac twin is D-24-3's ticket at closeout (L14, NOT STARTED — a closeout item, not a
   gap in the diff); `markdownCaret.noteEdit` keeping the reported range is recorded as design
   call 4 and is out of this unit (VX-296's arithmetic).
9. **The pins — SOLID.** Both red builds' trees verified byte-pure over base production files by
   git (no revert was ever in flight — the pins-first construction). Every tabled red verified in
   the logs BY NAME and line; every red an outcome line, no premise red (the construction still
   widens on this toolchain). The standing caret pin: file untouched (empty diff), red in main's
   shape on the red build AND in the base re-run (`vm24-pin-alone.log`, same `:215` expectation),
   green 3/3 on the fix in both company runs — which also proves the first callback fires on
   UIKit's own replace road on iOS 26.2. Determinism: each suite run alone and in one host after
   the 49/52 editor types with identical verdicts; the widened-every-time construction is argued
   from TEXTKIT2 §3's mechanism (a font-only run with no paragraph style in a base-styled
   paragraph forces the fixing write) and ASSERTED per run from the storage's own notifications.
   Reading (f) landed in the pin file first, built without the fix, and was red there (`:539`,
   `:541`) — the architect's "green on both is recorded, never forced red" rule never triggered.
10. **Words and records — SOLID.** Every new app-visible string carries a DRAFT marker in source
    and in the record (§10 item 6); `DeadVocabularyTests` green in both Mac legs; no UDID-shaped
    identifier in any committed run file (grepped); durations/counts/offsets only in the trace and
    the walk log; the one walk act that could not be driven is said as NOT WALKED with what stands
    in for it, never faked.

## Clean bill (beyond the foci)

- **The routing change is exactly D-24-1's letter:** the binding, the four arms, the refusal road,
  both fence belts and the settle are byte-unchanged; `storageDidEdit`'s new parameter defaults to
  nil so every pre-existing caller reads unchanged; with nil kept, `fallbackVerdict` is the old
  arithmetic byte for byte (pinned through the real observer:
  `aReportWithNoFirstCallbackRoutesFromTheReportAsBefore` desyncs exactly as before).
- **MobileSoul §5.2 honored in both fixes:** the block an edit belongs to is read from what
  changed; the face a character wears is re-derived where it lands — projection, never
  inheritance. Both device-test residuals (which roads arrive unarmed; the marked-text highlight)
  are correctly held for her "after" session rather than claimed from the simulator.
- **The walk's honesty:** the simulator produced no unarmed or widened edit (gate-less 0, widened
  0 of 55), and the record SAYS the walk therefore shows no snap-back avoided — the fix's evidence
  is the pins and her phone's "after" session (held, §10). The VM-243 before/after pair is real; I
  re-judged rows f/g from the captures myself.
- **Unit 0's instruments:** the morning script matches the wave-1 build's actual readout fields
  (counters monotonic, in-memory, no pre-fixing range — the one limit said plainly in the script).
- **The record's own claims:** every load-bearing window number in §12 and the walk record matched
  its on-disk artifact (verdict lines, issue counts, red names, line numbers, restart counts, skip
  counts, container listing lines) — nothing was found embellished.
- **Sizing and discipline:** two acceptance units plus a held device unit, one implementer per
  batch, pin-before-fix per member, no `Shared/`/`Sources/`/`Sync/`/custody/schema line, no
  orchestrator-typed code found in the diff, commits trailer-free, messages public copy.

## Disposition handed to the orchestrator

F1 and F2 are implementer-applied fixes under the cross-model flow (neither is FINDER-FIXES —
both are fully specified above; no `Sync/` line exists in this run). F3 is a one-clause doc note,
take or leave with F1's commit. No finding here earns a further round on its own (nothing
BLOCKER/MAJOR); round 2, if the cap rule grants one, would only re-check F1/F2's landings.

## The implementer's answers (round 1 fix pass)

*Opus implementer, fresh session, base `6b5dfb41d`. Each finding re-traced in the code before answering; written and
pushed before any fix.*

### F1 — AGREE

- **Traced.** `MobileEditTrace.headline()` writes the line as a fixed string (`MobileEditTrace.swift:553` on
  `6b5dfb41d`; the finding's `:552` is the "widened" line just above it — the same defect, one line off). The readout
  draws the headline in the `meta` role: Study `.system(size: 13)` (SF Pro), Terminal `.system(size: 13, design:
  .monospaced)` (SF Mono) (`Shared/Theme/PhoneType.swift:168-170`, `:230-238`), inside a stack padded 20 pt each side
  (`MobileEditTrace.swift:653`). On the walk's iPhone 17 Pro (402 pt wide) the measure is 362 pt.
- **Measured, not counted** (a font-metrics fact, as the finding says). A throwaway CoreText script in the session
  scratchpad (never in the PR) measured each headline line in the same two faces at the default text size, and the
  numbers match the capture: "widened" 350.5 pt measured, about 349 pt on `after/z-readout-after-all.png`; "gate-less"
  326.9 pt measured, about 326 pt on the capture. The old "rescued" line measures **380.0 pt, past the 362 pt
  measure — the wrap W-1 saw.**
- **The words.** Of the finding's two examples I take **"(snap-backs avoided)"**: 245.9 pt in Study, clearly inside
  its siblings that fit (326.9 and 350.5 pt) with 116 pt to spare; it also fits Terminal at a one-digit count (353.6
  pt; a two-digit count reaches 361.6 pt, at the edge). The other example, "(snap-backs that did not happen)", fits
  Study only (317.1 pt) and wraps in Terminal (450.0 pt). Both say what D-24-4 rules ("each rescued edit is one
  snap-back that did not happen"); the DRAFT marker stays; neither word is on the retired list.
- **The pin: NOT added.** The finding makes it optional. Two reasons: showing it red needs a stage window, which this
  pass is not given; and a character count is a weak stand-in here — the measurement shows it: about 45 characters
  fit in Terminal and 62 in Study, so "no line longer than 63 characters" would pass a line that wraps in Terminal.
  The verification is the measurement above, plus a capture of the readout on the fixed build, which is the
  orchestrator's to take (this pass boots no simulator). No existing pin asserts the old parenthetical: the trace
  suite's headline checks stop at the count (`MobileEditTraceTests.swift:399-401`, `:491`), so no test line changes
  for F1.
- **Two observations, not acted on** (each needs a choice the finding does not make):
  1. In **Terminal** at the default text size the other two parenthetical lines wrap too: "gate-less" (466.1 pt; E1's
     own line, older than VM-24) and VM-24's "widened" (498.2 pt). The walk's capture is Study, so nobody has seen it.
     Options: (a) leave it — the column holds in Study, and Copy hands over plain text either way; (b) shorten every
     parenthetical to fit Terminal; (c) put each explanation on its own line under its number. The meta role also
     grows with the text size up to xxxLarge, where every long line wraps; the same class.
  2. For her wording pass: `rescued` is decided before the arms run (`MobileEditorViewModel.swift:2289-2297`), so
     during a structural flight a rescued edit is then withheld by the storage belt and the page re-read (`:2324`,
     D-24-2's second row): the characters do not stay on the page in that rare case either, though the fence now says
     its sentence instead of desyncing. The old words, the new words and D-24-4's own sentence all read slightly
     past that case. Unchanged here: the meaning is D-24-4's, and the words are hers.

### F2 — AGREE

- **Traced.** `fallbackVerdict` reads `changedCharacters ?? editedRange` (`MobileEditorViewModel.swift:2425`), and
  the observer hands the kept value whenever the first callback fired and the capture accepted it (`:2911-2913`;
  `accepts`, `:2980-2984`). So a widened gate-less report can overflow its entry and take the recovery road only when
  nothing was kept (the `noCapture` case) — exactly as the finding says. The routing suite's doc
  (`MobileEditRoutingTests.swift:139-142`) still states the pre-VM-24 road as current, while its twin in the trace
  suite (`MobileEditTraceTests.swift:287-289`) was updated in this run.
- **Applied as the finding words it**, with the trace suite's own clause ("since VM-24 it routes from the changed
  characters") so the two suites say the same thing. Doc only; no pin (nothing executable changes).

### F3 — AGREE

- **Traced.** `MobileChangedCharactersCapture.willProcess` keeps the `willProcessEditing` range whenever the pass
  changed characters (`MobileEditorViewModel.swift:2962-2964`). That range is the transaction's accumulated range,
  attribute writes included (the type's own doc, `:2934-2936`). `MobileEditTrace.report` flags widened on
  `editedRange.length > changed.length` alone (`MobileEditTrace.swift:384`). So a transaction that bundles a wider
  attribute write reads as not widened, and its "changed … len" overstates the change. The routing reads the same
  wider range only toward refusal, so it is unaffected.
- **Taken** as one clause in the header's "widened" bullet, riding F1's commit. Comment only.

### What was applied

**Not done in this pass:** no optional length pin (F1's answer says why); no capture of the fixed readout (no
simulator is booted here, so that is the orchestrator's to take); no change to the two observations under F1 (they
need choices the findings do not make, so they are left for the reviewer's final call and her wording pass); batch A's
closeout in the run record (§12, "Words", `vm-24-unwarned-edit-routing.md:791`) still quotes the old words, as the
record of what shipped then. The morning script never quoted them.

| Finding | Commit | Where | Old | New |
|---|---|---|---|---|
| F1 | `9675f8888` | `MobileEditTrace.swift:553` → `:557`, `headline()` | `"  rescued           \(s.rescuedReports)   (each one a snap-back that did not happen)\n"` | `"  rescued           \(s.rescuedReports)   (snap-backs avoided)\n"` — DRAFT, the marker comment above it unchanged |
| F3 | `9675f8888` | `MobileEditTrace.swift:95-97` → `:95-101`, the header's "widened" bullet (comment text; the `//` prefixes dropped) | "the report ran past the characters that changed (the widening this file's carve-out below reasons about, now MEASURED, not inferred from `length - delta`);" | "the report ran past the characters that changed (the widening this file's carve-out below reasons about, now MEASURED, not inferred from `length - delta` — measured against the storage's accumulated pre-fixing range, which also holds any attribute write made in the same transaction, so a transaction that bundles a wider attribute write reads as not widened and its changed length overstates the change: the instrument under-counts, the routing is unaffected);" |
| F2 | `b3fa281f9` | `MobileEditRoutingTests.swift:139-142` → `:139-144`, `aStaleVerdictIsNotAppliedToTheNextEdit`'s doc (comment text; the `///` prefixes dropped) | "A widened gate-less report can already overflow its entry and take the honest recovery road, which is correct but is a different story from this one; the deletion keeps the pin on the binding alone." | "A widened gate-less report routed from the report alone — the pre-VM-24 road, now only the no-capture case (since VM-24 it routes from the changed characters) — can overflow its entry and take the honest recovery road, which is correct but is a different story from this one; the deletion keeps the pin on the binding alone." |

No test expectation moved: no pin asserted the old parenthetical (the headline checks stop at the count).

**The width evidence** (CoreText, the readout's own faces at the default text size, 13 pt; the measure is 362 pt on the
walk's iPhone 17 Pro; calibrated against the capture within about 2 pt):

| Line (count 0) | Characters | Study, SF Pro | Terminal, SF Mono |
|---|---|---|---|
| gate-less (fits in the capture) | 58 | 326.9 pt | 466.1 pt |
| widened (fits in the capture, the longest that does) | 62 | 350.5 pt | 498.2 pt |
| rescued, OLD (wraps in the capture) | 66 | 380.0 pt | 530.4 pt |
| **rescued, NEW** | **44** | **245.9 pt** | **353.6 pt** (361.6 pt at a two-digit count) |

**The build.** A phone `build-for-testing` of the tree at **`b3fa281f9`** (the working tree clean), scheme
`VariorumMobile`, destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`, no simulator booted, into
`App/Variorum/DerivedData/vm24-gate`: **`** TEST BUILD SUCCEEDED **`** (started 06:41:40, done by 06:42:53), log
`App/Variorum/DerivedData/logs/vm24-gate-bft.log`, 0 errors, no warning in either touched file, both touched files
compiled. The products hold `VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64.xctestrun`; the app's
`VariorumMobile.debug.dylib` carries "snap-backs avoided" once and "each one a snap-back" zero times (the unchanged
"widened" words once, as a control). **No Mac build is owed:** `git diff --stat 6b5dfb41d b3fa281f9 --
App/Variorum/Shared Sources App/Variorum/Variorum` is empty. **Nothing under App or Sources changes after
`b3fa281f9`**; the commits after it are records only. *(SUPERSEDED by the rebuild below: final call 2 changed one
string after this build, and the gate's product is now the rebuild's, of `8f5323554`.)*

#### Final call 2 — applied after the reviewer's final calls

**Not done:** nothing the call names is left. The "rescued", "no capture" and "gate-less" lines, the per-event
"widened — changed at …" mark, and the header and `Summary` doc comments that describe the concept are all
untouched, as the call says. Observation 2 is record-only, by the call.

| Call | Commit | Where | Old | New |
|---|---|---|---|---|
| Final call 2 | `8f5323554` | `MobileEditTrace.swift:556`, `headline()` | `"  widened           \(s.widenedReports)   (ran past the characters that changed)\n"` | `"  widened           \(s.widenedReports)   (past the change)\n"` — DRAFT, the marker comment above it unchanged |

No pin asserted the old words. The trace suite checks only the prefix `"  widened           1"`
(`MobileEditTraceTests.swift:399`), which still holds; `:396` asserts the per-event mark, which did not change.

**Measured before committing** (the same CoreText method, the readout's two faces at 13 pt, the 362 pt measure):

| "widened" line | Characters | Study, SF Pro | Terminal, SF Mono |
|---|---|---|---|
| NEW, one-digit count | 41 | 223.9 pt | 329.5 pt |
| NEW, two digits | 42 | 232.2 pt | 337.5 pt |
| NEW, three digits | 43 | 240.5 pt | 345.6 pt |
| NEW, four digits | 44 | 248.7 pt | 353.6 pt |
| **NEW, five digits (the bound)** | **45** | **256.9 pt** | **361.6 pt — fits, by 0.4 pt** |
| OLD, one digit | 62 | 350.5 pt | 498.2 pt |
| OLD, three digits | 64 | 367.1 pt (wraps even in Study) | 514.3 pt |

The bound is met in both voices. The Terminal figures cannot be checked against a capture, because no capture of the
Terminal readout exists; the Study calibration was within about 2 pt. So the five-digit Terminal fit is at the edge,
and four digits leave 8.4 pt to spare, as the call's "a digit of air" intends.

**The rebuild.** A phone `build-for-testing` of the tree at **`8f5323554`** (the working tree clean), the same
command and folder as before (scheme `VariorumMobile`, `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`, no
simulator booted, `-derivedDataPath App/Variorum/DerivedData/vm24-gate`): **`** TEST BUILD SUCCEEDED **`** (started
06:48:58, done by 06:49:26), log `App/Variorum/DerivedData/logs/vm24-gate-bft2.log` (the first build's log kept beside
it). It had 0 errors and no warning in `MobileEditTrace.swift`, which was recompiled. The products still hold
`VariorumMobile_VariorumMobile_iphonesimulator27.1-arm64.xctestrun`. The app's `VariorumMobile.debug.dylib` carries
"(past the change)" once and "ran past the characters that changed" zero times, and "snap-backs avoided" once and
"each one a snap-back" zero times. **No Mac build is owed:** `git diff --stat 6b5dfb41d 8f5323554 --
App/Variorum/Shared Sources App/Variorum/Variorum` is empty. **Nothing under App or Sources changes after
`8f5323554`**; every commit after it is a record.

## Final calls (the round-1 reviewer, same session, 2026-11-20)

*Read before calling: the fix-pass diff `6b5dfb41d..b3fa281f9` whole (two files, strings and
comments only — no executable line moves, and no test asserted the old words: the headline checks
stop at the count, verified in `MobileEditTraceTests` myself); the implementer's answers above;
the width table and its calibration against the W-1 capture.*

**F1 — CONFIRMED as landed** (`9675f8888`). "(snap-backs avoided)" at the rescued line, DRAFT
marker kept; 245.9 pt against the 362 pt Study measure, with the calibration against the real
capture within ~2 pt on three lines. **The pin's absence is ACCEPTED, for the implementer's
reason, which is better than my proxy:** ~45 characters fit Terminal where ~62 fit Study, so a
63-character bound would bless a line that wraps in Terminal — the proxy was weaker than the
measurement, and the finding had already made it optional. Verification stands on the calibrated
measurement; if the orchestrator re-runs any AFTER pass in the kept snapshot before closeout, a
capture of the fixed readout rides along as the closing picture — recommended, not owed (the
measurement is accepted evidence on its own).

**F2 — CONFIRMED as landed** (`b3fa281f9`). The sentence as my finding worded it, with the trace
suite's clause, so the two suites now state the same contract. Nothing else in the file moved.

**F3 — CONFIRMED as landed** (rides `9675f8888`). The header's "widened" bullet now says the
baseline (the accumulated pre-fixing range) and both consequences (instrument under-count;
routing unaffected). Exactly the clause asked.

**Observation 1 — call: (b), narrowly.** This run's own new line must fit BOTH voices; the
pre-existing lines are not this diff's defect.

- **The "widened" line's DRAFT parenthetical becomes `(past the change)`** — the one wording, no
  choice left: `"  widened           \(s.widenedReports)   (past the change)\n"`. The acceptance
  bound: the line fits the Terminal measure (SF Mono 13 pt, 362 pt on the walk device — about
  45 monospace characters) **at a five-digit count** — widened is per-character-report and a long
  session can run it to four digits, so the bound leaves a digit of air; by the implementer's own
  pt-per-character calibration (~8.04 pt) the fixed part (20) + 5 digits + 3 spaces + 17 = 45
  characters ≈ 361.6 pt. The implementer verifies with the same CoreText script before
  committing; words stay DRAFT, hers.
- **"rescued (snap-backs avoided)" stays as landed**, with its bound RECORDED: fits Terminal
  through a two-digit count (361.6 pt); a three-digit rescue count in one session would itself be
  a finding worth more than the gloss. No change.
- **"no capture (expected 0)" fits everywhere** at any plausible digit count. No change.
- **The pre-existing "gate-less" line (E1's, older than this run) and the xxxLarge text-size wrap
  are NOT this run's to fix:** both go to her wording pass as one line in the closeout's held
  bundle beside §10 item 6 (the readout's DRAFT words), so the choice is hers — option (c)'s
  own-line layout included if she wants it. Nothing else owed.

**Observation 2 — call: record only.** The `rescued` counter's semantics are D-24-4's as ruled —
a ROUTING verdict, decided before the arms, and that is the right instrument semantics: during a
flight the rescue is real at the routing level, and what follows is the fence's designed, SAID
withholding — a different mechanism from the silent snap-back VM-24 removes. Coupling the counter
to fence state would buy no diagnosis and cost clarity. One line rides the same her-wording bundle
("the gloss reads slightly past the in-flight withheld case, which the fence says aloud"); no code
change, no pin (no behavior).

**Second round — NOT EARNED.** Round 1 found no BLOCKER or MAJOR; the fix pass and observation 1's
remaining fix are words and comments only, with no executable change and no test expectation
touched (verified in the diff, and no pin asserts any of these strings beyond the count prefix).
Under the cap rule the ladder closes after observation 1's one-line fix lands: that landing gets
the orchestrator's line-by-line check against this call (the final-round rule), the implementer's
CoreText verification at the stated bound, and the gate's company run as the compile proof. The
pieces this round leaves open are already in the ledger: the gate's two owed legs (the 100k
trace-inert pin and the gated speed suite, L11 — with the `typeEdit` one-pass-per-keystroke note
as the first place to look if the speed leg moves), the Mac twin ticket (L14), the TEXTKIT2 §3
canon line (L12), and her device "after" session (§10).
