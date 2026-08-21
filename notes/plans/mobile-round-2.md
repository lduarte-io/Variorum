# Mobile Round 2 — stability, capture & the parity backlog

**STATUS: OPEN 2026-08-21.** Author-attended kickoff ran the same day
(her asks + four rulings recorded verbatim in §2). Cast: **ALL-OPUS**
at her explicit ruling — orchestrator, a fresh implementer per batch, a
fresh cold reviewer per ladder round, every one of them Opus. Run under
`/architect-phase` from `~/dev/variorum-mobile` on branch `mobile`.

---

## 0. KICKOFF MESSAGE (paste-ready — a fresh session starts here)

> You are the architect/orchestrator for **Mobile Round 2** of the
> Variorum iPhone app. Read, in full and yourself: `CLAUDE.md`,
> `notes/MobileSoul.md`, `notes/CoreDescription.md`,
> `notes/OverallModel.md`, `notes/AppSpec.md` §5/§7/§9,
> `notes/TEXTKIT2_NOTES.md`, and THIS FILE in full. Then read the four
> investigation records this round opened with:
> `mobile-round-2-crash-trace.md`, `-parity-inventory.md`,
> `-stability-survey.md`, `-quicknote-survey.md` (same directory).
>
> The round's spine is §6's ledger, run in §7's batch order. The crash
> (M1) outranks everything: it is the reason this round exists. Her
> standing instruction is that **nothing gates on installing to her
> phone** — build, verify, keep moving; take install windows
> opportunistically.
>
> Cast is ALL-OPUS. Reviews are DEEPER than standard by her ruling —
> §8 governs. The constitution in §5 binds every batch.

---

## 1. What this round is

The author's own framing, from the kickoff: *"your job is going to be
to try to fix some issues with the app I've found, add some features,
and do a bit of phase parity work."*

Three strands, in her priority order:

1. **Stability** — a frequent, reproducible crash in the editor, plus
   the architectural question behind it. Her words: *"The crashing is
   the biggest issue"* and *"I'd also make sure the architecture of the
   app is looking solid because the crashing is a little annoying -
   performance and stability are key!"*
2. **Features she asked for** — a copy-the-whole-note button, roomier
   spacing under the keyboard bar's three doors, and a home-screen
   quick-note capture.
3. **Parity** — the backlog the ledger has been accumulating: PL-9
   (14d), PL-10 (13e), PL-11 (13j). With one row needing MORE than
   parity (§2, ruling R4).

---

## 2. HER RULINGS (kickoff, 2026-08-21 — verbatim-faithful)

**R1 — The cast is ALL-OPUS, and reviews get the surplus.** Her words:
*"I have a lot of Opus credits at the moment and am running low on
Fable credits, so this will be an opus only phase / work. There should
be more cold reviews to account for that fact."* Later the same
sitting: *"remember that you're the orchestrator and can spawn as many
subagents as you need for your work - it's open season on opus
credits."* → §8's amplified ladder is the spend.

**R2 — The crash is the top item.** Her description, verbatim: *"the
app completely crashes frequently when I'm trying to highlight and
select something at the end or delete a paragraph at the end of
something, with multiple lines selected. there might be more cases that
trigger it but i've been seeing it crash."* She supplied two real crash
logs from her iPhone at the kickoff (§3).

**R3 — Never gate on the phone install.** Her words: *"if my phone
isn't unlocked and ready when the crash fix is ready, you should just
keep working through the phases. don't gate on that and don't freeze
development for it - i might step away before the crash launch is
ready, though i'll say when i'm stepping away."* She chose "install
once the crash fix lands, then again at the end" — but this ruling
makes both windows OPPORTUNISTIC, never blocking.

**R4 — Parity: build it all, ordered by importance.** Her words: *"you
can order by importance but i want to stay on top of the backlog and
try to add it all - if things like take reordering look too crowded
later on mobile, i'll consider different UX solutions or remove them
later. let's get the parity built in code so i can keep using the app as
fully as possible."* And on the trash row specifically: *"one of the
phases (trash) needs more than even phase parity - the actual deletion
buttons weren't added, they're in the next variorum core phase, even
though the mechanism was added, and you should add deletion buttons."*

**R5 — The quick note mints as you type.** Chosen from three offered
save models. Her requirement, verbatim: *"i like the current 'go to
entry' for the journal entry, but I want a faster note capture, maybe
that even lets you write it on the home screen and then press a button
to go into the particular note for it. I know variorum the mac app only
has the one 'type a new note here' and I think it's excellent and should
be copied - it's satisfying to type it on the home screen. at the same
time, i think the journal button shortcut is fine to keep on the mobile
app because it keeps it journaling focused, which i like. in the 'quick
note' box on the home screen, if the user just closes the app, their
note should still be saved! it should have generous instant saving so
that even if they forget to hit enter or press the button to edit it
fully, it's still saved and it should show a little icon when saved. so
they can fully write it and know it's saved from the homescreen, but
still enter to go into the full editor with takes and everything."*
The ruled model as it was put to her: *a real note is created ~1s after
the first keystroke and autosaves like any note, so it syncs to the Mac,
appears in the library, and the saved icon means genuinely saved; cost:
an abandoned one-word note is a real note you'd have to delete.*

**R6 — The copy door.** Her words: *"I also need a button added at the
top that allows me to copy everything i've written in a particular
note."* Architect's stated reading at the kickoff, uncorrected by her:
copies the whole note as markdown — the chosen takes joined, exactly
what export writes — title not included, with a brief receipt.

**R7 — The keyboard bar's three doors need air.** Her words: *"the
buttons at the bottom, the three of them, also need more generous
spacing because they're kind of touching the keyboard bar, which is
annoying."* CONFIRMED by her the same sitting when the architect read
them back as the keyboard bar's resting trio **Aa · ⑂ · ⋯**
(`MobileKeyboardBar.swift`, the `inputAccessoryView`): *"the three
buttons on the bottom are the correct buttons. you had that right."*

---

## 3. THE CRASH EVIDENCE (recorded here so no session re-derives it)

Two `.ips` logs supplied by the author, 2026-08-20, iPhone18,1 on
**iOS 26.6 (23G71)**, app version 1.0 build 1
(`io.lduarte.VariorumMobile`). Both are **`EXC_BREAKPOINT` / `SIGTRAP`
— a Swift runtime trap** (precondition/fatalError/force-unwrap/index),
NOT an Obj-C exception. Faulting thread 0, identical stacks apart from
the trap site:

```
0  BlockRangeIndex.applyBlockEdit(at:lengthDelta:)     ← 15:52:43 log
0  BlockRangeIndex.applyTailEdit(lengthDelta:)         ← 13:59:27 log
1  MobileEditorViewModel.storageDidEdit(_:changeInLength:)
2  closure #1 in MobileStorageObserver.textStorage(_:didProcessEditing:range:changeInLength:)
4  MainActor.assumeIsolated
5  @objc MobileStorageObserver.textStorage(_:didProcessEditing:…)
6  -[NSTextStorage processEditing]
7  -[NSTextStorage endEditing]
8  -[NSTextStorage coordinateEditing:]
9  -[UITextInputController _insertText:fromKeyboard:]
10 -[UITextInputController deleteBackward]
11 -[UITextView deleteBackward]
12 -[UIKBInputDelegateManager _deleteBackwardAndNotify:reinsertText:overrideOriginalContextBe…]
13 -[_UIKeyboardStateManager deleteBackwardAndNotifyAtEnd:deletionCount:reinsertTextInLoop:]
```

The two candidate trap sites, both in `App/Variorum/Shared/EditorBrain/BlockRangeIndex.swift`:
- `applyBlockEdit` — `precondition(entries[index].length + lengthDelta >= 0, "block length went negative")`
- `applyTailEdit` — `precondition(tailLength != nil, "no open tail")` / `precondition((tailLength ?? 0) + lengthDelta >= 0, "tail length went negative")`

**Two facts that shape the whole batch:**
- `BlockRangeIndex` lives in `App/Variorum/Shared/EditorBrain/` — the
  brain BOTH platforms share. The fix lands once; the Mac's exposure is
  a question the trace must answer, not assume.
- Her phone is on **iOS 26.6**; the newest simulator runtime on this
  machine is **26.2**. The UIKit input path in frames 9–13 is
  version-gated (TEXTKIT2_NOTES §5's standing corollary). **A
  non-reproduction on 26.2 is NOT evidence of absence** — record it as
  a runtime gap, never as a clean bill.

Log paths (author's machine): `<home>/Downloads/VariorumMobile-2026-08-20-155243.ips`, `…-135927.ips`.

---

## 4. The four opening investigations (spawned at kickoff, before any build)

| Record | Question it answers |
|---|---|
| `mobile-round-2-crash-trace.md` | The crash mechanism to certainty, the smallest correct fix, and the red-on-old pin design |
| `mobile-round-2-parity-inventory.md` | Every owed capability at file level, sized and ordered; the more-than-parity trash doors |
| `mobile-round-2-stability-survey.md` | The rest of the reachable-trap surface + the architecture verdict she asked for |
| `mobile-round-2-quicknote-survey.md` | What exists for the quick note, what "saved" can honestly claim, the design forks |

Findings from these are ADOPTED INTO THE LEDGER below by the architect
before any implementer sees them (repo-first). A survey finding is not
scope until it has a ledger row.

---

## 5. BINDING PRINCIPLES

### 5a. The 13b constitution (P-1…P-9, byte-verbatim per the skill's requirement)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

### 5b. This round's additions (architect, under the mandate)

- **M-A — The crash fix must convert a TRAP into a REFUSAL, never
  delete a guarantee.** `BlockRangeIndex`'s preconditions exist because
  a silently-wrong index corrupts block identity — AppSpec §15's risk
  #1. Removing or loosening a precondition to stop a crash is
  forbidden. The correct shape is the one the code already knows:
  `desyncRecovery()` — the store is truth, drop local bookkeeping,
  re-render from the projection. An unroutable edit takes that road
  visibly; it never traps and never guesses.
- **M-B — Shared brains change once, and BOTH platforms' suites run.**
  Anything under `App/Variorum/Shared/` or `Sources/VariorumCore/` is a
  both-platform change: the batch that lands it runs core + Mac + spine
  + mobile before claiming green (baselines in §9). MobileSoul §3's rule
  in its operational form.
- **M-C — No new brain in mobile app code.** Every capability this
  round adds either composes an existing core/`Shared` brain or hoists
  one there. A rule the phone implements locally that the Mac also needs
  is a parity defect at birth (the KnownIssues six-brains row is the
  standing scar).
- **M-D — ZERO schema, ZERO `Sources/VariorumCore/Sync/`.** A schema
  need is a SyncSpec §12 lockstep event — mirror-first, her explicit go.
  Stop and report; never improvise. The mirror is at **marker 7**.
- **M-E — Deletion doors are irreversible-adjacent: confirm, and say
  what will happen.** The 13j rider binds the phone identically —
  Delete Now / Empty Trash are IN-TRASH-ONLY with confirm-every-time;
  ordinary note deletion is move-to-Trash and says so. A door that
  destroys must name what it destroys before it acts.

---

## 6. THE LEDGER (every row owned; nothing sits unowned)

| # | Item | Source | Batch | Status |
|---|------|--------|-------|--------|
| M1 | **The editor crash** — the `BlockRangeIndex` trap pair reached by deleting a multi-line selection at a document's end. Trace → smallest correct fix in `Shared/EditorBrain` → red-on-old pins → Mac exposure verdict | R2 + §3 | 1 | open |
| M2 | The rest of the reachable-trap surface + the concurrency/lifecycle findings the stability survey proves | R2 (her "architecture is solid?" ask) | 1 | open — scope set by the survey |
| M3 | **Copy the whole note** — a masthead door; markdown, chosen takes joined, receipt | R6 | 2 | open |
| M4 | **Keyboard-bar spacing** — real air under Aa · ⑂ · ⋯ | R7 | 2 | open |
| M5 | **Home-screen quick note** — mint-as-you-type, saved indicator, ⏎ opens the full editor; the Today button untouched | R5 | 3 | open |
| M6 | **PL-11 — Trash, deletion & recovery faces**, INCLUDING the real deletion buttons the Mac itself does not yet have | R4 + PL-11 | 4 | open |
| M7 | **PL-10 — Takes & block management doors** (reorder takes, copy-all-takes, take-to-block-below, takes-to-blocks, the duplicate-book-name guard) | R4 + PL-10 | 5 | open |
| M8 | **PL-9 — The account sheet's phone judgment** (sheet reads right; the bridge-connect door decision; exercise the iOS `presentationAnchor` arm once) | R4 + PL-9 | 6 | open |
| M9 | The parity inventory's MISSED-capability sweep (belt and braces — anything the ledger didn't record) | MobileSoul §6 protocol | assigned on arrival | open |
| M10 | Round closeout — plan status, parity-ledger rows burned down, MobileSoul/KnownIssues/master-plan updates, the author handoff | CLAUDE.md ritual | last | open |

Design calls PL-10 holds for her (the phone's ●n comment-marker side;
the margin-hover comment door's tap shape; callout swatches/emoji
picker) are **held and bundled** for a sitting, not decided
autonomously — the propose-only rule.

---

## 7. BATCH ORDER (importance, per R4)

1. **Batch 1 — THE CRASH (M1, M2).** Nothing else ships first. Ends
   with a Release build ready for her phone; the install is taken
   whenever her phone happens to be reachable (R3 — never a gate).
2. **Batch 2 — The two fast wins (M3, M4).** Small, visible, and they
   ride the same build.
3. **Batch 3 — Quick note (M5).**
4. **Batch 4 — Trash & deletion (M6).** The largest parity row and the
   one she called out as more-than-parity.
5. **Batch 5 — Takes & block doors (M7).**
6. **Batch 6 — Account sheet + the held design calls (M8).**
7. **Closeout (M10).**

Batches 4–6 may be re-ordered on evidence from the parity inventory;
any re-order is recorded here with its reason.

---

## 8. THE REVIEW LADDER (amplified — R1's spend)

Standard is one ladder per stage. **This round runs a ladder per
BATCH**, plus two extra passes:

- **Per batch:** a FRESH cold Opus reviewer runs `notes/REVIEW_PROMPT.md`
  VERBATIM with zero framing over that batch's combined diff. Findings
  land in this file BEFORE any fix session sees them. Fixes in a fresh
  session, each with a traced mechanism and a revert-verified pin.
  Round 2 re-reviews with another fresh reviewer; a new BLOCKER/MAJOR
  earns round 3; hard cap three.
- **THE DEDICATED STABILITY PASS** (extra, this round only): after
  batch 1, one reviewer whose ONLY brief is the crash class and the
  editor's range/identity math — adversarial, tasked to find the case
  the fix misses. It reviews the fix, not the feature.
- **THE WHOLE-ROUND PASS** (extra): after the last build batch, one
  reviewer over the round's entire diff, briefed on nothing but the
  diff — the round's own cold read.

Every finding gets a written disposition here. Disputes are adjudicated
by the architect against the canonical docs; the spec outranks both
agents. The hallucination guard is absolute: no fix without a
self-traced mechanism, and every bug-class fix lands with a pin proven
red on the pre-fix code by behavioral revert.

---

## 9. ENVIRONMENT (binding for every batch)

- **Worktree** `~/dev/variorum-mobile`, branch `mobile`. Fast-forwarded
  to main's tip at kickoff (2026-08-21, `46ffa0c` — 148 commits, clean
  FF, zero conflicts). Push `origin mobile` after commits; **never push
  main**. `mobile` → `main` at her word only.
- **Simulator:** iPhone 17 family on the newest runtime — her standing
  LK1 rule. Today: `-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'`.
  **Her device is on iOS 26.6** — record the gap on anything
  input-path-shaped (§3).
- **Mobile tests:** `xcodebuild test -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile -destination …`
  from the repo root; confirm the "Test run with N tests" line; zsh
  `pipestatus`.
- **Mac tests** run from `App/Variorum/`; core via `swift test`.
- **Baselines** (the 13j closeout, 2026-08-19 — CLAUDE.md's rule: the
  previous closeout is the baseline; never run the full suite at
  session start): core **1350/141** · Mac **1546/269 FULLY GREEN** ·
  spine **63/8** · mobile **314/60** · mirror marker **7**.
- **The A4 fence:** debug/simulator builds resolve the DEV store and
  never sync. NEVER point a debug build at the real store. Her phone
  installs **Release**:
  `xcodebuild -project App/Variorum/Variorum.xcodeproj -scheme VariorumMobile -configuration Release -destination 'generic/platform=iOS' build`.
- **NEVER add a custom build configuration** (the 4G trap — SPM deps
  build Release under any configuration not named exactly "Debug",
  silently stripping the DEBUG-gated oracles out from under the tests).
- **No schema, no `Sync/`** (M-D). Backups WAL-safe before touching the
  real store (the A1 rail).

---

## 10. BATCH RECORDS

*(Each batch appends: brief given → what landed → tests → ladder
findings + dispositions → commits. Repo-first, same turn.)*

### Kickoff (2026-08-21)
- Her asks and four rulings recorded (§2); crash logs read and their
  evidence recorded (§3) so no later session re-derives it.
- `mobile` fast-forwarded to `main` (`46ffa0c`): 148 commits, 0 ahead,
  clean — 13e, 13j, and 14d's cores are now in the tree, which is what
  makes the parity batches buildable at all.
- Four investigations spawned in parallel before any build (§4).
