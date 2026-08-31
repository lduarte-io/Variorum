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
| Mac | **1843 / 312** — baseline exact; unverified since the fix round touched no Mac file (`git status` over `Variorum`/`Shared`/`VariorumTests` was empty) |
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
