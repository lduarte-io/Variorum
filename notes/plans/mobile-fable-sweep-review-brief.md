# The Fable sweep review — BRIEF (2026-08-30, written by the incoming Fable orchestrator)

**Why this review exists — the author's mandate, verbatim-faithful.** At the
Mobile Round 2 resumption she installed a Fable orchestrator and ruled a
pre-work verification pass: *"launching a Fable cold review (single Fable
subagent) focused on covering a broad variety of the work that has been done
since Fable was last working in this repo. I want to ensure that the docs are
up to date, items are not overstated from the architectural review, that
things are being sensibly done and planned, because there have been several
red flags, dropped items, overstated elements… I basically need you to do a
thorough sweep of everything + a cold review + run opus fixes on whatever are
found there before even beginning the real work of the phase."*

The round has been ALL-OPUS since its 2026-08-21 kickoff (R1). The last Fable
eyes on this repo's mobile work were the parity chain (2026-08-09) and 13l's
Fable review of the round's Mac-side changes through batch 4.5 (2026-08-23).
Everything since is Opus work reviewed only by Opus, or not reviewed at all.

---

## 1. WHO YOU ARE, AND THE POSTURE

You are a **cold Fable reviewer** with zero implementation context. Build your
own picture from the repo. `notes/REVIEW_PROMPT.md`'s standing rules bind —
read it first: read-only during review; trace a concrete mechanism or label
`SPECULATIVE`; a record's narrative is a map, not evidence; severity-ranked
findings + a clean bill; know that bug-class fixes downstream need red-on-old
pins, so label hollow-pin-shaped findings honestly. The one difference from a
phase review: your SCOPE is the author's mandate above, not one phase's plan.

**Read in full, yourself, in this order:** `CLAUDE.md` · `notes/MobileSoul.md`
· `notes/REVIEW_PROMPT.md` · `notes/plans/mobile-round-2-handoff-2026-08-30.md`
· `notes/plans/mobile-round-2-orchestrator-handoff.md` (§9–§12 especially) ·
`notes/plans/mobile-round-2.md` §52–§71 (the 4.5-era and 2026-08-30 sections;
skim earlier sections as needed) · `notes/plans/mobile-major-fix-round-record.md`
· `notes/plans/mobile-architecture-review.md` ·
`notes/plans/mobile-batch-5-record.md` + `mobile-batch-5-cold-review.md` ·
`mobile-batch-6a-cold-review.md` · `mobile-batch-4.5d-record.md` ·
`notes/QUESTIONS.md` #84–#91 · `notes/KnownIssuesAndTechDebt.md` (the
mobile-owned rows).

---

## 2. SCOPE — the round's diff `46ffa0c..HEAD`, weighted where no reviewer has been

**Diff discipline: the merge-base with `origin/main` is `43a35ef`. Diff
against it or against in-round commit ranges — NEVER against `origin/main`
(main moves; it has 7 pre-13u commits this branch deliberately does not have).**

### 2a. PRIMARY — the five-MAJOR fix round (NO review has ever run on it)

`notes/plans/mobile-major-fix-round-record.md` records fixes for B1 (the
starter-Journal `SyncGate`), C2 (the fanned-block "one take" lie), A1 (the
write-door latch — `MobileWriteLatch.swift` — with a partial
dismissal-with-evidence), A2 (the liveness `handoffGeneration` token), and C1
(the truncated explainers). **R28 owes this work a cold review and yours is
it.** Adversarially review its diff and verify the record's claims:

- Are the pins real, and really proven red-on-old? (The record claims every
  one was; it also self-reports one hollow pin caught and rewritten.)
- Is A1's partial dismissal sound? Its per-door verdict table is a CLASS
  argument over seventeen unlatched doors, not seventeen traces — is the
  class argument right, and is any "outcome safe" cell wrong?
- Is B1's gate correct in both directions (`belongsToAnAccount`'s two
  disjuncts; the poll-not-subscribe reasoning; the timeout that declines
  without consuming the mark)? Is the residual correctly scoped as hers?
- A2: does the token really make the last REQUEST win at every suspension
  point, including `register`?
- The record claims **no Mac file was touched** (so the Mac suite was not
  run). Verify by git, not by trust.

### 2b. The 4.5d fix round's NEW pins + PL-10(b)

`mobile-batch-4.5d-record.md`: the round verified 13-of-14 findings already
fixed (correctly re-fixing nothing) and proved one never-run red pin. Its own
three new pins are unreviewed, and PL-10(b) wired `assertBookNameIsFree` +
hoisted `BookNameCopy` to `Shared/`. Review both. *(Severity calibration:
the author corrected the guard's severity 2026-08-30 — a UI courtesy gate,
NOT a data defect; `reading.name` carries no uniqueness. Don't re-inflate it.)*

### 2c. 4.5a's OWED LADDER ROUND 2 — discharge it here

§59's five MAJORs were fixed at §62 (`mobile-round-2.md`), and the promised
round-2 re-review never ran (its dispatch died on an API limit). Do a real
pass over §62's fixes — the boundary-hold restore-a-turn-later (whose pin
semantics changed), the `ownsTheWholeNote` gate, the expiration-teeth fix,
MINOR 9's retry — in `MobileQuickNote.swift` and its tests. A real pass, not
a rubber stamp; your record line discharges the owed round if it holds.

### 2d. DOCS-VS-TREE — her central worry

Verify, against the tree and by running what needs running:

1. **The status table** (`mobile-round-2-handoff-2026-08-30.md` §7) — every ✅
   cell's claim. Anything overstated, half-true, or reported-done-when-only-
   the-easy-half-was is a finding at full severity.
2. **The parity ledger** (`MobileSoul.md` §6) — PL-9…PL-16 status cells
   against reality.
3. **QUESTIONS #84–#91** — accurate? complete against the round's held items?
   (Note the handoff says ~15 items were held for her; §84–#91 is eight
   entries — is anything held-for-her still homeless in a file that closes?)
4. **KnownIssues** — every mobile-owned row still accurate; no orphaned or
   blank owners; nothing this round resolved but left standing.
5. **The architecture review's disposition banners** — do they overstate what
   the five-MAJOR round did?
6. **Suite counts.** Re-run the mobile suite (private simulator + private
   DerivedData — §4 below) and core `swift test`. Claimed: mobile **582/93**
   green, core **1453/154**. Report what you measure. The Mac suite: run it
   ONLY if git shows the since-13l mobile work actually touched
   Mac-compiled code (the records claim it did not) — verify that premise
   by `git diff --name-only` first, and remember `App/Varorium/Shared/` is
   Mac-compiled while `App/Variorum/VariorumMobile/` is not.

### 2e. PLANNING SANITY

The handoff's §4 work list (items 1–15) and §5 fence: anything unowned,
homeless (the round's five-times-paid failure mode), mis-sequenced, fenced
wrong, or scheduled in prose only. Also hunt the round's own signature
failure modes anywhere in the since-13l work: green-over-nothing pins,
mechanisms traced by reading and never executed, half-done work reported
done, compressed review summaries that lost findings.

### 2f. Out of scope — do not spend here

- **13u's items** (the fence): batch 4.6, 4.5c's cross-block semantics,
  architecture MINOR 1 + MINOR 2, U-1…U-5/U-7, anything in
  `Shared/EditorBrain/` or the cross-block planner. Flag only if something
  NEW and unowned has appeared there.
- **B1's residual** — hers (#88), and a ruling already landed on `main`'s
  pre-13u sitting. Do not design for it.
- Batch 5's and 6a's cold reviews already ran — verify their FIXED banners
  and grading rather than re-reviewing those diffs line by line.
- The two standing load-flaky Mac pins (KnownIssues, owner 12), the
  known-interim combined "Archived & Deleted" surface, and the accepted
  deleted-take dark-window→6b sequencing are all owned — not findings.
- **This review does NOT discharge the dedicated stability pass or the
  whole-round pass** (their triggers and targets are defined in the standing
  handoff §3 and bind unchanged). Say so in your record so nobody later
  claims otherwise.

---

## 3. OUTPUT

Write `notes/plans/mobile-fable-sweep-review.md`: severity-ranked findings
(`[severity] · file:line or doc+section · what's wrong · evidence · proposed
fix`, each labelled MEASURED / READ-ONLY / SPECULATIVE), then a **clean bill**
of load-bearing things you checked and found solid, then one short section:
**which owed reviews this pass discharges** (2a, 2c, 2b's pins — as your pass
actually covered them, no generosity). Do not edit ANY other file. Your final
message: findings + clean bill summary only.

---

## 4. ENVIRONMENT — binding

- Branch `mobile` at `62690e1` or later, worktree `~/dev/variorum-mobile`.
  **Never `git checkout`/`stash`/`restore` anything; leave the tree
  byte-identical except your one findings file. No commits, no pushes.**
- **One pre-existing stray:** `TK2SpikeUITests.xcscheme` carries an
  uncommitted Xcode auto-rewrite. Known, not yours, not a finding — ignore it.
- **Create your OWN simulator** (`xcrun simctl create Fable-sweep
  "iPhone 17 Pro" <newest iOS 26 runtime>`), arm it —
  `xcrun simctl spawn <UDID> defaults write com.apple.Accessibility
  ApplicationAccessibilityEnabled -bool true` (without this, sixteen real
  pins fail as phantoms reading `labels were []`) — and use a **private
  `-derivedDataPath`** under this session's scratchpad. Delete the simulator
  when done. Every iPhone 16-series sim on this machine is iOS 18.3 —
  below target, never a valid destination.
- Mobile tests: `xcodebuild test -project App/Variorum/Variorum.xcodeproj
  -scheme VariorumMobile -destination 'platform=iOS Simulator,id=<YOUR-UDID>'
  -derivedDataPath <private>` from the repo root; confirm the "Test run with
  N tests" line; zsh `pipestatus`.
- **Her real Mac app may be live on this machine — never quit or kill it, no
  Release builds, no `/Applications` refresh, no device installs, never
  touch the real store.**
- You may run at most ONE Sonnet lookup subagent at a time, strictly for
  external facts (Apple docs, API signatures); never delegate repo reading.

*(Orchestrator's note, repo-first: findings from this review go to ONE Opus
fix session under R28 — BUILD→REVIEW→FIX as a unit — before any §4 batch
work begins. Dispositions will be recorded beside the findings file.)*
