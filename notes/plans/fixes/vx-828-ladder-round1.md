# VX-828 — Ladder round 1 (cold review, Fable, 2026-11-05)

**Scope reviewed:** the run's whole diff, `git diff 8ffdd8278...HEAD` (60 files, +9,731/−186) —
batches A (VX-806/VX-655, editor seam), D (VX-800/VX-636), C (VX-823), B (VX-824/833/844),
E (VX-798/838/840) — against the run record's rulings, AppSpec/OverallModel invariants,
SurfaceContracts' touched sections, QUESTIONS #92/#94, and the purge memo's S2 bend. The vendored
`Sources/VariorumCore/Queries/TagUsageQueries.swift` was reviewed as a CONSUMER contract only
(vx-809's ladder owns its internals); its byte-identity to the owner's mint was verified
(blob `90472b916` on both `HEAD` and `origin/vx-809-mcp-door-ergonomics`). Core suites
`BoundarySnappingTests` · `EmptyBlockSweepTests` · `UnusedTagsTests` re-run headless by this
reviewer: 65/65 green. No `Sync/`, custody or keychain file in the diff; canon and QUESTIONS
untouched (drafts live in the run record — the two-file rule held).

**Verdict: no BLOCKER, no MAJOR.** One standing MINOR (plus one OVERTAKEN mid-round), four NIT.

*(Amendment, same round: this review ran against the tree at its spawn; the orchestrator's
batches B+E verification commit 6d9c383ad landed while it ran — record-only, no code — and
overtakes the second MINOR below. The verification-debt section is restated against 6d9c383ad.)*

---

## Findings

**[MINOR] · App/Variorum/VariorumTests/LibraryReturnRoadTests.swift:23, :155 · The road pin's own
text cites R-C4 as its red-on-old — which window 2 proved FALSE — and the fix's mechanism has no
automated pin at all (the run record's own flag for this ladder).**
Evidence: the file's header says "RED under revert R-C4 (the landing gated on a reading again…)"
and line 155 repeats it — but the record's "Batch C — WINDOW 2, R-C4 HOLLOW + R-C4b NAMED" section
records that BOTH R-C4 and R-C4b ran GREEN under revert on both road arguments (the hosted RootView
mount still produces a scroll reading, so the pin never reproduces the live no-reading condition),
and rules that the pin "must NOT be cited as this fix's red-on-old" — the fix's evidence is the
cross-window live pair. A later round or session reading the test file will cite R-C4 as the pin's
red and be wrong; and today a change that re-gates `landIfReady` on `memory.window.isMeasured`
(exactly the pre-fix rule) passes every suite — the verified fix has no regression net for its own
mechanism.
Fix (two parts, one commit): (a) re-word the header and the line-155 doc to say the pin is a
shell-road regression net whose red-on-old is the cross-window behavioral pair (point at the
record's window-2 section). (b) Make the pin mechanism-honest with the instrument that already
exists: install the `LibraryPlaceTrace` sink in the pin (it already prints the trace on failure)
and assert the return's `land(<trigger>)` line's trigger is never `"reading"` — the fix lands from
`appear`/`height`/`relisted`, while under R-C4 the hosted road's landing fires from `"reading"`,
so the amended assertion is red under R-C4 by construction and green on the fix.
Pin: the amended trigger assertion, shown red under R-C4 (uncommitted edit, restored), green on
the committed tree.

**[MINOR — OVERTAKEN BY 6d9c383ad, no action owed] · notes/plans/fixes/vx-828-editor-shell-qol.md
(THE LEDGER) · At this review's spawn, rows 3–5 and 9–11 still read NOT-STARTED while batches B and
E were fully built and committed** (B0–B4 at ec53930ef…8b8a2b31a, E0–E5 at c9aba7cb1…9a49f7350) —
a resuming session reading the ledger first would have met a state contradicting the batch
sections. The orchestrator's B+E verification commit (6d9c383ad, mid-round) flipped rows 3/4/5/9
to VERIFIED and 10/11 to VERIFIED-BY-PINS, which heals it. Recorded for the round's history; the
residual lesson (flip the ledger row in the same commit as the batch's build, not only at
verification) is the resiliency protocol's own and goes to the orchestrator, not the implementer.

**[NIT] · Sources/VariorumCore/Domain/BoundarySnapping.swift:189 (+ the record's P-828-6
neighborhood) · The punctuation-adjacent caret's behavior change is real and unnamed in the
record's PROVISIONAL list.**
Evidence: `wordStart` treats any non-whitespace run as the word (the scanners' own notion, stated
in the doc), so a caret between a word and its trailing punctuation — `"alpha beta|, gamma"` —
is "inside a word" and the whole run `beta,` rides down; pre-VX-806 the settle cut at the NEXT
word's start (`gamma`), keeping `beta,` behind. Within the ruling's letter, one word-notion by
design — but it is a visible divergence at a caret ordinary language wouldn't call "the middle of
a word", and neither the self-assessment's P-828-6 entry nor the canon draft names it for her eye.
Fix: one sentence in the record's P-828-6/QUESTIONS draft naming the punctuation-adjacent caret.
No pin (documentation; the behavior itself is the ruled one under the stated word notion).

**[NIT] · App/Variorum/Shared/RecoveryCopy.swift:872 (`deleteEmptyBlocksNothingLeft`) · The race
refusal's sentence over-claims.**
Evidence: "None of those empty blocks are in the Trash any more — nothing was deleted." also
covers the race where a block is still IN the Trash but stopped qualifying (a sync apply wording
a take or landing a comment in the confirm's pause — the op's `qualifying` re-read, not the
listing's). The words are PROVISIONAL P-828-10 and hers to tune.
Fix: carry this case to her wording pass at the handoff (e.g. "…aren't empty-with-no-history any
more…"). No pin (copy).

**[NIT · SPECULATIVE] · App/Variorum/Variorum/Core/Views/WingSwitcherMenu.swift:175–177 · The
▾ list's pick of the CURRENT wing may be a dead door under P-828-1 (ii)(a).**
Evidence: the ruling makes a deliberate pick of the current row land in its Bookcase on every
switcher door, and the brain/sheet/chord now honor it — but the ▾ list's door is a SwiftUI
`Picker` binding (`set: { wings.goTo($0, saying: false) }`), and a Picker's setter firing when the
already-selected row is re-picked is framework behavior I cannot trace in this repo; if it does
not fire, this one door silently does nothing on the identity pick. SPECULATIVE accordingly — a
walk observation, not a traced bug.
Fix: add "▾ list, re-pick the CURRENT wing → its Bookcase" as a micro-leg beside the merge-gate
walk's already-deferred ▾-list witness (6d9c383ad's deferred list); if dead, either give the
current row a Button face or record the exception against the ruling. No headless pin possible
(framework event delivery).

**[NIT] · App/Variorum/VariorumTests/QuickEntryWingLabelTests.swift:85 · The 2,400-char source
window is one comment away from a false red, and batch B already paid it once.**
Evidence: the window-part-1 red #2 was this pin misfiring because a 5-line comment above the
toolbar item pushed `.lineLimit`/`.help`/`.sharedBackgroundVisibility` past the window; the fix
DELETED the source comment to appease the pin (8b8a2b31a), and the record itself says "about 80
chars of headroom now; a later touch there should widen it". Adjusting production source to fit a
brittle test window is backwards.
Fix: widen the window (or anchor the scan to the item's closing brace) in a later touch — the
record already owes it; filing it here so it doesn't evaporate. No pin (test hygiene).

---

## ROUND 1 FINAL CALLS (cross-model flow — the implementer's agree/dispute returned; the
reviewer's call, 2026-11-05)

**MINOR 1, part (a) — re-word the two docs: CONFIRMED as agreed**, with one addition now owed by
part (b)'s recheck: the wording must carry the CORRECTED mechanism — `LibraryPlaceScrollMemory` is
per-mount `@State` (`LibraryPlaceScroll.swift:137`), so R-C4's `memory.window.isMeasured` guard
read a MOUNT-LOCAL window, and what fed it in window 2 was the hosted mount's own unavoidable
scroll reading — not, as the window-2 record argued, a window persisting across the trip (that is
the model-held `placeMemory.windows`, which the guard never reads). Append a one-line correction
BESIDE the record's "WINDOW 2, R-C4 HOLLOW" section pointing here; the window log itself stays
verbatim (the night's record is never rewritten).

**MINOR 1, part (b) — the trigger-order assertion: WITHDRAWN; the dispute is CORRECT, and the
implementer's seam counter-proposal is CONFIRMED as the fix shape.** Both failure modes were
re-traced by the reviewer against `LibraryPlaceScroll.body` and verified concrete:
- FALSE RED on the fix: at mount with the height not yet reported, `landIfReady("appear")` is a
  no-op (viewport 0); whether the height report or a scroll reading fires next is the framework's
  order, and a reading-first mount lands from `"reading"` on CORRECT code — the assertion pins
  callback order, not the mechanism.
- FALSE GREEN under R-C4: a reading arriving BEFORE `onAppear` measures the mount-local window
  without landing (no proxy yet — no `land(...)` line), and `onAppear` then passes R-C4's added
  guard and lands from `"appear"` — the assertion passes under the revert. Hosted mounts do send
  a reading, so the road is reachable.

**The CONFIRMED fix (the implementer applies):** a DEBUG-only seam,
`LibraryPlaceTrace.withholdsReadingsUntilAim` (default false; production unaffected — the
`SidebarSectionWindow.phaseSeam` precedent, batch D's ruling-8 internal-seam class), gating
`LibraryPlaceScroll.reading()`: while on, a mounting pane receives NO scroll reading until its
landing has aimed — the live no-reading mount PLAYED deterministically. Constraints the gate must
honor: (i) while withheld, nothing feeds `memory.window` or `placeMemory.noteWindow` (else R-C4's
guard is fed again); (ii) after the first aim, readings flow, so the hold's settle checks still
confirm the row (`check()` needs a measured window); (iii) `decide()` is still reached at
`onAppear`, so the owed landing is still decided. The road pin's RETURN leg turns the seam on
(and restores it off — the default — after).
**The pin and its red:** revert R-C4 (`landIfReady` re-gated on `memory.window.isMeasured`) under
the seam → no reading ever feeds the guard → never lands → both road arguments red at the top;
restored → green (the fix lands from appear/height). The red-show rides the merge-gate stage
window (uncommitted revert, `git checkout --` restores). **R-C4b must NOT be cited for this pin**
(with the appear/height triggers disabled, the relisted trigger still lands on the pane's own
height) — the re-worded doc says so.

**MINOR 2 (ledger rows): dispositioned OVERTAKEN above — no action.**

**NIT (QuickEntryWingLabelTests window): CONFIRMED as agreed** — 2,400 → 4,800 with the comment,
the no-later-navigation-item check done.

**The remaining NITs** (the P-828-6 punctuation-adjacent-caret sentence; the P-828-10 refusal
wording to her pass; the SPECULATIVE ▾-list current-row micro-leg at the merge-gate walk) stand as
written — record/handoff/walk items, the orchestrator carries them (already dispositioned in the
run record at e6215aef9).

---

## Verification debt (not findings — named so the ladder's close is not misread)

Restated against 6d9c383ad (the mid-round B+E verification: suites 120/13 with one order-isolation
flake green alone, all eight reverts red on their asserted lines, the walk's primary B/E legs green
both voices). The record is honest about all of these; the merge gate must see them done, and this
round's clean bill does NOT cover them:
- **The merge-gate walk's deferred legs** (each pin-covered today, per 6d9c383ad): batch C's seven;
  B's ⌘L-sheet / ▾-list / masthead-cycle landing witnesses, the Library-search-field chord, the
  snippets-EDITOR chord, the label's seam drag / sub-24-pt floor / full screen / first-frame flash,
  the ⌘/ helper rows; E's menu-group glance, the capture-box chord, and the two Settings legs
  (VX-838's live follow, VX-840's live sweep — the husk-tag fixture stands ready).
- **Batches A + D:** the phone suites at the merge gate (Shared/ changed).
- The merge gate's standing items: main ≥ be17fb632 merged in first; `TagUsageQueriesTests` +
  `CapabilityRegistryTests` + `ShellChromeTests` re-run by whoever merges second.

---

## Clean bill (checked and found solid)

- **VX-806 (editor seam).** `BoundarySnapping.wordStart` is correct and total: strictly-interior,
  grapheme-aligned, non-whitespace on both sides; the answer is always a member of S4-22's legal
  set and strictly BEFORE the caret (every interior boundary has whitespace before it, so the word
  always rides down whole); the blank-prefix → start-arm fall-through matches the scanner's
  leading-run-starts-no-word design. `TypedReturn.act`'s arm ordering preserved every prior road
  (list door first, ⇧⏎, chip off, selections, tail, whitespace arms — guard pins green on both
  sides); `plan(divideAtExactCut:)` shares `frontRefusal` byte-identically with the menu entry and
  takes only a legal interior cut (else the menu's settle); the fanned road verified end-to-end:
  `.divideW` → `applyStructural(ceremony: false)` → `runKeepOnTopDivide(activeCut:)` with the
  exact cut as the displayed take's seed. The core pins' exact values re-run green by this
  reviewer. Re-pointed pins (#92(b) supersession; `NestedListDoorTests`) all carry justified,
  accurate annotations.
- **VX-655.** The claim no longer mutates; it decides against the unretracted surface (trailing
  whitespace is the end — the same `.emptyBlock(.below)`); the act names its block so a
  claim-to-act click can never point the retraction elsewhere; `listContinuationRetraction` is a
  pure read with the full guard set; the op-body `autosave` refuses first on a sealed/locked/
  archived take (verified at `editableVariant`, `Operations+Variant.swift:545` — the
  partial-failure window is behavior-par with the old road and spoken); the order pin holds the
  writer and asserts the claim-turn, mid-flight and landed bytes exactly; #94's undo story is
  pinned whole (text stack cleared, one "New Block" entry, the R2-3 double-registration gap closed
  by subtraction).
- **VX-800.** The predicate's six readings match R-828-1 and the fork's ruling exactly (any-row
  counts proven load-bearing by mutation probes M1–M3); the candidate set reuses `Queries.trash`'s
  block arm (window, wing fence, intent fence, cascade-victim exclusion inherited, never twinned);
  the op is one transaction, re-reads inside it, takes confirm ∩ still-qualifying, mints intents
  only through `mintPurgeIntents` — S2's one bend honored, no raw DELETE, no undo entry, no
  touch/churn; the empty answer writes nothing (pinned incl. the outbox). The door is
  registry-declared, drawn only at count > 0 (P-2), confirmed every time; the pick belt and the
  notes-only `forgetLocalMemories` asymmetry are both right (blocks carry no per-note memories).
  The held observation re-fetches on a reader (VX-670's discipline) with a `now` posture identical
  to the listing's own.
- **VX-636.** The mechanism is real (overlay claims no layout room) and the fix is the laid-out
  band with ArchivedView's precedence order, `library.lastError` included as before; the `.quiet`
  arm follows the Pool's seam-hosting precedent; the DEBUG probe and the ruled `model:` seam are
  clean.
- **VX-823.** The pure brain's capture/resolve/anchorY/isSettled/depth are correct (fallback order
  below-first at a tie; the opened row deliberately not an anchor per the ruling; `Order` is
  lookups, never a listing copy — P1); the model's drop roads match the ruling (new question, wing
  switch; mode switch flagged PROVISIONAL in the record as it must be); per-pane memory reached;
  the landing reads nothing and the re-ask is depth-bounded (Q5 as ruled); no `.scrollPosition`
  binding exists anywhere in the Library (the 18l-c U8 trap genuinely designed around); teardown
  cannot note a place (the liveness guard); `endRestore` always runs (no stuck-restoring road);
  the hold is budgeted and her hand ends it. Every row-open door routes through `rowOpened` with
  the right `marks:` value (cards/scraps/block lines markless).
- **VX-824/833/844.** The chord classifier is exact (⌘ alone, one digit, keyDown only); the
  writing-surface gate matches the Q-B1 (a) ruling and the registry availability mirrors the mode
  row; refusal words as drafted; `goTo` is the ONE deliberate road and the never-lands list
  (follow, mint, delete, revalidate, Compare, MCP) is untouched by construction (none call it);
  the brain's `.commit(current)` re-points are justified and annotated; the label's space rule,
  placement, probe and marquee honor P-8 (no clock while it fits; cancellable task; Reduce Motion
  still; hard clips, no ellipsis); the two edges (24-pt floor, hidden sidebar) are as ruled.
- **VX-798.** The one-shot property is structural (no selector writes a checking flag; the three
  AppKit toggles deliberately absent — the TEXTKIT2 §3 pairing protected); responder-chain
  dispatch with no explicit `to:`; the refusal speaks on P-2; the collision sweep is recorded at
  the declaration and pinned as data; the menu group sits after Find with the two items only.
- **VX-838/VX-840.** The wing-follow fix is RootView's own idiom with the name read in the SAME
  observation as the list (the header can never name another wing); `deleteUnusedTags` is one
  write on one stamp through `deleteTag`'s own subtree body with the in-write worn + wholly-
  confirmed guards (each proven load-bearing by M-E1…M-E3), one "Delete Unused Tags" entry on
  VX-247's machinery gaining only a label; `unusedTags`' downward-closure optimization is sound
  (worn is subtree-honest, pinned tag-by-tag) and the column-narrowed region covers every table
  the vendored brain's `.library` arm reads (verified against the brain's SQL: tag, post_tag,
  block_tag, container/block/wing at (id, deleted_at) only); the linked boxes encode exactly
  deleteTag's reality and the act deletes exactly the checked set.
- **Process.** Pin-before-fix held per member (behavioral reverts named before running, mutation
  probes announced before run, the one hollow pin RECORDED as hollow rather than cited); commits
  are per piece with no `Co-Authored-By`/`Claude-Session` trailers; the two-file rule held (canon
  and QUESTIONS untouched; all deltas drafted in the record); no `Sync/`, custody or keychain
  file anywhere in the diff; the vendored seam is byte-identical to its owner's mint with
  provenance in the commit.
