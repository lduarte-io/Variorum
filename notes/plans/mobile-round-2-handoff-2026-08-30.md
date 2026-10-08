# Mobile Round 2 — ORCHESTRATOR HANDOFF, written 2026-08-30

**For a session resuming the work that does NOT touch the Mac/`Shared/`
core.** Her instruction: *"I want to resume orchestration of the pieces
that aren't touching the mac shared core… I want to know what work
exactly is left, what work sits outside of the shared core."*

The round's standing documents still govern —
`mobile-round-2-orchestrator-handoff.md` (§3's batch map is THE
SCHEDULE; §9–§12 are this week's additions) and `mobile-round-2.md`.
This file is the delta and the work inventory.

---

## 0. PASTE-READY KICKOFF

> You are the architect/orchestrator for **Mobile Round 2** of the
> Variorum iPhone app. Work in `~/dev/variorum-mobile` on branch
> `mobile`, under `/architect-phase`.
>
> **READ IN FULL, YOURSELF:** `CLAUDE.md` · `notes/MobileSoul.md` ·
> `.claude/skills/architect-phase/SKILL.md` · **this file** ·
> `notes/plans/mobile-round-2-orchestrator-handoff.md` (both halves,
> §9–§12 especially) · `notes/plans/mobile-round-2.md`.
>
> **CAST: ONE SUBAGENT AT A TIME for development** (her 2026-08-30
> ruling, §12). Cold reviews MAY run in parallel. **R28 binds:
> BUILD → COLD REVIEW → FIX as one unit.**
>
> **DO NOT TOUCH `App/Variorum/Shared/EditorBrain/` or the cross-block
> planner** — 13u1 owns that seam and is running on `main`.
>
> **VERIFY, DO NOT TRUST.** Diff against the **merge-base**, never
> against `origin/main` — main moves under you (it moved 8 commits
> mid-session on 2026-08-30 and produced a false "Sources/ changed"
> reading).

---

## 1. STATE AT CUTOVER — re-derive it, do not inherit it

| | |
|---|---|
| branch | `mobile`, pushed |
| **mobile suite** | **582 / 93 green** (independently re-run at cutover, not inherited) |
| core | **1453 / 154** — baseline exact |
| Mac | **1843 / 312** — baseline exact; unverified since the fix round touched no Mac file (`git status` over `Variorum`/`Shared`/`VariorumTests` was empty). **⚠️ EXPECT A KNOWN RED THAT IS NOT THIS ROUND'S** (added at the Fable sweep, finding 5): the `fa522d6` merge brought `main`'s 13p-fix keychain work into this tree, and QUESTIONS **#91** — written by the same session — records `CustodyHandoverTests.theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable` failing on CLEAN `main`, deliberately not fixed here and routed to the Mac session. It may already be fixed by a later 13p-fix ladder round; **unverified here**. Do not spend the which-kind-of-red time this repo keeps paying — check #91 first |
| hygiene | zero `Sources/` (**vs the MERGE-BASE**), zero `Sync/`, zero `EditorBrain/`, no build config, marker **7** |
| `main` | **moved 8 commits during the session** — the 13p-fix ladder, a tech-debt sweep, the pre-13u round plan. **No merge attempted; the post-13u merge is deliberately the next session's, not this one's** |

---

## 2. HOW B1 WAS SETTLED — she asked specifically

**The finding.** The starter-Journal seed's virgin-store test is two
local reads, fired from a `.task` that is a **sibling** of the one
constructing `AppServices`/`SyncSession`. The sign-in door lives
**inside the shell** (`MobileSettingsView` → `Shared/AuthViews.swift`),
so on a fresh install there is no ordering in which the user signed in
first. A phone joining her existing account would mint a `Journal`,
designate it, pin it, and mint a note — ordinary synced inserts that
**propagate to every device**. It falsified the file header's own claim.

**The fix, and its shape is the interesting part:**

1. **The call site MOVED rather than being guarded.** The seed now runs
   from `VariorumMobileApp` **after `await start()`**
   (`VariorumMobileApp.swift:118`) instead of from a `.task` racing its
   sibling. **The concurrency was removed, not gated around** — which is
   why this is a fix and not a mitigation.
2. **A `SyncGate` of two injected facts**
   (`MobileStarterJournal.swift:148`):
   - **`belongsToAnAccount`** — a composed sync chain **OR** a
     signed-in session whose chain has not composed yet. The second
     disjunct is deliberate: **owner adoption can fail and leave a
     signed-in device unconfigured**, and that device's store still
     belongs to the account, so `isConfigured` alone reads the unsafe
     direction.
   - **`hasSyncedCleanly`** — a round finished **without error**, i.e. a
     pull-to-head landed and the store shows what the account holds.
     **A failed round is not an answer.**
3. **A bounded wait (20 s) then a re-ask of `storeIsNew`.** Timing out
   **declines without consuming the mark**, so the next launch asks
   again. Declining is free; seeding wrongly is not.
4. **It polls rather than subscribing**, deliberately:
   `onRoundCompleted` is a **single closure already owned by the
   Fragments bridge**, and furniture must not be able to break the
   bridge.

**Red proven at the duplicate itself** — `books.count → 2`.

### 2.1 🔴 B1's RESIDUAL IS HERS — she has taken it

**The gate cannot close this case:** a fresh install where nobody is
signed in seeds correctly (it genuinely is a new device's store) — and
if she **then** signs in from Settings, **her real Journal arrives
beside the starter one.**

No gate can fix it, because at seed time the store honestly was this
device's. It needs a product answer: an explicit first-run moment
(sign-in offered *before* the shell), or a post-sign-in reconciliation
(detect the arriving Journal and retire the starter). **Her words,
2026-08-30: *"B1 is a real item though - that's good to note and I'll
address it in my upcoming mac session."*** Recorded in the file header
too. **Do not build a guess for it.**

---

## 3. HER DECISIONS THIS SESSION — settled, do not reopen

- **The archive/trash IA is RULED: option 2, "Two rooms"** (§10.1) —
  Archive is a room you browse, the Trash a utility you visit; two
  doors, two destinations, nothing shared. **This unblocks batch 6c.**
- **The Library's filter vocabulary is a NEW ROW and outranks the
  archive work** (§10.2) — kind filters ("books", "posts"), not just
  the provenance filters (`bookless`, `scraps`) that exist today; and
  **Archive inherits the same set**, which is the cost she accepted by
  choosing Two rooms.
- **C2's one-take case KEEPS THE CALM SENTENCE.** Her words: *"we can
  keep the sentence for now, I just have to see it later when I'm using
  the app and doing the copy pass anyway."* **Provisional against her
  own eyes at the 13s copy pass — not a closed question, and not a
  correctness one either way.**
- **The shelf's two refinements** (§10.3) — shipped.
- **Cast: one subagent at a time for development; parallel reviews
  allowed** (§12).

---

## 4. 🟢 THE WORK LEFT THAT IS CLEAR OF THE MAC/SHARED CORE

**This is the section she asked for.** Everything below is phone-local
and can run now. Ordered as I would run it.

| # | work | notes |
|---|---|---|
| **1** | **Batch 6c — the Two-rooms IA** | Her fresh ruling. Design is `notes/plans/mobile-archive-trash-design/` (option 2) + §69's five-places map. Retires the combined "Archived & Deleted" surface |
| **2** | **The Library filter row** | **She ranked this ABOVE the archive work** — *"more important because it's where you see everything."* Kind filters; Archive inherits the same set. **Design note:** "books" and "posts" are different entity kinds, so the row may be expressing two things at once — settle that before building. **Known risk: the filter row is already at its width budget** |
| **3** | **Batch 6b — the per-note tray** | §69.3's ruled three-section shape (Archived / Leaving, deleted takes under a collapsed disclosure). Completes the recovery story with 6a |
| **4** | **Batch 9(e) — TEXT SELECTION IS BROKEN** | Her unprompted report: *"holding it down makes you scroll upwards, the exact opposite."* A daily-use defect on the core surface. **Trace the mechanism before designing.** Phone-local input handling — but **stop if it leads into `EditorBrain/`** |
| **5** | **4.5c's phone-local half** | **B45-2 (`displaySlot`/`slots[i]` coupling) FIRST — batch 7 walks straight into it.** Plus the unwired A7/#34 seam carves, the live-editor-over-a-tombstone fix, `MobileLenses.swift:419`, two one-liners. **Its cross-block SEMANTICS half is 13u1's — leave it** |
| **6** | **Batch 7** | Reorder takes · copy-all-takes · take→block · M23 copy-follows-screen · swatches + emoji · block multi-select · **PR21 replace, which HOISTS `FindReplaceGate` WITH it**. **PL-10(b) is already DONE** (the duplicate-book-name guard shipped this session) |
| **7** | **Batch 10** | Swipe shelf↔library (*"it's killing me"*) · a home-screen way to see starred notes (**a phone face — she ruled NOT a smart book; that's 13i's**) · new-note + new-chapter buttons inside a book |
| **8** | **Batch 8** | Tag-chip grammar (**HOIST `applyTypedPath`**) · cadence/pruning settings · PL-9's judgment acts · document settings · PR23 the forked voice brain (HOIST) · M14's unmeasured half |
| **9** | **The remaining review findings** | The two cold reviews' MINORs/NITs (`mobile-batch-5-cold-review.md`, `mobile-batch-6a-cold-review.md`) + the architecture review's **MINOR 3** (`MobileEditorStyle.voice` unsynchronised global), **MINOR 4** (refusal presentation's ten homes, 71 raw `String(describing:)` dumps), **NIT 1**, **NIT 2**. **Architecture MINOR 1 and MINOR 2 are NOT here — see §5** |
| **10** | **4.5a's ladder round 2** | Owed; never ran. §59's fixes are substantial and one changed pin semantics |
| **11** | **4.5e — verification only** | 13l built L-c and L-d. Confirm the `.opening` launch arm renders on the phone and that releasing an autosave coordinator at the quick note's `reset()` behaves |
| **12** | **R24** | `"more info"` → `"info"`. Three sites + two pins, written out in `mobile-batch-5-record.md`. Minutes |
| **13** | **The dedicated stability pass** | 4.5's **exit condition**; owns **M27**. 4.5 is not done until it runs |
| **14** | **The whole-round pass** | Closeout obligation **ZERO** |
| **15** | **Closeout** | 13 obligations, §7 of the standing handoff. Note **QUESTIONS.md still has ZERO round-2 entries** while ~15 items are held for her |

**Also owed and unslotted:** PL-13's faces (13l's data-safety twin —
backup freshness, sync-status slot, the `SecretCheck` face, note-level
multi-select), PL-14's remaining faces, PL-9's three judgment acts, and
PL-15's **device-only** items (the live Face ID walk, the on-device perf
leg) which **only her phone can give**.

---

## 5. 🔴 THE WORK THAT IS **NOT** CLEAR — 13u's, and why

**Do not take these. They are the reason the next session exists.**

| item | owner | why |
|---|---|---|
| **Batch 4.6** (the quick note's second pass) | **13u item 9** | It settles the quick-capture ownership model **for both platforms**. Her ruling: *"it won't need a design sitting, the mac will have decided it."* A lost-prose defect is live behind it |
| **4.5c's cross-block semantics** | **13u item 5** | Ruled once, for both platforms |
| **Architecture MINOR 1** — `applyDifferential` O(N²) | **13u item 8** | It is literally that item's row, in `Shared/EditorBrain/BlockRangeIndex.swift` |
| **Architecture MINOR 2** — structural refusal vocabulary forked across both targets | **13u-adjacent** | The fix is a `Shared/` hoist; 13u1 is rewriting that neighbourhood |
| **U-1 … U-5, U-7** | **13u item 8 + item 7** | The handback checklist's 13u half (§2b). **13l's four all landed; only these remain** |
| **The `main` → `mobile` merge** | next session | `main` moved 8 commits this session and 13u1 is live in the shared seam. **This merge is the one that can genuinely conflict — take it slowly** |

---

## 6. THE RULES THAT BIND — earned this session, at real cost

1. **Diff against the MERGE-BASE, never `origin/main`.** Main moves.
   This produced a false "`Sources/` changed" reading at cutover.
2. **Pathspec-limit the COMMIT, not just the add**
   (`git commit -m "…" -- <paths>`). A bare `git commit` publishes the
   whole index. In this repo that shipped a deletion without its
   replacement and **left the Mac target un-buildable across a commit**
   (§11.3).
3. **One simulator AND one `-derivedDataPath` per live session.** Proven
   by `strings`: a shared device's installed bundle carried another
   branch's whole test suites; `clean` + `uninstall` did not survive the
   next concurrent install. **Worst for reviewers — a contaminated run
   hands them convincing evidence for findings that are not real.**
4. **Every iPhone 16-series simulator here is iOS 18.3**, below the iOS
   26 deployment target, and is **not a valid destination**. Valid:
   *[removed for publication]*
5. **Arm `ApplicationAccessibilityEnabled` on every simulator used** —
   without it sixteen real pins fail as phantoms reading `labels were []`.
6. **The hallucination guard:** no finding fixed without tracing its
   mechanism yourself; every bug-class fix lands a **proven-red** pin.
   **A dismissal with evidence is a good outcome.** This session
   dismissed one MAJOR as stale (the review predated its fix) and
   self-reported one hollow pin — both are the guard working.
7. **A dying agent leaves WORK as well as corruption** (§10.5) — read a
   failed agent's tree for both.

---

# 7. 🔵 THE WHOLE-ROUND STATUS TABLE (written 2026-08-30 at her ask)

*Her words: "I'm still unsure of what has been done and what remains to
be done, knowing that the mac will be completing a fix round, then all
of 13u, before mobile is resumed."*

**Read the two tables as one story: everything mobile round 2 ever
scheduled is in exactly one row below.** Nothing is in both.

## 7.1 ✅ DONE — built AND cold-reviewed unless the cell says otherwise

| # | What | Built | Reviewed |
|---|---|---|---|
| **1** | M1 **the editor crash** (the round's reason) · M2a–M2e | ✅ | ✅ rounds 1+2 closed |
| **1b** | M11/PR18 whole-block-selection delete | ✅ | ✅ rounds 1+2 |
| **2** | M3 the copy door · M4 bar air | ✅ | ✅ |
| **3** | M22 **merge-then-edit** (its hoist exposed a P1 violation shipped on the Mac since 2026-07-09 — 23.8 s → 0.003 s) | ✅ | ✅ |
| **3b** | M5 **the home-screen quick note** | ✅ | ✅ (found 2 BLOCKERs) |
| **—** | R12 bar tuning · R22 one-row strip · M26 un-indent | ✅ | ✅ |
| **4** | M20 the undo door · delete a note · **the Trash** · delete a book · the on-leaving savepoint | ✅ | ✅ (found 1 BLOCKER) |
| **4.5a** | Capture & lifecycle — **Q1/Q2, two of the round's three BLOCKERs** (the quick note destroying stored text; a refused save wiping the box AND its error) | ✅ built + fixed | ⚠️ round 1 done · **ROUND 2 OWED** |
| **4.5b** | Deletion doors — **the third BLOCKER** (four dead confirm buttons; the A12 warning whose Undo *cancelled* it) + the accessibility harness + the `TrashPutBack` hoist | ✅ | ✅ **discharged by 13l's Fable review** |
| **4.5d** | The keyboard bar's geometry | ✅ | ✅ · **fix round DONE 2026-08-30** — and its finding was that **13 of 14 fixes already existed uncommitted**, so the right act was to fix nothing |
| **5** | **The shelf layout** R26/R27/R27b — her twice-stated complaint — **plus her two live refinements** (one-line box; the writing room made a pinned guarantee across 2,408 states) | ✅ | ✅ |
| **6a** | **The Block History twin** — closes the **deleted-take dark window** (deleted takes were invisible *and* un-restorable on the phone) | ✅ | ✅ |
| **—** | **PL-10(b)** the duplicate-book-name guard — the phone had zero sites where the Mac gates at five. **A UI courtesy gate, NOT a data defect** (author, 2026-08-30; no uniqueness exists on `reading.name`) | ✅ | ✅ **reviewed at the Fable sweep (2026-08-30)** — `mobile-fable-sweep-review.md` §2b discharge. *(Corrected there, finding 4: this cell used to read "✅ (was 4.5d's)", which the same document contradicted at §11.2 — 4.5d's cold review PREDATES this build work, so the wiring, the `BookNameCopy` hoist, `excluding:` and its three pins had no review at all until the sweep.)* |
| **—** | **The handback checklist**, actually run — 13l's four all landed; **nothing returned to mobile** | ✅ | n/a |
| **—** | **The mobile app's FIRST architecture review** — 0 BLOCKER · 2 MAJOR · 4 MINOR · 2 NIT | ✅ | n/a (it *is* a review) |
| **—** | **The archive/trash design session** — 4 IA options; **she ruled "Two rooms"** | ✅ | n/a |
| **—** | **The five-MAJOR fix round** — B1 the starter-Journal seeding before sign-in (**could pollute her real synced corpus**) · C2 fanned blocks reporting "one take" · A1's latch · A2 the liveness race · C1 truncated explainers | ✅ | ⚠️ **its own R28 review OWED** |
| **—** | **`main` did not build for iOS** — R3-2's sentence placed in the macOS-only branch of a `Shared/` conditional. Proven pre-existing, fixed | ✅ | n/a |

**Suites: 513/86 → 582/93.** Hygiene held the whole round: **zero
schema, zero `Sources/`, zero `Sync/`, marker 7.**

## 7.2 ⏳ REMAINING — and the fence is the point

**Column "needs Mac?" is the answer to her question.** 🔴 rows cannot
start until 13u lands; 🟢 rows could run tomorrow.

| # | What | needs Mac? |
|---|---|---|
| **6c** | ~~**The Two-rooms IA**~~ — **DONE 2026-08-31** (built `799ff11` · cold-reviewed 0 BLOCKER/0 MAJOR · fix wave `52a00fc`; the Versions face shipped WITH it; records: `mobile-batch-6c-record.md` + `-cold-review.md`; D5's purge-road hook deliberately waits for 6b's tray, precondition-pinned) | ✅ done |
| **—** | ~~**The Library's filter vocabulary**~~ — **DONE 2026-08-31** (built `19e52d5` · reviewed · fix wave `8b4d38b`; her #92 rulings + the #93(b) All = books+notes union; the Archive wears the honest reduced set — book-archiving is 13i's, #93(a); records: `mobile-batch-filters-record.md` + `-cold-review.md`) | ✅ done |
| **6b** | ~~**The per-note tray**~~ — **DONE 2026-08-31** (built `8a956b3` · cold-reviewed 0 BLOCKER/0 MAJOR · fix wave `afbcf8d`; the tray in §69.3's ruled shape + the blocks chip's three segments (Q8 answered by placement) + PR6's archive doors both directions + 6c's D5 flip + PR14's lens-dangle notices + PR22's guide chapter; **PL-14 CLOSES**; records: `mobile-batch-6b-record.md` + `-cold-review.md`) | ✅ done |
| **9** | ~~The editor's ⋯ menu · text selection~~ — **DONE 2026-08-31** (built `1260da4` · cold-reviewed 2 MAJOR/2 MINOR/4 NIT · fix wave `f0cb1f1`; verify-first found undo+redo ALREADY in the note ⋯ since batch 4 — her ask predates the build her phone runs; `Takes…` left the block ⋯; Block History moved to the per-take ⋯ opening FOCUSED; the merge vocabulary is a PROPOSE-ONLY section in the record §5 for her bundle; **the SELECTION DEFECT is TRACED-NOT-FIXED** — record §4.3–§4.5: four candidates, measured rule-outs, and a ONE-MINUTE device experiment of hers that collapses the table, joining the device queue; the stranded-`isEditable` defect it found is OWNED by the leftover-backlog batch with its fix shape ruled; records: `mobile-batch-9-record.md` + `-cold-review.md`) | ✅ done (the selection fix awaits her device experiment) |
| **4.5c** | ~~**Phone-local half only**~~ — **DONE 2026-08-31** (built `4788a95` — through TWO session deaths on the survival-record posture — · cold-reviewed 2 MAJOR/4 MINOR/4 NIT · wave `06d6163` · ROUND 2 re-review 0B/0M/3m/2n · wave 2 `6eec90e`; B45-2 fixed by-identity; the tombstone-liveness fix at the seam with the entry arm and belt both store-confirming before any refusal; Rename Lens → `presenting:`; the seam carves DEFERRED to post-13u by ruling; the sync-road silent-drop residual OWNED on the leftover-backlog row; records: `mobile-batch-45c-phone-record.md` + `-cold-review.md`) | ✅ done |
| **7** | ~~Reorder takes · take→block · copy-follows-screen · swatches + emoji · block multi-select~~ — **PHONE-LOCAL HALF DONE 2026-08-31** (built `73945ed` · cold-reviewed 2 MAJOR/4 MINOR/2 NIT · fix wave `548513d`; reorder composing #57's ruled edges · the AR-1 doors with the structural latch on the chrome button · M23 copy-follows-screen with the callout corner's HONEST receipt (the `exportMapped`→`public` one-worder rides the #94 post-merge list) · swatches+emoji with the drift pin extended · block multi-select composing `deleteWholeBlockRun`, Merge Selected deliberately withheld pending her batch-9 proposal ruling; records: `mobile-batch-7-record.md` + `-cold-review.md`). **STILL FENCE-BLOCKED, #94: PR21 replace (FindReplaceGate hoist) · copy-all-takes (TakeClipboard hoist)** — the post-13u merge session's | ✅ phone-local done (two #94 items ride the merge) |
| **10** | ~~Swipe shelf↔library · the starred face · in-book doors~~ — **DONE 2026-09-01** (built through four protocol checkpoint commits · cold-reviewed 2 MAJOR/4 MINOR/2 NIT · fix wave `8cb9c25`; the Starred‹Shelf›Library band with a settle spring, both stacks kept alive (driven); the starred page as a face — the smart book stays 13i's; New Note gated inside the mint's transaction + New Chapter curated-only, refusals spoken beside the doors; the assign-to-chapter door's placement is HER call; records: `mobile-batch-10-record.md` + `-cold-review.md`) | ✅ done — **the round PAUSES here at her word; resumes after 13u + the merge** |
| **8** | Tag-chip grammar (**HOIST `applyTypedPath`**) · cadence/pruning settings · PL-9's judgment acts · document settings · the forked voice brain (HOIST) · M14's unmeasured half | 🟢 no |
| **—** | **THE LEFTOVER REVIEW BACKLOG** (the seat road's item 7 — one consolidated batch): the three reviews' **MINORs/NITs** + architecture **MINOR 3** (unsynchronised `voice` global) and **MINOR 4** (refusal copy's ten homes, 71 raw dumps) — **plus, since 2026-08-31, one real DEFECT with its fix's shape already ruled: 🟠 `isEditable` CAN BE STRANDED FALSE, leaving her page permanently read-only with no sheet on screen.** Three overlay sheets (takes browser · comments · block history) each save the page's `isEditable`, force it false, and restore what they saved (`MobileTakesBrowserView.swift:226-234` · `MobileCommentsSheetView.swift:127-136` · `MobileBlockHistorySheetView.swift:143-150`); interleave two and the inner one saves the OUTER one's `false`, so the last restore leaves the page non-editable and nothing on the surface explains why. **Measured** at batch 9's selection trace and **independently reproduced by that batch's cold reviewer** (its MAJOR 1). **Text-loss-adjacent** — she cannot type in her own note. **THE FIX, ruled at adjudication so this batch inherits a decision:** replace the three per-sheet save/restore pairs with **ONE nesting-aware editability authority on the write surface** — a depth count (sheets push/pop; editable only at depth 0) or an equivalent restore-to-rest rule — the same "one authority" move `PaneTextAuthority` already is for liveness; **pin the two-sheet interleave red-on-old** (browser open → history open → browser close → history close ⇒ page ends editable). Batch 9's own door is already properly nested and its A6 pin (`theHistoryDoorLeavesThePageEditableAfterwards`) STAYS. Whether any pre-batch-9 road reaches the interleave is **un-established** (both other sheets are summoned from the keyboard bar, which a covering sheet hides) — so it may be latent, and that is a reason to fix it, not to wait. **AND THE SAME PHOTOGRAPH HAS A SECOND VICTIM, ROUTED HERE 2026-08-31 (batch 4.5c-phone's cold review, MINOR 4 — adjudicated as this row's, not that batch's, because the ruled fix retires the whole class):** the three sheets restore their captured `pageWasEditable` **unconditionally**, so if the NOTE DIES while a sheet is up — the sync road, or a delete on the other tab — `adoptHeader`'s relinquish sets `isEditable = false` (a no-op; the sheet already did) and the sheet's close then hands the keyboard back **over a tombstone**. No bytes move (the gate belt refuses each keystroke and `Operations.autosave` refuses a tombstoned variant either way), but 4.5c-phone's stated intent — *"the keyboard drops the moment the note does"* — is defeated, and it is the exact inverse of the stranded-false defect above: the same unconditional restore, leaking in the other direction. **The ruled fix covers both by construction** if the authority DERIVES editability at rest (`isLive && !noteIsGone && !sealed`) rather than restoring a photograph — so build it as a derivation, not as a depth-counted photograph, and **pin this direction too** (note open → sheet open → note deleted → sheet close ⇒ page ends NON-editable). The phone now has six writers of `textView.isEditable` across four files; one derivation retires the class. **AND ITS SIBLING RESIDUAL, ROUTED HERE 2026-08-31 (4.5c-phone's round-2 review, MINOR R2-3 — the same batch's second deferral, given the same owner so neither sits in a plan file that closes): 🟠 THE SYNC ROAD DROPS THE KEYBOARD WITH NOTHING ON SCREEN.** When the note dies under a surface that is HOLDING the pen — deleted on the Mac and delivered here, the road no grant covers — `adoptHeader`'s relinquish (`MobileEditorViewModel.swift:616-657`) ends her typing and **says nothing at all**, until some later grant or keystroke speaks. It is a deliberate DECLINE, traced not assumed, and the trace is sound: speaking at that transition would clobber the receipt on her commonest deletion road (`deleteNote` reports *"Moved to the Trash…"* and the observation delivers nil a beat later, so the note's own ⋯ door would answer its own act with a refusal about a door she just used — `MobileDeletionTests.deletingANoteMovesItToTheTrashAndSaysSo` pins that receipt). Two qualifications the original record did not carry, verified by the round-2 reviewer: on that road the screen is DISMISSING (`MobileNoteActions.swift:145-148`), so the clobber would be a flash under an animation rather than a state she is left in; and the Library-row road cannot clobber at all (it reports on the LIBRARY model). **THE DESIGN QUESTION THIS NEEDS ANSWERED — it is why this is a design act and not a patch: how does a relinquish tell *"this surface deleted it"* from *"someone else did"*?** Answer that and the sentence can be spoken exactly where it is true. **The MECHANISM half is this row's; the VOICE half — what the phone should SAY when sync deletes the note under her hands — is flagged for the author's bundle** (MobileSoul §5.3's discoverability family: it is a copy decision about a surface she is standing on, not an implementation choice). Full records: `mobile-batch-9-record.md` §4.6 · `mobile-batch-45c-phone-cold-review.md` MINOR 4 + MINOR R2-3 + WAVE 2 RESULTS item 3 | 🟢 no |
| **—** | **4.5a's ladder round 2** · **the 5-MAJOR round's own review** · **4.5e verification** · **R24** (3 sites, minutes) | 🟢 no |
| **—** | **PL-13/PL-14/PL-9 faces** — data-safety twin, remaining recovery faces, the bridge-door judgment | 🟢 no |
| **—** | **The dedicated stability pass** — 4.5's **exit condition**; owns **M27** | 🟢 no |
| **—** | **The whole-round pass** — closeout obligation **ZERO** | 🟢 no |
| **—** | **Closeout** — 13 obligations; **QUESTIONS.md still has ZERO round-2 entries** while ~15 items are held for her | 🟢 no |
| **4.6** | **The quick note's second pass** — a **live lost-prose defect**. Waits on **13u item 9** to rule quick-capture ownership for both platforms | 🔴 **13u** |
| **4.5c** | Its **cross-block semantics** half | 🔴 **13u item 5** |
| **—** | Architecture **MINOR 1** — the O(N²) in `Shared/EditorBrain/BlockRangeIndex.swift` | 🔴 **13u item 8** (it *is* that row) |
| **—** | Architecture **MINOR 2** — refusal vocabulary forked across both targets | 🔴 13u-adjacent |
| **—** | **U-1 … U-5, U-7** — the handback checklist's 13u half | 🔴 **13u items 7–8** |
| **—** | **The `main` → `mobile` merge** | 🔴 **after 13u** |
| **—** | **PL-15's device items** — the live Face ID walk · Read-mode memory at 100k. **Only her phone can give these** | 🟣 **her device** |

## 7.3 THE ONE-LINE ANSWER TO HER QUESTION

**Fifteen of the remaining twenty-one rows do not need the Mac at all.**
Only **six** wait on 13u, and every one of them is in the editor seam —
which is exactly the seam 13u exists to settle. **The round's three
BLOCKERs are all fixed and merged**; what remains is one live defect
(4.6's lost prose, blocked by design), breadth (batches 7–10), and the
round's own closing discipline (two standalone passes + closeout).
