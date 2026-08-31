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
   passing gave zero signal (the MobileSoul §3 class, live demonstration). *(REFINED later the same
   sitting at her pushback — "every batch seems kind of frequent to me when this is the first time
   it's broken. I'm open to other opinions" — architect's shape, standing unless she overrules: the
   iOS BUILD check (~2 min, no tests) runs at the close of any batch that touched `Shared/` or
   `Sources/` — a batch touching neither cannot break iOS and skips it; the full MOBILE SUITE runs
   once, at phase/round end. Rationale: the cheap check is what localizes blame to one batch instead
   of a phase's archaeology; the expensive check is the one worth rationing.)*
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
scheduled INSIDE Act 9 at a moment the custody batch calls for it. **At the checkpoint (late
evening): she closed the app — "i've closed my application, it's now refresh ready" — accepting the
tonight-after-green-suites order (install refresh from the verified tree, the ladder still reviewing
after with a re-refresh on any finding).**

**R-pre13u-6 — 17h OPENED (her word at the checkpoint): "Open 17h, run it this round."** The two
custody rows that carried owner "17a" outside its item list (R2-7 saveGated delete-before-add;
R3-5 delete-status-discarded + riders) become entry **17h** in `phase-17-standing-fixes.md` — a
small fresh Fable session, run in this round after Act 9 closes, while the subsystem is warm.

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

### ACT 1 RECORD — the Fable cold review's findings (returned 2026-08-30 late evening; recorded
### verbatim-faithful BEFORE any fix session; dispositions at right)

The reviewer confirmed no Review-foci section exists in either anchor; the known-red custody test was
independently found and traced. Findings:

| # | sev | finding (condensed — the reviewer's full trace is in the session record; mechanisms restated in the routing target) | routed to |
|---|---|---|---|
| F1 | MAJOR | `CustodyHandoverTests.theE2EESurfaceNamesTheSymptomWhenAWriteLandsUnreadable` (CustodyHandoverTests.swift:85) **depends on the author's live Keychain state**: `DeviceKeyStore.keychain(custody:)` fakes the TRANSITION only — its `load` is live (`E2EELaunchKeyCache.shared.value` → real `E2EEKeychainStorage.gatedItemExists()`/`load()`), and `setBiometricRequirement` short-circuits at `guard let material = store.load() else { return .noMaterial }` (EncryptionSession.swift:436), so the fake seam is never consulted on any machine without a readable plain `e2ee-keys` item. **Its green at 17g's close was borrowed from the R3-1 drill's litter** (a readable plain sentinel); the author's owed cleanup is what turned it red. Reviewer demonstrated the red live. Production behavior is correct; the defect is pure test isolation, and it breaks the phase's own keychain-test trap in the READ direction. Fix: fully faked store — memberwise `DeviceKeyStore` with `load: { material() }` (or extend the seam to carry `load`) so the pin never consults the live Keychain. | **Act 9** |
| F2 | MAJOR | **MobileSoul PL-16 carries a falsified verification claim**: *"Verified at the ladder, not assumed: `xcodebuild build -scheme VariorumMobile` succeeded…"* — impossible for the tree it describes (PL-16 shipped in `64fe30b`, the same commit whose R3-2 change broke the iOS build entirely; proven by `43a35ef`'s clean-worktree check). Fix: dated in-place correction on PL-16. | **architect, this turn** — DONE below |
| F3 | MINOR | The closed 17g entry contradicts itself about the install: "Owed to the author" item 4 still says the fixed build is NOT in `/Applications`, while the CLOSE record says it was refreshed, hash-matched. Fix: mark item 4 DONE with the CLOSE's evidence. | **architect, this turn** — DONE below |
| F4 | MINOR | **The only guard between test code and the author's live E2EE custody is a plan-file sentence — and it already failed once** (the R3-1 incident's class is structural, the remedy procedural). Fix sketch: a DEBUG-only test-process tripwire on `E2EEKeychainStorage`'s fixed-account write/delete leaves (fact-suite exempt via its throwaway-service path); pinnable (a test asserting the tripwire fires from a test process fails on pre-fix code). | **Act 9** (the reviewer's own owner call) |
| F5 | NIT | `Phase13pKeychainFactTests.swift:5–16` header still describes the pre-signing world in the present tense. | **Act 9** (same files) |
| F6 | NIT | `StoreProtection.swift:225–228` — `wroteButUnreadable` is spoken by BOTH surfaces but answers only the store-key one ("still open your library" is non-responsive when the E2EE **sync** toggle fails; that road back is passphrase re-enrollment of sync custody). | **Act 9** — the CF-12 rework rebuilds this exact surface; give the E2EE arm its own responsive sentence (functional copy; her voice pass re-words later) |
| F7 | NIT | `TrayPanel.swift` (merge delta) ends without a trailing newline. | **architect, this turn** — DONE below |

**Clean bill highlights (the load-bearing ones):** site enumeration independently re-verified (the
partition flag has exactly one production definition; the plain families verifiably don't carry it —
no stranding); `CustodyHandover.perform` semantics verified by reading AND by running its pins (31/32
green; the one red is F1, not production); the count arithmetic re-derived from the diffs and exact;
zero `Sync/` lines / zero schema / marker 7 across all eight commits; the merge pair's Mac/`Shared`
deltas are disciplined hoists with the forked-brains row updated accurately; every ladder disposition
promising an owner has its row; `43a35ef`'s fix minimal and correct; the entitlements mechanism right
with the tightened pin a genuine regression guard.

**Adjudication (architect):** all seven accepted; no disputes. F1's disposition SATISFIES the
kickoff's demand (trace why red on clean main yet green at close — answered: the drill's litter was
the green's precondition). F2 is the process finding with teeth: a "verified, not assumed" sentence
in a ledger a future session trusts was false — the correction lands now, and the standing iOS-build
gate (KICKOFF item 3) is the structural answer.

---

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

**ACT 2 EXECUTED (2026-08-30, architect — the author asked for and received the architect's second
opinion at the sitting before this landed; her Opus implementer proposed the refinement, the
architect concurred with two sharpenings).** The CLAUDE.md bullet now: binds construction / held
references / business-logic calls / lifecycle ownership; legalizes rendering; carries the rationale
in-text (the clarification-vs-relaxation tell); and the placement clause is NORMATIVE with named
homes (`Core/Views` for Mac chrome, `Shared/` for cross-platform) and the hoist-at-next-touch rule —
the two sharpenings: (1) placement normative-with-a-home rather than advisory, (2) the boundary
stated as construction-and-ownership so a view cannot smuggle coupling by taking a sibling VM it
minted itself. **The falsifiable check, run and recorded: the `Library`↔`Pool` cycle still violates
("never holds"), and `WriteTakesPanel` constructing `TakesViewModel` still violates ("never
constructs") — the amendment clarifies, it does not relax.** `phase-13u-feel-and-polish.md` gained
the P39a/P39b addendum on 13u2's roster. AppSpec §2's one-line mirror of the old wording is left
untouched deliberately: it remains true read at the ownership level, and CLAUDE.md's refined bullet
is the precise, governing form (recorded here so nobody reads the difference as drift).

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

**Arrived later the same sitting (2026-08-30, her words), routed:**

- *"when i have 10 'tabs' open, i can see that there's more open underneath but i can't click on the
  'one more note open' to see what it is or move it up. not sure what what point the tabs should
  auto cycle or if you have any ideas on that, because I do think it gets to a point where it would
  just get messy, but just seeing '2 more open' and it's the 2 i most recently opened is a bittt
  annoying. i'm open to ideas"* → **Act 10 item 9.**
- *"i also am open to the idea that what is the pool (note not in a book) should just be a filter on
  the library - i'm inclined towards liking the pool staying its own tab, but i do wonder if i
  should have the library gaining more filters on my radar"* → **the 13i brief** (agenda line added
  there — the Library-filter vocabulary belongs beside smart books/wings/starred, one design space,
  never two mechanisms for one idea). Her inclination recorded: Pool stays its own tab; this round
  changes nothing about the IA.
- *"it's jarring when you go from being in a note to the library and the 'This note' section of the
  UI just disappears - it feels a bit jumpy. not sure if we just neeed to smooth that animation or
  what"* → **Act 10 item 10.**

**And later still (same sitting, her words), routed:**

- *"checking one of the markdown boxes right now moves you to the absolute bottom of the note for an
  unknown reason. that's also quite annoying"* → **Act 10 item 11** (trace-first — the mechanism is
  unknown by her own words and must be traced, never guessed).
- *"this is a really micro note, but when someone types an arrow like this -> i want it to fill in
  with the arrow symbol: →. same for the left arrow. i can't think of a simple up and down arrow
  option but i'd like them too, but definitely the autochange from this <- and this ->"* →
  **Act 10 item 12** (left/right ruled; up/down wanted, typed form open).
- *"i think that N more open should cap with total tabs at 20 - otherwise it's just going to be a
  bit of a mess"* → **RULED into Act 10 item 9** (the cap).
- *"i agree with the fact that regions shouldn't teleport - i like the idea of it being an 'extra
  information' pane for items in the library that you've clicked on once though, I could see that
  being super useful actually. book information or note information, that kind of thing. i really
  like that and i want to see it built at the very least - context aware panel depending on the
  item"* → **RULED into Act 10 item 10** (the panel is IN, not a screenshot-pair question).

**Third wave (same sitting, her words), routed — and her scope authorization recorded verbatim:
*"I know that Act 10 has a number of items in it already… It's ok if Act 10 is more significantly
sized - it seems like we're moving through items well, and this just needs to be fixed."***

- *"what do you mean pin? I don't see such a thing as a pinned tab, only the option to star"* —
  **she is right; the architect imported a browser concept that doesn't exist here.** Tabs have no
  pin; star is a different surface (the sidebar Starred section) and book-pinning lives on the
  shelf. Item 9's cap wording CORRECTED: the 21st open closes the least-recently-used open, full
  stop.
- The Starred sidebar row (her screenshot): *"there should only be a star on one side though - i
  like the blue star, the right side is probably better for it. also, it has to handle super long
  titles and should do a stereo style scroll when hovered over, the rest of the time showing that
  it's been cut off when the items are too long. there's also not enough padding above it"* →
  **Act 10 item 13.**
- The library row's click model — *"clicking on a library item not on the text of the item merely
  highlights the row in blue, and doesn't do anything, even double clicking. clicking on the text of
  the name results in instantly going inside. so i think that should be addressed / could be the
  answer: a click on the whole body highlights it in blue and shows you data maybe (if it's locked,
  associated tag, that kind of thing…) and a click on the text could still instantly open it. a
  double click on the blue should lead to going into it though, it's just weird that it doesn't"* →
  **RULED into Act 10 item 10 — this ANSWERS the interaction fork** (no ratified gesture changes:
  text-click still opens; the dead body-click becomes select-for-info; double-click opens).
- *"please look at how unhelpful this 'mark as versions with' element is. this is a disaster - it's
  not useful at all tbh"* (her screenshot: a flat submenu enumerating the whole corpus) → **Act 10
  item 14** (the ONE searchable note-picker component).
- *"things are equally unhelpful in the compare tab - this is a mess UX / UI wise and should be
  cleaned up as well… the compare flow is so confusing right now, + make outline note + note is
  confusing, how you select things is confusing, the whole thing is a bit of a mess"* → **Act 10
  item 15.**
- The Blocks page: *"feels half baked and semi useless right now, i don't even know what to say
  specifically for feedback on it other than it's hard to imagine exactly why someone would use it.
  maybe it should look more like the 'book' page, but for within this note? like have that index
  like outline view? or let you read just the note with reading tools and the title of it should be
  renamed from blocks? … I'm not even sure how to fix it"* → **Act 10 item 16 (proposal-first).**
- Snippets: *"there's also no door to making a new pool and it's confusing what the pool even means /
  how it got there / what the whole concept is. that might be a bigger change that shouldn't be done
  in Act 10, but a BIT of a refresh, a search, more of a library esque view, idk, something could
  maybe be added because what even is this page? feels compeltely half baked"* → **Act 10 item 17
  (the bounded refresh; the concept question flagged, not solved).**

---

## Act 9 — The custody batch: 17a + the CF-12/#82 builds + the routed review findings (Fable implementer)

**THE BATCH BRIEF (self-contained; the implementer reads THIS section + the named sources, nothing
briefed from any session's context).** ONE Fable batch over the key-custody subsystem. Work in this
order, committing per numbered group:

1. **F1 — the state-dependent custody pin, first** (it reds every suite run until fixed): the full
   trace is the ACT 1 RECORD table above. Fix per the reviewer's sketch: the pin gets a fully faked
   store — memberwise `DeviceKeyStore` with `load: { material() }` (or extend the
   `keychain(custody:)` seam to carry `load`) — so it never consults the live Keychain. Verify it
   passes regardless of machine keychain state; note the OLD form's red-on-clean-main is the
   behavioral evidence (already demonstrated by the reviewer — do not re-litter the keychain to
   re-prove it). Sweep the suite for siblings with the same live-`load` dependency while there
   (the R3-NIT `E2EELaunchKeyCache` save/restore rider from KnownIssues' 17a row rides here too).
2. **17a's eight items** (P1, P2, P3, P10, P11, P12, P13, P15) — the entry in
   `notes/plans/phase-17-standing-fixes.md` is the per-item brief (finder claim + verifier trace);
   six of eight share the `try?`-swallows-typed-errors root cause, P3 is the re-lock's missing
   `finalizeWork()`, P15 is the key-in-SQL-error channel. Pin before fix, per item; a pin green on
   both sides dismisses the item as hollow, recorded not fixed.
3. **F4 — the test-process tripwire**: DEBUG-only guard on `E2EEKeychainStorage`'s fixed-account
   write/delete leaves (test process detected → refuse/trap), fact-suite exempt via its
   throwaway-service path; pinned (the tripwire fires from a test process; red on pre-fix code).
4. **The CF-12 rework per R-pre13u-2** (the RULINGS block above; Act 8 carries the mechanism): the
   sync-keys gate becomes an opt-in setting, DEFAULT OFF for everyone; OFF ⇒ the E2EE keys ride the
   plain custody item behind the app's own at-open gate (transition via `CustodyHandover` discipline
   both directions); ON ⇒ the separate unlock honored regardless of at-open mode. Existing stored
   values RESET to the new default (the semantics changed; her confirm covers this — her device ends
   with one prompt). The surfaces live in `Shared/` (`EncryptionViews`), so both platforms inherit;
   pin the one-prompt outcome by counting biometric evaluations (one launch under Biometric mode
   with the setting OFF evaluates exactly once). **F6 rides here**: give `wroteButUnreadable`'s E2EE
   arm its own responsive sentence (that surface's road back is passphrase re-enrollment of sync
   custody, not "open your library"); functional copy, her voice pass re-words later.
5. **The #82 build per R-pre13u-3**: TN3137 migration (read without the flag → re-add with
   `kSecUseDataProtectionKeychain` → delete old) for the STORE-KEY family only, round-trip pinned;
   E2EE custody untouched. The migration must be idempotent and crash-tolerant (a half-migrated
   state re-heals on next launch), and `CustodyHandover`'s write-verify-then-delete IS the
   transition discipline. Update the two corrected production comments' successors if wording now
   changes again.
6. **The nudge tier-detection half of R-pre13u-4** (detection here; faces are Act 10's): ONE shared
   brain answering "which legs exist" — passphrase wrap · recovery wrap · escrow VERIFIED-LANDED
   (not assumed: the reconcile confirms its own item reads back) · biometric/gated custody — and the
   derived tier (covered / exposed). Device-neutral language hooks ("this device"). **The escrow
   verification observable serves double duty:** it is BOTH the nudge's escrow leg AND the
   author-run check (R-pre13u-5) — surface the verified/not-landing fact where the Encryption pane
   can render it (Act 10 styles it). When the probe is ready, STOP and report the exact steps for
   her escrow check (she is around and has agreed to run it this batch); the architect relays.
7. **F5** — the `Phase13pKeychainFactTests.swift:5–16` header rewrite (post-signing world).

**Sources to read first, in order:** this file's KICKOFF + RULINGS + ACT 1 RECORD + Act 8;
`notes/plans/phase-17-standing-fixes.md` (the 17a entry + standing rules); the environment-traps
section of `notes/plans/phase-13p-fix-dp-keychain.md` (BINDING — especially the R3-1 rule);
`CLAUDE.md`. The 14b/13p custody architecture reads from
`App/Variorum/Shared/{EncryptionKeychain,EncryptionSession,ProtectionController,StoreProtection}.swift`
and `Sources/VariorumCore/Persistence/{StoreKey,StoreKeyEnvelope}.swift`.

**Hard rules:** pin before fix with behavioral-revert verification; **never touch the author's live
keychain items, her iCloud Keychain, or her real store** (the 17g R3-1 incident is the cautionary
record; F3's tripwire exists because the rule alone failed once — build it early and let it protect
the rest of the batch); zero `Sources/VariorumCore/Sync/` lines (nothing here needs them — any
exception stops and reports); no schema; no product invention (unresolved behavior → QUESTIONS.md).

**Verification at batch close:** targeted custody suites green + the FULL Mac suite green (state
counts vs 1854/314), **the iOS target BUILDS** (the standing gate — `xcodebuild build -scheme
VariorumMobile`), mobile suite green (582/93 baseline), tutorial spine green, the two known
load-flaky suites re-run isolated before concluding anything from a red. Record per-item
dispositions in the 17a entry (it closes) + a batch record in this file.

### ACT 9 BATCH RECORD (2026-08-30, the Fable custody batch — implementer session; commits `270bf4f…d6a4911` + the records commit)

**All seven work-order groups executed in order, one-to-a-few coherent commits each; every
bug-class fix landed with a red-on-old pin verified by a faithful behavioral revert** (never a
seam removal — the R3-1 trap honored; the drill reds reproduced the traced end states verbatim:
P2's both-Keychain-items-deleted library, P3's tail-in-no-row loss, P13's untyped-error +
minted-custody dead end, P15's full 64-hex key in both error channels, R-pre13u-2's two-prompt
world). **17a is CLOSED** — per-item dispositions in `phase-17-standing-fixes.md`'s entry.

| group | what landed | commit |
|---|---|---|
| 1 | **F1** — the state-dependent custody pin fully faked (red observed live on the pre-fix tree, 22:01); the R3-NIT `E2EELaunchKeyCache` save/restore rider (cache made internal); sibling sweep: `CustodyHandoverTests` is the ONLY suite driving `.keychain(` — no other live-`load` dependency | `270bf4f` |
| 2 | **17a's eight items**, four commits: P1/P2/P10/P11 (the envelope-write family — the tri-state `readEnvelope` seam, throwing `ensuredEnvelope`, fresh-read `setMode` authorization, derive-then-read `setPassphrase`, the lobby's one `deadEndMessage` brain) · P3 (`macWillLock`, the `mobileWillLock` twin) · P12/P13 (present-but-unreadable ⇒ `.encryptedOrUnknown`, typed refusal, no mint, no persisted downgrade) · P15 (key-hex scrubbed from both error channels at origin) | `30fd249` `8aef252` `54d28ea` `b9c90f6` |
| 3 | **F4** — `KeychainTestTripwire` (KeychainCustody.swift's third named rule): every fixed-account E2EE write/delete leaf refuses from a test process before any SecItem call; red-on-old via the SAFE drill (detection off + service redirected to a throwaway REVERTDRILL service in ONE edit; litter swept; the real-constants revert — the R3-1 act — never performed) | `ffa0a83` |
| 4 | **R-pre13u-2 + F6** — the sync gate opt-in, DEFAULT OFF; `SyncGateOptIn` marker (production `.live` at AppServices; ephemeral default fences tests off the machine's defaults); LEGACY gates reset to plain at the first material-in-hand moment through the `CustodyHandover`-disciplined transition (her device ends at ONE prompt; one click re-enables); the E2EE arm's own `wroteButUnreadable` sentence | `a21bd63` |
| 5 | **#82 (R-pre13u-3)** — the store key device-bound: DP flag + TN3137 migration (idempotent, crash-healing, open-never-hinges-on-it); `delete` takes both keychains; the two production comments' successors updated both sides | `bbf5cf2` |
| 6 | **R-pre13u-4/5 detection** — `ProtectionLegs` (the ONE nudge brain, tier covered/exposed/unknown, device-neutral exposed copy + the ways-back-in line) · the VERIFIED-LANDED escrow observable (`escrowVerifiedLanded` + `EscrowReconcileOutcome`'s read-back leg) · the Console evidence line for her check | `7b16ad6` |
| 7 | **F5** — the fact suite's header leaves the pre-signing world | `d6a4911` |

**MEASURED PLATFORM FACTS (new, absorbed into the design and pinned):**
1. **A PLAIN (no-ACL) data-protection item under a shared service/account IS matched by a no-flag
   `SecItemDelete`** — unlike the ACL'd items 13p-fix measured (whose ACL is evidently what hides
   them from legacy searches). Found when the #82 legacy sweep destroyed the bound item it had just
   verified; the design answer is a distinct `<scope>-bound` account (the gated family's
   account-carries-the-policy pattern), making the two families structurally unable to touch each
   other whatever a point release decides about cross-visibility.
2. **`FileHandle.read(upToCount:)` returns nil WITHOUT throwing at EOF** — so the P12/P13 classifier
   distinguishes nil-at-EOF (empty file, the deliberate `.absent` half, now pinned) from a THROWING
   read (unreadable ⇒ `.encryptedOrUnknown`).
3. **Live end-to-end evidence for #82:** the hosted test runs migrated the DEV store's real key
   mid-batch and the host kept opening through the bound item on every later suite boot.

**RECORDED CORNERS (deliberately unchanged, each doc'd at its site):**
`failedOutcome` stays doorless over an unreadable sidecar (widening that surface is design);
`verifyPassphraseAgainstStore` answers nil on unreadable (a third guard answer is design; harmless —
every write door refuses regardless); `macWillLock` finalizes only the ACTIVE editor, identically to
the quit door it mirrors (widening both is one design act); the nil-URL route fallback fix rides
P13 unpinned (no seam over the private URL resolution); P15's PRAGMA site is pinned pure only (that
statement's failure is not drivable — SQLCipher defers key validation to the first page read);
group 6's observable is a ruled feature, carried by traced mechanism + the refused/off/unknown arms
rather than a bug-class red-on-old. **#82's build-config note:** the bound item belongs to the
access group that migrated it, so the rare debug-build real-store opt-in road now lands on the
sidecar recovery surface instead of opening silently (recorded in the family header + the
KnownIssues residual row).

**MOBILE (for the round's parity line):** groups 4 and 6 are `Shared/` brains — the phone INHERITS
the opt-in/reset semantics and the `ProtectionLegs` tier by construction (R-pre13u-4's "both
platforms invoke the same nudge brain", satisfied at the seam); the phone's FACES for the exposed
tier and the pane line are the parity line's to name (Act 10 styles the Mac's). iOS target built
green at every `Shared/`-touching commit and at close.

**THE TWO RE-ROUTED KNOWNISSUES ROWS** (R2-7 `saveGated` delete-before-add; R3-5
delete-status-discarded): never in 17a's 8-item list — **re-routed to 17h**, opened at the author's
word; their rows now name 17h. Not resolved, not orphaned. (R3-5's R3-NIT rider WAS discharged here,
group 1.)

**ESCROW RESULT — PENDING (architect fills after her run).** The check needs the refreshed
real-store build (the reconcile's escrow arm is real-variant-only by 13p design), so it runs after
this batch's green suites and the `/Applications` refresh: launch → unlock → confirm the escrow
dial ON → quit → relaunch → read `log show --last 10m --predicate 'subsystem ==
"io.lduarte.Variorum" AND category == "protection"'`. **PASS** = the relaunch line reads
`item read back == current key: Optional(true) · wrote this pass: false` (the reconcile reads its
own item back rather than re-writing). **FAIL** = `read back … Optional(false)`, or `wrote this
pass: true` on every relaunch. Her result: **PASS on the first-launch evidence (2026-08-31
00:56:57, read by the architect from the unified log — the `.info` flag and `/usr/bin/log` are both
required; zsh shadows `log` with a builtin):**
`escrow reconcile: dial ON · item read back == current key: Optional(true) · wrote this pass: false`
— the reconcile found the iCloud item, read it back through the production path, it MATCHES the
current key, and nothing needed re-writing. The silent-failure mode (believing a copy exists when it
doesn't) is excluded on evidence; the item had landed in an earlier post-signing launch and
verifiably round-trips. **The KnownIssues escrow row retires.** *(One residual for the successor: her
confirming RELAUNCH — after the one-time sync-gate unlock — should show the same line again; and if
she reports a SECOND biometric prompt on any launch AFTER that one-time unlock, that is a finding
against the R-pre13u-2 reset, back to the custody batch.)* **RESIDUAL CLOSED (2026-08-31, ~01:55,
her word to the successor): "i've done the sync unlock and it was successful - the confirming line
was positive."** The R-pre13u-2 reset's material-in-hand moment completed on her device; the
one-prompt world is live end to end. The tripwire survives as a watch, not a task: a SECOND
biometric prompt on any FUTURE launch is a finding against the reset, back to the custody
subsystem.

**VERIFICATION AT CLOSE:** core **1457/154 GREEN** (13p baseline 1453/154 + the 4 new core pins,
exact) · Mac full suite **1871/317 ALL PASSED** (baseline 1854/314 + 17 new pins across 3 new
suites — count arithmetic exact; a first full run under load reddened the KNOWN load-flaky canvas
suite — green 6/6 isolated per the standing rule, the KnownIssues row's verdict confirmed — and
caught two honest `KeychainOffMainTests` call-sequence pins meeting the batch's DELIBERATE
sequence changes, both justified-edited with comments naming the ruling: adopt's reset consult
before the save, R-pre13u-2; the escrow arm's verification read-back, R-pre13u-4; the clean full
re-run followed) · **iOS target BUILDS** (the standing gate, green at every `Shared/`-touching
commit and at close) · mobile **582/93 PASSED, 2 standing known issues** (the exact 13p baseline)
· tutorial spine GREEN (all 10 tutorial suites in the full run) · zero
`Sources/VariorumCore/Sync/` lines, zero schema, marker untouched (diff-verified: no file under
`Sync/` in any commit). **Environment:** the real-store app was RUNNING at batch start (contrary
to the brief's "closed tonight") — instance-check discipline held throughout (no Release builds,
no `/Applications` refresh, never touched); it closed mid-batch. The revert drills' keychain
traffic touched ONLY throwaway drill items (the F4 drill's own unguarded `clear()` swept its
litter; `security`-CLI not-founds corroborated).

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

   **THE CLARITY TABLE IS THE CENTERPIECE (her sixth-wave escalation, 2026-08-31, verbatim: "I need
   a way clearer chart and table of what settings you can have / what passphrase or autominted key
   or icloud key or whatever / what you need to log in / where. I'm still confused which, again,
   it's normally a bad sign when I'm confused because it will mean my users will be hopeless
   confused + scared of the worst possible thing, which is losing all of their work… settings has
   like 5 paragraphs around encryption it's also very confusing").** The deliverable, replacing the
   paragraph stacks: **(a)** a LIVE "ways back in" checklist as the protection pane's centerpiece —
   the actual legs THIS device/account has right now (Act 9's `ProtectionLegs` brain feeds it:
   this-device unlock · passphrase · recovery phrase · iCloud Keychain copy), present/absent, with
   one situation table behind a ? for depth — **situation → what opens the library** (this device
   by mode · a new device with your iCloud · a new device without it · a restored backup on other
   hardware · every-leg-lost = gone, the honest floor); **(b)** the same table, prose-lite and
   device-neutral, aligned into the TUTORIAL's privacy chapter (13p's per-mode loss-math instruction
   made scannable) — the field-guide re-seed obligation rides the closeout per the standing rule;
   **(c)** the five encryption paragraphs collapse into the structure — a sentence survives only
   where truly necessary (her amended doctrine). The architect's sitting reply of 2026-08-31
   carries the reference version of the table — the batch renders it, not re-derives it.

   **Seventh-wave sharpenings (2026-08-31, from her follow-up questions — these are PART OF the
   table's spec):** **(i)** the table distinguishes the TWO new-device rows, which are different
   mechanisms: *adopting a copy of the library* (AirDrop/13x/restored folder — the iCloud escrow
   copy opens it, no Variorum secret) vs *a new empty device pulling your content via SYNC* — that
   one takes the encryption passphrase ONCE (E2EE enrollment; the iCloud copy deliberately does
   NOT substitute — the server must never be able to hand keys around). SAME passphrase, never a
   separate code (the one-secret doctrine); #82 bound only the store key's local item, E2EE custody
   unchanged by design. **(ii)** the demanded-modes row states the fallback truthfully: at THIS
   device's lobby under Touch ID/Face ID, the fallbacks are the passphrase and recovery phrase —
   the app NEVER silently opens via the iCloud copy on a device whose mode demands biometry (that
   would be the theater R13p-16 killed); the escrow dial's already-worded caveat (a person using
   your unlocked Mac could dig the copy out of iCloud Keychain; Locked-down turns it off for
   exactly that reason) stays the honest disclosure. **(iii — her ask, verbatim: "maybe the
   encryptions settings in settings should have an encryption explainer tab - i guess i could also
   have it in the field guide and it makes sense there, but settings should also carry a better
   explanation and point someone towards the tutorial"):** the settings surface gains an EXPLAINER
   section/tab — the rendered table + a door to the field guide's privacy chapter — so settings
   explains AND points, and the deep teaching lives in the tutorial. **(iv)** E2EE custody internals
   never surface to users (her read, confirmed: "the E2EE is just about what i need to understand,
   not my users") — user-facing copy speaks of ONE passphrase and what it opens, never of key
   families.
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
   grammar where a calmer grouping serves better, within the two voices. **Eighth wave: the mandate
   now has a CONCRETE reference — the mockup file's grammar is the style guide (W8-2: spacing,
   squarish-rounded controls, calm cards, "doesn't have to be an exact 1 for 1"), and the sidebar's
   liquid-glass floating pane retires for solid geometric lines (W8-3). Act 10 restyles what it
   touches; 13u2 carries the app-wide continuation.**
9. **The open-notes tabs overflow** (her report is in Act 7's arrivals, verbatim). The mechanical
   half is not a taste call: **a newly opened note never lands in the hidden overflow** (the
   newcomer takes a visible slot; the least-recently-used visible note is what drops), and any
   "N more open" affordance is a REAL DOOR (click → list → focus). The shape recommendation, hers to
   see in screenshots: the Open section follows the starred-items precedent (13u item 10's ruled
   shape) — visible up to ~7, then the section itself scrolls, no dead label; ⌘⇧1…9 stay bound to
   the visible order. **AUTO-CLOSE RULED (her word, same sitting): total open tabs cap at 20** —
   opening the 21st quietly closes the least-recently-used open (a tab is a pointer; nothing is
   lost — the note stays in the library). *(Wording corrected at her question — there is no
   pinned-tab concept in this app and none is being invented; star is a different surface.)*
10. **The note → library transition + THE CONTEXT-AWARE RIGHT PANEL (ruled in — AND the interaction
    fork is RULED, by her, on the app's own existing behavior):** the "This note" right region never
    teleports — the transition animates, column width in sync — AND the library's right region gains
    an **"extra information" panel, context-aware by item kind**. **The click model, hers verbatim
    at the sitting (it resolves the fork with ZERO change to #79's ratified gestures):** a click on
    the **row body** (today a dead highlight) selects and shows the info panel; a click on the
    **title text** still opens instantly, as today; a **double-click anywhere on the row** opens
    (today it weirdly doesn't). Panel content latitude is the implementer's — her direction: what
    makes a library mini-view useful — *"if it's locked, associated tag… # of words? notes? last
    edited? the type of thing people want in a library"* — per kind (note vs book). Principle for
    the whole act: regions visibly become things or visibly leave. Design together with item 5 (the
    tags move) — one coherent right edge, not two patches.
11. **Checking a markdown checkbox jumps to the absolute bottom of the note** (her report in Act 7's
    arrivals; the mechanism is UNKNOWN — trace first, never guess). Candidate family for the tracer:
    the toggle's storage rewrite resetting scroll/caret (the TK2 geometry class, TEXTKIT2 §2), but
    the trace decides. Red-on-old pin: scroll position (and caret) preserved across a checkbox
    toggle.
12. **Typed-arrow substitution:** `->` becomes → and `<-` becomes ← as you type (ruled). Constraints:
    a pure type-time text transform — content-level, both stored and rendered (markdown-as-content
    untouched as a doctrine); NEVER inside code spans/blocks (arrows are syntax there); ordinary text
    undo reverts it (the smart-quotes convention). ONE brain, built to be shareable with the phone.
    If the implementer finds it entangled with `MarkdownActs`' arming flow, it DEFERS to 13u1 rather
    than complicating a seam about to be rewritten — record the deferral. Up/down arrows: wanted,
    typed form undecided (*"i can't think of a simple up and down arrow option but i'd like them
    too"*) — the batch may PROPOSE candidates (e.g. `-^` / `-v`) as a note for her; nothing built
    without her nod.
13. **The Starred sidebar row** (her screenshot shows TWO stars, one each side): exactly ONE star —
    the blue one, on the RIGHT ("probably better", her lean — the batch may confirm in place); long
    titles truncate with a visible ellipsis at rest and **marquee-scroll on hover** ("stereo style",
    her word); more padding above the Starred section. P-8 binds (`lineLimit` on chrome text).
14. **ONE searchable note-picker component** — built once, used everywhere a note is chosen from the
    corpus: the "Mark as Versions with" submenu (her screenshot: a flat menu enumerating every note —
    "a disaster"), item 2's Add-to-Book door, and Compare's "Choose a note…". Shape: search-as-you-
    type, contextually ranked (version peers first where versions are the subject; recent first
    otherwise), snippet/date context per row so five "2026-08-23"s are tellable apart. The derived
    display-name rule (13u item 4) is the ranking's natural friend but is NOT built early here —
    titles as they are, ranked well, is this act's bar.
15. **The Compare + LENSES cleanup — BUILD IT, no proposals (her fifth-wave ruling, verbatim: "i
    honestly don't even want proposals - i want item 15 to just do its best with compare + lenses
    and build the code changes - I find it hard to compare from screenshots, it's really a user
    FLOW. that's why I keep saying UX - this is deeper than just UI and what buttons are there,
    it's about how the user experiences the page.")** The batch redesigns the pair's USER FLOW
    directly and lands the code — she judges it in the running app, not from stills. The bar: the
    two modes tellable apart from their structure; Compare's first-open teaches by what it OFFERS
    (pick a note / mint an outline as real, generous doors — not centered gray prose); the picker
    is item 14's component; every act ("make outline note", "+ note", "+ column", "Duplicate as
    Version", ✓/⧉) is a clear, generous control where the flow wants it. The lens/compare SEMANTICS
    (13b's rebuild) are untouched, and the mode ROW itself (R60–94 canon) stays — everything INSIDE
    the two modes is the batch's to reshape. **HER COPY DOCTRINE, as amended the same wave:** *"if
    a new sentence is truly necessary it can be added, but in general the focus should be on an
    excellent, guiding, clear user experience with nice, generous buttons"* — structure and
    generous targets first, ?-disclosure for depth, a sentence only where truly necessary. Her
    named negative example (13u's, not this round's — context only): the comment pane, "a big box
    with a tiny place to click into and write in."
16. **The Blocks page — PROPOSAL-FIRST, never built blind** (her own words: "I'm not even sure how
    to fix it"): the batch produces 2–3 concrete directions as mockups/screenshots for her ruling —
    her floated candidates seed them: (a) a book-page-like **in-note index/outline** (the block-TOC
    idea grown up: names/first-sentences, jump, collapse); (b) a **read-the-note view with reading
    tools**; (c) a rename away from "Blocks" either way. She picks; the build follows her pick
    (this act if timing allows, else the deferral is recorded with its owner). No silent redesign
    of a mode's purpose — that is a product call. **RULED at the eighth wave (2026-08-31, the
    mockup feedback — the W8-1 block below): BOTH build — Index as a new mode after Takes, Blocks
    stays as the self-sufficient poweruser center — PLUS a note READ surface (read-only,
    vertical/book-like, click-through landing in Index, position tracked across modes). The name
    "Blocks" stays for direction C; the mockup file is the style reference.**
17. **Snippets — the BOUNDED refresh, widened at her fourth wave** (her scoping: "a BIT of a
    refresh"; then: *"there's a field guide scraps - how? does each book have a pool? note have a
    pool? why can you not make a new pool, move items between pools, or delete them there?
    definitely needs a more familiar surface"*): **pool MANAGEMENT doors** — create a new pool,
    delete a pool (the ordinary `deleteContainer`/Trash road), move scraps between pools — plus
    search over scraps and a more library-esque listing. **The ownership answer belongs IN the
    surface's structure** (the true facts: pools are free-standing scrap areas — no book or note
    owns one; "tutorial scraps" exists because the field guide seeded its own; most people live in
    the one default pool): if the surface shows pools as what they are, her three questions stop
    needing to be asked. **PLUS the naming collision flagged for her, not solved:** the chip reads
    "pool: Pool" — `container.kind='pool'` (scrap areas) and the sidebar's Pool (bookless notes,
    R29) share one word for two concepts. ~~Renaming either is product vocabulary = HERS; the batch
    brings candidates.~~ **NAMING RULED (fifth wave, her words: "let's stop calling that whole thing
    pool and focus on it being called snippets"):** the scrap-area vocabulary becomes **SNIPPETS in
    every UI string** — the "pool: Pool" chip, the pool picker, the seeded default's displayed name,
    any "pool" copy on the surface — on the K5 precedent (UI strings only; `container.kind='pool'`
    stays the model term exactly as `kind='post'` survived the note sweep; canon docs unchanged).
    The sidebar's Pool (bookless notes) KEEPS its name — the collision dissolves from the other
    side; if she ever wants that renamed too, her word. The deeper "what is this page for" question
    stays recorded as open. **Eighth wave (W8-4): the snippets direction is ruled GOOD; the
    takes-count badge on snippet rows joins the build; "group" proceeds as the working container
    noun (hers to override); the mockup's Snippets tab is the style reference.**

**Act 10 sizing (her authorization at the sitting):** the act is deliberately allowed to be
"more significantly sized." It runs as **up to two sequential Fable implementer waves** at the
architect's discretion — wave 1 the mechanical/polish items, wave 2 the surface redesigns (14–17,
the panel, the lobby) — with a clean handoff seam between; one wave if it fits.

**THE MOCKUP STEP (her instruction, fourth wave; SIXTH-WAVE AMENDMENT: the SUCCESSOR orchestrator
spawns it — her word at the handoff seam, "I might as well have the same agent that will orchestrate
the taste run the html mockup agent" — it is the successor's FIRST act, before 17h):** ONE
mockup agent produces **local HTML** (a file path handed to her — NEVER published anywhere) covering
**item 16's Blocks directions (2–3) and item 17's Snippets refresh**, in the app's own voice
grammar. **ONE feedback round by design** — her words: *"I don't always like multiple rounds of html
because most of the time little details are off, and generally the direction is enough to
establish."* **Compare/Lenses are EXCLUDED from the HTML step at her doubt** (*"the precise
interactions shown by the buttons and what's available don't often cross into html land well… i do
doubt a redesign there will go well"*) — item 15's proposals come as in-app screenshots from the
Act 10 wave instead. **The capture rule (her instruction, verbatim-faithful):** *"i'd make sure that
I save my prompts verbatim and try to ensure that the subagent has access to the images i've been
giving you or at least a good description of them + the issue they show, because I've been putting a
lot of feedback straight into my chat with you and I want to make sure it's all being captured
appropriately."* — executed as `notes/plans/pre-13u-screens-manifest.md` (every screenshot's
contents + her verbatim issue + the routed item; pixels in the gitignored
`notes/plans/pre-13u-screens/` where recoverable). **The mockup agent and every Act 10 wave brief
FROM the manifest + this file's items — never from any session's chat.**

**SUCCESSOR KICKOFF RECORD (2026-08-31, the successor orchestrator's first turn).** State verified
against git (tip `709ee27`; Act 9 close, escrow PASS, handoff, and seventh wave all present; tree
clean, synced). The screens dir holds **2 files** — she did not run the copy command, so the
manifest's descriptions carry for the other nine, the case the manifest was written for. **Her
concurrency authorization at kickoff, verbatim: "Since the html taste agent is a subagent that
won't be making code changes, you can start other codework and that subagent simultaneously."** —
the one-agent-at-a-time rule stands for CODE agents; the no-code mockup agent runs beside 17h at
her word. Mockup HTML lands untracked in `notes/plans/pre-13u-mockups/` (gitignored with its
screens sibling), path printed for her — never published.

**MOCKUP DELIVERED (2026-08-31, ~02:05):** `notes/plans/pre-13u-mockups/blocks-and-snippets.html` —
self-contained, untracked, verified zero external refs, nothing committed or published. Three
Blocks directions (A Index — standing heading-index column beside a scroll-synced reading pane ·
B Read — the calm rendered page, floating tool rail, margin doors on hover; its click-to-edit is
13u2 item 17's door built once · C Blocks-workbench — blocks as objects: per-row facts,
multi-select + bulk bar giving 13e's block multi-select a face, right-hand context panel on item
10's idea; the one direction where the name "Blocks" stays right) + the Snippets refresh (ownership
answered by structure — snippet groups as flat siblings in a left rail; search/filters; calm cards;
multi-select; every existing door preserved; "pool" grep-verified absent from Snippets UI strings).
Agent's flags for her round: the container noun ("group", alternatives group/set/box/shelf — hers);
A and B are close relatives (A's right half is a compressed B — possibly ONE mode with a
collapsible contents column; C is the genuinely separate idea). **Her ONE feedback round is now
open.**

**17h CLOSED (2026-08-31, ~02:45 — the fresh Fable custody session; commits `73763c2` `bc48315`
`98813d4` `eee25d2`, pushed).** Both items FIXED with revert-verified red-on-old pins: R2-7 as
probe-first narrowing (`GatedSaveChoreography`, one brain, both gated families; the swap remedy
REJECTED with a traced reason — renaming an ACL'd item is a `SecItemUpdate` and would prompt; the
surviving between-two-adds crash window pinned as DOCUMENTED behavior, not claimed fixed) · R3-5
with all riders (Bool delete seams, `CustodyHandover.outgoingNotReleased` roll-back-and-refuse,
verified `.passphrase` releases, `deletesSucceed` knob; R3-4's five composition pins + the tripwire
name mapping; R3-6's `setMode` custody choreography off-main byte-preserved). Scope note recorded
at the entry: `deleteEscrow` deliberately not widened (opposite failure polarity, own observable).
Counts: core **1457/154 exact** · Mac **1887/320** (arithmetic exact = 1871/317 + 16 pins/3 suites;
the ONE red was the known latency pin, 3× isolated in its recorded band, adjudicated pre-existing
on the diff fact) · tutorial spine 10/10 · iOS builds · zero `Sync/`, zero schema. Dispositions in
the 17h entry (register flipped closed); the two KnownIssues rows resolved. The session died once
awaiting its backgrounded suite (the standing memory trap) and was resumed to a synchronous close.

## THE MOCKUP FEEDBACK — HER RULINGS, EIGHTH WAVE (2026-08-31, ~02:50; her one feedback round,
## recorded verbatim-faithful; these RULE item 16, widen 17, sharpen 8, and mint item 18)

Her opener: *"amazing work and loved the terminal and study voices, and the great ideas… I LOVED
these mockups… beautiful work seriously."*

**W8-1 — ITEM 16 RULED: BOTH directions build.** Her words: *"both the Index page and the Blocks -
workbench page were EXCELLENT. So I've decided I need both."*
- **Blocks stays Blocks — the poweruser center:** *"keep Blocks as the poweruser center for someone
  who wants to really work with their block, without the side menu even. make sure it has high
  quality doors to the trays, every operation blocks have, etc. this is a useful powerhouse for
  something complex."* (Direction C builds as the Blocks mode; the name stays; self-sufficient —
  tray doors and every block operation in the page.)
- **Index goes in as a mode:** *"index page - obviously a need, seems more fundamental, let's put
  it in under Takes."* (The architect's reading, stated to her in-turn: a NEW MODE TAB slotted
  after Takes in the mode row — correctable at her word if she meant inside the Takes mode.)
- **AND a note READ surface:** *"a Reading surface SHOULD be added! not the book surface (wouldn't
  make sense for a note like it does for a book) within a book, but the Read surface that you
  can't edit it (but clicking on it brings you to that sentence within index, already open, and
  index tracks position with take / write / probably block too). But the read surface that's only
  verticle or book like - that's the thing that notes have been missing relative to books, is the
  ability to read."* (Direction B, adopted as a read-only mode: vertical/book-like; a click lands
  that sentence in INDEX already open; Index tracks position across Takes/Write/probably Blocks —
  the same scrolled-open-door mechanism as 13u item 17's read-view edit jump, built once.)
- **Mode-row canon consequence, recorded:** the note's mode row (R60–94; six modes, ⌘1–⌘6) GAINS
  Index and Read at her word — no existing tab is removed, so item 15's "the mode row stays"
  constraint survives as existing-tabs-stay. The field guide's "getting around" lesson enumerates
  the six modes, so the tutorial content changes → the re-seed obligation rides the closeout.
  AppSpec §12's mode-row delta lands at closeout per the ritual.

**W8-2 — THE MOCKUPS ARE THE STYLE GUIDE; the app restyles to them, Act 10 + 13u.** Her words:
*"treat them as an actual guide - doesn't have to be an exact 1 for 1, but the spacing felt modern
and satisfying, I lovedddd how clean it felt, it felt like I wanted the whole app restyled in that
modern app look. I was drooooling for it!!!… the spacing is good, the size of the index search bar
and it's squarish rounded corners felt great, loved it all."* And: *"i want to app restyled liked
this during batch 10 & during the 13u batch. I feel like the Takes page and Write page already
basically look like this."* And cohesion: *"I also feel like these mockups match the mobile app's
modern feeling and like half of the book page's modern feeling. it matches a lot of the app, the
app just all has to get more cohesive."* → Act 10's item 8 mandate now has a CONCRETE reference
(the mockup file's grammar: the spacing scale, the squarish-rounded search bar, calm cards, no
hairline grid); Act 10 restyles the surfaces it touches; **13u2 inherits the app-wide
continuation** (addendum written in the 13u plan this turn). The mockup file
`notes/plans/pre-13u-mockups/blocks-and-snippets.html` is the reference artifact — PRESERVE it.

**W8-3 — LIQUID GLASS RETIRED ON THE SIDEBAR; solid geometric lines.** Her words (with her
screenshot of the mockup's sidebar, manifest row 13): *"I liked how on the left even, it doesn't
have the liquid glass pane floating on top - i realized i don't like that, and i'd rather have
these more solid, geometric lines."* → part of the restyle mandate: the floating/glass pane
grammar goes; flat, solid, geometric structure in.

**W8-4 — SNIPPETS: ruled good, widened by one, two questions answered.** Her words: *"the snippets
idea is good - can we show how many takes they're in? what if they were edited, do they still
appear there? i think it's a cool idea."* → the takes-count badge on snippet rows is IN (the
mockup's "⑂ N takes" becomes real). Answered in-turn (existing semantics, no invention): a snippet
is a standalone block living in its group until moved/archived/deleted; editing it updates it in
place (the "edited" metadata) and it STAYS listed; dragging into a note mints a lineage COPY and
the original snippet remains — edits to the note's copy never touch the snippet. **The container
noun stays open** — she engaged with the mockup's "group" without objecting; "group" proceeds as
the working noun, hers to override.

**W8-5 — NEW ITEM 18: the BOOK view's Outline glowup + an index-like book view.** Her words (with
her screenshot of the current book Outline on the field guide, manifest row 14): *"I'm also
realizing that I'd like a more 'index like' view on book - I think that outline could be a better
job of being the 'google docs like' one super long document, just have better spacing and stuff
because it's so bizarrely open on the right and it's ugly how the note details render below the
note's opening paragraphs - if anything, those should render to the side. but yeah, i basically
think that outline needs to get a bit prettier / earn its place as 'the whole document at once,
but you can have sections collapsed and see the outline there' and there should ALSO be an index
like view, and ALSO the book view is cool - it can share an outline with the more google docs
'Outline' mode. I don't know how the index view will reconcile with the current smallness of the
outline pane, but I'm sure a way will be found for things to work in the book view."* Her close:
*"in the end, this html mockup provided the bookview AND the notes view with a much needed
glowup."* → **Item 18** (book view): (a) Outline mode earns "the whole document at once,
collapsible sections, outline visible" — fixed spacing, the open-right fixed, note details render
to the SIDE never below the opening paragraphs; (b) an index-like view for books (the note Index's
sibling — share the outline brain where honest); (c) the book view sharing an outline with Outline
mode. Runs in Act 10 wave 2 IF it fits; else DEFERRED to 13u2 with the restyle continuation
(recorded either way — never dropped).

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
