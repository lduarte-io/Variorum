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

**CURRENT STAGE → A (the floor) — KICKED OFF 2026-08-09 as the first
leg of a CHAINED A→D run (her ruling at this kickoff — see STAGE A
KICKOFF below; stages still run as their own phases, but no author
gate between them; ONE combined sitting at the chain's end).**

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
