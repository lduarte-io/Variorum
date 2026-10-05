# Phase 19 — Standing Fixes (STANDING PLAN, the second ledger)

> **This phase does not close.** It is the successor ledger to Phase 17, opened at the author's
> word on 2026-10-04, the night 17's alphabet filled (17z took the last letter): *"we don't have
> phase 19 right now, right? make a note that future small issues like the 17 rounds should start
> filling up phase 19 a–z now."* Its **entries** (19a, 19b, … 19z) are what open, run, and close —
> the phase itself stays open for the life of the project. A closed entry is never reopened; a
> recurrence gets a fresh letter.
>
> **Every rule from Phase 17 binds here unchanged** (the philosophy and the stated rules at the top
> of `notes/plans/phase-17-standing-fixes.md` are the canon; read them before opening an entry):
> product advancement never lands here; the master plan carries one pointer row; each entry is
> scoped, cast, run and closed on its own; pin before fix with red-on-old verified by revert; an
> Opus cold review is mandatory per entry, a Fable one whenever the diff touches `Sync/`,
> custody/keychain or the editor seam (the author may waive); a standing-fixes entry is a valid
> KnownIssues owner. **Phase 17's own OPEN entries (17r, 17s, 17w, 17x, 17y, 17z and the 17e
> residue) still run and close in THEIR file** — only NEW entries land here.

## The entries

| Letter | Subject | State |
|---|---|---|
| a | Xcode 27 / Swift 6.4: the TEST-target + mobile migration (the 13r toolchain census's 28 non-app errors) | **CLOSED 2026-10-04** — round 2: no BLOCKER/MAJOR (2 MINOR record-scope, dispositioned into the lesson/19b/19c; 1 NIT next-touch); every target green under Xcode 27 |
| b | Xcode 27 / Swift 6.4: the MOBILE test-target migration (19a round-1 finding 2's census; CopiedRow unified to ONE source, three consumers) | **CLOSED 2026-10-04** — round 1 CLEAN BILL (no BLOCKER/MAJOR/MINOR; 2 record-scope NITs dispositioned); 6 sites fixed, mobile 62/14 green |
| c | The Xcode-27 residue census: silent vacuous-#expect candidates (19a NOTICED #6) + the test-side isolation warnings, Mac AND MOBILE (#7, widened at 19b's close) | **CLOSED 2026-10-04** — round 1: the entry's arms CLEAN (263 REAL, 0 vacuous, 1 recorded; isolation 43→0); the 1 MAJOR was the RECORD's false `#require` clearance → corrected, class routed to 19d |
| d | The compiler-flagged never-failing checks: the `#require` silent-nil class + the always-true comparisons (PostureSwitchDrill:621, SyncEnrollment:262) — 19c round 1's F1+F2 | **CLOSED 2026-10-04** — round 2: no BLOCKER/MAJOR (2 MINOR + 1 NIT, record/method scope, dispositioned); the 187-hollow reclassification CONFIRMED by the reviewer's own true-nil mutant; tripwire 0, zero redundancy warnings, all suites green. **THE LEDGER PARKS until 13r closes** (record-and-queue only) |
| e | The runbook's repo copy drifted from the shipped text: `notes/DataSafetyRunbook.md` line 291 still says "on your shelf" where `DataSafetyCopy.runbook` has said "on your Bookcase" since 13i-d U6 (`827da96c`) — `DataSafetyRunbookTests.theShippedRunbookAndTheRepoCopyAreOneDocument` red. Found by 13r U3-A's finals (2026-10-04), PRE-EXISTING (confirmed at `138ac723`, before any U3-A line). The fix: the one-line repo-doc sync (copy the rendered text the test writes over the repo file), one commit, the pin going green IS the verification; the per-entry Opus cold review per the standing rule (the author may waive a one-line doc sync at her word). | **CLOSED 2026-10-05** (the 17y run's B0, the orchestrator's own hands under the waived-review grant — the architect mandate's small-fixes latitude): the one-word repo-doc sync landed (`notes/DataSafetyRunbook.md` line 291 "on your shelf" → "on your Bookcase"); `DataSafetyRunbookTests` 5/5 green, `theShippedRunbookAndTheRepoCopyAreOneDocument` included — the documented red at the 13r/19f finals IS the red-on-old, the green is the whole verification per her waiver. **Review WAIVED at her word** (the 2026-10-04 evening planning sitting, the question tool) |
| f | The support doors gain THE PRE-DRAFT CHOICE (her #181 (i) ruling, 2026-10-04, the 13r post-close sitting): before ANY draft opens, both doors ask — "Open in Mail" / "Show the file and copy the address" (the plain feedback door the same shape minus the file: "Open in Mail" / "Copy the address"). Closes the measured no-Mail-account dead-end (13r's F-W5: both doors land in Mail's Add Account sheet, no draft, Variorum cannot tell) BY CONSTRUCTION — the second road never needs a mail app (the address to the pasteboard; the report revealed in Finder). Scope: `Features/Diagnostics/SupportMail.swift` + the two door call sites; no send road exists and none is added; words functional (13s re-voices); zero Sync//schema/mobile. Pins: the choice interposes before any compose on BOTH doors (red-on-old: the old shape composes directly); the copy-the-address road lands support@stargazing.tech on the pasteboard and, for a report, reveals the file; the existing draft/attachment pins ride unmodified. Acceptance: pins + a dev-store walk capture of both doors' choice; the mandatory per-entry Opus cold review. | **CLOSED 2026-10-04** — built + walked (both voices, clipboard restored byte-for-byte), pins red-on-old + revert-verified, full Mac 3812/618 green modulo the two named reds (19e, 19g); the Opus cold review 0/0/2/4, every finding dispositioned (two fixed at adjudication pin-first); her #182 (a)–(e) ratified same sitting. **BUILT 2026-10-04** (the 19f RECORD below: both doors ask, red-on-old + revert verified, walked; PROVISIONALs #182) — the Opus cold review is next |
| g | FOUR bare `.fixedSize()` chrome sites with no `lineLimit` — `Features/Shelf/BookcaseStrip.swift:227`/`:342` (13i-d U1, `52262af7`) and `Features/BookView/BookSettingsSheet.swift:521`/`:575` (13i-e U2, `2f3109fe`) — the P-8 b6dae25 class, caught by 13u4 S3's class-closing source-walk pin (`ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy`, red at 19f's full-suite finals; the sites are byte-unchanged since before 19f). The pin IS the red-on-old; the fix is a deliberate line policy per site (`.lineLimit(1)`, or a reasoned `nil`), the pin going green the verification; per-entry Opus review (the author may waive a four-line sweep at her word). Until it runs, a full Mac run reads green modulo TWO named reds (19e + this). | **CLOSED 2026-10-05** (the 17y run's B0, the orchestrator's own hands under the waived-review grant): all four sites took a deliberate `.lineLimit(1)` with the 19g marker comment — each is a one-line chrome piece (the strip's one-line-by-contract chip row, the counts row, the two `lines: 1` VoicedChips); `ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` green — the documented red at 19f's finals IS the red-on-old, the green is the whole verification per her waiver. **Review WAIVED at her word** (the 2026-10-04 evening planning sitting, the question tool) |

---

## 19c — the Xcode-27 residue census (opened 2026-10-04 by the 13r orchestrator; owns 19a's NOTICED #6 and #7)

**Arm 1 — the silent vacuous-#expect candidates (#6).** F1's mechanism has a WARNING-FREE
twin: a `@discardableResult … -> Bool` callee asserted bare takes the same Void route with no
tell. 65 such functions exist in `Sources` + the Mac/Shared app code; the named live
candidates are `MarkdownActsTests.swift:96/123/146/167/191`
(`#expect(MarkdownActs.apply(.bold, to: h.textView))`) and
`BookStructureTests.swift:782/786/793` (`#expect(book.structure.acceptDrop(…`); R2-2 adds the
MOBILE arm — `MobileMarkdownActs.swift:90–91` asserted bare at
`MobileMarkdownTests.swift:389/397/453/551/563` — so Arm 1's universe is `Sources` + the
Mac/Shared app code + `VariorumMobile/`, with the mobile call sites sequenced AFTER 19b (no
mobile test build exists until 19b). **Scope:** enumerate EVERY bare `#expect(F(…))` call
site over a `@discardableResult -> Bool` callee (grep-complete, recorded); settle each
candidate with a red mutant **IN PLACE in the real test target at the EXACT spelling, then
revert — never in a scratch or mimic module (R2-1: the import graph, not only the spelling,
decides the overload; the recorded trigger conditions rank candidates, never clear them)**;
re-spell any vacuous site (explicit type or `== true`) with the mutant red on the new
spelling; a site whose falseness cannot be staged mechanically is recorded, not guessed. **Arm 2 — the isolation residue (#7), WIDENED
to the mobile side at 19b's close:** the warning-grade main-actor reads in seven Mac test
files (`BookViewTests`, `LibraryPanelTests`, `PagedReadTests`, `ReadNoteLandingTests`,
`ReadTierTests`, `TakePaneMeasureTests`, `TutorialWalkTests`) AND in the five mobile test
files 19b's census found (`MobileMarkdownTests`, `MobileTakesBrowserTests`,
`MobileCommentDraftTests`, `MobileCommentParkTests`, `MobileProtectionTests` — 20 warnings;
the per-class table is the 19b RECORD's) get the same test-side `@MainActor`, assertion
bytes unchanged — the F3 class closed file-complete on BOTH platforms before the next
toolchain promotes it to red. **Adjacent residue recorded here, deliberately NOT owned by
this entry (19b round 1's routing):** the 10 deprecated `UIWindow.init(frame:)` sites in 7
mobile test rigs — not mechanical (the replacement needs a window scene); a fresh letter
when a toolchain turns it red. **Rules:** 19a's
(mechanical only; anything intent-changing stops and reports). **Acceptance:** the census
table in the record (site → real/vacuous-fixed, mutant evidence per fix) · zero isolation
warnings left in the Mac test build AND zero in the mobile test build beyond the recorded
not-owned classes (the deprecation class and `MobileProtectionTests:1573`'s unnecessary
`try` — the citation corrected per round 1 F4 — stay recorded, not owed) · the touched
suites green at a quiet window. **Cast:**
`opus-implementer`; Opus cold review. **State: CLOSED 2026-10-04 — round 1 returned a CLEAN
BILL on the entry's own two arms (every settlement independently re-scored; 29 of the
reviewer's own in-place mutants red at their own lines); its 1 MAJOR is against the RECORD's
adjacent `#require` clearance claim, corrected in the ROUND 1 section below and the class
routed to 19d; 2 MINOR + 2 NIT dispositioned by edit; no in-entry code fix landed, so no
round 2 is owed — 19d's own ladder reviews the new class's work.**

## 19c ROUND 1 — the Opus cold review's findings and the orchestrator's dispositions (2026-10-04, same-model flow); THE ENTRY CLOSES

**The entry's own arms: CLEAN.** The reviewer re-ran the route census on its own fresh
builds (TSVs identical), re-scored all 263 settlement rows against the mutant logs by its
own script, ran 29 of its own in-place mutants (all red at their own lines, including every
19a-named candidate), reconciled every count, confirmed the callee-universe narrowing loses
no sites, and re-ran both arms' suites green (Mac 160/23 at a zero-instance window; mobile
106/17). Zero `#expect`/`#require` lines changed in the landed diff. The mutants never
touched `Sync/`; keychain-fact tests clean up in unconditional `defer`s. Reviewer evidence:
`App/Variorum/DerivedData/19c-review/` (kept).

- **F1 [MAJOR] ACCEPTED — the RECORD's `#require` clearance sentence is FALSE, and a real
  silent class sat behind it, unowned.** The reviewer's in-place probes (exact spellings,
  reverted): in a `try? #require(X)` position, or `try #require(X)` where an Optional is
  expected, the compiler picks Testing's doc-private `#require<T>(_ optionalValue: T) -> T`
  (the `NonOptionalRequireMacro`), binds T to the OPTIONAL ITSELF, and a nil X records
  NOTHING at that line — the only tell is the "'#require(_:_:)' is redundant because 'X'
  never equals 'nil'" warning. Proven at `QuickNoteTests.swift:358` (a nil-returning
  `keyEquivalent` mutant: NO issue at 358; only later lines red) and
  `ReadRenderingTests.swift:210/237/349` (same shape, logs `mac-probe-req.log`/`-req2.log`).
  **Census: 38 compiler-flagged sites (Mac 26 · mobile 4 · core 8).** At the four probed
  sites later expectations caught the nil; nobody has checked the other 34. DISPOSITIONS:
  the record's sentence carries an in-place correction note; NOTICED #2's tripwire claim is
  NARROWED (the route census sees `#expect` routes only — require-kind calls sit on the
  Optional route BY DESIGN and are invisible to it; the redundancy WARNING is this class's
  only tell); **the class is ROUTED TO 19d** (opened below — the sizing rule, 19a's F2
  precedent: this entry's session already carried its unit). The warn-free spelling exists
  in the tree (`BookArchiveFacesTests:106` hoists into a `let` first) and is 19d's shape.
  **[CORRECTED AT 19d (rounds 1–2; this note owed since 19d ROUND 1 claimed it existed —
  19d R2-1): the "records NOTHING" and "only tell" sentences above are both too strong.
  Only 19 of the 38 flagged sites were SILENT — the other 18 were HOLLOW (the macro's
  direct-value route records at its own line). And the warning is NOT a reliable tell:
  `NonOptionalRequireMacro` SUPPRESSES it whenever an argument token is `?`, `nil` or
  `Optional` (the open-swift#79202 workaround), which hid the genuinely silent
  `BookAscentTests:803`. The standing method since 19d: the `try? #require` grep tripwire
  AT ZERO, plus token/type sweeps — the 19d ROUND 1/ROUND 2 sections carry it.]**
- **F2 [MINOR] ACCEPTED — `PostureSwitchDrillTests.swift:621` can never fail**
  (`deviceID != nil` on a non-optional `String`; always true since `9f0eceea`, 2026-09-05 —
  pre-toolchain, so not residue). The compiler's "always returns true" warning is
  path-anchored, not in-expansion, so piece 2's filter missed it; the VOID route makes the
  route census blind to it. ROUTED TO 19d with its named twin `SyncEnrollmentTests:262`
  (19a's next-touch orphan — 19d is that touch): the compiler-flagged NEVER-FAILING-CHECK
  family is one entry. Both are custody-drill test files — 19d's cold review carries an
  explicit charge on them (the 19a FurnitureConvergence precedent), and the orchestrator
  verifies those re-spells itself at 19d's close.
- **F3 [MINOR] ACCEPTED — NOTICED #3's lesson was overgeneralized; REWORDED BY THIS BLOCK**
  (the reviewer's counterexample: seven unannotated `findPane` locals directly inside
  `@MainActor` test bodies compile warning-free in the very file the record cites). The
  lesson as CORRECTED, binding wherever it is carried: **a local function declared inside a
  CLOSURE does not inherit that closure's isolation — even when the closure's type is
  explicitly `@MainActor`; a local function directly in a main-actor FUNCTION BODY does
  inherit it.** (Plus the unchanged nested-helper corollary: annotate both.)
- **F4 [NIT] ACCEPTED, corrected by edit:** the record's NOT-DONE (6) says the mutants
  touched "two core Sources files" — `mutants.diff` shows THREE (`Operations+Reading.swift`,
  `StoreEncryptionMigration.swift`, `StoreKey.swift` — the latter two custody code, all
  reverted, none landed); the entry's `MobileProtectionTests:1572` citation is now 1573
  (both corrected above/in this block).
- **F5 [NIT] ACCEPTED as recorded residue:** the Mac test target's remaining 74 warnings
  have no per-class census (19b did one for mobile; the next toolchain entry does the Mac
  twin). Named now as adjacent concurrency-family residue, recorded NOT owed:
  `SendableClosureCaptures` at `NoteDeletionDoorsTests:432` and
  `StructuralGestureTests:1007/1071` — the likeliest to turn red at a future toolchain
  bump; a fresh letter when one does.
- **The reviewer's observation ADOPTED for the record:** the route census reads the overload
  the compiler chose IN THE REAL TARGET (it is not R2-1's forbidden scratch-module
  evidence), so it STANDS as supporting evidence for the one recorded site
  (`AppleKeyRoundTripTests:97`, VOID route) — the site stays RECORDED, not settled: its
  suite writes into her real iCloud Keychain and no session runs it.

**19c IS CLOSED** (opened at 19a's close, closed 2026-10-04; one round; the red-on-old was
each settlement's own in-place mutant).

## 19d — the compiler-flagged never-failing checks: the `#require` silent-nil class + the always-true comparisons

**Opened 2026-10-04 by the 13r orchestrator out of 19c round 1 (F1 + F2).** **Scope, two
families, test targets only:** **(1) the `#require` silent-nil class — 38 compiler-flagged
sites (Mac 26 · mobile 4 · core 8**, the reviewer's census from fresh builds; a FLOOR:
re-census first, counting unique warning lines): every `try? #require(X)` /
Optional-position `try #require(X)` site re-spelled to a shape where a nil RECORDS AT ITS
OWN LINE — the hoisted spelling (`let y = try #require(X)` first, then use `y`;
`BookArchiveFacesTests:106` is the in-tree exemplar) or an explicit `#expect(X != nil)` +
unwrap, whichever preserves the test's abort-vs-continue intent; **a `try?`
record-and-continue site where abort-vs-continue is genuinely ambiguous STOPS AND REPORTS
to the orchestrator** (choosing is test-intent, not mechanics); `FannedDefaultsTests:355`
(a non-optional wrapped — purely redundant) is cleanup. **(2) the always-true-comparison
family:** `PostureSwitchDrillTests:621` (`deviceID != nil` on non-optional; re-spell to a
failable assertion, e.g. `!isEmpty`, red under an in-place `""` mutant) and
`SyncEnrollmentTests:262` (19a's orphan: the dead `!= nil` removed — the `try` carries the
real check). **Rules:** 19a's (mechanical; intent-changing stops), PLUS every re-spell
carries F1's pin discipline — under an in-place nil/empty mutant at the exact call, the OLD
spelling records nothing at its line (the red-on-old is the SILENCE, shown once per shape)
and the NEW spelling records an issue AT ITS OWN LINE; mutants announced in-flight,
reverted, tree clean. **Acceptance:** zero "'#require(_:_:)' is redundant" and zero
"always returns true" warnings in all three test builds, except sites recorded with a
reason · the census table (site → re-spelled-with-pin / recorded) · touched suites green at
a quiet window (mobile on a concrete simulator). **Cast:** `opus-implementer`; Opus cold
review **with an explicit charge on the custody-drill test files** (`PostureSwitchDrill`,
`SyncEnrollment` — assertions must not weaken; the 19a FurnitureConvergence precedent), and
the orchestrator verifies those re-spells by its own hands at the close. **DO-NOT-TOUCH
unchanged from 19b/19c** (13r's staged artifacts, `Sync/`, schema, app source except
nothing — this entry is TEST FILES ONLY). ~~**State: FIXES-IN-FLIGHT (2026-10-04)**~~ — round 1
arbitrated below (1 MAJOR accepted with fixes owed; the hollow cleanup TAKEN at the
orchestrator's call; 1 NIT reword); the orchestrator's own-hands check of 621/262 PASSED
(strictly stronger / abort-preserved) and the round-1 reviewer's independent custody read
agrees. **State: CLOSED 2026-10-04 — round 2 clean (no BLOCKER/MAJOR; 2 MINOR + 1 NIT, all
record/method scope, dispositioned by edit in the ROUND 2 section below); the 187-hollow
reclassification CONFIRMED by the fresh reviewer's own true-nil mutant; the entry closed on
two rounds, and THE LEDGER PARKS until 13r closes.**

## 19d ROUND 1 — the Opus cold review's findings and the orchestrator's dispositions (2026-10-04, same-model flow: the orchestrator arbitrates, the implementer fixes, a FRESH reviewer runs round 2)

**The entry's landed work held:** all 18 hollow scorings re-verified (plus the reviewer's
own probe), all 20 silent-site pin pairs re-scored (old silent at its line, new red at its
own line), the re-spells faithful (types, abort-vs-continue, downstream bytes), the warning
censuses reproduced (Mac 102→83, mobile 47→43, core 30→30, nothing added), the four
temporarily-mutated sources sha256-matched to base, suites green at a zero-instance window
(Mac 205/29; mobile 24/2). **The custody-drill charge is satisfied twice over:** the
reviewer's independent read traced 621's identity paths (the only empty-identity
constructor's one consumer takes `.material` only — the new line fails only on a real
defect) and mutated 262's new spelling red; the orchestrator's own-hands diff check agreed.
Reviewer evidence: `App/Variorum/DerivedData/19d-review/` (kept).

- **F1 [MAJOR] ACCEPTED — TWO MORE LIVE SILENT SITES, invisible to the warning census:**
  `BookAscentTests.swift:803` (`let action = try? #require(center.current?.action)`) and
  `MarkdownFaceTests.swift:187` (same shape over `font(…)?.pointSize`). The mechanism,
  reviewer-traced to swift-testing's source (the one Sonnet lookup, an external fact):
  `NonOptionalRequireMacro` SUPPRESSES its redundancy warning whenever any argument token is
  `?`, `nil` or `Optional` (`#if !SWT_FIXED_137943258`, the workaround for OPEN swift#79202;
  the flag is defined nowhere, so suppression is ON in every shipped build). Both sites
  proven silent by in-place probes (`19d-review/mac-probe.log`); the reviewer's 278-site
  token sweep found NO third (core zero, mobile zero, UITests zero). **So the
  compiler warning is NOT a reliable tell for this class — 19c round 1 F1's "the redundancy
  WARNING is this class's only tell" is FALSE under token suppression (annotated in place),
  and NOTICED #1/#2/#4's warning-anchored census wording is corrected with the fixes.**
  FIX (the implementer): re-spell both in the (R) shape, downstream lines byte-identical;
  pins — the red-on-old is the LOGGED SILENCE under the reviewer's two mutants, and the new
  spellings must go RED AT THEIR OWN LINES under the same mutants.
- **F2 [MINOR] ACCEPTED — THE 18-HOLLOW CLEANUP IS TAKEN (the orchestrator's scope call,
  reversing its own earlier leaning on the reviewer's two new facts):** (1) with the warning
  suppressed by design, the ONLY toolchain-independent tripwire for the record-and-continue
  half is `grep -rn 'try? #require'` AT ZERO — which requires the hollow sites re-spelled;
  (2) the hollow sites are correct only through how `__checkValue`'s `T` binds inside an
  expansion that exists BECAUSE of open swift#79202 (SPECULATIVE and unpinnable, the
  reviewer's own label — removing the dependency costs nothing). These land as CLEANUP
  (behaviour-identical, the `FannedDefaultsTests:355` class; no bug-fix claim, no new pins
  owed — the per-site mutant evidence is already logged), each preserving its site's
  abort-vs-continue semantics. The acceptance line is then met LITERALLY: zero redundancy
  warnings in all three test builds, no recorded exceptions; the grep tripwire is the
  standing census method from here on.
- **F3 [NIT] ACCEPTED — the record's "corroborated by the compiler's own choice" wording
  overstates `routes.py`:** it reads the generic `__check*` symbol, not the type binding.
  Reworded with the fixes: the route the compiler chose; the bindings INFERRED and settled
  AT RUNTIME (the mutants are the evidence). The route-to-behaviour mapping held 40/40.

**[F1 CORRECTED AT THE FIX ROUND — kept beside the original, the custom:** the implementer's
pinning work proved `MarkdownFaceTests:187` HOLLOW, not silent — the round-1 reviewer's
probe (removing the `.font` attribute) never produced a nil, because `NSTextStorage`
re-adds a default 12-pt font; BOTH probe logs show `(headingSize ?? 0) → 12.0`, so the
logged "silence" never tested the site. Under a TRUE nil mutant (the test file's own
`font(_:at:)` helper returning nil for exactly that call) the OLD spelling records at its
own line. The genuinely silent F1 site is `BookAscentTests:803` ALONE, now pinned by the
implementer's own red-on-old; 187's re-spell stands as F2-class cleanup. The
route-to-behaviour mapping is therefore 40 of 41 — **the route census RANKS candidates,
it never settles one** (R2-1's law holding once more, now against a reviewer's probe). The
probe lesson, binding: CHECK THE CAPTURED VALUE first — confirm the mutant really produced
the nil before reading a silence. Round 2 verifies this reclassification independently.]**

## 19d ROUND 2 — the fresh reviewer's verdict and the orchestrator's dispositions (2026-10-04); THE ENTRY CLOSES

**No BLOCKER, no MAJOR — no round 3 earned. 2 MINOR + 1 NIT, all record/method scope,
DISPOSITIONED BY EDIT in this commit.** The disputed reclassification is SETTLED: the
reviewer's OWN true-nil mutant (runs A/B, `19d-r2/mac-runA.log`/`runB.log`) confirms
**`MarkdownFaceTests:187` is HOLLOW** (the old spelling records at its own line with
`(headingSize ?? 0) → 0.0` proving the nil was real) and **`BookAscentTests:803` is the one
genuinely SILENT site** (nothing at its line; downstream catches only), with both new
spellings RED at their own lines. The clean bill besides: every hollow cleanup read
line-by-line (abort-vs-continue preserved, hoists at the original evaluation points, no
name shadowing, downstream bytes identical, the implementer's mutant logs agreeing issue
for issue); the tripwire grep 0 across the five test roots AND `Sources`/`App`; fresh
builds on all three targets — redundancy warnings core 0 · Mac 0 · mobile 0, nothing
added (core 30→22, Mac 102→73, mobile 47→43); touched suites re-run at HEAD by the
reviewer's own build (Mac 218/28 at a zero-instance window; core 61/11, zero skipped);
the fix diff touches no `Sources`, no `Sync/`, no custody file. Reviewer evidence:
`App/Variorum/DerivedData/19d-r2/` (kept; its build products deletable at the sweep).

- **R2-1 [MINOR] ACCEPTED — the annotation 19d ROUND 1 F1 claimed was "(annotated in
  place)" did not exist:** the bracketed correction now sits beside 19c ROUND 1 F1 (this
  commit), saying what it owed — 19/38 silent, 18 hollow, the warning NOT a reliable tell
  under token suppression, the grep tripwire the standing method.
- **R2-2 [MINOR] ACCEPTED — the completeness sweep's CONCLUSION holds; its METHOD had
  three holes the record presented as sound** (corrected by the bracket beside the record's
  sweep bullet, this commit): the STMT class keyed on a same-line regex (missing
  continuation-line arguments and implicit closure returns — `TypewriterRoomTests:269`,
  `TutorialBooksChapterTests:669`); the token filter ran on a 100-char-truncated column
  (missing `DivideKeyMonitorTests:103`); the LET-class `!` reasoning was BACKWARDS (a
  postfix `!` NEEDS an Optional — exactly the silent binding; vacuous today at 0 sites).
  The reviewer settled the missed sites BY TYPE (269 → `.convert` forces unwrap; 103 → a
  non-optional `NSEvent` return; 669 → unconstrained, the more-specific unwrap wins and a
  silent binding would have warned) and re-swept all 2797 sites by its own script: **NO
  third silent site — the conclusion stands on the corrected method.** If `reqpos.py`
  serves a future census it must classify by the true statement start and filter the FULL
  argument.
- **R2-3 [NIT] ACCEPTED — two stale "orchestrator's check owed" lines** in the record now
  carry their DONE brackets (this commit): the own-hands 621/262 verification PASSED at the
  round-1 arbitration and the round-1 reviewer's independent read agreed.
- **The reviewer's ranking observation, RECORDED as a ranking aid only (never a
  clearance):** the silent sites all END in a member whose own type is Optional; at 187 the
  terminal `pointSize` is non-optional and the nil came from the chained base. Only a
  real-nil mutant settles a site.

**19d IS CLOSED** (opened and closed 2026-10-04; two rounds; the red-on-old was the logged
SILENCE per silent site and each hollow site's own-line record). **THE 19 LEDGER PARKS for
the remainder of 13r** (the refocus commitment in the 13r plan's LIVE STATUS): new findings
are recorded and queued here, never run, until 13r closes.

---

## 19a ROUND 1 — the Opus cold review's findings and the orchestrator's dispositions (2026-10-04, same-model flow: the orchestrator arbitrates, the implementer fixes, a FRESH reviewer runs round 2)

- **F1 [MAJOR] — `CatalogDetailWordsTests.swift:45` is VACUOUS under Xcode 27 — ACCEPTED,
  ORCHESTRATOR-CONFIRMED by the decisive check run by my own hands** (line 45's argument →
  the provably-false `.tag("")`: the suite stayed GREEN 2/2; file restored, tree clean).
  Mechanism per the review (from Xcode 27's `Testing.swiftinterface`): a bare implicit-member
  `.tag(…)` argument in function-call shape routes the `#expect` expansion through
  `__checkFunctionCall` with R = Void — the Bool is discarded (the compiler's own
  "unused result" warning IS the tell) and the check passes on `.some(())`, unable to fail.
  **The orchestrator's earlier settlement (`e57fbb4c`) is WITHDRAWN:** its probe substituted
  `.legacyProfile` for the trigger spelling `.tag`, which changed overload resolution — the
  probe proved a DIFFERENT instance real. The lesson, binding on future settlements: **a
  settling probe must reproduce the EXACT trigger spelling, or prove the substitution
  resolution-equivalent** *(AMENDED at round 2, R2-1: and it must run IN PLACE in the real
  test target — the import graph also decides the overload, so a scratch/mimic module can
  clear a vacuous site wrongly even at the exact spelling)*. FIX (the implementer, in-entry): re-spell line 45 with the explicit
  type (`RuleTerm.tag("t1")`) or `== true`; land the review's mutation pin discipline (the
  `.tag("")` mutant must go RED on the new spelling — it is GREEN on today's); correct NOTICED
  #1; record the census rule — an unused-result warning inside an `#expect` expansion means a
  vacuous expectation until proven otherwise (and a `@discardableResult` callee takes the same
  path with NO warning — the review's named blind spot).
- **F2 [MAJOR] — the mobile TEST target does not compile and nothing owned it — ACCEPTED,
  ownership gap real; ROUTED TO 19b** (below) rather than extending this entry: the
  orchestrator read the review's own continue-after-errors log (`mobile-bft-2.log`) and the
  class reaches **~61 sites across ~25 mobile test files** (the review's six were the
  first-failure floor) — a full unit of its own by the sizing rule, and this entry's session
  already carried one. 19b carries the census, the same rules, and the CopiedRow unification
  question.
- **F3 [NIT] — `LandingAuthorityTests.swift:54–59`, the ISOLATION class as warnings —
  ACCEPTED: fix in-entry now** (the same test-side `@MainActor`, assertion bytes unchanged;
  one toolchain promotion from red is exactly what this entry exists to prevent). The
  review's app-side root note (nonisolated types with default-isolated extensions) is
  recorded here, no fix owed in a test-migration entry.
- **F4 [NIT] — the CopiedRow doc comment's duplicate-column claim is half-true — ACCEPTED as
  the COMMENT NARROWING** (both twins: case-variant duplicate names unsupported; every live
  site reads single-table rows with unique names). The case-insensitive rebuild is NOT
  implemented (zero live sites — over-build); the one-source-many-targets unification rides
  19b, which adds the third consumer.
- **Out-of-entry note recorded:** `SyncEnrollmentTests.swift:262`'s `!= nil` on a non-optional
  `SymmetricKey` is dead weight (the `try` carries the real check) — remove at the next
  legitimate touch of that file; no fix owed here.
- **The clean bill acknowledged:** the convergence suites' assertions proven unweakened by the
  review's three red mutations; CopiedRow↔Row parity independently re-verified; the authorized
  pin independently confirmed discriminating; every acceptance claim checked against its log.

## 19a ROUND 2 — the fresh reviewer's verdict and the orchestrator's dispositions (2026-10-04); THE ENTRY CLOSES

**No BLOCKER, no MAJOR — no round 3 earned; F1/F3/F4 confirmed sound** (the re-spell verified
against the real module graph with a true red/green pair at the exact spelling; the F1 census
claim re-checked across every build log; F3's six warnings traced into the one now-annotated
test, suites 10/2 green; F4's narrowed comment verified against GRDB's own source and all 20
live sites). Two MINOR findings, both record/ledger scope, DISPOSITIONED BY EDIT in this
commit; one NIT held to next-touch:

- **R2-1 [MINOR] ACCEPTED — the settlement lesson was incomplete: the IMPORT GRAPH, not only
  the spelling, decides the overload.** The reviewer's probes: the same exact spelling is REAL
  with `import Testing` alone and VACUOUS once `SwiftUI`/`AppKit`/`Dependencies` is visible
  (an Optional-typed parameter + certain implicit-member names — observed: `tag`, `id`,
  `opacity`, `post`, `bold`); `Foundation`/`Combine`/`GRDB` leave it real. So NOTICED #1's
  failed reproduction was the import graph's doing, and even an exact-spelling probe in a
  scratch module can clear a vacuous site wrongly. **The lesson as AMENDED (binding, here and
  in 19c's rules): settle by mutating IN PLACE in the real test target, then revert — never
  in a scratch or mimic module.** The trigger conditions are recorded as a candidate-RANKING
  aid only, never a clearance.
- **R2-2 [MINOR] ACCEPTED — mobile's vacuous-expectation check was unowned.** Named live
  candidates: `MobileMarkdownActs.swift:90–91` (`@discardableResult … -> Bool`) asserted bare
  at `MobileMarkdownTests.swift:389/397/453/551/563`. DISPOSITIONED: 19b's acceptance gains
  the zero-unused-result-warnings line; 19c Arm 1 widens to the mobile callees and call
  sites, sequenced after 19b (both edited below/above in this commit).
- **R2-3 [NIT] — one 127-column comment line in each CopiedRow twin: re-wrap at next touch**
  (recorded; no commit owed).

**19a IS CLOSED** (opened and closed 2026-10-04; the red-on-old was the failing Xcode-27
build; every target compiles and runs green; the ladder ran round 1 → fixes → round 2 clean).

## 19b — Xcode 27 / Swift 6.4: the MOBILE test-target migration

**Opened 2026-10-04 by the 13r orchestrator out of 19a's round-1 review** (finding 2: the
mobile TEST target was outside every census — the 13r-u1 probe built the mobile APP only —
and does not compile under Xcode 27; unowned ⇒ owned here). **Scope:** the Row-Sendable
ROW-COPY class across `App/Variorum/VariorumMobileTests/` — **~61 sites in ~25 files** per
the reviewer's continue-after-errors log (a FLOOR until the build is green: censuses are
lower bounds, 19a's own lesson); the same rules as 19a (MECHANICAL migration only, assertion
bytes preserved, any intent-changing fix stops and reports); PLUS the **CopiedRow
unification question** — one source file serving core/Mac/mobile versus a third identical
twin: the implementer PROPOSES, the orchestrator rules, before building that part.
**Acceptance:** mobile TEST BUILD SUCCEEDED (generic iOS Simulator) · the touched files'
suites green on a concrete simulator (suite-level, counts confirmed) · **zero unused-result
warnings inside `#expect`/`#require` expansions in the mobile test build (F1's census rule;
any found settled by an IN-PLACE mutant at the exact spelling — R2-1's amended lesson)** ·
F4's narrowed comment carried into whatever CopiedRow shape lands. **Cast:** `opus-implementer`; Opus cold review.
**Red-on-old:** the failing build itself (`mobile-bft-2.log` preserved in the 19a round-1
evidence). **State: CLOSED 2026-10-04 — the Opus cold review returned a CLEAN BILL (no
BLOCKER, no MAJOR, no MINOR; two record-scope NITs, dispositioned in the ROUND 1 section
below); no round 2 earned.**

**THE CENSUS CORRECTED (the implementer's log re-read, 2026-10-04 — accepted by the
orchestrator):** the "~61 sites in ~25 files" above was the round-1 log's WARNING census
misread as the error class; the preserved red-on-old carries **6 ROW-COPY error sites in 4
mobile test files** (MobileLibraryTests:212 · MobileMembershipTests:239/299 ·
MobileShellTests:270 · MobileTutorialWalkTests:395/433), a FLOOR until the implementer's own
builds iterate to green. The ~60 warnings get a per-class census in the 19b RECORD (counts +
classes, no fixes beyond this entry's own acceptance lines); their ROUTING is held for the
orchestrator at the entry's close (candidates: the mobile main-actor warning class widens
19c Arm 2; cosmetic classes recorded next-touch).

**THE COPIEDROW FORK — RULED BY THE ORCHESTRATOR (2026-10-04, repo-first before the build):
OPTION A, one file, three consumers.** `Tests/VariorumCoreTests/Support/CopiedRow.swift`
stays the single source; the Xcode project gains ONE classic file reference to it (a small
TestSupport group) plus one PBXBuildFile per TEST target's Sources phase; the Mac twin
`App/Variorum/VariorumTests/CopiedRow.swift` is DELETED. Why over B: one source of truth
ends the lockstep-editing class F4 already exposed; the pbxproj risk is contained to
test-target sections (provable in the diff) and cannot touch 13r's BUILT walk artifacts; B
would institutionalize a three-way copy rule the next toolchain bump punishes. RIDERS: (1)
the record PROVES from the diff that zero app-target lines changed; (2) the twin's deletion
lands in the SAME commit as the wiring — no interval with a duplicate or missing type; (3)
verification owed: core `swift build --build-tests` green · Mac `build-for-testing` compiles
· the Mac suites that consume CopiedRow (19a's migrated Row-copy suites) re-run GREEN at a
zero-instance window (the re-pointed file proven serving the Mac target identically) ·
mobile per this entry's own acceptance; (4) comment fate as proposed — F4's narrowed text
verbatim, the three-consumers header, "keep them identical" retires, R2-3's re-wrap counts
as its next touch; (5) any harness-stopped deletion is surfaced, never worked around.

## 19b ROUND 1 — the Opus cold review's verdict and the orchestrator's dispositions (2026-10-04, same-model flow); THE ENTRY CLOSES

**CLEAN BILL: no BLOCKER, no MAJOR, no MINOR — no round 2 earned.** The reviewer verified by
its own hands: six in-place red mutants in the real mobile target (exactly 6 issues, then
reverted, tree clean) proving every migrated assertion can still fail — including the new
`== nil as String?` shape, proven non-vacuous; the 6-site census reconfirmed from both logs;
zero `#expect`/`#require` lines changed; the pbxproj object diff independently reproduced
(only the main group, the two TEST Sources phases, and the four new objects — all six
targets, every configuration, both app Sources phases unchanged); the twins' code proven
identical pre-deletion; mobile 62/14 green on a concrete simulator; Mac 213/40 and core 29/5
green at a zero-instance window; the warning census reconciled (58 path-anchored + 2
macro-expansion = 60). Reviewer evidence: `App/Variorum/DerivedData/19b-review/` (kept; its
3.3 GB of build products deleted, logs retained). Two NITs, both record-scope:

- **N1 [NIT] ACCEPTED — the 19b RECORD's post-edit line citations drifted by one; THIS BLOCK
  is the corrected citation** (the record's prose stands as written; verified by the
  orchestrator's own grep at HEAD): `.map(CopiedRow.init)` sits at MobileLibraryTests:215 ·
  MobileMembershipTests:242/303 · MobileShellTests:279 · MobileTutorialWalkTests:396/434;
  the two flagged read shapes at MobileMembershipTests:244/305 (`== nil as String?`) and
  MobileLibraryTests:218/222. The census lines (the compiler's error lines on the OLD tree)
  were correct as recorded. The record's "evidence in place" gap for the NULL-binding shape
  is also closed BY THE REVIEW: its green run proved the binding, and the reviewer's red
  mutants (logs `19b-review/mobile-bft-mutant.log` + `mobile-mutant-run.log`; issues at
  Library:217, Membership:244/305, Shell:281/282, TutorialWalk:439) supply the
  can-fail proof R2-1's discipline asks for.
- **N2 [NIT] ACCEPTED as next-touch, record-only:** CopiedRow's failure output prints two
  parallel arrays where `Row` printed name:value pairs; the improvement at the next
  legitimate touch is a `CustomStringConvertible` built from `zip(columns, values)` (never
  `row.description` — the dictionary rebuild loses column order). Joins R2-3's next-touch
  class. No commit owed.
- **Out-of-diff item 1 — FIXED in this commit:** the master plan's standing-fixes pointer
  row (17) gains the succession sentence naming THIS ledger as the active one (the ledger
  header's "the master plan carries one pointer row" promise was dangling for 19).
- **Out-of-diff item 2 — RECORDED, no entry opened:** a fresh mobile build shows 7 app/core
  SOURCE warnings, outside 19b/19c's test-file scope (warning-grade, zero behavior change;
  next legitimate touch per file). One is `Shared/EncryptionSession.swift:387` ("`joined`
  inferred as `()?`") — custody-adjacent, so any future touch of that file is FABLE-seat
  work by the standing review rule.

**THE NOTICED ROUTING (held to the close, now ruled):** (1) the 20 mobile isolation
warnings in 5 files → **19c Arm 2 WIDENS to the mobile side** (the 19c entry is amended in
this commit); (2) the 10 deprecated `UIWindow.init(frame:)` sites in
7 test rigs are RECORDED in 19c's entry as adjacent residue deliberately NOT owned there
(not mechanical — the replacement needs a window scene; promote to a fresh letter when a
toolchain turns it red); (3) the counting lesson, binding on future censuses: xcodebuild's
"(N failures)" counts BUILD COMMANDS, not errors — count unique `error:` lines, and include
`macro expansion #expect:` lines when counting warnings (they carry no file path).

**19b IS CLOSED** (opened and closed 2026-10-04; the red-on-old was the failing mobile test
build; one round, clean).

---

## 19a — Xcode 27 / Swift 6.4: the test-target + mobile migration

**Opened 2026-10-04 by the 13r orchestrator** (not author-filed — flagged to her and RATIFIED
at her word the same day: *"that's fine on 19a being opened by you - the ledger never needed to
say that it would be author filled in the first place, the 17 series was also used by sessions
whenever they needed a place to put an issue"* — sessions may open entries here, as they did in
17; the toolchain moved to Xcode 27.0/27A266a mid-13r at her hands, and the 13r U1
implementer's clean-build census found the breakage; the census record is the 13r plan's U1
RECORD, commit `d2e091ee`, logs under the gitignored `App/Variorum/DerivedData/13r-u1/`).
**Deliberately NOT in this entry:** the Mac APP's one error (`PaneSurface.swift:1076`,
isolated-conformance) — an editor-seam line that lands inside 13r U1 and rides 13r's Fable
ladder; this entry's diff touches NO editor seam, NO `Sync/` source, NO custody.

**Scope (the census, exact):**
- **`VariorumTests` (Mac), 20 errors / 8 files:** `PaletteDerivationTests` ×10 (main-actor
  statics `all` / `resolved(_:tint:)` used from nonisolated test contexts) ·
  `PlainPasteTests` ×2 (`MemberImportVisibility`: missing `import VariorumCore`) · GRDB
  `Row`'s now-enforced unavailable Sendable: `TagAndFolderTests` ×2, `TutorialWalkTests` ×2,
  `LifecycleFacesTests` ×1, `PoolDragTests` ×1, `StructuralGestureTests` ×1 ·
  `EditorSeamCostTests` ×1 (a main-actor static from a nonisolated context).
- **Core tests, 7 errors, ALL in `Tests/VariorumCoreTests/FurnitureConvergenceRepairTests.swift`:**
  lines 433/727/803 missing `await` + `Row` Sendable; line 864 `Row` Sendable alone.
- **Mobile, 1 error:** `VariorumMobile/Features/Write/MobileChipFlow.swift:81` — type-check
  timeout on the `height` reduce in the chip-flow `sizeThatFits` (fix = split the expression;
  same computed layout).

**Rules:** MECHANICAL migration only — isolation annotations, `await`s, imports, materializing
`Row` reads inside database closures, expression splitting; **test intent and assertions
byte-preserved**. Any fix that would change what a test asserts STOPS and reports.
`FurnitureConvergenceRepairTests` is a sync-convergence suite — the sync engine's protection —
so the cold review explicitly verifies no assertion weakened there. Pin-before-fix reads on
this entry as: these are COMPILE errors, red-on-old IS the failing build (the 13r-u1 probe
logs record it); no behavioral pin is owed, and the acceptance is the suites RUNNING green.

**Acceptance:** core `swift test` green in full · the eight fixed Mac files' suites green
(suite-level `-only-testing` from `App/Variorum/`, the "Test run with N tests" line confirmed,
`skipped:` lines read) · **the TK2 point-release tripwire suites green under the new toolchain**
(`JumpViewportLayoutTests` · `RefontGapTopTests` · `InlineHeightReportTests` ·
`TakePaneMeasureTests` · `PaneRenderRestoreClipTests` · `IndexTierMetricsTests` ·
`PaneFindFaceTests` — the first suite run on a new Xcode major IS the SDK-shift census) ·
**`PaneSurfaceTests` green — its five `PaneDecoration.resolve` pins are the behavior-preservation
proof for 13r U1's one-line fix** · the mobile target builds. Mac runs at zero-instance windows.

**Cast:** `opus-implementer`; **Opus cold review** (mandatory per entry; no Fable trigger —
the editor-seam line is 13r's, reviewed there). **Sequencing:** strictly sequential with 13r's
agents — runs after 13r U1's implementer session ends, before 13r U2 spawns (U2/U3's pins and
the 13r ladder's "suite green" need the restored base; U1's static drill and her live drill do
not wait on this entry).

**State: ROUND-2-PENDING** — acceptance met 2026-10-04 by the implementer's runs (the 19a RECORD
below: core 2174/244 · the fixed Mac files' 48 suites 286/48 · the TK2 tripwires 41/8 at a
zero-instance window · `PaneSurfaceTests` 15/1 with the authorized pin · the mobile app builds);
round 1 reviewed and arbitrated (the "19a ROUND 1" section above); its three in-entry fixes F1 · F3 ·
F4 landed (the RECORD's "ROUND 1 FIXES"; `e9fbccbe`, `13610ffc`): `RuleHearsActsTests` 2/1 with
the F1 mutant RED, `LandingAuthorityTests` + `LandingSignpostTests` 10/2. A FRESH reviewer runs
round 2 over the fixes (`git diff 574ea6a8..HEAD -- Tests App`), spawned by the orchestrator.

### 19a RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract):** no walk capture — the entry's acceptance
is the suites RUNNING green (no product face changed; the one `Sources` line is a value-identical
expression split in a SwiftUI `Layout` whose arithmetic is not headless-pinned — `MobileChipFlowTests`
pins the pure brains only — and the mobile TEST target was neither built nor run: the entry asks for
the mobile app build only). No `Sync/`, no custody, no schema, no app source beyond that one mobile
line; 13r U1's `PaneSurface.swift` line untouched (the mutation check below swapped it temporarily
and restored it, sha256-verified). The brief's "`PaneSurfaceTests`' five `PaneDecoration.resolve` pins
PROVE 13r U1's line behavior-preserving" did NOT hold as stated — piece 4 says why; the orchestrator
ADJUDICATED it (piece 5) and authorized ONE committed absolute pin, landed here. **The drill-window pause is LIFTED** (the orchestrator's "drill window closed",
2026-10-04 — her live drill passed; U1 closed): suites run at quiet windows from here, her real-store
instance never touched, the measurement-shaped TK2 tripwire suites preferring a zero-instance window.
(During the window the implementer ran compile-only work — `swift build --build-tests` and
`xcodebuild build-for-testing` — and held core `swift test` too, since some core suites exercise
keychain custody seams and her drill read the keychain.)

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match.

**Red-on-old (the census, re-read from the 13r-u1 probe logs, exact):** `probe-xcodebuild-bft.log`
20 errors / 8 files (PaletteDerivation 24/76/107/124/125/128/176/187/191/236 · PlainPaste 88/103 ·
TagAndFolder 103/111 · TutorialWalk 480/514 · LifecycleFaces 50 · PoolDrag 59 · StructuralGesture 492
· EditorSeamCost 183); `probe-swift-build-tests.log` 7 errors (FurnitureConvergenceRepair 433 ×2,
727 ×2, 803 ×2, 864); `probe-mobile-build.log` 1 error (MobileChipFlow 81 — NOTE: line 81 is the
`contentWidth` expression (81–84), not the `height` reduce (78–80) the entry names; the probe log's
own source excerpt shows it; `height` type-checks).

**THE CENSUS WAS A LOWER BOUND (found 2026-10-04, same session).** `swift build --build-tests` stops
at the first failing COMPILE BATCH (SwiftPM has no keep-going flag), so the probe saw only the batch
holding `FurnitureConvergenceRepairTests`. Fixing it and rebuilding exposed three more core sites,
each in a later batch, fixed in the same mechanical classes (logs `App/Variorum/DerivedData/19a/
core-build-tests{,-2,-3,-4}.log`, gitignored): `Phase11LockstepSyncTests.swift:221` (ROW-COPY, ×2
errors — **a sync lockstep/convergence suite: the cold review checks it like Furniture**) ·
`TagFamilySectionsTests.swift:101/107` (EXPR-SPLIT: "failed to produce diagnostic" + "generic
parameter 'Value' could not be inferred" on a typed `for fetch: @Sendable (Database) throws -> Int in
[closure, closure]` header) · `StructuralSplitAtNewlinesTests.swift:393` (TRY-IN-REQUIRE, below).
The fourth build is GREEN.
**The Mac target's census was a lower bound for the same reason** (`xcodebuild` stops scheduling
compile batches after the first failure): after the 20 census sites, the rebuild exposed
`LifecycleFacesTests.swift:94` (ROW-COPY — the file's SECOND read, a tuple holding `[Row]`); a
continue-after-errors pass (`-IDEBuildingContinueBuildingAfterErrors=YES`, an IDE build-system
default, not a build setting) then showed exactly ONE remaining failing batch, nine errors: ROW-COPY
at `BookStructureTests` 312/385 · `CanvasAndPoolTests` 69 · `CanvasBankTests` 120/338 ·
`CanvasDragTests` 333; ISOLATION at `BoundaryClampTests` 226/242/248 (one sync test calling the
Mac-only `CrossBlockRefusal.message(for:)` forward). After those, `** TEST BUILD SUCCEEDED **`
(logs `App/Variorum/DerivedData/19a/mac-bft{,-2,-3,-4}.log`). **Totals: core 7 → 12 errors in 5 files;
Mac 20 → 30 errors in 13 files; mobile 1.**

**The mechanism classes (for the cold review):**
- **ROW-COPY** (GRDB `Row` crossing an async `read`): GRDB 7 declares `@available(*, unavailable)
  extension Row: Sendable` (`.build/checkouts/GRDB.swift/GRDB/Core/Row.swift:278-280`). Under Swift
  6.2 the solver treated the unavailable conformance as non-conforming, so every `db.read { …Row… }`
  in an async body silently resolved to the SYNC `AppDatabase.read` overload (which is why the core
  sites compiled with no `await` at all). Swift 6.4 now selects the async overload
  (`read<T: Sendable>(_: @Sendable …) async`, `AppDatabase.swift:184`) and diagnoses the unavailable
  conformance (plus, at the await-less sites, the missing `await`). Fix: `await` the read and copy
  the rows INSIDE the closure — `….map(CopiedRow.init)` — into `CopiedRow`
  (`Tests/VariorumCoreTests/Support/CopiedRow.swift`; the Mac target gets the same type): a Sendable
  `(columns, values: [DatabaseValue])` copy whose two String-keyed subscripts READ THROUGH A REBUILT
  GRDB `Row` (so decoding, NULL and missing-column behaviour are GRDB's own) and whose synthesized
  `==` equals `Row ==` for scope-free raw-SQL rows (ordered names case-sensitive, `DatabaseValue
  ==`). **Every `#expect` line at a ROW-COPY site is byte-identical.** Overload proof: a standalone
  Swift 6.4 experiment mimicking `Row`'s three subscripts vs the copy's two (scratchpad `solver/`)
  binds the SAME `Value` for every shape the sites use — `x?["c"] as String?` (Optional<String>,
  so NULL reads nil, never a trap) · `x["c"] == "lit"` / `== s` / `allSatisfy { $0["c"] == … }`
  (String) · `x["c"] == nil` / `!= nil` (the untyped subscript) · `let k: String = x["c"]`.
- **ISOLATION** (main-actor members called from nonisolated test contexts): the Mac app target
  builds with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; `VariorumTests` does not (nonisolated).
  `PalettePreset.all` / `resolved(_:tint:)` sit in an `extension PalettePreset` that is NOT marked
  `nonisolated` (the struct is), and the 3-arg `CrossBlockRefusal.message(range:index:slots:)` and
  `message(for:)` live in the Mac's default-isolated `CrossBlockRefusalRoads.swift` extension (the
  enum itself is `nonisolated`) — so all are main-actor members Swift 6.4 now refuses from a
  nonisolated sync test. Fix, test-side only (no app source touched): `@MainActor` on the
  `PaletteDerivationTests` SUITE (all ten sites plus its shared `presets` helper are inside it; every
  test there is a pure computation) and on the ONE function at each of
  `EditorSeamCostTests.theCrossBlockRefusalDiagnosisStaysCheapAtTwentyThousandBlocks` (a 50 ms
  ceiling over a synchronous pure call — main-actor execution cannot interleave inside it) and
  `BoundaryClampTests.theSurvivingResidualsAreNamedAndNeitherIsAGeometry`.
- **IMPORT** (`MemberImportVisibility`, on in every target): `PlainPasteTests` reads
  `Queries.RenderedBlock.text` without importing its defining module — `import VariorumCore` added.
- **EXPR-SPLIT** (type-check failures): MobileChipFlow:81 (DONE — `contentWidth`'s one expression
  became `let rowWidths: [CGFloat] = rows.map { row in let chipWidths: CGFloat = …reduce(0, +); let
  gaps: CGFloat = CGFloat(max(row.count - 1, 0)) * hSpacing; return chipWidths + gaps }` then
  `rowWidths.max() ?? 0` — the same per-row sum, the same gaps, the same `+` order, the same max and
  the same empty answer; `height` untouched, it type-checks) · TagFamilySections:101 (DONE —
  the typed closure array hoisted to `let fetches: [@Sendable (Database) throws -> Int]`, then
  `for fetch in fetches`; same two closures, same order, same loop body).
- **TRY-IN-REQUIRE** (Xcode 27's Swift Testing `#require` now expands a function-call argument into
  `__checkFunctionCall(db.self, calling: { $0.fetchString($1,$2) }, …)`, a closure the outer `try`
  does not cover): `StructuralSplitAtNewlinesTests.swift:393` gains `try` before `db.fetchString(` —
  **the ONE assertion-line byte change so far: an effect marker only, the same call and the same
  value checked** (the macro now checks it as a value rather than decomposing the call; only a
  failure message's sub-expression detail differs).

**Pieces:**
1. Core test target compiles under Xcode 27 — DONE (this commit): ROW-COPY at
   `FurnitureConvergenceRepairTests` 433/727/803/864 + `Phase11LockstepSyncTests` 221; EXPR-SPLIT at
   `TagFamilySectionsTests` 101; TRY-IN-REQUIRE at `StructuralSplitAtNewlinesTests` 393;
   `Support/CopiedRow.swift` new. `swift build --build-tests` exit 0 (log `core-build-tests-4.log`).
   Core `swift test` full run — PENDING (held for the drill window).
2. Mac `VariorumTests` compiles under Xcode 27 — DONE (this commit): ROW-COPY at `TagAndFolderTests`
   104/112 · `TutorialWalkTests` 480/514 (the call-site copy; the `userPostRows` helper keeps returning
   `[Row]` — it is called only inside the reads) · `LifecycleFacesTests` 50 (`container()` now returns
   `CopiedRow`) + 94 · `PoolDragTests` 59 · `StructuralGestureTests` 492 · `BookStructureTests`
   312/385 · `CanvasAndPoolTests` 69 · `CanvasBankTests` 120/338 · `CanvasDragTests` 333; ISOLATION at
   `PaletteDerivationTests` (suite) · `EditorSeamCostTests` (one test) · `BoundaryClampTests` (one
   test); IMPORT at `PlainPasteTests`; `VariorumTests/CopiedRow.swift` new (the core copy's twin). **No
   `#expect`/`#require` line changed in the Mac diff.** The ROW-COPY overload experiment was extended
   to the Canvas shapes (`rows[0]["x"] == Double(…)` → `Double`; `let x: Double? = rows.first?["x"]`
   → `Optional<Double>`) — the same bindings as `Row`. `xcodebuild build-for-testing` →
   `** TEST BUILD SUCCEEDED **` (log `mac-bft-4.log`). Suite runs — PENDING.
3. Mobile `MobileChipFlow.swift:81` — DONE (this commit; EXPR-SPLIT above). `xcodebuild -scheme
   VariorumMobile -destination 'generic/platform=iOS Simulator' build` → `** BUILD SUCCEEDED **`, no
   diagnostic on the file (log `App/Variorum/DerivedData/19a/mobile-build.log`). The only `Sources`
   line in this entry's diff.
4. Acceptance runs — IN-PROGRESS.
   - **Core `swift test`, full: GREEN — `✔ Test run with 2174 tests in 244 suites passed`** (13i-e's
     baseline 2173/244), exit 0, the one `skipped:` line the standing Supabase integration gate
     (`basicOfflineEditsConvergeOverTheRealServer`, env-gated), XCTest `Executed 0 tests` (no XCTest
     cases). Every touched core test passed BY NAME: `theLosersTombstoneArrivingBeforeItsRepointsMoves
     TheMembershipsToTheKeeper` (433) · `aLoserRenamedLocallyStillHandsItsMembershipsToTheKeeper` (727)
     · `aFreshStoreMeetingTheLoserDeadHandsItsMembershipsToTheKeeper` (803) ·
     `aMembershipArrivingUnderTheDeadLoserRepointsToTheKeeper` (864) ·
     `duplicateCanvasRowsRepairToTheSmallerIDAndTheRepairPushes` (Phase11 221) ·
     `bothReadsAreBlindToAutosave` (TagFamily) · `everyRowItWritesIsAnOrdinaryOutboxedRow`
     (SplitAtNewlines). Log `App/Variorum/DerivedData/19a/core-swift-test.log`.
   - **`CopiedRow` ↔ `Row` parity, on a real database (a THROWAWAY probe, run once by filter, deleted,
     never committed):** NULL / missing column / present via the untyped subscript; `as String?` on
     text, NULL and missing; `as Int?`, `as Double?` (and `Double?` from an integer column); a
     case-insensitive `let x: String = copy["T"]`; `copy["t"] == "abc"`; `==` against an equal row, a
     row differing in one value, and a row differing only in a column name's CASE — 18 checks, every
     one the same answer as `Row`. 1 test, passed.
   - **The 13 fixed Mac files' suites + `PaneSurfaceTests`/`PanePublishDoorTests`** (48 suites, every
     test type in those files; `test-without-building`, suite-level `-only-testing`): **run 2 GREEN —
     `✔ Test run with 286 tests in 48 suites passed`, no `skipped:` line** (286 = the files' `@Test`
     count exactly). Run 1 (same set) had ONE issue: `CanvasHostedRealizationTests.
     aMountedLongPostRealizesABoundedCardSet` — `paneCount > 0` (a 300-card canvas mounted in its own
     `NSWindow` found no `PaneTextView` in the hierarchy). Not this entry's: the test touches no edited
     line (this file's edit is line 69, another struct) and no `CopiedRow`; GREEN alone 2/2
     (`mac-canvas-hosted-{1,2}.log`) and in run 2; and the same expectation failed the same way in a
     crowded Act 10 full run under Xcode 26 (`notes/plans/act10-correction-screens/batch-g/
     g-full-mac.log:1091`). Recorded as the pre-existing concurrent-mount sensitivity of a mounted
     window test, with her real-store app live beside the run. Logs `mac-suites-{1,2}.log`.
   - **`PaneSurfaceTests` GREEN (run 2) — `theLivePanesDecorationFollowsTheIndicatorPreference`, the
     test holding all five `PaneDecoration.resolve` calls, passed by name. BUT those five pins do NOT
     discriminate 13r U1's line** (`PaneSurface.swift:1077`, `tokens.map { _ in Color.clear } ??
     Color.gray.opacity(0.25)`): every call passes NON-nil tokens, and they compare the rest look only
     RELATIVELY (`off == rest`, `background.stroke == rest.stroke`, `resolve(isLive: false, …) ==
     rest`) — no test anywhere pins either arm's ABSOLUTE stroke (grep: `PaneDecoration` appears in
     tests only there and in `hostRing`'s three pins). A swapped or merged arm would stay green. **What
     stands in, as evidence (a THROWAWAY probe in `VariorumTests`, run once by filter, deleted, never
     committed — the line is 13r's editor-seam fix, so a committed pin is 13r's ladder's call, not this
     entry's):** for both voices × light/dark × every indicator style, `resolve(isLive: false, …,
     tokens: voiced) == PaneDecoration(stroke: .clear, lineWidth: 0.5, fill: nil)`; for every style,
     `resolve(isLive: false, …, tokens: nil) == PaneDecoration(stroke: Color.gray.opacity(0.25),
     lineWidth: 0.5, fill: nil)` and `!=` the clear one; and the live `.off` arm returns each rest. 1
     test, passed (`mac-probe-run.log`). So U1's line reads the shipped values on BOTH arms — the
     comment's contract ("voiced compositions draw nothing … tokens nil keep their grey hairline").
     **Routed to the orchestrator: whether 13r's ladder wants that probe's two absolute assertions
     committed as a real pin.**
     **ADJUDICATED** — see piece 5.
   - **The core count's +1 vs the 13i-e closeout baseline (2174/244 vs 2173/244):** not this entry's
     — 19a adds no core test (`8fe0680e` touches no `@Test` line). The closeout paragraph's 2173 was
     counted BEFORE the 13i-e post-close addendum: `6b1eefaf` (her W-O-1(b) ruling, 2026-10-03)
     renamed `aDecidedPairBringsNothingBack` → `aDecidedPairStillBringsTheJournalBackAndRefilesNothing`
     and ADDED `aHandRemovedPairStaysRemovedButTheJournalStillReturns` (DailyJournalRulingsTests), and
     `d58bc3ee` already recorded "core 2174/244".
   - **The mobile target builds** — DONE (piece 3).
   - **The seven TK2 tripwire suites — GREEN at a ZERO-INSTANCE window** (her app quit, the
     orchestrator's word; `pgrep` empty before AND after, 11:19:23Z–11:20:53Z; products rebuilt from the
     restored tree first): `JumpViewportLayoutTests` · `RefontGapTopTests` · `InlineHeightReportTests` ·
     `TakePaneMeasureTests` · `PaneRenderRestoreClipTests` · `IndexTierMetricsTests` (+ its file's
     `PaneLineMetricsScopeTests`) · `PaneFindFaceTests` — **`Test run with 41 tests in 8 suites passed …
     with 4 known issues`**, no `skipped:` line. The 4 known issues are the STANDING non-intermittent
     `withKnownIssue` at `IndexTierMetricsTests.swift:290` (#154 (b)'s one residual, 18l-c: TK2 lays the
     extra line after an empty last paragraph short), 2 voices × the Book Index and Read-edit panes —
     **measured −10.0 pt (Terminal) / −20.0 pt (Study), exactly the values recorded on 27.0**. **The
     SDK-shift census: the first suite run on Xcode 27 / the 27.0 SDK finds NO TK2 geometry shift** (the
     OS stayed 27.0 / 26A428 — only the toolchain and SDK moved). Log `mac-tk2-tripwires.log`.
5. **THE ONE AUTHORIZED NEW ASSERTION** — the 13r orchestrator's "19a MID-RUN ADJUDICATION"
   (`notes/plans/phase-13r-distribution.md`, the LIVE STATUS bullet, `0b2c1385`): the finding accepted,
   the "five pins prove it" acceptance line corrected, and — **as a scoped exception to this entry's
   no-new-assertions rule** — ONE committed pin authorized: `PaneDecoration.resolve`'s ABSOLUTE rest
   values on both arms, named as the Xcode-27 isolated-conformance fix's tripwire. **LANDED (this
   commit):** `PaneSurfaceTests.theRestLookHoldsItsAbsoluteValueOnBothArms` — for both voices ×
   light/dark × every indicator style, voiced tokens → `PaneDecoration(stroke: .clear, lineWidth:
   0.5, fill: nil)`; for every style, nil tokens → `PaneDecoration(stroke: Color.gray.opacity(0.25),
   lineWidth: 0.5, fill: nil)`. GREEN on the current tree: `✔ Test run with 15 tests in 1 suite
   passed` (`PaneSurfaceTests`, 14 + the pin; `mac-pin-green.log`). The pin's own red-on-old cannot
   run (the pre-U1 spelling no longer compiles), so its discrimination is shown by a MUTATION CHECK:
   **MUTATION CHECK STARTING after this commit** — `PaneSurface.swift:1077`'s arms are swapped
   temporarily (`tokens.map { _ in Color.gray.opacity(0.25) } ?? Color.clear`), the pin must go RED,
   then the file is restored with `git checkout -- App/Variorum/Variorum/Surface/PaneSurface.swift`
   (it is committed and carries no other change) and its sha256 re-read against
   `f5549afc0f5e3732ca9c4c23068d0d24ebf1204aa1e6ac40120c225064c1d770`. If this record still says
   STARTING, the check died mid-flight: run that `git checkout --` first.
   **MUTATION CHECK — DONE.** With the arms swapped (`mac-bft-mutant.log`, `mac-pin-mutant.log`): the
   new pin went **RED, 15 issues** (12 voiced: 2 voices × 2 appearances × 3 styles at line 169; 3 nil
   at line 176) and it was the ONLY failing test — **the five relative pins stayed GREEN under the
   mutant** (`✘ Test run with 15 tests in 1 suite failed … with 15 issues`, every issue the new pin's),
   the finding demonstrated directly. Restored with `git checkout --`; sha256 re-read =
   `f5549afc…c1d770`, the pre-mutation value; `git status` clean; the test products rebuilt from the
   restored tree (`mac-bft-restored.log`) before the tripwire run.

**DISPOSITIONS (every census and extension site):** all **FIXED** — core 12 errors / 5 files, Mac 30
errors / 13 files, mobile 1. Evidence class (the entry's own reading of pin-before-fix): red-on-old
IS the failing build (`App/Variorum/DerivedData/13r-u1/probe-*.log` for the census;
`App/Variorum/DerivedData/19a/core-build-tests{,-2,-3}.log` and `mac-bft{,-2,-3}.log` for the
extensions), green-on-new is the compiling targets plus the suites above. Nothing DISMISSED, nothing
DEFERRED. **Assertion bytes:** every `#expect`/`#require` line in the diff is byte-identical EXCEPT
(1) `StructuralSplitAtNewlinesTests.swift:393` — `try` added inside a `#require` (an effect marker;
the same call and value), and (2) the ONE new pin, authorized (piece 5). The two sync-convergence
files (`FurnitureConvergenceRepairTests`, `Phase11LockstepSyncTests`) change ONLY their read lines
(`await` + `.map(CopiedRow.init)`); every assertion there is byte-identical and every touched test
passed by name.

**FOR THE COLD REVIEW — the diff, by class (`git diff a634ff7a..HEAD -- Tests App`):**
- ROW-COPY: `Tests/VariorumCoreTests/Support/CopiedRow.swift` + `App/Variorum/VariorumTests/CopiedRow.swift`
  (new, identical bodies) · core `FurnitureConvergenceRepairTests`, `Phase11LockstepSyncTests` · Mac
  `TagAndFolderTests`, `TutorialWalkTests`, `LifecycleFacesTests`, `PoolDragTests`,
  `StructuralGestureTests`, `BookStructureTests`, `CanvasAndPoolTests`, `CanvasBankTests`,
  `CanvasDragTests`. Check: `CopiedRow`'s reads go through a rebuilt GRDB `Row`; `==` matches
  `Row ==` for scope-free rows; the overload experiment and the real-DB parity probe (piece 4).
- ISOLATION: `PaletteDerivationTests` (suite `@MainActor`), `EditorSeamCostTests` and
  `BoundaryClampTests` (one function each).
- IMPORT: `PlainPasteTests`.
- EXPR-SPLIT: `TagFamilySectionsTests` (core), `MobileChipFlow.swift` (the one `Sources` line).
- TRY-IN-REQUIRE: `StructuralSplitAtNewlinesTests` (core).
- THE AUTHORIZED PIN: `PaneSurfaceTests.theRestLookHoldsItsAbsoluteValueOnBothArms`.

**NOTICED (routed to the orchestrator; none acted on here):**
1. **A possibly VACUOUS `#expect` under Xcode 27's Testing macros, unresolved:**
   `Tests/VariorumCoreTests/CatalogDetailWordsTests.swift:45`
   (`#expect(RuleGrammar.hearsApplyingActs(.tag("t1")))`) now WARNS "result of call to
   'hearsApplyingActs' is unused" inside its expansion
   (`__checkFunctionCall(RuleGrammar.self, calling: { $0.hearsApplyingActs($1) }, .tag("t1"), …)`).
   That is the shape the `-> R?` overload of `__checkFunctionCall` would take with `R = Void` — which
   would make the expectation always pass. An isolated reproduction (a mimic with the same
   `(RuleTerm?) -> Bool` signature, scratchpad `expectprobe/`) is NOT vacuous (its false
   expectations fail) and does not warn, and the sibling lines 46–51 do not warn either, so the real
   module's warning is unexplained. Not checked further (the orchestrator's stop order). The settling
   check, ≈2 min: a throwaway core test whose FIRST statement is the same form on a FALSE value
   (`#expect(RuleGrammar.hearsApplyingActs(.tag("")))`) must FAIL. If it passes, every
   `__checkFunctionCall`-shaped `#expect` deserves a sweep — an entry of its own.
2. **The census method:** both `swift build` and `xcodebuild` stop scheduling compile batches at the
   first failure, so a one-pass "census" of a new toolchain is a LOWER BOUND (13r U1's 28 became 43
   here). The next major's census should iterate to green before quoting a number.
3. **Swift 6.4 warnings, not errors (out of scope):** core test build 60 warnings (new classes:
   "no calls to throwing functions occur within 'try'" ×11, "#require is redundant" ×8, unused
   results), Mac test build 207; 13r U1 recorded 4 new `nonisolated(unsafe)`-unnecessary warnings in
   core `Sources`.
4. **`CanvasHostedRealizationTests.aMountedLongPostRealizesABoundedCardSet`** — the pre-existing
   concurrent-mount sensitivity (piece 4): one `paneCount > 0` miss in a 48-suite run beside her live
   app, green alone 2/2 and in the re-run; the same miss is on record from Act 10 under Xcode 26.
5. **Two `CopiedRow` copies** (the core and Mac test targets share no support module) — keep them
   identical; the Mac file's header says so.

**Commits:** `4a50d0f2` (record opened, drill pause) · `8fe0680e` (piece 1, core) · `7fbe7550` (piece
2, Mac) · `dd2bd8f8` (piece 3, mobile) · `feaf5045` (acceptance runs) · `97ce8a87` (piece 5, the pin)
· `12d28565` (tripwires + mutation check) · this commit (dispositions, State → REVIEW-PENDING).

**ROUND 1 FIXES (LIVE STATUS — the same implementer, resumed 2026-10-04 at the orchestrator's
arbitration `e1bfdd08`; the binding record is the "19a ROUND 1" section above):**
- F1 [MAJOR] `CatalogDetailWordsTests.swift:45` vacuous — **DONE (`e9fbccbe` + this commit).**
  Re-spelled `#expect(RuleGrammar.hearsApplyingActs(RuleTerm.tag("t1")))` — the explicit type, the
  file's own line-51 idiom — under a three-line comment naming why (the expectation now sits at line
  49). The core test build carries ZERO unused-result warnings inside any `#expect`/`#require`
  expansion (it carried 1, this line; `r1-core-bft.log`). **Mutation check DONE:** argument →
  `RuleTerm.tag("")` ⇒ `RuleHearsActsTests` RED, exactly 1 issue, at the re-spelled line
  (`Expectation failed: RuleGrammar.hearsApplyingActs(RuleTerm.tag(""))`; `r1-f1-mutant.log`) — the
  same mutant was GREEN on the old spelling (the orchestrator's decisive check). Restored with
  `git checkout --`, tree clean, suite GREEN again 2/1.
  **NOTICED #1 CORRECTED:** the isolated reproduction I cited did not reproduce the trigger (its
  stand-in enum resolved differently), so "not vacuous in isolation" proved nothing about line 45;
  the line WAS vacuous. Mechanism (the review's, from Xcode 27's `Testing.swiftinterface`): the
  bare implicit-member `.tag(…)` argument in function-call shape routes the `#expect` expansion
  through `__checkFunctionCall` with R = Void, the Bool is discarded, and the check passes on
  `.some(())`. **THE CENSUS RULE (binding on any toolchain census):** an unused-result warning inside
  an `#expect`/`#require` expansion means a VACUOUS expectation until a red mutant proves otherwise
  — and a `@discardableResult` callee takes the same path with NO warning, so the tell cannot
  clear those. Applied to this entry's targets: the core and Mac test builds carry exactly ONE such
  warning between them (line 45, now gone). The silent half is NOT cleared — see NOTICED #6.
- F3 [NIT] `LandingAuthorityTests.swift:54–59` isolation warnings — **DONE (this commit).**
  `@MainActor` on the one synchronous test, `theTwoPoliciesCarryTheSurfacesShippedNumbers` (its six
  `BookView.landing*` / `ReadingFlowView.landing*` reads are main-actor statics); assertion bytes
  unchanged. The Mac test build's lines carrying those six warnings: 12 → 0 (`r1-mac-bft.log`).
  `LandingAuthorityTests` + `LandingSignpostTests` (the file's two suites): **`✔ Test run with 10
  tests in 2 suites passed`**, no `skipped:` line, at a zero-instance window (`pgrep` empty before
  and after; `r1-landing.log`). The rest of the class in the Mac build (AppKit `subviews` / `title`
  / `frame` / `identifier` from nonisolated contexts — `BookViewTests`, `LibraryPanelTests`,
  `PagedReadTests`, `ReadNoteLandingTests`, `ReadTierTests`, `TakePaneMeasureTests`,
  `TutorialWalkTests`) is NOT F3's and is not touched — NOTICED #7.
- F4 [NIT] both `CopiedRow` twins' duplicate-column comment — **DONE (this commit).** Narrowed in
  both: an EXACT duplicate keeps the leftmost; duplicates differing only in CASE are NOT supported
  (the rebuilt row comes from an unordered dictionary, so GRDB's case-insensitive lookup picks one
  unspecified); every live site reads single-table rows with unique names. Comment-only — the
  bodies are byte-identical between the twins (`diff` clean) and both targets build. No
  case-insensitive rebuild (the arbitration's ruling).
- F2 is 19b's (the mobile TEST target) — not touched here.

**NOTICED, round 1 (routed to the orchestrator; none acted on):**
6. **The census rule's SILENT half is live in this codebase, unverified.** 65 functions in `Sources`
   and the Mac/Shared app code are `@discardableResult … -> Bool` (scratchpad list), and Mac tests
   assert some of them BARE with an implicit-member argument, the exact F1 shape minus the warning,
   e.g. `MarkdownActsTests.swift:96/123/146/167/191` (`#expect(MarkdownActs.apply(.bold, to:
   h.textView))`), `BookStructureTests.swift:782/786/793` (`#expect(book.structure.acceptDrop(…`).
   Whether any is vacuous is unknown until a red mutant at its exact spelling says so — a census
   of its own (a natural rider for 19b, or a fresh letter).
7. **The ISOLATION class still stands as WARNINGS** in seven Mac test files (F3's list above): one
   toolchain promotion from red, like F3. Not this round's.

---

## 19b RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract):** (1) no walk capture — no product face
changed: the diff is test-target-only (four mobile test files, the one shared test-support file's
COMMENT, the Mac twin's deletion, and test-target-only pbxproj objects), so the entry's acceptance is
builds + suites, as 19a's was; (2) NO full suite — only the touched mobile files' suites, rider 3's Mac
CopiedRow consumers, and the core CopiedRow consumers ran (below); (3) no vacuous-`#expect` settlement
— the R2-2 mobile candidates are 19c Arm 1's, untouched (re-spelling them would change assertion
bytes); (4) no warning fixed — the 60-warning census is RECORDED for the orchestrator's routing; (5) no
`Sync/`, no custody, no schema, no app source, no Release build, `/Applications` untouched (no Mac-app
change: the app targets' pbxproj objects are byte-equal — no refresh owed); `Tools/Release/` and 13r's
DerivedData folders untouched.

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match. Base `102453a8`.

**THE CENSUS, re-read from the preserved red-on-old (`App/Variorum/DerivedData/19b/mobile-bft-2.log`,
the 19a round-1 reviewer's continue-after-errors `build-for-testing`):** exactly **6 ERROR sites in 4
files**, all ROW-COPY (`conformance of 'Row' to 'Sendable' is unavailable`), each printed twice (two
arch passes): `MobileLibraryTests.swift:212` · `MobileMembershipTests.swift:239/299` ·
`MobileShellTests.swift:270` · `MobileTutorialWalkTests.swift:395/433`. **The entry's "~61 sites in
~25 files" is NOT the log's error census** — the log's ~60 unique WARNING lines (20 "no calls to
throwing functions occur within 'try'", 17+2+1 main-actor reads from nonisolated contexts, 10
`UIWindow.init(frame:)` deprecations, …) match that figure; the errors are 6. Still a FLOOR (19a's
lesson): SIL-stage diagnostics only run once a batch type-checks, so the number is quoted only after
my own builds iterate to green. Ten more `Row.fetch*` reads in the mobile tests (`MobileBlockHistory`
55, `MobileShell` 249, `MobileStructural` 511, `MobileTakeLock` 42/55, `MobileTutorialWalk` 193/1061,
`MobileWalk` 495) did NOT error — each is checked below before it is called out of scope.

**THE COPIEDROW FORK — RULED: OPTION A** (the orchestrator, `52edc1f9`; the ruling text and its five
riders live in the 19b entry above). Built in piece 2: `Tests/VariorumCoreTests/Support/CopiedRow.swift`
is the ONE source; the Xcode project compiles that same file into BOTH test targets; the Mac twin
`App/Variorum/VariorumTests/CopiedRow.swift` is deleted in the SAME commit as the wiring (rider 2).
Facts behind it: both Xcode test targets are nonisolated (no `SWIFT_DEFAULT_ACTOR_ISOLATION`), Swift
6.0 mode, `MemberImportVisibility` on, fed by file-system-synchronized groups with empty Sources
phases, and already `import GRDB` — the type compiles identically in all three.

**Pieces:**
1. Red-on-old under my own hands — DONE (`1355ecad` record; the log is gitignored): a fresh
   `build-for-testing` of the unmodified tree (`App/Variorum/DerivedData/19b/mobile-bft-old.log`,
   derived data `19b/mobile.noindex`, `-IDEBuildingContinueBuildingAfterErrors=YES`) → `** TEST BUILD
   FAILED **`, exactly the same 6 error sites as the preserved log (no more, no fewer). Its "(27
   failures)" counts failed BUILD COMMANDS (four 6-file compile batches × two archs plus their per-file
   lines) — the failing batches hold 24 files, the likely source of the entry's "~25 files".
2. The six ROW-COPY call sites + the ruled CopiedRow shape — DONE (this commit). Call sites, 19a's
   shape exactly (the copy INSIDE the read closure; every `#expect`/`#require` line byte-identical):
   `MobileLibraryTests` 214 · `MobileMembershipTests` 241, 301 · `MobileShellTests` 280 (`Row.fetchOne(…)
   .map(CopiedRow.init)` — `Optional.map`) · `MobileTutorialWalkTests` 395, 433 (the call-site copy,
   `userPostRows(…).map(CopiedRow.init)`; the helper keeps returning `[Row]` — it is called only inside
   the reads, as on the Mac). The ruled shape: (a) `Tests/VariorumCoreTests/Support/CopiedRow.swift` —
   COMMENT-ONLY change (the body is byte-identical): the header now names its three consumers and how
   each sees it; F4's narrowed duplicate-column text carried verbatim (words unchanged); "keep them
   identical" retired; R2-3's 127-column line re-wrapped (this is its next touch); (b)
   `App/Variorum/Variorum.xcodeproj/project.pbxproj` — ONE `PBXFileReference` (`CopiedRow.swift`) in a
   new `TestSupport` `PBXGroup` (`path = ../../Tests/VariorumCoreTests/Support`, under the main group),
   TWO `PBXBuildFile`s, one in each TEST target's Sources phase; (c) `git rm` of the Mac twin (no harness
   stop). **RIDER 1 — zero app-target lines, PROVEN from the diff** (both files converted to JSON with
   `plutil`, every object compared — `App/Variorum/DerivedData/19b/pbxproj-object-diff.txt`): REMOVED
   none; ADDED exactly the file reference, the two build files and the `TestSupport` group; CHANGED
   exactly three objects — the project's main group (`children` gains `TestSupport`), `VariorumTests`'
   Sources phase `E1C271912FFC2F440084BEA6` and `VariorumMobileTests`' `E1D217642FFCE2C600886CFC`
   (`files: [] → [the build file]`); all six `PBXNativeTarget`s, every build configuration, and both app
   targets' Sources phases (`E1C271842FFC2F420084BEA6` Variorum, `E1D217582FFCE2C500886CFC`
   VariorumMobile) byte-equal.
   **Builds:** mobile `build-for-testing` (generic iOS Simulator) → **`** TEST BUILD SUCCEEDED **` on the
   FIRST iteration** (`mobile-bft-1.log`; the shared file compiled `in target 'VariorumMobileTests'` from
   `Tests/VariorumCoreTests/Support/CopiedRow.swift`) — **the census is FINAL: 6 sites in 4 files**,
   no SIL-stage extension site surfaced (unlike 19a's core and Mac targets). Mac `build-for-testing` →
   `** TEST BUILD SUCCEEDED **` (`mac-bft-1.log`; the shared file compiled `in target 'VariorumTests'`,
   zero references to the deleted twin). Core `swift build --build-tests` → `Build complete!`, exit 0
   (`core-build-tests.log`).
   **The ten non-erroring `Row.fetch*` reads** (named in the census paragraph) — checked, OUT OF SCOPE:
   each already maps its rows to Sendable values INSIDE the closure (`.map { ($0["kind"], $0["text"]) }`,
   `.map { $0["deleted_at"] as String? }`, `.reduce(into: [String: String]())`, …), so no `Row` crosses
   the async read — they are already in the copy-inside-closure shape.
3. The `#expect`/`#require` unused-result census over the green build log — DONE (this commit): see
   the WARNING CENSUS below. **ZERO unused-result warnings inside any `#expect`/`#require` expansion in
   the mobile test build** (acceptance line met).
4. Suites green on a concrete simulator — DONE (this commit). Every suite type in the four touched
   files (14 suites: `MobileLibraryTests` · `MobileLibrarySortTests` · `MobileMembershipTests` ·
   `MobileNoteRenameTests` · `MobileNoteEntryDateTests` · `MobileShellTests` · the eight
   `MobileTutorialWalkTests.swift` suites), `test-without-building`, suite-level `-only-testing`, on the
   project's established destination `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`: **`Test run
   with 62 tests in 14 suites passed … with 2 known issues`** (62 = the files' `@Test` count exactly),
   ZERO `skipped:` lines (`mobile-suites-1.log`). The 2 known issues are the STANDING deliberate
   `withKnownIssue` in `theFannedDivideLessonLandsTheDuplicateShape` (`MobileTutorialWalkTests` 919–,
   13u1 ladder F-5 `0af79a38`, its KnownIssues row owned by the mobile project) — untouched here. **Every
   test holding a migrated site passed BY NAME:** `theNewNoteDoorMintsANamelessNote` (Library) ·
   `renameWritesTrimsAndBlankClears` + `setAndClearTheEntryDate` (Membership) ·
   `theShelfNewNoteDoorIsTheLibrarysTwin` (Shell) · `restoreReplacesWholesaleAndTouchesNothingElse`
   (TutorialWalk, both reads + the `[CopiedRow] ==` wholesale pin). **The read shapes (for the
   review):** `(x?["c"] as String?) == nil` and `as Int?` and `[copies] == [copies]` are 19a's covered
   shapes; two shapes are NEW here — `x?["c"] == nil as String?` (Membership 243/303) and `x?["c"]` passed
   to a `String?` parameter (`DisplayTitle.day(fromStamp:)`, `TimelineItem(createdAt:)`, Library
   217/221). Evidence in place, not in a mimic (R2-1): Membership 243/303 read a SQL NULL — had the copy's
   generic subscript bound a NON-optional `String`, GRDB's decode traps on NULL and the test dies; it
   passed, so the binding is `String?`, the only one that can read nil there, as `Row`'s did. Library
   217/221 read a NOT NULL `created_at` into `String?` parameters (no untyped-subscript candidate
   converts to `String?`), where `String` and `String?` bindings decode the same value.
5. Rider 3's Mac re-run — DONE (this commit). Every suite type in the nine Mac files that consume
   `CopiedRow` (40 suites; `BookStructureTests` · `CanvasAndPoolTests` · `CanvasBankTests` ·
   `CanvasDragTests` · `LifecycleFacesTests` · `PoolDragTests` · `StructuralGestureTests` ·
   `TagAndFolderTests` · `TutorialWalkTests`; the non-suite `CanvasDragRig` helper excluded) from the
   re-pointed build: **`✔ Test run with 213 tests in 40 suites passed`** (213 = those files' `@Test`
   count exactly), ZERO `skipped:` lines, at a ZERO-INSTANCE window — `pgrep -fl
   'Variorum.app/Contents/MacOS'` empty before (13:59:49Z) and after (14:01:14Z) (`mac-suites-1.log`,
   `mac-suites-1.window`). The re-pointed file serves the Mac target identically. **Extra, core:** the
   two core consumers' five suites (`JournalKeeperRepairTests` · `TheDrainOrderTests` ·
   `SchemaLockstepTests` · `SchemaVersionTransportTests` · `Phase11SyncConvergenceTests`) —
   **`✔ Test run with 29 tests in 5 suites passed`**, no `skipped:` line (`core-copiedrow-suites.log`;
   the core file's change is comment-only).

**DISPOSITIONS (every census site):** all six **FIXED** (ROW-COPY): `MobileLibraryTests` 212 ·
`MobileMembershipTests` 239, 299 · `MobileShellTests` 270 · `MobileTutorialWalkTests` 395, 433.
Evidence class (19a's reading of pin-before-fix for a toolchain migration): red-on-old IS the failing
build (`mobile-bft-2.log` preserved + `mobile-bft-old.log` by my hands, the same six); green-on-new is
the TEST BUILD SUCCEEDED + the suites above. Nothing DISMISSED, nothing DEFERRED inside the scope. The
ten non-erroring `Row.fetch*` reads: out of scope, already copy-inside-closure (piece 2). **Assertion
bytes:** ZERO `#expect`/`#require` lines in the diff (`git diff 52edc1f9..HEAD -- App Tests | grep -E
'^[-+].*#(expect|require)'` is empty). **Acceptance lines:** mobile TEST BUILD SUCCEEDED ✔ · the touched
files' suites green on a concrete simulator, counts confirmed, `skipped:` read ✔ · zero unused-result
warnings inside `#expect`/`#require` expansions ✔ · F4's narrowed comment carried into the ONE file ✔ ·
the ruling's riders 1–5 ✔ (1: the object diff; 2: `3c70b283` carries the wiring AND the deletion; 3:
core build-tests, Mac bft, rider-3 suites, mobile; 4: the comment fate; 5: the `git rm` met no stop).

**FOR THE COLD REVIEW — the diff, by class (`git diff 52edc1f9..HEAD -- App Tests`):**
- ROW-COPY: `App/Variorum/VariorumMobileTests/{MobileLibraryTests,MobileMembershipTests,MobileShellTests,
  MobileTutorialWalkTests}.swift` — six `.map(CopiedRow.init)` insertions inside read closures.
- THE ONE FILE: `Tests/VariorumCoreTests/Support/CopiedRow.swift` — comment-only (`git diff -w` shows no
  code line); `App/Variorum/VariorumTests/CopiedRow.swift` deleted; `App/Variorum/Variorum.xcodeproj/
  project.pbxproj` — the four added objects + three changed objects of rider 1's proof.
- Check: the shared file compiles `in target 'VariorumTests'` and `in target 'VariorumMobileTests'` from
  its core path (the build logs); no app target's objects changed; every `#expect` line byte-identical.

**NOTICED (routed to the orchestrator; none acted on):**
1. **The mobile ISOLATION warnings (20 = 17 + 2 autoclosure + 1 static, five files:
   `MobileMarkdownTests`, `MobileTakesBrowserTests`, `MobileCommentDraftTests`, `MobileCommentParkTests`,
   `MobileProtectionTests`)** are the 19a F3 / 19c Arm 2 class on the phone side — one toolchain
   promotion from red. A candidate widening of 19c Arm 2 (the orchestrator's routing call).
2. **`UIWindow.init(frame:)` deprecated in iOS 26 (10 sites in 7 files, the hosted-surface rigs)** —
   cosmetic today; `init(windowScene:)` needs a scene in a test host, so it is not a mechanical swap.
3. **The census-number lesson, refined:** an xcodebuild failure summary's "(N failures)" counts failed
   BUILD COMMANDS (batch lines + per-file lines × archs), and a continue-after-errors log's warning
   lines outnumber its errors — quote the unique `error:` lines, and include the
   `macro expansion #expect:` lines when counting warnings (they carry no file path).

**Commits:** `1355ecad` (record opened) · `3c70b283` (pieces 1–3: the six sites, the ruled CopiedRow
shape, the census) · this commit (pieces 4–5, dispositions, State → REVIEW-PENDING).

**THE WARNING CENSUS (the mobile TEST target, the green build `mobile-bft-1.log`; counts + classes only,
no fixes — routing is the orchestrator's at the close; the full line list is
`App/Variorum/DerivedData/19b/mobile-warning-census.txt`):** **60 unique warnings in 20 files** (each
printed once per arch). The test-target set is IDENTICAL between the red-on-old fresh build and the green
one — fixing the six sites surfaced no new warning. NOTE for any re-count: two of the 60 are reported at
`macro expansion #expect:1:N`, not at a file path, so a `^/…: warning:` grep finds only 58.
| Class | Count | Sites (file:line) |
|---|---|---|
| UnnecessaryEffectMarker — "no calls to throwing functions occur within 'try'" | 20 | `MobileNoteClipboardTests` 86/111/131/148/165/191 · `MobileTrashTests` 54/82/112/261/408/419 · `MobileUndoDoorTests` 116/194/220 · `MobileDeletionTests` 270 · `MobileEditTraceTests` 343 · `MobileEmptyStoreTests` 120 · `MobileTutorialWalkTests` 919 · `MobileProtectionTests` 1572 (INSIDE an `#expect` expansion: `#expect(try await PostureSwitchRunner.pendingMarker(…) == nil)`) |
| ISOLATION — main-actor property read from a nonisolated context | 17 | `MobileMarkdownTests` 646/647/648/649/651×2/653/656 · `MobileTakesBrowserTests` 741×2/956/957/963 · `MobileCommentDraftTests` 54/55 · `MobileCommentParkTests` 57/58 |
| ISOLATION — main-actor property read from a nonisolated AUTOCLOSURE | 2 | `MobileMarkdownTests` 657×2 |
| ISOLATION — main-actor STATIC property from a nonisolated context | 1 | `MobileProtectionTests` 620 (INSIDE an `#expect` expansion: `EncryptionView.keysReplacedExplanation`) |
| DeprecatedDeclaration — `UIWindow.init(frame:)` (iOS 26: "Use init(windowScene:)") | 10 | `MobileBlockHistoryTests` 579/688 · `MobileKeyboardBarGeometryTests` 254/584 · `MobileTakesBrowserTests` 768/944 · `MobileCommentDraftTests` 70 · `MobileCommentParkTests` 70 · `MobileLivenessTests` 400 · `MobileSurfaceDriver` 218 |
| "`#require(_:_:)` is redundant because … never equals 'nil'" | 4 | `MobileCrossBlockEditTests` 144/163/210/310 |
| "conditional cast … always succeeds" | 2 | `MobileQuickNoteTests` 1172/1188 |
| NoUsage — "expression of type 'Bool' is unused" | 2 | `MobileWriteLatchTests` 100/101 — `await first.value` / `await second.value` (a `Task<Bool>`'s value as a bare STATEMENT, NOT inside any `#expect`/`#require` expansion) |
| NoUsage — "immutable value … was never used" | 1 | `MobileUndoDoorTests` 250 |
| VariableNeverMutated | 1 | `VaultRPCEmulation` 104 |
**The F1 census rule applied:** zero "result of call … is unused" / unused-result warnings inside any
`#expect`/`#require` expansion (the build's only two in-expansion warnings are the isolation and
effect-marker lines above). **The rule's SILENT half is NOT cleared and is NOT this entry's:** a
`@discardableResult … -> Bool` callee asserted bare takes the vacuous route with NO warning — 19a
R2-2's named mobile candidates (`MobileMarkdownActs.swift:90–91` asserted bare at
`MobileMarkdownTests.swift:389/397/453/551/563`) carry no warning in this build, as the rule predicts;
settling them by in-place mutants is 19c Arm 1's, sequenced after this entry (the mobile test build now
exists for it).

---

## 19c RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract):** (1) no walk capture — no product face
changed: the landed diff is 12 TEST files (19 local/helper declarations and one test gaining
`@MainActor`) and this record; every Arm-1 edit was a reverted probe; so the acceptance is builds +
suites + the census, as 19a's and 19b's were; (2) NO re-spell — the census found ZERO vacuous sites,
so no assertion byte changed anywhere; (3) ONE site not settled: `AppleKeyRoundTripTests.swift:97`
lives in an opt-in suite that writes a synchronizable item into her iCloud Keychain — a session never
runs it; RECORDED; (4) the silent class's WIDER edge (imported ObjC/C `BOOL` methods, which Swift
treats as discardable) is outside the entry's stated callee universe — measured by the
compiler-level census, not mutant-settled; NOTICED below; (5) NO full suite — only the Arm-1
census suites (baseline + mutant) and the Arm-2 touched files' suites; (6) no `Sync/`, no schema,
no app source landed (the mutants touched `Shared/` custody files and two core `Sources` files
TEMPORARILY, restored — `mutants.diff`), no Release build, `/Applications` untouched (no Mac-app
change — no refresh owed); `Tools/Release/`, 13r's DerivedData folders and the 13r plan untouched;
(7) the NOT-OWNED classes untouched: the 10 `UIWindow.init(frame:)` deprecations and
`MobileProtectionTests`' unnecessary `try` (1572 → 1573 after this entry's one inserted line).

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match. Base `e8a0950e` (no code
change since 19b's `3c70b283`; every commit after it touches `notes/` only). Evidence logs:
`App/Variorum/DerivedData/19c/` (gitignored, 4.8 GB with its two derived-data folders, kept for the
review); every census script and output is in its `census/` subfolder.

**THE METHOD (decided before any edit; the reviewer checks it):**
- **Arm 1 enumeration, two independent censuses.** (A) the GREP census the entry asks for — every
  `@discardableResult` declaration in `Sources` + `App/Variorum/{Variorum,Shared,VariorumMobile}`
  whose return type is `Bool`/`Bool?` (a balanced-paren signature parse, not a line grep), PLUS
  the same attribute on test-target helpers (an extension of the stated universe — the mechanism
  does not care where the callee lives; recorded as such); then every `#expect(`/`#require(` in
  the three test targets whose first argument, after `try`/`await`/`!`/outer parens, is a call
  whose final name is one of those callees, each RESOLVED by hand to its declaration (name
  collisions are many: `settle`, `poll`, `save`, `apply`…). (B) a COMPILER-LEVEL cross-check
  (DONE — piece 3): which `__checkFunctionCall` overload each expansion actually CALLS, read from the
  test objects' relocations (`llvm-objdump -d -r -l`; the line annotations name the macro buffer,
  whose mangled name carries the original line) — the `-> R?` overload under an `#expect` is the
  vacuous route by construction. (B) ranks and cross-checks; it never clears (R2-1).
- **Arm 1 settlement — the CALLEE-NEGATION mutant, in place.** Each in-class callee keeps its
  exact declaration (attributes, name, parameter clause, effects, return type) and its body is
  renamed aside behind a wrapper of the identical signature that calls it and returns the
  NEGATED Bool. Every call site stays byte-identical (the import graph, the spelling and the
  overload set are untouched; only the runtime value flips), every side effect still happens,
  and every assertion over the callee's Bool — bare, `!`-negated, `try`/`await`-prefixed or
  `== true/false` — must go RED if it is real. A site that stays green under its callee's
  mutant (and is proven REACHED) is VACUOUS. Re-spelled sites must then go RED under the same
  mutant on the new spelling, and green without it. Mutants are reverted with
  `git checkout --` of COMMITTED files only (the resiliency protocol's rule 11) and verified by
  `git status`/`git diff`.
- **Arm 2:** the warning census from fresh `build-for-testing` logs (Mac + mobile), the
  isolation class's sites per file, test-side `@MainActor` (19a F3's shape), assertion bytes
  unchanged, rebuild to zero.

**Pieces:**
1. The grep census (A) — DONE (`1df8793c`; resolution encoded in `census/resolve.py`, output `census/resolved.tsv`):
   95 `@discardableResult … -> Bool/Bool?` declarations in the four code roots (19 core, 33 Mac,
   21 Shared, 22 mobile — 19a's "65" predates the mobile arm) + 17 test-target helpers; 369
   name-matched assertion sites → **261 IN-CLASS** (core 5 · Mac 169 · mobile 87; by shape: 141
   BARE, 104 `try`/`await`-prefixed, 16 `!`-negated) + the 3 named `== true/false` lines
   (`BookStructureTests` 782/786/793, settled by the same mutant) = **264 sites to settle**; **108
   OUT** with the reason per site (76 file-local non-discardable `settle`; 22 CLOSURE-property calls
   — `StoreKeyCustody.save`, `DeviceKeyStore.save`, `StoreKeyGuard.saveGated`/`removeLegacyEscrow`
   — which warn when discarded (scratch-verified); `LegacyLegs.apply` ×3 and the Mac
   `MarkdownActs.toggleCheckbox` ×2, not discardable; 4 Optional-returning `#require` unwraps;
   one file-local `run`).
2. Fresh builds — DONE (`11eb4820`; `mac-bft-0.log`, `mobile-bft-0.log`: `** TEST BUILD SUCCEEDED **`; core up
   to date at HEAD). **The census rule's visible half:** zero unused-result warnings inside any
   `#expect`/`#require` expansion in either build (the only in-expansion warnings: Mac
   `SyncEnrollmentTests:262`'s known `!= nil`; mobile `MobileProtectionTests:1572`'s `try` and
   `:620`'s isolation read — Arm 2's).
3. The compiler-level cross-check (B) — DONE (`11eb4820` + `1df8793c`). ZERO `#expect` expansions on an Optional-returning
   route in Mac (18,950 `__check` calls), mobile (3,623) or core (8,997); **positive control
   PASSED and RESTORED**: `CatalogDetailWordsTests.swift:49` re-spelled to F1's bare `.tag("t1")`
   flipped to `__checkFunctionCall … OPT` (and its unused-result warning returned —
   `core-bt-posctl.log`, `core-routes-posctl.tsv`); `git checkout --` restored it, the route read
   VOID again (`core-routes-restored.tsv`), tree clean.
4. Mutant runs — DONE (`b0f94351`). **Baselines GREEN on the unmutated tree** (zero-instance window):
   Mac 44 suites `Test run with 362 tests in 44 suites passed … with 5 known issues`
   (`mac-base-1.log`; 8 skips = the opt-in `DebugOracleSingletonWindowTests` suite), that suite
   run deliberately ALONE with `TEST_RUNNER_VARIORUM_ORACLE_SINGLETON_WINDOWS=1` (its own gate's
   instruction): 7 tests passed (`mac-base-singleton.log`); mobile 24 suites `206 tests … passed
   … with 2 known issues` (`mobile-base-1.log`, iPhone 17 Pro / iOS 26.2, 0 skipped); core
   `StoreEncryptionMigrationTests` 9 passed (`core-base-1.log`). **NOT RUN, BY DESIGN:**
   `AppleKeyRoundTripTests` (opt-in: writes a synchronizable item into her iCLOUD Keychain — her
   act, never a session's) — its one site is recorded unstageable here.
   **THE MUTANT RUNS — DONE; MUTANTS RESTORED** (44 callees — 27 Mac-reachable, 15 mobile, 2
   core — via `census/mutate.py`; the full mutant diff is `mutants.diff`; restored with
   `git checkout --` of the 30 files, `git status` clean, zero `__mut19c` left in the tree).
   Mutant mechanics the reviewer should check: the wrapper copies the header bytes from the first
   attribute line (so `@MainActor` above `@discardableResult` rides both copies); unqualified calls
   INSIDE a renamed original to another function mutated in the same file are redirected to that
   function's original (`saveGated`→`deleteGated`, `typeAtEnd`→`typeEdit`, the recursive
   `MenuActionHandler.activate`) so each wrapper flips only what leaves it — without that,
   `typeAtEnd`'s sites would have read a double negation; and a mutated file's lines below the
   wrapper SHIFT, so `census/settle.py` maps every original site line into the mutated file
   (difflib over `git show HEAD:` vs the mutated file) before reading the log's issue locations.
   **Results — every runnable site RED at its own line under its callee's mutant:**
   core `StoreEncryptionMigrationTests` 5/5 (`core-mut-1.log`, 9 tests, 17 issues) · Mac 154/154
   in 44 suites (`mac-mut-1.log`: `Test run with 362 tests in 44 suites failed … with 323 issues`
   — the same 362 as the baseline) · the opt-in singleton suite, run alone, 17/17
   (`mac-mut-singleton.log`, 7 tests, 17 issues) · mobile 87/87 (`mobile-mut-1.log`; 24 suites).
   **No candidate line carried an issue in its baseline** (the baselines' only issue lines:
   `IndexTierMetricsTests:274` ×4 and `TakesFindBoardTests:431` — the standing known issues —
   and mobile `MobileTrashTests:497/498`, known issues; none a census site). Mutant-only
   fallout, recorded: downstream production code branches on several of these Bools, so other
   assertions also moved (e.g. `MobileWalkTests` walk3's text checks after a flipped
   `toggleCheckbox`), and in `walk3_markdownVocabularyByteStable` the mobile DEBUG identity
   oracle killed the host (`MobileEditorViewModel.swift:1682`, "surface desynced") — the runner
   restarted and finished the suite; every census site had already recorded its red. Neither
   occurs on the restored tree. **Settlement table:** `census/{core,mac,singleton,mobile}-settle.tsv`
   (site → RED/GREEN → issue count). **VERDICT: 263 sites REAL with mutant evidence; ZERO
   VACUOUS; 1 RECORDED** (`AppleKeyRoundTripTests.swift:97`, the iCloud-Keychain opt-in — a
   session never runs it; its expansion calls the `-> Bool` overload, a rank, not a clearance).
5. Re-spells — NONE OWED (zero vacuous sites; no assertion byte changes in Arm 1).
6. Arm 2 — DONE (`d2e43ea4` the code; `a7bbaac1` the suites). The warning-grade main-actor reads sat in
   LOCAL helper functions (Swift 6.4 does not give a local `func` its enclosing test's isolation —
   every suite here is already `@MainActor`), one nested struct method, two file-scope `private
   func find`s and ONE synchronous test; the treatment is test-side `@MainActor` on exactly that
   context (19a F3's shape; the local-function spelling follows `PoolDragTests:299`'s `@MainActor
   func poll`): **Mac** — `BookViewTests` `walk` ×2 / `count` / `views`; `LibraryPanelTests`
   `Mounted.tearDown`; `PagedReadTests` `walk` AND its caller `drawnPages` (the first build said
   so: `error: call to main actor-isolated local function 'walk' in a synchronous nonisolated
   context` — `walk` is nested in `drawnPages`, `mac-bft-arm2.log`; fixed the same way,
   `mac-bft-arm2b.log` green); `ReadNoteLandingTests` `scrollViews`; `ReadTierTests` `hasDecor` /
   `hasBadge`; `TakePaneMeasureTests` `findPane` (the one at 561 — the file's other seven
   `findPane`s never warned and are untouched); `TutorialWalkTests` `hasBadge` / `badgeYs`.
   **Mobile** — `MobileCommentDraftTests` / `MobileCommentParkTests` file-scope `find`;
   `MobileMarkdownTests` `labels`; `MobileTakesBrowserTests` `subview` / `find` / `cardsScroll`;
   `MobileProtectionTests` — `@MainActor` on the ONE synchronous test
   `theReconciledStringsNameThePhone` (its line-620 `#expect` reads the main-actor static
   `EncryptionView.keysReplacedExplanation`; the attribute line shifts the file's later lines by
   one — the NOT-OWNED unnecessary `try` now sits at **1573**). **Diff:** 12 files, 20+/19−, every
   changed line a declaration gaining `@MainActor` (plus the one attribute line); **zero
   `#expect`/`#require` lines changed** (`git diff -U0 | grep '#(expect|require)'` empty).
   **Census after (full test-target recompiles — the test targets' intermediates deleted first so
   every test file re-emits its diagnostics; `mac-bft-arm2-full.log`, `mobile-bft-arm2-full.log`,
   both `** TEST BUILD SUCCEEDED **`):** Mac test-file warnings 97 → **74**, the removed set
   EXACTLY the 23 isolation lines in the 7 files, nothing added; mobile 60 → **40**, the removed
   set EXACTLY the 20 (17 + 2 autoclosure + the in-expansion static), nothing added; **ZERO
   isolation warnings left in either test target** — what remains is the recorded NOT-OWNED
   classes (10 `UIWindow.init(frame:)` deprecations; `MobileProtectionTests:1573`'s `try`) and the
   other cosmetic classes 19a/19b recorded. **Arm 1 still holds after Arm 2:** the route census
   re-run on the recompiled objects is IDENTICAL per (file, macro, check, route) on both targets,
   zero `#expect` on an Optional route (`mac-routes-arm2.tsv`, `mobile-routes-arm2.tsv`).
   **Suites — DONE:** every suite type in the 12 touched files (`census/arm2-suites.tsv`),
   `test-without-building`, suite-level `-only-testing`: **Mac `✔ Test run with 160 tests in 23
   suites passed`** (160 = those 7 files' `@Test` count exactly; ZERO `skipped:` lines; a
   ZERO-INSTANCE window — `pgrep` empty before 15:24:34Z and after 15:27:22Z,
   `mac-arm2-suites-1.{log,window}`; the TK2 tripwire `TakePaneMeasureTests` among them, green) ·
   **mobile `✔ Test run with 106 tests in 17 suites passed`** (106 = those 5 files' `@Test` count
   exactly; ZERO `skipped:` lines; iPhone 17 Pro / iOS 26.2; `mobile-arm2-suites-1.log`).
7. Acceptance + the census table + dispositions — DONE (`a7bbaac1`). State → REVIEW-PENDING.

**THE CENSUS TABLE (Arm 1 — every in-class site, by callee; the per-site rows with their issue
counts are `census/{core,mac,singleton,mobile}-settle.tsv`, the resolution `census/resolved.tsv`):**

| Callee (`@discardableResult … -> Bool`) | Sites (file: lines; shape B bare · N `!` · E try/await · Q `== true/false`) | Result under its negation mutant |
|---|---|---|
| StoreEncryptionMigration.migrateIfNeeded | StoreEncryptionMigrationTests 114E,142E,206E,334E | 4 RED |
| StoreEncryptionMigration.rekey | StoreEncryptionMigrationTests 221E | 1 RED |
| AppleKeyKeychain.delete | AppleKeyRoundTripTests 97B | 1 RECORDED |
| CommandRouter.requestBlockHistory | BlockHistoryHostTests 153B,165B,181B · BlockHistoryPaneTests 160B,199N,202B | 6 RED |
| CommandRouter.requestMode | BlockHistoryHostTests 159B,168B,206B,207B,209B · CommandRoutingTests 91B,96B,97N,106N,960N,1033B · CurrentBlockContinuityTests 187B,198B,204B,217B,319B,329B,343B,368B,454B,462B,477B · MastheadLayoutTests 79B · ModeSwitchCarryTests 209B,216B,311B,427B · ModeSwitchFeelTests 217B,220B,403B · NoteOpenLandingTests 319B,509B,512B · PostDetailAndPanelTests 164B | 34 RED |
| EditorViewModel.pickBlock | BlockManagementTests 151B,486B,494B,531B · TrashSurfaceTests 540B,767B · TutorialWalkTests 2489B,2491B,2949B | 9 RED |
| (test helper) BlocksWorkbenchFaceTests.Rig.poll | BlocksWorkbenchFaceTests 256E,263E,314E,336E · PagesArrowKeysTests 104E,112E,134E · RowClickTests 127E | 8 RED |
| BookOutlineHeights.stand | BookHeightManifestTests 275B,278N | 2 RED |
| BookPanelModel.drop | BookPanelTests 296E,301E | 2 RED |
| CommandRouter.dispatch | BookViewTests 770N,775B,1175N,1182B,1194B · CommandRoutingTests 127N,141B,143B · TakesFindBoardTests 479B | 9 RED |
| (test helper) DebugOracleWindowRig.settle | DebugOracleSingletonWindowTests 95E,106E,112E,131E,153E,165E,209E,217E,264E,275E,313E,322E,359E,368E,391E,400E · DebugOracleTwoWindowTests 252E,269E,294E,330E,344E,379E,394E,437E,444E,475E,486E,522E,527E,538E,543E | 31 RED |
| CommandRouter.requestNoteTray | DebugOracleSingletonWindowTests 110B · SideColumnTests 131B · TrayPanelMoveTests 114B,134N | 4 RED |
| MarkdownStyling.style | FormattingSurfacesTests 183B,205B | 2 RED |
| MarkdownStyling.restyle | FormattingSurfacesTests 211B | 1 RED |
| (test helper) IndexClickCaretTests.Rig.poll | IndexClickCaretTests 415E,470E,472E · IndexTierMetricsTests 351E,370E,393E,427E,457E,486E | 9 RED |
| MarkdownActs.apply | MarkdownActsTests 96B,123B,146B,167B,191B | 5 RED |
| CommandRouter.requestTagField | MastheadLayoutTests 438B | 1 RED |
| CommandRouter.requestNoteVersions | NoteVersionsPaneTests 119B,142N,144B | 3 RED |
| RuleEditorModel.save | OutflowChooserTests 126E,149E,166E,202E,231E · RuleEditorTests 230E,254E,287E,318E,347E,372E,395E · TimelineAndReadingsTests 148E | 13 RED |
| WorkspaceModel.closeSplit | PaneSplitTests 195B,265B · SavepointOnLeaveTests 203B | 3 RED |
| StoreKeyGuardKeychain.saveGated | Phase13pKeychainFactTests 240B,264B,266B | 3 RED |
| StoreKeyGuardKeychain.deleteGated | Phase13pKeychainFactTests 249B,287B | 2 RED |
| (test helper) ReadModeTests.Rig.poll | ReadModeTests 220E,224E,226E,235E,238E,239E,256E,260E,262E,266E,437E,443E | 12 RED |
| Operations.removePostFromReading | SampleLibraryWelcomeTests 475E | 1 RED |
| KeychainAuthStorage.save | SessionTokenBindingTests 108B,147B | 2 RED |
| KeychainAuthStorage.clear | SessionTokenBindingTests 115B,152B | 2 RED |
| StoreKeyCustody.deviceKeychainRemove | StoreKeyBindingTests 198B | 1 RED |
| TakesBoardLayout.noteArticleRowFrame | TakesArticleScrollTests 2005B,2006B | 2 RED |
| WingsModel.mint | WingSwitcherTests 69E | 1 RED |
| (test helper) MenuActionHandler.activate | MobileBlockMenuTests 286B | 1 RED |
| MobileCommentsController.add | MobileCommentDraftTests 127E,152E · MobileCommentParkTests 96E,331E | 4 RED |
| MobileCommentsController.submitDraft | MobileCommentDraftTests 156E · MobileCommentParkTests 160E,348E,364E,370E | 5 RED |
| MobileBookDetailsModel.archiveDailyJournal | MobileDailyJournalArchiveTests 56E | 1 RED |
| MobileEditorViewModel.deleteNote | MobileDeletionTests 60E,291E | 2 RED |
| (test helper) HostedSurface.activate | MobileDeletionTests 88B,90B,238B,240B,277B,363B · MobileQuickNoteTests 1017B · MobileShelfTodayDoorTests 64B,112B · MobileTrashTests 88B,94B,116B,265B,295B,364B,423B · MobileUndoDoorTests 119B,198B,204B,223B,283B,379B | 22 RED |
| (test helper) HostedSurface.tapAlertAction | MobileDeletionTests 153B,243B,331B · MobileTrashTests 323B,379B · MobileUndoDoorTests 320B,382B | 7 RED |
| MobileLibraryViewModel.confirmDeleteNote | MobileDeletionTests 197E | 1 RED |
| (test helper) typeEdit (free func) | MobileEditRoutingTests 532B · MobileEditTraceTests 216B · MobileEditorTests 655B,686B,709B · MobileLivenessTests 80B,85N,209B,214N · MobileNoteClipboardTests 80B · MobileTakesBrowserTests 278B · MobileTakesTests 148B,173B,207B,242B,253B,278B,382N,404N | 19 RED |
| MobileLensesModel.saveCurrentView | MobileLensesTests 200E · MobileTutorialWalkTests 827E | 2 RED |
| MobileMarkdownActs.apply | MobileMarkdownTests 389B,397B,453B,551B,563B,574N | 6 RED |
| MobileMarkdownActs.toggleCheckbox | MobileMarkdownTests 825B,834B,857N,871B · MobileTutorialWalkTests 658B · MobileWalkTests 185B | 6 RED |
| MobileReferencesModel.addURL | MobileReferencesTests 37E,38E,67E | 3 RED |
| MobileScrapsModel.mintScrap | MobileScrapsTests 66E,72E,175E,208E | 4 RED |
| (test helper) typeAtEnd (free func) | MobileTutorialWalkTests 591B,594B,595B,596B | 4 RED |
| BookStructureModel.acceptDrop | BookStructureTests 782Q,786Q,793Q | 3 RED |

**Totals: 264 sites — 263 REAL (RED at their own line under their callee's mutant), 0 VACUOUS,
1 RECORDED (the iCloud-Keychain opt-in).** By target: core 5 · Mac 171 (154 in the 44-suite run +
17 in the opt-in singleton suite run alone) · mobile 87 · + the recorded one. The 19a-named
candidates (`MarkdownActsTests` 96/123/146/167/191, `BookStructureTests` 782/786/793) and the
R2-2 mobile arm (`MobileMarkdownTests` 389/397/453/551/563, plus 574's negated twin) are ALL REAL.
The out-of-class remainder (108 sites, `census/resolved.tsv` with a reason per row) needs no
mutant: each callee warns when its result is discarded, and both fresh builds carry ZERO
unused-result warnings inside any expansion (the census rule's visible half).
**#require, checked the same way:** every `#require` on an Optional route is the unwrap
overload doing its job; the 48 whose macro starts the statement (where a discarded Bool would
hide) were read one by one — every condition is Optional-typed (`fetchVault`, `Queries.reading`,
`RuleGrammar.encode`, `fetchOne`, a failable `DayBounds` init, …;
`census/require-opt-statement-sites.txt`). **[THE FIRST SENTENCE IS CORRECTED AT ROUND 1
(F1, MAJOR) — kept un-deleted beside its correction, the 19a custom: 38 compiler-flagged
sites take the `NonOptionalRequireMacro` route (`try?` position, or `try #require` where an
Optional is expected), where a nil records NOTHING at its own line. The statement-form
reading above was sound; the clearance it implied for the whole macro was not. The class is
19d's; the ROUND 1 section carries the mechanism and probes.]**

**DISPOSITIONS:** Arm 1 — the census is the deliverable: 263 sites **REAL with mutant evidence**
(no fix owed; nothing to re-spell) · 1 **RECORDED** (`AppleKeyRoundTripTests.swift:97`, unrunnable
by a session; its expansion calls the `-> Bool` overload — a rank, never a clearance; it settles
the day she next runs that opt-in drill with the negation mutant in place, if she wants it
settled — no row is opened without her owner) · 0 vacuous. Arm 2 — **FIXED, all 43 warnings**
(Mac 23 in 7 files, mobile 20 in 5 files): red-on-old IS the warning census of the fresh
pre-entry builds (`mac-bft-0.log`, `mobile-bft-0.log`); green-on-new is the full test-target
recompiles' census (zero isolation warnings left, nothing added) + the touched suites green.
Nothing DISMISSED, nothing DEFERRED.

**ACCEPTANCE LINES:** the census table in the record, with mutant evidence per site ✔ · zero
isolation warnings in the Mac test build AND the mobile test build beyond the recorded not-owned
classes ✔ · the touched suites green at a quiet window, counts confirmed, `skipped:` read ✔.

**NOTICED (routed to the orchestrator; none acted on):**
1. **The silent half of the census rule is WIDER than `@discardableResult`.** Swift imports
   ObjC/C methods as discardable unless they are marked `warn_unused_result`: in a scratch
   typecheck under this toolchain, `FileManager.fileExists(atPath:)`, `NSTextView
   .shouldChangeText(in:replacementString:)`, `becomeFirstResponder()` and `NSString.hasPrefix`
   discard silently, while the Swift stdlib's `contains`/`hasPrefix` and CoreGraphics'
   `intersects` warn. The test targets assert such calls bare (by callee name among the 5,898
   call-shaped conditions: `fileExists` 52, `shouldChangeText` 21, …). They are outside this
   entry's stated universe and NOT mutant-settled — but the compiler-level census below already
   reads them: none sits on the vacuous route at HEAD.
2. **A cheap, exact tripwire exists for this whole class** — `census/routes.py`: every
   `__check*` call in every test object, by macro expansion (the DWARF line annotation names
   the macro buffer, whose mangled name carries the original line) and by the overload the
   COMPILER chose (`-> R?` under an `#expect` = the vacuous route). It is callee-agnostic,
   needs only the build products, runs in about a minute per target, and was validated by a
   positive control (the F1 spelling flips its line to the Optional route; the fix flips it
   back). A candidate standing step for the next toolchain census (a script under `Tools/` or a
   test-plan note) — the orchestrator's or the author's call; not built into the repo here.
3. **Local functions do not inherit their test's `@MainActor` under Swift 6.4** — the whole Arm-2
   class was local helpers inside already-`@MainActor` suites (plus one nested struct method and
   two file-scope helpers). A helper NESTED in another helper needs both annotated
   (`PagedReadTests`' `drawnPages`/`walk`: annotating only the inner one is a compile error).
   Worth one line wherever the project keeps its toolchain lessons.
4. **Mutant fallout worth knowing for the next settlement:** several production paths BRANCH on
   these Bools (a flipped `toggleCheckbox` moved `MobileWalkTests` walk3's text, and the mobile
   DEBUG identity oracle killed that test's host — the runner restarted and finished); a census
   that settles by negation must read issue LOCATIONS, never pass/fail counts, and must map
   lines in files that carry a wrapper (the first read here mis-scored 33 sites GREEN until the
   line shift was mapped — `census/settle.py` does it).

**FOR THE COLD REVIEW — the landed diff (`git diff e8a0950e..HEAD -- App Tests Sources`):** 12
test files, 20+/19−: each changed line is a helper/test declaration gaining `@MainActor` (13
same-line prefixes in 7 Mac files incl. `PagedReadTests`' two; 6 in 4 mobile files; one attribute
line above `MobilePhoneProtectionCopyTests.theReconciledStringsNameThePhone`). Check: no
`#expect`/`#require` line changed; each annotated function is the context the compiler named
(`mac-bft-0.warnings.txt` / `mobile-bft-0.warnings.txt` vs the `*-arm2-full.warnings.txt`);
every caller of an annotated helper is main-actor (the builds say so). **The Arm-1 evidence is
reproducible from the folder:** `census/mutate.py` over `census/*-mutants.txt` re-creates
`mutants.diff`; `census/settle.py` re-scores the mutant logs; `census/routes.py` re-reads any
build's objects. Commits: `fdc841ad` (record opened, method) · `11eb4820` (builds, route census,
positive control announced) · `1df8793c` (census resolved, baselines, mutants announced) ·
`b0f94351` (mutant results, restored) · `d2e43ea4` (Arm 2) · this commit (suites, table,
dispositions, NOTICED, State → REVIEW-PENDING).

---

## 19d RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract) — AS OF ROUND 1:** (0) **round 1's F1
pins hold for ONE of its two sites only:** `BookAscentTests:803` is genuinely silent and FIXED with
its pin; `MarkdownFaceTests:187` is HOLLOW (its old spelling records at its own line under a real
nil — the reviewer's P2 never produced a nil), so it carries no fix claim; its edit stands as an F2
cleanup. (1) ~~18 of the 38 sites NOT re-spelled~~ — **superseded at round 1: the orchestrator took
the cleanup (F2); all 19 hollow sites are now re-spelled behaviour-identically.** (2) **The posture drill
was NOT run** — `PostureSwitchDrillTests` is env-gated OFF (`VARIORUM_POSTURE_DRILL=1`) and stayed
off; line 621's re-spell is evidenced by a same-file throwaway probe + the route census, and the
orchestrator's own-hands verification of both custody-drill re-spells is still owed (the entry's
rule). **[DONE — it PASSED at the round-1 arbitration (strictly stronger / abort-preserved), and
the round-1 reviewer's independent custody read agreed; 19d ROUND 1 records it — R2-3's bracket.]** (3) `SyncEnrollmentTests:262` took the behaviour-identical `_ = try …`, NOT `#expect(throws:
Never.self) { … }` (which would turn abort into continue — test intent). (4) `VariorumMobile/Spike/
SpikeScenarios.swift:240`'s always-true comparison is mobile APP source — not owned, untouched. (5)
No walk capture — no product face changed (15 test files only), so the acceptance is builds +
pins + suites, as 19a–19c's were. (6) No full suite — the touched files' suites (+ the core
hollow-site suites as a sanity run). (7) No `Sync/`, no schema, no custody source, no app or core
source LANDED; the mutants touched four source files TEMPORARILY (`Sources/VariorumCore/Domain/
RuleGrammar.swift`, `Features/Editor/DivideWCeremony.swift`, `EditorCommands.swift`,
`Features/BookView/PagePaginator.swift`), each reverted and sha256-verified; no Release build;
`/Applications` untouched (no Mac-app change — no refresh owed); `AppleKeyRoundTripTests` not run;
`Tools/Release/`, 13r's and 19c's DerivedData folders and the 13r plan untouched.

**Toolchain at session start (re-read, matches the pinned pair):** macOS 27.0 (26A428) · Xcode 27.0
(27A266a) · `xcode-select -p` = `/Applications/Xcode.app/Contents/Developer`. Zero-instance check
(`pgrep -fl 'Variorum.app/Contents/MacOS'`) at session start: no match. Base `5790a095`. Evidence:
`App/Variorum/DerivedData/19d/` (gitignored).

**THE METHOD (decided before any edit; the reviewer checks it):**
- **Census first, from MY OWN fresh builds** (fresh derived-data / scratch paths under `19d/`, so
  every test file re-emits its diagnostics): core `swift build --build-tests --scratch-path
  …/19d/core.build`; Mac and mobile `xcodebuild build-for-testing` (`-derivedDataPath
  DerivedData/19d/{mac,mobile}.noindex`, mobile on `generic/platform=iOS Simulator`). Counted as
  UNIQUE warning lines (file:line:col, plus `macro expansion #require:` lines with their
  "expanded code originates here" note — they carry no path of their own; 19b's counting lesson),
  never "(N failures)". Two classes: "'#require(_:_:)' is redundant because 'X' never equals
  'nil'" and "… always returns true". The reviewer's 38 + 2 is a floor.
- **The re-spell rule, decided by the site's OWN spelling (mechanical, not a judgment of intent):**
  (R) **`try? #require(X)`** — the spelling's own semantics under the overload its author meant
  (`#require<T>(_: T?) -> T`) is RECORD AT THE LINE, THEN CONTINUE with nil (the `try?` swallows the
  throw). The faithful re-spell keeps exactly that: `let x = X` then `#expect(x != nil)` on the next
  line (X evaluated once; every downstream `x?.…` line byte-identical). (A) **`try #require(X)` in an
  Optional-typed position** (an argument or an assignment whose type is `T?`) — the spelling's own
  semantics is ABORT on nil (`try`, not `try?`): HOIST `let y = try #require(X)` onto its own line
  (no type context, the `BookArchiveFacesTests:106` shape), then pass `y`. (C) a `#require` over a
  NON-optional (`FannedDefaultsTests:355`) — pure cleanup, the macro dropped, no pin possible (the
  type proves non-nil). A site that fits none of these, or whose `try?` sits beside contrary
  signals (a force-unwrap downstream, a throwing context that makes the `try?` look accidental),
  STOPS AND REPORTS.
- **The pin discipline (F1's), per site:** a nil/empty MUTANT staged IN PLACE in the real test
  target, keeping the re-spelled line byte-identical — preferring the upstream VALUE (a variable's
  assignment, an input that makes the callee answer nil) over the callee's source; a callee-source
  mutant only where no in-test input reaches nil, announced and reverted with the source
  sha256-verified. **Once per SHAPE** the OLD spelling is shown SILENT at its line under the same
  mutant; **for EVERY site** the NEW spelling is shown RED AT ITS OWN LINE. Scored by issue
  LOCATIONS in the log, never pass/fail counts (19c's lesson). Mutants are announced HERE before
  they run, applied only over COMMITTED files, reverted with `git checkout --`, tree verified clean,
  `grep` for probe strings empty.
- **Family 2:** `PostureSwitchDrillTests:621` → `#expect(!joinerRecord.deviceID.isEmpty, …)`.
  **The drill suite is env-gated OFF (`VARIORUM_POSTURE_DRILL=1`) and STAYS OFF** (the brief's
  binding line — it seeds the corpus and writes real Keychain items); so line 621 cannot be run in
  place by this session. Its evidence is (i) the warning gone from the real target's build, (ii) a
  THROWAWAY probe test in the SAME file (same import graph, the exact assertion spelling, the same
  `SyncCustodyRecord` type) over `deviceID: ""` — the old spelling GREEN (silent), the new RED at its
  line — run once by filter, deleted, never committed (the 19a piece-4 precedent), and (iii) the
  route the compiler chose at line 621 in the real build (19c's `routes.py`, adopted as supporting
  evidence at 19c round 1). FLAGGED for the orchestrator's own-hands verification.
  `SyncEnrollmentTests:262` → the dead `!= nil` removed, the throw kept as the check, record-and-
  continue kept (the spelling decided at build time — `#expect(throws: Never.self) { … }` if it
  compiles warning-free under Xcode 27's Testing, which declares no dedicated `expect(throws:
  Never.Type)` overload); pinned by an in-place throwing mutant (the OLD words' key at the line) —
  RED at its own line on BOTH spellings (the old line was never silent on a throw — only its
  comparison was dead). **[CORRECTED IN PLACE at piece 4 — kept beside its correction, the 19a
  custom: the old line does NOT record at its own line on a throw; the error escapes the `#expect`
  and aborts the test, recorded at the `@Test` declaration (248). So "record-and-continue kept" was
  a false premise; the re-spell keeps the ACTUAL behaviour (`_ = try …`, abort-on-throw), and the
  pin shows the identical issue on both spellings.]**

**Pieces:**
1. Fresh builds + the census — DONE (`4fe9a227`). `core-bt-0.log` (`Build complete!`, a fresh
   scratch path), `mac-bft-0.log` and `mobile-bft-0.log` (`** TEST BUILD SUCCEEDED **`, fresh
   derived data); the census script `19d/census.sh` (ANSI stripped; a warning whose expression
   spans lines is matched on "is redundant because", not on "never equals 'nil'" — a first pass
   matched the latter and MISSED the three multi-line sites, caught by reconciling against the
   reviewer's list); outputs `19d/{core,mac,mobile}-census-0.txt`. **THE CENSUS IS EXACTLY THE
   FLOOR: 38 `#require` sites — core 8 · Mac 26 · mobile 4 — no more, no fewer** (the reviewer's
   list, site for site). **[CORRECTED AT ROUND 1 (F1) — kept beside its correction: this was the
   WARNING census, and the warning is not a complete tell — `NonOptionalRequireMacro` suppresses it
   when an argument token is `?`, `nil` or `Optional`. Two more `try? #require` sites existed
   (`BookAscentTests:803`, `MarkdownFaceTests:187`); round 1's runs A/B settle them (803 silent,
   187 hollow). The complete method is the warning lines + a position sweep (`19d/reqpos.py`) + the
   `try? #require` grep tripwire — the ROUND 1 FIXES record.]** **Always-true: the 2 named test sites** (`PostureSwitchDrillTests:621`;
   `SyncEnrollmentTests:262`, printed twice — at its path and at `macro expansion #expect:1:112` —
   ONE site) **+ 1 NOT OWNED: `App/Variorum/VariorumMobile/Spike/SpikeScenarios.swift:240`**
   ("comparing non-optional value of type 'NSLayoutManager' to 'nil'") — mobile APP source in the
   Spike folder, compiled into the mobile test build but outside this test-files-only entry;
   RECORDED, not touched. No "always returns false" twin anywhere (that class fails loudly anyway).
   **The per-site classification (the rule above, read off each site's own spelling):**
   - (A) HOIST, `try #require(X)` in an Optional position — core: `BookArchiveFacesCoreTests:24`,
     `BookWingMoveTests:159/216`, `DailyJournalRulingsTests:504`, `PendingArrivalDismissalTests:26`,
     `WingContentsMoveTests:64/68` (all `querySpec: String?`), `TrashAndArchiveTests:253` (the
     INNER `#require(stamp)` nested in an outer `#require`, `fromStamp: String?`); Mac:
     `BookArchivedLineTests:471`, `WingBookMoveDoorTests:149/250` (`querySpec:`),
     `LibraryDayFilterTests:114/124` (`setEditedOn(_: String?)`), `ReadRenderingTests:210/237/349`
     (`ctFrame: CTFrame?`), `TutorialWalkTests:563` (`createTag(parent: String?)`),
     `TypingErgonomicsTests:368` (`contentView: NSView?`) — **18 sites**.
   - (R) RECORD-AND-CONTINUE, `try? #require(X)` — Mac: `EditorSeamCostTests:81`,
     `FannedDefaultsTests:221`, `MarkdownFaceTests:284`, `NoteBoxTests:221`,
     `NoteVersionsPaneTests:332/336`, `OriginBlockDoorTests:87/90`, `QuickNoteTests:358`,
     `SurfaceSizeMemoryTests:687`, `SystemHotKeyTests:200`, `TakeStructureDoorTests:343`,
     `TrayPanelMoveTests:74`, `TutorialWalkTests:3502/3504`; mobile:
     `MobileCrossBlockEditTests:144/163/210/310` — **19 sites**. Every one sits in a NON-throwing
     test function (the `try?` is the only spelling that compiles there) and every downstream use
     is optional-chained or `??`-defaulted — no contrary signal; **zero stop-and-report sites.**
   - (C) CLEANUP — `FannedDefaultsTests:355` (`EditorViewModel.postID` is `let postID: String`) —
     **1 site**, no pin possible.
   - No touched suite is env-gated except `PostureSwitchDrillTests` (grep of every touched file).
2. Re-spells, committed per target — Mac DONE (`36954f75`); mobile DONE (`6bb4eae4`); family 2 DONE (`97b3eb0c`, piece 4). **Mac (12
   files, the 15 SILENT sites + the 355 cleanup):** (R) `let x = X` + `#expect(x != nil)` at
   `EditorSeamCostTests:81`, `MarkdownFaceTests:284`, `NoteBoxTests:221`,
   `NoteVersionsPaneTests:332`/`:336`, `OriginBlockDoorTests:87`/`:90`, `QuickNoteTests:358`,
   `SystemHotKeyTests:200`, `TakeStructureDoorTests:343`, `TrayPanelMoveTests:74`; (A) the hoist
   `let ctFrame = try #require(paginator.frame(forPage: 0))` + `view.ctFrame = ctFrame` at
   `ReadRenderingTests:210`/`:237`/`:349`, `let scrollView = try
   #require(h.textView.enclosingScrollView)` + `window.contentView = scrollView` at
   `TypingErgonomicsTests:368`; (C) `let post = h.model.postID` at `FannedDefaultsTests:355`. Every
   downstream line byte-identical. `mac-bft-new.log` → `** TEST BUILD SUCCEEDED **`; the touched
   files' warnings before → after: EXACTLY the 16 redundancy lines removed, the hollow
   `FannedDefaultsTests:221` stays (recorded), nothing added (the only other lines are
   `QuickNoteTests`' three pre-existing effect-marker warnings, shifted down one line).
   **Mobile (1 file, the 4 SILENT sites):** (R) at `MobileCrossBlockEditTests:144`/`:163`/`:210`/`:310`
   (`let edit = Self.plan(…)` / `CrossBlockCompound.plan(…)` + `#expect(edit != nil)`).
   `mobile-bft-new.log` → `** TEST BUILD SUCCEEDED **`; the file's warnings 4 → 0, nothing added.
3. Mutant pins (old silent once per shape; new red at its line per site) — DONE (`c93be1ef`).
   **THE MUTANTS (the script `19d/mutate.py`, string-anchored so one patch applies to the old AND
   the re-spelled tree; each edit asserted to match exactly once; marker `MUT19D`):** set **M1** —
   every site's first-run mutant: CALLEE (source, announced): `RuleGrammar.encode` answers nil
   (core) · `DivideWCeremony.releasedOriginalNote` answers nil · `EditorCommands.keyEquivalent`
   answers nil for `.quickNote`/`.takeToBlockBelow`/`.takesToBlocks` · `PagePaginator.frame(forPage:)`
   answers nil (Mac); UPSTREAM VALUE (test code, the site line untouched): TrashAndArchive's stamp
   read keyed to a missing id · EditorSeamCost `Self.index([])` · FannedDefaults' help table without
   `.divide` · LibraryDayFilter's FIRST field's pick never lands · MarkdownFace's text layout manager
   removed from its content manager (so `textStorage` reads nil) · NoteBox `edited`/`saved` nil ·
   NoteVersions' local `cost` helper zeroed (the "nothing to say" cost) · SurfaceSizeMemory
   `herStamp` nil · SystemHotKey's fake never records its id · TrayPanelMove `doors` emptied ·
   TutorialWalk's parent-tag predicate and both chapter names unmatched · TypingErgonomics' text
   view detached from its scroll view · mobile: the REAL `CrossBlockCompound.plan` handed surface
   text of the wrong length (its own desync guard answers nil — `CrossBlockCompound.swift`'s
   `guard text.length == ranges[i].length else { return nil }`). Set **M2c** (core,
   `WingContentsMove:68` — same test as 64, whose hoisted `try` aborts first): `encode` answers nil
   on its SECOND call (the filtered run holds that one test; `createReading` never encodes a valid
   v2 spec, so call 1 is line 64's). Set **M2m** (Mac, `LibraryDayFilter:124`): only the ARMED
   field's pick never lands. Set **SE** (`SyncEnrollmentTests:262`): the OLD words' key AT the line
   (`words: fresh` → `words: old`, one same-typed identifier — the only value edit on a site line).
   Callee sources' base sha256 in `19d/callee-sha-base.txt` (RuleGrammar `f2d83651…`,
   DivideWCeremony `baa303ec…`, EditorCommands `66264f65…`, PagePaginator `401fb7f0…`).
   **OLD-TREE M1 — ANNOUNCED, STARTING after this commit** (on the committed base, so `git checkout
   --` restores): `python3 App/Variorum/DerivedData/19d/mutate.py M1`, then the core build + the six
   core suites, the Mac bft + the 19 Mac suites, the mobile bft + `MobileCrossBlockEditBrainTests`;
   then `git checkout --` of every M1 file, `git status` clean, `grep -r MUT19D` empty, the four
   sha256s re-read. **If this record still says STARTING, a death came mid-mutant: run `git
   checkout -- Sources App Tests` and re-read the shas FIRST.**
   **OLD-TREE M1 — DONE, REVERTED** (`19d/old-M1.diff`; logs `core-old-M1.log` — 40 tests / 6
   suites, `mac-old-M1.log` — 202 tests / 18 suites at a zero-instance window
   (`mac-old-M1.window`: `pgrep` empty before 16:37:37Z and after 16:38:53Z), `mobile-old-M1.log`
   — 12 tests / 1 suite, iPhone 17 Pro / iOS 26.2; issue locations by `19d/issues.py`; restored
   with `git checkout --` of the 17 files, `git status` clean, zero `MUT19D` in the tree, all four
   callee sha256s OK). **THE FINDING — the class is NOT uniformly silent; the redundancy warning is
   a STATIC diagnostic and does not by itself mean a runtime silence.** Under the in-place nil
   mutant, the OLD spelling:
   - **RECORDS AT ITS OWN LINE (the site's own expression as the message — e.g. "Expectation
     failed: try RuleGrammar.encode(.tag(inbox.id))", "…: picked", "…: herStamp", "…: stamp")** at
     core `BookArchiveFacesCoreTests:24`, `BookWingMoveTests:159`, `DailyJournalRulingsTests:504`,
     `PendingArrivalDismissalTests:26` (×3 callers), `TrashAndArchiveTests:253` (the INNER
     `#require(stamp)` — message "stamp"), `WingContentsMoveTests:64`; Mac `BookArchivedLineTests:471`,
     `FannedDefaultsTests:221`, `LibraryDayFilterTests:114`, `SurfaceSizeMemoryTests:687`,
     `TutorialWalkTests:563`, `:3501`/`:3503` (the macro's first line; the warning cites 3502/3504),
     `WingBookMoveDoorTests:149`/`:250`. **These are HOLLOW for the silent-nil class** (the pin
     would be green on both sides) — every one's `X` is a plain variable, a subscript, a
     `try`-prefixed call or a trailing-closure call.
   - **SILENT AT ITS OWN LINE (only later lines record, or nothing at all)** at Mac
     `EditorSeamCostTests:81` (82 records), `MarkdownFaceTests:284` (286/289/291),
     `NoteBoxTests:221` (223–230), `NoteVersionsPaneTests:332`/`:336` (334/338),
     `OriginBlockDoorTests:87`/`:90` (88–93), `QuickNoteTests:358` (359/360),
     `ReadRenderingTests:210`/`:237`/`:349` (217/241/357), `SystemHotKeyTests:200` (202/203),
     `TakeStructureDoorTests:343` (344 ×2), `TrayPanelMoveTests:74` (75/76),
     `TypingErgonomicsTests:368` (NOTHING records anywhere in the test — the mutant's effect is
     proven on the new spelling, below); mobile `MobileCrossBlockEditTests:144`/`:163`/`:210`/`:310`
     (only the downstream `edit?.…` lines). **These are the genuine never-failing checks** — every
     one's `X` is an UN-prefixed function call or member access.
   - NOT REACHED under M1 (an earlier abort in the same test): core `BookWingMoveTests:216`,
     `WingContentsMoveTests:68`; Mac `LibraryDayFilterTests:124` — OLD-M2 below.
   **OLD-TREE M2 — ANNOUNCED, STARTING after this commit:** `mutate.py M2c` (REVISED from the
   counter to a PER-CALL callee mutant: `encode` answers nil only when the calling thread carries
   the `MUT19D` flag, set on the line just before the site's statement — synchronous, so the same
   thread, and immune to parallel tests; sites 68 and 216) + `mutate.py M2m`; core build + the two
   core suites, Mac bft + `LibraryDayFilterTests`; then `git checkout --`, status clean, zero
   markers, RuleGrammar's sha256 re-read. Same death rule as above.
   **OLD-TREE M2 — DONE, REVERTED** (`19d/old-M2.diff`; `core-old-M2.log` 11 tests / 2 suites, EXACTLY
   2 issues: `BookWingMoveTests:217` and `WingContentsMoveTests:69` — the original 216/68, shifted one
   line by the inserted flag — each "Expectation failed: try RuleGrammar.encode(.tag(classics.id))";
   `mac-old-M2.log` 19 tests / 1 suite at a zero-instance window, EXACTLY 1 issue:
   `LibraryDayFilterTests:124` "Expectation failed: picked"). All three RECORD AT THEIR OWN LINE —
   hollow. Restored: status clean, zero markers, the four sha256s OK.
   **THE MECHANISM — THE ROUTE THE COMPILER CHOSE; THE BINDINGS INFERRED, AND SETTLED AT RUNTIME BY
   THE MUTANTS** *(reworded at round 1, F3: `routes.py` reads the generic `__check*` symbol each
   expansion calls, never the type binding inside it; the binding story below is INFERENCE)* (19c's `routes.py`, copied to
   `19d/routes.py`, over the BASE build's objects — `{mac,core,mobile}-routes-base.tsv`): every one
   of the 38 sites binds the `NonOptionalRequireMacro` (hence the identical warning), but the
   macro delegates to the ordinary `#require` expansion, which then type-checks ON ITS OWN:
   **(i) at all 18 HOLLOW sites the expansion calls `__checkValue`** (`__checkValue<T>(_
   optionalValue: T?, …) -> Result<T, Error>` takes the value DIRECTLY and binds `T := X` — a nil
   records); **(ii) at all 19 SILENT sites it calls `__checkFunctionCall` or `__checkPropertyAccess`**
   (the decomposed forms take the value as a CLOSURE'S result typed `R?`; with the macro's result
   type `X?` as the context, `R` binds to `X?` and the closure's `X?` promotes to `X??`, so a nil
   arrives as `.some(nil)` and passes — INFERRED). 38 of 38 sites: route ⇔ runtime behaviour, no exception
   **[CORRECTED AT ROUND 1: 40 of 41 — `MarkdownFaceTests:187` routes `__checkPropertyAccess` yet
   RECORDS under a real nil (runs A/B). The route RANKS; only the runtime settles.]**
   (`TrashAndArchive:253` carries both — its flagged INNER `#require(stamp)` is `__checkValue`, its
   unflagged outer `#require` the function-call form). The class's real tell is therefore the
   warning **on a decomposed expression** (an un-prefixed call or member access), not the warning
   alone. **[CORRECTED AT ROUND 1 (F1/F3): the warning is NOT a reliable tell at all (token
   suppression hides it) and the route does not decide the behaviour (187); the standing method is
   the grep tripwire at zero + the position sweep, with a real-nil mutant as the only settlement.]** **This NARROWS 19c round 1 F1's census sentence** ("a nil X records NOTHING at that
   line" — true of 19 of its 38; the four sites its probes touched were all decomposed forms).
   **DISPOSITIONS DECIDED (the contract's hollow rule — a pin green on both sides is a hollow row:
   record it, do not fix it):** the 18 HOLLOW sites are **DISMISSED AS HOLLOW**, NOT re-spelled —
   their warnings stay, each RECORDED with its reason (the acceptance's "except sites recorded
   with a reason"); the 19 SILENT sites are re-spelled with pins; `FannedDefaultsTests:355` is the
   brief's ruled cleanup. FLAGGED for the orchestrator: re-spelling the 18 hollow sites as a
   warning-only cleanup would make the redundancy warning a clean tell again (no behaviour
   change); that is a scope call, not this implementer's.
   **NEW-TREE M1 + SE — ANNOUNCED, STARTING after this commit** (the re-spelled tree, committed at
   `97b3eb0c`): `mutate.py M1` + `mutate.py SE`; Mac bft + the 18 site suites + `SyncEnrollmentTests`;
   mobile bft + `MobileCrossBlockEditBrainTests` (no core site was re-spelled — no core NEW run is
   owed). **The score sheet (the line each NEW spelling must record at, in the MUTATED file):**
   EditorSeamCost 82 · MarkdownFace 286 (285 + the mutant's inserted line) · NoteBox 223 ·
   NoteVersions 334, 339 · OriginBlockDoor 88, 92 · QuickNote 359 · ReadRendering 210, 238, 351 ·
   SystemHotKey 201 · TakeStructureDoor 344 (×2, the loop) · TrayPanelMove 75 · TypingErgonomics 369
   (368 + 1) · mobile 145, 165, 213, 316 · SyncEnrollment: "Caught error" at 248 (the old line's own
   behaviour, unchanged). Revert as before; same death rule.
   **NEW-TREE M1 + SE — DONE, REVERTED** (`19d/new-M1-SE.diff`; `mac-new-M1.log` 207 tests / 19
   suites at a zero-instance window — `mac-new-M1.window`: `pgrep` empty before 17:01:15Z and after
   17:02:33Z; `mobile-new-M1.log` 12 tests / 1 suite; restored with `git checkout --` of the 18
   files, status clean, zero markers, the four sha256s OK). **EVERY re-spelled site RED AT ITS OWN
   NEW LINE, with its own expression as the message — the score sheet met 20 of 20:** EditorSeamCost
   82 "last != nil" · MarkdownFace 286 "storage != nil" · NoteBox 223 "both != nil" · NoteVersions
   334 "three != nil", 339 "stranded != nil" · OriginBlockDoor 88 "one != nil", 92 "three != nil" ·
   QuickNote 359 "chord != nil" · ReadRendering 210/238/351 "paginator.frame(forPage: 0)" (and each
   test now ABORTS there — the old run's later 217/241/357 lines are gone: the hoist's `try` intent)
   · SystemHotKey 201 "pressed != nil" · TakeStructureDoor 344 ×2 "key != nil" · TrayPanelMove 75
   "tray != nil" · TypingErgonomics 369 "h.textView.enclosingScrollView" (**this proves the mutant
   real, so the OLD site was silent with NOTHING downstream to catch it — the purest instance of the
   class**) · mobile 145/165/213/316 "edit != nil" (32 issues = the old run's 28 + exactly these 4)
   · SyncEnrollment "Caught error: .unwrapFailed" at 248 — IDENTICAL to the old line's (behaviour
   kept). Every downstream `x?.…` line fails as before (record-and-continue intact). The hollow
   sites re-recorded at their own lines, unchanged.
4. Family 2 — DONE (`97b3eb0c`; the NEW-spelling SE pin rides piece 3). **OLD-SPELLING EVIDENCE — ANNOUNCED** (both
   files committed at base; `SyncEnrollmentTests` is an ordinary suite over in-memory custody and
   a scripted vault — no real Keychain item): (a) `mutate.py SE` on the OLD line 262 (`words:
   fresh` → `words: old` — the unwrap must THROW); (b) a THROWAWAY probe suite appended to
   `PostureSwitchDrillTests.swift` (un-gated, marker `Mut19dDeviceIDProbe`/`MUT19D`): `let
   joinerRecord = try #require(Optional(SyncCustodyRecord(deviceID: "", material: nil)), …)` then
   line 621's OLD spelling and its NEW spelling, verbatim with the same comment, one after the
   other — the old must stay GREEN (the silence), the new go RED at its line. Mac bft, then
   `SyncEnrollmentTests` + `Mut19dDeviceIDProbe` only (the gated drill stays OFF — not in the run).
   Revert: `git checkout -- App/Variorum/VariorumTests/{SyncEnrollmentTests,PostureSwitchDrillTests}.swift`,
   status clean, zero markers.
   **OLD-SPELLING EVIDENCE — DONE, REVERTED** (`19d/old-SE-probe.diff`; `mac-old-SE.log`, 6 tests / 2
   suites — `SyncEnrollmentTests` + the probe ONLY, the drill not run — at a zero-instance window,
   `mac-old-SE.window`: `pgrep` empty before 16:55:24Z and after 16:56:21Z; restored, status clean,
   zero markers): **(b) the probe** — the OLD spelling (`#expect(joinerRecord.deviceID != nil, …)`)
   stayed GREEN over `deviceID: ""` (the silence), the NEW spelling (`#expect(!joinerRecord.deviceID
   .isEmpty, …)`) went RED at its own line ("Expectation failed: !joinerRecord.deviceID.isEmpty") —
   exactly 1 issue. **(a) `SyncEnrollmentTests:262` — THE METHOD'S PRESUMPTION WAS WRONG, corrected
   here:** the OLD line does NOT record at its own line on a throw. The `try` operand is evaluated
   before the check, the error ESCAPES the `#expect` and aborts the test, recorded as "Caught error:
   .unwrapFailed" at the `@Test` DECLARATION (line 248), exactly 1 issue. So the old line's effective
   check was "the unwrap does not throw", ABORT-on-throw; its `!= nil` was a dead conjunct. **The
   re-spell therefore keeps that behaviour byte-for-byte: `_ = try vault.unwrapMaster(…)`** (the
   brief's "removed — the `try` carries the real check", read literally), under a one-line comment.
   NOT taken: `#expect(throws: Never.self) { … }` — it would record at its own line but CONTINUE
   after a throw, changing abort into continue in a custody-drill file (test intent, not
   mechanics; the orchestrator's call if it wants that locality).
   **The re-spells — DONE (`97b3eb0c`):** `PostureSwitchDrillTests:621` → `#expect(!joinerRecord
   .deviceID.isEmpty, "the device identity minted beside them")` (strictly stronger than the
   always-true line: `SyncCustodyRecord.fresh` mints a lowercased UUID string, so a real enrol
   passes; an empty identity now fails); `SyncEnrollmentTests:262` → the comment + `_ = try …`.
   `mac-bft-new2.log` → `** TEST BUILD SUCCEEDED **`; the two files' warnings before → after: the
   two always-true lines removed, nothing added (`PostureSwitchDrillTests:697`'s effect-marker
   warning predates this entry). This build also re-emitted the other changed files: **the Mac
   redundancy census now reads EXACTLY the 10 hollow sites**, recorded.
5. Rebuilds + the touched suites green — DONE (this commit). **FULLY FRESH final builds** (new
   derived-data / scratch paths, so every file re-emits): `core-bt-final.log` (`Build complete!`),
   `mac-bft-final.log` / `mobile-bft-final.log` (`** TEST BUILD SUCCEEDED **`). **The closing census
   (`{core,mac,mobile}-census-final.txt`): core 8 + Mac 10 redundancy lines = EXACTLY the 18 HOLLOW
   sites (recorded); mobile 0; always-true in test files 0 (the one left is the not-owned mobile APP
   line `SpikeScenarios.swift:240`).** Whole-target "nothing added" (`19d/warnsets.py`, base `*-0`
   vs `*-final`, by file and by (file, message) ignoring line shifts): Mac 102 → 83 unique warnings
   (−19 = the 16 redundancy lines + 621 + 262's path and in-expansion lines), mobile 47 → 43 (−4),
   core 30 → 30; **added: NONE in all three.** The route census over the FINAL objects
   (`mac-routes-final-custody.tsv`): `PostureSwitchDrillTests:621` now compiles to
   `__checkPropertyAccess` on the Bool (VOID) route — the real one (base: `__checkBinaryOperation`
   folded to always-true); `SyncEnrollmentTests` 262 carries no expectation now (its old 263 moved to
   264). **Suites (the final build products, `test-without-building`, suite-level
   `-only-testing`):** **Mac `✔ Test run with 197 tests in 27 suites passed`** — every suite type
   in the 13 touched Mac files other than the gated drill (`mac-touched.args`; 197 = those files'
   `@Test` count exactly; ZERO `skipped:` lines; a ZERO-INSTANCE window — `pgrep` empty before
   17:11:31Z and after 17:12:20Z, `mac-final-suites.window`; `PostureSwitchDrillTests` deliberately
   NOT in the run — its suite is the env-gated drill, left off) · **mobile `✔ Test run with 24
   tests in 2 suites passed`** (`MobileCrossBlockEditBrainTests` + `MobileCrossBlockEditTests`, the
   file's 24 `@Test`s; zero `skipped:`; iPhone 17 Pro / iOS 26.2) · core (NOT owed — no core file
   changed; a sanity run of the hollow sites' six suites) `✔ Test run with 40 tests in 6 suites
   passed`, zero `skipped:`. Evidence folder 5.2 GB (the superseded build products deleted, every
   log kept; the final build products kept so the reviewer can re-read routes).
6. The census table, dispositions, acceptance lines, State → REVIEW-PENDING — DONE (this commit).

**THE CENSUS TABLE (40 sites + 1 not owned).** Class: A = `try #require` in an Optional position
(abort) · R = `try? #require` (record-and-continue) · C = cleanup. Route = the `__check*` the
expansion calls at the site in the real target (`*-routes-base.tsv`). OLD = the old spelling under
the in-place nil mutant (logs `{core,mac,mobile}-old-M1.log`, `core-old-M2.log`, `mac-old-M2.log`);
NEW = the re-spelled line (line numbers in the COMMITTED file) under the same mutant
(`mac-new-M1.log`, `mobile-new-M1.log`).

| Site (base line) | Class | Route | OLD under the mutant | NEW under the mutant | Disposition |
|---|---|---|---|---|---|
| core `BookArchiveFacesCoreTests:24` | A | `__checkValue` | RED at 24 | — | HOLLOW → CLEANUP (round 1 F2) |
| core `BookWingMoveTests:159` | A | `__checkValue` | RED at 159 | — | HOLLOW → CLEANUP (round 1 F2) |
| core `BookWingMoveTests:216` | A | `__checkValue` | RED at 216 (M2c; logged 217, +1 shift) | — | HOLLOW → CLEANUP (round 1 F2) |
| core `DailyJournalRulingsTests:504` | A | `__checkValue` | RED at 504 | — | HOLLOW → CLEANUP (round 1 F2) |
| core `PendingArrivalDismissalTests:26` | A | `__checkValue` | RED at 26 (×3 callers) | — | HOLLOW → CLEANUP (round 1 F2) |
| core `TrashAndArchiveTests:253` (inner) | A | `__checkValue` | RED at 253 "stamp" | — | HOLLOW → CLEANUP (round 1 F2) |
| core `WingContentsMoveTests:64` | A | `__checkValue` | RED at 64 | — | HOLLOW → CLEANUP (round 1 F2) |
| core `WingContentsMoveTests:68` | A | `__checkValue` | RED at 68 (M2c; logged 69) | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `BookArchivedLineTests:471` | A | `__checkValue` | RED at 471 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `FannedDefaultsTests:221` | R | `__checkValue` | RED at 221 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `LibraryDayFilterTests:114` | A | `__checkValue` | RED at 114 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `LibraryDayFilterTests:124` | A | `__checkValue` | RED at 124 (M2m) | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `SurfaceSizeMemoryTests:687` | R | `__checkValue` | RED at 687 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `TutorialWalkTests:563` | A | `__checkValue` | RED at 563 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `TutorialWalkTests:3502` (macro at 3501) | R | `__checkValue` | RED at 3501 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `TutorialWalkTests:3504` (macro at 3503) | R | `__checkValue` | RED at 3503 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `WingBookMoveDoorTests:149` | A | `__checkValue` | RED at 149 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `WingBookMoveDoorTests:250` | A | `__checkValue` | RED at 250 | — | HOLLOW → CLEANUP (round 1 F2) |
| Mac `EditorSeamCostTests:81` | R | `__checkPropertyAccess` | SILENT (82 only) | RED at 82 | FIXED |
| Mac `MarkdownFaceTests:284` | R | `__checkPropertyAccess` | SILENT (286/289/291) | RED at 285 (logged 286) | FIXED |
| Mac `NoteBoxTests:221` | R | `__checkFunctionCall` | SILENT (223–230) | RED at 223 | FIXED |
| Mac `NoteVersionsPaneTests:332` | R | `__checkFunctionCall` | SILENT (334) | RED at 334 | FIXED |
| Mac `NoteVersionsPaneTests:336` | R | `__checkFunctionCall` | SILENT (338) | RED at 339 | FIXED |
| Mac `OriginBlockDoorTests:87` | R | `__checkFunctionCall` | SILENT (88/89) | RED at 88 | FIXED |
| Mac `OriginBlockDoorTests:90` | R | `__checkFunctionCall` | SILENT (91–93) | RED at 92 | FIXED |
| Mac `QuickNoteTests:358` | R | `__checkFunctionCall` | SILENT (359/360) | RED at 359 | FIXED |
| Mac `ReadRenderingTests:210` | A | `__checkFunctionCall` | SILENT (217) | RED at 210, aborts | FIXED |
| Mac `ReadRenderingTests:237` | A | `__checkFunctionCall` | SILENT (241) | RED at 238, aborts | FIXED |
| Mac `ReadRenderingTests:349` | A | `__checkFunctionCall` | SILENT (357) | RED at 351, aborts | FIXED |
| Mac `SystemHotKeyTests:200` | R | `__checkPropertyAccess` | SILENT (202/203) | RED at 201 | FIXED |
| Mac `TakeStructureDoorTests:343` | R | `__checkFunctionCall` | SILENT (344 ×2) | RED at 344 ×2 | FIXED |
| Mac `TrayPanelMoveTests:74` | R | `__checkPropertyAccess` | SILENT (75/76) | RED at 75 | FIXED |
| Mac `TypingErgonomicsTests:368` | A | `__checkPropertyAccess` | SILENT — NOTHING records in the test | RED at 368 (logged 369), aborts | FIXED |
| Mac `FannedDefaultsTests:355` | C | `__checkPropertyAccess` (`postID: String`) | — (cannot be nil) | — | CLEANUP (macro dropped) |
| mobile `MobileCrossBlockEditTests:144` | R | `__checkFunctionCall` | SILENT (145–156) | RED at 145 | FIXED |
| mobile `MobileCrossBlockEditTests:163` | R | `__checkFunctionCall` | SILENT (164–169) | RED at 165 | FIXED |
| mobile `MobileCrossBlockEditTests:210` | R | `__checkFunctionCall` | SILENT (211/212) | RED at 213 | FIXED |
| mobile `MobileCrossBlockEditTests:310` | R | `__checkFunctionCall` | SILENT (313–318) | RED at 316 | FIXED |
| Mac `BookAscentTests:803` (round 1 F1 — warning SUPPRESSED by its `?` token) | R | `__checkPropertyAccess` | SILENT under P1 (run A: nothing at the site; 805/807 only) | RED at 804 (logged 805, run B) | FIXED (round 1) |
| Mac `MarkdownFaceTests:187` (round 1 F1 — warning SUPPRESSED) | R | `__checkPropertyAccess` | RED AT 187 under a REAL nil (run A; P2 never made it nil) | RED at 188 (run B) | HOLLOW → CLEANUP (round 1 F2) |
| Mac `PostureSwitchDrillTests:621` (always-true) | — | `__checkBinaryOperation` → `__checkPropertyAccess` (VOID) | probe over `deviceID: ""`: GREEN (the silence) | probe: RED at its line | FIXED (`!…isEmpty`; drill gated off) |
| Mac `SyncEnrollmentTests:262` (always-true) | — | `__checkValue` → none (`_ = try`) | throw: "Caught error" at 248 (the `@Test` line) | identical, at 248 | CLEANUP (dead conjunct removed; behaviour identical) |
| mobile APP `Spike/SpikeScenarios.swift:240` (always-true) | — | — | — | — | RECORDED, NOT OWNED (app source) |

**Totals: the 38 `#require` sites — 19 FIXED with pins (Mac 15 · mobile 4; old SILENT at its line,
new RED at its own line, 19/19), 18 DISMISSED AS HOLLOW (core 8 · Mac 10; old already RED at its
own line, so no pin can be red-on-old), 1 CLEANUP. The 2 always-true test sites: 621 FIXED (probe
pin), 262 CLEANUP (behaviour-identical). Zero stop-and-report sites; zero DEFERRED.**
**[TOTALS AT ROUND 1 — the class is 40 `#require` sites, not 38 (the two token-suppressed `try?`
sites): 20 FIXED with pins (Mac 16 incl. `BookAscentTests:803` · mobile 4); 19 HOLLOW, every one
re-spelled as a behaviour-identical CLEANUP at round 1 (core 8 · Mac 11 incl.
`MarkdownFaceTests:187`; the orchestrator's F2 ruling); 1 CLEANUP (`FannedDefaultsTests:355`). The
`try? #require` grep reads ZERO across all five test roots; the redundancy warning reads ZERO in all
three test builds. The 2 always-true sites unchanged from round 0 (621 FIXED, 262 CLEANUP).]**

**DISPOSITIONS (by the contract's three):** FIXED with its pin — the 19 silent sites + 621 (each pin
in the table, logs named above) · DISMISSED AS HOLLOW — the 18 sites, each with the mutant log
showing its old spelling RED at its own line with its own expression as the message (the reason
their warnings stay) · DEFERRED — none. Cleanups (ruled by the brief, no behaviour change): 355,
262. Not owned: `SpikeScenarios.swift:240` (app source; no row opened — warning-grade, next
legitimate touch of that Spike file).

**ACCEPTANCE LINES:** zero "'#require(_:_:)' is redundant" warnings in all three test builds except
sites recorded with a reason — ✔ (the final fresh builds carry exactly the 18 hollow sites, each
recorded above with its mutant evidence) **[AT ROUND 1: met LITERALLY — the fresh round-1 builds
carry ZERO, no recorded exceptions; see the ROUND 1 FIXES record]** · zero "always returns true" warnings in the test files —
✔ (the one left is mobile APP source, recorded not owned) · the census table — ✔ (above) · the
touched suites green at a quiet window — ✔ (Mac 197/27 at a zero-instance window, mobile 24/2 on
iPhone 17 Pro / iOS 26.2, `skipped:` read: none) · custody-drill lines not weakened — ✔ (621 is
strictly stronger than an always-true line; 262's check and its abort are unchanged) — **the
orchestrator's own-hands verification of these two is the entry's remaining owed step.**
**[DONE — PASSED at the round-1 arbitration; confirmed independently by the round-1 reviewer's
custody read. R2-3's bracket.]**

**FOR THE COLD REVIEW — the landed diff (`git diff 5790a095..HEAD -- App Tests Sources`):** 15
test files, 46+/26−, no other path (`Sources` and every app target untouched). 22 macro lines
removed (the 19 silent sites + 355 + 621 + 262), 20 added (11 Mac + 4 mobile `#expect(x != nil)`,
4 hoisted `try #require`, 621's `!…isEmpty`). Check: every downstream line byte-identical; the
record-and-continue sites keep continuing (their downstream `x?.…` lines still record under the
mutant — `mac-new-M1.log`); the hoisted sites abort where the old `try` meant to. **The
custody-drill charge:** `PostureSwitchDrillTests.swift:621` (one line; the drill itself is
env-gated off and was never run — its evidence is the probe's two lines in `old-SE-probe.diff` +
`mac-old-SE.log`, and the final route) and `SyncEnrollmentTests.swift:262–263` (a comment + `_ =
try vault.unwrapMaster(…)`; the `SE` mutant's issue is the same "Caught error: .unwrapFailed" at
248 on both spellings — `mac-old-SE.log` vs `mac-new-M1.log`). **Reproducible from the folder:**
`mutate.py {M1,M2c,M2m,SE}` re-creates every mutant (`old-M1.diff`, `old-M2.diff`,
`old-SE-probe.diff`, `new-M1-SE.diff` are the applied diffs); `issues.py <log>` re-scores issue
locations; `routes.py` re-reads routes from any build's objects; `census.sh` / `warnsets.py`
re-count warnings.

**NOTICED (routed to the orchestrator; none acted on):**
1. **19c round 1 F1's census sentence is NARROWED by this entry's evidence:** the redundancy warning
   is the `NonOptionalRequireMacro`'s STATIC diagnostic and fires at all 38 sites, but only the 19
   whose expression the macro DECOMPOSES (an un-prefixed function call → `__checkFunctionCall`, a
   member access → `__checkPropertyAccess`) are silent at runtime; a plain variable, a subscript, a
   `try`-prefixed call or a trailing-closure call goes through `__checkValue` and records. The
   cheap exact ranking for a future census: a flagged `#require` line whose route is
   `__checkFunctionCall`/`__checkPropertyAccess` = silent; `__checkValue` = hollow (38/38 here;
   the runtime mutant stays the settlement — R2-1). **[CORRECTED AT ROUND 1 (F1/F3): NOT exact —
   the warning is suppressed on `?`/`nil`/`Optional` argument tokens (two unflagged `try?` sites
   existed), and the route is not the binding (`MarkdownFace:187`: `__checkPropertyAccess`, yet it
   records). The method from here: the `try? #require` grep at ZERO (a standing tripwire), the
   position sweep `19d/reqpos.py` for the Optional-slot half (token-independent: every OTHER-position
   site carrying any `?`/`nil`/`Optional` is settled by the receiving slot's TYPE), and a real-nil
   mutant to settle any candidate.]**
2. **The 18 hollow sites' warnings now carry NO signal** — every future build re-prints them. A
   warning-only re-spell (the hoist / `#expect(x != nil)`, zero behaviour change; each's mutant
   evidence already logged) would leave the redundancy warning meaning "silent" again. A scope
   call for the orchestrator; not taken here (the contract's hollow rule). **[RESOLVED AT ROUND 1
   (F2, the orchestrator's call): the cleanup is TAKEN — all 18 re-spelled behaviour-identically; and
   the warning would NOT have become a clean tell (token suppression) — the grep tripwire is the
   tell.]**
3. **`#expect(try X …)` does not record at its line on a throw:** the `try` operand is evaluated
   before the check, so the error escapes the macro and ABORTS the test, recorded at the `@Test`
   declaration (observed: `SyncEnrollmentTests:262` under the SE mutant → issue at 248). Wherever
   the suites read `#expect(try …)` as "record and continue", it is "abort, recorded at the
   test". If line-local recording matters at a custody line, `#expect(throws: Never.self) { … }` is
   the spelling (continue + at its line) — test intent, so not taken here.
4. **A census method note:** a warning whose expression spans lines splits its message across
   lines, so a grep for the message's tail ("never equals 'nil'") misses it — anchor on the head
   ("is redundant because"). My first pass missed 3 of 38 until reconciled against the reviewer's
   list. **[CORRECTED AT ROUND 1 (F1): anchoring better on the warning still cannot find a site the
   macro never warns about — the warning census is a FLOOR; the grep tripwire and the position
   sweep are what close it.]**

**Commits:** `94145dbc` (record opened, method) · `4fe9a227` (census; mutants written; OLD-M1
announced) · `4585b7f9` (OLD-M1 results — the class not uniformly silent) · `096bc934` (OLD-M2;
the mechanism via the route census; dispositions decided) · `36954f75` (Mac re-spells) ·
`6bb4eae4` (mobile re-spells) · `edf25961` (family 2's old-spelling evidence announced) ·
`97b3eb0c` (family 2 re-spells + the 262 correction) · `73a263fb` (NEW-tree runs announced, score
sheet) · `c93be1ef` (NEW-tree pins) · this commit (final census, suites, table, dispositions,
State → REVIEW-PENDING).

**ROUND 1 FIXES (LIVE STATUS — the same implementer, resumed 2026-10-04 at the orchestrator's
arbitration `f3f5c3a0`; the binding record is the "19d ROUND 1" section above; fix diff range
`f3f5c3a0..` this section's last commit):**
- **The completeness sweep, re-derived by MY OWN method (token-INDEPENDENT) — DONE (this commit):**
  `19d/reqpos.py` classifies EVERY `#require(` in the five test roots (core, Mac, mobile, both
  UITests) by the SYNTACTIC POSITION its result flows into — 2803 sites: LET 2477 (unannotated
  `let/var x = try #require(…)` ending the statement or followed by `.member`/`!` — no contextual
  type, so the unwrap overload; the overload choice is type-decided, never token-decided, and no
  token-free LET site has ever warned) · STMT 96 · TRYQ 6 · OTHER 224 (`reqpos-0.tsv`). The
  silent class can only live in TRYQ (all 6 re-spelled by this round) or in an OTHER site whose
  result fills an Optional-typed slot; a TOKEN-FREE such site always warns (the suppression is the
  only silencer — the reviewer's source trace), and the final builds carry no warning beyond the 18
  sites F2 now re-spells; so the residue is the OTHER sites whose argument carries a suppressing
  token. Filtered with a deliberately BROAD superset (any `?` incl. `??`/ternary/`try?`, `nil`,
  `Optional`): **12 sites (`reqpos-0-other-tokens.txt`), each settled BY TYPE:** `NoteTrayTakesTests`
  82/84/103/126/145 + `ObservationQueryTests:44` (`branchVariant(_:from: String)`) ·
  `StructuralSplitAtNewlinesTests:392` (`outboxContains(_: String, _: String)`) ·
  `DivideArrangementTests:363` (a `for … in` — `Optional` is not a `Sequence`) ·
  `PostureSwitchTests:1116` (`>` — `Optional` is not `Comparable`) · `SampleLibraryTests:700`
  (annotated `: String`) · `SampleLibraryWelcomeTests:442` (the closure's result is `story`, passed
  to `addPostToReading(_ postID: String, …)` — a `String?` would not compile) ·
  `SurfaceSizeMemoryTests:782` (`FocusedBlock`'s memberwise `blockID: String`). **All 12 are
  unwrap-bound: NO third silent site** — the reviewer's 278-site token sweep confirmed by a method
  that does not depend on knowing the macro's exact suppression-token set. **[METHOD CORRECTED AT
  ROUND 2 (R2-2) — the CONCLUSION stands, re-confirmed by the round-2 reviewer's own 2797-site
  sweep, but three holes in `reqpos.py` are on the record: the STMT class keyed on a same-line
  regex (missing `TypewriterRoomTests:269` and `TutorialBooksChapterTests:669`), the token filter
  ran on a 100-char-truncated argument column (missing `DivideKeyMonitorTests:103`), and the LET
  `!` reasoning was backwards (a postfix `!` NEEDS an Optional — the silent binding; 0 such sites
  today). The three missed sites were settled BY TYPE at round 2, all unwrap-bound. Any standing
  reuse of the script must classify by the true statement start and filter the full argument. The
  19d ROUND 2 section carries the detail.]**
- F1 [MAJOR] re-spells — DONE (`6e0a359c`; dispositions corrected by runs A/B below — BookAscent FIXED with its pin, MarkdownFace HOLLOW, its edit standing as an F2 cleanup): `BookAscentTests:803` → `let action = center.current?.action` + `#expect(action != nil)`; `MarkdownFaceTests:187` → `let headingSize = font(storage, at: titleAt)?.pointSize` + `#expect(headingSize != nil)`; downstream lines byte-identical (build PENDING, rides F2's).
- F2 [MINOR] the 18-hollow cleanup (behaviour-identical, each site's abort-vs-continue kept) —
  core DONE (`668846bb`), Mac DONE (this commit). **Core (6 files, the 8 sites, all (A) — abort kept):** the
  hoist `let tagRule = try #require(try RuleGrammar.encode(.tag(…)))` (`classicsRule`/`writingRule`
  where a test holds two) on the line before the `createReading` that consumed it, then
  `querySpec: <rule>` — `BookArchiveFacesCoreTests:24`, `BookWingMoveTests:159/216`,
  `DailyJournalRulingsTests:504`, `PendingArrivalDismissalTests:26`, `WingContentsMoveTests:64/68`
  (evaluation order unchanged: each rule is still encoded immediately before its own
  `createReading`); `TrashAndArchiveTests:253` → `let createdStamp = try #require(stamp)` then
  `let day = try #require(DisplayTitle.day(fromStamp: createdStamp))`. `core-bt-r1.log`
  (`Build complete!`): redundancy census 0; the six files carry no warning of any kind.
  **Mac (6 files, the 10 sites):** (A, abort kept — the hoist) `BookArchivedLineTests:471`
  (`inboxRule`), `WingBookMoveDoorTests:149`/`:250` (`tagRule`/`starRule`), `LibraryDayFilterTests:114`/
  `:124` (`firstPick`/`secondPick` — each `#require(picked)` read at the same point, after its
  field's pick, exactly where the argument was evaluated), `TutorialWalkTests:563`
  (`parentTagID`); (R, continue kept — `let x = X` + `#expect(x != nil)`) `FannedDefaultsTests:221`,
  `SurfaceSizeMemoryTests:687`, `TutorialWalkTests:3501`/`:3503` (`index`/`places`; the existing
  3505 `#expect(index != nil && places != nil)` stays byte-identical). Local names checked
  collision-free per file. **THE TRIPWIRE: `grep -rnE 'try\?[[:space:]]*(await[[:space:]]+)?#require'`
  over all five test roots → 0.** `mac-bft-r1.log` (`** TEST BUILD SUCCEEDED **`, incremental over
  the final derived data): Mac redundancy census 0; the 8 Mac files touched this round carry only
  `BookAscentTests:554`'s two effect-marker warnings, present identically in the base build.
- F1 pins under the reviewer's two mutants (re-created by `19d/mutate.py F1R` — the same upstream
  edits as `19d-review/probe.py` P1/P2: `center.refuse(…)` above BookAscent's site, the heading's
  `.font` attribute removed above MarkdownFace's — anchored on the line ABOVE the site so they
  apply to the new spelling) — the red-on-old is the reviewer's LOGGED silence
  (`19d-review/mac-probe.log`: in the probe-mutated files the sites sit at 804/188 and record
  NOTHING; only 805/807 and 189/195 do). **ROUND-1 MUTANT RUN — ANNOUNCED, STARTING after this
  commit** (the committed tree `83955f96`): `mutate.py M1` + `mutate.py F1R`; the Mac bft (final
  derived data) + the 18 site suites + `SyncEnrollmentTests` + `DivergeDoorTests` (BookAscent's
  site); the core six suites. M1 rides along at no extra cost: it re-scores every round-0
  re-spell and shows the 18 cleanups behaviour-identical under their logged mutants (no pin
  OWED for those — F2's ruling). **Score sheet (MUTATED-file lines):** the owed F1 pins —
  `BookAscentTests` 805 "action != nil" (804 + F1R's line) and `MarkdownFaceTests` 189 "headingSize
  != nil" (188 + F1R's line); the cleanups' expected issue lines are each hoisted / `#expect` line
  (core 22, 157, 502, 24, 253, 62; Mac 470, 147, 249, 114, 562 — each then ABORTING its test as the
  old `try` did; 222, 688, 3503, 3505 — each CONTINUING as the old `try?` did). Revert: `git
  checkout --` of the touched files, status clean, zero markers, the four callee sha256s.
  **ROUND-1 MUTANT RUN — DONE, REVERTED** (`19d/r1-M1-F1R.diff`; `core-r1-M1.log` 40 tests / 6
  suites; `mac-r1-M1.log` 213 tests / 20 suites at a zero-instance window — `mac-r1-M1.window`:
  `pgrep` empty before 17:52:10Z and after 17:53:31Z; restored with `git checkout --` of the 18
  files, status clean, zero markers, the four sha256s OK). **(a) `BookAscentTests` — PINNED: RED at
  805 "action != nil"** (the new line, +1 for F1R's inserted line), then its downstream 806/808 as
  before. **(b) `MarkdownFaceTests:187` — NOT PINNED BY P2, AND P2 NEVER TESTED IT:** the new line
  (189 mutated) did NOT record; only 190 `(headingSize ?? 0) > base.pointSize` and 196 did, and the
  captured value reads `(headingSize ?? 0) → 12.0` — in THIS log and identically in the reviewer's
  `19d-review/mac-probe.log`. `NSTextStorage` fixes attributes when the edit is processed
  (`fixFontAttribute` reassigns a default 12-pt font to any run left without one), so removing the
  `.font` attribute never yields nil there. **The reviewer's logged "silence" at 188 is therefore
  UNINFORMATIVE for this site: X was 12.0, not nil** (BookAscent's P1 is genuine — its downstream
  `action?.label` failed on nil in both logs). Route at 187 (the reviewer's
  `mac-routes-final-all.tsv`): `__checkPropertyAccess` — the decomposed form, so silence is
  PREDICTED; only a real nil can settle it. **(c) every round-0 re-spell re-scored RED at its own
  line** (82, 223, 334, 339, 88, 92, 359, 210/238/351, 201, 344 ×2, 75, 369, and MarkdownFace's
  voice-switch site at 288 = 285 + two inserted lines). **(d) the 18 cleanups are
  behaviour-identical under their logged mutants:** core recorded EXACTLY the old run's 9 issues,
  each now at its hoisted line with the same message (22, 157, 502, 24 ×3, 253 "stamp", 62; 203 =
  the old run's 202 fallout, +1); Mac 470, 147, 249, 114 "picked", 562 "parentID" — each test then
  ABORTS as the old `try` did (nothing below it records) — and 222, 688, 3503/3505 record then
  CONTINUE (their downstream `?.` lines still record, 3506's `index != nil && places != nil` too).
  **RUNS A/B for MarkdownFace:187 — ANNOUNCED, STARTING after this commit** (set `F1M`: the site's
  own file-private callee `font(_:at:)` answers nil for exactly the site's call — the heading string
  at the title's offset — a one-line replacement, no line shift; offsets 0 and "Big" untouched). **A
  (the self-owned red-on-old, for BOTH F1 sites):** `mutate.py OLDF1` (the two OLD spellings
  restored TEMPORARILY over the committed new ones) + `F1P1` + `F1M`; Mac bft + `MarkdownFaceTests`
  + `DivergeDoorTests`; expected: NO issue at BookAscent 804 (the old site, +1) nor MarkdownFace 187,
  only their downstream lines. **B (the new spellings):** `F1P1` + `F1M` on the committed tree;
  expected RED at BookAscent 805 "action != nil" and MarkdownFace 188 "headingSize != nil". Each run
  reverted with `git checkout --` of the two files, status clean, zero markers.
  **RUNS A/B — DONE, REVERTED** (`19d/r1-runA.diff`, `r1-runB.diff`; `mac-r1-runA.log`,
  `mac-r1-runB.log`, 22 tests / 2 suites each, zero-instance windows — `pgrep` empty 17:56:48Z–
  17:57:51Z and 17:59:18Z–18:00:20Z; restored, status clean, zero markers, the four sha256s OK):
  - **`BookAscentTests:803` — GENUINELY SILENT, now PINNED by my own pair:** run A (the OLD spelling
    under P1) records NOTHING at the site (804 there) — only 805 `action?.label == "Do it"` (nil)
    and 807; run B (the new spelling) RED at 805 "action != nil". **FIXED.**
  - **`MarkdownFaceTests:187` — HOLLOW, the round-1 F1 finding does NOT hold for this site:** under
    a REAL nil (`F1M`), run A's OLD spelling RECORDS AT ITS OWN LINE — "Expectation failed:
    font(storage, at: titleAt).pointSize" at 187 — then 188/194. The reviewer's P2 left
    `headingSize` at 12.0, so its logged silence never exercised the site. Run B's new spelling
    records at its own line (188 "headingSize != nil"): the re-spell is BEHAVIOUR-IDENTICAL.
    **Disposition: DISMISSED AS HOLLOW as a silent-nil finding; the edit (`6e0a359c`) STANDS as an
    F2-class CLEANUP** (F2's tripwire requires every `try? #require` gone). Routed to the
    orchestrator: the "19d ROUND 1" F1 text names this site silent.
  - **The route ≠ the behaviour, by counterexample:** `MarkdownFace:187` compiles to
    `__checkPropertyAccess` — the decomposed form — yet records. So my round-0 "38/38 route ⇔
    runtime" and the arbitration's "held 40/40" are 40 of 41: **the route RANKS a site, it never
    settles one; only a real-nil mutant does** (R2-1's lesson, one level down).
- F3 [NIT] wording + NOTICED #1/#2/#4 corrections — DONE (this commit): the mechanism heading reworded (the route the compiler chose; the bindings inferred, settled at runtime), the 38/38 claim corrected to 40 of 41, the census's floor claim and NOTICED #1/#2/#4 each carry an in-place correction note kept beside the original text.
- **Tripwire + final builds + suites — DONE (this commit).** **The tripwire `grep -rnE
  'try\?[[:space:]]*(await[[:space:]]+)?#require'` over all five test roots → 0.** FULLY FRESH
  round-1 builds (`core-bt-r1final.log` `Build complete!`; `mac-bft-r1final.log` /
  `mobile-bft-r1final.log` `** TEST BUILD SUCCEEDED **`): **redundancy warnings core 0 · Mac 0 ·
  mobile 0 — no exceptions** (`*-census-r1final.txt`; mobile's one line is the not-owned app-source
  always-true, `SpikeScenarios.swift:240`); always-true in test files 0. Nothing added anywhere
  (`warnsets.py`, base `*-0` → `*-r1final`): core 30 → 22 (−8), Mac 102 → 73 (−29 = 26 redundancy
  + 621 + 262's two lines), mobile 47 → 43 (−4); added: NONE. **Suites** — every suite type in all
  26 files changed by the entry (`r1-touched-files.txt`; the gated drill's file excluded, left
  off), `test-without-building` on the round-1 products: **Mac `✔ Test run with 360 tests in 52
  suites passed`** (360 = those files' `@Test` count exactly; ZERO `skipped:`; a ZERO-INSTANCE
  window — `pgrep` empty before 18:07:11Z and after 18:09:03Z, `mac-r1final-suites.window`) ·
  **mobile `✔ Test run with 24 tests in 2 suites passed`** (zero `skipped:`; iPhone 17 Pro / iOS
  26.2) · **core `✔ Test run with 61 tests in 11 suites passed`** (zero `skipped:`). Evidence 5.2 GB
  (the round-0 build products deleted, every log kept; the round-1 products kept for round 2).
- **THE ROUND-1 FIX DIFF (`git diff f3f5c3a0..HEAD -- App Tests Sources`): 14 test files, 40+/22−,
  no other path.** 20 macro lines removed (the 2 F1 sites + the 18 hollow), 21 added (2 + 8 core
  hoists + `TrashAndArchive`'s rewritten outer line + 6 Mac hoists + 4 Mac `#expect(x != nil)`).
  For round 2 to check: every downstream line byte-identical; every hoist placed where its argument
  was evaluated (each rule encoded immediately before its own `createReading`; each `picked` read
  after its field's pick); `try` sites still abort, `try?` sites still continue — the round-1
  mutant run's logs show it per site (`core-r1-M1.log`, `mac-r1-M1.log`).
- **Commits:** `4439b157` (opened; the sweep) · `6e0a359c` (F1 re-spells) · `668846bb` (F2 core) ·
  `83955f96` (F2 Mac; tripwire 0) · `94c2e9c3` (round-1 run announced) · `84dd79b5` (round-1 run
  results; the P2 finding; runs A/B announced) · `d3b9c01e` (runs A/B) · `aac611d4` (F3) · this
  commit (final builds, suites, table/totals/acceptance, State → ROUND-2-PENDING).
- **FOR THE ORCHESTRATOR (routed, not acted on):** (a) the "19d ROUND 1" section's F1 text names
  `MarkdownFaceTests:187` a live silent site and its arbitration says the route mapping "held 40/40"
  — both are corrected by runs A/B (187 is hollow under a real nil; the mapping is 40 of 41); (b)
  the reviewer's P2 probe was non-discriminating (`NSTextStorage` re-fixes a removed `.font` to a
  12-pt default) — a mutant-design lesson worth keeping: CONFIRM the mutant's value is the one
  intended (here, the captured `→ 12.0` said so) before reading a silence.

---

## 19f RECORD (the implementer's LIVE STATUS — Opus, 2026-10-04; DONE(hash) / IN-PROGRESS / PENDING)

**NOT DONE BY THIS ENTRY (stated first, per the contract; FINAL at the stop, 2026-10-04):**
- **`/Applications/Variorum.app` was NOT refreshed and nothing was released** — her rule, recorded
  this same evening in the 13r handoff's item 8 (`6c812d6f`): a release's trigger is always her
  explicit word, and `/Applications` refreshes are her test road. Until one carries 19f, the
  shipped 0.9.1 still opens the draft directly (F-W5's dead-end stands there).
- **A Variorum mail draft has still never been seen on screen on this M3** — its Mail still has no
  account, so the walk's Open in Mail leg reached Mail's Add Account sheet (F-W5, unchanged
  beneath the choice). Only FEEDBACK's Open in Mail was pressed in the walk; the report's Open in
  Mail (the compose-with-attachment road) is pinned headless (`theReportDoorAsksBeforeAnyDraftOpens`
  + SupportDraftTests' road pins), not walked.
- **The Help door's door-level pin is SOURCE-TEXT** (`theHelpDoorAsksBeforeItsDraftOpens` — a
  `Commands` struct's private act, the SupportDraftTests precedent for this very door); the
  behaviour beneath it is pinned through the shared dispatcher and the channel, and walked.
- **Core and mobile were not run** — zero `Sources/`, `Shared/`, mobile paths. (The FULL Mac suite
  WAS run, at the zero-instance window the author opened and the orchestrator relayed — below.)
  Its two real reds are PRE-EXISTING and not 19f's: 19e's queued runbook drift, and a NEW-TO-THE-
  RECORD regression of the 13u4 S3 class pin (`ChromeLineLimitTests`) — routed below, NOT fixed
  here (another unit).
- QUESTIONS **#182** (a)–(e) are PROVISIONAL, awaiting her; (c) confirmed on screen.
- ~400 pre-existing test-host fixture dirs in the Debug container's `tmp/` (the U3-B pins' and
  older) — recorded, not swept (only this entry's 12 removed).
- No `Sources/VariorumCore/Sync/`, no schema, no `Shared/`, no mobile, no `Server/`; her real store
  and her app never touched (her app absent at every check); no subagent spawned.

**Session start (2026-10-04):** toolchain re-read — macOS 27.0 (26A428) · Xcode 27.0 (27A266a) ·
`xcode-select -p` = `/Applications/Xcode.app/Contents/Developer` (the pinned pair). Zero instances
(`pgrep -fl 'Variorum.app/Contents/MacOS'`: no match). Base `505df96e` = origin, tree clean, commit
count 4934. Read in this session, in full: this ledger's header + row f; QUESTIONS #181 (the ruled
(i) and the ratified (a)–(h)); the 13r plan's binding principles P-1…P-9, the U3-B RECORD (pieces
1–7, the walk, F-W5) and the LADDER's F5 exchange + fix (`15ce51b5`); `SupportMail.swift`,
`SupportDraft.swift`, `DiagnosticsPane.swift`, `DiagnosticsCopy.swift`, the Help door in
`EditorCommands.swift`, `ShellRouter`'s ask channel + `RootView`'s `shellConfirmAlert` host,
`SupportDraftTests` (13), `DiagnosticsPaneTests` (8), `ShellConfirmTests`; KnownIssues row 67 (the
app's confirms are SwiftUI `.alert`s; an app-modal `runModal()` is unpinnable headless);
`Tools/WalkKit/README.md` + `guard.sh`/`click.sh`/`keys.sh`; `notes/SessionResiliencyProtocol.md`.
Evidence dir: `App/Variorum/DerivedData/19f/` (gitignored).

**THE DESIGN (decided before any edit; the reviewer checks it):**
- ONE question, ONE dispatcher, in `SupportMail.swift`: `SupportQuestion` (`.feedback` — "Open in
  Mail" / "Copy the address"; `.report(file:)` — "Open in Mail" / "Show the file and copy the
  address", carrying the report's file) and `SupportMail.ask(_:choose:roads:pasteboard:openInMail:)`
  — it ASKS FIRST; a dismissed question opens nothing; "Open in Mail" runs the door's OWN road (the
  closure — exactly today's `SupportMail.open`, (a)/(b) unchanged beneath the choice); the second
  road puts `support@stargazing.tech` on the pasteboard and, for a report, reveals the file through
  the existing `roads.reveal` — no draft, no mail app. `SupportMailRoads` is UNCHANGED (still
  send-free; the test double `RecordingRoads` rides unmodified); the pasteboard is a parameter so a
  pin drives the real write against a PRIVATE named pasteboard (the `TakeClipboard`/`WordsClipboard`
  precedent — her clipboard is never a test's).
- ONE channel + ONE presenter for the choice, `Features/Diagnostics/SupportChoice.swift`:
  `SupportChoiceAsk` (the `ShellRouter.ask` continuation shape and its three pinned rules —
  dismissal is an answer, a second ask answers the first, answer-and-clear is one act) and
  `.supportChoiceAlert(_:)`, a SwiftUI `.alert` (row 67's grammar). The report door's pane hosts one;
  the Help door asks through the WINDOW — `ShellRouter.supportChoice`, hosted by `RootView` beside
  `shellConfirmAlert` (the ask channel's road; the `whatsNewRequested` precedent of a feature request
  on the shell). With no window to ask in (store not open, or every window closed) the Help door —
  always enabled — asks through an app-modal alert, its own existing no-window voice.
- The doors: `DiagnosticsPane.send` and `EditorCommands.sendFeedback` ask through `SupportMail.ask`;
  each door's mail road is its old act VERBATIM inside the "Open in Mail" closure (so the Help
  door's source still reads `SupportMail.open(.feedback(.thisMac()))` — SupportDraftTests'
  13th pin rides unmodified, and truthfully).
- **Pin-before-fix order:** piece 1 lands the choice layer + the pane's injectable chooser/pasteboard
  with the doors STILL composing directly (the old shape); the door pins are written against it and
  run RED there; piece 2 flips the doors; green; then a recorded revert of the two door call sites →
  red; restore → green.

**Pieces:**
1. The choice layer + its pins; the doors unchanged — **DONE (this commit).**
   - `SupportMail.swift`: `SupportChoice`, `SupportQuestion` (`.feedback` / `.report(file:)`),
     `SupportChooser`, `SupportMail.Answer` and `SupportMail.ask` (above). `SupportDraft.swift`'s
     `SupportCopy`: her three button words verbatim ("Open in Mail", "Show the file and copy the
     address", "Copy the address"), the two titles + details (FUNCTIONAL — 13s re-voices), the two
     copy receipts. `SupportChoice.swift` (new): `SupportChoiceAsk`, `.supportChoiceAlert(_:)`,
     `SupportChoiceModal` (the no-window app-modal ask). `ShellRouter.supportChoice` + `RootView`'s
     `.supportChoiceAlert(router.supportChoice)` beside `shellConfirmAlert` (inert until piece 2).
     `DiagnosticsPane`: injectable `pasteboard` + `choose` (nil = its own `.alert`) and `send`
     internal so a pin can press the door — **its body still composes directly (the old shape).**
   - Pins: `VariorumTests/SupportChoiceTests.swift` (11 — the channel's three rules + the per-shell
     channel; the dispatcher asks FIRST (no road, no copy, no reveal before the answer); a dismissal
     does nothing; Open in Mail runs the door's own road (the U3-B mailto, unchanged); Copy the
     address = the address alone on a PRIVATE pasteboard, no draft, nothing revealed for feedback;
     the report's road reveals ITS file; her words). Red-on-old by construction (new API).
   - **Run (zero instances, `-derivedDataPath DerivedData/19f/dd`): `Test run with 37 tests in 4
     suites passed`, no `skipped:` line** — SupportChoice 11 + SupportDraft 13 (UNMODIFIED) +
     DiagnosticsPane 8 + ShellConfirm 5 (`19f/p1-test.log`; build `p1-bft.log`, no warning in any
     touched file).
2. The door pins RED on piece 1's tree; the doors ask; GREEN; the revert check — **DONE except the
   revert check (this commit); the revert check IN-PROGRESS — ANNOUNCED HERE BEFORE IT STARTS.**
   - Four door pins added to `SupportChoiceTests` (15 now): `theReportDoorAsksBeforeAnyDraftOpens`
     (the pane's Send Report… pressed through `send(_:)`: the report's question on screen, NOTHING
     composed/opened/revealed/copied; then Open in Mail = the U3-B compose with the report's own
     file), `theReportDoorsSecondRoadShowsTheFileAndCopiesTheAddress` (the file revealed, the
     address on the private pasteboard, no draft), `aDismissedReportQuestionOpensNothing`,
     `theHelpDoorAsksBeforeItsDraftOpens` (a `Commands` door — read from its source on the
     SupportDraftTests precedent for this very door: the act asks the feedback question, of the
     window's `supportChoice` or the `SupportChoiceModal` fallback, and its ONE
     `SupportMail.open(.feedback(.thisMac()))` sits after/inside the ask).
   - **RED ON THE OLD SHAPE (piece 1's tree, `ba5949b4`, the doors composing directly; pins
     uncommitted): `Test run with 15 tests in 1 suite failed … with 9 issues` — exactly the 4 door
     pins** (the report door: no question asked + composed at the press, ×3 tests; the Help door:
     no `SupportMail.ask(.feedback` in its act); the 11 layer pins green (`19f/p2-red.log`).
   - THE FIX: `DiagnosticsPane.send` and `EditorCommands.sendFeedback` ask through `SupportMail.ask`
     — the report door with its pane's `.alert` (or the injected chooser); the Help door of the
     window (`windows.creationRouter()?.supportChoice` — the full window raised if Settings or a
     note window is key) or, with no window, `SupportChoiceModal`. Each door's old act sits VERBATIM
     inside the Open in Mail closure. The second road's receipt: the pane's caption
     (`copiedAddressShowingFile`), the Help door's status seam (`copiedAddress`, a RECEIPT — her
     confirmations setting governs it); with no store, nothing more is said (the question's own
     words said what the button does).
   - **GREEN: `Test run with 41 tests in 4 suites passed`, no `skipped:` line** — SupportChoice 15 +
     SupportDraft 13 (UNMODIFIED) + DiagnosticsPane 8 + ShellConfirm 5 (`19f/p2-green.log`; no
     warning in any touched file).
   - **THE REVERT CHECK (announced; the committed tree is THIS commit, so `git diff` against it
     shows exactly what is reverted):** the two door call sites restored to piece 1's text
     (`git show ba5949b4:<path>` over `App/Variorum/Variorum/Features/Settings/DiagnosticsPane.swift`
     and `App/Variorum/Variorum/EditorCommands.swift`), the suite run, then `git checkout HEAD --`
     on exactly those two paths and the suite re-run. If a session dies mid-check: `git diff` shows
     the reverted lines; `git checkout HEAD --` those two paths restores the fix. **DONE (this
     commit's predecessor's tree): REVERTED → `Test run with 28 tests in 2 suites failed … with 9
     issues` — exactly the 4 door pins, the same 9 issues as the pre-fix run; SupportDraftTests 13
     green on BOTH sides (`19f/p2-revert.log`). RESTORED (`git diff` empty) → `Test run with 28
     tests in 2 suites passed`, no `skipped:` line (`19f/p2-restored.log`).** No hollow pin.
3. QUESTIONS #182 (the readings the ruling leaves open) — **DONE (this commit).** (a) the Help door
   asks in the main window's `.alert` (raised from Settings/a note window), and with NO window an
   app-modal alert; (b) the second road's receipts (status seam / the pane's caption / silent with
   no store); (c) "Open in Mail" first and the default button — **its default-ness is the walk's to
   confirm (PENDING)**; (d) **THE PASTEBOARD READING (the brief's ask, one line): the copied
   address does NOT expire — it is a public address; the twelve words' 60 s clear exists because
   they are a secret (the simpler position, taken);** (e) one word of the Diagnostics promise:
   "Send Report… opens an email draft…" → "**offers**" (it asks first now; `DiagnosticsCopy.swift`,
   pin-neutral — `thePromiseSaysWhatTheCodeDoes` checks substrings this word is not in; flagged for
   the reviewer as the one copy line touched outside the question's own words).
4. The dev-store walk (both doors' choice, the roads in use) — **DONE (this commit). The restore
   point, named before it ran** (Debug build `App/Variorum/DerivedData/19f/dd/Build/Products/Debug/
   Variorum.app`, `io.lduarte.Variorum.debug` 0.9.1 (4939), the fenced dev store; `cliclick` +
   `Tools/WalkKit`, every act behind `guard.sh`; her app absent; the host holds AX + Screen
   Recording (a compiled probe: `AX: true SCREEN: true`). Captures into the NEW gitignored
   `notes/plans/19-screens/19f/` (this commit adds the ledger's `notes/plans/19-screens/` line —
   the per-phase screens precedent; no 19 entry walked before).
   - **State before:** the dev domain's prefs EXPORTED to the gitignored
     `App/Variorum/DerivedData/19f/devprefs-prewalk/io.lduarte.Variorum.debug.plist` (the opt-in
     key ABSENT there); the dev container has NO `Application Support/Diagnostics` folder; Mail NOT
     running; HER CLIPBOARD holds 123 bytes of plain text (utf8/utf16/string), saved to this
     session's scratchpad (never the repo) for the restore — the walk's copy road MUST write the
     general pasteboard, that is the act under test.
   - **Restore at the walk's end (app quit by identity):** `defaults import` the export, then
     delete `variorum.crashReports.optIn` (import MERGES — the U3-B lesson) and diff the domain's
     export against the pre-walk one; remove the walk's `Application Support/Diagnostics` folder and
     its synthetic file under the container's `Data/tmp/`; the voice back to what it was; Mail quit
     if the Open in Mail leg launched it (any compose window closed UNSENT); the Finder window the
     reveal opened closed; her clipboard restored with `pbcopy` and its byte count/sha256 compared.
   - **The legs:** (1) Settings ▸ Diagnostics with one synthetic report (the opt-in ON + the U3-B
     env door) → Send Report… → THE CHOICE on screen (Terminal) → "Show the file and copy the
     address" → Finder shows the file, `pbpaste` reads the address, the pane's receipt, no Mail;
     (2) Send Report… → Cancel → nothing; (3) the choice in STUDY; (4) Help ▸ Send Feedback…
     pressed while Settings is key → the main window comes forward and asks → "Copy the address" →
     `pbpaste` + the bottom bar's receipt; (5) Help ▸ Send Feedback… → "Open in Mail" → the U3-B
     road (Mail's Add Account sheet on this M3 — F-W5 — or a draft), closed unsent; (6) every window
     closed → Help ▸ Send Feedback… → the app-modal ask → Cancel; (7) Help ▸ Restore Tutorial… still
     asks (the second `.alert` host on `RootView` did not displace the first) → Cancel.
   **THE WALK — DONE, RESTORED (2026-10-04 ~03:06–03:14Z; every act behind `guard.sh` — `--author`
   first; her app absent throughout, idle ≥ 26 min at the start; captures in the gitignored
   `notes/plans/19-screens/19f/`):**
   - `w0/` — launch with the synthetic env + the opt-in ON: `crash-report-20261005T030632Z-c93d9bf3
     .json` born AT LAUNCH (the U3-B road). `w1/`, `w1b/` — Settings ▸ Diagnostics (Terminal): the
     card, the doors, and the promise reading "**offers** an email draft".
   - `w2-choice-terminal/` — **Send Report… → THE CHOICE ON SCREEN, nothing opened:** "Send this
     crash report", the detail, **Open in Mail** (the blue DEFAULT — #182 (c) CONFIRMED: SwiftUI makes
     the first button Return's), **Show the file and copy the address**, Cancel; Mail NOT launched, no
     Finder window.
   - `w3-copied-report/` + `w3-finder/` — **"Show the file and copy the address":** `pbpaste` read
     exactly `support@stargazing.tech`; Finder came forward on a "Crash Reports" window with THE
     report's file selected; the pane's caption: "Copied support@stargazing.tech and showed
     crash-report-20261005T030632Z-c93d9bf3.json in Finder — attach it to an email from any mail
     app."; Mail NOT launched — **no mail app needed, the F-W5 dead-end closed by construction.**
   - `w4-cancel/` — a marker on the pasteboard, the reveal's window closed, Send Report… → the
     choice → **Cancel → nothing:** the marker unchanged, no Finder window, no Mail, no caption
     (the earlier receipt cleared at the press).
   - `w5-study/` — the voice → STUDY (Settings ▸ General's AX radio); Send Report… → **the same
     choice** (system alert chrome — identical in both voices, as the `.alert` grammar is), dismissed
     with **Escape → nothing** (the binding's nil road: marker, Finder, Mail all unchanged). The voice
     back to TERMINAL (the radio read `10`).
   - `w6-feedback-choice/` — **Help ▸ Send Feedback… pressed with SETTINGS KEY → the main window came
     forward and asked** ("Send feedback" · Open in Mail · Copy the address · Cancel); Mail NOT
     launched, the marker unchanged.
   - `w7-feedback-copied/` — **"Copy the address":** `pbpaste` = the address; the bottom bar's
     QUIET receipt "Copied support@stargazing.tech — paste it into any mail app."; no Mail.
   - `w8-open-in-mail/` — Help ▸ Send Feedback… → **"Open in Mail" → the U3-B road EXACTLY:** Mail
     (not running before) launched into its own **Add Account** sheet — this M3's Mail still has no
     account, F-W5 as measured — the pasteboard untouched; Mail's Cancel QUIT Mail (as U3-B
     measured). Nothing sent (no account exists to send from).
   - `w9-restore-tutorial/` — **Help ▸ Restore Tutorial… still asks through ITS `.alert`** ("Restore
     the tutorial?" · Cancel · Replace) — the second host on `RootView` displaced nothing; Escape →
     gone, nothing replaced.
   - `w10-no-window-modal/` — Settings and the main window CLOSED (the app frontmost with zero
     windows) → Help ▸ Send Feedback… → **the app-modal ask** (`AXDialog` 260×350 at (734,217),
     captured by frame): the same title, words and three buttons (with the Debug build's generic
     icon); "Copy the address" pressed BY NAME → `pbpaste` = the address; no Mail.
   - **RESTORED:** the dev app quit by identity (zero instances after); `defaults import` of the
     export + the `variorum.crashReports.optIn` delete → **the domain's export diffed against the
     pre-walk one: 0 lines**; the walk's `Application Support/Diagnostics` folder and synthetic file
     removed (neither existed before); the voice Terminal; Mail NOT running (as before); the reveal's
     Finder window closed (the one Finder window left, "DerivedData", predates the walk); **her
     clipboard restored — 123 bytes, the same sha256 prefix `c936d3f768adbb57`, the same three types
     — and the scratch copy deleted.** Also removed: the 12 `19f-door-*` fixture stores my pin runs
     left in the Debug container's `tmp/` (the test host shares it; the U3-B pins leave theirs too —
     ~400 entries of that pre-existing class remain, recorded not swept).
   - **Machinery, recorded:** mid-walk-staging the orchestrator committed `34bf1485` (its own
     `notes/handoffs/phase-13r-handoff.md` line) in this same checkout — a disjoint file; every 19f
     commit is pathspec-limited. The voiced card doors are NOT exposed to AX in the Settings form
     (`entire contents` finds no `AXButton`), so Send Report… was pressed by guarded click at a point
     read from a fresh capture; the alert's buttons likewise (or by Escape); the no-window modal's
     buttons by AX name.
5. Finals (suites, scope, record) — **DONE (this commit).**
   - **Build at HEAD (`finals-bft.log`): TEST BUILD SUCCEEDED, no warning in any touched file.**
   - **FAMILY A — U3-B's 31-suite close set + `SupportChoiceTests` (zero instances): `Test run with
     289 tests in 32 suites` — 1 issue, EXACTLY 19e's pre-existing
     `DataSafetyRunbookTests.theShippedRunbookAndTheRepoCopyAreOneDocument`; the `skipped:` lines
     are exactly the 7 opt-in `DebugOracleSingletonWindowTests` + their suite (as always).** 289 =
     the ladder's 274 baseline + this entry's 15 (`finals-familyA.log`).
   - **FAMILY B — the ladder's 34-suite shell-landing/windows/tutorial/command-routing/note-box set
     (RootView, ShellRouter and EditorCommands are touched): `Test run with 166 tests in 34 suites
     passed`, no `skipped:` line — the baseline exact** (`finals-familyB.log`).
   - **SCOPE (`git log 505df96e..HEAD`, the 19f commits only):** `EditorCommands.swift`,
     `RootView.swift`, `ShellRouter.swift`, `Features/Diagnostics/{SupportMail,SupportDraft,
     SupportChoice(new)}.swift`, `Features/Settings/{DiagnosticsPane,DiagnosticsCopy}.swift`,
     `VariorumTests/SupportChoiceTests.swift` (new), `.gitignore` (one line), `notes/QUESTIONS.md`
     (#182), this ledger. 648+/21− in `App/`. **No `Sources/`, `Shared/`, mobile, `Server/` or
     `Sync/` path.** SupportDraftTests.swift UNTOUCHED (its 13 pins ride unmodified, green on both
     sides of the revert). The range also holds the orchestrator's own commits (`9ce643ec`,
     `34bf1485`, `6c812d6f` — FuturePhases + the 13r handoff), none of them 19f's.

   - **THE FULL MAC SUITE (the author's zero-instance window, relayed by the orchestrator: "my app
     is closed & prepared"; zero instances re-checked by this session; launched detached to its log
     and POLLED IN THE FOREGROUND to its end, 03:23→03:49Z): `Test run with 3812 tests in 618 suites
     failed after 1557.035 seconds with 7 issues (including 5 known issues)`** (`finals-fullmac.log`)
     — the 5 KNOWN are declared `withKnownIssue`s (IndexTierMetrics `overTwoBlankLines` ×4, both
     voices; TakesFindBoard's Esc boundary ×1); the 17 `skipped:` lines are exactly the env-gated
     opt-in drill/oracle suites (Apple-key round trip, migration/posture/connect drills, the
     singleton-window oracles) and their tests; `SupportChoiceTests` passed. **The 2 real issues,
     BOTH PRE-EXISTING, neither 19f's:** (i) 19e's runbook drift (named, queued); (ii)
     **`ChromeLineLimitTests.everyBareFixedSizeStatesItsLinePolicy` — 4 offenders: `Features/Shelf/
     BookcaseStrip.swift:227` and `:342` (last touched `52262af7`, 13i-d U1, 2026-10-02) and
     `Features/BookView/BookSettingsSheet.swift:521` and `:575` (last touched `2f3109fe`, 13i-e U2,
     2026-10-03) — bare `.fixedSize()` with no `lineLimit` within four lines (P-8; the 13u4 S3
     class pin, KnownIssues row 37's closer).** The pin is a pure source scan, and both files AND
     the pin are byte-unchanged since this entry's base `505df96e` (`git diff --stat` empty), so the
     red stands identically at the base. **ROUTED to the orchestrator (a ledger-letter candidate:
     the class pin catching a 13i-d/13i-e regression; every finals family since then ran without
     this suite). NOT fixed here — another surface, another unit.**

**DISPOSITION (the entry's letter, row by row):**
- *Before ANY draft opens, both doors ask* — **FIXED**, pins `theReportDoorAsksBeforeAnyDraftOpens`,
  `aDismissedReportQuestionOpensNothing`, `theHelpDoorAsksBeforeItsDraftOpens` (+ the dispatcher's
  `theQuestionComesBeforeAnyRoad`, `aDismissedQuestionDoesNothingAtAll`); **red on the old shape (9
  issues) and by revert (the same 9), green after**; walked on both doors (w2, w4, w5, w6, w10).
- *The copy road lands the address on the pasteboard and, for a report, reveals the file; no draft*
  — **FIXED**, pins `theReportDoorsSecondRoadShowsTheFileAndCopiesTheAddress` (red on old/by
  revert), `copyTheAddressPutsTheAddressOnThePasteboardAndOpensNoDraft`,
  `showTheFileAndCopyTheAddressRevealsTheReportsOwnFile`; walked (w3, w7, w10).
- *Open in Mail takes exactly today's roads; no send road exists or is added* — **HELD**:
  `SupportMailRoads` unchanged (still send-free); each door's U3-B act verbatim under the closure;
  pins `openInMailTakesTheDoorsOwnRoadAndCopiesNothing` + the report door's compose leg; walked (w8).
- *The existing draft/attachment pins ride unmodified* — **HELD**: SupportDraftTests 13/13, file
  untouched.
- *The choice is a small calm surface in the app's alert grammar* — the `.alert` (row 67's) on both
  doors, the app-modal only where no window exists (#182 (a), PROVISIONAL).
- *The pasteboard copy's expiry* — **READING: no expiry (a public address)** — #182 (d).
- No bug-class row was found hollow. Nothing DEFERRED inside the entry's letter.

**FOR THE REVIEWER (flagged, not decided):** (1) `SupportChoiceAsk` REPEATS `ShellRouter.ask`'s
continuation shape rather than generalising it — the confirm is yes/no and its one caller (the
tutorial doors) would have moved; one more two-answer question would justify folding them.
(2) The one copy line outside the question's own words: the Diagnostics promise's "opens" →
"offers" (#182 (e)). (3) The Help door raises a full window behind Settings to ask
(`windows.creationRouter()`'s side effect — a chosen act, the creation-door precedent). (4) The
report door's `Task` outlives a pane that disappears mid-question only as long as the question
stands (the `.alert` goes with the pane; SwiftUI's dismissal answers nil through the binding — not
walked: closing Settings with the question up).

## 19f COLD REVIEW + THE CLOSE (2026-10-04, Opus cold review, same-model flow — the orchestrator arbitrates; THE ENTRY CLOSES)

**VERDICT: 0 BLOCKER · 0 MAJOR · 2 MINOR · 4 NIT**, with a deep clean bill (the ruled shape exact — both doors ask before any draft, the old roads byte-identical inside "Open in Mail", no send road exists, #181 (a)–(h) undrifted; the pin story independently traced — the 9 red-on-old issues reproduced assertion-by-assertion; the four implementer flags each adjudicated clean; hygiene clean). Dispositions, each at the orchestrator's arbitration:
- **M1 (the promise's twin — the Settings catalog blurb still said "opens") — FIXED AT ADJUDICATION, pin-first:** the named red-on-old pin landed (`DiagnosticsPaneTests.theCatalogBlurbSpeaksThePromisesVerb`, RED at HEAD with exactly 1 issue), then the one-word fix (`SettingsShape.swift` "opens" → "offers"); #182 (e) widened to name both sites so one overturn reverts both. (A vacuous per-test `-only-testing` run was caught and re-run at suite level — the standing trap, met again.)
- **M2 (the free-standing alert's trigger described wrongly — "every window closed" vs the real "no MAIN window") — RECORD FIXED:** #182 (a) carries the corrected clause; HER ratification of (a), taken minutes earlier on the pre-correction wording, is flagged in-entry for her one-word confirm. The unwalked Settings-open/no-main-window path is named rather than claimed.
- **N3 (the Help-door source pin's message overclaimed) — FIXED:** the message now states what the pin proves (source order), naming where the only-on-that-road half lives.
- **N4 (the windowless refusal speaks into no surface — practically unreachable) — RECORD-ONLY, next-touch:** pick the refusal's voice by the same is-there-a-window test the ask uses.
- **N5 (the stale "(PROVISIONAL #181)" header label) — FIXED:** reads "(ratified, #181 (b))".
- **N6 (the "Mail" button word vs the default-mail-app reality) — RECORDED for 13s** in #182's status block.
**Post-fix verification (the orchestrator's own hands, zero instances):** DiagnosticsPane + SupportChoice + SupportDraft — **37 tests in 3 suites PASSED**. **HER #182 RATIFICATIONS (the same sitting, the question tool): (a)–(e) ALL RATIFIED AS BUILT** — (a) subject to the corrected-clause confirm above. **19f IS CLOSED.**
**HER TEST REFRESH (2026-10-04, at her word — "my app is closed & prepared"; refreshes are her TEST road, never a release):** the A1 rail down clean again (six ok, `safety-copies/19f-refresh-*`), `/Applications` refreshed at the verified zero-instance window — **0.9.1 (build 4947), seal valid**, the refresh build swept and unregistered. Her daily drive now carries 19f: Help ▸ Send Feedback… asks the choice; Send Report… asks it whenever a report card exists. NOTHING PUBLISHED — 0.9.2 waits for her explicit word, per her standing rule.
