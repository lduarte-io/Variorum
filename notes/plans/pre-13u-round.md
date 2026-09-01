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

**R-pre13u-7 — THE NINTH WAVE: the security-clarity rulings (2026-08-31; carried by her to the
successor from a background design session with the founding orchestrator).**
**`notes/plans/pre-13u-memo-security-shapes.md` is the BINDING record** — the one law, the four
credentials, the RECIPES presentation format, shapes 1–2 with per-shape "who this protects you
from" + the two what-ifs, the per-mode "what YOU need" statements, the truthful unchosen-state
indicator, the two decision ceremonies, the ratified sync sentence, the compound warning, rotation
stays open (the Auto corner stated out loud). Her two-line version, verbatim: *"Read
notes/plans/pre-13u-memo-security-shapes.md — it extends Act 10 item 3's spec and is the binding
record of the security-clarity rulings; Shape 3 is deferred, the escrow/posture coupling is the
one behavior change, the rest is wording."* Consequences, recorded: **(a)** the memo EXTENDS Act 10
item 3's spec, and its recipes format SUPERSEDES the sixth-wave "one situation table behind a ?"
in shape — no grand matrix; the three-row shapes summary is the ONLY surviving table (the
seventh-wave truths — the two new-device rows, the demanded-mode fallback, E2EE-stays-internal —
carry INTO the recipes/what-ifs wording unchanged). **(b)** The ONE behavior change is the
escrow/posture coupling (§4: demanded modes do not offer the iCloud spare; escrow's default
follows the posture; her why-sentence is the copy) — it builds in Act 10 with item 3. **(c)**
Shape 3 is DEFERRED at her word (§8, verbatim: *"we're deferring a shape 3 where sync without
variorum login is created - not making it now, I feel fairly satisfied"*) — a ruled non-build with
the reopening question framed in the memo, deliberately NO owner slotted (not parked work — a
settled product ruling; 13x-adjacent by nature if ever reopened). **(d)** Precedence: where the
memo and her carried successor block differ, THE MEMO WINS (its own §10). **(e)** The memo's
tutorial-privacy-chapter wording changes make the field-guide re-seed obligation live at closeout.

**R-pre13u-8 — PHONE SHERLOCK, RULED (her word: "i agree, giving the word for it to become
R-pre13u-8 for Act 0").** The tenth-wave proposed shape below builds as proposed, in Act 0: the
phone seeds Sherlock at R-pre13u-1's first-write moment through the Journal-furniture gate
(account-owned stores skip and arrive-by-sync); the pristine-copy dedupe repair (per-note manifest
hashes; both-pristine → deterministic keeper; one-edited → edited kept; both-edited → both
survive, an edited copy NEVER silently retired) lands beside the Journal-keeper repair — the
`Sync/` half is Fable's under the standing rider, the seed rides the Opus half. **The RESTORE
DOOR is also RULED (her word: "Restore door - yes, let's do it")** — a tutorial-style "restore the
sample library" door on the field guide's restore precedent; the Mac face rides Act 10 (wave 1);
the phone's face joins mobile's parity answer. **And R-pre13u-7 gains consequence (f), her
instruction verbatim: "the ninth wave should have a note to write a mobile parity note explaining
the posture, ensuring mobile matches, etc. no different settings for one account on mobile +
mac."** → the closeout's MOBILE PARITY LINE carries a security-posture note: the memo's
presentation (recipes, shapes, the escrow/posture coupling) reaches mobile as the SAME posture —
one account has ONE posture across Mac + phone, never per-platform settings divergence (the
`Shared/` custody brains already carry the semantics by construction; the faces are per-platform).

**THE OVERNIGHT AUTHORIZATION (2026-08-31, ~04:00 — her word, verbatim: "i'm going to sleep and i
want this to be free to run until completion overnight").** The away-run rules are ACTIVE for the
rest of the round: PROVISIONAL-and-continue on everything short of an author-only hard stop; taste
forks are built to best judgment under her granted latitude with alternatives noted; anything
genuinely hers is HELD and BUNDLED into the MORNING BUNDLE at close — never improvised around,
never blocking. The remaining sequence runs one agent at a time to completion: Act 5 (in flight) →
Act 0 Opus → Act 0 Fable (`Sync/`) → Act 10 wave 1 → wave 2 → the Opus midpoint review + fixes →
the final Fable ladder (cap 3) → closeout. The `/Applications` refresh + tutorial re-seed run
overnight ONLY if she quits the app before sleeping (asked); otherwise both are HELD for the
morning per the never-quit rule. **GRANTED (her word before sleeping: "i've quit variorum, and the
mac will be left plugge din with the lid open") — instance check verified ZERO at 04:0x; the
zero-instance window is open for the closeout's refresh + re-seed (A1 backup first, always);
caffeinate is holding the machine.** **RE-CONFIRMED at the round's tail (her word, 2026-08-31 evening): "My variorum is quit and it's ready for refresh when the final Fable cold review + fixes for that are complete."** — the refresh + re-seed run AFTER the ladder's fixes land, at the still-open window (re-verify zero instances first). **The Pool tag-column question is RESOLVED without her** — her
mid-sitting re-cast already granted the latitude by name (*"tags as a column or not"*), and the
eighth wave superseded the old screenshot-pair plan with a style guide she loved: the wave builds
the mockup's card/metadata-chip grammar as the default, judges the column question in place, and
notes the alternative in the morning bundle only if genuinely torn. **Cast confirmed at her
goodnight (verbatim: "fable implementers on act 10 (both waves) + fable implementers for wave 9
explaining the encryption by the way"):** BOTH Act 10 waves are Fable, and the ninth wave's
encryption-explanation build (the memo's rendering, item 3) is explicitly Fable-implemented —
consistent with her mid-sitting re-cast, now unambiguous.

**HER OVERNIGHT CHECK-IN (2026-08-31, during Act 10 wave 1 — recorded as a live finding + its
verification):** *"why did variorum want permission to record my screen? i gave it permission for
now but I don't get why it had that question and users definitely shouldn't see it. I think maybe
it's fine though and i'ts just for the design pass?"* **Verified by the architect same turn: the
SHIPPING PRODUCT has ZERO screen-capture code** — `grep` over `App/`, `Sources/`, and every test
target for `CGWindowListCreateImage` / `ScreenCaptureKit` / `SCScreenshotManager` /
`CGDisplayCreateImage` / `XCUIScreen` / `screencapture` returns NOTHING — so no user can ever be
shown that prompt by the app itself. The prompt was the DESIGN PASS's screenshot verification
capturing the running dev-store Debug build, which carries the same "Variorum" identity, so macOS
named the prompt after it. Dev-machinery-only, exactly her guess. **Routed:** the midpoint review
and the ladder confirm no capture code lands in any production target (the grep is the check);
the morning bundle notes she may revoke the grant afterward (System Settings ▸ Privacy & Security
▸ Screen & System Audio Recording) — nothing in the product needs or requests it.

**THE NINTH WAVE'S CLOSING RIDERS (2026-08-31, pre-sleep — the memo's §9b/§9c, carried by her;
the memo is the full text, this block is the ROUTING):**
- **T1, the stale-copy re-key clobber** → **Act 10 wave 2 ATTEMPTS the guard** (the recency
  comparison reading the disclosure envelope's plain facts — ids/dates/seqs — and the
  COUNT-AND-DATES warning she ruled emphasized: "12 notes this copy doesn't have, newer versions
  of 9 others, latest Aug 28"; plus the near-empty-store corner). The wave is Fable, so any
  `Sync/` lines ride the standing rider; if the guard proves entangled, the deferral is recorded.
  **EITHER WAY the final ladder verdicts the door: guarded, or a KnownIssues row with an owner.**
- **T2, the honest UNKNOWN tier** → the SPLIT is hers: the **rendering half joins Act 10 item 3
  NOW** (three-value truth — covered/exposed/unknown each with its own sentence; the Act 9
  `ProtectionLegs` brain already carries the three states; a deferred rendering would quietly
  ship a binary); the **verification half routes to 13r** (her Sparkle/fresh-download walk — the
  first real stranger machine); the closeout records the 13r line.
- **§9c item 3, render-don't-re-derive** → BINDING review discipline for the Act 10 waves, the
  Opus midpoint, and the ladder: the keystone lines (key-not-backup · the sync sentence ·
  Touch-ID-guards-this-device) land essentially verbatim from the memo — almost-true paraphrase
  is the named failure mode.
- **§9c item 4, the marketing pull** → no build; stands in the memo as the named pressure
  (13s/copy-phase adjacent; R13p-16 is the defense).
- **§9c item 5, promote to canon** → NEW CLOSEOUT OBLIGATION (13, below): the closeout anchors
  the memo from the canonical docs (an AppSpec delta pointer) so 13x/13y/the tier inherit the
  shapes model rather than re-derive it.

**THE TENTH WAVE (2026-08-31, after Acts 3+4's close — her replies to the three parity calls;
the two pending items since RULED as R-pre13u-8 above):**

- **PHONE SHERLOCK — her directive, verbatim: "hmmm can you explore any way that the phoen COULD
  get sherlock but if it synced it could just check for a duplicate and not include it? like if a
  book's hash was identical or something? some people will be phone only users and they should
  get to experience it."** The architect's PROPOSED shape (presented to her in-turn, pending her
  confirm — becomes R-pre13u-8 on her word): the phone seeds Sherlock at **R-pre13u-1's
  first-write moment** through the same gate as the Journal furniture (an account-owned store
  skips the local seed and waits for sync — arrive-by-sync stays the common account path); the
  race where two seeded copies meet converges by a **pristine-copy dedupe** beside Act 0's
  Journal-keeper repair: the sample library is identifiable by the seeder's own `discover`
  predicate, and a copy is PRISTINE when its per-note rendered text matches the bundled source's
  manifest hashes (her hash idea, sharpened to per-note). Rule: both pristine → deterministic
  keeper (smaller id), the other retired (nothing lost — byte-identical); one edited → the EDITED
  copy is kept, the pristine one retired; both edited → BOTH survive (the documented
  concurrent-divide class — an edited copy is NEVER silently retired). Zero schema; the repair
  emits ordinary tombstones with explicit outbox rows; **`Sync/` work → Fable, riding Act 0's
  existing Fable half**; the phone seed rides Act 0's Opus half.
- **The never-lands corner — ACCEPTED (her word: "i think it's fine for an account-owned store
  whose sync never lands to not seed ? I'm not syre how the sync would never land").** Her
  question answered in-turn: the corner is a signed-in device that cannot complete a clean
  pull-to-head (long offline stretch, unreachable server, or a §12 lockstep refusal on an
  outdated build) — the gate can't tell "account has nothing" from "couldn't look", so it
  declines; Sherlock simply arrives with the rest of the account's content when sync first lands.
- **The restore door — HER UNCERTAINTY PRESERVED, verbatim: "you're talking about a tutorial
  style restore, right? i guess if it's only restoring sherlock holmes it's not necessary? but
  might be nice? feeling a bit conflicted on these calls honestly."** The architect's
  recommendation (pending her nod): ADD the door — Sherlock is field-guide-class seeded content
  and the field guide has restore (the seeder already mirrors TutorialSeeder's
  `discover`/`findOrSeed`/`restore` shape, so the door is nearly free); the starter-journal
  "deletion is final" precedent doesn't apply, that being user-writing scaffold, not demo
  content. Not built without her word.
- **MOBILE MUST DESIGN FOR THE NEW MODES — her note, verbatim, routed to the parity line: "i'd
  also make a note for mobile that with the new act 10 edits to notes to have that block page &
  outline + pages/google doc looking page + a read page, that mobile is going to have to think
  of how to handle all of those items."** → joins obligation 7's MOBILE PARITY LINE: the
  closeout's MobileSoul row names the Act 10 mode additions (Index · Read + minimal companion
  outline · the Blocks powerhouse · the cohesive Book redesign) as surfaces the phone must
  deliberately answer — its own shapes, per MobileSoul's smaller-surface discipline, decided at
  mobile's resumption, never bolted on.

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

### SCOPE ADDITION (R-pre13u-8, ruled 2026-08-31 — see the RULINGS block): Act 0 also carries the
### phone's Sherlock seed + the pristine-copy dedupe repair

The Opus half adds the phone's Sherlock seed at the same first-write moment (account-owned stores
skip — arrive-by-sync); the Fable `Sync/` half adds the pristine-copy dedupe beside the
Journal-keeper repair (per-note manifest hashes against the bundled source; both-pristine →
deterministic keeper; one-edited → the edited copy kept; both-edited → both survive — an edited
copy is never silently retired; ordinary tombstones with explicit outbox rows; zero schema). The
sample library's identity predicate is the Mac seeder's own `discover` predicate, shared.

### ACT 0 OPUS-HALF RECORD (2026-08-31, the overnight run — the seed half of R-pre13u-1 + R-pre13u-8)

**Scope built:** the four groups in the work order. **NOT built here and deliberately named:** the
two `Sync/` convergence repairs (the Journal keeper + the pristine-copy dedupe) — the Fable session
that follows, per the standing rider; and the **restore-the-sample-library door** (R-pre13u-8's
ruled door — Mac face at Act 10 wave 1, phone face at mobile's parity answer). **ZERO
`Sources/VariorumCore/Sync/` lines, ZERO schema, ZERO `Sources/` lines of any kind.**

**Group 1 — B1, seed-on-first-write (R-pre13u-1).** The launch-time seed call is gone from
`VariorumMobileApp`; the 20-second bounded wait, its 100 ms poll, and `SyncGate.hasSyncedCleanly`
are DELETED with it. The occasion is `MobileFirstWriteFurniture` (new, mobile-local), announced to
through a new `AppSession.noteFirstWrite()` seam wired at five write doors: the quick note's mint,
＋ New Note, Today's Entry, ＋ New Book, ＋ new scrap. **Nothing on a write path awaits it** —
`noteFirstWrite()` starts a task and returns.

The gate reduced to ONE fact read AT THE WRITE (`belongsToAnAccount`) because that is the first
moment the question has an answer: the sign-in door lives inside the shell, so at launch on a fresh
install there is no ordering in which the account could be known, and waiting only narrows the
window rather than closing it. An account-owned store seeds NOTHING — her ruled accepted corner
("an account whose sync never lands" simply waits). `Outcome.awaitingFirstSync` was RETIRED rather
than left unreachable (the 13c `noDailyBook` precedent: a case that can never be returned is the
drift class); `.accountOwned` replaced it.

**Two guards, at two moments, and the split is the design.** The virgin verdict is taken at LAUNCH
(`prime()` — one cheap local read; reading is not seeding, and what her ruling moved off the launch
path is the MINT) because by the write moment her own first note may already have landed, and
reading it late would decline on the strength of the very keystroke that summoned the furniture.
Beside it, a **live re-check inside the mint's own runner turn** (`dailyJournalBookID()` +
`assertBookNameIsFree`, both public core reads), which cannot be read stale — AppSpec's
`deleteBlock` precondition doctrine. That second guard is what makes **Today's Entry** safe:
`shelveInDailyJournalBook` creates and pins the Journal book ITSELF, so her very first act can mint
exactly the book the furniture would; the runner is serial, so one turn sees the other's book and
declines, and exactly one Journal exists whichever door won.

**Group 2 — empty-state copy.** `MobileEmptyStoreCopy` (mobile-local). The Library had **no empty
state at all** — an empty store showed a path line, a search field, a filter row and nothing else —
and now says `No notes yet.` / `＋ New Note starts one.` The shelf's existing books line gains the
second road. **Both surfaces name the returning-owner road** (`Have an account? Settings ▸ Sync
signs you in.`), because a fresh install has exactly two kinds of owner and naming only the first is
what makes an empty screen read as *"my writing is gone"*. Door names are DERIVED from the doors
(`MobileNewNoteDoor.doorTitle`), never retyped. FUNCTIONAL and PROVISIONAL — 13s rewords.

**Group 3 — the phone's Sherlock seed (R-pre13u-8) + the HOIST.** The phone seeds the sample
library at the same first-write moment through the same gate; an account-owned store skips
(arrive-by-sync). **Placement reasoning, stated as the work order asks:** `SampleLibrarySeeder.swift`
and `SherlockAdventures.txt` **MOVED** (git mv, one file, one resource) to
`App/Variorum/Shared/SampleLibrary/` — `Shared/` is a `PBXFileSystemSynchronizedRootGroup` in BOTH
app targets, so the hoist cost **zero pbxproj edits** and the resource lands in both bundles
automatically (verified in both built products, not assumed). The type KEPT its name, which is why
**`VariorumTests/SampleLibraryTests.swift` is byte-untouched** — the 3C parity proof that an address
moved and behaviour did not. What is per-platform and deliberately NOT hoisted is WHEN the seed runs:
the Mac keeps its launch occasion and its bounded wait (its occasion still has the race the wait
narrows); the phone's occasion answers the account question once and hands the seeder `.unowned`, so
**the wait is structurally unreachable from the phone**. Two now-stale sentences in the moved file's
header carry dated corrections rather than silent edits.

**THE MANIFEST — the artifact the Fable half consults.** `SampleLibraryManifest`, file-scope and
`nonisolated` in the same file:

```
bookName: String            // the reserved book name  — half the identity predicate
tagName:  String            // the reserved tag path   — the other half
noteHashes: [String: String]  // note TITLE → SHA-256 hex of the text the seed stores
titles: Set<String>
func isPristine(title:renderedText:) -> Bool
```

Built by `SampleLibrarySeeder.manifest()` (from the bundle) or `.manifest(stories:)` (pure, for a
pin). **The engine side needs to import nothing:** the recipe is core's own public
`BridgeHash.body`, so the repair reads
`BridgeHash.body(Queries.renderedText(db, containerID: id))` and compares — which matters because
`Sources/VariorumCore/Sync/` cannot see app-target code at all, so the two halves must name ONE
function that both can reach. **A title the manifest does not know is never pristine** — a note she
ADDED to the book is her own, and "I have no hash for this" must never read as "this is untouched
shipped content". Per-NOTE rather than per-book, because her rule turns on per-note truth (one
edited → the edited copy kept) and a book hash would have to be re-derived from the notes anyway.

**Group 4 — the header correction (the act's own obligation).** `MobileStarterJournal`'s header
claimed the virgin-store guard *"protects a phone that syncs an existing account down"*. That was
FALSE and the residual proved it; a dated in-place correction now says so, says why a local read of
an empty store can never distinguish *"you have nothing"* from *"your things have not arrived yet"*,
and says what actually protects it instead.

**PINS, and the red-on-old evidence.** These are ruled behaviour CHANGES rather than bug fixes, so
the guard's form is **behavioural revert**: the old behaviour was restored in the implementation and
each named pin was observed RED, then restored. Three passes, all run:

| pass | reverted | pins that went RED (observed) |
|---|---|---|
| A | the account gate; the in-turn live guard | `anAccountOwnedStoreIsNeverSeeded` · `signingInBeforeTypingLeavesNoStarterFurniture` · `decliningForAnAccountDoesNotSpendTheSeed` · `aJournalBookArrivingFirstStopsTheMint` (**`books.count → 2`** — the duplicate Journal itself) · `aBookAlreadyWearingTheNameStopsTheMint` (**`books.count → 2`**) |
| B | the launch seeds again; the 20 s bounded wait; no phone sample seed | `primingSeedsNothing` (a Journal book present after launch alone) · `anAccountOwnedStoreDoesNotWait` (**`elapsed → 20.097 s` vs the 5 s budget** — the deleted wait, measured) · `anAccountOwnedStoreSeedsNothing` · `aPhoneOnlyStoreGetsTheSampleLibrary` · `theJournalIsSeededBeforeTheSampleLibrary` |
| C | the manifest hash recipe perturbed by one newline | `theManifestMatchesWhatTheSeedActuallyStores` (**12 of 13 notes**) · `theHashIsTheCoresOwnRecipe` · `aTitleTheManifestDoesNotKnowIsNeverPristine` |

The one pin with a deliberately WEAK guard is recorded as such: `MobileEmptyStoreTests` pins that
the copy names both roads and DERIVES the door name — it cannot fail against a tree that has no copy
at all, because the symbol would not exist. The view wiring it guards is one visible line per surface.

**Counts.** Mobile **602 / 97 PASSED, the 2 standing known issues** (baseline 582/93 — +20 tests,
+4 suites). Mac **[see the close-of-act line below]** with `VariorumTests/` unmodified. iOS build
gate green at every step (the standing per-batch gate).

**Bundle delta on the phone:** the resource is **574,874 bytes raw / 211,562 gzipped** — the only
size this act adds, and it is the same file the Mac already shipped.

**Notes for the Fable `Sync/` half:**
1. The manifest above is the pristine predicate; `SampleLibrarySeeder.bookName` / `.tagName` /
   `discover` are the identity predicate, all now in `Shared/` — but **none of them is reachable from
   `Sync/`**. Inject the manifest (or its `[title: hash]` dictionary) the way the engine already
   takes its key providers; the hash recipe itself is reachable (`BridgeHash.body`).
2. The Journal-keeper repair's "same book" predicate has a live precedent to match: this act's mint
   guard uses **designation** (`dailyJournalBookID`) plus **name** (`assertBookNameIsFree`, which is
   `BookNaming.key`-folded, not raw equality). The plan's candidate was "designation + profile".
3. The residual the repair must heal is now precisely stated and pinned from the other side:
   `signingInBeforeTypingLeavesNoStarterFurniture` pins that the *new* ordering avoids it; the repair
   is for devices where it already happened.

**Deferred / handed on:** the sample-library restore door (Act 10 wave 1 · mobile's parity answer,
MobileSoul **PL-17**); both `Sync/` repairs (the Fable half); the empty-state copy's wording (13s).

### ACT 0 FABLE-HALF RECORD (2026-08-31, the overnight run — the two `Sync/` convergence repairs)

**Scope built (the standing rider's session):** the Journal-keeper repair (R-pre13u-1's second
half) and the sample-library pristine-copy dedupe (R-pre13u-8), both as SyncSpec §7-class
apply-time repairs inside `runPostApplyRepairs` — deterministic on every device, every repair
write enqueued explicitly past the muted triggers, ordinary tombstones with exact stamps so the
Trash/restore surfaces stay honest. **ZERO schema, marker stays 7, ZERO `Server/` lines and ZERO
`Persistence/` lines (diff-verified against origin/main).** Commits: `a83a033` (Journal) ·
`27905c4` (Sherlock + the seam) · `c183da7` (the wiring) · the records commit.

**THE "SAME BOOK" PREDICATE — decided, and why.** ONE named function,
`Queries.dailyJournalBookCandidates(_:)`: live + `kind='curated'` + `profile='journal'`, sorted by
id (index 0 = the keeper everywhere). The mint (`insertDailyJournalBook`) now stamps
`Queries.dailyJournalBookProfile` — the same constant the predicate filters on — so the mint and
the repair share one symbol and cannot drift. The reasoning, recorded as the work order asks:
**(a)** the plan's candidate was "designation + profile", and that is what this IS, with
designation read as *provenance*: the only writer of reading-profile `'journal'` is the ONE shared
daily-book mint (⌘J, Today's Entry, the bridge, the phone's furniture all delegate to
`shelveInDailyJournalBook`'s ensure), which designates at birth — so the profile is the durable
"was designated on its own device" fact, while the `setting` row itself cannot serve as the
predicate: its CAS erases the loser's designation before any device can read both, and a
predicate on the raced value would be nondeterministic across devices. **(b)** The Opus half's
mint-guard precedent (designation + `BookNaming`-folded name) deliberately does NOT carry its
NAME leg into the repair: `BookNaming`'s own E13 doctrine says the offline name race is LEGAL and
a name-keyed repair "would delete a book she made on her phone" — and a renamed real Journal must
not shield a duplicate from healing. The name belongs at the DOOR (one device, her intent
visible); the profile belongs at the REPAIR (provenance the race cannot fake). Pinned from both
sides: `aDeliberateBookNamedJournalIsNeverConverged` (her same-name book survives) and
`twoOfflineMintedJournalBooksConvergeToTheSmallerIDKeeper`.

**What the Journal repair does per loser (the explicit what-moves-with-the-loser spec the
Fragments post-mortem demands):** live chapters move whole to the keeper (`reading_section`
re-pointed — duplicate names and interleaved positions are both legal, and membership
`section_id` pointers stay meaningful); live memberships re-point to the keeper, EXCEPT one whose
post the keeper already holds, which tombstones as a pure duplicate (`uq_reading_post_live` — the
tag.path application rule, pinned by `aPostAlreadyOnTheKeeperDedupesTheLosersMembershipInstead`);
the loser reading tombstones (its cascade finds nothing — children just moved — and the §7 victim
sweep is the belt); the DESIGNATION rewrites to the keeper ONLY where it currently names a loser
(one she deliberately moved to another book is hers; plain UPDATE, never REPLACE — `sync_version`
is the CAS token). What deliberately does NOT move, the tag.path "worst case a lost rename"
class: the loser's row metadata (custom name, extents, a finish) and its shelf-pin entry (dangles
harmlessly; the pins read is liveness-filtered). A FINISHED keeper still receives memberships —
a repair is not authoring (the resolveSyncConflict-under-seal doctrine).

**THE INJECTION SEAM (the architect's recommended shape, adopted — my reading of the engine
agrees):** `SampleLibraryDedupeFacts` (new, `Sync/SampleLibraryDedupe.swift`), taken by
`SyncEngine.init` exactly the way it takes `keyProvider` — **nil by default, and a nil-facts
engine is INERT** (pinned: `noInjectedFactsMeansNoDedupe`), so no test world and no unwired
composition can misidentify a book. The facts: the identity predicate (the seeder's own
`discover` rule — EXACT live-name match, deliberately unfolded: a renamed copy reads as hers and
is left alone), the reserved tag path, a **LAZY** `loadNoteHashes` closure (the ~0.5 MB parse
runs only when two same-name copies actually coexist — about once in a store's life), and the
hash recipe as a function reference (`BridgeHash.body` — a recipe drift reads everything as
edited, which fails SAFE to both-survive). Wired at the ONE composition site both platforms
share (`SyncSession.configure` in `Shared/`), from `SampleLibrarySeeder.dedupeFacts()` — so the
Mac and the phone hand the engine identical facts by construction, and
`SampleLibraryDedupeFactsTests` (Mac, 3 pins) binds the wired facts to the real bundled manifest
and the one shared recipe — the drift core tests cannot see.

**The PRISTINE rule as built — the ruled hash rule plus engagement, every extension erring in ONE
direction.** A copy is pristine iff its live notes are EXACTLY the manifest's titles with
matching per-note rendered-text hashes AND it shows no other sign of her hands: a fanned or
archived take (invisible to the render — without this, a take she fanned on shipped text would
be silently retired, exactly what "an edited copy is NEVER silently retired" forbids; pinned:
`anUnrenderedTakeCountsAsEngagementAndProtectsTheCopy`), a savepoint, a comment, a tag beyond the
reserved one, a membership in another book (without this, retiring the copy would tear its note
out of a book she curated), a seal, an archive, an entry date, floating notes, a reference, or
book-level extents/finish/grouping. Every signal reads SYNCED rows only (same verdict on every
device once converged — the determinism the keeper choice rides on) and errs only toward EDITED,
i.e. toward keeping copies. **INDETERMINATE + defer-whole-pass:** a copy whose rows are still in
flight (a membership's post not yet arrived, a placement's block missing, a block with zero
variant rows, zero membership rows at all, or fewer live notes than shipped with no tombstone
evidence — the SyncSpec §5 straggler class) defers the ENTIRE pass with zero writes: classifying
partial data could retire the wrong copy on one device and a different one on another (traced:
a half-arrived pristine copy would read "edited" and beat the complete local pristine copy,
breaking cross-device determinism). Deferring is free; a later batch completes the picture.
A pruned-then-purged copy whose tombstone evidence is physically gone reads indeterminate
forever — both copies survive, the safe direction, recorded.

**Retirement mechanics:** the book first (its active cascade takes memberships + chapters at the
exact stamp; the §7 victim sweep enqueues what the muted outbox triggers could not), then each
member note via the container cascade (placements → blocks → variants, tags, references) — all
ONE stamp per copy, so `restoreContainer`/`restoreReading` recognize the family. Ordinary
tombstones, never purge intents: the Trash lists the retired copy and Put back works.

**PINS — red-on-old evidence (test-first: the suites were written and RUN before any repair
existed).** On the pre-repair tree, **7 of 11 core pins RED, observed and logged**: two live
Journals persisting on both devices (`liveJournalBookIDs == [keeper]` read TWO ids), the loser
never tombstoned, no repair outbox rows, the designation stuck on the loser, the shared post
doubly membered; two sample copies persisting, no family retirement, and the PRISTINE copy
surviving beside the edited one. The Sherlock reds ran against the seam-only tree (the facts
struct had to exist to compile; the repair logic did not yet). The 4 green-on-old pins are
boundary/documented-outcome pins whose value is holding AFTER the repair:
`aDeliberateBookNamedJournalIsNeverConverged` (E13), `twoEditedCopiesBothSurvive` (the ruled
documented outcome — BOTH survive, zero retirement writes, the §7 concurrent-divide class),
`noInjectedFactsMeansNoDedupe` (inert default), `theRepairIsIdempotentOnceConverged` (dump-stable
across further rounds; the Sherlock idempotence assertion rides
`twoPristineCopiesConvergeToTheSmallerIDKeeper`). Convergence assertions throughout are the §7
trio: deterministic outcome · same choice on both devices · byte-identical `syncedDump`.

**Counts (the close, all three suites in order):** core **1475/158 PASSED** (baseline 1464/156 +
11 tests/2 suites — `FurnitureConvergenceRepairTests` + `SampleLibraryDedupeRepairTests`); Mac
**1908/323 PASSED** (baseline 1905/322 + the 3 wiring pins; the load-flaky latency pin GREEN this
run, no adjudication needed; the tutorial spine green inside the run); mobile **602/97 PASSED +
exactly the 2 standing known issues** (baseline exact — the phone's dedupe wiring rides the
shared `SyncSession`, zero mobile-side deltas).

**PROVISIONALs + documented corners → QUESTIONS #85** (the away-run bundle): the predicate
choice's one behavioral corner (restoring a superseded old Journal from the Trash while a new
designated one lives re-converges the two — memberships merge into the keeper; arguably correct
under one-daily-Journal, hers to ratify), the engagement-signal extension of the ruled hash rule,
the lost-metadata/pin-dangle class, and the ≥3-copies generalization (pristine copies retire
beside ANY survivor).

**Deferred / handed on:** **SyncSpec §7's canon delta (the two new repair rules) is the
ARCHITECT's to write at closeout — deliberately not written here** (the work order's own
instruction; this record is the source it composes from). The sample-library restore door stays
Act 10 wave 1's (Mac) + mobile's parity answer (PL-17). Nothing else deferred; no owner changes.

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

> **DATED CORRECTION (2026-08-31, the midpoint review's M1 — the line above CONFLATES two things and
> the first implementation followed it faithfully).** "Segments on entry by the global mode" and "so
> each paragraph becomes a block" are not the same claim: `importPost` reads the reader's synced
> `default_segmentation`, and under the shipped **One block** option the whole library seeded as
> thirteen giant blocks — the opposite of what this act exists to demonstrate. **The seed names its
> own mode** (`SampleLibrarySeeder.segmentation = .paragraph`, passed through `importPost`'s new
> explicit `segmentation:` parameter), which restores the mode-independence `TutorialSeeder` always
> had via `newBlock`. Every other `importPost` caller is byte-unchanged. Pinned:
> `theSeedIsIndependentOfTheReadersSegmentationSetting`.

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

   **NINTH WAVE (R-pre13u-7 — read before building this item):**
   **`notes/plans/pre-13u-memo-security-shapes.md` is the BINDING extension of this spec.** Its
   RECIPES format supersedes the situation-table SHAPE — no grand matrix; the three-row shapes
   summary is the only surviving table — while every seventh-wave truth below carries into the
   recipes/what-ifs wording unchanged. The one behavior change riding this item: the memo §4
   escrow/posture coupling — demanded modes do not offer the iCloud spare; escrow's default
   follows the posture; her why-sentence is the copy.

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
    takes-count badge on snippet rows joins the build; the container noun "group" is RULED fine
    (her follow-up); the mockup's Snippets tab is the style reference.**

**Act 10 sizing (her authorization at the sitting):** the act is deliberately allowed to be
"more significantly sized." It runs as **up to two sequential Fable implementer waves** at the
architect's discretion — wave 1 the mechanical/polish items, wave 2 the surface redesigns (14–17,
the panel, the lobby) — with a clean handoff seam between; one wave if it fits.

**SIZING DEVIATION (successor architect, 2026-08-31 mid-run — recorded per the skill's deviation
rule):** wave 1 consumed nearly a full implementer session on the SMALLER half of the act's scope,
so "wave 2" runs as **sequential focused Fable sessions** rather than one — **2a** the
protection/clarity wave (items 3 + 4 + the eye peek + the Account pane + the T1 guard attempt +
T2's unknown rendering — the "encryption explanation" wave her goodnight cast named), **2b** the
library-ish surfaces (item 14's picker + item 2's Pool + item 17's Snippets), **2c** the modes &
views (item 16's three ruled modes + item 15's Compare/Lenses + item 18's cohesive Book redesign,
which defers WHOLE to 13u2 if 2c cannot hold it). Reason: the ~500k context-degradation rule
applied to implementers — a mid-redesign session death is the worst outcome; her "both waves"
cast language holds (all Fable, sequential, clean seams). Still ONE act, one record trail.

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
  **CONFIRMED at her follow-up, verbatim: "yeah - I did mean a new mode tab slotted after takes in
  the mode row."**
- **AND a note READ surface:** *"a Reading surface SHOULD be added! not the book surface (wouldn't
  make sense for a note like it does for a book) within a book, but the Read surface that you
  can't edit it (but clicking on it brings you to that sentence within index, already open, and
  index tracks position with take / write / probably block too). But the read surface that's only
  verticle or book like - that's the thing that notes have been missing relative to books, is the
  ability to read."* (Direction B, adopted as a read-only mode: vertical/book-like; a click lands
  that sentence in INDEX already open; Index tracks position across Takes/Write/probably Blocks —
  the same scrolled-open-door mechanism as 13u item 17's read-view edit jump, built once.)
  **Her sharpening (follow-up, verbatim): "for the read mode in each individual note, there should
  also be a more minimal outline than 'index' for the read only mode"** — the note's Read mode
  carries a MINIMAL companion outline (the book's small TOC-pane grammar), distinct from the full
  Index mode. She also acknowledged the standing 13u defect in the same breath: *"i do know that
  13u has to fix the defect that already exists in clicking somewhere in read mode not taking you
  to the right location, but I think we have a good plan"* — the book-side jump fix stays 13u
  item 17's; the note's Read click-through shares its mechanism.
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
**Her follow-up ruling: the file is COMMITTED to the repo** (*"let's make sure the mockup file is
also committed to the notes repo as is normal for artifacts that need to survive"*) — the
gitignore line removed, the file tracked from this commit on.

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
the working noun, hers to override. **RULED at her follow-up: "group is also fine."**

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
(recorded either way — never dropped). **HER FOLLOW-UP RULING: (a)/(b)/(c) run TOGETHER as ONE
cohesive Book redesign** — verbatim: *"let's make usre that the index view for books + c (how the
index view reconciles with the small outline pane) go together, since they're all UI changes in
the same Book area, it should be a single cohesive book redesign."* Item 18 never splits across
waves or phases; if it defers, it defers WHOLE. **Her sharpening (follow-up, verbatim): "i'd make
it clear that i do like the more minimal outline to go along with the current modes"** — the
book's small/minimal outline pane STAYS beside the current modes; the index-like view JOINS the
Book area rather than replacing that pane. Two grains, deliberately: minimal outline as the
companion, index as the full view.

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
   mobile-visible"* is not available as an answer for this round. **WIDENED at her sign-off
   (2026-08-31, verbatim: "Remember to update mobile thoroughly at the end with whatever is new /
   required - especially the encryption details / explanation, and the page redesigns"):** the
   closeout writes a SELF-CONTAINED mobile update note (the 14a mobile-update-message precedent)
   beside the MobileSoul row(s), covering AT LEAST: the security-clarity memo's presentation as
   mobile's posture spec (R-pre13u-7(f) — one account, one posture, both platforms; the recipes/
   shapes wording; the escrow/posture coupling the `Shared/` brains already carry), the
   ProtectionLegs exposed-tier faces owed, the new note modes + the cohesive Book redesign (the
   tenth-wave note), the Sherlock answer as built (R-pre13u-8 — the phone's seed + dedupe land in
   Act 0 THIS round), the restore door's phone face, the Snippets/Blocks redesigns' parity
   implications, and the style-guide grammar (her own observation: the mockups match mobile's
   modern feeling — the Mac is converging TOWARD it).
8. **Anything deferred lands in `KnownIssuesAndTechDebt.md` with an owner.** Never dropped back into
   the sweep artifact, which is a dated snapshot and not a tracking surface.
9. **`/Applications/Variorum.app` refreshed** if any Mac app code changed, per CLAUDE.md — and note
   that she does not quit the running app on request, so coordinate.
10. **The iOS target builds** at every batch close and at round end — the R3-2 lesson: the Mac suite
    alone is ZERO signal for `Shared/`.
11. **The three sitting rulings** (B1 · CF-12 · #82) recorded verbatim in the KICKOFF's RULINGS block
    and in `notes/QUESTIONS.md`, and built as ruled.
12. **17a closed in `phase-17-standing-fixes.md`** with per-item dispositions, alongside 17c and 17f.
13. **The security-shapes memo ANCHORED FROM CANON** (memo §9c item 5, her carry): the closeout's
    AppSpec §14 delta names `notes/plans/pre-13u-memo-security-shapes.md` as the binding design
    record of the security shapes/recipes model, so future phases touching these seams (13x, 13y,
    the tier) inherit it rather than re-derive it. Plus the T2 verification line recorded for 13r,
    and the T1 door's ladder verdict (guarded, or a KnownIssues row with an owner).

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

---

# ACTS 3+4 BATCH RECORD (2026-08-31 — the sample library, then the read layer it measures)

**Commits, in order:** `e727e6e` (Act 3 — the seeder, the text, the wiring, ten pins) ·
`e08762b` (**schema `v1_15`, on its own commit** — the P20 index) · `edee416` (Act 4 — P18/P19/P21
and eight pins) · this records commit.

**Order was the point.** Act 3 ran first because Act 4's measurements are supposed to happen against
a real 105k-word book rather than a synthetic fixture, and they did: every note-level number below
comes from the seeded Sherlock corpus on a real on-disk SQLCipher store, and only the corpus-SCALING
numbers come from a synthetic probe (2,000 and 20,000 containers), because twelve notes cannot
demonstrate an asymptote.

## Act 3 — the sample library

**What it really is: 12 stories · 2,530 paragraphs · 104,350 words** (the app measures the seeded
store at **105,335 words / 2,533 blocks** — its own word rule plus the three attribution paragraphs).
Her two targets land in one corpus: ~105k in a book, and a ~10k note (the biggest story, "The
Adventure of the Copper Beeches", is **9,944 words**; the smallest, "A Case of Identity", 6,975).
**Bundle cost: 574,874 bytes — 561 KB** in the app, verified present in the built product's
`Contents/Resources`.

**The text.** Derived from the raw Project Gutenberg #1661 download by
`notes/source/sherlock-extract.py` (committed, so the derivation is auditable and re-runnable): PG
header/footer and the volume front matter stripped per her Gutenberg ruling, `%%% <title>` delimiters
the seeder splits on and never stores. **The unwrapping is the load-bearing part and it was nearly a
defect:** `SegmentationRules.bulkSegments` splits paragraph mode on every non-blank LINE, so shipping
PG's 72-column hard wrapping would have minted **~11,000 one-line blocks** instead of 2,530
paragraphs — a library that proved the opposite of what it exists to prove. Pinned
(`bundledTextIsTheTwelveAdventures` asserts the block count stays in the 2,000–3,000 band).

**Shape in the app.** A curated book, `the adventures of sherlock holmes`, **13 chapters**: a
front-matter chapter `about this text` holding the plain source attribution, then one chapter per
story, one note per story, every note tagged `sherlock holmes`. *The 13th chapter is a judgement I
made and flag for her: her ruling says "ship the public-domain text with a plain source attribution",
and an attribution that lives only in the repo is not shipped — so it is a note inside the book, which
also means the tag really does select **everything**.*

### The six traps, answered

1. **First-launch cost — measured, and the answer is that it is off the path.** The seed sits after
   `AppServices.start()` inside the window's own `.task`; the 562 KB parse runs off the main thread;
   each story is its OWN runner turn, so a reader typing during the seed waits one story's writes
   (~370 ms) and never the library's. **Measured on a fresh dev store, launch → first window on
   screen: 1.25 s with the seed suppressed, 0.96 s with it running, 0.88 s on the already-seeded
   second launch** (CGWindowList polling by PID; the differences are launch noise, which is the
   finding — the seed is not on that path at all). **The seed's own cost, on a real on-disk encrypted
   store: 4.4–4.5 s**, landing 4.3 MB + 1 MB WAL.
2. **Undo — closed.** The seed runs on the QUIET facade (`Operations(undoStack: nil)`, the
   `TutorialSeeder`/`MobileStarterJournal` shape), so twelve `importPost` calls leave the stack at
   depth 0. Pinned: `seedRegistersNoUndoEntry`.
3. **Idempotence — closed, and stronger than asked.** Three guards: a per-store-variant `UserDefaults`
   mark, discovery by reserved book name + tag, and the sync gate. Pinned both ways
   (`seedingTwiceIsANoOp` covers the mark AND, with the mark cleared, discovery). **Plus
   resumability**, which the trap did not ask for but the placement demands: the seed runs from a
   cancellable window task, so discovery reports WHICH story titles are already in the book and the
   seed mints only the missing ones — a window closed mid-seed heals at the next launch instead of
   leaving a half library forever (`aPartialSeedResumes`: 4 stories in, 8 minted, one book, 13
   chapters).
4. **`reading_section` at real scale — what I saw: nothing.** 13 chapters with 13 memberships
   assemble in **0.80 ms** and the chapter resolution is exact (13 distinct `sectionPath`s, no chapter
   holding two notes). This is the first real book the table has carried and it did not notice.
5. **Sync baseline — one line, as asked.** A signed-in new user's first push is now ~105k words of
   ciphertext: **~4.3 MB of store, 2,533 blocks / 2,533 variants / 2,533 placements / 13 memberships /
   13 sections / 13 tag applications ≈ 7,600 rows** before she writes anything. That is the floor
   **13y** should design its per-account quotas against, and it is close to the author's own entire
   corpus at the 14c repush (7,278 rows).
6. **THE PHONE — a proposal, not a build** (nothing mobile-side was touched). **Recommendation:
   ARRIVE BY SYNC; do not seed on the phone.** Three reasons. (a) The phone is a first-class
   birthplace of stores, but a phone-born store that later signs into an account would then carry a
   second library, and the guard that prevents it is the same sync gate whose declining case is
   already the awkward one. (b) The Mac seeds default-on, so any account with a Mac already has the
   library and the phone gets it for free. (c) A phone-only user is exactly the case where 561 KB of
   bundle and a 4.5 s first-launch write are least welcome — and the app's own answer for a
   phone-first store is `MobileStarterJournal`, which is furniture sized for a phone.
   **It interacts with R-pre13u-1** (seed-on-first-write): if the architect wants the phone to seed,
   it should ride the SAME first-write moment the starter furniture now rides, not launch — otherwise
   the phone gains a second launch-time seeding mechanism the round just deleted one of.

### Her two verifications — both pinned

- **The Pool is BLANK on a freshly seeded store** (`thePoolIsBlank`): `Queries.poolPosts` returns
  nothing, because every seeded story is a member of the book. A seeding bug that left the stories
  bookless would have filled a new reader's Pool with twelve strangers, exactly as she said.
- **The `sherlock holmes` tag selects the whole set** (`theTagSelectsTheWholeSet`): 13 posts, the
  stories and the attribution note, so the library is removable in one gesture.

### Does it feel fast? — the acceptance bar

Measured on the author's M3, Debug builds, against the seeded corpus on a real encrypted store:

| Read | Time |
|---|---|
| Book assembly (13 entries, chapters resolved) | **0.80 ms** |
| Library listing (200) | **0.25 ms** |
| Bookshelf | **0.35 ms** |
| Note render — the biggest story, 9,944 words / 212 blocks | **3.44 ms** |
| `takesProjection` — same note | 71.0 ms **→ 32.3 ms after Act 4** |
| Tray takes — same note | 0.95 → **0.80 ms** |
| Pool listing | 0.42 ms |
| Trash listing | ~2.0 ms |
| One autosave inside the biggest story | **2.6 ms** |

**P1 verdict: it holds.** Every read above is proportional to the note or the page, not to the
corpus, and the two that were NOT — `trayTakes` and the classifier — are Act 4's fixes. Opening a
10k-word story costs 3.4 ms; typing in it costs 2.6 ms per autosave. **One honest exception, recorded
as a finding rather than polish:** `Queries.bookWordCounts` — the shelf's word/progress aggregate —
costs **172–178 ms** on this corpus because it reads every block of every book. It is a deliberate
ONE-SHOT (off-main, on shelf appearance, never held), so nothing re-runs it while she types and the
shelf renders before it lands; what changed is that the sample library makes it **every new user's
floor** rather than a mature corpus's. New `KnownIssuesAndTechDebt.md` row, owner **12**.

### For 13i — the wing line (recorded here for the closeout to carry)

**The sample library should become its own WING, removable in one gesture.** It is the cleanest first
citizen of the wings design: a whole room of someone else's writing sitting in Home, beside her
journal and the tutorial, is exactly the "different room in the same house" case. Today it is a book
plus a tag, and the tag is what makes it removable as a set; a wing would make removal one gesture and
would keep 105k words of Conan Doyle out of every Library and Pool listing she scrolls. *(Recorded for
the architect to place on the 13i brief — this batch deliberately did not edit that file.)*

### Open calls the architect may want to make (nothing was invented)

- **No restore door.** Deleting the library is final, following her ruled starter-journal shape ("if
  they delete that journal book … it just doesn't appear at all"). The tutorial has Help ▸ Restore;
  whether the sample library deserves one is a product call, not mine.
- **A signed-in device whose sync never lands cleanly never seeds.** The gate declines and re-asks
  each launch (observed live on this machine's dev store, which is account-owned and does not complete
  a round — the seeder logged `awaitingFirstSync`). Correct by design — the alternative is duplicating
  a library that is about to arrive — but it means "default-on" is "default-on once sync has spoken"
  for account-owned stores. The one-line logger (`subsystem io.lduarte.Variorum`, category
  `sample-library`) exists precisely so this question is answerable in the field.

## Act 4 — 17c's four items

**All four FIXED, each with a red-on-old pin verified by reverting the fix** (behaviourally, for P19,
so the new API stayed compiled). Per-item dispositions with before/after numbers are written into the
**17c entry** of `notes/plans/phase-17-standing-fixes.md`, and its register row is flipped to closed.
In brief:

| Item | Before → after | Pin, red on old |
|---|---|---|
| **P18** trayTakes scanned `variant` | ordinary 1-block note 0.836 → 4.783 ms across a 10× corpus; after **0.472 → 0.470 ms, flat** | plan must not contain `SCAN v` — red on old |
| **P19** Trash peer N+1 | 15 versions at 20k containers **551 → 15.0 ms** | statements for 1 vs 10 versions must be equal — red on old (6 vs 16) |
| **P20** classifier had no index | plain note 0.374 → 1.791 ms across a 10× corpus; after **0.215 → 0.218 ms, flat** | plan names `idx_container_note_version` — red with the index dropped |
| **P21** activeFans one query per block | 40 blocks: **40 statements → 1**; `takesProjection` 71.0 → 32.3 ms | statement count — red on old |

**The P20 index is LOCAL and is NOT a §12 lockstep event** — the Postgres mirrors carry no indexes
beyond the PK by design (SyncSpec §2), so nothing on the wire changes and **the marker stays 7**, as
this plan's own line said it would. It still took its own commit ahead of everything that uses it.

**One residual, recorded with an owner rather than smuggled in:** P19's single pass is still linear in
the corpus, because the peer note is reached through `container_block` BY BLOCK ID and the only index
there is the live-rows partial one, while the lookup must stay tombstone-insensitive. Closing it needs
an index on `container_block(block_id)` — a second schema change on a busy table, so it is a
`KnownIssuesAndTechDebt.md` row owned by **12**, not a drive-by.

**The verifier's temperings held up and the record says so:** P20's real-world consequence is
single-digit milliseconds (its value is that the WRITE path's shape becomes flat), and P21 is a
constant factor rather than a P1 break. **P18 was the sharpest of the four** — corpus-linear on an
ordinary ONE-BLOCK note, which is what made its "never the corpus" doc claim false rather than
optimistic. All three false doc comments the sweep named are corrected in place.

## Verification at close

- **Core `swift test`: 1465 tests / 155 suites, GREEN** (baseline 1457/154; +8 pins in one new suite).
  Three consecutive clean runs; one earlier run reported a single issue that did not reproduce in
  three subsequent full runs and could not be identified from the output.
- **Mac suite: 1897 tests / 321 suites** (baseline 1887/320; +10 pins in one new suite) with **one
  failure — the known load-flaky `EditorWindowSmokeTests.rewriteStrategyLatencies`** at 52.98 ms
  against its 50 ms budget. **Adjudicated PRE-EXISTING, and this time demonstrated rather than
  inferred:** it fails ISOLATED too (51.9–53.8 ms over four runs), and the **pre-round baseline commit
  `626c8c2` was checked out into a worktree, built, and run under the same load: 52.53 ms.** Load
  average 12–20 on a 42-day-up box with her live app running. The KnownIssues row gains this as its
  first both-trees-actually-built covariate.
- **Tutorial spine green** inside the full run (every `Tutorial …` suite passed).
- **iOS target builds** (`xcodebuild build -scheme VariorumMobile`) — mandatory because `Sources/` was
  touched.
- **Zero `Sources/VariorumCore/Sync/` lines**, diff-verified; one schema change, in its own commit;
  lockstep marker unchanged at 7.

---

# ACT 5 BATCH RECORD (2026-08-31 — 17f: dead code, canon corrections, and the pins that could not fail)

**Commits, in order:** `8bb0185` (P42 — the crystallization-kind hoist) · `0c20c4f`
(P43·P44·P45 — dead code out, two contracts corrected) · `130a9b6` (P46 — the canon
correction) · `72232e2` (P47·P48·P49·P50 — the four pin items) · `6ee0451` (P47's mobile
twin) · this records commit.

**Nine items, eight FIXED, one DISMISSED AS HOLLOW.** Per-item dispositions with evidence
classes live in the 17f entry of `notes/plans/phase-17-standing-fixes.md`; this record
carries the numbers, the drills, and what now binds.

## The four test findings — what changed and what proves it

**All three fixed pin-items were drilled red-on-old**, because a pin that cannot fail is
exactly what this act is about, and adding one without proving it fails would have repeated
the defect in a new place.

- **P47 (both platforms).** Drill: delete `Text(ProtectionCopy.openAppIsReadable)` from
  `ProtectionPane.modeSection` and the dead-end `Text` from each lobby → **3 of 4 Mac pins
  red, 2 of 3 phone pins red**, and in both cases the roads-exist complement correctly still
  passes (it asserts the dead end's ABSENCE). Before this act, that same deletion left the
  entire repo green.
  **Two measured dead ends, recorded in the test file so they are not re-attempted:** the
  hosted view's **accessibility tree is empty** in this environment (`NSHostingView` reports
  0 subviews, 0 accessibility children) and **`dataWithPDF` captures nothing** (layer-backed
  ⇒ nothing draws through `draw(_:)`; 833 bytes, no text). What works is reflecting the real
  `body` — and the property that makes it a composition pin rather than a source grep was
  verified, not assumed: **an untaken `_ConditionalContent` branch is ABSENT** from the dump
  (a lobby with roads carries no dead-end sentence). One mechanical note carried in both
  files: `dump` escapes non-ASCII, so sentences are matched through `String(reflecting:)`,
  never against the raw literal — the reason a first pass reported false negatives on exactly
  the sentences containing typographic apostrophes.
- **P48.** Drill: a synthetic 4.38× library-page regression **PASSES under the old 2 ms
  floor** — the run log printing `bound by BUDGET 2.0ms` — and **FAILS under the new
  budget**. That is the finding's own example, made falsifiable.
- **P49.** Drill: skip one registered table's trigger pair in `createOutboxCapture` → the pin
  fires naming the table and the consequence ("its rows would never leave this device and
  nothing anywhere would say so"). **Zero `Sources/VariorumCore/Sync/` lines** — the test
  imports the registry and reads `sqlite_master`; the rider is intact, diff-verified.
- **P50 — dismissed as hollow, by measurement, not by argument.** The claim was that
  `lock()` closes the last connection so SQLite checkpoints the WAL away before the scan.
  Probed on this tree: the WAL measures **1,100,072 / 1,153,632 bytes BEFORE `lock()` and
  the identical byte counts AFTER it**, frames intact — so the scan has always read real WAL
  content and the belt was live. Reordering it (the finding's proposed fix) was written,
  measured to be unnecessary, and **reverted**. What survives is the one real (latent) hole:
  `if let … try?` meant a missing WAL would make the assertion vanish silently, so the read
  is now hard and the frames are asserted present — if a future change ever does checkpoint
  the WAL away here, it says so rather than quietly becoming the dead belt.

## WHAT BINDS IN EACH P1 BENCHMARK AFTER P48

The assertion shape is unchanged (`large ≤ max(small × factor, budget)`, factor 3.0); what
changed is that the **budget is derived (2 ms → 1 ms)**, every run **prints the ratio and
names the binding term**, the failure message names it too, and the five query pins are
renamed **flat-OR-under-budget** so no name claims what the gate does not enforce
(`autosaveIsFlatInPostLength` keeps its flat name — see below).

Budget derivation: measured large-corpus medians across two hosts (a quiet one and this
machine under agent load) span **0.32–1.27 ms**. 1 ms sits above the cheapest (`library`,
0.32–0.40 ms) and **below the dearest** (`timelinePage`, ~1.27 ms), so at least one pin is
always ratio-bound and the budget can never become the suite's only teeth. It does not flake
because it binds **only when `small × 3 < 1 ms`** — i.e. on a host fast enough that the
correlated large median is far below it; the uncorrelated-spike case is what the median of 20
iterations absorbs.

| benchmark | measured (small → large, full-suite run) | what binds NOW |
|---|---|---|
| `postRenderIsFlatOrUnderBudgetInCorpusSize` | 0.817 → 0.831 ms (1.02×) | **RATIO** (bound 2.45 ms). Budget-bound only if the small median drops under ~0.33 ms |
| `readingAssemblyFirstPageIsFlatOrUnderBudgetInCorpusSize` | 0.745 → 0.716 ms (0.96×) | **RATIO** (bound 2.23 ms); same fast-host caveat |
| `timelinePageIsFlatOrUnderBudgetInCorpusSize` | 0.766 → 1.258 ms (1.64×) | **RATIO, always** — its large median exceeds the budget, so the budget is inert here. Its 1.6× is a real keyset-seek difference, stable across every run, well inside 3× |
| `libraryPageIsFlatOrUnderBudgetInCorpusTextSize` | 0.401 → 0.397 ms (0.99×) | **RATIO on a loaded host (1.20 ms), BUDGET on a quiet one (1.0 ms)** — the cheapest probe, and the finding's example. Worst-case tolerated regression drops from **6.45× to ~3.1×** |
| `tagSubtreeIsFlatOrUnderBudgetInCorpusSize` | 0.831 → 0.833 ms (1.00×) | **RATIO** (bound 2.49 ms) |
| `autosaveIsFlatInPostLength` | 1.718 → 1.720 ms (1.00×) | **RATIO, always** — its own 1 ms floor cannot bind against a ~1.7 ms control, which is why this one keeps its flat name |

Every one of the six was **RATIO-bound in the full-suite run** (i.e. under load), which is
also the stability evidence: the tightened budget never became the binding term in the
conditions the suite actually runs in.

## The other five items, briefly

- **P42** — the mode → kind rule now lives once in `Shared/EditorBrain/CrystallizationPlanner`
  and is called from all five sites (Mac ×3, phone ×2). Both factories **switch exhaustively**,
  so a fourth segmentation mode becomes a build failure at the one place that decides rather
  than five silent fall-throughs. Evidence: grep 5 → 0 duplications, four new pins, iOS builds.
- **P43** — `fanAction` + `enum FanAction` + `loadFan`'s per-open store read + two unread
  `FanPanelState` fields removed; `openFan` is synchronous. `FanPanelState` itself stays (the
  sheet's `item:` binding — the verifier's correction to the finder). The test that was the
  dead code's only caller is **re-pointed onto a live door** (⌘⇧A `archiveCaretTake` on a last
  active take), so the suite now guards a refusal the app can actually reach.
- **P44** — no cap invented. `removeAll()` is not dead (four test call sites); what was missing
  was the statement that it has **no production caller and deliberately none**, which it now
  carries, alongside the retention fact at `entries` (bounded per act by the edit ⇒ P1's letter
  holds; session-scoped, never persisted). **ARCHITECT NOTE:** a retention ceiling for the undo
  stack is a *product* call — how far back can she undo — and nothing measured says one is
  needed, so this is raised here rather than opened as a KnownIssues row.
- **P45** — `BoundarySnapping.snap` and its four tests removed (zero production callers, kept
  green by its own tests while `divide`'s doc named it as the contract); the divide doc and the
  planner header now name `settle`, the rule that actually ships.
- **P46** — AppSpec corrected 24 → 2 in **both** stale places (§7's seed comment and §9's
  `idleAutoCommit`), each citing 13j's J11 ruling. Canon aligned to an already-ruled value;
  nothing else in canon touched.

## Verification at close

- **Core `swift test`: 1464 tests / 156 suites, GREEN** (baseline 1465/155 — arithmetic:
  −4 `snap` tests, +3 trigger-coverage pins, +1 new suite). Three consecutive clean runs; an
  earlier run reported a single issue that did not reproduce and could not be identified from
  the captured output — the same shape the Acts 3+4 record notes.
- **Mac suite: 1905 tests / 322 suites** (baseline 1897/321 — +4 P47 pins, +4 P42 pins, +1
  suite) with **one failure: the known load-flaky
  `EditorWindowSmokeTests.rewriteStrategyLatencies`** at 50.88 ms against its 50 ms budget.
  **Adjudicated PRE-EXISTING — and this act's diff touches `EditorViewModel`, so it was
  adjudicated by measurement rather than by assertion.** Isolated re-runs on the current tree
  swung 85.8 / 78.8 / 58.4 ms and one pass, so a single reading proves nothing; an
  **interleaved paired comparison** against the pre-act commit `58e98c6` (built in its own
  worktree, alternating base/current to control for load drift) reads:
  **BASE 45.6 / 38.7 / 42.7 ms · CURRENT 39.8 / 39.7 / 39.5 ms** — the current tree is if
  anything faster and steadier, and both pass the budget when the box is quiet. The
  KnownIssues row gains a second both-trees-built covariate, and its remedy now has paired
  calibration data.
- **Tutorial spine green** inside the full run (all ten `Tutorial …` suites passed).
- **iOS target builds** (`xcodebuild build -scheme VariorumMobile`) — mandatory, `Shared/` was
  touched by P42.
- **Mobile targeted run green: 3 tests / 1 suite** (`MobileProtectionSurfaceTests`, iPhone 17 /
  iOS 26.2). The full mobile suite stays a round-end act.
- **Zero `Sources/VariorumCore/Sync/` lines**, diff-verified; **no schema**; lockstep marker
  unchanged at 7.

---

# ACT 10 WAVE 1 RECORD (2026-08-31 — the mechanical/polish items, Fable implementer)

**Commits, in order:** `61a5acf` (item 11) · `0e6a09e` (item 1 + `CalmGrammar.swift`) ·
`01af914` (item 12) · `a977247` (items 9+13) · `1dc7cba` (item 5) · `dcb620d` (item 10) ·
`e243c1a` (items 6+7) · `6da4600` (the Sherlock restore door) · `42eda78` (item 7's
endpaper finish) · the closing verification/record commit. All pushed.

**The style guide rode every touched surface** (W8-2/W8-3): `CalmGrammar.swift` in `Theme/`
is the mockup grammar as chrome vocabulary — `CalmCard` (radius-10 bordered cards on the
card surface, wash selection), `CalmSectionHeader` (an ordinary stacked header that CANNOT
be clip-measured), `CalmButtonStyle` (the mockup's squarish-rounded generous `.btn`, with
primary/danger roles), and `MarqueeText` (ellipsis at rest, stereo-scroll on hover). It
COMPOSES with VoiceControls (still the quiet-word vocabulary); 13u2 inherits the app-wide
continuation from this one file instead of per-view archaeology.

## Per-item verdicts

- **Item 1 — This Note's Tray: FIXED + restyled.** Traced class: the panel was a plain macOS
  `List`, whose fixed section-header measurement clipped the Leaving header (title + multi-line
  explainer) to the sliver her screenshot shows. Rebuilt as a ScrollView of calm cards —
  the mechanism dies by construction. Order judged in place under the granted latitude:
  **LEAVING first** (what is counting down is what she opened the tray for), takes fold, then
  ARCHIVED. Pin `TrayPanelShapeTests.everySectionRendersUnclippedComposition` —
  **revert-verified red-on-old** (the old body reflects `List<` and fails 5 ways) — over a
  REAL ops-seeded store (deleted block · archived block · deleted take). Screenshot-verified
  (`22-tray.png`): nothing clipped at 420 pt, full explainer, generous Put back doors.
  *Small note:* the quiet meta line truncates its tail at narrow widths (countdown label) —
  the preview deliberately wins (the P-1 squeeze lesson); a 2-line meta is a one-line change
  if she wants it.
- **Item 5 — tags out of the nav bar: BUILT.** `MastheadTagCluster` (Features/Tags) renders
  the cards + the ＃ fold on the masthead's right edge, directly under the tray/scraps/
  references icons, across from the membership chip — one coherent right edge (designed with
  item 10). The context bar's constant row is **← · book · →** + the tray badge.
  **The "+ tag" call (hers, delegated): taken.** The masthead's add door reads **"＋ tag"**
  (room to be generous there); the Library rows keep the bare ＋ (dense listing — exactly her
  clutter hedge). One preference (`TagChipsFold`) and one type-to-create door
  (`applyTypedPath`) — addresses moved, zero semantics. **13k K11/K12 SUPERSEDED IN PART by
  her ruling** (recorded in `ContextBar.swift`/`ContextBarDoors.swift` and here): the icon
  row is three doors; the fold and the cards live at the masthead. `.tagNote`/`.toggleTagChips`
  moved renderers; the registry walk union gained the cluster (the E2/E8 justified-edit
  convention). ⌘⇧I unchanged. Screenshot-verified (`05-crop-top.png`).
- **Item 6 — the bottom bar spreads back out: BUILT.** The collapse decision is pure
  (`CommitBar.usesTwoRows`), the threshold measured down **1080 → 840** (the one-row content
  runs ~800 pt in the wider monospace voice), and the two-row fallback's first row now
  carries the counts on the right (her screenshot's empty-right fixed). Pin
  `CommitBarLayoutTests.ordinaryWidthsKeepOneRow` — **red-on-old at 900 pt**.
  *Visual note for the midpoint walk:* in the DEV-STORE walk the bottom bar did not render
  at all — **on the PRE-WAVE binary too** (stale-build reproduction, `03-bottom.png`), so it
  is NOT this wave's regression; a headless probe measured the hosted `EditorView` reserving
  exactly the bar's 31 pt (969+31/1000), so the bar is healthy in isolation. Her own Aug-30
  screenshot SHOWS the bar in her real build. The midpoint review should check the bar in
  HER app; if it renders there, the dev observation is an environment/state condition of the
  fresh dev store and nothing more.
- **Item 7 — the lobby refresh: BUILT + screenshot-verified** (`21-lobby5.png`). Her floated
  direction taken literally: the brand's TESSELLATING `girl-and-the-fan` (TASTE.md's named
  seamless endpaper; the fan is the brand image) tiles the room at a 340 pt grain —
  **rasterized at load: an SVG rep tiles as NOTHING in SwiftUI (measured)** — washed to an
  undertone; the calm card (W8-2 grammar) sits in the UPPER THIRD, clear of the centered
  system Touch ID dialog; under a Biometric demand only the Touch ID road shows and the
  passphrase field arrives on demand behind one quiet word; recovery stays behind the
  disclosure. Every sentence is the standing `ProtectionCopy` brain's — zero copy changes.
  All four P47 lobby pins hold unmodified. *Taste dial noted for the morning:* the pattern's
  presence is set by two opacities in `StoreLockView` (art 0.55 / wash 0.35 light; 0.08/0.5
  dark) — one-line tuning if she wants it quieter or louder.
- **Item 9 — tabs overflow: FIXED (her ruled shape).** `OpenNotes.shown` is EVERY open note
  (the prefix window died); the strip left the List for the sidebar's BOTTOM RAIL, ~7 rows
  tall then scrolling in place, with the newcomer auto-revealed (`ScrollViewReader` on the
  recency head). The dead "…N more open" label died WITH the hidden set — every open note is
  its own clickable row, strictly more door than the label ever was (the ruled
  no-dead-label shape). **⌘⇧1–9 are a KEY cap** (`ordinalCap` — renamed with its meaning),
  badges on the first nine rows only. **The ruled 20-tab auto-close built**
  (`trackedCap = 20`; the 21st closes the least-recently-OPENED — a tab is a pointer,
  nothing lost). Manual reorder now covers every row, via the strip's own transfer type
  (`OpenNoteDragToken` — deliberately not a String, so a dragged row can never be imported
  as text by the sidebar's plainText drop). Pins: `aNewlyOpenedNoteIsAlwaysShown` —
  **revert-verified red-on-old** (prefix restored → 4 failures) — + the 20-cap and
  reorder-reach pins; the old shown/hidden pins updated DELIBERATELY with supersession notes.
- **Item 10 — the transition + the context-aware right panel: BUILT (her click model
  exactly).** Row-body click SELECTS and shows `LibraryInfoPanel` (the dead highlight now
  means something); TITLE click opens instantly as today; DOUBLE-CLICK anywhere opens (it
  weirdly didn't — now routed before the single-tap). Books get the same model
  (`selectBook`). The panel is per-kind: a NOTE shows words · blocks · with-takes · comments
  · entry/edited/created days · its books · its tags; a BOOK shows kind+finished · notes ·
  chapters · word target · cap · created — one-shot reads (the NoteCards discipline;
  `Queries.wordCount` is the one counting rule). The panel is the note-side inspector's
  WIDTH SIBLING (min 280/ideal 420) and both sides now animate their coming and going
  (the never-teleports principle; PostDetailView's toggle wraps in `withAnimation`).
  A multi-pick summarizes and points at the header's bulk doors. The pick follows the
  LISTING (prune covers the panel too). **QUESTIONS #79's plain-click PROVISIONAL is
  superseded by her own ruling** — noted at #79. Pins: the reworked
  `NoteRowSelectionRuleTests`/`NoteRowRoutingTests` (13/13, including
  `aPlainClickSelectsAndShowsTheInfoPanel`).
- **Item 11 — the checkbox scroll-jump: FIXED, mechanism TRACED (it was unknown by her own
  words).** The trace: a checkbox click runs `MarkdownActs.toggleCheckbox` BEFORE
  `super.mouseDown`, so the CARET is still wherever it was before the click — after a
  writing session, the document's END. The toggle's storage edit calls `didChangeText()`,
  which runs `TypewriterScrollView.keepCaretClearance` — β1's typing-follow (armed by
  default) — which computes the CARET's line bottom and scrolls down to it: the absolute
  bottom, exactly her report. β1's own doc premise ("a click near the bottom of the page
  never makes the view jump") missed the click-that-edits case. Fix: the toggle's mutation
  runs under `withoutCaretFollow` (the `withSoftNewline`/`isPasting` idiom) — a click's edit
  never drags the view to the caret; typing/paste/delete keep the clearance byte-identically.
  Pin `CheckboxScrollTests.togglingACheckboxPreservesScrollAndCaret` — **red-on-old at a
  measured 6,103 pt jump**, green with the fix; box toggles and caret preserved either way.
- **Item 12 — typed arrows: BUILT (one brain, shareable).** `TypedArrows` in core Domain
  (pure, line-scoped for P1): `->` → → and `<-` → ← at type time; **never inside a code
  span** (the shipped F-3 vocabulary has inline code only — fenced blocks are not a concept
  the app has, so the span guard is the whole code guard); `-->`/`<<-` stay literal
  (recorded deliberate non-matches); UTF-16 arithmetic pinned against emoji prefixes. Mac
  face: both writing surfaces (`EditorTextView` + `PaneTextView`) hook `insertText` after
  `super` — the K5 trio shape — applying on the substitution's OWN runloop pass and sealing
  the typing coalescing on both sides, so **⌘Z reverts just the substitution** (the
  smart-quotes convention; the split rides real event turns, verified at the mechanism level
  by `theSubstitutionIsItsOwnUndoableEdit` — the full two-step convention is unpinnable in
  the harness, whose event undo-groups never close: measured, recorded in the test's doc).
  **Hardened live:** a zero-gap keystroke burst landed the next key before the deferred pass
  and the live-caret check declined — the substitution now ANCHORS at the typed pair
  (`aFastBurstStillEarnsItsArrow`, revert-verified red-on-old). **Verified in the RUNNING
  app** (`10-crop.png`: "in the editor e → f, back f ← e"). **The entanglement verdict:
  NOT entangled with `MarkdownActs`' arming flow** — the second edit takes the proven K5
  lead-insertion shape (its own `shouldChangeText` → consume), no verdict is armed-without-
  consuming; built here, no deferral to 13u1. *Boundary recorded:* the QUICK-ENTRY bar is a
  TextField, not a writing surface — text typed there (and handed off) stays literal by
  design; the capture surface's ownership is 13u's standing question. **Up/down arrows —
  PROPOSED ONLY (nothing built), her nod required:** candidates `-^` → ↑ and `-v` → ↓ (the
  `->` family's own grammar: dash + direction glyph; `-v` risks colliding with words ending
  "-v" far less than `^`/`v` alone would); alternative `|^` / `|v`. Her pick or veto at the
  morning bundle.
- **Item 13 — the Starred sidebar row: BUILT.** Exactly ONE star — blue, on the RIGHT (her
  lean, confirmed in place: the right star is also the un-star door, so the mark and the act
  live in one spot). **A `star` token joined the four voice palettes** (Terminal reuses its
  blue ring hue; Study its blue accent — neither accent nor ring could serve alone: Terminal's
  accent is green, Study's ring is orange; the mockup draws the star blue in both voices,
  W8-2). Titles: ellipsis at rest, **marquee-scroll on hover** (`MarqueeText`, "stereo
  style"); more air above the section (＋14 pt). P-8 holds throughout.
- **The Sherlock restore door (tenth-wave ruling): BUILT.** `Help ▸ Restore the Sample
  Library` + the ⌘K row (`.restoreSampleLibrary`, registered with the E2/E8 walk
  conventions), riding `SampleLibrarySeeder`'s RESUMABLE seed — it mints only what is
  MISSING (a deleted book comes back whole; surviving edited copies untouched), so unlike
  the tutorial's replace **no confirm gates it**; fire-and-DO, opens the book, failures
  speak.

## The walk's captures (gitignored `notes/plans/pre-13u-act10-screens/`)

`05-crop-top.png` (item 5's right edge) · `10-crop.png` (live arrows) · `21-lobby5.png`
(item 7) · `22-tray.png` (item 1) · `cal.png` (the solid sidebar + the new bottom-rail Open
strip — W8-3's flat column visible) · plus the trace/calibration frames. **Folded into the
midpoint review's walk** (capture practicalities, recorded honestly): the library info
panel + click model in motion, the starred marquee under a real pointer, the Open strip
past 7 with drag reorder, the bottom bar in HER app (see item 6's note), dark-mode passes
of the restyled surfaces (legible by token construction; not eyeballed).

## Environment notes (for the orchestrator)

- **The DEV store was found unopenable at wave start** — `sqlcipher hmac check failed
  pgno=1` in the very first test run's host launch (07:24, BEFORE any wave code ran in an
  app context), the failure surface offering no sidecar road. The broken file is SET ASIDE
  as `variorum.sqlite.broken-2026-08-31` in the dev container (bytes preserved for the
  morning if anyone cares); a fresh dev store minted for the walk and opens cleanly. Her
  REAL store/app untouched (never launched; the walk used the Debug dev build only).
- A leftover crashed test-host instance (the arrow suite's NSUndoManager exception during a
  test-harness experiment) was killed; two Problem Reporter dialogs from earlier agents'
  overnight work were left on her screen untouched.
- **The Sherlock launch-seed did not fire in the dev walk** (0 books after writes on the
  current binary) — possibly the R-pre13u-1 first-write moment's gate on this dev store, not
  investigated further (the seeder's own suite is green; the log line to check is
  `category == "sample-library"`, which showed nothing in the walk window). Worth one look
  at the midpoint review.

## Taste forks for the morning bundle

1. **Tray section order** — Leaving above Archived (my call; the reverse is a two-line swap).
2. **"＋ tag" vs "＋"** — labeled door in the masthead, bare ＋ on dense rows (her delegated
   call, split by context; unify at her word).
3. **The lobby's pattern presence** — two opacity dials, currently a visible-but-calm
   endpaper; louder/quieter is one line.
4. **Up/down arrows** — proposals only (`-^`/`-v`, alt `|^`/`|v`); nothing built.
5. **The Open strip cap badges** — rows past nine carry no ⌘⇧ badge (the keys stop at 9);
   an alternative is dimming, not hiding.
6. **The library info panel's fact set** — my latitude pick (words/blocks/takes/comments/
   days/books/tags; books get notes/chapters/target/cap); swap freely.

## Verification at close

- **Core `swift test`: 1484 tests / 159 suites, GREEN.**
- **Mac suite: 1919 tests / 327 suites, GREEN — zero failures** (baseline 1908/323; the
  arithmetic is exact: +11 pins in +4 suites — CheckboxScroll 1 · TypedArrowFace 6 ·
  TrayPanelShape 1 · CommitBarLayout 3). The known load-flaky latency pin PASSED in this
  run (no adjudication needed); the canvas suite passed in-suite. The tutorial spine green
  inside the full run. Three standing pins were updated DELIBERATELY for moved cheese, each
  carrying its supersession note: the ContextBar declaration pins (the tags' acts moved to
  `MastheadTagCluster`, asserted from both sides) and the tray-move walk's List-class
  anchors (the List is the retired clipping mechanism; the panel's composition is
  `TrayPanelShapeTests`' pin now).
- **iOS target BUILDS** (`VariorumMobile`, generic/platform=iOS) — mandatory: core
  (`TypedArrows`) and `Shared/` (`VoiceTokens`' star token) were touched.
- **Zero `Sources/VariorumCore/Sync/` lines** (diff-verified: the wave's only core change
  is `Domain/TypedArrows.swift` + its tests); **zero schema**; lockstep marker untouched.
- Every red-on-old pin was verified by BEHAVIORAL REVERT (the checkbox suppression, the
  tray List, the OpenNotes prefix window, the bar threshold, the arrows burst anchor —
  each re-run red on the reverted code, then restored).

---

# ACT 10 WAVE 2a RECORD (2026-08-31 — the protection/clarity wave, Fable implementer)

**LIVE STATUS SECTION — updated per commit while the wave runs** (the session-limit
protocol: the coordinator warned at 87%; this record is written mid-flight so a fresh
successor can resume from the repo alone. A line marked PENDING is UNVERIFIED; a line
marked IN-PROGRESS names exactly what remains).

**Machinery honesty:** the original wave-2a session DIED mid-Group-B on a transient API
auth error ("Not logged in") and was resumed by a successor with the same brief; the
working tree survived (one uncommitted StoreProtection.swift edit), zero work lost. The
recon subagent it had spawned completed after the death; its coordinates were relayed by
the coordinator (no re-derivation). No further subagents were used.

**Binding spec:** `notes/plans/pre-13u-memo-security-shapes.md` (the memo WINS over any
other block); Act 10 item 3 + item 4 + the NINTH WAVE'S CLOSING RIDERS block above;
render-don't-re-derive (§9c item 3) binds every surface below.

## Commits, in order

- `b177571` — **THE COUPLING (memo §4, the ONE behavior change): DONE.**
  `ProtectionDials.effectiveEscrowOn` is the one rule; custody acts on it at the mode
  transition itself (`reconcileEscrowToPosture`), at every ready-launch reconcile, and at
  the dial door; the stored dial keeps her Auto choice. `lossLegs`/`lossMath` stop listing
  a spare the posture removed (passphrase-mode escrow arm collapsed, supersession
  recorded). Faces: Mac pane + phone sheet stop offering the dial under demanded modes,
  speak `escrowNotOfferedUnderDemanded` (her why-sentence, near-verbatim) + the
  kept-choice note; `ProtectionShapes.compoundWarning` rides the ON state on both.
  `escrowUnderDemandedMode` superseded; its copy-sweep pin RE-ANCHORED (never deleted);
  the mobile composed-from-legs pin superseded deliberately (posture-aware iCloud claim).
  **Pins: `EscrowPostureCouplingTests` (7 tests) — REVERT-VERIFIED RED-ON-OLD** (probe
  reverted `effectiveEscrowOn` + the lossLegs coupling: 5/7 red, 10 issues — the spare
  survived into biometric and `escrowVerifiedLanded` stayed true; the two that stayed
  green pin the face and the dial-door branch, mechanisms outside the probe). Restored
  green 41/41 across the touched suites; Mac + iOS targets build.
- `018d6ee` — **THE EYE/PEEK CONTROL (item 3): DONE.** `PeekableSecretField` (Shared);
  adopted at EVERY passphrase-family field: set/reset sheets, SecretCheck's passphrase
  arm, Mac lobby + failure surface, all six EncryptionViews fields, the phone's
  ceremonies/lobby/failure. AuthViews' account-password trio deliberately stays plain (a
  different secret family). Both targets build. No dedicated pin (a chrome control;
  behavior rides existing surface pins) — the midpoint may add one if wanted.
- `232b090` — **WIP:** `ProtectionShapes.checklistRows(_:mode:)` joined the shared brain
  (the checklist's row model, three-value escrow truth, posture-aware). Compiling; no
  face consumes it yet.

## Piece-by-piece status (the successor's map)

1. **`ProtectionShapes.swift` (Shared) — the memo brain: DONE** (b177571 + 232b090).
   Keystone lines essentially verbatim: `oneLaw`, `deviceAsPowerfulAsPassphrase` (Touch
   ID keystone), `syncSentence` (ratified, verbatim), `spareKeyIsAKey` (key-not-backup +
   never-a-remote-sync-key), `resetRoad` ("passphrase is still the path"),
   `compoundWarning`; the recipes (`openRecipes`/`opensNothingAlone` + the two new-device
   rows split per seventh wave (i)); `demandedFallbackTruth` (seventh wave (ii)); the
   three-row `shapes` summary (the ONLY table) with per-shape who-this-stops + the TWO
   what-ifs; the four `needStates` (§5) + `currentNeedState`; `tierSentence` (T2's three
   values, three sentences); `escrowLegSentence` (per-leg three-value truth);
   `checklistRows`; `unchosenIndicatorLabel/Detail` (NEVER "encryption off");
   `lockMomentFraming` + `syncSignupFraming` (the two ceremonies).
2. **The coupling: DONE** (b177571, above).
3. **The pane restructure (Mac ProtectionPane) — DONE.** The live checklist section
   LEADS the pane (rows from `checklistRows` + `tierSentence` + the current-mode
   what-you-need pair); the mode stack collapsed behind "More about what this protects"
   — the NAMED `ModeHonestyDisclosure` view (oneDeviceNote + openAppIsReadable + the
   demanded-arm `demandedFallbackTruth`); modeSentence + lossMath stay visible; the
   explainer-pointer section closes the pane. **P47 RE-ANCHORED with the supersession
   note** (`theSettingsPaneShowsTheOpenAppIsReadableDisclosure` asserts pane essentials
   + the door, and hosts the disclosure view directly — never deleted); NEW pins
   `thePaneLeadsWithTheLiveChecklist` + `theExplainerCarriesTheKeystonesVerbatim`.
4. **The explainer tab — DONE.** `ProtectionExplainerView` (Shared, plain styling —
   phone-legible) renders the whole memo brain: oneLaw → recipes + spare-key corollary →
   opens-nothing-alone → the two new-device rows + resetRoad + the ratified syncSentence
   → the three shapes as cards (Shape 3 badged "not offered") with per-shape
   who-this-stops + BOTH what-ifs → the four needStates + demandedFallbackTruth +
   compoundWarning → the field-guide pointer BY NAME (the live cross-scene door is
   taste-fork 2). Mounted as Settings ▸ "How Protection Works";
   `theExplainerCarriesTheKeystonesVerbatim` pins BOTH halves (byte-exact keystone
   content + surface carriage) — piece 14's confirmation mechanism, already green.
5. **T2 unknown rendering — DONE.** The pane's checklist renders the three-value truth
   (piece 3); the phone sheet gained the standing ways-back-in line (the same brain —
   `waysBackInLine(controller.legs)` in the mode section, R-pre13u-4's letter).
6. **The nudge tier-awareness (R-pre13u-4's faces) — DONE.** `nudgeBar` consults the
   tier: exposed renders the hardened device-neutral pair, covered keeps the gentle
   two-offer copy, unknown stays suppressed. Pinned both ways
   (`ProtectionTierFaceTests.theExposedNudgeSpeaksTheHardenedCopy` +
   `aCoveredNudgeKeepsTheGentleCopy`).
7. **The unchosen-state indicator (memo §6) — DONE.** `ProtectionStatusRow` (Mac) leads
   the sidebar's bottom status family (above Sync/Bridge); renders ONLY while the choice
   is genuinely unmade (Auto + no secrets + facts readable); tier-true detail (exposed →
   the hardened headline in alarm ink; covered-unchosen → the calm lock-and-keys line);
   opens Settings; NEVER "encryption off" (pinned:
   `theIndicatorRendersOnlyWhileTheChoiceIsUnmade` +
   `theIndicatorCopyNamesTheLockAndKeysNeverEncryptionOff`). RootView gained the
   defaulted `protection:` param; VariorumApp passes `bootstrap.protection`.
8. **The ceremonies' copy — DONE (189c69c).** The set sheet renders `lockMomentFraming` ONLY when a
   demanded pick summoned it; setup step 1 carries `syncSignupFraming`; the enrolled
   section states the device keystone. Verbatim carriage is piece 4's keystone pin.
9. **The tutorial privacy chapter alignment (sixth wave (b)) — DONE.** Content-only,
   two lessons stay two (the contract's SHORT rule): the spare-key paragraph now
   teaches the COUPLING (asking modes don't offer the spare; her why-sentence's logic)
   + spare-key-is-a-key + never-pulls-from-the-server; the strictest-chain paragraph
   drops the stale "with the iCloud copy off as well" (the shape carries no spare);
   lesson 2 gains the sync leg with the ratified syncSentence VERBATIM (composed from
   the brain) + the recipes in one breath; rewritten paragraphs shifted to "this
   device" (full neutrality is bounded by the one-brain assertions, which interpolate
   per-platform — recorded). The contract suite green 3/3. The MOBILE lesson checked:
   it never names a spare under asking modes — no drift, no edit. The field-guide
   RE-SEED stays the closeout's obligation. *(Superseded planning text below kept for
   the audit trail:)* Plan:
   content-only edits to `TutorialSeeder.swift`'s two privacy lessons (~line 1201/1264):
   the spare-key paragraph updates to the COUPLING truth (asking modes don't offer the
   spare — today it says "Locked-down turns it off on purpose", now true of every asking
   mode); add the one-law/recipes/sync-sentence/spare-key-corollary teaching, prose-lite
   and device-neutral ("this device"); keep composing the legs list from
   `ProtectionCopy.lossLegs` (the TutorialWalkTests contract at ~line 3050+ asserts every
   leg appears — keep it green, extend deliberately if lesson structure changes). The
   FIELD-GUIDE RE-SEED stays the closeout's obligation (not this wave's).
   **Check `MobileTutorialSeeder.swift` line ~647** (the phone's privacy lesson does NOT
   use lossLegs — deliberate; align its coupling-truth wording if it names the spare
   under asking modes).
10. **T1 — the stale-copy re-key guard: BUILT AND GUARDED (the attempt succeeded).**
    The verdict for the ladder: **the door is guarded, with evidence.**
    `Sources/VariorumCore/Sync/RekeyRecencyProbe.swift` — the READ-ONLY read seam
    exactly to the settled design below (deviceID nil on EVERY window ⇒ no server-side
    cursor, no horizon effect; local DB read-only; plain columns only, zero decryption;
    anchored on the local copy's own cursor so the near-empty corner reports through the
    same numbers) + the pure `RekeyGuardRule` (warn when server-ahead, never refuse).
    Wired: `EncryptionSession.rekeyRecencyProbe` beside the rekeyRunner (AppServices —
    ordinary transport + the engine's key provider); the door's confirm runs the probe
    on FIRST press, interposes the COUNT-AND-DATES warning (her ruled emphasis,
    essentially verbatim: "12 notes this copy doesn't have, and newer versions of 9
    others, the latest from Aug 28, 2026. Re-keying replaces the server's copy with this
    one — those would be lost. If you can remember your passphrase, that road keeps
    them."), retitles the confirm "Replace the Server's Copy Anyway", and the SECOND
    press proceeds; a probe failure interposes the honest couldn't-compare sentence and
    proceeds — the guard warns, never blocks (the reset road stays open). Pins: core
    `RekeyRecencyProbeTests` (5 — the stale-copy scenario with the read-only proof on
    BOTH sides incl. the fake server's device_cursor unchanged; the fresh-store/near-
    empty corner; current-copy silence; copy-ahead silence; the rule) — **REVERT-
    VERIFIED RED-ON-OLD** (rule → always-proceed: 2 issues red, restored green);
    Mac `RekeyGuardFaceTests` (4 — the count-and-dates form + arms + date formatting;
    found + fixed a MainActor isolation crash in the first run: view statics are
    isolated, the suite is @MainActor now). `Sync/` lines under the Fable rider:
    ONE new read-only file, zero engine-write-path changes (the postmortem was read
    before any of it). *(The settled design below kept for the audit trail:)* The design
    (settled by this session's reading, recorded so the successor need not re-derive):
    a READ-ONLY `RekeyRecencyProbe` in `Sources/VariorumCore/Sync/` (Fable rider
    honored; `notes/sync-postmortem-fragments.md` was read in full) — fetch loop over
    `transport.pull(since: <local cursor>, limit: batchSize, activeKeyID: <provider's
    corpus key id>, deviceID: nil)` — **deviceID nil on EVERY window** (a probe is not a
    round; nil records NO server-side cursor — genuinely read-only; SyncTransport.swift
    :60-71 documents this), pages until empty, dedupes container rows by rowID keeping
    last, filters kind == "post" && deleted_at == nil (PLAIN columns — ids/dates/enums
    are deliberately plain in the disclosure envelope; NO decryption — read the raw
    SyncRow.columns, never crypto.decryptFromWire), compares against local container
    rows: N = server-live ids absent locally; M = ids whose server updated_at > local
    updated_at; latest = max server updated_at among those. Report struct + a pure
    `RekeyGuard` rule (warn when N+M > 0; the near-empty corner is covered because a
    fresh/stale store's cursor is behind, so the pull returns the full server picture).
    WIRE: an `EncryptionSession.rekeyRecencyProbe` closure beside `rekeyRunner`
    (AppServices.start ~line 260, composed like runAccountRekey: makeSyncTransport(auth)
    + the engine's key provider + withDependencies database); the EncryptionViews
    rekeySection's confirm button first runs the probe (busy state), and when the server
    is ahead shows the COUNT-AND-DATES warning (her ruled emphasis, essentially
    verbatim): "the server holds N notes this copy doesn't have, and newer versions of M
    others, the latest from <date>. Re-keying replaces the server's copy with this one —
    those would be lost. If you can remember your passphrase, that road keeps them." +
    an explicit "Replace Anyway" confirm; a probe FAILURE (offline etc.) proceeds with
    one honest couldn't-compare sentence (the door must never be blocked by the guard).
    Tests: core `RekeyRecencyProbeTests` against the fake server
    (Tests/VariorumCoreTests/Support/FakeSyncServer.swift:57) — stale-copy N/M/latest
    correctness + the fresh-store (cursor 0) corner + zero-when-current; a face-level
    composition pin that a server-ahead report renders the count-and-dates sentence.
    **EITHER WAY the final ladder verdicts this door** (guarded with evidence, or a
    KnownIssues row with an owner — the riders block).
11. **Item 4 — the trash/encryption/archived sweep: DONE (judged scope, recorded).**
    ARCHIVED: the hairline-row grammar retired for W8-2 calm cards (List kept — the
    window is 500, virtualization stays; separators gone; CalmCard rows with generous
    CalmButtonStyle doors — Open · Unarchive-primary · Delete-danger; every door
    byte-identical). ACCOUNT (manifest row 04): grouped by question — identity+sync →
    bridge → the DESTRUCTIVE door LAST behind its own divider (it sat mid-column
    between the tier and the bridge); zero copy changes, zero doors lost; shared file,
    phone-legible (PageDoor vocabulary throughout). TRASH: judged ALREADY-GROUPED — the
    polish round's ledger did this surface's de-crowding (G7 grouping, the filter chip,
    the window notes, the fold-able ancestor runs, each behaviour pinned); a card-
    grammar restyle there would touch pinned rendering decisions for pure look and is
    left to 13u2's app-wide continuation (taste fork 3). The reminder/nudge family rode
    piece 6 (tier faces). The encryption-pane crowding was pieces 3–4's centerpiece. Coordinates (relayed
    recon): Mac Trash = `Features/Library/RecoveryView.swift` (plain List; copy via
    `Shared/RecoveryCopy.swift`); Archived = `Features/Library/ArchivedView.swift`
    (plain List; local statics :143-146); Account pane = `Shared/AuthViews.swift` 37-438
    (long strings :64-95; manifest row 04's grouping complaint). The pass: CalmGrammar
    vocabulary (CalmCard/CalmSectionHeader/CalmButtonStyle — Mac-side surfaces;
    AuthViews is SHARED, so restructure там must stay phone-legible), group by the
    question each element answers, ?-disclosure for depth, NEVER delete a door. The
    reminder/nudge family rides piece 6.
12. **Screenshots — DONE (dev-store Debug walk; gitignored pre-13u-act10-screens/):**
    `30-main.png` — the UNCHOSEN-STATE INDICATOR LIVE bottom-left (alarm ink, the
    exposed headline; caught + fixed a label truncation, lineLimit 1 → 2);
    `32-protection-pane.png` — the checklist LEADING the pane with T2's three-value
    truth live ("iCloud spare key — not checked yet this launch");
    `33/33b/34` — the explainer tab, keystones legible (one law leading, recipes,
    new-device split). NOT walked (pinned instead): the demanded-state escrow section
    (needs a passphrase ceremony on the dev store; `thePaneSpeaksTheWhySentence…` pins
    it), the lobby eye, the exposed nudge. **Walk incident, recorded:** the dev build
    raised a KEYCHAIN ACL PROMPT for its own legacy dev-scope e2ee item
    ("io.lduarte.Variorum.e2ee-keys") — DENIED, nothing entered, her keychain untouched
    (the dev app handles refusal honestly); dev-app quit cleanly after, zero instances.
13. **Full verification at close — RUN, GREEN (with one adjudicated red):**
    · **Core `swift test`: 1489 tests / 160 suites GREEN** — baseline 1484/159 + exactly
      the probe suite (+5/+1).
    · **Mac: 1936 tests / 330 suites — the ONLY red is the KNOWN load-flaky latency
      pin** (`rewriteStrategyLatencies`, its KnownIssues row): ADJUDICATED PRE-EXISTING
      by the row's own PAIRED protocol — isolated ×3 on this tree (54.3 / 56.2 /
      57.9 ms) vs isolated ×2 on the PRE-WAVE baseline worktree at 6732864 (53.7 /
      56.4 ms), statistically identical, and this wave's diff has ZERO editor-path
      lines. The 13p covariate held (a loaded box — this session built/tested for
      hours beside her live real-store app). Arithmetic exact: +17 tests / +3 suites
      over the 1919/327 baseline = EscrowPostureCoupling 7 + ProtectionTierFace 4 +
      RekeyGuardFace 4 + the two render pins, in 3 new suites. The canvas suite passed
      in-suite (no isolation needed). The tutorial spine green inside the run. ONE
      moved-cheese pin re-anchored DELIBERATELY with its supersession note:
      `KeychainOffMainTests.everyTransitionArmsGuardSeamWorkArrivesOffMain` — the
      coupling's escrow calls joined each transition's expected off-main list; the
      anyOnMainThread LAW never went red (the calls arrived off-main, exactly as that
      suite polices).
    · **Mobile: 602 tests / 97 suites PASSED + the 2 standing known issues** — the
      baseline exactly; the iOS build subsumed.
14. **Keystone-lines-verbatim confirmation — CONFIRMED, mechanized.**
    `theExplainerCarriesTheKeystonesVerbatim` asserts BOTH halves and is green: the
    ratified sync sentence BYTE-EXACT ("Sync brings your writing back to any device —
    as long as you keep your passphrase or recovery phrase. We can never reset it for
    you: that's what end-to-end means."), the Touch-ID keystone's exact head and tail
    ("An unlocked, enrolled device is as powerful as your passphrase." … "guards this
    device — your passphrase is what lets a new device in."), key-not-backup + opens-
    copies-only + never-pulls-from-the-server, "Passphrase is still the path" — and
    that the explainer SURFACE carries every one. E2EE never appears as user-facing
    vocabulary (seventh wave (iv)); "end-to-end" appears only inside the ratified
    sentence itself.
15. **MOBILE PARITY note (for the closeout's line — R-pre13u-7(f)/R-pre13u-8(f)):**
    ONE posture per account, made structural: the coupling, the checklist rows, the
    tier sentences, the recipes/shapes brain (`ProtectionShapes`), the peek field, and
    the explainer view all live in `Shared/` — the phone's sheet ALREADY renders the
    coupling (no dial under demanded modes, her why-sentence), the compound warning,
    and the standing ways-back-in line from the same brain. Mobile's own deliverables
    at its resumption (faces, not semantics — never re-decided): the exposed-nudge
    FACE (the brain + copy are shared and tier-ready), a checklist face if the sheet
    wants rows over the line, mounting `ProtectionExplainerView` in the phone's
    settings chrome, and the phone's own re-key door face already inherits the T1
    guard through the shared EncryptionView. The phone's tutorial lesson was checked —
    no coupling drift, no edit needed.

## Taste forks so far (for the morning bundle)

1. **Settings panes keep system Form chrome** (not CalmGrammar-carded): the Settings
   window is macOS-native chrome and its sibling panes (Appearance/Tags/Data Safety) are
   all Form-styled; the clarity deliverable is CONTENT structure. The mockup-grammar
   restyle of the Settings window itself is left to 13u2's app-wide continuation.
   One-line swap per section if she wants cards there too.
2. **The field-guide door from Settings points BY NAME** (chapter "keeping it private")
   rather than a live cross-scene button — routing from the Settings scene into the main
   window's book view is 13u2-adjacent machinery; the pointer is honest meanwhile.
3. **The Trash keeps its engineered layout** (see piece 11): the polish round already
   grouped it and pinned the shapes; the calm-card restyle rides 13u2's app-wide
   continuation rather than risking pinned rendering for look alone.

---

# ACT 10 WAVE 2b RECORD (2026-08-31 — the library-ish surfaces, Fable implementer)

**Scope:** item 14 (ONE searchable note-picker, wired at Mark-as-Versions + the Pool's
Add-to-Book) · item 2 (the Pool page redesign) · item 17 (the Snippets refresh to the ruled
mockup direction). Style guide W8-2/W8-3 binds; her amended copy doctrine binds; every
door survives.

## LIVE STATUS (updated per commit — the checkpoint protocol)

- `103ad38` — **CORE LAYER: DONE.** `Queries.notePickerNotes` (bounded, LIKE-escaped,
  snippet+day context per row, subject excluded, archived/deleted/versions fenced) ·
  `PoolItem` + `poolID`/`updatedAt` · `allPoolsListing` + `poolCounts` +
  `observeAllPoolItems` · **`TrashItem.Kind.snippetGroup` + the pool arm in
  `Queries.trash`** (the ruled delete-group door's honesty — #77's lesson; Put back =
  `restoreContainer`, snippets ride the exact-stamp cascade). Pins:
  `SnippetsAndPickerQueryTests` (9), the group-arm pair REVERT-VERIFIED red-on-old.
- `021dcdc` — **THE GROUP KIND'S FACES: DONE.** TrashPutBack `.snippetGroup` →
  `restoreContainer`; TrashScope lists/filters/bulk-purges it; RecoveryCopy's ruled
  vocabulary; RecoveryView help + "Open snippets"; the phone composes from the shared
  brains (zero mobile edits). `NoteDeletion.run`'s kind fence deliberately untouched.
  Pins: `SnippetGroupTrashTests` (2). Mac build + suite green.
- `2986356` — **ITEM 14, THE PICKER: DONE (version doors wired).**
  `Core/Views/NotePicker.swift` (the shared Mac-chrome home minted per the placement
  rule): data-blind `NotePickerSheet` + pure `NotePickerRanking` + three sources
  (corpusNotes peers-first · versionPeers exactly-the-linked · curatedBooks). The
  Library's Mark/Unmark corpus submenus retired; acts byte-identical. **The 2c seam:**
  Compare's "Choose a note…" = `.corpusNotes(session:excluding:versionPeersOf:
  peerAnnotation:)` + its own onPick — no component change needed. Pins:
  NotePickerRankingTests (3) · NotePickerSourceTests (3) · the core ids-overload pin.
- `85d120b` — **ITEM 2, THE POOL PAGE: DONE.** Calm cards over the hairline List; tag
  chips on the metadata line (the column question judged in place — the chips are DOORS,
  a text column is not; not torn); the quiet day beside the title (suppressed when the
  title is the day); the per-row "add to book" door opens the item-14 picker over the
  curated shelf (finished marked, gate speaks). Acts byte-identical; every context door,
  drag, empty state survive. Pins: PoolPageTests (2).
- `9adef40` — **ITEM 17, SNIPPETS: DONE.** Groups rail (flat siblings + counts) · the
  four management doors (new/rename/delete-to-Trash with ask-time count · move-between) ·
  search + tag/sort filters (in-memory over the held listing) · calm cards with the W8-4
  takes badge/words/edited/chips · bulk bar (move/tag/archive/delete) · every prior door
  survives · SNIPPETS vocabulary pinned (`SnippetsCopy.allStrings` sweep; the "pool:
  Pool" chip dead; `PoolNaming` maps the seeded literal; ScrapsPanel swept). The
  note-door kind fence PINNED staying. Pins: SnippetsVocabulary (2) · SnippetFilter (3)
  · SnippetsGroupDoors (4).
- (walk fix) — an empty GROUP speaks as an empty listing, not "Nothing matches."
  (caught live in the wave's own dev walk).
- (close) — the two standing pins whose cheese the ruled changes moved were re-anchored
  DELIBERATELY with supersession notes: `noDoorPutsAPoolContainerInTheTrash` →
  `aDeletedGroupRowsAsAGroupAndNeverAsANote` (its own doc had demanded exactly this:
  *"If a pool-deleting door is ever built, this goes red and its Trash story has to be
  designed with it"* — it went red on schedule; the never-as-a-note guard survives
  whole) · `theTrashScopeIsOneDecisionForBothSurfaces` gains `.snippetGroup` with the
  widening recorded. FULL verification below; wave CLOSED.

## Per-item verdicts

- **Item 14 — the searchable note-picker: BUILT + WIRED (both wave-2b consumers).**
  `App/Variorum/Variorum/Core/Views/NotePicker.swift` — the shared Mac-chrome home
  minted per CLAUDE.md's placement rule (Library + Pool consume it now; Compare in 2c).
  Data-blind `NotePickerSheet` (W8-2 squarish search field, calm-card rows, ⏎ picks the
  top row, Esc cancels, generation-guarded reads — the palette's cadence, no debounce
  machinery) over a `NotePickerSource`. **The ranking rule in a sentence:** version
  peers float to the top STABLY where versions are the subject, recent-first order is
  preserved inside both partitions, and the day detail is suppressed when the title
  already IS the day. Sources: `corpusNotes` (bounded `Queries.notePickerNotes` —
  LIKE-escaped, snippet + day context per row, subject excluded, archived/deleted/
  versions fenced), `versionPeers` (the Unmark door offers EXACTLY the linked peers —
  R60/R68's unlinked-pick refusal corner closed structurally), `curatedBooks` (the
  standing door's own population, finished books offered with the honest mark — the
  gate still speaks on pick). The Library's two corpus-enumerating submenus (manifest
  row 06 — "a disaster") retired; the ACTS byte-identical. Pins:
  `NotePickerRankingTests` (3) · `NotePickerSourceTests` (3) · core
  `SnippetsAndPickerQueryTests` (10, incl. bounded/snippet/escape/exclusion facts).
  Walk-verified: `66-versions-picker.png` — six "2026-08-31" rows, every one tellable
  apart by its snippet.
- **Item 2 — the Pool page: REDESIGNED.** Calm cards over the hairline List (W8-2);
  interactive tag chips on the metadata line; the quiet day beside the title (suppressed
  when the title is the day); the per-row "add to book" door opens the item-14 picker
  over the curated shelf. The dropdown's capability survives byte-identical
  (`model.addToBook`, the same gate refusals in words) — pinned `PoolPageTests` (2: the
  act drains the pool; a finished book's refusal speaks). Every context-menu door, the
  drag payload, and the empty state survive. **The tag-column question, judged in
  place (her overnight authorization):** chips on the metadata line — the chips are
  DOORS (colour · leaf · ✕ off · ＋ types one on) and a tag COLUMN of plain text could
  not be; not genuinely torn, so no screenshot pair queued. Walk:
  `46-pool-page.png` · `47-book-picker.png` · `48-pool-after-add.png` (8 → 7, the drain
  live).
- **Item 17 — Snippets: REBUILT to the ruled direction (the mockup's Snippets tab).**
  The groups rail as flat siblings with counts (the ownership answer in the structure);
  + new group · rename group · delete group (the ordinary `deleteContainer`/Trash road —
  the menu line and the ask-time-counted confirm both say where its snippets go; NO
  ⌥⌘Z claimed, `deleteContainer` registers no structural undo by the 13j doctrine) ·
  move snippets between groups (single ⋯ and bulk); search + tag + sort filters
  in memory over the held listing (a keystroke never touches the store); calm cards
  with the W8-4 "⑂ N takes" badge (free — `RenderedBlock.activeVariantCount` already
  rode the listing), word counts (`Queries.wordCount`, the one rule), edited days, tag
  chips, and the all-groups home line; multi-select with the bulk bar (move ▾ · tag ▾ ·
  archive · delete · clear), acts landing in listing order; the dashed drop target +
  the whole-list drop, the footer entry with its blinking cursor, open-as-editor,
  drag-out (⌥ carries the fan), and the per-card tag/archive/delete trio all survive.
  **The vocabulary is a PIN, not a hope:** `SnippetsCopy.allStrings` sweeps for
  "pool"/"scrap"; the "pool: Pool" chip is dead; `PoolNaming` displays the app-seeded
  literal "Pool" as "Snippets" (storage untouched — every stored "Pool" was app-minted,
  no rename door existed before this wave; the she-renames-a-group-to-"Pool" corner is
  recorded at the brain); the ScrapsPanel's strings swept the same way. **The Trash
  story end-to-end:** `TrashItem.Kind.snippetGroup` + the pool arm (core), TrashPutBack
  → `restoreContainer`, TrashScope lists/filters/bulk-purges it, RecoveryCopy speaks
  "snippet group", the phone composes ALL of it from the shared brains with zero mobile
  edits. `NoteDeletion.run`'s kind fence deliberately UNTOUCHED and PINNED staying (the
  note-shaped doors still refuse pools; the group door is a deliberate, group-shaped
  act). Pins: `SnippetGroupTrashTests` (2) · `SnippetsVocabularyTests` (2) ·
  `SnippetFilterTests` (3) · `SnippetsGroupDoorsTests` (4) · core group-arm pair
  REVERT-VERIFIED red-on-old. The deeper "what is this page for" question stays open,
  as ruled. Walk: `49`–`59` (mint · groups · bulk · move · ⋯ menu · confirm · receipt)
  + `62-trash.png` (the group ROWS, kind + clock) + `64-after-putback.png` (back whole).

## THE COMPONENT SEAM FOR WAVE 2c (item 15's Compare "Choose a note…")

`NotePickerSheet(tokens:title:prompt:emptyState:source:onPick:)` is data-blind — drop it
in with `source: .corpusNotes(session:excluding:versionPeersOf:peerAnnotation:)` (peers
ranked first — exactly the "version peers first where versions are the subject" rule)
and Compare's own `onPick`. No component change needed; a new feed is a new
`NotePickerSource` factory beside the three shipped ones.

## Taste forks for the morning bundle

1. **The Snippets card click model** — body click SELECTS (bulk bar appears),
   double-click opens the editor (item 10's own ruled grammar, applied in place; the
   old behavior was single-click-opens). One-line swap if she wants open-on-click back.
2. **The Trash row's group title reads the STORED name** (core display rule) — a
   deleted seeded-default group would row as "Pool" while the Snippets page calls it
   "Snippets". Mapping it would put UI vocabulary into core's display brain (which also
   names export folders), so left; visible only if the seeded default is deleted whole.
3. **The delete-group confirm's Delete is the plain destructive role** — macOS renders
   it red beside Cancel; no "type the name" ceremony (2 clicks total, the 13j notes
   precedent). Say the word if she wants it heavier.
4. **The bulk "tag ▾" applies ONE existing tag per pick** (batch semantics, skips
   already-tagged); type-to-create stays the per-card sheet's. A typed-path bulk door
   is a small addition if wanted.
5. **The entry bar's blinking cursor** sits at the row's right edge (pre-existing
   shipped layout, deliberately untouched).

## Walk captures (gitignored `notes/plans/pre-13u-act10-screens/`)

`40-launch` · `42-seeded-notes` · `43-shelf` · `44-newbook` · `45-books` ·
`46-pool-page` · `47-book-picker` · `48-pool-after-add` · `49-snippets-empty` ·
`50-snippets-filled` · `51-newgroup-ask` · `52-two-groups` · `53-bulk-bar` ·
`54-two-selected` · `55-move-menu` · `56-after-move` · `57-group-menu` ·
`58-delete-confirm` · `59-after-delete` · `60/61-library` · `62-trash` · `63-putback` ·
`64-after-putback` · `65-row-menu` · `66-versions-picker`. Dev-store Debug build only;
her real app/store untouched (zero instances before launch and after quit); the walk
seeded its own notes/books/snippets by UI automation. Dark-mode passes not eyeballed
(legible by token construction — both voices via `VoiceTokens`); folded to the midpoint
review's walk like wave 1's.

## Verification at close

- **Core `swift test`: 1499 tests / 161 suites GREEN** — baseline 1489/160 + exactly
  the wave's suite (+10/+1).
- **Mac: 1955 tests / 337 suites — the ONLY red is the KNOWN load-flaky latency pin**
  (`rewriteStrategyLatencies`), **ADJUDICATED PRE-EXISTING by its row's PAIRED
  protocol**: isolated ×3 on this tree (50.83 / 50.99 / 50.99 ms) vs isolated ×2 on the
  pre-wave baseline worktree at `ba513fb` (52.59 / 50.28 ms) — statistically identical,
  and the wave's diff has ZERO editor-path lines (`git diff` over Editor/EditorBrain/
  Domain: empty). Arithmetic exact: +19 pins / +7 suites over 1936/330
  (SnippetGroupTrash 2 · NotePickerRanking 3 · NotePickerSource 3 · PoolPage 2 ·
  SnippetsVocabulary 2 · SnippetFilter 3 · SnippetsGroupDoors 4). The tutorial spine
  green inside the run; the canvas suite passed in-suite (no isolation needed). TWO
  standing pins re-anchored DELIBERATELY with supersession notes (the close entry
  above).
- **Mobile: 602 tests / 97 suites PASSED + the 2 standing known issues — the baseline
  exactly** (Shared/ was touched: RecoveryActs/RecoveryCopy; the phone's Trash gains
  the group kind's rows/filter/put-back from the shared brains with zero mobile edits —
  one posture, one account). The iOS build subsumed.
- **Zero `Sources/VariorumCore/Sync/` lines** (the wave's core diff: Queries + tests
  only); **zero schema**; lockstep marker untouched.
- Red-on-old: the trash group-arm pair revert-verified (arm disabled → 2 tests red,
  4 issues → restored green); the remaining new suites pin NEW brains and doors
  (pin-with-the-build, the defect-class pins named above).

## Residuals for the orchestrator (recorded, not dropped)

- The tutorial/field-guide content still says "scraps" in its own prose (e.g. the
  "archive · delete · scraps" trio) — tutorial CONTENT is the re-seed's and 13s's, not
  a UI-string sweep's; the standing field-guide re-seed obligation at the round's
  closeout is where the vocabulary catches up.
- The mockup's group-menu caption promised "⌥⌘Z" for delete-group; the shipped line
  deliberately does NOT (no undo entry exists — the Trash is the road). If she wants
  `deleteContainer` undoable, that is the standing 13j-doctrine product call (the
  KnownIssues quick-note row already carries it).
- The Snippets surface's held observation (`observeAllPoolItems`) re-fires at the same
  cadence `observePool` always has (the tray-panel row's parked class, unchanged in
  kind, summed over groups — scraps-scale by nature).

# ACT 10 WAVE 2c RECORD (2026-08-31 — the modes & views wave, Fable implementer)

**Scope:** item 16 (the THREE ruled note modes — Index new after Takes · Read new
read-only · Blocks kept-and-earned as the workbench, W8-1) · item 15 (the
Compare + Lenses flow rebuild, built directly per her fifth-wave ruling) ·
item 18 (the cohesive Book redesign IF the wave holds it — defers WHOLE
otherwise, verdict recorded either way). Style guide W8-2/W8-3 binds; her
amended copy doctrine binds; every door survives; P-3 hard (ONE live editor,
liveness through `PaneTextAuthority` only); P1 measured on the Sherlock corpus.

## LIVE STATUS — FINAL (wave CLOSED 2026-08-31; the per-commit entries stand as the checkpoint trail)

- `37c1467` (base) — reading done (plan §Act 10 + W8 rulings, the mockup style reference,
  manifest rows 07/08/11/14, wave 2b's seam, PostMode/registry/TOC/read-tier/
  Compare/Lenses/BookView surfaces). Build plan: (1) brains + core queries →
  (2) Index mode → (3) Read mode → (4) Blocks workbench → (5) Compare+Lenses →
  (6) tutorial + key sweep → item 18 verdict → full verification → records.
- `8d11b05` — **BRAINS + QUERY LAYER: DONE.** `Shared/NoteIndexOutline` (pure
  grouping: headings→sections on F-3's first-line letter; flat when headingless;
  DRIFT PIN against `MarkdownRendering` so the cheap check and the one law can
  never disagree silently) · core `Queries.blockWorkbench` + observation (item
  16-C's per-row facts: takes/comments/lock/words/edited/tags, read-time
  derived; `WorkbenchQueryTests` 3 green) · `FlowParagraph` HOISTED
  BookView→`Core/Views` (hoist-at-next-touch; the Read mode is consumer #2;
  every existing pin rode unmodified — the 3C proof shape).
- `1e3272d` — **INDEX + READ SHIPPED as modes.** The row: Write · Takes ·
  **Index** · **Read** · Lenses · Compare · Blocks · Canvas (⌘1–⌘8 derive from
  the one order — rail/menu/keys can't disagree). Index = direction A (sections
  column + filter + fold-all + every TOC door + expand-to-edit via the ONE
  authority + scroll-synced rendered pane, zero TK2 geometry); Read = direction
  B (paper page, minimal companion outline per her sharpening, Aa scale, click
  lands in Index — the scrolled-open door, built ONCE on
  `CommandRouter.focusedBlock`). Registry: `.read` greys the editing families
  (projection tier, P-3); key labels swept. Pins: NewModesTests (4).
- `ea75a9b` — **BLOCKS = THE WORKBENCH (direction C).** Facts per row ·
  filter/show/sort postures (↑↓ wake only in note order — a sorted listing is
  a way of looking) · multi-select on 13e's `BlockSelection` with the bulk bar
  (top/bottom · carry-all merge chain · tag · move-out · archive · delete;
  delete/merge = ONE ⌥⌘Z entry) · the context panel (editable body through the
  ONE authority; facts; takes preview; doors to Write/Takes/History/tray).
  Every TOC door survives; walk pins re-anchored deliberately with
  supersession notes (both new faces declare the pair). Pins:
  BlocksWorkbenchTests (6); BlockTOCTests rode UNMODIFIED.
- `6dca6b2` — **COMPARE + LENSES REBUILT (item 15).** Compare's first open =
  the OFFER page (two generous cards: search-the-library via the item-14
  picker with version peers ranked + annotated · make-outline-note with its
  consequence line; version peers as direct open-beside rows); the dropdown
  dead — the picker everywhere; open slots wear the dashed choose-a-note door
  (Lenses' own stub grammar — ONE "column could stand here" vocabulary);
  column headers are NOTE cards (title · relationship · calm act row). Lenses:
  the footer sentence retired INTO a ?-disclosure (exact words preserved,
  summoned not standing); headers are LENS cards (name · kind line · doors,
  adopt visibly primary). The two modes now tell apart by STRUCTURE (notes+
  relationships vs ways-of-looking+adopt). Semantics byte-untouched; Compare/
  Takes suites green unmodified.
- `6a42071` — **THE FIELD GUIDE LEARNS THE ROW.** "getting around" enumerates
  the eight modes + ⌘1–⌘8; every seeder key literal swept to the new ordinals;
  NEW LESSON "index · read" opens ways-of-looking (the walk's plan⇔seed
  contract EXTENDED, never rewritten); the blocks·canvas lesson teaches the
  workbench honestly. Spine green: 71/10. The live re-seed stays the round
  closeout's per the standing rule.
- **SESSION SEAM (machinery honesty):** the wave's implementer died to its
  session limit after 6a42071 with three fixes uncommitted in the tree; a
  CONTINUATION Fable session adopted them by reading the diffs (this
  record's successor-map purpose, exercised for real). The next entry is the
  continuation's first commit.
- `a7d2c2b` (continuation) — **THE WALK'S TWO FIXES + THE P1 SANITY PIN, adopted and
  committed.** (a) The workbench row's stacked `.modifiers(...)` TapGestures
  dead-stalled EVERY click (the gesture graph waits on unmet modifier
  requirements instead of failing them) → ONE tap handler reading
  `NSEvent.modifierFlags` at the event — wave 1's `NoteRowSelection` idiom,
  routing into 13e's `BlockSelection` brain unchanged; count-2 + plain is
  the standing codebase idiom (LibraryCatalogView). (b) Index's one-shot
  scroll request had TWO consumers racing on one nil-after-scroll channel
  (the pane consumed, the column starved) → the column got its own
  `columnTarget` channel; each channel now has exactly one consumer.
  (c) `WorkbenchP1SanityTests` — the new modes' query layer at the Sherlock
  note scale (120 blocks / ~10k words): blockWorkbench **16.4 ms** cold ·
  blockTOC **1.9 ms**; the asserted ceiling is a 1 s sanity bound two orders
  above measured (the latency-pin lesson: a pin that reds under load cannot
  do its job), the real numbers stated here not asserted.
- `46828a0` (continuation) — **ITEM 18 ATTEMPTED — the INDEX book view
  ships.** Verdict grounds: the pieces were all proven grammars in-tree
  (grouped-entries brain · FlowParagraph · the Index column grammar · the
  W21 reveal/carry machinery), the continuation session was fresh, and the
  field guide book (her screenshot's exact subject) is walkable for visual
  proof. Shipped: `.index` joins `ViewMode` (compile-error-found switches);
  `BookAnchor` gains the `indexPostID` fact + arm (the `pagedAnchor`
  pattern — reported, never decided); `BookIndexView` — a 300 pt column
  (chapters foldable, filter over titles/dates, chapter-filing ⋯ menus,
  count footer) beside a scroll-synced rendered pane (read-cheap
  FlowParagraph prose in the VOICE, lazy per note — P3/P1; ZERO live
  editor, editing lands in Outline via the ascent's own `requestReveal`
  door, double-click or the row menu). **The reconciliation, answered as
  designed:** in Index the minimal navigator steps aside (the index IS the
  outline pane grown up) and the shared `bookMasthead` rides into the index
  column, so no chrome is lost; the minimal pane stays beside every other
  mode (her sharpening honored). **The mode control became quiet word-tabs
  (Outline · Index · Book · Read)** — the segmented picker retired (W8-2:
  it is exactly the dated chrome grammar, and its ideal width had already
  forced `.controlSize(.small)` at three labels; a fourth re-runs the
  b6dae25 overflow). Index sits SECOND, mirroring the note row's Write ·
  Takes · Index · Read cohesion. Tutorial's one tabs sentence updated
  (content → the standing re-seed obligation). Pins: BookIndexColumnTests
  (5 — incl. the ONE deliberate fold/filter divergence from the note
  Index: a matching CHAPTER title keeps all its notes, documented at the
  brain), BookAnchor/BookCarry `.index` arms; adjacent book suites green.
- `9b740de` (continuation) — **ITEM 18 PART 2: the OUTLINE GLOWUP.** The
  three W8-5 asks, one grammar: **the DETAILS GUTTER** — a 190 pt rail at
  the prose column's right (the "bizarrely open" right earns its keep).
  Collapsed cards keep title + excerpt; the meta ("N w · ⑂ takes on M
  blocks") moves INTO the gutter (details to the side, never below the
  opening paragraphs — her words' letter); expanded read-cheap notes put
  the same facts there; **the FOCUSED note's editor bar moves to the
  gutter too** — `CommitBar` gains `axis: .vertical` (ONE brain, every
  door, two arrangements; the Aa slide-out becomes a popover in the rail —
  summoned, same doors) and `EditorView` gains `barPlacement: .side`
  (the book Outline's focused inline form only; every other host keeps
  `.bottom` byte-unchanged). Her screenshot's "FULL editor bottom-bar
  inside a card below its paragraphs" is gone. Spacing swept to the W8-2
  grammar (row spacing 4→10, card padding 16/13, radius 10, air around
  the title block). The bar's sheet fallback hosts (Block History /
  Versions) moved to the axis-neutral wrapper — pinned suites green
  (BlockHistoryPane, NoteVersionsPane, CommitBarLayout, LifecycleFaces,
  BookView). PostCardExcerpt absorbed into the row (one fetch serves card
  + gutter, same realized-row cadence — P1 unchanged).

- **SESSION SEAM #2:** the continuation session died at its limit after `9b740de`.
  A THIRD Fable session adopted the seam from this record (the item 18 verdict
  grounds above were its brief) and shipped the next three.
- `ba13dc8` (third session) — **THE SHERLOCK MODE-LEVEL MEASUREMENTS (the P1
  statement).** `ModesSherlockMeasureTests` (2) on the REAL seeded library, not a
  fixture: on the 9,944-word story — blockTOC **3.1 ms** · outline grouping
  **1.8 ms** · word sum **16.0 ms** · blockWorkbench **22.2 ms** · renderPost
  **2.8 ms**; on the 105k-word book — book snapshot **4.1 ms** · index flattening
  **0.4 ms** · FULL realization **36.1 ms** over 2,533 blocks (the price the lazy
  tiers never pay at once). Ceilings are sanity bounds two orders above measured
  (the latency-pin lesson); the numbers live HERE, not in the assertions.
- `bd6c81f` (third session) — **ITEM 18 MOUNT SMOKES.** `BookRedesignMountTests`
  (2): the INDEX book view mounts chaptered with ZERO live editors (editing lands
  in Outline — falsifiable by count); the Outline gutter's focused form
  (`EditorView barPlacement: .side` + `CommitBar axis: .vertical`) mounts exactly
  ONE live editor on focus and releases it on collapse. P-3's letter, counted.
- `54a2cb1` (third session) — **THE MASTHEAD TAB-WRAP FIX — the walk earns its
  keep.** The four word-tabs + gear compressed inside the 190 pt navigator and
  wrapped mid-word ("outl/ine") — the b6dae25 class. Caught ONLY because the third
  session walked a FRESH build: the continuation's post-commit captures were of a
  STALE build, so the overflow had never been seen. Fix: the gear rides the
  truncating TITLE line, the tabs own their row whole, every label `lineLimit(1)`
  + `fixedSize` (P-8's letter); the masthead doc's false "four labels measure
  under 190 pt" claim corrected to tell the story. Verified both ways — the stale
  capture shows the wrap; shots 81/82 show one clean line in the navigator AND
  the index column. **Lesson, recorded for the round:** a post-commit capture is
  evidence only when it comes from a build of the committed tree.
- **SESSION SEAM #3:** the third session died after `54a2cb1` with the two pin
  re-anchors below COMPLETE but uncommitted in the tree, and its full-suite run
  killed unfinished. The CLOSER (a fourth session) adopted both by diff-read.
- `15c7463` (closer) — **THE TWO RULED PIN RE-ANCHORS, committed.**
  `MarkdownActsTests.formattingIsAvailableWhereverTextIsEditedAndGreyWhereItIsNot`
  — the premise "every mode hosts a live editable surface" was falsified BY
  RULING (W8-1: READ is the projection tier, deliberately read-only); the pin now
  asserts the formatting family greys in Read and stays `.act` in every EDITING
  mode (the registry-side twin is `NewModesTests`). `PostDetailModeMemoryTests.
  theModeVocabularyIsTheEightModeRail` — seven → six (Outline retired, 13b
  4C/S4-3) → EIGHT, the third re-anchor in this pin's own lineage; the mode-row
  change IS the ruled behavior change each time. **The full suite then found NO
  further moved-cheese pin** (the coordinator's widened brief for the closer:
  every other standing pin held against the eight-mode row, Read-as-projection,
  the book's word-tabs, the details gutter and the workbench WITHOUT edit; the
  predecessors' own three re-anchors — `CapabilityRegistryTests`' archive/delete
  pair and `BlockHistoryPaneTests`' capability union, both widened from
  `BlockTOCView` to `BlocksWorkbenchView` + `IndexModeView` "so the promise
  widened rather than moved", and `BookAscentTests`' `.index` arm + carry pin —
  all carry supersession notes citing W8-1).
- (close, this commit) — **FULL VERIFICATION + THE RECORD.** Mac **1980/343** ·
  core **1503/163** · iOS builds. The sections below.

**WAVE STATUS: CLOSED 2026-08-31. Items 15, 16 and 18 BUILT; NOTHING from this
wave defers to 13u2** (the item 18 whole-or-nothing clause was never invoked).

## Per-item verdicts

- **Item 16 — the three ruled note modes (W8-1): BUILT.** INDEX (direction A —
  `IndexModeView`: the standing sections column on `Shared/NoteIndexOutline`,
  filter, fold-all, every TOC door, expand-to-edit through the ONE
  `PaneTextAuthority`, a scroll-synced rendered pane with ZERO TK2 geometry);
  READ (direction B — `ReadModeView`: the paper page on `ReadingPageTokens`, the
  MINIMAL companion outline per her sharpening, Aa scale, hover ordinals, NO live
  editor — the registry greys the editing families; a paragraph click lands in
  Index via the scrolled-open door); BLOCKS kept and EARNED (direction C —
  `BlocksWorkbenchView`: facts per row from core `Queries.blockWorkbench`,
  filter/show/sort postures, multi-select on 13e's `BlockSelection` with the bulk
  bar, the context panel with an editable body through the ONE authority and
  doors to Write/Takes/History/tray; every TOC door survives). The field guide
  teaches all three. Pins: `NewModesTests` (5) · `BlocksWorkbenchTests` (6) ·
  `NoteIndexOutlineTests` (4, incl. the DRIFT pin against `MarkdownRendering`) ·
  core `WorkbenchQueryTests` (3) + `WorkbenchP1SanityTests` (1) ·
  `ModesSherlockMeasureTests` (2) · the ruled re-anchors named above.
  Walk-verified: shots 74–79, 83.
- **Item 15 — the Compare + Lenses flow rebuild: BUILT DIRECTLY (her fifth-wave
  ruling — no proposals).** Compare's first open is the OFFER page (two generous
  cards: search-the-library via item 14's picker with version peers ranked +
  honestly marked · make-outline-note with its consequence line; version peers as
  direct open-beside rows); the "Choose a note…" dropdown is DEAD everywhere; an
  open slot wears the dashed choose-a-note door (Lenses' own stub grammar — ONE
  vocabulary); column headers are NOTE cards (title · relationship · calm acts).
  Lenses: the footer explainer RETIRED into a ?-disclosure (exact words
  preserved); headers are LENS cards (name · kind · doors, adopt visibly
  primary). The two modes tell apart by STRUCTURE. Semantics byte-untouched
  (13b's rebuild): `CompareComposition`/`CompareViewModel`/Takes suites green
  UNMODIFIED — that is the proof, and deliberately no new pin (a flow rebuild
  over pinned semantics pins nothing new). **She judges it in the running app by
  her own ruling** — see the residuals: the 2c walk set carries no Compare/Lenses
  capture.
- **Item 18 — the cohesive Book redesign (W8-5): BUILT, WHOLE, IN-WAVE.** The
  three asks, each with its grounds:
  - **(a) The Outline glowup — the whole document at once, details to the SIDE,
    the open-right earning its keep:** the DETAILS GUTTER (`9b740de`) — a 190 pt
    rail right of the prose column carries the card meta ("N w · ⑂ takes on M
    blocks") for collapsed AND expanded notes (never below the opening
    paragraphs — her words' letter), and the FOCUSED note's whole editor bar
    rides the same rail (`CommitBar axis: .vertical` — one brain, every door, two
    arrangements; `EditorView barPlacement: .side`, used by this host only);
    spacing swept to W8-2's grammar. Her screenshot's "full bottom-bar inside a
    card below its paragraphs" is gone (shot 81). Pins: `BookRedesignMountTests`
    (ONE live editor on focus, released on collapse) + `CommitBarLayout` /
    `BlockHistoryPane` / `NoteVersionsPane` / `LifecycleFaces` / `BookView` suites
    green.
  - **(b) An index-like book view sharing the outline brain where honest:**
    `BookIndexView` (`46828a0`) — a 300 pt column (chapters foldable, filter,
    chapter-filing ⋯ menus, count footer) beside a scroll-synced read-cheap
    rendered pane (lazy per note — P3/P1; ZERO live editor, editing = the
    ascent's own reveal door into Outline). **The brain it shares is the BOOK's
    outline brain** — `BookStructureModel.grouped(entries:)`, the exact function
    Outline mode (`BookView.swift:150/362/804`) and the paged view consume — and
    it deliberately does NOT share the note Index's `NoteIndexOutline`, because a
    book's chapters are REAL `reading_section` rows while a note's sections are
    DERIVED from headings; re-deriving would be a second brain over facts the
    book already owns (`BookIndexView.swift:15`). What IS shared with the note
    Index is the grammar (column + synced pane) and the one markdown transform
    (`FlowParagraph`, hoisted for exactly this). "Where honest" honored by NOT
    sharing the heading brain. Pins: `BookIndexColumnTests` (5, incl. the one
    deliberate divergence — a matching CHAPTER title keeps all its notes) ·
    `BookAscentTests`' `.index` anchor + carry · `BookRedesignMountTests` (mounts
    chaptered with ZERO live editors). Shot 82.
  - **(c) The book view sharing an outline with Outline mode, reconciled with the
    small pane:** the minimal navigator pane STAYS beside Outline · Book · Read
    (her sharpening: "I do like the more minimal outline to go along with the
    current modes"); in INDEX it steps aside because the index IS that pane grown
    up, and the shared `bookMasthead` rides into the index column so no chrome is
    lost. The mode control became quiet word-tabs **Outline · Index · Book ·
    Read** (the segmented picker retired per W8-2 — its width trap is what
    `54a2cb1` then met and fixed in the tabs' own row). One outline brain feeds
    every mode (ground (b)); one pane grammar at two grains (minimal beside the
    modes, full as Index). Shots 81/82 show the same book in both.
  - **Residue, named as residue (a built-whole design with a named residue is a
    verdict, not a split):** the PAGED Book mode's and the book Read mode's chrome
    are not restyled to W8-2 — 13u2's app-wide restyle continuation (its addendum
    already carries it); the book Read-mode click-through jump defect stays 13u
    item 17's (her own words at W8-1); the Outline card's excerpt reads the first
    block verbatim (a taste fork below); the live field-guide re-seed + AppSpec
    §12's mode-row delta ride the ROUND closeout by the standing rules.

## The mode rows as they now read

- **Note:** Write ⌘1 · Takes ⌘2 · **Index ⌘3** · **Read ⌘4** · Lenses ⌘5 ·
  Compare ⌘6 · Blocks ⌘7 · Canvas ⌘8 — the rail, the masthead menu and the keys
  all derive from the ONE `PostMode` order (`NewModesTests` pins that the order IS
  the key mapping); the field guide enumerates it and every seeder key literal is
  swept (`6a42071`).
- **Book:** **Outline · Index · Book · Read** — quiet word-tabs in the navigator
  masthead, Index second to mirror the note row's writing/reading cohesion.

## The Sherlock numbers and the P1 statement

On the REAL seeded library (`ba13dc8`, in-app): the 9,944-word story reads
blockTOC 3.1 ms · outline grouping 1.8 ms · word sum 16.0 ms · blockWorkbench
22.2 ms · renderPost 2.8 ms; the 105k-word book reads book snapshot 4.1 ms ·
index flattening 0.4 ms · FULL realization 36.1 ms over 2,533 blocks. At the
core layer on a same-scale fixture (`a7d2c2b`): blockWorkbench 16.4 ms cold ·
blockTOC 1.9 ms. **P1 HOLDS for every surface this wave added:** each mode's read
is a bounded per-note query (ms-scale at her working size); the book's 36.1 ms is
the ONE-TIME cost of realizing all 2,533 blocks, which the lazy tiers
(`LazyVStack` per note, read-cheap `FlowParagraph`) never pay at once; Index,
Read, the workbench and the book Index depend on ZERO TK2 geometry; P-3 is
counted, not assumed (`BookRedesignMountTests`: 0 live editors in the book Index,
exactly 1 in the gutter's focused form). Every asserted ceiling sits two orders
above the measured value, so the pins cannot red under load — the numbers are
stated here, deliberately not asserted.

## The scrolled-open door — built ONCE, two named reusers

Read's paragraph click lands that block in Index already open and scrolled: the
mechanism is `CommandRouter.focusedBlock` seeding the Index column's own
one-shot `columnTarget` channel (one consumer per channel since `a7d2c2b`). **13u
item 17** (the book Read-view edit jump — "clicking brings you to the top, which
sucks") and **13i's Book Panel click-through** both REUSE this door rather than
minting their own; the book-side ascent already routes through `requestReveal`,
so item 17's remaining work is the TK2 scroll-to-location leg (TEXTKIT2 §2), not
a new door.

## Taste forks for the morning bundle

1. **Read's slot — beside Index, after Takes** (recorded taste call: the row now
   pairs writing · reading · comparing · managing, and Read's click-through lands
   in Index, so they sit adjacent). **Consequence she will feel: ⌘3–⌘6 REMAPPED**
   — Lenses ⌘5, Compare ⌘6, Blocks ⌘7, Canvas ⌘8. A re-slot is one line in
   `PostMode` (everything derives from the order).
2. **The book's Index tab sits SECOND** (Outline · Index · Book · Read), mirroring
   the note row; the segmented picker became word-tabs (W8-2). One line to reorder.
3. **The Outline card's excerpt reads the first block verbatim** — so a
   chapter-numeral opener ("I.", *A Scandal in Bohemia*, shot 81) yields a
   one-character excerpt. The seed's shape meeting a simple rule; skipping
   trivially short first blocks is a small brain change if she wants it.
4. **The details gutter is 190 pt and hosts the FOCUSED note's WHOLE editor bar
   vertically** (Aa as a popover in the rail). Both arrangements are ONE brain
   (`CommitBar axis:`), so "bar stays horizontal under the card, meta only in the
   rail" is a one-argument swap if the rail feels crowded.
5. **The book Index has NO live editor** — editing is the reveal door into Outline
   (double-click or the row ⋯), the same posture as the note's Read → Index
   click-through. In-place editing there would be a second host for the ONE
   editor — a P-3 decision, not a tweak.
6. **The book Index's ONE deliberate fold/filter divergence** from the note Index:
   a matching CHAPTER title keeps ALL its notes (pinned, documented at the brain).
   Her call if she'd rather the filter narrow to matching notes only.
7. **The workbench's ↑↓ wake only in note order** — a sorted listing is a way of
   looking, not a place to reorder; its row click model rides 13e's
   `BlockSelection` as the Library's rows do.
8. **Compare's first open is the OFFER page** (search the library · make an
   outline note · version peers as direct rows) and the dropdown is gone
   everywhere in favor of the picker; **Lenses' explainer sentence** lives behind
   `?` with its exact words. Hers to judge in the running app — see residual 1.
9. **Read's minimal companion outline is collapsible**, Aa-scaled, with hover
   gutter ordinals and a meta bar carrying the tray door.

## Walk captures (gitignored `notes/plans/pre-13u-act10-screens/`)

74 index landing · 75 index scroll-sync · 76 read · 77 read click-through · 78
workbench · 79 workbench bulk bar · 80 launch · 81 book Outline (the gutter + one
clean tab line) · 82 book Index · 83 the note's eight-mode rail. Shots 81/82 are
from the third session's FRESH build (the tab-wrap lesson above).

## Machinery honesty

**Three session deaths across the wave, every one continued LOSSLESSLY from this
record:** the implementer died after `6a42071` with three fixes uncommitted (the
continuation adopted them by diff-read → `a7d2c2b`); the continuation died after
`9b740de` (the third session picked up the item 18 verdict grounds from the record
and shipped the measurements, the mount smokes and the wrap fix); the third died
after `54a2cb1` with the two pin re-anchors uncommitted and its suite run killed
(the closer adopted them → `15c7463`, then ran the verification the third never
finished). The per-commit LIVE STATUS entries + `git diff` were sufficient every
time — the checkpoint protocol exercised for real, three times, with zero
re-derivation. Two lessons the wave paid for: (1) a post-commit capture is
evidence only from a build of the committed tree; (2) a suite run must be waited
on in the FOREGROUND — the third session backgrounded it and ended its turn.

## Verification at close

- **Mac: 1980 tests / 343 suites GREEN in 267 s, ZERO failures** — baseline
  1955/337 + exactly the wave's suites (+25/+6: NewModes 5 · BlocksWorkbench 6 ·
  BookIndexColumn 5 · BookRedesignMount 2 · ModesSherlock 2 · NoteIndexOutline 4
  = 24, + BookAscent's `.index` carry pin). **The known load-flaky latency pin
  PASSED outright** — `rewriteStrategyLatencies` read **35.5 ms** at 50k words
  (budget 50 ms) on a box 13 min past a reboot at load 25–44 — so the PAIRED
  worktree protocol was not invoked (its stale `pre2c` registration at `37c1467`
  was pruned at this close). `Canvas drag tracking` passed in-suite. **All ten
  `Tutorial …` suites green** inside the run (the spine, 71/10 at `6a42071`,
  unchanged since).
- **Core `swift test`: 1503 tests / 163 suites GREEN in 50 s** — baseline
  1499/161 + exactly the wave's (+4/+2: `WorkbenchQueryTests` 3 ·
  `WorkbenchP1SanityTests` 1).
- **iOS: `xcodebuild build -scheme VariorumMobile -destination
  'generic/platform=iOS Simulator'` — BUILD SUCCEEDED** (11 pre-existing-class
  warnings, zero errors; `Shared/` gained `NoteIndexOutline`). See residual 2 for
  why the destination is now stated explicitly.
- **Zero `Sources/VariorumCore/Sync/` lines; zero `Persistence/` lines; no
  schema; lockstep marker untouched at 7** — `git diff --stat 37c1467..HEAD` over
  both paths is empty.
- **The author's real app was NOT running at any point** (`pgrep` by the
  `/Applications` path empty before, during and after; no Release build, no
  `/Applications` refresh — the round closeout's).
- **Red-on-old:** the two ruled re-anchors are red on the pre-wave assertions by
  construction (the old lines name the ruled-away state: formatting `.act` in
  Read; a six-entry rail); the wave's new suites pin NEW brains and mounts
  (pin-with-the-build), with the drift pin (`NoteIndexOutline` vs
  `MarkdownRendering`) and the P-3 counts as the defect-class pins.

## Residuals for the orchestrator (recorded, not dropped)

1. **No Compare/Lenses capture exists in the 2c walk set** (74–83 cover
   Index/Read/workbench/launch/book). Item 15 is hers to judge in the running app
   by her own ruling — the orchestrator's pre-bundle walk should shoot the OFFER
   page and one lens card from a fresh build so the bundle carries them.
2. **The bare `xcodebuild build -scheme VariorumMobile` no longer proves the iOS
   target:** since the 2026-08-30 signing change it resolves FIRST to "My Mac
   (Designed for iPad)" and fails on the iOS Team Provisioning Profile excluding
   this Mac — an environment fact, not a code one (zero compile errors). The
   round's verification lines and 13r should state the destination
   (`generic/platform=iOS Simulator`) so the check means what it says.
3. **The full mobile test suite stays a round-end act** (the wave-1/2b posture);
   `Shared/` gained one NEW file (`NoteIndexOutline`) and nothing existing there
   moved.
4. **The workbench's opt-in facts observation (`observeBlockWorkbench`)** is held
   only in Blocks mode and re-fires at autosave cadence while its context panel's
   body is edited — 22.2 ms cold at the 10k-word note, off-main. The tray-panel
   KnownIssues row's parked class, unchanged in kind; measure at 12 beside its
   siblings if it ever earns a row.
5. **Carried to the ROUND closeout by the standing rules:** the live field-guide
   re-seed (tutorial CONTENT changed: the eight-mode "getting around" + the new
   "index · read" lesson); AppSpec §12's mode-row delta (six → eight; the book's
   four word-tabs); the `/Applications` refresh; the mobile update note owes a
   paragraph on the new modes + the Book redesign (obligation 7's "tenth-wave
   note" clause).

# MIDPOINT REVIEW RECORD (2026-08-31 evening — the Opus cold review over the Opus-built surface:
# Acts 3+4, Act 5, Act 0's Opus half; REVIEW_PROMPT verbatim, zero framing; findings recorded
# BEFORE any fix session; the architect's dispositions at right)

| # | sev | finding (condensed; the reviewer's full mechanism is in the session record and restated in the fix brief) | disposition |
|---|---|---|---|
| M1 | MAJOR | `SampleLibrarySeeder.seed` mints via `importPost`, which segments by the reader's synced `default_segmentation` — under the shipped "One block" option the whole library seeds as 13 giant blocks (Blocks/Index/Outline show 13 rows for 105k words; autosave rewrites ~60 KB per keystroke inside a story). The plan's own build-shape line conflated the two; `TutorialSeeder` (the named precedent) is mode-independent via `newBlock`. | **ACCEPT — FIX.** Mint per paragraph explicitly (`SegmentationRules.bulkSegments(text, mode: .paragraph)` + the tutorial's `newBlock` road, or an explicit `segmentation:` on `importPost`); the reviewer's red-on-old pin (seed under `.oneBlock` → the scandal story renders >200 blocks). The bundled text was shaped for `.paragraph`; the manifest's round-trip assumes it. — **FIXED `5f6b46a`.** The `segmentation:` road: an explicit `Segmentation? = nil` on `importPost` (nil = the global chain, so all other callers are byte-unchanged) + `SampleLibrarySeeder.segmentation = .paragraph` named at both mint sites. PIN `theSeedIsIndependentOfTheReadersSegmentationSetting`, red on the reverted tree: `(blocks.count → 1) > 200`. The plan's Act 3 build-shape line carries a dated correction. |
| m1 | MINOR | `Queries.versionsOfNotes` builds an unbounded `IN (…)` while its sibling `activeFans` chunks at 400; `Queries.trash(limit: nil)` callers make the list the whole 30-day window (latent at 32766 today; 13w fills it at machine cadence). | **ACCEPT — FIX.** Same chunk loop, merged dictionaries; a pin over a >400-id list (equivalence, honestly labelled). — **FIXED `7eb38f2`.** Chunked at `fanChunk`; the per-chunk pass extracted as `accumulateVersionPeers`; the merge is a plain UNION (a version's rows can only come from the chunk carrying its id). PIN `theBatchedPeerLookupChunksItsParameterList` — a SHAPE half (1,000 ids ⇒ 3 statements, red on old: 1) plus the equivalence half with real ids at the head, ON the 400-boundary and at the tail. **Honesty note:** a first draft claimed the old door THREW at 40,000 ids and it PASSED on the reverted tree — measured instead: this SQLCipher build takes 65,536 parameters and throws at 100,000, so the cliff is far above any real Trash window. The pin's doc says so rather than dressing a latent cliff as a live defect. |
| m2 | MINOR | Act 0's mobile empty-state pins assert the CONSTANTS only — deleting the views leaves them green (the P47 hole, in the same round that closed it). | **ACCEPT — FIX.** Composition-dump pins per surface on `MobileProtectionSurfaceTests.composition(of:)`. — **FIXED `34f35bf`.** Library: the composition dump as prescribed. Shelf: a MOUNTED pin instead, because its empty state sits inside a `GeometryReader` whose content closure runs at layout time and is absent from a dump at ANY depth (checked at `maxDepth: 400`) — the phone's live accessibility tree makes the stronger measurement available, so the sentence must reach the RENDERED tree. Plus a complement (a store WITH a note carries no empty copy). Matching goes through `tokens.chromeLabel`, which lowercases in the terminal voice — found by a red pin. **RED-ON-OLD IS THE FINDING ITSELF:** with both empty-state VStacks deleted the two constant pins stayed GREEN and both new pins went red. |
| m3 | MINOR | `MobileFirstWriteFurniture.lastOutcome` is written and read nowhere (its doc names a DEBUG surface that does not exist — the P43 class); the occasion has NO logging, and the `.accountOwned` early return short-circuits before either seeder, so the likeliest "why didn't my Journal/Sherlock appear?" produces no line. | **ACCEPT — FIX.** One `Logger(subsystem: "io.lduarte.Variorum", category: …)` notice per outcome (the `SampleLibrarySeeder` precedent); delete `lastOutcome`. — **FIXED `06a49a2`.** `lastOutcome` deleted (grep-verified: zero readers in either app or test target); one `notice` per occasion in category `first-write-furniture`, covering `.alreadyRan`, `.accountOwned`, and `.ran` with BOTH seeders' outcomes inside it — so the `.accountOwned` short-circuit, which produced no line anywhere, now speaks. `.public` safe by inspection (case names + reading ids). Cleanliness class, no pin. |
| m4 | MINOR | `sherlock-extract.py` writes to the pre-hoist path (raises `FileNotFoundError`); the record's "re-runnable" claim is false; the docstring names the old path twice. | **ACCEPT — FIX.** The path constant + docstring; cleanliness class, no pin. — **FIXED `339115b`.** Path constant + both docstring mentions → `App/Variorum/Shared/SampleLibrary/`; a dated path note records why it drifted. **Re-runnability PROVEN, not asserted:** the script was run and its output byte-compared (`cmp`) against the committed resource — identical, resource untouched in git, and its own report matches the batch record exactly (12 stories · 2,530 paragraphs · 104,350 words · 574,874 bytes). |
| m5 | MINOR | Per-title resumability quietly weakens "deletion is final": a lost device mark (reinstall, a 13x-restored store, cleared defaults) re-mints exactly the deleted/renamed titles into her book; and `createSection`/`importPost` are separate transactions, so a death between them leaves an empty chapter and the next occasion mints a duplicate-named one. | **ACCEPT — BOTH HALVES.** Record the mark-loss residual in the seeder's "deletion is final" section (the `MobileStarterJournal` precedent); add the cheap guard — a story's turn skips when its title is in the book OR a chapter of that name already exists — pinned (chapter-present/post-missing state mints no second chapter). — **FIXED `94e6405`, both halves.** The guard REUSES the standing chapter rather than skipping the story (`discover` now reports `chapterIDsByName`): skipping would leave the reader missing a story AND an empty chapter, which is the worse half of the same bug. PIN `aResumedSeedReusesAnEmptyChapterInsteadOfDoublingIt`, red on the reverted tree: `chapters.count → 14`, two chapters named "A Scandal in Bohemia", the note landing in the NEW one. The residual half names all three mark-loss roads (reinstall · a 13x-restored store · cleared defaults) and the `setting`-table blocker that closes it. |
| m6 | MINOR | Default-on seeding into an EXISTING store stamps every story `last_touched_at`/`last_major_revision_at` at seed time (via `registerTextChange`), so 13 Conan Doyle notes land at the TOP of the Library and Timeline above her own recent writing — on her real store at the next launch of the refreshed build. | **ACCEPT — FIX, PROVISIONAL (product-flavored; morning bundle).** Seeded stories carry BACK-DATED stamps — `created_at`, `last_touched_at`, `last_major_revision_at` set to the work's publication date (1892-10-14) — so they sort to the bottom of recency views and read honestly on the Timeline; timestamps are display data (SyncSpec §9), the seed is a local mint. Alternative if she prefers: stamp at seed time and accept the displacement. Her nod at the bundle. — **BUILT `d34b75f`, STILL PROVISIONAL.** THE ROAD: the whole seed runs inside `withDependencies { $0.date = .constant(publicationDate) }` — the operations layer's OWN time seam. No new operation, no second write pass, no raw UPDATE. Scope covers book/tag/chapters too (books sort by NAME, so the shelf does not move). PIN `theLibraryIsBackDatedToItsPublication` — her note leads `.lastTouched`/`.lastMajorRevision`/`.createdAt`, all thirteen carry the stamp, the Timeline's oldest page is them; red on the reverted tree with 6 failures, her note 14th on every sort. **Her alternative is one constant and one scope away, and the constant's doc says so.** |
| n1 | NIT | The composition-dump pins prove a `Text` is COMPOSED, not VISIBLE (`.opacity(0)`, clipped frames, `.hidden()` keep them green). | **ACCEPT — DOC.** Record the road's limit beside the two rejected roads in `ProtectionSurfaceRenderTests`' header and the mobile twin. — **DOC'd `6938a70`**, both headers. Also carries the boundary this fix session met for real: a sentence inside a `GeometryReader`'s content closure is absent from a dump at any depth, so such a surface needs a mounted pin — the mobile header names its worked example and the Mac's points at it. |
| n2 | NIT | `MobileStarterJournal`'s `.accountOwned` doc says "the next write asks again"; within one launch the occasion is spent. | **ACCEPT — DOC.** One clause: true across launches. — **DOC'd `16fcc43`**, with the reason: within one launch the single `occasion` task is spent and every later write joins it (`.alreadyRan`), which is deliberate — one account read per launch, not one per keystroke. |
| n3 | NIT | The 13i wing line (Act 3 decision D) is not yet in the 13i brief. | **CARRY — closeout item** (already on the closeout checklist). |
| n4 | NIT | `phase-13b-make-it-work.md:5295` still names `BoundarySnapping.snap(.sentence)`. | **LEAVE — recorded.** Closed-phase history; the live doc sites and AppSpec were corrected at P45; editing closed plan files is the archive's own no-rewrite class. |

**Clean bill (load-bearing lines, kept):** P18's CTE equivalence traced case by case; P19's ordering rule survives the SQL→Swift move; P21's batching returns the same dictionary; `v1_15` in its own commit, not a §12 event, both plan pins green; `ReadLayerP1Tests`+`TriggerCoverageTests` 11/11; P48 verified live (every pin ratio-bound on this host); P49 with zero `Sync/` edits, diff-verified; P42 complete and behavior-neutral; P43 no dangling refs; P45 independently verified; P50's dismissal right; the Act 0 hoist proven (SampleLibraryTests 10/10, file byte-untouched); the Pool-blank + tag pins real and green; trap 2 (undo) closed; the sync gate sound (`lastSuccessAt` only after pull AND push succeed); fences intact across all eleven commits; the bundled text clean of PG strings and markdown-significant line starts; `.public` logging leaks no bound arguments; the `bookWordCounts` row's one-shot claim true; all new KnownIssues rows owned.

**Adjudication:** no disputes to relay — every finding traced a concrete mechanism; M1 is the review's real catch (a plan-level conflation the implementation followed faithfully) and must land BEFORE her store seeds at the refresh. Fixes → an Opus fix session (none touch custody or `Sync/`); the final ladder reviews them with everything else.

# MIDPOINT FIX RECORD (2026-08-31, a fresh Opus fix session — every FIX and DOC row of the
# midpoint review, one commit each, pushed per commit under the checkpoint protocol)

**Commits, in the brief's order:** `5f6b46a` (M1) · `94e6405` (m5) · `d34b75f` (m6) ·
`7eb38f2` (m1) · `34f35bf` (m2) · `06a49a2` (m3) · `339115b` (m4) · `6938a70` (n1) ·
`16fcc43` (n2) · this records commit. **Nine findings, nine commits, zero deferred.**
`n3` remains the closeout's carry and `n4` remains LEAVE-recorded, both untouched.

## The red-on-old evidence, per bug-class finding (behavioural revert in every case)

| finding | pin | what the reverted tree said |
|---|---|---|
| **M1** | `SampleLibraryTests.theSeedIsIndependentOfTheReadersSegmentationSetting` | `Expectation failed: (blocks.count → 1) > 200` — the 105k-word library as thirteen blocks, exactly the MAJOR |
| **m5** | `SampleLibraryTests.aResumedSeedReusesAnEmptyChapterInsteadOfDoublingIt` | `(chapters.count → 14) == 13`; two chapters named "A Scandal in Bohemia"; `sectionID` mismatch — the note landed in the NEW chapter |
| **m6** | `SampleLibraryTests.theLibraryIsBackDatedToItsPublication` | 6 failures — her own note 14th on `.lastTouched`, `.lastMajorRevision` AND `.createdAt`, and the Timeline's oldest page 2026 |
| **m1** | `ReadLayerP1Tests.theBatchedPeerLookupChunksItsParameterList` | `(peerStatements.count → 1) == 3` — one unbounded list where the sibling batcher makes three |
| **m2** | `MobileEmptyStoreTests.theEmptyLibrarySurfaceCarriesAllThreeSentences` + `.theEmptyShelfSurfaceNamesBothRoads` | with BOTH empty-state VStacks deleted: the two shipped CONSTANT pins stayed **green** and both new surface pins went red — the finding demonstrated rather than described |

Every revert took a pre-revert copy first (`<scratch>/midpointfix-prerevert/`, this session's own
directory per the resiliency addendum's rule 3), and every restore was `diff`-verified before the
commit that followed. `m3`/`m4` are the cleanliness class the hallucination guard exempts from
pins (dead code; a stale path proven by RUNNING the script and `cmp`-ing its output); `n1`/`n2`
are documentation.

## Two places this session corrected ITSELF, recorded because the guard is the point

1. **m1's first pin was FALSE.** It claimed the unchunked door threw past the SQLite parameter
   ceiling at 40,000 ids — and it **passed** on the reverted tree. Measured rather than re-guessed:
   on this SQLCipher build a **65,536**-parameter `IN` list succeeds and **100,000** throws "too
   many SQL variables". So the cliff is far above any real Trash window, the finding is the LATENT
   class the review itself recorded, and the pin was rewritten as a SHAPE pin (statement count)
   that is honestly red on old without pretending the cliff was live. The pin's own doc carries
   the measured numbers.
2. **m2's shelf could not take the prescribed road, and the reason is worth keeping.** Its empty
   state sits inside a `GeometryReader`, whose content is a CLOSURE evaluated at layout time — so
   `dump` walks past it at any depth (checked at `maxDepth: 400`, not assumed). The phone has what
   the Mac's header records as unavailable there, a live accessibility tree on a hosted surface, so
   the shelf got the STRONGER measurement instead. Both `ProtectionSurfaceRenderTests` headers now
   carry the boundary (n1's own subject).

## The m6 road, stated because "never an ad-hoc row edit" was the constraint

The back-dating writes **no** rows of its own. The whole seed runs inside
`withDependencies { $0.date = .constant(SampleLibrarySeeder.publicationDate) }` — `Operations`
reads `@Dependency(\.date)` and nothing else, so every stamp it writes (`created_at`, `updated_at`,
`last_touched_at`, and the `last_major_revision_at` the first churn crossing lands) carries
1892-10-14. No new operation, no second write pass, no raw UPDATE, no transaction discipline bent.
The scope covers the book, tag and chapters as well as the notes — deliberately, since books sort
by NAME (`Queries.readings`), so nothing on the shelf moves either way, and a library whose notes
say 1892 while its book says today would be incoherent. **It stays PROVISIONAL:** her alternative
(stamp at seed time, accept the displacement) is one constant and one scope away, and
`publicationStamp`'s doc says so at the code.

## Fences

**ZERO `Sources/VariorumCore/Sync/` lines · ZERO `Persistence/` lines · ZERO schema · lockstep
marker untouched at 7** — diff-verified over the whole range. The author's real app was never
running (`pgrep` by the `/Applications` path empty throughout); no Release build, no
`/Applications` refresh.

## Verification at close

PENDING — filled below when the three suites complete.
