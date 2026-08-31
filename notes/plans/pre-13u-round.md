# The pre-13u round (EXECUTION PLAN)

**Status: OPEN — the `/architect-phase` kickoff sitting is underway (2026-08-30 evening).**
Authored 2026-08-30 immediately after the proactive tech-debt sweep; **WIDENED the same evening by the
author's kickoff message** (the KICKOFF section below). Runs after her live `13p-fix` session (**17g**)
and before **13u1**. Runs under `/architect-phase`: the P-1…P-9 constitution in
`.claude/skills/architect-phase/SKILL.md` **binds this round by reference** (bound by pointer rather
than copied verbatim — a deliberate leanness deviation, recorded per the skill's own deviation rule).

## What this round is — and why it is not a numbered phase

A **round**, on the precedent of the post-13l polish round and the mobile parity round: a bounded,
mixed-roster session between two phases. It carries three Phase 17 entries, a cold review, a canon
amendment, an outbound brief, and one small user-visible addition.

**The vocabulary matters, so it is stated once.** The ROUND is the vehicle — a session with a plan and
a closeout. The **17 entries are the work items it carries**, and they keep their letters and close in
their own file. This round does not become a 17-entry itself, and it is not a phase-table row: only
its one product-visible deliverable (the sample library) earns a mention in the running order.

**Why these things are together.** They share a property rather than a subject: every one is work that
should happen *before* 13u1 opens the editor seam, and none is large enough to hold a phase. Two of
them also feed each other — Act 3 builds the corpus Act 4 measures against.

> **⚠️ FILE-OWNERSHIP TRAP AT KICKOFF.** `notes/plans/phase-17-standing-fixes.md` was being written by
> the concurrent `13p-fix` session when this plan was authored, so this plan deliberately does not
> touch it. **First act of this round: re-read that file** — 17g exists by now, and this round's
> cross-references into it (Acts 1, 4, 5) must be added there, not assumed.

---

## KICKOFF (2026-08-30 evening — the `/architect-phase` sitting; the author's message, itemized)

She invoked `/architect-phase` on this round. Her items, verbatim-faithful, each routed:

1. **Cast (her instruction):** *"start with a Fable cold review, use Opus implementers (unless a
   piece of machinery is exceptionally tricky), and Opus cold review when you think is right + end
   with Fable cold review at the end or also at a few intermediate points if it makes sense. Be
   judicious in use of tokens but use them where needed, because doing too much with Opus led to a
   lot of the messiness in this phase."* Her hindsight on 13p-fix: *"the 13p-fix phase ran on Opus
   only, and I think that was a mistake in hindsight (I thought it would be just signing into the
   account, but it turns out there were more issues)."* The CAST table below executes this.
2. **A test fails on clean main** — `CustodyHandoverTests.theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable`,
   proven by the mobile session on a clean detached worktree at `origin/main` (*"Pre-existing on main,
   in the 13p-fix work"*). Yet 17g's close recorded **1854/314 ALL PASSED** on its final tree — so
   the failure is environment- or state-dependent, and BOTH facts are inputs: the fix wave must trace
   WHY it reds there and passed at 17g's close (candidates: the R3-NIT process-global
   `E2EELaunchKeyCache` leak; machine keychain state), not merely re-green it.
3. **main did not build for iOS for the whole 13p-fix run** — R3-2's `wroteButUnreadable` was placed
   in the `#else` (macOS-only) arm while three `Shared/` sites reference it unconditionally. The
   mobile session proved it pre-existing and fixed it at the merge (`43a35ef`). Two consequences:
   (a) the mobile merge's Mac/`Shared` deltas JOIN Act 1's review scope; (b) **the round gains a
   standing verification gate: the iOS target must build at every batch close** — the Mac suite
   passing gave zero signal (the MobileSoul §3 class, live demonstration).
4. **17a joins the roster** (it was not in the original draft): the 13p custody residue, URGENT
   run-first per the register — the same subsystem as the CF-12/#82 rulings, so it runs as ONE
   Fable custody batch with them (Act 9).
5. **The three standing questions are put to her AT THIS SITTING** — this supersedes the same-day
   routing to 13u's agenda (`7661504`) at her own word: Act 0's B1 residual, Act 8's CF-12
   doctrinal question, and QUESTIONS #82. Rulings land in the RULINGS block below as they arrive.
6. **Her carried items ARRIVED (Act 7 fills):** (i) an eye/peek toggle on the encryption-passphrase
   set screen — *"it's annoying to have no option to glimpse at it"*; (ii) This Note's Tray UI —
   *"weird and janky UI where elements are cut off and it's badly ordered / organized"* (screenshot
   on file: a section header clipped under a divider); (iii) the Pool page — *"looks dated and
   doesn't feel good to use - the add to book as the dropdown on the far right is kinda bleh. there's
   no search in that book dropdown either so it'll get tiresome. I think tag might look better as a
   column? maybe not, but this isn't good"*; (iv) *"all of the setting pages are a mess for a user to
   look at - I do have to write my own copy, but look at how crowded this is and how it gives a user
   just a lack of clarity"* (the Encryption pane, the Account pane, the Opening Variorum pane —
   screenshots on file); (v) *"I'm concerned that the overall UI / UX with the trash / encryption /
   archived pass didn't get enough love and would like a general sweep + fix of those. I'll update
   the phrasing later and make sure the buttons stay available"*; (vi) the at-open explainer stack —
   *"this info is all good, and I certainly do need to convey it to users somehow, but this is so
   confusing to look at"*. All routed to **Act 10**.
7. **Sherlock stays in** (*"the inclusion of sherlock holmes in the library"*) — Act 3 as ruled.
8. **Environment caveat from the mobile merge, recorded:** the merged history contains one commit
   where a staging sweep left the Mac target un-buildable — **a `git bisect` across it fails to
   build for reasons unrelated to what it bisects.** Carried into every batch brief.

### CAST (executes her instruction)

| Act | Work | Implementer | Review |
|---|---|---|---|
| 1 | Cold review of 2026-08-30 IN FULL (signing + 17g + ladder fixes) **+ the mobile merge's Mac/`Shared` deltas + the failing custody test** | — | **Fable cold reviewer** (REVIEW_PROMPT verbatim, zero framing) |
| 9 (custody) | Act 1's custody-layer fixes + **17a** (8 items) + the CF-12 build per ruling + the #82 build per ruling | **Fable** — the "exceptionally tricky machinery" clause; this subsystem is why 13p-fix-on-Opus went wrong | rides the final ladder |
| 0 | The B1 fix per ruling | Opus (mobile app layer); **Fable for any `Sync/` repair half** (the standing rider) | rides the final ladder |
| 3+4 | Sherlock seed, then 17c measured on that corpus | Opus | Opus cold review (midpoint) |
| 10 | The UI/UX pass (tray · Pool · protection/settings surfaces · eye peek · trash/archived sweep · tags placement · bottom bar) | **Fable**, screenshot-verified — her mid-sitting re-cast: *"I want Fable taste + judgement on that phase because there's a variety of UI/UX improvements needed"* | Opus cold review (midpoint) |
| 5 | 17f (9 items) | Opus | Opus cold review (midpoint) |
| 2, 6 | P39 amendment · the Fragments brief | the architect | — |
| end | The whole round diff | — | **Fable cold-review ladder** (fresh reviewer per round, cap 3) |

**Sequence:** sitting rulings → Act 1 (Fable review) → Act 9 (Fable custody batch) → Acts 3+4 →
Act 10 → Act 5 → Act 0 per ruling → the Opus midpoint review + fixes over the Opus-built surface →
the final Fable ladder → closeout (Acts 2 and 6 land architect-side along the way). Strictly one
agent at a time.

### RULINGS (recorded verbatim as they land at the sitting)

**R-pre13u-1 — B1, RULED: "First write + repair."** Seed-on-first-write: the mobile starter furniture
(Journal book, designation, pin, starter note) is minted by her first WRITE, never by launch — sign
in before typing and the real Journal simply arrives; the 20-second bounded wait is deleted. PLUS the
SyncSpec §7-class convergence repair: two designated Journal books converge by deterministic keeper
(the `tag.path` pattern — smaller id keeps, memberships re-pointed, loser tombstoned; the "same book"
predicate is the batch's design item, designation + profile the candidate). The repair is `Sync/`
work — **Fable**, per the standing rider. Empty-state copy rides the seed-on-write change so a fresh
install doesn't read as broken. Her ruling lands in `QUESTIONS.md` at close per the Act 0 obligation.

**R-pre13u-2 — CF-12, her direction verbatim (translation confirmed below):** *"My inclination is
that this should be a setting that is by default off for everyone - you can force a separate unlock
for sync if you want, regardless of the keychain, or not. If it being a setting would cause issues
with handing the context forward, then I think it being a setting for only those with auto mode
enabled on keychain login is fine, but it shouldn't be required for them either. Someone who chose
keychain auto PROBABLY wants sync to also be auto, but maybe they don't I suppose."* Translation
(pending her confirm): the sync-keys gate becomes an OPT-IN setting, **DEFAULT OFF for everyone**.
OFF ⇒ no separate sync unlock — the E2EE keys ride the plain custody item behind the app's own
at-open gate, whatever the mode; under Auto, sync is auto too. ON ⇒ a separate sync unlock honored
regardless of at-open mode (two prompts is what opting in asks for). If demanded-mode availability
proves technically fraught, Auto-only visibility of the setting is acceptable to her — but it is
never required-on for anyone. **CONFIRMED at the sitting: "Yes, build that"** — including the reset
of existing checked boxes by the semantics change (her own device ends with no second prompt; one
click re-enables the separate gate if ever wanted).

**R-pre13u-3 — #82, RULED at the sitting: BIND THE STORE KEY ONLY (option c).** Her words: *"I agree
with binding the store key only - it closes the last gap where only a computer password is enough to
get your text, which is consistent."* Builds in Act 9 (the Fable custody batch): the TN3137
read→re-add-with-flag→delete-old migration for the store-key family only, round-trip pinned; E2EE
custody stays as-is. **Rider adopted with it: the one author-run iCloud-escrow verification check is
PULLED INTO THIS ROUND** (escrow ON → relaunch → confirm the reconcile reads its own item back) —
escrow becomes the load-bearing Auto safety net post-binding, so it gets proven, not assumed; the
KnownIssues R3-7 row re-homes here.

**R-pre13u-4 — the follow-on she opened (PENDING): is the nudge enough for Auto users without iCloud
Keychain, post-binding?** Her words: *"This is making me wonder for auto users if we need to rethink
the nudge if they don't use iCloud keychain or the iCloud escrow copy. I like people being able to
write without any complex setup but I dunno... is a nudge really enough for 'only this device can
open your work until you set a passphrase if you don't have icloud keychain on?' It's hard to be a
super secure app without forcing users to go through some kind of setup for their own security I
guess. But at the same time, I think maybe that is ok? when does the nudge come up? and how much of a
nudge is it? … I'm kind of questioning our overall approach."* **RULED at the sitting: STATE-AWARE
NUDGE**, her words: *"state aware nudge, but keep in mind that the phone has to invoke the same nudge
and the language maybe should be 'this device'. also, sync will be free for the first 3 months so
hopefully people sign up for sync anyway."* The shape: covered users (escrow verifiably landed, or
any secret set) keep today's gentle nudge and cadence; the EXPOSED state (Auto + no secrets + escrow
not landing) gets hardened plain-truth copy — device-neutral language ("this device", never "this
Mac") — plus a standing "Ways back in" line in the Encryption pane counting the actual legs. Never a
modal, never a gate; cadence numbers unchanged. **Both platforms invoke the same nudge brain** (her
rider — the tier detection is shared; the faces per-platform). Detection lands in Act 9 (it rides the
escrow verification); faces in Act 10 + a mobile deliverable named in the parity line.

**R-pre13u-5 — escrow check timing (her word):** *"I can do the escrow later this batch too when it's
a good moment - I'll be around for this full batch."* The author-run escrow round-trip check is
scheduled INSIDE Act 9 at a moment the custody batch calls for it.

---

## Reading order (do this first, in this order)

1. `CLAUDE.md` — especially the standing-fixes rule (the master plan is product advancement only) and
   the author-only calls.
2. `notes/ProactiveTechDebtReview-2026-08-30.md` — **the audit table first**, then P39, and the 17c and
   17f entries. Every finding carries its verifier's trace; **where finder and verifier differ the
   verifier wins.**
3. `notes/plans/phase-17-standing-fixes.md` — the philosophy, the standing rules (pin-before-fix), the
   allocation register, and **17g as the other session left it**.
4. `notes/plans/phase-13u-feel-and-polish.md` — the fold section at its end (Act 2 hands work to 13u2).
5. `notes/OverallModel.md` §9 ("how to smell a wrong design") — Act 2 turns on it.
6. For Act 3 only: `Sources/VariorumCore/Operations/Operations+Import.swift`,
   `Operations+Sections.swift`, and `App/Variorum/Variorum/Features/Tutorial/TutorialSeeder.swift`.

**The standing rules bind unchanged:** pin before fix; a pin that passes on both sides dismisses the
item as hollow rather than fixing it; no product invention (unresolved behaviour goes to
`notes/QUESTIONS.md`); schema changes get their own commit; the `Sources/VariorumCore/Sync/` Fable
rider binds any file under it.

---

# The roster

## Act 0 — OPEN HERE: the mobile B1 residual — a design discussion first, then the fix

**The author's instruction (2026-08-30):** this round OPENS with a discussion of, and suggestions for,
the residual below; **this session handles the fix.** Discussion before build — the friction doctrine
(P-5): the edges get decided on paper, not discovered by her.

### What was already fixed, and why it was a fix rather than a mitigation

*(Her account, preserved — it is the load-bearing context for the residual.)*

> It wasn't gated. The race was removed. The seed moved out of the `.task` that was a sibling of the
> one building `AppServices`, and now runs from `VariorumMobileApp` after `await start()`. That's why
> it's a fix rather than a mitigation — there is no longer an ordering to lose.
>
> On top of that, a `SyncGate` of two injected facts, and both are more careful than they look:
> **`belongsToAnAccount`** — a composed sync chain *or* a signed-in session whose chain hasn't
> composed yet. The second half is the interesting one: owner adoption can fail and leave a signed-in
> device unconfigured, and that device's store still belongs to the account. `isConfigured` alone
> reads the unsafe direction. **`hasSyncedCleanly`** — a round that finished without error, i.e. a
> pull-to-head actually landed. A failed round is not an answer — otherwise a network stumble looks
> like "nothing's here, seed away."
>
> Then a 20-second bounded wait and a re-ask of `storeIsNew`. Timing out declines without consuming
> the mark, so the next launch asks again — declining is free, seeding wrongly isn't. And it polls
> rather than subscribing, because `onRoundCompleted` is a single closure already owned by the
> Fragments bridge, and furniture must not be able to break the bridge.

### The residual the gate cannot close

> B1 has a residual the gate can't close. Fresh install, nobody signed in → seeds correctly. If you
> then sign in from Settings, your real Journal arrives beside the starter one. Closing that needs
> either an explicit first-run moment or a post-sign-in reconciliation — a product call, not a bug fix.
>
> The decisive part: the sign-in door lives inside the shell (`MobileSettingsView` →
> `Shared/AuthViews.swift`), so on a fresh install **there is no ordering in which you could have
> signed in first.**
>
> What that means concretely: install on a new phone against your existing account and it mints a
> Journal, designates it, pins it, and mints a note — all ordinary **synced inserts that propagate to
> every device.** This directly falsifies the file's own header claim that the virgin-store guard
> "protects a phone syncing an existing account down."

### The framing worth putting to her first

**Furniture that syncs is furniture that duplicates per device.** The gate can only help if the device
knows about the account *before* seeding, and the sign-in door's placement makes that impossible on a
fresh install. So the question underneath is not "how do we time the seed better" — it is **should
first-run furniture be synced content at all**, and if it must be, **what converges two devices that
each correctly decided "no Journal exists yet"?**

### Candidate shapes (for her to rule; none is built before she does)

1. **An explicit first-run moment.** Nothing is seeded until she answers *"Sign in"* or *"Start
   fresh."* Honest, conventional, and it makes the ordering impossible rather than unlikely. Cost: a
   first-run screen on a phone whose whole design avoids ceremony — and it puts a wall in front of the
   fastest capture path she has.
2. **Seed on first WRITE, not first launch.** The mark is consumed by intent, not by app start:
   nothing exists until she types. Sign in before typing and the real Journal simply arrives. No
   screen, no wait, and it deletes the 20-second bounded wait entirely. Cost: "empty app" on first
   open — which may read as broken without a little empty-state copy.
3. **An apply-time convergence repair — the SyncSpec §7 class.** Treat two designated Journal books as
   the duplicate-creation problem §7 already solves for `tag.path`: deterministic keeper (smaller
   `id`), re-point the loser's memberships, tombstone it. This is the only shape that fixes the case
   where the duplication *already happened* — including on devices already in the wild — and it needs
   no first-run UX at all. Cost: a real repair rule, and `reading` has no natural key today, so the
   "same book" predicate has to be defined (designation + profile is the candidate).
4. **Post-sign-in reconciliation.** Seed anyway; when a sign-in later brings a real Journal down,
   retire the starter. Cost: the starter may have been *written in* by then, so this needs merge
   semantics — the weakest option, and named here mainly so the round can say why it declined it.

**A recommendation to bring, not to assume: (2) + (3).** (2) removes the common case with less
machinery than the gate it replaces; (3) is the only one that heals devices where it has already
happened, and it is a shape this codebase already knows how to reason about. (1) stays the honest
fallback if she wants the moment to be explicit.

### Obligation

Her ruling recorded verbatim in `QUESTIONS` before any build; red-on-old pin for whichever shape;
`MobileSoul` row; and the mobile file's header claim about the virgin-store guard **corrected**, since
it is now known to be false.

---

## Act 1 — Cold review of 17g (the `13p-fix` session's work)

A fresh reviewer running `notes/REVIEW_PROMPT.md` **verbatim**, with zero implementation context, over
17g's diff. The isolation is the point: this round must not summarize 17g to its own reviewer.

17g fixed a defect she found **by testing the refreshed 13p install** — provenance that matters,
because it is exactly the class the sweep could not reach (the sweep read code; it ran nothing).

**Obligation:** every finding gets a written disposition in 17g's entry. Anything real and unfixed
lands in `KnownIssuesAndTechDebt.md` with an owner.

### Act 1 scope addendum — FOR THE ORCHESTRATOR, **not** to be passed to the reviewer

*(Added 2026-08-30 by the 13p-fix session at the author's instruction — her words: the next round
"will include a Fable cold review of all of the items from today as well, so ensure they've all been
clearly documented." This block is bookkeeping and SCOPE, deliberately not review foci: written after
the implementation, any description of the work would carry implementation context and break the
isolation this act depends on. Hand the reviewer the prompt and the repo, nothing from here.)*

**The review's scope is TODAY IN FULL, which is wider than 17g's own commits.** Two separate pieces of
work landed on 2026-08-30, and only the second is 17g:

| # | commit | what it is |
|---|---|---|
| 1 | `b4f453d` | the 13p signing gap closed (`keychain-access-groups`, device registration, the tightened ACL pin) |
| 2 | `8b017ec` | the post-signing full-suite record |
| 3 | `48d047d` | 17g's first commit *(⚠️ also swept in a concurrent session's `notes/ProactiveTechDebtReview-2026-08-30.md` — recorded at R1-12; history rewrites are author-only so it stands)* |
| 4 | `edcbc1c` | the canvas-flake KnownIssues row |
| 5 | `3779e77` | ladder round 1's fixes |
| 6 | `9b1669c` | ladder round 2's fixes |
| 7 | `64fe30b` | ladder round 3's fixes + the 17g entry |

Piece 1 is what MADE the 17g defect reachable, so a review that reads only 17g's diff sees a fix
without its cause. Both are documented — piece 1 in `notes/plans/phase-13p-note-protection.md`'s
POST-CLOSEOUT (with its own dated correction pointing at 17g), in `QUESTIONS #81(a)`, and in the
13p handoff's item 2.

**Where the documentation for all of it lives** (so the orchestrator can confirm completeness before
spending a reviewer on it): `notes/plans/phase-13p-fix-dp-keychain.md` (the FINDING with its
measurement, the fix design, the ledger, three full ladder rounds with per-finding dispositions),
the **17g** entry in this file's sibling `phase-17-standing-fixes.md`, `QUESTIONS #81(a)` and
**#82**, `MobileSoul` **PL-16**, and six `KnownIssuesAndTechDebt.md` rows (owners 17a ×2, 13x ×2,
13r, 12).

**Three things the orchestrator should carry into the round, because they are open by design:**

1. **A verification gap, if it is still open.** Round 3's changes had targeted suites green (30/2) but
   the full Mac suite run was interrupted twice; the last measured full run is **1853/314 at
   `9b1669c`**, which predates them. If the 13p-fix session's final run did not land, **run it first** —
   a review over an unverified tree wastes the reviewer.
2. **`QUESTIONS #82` is an author decision, not a defect** — the store key's protection class is inert
   on macOS, so it rides Migration Assistant to other hardware. A reviewer may re-find the mechanism;
   it is owned and escalated, not missed.
3. **17g broke its own environment trap and says so** (R3-1): a revert drill overwrote the author's
   live E2EE custody with test material. The remediation is hers (delete + re-enroll) and the rule is
   now in that plan's traps section. If a reviewer flags the incident, the correct disposition is
   "already recorded" — but a reviewer flagging that the *rule* is missing or weak is a real finding.
4. **(Added at the kickoff sitting.)** The review scope WIDENS twice: the mobile merge's Mac/`Shared`
   deltas (`fa522d6` + `43a35ef` — the R3-2 iOS-build fix among them) join the diff under review, and
   the failing `CustodyHandoverTests.theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable` is a
   known-red input for the FIX WAVE (trace why it reds on clean main yet passed at 17g's close —
   never merely re-green it). Both stay orchestrator-side; the reviewer gets the prompt and the repo.

## Act 2 — P39: refine the rule, then hand the code fix to 13u2

**The finding, corrected.** CLAUDE.md binds *"cross-feature interactions route through parent
composition, never feature-to-feature calls."* Measured 2026-08-30: **57 directed cross-feature edges
across 8 mutual pairs** (the finder claimed 20). Parent composition **is** honoured — `RootView` is the
only construction site — so only the "never feature-to-feature calls" half is violated. Of the 8 pairs,
**two are real defects** and six are a view rendering a sibling's view or a shared component homed in a
feature folder.

**The author's ruling (2026-08-30): a rule violated 57 times is usually a wrong rule.** This is
OverallModel §9's own doctrine — an operation tortured to express means the schema is wrong, not the
operation.

**What this act does:**

1. **Amend CLAUDE.md** so the prohibition binds **view models, business logic, and lifecycle
   ownership** — never a view rendering a sibling's view, and never a shared component in what is a
   single Swift module.
2. **Write the rationale into the amendment**, not just the rule. The reason is testability and
   isolation: a cross-feature *view-model* reference destroys them; a view reference does not. Without
   the stated reason, the next reader cannot tell a clarification from a relaxation.
3. **Add the positive placement clause** — where a shared view component actually lives. *This half is
   the one that is easy to skip and must not be:* without it, the amendment trades a violated rule for
   no rule, and the tail (`TakeEditCost`, `TagChips`, `MembershipChip`, `NoteDeleteConfirm`) keeps
   growing with nowhere to go.
4. **Hand the code fix forward: EDIT `notes/plans/phase-13u-feel-and-polish.md` to add P39's two real
   items to 13u2's roster** — (a) break the `Library` ↔ `Pool` view-model cycle (Pool stops holding
   `LibraryViewModel`; `duplicateAsVersion` and `archive` become closures passed by `RootView`), and
   (b) stop `Editor/WriteTakesPanel.swift:51` constructing `TakesViewModel`. **13u2 and not here**,
   deliberately: both touch `RootView` composition and `@State` lifecycle, 13u2 is already in those
   surfaces, and scoping them before the rule is refined would build against a rule about to change.

**The test of a good amendment, and it is falsifiable:** under the refined rule, **both real defects
must still be violations.** If either becomes legal, the amendment relaxed the rule instead of stating
it, and it is wrong. Check this explicitly and record the check.

**No code changes in this act.** It is a canon amendment plus a plan edit.

## Act 3 — The sample library: *The Adventures of Sherlock Holmes*

**Her ask, 2026-08-30:** the Sherlock Holmes adventures added to the store as a **book, each short
story its own note, each story a chapter** — so new users get *"a familiar lens through which to
explore the app, while also seeing how fast it is"* — and so she can measure **100k words in a book +
10k words in a note on her own device.**

### Her rulings (2026-08-30 — made after the first draft of this plan asked; they are settled)

**IT SHIPS IN EVERY READER'S STORE. Default-on, not opt-in.** The draft recommended opt-in and she
overruled it, with the reasoning recorded because it is the design argument, not just the verdict:

> *"it'll only be about 10 notes, fewer than the tutorial, and it can be tagged sherlock holmes. it's
> easy to delete if they want but it makes the power of the app clear in a way that the tutorial just
> doesn't — one is made to be digestible, the other is meant to show scale."*

**Two things follow from that, and they are the acceptance bar for this act.** The tutorial and the
sample library have **different jobs**: the tutorial teaches and is deliberately small; Sherlock exists
to make *scale* legible — a real book, real chapters, a 10k-word note that opens instantly. If the
seeded library does not feel fast, this act has failed at its actual purpose and that is a finding, not
a polish item.

**And her structural observation, which is a verification item:** *"the Pool is the library for items
not in a book — that'll be blank for new users."* Because every seeded story is a **member of the
book**, the Pool stays empty on a fresh store, which is the correct first impression. **Check this
explicitly** — a seeding bug that leaves stories bookless would fill a new user's Pool with twelve
strangers on first launch.

**The stories are TAGGED `sherlock holmes`** — her word — so the whole library is findable and
removable as a set.

**Gutenberg handling: standard practice, ratified.** Strip the PG header/footer and ship the
public-domain text with a plain source attribution. The stories are US public domain; the PG trademark
licence attaches to their edition, not to the work.

| # | Decision | State |
|---|---|---|
| A | Which text | *Adventures* (1892) — **12 stories, ~105k words**, which lands on both her targets at once. Her *"about 10 notes"* matches. Confirm real counts at ingest. |
| B | Gutenberg boilerplate | **RULED** — strip, attribute, ship |
| C | Default-on vs opt-in | **RULED — default-on, every reader's store** |
| D | Where it lives | Curated book in the default wing now; **record a line for 13i**: it should become its own wing, removable in one gesture |
| E | Bundle cost | ~600KB of text. **State the measured number at close.** |

### Build shape

Mirror `TutorialSeeder` exactly — the proven precedent (`enum TutorialSeeder` with `discover` /
`findOrSeed` / `restore` / `cleanup` / `seed`, driven from `ShellActions`). A `SampleLibrarySeeder`
beside it, same shape, same idempotence discipline.

Per story: `importPost(title:text:)` — which segments on entry by the global mode, so each paragraph
becomes a block — then `addPostToReading`, `createSection` (one chapter per story),
`assignPostToSection`, and `applyTag` for `sherlock holmes`.

### Traps — and default-on makes the first one serious

1. **FIRST-LAUNCH SEEDING COST IS NOW ON EVERY NEW USER'S CRITICAL PATH.** ~105k words segmenting into
   the low thousands of blocks, plus 12 posts, 12 sections, 12 memberships and 12 tag applications — a
   substantial write that did not exist when this was opt-in. **P2 binds: no DB I/O on the main
   thread**, and this app already has a KnownIssues row for windowless launches and launch-path
   robustness. **Seed off-main, after the window is up, never blocking first paint** — and measure
   first-launch wall time on a fresh store, before and after. A first launch that stalls is a worse
   first impression than no sample library at all, which would invert the entire point of the act.
2. **`importPost` registers a structural undo entry per call.** Twelve calls put twelve "Import"
   entries on the session stack, so a new user's first ⌥⌘Z does something surprising. Check what
   `TutorialSeeder` does and do the same.
3. **Idempotence.** Seeding twice must not mint a second book. `TutorialSeeder.discover` is the pattern.
   This matters more now: the seeder runs for everyone, on every fresh store, including hers.
4. **It is the first time `reading_section` carries a real book at scale** — 12 chapters with real
   memberships. Watch it and say what you saw.
5. **It syncs.** A signed-in new user pushes ~105k words of ciphertext on first sync. Not a blocker;
   worth one line in the closeout because it is now the baseline every account starts from, and **13y**
   is about to design per-account quotas against exactly that baseline.
6. **The phone is a first-class birthplace of stores** (13p, MobileSoul PL-15). A store created ON the
   phone must reach a deliberate answer — seed there too, or arrive by sync. **This is the act's mobile
   parity line**, and default-on is what makes it a real question rather than a footnote.

### What it is for, beyond the content

**This corpus is Act 4's instrument.** Seed it before running 17c so the read-layer measurements happen
against a real 105k-word book instead of a synthetic fixture. That is why Act 3 precedes Act 4.

Report, on her device: book open, scroll, and book-view assembly at 105k; note open and typing latency
in a ~10k-word story; first-launch wall time on a fresh store; and whether P1 holds — cost proportional
to viewport and edit, never to corpus.

## Act 4 — 17c: the read layer's P1 debt

Four findings (P18–P21) in `Sources/VariorumCore/Queries/`. Deliberately split from 13u1's O(N²)
family, which is editor-seam.

**P20 first — it is the sharpest and the cheapest.** The version-history classifier has no index, so
`deleteContainer` walks every post in the corpus **inside its own write transaction**, even for a note
with zero versions: a corpus-scaled hold on the write lock, not merely a slow read. **A local index is
free under SyncSpec §12** — the Postgres mirrors deliberately carry no indexes beyond the PK — so it is
not a lockstep event and needs no deploy window. It is still a schema change: **its own commit**, ahead
of anything using it.

Then P18 (`trayTakes` full-scanning `variant` inside a held observation), P19 (`versionOfNote` N+1 in
the Trash listing) and P21 (`activeFans` one query per block in a Swift loop).

**Measure on Act 3's corpus, before and after, and put real numbers in the closeout.** These four were
traced by reading, not benchmarked — the sweep ran no code. A finding whose pin passes on both sides is
dismissed as hollow and recorded, not fixed.

## Act 5 — 17f: dead code, canon corrections, and pins that cannot fail

Nine items (P42–P50). The cheapest act and the best ratio of effort to future time saved.

**The four test findings are the reason this act belongs in a verification round.** This project's whole
review doctrine rests on the red-on-old pin — so a pin that *cannot* fail is not a weak test, it is a
hole in the mechanism every future review depends on. **P48 is the sharpest:** five of six P1
benchmarks are gated by an absolute 2 ms floor rather than the flatness ratio their own names claim, so
they would not go red if P1 were violated — which is precisely what several sweep findings allege is
already happening, and what Act 4 is measuring.

P46 is a canon correction costing minutes: AppSpec §7's seed comment still says `idle_commit_hours = 24`
where the shipped seed is 2.

**Dead-code items (P43, P45) must be grep-verified before removal**, per the finding's own standard.

## Act 6 — The Fragments encryption outbound brief

Write the outbound brief for the Fragments agent as a dated carry item in
`notes/fragments-bridge-contract.md` — the standing channel, since the Fragments repo is hands-off by
rule and **this round never touches `~/dev/fragments`.**

Content: Fragments' own at-rest/local encryption story beyond the shared journal class, per the running
order's row 3 and 13p's outbound-brief deliverable. 13p already drafted material for her carry —
**read it before writing, and extend rather than duplicate.**

**She carries it. This round does not send anything.**

## Act 8 — THE DOUBLE TOUCH ID (author-reported 2026-08-30, in her own hands, minutes after the 13p-fix install)

> **⚠️ THE RULING MOVED (author, 2026-08-30, same evening).** She chose to
> start **13u** rather than run this round first, and asked that the two
> open settling questions ride 13u's design sitting: this act's doctrinal
> question and **QUESTIONS #82** are now agenda items **9 and 10** of
> `notes/plans/phase-13u-feel-and-polish.md`. **Nothing here is removed** —
> this act stays the traced record (the mechanism, the two mechanical
> shapes, the doctrinal argument), and 13u's agenda points AT it rather
> than restating it. If this round runs first anyway, it may still do the
> mechanical warming fix, which serves either ruling — but it does **not**
> decide the doctrinal question.
>
> **Her inclination, recorded and not yet a ruling:** keep the sync-keys
> gate meaningful under **Auto**, where it is the only gate; the live
> question is what it does under the demanded modes.


**Her report, verbatim:** *"it's driving me crazy that I unlock with the touchid, I get into an app
that still doesn't have sync unlocked & the bridge shows that it's failing, and I have to use touchid
AGAIN. how can we fix this issue? because it makes the app feel broken."*

**She is right, and it is not a polish item — the app asks twice BY CONSTRUCTION.** There are two
independently biometry-gated keychain items and each one evaluates its own `LAContext`:

| # | item | evaluated at | door |
|---|---|---|---|
| 1 | the STORE key (13p `StoreKeyGuard`, `.biometric` at-open mode) | `StoreKeyGuard.swift:87` | the lobby — `StoreLockView` → `lobby.unlockWithBiometrics()` |
| 2 | the E2EE device keys (14b CF-12) | `EncryptionKeychain.swift:425` | Settings ▸ Encryption — `EncryptionViews.swift:517`, a button she must find and press |

So the shipped flow is: Touch ID at the lobby → the app opens → **sync and the bridge are still
locked and SAY they are failing** → she has to go into Settings and press "Unlock with Touch ID"
again. Nothing is broken in the sense of wrong; it is two gates wearing one name, and the second one
is *manual*.

### The mechanical fix — one prompt, and it is small

`kSecUseAuthenticationContext` exists exactly for this: a successfully-evaluated `LAContext` satisfies
further keychain reads without re-prompting (`touchIDAuthenticationAllowableReuseDuration` widens the
window if the second read is later). Today each road builds its OWN context and evaluates, which is
why there are two prompts.

- **(A) WARM AT UNLOCK — recommended.** The lobby's successful unlock, while it still holds its
  evaluated context, ALSO reads the E2EE gated item under that same context and fills
  `E2EELaunchKeyCache`. One prompt; sync and the bridge are live the moment the app opens; nothing
  else changes. Fires only when the E2EE gate is ON. Needs a composition seam from the lobby to the
  E2EE custody — the plumbing is the work, not the logic.
- **(B) HAND THE CONTEXT FORWARD.** The lobby stores its evaluated context; `unlockGatedItem` reuses
  it instead of evaluating. Lazier (no keychain work if sync never runs) but the context has to still
  be valid at use, so it inherits a reuse-window question (A) does not have.

**Pin either shape by counting evaluations, not by watching prompts:** the existing seams already make
this testable — one launch under a demanded mode with the E2EE gate ON must evaluate biometrics
**exactly once**.

### The doctrinal question underneath — HERS, and it may delete the work

**R13p-16 says a gate inside an already-unlocked app is a curtain, not a boundary** — that is why
per-note locks were dropped, in her words: *"it makes users think privacy is in place that just
isn't."* The second Touch ID is arguably that exact shape. Once the store has been unlocked the
library is already readable; the CF-12 gate then protects only the ability to *sync*, on a machine
whose notes are already open. If R13p-16's reasoning binds here too, the honest answer is not "ask
once instead of twice" but:

- **(C) RETIRE the separate CF-12 biometric gate whenever the store's at-open mode is already
  demanding** (Biometric or Passphrase). The app has ONE gate — the at-open mode — and the E2EE keys
  ride the ordinary plain item behind it. The CF-12 toggle stays meaningful only under Auto, where it
  is the sole gate.

**This is an author call, not the round's.** (A) is the safe improvement that leaves the security
posture exactly as it is; (C) is the coherent one if her R13p-16 doctrine reaches this gate too, and
it also removes a toggle whose whole family caused the 13p-fix incident. **Ask her before building** —
and note that (A) is not wasted if she later rules (C): warming the cache at unlock is the same
plumbing either way.

### Obligation

Red-on-old pin (the evaluation count), the tutorial spine green, and the answer recorded in
`QUESTIONS`. If (C) is ruled, `MobileSoul` gains a row — the phone has the same two gates.

---

## Act 7 — Her carried items

> **FILL AT KICKOFF — she supplies these once the session is underway, not before.** Her words,
> 2026-08-30: *"I'll just tell the other session the other items once the session is underway - I have
> to have a bit of time with the app to find them and I can't do that right now while the test suites
> are running because they pop up very annoyingly on my computer screen."*
>
> **So this act starts empty by design, and the round must not treat that as nothing to do.** Two
> consequences for whoever runs it: **(a)** do not schedule this act first — she needs quiet hands-on
> time with the app to find the items, and a running suite steals her screen; **(b)** when the items
> arrive, record each here **in her words**, with a traced mechanism where she has one, and disposition
> each at close like everything else. **An item with no traced mechanism is not ready to be built** —
> it is a note, and it goes to `QUESTIONS.md` or to a later entry.
>
> *(Standing environment note worth carrying: test runs pop windows onto her screen. Prefer running
> suites when she is not trying to use the app, and say when you are about to.)*

**FILLED at the kickoff sitting — see KICKOFF item 6; all six routed to Act 10.** More may arrive;
record each here in her words as it does.

---

## Act 9 — The custody batch: 17a + the CF-12 and #82 builds (Fable implementer)

ONE Fable batch over the key-custody subsystem, composed of: **17a's eight items** (P1, P2, P3, P10,
P11, P12, P13, P15 — the register's entry is the brief; six of eight share the `try?`-swallows-typed-
errors root cause, P3 is the re-lock's missing `finalizeWork()`, P15 is the key-in-SQL-error channel),
**the CF-12 build per the sitting ruling** (Act 8 carries the mechanism and both mechanical shapes),
**the #82 build per the sitting ruling** (the TN3137 read→re-add-with-flag→delete-old migration, per
family, round-trip pinned — IF ruled), and **whatever custody-layer findings Act 1's review adds**.
Also from Act 1's fix scope: the failing `CustodyHandoverTests` red on clean main, traced then fixed.

Standing rules bind hard here: pin before fix; behavioral-revert verification; **never touch the
author's live keychain items or her real store** (the 17g R3-1 incident is the cautionary record —
its rule lives in `phase-13p-fix-dp-keychain.md`'s traps section and every custody brief carries it).

## Act 10 — The UI/UX pass: the tray, the Pool, and the protection surfaces (**Fable** implementer)

**Re-cast mid-sitting by the author (2026-08-30):** *"make Batch 10's UI/UX improvements a Fable
implementer actually. I want the taste to be better and there's some latitude in redesign to make the
user experience better (tags as a column or not, different way of organizing the pool and adding to
book button, etc.) … I want Fable taste + judgement on that phase because there's a variety of UI/UX
improvements needed."* **The latitude is real and granted:** within the two voices and the standing
copy rider, the implementer redesigns rather than merely tidies — screenshot pairs still ride
anything genuinely taste-forked, but the default is exercise the judgment, don't queue it.

Screenshot-verified against her screenshots. Her phrasing rider binds throughout: **she will rewrite
copy later — keep every capability and button present**; restructure and de-clutter, never delete
doors.

1. **This Note's Tray** — elements cut off (a section header visibly clipped under a divider in her
   screenshot), ordering/organization poor. Fix layout, spacing, section order; nothing clipped at
   any pane width. (P-8: chrome `fixedSize` texts always carry a `lineLimit` — the b6dae25 class is
   exactly this family; check it first.)
2. **The Pool page** — the far-right "Add to Book" dropdown retired in favor of a book picker WITH
   SEARCH; her floated tag-as-column explored as a screenshot pair for her ruling (*"maybe not"* is
   preserved uncertainty, not a decision); general de-dating (row grammar, spacing, affordances)
   within the two voices.
3. **The protection/settings surfaces** — the Encryption pane, the Account pane, the Opening Variorum
   pane: crowded → grouped and scannable, progressive disclosure where honest (the at-open explainer
   stack conveys several rulings' worth of consequence text in one undifferentiated column — group by
   the question each paragraph answers, collapse detail, lose nothing). **The eye/peek toggle lands
   on the passphrase set screen** — and on its SecureField siblings on the same surfaces for
   consistency (`SecretCheck`, the lobby's passphrase field), one shared control, not three ad-hoc
   ones.
4. **The trash/encryption/archived sweep** — a general pass over the 13j/13l/13p-era surfaces (Trash,
   Archived, the lobby, the reminder/nudge family) for the same crowding/jank class; anything
   taste-shaped beyond the granted latitude lands on a propose-only list for her.
5. **Tags move out of the navigation bar** (her mid-sitting item, verbatim): *"I also want the tags
   moved from where they are in the top bar to being under the scraps / outside reference / tray
   button - they look cluttered up there in the navigation bar and I think they'd look nicer on the
   far right, across from what books an item is in."* And the affordance label: *"maybe instead of
   just a + it should have like + tag or something so it's clear - not sure if that would be a lot of
   chrome clutter there that's not worth it"* — **her uncertainty preserved; the "+ tag" vs "+" call
   is explicitly delegated to Fable taste** at build time, judged in place. (History note for the
   implementer: the 13k compact context/nav bar ruled tag cards default-visible in the nav bar — this
   ruling SUPERSEDES that placement; record the supersession in the batch record.)
6. **The bottom bar spreads back out** (her screenshot: the two-row cramped state — "block 1/10 ·
   block ▾ · Takes · commit ⌘S · history / note ▾ · comments · Aa"): *"this bottom bar should be
   spread out again, unless the window is small and it needs to be collapsed."* One row at ordinary
   widths; the collapse is a width-responsive fallback, not the default.
7. **The lobby / first-unlock screen refresh** (her ask at the sitting, verbatim): *"this page looks
   ugly - the touchid thing opens up centered, covering up the middle of the screen, and there's a
   lot of stuff on that first unlock screen. I just think it needs to look a bit nicer - maybe throw
   one of the tesselating background art photos on there with a calm white box in the middle for it,
   aware that the prompt will appear. or do something else, idk exactly."* Design the lobby AROUND
   the fact that the system Touch ID dialog lands centered (compose the calm box off-center or
   size/place elements so the dialog doesn't occlude the essentials); reduce what's on screen at
   first unlock (progressive disclosure — passphrase field can arrive on demand under Biometric).
   Check `notes/brand/` for the tessellating background art she references; if the assets aren't
   in-repo, ask her to supply before styling around them.
8. **The standing mandate for the whole act** (her words): *"I just feel like the app feels a bit
   dated in the way that apple apps sometimes do - one line bars between items, etc. I want a bit of
   a refresh + fresh feeling added."* (Her second screenshot — the note ▾ menu's hairline dividers —
   is an instance of the grammar she means.) The latitude covers retiring the hairline-separator
   grammar where a calmer grouping serves better, within the two voices.

---

# Obligations at close

1. **Every item verdicted** — FIXED (naming its red-on-old pin), DISMISSED AS HOLLOW (the pin passed on
   both sides), or DEFERRED with a named owner. Silence on any item is an incomplete closeout.
2. **17c and 17f closed in `phase-17-standing-fixes.md`** with their dispositions, and this round
   cross-referenced from 17g's entry (see the file-ownership trap above).
3. **P39's amendment carries its rationale and its placement clause**, and the falsifiable check is
   recorded: both real defects still violate the refined rule.
4. **`phase-13u-feel-and-polish.md` updated** with P39's two code items on 13u2's roster.
5. **Act 3's measurements reported on her device**, not on a test fixture — 105k in a book, ~10k in a
   note, **first-launch wall time on a fresh store**, and P1 stated as held or not.
5b. **The Pool is verified BLANK on a fresh seeded store** (her structural check — every story is a
   book member), and the `sherlock holmes` tag selects the whole set.
6. **A line recorded for 13i**: the sample library should become its own wing.
7. **MOBILE PARITY LINE** — required by CLAUDE.md's closeout ritual, and **Act 3 makes it a real
   question**: the phone is a first-class birthplace of stores since 13p, so a store created there
   either seeds Sherlock or receives it by sync, and the round must say which. *"Nothing
   mobile-visible"* is not available as an answer for this round.
8. **Anything deferred lands in `KnownIssuesAndTechDebt.md` with an owner.** Never dropped back into
   the sweep artifact, which is a dated snapshot and not a tracking surface.
9. **`/Applications/Variorum.app` refreshed** if any Mac app code changed, per CLAUDE.md — and note
   that she does not quit the running app on request, so coordinate.
10. **The iOS target builds** at every batch close and at round end — the R3-2 lesson: the Mac suite
    alone is ZERO signal for `Shared/`.
11. **The three sitting rulings** (B1 · CF-12 · #82) recorded verbatim in the KICKOFF's RULINGS block
    and in `notes/QUESTIONS.md`, and built as ruled.
12. **17a closed in `phase-17-standing-fixes.md`** with per-item dispositions, alongside 17c and 17f.

# Verification at close

- Core, Mac, mobile and spine suites green, with counts stated against 13p's finals (core 1453/154 ·
  Mac 1843/312 · mobile 513/86 · spine 71/10). **The known intermittent latency pin reds under load —
  re-run isolated before concluding anything.**
- The tutorial spine green (the permanent acceptance script).
- Act 4's before/after numbers on Act 3's corpus.
- Zero `Sources/VariorumCore/Sync/` lines unless the Fable rider was honoured.
- Lockstep marker unchanged at 7 (Act 4's index is local-only; **13y owns the next event**).

# Where this round slots

**After `13p-fix`/17g, before 13u1** — her stated sequence, and the right one:

- Act 1 reviews 17g while that work is fresh.
- Act 2 must precede 13u2, which receives its output.
- Act 3 gives Act 4 a real corpus, and gives 13u1 a realistic tree to open the editor seam against.
- Act 5's honest P1 pins should exist **before** 13u1 changes P1-relevant code, not after.

Nothing here blocks on 13y, 13i, or the mobile project.
