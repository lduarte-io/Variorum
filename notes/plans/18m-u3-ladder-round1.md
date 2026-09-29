# 18m U3 — COLD REVIEW, ROUND 1 (Fable, 2026-09-29) — COMPLETE

**Scope reviewed:** `git diff 60a0f47a..6c36cdd5` (the U3 mechanical window; code last changes at
`833947a6`, records after), against the 18m plan's U3 BRIEF + CLASSIFICATION RULING, MobileSoul
§3/§4 item 4, AppSpec §9, KnownIssues row 28, QUESTIONS #159. Every production file in the diff
read in full; the three new pin files and the three sanctioned edits read in full; no "Review
foci" section exists in the plan or charter (checked), so the coordinator's standing focus —
the §4.4 no-platform-door-words law — is addressed in the clean bill.

**Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT.** The unit is sound: the hoist is
byte-identical where it claims to be, the collapse's word changes are exactly the ruled set,
the §4.4 law holds by compile-time target membership AND the string-level tripwire, and both
platforms' new pins verify green in this reviewer's own runs at HEAD.

## FINDINGS (severity-ranked)

### F-1 · MINOR · `App/Variorum/Shared/VersionActs.swift:112` + plan U3 RECORD STEP 1-C + KnownIssues row 28 (c) + QUESTIONS #159(1)
**What:** the sealed-family enumeration the ruling rests on is incomplete — `VersionActs.words`
(a SHARED-home `OperationError` refusal switch, compiled into both app targets) carries the Mac
door verb in *"This note is marked complete — unseal it to restore a version."* and is absent
from all three enumeration homes: the U3 RECORD's family quote (STEP 1-C), row 28 (c)'s
next-touch list (which names the `DeletionRefusal`/`RecoveryCopy.sealedPutBackRefusal` pair,
`CanvasViewModel`, `MobileQuickNoteCopy` — not `VersionActs`), and #159(1)'s "not yet touched"
list. The ruling's premise is *"the family's remainder is LISTED in row 28's (c) entry"* so her
one ruling can extend the reach — an unlisted member means that ruling would silently miss it.
**Evidence:** `grep -rn "marked complete" App/Variorum/Shared/` → `RecoveryCopy.swift:448`
(enumerated) · `RecoveryActs.swift:180` (enumerated) · `VersionActs.swift:112` (nowhere);
`grep -rln "as? OperationError" Shared/` → exactly `OpsRefusalTable`, `VersionActs`,
`RecoveryActs` — three shared refusal switches, the enumeration covers two.
**Class:** record/enumeration completeness — no red-on-old pin can pin a missing list row;
honestly NOT bug-class. **Fix:** one line in row 28 (c)'s sealed-family remainder + one clause
in #159(1)'s "not yet touched" list naming `VersionActs.words`'s seal line.

### F-2 · NIT · `notes/KnownIssuesAndTechDebt.md` row 28 (c)
**What:** the (c) entry still reads *"HOISTED at 18m U3 (2026-09-29; collapse and finals
PENDING in the 18m U3 RECORD)"* at the window's close — the collapse landed (commits 3–4) and
the finals ran (`61f3a98e`); the PENDING mark is stale. **Evidence:** the row's final state in
the diff vs the U3 RECORD's LIVE STATUS (all DONE). **Fix:** flip the parenthetical to the
landed truth (one line; naturally F-1's same touch).

### F-3 · NIT · `App/Variorum/VariorumTests/SavepointNamingTests.swift:373`
**What:** `writesDoorAndFilerSpeakOneSealSentence`'s doc comment still names the deleted
`operationMessage`. The implementer flagged this deliberately (keeping the test diff to exactly
S-1/S-2/S-3); confirmed as the one-line doc NIT it is. **Fix:** reword to name the table;
comment-only.

### F-4 · NIT · locked-TAKE sentence family, unenumerated (record-class)
**What:** the unit's own doctrine — enumerate the family you leave — was applied to the seal
family but not to its smaller sibling: the locked-take sentence now ships in four Mac spellings
plus the phone's — the table's *"That take is locked — unlock it or branch a new take."* ·
the gate static `EditorViewModel.lockedTakeGateRefusal` *"…branch it or unlock it to edit."* ·
the planner's `RefusalCopy` :23 *"…branch it or unlock it first."* · `EditorFind` :103 *"That
match is in a locked take — …"* · the phone's `lockedTakeRefusal` (⑂ road). None is false at
its door and each is a different voice (gate/planner/find/table), so nothing converges here by
this unit's charter — but no enumeration anywhere records the family for a future one-ruling
convergence the way the seal's does. **Evidence:** grep over production (the five spellings
above); row 28 (c) and #159 name none of them. **Fix:** one enumerating sentence in row 28 (c)
(or a #159 sub-clause); zero code.

## CLEAN BILL (what I specifically checked and found solid)

1. **The §4.4 law, three layers deep (the unit's charter and this review's backbone).**
   (a) Target membership verified in the pbxproj: `Shared/` is a fileSystemSynchronizedGroup of
   BOTH app targets; `Variorum/` (Registry, the Mac half) Mac-only; `MobileRefusalRoads.swift`
   mobile-only — "the phone cannot name `.mac`" is a real compile-time fact. (b) The shared
   file's literals read in full: no chord, no door name, no platform name; the seal noun/verb
   arrive only as `SealedNoteCopy.Words` values from each platform's own target; the two chord
   slots (`divideChord`, `arrangeTakesRoad`) are nil on the phone and the sentences end at
   facts true on both platforms (keep-on-top per U-2; AppSpec §9 confirms it is both platforms'
   default). (c) The tripwire (`OpsRefusalTableIntegrityTests`) walks the shared file's string
   literals with the house extractor (comments skipped — verified against the extractor's
   implementation; `\u{…}` escapes kept, which is why the vocabulary bans both glyph and escape
   forms), bans both platforms' door/chord vocabularies by name, and its bite test proves
   non-vacuity against each platform's real home. Verified green in my own run.
2. **The hoist's byte-identity (3C).** The hoist commit (`59715238`) touched zero test files
   (git show --stat). Every moved sentence compared old-vs-new in the diff: byte-identical,
   including the recomposed road parentheticals (`.fannedBlock` "(⌥⌘⇧D arranges them
   differently)." and `.lastActiveVariant`'s "(⌘⇧D)"), the `\u{2014}`/`\u{201C}` escapes, and
   the fallback chain (`macWords ?? shared message` ≡ pre-hoist: worded → "Refused: …" →
   `String(describing:)`). The Mac gate forward's `fanRoads: CrossBlockRefusal.macFanRoads` is
   exactly what the old no-argument call resolved to (`CrossBlockRefusalRoads.swift:31`'s
   convenience) — zero behavior change on `.crossesBlockBoundary`.
3. **The collapse's word changes are exactly the ruled set.** Test-target footprint over the
   window: 3 new files + exactly S-1/S-2/S-3 (my own diff stat) — each sanctioned edit is the
   ruled sentence, with the ruling cited at the edit. `operationMessage` has zero production
   references left (comments only). The four Write sentences the table gained
   (`bufferChangedSinceGesture`, ceremony trio) and the two both-platform sentences
   (`invalidCut`, `invalidCommentText`) are byte-identical to their sources.
4. **No latent red outside the finals' 61-file selection.** The finals were grep-chosen files,
   not the full Mac suite — so I swept BOTH whole test trees for every changed literal (the
   old seal spellings, the old Write voice's five sentences, both old fallback forms) and for
   dump-form assertions: the only Mac hit is `CommandRoutingTests:306/308`, an injection-echo
   FIXTURE of the status seam (asserts what it injects — rides by construction); every
   "Refused:" assertion in either tree is NEGATIVE (`!hasPrefix`), which the collapse only
   makes greener; every phone "locked — unlock" literal is the phone's own unchanged
   vocabulary. No unedited pin asserts a changed sentence.
5. **The phone's seal words changed nowhere.** `MobileUndoDoor`'s retired `.lockedPost` arm ==
   the table's phone words byte-for-byte ("This note is locked — unlock it first."); the gate,
   comments, block-menu and structural arms compose the same sentences they shipped
   (`SealedNoteCopy.sentence(act:words:.phone)` reproduces `"This note is locked — unlock it
   to \(act)."` exactly); `theSealStaysInThePhonesOwnDoorWords` guards them.
6. **O-1 (a) is the mapping line only.** `EditorEditRoute.swift` is untouched by the window
   (diff file list); the change is `.refuseAwaitingSync`'s one `refuse(...)` line onto
   `CrossBlockRefusal.message(for: .unsyncedBlock, …)` whose cause/road clauses compose the
   Mac's exact sentence (read in `CrossBlockRefusal.swift`); S-3's pin computes from the same
   function. U1's arm set and order stand.
7. **FORK L-c's mechanics.** The one core guard (`ensureNotLastActive`) does serve archive,
   delete and move-out; the new sentence carries both riding pins' fragments — verified against
   the pins' actual literals (`TakeStructureDoorTests:279` "only one take",
   `EditorSessionTests:733` "keeps at least one take") — and the convergence pin exercises BOTH
   doors (⌘⇧A and E5) end-to-end against the store. Copy itself is PROVISIONAL in #159, as
   ruled.
8. **Green claims re-verified by my own runs at HEAD** (records-only commits after the window —
   checked): Mac `RefusalTableConvergenceTests` + `OpsRefusalTableIntegrityTests` +
   `SavepointSealedDoorTests` + `TutorialLibraryActsTests` → **23 tests / 4 suites PASSED**
   (matches the record); phone `MobileRefusalTableTests` + `MobileWholeBlockDeleteTests` on the
   iPhone 17 Pro simulator → **21 tests / 2 suites PASSED** (matches the record). Walk evidence
   spot-checked with my own eyes: `terminal/04-R1-sealed-cmdS.png` shows the ruled stem *"This
   note is sealed — unseal it first."* toasting under the sealed banner.
9. **Fences and hygiene.** Zero `Sources/`, `Sync/`, schema in the window; zero trailers on all
   eleven commits (checked `git log --format=%(trailers)`); QUESTIONS #159 lands whole (four
   spellings + flips (b)/(c) + FORK L + O-1 + the ranking sub-item, next free #160); the walk's
   dev-store residue and the row-73 crash-reporter window are honestly recorded for her bundle.
   Nothing in the diff copies text across entities or scales with corpus size (the source walks
   read one file each).
10. **The R-PHONE unpredicted red's mechanism** (the revert emptying the default arm that the
    undo door's seal now rides) is coherent with the code as landed — the guard biting on a
    wider-than-predicted revert, not a hole.

**Round-1 disposition: no BLOCKER/MAJOR → per the ladder rule this is a one-round unit unless
the implementer's response surfaces something new. F-1/F-2/F-4 are record-line fixes and F-3 a
comment line; all four are dispute-eligible but none blocks.**

## DISPOSITIONS + FIXES (the reviewer's final call, 2026-09-29 — ROUND CLOSED)

**The implementer's response: AGREE on all four, ZERO DISPUTES** (with fix leans, and on F-4 a
WIDER family than my five — nine members by its grep). **Final calls: all four CONFIRMED.**
Per the cross-model flow and the coordinator's explicit authorization, the fixes are the
reviewer's own, landed in this session:

- **F-1 (MINOR) — CONFIRMED, FIXED `31b52f22`.** Row 28 (c) now names `VersionActs.words`'
  seal line beside the `DeletionRefusal`/`sealedPutBackRefusal` pair, stating the deep edge
  plainly per the orchestrator's note (a SHARED home carrying a Mac door verb the PHONE
  COMPILES, latent only for want of a Versions face — PL-29 verified against MobileSoul's
  parity ledger before citing); QUESTIONS #159 (1) gains the versions-door clause; the U3
  RECORD's STEP 1-C carries a dated correction note (attributed, never silently rewritten).
- **F-2 (NIT) — CONFIRMED, FIXED `31b52f22`.** The stale "collapse and finals PENDING"
  flipped to the landed truth (five commits; Mac 1,145/144; mobile 654/112).
- **F-3 (NIT) — CONFIRMED, FIXED `d36d57ae`.** Comment-only: the consequence line names the
  table's `lockedPost` line (`SealedNoteCopy`) instead of the deleted `operationMessage`, and
  the same doc block's two quoted sibling refusals now read their landed "unseal" spellings
  (same staleness class, same comment, zero logic).
- **F-4 (NIT) — CONFIRMED, FIXED `31b52f22`, ADOPTING the implementer's WIDER enumeration.**
  Hallucination guard honored: all nine members re-verified against the tree by this reviewer
  before landing (ReadEditPane's `.help` state line; `MobileTakesBrowser`'s
  `lockedTakeCardRefusal`/`lockedTakeVerbRefusal`; `MobileQuickNote`'s state line; the file
  strings read at their homes). Home: row 28 (c), as the implementer argued — #159 asks her
  nothing about this family today. Zero code.

**Fix protocol note, stated honestly:** all four are record/comment-class — no red-on-old pin
exists for a list row or a doc comment (declared in each finding at round 1); the pin-before-fix
rule therefore does not bind them, and none touches behavior.

**Confirmation run (cheapest honest):** `SavepointSealedDoorTests` +
`RefusalTableConvergenceTests` + `OpsRefusalTableIntegrityTests` after the fixes —
**15 tests / 3 suites PASSED** (the comment-only edit compiles; every riding pin green).
Docs edits are read by no test (the tripwire walks `Shared/OpsRefusalTable.swift` only —
untouched).

**ROUND 1 CLOSED: 0 BLOCKER · 0 MAJOR · 1 MINOR · 3 NIT — all agreed, all confirmed, all
fixed (`31b52f22` + `d36d57ae`, pushed, no trailers). No new BLOCKER/MAJOR ⇒ no round 2 by
the ladder rule; the implementer's sanity pass over the two fix commits is the remaining
cross-model step (the coordinator's to spawn).**
