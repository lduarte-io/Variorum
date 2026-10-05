# 17y B2 — cold-review ladder ROUND 1 (opus-reviewer, 2026-10-05; the orchestrator's arbitration — same-model flow)

**Scope:** `git diff 8ff566e1..d3560ab9` (B2 — items (a)(b)(e)(m)(n)(p); the orchestrator's
record-only commits inside the range reviewed as record). Reviewed cold in the worktree under
`notes/REVIEW_PROMPT.md` verbatim; the reviewer's probes ran in a scratch `git archive` copy —
the worktree untouched, no instance running. The reviewer confirmed the cast call independently:
no `Sync/`, custody, schema, editor seam or default's-meaning content in the diff.

**Verdict: 0 BLOCKER · 2 MAJOR · 2 MINOR · 6 NIT.** A FIX ROUND is owed (MAJOR-1 and the
cheap hardening/correctness NITs, in a FRESH implementer session); MAJOR-2 re-owns to B-DEDUPE
in-pass; MINOR-2 is the orchestrator's own record work. Round 2 re-reviews the fixes.

## Findings and dispositions (the orchestrator arbitrating against the spec)

**[MAJOR-1] · `BookPanelModel.swift:339` (`dropOutcome`) + `:486` · a FINISHED/SEALED book in a
stamp order now speaks a refusal whose way out is impossible.** Evidence (reviewer-traced +
probed): `dropOutcome` never checks `locked`; pre-B2 the same drop reached `assignPostToSection`,
whose lock guard (Operations+Sections.swift:140) runs before its no-op guard (:160) and spoke
*"“X” is finished — reopen it first."* Post-B2 the sort gate answers first with "set the book's
order ▾ to Manual order and save it" — but on a frozen book the Save button is hidden
(BookView.swift:1082) and `setReadingSort` refuses (Operations+Reading.swift:199). Probe: red on
d3560ab9, green pre-B2.
**DISPOSITION: CONFIRMED — FIX THIS ROUND.** The contract is U2-8's own: the refusal must carry
a REAL road. A frozen book's drop speaks the reopen/unseal refusal, never `needsManualOrder` —
the lock consult runs BEFORE the sort gate (letting the plan run so the op's own guard speaks is
the preferred shape: one refusal source, sealed wording free). PIN (red-on-old on d3560ab9): the
reviewer's probe shape — finished + stamp order + same-chapter drop expects "reopen"; plus the
sealed variant expecting "unseal".

**[MAJOR-2] · `TutorialSeeder.swift:455–457` + `:1666–1680` (= the batch's F-B2-6) · once (p)
ships, the RELEASED field guide teaches a mode that isn't there, and the deferral had no owner.**
Evidence: the seeded guide's mode-row sentence hard-codes "… · Blocks · Canvas, and ⌘1 through
⌘7" and a whole lesson opens "CANVAS (⌘7) scatters the blocks…"; Release has six modes and ⌘7
unbound; B-SEED seeds the guide into every fresh store at birth and R-17y-6 ships 0.9.2 at this
pass's close — before 13s. The helper's own "canvas" entry was gated for exactly this class
(WT-1 in prose); the guide's identical teaching was left in on the B2 fence (seed content),
owned only by a line in the batch record.
**DISPOSITION: CONFIRMED — RE-OWNED IN-PASS TO B-DEDUPE** (the orchestrator's implementation
batch, which already carries the pass's ONE authorized seed-content touch — R-17y-8's lesson
sentence — with the re-seed consequence recorded). The fix there: the mode-row sentence derives
from the (p) seam (`PostMode.modeList()`/`keySpan()`) and the Canvas lesson gates on
`buildKeepsCanvas`, exactly as the helper does — truth-telling against the shipped build, not
content authoring; the Debug guide (and the tutorial spine) keeps teaching Canvas. PROVISIONAL
(numbered at B-DEDUPE's close, QUESTIONS-ready): (a) this build · (b) ship 0.9.2 teaching Canvas
briefly with a 13s-owned KnownIssues row. The 0.9.2 notes presented to her will name the change
either way. The B2 fix round does NOT touch it — the seed-content fence holds for that session.

**[MINOR-1] · `ShelfView.swift:610` + `:1022–1029`; `BookcaseRowFreezeTests.swift:22` · the
row-freeze pin's red-on-old depends on a frame recorder nothing reads, and the record's 3c
evidence cites a diagnostic version of the test.** Evidence (reviewer re-ran both sides): the
committed pin IS red 3/3 with the identity line reverted — but goes GREEN (hollow) if the
`.onGeometryChange(.global)` → `recordFrame` modifier is also removed; no test reads
`BookcaseRowOracle.frame(_:)`; its doc claims a read that doesn't exist; the record's "RED 3 of
3 … 4 issues" issue-lines sit past the committed file's end and two are DIAG prints.
**DISPOSITION: CONFIRMED — FIX THIS ROUND** (hardening + honest record; no pin owed — not a
bug-class fix): say at BOTH sites that the recorder is load-bearing for this pin's red-on-old
and that the why remains unexplained; make the pin REQUIRE a frame record for both rows so the
coupling is explicit and the recorder cannot be "cleaned up" into hollowness; correct the B2
RECORD's 3c evidence citation to the committed test's real lines/issues.

**[MINOR-2] · `AppSpec.md` §12 + the 17y record · a canon change and a deferred defect were
both unrecorded.** (i) §12 still teaches the seven-mode row and "Canvas = a VIEW on a post or
the scraps area" — false in Release after (p). (ii) F-B2-7 (the book view's OWN navigator/
Outline drop under a stamp order is still the silent no-op) was left "the orchestrator's call"
with no owner.
**DISPOSITION: CONFIRMED — THE ORCHESTRATOR'S OWN, done at this round's seam:** (i) the entry's
close list gains the §12 canon delta line (Canvas Debug-only; Release six modes ⌘1–⌘6; the
Snippets canvas off in Release per P-17y-B2-7/#184(g)) — landing at the entry's CLOSE exactly as
her (p) ruling stated it; (ii) F-B2-7 RE-OWNS TO B3 (a rider on its book-view touch — the same
`needsManualOrder` words AND MAJOR-1's lock-first ordering apply to that surface; the B3 brief
amended). Neither is deferred out of the pass, so no KnownIssues row.

**[NIT-1, SPECULATIVE on the trigger] · `CaptureTextView.swift:227–229`/`286–295`;
`CaptureFocusReportTests.swift:45` · the Bookcase's real autofocus road writes SwiftUI state
inside `updateNSView`; the pin's host exercises the other road; the test header mis-states the
red count (1 issue, not 2).**
**DISPOSITION: CONFIRMED — FIX THIS ROUND** (the standard fix for the state-during-update
class): deliver `onCaretChange` async (or run `takeFocus` async), move the pin host's raise into
`.task` so it drives the real road, correct the header. The (m) suites and the one-cursor
behaviour must hold green — if the async delivery destabilizes focus timing in any suite, STOP
and record instead (the walk already proves the outcome; this is hardening).

**[NIT-2] · stale comments at `BookcaseStrip.swift:51–54`, `BookPanelModel.swift:121–124`
("the proven Transferable road" — both roads were dead, F-B2-1), `PostDetailView.swift:891`
("the date rides as the field's prompt" — no longer true), and the prior masthead pin's doc
(claims it guards what F-B2-3 showed it cannot see).**
**DISPOSITION: CONFIRMED — FIX THIS ROUND.** One-line corrections pointing at the plist/
`DragTypeDeclarationTests` and at the new words-measuring pin.

**[NIT-3] · `BookPanelView.swift:224` · the lone-chapter grip is removed by `if`, shifting
chapter names ~12 pt as the count crosses 1↔2 — the opposite of (b)'s own fixed-column/opacity
idiom.**
**DISPOSITION: CONFIRMED — FIX THIS ROUND:** draw by opacity in a fixed slot (#184(b)'s decision
unchanged — only the layout mechanism).

**[NIT-4] · `BookPanelModel.swift:339–346` · the stamp-order gate refuses a drop that is
already satisfied (a note dropped onto its immediate shown successor).**
**DISPOSITION: CONFIRMED — FIX THIS ROUND:** return `.nothing` when the manual plan's `before`
is the note's immediate successor in its shown group — no placement was being asked, so no
refusal is owed (the refusal's own words would be false: nothing needed placing). Match manual
order's behaviour for the same gesture.

**[NIT-5] · `PostMode.swift:90` · overriding `allCases` drops the compiler's completeness
guarantee — a future case omitted from `declaredOrder` would silently vanish.**
**DISPOSITION: CONFIRMED — FIX THIS ROUND:** a completeness pin — every case (via an
exhaustive-switch helper) appears in `order(keepingCanvas: true)`.

**[NIT-6] · `ShelfViewModel.swift:515` (`gripHelp`) · "lands right above the row you drop it
on" is false across the starred float (an unstarred book dropped on a starred row lands at the
top of the unstarred run — pre-existing U1/§20 design, newly reachable).**
**DISPOSITION: CONFIRMED — FIX THIS ROUND:** soften the help copy so it promises only what §20
delivers; record the edge as a #184 extension in her words (alternatives: refuse cross-half row
drops with a stated reason; her walk may pick). The placement behaviour itself is settled
design — not touched.

## Clean bill (reviewer's, verified load-bearing items)

The plist lints and carries exactly the three `UTType(exportedAs:)` identifiers, Debug and
Release alike, with no generic `public.data` target to leak into; the section-qualified row
identity independently re-proven red/green; (e)'s trace verified to the op's no-op guard with
cross-chapter filing unchanged; (m)'s one-consumer claim and non-key-window behaviour checked;
(n)'s no-prompt + behind-text + accessibility label + R6-3 draft rule intact; (p)'s seam
enumeration complete (every `allCases` reader, the stored decode, the registry/helper/masthead
strings, the `.surface` doors) and the Release compile log located; END counts located
(335/62 + 98/13); P1 constant-per-row; #184 carries the seven provisionals in her words;
mobile parity holds.

## The round's process record

Findings and dispositions land in this file BEFORE any fix session sees them (this commit).
The FIX ROUND runs in a FRESH `opus-implementer` session (the B2 implementer sits at ~780k
tokens — past the ~500k quality line; the ladder's "fixes in a fresh session" applies), briefed
from THIS file + the B2 RECORD, fences identical to B2's (seed content included — MAJOR-2 is
B-DEDUPE's). Round 2 re-reviews the fix diff with a FRESH reviewer. MAJOR-2's fix lands in
B-DEDUPE and is re-reviewed by THAT batch's fable-reviewer round.
