# Variorum for iPhone — THE PARITY & POLISH ROUND
### From great start to a great, faithful execution of the Mac app

*Authored 2026-08-03 at the author's directive, during the v1 gate
sitting (the sitting's full record: `notes/plans/mobile-app-plan.md`,
"GATE SITTING — RUN RECORD"). This plan is self-contained for a fresh
session and is the launchable unit the author asked for.*

---

## KICKOFF MESSAGE (paste-ready for the session that runs this)

> You are the architect/orchestrator for the Variorum for iPhone
> **parity & polish round**, under `/architect-phase` (the shape this
> project has run since its design sitting — M13's all-Fable cast is
> the standing default; the author may re-cast at kickoff). **She
> invokes each stage NAMING MOBILE explicitly (e.g. `/architect-phase
> mobile parity stage A`) from the `~/dev/variorum-mobile` worktree —
> a bare invocation resolves to the MAC master-plan pointer and is
> always wrong here.** Read, in
> order, IN FULL: `.claude/skills/architect-phase/SKILL.md` ·
> `CLAUDE.md` · **`notes/MobileSoul.md` — the SOUL DOCUMENT: the
> author's stand-in where she isn't guiding; its bar (100k words,
> memory included), architecture rule (brains in core/Shared, faces
> per platform), decision grammar, platform truths, and parity ledger
> BIND every batch and every PROVISIONAL judgment this round makes**
> · `notes/plans/mobile-app-plan.md`'s RUN RECORD (rulings
> M1–M14, LK1–LK11, the stage records, and especially the **GATE
> SITTING record** — every ruling this plan builds is recorded there
> verbatim) · this plan · `notes/plans/mobile-architect-handoff.md`
> (machinery lessons). Work in `~/dev/variorum-mobile`, branch
> `mobile` (if the merge to `main` has happened, verify with the
> author whether work continues on `main` or a fresh branch).
> Verify repo state (`git log --oneline -10`, `git status`) and
> spot-check the latest records before relying on them. **ONE
> INVOCATION = ONE STAGE (her restructure, 2026-08-03: "A-D seems
> like a lot for one phase" — each stage below runs as its OWN
> phase):** implement the stage's batches → ladder → closeout → her
> gate → HARD STOP; she kicks off the next stage herself. Standing
> discipline throughout: fresh implementer session per batch, a
> stage-end review ladder with fresh cold reviewers, red-on-old pins
> absolute, PROVISIONAL-and-continue for non-gating ambiguity,
> author-only calls as hard stops, **commit and push `origin` after
> every batch record, every fix pass, and every ruling recorded —
> never let the tree sit unpushed at a stopping point.** Update the
> CURRENT-STAGE pointer below at every stage close.

**CURRENT STAGE → C (capability parity by family) — Stages A and B
CLOSED 2026-08-09 (each ladder closed at round 2; the closeout
sections below have the records); the chain continues per her
kickoff ruling (no author gate between stages; ONE combined sitting
at the chain's end).**

## The mandate (what the author ruled this round INTO existence for)

All quotes and full context live in the gate-sitting record; the
binding headlines:

1. **THE PARITY RULING** (CoreDescription pillar 8, second ratified
   supersession): mobile is *"a complete, comprehensive app and
   solution… basically just as capable as the mac app"* — her
   daily-driver complement (*"like apple notes on the phone v.
   computer… it can't be a very lobotomized version"*).
2. **THE SEE-YOUR-DATA PRINCIPLE:** if it exists on the Mac and is
   her information, mobile shows that it exists — an editor or
   dedicated viewer is not owed.
3. **THE NO-REDIRECT PRINCIPLE:** a refusal that says "do it on the
   Mac" is a red flag; every such refusal is a parity finding to
   dissolve. Ceremony-adjacent complexity may keep a simpler road,
   but a road must exist.
4. **Her pacing:** step-by-step batches, the tutorial book proving
   functionality, everything simulator-testable.

**Explicitly NOT owed (her exclusions, verbatim in the record):**
Compare · the Snippets/scraps drag-into-note door (view + maybe-add
IS owed) · sticky-note-style editing (canvas) · workspace/windowing
(*"workflow and editor options, not a fundamentally different
capability"*) · two-pane Outline (retired into Compare on the Mac
anyway) · expand-all-fans · the reference side-by-side panel (the
"More info" list IS owed) · the ceremonies (simpler defaults stand
in) · **iPad, permanently** (portrait-locked iPhone; declaring iPad
capability forbids portrait-only — never declare it). **The FUTURE
LIST** (quick-capture widget · whole-data download link) stays
future; bulk import never.

## Stage table

| Stage | Scope | Gate |
|---|---|---|
| **A — The floor: defects & ruled fixes** | 1. The takes-peek scroll defect (Write surface, peek chrome — reproduce on simulator, red-on-old, fix). 2. `TARGETED_DEVICE_FAMILY` → `1`, portrait-only orientations, all mobile targets. 3. **Q-M1 (a)**: branch-under-refused-flush seeds from the card's shown bytes (pin). 4. **Q-M2 core+phone**: the duplicate-shape default divide (displayed take cut, every other take duplicated whole onto BOTH successors; shared core op — the Mac door change stays 13j's; A released to lineage unchanged; refusals for start/end cuts unchanged). 5. Note seal lock/unlock on mobile (the ruled door; refusal copy loses its redirect). 6. The spacing/padding FLOOR: a first systematic pass over the v1 surfaces (her finding: "the spacing needs to be fixed" — more padding generally; LK canon binds; screenshots to her at the stage gate). 7. **THE P-ROUND FLIPS (2026-08-04, dispositions in the gate record):** the Aa bar redesign (formatting acts condense into one Aa door — her words) · the P35 navigation inversion (book-tap → contents; Read is the door) · P33's shelf + New Note · P5's long-press heading picker · P24's typewriter-room bottom inset (verify/build) · P23's stale-I10 + P32's truncation rewording · P26/P43 voice-cased menus · P38's crowding corner. | Ladder; her screenshot look |
| **B — The tutorial book spine** | The mobile tutorial book (the 13b tutorial-as-spec precedent, phone-native): seeded content that exercises every shipped capability; simulator-drivable UI walks (scroll, tap, move) that fill it out and assert; it becomes the round's permanent acceptance spine — every later batch keeps it green. Reuse the Mac `TutorialSeeder` shape, never its Mac-specific copy. **Plus THE PERFORMANCE FIXTURE (the soul document's bar made executable): a seeded ~100k-word post + large corpus in the dev store, with a scripted measurement walk (open-time, typing latency, scroll, PEAK MEMORY) — from this stage on, every ladder includes its spot-check, corpus-flat.** | Spine green; perf fixture measured; her walkthrough |
| **C — Capability parity, by family** | The registry-driven audit: walk the Mac capability registry (P-1) against the phone; produce the PARITY MATRIX (owed / compromised-shape / not-owed-per-ruling, each row citing its ruling); then batches per family, matrix-ordered: **books & membership** (create book, move/add note between books, membership chip parity; **her LK5-rider expansion, 2026-08-04: the BOOK DETAILS surface off a book's contents — finish/unfinish as a v1 phone capability, tag editing there — and smart-book creation FROM tags**) · **tags** (browse, apply, create; tag posts — "full app functionality", her words; leaf-chip grammar) · **locks** (take lock/unlock joins the note seal) · **references** ("More info" list: see, add, open) · **scraps/Snippets** (view, maybe add) · **comments/callouts gaps** · **lenses, compromised shape** (her sketch: top-bar lens switching, save-current — design at the batch) · **the S5 conflict surface** (offline is the phone's normal — a conflict variant landing on the phone must be DISCOVERABLE there, the takes badge its natural face; verify + pin) · **remaining refusal-copy sweep** (no-redirect: every "on the Mac" string dissolves or names its sanctioned exception). Each batch: brief → fresh implementer → record → tests; the spine green every batch. | Per-family ladder rounds |
| **D — Polish & the look round** | The whole-app spacing/design pass against the LK canon with her screenshot rounds (the L11 design/beauty ledger row realized); remaining P1–P44 flips as she makes them; device feel-round riders (loupe, badge target, marker z-order, sheet keyboard, Write→Read freshness); **the 14b ACCOUNT/ENCRYPTION pages' UI/UX pass (her instruction at the pre-Stage-A close, 2026-08-04): the tabbed Account sheet, the stepped E2EE setup, enrollment/locked/replaced states, and the sync row as the phone renders them — her words: "they work, I just think they're a bit ugly right now and don't follow UI principles"; these are SHARED views shipped functional-and-unstyled by convention, so the pass styles through the one seam (voice tokens / platform-conditional layers), never a fork — Mac-side beauty coordinates with the Design & UI review row**; **the exit gate runs the 100k performance fixture ON DEVICE** (latency AND peak memory — her explicit bar). **At D's close (her plan, 2026-08-04): the first INTERNAL TestFlight** — *"super basic internal testflight… for just me and whoever I add"* — her word triggers it; Stage E carries the readiness work that broader exposure needs. | Her acceptance + the on-device 100k run |
| **E — TestFlight & store readiness** (her directive 2026-08-04, the Fragments-precedent phase shape) | **ENTRY GATE (her batch-1 ruling): the parity ledger is EMPTY or every open row consciously deferred by her** — 13-phase results absorb continuously at every stage kickoff, and a re-runnable ledger round handles pile-ups; broad exposure never ships with unexamined parity debt. The broad distribution considerations, gathered in one stage: **the Dynamic Type + VoiceOver audit** over the custom surfaces (badge, peek strip, seams — moved here from D at her word); the privacy policy page (near-trivially short for a local-first app — which is exactly why it should exist; composes with the Mac v1-readiness row's, one story for both); App Store screenshots + listing copy; the privacy manifest + encryption-export declaration; TestFlight external-group setup when she wants beyond internal; *[removed for publication]*. Portrait-only/iPhone-only already ruled and shipped by Stage A. | Her acceptance; a submittable build |

**Not this round's:** the Mac-side 13j build (divide default door +
keybind, restoration-doors sitting, the lens loud-fallback door) —
recorded on the 13j row, runs as a Mac phase after Phase 14. S5's
sync soak rides real use. TestFlight at stability (M14).

## Discipline (standing, restated so the plan is self-contained)

- **Cast:** `/architect-phase`; all-Fable default (M13); the author
  may re-cast at kickoff. Fresh implementer per batch; fresh cold
  reviewer per ladder round; strictly sequential.
- **Tests with every step; red-on-old absolute** (the hallucination
  guard: trace the mechanism before fixing; a pin passing on both
  sides exposes a hollow finding). The tutorial spine green from
  Stage B on. Simulator: iPhone 17 family, newest iOS runtime (LK1).
- **Commit + push `origin` regularly — part of the plan by her
  explicit instruction:** after every batch record, fix pass,
  adjudication, and recorded ruling; never end a working bout
  unpushed.
- **PROVISIONAL-and-continue** for non-gating ambiguity, bundled to
  her at stage gates; author-only calls (product invention, invariant
  changes, dependencies, schema) are hard stops. **NO schema** (a
  need = SyncSpec §12 lockstep event — stop, mirror-first, her go).
  **`Sources/VariorumCore/Sync/` untouched** (Fable-only rider moot
  under an all-Fable cast, but the boundary stands).
- **Core changes are legal where a ruling demands them** (Q-M2's op)
  — four-suite duty every time (mobile · core · Mac · spine), zero
  Mac behavior change beyond what a ruling ordered.
- **Repo-first records:** every batch brief/record in THIS file or
  the run record it points to; her rulings verbatim, same turn.
- **Machinery lessons bind** (`mobile-architect-handoff.md`): the
  wrong-core pbxproj trap · `UITextView(usingTextLayoutManager:)`
  factory trap · attribute re-stamping on every insertion path · the
  spine's seven suite-type names · her interleaved rulings recorded
  same-turn.

## Branch & merge discipline (added 2026-08-03 at her merge-go; BINDING for every stage)

Nothing about branch synchronization is automatic — it is THIS
discipline, executed by sessions, that keeps the two lines healthy:

- **The layout:** mobile work continues in the `~/dev/variorum-mobile`
  worktree on branch `mobile`; the Mac phases (14a now) work `main` in
  `~/dev/variorum`. The v1 gate merge (`mobile` → `main`, 2026-08-03)
  carried the whole mobile build + every gate ruling to `main`.
- **PULL `main` IN at every good moment:** `git fetch && git merge
  origin/main` into `mobile` at EVERY stage kickoff and EVERY batch
  boundary (and before any ladder round). **14a is actively changing
  shared code — the sign-in machinery (`App/Variorum/Shared/` auth
  shells, and the mirror-side expectations) is shared between Mac and
  mobile, and 14a's batches will update BOTH surfaces through it.**
  A stale `mobile` branch working on pre-14a auth shells is the
  failure this rule exists to prevent. Conflicts resolve in the
  mobile worktree, never in the Mac's.
- **MERGE `mobile` BACK at stage ends, with her prompt:** every stage
  closeout ends by ASKING the author whether this is a good moment to
  merge `mobile` → `main` (14's state decides; plain merge, never a
  rewrite). Never auto-merge outward without her word; never end a
  stage without asking.
- Both directions push `origin` immediately after merging.

## State at authoring (2026-08-03)

- v1 gate sitting RAN on-device; the build verified compiling +
  signing for a physical iPhone. Q-M1 ruled (a); Q-M2 ruled (her
  duplicate shape); the parity/see-your-data/no-redirect principles
  recorded; the exclusions and FUTURE LIST recorded; P1–P44 stand
  silent-as-shipped except any flip she makes in Stage D.
- **Merge `mobile` → `main` PRECEDES the round's kickoff** (her
  directive: notes complete + plan launchable → merge, at a Phase 14
  pause). The merge carries the Q-M2 core shape and every record to
  the Mac codebase before any 13 phase builds on them.
- The 14a suite-identity work runs in the main worktree in parallel;
  nothing in this round touches auth (the suite-account change lands
  on the phone through the shared shells when 14a ships it).

## PRE-STAGE-A: the 14b real-sync phone build (author's instruction, 2026-08-04 ~3:40am)

*Recorded at her word, before Stage A — this section is self-contained:
if the session that scheduled the morning check is gone, a fresh
session executes from here. Main's own record of the same arrangement
is the 14b round-6 commit (e9eb5ed): "mobile merges main in the
MORNING, post-batches; Release install per the A4 fence; a pre-14b
build refuses marker 5 by design."*

- **What she asked for:** a build on her phone with **real sync** so
  she can sign in (14a's direct email+password form through the shared
  seam; verification pages live at stargazing.tech), enter her E2EE
  passphrase to enroll (the PL-6 ledger row), and verify sync over the
  encrypted mirror — 14b's morning gate step. This deliberately
  supersedes, for now, the loose "real phone sync waits for
  TestFlight" tie-in.
- **The 7am check** (a ~6:57am one-shot is scheduled in the live
  mobile session; session-only, so if that session died she messages
  at 7 and this section is the instruction): in
  `~/dev/variorum-mobile` on `mobile`, `git fetch origin`, then the
  landing signal — `git show
  origin/main:Sources/VariorumCore/Sync/SyncSchema.swift` must read
  `lockstepVersion = 5` AND `git log origin/main` must show 14b
  batch/ladder commits. **Not landed → report and WAIT for her word;
  nothing else.** Never merge from pre-14b main: a marker-4 client
  refuses the migrated mirror by design.
- **On landed:** merge `origin/main` → `mobile` (notes-file conflicts
  resolve as the UNION of both sides' records — the c928a33
  precedent); run the mobile suite; build the Release phone build —
  `xcodebuild -project App/Variorum/Variorum.xcodeproj -scheme
  VariorumMobile -configuration Release -destination
  'generic/platform=iOS' build` — **Release, never Debug** (Debug is
  the dev-store fence and must never touch her corpus); commit and
  push `mobile` only — **never push main** (active 14b development).
- **EXECUTED 2026-08-04 ~7:00am** — landed signal confirmed (marker 5,
  ladder closed round 2), merged clean (code byte-identical to main's
  ladder-verified tree outside `notes/`), mobile 173/25 green, Release
  built + installed over the Wi-Fi tunnel (the locked phone took it).
  **Her first-look finding, fixed same hour: the DOORLESS sign-in
  states.** She saw "Checking this account's encryption state…" with
  no way to log in — a stale Keychain session (only `signOut()`
  clears, the 9c contract) reads as signed in, its dead token fails
  the vault fetch, and the keys check's designed zero-transport-contact
  refusal hides the auth problem behind the locked face. THREE doors
  added on the SHARED surface (the Mac inherits at the next
  mobile→main merge — the 14b Mac session should know):
  `SyncStatusRow`'s keys-locked arm gains "Account…" beside "Unlock…";
  `EncryptionView`'s `.signedOut` arm gains "Sign in…" and its
  `.unknown`-with-error arm becomes an honest failed-check face with
  "Account…" (spinner dropped — it claimed still-trying forever);
  the account sheet's dismissal re-resolves the encryption state.
  The 13b doctrine applied, not new behavior: a message naming an act
  offers the act's door. Mobile suite re-run green; rebuilt,
  reinstalled.
- **THE NEXT ROUND (her directive, 2026-08-04 morning, after the door
  fixes):** the Mac is landing capability + copy changes THROUGHOUT
  the E2EE flow right now — **do not pull main until her word.**
  Sequence, hers: (1) she says pull → merge latest main; (2) mobile
  makes the changes the merge implies; (3) at her word, merge to
  `main`. **The BINDING design rule for those changes: the phone
  might be the ENROLLER** — the setup flow, the screens along it, and
  the saving-12-words ceremony get mobile-world care, and her named
  case verbatim: "if a user switches apps to save their passphrase or
  12 words somewhere the flow shouldn't just disappear." Concrete
  classes that must hold on iOS: the flow's state (incl. the
  shown-once `generatedWords`) survives backgrounding and return; the
  ceremony sheets refuse casual swipe-dismissal; and scene DEATH
  mid-ceremony is tolerable by construction — nothing lands until the
  re-entry confirm (Round 5's order), so a killed app re-offers
  generation rather than dangling a half-written vault. Copy is
  copied WITH care from the Mac's flow, not invented fresh (the
  wording rides the 14b GATE RATIFY block).
- **THE NEXT ROUND — EXECUTED (2026-08-04 morning, her "you can pull
  main" + the 14b flow-notes work order):** final main merged in TWO
  pulls (the copy/flow + crossover rounds, then nothing new at her
  "main is final" — the morning merge already carried the cold-pass
  tip c86a2e5). The pre-Stage-A door fixes RESOLVED to main's CF-14
  shape (tabs absorb the doorless states structurally; the conflict
  taken theirs, nothing forked). The adaptation shipped: **(1)** the
  lifecycle care verified by inspection — the mobile shell touches
  nothing on scenePhase but flush+sync, every layer of the sheet
  chain is plain preserved @State, so background→foreground is the
  same step with the same words, and the kill case resumes step 4 by
  state (the notes' traced architecture, untouched); **(2)** the
  app-switcher SNAPSHOT COVER — weighed and BUILT, PROVISIONAL for
  her walk: `SnapshotPrivacy.redactionReasons` at the shell root +
  `privacySensitive` on exactly the numbered words display and the
  three phrase entry fields (shared-file marking, inert on the Mac by
  construction — no redaction reasons are ever applied there); two
  rule pins in `MobileSnapshotPrivacyTests`; **(3)** BIP-39 entry
  ergonomics — the three phrase fields share one `phraseEntryField`
  helper: autocorrect off (carried) + auto-capitals off on the phone
  (validation folds case, but a capitalized first word READS wrong);
  **(4)** the terminology pin holds (no forbidden word anywhere,
  comments included). Mobile suite **175/26 green** (173/25 + the two
  pins, exactly accounted). NOT walked visually: the full-setup
  first-run (.noVault) path — no safe live subject exists until a
  non-her account (14c); its gates are pure pinned functions, its
  layout carries no fixed widths, and step 4's screen is safely
  viewable on her phone via Regenerate-then-Cancel (the words display
  + cover + field ergonomics all exercise there). Her drill covers
  the rest live: forget → CF-16 replaced state → re-enroll → the
  phrase road with her NEW 12 words.
- **PRE-STAGE-A CLOSED (2026-08-04, her sign-off):** the PL-6 build
  half merged to `main` at her word — a FAST-FORWARD (c86a2e5 →
  9674395; `mobile` already contained final main, so the histories
  never diverged), pushed both branches, her `~/dev/variorum` main
  checkout updated in place. `/Applications` deliberately NOT
  refreshed (her real-store instance mid-drill; the merge's Mac-side
  delta is inert by construction — the next Mac session's refresh
  covers it). The drill build is installed on her phone. Her two
  closing directives: **(1)** the pages built today get a UI/UX pass
  at STAGE D (recorded in the stage table's D row — "they work, I
  just think they're a bit ugly right now and don't follow UI
  principles"); **(2)** her words: "I'll next see you after phase 14
  is fully complete for the mobile parity stage A invocation" —
  Stage A waits for the WHOLE 14 family (14c included), then runs as
  its own `/architect-phase mobile parity stage A` from this
  worktree.
- **Install DIRECTLY at build-ready (her ~3:50am blessing — this
  supersedes the earlier hold-for-her-go):** her words: "go ahead and
  automatically install to my phone if you're able to in the morning
  when the new item is built … you have my blessing to install it
  directly if you wake up at 7, complete the phase, and have a new
  build ready for me." Install via `xcrun devicectl device install
  *[removed for publication]*
  Build/Products/Release-iphoneos/VariorumMobile.app` (scheme
  *[removed for publication]*
  `-allowProvisioningUpdates` to the build). She acknowledged a
  locked phone may refuse the install — on failure, report BUILD
  READY + install pending and retry at her word; never loop retries.
  Installing ahead of the mirror wipe is safe by construction: a
  fresh install sits signed out, and nothing syncs until she signs in
  and enrolls with her passphrase — the E2EE gate IS her passphrase.

---

## STAGE A — KICKOFF (2026-08-09; the chained-run session)

**Her invocation (`/architect-phase mobile parity stage A`, this
worktree), rulings verbatim-faithful:**

- **THE CHAIN RULING (supersedes the one-invocation-one-stage letter
  for THIS run only):** asked whether to hard-stop at A's gate or
  chain the stages, she ruled: *"I'll be connected and able to check
  on things via my mobile phone's RC connect, but my only concern is
  if the context window will become overly full if we do all of Chain
  A->D in one pass. I think A->D is fine, but the orchestrator should
  prepare a handoff message if the context window becomes overly
  full, and I'll be able to paste that new message into a new chat if
  needed. I think chaining A->D is otherwise fine."* Consequence:
  stages still run as their OWN phases (batches → ladder → closeout →
  pointer update), but the next stage kicks off at the previous one's
  close without her word; every screenshot look, PROVISIONAL, and
  bundled ruling collects into ONE combined sitting at the chain's
  end. Stage D's inherently-hers items (the on-device 100k run, the
  feel riders, her acceptance, the TestFlight trigger) wait there.
  Author-only hard stops still stop the chain. **The context proviso
  is a standing duty:** at any sign of an overly full window, the
  orchestrator writes the two-document handoff (role file with a
  paste-ready successor kickoff + the plan file current) and tells
  her — she pastes it into a fresh chat.
- **Branch discipline this run, hers:** *"I'm mid stage 14c on the
  variorum mac app side - so don't merge into main. however, you can
  merge current main in before you start working (it was mostly
  database changes to allow for multi user)."* So: NO outward merge
  this chain — the stage-end merge ask is pre-answered until she says
  otherwise; inward pulls at stage kickoffs and batch boundaries per
  the standing discipline.
- Her framing kept: *"I like having a real app that syncs on my
  phone, so it was a good move to enable real sync and usage at this
  point in time."* The phone's live sync is a working asset; nothing
  this chain does may break it (the install hold below).

**The kickoff merge (executed 2026-08-09):** `origin/main` → `mobile`
FAST-FORWARDED `09a0dfc` → `0ded142` (mobile held nothing main
lacked; zero conflicts; the tree is byte-identical to main's 14c
build-half ladder-verified tip). Pushed. Baseline counts stand by
that tree's own recorded verification — **core 1201/127 · Mac
1240/219 tripwire-only · mobile 175/26 · spine 51/7** (0ded142's
record: the last two fix commits touched no Sources/ or App/ code) —
no session-start suite run, per the standing rule.

**THE INSTALL HOLD (BINDING all chain long):** the merged client's
`lockstepVersion` is **6** (14c's reborn-mirror event); the LIVE
mirror is still **marker 5** — 14c's deploy is its gate half's act
and has not run. A phone install from this tree would refuse to sync
by design (SyncSpec §12), and her phone's current marker-5 build
syncs today. Therefore **no Release install to her phone from this
tree until 14c's gate deploys the mirror** (or her explicit word).
Everything this chain builds verifies on the simulator (Debug = dev
store, the A4 fence; sync untouched). PL-5's remaining live-phone
sign-in verify rides the end bundle behind the same hold.

**Ledger sweep (the kickoff duty):** no Mac closeout has landed since
14b's (PL-6 CLOSED; 14c is mid-phase — its parity line arrives at ITS
closeout; this chain re-sweeps at every stage kickoff per the
continuous-absorption ruling). Open rows PL-1…PL-4, PL-7 all wait on
unrun Mac phases; nothing to absorb today. The kickoff merge DOES
carry 14c's tier/onboarding shared views (`TierViews.swift`) onto the
phone through the one seam — functional-by-convention; their look
joins Stage D's shared-surface pass beside the 14b Account/Encryption
pages if her look flags them.

**Stage A batch structure (three batches, a fresh implementer each,
strictly sequential):**

- **A1 — the defect + the mechanical floor:** the takes-peek scroll
  defect (reproduce → trace → red-on-old → fix) · the iPhone-only/
  portrait-only target flip · Q-M1(a) seed-from-shown-bytes + pin ·
  the note seal lock/unlock door (the refusal loses its redirect) ·
  the P23 + P32 rewords.
- **A2 — Q-M2, core + phone:** the duplicate-shape default divide as
  a shared core operation + the phone's divide door adopting it. The
  chain's one deliberate core-touching batch; the four-suite duty
  fires; ZERO Mac behavior change (the Mac door change is 13j's).
- **A3 — the ruled UI flips + the spacing floor:** the Aa bar
  condensation · P35's book-tap inversion (contents first; Read is
  the door) · P33's shelf + New Note · P5's long-press heading
  picker · P24's typewriter-room inset (verify/build) · P26/P43
  voice-cased menus · P38's one-line fanned+commented crowding
  corner · then the first systematic spacing/padding pass (LK canon
  binds; screenshots gathered for the end bundle).

Then the Stage A ladder over the combined diff (fresh cold reviewer,
`notes/REVIEW_PROMPT.md` verbatim; round 2 re-reviews; cap three),
the stage closeout, pointer → B, and Stage B kicks off in-chain.

## Environment traps (carried verbatim from `notes/plans/mobile-app-plan.md` — BINDING for every batch this round)

- Simulator destination: **iPhone 17 family on the MOST RECENT iOS
  runtime — her standing rule (LK1: "def only go for the iPhone 17 most
  recent iOS simulators")**. Today that is
  `-destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2'`;
  when a newer runtime lands, move to it and re-verify. The iPhone 16
  sims on this machine are iOS 18.3 — BELOW the deployment target; they
  resolve to nothing (the sitting's own trap).
- Mobile tests: `xcodebuild test -project App/Variorum/Variorum.xcodeproj
  -scheme VariorumMobile -destination …` from the repo root; confirm the
  "Test run with N tests" line; zsh `pipestatus`.
- The A4 fence: debug/simulator builds resolve the DEV store and never
  sync — safe by construction; NEVER point a debug build at the real
  store; her phone installs Release (M14).
- Shared-core discipline: touch `Sources/VariorumCore` only deliberately
  and small; before landing any shared-core change, verify core + Mac
  suite + spine by own runs (current baseline: core 1201/127 · Mac
  1240/219 with the recorded tripwire · spine 51/7); Mac tests run from
  `App/Variorum/`. `Sources/VariorumCore/Sync/` stays untouched (the
  boundary stands regardless of cast).
- Worktree: merge `main` → `mobile` regularly; `mobile` → `main` at
  milestones at her word — **pre-answered NO for this chain (mid-14c)**;
  push `origin mobile` after commits.
- NO schema; a schema need is a SyncSpec §12 lockstep event
  (mirror-first, her explicit go) — stop and report.
- NEVER add a custom build configuration (the 4G trap — SPM deps build
  Release under any configuration not named exactly "Debug", silently
  stripping DEBUG-gated oracles).
- Spike code lives under `App/Variorum/VariorumMobile/Spike/`,
  DEBUG-gated, its UITest half behind the separate `TK2SpikeUITests`
  scheme — KEPT as the executable TEXTKIT2 §5 form for iOS point
  releases. It never rides the baseline suite.
- **The install hold (this chain):** client marker 6 vs live mirror 5 —
  no Release install to her phone until 14c's mirror deploy lands.

## Stage A, batch A1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, working in
`~/dev/variorum-mobile`, branch `mobile`, starting at `0ded142`.

**Read first, IN FULL, in this order — your own reading, never a
summary:** `CLAUDE.md` · `notes/MobileSoul.md` · THIS plan file
(`notes/plans/mobile-parity-round.md`) top to bottom ·
`notes/plans/mobile-app-plan.md` §§ "The settled shape" (~line 313),
"Environment traps" (~473), "GATE SITTING — RUN RECORD" (~5716 to the
file's end — the rulings this batch builds), the Stage 2 batch-1
brief + record (~1786–2076 — the peek chrome item 1 fixes), and the
Stage 2 ladder's branchDisplayed/flush findings (~2435–2770 — item
3's adjacent context) · `notes/plans/mobile-architect-handoff.md`
(machinery lessons). The Environment traps section above BINDS.

**Items (each lands with tests; red-on-old by behavioral revert for
every bug-class fix — the hallucination guard is absolute):**

1. **The takes-peek scroll defect.** Her report, verbatim in the gate
   record: *"it seems that you can't actually scroll when the app has
   takes open, so i could make a new take but i couldn't scroll down
   through the list of takes to edit it better"* — pinned by her to
   the S2 peek chrome on the WRITE surface (the takes button), NOT
   the LK4 browser sheet. Reproduce on the simulator FIRST (a note
   whose takes/text need scrolling; peek open). Trace the concrete
   mechanism yourself — gesture arbitration between the peek strip's
   pan/swipe recognizers and the scroll view is the obvious suspect,
   but trace, never pattern-match. Fix WITHOUT breaking the ruled
   swipe grammar (swipe flips takes · sticky peek · explicit ✓ — the
   M rulings). Red-on-old pin.
2. **iPhone-only, portrait-only (the platform ruling).**
   `TARGETED_DEVICE_FAMILY` `"1,2"` → `1` and the landscape iPhone
   orientations dropped, on EVERY mobile target (app + test hosts +
   the spike target if it declares its own). Never declare iPad
   capability (her ruling: declaring it forbids portrait-only). A pin
   lands: a test asserting the built product declares device family
   1-only and portrait-only orientations — exact shape your judgment.
3. **Q-M1 (a) — seed-from-shown-bytes.** Her ruling: branching a take
   under a REFUSED flush seeds the new take from what the card SHOWS
   (the pending bytes ride into the new take). Locate the
   branchDisplayed path (the S2 ladder's flush-first MAJOR is your
   adjacent context — read its disposition). Red-on-old pin for the
   refused-flush case specifically.
4. **The note seal door.** Her ruling: *"i do think that you should
   be able to unlock a note and lock it on mobile."* Route through
   the core's `lockPost`/`unlockPost` operations (the seal's
   auto-commit insurance already rides them). Place the door where
   the note's acts live — your judgment, named and justified in the
   batch record; wording consistent with the shipped register (A3
   does the full P26/P43 voice-case sweep — don't fork registers).
   The sealed-note refusal copy LOSES its "unlock it on the Mac"
   redirect: the message names the act and offers the door (the 13b
   fire-and-DO doctrine, already applied once on this surface — the
   pre-Stage-A door fixes are the precedent). State-transition tests
   through the view model + copy pins.
5. **Two rewords, copy pins updated, no new capability.** P23: the
   stale I10 refusal line rewords — the phone HAS a delete door since
   S4; the "Mac gesture" tail violates no-redirect and goes. P32: the
   truncation marker rewords neutrally (no "lives on the Mac");
   load-more stays deferred with the Mac's bounded-window family.

**Discipline:** work synchronously — never end your turn waiting on a
background build; run every build/test to completion in-turn. Mobile
suite green by your OWN run at the end (record the "Test run with N
tests" line). If anything under `App/Variorum/Shared/` changes, run
the Mac suite too (from `App/Variorum/`); `Sources/VariorumCore/`
changes are NOT expected in this batch — a fix that seems to want one
STOPS and returns to the architect first. Commit per logical item
with the standing trailer; write the batch record into THIS file
(counts, mechanisms traced, pins named, door placements justified,
PROVISIONALs); push `origin mobile` before finishing.
PROVISIONAL-and-continue for non-gating ambiguity; author-only calls
stop the batch.

## Stage A, batch A1 — BATCH RECORD (implementer, 2026-08-09; commits `a95839d` · `4473ba8` · `647a430` · `8163b0e` · `ddde966` + the record commit)

**All five items shipped.** Per item:

1. **The takes-peek scroll defect — TRACED AND FIXED; the recorded
   surface pin did not survive reproduction.** Reproduction ran FIRST,
   both roads, on the iPhone 17 Pro / iOS 26.2 simulator: **(a)** a
   throwaway real-touch UITest (driven through the TK2SpikeUITests
   scheme; deleted after use) walked her exact flow in the REAL app —
   new note, ten wrapping paragraphs, ⑂, branch, done, horizontal
   swipe — and proved the WRITE-SURFACE PEEK SCROLL HEALTHY: with a
   peek active and the pill showing, vertical swipes moved the
   content-anchored badge oracle across the full scrollable range,
   both directions, twice, and the swipe still flipped (pill
   appeared). The gesture-arbitration suspect (and the gate record's
   "NOT the LK4 browser sheet" pin) is REFUTED with evidence; a
   headless probe additionally cleared contentSize integrity, offset
   retention across layout ticks, hit-test routing, and the pan
   router's vertical-translation refusal. **(b)** The BROWSER SHEET's
   mechanism was measured cold: a full-bounds manual-frame overlay
   with ZERO keyboard relationship — footer/new-take doors at y≈800
   and the card band to y≈648 on the phone-class window, against a
   keyboard whose own measured height is 233 pt (top ≈641) — so the
   moment minting raised focus (the S2 MINOR-2 fix, exactly "i could
   make a new take") the card list's max scroll offset ignored the
   occluded band — with few takes it is exactly ZERO, the list cannot
   scroll at all ("you can't actually scroll") — while the live card
   and the footer sat behind the keyboard ("couldn't scroll down
   through the list of takes to edit it better"). The S2 ladder's own
   flag-5 rider predicted this bite verbatim ("once focus rises, the
   missing keyboard-guide constraint bites more often"); her gate
   report IS that feel-round finding. The sheet rides OVER the Write
   surface (page visible behind) and is entered from the takes button,
   so her pin's words describe this overlay exactly. *Fix
   (`MobileTakesBrowserView`):* the sheet's layout gains the
   keyboard's share — `keyboardEndFrame` fed by the system
   keyboard-frame notifications (the sheet is manual-frames, so the
   guide-constraint mechanism doesn't fit; tests post the same
   notifications deterministically), footer + card band end ABOVE the
   keyboard (the band's max offset now accounts for every covered
   card), and the live card is REVEALED once per editing transition
   and once per keyboard move, never per render (her own scrolling is
   not fought). The ruled swipe grammar is untouched (all peek/✓ pins
   green). *Pin:* `theKeyboardNeverStrandsTheCardListFooterOrLiveCard`
   — revert-verified: pre-fix mechanism restored → **3 issues**
   (footer 688>400 · band 648>400 · the deepest live card at 833
   outside the 485 band), 8 sibling tests green (discrimination); fix
   restored → green. *Honest limits, for the stage's device round:*
   the simulator harness would not present the software keyboard
   (hardware-keyboard state persists in headless runs — the keyboard
   element parks offscreen with its real height), so the fix's live
   confirmation rides the stage's on-device look; and if her defect
   has a second arm that only real fingers on a real phone surface,
   the write-surface refutation should be re-checked there once.
   *Ladder note:* the reveal pin initially targeted the branch mint
   and passed on old code (hollow — `branchVariant` mints BESIDE its
   source, near the top); re-aimed at the deepest card by frame, it
   discriminates. Recorded per the hallucination guard.

2. **iPhone-only, portrait-only (the platform ruling).**
   `TARGETED_DEVICE_FAMILY` `"1,2"` → `1` on ALL SIX mobile build
   configs (app + unit-test host + UITest/spike host, Debug and
   Release each); the `_iPad` orientation declaration DROPPED entirely
   (never declare iPad capability — her ruling's letter); iPhone
   orientations reduced to portrait alone. Mac-side config blocks
   byte-untouched (verified by mapping each settings block to its
   bundle id), and the Mac target re-verified: **BUILD SUCCEEDED**
   after the pbxproj edit. *Pin:*
   `theBuiltProductIsIPhoneOnlyAndPortraitOnly` — reads the BUILT
   product's Info.plist through the hosted suite's `Bundle.main`
   (`UIDeviceFamily == [1]`, orientations == portrait-only, no
   `~ipad` key), so pbxproj drift fails in CI, not on her phone. Run
   RED on the pre-flip declarations first (families `[1,2]`,
   landscape declared — 2 issues), green after the flip.

3. **Q-M1 — RULED (a), BUILT: branch under a refused flush seeds from
   the card's SHOWN bytes.** *Traced (the S2 round-2 NIT's own
   scenario):* you typed into a take a remote lock then froze; the
   locked refusal RECOMMENDS branching — but `branchDisplayed`'s
   flush refuses (`lockedVariant`; the MINOR-1 keep-pending posture
   holds the bytes), `branchVariant` copies `working_text` from the
   STORE, and the mint carried the frozen bytes while the source card
   showed the pending ones. *Fix:* the displayed take's
   `surfaceKnownText` (exactly what `cards()` renders) is captured
   before the mint; where it differs from the mint's store copy it
   rides into the new take through the ordinary card-edit road
   (`recordTakeEdit` → the refresh's flush — the mint is fresh and
   unlocked, so it always lands, BEFORE `beginEditing` attaches the
   card editor so the live card opens on the seeded bytes). A
   successful flush makes the seeding a byte-for-byte no-op — the
   ordinary road is untouched. *Pin:*
   `branchUnderARefusedFlushSeedsFromTheShownBytes` (card edit on the
   chosen take → remote lock delivered → branch → the mint's ledger
   record AND store row hold the typed bytes; the source stays
   keep-pending exact: frozen store bytes, pending card bytes) —
   revert-verified: seeding disabled → **2 issues** (mint ledger nil,
   mint store row stale), 20 siblings green; restored → 30/2 green
   across both browser suites.

4. **The note seal door + the sealed refusals lose the redirect.**
   *Doors:* `MobileEditorViewModel.lockNote()/unlockNote()` through
   the core's own `lockPost`/`unlockPost` (the seal's auto-commit
   insurance rides them — pinned: one `commit_point` for the dirty
   buffer at seal, zero on unlock, I6's
   consequence-not-equivalence). `lockNote` is FLUSH-GUARDED like
   every structural door — *traced:* a pending surface edit left
   behind the seal would refuse at its later flush (`.lockedPost`)
   and the typed bytes could never land (the text-loss class) — so
   pending text lands BEFORE the seal, and a flush that cannot land
   (locked take, keep-pending) refuses the whole act with the
   standing wording, note left open. *Placement (named + justified):*
   the MASTHEAD — the phone's note-identity surface and its only
   note-level acts home (block acts live in the bar's ⋯; the seal is
   the NOTE's own state, already displayed there): a state-mirroring
   lock glyph beside the title (one reversible tap each way — the
   seal is a guard, never a snapshot), plus **"Unlock Note" on the
   sealed state line itself** (fire-and-DO: the line naming the state
   offers the act; the masthead stays visible above the browser
   sheet, so every sealed refusal's "unlock it" has its door in
   view). *Copy sweep (sanctioned pin flips riding the ruling):* all
   EIGHT sealed-note sites drop "on the Mac" → "This note is locked —
   unlock it to ⟨act⟩."; the locked-TAKE / archived-take copies
   deliberately KEPT for Stage C's locks family. *Tests:*
   `MobileNoteSealTests` (a new suite): seal/unseal state transitions
   through the VM against the store, the new gate copy pinned, the
   refusing arm pinned; the flush-guard mutation-checked (blind seal
   restored → **4 issues**: stranded store bytes + the blind seal
   landing; restored → green); the affected suites 66/6 green. The
   SwiftUI masthead wiring itself (3-line doors onto the tested VM
   methods) is not headless-testable in this harness — recorded, the
   stage's screenshot look covers it.

5. **The two rewords.** **P32 BUILT:** the truncation marker rewords
   neutrally — "the full book lives on the Mac" (both book surfaces)
   → "Showing the first N notes — the rest of this book isn't loaded
   yet.", hoisted to ONE shared sentence
   (`MobileBookViewModel.truncationMarker`) consumed by the note list
   AND the Read flow so the copy can never fork; load-more stays
   deferred with the Mac's bounded-window family (Phase 12's row).
   Copy pin `theTruncationMarkerCarriesNoMacRedirect` (exact wording
   + no "Mac"). **P23 VERIFIED ALREADY SATISFIED — no change owed:**
   the stale S2 I10 line ("Deleting the whole block is a Mac gesture
   for now") was retired at S4 batch 1 when the phone's Delete Block
   door landed; the shipped copy names the phone's own ⋯-menu door
   and is pinned in MobileTakesBrowserTests + MobileWalkTests (both
   green this batch). The P-round flip was recorded against the
   S2-era copy; the record here closes it with evidence rather than a
   redundant edit.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2):**
full mobile suite — **"Test run with 181 tests in 27 suites passed"**
— the 175/26 baseline + this batch's six pins and one new suite,
exactly accounted (keyboard pin · platform pin · Q-M1 pin · 2 seal
tests · truncation pin). **Core / Mac / spine deliberately not run:**
the batch's diff carries zero `Sources/VariorumCore`, zero
`App/Variorum/Shared/`, zero Mac-side source, zero schema, zero
`Sync/` lines — the brief's only-if-shared condition never fired; the
one shared FILE touched (the pbxproj, mobile config blocks only) was
covered by a Mac-target build: **BUILD SUCCEEDED**.

**PROVISIONALs (for the chain's end bundle):**
- **PA1-1:** the seal door's visual form — the masthead lock glyph
  (SF `lock`/`lock.open`, muted-vs-accent by state) and the
  system-register "Unlock Note" wording (the block menu's own
  register; A3's voice-case sweep may recase). Placement itself is
  justified above, not provisional.
- **PA1-2:** the browser's keyboard feed rides the system keyboard
  notifications rather than a `keyboardLayoutGuide` constraint (the
  sheet is manual-frames; the guide is a constraint mechanism) — a
  mechanism interpretation for the ladder, with the portrait-locked
  window making the screen/window coordinate identity exact.
- **PA1-3 (finding, not a provisional):** the gate record's surface
  pin ("the S2 peek chrome, NOT the LK4 browser sheet") did not
  reproduce under real touches; the browser's keyboard blindness did,
  and matches her words exactly. If her defect has a second arm only
  a physical device surfaces, the stage's device round should
  re-check the write-surface peek scroll once on her phone.
- **A3 note (P24):** the real-touch run observed a small scrollable
  range past the document's end on the Write surface — consistent
  with the typewriter-room bottom inset being absent; evidence for
  A3's verify/build item.

**Deliberate absences (scope, not holes):** take lock/unlock and the
remaining refusal-copy sweep (Stage C's families — the locked-take
copies still name the Mac by design until that batch); the Aa bar /
P35 / P33 / P5 / P24 / P26/P43 / P38 and the spacing floor (A3);
Q-M2's core divide shape (A2, the chain's one core-touching batch).

## Stage A, batch A1 — ACCEPTED (architect, 2026-08-09)

Verified by spot-check + own runs before relying on anything above
(the never-trust rule): all six commits present (`a95839d` …
`3087f27`), diff scope confirmed — 20 files, **zero**
`Sources/VariorumCore/` lines, zero `Shared/` lines, the pbxproj edit
mobile-configs-only with the Mac build check recorded; the mobile
suite re-run by the architect's own hand: **"Test run with 181 tests
in 27 suites passed"** — the 175/26 baseline + six pins + one suite,
exactly accounted. `main` unmoved at the batch boundary
(`0ded142`; no inward pull needed).

**The surface-pin adjudication (PA1-3's substance — recorded so the
ladder and her end bundle read one story):** the gate record's
"NOT the LK4 browser sheet" line was the PRIOR architect's
interpretation of her second report, not her words — her words were
*"i could make a new take but i couldn't scroll down through the list
of takes to edit it better."* The implementer's real-touch runs
proved the Write-surface peek scroll healthy (badge oracle full
range, both directions, grammar intact) and traced a REAL scroll
defect in the browser sheet: keyboard-blind layout — minting raises
focus, the keyboard occludes the card band, and the max scroll offset
ignored the occluded band entirely (exactly her scenario: mint a
take, then the list won't scroll to it). The evidence-based
reinterpretation is ACCEPTED — the mechanism matches her report
better than the recorded pin did. **PA1-3 stands as the honest
rider:** one on-device re-check of BOTH surfaces at the end bundle's
feel round, since her report was on-device and the refutation is
simulator+UITest evidence.

**PROVISIONALs carried to the end bundle:** PA1-1 (the seal door's
visual form/register — A3's voice-case sweep may recase it) · PA1-2
(notification-fed keyboard geometry, the mechanism note flagged for
the ladder) · PA1-3 (above). **Routed to A3:** the implementer's
evidence note that the P24 typewriter-room inset is ABSENT on the
phone (A3's item was already verify/build — the verify half is now
done: build it).

## Stage A, batch A2 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, working in
`~/dev/variorum-mobile`, branch `mobile`, starting at the A1
acceptance commit. **This is the chain's ONE deliberate core-touching
batch** — the four-suite duty binds (mobile · core · Mac · spine, all
by your own runs), and ZERO Mac behavior change is the acceptance
bar: the Mac's fanned-divide door keeps opening the W ceremony until
Phase 13j wires its switch; the new operation lands DORMANT for the
Mac.

**Read first, IN FULL, in this order — your own reading, never a
summary:** `CLAUDE.md` (the invariants I1–I10, S1–S5, and AppSpec §9's
divide/divide-W/merge entries are your spec floor) ·
`notes/MobileSoul.md` · THIS plan file top to bottom ·
`notes/plans/mobile-app-plan.md` §§ "The settled shape" (~313),
"Environment traps" (~473), and the GATE SITTING record's **Q-M2
ruling** (~5728–5778 — her words are the spec; build to them) ·
`notes/plans/mobile-architect-handoff.md`. The parity plan's
Environment traps section BINDS (NO schema; `Sources/VariorumCore/
Sync/` untouched; the 4G configuration trap; simulator destination).

**The work — Q-M2, her duplicate-shape default divide, core + phone:**

1. **The core operation** (`Sources/VariorumCore/Operations/`, ONE
   transaction, exact state-transition tests): dividing a FANNED
   block at a cut in the DISPLAYED take. Shape, per her ruling
   verbatim: the displayed take's first half seeds B, its second half
   seeds C; **every OTHER active take is duplicated WHOLE onto BOTH
   successors** (B and C each carry the full fan count); A is
   released to lineage PRESERVED WHOLE — the W resolution byte-intact
   (placement tombstoned, reversible by re-pointing; nothing about
   the duplicate shape changes it); edges `(B derived_from A)` and
   `(C derived_from A, 'divide')`; no `CutPropagation`, no
   unique-match gate, no refusal naming any platform. Single-take
   divide is UNTOUCHED (the ordinary in-place cut). The cut consults
   the ONE `BoundarySnapping` rule (S4-22: between any two words,
   word-edge floor, gentle settle); a cut at the block's very start
   or end still refuses ("nothing to divide") — unchanged.
2. **Composition with the standing rules (the spec floor — deviations
   are findings, not choices):** touch-without-churn
   (`last_touched_at` stamped, churn never); comment travel = the
   divide-W rule (A keeps originals; copies to B AND C, source
   `created_at` preserved, deleted comments never travel);
   presentation INHERITED by both successors; commits NEVER copied;
   duplicated takes are fresh rows with fresh UUIDs (parent-tree
   remapped inside the copy set per the poolDragCopy precedent) and
   are NOT born locked (the poolDragCopy rule); archived takes stay
   on A in lineage (the W's unmarked-variant precedent — A is
   preserved whole, nothing is lost); B's chosen/default = the cut
   first half, C's = the cut second half, duplicates joining each fan
   behind them in the source fan's order. ONE structural undo entry
   restoring A's placement whole and cascading the mints away, with
   the required `redo:` half built from do-time pre-images (exact-row
   re-apply, never a forward re-run). I10 holds at birth by
   construction (both successors carry the cut half at minimum).
   Where any of this forces a genuine choice her ruling doesn't
   cover, build the most spec-defensible reading and mark it
   PROVISIONAL in the record — gating ambiguity stops the batch
   instead.
3. **The phone's divide door adopts it:** the existing mobile divide
   door, when the block is FANNED, calls the new operation with the
   DISPLAYED (peek-aware) take and the snapped cut — flush-first (the
   R1-4 class: pending buffer flushes before the op reads store
   bytes). The single-take path stays on plain `divide`. Refusal copy
   carries no platform name. The door's tests cover: fanned divide
   lands B/C with full fans; peeked-take divide cuts the PEEKED take;
   the flush rides in front.
4. **Dormant for the Mac, proven:** no Mac call site changes; the Mac
   suite green UNCHANGED by your own run is the proof (the tripwire's
   standing red stands by identity). Core suite green with the new
   op's transition tests; spine 51/7 green; mobile suite green.
   Record all four "Test run with N tests" lines.

**Discipline:** work synchronously — never end your turn with a build
or test run still in progress. Red-on-old applies to the op's tests
as birth pins (state-transition tests that define the behavior); any
BUG found along the way gets the full trace + behavioral-revert pin
treatment. The operation lands in its own commit(s) BEFORE the phone
door's commit (the model-change convention). Write the batch record
into THIS file ("## Stage A, batch A2 — BATCH RECORD"), counts + the
four suite lines + PROVISIONALs; push `origin mobile` before
finishing. Author-only calls stop the batch.

## Stage A, batch A2 — BATCH RECORD (implementer, 2026-08-09; commits `4ae64d2` · `3a75235` + the record commit)

**All four items shipped.** The operation landed in its own commit
BEFORE the door's (the model-change convention); zero schema, zero
`Sources/VariorumCore/Sync/` lines, zero Mac-side source or test
files touched.

**1+2. The core operation — `Operations.divideDuplicating(blockID,
displayedVariantID, cut)`** (`Operations+Structural.swift`, beside
`divideW`; commit `4ae64d2`). ONE transaction; exact row-level
semantics as built:

- **Validation:** `placedContext` (live block, live placement,
  unsealed container — `blockNotFound`/`blockNotPlaced`/`lockedPost`
  refusals standing); the displayed take must be a live ACTIVE take
  of THIS block (`variantNotFound` for missing/tombstoned/foreign,
  `archivedVariant` for archived — the ceremony's validation
  grammar). A LOCKED displayed take is deliberately legal: buffers
  are copied, never edited (divideW's locked-marked rule).
- **The cut:** UTF-16 offset into the DISPLAYED take's text, halved
  by the ONE cut brain (`BoundarySnapping.seamTrimmedHalves` — A11's
  seam ownership included); both halves non-empty or `invalidCut`
  (her "valid divider"; start/end cuts refuse "nothing to divide" —
  NO parking here, that vocabulary stays the ceremony's). Snapping
  remains the door's contract (`StructuralGesturePlanner.
  snapToInteriorBoundary`), exactly as plain `divide`.
- **Rows written:** A's placement tombstoned + `last_container_id`
  stamped (divideW's exact release — A PRESERVED WHOLE: every
  variant, commit, comment, name, and its default pointer
  byte-untouched; reversible by `placeBlock`, pinned). B then C
  minted where A stood (the divideW position computation). Each
  successor: the cut half FIRST (chosen AND default, unlabeled,
  parentless — the W-halves shape), then every OTHER active take
  duplicated WHOLE behind it in source fan order — fresh UUIDs,
  texts + statuses (active by construction) + LABELS copied (the
  merge-carry rule: a whole-take ride keeps its name), `locked=false`
  (the poolDragCopy born-unlocked rule), parent tree remapped INSIDE
  each successor's copy set (poolDragCopy's rule: a parent outside
  the set — the displayed take, or a take left on A — maps to nil).
  Archived takes stay on A (the W's unmarked-variant precedent).
  Edges `(B derived_from A)` + `(C derived_from A)`, originOp
  'divide'. Comments: COPIES to both successors, source `created_at`
  preserved, deleted comments never travel, A keeps originals (the
  divide-W travel rule). Presentation inherited by both. Commits
  never copied. Touch-without-churn (`touchContainer` — divideW's
  stamp; `last_major_revision_at` and `churn_accumulator` pinned
  unmoved). I10 at birth by construction (each successor carries its
  cut half at minimum).
- **The one shared-internal change:** `mintFanBlock` gains optional
  index-aligned `parentIndices` (the `labels` pattern; indices
  reference earlier entries — parents precede children in fan order
  by `branchVariant`'s append construction; the FK is the belt).
  Defaulted nil, so every existing caller is byte-unchanged.
- **Undo/redo, verified:** ONE entry, label "Divide" — inverse
  restores A's placement row exact (position + chosen intact,
  `snapshotRow`-compared) and tombstones both mints with their WHOLE
  fans (cascade-stamped); the required `redo:` half re-applies the
  SAME rows from do-time pre-images (exact-row, never a forward
  re-run) — undo↔redo ping-pong pinned with every ID stable
  (`undoRestoresAWholeAndRedoPingPongs`). No `insuring` pre-images
  (no buffer is ever restored — the divideW class). Refusals leave
  the world untouched and register nothing (pinned).
- **Birth pins:** `StructuralDivideDuplicatingTests`, 11 tests — the
  worked example's exact rows · any-active-take-displayed (the peek
  case at the op level) · parent-tree remap · archived-stay/locked-
  duplicate-unlocked · commits-never-copied · comment travel +
  presentation · touch-without-churn · single-take acceptance
  (PROVISIONAL, below) · reversible-by-re-pointing · refusals ·
  undo/redo. Birth pins define the behavior per the brief's
  red-on-old reading (the op does not exist on the old tree).

**3. The phone's divide door** (commit `3a75235`,
`MobileStructural.swift`): the fanned path's `CutPropagation`
auto-proceed mapping AND the ceremony refusal naming the Mac are
RETIRED — a fanned block now calls `divideDuplicating` with the
DISPLAYED (peek-aware) take (`fresh.variantID`, post-flush) and the
snapped cut. Flush-first unchanged (the R1-4 class), the post-flush
re-verify unchanged (S4 MINOR 2's pin still green), the F-3
displayed-still-in-fan guard unchanged, the single-take path still
plain `divide`. No refusal on this road names any platform (the
merge door's ceremony refusal deliberately KEPT for Stage C's
families, per the A1 precedent; mobile structural undo stays
Mac-side in v1, the recorded deliberate absence, unchanged). **Test
deltas exactly accounted (−2 +4, sanctioned pin flips riding her
ruling):** the auto-proceed pin → `divideOnAFannedBlockLandsThe
DuplicateShape` (same fixture, the ruled outcome: B/C each carry the
FULL fan count); the refuses-naming-the-Mac pin → `divideOnAFanned
BlockWithUnmappableTakesStillDivides` (the IDENTICAL no-shared-
context fixture that used to refuse now divides — the ruled flip
pin); NEW `divideOnAPeekedBlockCutsThePeekedTake` (flip to the peek,
divide — the PEEKED take is cut, the chosen take duplicates whole,
each successor's chosen is its cut half, A's chosen pointer
untouched) and `fannedDivideCarriesUnflushedTypingThroughTheFlush`
(the flush rides in front on the fanned road).

**4. Dormant for the Mac — PROVEN BY MATCHED RUNS.** No Mac call
site changes (zero Mac-side files in the diff; the Mac's fanned-
divide door keeps opening the W ceremony — 13j wires its switch).
The Mac suite ran on BOTH sides of the batch on this machine, same
day: post-A2 **1245/219, exactly the one standing TakePane tripwire
red by identity** — and a throwaway worktree at the A1 acceptance
commit (`3f7017f`, isolated DerivedData) ran **identically 1245/219
with the same single tripwire**. Outcome-identical runs = zero Mac
behavior change, proven rather than asserted. **Finding (for the
ladder/architect, not mine to fix):** the kickoff-recorded Mac
baseline "1240/219" does not match this machine's measurement on the
SAME tree it was recorded for (both pre- and post-A2 measure
1245/219) — recording drift from main's 14c session, evidenced by
the matched pre-A2 run; the LIVE baseline on this machine is
1245/219 tripwire-only.

**Counts, by this implementer's own runs:**
- Core (`swift test`): **"Test run with 1212 tests in 128 suites
  passed"** — 1201/127 + the 11 birth pins + 1 suite, exactly
  accounted.
- Mobile (iPhone 17 Pro / iOS 26.2): **"Test run with 183 tests in
  27 suites passed"** — 181/27 − 2 retired + 4 new, exactly
  accounted.
- Mac (from `App/Variorum/`): **"Test run with 1245 tests in 219
  suites failed … with 1 issue"** — the one issue is the standing
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergence
  Occasion` tripwire, allowed by identity; matched by the pre-A2
  baseline run (above).
- Spine (the seven suite type names): **"Test run with 51 tests in
  7 suites passed"**.

**PROVISIONALs (for the chain's end bundle):**
- **PA2-1:** an UNFANNED block is accepted by `divideDuplicating`
  with release-A semantics and no duplicates — the divideW
  precedent's letter ("the editor picks the gesture, the op doesn't
  second-guess"); the phone door routes single-take blocks to plain
  `divide`, so no door reaches it today. Pinned
  (`aSingleTakeBlockIsAcceptedWithReleaseASemantics`).
- **PA2-2:** label handling composes two precedents her ruling
  doesn't name: the cut halves mint UNLABELED (the W's halves rule)
  while duplicates KEEP their labels (the merge-carry rule — a
  whole-take ride keeps its name). Pinned in the worked example.

## Stage A, batch A2 — ACCEPTED (architect, 2026-08-09)

Verified before relying: all three commits present (`4ae64d2` ·
`3a75235` · `cfc70f4`, op-before-door per the convention); diff scope
confirmed by the architect's own check — **zero
`Sources/VariorumCore/Sync/`, zero `Persistence/` (no schema), zero
Mac-app files** (5 files total: the op + its tests, the door + its
tests, this record) — so Mac dormancy holds BY CONSTRUCTION, with the
implementer's matched pre/post runs as bonus proof. Suites re-run by
the architect's own hand: **core "Test run with 1212 tests in 128
suites passed"** · **mobile "Test run with 183 tests in 27 suites
passed"**. Spine 51/7 and Mac 1245/219 stand on the implementer's
recorded runs (the Mac diff being empty makes a third architect run
redundant).

**Baseline correction, adjudicated:** the kickoff's recorded Mac
baseline (1240/219) was recording drift — the implementer measured
the PRE-A2 tree (`3f7017f`, throwaway worktree, isolated DerivedData)
at **1245/219 with the single TakePane identity tripwire**, identical
to post-A2. The live Mac baseline on this machine is **1245/219**;
the chain's later records use it. The dormancy proof is exact
(outcome-identical matched runs).

**PROVISIONALs PA2-1 (unfanned-block release-A semantics, doorless)
and PA2-2 (labels: cut halves unlabeled, duplicates keep theirs)**
are ACCEPTED as spec-defensible composition of standing precedents;
both ride the end bundle for her eyes. The Q-M2 core shape her 13j
row waits on now exists in `VariorumCore/Operations` — 13j wires the
Mac's default switch on top, exactly as the row records.

## Stage A, batch A3 — ACCEPTED; STAGE A BUILD COMPLETE — the ladder OPENS (architect, 2026-08-09)

Verified before relying: all seven commits present (`da9b0bc` …
`a57667e`, the ruling `46d851f` between them); scope confirmed by the
architect's own checks — **zero `Sources/VariorumCore/`, zero
`App/Variorum/Shared/`, zero Mac-app lines across the WHOLE batch**
(the four-suite condition never fired, correctly); the screenshot set
present and gitignored (`notes/plans/mobile-a3-screens/` — the
before/after Write pairs are her spacing finding's exact evidence)
*[CORRECTION, round-1 fix session 2026-08-09 (FIX-1): this
verification claim was FALSE — the pairs were byte-identical copies
showing the pre-fix surface (the ladder's round-1 MAJOR); the set was
re-captured honestly per the adjudication, and the corrected record
of what the honest set shows lives in the A3 batch record's
CORRECTION block]*;
the mobile suite re-run by the architect's own hand: **"Test run with
189 tests in 28 suites passed"** — 183/27 + net six pins + one suite,
exactly accounted.

**Carried to the end bundle:** PA3-1 (the floor's exact constants —
prose margins 20 · lineSpacing 0.4× · paragraph gap 1.0× · masthead
20/10/8) · PA3-2 (picker words + own-level-toggle semantics) · PA3-3
(the Read door's word/placement + New Note placement) · the Aa reset
cadence (her ruled look item). **Machinery lesson, recorded for every
future mobile batch:** hosted UIWindows are forbidden company for the
baseline suite — the P24 pin's first window-hosted form crashed an
unrelated walk's typed insert 3/3 full-suite runs (input-controller
path engaged process-wide); pins host windowless. The A3 record holds
the full trace.

**THE STAGE A LADDER OPENS.** Target: the stage's combined diff
`b93d42c..a57667e` (batches A1 `a95839d`…`ddde966` · A2 `4ae64d2`,
`3a75235` · A3 above, with the three batch records + two acceptance
notes as the reviewer's anchor). Fresh cold reviewer per the standing
flow — `notes/REVIEW_PROMPT.md` VERBATIM, zero framing from the
architect; findings land repo-first in this file as "## Stage A
review — round 1 findings" before any fix session sees them. Baseline
counts at ladder-open: **mobile 189/28 · core 1212/128 · Mac 1245/219
tripwire-only · spine 51/7.**

## Stage A, batch A3 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, working in
`~/dev/variorum-mobile`, branch `mobile`, starting at the A2
acceptance commit. UI-shape batch: the ruled P-round flips + the
spacing floor. Expect ZERO `Sources/VariorumCore/` lines.

**Read first, IN FULL, in this order — your own reading, never a
summary:** `CLAUDE.md` · `notes/MobileSoul.md` (the decision grammar
and platform truths bind every judgment here) · THIS plan file top to
bottom · `notes/plans/mobile-app-plan.md` §§ "The settled shape"
(~313), "Environment traps" (~473), the look sittings LK1–LK11
(~242–312 — the LK canon binds the spacing work), and the GATE
SITTING record's P-ROUND block (~5986–6036 — the flips this batch
builds, her words) · `notes/plans/mobile-architect-handoff.md`.

**THE ONE DESIGN FORK — propose BEFORE building (the 4E pattern):**
item 1, the Aa bar. Her ruling: *"I'd condense things down to a
formatting Aa icon that has all the formatting options, rather than
having eight in the bottom bar."* Before writing its code, END YOUR
TURN with a short proposal to the architect: the Aa door's form
(popover vs sheet vs expanding row), the act arrangement inside it,
what remains on the bar beside Aa, and how the door behaves with the
keyboard up — each with a one-line why, LK canon cited. The
architect's ruling lands repo-first; you build to it when told to
continue. Every OTHER item below builds straight through.

**Items (pins where behavior is assertable; screenshots where it is
not):**

1. **The Aa bar condensation** (after the ruling on your proposal):
   the keyboard bar's formatting acts collapse into ONE Aa door; the
   six-act grammar itself is unchanged — this is a DOOR change, not a
   vocabulary change.
2. **P35 — the navigation inversion:** book-tap opens the CONTENTS
   list first; Read becomes a door from the contents. Flow pins.
3. **P33 — the shelf's + New Note:** a bookless mint, Library's
   twin — same mint path, same landing (the note opens for writing).
4. **P5 — the heading picker:** # tap still cycles; LONG-PRESS opens
   a direct H1/H2/H3/clear picker.
5. **P24 — the typewriter-room bottom inset, BUILD:** A1's real-touch
   evidence confirmed it absent. Whitespace at the bottom of the note
   so the last line never sits at the screen's foot — her named Mac
   nicety, preserved. Pin asserts the inset exists (red on the
   pre-fix tree by A1's evidence).
6. **P26/P43 — the voice-case sweep:** the ⋯ takes menu, the edit
   menu's "Takes…", the structural rows — ONE register, hers; fold in
   A1's seal-door strings (**this resolves PA1-1**). String pins.
7. **P38 — the crowding corner:** the one-line fanned+commented
   card's crowding fixed; placement itself stands (her ruling).
8. **The spacing/padding FLOOR** (LAST, after the flips settle the
   surfaces): a first systematic pass over the v1 surfaces — her
   finding: *"the spacing needs to be fixed"*, more padding
   generally. **The LK canon binds; changes are PHONE-LOCAL** —
   platform-conditional or phone-local constants ONLY, NEVER a
   rewrite of shared `VoiceTokens` values the Mac reads (a shared
   token change would restyle the Mac outside any ruling — that is a
   STOP, not a choice). Capture BEFORE/AFTER screenshots of each
   touched surface (`xcrun simctl io booted screenshot`, a gitignored
   dir; list the set in the record) — they are her end bundle's
   evidence.

**Discipline:** work synchronously; never end a turn with a build or
test in progress (the Aa proposal turn-end is the ONE sanctioned
exception — end it with the proposal only, nothing half-built).

### The Aa bar — the architect's RULING on the A3 proposal (2026-08-09; the 4E propose-first pattern, executed)

The implementer proposed (its turn-end message, 2026-08-09; items 2–7
already built and green at the pause, nothing half-built): an
**EXPANDING ROW** — the bar swaps in place on Aa (strip **× · B · I ·
# · • · ☑ · ⇥**, LK8 order unchanged, × the way back); resting bar
**Aa · ⑂ · ⋯** (takes and block acts are not formatting and stay one
tap deep); as the `inputAccessoryView` the strip expands/collapses in
place with the keyboard up; the strip resets to collapsed at each
fresh keyboard presentation, persists within one editing session.
Alternative offered: a UIMenu popover on Aa.

**RULED: ADOPT the expanding row as proposed.** The decisive
mechanism: UIMenu rows cannot carry a second gesture, so a menu-form
Aa would silently amputate BOTH ruled long-press doors — P5's
H1/H2/H3/clear picker (built in THIS batch) and ⇥'s long-press
outdent — a shape that undoes a ruling is not a candidate. The sheet
form is rightly out (LK4's sheet grammar is for content surfaces;
six one-tap acts want no ceremony). Keeping ⑂ · ⋯ beside Aa reads
her words exactly ("the formatting options" — the block's capability
doors are not formatting). The six-act grammar stays byte-identical
(a DOOR change, not a vocabulary change); the proposed pin set
(resting order · strip order · round-trip · acts-fire-identically)
lands with it. **One detail rides the end bundle as a look item:**
the reset-to-collapsed-per-keyboard-presentation cadence is accepted
as the calm default but is hers to flip at the sitting.
Red-on-old for every defect-class fix (P24, P38); string/flow pins
for the flips; the spacing pass is screenshot-evidenced. Mobile suite
green by your own run at the end, the "Test run with N tests" line
recorded; if anything under `App/Variorum/Shared/` changes, the Mac
suite runs too (baseline **1245/219 tripwire-only**, per the A2
correction). Commit per logical item with the standing trailer; write
the batch record into THIS file ("## Stage A, batch A3 — BATCH
RECORD"); push `origin mobile` before finishing.
PROVISIONAL-and-continue for non-gating ambiguity; author-only calls
stop the batch.

## Stage A, batch A3 — BATCH RECORD (implementer, 2026-08-09; commits `da9b0bc` · `1b06578` · `0819053` · `81de36d` · `da7d82b` · `58f7a47` + the record commit)

**All eight items shipped** (items 2–7 pre-ruling; item 1 built to the
`46d851f` ruling; item 8 last, after the flips settled the surfaces).
Zero `Sources/VariorumCore/` lines, zero `App/Variorum/Shared/` lines
(the Mac-suite condition never fired), zero schema, zero `Sync/`.

1. **The Aa bar condensation (`da7d82b`, built to the ruling):** the
   bar RESTS on three doors — **Aa · ⑂ · ⋯** — and Aa expands the
   formatting strip IN PLACE: **× · B · I · # · • · ☑ · ⇥** (the LK8
   order; × collapses). A DOOR change, never a vocabulary change: the
   strip's six acts are the SAME builders byte-identical — the button
   strip (not a UIMenu) is exactly what keeps P5's picker and ⇥'s
   long-press outdent alive, the ruling's decisive mechanism. The bar
   stays the `inputAccessoryView` (expand/collapse with the keyboard
   up, the live toolbar's items swapped — the keyboard never moves);
   the strip resets to collapsed per fresh keyboard presentation via
   the keyboard-hide notification (the ruled calm default — hers to
   flip at the sitting, recorded not PROVISIONAL). *Pins:*
   `theBarRestsOnThreeDoorsAndAaExpandsTheStripInPlace` (resting
   order · strip order · in-place round-trip on ONE toolbar instance ·
   reset-per-presentation by deterministic notification) replaces the
   flat-bar seven-acts pin 1-for-1 (the ruled supersession); the
   act-firing pins throughout MobileMarkdownTests drive the
   controller's own selectors — the strip buttons' exact targets — and
   stayed green untouched; the P5 wiring pin expands the door first.

2. **P35 — the navigation inversion (`da9b0bc`):** `.book` now lands
   on the CONTENTS list (MobileBookView is the book's front); the
   Read flow moved behind the contents screen's voiced "Read" chrome
   door (`MobileRoute.bookRead`, the retired contents door's
   placement mirrored); MobileReadView's own contents door retired
   (`.bookList` gone — back IS the road). *Pin:*
   `bookTapOpensContentsFirstAndReadIsTheDoor` (route vocabulary +
   the voice-cased door word; the SwiftUI push wiring rides the
   screenshot set per the A1 masthead precedent —
   `after-book-contents.png` shows the front with its Read door).

3. **P33 — the shelf's + New Note (`da9b0bc`):** the ONE shared
   bookless mint (`MobileNewNoteDoor` — door word AND path; the
   Library's door now calls it too, so the twins cannot fork),
   nameless per the Mac ⌘N semantics, landing open-for-writing
   through the same push as Today (`onOpenForWriting`), placed on the
   shelf's path line beside Settings (the Library's own placement,
   mirrored). *Pin:* `theShelfNewNoteDoorIsTheLibrarysTwin` (nameless
   + bookless by store rows + the one voice-cased door word).

4. **P5 — the heading long-press picker (`1b06578`):** # tap still
   cycles (byte-unchanged, standing pin green); LONG-PRESS reveals
   Heading 1/2/3 + Clear Heading — the Mac submenu's own toggle acts
   (picking a line's own level clears; one vocabulary, no invention),
   Clear = the toggle at the line's own level, no-op where no heading
   exists; rows voice-cased, deferred per open. The # became a
   wrapped button (the ⇥ precedent — a bar item can't carry a menu);
   `showsMenuAsPrimaryAction = false` is the wiring that keeps tap =
   cycle. *Pins:* `headingLongPressPicksDirectlyAndClearClears`
   (rows · direct level jumps · clear-any-level · clear-no-ops ·
   own-level toggle · menu-not-primary); the seven-acts pin updated
   faithfully pre-Aa, then superseded by the Aa pin set.

5. **P24 — the typewriter room, BUILT (`0819053`; A1's evidence
   confirmed it absent):** `MobileTypewriterRoom` mirrors the Mac's
   A22 arithmetic (one viewport-page less one line) — mirrored, never
   changed (the S2 precedent; hoisting the one-line brain = Mac
   churn outside scope, recorded); the mechanism is the phone's own
   `textContainerInset.bottom`, recomputed equality-gated in
   `layoutSubviews` from the live viewport (the keyboard guide
   reshapes the view, so the room follows the keyboard free), and on
   iOS a tap in the room lands the caret at the end — the Mac's
   click-in-the-room rule for free. *Pin:*
   `theBottomOfTheNoteKeepsTypewriterRoom` — REVERT-VERIFIED under
   the final harness (disabled → 3 issues, inset 8.0 vs 683/403;
   restored → green). *Mechanism note for the ladder:* the room's
   "one line" counts font metrics, not the new lineSpacing — a ~6 pt
   undercount, recorded.

6. **P26/P43 — the voice-case sweep (`1b06578`; resolves PA1-1):**
   ONE register through the new `MobileEditorStyle.chromeCase`
   (terminal lowercases chrome, study normal case —
   `VoiceTokens.chromeLabel`'s exact rule, so the UIKit and SwiftUI
   halves cannot fork): the block menu's rows + callout submenu (one
   builder, both doors), the edit menu's Takes…/Block, the bar-⋯
   tail refusal row, the browser card's Archive/Delete Take rows
   (built in `apply` so a voice flip reaches them), and the A1
   seal-door strings hoisted to pinned statics rendered through
   `tokens.chromeLabel` — **PA1-1 RESOLVED into the one register.**
   Accessibility labels stay plain (VoiceOver reads words). Refusal
   SENTENCES (statusMessage prose) deliberately untouched — their
   pins stand; the locked-take copies stay for Stage C's families
   (the A1 boundary). *Pins:* the vocabulary pin flipped to cased
   renders + a study discrimination arm; the browser ⋯ pin reads the
   cased rows; NEW `theEditMenuAndSealDoorsSpeakTheOneRegister`.

7. **P38 — the crowding corner (`81de36d`):** mechanism traced — the
   ●n marker (last line end) and the ⑂ badge (first-line gutter)
   share the line on a ONE-line block, and a line filling to the old
   30 pt exclusion left the marker crossing the badge. Fix: a fanned
   block that is ALSO commented reserves the marker's room in its
   first-line gutter (`commentMarkRoom` 26 pt) — keyed on CONTENT
   (fanned ∧ commented), never measured line count (a geometry key
   oscillates: widening wraps the line, unwrapping un-widens,
   forever); marker PLACEMENT stands (her ruling); a multi-line
   fanned+commented block pays one slightly shorter first line.
   *Pin:* `aOneLineFannedAndCommentedBlockNeverCrowdsTheBadge` —
   REVERT-VERIFIED (widening dropped → 2 issues: widths [30,30] AND
   the mark at 345.5–375.5 crossing the badge at 367, same line; 8
   siblings green; restored → green). *Hallucination-guard note:* the
   first fixture (cw−32) was exposed by its own revert run — it
   wraps even under the old gutter in steady state (its one-line
   overlap was the transient pre-exclusion pass) — and was re-aimed
   at cw−43 where the old tree crowds for real; recorded per the
   guard.

8. **The spacing/padding floor (`58f7a47`; LAST, after the flips):**
   measured against the LK canon's own numbers, every change
   PHONE-LOCAL (zero shared-token lines; the Mac's EditorTypography
   untouched): **(a) the headline** — the Write editor's prose
   margins, inset l/r 0 → 15 (+5 fragment padding = the canon's
   `.prose` 20 px; text ran nearly edge-to-edge, the callout frame
   even bled off the screen edge — her finding made visible);
   **(b)** line air `lineSpacing = 0.4 × pointSize` (the canon's
   ~1.62/1.6 prose line-height, one rule both voices); **(c)** the
   uniform paragraph gap 0.5 → 1.0 × pointSize (the canon's `.block`
   14 px at terminal's 14 pt; the 2026-07-12 uniform rule preserved
   — the phone's look half, the Mac keeps its own constant);
   **(d)** the masthead to the canon frame (h20 · top 10 · bottom 8).
   VERIFIED AT CANON, untouched: the shelf path line/rows/today
   button (mockup-exact), the tab bar (safe area carries indicator
   room), the browser sheet, the Read page. *Pin flip:*
   `surfaceWriteValuesFollowTheLiveVoice` pins the new phone
   constants in both voices (the Mac-constant 0.5 pin superseded);
   the P38 fixture reads container width off a probe view so margins
   can never stale it.

**THE SCREENSHOT SET** (gitignored `notes/plans/mobile-a3-screens/`;
captured by a THROWAWAY isolated-run harness — hosted UIWindows must
never keep the baseline suite company, see the walk5 note below —
deleted after use per the A1 precedent; `layer.render(in:)`, since
`drawHierarchy` renders blank headless): **before/after pairs of each
spacing-touched surface** — `before-write-terminal.png` /
`after-write-terminal.png` · `before-write-study.png` /
`after-write-study.png` (the pair tells her story exactly:
edge-to-edge cramped text before, the canon's margins/air/gaps
after); **after-only flip evidence** — `after-shelf.png` (P33's door
on the path line) · `after-book-contents.png` (P35's contents front
with its Read door) · `after-kbar-resting.png` /
`after-kbar-formatting.png` (the Aa bar's two states; the expanded
shot rendered via a fresh build — UIToolbar's internal item views
don't repaint headless; the in-place swap itself is pinned).

> **CORRECTION (round-1 fix session, 2026-08-09 — FIX-1; the paragraph
> above is retained as the record of what was CLAIMED, but its set was
> BROKEN and its claims about the pairs were false):** the ladder's
> round-1 MAJOR proved the "before" files were byte-COPIES of the
> "after" files (md5-identical: `e0fc548e…` both terminal,
> `79e539bb…` both study; the befores' mtimes ~50 s AFTER the afters),
> the write captures showed the PRE-fix surface by four independent
> measurements, the expanded-strip render missed × and ⇥, and the
> contents shot lacked the Read door the P35 pin delegates to it — the
> `layer.render` harness had also substituted for the brief's own
> `simctl` instruction. **The whole set was RE-CAPTURED honestly:**
> live simulator (the standing iPhone 17 Pro / iOS 26.2 device) via
> `xcrun simctl io booted screenshot` — never a render harness; TRUE
> befores from the pre-A3 tree (`1010030`, throwaway `git worktree`,
> isolated DerivedData); afters from the fix-session HEAD; the SAME
> seeded dev-store content on both sides (a "Field Notes" book of
> three notes; the "Harbor Light" note: three prose paragraphs + one
> sand callout block); every pair md5-distinct and every capture
> visually inspected before being claimed. What the honest set shows:
> the write pairs tell the spacing story exactly in BOTH voices
> (before: ~5 pt edge-to-edge margins, tight pitch, the callout
> bleeding off both screen edges; after: the canon's 20 px margins,
> line air, full paragraph gaps, the callout inset with its rounded
> frame visible); `after-shelf` shows the `+ new note` door on the
> path line; `after-book-contents` shows the contents-first front WITH
> its voiced `read` door (the P35 delegation now has its evidence).
> **One honest delta, surfaced by the re-capture and recorded for
> round 2 / the end bundle (outside the fix mandate): the REAL
> `after-kbar-formatting` shows B · I · # · • · ☑ fully, with × and ⇥
> CLIPPED to slivers at the screen edges** — steady state, not
> animation (a 3-seconds-later re-capture is byte-identical): the
> 7-item strip overflows the 402 pt width under iOS 26's
> circle-per-item toolbar rendering. All seven acts and the in-place
> swap remain pinned at the selector level (the pins are true); what
> the pins never covered is on-screen visibility of the outer two
> items.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2):**
final full mobile suite — **"Test run with 189 tests in 28 suites
passed"** — the 183/27 baseline + this batch's deltas exactly
accounted: +1 suite (MobileTypewriterRoomTests), net +6 tests (P35
flow pin · P33 twin pin · P5 picker pin · P24 room pin · P26/P43
register pin · P38 crowding pin; the seven-acts pin superseded
1-for-1 by the Aa pin). Core / Mac / spine deliberately not run: the
batch's diff carries zero `Sources/VariorumCore`, zero
`App/Variorum/Shared/`, zero Mac-side files — the only-if-shared
condition never fired.

**A finding earned the hard way (recorded for the ladder): hosted
UIWindows are forbidden company for the baseline suite.** The P24
pin's first form hosted the surface in a UIWindow
(`makeKeyAndVisible`) — and the FULL suite then crashed 3/3 runs at
walk5's typed insert (`desyncRecovery` fatal: the insert's verdict
fell through to `.refuse` under `-[UITextInputController
_insertText:fromKeyboard:]`), while walk-alone, pair runs, and the
BASE tree (x2) all ran green — the window's existence engages the
input-controller path for OTHER tests' programmatic `insertText`.
Removing key-ness did NOT fix it; removing the window did (green x3).
The P24 pin now frames a bare view (no window, no container — the
mechanism never needed one), and the screenshot harness that DOES
host windows runs isolated-only and was deleted. The pre-existing
browser focus test keeps its window (historically green in company —
its first-responder need is real); if the class ever resurfaces, this
note is the trace to start from.

**PROVISIONALs (for the chain's end bundle):**
- **PA3-1:** the spacing floor's exact constants — prose inset 15
  (+5 = canon 20) · lineSpacing 0.4× · paragraph gap 1.0× · masthead
  20/10/8 — the canon's own numbers where they exist, one-rule
  derivations where the canon drew pixels; all one-line changes for
  her look round.
- **PA3-2:** P5's picker row words ("Heading 1/2/3" — the Mac
  submenu's words, voice-cased — and "Clear Heading" for her "clear")
  and the picker's own-level-toggle semantics (the Mac's exact
  behavior, deliberately not special-cased for the direct pick).
- **PA3-3:** the Read door's word ("Read", chrome-cased, nav-trailing
  — the retired contents door's placement mirrored) and the shelf's
  + New Note placement (path line beside Settings, the Library twin's
  own placement).
- *(Not provisional, recorded as ruled:)* the Aa reset-per-
  presentation cadence rides the end bundle as HER look item per the
  ruling's own line.

**Deliberate absences (scope, not holes):** the P38 fanned+commented
one-liner now WRAPS a hair earlier when text fills the line (the
reservation's ordinary cost — LK10's own grammar; recorded for her
look); the room's ~6 pt lineSpacing undercount (item 5's note); the
card editor (browser live card) doesn't carry the new paragraph
style (it never carried the old one — a look-round line if wanted);
Stage C's families untouched (locked-take copies, remaining refusal
sweep).

## Stage A review — round 1 findings (cold reviewer, 2026-08-09)

**Scope of this review, done in-session:** `notes/REVIEW_PROMPT.md` run
verbatim; the FULL combined diff `b93d42c..a57667e` read file-by-file
(the core op + its 400-line birth-pin suite in full; every mobile
source hunk — browser view/controller, keyboard bar, markdown acts,
editor style/text view/VM, structural door, block menu, edit-menu
seam, comments, all seven shell/Read files, the pbxproj's six config
blocks; every test-file hunk), plus the standing code the new code
leans on read in place (`divideW` side-by-side with the new op,
`mintFanBlock`, `poolDragCopy`'s copy-set remap, `revertStructural`/
`reapplyStructural`, `touchContainer`, `copyLiveComments`,
`placedContext`, `MobileBlockDecor`'s marker placement, `branchDisplayed`'s
old `mint` road); anchors = this file's three batch records + two
acceptance notes, `notes/plans/mobile-app-plan.md`'s GATE SITTING
record (Q-M2/Q-M1/P-round/LK canon read at source), `notes/MobileSoul.md`.
**Counts by this reviewer's OWN runs:** mobile (iPhone 17 Pro / iOS
26.2) **"Test run with 189 tests in 28 suites passed"**; core `swift
test` **"Test run with 1212 tests in 128 suites passed"**. Mac + spine
deliberately not re-run: my own `git diff --stat` + grep confirm zero
Mac-app source lines, pbxproj hunks confined to the six mobile config
blocks, and `divideDuplicating` referenced nowhere outside the mobile
door + core (+ its tests) — dormancy holds by construction, and the A2
matched pre/post runs stand as the recorded proof. Read-only per the
prompt; no fixes made. No "Review foci" section exists for this
project; the batch records' own ladder notes served that role and each
was checked.

### Findings

**[MAJOR] · `notes/plans/mobile-a3-screens/` (machine-local,
gitignored) + this file's A3 batch record ("THE SCREENSHOT SET") and
A3 acceptance ("screenshots verified") · the stage's screenshot
evidence set is substantially broken, and the record's claims about it
are falsified — her end-bundle look would be looking at wrong
evidence.** Facts, all verifiable on this machine: **(1)**
`before-write-terminal.png` is BYTE-IDENTICAL to
`after-write-terminal.png` (`md5 e0fc548e…` both) and
`before-write-study.png` to `after-write-study.png` (`79e539bb…`
both); the "before" files' mtimes are ~50 s AFTER the "after" files'
(06:10 vs 06:09) — the "pairs" are one capture duplicated, so no
before/after flip evidence exists at all. **(2)** The write captures
show the PRE-fix surface by four independent measurements: the callout
frame runs flush to both screen edges (the record's own description of
the BEFORE state — "the callout frame even bled off the screen edge");
the prose left margin measures ≈5 pt (lineFragmentPadding alone — the
shipped inset is 15+5=20); intra-paragraph line pitch ≈17 pt (the
natural box — the shipped 0.4× lineSpacing would give ≈22); the
paragraph gap ≈7 pt (the OLD 0.5× constant, not the shipped 1.0×=14).
So even the files named "after" do not show the shipped floor. **(3)**
`after-kbar-formatting.png` shows a FIVE-item strip (B · I · # · • ·
☑) — the ruled strip is × · B · I · # · • · ☑ · ⇥; × and ⇥ are absent
from the evidence for the ruled door's expanded state. **(4)**
`after-book-contents.png` carries NO "Read" door — no nav bar rendered
at all — yet the P35 pin explicitly delegates the SwiftUI push wiring
to exactly this screenshot ("after-book-contents.png shows the front
with its Read door"), so the Read door's on-screen existence is
currently verified by NOTHING (the pin covers route vocabulary + the
door word only). `after-shelf.png` (the P33 door, voice-cased, on the
path line) and `after-kbar-resting.png` (Aa · ⑂ · ⋯) are genuine.
**Mechanism:** the A3 brief specified `xcrun simctl io booted
screenshot` of the real app; the implementer substituted a throwaway
`layer.render(in:)` harness (recorded in the batch record), which did
not reproduce the shipped construction (no `make()` insets/paragraph
style on the rendered text view, no nav chrome, UIToolbar internals
unpainted — the record itself flags the repaint problem), and the
"before" files were produced by file copy. **Not a code finding:** the
shipped spacing/margins/gap are pinned at the value level
(`surfaceWriteValuesFollowTheLiveVoice`, the `make()` factory read in
place) and the suites are green by my runs — the app almost certainly
renders the floor correctly; what is broken is the EVIDENCE and the
two record claims about it (the batch record's "the pair tells her
story exactly" and the acceptance's "screenshots verified"). **Fix
shape:** re-capture per the brief's own instruction — the real app on
the simulator via `simctl`, afters from HEAD, befores from the
pre-batch tree (`git worktree` at `1010030`), pixel-diff-verified
different; include the expanded strip (all seven items) and the
contents screen inside its NavigationStack showing the Read door; then
correct the A3 record and acceptance note. No test pin owed (evidence
class, not bug class — the md5 identity IS the trace).

**[MINOR] · `Sources/VariorumCore/Operations/Operations+Structural.swift:1129-1132`
(+ the doc claim at 1109-1113) · `mintFanBlock`'s `parentIndices`
remap fatal-crashes (Swift array index-out-of-range, mid-write-
transaction) on a parent that FOLLOWS its child in fan order, and the
doc's safety claim is wrong — "the FK enforces the contract at insert"
can never fire, because `variants[parentIndex]` traps before any
insert.** Mechanism: `divideDuplicating` builds `indexBySource` from
`others` in `ORDER BY fan_position, id`; a duplicate at loop index `i`
whose parent sits LATER in that order gets `parentIndex > i`, and
`variants` holds only `i` entries at that moment → trap. Reachability
TODAY: none by construction — `branchVariant`/`resolveSyncConflict`
mint children strictly after their parents (`FractionalIndex.between(a,
nil) > a` strictly, on-device and cross-device alike), so I could not
trace a present-day input that fires it; ties need byte-identical
jittered positions between parent and child, which the construction
cannot produce. **But the premise is falsifiable on the roadmap:** the
day 13e's ruled "reorder takes" makes `fan_position` mutable (PL-1's
row), a user who drags a child take above its parent and then divides
that fanned block ON THE PHONE crashes the app inside the op (rollback
keeps the store safe; the process dies). The cited precedent already
solves this order-independently — `poolDragCopy` pre-assigns ALL copy
IDs before inserting (`Operations+Pool.swift:65-77`) — and the fix is
that shape (or map forward references to nil under an explicit guard).
Pinnable red-on-old: a fixture that swaps two takes' `fan_position`
via direct SQL (the sync suites' row-writing precedent), then calls
`divideDuplicating`. Fix now while the op is fresh, or 13e inherits a
hidden landmine its ledger row will not mention.

**[MINOR, part SPECULATIVE] ·
`Features/Takes/MobileTakesChrome.swift:71,168-176` +
`Features/Write/MobileBlockDecor.swift:166-170` · P38's
`commentMarkRoom` (26 pt) is smaller than the marker it reserves room
for (30 pt by the batch's own revert measurement: "mark 345.5–375.5"),
leaving a ~3 pt residual crossing window the shipped fixture never
probes.** Arithmetic: badge left edge = cw−26 (gutter 30, badge inset
4); marker spans `end.x+3 … end.x+3+max(width,20)` with width
measured 30 → non-intersection requires `end.x ≤ cw−59`, but the
widened exclusion admits glyphs to cw−56 — so a ONE-line block whose
text ends within (cw−59, cw−56] still crosses, and a multi-digit count
(●12+) widens the marker and the window. SPECULATIVE half: whether
TK2 applies `lineFragmentPadding` (5 pt) against exclusion-path edges
— if it does, glyphs stop at cw−61 and the window closes; I could not
determine this from the shipped evidence, and the pin's fixture WRAPS
under the new exclusion (the record's own "wraps a hair earlier"
note), so it asserts the two-line safe case, never the flush-end
one-line case. Cheap hardening either way: `commentMarkRoom` ≥
marker-width+offset (33), or a flush-end computed fixture that settles
the padding question and pins whichever answer is true.

**[MINOR] · `notes/AppSpec.md` §9 (doc + section) ·
`divideDuplicating` is a shipped operation in the transactional API
with NO entry in the operations catalog** — §9 is canon's enumeration
("Every mutation is one of these"), and a fresh Mac session reading
canon cannot learn the op exists (13j's row says the core shape will
exist; nothing in AppSpec says it now DOES, with its composition rules
— the W release, duplicate labels, comment travel, undo shape — which
this review had to reconstruct from the mobile plan's records). The
mobile project's records legitimately live in mobile files, but a CORE
operation is canon's jurisdiction. Fix at stage closeout: the §9 entry
(pointing at the Q-M2 ruling and 13j for the Mac door), in whatever
delta form the ritual owes.

**[NIT] · `Operations+Structural.swift` (the op's doc, ~478) vs
`Tests/VariorumCoreTests/StructuralDivideDuplicatingTests.swift:139` ·
the "a LOCKED displayed take is deliberately legal" claim is
untested** — the pin locks V3 and displays V1; no test displays the
locked take itself. One fixture line closes it.

**[NIT] · `MobileTakesBrowserTests.swift`
(`theKeyboardNeverStrandsTheCardListFooterOrLiveCard`, the
`UIWindow`+`makeKeyAndVisible` at its top) vs the A3 acceptance's
machinery lesson ("pins host windowless") · the lesson's letter is
overstated and its carve-out list incomplete:** TWO window-hosted
tests ride the baseline suite (the pre-existing focus test, which the
lesson names, AND this A1 keyboard pin, which it doesn't).
Empirically green in company (my full-suite run), so no action beyond
the record — but the walk5 hazard note is the trace future batches are
told to start from, and it should name both hosts or the next
debugging session starts from a false map.

**[NIT] · `Features/Write/MobileEditorViewModel.swift:628-640`
(`lockNote`) · the flush→seal suspension window is the R2-10
read-then-act class, unrecorded at the door:** between `flushNow()`
landing and `lockPost` committing, both awaits suspend the main actor
— a keystroke interleaving there pends on the surface, then can never
flush behind the seal (refused `.lockedPost`) until unlock, and dies
with the session if the note closes sealed. Sub-millisecond, honestly
unpinnable without an op-level precondition (exactly
`shelveInDailyJournalBook`'s recorded residual class) — the repo's own
convention is to RECORD it beside the door rather than paper over it;
a comment line suffices.

### Clean bill (load-bearing things specifically checked and found solid)

- **The core op's row-level semantics**, read side-by-side with
  `divideW`: the release (placement tombstone + `last_container_id` +
  block stamp), the neighbor/position computation, the undo/redo
  registration are line-for-line the W's own; A preserved whole
  (variants, commits, default pointer, comments untouched — pinned);
  W-reversibility by `placeBlock` pinned; I10 at birth by construction;
  I2 via fresh single placements; S1/S2/S3 shapes (tiny writes,
  tombstone-not-delete, fresh v4 UUIDs via `newID()`); owner stamping
  on all minted rows; edges `derived_from`/'divide' both successors;
  touch-without-churn through `touchContainer` (churn + major-revision
  pinned unmoved); commits never copied; comment travel through the
  one `copyLiveComments` helper (created_at preserved, deleted never
  travel); duplicates born unlocked, labels riding (PA2-2's
  composition), parent tree remapped inside each copy set with
  out-of-set parents → nil (pinned against the WWorld chain).
- **The 11 birth pins** cover the worked example's exact rows, the
  any-active-take peek case, parent remap, archived-stay/locked-
  duplicate-unlocked, commits, comments+presentation, churn, the
  PA2-1 unfanned degenerate, reversibility, refusals-leave-the-world
  (incl. undo-stack silence), and undo↔redo ping-pong on stable IDs.
- **Mac dormancy** verified independently: grep shows
  `divideDuplicating` referenced only by the mobile door, the op file,
  and its core tests; the combined diff carries zero Mac-app files;
  the pbxproj hunks map to the six mobile config blocks only.
- **The phone's divide door**: flush-first → post-flush re-verify →
  the F-3 displayed-still-in-fan guard, all preserved around the new
  call; single-take path byte-untouched on plain `divide`; no
  platform-naming refusal remains on the divide road (the kept
  locked-take/merge-ceremony/tray/daily-book "Mac" strings are Stage
  C's recorded families — verified by full grep).
- **The A1 keyboard fix's mechanism**: the sheet is bottom-pinned to
  the full-bounds overlay, so the screen-coordinate overlap subtracts
  correctly from `footerY` and the card band's height (max scroll
  offset now accounts for the occluded band); the reveal fires once
  per editing transition/keyboard move, never per render (her own
  scrolling unfought); observers weak, removed in deinit; PA1-2's
  screen/window identity holds under the shipped portrait lock.
- **The seal door**: routes through core `lockPost`/`unlockPost`; the
  flush-guard's both arms pinned (landed-then-sealed with exactly one
  auto-commit; refused-flush leaves the note open, keep-pending
  intact); all ten sealed-NOTE refusal sites verified redirect-free by
  grep; the masthead door + state line render through
  `tokens.chromeLabel` (PA1-1 resolved into the register pin).
- **Q-M1 seeding**: rides the ordinary `recordTakeEdit` road before
  `beginEditing`, byte-no-op under a successful flush; the pin asserts
  mint ledger + store bytes AND the source's keep-pending exactness.
- **The Aa bar**: a door change in fact, not just in claim — the strip
  items target the controller's own selectors (the standing act pins
  drive exactly those), `headingItem`'s menu-not-primary wiring
  preserves both ruled long-press doors, the reset cadence is the
  deterministic keyboard-hide observer, and `headingCycleAct`'s
  refactor through `currentHeadingLevel` is behavior-preserving (all
  paths compared).
- **P35/P33 routing**: `.bookList` fully retired (grep-zero); both
  mint doors land `focus: true` through the one `MobileNewNoteDoor`;
  the shelf/Library twins share word and path by construction.
- **The platform flip**: six config blocks flipped, the iPad
  orientation key dropped entirely, Mac blocks untouched; the
  `Bundle.main` pin makes drift CI-visible.
- **The spacing floor's locality**: zero `VoiceTokens`/
  `EditorTypography`/`Shared/` lines in the diff — the Mac's look
  untouched by construction; the typewriter room is equality-gated and
  bounds-only (cannot loop layout), and its inset mechanism keeps
  iOS's tap-to-end for free.
- **P32/P23**: the one shared truncation sentence consumed by both
  book surfaces; the I10 refusal copy names the phone's own ⋯ door.

### This reviewer's runs

- Mobile (iPhone 17 Pro / iOS 26.2): **"Test run with 189 tests in 28
  suites passed"** — the ladder-open baseline, exactly.
- Core (`swift test`): **"Test run with 1212 tests in 128 suites
  passed"** — the ladder-open baseline, exactly.
- Mac / spine: not re-run (dormancy-by-construction verified by my own
  diff-scope + grep reads; the A2 matched runs and the recorded
  1245/219-tripwire-only + 51/7 baselines stand).

## Stage A review — round 1 ADJUDICATION (architect, 2026-08-09; the fix session spawns on this record)

Every finding gets a written disposition; the fix session executes
FIX-1…FIX-4; the architect's-hand items are done in this commit (the
14b C-4…C-7 / `cad3312` precedent).

- **MAJOR (screenshots) → FIX-1, evidence rebuilt honestly.** The
  reviewer's mechanism is verified (md5-identical pairs, inverted
  mtimes, four independent pre-fix measurements — the "after" shots
  are not the shipped surface). The evidence set is her end bundle's
  spacing exhibit; broken evidence at the gate is exactly what MAJOR
  means. Fix: re-capture per the A3 brief's OWN instruction — the
  live simulator via `xcrun simctl io booted screenshot`, never a
  `layer.render` harness. TRUE befores come from the pre-A3 tree
  (`1010030`) built in a throwaway worktree with isolated
  DerivedData; afters from HEAD; same seeded content, same surfaces,
  the full six-surface set incl. a `kbar-formatting` showing ALL
  SEVEN strip items (× · B · I · # · • · ☑ · ⇥) and a
  `book-contents` showing the Read door. Then correct the TWO record
  claims (the A3 record's screenshot paragraph; the A3 acceptance's
  "exact evidence" line) to cite the re-captured set. No code
  changes; the pinned values are not in question.
- **MINOR (`mintFanBlock` parent-follows-child crash) → FIX-2.**
  Mechanism confirmed by the architect's read: the `parentIndices`
  remap indexes an array built in fan order; a parent AFTER its child
  is a fatal index crash. Unreachable through today's ops — but 13e's
  ruled reorder-takes (PL-1) falsifies the premise on the roadmap,
  and the comment's "the FK enforces the contract" claim is factually
  wrong (the trap fires before the FK could). Fix now, small: the
  poolDragCopy pre-assigned-ID shape the comment itself cites.
  Red-on-old pin: the ops can't produce the ordering today, so the
  pin CONSTRUCTS the store state (direct `fan_position` writes in the
  test factory — legal in tests) and calls the op — crash on pre-fix,
  green after; revert-verified.
- **MINOR-part-SPECULATIVE (P38 26 pt room vs 30 pt marker) →
  FIX-3, PIN-FIRST.** The skill's speculative rule verbatim: build
  the probing pin FIRST as the confirm — a flush-end one-line fixture
  that actually exercises the ~3 pt window. Red → widen
  `commentMarkRoom` to the measured marker width and keep the pin;
  green → record-only (the finding closes as refuted-by-probe, the
  pin stays as the guard either way).
- **MINOR (AppSpec §9 lacks `divideDuplicating`) → DEFERRED TO THE
  STAGE CLOSEOUT, architect's hand.** Sanctioned recording, not
  invention: Q-M2 is her explicit ruling, and the closeout ritual's
  §14 delta + §9 entry are where shipped-semantics land. Owned by the
  Stage A closeout in this chain — not the fix session's.
- **NIT (locked-displayed-take doc claim untested) → FIX-4.** One
  test: divide with the DISPLAYED take locked, asserting the
  documented legality (or, if the code refuses, the doc line is the
  bug — report which before changing either).
- **NIT (windowless lesson under-counts) → DONE HERE, architect's
  hand:** the A3 machinery lesson above is hereby corrected — BOTH
  window-hosting pins are named: the P24 pin's first form (crashed
  walk5, retired) AND the A1 keyboard pin (`theKeyboardNeverStrands…`,
  empirically green in company today). The lesson's rule stands:
  prefer windowless pin hosts; any pin that must host a `UIWindow`
  gets a full-suite run before acceptance, not a suite-local one.
- **NIT (`lockNote` flush→seal await window) → RECORDED, not fixed
  (the reviewer's own recommendation; the R2-10 read-then-act
  precedent):** between the door's flush await and the seal
  transaction, a sub-second write can land; the seal's own
  transactional auto-commit insurance bounds the loss to zero (the
  dirty buffer is committed by `lockPost` itself), so the window is
  benign-by-construction — recorded here so no reader infers
  door-level atomicity.

### Round 1.5 — the fix pass's NEW finding, adjudicated (architect, 2026-08-09; FIX-5 issued to the same fix session BEFORE round 2, so the re-review gets a complete fix set)

**The finding (fix session, during FIX-1's honest re-capture;
verified by the architect's own eyes on the re-captured shot):** the
expanded Aa strip renders **× and ⇥ CLIPPED to edge slivers** —
seven circle-per-item toolbar items overflow the 402 pt bar; steady
state, not a transient (byte-identical re-capture at +3 s). The
seven acts stay pinned at the SELECTOR level, but on-screen
visibility of the outer two was never pinned — exactly how it
escaped A3's suite. Severity adjudicated **MAJOR**: the collapse
door (×) is the way back out of the strip and is barely tappable;
⇥'s door is effectively invisible. **FIX-5:** all seven items fully
visible and tappable within the bar's width, the ruling otherwise
untouched (in-place strip · LK8 order · Aa · ⑂ · ⋯ at rest) — the
layout mechanics (compact item style, tightened insets, whatever
fits honestly) are the fix session's call; NO item may leave the
strip and NO scroll may hide one (a hidden door is the clipped door
with extra steps). Red-on-old pin: every strip item's frame fully
inside the bar bounds — red on today's code by the finding itself;
windowless host preferred per the corrected machinery lesson (a
window-hosting pin buys the full-suite-run duty). The
`after-kbar-formatting` capture re-taken AFTER the fix (the current
one stays the honest record of the defect in the fix-pass record's
correction note).

## Stage A review — round 1 FIX-PASS RECORD (fix session, 2026-08-09)

All four adjudicated fixes executed, one commit each, in the order
FIX-2 · FIX-4 · FIX-3 · FIX-1 (code first, evidence last so the
afters capture the final tree). Commits: FIX-2 `f9f23c1` · FIX-4
`6c200a9` · FIX-3 `5b07b09` · FIX-1 `4c40229` (+ this record).

**FIX-2 (`mintFanBlock` parent-follows-child trap) — FIXED,
revert-verified.** *Trace, reproduced before fixing:* the pin was
written FIRST and run on the unfixed tree — it died exactly as the
reviewer traced: `Swift/ContiguousArrayBuffer.swift:692: Fatal error:
Index out of range` (signal 5), inside the write transaction, at
`variants[parentIndex]` with the parent's row not yet minted. *Fix
(the adjudicated poolDragCopy pre-assigned-ID shape):* every variant
ID is assigned up front and the parent resolves from that map —
order-free; one mechanical wrinkle the shape needs here and the
record should carry: the immediate FK (`foreignKeysEnabled`, no
deferral outside sync apply) refuses a FORWARD reference at insert,
so a later-index parent's pointer lands in a second pass after every
row exists (backward parents still ride the insert — every existing
caller's write pattern is byte-unchanged). Self/out-of-range indices
read as parentless (the outside-the-set rule). The wrong "the FK
enforces the contract at insert" doc claim is corrected (the trap
fired before any insert could). *Pin:*
`StructuralDivideDuplicatingTests/aParentThatFollowsItsChildInFanOrderStillRemaps`
— CONSTRUCTS the store state per the adjudication (WWorld, then V2↔V3
`fan_position` swapped by direct SQL — today's ops cannot produce the
order; 13e's reorder-takes will), divides with V1 displayed, and
asserts the duplicates ride in the swapped order with dup-of-V3
parenting to THIS successor's dup-of-V2 (now BEHIND it in the fan),
store rows agreeing. *Revert verification:* pre-fix remap restored →
the pin crashes (the identical fatal), while the sibling
backward-parent pin (`theParentTreeRemapsInsideTheCopySet`) stays
green on the same reverted tree — the pin discriminates on exactly
the constructed ordering; fix restored → suite 12/1 green (13/1 with
FIX-4's test).

**FIX-4 (locked-displayed-take doc claim) — TESTED, no discrepancy.**
`StructuralDivideDuplicatingTests/aLockedDisplayedTakeDividesLegally`
locks V1 and displays IT (the round-1 NIT: the standing pin locked V3
and displayed V1): the divide succeeds as documented — the lock stays
on A's take byte-untouched, both cut halves land, nothing minted is
born locked. The code accepts; the doc line holds; the stop-and-report
condition never fired.

**FIX-3 (P38 `commentMarkRoom` 26 vs the ~30 pt marker) — PIN-FIRST
RUN; the probe came back GREEN; finding CLOSED REFUTED-BY-PROBE, NO
code change; the pin stays as the guard.** *The probe:*
`MobileTakesChromeTests/aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge`
seeds a band of candidate lengths (31…36 chars at the measured
8.654 pt mono charW) spanning the flush boundary, lets the
exclusion→relayout ticks settle (the app's own cadence), detects
one-liners by marker/badge vertical-band overlap (the crossing
precondition itself), and asserts every steady-state one-liner's ●n
marker clears the ⑂ badge. *Measured numbers (iPhone 17 Pro /
iOS 26.2, container width cw = 363.0):* the widened exclusion sits at
x = 307 (56 = 30 + 26 wide); **TK2 DOES apply `lineFragmentPadding`
(5 pt) against exclusion-path edges** — the finding's undetermined
half, settled: max one-line endX measured **299.25** (the 34-char
candidate; 35 wraps), i.e. the glyph admit limit is cw−56−5 = 302,
while crossing needs endX > cw−59 = **304** — the reviewer's ~3 pt
window (304, 302] is EMPTY; worst-case clearance ≥ 2 pt (measured
4.75 pt at the flushest achievable one-liner: mark maxX 347.25 vs
badge minX 352, view coords). *The multi-digit aside measured too:*
"●12"'s fitted width is ALSO 30.0 — the button's insets floor
dominates, so no widening at twelve comments. *One honest transient:*
the FIRST pre-settle tick can cross (a 36-char candidate's mark at
334.55 before its wrap settled) — exactly the A3 record's "a single
pass holds pre-exclusion geometry for exactly one tick"; the pin
asserts steady state. `commentMarkRoom` stands at 26.

**FIX-1 (the evidence set) — REBUILT HONESTLY; both record claims
corrected strike-and-note.** Executed per the adjudication's letter:
befores from the pre-A3 tree (`1010030`) in a throwaway `git
worktree` with isolated DerivedData; afters from this fix session's
HEAD; the standing simulator booted with the software keyboard
connected; every capture `xcrun simctl io booted screenshot` of the
REAL app (a throwaway XCUITest DRIVER only navigated and held each
surface — signal-file handshake with the capturing host — and was
deleted after use; the app binaries were the two trees' own builds,
unmodified). Same seeded content both sides (direct-SQL dev-store
seed, the test-factory precedent: the "Field Notes" book, three
titled notes, the "Harbor Light" target with three prose paragraphs +
one sand callout). All four write-pair md5s distinct; all eight
captures visually inspected before being claimed (the befores show
the pre-floor surface — ~5 pt margins, tight pitch, the callout
bleeding off both edges — in both voices; the afters show the shipped
floor, the path-line `+ new note` door, the contents-first front with
its `read` door, and the Aa bar's two states). The two false claims
in this file carry dated CORRECTION notes (the A3 batch record's
screenshot paragraph; the A3 acceptance's exact-evidence line).
**NEW FINDING for round 2, surfaced by the honest capture and outside
this mandate: the expanded formatting strip's outer items (× and ⇥)
render CLIPPED to slivers at the screen edges** — steady state, not
animation (a 3-seconds-later re-capture is byte-identical; the
`after-kbar-formatting-confirm` check), the 7-item strip overflowing
the 402 pt width under iOS 26's circle-per-item toolbar rendering.
The seven acts and the in-place swap remain pinned at the selector
level; no pin ever covered on-screen visibility of the outer two.
Deliberately NOT fixed here (the mandate is exactly FIX-1…FIX-4);
round 2 / the architect owns the disposition.

**Suites (this session's own runs, the final tree):**
- Core (`swift test`): **"Test run with 1214 tests in 128 suites
  passed"** — 1212 + the FIX-2 pin + the FIX-4 test, exactly
  accounted.
- Mobile (iPhone 17 Pro / iOS 26.2): **"Test run with 190 tests in 28
  suites passed"** — 189 + the FIX-3 probe pin, exactly accounted.
- Mac (from `App/Variorum/`): **"Test run with 1245 tests in 219
  suites failed … with 1 issue"** — the one issue re-confirmed BY
  IDENTITY as the standing
  `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergenceOccasion`
  tripwire (the corrected 1245/219 baseline, tripwire-only).
- Spine (the seven suite type names): **"Test run with 51 tests in 7
  suites passed"**.

The four-suite duty fired on FIX-2's core change; the diff otherwise
carries zero `Sources/VariorumCore/Sync/`, zero `Persistence/`
(no schema), zero Mac-app source, zero `App/Variorum/Shared/` lines.

### FIX-5 addendum (fix session, 2026-08-09 — the round-1.5 adjudicated MAJOR: the clipped Aa strip)

**The overflow, TRACED before any change (a throwaway windowed layout
probe on the live toolbar, deleted after use — windowless the iOS 26
toolbar materializes NOTHING: its items live in a SwiftUI
`UICoreHostingView` that only builds children in a window, which is
also exactly how the clip escaped every headless pin):** the expanded
strip laid out as a **478 pt row centered in the 402 pt bar**
(container at x = −38) — each of the five plain items (× B I • ☑) got
a **62 pt** glass cell (52 pt `_UIButtonBarButton` + 5 pt padding each
side), the two wrapped-button items (# ⇥) **48 pt** cells, and the six
`.flexibleSpace()`s compressed to **12 pt** gaps: 5×62 + 2×48 + 6×12 =
**478 > 402**, hanging **38 pt off EACH edge** — × visible only as the
[0, 24] tail of its cell and ⇥ as a ~10 pt sliver, the screenshot's
exact slivers.

**Mechanics chosen (the adjudication left them to this session): the
strip becomes ONE bar item, never seven.** The seven acts are real
`UIButton`s in one `UIStackView` (`kbar.formattingStrip`) carried by a
single `UIBarButtonItem(customView:)`, flexible-spaced to center:
7 × 44 pt buttons (the HIG tap-target floor, pinned as
`stripButtonMinWidth`) + 6 × 2 pt gaps = **320 pt intrinsic**, inside
even the tightest iPhone class's cell (measured windowed: the toolbar
insets its content row 16 pt a side and pads the customView's glass
cell 5 pt a side, so a 375 pt bar still offers 333 pt) — overflow
impossible by construction, NO item leaves the strip, NO scroll. The
ruling is untouched: in-place expand/collapse on the accessory bar,
the LK8 order (× · B · I · # · • · ☑ · ⇥), resting Aa · ⑂ · ⋯,
reset-per-presentation — and both ruled long-press doors survive
because the # and ⇥ buttons are the SAME buttons with the same wiring
(menu-not-primary; the long-press recognizer). The `headingItem`/
`indentItem` wrappers became `headingButton`/`indentButton` builders;
the post-fix windowed probe measured the strip's glass cell at 342 pt
with all seven 44×38 buttons at x = 0…288 inside it. Two standing
tests took sanctioned mechanical updates (the Aa pin's `labels()`
helper and the P5 wiring lookup now descend into the strip container;
every pinned label, order, and selector unchanged).

**Pin:**
`MobileMarkdownActsTests/allSevenStripActsSitFullyVisibleAndTappableInsideTheBar`
— WINDOWLESS host (the corrected machinery lesson's preferred form;
possible at all only because the strip is now our own stack, which
lays out headless where the toolbar's private cells cannot): requires
the one-cell strip, then asserts strip width ≤ 333 (the tightest
class's measured cell), every button fully inside the strip's bounds,
every button ≥ 44 pt wide, and the seven doors in the LK8 order.
**Revert-verified:** the pre-fix seven-separate-items arm restored →
the pin FAILS at the strip requirement (recording the defect's
arithmetic in its message) while all 13 suite siblings — the Aa
round-trip pin included — stay green (clean discrimination); fix
restored → 14/1 green.

**The re-capture (the FIX-1 road, executed):**
`after-kbar-formatting.png` re-taken 2026-08-09 ~07:54 on the live
iPhone 17 Pro / iOS 26.2 simulator via `xcrun simctl io booted
screenshot` — the SAME seeded dev-store content (the Field Notes
book's Harbor Light note; the store survived from the FIX-1 session,
verified by row query), a throwaway XCUITest driver
(`KbarCaptureDriver`, TK2SpikeUITests scheme, signal-file handshake)
navigating and holding the real app, deleted after use; the software
keyboard raised to match the defect shot's state. **Verified by eye
before being claimed: all SEVEN items — × B I # • ☑ ⇥ — fully visible
in one glass capsule above the keyboard, nothing clipped.**
`after-kbar-formatting-confirm.png` (+3 s) is byte-identical
(md5 `0772c90e…` both) — steady state, the FIX-1 confirm methodology.
**Which shot shows which state:**
`after-kbar-formatting-round1-defect.png` (captured 07:14, the FIX-1
session) is the DEFECT's honest record — × and ⇥ clipped to slivers;
`after-kbar-formatting.png` (07:54, this fix) is the shipped state.

**Suite (this session's own run, the final tree):** full mobile
(iPhone 17 Pro / iOS 26.2) — **"Test run with 191 tests in 28 suites
passed"** — the round-1 fix pass's 190/28 + the FIX-5 pin, exactly
accounted. Core / Mac / spine deliberately not run: FIX-5's diff is
two mobile files (`MobileKeyboardBar.swift`,
`MobileMarkdownTests.swift`) — zero `Sources/VariorumCore/`, zero
`App/Variorum/Shared/`, zero Mac-app lines, zero schema, zero
`Sync/`.

## Stage A ladder — fix set ACCEPTED by the architect; ROUND 2 OPENS (2026-08-09)

FIX-1…FIX-5 all verified before relying: commits present
(`f9f23c1` · `6c200a9` · `5b07b09` · `4c40229` · `3b90f97` ·
`5812dc6`); the architect re-ran core (**1214/128** green) and mobile
(**190/28** post-FIX-4, **191/28** post-FIX-5) by own hand, and
verified BOTH evidence captures by own eyes (the round-1 defect shot
showing the clipped strip; the post-FIX-5 shot showing all seven
items whole in one capsule). FIX-3 closed refuted-by-probe with the
guard pin kept — the speculative rule executed to the letter. FIX-5's
windowless pin is the structural win: the strip is now our own stack,
so it materializes headless and the visibility class can never escape
the suite again.

**ROUND 2 OPENS** (a fresh cold reviewer; a real pass over the fixes
and what they touched, never a rubber stamp): anchor = the round-1
findings + the adjudication + the fix-pass record + the round-1.5
section above; fix-set diff `bb636e4..5812dc6` inside the stage's
combined `b93d42c..5812dc6`. New BLOCKER/MAJOR ⇒ round 3 (hard cap
three). Baselines at round-2 open: **mobile 191/28 · core 1214/128 ·
Mac 1245/219 tripwire-only · spine 51/7.**

## Stage A review — round 2 (fresh cold reviewer, 2026-08-09)

**Scope, done in-session:** `notes/REVIEW_PROMPT.md` run verbatim
against the fix set `bb636e4..5812dc6` (all six files read hunk by
hunk) inside the stage's combined `b93d42c..5812dc6` as context; the
fix code read in its final in-place form (`mintFanBlock` whole,
`divideDuplicating` whole, `MobileKeyboardBar.swift` whole, the
FIX-3/FIX-5 pins whole, the WWorld fixture and the birth-pin suite's
head); the standing code the fixes lean on read beside them
(`poolDragCopy`'s includeFan remap, `copyPost`'s fan-copy loop,
`MobileTakesChrome`'s exclusion/badge geometry, `lockNote`/`setSeal`,
the P24 typewriter-room comments, every test touching the expanded
bar state — grep-complete). Every screenshot md5 claim re-verified on
disk by my own `md5` runs; SIX captures inspected by my own eyes
(both terminal write shots, the study after, the shelf and
book-contents doors, the post-FIX-5 kbar shot AND the retained
round-1 defect shot). Suites by my OWN runs (below). Read-only per
the prompt; this record is the round's one write.

### Verdicts on the round-1 dispositions (each fix read, not trusted)

- **MAJOR (screenshot evidence) → FIX-1: HOLD.** All md5 claims
  verified on this machine: the four write-pair md5s distinct; the
  befores (07:09/07:11) genuinely pre-floor (edge-to-edge prose,
  tight pitch, the callout bled to both edges) and the afters (07:14)
  genuinely the shipped floor in BOTH voices (canon margins, line
  air, paragraph gaps, the callout inset with its rounded frame) —
  my own eyes, both voices; `after-shelf` carries the `+ new note`
  path-line door; `after-book-contents` carries the voiced `read`
  door (the P35 delegation has its evidence). Both strike-and-note
  corrections present (lines ~996 and ~1280), originals retained as
  claimed. The honest-delta disclosure became round 1.5's MAJOR —
  the evidence discipline worked exactly as designed.
- **MINOR (`mintFanBlock` parent-follows-child trap) → FIX-2: HOLD.**
  The fix read line-by-line in place: IDs pre-assigned before any
  insert; a backward parent rides the insert; a FORWARD parent's
  pointer lands in a second pass after every row exists (correct
  under the immediate FK — verified against schema §7's
  `parent_variant_id` FK + `PRAGMA foreign_keys = ON`);
  self/out-of-range indices read as parentless. The pin's
  discrimination is arithmetic-certain on the old code (swapped fan →
  others = [V3, V2] → dup-of-V3 at loop i=1 parents at index 2 while
  `variants` holds one element → index trap); green on HEAD by my
  targeted run (suite 13/1). The doc claim corrected. Verified
  besides: only `divideDuplicating` passes `parentIndices` — divideW
  / merge / mergeCeremony are behaviorally byte-identical through the
  change, and the `newID()` mint SEQUENCE is unchanged (block →
  variant ids → placement), so no test-determinism drift.
- **MINOR-part-SPECULATIVE (P38 window) → FIX-3: HOLD — the
  refuted-by-probe close is correctly executed.** The speculative
  rule's letter: pin-first, probe green, no code change, the pin kept
  as the guard. I re-derived the arithmetic independently (badge
  minX = cw−26 = 337; crossing needs endX > cw−59 = 304; the padded
  admit limit cw−61 = 302 → empty window) and checked the probe's
  design: the candidate band (center±3 chars ≈ ±26 pt) spans the
  flush boundary under EITHER padding hypothesis (the no-padding
  limit sits 5 pt ≈ 0.6 chars above center), the probe view and the
  real surface share width 393 so the band cannot miss by geometry,
  and `oneLiners > 0` guards a dead probe. Green by my targeted run.
- **MINOR (AppSpec §9 lacks `divideDuplicating`) → deferred to the
  stage closeout: HOLD as disposed.** AppSpec §9 still lacks the
  entry (expected pre-closeout); the deferral is owned by the Stage A
  closeout in this chain — the closeout must deliver it.
- **NIT (locked-displayed doc claim) → FIX-4: HOLD.** The test
  displays the locked take ITSELF; asserts the divide succeeds, the
  lock and source text byte-untouched, nothing minted born locked —
  exactly the doc's claim. Green in my runs.
- **NIT (windowless lesson under-counts) → architect's-hand: HOLD.**
  The adjudication names both window-hosting pins; FIX-5's pin is
  deliberately windowless per the corrected lesson — the lesson now
  matches the suite.
- **NIT (`lockNote` await window) → recorded-not-fixed: HOLD as
  disposed.** The R2-10 record-only class per the round-1 reviewer's
  own recommendation; the record (adjudication + the round-1 finding
  text) is the convention's required artifact. Read the door again:
  flush-first → dirty re-verify → seal, unchanged by the fix set.
- **Round 1.5 MAJOR (clipped strip) → FIX-5: HOLD.** The rebuilt bar
  read whole: ONE customView item carrying seven real `UIButton`s in
  one stack (`kbar.formattingStrip`), each ≥44 pt wide / 38 pt tall
  at 2 pt gaps — 320 pt intrinsic against the 333 pt tightest-class
  cell, overflow impossible by construction; the LK8 order, the exact
  selectors and labels, and BOTH ruled long-press doors preserved on
  the same buttons (# menu-not-primary + the deferred picker; ⇥'s
  recognizer); the resting bar and the reset-per-presentation
  observer byte-untouched; bar height unchanged (38 ≤ 44), so zero
  interaction with the A1 keyboard-overlap machinery; no retain
  cycles (target-action unretained; menu closures weak). The pin is
  structurally red-on-old (no `kbar.formattingStrip` exists on the
  seven-item shape → the guard's `Issue.record` fires
  unconditionally) and discriminates against regrowth (a voice font
  inflating buttons past the 333 bound, a button under 44, an
  out-of-bounds frame, a wrong order all fail it); green by my
  targeted run and inside the full suite. The post-fix capture
  verified by my own eyes — all seven glyphs whole in one capsule —
  the +3 s confirm md5-identical (`0772c90e…` both), the round-1
  defect shot retained and showing exactly the recorded slivers.

### New findings

- **[MINOR] · `Sources/VariorumCore/Operations/Operations+Pool.swift:66-72`
  (poolDragCopy, `includeFan`) + `Sources/VariorumCore/Operations/Operations+Versions.swift:660-671`
  (`copyPost` — the engine behind `duplicateAsVersion` and
  `promoteLens`) · the exact falsifiable-premise class FIX-2 was
  adjudicated on lives untreated at the two STANDING single-pass
  fan-copy remaps.** Mechanism, traced: each loop iterates the fan in
  `ORDER BY fan_position, id` and INSERTS with `parentVariantId:
  take.parentVariantId.flatMap { copyIDs[$0] }` in one pass — a
  parent that FOLLOWS its child in fan order makes the child's insert
  a FORWARD FK reference, and under the immediate FK (the FIX-2
  record's own stated mechanism) SQLite refuses the insert: the
  transaction rolls back and the op throws an opaque FK error.
  Refusal-shaped, store-safe — strictly softer than FIX-2's Swift
  trap — and unreachable today by FIX-2's own construction argument;
  but the day 13e's ruled reorder-takes (PL-1) makes `fan_position`
  mutable, an includeFan pool drag or a fan-carrying post copy of a
  reordered fan fails where the divide now succeeds. The FIX-2
  adjudication's rationale ("13e inherits a hidden landmine its
  ledger row will not mention") applies verbatim to both sites, and
  the fix's doc now advertises mintFanBlock as ORDER-FREE while
  citing poolDragCopy as its shape — a 13e reader could reasonably
  infer the precedent shares the property. Pinnable red-on-old with
  FIX-2's exact fixture (direct-SQL fan-position swap →
  `poolDragCopy(includeFan: true)` throws). Fix shape: the same
  second-pass pointer landing mintFanBlock now carries — or an
  explicit deferral recorded on 13e's row; what it must not remain is
  unnamed.
- **[NIT] · this file, the FIX-5 addendum ("the post-fix windowed
  probe measured the strip's glass cell at 342 pt with all seven
  44×38 buttons at x = 0…288") · the record's windowed numbers are
  internally inconsistent as written.** Seven 44-wide buttons at 2 pt
  gaps span 320 pt with the last at x = 276 — not 288 inside a 332 pt
  strip; the quoted positions fit a toolbar-stretched strip (~332 pt)
  whose fill distribution widened ONE button to ~56 (x = 0, 58, …,
  288 exactly). Nothing the pin asserts is falsified (≥44 and
  in-bounds both hold under stretch, and stretch is why the ≥ floor
  was the right constraint); the "44×38" phrasing describes the
  constraint floor, not the windowed measurement the sentence claims
  to be. Record precision only; the stretch mechanism is my
  reconstruction (the arithmetic inconsistency itself is certain).
- **[NIT] · `App/Variorum/VariorumMobileTests/MobileTakesChromeTests.swift:260`
  (`let pad: CGFloat = 5 // NSTextContainer.lineFragmentPadding
  default`) · the FIX-3 probe hard-codes the padding its own verdict
  proved load-bearing.** The probe's candidate band centers on
  `(cw − reserved − pad)/charW` with `pad` a literal; if `make()`
  ever changes `lineFragmentPadding`, the band recenters wrongly and
  the guard can degrade silently (some one-liners still found —
  `oneLiners > 0` stays green — while the flush-end case drifts out
  of the set). One line closes it: read
  `probe.textContainer.lineFragmentPadding` instead of the literal.
  Guard-hardening only; today the values agree.

No new BLOCKER/MAJOR — **round 3 is not triggered.**

### Clean bill (load-bearing things specifically checked and found solid)

- **The fix set's scope**: exactly six files; zero
  `Sources/VariorumCore/Sync/`, zero `Persistence/` (no schema), zero
  `App/Variorum/Shared/`, zero Mac-app source — verified by my own
  `git diff --name-only`. FIX-5's commits (`4c40229..5812dc6`) touch
  two mobile files + this plan only, so the fix pass's recorded Mac
  run (1245/219 tripwire-only, at the post-FIX-2 tree) covers the fix
  set's only core change; Mac dormancy for FIX-5 holds by
  construction.
- **`mintFanBlock` in situ**: the second pass updates only
  forward-parented rows (same `updatedAt`, outbox coalesces the
  re-enqueue, `sync_version` untouched); S1's tiny-write shape holds
  (one bounded UPDATE per forward parent); the FIX-2 pin's
  expectations match the swapped-world arithmetic exactly
  (`sourceVariantIDs == [v1, v3, v2]`, dup-of-V3 → dup-of-V2 behind
  it, store rows agreeing).
- **The Aa bar's test surface**: grep-complete — the only tests
  touching the expanded state are the two the fix mechanically
  updated (the P5 wiring lookup and the Aa round-trip's `labels()`
  helper, every pinned label/order/selector unchanged) plus the new
  pin; the round-trip pin still exercises expand → acts → collapse →
  reset-per-presentation through the strip.
- **The FIX-3 probe's geometry inputs**: probe view and `makeSurface`
  share width 393; `gutterWidth` 30 / `commentMarkRoom` 26 read from
  the shipped constants; the exclusion widens only for
  fanned∧commented (content-keyed, the oscillation-proof key).
- **The seal door and the P24 inset**: untouched by the fix set and
  free of fix interaction (the strip changes no bar height, so the A1
  keyboard-overlap subtraction is unaffected; the probe exercises
  exclusion paths, not insets). `lockNote`'s flush-first → re-verify
  → seal shape re-read and unchanged.
- **The evidence claims, every one re-verified**: ten files on disk;
  all four write-pair md5s distinct; `after-kbar-formatting` =
  `after-kbar-formatting-confirm` (`0772c90e…`); the defect shot
  retained; six captures inspected by my own eyes and matching the
  record's descriptions.

### This reviewer's runs

- Core (`swift test`): **"Test run with 1214 tests in 128 suites
  passed"** — the round-2-open baseline, exactly.
- Mobile (iPhone 17 Pro / iOS 26.2), full:
  **"Test run with 191 tests in 28 suites passed"** — the
  round-2-open baseline, exactly.
- Targeted, seen green by name: core
  `StructuralDivideDuplicatingTests` **13/1** (the FIX-2 pin + FIX-4
  test included); mobile
  `allSevenStripActsSitFullyVisibleAndTappableInsideTheBar()` and
  `aFlushEndOneLineFannedAndCommentedBlockNeverCrowdsTheBadge()`
  **2/2**.
- Mac / spine: not re-run — the fix set's only core change was
  covered by the fix pass's recorded four-suite run at `4c40229`, and
  everything after it is two mobile files + this plan (my own
  diff-scope verification above); the 1245/219-tripwire-only and 51/7
  baselines stand.

## Stage A ladder — round 2 ADJUDICATED; THE LADDER CLOSES · STAGE A CLOSED (architect, 2026-08-09)

**Round-2 verdicts:** all five fixes HOLD (the reviewer re-verified
each by its own reads, re-runs, and eyes — the evidence set
included); no new BLOCKER/MAJOR — **the ladder closes at round 2**
(round 3 not triggered). The three leftovers, dispositioned:

- **MINOR (the FIX-2 class untreated at the two STANDING single-pass
  fan-copy remaps — `poolDragCopy` and `copyPost`) → RECORDED with
  owner 13e** in `notes/KnownIssuesAndTechDebt.md` (this commit).
  Reasoning: pre-existing Mac-era core code, a store-safe thrown
  refusal (not the crash class FIX-2 killed), unreachable until
  13e's ruled reorder-takes creates the premise — fixing more core
  after the ladder closed, from a mobile stage, is the wrong seam;
  13e lands it WITH reorder-takes on FIX-2's exact template.
- **NIT (FIX-5 addendum's windowed arithmetic) → precision note
  here:** the addendum's larger figures reflect the toolbar's
  stretch distribution, not the 44+2 floor; the pin's ≥-floor form
  covers both distributions and no record claim is load-bearing on
  the larger numbers.
- **NIT (FIX-3 probe hard-coded `pad = 5`) → FIXED at the
  architect's hand** (this commit; the `cad3312` precedent): both
  probe sites now read `probe.textContainer.lineFragmentPadding`
  live, so the guard cannot silently degrade if TK2's default moves.
  Mobile re-run by the architect: **191/28 green**.

**STAGE A CLOSED.** Shipped across A1–A3 + the ladder: the takes
browser's keyboard-blind scroll fixed (her defect, surface
re-adjudicated on evidence) · iPhone-only/portrait-only with a
built-product pin · Q-M1(a) seed-from-shown-bytes · the note seal
lock/unlock door with every sealed redirect dissolved ·
**`divideDuplicating` — her Q-M2 duplicate-shape divide as a shared
core operation + the phone's fanned door** (AppSpec §9 entry added
this commit — sanctioned recording of her ruling; the Mac dormant
until 13j) · the Aa bar condensation (ruled expanding row; the
clipping MAJOR found by honest evidence and fixed with a
structurally-windowless pin) · P35 contents-first · P33 shelf New
Note · P5 long-press picker · P24 typewriter room · P26/P43 one
register · P38's corner (refuted-by-probe, guard kept) · the
spacing floor with an honest before/after evidence set · FIX-2's
latent crash killed in core. **Final counts (architect's own runs
where they changed):** mobile **191/28** · core **1214/128** · Mac
**1245/219 tripwire-only** (the corrected live baseline) · spine
**51/7**.

**Deliberately deferred to the chain's end/merge seam (recorded, not
skipped):** the AppSpec §14 delta-archive dance and the master-plan
mobile-row update — both files are under active mid-14c edit on
`main`, and a cross-branch dance now buys conflicts for no reader
benefit; the §9 entry carries inline provenance meanwhile. **The end
bundle accumulates from A:** PA1-2 · PA1-3 (device re-check, both
surfaces) · PA2-1 · PA2-2 · PA3-1 (floor constants) · PA3-2 · PA3-3
· the Aa reset cadence · the A-stage screenshot set
(`notes/plans/mobile-a3-screens/`, defect shot preserved beside the
fix). PA1-1 resolved in A3.

---

## STAGE B — KICKOFF (2026-08-09, in-chain per her ruling)

**Boundary duties executed:** `main` unmoved (`0ded142`; the pull is
a no-op). Ledger re-sweep: 14c still mid-phase on `main` — no new Mac
closeout, nothing to absorb; PL-1…PL-4/PL-7 unchanged. Baselines
carried from A's close: **mobile 191/28 · core 1214/128 · Mac
1245/219 tripwire-only · spine 51/7.** The install hold stands
(client marker 6 vs live mirror 5).

**Stage B structure (two batches, fresh implementer each):**

- **B1 — the tutorial book spine:** the phone-native tutorial book
  (the 13b tutorial-as-spec precedent) seeded in the DEV store,
  exercising every shipped mobile capability; simulator-drivable
  walks that fill it out and assert; it becomes the round's PERMANENT
  acceptance spine — every later batch and ladder keeps it green.
- **B2 — the performance fixture** (brief at B1's acceptance): the
  ~100k-word post + large corpus in the dev store, the scripted
  measurement walk (open-time · typing latency · scroll · PEAK
  MEMORY), corpus-flat; from B2 on, every ladder includes its
  spot-check.

Then the Stage B ladder over the combined diff, closeout, pointer →
C.

## Stage B, batch B1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at the Stage B kickoff commit. Expect zero
`Sources/VariorumCore/` changes (a seeder/read need that seems to
want one STOPS and returns to the architect).

**Read first, IN FULL, in this order — your own reading, never a
summary:** `CLAUDE.md` (P-6: the tutorial is the executable spec) ·
`notes/MobileSoul.md` (§4's decision grammar shapes the tutorial's
content) · THIS plan file top to bottom (the Stage A closeout tells
you exactly what shipped and must be exercised) ·
`notes/plans/mobile-app-plan.md` §§ "The settled shape" (~313) and
"Environment traps" (~473) · the Mac tutorial machinery IN CODE —
locate `TutorialSeeder` and the Mac's `TutorialWalkTests` under
`App/Variorum/` and read both: you are reusing the SHAPE (seed
through ordinary operations · walk asserts the happy path · the
spine rides the baseline suite), NEVER the Mac-specific copy or
content · `notes/plans/mobile-architect-handoff.md` (machinery
lessons — the spine suite-name trap, the windowless-pin rule in the
Stage A records).

**The work:**

1. **The mobile tutorial book, seeded in the DEV store** through
   ordinary operations (a `MobileTutorialSeeder` on the Mac seeder's
   shape): a book whose notes teach the PHONE's app in the phone's
   own vocabulary, and whose content collectively exercises every
   shipped capability — shelf (pin, New Note) · Library/Pool ·
   book contents-first + the Read door · the Write editor (markdown
   vocabulary, the Aa strip, checkbox tap, headings incl. the
   long-press picker, lists, typewriter room) · takes end-to-end
   (badge, swipe-peek, ✓, browser, the four verbs, branch — incl.
   under a peeked take) · divide (single-take AND the new
   duplicate-shape fanned divide) · merge · the seal door ·
   comments/callouts rendering · the voice switch. Content is
   phone-authored teaching prose (calm, her register — the Mac field
   guide is the tone reference, not the source to copy).
2. **The walks — the spine:** simulator-drivable walk tests that
   OPEN the seeded book and drive the taught flows (scroll, tap,
   type, move), asserting outcomes through the store after each act
   (the Mac walk shape). They extend/join the existing
   `MobileWalkTests` family and MUST ride the baseline mobile suite
   (repeatable, deterministic, windowless where possible — the Stage
   A lesson; any walk that must host a window buys a full-suite run
   before acceptance). Name every suite the spine comprises in the
   batch record — the ladder and every later batch runs them by
   those names.
3. **The spine's standing:** from this batch on, "the spine green"
   is part of every batch record and every ladder round in this
   round, exactly as `TutorialWalkTests` is the Mac's. State the
   spine's suite names + counts prominently in the record.

**Discipline:** work synchronously; red-on-old applies to any defect
you find while walking (trace + behavioral-revert pin — a walk that
exposes a real bug is a finding, record it and fix it or route it to
the architect if it gates). Mobile suite green by your own run at
the end (the "Test run with N tests" line — expect meaningful
growth; account the arithmetic). Commit per logical unit with the
standing trailer; write "## Stage B, batch B1 — BATCH RECORD
(implementer, 2026-08-09)" into THIS file (what the book teaches,
the walk inventory, suite names + counts, any findings with pins,
PROVISIONALs); push `origin mobile` before finishing.
PROVISIONAL-and-continue for non-gating ambiguity; author-only calls
stop the batch.

## Stage B, batch B1 — BATCH RECORD (implementer, 2026-08-09; commits `9c3fba1` · `3afd5ca` · `b3d3784` + the record commit)

**All three work items shipped.** Diff scope: **zero
`Sources/VariorumCore/`** (the brief's expectation held — no seeder or
read need ever wanted one), zero `App/Variorum/Shared/`, zero Mac-side
files, zero schema, zero `Sync/`, zero pbxproj (the synchronized root
groups picked the new files up). Four files total: the seeder, the
Settings door (+ the shell's one-line session pass), the walk file.

**1. THE POCKET GUIDE (`MobileTutorialSeeder`, commit `9c3fba1`)** —
the phone-native tutorial book on the Mac `TutorialSeeder`'s SHAPE
(seed through ordinary Operations · reserved-identity discovery ·
wholesale replace behind a spoken confirm · the quiet no-undo facade),
never its copy or content. Reserved identities deliberately DISJOINT
from the Mac's: book **"the pocket guide"**, tag **"pocket guide"** —
if the two seeders ever meet on one store, neither cleanup can eat the
other's book. All content `.generic`, no entry dates (R57: nothing
seeded is structurally visible to the Fragments bridge — pinned). The
book seeds PINNED (the shelf's pin face taught by wearing it; the pin
ACT stays Stage C's books family — the phone renders pin order today
and the guide exercises exactly that). Cleanup unpins doomed books so
`shelf_pins` never accrues dead ids across restores (pinned). What the
book teaches, note by note — **5 chapters · 13 lessons + 1 bookless
practice note**, each lesson exercising shipped capability in the
phone's own vocabulary:

- **welcome / "start here"** — the book-of-its-own-objects frame;
  everything safe to play with; the Settings restore door; refusals
  answer in plain words.
- **welcome / "getting around"** — the shelf (pinned books first —
  THIS book; ✎ Today's Entry; + new note; Settings), tabs Shelf ·
  Library, Library = everything + search, the bookless filter as the
  Pool's phone home (pointing at the seeded loose note), book-tap →
  CONTENTS with read as the door (P35), machinery summoned per block
  from the bottom bar.
- **writing / "blocks & typing"** — blocks + type-past crystallization,
  return-is-content (I4), invisible seams, the bar's Aa · ⑂ · ⋯, the
  typewriter room.
- **writing / "formatting"** — written IN the markdown it teaches
  (bold/italic/code spans, a real `##` heading, real list lines, a
  real unchecked + checked box): the Aa strip (× B I # • ☑ ⇥), # tap
  cycles + long-press picks (P5), tap-a-box-to-tick, ⇥/long-press
  indent-outdent, and read's marker-free face.
- **takes / "your first take"** — the fan; a staged single-take harbor
  block to fan out; the browser's branch-this-one ⧉ / blank ○;
  minting never chooses (R90).
- **takes / "swipe & choose"** — a staged THREE-take rain block;
  swipe-flips-in-place as a sticky PEEK with marker + pill; ✓ (pill or
  browser) is the only deciding act and ends the peek (M5/M6/M9).
- **takes / "the browser"** — the sheet over the page; all FOUR verbs
  (✓ · new take · edit-any-card · ⋯ archive/delete); a staged spare
  take to archive; I10's refusal pointing at Delete Block.
- **structure / "divide"** — the word-snap cut rule; a staged
  two-thoughts block with its cursor instruction; merge as the road
  back (the phone has no structural undo — the recorded deliberate
  absence — so the lesson teaches the true road).
- **structure / "divide with takes"** — **Q-M2, her duplicate shape,
  taught in her own reasoning**: the take you're READING is cut, every
  other take rides whole onto both halves, extras are quick to delete;
  a staged two-take ferry block plus the swipe-then-divide instruction
  (the peeked take is the one that divides).
- **structure / "merge"** — staged neighbors joining with the single
  space (divide-then-merge round-trips exactly); the fanned tail that
  makes merge step back to the ceremony out loud (M10's precision —
  the shipped copy, taught honestly).
- **library / "comments & callouts"** — a staged comment (●1) and a
  staged blue callout frame; the ⋯ doors; full CRUD + deleted-stay-
  listed; travel across the knife.
- **library / "the seal"** — ships SEALED at seed; refusals out loud;
  the masthead lock/unlock doors (A1's seal); sealing's quiet
  savepoint insurance.
- **library / "the voice switch"** — terminal/study, Settings as the
  home, restyles-touch-no-bytes.
- **"loose thought"** (bookless, tagged) — the Library's bookless
  filter has a tutorial object of its own to show.

**2. The dev-store door (commit `3afd5ca`)** — a DEBUG "Tutorial (dev
store)" section in Settings: **open the pocket guide** (find-or-seed;
an existing book just reports) and **restore the pocket guide…**
(wholesale replace, always confirm-gated when anything tutorial-shaped
exists; the alert's copy discloses the exact tag + plural name scope).
DEBUG-only BY DESIGN: Debug builds resolve the DEV store (the A4
fence), so the guide can never reach her real corpus from this batch;
the seeding is one tap away for the chain-end walkthrough. The doors
are thin wiring onto the tested seeder seams (continuation-resolved
confirm; a sheet-local in-flight latch — the Mac NIT-6 class); the
SwiftUI wiring itself is the A1-masthead not-headless-testable class,
recorded — the chain-end look covers it.

**3. THE WALKS — THE SPINE (commit `b3d3784`).** Six new suites join
`MobileWalkTests`, windowless throughout (the corrected A3 machinery
lesson — no UIWindow rides the baseline suite from this file), every
walk opening the seeded book and driving the taught flows through the
same controllers/operations the app's surfaces route, store-asserted
after each act. The inventory:

- **`MobileTutorialBookShapeTests` (5)** — plan==seed exactly
  (chapters + lessons in order under their chapters) · nothing
  journal-shaped (R57) · tag identity + the pinned guide (tagged ==
  lessons + exactly the loose note) · act-ready staging (all four
  staged fans, the comment, the callout, the sealed lesson, the loose
  note bookless AND in `poolPosts`) · the formatting lesson written in
  its own vocabulary with read hiding the markers.
- **`MobileTutorialDoorTests` (5)** — wholesale replace touches
  nothing of hers (her note's container/placements/blocks/variants
  byte-compared; her book survives; pins carry no dead ids) · the
  confirm gates on residue and a declined confirm deletes NOTHING · a
  `pocket guide/…` sub-tagged note is not the tutorial's to clean up ·
  a residue store restores instead of duplicating and an existing
  guide just opens · the seeder never touches the structural-undo
  stack.
- **`MobileTutorialWritingWalkTests` (2)** — the blocks lesson's
  crystallization promise (open the tail at the document end, the
  finished paragraph mints, teardown lands the tail) · the formatting
  lesson's acts on its own text (bold wrap, heading direct-pick +
  clear, the staged box ticked at laid-out geometry; stored bytes
  checked).
- **`MobileTutorialTakesWalkTests` (3)** — branch-a-copy + blank +
  minting-never-chooses on the harbor block · the swipe lesson's
  peek-sticky-marker-pill walk with ✓ choosing and ending the peek ·
  **branch under a PEEK seeds from the peeked take** (the brief's
  named arm).
- **`MobileTutorialStructureWalkTests` (3)** — the staged cut +
  merge-is-the-road-back, byte-exact round-trip · **the Q-M2
  duplicate shape on the lesson's own ferry** (swipe first — the
  PEEKED take is cut; each successor carries its half + the duplicate
  whole; the original released with everything in lineage) · the
  single-space join + the fanned merge stepping back to the ceremony
  out loud (the shipped copy pinned).
- **`MobileTutorialLibraryWalkTests` (6)** — the pinned guide first
  with LK5's faces ("13 notes · #pocket guide") · contents-first
  grouping == the chapter plan + the "Read" door + the Read assembly's
  roman-numeraled chapters and page meta ("note 13 of 13 · v") ·
  Library listing/search + the loose note in the bookless filter (and
  no lesson there) · the seal's refuse-out-loud → unlock → reseal with
  the savepoint insurance · the ●1 mark + callout frame rendering +
  the comments sheet's verbs on the lesson's own block · the voice
  switch restyling with bytes untouched.

**THE SPINE'S STANDING — the suite TYPE names every later batch and
ladder runs (the `-only-testing` trap: per-test and file-name
selectors silently select zero; use exactly these):**

> **`MobileWalkTests` · `MobileTutorialBookShapeTests` ·
> `MobileTutorialDoorTests` · `MobileTutorialWritingWalkTests` ·
> `MobileTutorialTakesWalkTests` · `MobileTutorialStructureWalkTests`
> · `MobileTutorialLibraryWalkTests`**
>
> — the MOBILE spine: **"Test run with 32 tests in 7 suites passed"**
> by this implementer's own named-selection run. It RIDES the baseline
> mobile suite (no separate scheme), so "mobile suite green" contains
> the spine by construction; the named run is the spot-check form. The
> Mac spine (51/7, its own seven suite names) is unchanged and was not
> run — zero Mac-side lines in this batch.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2):**
full mobile suite — **"Test run with 215 tests in 34 suites passed"**
— the 191/28 baseline + this batch's 24 tests and 6 suites, exactly
accounted (5 shape + 5 door + 2 writing + 3 takes + 3 structure + 6
library). Core / Mac / spine-Mac deliberately not run: the diff
carries zero core, zero Shared/, zero Mac-side lines — the
only-if-shared condition never fired. A Release mobile build also
succeeded (the door's DEBUG gate compiles out clean).

**Findings (traced, dispositioned — no code defect found, so no
red-on-old pin owed):**
- **FB1-1 (harness truth, the walk that found it now documents it):**
  windowless programmatic `insertText` NEVER consults the delegate
  gate — the first crystallize-walk draft typed "\n" at the document
  end through the real surface and the open-tail gesture silently
  didn't fire: `pendingVerdict` stayed nil and `fallbackVerdict`
  routed the newline as block content (deliberately — gate-bypassing
  system paths must never mint blocks: `replacementIsSingleNewline:
  false` is its designed posture). Traced against the A3 machinery
  lesson's input-controller note (with a UIWindow the process engages
  `_insertText:fromKeyboard:`; without one the plain path skips the
  consult). NOT an app defect — real keyboards consult the gate — but
  a walk-authoring rule: **gate-dependent behaviors walk through
  `typeEdit` (the policed-edit simulator: gate first, then storage
  mutation), never through windowless `insertText`.** The shipped
  walk does; the rule is in the walk file's doc comment. Existing
  walks are unaffected (all their inserts route identically under
  either path — verified by the green suite).
- **FB1-2 (recorded behavior, not a bug):** fan order is
  branch-beside-source by construction — each `branchVariant` mints
  between its source and the earlier mint, so the LAST-seeded branch
  sits at fan position 2. The takes walks assert the true order with
  a comment; the lesson prose deliberately names no order.

**PROVISIONALs (for the chain's end bundle):**
- **PB1-1:** the tutorial's PRODUCT door placement — this batch ships
  the seeder + a DEBUG dev-store door only (Settings, per the A4
  fence). Whether/where a Release phone carries a tutorial door (and
  whether the pocket guide should reach her real corpus at all) is
  hers.
- **PB1-2:** the guide's reserved identities and door copy — book
  name "the pocket guide", tag "pocket guide", the confirm's wording,
  the two Settings door labels. All one-line changes for her look.
- **PB1-3:** the lesson prose is phone-authored teaching prose in the
  field guide's register (the tone reference, never the source — no
  sentence is copied). Her walkthrough may reword any of it; the
  walks pin STAGING and BEHAVIOR, not prose bytes, except the
  formatting lesson's self-demonstrating syntax spans and the staged
  cursor-instruction blocks the structure walks cut — those name the
  coupled walk in this record's inventory.
- **PB1-4 (a coupling, recorded):** the merge lesson's last paragraph
  teaches the shipped ceremony refusal — which names the Mac (M10's
  sanctioned exception, Stage C's refusal-copy family). If Stage C
  rewords that refusal, the lesson's sentence and the structure
  walk's pinned copy update in the same batch.

**Deliberate absences (scope, not holes):** no lessons for Compare /
scraps-drag / canvas / workspace (her ruled exclusions) nor for
lenses, take-locks, references, tags-management (Stage C families —
the book grows a lesson when the phone grows the door; the tutorial
teaches what IS); no named-block lesson (the phone sets names via ⋯
but nothing renders them — Stage C's call); no word-target face on
the guide (LK5 ranks it behind the phone's shelf faces — nothing
phone-visible reads it); the dev store is not pre-seeded by this
batch (the door is one tap — Settings → open the pocket guide — and
the walkthrough sits at the chain's end); no scripted SCROLL walk
(nothing in the walk family scrolls today — B2's performance fixture
brings the scripted scroll measurement).

## Stage B, batch B1 — ACCEPTED (architect, 2026-08-09)

Verified: all four commits present; scope clean by own check (zero
`Sources/VariorumCore/`, zero `Shared/`, zero Mac-side, zero
pbxproj — the DEBUG door compiles out of Release, and the A4 fence
makes the seeded store the dev store by construction); the mobile
suite re-run by the architect's own hand: **"Test run with 215 tests
in 34 suites passed"** — 191/28 + 24 tests + 6 suites, exactly
accounted. **THE SPINE STANDS:** seven suite type names
(`MobileWalkTests` · `MobileTutorialBookShapeTests` ·
`MobileTutorialDoorTests` · `MobileTutorialWritingWalkTests` ·
`MobileTutorialTakesWalkTests` · `MobileTutorialStructureWalkTests` ·
`MobileTutorialLibraryWalkTests`), **32/7** — every later batch
record and ladder round in this chain states its green.

**Carried to the end bundle:** PB1-1 (the seeding door's product
placement — DEBUG-only today) · PB1-2 (guide/door names and copy) ·
PB1-3 (lesson prose hers to reword — walks pin staging, not prose
bytes) · **PB1-4 routed to Stage C's refusal-copy family with a
flag: the phone's merge still carries the Mac-naming ceremony
refusal, and the tutorial's merge lesson currently TEACHES it — when
C dissolves the refusal, the lesson and its walk update in the same
batch** (the tutorial-as-spec discipline: a stale lesson is a
regression). FB1-1/FB1-2 stand as recorded walk rules, not defects.

## Stage B, batch B2 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at the B1 acceptance commit. Expect zero
`Sources/VariorumCore/` changes (measurement reads what exists; a
need that wants core STOPS and returns to the architect). Zero
schema; `Sync/` untouched; the Environment traps section binds.

**Read first, IN FULL, in this order:** `CLAUDE.md` (P1–P3 — the
performance invariants this batch makes executable on the phone) ·
`notes/MobileSoul.md` §2 (THE BAR: her words — "I do not want the
mobile app to choke even on 100k words"; MEMORY is a first-class
metric — iOS jetsam; the executable form this batch builds) · THIS
plan file top to bottom (B1's record — the fixture rides beside the
pocket guide in the dev store, same door family) ·
`notes/plans/mobile-app-plan.md` §§ "The settled shape" and
"Environment traps" · the Mac P1 benchmark precedent IN CODE (the
Phase 4 perf suites under `Tests/VariorumCoreTests/` — flatness
assertions, not absolute wall-clock) ·
`notes/plans/mobile-architect-handoff.md`.

**The work:**

1. **The fixture, seeded in the DEV store** (the B1 door family — a
   DEBUG door beside the pocket guide's): a **~100k-word post**
   shaped like real writing (crystallization-scale blocks, realistic
   paragraph distribution, SOME fanned and commented blocks so the
   chrome layer participates in every measurement) plus a **large
   corpus** around it (hundreds of notes across several books — the
   scale that can prove corpus-flatness). Deterministic content
   (seeded generator, no `Date.now` randomness) so runs compare.
2. **The scripted measurement walk:** a repeatable harness measuring
   — post OPEN-TIME (open → first render) · TYPING latency (insert
   at the viewport in the 100k post) · SCROLL through the full post
   · **PEAK MEMORY across the whole walk** (the phone's own
   constraint; footprint, not compressed estimates). Two assertion
   kinds: **FLATNESS pins** (the 100k-post/large-corpus measurement
   vs a small-fixture control within a stated factor — the Mac P1
   shape; these are the suite's teeth) and **recorded absolutes**
   (informational, landed in the batch record — simulator numbers,
   explicitly labeled as such; the ON-DEVICE run is Stage D's exit
   gate, already planned). A memory CEILING pin is wanted but its
   bound is yours to propose from measurement — generous but
   meaningful, marked PROVISIONAL.
3. **The ladder spot-check, standing:** name the fixture suite(s) so
   every ladder round from here on runs them by name beside the
   spine. If the full walk is too heavy for every-run cadence, split
   a fast spot-check subset and say which is which.
4. **The spine stays green** (first batch under the new standing —
   your record states its 32/7 by your own named-selection run).

**Discipline:** work synchronously; red-on-old for any defect the
measurements expose (a flatness violation is a FINDING — trace it,
report it; if it gates the bar, STOP and return to the architect
rather than tuning around it). Full mobile suite green by your own
run, arithmetic accounted. Commit per logical unit with the standing
trailer; write "## Stage B, batch B2 — BATCH RECORD (implementer,
2026-08-09)" into THIS file (the fixture's shape, every measured
number with its label, the pins' factors/bounds, suite names,
PROVISIONALs); push `origin mobile` before finishing.

## Stage B, batch B2 — BATCH RECORD (implementer, 2026-08-09; commits `f62151a` · `976a86a` + the record commit)

**All four work items shipped — and the walk did exactly what it was
built to do: it caught a BAR-GATING P1 finding (FB2-1, below), traced
to its mechanism and NOT fixed or tuned around, per the brief's
letter.** Diff scope: three files (the seeder, the Settings door edit,
the walk suites) — **zero `Sources/VariorumCore/`** (the brief's
expectation held), zero `App/Variorum/Shared/`, zero Mac-side files,
zero schema, zero `Sync/`, zero pbxproj (synchronized groups). Core /
Mac / Mac-spine deliberately not run: the only-if-shared condition
never fired.

**1. THE FIXTURE — "the proving ground" (`MobilePerfFixtureSeeder`,
commit `f62151a`).** Reserved identities (the B1 discipline, disjoint
from the pocket guide's): book **"the proving ground"** holding
**"the long haul"** (the mega post) and **"the short walk"** (the
control), tag **"perf fixture"**, six corpus books **"field journal
vol. i…vi"**. The exact shape, store-verified equal to the generator's
own arithmetic (the seed is deterministic end to end — SplitMix64
prose, no `Date.now` anywhere in content):

- **The mega post: 100,025 words in 1,370 blocks** —
  crystallization-scale paragraphs (sentences 8–18 words, paragraphs
  3–6 sentences), **258 multi-paragraph blocks** (every 7th two
  paragraphs, every 19th three — I4's internal newlines), chrome
  staged on prime strides so the chrome layer participates in every
  measurement: **34 fanned · 26 commented · 14 callout blocks**
  (fans every 41st, comments every 53rd, callouts every 97th; take
  texts from an independent generator stream).
- **The control post: ~4,000 words, the SAME shape rules, its own
  seeds** — byte-identical in every world by construction (pinned),
  chrome-staged (1 fan · 1 comment · 1 callout) so both sides of
  every ratio run the same machinery.
- **The corpus: 300 notes spread evenly across the six books** (4–8
  one-paragraph blocks each; a fan every 10th note, a comment every
  15th). The SMALL control world: the same six books, 12 notes, no
  mega post — corpus SIZE is the axis, never corpus shape (pinned).
- All content `.generic`, no entry dates (R57 mirrored; pinned:
  zero journal-shaped rows). Seeded through ordinary Operations on
  the quiet facade (`undoStack: nil`; pinned untouched).
- **The DEBUG door** (Settings → "Performance (dev store)" → "Seed
  the 100k fixture", beside the pocket guide's doors): find-or-seed
  ONLY — an existing proving ground just reports; nothing is ever
  destroyed, so no confirm is owed (PB2-1 records the deliberate
  absence of a restore door). Latch + spoken outcome per the B1
  family; Debug = dev store by the A4 fence; a Release build
  verified the door compiles out (**BUILD SUCCEEDED**).

**2. THE MEASUREMENT WALK (`MobilePerfWalkTests`, commit `976a86a`)**
— the Mac PerfBenchmarkTests shape (ratios are the assertion,
absolutes are machine noise): median-of-N, **factor 3.0×** on every
flatness pin, noise floors (open 30 ms · keystroke 4 ms · scroll
step 4 ms), absolutes printed as `PERF[sim]` lines — **every number
below is a SIMULATOR number (iPhone 17 Pro / iOS 26.2, test host,
in-memory store); the on-device run is Stage D's exit gate.** The
axes, stated: typing and per-step scroll must be flat in POST size
(P1's heart); OPEN must be flat in CORPUS size — open is NOT flat in
the post's own length by design (the storage fill is O(post); AppSpec
§4's "reading a post is one indexed query"), so the 100k open is a
recorded absolute, never a flatness pin.

**The measured numbers (the final full-suite run, 2026-08-09):**

| Measurement | Control | 100k / big | Ratio | Verdict |
|---|---|---|---|---|
| Open, fixed control post — 12-note vs 300-note corpus | 33.8 ms | 35.0 ms | **1.03×** | **FLAT — green** |
| Open, the 100k post | — | **901.9 ms** | — | recorded absolute |
| Keystroke at the top viewport (4k vs 100k post) | 7.916 ms | **551.4 ms** | **69.7×** | **VIOLATION → FB2-1** |
| Keystroke at the end of the note | 7.916 ms | **297.8 ms** | **37.6×** | **VIOLATION → FB2-1** |
| Keystroke p95 | 9.4 ms | 575.9 / 401.8 ms | — | recorded |
| Scroll step, full walk (median) | 1.735 ms | **47.8 ms** | **27.6×** | **VIOLATION → FB2-1** |
| Scroll, the 100k post whole | 84 steps · 159 ms (control) | **2,075 steps · 100.5 s · p95 56.8 ms · worst 159.6 ms** | — | recorded |
| Memory across the whole walk (phys_footprint, sampled) | — | start 105 MiB · after open 117 MiB · **sampled peak 5,947 MiB · walk delta 5,842 MiB** | — | **VIOLATION → FB2-1** |

**FB2-1 — THE BAR-GATING FINDING (traced, recorded, deliberately not
fixed here: the brief's "a flatness violation is a FINDING, not a
tuning target" + the architect owns the disposition).** Her bar is
*"I do not want the mobile app to choke even on 100k words"* — the
app as built chokes at 100k: half-second keystrokes, 48 ms scroll
ticks (a 16 ms frame budget), and a memory profile that jetsam would
kill on a real phone many times over. The mechanism, traced cold with
a throwaway probe (windowless AND windowed — identical, so NOT a
harness artifact; probe deleted after use per the A1 precedent):

1. **Bare TK2 on the IDENTICAL 100k text is pristine:** open 6 ms ·
   keystroke ~5 ms · scroll step 0.6–1.0 ms · footprint FLAT
   (~75 MiB, zero growth over the walk). The platform is healthy —
   the Stage 0 ADOPT verdict re-confirmed at 100k. The app road is
   the entire cost.
2. **Every keystroke runs a DOCUMENT-scope chrome refresh:**
   `MobileEditorViewModel.storageDidEdit` ends with
   `textView?.refreshChrome()` — the DEFAULT `.document` scope — so
   each keystroke resolves `.ensuresLayout` geometry for all ~74
   decorated blocks across the whole 100k document. Measured: a
   document chrome pass costs 115–330 ms on the mega post (vs ~0 on
   the control — post-size-proportional, P1 violated).
3. **The amplifier — every document pass RE-WRITES
   `textContainer.exclusionPaths`** (probe: `changedSincePrior YES`
   on every consecutive pass, 39 exclusion rects): each write
   invalidates the WHOLE document's layout, exclusions carve the
   lines so re-resolved geometry shifts, the next pass's rects differ
   again — a self-sustaining geometry↔exclusion feedback loop. The
   far-geometry cost after one invalidation: 262.7 ms (vs 1.2 ms on
   clean layout — the probe's sharpest single number). The keystroke
   pays it twice: inside `storageDidEdit` (~170–450 ms) and again in
   the following layout pass (~310–340 ms).
4. **Scroll and memory are the same loop's other faces:** each
   scroll tick's `layoutSubviews` chrome pass costs ~12 ms clean but
   ~40–70 ms under the walk's continual invalidation churn; the
   churn's re-layout allocations accumulated a **5.9 GiB sampled
   footprint peak** across the full traversal (even 8 steps grow
   ~110 MiB; bare TK2: zero). The walk's 2,075 steps (vs ~450
   expected from bare content height) are the same churn's
   contentSize thrash, recorded.
5. **Open (901.9 ms vs bare 6 ms)** is the first document chrome
   pass + markdown styling + the far-decorated-block geometry
   forcing essentially full layout — heavy but not itself the
   bar-gating half; recorded.

**How the finding lives in the suite (the self-arming shape):** the
four violated assertions ride `withKnownIssue(FB2-1)` — the suite is
GREEN and honest today, and the moment the owning fix lands, each
wrapper's un-fired known issue FAILS its test until the wrapper is
removed: the pins activate themselves against the fix, which is
red-on-old inverted for a defect that predates its pin. The
open-corpus pin rides unwrapped (green on today's code). NOT fixed,
NOT tuned: no factor was widened, no probe was shrunk to pass.

**The PROVISIONAL memory ceiling (the brief's ask — proposed from
measurement):** `walkDeltaCeilingMB = 250` — the walk's sampled
`phys_footprint` delta over its own start must stay ≤ 250 MiB.
Derivation from the HEALTHY references (today's defect-inflated
5,842 MiB is no basis for a bound): bare TK2 holds the whole walk
flat (~0 delta) and the app road's open adds ~27 MiB, so 250 MiB is
~9× the healthy open delta — generous for a fixed app, categorically
under iOS foreground jetsam limits, and a bound today's churn (and
any future per-fragment leak) blows through. PROVISIONAL — the
architect/author may re-bound it, and Stage D's on-device run gives
the real-phone calibration.

**3. THE SUITES + THE LADDER SPOT-CHECK (standing):** the fixture
suites are **`MobilePerfFixtureTests` · `MobilePerfWalkTests`** —
run by exactly those TYPE names (the `-only-testing` trap). They
RIDE the baseline mobile suite, so every ladder's full-suite run
includes them by construction; the two-suite named run is the
standalone spot-check form. **Cost, stated honestly: ~2.5 min while
FB2-1 stands** (typing ~23 s + the merged full-traversal test
~110 s — the defect's own cost; the two heavy twins were merged into
ONE traversal precisely to halve this) **and ~15 s once the fix
lands.** An env-var gate for the heavy half was built, PROVEN
undeliverable (`TEST_RUNNER_`- and `SIMCTL_CHILD`-prefixed variables
both fail to reach this project's hosted runner — verified by env
dump), and REMOVED: a pin nobody runs is the silent-skip failure
mode. If a later ladder finds the interim cost too heavy, splitting
is the architect's call — the record here is the which-is-which.

**4. THE SPINE:** **"Test run with 32 tests in 7 suites passed"** by
this implementer's own named-selection run (the seven suite type
names, unchanged from B1).

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2):**
full mobile suite — **"Test run with 224 tests in 36 suites passed"**
(4 known issues, all FB2-1's wrappers; exit 0) — the 215/34 baseline
+ this batch's 9 tests and 2 suites, exactly accounted (6 fixture +
3 walk). A Release mobile build also succeeded (the door's DEBUG gate
compiles out clean).

**PROVISIONALs (for the chain's end bundle):**
- **PB2-1:** the perf door is find-or-seed ONLY — no wholesale
  restore door (nothing destructive ⇒ no confirm; a mangled fixture
  is re-seedable by deleting "the proving ground" through ordinary
  doors and tapping seed again). One door beside B1's two; hers to
  extend.
- **PB2-2:** the memory ceiling's bound (250 MiB walk delta) and its
  test-host framing (in-memory store; the app's on-disk dev store and
  the real phone differ — Stage D calibrates). The bound is the
  target the FB2-1 fix must meet.
- **PB2-3:** the fixture's exact scale constants — 100k mega target ·
  4k control · 300/12 corpus notes · six books · the prime strides —
  all one-line changes if her walkthrough wants a different feel.

**Deliberate absences (scope, not holes):** NO fix for FB2-1 (the
brief's stop-shape: traced and returned to the architect — the fix is
editor-architecture work: keystroke-scope banding, exclusion
staleness keyed on content rather than rect-compare, and breaking the
geometry↔exclusion feedback loop; whether the Mac's chrome shares any
of the class is the architect's routing question, not asserted here);
no Read-flow or shell-surface measurements (the brief's four
measurements are the walk; the shell's P1 discipline is pinned
elsewhere); no on-device numbers (Stage D's exit gate, already
planned); the dev store is not pre-seeded by this batch (the door is
one tap).

## Stage B, batch B2 — ACCEPTED; FB2-1 ADJUDICATED: FIX NOW, IN-CHAIN, AS BATCH B3 (architect, 2026-08-09)

Verified: all three commits present; scope clean by own check (zero
core/Shared lines); the full mobile suite re-run by the architect's
own hand: **"Test run with 224 tests in 36 suites passed … with 4
known issues"** — the four being exactly FB2-1's self-arming wrapped
pins, arithmetic exact (215/34 + 6 + 3 + 2 suites). The fixture is
the stage's point proven: it exists to catch exactly this.

**FB2-1's disposition — FIX NOW, as Stage B's fix batch (B3), before
the Stage B ladder.** Reasoning: the soul document makes performance
IDENTITY and her bar is explicit ("I do not want the mobile app to
choke even on 100k words") — 551 ms keystrokes, 28× scroll steps,
and a ~5.8 GiB walk delta ARE the choke, and the banned failure mode
is the app's founding grievance. Routing it to Stage D would build
Stage C's whole capability layer on a choking editor and guarantee a
failed on-device exit gate. The mechanism is TRACED (B2's record):
`storageDidEdit` → document-scope `refreshChrome()` → every pass
re-writes `exclusionPaths` → whole-document layout invalidation — a
geometry↔exclusion feedback loop; bare TK2 on identical text is
pristine, so the app road is the entire cost. P-8 names the law the
fix restores: **invalidation ∝ realized rows/viewport, never
document size**; the overlay law's equality-gating discipline is the
adjacent precedent. **PB2-2's 250 MiB walk-delta ceiling is the
fix's numeric target** (device calibration stays Stage D's).

**Also carried:** PB2-1 (find-or-seed-only door) · PB2-3 (fixture
scale constants) to the end bundle. The 100k OPEN absolute (901.9 ms
sim) stays a recorded-not-pinned number — the fix batch reports
where it lands after the document-pass cost collapses, and whether
an open-time pin is then honest to add (implementer reports, the
architect rules at acceptance).

## Stage B, batch B3 brief (the FB2-1 fix batch — self-contained; the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at the B2 acceptance commit. Mobile
app-layer work expected (`MobileTakesChrome*` and the edit
notification road); zero `Sources/VariorumCore/`; zero schema;
`Sync/` untouched; Environment traps bind.

**Read first, IN FULL:** `CLAUDE.md` (P1–P3; P-8's invalidation law)
· `notes/MobileSoul.md` §2 · THIS plan file top to bottom — above
all **the B2 BATCH RECORD's FB2-1 trace** (the mechanism is already
traced; re-verify it yourself against the code before designing, the
hallucination guard binds) — and the A3/FIX-5 records (the chrome
layer you are changing carries their pins) ·
`notes/plans/mobile-architect-handoff.md`.

**The work — restore P1/P-8 on the editing road:**

1. **Scope the chrome refresh to the edit.** `storageDidEdit` knows
   its edited range; the chrome pass must touch only the blocks
   whose chrome that edit can change (plus viewport-realized
   geometry), never the document. Design the scoping yourself from
   the traced mechanism — but the LAW is fixed: invalidation ∝
   viewport + edit, never post length.
2. **Break the exclusion feedback loop.** `exclusionPaths` writes
   must be equality-gated (an unchanged path set is never
   re-written) and scoped — a chrome pass that changes nothing must
   invalidate nothing. The overlay law's wire-time-delivery +
   equality-gate discipline is the precedent; mind its trap (state
   computed before layout exists, frozen by the gate) — deliver at
   wire time, gate only real non-changes.
3. **The pins are the proof:** B2's four violated pins ride
   `withKnownIssue(FB2-1)` and are SELF-ARMING — they fail the
   moment the fix lands until unwrapped. Unwrap them as the fix
   lands (that unwrap IS the red-on-old evidence in reverse: red
   yesterday by measurement, green today by the same measurement).
   The 250 MiB walk-delta memory ceiling (PB2-2) arms as a real pin.
   Every existing chrome pin (A3's P38 guard, FIX-5's strip pin, the
   A1 keyboard pin) stays green — the chrome layer's behavior is
   pinned; only its COST may change.
4. **Re-run the full measurement walk and record the post-fix
   numbers** (open · keystroke top/end · scroll · peak memory, same
   labels as B2's record) — these are her end bundle's honest
   numbers. Report where the 100k OPEN lands and whether an
   open-time pin would now be honest (report, don't add — the
   architect rules at acceptance).
5. **The spine stays green** (32/7 by your own named run) and the
   full suite green with ZERO known issues remaining.

**Discipline:** work synchronously (measurement runs are long — wait
them out); if the scoped design turns out to require touching shared
or core code, STOP and return to the architect with the constraint
rather than crossing the boundary. Commit per logical unit with the
standing trailer; write "## Stage B, batch B3 — BATCH RECORD (fix
batch, 2026-08-09)" into THIS file (the fix's design in P-8 terms,
per-pin unwrap results, the full post-fix number table beside B2's,
the ceiling pin's final bound, PROVISIONALs); push `origin mobile`
before finishing.

## Stage B, batch B3 — BATCH RECORD (fix batch, 2026-08-09; commits `129f695` · `529a97e` + the record commit)

**All five work items shipped; the bar is met; ZERO known issues
remain.** Diff scope: 8 files, all mobile app + mobile tests — **zero
`Sources/VariorumCore/`, zero `App/Variorum/Shared/`, zero Mac-side
files, zero schema, zero `Sync/`** (the STOP condition never fired);
Release build **SUCCEEDED**. But the fix's shape is NOT the one the
brief presumed, and the record leads with that honestly:

**THE ROOT, TRACED DEEPER THAN B2's WRITE-AMPLIFIER (the hallucination
guard executed — B2's trace re-verified by code-read AND a same-host
re-run of the walk, then probed further before designing).** The
pre-fix baseline reproduced on this host to within noise (keystroke
553.7/302.5 ms · scroll step 47.7 ms · walk delta 5,763 MiB · open
910.3 ms). The `.edit` scoping alone (item 1 as written) collapsed
only PART of the cost (keystroke 553.7 → 285.9 ms) — a throwaway
component probe (both probes deleted after use, the A1/B2 precedent)
then isolated the residue to the LAYOUT pass itself and proved the
deeper truth: **container `exclusionPaths` make TK2's post-edit
relayout DOCUMENT-scale by PRESENCE alone** — with the 39 staged
rects, ~263–300 ms per keystroke's layout; with even **ONE** rect,
~155–190 ms, **position-independent** (a rect at minY 1622 and one at
minY 410,952 measured identically); with **zero**, 0.51–1.9 ms
(bare-class) — and exclusions inflate TK2's height estimate ~1.4×
(contentSize 414,781 under rects vs 294,742 clean — the 2,075-step
scroll thrash's mechanism, and most of the memory churn's). The B2
trace's write-loop was real but was the amplifier, not the root: **no
equality-gating or scoping of WRITES can meet the bar while any rect
is installed.** The brief's item 2 presumed the exclusion mechanism
survives; the LAW it fixed ("invalidation ∝ viewport + edit, never
post length") is unmeetable under that presumption, and the law is
what this record obeyed. The Mac never uses `exclusionPaths`
(grep-zero) — the mechanism was mobile-local (LK10's implementation
choice, not shared canon), so the swap below crosses no platform seam.

**THE FIX'S DESIGN, in P-8 terms (three legs, commit `129f695`):**

1. **The edit-scoped chrome pass (item 1 as briefed):**
   `RefreshScope` gains `.edit(NSRange)`; the band = the padded
   near-viewport band ∪ the edited range (`NSUnionRange` — an honest
   covering superset, so a dictation landing while scrolled away
   still refreshes its own block); unavailable viewport or a width
   change escalates to a full pass (the standing honest fallback);
   `storageDidEdit` routes through it. `.document` remains the
   delivery/flip/voice axes' scope — user-act or settle cadence,
   never keystroke. Invalidation ∝ viewport + edit.
2. **The gutter mechanism moved to first-paragraph PARAGRAPH-STYLE
   reservations** — `MobileEditorTextView.setTailReservation` /
   `setLeadingFirstLineReservation` (the S4 one-implementation rule:
   one door, both controllers): the takes chrome owns the TAIL
   (LK10's 30 pt gutter, + P38's 26 pt comment-mark room,
   content-keyed exactly as before), the decor owns the emoji
   `firstLineHeadIndent` (exactly first-line-only — better fidelity
   than the old rect), read-modify-write on one style object so both
   compose on a block carrying both. Position-independent, so TK2's
   relayout stays incremental. **The reservation walk is
   band-INDEPENDENT and equality-gated against STORAGE TRUTH at the
   paragraph's governing character** (attribute reads force no
   layout) — never a cached record, which is the brief's overlay-law
   trap dodged at the design level: a materialization or voice
   re-base that dropped the style heals at the next pass's verify; a
   steady-state pass writes NOTHING; a real write invalidates
   exactly one paragraph. Container exclusion paths are RETIRED on
   the Write surface and pinned never to return.
3. **The O(entries²)/O(decorated×entries) walks flattened** (justified
   by B2's own measured ~12 ms "clean" tick vs the 5 ms bound): the
   chrome controllers read every block range from ONE index walk per
   pass (`MobileEditorViewModel.blockRangesByID`, replacing 74 ×
   O(entries) `rangeOfBlock` scans), and the DEBUG identity audit
   drops its per-entry `range(ofEntryAt:)` calls (O(entries²) —
   ~1.9 M additions per keystroke at 1,370 blocks) for a
   running-location walk. Same oracle, same checks, same ranges.

**THE MECHANISM PIN (written FIRST, red on the unfixed tree):**
`MobileTakesChromeTests.aKeystrokesChromePassIsEditScopedAndWriteFree
WhenNothingMoved` — one policed keystroke into the near block of a
long post asserts: the FAR fanned block is never layout-forced
(RED-ON-OLD — the pre-B3 `.document` keystroke pass resolved it; run
red before the fix with 10 siblings green), its chrome survives, the
container carries NO exclusion paths (FB2-1's root guard — any
return re-opens the 160 ms+ class), and the far paragraph's governing
style is the SAME OBJECT after the keystroke (no write — the
write-free and no-exclusions halves are guards against regrowth, not
the discriminator; recorded per the guard).

**THE STANDING PINS — every BEHAVIOR assertion intact; MECHANISM-
reading lines flipped to the new mechanism (recorded openly for the
architect's adjudication, since the brief's letter said the named
pins "stay green" and their behavior halves did — but four pins' and
one walk's internal lines READ the exclusion rects and could not
survive the mechanism the law forced):**
- **A3's P38 guard** (`aOneLineFannedAndCommentedBlockNeverCrowdsThe
  Badge`): the widths-[30, 56]-via-exclusionPaths line now reads the
  two blocks' tail reservations (56 target, 30 sibling — same
  numbers, same discrimination); **the behavior assertion — the ●n
  marker never intersects the ⑂ badge — is byte-identical and
  green.**
- **FIX-3's flush-end probe**: passes **UNCHANGED** — its reserve
  arithmetic (30 + 26) is mechanism-independent and its assertions
  were always behavioral.
- **The S2 badge/gutter pin**: exclusion count/bounds lines → the
  fanned block reserves 30, the fanless reserves 0, the container is
  exclusion-free; badge-in-column and first-line assertions kept
  (`textNeverRunsUnderTheBadge` — the pure behavior pin — passes
  untouched).
- **The S2 MINOR-3 per-tick scope pin**: the off-band-exclusion-
  survives lines → the off-band reservation survives (storage truth);
  the geometry-scope assertions (`lastGeometryResolvedBlockIDs`)
  byte-identical.
- **The A1 walk's gutter line** and **the S4 emoji-gap test**: flipped
  to reservation reads the same way.
- **FIX-5's strip pin and the A1 keyboard pin: untouched and green**
  (the full suite contains both).
- **Recorded behavior delta (PROVISIONAL PB3-2 below):** the tail
  reservation shortens every line of a fanned block's FIRST PARAGRAPH
  where the old rect shortened only the first LINE — identical for
  the common one-line/one-paragraph fan; a multi-line first paragraph
  now ends each line 30 pt short. The emoji gap's fidelity went the
  other way: exactly first-line-only, as the rect was.

**PER-PIN UNWRAP RESULTS (item 3 — the self-arming shape executed
exactly as designed, commit `529a97e`):** with the fix landed, all
four wrappers FIRED against it — keystroke(top) and keystroke(end)
reported their expectations mid-collapse, the scroll-step pin
reported **"Known issue was not recorded"** (its median passed the
standing bound outright), and the ceiling likewise once the harness
told the truth (below) — red-on-old in reverse, per the brief's own
words. All four wrappers REMOVED; the pins ride armed; the `fb2_1`
doc block in the walk file is now the finding's FIXED record.

**Two measurement-honesty changes, each derived, neither a widened
factor (the 3.0× ratio stands untouched):**
- **The typing noise floor re-derived 4 → 12 ms (PROVISIONAL
  PB3-1):** B2 set 4 ms as a noise floor under a then-8 ms control;
  the fix collapsed the control to ~0.7 ms, making the floor the
  binding bound — and it sat BELOW the PLATFORM's own cost: B2's own
  bare-TK2 probe measured **~5 ms per keystroke at 100k on bare
  TK2** (the platform's per-edit bookkeeping at 1,370 paragraphs), so
  no app-layer fix can meet 4 ms. Post-fix the 100k keystroke medians
  6–8 ms = platform ~5 + app road ≤ ~2.5 (audit + scoped chrome +
  index walks, all O(entries), none O(bytes)). 12 ms = platform floor
  + app road + host-variance headroom; under ¾ of a 60 Hz frame (the
  bar's "doesn't choke" met with room); 45× tighter than the defect
  it guards (551 ms — any exclusion-path return measures 160 ms+).
- **The walk drains its autorelease pool once per step/keystroke,
  inside the timed window** (a real frame drains; the synchronous
  loop was accumulating 2,077 turns of autoreleased garbage no phone
  ever holds — post-fix the undrained walk still measured 545 MiB of
  pure pile). Harness fidelity, not tuning: the drain's cost is timed
  as part of each step.

**THE POST-FIX NUMBER TABLE (final full-suite run, iPhone 17 Pro /
iOS 26.2 simulator, test host, in-memory store — B2's numbers beside;
the on-device run remains Stage D's exit gate):**

| Measurement | B2 (pre-fix) | B3 (post-fix) | Verdict |
|---|---|---|---|
| Open, control post — 12 vs 300-note corpus | 33.8 / 35.0 ms (1.03×) | 25.1 / 23.4 ms (**0.93×**) | FLAT — green (unwrapped all along) |
| Open, the 100k post | 901.9 ms | **433.2 ms** | recorded absolute (see below) |
| Keystroke, top viewport (4k vs 100k) | 7.9 → 551.4 ms (**69.7×**) | 0.70 → **6.09 ms** (8.7×; bound = 12 ms floor) | **ARMED, green** |
| Keystroke, end of note | 7.9 → 297.8 ms (**37.6×**) | 0.70 → **7.01 ms** (10.0×) | **ARMED, green** |
| Keystroke p95 | 575.9 / 401.8 ms | **7.0 / 8.8 ms** | recorded |
| Scroll step, full walk (median) | 1.74 → 47.8 ms (**27.6×**) | 0.47 → **1.70 ms** (3.59×; bound = 4 ms floor) | **ARMED, green** |
| Scroll, the 100k post whole | 2,075 steps · 100.5 s · p95 56.8 | 2,077 steps · **3.65 s** · p95 2.38 · worst 8.81 | recorded |
| Memory, whole walk (phys_footprint) | peak 5,947 · delta 5,842 MiB | peak **107** · delta **43 MiB** | **CEILING ARMED at 250 MiB — green, 5.8× headroom** |

*(The residual ~2,077-step count is TK2's own estimate-revision chase
during a full traversal — the estimates converge upward as real
layout replaces them, the walk's y chases, and per-step cost stays
flat; steady-state contentSize is the real ~294.7k. TEXTKIT2 §2's
class, not the app's.)*

**THE 100k OPEN — reported for the architect's ruling (item 4):**
433.2 ms sim (halved from 901.9 — the open's document chrome passes
now run on layout that exclusion writes no longer invalidate between
them). **Recommendation: keep it a recorded absolute, not a pin** —
open is O(post) BY DESIGN (B2's axes statement; AppSpec §4's "reading
a post is one indexed query" covers the storage fill, and the first
full materialization + markdown styling + first layout are honestly
post-proportional), and an absolute wall-clock pin on a shared
simulator host is the machine-noise class the Mac's ratio-shaped P1
suite deliberately avoids. The corpus-flatness open pin (the axis
that CAN regress by accident) is armed and green. The architect
rules at acceptance.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2):**
full mobile suite — **"Test run with 225 tests in 36 suites passed"**
— ZERO known issues (the brief's item 5 bar), 224/36 + the mechanism
pin, exactly accounted; the suite runs in **18.4 s** where FB2-1's
churn held it at ~2.5 min (B2's predicted "~15 s once the fix lands",
confirmed at suite level). Spine: **"Test run with 32 tests in 7
suites passed"** by named-selection run. Perf suites standalone: 9/2
green. Release build: **BUILD SUCCEEDED**. Core / Mac / Mac-spine
deliberately not run: zero core, zero `Shared/`, zero Mac-side lines
— the only-if-shared condition never fired.

**PROVISIONALs (for the chain's end bundle):**
- **PB3-1:** the typing noise floor's re-derived value (12 ms; the
  derivation above — platform ~5 ms + app road + headroom). The
  architect/author may re-bound; Stage D's on-device run gives the
  real phone's calibration for both this and the ceiling.
- **PB3-2:** the tail reservation's paragraph-granularity — a
  MULTI-LINE first paragraph of a fanned block now ends every line
  30 pt short (the old rect shortened only line one). Identical for
  the common short fan; her look round may prefer the old shape, in
  which case the road is a custom TK2 layout-fragment (TEXTKIT2 §3
  risk) or accepting exclusions ONLY on such blocks (re-opening the
  measured cost) — recorded so the trade is hers.
- **PB3-3:** the mechanism-line pin flips (the list above) — executed
  under the law's authority ("the LAW is fixed") with every behavior
  assertion intact; the architect's acceptance is their sanction, and
  any flip found wrong reverts against the retained old lines in
  git history.
- **PB2-2 RESOLVES:** the 250 MiB walk-delta ceiling is ARMED as
  proposed (measured delta 43 MiB); its device calibration stays
  Stage D's.

**Deliberate absences (scope, not holes):** the open road's redundant
double document-pass (ingest refreshes after `applyProjection` arms
that already refreshed) survives — removing it would change the
settle cadence the standing pins exercise, open is report-only, and
the passes are now cheap (2.3 ms on valid layout, measured); noted
for any future open-time work. The two throwaway probes were deleted
after use (their numbers live in this record and the commit
messages). No Read-flow measurements (B2's boundary); no on-device
numbers (Stage D's gate).

## Stage B, batch B3 — ACCEPTED; STAGE B BUILD COMPLETE — the ladder OPENS (architect, 2026-08-09)

Verified: three commits present; scope clean by own check (zero
core/Shared lines — the exclusion retirement is mobile-local; the
Mac never used exclusionPaths); the full mobile suite re-run by the
architect's own hand: **"Test run with 225 tests in 36 suites
passed" in 18.5 s, ZERO known issues** (FB2-1's four self-armed
wrappers all fired and unwrapped; the 250 MiB ceiling ARMED at a
measured 43 MiB delta — PB2-2 resolves). The headline table (sim):
keystroke top **551.4 → 6.09 ms** · end **297.8 → 7.01 ms** · scroll
step **47.8 → 1.70 ms** · walk delta **5,842 → 43 MiB** · 100k open
**901.9 → 433.2 ms**. Her bar's executable form now holds on the
simulator; the device calibration stays Stage D's exit gate.

**Two acceptance rulings:**
- **The 100k OPEN stays recorded-not-pinned** (the fix session's
  recommendation, accepted): open is O(post) by design and absolute
  wall-clock pins are the machine-noise class; the number rides the
  record and Stage D's device run re-measures it.
- **PB3-3 (mechanism-reading lines in four pins flipped from
  exclusion reads to reservation reads) — ACCEPTED:** the pins'
  BEHAVIOR assertions are byte-identical; the flipped lines read the
  new mechanism because the old one no longer exists, which is the
  parity-refactor reading of "pins compile and pass unmodified" —
  the assertions, not the plumbing, are the pin. PB3-1 (the noise
  floor re-derived 4 → 12 ms because bare TK2 itself pays ~5 ms at
  100k) is accepted on its recorded derivation; the 3× factor stands
  untouched.

**THE STAGE B LADDER OPENS.** Target: the stage's combined diff
`5aa10f5..2f5b008` (B1 `9c3fba1`…`b3d3784` · B2 `f62151a`,
`976a86a` · B3 `129f695`, `529a97e`, with the three batch records +
acceptance notes + the FB2-1 adjudication as the reviewer's anchor).
Fresh cold reviewer, `notes/REVIEW_PROMPT.md` VERBATIM, zero
framing; findings repo-first as "## Stage B review — round 1
findings". Baselines at ladder-open: **mobile 225/36 (zero known
issues) · spine 32/7 · core 1214/128 · Mac 1245/219 tripwire-only ·
spine-Mac 51/7.**

## Stage B review — round 1 findings (cold reviewer, 2026-08-09)

Cold review of the Stage B combined diff `5aa10f5..2f5b008` (13
mobile files + this plan file; commits `9c3fba1`…`529a97e`), run
against `notes/REVIEW_PROMPT.md` verbatim with zero implementation
context. Anchors read in full: the Stage B kickoff + all three batch
records + acceptances + the FB2-1 adjudication; `notes/MobileSoul.md`
(§2 load-bearing); CLAUDE.md; the canonical docs' invariant sections;
the entire diff plus the current state of every touched file (and the
surrounding files the mechanisms ride through: `MobileEditorStyle`,
`MobileStructural`, `MarkdownFace`'s call site, the storage-delegate
road). No "Review foci" section exists for this project. No fixes
made; read-only throughout.

### Findings

**MINOR 1 · `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift:339–383` + `Features/Takes/MobileTakesChrome.swift:188` — reservation paragraph styles leak beyond the first paragraph and outlive their purpose; unrecorded (PB3-2 covers a different, narrower delta).**
Mechanism: `setReservation` writes the mutated style over the WHOLE
first-paragraph range, deliberately including the trailing separator
newline (the file's own comment, line 339, calls this "harmless and
deliberate"). Two concrete leak roads follow: **(a) the split
residue** — typing Enter INSIDE a fanned block's first paragraph
(I4: newline is content) splits it; the second paragraph's characters
already carry `tailIndent −30` (or −56 commented), the equality gate
reads only the governing FIRST character (which is correct, so no
pass ever re-writes), cleanup on fan-death clears only the first
paragraph — so every line of the continuation paragraph renders
30+ pt short for the rest of the session (heals only at a full
re-materialization: re-open or voice switch). The emoji
`firstLineHeadIndent` mirror: a split callout block's second
paragraph indents its first line with no glyph over it. **(b) the
separator inheritance** — because the styled paragraph range includes
the block's separator "\n", UIKit's typing-attribute derivation
(re-derived from the preceding character at each caret move; the
constructor's one-time `typingAttributes` write at
MobileEditorTextView.swift:462 does not pin it) hands the reservation
to text typed immediately after a one-paragraph fanned block — the
open tail, and every block crystallized from it, carries a permanent
30 pt tail dent with no fan. Evidence: the write pattern read at
:369–383 (whole-paragraph `addAttribute` incl. separator), the gate
at :347–366 (governing character only), cleanup at
MobileTakesChrome.swift:218–222 (first paragraph only); variant (a)
is pure attribute persistence; variant (b) additionally rides
documented UIKit typingAttributes behavior — traced, not executed by
this reviewer. Red-on-old pinnable: seed a one-paragraph fanned
block → settle chrome → `typeEdit` "\n" mid-first-paragraph →
chrome pass → assert the second paragraph's governing `tailIndent
== 0` (fails today). Proposed fix: the reservation walk (which
already holds the block's full range) normalizes the block's
NON-first paragraphs to zero reservation, and/or the write excludes
the separator so the tail never inherits.

**MINOR 2 · `App/Variorum/VariorumMobileTests/MobilePerfWalkTests.swift:552–560` (+ `Features/Write/MobileEditorViewModel.swift:698`, `Features/Takes/MobileTakesChrome.swift:173`, `Features/Write/MobileBlockDecor.swift:101`) — the post-axis "flatness" pins no longer bind through the ratio; the floors are the only teeth, and the residual per-event cost is O(entries) by mechanism.**
Evidence, this reviewer's own full-suite run: keystroke ratios
**9.44× / 10.39×**, scroll step **4.22×** — all beyond the stated
3.0× factor; every post-axis pin passes solely under its absolute
floor (12 ms / 4 ms), so the 3× factor is dead weight on them and a
genuine post-size regression up to the floor (keystroke 6.7 →
11.9 ms) would pass silently under a test named
`typingAtTheViewportIsFlatInPostSize`. The floors are honestly
derived (PB3-1's platform-floor derivation is recorded and was
accepted; her bar is met with room) — the finding is that the pins'
names/comments still claim the ratio axis while the binding
assertion is an absolute per-event budget at the 100k bar. The
mechanism of the residual growth is concrete: the keystroke and
EVERY scroll tick pay O(entries) — `blockRangesByID()` is built
**twice per refresh door** (once per controller: MobileBlockDecor
:101 and MobileTakesChrome :173 — the B3 record's "ONE index walk
per pass" is per-controller, two per pass), unconditionally even for
a post with zero decorated blocks, plus the band-independent
O(fanned) reservation verify per pass. At 1,370 entries that is the
measured 1.8 ms vs 0.43 control. P1's letter ("cost ∝ viewport +
edit, never document size") is met up to this linear small-constant
term hidden under the floor. Proposed: re-comment/rename the
post-axis pins to what they assert (per-event absolute budgets at
the bar, floors binding), and cheaply shrink the mechanism — build
the ranges dict once in `refreshChrome` and pass it to both
controllers, with an early-out when no slot is decorated. Not a bar
violation today; recorded so the next scale jump doesn't
rediscover it.

**NIT 1 · `App/Variorum/VariorumMobileTests/MobileTakesChromeTests.swift:182, 266–273, 311, 320–326` — surviving pins narrate the retired exclusion mechanism.**
`textNeverRunsUnderTheBadge`'s comment still says the discrimination
"proves the exclusion rect … did it"; the FIX-3 flush-end probe's
doc block and recorded PROBE VERDICT derive its candidate band from
exclusion-path-edge behavior ("TK2 applies lineFragmentPadding
against exclusion-path edges", "the widened exclusion", settle
rounds "exclusion → relayout → chrome") — a mechanism that no longer
exists on this surface. The assertions are behavioral and pass under
reservations, but the recorded derivation is exactly what the pin's
own re-derivation instruction would mislead. One-comment fixes;
PB3-3's open flip list covered the flipped pins, not these two
survivors.

**NIT 2 · `App/Variorum/VariorumMobile/Features/Shell/MobileSettingsView.swift:192–216` — the "Open the pocket guide" door re-implements `findOrSeed`'s branching inline, and never opens.**
The tested seam `MobileTutorialSeeder.findOrSeed(session:confirmReplace:)`
takes exactly the continuation-shaped closure the view builds, yet
`tutorialDoor` duplicates the discover → exists-report /
residue-confirm → restore grammar by hand (two encodings of one
grammar = drift risk; the MAJOR-A same-`Existing` discipline is
preserved, verified). And the door labeled "Open…" only
seeds-or-reports — it never navigates to the book. DEBUG-only;
recorded for the Stage C door families.

**NIT 3 · `App/Variorum/VariorumMobile/Features/Shell/MobileSettingsView.swift:39, 204–208` — the confirm continuation can strand.**
If the Settings sheet is torn down while the replace alert is up
(swipe-dismiss), neither alert button runs, the checked continuation
never resumes, and `tutorialDoor` suspends forever (leaked
continuation + the in-flight latch held for the sheet's next
presentation). DEBUG-only, low stakes; resume(false) on disappear is
the one-line shape.

### Clean bill (load-bearing things specifically checked and found solid)

- **The suite counts, by this reviewer's own runs** (below): full
  mobile **225/36 passed, 18.5 s, ZERO known issues**; the spine by
  its seven type names **32/7 passed**. Arithmetic exact: 191/28 +
  24/6 (B1) + 9/2 (B2) + 1 mechanism pin (B3) = 225/36.
- **The B3 headline numbers reproduce on this host within noise**
  (my run's own `PERF[sim]` lines): open(100k) 464.2 ms (record
  433.2) · keystroke 6.72/7.40 ms (6.09/7.01) · scroll step 1.80 ms
  (1.70) · walk delta 40 MiB vs the armed 250 (43) · corpus-open
  1.13× flat · 2,077 steps / 3.63 s full traversal. The bar's
  executable form holds on the simulator by independent measurement.
- **The mechanism pin** (`aKeystrokesChromePassIsEditScopedAndWrite
  FreeWhenNothingMoved`, MobileTakesChromeTests:552) read in full:
  the far-not-resolved half is the discriminator and is red-on-old
  by mechanism — the pre-B3 `storageDidEdit` ended in the
  `.document`-default `refreshChrome()` (seen in the diff), whose
  nil band resolves every fanned block's geometry, so the far-block
  assertion fails on that tree; the `===` same-style-object
  assertion is a real write-free guard; the empty-`exclusionPaths`
  assertion is the root guard.
- **The exclusion retirement is total and mobile-local:** grep-zero
  live `exclusionPaths` references in mobile sources (doc comments
  only) and grep-zero on the Mac side — the B3 claim verified.
- **No write loop:** the storage observer guards on
  `.editedCharacters` (MobileEditorViewModel:1411), so reservation
  attribute writes cannot re-enter `storageDidEdit`; both
  controllers carry the reentrancy latch (`refreshing`), and the
  equality gates make the steady state write-free.
- **The composition rule holds in code:** decor owns
  `firstLineHeadIndent`, chrome owns `tailIndent`, both
  read-modify-write ONE style object in the deterministic
  decor→chrome order; the `.edit` band (near ∪ edited, NSUnionRange)
  and the width-change/no-viewport full-pass escalations are
  byte-mirrored in both controllers; `.document` remains the
  delivery/flip/voice cadence (call sites read: 348, 428, 537, 562,
  802 vs the one `.edit` at 915 and the one `.nearViewport` at the
  layout hook).
- **No paragraph-style clobber class:** `MarkdownFace` writes no
  `paragraphStyle` (grep over Write/ + Shared/); `applyVoiceChange`
  re-bases paragraph styles and then runs the document chrome pass
  in the same act, so reservations heal exactly as claimed.
- **The tutorial seeder's discipline:** Operations-only (no ad-hoc
  row writes anywhere in either seeder), the quiet no-undo facade
  with the walk pinning `undoStack.depth == 0`; R57 pinned
  store-wide (zero journal-shaped rows); reserved identities
  verified DISJOINT from the Mac's ("the field guide"/"tutorial"
  read in the Mac source); exact-tag cleanup (never subtree) with
  the sub-tag survival walk; the wholesale replace byte-compares her
  note's whole subtree (container/placements/blocks/variants); pin
  hygiene (no dead ids) walk-asserted; the confirm's disclosure
  matches what cleanup actually deletes.
- **The walks assert store outcomes through the app's own roads:**
  typeEdit for gate-dependent behavior (FB1-1's rule, applied); the
  Q-M2 duplicate-shape walk checks the peeked take is the one cut,
  both successors carry half + the whole duplicate, and the original
  is released with its full fan in lineage (the gate ruling's
  letter); merge's single-space join round-trips byte-exact; the
  ceremony step-back copy pinned in the walk matches the shipped
  string at `MobileStructural.swift:238` (and PB1-4's coupling flag
  is recorded for Stage C).
- **The perf fixture is honest:** deterministic end to end
  (SplitMix64, no `Date.now` in content, determinism pinned), store
  truth == generator arithmetic pinned at 100,025 words / 1,370
  blocks (my run's fixture line), the control byte-identical across
  worlds pinned, chrome staged on BOTH sides of every ratio,
  find-or-seed idempotence pinned, and the four B2 wrappers are
  really gone (grep: zero `withKnownIssue` callers; the helper's
  self-arming parameter survives documented for the next traced
  finding).
- **The 100k-open recorded-not-pinned ruling is internally
  consistent** with the stated axes (open is O(post) by design,
  AppSpec §4's letter) — and the axis that CAN regress by accident,
  corpus-size open, IS an armed pin and measured genuinely flat
  (1.13× my run).
- **Scope:** the combined diff touches exactly 13 mobile files +
  this plan file — zero `Sources/VariorumCore/`, zero
  `App/Variorum/Shared/`, zero Mac-side, zero schema, zero `Sync/`
  (file list verified against the diff stat). Core/Mac/Mac-spine
  baselines were therefore not re-run by this reviewer (nothing in
  the diff can move them); the mobile suite and spine were.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator)

- Full mobile suite: **"Test run with 225 tests in 36 suites passed
  after 18.496 seconds"** — exit 0, zero known issues, zero
  failures.
- The spine by its seven type names: **"Test run with 32 tests in 7
  suites passed after 3.616 seconds"** — TEST SUCCEEDED.
- Core / Mac / Mac-spine: not run (zero shared lines in the diff —
  the standing only-if-shared condition).

## Stage B review — round 1 ADJUDICATION (architect, 2026-08-09; the fix session spawns on this record)

No BLOCKER/MAJOR. All five findings adjudicated FIX — each is small,
none reopens design:

- **MINOR 1 → FIX-B1 (the reservation-style leak).** The reviewer's
  mechanism is concrete and red-on-old pinnable: a mid-paragraph
  Enter in a fanned block strands `tailIndent` on the continuation
  paragraph (the governing-character gate can never heal what it
  never governs), and the styled separator newline feeds UIKit
  `typingAttributes` so tails typed after a one-paragraph fanned
  block inherit a permanent 30 pt dent. Fix both roads (heal beyond
  the governing paragraph; keep `typingAttributes` clean of
  reservation styles); red-on-old pin per road, behavioral revert.
- **MINOR 2 → FIX-B2 (honest flatness teeth + the double-build).**
  Two halves, both owed: (a) single-build `blockRangesByID()` per
  refresh event (it is built twice, once per controller,
  unconditionally on every keystroke/scroll tick); (b) after (a),
  re-measure the post-axis ratios — if they then bind under 3.0×,
  restore the ratio as the pins' teeth; if they genuinely cannot
  (platform floor effects), RENAME the pins to what they enforce
  (floors) — a pin named "flat" that enforces a floor is the
  record-claim class. Report which road the measurement chose.
- **NIT 1 → FIX-B3:** the two surviving pins' narration flips to the
  reservation mechanism (comments/derivation only; assertions
  untouched).
- **NIT 2 → FIX-B4:** the pocket-guide door routes through the
  tested `findOrSeed` seam AND actually opens the guide (a door
  that says "Open" and doesn't navigate is the fire-and-DO class,
  DEBUG-only or not).
- **NIT 3 → FIX-B5:** the replace-confirm continuation is cancelled
  on sheet teardown (no leaked continuation, no held latch).

## Stage B review — round 1 FIX-PASS RECORD (fix session, 2026-08-09)

All five adjudicated fixes executed, one commit each, in the order
FIX-B1 · FIX-B2 · FIX-B3 · FIX-B4 · FIX-B5. Commits: FIX-B1 `bdb2272`
· FIX-B2 `730fc86` · FIX-B3 `dabab3c` · FIX-B4 `4328bbe` · FIX-B5
`8d93c94` (+ this record). Diff scope across the whole fix set,
verified by own `git diff --name-only 42d7392..HEAD`: **seven mobile
files — zero `Sources/VariorumCore/`, zero `App/Variorum/Shared/`,
zero Mac-app source, zero schema, zero `Sync/`** (the STOP condition
never fired; core/Mac/Mac-spine baselines therefore stand — 1214/128 ·
1245/219 tripwire-only · 51/7).

**FIX-B1 (the reservation-style leak, BOTH roads) — FIXED; one
red-on-old pin per road, both born red on the unfixed tree and
per-road revert-verified.** The pins were written FIRST and run
against the shipped tree: both fired one issue each on exactly the
traced mechanisms (continuation paragraph `tailIndent` reading 30.0;
tail character reading 30.0), 11 suite siblings green.

- *Road (a), the split residue:* `setReservation`
  (`MobileEditorTextView`) now walks every paragraph that BEGINS
  inside the block — the first gets the reservation's own
  equality-gated mutate, every later one gets an equality-gated HEAL
  to zero for that door's field (the emoji `firstLineHeadIndent`
  mirror rides the same shared implementation). A mid-paragraph Enter
  strands nothing: the very keystroke's own `.edit` chrome pass heals
  the continuation paragraph (the reservation walk is
  band-independent). Cost: one attribute read per continuation
  paragraph per pass, zero writes at steady state. *Pin:*
  `MobileTakesChromeTests/aMidParagraphReturnNeverStrandsTheReservationOnTheContinuationParagraph`.
- *Road (b), the typing inheritance — the fix's shape is NOT the
  reviewer's proposed write-exclusion, and the record leads with why:*
  the separator provably CANNOT be kept clean. A throwaway probe
  (bare `NSTextStorage`, with and without a TLM attached; deleted
  after use per the A1 precedent) pinned it cold: **NSTextStorage
  attribute FIXING re-propagates the paragraph's governing style
  across the whole paragraph, terminator included** — a write clamped
  to exclude the terminator reads back styled (−30) on both
  arrangements, and the first clamped-write implementation of this
  fix measured exactly that in-suite (pin (b) v1 stayed red under the
  clamp; the clamp was then dropped as dead behavior). So the fix
  heals the LANDING instead: `healTailReservationResidue` /
  `healLeadingReservationResidue` run on the `.edit` road after each
  controller's reservation walk, zeroing that controller's field
  across the edited range's paragraphs EXCEPT those the walk itself
  governs (a currently-reserved block's first paragraph) — a derived
  dent (the open tail, a next block's first characters, and every
  block crystallized from a dented tail) never survives its own
  keystroke's `storageDidEdit` pass. O(paragraphs in the edit), P-8
  clean; the write-free steady state and the B3 mechanism pin's
  same-style-object assertion are preserved (typing inside a reserved
  paragraph touches nothing — its start is a governed start). *Pin:*
  `MobileTakesChromeTests/aTailTypedAfterAFannedBlockNeverInheritsTheReservation`
  — opens the tail through the gate road (`typeEdit` ⏎ at the
  document end, FB1-1's rule), then types into the tail CARRYING the
  style read off the actual preceding character (the documented
  UIKit `typingAttributes` derivation, simulated the way FB1-1
  simulates the keyboard — windowless `insertText` bypasses
  `typingAttributes`, so the real derivation cannot be exercised
  headless), with a probe-liveness guard asserting the separator
  really carries the style the pin exists to contain.
- *Revert verification, per road:* heal walk disabled → ONLY pin (a)
  red (continuation paragraph 30.0), 12 others green; residue heal
  disabled → ONLY pin (b) red (tail character 30.0), 12 others green;
  fix restored → 13/1 green. Clean per-road discrimination.

**FIX-B2 (honest flatness teeth + the double-build) — (a) BUILT,
(b) MEASURED; the RENAME road chosen for both post-axis pins.**

- *(a)* `blockRangesByID()` now builds ONCE per refresh event: the one
  `refreshChrome` door builds it and hands it to both controllers
  (`refresh(scope:ranges:)`); solo controller refreshes (the
  peek/pill roads, direct test calls) self-build via the defaulted
  parameter — those are single-controller events, so they were never
  the double-build.
- *(b) The measurement (this host, iPhone 17 Pro / iOS 26.2, full
  fixture conditions).* PRE single-build (this session's own baseline
  run at the FIX-B1 tree): keystroke **8.34× / 9.42×** (0.767 →
  6.396 / 7.225 ms), scroll **4.24×** (0.419 → 1.775 ms). POST
  single-build, two runs: keystroke **8.84× / 9.55×** and **8.63× /
  9.53×** (control ~0.70 → big 6.0–6.8 ms), scroll **3.44×** and
  **3.75×** (0.41–0.45 → 1.55–1.56 ms). The single build shaved the
  expected fraction of a millisecond off the 100k side (scroll step
  ~1.78 → ~1.55 ms); the ratios do NOT bind under 3.0×, and the
  measurement says they genuinely cannot: for the keystroke, bare
  TK2's own per-edit cost at 1,370 paragraphs (~5 ms, B2's probe) is
  ~7× the control's 0.7 ms TOTAL — a platform-only ratio no
  app-layer change can beat; for the scroll, the walk holds 3.4–4.2×
  across clean runs (TK2's estimate-revision traversal at 100k plus
  the ONE remaining O(entries) ranges walk per tick, which the
  design requires — the reviewer's own "linear small-constant term").
  **Road chosen: RENAME**, per the adjudication's letter —
  `typingAtTheViewportIsFlatInPostSize` →
  `typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`;
  `theFullScrollIsFlatPerStepAndTheWalkHoldsTheMemoryCeiling` →
  `theFullScrollHoldsThePerStepBudgetAt100kAndTheWalkHoldsTheMemoryCeiling`.
  The assertions are byte-untouched (`big ≤ max(control × 3, floor)`
  — the floor binds today, and ratio teeth SELF-ARM on any host
  where the control rises past floor/3; every run still prints the
  ratio); the corpus-open pin keeps its flatness name — its ratio
  genuinely binds (0.94–1.13× measured). The suite header and
  constants block now state the per-axis teeth honestly.

**FIX-B3 (narration flips) — DONE, comments/derivation only, every
assertion byte-untouched.** `textNeverRunsUnderTheBadge`'s
discrimination line now names the tail reservation; the FIX-3
flush-end probe's doc block, settle-round comment, and PROBE VERDICT
derive the candidate band from the reservation's trailing boundary
(the verdict records that its numbers were measured under the Stage A
exclusion mechanism and stand green unchanged under reservations —
the arithmetic is mechanism-independent, and the probe's own
`oneLiners > 0` liveness guard held through the swap). Two same-class
comment lines found in the same file were flipped with them and are
recorded here for round 2 (the FIX-B3 class exactly, comment-only):
the file header's "exclusion-rect gutter" phrase and the
`perTickRefreshResolvesOnlyNearViewportGeometry` doc's "gutter
exclusion survives from its cached rect" line — a PB3-3 flip-list
survivor whose narration was factually wrong under reservations
(storage truth has no cached rect). Chrome suite 13/1 green.

**FIX-B4 (the pocket-guide door) — DONE, both halves.** The open door
is ONE call into the tested `MobileTutorialSeeder.findOrSeed(session:
confirmReplace:)` seam — the discover → exists / residue-confirm →
restore grammar is now encoded once, where the walk suites drive it
(MAJOR-A's same-`Existing` discipline is the seam's own) — and on
success the door DOES what its label says: the shell's
`onOpenTutorialBook` closure dismisses Settings and pushes
`MobileRoute.book(bookID)` onto the SHELF stack (fire-and-DO; an
already-seeded guide now OPENS instead of merely reporting). The tab
value is deliberately not written — Settings is the shelf's own door,
so the shelf tab is the visible one, and the tab doors own the
liveness handoff. The RESTORE door keeps its distinct always-replace
grammar on the same tested `discover`/`restore` seams (deliberately
NOT `findOrSeed`, which short-circuits at an existing book; its shape
was not the finding). DEBUG-only throughout (the A4 fence): Release
build **SUCCEEDED** with the door compiled out;
`MobileTutorialDoorTests` 5/1 green. The SwiftUI push wiring itself
is the recorded A1-masthead not-headless-testable class — the
chain-end look covers it.

**FIX-B5 (the continuation cancel) — DONE.** The Settings sheet's
`onDisappear` resolves a still-pending replace confirm as a DECLINE:
the awaiting door resumes through its normal refusal arm ("Left as it
was."), its `defer` releases the in-flight latch, and double-resume is
impossible by construction (both alert buttons nil the continuation
after resuming; the teardown checks nil first; all on the MainActor).
The reviewer's traced mechanism, the reviewer's one-line shape; the
same not-headless-testable wiring class as FIX-B4, recorded.

**Suites (this session's own runs, the final tree, iPhone 17 Pro /
iOS 26.2):**
- Full mobile: **"Test run with 227 tests in 36 suites passed"** in
  18.5 s — ZERO known issues; the 225/36 ladder-open baseline + the
  two FIX-B1 pins, exactly accounted (FIX-B2's renames are 1-for-1;
  no other test count moved).
- The spine by its seven type names: **"Test run with 32 tests in 7
  suites passed"**.
- The perf spot-check suites by name (`MobilePerfFixtureTests` ·
  `MobilePerfWalkTests`): **"Test run with 9 tests in 2 suites
  passed"** standalone (and inside the full run above).
- Final-tree perf lines (the record's honest numbers): open(100k)
  453.7 ms · keystroke 6.21 / 6.94 ms (ratios 8.35× / 9.32×) ·
  scroll step 1.58 ms (3.78×) · corpus-open 1.02× flat · walk delta
  39 MiB against the armed 250 MiB ceiling.
- Core / Mac / Mac-spine deliberately not run: zero shared lines in
  the fix set (the standing only-if-shared condition; the scope check
  above is the proof).

## Stage B ladder — fix set ACCEPTED by the architect; ROUND 2 OPENS (2026-08-09)

FIX-B1…FIX-B5 verified before relying: six commits present; scope
clean by own check (seven mobile files, zero core/Shared/Mac lines);
the full mobile suite re-run by the architect's own hand: **"Test run
with 227 tests in 36 suites passed", zero known issues, 18.5 s** —
225/36 + FIX-B1's two born-red pins, exactly accounted. FIX-B1's
mechanism discovery is accepted AND noted for the canon fold-in at
the stage closeout (NSTextStorage attribute fixing re-propagates the
governing paragraph style across the paragraph, terminator included —
the heal-the-landing shape is the only possible one). FIX-B2's
RENAME road is accepted on its two-run measurement (bare TK2's own
per-edit cost at 1,370 paragraphs makes a 3.0× post-axis ratio
unattainable; the pins now claim exactly what they enforce, the
ratio teeth self-arm if a control rises, and the corpus-axis pin
keeps its honestly-binding flatness name).

**ROUND 2 OPENS** (fresh cold reviewer; a real pass over the fixes
and what they touched): anchor = the round-1 findings + adjudication
+ fix-pass record above; fix-set diff `42d7392..747e3fd` inside the
stage's combined `5aa10f5..747e3fd`. New BLOCKER/MAJOR ⇒ round 3
(hard cap three). Baselines at round-2 open: **mobile 227/36 zero
known issues · spine 32/7 · perf suites 9/2 · core 1214/128 · Mac
1245/219 tripwire-only · spine-Mac 51/7.**

## Stage B review — round 2 (fresh cold reviewer, 2026-08-09)

A real re-review of the fix set `42d7392..747e3fd` inside the stage's
combined `5aa10f5..747e3fd`, run against `notes/REVIEW_PROMPT.md`
with the round-1 findings + adjudication + fix-pass record as the
anchor and zero fix-session context. Every fix's code and pins read
in full, with the surrounding files the mechanisms ride through
(`MobileEditorTextView`'s reservation/heal section whole, both
chrome controllers whole, the settings/shell views whole, the perf
suite's constants and assertions, `MobileTutorialSeeder.findOrSeed`,
the `storageDidEdit` road). **Both FIX-B1 behavioral reverts were
re-executed by this reviewer's own hand** (transient source edits,
restored to `f2c7a3e` exactly; tree verified clean after). One
Sonnet lookup spent, per the standing exception, on Apple's
`fixAttributes` documentation — the impossibility claim's external
fact.

### Verdicts on the round-1 dispositions

- **FIX-B1 (the reservation-style leak, both roads) — HOLD.** The
  shared `setReservation` walk (mutate-first / heal-rest) and the
  edit-scoped `healReservationResidue` twins read correct, and the
  per-road revert discipline REPRODUCES exactly as recorded: revert
  A (the walk's continuation heal disabled) → ONLY pin (a) red, the
  continuation paragraph reading precisely the traced 30.0, 12
  siblings green; revert B (the chrome's residue-heal call disabled)
  → ONLY pin (b) red at 30.0, 12 siblings green; the restored tree
  green. Clean per-road discrimination, empirically re-verified.
  Free consequence verified in code: fan-death cleanup
  (`setTailReservation(0, …)`) now rides the same walk, so round
  1's cleanup-only-clears-the-first-paragraph gap healed too.
- **FIX-B2 (single-build + the RENAME road) — HOLD.** The one
  `refreshChrome` door builds `blockRangesByID()` once and hands it
  to both controllers; all six `MobileEditorViewModel` refresh call
  sites route through that door (the solo peek/pill roads are
  genuinely single-controller events — the defaulted self-build is
  not a double-build). The rename is honest by this reviewer's own
  measurement: keystroke ratios **9.41× / 10.08×** at 6.535/7.000 ms
  — the 12 ms floor binds; scroll **3.14×** at 1.474 ms — the 4 ms
  floor binds (and in this run `control×3 = 1.41 < big = 1.47`, so
  the ratio term alone would have failed marginally — the floor IS
  the protecting bound, exactly what the new names claim); the
  corpus-open pin's kept flatness name binds through its ratio
  (**0.99×** measured, `control×3 ≈ 69 ms ≫ the 30 ms floor`). The
  assertion shape is byte-identical (`big ≤ max(control × factor,
  floor)`), the ratio prints every run, and the self-arming note is
  accurate. The ~5 ms bare-TK2 premise is anchored in the pre-fix
  B3 record (this plan, the PB3-1 derivation), not invented at the
  fix.
- **FIX-B3 (narration flips) — HOLD.** All flips read;
  assertions byte-untouched confirmed against the diff. This
  reviewer's own sweep of every `exclusion` reference across mobile
  sources AND tests: all survivors are historical narration ("since
  parity B3", FB2-1's mechanism records) or live GUARD pins
  (`exclusionPaths.isEmpty`) — zero comments still claim the
  retired mechanism is the live one.
- **FIX-B4 (the pocket-guide door) — HOLD.** The open door is one
  call into the tested `findOrSeed` seam (the seam read in full:
  exists → bookID immediately, residue → confirm → restore, the
  MAJOR-A same-`Existing` discipline internal to it), and the
  navigation closure is sound: `onSettings` is wired ONLY at the
  shelf root (`MobileShelfView`), so whenever the closure fires the
  shelf tab is necessarily the visible one and the `shelfPath` push
  lands on the visible stack from its root — the deliberately
  unwritten tab value is correct, not an omission. The restore
  door's distinct always-replace grammar on `discover`/`restore`
  intact. The compiled-out claim re-verified by this reviewer's own
  Release build: **BUILD SUCCEEDED**.
- **FIX-B5 (the continuation cancel) — HOLD.** Double-resume is
  impossible by construction as claimed: both alert buttons
  resume-then-nil, the teardown checks nil first, all on the
  MainActor. The one adjacent presentation road checked — the spike
  `fullScreenCover`, whose presentation WOULD fire the sheet root's
  `onDisappear` — cannot race the continuation: while the confirm
  is pending the alert's modality blocks every other door, so the
  teardown decline is the only extra resolver, and it releases the
  latch through the awaiting door's own refusal arm.

### The FIX-B1 impossibility claim — reads TRUE

The record's claim (the separator cannot be kept clean; attribute
FIXING re-propagates the governing paragraph style across the whole
paragraph, terminator included; therefore the reviewer's proposed
write-exclusion shape is impossible and heal-the-landing is the only
road) is **documented platform behavior**, not a probe artifact.
Apple's `fixParagraphStyleAttribute(in:)` / `fixAttributes(in:)`
documentation, verbatim: it *"assigns the first paragraph style
attribute value in each paragraph to all characters of the
paragraph"*, with the range *"extended as needed to cover the last
paragraph partially contained"* and the paragraph delimited by
CR/LF/U+2029 — and `NSTextStorage.processEditing()` *"fixes
attributes"* automatically after every edit. A write clamped to
exclude the terminator is therefore re-fixed back to the governing
style — exactly what the fix session's deleted probe measured and
what the recorded pin-(b)-v1-stayed-red-under-the-clamp experiment
showed in-suite. One honesty note, no severity: on the live surface
the separator carries the style through TWO mechanisms at once (the
shipped walk deliberately writes the whole paragraph range, AND
fixing would re-propagate regardless); pin (b)'s probe-liveness
guard pins the feed, the documentation pins the impossibility.

### New findings

**MINOR R2-1 · `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift:420–449` (`setReservation`) — the road-(a) walk makes the band-independent reservation verify O(fanned-block bytes) per pass — on every scroll tick — and the residual is unrecorded.**
Mechanism: pre-fix, the verify read ONE governing character per
fanned block per pass (one `paragraphRange` scan of the FIRST
paragraph); post-fix, `setReservation` walks EVERY paragraph of
every fanned block on every pass — and the reservation walk runs
band-independent on all three scopes, including the per-scroll-tick
`.nearViewport` — with each `getParagraphStart` scanning its
paragraph's text. Per-tick cost: O(total bytes of all fanned
blocks), where it was O(their first paragraphs). Identical for
single-paragraph fanned blocks (the common case — the loop exits
after one iteration); the delta exists exactly for MULTI-paragraph
fanned blocks, and the mobile-real shape *journal `one_block` entry
+ a take* is precisely a large multi-paragraph fanned block whose
whole text is re-scanned per tick (a 100k one-block fanned post ≈
~1 ms/tick of pure verify). Invisible to the perf pins by fixture
shape: the mega post's ~33 fanned blocks (fanStride 41) carry small
paragraph counts, so the post-fix scroll step measured DOWN
(1.47–1.56 ms). No bar violation today — this is the round-1
MINOR-2 recorded-residual class, recorded so the next scale jump
doesn't rediscover it. Proposed shape (the adjudication's to
weigh): keep the governing-character verify band-independent, but
run the continuation-heal half only on `.edit`/`.document` passes —
a strand is only ever BORN by an edit, and every
materialization/voice re-base arrives with its own `.document`
refresh, so tick-cadence continuation scans add no heal occasion.
Labeled honestly: a perf-mechanism finding, pinnable only as a
measured budget on a multi-paragraph-fanned fixture — not
red-on-old bug-class.

**NIT R2-2 · `MobileEditorTextView.swift:451–460` (doc) vs `:484–509` — `healReservationResidue`'s comment misstates its covered set.**
The comment says "every paragraph beginning in `range`"; the
implementation also processes the paragraph that merely CONTAINS
`range.location` (the first `getParagraphStart` returns
`pStart ≤ range.location`). The broader sweep is correct and
harmless — paragraph-granularity superset, governed starts protect
live reservations — so the comment is the FIX-B3 narration class:
one line.

**NIT R2-3 · `MobileEditorTextView.swift:191–197` — `refreshChrome` pays the O(entries) index build before any controller guard.**
Pre-fix the build sat behind each controller's
`bounds.width > 0` / `refreshing` guards; post-fix the door builds
unconditionally, so pre-layout events (`installTakes`' own
`refreshChrome()` at `:164`, always; any refresh before first
layout) pay a wasted O(entries) walk both controllers then discard.
Setup-only in practice, steady state unaffected; hoisting a
width/latch check into the door (or building lazily) restores the
strictness.

No BLOCKER/MAJOR — round 3 does not open.

### Clean bill (load-bearing things specifically checked and found solid)

- **Scope, own check:** `git diff --name-only 42d7392..747e3fd` =
  seven mobile files + this plan file; zero `Sources/VariorumCore/`,
  zero `App/Variorum/Shared/`, zero Mac-side, zero schema, zero
  `Sync/`. Core/Mac/Mac-spine deliberately not run (the standing
  only-if-shared condition).
- **Counts, own runs** (below): full mobile 227/36 zero known
  issues; pin arithmetic exact (225 ladder-open + FIX-B1's two).
- **Both born-red claims re-verified empirically** by the per-road
  reverts above — each pin fails on exactly its own road's absence,
  at exactly the traced value, with all siblings green.
- **No third writer to clobber:** grep over mobile sources — no
  paragraph-indent (`tailIndent`/`firstLineHeadIndent`/`headIndent`)
  writer exists outside the two reservation doors + heals;
  `MarkdownFace` writes no `paragraphStyle`; the voice re-base
  writes `baseParagraphStyle` then re-runs the document chrome pass.
  The heals cannot zero a style any other subsystem owns.
- **The governed-start skip sets are exactly each walk's own seen
  set** (chrome `seen`→tail, decor `emojiSeen`→leading —
  byte-mirrored twins), and the two doors' disjoint fields keep a
  both-fanned-and-callout block composed under both heals.
- **Typing/crystallization traced through the heal:** the
  completing keystroke's own `.edit` pass covers the landing at
  paragraph granularity (the heal expands to paragraph bounds);
  per-keystroke healing means dents never accumulate across
  paragraphs; `typingAttributes` re-derive clean from the healed
  character at the next selection change, so steady state returns
  to write-free after one heal write; paste lands its whole range
  in the edited range (all its paragraphs healed); a mid-paragraph
  landing is self-fixing (the paragraph's clean governor wins the
  fix); deletion joining a dented tail into a governed paragraph
  re-mutates to truth via the walk.
- **The write-free steady state survives the heals** — every heal
  is equality-gated; the B3 mechanism pin
  (`aKeystrokesChromePassIsEditScopedAndWriteFreeWhenNothingMoved`)
  green in this reviewer's full run.
- **The `.edit` road routes through the ONE door** at all six VM
  call sites (`:348/:428/:537/:562/:802` `.document`, `:915`
  `.edit`); `layoutSubviews` → `.nearViewport` through the same
  door — the FIX-B2 single-build covers every double-build site.
- **The FIX-B2 measurement premise** (bare TK2 ~5 ms per edit at
  1,370 paragraphs) is anchored in the pre-fix B3 record; the
  corpus-open pin's kept flatness name binds through its ratio by
  this reviewer's own 0.99× measurement.
- **Release posture:** Release build SUCCEEDED with the DEBUG doors
  compiled out (own run); the `#if DEBUG` split in
  `MobileShellView.settingsSheet` is compile-time coherent in both
  configurations.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator)

- Full mobile suite: **"Test run with 227 tests in 36 suites passed
  after 18.185 seconds"** — exit 0, zero known issues, zero
  failures.
- The spine by its seven type names: **"Test run with 32 tests in 7
  suites passed after 3.643 seconds"** — TEST SUCCEEDED.
- Perf suites standalone: **"Test run with 9 tests in 2 suites
  passed after 9.795 seconds"**; PERF lines: open(100k) 443.5 ms ·
  keystroke 6.535/7.000 ms (ratios 9.41×/10.08×) · scroll step
  1.474 ms (3.14×) · corpus-open 0.99× · walk delta 41 MiB against
  the armed 250.
- Revert runs (chrome suite, 13 tests): revert A → exactly 1
  failure (pin (a), 30.0); revert B → exactly 1 failure (pin (b),
  30.0); both edits restored via `git checkout`, tree verified
  clean at `f2c7a3e`.
- Release build (`-configuration Release`, simulator destination):
  **BUILD SUCCEEDED**.
- Core / Mac / Mac-spine: not run — zero shared lines in the fix
  set (the standing only-if-shared condition).

## Stage B ladder — round 2 ADJUDICATED; THE LADDER CLOSES · STAGE B CLOSED (architect, 2026-08-09)

**Round-2 verdicts:** all five fixes HOLD (both FIX-B1 reverts
re-executed by the reviewer's own hand; the impossibility claim
verified against Apple's own `fixParagraphStyleAttribute` wording);
no new BLOCKER/MAJOR — **the ladder closes at round 2.** The three
leftovers, dispositioned and DONE at the architect's hand this
commit (the `cad3312` post-close precedent), mobile re-run
**227/36 green** by the architect's own hand after:

- **MINOR R2-1 → FIXED:** the continuation-heal half of the
  reservation walk now rides the `.edit`/`.document` roads ONLY
  (strands are only born by edits — the reviewer's own proposed
  shape); a scroll tick pays O(first paragraph) per decorated block,
  never O(block bytes). Both chrome callers pass the road's shape;
  the flag defaults to the healing shape so no future caller can
  accidentally opt out.
- **NIT R2-2 → FIXED:** the road-(b) heal doc now says what the code
  does (paragraphs the range TOUCHES, containing-paragraph
  included).
- **NIT R2-3 → FIXED:** `refreshChrome` guards `bounds.width > 0`
  before building the O(entries) index — pre-layout events pay
  nothing; the first real layout escalates to a full pass by the
  standing width-change rule.

**STAGE B CLOSED.** Shipped: **the pocket guide** (5 chapters / 13
lessons, phone-authored, seeded through a DEBUG door; every shipped
capability exercised) · **the spine** (seven suite type names, 32/7,
riding the baseline suite) · **the proving ground** (100,025 words /
1,370 blocks + a 300-note corpus, deterministic) · **the measurement
walk** (flatness + floor pins, the armed 250 MiB ceiling) · **the
FB2-1 fix** — her bar's executable form now HOLDS on the simulator:
keystroke 551→6 ms · scroll 48→1.7 ms · walk delta 5,842→43 MiB ·
100k open 902→433 ms · the suite itself 2.5 min→18 s — plus the
reservation mechanism replacing exclusion paths outright, and the
FIX-B1 heal roads. **Two TK2 discoveries folded into
`notes/TEXTKIT2_NOTES.md` §3 as dated, pinned findings** (exclusion
presence ⇒ document-scale relayout; attribute fixing re-propagates
governing paragraph styles). **Final counts:** mobile **227/36
zero known issues** · spine **32/7** · perf **9/2** · core 1214/128
· Mac 1245/219 tripwire-only · spine-Mac 51/7. **End-bundle adds
from B:** PB1-1/PB1-2/PB1-3 (guide placement/names/prose) · PB2-1 ·
PB2-3 (fixture constants) · PB3-1's derived 12 ms floor (recorded
for her transparency, not a decision) — PB1-4 rides Stage C's
refusal family with the lesson-update rider; PB2-2 RESOLVED (the
armed ceiling). **CURRENT STAGE → C.**

---

## STAGE C — KICKOFF (2026-08-09, in-chain per her ruling)

**Boundary duties executed:** `main` unmoved (`0ded142`). Ledger
re-sweep: 14c still mid-phase — nothing to absorb; PL-1…PL-4/PL-7
unchanged. Baselines carried from B's close: **mobile 227/36 zero
known issues · spine 32/7 · perf 9/2 · core 1214/128 · Mac 1245/219
tripwire-only · spine-Mac 51/7.** The install hold stands.

**The ladder interpretation for this stage (recorded as a process
PROVISIONAL — the stage table's gate column says "Per-family ladder
rounds" where the standing shape is one stage-end ladder):** each
BUILD batch groups 1–3 families and gets its OWN ladder (round 1 →
fixes → round 2; new BLOCKER/MAJOR ⇒ round 3; cap three) — family
granularity at batch cadence, honoring the table's words without a
nine-ladder explosion. The audit batch (C1) produces a record, not a
diff, and is reviewed by the architect directly rather than laddered.

**Stage C structure:**

- **C1 — THE PARITY MATRIX (the audit batch; record-only):** walk the
  Mac capability registry (P-1) AND the Mac's feature surfaces beyond
  it against the phone; produce the matrix — every capability × phone
  status (already-parity / owed / compromised-shape /
  not-owed-per-ruling), EVERY row citing its ruling (the exclusions
  list, the gate record, MobileSoul §4, LK5's expansion) — plus a
  proposed family-batch ordering with per-family scope lines. The
  architect reviews and orders C2+ from it.
- **C2+ — the family batches, matrix-ordered** (briefs written per
  batch from the matrix): books & membership (incl. LK5's expansion —
  the BOOK DETAILS surface off contents, finish/unfinish, tag editing
  there, smart-book creation FROM tags) · tags (browse, apply,
  create; tag posts; leaf-chip grammar) · locks (take lock/unlock
  joins the note seal) · references ("More info": see, add, open) ·
  scraps (view, maybe add) · comments/callouts gaps · lenses
  (compromised shape — her top-bar sketch; design at the batch) ·
  the S5 conflict surface (a conflict variant DISCOVERABLE on the
  phone; the takes badge its natural face; verify + pin) · the
  refusal-copy sweep (every "on the Mac" string dissolves or names
  its sanctioned exception — the merge ceremony refusal included,
  with PB1-4's lesson-update rider). The spine green every batch.

## Stage C, batch C1 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at the Stage C kickoff commit. **This batch
writes NO app code** — its deliverable is the PARITY MATRIX section
appended to THIS file (plus the batch record). Read-only over the
code; write-only into the plan.

**Read first, IN FULL, in this order:** `CLAUDE.md` ·
`notes/MobileSoul.md` (§4's decision grammar is the matrix's verdict
vocabulary; §6's ledger protocol) · THIS plan file top to bottom (the
mandate's exclusions; the Stage A/B closeouts — what already shipped;
PB1-4) · `notes/plans/mobile-app-plan.md`'s GATE SITTING record
(~5716–end: the parity ruling, see-your-data, no-redirect, the
exclusions verbatim, LK5's expansion ruling, the P-round
dispositions) · the Mac capability REGISTRY IN CODE (locate the
`Registry/` layer under `App/Variorum/` — every declared act: verb,
scope, doors, refusal copy) · the Mac's feature surfaces BEYOND the
registry (the P-1 scope note: the registry covers the routed
vocabulary — walk `App/Variorum/Features/` for surface-local
capabilities: books/shelf faces, tags, locks, references, scraps,
comments, lenses, search, settings) · the MOBILE app's shipped
surfaces (`App/Variorum/VariorumMobile/`) so "already-parity" rows
are grounded in code, not memory.

**The deliverable — append to THIS file as "## THE PARITY MATRIX
(C1, 2026-08-09)":**

1. **The matrix:** one row per capability, columns: capability ·
   where it lives on the Mac (registry act or surface:file) · phone
   status — **already-parity** (cite the mobile code/tests) · **owed**
   (full-shape) · **owed-compromised** (shape changes, capability
   survives — name the intended shape in one line) ·
   **not-owed-per-ruling** (cite the exclusion's words) — · and the
   RULING CITATION for every non-already row. Group rows by family.
2. **Gaps the registry can't see:** anything her rulings owe that no
   Mac registry act names (the LK5 expansion's smart-book-from-tags;
   the S5 conflict discoverability check) gets its own row with the
   ruling cited.
3. **The proposed batch ordering:** group the owed families into 3–4
   build batches with one-line scope + risk notes each (which need
   in-batch design forks, which are mechanical), and name anything
   that looks core/Shared-touching so the architect can plan the
   four-suite duty.
4. **A refusal-copy inventory:** every user-facing string in the
   mobile app that names the Mac (grep-grounded, file:line), each
   marked dissolve / sanctioned-exception-candidate (the ceremony
   class), for the sweep batch.

**Discipline:** verdicts use the soul document's grammar and cite
rulings — where a capability's status is genuinely unruled, mark it
**OPEN-FOR-HER** with a one-line question (these collect into the end
bundle; do NOT guess product behavior). Commit the matrix + batch
record with the standing trailer; push `origin mobile`. Your final
reply to me is compact: row counts per status, the proposed batch
ordering, the OPEN-FOR-HER list, commit hash.

## THE PARITY MATRIX (C1, 2026-08-09)

**Method:** the Mac capability registry read in full
(`App/Variorum/Variorum/Registry/CapabilityRegistry.swift` — all 71
declared `CapabilityID`s — plus `Capability.swift`'s model), then the
Mac's feature surfaces BEYOND it walked in code (shelf book menu ·
book navigator/structure · membership chip · library note menu ·
recovery · tags manager + chips · references panel · pool/scraps ·
lenses board · commit bar incl. the date + history faces · settings
panes), then every shipped MOBILE surface read so already-parity rows
cite code, not memory. Verdicts use the soul document §4's grammar;
every non-already row carries its ruling. **Citation key:** [PARITY]
= the parity ruling (gate record, CoreDescription pillar 8's second
supersession) · [SEE] = see-your-data · [NORED] = no-redirect ·
[EXCL] = the exclusions verbatim · [LK5+] = LK5's expansion ruling
(the P-round block: *"finishing / unfinishing should be a v1 phone
capability… book details from the contents… change tags there too…
create books based on tags and tag posts — again, full app
functionality"*) · [FUT] = the FUTURE LIST · [WKRD] = her merge
workaround doctrine (*"there is probably a workaround there the same
way I chose a workaround for divide"*) · [PL-n] = parity-ledger rows
· [P-n] = P-round dispositions · [B1] = the Stage B pocket-guide
record. Registry rows the registry could NOT see are marked ◆
(deliverable 2's class).

### Family: writing & blocks

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Divide (single-take, in-place) | registry `.divide`; EditorViewModel | **already** — `MobileStructural.divide` (plain `ops.divide`); pins `MobileStructuralTests`, spine structure walk | — |
| Divide (fanned — the duplicate shape) | core `divideDuplicating` (A2); Mac door stays W-ceremony until 13j | **already** — `MobileStructural.swift:149` (displayed/peek-aware take, snapped cut); pins `divideOnAFannedBlockLandsTheDuplicateShape`, `divideOnAPeekedBlockCutsThePeekedTake`, the ferry walk | Q-M2 (hers) |
| Merge (instant, fanless) | registry `.merge` | **already** — `MobileStructural.mergeWithPrevious`; single-space round-trip pinned in the structure walk | — |
| Merge with a fan on either side | Mac: the pairing ceremony (S4-23) | **owed-compromised** — today refuses to the Mac ceremony (`MobileStructural.swift:238`); the intended shape is a SIMPLER phone default designed at the batch (candidates: archive-extras-then-merge named as the road · a carry-all merge mirroring Q-M2's duplicate logic) — ceremonies themselves stay unreplicated | [WKRD] + [EXCL] (ceremonies) + [NORED]'s "SOMEHOW" |
| Extract | registry `.extract` (⌘⇧E) | **OPEN-FOR-HER** — unruled; the phone has selection, so a selection-menu act is cheap. *Q: should extract (and make-block) cross to the phone's selection menu, or stay Mac gestures?* | — |
| Make Block from Selection | registry `.makeBlock` | **OPEN-FOR-HER** — same question as extract | — |
| Delete in Every Take | registry `.deleteInEveryTake` | **OPEN-FOR-HER** — unruled takes-editing convenience. *Q: wanted on the phone, or Mac-only?* | — |
| New block at end | registry `.addBlockAtEnd` | **already** — the open tail + type-past crystallization (`MobileEditorViewModel.crystallizeIfNeeded`; crystallize walk, `typeEdit` road) | — |
| New Block Below (mid-note) | registry `.insertBlockBelow` (⌘⇧⏎) | **owed** — no phone door; mechanical (a ⋯-menu row over the standing op); the awkward road today is type-into-next-then-divide | [PARITY] |
| Delete block | registry `.deleteBlock` | **already** — ⋯ menu + confirm (`MobileBlockMenu.confirmDelete` → the structural contract, S4 MAJOR-1); pins in `MobileBlockMenuTests` | — (confirm copy → inventory #2) |
| Structural undo / redo | registry `.structuralUndo`/`.structuralRedo` | **not-owed-now** — the recorded deliberate absence; her P40 disposition kept the delete confirm *"while the phone lacks structural undo"*, accepting the v1 state | [P40] |
| Find in note (5 acts) | registry `.findInPost` family (⌘F…) | **owed** — no phone find; her L6 grievance ("reaching for that and not having it") is platform-neutral; shape: iOS's own find interaction on the Write surface (TEXTKIT2 §3 care) | [PARITY] |
| Formatting: bold · italic · heading (+picker) · bullet · checklist · indent · outdent | registry `formatBold`…`formatOutdent` | **already** — the Aa strip + long-press pickers (`MobileKeyboardBar`, `MobileMarkdownActs`); pins `MobileMarkdownTests` | — |
| Formatting: strikethrough · inline code · add link | registry `.formatStrikethrough`/`.formatCode`/`.formatAddLink` | **owed** — doors absent from the Aa strip/menus; the raw-syntax road already works (F-1 dual-mode's first face; code tint + tappable links render), so this is mechanical door-completion of her "all the formatting options" | [PARITY] + her Aa ruling's letter |
| Commit (deliberate savepoint) + history view + restore | registry `.commitTake` (⌘S); `CommitBar` history list + Restore | **owed** — NO commit door and NO history surface on the phone (grep-verified: every mobile "commit" match is a comment); core `Queries.commitHistory` + `restoreCommit` exist; shape at the batch (a note/block-level act + a see-your-data history list; §9's predates-a-split warn rides restore). Idle auto-commit machinery ALREADY runs (shared `AppServices.idleCommits`) | [PARITY] + pillar 2 + [SEE] |
| Editing-look settings (seams toggle, editing indicator, inline comments, hover handles, long-block layout, paragraph gap, spellcheck) | registry `.toggleSeams`; `AppSettingsView` | **not-owed** — each setting's own shipped copy says "This Mac only"; the phone's look is the LK canon's | the settings' own per-machine design |
| Caret/keyboard ergonomics (previous/next block, mode keys, open-notes keys, back/forward) | registry `.previousBlock`/`.nextBlock`/`.switchMode`/`.openNote`/`.navigateBack`/`.navigateForward` | **not-owed** — moot on touch: tap places the caret, the system back gesture is the road, the phone has no mode row | [EXCL]'s workspace distinction ("workflow and editor options, not a fundamentally different capability") |

### Family: takes

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Show takes (badge → browser) | registry `.showTakes` | **already** — the ⑂ badge + bar ⑂ + edit-menu Takes… (`MobileTakesChrome`, `MobileTakesBrowser.open` — the single-take block opens too, the fan-birth door); pins `MobileTakesBrowserTests`, takes walks | — |
| Branch (new take from shown) | registry `.newTake` | **already** — "Branch this one ⧉" (`branchDisplayed`, flush-first + Q-M1(a) seed-from-shown-bytes pinned) | — |
| Blank take | registry `.blankTake` | **already** — "Blank ○" (`newBlank`; minting never chooses, R90 pinned) | — |
| Blank take as chosen | registry `.blankTakeAsChosen` (⇧⌥⌘T) | **already (composition)** — blank + ✓, two taps; no dedicated door owed (the power-chord is Mac keyboard vocabulary) | — |
| Choose | registry `.chooseTake` | **already** — the pill ✓ and the browser card ✓ (`chooseDisplayed`/`choose`; M6's only-deciding-act pinned) | — |
| Step previous/next | registry `.previousTake`/`.nextTake` | **already** — the swipe flip IS the step (M5; `MobileTakesController.flip`, peek pins) | — |
| Archive take | registry `.archiveTake` | **already** — card ⋯ (`MobileTakesBrowser.archive`) | — |
| Delete take | Mac: card menus (op `deleteVariant`) | **already** — card ⋯ (`delete`; I10 + chosen-slot refusals pinned with phone copy) | — |
| Unarchive + the archived listing | registry `.unarchiveTake` (surface door on the archived card) | **owed** — the browser shows the LIVE fan only; "recovery surfaces stay Mac-side in v1" was a recorded v1 absence, and archived takes are her information (`Queries.blockFan` already returns them). Dissolves inventory #14 | [SEE] + [PARITY] |
| Label take | registry `.labelTake` | **owed** — cards DISPLAY labels (`Card.label`) but no set-door exists; mechanical (a card-⋯ row over `setTakeLabel`) | [PARITY] |
| Take lock/unlock | Mac: op `lockVariant`/`unlockVariant` (faces on cards) | **owed** — the C-kickoff locks family ("take lock/unlock joins the note seal"); dissolves the six locked-take redirects (inventory #1,3,6,11–13) | [PARITY] + [NORED]; A1's boundary note routed it here |
| Diverge here (branch a specific thread) | registry `.divergeHere` | **already (composition)** — peek/flip to the take, then branch (branch copies the DISPLAYED take) | — |
| Diff against chosen | registry `.diffAgainstChosen` | **OPEN-FOR-HER** — unruled; Compare is excluded but a one-column two-take diff is legible on a phone. *Q: is a read-only take-diff wanted, or does swipe-compare suffice?* | — |
| Close-all / page fan | registry `.closeAllTakes`/`.pageFanBack`/`.pageFanForward` | **not-owed** — board-geometry acts with no phone referent (the browser scrolls; a peek ends by ✓ or flip-back) | [EXCL]'s workspace distinction |
| Reorder takes · move-take-into-block · copy-all-takes · takes-aware find/replace | 13e's ruled additions (not yet on the Mac either) | **not-owed-YET** — adopt after the Mac lands them | [PL-1] |

### Family: comments & callouts

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Comments CRUD + deleted-visible + restore | registry `.blockComments`; `CommentsPanel` | **already** — the comments sheet (`MobileComments`/`MobileCommentsSheetView`: add, edit, delete, deleted section, restore — never-skimpy ported); ●n mark + P38 corner pinned (`MobileTakesChromeTests`); travel is core's | — |
| Callout frames (toggle · five colors · emoji · remove) | registry `.callout`; `CalloutMenu` | **already** — the ⋯ Callout submenu (`MobileBlockMenu.calloutSubmenu`, `MobileCallout` mirroring the one transform + token names); pins `MobileBlockMenuTests` | — |
| The "gaps" audit (the C-kickoff family's question) | — | **CLOSED, no owed gap found**: the inline-tinted display setting is the Mac-local class ("This Mac only"); the margin-hover grammar and emoji PICKER are 13e candidates on BOTH platforms [PL-1]; Read renders calm prose exactly as the Mac's reading flow does | — |

### Family: books & membership ◆ (largely registry-blind — the shelf/chip/navigator vocabulary)

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Open book → contents → Read; chapters honored | Mac book view/navigator | **already** — P35 contents-first (`MobileBookView` + `readDoorTitle` pin), Read flow with chapter captions + page meta (`MobileReadView`/`MobileReadPage`); library walks | — |
| Create book (curated · smart · journal) ◆ | ShelfView "+ New Book" alert (3 kinds) | **owed** — her feel-round finding named it ("create a new book"); ops standing (`createReading`) | her finding #2 + [LK5+] |
| Smart-book creation FROM tags ◆ | Settings tag manager "Promote to Book…" + shelf Create Smart Book | **owed** — the LK5 expansion names it verbatim | [LK5+] |
| BOOK DETAILS surface off contents: finish/unfinish ◆ | shelf menu Finish/Reopen | **owed** — "finishing / unfinishing should be a v1 phone capability — there should be some way to get to book details from the contents of a book"; dissolves inventory #8 | [LK5+] |
| Tag editing on book details ◆ | shelf tags column + manage | **owed** — "you can change tags there too" | [LK5+] |
| Rename book ◆ | shelf menu Rename… | **owed** — rides the book-details surface; basic metadata under "full app functionality" | [LK5+]/[PARITY] |
| Membership: see/add/move/remove a note between books ◆ | `MembershipChip` (R61/R67 add door) + Manage Notes… | **owed** — "the ability to move something between books"; the chip is the natural phone shape (masthead-adjacent) | her finding #2 + [PARITY] |
| Diverge for this book | registry `.divergeForBook` (chip row door, W23) | **owed** — rides the chip's phone shape; flush-first (R1-4) binds | [PARITY]; shape at the batch |
| Pin/unpin book ◆ | shelf menu Pin/Unpin | **owed** — the phone RENDERS pin order (`MobileShelfFaces.ordered`); the ACT was explicitly left to "Stage C's books family" | [B1]'s record + [PARITY] |
| Daily-journal designation road ◆ | shelf menu "Use as Daily Journal" | **owed** — a road must exist for the Today door's smart/finished-book refusals to stop redirecting (inventory #8–10); shape at the batch (likely a book-details row) | [NORED] |
| Chapter CRUD · in-book reorder · book sort · smart-filter editing · smart→curated conversion ◆ | book navigator + shelf menus | **OPEN-FOR-HER** — the LK5 expansion named details/tags/creation, not structure management. *Q: how much book STRUCTURE management crosses in v1 — chapters, reorder, sort, filter edits, conversion — vs. staying the Mac's desk work?* | — |
| Extent faces (book word target / max posts; post word target) | shelf Length & Extent…; `WordTargetFace` | **not-owed-now** — LK5 ranked word progress behind the phone's faces; "v1 ships without it (recorded)"; revisitable at her look round | LK5's recorded ranking |
| Book/post/block export; library export; import | shelf + library menus; registry `.exportLibrary`/`.importFiles`/`.exportCaretBlock` | **not-owed-per-ruling** — the download-link direction ("easier to eventually provide users with a link"); share-sheet is the future export grammar; "definitely no bulk import on an iphone" | [FUT] |

### Family: notes (metadata & lifecycle)

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| New note · Today's entry (+ daily shelving) | registry `.newPost`/`.todaysEntry` | **already** — the twin + new note doors (P33, `MobileNewNoteDoor` pin) and the Today button (`MobileTodayDoor` — create-or-open + `shelveInDailyJournalBook`, outcomes worded) | — |
| Note seal (lock/unlock) | registry `.sealPost` | **already** — the masthead door + state line (A1; `MobileNoteSealTests`, flush-guard revert-verified) | — |
| Rename note ◆ | library Rename… | **owed** — no phone door on stored titles; basic metadata | [PARITY] ("full app functionality") |
| Entry date set/clear ◆ | `CommitBar` date face (`setEntryDate`) | **OPEN-FOR-HER** — unruled. *Q: should the phone re-date a note (journal sorting), or is dating Mac-side curation?* | — |
| Archive/delete/restore note · tray · unplaced blocks · origin door | library rows, `RecoveryView`, registry `.showOriginBlock` | **owed — LEDGER-ROUTED to PL-3 (13j)**: deletion/Trash/restoration doors are 13j's one design (her gate ruling #7 widened it: "restoration of archived/deleted things generally — where the doors live"); the phone's half lands at least see-your-data when 13j runs. Consciously deferred — the Stage E gate reads this row | [PL-3] + gate ruling #7 |
| Duplicate as Version · version links | library/pool rows; `.versionOf` doors | **OPEN-FOR-HER** — unruled (Compare excluded; diverge-for-book rides the chip). *Q: does duplicate-as-version cross, or wait for a use she feels?* | — |

### Family: tags ◆

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Browse the taxonomy | Settings tag manager; `TagsViewModel` | **owed** — the C family's "browse"; leaf-chip grammar (13k K3) binds display, already applied on shelf faces (`MobileShelfFaces.leaf`) | [LK5+] |
| Create tags (+ hierarchy) | tag manager New Tag…/New Child Tag… | **owed** | [LK5+] ("full app functionality") |
| Apply/remove tags on posts | `NoteTagChips` (＋ chip) | **owed** — "tag posts" verbatim | [LK5+] |
| Tag rename / delete (management) | tag manager Rename…/Delete (with subtree) | **OPEN-FOR-HER** — the expansion named browse/apply/create. *Q: does tag MANAGEMENT (rename, delete-with-subtree, hierarchy edits) cross, or stay the Mac Settings' home (R52)?* | — |
| Block tags | registry `.tagBlock` (scrap rows/canvas) | **OPEN-FOR-HER** — her ruling named POSTS; block tags primarily serve the pool. *Q: does block-tagging ride the scraps surface, or stay Mac-side?* | — |

### Family: references ◆

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| See a note's references | `ReferencePanel` list | **owed** — the "More info"-style list, her words | her precision #3 + [SEE] |
| Add (URL) + open a reference | panel Add File…/URL; open | **owed** — "maybe add + open one"; URLs open; FILE rows list honestly by name (`file_bookmark` is LOCAL-ONLY per AppSpec §7 — a Mac file cannot open on the phone; the copy must say so without redirecting) | her precision #3 |
| Side-by-side reference panel | the Mac panel beside the draft | **not-owed-per-ruling** — "no side-by-side view ever" | [EXCL] |

### Family: scraps / Snippets & pool ◆

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Pool (bookless notes) | sidebar Pool (R29) | **already** — the Library's bookless filter (`MobileLibraryViewModel.startBookless`; loose-note walk) | — |
| View the scraps area | `ScrapsPanel`/`BlocksAreaView` | **owed** — "you should be able to view your pool of scraps if you want on mobile" | her precision #1 + [SEE] |
| Add to scraps | scrap minting doors | **owed-compromised** — her "and maybe add to it": the maybe is recorded; scope settles at the batch (a plain add-scrap door at most) | her precision #1 |
| Drag scraps into a note | the Mac drag door | **not-owed-per-ruling** — the exclusion verbatim ("it's hard to imagine how you would add items from there to a post / note on mobile") | [EXCL] |

### Family: lenses

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Lenses (save current · switch active · adopt; rename) | registry `.saveChoicesAsLens`/`.renameLens`; `LensesBoardView` | **owed-compromised** — her sketch IS the intended shape: "choose between lenses on the top bar and switch to a different active lens but can save the one you're in"; design at the batch (the multi-column board never crosses); core `LensQueries` + ops standing | her lens precision + [PARITY] |
| Lens dangling-pick honesty | Mac loud-fallback door = 13j's ruling | **rider on the lens batch** — the phone surface designs WITH `effectiveLensSelection`'s fallback visible (the Mac's loud door is 13j's; the phone must at least not lie) | gate ruling #7 |

### Family: search

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Find anything (catalog scope) | registry `.findAnything` (⌘K) | **already** — the Library search (`MobileLibraryViewModel.search` — `searchCatalog`, same scope; body-search-not-invented pinned in `MobileLibraryTests`) | — |
| Whole-library body search | the roadmap row (unrun) | **not-owed-YET** — the engine lands in core Queries with phone memory/P1 at the table | [PL-2] |
| Library sort choice | Mac library view modes (timeline etc.) | **OPEN-FOR-HER** — the phone lists newest-first only. *Q: is a sort picker (entry date · created · last touched) wanted on the phone Library?* | — |
| Timeline / folder view modes | Mac Library modes | **not-owed** — traversal coverage exists (Library + books + the owed tags family); view modes are Mac workflow surfaces | [EXCL]'s workspace distinction |

### Family: sync · account · E2EE

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Suite sign-in / account | shared `AuthViews`/`SyncStatusViews` | **already** — PL-5 shipped through the one seam (Account sheet off the sync row; the pre-Stage-A door fixes); live-phone verify rides the end bundle behind the install hold | [PL-5] |
| E2EE enroll/unlock/forget/recovery + snapshot cover | shared `EncryptionViews` | **already** — PL-6 CLOSED (her drill passed live; 0.16 s KDF; `MobileSnapshotPrivacyTests`) | [PL-6] |
| Sync status face | shared `SyncStatusRow` | **already** — Settings' sync section | — |
| S5 conflict discoverability ◆ | core: conflict-as-variant (label 'conflict') | **owed — VERIFY + PIN** (no code expected): a conflict variant landing on the phone must be DISCOVERABLE — the mechanism says it is (a conflict mints a take → the block is fanned → the ⑂ badge; the browser card shows the label) — the batch proves it end-to-end from a landed conflict row and pins it | the C-kickoff's named check; MobileSoul §5.3 (standing acceptance item) |
| Fragments bridge faces | Mac-hosted engine (paused until the 14c-end batch) | **not-owed** — the bridge is a Mac-side engine by design; its results flow to the phone via sync | the bridge's Mac-hosted architecture |

### Family: app-scope & misc

| Capability | Mac location | Phone status | Ruling |
|---|---|---|---|
| Voice switch | Mac Settings appearance | **already** — Settings' voice rows (`MobileVoiceTests`; open surfaces follow via `applyVoiceChange`) | — |
| Tutorial | registry `.restoreTutorial` | **already** — the pocket guide + DEBUG doors ([B1]; the PRODUCT door placement is PB1-1, hers at the end bundle) | — |
| Shortcuts & Dictionary helper | registry `.helper` (⌘/) | **not-owed** — a keyboard-dictionary has no touch referent; the app-vocabulary teaching lives in the pocket guide | moot-by-platform; [B1] |
| Quick note (summon-anywhere) | registry `.quickNote` + menu-bar extra | **not-owed-now** — the quick-capture widget is "W26's phone-shaped cousin", explicitly future | [FUT] |
| Stars | registry `.toggleStar` | **OPEN-FOR-HER** — unruled (pins cover books; stars span notes AND books). *Q: does the starred set cross to the phone shelf, and where?* | — |
| Workspace: splits · windows · open-notes list · note-only windows | registry `.openBeside`/`.closeSplit`/`.openInNewWindow` etc. | **not-owed-per-ruling** — workspace/windowing excluded | [EXCL] |
| Compare · open peer post · Outline · expand-all-fans | registry `.openPeerPost`; Compare board | **not-owed-per-ruling** | [EXCL] |
| Canvas / sticky-note editing · canvas bank | Canvas feature | **not-owed-per-ruling** | [EXCL] |
| Tag-chips fold (context bar) | registry `.toggleTagChips` | **not-owed** — Mac context-bar chrome; the phone's tag display shape is the tags batch's | [EXCL]'s workspace distinction |
| Block-TOC-style navigation + block-name display | Mac TOC view; names set via phone ⋯ but rendered nowhere | **OPEN-FOR-HER** — her own candidate ("the block-TOC-style list remains the phone-friendly navigation candidate"); block names' phone face was left as "Stage C's call" in [B1]. *Q: is an in-note block list (showing names) wanted for v1 navigation?* | — |

### Row counts per status

- **already-parity: 27** (composition-covered included)
- **owed (full shape): 23** — insertBlockBelow · find-in-note · strike/code/link doors · commit+history · unarchive+archived-listing · label take · take lock/unlock · create book · smart-book-from-tags · book details finish/unfinish · book tag editing · rename book · membership chip · diverge-for-book · pin/unpin · daily-designation road · rename note · tags browse · tag create · tag apply · references-see · references-add/open · scraps view · S5 verify+pin *(24 named — diverge-for-book rides the chip row's batch, counted with it)*
- **owed-compromised: 3** — fanned-merge workaround · lenses · scraps add
- **owed, ledger-routed (consciously deferred): 1** — deletion/restoration surfaces (PL-3/13j; delete-book included)
- **not-owed-per-ruling / moot: 19**
- **OPEN-FOR-HER: 11** (the list below)

### The OPEN-FOR-HER collection (for the chain's end bundle)

1. **Extract + Make Block on the phone** — selection acts; cheap via the selection menu. Cross, or Mac gestures?
2. **Delete in Every Take** — wanted on the phone?
3. **Diff against chosen** — a one-column take-diff is phone-legible; wanted, or does swipe-compare suffice?
4. **Book structure management** — chapter CRUD, in-book reorder, sort, smart-filter editing, smart→curated conversion: how much crosses in v1?
5. **Entry date set/clear on the phone** — re-date a note there?
6. **Duplicate as Version** — cross, or wait?
7. **Tag management** (rename/delete/hierarchy) — cross, or stay the Mac Settings' home (R52)?
8. **Block tags** — ride the scraps surface, or Mac-side?
9. **Library sort picker** — entry date / created / last touched on the phone Library?
10. **Stars** — does the starred set cross, and where does it live on the phone?
11. **Block-TOC navigation + block-name display** — an in-note block list for v1?

### The proposed build-batch ordering (C2–C5)

1. **C2 — books & membership (+ note metadata riders).** Create book (three kinds) · pin/unpin · the BOOK DETAILS surface off contents (finish/unfinish · tag editing · rename book · the daily-designation road) · smart-book-from-tags · the membership chip (see/add/move/remove; diverge-for-book's shape) · rename note · the Today-door rewords these doors unlock. *Risk:* the batch's one design fork is the book-details surface's shape (LK4's sheet grammar is the precedent); everything else is mechanical over standing ops (`createReading`, `addPostToReading`, `removePostFromReading`, the lock ops, `applyTag`). Possible small core `Queries` additions for detail aggregates — **four-suite duty if any core line lands**.
2. **C3 — the see-your-data trio: tags · references · scraps.** Tags browse/create/apply with leaf chips · the references "More info" list (see, add URL, open; file rows honest without redirecting) · scraps viewing (+ the maybe-add call). *Risk:* low, mostly mechanical; OPEN answers 7/8 may adjust scope mid-batch.
3. **C4 — takes completeness · locks · commit/history · editor fill.** Take lock/unlock · the archived listing + unarchive · label take · the commit door + history surface (restore with the §9 predates-a-split warn) · insert block below · strike/code/link doors · find-in-note · the S5 conflict verify+pin. *Risk:* the find interaction on TK2 (TEXTKIT2 §3 care); history-surface shape is design-lite; `blockFan`/`commitHistory` already exist in core — zero core expected.
4. **C5 — lenses (design-first) + THE REFUSAL-COPY SWEEP (last, by dependency).** The lens compromised shape (her top-bar sketch; a propose-first turn to the architect per the 4E pattern is warranted) · then the sweep: every inventory row below dissolves or names its sanctioned exception — the merge-ceremony wording gains its phone road, and **PB1-4's rider executes: the pocket guide's merge lesson + its walk pin update in the same batch**. *Risk:* the sweep depends on C2/C4 doors existing — hence last.

**Core/Shared expectations across all four:** zero `Sources/VariorumCore/Sync/`, zero schema (any need = a §12 lockstep STOP), zero `App/Variorum/Shared/` expected; the only anticipated core surface is small additive `Queries` reads (C2), which fire the four-suite duty. The spine (32/7) green every batch; the perf suites ride the full-suite runs.

### The refusal-copy inventory (grep-grounded: every user-facing mobile string naming the Mac)

| # | file:line | The string (abbrev.) | Disposition |
|---|---|---|---|
| 1 | `Features/Write/MobileEditorViewModel.swift:1358` | "This take is locked — branch it or unlock it on the Mac to edit." | **dissolve** at C4 (take unlock door: "…or unlock it" + the door) |
| 2 | `Features/Write/MobileBlockMenu.swift:219` | delete confirm: "The block waits in this note's deleted-blocks tray on the Mac." | **dissolve** (reword neutral — the tray fact without the redirect; the phone's recovery DOOR rides PL-3/13j) |
| 3 | `Features/Write/MobileStructural.swift:128` | locked take (same sentence as #1) | **dissolve** at C4 |
| 4 | `Features/Write/MobileStructural.swift:238-239` | "One of these blocks has other takes — pairing takes into a merge is the Mac's merge ceremony." | **sanctioned-exception-candidate** (her named merge exception) — but the sweep must add the phone ROAD per "SOMEHOW you should be able to get to the state you want" (the C5 workaround design or the archive-extras road named) |
| 5 | `Features/Write/MobileStructural.swift:292` | "Block deleted — it waits in this note's deleted-blocks tray on the Mac." | **dissolve** (neutral reword; door rides PL-3) |
| 6 | `Features/Write/MobileStructural.swift:340` | locked take (refusalMessage arm) | **dissolve** at C4 |
| 7 | `Features/Tutorial/MobileTutorialSeeder.swift:452` | the merge lesson teaches the ceremony refusal | **PB1-4's rider** — updates in the SAME batch as #4 (lesson + walk pin) |
| 8 | `Features/Shell/MobileTodayDoor.swift:57` | finished daily book: "…reopen it on the Mac." | **dissolve** at C2 (finish/unfinish lands) |
| 9 | `Features/Shell/MobileTodayDoor.swift:59` | full daily book: "…extend it on the Mac." | **dissolve-candidate** — extents are LK5-deferred, so the road is designate-another/unfinish; the C2/C5 wording names a phone road or the row becomes a flagged exception |
| 10 | `Features/Shell/MobileTodayDoor.swift:61` | smart daily book: "…pick a curated one on the Mac." | **dissolve** at C2 (the designation road) |
| 11 | `Features/Takes/MobileTakesBrowser.swift:286` | locked take (beginEditing) | **dissolve** at C4 |
| 12 | `Features/Takes/MobileTakesBrowser.swift:321` | locked take (card gate) | **dissolve** at C4 |
| 13 | `Features/Takes/MobileTakesBrowser.swift:405` | "That take is locked — unlock it on the Mac first." | **dissolve** at C4 |
| 14 | `Features/Takes/MobileTakesBrowser.swift:407` | "That take is archived — unarchive it on the Mac first." | **dissolve** at C4 (unarchive door) |
| 15 | `Spike/SpikeScenarios.swift:228` | DEBUG spike recorder note ("same as Mac spike") | **no action** — not user-facing (DEBUG diagnostics; recorded for grep-completeness) |

Copy-pin note for the sweep batch: several of these sentences are PINNED (the A1/A3 records name the kept locked-take copies as deliberate) — every dissolve is a sanctioned pin flip riding this matrix's rulings, recorded per flip.

## Stage C, batch C1 — BATCH RECORD (implementer, 2026-08-09)

**Method.** Read in the brief's order, in full: `CLAUDE.md` · `notes/MobileSoul.md` · THIS plan file top to bottom (A/B closeouts, PB1-4, the C kickoff) · the GATE SITTING record (`notes/plans/mobile-app-plan.md` ~5716–end). Then the code, read-only: the Mac Registry layer in full (`Capability.swift` + `CapabilityRegistry.swift` — 71 `CapabilityID`s; `OpsRefusalCopy`/`ShellActions` skimmed for door tables), the Mac feature surfaces beyond it (shelf/book/membership/library/recovery/tags/references/pool/lenses/settings/commit-bar/readings files walked by door extraction — `Button`/`Menu` sweeps plus header reads), and EVERY mobile feature file (Shell/Write/Takes/Read/Tutorial surfaced in full or by API walk; `MobileStructural`, `MobileBlockMenu`, `MobileTakesBrowser`, `MobileWriteView`, `MobileSettingsView`, shelf/library/book models read whole). Verdict-grounding greps: the `Mac`-string sweep (15 hits, all classified), the no-commit-door proof (zero non-comment `commit` references in mobile features), `blockFan`/`commitHistory` core availability, `IdleCommitScheduler` in shared `AppServices`.

**Coverage counts.** All 71 registry `CapabilityID`s dispositioned (grouped into matrix rows where a family shares one verdict); 20 registry-blind capabilities (◆) rowed from the Mac's surface-local vocabulary and her rulings (the LK5 expansion's four, the S5 check, the shelf/chip/tags/references/scraps families); statuses: **27 already · 23 owed · 3 owed-compromised · 1 owed-ledger-routed · 19 not-owed · 11 OPEN-FOR-HER**. Every non-already row carries its ruling citation; every already row cites mobile code and its pin suite.

**What I could not classify from code or record (hence OPEN):** the eleven OPEN-FOR-HER rows above — each is genuinely unruled (no gate-record sentence, no M/LK/P disposition, no exclusion covers it); none gates C2–C4's scope as ordered (OPEN answers 4/7/8 can adjust C2/C3 scope mid-chain if she answers early; the rest ride the end bundle).

**No app code written** (the brief's letter): the diff is this plan file only. No tests run (record-only batch; the ladder interpretation in the C kickoff routes C1 to architect review, not a ladder). Baselines stand as carried at the C kickoff: mobile 227/36 zero known issues · spine 32/7 · perf 9/2 · core 1214/128 · Mac 1245/219 tripwire-only · spine-Mac 51/7.

**Notes for the architect's review:**
- The owed set is deliberately conservative on invention: where a Mac act's phone shape would be a design act (commit/history face, lens top-bar, merge workaround, book-details sheet), the row says "shape at the batch" rather than sketching UI — the batches' briefs own the shapes, the 4E propose-first pattern where flagged.
- Two rows interact with OTHER phases' territory and are routed, not built: deletion/restoration (PL-3/13j — consciously deferred, Stage E reads it) and the 13e takes vocabulary (PL-1). The lens batch carries a 13j-adjacent rider (dangling-pick honesty) without building the Mac's loud door.
- The refusal sweep is LAST by dependency and carries PB1-4's lesson-update rider explicitly; six of the fourteen user-facing rows dissolve on ONE door family (take locks — C4), which is why C4 precedes C5.
- The S5 row expects zero code: if the verify finds the badge/browser road broken, that is a FINDING (trace + red-on-old), not a silent fix.

## Stage C, batch C1 — ACCEPTED; THE BATCH ORDERING RULED (architect, 2026-08-09)

The matrix reviewed directly (the kickoff's record-only
interpretation): 71 registry CapabilityIDs + 20 registry-blind rows
all dispositioned, ruling citations on every non-already row,
already-parity verdicts grounded in mobile code + pins, the
refusal inventory grep-grounded (15 rows). **The proposed C2–C5
ordering is ADOPTED as written** (C2 books/membership/metadata with
the details-surface design fork · C3 the see-your-data trio · C4
takes completeness/locks/history/editor fill + the S5 pin · C5
lenses design-first + the refusal sweep LAST). **The 11 OPEN-FOR-HER
rows ride the end bundle** — none gates a batch (all additive); her
answers fold into the owning batch if they arrive mid-chain (the
standing fold-in rule). The one sanctioned-exception-candidate (the
merge-ceremony refusal) gets its "SOMEHOW" road designed at C5, per
her no-redirect wording's own exception clause.

## Stage C, batch C2 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at the C1 acceptance commit. **Scope:
books & membership + note metadata — the matrix's C2 rows ONLY**
(the OPEN-FOR-HER rows are out: no chapters/reorder/sort-picker/
entry-date/stars/convert — unruled product behavior is never built).

**Read first, IN FULL:** `CLAUDE.md` · `notes/MobileSoul.md` · THIS
plan file top to bottom — above all **THE PARITY MATRIX's books &
membership + note-metadata rows** (each row cites its ruling; build
to the citations) and the refusal inventory's four C2 rows ·
`notes/plans/mobile-app-plan.md`'s GATE SITTING record (LK5's
expansion ruling verbatim) · the Mac's shelf/book faces in code
(the shapes being paralleled — `App/Variorum/Features/`) · the
mobile shell/shelf/book surfaces (`App/Variorum/VariorumMobile/`) ·
`notes/plans/mobile-architect-handoff.md`. Environment traps bind.

**THE ONE DESIGN FORK — propose BEFORE building (the 4E pattern):**
the BOOK DETAILS surface's shape (off a book's contents: finish/
unfinish · tag editing · rename · the daily-designation road — and
create-book's home if you put it there). END YOUR TURN with a short
proposal: where the door lives on the contents screen, sheet vs
push, the acts' arrangement, refusal/undo stories per act, LK canon
cited — one line of why each. The architect rules repo-first; you
build on the ruling. Everything else builds straight.

**The work (besides the fork):** create book (the matrix's kinds) ·
pin/unpin · smart-book-from-tags (her "people also need to be able
to create books based on tags") · the membership chip (see
memberships, add-to-book; the diverge-for-book road where the core
op's curated-only shape allows) · rename note · the four C2 refusal
rewords (Today door + tray). ALL acts route through existing core
operations (`addPostToReading`, `assertReadingAcceptsPosts`,
`shelveInDailyJournalBook`, `divergePostForReading`, reading CRUD —
they exist; read them). **Small additive `VariorumCore/Queries`
reads are legal IF genuinely needed** (e.g. books-by-tag), with the
FULL four-suite duty and zero change to existing queries; anything
in `Operations/`, schema, or `Sync/` STOPS and returns to the
architect. **Tutorial-as-spec rider:** any door or copy the pocket
guide teaches that this batch changes updates the lesson AND its
walk in the same commit.

**Discipline:** work synchronously; red-on-old for defect-class
fixes; state-transition tests through the view models for every new
door; refusal copy carries no platform name. Full mobile suite green
by your own run (arithmetic accounted) + the spine 32/7 + perf 9/2
by name; four-suite duty if core Queries changed. Commit per logical
unit with the standing trailer; write "## Stage C, batch C2 — BATCH
RECORD (implementer, 2026-08-09)" into THIS file; push
`origin mobile`. PROVISIONAL-and-continue; author-only calls stop.

## MID-CHAIN SITTING (2026-08-09, via RC — the 11 OPEN-FOR-HER rows RULED; verbatim-faithful)

She asked for the question tool and answered all eleven (two rounds
of four after round one's four — the tool's 4-cap reshaped her 5+6).
Her words quoted where she wrote them:

1. **Book structure management → RULED SET ONLY, with a NEW FACT:**
   *"There is a mac phase coming up that's going to redefine some
   elements of books / chapters / rules, so keeping the ruled set
   only is fine for now and we'll plan to add other functionality
   once the mac side is done."* (13i's orbit.) Chapters/reorder/
   sort-change/smart-filter-editing/conversion all WAIT for the Mac
   redefinition; a post-13i mobile round adds them.
2. **Tag management → CROSS FULLY** (after the subtree explanation;
   her grounds, verbatim: *"I know some people won't use the mac app
   at all, so I'm inclined to say cross fully."*) — rename +
   delete-with-subtree get C3 doors, the subtree consequence named
   in the delete confirm; phone tag-create supports child tags. Her
   sentence is also a standing parity principle: phone-only users
   are real.
3. **Block tags → Mac-side for now** (recommended accepted).
4. **Entry date → CROSSES** (recommended accepted) — folds into C2's
   note-metadata family (running batch; added at the fork resume).
5. **Extract + Make Block → CROSS via the selection menu** (C4).
6. **Delete in Every Take → Mac-only for now.**
7. **Take diff → swipe suffices** (R58's grammar re-affirmed).
8. **Duplicate as Version → wait for a felt need.**
9. **Library sort picker → ADD** (→ C3, the mechanical batch).
10. **Stars → CROSS** — act + starred face, exact shape at the batch
    (→ C3).
11. **Block-TOC in-note list → YES, v1** — names get their phone
    face (→ C4).

**Scope updates from the sitting:** C3 gains tag management (rename
+ delete-with-subtree) · the Library sort picker · stars. C4 gains
extract/make-block on the selection menu · the block-TOC list. The
end bundle's open-question count drops to ZERO — everything her
sitting owed is now ruled or consciously waiting (13i's round; felt-
need flips). Also her morale note, kept because it names the bar:
*"I was super happy to see that you diagnosed an issue with the
notes being too slow to edit - it's the thing that most bugs me
about apple notes so I'm happy it's being handled."* And her context
guidance: *"500k is rather conservative so feel free to continue."*

## Stage C, batch C2 — THE BOOK DETAILS RULING (architect, 2026-08-09; the fork's repo-first ruling)

**ADOPT the proposed shape:** the voiced **"Details"** word in the
contents screen's trailing chrome · a medium-detent LK4 sheet over
the contents · the act column as proposed (identity block on the
shelf faces' one brain · rename via the name row, alert-prefilled ·
one state-mirroring Finish/Reopen row through `lockReading`/
`unlockReading` · Use-as-Daily rendered on curated journal-profile
books only, P-2's letter) · create-book stays the shelf's ·
delete/extents/structure deliberately absent as proposed.

**The tags half → (B), decided BY HER SITTING ANSWER, not by
preference:** her book-structure ruling explicitly deferred
smart-filter editing until the Mac's 13i-class redefinition — and
option (A)'s editable half IS smart-filter editing. So: details
**DISPLAYS** the book's tags (both kinds, the shelf faces' source);
nothing tag-editable ships in C2; C3's tags family owns note-level
tag editing; smart-filter tag editing joins the post-13i round with
the rest of structure management. (A curated book's shelf tags are
derived from member notes by model fact — there is no book-level tag
row to edit; the display says so honestly if a reader wonders.)

**Added to C2 at the same resume (her sitting, item 4):** entry-date
set/clear crosses — the note-metadata family's last member; through
the existing `setEntryDate` op, phone face the implementer's call,
state-transition tests per act, no platform-named refusals. The
Today-door rewords + the getting-around lesson update ride the fork
build as proposed (tutorial-as-spec).

## Stage C, batch C2 — BATCH RECORD (implementer, 2026-08-09; commits `303689e` · `121bdd6` · `54dd6f5` · `aaf80fa` · `c361db2` · `d6a8dc6` + the record commit)

**Every matrix C2 row shipped** (books & membership + note metadata,
plus the sitting's entry-date addition), all acts through EXISTING
core operations — zero `Sources/VariorumCore/` lines, zero schema,
zero `Sync/` (the anticipated small-Queries case never fired: every
read needed already existed). ONE `App/Variorum/Shared/` change
(below), Mac-suite-verified. Per capability:

1. **Pin/unpin (`303689e`).** Door: the shelf book row's LONG-PRESS
   context menu — the act belongs where the list it orders lives (the
   Mac shelf row's own placement, the phone's long-press grammar);
   state-mirroring words via the pure `MobileShelfFaces.pinDoorTitle`
   (the Mac menu's own vocabulary, voice-cased). Op: `setShelfPinned`
   (R38 append-order, idempotent both ways). Test: order flips both
   ways against store truth + the door words
   (`MobileBookPinTests`, 1).

2. **Create book + smart-book-from-tags (`121bdd6`).** Door: the
   shelf list's own trailing "+ new book" row (a list of books ends
   with the door that adds one; the path line stays two doors — the
   P38 crowding lesson); ONE sheet folds the Mac's three-kind alert
   AND its Promote-to-Book sheet — deliberately, because the phone
   has no smart-filter editor (ruled deferred), so smart creation IS
   the from-tags road: spec chosen at birth (OR→`tags`,
   AND→`tagsAll` — the Mac `PromoteTagsSheet.spec` rule mirrored
   pure), tags stay on the notes (R37). Journal books mint the Mac
   alert's exact dated shape (curated · profile 'journal' ·
   entry-date asc). Refuse-at-the-face gates: no nameless book (K1 —
   no literal placeholder mints), no tagless smart book. Landing:
   the created book opens as its contents front (fire-and-DO). Ops:
   `createReading` only. Tests: three-kind exact rows · end-to-end
   from-tags collect + canonical spec JSON + AND arm · the pure gate
   (`MobileBookCreateTests`, 3).

3. **The membership chip + diverge-for-book (`54dd6f5`).** Door: the
   masthead's identity line under the title (the chip label in the
   voice's path grammar — "~/journal" terminal single-book, "in N
   books" — accent when several; the Mac label's own rule); tap →
   an LK4 sheet carrying the Mac chip's vocabulary: SEE curated AND
   smart holdings (derived membership IS membership;
   curated-before-smart order, no recents — the phone has no
   workspace visit history, recorded), ADD to open curated books
   (`addPostToReading`), add to smart books BY TAGGING
   (`collectPostIntoSmartReading`, R98 apply-and-report), REMOVE
   where a row exists (`removePostFromReading`; a smart row renders
   NO remove — P-2, pinned pure), DIVERGE FOR THIS BOOK through the
   SHARED flush-first entry (`AppSession.divergeForBook` →
   `divergePostForReading`), the copy one tap away (R67 — an
   `onOpenNote` push threaded from the shell). **The one `Shared/`
   change: `divergeForBook` moved OUT of `AppSession`'s
   `#if os(macOS)` fence** — the soul rule's letter (mobile never
   forks a brain; this four-line entry IS the R1-4 flush-first
   brain); Mac code byte-identical, and the full Mac suite ran as
   proof: **"Test run with 1245 tests in 219 suites failed … 1
   issue" — the one issue re-confirmed BY IDENTITY as the standing
   `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByAConvergence
   Occasion` tripwire** (the recorded baseline exactly). Phone
   wording deltas, deliberate: no "⌥⌘Z undoes it" tail (the phone
   has no structural undo — the recorded v1 posture) and the
   smart-diverge refusal names no Duplicate-as-Version door (OPEN →
   ruled wait). Tests: brains (label/order/P-2) · exact membership
   rows both ways · collect-by-tagging · diverge exact-slot + THE
   PENDING-BYTES PIN (typed bytes recorded in the one per-post
   coordinator ride into the copy — R1-4) · smart-diverge refusal
   mints nothing (`MobileMembershipTests`, 4).

4. **Rename note (`54dd6f5`).** Door: the masthead TITLE is the door
   (alert-confirmed — a stray tap costs nothing; prefilled with the
   STORED title, never the derived display). Op: `renameContainer`
   (trimmed; blank clears to NIL — R6-3/K1's no-placeholder
   semantics); legal under the seal BY AppSpec §9's letter ("may
   still be … retitled"), pinned. Tests: trim/clear/under-seal
   (`MobileNoteRenameTests`, 2).

5. **Tray rewords (`aaf80fa`)** — inventory #2/#5 DISSOLVED
   (sanctioned pin flips riding the matrix): the delete confirm's
   detail and the post-delete report keep the tray FACT and lose "on
   the Mac"; both hoisted to pinned statics with no-platform-name
   assertions. The recovery DOOR stays PL-3/13j's, consciously
   routed.

6. **THE BOOK DETAILS SURFACE (`c361db2`, built to the fork's
   ruling).** Door: the voiced **"Details"** word in the contents
   screen's trailing chrome beside "Read" (pinned static); a
   medium-detent LK4 sheet. The act column as ruled: identity block
   on the ONE shelf-faces brain (name-with-✓ + count·tags·daily —
   details can never disagree with the shelf; ONE read delivers row
   + tags + designation coherently) · the name row IS the rename
   door (`renameReading` — free on finished books, the
   renameSection parallel, pinned; blank face-gated) · one
   state-mirroring **Finish/Reopen** row (`lockReading`/
   `unlockReading` — a reversible guard, its own inverse, no undo
   entry) · **tags DISPLAY-ONLY, both kinds** (ruled (B): a curated
   book's tags are derived from member notes by model fact; smart-
   filter editing waits for the Mac's book redefinition) · **Use as
   Daily Journal** rendered on curated journal-profile books only
   (the Mac's render rule, P-2, pinned pure; `setDailyJournalBook`).
   Deliberately absent as ruled: delete book (PL-3/13j) · extents
   (LK5's ranking) · chapters/reorder/sort/filter/convert (the
   post-13i round). **Same commit: the three Today-door rewords**
   (inventory #8/#9/#10 dissolved — finished names "reopen it from
   its book details"; full and smart name the designation road;
   extents stay unbuilt so #9's road IS designation; substring pins
   kept, road words + a no-"Mac" sweep added) and the
   getting-around lesson's details sentence. Tests: finish/reopen
   flips + faces · rename trim/gate/free-under-finish · the
   designation road END-TO-END (a smart-daily Today refusal →
   designate a curated journal from details → the next Today
   shelves silently) · tags display for both kinds · the door word
   (`MobileBookDetailsTests`, 4).

7. **Entry date set/clear (`d6a8dc6`, her sitting item 4).** Door:
   the masthead identity line's DATE CHIP beside the books chip
   (the date is note identity exactly as membership is; the
   alert-confirmed chip is the rename door's own grammar — field
   prefilled, Set / Clear Date / Cancel, the format named in the
   message). Op: `setEntryDate` (blank clears — un-dating is the
   op's own letter; the op's `invalidEntryDate` stays the belt).
   A malformed day REFUSES AND KEEPS in phone words (the
   ExtentInput parallel; pinned static, no platform name). Dating
   rides the retitle class under the seal (the op's standing
   both-platform behavior — recorded and pinned, not left to
   inference). Tests: set/clear + untitled-masthead-shows-the-day ·
   refuse-and-keep · under-seal (`MobileNoteEntryDateTests`, 3).

**Tutorial-as-spec:** the getting-around lesson's prose grew in the
OWNING commits (shelf doors + pin long-press · the masthead
identity paragraph · the details sentence · the date chip); no walk
pins prose (PB1-3 — the shape/door suites re-ran green each time);
no new lesson (the 13-lesson counts stay pinned).

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS
26.2):** full mobile — **"Test run with 244 tests in 42 suites
passed"** — the 227/36 baseline + 17 tests + 6 suites, exactly
accounted (pin 1 · create 3 · membership 4 · rename 2 · details 4 ·
entry-date 3; suites `MobileBookPinTests` · `MobileBookCreateTests`
· `MobileBookDetailsTests` · `MobileMembershipTests` ·
`MobileNoteRenameTests` · `MobileNoteEntryDateTests`). Spine
**32/7** and perf **9/2** by named runs. Mac **1245/219
tripwire-only by identity** (run at the one Shared/ change).
Release build **SUCCEEDED**. Core/spine-Mac not run: zero
`Sources/VariorumCore/` lines in the whole batch.

**PROVISIONALs (for the chain's end bundle):**
- **PC2-1:** the chip sheet's book-name rows are LABELS, not doors —
  seeing the holdings is the owed capability; the Mac's
  open-book-at-note ascent has no phone wiring yet (one push closure
  away if her look wants it).
- **PC2-2:** the create sheet's words (kind doors "Book · Journal
  Book · Smart Book", the "Create Book" button, the three captions)
  and its open-the-created-book landing — all one-line changes for
  her look.
- **PC2-3:** the date chip's face — a text-field alert (plain
  yyyy-mm-dd, matching the op's own vocabulary) rather than a
  DatePicker sheet, and "no date" as the unset label; a picker is a
  look-round swap if wanted.
- **PC2-4:** diverge and remove-from-book ship WITHOUT confirms —
  both are recoverable by hand (re-add; the original keeps
  everything), unlike the tray-bound delete-block whose confirm
  precedent (P40) is explicitly about un-recoverable-on-phone
  destruction. Recorded judgment, hers to flip.
- **PC2-5:** the details sheet's Finish/Reopen caption sentences and
  the "Book Details" header word — copy for her look round.

**Deliberate absences (scope, not holes):** delete book + trash/
restore (PL-3/13j, consciously routed) · extent faces (LK5's
recorded ranking) · chapters/reorder/sort-change/smart-filter-
editing/conversion (her sitting's ruled WAIT — the post-13i round)
· the pin door not duplicated on details (one act, one door — the
shelf row it orders) · locked-take/merge-ceremony refusal strings
untouched (C4/C5's families, incl. PB1-4's lesson rider) ·
note-level tag editing (C3's, per the ruling).

## Stage C, batch C2 — ACCEPTED; the C2 LADDER OPENS (architect, 2026-08-09)

Verified: all seven commits present; the mobile suite re-run by the
architect's own hand: **"Test run with 244 tests in 42 suites
passed"** — 227/36 + 17/6, exactly accounted; zero
`Sources/VariorumCore/` lines (the small-Queries allowance never
fired); the ONE `Shared/` change (`AppSession.swift`, 24+/21− — the
`divergeForBook` relocation out of the macOS fence) covered by the
implementer's Mac run at **1245/219 tripwire-only by identity**.
Five refusal strings dissolved with their doors landing in the same
commits; the getting-around lesson grew per owning commit
(tutorial-as-spec held). **PC2-1…PC2-5 ride the end bundle.**

**THE C2 LADDER OPENS.** Target: `6ccdfca..e67a8e0` (the batch's
seven commits; the C1 matrix, the fork ruling, and the mid-chain
sitting are the reviewer's anchor). Fresh cold reviewer,
`notes/REVIEW_PROMPT.md` VERBATIM; findings repo-first as "## Stage
C review — C2 round 1 findings". Baselines at open: **mobile 244/42
· spine 32/7 · perf 9/2 · core 1214/128 · Mac 1245/219
tripwire-only · spine-Mac 51/7.**

## Stage C review — C2 round 1 findings (cold reviewer, 2026-08-09)

**Method.** Cold, zero implementation context. Read: `CLAUDE.md`;
`notes/MobileSoul.md` in full; this plan's Stage C kickoff, C1 brief +
THE PARITY MATRIX (every C2 row and its citations), the MID-CHAIN
SITTING, the BOOK DETAILS RULING, the C2 brief, batch record, and
acceptance; `notes/plans/mobile-app-plan.md`'s gate record (the LK5
expansion ruling verbatim at ~6028); AppSpec §7/§9 for the seal and
`setEntryDate`/`renameContainer` letters. The full diff
`6ccdfca..0999771` read file by file, plus every core operation the
new doors call (`Operations+Diverge`, `+SmartCollect`, `+Reading`,
`+Appearance`, `+Container`), the shared seam (`AppSession`,
`AutosaveCoordinator.record/flushNow`), the Mac parallels being
mirrored (`MembershipChip`, `ShelfView`'s create/rename alerts +
pin menu, `AppSettingsView`'s PromoteTagsSheet spec rule,
`ReadingsViewModel`), and all four new/changed test files. No fixes
made. No "Review foci" section exists for this project.

### Findings

**MINOR C2-R1-1 ·
`App/Variorum/VariorumMobile/Features/Write/MobileWriteView.swift:203`
(the rename alert's message) — the blank-clear promise names a
display shape that does not exist.** The alert says *"A blank title
clears the stored name — the note shows its own words instead."*
Mechanism: `renameNote(blank)` stores NIL →
`adoptHeader` → `DisplayTitle.note(title: nil, entryDate:)` — and
that brain's chain is title → DAY → the literal `"Untitled"`
placeholder (`Sources/VariorumCore/Domain/DisplayTitle.swift:120–124`).
No arm of the chain ever shows the note's words (first-sentence
derivation is the BLOCK-name brain, never a note title). So a dated
note shows its day and an undated one shows "Untitled" — the user
who blanked the title expecting "its own words" gets neither. The
sentence is also an unpinned view literal, against the batch's own
hoist doctrine ("a promise in a literal is a promise no test can
keep" — applied to the tray strings in `aaf80fa` but not here).
*Fix:* reword to the day fact (e.g. "the note shows its day
instead") and hoist to a pinned static. Copy-class — no red-on-old
pin owed beyond the hoisted-string assertion.

**MINOR C2-R1-2 ·
`App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift:406–408`
— the masthead's DisplayTitle call drops the `createdAt` link the
Library uses, and this batch's new doors walk users into the
divergent state.** `adoptHeader` calls
`DisplayTitle.note(title:entryDate:)` with no `createdAt`
(`Queries.ContainerHeader` doesn't carry it —
`Sources/VariorumCore/Queries/EditorSupport.swift:14–32`), while the
Library row calls the same brain WITH it
(`MobileLibraryViewModel.rowTitle:154–157`). Mechanism: mint via
"+ new note" (nil title, nil entry_date) → the Library row shows the
created day; the masthead shows the literal "Untitled" — two phone
surfaces disagree on the same note's name, against the DisplayTitle
header's own one-brain doctrine. Pre-existing call (unchanged by
this diff), but C2 made the masthead title THE RENAME DOOR whose
blank-clear arm lands exactly here, and the new pin
(`setAndClearTheEntryDate`'s "untitled-masthead-shows-the-day")
covers only the entry-dated arm. Red-on-old pinnable today: assert
an untitled, undated note's `displayTitle` equals its created day —
fails on this tree. *Fix shape:* carry `createdAt` on
`ContainerHeader` and pass it (the C2 brief's small-additive-Queries
allowance, which fires the four-suite duty), or record the
divergence as deliberate where the ladder rules the query change out
of a review round's scope.

**NIT C2-R1-3 ·
`App/Variorum/VariorumMobile/Features/Shell/MobileBookDetails.swift:118–123`
— the book-rename door refuses blank silently.** `rename()` is
`guard canRename else { return }`: tapping "Rename" with a blanked
field dismisses the alert having done and said nothing — the quiet
half-door class the capability doctrine dislikes. For the record,
the Mac parallel is WORSE, not better: `ReadingsViewModel.rename`
(`:63–65`) passes any string straight to `renameReading`, which has
no gate (`Operations+Reading.swift:77–79`) — the Mac stores a blank
book name (its own latent wart, out of this diff's scope). One line
either way on the phone: speak a refusal into `lastError`, or
disable the alert's Rename button as the create sheet disables
"Create Book".

**NIT C2-R1-4 · `App/Variorum/Shared/AppSession.swift:40–41` — a
stale comment in the one Shared file this batch touched.** "(…the
mobile surface performs no structural ops, so it stays empty
there.)" has been false since the v1 build (the phone's
divide/merge/delete register inverses) and this batch widens the
falsehood: `divergePostForReading` registers an undo entry
(`Operations+Diverge.swift:114`) now reachable from a phone door.
Harmless at runtime (entries are small and session-scoped; no phone
door drains them — the recorded no-structural-undo posture), but the
comment misinforms the next reader of a load-bearing shared file.
Comment fix only.

**NIT C2-R1-5 · this plan file, the C2 brief ("the four C2 refusal
rewords") vs the inventory and record (five: #2/#5/#8/#9/#10) — a
count drift in the process record.** The code followed the matrix
(all five dissolved); the acceptance's "five … with their doors
landing in the same commits" is also loose for #2/#5, whose
disposition is reword-only with the recovery door consciously
PL-3/13j-routed (no door owed — the matrix's own ruling). Recorded
so the numbers reconcile; no code change.

**NIT C2-R1-6 ·
`App/Variorum/VariorumMobileTests/MobileBooksTests.swift:305–316` —
a second file-scope polling helper.** The new global `settle`
duplicates the shape of `MobileTutorialWalkTests`' private `poll`
(`:67`). Two coexisting helpers invite a third; hoist one into
`MobileEditorTestSupport` when convenient. Cleanliness only.

### Clean bill (load-bearing things specifically checked and found solid)

- **The ONE `Shared/AppSession.swift` change is Mac-behavior-identical
  by token identity:** the `divergeForBook` body (signature + the two
  statements) is byte-identical before/after; only its position (out
  of the `#if os(macOS)` fence) and the doc comment changed; every
  member it references (`autosave(forPost:)`, `runner`,
  `Operations.DivergeResult`) is unfenced shared code; the Mac-fenced
  caller (`divergeFromNote:190`) is untouched. Verified by diff
  reading; the implementer's + architect's Mac runs (1245/219
  tripwire-only by identity) stand as the suite evidence.
- **The flush-first claim is structurally true on the phone, not just
  pinned:** the mobile editor takes its coordinator from the SAME
  per-post registry the shared entry flushes
  (`MobileEditorViewModel.swift:152` →
  `session.autosave(forPost:)`; `divergeForBook` flushes that
  registry's coordinator), and the R1-4 pin
  (`divergeSwapsAtTheExactSlotAndCarriesPendingBytes`) records
  pending bytes through that same accessor and reads them back out
  of the copy's variant rows.
- **Zero `Sources/VariorumCore/` lines** in `6ccdfca..0999771`
  (verified by `git diff --name-only`; the small-Queries allowance
  indeed never fired); zero schema; zero `Sync/`; every new door
  routes through an existing core op, each read in source:
  `setShelfPinned` (R38 append-order, idempotent guards) ·
  `createReading` (three kinds; the journal shape byte-matches the
  Mac alert's curated/'journal'/entryDate-asc) ·
  `addPostToReading` / `collectPostIntoSmartReading` (R98) /
  `removePostFromReading` · `divergePostForReading` (smart →
  `wrongReadingKind`, finished → `lockedReading`, exact
  slot + section, capacity deliberately ungated) · `renameContainer`
  · `setEntryDate` (`JournalDay` belt) · `lockReading`/
  `unlockReading` · `renameReading` · `setDailyJournalBook`.
- **The five refusal dissolves, verified per commit:** #8/#9/#10
  reword in `c361db2`, the SAME commit that builds the doors the new
  words name (Finish/Reopen + Use-as-Daily on the details sheet);
  #2/#5 reword neutrally in `aaf80fa` per the matrix's
  reword-only/PL-3 disposition. `MobileShellTests` pins all four
  shelving notes Mac-free; the tray pair are hoisted pinned statics.
  No new user-facing "Mac" string anywhere in the diff (grep-checked;
  remaining inventory rows #1/#3/#4/#6/#7/#11–14 are C4/C5's,
  deliberately untouched).
- **The book-details tags half is display-only as ruled (B):**
  `MobileBookDetailsModel` exposes `tagPaths`/`metaLine` and no
  tag-touching act; both kinds render through the ONE shelf faces
  brain (smart = its own spec's tags; curated = derived member-post
  paths), pinned in `theIdentityBlockDisplaysTagsForBothKinds`. The
  create sheet's picker only chooses spec paths at birth
  (`createReading` alone — R37 held: applications untouched); the
  membership sheet's `collect` applies tags, which is the Mac's own
  R98 smart-ADD road, not book-details tag editing.
- **Under-seal rename/entry-date match the letters:** rename is
  §9's own enumeration ("may still be … retitled") — pinned
  (`renameWorksUnderTheSeal`); entry-date is not in §9's list but IS
  the recorded core class — `setEntryDate` carries no seal guard by
  design and the core's own `setPostWordTarget` comment names "the
  N34 container-row-metadata-allowed class (title/date/profile/
  segmentation stay editable under seal)" — so the phone pins
  standing both-platform behavior rather than inventing it
  (`entryDateWorksUnderTheSeal`).
- **The Mac chip's vocabulary genuinely mirrored, deltas recorded:**
  label three-case + path grammar (`MembershipChip.label:178–187`),
  add/collect/remove/diverge bodies near-verbatim, smart rows
  rendering diverge-with-honest-refusal exactly as the Mac's rows do
  (its comment: "silence where the row looks actionable is the
  confusion"). The phone's two wording deltas (no ⌥⌘Z tail, no
  Duplicate-as-Version door) and its P-2 refinement (no remove door
  on smart rows, where the Mac renders one that can only refuse) are
  all recorded in the batch record.
- **The spec/JSON road end-to-end:** `MobileCreateBookModel.spec`
  mirrors `PromoteTagsSheet.spec` exactly (OR→`tags`, AND→`tagsAll`);
  canonical JSON pinned; the single-tag AND degenerates to OR
  (`joinAll && paths.count > 1`) — semantically identical, safely.
- **Live projections hold:** the shelf's held observation covers
  books + pins + daily designation, so pin/designate/finish/rename
  flow to the shelf without manual refresh; the contents screen holds
  its own reading-row observation, so a details rename/finish
  updates the screen beneath the sheet.
- **Tutorial-as-spec held:** the getting-around lesson grew in each
  owning commit (pin long-press · + new book · details · the
  masthead identity paragraph · the date chip); every door it names
  exists in the same tree; walks pin staging, not prose (PB1-3) —
  the 13-lesson counts stand (spine green below).
- **Deliberate absences verified absent, not forgotten:** no delete
  book, no extent faces, no chapter/sort/filter/convert acts, no
  note-level tag editing on details (C3's), no pin door duplicated on
  details — each matching its named ruling.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator)

- Full mobile suite: **244 passed, 0 failed, in 42 suites** (xcresult
  summary verified: passedTests 244, failedTests 0; the 42 suite
  names enumerated — all six new C2 suites present). Matches the
  batch's arithmetic exactly (227/36 + 17/6).
- The spine by its seven type names: **"Test run with 32 tests in 7
  suites passed after 3.539 seconds"** — TEST SUCCEEDED.
- Perf suites standalone (`MobilePerfFixtureTests` ·
  `MobilePerfWalkTests`): **"Test run with 9 tests in 2 suites
  passed after 9.857 seconds"** — TEST SUCCEEDED.
- Core / Mac / Mac-spine: not run — zero `Sources/VariorumCore/`
  lines in the diff (the standing only-if-shared condition); the one
  `Shared/` change verified Mac-identical by diff reading (clean
  bill, first entry) with the implementer's recorded Mac run as
  suite evidence.

## Stage C review — C2 round 1 ADJUDICATION + FIX PASS (at the architect's hand, 2026-08-09)

No BLOCKER/MAJOR; all six findings adjudicated FIX and executed by
the architect directly (the skill's small-fixes allowance; every
trace re-verified against the code before changing it):

- **MINOR C2-R1-2 → FIXED (the one core-touching fix — the C2
  brief's small-additive-Queries class):** `Queries.ContainerHeader`
  gains `createdAt` (the raw TEXT stamp, fetched as stored — no
  Date round-trip; the comment says why), and the masthead's
  `DisplayTitle.note` call carries it — the masthead and the listing
  rows now read ONE chain. Pin
  `anUntitledUndatedNoteMastheadShowsItsCreatedDay` uses the brain
  itself as oracle; **red-on-old verified by behavioral revert** (2
  issues on the pre-fix VM line, siblings green, discrimination
  clean).
- **MINOR C2-R1-1 → FIXED:** the blank-clear copy hoisted to
  `MobileEditorViewModel.blankTitleClearsMessage` and corrected —
  "the note shows its date instead" (the chain's truth); pin
  `theBlankClearMessageNamesTheRealFallback` guards both directions.
- **NIT C2-R1-3 → FIXED:** the book-rename alert's Rename button
  disables on blank — the face gate the model's comment promised.
- **NIT C2-R1-4 → FIXED:** `AppSession`'s stale "no structural ops
  on mobile" comment corrected (the phone registers undo entries at
  its structural doors; no undo UI yet).
- **NIT C2-R1-5 → RECORDED here:** the brief's "four rewords" vs
  five dissolved — the fifth (#2/#5's second string) rode the same
  tray commit; #2/#5 are reword-only per the matrix (no door owed);
  the acceptance's "doors in the same commits" claim is precise for
  #8/#9/#10 only.
- **NIT C2-R1-6 → FIXED:** the walks' private `poll` delegates to
  the shared `settle` — one polling body suite-wide, call sites
  untouched.

**Four-suite duty (the core header changed), all by the architect's
own runs:** mobile **246/42** (244 + the two pins, exact) · core
**1214/128** · Mac **1245/219 with exactly the standing TakePane
tripwire by identity** · Mac spine **51/7** (by the seven TRUE suite
type names — the file-name trap re-confirmed and dodged). **ROUND 2
OPENS** on the fix set: target this commit's diff inside
`6ccdfca..HEAD`; fresh reviewer; new BLOCKER/MAJOR ⇒ round 3.

## Stage C review — C2 round 2 (fresh cold reviewer, 2026-08-09)

**Method.** Cold re-review of the fix set `59b9dd4..1aec1a2` inside
the batch's `6ccdfca..1aec1a2` — a real pass over the fixes and what
they touched, held to implementer severity (the fixes were the
architect's). Read: the round-1 findings + adjudication above as
anchor; the full fix diff file by file; `EditorSupport.swift`'s
changed query in place; `DisplayTitle.swift` whole (the chain the
R1-2 fix joins); `VariorumRecord.swift` (the `createdAt: Date`
decode premise); every `ContainerHeader` consumer repo-wide by
enumeration; every `DisplayTitle.note` call site by per-site read;
the R1-4 comment's claims against the phone's actual registering
doors (`MobileStructural`, `MobileTakesBrowser`,
`Operations+Structural/+TakeEdits/+Deletion/+Diverge` register
sites); `MobileBookDetails.swift` and `MobileWriteView.swift`'s
alert regions whole; the `settle`/`poll` pair's exact semantics.
Pins re-run by name where they settle claims. No fixes made.

### Verdicts per round-1 fix — ALL SIX HOLD

- **R1-2 (the core-touching fix) → HOLD.** The query shape checked
  in place: the raw `String.fetchOne` re-reads the SAME row inside
  the same read transaction two lines below `Container.fetchOne` —
  the `?? ""` arm is unreachable (and would degrade to the
  placeholder via `day(fromStamp:)`'s isEmpty guard, never crash).
  The raw-fetch-vs-record-Date reasoning HOLDS and is the
  established pattern, not an invention: the record decodes
  `createdAt` as `Date` (`VariorumRecord`'s formatter strategy), and
  every other carrier of this fact already reads the stored TEXT raw
  — `noteDisplayTitle`'s `Row.fetchOne` (TakesQueries:146–151),
  `TimelineItem.createdAt` (Timeline.swift:77), the catalog hits
  (ShelfQueries:411) — so "one chain, as stored" is literally true
  rather than a comment's hope. Consumers enumerated: the two editor
  VMs (mobile now passes `createdAt`; the Mac's `adoptHeader` reads
  `locked` only — behavior unchanged) + `observeContainerHeader`
  (`removeDuplicates()` over Equatable — `createdAt` is immutable
  per row, no operation writes it, so no new delivery source); NO
  construction site exists outside core (the memberwise init is
  internal; every test reference in all three test targets is a
  fetch, grep-verified). The pin exercises the REAL path
  (`loadOnce` → `Queries.containerHeader` → `adoptHeader`), uses
  the brain itself as oracle (timezone-proof by construction), and
  passes BY NAME in my targeted run; the red-on-old mechanism is
  traced — pre-fix the call took `DisplayTitle.note`'s defaulted
  `createdAt: nil`, so untitled+undated → placeholder → exactly the
  adjudication's 2 issues. P1-clean: one extra PK point-read per
  header materialization, cost ∝ the container, never the corpus.
- **R1-1 → HOLD.** "the note shows its date instead" is the chain's
  truth post-R1-2 (entry date, else created day; the placeholder
  survives only for an unparseable stamp — practically unreachable);
  the rename prefill is the STORED title (`header?.title ?? ""`,
  MobileWriteView:141), never the displayed day, so blank-clear can
  never accidentally store a date; the pin guards both directions;
  no stale "own words" copy anywhere (grep, non-test sources).
- **R1-3 → HOLD.** The `.disabled` gate re-evaluates as the alert's
  `@State`-bound TextField edits; the model's `guard canRename`
  belt stays beneath the face; `canRename` is pure, nonisolated,
  and already pinned (MobileBooksTests:216–217); its `.whitespaces`
  trim matches the create sheet's `canCreate` gate exactly — "the
  create sheet's rule" is accurate to the letter.
- **R1-4 → HOLD, with one NIT residue (N-1 below).** The falsehood
  the finding named is gone and the sentence's claim is true — but
  the replacement's door list undercounts (see N-1).
- **R1-5 → HOLD.** Record-only, recorded; the reconciliation
  paragraph is where the adjudication says it is.
- **R1-6 → HOLD.** `settle` is internal (target-visible) and the
  delegation's signature/isolation line up; semantics equivalent —
  the `where`-clause loop performs up to `attempts` extra cheap
  `done()` evaluations after the condition turns true instead of
  poll's early return, with no suspension either way (the walks'
  conditions are pure state reads); spine 32/7 green through the
  rewired helper by my own run.

### New findings

- **NIT C2-R2-N1 · `App/Variorum/Shared/AppSession.swift:40–43` —
  the R1-4 replacement comment's enumeration is itself incomplete.**
  "divide, delete, the chip's diverge" reads as the phone's
  registering-door list, but merge (`MobileStructural.swift:250` →
  `ops.merge`, a register site in `Operations+Structural`) and the
  Takes browser's archive/delete-variant
  (`MobileTakesBrowser.swift:345` + its ⋯ menu →
  `Operations+TakeEdits`/`+Deletion` register sites) also register
  undo entries from phone doors. The corrected sentence's CLAIM
  ("registers entries where its structural doors do") is true; the
  em-dash list under it can misinform the next reader exactly as
  the old comment did, one notch smaller. Comment-only fix — no pin
  possible or owed.

No other new findings: no BLOCKER, no MAJOR, no MINOR. Per the
ladder rule (round 3 only on a NEW BLOCKER/MAJOR), **the C2 ladder
CLOSES at round 2**; N1 is recorded for the architect's discretion.

### Clean bill (specifically checked, found solid)

- **The one-chain doctrine is now genuinely whole:** every
  `DisplayTitle.note` caller repo-wide carries `createdAt` — the
  masthead (post-fix), both mobile listing brains
  (`MobileLibraryViewModel:155`, `MobileBookViewModel:101`), the
  catalog hits, and `noteDisplayTitle` — verified per site, not by
  grep alone (multi-line calls dodge a same-line grep).
- **The Mac tree over the core change:** full Mac test-target
  compile + the Mac spine green by my own run (51/7, the seven TRUE
  suite type names); Mac `ContainerHeader` use is fetch-only and
  field-stable (`adoptHeader` reads `locked`; no equality pins, no
  constructions), so the architect's post-fix 1245/219
  tripwire-only run stands as the full-suite evidence.
- **Observation dedup unchanged:** `AppDatabase.observe` is
  `.removeDuplicates()` over Equatable; `createdAt` never changes
  on a live row, so widening the header cannot add deliveries.
- **The oracle-input premise of the new pin:** `createPost(title:
  nil)` mints nil title AND nil `entry_date`
  (Operations+Container:16–26), so the pin's hardcoded oracle
  arguments match the row's real state.
- **The fix set stayed inside its lane:** zero `Sync/` lines, zero
  schema, zero new operations; the one core change is the round-1
  finding's own proposed shape (the C2 brief's small-additive-
  Queries allowance, spent as designed).
- **No new user-facing platform-name or promise strings**; the two
  new pins are the only test-behavior additions, and the
  `poll`→`settle` rewire left every call site untouched.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator; core from the repo root; Mac spine from `App/Variorum/`)

- Full mobile suite: **"Test run with 246 tests in 42 suites
  passed"** — TEST SUCCEEDED (244 + the two fix pins, exact); both
  new pins additionally pass BY NAME in a targeted
  `MobileNoteEntryDateTests` run (5/1).
- Core: **"Test run with 1214 tests in 128 suites passed"** —
  matches the round-2-open baseline exactly.
- Mobile spine by its seven type names: **"Test run with 32 tests
  in 7 suites passed"** — TEST SUCCEEDED.
- Perf standalone: **"Test run with 9 tests in 2 suites passed"** —
  TEST SUCCEEDED.
- Mac spine by its seven TRUE type names: **"Test run with 51 tests
  in 7 suites passed"** — TEST SUCCEEDED (full Mac test-target
  compile rides this run).
- Full Mac suite: not re-run (fetch-only consumers verified by
  enumeration; the architect's recorded post-fix 1245/219
  tripwire-only run stands).

## Stage C — the C2 LADDER CLOSES at round 2 (architect, 2026-08-09); C3 OPENS

Round 2: all six fixes HOLD (the architect's fixes held to full
severity by a fresh reviewer — R1-2's core reasoning, consumer
enumeration, and pin all verified independently); no new
BLOCKER/MAJOR/MINOR. The one comment-only NIT (C2-R2-N1 — the undo
comment's door list) FIXED at the architect's hand in this commit
(merge + the browser's archive/delete-variant join the list;
comment-only, no suite consequence). **C2 CLOSED.** Baselines
carried: mobile 246/42 · core 1214/128 · Mac 1245/219 tripwire-only
· Mac spine 51/7 · mobile spine 32/7 · perf 9/2.

## Stage C, batch C3 brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at this commit. **Scope: the see-your-data
trio + the sitting's C3 additions** — tags (browse · create incl.
child tags · apply/remove on posts, leaf-chip grammar · MANAGEMENT:
rename + delete-with-subtree, her cross-fully ruling with the
subtree consequence NAMED in the delete confirm) · references (the
"More info" list: see, add a URL, open; FILE references listed
honestly in neutral words — the bookmark is per-machine by model
fact (`file_bookmark` is local-only, AppSpec §7), so the copy states
what a file row is without naming any platform) · scraps (view the
scraps area + mint a scrap — her "view your pool of scraps … and
maybe add to it"; the drag-into-note door stays not-owed) · the
Library sort picker (the standing sort vocabulary: entry date ·
created · last touched · last meaningful edit) · stars (the act +
a starred face for notes AND books — find the Mac's storage
mechanism IN CODE and reuse it through core; the face's exact home
is your call, PROVISIONAL).

**Read first, IN FULL:** `CLAUDE.md` · `notes/MobileSoul.md` · THIS
plan file top to bottom — the MATRIX's tags/references/scraps/
Library rows + the MID-CHAIN SITTING's rulings 2/3/9/10 are your
spec; the refusal inventory's C3 rows dissolve here ·
`notes/plans/mobile-app-plan.md` §§ "The settled shape" +
"Environment traps" · the Mac's tags/references/scraps/star faces
in code (the shapes being paralleled) ·
`notes/plans/mobile-architect-handoff.md`.

**Discipline (the standing set):** everything routes through
existing core operations; small additive `VariorumCore/Queries`
reads legal IF genuinely needed (four-suite duty; zero change to
existing queries; the Mac spine's seven TRUE type names are at
~line 767 of mobile-app-plan.md); `Operations/`/schema/`Sync/`
STOPS. Tutorial-as-spec: lessons + walks update in the same commit
as any door they teach. Work synchronously; red-on-old for
defect-class fixes; state-transition tests per new door; no
platform-named refusals (the delete-with-subtree confirm names the
CONSEQUENCE, not a platform). Full mobile suite green by your own
run (arithmetic accounted) + mobile spine 32/7 + perf 9/2 by name.
Commit per logical unit with the standing trailer; batch record
into THIS file ("## Stage C, batch C3 — BATCH RECORD"); push
`origin mobile`. PROVISIONAL-and-continue; author-only calls stop.

## Stage C, batch C3 — BATCH RECORD (implementer, 2026-08-09)

**Every brief item shipped** — the see-your-data trio (tags in full ·
references · scraps) plus the sitting's C3 additions (the Library sort
picker · stars). Diff scope, verified by own `git diff --name-only`:
**17 files, ALL mobile app + mobile tests — zero
`Sources/VariorumCore/`, zero `App/Variorum/Shared/`, zero Mac-side
files, zero schema, zero `Sync/`, zero pbxproj** (synchronized groups
took the five new source files). The brief's small-additive-Queries
allowance never fired: every read and every act already existed in
core — tags (`createTag`/`renameTag`/`deleteTag`/`applyTag`/
`removeTag`; `allTags`/`postTags`/`observeTags`), references
(`addReference`/`removeReference`; `Queries.references`), scraps
(`createPool`/`newBlock`; `pools`/`poolListing`/`observePools`/
`observePool`), sort (`observeLibrary(sort:)` — the parameter was
there all along), stars (`setStarred`/`Queries.starred` — 13f W4's
mechanism, found in code as the brief instructed). The four-suite
duty therefore never fired; core / Mac / Mac-spine baselines stand
untouched by construction. Release build **SUCCEEDED** (the DEBUG
doors compile out). Per capability:

1. **TAGS — management crosses FULLY (`dcc06f9`; her ruling 2, its
   grounds recorded as a standing principle: "some people won't use
   the mac app at all").** *Door:* **"Manage Tags" in Settings** —
   placement justified as R52's letter mirrored (Settings is "tag
   management's real home" on the Mac; the phone keeps the one home
   rather than inventing a second). The manager sheet: browse the
   hierarchy indented in path order (parents before children by the
   materialized path's construction; full paths visible on nested
   rows — hierarchy stays surfaced, R45) · create root tags ("+ new
   tag") AND child tags ("New Child Tag…" on the row's long-press —
   her ruling's letter) · rename (the op's one-transaction subtree
   ripple) · **delete-with-subtree behind a confirm that NAMES THE
   CONSEQUENCE**: the pure `deleteConsequence` brain speaks the
   sub-tag count and that notes lose those tags ("Deleting “life”
   also deletes its 3 sub-tags — every note wearing any of them
   loses those tags. There is no undo for this.") — the consequence,
   never a platform, pinned in both arms. Refusals in phone words
   through one copy brain (duplicate path · invalid name · gone).
   Deliberate delta from the Mac, recorded: the MAC's own delete row
   fires with NO confirm — the phone adds one because the brief's
   letter demands the named consequence; one-way divergence in the
   phone's safer direction, not a fork of a brain.
2. **TAGS ON A NOTE (`f1f9f13`; "tag posts — full app functionality";
   the 13k K3 leaf-chip grammar).** *Door:* the masthead's SECOND
   identity line wears the note's tags as LEAF-only chips ("#goals
   #sea"; the door word "tags" when bare) — placement justified: the
   masthead is the phone's note-identity surface (the C2 books/date
   chips' own home), and a second line keeps four chips from
   crowding one. Tap → the tags sheet (LK4): apply by TYPING — the
   Mac N24 road mirrored exactly (deepest existing live prefix
   resolves; the missing remainder is CREATED through the standing
   ops, child tags included; the LEAF applies; one serialized runner
   turn so a racing duplicate refuses through the op's own guard;
   slash noise forgives, "/a//b/" is a/b; already-applied no-ops
   politely) — apply by suggestion (applied dropped, substring
   match, capped at 8 — the Mac `TagChipAdder` rule, pinned pure),
   remove with ✕ (this note only; the tag lives on). Chips show the
   leaf; the full path lives on the sheet's rows.
3. **REFERENCES — the "More info" list (`ff8e358`; her precision #3:
   see · add a URL · open; the side-by-side panel stays the ruled
   exclusion).** *Door:* the **"more info" chip** beside the tags
   chip (her own name for the surface; the count rides the word —
   "more info · 2"). The sheet: rows in panel order (`position, id`
   — the Mac panel's own); URL rows are DOORS (open in the system
   browser; named by host; bare hosts normalize to https — the Mac
   `addURL` brain extracted pure and pinned); **FILE rows list
   honestly in neutral words** — "A file stays on the device where
   it was added — only its name travels here." (the model fact:
   `file_bookmark` is LOCAL-ONLY, AppSpec §7; NO platform named,
   pinned) — and open nothing (`openableURL` nil by kind: there is
   no file here to open, so no refusal is invented); "+ add a link"
   (alert; unloadable strings refuse in phone words and mint
   nothing; blank is a quiet no-op); remove on the row's long-press
   (PC3-2 below — one step beyond the letter, no-redirect-grounded).
4. **SCRAPS — view + mint (`9b3fc6a`; her precision #1).** *Door:*
   the Library's THIRD filter — **All · Bookless · Scraps** —
   justified: the Library is everything, the bookless filter is
   already the Pool's phone home, and standalone blocks are the
   pool family's other half; no new tab, no new place. The view:
   scraps in pointer order (the pool renders as a container — one
   traversal) with block tags DISPLAYED leaf-first (display only —
   block-tag editing stays Mac-side, her ruling 3); several pools
   all REACHABLE through a picker rendered only when several exist,
   oldest the default (the Mac N19 lesson carried, not relearned).
   The mint: "+ new scrap" → ONE standalone block via the Mac entry
   bar's exact composition (`createPool(title: "Pool")` when none
   exists — byte-mirrored, including the stored title — then
   `newBlock`); blank text is a quiet no-op. The drag-into-note
   door stays not-owed (the ruled exclusion, untouched).
5. **THE LIBRARY SORT PICKER (`9ecaaa5`; her ruling 9).** *Door:* the
   filter row's trailing **sort menu** ("sort: last touched"),
   rendered on the ALL filter only — bookless keeps the core
   query's own order and scraps are pointer-ordered, so a sort door
   there could never mean what it says (P-2: not rendered). The
   vocabulary is the brief's four words over the core `LibrarySort`'s
   own stamp expressions — **entry date · created · last touched ·
   last meaningful edit** (the 80%-sort's stamp) — newest first,
   last-touched the standing default. A way of LOOKING: `setSort`
   writes nothing; the view's `.task(id: sort)` restarts the held
   observation (the A31 restart shape).
6. **STARS (`27c06ad`; her ruling 10).** *The mechanism, found IN
   CODE and reused through core as the brief instructed:* 13f W4's
   synced `'starred'` setting list — `Operations.setStarred` (append
   order, the honest 5-cap, every write self-heals) + `Queries.
   starred` (the one live-targets read) + `StarTarget` (`post:`/
   `reading:` keys); ZERO schema, the shelf_pins class. *The act:*
   long-press **Star/Unstar** on shelf book rows (deliberately
   beside Pin — the Mac 13f adjacency: pinning orders THIS list, a
   star lifts the thing to the top section) and on Library note
   rows; state-mirroring words (the Mac `StarCopy`'s own). *The
   face (the brief's your-call, PROVISIONAL PC3-4):* **the starred
   section at the SHELF's top** — the Mac's sidebar-top placement
   mirrored onto the phone's home surface; rendered only when
   anything is starred; rows navigate (book → contents, note → its
   page; the route brain pinned) and un-star on long-press. *The
   cap refuses in PHONE words* — "un-star one in the starred list
   at the top of the shelf" (never "sidebar", never "Mac"; pinned)
   — and evicts nothing. *Names ride the ONE DisplayTitle chain*
   (the C2 doctrine): an untitled star reads its created day via a
   bounded ≤5-point-read resolution through `containerHeader` —
   `StarredItem.name` alone would render it blank.

**Tutorial-as-spec, held per owning commit:** the pocket guide's
getting-around lesson grew a sentence/paragraph in the SAME commit as
each door — the Settings sentence (tag management) · the masthead
paragraph (tags + more info, one second-line paragraph) · the Library
paragraph (the sort door + the scraps filter) · the shelf paragraph
(stars). No new lesson (the C2 precedent — the 13-lesson counts stay
pinned); no walk pins prose (PB1-3); the shape suites re-ran green in
the full run below.

**The refusal inventory's C3 rows: NONE EXIST — verified, not
assumed.** The inventory's fifteen rows are C2's (dissolved), C4's
(locked/archived-take, #1/#3/#6/#11–14 — the takes/locks family),
and C5's (the merge ceremony #4 + PB1-4's lesson rider); no row was
assigned to C3 and none of C3's surfaces carried a Mac-naming
string. The batch's own guarantee instead: **zero NEW user-facing
"Mac" strings** (grep over the whole diff's added lines — no hit),
and three refusal/consequence strings are pinned platform-free
(the delete-tag consequence, the file-row sentence, the star cap).

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2
simulator):**
- Full mobile suite: **"Test run with 262 tests in 48 suites
  passed"** — the 246/42 baseline + this batch's 16 tests and 6
  suites, exactly accounted (`MobileTagManagerTests` 3 ·
  `MobileNoteTagsTests` 2 · `MobileReferencesTests` 3 ·
  `MobileScrapsTests` 3 · `MobileLibrarySortTests` 2 ·
  `MobileStarsTests` 3).
- Mobile spine by its seven type names: **"Test run with 32 tests in
  7 suites passed"**.
- Perf suites by name (`MobilePerfFixtureTests` ·
  `MobilePerfWalkTests`): **"Test run with 9 tests in 2 suites
  passed"**.
- Core / Mac / Mac-spine deliberately not run: zero core, zero
  `Shared/`, zero Mac-side lines in the whole batch — the
  only-if-shared condition never fired; baselines stand (core
  1214/128 · Mac 1245/219 tripwire-only · Mac spine 51/7).
- Release build: **BUILD SUCCEEDED**.

**Test posture:** every new door landed with state-transition tests
through its view model against a real in-memory store (birth pins —
the doors did not exist on the old tree, the A2 reading of
red-on-old); no defect-class fix arose, so no behavioral-revert pin
was owed. Every act's store consequence is asserted through core
queries or raw SQL (star order as the stored JSON; tombstones as
tombstones; the mint's exact rows).

**PROVISIONALs (for the chain's end bundle):**
- **PC3-1 — the masthead's second identity line** (tags · more info
  under books · date): two rows read calmer than four chips on one;
  her look round may re-arrange (one-line moves).
- **PC3-2 — references REMOVE ships beyond the letter** ("see, add,
  open"): a row the phone can add it must be able to take back —
  an add-only surface would send its own typos to the Mac, the
  no-redirect smell. Long-press, destructive-roled.
- **PC3-3 — the phone's delete-tag confirm** (the Mac's own delete
  row fires without one): the brief's named-consequence requirement
  implies a confirm surface; recorded as deliberate one-way
  divergence, hers to flip either way.
- **PC3-4 — the starred face's home** (the brief's your-call): the
  shelf-top section, the Mac's sidebar-top mirrored; a Library
  filter or a smaller face are cheap moves if her look prefers.
- **PC3-5 — door words for her look:** "Manage Tags" · "tags" /
  "more info" chip words · "Scraps" / "+ new scrap" · "sort: …" ·
  "★ starred" / "Star"/"Unstar" — all pinned statics, one-line
  changes each.
- **PC3-6 — search hits on pool scraps still render no row** (the
  standing S3 filter): the scraps view exists now, but a hit can't
  scroll-to/highlight a scrap, and a row that lands you at the top
  of a list is a half-door; recorded rather than half-built. One
  routing line away if ruled wanted.

**Deliberate absences (scope, not holes):** block-tag EDITING
(her ruling 3 — Mac-side; scrap rows display leafs only) · the
scraps drag-into-note door (the ruled exclusion) · a references
file-ADD door (no phone file picker owed; URL is the ruled add) ·
the reference side-by-side panel (excluded) · sort on bookless/
scraps (each keeps its own honest order; the door isn't rendered
there) · a star door on the open note's masthead (the Library row
is the phone's row surface; one line if her look wants it) · the
locked-take/merge-ceremony refusal strings untouched (C4/C5's
families, incl. PB1-4's lesson rider).

## Stage C, batch C3 — ACCEPTED; the C3 LADDER OPENS (architect, 2026-08-09)

Verified: all seven commits present; scope clean by own check
(17 files, ALL mobile — zero core/Shared/Mac/schema/Sync; the
four-suite duty never fired, correctly); the full mobile suite
re-run by the architect's own hand: **"Test run with 262 tests in
48 suites passed"** — 246/42 + 16/6, exactly accounted. The stars
mechanism reuses the Mac's 13f storage through core (zero schema);
tag deletion's confirm names the CONSEQUENCE platform-free; the file
-reference copy is honest-neutral as briefed. **PC3-1…PC3-6 ride the
end bundle.**

**THE C3 LADDER OPENS.** Target: `ad4fbcf..9f12f2b`. Fresh cold
reviewer, `notes/REVIEW_PROMPT.md` VERBATIM; findings repo-first as
"## Stage C review — C3 round 1 findings". Baselines at open:
**mobile 262/48 · mobile spine 32/7 · perf 9/2 · core 1214/128 ·
Mac 1245/219 tripwire-only · Mac spine 51/7.**

## Stage C review — C3 round 1 findings (cold reviewer, 2026-08-09)

**Method.** Cold, zero implementation context. Read: `CLAUDE.md`;
`notes/MobileSoul.md` in full; this plan's PARITY MATRIX (the
tags/references/scraps/Library/misc families and their citations), the
MID-CHAIN SITTING's rulings 2/3/9/10, the C3 brief, batch record, and
acceptance; the refusal-copy inventory; AppSpec §7 (`reference`,
`setting`, tags) and §9 (tag ops). The full diff `ad4fbcf..c2602d8`
read file by file (all five new sources, all six modified sources, all
five test files), plus every core mechanism the batch claims to reuse,
read in core and on the Mac side: `Operations+Appearance.setStarred` /
`Queries.starred` / `StarTarget` vs the Mac `StarsModel`/`StarCopy`;
`Operations+Tag` (createTag/renameTag/deleteTag/applyTag/removeTag) and
`TagQueries` vs `TagsViewModel`/`TagAssignmentViewModel`/`TagChipAdder`;
`Operations+Reference`/`ReferenceQueries` vs `ReferencesViewModel.addURL`;
`PoolAndTray`/`Observations` vs `PoolViewModel` + `BlocksAreaView.submit`;
`Timeline.LibrarySort`/`observeLibrary`. No fixes made. No "Review foci"
section exists for this project; the spawn prompt's named checks are
each answered below (findings or clean bill).

### Findings

**MINOR C3-R1-1 ·
`App/Variorum/VariorumMobile/Features/Shell/MobileTagManager.swift:188–189`
— the manager's empty state teaches a road its own door refuses.** The
hint reads *"No tags yet — + new tag starts the taxonomy; “/” nests
(life/goals)."* — but the one door that empty state offers (`+ new
tag`) routes `MobileTagsModel.create` → `ops.createTag(name:)`, which
REFUSES any name containing "/"
(`Sources/VariorumCore/Operations/Operations+Tag.swift:15–17`,
`invalidTagName`). Mechanism: fresh store → Settings → Manage Tags →
the hint invites typing "life/goals" into the create alert → "Tag
names can't be empty or contain “/”." The typed-path road exists only
on the NOTE-tags sheet (`applyTypedPath`), which this sheet does not
have; the Mac manager's own empty state promises nothing ("No tags
yet." — `AppSettingsView.swift:244`). *Fix:* reword the hint to the
doors that exist (create a root, then "New Child Tag…" on its
long-press) or give the create alert the typed-path walk. Copy-class —
a string pin, no red-on-old owed beyond it.

**MINOR C3-R1-2 ·
`App/Variorum/VariorumMobile/Features/Write/MobileReferences.swift:216–250`
(with the brains at 68–81) — an unopenable URL row renders wearing the
FILE row's honest sentence, which is then false.** The row view
branches on `openableURL(reference) != nil`; the else arm shows
`fileRowNote` ("A file stays on the device where it was added — only
its name travels here"). `openableURL` returns nil for `kind == .url`
whenever `reference.url` is nil or `URL(string:)` rejects it — and
that state is constructible today: `addReference(to:kind:.url,
name:"x", url:nil)` is legal core (`Operations+Reference.swift:10–29`
validates nothing about the kind/url pairing), and a synced row can
carry it. `rowTitle` then labels the row "link" while the sentence
beneath calls it a file — incoherent copy on the batch's own
honesty-focused surface. *Fix:* key the honest sentence on
`reference.kind == .file` (an unparseable URL row wants its own words,
or a plain non-door row with no sentence); make the branch a pure
row-kind brain so it pins — the branch living only in the view is part
of the smell.

**MINOR C3-R1-3 ·
`App/Variorum/VariorumMobile/Features/Shell/MobileScraps.swift:184–199`
— the scraps rows are the phone's one non-lazy listing.** The
section's `ForEach` sits inside a plain `VStack`, and the parent
`LazyVStack` (`MobileLibraryView.swift:35–41`) cannot help:
`MobileScrapsSection` is ONE lazy child, so its whole interior
materializes the moment the Scraps filter shows. The Mac's own
parallel is lazy (`BlocksAreaView.swift:49–51` — ScrollView →
LazyVStack → ForEach over the same `PoolItem`s), and the held
`observePool` fetch is already unbounded (core's standing pool shape),
so at pool scale the phone pays full-row view construction plus a full
re-render per observation delivery — the class MobileSoul §2 bans
("every list windowed"; memory is the phone's own bar). No wrong
behavior at today's scrap counts; a hazard that grows with her pool.
*Fix:* restructure so the rows land in a lazy container (the section
emits rows into the outer LazyVStack context, or carries its own
ScrollView-level laziness as the Mac does).

**MINOR C3-R1-4 ·
`MobileNoteTags.swift:58–143` / `MobileScraps.swift:50–121` /
`MobileTagManager.swift:77–118` / `MobileReferences.swift:58–64` — the
batch's brains are byte-copies of Mac app-local code with no debt
record; MobileSoul §3 names this the drift class.** The typed-path
resolution walk (token-for-token `TagAssignmentViewModel.
applyTypedPath`), the suggestion rule (=`TagChipAdder.suggestions`),
the refusal-copy switch (=`TagsViewModel.message`), `depth(of:)`
(=`TagsViewModel.depth`), the pool observation shape + `activePool`
rule (=`PoolViewModel`), and the URL normalization
(=`ReferencesViewModel.addURL`'s inline logic) now exist twice, in two
app targets, with independent pins. MobileSoul §3: *"mobile never
forks a brain"* — and for Mac-side brains in app-local code, *"the Mac
phase should hoist the brain, or the ledger row records the debt
explicitly."* The batch records neither. What concretely degrades: a
13e-class Mac change to the typed road, the suggestion cap, or the
normalization lands in one copy and the platforms silently diverge on
a behavior promised to be ONE road (the C2-R1-2 drift class, realized
across platforms instead of surfaces). Architectural — no test pin
owed; the honest fix is a recorded debt row (parity ledger or a
PROVISIONAL naming the duplicated brains); hoisting to `Shared/` fires
the four-suite duty and is a later batch's deliberate call, not a
review fix.

**NIT C3-R1-5 · `MobileReferences.swift:252–258` + the PC3-2 record —
remove is offered on FILE rows, which PC3-2's own ground does not
cover.** The justification is "a row the phone can add it must be able
to take back" — but the phone cannot add a file reference, and
removing one tombstones the Mac's bookmark row through sync with no
restore door anywhere. Defensible (her data, an existing op, the Mac
panel also removes without confirm) — but the PROVISIONAL's wording
should cover the file arm, or the menu should omit Remove there.

**NIT C3-R1-6 ·
`App/Variorum/VariorumMobileTests/MobileLibraryTests.swift:287–295` —
`theSortVocabularyIsPinned`'s doc comment claims "and the no-op flip"
but no assertion exercises `setSort`'s same-value guard.** Comment or
assertion; one line either way.

**NIT C3-R1-7 · `MobileShelfView.swift:73–78` +
`MobileLibraryView.swift:55–63` — star refusals render on BOTH tab
roots at once and never clear passively.** `lastError` is one field on
the one shared model, and both roots render it: a cap refusal fired
from a Library note row also sits waiting at the shelf's bottom (and
vice versa), until some later toggle succeeds. The "spoken where the
door fired" comments overstate. Cosmetic.

**NIT C3-R1-8 (SPECULATIVE) · `MobileScraps.swift:106–121` — the
nested pool-items observation may outlive the surface.** `start()`'s
cancellation arm cancels `itemsTask` only via `catch is
CancellationError`; if GRDB's `AsyncValueObservation` iteration ends
by RETURNING (not throwing) when the section's `.task` cancels, the
unstructured `itemsTask` (holding `session`; the model is shell-owned
and app-long) keeps the unbounded pool render re-fetching at write
rate after the user leaves the Scraps filter. Byte-identical to the
Mac `PoolViewModel`, so parity holds either way; SPECULATIVE because
the cancellation path's throw-vs-return behavior was not traced into
GRDB.

### Clean bill (load-bearing things specifically checked and found solid)

- **Zero `Sources/VariorumCore/`, zero `App/Variorum/Shared/`, zero
  Mac-side, zero schema, zero `Sync/`, zero pbxproj** — verified by own
  `git diff --name-only ad4fbcf..c2602d8`: 17 files, all
  `VariorumMobile`(+Tests) + this plan file. The small-Queries
  allowance never fired — every read and act pre-existed, verified per
  symbol in core: `createTag`/`renameTag`/`deleteTag`/`applyTag`/
  `removeTag`; `allTags`/`postTags`/`observeTags` (all live-only);
  `addReference`/`removeReference`/`Queries.references`; `createPool`/
  `newBlock`/`pools`/`poolListing`/`observePools`/`observePool`;
  `observeLibrary(sort:)` — the parameter existed since Phase 10;
  `setStarred`/`Queries.starred`/`StarTarget`/`starLimitReached`.
- **Stars: the mechanism IS the Mac's own, and nothing new syncs
  incoherently.** The phone model mirrors `StarsModel` (same core
  write — append order, cap-refuses-not-evicts, every-write self-heal;
  same one read rule — live targets only, bounded by the cap), the
  door words are `StarCopy`'s, and the stored value is ids-only
  (`post:`/`reading:` keys under the `'starred'` setting) — plain
  metadata CAS, ZERO schema, consistent with the 14b `setting.value`
  PLAIN fence (no user-authored prose; the `shelf_pins` class
  exactly). The store-truth test asserts the exact stored JSON; the
  cap test proves refusal + no eviction + phone wording (never
  "sidebar", never "Mac").
- **The delete-with-subtree consequence counts the SUBTREE, not direct
  children.** `subtreeCount` counts all live descendants by path
  prefix — the same live-only prefix rule `deleteTag`'s SQL applies
  (`substr(path,1,N) = prefix AND deleted_at IS NULL`) — and the
  test's fixture is two levels deep (goals + 2026 under life = 2), so
  the depth claim is proven, not assumed. The act's tombstones are
  exact (3 dead tag rows, S2; the sibling's application survives);
  both confirm arms pinned platform-free. "There is no undo for this"
  is honest: no restoreTag op exists and structural undo excludes
  tags.
- **renameTag's ripple routes the SAME core op as the Mac** (the
  one-transaction subtree path rewrite, `Operations+Tag.swift:35–71`),
  proven through the phone door across three path depths.
- **The typed-tag road is token-identical to the Mac N24 brain**
  (deepest-live-prefix resolution → creates + leaf-apply in one
  serialized runner turn → `alreadyTagged` no-op; slash noise
  forgiven), proven end-to-end including leaf-only application and the
  empty-type refusal in phone words.
- **The file-reference copy is honest-neutral as claimed** — the
  sentence states the model fact (`file_bookmark` LOCAL-ONLY, AppSpec
  §7) and names no platform, pinned; file rows open nothing with no
  invented refusal. (C3-R1-2 is the URL-row arm of that branch, not
  the file arm.)
- **addURL is the Mac's exact normalization** (trim → "://" check →
  https prefix → URL + host guard, named by host), refusals in phone
  words, blank a quiet no-op, unloadable mints nothing — all pinned;
  rows list in the panel's own `(position, id)` order.
- **The scrap mint is byte-mirrored against `BlocksAreaView.submit`,
  including the fine grain:** both trim only for the emptiness guard
  and mint the UNTRIMMED text; `createPool(title: "Pool")` only when
  none exists; the mint lands in the ACTIVE pool; oldest-first
  default; pool-created-once with exact rows (2 placements, 2 live
  variants — I10 at birth) all pinned.
- **The sort picker is read-only as claimed**: `setSort` flips a
  session property — no op call, no setting write, nothing persisted;
  the four words map onto the core `LibrarySort`'s own COALESCE stamp
  expressions (nothing invented); rendered on ALL only, where the
  other filters' orders would make the door a lie (P-2); the
  `.task(id:)` restart contract is mirrored in the store-truth test
  across three stamps.
- **The starred face behaves**: renders only when non-empty; rows
  navigate (book → contents, note → page, focus false); names ride the
  ONE DisplayTitle chain with the untitled-star arm proven against a
  created-day expectation (`StarredItem.name` alone would render
  blank — the C2-R1-2 fix's `containerHeader.createdAt` carrying it).
- **Zero new user-facing "Mac" strings** — my own grep over the diff's
  added lines: no hit; the batch's three sensitive strings (delete
  consequence, file sentence, star cap) each pinned platform-free.
- **Tutorial-as-spec held per owning commit** — all six door commits
  touch `MobileTutorialSeeder.swift` (verified by per-commit log); no
  new lesson; the shape suites ride the green full run.
- **The refusal inventory owns no C3 rows** — re-walked the fifteen:
  C2's are dissolved, the rest name C4/C5/PL-3; none was C3's.
- Noted, not a finding: the manager's `ORDER BY path` listing can
  interleave an unrelated root between a parent and its indented child
  (`"a"`, `"a-b"`, then `"a/x"` at depth 1 — '-' sorts before '/') —
  the Mac manager renders the identical order with the identical depth
  rule, so the phone mirrors rather than forks; the nested rows'
  visible full paths carry the truth.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator; core from the repo root)

- Full mobile suite: **262 tests, 262 passed, 0 failed — TEST
  SUCCEEDED** (xcresult totals; the 246/42 baseline + the batch's 16/6
  exactly: TagManager 3 · NoteTags 2 · References 3 · Scraps 3 ·
  LibrarySort 2 · Stars 3).
- Mobile spine by its seven suite type names: **"Test run with 32
  tests in 7 suites passed"** — TEST SUCCEEDED.
- Perf by name (`MobilePerfFixtureTests` · `MobilePerfWalkTests`):
  **"Test run with 9 tests in 2 suites passed"** — TEST SUCCEEDED.
- Core: **"Test run with 1214 tests in 128 suites passed"** — the
  baseline exact.
- Mac suite/spine deliberately not run: zero Mac-side and zero
  `Shared/` lines in the diff (verified); the recorded 1245/219
  tripwire-only + 51/7 baselines stand.

## Stage C review — C3 round 1 ADJUDICATION (architect, 2026-08-09; the fix session spawns on this record)

No BLOCKER/MAJOR. Dispositions:

- **MINOR C3-R1-1 → FIX-C3a:** the manager's `+ new tag` gains the
  SAME typed-path road the note-tags sheet already has (one create
  rule everywhere — the hint then teaches a road its door walks);
  never fix the hint by deleting the promise (fire-and-DO).
- **MINOR C3-R1-2 → FIX-C3b:** the references row branches on
  `kind == .file`; an unopenable URL row gets its own honest state
  (stored text shown, no door, no file sentence). Pin the false-copy
  case red-on-old.
- **MINOR C3-R1-3 → FIX-C3c:** the scraps listing goes lazy AND
  windowed with the standing probe+marker discipline (the P32
  truncation grammar; MobileSoul §2's bar names the hazard). The
  window size mirrors the other mobile lists'.
- **MINOR C3-R1-4 → RECORDED with an owner** (this commit):
  `notes/KnownIssuesAndTechDebt.md` gains the six-copied-brains row,
  owned by the mobile project row (a post-chain mobile batch hoists;
  any Mac phase touching one hoists THEN). The soul doc's rule
  executed to the letter — the debt is explicit, not silent.
- **NIT C3-R1-5 → stands as PC3-2** (already a recorded PROVISIONAL,
  no-redirect-grounded; her bundle rules it).
- **NIT C3-R1-6 → FIX-C3d:** the sort-test doc comment either gains
  its claimed no-op-flip pin or loses the claim — whichever the
  five-minute truth is.
- **NIT C3-R1-7 → ROUTED to Stage D's polish pass** (the star
  refusal's display cadence is look-round material; recorded).
- **NIT C3-R1-8 (SPECULATIVE) → record-only** (Mac-identical either
  way; the pin-first rule would spend more than the risk).

## Stage C review — C3 round 1 FIX-PASS RECORD (fix session, 2026-08-09)

All four adjudicated fixes executed, one commit each, in order:
FIX-C3a `e62a116` · FIX-C3b `50405b7` · FIX-C3c `a30510e` · FIX-C3d
`f3a131d` (+ this record). Diff scope across the whole fix set,
verified by own `git diff --name-only 164a53d..HEAD`: **nine files,
ALL mobile app + mobile tests — zero `Sources/VariorumCore/`, zero
`App/Variorum/Shared/`, zero Mac-side files, zero schema, zero
`Sync/`, zero pbxproj** (the STOP condition never fired;
core/Mac/Mac-spine baselines stand — 1214/128 · 1245/219
tripwire-only · 51/7).

**FIX-C3a (the manager's + new tag walks the typed-path road — ONE
create rule everywhere) — BUILT, revert-verified.** *Trace:* the
manager's `+ new tag` routed the raw string to `createTag`, whose own
guard refuses any "/" (`invalidTagName`) — while the empty-state hint
promised "“/” nests (life/goals)"; the typed-path walk lived only on
the note-tags sheet. *The fix's shape — reuse, never a third copy
(the six-copied-brains row's anti-pattern, avoided at its worst
form):* the walk's three parts hoisted INTO `MobileTagsModel` (the
tags family's standing copy-brain home) as the ONE typed-path brain —
`typedSegments` (slash noise forgives, pure) · `typedPathPlan`
(deepest-existing-live-prefix resolution → `TypedPathPlan`, pure) ·
`createMissing` (the create-on-the-way half, run INSIDE one
serialized runner turn so a racing duplicate refuses through the
op's own guard) · the shared `emptyTypedPathMessage`. The note-tags
sheet's `applyTypedPath` REFACTORED ONTO the brain — its apply half
and its one-turn create+apply composition byte-identical (its
standing pins green untouched); the manager's new `createTypedPath`
walks the same brain, refuses a fully-existing path as the duplicate
it is (the standing sentence, one copy brain), and speaks the shared
hint on an empty type. The empty-state hint hoisted to the pinned
`MobileTagManagerSheet.emptyStateHint` (the C2-R1-1 hoist doctrine)
— it now teaches a road its own door walks; the root create alert's
message names the nesting ("“/” nests (life/goals) — missing parents
are created on the way."). The child-tag door ("New Child Tag…")
deliberately keeps single-NAME semantics — its alert frames "A child
of “X”" and prompts a Name; extending typed paths under a parent was
not the adjudication's letter and is one call away if her look wants
it (recorded, not provisional — the hint's promise concerns the door
it sits beside). *Pin:*
`MobileTagManagerTests/theNewTagDoorWalksTypedPaths` — hierarchy
created on the way · partly-existing path creates only the tail with
slash noise forgiven · fully-existing path refuses with the standing
sentence, nothing minted · the shared empty hint · the hoisted
promise pinned beside the door that keeps it. *Revert verification:*
the pre-fix raw-to-`createTag` door restored inside
`createTypedPath` → the pin fails with **8 issues** (the traced
refusal "Tag names can't be empty or contain “/”." and zero tags
minted), all 5 suite siblings green; fix restored → 6/2 green.

**FIX-C3b (reference rows branch on the STORED KIND; the unopenable
link's own honest state) — BUILT, revert-verified.** *Trace
(the reviewer's, re-verified in code):* the row view branched on
`openableURL != nil` — a `.url` row with nil/unparseable url (legal
core: `addReference` validates nothing about the kind/url pairing; a
synced row can carry it) fell into the else arm wearing the FILE
row's sentence, titled "link" above words calling it a file. *Fix:*
the branch left the view for a pure row-kind brain —
`MobileReferencesModel.RowState` (`opens(URL)` · `file` ·
`unopenableLink`), keyed `kind == .file` FIRST, so the file sentence
has exactly one home; the view switches on it. The unopenable link's
own state: its STORED text shows (`rowTitle` — name, else url, else
"link"), plain ink, no door, no sentence; remove stays on the
long-press (all three states — PC3-2's standing scope). The
loadable-link door and the file arm render byte-identically to
before. *Pin:*
`MobileReferencesTests/anUnopenableURLRowNeverWearsTheFileSentence`
— a nil-url `.url` row classifies `.unopenableLink` with its stored
text; the good link stays `.opens`; `.file` is the sentence's only
home. *Revert verification:* the pre-fix openable-else-file branch
mirrored into the brain → the pin fails with **1 issue**
(`rowState(broken) → .file` — the false copy, recorded in the pin's
own message), 3 siblings green; fix restored → 4/1 green.

**FIX-C3c (the scraps listing goes LAZY and WINDOWED) — BUILT,
revert-verified on the window half.** *The window (MobileSoul §2's
bar):* `MobileScrapsModel` gains `window` (default **200 — the
Library filter neighbor's own `listingLimit`**, the mirror the
adjudication named; the book list's 300 is the reading surface's),
applied through ONE `adopt` rule shared by BOTH delivery roads (the
`observePool` loop and the headless `refresh`), with `truncated`
beside it. *The marker (P32's grammar):*
`MobileScrapsModel.truncationMarker(shown:)` — "Showing the first N
scraps — the rest aren't loaded yet." — neutral, never a platform,
rendered under the rows when the window cuts. *The probe
discipline's contract, held by construction and PINNED:* the
standing core pool read carries no limit (bounding the FETCH is a
core seam — the zero-core mandate; recorded, matching the round-1
finding's own "core's standing pool shape" reading), so the delivery
is whole and `count > window` is exact truth — an exact-window pool
can never false-positive the marker (the probe row's whole job,
satisfied without one; asserted in the pin's second arm). *The lazy
half:* `MobileScrapsSection.body` flattens to `@ViewBuilder` content
— no wrapping VStack — so the rows land in the Library's own
LazyVStack context and materialize lazily (the round-1 mechanism:
the plain VStack made the whole interior ONE lazy child). The
observation's lifecycle moves to stable chrome —
`MobileLibraryView`'s `.task(id: model.filter)` runs `scraps.start()`
while the Scraps filter shows and cancels when it leaves (the old
section-task lifecycle exactly; a task must never live on a lazy row
that can scroll away) — and the mint alert rides its own door (an
alert presents modally; the attachment point governs lifetime only).
The SwiftUI row-level laziness itself is the recorded
not-headless-testable class (the A1-masthead precedent) — the
structural change is the fix, the window is the pinned floor either
way. *Pin:*
`MobileScrapsTests/theScrapsListingWindowsWithTheTruncationMarker`
(window 4 to exercise the seam): past-window → exactly the window +
the marker, neutral; exact-window → all rows, NO marker. *Revert
verification:* the unwindowed pre-fix delivery restored in `adopt` →
the pin fails with **3 issues** (5 rows shown · `truncated` false ·
the marker sentence off-by-the-cut), 3 siblings green; fix restored
→ 4/1 green.

**FIX-C3d (the sort-test doc comment's claimed no-op-flip pin) — THE
PIN NOW EXISTS, and the five-minute truth ran deeper than the
claim.** `theSortVocabularyIsPinned` gains the assertion the comment
claimed: with observation tracking armed on `model.sort`, an
equal-value `setSort` wakes NO observer (so the view's
`.task(id: sort)` never restarts the listing observation) while a
real flip wakes it; `setSort` itself is byte-unchanged. *The
discovery, probe-verified both ways on iOS 26.2 (recorded here per
the hallucination guard — the probes were transient source edits,
restored):* **the silence is guaranteed TWICE.** With the model's
`guard next != sort` DROPPED, the equal-value write STILL woke
nothing — while a build-freshness probe writing a DIFFERENT value
through the same call fired the same registration (and failed the
ordering test, proving the toolchain rebuilt) — i.e. **the
@Observable macro on this SDK skips notification for equal-value
writes to Equatable properties.** A pin that passes on both sides of
the model's guard cannot claim to discriminate that guard: the pin
is therefore worded as the no-op-flip CONTRACT pin it is (the
behavior the doc comment promised — no restart on a same-value pick
— which the platform and the guard jointly hold), never a guard-line
discriminator. The doc comment now says exactly that, with the
measurement dated. *(A note for future mechanism pins in this repo:
equal-value writes to Equatable `@Observable` properties are
platform-deduped on iOS 26.2 — a same-style-object or
no-notification pin cannot use them to discriminate an app-level
equality guard.)*

**Suites (this session's own runs, the final tree, iPhone 17 Pro /
iOS 26.2 simulator):**
- Full mobile: **"Test run with 265 tests in 48 suites passed"** —
  the 262/48 ladder-open baseline + THREE pins (C3a · C3b · C3c),
  exactly accounted (C3d's assertions ride the existing vocabulary
  test).
- The mobile spine by its seven suite type names: **"Test run with
  32 tests in 7 suites passed"**.
- Perf by name (`MobilePerfFixtureTests` · `MobilePerfWalkTests`):
  **"Test run with 9 tests in 2 suites passed"**.
- Core / Mac / Mac-spine deliberately not run: zero core, zero
  `Shared/`, zero Mac-side lines in the fix set (the standing
  only-if-shared condition; the scope check above is the proof) —
  baselines stand (core 1214/128 · Mac 1245/219 tripwire-only ·
  Mac spine 51/7).

## Stage C — C3 fix set ACCEPTED; ROUND 2 OPENS (architect, 2026-08-09)

FIX-C3a…d verified: scope clean by own check (nine files, all
mobile), the full suite re-run by the architect's own hand —
**265/48 green** (262 + 3 pins, exact). C3a's hoist-not-third-copy
shape honored (the typed-path brain now lives ONCE in
`MobileTagsModel`, the note sheet refactored onto it — the copied-
brains row's anti-pattern avoided in the same ladder that recorded
it). C3d's @Observable equal-value-dedupe discovery accepted as
recorded (the pin words the CONTRACT, not a guard-line — the honesty
rule). **ROUND 2 OPENS:** fix-set diff `164a53d..2bcd070` inside
`ad4fbcf..2bcd070`; fresh reviewer; new BLOCKER/MAJOR ⇒ round 3.
Baselines: mobile 265/48 · spine 32/7 · perf 9/2 · core 1214/128 ·
Mac 1245/219 tripwire-only · Mac spine 51/7.

## Stage C review — C3 round 2 (fresh cold reviewer, 2026-08-09)

**Method.** Cold, zero fix-session context. Anchor read: the C3 round 1
findings · the ADJUDICATION · the FIX-PASS RECORD · the fix-set
acceptance. The fix-set diff `164a53d..2bcd070` read line by line (nine
files, all mobile — verified by own `git diff --name-only`: zero
`Sources/VariorumCore/`, zero `Shared/`, zero Mac-side, zero schema,
zero `Sync/`, zero pbxproj); every touched file then read WHOLE on the
final tree (`MobileTagManager` · `MobileNoteTags` · `MobileReferences`
· `MobileScraps` · `MobileLibraryView` + the four test files), plus the
core mechanisms the fixes lean on (`Queries.poolListing`/`observePool`
— confirmed unbounded; `MobileLibraryViewModel.setSort`/`listingLimit`)
and the adjudication's side-effects (the KnownIssues six-copied-brains
row at `164a53d` — present, owner named). A REAL pass, not a stamp: the
C3d platform claim was independently re-probed (below).

### Verdicts, per fix

**FIX-C3a — HOLD.** The typed-path brain lives ONCE
(`MobileTagsModel.typedSegments` / `TypedPathPlan` / `typedPathPlan` /
`createMissing` / `emptyTypedPathMessage`); own grep finds no leftover
copy of the walk anywhere in the mobile target. The note-tags sheet's
`applyTypedPath` is verified byte-equivalent through the hoist by
line-diff of the old inline walk against the hoisted brain (identical
resolution loop, identical `existingLeafID ?? parent` leaf rule,
identical one-serialized-turn create+apply composition — the turn
boundary itself is reading-verified, since no headless pin can see a
transaction seam) and the standing `MobileNoteTagsTests` pins DO
discriminate the walk's behavior surface: create sets, LEAF-only apply,
polite re-apply no-op (the `existingLeafID` road + `alreadyTagged`
catch), slash-noise forgiveness, and the exact empty-hint sentence
would each fail on a mis-hoist. The new pin discriminates the door: the
pre-fix raw-to-`createTag` route refuses any "/" at the op's own guard
and mints nothing — the pin's first two assertions fail there. Checked
deltas, all deliberate and sound: "///" and whitespace-only now speak
the shared hint instead of `invalidTagName` (the note sheet's own
sentences); a fully-existing path refuses with the standing duplicate
sentence BEFORE the runner turn, and the read-to-turn race still lands
on `createTag`'s own guard; a live-tombstoned path re-creates legally
(live-only read + live-scoped unique index — the tombstone-then-
recreate doctrine holds through the typed road). The child door's
kept single-NAME semantics match its own alert copy ("A child of
“X”." — no nesting promised there).

**FIX-C3b — HOLD.** `RowState` keys `kind == .file` FIRST
(`MobileReferences.swift:101–105`), so the file sentence has exactly
one home; the unopenable link's state shows stored text, no door, no
sentence; the `.opens` and `.file` view arms are byte-identical to the
pre-fix rendering; remove rides all three states (PC3-2's standing
scope). The pin discriminates: the pre-fix openable-else-file branch
mirrored into the brain returns `.file` for a nil-url `.url` row — the
pin's first assertion fails there. The pin's fixture builds the broken
row through legal core (`addReference` validates nothing about the
kind/url pairing — re-verified in `Operations+Reference`).

**FIX-C3c — HOLD.** The window lands at ONE `adopt` rule shared by
both delivery roads (`MobileScraps.swift:70–73`; the observation's
loop and `refresh` both call it; `restartItems` resets `truncated`
with `items`), the default 200 verifiably mirrors the Library
neighbor's own `listingLimit` (`MobileLibraryViewModel.swift:58`).
The by-construction probe claim VERIFIED IN CORE: `Queries.
poolListing` → `renderPost` carries no LIMIT and `observePool` wraps
it whole — the delivery is the whole pool, so `count > window` is
exact truth and the exact-window arm discriminates a `>=`-class false
positive. The pin discriminates the window (unwindowed adopt → 5 rows,
`truncated` false, marker off-by-the-cut). The lazy half is
structurally right: the flat `@ViewBuilder` body puts the `ForEach`
into the Library's own LazyVStack list context (the pre-fix VStack was
ONE lazy leaf), the observation's lifecycle moved to stable chrome
(`.task(id: model.filter)`) with cancellation semantics preserved, and
the mint alert rides its own door — the recorded not-headless-testable
class, accepted as recorded. One lifecycle nuance survives as R2-1
below.

**FIX-C3d — HOLD.** The claimed pin now exists as the no-op-flip
CONTRACT pin, honestly worded (it does not claim to discriminate the
guard line — the hallucination guard's own rule). The platform-dedupe
discovery was INDEPENDENTLY REPRODUCED by this reviewer's own
scratchpad probe on this toolchain (outside the repo, no source
edits): an equal-value write to an Equatable `@Observable` stored
property fires NO `withObservationTracking` onChange; a
different-value write fires it. The fix session's probe reasoning
reads true — and its build-freshness arm (a different-value write
through the same call firing while the guard was dropped) is exactly
the control that makes the equal-value silence evidence rather than a
stale build. The pin's construction is self-validating: if the
tracking registration had failed to arm, the second assertion
(real flip wakes it) would fail. `setSort` byte-unchanged, verified.

### New findings

**NIT C3-R2-1 · `MobileLibraryView.swift:76–78` +
`MobileScraps.swift:205–213` — the scraps observation now survives an
active SEARCH; the "exactly the old section-task lifecycle" comment
overstates by one window.** Pre-fix, the section's own `.task`
cancelled whenever `model.hits != nil` displaced the section from the
tree (the `if let hits` branch wins over the filter branch); post-fix
the task keys on `filter` alone, so while search hits show on the
Scraps filter, the whole-pool observation keeps re-fetching at write
rate (e.g. a sync apply landing mid-search) behind an invisible
surface. Cost-only, bounded, ends on filter/tab change; no wrong
behavior. Fix is one condition (`model.filter == .scraps && model.hits
== nil` as the task id's companion) or an honest comment.

**NIT C3-R2-2 · `MobileScraps.swift:170–200` + the window — at
>window scraps, a successful mint is invisible.** `mintScrap` lands
the new block at pointer-order END; `adopt` shows the first `window`
rows; so past 200 scraps the mint succeeds (field clears, `refresh`
runs) and no new row appears — only the marker's "the rest aren't
loaded yet" covers it, and the "+ new scrap" door sits directly under
that marker. Inherent consequence of the adjudicated windowing (the
Mac's unbounded list shows its mint; the phone's windowed one cannot),
not a defect: record-only for the look round — a courtesy candidate is
mint-time copy or scrolling the marker into view.

**NIT C3-R2-3 (doc, predates the fix set — recorded so the next
session doesn't trip it) · the C3 brief's spine pointer names the
MAC's suite types.** The brief (and the batch discipline) points at
"~line 767 of mobile-app-plan.md" for the mobile spine's seven TRUE
type names — but that note lists the MAC spine's `Tutorial*Tests`
names (51/7). The MOBILE spine's seven are `MobileWalkTests` + the six
`MobileTutorial*Tests` structs in `MobileTutorialWalkTests.swift`
(24+8 = 32/7). This reviewer's first spine invocation selected ZERO
tests off the Mac names — the exact trap the note itself warns about,
one indirection deeper. One-line doc fix at the next records edit.

### Clean bill (specifically checked, found solid)

- **Scope:** nine files, all mobile app + tests (own `git diff
  --name-only 164a53d..2bcd070`); zero core/Shared/Mac/schema/Sync/
  pbxproj — the STOP condition never fired; core/Mac baselines stand
  by construction.
- **The adjudication's non-fix dispositions landed:** the
  six-copied-brains KnownIssues row EXISTS at `164a53d` with a named
  owner (the mobile project row) — and remains ACCURATE post-C3a: the
  typed-path walk still lives twice ACROSS platforms (Mac
  `TagAssignmentViewModel` + `MobileTagsModel`); C3a removed only the
  would-be third in-target copy, exactly as the record claims. R1-5
  stands as PC3-2; R1-7 recorded for Stage D; R1-8 record-only.
- **Zero new user-facing "Mac" strings in the fix set** (own grep over
  added lines — one doc-comment "per-machine" only); the truncation
  marker, the shared empty hint, and the nesting alert message are all
  platform-free.
- **Fire-and-DO honored to the adjudication's letter:** the empty-state
  hint was hoisted and KEPT, and the door now walks the road it
  teaches — the promise was not deleted.
- **The hint/door drift is pinned on both sides:** the hoisted
  `emptyStateHint` static is asserted beside the door's typed-path pin.
- **`setSort`, `openableURL`, `rowTitle`, the `.opens`/`.file` render
  arms, and the note sheet's apply half:** byte-unchanged through the
  fix set, verified against the diff.
- **The C3d platform claim reproduced independently** (own probe, this
  toolchain): equal-value Equatable writes are observation-deduped.

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator)

- Full mobile suite: **"Test run with 265 tests in 48 suites passed"**
  — TEST SUCCEEDED (the 262/48 ladder-open baseline + the three fix
  pins, exactly accounted; C3d rides the existing vocabulary test).
- Mobile spine by its seven TRUE type names (`MobileWalkTests` + the
  six `MobileTutorial*`): **32/32 passed, 0 failed** (xcresult
  totals) — TEST SUCCEEDED.
- Perf by name (`MobilePerfFixtureTests` · `MobilePerfWalkTests`):
  **"Test run with 9 tests in 2 suites passed"** — TEST SUCCEEDED.
- Core / Mac / Mac-spine not run: zero core, zero `Shared/`, zero
  Mac-side lines in the fix set (own scope check); baselines stand
  (core 1214/128 · Mac 1245/219 tripwire-only · Mac spine 51/7).

**Verdict: all four fixes HOLD; no BLOCKER/MAJOR — no round 3 owed.**
Three NITs recorded above (one a pre-existing doc pointer), none
gating.

## Stage C — the C3 LADDER CLOSES at round 2 (architect, 2026-08-09); C4 OPENS

Round 2: all four HOLD (C3d's platform claim independently
reproduced by the reviewer's own probe); no BLOCKER/MAJOR. The three
NITs, dispositioned at the architect's hand: **R2-1** the scraps
observation surviving an active search is cost-only and now
RECORDED here (the lifecycle comment's one-window overstatement
noted; not worth a churn commit) · **R2-2** mint-past-window
visibility ROUTED to Stage D's look round (inherent to the
adjudicated windowing) · **R2-3** the spine-pointer confusion FIXED
by this record: **the MOBILE spine's seven suite type names are
`MobileWalkTests` · `MobileTutorialBookShapeTests` ·
`MobileTutorialDoorTests` · `MobileTutorialWritingWalkTests` ·
`MobileTutorialTakesWalkTests` · `MobileTutorialStructureWalkTests`
· `MobileTutorialLibraryWalkTests` (32/7); the MAC spine's seven
(51/7) are the `Tutorial*ActsTests` family listed at
mobile-app-plan.md ~line 767 — two different spines, never
interchangeable.** **C3 CLOSED.**

**C4 OPENS — split into TWO build sessions for session-size safety,
ONE ladder over the combined diff** (the family-granularity intent
holds; the split is purely the ~500k context-degradation rule
applied to a ten-item batch):

- **C4a — takes completeness + locks + history + S5:** take
  lock/unlock (the note seal's sibling; the SIX locked-take refusal
  strings dissolve here per the inventory) · archived-takes listing
  + unarchive · label take · the commit door + history face (with
  AppSpec §9's "this commit predates a split" warning class where
  the history shows one) · **the S5 conflict-discoverability
  verify + pin** (a conflict variant landing on the phone must be
  DISCOVERABLE — the takes badge its natural face).
- **C4b — the editor fill:** insert-block-below (the ⋯-menu row
  over the standing op) · the strike/code/link doors · find-in-note
  (TEXTKIT2 §3's crash-pairing care binds) · **extract + make-block
  on the selection menu** (her sitting ruling) · **the block-TOC
  in-note list** (her sitting ruling — block NAMES' phone face).

## Stage C, batch C4a brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at this commit. Scope: C4a's five items
above, the matrix's rows their spec (each cites its ruling).

**Read first, IN FULL:** `CLAUDE.md` (AppSpec §9's lock/archive/
commit entries are the op floor; SyncSpec §6's S5 is the conflict
row's law) · `notes/MobileSoul.md` (§5.3: offline is the phone's
NORMAL — the S5 check's why) · THIS plan file top to bottom (the
MATRIX's takes/locks/history rows · the refusal inventory's six
locked-take rows · PB1-4's neighbor note) · the Mac's takes/lock/
history faces in code · `notes/plans/mobile-architect-handoff.md`.
Environment traps bind; the MOBILE spine's seven names are in the
C3-close section directly above.

**The work:** every act through existing core ops (`lockVariant`/
`unlockVariant` — remember lock-insures-first is the OP's own
behavior · `archiveVariant`/the unarchive road · the label setter ·
`commit` + `Queries` history reads · `resolveSyncConflict` is
S5's landing, already core). The six locked-take strings dissolve
WITH their doors in the same commits (fire-and-DO). The S5 row is
VERIFY + PIN work: prove a conflict variant landing on this block
surfaces in the phone's badge/browser (the fan count road), and pin
it — if discovery genuinely fails, that is a FINDING (trace, fix if
mobile-side, STOP if core-side). Tutorial-as-spec: the takes lesson
grows where doors land. Small additive Queries legal with the
four-suite duty; `Operations/`/schema/`Sync/` STOPS.

**Discipline (standing):** synchronous; red-on-old for defect-class;
state-transition tests per door; no platform-named refusals. Full
mobile suite green by own run (from 265/48, arithmetic accounted) +
mobile spine 32/7 + perf 9/2 by name. Commit per logical unit with
the standing trailer; record as "## Stage C, batch C4a — BATCH
RECORD"; push. PROVISIONAL-and-continue; author-only calls stop.

## Stage C, batch C4a — BATCH RECORD (implementer, 2026-08-09; commits `c8f342e` · `597f8d6` · `d9a0e76` · `1c58e0c` · `572b057` · `dab4c03` · `e2fdd9d` + the record commit)

**All five work items shipped; the S5 verdict is GREEN (no finding).**
Diff scope, verified by own `git diff --name-only 36ab18d..HEAD`: 21
files — **two core** (`Queries/EditorSupport.swift` + its core test —
the sanctioned small-additive class, the four-suite duty fired), **one
Mac file** (`EditorViewModel.swift` — the CommitRules DELEGATION only,
behavior byte-identical), the rest mobile app + mobile tests. **Zero
`Sources/VariorumCore/Sync/`, zero `Persistence/` (no schema), zero
`Operations/`, zero `App/Variorum/Shared/`, zero pbxproj** (synchronized
groups took the four new files). Per item:

1. **TAKE LOCK/UNLOCK (`c8f342e`) — the note seal's sibling.** *Door:*
   a state-mirroring **Lock Take / Unlock Take** row on each browser
   card's ⋯ — placement justified: the card is the take's one identity
   surface on the phone (the Mac's own card-menu placement,
   WriteTakesPanel's ⋯), the row mirrors state per render (the seal
   glyph's one-reversible-tap grammar, menu-rowed), and the sheet is one
   ⑂ away from anywhere. *Ops:* `lockVariant`/`unlockVariant` — the
   lock-insures-first behavior is the OP's own (a dirty STORE buffer
   takes one quiet auto commit; I6's consequence-not-equivalence). *The
   door's own guard, traced before building:* the op's insurance can
   only commit what the STORE holds — pending SURFACE bytes live in the
   coordinator until a flush lands, so a blind lock would insure the
   STALE text and the later flush would refuse `.lockedVariant`,
   stranding the typed bytes pending forever (the A1 `lockNote` trace,
   the take's edition). So the lock road is **FLUSH-FIRST** with the
   standing refused-flush wording; unlock needs no flush (nothing about
   it reads a buffer, and a locked take admits no pending edits).
   *Mutation-checked by behavioral revert:* blind lock restored → **3
   issues** (stale store bytes · the insurance commit of the stale text
   · stranded pending), 3 siblings green; fix restored → green.
   *Tests:* `MobileTakeLockTests` (4) — the reversible flip with ZERO
   commits on a committed-clean buffer (I6 through the door) · the
   flush-guard pin · both seal arms in phone words · the copy pins.

2. **THE SIX LOCKED-TAKE REFUSALS DISSOLVE WITH THE DOOR (`c8f342e` —
   fire-and-DO: the doors land in the same commit as the copy).**
   Inventory **#1 · #3 · #6 · #11 · #12 · #13**, all six sites now
   phone-roaded through pinned statics that cannot fork:
   - `MobileEditorViewModel.lockedTakeRefusal` — *"This take is locked
     — branch it, or unlock it from its card in the takes sheet (⑂)."*
     — the page-level sentence (the VM's gate copy + BOTH
     `MobileStructural` sites route through the one static).
   - `MobileTakesBrowserController.lockedTakeCardRefusal` — *"This
     take is locked — unlock it from its card's ⋯, or branch it."* —
     the in-sheet pair (beginEditing + the card gate), where the door
     is one tap away on the same card.
   - `MobileTakesBrowserController.lockedTakeVerbRefusal` — *"That
     take is locked — unlock it from its card's ⋯ first."* — the verb
     arm (delete/branch reaching a locked take).
   Five standing pins flipped to the new copy (sanctioned, listed:
   MobileTakesBrowserTests ×3 · MobileTakesTests ×1 ·
   MobileStructuralTests ×1) + a no-"Mac" sweep pin over the statics
   and both refusal mappers.

3. **ARCHIVED-TAKES LISTING + UNARCHIVE (`597f8d6`) — dissolves
   inventory #14.** *Door:* the browser sheet lists the open block's
   archived takes below the live fan — an "archived · n" header +
   read-only cards (labels riding — the archived listing is exactly
   where a label identifies, the core op's own recorded rationale;
   read-only by the op's own rule: an archived buffer refuses edits),
   each card's ⋯ carrying **Unarchive Take** (the road back) and
   **Delete Take**. Placement justified: see-your-data says the road
   back lives where the fan lives (the Mac WriteTakesPanel's own
   section, phone-carded). *Ops:* `unarchiveVariant` / the standing
   `deleteVariant`; the listing is a direct `Queries.blockFan` read
   (archived filtered; cost ∝ the block's fan) — the controller takes
   the SESSION now (the comments controller's own shape; the one
   constructor updated). Reloads at open, after every verb, and on
   every projection ingest (a REMOTE archive lands live); clears at
   close. *Copy:* `archivedTakeRefusal` — *"That take is archived —
   unarchive it from the archived list below."* — pinned, no platform
   name; the S2-era "recovery surfaces stay Mac-side in v1" header
   absence dissolved with the doors (deleted-take RESURRECTION alone
   stays PL-3/13j's, with the trash family). *Tests:*
   `MobileArchivedTakesTests` (4) — the full round trip (archive →
   listed with label → unarchive → back in fan order) · the sealed
   refusal with viewing-stays-free · delete-from-the-listing · the
   copy pin.

4. **LABEL TAKE (`d9a0e76`).** *Door:* **Label Take…** on each card's
   ⋯ — live AND archived cards. *Ops:* `setTakeLabel` (trim-and-NULL
   clear; legal on a LOCKED take — identity metadata, not buffer — and
   on an ARCHIVED one; both the op's own recorded rules, pinned through
   the door). The prompt rides an injectable seam on the block menu's
   plumbing pattern (production UIAlertController installed at the VM's
   attach, prefilled with the STORED label; cancel is a true nothing;
   EMPTY is a real answer — the clear). *Tests:* `MobileTakeLabelTests`
   (2) — set/change/clear + locked + archived + the seam's prefill
   under the pinned words · the sealed refusal.

5. **THE COMMIT DOOR + THE TAKE-HISTORY FACE (`1c58e0c` core ·
   `572b057` phone) — AppSpec §9's deliberate-savepoint pillar reaches
   the phone.** *The core half, its own commit (the model-change
   convention):* `Queries.commitPredatesSplit` lands beside
   `splitDates` (additive; zero change to existing queries) and the
   Mac's app-local `CommitRules` DELEGATES to it byte-identically (the
   C2 `divergeForBook` relocation precedent; the Mac's own
   EditorSessionTests pin holds through the delegation) — ONE brain,
   both platforms, instead of a seventh row on the copied-brains
   KnownIssues ledger. Core test added. *The phone half:* the block ⋯
   gains **Commit Take** and **Take History…** — placement justified:
   the ⋯ is the phone's one block-acts home, and both act on the caret
   block's DISPLAYED (peek-aware) take, the Mac's caret-variant
   semantics exactly (⌘S commits the caret take; the CommitBar lists
   it) — flip/peek to a take and the doors follow it: per-take history
   through composition, one door per act. Commit is **FLUSH-FIRST**
   (the savepoint's whole job is the exact bytes she sees;
   mutation-checked by behavioral revert: flush dropped → **2 issues**
   — stale savepoint text + text left pending — 5 siblings green). The
   history sheet (`MobileTakeHistoryController` + the comments sheet's
   pixels pattern): rows newest-first — date · auto/manual ·
   **"predates a split"** through the one core predicate · preview ·
   per-row Restore. The PRE-SPLIT road **gates on the §9 warning**
   (*"This commit predates a split of this block — restoring it brings
   back text from before the split."*) via inspectable state
   (`pendingRestore` — the view presents the confirm; headless tests
   drive `restore(confirmed:)`), and restore is flush-first too (a
   pending flush landing after it would overwrite the restored text —
   the stale-flush class). Refusals in phone words; the locked-take arm
   rides the ONE standing sentence (commit and restore both reach the
   frozen buffer). Idle auto-commits already ran on the phone (shared
   `AppServices`) — the history face is where they become VISIBLE:
   see-your-data closes over machinery that was already writing.
   *Tutorial-as-spec, the lesson+walk rider executed:* blocks & typing
   grows the savepoint paragraph + the ⋯ enumeration, and the
   crystallize walk's staging count moves 4 → 5 in the SAME commit.
   *Tests:* `MobileTakeHistoryTests` (6) — the flush-first savepoint ·
   both refusal arms (incl. the seal's own insurance row, asserted as
   the SEAL's) · newest-first/kinds/flags on a real divide fixture ·
   restore + the confirm gate + the resurrected pre-split text ·
   restore-under-seal · the copy pins. The ⋯ drift pin flips through
   the shared `rowTitles` oracle (both doors' rows grew).

6. **THE S5 VERIFY + PIN (`dab4c03`) — VERDICT: GREEN, no finding.**
   *The mechanism, proven end to end rather than asserted:* the
   engine's reject merge lands the losing text through
   `resolveSyncConflict` — a fresh ACTIVE variant, label `'conflict'`,
   at the fan's end (S5: nothing clobbered). An active second variant
   makes the slot's `activeVariantCount` 2 → `hasFan` → **three
   discovery roads from one delivery**: the ⑂ BADGE renders on the
   laid-out surface (the natural face — asserted on a real
   `MobileWriteSurfaceView`, windowless), the swipe pill counts
   "take 1/2", and the browser's fan lists the conflict card WEARING
   its label, not chosen, the chosen pointer and text store-asserted
   untouched. The delivery arm drives exactly what the standing
   observation does (the fresh-read ingest as `fromDelivery`). *The
   sealed arm pinned too:* S5 outranks the seal (the op's documented
   rule — refusing would throw the losing text away), the landed
   conflict stays discoverable under it, viewing free while editing
   refuses with the sealed copy. `MobileConflictDiscoveryTests` (2);
   MobileSoul §5.3's standing acceptance item now has its executable
   form.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2
simulator; core from the repo root; Mac from `App/Variorum/`):**
- Full mobile suite: **"Test run with 283 tests in 53 suites passed"**
  — the 265/48 baseline + 18 tests + 5 suites, exactly accounted
  (lock 4 · archived 4 · label 2 · history 6 · S5 2).
- Mobile spine by its seven TRUE type names: **"Test run with 32 tests
  in 7 suites passed"** (one staging assertion updated in place — the
  lesson+walk rider; the count stands 32/7).
- Perf by name (`MobilePerfFixtureTests` · `MobilePerfWalkTests`):
  **"Test run with 9 tests in 2 suites passed"**.
- Core (`swift test`): **"Test run with 1215 tests in 128 suites
  passed"** — 1214 + the predicate test, exact.
- Mac spine by its seven TRUE type names: **"Test run with 51 tests in
  7 suites passed"**.
- Full Mac suite: **"Test run with 1245 tests in 219 suites failed …
  with 1 issue"** — the one issue re-confirmed BY IDENTITY as the
  standing `TakePaneMeasureTests.aStrandedRenderTierIsRebuiltByA
  ConvergenceOccasion` tripwire (the recorded 1245/219 tripwire-only
  baseline, exactly; the batch's Mac-side delta is the one-line
  CommitRules delegation, and the suite proves it inert).

**PROVISIONALs (for the chain's end bundle):**
- **PC4a-1 — the locked-take wording SPLIT by context:** one page-level
  sentence (names the takes sheet, ⑂) and one in-sheet pair (names the
  card's ⋯, one tap away) rather than a single sentence everywhere —
  the door-in-view principle read per surface; her look may unify.
- **PC4a-2 — the savepoint doors' words and home:** "Commit Take" /
  "Take History…" on the block ⋯, acting on the DISPLAYED take (the
  matrix row's "shape at the batch", decided as the Mac's caret-variant
  semantics + peek composition). A per-card history door in the browser
  was deliberately NOT added (one act, one door; peek covers per-take).
- **PC4a-3 — the history sheet's face:** the comments sheet's pattern
  (top 160, dim, done), row grammar date-`.abbreviated/.shortened` ·
  kind · flag · one-line preview · Restore, the empty-state sentence
  ("No savepoints yet — Commit Take in ⋯ keeps one."), flag ink =
  accent. All one-line changes for her look.
- **PC4a-4 — the archived section's face:** "archived · n" header +
  read-only two-line cards below the live fan, Delete offered beside
  Unarchive (the Mac archived card's second door). Her look may fold
  or re-arrange.
- **PC4a-5 — the label prompt's copy:** "Label Take" / "A short name
  for this take's card — never printed in the prose. Leave empty to
  clear." (the Mac sheet's caption, phone-alerted).
- *(Recorded, not provisional:)* the history sheet lists the take
  CAPTURED at open — a remote flip mid-read must not silently swap
  whose past you are reading; close-and-reopen follows the new
  displayed take.

**Deliberate absences (scope, not holes):** the merge-ceremony refusal
(inventory #4) and the tutorial's merge-lesson sentence (#7, PB1-4's
rider) stay UNTOUCHED — C5's sanctioned-exception design owns them
(verified still present, the only user-facing "Mac" strings left in
the mobile target) · deleted-take resurrection stays PL-3/13j's (the
trash family; the archived road back is THIS batch's) · no commit door
on the browser cards (PC4a-2's one-door reading) · the history sheet's
SwiftUI-free UIKit wiring is the recorded A1-masthead
not-headless-testable class for its pixels (the brain is fully
pinned); the chain-end look covers it.

## Stage C, batch C4a — ACCEPTED (architect, 2026-08-09)

Verified: all eight commits present; core **1215/128** and mobile
**283/53** re-confirmed by the architect's own runs (18/5 growth
exact); the Mac's `CommitRules` delegation read line-by-line — a
one-line delegation to the hoisted core brain, byte-identical
behavior, NO seventh copied-brain row (the hoist-not-copy rule
honored); the implementer's Mac 1245/219 tripwire-only + Mac spine
51/7 runs stand on that diff. The six locked-take redirects are
GONE with their doors landing in the same commits; **the S5 proof is
the batch's crown: a conflict take landing on a phone block is
discoverable by three roads from one delivery, pinned, and the
sealed arm honors S5-outranks-the-seal exactly as the spec orders.**
PC4a-1…5 ride the end bundle. The ONLY user-facing "Mac" strings
left in the mobile target are the merge-ceremony refusal + its
tutorial sentence — C5's, by design (PB1-4's rider).

## Stage C, batch C4b brief (self-contained — the implementer is briefed by THIS section plus the sections it names)

**Cast:** a fresh Fable implementer session, `~/dev/variorum-mobile`,
branch `mobile`, starting at this commit. Scope: **the editor fill**
— the C4 split's second half; ONE ladder covers C4a+C4b after this
batch.

**Read first, IN FULL:** `CLAUDE.md` (AppSpec §9's extract entry —
boundary-adjacency and the fanned-extract documented behavior — and
§12's block-TOC paragraph are the spec floor; TEXTKIT2_NOTES §3's
spell/completion crash pairing binds find-in-note) ·
`notes/MobileSoul.md` · THIS plan file top to bottom (the MATRIX's
editor-fill rows · the MID-CHAIN SITTING rulings 5 and 11 · the C4
split note · the C4a record — the surfaces you extend) · the Mac's
selection-menu/find/TOC faces in code ·
`notes/plans/mobile-architect-handoff.md`. Environment traps bind;
the MOBILE spine's seven names are in the C3-close section.

**The five work items:**

1. **Insert Block Below** — the ⋯-menu row over the standing op (the
   matrix row: mechanical; the awkward type-into-next-then-divide
   road retires as the road, the door stays).
2. **Strike/code/link doors** — the markdown vocabulary's remaining
   acts join the Aa strip's grammar (the SAME six-act brain family;
   the LK8 order question: they land INSIDE the Aa strip — the
   resting bar stays Aa · ⑂ · ⋯, and the strip may grow rows/acts
   within its capsule; the FIX-5 visibility pin's frames-in-bounds
   rule extends to whatever the strip becomes).
3. **Find-in-note** — the Write editor's find face (the Mac's ⌘F
   family, phone-shaped); TEXTKIT2 §3's crash-pairing care binds
   (no continuous-spellcheck interaction; highlight via the standing
   overlay discipline, never rendering attributes).
4. **Extract + Make Block on the selection menu** (her sitting
   ruling 5): both acts as UIEditMenu items over the existing core
   ops — extract's boundary-adjacency refusals speak in phone words;
   the fanned-extract documented behavior may warrant the Mac's hint
   (your call, PROVISIONAL).
5. **The block-TOC in-note list** (her sitting ruling 11): a
   summoned in-note block list — one row per block, its NAME where
   set else the first sentence DERIVED AT READ TIME (never stored —
   AppSpec §12's letter); tap jumps the editor there; block names
   get their phone face. Virtualized per P3 if long (the windowing
   discipline).

**Discipline (standing):** existing core ops; small additive Queries
with the four-suite duty; `Operations/`/schema/`Sync/` STOPS.
Tutorial-as-spec (the writing lesson grows where doors land).
Synchronous; red-on-old for defect-class; state-transition tests per
door; no platform-named refusals. Full mobile suite green by own run
(from 283/53, arithmetic accounted) + mobile spine 32/7 + perf 9/2
by name. Commit per logical unit with the standing trailer; record
as "## Stage C, batch C4b — BATCH RECORD"; push.
PROVISIONAL-and-continue; author-only calls stop.

## Stage C, batch C4b — BATCH RECORD (implementer, 2026-08-09; commits `a72c06f` · `c901d2a` · `20ddadd` · `c70801b` · `1be635f` · `dd715c2` + the record commit)

**All five work items shipped.** Diff scope, verified by own `git diff
--name-only 47baf1b..HEAD`: **14 files, ALL mobile app + mobile tests —
zero `Sources/VariorumCore/`, zero `App/Variorum/Shared/`, zero
Mac-side files, zero schema, zero `Sync/`, zero pbxproj** (synchronized
groups took the two new files). The brief's small-additive-Queries
allowance never fired: every brain the batch needed already existed —
`newBlock(at: .after)` (item 1), `MarkdownSurfaceDoors` + the three
`MarkdownEditing` acts (item 2), UITextView's native `UITextSearching`
adoption (item 3), the SHARED `StructuralGesturePlanner` + `extract` +
the divide compound (item 4), `Queries.blockTOC`/`tocHandle` (item 5).
The four-suite duty therefore never fired; core / Mac / Mac-spine
baselines stand by construction (core 1215/128 · Mac 1245/219
tripwire-only · Mac spine 51/7). Per item:

1. **INSERT BLOCK BELOW (`a72c06f`) — the matrix's mechanical row.**
   *Door:* a **New Block Below** row on the ⋯ block menu, heading the
   structural family (minting under the block is the gentlest
   structural act, so it reads before the knives; the ⋯ already
   resolves the caret's block and refuses honestly in the open tail —
   placement justified). *Op:* `newBlock(in:text:"",at:.after(blockID))`
   — the Mac 13b 4D act's exact op; I10 at birth (the empty variant IS
   the one live take); the Mac door's status sentence shared verbatim.
   The sibling contract whole: one flight · flush-first (a refused
   flush refuses the act) · store-led settle · caret by identity into
   the mint. The awkward type-into-next-then-divide road retires as
   THE road. `rowTitles` grew through the one builder — both doors
   (bar ⋯ + edit-menu Block submenu) follow by construction, and the
   standing vocabulary pins read the constant, so nothing else moved.
   *Tests (+2):* the mint's exact rows/caret/status; the seal +
   refused-flush guards (no platform name). *Tutorial:* the blocks &
   typing lesson's ⋯ enumeration grew the act in the same commit.

2. **STRIKE / CODE / LINK IN THE Aa STRIP (`c901d2a`).** The three
   remaining markdown acts join the strip INSIDE its capsule (the
   brief's LK8 answer; the resting bar stays **Aa · ⑂ · ⋯**,
   byte-untouched). *The geometry fact that shaped it:* ten 44 pt acts
   cannot sit on one row of any iPhone class (10×44 + 9×2 = 458 pt vs
   the tightest cell's 333), so the capsule holds **TWO ROWS** — the
   character acts **× B I S ⟨⟩ link**, then the line acts **# • ☑ ⇥**
   — the standing seven keeping their LK8 relative order, the
   arrivals landing exactly where the Mac's act table puts them
   (after Italic); the BAR grows to 84 pt while expanded
   (`reloadInputViews` carries the height) and returns to 44 at
   collapse/reset. The doors fire the SAME shared-brain acts the
   Mac's Format menu fires (`.strikethrough`/`.code`/`.link` —
   `MarkdownSurfaceDoors`, one computation both platforms; the link
   act leaves the caret inside its empty parens, the law's own
   contract, pinned). Glyphs: a struck-through **S** (the act worn),
   **⟨⟩**, and the SF `link` symbol (the seal door's SF precedent —
   symbols tint with the voice ink); labels are the registry's own
   verbs. **The FIX-5 pin EXTENDED per the brief's rule** —
   `allTenStripActsSitFullyVisibleAndTappableInsideTheBar`: every row
   inside the tightest class's cell, every button frames-in-bounds
   AND ≥44 pt, the capsule inside the expanded bar (the new vertical
   axis), the ten doors in reading order, the 6/4 split pinned; the
   Aa round-trip pin gained the height flip; the P5 wiring lookup
   descends the row level (mechanics only — every pinned label,
   order, selector unchanged). *Tests (+1):* the three acts' store
   bytes + toggle + the link caret. *Tutorial:* the formatting lesson
   demonstrates the acts by BEING them (`~~struck words~~` + a real
   link) — lesson + the shape walk's span list in the same commit.

3. **FIND-IN-NOTE (`20ddadd`).** *Shape:* the matrix row's own — iOS's
   NATIVE find interaction on the Write surface
   (`isFindInteractionEnabled`; the system navigator over UITextView's
   `UITextSearching` adoption; hardware ⌘F rides the system's own
   keys). *Door:* the masthead's **magnifier**, beside the seal glyph
   — the note-tool corner (the seal's placement class: note-level,
   always visible); finding is reading, so a sealed note finds
   freely. *TEXTKIT2 §3's care, held by construction and pinned:*
   zero highlight code of ours (match decoration is the system
   interaction's internal business — never a rendering attribute of
   ours, the overlay-discipline constraint satisfied by writing NO
   decoration at all), zero spell-check coupling (`spellCheckingType`
   untouched, no `UITextChecker` — the §3 crash pairing left exactly
   where the OS put it). **REPLACE IS STRUCTURALLY OFF (PROVISIONAL
   PC4b-2):** `supportsTextReplacement` overridden `false` at the
   protocol's own switch, so the system never offers a replace field
   — the Mac's M1/M1b measurements proved system-driven replace
   applies coalesced multi-block storage transactions that bypass the
   per-block police, and iOS's replace road is exactly as unmeasured;
   an unpoliced machine-driven sweep is the class the Mac refused.
   The in-note replace face lands when it can ride the policed path
   (the Mac's deferred-application shape, UIKit-spelled); takes-aware
   replace is 13e's either way. *Tests (+2, +1 suite):* interaction
   on + replace declined + the doorless no-op; storage/spellcheck
   untouched by the find work. *Tutorial:* the getting-around
   masthead paragraph grew the magnifier.

4. **EXTRACT + MAKE BLOCK ON THE SELECTION MENU (`c70801b` +
   `dd715c2`) — her mid-chain ruling 5.** *Doors:* two UIEditMenu
   items — the registry's verbs, voice-cased — rendered ONLY when a
   selection exists (P-2: a caret can never span; the caret menu is
   byte-unchanged, its standing pins prove it). *The brain is the ONE
   shared planner* (`StructuralGesturePlanner.plan` — boundary
   adjacency, the S4-22 word rule, the whole refusal vocabulary; zero
   second opinion anywhere), and the span body mirrors the sibling
   contract: latch → flush FIRST → **plan against the POST-flush
   surface** (planning after the flush buys what the divide door's
   re-verify buys — the plan can never hold a pre-flush reading of a
   re-tiled surface) → the standing ops → the one fresh-read settle,
   caret by identity. Extract runs `ops.extract` (source survives,
   keeps identity + fan; the extracted block lands before/after per
   edge; caret in it). Make Block runs **the Mac's exact execution**:
   two divides as ONE `withCompound` (atomic on partial failure), the
   second cut derived from the first divide's ACTUAL output (the
   seam-trim arithmetic — never re-guessed); caret in the carved
   middle. *Refusals in phone words, no platform named:* the
   **fanned middle span names the phone's OWN divide road** (Q-M2 —
   "divide at the span's edges instead: the other takes ride onto
   both halves whole") instead of a ceremony the phone deliberately
   lacks; extract's middle span points at Make Block; the cross-block
   spans name the divide/merge roads (both exist here); the guided
   cross-block flow's stand-in refuses with merge-first named
   (`crossBlockMakeBlockRefusal`). **The fanned-extract hint SHIPS
   (my call, PROVISIONAL PC4b-3):** AppSpec §9 review #10's
   documented behavior gets the Mac's contract-item-8 sentence
   verbatim through the status line (the phone's transient face) —
   the honest voice for a span the other takes silently keep.
   *Tests (+5, +1 suite):* prefix extract with flush-carried typing +
   before-the-source landing + caret; the fanned hint + the
   other-take-keeps-the-span store proof; the middle-span carve with
   source identity kept; five refusal shapes each no-Mac-asserted;
   the menu's selection-only offer. One standing pin widened with the
   doors (`dd715c2` — the edit-menu composition pin's with-selection
   arm; caret/tail arms byte-identical). *Tutorial:* the divide
   lesson grew the two knives.

5. **THE BLOCK-TOC IN-NOTE LIST (`1be635f`) — her mid-chain ruling
   11; block names' phone face.** *Door:* the masthead's **blocks**
   chip (the second identity line, beside tags · more info — the
   masthead is the phone's note-level home; PROVISIONAL PC4b-4 for
   her look: three chips now share that line). *Face:* an LK4
   masthead-sheet (the references sheet's grammar) whose rows ride a
   **LazyVStack** (P3 — virtualized; the handles derive IN the lazy
   row bodies, so a 1,000-block note derives only what it shows).
   One row per block: the NAME where set, else the first sentence
   **derived at read time through the one core brain**
   (`Queries.blockTOC` + `tocHandle` — the Mac TOC's own; never
   stored, the no-denormalization letter), the Mac row's ⑂ fan
   marker riding along — this is where names SET on the phone since
   S4 finally RENDER (the [B1] record's "Stage C's call", called).
   *The tap:* `jumpToBlock` — caret at the block's start; the
   block's first line lands a breath under the viewport top via
   `firstLineGeometry` (`.ensuresLayout` on exactly the target
   fragment — the hybrid-jump cost class), deliberately UNCLAMPED
   against `contentSize` (TK2's estimate can run under the real
   layout at the target — TEXTKIT2 §2's class — and the typewriter
   room already makes any block's top a legitimate scroll target);
   `scrollRangeToVisible` is the honest fallback. A dead block
   refuses in plain words. *Windowing judgment, recorded:* NO window
   on this list — a jump list that cannot reach the note's far
   blocks fails its whole purpose; the read is ONE `blockTOC` pass,
   cost ∝ the post (the open-a-note class, AppSpec §4's letter), and
   laziness — not truncation — is what P3 asks of a
   bounded-by-one-post surface. *The chip is the bare voiced word,
   countless* (recorded judgment: the chip refreshes at sheet
   cadence, not keystroke cadence — a stale census on the masthead
   would be worse than none; the list is the census). *Tests (+3,
   +1 suite):* rows/names/first-sentences with the derivation proven
   READ-TIME (rename + text edit follow on the next read, no stored
   copy anywhere); the jump's caret + landing offset + dead-block
   refusal; the empty state on the one standing sentence. *Tutorial:*
   the getting-around masthead paragraph grew the door.

**Tutorial-as-spec, held per owning commit:** the blocks & typing ⋯
enumeration (item 1) · the formatting lesson's three acts + the shape
walk's span list (item 2 — the ONE pinned-prose lesson, walk updated
in the same commit per PB1-3's carve-out) · the getting-around
masthead paragraph (items 3 + 5) · the divide lesson's two knives
(item 4). No new lesson (the 13-lesson counts stand — spine green
below); no walk pins prose beyond the formatting spans.

**Counts, by this implementer's own runs (iPhone 17 Pro / iOS 26.2
simulator):**
- Full mobile suite: **"Test run with 296 tests in 56 suites
  passed"** — the 283/53 baseline + this batch's 13 tests and 3
  suites, exactly accounted (insert-below 2 · strip acts 1 · find 2
  [+`MobileFindInNoteTests`] · selection acts 5
  [+`MobileSelectionActsTests`] · block list 3
  [+`MobileBlockListTests`]; the Aa/FIX-5/P5/edit-menu pins flipped
  1-for-1, every flip named in its owning commit).
- Mobile spine by its seven TRUE type names: **"Test run with 32
  tests in 7 suites passed"**.
- Perf by name (`MobilePerfFixtureTests` · `MobilePerfWalkTests`):
  **"Test run with 9 tests in 2 suites passed"**.
- Core / Mac / Mac-spine deliberately not run: zero core, zero
  `Shared/`, zero Mac-side lines in the whole batch (the scope check
  above is the proof) — the only-if-shared condition never fired;
  baselines stand (core 1215/128 · Mac 1245/219 tripwire-only · Mac
  spine 51/7).

**Test posture:** every new door landed with state-transition tests
through the view model / controller against a real in-memory store
(birth pins — the doors did not exist on the old tree, the A2 reading
of red-on-old); no defect-class fix arose, so no behavioral-revert pin
was owed. Four standing pins took sanctioned flips riding the doors
(the Aa pin's labels+height · the FIX-5 pin's ten-act extension — the
brief's own instruction · the P5 wiring lookup's row descent · the
edit-menu composition pin's with-selection arm), each recorded in its
owning commit; every flip widens with a door, none weakens.

**PROVISIONALs (for the chain's end bundle):**
- **PC4b-1 — the New Block Below row's seat** (heading the structural
  family, before Divide) and its shared status sentence — one-line
  moves for her look.
- **PC4b-2 — find ships REPLACE-OFF** (`supportsTextReplacement`
  false): the M1/M1b reasoning above; the honest alternative — the
  Mac's deferred-application gate rebuilt on UIKit — is real work her
  bundle can commission if she wants in-note replace on the phone
  before 13e's takes-aware family.
- **PC4b-3 — the fanned-extract hint ships** (the Mac's sentence
  through the status line); her look may prefer silence or other
  words.
- **PC4b-4 — the masthead's second line now carries THREE chips**
  (tags · more info · blocks) — PC3-1's two-row calm reading holds,
  but the line is fuller; her look round may re-arrange (the blocks
  chip is one line to move).
- **PC4b-5 — the strip's row split and glyphs** (6/4 by family; the
  struck-S, ⟨⟩, SF `link`) and the 84 pt expanded bar — all one-line
  changes for her look; the reset-per-presentation cadence is
  unchanged and stays her recorded look item.
- **PC4b-6 — the blocks chip is countless** (the recorded judgment
  above); a live count needs an observation the masthead chips
  deliberately don't hold — hers to commission if wanted.

**Deliberate absences (scope, not holes):** the merge-ceremony
refusal (inventory #4) + the tutorial's merge-lesson sentence (#7,
PB1-4's rider) stay UNTOUCHED for C5's sanctioned-exception design —
re-verified still the ONLY user-facing "Mac" strings in the mobile
target (grep over the final tree) · no cross-block Make Block
execution (the Mac's guided flow runs through W-ceremony arms the
phone deliberately lacks; the refusal names the merge-first road —
C5's workaround design owns any richer shape) · Delete in Every Take
stays Mac-only (her ruling 6) · the Mac TOC's expand-into-read-tier
and block-management halves stay Mac-side (the phone's list is the
summoned NAVIGATION half; block acts live on the ⋯, one home) · no
Release-build re-verify this batch (no DEBUG-gated door changed; the
standing Release checks stand).

## Stage C, batch C4b — ACCEPTED; the C4 LADDER OPENS over the pair (architect, 2026-08-09)

Verified: all seven commits present; scope clean by own check
(14 files, zero core/Shared/Mac/schema/Sync — the four-suite duty
never fired); the full mobile suite re-run by the architect's own
hand: **"Test run with 296 tests in 56 suites passed"** — 283/53 +
13/3, exact. The Aa strip's two-row growth spent the brief's own
"may grow rows" allowance with the FIX-5 pin extended to all ten
acts; the TOC's deliberately-unwindowed read is accepted as the
open-a-note cost class (a jump list must reach the far blocks;
recorded, P1-coherent). **PC4b-1…6 ride the end bundle.**

**THE C4 LADDER OPENS** over the combined pair: target
`36ab18d..28fdb65` (C4a's eight commits + C4b's seven; both batch
records + acceptances the reviewer's anchor). Fresh cold reviewer,
`notes/REVIEW_PROMPT.md` VERBATIM; findings repo-first as "## Stage
C review — C4 round 1 findings". Baselines at open: **mobile 296/56
· mobile spine 32/7 · perf 9/2 · core 1215/128 · Mac 1245/219
tripwire-only · Mac spine 51/7.**

## Stage C review — C4 round 1 findings (cold reviewer, 2026-08-09)

**Method.** `notes/REVIEW_PROMPT.md` executed verbatim, cold. Read in
full: the C4a/C4b briefs + batch records + acceptances, the PARITY
MATRIX's takes/writing rows, the MID-CHAIN SITTING rulings (5 and 11),
the refusal-copy inventory, `notes/MobileSoul.md`, AppSpec §9's
lock/archive/commit/extract/divide entries + §12's TOC paragraph,
SyncSpec §6's S5 row, TEXTKIT2_NOTES §2/§3. The combined diff
`36ab18d..667f4c6` read file-by-file in its entirety (all 29 files);
the Mac's `EditorSurfaceController` make-block body and
`StructuralGesturePlanner` read beside the phone's new callers for
byte-parity; every load-bearing record claim chased to its test or
code. All suites re-run by this reviewer's own hand (counts at the
bottom).

### Findings

1. **[MINOR] · `App/Variorum/VariorumMobile/Features/Takes/MobileTakeHistory.swift`
   (`refresh()`) · the stale-read guard compares the BLOCK only, not
   the captured take.** Mechanism: `refresh()` captures `variantID` at
   entry, awaits the DB read, then guards `openBlockID == blockID`
   before writing `items`. `variantID` is captured at `open()` (the
   recorded held-for-the-sheet's-life design). Close the sheet, flip
   the block's displayed take on the page, reopen on the SAME block —
   the reopened sheet's `variantID` is the new take, but a first-open
   refresh still in flight passes the block-only guard and can land
   LAST, listing the OLD take's history under the new capture until
   the next projection ingest re-reads. Reachability is one in-flight
   DB read's latency across a close→flip→reopen by hand — narrow, and
   it self-heals on any delivery — and the window is not deterministically
   pinnable through the current seams (the read is not injectable), so
   the fix protocol may fairly rank it hygiene rather than bug-class.
   Proposed fix: extend the guard one clause —
   `guard openBlockID == blockID, self.variantID == variantID` — so a
   stale in-flight read can never publish under a newer capture.
   (`reloadArchived()` has no analogous hazard: its data is per-block
   and its guard already covers the block.)

2. **[NIT] · `App/Variorum/VariorumMobile/Features/Write/MobileBlockList.swift`
   (the sheet's `.task` refresh) · the open list never re-reads on a
   delivery.** The rows load once per presentation; a remote divide or
   block arrival landing WHILE the sheet is open (MobileSoul §5.3:
   offline/sync races are the phone's normal) leaves the list one
   delivery stale — the record's "the list is the census" is true at
   open-cadence only. Honesty is preserved (a tap on a vanished block
   refuses in the pinned words; a tap on a live row jumps correctly),
   so this is a small staleness hazard, not wrong behavior. A
   `projectionDidChange`-style re-read while presented — or a line in
   the recorded judgment saying open-cadence is the deliberate scope —
   would close it.

3. **[NIT] · `App/Variorum/VariorumMobile/Features/Write/MobileStructural.swift:475`
   (`blockInsertedStatus`) · the shared sentence is now THREE
   literals.** "New block added below — type away." exists verbatim at
   Mac `TakesViewModel.swift:1402`, Mac `EditorSurfaceController.swift:385`,
   and the new mobile static. The record's "shared verbatim" is
   by value, not by symbol; the one-vocabulary discipline elsewhere
   (this batch's own refusal statics) pins copy so it cannot fork.
   Cross-target sharing would need a Shared home, but the Mac's own
   two literals could at least read one constant. Drift hazard only —
   no behavior at stake.

4. **[NIT] · `App/Variorum/VariorumMobile/Features/Takes/MobileTakeHistorySheetView.swift`
   (`renderRows`) · every savepoint materializes as a UIView on every
   render, unwindowed and without reuse.** Cost ∝ the take's commit
   count — bounded by one variant's history (P1-coherent as the
   open-cost class, like the TOC's recorded judgment), but idle
   auto-commits accrete over years, and while the sheet is open every
   remote-delivery ingest rebuilds the full row set (keystroke-cadence
   rebuilds cannot occur — the page editor stands down under the
   sheet). The TOC list took a LazyVStack for the same shape; the
   comments-sheet precedent this view copies has few rows by nature.
   A look-round/scale item, recorded so it is a decision rather than
   an accident.

No BLOCKER. No MAJOR. Nothing in the pair invents product behavior,
touches `Sync/`/`Operations/`/schema, copies text across entities,
stores a derived handle, or scales with corpus size.

### Clean bill (load-bearing things specifically checked and found solid)

- **The S5 discoverability proof — the batch's crown, verified against
  the spec's letter.** `MobileConflictDiscoveryTests` drives the real
  op (`resolveSyncConflict` — the engine's landing door), and the pins
  hold SyncSpec §6/AppSpec §9 exactly: fresh ACTIVE take, label
  `'conflict'`, at the fan's end; the chosen pointer AND chosen text
  store-asserted untouched (raw SQL on `container_block`); THREE roads
  from the one delivery (the ⑂ badge on a laid-out surface, the pill's
  "take 1/2", the browser card wearing the label, not chosen); and the
  sealed arm honors S5-outranks-the-seal — the conflict lands and
  stays discoverable under `lockPost`, viewing free, editing refusing
  with the sealed copy. The delivery arm is the standing observation's
  exact ingest (`fromDelivery: true`). MobileSoul §5.3's acceptance
  item now has its executable form.
- **The commit-history hoist is a hoist, not a copy.**
  `Queries.commitPredatesSplit` (core) is byte-identical to the old
  `CommitRules` body (`splitDates.max()` guard + `<`); the Mac enum is
  now a ONE-line delegation; the phone's history face reads the same
  predicate. The Mac's own pin (`EditorSessionTests`, 20 tests) run by
  this reviewer: green through the delegation. Core gained the
  predicate's own test, mirror-cased.
- **Take lock/unlock's flush-first guard — the traced mechanism and a
  pin that goes red on the blind path.** Pending surface bytes live in
  the coordinator; a blind `lockVariant` would insure the STALE store
  text and the later flush would refuse `.lockedVariant`, stranding
  the typed bytes — and `MobileTakeLockTests`'s assertions (store text
  == typed, insurance commit text == typed, `!isDirty`) all diverge on
  that path. The I6 arm pins ZERO commits on a committed-clean flip;
  both seal arms speak phone words; unlock needs no flush and the
  keep-pending bytes land immediately after unlock because
  `refreshTakesFromStore` flushes first (read and confirmed).
- **The six locked-take redirects + #14 are gone, and the grep claim
  is TRUE.** All seven sites route through three pinned statics (page
  sentence · in-sheet pair · verb arm) + the archived-list road; a
  no-"Mac" sweep rides the pins. This reviewer's own grep over the
  final tree: the ONLY user-facing "Mac" strings in the mobile target
  are the merge-ceremony refusal (`MobileStructural.swift:239`) and
  its tutorial sentence (`MobileTutorialSeeder.swift:528`) — C5's
  sanctioned pair (PB1-4's rider); the `SpikeScenarios.swift:228` hit
  is DEBUG diagnostics, inventory #15's recorded no-action.
- **Extract + Make Block ride the ONE shared planner — no second
  brain.** `StructuralGesturePlanner` (Shared) is untouched by the
  diff — both commands and both plan cases pre-existed; the phone
  calls `plan()` with the S4-22 snapping and whole refusal vocabulary
  intact. The span body's order is honest: latch → flush FIRST → plan
  against the post-flush surface (the flush persists bytes without
  rewriting surface characters, so the captured range stays valid and
  the plan reads the re-tiled index). Make Block is the Mac's exact
  execution — `withCompound` two-divide, the second cut derived from
  the first divide's ACTUAL output via the same dropped-units
  arithmetic (compared line-by-line against
  `EditorSurfaceController.swift:226–235`); atomicity on partial
  failure is `withCompound`'s rollback, read in core. The fanned
  middle span names the phone's OWN Q-M2 divide road; cross-block
  spans name divide/merge — both roads exist on the phone; five
  refusal shapes pinned no-Mac; the fanned-extract hint is the Mac's
  contract-item-8 strings verbatim; the selection-only offer is
  pinned with the caret arm byte-identical.
- **The Aa strip's two-row growth and the extended FIX-5 pin.**
  `allTenStripActsSitFullyVisibleAndTappableInsideTheBar` covers the
  brief's letter: each row within the tightest class's 333 pt cell,
  every button frames-in-bounds (±0.5) AND ≥44 pt, vertical
  containment inside the capsule and the capsule inside the 84 pt
  expanded bar (the new axis), the ten doors in
  `formattingRowLabels`' flattened order, the 6/4 split pinned in
  both geometry and constants. The resting bar (Aa · ⑂ · ⋯, 44 pt)
  is pinned byte-unchanged with the height round-trip; the three
  arrivals fire the shared `MarkdownEditing` acts with store bytes,
  toggle, and the link's caret-in-parens pinned, identity audit zero.
- **Find-in-note holds TEXTKIT2 §3's care by construction.** The diff
  adds `isFindInteractionEnabled = true`, one `presentFind()` call,
  and the `supportsTextReplacement` override — zero highlight code,
  zero rendering attributes, zero spell-check lines (grep-confirmed;
  the pin asserts `spellCheckingType == .default` and storage
  untouched). Replace is declined at the protocol's own switch with
  the M1/M1b reasoning carried in the override's comment (PROVISIONAL
  PC4b-2, honestly recorded); a sealed note finds freely.
- **The block-TOC is read-time truth and the jump is the hybrid-jump
  class.** `Queries.blockTOC`/`tocHandle` are the pre-existing core
  brains (zero core lines in C4b — confirmed by `git log` over
  `Sources/` and `Shared/`); the derivation-is-read-time pin renames
  and edits the fixture and watches the handle follow with no stored
  copy; `jumpToBlock` ensures layout on exactly the target fragment
  (`firstLineGeometry`, pre-existing), floor-clamps at 0 only
  (deliberately unclamped above, TEXTKIT2 §2's under-estimate class,
  reasoning in the code), lands the pinned 24 pt breath, and refuses
  a dead block in pinned words. The LazyVStack + no-window judgment
  is coherent: one `blockTOC` pass ∝ the post, laziness not
  truncation.
- **Insert Block Below is the standing op through the sibling
  contract.** `newBlock(text: "", at: .after)` — I10 at birth pinned
  (the empty variant IS the one live take), caret by identity, the
  seal and refused-flush guards pinned with no platform name, and
  `rowTitles` grew through the one builder so both ⋯ doors follow by
  construction.
- **Sanctioned pin flips, all accounted.** C4a: the three browser
  copy pins + the takes-page pin + the structural pin + the card-⋯
  four-row grammar; C4b: the Aa labels+height, the FIX-5 ten-act
  extension, the P5 row-descent, the edit-menu with-selection arm.
  Every flip widens with a door; no pin was deleted (the diff is
  insertion-only across test files but for the flips themselves).
- **Tutorial-as-spec held per owning commit.** Lock/label paragraphs
  appended after the staged blocks (staging indices stand); the
  savepoint paragraph + ⋯ enumeration with the crystallize walk's
  4→5 in the same commit; the formatting lesson demonstrates by BEING
  (~~struck words~~ + a real link) with the render-hides pinned; the
  two knives on the divide lesson; the magnifier + blocks chip in the
  getting-around paragraphs. Merge lesson untouched for C5, verified.
- **Scope discipline.** Zero `Sources/VariorumCore/Sync/`, zero
  `Operations/`, zero `Persistence/`/schema, zero
  `App/Variorum/Shared/`, zero pbxproj; the only core lines are
  C4a's sanctioned additive predicate + its test (four-suite duty
  fired there; C4b's never fired, correctly).

### This reviewer's runs (iPhone 17 Pro / iOS 26.2 simulator; core from the repo root; Mac from `App/Variorum/`)

- Full mobile suite: **"Test run with 296 tests in 56 suites passed"**
  — the recorded baseline, exact.
- Mobile spine by its seven TRUE type names (the C3-close list):
  **"Test run with 32 tests in 7 suites passed"**.
- Perf by name: **"Test run with 9 tests in 2 suites passed"**.
- Core `swift test`: **"Test run with 1215 tests in 128 suites
  passed"**.
- Mac `EditorSessionTests` (the delegation's covering suite — the
  batch's only Mac-side line): **"Test run with 20 tests in 1 suite
  passed"**. The full Mac 1245/219 tripwire-only baseline stands on
  the implementer's and architect's recorded same-diff runs.
