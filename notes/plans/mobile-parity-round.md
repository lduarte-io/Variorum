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

**CURRENT STAGE → A (the floor) — not yet kicked off; the `mobile` →
`main` v1 merge landed 2026-08-03 (see Branch & merge discipline).**

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
| **D — Polish & the look round** | The whole-app spacing/design pass against the LK canon with her screenshot rounds (the L11 design/beauty ledger row realized); remaining P1–P44 flips as she makes them; device feel-round riders (loupe, badge target, marker z-order, sheet keyboard, Write→Read freshness); **the exit gate runs the 100k performance fixture ON DEVICE** (latency AND peak memory — her explicit bar). **At D's close (her plan, 2026-08-04): the first INTERNAL TestFlight** — *"super basic internal testflight… for just me and whoever I add"* — her word triggers it; Stage E carries the readiness work that broader exposure needs. | Her acceptance + the on-device 100k run |
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
