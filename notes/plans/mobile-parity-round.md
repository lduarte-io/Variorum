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
before/after Write pairs are her spacing finding's exact evidence);
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
